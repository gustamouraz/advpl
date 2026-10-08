#Include "Totvs.ch"
#include "rwmake.ch"
#INCLUDE 'FWMVCDef.ch'
#include 'PROTHEUS.CH'
#Include 'topconn.ch'

Static cTitulo := "Localização Produtos"

User Function LMFEST01() 

    Local aArea   := GetArea()
    Local oBrowse

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZZF")
    oBrowse:SetDescription(cTitulo)

    oBrowse:Activate()

    RestArea(aArea)

Return 


Static Function MenuDef()
    Local aRot := {}
      
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.LMFEST01' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.LMFEST01' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.LMFEST01' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.LMFEST01' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 5

Return aRot
 
Static Function ModelDef()
    //Na montagem da estrutura do Modelo de dados, o cabeçalho filtrará e exibirá somente alguns campos, já a grid irá carregar a estrutura inteira conforme função fModStruct
    Local oModel      := NIL
    Local oStruCab    := FWFormStruct(1, 'ZZF', {|cCampo| AllTRim(cCampo) $ "ZZF_FILIAL, ZZF_DATINC"})
    Local oStruGrid   := FWFormStruct(1, 'ZZF', {|cCampo| AllTrim(cCampo) $ "ZZF_FILIAL, ZZF_DATINC, ZZF_CODPRO, ZZF_DESPRO, ZZF_QUANT, ZZF_LOCAL"})
    Local bPre := Nil
    Local bPos := Nil
    Local bCommit := {|oModel| fCommit(oModel) }
    Local bCancel := Nil

    oStruGrid:AddTrigger( "ZZF_CODPRO", "ZZF_DATINC" , { || .T. }, { | oFields | DDATABASE  } )
    oStruGrid:AddTrigger( "ZZF_CODPRO", "ZZF_DESPRO" , { || .T. }, { | oFields | GetAdvFVal("SB1","B1_DESC",xFilial("SB1") + oFields:GetValue("ZZF_CODPRO"),1,"")  } )
    oStruGrid:SetProperty("ZZF_DESPRO", MODEL_FIELD_WHEN,{|| .F.})

    oModel := MPFormModel():New('CADZZFM', bPre, bPos, bCommit , bCancel )
    //Agora, define no modelo de dados, que terá um Cabeçalho e uma Grid apontando para estruturas acima
    oModel:AddFields('MdFieldZZF', NIL, oStruCab)
    oModel:AddGrid('MdGridZZF', 'MdFieldZZF', oStruGrid, , )  

    //Monta o relacionamento entre Grid e Cabeçalho, as expressões da Esquerda representam o campo da Grid e da direita do Cabeçalho
    oModel:SetRelation('MdGridZZF', {;
            {'ZZF_FILIAL', 'xFilial("ZZF")'},;
            {'ZZF_DATINC', 'ZZF_DATINC'};
        }, ZZF->(IndexKey(1)))

    //Definindo outras informações do Modelo e da Grid
    oModel:GetModel("MdGridZZF"):SetMaxLine(9999)
    oModel:SetDescription(cTitulo)
    
    oModel:SetPrimaryKey({"ZZF_FILIAL","ZZF_CODPRO","ZZF_LOCAL"})
 
Return oModel
 
Static Function ViewDef()
    //Na montagem da estrutura da visualização de dados, vamos chamar o modelo criado anteriormente, no cabeçalho vamos mostrar somente 3 campos, e na grid vamos carregar conforme a função fViewStruct
    Local oView        := NIL
    Local oModel    := FWLoadModel('LMFEST01')
    Local oStruCab  := FWFormStruct(2, "ZZF", {|cCampo| AllTRim(cCampo) $ "ZZF_FILIAL, ZZF_DATINC"})
    Local oStruGRID := FWFormStruct(2, "ZZF", {|cCampo| AllTRim(cCampo) $ "ZZF_FILIAL, ZZF_DATINC, ZZF_CODPRO, ZZF_DESPRO, ZZF_QUANT, ZZF_LOCAL"})
 
    // oStruCab:RemoveField("ZZF_DATINC")
    	
    //Define que o cabeçalho não terá abas
    oStruCab:SetNoFolder()

    oStruGRID:RemoveField("ZZF_FILIAL") 
    oStruGRID:RemoveField("ZZF_DATINC") 

    //Cria o View
    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
 
    //Cria uma área de Field vinculando a estrutura do cabeçalho com MDFieldZZF, e uma Grid vinculando com MdGridZZF
    oView:AddField('VIEW_ZZF', oStruCab, 'MdFieldZZF')
    oView:AddGrid ('GRID_ZZF', oStruGRID, 'MdGridZZF' )
 
    //O cabeçalho (MAIN) terá 10% de tamanho, e o restante de 90% irá para a GRID
    oView:CreateHorizontalBox("MAIN", 10)
    oView:CreateHorizontalBox("GRID", 90)
 
    //Vincula o MAIN com a VIEW_ZZF e a GRID com a GRID_ZZF
    oView:SetOwnerView('VIEW_ZZF', 'MAIN')
    oView:SetOwnerView('GRID_ZZF', 'GRID')
    oView:EnableControlBar(.T.)
 
    //Define o campo incremental da grid como o ZZF_ITEM
    // oView:AddIncrementField('GRID_ZZF', 'ZZF_ITEM')

// função para atualizar a descrição quando da inclusão.
    oView:SetAfterViewActivate({|oView| _IniCpos(oView)} ) 
Return oView
 
//Função chamada para montar o modelo de dados da Grid
Static Function fModStruct()
    Local oStruct
    oStruct := FWFormStruct(1, 'ZZF')
Return oStruct
 
//Função chamada para montar a visualização de dados da Grid
Static Function fViewStruct()
    Local oStruct
    oStruct := FWFormStruct(2, "ZZF")
Return oStruct

Static Function fCommit(oModel)
    Local lRet := .T.

    FWFormCommit( oModel )

Return lRet

Static Function _IniCpos(oView)

    Local nOperation := oView:GetOperation() 
    Local oModel := FWModelActive() 
    Local oModelZZF := oModel:GetModel("MdFieldZZF")
    Local oMoGridZZF := oModel:GetModel("MdGridZZF")

    If nOperation == 3
		oModelZZF:SetValue("ZZF_DATINC",DDATABASE )
		oMoGridZZF:SetValue("ZZF_DATINC",DDATABASE )
        oView:Refresh()
    EndIf


Return
