//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} RMO004
Relatório - Romaneio x Peso Descontado    
@author zReport
@since 06/06/2018
@version 1.0
	@example
	u_RMO004()
	@obs Função gerada pelo zReport()
/*/
	
User Function RMO004()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""
	
	//Definies da pergunta
	cPerg := "XORIG01   "
	
	//Se a pergunta no existir, zera a varivel
	DbSelectArea("SX1")
	SX1->(DbSetOrder(1)) //X1_GRUPO + X1_ORDEM
	If ! SX1->(DbSeek(cPerg))
		cPerg := Nil
	EndIf
	
	//Cria as definições do relatório
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
 | Desc:  Função que monta a definição do relatório                              |
 *-------------------------------------------------------------------------------*/
	
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	Local oBreak   := Nil
	Local oFunTot1 := Nil
	Local oFunTot2 := Nil
	Local oFunTot3 := Nil
	Local oFunTot4 := Nil
	Local oFunTot5 := Nil
	Local oFunTot6 := Nil
	Local oFunTot7 := Nil
	Local oFunTot8 := Nil
	Local oFunTot9 := Nil
	Local oFunTot10 := Nil
	Local oFunTot11 := Nil
	
	//Criacao do componente de impresso
	oReport := TReport():New(	"RMO004",;		//Nome do Relatorio
								"Romaneio x Peso Descontado",;		//Titulo
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, sera impresso uma pagina com os parametros, conforme privilegio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de codigo que sera executado na confirmacao da impressao
								)		//Descricao
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetLandscape()
	oReport:SetLineHeight(50)
	oReport:nFontBody := 06
	//oReport:SetPortrait()
	
	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
									"Dados",;		//Descrição da seção
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira ser considerada como principal da seção
	//TRCell():New(oSectDad,"NOME"		,,"ENTIDADE"  		,"@!",40)
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores sero impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatrio
	//TRCell():New(oSectDad, "FILIAL", "QRY_AUX", "Filial", "@!", 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ROMANEIO", "QRY_AUX", "Romaneio", "@!", 12, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	// ADICIONADO 0302

	TRCell():New(oSectDad, "FILIAL", "QRY_AUX", "FILIAL", "@!", 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TIPO", "QRY_AUX", "Tipo", "@!",30, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CONTRATO", "QRY_AUX", "Contrato", "@!", 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DATA_ROM", "QRY_AUX", "Dt.Contrato", "@D", 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	//TRCell():New(oSectDad, "TIKET_CLAS", "QRY_AUX", "Tiket_clas", "@!", 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

	TRCell():New(oSectDad, "NOME", "QRY_AUX", "Ent", "@!", 35, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ENTLOJ", "QRY_AUX", "LJEnt", "@!", 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QTDFIS", "QRY_AUX", "QtdFiscal", "@E 999,999,999.99", 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VLRUNI", "QRY_AUX", "VlrUnit", "@E 999,999,999.99", 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VLRTOT", "QRY_AUX", "VlrTot", "@E 999,999,999.99", 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	

	TRCell():New(oSectDad, "PLACA", "QRY_AUX", "Placa", "@!", 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PRODUTO", "QRY_AUX", "Produto", "@!", 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "LOCAL", "QRY_AUX", "Local", "@!", 02, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "SAFRA", "QRY_AUX", "Safra", "@!", 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DATA", "QRY_AUX", "Data", "@D", 12, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NOTA", "QRY_AUX", "Nota", "@!", 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "SERIE", "QRY_AUX", "Serie", "@!", 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TRANSPORTADORA", "QRY_AUX", "Transportadora", "@!", 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CHAVENFE", "QRY_AUX", "ChaveNfe", "@!", 44, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "OBSERVACAO", "QRY_AUX", "Observacao", "@!", 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DATA_PESO", "QRY_AUX", "Data_Peso1", "@D", 12, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PESO01", "QRY_AUX", "Peso01", "@E 999,999,999.99", 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PESO02", "QRY_AUX", "Peso02", "@E 999,999,999.99", 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PESSUBT", "QRY_AUX", "Pes.Subt.", "@E 999,999,999.99", 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "UMIDADE", "QRY_AUX", "Umidade", "@E 999.99", 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PESUMI", "QRY_AUX", "Pes.Umi.", "@E 999,999.99", 13, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "IMPUREZA", "QRY_AUX", "Impureza", "@E 999.99", 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PESIMP", "QRY_AUX", "Pes.Imp.", "@E 999,999.99", 13, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "AVARIADO", "QRY_AUX", "Avariado", "@E 999.99", 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PESAVAR", "QRY_AUX", "Pes.Avar.", "@E 999,999.99", 13, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "OUTROS", "QRY_AUX", "Outros", "@E 999.99", 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PESOUTR", "QRY_AUX", "Pes.Outr.", "@E 999,999.99", 13, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "LIQUIDO", "QRY_AUX", "Liquido", "@E 999,999,999.99", 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE", "QRY_AUX", "CT-e", "@!", 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	//Definindo a quebra
	oBreak := TRBreak():New(oSectDad,{|| QRY_AUX->(CONTRATO) },{|| "TOTAIS" })
	oSectDad:SetHeaderBreak(.T.)
	
	//Totalizadores
	oFunTot1 := TRFunction():New(oSectDad:Cell("PESSUBT"),,"SUM",oBreak,,"@E 9,999,999,999.99")
	oFunTot1:SetEndReport(.F.)
	oFunTot2 := TRFunction():New(oSectDad:Cell("UMIDADE"),,"AVERAGE",oBreak,,"@E 999.99")
	oFunTot2:SetEndReport(.F.)
	oFunTot3 := TRFunction():New(oSectDad:Cell("PESUMI"),,"SUM",oBreak,,"@E 9,999,999,999.99")
	oFunTot3:SetEndReport(.F.)
	oFunTot4 := TRFunction():New(oSectDad:Cell("IMPUREZA"),,"AVERAGE",oBreak,,"@E 999.99")
	oFunTot4:SetEndReport(.F.)
	oFunTot5 := TRFunction():New(oSectDad:Cell("PESIMP"),,"SUM",oBreak,,"@E 9,999,999,999.99")
	oFunTot5:SetEndReport(.F.)
	oFunTot6 := TRFunction():New(oSectDad:Cell("AVARIADO"),,"AVERAGE",oBreak,,"@E 999.99")
	oFunTot6:SetEndReport(.F.)
	oFunTot7 := TRFunction():New(oSectDad:Cell("PESAVAR"),,"SUM",oBreak,,"@E 9,999,999,999.99")
	oFunTot7:SetEndReport(.F.)
	oFunTot8 := TRFunction():New(oSectDad:Cell("OUTROS"),,"AVERAGE",oBreak,,"@E 999.99")
	oFunTot8:SetEndReport(.F.)
	oFunTot9 := TRFunction():New(oSectDad:Cell("PESOUTR"),,"SUM",oBreak,,"@E 9,999,999,999.99")
	oFunTot9:SetEndReport(.F.)
	oFunTot10 := TRFunction():New(oSectDad:Cell("LIQUIDO"),,"SUM",oBreak,,"@E 9,999,999,999.99")
	oFunTot10:SetEndReport(.F.)
	oFunTot11 := TRFunction():New(oSectDad:Cell("ROMANEIO"),,"COUNT",oBreak,,"@E 999,999")
	oFunTot11:SetEndReport(.F.)
Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Função que imprime o relatório                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += " SELECT NJJ.NJJ_FILIAL AS FILIAL,"		+ STR_PULA
	cQryAux += " NJJ.NJJ_CODROM AS ROMANEIO,"		+ STR_PULA
	cQryAux += " CONVERT(VARCHAR,CAST(NJJ.NJJ_DATA AS DATETIME),103)  AS DATA_ROM,"		+ STR_PULA
	cQryAux += " NJJ.NJJ_FILIAL AS FILIAL,"		+ STR_PULA
	cQryAux += " NJJ.NJJ_TKTCLA AS TIKET_CLAS,"		+ STR_PULA
	cQryAux += " NJJ.NJJ_PLACA AS PLACA,"		+ STR_PULA
	cQryAux += " NJJ.NJJ_ENTLOJ AS ENTLOJ,"		+ STR_PULA
	cQryAux += " NJM.NJM_QTDFIS AS QTDFIS, "		+ STR_PULA
    cQryAux += " NJM.NJM_VLRUNI AS VLRUNI, "		+ STR_PULA
    cQryAux += " NJM.NJM_VLRTOT AS VLRTOT, "		+ STR_PULA
	cQryAux += " CASE NJJ.NJJ_TIPO"		+ STR_PULA
	cQryAux += " WHEN '1' THEN 'ENTRADA POR PRODUO'"		+ STR_PULA
	cQryAux += " WHEN '2' THEN 'REMESSA PARA DEPOSITO'"		+ STR_PULA
	cQryAux += " WHEN '3' THEN 'ENTRADA PARA DEPOSITO'"		+ STR_PULA
	cQryAux += " WHEN '4' THEN 'SAIDA POR VENDA'"		+ STR_PULA
	cQryAux += " WHEN '5' THEN 'ENTRADA POR COMPRA'"		+ STR_PULA
	cQryAux += " WHEN '6' THEN 'DEVOLUO DE DEPOSITO'"		+ STR_PULA
	cQryAux += " WHEN '7' THEN 'DEVOLUO DE REMESSA'"		+ STR_PULA
	cQryAux += " WHEN '8' THEN 'DEVOLUO DE COMPRA'"		+ STR_PULA
	cQryAux += " WHEN '9' THEN 'DEVOLUO DE VENDA'"		+ STR_PULA
	cQryAux += " END AS TIPO,"		+ STR_PULA
	cQryAux += " NJJ.NJJ_CODENT AS CODIGO,"		+ STR_PULA
	cQryAux += " NJJ.NJJ_LOJENT AS LOJA,"		+ STR_PULA
	cQryAux += " NJ0.NJ0_NOME AS NOME,"		+ STR_PULA
	cQryAux += " NJJ.NJJ_CODCTR AS CONTRATO,"		+ STR_PULA
	cQryAux += " SB1.B1_DESC AS PRODUTO,"		+ STR_PULA
	cQryAux += " NJJ.NJJ_LOCAL AS LOCAL,"		+ STR_PULA
	cQryAux += " NJU.NJU_DESCRI AS SAFRA ,"		+ STR_PULA
	cQryAux += " CONVERT(VARCHAR,CAST(NJM.NJM_DOCEMI AS DATETIME),103) AS DATA,  "		+ STR_PULA
    cQryAux += " NJM.NJM_DOCNUM AS NOTA,  "		+ STR_PULA
    cQryAux += " NJM.NJM_DOCSER AS SERIE,      "		+ STR_PULA
	cQryAux += " NJJ.NJJ_OBS AS OBSERVACAO,"		+ STR_PULA
	cQryAux += " SA4.A4_NOME AS TRANSPORTADORA,"		+ STR_PULA
	cQryAux += " NJJ_CHVNFE AS CHAVENFE,"		+ STR_PULA
	cQryAux += " CONVERT(VARCHAR,CAST(NJJ_DATPS1 AS DATETIME),103) AS DATA_PESO,"		+ STR_PULA
    cQryAux += " (NJJ.NJJ_PESO1 * (NJM.NJM_PERDIV/100)) AS PESO01,  "		+ STR_PULA
    cQryAux += " (NJJ.NJJ_PESO2  * (NJM.NJM_PERDIV/100)) AS PESO02,  "		+ STR_PULA
    cQryAux += " (NJK.NJK_BASDES  * (NJM.NJM_PERDIV/100)) AS PESSUBT,  "		+ STR_PULA
    cQryAux += " (NJK.NJK_PERDES * (NJM.NJM_PERDIV/100))   AS UMIDADE,  "		+ STR_PULA
    cQryAux += " (NJK.NJK_QTDDES * (NJM.NJM_PERDIV/100))   AS PESUMI,  "		+ STR_PULA
    cQryAux += " (NJK1.NJK_PERDES * (NJM.NJM_PERDIV/100))  AS IMPUREZA,  "		+ STR_PULA
    cQryAux += " (NJK1.NJK_QTDDES * (NJM.NJM_PERDIV/100))  AS PESIMP,  "		+ STR_PULA
    cQryAux += " (NJK2.NJK_PERDES * (NJM.NJM_PERDIV/100))  AS AVARIADO,  "		+ STR_PULA
    cQryAux += " (NJK2.NJK_QTDDES * (NJM.NJM_PERDIV/100))  AS PESAVAR,  "		+ STR_PULA
    cQryAux += " (NJK3.NJK_PERDES * (NJM.NJM_PERDIV/100))  AS OUTROS,  "		+ STR_PULA
    cQryAux += " (NJK3.NJK_QTDDES * (NJM.NJM_PERDIV/100))  AS PESOUTR,  "		+ STR_PULA
    cQryAux += " (NJJ.NJJ_PSLIQU * (NJM.NJM_PERDIV/100))  AS LIQUIDO, "		+ STR_PULA
	cQryAux += " NJJ.NJJ_XCTE AS CTE"		+ STR_PULA
	cQryAux += " FROM NJJ010 NJJ"		+ STR_PULA
	cQryAux += " INNER JOIN NJM010 NJM  ON NJM_FILIAL = NJJ_FILIAL "		+ STR_PULA
	// cQryAux += " 	AND NJM_CODCTR = NJJ_CODCTR  "		+ STR_PULA
	cQryAux += " 	AND NJM_CODROM = NJJ_CODROM "		+ STR_PULA
	cQryAux += " 	AND NJM.D_E_L_E_T_ = '' "		+ STR_PULA
	cQryAux += " INNER JOIN NJ0010 NJ0 ON NJJ.NJJ_CODENT = NJ0.NJ0_CODENT AND NJJ.NJJ_LOJENT = NJ0.NJ0_LOJENT AND NJ0.D_E_L_E_T_=' '"		+ STR_PULA
	cQryAux += " INNER JOIN NJU010 NJU ON NJJ.NJJ_CODSAF = NJU.NJU_CODSAF AND NJU.D_E_L_E_T_=' '"		+ STR_PULA
	cQryAux += " INNER JOIN SB1010 SB1 ON NJJ.NJJ_CODPRO = SB1.B1_COD AND SB1.D_E_L_E_T_=' '"		+ STR_PULA
	cQryAux += " LEFT JOIN NJK010 NJK ON NJK.NJK_CODROM = NJJ_CODROM AND NJK.NJK_FILIAL = NJJ_FILIAL AND NJK.D_E_L_E_T_= ' ' AND NJK.NJK_ITEM ='001'"		+ STR_PULA
	cQryAux += " LEFT JOIN NJK010 NJK1 ON NJK1.NJK_CODROM = NJJ_CODROM AND NJK1.NJK_FILIAL = NJJ_FILIAL AND NJK1.D_E_L_E_T_= ' ' AND NJK1.NJK_ITEM ='002'"		+ STR_PULA
	cQryAux += " LEFT JOIN NJK010 NJK2 ON NJK2.NJK_CODROM = NJJ_CODROM AND NJK2.NJK_FILIAL = NJJ_FILIAL AND NJK2.D_E_L_E_T_= ' ' AND NJK2.NJK_ITEM ='003'"		+ STR_PULA
	cQryAux += " LEFT JOIN NJK010 NJK3 ON NJK3.NJK_CODROM = NJJ_CODROM AND NJK3.NJK_FILIAL = NJJ_FILIAL AND NJK3.D_E_L_E_T_= ' ' AND NJK3.NJK_ITEM ='004'"		+ STR_PULA
	cQryAux += " LEFT JOIN SA4010 SA4 ON NJJ_CODTRA = SA4.A4_COD AND SA4.D_E_L_E_T_=''"		+ STR_PULA
	cQryAux += " WHERE NJJ.NJJ_CODCTR >= '" + MV_PAR01 + "' AND NJJ.NJJ_CODCTR <= '" + MV_PAR02 + "'"		+ STR_PULA
	cQryAux += " AND NJJ.NJJ_CODENT >= '" + MV_PAR03 + "' AND NJJ.NJJ_CODENT <= '" + MV_PAR04 + "' "		+ STR_PULA
	cQryAux += " AND NJJ.NJJ_CODSAF >= '" + MV_PAR05 + "' AND NJJ.NJJ_CODSAF <= '" + MV_PAR06 + "'"		+ STR_PULA
	cQryAux += " AND NJJ.NJJ_CODROM >= '" + MV_PAR07 + "' AND NJJ.NJJ_CODROM <= '" + MV_PAR08 + "' "		+ STR_PULA
	cQryAux += " AND NJJ.NJJ_FILIAL >= '" + MV_PAR09 + "' AND NJJ.NJJ_FILIAL <= '" + MV_PAR10 + "' "		+ STR_PULA
	cQryAux += " AND NJJ.NJJ_TIPO >= '" + MV_PAR11 + "' AND NJJ.NJJ_TIPO <= '" + MV_PAR12 + "' "		+ STR_PULA
	cQryAux += " AND NJJ.NJJ_DATA >= '" + DToS(MV_PAR13) + "' AND NJJ.NJJ_DATA <= '" + DToS(MV_PAR14) + "' "		+ STR_PULA
	cQryAux += " AND NJJ.NJJ_CODPRO >= '" + MV_PAR15 + "' AND NJJ.NJJ_CODPRO <= '" + MV_PAR16 + "' "		+ STR_PULA
	cQryAux += " AND NJJ.D_E_L_E_T_<>'*' AND NJJ.NJJ_STATUS<>'4'"		+ STR_PULA
	//cQryAux += " ORDER BY NJJ.NJJ_CODROM"		+ STR_PULA
	cQryAux := ChangeQuery(cQryAux)
	
	//Executando consulta e setando o total da rgua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())
		//Incrementando a rgua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()
		
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		QRY_AUX->(DbSkip())
	EndDo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())
	
	RestArea(aArea)
Return
