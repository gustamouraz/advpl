#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

Static cTitulo := "Planejamento Safra"
Static cZZJCtx := ""
Static cZZJVaried  := ""
Static cZZJCultur  := ""
Static cZZJSafra   := ""
Static cZZJPacote  := ""
Static cZZJFilial  := ""
Static cZZJCodEtp  := ""
Static nZZJAreGer  := 0
Static nZZJCstHa  := 0
Static nZZJEtapa   := 1
Static oZZJTmp     := Nil
Static oZZJBrw     := Nil
Static oZZJGrid    := Nil
Static oZZJCstHa   := Nil
Static cZZJFSel    := ""
Static aZZJAvC    := {}

/*/{Protheus.doc} LMFZZJ
Tela manual para planejamento de safra com grid de itens.
@type function
/*/
// Abre o browse principal do cadastro ZZJ.
User Function LMFZZJ()
	Local aArea   := FWGetArea()
	Local oBrowse := FWMBrowse():New()
	Local aSeek   := {}
	Local aFils   := ZZJFILS()

	AAdd(aSeek, { "Filial", ;
		{{ "", "C", 12, 0, "ZZK_FILIAL", "@!" }}, 1 } )
	AAdd(aSeek, { "Cultura", ;
		{{ "", "C", 20, 0, "ZZK_CULTD", "@!" }}, 2 } )
	AAdd(aSeek, { "Tecnologia", ;
		{{ "", "C", 80, 0, "ZZK_VARIED", "@!" }}, 3 } )
	AAdd(aSeek, { "Ano Safra", ;
		{{ "", "C", 10, 0, "ZZK_SAFRA", "@!" }}, 4 } )
	AAdd(aSeek, { "Pacote", ;
		{{ "", "C", 40, 0, "ZZK_PACDS", "@!" }}, 5 } )

	// A ZZK ja e mantida pontualmente nas gravacoes. Evita reconstruir todos
	// os resumos ao abrir a rotina, o que gerava bloqueios entre filiais.
	// Remove eventuais duplicidades deixadas pela antiga busca por indice.
	ZZKFIX()
	DbSelectArea("ZZK")
	ZZK->(DbSetOrder(1))
	ZZK->(DbGoTop())
	oZZJTmp := oBrowse
	oBrowse:SetAlias("ZZK")	
	// Limita o seletor padrao de filial a mesma regra da selecao customizada.
	oBrowse:SetFilial(aFils)
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("LMFZZJ")
	oBrowse:SetDBFFilter(.T.)
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetFilterDefault("")
	// Filtros predefinidos para separar os pacotes de solo dos demais insumos.
	If ZZJPACOK("S")
		oBrowse:AddFilter("Solos", "(ZZK->ZZK_PACOTE == 'S' .Or. ZZK->ZZK_PACOTE == 'A')")
	EndIf
	oBrowse:AddFilter("Insumos", "(ZZK->ZZK_PACOTE <> 'S' .And. ZZK->ZZK_PACOTE <> 'A')")
	oBrowse:SetWalkThru(.F.)
	// A inclusao usa o seletor padrao filtrado por SetFilial().
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetOnlyFields({ "ZZK_FILIAL", "ZZK_CULTD", "ZZK_VARIED", "ZZK_AREGER", "ZZK_CSTPHA", "ZZK_SAFRA", "ZZK_PACDS", "ZZK_DAE" })
	oBrowse:SetSeek(.T., aSeek)
	oBrowse:Activate()

	FWRestArea(aArea)
Return Nil

// Define as opcoes do browse.
Static Function MenuDef()
	Local aRotina := {}

	AAdd(aRotina, { "Incluir", "U_ZZJINC()", 0, 3, 0, Nil })
	AAdd(aRotina, { "Alterar/Visualizar", "U_ZZJALT()", 0, 4, 0, Nil })
	AAdd(aRotina, { "Excluir Pacote", "U_ZZJEXC()", 0, 5, 0, Nil })
	AAdd(aRotina, { "Imprimir Planilha", "U_ZZJIMP()", 0, 6, 0, Nil })
	If ZZJUVGA()
		AAdd(aRotina, { "Volume Geral Final", "U_ZZJVGF()", 0, 7, 0, Nil })
	EndIf
	AAdd(aRotina, { "Atualizar", "U_ZZJATU()", 0, 8, 0, Nil })

Return aRotina

// Sincroniza somente o resumo posicionado e atualiza o browse.
User Function ZZJATU()
	Local aArea := FWGetArea()
	Local cFil  := ""
	Local cCul  := ""
	Local cVar  := ""
	Local cSaf  := ""
	Local cPac  := ""

	// A atualizacao geral percorria todas as filiais e disputava bloqueios na
	// ZZK com outros usuarios. Os dados ja sao sincronizados na gravacao; esta
	// acao reprocessa apenas o pacote atualmente selecionado.
	If !Empty(cZZJFilial) .And. !Empty(cZZJCultur) .And. !Empty(cZZJVaried) .And. !Empty(cZZJSafra)
		cFil := cZZJFilial
		cCul := cZZJCultur
		cVar := cZZJVaried
		cSaf := cZZJSafra
		cPac := cZZJPacote
	ElseIf Select("ZZK") > 0 .And. !ZZK->(Eof())
		DbSelectArea("ZZK")
		cFil := AllTrim(cValToChar(ZZK->ZZK_FILIAL))
		cCul := AllTrim(cValToChar(ZZK->ZZK_CULTUR))
		cVar := AllTrim(cValToChar(ZZK->ZZK_VARIED))
		cSaf := AllTrim(cValToChar(ZZK->ZZK_SAFRA))
		cPac := AllTrim(cValToChar(ZZK->ZZK_PACOTE))
	EndIf

	If !Empty(cFil) .And. !Empty(cCul) .And. !Empty(cVar) .And. !Empty(cSaf)
		ZZKSYN(cFil, cCul, cVar, cSaf, cPac)
	EndIf

	If ValType(oZZJTmp) == "O"
		oZZJTmp:Refresh()
	EndIf

	FWRestArea(aArea)
Return Nil

// Sincroniza a ZZK a partir dos itens gravados na ZZJ.
Static Function ZZJBTAB()
	Local cAlias  := GetNextAlias()
	Local cQuery  := ""
	Local cFilRow := ""
	Local cCulRow := ""
	Local cVarRow := ""
	Local cSafRow := ""
	Local cPac    := ""

	cQuery := " SELECT ZZJ_FILIAL, ZZJ_CULTUR, ZZJ_VARIED, MAX(ZZJ_AREGER) ZZJ_AREGER, MAX(ZZJ_CUSTO) ZZJ_CUSTO, ZZJ_SAFRA, "
	cQuery += " CASE WHEN LEFT(ZZJ_ETAPA,1) BETWEEN '0' AND '9' THEN '' ELSE LEFT(ZZJ_ETAPA,1) END ZZJ_PACOTE, "
	cQuery += " MIN(ZZJ_DAE) ZZJ_DAE, SUM(ZZJ_CSTDHA) ZZJ_CSTDHA "
	cQuery += " FROM " + RetSqlName("ZZJ")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY ZZJ_FILIAL, ZZJ_CULTUR, ZZJ_VARIED, ZZJ_SAFRA, "
	cQuery += " CASE WHEN LEFT(ZZJ_ETAPA,1) BETWEEN '0' AND '9' THEN '' ELSE LEFT(ZZJ_ETAPA,1) END "
	cQuery += " ORDER BY ZZJ_FILIAL, ZZJ_CULTUR, ZZJ_VARIED, ZZJ_SAFRA, ZZJ_PACOTE "

	MpSysOpenQuery(cQuery, cAlias)
	While !(cAlias)->(Eof())
		cFilRow := AllTrim(cValToChar((cAlias)->ZZJ_FILIAL))
		If !ZZJAFIL(cFilRow)
			(cAlias)->(DbSkip())
			Loop
		EndIf

		cCulRow := AllTrim(cValToChar((cAlias)->ZZJ_CULTUR))
		cVarRow := AllTrim(cValToChar((cAlias)->ZZJ_VARIED))
		cSafRow := AllTrim(cValToChar((cAlias)->ZZJ_SAFRA))
		cPac := AllTrim(cValToChar((cAlias)->ZZJ_PACOTE))
		ZZKGRV(cFilRow, cCulRow, cVarRow, cSafRow, cPac, (cAlias)->ZZJ_AREGER, (cAlias)->ZZJ_CUSTO, (cAlias)->ZZJ_CSTDHA, (cAlias)->ZZJ_DAE)
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

	DbSelectArea("ZZK")
	ZZK->(DbGoTop())

Return "ZZK"

// Inclui ou atualiza uma linha agrupada da ZZK.
Static Function ZZKGRV(cFil, cCul, cVar, cSaf, cPac, nArea, nCusto, nCstPac, nDae)
	Local aRec   := ZZKREC(cFil, cCul, cVar, cSaf, cPac)
	Local lFound := Len(aRec) > 0
	Local nI     := 0

	DbSelectArea("ZZK")
	If lFound
		ZZK->(DbGoTo(aRec[1]))
		lFound := !ZZK->(Eof()) .And. !ZZK->(Deleted())
	EndIf
	If !lFound
		If !RecLock("ZZK", .T.)
			Return .F.
		EndIf
	ElseIf !RecLock("ZZK", .F.)
		Return .F.
	EndIf

	ZZK->ZZK_FILIAL := cFil
	ZZK->ZZK_CULTUR := cCul
	ZZK->ZZK_CULTD  := ZZJCUD(cCul)
	ZZK->ZZK_VARIED := cVar
	ZZK->ZZK_AREGER := nArea
	ZZK->ZZK_CUSTO  := nCusto
	ZZK->ZZK_CSTPHA := nCstPac
	ZZK->ZZK_SAFRA  := cSaf
	ZZK->ZZK_PACOTE := cPac
	ZZK->ZZK_PACDS  := IIf(Empty(cPac), "SEM PACOTE", ZZJPDS(cPac))
	ZZK->ZZK_DAE    := nDae
	ZZK->(MsUnlock())

	// Mantem apenas o primeiro resumo quando ja existem linhas repetidas.
	For nI := 2 To Len(aRec)
		ZZK->(DbGoTo(aRec[nI]))
		If !ZZK->(Eof()) .And. !ZZK->(Deleted()) .And. RecLock("ZZK", .F.)
			ZZK->(DbDelete())
			ZZK->(MsUnlock())
		EndIf
	Next
	ZZK->(DbCommit())

Return Nil

// Retorna os RECNOs do resumo sem depender da ordem configurada no SX2/SIX.
Static Function ZZKREC(cFil, cCul, cVar, cSaf, cPac)
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local aRet   := {}

	cQuery := " SELECT R_E_C_N_O_ ZREC "
	cQuery += " FROM " + RetSqlName("ZZK")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND ZZK_FILIAL = '" + ZZJSQL(cFil) + "' "
	cQuery += " AND ZZK_CULTUR = '" + ZZJSQL(cCul) + "' "
	cQuery += " AND ZZK_VARIED = '" + ZZJSQL(cVar) + "' "
	cQuery += " AND ZZK_SAFRA = '" + ZZJSQL(cSaf) + "' "
	cQuery += " AND ZZK_PACOTE = '" + ZZJSQL(cPac) + "' "
	cQuery += " ORDER BY R_E_C_N_O_ "

	MpSysOpenQuery(cQuery, cAlias)
	While !(cAlias)->(Eof())
		AAdd(aRet, (cAlias)->ZREC)
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

Return aRet

// Elimina duplicidades preexistentes na tabela de resumo.
Static Function ZZKFIX()
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local cFil   := ""
	Local cCul   := ""
	Local cVar   := ""
	Local cSaf   := ""
	Local cPac   := ""
	Local aRec   := {}
	Local nI     := 0

	cQuery := " SELECT ZZK_FILIAL, ZZK_CULTUR, ZZK_VARIED, ZZK_SAFRA, ZZK_PACOTE "
	cQuery += " FROM " + RetSqlName("ZZK")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY ZZK_FILIAL, ZZK_CULTUR, ZZK_VARIED, ZZK_SAFRA, ZZK_PACOTE "
	cQuery += " HAVING COUNT(*) > 1 "

	MpSysOpenQuery(cQuery, cAlias)
	While !(cAlias)->(Eof())
		cFil := AllTrim(cValToChar((cAlias)->ZZK_FILIAL))
		If ZZJAFIL(cFil)
			cCul := AllTrim(cValToChar((cAlias)->ZZK_CULTUR))
			cVar := AllTrim(cValToChar((cAlias)->ZZK_VARIED))
			cSaf := AllTrim(cValToChar((cAlias)->ZZK_SAFRA))
			cPac := AllTrim(cValToChar((cAlias)->ZZK_PACOTE))
			aRec := ZZKREC(cFil, cCul, cVar, cSaf, cPac)

			DbSelectArea("ZZK")
			For nI := 2 To Len(aRec)
				ZZK->(DbGoTo(aRec[nI]))
				If !ZZK->(Eof()) .And. !ZZK->(Deleted()) .And. RecLock("ZZK", .F.)
					ZZK->(DbDelete())
					ZZK->(MsUnlock())
				EndIf
			Next
			ZZK->(DbCommit())
			// Recalcula o resumo preservado com os valores atuais da ZZJ.
			ZZKSYN(cFil, cCul, cVar, cSaf)
		EndIf
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

Return Nil


/*/{Protheus.doc} ZZJETD
Retorna a descricao completa da etapa para uso em campo virtual no browse.
@type function
/*/
// Traduz ZZJ_ETAPA para a descricao completa da etapa.
User Function ZZJETD(cEtapa)
	Local cCod := ""
	Local cPac := ""
	Local aEtp := {}
	Local nPos := 0
	Local cRet := ""
	Local nEq  := 0

	If PCount() == 0 .Or. cEtapa == Nil
		If Select("ZZJ") > 0
			cEtapa := ZZJ->ZZJ_ETAPA
		Else
			Return ""
		EndIf
	EndIf

	cCod := ZZJETC(cEtapa)
	cPac := ZZJPCE(cCod)
	aEtp := ZZJETA(cPac)
	nPos := AScan(aEtp, {|cItem| ZZJETN(ZZJETC(cItem), cPac) == ZZJETN(cCod, cPac)})

	If nPos > 0
		cRet := aEtp[nPos]
		nEq := At("=", cRet)
		If nEq > 0
			cRet := SubStr(cRet, nEq + 1)
		EndIf
	EndIf

	If Empty(cRet)
		cRet := cCod
	EndIf

Return AllTrim(cRet)

// Solicita os dados principais antes de abrir a inclusao.
User Function ZZJINC()
	Local aArea    := FWGetArea()
	// A operacao 3 do FWMBrowse ja solicitou a filial e SetFilial() limitou
	// as opcoes. Usa a filial ativa, sem abrir a selecao customizada novamente.
	Local cFilSel  := AllTrim(cValToChar(xFilial("ZZJ")))
	Local aSel     := {}
	Local cAcao    := ""
	Local cPacNext := ""

	aZZJAvC := {}
	If Empty(cFilSel) .Or. !ZZJAFIL(cFilSel)
		MsgStop("Selecione uma filial permitida para o planejamento." + CRLF + CRLF + ;
			"Filiais permitidas:" + CRLF + ZZJFILMSG(), cTitulo)
		FWRestArea(aArea)
		Return Nil
	EndIf

	aSel := ZZJASK()
	If Len(aSel) == 0
		FWRestArea(aArea)
		Return Nil
	EndIf

	cZZJVaried  := aSel[1]
	cZZJCultur  := aSel[2]
	cZZJPacote  := aSel[3]
	cZZJSafra   := aSel[4]
	cZZJFilial  := cFilSel
	cZZJCodEtp  := ""
	cZZJCtx     := cZZJPacote
	nZZJEtapa   := 1

	If !ZZJPSOK(cZZJSafra, cZZJFilial)
		ZZJCLN()
		FWRestArea(aArea)
		Return Nil
	EndIf

	Do While .T.
		cAcao := ZZJRUN(1)
		// Tanto Finalizar quanto Confirmar permitem selecionar outro pacote.
		// ZZJASKP limita a lista aos pacotes ainda nao lancados neste contexto.
		If cAcao <> "F" .And. cAcao <> "P"
			Exit
		EndIf

		cPacNext := ZZJASKP()
		If Empty(cPacNext)
			Exit
		EndIf

		cZZJPacote := cPacNext
		cZZJCtx    := cZZJPacote
		cZZJCodEtp := ""
		nZZJEtapa  := 1
	EndDo

	// A ZZK ja foi sincronizada por ZZJCONS() em cada gravacao.
	ZZJREF()

	cZZJCtx    := ""
	cZZJVaried  := ""
	cZZJCultur  := ""
	cZZJPacote  := ""
	cZZJSafra   := ""
	cZZJFilial  := ""
	cZZJCodEtp  := ""
	nZZJAreGer  := 0
	nZZJEtapa   := 1
	FWRestArea(aArea)

Return Nil
// Abre alteracao posicionada no planejamento selecionado.
User Function ZZJALT()
	Local aArea := FWGetArea()
	Local cFilAlc := ""

	aZZJAvC := {}
	If Select("ZZK") > 0 .And. !ZZK->(Eof())
		DbSelectArea("ZZK")
		cFilAlc     := AllTrim(cValToChar(ZZK->ZZK_FILIAL))
		cZZJFilial  := cFilAlc
		cZZJVaried  := AllTrim(cValToChar(ZZK->ZZK_VARIED))
		cZZJCultur  := AllTrim(cValToChar(ZZK->ZZK_CULTUR))
		cZZJSafra   := AllTrim(cValToChar(ZZK->ZZK_SAFRA))
		nZZJAreGer  := ZZK->ZZK_AREGER
		cZZJPacote  := AllTrim(cValToChar(ZZK->ZZK_PACOTE))
		cZZJCodEtp  := ""
		cZZJCtx    := cZZJPacote
		nZZJEtapa   := 1
	ElseIf Select("ZZJ") > 0
		DbSelectArea("ZZJ")
		cFilAlc     := AllTrim(cValToChar(ZZJ->ZZJ_FILIAL))
		cZZJFilial  := cFilAlc
		cZZJVaried  := AllTrim(cValToChar(ZZJ->ZZJ_VARIED))
		cZZJCultur  := AllTrim(cValToChar(ZZJ->ZZJ_CULTUR))
		cZZJSafra   := AllTrim(cValToChar(ZZJ->ZZJ_SAFRA))
		nZZJAreGer  := ZZJ->ZZJ_AREGER
		cZZJCodEtp  := AllTrim(cValToChar(ZZJ->ZZJ_ETAPA))
		cZZJPacote  := ZZJPCE(cZZJCodEtp)
		cZZJCtx    := cZZJPacote
		nZZJEtapa   := Max(1, ZZJETN(cZZJCodEtp, cZZJPacote))
	EndIf

	If !ZZJAFIL(cFilAlc)
		MsgStop("Usuario sem acesso a filial do planejamento selecionado.", cTitulo)
		ZZJCLN()
		FWRestArea(aArea)
		Return Nil
	EndIf

	If !ZZJPACOK(cZZJPacote)
		MsgStop("Usuario sem permissao para utilizar este pacote.", cTitulo)
		ZZJCLN()
		FWRestArea(aArea)
		Return Nil
	EndIf
	If !ZZJPACCTXOK(cZZJPacote, cZZJCultur)
		MsgStop("Os pacotes de solo exigem a opcao Preparo de Solo.", cTitulo)
		ZZJCLN()
		FWRestArea(aArea)
		Return Nil
	EndIf

	If !ZZJPSOK(cZZJSafra, cZZJFilial)
		ZZJCLN()
		FWRestArea(aArea)
		Return Nil
	EndIf

	ZZJRUN(2)
	// A ZZK ja foi sincronizada por ZZJCONS() durante a gravacao.
	ZZJREF()

	cZZJCtx    := ""
	cZZJVaried  := ""
	cZZJCultur  := ""
	cZZJPacote  := ""
	cZZJSafra   := ""
	cZZJFilial  := ""
	cZZJCodEtp  := ""
	nZZJAreGer  := 0
	nZZJEtapa   := 1
	FWRestArea(aArea)

