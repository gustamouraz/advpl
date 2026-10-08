#Include "Protheus.ch"
#Include "FWMVCDEF.ch"
#Include "FILEIO.ch"

Static oLMT85Mark := Nil

/*/{Protheus.doc} LMTMSE85
Monitor customizado de notas rejeitadas pela LMTMSE80.
Permite selecionar registros DEV e reprocessa-los pelo importador simplificado.
@type function
@author Masutti
@since 02/09/2026
/*/
User Function LMTMSE85()
	If xFilial("DEV") != "0201"
		MsgStop("A LMTMSE85 deve ser executada na empresa/filial 02/01. Contexto atual: " + xFilial("DEV"), "Importador simplificado")
		Return Nil
	EndIf

	oLMT85Mark := FWMarkBrowse():New()
	oLMT85Mark:SetAlias("DEV")
	oLMT85Mark:SetSemaphore(.T.)
	oLMT85Mark:SetDescription("NF-e nao importadas - Importador simplificado")
	oLMT85Mark:SetFieldMark("DEV_OK")
	// Habilita o botao/atalho de marcar todos do FWMarkBrowse. A marcacao
	// respeita o filtro corrente, portanto atua somente nos itens em tela.
	oLMT85Mark:SetAllMark({|| LMT85MRKALL()})
	oLMT85Mark:SetFilterDefault("DEV_STATUS == '1'")
	oLMT85Mark:Activate()

Return Nil

// Define a acao de reprocessamento para os registros marcados na DEV.
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Reprocessar selecionadas" ACTION "U_LMT85PRC()" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar motivo do erro" ACTION "U_LMT85VIS(Recno())" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Processar XMLs em NEW" ACTION "U_LMT85NEW()" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Marcar/desmarcar todos em tela" ACTION "U_LMT85MKT()" OPERATION 2 ACCESS 0

Return aRotina

// Acao publica para disponibilizar a marcacao total no menu Outras Acoes.
User Function LMT85MKT()
	LMT85MRKALL()
Return Nil

// Usa a marcacao nativa do FWMarkBrowse, que respeita o filtro e a grade atual.
Static Function LMT85MRKALL()
	If ValType(oLMT85Mark) == "O"
		oLMT85Mark:AllMark()
	EndIf

Return Nil

/*/{Protheus.doc} LMT85VIS
Exibe os detalhes do registro DEV, incluindo motivo e detalhe tecnico do erro.
@type function
/*/
User Function LMT85VIS(nRecno)
	Local aVisualiza := {}
	Local aCampos    := {}
	Local nCampo     := 0

	Default nRecno := 0
	If Empty(nRecno)
		Return Nil
	EndIf

	// DEV_MOTERR e DEV_DETERR permanecem no array e sao exibidos no AxVisual.
	aCampos := ApBuildHeader("DEV", {"DEV_OK", "DEV_STATUS"})
	For nCampo := 1 To Len(aCampos)
		AAdd(aVisualiza, aCampos[nCampo, 2])
	Next
	AxVisual("DEV", nRecno, 2, aVisualiza)

Return Nil

/*/{Protheus.doc} LMT85NEW
Reexecuta a LMTMSE80 para os XMLs que ficaram na pasta NEW. Esta acao permite
retomar lotes que ja receberam DEV_STATUS 3 em tentativa anterior.
@type function
/*/
User Function LMT85NEW()
	Local aRet      := U_LMTMSE80()
	Local nRet      := 0
	Local nOk       := 0
	Local nErro     := 0
	Local nPendente := 0

	If ValType(aRet) != "A" .Or. Empty(aRet)
		MsgInfo("Nenhum XML foi localizado em XMLNFE\\NEW.", "Importador simplificado")
		Return Nil
	EndIf

	For nRet := 1 To Len(aRet)
		Do Case
		Case aRet[nRet, 2] == "OK"
			nOk++
		Case aRet[nRet, 2] == "ERRO"
			nErro++
		Otherwise
			nPendente++
		EndCase
	Next
	MsgInfo("Resultado do processamento em NEW:" + CRLF + ;
		"Gravados na DE5: " + cValToChar(nOk) + CRLF + ;
		"Rejeitados: " + cValToChar(nErro) + CRLF + ;
		"Nao localizados/bloqueados: " + cValToChar(nPendente), "Importador simplificado")

	If ValType(oLMT85Mark) == "O"
		oLMT85Mark:Refresh()
	EndIf

Return Nil

