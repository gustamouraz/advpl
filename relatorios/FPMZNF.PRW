//Bibliotecas
    #Include "Totvs.ch"
    #Include "FWMVCDef.ch"
    #include 'protheus.ch'
    #include 'parmtype.ch'
 
//Variveis Estaticas
    Static cTitulo := "Contrato (Logistica)"
    Static cTabPai := "ZNF"
    Static cTabFilho := "ZNJ"
    Static ENTER := Chr(13)+Chr(10)
 
/*/{Protheus.doc} User Function U_FPMZNF()
@desc Contratos Logística
@author Luiz Moura
@since 20/06/2022
@version 1.0
@type function
/*/
 
User Function FPMZNF()

    Local oBrowse
    Local aArea   := GetArea()

    Private aRotina := {}
    Private lCopia := .F.

    //Definicao do menu
    aRotina := MenuDef()

    //Instanciando o browse
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cTabPai)
    oBrowse:SetDescription(cTitulo)

    // //legenda - STATUS
    oBrowse:AddLegend( "ZNF->ZNF_SITUA = '1' .AND. Alltrim(ZNF->ZNF_NUMCON) = ''"   , "BLUE"    , "Pendente N° Contrato"   )
    oBrowse:AddLegend( "ZNF->ZNF_SITUA = '1' .AND. DATE()>ZNF->ZNF_DTVEN"           , "YELLOW"  , "Vencido"   )
    oBrowse:AddLegend( "ZNF->ZNF_SITUA = '1'"                                       , "GREEN"   , "Ativo"      )
    oBrowse:AddLegend( "ZNF->ZNF_SITUA = '2'"                                       , "RED"     , "Encerrado"  )

    //Ativa a Browse
    oBrowse:Activate()
    
    RestArea(aArea)
 
Return Nil
 
/*/{Protheus.doc} MenuDef()
@desc Menu de opcoes na funcao FPMZNF
@author Luiz Moura
@since 20/06/2022
@version 1.0
@type function
/*/
 
Static Function MenuDef()
    Local aRotina := {}
 
    //Adicionando opcoes do menu
    ADD OPTION aRotina TITLE "Visualizar"           ACTION "VIEWDEF.FPMZNF"  OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"              ACTION "VIEWDEF.FPMZNF"  OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"              ACTION "VIEWDEF.FPMZNF"  OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"              ACTION "VIEWDEF.FPMZNF"  OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE 'Legenda'              ACTION 'u_ZNFLEGEN'      OPERATION 6 ACCESS 0 
    ADD OPTION aRotina TITLE 'Novo Contrato Filho'  ACTION "U_COPYZNF()"     OPERATION 9 ACCESS 0 

Return aRotina
 
Static Function z02Menu()
Return MenuDef()
 
/*/{Protheus.doc} ModelDef()
@desc Modelo de dados na funcao FPMZNF
@author Luiz Moura
@since 20/06/2022
@version 1.0
@type function
/*/
 
Static Function ModelDef()
    Local oStruPai := FWFormStruct(1, cTabPai)
    Local oStruFilho := FWFormStruct(1, cTabFilho)
    Local oModel

    Local aRelation := {}
    Local bPre := Nil
    Local bPos := {|oModel| U_bPost()}
    Local bCommit := Nil
    Local bCancel := Nil
 
    //Cria o modelo de dados para cadastro
    oModel := MPFormModel():New("FPMZNFO", bPre, bPos, bCommit, bCancel)
    oModel:AddFields("ZNFMASTER", /*cOwner*/, oStruPai)
    oModel:AddGrid("ZNJDETAIL","ZNFMASTER",oStruFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
    oModel:SetDescription(cTitulo)
    oModel:GetModel("ZNFMASTER"):SetDescription( "Dados de - " + cTitulo)
    oModel:GetModel("ZNJDETAIL"):SetDescription( "Grid de - " + cTitulo)
    oModel:SetPrimaryKey({'ZNF_FILIAL','ZNF_COD','ZNJ_ITEM'})

    //Altera estrutura dos campos
    oStruPai:SetProperty("ZNF_TIP", MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'Iif(aScan(U_VldX5Cmp("M->ZNF_TIP"),(M->ZNF_TIP)) = 0, .F., .T.)'))
    oStruPai:SetProperty("ZNF_SERVI", MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'Iif(aScan(U_VldX5Cmp("M->ZNF_SERVI"),(M->ZNF_SERVI)) = 0, .F., .T.)'))
    oStruPai:SetProperty("ZNF_DIARIA", MODEL_FIELD_WHEN,{|| .F.})
    // oStruPai:SetProperty("ZNF_UNID", MODEL_FIELD_WHEN,{|| .F.})
    oStruPai:SetProperty("ZNF_CONPAI", MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,         'IIF(!(lCopia), .F., .T.)'))   
    oStruFilho:SetProperty("ZNJ_TIPVEI", MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'Iif(aScan(U_VldX5Cmp("M->ZNJ_TIPVEI"),(M->ZNJ_TIPVEI)) = 0, .F., .T.)'))

    //Fazendo o relacionamento
    aAdd(aRelation, {"ZNJ_FILIAL", "xFilial('ZNF')"})
    aAdd(aRelation, {"ZNJ_COD", "ZNF_COD"})
    oModel:SetRelation("ZNJDETAIL", aRelation, ZNJ->(IndexKey(1)))
     
    //Definindo campos unicos da linha
    oModel:GetModel("ZNJDETAIL"):SetUniqueLine({'ZNJ_ITEM'})
 