Return Nil

// Exclui todo o pacote do planejamento posicionado no browse.
User Function ZZJEXC()
	Local aArea := FWGetArea()
	Local cFil  := ""
	Local cVar  := ""
	Local cCul  := ""
	Local cSaf  := ""
	Local cEtp  := ""
	Local cPac  := ""
	Local cMsg  := ""

	If Select("ZZK") > 0 .And. !ZZK->(Eof())
		DbSelectArea("ZZK")
		cFil := AllTrim(cValToChar(ZZK->ZZK_FILIAL))
		cVar := AllTrim(cValToChar(ZZK->ZZK_VARIED))
		cCul := AllTrim(cValToChar(ZZK->ZZK_CULTUR))
		cSaf := AllTrim(cValToChar(ZZK->ZZK_SAFRA))
		cPac := AllTrim(cValToChar(ZZK->ZZK_PACOTE))
	ElseIf Select("ZZJ") > 0 .And. !ZZJ->(Eof())
		DbSelectArea("ZZJ")
		cFil := AllTrim(cValToChar(ZZJ->ZZJ_FILIAL))
		cVar := AllTrim(cValToChar(ZZJ->ZZJ_VARIED))
		cCul := AllTrim(cValToChar(ZZJ->ZZJ_CULTUR))
		cSaf := AllTrim(cValToChar(ZZJ->ZZJ_SAFRA))
		cEtp := AllTrim(cValToChar(ZZJ->ZZJ_ETAPA))
		cPac := ZZJPCE(cEtp)
	Else
		FWRestArea(aArea)
		Return Nil
	EndIf

	If Empty(cPac)
		MsgStop("Nao foi possivel identificar o pacote da etapa posicionada.", cTitulo)
		FWRestArea(aArea)
		Return Nil
	EndIf

	If !ZZJPACOK(cPac)
		MsgStop("Usuario sem permissao para utilizar este pacote.", cTitulo)
		FWRestArea(aArea)
		Return Nil
	EndIf
	If !ZZJPACCTXOK(cPac, cCul)
		MsgStop("Os pacotes de solo exigem a opcao Preparo de Solo.", cTitulo)
		FWRestArea(aArea)
		Return Nil
	EndIf

	If !ZZJAFIL(cFil)
		MsgStop("Usuario sem acesso a filial do planejamento selecionado.", cTitulo)
		FWRestArea(aArea)
		Return Nil
	EndIf

	If !ZZJPSOK(cSaf, cFil)
		FWRestArea(aArea)
		Return Nil
	EndIf

	cMsg := "Confirma a exclusao de todo o pacote " + ZZJPDS(cPac) + " da tecnologia " + cVar + " na safra " + cSaf + "?"
	If MsgYesNo(cMsg, cTitulo)
		ZZJDEP(cFil, cVar, cCul, cSaf, cPac)
		// ZZKDEL() ja removeu somente o resumo do pacote excluido.
		ZZJREF()
	EndIf

	FWRestArea(aArea)

Return Nil

// Gera uma planilha XLSX com cabecalho e grid do pacote posicionado.
User Function ZZJIMP()
	Local aArea  := FWGetArea()
	Local cFil   := ""
	Local cSaf   := ""

	If Select("ZZK") > 0 .And. !ZZK->(Eof())
		DbSelectArea("ZZK")
		cFil   := AllTrim(cValToChar(ZZK->ZZK_FILIAL))
		cSaf   := AllTrim(cValToChar(ZZK->ZZK_SAFRA))
	ElseIf Select("ZZJ") > 0 .And. !ZZJ->(Eof())
		DbSelectArea("ZZJ")
		cFil   := AllTrim(cValToChar(ZZJ->ZZJ_FILIAL))
		cSaf   := AllTrim(cValToChar(ZZJ->ZZJ_SAFRA))
	Else
		FWRestArea(aArea)
		Return Nil
	EndIf

	If Empty(cFil) .Or. Empty(cSaf)
		MsgStop("Nao foi possivel identificar a filial e a safra posicionadas.", cTitulo)
		FWRestArea(aArea)
		Return Nil
	EndIf

	If !ZZJAFIL(cFil)
		MsgStop("Usuario sem acesso a filial do planejamento selecionado.", cTitulo)
		FWRestArea(aArea)
		Return Nil
	EndIf

	ZZJXLS(cFil, cSaf)

	FWRestArea(aArea)

Return Nil

// Gera uma planilha XLSX consolidada da safra atual em todas as filiais.
User Function ZZJVGF()
	Local aArea := FWGetArea()
	Local cSaf  := ""

	If !ZZJUVGA()
		MsgStop("Usuario sem acesso a acao Volume Geral Final. Verifique os parametros MV_ZZJVGFG/MV_ZUPLSAF.", cTitulo)
		FWRestArea(aArea)
		Return Nil
	EndIf

	If Select("ZZK") > 0 .And. !ZZK->(Eof())
		DbSelectArea("ZZK")
		cSaf := AllTrim(cValToChar(ZZK->ZZK_SAFRA))
	ElseIf Select("ZZJ") > 0 .And. !ZZJ->(Eof())
		DbSelectArea("ZZJ")
		cSaf := AllTrim(cValToChar(ZZJ->ZZJ_SAFRA))
	EndIf

	If Empty(cSaf)
		MsgStop("Nao foi possivel identificar a safra posicionada.", cTitulo)
		FWRestArea(aArea)
		Return Nil
	EndIf

	ZZJXVG(cSaf)

	FWRestArea(aArea)
Return Nil

// Valida se o usuario corrente pode usar a acao Volume Geral Final.
Static Function ZZJUVGA()
	Local cGrpPar := ZZJGETMV("MV_ZZJVGFG", xFilial("ZZJ"))
	Local cUsrPar := ZZJGETMV("MV_ZUPLSAF", xFilial("ZZJ"))

	If !Empty(AllTrim(cGrpPar))
		Return ZZJUGRP(cGrpPar)
	EndIf

	If Empty(AllTrim(cUsrPar))
		Return .T.
	EndIf

Return ZZJUTOK(cUsrPar, Upper(AllTrim(cValToChar(__cUserID))))

// Limpa o contexto do planejamento aberto na inclusao ou alteracao.
Static Function ZZJCLN()
	cZZJCtx    := ""
	cZZJVaried := ""
	cZZJCultur := ""
	cZZJPacote := ""
	cZZJSafra  := ""
	cZZJFilial := ""
	cZZJCodEtp := ""
	nZZJAreGer := 0
	nZZJEtapa  := 1

Return Nil

// Valida se a safra pode receber manutencao. MV_ZZJFSAF informa a ultima
// safra fechada e MV_ZZJFGRP contem os grupos autorizados a excecao.
Static Function ZZJPSOK(cSaf, cFil)
	Local cSafFec := AllTrim(ZZJGETMV("MV_ZZJFSAF", cFil))
	Local cGrpPar := AllTrim(ZZJGETMV("MV_ZZJFGRP", cFil))
	Local nSaf    := ZZJSAFNO(cSaf)
	Local nSafFec := ZZJSAFNO(cSafFec)

	// Sem parametro de fechamento, ou com valor invalido, a manutencao segue
	// liberada para preservar o comportamento atual da rotina.
	If Empty(cSafFec) .Or. nSafFec <= 0 .Or. nSaf > nSafFec
		Return .T.
	EndIf

	If !Empty(cGrpPar) .And. ZZJUGRP(cGrpPar)
		Return .T.
	EndIf

	MsgStop("Planejamento da safra " + AllTrim(cValToChar(cSaf)) + ;
		" esta fechado para manutencao. Somente grupos autorizados no parametro MV_ZZJFGRP podem altera-lo.", cTitulo)

Return .F.

// Normaliza o codigo da safra para comparacao. Atende codigos como 11 e
// descricoes no formato 2025/2026.
Static Function ZZJSAFNO(cSaf)
	Local cNum := ""
	Local cVal := AllTrim(cValToChar(cSaf))
	Local nI   := 0
	Local cChr := ""

	For nI := 1 To Len(cVal)
		cChr := SubStr(cVal, nI, 1)
		If cChr >= "0" .And. cChr <= "9"
			cNum += cChr
		EndIf
	Next

Return Val(cNum)

