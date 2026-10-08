#Include "Totvs.ch"
#include "rwmake.ch"
#INCLUDE 'FWMVCDef.ch'
#include 'PROTHEUS.CH'
#Include 'topconn.ch'
 //PROJETO CD - 2024
Static cTitulo := "Atendimento CD"

User Function ACMVCZGQ() 

    Local aArea   := GetArea()
    Local oBrowse
	Local _cFiltro := ""

    Private _cProdDe := ''
    Private _cProdAt := 'ZZZZZZZZ'
    Private _cPendente := 'S'

    Private _cMVPAR01 := "1"
    Private _cMVPAR02 :=Space(TamSx3("B1_COD")[1])
    Private _cMVPAR03 := "ZZZZZZZZZZ"
    Private _cMVPAR04 := "1"
    Private _cMVPAR05 := dDatabase - 30
    Private _cMVPAR06 := dDatabase + 30  
    Private _cMVPAR07 := "      "  
    Private _cMVPAR08 := "ZZZZZZ"
    
    Private _cMVPAR09 := "      "  
    Private _cMVPAR10 := "ZZZZZZ"

    Private _cArmazem := ''


    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZGM")
    oBrowse:SetDescription(cTitulo)

	_cFiltro += " ZGM_REGTIT = 'S'  "
	
	oBrowse:SetFilterDefault( "@"  + _cFiltro )  
    oBrowse:Activate()
      
    RestArea(aArea)


Return 


Static Function MenuDef()
    Local aRot := {}
      
    //Adicionando opes
    //ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ACMVCZGQ' OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRot TITLE 'Atendimento'    ACTION 'VIEWDEF.ACMVCZGQ' OPERATION  MODEL_OPERATION_UPDATE ACCESS 0 
Return aRot
 
Static Function ModelDef()
    //Na montagem da estrutura do Modelo de dados, o cabealho filtrar e exibir somente alguns campos, j a grid ir carregar a estrutura inteira conforme funo fModStruct
    Local oModel      := NIL
    Local oStruCab    := FWFormStruct(1, 'ZGM' ) // Centro de Distribuo
    Local oStruZGQ    := FWFormStruct(1, 'ZGQ' , {|cCampo| !AllTRim(cCampo) $ "ZGQ_SALDO,ZGQ_QTDFAT" } )  // REquisies
    Local oStruZGR    := FWFormStruct(1, 'ZGR' ) // Historico
    
    
    Local oStruZGS    := FWFormStruct(1, 'ZGS' )  //Aglutinador

    DBSELECTAREA( "ZGM" )
    ZGM->(DbSetOrder(1))
    ZGM->(DbGoTop())

    //If ZGM->(DbSeek(xFilial("ZGM")))
    If ZGM->(DbSeek(cFilAnt))
        While ZGM->(!eof())
            If !Empty(ZGM->ZGM_LOCALM)
                _cArmazem := ZGM->ZGM_LOCALM
                Exit
            EndIf
        EndDo
    EndIf
    oStruZGQ:AddField( ;
        AllTrim('') , ;               // [01] C Titulo do campo
        AllTrim('') , ;               // [02] C ToolTip do campo
        'ZGQ_LEGEND' , ;               // [03] C identificador (ID) do Field
        'C' , ;                     // [04] C Tipo do campo
        50 , ;                      // [05] N Tamanho do campo
        0 , ;                      // [06] N Decimal do campo
        Nil , ;                     // [07] B Code-block de validao do campo
        {|| ACZGMLEG() } , ;                     // [08] B Code-block de validao When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatrio
        { || U_ACZGQCOR() } , ;           // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operao de update.
        .T. ) 


    oStruZGQ:AddField( ;
        AllTrim('Saldo') , ;               // [01] C Titulo do campo
        AllTrim('Saldo') , ;               // [02] C ToolTip do campo
        'ZGQ_SLDPRD' , ;               // [03] C identificador (ID) do Field
        'N' , ;                     // [04] C Tipo do campo
        16 , ;                      // [05] N Tamanho do campo
        2 , ;                      // [06] N Decimal do campo
        Nil , ;                     // [07] B Code-block de validao do campo
        {|| .F. } , ;                     // [08] B Code-block de validao When do campo
        NIL , ;                     // [09] A Lista de valores permitido do campo
        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatrio
        { || U_ACSLDPRD() } , ;           // [11] B Code-block de inicializacao do campo
        NIL , ;                     // [12] L Indica se trata de um campo chave
        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operao de update.
        .T. )         

    

    oModel := MPFormModel():New('CADZE1M', {|| AVLVZE1ALT() }, {|oModel| fValidGrid(oModel)}, {|oModel| fCommit(oModel) } , /*bCancel*/ )
 
    //Agora, define no modelo de dados, que ter um Cabealho e uma Grid apontando para estruturas acima
    oModel:AddFields('MdFieldZGM', NIL, oStruCab)
    oModel:AddGrid('MdGridZGQ', 'MdFieldZGM', oStruZGQ  )
    oModel:AddGrid('MdGridZGR', 'MdGridZGQ', oStruZGR  )
    //ANDRE CLARO 20240525   oModel:AddGrid('MdGridSD2', 'MdGridZGR', oStruSD2  )
    

    oModel:AddGrid('MdGridZGS', 'MdFieldZGM', oStruZGS )
     
    //Monta o relacionamento entre Grid e Cabealho, as expresses da Esquerda representam o campo da Grid e da direita do Cabealho
    oModel:SetRelation('MdGridZGQ', {;
            {"ZGQ_FILIAL", 'xFilial("ZGQ")'},;
            {"ZGQ_CDFIL", "ZGM_FILIAL"} }, ZGQ->(IndexKey(1)))

    oModel:SetRelation('MdGridZGR', {;
            {"ZGR_FILIAL", "ZGQ_CDFIL"},;
            {"ZGR_CODREQ", "ZGQ_CODREQ"},;
            {"ZGR_SEQDSM", "ZGQ_SEQDSM"} }, ZGR->(IndexKey(1)))

