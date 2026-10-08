//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} RELCTE1G
@description Relatório de CTE's Emitidos   
@author Giancarlo Albano
@owner Masutti
@since 28/10/2020
@version 1.0
/*/
	
User Function RELCTE1G()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""
	Private cCteAlias := GetNextAlias()	
	
	//Definies da pergunta
	cPerg := "RELCTE1G"
	
	//Se a pergunta no existir, zera a varivel
	/*/

	[Alessandre Antoniassi - 19/11/2020]
	//Por determinao da TOTVS avaliadda no codeanalysis toda Manipulao dos Metadados devem
	//ser feitas pelo configurador

	DbSelectArea("SX1")
	SX1->(DbSetOrder(1)) //X1_GRUPO + X1_ORDEM
	If ! SX1->(DbSeek(cPerg))
		cPerg := Nil
	EndIf
	*/


	//Cria as definies do relatório
	oReport := fReportDef()
	
	//Ser enviado por e-Mail?
	If lEmail
		oReport:nRemoteType := NO_REMOTE
		oReport:cEmail := cPara
		oReport:nDevice := 3 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
		oReport:SetPreview(.F.)
		oReport:Print(.F., "", .T.)
	//Seno, mostra a tela
	Else
		oReport:PrintDialog()
	EndIf
	
	RestArea(aArea)
Return
	
