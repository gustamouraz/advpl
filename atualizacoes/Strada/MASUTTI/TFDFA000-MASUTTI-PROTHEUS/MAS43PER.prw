// BIBLIOTECAS NECESSÁRIAS
#Include "TOTVS.ch"

// VARIÁVEL DE RETORNO
Static MP_CONPAD As Character

/*/{Protheus.doc} MAS43PER
	CONSULTA PADRÃO COM CAIXA DE MARCAÇÃO (MARKBROWSE)
	@Daniel Victor da Rosa
	@since 03/04/2024
/*/
User Function MAS43PER()

	Local aArea   As Array
	Local lFind   As Logical
	Local oDialog As Object
	Private oMark   As Object
	Private cAlias  := GetNextAlias()

	lFind   := .F.
	aArea   := GetArea()
	oDialog := GenDialog(50)

	GenMarkBrw(@oDialog)

	ACTIVATE MSDIALOG oDialog CENTERED
	RestArea(aArea)

	IIf (MP_CONPAD != NIL .And. Len(MP_CONPAD) > 0, lFind := .T., lFind := .F.)
Return (lFind)

/*/{Protheus.doc} GenDialog
	EFETUA A MONTAGEM DA CAIXA DE DIÁLOGO DE FUNDO
	@Daniel Victor da Rosa
	@since 03/04/2024
/*/
Static Function GenDialog(nPercent As Numeric)
	Local oSize   As Object
	Local oDialog As Object

	oSize := FwDefSize():New(.F.)

	DEFINE MSDIALOG oDialog TITLE "Consulta Padrão - TES" FROM 000,000 TO Round(oSize:aWindSize[3] * (nPercent/100), 0), Round(oSize:aWindSize[4] * (nPercent/100), 0) PIXEL
Return (oDialog)

/*/{Protheus.doc} GenMarkBrw
	INCORPORA A GRID EM UMA CAIXA DE DIÁLOGO
	@Daniel Victor da Rosa
	@since 03/04/2024
/*/
Static Function GenMarkBrw(oDialog As Object)

	Local aFields As Array

	aFields := {}
	GenTable(cAlias)

	AAdd(aFields, {"Filail",    "TRB_FIL",  "C", 06, 00})
	AAdd(aFields, {"Código",    "TRB_COD",  "C", 03, 00})
	AAdd(aFields, {"Descrição", "TRB_DESC", "C", 30, 00})

	oMark := FwMarkBrowse():New()
	oMark:AddMarkColumns( { || if( TRB_OK == 1,"LBOK","LBNO") },{ || Marca()})
	oMark:SetAlias(cAlias)
	oMark:SetIgnoreARotina(.T.)
	oMark:SetMenuDef("TESTE296")
	oMark:SetTemporary(.T.)
	oMark:SetMark( "OK" , "TRB", "TRB_OK")
	oMark:SetFields(aFields)
	oMark:SetOwner(oDialog)
	oMark:IsInvert(.T.)
	oMark:SetDescription("Tipos")
	oMark:SetOnlyFields({"TRB_FIL", "TRB_COD", "TRB_DESC"})
	oMark:AddButton("Confirmar", {|| CheckSelected(@oMark)})
	oMark:AddButton("Visualizar", {|| visuaTes() })

	oMark:Activate()
Return (NIL)

