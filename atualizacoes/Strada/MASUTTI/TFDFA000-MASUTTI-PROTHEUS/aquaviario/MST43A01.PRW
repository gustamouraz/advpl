//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
//Variáveis Estáticas
Static cTitulo := "Cadastro de Portos"
 
User Function MST43A01()
    Local aArea   := GetArea()
    Local oBrowse
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("ZB2")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Legendas
    oBrowse:AddLegend( "ZB2->ZB2_ATIVO == '1'", "GREEN",    "Ativo" )
    oBrowse:AddLegend( "ZB2->ZB2_ATIVO == '2'", "RED",    "Inativo" )
     
    //Ativa a Browse
    oBrowse:Activate()
     
    RestArea(aArea)
Return Nil
 

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Criação do menu MVC                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/ 
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.MST43A01' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.MST43A01' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.MST43A01' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.MST43A01' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot
 

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
     
    //Criação da estrutura de dados utilizada na interface
    Local oStZB2 := FWFormStruct(1, "ZB2")
	Local bVldPos 	:= {||	zTudoOK() }
     
    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("zMST43A01M",/*bPre*/, bVldPos,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMZB2",/*cOwner*/,oStZB2)
     
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'ZB2_FILIAL','ZB2_CODPOR'})
     
    //Adicionando descrição ao modelo
    // oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    // //Setando a descrição do formulário
    // oModel:GetModel("FORMZB2"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel
 

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/ 
Static Function ViewDef()
    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("MST43A01")
     
    //Criação da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStZB2 := FWFormStruct(2, "ZB2")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'ZB2_NOME|ZB2_DTAFAL|'}
     
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_ZB2", oStZB2, "FORMZB2")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_ZB2', 'Dados do Porto' )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_ZB2","TELA")
Return oView
 

/*/{Protheus.doc} zMVC01Leg
Função para mostrar a legenda das rotinas MVC 
@author Atilio
@since 17/08/2015
@version 1.0
    @example
    u_zMVC01Leg()
/*/
Static Function zMVC01Leg()
    Local aLegenda := {}
     
    //Monta as cores
    AADD(aLegenda,{"BR_VERDE",        "Ativo"  })
    AADD(aLegenda,{"BR_VERMELHO",    "Inativo"})
     
    BrwLegenda("Portos", "Procedencia", aLegenda)
Return


Static Function zTudoOK()
	Local oModel 		:= FwModelActive()
	Local nOpc 			:= oModel:GetOperation()
	Local oModelZB2		:= oModel:GetModel('FORMZB2')
	Local cCodPorto		as Character
	Local lRet			:= .t.

	Begin Sequence
		If !(nOpc == MODEL_OPERATION_INSERT  .Or. nOpc == MODEL_OPERATION_UPDATE)
			break
		ENdif

        IF nOpc = 3
            cCodPorto := oModelZB2:GetVAlue('ZB2_CODPOR')	
            lExist := POSICIONE("ZB2", 1, xfilial("ZB2")+cCodPorto, "ZB2_CODPOR")	

            If !EMPTY(lExist)
                lRet := .f.
                Help( ,, 'PORTOEXISTE',,"Porto já cadastrado com código: " + cCodPorto , 1, 0)
                break
            Endif
        elseIf nOpc = 4
            IF ZB2->ZB2_CODPOR <> oModelZB2:GetVAlue('ZB2_CODPOR')
                cCodPorto := oModelZB2:GetVAlue('ZB2_CODPOR')	
                lExist := POSICIONE("ZB2", 1, xfilial("ZB2")+cCodPorto, "ZB2_CODPOR")	

                If !EMPTY(lExist)
                    lRet := .f.
                    Help( ,, 'PORTOEXISTE',,"Porto já cadastrado com código: " + cCodPorto , 1, 0)
                    break
                Endif
            ENDIF
        Endif

	End Sequence

Return lRet
