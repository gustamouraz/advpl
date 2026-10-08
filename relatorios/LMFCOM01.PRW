//Bibliotecas
    #Include "Totvs.ch"
    #Include "FWMVCDef.ch"
    #include 'protheus.ch'
    #include 'parmtype.ch'
 
//Variveis Estaticas
    Static cTitulo := "Tipos de Solicitação"
    Static cTab := "ZZG"
 
/*/{Protheus.doc} User Function U_LMFCOM01()
@desc Contratos Logística
@author Luiz Moura
@since 20/06/2022
@version 1.0
@type function
/*/
 
User Function LMFCOM01()

    Local oBrowse
    Local aArea   := GetArea()

    Private aRotina := {}

    //Definicao do menu
    aRotina := MenuDef()

    //Instanciando o browse
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cTab)
    oBrowse:SetDescription(cTitulo)

    //Ativa a Browse
    oBrowse:Activate()
    
    RestArea(aArea)
 
Return Nil
 
/*/{Protheus.doc} MenuDef()
@desc Menu de opcoes na funcao LMFCOM01
@author Luiz Moura
@since 20/06/2022
@version 1.0
@type function
/*/
 
Static Function MenuDef()
    Local aRotina := {}
 
    //Adicionando opcoes do menu
    ADD OPTION aRotina TITLE "Visualizar"           ACTION "VIEWDEF.LMFCOM01"  OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"              ACTION "VIEWDEF.LMFCOM01"  OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"              ACTION "VIEWDEF.LMFCOM01"  OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"              ACTION "VIEWDEF.LMFCOM01"  OPERATION 5 ACCESS 0

Return aRotina
 
Static Function z02Menu()
Return MenuDef()
 
/*/{Protheus.doc} ModelDef()
@desc Modelo de dados na funcao LMFCOM01
@author Luiz Moura
@since 20/06/2022
@version 1.0
@type function
/*/
 
Static Function ModelDef()
    Local oStru := FWFormStruct(1, cTab)
    Local oModel
    Local bPre := Nil
    Local bPos := Nil
    Local bCommit := Nil
    Local bCancel := Nil

    oStru:SetProperty("ZZG_COD", MODEL_FIELD_WHEN,{|| .F.})
    oStru:SetProperty('ZZG_COD',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  "'"+GetSX8Num("ZZG","ZZG_COD")+"'"     ))
 
    //Cria o modelo de dados para cadastro
    oModel := MPFormModel():New("FPMZZGO", bPre, bPos, bCommit, bCancel)
    oModel:AddFields("ZZGMASTER", /*cOwner*/, oStru)
    oModel:SetDescription(cTitulo)
    oModel:GetModel("ZZGMASTER"):SetDescription( "Dados de - " + cTitulo)
    oModel:SetPrimaryKey({'ZZG_FILIAL','ZZG_COD'})

Return oModel
 
/*/{Protheus.doc} ViewDef
@desc Visualizacao de dados na funcao LMFCOM01
@author Luiz Moura
@since 20/06/2022
@version 1.0
@type function
/*/
 
Static Function ViewDef()
    Local oModel := FWLoadModel("LMFCOM01")
    Local oStru := FWFormStruct(2, cTab)
    Local oView
 
    //Cria a visualizacao do cadastro
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_ZZG", oStru, "ZZGMASTER")
 
    //Partes da tela
    oView:CreateHorizontalBox("CABEC", 100)
    oView:SetOwnerView("VIEW_ZZG", "CABEC")
    oView:EnableControlBar(.T.)

    //Titulos
    oView:EnableTitleView("VIEW_ZZG", "Dados de " + cTitulo)
  
    oView:SetFieldAction("ZZG_NATURE"   , {|oView, cIdView, cField, xValue| LMRETSED(oView, cIdView, cField, xValue)})
    oView:SetFieldAction("ZZG_COND"     , {|oView, cIdView, cField, xValue| LMRETSE4(oView, cIdView, cField, xValue)})

Return oView
 

//Bibliotecas
#Include "TOTVS.ch"
 
/*/{Protheus.doc} User Function zExe261
Função que abre uma tela para seleção de registros conforme um Array
@type  Function
@author Atilio
@since 21/02/2023
@obs 
 
    Função F_Opcoes
    Parâmetros
        + Define a variável de retorno
        + Define o texto do título da janela
        + Define o array de linhas da grid
        + Define os códigos das linhas da grid
        + Mantido por compatibilidade
        + Mantido por compatibilidade
        + Define se será a seleção de apenas 1 linha por vez
        + Tamanho da string da chave
        + Número máximo de elementos
        + Inclui botões para múltipla seleção
        + Define se será montado através de um X3_CBOX
        + Qual é o campo para montagem das opções
        + Não permite ordenação
        + Não permite pesquisar
        + Força o retorno como Array
        + Acionado em consulta F3
    Retorno
        Retorna .T. se foi confirmado ou .F. se foi cancelado
     
    **** Apoie nosso projeto, se inscreva em https://www.youtube.com/TerminalDeInformacao ****
/*/
 