/*
    oModel:SetRelation('MdGridSD2', {;
            {"D2_FILIAL", "ZGR_FILIAL"},;
            {"D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA", "ZGR_CHVORI"},;
            {"'D2'", "ZGR_OPERAC"}  }, SD2->(IndexKey(3)))
*/


    

    oModel:SetRelation('MdGridZGS', {;
            {"ZGS_FILIAL", "ZGM_FILIAL" },; 
            {"ZGS_ITEZGM", "ZGM_ITEM" }}, ZGS->(IndexKey(1)))

	oModel:GetModel('MdGridZGS'):SetLoadFilter(, "ZGS_CLIENT <> ''  " )

    oModel:GetModel('MdGridZGR'):SetLoadFilter(, "ZGR_OPERAC <> ''  " )

    oModel:GetModel('MdGridZGQ'):SetLoadFilter(, " ZGQ_APROVA <> '' AND ZGQ_RESIDU <> 'S' AND ZGQ_PROD >= '"+_cProdDe+"' AND ZGQ_PROD <= '"+_cProdAt+"' AND (ZGQ_NFESAI = '' OR 'N' = '"+_cPendente+"') " )
 
    //Aqui continua os comandos para criao do ModelDef



    oModel:GetModel( 'MdGridZGQ' ):SetNoInsertLine( .T. )
    oModel:GetModel( 'MdGridZGR' ):SetNoInsertLine( .T. )
    //ANDRE CLARO 20240525   oModel:GetModel( 'MdGridSD2' ):SetNoInsertLine( .T. )
    
    
    oModel:GetModel( 'MdGridZGS' ):SetNoInsertLine( .T. )

    //ANDRE CLARO 20240525   oModel:GetModel( 'MdGridSD2' ):SetOptional( .T. )
    
    oModel:GetModel( 'MdGridZGR' ):SetOptional( .T. )
    oModel:GetModel( 'MdGridZGS' ):SetOptional( .T. )


    oModel:GetModel( 'MdGridZGQ' ):SetNoUpdateLine( .F. )
    oModel:GetModel( 'MdGridZGR' ):SetNoUpdateLine( .F. )
    //ANDRE CLARO 20240525   oModel:GetModel( 'MdGridSD2' ):SetNoUpdateLine( .T. )
    
    
    oModel:GetModel( 'MdGridZGS' ):SetNoUpdateLine( .F. )



    oStruZGS:SetProperty("ZGS_MARK",MODEL_FIELD_WHEN,{|| .T.})
    oStruZGS:SetProperty("ZGS_CODAGL",MODEL_FIELD_WHEN,{|| .T.})
    oStruZGS:SetProperty("ZGS_FILIAL",MODEL_FIELD_WHEN,{|| .T.})
    oStruZGS:SetProperty("ZGS_PEDIDO",MODEL_FIELD_WHEN,{|| .T.})
    oStruZGS:SetProperty("ZGS_DOCSAI",MODEL_FIELD_WHEN,{|| .T.})
    oStruZGS:SetProperty("ZGS_SERSAI",MODEL_FIELD_WHEN,{|| .T.})
    oStruZGS:SetProperty("ZGS_CLIENT",MODEL_FIELD_WHEN,{|| .T.})
    oStruZGS:SetProperty("ZGS_LOJA",MODEL_FIELD_WHEN,{|| .T.})
    oStruZGS:SetProperty("ZGS_EMISSA",MODEL_FIELD_WHEN,{|| .T.})
    oStruZGS:SetProperty("ZGS_APROVA",MODEL_FIELD_WHEN,{|| .T.})
    oStruZGS:SetProperty("ZGS_FILDES",MODEL_FIELD_WHEN,{|| .T.})
    oStruZGS:SetProperty("ZGS_NATSAI",MODEL_FIELD_WHEN,{|| .T.})
    oStruZGS:SetProperty("ZGS_CODPGT",MODEL_FIELD_WHEN,{|| .T.})

    oStruZGS:SetProperty("ZGS_FORNEC",MODEL_FIELD_WHEN,{|| .T.})
    oStruZGS:SetProperty("ZGS_LJFORN",MODEL_FIELD_WHEN,{|| .T.})

    oStruZGQ:SetProperty("ZGQ_FILIAL",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_MARK",MODEL_FIELD_WHEN,{|| .T.})
    oStruZGQ:SetProperty("ZGQ_CODREQ",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_ITEM",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_PROD",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_DESC",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_QUANT",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_CC",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_EMISSA",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_DTNECE",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_DTATEN",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_USERAP",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_APROVA",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_CDFIL",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_CDISTR",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_NUMSC",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_ITEMSC",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_NFESAI",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_NFEENT",MODEL_FIELD_WHEN,{|| .T.})
    oStruZGQ:SetProperty("ZGQ_SOLICT",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_FILORI",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_CODAGL",MODEL_FIELD_WHEN,{|| .F.})
    oStruZGQ:SetProperty("ZGQ_RESIDU",MODEL_FIELD_WHEN,{|| .T.})  
    oStruZGQ:SetProperty("ZGQ_OBSERV",MODEL_FIELD_WHEN,{|| .F.})

    //Definindo outras informaes do Modelo e da Grid
    oModel:GetModel("MdGridZGS"):SetMaxLine(9999)

    
    oModel:GetModel("MdFieldZGM"):SetDescription(Alltrim(ZGM->ZGM_DESC))
    oModel:GetModel("MdGridZGS"):SetDescription('Aglutinao para PV')
    oModel:GetModel("MdGridZGQ"):SetDescription('Requisies')    
    oModel:GetModel("MdGridZGR"):SetDescription('Movimentaes')    
    //ANDRE CLARO 20240525   oModel:GetModel("MdGridSD2"):SetDescription('Nota Fiscal de Sada')    
    

    oModel:SetDescription("Painel de Requisio ao CD")
    
    oModel:SetPrimaryKey({"ZGQ_FILIAL","ZGQ_CODREQ","ZGQ_ITEM","ZGQ_SEQDSM" } ) ///","ZE1_PARCEL","ZE1_TIPO","ZE1_ITEM"})
 
Return oModel
 
Static Function ViewDef()
    //Na montagem da estrutura da visualizao de dados, vamos chamar o modelo criado anteriormente, no cabealho vamos mostrar somente 3 campos, e na grid vamos carregar conforme a funo fViewStruct
    Local oView        := NIL
    Local oModel    := FWLoadModel('ACMVCZGQ')

    Local oStruCab  := FWFormStruct(2, "ZGM" ) //, {|cCampo| AllTRim(cCampo) $ "ZB0_FILIAL,ZB0_NUMORC,ZB0_REV,ZB0_VALTOT,ZB0_DTEMIS,ZB0_DTVLDO,ZB0_EMPRES,ZB0_CDPROS,ZB0_NMPROS,ZB0_CLICOD,ZB0_LOJA,ZB0_CLINOM,ZB0_TIPC,ZB0_TPFRET,ZB0_VALFRE,ZB0_PRZENT,ZB0_TRANCD,ZB0_TRANRS,ZB0_TRANST,ZB0_CDCOND,ZB0_DSCOND,ZB0_VENDCD,ZB0_VENDNO,ZB0_VENDC0,ZB0_FRTREL"})
    Local oStruZGQ := FWFormStruct(2, "ZGQ" , {|cCampo| !AllTRim(cCampo) $ "ZGQ_SALDO,ZGQ_QTDFAT" } ) 
    Local oStruZGR := FWFormStruct(2, "ZGR" , {|cCampo| !AllTRim(cCampo) $ "D2_FILIAL,D2_DOC,D2_ D2_EMISSAO, SD2.D2_ITEM"})
    //ANDRE CLARO 20240525   Local oStruSD2 := FWFormStruct(2, "SD2" , {|cCampo| AllTRim(cCampo) $ "D2_FILIAL,D2_DOC,D2_SERIE,D2_EMISSAO, SD2.D2_ITEM"})
    
    Local oStruZGS := FWFormStruct(2, "ZGS" ) //, {|cCampo| !AllTRim(cCampo) $ "  "  })

    DBSELECTAREA( "ZGM" )
    ZGM->(DbSetOrder(1))
    ZGM->(DbGoTop())

    //If ZGM->(DbSeek(xFilial("ZGM")))
    If ZGM->(DbSeek(cFilAnt))
        While ZGM->(!eof())
            If !Empty(ZGM->ZGM_LOCALM)
                _cArmazem := ZGM->ZGM_LOCALM
                Exit
            EndIf
        EndDo
    EndIf
	
   oStruZGQ:AddField( ;                      // Ord. Tipo Desc.
        'ZGQ_LEGEND'                        , ;        // [01] C   Nome do Campo
        "00"                             , ;     // [02] C   Ordem
        AllTrim( ''    )        , ;     // [03] C   Titulo do campo
        AllTrim( '' )       , ;     // [04] C   Descricao do campo
        { 'Legenda' }           , ;     // [05] A   Array com Help
        'C'                             , ;     // [06] C   Tipo do campo
        '@BMP'               , ;     // [07] C   Picture
        NIL                             , ;     // [08] B   Bloco de Picture Var
        ''                             , ;     // [09] C   Consulta F3
        .T.                             , ;     // [10] L   Indica se o campo  alteravel
        NIL                             , ;     // [11] C   Pasta do campo
        NIL                             , ;     // [12] C   Agrupamento do campo
        NIL                                        , ;     // [13] A   Lista de valores permitido do campo (Combo)
        NIL                             , ;     // [14] N   Tamanho maximo da maior opo do combo
        NIL                             , ;     // [15] C   Inicializador de Browse
        .T.                             , ;     // [16] L   Indica se o campo  virtual
        NIL                             , ;     // [17] C   Picture Variavel
        NIL                             )       // [18] L   Indica pulo de linha aps o campo 
 
   oStruZGQ:AddField( ;                      // Ord. Tipo Desc.
        'ZGQ_SLDPRD'                        , ;        // [01] C   Nome do Campo
        "10"                             , ;     // [02] C   Ordem
        AllTrim( 'Saldo'    )        , ;     // [03] C   Titulo do campo
        AllTrim( 'Saldo do Produto' )       , ;     // [04] C   Descricao do campo
        { 'Saldo Produto' }           , ;     // [05] A   Array com Help
        'N'                             , ;     // [06] C   Tipo do campo
        '@E 999,999,999.999'               , ;     // [07] C   Picture
        NIL                             , ;     // [08] B   Bloco de Picture Var
        ''                             , ;     // [09] C   Consulta F3
        .T.                             , ;     // [10] L   Indica se o campo  alteravel
        NIL                             , ;     // [11] C   Pasta do campo
        NIL                             , ;     // [12] C   Agrupamento do campo
        NIL                                        , ;     // [13] A   Lista de valores permitido do campo (Combo)
        NIL                             , ;     // [14] N   Tamanho maximo da maior opo do combo
        NIL                             , ;     // [15] C   Inicializador de Browse
        .T.                             , ;     // [16] L   Indica se o campo  virtual
        NIL                             , ;     // [17] C   Picture Variavel
        NIL                             )       // [18] L   Indica pulo de linha aps o campo 
 




    	
    //Define que o cabealho no ter abas
    oStruCab:SetNoFolder()

    /// REMOVENDO CAMPOS NO NECESSRIOS
    oStruZGQ:RemoveField("ZGQ_CDISTR")
    oStruZGQ:RemoveField("ZGQ_NUMSC")
    oStruZGQ:RemoveField("ZGQ_ITEMSC")
    oStruZGQ:RemoveField("ZGQ_NFESAI")
    oStruZGQ:RemoveField("ZGQ_NFEENT")
    oStruZGQ:RemoveField("ZGQ_CODAGL")    
    oStruZGQ:RemoveField("ZGQ_USERAP")


    

    oStruZGQ:RemoveField("ZGQ_RESIDU")

    oStruZGR:RemoveField("ZGR_CODREQ")
    oStruZGR:RemoveField("ZGR_ITEM")
    oStruZGR:RemoveField("ZGR_ITEDOC")
    oStruZGR:RemoveField("ZGR_CHVORI")
    oStruZGR:RemoveField("ZGR_STATUS")
    oStruZGR:RemoveField("ZGR_USER")
    
    //oStruZGS:RemoveField("ZGS_FORNEC")
    //oStruZGS:RemoveField("ZGS_LJFORN")

    oStruZGS:RemoveField("ZGS_ITEZGM")
    

    //Cria o View
    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
 
    //Cria uma rea de Field vinculando a estrutura do cabealho com MdFieldSA1, e uma Grid vinculando com MdGridZE1
    oView:AddField('VIEW_ZGM', oStruCab, 'MdFieldZGM')
    oView:AddGrid ('GRID_ZGQ', oStruZGQ, 'MdGridZGQ' )
    oView:AddGrid ('GRID_ZGS', oStruZGS, 'MdGridZGS' )
    oView:AddGrid ('GRID_ZGR', oStruZGR, 'MdGridZGR' )
    //ANDRE CLARO 20240525   oView:AddGrid ('GRID_SD2', oStruSD2, 'MdGridSD2' )
    
 
    //O cabealho (MAIN) ter 25% de tamanho, e o restante de 75% ir para a GRID
    //oView:CreateHorizontalBox("MAINHIDE", 5)
    oView:CreateHorizontalBox("MAINHIDE", 0)

    oView:CreateHorizontalBox("ESCONDE1", 0)
    oView:CreateHorizontalBox("ESCONDE2", 0)

    oView:CreateHorizontalBox("MAINBUTT", 5)
    oView:CreateHorizontalBox("MAINSHOW", 60)
    oView:CreateHorizontalBox("GRID", 35)

    // Acrescenta um objeto externo ao View do MVC
    oView:AddOtherObject("PNL_ZGSA", {|oPanel| CABZGSA(oPanel)})
    oView:SetCloseOnOk( { || .T. })  //Fecha a Tela ao confirmar

    oView:SetOwnerView('VIEW_ZGM', 'MAINHIDE')
    oView:SetOwnerView('PNL_ZGSA', 'MAINBUTT')
    oView:SetOwnerView('GRID_ZGQ', 'MAINSHOW')
    
    //escondidos
    

    //ANDRE CLARO 20240525   oView:SetOwnerView('GRID_SD2', 'ESCONDE2')

    //Criando a folder dos produtos (filhos)
    oView:CreateFolder('PASTA_FILHOS', 'GRID')

    oView:AddSheet('PASTA_FILHOS', 'ABA_FILHO01', "Aglutinador")
    oView:AddSheet('PASTA_FILHOS', 'ABA_FILHO02', "Movimentos")
    
    //Criando os vinculos onde sero mostrado os dados
    oView:CreateHorizontalBox('ITENS_FILHO01', 100,,, 'PASTA_FILHOS', 'ABA_FILHO01' )
    oView:CreateHorizontalBox('ITENS_FILHO02', 100,,, 'PASTA_FILHOS', 'ABA_FILHO02' )
    //AQUI ANDRE oView:CreateHorizontalBox('ITENS_FILHO03', 100,,, 'PASTA_FILHOS', 'ABA_FILHO03' )
      
    oView:SetOwnerView('GRID_ZGS', 'ITENS_FILHO01')
    oView:SetOwnerView('GRID_ZGR', 'ITENS_FILHO02')

    oView:EnableTitleView( "MdFieldZGM")
    oView:EnableTitleView( "MdGridZGQ")
    oView:EnableTitleView( "MdGridZGS")
    oView:EnableTitleView( "MdGridZGR")
    //ANDRE CLARO 20240525   oView:EnableTitleView( "MdGridSD2")
    

    oView:EnableControlBar(.T.)
 
    oView:SetAfterViewActivate({|oView| _IniCpos(oView)} )  
Return oView
 
//Funo chamada para montar o modelo de dados da Grid
Static Function fModStruct()
    Local oStruct
    oStruct := FWFormStruct(1, 'ZGM')
Return oStruct
 
//Funo chamada para montar a visualizao de dados da Grid
Static Function fViewStruct()
    Local oStruct
 
    oStruct := FWFormStruct(2, "ZGQ" ) //, {|cCampo| AllTRim(cCampo) $ "ZE1_NUMORC,ZE1_REVISA, ZE1_ITEM  ZE1_DATA  ZE1_HORA  ZE1_USER  ZE1_USERNA ZE1_VLRTOT ZE1_VLRAPR ZE1_CONDPG ZE1_OBS   "})
Return oStruct
 
//Funo que faz a validao da grid
Static Function fValidGrid(oModel)

Local _lRet     := .T.
Local _cZE1Num :=  FwFldGet("ZE1_CODIGO",1,oModel)
Local _cZE1Item :=  FwFldGet("ZE1_ITEM",1,oModel)   





Return _lRet

static function fCommit(oModel)
Local lRet := .T.

// NO VOU GRAVAR NADA, ORQUE A CADA GERAO SER FEITO COMMIT DAS INFORMAES.
//FWFormCommit( oModel )

Return lRet

User Function zZE1item()

Local _cItem := "0001"

Return _cItem



Static Function AVLVZE1ALT()

//Local _oModel := FwModelActive()
//Local _cItem := _oModel:GetValue('MdGridZE1','ZE1_ITEM')
//Local _cCodigo := _oModel:GetValue('MdGridZE1','ZE1_CODIGO')
//Local _cAlias := GetNextAlias()
Local _lRet := .T.



Return _lRet






Static Function _IniCpos(oView)

Local nOperation := oView:GetOperation() 
Local oModel := FWModelActive() 
Local oModelZGM := oModel:GetModel("MdFieldZGM")
Local oGridZGQ := oModel:GetModel("MdGridZGQ")
Local oGridZGS := oModel:GetModel("MdGridZGS")

Local _nX := 0 
Local _aSaveLines := FWSaveRows()

DBSELECTAREA( "ZGM" )
ZGM->(DbSetOrder(1))
ZGM->(DbGoTop())

//If ZGM->(DbSeek(xFilial("ZGM")))
If ZGM->(DbSeek(cFilAnt))
    While ZGM->(!eof())
        If !Empty(ZGM->ZGM_LOCALM)
            _cArmazem := ZGM->ZGM_LOCALM
            Exit
        EndIf
    EndDo
EndIf  

If nOperation == 3 .OR. nOperation == 4
    For _nX := 1 To  oGridZGQ:Length()
        oGridZGQ:GoLine( _nX )
        If !oGridZGQ:IsDeleted() 
            oGridZGQ:LoadValue( 'ZGQ_MARK', .F. )
        EndIf
    Next _nX 

    For _nX := 1 To  oGridZGS:Length()
        oGridZGS:GoLine( _nX )
        If !oGridZGS:IsDeleted() 
            oGridZGS:LoadValue( 'ZGS_MARK', .F. )
        EndIf
    Next _nX     
    
    oGridZGQ:GoLine( 1 )
    oGridZGS:GoLine( 1 )

    oView:Refresh("MdGridZGS")
    oView:Refresh("MdGridZGQ")
    oView:Refresh()

EndIf 

FWRestRows( _aSaveLines )

Return

Static Function CABZGSA(oPanel)
    Local oView      := FWViewActive()
    Local oModel      := FWModelActive()
    Local oFont8N     := TFONT():New("ARIAL",08,-11,,.T.,,,,.T.,.F.) ///Fonte 8 Negrito

    Local nAlt := oPanel:NHEIGHT
    Local nLarg := oPanel:NWIDTH
    Local nDiv := 25
    Local _nUnid := nLarg / nDiv

    if oModel:GetOperation() > 1
        SetKey(VK_F5, {|| IncGrid(1)})
    Endif

    SX3->(DbSetOrder(2))

    if Type("oScrSco") == "U"
        oScrSco := TScrollBox():Create(oPanel,01,01,oPanel:nClientHeight - 40,oPanel:nClientWidth / 2,.F.,.T.,.F.)
        oScrSco:Align := CONTROL_ALIGN_ALLCLIENT
    Endif

    oPanel1 := oPanel
    oView:Refresh()
   
    oBtnA1  := TButton():New( 001, (nLarg/nDiv*1)-_nUnid, "AGLUTINAR",oScrSco,{||      Processa({||   ACZGOAGL(@oView, 1 )    } ,"Aglutinando..."  )    }, 50,10,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnA2  := TButton():New( 001, (nLarg/nDiv*2)-_nUnid, "DESAGLUTINAR",oScrSco  ,{|| Processa({||   ACZGOAGL(@oView, 2 )    } ,"desaglutinando..."  )    }, 50,10,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnA4  := TButton():New( 001, (nLarg/nDiv*3)-_nUnid, "ATENDER",oScrSco   ,{||     Processa({||   ACZGOATN(@oView)        } ,"Atendendo..."  )     }, 50,10,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnA5  := TButton():New( 001, (nLarg/nDiv*4)-_nUnid, "REENTRADA",oScrSco ,{||     Processa({||   ACZGOREE(@oView)        } ,"Reentrando..."  ) }, 50,10,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnA3  := TButton():New( 001, (nLarg/nDiv*5)-_nUnid, "GERAR SC",oScrSco  ,{||     Processa({||   ACZGOSC(@oView)         } ,"Inc. Solic. Compras..."  )      }, 50,10,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnB2  := TButton():New( 001, (nLarg/nDiv*6)-_nUnid, "FILTRAR ",oScrSco  ,{||     Processa({|| ACFILTRO(@oView)} ,"Filtrando..."  ) } , 50,10,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnB3  := TButton():New( 001, (nLarg/nDiv*7)-_nUnid, "REFRESH ",oScrSco  ,{||     Processa({|| ACREFRESH(@oView)} ,"Atualizando Tela..."  ) }, 50,10,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnB4  := TButton():New( 001, (nLarg/nDiv*8)-_nUnid, "RESIDUO ",oScrSco  ,{||     Processa({|| ACZGQRES(@oView)} ,"Eliminando..."  ) }, 50,10,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnB6  := TButton():New( 001, (nLarg/nDiv*9)-_nUnid, "DESMEMBRAR ",oScrSco  ,{||  Processa({|| ACZGQDES(@oView)} ,"Desmembrando..."  ) }, 50,10,,,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnB1  := TButton():New( 001, (nLarg/nDiv*10)-_nUnid, "MARC. TODOS",oScrSco   ,{||      Processa({|| ACZGOMKT(@oView)} ,"Processando..."  ) }, 50,10,,,.F.,.T.,.F.,,.F.,,,.F. )

    oBtnB7  := TButton():New( 001, (nLarg/nDiv*11)-_nUnid, "IMPRIMIR",oScrSco   ,{||      Processa({|| ACZGIMPR(@oView)} ,"Processando..."  ) }, 50,10,,,.F.,.T.,.F.,,.F.,,,.F. )

    oBtnB5  := TButton():New( 001, (nLarg/nDiv*12)-_nUnid, "LEGENDA ",oScrSco  ,{||   ACZGMLEG(@oView) }, 50,10,,,.F.,.T.,.F.,,.F.,,,.F. )

    //Cria CSS Defualt para os Botoes
    cCSSBtn1 := " QPushButton {"
    cCSSBtn1 += " background-color: RGB(83,141,213);"
    cCSSBtn1 += " border-style: outset; "
    cCSSBtn1 += " border-width: 1px;"
    cCSSBtn1 += " border-color: black;"
    cCSSBtn1 += " border-radius: 10px;"
    cCSSBtn1 += " font-weight: bold;"
    cCSSBtn1 += " }"

    //Cria CSS Defualt para os Botoes
    cCSSBtn2 := " QPushButton {"
    cCSSBtn2 += " background-color: RGB(149,179,215);"
    cCSSBtn2 += " border-style: outset; "
    cCSSBtn2 += " border-width: 1px;"
    cCSSBtn2 += " border-color: black;"
    cCSSBtn2 += " border-radius: 10px;"
    cCSSBtn2 += " font-weight: bold;"
    cCSSBtn2 += " }"    

    oBtnA1:setCSS(cCSSBtn1)
    oBtnA2:setCSS(cCSSBtn2)
    oBtnA3:setCSS(cCSSBtn1)
    oBtnA4:setCSS(cCSSBtn2)
    oBtnA5:setCSS(cCSSBtn1)

    oBtnB1:setCSS(cCSSBtn1)
    oBtnB2:setCSS(cCSSBtn2)
    oBtnB3:setCSS(cCSSBtn1)
    oBtnB4:setCSS(cCSSBtn2)
    oBtnB5:setCSS(cCSSBtn1)
    oBtnB6:setCSS(cCSSBtn2)

    oBtnB7:setCSS(cCSSBtn1)
    
    
    oBtnB1:Refresh()
    oBtnB2:Refresh()
    oBtnB3:Refresh()
    oBtnB4:Refresh()
    oBtnB5:Refresh()
    oBtnB6:Refresh()

    oBtnA1:Refresh()
    oBtnA2:Refresh()
    oBtnA3:Refresh()
    oBtnA4:Refresh()
    oBtnA5:Refresh()

Return


Static Function ACZGOMKT(oView)


Local oModel := FWModelActive() 
Local oGridZGQ := oModel:GetModel("MdGridZGQ")
Local _aSaveLines := FWSaveRows()
Local _nX := 0 
Local _nCount := 0 

Local _aPergs := {}
Local _aRet := {}
Local _nNovaQtde := 0
Local _nNewZGQ := 0 
Local oModel := FWModelActive() 
Local oGridZGQ := oModel:GetModel("MdGridZGQ")
Local _aSaveLines := FWSaveRows()
Local _nX := 0 
Local _nY := 0
Local _aNewZGQ := {}
Local _nLineZGS := 0 
Local _lMarcar := .T.
Local _nOpcao := 0


_nOpcao := Aviso("ATENO","ESCOLHA A OPO DESEJADA",{"MARCAR","DESMARCAR","CANCELAR"},2)

If _nOpcao == 1 //marcar
    _lMarcar := .T.
ElseIf _nOpcao == 2 //desmarcar
    _lMarcar := .F.
Else
    Return 

Endif

For _nX := 1 To  oGridZGQ:Length()
    IncProc("Processando... Por favor, aguarde.")
    oGridZGQ:GoLine( _nX )
    If !oGridZGQ:IsDeleted()
        oGridZGQ:LoadValue('ZGQ_MARK', _lMarcar )
    EndIf
Next _nX

FwFormCommit(oModel)

oGridZGQ:GoLine( 1 )

oView:Refresh("MdGridZGQ")
oView:Refresh()   

Return 

// Rotina de desmembramento de requisies ao cd
Static Function ACZGQDES(oView)

Local oModel := FWModelActive() 
Local oGridZGQ := oModel:GetModel("MdGridZGQ")
Local _aSaveLines := FWSaveRows()
Local _nX := 0 
Local _nCount := 0 

Local _aPergs := {}
Local _aRet := {}
Local _nNovaQtde := 0
Local _nNewZGQ := 0 
Local oModel := FWModelActive() 
Local oGridZGQ := oModel:GetModel("MdGridZGQ")
Local _aSaveLines := FWSaveRows()
Local _nX := 0 
Local _nY := 0
Local _aNewZGQ := {}
Local _nLineZGS := 0 

For _nX := 1 To  oGridZGQ:Length()
    IncProc("Desmembrando... Por favor, aguarde.")
    oGridZGQ:GoLine( _nX )
    If !oGridZGQ:IsDeleted() .and. oGridZGQ:GetValue( 'ZGQ_MARK' ) 
        _nCount ++ 
    EndIf
Next _nX

If _nCount == 1 
    For _nX := 1 To  oGridZGQ:Length()
        IncProc("Desmembrando... Por favor, aguarde.")
        oGridZGQ:GoLine( _nX )
        If !oGridZGQ:IsDeleted() .and. oGridZGQ:GetValue( 'ZGQ_MARK' ) 
            If !Empty(oGridZGQ:GetValue( 'ZGQ_NFEENT' ) )
                Aviso("Ateno","Essa requisio j gerou NF Entrada",{"REVISAR"},2)
                Return 
            ElseIf !Empty(oGridZGQ:GetValue( 'ZGQ_NFESAI' ) )
                Aviso("Ateno","Essa requisio j gerou NF Sada",{"REVISAR"},2)
                Return    
            ElseIf !Empty(oGridZGQ:GetValue( 'ZGQ_NUMSC' ) ) .and. 1 == 2 
                Aviso("Ateno","Essa requisio j gerou SC",{"REVISAR"},2)
                Return                              
            Else
                aadd( _aPergs , {1, "Qtd. Desmembrar"             , 0  , "@E 999,999,999.9999"                               ,'.T.'      ,     ,'.T.'  ,80     ,.F.})

                If	ParamBox(_aPergs , "Desmembramento de Requisio", _aRet,,,,700,1000, /*oMainDlg*/,,.F.,.F.)
                    _nNovaQtde := _aRet[1]
                    If _nNovaQtde >= oGridZGQ:GetValue( 'ZGQ_QUANT' )
                        Aviso("Ateno","A quantidade informada  maior que a quantidade da requisio.",{"REVISAR"},2)
                        Return 
                    Else
                        //At aqui terei a nova quantidade a quantidade atualizada da antiga.
                        _nNewZGQ := oGridZGQ:GetValue( 'ZGQ_QUANT' ) - _nNovaQtde //Esse valor ser atualizado na ZGQ
                        _cNewSeq := oGridZGQ:GetValue( 'ZGQ_SEQDSM' )
                        If Empty(_cNewSeq)
                            _cNewSeq := "001"
                        Else
                            _cNewSeq := ACGetSeq(oGridZGQ:GetValue( 'ZGQ_FILORI' ), oGridZGQ:GetValue( 'ZGQ_CODREQ' )) 
                            _cNewSeq := Soma1(_cNewSeq)
                        EndIf

                        aAdd(_aNewZGQ, { 'ZGQ_FILIAL', oGridZGQ:GetValue( 'ZGQ_FILIAL') }) 
                        aAdd(_aNewZGQ, { 'ZGQ_CODREQ', oGridZGQ:GetValue( 'ZGQ_CODREQ')})
                        aAdd(_aNewZGQ, { 'ZGQ_ITEM'  , oGridZGQ:GetValue( 'ZGQ_ITEM')})
                        aAdd(_aNewZGQ, { 'ZGQ_SEQDSM'  , _cNewSeq })
                        aAdd(_aNewZGQ, { 'ZGQ_PROD'  , oGridZGQ:GetValue( 'ZGQ_PROD')})
                        aAdd(_aNewZGQ, { 'ZGQ_LOCAL' , oGridZGQ:GetValue( 'ZGQ_LOCAL')})
                        aAdd(_aNewZGQ, { 'ZGQ_DESC'  , oGridZGQ:GetValue( 'ZGQ_DESC')})
                        aAdd(_aNewZGQ, { 'ZGQ_QUANT' , _nNovaQtde })
                        aAdd(_aNewZGQ, { 'ZGQ_CC'    , oGridZGQ:GetValue( 'ZGQ_CC')})
                        aAdd(_aNewZGQ, { 'ZGQ_EMISSA', oGridZGQ:GetValue( 'ZGQ_EMISSA')})
                        aAdd(_aNewZGQ, { 'ZGQ_DTNECE', oGridZGQ:GetValue( 'ZGQ_DTNECE')})
                        aAdd(_aNewZGQ, { 'ZGQ_DTATEN', oGridZGQ:GetValue( 'ZGQ_DTATEN')})
                        aAdd(_aNewZGQ, { 'ZGQ_USERAP', oGridZGQ:GetValue( 'ZGQ_USERAP')})
                        aAdd(_aNewZGQ, { 'ZGQ_APROVA', oGridZGQ:GetValue( 'ZGQ_APROVA')})
                        aAdd(_aNewZGQ, { 'ZGQ_CDFIL' , oGridZGQ:GetValue( 'ZGQ_CDFIL')})
                        aAdd(_aNewZGQ, { 'ZGQ_CDISTR', oGridZGQ:GetValue( 'ZGQ_CDISTR')})
                        aAdd(_aNewZGQ, { 'ZGQ_SOLICT', oGridZGQ:GetValue( 'ZGQ_SOLICT')})
                        aAdd(_aNewZGQ, { 'ZGQ_FILORI', oGridZGQ:GetValue( 'ZGQ_FILORI')})
                        aAdd(_aNewZGQ, { 'ZGQ_OBSERV', oGridZGQ:GetValue( 'ZGQ_OBSERV')})
                        
                        oModel:GetModel( 'MdGridZGQ' ):SetNoInsertLine( .F. )
                        oModel:GetModel( 'MdGridZGQ' ):SetNoUpdateLine( .F. )

                        oGridZGQ:LoadValue('ZGQ_QUANT', _nNewZGQ)

                        //oView:Refresh("MdGridZGQ")
                        
                        //FAo a nova incluso
                        _nLineZGS := oGridZGQ:AddLine()
                        oGridZGQ:GoLine(_nLineZGS)
                        For _nY := 1 to Len(_aNewZGQ)  
                            oGridZGQ:LoadValue(_aNewZGQ[_nY][1],_aNewZGQ[_nY][2] )
                        Next _nY   
                        oView:Refresh("MdGridZGQ")   

                        oModel:GetModel( 'MdGridZGQ' ):SetNoInsertLine( .T. )
                        oModel:GetModel( 'MdGridZGQ' ):SetNoUpdateLine( .F. )     




                        FwFormCommit(oModel)

                        oModel := FWModelActive()
                        oModel:DeActivate() 
                        oModel:SetOperation(4) 
                        oModel:Activate()

                        oView:Refresh("MdFieldZGM")
                        oView:Refresh("MdGridZGQ")
                        oView:Refresh("MdGridZGS")
                        oView:Refresh("MdGridZGR")
                        oView:Refresh()   

                        EXIT //SAIO DO FOR PORQUE  1 PARA UM                                      

                    EndIf                    
                EndIf
            EndIf
        EndIf
    Next _nX
Else
    Aviso("Ateno","Selecione apenas e ao menos um registro para desmembrar",{"REVISAR"},2)
    Return 
EndIf

Return 

Static Function ACREFRESH(oView, oModel)
oModel := FwModelActive()



    oView:Refresh("MdFieldZGM")
    oView:Refresh("MdGridZGQ")
    oView:Refresh("MdGridZGS")
    oView:Refresh("MdGridZGR")
    
    //ANDRE CLARO 20240525   oView:Refresh("MdGridSD2")
    oView:Refresh()
    
If ValType(oModel) <> "U"

    FwFormCommit(oModel)

    oModel := FWModelActive()
    oModel:DeActivate() 
    oModel:SetOperation(4) 
    oModel:Activate()

    oView:Refresh("MdFieldZGM")
    oView:Refresh("MdGridZGQ")
    oView:Refresh("MdGridZGS")
    oView:Refresh("MdGridZGR")
    
    //ANDRE CLARO 20240525   oView:Refresh("MdGridSD2")
    oView:Refresh()
EndIf

Return 

Static Function ACFILTRO(oView)

Local _aPergs := {}
Local _aRet := {}
//Local dDataI := dDatabase - 30
//Local dDataF := dDatabase + 30
Local _cFilData := ''

Local oModel := FWModelActive() 
Local oModelZGM := oModel:GetModel("MdFieldZGM")
Local oGridZGQ := oModel:GetModel("MdGridZGQ")
Local oGridZGS := oModel:GetModel("MdGridZGS")
Local oGridZGR := oModel:GetModel("MdGridZGR")
Local _aSaveLines := FWSaveRows()
Local _nX := 0 

aAdd( _aPergs,  {2, "Manter Seleo"        , _cMVPAR01  , {"1=Sim"  ,"2=No"}   , 080        ,".T."                                  ,.T.})
aadd( _aPergs , {1, "Produto de"            , _cMVPAR02  , "@!"                               ,'.T.'      ,"SB1"      ,'.T.'  ,80     ,.F.})
aadd( _aPergs , {1, "Produto ate"	        , _cMVPAR03  , "@!"                               ,'.T.'      ,"SB1"      ,'.T.'  ,80     ,.T.})
aAdd( _aPergs,  {2, "Apenas Pendentes"      , _cMVPAR04  , {"1=Sim"  ,"2=No"}   , 080        ,".T."                                  ,.T.})
aadd( _aPergs , {1, "Dt. Neces. de"  		, _cMVPAR05  ,                                    ,'.T.'      ,           ,'.T.'  , 50    ,.T.})
aadd( _aPergs , {1, "Dt. Neces. at"  		, _cMVPAR06  ,                                    ,'.T.'      ,           ,'.T.'  , 50    ,.T.})

aadd( _aPergs , {1, "Filial de"             , _cMVPAR07  , "@!"                               ,'.T.'      ,"SM0"      ,'.T.'  ,80     ,.F.})
aadd( _aPergs , {1, "Filial ate"	        , _cMVPAR08  , "@!"                               ,'.T.'      ,"SM0"      ,'.T.'  ,80     ,.T.})

aadd( _aPergs , {1, "Requisio de"             , _cMVPAR09  , "@!"                               ,'.T.'      ,"ZGQ"      ,'.T.'  ,80     ,.F.})
aadd( _aPergs , {1, "Requisio ate"	        , _cMVPAR10  , "@!"                               ,'.T.'      ,"ZGQ"      ,'.T.'  ,80     ,.T.})

If	ParamBox(_aPergs , "CENTRO DE DISTRIBUIO", _aRet,,,,700,1000, /*oMainDlg*/,,.F.,.F.)

    _cMVPAR01 := _aRet[1]
    _cMVPAR02 := _aRet[2]
    _cMVPAR03 := _aRet[3]
    _cMVPAR04 := _aRet[4]
    _cMVPAR05 := _aRet[5]
    _cMVPAR06 := _aRet[6]


    _cMVPAR07 := _aRet[7]
    _cMVPAR08 := _aRet[8]

    _cMVPAR09 := _aRet[9]
    _cMVPAR10 := _aRet[10]

    If _aRet[1] <> "1" //Mantem a seleo
        For _nX := 1 To  oGridZGQ:Length()
            IncProc("Filtrando... Por favor, aguarde.")
            oGridZGQ:GoLine( _nX )
            If !oGridZGQ:IsDeleted() .and. oGridZGQ:GetValue( 'ZGQ_MARK' ) 
                oGridZGQ:SetValue( 'ZGQ_MARK', .F. ) 
            EndIf
        Next _nX
            oView:Refresh("MdGridZGQ")
            
        For _nX := 1 To  oGridZGS:Length()
            IncProc("Filtrando... Por favor, aguarde.")
            oGridZGS:GoLine( _nX )
            If !oGridZGS:IsDeleted() .and. oGridZGS:GetValue( 'ZGS_MARK' ) 
                oGridZGS:SetValue( 'ZGS_MARK', .F. ) 
            EndIf
        Next _nX
        oView:Refresh("MdGridZGS")

    EndIf 

    If !Empty(_aRet[5]) .or. !Empty(_aRet[6])
        _cFilData := " AND ZGQ_DTNECE >= '"+DtoS(_aRet[5]) +"' AND ZGQ_DTNECE <= '"+dToS(_aRet[6]) + "' "
    EndIf

    If _aRet[9] <> '' .or. _aRet[10] <> ''
        _cFilData += " AND ZGQ_CODREQ >= '"+_aRet[9]+"'   AND ZGQ_CODREQ <= '"+_aRet[10]+"' " 
    EndIf

    If !Empty(_aRet[7]) .or. !Empty(_aRet[8])
        _cFilData += " AND ZGQ_FILORI >= '"+_aRet[7] +"' AND ZGQ_FILORI <= '"+_aRet[8] + "' "

        oGridZGS:cLoadFilter := " ZGS_FILDES >= '"+_aRet[7]+"' AND ZGS_FILDES <= '"+_aRet[8]+"' "
    EndIf



    _cFilData += "  AND ZGQ_RESIDU <> 'S' AND  ZGQ_APROVA <> ''  "

    If _aRet[4] == "1" //Apenas Pendentes? 
        _cPendente := "S" 

        If !Empty(_aRet[3])
            _cProdDe := _aRet[2]
            _cProdAt := _aRet[3]


            oGridZGQ:cLoadFilter :=  " (( ZGQ_PROD >= '"+_cProdDe+"' AND ZGQ_PROD <= '"+_cProdAt+"' "+_cFilData+" AND (ZGQ_NFESAI = '' OR 'N' = '"+_cPendente+"' )) OR ZGQ_MARK = 'T' ) "
        Else
            _cProdDe := "  "
            _cProdAt := "ZZZZZZZZZZ"
            oGridZGQ:cLoadFilter :=  " (( ZGQ_PROD >= '"+_cProdDe+"' AND ZGQ_PROD <= '"+_cProdAt+"' "+_cFilData+" AND (ZGQ_NFESAI = '' OR 'N' = '"+_cPendente+"')  ) OR ZGQ_MARK = 'T'   ) "
        EndIf
        
        oGridZGS:cLoadFilter :=  "  ZGS_DOCSAI = '' "

    Else 
        If !Empty(_aRet[3])
            _cProdDe := _aRet[2]
            _cProdAt := _aRet[3]
            oGridZGQ:cLoadFilter :=  "( ( ZGQ_PROD >= '"+_cProdDe+"' AND ZGQ_PROD <= '"+_cProdAt+"' "+_cFilData+"   ) OR ZGQ_MARK = 'T' ) "
        Else
            _cProdDe := ""
            _cProdAt := "ZZZZZZ"
            oGridZGQ:cLoadFilter :=  "( ( ZGQ_PROD >= '"+_cProdDe+"' AND ZGQ_PROD <= '"+_cProdAt+"' "+_cFilData+"   ) OR ZGQ_MARK = 'T' )   "                    
        EndIf
        oGridZGS:cLoadFilter :=  "   "        
    EndIf 

FWRestRows(_aSaveLines)

FwFormCommit(oModel)

oModel := FWModelActive()
oModel:DeActivate() 
oModel:SetOperation(4) 
oModel:Activate()


oView:Refresh("MdFieldZGM")
oView:Refresh("MdGridZGQ")
oView:Refresh("MdGridZGS")
oView:Refresh("MdGridZGR")

//ANDRE CLARO 20240525   oView:Refresh("MdGridSD2")

Endif

Return 



Static Function ACZGOAGL(oView, _nOpc)

Local _cDoc := ''
Local _nX := 1 
Local _cFilDest := ''
Local _cProd := ''
Local _cNaturez := ''
Local _cTesE := ''
Local _cTesS := ''
Local _cCondPg := ''
Local _aCliLj := {}
Local _nFirst := 0
Local oModel := FWModelActive() 
Local oFieldZGQ	:= oModel:GetModel("MdFieldZGM")
Local oGridZGQ	:= oModel:GetModel("MdGridZGQ")
Local oGridZGS	:= oModel:GetModel("MdGridZGS")
Local oModelZGM := oModel:GetModel("MdFieldZGM")

Local _nLinZGS := oGridZGS:Length()
Local _aCodAgl := {}
Local _aSaveLines := FWSaveRows()
Local _nY := 0
Local _lRet := .T.
Local _nLineZGS := 0 
Local _aVldSaldos := {}
Local _cLocAmox := oFieldZGQ:GetValue("ZGM_LOCALM")
Local _nPos := 0 
Local _nSaldo := 0 
Local _cVldSaldo := ''



If _nOpc == 1 //AGlutinar

DbSelectArea("SB2")
SB2->(DbSetOrder(1))

_cDoc := ACRZGSCD()


    ProcRegua(oGridZGQ:Length())

    For _nX := 1 To  oGridZGQ:Length()
        IncProc("Validando Reg. Selecionados... Por favor, aguarde.")
        oGridZGQ:GoLine( _nX )
        If !oGridZGQ:IsDeleted() .and. oGridZGQ:GetValue( 'ZGQ_MARK' ) 

            If !Empty(oGridZGQ:GetValue( 'ZGQ_CODAGL'))
                Aviso("ATENO", "Foram selecionados registros j aglutinados.", {"Sair"} , 2 , "Verifique os registros selecionados:")
                _lRet := .F.
            EndIf
            If _lRet .and. !Empty(oGridZGQ:GetValue( 'ZGQ_NFESAI')) 
                Aviso("ATENO", "Foram selecionados registros que j geraram nota fiscal.", {"Sair"} , 2 , "Verifique os registros selecionados:")
                _lRet := .F.
            EndIf

            If _lRet .and. oGridZGQ:GetValue( 'ZGQ_RESIDU') == "S" 
                Aviso("ATENO", "Foram selecionados registros com resduo eliminado", {"Sair"} , 2 , "Verifique os registros selecionados:")
                _lRet := .F.
            EndIf  

            If _lRet .and. !Empty( _cFilDest ) 
                If oGridZGQ:GetValue( 'ZGQ_FILORI') <> _cFilDest
                    Aviso("ATENO", "Foram selecionados registros de filiais distintas.", {"Sair"} , 2 , "Verifique os registros selecionados:")
                    _lRet := .F.
                EndIf
            Else
                _cFilDest := oGridZGQ:GetValue( 'ZGQ_FILORI')
            EndIf

            If SuperGetMv("MV_ZGQVSAG",.F.,.T.)
                SB2->(DbGoTop())
                If SB2->(DbSeek(xFilial("SB2") + oGridZGQ:GetValue( 'ZGQ_PROD' ) + _cLocAmox ))
                    _nPos := aScan(_aVldSaldos, {|x| x[2] + x[3] == oGridZGQ:GetValue( 'ZGQ_PROD' ) + _cLocAmox   })
                    If _nPos <> 0 
                        _aVldSaldos[_nPos][4] += oGridZGQ:GetValue( 'ZGQ_QUANT' )  
                    Else
                        aAdd(_aVldSaldos, { xFilial("SB2"), oGridZGQ:GetValue( 'ZGQ_PROD' ), _cLocAmox ,  oGridZGQ:GetValue( 'ZGQ_QUANT' )  }  )
                    EndIf
                EndIf
            EndIF

        EndIf
    Next _nX

    If _lRet .and. SuperGetMv("MV_ZGQVSAG",.F.,.T.) //VALIDA SALDO NO MOMENOTO DA AGLUTINAO? 
        If Len(_aVldSaldos) <> 0
            DbSelectARea("SB2")
            SB2->(DbSetOrder(1))
            _nSaldo := 0
            For _nX := 1 to Len(_aVldSaldos)
                SB2->(DbGoTop())
                If SB2->(DbSeek(_aVldSaldos[_nX][1] + _aVldSaldos[_nX][2] + _aVldSaldos[_nX][3] ))
                    If GetMV("MV_TPSALDO") == "C"
                        _nSaldo := SaldoSB2(,,,,,"SB2")
                    Else
                        _nSaldo := SB2->(  B2_QATU-B2_QACLASS-B2_RESERVA   )
                    EndIf  
                    If _nSaldo < _aVldSaldos[_nX][4]
                        _cVldSaldo += "Prod/Loc: "+SB2->B2_COD+"/"+SB2->B2_LOCAL+" |SB2: "+cValToChar(_nSaldo)+" PV: "+cValToChar(_aVldSaldos[_nX][4])+" | SALDO: "+cValToChar(_nSaldo-_aVldSaldos[_nX][4])+CHAR(13)+CHAR(10)
                    EndIf
                EndIf

            Next _nX 
        EndIf
        If !Empty(_cVldSaldo)
            If Aviso("ATENO: SALDO INSUFICIENTE!",;
                CHAR(13)+CHAR(10)+"Os produtos abaixo no possuem saldo para atender as requisies: ";
                +char(13)+char(10)+_cVldSaldo, {"REVISAR","CONTINUAR"}, 2 ) == 1 
                _lRet := .F.
            EndIf

        EndIf
    EndIf



    If !_lRet 
        FWRestRows( _aSaveLines )
        Return 
    EndIf
    DbSelectArea("ZGO")
    ZGO->(DbSetOrder(1)) //ZGO_FILIAL+ZGO_FILDES+ZGO_PROD+ZGO_GRUPO

    DbSelectArea("SB1")
    SB1->(DbSetOrder(1))
    SB1->(DbgOtOP())

    DbSelectArea("SBM")
    SBM->(DbSetOrder(1))

    ProcRegua(oGridZGQ:Length())

    For _nX := 1 To  oGridZGQ:Length()
        IncProc("Aglutinando Registros selecionados... Por favor, aguarde.")

        oGridZGQ:GoLine( _nX )
        If !oGridZGQ:IsDeleted() .and. oGridZGQ:GetValue( 'ZGQ_MARK' ) 
            ZGO->(DbGoTop())
            If ZGO->(DbSeek(oGridZGQ:GetValue( 'ZGQ_FILORI') + oGridZGQ:GetValue( 'ZGQ_PROD' ) ))
                If Empty(_cNaturez)
                    _cNaturez := ZGO->ZGO_NATSAI
                    _cCondPg := ZGO->ZGO_CONPGS
                EndIf 
                If Empty(_cCondPg)
                    _cCondPg := ZGO->ZGO_CONPGS
                EndIf
            Else
                SB1->(DbGoTop())
                If SB1->(DbSeek(xFilial("SB1") + oGridZGQ:GetValue( 'ZGQ_PROD' ) ))
                    SBM->(DbGoTop())
                    If SBM->(DbSeek(xFilial("SBM") + SB1->B1_GRUPO ))
                        
                        ZGO->(DbSetOrder(2)) //ZGO_FILIAL+ZGO_FILDES+ZGO_GRUPO
                        ZGO->(DbGoTop())
                        If ZGO->(DbSeek(oGridZGQ:GetValue( 'ZGQ_FILORI') + oGridZGQ:GetValue( 'ZGQ_PROD' ) ))
                            If Empty(_cNaturez)
                                _cNaturez := ZGO->ZGO_NATSAI
                                _cCondPg := ZGO->ZGO_CONPGS
                            EndIf 
                            If Empty(_cCondPg)
                                _cCondPg := ZGO->ZGO_CONPGS
                            EndIf                             
                        EndIf
                    EndIf
                EndIf
            EndIf
            If !Empty(_cNaturez)
                Exit
            EndIf
        EndIf
    Next _nX

    ProcRegua(2)
    IncProc("Gerando dados de aglutinao. Por favor, aguarde.")

    _aCliLj := ACZGQCLI(_cFilDest)

    If !Empty(_aCliLj[1]) .and. !Empty(_aCliLj[2])

        oGridZGS:SetNoInsertLine( .F. )
        oGridZGS:SetNoUpdateLine( .F. )
            /*If !Empty(oGridZGS:GetValue("ZGS_CLIENT"))
                _nLineZGS := oGridZGS:AddLine()
            Else
                oGridZGS:DeleteLine()
                _nLineZGS := oGridZGS:AddLine()
            EndIf*/

            _nLineZGS := oGridZGS:AddLine()
            oGridZGS:SetValue( 'ZGS_MARK' ,  .T.                )
            oGridZGS:SetValue( 'ZGS_FILIAL',  xFilial("ZGS")    )
            oGridZGS:SetValue( 'ZGS_CODAGL', _cDoc              )
            oGridZGS:SetValue( 'ZGS_ITEZGM', oModelZGM:GetValue("ZGM_ITEM") )
            oGridZGS:SetValue( 'ZGS_CLIENT', _aCliLj[1]         )
            oGridZGS:SetValue( 'ZGS_LOJA', _aCliLj[2]           )
            oGridZGS:SetValue( 'ZGS_EMISSA', Date()             )
            oGridZGS:SetValue( 'ZGS_FILDES'  , _cFilDest        )
            oGridZGS:SetValue( 'ZGS_APROVA'  , __cUserID        )
            oGridZGS:SetValue( 'ZGS_NATSAI'  , _cNaturez        )
            oGridZGS:SetValue( 'ZGS_CODPGT'  , _cCondPg         )
            
            
            
        If _nLinZGS <  oGridZGS:Length() //Se incluiu a linha, fao o vinculo.
            IncProc("Finalizando aglutinao. Por favor, aguarde.")
            For _nX := 1 To  oGridZGQ:Length() 
                oGridZGQ:GoLine( _nX )
                If !oGridZGQ:IsDeleted() .and. oGridZGQ:GetValue( 'ZGQ_MARK' ) 
                    If _nFirst == 0 
                        _nFirst := _nX
                    EndIf
                    oGridZGQ:LoadValue( 'ZGQ_CODAGL', _cDoc ) 
                    oGridZGQ:LoadValue( 'ZGQ_MARK', .F. )  //Desmarco todos
                    oView:Refresh("MdGridZGQ")
                EndIf
            Next _nX 
            
            If oGridZGQ:Length()  <> 0 
                oGridZGQ:GoLine( 1 )
            EndIf
            
            oView:Refresh("MdGridZGQ")
            oView:Refresh("MdGridZGS")
            oView:Refresh()

            If _lRet
                FwFormCommit(oModel)
            EndIf            

            FWRestRows( _aSaveLines )

        EndIf
    Else
        Aviso("ATENO", "No existe um cliente vinculado a filial da requisio "+_cFilDest+CHAR(13)+CHAR(10);
                +" preciso que exista um cliente ativo com o cdigo da filial informado no campo |A1_FILTRF - Fil. Transf.|", {"Sair"} ,;
                 2 , "Verifique os registros selecionados:")
        Return 
    EndIf
Else //DESAGLUTINAR
    ProcRegua(oGridZGS:Length())

    For _nX := 1 To  oGridZGS:Length()
        IncProc("Validando Reg. Selecionados... Por favor, aguarde.")
        oGridZGS:GoLine( _nX )
        If !oGridZGS:IsDeleted() .and. oGridZGS:GetValue( 'ZGS_MARK' ) 
            If !Empty(oGridZGS:GetValue( 'ZGS_FORNEC'))
                Aviso("ATENO", "Cod. Aglutinao j gerou Doc. Entrada!", {"Sair"} , 2 , "Verifique os registros selecionados:")
                _lRet := .F.
            EndIf
            If !Empty(oGridZGS:GetValue( 'ZGS_DOCSAI'))
                Aviso("ATENO", "Cod. Aglutinao j gerou Doc. Saida!", {"Sair"} , 2 , "Verifique os registros selecionados:")
                _lRet := .F.
            EndIf   
            If !Empty(oGridZGS:GetValue( 'ZGS_PEDIDO'))
                Aviso("ATENO", "Cod. Aglutinao j gerou pedido de venda!", {"Sair"} , 2 , "Verifique os registros selecionados:")
                _lRet := .F.
            EndIf                       
        EndIf
    Next _nX

    If !_lRet 
        Return 
    EndIf
    //oModel:GetModel( 'MdGridZGS' ):SetNoInsertLine( .F. )
    //oModel:GetModel( 'MdGridZGS' ):SetNoUpdateLine( .F. )

    For _nX := 1 To  oGridZGS:Length()
        IncProc("Validando Reg. Selecionados... Por favor, aguarde.")
        oGridZGS:GoLine( _nX )
        If !oGridZGS:IsDeleted() .and. oGridZGS:GetValue( 'ZGS_MARK' ) 
            If oGridZGS:DeleteLine()
                If !Empty(oGridZGS:GetValue( 'ZGS_CODAGL' ))
                    aAdd(_aCodAgl, oGridZGS:GetValue( 'ZGS_CODAGL' ))
                EndIf
                FwFormCommit(oModel)
            Else 
                _lRet := .F.
                Aviso("ATENO", "No foi possvel desaglutinar o cdigo: "+oGridZGS:GetValue('ZGS_CODAGL'), {"Sair"} , 2 , "Verifique os registros selecionados:")
                Exit
            EndIf
        EndIf
    Next _nX

    If _lRet 
        For _nX := 1 to Len(_aCodAgl)
            For _nY := 1 To  oGridZGQ:Length()
                oGridZGQ:GoLine( _nY )
                If !oGridZGQ:IsDeleted() .and. Alltrim(oGridZGQ:GetValue( 'ZGQ_CODAGL' )) == Alltrim(_aCodAgl[_nX])
                    oGridZGQ:LoadValue( 'ZGQ_CODAGL',Space(TamSx3("ZGQ_CODAGL")[1])) 
                    oView:Refresh("MdGridZGQ")
                EndIf
            Next _nY 
        Next _nX 
    EndIf


    oView:Refresh("MdGridZGS")
    oView:Refresh("MdGridZGQ")
    oView:Refresh() 

    If _lRet
        FwFormCommit(oModel)
    EndIf
    
EndIf

FWRestRows( _aSaveLines )

oModel := FWModelActive()
oModel:DeActivate() 
oModel:SetOperation(4) 
oModel:Activate()


oView:Refresh("MdFieldZGM")
oView:Refresh("MdGridZGQ")
oView:Refresh("MdGridZGS")
oView:Refresh("MdGridZGR")

//ANDRE CLARO 20240525   oView:Refresh("MdGridSD2")


Return 

//FUNO RESPONSVEL POR GERAR A INTEGRAO DOS AGLUTINADOS EM UM DOC DE SADA.
Static Function ACZGOATN(oView)

Local _nX := ''
Local _nS := ''
Local _aCabec := {}
Local _aItens := {}
Local _aLinha := {}
Local _cAgluts := ''
Local _cAlias := ''
Local _cQuery := ''
Local _cSeq := ''
Local _aNotas := {}
Local _nPreco := 0
Local _cCliente := ''
Local _cLjCli := ''
Local _cNatSai := ''
Local _cNatEnt := ''
Local _cCondPgS := ''
Local _cCondPgE := ''
Local _cFilDest := ''
Local _cFornece := ''
Local _aForLj := {}
Local _cLjFor := ''
Local _cSerNota := SuperGetMv("MV_ZSERTRF",.F.,"", cFilAnt)
Local _cCabNFe := {}
Local _cPedido := ''
Local _cFilOrig := cFilAnt
Local _nQuantos := 0
Local _cCodAgl := ''
Local oModel := FWModelActive() 
Local oGridZGQ	:= oModel:GetModel("MdGridZGQ")
Local oGridZGS	:= oModel:GetModel("MdGridZGS")
Local oGridZGR	:= oModel:GetModel("MdGridZGR")
Local _nPendNFE := 0 //Sem sada/1=saida/2-entrada // se chegar no final s com a sada ok, chamo a reentrada
Local oFieldZGQ	:= oModel:GetModel("MdFieldZGM")
Local _cLocAmox := oFieldZGQ:GetValue("ZGM_LOCALM")
Local _aVldSaldos := {}
Local _nSaldo := 0 
Local _cVldSaldo := ''
Local _nPos := 0 

//Local oFieldZGQ	:= oModel:GetModel("MdFieldZGM")
//Local _cLocAmox := oFieldZGQ:GetField("ZGM_LOCALM") // - CENTRO DE DISTRIBUO

    For _nX := 1 To  oGridZGS:Length()
        oGridZGS:GoLine( _nX )
        If !oGridZGS:IsDeleted() .and. oGridZGS:GetValue( 'ZGS_MARK' ) 
            If !Empty(oGridZGS:GetValue( 'ZGS_PEDIDO')) .OR. !Empty(oGridZGS:GetValue( 'ZGS_DOCSAI'))
                Aviso("ATENO", "Foram selecionados itens que j geraram pedido de venda!", {"Sair"} , 2 , "Verifique os registros selecionados:")
                Return 
            EndIf
            _nQuantos ++
            If !Empty(oGridZGS:GetValue( 'ZGS_CODAGL'))
                _cAgluts += oGridZGS:GetValue( 'ZGS_CODAGL')+';'

                _cCodAgl := oGridZGS:GetValue( 'ZGS_CODAGL')
            EndIf

            If Empty(_cFilDest)
                _cFilDest := oGridZGS:GetValue( 'ZGS_FILDES') 
            EndIf

            If Empty(_cFornece)
                _aForLj := ACZGQFOR(cFilAnt)
                _cFornece := _aForLj[1]
                _cLjFor := _aForLj[2]
            EndIf

            If Empty(_cCliente)
                _cCliente := oGridZGS:GetValue( 'ZGS_CLIENT')
            EndIf

            If Empty(_cLjCli)
                _cLjCli := oGridZGS:GetValue( 'ZGS_LOJA') 
            EndIf


                If Empty(_cNatSai)
                    _cNatSai := oGridZGS:GetValue( 'ZGS_NATSAI')  // Natureza Saida
                EndIf
                
                If Empty(_cCondPgS)
                    _cCondPgS := oGridZGS:GetValue( 'ZGS_CODPGT') //Cond. Saida
                EndIf

        EndIf
    Next _nX 

    If _nQuantos <> 1 
        Aviso("ATENO", "Foram selecionados mais de um cdigo de aglutinao. Para que possa ser rastreado, cada cdigo dever gerar um documento de sada!", {"Sair"} , 2 , "Verifique os registros selecionados:")
        Return 
    EndIf

    If !Empty(_cAgluts) 
        _cAlias := GetNextAlias()

        _cQuery := " "
        _cQuery += "  SELECT COUNT(*) AS CONTADOR   "
        _cQuery += "  FROM 	(SELECT DISTINCT ZGS.ZGS_CLIENT, ZGS.ZGS_LOJA, ZGS.ZGS_FILDES   "
        _cQuery += "  		 FROM "+RetSqlName("ZGS")+" ZGS  "
        _cQuery += "  		 WHERE ZGS.D_E_L_E_T_ = '' AND ZGS.ZGS_FILIAL = '"+xFilial("ZGS")+"' AND ZGS.ZGS_CODAGL <> '' AND ZGS.ZGS_CODAGL IN "+FormatIn(_cAgluts,";") 

//        _cQuery += " UNION ALL SELECT 'FATURADO' AS ZGS_CLIENT, 'LOJA' AS ZGS_LOJA, 'FILIAL' AS ZGS_FILDES   "
//        _cQuery += "  		 FROM "+RetSqlName("ZGS")+" ZGS  "
//        _cQuery += "  		 WHERE ZGS.D_E_L_E_T_ = '' AND ZGS_DOCSAI <> '' AND ZGS.ZGS_CODAGL IN "+FormatIn(_cAgluts,";") 
        
        _cQuery += " ) AS TEMP "

        MPSysOpenQuery( _cQuery, _cAlias )

        If (_cAlias)->CONTADOR <> 1 
            Aviso("ATENO", "Foram selecionados itens com informaes distintas ou j faturados. CLIENTE / LOJA / FILIAL DESTINO devem ser iguais.", {"Sair"} , 2 , "Verifique os registros selecionados:")
            Return 
        Else
            /*
            _aCabec := {}
            aAdd(_aCabec, {"C5_TIPO"		, "N"			, Nil })
            aAdd(_aCabec, {"C5_CLIENTE"	, _cCliente	 , Nil })
            aAdd(_aCabec, {"C5_LOJACLI"	, _cLjCli	 , Nil })
            aAdd(_aCabec, {"C5_NATUREZ"	, _cNatSai	 , Nil })
            aAdd(_aCabec, {"C5_ESPECI1"	, "VOL"	     , Nil })
            aAdd(_aCabec, {"C5_CONDPAG"	, _cCondPgS	 , Nil })
            aAdd(_aCabec, {"C5_VOLUME1"	, 1	 		 , Nil }) // Dado adicional solicitado pelo cliente piloto bom futuro
            aAdd(_aCabec, {"C5_ZCGC"	, "ACMVCZGQ" , Nil })
            aAdd(_aCabec, {"C5_ZCODAGL"	, _cCodAgl , Nil })
            */
        EndIf
        (_cAlias)->(DbCloseArea())

        _cAlias := GetNextAlias()
        _cQuery := " "
       
        _cQuery += " SELECT  ZGQ.ZGQ_FILORI AS C6_FILIAL,  "
        _cQuery += " 		ZGQ.ZGQ_PROD AS C6_PRODUTO,  "
        _cQuery += " 		ZGO.ZGO_LOCSAI AS C6_LOCAL, ZGO.ZGO_TS AS C6_TES, "
        _cQuery += " 		ZGQ.ZGQ_CC AS C6_CC,  ZGO_NATENT, ZGO_NATSAI, ZGO_CONPGS, ZGO_CONPGE,
        _cQuery += " 		SUM(ZGQ.ZGQ_QUANT) AS C6_QTDVEN  " 
        _cQuery += " FROM		"+RetSqlName("ZGS")+" ZGS WITH(NOLOCK) INNER JOIN "+RetSqlName("ZGQ")+" ZGQ WITH(NOLOCK) ON  "
        _cQuery += " 			ZGS.ZGS_FILIAL = '"+xFilial("ZGS")+"'  "
        _cQuery += " 		AND ZGS.ZGS_CODAGL = ZGQ.ZGQ_CODAGL  "
        _cQuery += " 		AND ZGS.ZGS_FILDES = ZGQ.ZGQ_FILORI  "
        _cQuery += " 		AND ZGQ.D_E_L_E_T_ = ''  "
        _cQuery += " 			INNER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON  "
        _cQuery += " 			SB1.B1_FILIAL = '"+xFilial("SB1")+"'  "
        _cQuery += " 		AND SB1.B1_COD = ZGQ.ZGQ_PROD  "
        _cQuery += " 		AND SB1.D_E_L_E_T_ = ''  "
        _cQuery += " 			 OUTER APPLY 
        _cQuery += " 			 				(SELECT * 
        _cQuery += " 			 				FROM 
        _cQuery += " 			 				(SELECT 	* ,ROW_NUMBER() OVER (
        _cQuery += " 			 							ORDER BY ZGO.ZGO_PROD DESC
        _cQuery += " 			 								,ZGO.ZGO_GRUPO
        _cQuery += " 			 							) AS LINHA
        _cQuery += " 			 				FROM 	"+RetSqlName("ZGO")+" ZGO "
        _cQuery += " 			 				WHERE 		ZGO.D_E_L_E_T_ = '' AND ZGO.ZGO_FILIAL = '"+xFilial("ZGO")+"'  "
        _cQuery += " 			 						AND ZGO.ZGO_FILDES = ZGQ.ZGQ_FILORI
        _cQuery += " 			 						AND (ZGO.ZGO_PROD  = ZGQ.ZGQ_PROD OR 
        _cQuery += " 			 				        	( ZGO.ZGO_PROD = '' AND ZGO.ZGO_GRUPO = SB1.B1_GRUPO AND ZGO.ZGO_GRUPO <> '' ) )		
                                
        _cQuery += " 					) AS BASE  "
        _cQuery += " 					WHERE BASE.LINHA = 1 ) AS ZGO  "
        _cQuery += " WHERE		ZGS.D_E_L_E_T_ = '' AND ZGS.ZGS_FILIAL = '"+xFilial("ZGS")+ "'  "
        _cQuery += " 		AND ZGS.ZGS_CODAGL IN "+FormatIn(_cAgluts,";")+"   "
        _cQuery += "  GROUP BY 	ZGQ.ZGQ_FILORI,ZGQ.ZGQ_PROD,ZGO.ZGO_LOCSAI,ZGQ.ZGQ_CC,ZGO.ZGO_TS,ZGO_NATENT, ZGO_NATSAI, ZGO_CONPGS, ZGO_CONPGE, ZGO.ZGO_PROD, ZGO.ZGO_GRUPO

        MPSysOpenQuery( _cQuery, _cAlias )

        If (_cAlias)->(!eof())
            While (_cAlias)->(!eof())

                If Empty(_cNatSai)
                    _cNatSai := (_cAlias)->ZGO_NATSAI // Natureza Saida
                EndIf
                
                If Empty(_cNatEnt)
                    _cNatEnt := (_cAlias)->ZGO_NATENT // Natureza Entrada
                EndIf

                If Empty(_cCondPgS)
                    _cCondPgS := (_cAlias)->ZGO_CONPGS //Cond. Saida
                EndIf

                If Empty(_cCondPgE)
                    _cCondPgE := (_cAlias)->ZGO_CONPGE //Cond. Entrada
                EndIf

                If Empty(_cSeq)
                    _cSeq := "01"
                Else
                    _cSeq := Soma1(_cSeq) //Somo 1 
                EndIf
                _nPreco := 0 
                _nPreco := U_ZCDZGCPR((_cAlias)->C6_PRODUTO)

                /// tratamento solicitado em 26/03/2024 - para que considere o custo mdio para transferencias
                DbSelectArea("SB2")
                SB2->(DbSetOrder(1))
                SB2->(DbGoTop())
                If SB2->(DbSeek(xFilial("SB2") + (_cAlias)->C6_PRODUTO + _cLocAmox ))
                    _nPos := aScan(_aVldSaldos, {|x| x[2] + x[3] == (_cAlias)->C6_PRODUTO + _cLocAmox   })
                    If _nPos <> 0 
                        _aVldSaldos[_nPos][4] += (_cAlias)->C6_QTDVEN
                    Else
                        aAdd(_aVldSaldos, { xFilial("SB2"), (_cAlias)->C6_PRODUTO, _cLocAmox ,  (_cAlias)->C6_QTDVEN }  )
                    EndIf
                    If SB2->B2_CM1 > 0 
                        _nPreco := SB2->B2_CM1
                    EndIf
                EndIf
                _aLinha := {}
                aAdd(_aLinha, { "C6_ITEM", _cSeq, Nil } )
                aAdd(_aLinha, { "C6_PRODUTO", (_cAlias)->C6_PRODUTO, Nil } )
                aAdd(_aLinha, { "C6_LOCAL", _cLocAmox  , Nil } )
                aAdd(_aLinha, { "C6_QTDVEN", (_cAlias)->C6_QTDVEN	, Nil } )
                aAdd(_aLinha, { "C6_QTDLIB", (_cAlias)->C6_QTDVEN	, Nil } )
                aAdd(_aLinha, { "C6_PRCVEN", _nPreco		, Nil } )
                aAdd(_aLinha, { "C6_VALOR",  Round( (_cAlias)->C6_QTDVEN * _nPreco , 2 )      , Nil } ) 
                aAdd(_aLinha, { "C6_TES",   (_cAlias)->C6_TES  , Nil } )
                aAdd(_aLinha, { "C6_CC",   (_cAlias)->C6_CC  , Nil } )

                aAdd(_aItens, _aLinha)
                If Len(_aItens) == 99 
                    aAdd(_aNotas, _aItens ) 
                    _aItens := {}
                EndIf

            (_cAlias)->(DbSkip())
            EndDo
        Else
            Aviso("ATENO", "Revise o cadastro @ Cad. Regras p/ NF Sai/Ent CD referente aos produtos dessa aglutinao", {"Sair"} , 2 , "Verifique os registros selecionados:")
            Return         
        EndIf

        If Len(_aItens) > 0 
            If Len(_aVldSaldos) <> 0
                DbSelectARea("SB2")
                SB2->(DbSetOrder(1))
                _nSaldo := 0
                For _nX := 1 to Len(_aVldSaldos)
                    SB2->(DbGoTop())
                    If SB2->(DbSeek(_aVldSaldos[_nX][1] + _aVldSaldos[_nX][2] + _aVldSaldos[_nX][3] ))
                        If GetMV("MV_TPSALDO") == "C"
                            _nSaldo := SaldoSB2(,,,,,"SB2")
                        Else
                            _nSaldo := SB2->(  B2_QATU-B2_QACLASS-B2_RESERVA   )
                        EndIf  
                        If _nSaldo < _aVldSaldos[_nX][4]
                            _cVldSaldo += "Prod/Loc: "+SB2->B2_COD+"/"+SB2->B2_LOCAL+" |SB2: "+cValToChar(_nSaldo)+" PV: "+cValToChar(_aVldSaldos[_nX][4])+" | SALDO: "+cValToChar(_nSaldo-_aVldSaldos[_nX][4])+CHAR(13)+CHAR(10)
                        EndIf
                    EndIf
                Next _nX 
            EndIf
            If !Empty(_cVldSaldo)
                Aviso("ATENO: SALDO INSUFICIENTE!",;
                CHAR(13)+CHAR(10)+"Os produtos abaixo no possuem saldo para atender as requisies: ";
                +char(13)+char(10)+_cVldSaldo, {"REVISAR"}, 2 )
                Return
            Else
                aAdd(_aNotas, _aItens )
            EndIf

            
        EndIf

        _aCabec := {}
        aAdd(_aCabec, {"C5_TIPO"		, "N"			, Nil })
        aAdd(_aCabec, {"C5_CLIENTE"	, _cCliente	 , Nil })
        aAdd(_aCabec, {"C5_LOJACLI"	, _cLjCli	 , Nil })
        aAdd(_aCabec, {"C5_NATUREZ"	, _cNatSai	 , Nil })
        aAdd(_aCabec, {"C5_ESPECI1"	, "VOL"	     , Nil })
        aAdd(_aCabec, {"C5_CONDPAG"	, _cCondPgS	 , Nil })
        aAdd(_aCabec, {"C5_VOLUME1"	, 1	 		 , Nil }) // Dado adicional solicitado pelo cliente piloto bom futuro
        aAdd(_aCabec, {"C5_ZCGC"	, "ACMVCZGQ" , Nil })
        aAdd(_aCabec, {"C5_ZCODAGL"	, _cCodAgl , Nil })   
		//aAdd(_aCabec, {"C5_ZEXCNF"	, "S" , Nil })   //Se excluir a nota fiscal, j exclui o pedido junto!

        aAdd(_aCabec, {"C5_TPFRETE"	, "C" , Nil })    //CIF

        If Len(_aCabec) > 0 
            For _nX := 1 to Len(_aNotas)
                    // Incluso do pedido de vendas
                    _cPedido := ZPVINC(_cFilOrig, _aCabec, _aNotas[_nX])
                    If !empty(_cPedido)

                        
                        //// ATUALIZANDO NUMERO DO PEDIDO NA TABELA DE AGLUTINADORES
                        For _nX := 1 To  oGridZGS:Length()
                            oGridZGS:GoLine( _nX )
                            If !oGridZGS:IsDeleted() .and. oGridZGS:GetValue( 'ZGS_MARK' )    
                                oGridZGS:LoadValue( 'ZGS_PEDIDO', _cPedido ) 
                                oView:Refresh("MdGridZGS")
                            EndIf
                        Next _nX  

                        //// ATUALIZANDO RASTREAMENTO LOG POR ITENS DE REQUISIO.
                        For _nX := 1 To  oGridZGQ:Length()
                            oGridZGQ:GoLine( _nX )
                            If !oGridZGQ:IsDeleted()   
                                If Alltrim( oGridZGQ:GetValue( 'ZGQ_CODAGL' ) ) == Alltrim(_cCodAgl)
                                    // Adicionando rastreamento do pedido de vendas 
                                    oModel:GetModel( 'MdGridZGR' ):SetNoInsertLine( .F. )
                                    oModel:GetModel( 'MdGridZGR' ):SetNoUpdateLine( .F. )
                                    DbSelectArea("ZGR")
                                    ZGR->(DbSetOrder(3)) // filial + operao + chv origem
                                    ZGR->(DbGoTop())
                                    If !ZGR->(DbSeek(xFilial("ZGR") + "PV" + _cPedido ))

                                        oGridZGR:AddLine()
                                            oGridZGR:SetValue( 'ZGR_FILIAL',  xFilial("ZGR") )
                                            oGridZGR:SetValue( 'ZGR_CODREQ', oGridZGQ:GetValue( 'ZGQ_CODREQ' ) )
                                            oGridZGR:SetValue( 'ZGR_ITEM', oGridZGQ:GetValue( 'ZGQ_ITEM' ) )
                                            oGridZGR:SetValue( 'ZGR_OPERAC', 'PV'    )
                                            oGridZGR:SetValue( 'ZGR_NUMDOC', _cPedido   )
                                            oGridZGR:SetValue( 'ZGR_FILORI'  , oGridZGQ:GetValue( 'ZGQ_FILORI' ) )
                                            oGridZGR:SetValue( 'ZGR_CHVORI'  , _cPedido       )

                                            oGridZGR:SetValue( 'ZGR_USER'  , __cUserID        )
                                            oGridZGR:SetValue( 'ZGR_NOMUSR'  , cUserName        )
                                            oGridZGR:SetValue( 'ZGR_DTLOG'  , Date()        )
                                            oGridZGR:SetValue( 'ZGR_HRLOG'  , SubStr(Time(),1,5)        )
                                            oGridZGR:SetValue( 'ZGR_STATUS'  , 'A'        )
                                    EndIf
                                    oView:Refresh("MdGridZGR")
                                    oModel:GetModel( 'MdGridZGR' ):SetNoInsertLine( .T. )
                                    oModel:GetModel( 'MdGridZGR' ):SetNoUpdateLine( .T. )
                                EndIf
                            EndIF
                        Next _nX  

                        // Gerao do documento de sada 
                        _aRetNFS := {}
                        // Retorno 3 posies / 1 - se gerou a nota ,2-numero da nota, 3-serie
                        _aRetNFS := GravaNF(_cFilOrig, _cPedido, _cSerNota) 
                        If  _aRetNFS[1]   // Se gravou a NF de sada, vou perguntar se deseja gravar a de entrada
                            _nPendNFE := 1 //gerou NF sada
                            //// ATUALIZANDO NUMERO DA NOTA FISCAL DE ENTRADA NA TABELA DE AGLUTINADORES
                            For _nX := 1 To  oGridZGS:Length()
                                oGridZGS:GoLine( _nX )
                                If !oGridZGS:IsDeleted() .and. oGridZGS:GetValue( 'ZGS_MARK' )    
                                    oGridZGS:LoadValue( 'ZGS_DOCSAI', _aRetNFS[2] ) 
                                    oGridZGS:LoadValue( 'ZGS_SERSAI', _aRetNFS[3] ) 
                                    oView:Refresh("MdGridZGS")
                                EndIf
                            Next _nX  

                            //// ATUALIZANDO RASTREAMENTO LOG POR ITENS DE REQUISIO.
                            For _nX := 1 To  oGridZGQ:Length()
                                oGridZGQ:GoLine( _nX )
                                If !oGridZGQ:IsDeleted()
                                    If Alltrim( oGridZGQ:GetValue( 'ZGQ_CODAGL' ) ) == Alltrim(_cCodAgl)
                                        // Adicionando rastreamento do pedido de vendas 
                                        oModel:GetModel( 'MdGridZGR' ):SetNoInsertLine( .F. )
                                        oModel:GetModel( 'MdGridZGR' ):SetNoUpdateLine( .F. )

                                        DbSelectArea("ZGR")
                                        ZGR->(DbSetOrder(3)) // filial + operao + chv origem
                                        ZGR->(DbGoTop())
                                        If !ZGR->(DbSeek(xFilial("ZGR") + "D2" + _aRetNFS[2]  + _aRetNFS[3] + _cCliente + _cLjCli  ))                                        

                                            oGridZGR:AddLine()
                                                oGridZGR:SetValue( 'ZGR_FILIAL',  xFilial("ZGR") )
                                                oGridZGR:SetValue( 'ZGR_CODREQ', oGridZGQ:GetValue( 'ZGQ_CODREQ' ) )
                                                oGridZGR:SetValue( 'ZGR_ITEM', oGridZGQ:GetValue( 'ZGQ_ITEM' ) )
                                                oGridZGR:SetValue( 'ZGR_OPERAC', 'D2'    )
                                                oGridZGR:SetValue( 'ZGR_NUMDOC', _aRetNFS[2]   )
                                                oGridZGR:SetValue( 'ZGR_FILORI'  , oGridZGQ:GetValue( 'ZGQ_FILORI' ) )
                                                oGridZGR:SetValue( 'ZGR_CHVORI'  , _aRetNFS[2]  + _aRetNFS[3] + _cCliente + _cLjCli       )
                                                oGridZGR:SetValue( 'ZGR_USER'  , __cUserID        )
                                                oGridZGR:SetValue( 'ZGR_NOMUSR'  , cUserName        )
                                                oGridZGR:SetValue( 'ZGR_DTLOG'  , Date()        )
                                                oGridZGR:SetValue( 'ZGR_HRLOG'  , SubStr(Time(),1,5)        )
                                                oGridZGR:SetValue( 'ZGR_STATUS'  , 'A'        )
                                                oView:Refresh("MdGridZGR")
                                        EndIf
                                        
                                        oGridZGQ:LoadValue( 'ZGQ_NFESAI'  ,   _aRetNFS[2]     )
                                        oView:Refresh("MdGridZGQ")

                                        oModel:GetModel( 'MdGridZGR' ):SetNoInsertLine( .T. )
                                        oModel:GetModel( 'MdGridZGR' ):SetNoUpdateLine( .T. )
                                    EndIf
                                EndIF
                            Next _nX  

                            If ACGERNFE(_aRetNFS, _cFilOrig,_cFilDest, _cCliente, _cLjCli,_cFornece,_cLjFor,_cCondPgE,_cNatEnt, .F.  )

                                //// ATUALIZANDO NUMERO DA NOTA FISCAL DE SADA NA TABELA DE AGLUTINADORES
                                For _nX := 1 To  oGridZGS:Length()
                                    oGridZGS:GoLine( _nX )
                                    If !oGridZGS:IsDeleted() .and. oGridZGS:GetValue( 'ZGS_MARK' )    
                                        oGridZGS:SetValue( 'ZGS_FORNEC', _cFornece ) 
                                        oGridZGS:SetValue( 'ZGS_LJFORN', _cLjFor   ) 

                                        oView:Refresh("MdGridZGS")
                                    EndIf
                                Next _nX  

                                // Adicionando rastreamento do pedido de vendas 
                                oModel:GetModel( 'MdGridZGR' ):SetNoInsertLine( .F. )
                                oModel:GetModel( 'MdGridZGR' ):SetNoUpdateLine( .F. )
                                DbSelectArea("ZGR")
                                ZGR->(DbSetOrder(3)) // filial + operao + chv origem
                                ZGR->(DbGoTop())
                                If !ZGR->(DbSeek(xFilial("ZGR") + "D1" + _aRetNFS[2]  + _aRetNFS[3] +_cFornece + _cLjFor ))
                                    oGridZGR:AddLine()
                                        oGridZGR:SetValue( 'ZGR_FILIAL',  xFilial("ZGR") )
                                        oGridZGR:SetValue( 'ZGR_CODREQ', oGridZGQ:GetValue( 'ZGQ_CODREQ' ) )
                                        oGridZGR:SetValue( 'ZGR_ITEM', oGridZGQ:GetValue( 'ZGQ_ITEM' ) )
                                        oGridZGR:SetValue( 'ZGR_OPERAC', 'D1'    )
                                        oGridZGR:SetValue( 'ZGR_NUMDOC', _aRetNFS[2]   )
                                        oGridZGR:SetValue( 'ZGR_FILORI'  , oGridZGQ:GetValue( 'ZGQ_FILORI' ) )
                                        oGridZGR:SetValue( 'ZGR_CHVORI'  , _aRetNFS[2]  + _aRetNFS[3] +_cFornece + _cLjFor        )
                                        oGridZGR:SetValue( 'ZGR_USER'  , __cUserID        )
                                        oGridZGR:SetValue( 'ZGR_NOMUSR'  , cUserName        )
                                        oGridZGR:SetValue( 'ZGR_DTLOG'  , Date()        )
                                        oGridZGR:SetValue( 'ZGR_HRLOG'  , SubStr(Time(),1,5)        )
                                        oGridZGR:SetValue( 'ZGR_STATUS'  , 'A'        )
                                
                                        oGridZGQ:LoadValue( 'ZGQ_NFEENT'  ,   _aRetNFS[2]     )                                
                                EndIf

                                oView:Refresh("MdGridZGQ")

                                oModel:GetModel( 'MdGridZGR' ):SetNoInsertLine( .T. )
                                oModel:GetModel( 'MdGridZGR' ):SetNoUpdateLine( .T. )
                                _nPendNFE := 2
                            EndIf
                        EndIf
                    EndIf
            Next _nX 

            If _nPendNFE <> 1 
                For _nX := 1 To  oGridZGS:Length()
                    oGridZGS:GoLine( _nX )
                    If !oGridZGS:IsDeleted() 
                        oGridZGS:LoadValue( 'ZGS_MARK', .F. )
                    EndIf
                Next _nX
            EndIf
            
            oGridZGQ:GoLine( 1 )
            oGridZGS:GoLine( 1 )

            oView:Refresh("MdGridZGS")
            oView:Refresh()

        Else
            Aviso("ATENO", "No h dados para gerao do PEDIDO / NOTA FISCAL DE SADA!", {"Sair"} , 2 , "Verifique os registros selecionados:")
            Return 
        EndIf
    EndIf

// Atualizo o modelo com o que foi ajustado
FwFormCommit(oModel)
oView:Refresh("MdFieldZGM")
//oView:Refresh("MdGridZGQ")
oView:Refresh("MdGridZGS")
oView:Refresh("MdGridZGR")

//ANDRE CLARO 20240525   oView:Refresh("MdGridSD2")
oView:Refresh()

If _nPendNFE == 1 //S gerou a sada
    ACZGOREE(oView)

    For _nX := 1 To  oGridZGS:Length()
        oGridZGS:GoLine( _nX )
        If !oGridZGS:IsDeleted() 
            oGridZGS:LoadValue( 'ZGS_MARK', .F. )
        EndIf
    Next _nX     
    
    oGridZGQ:GoLine( 1 )
    oGridZGS:GoLine( 1 )

    oView:Refresh("MdGridZGS")
    oView:Refresh()

EndIf

Return 


///// GERAO DA SOLICITAO DE COMPRAS
Static Function ACZGOSC( oView)
    
Local _aLinhaC1 := {}
Local _aItensSC := {}
Local _aCabSC := {}
Local _cDoc := ''
Local _nX := 1 
Local _cCC_CD := SuperGetMv("MV_ZCCUSCD",.F.,'1118')

Local oModel := FWModelActive() 
Local oGridZGQ	:= oModel:GetModel("MdGridZGQ")

Local oFieldZGQ	:= oModel:GetModel("MdFieldZGM")
Local _cLocAmox := oFieldZGQ:GetValue("ZGM_LOCALM") // - CENTRO DE DISTRIBUO
//Local oModelCAb := oModel:GetModel("MdFieldZGM")
Local _aSaveLines:= FWSaveRows()

For _nX := 1 To  oGridZGQ:Length()
    oGridZGQ:GoLine( _nX )
    If !oGridZGQ:IsDeleted() .and. oGridZGQ:GetValue( 'ZGQ_MARK' ) 
        _aLinhaC1 := {}

        aadd(_aLinhaC1,{"C1_ITEM"   , StrZero(_nX,TamSx3("C1_ITEM")[1]) ,  Nil  })
        aadd(_aLinhaC1,{"C1_PRODUTO", oGridZGQ:GetValue( 'ZGQ_PROD' )                       , Nil})
        aadd(_aLinhaC1,{"C1_QUANT"  , oGridZGQ:GetValue( 'ZGQ_QUANT' )    , Nil})
        aadd(_aLinhaC1,{"C1_ZUPRC"  , U_ZCDZGCPR(oGridZGQ:GetValue( 'ZGQ_PROD' ))    , Nil})
        //aadd(_aLinhaC1,{"C1_PRECO"  , (oMSNewGe1:aCols[_nX][_nPosVlr] / oMSNewGe1:aCols[_nX][_nPosQtd]  )  , Nil})
        aadd(_aLinhaC1,{"C1_LOCAL"  , _cLocAmox    , Nil})

        aadd(_aLinhaC1,{"C1_ZTIPOSC"  , "O"    , Nil})
        aadd(_aLinhaC1,{"C1_ZAPLDIR"  , "S"    , Nil}) ///SEMPRE SER ESTOQUE / REUNIO DE 26/03/2024
//        aadd(_aLinhaC1,{"C1_CC"     , oGridZGQ:GetValue( 'ZGQ_CC' )                  , Nil})
        aadd(_aLinhaC1,{"C1_CC"     , _cCC_CD                 , Nil})
        aadd(_aLinhaC1,{"C1_XSERVI"     , "N"                 , Nil})
        aadd(_aLinhaC1,{"C1_ORIGEM"     , "ACMVCZGQ"          , Nil})

        aadd(_aLinhaC1,{"C1_OBS" , "Ref. Req. CD "+oGridZGQ:GetValue( 'ZGQ_CODREQ' )+"/"+oGridZGQ:GetValue( 'ZGQ_ITEM' ) ,Nil})
        aadd(_aLinhaC1,{"C1_ZREQCD"  , oGridZGQ:GetValue( 'ZGQ_CODREQ' ) + oGridZGQ:GetValue( 'ZGQ_ITEM' )   , Nil})
        aadd(_aItensSC,_aLinhaC1)

        oGridZGQ:SetValue( 'ZGQ_ITEMSC', StrZero(_nX,TamSx3("C1_ITEM")[1])  )
    EndIf
Next _nX

FWRestRows( _aSaveLines )

Private lMsErroAuto := .F.
    
    DbSelectArea("SC1")
    SC1->(DbSetOrder(1))
    SC1->(DbGoTop())

    While .T.
        _cDoc := ""
        _cDoc := GetSXENum("SC1","C1_NUM")
        SC1->(dbGoTop())
        If SC1->(dbSeek(xFilial("SC1") + _cDoc ))
            ConfirmSX8()
        Else
            Exit
        EndIf
    EndDo

    aadd(_aCabSC,{"C1_NUM"       ,_cDoc       })
    aadd(_aCabSC,{"C1_SOLICIT"   ,cUserName  })
    aadd(_aCabSC,{"C1_EMISSAO"   ,dDataBase  })

    MSExecAuto({|x,y| mata110(x,y,3)}, _aCabSC , _aItensSC)
    If lMsErroAuto
        MostraErro()
    Else
        DbSelectArea("ZGQ")
        ZGQ->(DbSetOrder(1))
        DbSelectArea("ZGQ")
                
        
        For _nX := 1 To  oGridZGQ:Length()
            oGridZGQ:GoLine( _nX )
            If !oGridZGQ:IsDeleted() .and. oGridZGQ:GetValue( 'ZGQ_MARK' ) 
                ZGQ->(DbGoTop())
                If ZGQ->(DbSeek(xFilial("ZGQ") + oGridZGQ:GetValue( 'ZGQ_CODREQ' )+ oGridZGQ:GetValue( 'ZGQ_ITEM' )   ))
                    oGridZGQ:LoadValue( 'ZGQ_NUMSC', _cDoc  )
                    If  ZGQ->(RecLock("ZGQ",.F.))
                            ZGQ->ZGQ_NUMSC := _cDoc
                        ZGQ->(MsUnLock())
                    EndIf
                EndIf

                If  ZGR->(RecLock("ZGR",.T.))
                        ZGR->ZGR_FILIAL := xFilial("ZGR")
                        ZGR->ZGR_FILORI := cFilAnt
                        ZGR->ZGR_OPERAC := 'SC'
                        ZGR->ZGR_USER   := __cUserID
                        ZGR->ZGR_NOMUSR := cUserName
                        ZGR->ZGR_STATUS := "A"
                        ZGR->ZGR_DTLOG  := Date()
                        ZGR->ZGR_HRLOG  := Time()
                        ZGR->ZGR_NUMDOC := _cDoc
                        ZGR->ZGR_CODREQ := oGridZGQ:GetValue( 'ZGQ_CODREQ' ) 
                        ZGR->ZGR_ITEM   := oGridZGQ:GetValue( 'ZGQ_ITEM' )
                    ZGR->(MsUnLock())
                EndIf

            EndIf
        Next _nX

        //oModel:Refresh()
    EndIf
    
    
    oGridZGQ:GoLine( 1 )
    oView:Refresh('MdGridZGQ')
    oView:Refresh('MdGridZGR')
    oView:Refresh()
    FwFormCommit(oModel)
  
    oModel := FWModelActive()
    oModel:DeActivate() 
    oModel:SetOperation(4) 
    oModel:Activate()

    oView:Refresh("MdFieldZGM")
    oView:Refresh("MdGridZGQ")
    oView:Refresh("MdGridZGS")
    oView:Refresh("MdGridZGR")
    
    
    oView:Refresh()

/*
    FwFormCommit(oModel)
  
    oGridZGQ:GoLine( 1 )
    oView:Refresh('MdGridZGQ')
    oView:Refresh('MdGridZGR')
    oView:Refresh()
*/
Return 
    
//oView:AddUserButton( 'Reentrada NF','', {|oView| ACZGOREE()} )
Static Function ACZGOREE(oView)

Local _nX := ''
Local _aCabec := {}
Local _aItens := {}
Local _aLinha := {}
Local _cAgluts := ''
Local _cAlias := ''
Local _cQuery := ''
Local _cSeq := ''
Local _aNotas := {}
Local _nPreco := 0
Local _cCliente := ''
Local _cLjCli := ''
Local _cNatSai := ''
Local _cNatEnt := ''
Local _cCondPgS := ''
Local _cCondPgE := ''
Local _cFilDest := ''
Local _cFornece := ''
Local _aForLj := {}
Local _cLjFor := ''
Local _cSerNota := SuperGetMv("MV_ZSERTRF",.F.,"", cFilAnt)
Local _cCabNFe := {}
Local _cPedido := ''
Local _cFilOrig := cFilAnt
Local _nQuantos := 0
Local _cCodAgl := ''
Local oModel := FWModelActive() 
Local oGridZGQ	:= oModel:GetModel("MdGridZGQ")
Local oGridZGS	:= oModel:GetModel("MdGridZGS")
Local oGridZGR	:= oModel:GetModel("MdGridZGR")

    For _nX := 1 To  oGridZGS:Length()
        oGridZGS:GoLine( _nX )
        If !oGridZGS:IsDeleted() .and. oGridZGS:GetValue( 'ZGS_MARK' ) 
            If !(!Empty(oGridZGS:GetValue( 'ZGS_PEDIDO')) .AND. !Empty(oGridZGS:GetValue( 'ZGS_DOCSAI'))  )
                Aviso("ATENO", "Para realizar a reentrada o documento de sada tem que ter sido gerado!", {"Sair"} , 2 , "Verifique os registros selecionados:")
                Return 
            EndIf
            _nQuantos ++
            _cAgluts += oGridZGS:GetValue( 'ZGS_CODAGL')+';'

            _cCodAgl := oGridZGS:GetValue( 'ZGS_CODAGL')

            If Empty(_cFilDest)
                _cFilDest := oGridZGS:GetValue( 'ZGS_FILDES') 
            EndIf

            If Empty(_cFornece)
                _aForLj := ACZGQFOR(cFilAnt)
                _cFornece := _aForLj[1]
                _cLjFor := _aForLj[2]
            EndIf

            If Empty(_cCliente)
                _cCliente := oGridZGS:GetValue( 'ZGS_CLIENT')
            EndIf

            If Empty(_cLjCli)
                _cLjCli := oGridZGS:GetValue( 'ZGS_LOJA') 
            EndIf

        EndIf
    Next _nX 

    If _nQuantos <> 1 
        Aviso("ATENO", "Foram selecionados mais de um cdigo de aglutinao. Para que possa ser rastreado, cada cdigo dever gerar um documento de sada!", {"Sair"} , 2 , "Verifique os registros selecionados:")
        Return 
    EndIf

    If !Empty(_cAgluts) 
        _cAlias := GetNextAlias()

        _cQuery := " "
        _cQuery += "  SELECT COUNT(*) AS CONTADOR   "
        _cQuery += "  FROM 	(SELECT ZGS.ZGS_CLIENT, ZGS.ZGS_LOJA, ZGS.ZGS_FILDES   "
        _cQuery += "  		 FROM "+RetSqlName("ZGS")+" ZGS  "
        _cQuery += "  		 WHERE ZGS.D_E_L_E_T_ = '' AND ZGS.ZGS_FILIAL = '"+xFilial("ZGS")+"' AND ZGS.ZGS_CODAGL <> '' AND ZGS.ZGS_CODAGL IN "+FormatIn(_cAgluts,";") +" ) AS TEMP "

        MPSysOpenQuery( _cQuery, _cAlias )

        If (_cAlias)->CONTADOR <> 1 
            Aviso("ATENO", "Foram selecionados itens com informaes distintas. CLIENTE / LOJA / FILIAL DESTINO devem ser iguais.", {"Sair"} , 2 , "Verifique os registros selecionados:")
            Return 
        EndIf
        (_cAlias)->(DbCloseArea())

        _cAlias := GetNextAlias()
        _cQuery := " "
        _cQuery += " SELECT  ZGQ.ZGQ_FILORI AS C6_FILIAL,  "
        _cQuery += " 		ZGQ.ZGQ_PROD AS C6_PRODUTO,  "
        _cQuery += " 		ZGO.ZGO_LOCSAI AS C6_LOCAL, ZGO.ZGO_TS AS C6_TES,  "
        _cQuery += " 		ZGQ.ZGQ_CC AS C6_CC,  ZGO_NATENT, ZGO_NATSAI, ZGO_CONPGS, ZGO_CONPGE,
        _cQuery += " 		SUM(ZGQ.ZGQ_QUANT) AS C6_QTDVEN  "
        _cQuery += " FROM		"+RetSqlName("ZGS")+" ZGS WITH(NOLOCK) INNER JOIN "+RetSqlName("ZGQ")+" ZGQ WITH(NOLOCK) ON  "
        _cQuery += " 			ZGS.ZGS_FILIAL = ''  "
        _cQuery += " 		AND ZGS.ZGS_CODAGL = ZGQ.ZGQ_CODAGL  "
        _cQuery += " 		AND ZGS.ZGS_FILDES = ZGQ.ZGQ_FILORI  "
        _cQuery += " 		AND ZGQ.D_E_L_E_T_ = ''  "
        _cQuery += " 			INNER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON  "
        _cQuery += " 			SB1.B1_FILIAL = ''  "
        _cQuery += " 		AND SB1.B1_COD = ZGQ.ZGQ_PROD  "
        _cQuery += " 		AND SB1.D_E_L_E_T_ = ''  "
        _cQuery += " 			LEFT OUTER JOIN "+RetSqlName("ZGO")+" ZGO WITH(NOLOCK) ON  "
        _cQuery += " 			ZGO.ZGO_FILIAL = '"+xFilial("ZGO")+"'  "
        _cQuery += " 		AND ZGO.ZGO_FILDES = ZGQ.ZGQ_FILORI  "
        _cQuery += " 		AND (ZGO.ZGO_PROD  = ZGQ.ZGQ_PROD OR 
        _cQuery += " 		    ( ZGO.ZGO_PROD = '' AND ZGO.ZGO_GRUPO = SB1.B1_GRUPO AND ZGO.ZGO_GRUPO <> '' ) )  "
        _cQuery += " WHERE		ZGS.D_E_L_E_T_ = '' AND ZGS.ZGS_FILIAL = '"+xFilial("ZGS")+ "'  "
        _cQuery += " 		AND ZGS.ZGS_CODAGL IN "+FormatIn(_cAgluts,";")+"   "
        _cQuery += " GROUP BY 	ZGQ.ZGQ_FILORI,ZGQ.ZGQ_PROD,ZGO.ZGO_LOCSAI,ZGQ.ZGQ_CC,ZGO.ZGO_TS,ZGO_NATENT, ZGO_NATSAI, ZGO_CONPGS, ZGO_CONPGE   "

        MPSysOpenQuery( _cQuery, _cAlias )

        If (_cAlias)->(!eof())
            While (_cAlias)->(!eof())
                If Empty(_cNatEnt)
                    _cNatEnt := (_cAlias)->ZGO_NATENT // Natureza Entrada
                EndIf

                If Empty(_cCondPgE)
                    _cCondPgE := (_cAlias)->ZGO_CONPGE //Cond. Entrada
                EndIf

            (_cAlias)->(DbSkip())
            EndDo
        EndIf
        
        For _nX := 1 To  oGridZGS:Length()
            oGridZGS:GoLine( _nX )
            If !oGridZGS:IsDeleted() .and. oGridZGS:GetValue( 'ZGS_MARK' ) 
                // Retorno 3 posies / 1 - se gerou a nota ,2-numero da nota, 3-serie
                _aRetNFS := { .T., oGridZGS:GetValue( 'ZGS_DOCSAI') , oGridZGS:GetValue( 'ZGS_SERSAI' ) } 
                If  _aRetNFS[1]   // Se gravou a NF de sada, vou perguntar se deseja gravar a de entrada
                    If ACGERNFE(_aRetNFS, _cFilOrig,_cFilDest, _cCliente, _cLjCli,_cFornece,_cLjFor,_cCondPgE,_cNatEnt  )

                        //// ATUALIZANDO NUMERO DA NOTA FISCAL DE SADA NA TABELA DE AGLUTINADORES
                        For _nX := 1 To  oGridZGS:Length()
                            oGridZGS:GoLine( _nX )
                            If !oGridZGS:IsDeleted() .and. oGridZGS:GetValue( 'ZGS_MARK' )    
                                oGridZGS:SetValue( 'ZGS_FORNEC', _cFornece ) 
                                oGridZGS:SetValue( 'ZGS_LJFORN', _cLjFor   ) 
                            EndIf
                        Next _nX 
                        oView:Refresh("MdGridZGS")
                         

                        // Adicionando rastreamento do pedido de vendas 
                        oModel:GetModel( 'MdGridZGR' ):SetNoInsertLine( .F. )
                        oModel:GetModel( 'MdGridZGR' ):SetNoUpdateLine( .F. )

                        DbSelectArea("ZGR")
                        ZGR->(DbSetOrder(3)) // filial + operao + chv origem
                        ZGR->(DbGoTop())
                        If !ZGR->(DbSeek(xFilial("ZGR") + "D1" + _aRetNFS[2]  + _aRetNFS[3] +_cFornece + _cLjFor      ))

                            oGridZGR:AddLine()
                                oGridZGR:SetValue( 'ZGR_FILIAL',  xFilial("ZGR") )
                                oGridZGR:SetValue( 'ZGR_CODREQ', oGridZGQ:GetValue( 'ZGQ_CODREQ' ) )
                                oGridZGR:SetValue( 'ZGR_ITEM', oGridZGQ:GetValue( 'ZGQ_ITEM' ) )
                                oGridZGR:SetValue( 'ZGR_OPERAC', 'D1'    )
                                oGridZGR:SetValue( 'ZGR_NUMDOC', _aRetNFS[2]   )
                                oGridZGR:SetValue( 'ZGR_FILORI'  , oGridZGQ:GetValue( 'ZGQ_FILORI' ) )
                                oGridZGR:SetValue( 'ZGR_CHVORI'  , _aRetNFS[2]  + _aRetNFS[3] +_cFornece + _cLjFor        )
                                oGridZGR:SetValue( 'ZGR_USER'  , __cUserID        )
                                oGridZGR:SetValue( 'ZGR_NOMUSR'  , cUserName        )
                                oGridZGR:SetValue( 'ZGR_DTLOG'  , Date()        )
                                oGridZGR:SetValue( 'ZGR_HRLOG'  , SubStr(Time(),1,5)        )
                                oGridZGR:SetValue( 'ZGR_STATUS'  , 'A'        )
                        EndIf

                        oModel:GetModel( 'MdGridZGR' ):SetNoInsertLine( .T. )
                        oModel:GetModel( 'MdGridZGR' ):SetNoUpdateLine( .T. )

                        oView:Refresh("MdGridZGR")
                    EndIf
                EndIf
            //Exit
            EndIf
        Next _nX 
    EndIf

// Atualizo o modelo com o que foi ajustado
FwFormCommit(oModel)

oModel := FWModelActive()
oModel:DeActivate() 
oModel:SetOperation(4) 
oModel:Activate()

oView:Refresh("MdFieldZGM")
oView:Refresh("MdGridZGQ")
oView:Refresh("MdGridZGS")
oView:Refresh("MdGridZGR")

oView:Refresh()

Return 
    


//oView:AddUserButton( 'Saldo Filiais','', {|oView| ACZGOSLD()} )
Static Function ACZGOSLD(oModel, oView)
    Alert("Saldos")
Return 



Static Function ACZGQCLI(_cFilDest)
Local _cCliente := ''
Local _cLoja := ''
Local _cAlias := ''
Local _cFilSql := ''
Default _cFilDest := ''

If !(Empty(_cFilDest))
    _cAlias := GetNextAlias()
    _cFilSql := '%'+ValToSql(_cFilDest)+'%'
    
    BeginSql alias _cAlias
        %noparser%
        SELECT TOP 1  SA1.A1_COD, SA1.A1_LOJA
        FROM    %table:SA1% SA1 WITH(NOLOCK)    
        WHERE       SA1.D_E_L_E_T_ = ''
                AND SA1.A1_FILTRF = %EXP:_cFilSql%
                AND SA1.A1_MSBLQL <> '1'
    EndSql

    If (_cAlias)->(!eof())
        _cCliente := (_cAlias)->A1_COD
        _cLoja    := (_cAlias)->A1_LOJA    
    EndIf

    (_cAlias)->(DbCloseArea())
EndIf

Return { _cCliente, _cLoja }



Static Function ACZGQFOR(_cFilDest)
Local _cFornece := ''
Local _cLoja := ''
Local _cAlias := ''
Local _cFilSql := ''
Default _cFilDest := ''

If !(Empty(_cFilDest))
    _cAlias := GetNextAlias()
    _cFilSql := '%'+ValToSql(_cFilDest)+'%'
    
    BeginSql alias _cAlias
        %noparser%
        SELECT TOP 1  SA2.A2_COD, SA2.A2_LOJA
        FROM    %table:SA2% SA2 WITH(NOLOCK)    
        WHERE       SA2.D_E_L_E_T_ = ''
                AND SA2.A2_FILTRF = %EXP:_cFilSql%
                AND SA2.A2_MSBLQL <> '1'
    EndSql

    If (_cAlias)->(!eof())
        _cFornece := (_cAlias)->A2_COD
        _cLoja    := (_cAlias)->A2_LOJA    
    EndIf

    (_cAlias)->(DbCloseArea())
EndIf

Return { _cFornece, _cLoja }



// Funo responsvel por incluir o pedido de vendas
Static Function ZPVINC(_cFilial, _aCabecC5O, _aItensC6O)
Local _cPedido := ""
Local _cFilBkp := cFilant
Local nOpr    := 3  // NMERO DA OPERAO (INCLUSO)
Local aHeader := _aCabecC5O
Local aItems  := _aItensC6O
Local _aArea   := {} // ARMAZENA REA CORRENTE

Local _aAreaSM0  := GetArea("SM0")                      	

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

//Validao da Filial
If cFilant <> _cFilial
    _aAreaSM0  := GetArea("SM0")                      	
    _aArea   := GetArea()  

    _cFilBkp := cFilAnt
    cFilAnt  := _cFilial
    OpenSM0(cEmpAnt + cFilAnt)			
EndIf

_aArea := GetArea()

MsExecAuto({|x, y, z| MATA410(x, y, z)}, aHeader, aItems, nOpr)

If (lMsErroAuto)
    MostraErro()
Else
    _cPedido := SC5->C5_NUM
EndIf

cFilAnt  := _cFilBkp
OpenSM0(cEmpAnt + cFilAnt)	

RestArea(_aArea)
RestArea(_aAreaSM0)

Return _cPedido





Static Function GravaNF(_cFilial, _cPVDest, _cSerDest)
Local _nX			:= 0
Local aArea			:= GetArea()
Local aPvlNfs		:= {}
Local aNotas		:= {}
Local aBloqueio		:= {{"","","","","","","",""}}
Local nPrcVen		:= 0
Local nItemNf		:= 0
Local cSerie		:= ""
Local _lRet			:= .F.
Local cNumNota		:= ""
Local aBkpParam		:= Array(40)
Local aSavAre		:= {TWR->(GetArea()), SE4->(GetArea()), SB1->(GetArea()), SB2->(GetArea()), SF4->(GetArea()), SC5->(GetArea()), SC6->(GetArea())}
Local lContinua		:= .T.
Local nVezes		:= 0
Local _aAreaSM0  := GetArea("SM0")                      	
Local _aArea   := GetArea()  
Local _cFilBkp := cFilant
Local _cNumNF := ""
Local _cSerNF := ""
Local _aRet := {}
Default _cSerDest := ""

//Validao da Filial
If cFilant <> _cFilial
    _aAreaSM0  := GetArea("SM0")                      	
    _aArea   := GetArea()  

    _cFilBkp := cFilAnt
    cFilAnt  := _cFilial
    OpenSM0(cEmpAnt + cFilAnt)			
EndIf

	dDataBase := Date()

	ConOut("Backup de Parmetros...")
	For _nX := 1 to 40
		aBkpParam[_nX] := &("mv_par"+StrZero(_nX, 2))
	Next _nX

	dbSelectArea("TWR")
	TWR->(dbSetOrder(1))	//TWR_FILIAL+TWR_CODMOV

	dbSelectArea("SE4")
	SE4->(dbSetOrder(1))	//E4_FILIAL+E4_CODIGO

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))	//B1_FILIAL+B1_COD

	dbSelectArea("SB2")
	SB2->(dbSetOrder(1))	//B2_FILIAL+B2_COD+B2_LOCAL

	dbSelectArea("SF4")
	SF4->(dbSetOrder(1))	//F4_FILIAL+F4_CODIGO

	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))	//C5_FILIAL+C5_NUM
	If(SC5->(dbSeek( _cFilial + _cPVDest)))
		dbSelectArea("SC6")
		SC6->(dbSetOrder(1))	//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		SC6->(dbSeek( _cFilial + _cPVDest))

		ConOut("analisa os bloqueios do pedido (estoque / credito)")
		//analisa os bloqueios do pedido (estoque / credito)
		ConOut("analisa os bloqueios do pedido (estoque / credito)")
		Ma410LbNfs(2,@aPvlNfs,@aBloqueio)

		ConOut("Pedidos liberados...")
		
		
		SC6->(dbSetOrder(1))	//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		SC6->(dbSeek(xFilial("SC6") + _cPVDest))

		//carrega o pedido de venda no sistema
		ConOut("carrega o pedido de venda no sistema")
		dbSelectArea("SC9")
		SC9->(dbSetOrder(1))	//C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
		SC9->(dbSeek(xFilial("SC9") + _cPVDest))

		While SC9->(!EOF()) .AND. xFilial("SC9") + _cPVDest == SC9->(C9_FILIAL+C9_PEDIDO)
			SC6->(dbSeek(xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM))	//Numero do Pedido
			SE4->(dbSeek(xFilial("SE4") + SC5->C5_CONDPAG))					//Condicao de pagamento
			SB1->(dbSeek(xFilial("SB1") + SC6->C6_PRODUTO))					//Produto
			SB2->(dbSeek(xFilial("SB2") + SC6->C6_PRODUTO + SC6->C6_LOCAL))	//Produto + Local
			SF4->(dbSeek(xFilial("SF4") + SC6->C6_TES))						//Tes

			ConOut("Liberando tabela SC9")
			nPrcVen := SC9->C9_PRCVEN
			If(SC5->C5_MOEDA != 1)
				nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase)
			EndIf

			aAdd(aPvlNfs,{	SC9->C9_PEDIDO,;
							SC9->C9_ITEM,;
							SC9->C9_SEQUEN,;
							SC9->C9_QTDLIB,;
							nPrcVen,;
							SC9->C9_PRODUTO,;
							.F.,;
							SC9->(RecNo()),;
							SC5->(RecNo()),;
							SC6->(RecNo()),;
							SE4->(RecNo()),;
							SB1->(RecNo()),;
							SB2->(RecNo()),;
							SF4->(RecNo())})
			SC9->(dbSkip())
		End

		//carrega os parametros de geracao de pedrgunta
		ConOut("carrega os parametros de geracao de pergunta")
		Pergunte("MT460A",.F.)

		//seleciona a serie da nota
		ConOut("seleciona a serie da nota")
		cSerie	:= _cSerDest
		_cSerNF := cSerie
		
		//busca o numero maximo de itens por nota
		ConOut("busca o numero maximo de itens por nota")
		nItemNf := a460NumIt(cSerie)

		aAdd(aNotas,{})

		//clona o variavel do pedido para a nota
		ConOut("clona o variavel do pedido para a nota")
		For _nX := 1 To Len(aPvlNfs)
			If Len(aNotas[Len(aNotas)])>=nItemNf
				aAdd(aNotas,{})
			EndIf
			aAdd(aNotas[Len(aNotas)],aClone(aPvlNfs[_nX]))
		Next _nX

		ConOut("emite a nota fiscal")
		//emite a nota fiscal
		For _nX := 1 To Len(aNotas)
			If(GetMv("MV_NUMITEN",.T.))
				While (lContinua .And. !SX6->(MsRLock()))
					Inkey(1)
					nVezes++
					If(nVezes > 200)
						lContinua := .F.
					EndIf
				EndDo
			Else
				lContinua := .F.
			EndIf

			If(lContinua)
				ConOut("itens nota fiscal No " + cNumNota + " - Qtde. Itens: " + cValToChar(Len(aNotas[_nX])))
				
				MaPvlNfs(aNotas[_nX],;
							cSerie,;
							MV_PAR01==1,;
							MV_PAR02==1,;
							MV_PAR03==1,;
							MV_PAR04==1,;
							MV_PAR05==1,;
							MV_PAR07,;
							MV_PAR08,;
							MV_PAR15==1,;
							MV_PAR16==2)
				_cNumNF := SF2->F2_DOC
				_cSerNF := SF2->F2_SERIE

                aAdd(_aRet, .T. )
                aAdd(_aRet, _cNumNF )
                aAdd(_aRet, _cSerNF )
                
                If SF2->(RecLock("SF2",.F.))
                    SF2->F2_ZROMORI := "ACFIMEPF" //Flag de gerao de docs entre as filiais
                EndIf
				
                If(GetMv("MV_NUMITEN",.T.))
					SX6->(MsRUnLock())
				EndIf

				_lRet := .T.
			Else
				_lRet := .F.
				Exit
			EndIf
		Next _nX
	EndIf

	aEval(aSavAre, {|z| RestArea(z)})
	RestArea(aArea)

	ConOut("Restaurando parmetros...")
	For _nX := 1 to 40
		&("mv_par"+StrZero(_nX, 2)) := aBkpParam[_nX]
	Next _nX

	ConOut("termino da execucao...")

    RestArea(_aAreaSM0)
    RestArea(_aArea)

    cFilAnt  := _cFilBkp
	OpenSM0(cEmpAnt + cFilAnt)	

Return(_aRet)


Static Function ACGERNFE(_aRetNFS, _cFilOrig, _cFilDest, _cCliente, _cLjCli,_cFornece, _cLjFor,_cCondPg,_cNatEnt, _lMostra  )

Local _lRet := .F. //Gerou a NF de entrada?
Local _aArea := GetArea()
Local _aAreaSF2 := SF2->(GetArea())
Local _aAreaSD2 := SD2->(GetArea())
Local _cNumNF := _aRetNFS[2]
Local _cSerNF := _aRetNFS[3]
Local _cCabNFe  := {}
Local _aItens   := {}
Local _aLinha   := {}
Local _cAlias := ""
Local _cBkpFil := cFilAnt
Local _aDadosZGO := {}
Local _nPos :=  0
Local _aDadCC := {} //ITEM E CC

Default _lMostra := .T.
Private lMsHelpAuto := .F.
Private lMsErroAuto := .F.

DbSelectArea("SF2")
SF2->(DbSetOrder(1))
SF2->(DbGoTop())

If SF2->(DbSeek(_cFilOrig + _cNumNF + _cSerNF + _cCliente + _cLjCli )) //Se encontrei a nota fiscal de sada vou fazer a entrada

	If Empty(SF2->F2_CHVNFE) //.and. 'ATIVO' == 'INATIVO'
		//MsgStop("Nota Fiscal no autorizada! No ser feita a entrada da NF no destino!","Problema")
        If !MSGYESNO( "Nota Fiscal no autorizada! Deseja prosseguir?", "ACMVCZGQ" )
		    Return .F.
        EndIf
	EndIf

	//Montagem cabealho
	aAdd(_cCabNFe,{"F1_FILIAL"	,   _cFilDest	    ,NIL})
	aAdd(_cCabNFe,{"F1_TIPO"	,   SF2->F2_TIPO    ,NIL})
	aAdd(_cCabNFe,{"F1_FORMUL"	,   "N"			    ,NIL})
	aAdd(_cCabNFe,{"F1_DOC"		,   SF2->F2_DOC	    ,NIL})
	aAdd(_cCabNFe,{"F1_SERIE"	,   SF2->F2_SERIE	,NIL})
	aAdd(_cCabNFe,{"F1_EMISSAO"	,   SF2->F2_EMISSAO ,NIL})
	aAdd(_cCabNFe,{"F1_DTDIGIT"	,   SF2->F2_EMISSAO ,NIL})
	aAdd(_cCabNFe,{"F1_FORNECE"	,   _cFornece       ,NIL})
	aAdd(_cCabNFe,{"F1_LOJA"	,   _cLjFor	        ,NIL})
	aAdd(_cCabNFe,{"F1_ESPECIE"	,   SF2->F2_ESPECIE	,NIL})
	aAdd(_cCabNFe,{"F1_SEGURO"	,   SF2->F2_SEGURO  ,NIL})
	aAdd(_cCabNFe,{"F1_FRETE"	,   SF2->F2_FRETE	,NIL})
	aAdd(_cCabNFe,{"F1_DESPESA"	,   SF2->F2_DESPESA ,NIL})
	aAdd(_cCabNFe,{"F1_VALMERC"	,   SF2->F2_VALMERC ,NIL})
	aAdd(_cCabNFe,{"F1_VALBRUT"	,   SF2->F2_VALBRUT ,NIL})
	aAdd(_cCabNFe,{"F1_COND"	,   _cCondPg	    ,NIL})
	aAdd(_cCabNFe,{"E2_NATUREZ"	,   _cNatEnt	    ,NIL})
	aAdd(_cCabNFe,{"F1_CHVNFE"	,   SF2->F2_CHVNFE  ,NIL})
    aAdd(_cCabNFe,{"F1_TPFRETE"	,   SF2->F2_TPFRETE  ,NIL})
    
	_cAlias := GetNextAlias()
	
	BeginSql alias _cAlias
		%noparser%
		COLUMN D2_EMISSAO AS DATE
		COLUMN D2_DTVALID AS DATE
		COLUMN D2_DTDIGIT AS DATE
		SELECT	*
		FROM		%table:SD2% SD2 WITH(NOLOCK)
		WHERE		SD2.D_E_L_E_T_ = ''
				AND SD2.D2_FILIAL = %exp:SF2->F2_FILIAL%
				AND SD2.D2_DOC = %exp:SF2->F2_DOC%
				AND SD2.D2_SERIE = %exp:SF2->F2_SERIE%
				AND SD2.D2_CLIENTE = %exp:SF2->F2_CLIENTE%
				AND SD2.D2_LOJA = %exp:SF2->F2_LOJA%
		ORDER BY SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_ITEM
	EndSql

        While (_cAlias)->(!EOF()) 
            _aDadosZGO := ACRETZGO(_cFilOrig, _cFilDest,  (_cAlias)->D2_COD ) //1-local / 2-tes entrada
                
			aAdd(_aLinha,{"D1_FILIAL"	, _cFilDest             ,Nil})
			aAdd(_aLinha, {"D1_ITEM"    , "00"+(_cAlias)->D2_ITEM     ,Nil} )
            
			aAdd(_aLinha,{"D1_COD"		, (_cAlias)->D2_COD		            ,Nil})
			aAdd(_aLinha,{"D1_LOCAL"		, _aDadosZGO[1]		            ,Nil})
			aAdd(_aLinha,{"D1_QUANT"		, (_cAlias)->D2_QUANT		            ,Nil})
			aAdd(_aLinha,{"D1_VUNIT"		, (_cAlias)->D2_PRCVEN		        ,Nil})
			If (_cAlias)->D2_TOTAL <= 0 
				If (_cAlias)->D2_QUANT > 0 .AND. (_cAlias)->D2_PRCVEN > 0 
					aAdd(_aLinha,{"D1_TOTAL"		, (_cAlias)->D2_QUANT * (_cAlias)->D2_PRCVEN  ,Nil})	
				Else
					aAdd(_aLinha,{"D1_TOTAL"		, 1	                ,Nil})
				EndIf
			Else
				aAdd(_aLinha,{"D1_TOTAL"		, (_cAlias)->D2_TOTAL	                ,Nil})
			EndIf
            aAdd(_aLinha,{"D1_TES"		, _aDadosZGO[2]	                    ,Nil})
            //aAdd(_aLinha,{"D1_CC"		, (_cAlias)->D2_CCUSTO 	            ,Nil}) //ADICIONADO EM 28/5/24

            
			aAdd(_aLinha,{"D1_LOTECTL"		, (_cAlias)->D2_LOTECTL         ,Nil})
			aAdd(_aLinha,{"D1_DTDIGIT"		, (_cAlias)->D2_EMISSAO         ,Nil})
			aAdd(_aLinha,{"D1_DTVALID"        ,(_cAlias)->D2_DTVALID		,Nil})
			aAdd(_aLinha,{"AUTDELETA"	,"N"				            	,Nil})

            aAdd(_aDadCC, {"00"+(_cAlias)->D2_ITEM , (_cAlias)->D2_CCUSTO } ) //Vou atualizar a SD1 aps a incluso da NF

			aAdd(_aItens,_aLinha)
			_aLinha   := {}
            (_cAlias)->(DbSkip())
        EndDo
		(_cAlias)->(DbCloseArea())
        If Len(_aItens) > 0 
            lMsHelpAuto := .F.
            lMsErroAuto := .F.

			cFilAnt := _cFilDest
			OpenSM0(cEmpAnt + cFilAnt)

            MATA103(_cCabNFe, _aItens, 3, _lMostra,/**/,/**/,/**/,)
            If lMsErroAuto
                _lRet := .F.
                DbSelectArea("SF1")
				SF1->(DbSetOrder(1))
				SF1->(DbGoTop())
				If SF1->(DbSeek(_cFilDest + _cNumNF + _cSerNF + _cFornece + _cLjFor ))
					If SF1->(Reclock("SF1",.F.))
						SF1->F1_ORIGEM := "ACMVCZGQ"
						//SF1->F1_CHVNFE := SF2->F2_CHVNFE
						SF1->(MsUnlock())

                        // Atualiznado CC que no foi est aceitando via execAuto
                        DbSelectArea("SD1")
                        SD1->(DbSetOrder(1))
                        SD1->(DbGoTop())
                        If SD1->(DbSeek(SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
                            While SD1->(!EOF()) .AND. SF1->F1_FILIAL == SD1->D1_FILIAL .AND. SF1->F1_DOC == SD1->D1_DOC;
                             .AND. SF1->F1_SERIE == SD1->D1_SERIE .AND. SF1->F1_FORNECE == SD1->D1_FORNECE .AND. SF1->F1_LOJA==SD1->D1_LOJA
                                _nPos := aScan(_aDadCC,{|x| AllTrim(x[1]) == Alltrim(SD1->D1_ITEM)})
                                IF _nPos > 0 
                                    If  SD1->(RecLock("SD1",.F.))
                                            SD1->D1_CC := _aDadCC[_nPos][2]
                                        SD1->(MsUnLock())
                                    EndIf
                                EndIf
                                
                            SD1->(DbSkip())
                            EndDo
                        EndIf

					EndIf
                    _lRet := .T.
				Endif            
                //MsgBox(("Nao foi possivel gerar o documento de entrada."),"","STOP")
                MostraErro()
            Else    
				DbSelectArea("SF1")
				SF1->(DbSetOrder(1))
				SF1->(DbGoTop())
				If SF1->(DbSeek(_cFilDest + _cNumNF + _cSerNF + _cFornece + _cLjFor ))
					If SF1->(Reclock("SF1",.F.))
						SF1->F1_ORIGEM := "ACMVCZGQ"
						//SF1->F1_CHVNFE := SF2->F2_CHVNFE
						SF1->(MsUnlock())

                        // Atualiznado CC que no foi est aceitando via execAuto
                        DbSelectArea("SD1")
                        SD1->(DbSetOrder(1))
                        SD1->(DbGoTop())
                        If SD1->(DbSeek(SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
                            While SD1->(!EOF()) .AND. SF1->F1_FILIAL == SD1->D1_FILIAL .AND. SF1->F1_DOC == SD1->D1_DOC;
                             .AND. SF1->F1_SERIE == SD1->D1_SERIE .AND. SF1->F1_FORNECE == SD1->D1_FORNECE .AND. SF1->F1_LOJA==SD1->D1_LOJA
                                _nPos := aScan(_aDadCC,{|x| AllTrim(x[1]) == Alltrim(SD1->D1_ITEM)})
                                IF _nPos > 0 
                                    If  SD1->(RecLock("SD1",.F.))
                                            SD1->D1_CC := _aDadCC[_nPos][2]
                                        SD1->(MsUnLock())
                                    EndIf
                                EndIf
                                
                            SD1->(DbSkip())
                            EndDo
                        EndIf

					EndIf
                    _lRet := .T.
				Endif
            EndIf
			cFilAnt := _cBkpFil
			OpenSM0(cEmpAnt + cFilAnt)
        EndIf
EndIf

RestArea(_aAreaSF2)
RestArea(_aAreaSD2)
RestArea(_aArea)

Return _lRet 



Static Function ACRETZGO(_cFilOrig, _cFilDest, _cProduto)

Local _cLocal := ''
Local _cTE := ''
Local _cQuery := ''
Local _cAlias := ''

        _cAlias := GetNextAlias()
        _cQuery := " "
        _cQuery += " SELECT TOP 1 ZGO.ZGO_LOCENT, ZGO.ZGO_TE  "
        _cQuery += " FROM "+RetSqlName("SB1")+" SB1 WITH(NOLOCK)   "
        _cQuery += " 			LEFT OUTER JOIN "+RetSqlName("ZGO")+" ZGO WITH(NOLOCK) ON  "
        _cQuery += " 			ZGO.ZGO_FILIAL = '"+_cFilOrig+"'  "
        _cQuery += " 		AND ZGO.ZGO_FILDES = '"+_cFilDest+"'  "
        _cQuery += " 		AND (ZGO.ZGO_PROD  = SB1.B1_COD OR 
        _cQuery += " 		    ( ZGO.ZGO_PROD = '' AND ZGO.ZGO_GRUPO = SB1.B1_GRUPO AND ZGO.ZGO_GRUPO <> '' ) )  "
        _cQuery += " WHERE		SB1.D_E_L_E_T_ = '' AND SB1.B1_COD = '"+_cProduto+"' "        

        MPSysOpenQuery( _cQuery, _cAlias )

        If (_cAlias)->(!eof())
            _cLocal := (_cAlias)->ZGO_LOCENT
            _cTE := (_cAlias)->ZGO_TE
        EndIf

        (_cAlias)->(DbCloseArea())

Return { _cLocal, _cTE }



User Function ACZGQCOR()

Local _cColor := "BR_CINZA"
Local _cStatSC := ''

If !Empty(ZGQ->ZGQ_NUMSC) .and. Empty(ZGQ->ZGQ_NFESAI) .and. ZGQ->ZGQ_RESIDU <> "S" .and. !Empty(ZGQ->ZGQ_APROVA)
    _cStatSC := Alltrim(ACSTATSC(ZGQ->ZGQ_NUMSC))
EndIf

    IF !Empty(ZGQ->ZGQ_NFESAI)  // Finalizado
        _cColor := "BR_VERMELHO"
    ElseIf ZGQ->ZGQ_RESIDU == "S" //resduo eliminado
        _cColor := "BR_CINZA"
    ElseIF Empty(ZGQ->ZGQ_APROVA) //Pendente de aprovao
        _cColor := "BR_AZUL"        
    ElseIf _cStatSC == 'SC_ABERTO'
        _cColor := "BR_MARROM"
    ElseIf _cStatSC == 'PC_PARC_A'
        _cColor := "BR_MARROM"
    ElseIf _cStatSC == 'PC_ATEN'
        _cColor := "BR_LARANJA"
    ElseIf _cStatSC == 'SC_BLOQ'
        _cColor := "BR_MARROM"
    ElseIf _cStatSC == 'EM_COTAC'
        _cColor := "BR_MARROM"
    ElseIF !Empty(ZGQ->ZGQ_APROVA)
        _cColor := "ENABLE" // Em aberto
    Else
        _cColor := "BR_AMARELO" //Atendimento parcial
    EndIf

Return _cColor



Static Function ACRZGSCD()

Local _cDoc := ''

DbSelectArea("ZGS")
ZGS->(DbSetOrder(2))
ZGS->(DbGoTop())

While .T.
    _cDoc := ""
    _cDoc := GetSXENum("ZGS","ZGS_CODAGL")
    ZGS->(dbGoTop())
    If ZGS->(dbSeek(xFilial("ZGS") + _cDoc ))
        ConfirmSX8()
    Else
        Exit
    EndIf
EndDo 


Return _cDoc




Static Function ACZGMLEG(oView, oModel)
Local aLegenda := {}  
/*
AADD(aLegenda,{ "BR_BRANCO",      "Finalizado" })
AADD(aLegenda,{ "BR_MARROM",      "NFe Saida Emitida" })
AADD(aLegenda,{ "BR_PINK",              "Aguardando NFe Saida" })
AADD(aLegenda,{ "ENABLE",              "Gerou SC(Em Aberto)" })
AADD(aLegenda,{ "BR_AZUL_CLARO", "Req. Pendente" })
AADD(aLegenda,{ "BR_VERDE_ESCURO",       "Req. Aguardando Aprovao" })
AADD(aLegenda,{ "BR_PRETO",             "Resduo" })
AADD(aLegenda,{ "BR_AMARELO",           "SC c/ PC Parc. atendido" })
AADD(aLegenda,{ "DISABLE",              "SC c/ PC Atendido" })
AADD(aLegenda,{ "BR_CINZA",             "SC Bloqueada" })
AADD(aLegenda,{ "BR_LARANJA",           "SC Rejeitada" })
AADD(aLegenda,{ "BR_AZUL",           "SC Em cotao" })
*/


AADD(aLegenda,{ "ENABLE",             "Em aberto" })
AADD(aLegenda,{ "BR_AMARELO",         "Atendimento parcial" })
AADD(aLegenda,{ "BR_VERMELHO",        "Finalizado" })
AADD(aLegenda,{ "BR_AZUL",      "Pendente de Aprovao" })
AADD(aLegenda,{ "BR_CINZA",             "Resduo eliminado" })
AADD(aLegenda,{ "BR_MARROM",      "Proc. Compras" })

AADD(aLegenda,{ "BR_LARANJA",      "Proc. Compras Finalizado" })

BrwLegenda(cTitulo, "Status", aLegenda)

Return .F.
 

Static Function ACZGQRES(oView)

Local _nX := 0
Local oModel := FWModelActive() 
Local oGridZGQ	:= oModel:GetModel("MdGridZGQ")
Local _aSaveLines := FWSaveRows()

If Aviso("Ateno","Itens que forem eliminados no podero ser atendidos novamente!",{"Continuar","Revisar"},2) == 1 
    For _nX := 1 To  oGridZGQ:Length()
        oGridZGQ:GoLine( _nX )
        If !oGridZGQ:IsDeleted() .and. oGridZGQ:GetValue( 'ZGQ_MARK' ) 
            oGridZGQ:SetValue( 'ZGQ_RESIDU', 'S')
        EndIf
    Next _nX 
EndIf

FWRestRows( _aSaveLines )

oGridZGQ:GoLine( 1 )
oView:Refresh("MdGridZGQ")
oView:Refresh()

FwFormCommit(oModel)

oModel := FWModelActive()
oModel:DeActivate() 
oModel:SetOperation(4) 
oModel:Activate()

oView:Refresh("MdFieldZGM")
oView:Refresh("MdGridZGQ")
oView:Refresh("MdGridZGS")
oView:Refresh("MdGridZGR")

Return 




User Function ZM120ZGR(_cFilial, _cNumPC)

Local _cAlias := GetNextAlias()
Local _cFilSQL := '%'+ValToSql(_cFilial)+'%'
Local _cPCSQL := '%'+ValToSql(_cNumPC)+'%'

BeginSql alias _cAlias
    %noparser%
    SELECT  DISTINCT SC7.C7_FILIAL, SC7.C7_NUM, SC1.C1_ZREQCD
    FROM        %table:SC7% SC7 WITH(NOLOCK) INNER JOIN %table:SC1% SC1 WITH(NOLOCK) ON
                SC7.C7_FILIAL = SC1.C1_FILIAL
            AND SC7.C7_NUMSC = SC1.C1_NUM
            AND SC7.C7_ITEMSC = SC1.C1_ITEM
            AND SC1.D_E_L_E_T_ = ''
                LEFT OUTER JOIN %table:ZGR% ZGR WITH(NOLOCK) ON
                ZGR.ZGR_FILIAL = SC7.C7_FILIAL 
            AND ZGR.ZGR_CODREQ = SC1.C1_ZREQCD
            AND ZGR.ZGR_OPERAC = 'PC'
            AND RTRIM(ZGR.ZGR_NUMDOC) = SC7.C7_NUM
            AND ZGR.D_E_L_E_T_ = ''
    WHERE       SC7.D_E_L_E_T_ = ''
            AND ZGR.ZGR_FILIAL IS NULL
            AND SC7.C7_NUM = %exp:_cPCSQL%
            AND SC7.C7_FILIAL = %exp:_cFilSQL%
            AND SC1.C1_ZREQCD <> ''
EndSql

If (_cAlias)->(!Eof())
    DbSelectArea("ZGR")
    While (_cAlias)->(!Eof())
        If  ZGR->(RecLock("ZGR",.T.))
                ZGR->ZGR_FILIAL := xFilial("ZGR")
                ZGR->ZGR_FILORI := cFilAnt
                ZGR->ZGR_OPERAC := 'PC'
                ZGR->ZGR_USER   := __cUserID
                ZGR->ZGR_NOMUSR := cUserName
                ZGR->ZGR_STATUS := "A"
                ZGR->ZGR_DTLOG  := Date()
                ZGR->ZGR_HRLOG  := Time()
                ZGR->ZGR_NUMDOC := (_cAlias)->C7_NUM
                ZGR->ZGR_CODREQ := SUBSTR((_cAlias)->C1_ZREQCD,1,6)
                ZGR->ZGR_ITEM   := SUBSTR((_cAlias)->C1_ZREQCD,7,4)
            ZGR->(MsUnLock())
        EndIf
    (_cAlias)->(DbSkip())
    EndDo
EndIf

(_cAlias)->(DbCloseArea())

Return 


Static Function ACSTATSC(_cSC)

Local _cAlias := GetNextAlias()
Local _cQuery := ''
Local _cRet := ''

_cQuery := ""
_cQuery += " SELECT 	(CASE
_cQuery += "			WHEN SC1.C1_RESIDUO <> '' THEN 'SC_RESIDUO'
_cQuery += "			WHEN SC1.C1_COTACAO = '' AND SC1.C1_QUJE = 0 AND SC1.C1_APROV IN ('','L') THEN 'SC_ABERTO'
_cQuery += "			WHEN ISNULL(SC7.C7_QUANT,0) > 0 AND ISNULL(SC7.C7_QUANT,0) > ISNULL(SC7.C7_QUJE,0) THEN 'PC_PARC_A'
_cQuery += "			WHEN ISNULL(SC7.C7_QUANT,0) > 0 AND ISNULL(SC7.C7_QUANT,0) <= ISNULL(SC7.C7_QUJE,0) THEN 'PC_ATEN'
_cQuery += "			WHEN SC1.C1_QUJE = 0 AND C1_COTACAO = '' AND C1_APROV = 'B' THEN 'SC_BLOQ'
_cQuery += "			WHEN SC1.C1_QUJE = 0 AND C1_COTACAO = '' AND C1_APROV = 'R' THEN 'SC_REJEI'
_cQuery += "			WHEN SC1.C1_COTACAO <> '' AND SC1.C1_QUJE = '' THEN 'EM_COTAC'
_cQuery += " END) AS STATUS
_cQuery += " FROM		"+RetSqlName("SC1")+" SC1 WITH(NOLOCK) OUTER APPLY  "
_cQuery += "			(SELECT	SC7.C7_FILIAL, SC7.C7_NUMSC, SC7.C7_ITEMSC, SUM(SC7.C7_QUANT) AS C7_QUANT,SUM(SC7.C7_QUJE) AS C7_QUJE
_cQuery += "			FROM		"+RetSqlName("SC7")+" SC7 WITH(NOLOCK) "
_cQuery += "			WHERE		SC7.D_E_L_E_T_ = ''
_cQuery += "					AND SC7.C7_FILIAL = SC1.C1_FILIAL
_cQuery += "					AND SC7.C7_NUMSC = SC1.C1_NUM
_cQuery += "					AND SC7.C7_ITEMSC = SC1.C1_ITEM
_cQuery += "					AND SC7.C7_RESIDUO = ''
_cQuery += "			GROUP BY SC7.C7_FILIAL, SC7.C7_NUMSC, SC7.C7_ITEMSC) AS SC7
_cQuery += " WHERE		SC1.D_E_L_E_T_ = ''
_cQuery += "		AND SC1.C1_FILIAL = '"+cFilAnt+"' "
_cQuery += "		AND SC1.C1_NUM = '"+_cSC+"'

MPSysOpenQuery(_cQuery, _cAlias)

If (_cAlias)->(!eof())
    _cRet := (_cAlias)->STATUS
EndIf

(_cAlias)->(DbCloseArea())

Return _cRet



Static Function ACATD1CC( _nRecSF1 )

Default _nRecSF1 := 0 
Local _cQuery := ''
Local _cAlias := GetNextAlias()







Return 

User Function ACSLDPRD()

//Local oModel := FWModelActive() 
//Local oGridZGM	:= oModel:GetModel("MdFieldZGM") 
Local _cProduto := ZGQ->ZGQ_PROD
Local _nSaldo := 0

DbSelectArea("SB2")
SB2->(DbSetOrder(1))
SB2->(DbGoTop())

If SB2->(DbSeek(xFilial("SB2") + _cProduto + _cArmazem ))
    If GetMV("MV_TPSALDO") == "C"
        _nSaldo := SaldoSB2(,,,,,"SB2")
    Else
        _nSaldo := SB2->(  B2_QATU-B2_QACLASS-B2_RESERVA   )
    EndIf
EndIf

Return _nSaldo


// retorna a ltima sequencia de desdobramento
Static Function ACGetSeq(_cFilReq, _cCodReq)

Local _cAlias := GetNextAlias()
Local _cQuery := ''
Local _cRet := ''

_cQuery := " SELECT ISNULL(MAX(ZGQ.ZGQ_SEQDSM),'') AS ULTIMA FROM "+RetSqlName("ZGQ") + " ZGQ WITH(NOLOCK) WHERE ZGQ.D_E_L_E_T_ = '' AND ZGQ.ZGQ_FILORI = '"+_cFilReq+"' AND ZGQ.ZGQ_CODREQ = '"+_cCodReq +"'"

MPSysOpenQuery(_cQuery, _cAlias)

If (_cAlias)->(!eof())
    _cRet := (_cAlias)->ULTIMA
EndIf

(_cAlias)->(DbCloseArea())

Return _cRet



// funo responsvel por fazer a limpeza na ZGS / ZGQ
User Function ACZGSPV(_cFilial, _cPedido )

Local _cQuery := ''
Local _cAlias := ''

If !Empty(_cFilial) .and. !Empty(_cPedido)
    _cAlias := GetNextAlias()
    _cQuery := " "

    _cQuery += " SELECT ZGS.R_E_C_N_O_ AS RECZGS, ZGQ.R_E_C_N_O_ AS RECZGQ
    _cQuery += " FROM		"+RetSqlName("SC5")+ " SC5 INNER JOIN "+RetSqlName("ZGS")+" ZGS ON
    _cQuery += " 			SC5.C5_FILIAL = ZGS.ZGS_FILIAL
    _cQuery += " 		AND SC5.C5_ZCODAGL = ZGS.ZGS_CODAGL
    _cQuery += " 		AND ZGS.D_E_L_E_T_ = ''
    _cQuery += " 			INNER JOIN "+RetSqlName("ZGQ")+" ZGQ ON
    _cQuery += " 			ZGQ.ZGQ_FILIAL = '"+xFilial("ZGQ")+"'
    _cQuery += " 		AND ZGQ.ZGQ_CDFIL = ZGS.ZGS_FILIAL
    _cQuery += " 		AND ZGQ.ZGQ_CODAGL = ZGS.ZGS_CODAGL
    _cQuery += " 		AND ZGQ.D_E_L_E_T_ = ''
    _cQuery += " WHERE		SC5.D_E_L_E_T_ = ''
    _cQuery += " 		AND SC5.C5_NUM = '"+_cPedido+"'
    _cQuery += " 		AND SC5.C5_FILIAL = '"+_cFilial+"'    "

    MPSysOpenQuery(_cQuery, _cAlias)

    If (_cAlias)->(!eof())
        DbSelectArea("ZGQ")
        DbSelectArea("ZGS")
        While (_cAlias)->(!eof())
            ZGS->(DbGoTo((_cAlias)->RECZGS))
            If ZGS->(RECNO()) == (_cAlias)->RECZGS
                If ZGS->(RecLock("ZGS", .F.))
                        ZGS->ZGS_DOCSAI := ""
                        ZGS->ZGS_PEDIDO  := ""
                        ZGS->ZGS_SERSAI  := ""
                        ZGS->ZGS_FORNEC  := ""
                        ZGS->ZGS_LJFORN  := ""
                    ZGS->(MsUnlock())
                EndIf

                ZGQ->(DbGoTo((_cAlias)->RECZGQ))
                If ZGQ->(RECNO()) == (_cAlias)->RECZGQ
                    If ZGQ->(RecLock("ZGQ", .F.))
                        ZGQ->ZGQ_NFESAI := ''
                        ZGQ->ZGQ_NFEENT := ''
                        ZGQ->(MsUnlock())
                    EndIf
                EndIf                    
                
            EndIf
            (_cAlias)->(DbSkip())
        EndDo
    EndIf
    (_cAlias)->(DbCloseArea())

EndIf

Return 






// imprime grid ZGQ
Static Function ACZGIMPR(oView)


Local oModel := FWModelActive() 
Local oGridZGQ := oModel:GetModel("MdGridZGQ")
Local _aSaveLines := FWSaveRows()
Local _nX := 0 
Local _nCount := 0 

Local _aPergs := {}
Local _aRet := {}
Local _nNovaQtde := 0
Local _nNewZGQ := 0 
Local oModel := FWModelActive() 
Local oGridZGQ := oModel:GetModel("MdGridZGQ")
Local _aSaveLines := FWSaveRows()
Local _nX := 0 
Local _nY := 0
Local _aNewZGQ := {}
Local _nLineZGS := 0 
Local _lMarcar := .T.
Local _nOpcao := 0


Local _nRow := 0

local oPrtXlsx as object
local cFilename as character
local lRet as logical
Local cFont := ""
Local nSize := 11
Local lItalic := .F.
Local lBold := .T.
Local lUnderlined := .F.
Local cColor := "000000"
Local _cNomArq := 'c:\Temp\ACMCZGQ_'+DToS(Date())+StrTran(Time(),":","")
Local cColorF := "FFFFFF" 
Local cStyle := FwXlsxBorderStyle():Thin() //Medium()
Local lTop := .T.
Local lBottom := .T.
Local lLeft:= .T.
Local lRight := .T.
Local _aCabec := aClone(oGridZGQ:aHeader)

static oCellHorAlign := FwXlsxCellAlignment():Horizontal()
static oCellVertAlign := FwXlsxCellAlignment():Vertical()

    cFilename := _cNomArq+'.rel'
    ferase(cFilename)
    oPrtXlsx := FwPrinterXlsx():New(.T.)
    lRet := oPrtXlsx:Activate(cFilename)
    lRet := oPrtXlsx:SetBorder(lLeft, lTop, lRight, lBottom, cStyle, cColor)
	
    lRet := oPrtXlsx:AddSheet("REQUISICAO CD")
    
    cHorAlignment := oCellHorAlign:LEFT()
    cVertAlignment := oCellVertAlign:Default()
    lWrapText := .F.
    nRotation := 0
    cCustomFormat := ""

    cFont := FwPrinterFont():Calibri()
    nSize := 20
    lItalic := .F.
    lBold := .T.
    lUnderlined := .F.
    lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)
    _nRow ++

    lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, cColor, cColorF, cCustomFormat)	        

    cFont := FwPrinterFont():Calibri()
    nSize := 14
    lItalic := .F.
    lBold := .T.
    lUnderlined := .F.
    lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)
    _nY := 0 
    For _nX := 1 to Len(_aCabec)
        If Alltrim(_aCabec[_nX][2]) $ "ZGQ_CODREQ|ZGQ_ITEM|ZGQ_PROD|ZGQ_DESC|ZGQ_QUANT|ZGQ_CC|ZGQ_EMISSA|ZGQ_FILORI|ZGQ_OBSERV|ZGQ_SLDPRD"
            _nY ++
            lRet := oPrtXlsx:SetColumnsWidth(_nY, _nY, _aCabec[_nY][4] )

            lRet := oPrtXlsx:SetText(_nRow, _nY , _aCabec[_nX][1])
        EndIf
    Next _nX 

    For _nY := 1 To  oGridZGQ:Length()
        IncProc("Processando... Por favor, aguarde.")
        oGridZGQ:GoLine( _nY )
        _nRow ++
        If !oGridZGQ:IsDeleted()
            _nZ := 0 
            For _nX := 1 to Len(_aCabec)
                If Alltrim(_aCabec[_nX][2]) $ "ZGQ_CODREQ|ZGQ_ITEM|ZGQ_PROD|ZGQ_DESC|ZGQ_QUANT|ZGQ_CC|ZGQ_EMISSA|ZGQ_FILORI|ZGQ_OBSERV|ZGQ_SLDPRD"
                    _nZ++
                    If _aCabec[_nX][8] == "C"
                        cCustomFormat := ""
                        lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, cColor, cColorF, cCustomFormat)	
                        lRet := oPrtXlsx:SetText(_nRow, _nZ , Alltrim(oGridZGQ:GetValue(  Alltrim(_aCabec[_nX][2]) )  )     )
                    ElseIf _aCabec[_nX][8] == "N"
                        cCustomFormat := "0.00"
                        lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, cColor, cColorF, cCustomFormat)	
                        lRet := oPrtXlsx:SetNumber(_nRow, _nZ , oGridZGQ:GetValue(  Alltrim(_aCabec[_nX][2]) ))
                    ElseIf _aCabec[_nX][8] == "D"
                        cCustomFormat := "dd/mm/yyyy"
                        lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, cColor, cColorF, cCustomFormat)	
                        lRet := oPrtXlsx:SetDate(_nRow, _nZ , oGridZGQ:GetValue(  Alltrim(_aCabec[_nX][2]) )    )
                    EndIf
                EndIf
            Next _nX 
        EndIf
    Next _nY

    oGridZGQ:GoLine( 1 )
    oView:Refresh("MdGridZGQ")
    oView:Refresh()  

	lRet := oPrtXlsx:toXlsx()
 
    oPrtXlsx:DeActivate()
    shellExecute("Open", "excel", _cNomArq+".xlsx", "C:\", 1 )
    MsgInfo('Arquivo gerado com sucesso: '+cFilename,"Sucesso")

Return()

