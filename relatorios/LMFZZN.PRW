#Include "Protheus.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} LMFZZN
Cadastro da relacao de troca entre commodities.

@type  User Function
@author Luiz Moura
@since 21/08/2026
/*/
User Function LMFZZN()
    Local aArea   := GetArea()
    Local oBrowse := FWMBrowse():New()
    Local cFunBkp := FunName()

    SetFunName("LMFZZN")

    oBrowse:SetAlias("ZZN")
    oBrowse:SetDescription("Relacao de Troca entre Commodities")
    oBrowse:Activate()

    SetFunName(cFunBkp)
    RestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
Menu padrao do cadastro MVC.
/*/
Static Function MenuDef()
    Local aRot := {}

    ADD OPTION aRot TITLE "Visualizar" ACTION "VIEWDEF.LMFZZN" OPERATION MODEL_OPERATION_VIEW   ACCESS 0
    ADD OPTION aRot TITLE "Incluir"    ACTION "VIEWDEF.LMFZZN" OPERATION MODEL_OPERATION_INSERT ACCESS 0
    ADD OPTION aRot TITLE "Alterar"    ACTION "VIEWDEF.LMFZZN" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
    ADD OPTION aRot TITLE "Excluir"    ACTION "VIEWDEF.LMFZZN" OPERATION MODEL_OPERATION_DELETE ACCESS 0
    ADD OPTION aRot TITLE "Copiar"     ACTION "VIEWDEF.LMFZZN" OPERATION 9                      ACCESS 0
Return aRot

/*/{Protheus.doc} ModelDef
Modelo de dados da tabela ZZN.
/*/
Static Function ModelDef()
    Local oModel := Nil
    Local oStrZZN := FWFormStruct(1, "ZZN")

    // Em inclusao sugere a data-base. Na copia, preserva a data do pacote
    // que esta posicionado no browse (operacao MVC 9).
    oStrZZN:SetProperty("ZZN_DATA", MODEL_FIELD_INIT, {|oFields| LMFZZNDataIni(oFields) })

    // Garante a descricao tambem na copia de registros antigos que ainda
    // tenham sido gravados somente com o codigo do produto.
    oStrZZN:SetProperty("ZZN_DESPRD", MODEL_FIELD_INIT, {|oFields| LMFZZNDescProd(oFields) })

    // Campos calculados pelo sistema nao podem ser digitados pelo usuario.
    oStrZZN:SetProperty("ZZN_TOTAL", MODEL_FIELD_WHEN, {|| .F. })
    oStrZZN:SetProperty("ZZN_DESPRD", MODEL_FIELD_WHEN, {|| .F. })
    oStrZZN:SetProperty("ZZN_RTALGO", MODEL_FIELD_WHEN, {|| .F. })
    oStrZZN:SetProperty("ZZN_RTMILH", MODEL_FIELD_WHEN, {|| .F. })
    oStrZZN:SetProperty("ZZN_RTSOJA", MODEL_FIELD_WHEN, {|| .F. })

    // Recalcula o total e as relacoes de troca quando os valores forem alterados.
    oStrZZN:AddTrigger("ZZN_PRODUT", "ZZN_DESPRD", {|| .T. }, {|oFields| LMFZZNDescProd(oFields) })
    oStrZZN:AddTrigger("ZZN_PRECO", "ZZN_TOTAL", {|| .T. }, {|oFields| LMFZZNTotal(oFields) })
    oStrZZN:AddTrigger("ZZN_FRETE", "ZZN_TOTAL", {|| .T. }, {|oFields| LMFZZNTotal(oFields) })
    oStrZZN:AddTrigger("ZZN_TOTAL", "ZZN_RTALGO", {|| .T. }, {|oFields| LMFZZNRelTroca(oFields, "ZZN_ALGOD") })
    oStrZZN:AddTrigger("ZZN_TOTAL", "ZZN_RTMILH", {|| .T. }, {|oFields| LMFZZNRelTroca(oFields, "ZZN_MILHO") })
    oStrZZN:AddTrigger("ZZN_TOTAL", "ZZN_RTSOJA" , {|| .T. }, {|oFields| LMFZZNRelTroca(oFields, "ZZN_SOJA") })

    // O MVC nao encadeia de forma confiavel gatilhos disparados por campos
    // calculados. Por isso, preco e frete atualizam as relacoes diretamente.
    oStrZZN:AddTrigger("ZZN_PRECO", "ZZN_RTALGO", {|| .T. }, {|oFields| LMFZZNRelTroca(oFields, "ZZN_ALGOD") })
    oStrZZN:AddTrigger("ZZN_PRECO", "ZZN_RTMILH", {|| .T. }, {|oFields| LMFZZNRelTroca(oFields, "ZZN_MILHO") })
    oStrZZN:AddTrigger("ZZN_PRECO", "ZZN_RTSOJA" , {|| .T. }, {|oFields| LMFZZNRelTroca(oFields, "ZZN_SOJA") })
    oStrZZN:AddTrigger("ZZN_FRETE", "ZZN_RTALGO", {|| .T. }, {|oFields| LMFZZNRelTroca(oFields, "ZZN_ALGOD") })
    oStrZZN:AddTrigger("ZZN_FRETE", "ZZN_RTMILH", {|| .T. }, {|oFields| LMFZZNRelTroca(oFields, "ZZN_MILHO") })
    oStrZZN:AddTrigger("ZZN_FRETE", "ZZN_RTSOJA" , {|| .T. }, {|oFields| LMFZZNRelTroca(oFields, "ZZN_SOJA") })
    oStrZZN:AddTrigger("ZZN_ALGOD", "ZZN_RTALGO", {|| .T. }, {|oFields| LMFZZNRelTroca(oFields, "ZZN_ALGOD") })
    oStrZZN:AddTrigger("ZZN_MILHO", "ZZN_RTMILH", {|| .T. }, {|oFields| LMFZZNRelTroca(oFields, "ZZN_MILHO") })
    oStrZZN:AddTrigger("ZZN_SOJA" , "ZZN_RTSOJA" , {|| .T. }, {|oFields| LMFZZNRelTroca(oFields, "ZZN_SOJA") })

    oModel := MPFormModel():New("LMFZZNM")
    oModel:AddFields("FORMZZN", Nil, oStrZZN)

    // Tabela compartilhada: a relacao e unica por produto e data.
    oModel:SetPrimaryKey({"ZZN_PRODUT", "ZZN_DATA"})
    oModel:SetDescription("Relacao de Troca entre Commodities")
    oModel:GetModel("FORMZZN"):SetDescription("Dados da Relacao de Troca")
