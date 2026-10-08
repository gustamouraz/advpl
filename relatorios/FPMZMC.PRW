//Bibliotecas
#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'FWMVCDef.ch' 
Static cTitulo := "Cadastro de Exce��es PCO"  
User Function FPMZMC()
    Local aArea   := GetArea()
    Local oBrowse
    Local cFunBkp := FunName()
     
    SetFunName("FPMZMC")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZMC")
    oBrowse:SetDescription(cTitulo)
    oBrowse:AddLegend( "ZMC->ZMC_TIPO = '1'", "GREEN",          "Exce��o de TES"                )
    oBrowse:AddLegend( "ZMC->ZMC_TIPO = '2'", "RED",            "Exce��o de TM"                 )
    oBrowse:AddLegend( "ZMC->ZMC_TIPO = '3'", "YELLOW",         "Exce��o de Natureza"           )
    oBrowse:AddLegend( "ZMC->ZMC_TIPO = '4'", "ORANGE",         "Exce��o de Produto"            )  
    oBrowse:AddLegend( "ZMC->ZMC_TIPO = '5'", "BLUE",           "Exce��o de Grupo de Produto"   )
    oBrowse:AddLegend( "ZMC->ZMC_TIPO = '6'", "GRAY",           "Exce��o de Conta Contabil"     )
    oBrowse:AddLegend( "ZMC->ZMC_TIPO = '7'", "BROWN",          "Exce��o de Centro de Custo"    )
    oBrowse:Activate()
     
    SetFunName(cFunBkp)
    RestArea(aArea)
Return Nil
 
 
Static Function MenuDef()
    Local aRot := {}
    ADD OPTION aRot TITLE 'Visualizar'  ACTION 'VIEWDEF.FPMZMC'         OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Legenda'     ACTION 'u_ZMCLEG'               OPERATION 6                      ACCESS 0 //OPERATION X
    ADD OPTION aRot TITLE 'Incluir'     ACTION 'VIEWDEF.FPMZMC'         OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'     ACTION 'VIEWDEF.FPMZMC'         OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'     ACTION 'VIEWDEF.FPMZMC'         OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot 
Static Function ModelDef()
    Local oModel := Nil 
    Local oStZMC := FWFormStruct(1, "ZMC")
    oModel := MPFormModel():New("FPMZMC0",/*bPre*/,,,/*bCancel*/) 
    oModel:AddFields("FORMZMC",/*cOwner*/,oStZMC)
    oModel:SetPrimaryKey({'ZMC_FILIAL','ZMC_CODIGO'})
    oModel:SetDescription(cTitulo)
    oModel:GetModel("FORMZMC"):SetDescription("Inclusão de "+cTitulo)
Return oModel 
 
Static Function ViewDef()
    Local oModel := FWLoadModel("FPMZMC")
    Local oStZMC := FWFormStruct(2, "ZMC")
    Local oView := Nil
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_ZMC", oStZMC, "FORMZMC")
    oView:CreateHorizontalBox("TELA",100)
    oView:EnableTitleView('VIEW_ZMC', 'Dados - '+cTitulo )  
    oView:SetCloseOnOk({||.T.})
    oView:SetOwnerView("VIEW_ZMC","TELA")   
Return oView
  
User Function ZMCLEG()
    Local aLegenda := {}  
        AADD(aLegenda,{"BR_VERDE"     ,"Exceção de TES"             })  
        AADD(aLegenda,{"BR_VERMELHO"  ,"Exceção de TM"              })    
        AADD(aLegenda,{"BR_AMARELO"   ,"Exceção de Natureza"        })  
        AADD(aLegenda,{"BR_LARANJA"   ,"Exceção de Produto"         })  
        AADD(aLegenda,{"BR_AZUL"      ,"Exceção de Grupo de Produto"})  
        AADD(aLegenda,{"BR_CINZA"     ,"Exceção de Conta Contábil"  })  
        AADD(aLegenda,{"BR_MARROM"    ,"Exceção de Centro de Custo" })  
    BrwLegenda(cTitulo, "Status", aLegenda)
Return


/*/{Protheus.doc} ACEXCZMC
@type function
@version 12.1.22
@author André Claro - 35 99877-5495 / andre.claro@acclaro.com.br
@since 31/05/2023
@param _cProc, variant, param_description
@param _cItem, variant, param_description
@return logico - integra ou não ao PCO

If (  U_ACEXCZMC("000002","01"), SE2->E2_VALOR, 0 )




1=TES;2=TM;3=Natureza;4=Produto;5=Grupo;6=Conta;7=CC;8=Fornecedor;9=Especie                                                     

If _cProces == "000054"

ZMC_PROCES
ZMC_ITEM
ZMC_TIPO
ZMC_TES
ZMC_TM
ZMC_NATURE
ZMC_PROD
ZMC_GPROD
ZMC_CONTA
ZMC_CC
ZMC_ESPECI
ZMC_FORN
ZMC_LJFORN
ZMC_DUPLIC
ZMC_ESTOQU
ZMC_ENTFUT
ZMC_CFOP
Else

EndIf

/*/
User Function ACEXCZMC(_cProc, _cIt, _cProduto, _cCtaCtb, _cCusto, _cFornece, _cLjForn, _lIntegra, _lRegExc)
Local _aArea := GetArea()
Local _aAreaSF1 := SF1->(GetArea())
Local _aAreaSB1 := SB1->(GetArea())
Local _aAreaSE2 := SE2->(GetArea())
Local _aAreaSF4 := SF4->(GetArea())
Local _lRet := .T.
Local _cAlias := ''
Local _cCC := "" 
Local _cTM := ''
Local _cProcess := '%'+ValToSql(_cProc)+'%'
Local _cItem    := ""
Local _cFilSB1 := xFilial("SB1")
Local _cFilSE2 := xFilial("SE2")
Local _cFilSE1 := xFilial("SE1")
Local _cFilSF4 := xFilial("SF4")
Local _cGrupo := ""
Local _cMovEst := ""
Local _nX := 0
Local _aFiliais := {}
Local _cFilSql := ""
Local _cRotNao := Alltrim(UPPER(SuperGetMV("MV_Z151PCN",.F.,"U_ACPCOLSD3")))

Default _cProduto := ''
Default _cCtaCtb  := ''
Default _cCusto  := ''
Default _cFornece := ''
Default _cLjForn := ''
Default _lIntegra := .F.
Default _lRegExc := .F.
Default _cIt := ""

_cItem    := '%'+ValToSql(_cIt)+'%'

If !Empty(_cRotNao) .and. Alltrim(UPPER(FunName())) $ _cRotNao
    Return _lRet
EndIf


DbSelectArea("ZMC")
ZMC->(DbSetOrder(1)) //Filial / Codigo
ZMC->(DbGoTop())
 

_aFiliais := {}
aAdd(_aFiliais, cFilAnt)
aAdd(_aFiliais, SubStr(cFilAnt,1,4))
aAdd(_aFiliais, SubStr(cFilAnt,1,2))
aAdd(_aFiliais, "") //sem filial

For _nX := 1 to 4 //4 testes com filial inteira, com grupo/empresa, com grupo e sem filial
    _cAlias := GetNextAlias()
    _cFilSql := _aFiliais[_nX]
    
    _cQuery := ""
    _cQuery += "    SELECT  *
    _cQuery += "    FROM        "+RetSqlName("ZMC")+" ZMC WITH(NOLOCK) "  + CRLF
    _cQuery += "    WHERE       ZMC.D_E_L_E_T_ = '' AND ZMC.ZMC_FILIAL = '"+xfilial("ZMC")+"' " + CRLF
    _cQuery += "            AND ZMC.ZMC_PROCES = '"+_cProc+"' " + CRLF
    _cQuery += "            AND (ZMC.ZMC_ITEM = '"+_cIt+"' OR '"+_cIt+"' = ''  ) "  + CRLF
    _cQuery += "            AND ZMC.ZMC_FILORI LIKE '%' + '"+_cFilSql + "' " + CRLF
    _cQuery += "            AND ZMC.ZMC_REGEXC = 'R' " + CRLF
    If Empty(_cFilSql)
        _cQuery += "            AND ZMC.ZMC_FILORI = '' " + CRLF
    EndIf

    MpSysOpenQuery(_cQuery, _cAlias)

    If (_cAlias)->(!Eof())
        _lRegExc := .T.
        (_cAlias)->(DbCloseArea())
        Exit
    Else
        (_cAlias)->(DbCloseArea())
    EndIf

