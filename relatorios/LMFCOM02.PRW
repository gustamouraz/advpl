#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
//Variáveis Estáticas
Static cTitulo := "Compras Pecuária"
 
/*/{Protheus.doc} LMFCOM02
@author Luiz Moura
@since 20/06/2022
@version 1.0
/*/
 
User Function LMFCOM02()
    Local aArea   := GetArea()
    Local oBrowse
    Local cFunBkp := FunName()

    If Select("SX2") == 0
	    RpcClearEnv()
	    RPCSetType(3)	//NAO CONSOME LICENSA DE USO
	    If(!RpcSetEnv("01", "060110", "", "", "CTB",,{"SN3"}))
	    	Return(Nil)
	    EndIf
	    lRPC := .T.
    EndIf

     
    SetFunName("LMFCOM02")
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("ZZI")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
          
    //Filtrando
    //oBrowse:SetFilterDefault("ZZI->ZZI_USER >= '000000' .And. ZZI->ZZI_USER <= 'ZZZZZZ'")
     
    //Ativa a Browse
    oBrowse:Activate()
     
    SetFunName(cFunBkp)
    RestArea(aArea)
Return Nil
 
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Luiz Moura                                                   |
 | Data:  20/06/2022                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
 
Static Function MenuDef()
    Local aRot := {}
 
	aAdd( aRot, {  "Visualizar"              ,"VIEWDEF.LMFCOM02"                         , 0, 1, 0, .T. } )
	aAdd( aRot, {  "Incluir"                 ,"VIEWDEF.LMFCOM02"                         , 0, 3, 0, Nil } )
	aAdd( aRot, {  "Alterar"                 ,"VIEWDEF.LMFCOM02"                         , 0, 4, 0, Nil } )
	aAdd( aRot, {  "Excluir"                 ,"VIEWDEF.LMFCOM02"                         , 0, 5, 0, Nil } )

Return aRot
 
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Luiz Moura                                                   |
 | Data:  20/06/2022                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
     
    //Criação da estrutura de dados utilizada na interface
    Local oStZZI := FWFormStruct(1, "ZZI")     

    //Editando características do dicionário
    // oStZZI:SetProperty('ZZI_COD',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
    // oStZZI:SetProperty('ZZI_COD',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZZI", "ZZI_COD")'))         //Ini Padrão
    // oStZZI:SetProperty('ZNF_DESC',  MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'Iif(Empty(M->ZZ1_DESC), .F., .T.)'))   //Validação de Campo
    // oStZZI:SetProperty('ZNF_DESC',  MODEL_FIELD_OBRIGAT, Iif(RetCodUsr()!='000000', .T., .F.) )                                         //Campo Obrigatório
    // oStZZI:AddTrigger( "ZZI_USER", "ZZI_USRNOM" , { || .T. }, { | oFields |  USRRETNAME(oFields:GetValue("ZZI_USER"))   } )             //Gatilho
    // oStZZI:SetProperty('ZZI_USRNOM',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                              //Modo de Edição
     
    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("zModel1M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMZZI",/*cOwner*/,oStZZI)
     
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'ZZI_FILIAL','ZZI_NUMPC'})
     
    //Adicionando descrição ao modelo
    oModel:SetDescription(cTitulo)
     
    //Setando a descrição do formulário
    oModel:GetModel("FORMZZI"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Luiz Moura                                                   |
 | Data:  20/06/2022                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
    //Local aStruZNF    := ZZI->(DbStruct())
     
    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("LMFCOM02")
     
    //Criação da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStZZI := FWFormStruct(2, "ZZI")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SZZ1_NOME|SZZ1_DTAFAL|'}
     
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_ZZI", oStZZI, "FORMZZI")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_ZZI', 'Dados - '+cTitulo )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_ZZI","TELA")
     
    /*
    //Tratativa para remover campos da visualização
    For nAtual := 1 To Len(aStruZNF)
        cCampoAux := Alltrim(aStruZNF[nAtual][01])
         
        //Se o campo atual não estiver nos que forem considerados
        If Alltrim(cCampoAux) $ "ZNF_COD;"
            oStZZI:RemoveField(cCampoAux)
        EndIf
    Next
    */
Return oView
