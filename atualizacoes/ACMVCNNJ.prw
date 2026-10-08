#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDef.ch'

/*
@Autor:     André Claro / 35 99877-5495 andre.claro@acclaro.com.br
@Data:      Nov/2025
@Descriçío: ExecAuto para inclusío de Romaneio na entrada

Tipo das SX5
X5_CHAVE	X5_DESCRI
1     	(E) ENTRADA POR PRODUCAO                               
2     	(S) REMESSA PARA DEPOSITO                              
3     	(E) ENTRADA PARA DEPOSITO                              
4     	(S) SAIDA POR VENDA                                    
5     	(E) ENTRADA POR COMPRA                                 
6     	(S) DEVOLUCAO DE DEPOSITO                              
7     	(E) DEVOLUCAO DE REMESSA                               
8     	(S) DEVOLUCAO DE COMPRA                                
9     	(E) DEVOLUCAO DE VENDA                                 
A     	(E) ENTRADA POR TRANSFERÊNCIA                          
B     	(S) SAÍDA POR TRANSFERÊNCIA                            

*/
User Function ACSF2NNJ(_nRecSF2)

Local _aArea := GetArea()
Local _lRet := .F.

Default _nRecSF2 := 0 

If _nRecSF2 > 0 ///se veio da nota, Não apresento a tela com as insconsistencias
    _lRet := U_ACEXOG250( _nRecSF2 ,  .F. )
Else
    DbSelectArea("SF2")
    SF2->(DbSetOrder(1))
    SF2->(DbGoTop())

    If SF2->(DbSeek(xFilial("SF2") + NJJ->NJJ_DOCNUM + NJJ->NJJ_DOCSER ))
        _lRet := U_ACEXOG250( SF2->(RECNO()) , .T.  )
    Endif
EndIf

RestArea(_aArea)

Return _lRet


User Function ACEXOG250(_nRecSF2, _lTela)

Local _lRet := .T.
Local _aArea := GetArea()
Local _aAreaSF2 := SF2->(GetArea())
Local _aAreaSA1 := SA1->(GetArea())
Local _aAreaSA2 := SA2->(GetArea())
Local _aAreaNJJ := NJJ->(GetArea())
Local _aAreaNJR := NJR->(GetArea())
Local _cFilArea := cFilAnt
Local _cAlias := ''
Local _cQuery := ''
Local _nX := 0
Local _aTempCpo := {}
Local _aCposTab := {}
Local _cRomEnt := ""
Local _cCodRom := ""
Local _aFldlNJJ := {} 
Local _aGridNJK := {}
Local _aGridNK4 := {}
Local _aGridNJM := {}
Local _cFilDest := ""
Local _cCrtEnt := ""
Local _cEntDest := ""
Local _cPesoSN  := ""
Local _nQtdFis  := 0
Local _cCpoNJJnot := Alltrim(SuperGetMv("MV_ZNJJNAO", .F. ,"")) //Campos ignorados na entrada NJJ
Local _cCpoNJMnot := Alltrim(SuperGetMv("MV_ZNJMNAO", .F. ,"")) //Campos ignorados na entrada NJM
Local _cCpoNJKNao := Alltrim(SuperGetMv("MV_ZNJKNAO", .F. ,"NJK_CODROM")) //Campos ignorados na entrada NJK
Local _cProblema := ""
Local _cTesEnt := ""
Local _cCodEnt := ""
Local _cLjEnt := ""
Local _cChvNFE := ""

_cCpoNJMnot += Alltrim(SuperGetMv("MV_ZNJMNOT", .F. ,""))

Default _lTela := .F.
Default _nRecSF2 := 0 

