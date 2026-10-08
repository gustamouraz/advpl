#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "FWMVCDEF.CH"

/*/{Protheus.doc} LMFZZP
Cadastro compartilhado de fornecedor x produto.

A ZZP e a unica tabela fisica do cadastro: os dados do fornecedor formam o
cabecalho logico e os produtos sao mantidos na grade da mesma tabela.
@type function
/*/
User Function LMFZZP()
    Local aArea   := FWGetArea()
    Local oBrowse := FWMBrowse():New()

    DbSelectArea("ZZP")
    ZZP->(DbSetOrder(1))
    oBrowse:SetAlias("ZZP")
    oBrowse:SetDescription("Tabela Generica - Fornecedor x Produto")
    oBrowse:SetMenuDef("LMFZZP")
    oBrowse:SetDBFFilter(.T.)
    oBrowse:SetUseFilter(.T.)
    oBrowse:SetOnlyFields({ "ZZP_FORN", "ZZP_LOJA", "ZZP_NOME", "ZZP_GRUPO", ;
        "ZZP_DESGRP", "ZZP_PRODUT", "ZZP_DESPRO", "ZZP_OBS" })
    oBrowse:Activate()
    FWRestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
Menu padrao MVC.
/*/
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.LMFZZP" OPERATION MODEL_OPERATION_VIEW   ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.LMFZZP" OPERATION MODEL_OPERATION_INSERT ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.LMFZZP" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.LMFZZP" OPERATION MODEL_OPERATION_DELETE ACCESS 0
    ADD OPTION aRotina TITLE "Copiar"     ACTION "VIEWDEF.LMFZZP" OPERATION 9                      ACCESS 0
Return aRotina

/*/{Protheus.doc} ModelDef
Modelo MVC de uma unica tabela: o mesmo alias ZZP compoe o cabecalho e a
grade. O relacionamento replica fornecedor e loja nos itens da grade.
/*/
Static Function ModelDef()
    Local oModel   := Nil
    Local oStrCab  := FWFormStruct(1, "ZZP", {|cCampo| ZZPCabCampo(cCampo)})
    Local oStrGrid := FWFormStruct(1, "ZZP", {|cCampo| ZZPGridCampo(cCampo)})

    oStrCab:SetProperty("ZZP_FORN", MODEL_FIELD_OBRIGAT, .T.)
    oStrCab:SetProperty("ZZP_LOJA", MODEL_FIELD_OBRIGAT, .T.)
    oStrCab:SetProperty("ZZP_NOME"  , MODEL_FIELD_WHEN, {|| .F. })
    oStrCab:SetProperty("ZZP_NREDUZ", MODEL_FIELD_WHEN, {|| .F. })
    oStrCab:SetProperty("ZZP_EST"   , MODEL_FIELD_WHEN, {|| .F. })
    oStrCab:SetProperty("ZZP_MUN"   , MODEL_FIELD_WHEN, {|| .F. })

    oStrGrid:SetProperty("ZZP_ITEM"  , MODEL_FIELD_OBRIGAT, .T.)
    oStrGrid:SetProperty("ZZP_GRUPO" , MODEL_FIELD_OBRIGAT, .T.)
    oStrGrid:SetProperty("ZZP_PRODUT", MODEL_FIELD_OBRIGAT, .T.)
    oStrGrid:SetProperty("ZZP_DESGRP", MODEL_FIELD_WHEN, {|| .F. })
    oStrGrid:SetProperty("ZZP_DESPRO", MODEL_FIELD_WHEN, {|| .F. })

    // Gatilhos programaticos: nao dependem de configuracao no SX7.
    oStrCab:AddTrigger("ZZP_FORN", "ZZP_NOME"  , {|| .T. }, {|oFld| ZZPA2Campo(oFld, "A2_NOME")})
    oStrCab:AddTrigger("ZZP_FORN", "ZZP_NREDUZ", {|| .T. }, {|oFld| ZZPA2Campo(oFld, "A2_NREDUZ")})
    oStrCab:AddTrigger("ZZP_FORN", "ZZP_EST"   , {|| .T. }, {|oFld| ZZPA2Campo(oFld, "A2_EST")})
    oStrCab:AddTrigger("ZZP_FORN", "ZZP_MUN"   , {|| .T. }, {|oFld| ZZPA2Campo(oFld, "A2_MUN")})
    oStrCab:AddTrigger("ZZP_LOJA", "ZZP_NOME"  , {|| .T. }, {|oFld| ZZPA2Campo(oFld, "A2_NOME")})
    oStrCab:AddTrigger("ZZP_LOJA", "ZZP_NREDUZ", {|| .T. }, {|oFld| ZZPA2Campo(oFld, "A2_NREDUZ")})
    oStrCab:AddTrigger("ZZP_LOJA", "ZZP_EST"   , {|| .T. }, {|oFld| ZZPA2Campo(oFld, "A2_EST")})
    oStrCab:AddTrigger("ZZP_LOJA", "ZZP_MUN"   , {|| .T. }, {|oFld| ZZPA2Campo(oFld, "A2_MUN")})
    oStrGrid:AddTrigger("ZZP_GRUPO" , "ZZP_DESGRP", {|| .T. }, {|oFld| ZZPDescGrupo(oFld)})
    oStrGrid:AddTrigger("ZZP_PRODUT", "ZZP_DESPRO", {|| .T. }, {|oFld| ZZPDescProduto(oFld)})

    oModel := MPFormModel():New("LMFZZPM", , {|oMdl| ZZPValida(oMdl)}, {|oMdl| FWFormCommit(oMdl)})
    oModel:AddFields("ZZPMASTER", Nil, oStrCab)
    oModel:AddGrid("ZZPDETAIL", "ZZPMASTER", oStrGrid)
    oModel:SetRelation("ZZPDETAIL", {;
        {"ZZP_FILIAL", "''"}, ;
        {"ZZP_FORN"  , "ZZP_FORN"}, ;
        {"ZZP_LOJA"  , "ZZP_LOJA"}  ;
        }, ZZP->(IndexKey(1)))
    oModel:GetModel("ZZPDETAIL"):SetMaxLine(9999)
    oModel:SetPrimaryKey({"ZZP_FORN", "ZZP_LOJA", "ZZP_ITEM"})
    oModel:SetDescription("Tabela Generica - Fornecedor x Produto")
    oModel:GetModel("ZZPMASTER"):SetDescription("Dados do Fornecedor")
    oModel:GetModel("ZZPDETAIL"):SetDescription("Produtos")
Return oModel

/*/{Protheus.doc} ViewDef
Cabecalho e grade em uma tela MVC, com a maior parte da altura destinada aos
itens para acomodar todos os campos solicitados.
/*/
Static Function ViewDef()
    Local oModel   := FWLoadModel("LMFZZP")
    Local oStrCab  := FWFormStruct(2, "ZZP", {|cCampo| ZZPCabCampo(cCampo)})
    Local oStrGrid := FWFormStruct(2, "ZZP", {|cCampo| ZZPGridCampo(cCampo)})
    Local oView    := FWFormView():New()

    oStrCab:SetNoFolder()
    oStrGrid:RemoveField("ZZP_FILIAL")
    oStrGrid:RemoveField("ZZP_FORN")
    oStrGrid:RemoveField("ZZP_LOJA")
    oView:SetModel(oModel)
    oView:AddField("VIEW_ZZP", oStrCab, "ZZPMASTER")
    oView:AddGrid("GRID_ZZP", oStrGrid, "ZZPDETAIL")
    oView:CreateHorizontalBox("CABEC", 32)
    oView:CreateHorizontalBox("ITENS", 68)
    oView:SetOwnerView("VIEW_ZZP", "CABEC")
    oView:SetOwnerView("GRID_ZZP", "ITENS")
    oView:EnableTitleView("VIEW_ZZP", "Dados do Fornecedor")
    oView:EnableTitleView("GRID_ZZP", "Produtos")
    oView:EnableControlBar(.T.)
    oView:AddIncrementField("GRID_ZZP", "ZZP_ITEM")
Return oView

Static Function ZZPCabCampo(cCampo)
Return AllTrim(cCampo) $ "ZZP_FORN,ZZP_LOJA,ZZP_NOME,ZZP_NREDUZ,ZZP_EST,ZZP_MUN"

Static Function ZZPGridCampo(cCampo)
Return AllTrim(cCampo) $ "ZZP_FILIAL,ZZP_FORN,ZZP_LOJA,ZZP_ITEM,ZZP_GRUPO,ZZP_DESGRP,ZZP_PRODUT,ZZP_DESPRO,ZZP_OBS"

/*/{Protheus.doc} ZZPValida
Valida cabecalho, grade e a existencia dos cadastros de referencia antes da
gravacao MVC.
/*/
Static Function ZZPValida(oModel)
    Local oCab  := oModel:GetModel("ZZPMASTER")
    Local oGrid := oModel:GetModel("ZZPDETAIL")
    Local nLine := 0
    Local cForn := AllTrim(oCab:GetValue("ZZP_FORN"))
    Local cLoja := AllTrim(oCab:GetValue("ZZP_LOJA"))
    Local cGrp  := ""
    Local cProd := ""

    If !ZZPA2Existe(cForn, cLoja)
        oModel:SetErrorMessage("ZZPMASTER", "ZZP_FORN", "ZZPMASTER", "ZZP_FORN", ;
            "Fornecedor", "Fornecedor/Loja inexistente.", "Informe um fornecedor valido.")
        Return .F.
    EndIf
    If oGrid:Length() == 0
        oModel:SetErrorMessage("ZZPDETAIL", "ZZP_ITEM", "ZZPDETAIL", "ZZP_ITEM", ;
            "Produtos", "Informe ao menos um produto.", "Inclua um item na grade.")
        Return .F.
    EndIf
    For nLine := 1 To oGrid:Length()
        oGrid:SetLine(nLine)
        cGrp  := AllTrim(oGrid:GetValue("ZZP_GRUPO"))
        cProd := AllTrim(oGrid:GetValue("ZZP_PRODUT"))
        If Empty(cGrp) .Or. Empty(cProd) .Or. Empty(ZZPBuscaGrupo(cGrp)) .Or. Empty(ZZPBuscaProduto(cProd))
            oModel:SetErrorMessage("ZZPDETAIL", "ZZP_PRODUT", "ZZPDETAIL", "ZZP_PRODUT", ;
                "Produtos", "Grupo ou produto invalido.", "Revise os dados do item " + cValToChar(nLine) + ".")
            Return .F.
        EndIf
    Next
    oGrid:SetLine(1)
Return .T.

Static Function ZZPA2Campo(oFields, cCampo)
Return ZZPA2Valor(AllTrim(oFields:GetValue("ZZP_FORN")), AllTrim(oFields:GetValue("ZZP_LOJA")), cCampo)

Static Function ZZPA2Valor(cForn, cLoja, cCampo)
    Local cKey := xFilial("SA2") + PadR(cForn, TamSx3("A2_COD")[1]) + PadR(cLoja, TamSx3("A2_LOJA")[1])
    Local aTam := TamSx3(StrTran(cCampo, "A2_", "ZZP_"))
    Local cRet := ""

    If !Empty(cForn) .And. !Empty(cLoja)
        cRet := AllTrim(GetAdvFVal("SA2", cCampo, cKey, 1, ""))
    EndIf
Return PadR(Left(cRet, aTam[1]), aTam[1])

Static Function ZZPA2Existe(cForn, cLoja)
Return !Empty(AllTrim(ZZPA2Valor(cForn, cLoja, "A2_NOME")))

Static Function ZZPDescGrupo(oFields)
    Local aTam := TamSx3("ZZP_DESGRP")
Return PadR(Left(ZZPBuscaGrupo(AllTrim(oFields:GetValue("ZZP_GRUPO"))), aTam[1]), aTam[1])

Static Function ZZPDescProduto(oFields)
    Local aTam := TamSx3("ZZP_DESPRO")
Return PadR(Left(ZZPBuscaProduto(AllTrim(oFields:GetValue("ZZP_PRODUT"))), aTam[1]), aTam[1])

Static Function ZZPBuscaGrupo(cGrupo)
    Local cKey := xFilial("SBM") + PadR(cGrupo, TamSx3("BM_GRUPO")[1])
    Local cRet := ""

    If !Empty(cGrupo)
        cRet := AllTrim(GetAdvFVal("SBM", "BM_DESC", cKey, 1, ""))
        If Empty(cRet)
            cRet := AllTrim(GetAdvFVal("SBM", "BM_DESC", PadR(cGrupo, TamSx3("BM_GRUPO")[1]), 1, ""))
        EndIf
    EndIf
Return cRet

Static Function ZZPBuscaProduto(cProd)
    Local cKey := xFilial("SB1") + PadR(cProd, TamSx3("B1_COD")[1])
    Local cRet := ""

    If !Empty(cProd)
        cRet := AllTrim(GetAdvFVal("SB1", "B1_DESC", cKey, 1, ""))
        If Empty(cRet)
            cRet := AllTrim(GetAdvFVal("SB1", "B1_DESC", PadR(cProd, TamSx3("B1_COD")[1]), 1, ""))
        EndIf
    EndIf
Return cRet