/*/{Protheus.doc} LMT85PRC
Move XMLs selecionados da ERR para NEW e chama LMTMSE80 somente para eles.
@type function
/*/
User Function LMT85PRC()
	Local aArea    := GetArea()
	Local cMarca   := ""
	Local aDoctos  := {}
	Local aArqs    := {}
	Local nDocto  := 0
	Local cBase   := ""
	Local cNew    := ""
	Local cErr    := ""
	Local nMovidos := 0
	Local aRet     := {}
	Local nRet     := 0
	Local nOk      := 0
	Local nErro    := 0
	Local nPendente := 0

	If ValType(oLMT85Mark) != "O"
		MsgStop("Abra a rotina LMTMSE85 antes de reprocessar as notas.", "Importador simplificado")
		Return Nil
	EndIf

	If IsSrvUnix()
		cBase := "xmlnfe/"
		cNew  := cBase + "new/"
		cErr  := cBase + "err/"
	Else
		cBase := "XMLNFE\\"
		cNew  := cBase + "NEW\\"
		cErr  := cBase + "ERR\\"
	EndIf

	If !ExistDir(cBase)
		MakeDir(cBase)
	EndIf
	If !ExistDir(cNew)
		MakeDir(cNew)
	EndIf
	If !ExistDir(cErr)
		MakeDir(cErr)
	EndIf

	cMarca := oLMT85Mark:Mark()
	DbSelectArea("DEV")
	DEV->(DbSetOrder(2))
	If DEV->(DbSeek(xFilial("DEV") + "1"))
		While !DEV->(Eof()) .And. DEV->DEV_STATUS == "1"
			If oLMT85Mark:IsMark(cMarca)
				AAdd(aDoctos, { DEV->(RecNo()), AllTrim(DEV->DEV_ARQUIV) })
			EndIf
			DEV->(DbSkip())
		EndDo
	EndIf

	For nDocto := 1 To Len(aDoctos)
		If File(cErr + aDoctos[nDocto, 2], , .F.)
			If __CopyFile(cErr + aDoctos[nDocto, 2], cNew + aDoctos[nDocto, 2], , , .F.)
				FErase(cErr + aDoctos[nDocto, 2], , .F.)
				DEV->(DbGoTo(aDoctos[nDocto, 1]))
				If !DEV->(Eof()) .And. RecLock("DEV", .F.)
					DEV->DEV_STATUS := "3"
					DEV->(MsUnlock())
				EndIf
				If AScan(aArqs, {|cArq| Upper(AllTrim(cArq)) == Upper(AllTrim(aDoctos[nDocto, 2]))}) == 0
					AAdd(aArqs, aDoctos[nDocto, 2])
					nMovidos++
				EndIf
			Else
				LMT85ERR(aDoctos[nDocto, 1], "Reprocessamento", "Nao foi possivel mover o XML da pasta ERR para NEW.")
			EndIf
		ElseIf File(cNew + aDoctos[nDocto, 2], , .F.)
			// O XML ja foi encaminhado em uma tentativa anterior e permaneceu
			// em NEW. Reenvia diretamente ao importador, sem exigir a pasta ERR.
			DEV->(DbGoTo(aDoctos[nDocto, 1]))
			If !DEV->(Eof()) .And. RecLock("DEV", .F.)
				DEV->DEV_STATUS := "3"
				DEV->(MsUnlock())
			EndIf
			If AScan(aArqs, {|cArq| Upper(AllTrim(cArq)) == Upper(AllTrim(aDoctos[nDocto, 2]))}) == 0
				AAdd(aArqs, aDoctos[nDocto, 2])
				nMovidos++
			EndIf
		Else
			LMT85ERR(aDoctos[nDocto, 1], "Reprocessamento", ;
				"Arquivo nao localizado nas pastas XMLNFE\\ERR ou XMLNFE\\NEW: " + aDoctos[nDocto, 2])
			MsgAlert("Arquivo nao localizado nas pastas ERR ou NEW: " + aDoctos[nDocto, 2], "Importador simplificado")
		EndIf
	Next

	If Len(aArqs) > 0
		aRet := U_LMTMSE80(Nil, Nil, Nil, aArqs)
		If ValType(aRet) == "A"
			For nRet := 1 To Len(aRet)
				Do Case
				Case aRet[nRet, 2] == "OK"
					nOk++
				Case aRet[nRet, 2] == "ERRO"
					nErro++
				Otherwise
					nPendente++
				EndCase
			Next
		Else
			nPendente := nMovidos
		EndIf
		MsgInfo("Resultado do reprocessamento:" + CRLF + ;
			"Selecionados: " + cValToChar(nMovidos) + CRLF + ;
			"Gravados na DE5: " + cValToChar(nOk) + CRLF + ;
			"Rejeitados: " + cValToChar(nErro) + CRLF + ;
			"Nao localizados/bloqueados: " + cValToChar(nPendente), "Importador simplificado")
	Else
		MsgInfo("Nenhum XML marcado foi localizado na pasta ERR.", "Importador simplificado")
	EndIf

	If ValType(oLMT85Mark) == "O"
		oLMT85Mark:Refresh()
	EndIf
	RestArea(aArea)

Return Nil

// Atualiza o proprio registro DEV quando o XML nao chega ao importador.
Static Function LMT85ERR(nRecno, cMotivo, cDetalhe)
	Local aArea := GetArea()

	DbSelectArea("DEV")
	DEV->(DbGoTo(nRecno))
	If !DEV->(Eof()) .And. RecLock("DEV", .F.)
		DEV->DEV_STATUS := "1"
		DEV->DEV_MOTERR := cMotivo
		DEV->DEV_DETERR := cDetalhe
		DEV->DEV_DATIMP := dDataBase
		DEV->DEV_HORIMP := StrTran(Left(Time(), 5), ":", "")
		DEV->(MsUnlock())
	EndIf
	RestArea(aArea)

Return Nil