If _nRecSF2 <> 0 .AND. _lRet
    DbSelectArea("SF2")
    SF2->(DbSetOrder(1))
    SF2->(DbGoTo(_nRecSF2))
    If SF2->(RECNO()) == _nRecSF2
        _cFilial := SF2->F2_FILIAL

        If _cFilial <> cFilAnt
            cFilant := _cFilial
            OpenSm0(cEmpAnt + cFilAnt)
        EndIf

        _cChvNFE := SF2->F2_CHVNFE // (_cAlias)->NJJ_CHVNFE
        _cQuery := " SELECT TOP 1  NJJ_CODROM, NJJ_CODCTR, * 
        _cQuery += " FROM       "+RetSqlName("NJJ")+" WITH(NOLOCK) "
        _cQuery += " WHERE      D_E_L_E_T_ = '' 
        _cQuery += "        AND NJJ_TPFORM = '1'  AND NJJ_FILIAL = '"+SF2->F2_FILIAL+"' "
        _cQuery += "        AND NJJ_DOCSER = '"+SF2->F2_SERIE+"' 
        _cQuery += "        AND NJJ_DOCNUM = '"+SF2->F2_DOC+"' "
        _cAlias := GetNextAlias()
        MpSysOpenQuery(_cQuery, _cAlias)

        If (_cAlias)->(!EOF())
            _cCodRom := (_cAlias)->NJJ_CODROM
            _nQtdFis := (_cAlias)->NJJ_QTDFIS
            
            // Retorna dados da autorização de saída
            //_aRet := {(_cAlias)->NJP_XENAUT, (_cAlias)->NJP_XPSDES, (_cAlias)->NJP_XCRTDE } 
            _aCodAut := ACRAUTSAI((_cAlias)->NJJ_FILIAL, (_cAlias)->NJJ_CODCTR, (_cAlias)->NJJ_CODAUT)
            _cEntDest := _aCodAut[1]
            If _cEntDest == "S"
                _cPesoSN  := _aCodAut[2] // Com ou sem pesagem                
                _cCrtEnt := _aCodAut[3] // Contrato no Destino.
            Else
                ConOut("ACMVCNNJ - Contrato sem entrada automática no destino")
                _cProblema += "ACMVCNNJ - Contrato sem entrada automática no destino"+CRLF
                _lRet := .F. //Return                
            EndIf

            If _lRet
                DbSelectArea("NJR")
                NJR->(DbSetOrder(1))
                NJR->(DbGoTop())
                If NJR->(DbSeek(xFilial("NJR") + (_cAlias)->NJJ_CODCTR ))
                    If _cEntDest == "S"
                        //_cCrtEnt := NJR->NJR_XCRTDE // Contrato no Destino.
                        //_cPesoSN  := NJR->NJR_XPSDES // Com ou sem pesagem
                        //_cTesEnt := NJR->NJR_TESEST
                        _cCodEnt := NJR->NJR_CODENT
                        _cLjEnt  := NJR->NJR_LOJENT
                        
                    Else
                        ConOut("ACMVCNNJ - Contrato sem entrada automática no destino")
                        _cProblema += "ACMVCNNJ - Contrato sem entrada automática no destino"+CRLF
                        _lRet := .F. //Return                           
                    Endif
                Else
                    ConOut("ACMVCNNJ - Contrato não encontrado.")
                    _cProblema += "ACMVCNNJ - Contrato "+(_cAlias)->NJJ_CODCTR+" não encontrado."+CRLF
                    _lRet := .F. //Return                
                EndIf
            EndIf
        Else
            ConOut("ACMVCNNJ - Nota fiscal/Série "+SF2->F2_DOC+"/"+SF2->F2_SERIE+" Não encontrada nos romaneios da filial "+SF2->F2_FILIAL)
            _cProblema += "ACMVCNNJ - Nota fiscal/Série "+SF2->F2_DOC+"/"+SF2->F2_SERIE+" Não encontrada nos romaneios da filial "+SF2->F2_FILIAL+CRLF
            _lRet := .F. 
        EndIf

        (_cAlias)->(DbCloseArea())

        If cFilAnt <> _cFilial .and. _lRet
            cFilAnt := _cFilial
            OpenSm0( cEmpAnt + cFilAnt )
        EndIf

        If Empty(_cCodRom)
            ConOut("ACMVCNNJ - NF Saida sem Romaneio")
            _cProblema += "ACMVCNNJ - NF Saida sem Romaneio"+CRLF
            _lRet := .F. 
        ElseIf _lRet

            If SF2->F2_TIPO $ "DB" //Fornecedor
                DbSelectArea("SA2")
                SA2->(DbSetOrder(1))
                SA2->(DbGoTop())
                If SA2->(DbSeek(xFilial("SA2") + SF2->(F2_CLIENTE + F2_LOJA ) ))
                    If !Empty(SA2->A2_FILTRF)
                        _cFilDest := SA2->A2_FILTRF
                    Else
                        ConOut("ACMVCNNJ - Fornece "+SA2->A2_COD+"-"+SA2->A2_LOJA +' Não é filial. Campo A2_FILTRF vazio')
                        _cProblema += "ACMVCNNJ - Fornece "+SA2->A2_COD+"-"+SA2->A2_LOJA +' Não é filial. Campo A2_FILTRF vazio'+CRLF
                        _lRet := .F.         
                    EndIf
                EndIf

            Else //Cliente
                DbSelectArea("SA1")
                SA1->(DbSetOrder(1))
                SA1->(DbGoTop())
                If SA1->(DbSeek(xFilial("SA1") + SF2->(F2_CLIENTE + F2_LOJA ) ))
                    If !Empty(SA1->A1_FILTRF)
                        _cFilDest := SA1->A1_FILTRF
                    Else
                        ConOut("ACMVCNNJ - Cliente "+SA1->A1_COD+"-"+SA1->A1_LOJA +' Não é filial. Campo A1_FILTRF vazio')
                        _cProblema += "ACMVCNNJ - Cliente "+SA1->A1_COD+"-"+SA1->A1_LOJA +' Não é filial. Campo A1_FILTRF vazio'+CRLF
                        _lRet := .F.   
                    EndIf
                EndIf        
            EndIf

            _cQuery := ""
            _cQuery += " SELECT *     "
            _cQuery += " FROM 	SYS_COMPANY   "
            _cQuery += " WHERE 		D_E_L_E_T_ = ''    "
            _cQuery += " 		AND M0_CODIGO = '"+cEmpAnt+"'   "
            _cQuery += " 		AND M0_CODFIL = '"+_cFilDest+"'   "

            _cAlias := GetNextAlias()
            MpSysOpenQuery(_cQuery, _cAlias)
            IF (_cAlias)->(!EOF())
                ConOut("ACMVCNNJ - Filial de destino sera: "+cEmpAnt + " - "+ _cFilDest+" "+Alltrim((_cAlias)->M0_FILIAL)  )
            Else
                ConOut("ACMVCNNJ - Filial "+cEmpAnt + " - "+ _cFilDest+" Não existe no SYS_COMPANY.")
                _cProblema += "ACMVCNNJ - Filial "+cEmpAnt + " - "+ _cFilDest+" Não existe no SYS_COMPANY." + CRLF             
                _lRet := .F. //Return    
            EndIf
            (_cAlias)->(DbCloseArea())


            _cQuery := " SELECT TOP 1  NJJ_CODROM, NJJ_CODCTR, * 
            _cQuery += " FROM       "+RetSqlName("NJJ")+" WITH(NOLOCK) "
            _cQuery += " WHERE      D_E_L_E_T_ = '' 
            _cQuery += "        AND NJJ_FILIAL = '"+_cFilDest+"' AND NJJ_STATUS <> '4'    "
            _cQuery += "        AND NJJ_CHVNFE = '"+_cChvNFE+"' AND NJJ_CHVNFE <> ''  "


            _cAlias := GetNextAlias()
            MpSysOpenQuery(_cQuery, _cAlias)

            If (_cAlias)->(!EOF())
                _cRomEntrad := ""
                While (_cAlias)->(!EOF())
                    _cRomEntrad += (_cAlias)->NJJ_CODROM+CRLF
                    (_cAlias)->(DbSkip())
                EndDo
                ConOut("ACMVCNNJ - A NF da chave: "+_cChvNFE+" já existe na filial "+_cFilDest+" de destino."  )
                _cProblema += "ACMVCNNJ - A NF da chave: "+_cChvNFE+" já existe na filial de destino."+CRLF
                _cProblema += "ACMVCNNJ - Romaneios na entrada: "+CRLF+_cRomEntrad+CRLF
                _lRet := .F.
            EndIf

            (_cAlias)->(DbCloseArea())
            /* ESSA VALIDAÇÃO JÁ FOI FEITA ACIMA PARA CARREGAR AS VARIAVEIS _cCrtEnt E _cPesoSN
            If _lRet
                DbSelectArea("NJJ")
                NJJ->(DbSetOrder(1))
                NJJ->(DbGoTop())
                If NJJ->(DbSeek(xFilial("NJJ") + _cCodRom ))
                    DbSelectArea("NJR")
                    NJR->(DbSetOrder(1))
                    NJR->(DbGoTop())
                    If NJR->(DbSeek(xFilial("NJR") + NJJ->NJJ_CODCTR ))
                        If NJR->NJR_XENAUT == "S"
                            _cCrtEnt := NJR->NJR_XCRTDE // Contrato no Destino.
                            _cPesoSN  := NJR->NJR_XPSDES // Com ou sem pesagem
                        Else
                            ConOut("ACMVCNNJ - Contrato sem entrada automática no destino")
                            _cProblema += "ACMVCNNJ - Contrato sem entrada automática no destino" + CRLF
                            _lRet := .F. //Return                           
                        Endif
                    Else
                        ConOut("ACMVCNNJ - Romaneio sem contrato.")
                        _cProblema += "ACMVCNNJ - Romaneio sem contrato." + CRLF             
                        _lRet := .F. //Return    
                    EndIf                
                Else
                    ConOut("ACMVCNNJ - Romaneio Não existe.")
                    _cProblema += "ACMVCNNJ - Romaneio Não existe." + CRLF             
                    _lRet := .F. //Return    
                Endif
            EndIf
            */
        EndIf

        If _lRet  ///Se chegou até aqui, vou preparar os arrays para enviar para execAuto.
            _cFilBkp := cFilAnt
            cFilAnt := _cFilDest
            OpenSm0(cEmpAnt + cFilAnt)
            _cFilNJJ := xFilial("NJJ")
            While .T.
                _cRomEnt := ""
                _cRomEnt := GetSXENum('NJJ','NJJ_CODROM')
                
                NJJ->(dbGoTop())
                If NJJ->(dbSeek( _cFilNJJ + _cRomEnt ))
                    ConfirmSX8()
                Else
                    Exit
                EndIf
            EndDo
            
            If !Empty(_cCrtEnt)
                DbSelectArea("NJR")
                NJR->(DbSetOrder(1))
                NJR->(DbGoTop())
                If !NJR->(DbSeek(xFilial("NJR") + _cCrtEnt ))
                    ConOut("ACMVCNNJ - Contrato de Entrada Não existe!")
                    _cProblema += "ACMVCNNJ - Contrato de Entrada Não existe!"+CRLF
                    _lRet := .F. 
                Else
                    //Johnny pediu para buscar os dados do contrato de entrada.
                    _cTesEnt := NJR->NJR_TESEST
                    _cCodEnt := NJR->NJR_CODENT
                    _cLjEnt  := NJR->NJR_LOJENT
                    
                    //Se a TES de entrada for maior que 500 então eu busto a TES de devolução informada na TES de saída.
                    If _cTesEnt > '500'
                        DbSelectArea("SF4")
                        SF4->(DbSetOrder(1))
                        SF4->(DbGoTop())
                        If SF4->(DbSeek(xFilial("SF4") + _cTesEnt ))
                            If !Empty(SF4->F4_TESDV)
                                _cTesEnt := SF4->F4_TESDV
                            Else
                                ConOut("ACMVCNNJ - TES de SAÍDA sem TES de entrada para devolução!")
                                _cProblema += "ACMVCNNJ - TES "+_cTesEnt+" informada no contrato: "+_cCrtEnt+" de entrada não possui F4_TESDV preenchido!"+CRLF
                                _lRet := .F.
                            Endif
                        Else
                            ConOut("ACMVCNNJ - TES de entrada informada não existe!")
                            _cProblema += "ACMVCNNJ - TES "+_cTesEnt+" informada no contrato: "+_cCrtEnt+" não existe na filial "+xFilial("SF4")+"!"+CRLF
                            _lRet := .F.
                        EndIf
                    EndIf
                EndIf
            Else
                ConOut("ACMVCNNJ - Contrato de Entrada não informado!")
                _cProblema += "ACMVCNNJ - Contrato de Entrada não informado!"+CRLF
                _lRet := .F.             
            EndIf

            If _lRet
                cFilAnt := _cFilBkp
                OpenSm0(cEmpAnt + cFilAnt)
                _cFilNJJ := xFilial("NJJ")

                //Colocar em parametros depois
                _cCposNJJ := SuperGetMv("MV_ZNJJS01",.F., "NJJ_DOCEMI|NJJ_TIPENT|NJJ_FILIAL|NJJ_CODROM|NJJ_TIPO|NJJ_PLACA|NJJ_CODMOT|NJJ_TPFORM|NJJ_DOCESP|NJJ_CHVNFE|NJJ_DOCSER|NJJ_DOCNUM|NJJ_DOCEMI|NJJ_QTDFIS|NJJ_VLRUNI|NJJ_VLRTOT|NJJ_FRETE|NJJ_SEGURO|NJJ_DESPES|NJJ_CODCTR|NJJ_CODAUT|NJJ_XESPEC|NJJ_XVOLUM")
                _cCposNJJ += +"|"+SuperGetMv("MV_ZNJJS02",.F., "")
                //"NJJ_CODENT|NJJ_LOJENT|NJJ_ENTENT|NJJ_ENTLOJ|NJJ_TES|

                /* INICIO Composiçío do array da NNJ - _aFldlNJJ  */
                _cQuery := " SELECT * 
                _cQuery += " FROM "+RetSqlName("NJJ")+" NJJ WHERE NJJ.D_E_L_E_T_ = '' AND NJJ.NJJ_FILIAL = '"+xFilial("NJJ")+"'  "
                _cQuery += " AND NJJ.NJJ_CODROM = '"+ _cCodRom +"'  "
                _cAlias := GetNextAlias()
                MpSysOpenQuery(_cQuery, _cAlias)
                _aTempCpo := {}
                _aRet := ACRCODAUT(_cFilDest, _cCrtEnt, _nQtdFis) // {Autorizaçío, Local}
                If (_cAlias)->(!EOF())
                    _aCposTab := {}
                    _aCposTab := FWSX3Util():GetAllFields( "NJJ" , .F. )
                    While (_cAlias)->(!EOF())
                        _aTempCpo := {}
                        For _nX := 1 to Len(_aCposTab)
                            If(!Empty(FwSX3Util():GetFieldType(alltrim(_aCposTab[_nX]))))
                                If GetSx3Cache(alltrim(_aCposTab[_nX]), "X3_CONTEXT") <> "V"
                                    _cTpCpo := GetSx3Cache(alltrim(_aCposTab[_nX]), "X3_TIPO")
                                    
                                    If Alltrim(_aCposTab[_nX]) $  "NJJ_STSPES"
                                        If _cPesoSN == "S"  //0=Sem Pesagem;1=Primeira Pesagem;2=Segunda Pesagem
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), "2"   , Nil     } )
                                        Else
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), "0"   , Nil     } )
                                        Endif
                                    ElseIf Alltrim(_aCposTab[_nX]) $  "NJJ_MODPS1"
                                        If _cPesoSN == "S"  //A=Automatica / M=Manual
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), "A"   , Nil     } )
                                        Else
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), "M"   , Nil     } )
                                        Endif
                                    ElseIf Alltrim(_aCposTab[_nX]) $  "NJJ_TIPENT" //0=C/Pesagem;1=Terceiros;2=S/Pesagem;3=Retencao
                                        If _cPesoSN == "S"  
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), "0"   , Nil     } )
                                        Else
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), "2"   , Nil     } )
                                        Endif
                                    ElseIf Alltrim(_aCposTab[_nX]) $  _cCposNJJ //SOMENTE OS CAMPOS INFORMADOS AQUI SERíƒO ENVIADOS
                                        If Alltrim(_aCposTab[_nX]) == "NJJ_FILIAL"
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), _cFilDest   , Nil     } )
                                        ElseIf Alltrim(_aCposTab[_nX]) == "NJJ_CODROM" //Cí³digo de romaneiro no destino
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), _cRomEnt   , Nil      } )
                                        ElseIf Alltrim(_aCposTab[_nX]) == "NJJ_TIPO" //Tipos informados na SX5 -> K5 -> 3 Entrada por remessa
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), IIF( (_cAlias)->NJJ_TIPO=="2","3","7")   , Nil      } )
                                        ElseIf Alltrim(_aCposTab[_nX]) == "NJJ_TPFORM"
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), "2"   , Nil      } ) //Formulário prí³prio igual a Não.

                                        ElseIf Alltrim(_aCposTab[_nX]) == "NJJ_STATUS"
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), "0"   , Nil      } ) //0-Pendente;1=Completo

                                        ElseIf Alltrim(_aCposTab[_nX]) == "NJJ_CHVNFE" 
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), _cChvNFE   , Nil      } ) //0-Pendente;1=Completo

