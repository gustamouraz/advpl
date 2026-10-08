#INCLUDE 'TOTVS.CH'
#INCLUDE "topconn.ch"
#Include "RPTDEF.CH"

/*/{Protheus.doc} MAS43R01
Relatorio - Processamento CT-e x Doc. de Entrada
@type user function
@author Pedro Lindenberg
@since 27/05/2024
/*/
User Function MAS43R01()
	local _cPerg := PadR("MAS43R01",10)

	// carrega pergunta na memória
	If !Pergunte('MAS43R01',.T.)
		Return
	Endif
	// chama rotina para geracao do relatorio
	oReport := ReportDef(_cPerg)
	oReport:PrintDialog()

Return

/*/{Protheus.doc} ReportDef
  {Protheus.doc} User Function ReportDef
	(long_description)
	@Daniel Pedro Lindenberg
	@since 27/05/2024
/*/

Static Function ReportDef(mvPerg)

	Local oReport	as Object

	oReport := TReport():New('MAS43R01','Relatório de Processamento',mvPerg,{|oReport| PrintDialog(oReport)},'Ct-e x Documento de Entrda')

	oSection1  := TRSection():New(oReport ,"Cabeçalho",{"ZA1"})
	oSection1:SetTotalInLine(.F.)

	TRCell():New(oSection1, "Status"         , "", "STATUS" , /*Picture*/, 34/*Tamanho do dado na Sx3*/, /*lPixel*/, /*{|| code-block de impressao }*/, , , , , , , , , /*Negrito*/)
	TRCell():New(oSection1, "Filial"         , "", "FILIAL" , /*Picture*/, 15/*Tamanho do dado na Sx3*/ , /*lPixel*/, /*{|| code-block de impressao }*/, , , , , , , , , /*Negrito*/)
	TRCell():New(oSection1, "NumDocumento"   , "", "NUM.DOCUMENTO" , /*Picture*/, 15/*Tamanho do dado na Sx3*/ , /*lPixel*/, /*{|| code-block de impressao }*/, , , , , , , , , /*Negrito*/)
	TRCell():New(oSection1, "Fornecedor"     , "", "FORNECEDOR" , /*Picture*/, 12/*Tamanho do dado na Sx3*/ , /*lPixel*/, /*{|| code-block de impressao }*/, , , , , , , , , /*Negrito*/)
	TRCell():New(oSection1, "RazaoSocial"    , "", "RAZAO S."  , /*Picture*/, 65/*Tamanho do dado na Sx3*/, /*lPixel*/, /*{|| code-block de impressao }*/, , , , , , , , , /*Negrito*/)
	TRCell():New(oSection1, "DtDigit"        , "", "DT.INCLUSAO", /*Picture*/, 12/*Tamanho do dado na Sx3*/ , /*lPixel*/, /*{|| code-block de impressao }*/, , , , , , , , , /*Negrito*/)
	TRCell():New(oSection1, "DtEmissao"      , "", "DT.EMISSAO" , /*Picture*/, 12/*Tamanho do dado na Sx3*/ , /*lPixel*/, /*{|| code-block de impressao }*/, , , , , , , , , /*Negrito*/)
	TRCell():New(oSection1, "TES"            , "", "TES"    , /*Picture*/, 35/*Tamanho do dado na Sx3*/, /*lPixel*/, /*{|| code-block de impressao }*/, , , , , , , , , /*Negrito*/)
	TRCell():New(oSection1, "Natureza"       , "", "NATUREZA", /*Picture*/, 20/*Tamanho do dado na Sx3*/, /*lPixel*/, /*{|| code-block de impressao }*/, , , , , , , , , /*Negrito*/)
	TRCell():New(oSection1, "Valor"          , "", "VALOR"  , /*Picture*/, 14/*Tamanho do dado na Sx3*/, /*lPixel*/, /*{|| code-block de impressao }*/, , , , , , , , , /*Negrito*/)
	TRCell():New(oSection1, "UsuarioInclusao", "", "USUARIO", /*Picture*/, 20/*Tamanho do dado na Sx3*/, /*lPixel*/, /*{|| code-block de impressao }*/, , , , , , , , , /*Negrito*/)

	oSection1:SetHeaderPage()
	oReport:lParamPage := .F.

Return oReport


