#Include "Totvs.ch"
#include "rwmake.ch"
#INCLUDE 'FWMVCDef.ch'
#include 'PROTHEUS.CH'
#Include 'topconn.ch'

Static cTitulo := "Contrato Veículos (Logistica)"
Static cTab := "ZNL"
Static ENTER := Chr(13)+Chr(10)

User Function LMFTMS01() 

    Local oBrowse
    Local aArea   := GetArea()

    Private aRotina := {}
    Private lCopia := .F.

    //Definicao do menu
    aRotina := MenuDef()

    //Instanciando o browse
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cTab)
    oBrowse:SetDescription(cTitulo)

    // //legenda - STATUS
    oBrowse:AddLegend( "ZNL->ZNL_SITUA = '1' .AND. Alltrim(ZNL->ZNL_NUMCON) = ''"   , "BLUE"    , "Pendente N° Minuta"   )
    oBrowse:AddLegend( "ZNL->ZNL_SITUA = '1' .AND. DATE()>ZNL->ZNL_DTVEN"           , "YELLOW"  , "Vencido"   )
    oBrowse:AddLegend( "ZNL->ZNL_SITUA = '1'"                                       , "GREEN"   , "Ativo"      )
    oBrowse:AddLegend( "ZNL->ZNL_SITUA = '2'"                                       , "RED"     , "Encerrado"  )

    //Ativa a Browse
    oBrowse:Activate()
    
    RestArea(aArea)

Return 


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
 
Static Function ModelDef()
    //Na montagem da estrutura do Modelo de dados, o cabeçalho filtrará e exibirá somente alguns campos, já a grid irá carregar a estrutura inteira conforme função fModStruct
    Local oModel      := NIL
    Local oStruCab    := FWFormStruct(1, 'ZNL', {|cCampo| AllTRim(cCampo) $ "ZNL_FILIAL,ZNL_COD,ZNL_CODFOR,ZNL_LOJFOR,ZNL_RAZAO,ZNL_RAZAO2,ZNL_NUMCON,ZNL_GLPI,ZNL_ENT,ZNL_TIP,ZNL_MATRES,ZNL_RESP,ZNL_SERVI,ZNL_DTINI,ZNL_DTVEN,ZNL_MESES,ZNL_SITUA,ZNL_OBS,ZNL_CONPAI"})
    Local oStruGrid   := FWFormStruct(1, 'ZNL', {|cCampo| AllTrim(cCampo) $ "ZNL_ITEM,ZNL_PLACA,ZNL_CHASSI,ZNL_RENAVA,ZNL_MARMOD,ZNL_ANOFAB,ZNL_FROTA,ZNL_VALMEN,ZNL_LIMKM,ZNL_VLKMEX,ZNL_CONDUT,ZNL_ID,ZNL_DTDEVO"})
    Local bPre := Nil
    Local bPos := {|oModel| bPost()}
    Local bCommit := Nil
    Local bCancel := Nil

    oModel := MPFormModel():New('CADZNLM', bPre, bPos, bCommit , bCancel )
    //Agora, define no modelo de dados, que terá um Cabeçalho e uma Grid apontando para estruturas acima
    oModel:AddFields('MdFieldZNL', NIL, oStruCab)
    oModel:AddGrid('MdGridZNL', 'MdFieldZNL', oStruGrid, , )  

    //Monta o relacionamento entre Grid e Cabeçalho, as expressões da Esquerda representam o campo da Grid e da direita do Cabeçalho
    oModel:SetRelation('MdGridZNL', {;
            {'ZNL_FILIAL', 'xFilial("ZNL")'},;
            {'ZNL_COD', 'ZNL_COD'};
        }, ZNL->(IndexKey(1)))

    //Definindo outras informações do Modelo e da Grid
    oModel:GetModel("MdGridZNL"):SetMaxLine(9999)
    oModel:SetDescription(cTitulo)
    
    oModel:SetPrimaryKey({'ZNL_FILIAL','ZNL_COD','ZNL_ITEM'})
    oModel:GetModel("MdGridZNL"):SetUniqueLine({'ZNL_ITEM'})

    //Altera estrutura dos campos
    oStruCab:SetProperty("ZNL_TIP", MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'Iif(aScan(U_VLDX5ZNL("M->ZNL_TIP"),(M->ZNL_TIP)) = 0, .F., .T.)'))
    oStruCab:SetProperty("ZNL_SERVI", MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'Iif(aScan(U_VLDX5ZNL("M->ZNL_SERVI"),(M->ZNL_SERVI)) = 0, .F., .T.)'))
    oStruCab:SetProperty("ZNL_MESES", MODEL_FIELD_WHEN,{|| .F.})
    // oStruCab:SetProperty("ZNL_UNID", MODEL_FIELD_WHEN,{|| .F.})
    oStruCab:SetProperty("ZNL_CONPAI", MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,         'IIF(!(lCopia), .F., .T.)'))        
    //Definindo campos unicos da linha
 