/*
                                        ElseIf Alltrim(_aCposTab[_nX]) == "NJJ_PLACA" //Campo PLACA í‰ OBRIGATORIO - PENDENTE
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), "ARJ5923"   , Nil      } )
                                        ElseIf Alltrim(_aCposTab[_nX]) == "NJJ_XESPEC" 
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), (_cAlias)->NJJ_DOCESP   , Nil      } )  
                                        ElseIf Alltrim(_aCposTab[_nX]) == "NJJ_XVOLUM" 
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), 1  , Nil      } ) 
*/


                                        ElseIf Alltrim(_aCposTab[_nX]) == "NJJ_LOCAL"  //BUSCA DA AUTORIZAÇíO
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), _aRet[2]     , Nil      } )  
                                        ElseIf Alltrim(_aCposTab[_nX]) == "NJJ_CODAUT"  //CODIGO DE AUTORIZÇíO
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), _aRet[1]     , Nil      } )                                              

                                        ElseIf Alltrim(_aCposTab[_nX]) == "NJJ_CODCTR" //Cí³digo de romaneiro no destino
                                            If !Empty(_cCrtEnt)
                                                aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), _cCrtEnt   , Nil      } )
                                            EndIf

                                        ElseIf !(  Alltrim(SubStr(_aCposTab[_nX],5,20))  $ _cCpoNJJnot) //Campos ignorados na execAuto o prefixo eu ignoro, NJJ_
                                            IF _cTpCpo == "D"
                                                If     ValType(&('(_cAlias)->'+Alltrim(_aCposTab[_nX]))) == "D"
                                                    aAdd(_aTempCpo, {   Alltrim(_aCposTab[_nX]), &('(_cAlias)->'+Alltrim(_aCposTab[_nX])  )   , Nil          } )
                                                ElseIf ValType(&('(_cAlias)->'+Alltrim(_aCposTab[_nX]))) == "C"
                                                        aAdd(_aTempCpo, {   Alltrim(_aCposTab[_nX]), Stod(&('(_cAlias)->'+Alltrim(_aCposTab[_nX]) ) )   , Nil          } )
                                                EndIf
                                            ElseIf _cTpCpo $ "CN" //Caracter ou numérico
                                                aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), &('(_cAlias)->'+Alltrim(_aCposTab[_nX]) )    , Nil      } )
                                            EndIf
                                        EndIf
                                    EndIf
                                EndIf
                            EndIf 
                        Next _nZ                                                
                        aAdd(_aFldlNJJ, aClone(_aTempCpo))
                        _aTempCpo := {}
                        (_cAlias)->(DbSkip())
                    EndDo



                EndIf







                /* INICIO Composiçío do array da NNJ - _aGridNJK */
                _cQuery := " SELECT * 
                _cQuery += " FROM "+RetSqlName("NJK")+" NJK WHERE NJK.D_E_L_E_T_ = '' AND NJK.NJK_FILIAL = '"+xFilial("NJK")+"'  "
                _cQuery += " AND NJK.NJK_CODROM = '"+ _cCodRom +"'  "
                _cAlias := GetNextAlias()
                MpSysOpenQuery(_cQuery, _cAlias)
                _aTempCpo := {}
                If (_cAlias)->(!EOF())
                    _aCposTab := {}
                    _aCposTab := FWSX3Util():GetAllFields( "NJK" , .F. )
                    _cCpoNJKSim := "NJK_FILIAL|NJK_CODROM|NJK_ITEM|NJK_TPCLAS|NJK_PERDES|NJK_READES|NJK_QTDDES|NJK_DESRES|NJK_RESINF"

                    While (_cAlias)->(!EOF())
                        _aTempCpo := {}
                        For _nX := 1 to Len(_aCposTab)
                            If(!Empty(FwSX3Util():GetFieldType(alltrim(_aCposTab[_nX]))))
                                If GetSx3Cache(alltrim(_aCposTab[_nX]), "X3_CONTEXT") <> "V"
                                    If Alltrim(_aCposTab[_nX]) $ _cCpoNJKSim

                                        _cTpCpo := GetSx3Cache(alltrim(_aCposTab[_nX]), "X3_TIPO")

                                        If Alltrim(_aCposTab[_nX]) == "NJK_FILIAL"
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), _cFilDest   , Nil     } )
                                        ElseIf Alltrim(_aCposTab[_nX]) == "NJK_CODROM" //Cí³digo de romaneiro no destino
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), _cRomEnt   , Nil      } )
                                        Else
                                            IF _cTpCpo == "D"
                                                If ValType(&('(_cAlias)->'+Alltrim(_aCposTab[_nX]) )) == "D"
                                                    aAdd(_aTempCpo, {   Alltrim(_aCposTab[_nX]), &('(_cAlias)->'+Alltrim(_aCposTab[_nX]) )   , Nil          } )
                                                Else
                                                    aAdd(_aTempCpo, {   Alltrim(_aCposTab[_nX]), Stod(&('(_cAlias)->'+Alltrim(_aCposTab[_nX]) ) )   , Nil          } )
                                                EndIf
                                            ElseIf _cTpCpo $ "CN" //Caracter ou numérico
                                                aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), &('(_cAlias)->'+Alltrim(_aCposTab[_nX]) )    , Nil      } )
                                            EndIf
                                        EndIf
                                    EndIf
                                EndIf
                            EndIf 
                        Next _nZ                                                
                        aAdd(_aGridNJK, aClone(_aTempCpo))
                        _aTempCpo := {}
                        (_cAlias)->(DbSkip())
                    EndDo

                EndIf





                /* INICIO Composiçío do array da Nk4 - _aGridNK4 */
                _cQuery := " SELECT * 
                _cQuery += " FROM "+RetSqlName("NK4")+" NK4 WHERE NK4.D_E_L_E_T_ = '' AND NK4.NK4_FILIAL = '"+xFilial("NK4")+"'  "
                _cQuery += " AND NK4.NK4_CODROM = '"+ _cCodRom +"'  "
                _cAlias := GetNextAlias()
                MpSysOpenQuery(_cQuery, _cAlias)
                _aTempCpo := {}
                If (_cAlias)->(!EOF())
                    _aCposTab := {}
                    _aCposTab := FWSX3Util():GetAllFields( "NK4" , .F. )
                    While (_cAlias)->(!EOF())
                        _aTempCpo := {}
                        For _nX := 1 to Len(_aCposTab)
                            If(!Empty(FwSX3Util():GetFieldType(alltrim(_aCposTab[_nX]))))
                                If GetSx3Cache(alltrim(_aCposTab[_nX]), "X3_CONTEXT") <> "V"
                                    _cTpCpo := GetSx3Cache(alltrim(_aCposTab[_nX]), "X3_TIPO")

                                    If Alltrim(_aCposTab[_nX]) == "NK4_FILIAL"
                                        aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), _cFilDest   , Nil     } )
                                    ElseIf Alltrim(_aCposTab[_nX]) == "NK4_CODROM" //Cí³digo de romaneiro no destino
                                        aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), _cRomEnt   , Nil      } )
                                    Else
                                        IF _cTpCpo == "D"
                                            If ValType(&('(_cAlias)->'+Alltrim(_aCposTab[_nX]) )) == "D"
                                                aAdd(_aTempCpo, {   Alltrim(_aCposTab[_nX]), &('(_cAlias)->'+Alltrim(_aCposTab[_nX]) )    , Nil          } )
                                            Else
                                                aAdd(_aTempCpo, {   Alltrim(_aCposTab[_nX]), Stod(&('(_cAlias)->'+Alltrim(_aCposTab[_nX]) ) )   , Nil          } )
                                            EndIf
                                        ElseIf _cTpCpo $ "CN" //Caracter ou numérico
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), &('(_cAlias)->'+Alltrim(_aCposTab[_nX]) )    , Nil      } )
                                        EndIf
                                    EndIf
                                EndIf
                            EndIf 
                        Next _nZ                                                
                        aAdd(_aGridNK4, aClone(_aTempCpo))
                        _aTempCpo := {}
                        (_cAlias)->(DbSkip())
                    EndDo

                EndIf





                /* INICIO Composiçío do array da NJM - _aGridNJM */
                _cQuery := " SELECT * 
                _cQuery += " FROM "+RetSqlName("NJM")+" NJM WHERE NJM.D_E_L_E_T_ = '' AND NJM.NJM_FILIAL = '"+xFilial("NJM")+"'  "
                _cQuery += " AND NJM.NJM_CODROM = '"+ _cCodRom +"'  "
                _cAlias := GetNextAlias()
                MpSysOpenQuery(_cQuery, _cAlias)
                _aTempCpo := {}
                If (_cAlias)->(!EOF())
                    _aCposTab := {}
                    _aCposTab := FWSX3Util():GetAllFields( "NJM" , .F. )
                    While (_cAlias)->(!EOF())
                        For _nX := 1 to Len(_aCposTab)
                            If(!Empty(FwSX3Util():GetFieldType(alltrim(_aCposTab[_nX]))))
                                If GetSx3Cache(alltrim(_aCposTab[_nX]), "X3_CONTEXT") <> "V"
                                    _cTpCpo := GetSx3Cache(alltrim(_aCposTab[_nX]), "X3_TIPO")
                                    If Alltrim(_aCposTab[_nX]) $ "NJM_FILIAL|NJM_FILORG" //Filial de origem Não pode ser enviada
                                        If Alltrim(_aCposTab[_nX]) $ "NJM_FILIAL"
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), _cFilDest   , Nil     } )
                                        EndIf
                                    ElseIf Alltrim(_aCposTab[_nX]) == "NJM_CODROM" //.and. 1 == 2  //Cí³digo de romaneiro no destino
                                        //aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), _cRomEnt   , Nil      } )

                                    ElseIf Alltrim(_aCposTab[_nX]) == "NJM_CODCTR" //Cí³digo de romaneiro no destino
                                        If !Empty(_cCrtEnt)
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), _cCrtEnt   , Nil      } )
                                        EndIf
                                    ElseIf Alltrim(_aCposTab[_nX]) == "NJM_TES" 
                                        aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), _cTesEnt   , Nil      } ) 

                                    ElseIf Alltrim(_aCposTab[_nX]) == "NJM_CODENT" 
                                        aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), _cCodEnt   , Nil      } ) 

                                    ElseIf Alltrim(_aCposTab[_nX]) == "NJM_LOJENT" 
                                        aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), _cLjEnt   , Nil      } )                                                                                 

                                    ElseIf Alltrim(_aCposTab[_nX]) == "NJM_LOCAL"    
                                        aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), _aRet[2]   , Nil      } )  

                                    ElseIf Alltrim(_aCposTab[_nX]) == "NJM_CHVNFE"    
                                        aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), _cChvNFE   , Nil      } )  

                                    ElseIf Alltrim(_aCposTab[_nX]) == "NJM_TPFORM"    
                                        aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), "2"   , Nil      } )  
                                    //Johnny pediu para adicoinar como Entrega 1-Entrega;2=Devolução
                                    ElseIf Alltrim(_aCposTab[_nX]) == "NJM_TRANS"
                                        aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), "1"   , Nil      } )  
                                    ElseIf !(  Alltrim(SubStr(_aCposTab[_nX],5,20))  $ _cCpoNJMnot) //Campos ignorados na execAuto o prefixo eu ignoro, NJJ_
                                        IF _cTpCpo == "D"
                                            If ValType(&('(_cAlias)->'+Alltrim(_aCposTab[_nX]) )) = "D"
                                                aAdd(_aTempCpo, {   Alltrim(_aCposTab[_nX]), &('(_cAlias)->'+Alltrim(_aCposTab[_nX]) )    , Nil          } )
                                            Else
                                                aAdd(_aTempCpo, {   Alltrim(_aCposTab[_nX]), Stod(&('(_cAlias)->'+Alltrim(_aCposTab[_nX]) ) )   , Nil          } )
                                            EndIf
                                        ElseIf _cTpCpo $ "CN" //Caracter ou numérico
                                            aAdd(_aTempCpo, { Alltrim(_aCposTab[_nX]), &('(_cAlias)->'+Alltrim(_aCposTab[_nX]) )    , Nil      } )
                                        EndIf
                                    EndIf
                                EndIf
                            EndIf 
                        Next _nZ
                        aAdd(_aGridNJM, aClone(_aTempCpo))
                        _aTempCpo := {}
                        (_cAlias)->(DbSkip())
                    EndDo
                EndIf


                If U_ACOGA250(  .T., _cFilDest, _aFldlNJJ, _aGridNJK, _aGridNK4, _aGridNJM , _cRomEnt )
                    _lRet := .T.
                    If _lTela
                        Aviso("ATENÇÃO","Romaneio incluí­do com sucesso na filial de destino!",{"OK"},2)
                    EndIf
                Else
                    _lRet := .F.
                    If _lTela
                        Aviso("ATENÇÃO","Não foi possí­vel a inclusío do romaneio na filial de destino!",{"OK"},2)
                    EndIf
                EndIf

            EndIf
        Else
            If _lTela .and. !Empty(_cProblema)
                Aviso("ATENÇÃO",_cProblema,{"REVISAR"},2,"Problemas na integração do Romaneio de entrada: ")
            EndIf        
        EndIf
    EndIf