Static Function PrintDialog(oReport)

	Local oSection1  := oReport:Section(1)
	Local cQry := "" as Character
	Local cStatus := "" as Character
	Local cUser := "" as Character
	Local cAlias := "TMP"+GetNextAlias()
	Local oQuery := Nil
	Local	aCgcFor := {}
	Local	cFornec := ""
	Local	cForNome := ""

	cQry += "SELECT ZA1_FILDOC, ZA1_CTEDOC,"+CRLF
	cQry += "D1_TOTAL, D1_DTDIGIT, D1_EMISSAO,"+CRLF
	cQry += "F4_TEXTO, ED_DESCRIC, ZA1_STATUS,"+CRLF
	cQry += "DT6_USERGI, DT6_USERGA "+CRLF
	cQry += "FROM ZA1010 ZA1 "+CRLF
	cQry += "LEFT JOIN SD1010 SD1 ON "+CRLF
	cQry += "D1_FILIAL = ZA1_FILDCE AND "+CRLF
	cQry += "D1_DOC = ZA1_DOCENT AND "+CRLF
	cQry += "D1_SERIE = ZA1_CTESER AND "+CRLF
	cQry += "SD1.D_E_L_E_T_ = ' ' "+CRLF
	cQry += "LEFT JOIN ZNC010 ZNC ON "+CRLF
	cQry += "ZNC_FILIAL = ' ' AND "+CRLF
	cQry += "ZNC_COD = ZA1_ZNCCOD AND "+CRLF
	cQry += "ZNC.D_E_L_E_T_ = ' ' "+CRLF
	cQry += "LEFT JOIN SF4010 SF4 ON "+CRLF
	cQry += "F4_FILIAL = SUBSTRING(D1_FILIAL,1,4) AND "+CRLF
	cQry += "F4_CODIGO = ZNC_TES AND "+CRLF
	cQry += "SF4.D_E_L_E_T_ = ' ' "+CRLF
	cQry += "LEFT JOIN SED010 SED ON "+CRLF
	cQry += "ED_CODIGO = ZNC_NATURE AND "+CRLF
	cQry += "SED.D_E_L_E_T_ = ' ' "+CRLF
	cQry += "LEFT JOIN DT6010 DT6 ON "+CRLF
	cQry += "DT6_FILIAL = ZA1_FILIAL AND "+CRLF
	cQry += "DT6_FILDOC = ZA1_FILDOC AND "+CRLF
	cQry += "DT6_DOC = ZA1_CTEDOC AND "+CRLF
	cQry += "DT6_SERIE = ZA1_CTESER AND "+CRLF
	cQry += "DT6.D_E_L_E_T_ = ' ' "+CRLF
	cQry += "WHERE ZA1.D_E_L_E_T_ = ' ' AND "+CRLF
	cQry += "ZA1_CTEDOC BETWEEN ? AND ? "+CRLF
	cQry += "AND ZA1_CANCEL = 'N' "+CRLF
	IF MV_PAR05 == 1
		cQry += "AND ZA1_STATUS = 'S' "+CRLF
	ELSEIF MV_PAR05 == 2
		cQry += "AND ZA1_STATUS = 'E' "+CRLF
	ELSEIF MV_PAR05 == 3
		cQry += "AND ZA1_STATUS = 'R' "+CRLF
	ELSEIF MV_PAR05 == 4
		cQry += "AND (ZA1_STATUS = 'E' OR ZA1_STATUS = 'R') "+CRLF
	ENDIF
	oQuery := FWPreparedStatement():New(cQry)
	oQuery:setParams({MV_PAR03,MV_PAR04})
	MPSysOpenQuery(oQuery:getFixQuery(), cAlias)

	oSection1:Init()

	while !(cAlias)->(Eof())
		aCgcFor := {}
		cStatus := ""
		cUser 	:= ""
		cFornec := ""
		cForNome:= ""

		aCgcFor := FWSM0Util():GetSM0Data(, (cAlias)->ZA1_FILDOC, { "M0_CGC" } )
		SA2->(DBSETORDER(3))
		If SA2->(DbSeek(xFilial("SA2")+aCgcFor[1][2]))
			cFornec := SA2->A2_COD
			cForNome   := SA2->A2_NOME
		EndIf

		Do Case
		CASE (cAlias)->ZA1_STATUS == 'S'
			cStatus := "Sucesso ao Incluir"
		CASE (cAlias)->ZA1_STATUS == 'E'
			cStatus := "Erro ao Incluir"
		CASE (cAlias)->ZA1_STATUS == 'R'
			cStatus := "Reprocessado"
		ENDCASE

		If EMPTY((cAlias)->DT6_USERGA)
			cUser:=	FWLeUserlg(cAlias+"->DT6_USERGI",1)
		Else
			cUser:= FWLeUserlg(cAlias+"->DT6_USERGA",1)
		EndIf

		oSection1:Cell("Status"):SetValue(cStatus)
		oSection1:Cell("Filial"):SetValue((cAlias)->ZA1_FILDOC)
		oSection1:Cell("NumDocumento"):SetValue(Alltrim((cAlias)->ZA1_CTEDOC))
		oSection1:Cell("Fornecedor"):SetValue(cFornec)
		oSection1:Cell("RazaoSocial"):SetValue(cForNome)
		IF !EMPTY((cAlias)->D1_DTDIGIT) .AND. ((cAlias)->D1_DTDIGIT >= DTOS(MV_PAR01)) .AND. ((cAlias)->D1_DTDIGIT <= DTOS(MV_PAR02))
			oSection1:Cell("DtDigit"):SetValue((cAlias)->D1_DTDIGIT)
			oSection1:Cell("DtEmissao"):SetValue((cAlias)->D1_EMISSAO)
		ENDIF
		oSection1:Cell("TES"):SetValue((cAlias)->F4_TEXTO)
		oSection1:Cell("Natureza"):SetValue((cAlias)->ED_DESCRIC)
		oSection1:Cell("Valor"):SetValue((cAlias)->D1_TOTAL)
		oSection1:Cell("UsuarioInclusao"):SetValue(cUser)

		oSection1:PrintLine()

		(cAlias)->(DbSkip())

	end

	oSection1:Finish()

	(cAlias)->(DBCLOSEAREA())

Return(.T.) //oReport
