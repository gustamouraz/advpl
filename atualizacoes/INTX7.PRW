#Include "totvs.ch"

/* INTEGRAÇÃO COMBUSTÍVEIS  VIA API 202602 - ANDRÉ CLARO
@Autor:         André Claro
@Data:          06/02/2026
@Descrição: API responsável por recuperar os dados de NF de abastecimento e gravar na tabela ZHA-Cabeçalho/ZHB-Itens
*/



User Function INTX7()

	oProcess := MsNewProcess():New({  || ACEXECUTE(@oProcess)},"Importando registros via API...","Aguarde por favor!!!",.T.)
	oProcess:Activate()

Return 

Static Function ACEXECUTE(oProcess)
    Local oRetAPI := JsonObject():New() 
    Local cDtIni := '2026-01-01' //Substituir por Pergunte
    Local cDtFim := '2026-01-31' //Substituir por Pergunte
    Local nX, nY
    Local cErros := ''
    Local _cFlag := "N" //Começa como não integrado
    Local lOk := .F.
    Local dData      := Date()
    Local cHora      := Time()
    Local _cNumSeq := ""
    Local _cFilZHA := _cFilSA2 := _cFilCTT :=  ''
    Local _cErro := ""
    Local _cFornece := ""
    Local _cLoja := ""
    Local _cProduto := ""
    Local _cQuery := ""
    Local _cAlias := ""   
    Local _aRet := {}
    Local _aPergs := {} 
    Local _cUniErro := ""
    Local _cNaturez := ""
    Local _cLocal := ""
    Local _cTes := ""
    Local _cCondPag := ""
    Local _nCount := 0
    Local _cTpFrete := ""
    Local _nBaseICMS := 0 
    Local _nBasePIS := 0 
    Local _nBaseCOF := 0 
    Local _nAliqICMS := 0 
    Local _nAliqPIS := 0 
    Local _nAliqCOF := 0 
    Local _nVlrICMS := 0 
    Local _nVlrPIS := 0 
    Local _nVlrCOF := 0 
    Local _cCSTICMS := ""
    Local _cCSTPIS := ""
    Local _cCSTCOF := "" 

    Local _nBaseIPI := 0
    Local _nAliqIPI := 0
    Local _nVlrIPI := 0
    Local _cCSTIPI  := ""
    Local _nItem := 0 
    Local _nValDesc := 0  


    Private lEnv        := .F.
    DBSELECTAREA("ZGC")
    aadd( _aPergs , {1,"Data Inicio"  		,Date()-30, ,'.T.',,'.T.', 50 ,.T. } )
    aadd( _aPergs , {1,"Data Fim"  		    ,Date(), ,'.T.',,'.T.', 50 ,.T. } )
    //aadd( _aPergs , {1,"Chave NFe?"  		,Space(44), ,'.T.',,'.T.', 50 ,.T. } )

    If	ParamBox(_aPergs , "Importação de NFe Combustivel", _aRet,,,,700,1000, /*oMainDlg*/,,.F.,.F.)
        If MV_PAR02 < MV_PAR01
            Aviso("ATENÇÃO","Data fim não pode ser menor que a data inicio",{"REVISAR"},2)
            Return
        ElseIf (MV_PAR02 - MV_PAR01) > 30
            Aviso("ATENÇÃO","O período entre as datas não pode ser maior que 30 dias",{"REVISAR"},2)
            Return 
        Else
            _cTemp := DtoS(MV_PAR01)
            _cTemp := SubStr(_cTemp,1,4)+"-"+SubStr(_cTemp,5,2)+"-"+SubStr(_cTemp,7,2)
            cDtIni :=  _cTemp

            _cTemp := DtoS(MV_PAR02)
            _cTemp := SubStr(_cTemp,1,4)+"-"+SubStr(_cTemp,5,2)+"-"+SubStr(_cTemp,7,2)            
            cDtFim := _cTemp
        EndIf
    Else
        Aviso("ATENÇÃO","Cancelado pelo usuário.",{"REVISAR"},2)
        Return 
    EndIf


    _cFilZHA := xFilial("ZHA")
    _cFilSA2 := xFilial("SA2")
    _cFilCTT := xFilial("CTT")

    oRetAPI   := GETMOV(cDtIni, cDtFim)
    DbSelectArea("ZHB")
    DbSelectArea("ZHA")
    DbSelectArea("ZHC")
    ZHC->(DbSetOrder(2)) // ZHC_FILIAL+ZHC_FORNEC+ZHC_LOJA+ZHC_PRDFOR

    _nCount := Len(oRetAPI)
    oProcess:SetRegua1( 0 )
    oProcess:SetRegua2(_nCount)

    oProcess:IncRegua1( "Processando API Combustiveis " )
    

    For nX := 1 to Len(oRetAPI)

        oProcess:IncRegua2("Processando ("+ cValToChar( Round(nX/_nCount*100,2)) +"%)" )

        _cUniErro := ""
        lOk := .F.

        If oRetAPI[nX]["status"]= 'Processado'
            lOk := .T.
        ELSE 
            cErros += 'NF com Status: ' + oRetAPI[nX]["status"]
        ENDIF

        If valtype(oRetAPI[nX]["chave_nf"]) <> 'C' .and. lOk
            lOk := .F.
            cErros += 'Chave null Cod Pre Venda: ' + CVALTOCHAR(oRetAPI[nX]["cod_prevenda"]) + 'Cod Fatura: ' + CVALTOCHAR(oRetAPI[nX]["cod_fatura"]) + CRLF
        ENDIF

        ZHA->(DbSetOrder(2)) //chave de nfe
        ZHA->(DbGoTop())

        If lOk
            //Inicia ZHA
            If !ZHA->(DbSeek(oRetAPI[nX]["chave_nf"])) 
                _cFlag := "N"//Não integrado
                ZHA->(DbSetOrder(3)) //filial + numseq
                _cNumSeq := ""
                While .T.
                    _cNumSeq := ""
                    _cNumSeq := GetSXENum("ZHA","ZHA_NUMSEQ")
                    ZHA->(dbGoTop())
                    If ZHA->(DbSeek(_cFilZHA + _cNumSeq ) )
                        ConfirmSX8()
                    Else
                        Exit
                    EndIf
                EndDo 
            
                ZHA->(DbSetOrder(2))
                ZHA->(DbGoTop())

                _cFilOri := ""
                _cFilOri := Alltrim(U_ACNPJSM0(CVALTOCHAR(oRetAPI[nX]["cnpj_faturamento"]) , cValToChar(oRetAPI[nX]["ie_faturamento"] )))
                If _cFilOri <> cFilAnt
                    cFilAnt := _cFilOri
                    OpenSM0(cEmpAnt + cFilant)
                EndIf

                Begin Transaction 
                    _cFornece := ""
                    _cLoja := ""
                    _cProduto := ""
                    _cPlaca := ""
                    _cCgc := ""
                    RecLock("ZHA",.T.)
                        ZHA->ZHA_NUMSEQ      := _cNumSeq  
                        ZHA->ZHA_JSON		:= oRetAPI:toJson()		
                        ZHA->ZHA_FILORI      := _cFilOri // RETFIL(CVALTOCHAR(oRetAPI[nX]["cnpj_faturamento"]))				
                        ZHA->ZHA_DOC 		:= Alltrim(CVALTOCHAR(oRetAPI[nX]["nnf"]))
                        ZHA->ZHA_CODIGO		:= CVALTOCHAR(oRetAPI[nX]["codigo"])
                        ZHA->ZHA_PREVEN		:= CVALTOCHAR(oRetAPI[nX]["cod_prevenda"])
                        ZHA->ZHA_FATURA		:= CVALTOCHAR(oRetAPI[nX]["cod_fatura"])
                        ZHA->ZHA_NNF			:= CVALTOCHAR(oRetAPI[nX]["nnf"])
                        ZHA->ZHA_CODNFE		:= CVALTOCHAR(oRetAPI[nX]["cod_nfe"])
                        ZHA->ZHA_SERIE		:= Alltrim(CVALTOCHAR(oRetAPI[nX]["serie_nf"]))
                        ZHA->ZHA_CHVNFE		:= Alltrim(CVALTOCHAR(oRetAPI[nX]["chave_nf"]))
                        ZHA->ZHA_CFOP		:= CVALTOCHAR(oRetAPI[nX]["cfop_nf"])
                        ZHA->ZHA_ESPECI		:= Alltrim(CVALTOCHAR(oRetAPI[nX]["especie_nf"]))
                        ZHA->ZHA_NREDUZ		:= Alltrim(CVALTOCHAR(oRetAPI[nX]["fornecedor"]["loja"]))
                        _cCgc			:= Alltrim(CVALTOCHAR(oRetAPI[nX]["fornecedor"]["cnpj_loja"]))
                        ZHA->ZHA_CGC    := _cCgc

                        _cTpFrete := Alltrim(CVALTOCHAR(oRetAPI[nX]["tipo_frete"]))

                        Do Case
                            Case _cTpFrete == "0"
                                _cTpFrete := "C"
                            Case _cTpFrete == "1"
                                _cTpFrete := "F"
                            Case _cTpFrete == "2"
                                _cTpFrete := "T"
                            Case _cTpFrete == "3"
                                _cTpFrete := "R"
                            Case _cTpFrete == "4"
                                _cTpFrete := "D"
                            Case _cTpFrete == "9"
                                _cTpFrete := "S"                                                                                                
                            OtherWise
                                _cTpFrete := "S"
                        EndCase 

                        ZHA->ZHA_TPFRET := _cTpFrete

                        DbSelectArea("SA2")
                        SA2->(DbSetOrder(3))
                        IF (DbSeek( _cFilSA2 + _cCgc     ))
                            ZHA->ZHA_FORNEC := SA2->A2_COD
                            ZHA->ZHA_LOJA   := SA2->A2_LOJA

                            _cFornece   := SA2->A2_COD
                            _cLoja      := SA2->A2_LOJA
                        ELSE 
                            cErros += 'CNPJ: ' + CVALTOCHAR(oRetAPI[nX]["fornecedor"]["cnpj_loja"]) + ' nao Encontrado' + CRLF
                            _cUniErro += 'CNPJ: ' + CVALTOCHAR(oRetAPI[nX]["fornecedor"]["cnpj_loja"]) + ' nao Encontrado' + CRLF
                            _cFlag := "P"//Problema
                        ENDIF
                        SA2->(DbCloseArea())

                        ZHA->ZHA_INSCRI		:= CVALTOCHAR(oRetAPI[nX]["fornecedor"]["ie"])
                        ZHA->ZHA_MUN			:= CVALTOCHAR(oRetAPI[nX]["fornecedor"]["Cidade"])
                        ZHA->ZHA_UF			:= CVALTOCHAR(oRetAPI[nX]["fornecedor"]["UF"])
                        ZHA->ZHA_CGCFAT		:= CVALTOCHAR(oRetAPI[nX]["cnpj_faturamento"])
                        _cPlaca         := CVALTOCHAR(oRetAPI[nX]["placa"])
                        ZHA->ZHA_PLACA		:= _cPlaca

                        _cCCusto := CVALTOCHAR(oRetAPI[nX]["centro_custo"])
                        If Empty(_cCCusto)
                            cErros += "Centro de Custo não informado"
                            _cUniErro += "Centro de Custo não informado"
                            _cFlag := "P"//Problemas
                        Else
                            CTT->(DbGoTop())
                            If CTT->(DbSeek(_cFilCTT + _cCCusto))
                                If CTT->CTT_BLOQ == "1"
                                    cErros += "Centro de Custo "+_cCCusto+" bloqueado na CTT "
                                    _cUniErro += "Centro de Custo "+_cCCusto+" bloqueado na CTT "
                                    _cFlag := "P"//Problemas  
                                Else
                                    ZHA->ZHA_CCUSTO		:= CVALTOCHAR(oRetAPI[nX]["centro_custo"])
                                EndIf
                            Else
                                cErros += "Centro de Custo "+_cCCusto+" não Existe "
                                _cUniErro += "Centro de Custo "+_cCCusto+" não Existe "
                                _cFlag := "P"//Problemas                                
                            EndIf
                        EndIf

                        ZHA->ZHA_CGCMOT		:= CVALTOCHAR(oRetAPI[nX]["cnpj_mot"])
                        ZHA->ZHA_KMINFO		:= oRetAPI[nX]["km_informado"]
                        ZHA->ZHA_ABAINT		:= oRetAPI[nX]["abastecimento_interno"]

                        cEmissao        := StrTran(SubStr(oRetAPI[nX]["data_movimento"], 1, 10), "-", "")  
                        ZHA->ZHA_EMISSA		:= StoD(cEmissao)

                        cAtualiza       := StrTran(SubStr(oRetAPI[nX]["data_atualizacao"], 1, 10), "-", "")
                        ZHA->ZHA_DTAATL		:= StoD(cAtualiza)
                    ZHA->(MsUnlock())

                    //Inicia ZHB
                    For nY := 1 to len(oRetAPI[nX]["itens"])
                        
                        _cProduto := ""
                        _cTes := "" 
                        _cCondPag := ""
                        _cNaturez := ""
                        _cLocal := ""

                        If Valtype(oRetAPI[nX]["itens"][nY]["cod_produto"]) == "C"
                            _cProduto := Alltrim(oRetAPI[nX]["itens"][nY]["cod_produto"])
                        ElseIf Valtype(oRetAPI[nX]["itens"][nY]["cod_produto"]) == "N"
                            _cProduto := Alltrim(cValToChar(oRetAPI[nX]["itens"][nY]["cod_produto"]))
                        EndIf
                        ZHC->(DbGoTop())
                        If ZHC->(DbSeek(xFilial("ZHC") + _cFornece + _cLoja + _cProduto )) .and. !Empty(_cProduto)
                            _cProduto := ZHC->ZHC_PRODUT
                            If GetAdvFVal("CTD","CTD_ZESTSN",xFilial("CTD") + _cPlaca, 1, "" ) == "S"
                                _cTes := ZHC->ZHC_TEEST
                            Else
                                _cTes := ZHC->ZHC_TE
                            EndIf
                            
                            _cCondPag := ZHC->ZHC_CONDPG
                            _cNaturez := ZHC->ZHC_NATURE
                            _cLocal := ZHC->ZHC_LOCAL
                        Else
                            cErros += "Forn/Lj/Produto não existem na ZHC "+ _cFornece +"/"+ _cLoja +"-"+ _cProduto
                            _cUniErro += "Forn/Lj/Produto não existem na ZHC "+ _cFornece +"/"+ _cLoja +"-"+ _cProduto
                            _cFlag := "P"//Problemas
                        EndIf
                        
                        ZHB->(DbSetOrder(1))
                        _cItem :=  StrZero( nY , 4 ) //Right("000"+Alltrim(oRetAPI[nX]["itens"][nY]["seq_nota"]),4)

                        _nBaseICMS := 0 
                        _nBasePIS := 0 
                        _nBaseCOF := 0 
                        _nBaseIPI := 0

                        _nAliqICMS := 0 
                        _nAliqPIS := 0 
                        _nAliqCOF := 0
                        _nAliqIPI := 0  

                        _nVlrICMS := 0 
                        _nVlrPIS := 0 
                        _nVlrCOF := 0 
                        _nVlrIPI := 0

                        _cCSTICMS := ""
                        _cCSTPIS := ""
                        _cCSTCOF := "" 
                        _cCSTIPI := ""

                        If oRetAPI[nX]:hasProperty("itensXML")
                            If oRetAPI[nX]["itensXML"]:hasProperty(cValToChar(nY))
                                If ValType(oRetAPI[nX]["itensXML"][cValToChar(nY)]) == "J"
                                    If oRetAPI[nX]["itensXML"][cValToChar(nY)]:hasProperty("impostos") 
                                        If ValType(oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]) == "J"
                                            _nBaseICMS := Val( StrTran(  oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["ICMS"]["vl_base"],",","." ) )
                                            _nBasePIS := Val( StrTran( oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["PIS"]["vl_base"],",","." ) )
                                            _nBaseCOF := Val( StrTran( oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["COFINS"]["vl_base"],",","." ) )

                                            _nBaseIPI := Val( StrTran( oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["IPI"]["vl_base"],",","." ) )
                                            
                                            
                                            _nAliqICMS :=  Val( StrTran( oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["ICMS"]["aliquota"],",","." ) )
                                            _nAliqPIS :=  Val( StrTran( oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["PIS"]["aliquota"] ,",","." ) )
                                            _nAliqCOF :=  Val( StrTran( oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["COFINS"]["aliquota"] ,",","." ) )

                                            _nAliqIPI :=  Val( StrTran( oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["IPI"]["aliquota"] ,",","." ) )
                
                                            _nVlrICMS := Val( StrTran( oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["ICMS"]["valor"],",","." ) ) 
                                            _nVlrPIS := Val( StrTran( oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["PIS"]["valor"] ,",","." ) )
                                            _nVlrCOF := Val( StrTran( oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["COFINS"]["valor"] ,",","." ) )

                                            _nVlrIPI := Val( StrTran( oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["IPI"]["valor"] ,",","." ) )

                                            _cCSTICMS := oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["ICMS"]["CST"]
                                            _cCSTPIS := oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["PIS"]["CST"]
                                            _cCSTCOF := oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["COFINS"]["CST"]
                                            _cCSTIPI := oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["IPI"]["CST"]
                                        EndIf
                                    EndIf
                                Endif
                            EndIf
                        EndIf

                        RecLock("ZHB",.T.)
                            ZHB->ZHB_NUMSEQ := _cNumSeq
                            ZHB->ZHB_QUANT  := VAL(oRetAPI[nX]["itens"][nY]["qtde"])
                            ZHB->ZHB_VLUNIT := oRetAPI[nX]["itens"][nY]["vl_nota_unit_liquido"]
                            ZHB->ZHB_VLRBRT := oRetAPI[nX]["itens"][nY]["vl_nota_bruto"]
                            ZHB->ZHB_VUNBRT := VAL(oRetAPI[nX]["itens"][nY]["vl_nota_unit_bruto"])

                            If Empty(oRetAPI[nX]["itens"][nY]["vl_desconto_x7"])
                                _nValDesc := 0 
                            Else
                                _nValDesc := Val(oRetAPI[nX]["itens"][nY]["vl_desconto_x7"])
                            EndIf

                            ZHB->ZHB_VLRDES := _nValDesc  //add 18.08.2026 andre claro
                            ZHB->ZHB_CODPRD := _cProduto // Produto que veio da ZHC -- oRetAPI[nX]["itens"][nY]["cod_produto"]
                            ZHB->ZHB_TES     := _cTes
                            ZHB->ZHB_LOCAL   := _cLocal
                            ZHB->ZHB_ITEM   := _cItem
                            ZHB->ZHB_ITDESC := oRetAPI[nX]["itens"][nY]["produto"] //Descrição
                            ZHB->ZHB_BICMS := _nBaseICMS
                            ZHB->ZHB_PICMS := _nAliqICMS
                            ZHB->ZHB_VICMS := _nVlrICMS
                            ZHB->ZHB_BPIS  := _nBasePIS
                            ZHB->ZHB_PPIS  := _nAliqPIS
                            ZHB->ZHB_VPIS  := _nVlrPIS
                            ZHB->ZHB_BCOF  := _nBaseCOF
                            ZHB->ZHB_PCOF  := _nAliqCOF
                            ZHB->ZHB_VCOF  := _nVlrCOF
                            
                            ZHB->ZHB_BIPI  := _nBaseIPI
                            ZHB->ZHB_PIPI  := _nAliqIPI
                            ZHB->ZHB_VIPI  := _nVlrIPI
                            
                            ZHB->ZHB_CSTICMS  := _cCSTICMS
                            ZHB->ZHB_CSTPIS  := _cCSTPIS
                            ZHB->ZHB_CSTCOF  := _cCSTCOF
                            ZHB->ZHB_CSTIPI := _cCSTIPI
                        ZHB->(MsUnlock())
                Next nY

                End Transaction
                DbSelectArea("ZHA")
                ZHA->(DbSetOrder(3)) // FILIAL + NUMSEQ
                ZHA->(dbGoTop())
                If ZHA->(DbSeek(_cFilZHA + _cNumSeq ) )
                    If  ZHA->(RecLock("ZHA",.F.))
                            ZHA->ZHA_INTEGR := _cFlag //   "P"-Problema/ "N"-Não integrada a NF 
                            ZHA->ZHA_DETERR := _cUniErro

                            ZHA->ZHA_NATURE := _cNaturez
                            ZHA->ZHA_CONDPG := _cCondPag
                        ZHA->(MsUnLock())
                    Endif

                    ConfirmSX8()
                EndIf


            else
                If ZHA->ZHA_INTEGR == "S"
                    cErros += 'CHAVE: ' + CVALTOCHAR(oRetAPI[nX]["chave_nf"]) + ' ja integrado' + CRLF
                Else
                    _cFlag := "N"//Não integrado
                    _cNumSeq := ZHA->ZHA_NUMSEQ
                    _cChvZHA := ZHA->(ZHA->ZHA_FILIAL + ZHA_NUMSEQ )

                    _cFilOri := ""
                    _cFilOri := Alltrim(   U_ACNPJSM0(CVALTOCHAR(oRetAPI[nX]["cnpj_faturamento"]) , cValToChar(oRetAPI[nX]["ie_faturamento"] )  ))
                    If _cFilOri <> cFilAnt
                        cFilAnt := _cFilOri
                        OpenSM0(cEmpAnt + cFilant)
                    EndIf

                    Begin Transaction 
                        _cFornece := ""
                        _cLoja := ""
                        _cProduto := ""
                        _cPlaca := ""
                        _cCgc := ""
                        ZHA->(RecLock("ZHA",.F.))
                            ZHA->ZHA_JSON		:= oRetAPI:toJson()		
                            ZHA->ZHA_FILORI      := _cFilOri // RETFIL(CVALTOCHAR(oRetAPI[nX]["cnpj_faturamento"]))				
                            ZHA->ZHA_DOC 		:= Alltrim(CVALTOCHAR(oRetAPI[nX]["nnf"]))
                            ZHA->ZHA_CODIGO		:= CVALTOCHAR(oRetAPI[nX]["codigo"])
                            ZHA->ZHA_PREVEN		:= CVALTOCHAR(oRetAPI[nX]["cod_prevenda"])
                            ZHA->ZHA_FATURA		:= CVALTOCHAR(oRetAPI[nX]["cod_fatura"])
                            ZHA->ZHA_NNF			:= CVALTOCHAR(oRetAPI[nX]["nnf"])
                            ZHA->ZHA_CODNFE		:= CVALTOCHAR(oRetAPI[nX]["cod_nfe"])
                            ZHA->ZHA_SERIE		:= Alltrim(CVALTOCHAR(oRetAPI[nX]["serie_nf"]))
                            ZHA->ZHA_CHVNFE		:= Alltrim(CVALTOCHAR(oRetAPI[nX]["chave_nf"]))
                            ZHA->ZHA_CFOP		:= CVALTOCHAR(oRetAPI[nX]["cfop_nf"])
                            ZHA->ZHA_ESPECI		:= Alltrim(CVALTOCHAR(oRetAPI[nX]["especie_nf"]))
                            ZHA->ZHA_NREDUZ		:= Alltrim(CVALTOCHAR(oRetAPI[nX]["fornecedor"]["loja"]))


                            _cTpFrete := Alltrim(CVALTOCHAR(oRetAPI[nX]["tipo_frete"]))

                            Do Case
                                Case _cTpFrete == "0"
                                    _cTpFrete := "C"
                                Case _cTpFrete == "1"
                                    _cTpFrete := "F"
                                Case _cTpFrete == "2"
                                    _cTpFrete := "T"
                                Case _cTpFrete == "3"
                                    _cTpFrete := "R"
                                Case _cTpFrete == "4"
                                    _cTpFrete := "D"
                                Case _cTpFrete == "9"
                                    _cTpFrete := "S"
                                OtherWise
                                    _cTpFrete := "S"
                            EndCase 

                            _cCgc			:= Alltrim(CVALTOCHAR(oRetAPI[nX]["fornecedor"]["cnpj_loja"]))
                            ZHA->ZHA_CGC := _cCgc
                            DbSelectArea("SA2")
                            SA2->(DbSetOrder(3))
                            IF (DbSeek( _cFilSA2 +  _cCgc ))
                                ZHA->ZHA_FORNEC := SA2->A2_COD
                                ZHA->ZHA_LOJA   := SA2->A2_LOJA

                                _cFornece   := SA2->A2_COD
                                _cLoja      := SA2->A2_LOJA
                            ELSE 
                                cErros += 'CNPJ: ' + CVALTOCHAR(oRetAPI[nX]["fornecedor"]["cnpj_loja"]) + ' nao Encontrado' + CRLF
                                _cUniErro += 'CNPJ: ' + CVALTOCHAR(oRetAPI[nX]["fornecedor"]["cnpj_loja"]) + ' nao Encontrado' + CRLF
                                _cFlag := "P"//Problema
                            ENDIF
                            SA2->(DbCloseArea())

                            ZHA->ZHA_INSCRI		:= CVALTOCHAR(oRetAPI[nX]["fornecedor"]["ie"])
                            ZHA->ZHA_MUN			:= CVALTOCHAR(oRetAPI[nX]["fornecedor"]["Cidade"])
                            ZHA->ZHA_UF			:= CVALTOCHAR(oRetAPI[nX]["fornecedor"]["UF"])
                            ZHA->ZHA_CGCFAT		:= CVALTOCHAR(oRetAPI[nX]["cnpj_faturamento"])
                            _cPlaca         := CVALTOCHAR(oRetAPI[nX]["placa"])
                            ZHA->ZHA_PLACA		:= _cPlaca

                            _cCCusto := CVALTOCHAR(oRetAPI[nX]["centro_custo"])
                            If Empty(_cCCusto)
                                cErros += "Centro de Custo não informado"
                                _cUniErro += "Centro de Custo não informado"
                                _cFlag := "P"//Problemas
                            Else
                                CTT->(DbGoTop())
                                If CTT->(DbSeek(_cFilCTT + _cCCusto))
                                    If CTT->CTT_BLOQ == "1"
                                        cErros += "Centro de Custo "+_cCCusto+" bloqueado na CTT "
                                        _cUniErro += "Centro de Custo "+_cCCusto+" bloqueado na CTT "
                                        _cFlag := "P"//Problemas  
                                    Else
                                        ZHA->ZHA_CCUSTO		:= CVALTOCHAR(oRetAPI[nX]["centro_custo"])
                                    EndIf
                                Else
                                    cErros += "Centro de Custo "+_cCCusto+" não Existe "
                                    _cUniErro += "Centro de Custo "+_cCCusto+" não Existe "
                                    _cFlag := "P"//Problemas                                
                                EndIf
                            EndIf
                            
                            ZHA->ZHA_CGCMOT		:= CVALTOCHAR(oRetAPI[nX]["cnpj_mot"])
                            ZHA->ZHA_KMINFO		:= oRetAPI[nX]["km_informado"]
                            ZHA->ZHA_ABAINT		:= oRetAPI[nX]["abastecimento_interno"]

                            cEmissao        := StrTran(SubStr(oRetAPI[nX]["data_movimento"], 1, 10), "-", "")  
                            ZHA->ZHA_EMISSA		:= StoD(cEmissao)

                            cAtualiza       := StrTran(SubStr(oRetAPI[nX]["data_atualizacao"], 1, 10), "-", "")
                            ZHA->ZHA_DTAATL		:= StoD(cAtualiza)
                        ZHA->(MsUnlock())

                        //Inicia ZHB
                        For nY := 1 to len(oRetAPI[nX]["itens"])
                            
                            _cProduto := ""
                            _cTes := ""
                            _cCondPag := ""
                            _cNaturez := ""
                            _cLocal := ""

                            If Valtype(oRetAPI[nX]["itens"][nY]["cod_produto"]) == "C"
                                _cProduto := Alltrim(oRetAPI[nX]["itens"][nY]["cod_produto"])
                            ElseIf Valtype(oRetAPI[nX]["itens"][nY]["cod_produto"]) == "N"
                                _cProduto := Alltrim(cValToChar(oRetAPI[nX]["itens"][nY]["cod_produto"]))
                            EndIf

                            ZHC->(DbGoTop())
                            If ZHC->(DbSeek(xFilial("ZHC") + _cFornece + _cLoja + _cProduto )) .and. !Empty(_cProduto)
                                _cProduto := ZHC->ZHC_PRODUT
                                If GetAdvFVal("CTD","CTD_ZESTSN",xFilial("CTD") + _cPlaca, 1, "" ) == "S"
                                    _cTes := ZHC->ZHC_TEEST
                                Else
                                    _cTes := ZHC->ZHC_TE
                                EndIf
                                
                                _cCondPag := ZHC->ZHC_CONDPG
                                _cNaturez := ZHC->ZHC_NATURE
                                _cLocal := ZHC->ZHC_LOCAL
                            Else
                                cErros += "Forn/Lj/Produto não existem na ZHC "+ _cFornece +"/"+ _cLoja +"-"+ _cProduto
                                _cUniErro += "Forn/Lj/Produto não existem na ZHC "+ _cFornece +"/"+ _cLoja +"-"+ _cProduto
                                _cFlag := "P"//Problemas
                            EndIf
                            
                            ZHB->(DbSetOrder(1))
                            ZHB->(DbGoTop())
                            _cItem :=  StrZero( nY , 4 )   // Right("000"+Alltrim(oRetAPI[nX]["itens"][nY]["seq_nota"]),4)
                            _nBaseICMS := 0 
                            _nBasePIS := 0 
                            _nBaseCOF := 0 
                            _nBaseIPI := 0 

                            _nAliqICMS := 0 
                            _nAliqPIS := 0 
                            _nAliqCOF := 0 
                            _nAliqIPI := 0 

                            _nVlrICMS := 0 
                            _nVlrPIS := 0 
                            _nVlrCOF := 0 
                            _nVlrIPI := 0 

                            _cCSTICMS := ""
                            _cCSTPIS := ""
                            _cCSTCOF := "" 
                            _cCSTIPI := "" 
                            If oRetAPI[nX]:hasProperty("itensXML")
                                If oRetAPI[nX]["itensXML"]:hasProperty(cValToChar(nY))
                                    If ValType(oRetAPI[nX]["itensXML"][cValToChar(nY)]) == "J"
                                        If oRetAPI[nX]["itensXML"][cValToChar(nY)]:hasProperty("impostos") 
                                            If ValType(oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]) == "J"
                                                _nBaseICMS := Val( StrTran(   oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["ICMS"]["vl_base"] ,",","." ) )
                                                _nBasePIS := Val( StrTran(   oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["PIS"]["vl_base"],",","." ) )
                                                _nBaseCOF := Val( StrTran(   oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["COFINS"]["vl_base"],",","." ) )
                                                _nAliqICMS :=  Val( StrTran(   oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["ICMS"]["aliquota"],",","." ) )
                                                _nAliqPIS :=  Val( StrTran(   oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["PIS"]["aliquota"],",","." ) )
                                                _nAliqCOF :=  Val( StrTran(   oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["COFINS"]["aliquota"],",","." ) )
                    
                                                _nVlrICMS := Val( StrTran(   oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["ICMS"]["valor"],",","." ) )
                                                _nVlrPIS := Val( StrTran(   oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["PIS"]["valor"] ,",","." ) )
                                                _nVlrCOF := Val( StrTran(   oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["COFINS"]["valor"] ,",","." ) )

                                                _cCSTICMS := oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["ICMS"]["CST"]
                                                _cCSTPIS := oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["PIS"]["CST"]
                                                _cCSTCOF := oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["COFINS"]["CST"]

                                                _nBaseIPI := Val( StrTran(   oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["IPI"]["vl_base"],",","." ) )
                                                _nAliqIPI :=  Val( StrTran(   oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["IPI"]["aliquota"],",","." ) )
                                                _nVlrIPI := Val( StrTran(   oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["IPI"]["valor"] ,",","." ) )
                                                _cCSTIPI := oRetAPI[nX]["itensXML"][cValToChar(nY)]["impostos"]["IPI"]["CST"]
                                            EndIf
                                        EndIf
                                    Endif
                                EndIf
                            EndIf
                            If ZHB->(DbSeek(xFilial("ZHB") + _cNumSeq + _cItem ))
                                If  ZHB->(RecLock("ZHB",.F.))
                                        ZHB->ZHB_QUANT  := VAL(oRetAPI[nX]["itens"][nY]["qtde"])
                                        ZHB->ZHB_VLUNIT := oRetAPI[nX]["itens"][nY]["vl_nota_unit_liquido"]
                                        ZHB->ZHB_VLRBRT := oRetAPI[nX]["itens"][nY]["vl_nota_bruto"]
                                        ZHB->ZHB_VUNBRT := VAL(oRetAPI[nX]["itens"][nY]["vl_nota_unit_bruto"])

                                        If Empty(oRetAPI[nX]["itens"][nY]["vl_desconto_x7"])
                                            _nValDesc := 0 
                                        Else
                                            _nValDesc := Val(oRetAPI[nX]["itens"][nY]["vl_desconto_x7"])
                                        EndIf
                                        ZHB->ZHB_VLRDES := _nValDesc  //add 18.08.2026 andre claro

                                        ZHB->ZHB_CODPRD := _cProduto // Produto que veio da ZHC -- oRetAPI[nX]["itens"][nY]["cod_produto"]
                                        ZHB->ZHB_TES     := _cTes
                                        ZHB->ZHB_LOCAL   := _cLocal
                                        ZHB->ZHB_ITEM   := _cItem
                                        ZHB->ZHB_ITDESC := oRetAPI[nX]["itens"][nY]["produto"] //Descrição
                                        ZHB->ZHB_BICMS := _nBaseICMS
                                        ZHB->ZHB_PICMS := _nAliqICMS
                                        ZHB->ZHB_VICMS := _nVlrICMS
                                        ZHB->ZHB_BPIS  := _nBasePIS
                                        ZHB->ZHB_PPIS  := _nAliqPIS
                                        ZHB->ZHB_VPIS  := _nVlrPIS
                                        ZHB->ZHB_BCOF  := _nBaseCOF
                                        ZHB->ZHB_PCOF  := _nAliqCOF
                                        ZHB->ZHB_VCOF  := _nVlrCOF

                                        ZHB->ZHB_BIPI  := _nBaseIPI
                                        ZHB->ZHB_PIPI  := _nAliqIPI
                                        ZHB->ZHB_VIPI  := _nVlrIPI

                                        ZHB->ZHB_CSTICMS  := _cCSTICMS
                                        ZHB->ZHB_CSTPIS  := _cCSTPIS
                                        ZHB->ZHB_CSTCOF  := _cCSTCOF
                                        ZHB->ZHB_CSTIPI  := _cCSTIPI
                                    ZHB->(MsUnlock())
                                EndIf
                            EndIf
                        Next nY

                        End Transaction
                        DbSelectArea("ZHA")
                        ZHA->(DbSetOrder(3)) // FILIAL + NUMSEQ
                        ZHA->(dbGoTop())
                        If ZHA->(DbSeek(_cFilZHA + _cNumSeq ) )
                            If  ZHA->(RecLock("ZHA",.F.))
                                    ZHA->ZHA_INTEGR := _cFlag //   "P"-Problema/ "N"-Não integrada a NF 
                                    ZHA->ZHA_DETERR := _cUniErro
                                    ZHA->ZHA_NATURE := _cNaturez
                                    ZHA->ZHA_CONDPG := _cCondPag
                                ZHA->(MsUnLock())
                            Endif
                        EndIf
                EndIf
            EndIf 
        EndIf
    Next nX 

    If Aviso("ATENÇÃO","Deseja realizar a integração das notas fiscais Pendentes? ",{"Sim","Não"},2) == 1
        _cErro := ""

        _cQuery += "SELECT R_E_C_N_O_ AS RECZHA, * FROM "+RetSqlName("ZHA") + " ZHA WHERE ZHA.D_E_L_E_T_ = '' AND ZHA.ZHA_INTEGR = 'N' "
        _cAlias := GetNextAlias()
        MpSysOpenQuery(_cQuery, _cAlias)

        _nCount := 0
        While (_cAlias)->(!eof())
            _nCount++
        (_cAlias)->(DbSkip())
        EndDo

        oProcess:SetRegua1( 1 )
        oProcess:SetRegua2(_nCount)

        oProcess:IncRegua1( "Entrada de NFs - MATA103 " )
        nX := 0 
        (_cAlias)->(DbGoTop())
        DbSelectArea("ZHA")
        While (_cAlias)->(!eof())
            nX++
            oProcess:IncRegua2("Processando ("+cValToChar( Round(nX/_nCount*100,2) ) +"%)" )
            ZHA->(DbGoTo( (_cAlias)->RECZHA))
            If ZHA->(RECNO()) == (_cAlias)->RECZHA
                If U_ACAUTZHA(ZHA->ZHA_NUMSEQ, @_cErro)
                    If  ZHA->(RecLock("ZHA",.F.))
                            ZHA->ZHA_INTEGR := "S"
                        ZHA->(MsUnLock())
                    EndIf
                Else
                    _cDetalhe := Alltrim(ZHA->ZHA_DETERR)
                    _cDetalhe := CRLF + DtoC(Date()) + " " + Time()+" " + Alltrim(_cErro)

                    ZHA->(DbGoTo( (_cAlias)->RECZHA))
                    If ZHA->(RECNO()) == (_cAlias)->RECZHA
                        If  ZHA->(RecLock("ZHA",.F.))
                                ZHA->ZHA_DETERR := _cDetalhe
                                ZHA->ZHA_INTEGR := "P"
                            ZHA->(MsUnLock())
                        EndIf
                    Endif
                EndIf
            EndIf
            (_cAlias)->(DbSkip())
        EndDo
    EndIf

    U_FMKLOGTI("\logs\Integracao_X7\Logs",  FWTimeStamp(2, dData, cHora)  , cErros ) 

