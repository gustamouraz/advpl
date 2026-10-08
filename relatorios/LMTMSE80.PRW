#Include "Protheus.ch"
#Include "TOPConn.ch"
#Include "FILEIO.ch"

/*/{Protheus.doc} LMTMSE80
Importador simplificado de XML de NF-e para acervo historico do TMS.
Le XMLs em XMLNFE\NEW, grava a DE5 sem as validacoes comerciais da
TMSAE80 e move os arquivos para OLD ou ERR.
@type function
@author Masutti
@since 02/09/2026
/*/
User Function LMTMSE80(aParam, cParEmp, cParFil, aNFs)
	Local aFiles  := {}
	Local nFile   := 0
	Local cBase   := ""
	Local cNew    := ""
	Local cOld    := ""
	Local cErr    := ""
	Local lEnvSet := .F.
	Local cMsg    := ""
	Local aRet    := {}
	Local lOk     := .F.
	Local lMove   := .F.

	Default aParam  := {}
	Default cParEmp := ""
	Default cParFil := ""
	Default aNFs    := {}

	If IsSrvUnix()
		cBase := "xmlnfe/"
		cNew  := cBase + "new/"
		cOld  := cBase + "old/"
		cErr  := cBase + "err/"
	Else
		cBase := "XMLNFE\\"
		cNew  := cBase + "NEW\\"
		cOld  := cBase + "OLD\\"
		cErr  := cBase + "ERR\\"
	EndIf

	If IsBlind()
		If !Empty(cParEmp) .And. !Empty(cParFil)
			aParam := { cParEmp, cParFil }
		EndIf
		If ValType(aParam) != "A" .Or. Len(aParam) < 2
			ConOut("LMTMSE80: empresa e filial nao informadas para a execucao em background.")
			Return aRet
		EndIf
		RpcSetType(3)
		lEnvSet := RpcSetEnv(aParam[1], aParam[2], , , "TMS", "LMTMSE80")
		If !lEnvSet
			Return aRet
		EndIf
	EndIf

	If !ExistDir(cBase)
		MakeDir(cBase)
	EndIf
	If !ExistDir(cNew)
		MakeDir(cNew)
	EndIf
	If !ExistDir(cOld)
		MakeDir(cOld)
	EndIf
	If !ExistDir(cErr)
		MakeDir(cErr)
	EndIf

	// No reprocessamento a DEV ja informa os nomes. Montar a lista diretamente
	// evita que uma diferenca de raiz do AppServer no Directory() deixe XMLs em
	// NEW sem serem lidos. Sem lista informada, localiza todos os XMLs em NEW.
	If Len(aNFs) > 0
		For nFile := 1 To Len(aNFs)
			If !Empty(AllTrim(cValToChar(aNFs[nFile])))
				AAdd(aFiles, {AllTrim(cValToChar(aNFs[nFile]))})
			EndIf
		Next
	ElseIf IsSrvUnix()
		aFiles := Directory(cNew + "*.xml", , , .F.)
		If Empty(aFiles)
			aFiles := Directory("/" + cNew + "*.xml", , , .F.)
		EndIf
	Else
		aFiles := Directory(cNew + "*.xml")
		If Empty(aFiles)
			aFiles := Directory("\\" + cNew + "*.xml")
		EndIf
	EndIf

	For nFile := 1 To Len(aFiles)
		cMsg := ""
		lOk := .F.
		lMove := .F.
		If !File(cNew + aFiles[nFile, 1], , .F.)
			AAdd(aRet, {aFiles[nFile, 1], "NLOCAL", "Arquivo nao localizado em XMLNFE\\NEW."})
		ElseIf !LockByName(aFiles[nFile, 1], .T., .F.)
			AAdd(aRet, {aFiles[nFile, 1], "BLOQ", "Arquivo bloqueado por outro processo."})
		Else
			lOk := LMT80IMP(cNew + aFiles[nFile, 1], aFiles[nFile, 1], @cMsg)
			If lOk
				lMove := __CopyFile(cNew + aFiles[nFile, 1], cOld + aFiles[nFile, 1], , , .F.)
				If lMove
					FErase(cNew + aFiles[nFile, 1], , .F.)
					AAdd(aRet, {aFiles[nFile, 1], "OK", "Gravado na DE5."})
				Else
					AAdd(aRet, {aFiles[nFile, 1], "OK", "Gravado na DE5; nao foi possivel mover o XML para OLD."})
				EndIf
			Else
				lMove := __CopyFile(cNew + aFiles[nFile, 1], cErr + aFiles[nFile, 1], , , .F.)
				If lMove
					FErase(cNew + aFiles[nFile, 1], , .F.)
				EndIf
				AAdd(aRet, {aFiles[nFile, 1], "ERRO", cMsg})
			EndIf
			UnLockByName(aFiles[nFile, 1], .T., .F.)
		EndIf
	Next

	If lEnvSet
		RpcClearEnv()
	EndIf