EndIf

OpenSm0( cEmpAnt + _cFilArea )

RestArea(_aAreaSF2)
RestArea(_aAreaSA1)
RestArea(_aAreaSA2)
RestArea(_aAreaNJJ)
RestArea(_aAreaNJR)
RestArea(_aArea)

Return _lRet



User Function ACOGA250(  _lAut, _cFilial, _aFldlNJJ, _aGridNJK, _aGridNK4, _aGridNJM , __cCtrConf )

Local oModel := Nil
Local _lRet := .F.
Local _aItens := {}
Local _cFilBkp := _cFilial
Local aArea := GetArea()
Local aAreaNJJ := NJJ->(GetArea())
Local aAreaNJK := NJK->(GetArea())
Local _nX := 0

Default _aFldlNJJ := {} 
Default _aGridNJK   := {} 
Default _aGridNK4   := {}
Default _aGridNJM   := {}
Default _lAut := .F.
Default __cCtrConf := ""

Private lMsErroAuto := .F.
Private aRotina := {}

If cFilAnt <> _cFilial
    cFilAnt := _cFilial
    OpenSm0(cEmpAnt + cFilAnt)
EndIf

//Se veio como _lAut faí§o o preenchimento dos campos de forma padrío.
If !Empty(_aFldlNJJ) 
    aAdd(_aItens,{ "NJJUNICO", _aFldlNJJ[1]       })