Return oModel
 
Static Function ViewDef()
    //Na montagem da estrutura da visualização de dados, vamos chamar o modelo criado anteriormente, no cabeçalho vamos mostrar somente 3 campos, e na grid vamos carregar conforme a função fViewStruct
    Local oView        := NIL
    Local oModel    := FWLoadModel('LMFTMS01')
    Local oStruCab  := FWFormStruct(2, "ZNL", {|cCampo| AllTRim(cCampo) $ "ZNL_FILIAL,ZNL_COD,ZNL_CODFOR,ZNL_LOJFOR,ZNL_RAZAO,ZNL_RAZAO2,ZNL_NUMCON,ZNL_GLPI,ZNL_ENT,ZNL_TIP,ZNL_MATRES,ZNL_RESP,ZNL_SERVI,ZNL_DTINI,ZNL_DTVEN,ZNL_MESES,ZNL_SITUA,ZNL_OBS,ZNL_CONPAI"})
    Local oStruGRID := FWFormStruct(2, "ZNL", {|cCampo| AllTRim(cCampo) $ "ZNL_ITEM,ZNL_PLACA,ZNL_CHASSI,ZNL_RENAVA,ZNL_MARMOD,ZNL_ANOFAB,ZNL_FROTA,ZNL_VALMEN,ZNL_LIMKM,ZNL_VLKMEX,ZNL_CONDUT,ZNL_ID,ZNL_DTDEVO"})
 
    // oStruCab:RemoveField("ZNL_DATINC")
    	
    //Define que o cabeçalho não terá abas
    oStruCab:SetNoFolder()

    oStruGRID:RemoveField("ZNL_FILIAL") 
    oStruGRID:RemoveField("ZNL_COD") 

    //Cria o View
    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
 
    //Cria uma área de Field vinculando a estrutura do cabeçalho com MDFieldZNL, e uma Grid vinculando com MdGridZNL
    oView:AddField('VIEW_ZNL', oStruCab, 'MdFieldZNL')
    oView:AddGrid('GRID_ZNL', oStruGRID, 'MdGridZNL' )
 
    //O cabeçalho (MAIN) terá 10% de tamanho, e o restante de 90% irá para a GRID
    oView:CreateHorizontalBox("MAIN", 80)
    oView:CreateHorizontalBox("GRID", 20)
 
    //Vincula o MAIN com a VIEW_ZNL e a GRID com a GRID_ZNL
    oView:SetOwnerView('VIEW_ZNL', 'MAIN')
    oView:SetOwnerView('GRID_ZNL', 'GRID')
    oView:EnableControlBar(.T.)
 
    //Define o campo incremental da grid como o ZNL_ITEM
    oView:AddIncrementField('GRID_ZNL', 'ZNL_ITEM')

// função para atualizar a descrição quando da inclusão.
    oView:SetAfterViewActivate({|oView| _IniCpos(oView)} ) 
Return oView
 
//Função chamada para montar o modelo de dados da Grid
Static Function fModStruct()
    Local oStruct
    oStruct := FWFormStruct(1, 'ZNL')
Return oStruct
 
//Função chamada para montar a visualização de dados da Grid
Static Function fViewStruct()
    Local oStruct
    oStruct := FWFormStruct(2, "ZNL")
