//Bibliotecas
    #Include "Totvs.ch"
    #Include "FWMVCDef.ch"
    #include 'protheus.ch'
    #include 'parmtype.ch'
 
//Variveis Estaticas
    Static cTitulo := "Contrato Veículos (Logistica)"
    Static cTabPai := "ZNL"
    Static cTabFilho := "ZNK"
    Static ENTER := Chr(13)+Chr(10)
 
/*/{Protheus.doc} User Function U_LMFTMS01()
@desc Contratos Logística
@author Luiz Moura
@since 20/06/2022
@version 1.0
@type function
/*/
 
User Function LMFTMS01()

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
    oBrowse:AddLegend( "ZNL->ZNL_SITUA = '1' .AND. Alltrim(ZNL->ZNL_NUMCON) = ''"   , "BLUE"    , "Pendente N° Contrato"   )
    oBrowse:AddLegend( "ZNL->ZNL_SITUA = '1' .AND. DATE()>ZNL->ZNL_DTVEN"           , "YELLOW"  , "Vencido"   )
    oBrowse:AddLegend( "ZNL->ZNL_SITUA = '1'"                                       , "GREEN"   , "Ativo"      )
    oBrowse:AddLegend( "ZNL->ZNL_SITUA = '2'"                                       , "RED"     , "Encerrado"  )

    //Ativa a Browse
    oBrowse:Activate()
    
    RestArea(aArea)
 
Return Nil
 
/*/{Protheus.doc} MenuDef()
@desc Menu de opcoes na funcao LMFTMS01
@author Luiz Moura
@since 20/06/2022
@version 1.0
@type function
/*/
 
Static Function MenuDef()
    Local aRotina := {}
 
    //Adicionando opcoes do menu
	aAdd( aRotina, {  "Visualizar"              ,"VIEWDEF.LMFTMS01"                         , 0, 1, 0, .T. } )
	aAdd( aRotina, {  "Incluir"                 ,"VIEWDEF.LMFTMS01"                         , 0, 3, 0, Nil } )
	aAdd( aRotina, {  "Alterar"                 ,"VIEWDEF.LMFTMS01"                         , 0, 4, 0, Nil } )
	aAdd( aRotina, {  "Excluir"                 ,"VIEWDEF.LMFTMS01"                         , 0, 5, 0, Nil } )
	aAdd( aRotina, {  "Conhecimento"            ,"MsDocument('ZNL',ZNL->(RecNo()), 4)"      , 0, 4, 0, Nil } )
	aAdd( aRotina, {  'Legenda' 	            ,"u_ZNLLEGEN"                               , 0, 6, 0, Nil } )
	aAdd( aRotina, {  'Novo Contrato Filho'     ,"U_COPYZNL()"                              , 0, 9, 0, Nil } )

Return aRotina
 
Static Function z02Menu()
Return MenuDef()
 
/*/{Protheus.doc} ModelDef()
@desc Modelo de dados na funcao LMFTMS01
@author Luiz Moura
@since 20/06/2022
@version 1.0
@type function
/*/
 
Static Function ModelDef()
    Local oStruPai := FWFormStruct(1, cTabPai, {|cCampo| !(AllTRim(cCampo) $ "ZNL_PLACAS")})
    Local oStruFilho := FWFormStruct(1, cTabFilho)
    Local oModel

    Local aRelationZNK := {}
    Local bPre := Nil
    Local bPos := {|oModel| bPost()}
    Local bCommit := Nil
    Local bCancel := Nil

    //Cria o modelo de dados para cadastro
    oModel := MPFormModel():New("LMTMS01O", bPre, bPos, bCommit, bCancel)
    oModel:AddFields("ZNLMASTER", /*cOwner*/, oStruPai)
    oModel:AddGrid("ZNKDETAIL","ZNLMASTER",oStruFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
    oModel:SetDescription(cTitulo)
    oModel:GetModel("ZNLMASTER"):SetDescription( "Dados de - " + cTitulo)
    oModel:GetModel("ZNKDETAIL"):SetDescription( "Grid de - " + cTitulo)
    oModel:SetPrimaryKey({'ZNL_FILIAL','ZNL_COD','ZNK_ITEM'})

    //Altera estrutura dos campos
    oStruPai:SetProperty("ZNL_TIP", MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'Iif(aScan(U_VLDX5ZNL("M->ZNL_TIP"),(M->ZNL_TIP)) = 0, .F., .T.)'))
    oStruPai:SetProperty("ZNL_SERVI", MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'Iif(aScan(U_VLDX5ZNL("M->ZNL_SERVI"),(M->ZNL_SERVI)) = 0, .F., .T.)'))
    oStruPai:SetProperty("ZNL_MESES", MODEL_FIELD_WHEN,{|| .F.})
    // oStruPai:SetProperty("ZNL_UNID", MODEL_FIELD_WHEN,{|| .F.})
    oStruPai:SetProperty("ZNL_CONPAI", MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,         'IIF(!(lCopia), .F., .T.)'))   

    //Fazendo o relacionamento
    aAdd(aRelationZNK, {"ZNK_FILIAL", "xFilial('ZNL')"})
    aAdd(aRelationZNK, {"ZNK_COD", "ZNL_COD"})
    oModel:SetRelation("ZNKDETAIL", aRelationZNK, ZNK->(IndexKey(1)))
     
    //Definindo campos unicos da linha
    oModel:GetModel("ZNKDETAIL"):SetUniqueLine({'ZNK_ITEM'})
 