Static Function LMRETSED(oView)
    Local aArea      := FWGetArea()
    Local aRet       := {}
    Local cTitulo    := "Naturezas"
    Local aOpc       := {}
    Local cRet       := ""
	Local MvPar      := ""
	Local nTam	:= 0
    Local oModel := oView:GetModel()
    Local oModMaster := oModel:GetModel("ZZGMASTER")


    Default _cMyAlias	:= GetNextAlias()
    Default lTipoRet := .T.

    IF lTipoRet
		MvPar:=Alltrim(ReadVar())
		mvRet:=Alltrim(ReadVar())
		nTam := Len(mvRet)
	EndIf

    l1Elem := If (l1Elem = Nil , .F. , .T.)

    BeginSql alias _cMyAlias
		%noParser%
        SELECT
            SUBSTRING(ED_CODIGO,1,6)ED_CODIGO,
            TRIM(ED_DESCRIC)ED_DESCRIC
        FROM SED010 WITH(NOLOCK)
        WHERE D_E_L_E_T_ = '' AND SUBSTRING(ED_CODIGO,5,2) <> '  '
                AND (ED_CODIGO LIKE '%1%'
                OR ED_CODIGO LIKE '%2%'
                OR ED_CODIGO LIKE '%3%'
                OR ED_CODIGO LIKE '%4%'
                OR ED_CODIGO LIKE '%5%'
                OR ED_CODIGO LIKE '%6%'
                OR ED_CODIGO LIKE '%7%'
                OR ED_CODIGO LIKE '%8%'
                OR ED_CODIGO LIKE '%9%'
                OR ED_CODIGO LIKE '%0%')
        ORDER BY ED_CODIGO
	
	EndSql

    While !(_cMyAlias)->(Eof())

        //Define as opções de retorno (conforme o aOpc acima)
        cRet += (_cMyAlias)->ED_CODIGO
        //Define as opções que serão exibidas
        aAdd(aOpc, (_cMyAlias)->ED_DESCRIC)

        (_cMyAlias)->(DbSkip())
    EndDo

    (_cMyAlias)->(DbCloseARea())
 
    //Abre a tela para a seleção
    If F_Opcoes(@aRet       ,;    //uVarRet
                cTitulo     ,;    //cTitulo
                aOpc        ,;    //aOpcoes
                cRet        ,;    //cOpcoes
                12          ,;    //nLin1
                49          ,;    //nCol1
                l1Elem      ,;    //l1Elem
                6           ,;    //nTam
                999         ,;    //nElemRet
                .T.         ,;    //lMulti
                .F.          )    //lCBox
 
    EndIf
 
    FWRestArea(aArea)

    cRet := ArrTokStr(aRet, ";")
    oModMaster:SetValue("ZZG_NATURE",  SubStr(Alltrim(cRet),1, TamSx3("ZZG_NATURE")[1] ))
   oView:Refresh()
Return lTipoRet

Static Function LMRETSE4(oView)
    Local aArea      := FWGetArea()
    Local aRet       := {}
    Local cTitulo    := "Condições de Pagamento"
    Local aOpc       := {}
    Local cRet       := ""
	Local MvPar      := ""
	Local nTam	:= 0
    Local oModel := oView:GetModel()
    Local oModMaster := oModel:GetModel("ZZGMASTER")
    Local xMvRet := Nil


    Default _cMyAlias	:= GetNextAlias()
    Default lTipoRet := .T.

    IF lTipoRet
        xMvRet := &( AllTrim(ReadVar()) )
        MvPar  := IIf( ValType(xMvRet) == "C", RTrim(xMvRet), ;
                  IIf( ValType(xMvRet) == "N", AllTrim(Str(xMvRet)), "" ) )
        nTam   := Len(MvPar)
	EndIf

    l1Elem := If (l1Elem = Nil , .F. , .T.)

    BeginSql alias _cMyAlias
		%noParser%
        SELECT E4_CODIGO, TRIM(E4_DESCRI)E4_DESCRI FROM SE4010 WITH(NOLOCK) WHERE D_E_L_E_T_ = ''
	
	EndSql

    While !(_cMyAlias)->(Eof())

        //Define as opções de retorno (conforme o aOpc acima)
        cRet += (_cMyAlias)->E4_CODIGO
        //Define as opções que serão exibidas
        aAdd(aOpc, (_cMyAlias)->E4_DESCRI)

        (_cMyAlias)->(DbSkip())
    EndDo

    (_cMyAlias)->(DbCloseARea())
 
    //Abre a tela para a seleção
    If F_Opcoes(@aRet       ,;    //uVarRet
                cTitulo     ,;    //cTitulo
                aOpc        ,;    //aOpcoes
                cRet        ,;    //cOpcoes
                12          ,;    //nLin1
                49          ,;    //nCol1
                l1Elem      ,;    //l1Elem
                3           ,;    //nTam
                999         ,;    //nElemRet
                .T.         ,;    //lMulti
                .F.          )    //lCBox
 
    EndIf
 
    FWRestArea(aArea)

    cRet := ArrTokStr(aRet, ";")
    oModMaster:SetValue("ZZG_COND",  SubStr(Alltrim(cRet),1, TamSx3("ZZG_COND")[1] ))
   oView:Refresh()
Return lTipoRet