Return aRet

// Le, interpreta e grava uma NF-e. Apenas dados indispensaveis ao CT-e/MDF-e
// sao exigidos; contrato, perfil, cliente e sequencia DUL nao sao validados.
Static Function LMT80IMP(cPath, cFile, cMsg)
	Local cXml     := ""
	Local cXmlOri  := ""
	Local cXmlU    := ""
	Local cInfXml  := ""
	Local cIdeXml  := ""
	Local cEmitXml := ""
	Local cDestXml := ""
	Local cTrpXml  := ""
	Local cTotXml  := ""
	Local cPrdXml  := ""
	// Local cWarn    := ""
	// Local cParseEr := ""
	// Local oRoot    := Nil
	// Local oNfe     := Nil
	// Local oInf     := Nil
	// Local oIde     := Nil
	// Local oEmit    := Nil
	// Local oDest    := Nil
	// Local oTransp  := Nil
	// Local oTotal   := Nil
	// Local oIcmsTot := Nil
	// Local oDet     := Nil
	// Local oProd    := Nil
	Local cRem     := ""
	Local cDes     := ""
	Local cDoc     := ""
	Local cSerie   := ""
	Local cChave   := ""
	Local cCfop    := ""
	Local cFrete   := ""
	Local cProdGen := AllTrim(SuperGetMV("MV_PROGEN", .F., ""))
	Local cEmb     := ""
	Local dEmis    := CToD("//")
	Local nValor   := 0
	Local nQtdVol  := 0
	Local nPesoB   := 0
	Local nPesoL   := 0
	// Local cDetalhe := ""
	Local cChvDE5  := ""

	cXmlOri := MemoRead(cPath)
	If Empty(cXmlOri)
		cMsg := "Arquivo XML vazio ou nao acessivel."
		TMSAE80Grv(cFile, "", "", "", "", "Leitura do XML", cMsg)
		Return .F.
	EndIf

	// A leitura direta das tags elimina a dependencia do XmlParser, que pode
	// recusar NF-e 4.00 validas conforme a codificacao do AppServer.
	cXml := cXmlOri
	cXmlU := Upper(cXml)
	cChave := LMT80CHV(cXmlOri)

	cInfXml  := LMT80BLK(cXml, cXmlU, "INFNFE")
	cIdeXml  := LMT80BLK(cXml, cXmlU, "IDE")
	cEmitXml := LMT80BLK(cXml, cXmlU, "EMIT")
	cDestXml := LMT80BLK(cXml, cXmlU, "DEST")
	cTrpXml  := LMT80BLK(cXml, cXmlU, "TRANSP")
	cTotXml  := LMT80BLK(cXml, cXmlU, "ICMSTOT")
	cPrdXml  := LMT80BLK(cXml, cXmlU, "PROD")

	cRem   := LMT80TAG(cEmitXml, "CNPJ")
	cRem   := IIf(Empty(cRem), LMT80TAG(cEmitXml, "CPF"), cRem)
	cDes   := LMT80TAG(cDestXml, "CNPJ")
	cDes   := IIf(Empty(cDes), LMT80TAG(cDestXml, "CPF"), cDes)
	cDoc   := StrZero(Val(LMT80TAG(cIdeXml, "NNF")), TamSx3("F1_DOC")[1])
	cSerie := AllTrim(LMT80TAG(cIdeXml, "SERIE"))
	cCfop  := AllTrim(LMT80TAG(cPrdXml, "CFOP"))
	cFrete := AllTrim(LMT80TAG(cTrpXml, "MODFRETE"))
	nValor := LMT80NUM(LMT80TAG(cTotXml, "VNF"))
	dEmis  := LMT80DAT(LMT80TAG(cIdeXml, "DHEMI"), LMT80TAG(cIdeXml, "DEMI"))
	LMT80VOLXML(cTrpXml, @nQtdVol, @nPesoB, @nPesoL)

	If Empty(cRem) .Or. Empty(cDes) .Or. Empty(cDoc) .Or. Empty(cSerie) .Or. ;
		Empty(cChave) .Or. Empty(cCfop) .Or. nValor <= 0 .Or. Empty(dEmis)
		cMsg := "Dados obrigatorios ausentes: emitente, destinatario, NF, serie, chave, CFOP, emissao ou valor."
		TMSAE80Grv(cFile, cChave, cDoc, cSerie, cRem, "Dados minimos da NF-e", cMsg)
		Return .F.
	EndIf

	If !cFrete $ "01"
		cMsg := "Modalidade de frete invalida para geracao do CT-e: " + cFrete
		TMSAE80Grv(cFile, cChave, cDoc, cSerie, cRem, "Frete da NF-e", cMsg)
		Return .F.
	EndIf

	If Empty(cProdGen) .Or. !LMT80PRD(cProdGen, @cEmb)
		cMsg := "Produto generico MV_PROGEN nao informado ou nao localizado na SB1."
		TMSAE80Grv(cFile, cChave, cDoc, cSerie, cRem, "Produto generico", cMsg)
		Return .F.
	EndIf

	DbSelectArea("DE5")
	DE5->(DbSetOrder(1))
	// DbSeek pode posicionar no proximo registro quando o SOFTSEEK estiver
	// habilitado. Confirma a igualdade da chave completa antes de bloquear
	// a importacao como duplicidade.
	cChvDE5 := xFilial("DE5") + ;
		PadR(cRem, Len(DE5->DE5_CGCREM)) + ;
		PadR(cDoc, Len(DE5->DE5_DOC)) + ;
		PadR(cSerie, Len(DE5->DE5_SERIE))
	If DE5->(DbSeek(cChvDE5)) .And. ;
		DE5->(DE5_FILIAL + DE5_CGCREM + DE5_DOC + DE5_SERIE) == cChvDE5
		cMsg := "Nota fiscal ja existente na DE5."
		TMSAE80Grv(cFile, cChave, cDoc, cSerie, cRem, "Duplicidade", cMsg)
		Return .F.
	EndIf

	If !RecLock("DE5", .T.)
		cMsg := "Nao foi possivel bloquear a DE5 para inclusao."
		TMSAE80Grv(cFile, cChave, cDoc, cSerie, cRem, "Gravacao EDI", cMsg)
		Return .F.
	EndIf

	LMT80PUT("DE5_FILIAL", xFilial("DE5"))
	LMT80PUT("DE5_CGCREM", cRem)
	LMT80PUT("DE5_CGCDES", cDes)
	LMT80PUT("DE5_CGCDEV", IIf(cFrete == "0", cRem, cDes))
	LMT80PUT("DE5_DTAEMB", dDataBase)
	LMT80PUT("DE5_TIPFRE", IIf(cFrete == "0", "1", "2"))
	LMT80PUT("DE5_TIPTRA", "1")
	LMT80PUT("DE5_DOC", cDoc)
	LMT80PUT("DE5_SERIE", cSerie)
	LMT80PUT("DE5_EMINFC", dEmis)
	LMT80PUT("DE5_NFEID", cChave)
	LMT80PUT("DE5_CFOPNF", cCfop)
	LMT80PUT("DE5_CODPRO", cProdGen)
	LMT80PUT("DE5_CODEMB", cEmb)
	LMT80PUT("DE5_QTDVOL", nQtdVol)
	LMT80PUT("DE5_VALOR", nValor)
	LMT80PUT("DE5_PESO", Max(nPesoB, nPesoL))
	LMT80PUT("DE5_PESLIQ", nPesoL)
	// A TMSA050 lista somente notas EDI em aberto (DE5_STATUS = "1").
	// O status "2" representa documento ja encerrado e impede a selecao.
	LMT80PUT("DE5_STATUS", "1")
	LMT80PUT("DE5_STAUTO", "0")
	LMT80PUT("DE5_EDIAUT", "0")
	LMT80PUT("DE5_EDILOT", "0")
	LMT80PUT("DE5_EDIFRT", "0")
	DE5->(MsUnlock())
	DE5->(DbCommit())