Return oModel

/*/{Protheus.doc} ViewDef
Visao de manutencao do cadastro ZZN.
/*/
Static Function ViewDef()
    Local oModel := FWLoadModel("LMFZZN")
    // ZZN_FILIAL pode permanecer fisicamente na base enquanto o dicionario
    // e ajustado, mas nao faz parte da manutencao de tabela compartilhada.
    Local oStrZZN := FWFormStruct(2, "ZZN", {|cCampo| cCampo <> "ZZN_FILIAL"})
    Local oView  := FWFormView():New()

    oView:SetModel(oModel)
    oView:AddField("VIEW_ZZN", oStrZZN, "FORMZZN")
    oView:CreateHorizontalBox("TELA", 100)
    oView:EnableTitleView("VIEW_ZZN", "Relacao de Troca entre Commodities")
    oView:SetOwnerView("VIEW_ZZN", "TELA")
    oView:SetCloseOnOk({|| .T.})
Return oView

/*/{Protheus.doc} LMFZZNTotal
Retorna o total da operacao: preco acrescido do frete.
/*/
Static Function LMFZZNTotal(oFields)
    Local nPreco := IIf(ValType(oFields:GetValue("ZZN_PRECO")) == "N", oFields:GetValue("ZZN_PRECO"), 0)
    Local nFrete := IIf(ValType(oFields:GetValue("ZZN_FRETE")) == "N", oFields:GetValue("ZZN_FRETE"), 0)
Return nPreco + nFrete

/*/{Protheus.doc} LMFZZNDataIni
Inicializa a data apenas na inclusao. Na copia, utiliza a data do registro
de origem que permanece posicionado no alias do browse.
/*/
Static Function LMFZZNDataIni(oFields)
    Local dData := CToD("")

    If oFields:GetOperation() == MODEL_OPERATION_INSERT
        dData := dDataBase
    ElseIf Select("ZZN") > 0
        dData := ZZN->ZZN_DATA
    EndIf
Return dData

/*/{Protheus.doc} LMFZZNDescProd
Retorna a descricao do produto no tamanho exato do campo virtual.
/*/
Static Function LMFZZNDescProd(oFields)
    Local aTam   := TamSx3("ZZN_DESPRD")
    Local nTam   := aTam[1]
    Local cProd  := ""
    Local cDescr := ""
    Local aTamB1 := TamSx3("B1_COD")

    If ValType(oFields:GetValue("ZZN_PRODUT")) == "C"
        cProd := AllTrim(oFields:GetValue("ZZN_PRODUT"))
    EndIf

    // Durante a copia, o inicializador pode ser executado antes de o campo
    // produto ser transferido para o novo modelo.
    If Empty(cProd) .And. oFields:GetOperation() <> MODEL_OPERATION_INSERT .And. Select("ZZN") > 0
        cProd := AllTrim(ZZN->ZZN_PRODUT)
    EndIf

    If !Empty(cProd)
        cProd  := PadR(cProd, aTamB1[1])
        cDescr := GetAdvFVal("SB1", "B1_DESC", xFilial("SB1") + cProd, 1, "")

        // Produtos compartilhados nao possuem filial na chave fisica.
        If Empty(cDescr)
            cDescr := GetAdvFVal("SB1", "B1_DESC", cProd, 1, "")
        EndIf
    EndIf

Return PadR(Left(cDescr, nTam), nTam)

/*/{Protheus.doc} LMFZZNRelTroca
Calcula a relacao de troca entre o total da operacao e uma commodity.

@param oFields, objeto de campos do MVC
@param cCampo, campo que contem o valor da commodity
@return total dividido pelo valor da commodity
/*/
Static Function LMFZZNRelTroca(oFields, cCampo)
    // Calcula pelo preco e frete atuais, sem depender da ordem de disparo
    // dos gatilhos do MVC para atualizar ZZN_TOTAL.
    Local nTotal := LMFZZNTotal(oFields)
    Local nValor := IIf(ValType(oFields:GetValue(cCampo)) == "N", oFields:GetValue(cCampo), 0)

    If nValor == 0
        Return 0
    EndIf
Return nTotal / nValor