Return oModel
 
/*/{Protheus.doc} ViewDef
@desc Visualizacao de dados na funcao LMFTMS01
@author Luiz Moura
@since 20/06/2022
@version 1.0
@type function
/*/
 
Static Function ViewDef()
    Local oModel := FWLoadModel("LMFTMS01")
    Local oStruPai := FWFormStruct(2, cTabPai, {|cCampo| !(AllTRim(cCampo) $ "ZNL_PLACAS")})
    Local oStruFilho := FWFormStruct(2, cTabFilho)
    Local oView
 
    //Cria a visualizacao do cadastro
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_ZNL", oStruPai, "ZNLMASTER")
    oView:AddGrid("GRID_ZNK",  oStruFilho,  "ZNKDETAIL")

    //Titulos das views
    oView:EnableTitleView("VIEW_ZNL", "Dados do contrato")
    oView:EnableTitleView("GRID_ZNK", "Veículos")
    
    //Partes da tela
    oView:CreateHorizontalBox("CABEC", 65)
    oView:CreateHorizontalBox("GRID", 35)
    oView:SetOwnerView("VIEW_ZNL", "CABEC")
    oView:SetOwnerView("GRID_ZNK", "GRID")
    oView:EnableControlBar(.T.)
 
    //Removendo campos
    oStruPai:RemoveField("ZNL_UNID")
    // oStruFilho:RemoveField("ZNK_FILIAL")
    oStruFilho:RemoveField("ZNK_COD")
 
    //Adicionando campo incremental na grid
    oView:AddIncrementField('GRID_ZNK', 'ZNK_ITEM')

    //Ativando o campo de pesquisar e ativando o botão de Filtrar
    oView:SetViewProperty("GRID_ZNK", "GRIDSEEK",    {.T.})
    oView:SetViewProperty("GRID_ZNK", "GRIDFILTER",  {.T.})
 
Return oView

/*/{Protheus.doc} U_ZNLLEGEN()
@desc Função de legenda
@type function
@author Luiz Moura
@since 20/06/2022
@version 1.0
/*/

User Function ZNLLEGEN()
    Local aLegenda := {}  
        aAdd(aLegenda,{"BR_AZUL"      ,"Pendente"       })  
        aAdd(aLegenda,{"BR_AMARELO"   ,"Vencido"        })  
        aAdd(aLegenda,{"BR_VERDE"     ,"Ativo"          })  
        aAdd(aLegenda,{"BR_VERMELHO"  ,"Encerrado"      })    
    BrwLegenda(cTitulo, "Status", aLegenda)
Return

/*/{Protheus.doc} VLDX5ZNL()
@desc Função para validar cmapos ZNL_SERVI, ZNL_TIP
@type function
@author Luiz Moura
@since 20/06/2022
@version 1.0
/*/