Return .T.

// Retorna um no XML sem gerar erro para tags ausentes.
Static Function LMT80NOD(oPai, cTag)
	If ValType(oPai) != "O"
		Return Nil
	EndIf
Return XmlChildEx(oPai, "_" + Upper(cTag))

// Retorna o conteudo textual de uma tag ou atributo XML.
Static Function LMT80VAL(oPai, cTag)
	Local oTag := LMT80NOD(oPai, cTag)

	If ValType(oTag) == "O"
		Return AllTrim(cValToChar(oTag:Text))
	EndIf
Return ""

// Retorna CNPJ ou CPF do participante da NF-e.
Static Function LMT80DOC(oPessoa)
	Local cDoc := LMT80VAL(oPessoa, "CNPJ")

	If Empty(cDoc)
		cDoc := LMT80VAL(oPessoa, "CPF")
	EndIf
Return cDoc

// Converte numero do XML, cujo separador decimal e ponto.
Static Function LMT80NUM(cVal)
Return Val(StrTran(AllTrim(cValToChar(cVal)), ",", "."))

// Retorna a data de emissao, atendendo leiautes que usam dhEmi ou dEmi.
Static Function LMT80DAT(cDhEmi, cDEmi)
	Local cData := IIf(!Empty(cDhEmi), Left(cDhEmi, 10), cDEmi)

	If Empty(cData)
		Return CToD("//")
	EndIf
