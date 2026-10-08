#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} User Function MAS43T01
    (Tela em MVC para o cadastro das regras fiscais utilizadas no processamento dos CTEs)
    @type  Function
    @author Luan Woichechoscki
    @since 20/03/2024
    @version version
/*/
User Function MAS43T01()
	Local oBrowse := FwLoadBrw("MAS43T01")
	oBrowse:Activate()
Return

Static Function BrowseDef()
	Local oBrowse := FwMBrowse():New()
	Local  aSeek	  := {}

	Aadd( aSeek, { "Filial + Modal + Operação",{ {"","C",2,0,"ZNC_FILIAL",}, {"","C",5,0,"ZNC_MODAL",},  {"","C",5,0,"ZNC_CODOPE",}},1})
	Aadd( aSeek, { "Modal + Operação",{ {"","C",5,0,"ZNC_MODAL",},  {"","C",5,0,"ZNC_CODOPE",}},2})

	oBrowse:SetAlias("ZNC")
	oBrowse:SetDescription("Cadastro de Regras Fiscais")
	oBrowse:SetSeek(.T.,aSeek)
	oBrowse:SetMenuDef("MAS43T01")

Return (oBrowse)

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar'   ACTION 'VIEWDEF.MAS43T01' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE 'Incluir'      ACTION 'VIEWDEF.MAS43T01' OPERATION MODEL_OPERATION_INSERT  ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE 'Alterar'      ACTION 'VIEWDEF.MAS43T01' OPERATION MODEL_OPERATION_UPDATE  ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE 'Excluir'      ACTION 'VIEWDEF.MAS43T01' OPERATION MODEL_OPERATION_DELETE  ACCESS 0 // Alterar
Return aRotina

Static Function ModelDef()

	Local oModel
	Local oStruZB2 := FwFormStruct(1, "ZNC")

	oModel := MPFormModel():New("ZNCMODEL",, {|oModel| bPost() },/*bCommit*/,/*bCancel*/)
	oModel:AddFields("ZNCMASTER", NIL, oStruZB2)
	oModel:SetDescription("Cadastro")
	oModel:SetPrimaryKey({})

Return (oModel)

Static Function ViewDef()

	Local oView    := FwFormView():New()
	Local oStruZB2 := FwFormStruct(2, "ZNC")
	Local oModel   := FwLoadModel("MAS43T01")

	oView:SetModel(oModel)
	oView:AddField("VIEW_ZNC", oStruZB2, "ZNCMASTER")
	oView:CreateHorizontalBox("TELA" , 100)
	oView:SetOwnerView("VIEW_ZNC", "TELA")

Return (oView)

/*/{Protheus.doc} bPost
	(long_description)
	@Validação para não ter registros duplicados. 
	@Daniel Victor da Rosa
	@since 03/04/2024
/*/
Static Function bPost()

	Local lOkay := .T.
	Local oModel:= FwModelActive()

	IF oModel:GETOPERATION() == 3

		DBSELECTAREA("ZNC")
		DBSETORDER(1)
		IF DBSEEK(xfilial("ZNC")+M->ZNC_MODAL+M->ZNC_CODOPE+M->ZNC_TES)
			lOkay := .F.
			Help( ,, 'Help',, "Registro já cadastrado na base de dados", 1, 0 )
		ELSE
			lOkay := .T.
		ENDIF
		
	ENDIF

Return lOkay