EndIf

If !Empty(_aGridNJK)  .AND. 1 == 2 // Johhny pediu para Não mandar.
    aAdd(_aItens,{ "NJKUNICO", _aGridNJK      })
EndIf

If !Empty(_aGridNK4)  .and. 1 == 2 
    aAdd(_aItens,{ "NK4UNICO", {  { _aGridNK4 }  }    })
EndIf

If !Empty(_aGridNJM) 
    aAdd(_aItens,{ "NJMUNICO", { _aGridNJM[1] }   })
EndIf

If Len(_aItens) <> 0 

    Begin Transaction 
        lMsErroAuto := .F.
        oModel  := FwLoadModel ("OGA250")
        
        FWMVCRotAuto( oModel, "NJJUNICO" , MODEL_OPERATION_INSERT, _aItens)

        If lMsErroAuto
            MostraErro()
            _lRet := .F.
        Else
            NJJ->(dbGoTop())
            If NJJ->(dbSeek( xFilial("NJJ") + __cCtrConf ))
                ConfirmSX8()
            EndIf            
            ConOut("Romaneio Incluí­do com sucesso: "+NJJ->NJJ_FILIAL+" - "+NJJ->NJJ_CODROM )
            _lRet := .T.
            //_aGridAtu := aClone(_aGridNJK[1])
            //_aGridNJK := {}
            //_aGridNJK := aClone(_aGridAtu)
            If Len(_aGridNJK) > 0 
                _nNJK_FILIAL := aScan(_aGridNJK[1],{|x| Alltrim(x[1]) == "NJK_FILIAL"})
                _nNJK_CODROM := aScan(_aGridNJK[1],{|x| Alltrim(x[1]) == "NJK_CODROM"})
                _nNJK_ITEM   := aScan(_aGridNJK[1],{|x| Alltrim(x[1]) == "NJK_ITEM"})
                _nNJK_TPCLAS := aScan(_aGridNJK[1],{|x| Alltrim(x[1]) == "NJK_TPCLAS"})
                _nNJK_PERDES := aScan(_aGridNJK[1],{|x| Alltrim(x[1]) == "NJK_PERDES"})
                _nNJK_READES := aScan(_aGridNJK[1],{|x| Alltrim(x[1]) == "NJK_READES"})
                _nNJK_QTDDES := aScan(_aGridNJK[1],{|x| Alltrim(x[1]) == "NJK_QTDDES"})
                _nNJK_DESRES := aScan(_aGridNJK[1],{|x| Alltrim(x[1]) == "NJK_DESRES"})
                _nNJK_RESINF := aScan(_aGridNJK[1],{|x| Alltrim(x[1]) == "NJK_RESINF"})

                DbSelectArea("NJK")
                NJK->(DbSetOrder(1)) //NJK_FILIAL+NJK_CODROM+NJK_ITEM+NJK_TPCLAS   
                For _nX := 1 to Len(_aGridNJK)                                                                                                                    
                    NJK->(DbGoTop())
                    If NJK->(DbSeek(_aGridNJK[_nX][_nNJK_FILIAL][2]+_aGridNJK[_nX][_nNJK_CODROM][2]+_aGridNJK[_nX][_nNJK_ITEM][2]+_aGridNJK[_nX][_nNJK_TPCLAS][2]))
                        If NJK->(RecLock("NJK",.F.))
                                NJK->NJK_PERDES := _aGridNJK[_nX][_nNJK_PERDES][2]
                                NJK->NJK_READES := _aGridNJK[_nX][_nNJK_READES][2]
                                NJK->NJK_QTDDES := _aGridNJK[_nX][_nNJK_QTDDES][2]
                                NJK->NJK_DESRES := _aGridNJK[_nX][_nNJK_DESRES][2]
                                NJK->NJK_RESINF := _aGridNJK[_nX][_nNJK_RESINF][2]
                            NJK->(MsUnLock())
                        EndIf
                    EndIf
                Next _nX 
            EndIf
        EndIf  
    End Transaction