Return SToD(StrTran(cData, "-", ""))

// Recupera a chave de acesso diretamente do XML para erros anteriores ao parser.
Static Function LMT80CHV(cXml)
	Local cBusca := Upper(cXml)
	Local nPos  := At('ID="NFE', cBusca)

	If nPos > 0
		Return SubStr(cXml, nPos + 7, 44)
	EndIf
Return ""

// Retorna o conteudo interno da primeira tag informada, preservando o XML
// original para que valores acentuados nao sofram conversao.
Static Function LMT80BLK(cXml, cXmlU, cTag)
	Local cTagU  := Upper(cTag)
	Local nIni   := At("<" + cTagU, cXmlU)
	Local nAbre  := 0
	Local nFecha := 0
	Local cResto := ""

	If nIni == 0
		Return ""
	EndIf
	cResto := SubStr(cXmlU, nIni)
	nAbre := At(">", cResto)
	If nAbre == 0
		Return ""
	EndIf
	cResto := SubStr(cResto, nAbre + 1)
	nFecha := At("</" + cTagU + ">", cResto)
	If nFecha == 0
		Return ""
	EndIf
Return SubStr(cXml, nIni + nAbre, nFecha - 1)

// Recupera uma tag simples em um bloco XML ja delimitado.
Static Function LMT80TAG(cXml, cTag)
	Local cXmlU  := Upper(cXml)
	Local cTagU  := Upper(cTag)
	Local nIni   := At("<" + cTagU + ">", cXmlU)
	Local nFim   := 0
	Local cResto := ""

	If nIni == 0
		Return ""
	EndIf
	cResto := SubStr(cXml, nIni + Len(cTagU) + 2)
	nFim := At("</" + cTagU + ">", Upper(cResto))
	If nFim == 0
		Return ""
	EndIf
