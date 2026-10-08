#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} LMCPCO01
Consulta os movimentos de baixa de estoque elegiveis para o processo PCO
000151. A rotina e somente consultiva: nao inclui, altera ou exclui registros.

@type  User Function
@author TOTVS Customizacao
@since  07/10/2026
@version 1.0
/*/
User Function LMCPCO01()
	Local aArea   := GetArea()
	Local nTamFil := TamSX3("D3_FILIAL")[1]
	Local nTamCC  := TamSX3("D3_CC")[1]
	Local nTamCod := TamSX3("D3_COD")[1]
	Local nTamGrp := TamSX3("B1_GRUPO")[1]
	Local nTamCta := TamSX3("B1_RCONTA")[1]
	Local cFilDe  := Space(nTamFil)
	Local cFilAte := Replicate("Z", nTamFil)
	Local dEmiDe  := dDataBase
	Local dEmiAte := dDataBase
	Local cCCDe   := Space(nTamCC)
	Local cCCAte  := Replicate("Z", nTamCC)
	Local cCodDe  := Space(nTamCod)
	Local cCodAte := Replicate("Z", nTamCod)
	Local cGrpDe  := Space(nTamGrp)
	Local cGrpAte := Replicate("Z", nTamGrp)
	Local cCtaDe  := Space(nTamCta)
	Local cCtaAte := Replicate("Z", nTamCta)
	Local oDlg    := Nil
	Local oGrid   := Nil
	Local oGetFilDe  := Nil
	Local oGetFilAte := Nil
	Local oGetEmiDe  := Nil
	Local oGetEmiAte := Nil
	Local oGetCCDe   := Nil
	Local oGetCCAte  := Nil
	Local oGetCodDe  := Nil
	Local oGetCodAte := Nil
	Local oGetGrpDe  := Nil
	Local oGetGrpAte := Nil
	Local oGetCtaDe  := Nil
	Local oGetCtaAte := Nil
	Local aHead   := LmcPcoCabecalho()
	Local aCols   := {LmcPcoLinhaVazia()}

	DEFINE MSDIALOG oDlg TITLE "Consulta PCO - Baixas de estoque" FROM 000, 000 TO 600, 1299 PIXEL
		@ 003, 003 SAY "Filtros" OF oDlg SIZE 125, 497 PIXEL

		@ 013, 006 SAY "Filial de" OF oDlg SIZE 035, 009 PIXEL
		@ 010, 045 MSGET oGetFilDe  VAR cFilDe  SIZE 050, 010 OF oDlg F3 "SM0" PIXEL
		@ 013, 105 SAY "Filial ate" OF oDlg SIZE 035, 009 PIXEL
		@ 010, 145 MSGET oGetFilAte VAR cFilAte SIZE 050, 010 OF oDlg F3 "SM0" PIXEL
		@ 013, 205 SAY "Emissao de" OF oDlg SIZE 040, 009 PIXEL
		@ 010, 250 MSGET oGetEmiDe  VAR dEmiDe  SIZE 055, 010 OF oDlg PICTURE "@D" PIXEL
		@ 013, 315 SAY "Emissao ate" OF oDlg SIZE 045, 009 PIXEL
		@ 010, 365 MSGET oGetEmiAte VAR dEmiAte SIZE 055, 010 OF oDlg PICTURE "@D" PIXEL
		@ 013, 430 SAY "CC de" OF oDlg SIZE 035, 009 PIXEL
		@ 010, 475 MSGET oGetCCDe  VAR cCCDe  SIZE 050, 010 OF oDlg F3 "CTT" PIXEL
		@ 013, 535 SAY "CC ate" OF oDlg SIZE 035, 009 PIXEL
		@ 010, 575 MSGET oGetCCAte VAR cCCAte SIZE 050, 010 OF oDlg F3 "CTT" PIXEL

		@ 043, 006 SAY "Produto de" OF oDlg SIZE 040, 009 PIXEL
		@ 040, 045 MSGET oGetCodDe  VAR cCodDe  SIZE 055, 010 OF oDlg F3 "SB1" PIXEL
		@ 043, 105 SAY "Produto ate" OF oDlg SIZE 045, 009 PIXEL
		@ 040, 145 MSGET oGetCodAte VAR cCodAte SIZE 055, 010 OF oDlg F3 "SB1" PIXEL
		@ 043, 205 SAY "Grupo de" OF oDlg SIZE 035, 009 PIXEL
		@ 040, 250 MSGET oGetGrpDe  VAR cGrpDe  SIZE 050, 010 OF oDlg F3 "SBM" PIXEL
		@ 043, 315 SAY "Grupo ate" OF oDlg SIZE 035, 009 PIXEL
		@ 040, 365 MSGET oGetGrpAte VAR cGrpAte SIZE 050, 010 OF oDlg F3 "SBM" PIXEL
		@ 043, 430 SAY "Conta de" OF oDlg SIZE 040, 009 PIXEL
		@ 040, 475 MSGET oGetCtaDe  VAR cCtaDe  SIZE 055, 010 OF oDlg F3 "CT1" PIXEL
		@ 043, 535 SAY "Conta ate" OF oDlg SIZE 045, 009 PIXEL
		@ 040, 575 MSGET oGetCtaAte VAR cCtaAte SIZE 055, 010 OF oDlg F3 "CT1" PIXEL

		@ 070, 005 BUTTON "Cancelar" SIZE 045, 012 OF oDlg ACTION oDlg:End() PIXEL
		@ 070, 055 BUTTON "Exportar XLSX" SIZE 060, 012 OF oDlg ;
			ACTION MsgRun("Gerando arquivo XLSX...", "LMCPCO01", {|| LmcPcoExporta(oGrid)}) PIXEL
		@ 070, 577 BUTTON "Consultar" SIZE 045, 012 OF oDlg ;
			ACTION MsgRun("Consultando registros...", "LMCPCO01", ;
				{|| LmcPcoCarrega(oGrid, {oGetFilDe:cText, oGetFilAte:cText, ;
					oGetEmiDe:cText, oGetEmiAte:cText, oGetCCDe:cText, ;
					oGetCCAte:cText, oGetCodDe:cText, oGetCodAte:cText, ;
					oGetGrpDe:cText, oGetGrpAte:cText, oGetCtaDe:cText, ;
					oGetCtaAte:cText})}) PIXEL

		oGrid := MsNewGetDados():New(100, 005, 290, 645, GD_UPDATE, "AllwaysTrue", ;
			"AllwaysTrue", "", {}, , 999999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHead, aCols)
		oGrid:lActive := .F.
	ACTIVATE MSDIALOG oDlg CENTERED

	RestArea(aArea)
Return Nil

/*/{Protheus.doc} LmcPcoValidaFaixas
Valida os intervalos informados antes de montar a instrucao SQL.
@type Function
/*/
Static Function LmcPcoValidaFaixas(aParam)
	Local lOk := .T.

	If aParam[1] > aParam[2] .Or. aParam[3] > aParam[4] .Or. ;
		aParam[5] > aParam[6] .Or. aParam[7] > aParam[8] .Or. ;
		aParam[9] > aParam[10] .Or. aParam[11] > aParam[12]
		MsgStop("O valor inicial de cada faixa deve ser menor ou igual ao valor final.", "LMCPCO01")
		lOk := .F.
	EndIf
Return lOk

/*/{Protheus.doc} LmcPcoCarrega
Executa a consulta e atualiza o resultado na grade da tela.
@type Function
/*/
Static Function LmcPcoCarrega(oGrid, aParam)
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	// Local aHead  := LmcPcoCabecalho()
	Local aCols  := {}
	Local aLinha := {}

	If !LmcPcoValidaFaixas(aParam)
		Return Nil
	EndIf

	cQuery := " SELECT D3.D3_FILIAL, D3.D3_TM, D3.D3_DOC, B1.B1_COD, "
	cQuery += " TRIM(B1.B1_DESC) AS B1_DESC, B1.B1_GRUPO, TRIM(BM.BM_DESC) AS BM_DESC, "
	cQuery += " D3.D3_LOCAL, D3.D3_QUANT, D3.D3_CUSTO1, D3.D3_CC, AKD.AKD_DATA, "
	cQuery += " D3.R_E_C_N_O_ AS RECSD3, ISNULL(AKD.R_E_C_N_O_, 0) AS RECAKD "
	cQuery += " FROM " + RetSqlName("SD3") + " D3 WITH (NOLOCK) "
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " B1 WITH (NOLOCK) "
	cQuery += " ON B1.B1_COD = D3.D3_COD AND B1.D_E_L_E_T_ = '' "
	cQuery += " INNER JOIN " + RetSqlName("SBM") + " BM WITH (NOLOCK) "
	cQuery += " ON BM.BM_GRUPO = B1.B1_GRUPO AND BM.D_E_L_E_T_ = '' "
	cQuery += " INNER JOIN " + RetSqlName("SF5") + " F5 WITH (NOLOCK) "
	cQuery += " ON F5.F5_FILIAL = '' AND F5.F5_CODIGO = D3.D3_TM "
	cQuery += " AND F5.D_E_L_E_T_ = '' AND F5.F5_XBIPCO = '1' "
	cQuery += " LEFT OUTER JOIN " + RetSqlName("DHN") + " DHN WITH (NOLOCK) "
	cQuery += " ON DHN.DHN_FILIAL = D3.D3_FILIAL AND DHN.DHN_ITORI = D3.D3_ITEMSA "
	cQuery += " AND DHN.DHN_DOCORI = D3.D3_NUMSA AND DHN.D_E_L_E_T_ = '' "
	cQuery += " LEFT OUTER JOIN " + RetSqlName("AKD") + " AKD WITH (NOLOCK) "
	cQuery += " ON AKD.AKD_FILIAL = D3.D3_FILIAL "
	cQuery += " AND AKD.AKD_CHAVE = 'SD3' + D3.D3_FILIAL + D3.D3_COD + D3.D3_LOCAL + D3.D3_NUMSEQ + D3.D3_CF "
	cQuery += " AND AKD.AKD_PROCES = '000151' "
	cQuery += " AND AKD.AKD_ITEM = (CASE WHEN D3.D3_TM > '500' THEN '02' ELSE '01' END) "
	cQuery += " AND AKD.D_E_L_E_T_ = '' AND AKD.AKD_TIPO = '1' "
	cQuery += " WHERE D3.D_E_L_E_T_ = '' "
	cQuery += " AND D3.D3_FILIAL >= '" + AllTrim(aParam[1])  + "' AND D3.D3_FILIAL <= '" + AllTrim(aParam[2])  + "' "
	cQuery += " AND D3.D3_EMISSAO >= '" + DtoS(aParam[3])    + "' AND D3.D3_EMISSAO <= '" + DtoS(aParam[4])    + "' "
	cQuery += " AND D3.D3_CC >= '" + AllTrim(aParam[5])      + "' AND D3.D3_CC <= '" + AllTrim(aParam[6])      + "' "
	cQuery += " AND D3.D3_COD >= '" + AllTrim(aParam[7])     + "' AND D3.D3_COD <= '" + AllTrim(aParam[8])     + "' "
	cQuery += " AND B1.B1_GRUPO >= '" + AllTrim(aParam[9])   + "' AND B1.B1_GRUPO <= '" + AllTrim(aParam[10])  + "' "
	cQuery += " AND B1.B1_RCONTA >= '" + AllTrim(aParam[11]) + "' AND B1.B1_RCONTA <= '" + AllTrim(aParam[12]) + "' "
	cQuery += " AND D3.D3_TM > '500' "
	cQuery += " AND SUBSTRING(B1.B1_GRUPO, 1, 1) = '4' "
	cQuery += " AND DHN.DHN_DOCDES IS NULL "
	cQuery += " AND D3.D3_ESTORNO = '' AND D3.D3_CUSTO1 <> 0 "
	cQuery += " ORDER BY D3.D3_FILIAL, D3.D3_EMISSAO, D3.D3_DOC "

	// A consulta utiliza hints do SQL Server (WITH (NOLOCK)). Nao aplicar
	// ChangeQuery(), pois ele remove os parenteses do hint e gera "WITH"
	// isolado, o que invalida a instrucao SQL no SQL Server.
	MPSysOpenQuery(cQuery, cAlias)
	TCSetField(cAlias, "AKD_DATA", "D")

	While !(cAlias)->(EoF())
		aLinha := {(cAlias)->D3_FILIAL, (cAlias)->D3_TM, (cAlias)->D3_DOC, ;
			(cAlias)->B1_COD, (cAlias)->B1_DESC, (cAlias)->B1_GRUPO, ;
			(cAlias)->BM_DESC, (cAlias)->D3_LOCAL, (cAlias)->D3_QUANT, ;
			(cAlias)->D3_CUSTO1, (cAlias)->D3_CC, (cAlias)->AKD_DATA, ;
			(cAlias)->RECSD3, (cAlias)->RECAKD, "", .F.}
		AAdd(aCols, aLinha)
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

	If Empty(aCols)
		MsgInfo("Nenhum movimento foi encontrado para os parametros informados.", "LMCPCO01")
		aCols := {LmcPcoLinhaVazia()}
	EndIf

	oGrid:SetArray(aCols)
	oGrid:Refresh()
	oGrid:oBrowse:Refresh()
Return Nil

/*/{Protheus.doc} LmcPcoCabecalho
Monta o cabecalho da grade de resultado.
@type Function
/*/
Static Function LmcPcoCabecalho()
	Local aHead := {}

	AAdd(aHead, {"Filial",         "D3_FILIAL", "@!",                   6, 0, ".F.", ".F.", "C", "", ""})
	AAdd(aHead, {"TM",             "D3_TM",     "@!",                   3, 0, ".F.", ".F.", "C", "", ""})
	AAdd(aHead, {"Documento",      "D3_DOC",    "@!",                   9, 0, ".F.", ".F.", "C", "", ""})
	AAdd(aHead, {"Produto",        "B1_COD",    "@!",                  15, 0, ".F.", ".F.", "C", "", ""})
	AAdd(aHead, {"Descricao",      "B1_DESC",   "@!",                  40, 0, ".F.", ".F.", "C", "", ""})
	AAdd(aHead, {"Grupo",          "B1_GRUPO",  "@!",                   4, 0, ".F.", ".F.", "C", "", ""})
	AAdd(aHead, {"Descr. grupo",   "BM_DESC",   "@!",                  40, 0, ".F.", ".F.", "C", "", ""})
	AAdd(aHead, {"Armazem",        "D3_LOCAL",  "@!",                   2, 0, ".F.", ".F.", "C", "", ""})
	AAdd(aHead, {"Quantidade",     "D3_QUANT",  "@E 999,999,999.9999", 16, 4, ".F.", ".F.", "N", "", ""})
	AAdd(aHead, {"Custo",          "D3_CUSTO1", "@E 999,999,999.99",   16, 2, ".F.", ".F.", "N", "", ""})
	AAdd(aHead, {"CC",         	   "D3_CC",     "@!",                   9, 0, ".F.", ".F.", "C", "", ""})
	AAdd(aHead, {"Data PCO",       "AKD_DATA",  "@D",                   8, 0, ".F.", ".F.", "D", "", ""})
	AAdd(aHead, {"Recno SD3",      "RECSD3",    "@E 9999999999",       10, 0, ".F.", ".F.", "N", "", ""})
	AAdd(aHead, {"Recno AKD",      "RECAKD",    "@E 9999999999",       10, 0, ".F.", ".F.", "N", "", ""})
	AAdd(aHead, {"",               "VIRTUAL",   "@!",                   1, 0, ".F.", ".F.", "C", "", ""})
Return aHead

/*/{Protheus.doc} LmcPcoLinhaVazia
Retorna uma linha estrutural para a grade, incluindo o campo virtual final.
@type Function
/*/
Static Function LmcPcoLinhaVazia()
Return {"", "", "", "", "", "", "", "", 0, 0, "", CtoD("//"), 0, 0, "", .F.}

/*/{Protheus.doc} LmcPcoExporta
Exporta os registros atualmente apresentados na grade para um arquivo XLSX.
@type Function
/*/
Static Function LmcPcoExporta(oGrid)
	Local aDados       := oGrid:aCols
	Local oXlsx        := Nil
	Local cBaseArq     := "C:\\Temp\\LMCPCO01_" + DtoS(Date()) + StrTran(Time(), ":", "")
	Local cArqRel      := cBaseArq + ".rel"
	Local cArqXlsx     := cBaseArq + ".xlsx"
	Local nLinha       := 1
	Local nItem        := 0
	Local lPossuiDados := .F.

	For nItem := 1 To Len(aDados)
		If aDados[nItem][13] > 0
			lPossuiDados := .T.
			Exit
		EndIf
	Next nItem

	If !lPossuiDados
		MsgStop("Nao ha registros consultados para exportar.", "LMCPCO01")
		Return Nil
	EndIf

	FErase(cArqRel)
	FErase(cArqXlsx)
	oXlsx := FwPrinterXlsx():New(.T.)
	If !oXlsx:Activate(cArqRel)
		MsgStop("Nao foi possivel iniciar a geracao do arquivo XLSX.", "LMCPCO01")
		Return Nil
	EndIf

	oXlsx:AddSheet("Consulta PCO")
	oXlsx:SetColumnsWidth(1, 1, 10)
	oXlsx:SetColumnsWidth(2, 2, 8)
	oXlsx:SetColumnsWidth(3, 3, 14)
	oXlsx:SetColumnsWidth(4, 4, 16)
	oXlsx:SetColumnsWidth(5, 5, 45)
	oXlsx:SetColumnsWidth(6, 6, 10)
	oXlsx:SetColumnsWidth(7, 7, 45)
	oXlsx:SetColumnsWidth(8, 8, 10)
	oXlsx:SetColumnsWidth(9, 10, 18)
	oXlsx:SetColumnsWidth(11, 11, 14)
	oXlsx:SetColumnsWidth(12, 12, 12)
	oXlsx:SetColumnsWidth(13, 14, 14)
	oXlsx:SetFont(FwPrinterFont():Calibri(), 11, .F., .T., .F.)
	oXlsx:SetText(nLinha,  1, "Filial")
	oXlsx:SetText(nLinha,  2, "TM")
	oXlsx:SetText(nLinha,  3, "Documento")
	oXlsx:SetText(nLinha,  4, "Produto")
	oXlsx:SetText(nLinha,  5, "Descricao")
	oXlsx:SetText(nLinha,  6, "Grupo")
	oXlsx:SetText(nLinha,  7, "Descr. grupo")
	oXlsx:SetText(nLinha,  8, "Armazem")
	oXlsx:SetText(nLinha,  9, "Quantidade")
	oXlsx:SetText(nLinha, 10, "Custo")
	oXlsx:SetText(nLinha, 11, "CC")
	oXlsx:SetText(nLinha, 12, "Data PCO")
	oXlsx:SetText(nLinha, 13, "Recno SD3")
	oXlsx:SetText(nLinha, 14, "Recno AKD")
	oXlsx:SetFont(FwPrinterFont():Calibri(), 10, .F., .F., .F.)

	For nItem := 1 To Len(aDados)
		If aDados[nItem][13] > 0
			nLinha++
			oXlsx:SetText(nLinha,  1, aDados[nItem][1])
			oXlsx:SetText(nLinha,  2, aDados[nItem][2])
			oXlsx:SetText(nLinha,  3, aDados[nItem][3])
			oXlsx:SetText(nLinha,  4, aDados[nItem][4])
			oXlsx:SetText(nLinha,  5, aDados[nItem][5])
			oXlsx:SetText(nLinha,  6, aDados[nItem][6])
			oXlsx:SetText(nLinha,  7, aDados[nItem][7])
			oXlsx:SetText(nLinha,  8, aDados[nItem][8])
			oXlsx:SetNumber(nLinha, 9, aDados[nItem][9])
			oXlsx:SetNumber(nLinha, 10, aDados[nItem][10])
			oXlsx:SetText(nLinha, 11, aDados[nItem][11])
			oXlsx:SetDate(nLinha, 12, aDados[nItem][12])
			oXlsx:SetNumber(nLinha, 13, aDados[nItem][13])
			oXlsx:SetNumber(nLinha, 14, aDados[nItem][14])
		EndIf
	Next nItem

	oXlsx:ToXlsx()
	oXlsx:DeActivate()
	ShellExecute("Open", "excel", cArqXlsx, "C:\\", 1)
	MsgInfo("Arquivo gerado com sucesso:" + CRLF + cArqXlsx, "LMCPCO01")
Return Nil