EndIf

cFilAnt := _cFilBkp
OpenSm0(cEmpAnt + cFilAnt)

RestArea(aArea)
RestArea(aAreaNJJ)
RestArea(aAreaNJK)

Return _lRet


//Funçío responsável por retornar o local na filial de destino
Static Function ACRETLOC(_cFilial, _cProduto)

Local _cRet := "01"

Return _cRet

//Funçío responsável por retornar a TES de destino
Static Function ACRETTES(_cFilial)

Local _cRet := "465"

Return _cRet





// Retorna dados para autorização da entrada
Static Function ACRCODAUT(_cFilial, _cContrato, _nQtde)
Local _cAlias := ""
Local _cQuery := ""
Local _aRet   := {"" , ""}

_cQuery += " SELECT TOP 1  *     "
_cQuery += " FROM 		"+RetSqlName("NJP")+" WITH(NOLOCK)    "
_cQuery += " WHERE 		D_E_L_E_T_ = ''     "
_cQuery += " 		AND NJP_CODCTR = '"+_cContrato+"'     "
_cQuery += " 		AND NJP_FILIAL = '"+_cFilial+"'     "
_cQuery += " 		AND NJP_TIPO = 'E'     "
_cQuery += " 		AND NJP_STATUS <> 'E'    "
_cQuery += " 		AND NJP_DATFIM <=  '"+DtoS(Date())+"'   "
_cQuery += " 		AND NJP_QTDINI - NJP_QTDFCO >= "+cValToChar(_nQtde)+"    "
_cQuery += " ORDER BY NJP_ITEM    "
_cAlias := GetNextAlias()