Return AllTrim(Left(cResto, nFim - 1))

// Soma volumes e pesos sem depender do objeto retornado pelo XmlParser.
Static Function LMT80VOLXML(cXml, nQtdVol, nPesoB, nPesoL)
	Local cResto := cXml
	Local cVol   := ""
	Local nIni   := 0
	Local nAbre  := 0
	Local nFim   := 0

	nIni := At("<VOL>", Upper(cResto))
	While nIni > 0
		cResto := SubStr(cResto, nIni)
		nAbre := At(">", cResto)
		nFim := At("</VOL>", Upper(cResto))
		If nAbre == 0 .Or. nFim == 0
			Exit
		EndIf
		cVol := SubStr(cResto, nAbre + 1, nFim - nAbre - 1)
		nQtdVol += LMT80NUM(LMT80TAG(cVol, "QVOL"))
		nPesoB  += LMT80NUM(LMT80TAG(cVol, "PESOB"))
		nPesoL  += LMT80NUM(LMT80TAG(cVol, "PESOL"))
		cResto := SubStr(cResto, nFim + 6)
		nIni := At("<VOL>", Upper(cResto))
	EndDo
Return Nil

// Soma quantidade de volumes e pesos de todas as tags vol da NF-e.
Static Function LMT80VOL(oTransp, nQtdVol, nPesoB, nPesoL)
	Local oVol := LMT80NOD(oTransp, "VOL")
	Local nX   := 0

	If ValType(oVol) == "O"
		nQtdVol += LMT80NUM(LMT80VAL(oVol, "QVOL"))
		nPesoB  += LMT80NUM(LMT80VAL(oVol, "PESOB"))
		nPesoL  += LMT80NUM(LMT80VAL(oVol, "PESOL"))
	ElseIf ValType(oVol) == "A"
		For nX := 1 To Len(oVol)
			nQtdVol += LMT80NUM(LMT80VAL(oVol[nX], "QVOL"))
			nPesoB  += LMT80NUM(LMT80VAL(oVol[nX], "PESOB"))
			nPesoL  += LMT80NUM(LMT80VAL(oVol[nX], "PESOL"))
		Next
	EndIf
Return Nil

// Valida somente a existencia do produto generico e retorna sua unidade.
Static Function LMT80PRD(cProd, cEmb)
	Local aArea := GetArea()
	Local nTam  := TamSx3("B1_COD")[1]
	Local lRet  := .F.

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	lRet := SB1->(MsSeek(xFilial("SB1") + PadR(cProd, nTam)))
	If !lRet
		lRet := SB1->(MsSeek(PadR(cProd, nTam)))
	EndIf
	If lRet .And. !SB1->(Deleted()) .And. AllTrim(SB1->B1_MSBLQL) != "1"
		cEmb := SB1->B1_UM
	Else
		lRet := .F.
	EndIf
	RestArea(aArea)
Return lRet

// Atribui apenas campos presentes no dicionario da DE5, mantendo a rotina
// compativel com releases que ainda nao possuam campos mais novos.
Static Function LMT80PUT(cCampo, xValor)
	Local nPos := FieldPos(cCampo)

	If nPos > 0
		FieldPut(nPos, xValor)
	EndIf
Return Nil