Return oModel
 
/*/{Protheus.doc} ViewDef
@desc Visualizacao de dados na funcao FPMZNF
@author Luiz Moura
@since 20/06/2022
@version 1.0
@type function
/*/
 
Static Function ViewDef()
    Local oModel := FWLoadModel("FPMZNF")
    Local oStruPai := FWFormStruct(2, cTabPai)
    Local oStruFilho := FWFormStruct(2, cTabFilho)
    Local oView
 
    //Cria a visualizacao do cadastro
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_ZNF", oStruPai, "ZNFMASTER")
    oView:AddGrid("GRID_ZNJ",  oStruFilho,  "ZNJDETAIL")
 
    //Partes da tela
    oView:CreateHorizontalBox("CABEC", 65)
    oView:CreateHorizontalBox("GRID", 35)
    oView:SetOwnerView("VIEW_ZNF", "CABEC")
    oView:SetOwnerView("GRID_ZNJ", "GRID")
    oView:EnableControlBar(.T.)

    //Titulos
    oView:EnableTitleView("VIEW_ZNF", "Dados do contrato")
    oView:EnableTitleView("GRID_ZNJ", "Veículos")
 
    //Removendo campos
    oStruPai:RemoveField("ZNF_UNID")
    // oStruFilho:RemoveField("ZNJ_FILIAL")
    oStruFilho:RemoveField("ZNJ_COD")
 
    //Adicionando campo incremental na grid
    oView:AddIncrementField('GRID_ZNJ', 'ZNJ_ITEM')
 
    //Ativando o campo de pesquisar e ativando o botão de Filtrar
    oView:SetViewProperty("GRID_ZNJ", "GRIDSEEK",    {.T.})
    oView:SetViewProperty("GRID_ZNJ", "GRIDFILTER",  {.T.})
 
Return oView

/*/{Protheus.doc} U_ZNFLEGEN()
@desc Função de legenda
@type function
@author Luiz Moura
@since 20/06/2022
@version 1.0
/*/

User Function ZNFLEGEN()
    Local aLegenda := {}  
        aAdd(aLegenda,{"BR_AZUL"      ,"Pendente"       })  
        aAdd(aLegenda,{"BR_AMARELO"   ,"Vencido"        })  
        aAdd(aLegenda,{"BR_VERDE"     ,"Ativo"          })  
        aAdd(aLegenda,{"BR_VERMELHO"  ,"Encerrado"      })    
    BrwLegenda(cTitulo, "Status", aLegenda)
Return

/*/{Protheus.doc} U_VldX5Cmp()
@desc Função para validar cmapos ZNF_SERVI, ZNF_TIP, ZNJ_TIPVEI
@type function
@author Luiz Moura
@since 20/06/2022
@version 1.0
/*/