// Gera o arquivo XLSX da filial e safra informadas.
Static Function ZZJXLS(cFil, cSaf)
	Local oXls    := Nil
	Local lRet    := .F.
	Local cBase   := "C:\Temp\ZZJ_" + DToS(Date()) + "_" + StrTran(Time(), ":", "")
	Local cRel    := cBase + ".rel"
	Local nRow    := 0
	Local aRows   := ZZJXDT(cFil, cSaf)
	Local nI      := 0
	Local cEtp    := ""
	Local cGrp    := ""
	Local cGrpAt  := ""
	Local cTecAt  := ""
	Local cPac    := ""
	Local cCultAt := ""
	Local nStCst  := 0
	Local nStTot  := 0
	Local lTop    := .F.

	If Len(aRows) == 0
		MsgStop("Nao ha dados para a filial e safra posicionadas.", cTitulo)
		Return .F.
	EndIf

	FErase(cRel)
	oXls := FwPrinterXlsx():New(.T.)
	lRet := oXls:Activate(cRel)
	If !lRet
		MsgStop("Nao foi possivel iniciar a geracao da planilha.", cTitulo)
		Return .F.
	EndIf

	For nI := 1 To Len(aRows)
		If cCultAt <> aRows[nI, 1]
			If !Empty(cCultAt)
				ZZJXFIM(oXls, @nRow, cEtp, nStCst, nStTot)
			EndIf

			cCultAt := aRows[nI, 1]
			nRow    := 0
			cEtp    := ""
			cGrpAt  := ""
			cTecAt  := ""
			cPac    := ""
			nStCst  := 0
			nStTot  := 0
			lTop    := .F.
			oXls:AddSheet(ZZJXSHN(ZZJCUD(cCultAt)))
		EndIf

		If !Empty(cTecAt) .And. cTecAt <> (aRows[nI, 1] + "|" + aRows[nI, 2])
			ZZJXFIM(oXls, @nRow, cEtp, nStCst, nStTot)
			cEtp   := ""
			cGrpAt := ""
			cPac   := ""
			nStCst := 0
			nStTot := 0
		EndIf
		cTecAt := aRows[nI, 1] + "|" + aRows[nI, 2]

		cGrp := aRows[nI, 1] + "|" + aRows[nI, 2] + "|" + aRows[nI, 5]
		If cGrpAt <> cGrp
			If !Empty(cEtp)
				nRow++
				ZZJXSUM(oXls, nRow, nStCst, nStTot)
				nStCst := 0
				nStTot := 0
			EndIf
			cGrpAt := cGrp
			cEtp := ""
			cPac := aRows[nI, 5]
			ZZJXTOP(oXls, @nRow, cFil, cSaf, aRows[nI], !lTop)
			lTop := .T.
		EndIf
		If cEtp <> aRows[nI, 6]
			If !Empty(cEtp)
				nRow++
				ZZJXSUM(oXls, nRow, nStCst, nStTot)
				nStCst := 0
				nStTot := 0
			EndIf
			cEtp := aRows[nI, 6]
			nRow++
			ZZJXBAR(oXls, nRow, ZZJEDS2(cEtp, cPac), "009C9A", "FFFFFF", 4)
			nRow++
			ZZJXHD(oXls, nRow)
		EndIf
		nRow++
		ZZJXLN(oXls, nRow, aRows[nI])
		nStCst += aRows[nI, 15]
		nStTot += aRows[nI, 16]
	Next

	ZZJXFIM(oXls, @nRow, cEtp, nStCst, nStTot)
	ZZJXRSM(oXls, aRows)
	ZZJXRCP(oXls, aRows)
	
	FWAlertSuccess("Planilha gerada em: " + cBase, cTitulo)

	oXls:toXlsx()
	oXls:DeActivate()
	ShellExecute("Open", "excel", cBase, "C:\", 1)

Return .T.

// Gera a planilha consolidada da safra em todas as filiais habilitadas.
Static Function ZZJXVG(cSaf)
	Local oXls  := Nil
	Local lRet  := .F.
	Local cBase := "C:\Temp\ZZJVGF_" + DToS(Date()) + "_" + StrTran(Time(), ":", "")
	Local cRel  := cBase + ".rel"
	Local aRows := ZZJXVGD(cSaf)

	If Len(aRows) == 0
		FWAlertError("Nao ha dados para a safra informada.", cTitulo)
		Return .F.
	EndIf

	FErase(cRel)
	oXls := FwPrinterXlsx():New(.T.)
	lRet := oXls:Activate(cRel)
	If !lRet
		FWAlertError("Nao foi possivel iniciar a geracao da planilha.", cTitulo)
		Return .F.
	EndIf

	ZZJXVGF(oXls, aRows, cSaf)

	oXls:toXlsx()
	oXls:DeActivate()
	ShellExecute("Open", "excel", cBase, "C:\", 1)
	FWAlertSuccess("Planilha gerada em: " + cBase, cTitulo)

Return .T.

// Finaliza a aba corrente com subtotal pendente e assinatura.
Static Function ZZJXFIM(oXls, nRow, cEtp, nStCst, nStTot)
	If !Empty(cEtp)
		nRow++
		ZZJXSUM(oXls, nRow, nStCst, nStTot)
	EndIf

	nRow += 4
	ZZJXPUT(oXls, nRow, 4, "________________________________________", "FFFFFF", "000000", .F., "", "C", .F.)
	nRow++
	ZZJXPUT(oXls, nRow, 4, "Gerente da Unidade", "FFFFFF", "000000", .T., "", "C", .F.)

Return Nil

// Normaliza o nome da aba do Excel.
Static Function ZZJXSHN(cNome)
	Local cRet := AllTrim(cValToChar(cNome))

	If Empty(cRet)
		cRet := "Cultura"
	EndIf

	cRet := StrTran(cRet, ":", " ")
	cRet := StrTran(cRet, "\", " ")
	cRet := StrTran(cRet, "/", " ")
	cRet := StrTran(cRet, "?", " ")
	cRet := StrTran(cRet, "*", " ")
	cRet := StrTran(cRet, "[", " ")
	cRet := StrTran(cRet, "]", " ")
	cRet := SubStr(AllTrim(cRet), 1, 31)

Return cRet

// Gera a aba Resumo consolidando custo por grupo pela area total da fazenda/tecnologia.
Static Function ZZJXRSM(oXls, aRows)
	Local aCult := {}
	Local aTec  := {}
	Local aSub  := {}
	Local aVal  := {}
	Local cCult := ""
	Local cTec  := ""
	Local cSub  := ""
	Local cKey  := ""
	Local nPos  := 0
	Local nI    := 0
	Local nJ    := 0
	Local nK    := 0
	Local nRow  := 0
	Local nCol  := 0
	Local nQtTec := 0
	Local nMaxCol := 2

	oXls:AddSheet(ZZJXSHN("Resumo"))

	For nI := 1 To Len(aRows)
		cCult := aRows[nI, 1]
		cTec  := AllTrim(aRows[nI, 2])
		cSub  := AllTrim(aRows[nI, 10])

		If Empty(cSub)
			cSub := "SEM SUB GRUPO"
		EndIf

		If AScan(aCult, {|xItem| xItem == cCult}) == 0
			AAdd(aCult, cCult)
		EndIf

		cKey := cCult + "|" + cTec
		nPos := AScan(aTec, {|aItem| aItem[1] == cKey})
		If nPos == 0
			AAdd(aTec, { cKey, cCult, cTec, aRows[nI, 3], 0 })
			nPos := Len(aTec)
		EndIf
		aTec[nPos, 5] += aRows[nI, 16]

		cKey := cCult + "|" + cSub
		If AScan(aSub, {|aItem| aItem[1] == cKey}) == 0
			AAdd(aSub, { cKey, cCult, cSub })
		EndIf

		cKey := cCult + "|" + cSub + "|" + cTec
		nPos := AScan(aVal, {|aItem| aItem[1] == cKey})
		If nPos == 0
			AAdd(aVal, { cKey, cCult, cSub, cTec, aRows[nI, 16] })
		Else
			aVal[nPos, 5] += aRows[nI, 16]
		EndIf
	Next

	For nI := 1 To Len(aCult)
		nQtTec := 0
		For nJ := 1 To Len(aTec)
			If aTec[nJ, 2] == aCult[nI]
				nQtTec++
			EndIf
		Next
		nMaxCol := Max(nMaxCol, nQtTec + 1)
	Next

	nRow++
	ZZJXBRN(oXls, nRow, "Resumo", "00525B", "FFFFFF", Min(4, nMaxCol), nMaxCol)

	For nI := 1 To Len(aCult)
		cCult := aCult[nI]
		nQtTec := 0
		For nJ := 1 To Len(aTec)
			If aTec[nJ, 2] == cCult
				nQtTec++
			EndIf
		Next
		nRow += 2
		ZZJXBRN(oXls, nRow, "", "FFC000", "000000", Min(2, nQtTec + 1), nQtTec + 1)
		ZZJXPUT(oXls, nRow, 1, "CULTURA:", "FFC000", "000000", .T., "", "R", .F.)
		ZZJXPUT(oXls, nRow, 2, Upper(ZZJCUD(cCult)), "FFC000", "000000", .T., "", "L", .F.)

		nRow++
		ZZJXPUT(oXls, nRow, 1, "TECNOLOGIA:", "FFC000", "000000", .T., "", "R", .F.)
		nCol := 2
		For nJ := 1 To Len(aTec)
			If aTec[nJ, 2] == cCult
				ZZJXPUT(oXls, nRow, nCol, Upper(aTec[nJ, 3]), "FFC000", "000000", .T., "", "C", .F.)
				nCol++
			EndIf
		Next

		nRow++
		ZZJXPUT(oXls, nRow, 1, "AREA GERAL:", "FFF2CC", "000000", .T., "", "R", .F.)
		nCol := 2
		For nJ := 1 To Len(aTec)
			If aTec[nJ, 2] == cCult
				ZZJXPUT(oXls, nRow, nCol, aTec[nJ, 4], "FFF2CC", "000000", .T., "#,##0.00", "C", .T.)
				nCol++
			EndIf
		Next

		nRow++
		ZZJXPUT(oXls, nRow, 1, "TIPO OPERACAO", "92D050", "000000", .T., "", "L", .F.)
		nCol := 2
		For nJ := 1 To Len(aTec)
			If aTec[nJ, 2] == cCult
				ZZJXPUT(oXls, nRow, nCol, "CUSTO/HA", "92D050", "000000", .T., "", "C", .F.)
				nCol++
			EndIf
		Next

		For nJ := 1 To Len(aSub)
			If aSub[nJ, 2] <> cCult
				Loop
			EndIf

			nRow++
			ZZJXPUT(oXls, nRow, 1, aSub[nJ, 3], "FFFFFF", "000000", .F., "", "L", .F.)
			nCol := 2
			For nK := 1 To Len(aTec)
				If aTec[nK, 2] == cCult
					cKey := cCult + "|" + aSub[nJ, 3] + "|" + aTec[nK, 3]
					nPos := AScan(aVal, {|aItem| aItem[1] == cKey})
					If nPos > 0
						ZZJXPUT(oXls, nRow, nCol, IIf(aTec[nK, 4] > 0, aVal[nPos, 5] / aTec[nK, 4], 0), "FFFFFF", "000000", .F., "$ #,##0.00", "R", .T.)
					Else
						ZZJXPUT(oXls, nRow, nCol, "-", "FFFFFF", "000000", .F., "", "C", .F.)
					EndIf
					nCol++
				EndIf
			Next
		Next

		nRow++
		ZZJXPUT(oXls, nRow, 1, "CUSTO/HA", "C6E0B4", "000000", .T., "", "L", .F.)
		nCol := 2
		For nJ := 1 To Len(aTec)
			If aTec[nJ, 2] == cCult
				ZZJXPUT(oXls, nRow, nCol, IIf(aTec[nJ, 4] > 0, aTec[nJ, 5] / aTec[nJ, 4], 0), "C6E0B4", "000000", .T., "$ #,##0.00", "R", .T.)
				nCol++
			EndIf
		Next

	Next

Return Nil

// Gera a aba Resumo de compra consolidando volume por produto.
Static Function ZZJXRCP(oXls, aRows)
	Local aGrp   := {}
	Local cKey   := ""
	Local nPos   := 0
	Local nI     := 0
	Local nRow   := 0
	Local cCult  := ""

	oXls:AddSheet(ZZJXSHN("Resumo de compra"))
	nRow++
	ZZJXBRN(oXls, nRow, "Resumo de compra", "00525B", "FFFFFF", 3, 5)
	nRow++
	ZZJXPUT(oXls, nRow, 1, "Cultura", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 2, "Cod. Compon.", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 3, "Componente", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 4, "Sub Grupo", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 5, "Volume", "92D050", "000000", .T., "", "C", .F.)

	For nI := 1 To Len(aRows)
		cKey := aRows[nI, 1] + "|" + aRows[nI, 8] + "|" + aRows[nI, 10]
		nPos := AScan(aGrp, {|aItem| aItem[1] == cKey})
		If nPos == 0
			AAdd(aGrp, { cKey, aRows[nI, 1], aRows[nI, 8], aRows[nI, 9], aRows[nI, 10], aRows[nI, 14] })
		Else
			aGrp[nPos, 6] += aRows[nI, 14]
		EndIf
	Next

	For nI := 1 To Len(aGrp)
		nRow++
		cCult := ZZJCUD(aGrp[nI, 2])
		ZZJXPUT(oXls, nRow, 1, cCult, "FFFFFF", "000000", .F., "", "L", .F.)
		ZZJXPUT(oXls, nRow, 2, aGrp[nI, 3], "FFFFFF", "000000", .F., "", "C", .F.)
		ZZJXPUT(oXls, nRow, 3, aGrp[nI, 4], "FFFFFF", "000000", .F., "", "L", .F.)
		ZZJXPUT(oXls, nRow, 4, aGrp[nI, 5], "FFFFFF", "000000", .F., "", "L", .F.)
		ZZJXPUT(oXls, nRow, 5, aGrp[nI, 6], "FFFFFF", "000000", .F., "#,##0.00", "R", .T.)
	Next

Return Nil
// Consulta os itens do pacote para impressao.
Static Function ZZJXDT(cFil, cSaf)
	Local aRet   := {}
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local cPac   := ""

	cQuery := " SELECT ZZJ_CULTUR, ZZJ_VARIED, ZZJ_AREGER, ZZJ_CUSTO, ZZJ_ETAPA, ZZJ_ITEM, ZZJ_CDPROD, ZZJ_DEPROD, ZZJ_SUBGRP, ZZJ_DOSEHA, ZZJ_DAE, ZZJ_AREA, ZZJ_VOLUME, ZZJ_CSTDHA, ZZJ_CSTTOT "
	cQuery += " FROM " + RetSqlName("ZZJ")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND ZZJ_FILIAL = '" + ZZJSQL(cFil) + "' "
	cQuery += " AND ZZJ_SAFRA = '" + ZZJSQL(cSaf) + "' "
	cQuery += " ORDER BY ZZJ_CULTUR, ZZJ_VARIED, ZZJ_ETAPA, ZZJ_ITEM "

	MpSysOpenQuery(cQuery, cAlias)
	While !(cAlias)->(Eof())
		cPac := ZZJPCE(AllTrim((cAlias)->ZZJ_ETAPA))
		AAdd(aRet, { ;
			AllTrim((cAlias)->ZZJ_CULTUR), ;
			AllTrim((cAlias)->ZZJ_VARIED), ;
			(cAlias)->ZZJ_AREGER, ;
			(cAlias)->ZZJ_CUSTO, ;
			cPac, ;
			AllTrim((cAlias)->ZZJ_ETAPA), ;
			(cAlias)->ZZJ_ITEM, ;
			AllTrim((cAlias)->ZZJ_CDPROD), ;
			AllTrim((cAlias)->ZZJ_DEPROD), ;
			AllTrim((cAlias)->ZZJ_SUBGRP), ;
			(cAlias)->ZZJ_DOSEHA, ;
			(cAlias)->ZZJ_DAE, ;
			(cAlias)->ZZJ_AREA, ;
			(cAlias)->ZZJ_VOLUME, ;
			(cAlias)->ZZJ_CSTDHA, ;
			(cAlias)->ZZJ_CSTTOT })
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

	ASort(aRet, , , {|aX, aY| ;
		IIf(aX[1] <> aY[1], aX[1] < aY[1], ;
		IIf(aX[2] <> aY[2], aX[2] < aY[2], ;
		IIf(ZZJETO(aX[6]) <> ZZJETO(aY[6]), ZZJETO(aX[6]) < ZZJETO(aY[6]), aX[7] < aY[7]))) })

	ZZJXCHA(@aRet)

Return aRet

// Carrega e consolida os dados da safra em todas as filiais liberadas.
Static Function ZZJXVGD(cSaf)
	Local aRet   := {}
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local cKey   := ""
	Local nPos   := 0

	cQuery := " SELECT ZZJ_FILIAL, ZZJ_CULTUR, ZZJ_CDPROD, ZZJ_DEPROD, ZZJ_SUBGRP, ZZJ_VOLUME "
	cQuery += " FROM " + RetSqlName("ZZJ")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND ZZJ_SAFRA = '" + ZZJSQL(cSaf) + "' "
	cQuery += " ORDER BY ZZJ_CULTUR, ZZJ_FILIAL, ZZJ_CDPROD, ZZJ_SUBGRP "

	MpSysOpenQuery(cQuery, cAlias)
	While !(cAlias)->(Eof())
		If ZZJFACS(AllTrim((cAlias)->ZZJ_FILIAL)) .And. ZZJFPLS(AllTrim((cAlias)->ZZJ_FILIAL))
			cKey := AllTrim((cAlias)->ZZJ_FILIAL) + "|" + AllTrim((cAlias)->ZZJ_CULTUR) + "|" + ;
				AllTrim((cAlias)->ZZJ_CDPROD) + "|" + AllTrim((cAlias)->ZZJ_SUBGRP)
			nPos := AScan(aRet, {|aItem| aItem[1] == cKey})
			If nPos == 0
				AAdd(aRet, { ;
					cKey, ;
					AllTrim((cAlias)->ZZJ_FILIAL), ;
					AllTrim((cAlias)->ZZJ_CULTUR), ;
					AllTrim((cAlias)->ZZJ_CDPROD), ;
					AllTrim((cAlias)->ZZJ_DEPROD), ;
					AllTrim((cAlias)->ZZJ_SUBGRP), ;
					(cAlias)->ZZJ_VOLUME })
			Else
				aRet[nPos, 7] += (cAlias)->ZZJ_VOLUME
			EndIf
		EndIf
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

Return aRet

// Gera a aba Volume por Fazenda.
Static Function ZZJXVGF(oXls, aRows, cSaf)
	Local aCache := {}
	Local nI     := 0
	Local nRow   := 0

	oXls:AddSheet(ZZJXSHN("Volume por Fazenda"))
	nRow++
	ZZJXBRN(oXls, nRow, "Volume por Fazenda", "00525B", "FFFFFF", 4, 8)
	nRow++
	ZZJXPUT(oXls, nRow, 1, "Safra", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 2, "Cultura", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 3, "Filial", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 4, "Fazenda (UP)", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 5, "Cod. Compon.", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 6, "Componente", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 7, "Sub Grupo", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 8, "Volume Planejado", "92D050", "000000", .T., "", "C", .F.)

	For nI := 1 To Len(aRows)
		nRow++
		ZZJXPUT(oXls, nRow, 1, cSaf, "FFFFFF", "000000", .F., "", "C", .F.)
		ZZJXPUT(oXls, nRow, 2, ZZJCUD(aRows[nI, 3]), "FFFFFF", "000000", .F., "", "L", .F.)
		ZZJXPUT(oXls, nRow, 3, aRows[nI, 2], "FFFFFF", "000000", .F., "", "C", .F.)
		ZZJXPUT(oXls, nRow, 4, ZZJVFIL(aRows[nI, 2], aCache), "FFFFFF", "000000", .F., "", "L", .F.)
		ZZJXPUT(oXls, nRow, 5, aRows[nI, 4], "FFFFFF", "000000", .F., "", "C", .F.)
		ZZJXPUT(oXls, nRow, 6, aRows[nI, 5], "FFFFFF", "000000", .F., "", "L", .F.)
		ZZJXPUT(oXls, nRow, 7, aRows[nI, 6], "FFFFFF", "000000", .F., "", "L", .F.)
		ZZJXPUT(oXls, nRow, 8, aRows[nI, 7], "FFFFFF", "000000", .F., "#,##0.00", "R", .T.)
	Next

Return Nil

// Resolve a descricao da filial com cache simples para evitar consultas repetidas.
Static Function ZZJVFIL(cFil, aCache)
	Local cRet   := AllTrim(cFil)
	Local nPos   := AScan(aCache, {|aItem| aItem[1] == cFil})
	Local cAlias := ""
	Local cQuery := ""

	If nPos > 0
		Return aCache[nPos, 2]
	EndIf

	cAlias := GetNextAlias()
	cQuery := " SELECT TOP 1 M0_FILIAL "
	cQuery += " FROM SYS_COMPANY "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND M0_CODFIL = '" + ZZJSQL(cFil) + "' "

	MpSysOpenQuery(cQuery, cAlias)
	If !(cAlias)->(Eof())
		cRet := AllTrim((cAlias)->M0_FILIAL)
	EndIf
	(cAlias)->(DbCloseArea())

	AAdd(aCache, { cFil, cRet })
Return cRet

// Calcula o custo por hectare exibido no cabecalho amarelo da planilha.
Static Function ZZJXCHA(aRows)
	Local nI     := 0
	Local nIni   := 1
	Local cKeyAt := ""
	Local cKeyNx := ""
	Local nTot   := 0
	Local nJ     := 0

	If Len(aRows) == 0
		Return Nil
	EndIf

	cKeyAt := aRows[1, 1] + "|" + aRows[1, 2] + "|" + aRows[1, 5]
	For nI := 1 To Len(aRows)
		cKeyNx := aRows[nI, 1] + "|" + aRows[nI, 2] + "|" + aRows[nI, 5]
		If cKeyNx <> cKeyAt
			For nJ := nIni To nI - 1
				aRows[nJ, 4] := nTot
			Next
			nIni   := nI
			cKeyAt := cKeyNx
			nTot   := 0
		EndIf
		nTot += aRows[nI, 15]
	Next

	For nJ := nIni To Len(aRows)
		aRows[nJ, 4] := nTot
	Next

Return Nil
// Escreve o cabecalho visual do planejamento no XLSX.
Static Function ZZJXTOP(oXls, nRow, cFil, cSaf, aLin, lCab)
	If lCab
		nRow++
		ZZJXBAR(oXls, nRow, "Planejamento Safra", "00525B", "FFFFFF", 4)
		nRow++
		ZZJXBAR(oXls, nRow, "", "009C9A", "FFFFFF", 1)
		ZZJXPUT(oXls, nRow, 1, "FILIAL:", "009C9A", "FFFFFF", .T., "", "R", .F.)
		ZZJXPUT(oXls, nRow, 2, cFil, "009C9A", "FFFFFF", .T., "", "C", .F.)
		ZZJXPUT(oXls, nRow, 6, "ANO SAFRA:", "009C9A", "FFFFFF", .T., "", "R", .F.)
		ZZJXPUT(oXls, nRow, 7, cSaf, "009C9A", "FFFFFF", .T., "", "L", .F.)
		ZZJXPUT(oXls, nRow, 9, "CULTURA:", "009C9A", "FFFFFF", .T., "", "R", .F.)
		ZZJXPUT(oXls, nRow, 10, ZZJCUD(aLin[1]), "009C9A", "FFFFFF", .T., "", "L", .F.)
	EndIf
	nRow++
	ZZJXBAR(oXls, nRow, "", "FFC000", "000000", 1)
	ZZJXPUT(oXls, nRow, 1, "TECNOLOGIA:", "FFC000", "000000", .T., "", "R", .F.)
	ZZJXPUT(oXls, nRow, 2, aLin[2], "FFC000", "000000", .T., "", "L", .F.)
	ZZJXPUT(oXls, nRow, 3, "PACOTE:", "FFC000", "000000", .T., "", "R", .F.)
	ZZJXPUT(oXls, nRow, 4, ZZJPDS(aLin[5]), "FFC000", "000000", .T., "", "L", .F.)
	ZZJXPUT(oXls, nRow, 6, "AREA GERAL (HA)", "FFC000", "000000", .T., "", "R", .F.)
	ZZJXPUT(oXls, nRow, 7, aLin[3], "FFC000", "000000", .T., "#,##0.00", "L", .T.)
	ZZJXPUT(oXls, nRow, 9, "CUSTO ($)", "FFC000", "000000", .T., "", "R", .F.)
	ZZJXPUT(oXls, nRow, 10, aLin[4], "FFC000", "000000", .T., "$ #,##0.00", "L", .T.)
Return Nil
// Escreve o cabecalho da grid no XLSX.
Static Function ZZJXHD(oXls, nRow)
	ZZJXPUT(oXls, nRow, 1, "N. Aplicacao", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 2, "Cod. Compon.", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 3, "Componente", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 4, "Sub Grupo", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 5, "Dose / HA", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 6, "DAE", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 7, "Area", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 8, "Volume", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 9, "Custo / HA", "92D050", "000000", .T., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 10, "Custo Total", "92D050", "000000", .T., "", "C", .F.)
Return Nil

// Escreve uma linha da grid no XLSX.
Static Function ZZJXLN(oXls, nRow, aLin)
	ZZJXPUT(oXls, nRow, 1, aLin[7], "FFFFFF", "000000", .F., "#,##0", "C", .T.)
	ZZJXPUT(oXls, nRow, 2, aLin[8], "FFFFFF", "000000", .F., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 3, aLin[9], "FFFFFF", "000000", .F., "", "L", .F.)
	ZZJXPUT(oXls, nRow, 4, aLin[10], "FFFFFF", "000000", .F., "", "L", .F.)
	ZZJXPUT(oXls, nRow, 5, aLin[11], "FFFFFF", "000000", .F., "#,##0.0000", "R", .T.)
	ZZJXPUT(oXls, nRow, 6, aLin[12], "FFFFFF", "000000", .F., "#,##0", "C", .T.)
	ZZJXPUT(oXls, nRow, 7, aLin[13], "FFFFFF", "000000", .F., "#,##0.00", "R", .T.)
	ZZJXPUT(oXls, nRow, 8, aLin[14], "FFFFFF", "000000", .F., "#,##0.00", "R", .T.)
	ZZJXPUT(oXls, nRow, 9, aLin[15], "FFFFFF", "000000", .F., "$ #,##0.00", "R", .T.)
	ZZJXPUT(oXls, nRow, 10, aLin[16], "FFFFFF", "000000", .F., "$ #,##0.00", "R", .T.)
Return Nil

// Escreve a linha de subtotal da etapa no XLSX.
Static Function ZZJXSUM(oXls, nRow, nCstHa, nCstTot)
	ZZJXPUT(oXls, nRow, 1, "SOMA", "FFFFFF", "000000", .F., "", "R", .F.)
	ZZJXPUT(oXls, nRow, 2, "", "FFFFFF", "000000", .F., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 3, "", "FFFFFF", "000000", .F., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 4, "", "FFFFFF", "000000", .F., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 5, "", "FFFFFF", "000000", .F., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 6, "", "FFFFFF", "000000", .F., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 7, "", "FFFFFF", "000000", .F., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 8, "", "FFFFFF", "000000", .F., "", "C", .F.)
	ZZJXPUT(oXls, nRow, 9, nCstHa, "FFFFFF", "000000", .T., "$ #,##0.00", "R", .T.)
	ZZJXPUT(oXls, nRow, 10, nCstTot, "FFFFFF", "000000", .T., "$ #,##0.00", "R", .T.)
Return Nil

// Escreve uma faixa colorida de A ate J no XLSX.
Static Function ZZJXBAR(oXls, nRow, cText, cBg, cFg, nCol)
	Local nI := 0

	For nI := 1 To 10
		ZZJXPUT(oXls, nRow, nI, IIf(nI == nCol, cText, ""), cBg, cFg, .T., "", "C", .F.)
	Next
Return Nil

// Escreve uma faixa colorida preenchendo a quantidade informada de colunas.
Static Function ZZJXBRN(oXls, nRow, cText, cBg, cFg, nCol, nTotCol)
	Local nI := 0

	For nI := 1 To nTotCol
		ZZJXPUT(oXls, nRow, nI, IIf(nI == nCol, cText, ""), cBg, cFg, .T., "", "C", .F.)
	Next
Return Nil

// Aplica formato e escreve uma celula no XLSX.
Static Function ZZJXPUT(oXls, nRow, nCol, xVal, cBg, cFg, lBold, cFmt, cAln, lNum)
	ZZJXFMT(oXls, cBg, cFg, lBold, cFmt, cAln)
	If lNum
		oXls:SetNumber(nRow, nCol, xVal)
	Else
		oXls:SetText(nRow, nCol, cValToChar(xVal))
	EndIf
Return Nil

// Define fonte, alinhamento, cor e formato da proxima celula escrita.
Static Function ZZJXFMT(oXls, cBg, cFg, lBold, cFmt, cAln)
	Local cFont := FwPrinterFont():Calibri()
	Local oHor  := FwXlsxCellAlignment():Horizontal()
	Local oVer  := FwXlsxCellAlignment():Vertical()
	Local cHor  := oHor:Left()

	Do Case
	Case cAln == "C"
		cHor := oHor:Center()
	Case cAln == "R"
		cHor := oHor:Right()
	Otherwise
		cHor := oHor:Left()
	EndCase

	oXls:SetFont(cFont, IIf(lBold, 11, 10), .F., lBold, .F.)
	oXls:SetCellsFormat(cHor, oVer:Center(), .F., 0, cFg, cBg, cFmt)
Return Nil

// Extrai o codigo puro da etapa, desconsiderando a descricao.
Static Function ZZJETC(cItem)
	Local cRet := Upper(AllTrim(cValToChar(cItem)))
	Local nPos := At("=", cRet)

	If nPos > 0
		cRet := Left(cRet, nPos - 1)
	EndIf

Return AllTrim(cRet)

// Retorna o numero sequencial da etapa dentro do pacote.
Static Function ZZJETN(cEtapa, cPac)
	Local cCod := ZZJETC(cEtapa)
	Local cSuf := ""
	Local nRet := 1

	If Empty(cPac)
		cPac := ZZJPCE(cCod)
	EndIf

	If Empty(cCod) .Or. Empty(cPac) .Or. IsDigit(Left(cCod, 1))
		Return 1
	EndIf

	cSuf := Upper(AllTrim(SubStr(cCod, 2)))
	nRet := Val(cSuf)
	If nRet == 0 .And. !Empty(cSuf)
		nRet := Asc(Left(cSuf, 1)) - 55
	EndIf

	Return Max(1, nRet)

// Retorna a ordem geral da etapa considerando o pacote e a sequencia.
Static Function ZZJETO(cEtapa)
	Local cPac := ZZJPCE(cEtapa)
	Local nOrd := 0

	Do Case
	Case cPac == "D"
		nOrd := 100
	Case cPac == "B"
		nOrd := 200
	Case cPac == "T"
		nOrd := 300
	Case cPac == "E"
		nOrd := 400
	Case cPac == "P"
		nOrd := 500
	Case cPac == "C"
		nOrd := 600
	Case cPac == "F"
		nOrd := 700
	Case cPac == "I"
		nOrd := 800
	Case cPac == "R"
		nOrd := 900
	Case cPac == "M"
		nOrd := 1000
	Case cPac == "Q"
		nOrd := 1100
	Case cPac == "L"
		nOrd := 1200
	EndCase

Return nOrd + ZZJETN(cEtapa, cPac)

// Retorna a lista SQL da etapa atual apenas no codigo novo.
Static Function ZZJES1(cEtapa)
	Local cNew := ZZJETC(cEtapa)
	Local cRet := "'" + ZZJSQL(cNew) + "'"

Return cRet

// Retorna a descricao da etapa para um pacote especifico.
Static Function ZZJEDS2(cEtapa, cPac)
	Local aEtapa := ZZJETA(cPac)
	Local nPos   := AScan(aEtapa, {|cItem| ZZJETN(ZZJETC(cItem), cPac) == ZZJETN(cEtapa, cPac)})
	Local cRet   := cEtapa
	Local nEq    := 0

	If nPos > 0
		cRet := aEtapa[nPos]
		nEq := At("=", cRet)
		If nEq > 0
			cRet := SubStr(cRet, nEq + 1)
		EndIf
	EndIf

Return AllTrim(cRet)

// Retorna as etapas conforme o pacote selecionado.
Static Function ZZJETA(cCult)
	Local cCode := Upper(AllTrim(cValToChar(cCult)))
	Local aRet  := {}
	Do Case
	Case cCode == "D"
		AAdd(aRet, "D1=1 DESSECACAO PRE PLANTIO")
		AAdd(aRet, "D2=2 DESSECACAO PRE PLANTIO")
		AAdd(aRet, "D3=3 DESSECACAO PRE PLANTIO")
	Case cCode == "B"
		AAdd(aRet, "B1=1 ADUBACAO DE BASE")
		AAdd(aRet, "B2=2 ADUBACAO DE BASE")
	Case cCode == "T"
		AAdd(aRet, "T1=1 TRATAMENTO DE SEMENTE")
	Case cCode == "E"
		AAdd(aRet, "E1=1 PRE EMERGENTE")
		AAdd(aRet, "E2=2 PRE EMERGENTE")
	Case cCode == "P"
		AAdd(aRet, "P1=1 POS EMERGENTE")
		AAdd(aRet, "P2=2 POS EMERGENTE")
		AAdd(aRet, "P3=3 POS EMERGENTE")
		AAdd(aRet, "P4=4 POS EMERGENTE")
		AAdd(aRet, "P5=5 POS EMERGENTE")
		If Empty(cZZJCultur) .Or. cZZJCultur == "A"
			AAdd(aRet, "P6=6 POS EMERGENTE")
			AAdd(aRet, "P7=7 POS EMERGENTE")
		EndIf
	Case cCode == "C"
		AAdd(aRet, "C1=1 ADUBACAO DE COBERTURA")
		AAdd(aRet, "C2=2 ADUBACAO DE COBERTURA")
	Case cCode == "F"
		AAdd(aRet, "F1=1 ADUBO FOLIAR")
		AAdd(aRet, "F2=2 ADUBO FOLIAR")
		AAdd(aRet, "F3=3 ADUBO FOLIAR")
		AAdd(aRet, "F4=4 ADUBO FOLIAR")
	Case cCode == "I"
		AAdd(aRet, "I1=1 FUNGICIDA/INSETICIDA")
		AAdd(aRet, "I2=2 FUNGICIDA/INSETICIDA")
		AAdd(aRet, "I3=3 FUNGICIDA/INSETICIDA")
		AAdd(aRet, "I4=4 FUNGICIDA/INSETICIDA")
		AAdd(aRet, "I5=5 FUNGICIDA/INSETICIDA")
		AAdd(aRet, "I6=6 FUNGICIDA/INSETICIDA")
		AAdd(aRet, "I7=7 FUNGICIDA/INSETICIDA")
		AAdd(aRet, "I8=8 FUNGICIDA/INSETICIDA")
		AAdd(aRet, "I9=9 FUNGICIDA/INSETICIDA")
		AAdd(aRet, "IA=10 FUNGICIDA/INSETICIDA")
		AAdd(aRet, "IB=11 FUNGICIDA/INSETICIDA")
		AAdd(aRet, "IC=12 FUNGICIDA/INSETICIDA")
	Case cCode == "R"
		AAdd(aRet, "R1=1 REGULADOR DE CRESCIMENTO")
		AAdd(aRet, "R2=2 REGULADOR DE CRESCIMENTO")
		AAdd(aRet, "R3=3 REGULADOR DE CRESCIMENTO")
		AAdd(aRet, "R4=4 REGULADOR DE CRESCIMENTO")
	Case cCode == "M"
		AAdd(aRet, "M1=1 MATURADOR")
		AAdd(aRet, "M2=2 MATURADOR")
	Case cCode == "Q"
		AAdd(aRet, "Q1=1 DESTRUICAO DE SOQUEIRA")
		AAdd(aRet, "Q2=2 DESTRUICAO DE SOQUEIRA")
	Case cCode == "L"
		AAdd(aRet, "L1=1 DESFOLHA")
	Case cCode == "S"
		AAdd(aRet, "S1=1 CORRETIVOS DE SOLO")
		AAdd(aRet, "S2=2 CORRETIVOS DE SOLO")
		AAdd(aRet, "S3=3 CORRETIVOS DE SOLO")
		AAdd(aRet, "S4=4 CORRETIVOS DE SOLO")
		AAdd(aRet, "S5=5 CORRETIVOS DE SOLO")
	Case cCode == "A"
		AAdd(aRet, "A1=1 ADUBACAO DE CORRECAO")
		AAdd(aRet, "A2=2 ADUBACAO DE CORRECAO")
		AAdd(aRet, "A3=3 ADUBACAO DE CORRECAO")
		AAdd(aRet, "A4=4 ADUBACAO DE CORRECAO")
		AAdd(aRet, "A5=5 ADUBACAO DE CORRECAO")
	Otherwise
		aRet := ZZJALG()
	EndCase
Return aRet

// Retorna o pacote correspondente ao codigo da etapa.
Static Function ZZJPCE(cEtapa)
	Local cCod := ZZJETC(cEtapa)

	If Empty(cCod)
		Return ""
	EndIf

	If !IsDigit(Left(cCod, 1))
		Return Left(cCod, 1)
	EndIf

Return ""

// Retorna as etapas de algodao para o combo.
Static Function ZZJALG()
	Local aRet := {}
	AAdd(aRet, "D1=1 DESSECACAO PRE PLANTIO")
	AAdd(aRet, "D2=2 DESSECACAO PRE PLANTIO")
	AAdd(aRet, "D3=3 DESSECACAO PRE PLANTIO")
	AAdd(aRet, "B1=1 ADUBACAO DE BASE")
	AAdd(aRet, "B2=2 ADUBACAO DE BASE")
	AAdd(aRet, "T1=1 TRATAMENTO DE SEMENTE")
	AAdd(aRet, "E1=1 PRE EMERGENTE")
	AAdd(aRet, "E2=2 PRE EMERGENTE")
	AAdd(aRet, "P1=1 POS EMERGENTE")
	AAdd(aRet, "P2=2 POS EMERGENTE")
	AAdd(aRet, "P3=3 POS EMERGENTE")
	AAdd(aRet, "P4=4 POS EMERGENTE")
	AAdd(aRet, "P5=5 POS EMERGENTE")
	AAdd(aRet, "P6=6 POS EMERGENTE")
	AAdd(aRet, "P7=7 POS EMERGENTE")
	AAdd(aRet, "C1=1 ADUBACAO DE COBERTURA")
	AAdd(aRet, "C2=2 ADUBACAO DE COBERTURA")
	AAdd(aRet, "F1=1 ADUBO FOLIAR")
	AAdd(aRet, "F2=2 ADUBO FOLIAR")
	AAdd(aRet, "F3=3 ADUBO FOLIAR")
	AAdd(aRet, "F4=4 ADUBO FOLIAR")
	AAdd(aRet, "I1=1 FUNGICIDA/INSETICIDA")
	AAdd(aRet, "I2=2 FUNGICIDA/INSETICIDA")
	AAdd(aRet, "I3=3 FUNGICIDA/INSETICIDA")
	AAdd(aRet, "I4=4 FUNGICIDA/INSETICIDA")
	AAdd(aRet, "I5=5 FUNGICIDA/INSETICIDA")
	AAdd(aRet, "I6=6 FUNGICIDA/INSETICIDA")
	AAdd(aRet, "I7=7 FUNGICIDA/INSETICIDA")
	AAdd(aRet, "I8=8 FUNGICIDA/INSETICIDA")
	AAdd(aRet, "I9=9 FUNGICIDA/INSETICIDA")
	AAdd(aRet, "IA=10 FUNGICIDA/INSETICIDA")
	AAdd(aRet, "IB=11 FUNGICIDA/INSETICIDA")
	AAdd(aRet, "IC=12 FUNGICIDA/INSETICIDA")
	AAdd(aRet, "R1=1 REGULADOR DE CRESCIMENTO")
	AAdd(aRet, "R2=2 REGULADOR DE CRESCIMENTO")
	AAdd(aRet, "R3=3 REGULADOR DE CRESCIMENTO")
	AAdd(aRet, "R4=4 REGULADOR DE CRESCIMENTO")
	AAdd(aRet, "M1=1 MATURADOR")
	AAdd(aRet, "M2=2 MATURADOR")
	AAdd(aRet, "Q1=1 DESTRUICAO DE SOQUEIRA")
	AAdd(aRet, "Q2=2 DESTRUICAO DE SOQUEIRA")
	AAdd(aRet, "L1=1 DESFOLHA")
	AAdd(aRet, "S1=1 CORRETIVOS DE SOLO")
	AAdd(aRet, "S2=2 CORRETIVOS DE SOLO")
	AAdd(aRet, "S3=3 CORRETIVOS DE SOLO")
	AAdd(aRet, "S4=4 CORRETIVOS DE SOLO")
	AAdd(aRet, "S5=5 CORRETIVOS DE SOLO")
	AAdd(aRet, "A1=1 ADUBACAO DE CORRECAO")
	AAdd(aRet, "A2=2 ADUBACAO DE CORRECAO")
	AAdd(aRet, "A3=3 ADUBACAO DE CORRECAO")
	AAdd(aRet, "A4=4 ADUBACAO DE CORRECAO")
	AAdd(aRet, "A5=5 ADUBACAO DE CORRECAO")
Return aRet

// Retorna o codigo da etapa atual.
Static Function ZZJCET()
	Local aEtapa := ZZJETA(cZZJPacote)
	Local cRet   := "D1"

	If Len(aEtapa) > 0
		nZZJEtapa := Min(Max(nZZJEtapa, 1), Len(aEtapa))
		cRet := ZZJETC(aEtapa[nZZJEtapa])
	EndIf

Return cRet

// Retorna a descricao da etapa atual.
Static Function ZZJEDS(cEtapa)
	Local aEtapa := ZZJETA(cZZJPacote)
	Local nPos   := AScan(aEtapa, {|cItem| ZZJETN(ZZJETC(cItem), cZZJPacote) == ZZJETN(cEtapa, cZZJPacote)})
	Local cRet   := cEtapa
	Local nEq    := 0

	If nPos > 0
		cRet := aEtapa[nPos]
		nEq := At("=", cRet)
		If nEq > 0
			cRet := SubStr(cRet, nEq + 1)
		EndIf
	EndIf

Return AllTrim(cRet)

// Monta o detalhe do titulo da etapa ativa para a grid.
Static Function ZZJTIT()
	Local cVar := AllTrim(cZZJVaried)
	Local cCul := ZZJCUD(cZZJCultur)
	Local cPac := ZZJPDS(cZZJPacote)
	Local cSaf := AllTrim(cZZJSafra)
	Local cTit := ""

	If Empty(cCul)
		cCul := AllTrim(cZZJCultur)
	EndIf

	If !Empty(cVar)
		cTit += "Tecnologia: " + cVar
	EndIf

	If !Empty(cCul)
		cTit += IIf(Empty(cTit), "", " | ") + "Cultura: " + cCul
	EndIf

	If !Empty(cPac)
		cTit += IIf(Empty(cTit), "", " | ") + "Pacote: " + cPac
	EndIf

	If !Empty(cSaf)
		cTit += IIf(Empty(cTit), "", " | ") + "Safra: " + cSaf
	EndIf

Return cTit

// Retorna a descricao do pacote pelo codigo.
Static Function ZZJPDS(cPacote)
	Local aPac := ZZJPAC()
	Local nPos := AScan(aPac, {|aItem| aItem[1] == cPacote})

	If nPos > 0
		Return aPac[nPos, 2]
	EndIf

Return AllTrim(cPacote)

// Retorna as filiais que podem ser usadas no planejamento. Esta mesma lista
// alimenta o seletor padrao do FWMBrowse e a selecao customizada legada.
Static Function ZZJFILS()
	Local aRet     := {}
	Local cAlias   := GetNextAlias()
	Local cQuery   := ""
	Local cFilAtu  := ""

	cQuery := " SELECT M0_CODFIL "
	cQuery += " FROM SYS_COMPANY "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND M0_CODIGO = '" + ZZJSQL(cEmpAnt) + "' "
	cQuery += " ORDER BY M0_CODFIL "

	MpSysOpenQuery(cQuery, cAlias)
	While !(cAlias)->(Eof())
		cFilAtu := AllTrim((cAlias)->M0_CODFIL)
		If ZZJAFIL(cFilAtu)
			AAdd(aRet, cFilAtu)
		EndIf
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

Return aRet

// Retorna os codigos e descricoes das filiais autorizadas para exibir ao usuario.
Static Function ZZJFILMSG()
	Local cAlias  := GetNextAlias()
	Local cQuery  := ""
	Local cRet    := ""
	Local cFilAtu := ""
	Local cDesc   := ""

	cQuery := " SELECT M0_CODFIL, M0_FILIAL "
	cQuery += " FROM SYS_COMPANY "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND M0_CODIGO = '" + ZZJSQL(cEmpAnt) + "' "
	cQuery += " ORDER BY M0_CODFIL "

	MpSysOpenQuery(cQuery, cAlias)
	While !(cAlias)->(Eof())
		cFilAtu := AllTrim((cAlias)->M0_CODFIL)
		cDesc   := AllTrim((cAlias)->M0_FILIAL)
		If ZZJAFIL(cFilAtu)
			If !Empty(cRet)
				cRet += CRLF
			EndIf
			cRet += cFilAtu + " - " + cDesc
		EndIf
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

	If Empty(cRet)
		cRet := "Nenhuma filial liberada."
	EndIf

Return cRet

// Solicita a filial que sera gravada no planejamento.
Static Function ZZJSELF()
	Local cAlias := GetNextAlias()
	Local oMark  := Nil
	Local aArea  := FWGetArea()
	Local aSeek  := {}

	AAdd(aSeek, { "Codigo", ;
		{{ "", "C", 12, 0, "ZZF_COD", "@!" }}, 1 } )
	AAdd(aSeek, { "Descricao", ;
		{{ "", "C", 60, 0, "ZZF_DESC", "@!" }}, 2 } )

	cZZJFSel := ""
	If !ZZJFTMP(cAlias)
		FWRestArea(aArea)
		Return ""
	EndIf

	DbSelectArea(cAlias)
	If (cAlias)->(Eof())
		MsgStop("Nenhuma filial encontrada para selecao.", cTitulo)
		(cAlias)->(DbCloseArea())
		FWRestArea(aArea)
		Return ""
	EndIf

	oMark := FWMBrowse():New()
	oMark:SetMenuDef("")
	oMark:SetIgnoreARotina(.T.)
	oMark:SetDescription("Filiais")
	oMark:SetAlias(cAlias)
	oMark:SetTemporary()
	oMark:SetWalkThru(.F.)
	oMark:SetAmbiente(.F.)
	oMark:SetFilterDefault("")
	oMark:SetColumns({{'Codigo'   ,{|| (cAlias)->ZZF_COD  } ,, "@!",,012,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
	oMark:SetColumns({{'Empresa'  ,{|| (cAlias)->ZZF_EMP  } ,, "@!",,002,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
	oMark:SetColumns({{'Unidade'  ,{|| (cAlias)->ZZF_UNID } ,, "@!",,002,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
	oMark:SetColumns({{'Filial'   ,{|| (cAlias)->ZZF_FIL  } ,, "@!",,002,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
	oMark:SetColumns({{'Descricao',{|| (cAlias)->ZZF_DESC } ,, "@!",,060,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
	oMark:SetSeek(.T., aSeek)
	oMark:AddButton("OK", {|| ZZJFSOK(cAlias)})
	oMark:AddButton("Cancelar", {|| CloseBrowse()})
	oMark:Activate()

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

	FWRestArea(aArea)
Return cZZJFSel

// Monta a tabela temporaria de filiais para selecao.
Static Function ZZJFTMP(cAlias)
	Local aFields := {}
	Local cQuery  := ""
	Local cQryAls := GetNextAlias()
	Local oTmp    := Nil
	Local cFilAtu := ""
	AAdd(aFields, { "ZZF_COD",  "C", 12, 0 })
	AAdd(aFields, { "ZZF_EMP",  "C", 02, 0 })
	AAdd(aFields, { "ZZF_UNID", "C", 02, 0 })
	AAdd(aFields, { "ZZF_FIL",  "C", 02, 0 })
	AAdd(aFields, { "ZZF_DESC", "C", 60, 0 })

	oTmp := FWTemporaryTable():New(cAlias)
	oTmp:SetFields(aFields)
	oTmp:AddIndex("01", {"ZZF_COD"})
	oTmp:AddIndex("02", {"ZZF_DESC"})
	oTmp:Create()

	cQuery := " SELECT M0_CODFIL, M0_CODIGO, M0_FILIAL "
	cQuery += " FROM SYS_COMPANY "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND M0_CODIGO = '" + ZZJSQL(cEmpAnt) + "' "
	cQuery += " ORDER BY M0_CODFIL "

	MpSysOpenQuery(cQuery, cQryAls)
	While !(cQryAls)->(Eof())
		cFilAtu := AllTrim((cQryAls)->M0_CODFIL)
		If ZZJAFIL(cFilAtu) .And. RecLock(cAlias, .T.)
			(cAlias)->ZZF_COD  := cFilAtu
			(cAlias)->ZZF_EMP  := AllTrim((cQryAls)->M0_CODIGO)
			(cAlias)->ZZF_UNID := SubStr(AllTrim((cQryAls)->M0_CODFIL), 3, 2)
			(cAlias)->ZZF_FIL  := SubStr(AllTrim((cQryAls)->M0_CODFIL), 5, 2)
			(cAlias)->ZZF_DESC := AllTrim((cQryAls)->M0_FILIAL)
			(cAlias)->(MsUnlock())
		EndIf
		(cQryAls)->(DbSkip())
	EndDo
	(cQryAls)->(DbCloseArea())

	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())

Return .T.

// Verifica se o usuario corrente possui acesso a filial.
Static Function ZZJFACS(cFil)
	Local cFils := ""
	Local lRet  := .T.

	If Empty(cFil)
		Return .F.
	EndIf

	If FindFunction("FilsUsr")
		lRet := FilsUsr(cFil, cFil, @cFils)
		If !lRet .And. Empty(cFils)
			Return .F.
		EndIf
	EndIf

	Return .T.

// Valida se a filial pode ser exibida/manipulada pelo usuario corrente.
Static Function ZZJAFIL(cFil)
	If Empty(AllTrim(cFil))
		Return .F.
	EndIf

	If !ZZJFACS(cFil)
		Return .F.
	EndIf

	If !ZZJFPLS(cFil)
		Return .F.
	EndIf

Return .T.

// Verifica se a filial esta habilitada no parametro MV_ZFPLSAF.
Static Function ZZJFPLS(cFil)
	Local cCont := ""
	Local cFil6 := AllTrim(cValToChar(cFil))

	If Empty(cFil6)
		Return .F.
	EndIf

	cCont := Upper(AllTrim(ZZJGETMV("MV_ZFPLSAF", cFil6)))

Return cCont $ "1|T|.T.|S|SIM|TRUE|.TRUE."

// Retorna o conteudo do parametro SX6 considerando a hierarquia filial 6/4/2/global.
Static Function ZZJGETMV(cVar, cFil)
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local cCont  := ""
	Local cFil6  := AllTrim(cValToChar(cFil))
	Local cFil4  := Left(cFil6, 4)
	Local cFil2  := Left(cFil6, 2)

	cQuery := " SELECT TOP 1 X6_CONTEUD "
	cQuery += " FROM " + RetSqlName("SX6")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND X6_VAR = '" + ZZJSQL(AllTrim(cVar)) + "' "
	cQuery += " AND X6_FIL IN ('" + ZZJSQL(cFil6) + "', '" + ZZJSQL(cFil4) + "', '" + ZZJSQL(cFil2) + "', '') "
	cQuery += " ORDER BY CASE X6_FIL "
	cQuery += " WHEN '" + ZZJSQL(cFil6) + "' THEN 1 "
	cQuery += " WHEN '" + ZZJSQL(cFil4) + "' THEN 2 "
	cQuery += " WHEN '" + ZZJSQL(cFil2) + "' THEN 3 "
	cQuery += " ELSE 4 END "

	MpSysOpenQuery(cQuery, cAlias)
	If !(cAlias)->(Eof())
		cCont := AllTrim(cValToChar((cAlias)->X6_CONTEUD))
	EndIf
	(cAlias)->(DbCloseArea())

Return cCont

// Verifica se o token informado existe na lista do parametro.
Static Function ZZJUTOK(cCont, cToken)
	Local aItens := {}
	Local nI     := 0

	cCont  := Upper(AllTrim(cValToChar(cCont)))
	cToken := Upper(AllTrim(cValToChar(cToken)))

	If Empty(cCont) .Or. Empty(cToken)
		Return .F.
	EndIf

	cCont  := StrTran(cCont, ";", "|")
	cCont  := StrTran(cCont, ",", "|")
	aItens := StrTokArr(cCont, "|")

	For nI := 1 To Len(aItens)
		If Upper(AllTrim(cValToChar(aItens[nI]))) == cToken
			Return .T.
		EndIf
	Next

Return .F.

// Valida os grupos do usuario corrente contra a lista do parametro.
Static Function ZZJUGRP(cCont)
	Local aGrp := {}
	Local nI   := 0

	If !FindFunction("UsrRetGrp")
		Return .F.
	EndIf

	aGrp := UsrRetGrp(__cUserID)
	For nI := 1 To Len(aGrp)
		If ZZJUTOK(cCont, aGrp[nI])
			Return .T.
		EndIf
	Next

Return .F.

// Confirma a filial marcada no browse de filiais.
Static Function ZZJFSOK(cAlias)
	Local cFil := ""

	DbSelectArea(cAlias)
	If (cAlias)->(Eof())
		MsgStop("Selecione uma filial.", cTitulo)
		Return Nil
	EndIf

	cFil := AllTrim((cAlias)->ZZF_COD)
	If Empty(cFil)
		MsgStop("Selecione uma filial.", cTitulo)
		Return Nil
	EndIf

	cZZJFSel := cFil
	CloseBrowse()

Return Nil

// Abre a janela para selecao de tecnologia, pacote e safra.
Static Function ZZJASK()
	Local aVar   := ZZJVAR()
	Local aPac   := {}
	Local aSaf   := ZZJSAF()
	Local cVar   := IIf(Len(aVar) > 0, aVar[1, 1], "")
	Local cVarD  := IIf(Len(aVar) > 0, ZZJVLB(aVar[1, 1], aVar[1, 2]), "")
	Local cCult  := IIf(Len(aVar) > 0, aVar[1, 2], "")
	Local cCultD := ZZJCUD(cCult)
	Local cPac   := ""
	Local cSafD  := IIf(Len(aSaf) > 0, ZZJSFT(aSaf[1, 1], aSaf[1, 2]), "")
	Local cSafTit := AllTrim(cValToChar(GetSx3Cache("ZZJ_SAFRA", "X3_TITULO")))
	Local nSafTam := Val(cValToChar(GetSx3Cache("ZZJ_SAFRA", "X3_TAMANHO")))
	Local nSafWid := Min(Max((nSafTam * 8) + 45, 120), 220)
	Local aRet   := {}
	Local lOk    := .F.
	Local oDlg   := Nil
	Local oCbVar := Nil
	Local oCbSaf := Nil
	Local oGetCu := Nil
	Local oBtnOk := Nil
	Local oBtnCa := Nil
	Local nVar   := 0
	Local nSaf   := 0

	If Len(aVar) == 0 .Or. Len(aSaf) == 0
		MsgStop("Nao foi possivel montar as listas de tecnologia e safra.", cTitulo)
		Return aRet
	EndIf

	DEFINE MSDIALOG oDlg TITLE "Planejamento de Safra Agricola" FROM 0, 0 TO 270, 920 PIXEL
		@ 24, 24 SAY "Tecnologia/Cultura" OF oDlg PIXEL SIZE 90, 10
		@ 20, 118 MSCOMBOBOX oCbVar VAR cVarD ITEMS ZZJVTX(aVar) SIZE 300, 50 OF oDlg ON CHANGE {|| ZZJVCUL(cVarD, @cVar, @cCult, @cCultD, oGetCu) } PIXEL
		@ 84, 24 SAY IIf(Empty(cSafTit), "Ano Safra", cSafTit) OF oDlg PIXEL SIZE 70, 10
		@ 80, 118 MSCOMBOBOX oCbSaf VAR cSafD ITEMS ZZJSFD(aSaf) SIZE nSafWid, 50 OF oDlg PIXEL
		@ 110, 258 BUTTON oBtnOk PROMPT "Preencher" SIZE 82, 16 OF oDlg ACTION (ZZJVCUL(cVarD, @cVar, @cCult, @cCultD, oGetCu), ZZJOKA(cVar, @cCult, @cCultD, @lOk, oDlg)) PIXEL
		@ 110, 168 BUTTON oBtnCa PROMPT "Cancelar" SIZE 82, 16 OF oDlg ACTION oDlg:End() PIXEL
	ACTIVATE MSDIALOG oDlg CENTERED

	If !lOk
		Return aRet
	EndIf

	nVar := AScan(aVar, {|aItem| Upper(AllTrim(aItem[1])) == Upper(AllTrim(cVar)) .And. Upper(AllTrim(aItem[2])) == Upper(AllTrim(cCult))})
	If nVar == 0
		MsgStop("Selecione uma cultura/tecnologia valida.", cTitulo)
		Return aRet
	EndIf
	aPac := ZZJPAC(aVar[nVar, 2])
	If Len(aPac) == 0
		MsgStop("Nenhum pacote disponivel para a opcao selecionada.", cTitulo)
		Return aRet
	EndIf
	cPac := ZZJASKSEL(aPac, "Pacote")
	If Empty(cPac)
		Return aRet
	EndIf
	nSaf := Max(1, AScan(aSaf, {|aItem| ZZJSFT(aItem[1], aItem[2]) == cSafD}))
	aRet := { aVar[nVar, 1], aVar[nVar, 2], cPac, aSaf[nSaf, 1] }

Return aRet

// Retorna somente os pacotes ainda nao lancados no contexto atual.
Static Function ZZJPEN()
	Local aPac := ZZJPAC(cZZJCultur)
	Local aRet := {}
	Local nI   := 0

	For nI := 1 To Len(aPac)
		If !ZZJPEXI(aPac[nI, 1])
			AAdd(aRet, aPac[nI])
		EndIf
	Next

Return aRet

// Verifica se o pacote ja possui lancamento para filial/cultura/tecnologia/safra.
Static Function ZZJPEXI(cPac)
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local cEtps  := ZZJESQL(cPac)
	Local cFil   := IIf(Empty(cZZJFilial), xFilial("ZZJ"), cZZJFilial)
	Local lRet   := .F.

	If Empty(cEtps)
		Return .F.
	EndIf

	cQuery := " SELECT TOP 1 R_E_C_N_O_ ZREC "
	cQuery += " FROM " + RetSqlName("ZZJ")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND ZZJ_FILIAL = '" + ZZJSQL(cFil) + "' "
	cQuery += " AND ZZJ_VARIED = '" + ZZJSQL(cZZJVaried) + "' "
	cQuery += " AND ZZJ_CULTUR = '" + ZZJSQL(cZZJCultur) + "' "
	cQuery += " AND ZZJ_SAFRA = '" + ZZJSQL(cZZJSafra) + "' "
	cQuery += " AND ZZJ_ETAPA IN (" + cEtps + ") "

	MpSysOpenQuery(cQuery, cAlias)
	lRet := !(cAlias)->(Eof())
	(cAlias)->(DbCloseArea())

Return lRet

// Solicita apenas o proximo pacote mantendo filial, tecnologia, cultura e safra.
Static Function ZZJASKP()
	Local aPac   := ZZJPEN()

	If Len(aPac) == 0
		MsgInfo("Todos os pacotes ja foram lancados para esta filial, cultura, tecnologia e safra.", cTitulo)
		Return ""
	EndIf

Return ZZJASKSEL(aPac, "Proximo Pacote")

// Solicita um pacote dentre as opcoes compativeis com o contexto selecionado.
Static Function ZZJASKSEL(aPac, cTituloDlg)
	Local cPac   := IIf(Len(aPac) > 0, aPac[1, 2], "")
	Local cRet   := ""
	Local lOk    := .F.
	Local oDlg   := Nil
	Local oCbPac := Nil
	Local oBtnOk := Nil
	Local oBtnCa := Nil
	Local nPac   := 0

	DEFINE MSDIALOG oDlg TITLE cTituloDlg FROM 0, 0 TO 190, 650 PIXEL
		@ 18, 24 MSCOMBOBOX oCbPac VAR cPac ITEMS ZZJDSC(aPac) SIZE 280, 50 OF oDlg PIXEL
		@ 40, 88 BUTTON oBtnCa PROMPT "Encerrar" SIZE 82, 16 OF oDlg ACTION oDlg:End() PIXEL
		@ 40, 178 BUTTON oBtnOk PROMPT "Preencher" SIZE 82, 16 OF oDlg ACTION (lOk := .T., oDlg:End()) PIXEL
	ACTIVATE MSDIALOG oDlg CENTERED

	If lOk
		nPac := Max(1, AScan(aPac, {|aItem| aItem[2] == cPac}))
		cRet := aPac[nPac, 1]
	EndIf

Return cRet
// Valida o card inicial antes de abrir a grid.
Static Function ZZJOKA(cVar, cCult, cCultD, lOk, oDlg)
	If !ZZJVARV(cVar, @cCult)
		Return Nil
	EndIf

	cCultD := ZZJCUD(cCult)
	lOk := .T.
	oDlg:End()

Return Nil

// Retorna as tecnologias formatadas para exibicao no combo.
Static Function ZZJVTX(aItens)
	Local aRet := {}
	Local nI   := 0

	For nI := 1 To Len(aItens)
		AAdd(aRet, ZZJVLB(aItens[nI, 1], aItens[nI, 2]))
	Next

Return aRet

// Monta a descricao do combo de tecnologia/cultura.
Static Function ZZJVLB(cVar, cCult)
	Local cRet := AllTrim(cValToChar(cVar))

	If Empty(cRet)
		cRet := ZZJCUD(cCult)
	Else
		cRet += " | " + ZZJCUD(cCult)
	EndIf

Return cRet

// Atualiza a cultura vinculada a tecnologia selecionada.
Static Function ZZJVCUL(cVarD, cVar, cCult, cCultD, oGetCu)
	Local aVar := ZZJVAR()
	Local nPos := AScan(aVar, {|aItem| Upper(AllTrim(ZZJVLB(aItem[1], aItem[2]))) == Upper(AllTrim(cVarD))})

	If nPos > 0
		cVar := aVar[nPos, 1]
		cCult := aVar[nPos, 2]
		cCultD := ZZJCUD(cCult)
		If ValType(oGetCu) == "O"
			oGetCu:Refresh()
		EndIf
	EndIf

Return Nil

// Monta o texto exibido no campo de safra.
Static Function ZZJSFT(cCod, cDesc)
	Local cRet := AllTrim(cValToChar(cCod))

	If !Empty(AllTrim(cValToChar(cDesc)))
		cRet += " - " + AllTrim(cValToChar(cDesc))
	EndIf

Return cRet

// Retorna as safras formatadas para exibicao no combo.
Static Function ZZJSFD(aSaf)
	Local aRet := {}
	Local nI   := 0

	For nI := 1 To Len(aSaf)
		AAdd(aRet, ZZJSFT(aSaf[nI, 1], aSaf[nI, 2]))
	Next

Return aRet


// Valida a tecnologia informada e recupera a cultura vinculada.
Static Function ZZJVARV(cVar, cCult)
	Local aVar := ZZJVAR()
	Local nPos := AScan(aVar, {|aItem| Upper(AllTrim(aItem[1])) == Upper(AllTrim(cVar)) .And. aItem[2] == cCult})

	If nPos == 0
		MsgStop("Selecione uma cultura/tecnologia valida.", cTitulo)
		Return .F.
	EndIf

	cCult := aVar[nPos, 2]
Return .T.

// Controla a navegacao entre as etapas da tela manual.
Static Function ZZJRUN(nOp)
	Local aRet  := {}
	Local cAcao := "C"

	Do While .T.
		aRet  := ZZJDLG(nOp)
		cAcao := aRet[1]

		Do Case
		Case cAcao == "V"
			cZZJCodEtp := ""
			nZZJEtapa := Max(1, nZZJEtapa - 1)
		Case cAcao == "A"
			If !ZZJGRV(aRet[2], nOp)
				Exit
			EndIf
			ZZJREF()
			cZZJCodEtp := ""
			nZZJEtapa++
		Case cAcao == "F"
			If !ZZJGRV(aRet[2], nOp)
				Exit
			EndIf
			ZZJREF()
			Exit
		Case cAcao == "P"
			If !ZZJGRV(aRet[2], nOp)
				Exit
			EndIf
			If !ZZJPUP()
				MsgStop("Nao foi possivel atualizar os precos das etapas do pacote.", cTitulo)
				Exit
			EndIf
			ZZJREF()
			// Mantem a acao para que a inclusao abra a selecao do proximo pacote.
			Exit
		Otherwise
			Exit
		EndCase
	EndDo

Return cAcao

// Atualiza o browse apos a gravacao. A ZZK da tecnologia/safra ja foi
// sincronizada em ZZJCONS(), portanto nao e necessario recalcular tudo.
Static Function ZZJREF()
	If ValType(oZZJTmp) == "O"
		oZZJTmp:Refresh()
	EndIf

Return Nil

// Abre a tela manual com uma unica grid, sem MVC.
Static Function ZZJDLG(nOp)
	Local oDlg  := Nil
	Local oGrid := Nil
	Local oCan  := Nil
	Local oBack := Nil
	Local oNext := Nil
	Local oConf := Nil
	Local oFontB := TFont():New("ARIAL", 08, -11, ,.T., , , ,.T., .F.)
	Local aHead := ZZJHDR()
	Local aCols := ZZJCOL(nOp)
	Local aEdit := ZZJALTF()
	Local aData := {}
	Local nGridW := ZZJGRDW(aHead)
	Local nDlgW := nGridW - 190
	Local nDlgH := 720
	Local nGridH := nDlgH - 500
	Local nGridTop := 68
	Local nBtRow := nGridH + 18
	Local nBtCanc := 10
	Local nBtBack := nBtCanc + 240
	Local nBtNext := nBtBack + 80
	Local nBtConf := nBtNext + 240
	Local nTitW := nGridW - 20
	Local cAcao := "C"
	Local cNext := IIf(nZZJEtapa >= Len(ZZJETA(cZZJPacote)), "Finalizar", "Avancar ->")
	Local cEtap := ZZJEDS(ZZJCET())

	nZZJCstHa := ZZJSHA(aCols)

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0, 0 TO nDlgH, nDlgW PIXEL
		@ 12, 10 SAY cEtap OF oDlg PIXEL SIZE 180, 12 FONT oFontB
		@ 24, 10 SAY ZZJTIT() OF oDlg PIXEL SIZE nTitW, 12
		@ 24, nBtConf - 42 SAY "Area Geral" OF oDlg PIXEL SIZE 70, 10
		@ 20, nBtConf + 2 MSGET nZZJAreGer PICTURE "@E 999999999.99" SIZE 100, 12 OF oDlg PIXEL
		@ 42, nBtConf - 42 SAY "Custo Pacote ($)" OF oDlg PIXEL SIZE 80, 10
		@ 38, nBtConf + 2 MSGET oZZJCstHa VAR nZZJCstHa PICTURE "@E 999,999,999.99" SIZE 100, 12 OF oDlg WHEN .F. PIXEL
		oGrid := MsNewGetDados():New(nGridTop, 5, nGridH, nGridW, GD_INSERT+GD_UPDATE+GD_DELETE, "U_ZZJLOK()", "AllwaysTrue", "+ZZJ_ITEM", aEdit, , 999, "AllwaysTrue", , "AllwaysTrue", oDlg, aHead, aCols)
		@ nBtRow, nBtCanc BUTTON oCan PROMPT "Cancelar" SIZE 80, 16 OF oDlg ACTION oDlg:End() PIXEL
		@ nBtRow, nBtBack BUTTON oBack PROMPT "<- Voltar" SIZE 70, 16 OF oDlg ACTION (cAcao := "V", oDlg:End()) PIXEL
		@ nBtRow, nBtNext BUTTON oNext PROMPT cNext SIZE 80, 16 OF oDlg ACTION ZZJGAC(IIf(cNext == "Finalizar", "F", "A"), @cAcao, oDlg) PIXEL
		@ nBtRow, nBtConf BUTTON oConf PROMPT "Confirmar" SIZE 90, 16 OF oDlg ACTION ZZJGAC("P", @cAcao, oDlg) PIXEL
		oZZJGrid := oGrid
	ACTIVATE MSDIALOG oDlg CENTERED
	If oGrid <> Nil
		aData := oGrid:aCols
	Else
		aData := aCols
	EndIf
	oZZJGrid := Nil
	oZZJCstHa := Nil

Return { cAcao, aData }

// Executa a acao da grid somente apos validar o card superior.
Static Function ZZJGAC(cNova, cAcao, oDlg)
	If !ZZJVOK()
		Return Nil
	EndIf

	cAcao := cNova
	oDlg:End()

Return Nil

// Valida os dados superiores da grid antes de gravar.
Static Function ZZJVOK()
	If nZZJAreGer <= 0
		MsgStop("Informe a area geral.", cTitulo)
		Return .F.
	EndIf

Return .T.

// Calcula a largura da grid conforme o tamanho dos campos na SX3.
Static Function ZZJGRDW(aHead)
	Local nI    := 0
	Local nSize := 0
	Local nRet  := 80

	For nI := 1 To Len(aHead)
		nSize := Max(Val(cValToChar(aHead[nI, 4])), Len(AllTrim(cValToChar(aHead[nI, 1]))))
		nRet += (nSize * 8) + 18
	Next

	nRet := Max(nRet, 970)
	nRet := Min(nRet, 1780)

Return nRet

// Retorna o cabecalho da grid manual a partir da SX3.
Static Function ZZJHDR()
	Local aRet    := {}
	Local aFields := ZZJFLD()
	Local nI      := 0
	Local cField  := ""

	For nI := 1 To Len(aFields)
		cField := aFields[nI]
		If cField == "ZZJ_TOTVIS"
			AAdd(aRet, { ;
				"Custo Total", ;
				cField, ;
				GetSx3Cache("ZZJ_CSTTOT", "X3_PICTURE"), ;
				GetSx3Cache("ZZJ_CSTTOT", "X3_TAMANHO"), ;
				GetSx3Cache("ZZJ_CSTTOT", "X3_DECIMAL"), ;
				".T.", ;
				"S", ;
				GetSx3Cache("ZZJ_CSTTOT", "X3_TIPO"), ;
				"", ;
				"V", ;
				"", ;
				"" })
		ElseIf cField == "ZZJ_FILL"
			AAdd(aRet, { "", cField, "@!", 1, 0, ".T.", "S", "C", "", "V", "", "" })
		Else
			AAdd(aRet, { ;
				GetSx3Cache(cField, "X3_TITULO"), ;
				cField, ;
				GetSx3Cache(cField, "X3_PICTURE"), ;
				GetSx3Cache(cField, "X3_TAMANHO"), ;
				GetSx3Cache(cField, "X3_DECIMAL"), ;
				".T.", ;
				"S", ;
				GetSx3Cache(cField, "X3_TIPO"), ;
				GetSx3Cache(cField, "X3_F3"), ;
				GetSx3Cache(cField, "X3_CONTEXT"), ;
				GetSx3Cache(cField, "X3_CBOX"), ;
				GetSx3Cache(cField, "X3_RELACAO") })
		EndIf
		If cField == "ZZJ_CDPROD"
			aRet[Len(aRet), 3] := "@!"
			aRet[Len(aRet), 6] := "U_ZZJPCD()"
			aRet[Len(aRet), 9] := ""
			aRet[Len(aRet), 10] := "V"
		EndIf
		If cField == "ZZJ_DEPROD"
			aRet[Len(aRet), 6] := "U_ZZJPRD()"
			aRet[Len(aRet), 9] := ""
			aRet[Len(aRet), 10] := "V"
		EndIf
		If cField == "ZZJ_ITEM"
			aRet[Len(aRet), 1] := "N. Apl."
		EndIf
		If cField == "ZZJ_DOSEHA" .Or. cField == "ZZJ_AREA" .Or. cField == "ZZJ_VOLUME" .Or. cField == "ZZJ_CSTDHA" .Or. cField == "ZZJ_VLFRET"
			aRet[Len(aRet), 6] := "U_ZZJCST()"
		EndIf
	Next

Return aRet

// Retorna os campos que podem ser editados na grid.
Static Function ZZJALTF()
	Local aRet := { "ZZJ_CDPROD", "ZZJ_DEPROD", "ZZJ_SUBGRP", "ZZJ_DOSEHA", "ZZJ_DAE", "ZZJ_AREA", "ZZJ_VOLUME" }

	If cZZJPacote == "S" .Or. cZZJPacote == "A"
		AAdd(aRet, "ZZJ_VLFRET")
	EndIf

Return aRet

// Retorna os campos editaveis da grid manual.
Static Function ZZJFLD()
	Local aRet := { "ZZJ_ITEM", "ZZJ_CDPROD", "ZZJ_DEPROD", "ZZJ_SUBGRP", "ZZJ_DOSEHA", "ZZJ_DAE", "ZZJ_AREA", "ZZJ_VOLUME", "ZZJ_CSTDHA"}

	If cZZJPacote == "S" .Or. cZZJPacote == "A"
		AAdd(aRet, "ZZJ_VLFRET")
	EndIf
	AAdd(aRet, "ZZJ_TOTVIS")
	AAdd(aRet, "ZZJ_FILL")

Return aRet

// Retorna as linhas iniciais da grid manual.
Static Function ZZJCOL(nOp)
	Local aRet   := {}
	Local nTamCod := Val(cValToChar(GetSx3Cache("ZZJ_CDPROD", "X3_TAMANHO")))
	Local nTamDes := Val(cValToChar(GetSx3Cache("ZZJ_DEPROD", "X3_TAMANHO")))
	Local aRow   := { 1, PadR("", nTamCod), PadR("", nTamDes), "", 0, 0, 0, 0, 0 }
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local cFil   := IIf(Empty(cZZJFilial), xFilial("ZZJ"), cZZJFilial)
	Local lVlfRet := cZZJPacote == "S" .Or. cZZJPacote == "A"

	If lVlfRet
		AAdd(aRow, 0)
	EndIf
	AAdd(aRow, 0)
	AAdd(aRow, "")
	AAdd(aRow, .F.)

	// Na inclusao, uma etapa ja gravada precisa ser relida ao voltar para ela.
	// Na alteracao, mantem o mesmo carregamento dos dados existentes.
	cQuery := " SELECT ZZJ_ITEM, ZZJ_CDPROD, ZZJ_DEPROD, ZZJ_SUBGRP, ZZJ_DOSEHA, ZZJ_DAE, ZZJ_AREA, ZZJ_VOLUME, ZZJ_CSTDHA "
	If lVlfRet
		cQuery += ", ZZJ_VLFRET "
	EndIf
	cQuery += ", ZZJ_CSTTOT "
	cQuery += " FROM " + RetSqlName("ZZJ")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND ZZJ_FILIAL = '" + ZZJSQL(cFil) + "' "
	cQuery += " AND ZZJ_VARIED = '" + ZZJSQL(cZZJVaried) + "' "
	cQuery += " AND ZZJ_CULTUR = '" + ZZJSQL(cZZJCultur) + "' "
	cQuery += " AND ZZJ_SAFRA = '" + ZZJSQL(cZZJSafra) + "' "
	cQuery += " AND ZZJ_ETAPA IN (" + ZZJES1(ZZJCET()) + ") "
	cQuery += " ORDER BY ZZJ_ITEM "

	MpSysOpenQuery(cQuery, cAlias)
	While !(cAlias)->(Eof())
		AAdd(aRet, { ;
			(cAlias)->ZZJ_ITEM, ;
			PadR(AllTrim((cAlias)->ZZJ_CDPROD), nTamCod), ;
			PadR(AllTrim((cAlias)->ZZJ_DEPROD), nTamDes), ;
			AllTrim((cAlias)->ZZJ_SUBGRP), ;
			(cAlias)->ZZJ_DOSEHA, ;
			(cAlias)->ZZJ_DAE, ;
			(cAlias)->ZZJ_AREA, ;
			(cAlias)->ZZJ_VOLUME, ;
			(cAlias)->ZZJ_CSTDHA })
		If lVlfRet
			AAdd(aRet[Len(aRet)], (cAlias)->ZZJ_VLFRET)
		EndIf
		AAdd(aRet[Len(aRet)], (cAlias)->ZZJ_CSTTOT)
		AAdd(aRet[Len(aRet)], "")
		AAdd(aRet[Len(aRet)], .F.)
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

	If Len(aRet) == 0
		AAdd(aRet, aRow)
	EndIf

Return aRet

// Grava as linhas preenchidas diretamente na tabela ZZJ.
Static Function ZZJGRV(aCols, nOp)
	Local nI     := 0
	Local nJ     := 0
	Local aFld   := ZZJFLD()
	Local aOld   := {}
	Local cFld   := ""
	Local nValid := 0
	Local nPos   := 0
	Local nItem  := 0
	Local nOld   := 0
	Local nDel   := 0
	Local lNovo  := .T.
	Default nOp := 1

	If !ZZJPACOK(cZZJPacote)
		MsgStop("Usuario sem permissao para utilizar este pacote.", cTitulo)
		Return .F.
	EndIf
	If !ZZJPACCTXOK(cZZJPacote, cZZJCultur)
		MsgStop("Os pacotes de solo exigem a opcao Preparo de Solo.", cTitulo)
		Return .F.
	EndIf

	// Garante o fechamento mesmo se o parametro for alterado enquanto a grid
	// estiver aberta.
	If !ZZJPSOK(cZZJSafra, IIf(Empty(cZZJFilial), xFilial("ZZJ"), cZZJFilial))
		Return .F.
	EndIf

	// Valida antes de alterar o banco. Na versao anterior, todos os registros
	// eram apagados antes desta validacao e podiam ser perdidos se a grid
	// estivesse vazia.
	For nI := 1 To Len(aCols)
		If Len(aCols[nI]) >= Len(aFld) + 1 .And. ;
			!aCols[nI, Len(aCols[nI])] .And. ;
			!Empty(AllTrim(cValToChar(aCols[nI, 2])))
			nValid++
		EndIf
	Next

	// Tambem na inclusao pode haver registros: o usuario pode ter avancado
	// uma etapa e voltado para corrigi-la. Preserva os RECNOs nesse caso.
	aOld := ZZJOLD()

	// Na alteracao, uma grid totalmente vazia representa a exclusao da
	// aplicacao atual. Antes ela era rejeitada pela validacao e os itens
	// reapareciam ao abrir a tela novamente.
	If nValid == 0
		If nOp == 2 .And. Len(aOld) > 0
			If !MsgYesNo("A aplicacao " + ZZJEDS(ZZJCET()) + " ficara sem itens. Confirma a exclusao desta aplicacao?", cTitulo)
				Return .F.
			EndIf

			For nI := 1 To Len(aOld)
				If !ZZJDREC(aOld[nI, 2])
					MsgStop("Nao foi possivel excluir uma linha da aplicacao.", cTitulo)
					Return .F.
				EndIf
				nDel++
			Next
			DbSelectArea("ZZJ")
			ZZJ->(DbCommit())
			ZZJCONS()
			MsgInfo("Aplicacao excluida com sucesso. Registros excluidos: " + cValToChar(nDel), cTitulo)
			Return .T.
		EndIf

		MsgStop("Nenhuma linha valida foi gravada. Informe ao menos o codigo do componente.", cTitulo)
		Return .F.
	EndIf

	For nI := 1 To Len(aCols)
		If Len(aCols[nI]) < Len(aFld) + 1
			Loop
		EndIf

		nItem := IIf(Empty(aCols[nI, 1]), nI, ZZJNUM(aCols[nI, 1]))
		nOld  := AScan(aOld, {|aItem| aItem[1] == nItem .And. !aItem[3]})

		If aCols[nI, Len(aCols[nI])] .Or. Empty(AllTrim(cValToChar(aCols[nI, 2])))
			// A linha so e excluida quando foi efetivamente removida na grid.
			If nOld > 0
				If !ZZJDREC(aOld[nOld, 2])
					MsgStop("Nao foi possivel excluir a linha removida do planejamento.", cTitulo)
					Return .F.
				EndIf
				aOld[nOld, 3] := .T.
			EndIf
			Loop
		EndIf

		ZZJSYNC(aCols[nI], .F.)
		ZZJRCOL(aCols[nI])

		DbSelectArea("ZZJ")
		lNovo := nOld == 0
		If !lNovo
			ZZJ->(DbGoTo(aOld[nOld, 2]))
			If ZZJ->(Eof()) .Or. ZZJ->(Deleted())
				lNovo := .T.
			ElseIf !RecLock("ZZJ", .F.)
				MsgStop("Nao foi possivel atualizar a linha do planejamento.", cTitulo)
				Return .F.
			EndIf
		EndIf

		If lNovo .And. !RecLock("ZZJ", .T.)
			MsgStop("Nao foi possivel incluir a linha do planejamento.", cTitulo)
			Return .F.
		EndIf

		ZZJ->ZZJ_FILIAL := IIf(Empty(cZZJFilial), xFilial("ZZJ"), cZZJFilial)
		ZZJ->ZZJ_VARIED := cZZJVaried
		ZZJ->ZZJ_CULTUR := cZZJCultur
		ZZJ->ZZJ_SAFRA  := cZZJSafra
		ZZJ->ZZJ_ETAPA  := ZZJCET()
		If FieldPos("ZZJ_AREGER") > 0
			ZZJ->ZZJ_AREGER := nZZJAreGer
		EndIf
		If FieldPos("ZZJ_CUSTO") > 0
			ZZJ->ZZJ_CUSTO := 0
		EndIf
		For nJ := 1 To Len(aFld)
			cFld := aFld[nJ]
			If cFld == "ZZJ_FILL"
				Loop
			EndIf
			If cFld == "ZZJ_TOTVIS"
				cFld := "ZZJ_CSTTOT"
			EndIf
			nPos := FieldPos(cFld)
			If nPos > 0
				If cFld == "ZZJ_ITEM" .And. Empty(aCols[nI, nJ])
					FieldPut(nPos, nI)
				Else
					FieldPut(nPos, ZZJVAL(cFld, aCols[nI, nJ]))
				EndIf
			EndIf
		Next
		ZZJ->(MsUnlock())
		If nOld > 0
			aOld[nOld, 3] := .T.
		EndIf
	Next

	// Exclui somente registros antigos que realmente deixaram de existir na
	// grid. Todos os demais preservam o RECNO e recebem os novos valores.
	For nI := 1 To Len(aOld)
		If !aOld[nI, 3] .And. !ZZJDREC(aOld[nI, 2])
			MsgStop("Nao foi possivel excluir uma linha removida do planejamento.", cTitulo)
			Return .F.
		EndIf
	Next

	DbSelectArea("ZZJ")
	ZZJ->(DbCommit())
	ZZJCONS()

Return .T.

// Carrega os registros atuais da etapa para que a alteracao preserve o RECNO.
Static Function ZZJOLD()
	Local aRet   := {}
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local cFil   := IIf(Empty(cZZJFilial), xFilial("ZZJ"), cZZJFilial)

	cQuery := " SELECT R_E_C_N_O_ ZREC, ZZJ_ITEM "
	cQuery += " FROM " + RetSqlName("ZZJ")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND ZZJ_FILIAL = '" + ZZJSQL(cFil) + "' "
	cQuery += " AND ZZJ_VARIED = '" + ZZJSQL(cZZJVaried) + "' "
	cQuery += " AND ZZJ_CULTUR = '" + ZZJSQL(cZZJCultur) + "' "
	cQuery += " AND ZZJ_SAFRA = '" + ZZJSQL(cZZJSafra) + "' "
	cQuery += " AND ZZJ_ETAPA IN (" + ZZJES1(ZZJCET()) + ") "
	cQuery += " ORDER BY ZZJ_ITEM, R_E_C_N_O_ "

	MpSysOpenQuery(cQuery, cAlias)
	While !(cAlias)->(Eof())
		AAdd(aRet, { ZZJNUM((cAlias)->ZZJ_ITEM), (cAlias)->ZREC, .F. })
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

Return aRet

// Exclui uma linha individual removida pelo usuario na grid.
Static Function ZZJDREC(nRec)
	DbSelectArea("ZZJ")
	ZZJ->(DbGoTo(nRec))
	If ZZJ->(Eof()) .Or. ZZJ->(Deleted())
		Return .T.
	EndIf
	If !RecLock("ZZJ", .F.)
		Return .F.
	EndIf
	ZZJ->(DbDelete())
	ZZJ->(MsUnlock())

Return .T.

// Consolida area geral e custo total por filial, cultura, tecnologia e safra.
Static Function ZZJCONS()
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local nTotal := 0
	Local cFil   := IIf(Empty(cZZJFilial), xFilial("ZZJ"), cZZJFilial)
	Local cTot   := "0"
	Local cArea  := "0"

	cQuery := " SELECT ISNULL(SUM(ZZJ_CSTTOT), 0) ZTOTAL "
	cQuery += " FROM " + RetSqlName("ZZJ")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND ZZJ_FILIAL = '" + ZZJSQL(cFil) + "' "
	cQuery += " AND ZZJ_VARIED = '" + ZZJSQL(cZZJVaried) + "' "
	cQuery += " AND ZZJ_CULTUR = '" + ZZJSQL(cZZJCultur) + "' "
	cQuery += " AND ZZJ_SAFRA = '" + ZZJSQL(cZZJSafra) + "' "

	MpSysOpenQuery(cQuery, cAlias)
	If !(cAlias)->(Eof())
		nTotal := (cAlias)->ZTOTAL
	EndIf
	(cAlias)->(DbCloseArea())

	cTot  := StrTran(AllTrim(Str(nTotal, 18, 2)), ",", ".")
	cArea := StrTran(AllTrim(Str(nZZJAreGer, 18, 2)), ",", ".")
	cQuery := " UPDATE " + RetSqlName("ZZJ") + " SET "
	cQuery += " ZZJ_CUSTO = " + cTot + ", "
	cQuery += " ZZJ_AREGER = " + cArea
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND ZZJ_FILIAL = '" + ZZJSQL(cFil) + "' "
	cQuery += " AND ZZJ_VARIED = '" + ZZJSQL(cZZJVaried) + "' "
	cQuery += " AND ZZJ_CULTUR = '" + ZZJSQL(cZZJCultur) + "' "
	cQuery += " AND ZZJ_SAFRA = '" + ZZJSQL(cZZJSafra) + "' "

	If TcSqlExec(cQuery) != 0
		MsgStop("Nao foi possivel consolidar o custo total do planejamento.", cTitulo)
		Return Nil
	EndIf

	ZZKSYN(cFil, cZZJCultur, cZZJVaried, cZZJSafra, cZZJPacote)

Return Nil

// Recalcula os precos de todas as etapas do pacote apos a confirmacao.
// A regra de composicao do preco e a mesma usada na grid: preco unitario
// atual do componente multiplicado pela dose e pela area da aplicacao.
Static Function ZZJPUP()
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local cFil   := IIf(Empty(cZZJFilial), xFilial("ZZJ"), cZZJFilial)
	Local cEtps  := ZZJESQL(cZZJPacote)
	Local lVlfRet := cZZJPacote == "S" .Or. cZZJPacote == "A"
	Local nRec   := 0
	Local cProd  := ""
	Local nDose  := 0
	Local nArea  := 0
	Local nPreco := 0
	Local nCstHa := 0
	Local nCstTot := 0
	Local nVlfRet := 0

	If Empty(cZZJPacote) .Or. Empty(cEtps)
		Return .F.
	EndIf

	cQuery := " SELECT R_E_C_N_O_ ZREC, ZZJ_CDPROD, ZZJ_DOSEHA, ZZJ_AREA "
	If lVlfRet
		cQuery += ", ZZJ_VLFRET "
	EndIf
	cQuery += " FROM " + RetSqlName("ZZJ")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND ZZJ_FILIAL = '" + ZZJSQL(cFil) + "' "
	cQuery += " AND ZZJ_VARIED = '" + ZZJSQL(cZZJVaried) + "' "
	cQuery += " AND ZZJ_CULTUR = '" + ZZJSQL(cZZJCultur) + "' "
	cQuery += " AND ZZJ_SAFRA = '" + ZZJSQL(cZZJSafra) + "' "
	cQuery += " AND ZZJ_ETAPA IN (" + cEtps + ") "
	cQuery += " ORDER BY R_E_C_N_O_ "

	MpSysOpenQuery(cQuery, cAlias)
	DbSelectArea("ZZJ")
	While !(cAlias)->(Eof())
		nRec  := (cAlias)->ZREC
		cProd := AllTrim(cValToChar((cAlias)->ZZJ_CDPROD))
		nDose := ZZJNUM((cAlias)->ZZJ_DOSEHA)
		nArea := ZZJNUM((cAlias)->ZZJ_AREA)

		If nRec > 0 .And. !Empty(cProd)
			nPreco  := ZZJPCM(cProd)
			nCstHa  := nDose * nPreco
			nCstTot := nArea * nCstHa
			If lVlfRet
				nVlfRet := ZZJNUM((cAlias)->ZZJ_VLFRET)
			Else
				nVlfRet := 0
			EndIf
			nCstTot += nVlfRet
			If nArea > 0
				nCstHa := nCstTot / nArea
			EndIf
			ZZJ->(DbGoTo(nRec))
			If ZZJ->(Eof()) .Or. ZZJ->(Deleted()) .Or. !RecLock("ZZJ", .F.)
				(cAlias)->(DbCloseArea())
				Return .F.
			EndIf
			ZZJ->ZZJ_CSTDHA := nCstHa
			ZZJ->ZZJ_CSTTOT := nCstTot
			ZZJ->(MsUnlock())
		EndIf

		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())
	ZZJ->(DbCommit())

	// Atualiza os totalizadores do planejamento e do pacote com os novos precos.
	ZZJCONS()

Return .T.

// Exclui todas as etapas de um pacote do planejamento informado.
Static Function ZZJDEP(cFil, cVar, cCul, cSaf, cPac)
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local nRec   := 0
	Local nDel   := 0
	Local cEtps  := ZZJESQL(cPac)

	If Empty(cEtps)
		MsgStop("Nao ha etapas cadastradas para o pacote informado.", cTitulo)
		Return .F.
	EndIf

	cQuery := " SELECT R_E_C_N_O_ ZREC "
	cQuery += " FROM " + RetSqlName("ZZJ")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND ZZJ_FILIAL = '" + ZZJSQL(cFil) + "' "
	cQuery += " AND ZZJ_VARIED = '" + ZZJSQL(cVar) + "' "
	cQuery += " AND ZZJ_CULTUR = '" + ZZJSQL(cCul) + "' "
	cQuery += " AND ZZJ_SAFRA = '" + ZZJSQL(cSaf) + "' "
	cQuery += " AND ZZJ_ETAPA IN (" + cEtps + ") "

	MpSysOpenQuery(cQuery, cAlias)
	DbSelectArea("ZZJ")
	While !(cAlias)->(Eof())
		nRec := (cAlias)->ZREC
		If nRec > 0
			ZZJ->(DbGoTo(nRec))
			If !ZZJ->(Eof()) .And. RecLock("ZZJ", .F.)
				ZZJ->(DbDelete())
				ZZJ->(MsUnlock())
				nDel++
			EndIf
		EndIf
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())
	ZZJ->(DbCommit())

	If nDel > 0
		ZZKDEL(cFil, cCul, cVar, cSaf, cPac)
		MsgInfo("Pacote excluido com sucesso. Registros excluidos: " + cValToChar(nDel), cTitulo)
	Else
		MsgInfo("Nenhum registro encontrado para exclusao.", cTitulo)
	EndIf

Return nDel > 0

// Recalcula as linhas de resumo de uma tecnologia/safra a partir da ZZJ.
// Quando informado, limita a sincronizacao ao pacote alterado.
Static Function ZZKSYN(cFil, cCul, cVar, cSaf, cPacSel)
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local cPac   := ""
	Default cPacSel := ""

	cQuery := " SELECT MAX(ZZJ_AREGER) ZZJ_AREGER, MAX(ZZJ_CUSTO) ZZJ_CUSTO, "
	cQuery += " CASE WHEN LEFT(ZZJ_ETAPA,1) BETWEEN '0' AND '9' THEN '' ELSE LEFT(ZZJ_ETAPA,1) END ZZJ_PACOTE, "
	cQuery += " MIN(ZZJ_DAE) ZZJ_DAE, SUM(ZZJ_CSTDHA) ZZJ_CSTDHA "
	cQuery += " FROM " + RetSqlName("ZZJ")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND ZZJ_FILIAL = '" + ZZJSQL(cFil) + "' "
	cQuery += " AND ZZJ_CULTUR = '" + ZZJSQL(cCul) + "' "
	cQuery += " AND ZZJ_VARIED = '" + ZZJSQL(cVar) + "' "
	cQuery += " AND ZZJ_SAFRA = '" + ZZJSQL(cSaf) + "' "
	If !Empty(cPacSel)
		cQuery += " AND CASE WHEN LEFT(ZZJ_ETAPA,1) BETWEEN '0' AND '9' THEN '' ELSE LEFT(ZZJ_ETAPA,1) END = '" + ZZJSQL(cPacSel) + "' "
	EndIf
	cQuery += " GROUP BY CASE WHEN LEFT(ZZJ_ETAPA,1) BETWEEN '0' AND '9' THEN '' ELSE LEFT(ZZJ_ETAPA,1) END "

	MpSysOpenQuery(cQuery, cAlias)
	While !(cAlias)->(Eof())
		cPac := AllTrim(cValToChar((cAlias)->ZZJ_PACOTE))
		ZZKGRV(cFil, cCul, cVar, cSaf, cPac, (cAlias)->ZZJ_AREGER, (cAlias)->ZZJ_CUSTO, (cAlias)->ZZJ_CSTDHA, (cAlias)->ZZJ_DAE)
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

Return Nil

// Exclui o resumo do pacote quando todos os seus itens forem removidos da ZZJ.
Static Function ZZKDEL(cFil, cCul, cVar, cSaf, cPac)
	Local aRec := ZZKREC(cFil, cCul, cVar, cSaf, cPac)
	Local nI   := 0

	DbSelectArea("ZZK")
	For nI := 1 To Len(aRec)
		ZZK->(DbGoTo(aRec[nI]))
		If !ZZK->(Eof()) .And. !ZZK->(Deleted()) .And. RecLock("ZZK", .F.)
			ZZK->(DbDelete())
			ZZK->(MsUnlock())
		EndIf
	Next
	ZZK->(DbCommit())

Return Nil

// Retorna os codigos de etapa do pacote formatados para SQL no novo padrao.
Static Function ZZJESQL(cPac)
	Local aEtp := ZZJETA(cPac)
	Local cRet := ""
	Local cCod := ""
	Local nI   := 0

	For nI := 1 To Len(aEtp)
		cCod := ZZJETC(aEtp[nI])
		If !Empty(cCod)
			If !Empty(cRet)
				cRet += ","
			EndIf
			cRet += "'" + ZZJSQL(cCod) + "'"
		EndIf
	Next

Return cRet

// Escapa texto para uso em filtros SQL.
Static Function ZZJSQL(cText)
Return StrTran(AllTrim(cValToChar(cText)), "'", "''")

// Converte valores da grid para o tipo definido na SX3.
Static Function ZZJVAL(cField, xVal)
	If GetSx3Cache(cField, "X3_TIPO") == "N" .Or. cField == "ZZJ_CSTTOT"
		If ValType(xVal) == "N"
			Return xVal
		EndIf
		Return ZZJNUM(xVal)
	EndIf
Return cValToChar(xVal)

// Acionado ao sair da descricao para preencher produto e grupo da linha.
User Function ZZJPRD()
Return ZZJPRDS()

// Acionado ao sair do codigo para preencher produto e grupo da linha.
User Function ZZJPCD()
Return ZZJPRDC()

// Valida a linha atual e sincroniza os dados do produto quando possivel.
User Function ZZJLOK()
	If oZZJGrid <> Nil .And. oZZJGrid:nAt > 0
		ZZJMEM(oZZJGrid:aCols[oZZJGrid:nAt])
		ZZJSYNC(oZZJGrid:aCols[oZZJGrid:nAt], .T.)
		ZZJTHA()
	EndIf
Return .T.

// Consulta SB1 pelo codigo e atualiza a linha corrente da grid.
Static Function ZZJPRDC()
	Local nRow   := 0
	Local cCod   := ""

	If oZZJGrid == Nil .Or. oZZJGrid:nAt <= 0
		Return .T.
	EndIf

	nRow := oZZJGrid:nAt
	ZZJMEM(oZZJGrid:aCols[nRow])
	cCod := AllTrim(cValToChar(oZZJGrid:aCols[nRow, 2]))
	If Empty(cCod)
		Return .T.
	EndIf

Return IIf(ZZJSYNC(oZZJGrid:aCols[nRow], .T.), (ZZJTHA(), .T.), .F.)

// Consulta SB1 pela descricao e atualiza a linha corrente da grid.
Static Function ZZJPRDS()
	Local nRow   := 0
	Local cDesc  := ""

	If oZZJGrid == Nil .Or. oZZJGrid:nAt <= 0
		Return .T.
	EndIf

	nRow  := oZZJGrid:nAt
	ZZJMEM(oZZJGrid:aCols[nRow])
	cDesc := AllTrim(cValToChar(oZZJGrid:aCols[nRow, 3]))
	If Empty(cDesc)
		Return .T.
	EndIf

Return IIf(ZZJSYNC(oZZJGrid:aCols[nRow], .T.), (ZZJTHA(), .T.), .F.)

// Atualiza a linha com os valores em edicao do MsNewGetDados.
Static Function ZZJMEM(aRow)
	If Len(aRow) < 3
		Return Nil
	EndIf

	If Type("M->ZZJ_CDPROD") <> "U"
		aRow[2] := M->ZZJ_CDPROD
	EndIf

	If Type("M->ZZJ_DEPROD") <> "U"
		aRow[3] := M->ZZJ_DEPROD
	EndIf

Return Nil

// Sincroniza codigo, descricao, grupo e custo da linha informada.
Static Function ZZJSYNC(aRow, lMsg)
	Local aProd := {}
	Local cCod  := ""
	Local cDesc := ""
	Default lMsg := .F.

	If Len(aRow) < 10
		Return .F.
	EndIf

	cCod  := AllTrim(cValToChar(aRow[2]))
	cDesc := AllTrim(cValToChar(aRow[3]))

	If !Empty(cCod)
		aProd := ZZJPCOD(cCod)
	ElseIf !Empty(cDesc)
		aProd := ZZJPDES(cDesc, lMsg)
	EndIf

	If Len(aProd) >= 3
		aRow[2] := aProd[1]
		aRow[3] := aProd[2]
		aRow[4] := aProd[3]
		ZZJRCOL(aRow)
		Return .T.
	EndIf

	If lMsg .And. !Empty(cCod)
		MsgStop("Componente nao encontrado para o codigo informado.", cTitulo)
	EndIf

Return .F.

// Busca produto na SB1 pelo codigo informado.
Static Function ZZJPCOD(cCod)
	Local aRet   := {}
	Local cAlias := GetNextAlias()
	Local cQuery := ""

	cQuery := " SELECT TOP 1 SB1.B1_COD, SB1.B1_DESC, ISNULL(SBM.BM_DESC, SB1.B1_GRUPO) BM_DESC "
	cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
	cQuery += " INNER JOIN " + RetSqlName("SBM") + " SBM "
	cQuery += " ON SBM.D_E_L_E_T_ = ' ' "
	cQuery += " AND SBM.BM_FILIAL IN ('', '" + xFilial("SBM") + "') "
	cQuery += " AND SBM.BM_GRUPO = SB1.B1_GRUPO "
	cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' "
	cQuery += " AND SB1.B1_FILIAL IN ('', '" + xFilial("SB1") + "') "
	cQuery += " AND RTRIM(SB1.B1_COD) IN (" + ZZJCIN(cCod) + ") "
	cQuery += " AND ISNULL(SB1.B1_MSBLQL, '') <> '1' "
	cQuery += " ORDER BY SB1.B1_FILIAL DESC "

	MpSysOpenQuery(cQuery, cAlias)
	If !(cAlias)->(Eof())
		aRet := { AllTrim((cAlias)->B1_COD), AllTrim((cAlias)->B1_DESC), AllTrim((cAlias)->BM_DESC) }
	EndIf
	(cAlias)->(DbCloseArea())

Return aRet

// Busca produto na SB1 pela descricao digitada.
Static Function ZZJPDES(cDesc, lMsg)
	Local aRet   := {}
	Local aProd  := {}
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local cFind  := StrTran(Upper(AllTrim(cDesc)), "'", "''")
	Local nSel   := 0
	Default lMsg := .F.

	cQuery := " SELECT TOP 100 SB1.B1_COD, SB1.B1_DESC, ISNULL(SBM.BM_DESC, SB1.B1_GRUPO) BM_DESC "
	cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
	cQuery += " INNER JOIN " + RetSqlName("SBM") + " SBM "
	cQuery += " ON SBM.D_E_L_E_T_ = ' ' "
	cQuery += " AND SBM.BM_FILIAL IN ('', '" + xFilial("SBM") + "') "
	cQuery += " AND SBM.BM_GRUPO = SB1.B1_GRUPO "
	cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' "
	cQuery += " AND SB1.B1_FILIAL IN ('', '" + xFilial("SB1") + "') "
	cQuery += " AND UPPER(SB1.B1_DESC) LIKE '%" + cFind + "%' "
	cQuery += " AND ISNULL(SB1.B1_MSBLQL, '') <> '1' "
	cQuery += " ORDER BY SB1.B1_DESC "

	MpSysOpenQuery(cQuery, cAlias)
	While !(cAlias)->(Eof())
		AAdd(aProd, { AllTrim((cAlias)->B1_COD), AllTrim((cAlias)->B1_DESC), AllTrim((cAlias)->BM_DESC) })
		If Upper(AllTrim((cAlias)->B1_DESC)) == cFind
			nSel := Len(aProd)
		EndIf
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

	If Len(aProd) == 0
		If lMsg
			MsgStop("Componente nao encontrado. Informe uma descricao mais especifica.", cTitulo)
		EndIf
		Return aRet
	EndIf

	If nSel == 0
		If Len(aProd) == 1
			nSel := 1
		Else
			If lMsg
				MsgInfo("Foram encontrados " + cValToChar(Len(aProd)) + " componentes. Informe uma descricao mais especifica.", cTitulo)
			EndIf
			Return aRet
		EndIf
	EndIf

	If nSel > 0
		aRet := aProd[nSel]
	EndIf

Return aRet

// Calcula o custo do pacote igual a planilha: soma o Custo / HA.
Static Function ZZJSHA(aCols)
	Local nI   := 0
	Local nRet := 0

	For nI := 1 To Len(aCols)
		If Len(aCols[nI]) >= 11 .And. !aCols[nI, Len(aCols[nI])] .And. !Empty(AllTrim(cValToChar(aCols[nI, 2])))
			nRet += ZZJNUM(aCols[nI, 9])
		EndIf
	Next

Return nRet

// Atualiza o totalizador visual de custo por hectare do pacote.
Static Function ZZJTHA()
	If oZZJGrid == Nil
		Return Nil
	EndIf

	nZZJCstHa := ZZJSHA(oZZJGrid:aCols)
	If ValType(oZZJCstHa) == "O"
		oZZJCstHa:Refresh()
	EndIf

Return Nil
// Acionado ao alterar volume ou custo para recalcular o custo total.
User Function ZZJCST()
	If oZZJGrid <> Nil .And. oZZJGrid:nAt > 0
		ZZJRCT(oZZJGrid:nAt)
	EndIf
Return .T.

// Recalcula o custo total da linha corrente.
Static Function ZZJRCT(nRow)
	If oZZJGrid == Nil .Or. nRow <= 0 .Or. Len(oZZJGrid:aCols[nRow]) < 10
		Return Nil
	EndIf

	ZZJRCOL(oZZJGrid:aCols[nRow])
	ZZJTHA()

Return Nil

// Recalcula volume, custo por hectare e custo total da linha.
Static Function ZZJRCOL(aRow)
	Local cCod  := ""
	Local aFld  := ZZJFLD()
	Local nDose := 0
	Local nArea := 0
	Local nUnit := 0
	Local nVol  := 0
	Local nCha  := 0
	Local nTot  := 0
	Local nPosTot := AScan(aFld, {|cFld| cFld == "ZZJ_TOTVIS"})
	Local nPosFrete := AScan(aFld, {|cFld| cFld == "ZZJ_VLFRET"})

	If Len(aRow) < 10
		Return Nil
	EndIf

	cCod  := AllTrim(cValToChar(aRow[2]))
	nDose := ZZJNUM(aRow[5])
	nArea := ZZJNUM(aRow[7])

	If Empty(cCod)
		Return Nil
	EndIf

	nUnit := ZZJPCM(cCod)
	nVol  := nDose * nArea
	nCha  := nDose * nUnit
	nTot  := nArea * nCha
	If nPosFrete > 0
		nTot += ZZJNUM(aRow[nPosFrete])
	EndIf
	If nArea > 0
		nCha := nTot / nArea
	EndIf

	aRow[8]  := nVol
	aRow[9]  := nCha
	aRow[nPosTot] := nTot

Return Nil

// Converte valor numerico vindo da grid.
Static Function ZZJNUM(xVal)
	Local cVal := AllTrim(cValToChar(xVal))

	If "," $ cVal
		cVal := StrTran(cVal, ".", "")
		cVal := StrTran(cVal, ",", ".")
	EndIf

Return Val(cVal)

// Busca o ultimo preco de pedido de compra do produto e converte para dolar quando necessario.
Static Function ZZJPCM(cCod)
	Local nCusto := 0
	Local cFil   := IIf(Empty(cZZJFilial), xFilial("SC7"), cZZJFilial)

	cCod := AllTrim(cValToChar(cCod))
	If Empty(cCod)
		Return nCusto
	EndIf

	nCusto := ZZJPCS(cCod, 0)
	If nCusto <= 0
		nCusto := ZZJPCS(cCod, 1)
		If nCusto <= 0
			nCusto := ZZJUPR(cCod, cFil)
			If nCusto <= 0
				ZZJAVC(cCod + "|S", "Produto " + cCod + " nao possui pedido nas duas ultimas safras nem Ultimo Preco informado no cadastro. O custo ficara zerado.")
			EndIf
		EndIf
	EndIf

Return nCusto

// Busca o ultimo pedido de compra da safra vigente (nVolta=0) ou anterior
// (nVolta=1), considerando todas as filiais. A safra vai de 01/09 a 31/08.
// C7_XSAFRA pode estar gravado como AAAA/AAAA ou AAAAAAAA.
Static Function ZZJPCS(cCod, nVolta)
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	// Local nCusto := 0
	Local nPreco := 0
	Local nMoeda := 0
	Local nAnoIni := Year(dDataBase)
	Local dEmis := dDataBase
	Local cSafraRep := ""
	Local cSafraProx := ""

	Default nVolta := 0
	If Month(dDataBase) < 9
		nAnoIni--
	EndIf
	nAnoIni -= nVolta
	cSafraRep := StrZero(nAnoIni, 4) + StrZero(nAnoIni, 4)
	cSafraProx := StrZero(nAnoIni, 4) + StrZero(nAnoIni + 1, 4)

	cQuery := " SELECT TOP 1 C7_PRECO, C7_MOEDA, C7_EMISSAO "
	cQuery += " FROM " + RetSqlName("SC7")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND TRIM(C7_PRODUTO) IN (" + ZZJCIN(cCod) + ") "
	cQuery += " AND C7_PRECO > 0 "
	// Remove a barra para tratar tanto 2024/2025 quanto 20242025.
	// Apenas a repeticao do ano inicial ou o ano inicial/proximo ano sao aceitos.
	cQuery += " AND REPLACE(TRIM(C7_XSAFRA), '/', '') IN ('" + cSafraRep + "', '" + cSafraProx + "') "
	cQuery += " ORDER BY C7_EMISSAO DESC, C7_NUM DESC, C7_ITEM DESC, R_E_C_N_O_ DESC "

	MpSysOpenQuery(cQuery, cAlias)
	If !(cAlias)->(Eof())
		nPreco := (cAlias)->C7_PRECO
		nMoeda := Val(AllTrim(cValToChar((cAlias)->C7_MOEDA)))
		If ValType((cAlias)->C7_EMISSAO) == "D"
			dEmis := (cAlias)->C7_EMISSAO
		ElseIf !Empty((cAlias)->C7_EMISSAO)
			dEmis := SToD((cAlias)->C7_EMISSAO)
		EndIf
	EndIf
	(cAlias)->(DbCloseArea())

Return ZZJCPD(nPreco, nMoeda, dEmis)

// Consulta o Ultimo Preco (B1_UPRC) do cadastro do produto quando nao ha pedido de compra.
Static Function ZZJUPR(cCod, cFil)
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local cFilSB1 := IIf(Empty(cFil), xFilial("SB1"), cFil)
	Local nPreco := 0

	cQuery := " SELECT TOP 1 B1_UPRC "
	cQuery += " FROM " + RetSqlName("SB1")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND TRIM(B1_COD) IN (" + ZZJCIN(cCod) + ") "
	cQuery += " AND B1_FILIAL IN ('', '" + ZZJSQL(cFilSB1) + "') "
	cQuery += " AND B1_UPRC > 0 "
	cQuery += " ORDER BY CASE WHEN B1_FILIAL = '" + ZZJSQL(cFilSB1) + "' THEN 1 ELSE 2 END "

	MpSysOpenQuery(cQuery, cAlias)
	If !(cAlias)->(Eof())
		nPreco := (cAlias)->B1_UPRC
	EndIf
	(cAlias)->(DbCloseArea())

// B1_UPRC e informado na moeda 1; converte para dolar para manter o custo planejado.
Return ZZJCPD(nPreco, 1, dDataBase)

// Consulta o ultimo pedido de compra do produto na SC7 para uma filial ou todas.
Static Function ZZJCPC(cCod, cFil)
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local nCusto := 0
	Local nPreco := 0
	Local nMoeda := 0
	Local dEmis  := dDataBase

	cQuery := " SELECT TOP 1 C7_PRECO, C7_MOEDA, C7_EMISSAO "
	cQuery += " FROM " + RetSqlName("SC7")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND RTRIM(C7_PRODUTO) IN (" + ZZJCIN(cCod) + ") "
	cQuery += " AND C7_PRECO > 0 "
	cQuery += " AND C7_EMISSAO <= '" + DToS(dDataBase) + "' "
	If !Empty(cFil)
		cQuery += " AND C7_FILIAL = '" + ZZJSQL(cFil) + "' "
	EndIf
	cQuery += " ORDER BY C7_EMISSAO DESC, C7_NUM DESC, C7_ITEM DESC, R_E_C_N_O_ DESC "

	MpSysOpenQuery(cQuery, cAlias)
	If !(cAlias)->(Eof())
		nPreco := (cAlias)->C7_PRECO
		nMoeda := Val(AllTrim(cValToChar((cAlias)->C7_MOEDA)))
		If ValType((cAlias)->C7_EMISSAO) == "D"
			dEmis := (cAlias)->C7_EMISSAO
		ElseIf !Empty((cAlias)->C7_EMISSAO)
			dEmis := SToD((cAlias)->C7_EMISSAO)
		EndIf
	EndIf
	(cAlias)->(DbCloseArea())

	nCusto := ZZJCPD(nPreco, nMoeda, dEmis)

Return nCusto

// Converte o preco do pedido para dolar (moeda 2), mantendo a regra de custo em USD.
Static Function ZZJCPD(nPreco, nMoeda, dData)
	Local nCusto := 0
	Local nPtax  := 0

	If nPreco <= 0
		Return nCusto
	EndIf

	If Empty(dData)
		dData := dDataBase
	EndIf

	If Empty(nMoeda)
		nMoeda := 1
	EndIf

	Do Case
	Case nMoeda == 2
		nCusto := nPreco
	Case nMoeda == 1
		nPtax := ZZJPTX(dData)
		If nPtax > 0
			nCusto := nPreco / nPtax
		EndIf
	Otherwise
		nCusto := xMoeda(nPreco, nMoeda, 2, dData)
	EndCase

Return nCusto

// Emite alerta de custo uma unica vez por produto.
Static Function ZZJAVC(cKey, cMsg)
	If AScan(aZZJAvC, {|cItem| cItem == cKey}) == 0
		AAdd(aZZJAvC, cKey)
		MsgAlert(cMsg, cTitulo)
	EndIf

Return Nil
// Retorna a PTAX da moeda 2 na data base.
Static Function ZZJPTX(dRef)
	Local nPtax  := 0
	Local cAlias := GetNextAlias()
	Local cQuery := ""

	If Empty(dRef)
		dRef := dDataBase
	EndIf

	nPtax := RecMoeda(dRef, "2")
	If nPtax > 0
		Return nPtax
	EndIf

	cQuery := " SELECT TOP 1 M2_MOEDA2 "
	cQuery += " FROM " + RetSqlName("SM2")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND M2_DATA <= '" + DToS(dRef) + "' "
	cQuery += " AND M2_MOEDA2 > 0 "
	cQuery += " ORDER BY M2_DATA DESC "

	MpSysOpenQuery(cQuery, cAlias)
	If !(cAlias)->(Eof())
		nPtax := (cAlias)->M2_MOEDA2
	EndIf
	(cAlias)->(DbCloseArea())

Return nPtax

// Retorna variacoes seguras do codigo para consulta SQL.
Static Function ZZJCIN(cCod)
	Local aCod := {}
	Local cRet := ""
	Local cTmp := AllTrim(cValToChar(cCod))
	Local nI   := 0

	If !Empty(cTmp)
		AAdd(aCod, cTmp)
		AAdd(aCod, PadL(cTmp, 9, "0"))
		AAdd(aCod, PadL(cTmp, 10, "0"))
	EndIf

	For nI := 1 To Len(aCod)
		cTmp := AllTrim(aCod[nI])
		If !Empty(cTmp) .And. !((("'" + StrTran(cTmp, "'", "''") + "'") $ cRet))
			If !Empty(cRet)
				cRet += ","
			EndIf
			cRet += "'" + StrTran(cTmp, "'", "''") + "'"
		EndIf
	Next

	If Empty(cRet)
		cRet := "''"
	EndIf

Return cRet

// Retorna os textos do combo de tecnologia por cultura.
Static Function ZZJVDS(aItens)
	Local aRet := {}
	Local nI   := 0

	For nI := 1 To Len(aItens)
		AAdd(aRet, aItens[nI, 1] + " | " + aItens[nI, 2])
	Next

Return aRet

// Converte a cultura da carga para uma das opcoes validas de ZZJ_CULTUR.
Static Function ZZJCUL(cCultur)
	Local cText := Upper(AllTrim(cCultur))

	If cText $ "ABCDEFGH" .And. Len(cText) == 1
		Return cText
	EndIf

	Do Case
	Case "ALGODAO" $ cText
		Return "A"
	Case "COBERTURA" $ cText
		Return "B"
	Case "MILHO" $ cText
		Return "C"
	Case "EUCALIPTO" $ cText
		Return "H"
	Case "PASTAGEM" $ cText .Or. "BRACHIARIA" $ cText
		Return "D"
	Case "SOJA SEMENTE" $ cText
		Return "F"
	Case "SOJA" $ cText
		Return "E"
	Case "CAFE" $ cText
		Return "G"
	EndCase

Return ""

// Retorna a descricao oficial de cada opcao de ZZJ_CULTUR.
Static Function ZZJCUD(cCultur)
	Do Case
	Case cCultur == "S"
		Return "Preparo de Solo"
	Case cCultur == "A"
		Return "Algodao"
	Case cCultur == "B"
		Return "Cobertura"
	Case cCultur == "C"
		Return "Milho"
	Case cCultur == "D"
		Return "Pastagem"
	Case cCultur == "E"
		Return "Soja"
	Case cCultur == "F"
		Return "Soja Semente"
	Case cCultur == "G"
		Return "Cafe"
	Case cCultur == "H"
		Return "Eucalipto"
	EndCase

Return ""

// Retorna as tecnologias disponiveis para o planejamento.
Static Function ZZJVAR()
	Local aRet := {}

	AAdd(aRet, { "", "B" })
	AAdd(aRet, { "", "H" })
	If ZZJPACOK("S")
		AAdd(aRet, { "", "S" })
	EndIf

	AAdd(aRet, { "B3RF", "A" })
	AAdd(aRet, { "GLTP", "A" })
	AAdd(aRet, { "B3XF", "A" })
	AAdd(aRet, { "STP", "A" })
	AAdd(aRet, { "GLT", "A" })

	AAdd(aRet, { "CONKESTA INLIST", "E" })
	AAdd(aRet, { "I2X", "E" })
	AAdd(aRet, { "IPRO", "E" })
	AAdd(aRet, { "CONVENCIONAL", "E" })
	AAdd(aRet, { "CONKESTA INLIST", "F" })
	AAdd(aRet, { "I2X", "F" })
	AAdd(aRet, { "IPRO", "F" })
	AAdd(aRet, { "CONVENCIONAL", "F" })

	AAdd(aRet, { "VIP3", "C" })
	AAdd(aRet, { "PRO3", "C" })
	AAdd(aRet, { "PRO4", "C" })
	AAdd(aRet, { "PWU", "C" })
	AAdd(aRet, { "VYHR", "C" })

Return aRet


// Retorna os pacotes disponiveis para o planejamento.
Static Function ZZJPAC(cCult)
	Local aRet := {}
	Local lFiltro := PCount() > 0

	Default cCult := ""
	cCult := Upper(AllTrim(cValToChar(cCult)))

	If !lFiltro .Or. cCult <> "S"
		AAdd(aRet, { "D", "Dessecacao Pre Plantio" })
		AAdd(aRet, { "B", "Adubacao de Base" })
		AAdd(aRet, { "T", "Tratamento de Semente" })
		AAdd(aRet, { "E", "Pre Emergente" })
		AAdd(aRet, { "P", "Pos Emergente" })
		AAdd(aRet, { "C", "Adubacao de Cobertura" })
		AAdd(aRet, { "F", "Adubo Foliar" })
		AAdd(aRet, { "I", "Fungicida/Inseticida" })
		AAdd(aRet, { "R", "Regulador de Crescimento" })
		AAdd(aRet, { "M", "Maturador" })
		AAdd(aRet, { "Q", "Destruicao de Soqueira" })
		AAdd(aRet, { "L", "Desfolha" })
	EndIf

	If (!lFiltro .Or. cCult == "S") .And. (!lFiltro .Or. ZZJPACOK("S"))
		AAdd(aRet, { "S", "Corretivos de Solo" })
		AAdd(aRet, { "A", "Adubacao de Correcao" })
	EndIf

Return aRet

// Restringe os pacotes especiais aos usuarios autorizados, exceto administradores.
Static Function ZZJPACOK(cPac)
	Local aUsrAut := { "000560", "000095", "000416" }
	Local cUsr    := AllTrim(cValToChar(__cUserID))

	cPac := Upper(AllTrim(cValToChar(cPac)))
	If !(cPac == "S" .Or. cPac == "A")
		Return .T.
	EndIf

	If FwIsAdmin()
		Return .T.
	EndIf

Return AScan(aUsrAut, {|cUsrAut| cUsrAut == cUsr}) > 0

// Garante que os pacotes de solo sejam usados apenas em Preparo de Solo.
Static Function ZZJPACCTXOK(cPac, cCult)
	cPac  := Upper(AllTrim(cValToChar(cPac)))
	cCult := Upper(AllTrim(cValToChar(cCult)))

	If cPac == "S" .Or. cPac == "A"
		Return cCult == "S" .And. ZZJPACOK(cPac)
	EndIf

Return cCult <> "S"

// Retorna os anos safra disponiveis para o planejamento.
Static Function ZZJSAF()
	Local aRet  := ZZJSF3()
	Local nAno  := Year(Date())

	If Len(aRet) == 0
		aRet := ZZJOPT("ZZJ_SAFRA")
	EndIf

	If Len(aRet) == 0
		AAdd(aRet, { AllTrim(Str(nAno)) + "/" + AllTrim(Str(nAno + 1)), AllTrim(Str(nAno)) + "/" + AllTrim(Str(nAno + 1)) })
		AAdd(aRet, { AllTrim(Str(nAno + 1)) + "/" + AllTrim(Str(nAno + 2)), AllTrim(Str(nAno + 1)) + "/" + AllTrim(Str(nAno + 2)) })
		AAdd(aRet, { AllTrim(Str(nAno + 2)) + "/" + AllTrim(Str(nAno + 3)), AllTrim(Str(nAno + 2)) + "/" + AllTrim(Str(nAno + 3)) })
	EndIf

Return aRet

// Retorna anos safra consultando a tabela definida no X3_F3 de ZZJ_SAFRA.
Static Function ZZJSF3()
	Local aRet    := {}
	Local cF3     := Upper(AllTrim(cValToChar(GetSx3Cache("ZZJ_SAFRA", "X3_F3"))))
	Local cCodFld := ""
	Local cDscFld := ""
	Local cAlias  := GetNextAlias()
	Local cQuery  := ""

	If Empty(cF3)
		Return aRet
	EndIf

	cCodFld := ZZJFLDX(cF3, { "CODSAF", "CODIGO", "COD" })
	cDscFld := ZZJFLDX(cF3, { "DESCRI", "DESC", "NOME" })

	If Empty(cCodFld) .Or. Empty(cDscFld)
		Return aRet
	EndIf

	cQuery := " SELECT " + cCodFld + " ZCOD, " + cDscFld + " ZDESC "
	cQuery += " FROM " + RetSqlName(cF3)
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND " + cF3 + "_FILIAL IN ('', '" + xFilial(cF3) + "') "
	cQuery += " ORDER BY " + cDscFld + " DESC "

	MpSysOpenQuery(cQuery, cAlias)
	While !(cAlias)->(Eof())
		If !Empty(AllTrim((cAlias)->ZCOD))
			AAdd(aRet, { AllTrim((cAlias)->ZCOD), AllTrim((cAlias)->ZDESC) })
		EndIf
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

Return aRet

// Localiza um campo da tabela F3 usando os nomes existentes na SX3.
Static Function ZZJFLDX(cTab, aSuf)
	Local cRet := ""
	Local cFld := ""
	Local nI   := 0

	For nI := 1 To Len(aSuf)
		cFld := AllTrim(cTab) + "_" + aSuf[nI]
		If !Empty(AllTrim(cValToChar(GetSx3Cache(cFld, "X3_CAMPO"))))
			cRet := cFld
			Exit
		EndIf
	Next

Return cRet

// Retorna as descricoes de uma lista codigo/descricao.
Static Function ZZJDSC(aItens)
	Local aRet := {}
	Local nI   := 0

	For nI := 1 To Len(aItens)
		AAdd(aRet, aItens[nI, 2])
	Next

Return aRet

// Monta opcoes a partir do X3_CBOX de um campo.
Static Function ZZJOPT(cField)
	Local cCbox  := AllTrim(cValToChar(GetSx3Cache(cField, "X3_CBOX")))
	Local aItens := {}
	Local aPart  := {}
	Local nI     := 0
	Local cItem  := ""
	Local nPos   := 0
	Local cCode  := ""
	Local cDesc  := ""

	If Empty(cCbox)
		Return aItens
	EndIf

	aPart := StrTokArr(cCbox, ";")

	For nI := 1 To Len(aPart)
		cItem := AllTrim(aPart[nI])
		If Empty(cItem)
			Loop
		EndIf

		nPos := At("=", cItem)
		If nPos > 0
			cCode := AllTrim(Left(cItem, nPos - 1))
			cDesc := AllTrim(SubStr(cItem, nPos + 1))
		Else
			cCode := cItem
			cDesc := cItem
		EndIf

		If !Empty(cCode)
			AAdd(aItens, { cCode, cDesc })
		EndIf
	Next

Return aItens