MpSysOpenQuery(_cQuery, _cAlias)

If (_cAlias)->(!EOF())
    _aRet := {(_cAlias)->NJP_ITEM, (_cAlias)->NJP_XLOCAL } 
EndIf
(_cAlias)->(DbCloseArea())

Return _aRet

// Retorna dados da autorização de saída
//_aRet := {(_cAlias)->NJP_XENAUT, (_cAlias)->NJP_XPSDES, (_cAlias)->NJP_XCRTDE } 
Static Function ACRAUTSAI(_cFilial, _cContrato, _cCodAut)
Local _cAlias := ""
Local _cQuery := ""
Local _aRet   := {"","",""} //Entrada automatica / peso sim ou não / Contrato entrada

_cQuery += " SELECT TOP 1  *     "
_cQuery += " FROM 		"+RetSqlName("NJP")+" WITH(NOLOCK)    "
_cQuery += " WHERE 		D_E_L_E_T_ = ''     "
_cQuery += " 		AND NJP_CODCTR = '"+_cContrato+"'     "
_cQuery += " 		AND NJP_FILIAL = '"+_cFilial+"'     "
_cQuery += " 		AND NJP_TIPO = 'S'  AND NJP_ITEM = '"+_cCodAut+"'    "

_cAlias := GetNextAlias()

MpSysOpenQuery(_cQuery, _cAlias)

If (_cAlias)->(!EOF())
    _aRet := {(_cAlias)->NJP_XENAUT, (_cAlias)->NJP_XPSDES, (_cAlias)->NJP_XCRTDE } 
EndIf
(_cAlias)->(DbCloseArea())

