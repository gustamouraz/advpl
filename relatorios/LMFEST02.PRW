#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
//Variáveis Estáticas
Static cTitulo := "Ativo Biológico"
 
/*/{Protheus.doc} LMFEST02
@author Luiz Moura
@since 20/06/2022
@version 1.0
/*/
 
User Function LMFEST02()
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

     
    SetFunName("LMFEST02")
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("ZZH")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
          
    //Filtrando
    //oBrowse:SetFilterDefault("ZZH->ZZH_USER >= '000000' .And. ZZH->ZZH_USER <= 'ZZZZZZ'")
     
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
 
	aAdd( aRot, {  "Visualizar"              ,"VIEWDEF.LMFEST02"                         , 0, 1, 0, .T. } )
	aAdd( aRot, {  "Incluir"                 ,"VIEWDEF.LMFEST02"                         , 0, 3, 0, Nil } )
	aAdd( aRot, {  "Alterar"                 ,"VIEWDEF.LMFEST02"                         , 0, 4, 0, Nil } )
	aAdd( aRot, {  "Excluir"                 ,"VIEWDEF.LMFEST02"                         , 0, 5, 0, Nil } )

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
    Local oStZZH := FWFormStruct(1, "ZZH")     

    //Editando características do dicionário
    // oStZZH:SetProperty('ZZH_COD',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
    // oStZZH:SetProperty('ZZH_COD',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZZH", "ZZH_COD")'))         //Ini Padrão
    // oStZZH:SetProperty('ZNF_DESC',  MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'Iif(Empty(M->ZZ1_DESC), .F., .T.)'))   //Validação de Campo
    // oStZZH:SetProperty('ZNF_DESC',  MODEL_FIELD_OBRIGAT, Iif(RetCodUsr()!='000000', .T., .F.) )                                         //Campo Obrigatório
    // oStZZH:AddTrigger( "ZZH_USER", "ZZH_USRNOM" , { || .T. }, { | oFields |  USRRETNAME(oFields:GetValue("ZZH_USER"))   } )             //Gatilho
    // oStZZH:SetProperty('ZZH_USRNOM',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                              //Modo de Edição

    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("zModel1M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMZZH",/*cOwner*/,oStZZH)
     
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'ZZH_FILIAL','ZZH_DATA'})
     
    //Adicionando descrição ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    //Setando a descrição do formulário
    oModel:GetModel("FORMZZH"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Luiz Moura                                                   |
 | Data:  20/06/2022                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
    //Local aStruZNF    := ZZH->(DbStruct())
     
    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("LMFEST02")
     
    //Criação da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStZZH := FWFormStruct(2, "ZZH")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SZZ1_NOME|SZZ1_DTAFAL|'}
     
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_ZZH", oStZZH, "FORMZZH")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_ZZH', 'Dados - '+cTitulo )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_ZZH","TELA")
    oView:SetAfterViewActivate({|oView| LMFEST02IniFornecedor(oView)})

    /*
    //Tratativa para remover campos da visualização
    For nAtual := 1 To Len(aStruZNF)
        cCampoAux := Alltrim(aStruZNF[nAtual][01])
         
        //Se o campo atual não estiver nos que forem considerados
        If Alltrim(cCampoAux) $ "ZNF_COD;"
            oStZZH:RemoveField(cCampoAux)
        EndIf
    Next
    */
Return oView

Static Function LMFEST02IniFornecedor(oView)
    Local oModel      := FWModelActive()
    Local oModelZZH   := oModel:GetModel("FORMZZH")
    Local aFornecedor := LMFEST02Fornecedor()

    If oView:GetOperation() == 3 .And. !Empty(aFornecedor[1])
        // A loja deve ser preenchida antes do fornecedor para que o
        // gatilho do SX3 consiga localizar o nome reduzido na SA2.
        oModelZZH:SetValue("ZZH_LOJA", aFornecedor[2])
        oModelZZH:SetValue("ZZH_CLIFOR", aFornecedor[1])
        oView:Refresh()
    EndIf

Return

/*/{Protheus.doc} LMFEST02Fornecedor
Localiza o fornecedor ativo configurado para a filial do Ativo Biologico.

@return Array, codigo e loja do fornecedor
@type function
/*/
Static Function LMFEST02Fornecedor()
    Local aFornecedor := {"", ""}
    Local cAlias      := GetNextAlias()
    Local _cFilSql    := AllTrim(FWxFilial("ZZH"))

    BeginSql Alias cAlias
        %noParser%
        SELECT TOP 1
               SA2.A2_COD,
               SA2.A2_LOJA
          FROM %table:SA2% SA2 WITH(NOLOCK)
         WHERE SA2.D_E_L_E_T_ = ''
           AND SA2.A2_FILTRF = %exp:_cFilSql%
           AND SA2.A2_MSBLQL <> '1'
         ORDER BY SA2.A2_COD, SA2.A2_LOJA
    EndSql

    If (cAlias)->(!Eof())
        aFornecedor[1] := (cAlias)->A2_COD
        aFornecedor[2] := (cAlias)->A2_LOJA
    EndIf

    (cAlias)->(DbCloseArea())

Return aFornecedor