User Function VLDX5ZNL(cCampo)
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local aRet := {}

        cQuery += "SELECT TRIM(X5_DESCRI) X5_DESCRI FROM SX5010 WITH(NOLOCK) WHERE D_E_L_E_T_ = '' AND " + ENTER
        If cCampo == "M->ZNL_SERVI"
            cQuery += "X5_TABELA = 'ZA'"
        ElseIf cCampo == "M->ZNL_TIP"
            cQuery += "X5_TABELA = 'ZB'"
        EndIf

    MpSysOpenQuery(cQuery, cAlias)

    While (cAlias)->(!EOF())
       aAdd(aRet,(cAlias)->X5_DESCRI)
       (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(DbCloseArea())

Return aRet

/*/{Protheus.doc} bPost()
@desc Função chamada ao confirmar
@type function
@author Luiz Moura
@since 20/06/2022
@version 1.0
/*/

Static Function bPost()
    Local lRet          := .T.
    Local oModel        := FwModelActive()
    Local _dDtIni       := oModel:GetModel("ZNLMASTER"):GetValue("ZNL_DTINI")
    Local _dDtVen       := oModel:GetModel("ZNLMASTER"):GetValue("ZNL_DTVEN")
    Local _cConPai      := oModel:GetModel("ZNLMASTER"):GetValue("ZNL_CONPAI")
    Local _cCodFor      := oModel:GetModel("ZNLMASTER"):GetValue("ZNL_CODFOR")
    Local _cLojFor      := oModel:GetModel("ZNLMASTER"):GetValue("ZNL_LOJFOR")

    If lCopia .AND. ZNL->ZNL_NUMCON <> _cConPai
        Help("",1,"ATENÇÃO!",,"Para incluir um contrato filho não altere o contrato pai.", 1, 0,Nil,Nil,Nil,Nil,Nil,{"Contrato pai deve ser: "+ZNL->ZNL_NUMCON})
        lRet:= .F.
    EndIf
    If lCopia .AND. ZNL->ZNL_CODFOR <> _cCodFor
        Help("",1,"ATENÇÃO!",,"Para incluir um contrato filho não altere o fornecedor.", 1, 0,Nil,Nil,Nil,Nil,Nil,{"Cód Fornecedor deve ser: "+ZNL->ZNL_CODFOR})
        lRet:= .F.
    EndIf
    If lCopia .AND. ZNL->ZNL_LOJFOR <> _cLojFor
        Help("",1,"ATENÇÃO!",,"Para incluir um contrato filho não altere a loja do fornecedor.", 1, 0,Nil,Nil,Nil,Nil,Nil,{"Loja deve ser: "+ZNL->ZNL_LOJFOR})
        lRet:= .F.
    EndIf
    If _dDtIni < date() .AND. INCLUI
        Help("",1,"ATENÇÃO!",,"Você está inserindo contrato com data de início retroativa.", 1, 0,Nil,Nil,Nil,Nil,Nil,{""})
    EndIf
    If _dDtVen < _dDtIni 
        Help("",1,"ATENÇÃO!",,"Data de vencimento não pode ser menor que data de início.", 1, 0,Nil,Nil,Nil,Nil,Nil,{"Digite uma data de vencimento maior ou igual ao início"})
        lRet:= .F.
    EndIf
    
Return lRet

/*/{Protheus.doc} CopyZNL
@desc Função para cópia dos dados em MVC
@type function
@author Luiz Moura
@since 20/06/2022
@version 1.0
/*/
 
User Function COPYZNL()
    Local aArea        := GetArea()
    Local cPrograma    := "LMFTMS01"
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
    cCodCd := GetSXENum("ZNL", "ZNL_COD")
    ConfirmSX8()
     
    //Setando os campos do cabeçalho
    oModel:SetValue("ZNLMASTER", "ZNL_COD"      , cCodCd)
    oModel:SetValue("ZNLMASTER", "ZNL_CODFOR"   , AllTrim(ZNL->ZNL_CODFOR))
    oModel:SetValue("ZNLMASTER", "ZNL_LOJFOR"   , AllTrim(ZNL->ZNL_LOJFOR))
    oModel:SetValue("ZNLMASTER", "ZNL_RAZAO"    , AllTrim(ZNL->ZNL_RAZAO))
    oModel:SetValue("ZNLMASTER", "ZNL_RAZAO2"   , AllTrim(ZNL->ZNL_RAZAO2))
    oModel:SetValue("ZNLMASTER", "ZNL_ENT"      , "N")
    oModel:SetValue("ZNLMASTER", "ZNL_UNID"     , AllTrim(ZNL->ZNL_UNID))
    oModel:SetValue("ZNLMASTER", "ZNL_SITUA"    , "1")
    oModel:SetValue("ZNLMASTER", "ZNL_CONPAI"   , AllTrim(ZNL->ZNL_NUMCON))
    oModel:SetValue("ZNLMASTER", "ZNL_TIP"      , CriaVar("ZNL_TIP"))// Space(TamSx3("ZNL_TIP")[1]))
    oModel:SetValue("ZNLMASTER", "ZNL_NUMCON"   , CriaVar("ZNL_NUMCON"))//Space(TamSx3("ZNL_NUMCON")[1]))
    oModel:SetValue("ZNLMASTER", "ZNL_MATRES"   , CriaVar("ZNL_MATRES"))// Space(TamSx3("ZNL_MATRES")[1]))
    oModel:SetValue("ZNLMASTER", "ZNL_RESP"     , CriaVar("ZNL_RESP"))// Space(TamSx3("ZNL_RESP")[1]))
    oModel:SetValue("ZNLMASTER", "ZNL_DTINI"    , CriaVar("ZNL_DTINI"))
    oModel:SetValue("ZNLMASTER", "ZNL_DTVEN"    , CriaVar("ZNL_DTVEN"))
    oModel:SetValue("ZNLMASTER", "ZNL_MESES"    , CriaVar("ZNL_MESES"))// Space(TamSx3("ZNL_MESES")[1]))
    oModel:SetValue("ZNLMASTER", "ZNL_OBS"      , CriaVar("ZNL_OBS"))// Space(TamSx3("ZNL_OBS")[1]))
    oModel:SetValue("ZNLMASTER", "ZNL_GLPI"     , CriaVar("ZNL_GLPI"))// Space(TamSx3("ZNL_GLPI")[1]))
    oModel:SetValue("ZNLMASTER", "ZNL_SERVI"    , CriaVar("ZNL_SERVI"))// Space(TamSx3("ZNL_SERVI")[1]))
     
    //Pegando os dados do filho
    oModelGriA := oModel:GetModel("ZNKDETAIL")
    oStruuct    := oModelGriA:GetStruct()
    aCampos    := oStruuct:GetFields()
     
    //Se não for P12, pega do aCols, senão pega do aDataModel
    nTamanGrid := Iif(GetVersao(.F.) < "12", Len(oModelGriA:aCols), Len(oModelGriA:aDataModel))
     
    //Zerando os campos da grid
    For nLin := 1 To nTamanGrid
     
        //Setando a linha atual
        oModelGriA:SetLine(nLin)
         
        //Percorrendo as colunas
        For nCol := 1 To Len(aCampos)
         
        Next nCol
    Next nLin
    oModelGriA:SetLine(1)  
     
    //Executando a visualização dos dados para manipulação
    nRet     := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
    oModel:DeActivate()
     
    RestArea(aArea)
    lCopia := .F.
Return oModel

/*/{Protheus.doc} User Function FTMSREL
Define tabelas customizadas que podem utilizar o banco de conhecimento padrão
@type  Function
@author Luiz Moura
@since 20/06/2022
@see https://tdn.totvs.com/display/public/framework/FTMSREL
/*/
 
User Function FTMSREL()
    Local aArea    := FWGetArea()
    Local aRetorno := {}
 
    aAdd(aRetorno, {;
        "ZNL",;                               //Alias da Tabela
        {"ZNL_FILIAL", "ZNL_COD"},;           //Campos usados na chave
        {|| ZNL->ZNL_FILIAL + ZNL->ZNL_COD};  //Chave usada
    })
 
    FWRestArea(aArea)
Return aRetorno


/*/{Protheus.doc} ZNLBRW()
@desc Retorna string com array de ZNK para exibição no browse (X3_INIBRW)
@param cFil  (opcional) Filial do ZNL
@param cCod  (opcional) Código do ZNL
@param cP    (opcional) Campo da ZNK para retornar
@return String com placas separadas por ", "
*/
User Function ZNLBRW( _cCampo )
    Local aArea := GetArea()
    Local aResultados := {}
    Local cResultados := ""
    Local _cFilial := Alltrim(ZNL->ZNL_FILIAL)
    Local _cCodigo := Alltrim(ZNL->ZNL_COD)
    Local n := 0

    If !Empty(_cFilial) .And. !Empty(_cCodigo)
        DbSelectArea("ZNK")
        If ZNK->(ColumnPos( _cCampo )) > 0
            ZNK->(DbSetOrder(1))
            ZNK->(DbGoTop())
            If ZNK->(DbSeek( _cFilial + _cCodigo  ))
                Do While ZNK->(!EOF()) .And. AllTrim(ZNK->ZNK_FILIAL) == _cFilial .And. AllTrim(ZNK->ZNK_COD) == _cCodigo
                    If _cCampo = "ZNK_PLACA"
                        If !Empty(ZNK->ZNK_PLACA) .And. aScan(aResultados, ZNK->ZNK_PLACA ) == 0
                            aAdd(aResultados, ZNK->ZNK_PLACA )
                        EndIf
                        ZNK->(DbSkip())
                    ElseIf _cCampo = "ZNK_FROTA"
                        If !Empty(ZNK->ZNK_FROTA) .And. aScan(aResultados, ZNK->ZNK_FROTA ) == 0
                            aAdd(aResultados, ZNK->ZNK_FROTA )
                        EndIf
                        ZNK->(DbSkip())
                    EndIf
                EndDo
            EndIf
        Endif
    EndIf

    // monta string
    For n := 1 To Len(aResultados)
        If n == 1
            cResultados := aResultados[n]
        Else
            cResultados += ", " + aResultados[n]
        EndIf
    Next n

    RestArea(aArea)

Return Left(cResultados, 200)



User Function ZCADZNL()
    Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
    Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

    Private cString := "ZNL"

    dbSelectArea("ZNL")
    dbSetOrder(1)

    AxCadastro(cString,"Cadastro de ZNL",cVldExc,cVldAlt)

Return