Return oStruct

Static Function fCommit(oModel)
    Local lRet := .T.

    FWFormCommit( oModel )

Return lRet


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
    Local _dDtIni       := oModel:GetModel("MdFieldZNL"):GetValue("ZNL_DTINI")
    Local _dDtVen       := oModel:GetModel("MdFieldZNL"):GetValue("ZNL_DTVEN")
    Local _cConPai      := oModel:GetModel("MdFieldZNL"):GetValue("ZNL_CONPAI")
    Local _cCodFor      := oModel:GetModel("MdFieldZNL"):GetValue("ZNL_CODFOR")
    Local _cLojFor      := oModel:GetModel("MdFieldZNL"):GetValue("ZNL_LOJFOR")

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
    oModel:SetValue("MdFieldZNL", "ZNL_COD"      , cCodCd)
    oModel:SetValue("MdFieldZNL", "ZNL_CODFOR"   , AllTrim(ZNL->ZNL_CODFOR))
    oModel:SetValue("MdFieldZNL", "ZNL_LOJFOR"   , AllTrim(ZNL->ZNL_LOJFOR))
    oModel:SetValue("MdFieldZNL", "ZNL_RAZAO"    , AllTrim(ZNL->ZNL_RAZAO))
    oModel:SetValue("MdFieldZNL", "ZNL_RAZAO2"   , AllTrim(ZNL->ZNL_RAZAO2))
    oModel:SetValue("MdFieldZNL", "ZNL_ENT"      , "N")
    oModel:SetValue("MdFieldZNL", "ZNL_SITUA"    , "1")
    oModel:SetValue("MdFieldZNL", "ZNL_CONPAI"   , AllTrim(ZNL->ZNL_NUMCON))
    oModel:SetValue("MdFieldZNL", "ZNL_TIP"      , CriaVar("ZNL_TIP"))// Space(TamSx3("ZNL_TIP")[1]))
    oModel:SetValue("MdFieldZNL", "ZNL_NUMCON"   , CriaVar("ZNL_NUMCON"))//Space(TamSx3("ZNL_NUMCON")[1]))
    oModel:SetValue("MdFieldZNL", "ZNL_MATRES"   , CriaVar("ZNL_MATRES"))// Space(TamSx3("ZNL_MATRES")[1]))
    oModel:SetValue("MdFieldZNL", "ZNL_RESP"     , CriaVar("ZNL_RESP"))// Space(TamSx3("ZNL_RESP")[1]))
    oModel:SetValue("MdFieldZNL", "ZNL_DTINI"    , CriaVar("ZNL_DTINI"))
    oModel:SetValue("MdFieldZNL", "ZNL_DTVEN"    , CriaVar("ZNL_DTVEN"))
    oModel:SetValue("MdFieldZNL", "ZNL_MESES"    , CriaVar("ZNL_MESES"))// Space(TamSx3("ZNL_MESES")[1]))
    oModel:SetValue("MdFieldZNL", "ZNL_OBS"      , CriaVar("ZNL_OBS"))// Space(TamSx3("ZNL_OBS")[1]))
    oModel:SetValue("MdFieldZNL", "ZNL_GLPI"     , CriaVar("ZNL_GLPI"))// Space(TamSx3("ZNL_GLPI")[1]))
    oModel:SetValue("MdFieldZNL", "ZNL_SERVI"    , CriaVar("ZNL_SERVI"))// Space(TamSx3("ZNL_SERVI")[1]))
     
    //Pegando os dados do filho
    oModelGrid := oModel:GetModel("MdGridZNL")
    oStruuct    := oModelGrid:GetStruct()
    aCampos    := oStruuct:GetFields()
     
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

Static Function _IniCpos(oView)

    Local nOperation := oView:GetOperation() 
    Local oModel := FWModelActive() 
    Local oModelZNL := oModel:GetModel("MdFieldZNL")
    Local oMoGridZNL := oModel:GetModel("MdGridZNL")

    If nOperation == 3
        oView:Refresh()
    EndIf


Return
