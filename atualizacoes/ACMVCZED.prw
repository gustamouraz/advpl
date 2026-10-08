#Include "Totvs.ch"
#include "rwmake.ch"
#INCLUDE 'FWMVCDef.ch'
#include 'PROTHEUS.CH'
#Include 'topconn.ch'

/* PROJETO CENTRO DE DISTRIBUICAO - JAN/2024 (PROJCD)
@Autor:         André Claro
@Data:          02/12/2024
@Descrição:     Cadastro de log das movimentações de alteração de data de lote do estoque.
                
*/

Static cTitulo := "Amarração de Naturezas x Espécies"

User Function ACMVCZED()

	Local aArea   := GetArea()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SED")
	oBrowse:SetDescription(cTitulo)

	oBrowse:Activate()

	RestArea(aArea)

Return


Static Function MenuDef()
	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ACMVCZED' OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRot TITLE 'Alterar' ACTION 'VIEWDEF.ACMVCZED' OPERATION MODEL_OPERATION_UPDATE   ACCESS 0

Return aRot

Static Function ModelDef()
	Local oModel      := NIL
	Local oStruCab    := FWFormStruct(1, 'SED', {|cCampo| AllTRim(cCampo) $ "ED_FILIAL, ED_CODIGO, ED_DESCRIC"})
	Local oStruGrid   := FWFormStruct(1, 'ZED')


	oStruCab:SetProperty("ED_CODIGO",MODEL_FIELD_WHEN,{|| .F.})
	oStruCab:SetProperty("ED_DESCRIC",MODEL_FIELD_WHEN,{|| .F.})

	oStruGrid:AddTrigger( "ZED_ESPECI", "ZED_DSCESP", { || .t. }, { | oFields | Left(Alltrim(Posicione('SX5', 1, FWxFilial('SX5')+"42" + oFields:GetValue('ZED_ESPECI'), 'X5_DESCRI')), TamSx3("ZED_DSCESP")[1]) } )

	oModel := MPFormModel():New('CADZEDM', {|| AVLVZEDALT() }, {|oModel| fValidGrid(oModel)}, {|oModel| fCommit(oModel) } , /*bCancel*/ )
	oModel:AddFields('MdFieldZED', NIL, oStruCab)
	oModel:AddGrid('MdGridZED', 'MdFieldZED', oStruGrid, , )

	oModel:SetRelation('MdGridZED', {;
		{'ZED_FILIAL', "ED_FILIAL"  },;
		{"ZED_NATURE", "ED_CODIGO"  };
		}, ZED->(IndexKey(1)))

	oModel:GetModel("MdGridZED"):SetMaxLine(9999)
	oModel:SetDescription("Amarração de Naturezas x Espécies")

	oModel:SetPrimaryKey({"ZED_FILIAL","ZED_NATURE","ZED_ESPECI"})

Return oModel

Static Function ViewDef()

	Local oView        := NIL
	Local oModel    := FWLoadModel('ACMVCZED')
	Local oStruCab  := FWFormStruct(2, "SED", {|cCampo| AllTRim(cCampo) $ "ED_FILIAL, ED_CODIGO, ED_DESCRIC" })
	Local oStruGRID := FWFormStruct(2, "ZED")

	oStruCab:RemoveField("ED_FILIAL")

	oStruCab:SetNoFolder()

	oStruGRID:RemoveField("ZED_FILIAL")
	oStruGRID:RemoveField("ZED_NATURE")

	oView:= FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('VIEW_ZED', oStruCab, 'MdFieldZED')
	oView:AddGrid ('GRID_ZED', oStruGRID, 'MdGridZED' )

	oView:CreateHorizontalBox("MAIN", 40)
	oView:CreateHorizontalBox("GRID", 60)

	oView:SetOwnerView('VIEW_ZED', 'MAIN')
	oView:SetOwnerView('GRID_ZED', 'GRID')
	oView:EnableControlBar(.T.)

	//Define o campo incremental da grid como o ZGN_ITEM
	oView:AddIncrementField('GRID_ZED', 'ZED_ITEM')

Return oView

//Função chamada para montar o modelo de dados da Grid
Static Function fModStruct()
	Local oStruct
	oStruct := FWFormStruct(1, 'SED')
Return oStruct

//Função chamada para montar a visualização de dados da Grid
Static Function fViewStruct()
	Local oStruct

	oStruct := FWFormStruct(2, "ZED")
Return oStruct

//Função que faz a validação da grid
Static Function fValidGrid(oModel)
	Local _lRet     := .T.

Return _lRet

