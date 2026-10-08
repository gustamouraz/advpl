//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
//Variáveis Estáticas
Static cTitulo := "Cadastro de Balsas"
 
User Function MST43A02()
    Local aArea   := GetArea()
    Local oBrowse
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("ZB3")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Legendas
    oBrowse:AddLegend( "ZB3->ZB3_ATIVO == '1'", "GREEN",    "Ativo" )
    oBrowse:AddLegend( "ZB3->ZB3_ATIVO == '2'", "RED",    "Inativo" )
     
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
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.MST43A02' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.MST43A02' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.MST43A02' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.MST43A02' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
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
    Local oStZB3 := FWFormStruct(1, "ZB3")
	Local bVldPos 	:= {||	zTudoOK() }
     
    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("zMST43A02M",/*bPre*/, bVldPos,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMZB3",/*cOwner*/,oStZB3)
     
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'ZB3_FILIAL','ZB3_CBALSA '})
     
    //Adicionando descrição ao modelo
    // oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    // //Setando a descrição do formulário
    // oModel:GetModel("FORMZB3"):SetDescription("Formulário do Cadastro "+cTitulo)
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
    Local oModel := FWLoadModel("MST43A02")
     
    //Criação da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStZB3 := FWFormStruct(2, "ZB3")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'ZB3_NOME|ZB3_DTAFAL|'}
     
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_ZB3", oStZB3, "FORMZB3")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_ZB3', 'Dados do Balsa' )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_ZB3","TELA")
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
     
    BrwLegenda("Balsas", "Procedencia", aLegenda)
Return


Static Function zTudoOK()
	Local oModel 		:= FwModelActive()
	Local nOpc 			:= oModel:GetOperation()
	Local oModelZB3		:= oModel:GetModel('FORMZB3')
	Local cCodBalsa		as Character
	Local lRet			:= .t.

	Begin Sequence
		If !(nOpc == MODEL_OPERATION_INSERT  .Or. nOpc == MODEL_OPERATION_UPDATE)
			break
		ENdif

        IF nOpc = 3
            cCodBalsa := oModelZB3:GetVAlue('ZB3_CBALSA')	
            lExist := POSICIONE("ZB3", 1, xfilial("ZB3")+cCodBalsa, "ZB3_CBALSA")	

            If !EMPTY(lExist)
                lRet := .f.
                Help( ,, 'BALSAEXISTE',,"Balsa já cadastrado com código: " + cCodBalsa , 1, 0)
                break
            Endif
        elseIf nOpc = 4
            IF ZB3->ZB3_CBALSA <> oModelZB3:GetVAlue('ZB3_CBALSA')
                cCodBalsa := oModelZB3:GetVAlue('ZB3_CBALSA')	
                lExist := POSICIONE("ZB3", 1, xfilial("ZB3")+cCodBalsa, "ZB3_CBALSA")	

                If !EMPTY(lExist)
                    lRet := .f.
                    Help( ,, 'BALSAEXISTE',,"Balsa já cadastrado com código: " + cCodBalsa , 1, 0)
                    break
                Endif
            ENDIF
        Endif

	End Sequence

Return lRet