Return _aRet


User Function ACHVNJJ()

Local _cChvNfe := CHVNFE()
Local _cQuery := ""
Local _cAlias := ""

If Empty(_cChvNFE)
    Return 
EndIf
_cQuery := "SELECT R_E_C_N_O_ AS RECSF2 FROM "+RetSqlName("SF2")+" WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND F2_CHVNFE = '"+_cChvNFE+"' "
_cAlias := GetNextAlias()

MpSysOpenQuery(_cQuery, _cAlias)

If (_cAlias)->(!eof())
    U_ACEXOG250( (_cAlias)->RECSF2 , .T.  )
Else
    Aviso("AVISO","A chave informada Não existe!" , {"REVISAR"} , 2 )
EndIf

Return 
Static Function CHVNFE()                        
    Local oButton1
    Local oGet1
    Local oSay1
    Local cTexto    := SPACE(TamSX3("F1_CHVNFE")[1])
    Static oDlg
    

        DEFINE MSDIALOG oDlg TITLE "Chave da NF Referenciada" STYLE DS_MODALFRAME FROM 000, 000  TO 150, 400 COLORS 0, 16777215 PIXEL
        oDlg:lEscClose := .F.

            @ 007, 025 SAY oSay1 PROMPT "Informe a Chave da Nota Referenciada" SIZE 145, 009 OF oDlg COLORS 0, 16777215 PIXEL
            @ 025, 009 MSGET oGet1 VAR cTexto SIZE 183, 010 OF oDlg COLORS 0, 16777215 PIXEL
            @ 052, 078 BUTTON oButton1 PROMPT "Salvar" ACTION( oDlg:End()) SIZE 037, 012 OF oDlg PIXEL

        ACTIVATE MSDIALOG oDlg CENTERED

Return cTexto

 






// Função que realiza a validação da exclusão de item que tem NJJ por uma nota de saída.
User Function ACVEXCNJJ(_cChvNFE)

Local _cQuery := ""
Local _cAlias := ""
Local _lRet := .T.
Local _cAviso := " "

_cQuery := " SELECT	'Romaneio' AS OPER, NJJ.NJJ_FILIAL "+CRLF
_cQuery += " FROM		"+RetSqlName("NJJ")+" NJJ WITH(NOLOCK)
_cQuery += " WHERE		NJJ.D_E_L_E_T_ = '' 
_cQuery += " 		AND NJJ.NJJ_TIPO IN ('1','3','5','7','9','A') "+CRLF
_cQuery += " 		AND NJJ.NJJ_CHVNFE <> '' AND NJJ.NJJ_CHVNFE = '"+ _cChvNFE+"'       "+CRLF
_cQuery += " UNION  "+CRLF
_cQuery += " SELECT 'NFe' as OPER,	SF1.F1_FILIAL "+CRLF
_cQuery += " FROM		"+RetSqlName("SF1")+" SF1 WITH(NOLOCK)
_cQuery += " WHERE		SF1.D_E_L_E_T_ = '' 
_cQuery += " 		AND SF1.F1_CHVNFE <> '' AND SF1.F1_CHVNFE = '"+ _cChvNFE+"'       "+CRLF

_cAlias := GetNextAlias()
MpSysOpenQuery(_cQuery, _cAlias)

If (_cAlias)->(!eof())
    While (_cAlias)->(!eof())
        _cAviso += (_cAlias)->OPER+" lançado(a) na filial "+(_cAlias)->NJJ_FILIAL + CRLF
        _lRet := .F.
        (_cAlias)->(DbSkip())
    EndDo
    If !_lRet
        Aviso("ATENÇÃO", _cAviso, {"REVISAR"},2,"Exclua a NFe/Romaneio na origem e tente novamente:")
    EndIf

EndIf

(_cAlias)->(DbCloseArea())

Return _lRet






User Function ACALTOG250()
    Local lRet := .F.
    Local oModel := Nil
     
    oModel  := FWLoadModel('OGA250')   
    oModel:SetOperation(MODEL_OPERATION_UPDATE) //INCLUSÃO
    oModel:Activate()
     
    //### Modelos de dados: NJJUNICO, NJKUNICO, NK4UNICO, NJMUNICO ###
    //Setando valores nos campos
    oModel:GetModel('NJJUNICO'):SetValue('NJJ_TIPENT', '0') //COM PESAGEM
    oModel:GetModel('NJJUNICO'):SetValue('NJJ_TIPO', '4') //SAIDA POR VENDA
    oModel:GetModel('NJJUNICO'):SetValue('NJJ_CODCTR', '000116') //NUMERO DO CONTRATO
    oModel:GetModel('NJJUNICO'):SetValue('NJJ_TPFORM', '1')
    oModel:GetModel('NJJUNICO'):SetValue('NJJ_LOCAL', '01')
    oModel:GetModel('NJJUNICO'):SetValue('NJJ_TABELA', '000001')
    oModel:GetModel('NJJUNICO'):SetValue('NJJ_PESO1', 1000)
    oModel:GetModel('NJJUNICO'):SetValue('NJJ_PESO2', 2000)
    oModel:GetModel('NJJUNICO'):SetValue('NJJ_PSSUBT', 1000)
  
    //modelo de dados da aba Classificação(Grid)  
    oModel:GetModel('NJKUNICO'):GoLine( 1 ) //posicionando na linha
    oModel:GetModel('NJKUNICO'):SetValue('NJK_PERDES', 1) 
    oModel:GetModel('NJKUNICO'):GoLine( 2 ) //posicionando na linha           
    oModel:GetModel('NJKUNICO'):SetValue('NJK_PERDES', 0.8) 
 
    //modelo de dados da aba Comercialização(Grid) 
    oModel:GetModel( "NJMUNICO" ):GoLine( 1 ) //posicionando na linha          
    oModel:GetModel('NJMUNICO'):SetValue('NJM_ITEROM', '01')   
 
    If oModel:VldData() //valida os dados
        oModel:CommitData() //realiza a gravação do registro
        MsgInfo("Registro incluído com sucesso")   
        lRet := .T.
    Else   
        VarInfo("",oModel:GetErrorMessage())
        MsgAlert("Erro ao incluir o registro")
    EndIf 
 
return lRet