static function fCommit(oModel)
	Local lRet := .T.

	FWFormCommit( oModel )

Return lRet

User Function zZEDitem()

	Local _cItem := "001"

Return _cItem



Static Function AVLVZEDALT()
	Local _lRet := .T.

Return _lRet


User Function ACVLDZED(_cEsp, _cTpFret,_cNat, _cSerie, _lMt140, _lMt116,lHelp)

	local _lRet      := .T.
	local _cEspSerie := SuperGetMv("MV_ZESPSER",.F.,"SPED") //Espécies que obrigaam o preenchimento da série na NF
	local _cEspFrete := SuperGetMv("MV_ZESPTPF",.F.,"SPED") //Espécies que obrigaam o preenchimento do tipo de frete na NF
	local _cFilZED   := xFilial("ZED")
	local _cFNCZND   := SuperGetMv("MV_ZFNCZED",.F.,"MATA100|MATA103|MATA116|MATA140")
	local cHelp      := ''

	default _cEsp   := ''
	default _cTpFret:= ''
	default _cNat   := ''
	default _lMt140 := .F.
	default _cSerie := ''
	default _lMt116 := .F.
	default lHelp   := .T.

	//If IsInCallStack("U_TXMLV2")
	If !(Alltrim(FunName()) $ _cFNCZND) //Se a função não estiver sendo execuatda pela própria roina, sai reorno verdadeiro.
		Return .T.
	EndIf

	If !Empty(_cEsp)
		If Alltrim(_cEsp) $ _cEspSerie .and. Empty(_cSerie) .and. !Empty(_cEspSerie) //3-TRAVA SÉRIE: Documento de entrada, Pré documento de entrada.
			_lRet := .F.
			/* Aviso("ATENÇÃO","Serie obrigatória para NF com espécie "+Alltrim(_cEsp),{"REVISAR"},2) */
			cHelp := 'Serie obrigatória para NF com espécie ' + allTrim(_cEsp)
		ElseIf Alltrim(_cEsp) $ _cEspFrete .and. Empty(_cTpFret) .and. !Empty(_cEspFrete) .and. !_lMt140 .AND. !_lMt116 //2-TRAVA TIPO DE FRETE: Documento de entrada.
			_lRet := .F.
            /* Aviso("ATENÇÃO","Tp. Frete obrigatório para NF com espécie "+Alltrim(_cEsp),{"REVISAR"},2) */
			cHelp := 'Tp. Frete obrigatório para NF com espécie ' + allTrim(_cEsp)
		ElseIf !_lMt140 //Se vier da NF já vai ter a natureza!
			DbSelectArea("ZED")
			ZED->(DbSetorder(1))
			ZED->(DbGoTop())
			If ZED->(DbSeek(_cFilZED + _cNat + _cEsp ))
				If ZED->ZED_OPERAC == "B" //Se bloqueia
					_lRet := .F.
					/* Aviso("ATENÇÃO","A natureza "+_cNat+" não pode ser utilizada com a espécie "+Alltrim(_cEsp),{"REVISAR"},2) */
					cHelp := 'A natureza ' + _cNat + ' não pode ser utilizada com a espécie ' + allTrim(_cEsp)
				EndIf
			EndIf
		EndIf
	EndIf

	if !lRet .and. lHelp .and. !empty(cHelp)
		help(,,'ACVLDZED',,cHelp,1,0)
	endif

Return _lRet

/*
User Function ACMVZEDV()

Local _cChvSB8 := ''

	cTitulo 			:= "Amarração de Naturezas x Espécies"
	cPrograma 			:= 'ACMVCZED'
	nOperation 			:= MODEL_OPERATION_VIEW
	__lConfirmar		:= .F.
	__nOper     		:= 1
	__lBTNConfirma	:= .T.

    _cChvSB8 := SD5->(D5_FILIAL + D5_PRODUTO +D5_LOCAL + D5_LOTECTL + D5_NUMLOTE  )

	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Confirmar"},{.T.,"Sair"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"//"Salvar"
	DbSelectArea("ZED")
	ZED->(DbSetOrder(1)) //ZED_FILIAL+ZED_PRODUT+ZED_LOCAL+ZED_LOTECT+ZED_NUMLOT+ZED_IDLOG
	ZED->(DbGoTop())
	
	If ZED->(DbSeek(_cChvSB8) )
		FWExecView( cTitulo , cPrograma, nOperation, , {|| .T. },, , aButtons ,  )
	Else
		Aviso("Atenção","Nâo há logs para esse lote!",{"SAIR"},2)
	EndIf

Return 

*/