User Function VldX5Cmp(cCampo)
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local aRet := {}

        cQuery += "SELECT TRIM(X5_DESCRI) X5_DESCRI FROM SX5010 WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND " + ENTER
        If cCampo == "M->ZNF_SERVI"
            cQuery += "X5_TABELA = 'ZA'"
        ElseIf cCampo == "M->ZNJ_TIPVEI"
            cQuery += "X5_TABELA = 'ZC'"
        ElseIf cCampo == "M->ZNF_TIP"
            cQuery += "X5_TABELA = 'ZB'"
        EndIf

    MpSysOpenQuery(cQuery, cAlias)

    While (cAlias)->(!EOF())
       aAdd(aRet,(cAlias)->X5_DESCRI)
       (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(DbCloseArea())

Return aRet

/*/{Protheus.doc} U_bPost()
@desc Função chamada ao confirmar
@type function
@author Luiz Moura
@since 20/06/2022
@version 1.0
/*/

User Function bPost()
    Local lRet          := .T.
    Local oModel        := FwModelActive()
    Local _dDtIni       := oModel:GetModel("ZNFMASTER"):GetValue("ZNF_DTINI")
    Local _dDtVen       := oModel:GetModel("ZNFMASTER"):GetValue("ZNF_DTVEN")
    Local _cConPai      := oModel:GetModel("ZNFMASTER"):GetValue("ZNF_CONPAI")
    Local _cCodFor      := oModel:GetModel("ZNFMASTER"):GetValue("ZNF_CODFOR")
    Local _cLojFor      := oModel:GetModel("ZNFMASTER"):GetValue("ZNF_LOJFOR")

    If lCopia .AND. ZNF->ZNF_NUMCON <> _cConPai
        Help("",1,"ATENÇÃO!",,"Para incluir um contrato filho não altere o contrato pai.", 1, 0,Nil,Nil,Nil,Nil,Nil,{"Contrato pai deve ser: "+ZNF->ZNF_NUMCON})
        lRet:= .F.
    EndIf
    If lCopia .AND. ZNF->ZNF_CODFOR <> _cCodFor
        Help("",1,"ATENÇÃO!",,"Para incluir um contrato filho não altere o fornecedor.", 1, 0,Nil,Nil,Nil,Nil,Nil,{"Cód Fornecedor deve ser: "+ZNF->ZNF_CODFOR})
        lRet:= .F.
    EndIf
    If lCopia .AND. ZNF->ZNF_LOJFOR <> _cLojFor
        Help("",1,"ATENÇÃO!",,"Para incluir um contrato filho não altere a loja do fornecedor.", 1, 0,Nil,Nil,Nil,Nil,Nil,{"Loja deve ser: "+ZNF->ZNF_LOJFOR})
        lRet:= .F.
    EndIf
    If _dDtIni < date() .AND. INCLUI
        Help("",1,"ATENÇÃO!",,"Você está inserindo contrato com data de início retroativa.", 1, 0,Nil,Nil,Nil,Nil,Nil,{""})
    EndIf
    If _dDtVen < _dDtIni 
        Help("",1,"ATENÇÃO!",,"Data de vencimento não pode ser menor que data de início.", 1, 0,Nil,Nil,Nil,Nil,Nil,{"Digite uma data de vencimento maior ou igual ao início"})
        lRet:= .F.
    EndIf
    If ALTERA
        If MsgYesNo("Deseja alterar as filiais?","FPMZNF")
            GetFils()
        EndIf
    ElseIf INCLUI .AND. !(lCopia)
 
        GetFils()
    EndIf
    
Return lRet

/*/{Protheus.doc} CopyZNF
@desc Função para cópia dos dados em MVC
@type function
@author Luiz Moura
@since 20/06/2022
@version 1.0
/*/
 
User Function COPYZNF()
    Local aArea        := GetArea()
    Local cPrograma    := "FPMZNF"
    Local nOperation   := MODEL_OPERATION_INSERT
    Local nLin         := 0
    Local nCol         := 0
    Local nTamanGrid   := 0
    Local oModel
    //Caso precise testar em algum lugar
    lCopia     := .T.
     
    //Carrega o modelo de dados
    oModel := FWLoadModel(cPrograma)
    oModel:DeActivate() 
    oModel:SetOperation(nOperation) // Inclusão
    oModel:Activate(.T.) // Ativa o modelo com os dados posicionados
     
    //Pegando o campo de chave
    cCodCd := GetSXENum("ZNF", "ZNF_COD")
    ConfirmSX8()
     
    //Setando os campos do cabeçalho
    oModel:SetValue("ZNFMASTER", "ZNF_COD"      , cCodCd)
    oModel:SetValue("ZNFMASTER", "ZNF_CODFOR"   , AllTrim(ZNF->ZNF_CODFOR))
    oModel:SetValue("ZNFMASTER", "ZNF_LOJFOR"   , AllTrim(ZNF->ZNF_LOJFOR))
    oModel:SetValue("ZNFMASTER", "ZNF_RAZAO"    , AllTrim(ZNF->ZNF_RAZAO))
    oModel:SetValue("ZNFMASTER", "ZNF_RAZAO2"   , AllTrim(ZNF->ZNF_RAZAO2))
    oModel:SetValue("ZNFMASTER", "ZNF_ENT"      , "N")
    oModel:SetValue("ZNFMASTER", "ZNF_UNID"     , AllTrim(ZNF->ZNF_UNID))
    oModel:SetValue("ZNFMASTER", "ZNF_SITUA"    , "1")
    oModel:SetValue("ZNFMASTER", "ZNF_CONPAI"   , AllTrim(ZNF->ZNF_NUMCON))
    oModel:SetValue("ZNFMASTER", "ZNF_GATCOM"   , AllTrim(ZNF->ZNF_GATCOM))
    oModel:SetValue("ZNFMASTER", "ZNF_TIP"      , CriaVar("ZNF_TIP"))// Space(TamSx3("ZNF_TIP")[1]))
    oModel:SetValue("ZNFMASTER", "ZNF_NUMCON"   , CriaVar("ZNF_NUMCON"))//Space(TamSx3("ZNF_NUMCON")[1]))
    oModel:SetValue("ZNFMASTER", "ZNF_MATRES"   , CriaVar("ZNF_MATRES"))// Space(TamSx3("ZNF_MATRES")[1]))
    oModel:SetValue("ZNFMASTER", "ZNF_RESP"     , CriaVar("ZNF_RESP"))// Space(TamSx3("ZNF_RESP")[1]))
    oModel:SetValue("ZNFMASTER", "ZNF_DTINI"    , CriaVar("ZNF_DTINI"))
    oModel:SetValue("ZNFMASTER", "ZNF_DTVEN"    , CriaVar("ZNF_DTVEN"))
    oModel:SetValue("ZNFMASTER", "ZNF_DIARIA"   , CriaVar("ZNF_DIARIA"))// Space(TamSx3("ZNF_DIARIA")[1]))
    oModel:SetValue("ZNFMASTER", "ZNF_OBS"      , CriaVar("ZNF_OBS"))// Space(TamSx3("ZNF_OBS")[1]))
    oModel:SetValue("ZNFMASTER", "ZNF_GLPI"     , CriaVar("ZNF_GLPI"))// Space(TamSx3("ZNF_GLPI")[1]))
    oModel:SetValue("ZNFMASTER", "ZNF_SERVI"    , CriaVar("ZNF_SERVI"))// Space(TamSx3("ZNF_SERVI")[1]))
     
    //Pegando os dados do filho
    oModelGrid := oModel:GetModel("ZNJDETAIL")
    oStruct    := oModelGrid:GetStruct()
    aCampos    := oStruct:GetFields()
     
    //Se não for P12, pega do aCols, senão pega do aDataModel
    nTamanGrid := Iif(GetVersao(.F.) < "12", Len(oModelGrid:aCols), Len(oModelGrid:aDataModel))
     
    //Zerando os campos da grid
    For nLin := 1 To nTamanGrid
     
        //Setando a linha atual
        oModelGrid:SetLine(nLin)
         
        //Percorrendo as colunas
        For nCol := 1 To Len(aCampos)
         
        Next nCol
    Next nLin
    oModelGrid:SetLine(1)  
     
    //Executando a visualização dos dados para manipulação
    nRet     := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
    oModel:DeActivate()
     
    RestArea(aArea)
    lCopia := .F.
Return oModel

/*/{Protheus.doc} GetFils()
@desc Função que grava campo ZNF_UNID
@type function
@author Luiz Moura
@since 20/06/2022
@version 1.0
/*/

Static Function GetFils()
    
    Local lRPC          := .F.
    Local cFiliais      := ""    
	Local aFiliais      := {}
    Local oModel        := FwModelActive()
    Local oFieldZNF       := oModel:GetModel("ZNFMASTER")
    
    aFiliais      := AdmGetFil(.F.,.F.)
    If Select("SX2") == 0
        RpcClearEnv()
        RPCSetType(3)
        If(!RpcSetEnv("01", "010101", "", "", "COM",,{"SF1"}))
            Return(Nil)
        EndIf
        lRPC := .T.
    EndIf
    If Len(aFiliais) > 0
        cFiliais := AsString(aFiliais)
        cFiliais := StrTran(cFiliais,"{","")
        cFiliais := StrTran(cFiliais,"}","")
        cFiliais := StrTran(cFiliais,"'","")
        cFiliais := StrTran(cFiliais,",",";")
        lRet := .T. 
        If !(oFieldZNF:SetValue("ZNF_UNID",  Left(cFiliais,TamSX3("ZNF_UNID")[1])   ))
            Help("",1,"ATENÇÃO!",,"Não foi possível gravar a(s) filial(is)", 1, 0,Nil,Nil,Nil,Nil,Nil,{"Entre em contato com o administrador."})
            lRet := .F. 
        EndIf
    Else         
        Help(" ",1,"SELFIL",,"Selecione a filial para consulta", 1, 0 )
    EndIf
Return