Return Nil


Static Function GETMOV(cDtIni, cDtFim)

    Local API_URL   := SuperGetMv("MV_ZAPIZHA",.F.,"https://gateway.x7bank.com.br/Consultas/movimentosResumido" ) //"https://gateway.x7bank.com.br")
    Local aHeader   := {}
    Local oJsResult := JsonObject():new()
    Local cJsonBody := '{ "dataini": "' + cDtIni + '", "datafim": "' + cDtFim + '" }'
    Local nTimeOut 	:= 240
	Local cHeadRet 	:= ""
    Local cRetConn, cDesc
    Local cRetConexao := ''
    // Headers no formato correto: array de STRING "Chave: Valor"
    AAdd(aHeader, "Accept: */*")
    AAdd(aHeader, "Content-Type: application/json; charset=utf-8")
    AAdd(aHeader, "x-uid: 1586")
    AAdd(aHeader, "Token: 060911e24be53e24131c0dbb4667df9e")
    aadd(aHeader,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')

    API_URL += "/Consultas/movimentosResumidoB"
    cRetConexao := HTTPQuote( API_URL, "GET", NIL, cJsonBody , nTimeOut, aHeader, @cHeadRet )

    cRetConn := CValToChar(HttpGetStatus(@cDesc))   
                If cRetConn = '200' //Retorno Com sucesso
                oJsResult:FromJson(cRetConexao)
                else 
                
                endif



Return oJsResult


 
Static Function RETFIL(cCgc)
Local cCodFil := ''
Default cMyAlias	:= GetNextAlias()

    BeginSql alias cMyAlias	
        %noparser%  
            SELECT TOP 1 M0_CODFIL FROM SYS_COMPANY WITH(NOLOCK) WHERE M0_CGC = %exp:cCgc%  
    EndSql	
   (cMyAlias)->(DbGoTop())
   While (cMyAlias)->(!eof())
	cCodFil := (cMyAlias)->(M0_CODFIL)
	
(cMyAlias)->(DbSkip())
EndDo


    
Return Alltrim(cCodFil)
