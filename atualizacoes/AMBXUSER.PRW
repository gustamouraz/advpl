#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
//Variáveis Estáticas
Static cTitulo := "Usuário X Ambiente"
 
/*/{Protheus.doc} AMBXUSER
@author Pedro Victor
@since 22/10/2024
@version 1.0
    @return Nil, Função não tem retorno
    @example
    u_zModel1()
/*/
 
User Function AMBXUSER()
    Local aArea   := GetArea()
    Local oBrowse
    Local cFunBkp := FunName()
     
    SetFunName("AMBXUSER")
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("ZMP")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Legendas
    oBrowse:AddLegend( "DTOS(ZMP->ZMP_DTINI)+' '+ZMP->ZMP_HRINI > DTOS(Date())+' '+SubStr(FwTimeUF('RO')[2],1,5) .AND. DTOS(ZMP->ZMP_DTFIM)+' '+ZMP->ZMP_HRFIM > DTOS(Date())+' '+SubStr(FwTimeUF('RO')[2],1,5)", "YELLOW", "Não Iniciado"     )
    oBrowse:AddLegend( "DTOS(ZMP->ZMP_DTINI)+' '+ZMP->ZMP_HRINI < DTOS(Date())+' '+SubStr(FwTimeUF('RO')[2],1,5) .AND. DTOS(ZMP->ZMP_DTFIM)+' '+ZMP->ZMP_HRFIM > DTOS(Date())+' '+SubStr(FwTimeUF('RO')[2],1,5)", "GREEN",  "Dentro do Prazo"  )
    oBrowse:AddLegend( "DTOS(ZMP->ZMP_DTFIM)+' '+ZMP->ZMP_HRFIM < DTOS(Date())+' '+SubStr(FwTimeUF('RO')[2],1,5)", "RED",    "Prazo Vencido"    )
     
    //Filtrando
    //oBrowse:SetFilterDefault("ZMP->ZMP_USER >= '000000' .And. ZMP->ZMP_USER <= 'ZZZZZZ'")
     
    //Ativa a Browse
    oBrowse:Activate()
     
    SetFunName(cFunBkp)
    RestArea(aArea)
Return Nil
 
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Pedro Victor                                                 |
 | Data:  22/10/2024                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
 
Static Function MenuDef()
    Local aRot := {}
 
	aAdd( aRot, {  "Visualizar"              ,"VIEWDEF.AMBXUSER"                         , 0, 1, 0, .T. } )
	aAdd( aRot, {  "Incluir"                 ,"VIEWDEF.AMBXUSER"                         , 0, 3, 0, Nil } )
	aAdd( aRot, {  "Alterar"                 ,"VIEWDEF.AMBXUSER"                         , 0, 4, 0, Nil } )
	aAdd( aRot, {  "Excluir"                 ,"VIEWDEF.AMBXUSER"                         , 0, 5, 0, Nil } )
	aAdd( aRot, {  'Legenda' 	             ,"u_zMod1Leg"                               , 0, 6, 0, Nil } )

Return aRot
 
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Pedro Victor                                                 |
 | Data:  22/10/2024                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
     
    //Criação da estrutura de dados utilizada na interface
    Local oStZMP := FWFormStruct(1, "ZMP")
     
    //Editando características do dicionário
    oStZMP:SetProperty('ZMP_COD',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
    oStZMP:SetProperty('ZMP_COD',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZMP", "ZMP_COD")'))         //Ini Padrão
    //oStZMP:SetProperty('ZNF_DESC',  MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'Iif(Empty(M->ZZ1_DESC), .F., .T.)'))   //Validação de Campo
    //oStZMP:SetProperty('ZNF_DESC',  MODEL_FIELD_OBRIGAT, Iif(RetCodUsr()!='000000', .T., .F.) )                                         //Campo Obrigatório
    oStZMP:AddTrigger( "ZMP_USER", "ZMP_USRNOM" , { || .T. }, { | oFields |  USRRETNAME(oFields:GetValue("ZMP_USER"))   } )             //Gatilho
    oStZMP:SetProperty('ZMP_USRNOM',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                              //Modo de Edição
     
    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("zModel1M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMZMP",/*cOwner*/,oStZMP)
     
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'ZMP_FILIAL','ZMP_COD'})
     
    //Adicionando descrição ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    //Setando a descrição do formulário
    oModel:GetModel("FORMZMP"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Pedro Victor                                                 |
 | Data:  22/10/2024                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
    //Local aStruZNF    := ZMP->(DbStruct())
     
    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("AMBXUSER")
     
    //Criação da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStZMP := FWFormStruct(2, "ZMP")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SZZ1_NOME|SZZ1_DTAFAL|'}
     
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_ZMP", oStZMP, "FORMZMP")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_ZMP', 'Dados - '+cTitulo )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_ZMP","TELA")
     
    /*
    //Tratativa para remover campos da visualização
    For nAtual := 1 To Len(aStruZNF)
        cCampoAux := Alltrim(aStruZNF[nAtual][01])
         
        //Se o campo atual não estiver nos que forem considerados
        If Alltrim(cCampoAux) $ "ZNF_COD;"
            oStZMP:RemoveField(cCampoAux)
        EndIf
    Next
    */
Return oView
 
/*/{Protheus.doc} zMod1Leg
Função para mostrar a legenda
@author Pedro Victor
@since 22/10/2024
@version 1.0
    @example
    u_zMod1Leg()
/*/
 
User Function zMod1Leg()
    Local aLegenda := {}
     
    //Monta as cores
    AADD(aLegenda,{"BR_VERMELHO"    ,"Prazo Vencido" })
    AADD(aLegenda,{"BR_VERDE"       ,"Dentro do Prazo" })
    AADD(aLegenda,{"BR_AMARELO"     ,"Não Iniciado" })
     
    BrwLegenda(cTitulo, "Status", aLegenda)
Return