Next _nX

_aFiliais := {}
If !_lRegExc // Se estiver validando se existe regra
    If _cProc == "000054" //Nota Fiscal de Entrada
        //Definição de onde eu busco o Centro de Custo
        If _cIt $ "01|05|07"
            _cCC := Alltrim(SD1->D1_CC) // '%'+ValToSql(SD1->D1_CC)+'%' 
        ElseIf _cIt $ "09|10|11" 
            _cCC := Alltrim(SDE->DE_CC) // '%'+ValToSql(SDE->DE_CC)+'%'
        EndIf

        DbSelectArea("SB1")
        SB1->(DbSetOrder(1))
        SB1->(DbGoTop())
        If SB1->(DbSeek(_cFilSB1 + SD1->D1_COD))
            _cGrupo := SB1->B1_GRUPO
            _cMovEst := GetAdvFVal("SF4","F4_ESTOQUE",xFilial("SF4") + SD1->D1_TES, 1, "" )
            _cConta := IIF(_cMovEst=="S".AND.SuperGetMV('MV_ZAPLDIR',.F.,.T.),SB1->B1_CONTA,IIF(cFilAnt$GetMv("MV_ZFLPCOD"),SB1->B1_XCTADES,SB1->B1_RCONTA))  //Se estoque e usando conta de estoque  //PCO2025
        EndIf
        
        aAdd(_aFiliais, cFilAnt)
        aAdd(_aFiliais, SubStr(cFilAnt,1,4))
        aAdd(_aFiliais, SubStr(cFilAnt,1,2))
        aAdd(_aFiliais, "") //sem filial
        
        For _nX := 1 to 4 //4 testes com filial inteira, com grupo/empresa, com grupo e sem filial
            If !_lRet
                Exit
            EndIf
            _cAlias := GetNextAlias()
            _cFilSql := '%'+ValToSql(_aFiliais[_nX])+'%'
            If _lIntegra
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND ZMC.ZMC_ITEM = %exp:_cItem%
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                            AND ZMC.ZMC_INTEGR <> 'S'
                EndSql
            Else
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND ZMC.ZMC_ITEM = %exp:_cItem%
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                EndSql
            EndIf
            //1=TES;2=TM;3=Natureza;4=Produto;5=Grupo;6=Conta;7=CC;8=Fornecedor;9=Especie;A=Filial
            If (_cAlias)->(!eof())
                DbSelectArea("SF1")
                SF1->(DbSetOrder(1))
                DbSelectArea("SE2")
                SE2->(DbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO

                While (_cAlias)->(!eof()) .AND. _lRet
                    If (_cAlias)->ZMC_TIPO == "1" //Tes
                        If Alltrim((_cAlias)->ZMC_TES) == Alltrim(SD1->D1_TES)
                            _lRet := .F.
                            _nX := 4
                            (_cAlias)->(DbCloseArea())
                            Exit
                        ElseIf Empty((_cAlias)->ZMC_TES)
                            SF4->(DbGoTop())
                            If SF4->(DbSeek(_cFilSF4 + SD1->D1_TES))
                                If !Empty((_cAlias)->ZMC_DUPLIC)
                                    If SF4->F4_DUPLIC == (_cAlias)->ZMC_DUPLIC .AND.;
                                        (Empty((_cAlias)->ZMC_ESTOQU) .OR. SF4->F4_ESTOQUE == (_cAlias)->ZMC_ESTOQU ) .AND.;
                                        (Empty((_cAlias)->ZMC_CFOP) .OR. SF4->F4_CF == (_cAlias)->ZMC_CFOP ) .AND.;
                                        (Empty((_cAlias)->ZMC_ENTFUT) .OR. SF4->F4_EFUTUR == (_cAlias)->ZMC_ENTFUT )
                                        _lRet := .F.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit  
                                    EndIf

                                ElseIf !Empty((_cAlias)->ZMC_ESTOQU)
                                    If SF4->F4_ESTOQUE == (_cAlias)->ZMC_ESTOQU .AND.;
                                        (Empty((_cAlias)->ZMC_DUPLIC) .OR. SF4->F4_DUPLIC == (_cAlias)->ZMC_DUPLIC ) .AND.;
                                        (Empty((_cAlias)->ZMC_CFOP) .OR. SF4->F4_CF == (_cAlias)->ZMC_CFOP ) .AND.;
                                        (Empty((_cAlias)->ZMC_ENTFUT) .OR. SF4->F4_EFUTUR == (_cAlias)->ZMC_ENTFUT )
                                        _lRet := .F.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit  
                                    EndIf
                                ElseIf !Empty((_cAlias)->ZMC_CFOP)
                                    If Alltrim(SF4->F4_CF) == Alltrim((_cAlias)->ZMC_CFOP) .AND.;
                                        (Empty((_cAlias)->ZMC_DUPLIC) .OR. SF4->F4_DUPLIC == (_cAlias)->ZMC_DUPLIC ) .AND.;
                                        (Empty((_cAlias)->ZMC_ESTOQU) .OR. SF4->F4_ESTOQUE == (_cAlias)->ZMC_ESTOQU ) .AND.;
                                        (Empty((_cAlias)->ZMC_ENTFUT) .OR. SF4->F4_EFUTUR == (_cAlias)->ZMC_ENTFUT )
                                        _lRet := .F.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit  
                                    EndIf                      

                                ElseIf !Empty((_cAlias)->ZMC_ENTFUT)
                                    If SF4->F4_EFUTUR == (_cAlias)->ZMC_ENTFUT .AND.;
                                        (Empty((_cAlias)->ZMC_DUPLIC) .OR. SF4->F4_DUPLIC == (_cAlias)->ZMC_DUPLIC ) .AND.;
                                        (Empty((_cAlias)->ZMC_ESTOQU) .OR. SF4->F4_ESTOQUE == (_cAlias)->ZMC_ESTOQU ) .AND.;
                                        (Empty((_cAlias)->ZMC_CFOP) .OR. SF4->F4_CF == (_cAlias)->ZMC_CFOP ) 
                                        _lRet := .F.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit  
                                    EndIf  
                                EndIf
                            EndIf
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "2" //TM
                    ElseIf (_cAlias)->ZMC_TIPO == "3" //Natureza
                        SF1->(DbGoTop())
                        If SF1->(DbSeek(SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA)))                
                            SE2->(DbGoTop())
                            If SE2->(_cFilSE2 + SF1->(F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DUPL))
                                While _lRet .AND. SE2->(!EOF()) .AND. SE2->E2_FILIAL == _cFilSE2 ;
                                    .AND. SE2->E2_PREFIXO == SF1->F1_PREFIXO ;
                                    .AND. SE2->E2_NUM == SF1->F1_DUPL;
                                    .AND. SE2->E2_FORNECE == SF1->F1_FORNECE;
                                    .AND. SE2->E2_LOJA == SF1->F1_LOJA 
                                    If Alltrim(SE2->E2_TIPO) == "NF" .AND. ALLTRIM(SE2->E2_NATUREZ) == Alltrim(ZMC->ZMC_NATURE)
                                        _lRet := .F.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit
                                    EndIf
                                SE2->(DbSkip())
                                EndDo
                            EndIf
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "4" //Produto
                        If Alltrim((_cAlias)->ZMC_PROD) == Alltrim(SD1->D1_COD)
                            _lRet := .F.
                            Exit
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "5" //Grupo
                        If Alltrim(_cGrupo) == Alltrim((_cAlias)->ZMC_GPROD)
                            _lRet := .F.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "6" //Conta
                        If Alltrim(_cConta) == Alltrim((_cAlias)->ZMC_CONTA)
                            _lRet := .F.
                        EndIf            
                    ElseIf (_cAlias)->ZMC_TIPO == "7" //CC
                        If Alltrim((_cAlias)->ZMC_CC) == _cCC
                            _lRet := .F.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "8" //Fornecedor
                        If   Alltrim((_cAlias)->ZMC_FORN) == Alltrim(SD1->D1_FORNECE) .AND.; 
                            (Alltrim((_cAlias)->ZMC_LJFORN) == Alltrim(SD1->D1_LOJA) .OR. Empty((_cAlias)->ZMC_LJFORN) )
                            _lRet := .F.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "9" //Especie
                        SF1->(DbGoTop())
                        If SF1->(DbSeek(SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA)))
                            If Alltrim((_cAlias)->ZMC_ESPECI) == Alltrim(SF1->F1_ESPECIE)
                                _lRet := .F.
                            EndIf
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "A" //Filial
                        If Alltrim((_cAlias)->ZMC_FILORI) == cFilAnt 
                            _lRet := .F.
                        EndIf                    
                    EndIf
                (_cAlias)->(DbSkip())
                EndDo
            EndIf
            IF SELECT(_cAlias) > 0
                (_cAlias)->(DbCloseArea())
            ENDIF
        Next _nX 

    ElseIf _cProc $ "900052|900051" //Pedido de Compras e Solicitação de Compras
        _cCC := Alltrim(_cCusto)
        DbSelectArea("SB1")
        SB1->(DbSetOrder(1))
        SB1->(DbGoTop())
        If SB1->(DbSeek(_cFilSB1 + _cProduto))
            _cGrupo := SB1->B1_GRUPO
            _cConta := _cCtaCtb
        EndIf
        
        aAdd(_aFiliais, cFilAnt)
        aAdd(_aFiliais, SubStr(cFilAnt,1,4))
        aAdd(_aFiliais, SubStr(cFilAnt,1,2))
        aAdd(_aFiliais, "") //sem filial
        
        For _nX := 1 to 4 //4 testes com filial inteira, com grupo/empresa, com grupo e sem filial
            If !_lRet
                Exit
            EndIf
            _cAlias := GetNextAlias()
            _cFilSql := '%'+ValToSql(_aFiliais[_nX])+'%'
            _nTamFil := '%'+ValToSql( Len(_aFiliais[_nX]) )+'%'
            If _lIntegra
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND (ZMC.ZMC_ITEM = %exp:_cItem% OR ZMC.ZMC_ITEM = '' OR %exp:_cItem% = '' ) 
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                            AND ZMC.ZMC_INTEGR <> 'S'
                            AND LEN(ZMC.ZMC_FILORI) = %exp:_nTamFil%
                EndSql
            Else
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND (ZMC.ZMC_ITEM = %exp:_cItem% OR ZMC.ZMC_ITEM = '' OR %exp:_cItem% = '' ) 
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                            AND LEN(ZMC.ZMC_FILORI) = %exp:_nTamFil%
                EndSql
            EndIf

            //1=TES;2=TM;3=Natureza;4=Produto;5=Grupo;6=Conta;7=CC;8=Fornecedor;9=Especie  
            If (_cAlias)->(!eof())
                DbSelectArea("SF1")
                SF1->(DbSetOrder(1))
                DbSelectArea("SE2")
                SE2->(DbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO

                While (_cAlias)->(!eof()) .AND. _lRet
                    If (_cAlias)->ZMC_TIPO == "4" //Produto
                        If Alltrim((_cAlias)->ZMC_PROD) == Alltrim(_cProduto)
                            _lRet := .F.
                            Exit
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "5" //Grupo
                        If Alltrim(_cGrupo) == Alltrim((_cAlias)->ZMC_GPROD)
                            _lRet := .F.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "6" //Conta
                        If Alltrim(_cConta) == Alltrim((_cAlias)->ZMC_CONTA)
                            _lRet := .F.
                        EndIf            
                    ElseIf (_cAlias)->ZMC_TIPO == "7" //CC
                        If Alltrim((_cAlias)->ZMC_CC) == _cCC
                            _lRet := .F.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "8" //Fornecedor
                        If   Alltrim((_cAlias)->ZMC_FORN) == Alltrim(_cFornece) .AND.; 
                            (Alltrim((_cAlias)->ZMC_LJFORN) == Alltrim(_cLjForn) .OR. Empty((_cAlias)->ZMC_LJFORN) )
                            _lRet := .F.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "A" //Filial
                        If Alltrim((_cAlias)->ZMC_FILORI) == cFilAnt 
                            _lRet := .F.
                        EndIf                          
                    EndIf
                (_cAlias)->(DbSkip())
                EndDo
            EndIf
            IF SELECT(_cAlias) > 0
                (_cAlias)->(DbCloseArea())
            ENDIF
        Next _nX 
    ElseIf _cProc $ "000151" //Movimento interno // 08/11/2023 - André Claro
        _cCC := Alltrim(SD3->D3_CC)
        _cProduto := SD3->D3_COD
        _cTM := SD3->D3_TM
        _cCtaCtb := ''

        DbSelectArea("SB1")
        SB1->(DbSetOrder(1))
        SB1->(DbGoTop())
        If SB1->(DbSeek(_cFilSB1 + _cProduto))
            _cGrupo := SB1->B1_GRUPO
            _cCtaCtb := IIF(!Empty(SF5->F5_ZCONTA),SF5->F5_ZCONTA,SB1->B1_RCONTA)
            _cConta := _cCtaCtb
        EndIf
        
        aAdd(_aFiliais, cFilAnt)
        aAdd(_aFiliais, SubStr(cFilAnt,1,4))
        aAdd(_aFiliais, SubStr(cFilAnt,1,2))
        aAdd(_aFiliais, "") //sem filial
        
        For _nX := 1 to 4 //4 testes com filial inteira, com grupo/empresa, com grupo e sem filial
            If !_lRet
                Exit
            EndIf
            _cAlias := GetNextAlias()
            _cFilSql := '%'+ValToSql(_aFiliais[_nX])+'%'
            If _lIntegra
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND (ZMC.ZMC_ITEM = %exp:_cItem% OR ZMC.ZMC_ITEM = '' OR %exp:_cItem% = '' ) 
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                            AND ZMC.ZMC_INTEGR <> 'S'
                EndSql
            Else
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND (ZMC.ZMC_ITEM = %exp:_cItem% OR ZMC.ZMC_ITEM = '' OR %exp:_cItem% = '' ) 
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                EndSql
            EndIf

            If (_cAlias)->(!eof())
                While (_cAlias)->(!eof()) .AND. _lRet
                    If (_cAlias)->ZMC_TIPO == "4" //Produto
                        If Alltrim((_cAlias)->ZMC_PROD) == Alltrim(_cProduto)
                            _lRet := .F.
                            Exit
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "5" //Grupo
                        If Alltrim(_cGrupo) == Alltrim((_cAlias)->ZMC_GPROD)
                            _lRet := .F.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "2" //TM
                        If Alltrim(_cTM) == Alltrim((_cAlias)->ZMC_TM)
                            _lRet := .F.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "6" //Conta
                        If Alltrim(_cConta) == Alltrim((_cAlias)->ZMC_CONTA)
                            _lRet := .F.
                        EndIf            
                    ElseIf (_cAlias)->ZMC_TIPO == "7" //CC
                        If Alltrim((_cAlias)->ZMC_CC) == _cCC
                            _lRet := .F.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "A" //Filial
                        If Alltrim((_cAlias)->ZMC_FILORI) == cFilAnt 
                            _lRet := .F.
                        EndIf                          
                    EndIf
                (_cAlias)->(DbSkip())
                EndDo
            EndIf
            IF SELECT(_cAlias) > 0
                (_cAlias)->(DbCloseArea())
            ENDIF
        Next _nX     

    ElseIf _cProc == "000101" //Nota Fiscal de Saída
        //Definição de onde eu busco o Centro de Custo
        If _cIt $ "01"
            _cCC := Alltrim(SD2->D2_CCUSTO) // '%'+ValToSql(SD2->D2_CCUSTO)+'%' 
        ElseIf _cIt $ "09" 
            _cCC := Alltrim(AGH->AGH_CC) // '%'+ValToSql(AGH->AGH_CC)+'%'
        EndIf

        DbSelectArea("SB1")
        SB1->(DbSetOrder(1))
        SB1->(DbGoTop())
        If SB1->(DbSeek(_cFilSB1 + SD2->D2_COD))
            _cGrupo := SB1->B1_GRUPO
            _cMovEst := GetAdvFVal("SF4","F4_ESTOQUE",xFilial("SF4") + SD2->D2_TES, 1, "" )
            _cConta := IIF(_cMovEst=="S".AND.SuperGetMV('MV_ZAPLDIR',.F.,.T.),SB1->B1_CONTA,IIF(cFilAnt$GetMv("MV_ZFLPCOD"),SB1->B1_XCTADES,SB1->B1_RCONTA)) //Se estoque e usando conta de estoque  //PCO2025
        EndIf
        
        aAdd(_aFiliais, cFilAnt)
        aAdd(_aFiliais, SubStr(cFilAnt,1,4))
        aAdd(_aFiliais, SubStr(cFilAnt,1,2))
        aAdd(_aFiliais, "") //sem filial
        
        For _nX := 1 to 4 //4 testes com filial inteira, com grupo/empresa, com grupo e sem filial
            If !_lRet
                Exit
            EndIf
            _cAlias := GetNextAlias()
            _cFilSql := '%'+ValToSql(_aFiliais[_nX])+'%'
            If _lIntegra
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND ZMC.ZMC_ITEM = %exp:_cItem%
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                            AND ZMC.ZMC_INTEGR <> 'S'
                EndSql
            Else
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND ZMC.ZMC_ITEM = %exp:_cItem%
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                EndSql
            EndIf

            //1=TES;2=TM;3=Natureza;4=Produto;5=Grupo;6=Conta;7=CC;8=Fornecedor;9=Especie  
            If (_cAlias)->(!eof())
                DbSelectArea("SF2")
                SF2->(DbSetOrder(1))
                DbSelectArea("SE1")
                SE1->(DbSetOrder(2)) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

                While (_cAlias)->(!eof()) .AND. _lRet
                    If (_cAlias)->ZMC_TIPO == "1" //Tes
                        If Alltrim((_cAlias)->ZMC_TES) == Alltrim(SD2->D2_TES)
                            _lRet := .F.
                            _nX := 4
                            (_cAlias)->(DbCloseArea())
                            Exit
                        ElseIf Empty((_cAlias)->ZMC_TES)
                            SF4->(DbGoTop())
                            If SF4->(DbSeek(_cFilSF4 + SD2->D2_TES))
                                If !Empty((_cAlias)->ZMC_DUPLIC)
                                    If SF4->F4_DUPLIC == (_cAlias)->ZMC_DUPLIC .AND.;
                                        (Empty((_cAlias)->ZMC_ESTOQU) .OR. SF4->F4_ESTOQUE == (_cAlias)->ZMC_ESTOQU ) .AND.;
                                        (Empty((_cAlias)->ZMC_CFOP) .OR. SF4->F4_CF == (_cAlias)->ZMC_CFOP ) .AND.;
                                        (Empty((_cAlias)->ZMC_ENTFUT) .OR. SF4->F4_EFUTUR == (_cAlias)->ZMC_ENTFUT )
                                        _lRet := .F.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit  
                                    EndIf

                                ElseIf !Empty((_cAlias)->ZMC_ESTOQU)
                                    If SF4->F4_ESTOQUE == (_cAlias)->ZMC_ESTOQU .AND.;
                                        (Empty((_cAlias)->ZMC_DUPLIC) .OR. SF4->F4_DUPLIC == (_cAlias)->ZMC_DUPLIC ) .AND.;
                                        (Empty((_cAlias)->ZMC_CFOP) .OR. SF4->F4_CF == (_cAlias)->ZMC_CFOP ) .AND.;
                                        (Empty((_cAlias)->ZMC_ENTFUT) .OR. SF4->F4_EFUTUR == (_cAlias)->ZMC_ENTFUT )
                                        _lRet := .F.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit  
                                    EndIf
                                ElseIf !Empty((_cAlias)->ZMC_CFOP)
                                    If Alltrim(SF4->F4_CF) == Alltrim((_cAlias)->ZMC_CFOP) .AND.;
                                        (Empty((_cAlias)->ZMC_DUPLIC) .OR. SF4->F4_DUPLIC == (_cAlias)->ZMC_DUPLIC ) .AND.;
                                        (Empty((_cAlias)->ZMC_ESTOQU) .OR. SF4->F4_ESTOQUE == (_cAlias)->ZMC_ESTOQU ) .AND.;
                                        (Empty((_cAlias)->ZMC_ENTFUT) .OR. SF4->F4_EFUTUR == (_cAlias)->ZMC_ENTFUT )
                                        _lRet := .F.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit  
                                    EndIf                      

                                ElseIf !Empty((_cAlias)->ZMC_ENTFUT)
                                    If SF4->F4_EFUTUR == (_cAlias)->ZMC_ENTFUT .AND.;
                                        (Empty((_cAlias)->ZMC_DUPLIC) .OR. SF4->F4_DUPLIC == (_cAlias)->ZMC_DUPLIC ) .AND.;
                                        (Empty((_cAlias)->ZMC_ESTOQU) .OR. SF4->F4_ESTOQUE == (_cAlias)->ZMC_ESTOQU ) .AND.;
                                        (Empty((_cAlias)->ZMC_CFOP) .OR. SF4->F4_CF == (_cAlias)->ZMC_CFOP ) 
                                        _lRet := .F.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit  
                                    EndIf  
                                EndIf
                            EndIf
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "2" //TM
                    ElseIf (_cAlias)->ZMC_TIPO == "3" //Natureza
                        SF2->(DbGoTop())
                        If SF2->(DbSeek(SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA)))
                            SE1->(DbGoTop())
                            If SE1->(_cFilSE1 + SF2->(F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DUPL))
                                While _lRet .AND. SE1->(!EOF()) .AND. SE1->E1_FILIAL == _cFilSE1 ;
                                    .AND. SE1->E1_PREFIXO == SF2->F2_PREFIXO ;
                                    .AND. SE1->E1_NUM == SF2->F2_DUPL;
                                    .AND. SE1->E1_CLIENTE == SF2->F2_CLIENTE;
                                    .AND. SE1->E1_LOJA == SF2->F2_LOJA 
                                    If Alltrim(SE1->E1_TIPO) == "NF" .AND. ALLTRIM(SE1->E1_NATUREZ) == Alltrim(ZMC->ZMC_NATURE)
                                        _lRet := .F.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit
                                    EndIf
                                SE2->(DbSkip())
                                EndDo
                            EndIf
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "4" //Produto
                        If Alltrim((_cAlias)->ZMC_PROD) == Alltrim(SD2->D2_COD)
                            _lRet := .F.
                            Exit
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "5" //Grupo
                        If Alltrim(_cGrupo) == Alltrim((_cAlias)->ZMC_GPROD)
                            _lRet := .F.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "6" //Conta
                        If Alltrim(_cConta) == Alltrim((_cAlias)->ZMC_CONTA)
                            _lRet := .F.
                        EndIf            
                    ElseIf (_cAlias)->ZMC_TIPO == "7" //CC
                        If Alltrim((_cAlias)->ZMC_CC) == _cCC
                            _lRet := .F.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "8" //Fornecedor
                        If   Alltrim((_cAlias)->ZMC_FORN) == Alltrim(SD2->D2_CLIENTE) .AND.; 
                            (Alltrim((_cAlias)->ZMC_LJFORN) == Alltrim(SD2->D2_LOJA) .OR. Empty((_cAlias)->ZMC_LJFORN) )
                            _lRet := .F.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "9" //Especie
                        SF2->(DbGoTop())
                        If SF2->(DbSeek(SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA)))
                            If Alltrim((_cAlias)->ZMC_ESPECI) == Alltrim(SF2->F2_ESPECIE)
                                _lRet := .F.
                            EndIf
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "A" //Filial
                        If Alltrim((_cAlias)->ZMC_FILORI) == cFilAnt 
                            _lRet := .F.
                        EndIf                         
                    EndIf
                (_cAlias)->(DbSkip())
                EndDo
            EndIf
            //(_cAlias)->(DbCloseArea())
            IF SELECT(_cAlias) > 0
                (_cAlias)->(DbCloseArea())
            ENDIF

        Next _nX 

    ElseIf _cProc $ "000082|900082" //Pedido de Compras e Solicitação de Compras
        _cCC := Alltrim(_cCusto)
        _cConta := Alltrim(_cCtaCtb)

        If !Empty(_cIt) .and. Empty(_cConta) .and. _cProc $ "000082" //CT2 Vai estar posicionada
            If _cIt == "D"
                _cCC := Alltrim(CT2->CT2_CCD)
                _cConta := Alltrim(CT2->CT2_DEBITO)
            ElseIf _cIt == "C"
                _cCC := Alltrim(CT2->CT2_CCC)
                _cConta := Alltrim(CT2->CT2_CREDIT)        
            EndIf
        EndIf
    
        aAdd(_aFiliais, cFilAnt)
        aAdd(_aFiliais, SubStr(cFilAnt,1,4))
        aAdd(_aFiliais, SubStr(cFilAnt,1,2))
        aAdd(_aFiliais, "") //sem filial
        
        For _nX := 1 to 4 //4 testes com filial inteira, com grupo/empresa, com grupo e sem filial
            If !_lRet
                Exit
            EndIf
            _cAlias := GetNextAlias()
            _cFilSql := '%'+ValToSql(_aFiliais[_nX])+'%'
            If _lIntegra
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND (ZMC.ZMC_ITEM = %exp:_cItem% OR ZMC.ZMC_ITEM = '' OR %exp:_cItem% = '' ) 
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                            AND ZMC.ZMC_INTEGR <> 'S'
                EndSql
            Else
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND (ZMC.ZMC_ITEM = %exp:_cItem% OR ZMC.ZMC_ITEM = '' OR %exp:_cItem% = '' ) 
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                EndSql
            EndIf

            //1=TES;2=TM;3=Natureza;4=Produto;5=Grupo;6=Conta;7=CC;8=Fornecedor;9=Especie  
            If (_cAlias)->(!eof())
                DbSelectArea("SF1")
                SF1->(DbSetOrder(1))
                DbSelectArea("SE2")
                SE2->(DbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
                While (_cAlias)->(!eof()) .AND. _lRet
                    If (_cAlias)->ZMC_TIPO == "4" //Produto
                        If Alltrim((_cAlias)->ZMC_PROD) == Alltrim(_cProduto)
                            _lRet := .F.
                            Exit
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "5" //Grupo
                        If Alltrim(_cGrupo) == Alltrim((_cAlias)->ZMC_GPROD)
                            _lRet := .F.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "6" //Conta
                        If Alltrim(_cConta) == Alltrim((_cAlias)->ZMC_CONTA)
                            _lRet := .F.
                        EndIf            
                    ElseIf (_cAlias)->ZMC_TIPO == "7" //CC
                        If Alltrim((_cAlias)->ZMC_CC) == _cCC
                            _lRet := .F.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "8" //Fornecedor
                        If   Alltrim((_cAlias)->ZMC_FORN) == Alltrim(_cFornece) .AND.; 
                            (Alltrim((_cAlias)->ZMC_LJFORN) == Alltrim(_cLjForn) .OR. Empty((_cAlias)->ZMC_LJFORN) )
                            _lRet := .F.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "A" //Filial
                        If Alltrim((_cAlias)->ZMC_FILORI) == cFilAnt 
                            _lRet := .F.
                        EndIf
                    EndIf
                (_cAlias)->(DbSkip())
                EndDo
            EndIf
            IF SELECT(_cAlias) > 0
                (_cAlias)->(DbCloseArea())
            ENDIF
        Next _nX 
    EndIf


Else

    _lRet := .F.

    If _cProc == "000054" //Nota Fiscal de Entrada
        //Definição de onde eu busco o Centro de Custo
        If _cIt $ "01|05|07"
            _cCC := Alltrim(SD1->D1_CC) // '%'+ValToSql(SD1->D1_CC)+'%' 
        ElseIf _cIt $ "09|10|11" 
            _cCC := Alltrim(SDE->DE_CC) // '%'+ValToSql(SDE->DE_CC)+'%'
        EndIf

        DbSelectArea("SB1")
        SB1->(DbSetOrder(1))
        SB1->(DbGoTop())
        If SB1->(DbSeek(_cFilSB1 + SD1->D1_COD))
            _cGrupo := SB1->B1_GRUPO
            _cMovEst := GetAdvFVal("SF4","F4_ESTOQUE",xFilial("SF4") + SD1->D1_TES, 1, "" )
            _cConta := IIF(_cMovEst=="S".AND.SuperGetMV('MV_ZAPLDIR',.F.,.T.),SB1->B1_CONTA,IIF(cFilAnt$GetMv("MV_ZFLPCOD"),SB1->B1_XCTADES,SB1->B1_RCONTA))  //Se estoque e usando conta de estoque  //PCO2025
        EndIf
        
        aAdd(_aFiliais, cFilAnt)
        aAdd(_aFiliais, SubStr(cFilAnt,1,4))
        aAdd(_aFiliais, SubStr(cFilAnt,1,2))
        aAdd(_aFiliais, " ") //sem filial
        
        For _nX := 1 to 4 //4 testes com filial inteira, com grupo/empresa, com grupo e sem filial
            If _lRet
                Exit
            EndIf
            _cAlias := GetNextAlias()
            _cFilSql := '%'+ValToSql(_aFiliais[_nX])+'%'
            If _lIntegra
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND ZMC.ZMC_ITEM = %exp:_cItem%
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                            AND ZMC.ZMC_INTEGR <> 'S'
                            AND ZMC.ZMC_REGEXC = 'R' 
                EndSql
            Else
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND ZMC.ZMC_ITEM = %exp:_cItem%
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                            AND ZMC.ZMC_REGEXC = 'R' 
                EndSql
            EndIf
            //1=TES;2=TM;3=Natureza;4=Produto;5=Grupo;6=Conta;7=CC;8=Fornecedor;9=Especie  
            If (_cAlias)->(!eof())
                DbSelectArea("SF1")
                SF1->(DbSetOrder(1))
                DbSelectArea("SE2")
                SE2->(DbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO

                While (_cAlias)->(!eof()) .AND. !_lRet
                    If (_cAlias)->ZMC_TIPO == "1" //Tes
                        If Alltrim((_cAlias)->ZMC_TES) == Alltrim(SD1->D1_TES)
                            _lRet := .T.
                            _nX := 4
                            (_cAlias)->(DbCloseArea())
                            Exit
                        ElseIf Empty((_cAlias)->ZMC_TES)
                            SF4->(DbGoTop())
                            If SF4->(DbSeek(_cFilSF4 + SD1->D1_TES))
                                If !Empty((_cAlias)->ZMC_DUPLIC)
                                    If SF4->F4_DUPLIC == (_cAlias)->ZMC_DUPLIC .AND.;
                                        (Empty((_cAlias)->ZMC_ESTOQU) .OR. SF4->F4_ESTOQUE == (_cAlias)->ZMC_ESTOQU ) .AND.;
                                        (Empty((_cAlias)->ZMC_CFOP) .OR. SF4->F4_CF == (_cAlias)->ZMC_CFOP ) .AND.;
                                        (Empty((_cAlias)->ZMC_ENTFUT) .OR. SF4->F4_EFUTUR == (_cAlias)->ZMC_ENTFUT )
                                        _lRet := .T.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit  
                                    EndIf

                                ElseIf !Empty((_cAlias)->ZMC_ESTOQU)
                                    If SF4->F4_ESTOQUE == (_cAlias)->ZMC_ESTOQU .AND.;
                                        (Empty((_cAlias)->ZMC_DUPLIC) .OR. SF4->F4_DUPLIC == (_cAlias)->ZMC_DUPLIC ) .AND.;
                                        (Empty((_cAlias)->ZMC_CFOP) .OR. SF4->F4_CF == (_cAlias)->ZMC_CFOP ) .AND.;
                                        (Empty((_cAlias)->ZMC_ENTFUT) .OR. SF4->F4_EFUTUR == (_cAlias)->ZMC_ENTFUT )
                                        _lRet := .T.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit  
                                    EndIf
                                ElseIf !Empty((_cAlias)->ZMC_CFOP)
                                    If Alltrim(SF4->F4_CF) == Alltrim((_cAlias)->ZMC_CFOP) .AND.;
                                        (Empty((_cAlias)->ZMC_DUPLIC) .OR. SF4->F4_DUPLIC == (_cAlias)->ZMC_DUPLIC ) .AND.;
                                        (Empty((_cAlias)->ZMC_ESTOQU) .OR. SF4->F4_ESTOQUE == (_cAlias)->ZMC_ESTOQU ) .AND.;
                                        (Empty((_cAlias)->ZMC_ENTFUT) .OR. SF4->F4_EFUTUR == (_cAlias)->ZMC_ENTFUT )
                                        _lRet := .T.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit  
                                    EndIf                      

                                ElseIf !Empty((_cAlias)->ZMC_ENTFUT)
                                    If SF4->F4_EFUTUR == (_cAlias)->ZMC_ENTFUT .AND.;
                                        (Empty((_cAlias)->ZMC_DUPLIC) .OR. SF4->F4_DUPLIC == (_cAlias)->ZMC_DUPLIC ) .AND.;
                                        (Empty((_cAlias)->ZMC_ESTOQU) .OR. SF4->F4_ESTOQUE == (_cAlias)->ZMC_ESTOQU ) .AND.;
                                        (Empty((_cAlias)->ZMC_CFOP) .OR. SF4->F4_CF == (_cAlias)->ZMC_CFOP ) 
                                        _lRet := .T.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit  
                                    EndIf  
                                EndIf
                            EndIf
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "2" //TM
                    ElseIf (_cAlias)->ZMC_TIPO == "3" //Natureza
                        SF1->(DbGoTop())
                        If SF1->(DbSeek(SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA)))                
                            SE2->(DbGoTop())
                            If SE2->(_cFilSE2 + SF1->(F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DUPL))
                                While !_lRet .AND. SE2->(!EOF()) .AND. SE2->E2_FILIAL == _cFilSE2 ;
                                    .AND. SE2->E2_PREFIXO == SF1->F1_PREFIXO ;
                                    .AND. SE2->E2_NUM == SF1->F1_DUPL;
                                    .AND. SE2->E2_FORNECE == SF1->F1_FORNECE;
                                    .AND. SE2->E2_LOJA == SF1->F1_LOJA 
                                    If Alltrim(SE2->E2_TIPO) == "NF" .AND. ALLTRIM(SE2->E2_NATUREZ) == Alltrim(ZMC->ZMC_NATURE)
                                        _lRet := .T.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit
                                    EndIf
                                SE2->(DbSkip())
                                EndDo
                            EndIf
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "4" //Produto
                        If Alltrim((_cAlias)->ZMC_PROD) == Alltrim(SD1->D1_COD)
                            _lRet := .T.
                            Exit
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "5" //Grupo
                        If Alltrim(_cGrupo) == Alltrim((_cAlias)->ZMC_GPROD)
                            _lRet := .T.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "6" //Conta
                        If Alltrim(_cConta) == Alltrim((_cAlias)->ZMC_CONTA)
                            _lRet := .T.
                        EndIf            
                    ElseIf (_cAlias)->ZMC_TIPO == "7" //CC
                        If Alltrim((_cAlias)->ZMC_CC) == _cCC
                            _lRet := .T.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "8" //Fornecedor
                        If   Alltrim((_cAlias)->ZMC_FORN) == Alltrim(SD1->D1_FORNECE) .AND.; 
                            (Alltrim((_cAlias)->ZMC_LJFORN) == Alltrim(SD1->D1_LOJA) .OR. Empty((_cAlias)->ZMC_LJFORN) )
                            _lRet := .T.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "9" //Especie
                        SF1->(DbGoTop())
                        If SF1->(DbSeek(SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA)))
                            If Alltrim((_cAlias)->ZMC_ESPECI) == Alltrim(SF1->F1_ESPECIE)
                                _lRet := .T.
                            EndIf
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "A" //Filial
                        If Alltrim((_cAlias)->ZMC_FILORI) == cFilAnt 
                            _lRet := .F.
                        EndIf                        
                    EndIf
                (_cAlias)->(DbSkip())
                EndDo
            EndIf
            IF SELECT(_cAlias) > 0
                (_cAlias)->(DbCloseArea())
            ENDIF
        Next _nX 

    ElseIf _cProc $ "900052|900051" //Pedido de Compras e Solicitação de Compras
        _cCC := Alltrim(_cCusto)
        DbSelectArea("SB1")
        SB1->(DbSetOrder(1))
        SB1->(DbGoTop())
        If SB1->(DbSeek(_cFilSB1 + _cProduto))
            _cGrupo := SB1->B1_GRUPO
            _cConta := _cCtaCtb
        EndIf
        
        aAdd(_aFiliais, cFilAnt)
        aAdd(_aFiliais, SubStr(cFilAnt,1,4))
        aAdd(_aFiliais, SubStr(cFilAnt,1,2))
        aAdd(_aFiliais, "") //sem filial
        
        For _nX := 1 to 4 //4 testes com filial inteira, com grupo/empresa, com grupo e sem filial
            If _lRet
                Exit
            EndIf
            _cAlias := GetNextAlias()
            _cFilSql := '%'+ValToSql(_aFiliais[_nX])+'%'
            _nTamFil := '%'+ValToSql( Len(_aFiliais[_nX]) )+'%'
            If _lIntegra
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND (ZMC.ZMC_ITEM = %exp:_cItem% OR ZMC.ZMC_ITEM = '' OR %exp:_cItem% = '' ) 
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                            AND ZMC.ZMC_INTEGR <> 'S'
                            AND LEN(ZMC.ZMC_FILORI) = %exp:_nTamFil%
                EndSql
            Else
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND (ZMC.ZMC_ITEM = %exp:_cItem% OR ZMC.ZMC_ITEM = '' OR %exp:_cItem% = '' ) 
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                            AND LEN(ZMC.ZMC_FILORI) = %exp:_nTamFil%
                EndSql
            EndIf

            //1=TES;2=TM;3=Natureza;4=Produto;5=Grupo;6=Conta;7=CC;8=Fornecedor;9=Especie  
            If (_cAlias)->(!eof())
                DbSelectArea("SF1")
                SF1->(DbSetOrder(1))
                DbSelectArea("SE2")
                SE2->(DbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO

                While (_cAlias)->(!eof()) .AND. !_lRet
                    If (_cAlias)->ZMC_TIPO == "4" //Produto
                        If Alltrim((_cAlias)->ZMC_PROD) == Alltrim(_cProduto)
                            _lRet := .T.
                            Exit
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "5" //Grupo
                        If Alltrim(_cGrupo) == Alltrim((_cAlias)->ZMC_GPROD)
                            _lRet := .T.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "6" //Conta
                        If Alltrim(_cConta) == Alltrim((_cAlias)->ZMC_CONTA)
                            _lRet := .T.
                        EndIf            
                    ElseIf (_cAlias)->ZMC_TIPO == "7" //CC
                        If Alltrim((_cAlias)->ZMC_CC) == _cCC
                            _lRet := .T.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "8" //Fornecedor
                        If   Alltrim((_cAlias)->ZMC_FORN) == Alltrim(_cFornece) .AND.; 
                            (Alltrim((_cAlias)->ZMC_LJFORN) == Alltrim(_cLjForn) .OR. Empty((_cAlias)->ZMC_LJFORN) )
                            _lRet := .T.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "A" //Filial
                        If Alltrim((_cAlias)->ZMC_FILORI) == cFilAnt 
                            _lRet := .F.
                        EndIf                        
                    EndIf
                (_cAlias)->(DbSkip())
                EndDo
            EndIf
            IF SELECT(_cAlias) > 0
                (_cAlias)->(DbCloseArea())
            ENDIF
        Next _nX 
    ElseIf _cProc $ "000151" //Movimento interno // 08/11/2023 - André Claro
        _cCC := Alltrim(SD3->D3_CC)
        _cProduto := SD3->D3_COD
        _cTM := SD3->D3_TM
        _cCtaCtb := ''
        _lRet := .F.

        _cConta := IIF(!EMPTY(SF5->F5_ZCONTA),SF5->F5_ZCONTA,IIF(cFilAnt$GetMv("MV_ZFLPCOD"),POSICIONE("SB1",1,XFILIAL("SB1")+SD3->D3_COD,"B1_XCTADES"),POSICIONE("SB1",1,XFILIAL("SB1")+SD3->D3_COD,"B1_RCONTA"))) 

        If !Empty(_cConta)
            DbSelectArea("SB1")
            SB1->(DbSetOrder(1))
            SB1->(DbGoTop())
            If SB1->(DbSeek(_cFilSB1 + _cProduto))
                _cGrupo := SB1->B1_GRUPO
                _cCtaCtb := IIF(!Empty(SF5->F5_ZCONTA),SF5->F5_ZCONTA,SB1->B1_RCONTA)
                _cConta := _cCtaCtb
            EndIf
        EndIf

        aAdd(_aFiliais, cFilAnt)
        aAdd(_aFiliais, SubStr(cFilAnt,1,4))
        aAdd(_aFiliais, SubStr(cFilAnt,1,2))
        aAdd(_aFiliais, "") //sem filial
        
        For _nX := 1 to 4 //4 testes com filial inteira, com grupo/empresa, com grupo e sem filial
            If _lRet
                Exit
            EndIf
            _cAlias := GetNextAlias()
            _cFilSql := '%'+ValToSql(_aFiliais[_nX])+'%'
            If _lIntegra
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND (ZMC.ZMC_ITEM = %exp:_cItem% OR ZMC.ZMC_ITEM = '' OR %exp:_cItem% = '' ) 
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                            AND ZMC.ZMC_REGEXC = 'R'
                EndSql
            Else
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND (ZMC.ZMC_ITEM = %exp:_cItem% OR ZMC.ZMC_ITEM = '' OR %exp:_cItem% = '' ) 
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                            AND ZMC.ZMC_REGEXC = 'R'
                EndSql
            EndIf

            If (_cAlias)->(!eof())
                While (_cAlias)->(!eof()) .AND. !_lRet
                    If (_cAlias)->ZMC_TIPO == "4" //Produto
                        If Alltrim((_cAlias)->ZMC_PROD) == Alltrim(_cProduto)
                            _lRet := .T.
                            Exit
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "5" //Grupo
                        If Alltrim(_cGrupo) == Alltrim((_cAlias)->ZMC_GPROD)
                            _lRet := .T.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "2" //TM
                        If Alltrim(_cTM) == Alltrim((_cAlias)->ZMC_TM)
                            _lRet := .T.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "6" //Conta
                        If Alltrim(_cConta) == Alltrim((_cAlias)->ZMC_CONTA)
                            _lRet := .T.
                        EndIf            
                    ElseIf (_cAlias)->ZMC_TIPO == "7" //CC
                        If Alltrim((_cAlias)->ZMC_CC) == _cCC
                            _lRet := .T.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "A" //Filial
                        If Alltrim((_cAlias)->ZMC_FILORI) == cFilAnt 
                            _lRet := .F.
                        EndIf 
                    EndIf
                (_cAlias)->(DbSkip())
                EndDo
            EndIf
            IF SELECT(_cAlias) > 0
                (_cAlias)->(DbCloseArea())
            ENDIF
        Next _nX     

    ElseIf _cProc == "000101" //Nota Fiscal de Saída
        //Definição de onde eu busco o Centro de Custo
        If _cIt $ "01"
            _cCC := Alltrim(SD2->D2_CCUSTO) // '%'+ValToSql(SD2->D2_CCUSTO)+'%' 
        ElseIf _cIt $ "09" 
            _cCC := Alltrim(AGH->AGH_CC) // '%'+ValToSql(AGH->AGH_CC)+'%'
        EndIf

        DbSelectArea("SB1")
        SB1->(DbSetOrder(1))
        SB1->(DbGoTop())
        If SB1->(DbSeek(_cFilSB1 + SD2->D2_COD))
            _cGrupo := SB1->B1_GRUPO
            _cMovEst := GetAdvFVal("SF4","F4_ESTOQUE",xFilial("SF4") + SD2->D2_TES, 1, "" )
            _cConta := IIF(_cMovEst=="S".AND.SuperGetMV('MV_ZAPLDIR',.F.,.T.),SB1->B1_CONTA,IIF(cFilAnt$GetMv("MV_ZFLPCOD"),SB1->B1_XCTADES,SB1->B1_RCONTA)) //Se estoque e usando conta de estoque  //PCO2025
        EndIf
        
        aAdd(_aFiliais, cFilAnt)
        aAdd(_aFiliais, SubStr(cFilAnt,1,4))
        aAdd(_aFiliais, SubStr(cFilAnt,1,2))
        aAdd(_aFiliais, "") //sem filial
        
        For _nX := 1 to 4 //4 testes com filial inteira, com grupo/empresa, com grupo e sem filial
            If _lRet
                Exit
            EndIf
            _cAlias := GetNextAlias()
            _cFilSql := '%'+ValToSql(_aFiliais[_nX])+'%'
            If _lIntegra
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND ZMC.ZMC_ITEM = %exp:_cItem%
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                            AND ZMC.ZMC_INTEGR <> 'S'
                EndSql
            Else
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND ZMC.ZMC_ITEM = %exp:_cItem%
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                EndSql
            EndIf

            //1=TES;2=TM;3=Natureza;4=Produto;5=Grupo;6=Conta;7=CC;8=Fornecedor;9=Especie  
            If (_cAlias)->(!eof())
                DbSelectArea("SF2")
                SF2->(DbSetOrder(1))
                DbSelectArea("SE1")
                SE1->(DbSetOrder(2)) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

                While (_cAlias)->(!eof()) .AND. !_lRet
                    If (_cAlias)->ZMC_TIPO == "1" //Tes
                        If Alltrim((_cAlias)->ZMC_TES) == Alltrim(SD2->D2_TES)
                            _lRet := .T.
                            _nX := 4
                            (_cAlias)->(DbCloseArea())
                            Exit
                        ElseIf Empty((_cAlias)->ZMC_TES)
                            SF4->(DbGoTop())
                            If SF4->(DbSeek(_cFilSF4 + SD2->D2_TES))
                                If !Empty((_cAlias)->ZMC_DUPLIC)
                                    If SF4->F4_DUPLIC == (_cAlias)->ZMC_DUPLIC .AND.;
                                        (Empty((_cAlias)->ZMC_ESTOQU) .OR. SF4->F4_ESTOQUE == (_cAlias)->ZMC_ESTOQU ) .AND.;
                                        (Empty((_cAlias)->ZMC_CFOP) .OR. SF4->F4_CF == (_cAlias)->ZMC_CFOP ) .AND.;
                                        (Empty((_cAlias)->ZMC_ENTFUT) .OR. SF4->F4_EFUTUR == (_cAlias)->ZMC_ENTFUT )
                                        _lRet := .T.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit  
                                    EndIf

                                ElseIf !Empty((_cAlias)->ZMC_ESTOQU)
                                    If SF4->F4_ESTOQUE == (_cAlias)->ZMC_ESTOQU .AND.;
                                        (Empty((_cAlias)->ZMC_DUPLIC) .OR. SF4->F4_DUPLIC == (_cAlias)->ZMC_DUPLIC ) .AND.;
                                        (Empty((_cAlias)->ZMC_CFOP) .OR. SF4->F4_CF == (_cAlias)->ZMC_CFOP ) .AND.;
                                        (Empty((_cAlias)->ZMC_ENTFUT) .OR. SF4->F4_EFUTUR == (_cAlias)->ZMC_ENTFUT )
                                        _lRet := .T.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit  
                                    EndIf
                                ElseIf !Empty((_cAlias)->ZMC_CFOP)
                                    If Alltrim(SF4->F4_CF) == Alltrim((_cAlias)->ZMC_CFOP) .AND.;
                                        (Empty((_cAlias)->ZMC_DUPLIC) .OR. SF4->F4_DUPLIC == (_cAlias)->ZMC_DUPLIC ) .AND.;
                                        (Empty((_cAlias)->ZMC_ESTOQU) .OR. SF4->F4_ESTOQUE == (_cAlias)->ZMC_ESTOQU ) .AND.;
                                        (Empty((_cAlias)->ZMC_ENTFUT) .OR. SF4->F4_EFUTUR == (_cAlias)->ZMC_ENTFUT )
                                        _lRet := .T.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit  
                                    EndIf                      

                                ElseIf !Empty((_cAlias)->ZMC_ENTFUT)
                                    If SF4->F4_EFUTUR == (_cAlias)->ZMC_ENTFUT .AND.;
                                        (Empty((_cAlias)->ZMC_DUPLIC) .OR. SF4->F4_DUPLIC == (_cAlias)->ZMC_DUPLIC ) .AND.;
                                        (Empty((_cAlias)->ZMC_ESTOQU) .OR. SF4->F4_ESTOQUE == (_cAlias)->ZMC_ESTOQU ) .AND.;
                                        (Empty((_cAlias)->ZMC_CFOP) .OR. SF4->F4_CF == (_cAlias)->ZMC_CFOP ) 
                                        _lRet := .T.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit  
                                    EndIf  
                                EndIf
                            EndIf
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "2" //TM
                    ElseIf (_cAlias)->ZMC_TIPO == "3" //Natureza
                        SF2->(DbGoTop())
                        If SF2->(DbSeek(SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA)))
                            SE1->(DbGoTop())
                            If SE1->(_cFilSE1 + SF2->(F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DUPL))
                                While !_lRet .AND. SE1->(!EOF()) .AND. SE1->E1_FILIAL == _cFilSE1 ;
                                    .AND. SE1->E1_PREFIXO == SF2->F2_PREFIXO ;
                                    .AND. SE1->E1_NUM == SF2->F2_DUPL;
                                    .AND. SE1->E1_CLIENTE == SF2->F2_CLIENTE;
                                    .AND. SE1->E1_LOJA == SF2->F2_LOJA 
                                    If Alltrim(SE1->E1_TIPO) == "NF" .AND. ALLTRIM(SE1->E1_NATUREZ) == Alltrim(ZMC->ZMC_NATURE)
                                        _lRet := .T.
                                        _nX := 4
                                        (_cAlias)->(DbCloseArea())
                                        Exit
                                    EndIf
                                SE2->(DbSkip())
                                EndDo
                            EndIf
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "4" //Produto
                        If Alltrim((_cAlias)->ZMC_PROD) == Alltrim(SD2->D2_COD)
                            _lRet := .T.
                            Exit
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "5" //Grupo
                        If Alltrim(_cGrupo) == Alltrim((_cAlias)->ZMC_GPROD)
                            _lRet := .T.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "6" //Conta
                        If Alltrim(_cConta) == Alltrim((_cAlias)->ZMC_CONTA)
                            _lRet := .T.
                        EndIf            
                    ElseIf (_cAlias)->ZMC_TIPO == "7" //CC
                        If Alltrim((_cAlias)->ZMC_CC) == _cCC
                            _lRet := .T.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "8" //Fornecedor
                        If   Alltrim((_cAlias)->ZMC_FORN) == Alltrim(SD2->D2_CLIENTE) .AND.; 
                            (Alltrim((_cAlias)->ZMC_LJFORN) == Alltrim(SD2->D2_LOJA) .OR. Empty((_cAlias)->ZMC_LJFORN) )
                            _lRet := .T.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "9" //Especie
                        SF2->(DbGoTop())
                        If SF2->(DbSeek(SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA)))
                            If Alltrim((_cAlias)->ZMC_ESPECI) == Alltrim(SF2->F2_ESPECIE)
                                _lRet := .T.
                            EndIf
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "A" //Filial
                        If Alltrim((_cAlias)->ZMC_FILORI) == cFilAnt 
                            _lRet := .F.
                        EndIf                            
                    EndIf
                (_cAlias)->(DbSkip())
                EndDo
            EndIf
            //(_cAlias)->(DbCloseArea())
            IF SELECT(_cAlias) > 0
                (_cAlias)->(DbCloseArea())
            ENDIF

        Next _nX 

    ElseIf _cProc $ "000082|900082" //Pedido de Compras e Solicitação de Compras
        _cCC := Alltrim(_cCusto)
        _cConta := Alltrim(_cCtaCtb)

        If !Empty(_cIt) .and. Empty(_cConta) .and. _cProc $ "000082" //CT2 Vai estar posicionada
            If _cIt == "D"
                _cCC := Alltrim(CT2->CT2_CCD)
                _cConta := Alltrim(CT2->CT2_DEBITO)
            ElseIf _cIt == "C"
                _cCC := Alltrim(CT2->CT2_CCC)
                _cConta := Alltrim(CT2->CT2_CREDIT)        
            EndIf
        EndIf
    
        aAdd(_aFiliais, cFilAnt)
        aAdd(_aFiliais, SubStr(cFilAnt,1,4))
        aAdd(_aFiliais, SubStr(cFilAnt,1,2))
        aAdd(_aFiliais, "") //sem filial
        
        For _nX := 1 to 4 //4 testes com filial inteira, com grupo/empresa, com grupo e sem filial
            If _lRet
                Exit
            EndIf
            _cAlias := GetNextAlias()
            _cFilSql := '%'+ValToSql(_aFiliais[_nX])+'%'
            If _lIntegra
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND (ZMC.ZMC_ITEM = %exp:_cItem% OR  %exp:_cItem% = '' ) 
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                            AND ZMC.ZMC_INTEGR <> 'S'
                EndSql
            Else
                Beginsql alias _cAlias 
                    %noparser%
                    SELECT  *
                    FROM        %table:ZMC% ZMC WITH(NOLOCK)
                    WHERE       ZMC.D_E_L_E_T_ = ''
                            AND ZMC.ZMC_PROCES = %exp:_cProcess%
                            AND (ZMC.ZMC_ITEM = %exp:_cItem% OR  %exp:_cItem% = '' ) 
                            AND ZMC.ZMC_FILORI LIKE %exp:_cFilSql% + '%'
                EndSql
            EndIf

            //1=TES;2=TM;3=Natureza;4=Produto;5=Grupo;6=Conta;7=CC;8=Fornecedor;9=Especie  
            If (_cAlias)->(!eof())
                DbSelectArea("SF1")
                SF1->(DbSetOrder(1))
                DbSelectArea("SE2")
                SE2->(DbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
                While (_cAlias)->(!eof()) .AND. !_lRet
                    If (_cAlias)->ZMC_TIPO == "4" //Produto
                        If Alltrim((_cAlias)->ZMC_PROD) == Alltrim(_cProduto)
                            _lRet := .T.
                            Exit
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "5" //Grupo
                        If Alltrim(_cGrupo) == Alltrim((_cAlias)->ZMC_GPROD)
                            _lRet := .T.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "6" //Conta
                        If Alltrim(_cConta) == Alltrim((_cAlias)->ZMC_CONTA)
                            _lRet := .T.
                        EndIf            
                    ElseIf (_cAlias)->ZMC_TIPO == "7" //CC
                        If Alltrim((_cAlias)->ZMC_CC) == _cCC
                            _lRet := .T.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "8" //Fornecedor
                        If   Alltrim((_cAlias)->ZMC_FORN) == Alltrim(_cFornece) .AND.; 
                            (Alltrim((_cAlias)->ZMC_LJFORN) == Alltrim(_cLjForn) .OR. Empty((_cAlias)->ZMC_LJFORN) )
                            _lRet := .T.
                        EndIf
                    ElseIf (_cAlias)->ZMC_TIPO == "A" //Filial
                        If Alltrim((_cAlias)->ZMC_FILORI) == cFilAnt 
                            _lRet := .F.
                        EndIf
                    EndIf
                (_cAlias)->(DbSkip())
                EndDo
            EndIf
            IF SELECT(_cAlias) > 0
                (_cAlias)->(DbCloseArea())
            ENDIF
        Next _nX 
    EndIf
EndIf

RestArea(_aAreaSE2)
RestArea(_aAreaSF1)
RestArea(_aAreaSB1)
RestArea(_aAreaSF4)
RestArea(_aArea)

Return _lRet 