/*-------------------------------------------------------------------------------*
 | Func:  fReportDef                                                             |
 | Desc:  Função que monta a definio do relatório                              |
 *-------------------------------------------------------------------------------*/
	
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	//Local oBreak := Nil
	
	//Criao do componente de impresso
	oReport := TReport():New(	"RELCTE1G",;						//Nome do Relatório
								"Relatório de CTE's Emitidos",;		//Ttulo
								cPerg,;								//Pergunte ... Se eu defino a pergunta aqui, ser impresso uma pgina com os parmetros, conforme privilgio 101
								{|oReport| fRepPrint(oReport)},;	//Bloco de cdigo que ser executado na confirmao da impresso
								)									//Descrio
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetLandscape()
	//oReport:SetPortrait()
	oReport:SetLineHeight(50)
	oReport:nFontBody := 10
	
	//Criando a seo de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seo pertence
									"Dados",;		//Descrio da seo
									{cCteAlias}, , .F., .T., , , , , , ,, , , .T.)	//Tabelas utilizadas, a primeira ser considerada como principal da seo
	oSectDad:SetTotalInLine(.F.)  					//Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	TRCell():New(oSectDad, "CTE",			 	cCteAlias, "CTE", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "EMISSAO",		 	cCteAlias, "EMISSAO", /*Picture*/, 12, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DOC_CLIENTE",		cCteAlias, "DOC_CLIENTE", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CLIENTE",		 	cCteAlias, "CLIENTE", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "LOJA",		 		cCteAlias, "LOJA", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NOME",		 		cCteAlias, "NOME", /*Picture*/, 35, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PRODUTO",		 	cCteAlias, "PRODUTO", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DESCRICAO",		 	cCteAlias, "DESCRICAO", /*Picture*/, 35, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VIAGEM",		 	cCteAlias, "VIAGEM", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)	
	TRCell():New(oSectDad, "PESO",		 		cCteAlias, "PESO", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VALOR",		 		cCteAlias, "VALOR", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VALFRE_EMPRESA",	cCteAlias, "FRETE EMPRESA", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VALFRE_MOTORA",		cCteAlias, "FRETE MOTORISTA", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VLR_ADIANTAMENTO",	cCteAlias, "ADIANTAMENTO", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VLR_SEGURO",		cCteAlias, "SEGURO", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CODOBS",			cCteAlias, "OBSERVACAO", /*Picture*/, 80, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Função que imprime o relatório                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)

	Local aArea    	:= GetArea() 
	Local oSectDad 	:= Nil
	Local nAtual   	:= 0
	Local nTotal   	:= 0
	Local cDocAnt	:= ""
	
	
	//Pegando as sees do relatório
	oSectDad := oReport:Section(1)
	
	BeginSql Alias cCteAlias
		SELECT 
			DT6.DT6_DOC AS CTE, 
			CONVERT(VARCHAR,CAST(DT6.DT6_DATEMI AS DATETIME),103) AS EMISSAO,  
			DTC.DTC_NUMNFC AS DOC_CLIENTE, 
			DT6.DT6_CLIDEV AS CLIENTE, 
			DT6.DT6_LOJDEV AS LOJA, 
			SA1.A1_NOME AS NOME, 
			DTC.DTC_CODPRO AS PRODUTO, 
			DTC.DTC_CODOBS AS CODOBS,
			SB1.B1_DESC AS DESCRICAO, 
			DT6.DT6_NUMVGA AS VIAGEM,
			DT6.DT6_PESO AS PESO, 
			DT6.DT6_VALMER AS VALOR, 
			COALESCE(DT6.DT6_VALFRE,0) AS VALFRE_EMPRESA,
			COALESCE(DTR.DTR_VALFRE,0) AS VALFRE_MOTORA,
			COALESCE(DTR.DTR_ADIFRE,0) AS VLR_ADIANTAMENTO,
			COALESCE(DUP.DUP_VALSEG,0) AS VLR_SEGURO
		FROM %Table:DT6% DT6 
		INNER JOIN %Table:SA1%  SA1 
			ON SA1.A1_COD = DT6.DT6_CLIDEV 
			AND SA1.A1_LOJA = DT6.DT6_LOJDEV 
		INNER JOIN %Table:DTC%  DTC
			ON DTC.DTC_FILORI = DT6.DT6_FILORI
			AND DTC.DTC_LOTNFC = DT6.DT6_LOTNFC
			AND DTC.%NotDel%
		LEFT JOIN %Table:DUP%  DUP
			ON DUP.DUP_FILORI = DT6.DT6_FILORI
			AND DUP.DUP_VIAGEM = DT6.DT6_NUMVGA
			AND DUP.%NotDel%
		LEFT JOIN %Table:DTR%  DTR 
			ON DTR.DTR_FILORI = DT6.DT6_FILORI
			AND DTR.DTR_VIAGEM = DT6.DT6_NUMVGA
			AND DTR.%NotDel%
		INNER JOIN %Table:SB1%  SB1 
			ON SB1.B1_COD = DTC.DTC_CODPRO
		WHERE DT6.DT6_SITCTE = '2' 
			AND DT6.DT6_DATEMI BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			AND DT6.%NotDel%
		ORDER BY  DT6.DT6_DOC, DT6.DT6_DATEMI, DT6.DT6_CLIDEV, DT6.DT6_LOJDEV, DTC.DTC_NUMNFC
	EndSql


	Count to nTotal
	oReport:SetMeter(nTotal)
    (cCteAlias)->(DbGoTop())
 
	
	//Enquanto houver dados
	oSectDad:Init()
	(cCteAlias)->(DbGoTop())
	While ! (cCteAlias)->(Eof())
		//Incrementando a régua 
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()

		If cDocAnt == (cCteAlias)->CTE
			oSectDad:Cell("PESO"):SetValue(0) 
			oSectDad:Cell("VALOR"):SetValue(0) 
			oSectDad:Cell("VALFRE_EMPRESA"):SetValue(0) 
			oSectDad:Cell("VALFRE_MOTORA"):SetValue(0) 
			oSectDad:Cell("VLR_ADIANTAMENTO"):SetValue(0) 
			oSectDad:Cell("VLR_SEGURO"):SetValue(0) 
		Else
			oSectDad:Cell("PESO"):SetValue((cCteAlias)->PESO) 
			oSectDad:Cell("VALOR"):SetValue((cCteAlias)->VALOR) 
			oSectDad:Cell("VALFRE_EMPRESA"):SetValue((cCteAlias)->VALFRE_EMPRESA) 
			oSectDad:Cell("VALFRE_MOTORA"):SetValue((cCteAlias)->VALFRE_MOTORA) 
			oSectDad:Cell("VLR_ADIANTAMENTO"):SetValue((cCteAlias)->VLR_ADIANTAMENTO) 
			oSectDad:Cell("VLR_SEGURO"):SetValue((cCteAlias)->VLR_SEGURO) 
		EndIf

		oSectDad:Cell("CODOBS"):SetValue(MSMM((cCteAlias)->CODOBS,80)) 

		//Imprimindo a linha atual
		oSectDad:PrintLine()
		cDocAnt := (cCteAlias)->CTE
		
		(cCteAlias)->(DbSkip())
	EndDo
	oSectDad:Finish()
	(cCteAlias)->(DbCloseArea())
	
	RestArea(aArea)
Return