/*/{Protheus.doc} GenTable
	GERA O ARQUIVO DE TRABALHO
	@Daniel Victor da Rosa
	@since 03/04/2024
/*/
Static Function GenTable(cAlias As Character)

	Local oTable   As Object
	Local aFields  As Array
	Local nX       As Numeric
	Local cQuery   As Character
	Private aData  As Array

	nX      := 0
	aData   := {}
	aFields := {}
	oTable  := FwTemporaryTable():New(cAlias)

	AAdd(aFields, {"TRB_OK",   "N", 01, 00})
	AAdd(aFields, {"TRB_FIL",  "C", 06, 00})
	AAdd(aFields, {"TRB_COD",  "C", 03, 00})
	AAdd(aFields, {"TRB_DESC", "C", 30, 00})
	AAdd(aFields, {"TRB_REC",  "N", 16, 00})

	oTable:SetFields(aFields)
	oTable:AddIndex("01", {"TRB_COD"})
	oTable:Create()

	DbSelectArea(cAlias)

	cQuery := "SELECT  SF4.F4_FILIAL, SF4.F4_CODIGO, SF4.F4_TEXTO, SF4.R_E_C_N_O_ AS REC  "+CRLF+;
		"FROM " + RETSQLNAME('SF4') + " SF4 " +CRLF+;
		"WHERE SF4.D_E_L_E_T_ = ' ' AND SF4.F4_CODIGO <= '500' " +CRLF+;
		" ORDER BY  SF4.F4_CODIGO,  SF4.F4_FILIAL "

	oQuery:= FWPreparedStatement():New()
	oQuery:SetQuery(cQuery)
	cQuery := oQuery:GetFixQuery()
	cQuery := ChangeQuery(cQuery)
	cAlias2  := MPSysOpenQuery(cQuery)

	IF (cAlias2)->( !EOF() )
		WHILE (cAlias2)->( !EOF() )
			AAdd(aData, {(cAlias2)->F4_FILIAL, (cAlias2)->F4_CODIGO,   AllTrim( (cAlias2)->F4_TEXTO ), (cAlias2)->REC })
			(cAlias2)->( dbSkip() )
		ENDDO
	ELSE
		FWAlertHelp("Sem registros", "Verificar")
		VAR_IXB := ""
		cFilAnt := cFilBkp
		Return .T.
	ENDIF

	(cAlias2)->( dbCloseArea() )

	For nX := 1 To Len(aData)
		RecLock(cAlias, .T.)
		TRB_FIL  := aData[nX][1]
		TRB_COD  := aData[nX][2]
		TRB_DESC := aData[nX][3]
		TRB_REC  := aData[nX][4]
		MsUnlock()
	Next nX

	DbGoTop()
Return (NIL)

/*/{Protheus.doc} CheckSelected
	PREPARA O RETORNO PARA O CAMPO
	@Daniel Victor da Rosa
	@since 03/04/2024
/*/
Static Function CheckSelected(oMark As Object)

	Local cSelected As Character
	cSelected := Space(0)

	DbGoTop()
	DbEval({|| IIf((cAlias)->TRB_OK == 1, cSelected += "+" + AllTrim(TRB_COD), cSelected += Space(0))})
	MP_CONPAD := IIf(Len(cSelected) > 0, SubStr(cSelected, 2), cSelected)

	oMark:oBrowse:oOwner:End()
Return (NIL)

/*/{Protheus.doc} MenuDef
    SOBRESCRIÇÃO DAS OPERAÇÕES DA ROTINA PADRÃO
    @Daniel Victor da Rosa
    @since 04/04/2024
/*/
Static Function MenuDef()
	Local aRotina As Array
	aRotina := {}
Return (aRotina)

/*/{Protheus.doc} T200GET
    RETORNA A VARIÁVEL ESTÁTICA PARA O CAMPO
    @Daniel Victor da Rosa
    @since 04/04/2024
/*/
User Function T200GET()
Return (MP_CONPAD)

/*/{Protheus.doc} visuaTes
    VISUALIZAR A TES
    @Daniel Victor da Rosa
    @since 04/04/2024
/*/
Static Function visuaTes()

    Local cFilBkp     := cFilAnt
	Local aAreas      := {ZNC->(Getarea()),SF4->(GetArea()),GetArea()}
	Local nRec        := (cAlias)->TRB_REC
	Private cCadastro := "TES"

	cFilAnt := (cAlias)->TRB_FIL

	DBSELECTAREA("SF4")
	SF4->(DBGOTO(nRec))

	AxVisual("SF4",nRec, 2)
	AEval(aAreas,{|x,y| RestArea(x) })

	cFilAnt := cFilBkp

Return

/*/{Protheus.doc} Marca
    CONTROLA A MARCAÇÂO UNICA 
    @Daniel Victor da Rosa
    @since 04/04/2024
/*/
Static Function Marca()

	Local aArea	:= GetArea()
	Local nRec := (cAlias)->(RECNO())
	Local nMarca	:= 0
	Local nLinha    := oMark:At()

	If (cAlias)->TRB_OK == 0
		nMarca := 1
		(cAlias)->(DBGOTOP())
		while  (cAlias)->(!EOF())
			IF (cAlias)->TRB_OK == 1 .AND. (cAlias)->(RECNO()) <> nRec
				reclock((cAlias),.F.)
				(cAlias)->TRB_OK := 0
				(cAlias)->(msUnlock())
			ENDIF
			(cAlias)->(DBSKIP())
		end
		(cAlias)->(DBGOTO(nRec))
	EndIf
	reclock((cAlias),.F.)
	(cAlias)->TRB_OK := nMarca
	(cAlias)->(msUnlock())

	omark:refresh()
	omark:goto(nLinha)

	RestArea(aArea)

Return .T.
