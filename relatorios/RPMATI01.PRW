//Bibliotecas
#Include "TOTVS.ch" 

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)

User Function RPMATI01()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	
	Private cRPMATI01   := GetNextAlias()
	Private cPerg := "RPMATI01"
	 
	 
	If !Pergunte(PadR( cPerg , 10),.T.)
		MsgStop("Não foi possivel localizar as perguntas do grupo " + cPerg, "RPMATI01")
        Return NIL
    EndIf    
	
	//Cria as definies do relatrio
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
 | Desc:  Funo que monta a definio do relatrio                              |
 *-------------------------------------------------------------------------------*/
	
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	
	// Local oBreak := Nil
	
	//Criao do componente de impresso
	oReport := TReport():New(	"RPMATI01",;		//Nome do Relatrio
								"Relatorio",;		//Ttulo
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, ser impresso uma pgina com os parmetros, conforme privilgio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de cdigo que ser executado na confirmao da impresso
								)		//Descrio
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetPortrait()
	
	//Criando a seo de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seo pertence
									"Dados",;		//Descrio da seo
									{cRPMATI01})		//Tabelas utilizadas, a primeira ser considerada como principal da seo
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores sero impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatrio
	TRCell():New(oSectDad, "COD_CAPEX",  cRPMATI01, "Cod. Capex", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ITEM_CAPEX", cRPMATI01, "Item Capex", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

	TRCell():New(oSectDad, "FILIAL", cRPMATI01, "Filial", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TIPOATIVO", cRPMATI01, "Tipo Ativo", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CODDOBEM", cRPMATI01, "Cod. do bem", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ITEM", cRPMATI01, "Item", /*Picture*/, 4, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DESCRICAOGRP", cRPMATI01, "Descricao Grp.", /*Picture*/, 80, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CODGRUPO", cRPMATI01, "Cod. Grupo", /*Picture*/, 4, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DESCRICAO", cRPMATI01, "Descricao", /*Picture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DTAQUISICAO", cRPMATI01, "Dt. Aquisicao", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NUMPLAQUETA", cRPMATI01, "Num Plaqueta", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ANOMODELO", cRPMATI01, "Ano Modelo", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "FORNECEDOR", cRPMATI01, "Fornecedor", /*Picture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CODFORNEC", cRPMATI01, "Cod. Fornec.", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "LOJAFORNEC", cRPMATI01, "Loja Fornec.", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NOTAFISCAL", cRPMATI01, "Nota Fiscal", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NROCHASSIS", cRPMATI01, "Nro Chassis", /*Picture*/, 25, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NUMEROPLACA", cRPMATI01, "Numero Placa", /*Picture*/, 7, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "FROTA", cRPMATI01, "Frota", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CODPRODUTO", cRPMATI01, "Cod. Produto", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "STATUSBEM", cRPMATI01, "Status Bem", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "POTENCIA", cRPMATI01, "Potencia", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "N3_CONTA", cRPMATI01, "Conta", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "N3_CTADEPACUM", cRPMATI01, "Cta. Dep. Acum.", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "N3_CTADESPDEP", cRPMATI01, "Cta. Desp. Dep.", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "N3_DTINDEPREC", cRPMATI01, "Dt. In. Deprec.", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "N3_VALORIGM1", cRPMATI01, "Vlr. do Bem", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "N3_VLMAXDEP", cRPMATI01, "Vlr Max. Deprec.", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "N3_DEPRACUMM1", cRPMATI01, "Deprec. Acum.", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "N3_DEPRMESM1", cRPMATI01, "Deprec. Mês", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "N3_DEPREBALM1", cRPMATI01, "Deprec. Ano", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "N3_CCUSTOBEM", cRPMATI01, "Centro Custo", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "N3_TXANDEPR1", cRPMATI01, "Tx. Anual Deprec.", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)


	TRCell():New(oSectDad, "N1_ZINCENT", cRPMATI01, "D.A.I.", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "N1_XCONSBI", cRPMATI01, "Considera BI?", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TP_CREDITO", cRPMATI01, "Tp Cred PIS/COF", /*Picture*/, 30, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QTD_PARCELAS", cRPMATI01, "Qtd. Parc PIS/COF", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "MESES_DECORRIDOS", cRPMATI01, "Meses Decorridos", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	

	TRCell():New(oSectDad, "BASE_PC_ANO", cRPMATI01, "Base PIS/COF Anual", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VLR_PIS_ANO", cRPMATI01, "Vlr. PIS Balanço", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VLR_COF_ANO", cRPMATI01, "Vlr. COF Balanço", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "BASE_PC_MES", cRPMATI01, "Base PIS/COF Mês", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VLR_PIS_MES", cRPMATI01, "Vlr. PIS Mês", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VLR_COF_MES", cRPMATI01, "Vlr. COF Mês", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

	TRCell():New(oSectDad, "EXC_MES", cRPMATI01, "Vlr. ICM Mes", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "EXC_ANO", cRPMATI01, "Vlr. ICM Ano", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

	TRCell():New(oSectDad, "FN6_DTBAIX", cRPMATI01, "Dt. Baixa", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "MOTIVO", cRPMATI01, "Motivo Baixa", /*Picture*/, 55, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

//	TRCell():New(oSectDad, "VLR_JA_DEPRECIADO", cRPMATI01, "Vlr. J Depreciado?", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//	TRCell():New(oSectDad, "VLR_PIS", cRPMATI01, "Valor PIS", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//	TRCell():New(oSectDad, "VLR_COF", cRPMATI01, "Valor Cofins", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//	TRCell():New(oSectDad, "DEPR_MES", cRPMATI01, "Deprec. Mes", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)



Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Funo que imprime o relatrio       
 
 			OUTER APPLY 

				(SELECT 	SUM(CASE WHEN CL2.CL2_PER LIKE %exp:_cMes% +'%' THEN CL2_VLEXCL ELSE 0 END) AS EXC_MES,
							SUM(CASE WHEN CL2.CL2_PER LIKE %exp:_cAno% +'%' THEN CL2_VLEXCL ELSE 0 END) AS EXC_ANO,
							SUM(CL2_VLEXCL) AS EXC_TOT
				FROM		%table:CL2% CL2 WITH(NOLOCK)
				WHERE		CL2.D_E_L_E_T_ = ''
						AND CL2.CL2_FILIAL = N1.N1_FILIAL
						AND CL2_VLEXCL <> 0 
						AND CL2.CL2_CODATF = N1.N1_CBASE
						AND CL2.CL2_ITATF =  N1.N1_ITEM   ) AS EXC

			PISCOF.BASE_PC_ANO- ISNULL(EXC.EXC_ANO,0) AS BASE_PC_ANO ,
			PISCOF.VLR_PIS_ANO,
			PISCOF.VLR_COF_ANO,
			PISCOF.BASE_PC_MES- ISNULL(EXC.EXC_MES,0) AS BASE_PC_MES ,
			PISCOF.VLR_PIS_MES,
			PISCOF.VLR_COF_MES,						
                                   |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea    := GetArea() 
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	Local _cAno := '%'+ValToSql(SubStr(DtoS(MV_PAR02),1,4))+'%'
	Local _cMes := '%'+ValToSql(SubStr(DtoS(MV_PAR02),1,6))+'%'
		
	//Pegando as sees do relatrio
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	BeginSql Alias cRPMATI01
		%noparser%

		SELECT

			COALESCE(ZGD.ZGD_CODKAP, SC1.C1_ZCODKAP, '') AS COD_CAPEX,
			COALESCE(ZGD.ZGD_ITEM, SC1.C1_ZITEKAP, '') AS ITEM_CAPEX,
				
			N1.N1_FILIAL    AS  FILIAL,
			N3.N3_TIPO      AS  TIPOATIVO,
			N1.N1_CBASE 	AS  CODDOBEM,
			N1.N1_ITEM      AS  ITEM,
			NG.NG_DESCRIC	AS  DESCRICAOGRP,
			N1.N1_GRUPO 	AS  CODGRUPO,
			N1_DESCRIC      AS  DESCRICAO,
			N1.N1_AQUISIC   AS  DTAQUISICAO,
			N1.N1_CHAPA 	AS  NUMPLAQUETA,
			N1.N1_XANOMOD   AS  ANOMODELO,
			A2.A2_NOME      AS  FORNECEDOR,
			N1.N1_FORNEC    AS  CODFORNEC,
			N1.N1_LOJA      AS  LOJAFORNEC,
			N1.N1_NFISCAL   AS  NOTAFISCAL,
			N1.N1_CHASSIS   AS  NROCHASSIS,
			N1.N1_PLACA 	AS  NUMEROPLACA,
			N1.N1_XFROTA    AS  FROTA,
			N1.N1_PRODUTO   AS  CODPRODUTO,
			N1.N1_STATUS    AS  STATUSBEM,
			N1.N1_XPOTATI   AS  POTENCIA,
			N3.N3_CCONTAB   AS  N3_CONTA,
			N3.N3_CCDEPR    AS  N3_CTADEPACUM,
			N3.N3_CDEPREC   AS  N3_CTADESPDEP,
			N3.N3_DINDEPR   AS  N3_DTINDEPREC,
			N3.N3_VORIG1    AS  N3_VALORIGM1,
			N3.N3_VMXDEPR   AS  N3_VLMAXDEP,
			N3.N3_VRDACM1   AS  N3_DEPRACUMM1,
			N3.N3_VRDMES1   AS  N3_DEPRMESM1,
			N3.N3_VRDBAL1   AS  N3_DEPREBALM1,
			N3.N3_CUSTBEM   AS  N3_CCUSTOBEM,
			N3.N3_TXDEPR1   AS  N3_TXANDEPR1 ,
			N1.N1_ZINCENT,
			N1.N1_XCONSBI,
			PISCOF.TP_CREDITO, PISCOF.QTD_PARCELAS, PISCOF.MESES_DECORRIDOS,
			PISCOF.VLR_JA_DEPRECIADO, 
			PISCOF.VLR_PIS, 
			PISCOF.VLR_COF, 
			PISCOF.DEPR_MES,

			ISNULL(EXC.BSA_PIS,0) AS BASE_PC_ANO,
			ISNULL(EXC.VLA_PIS,0) AS VLR_PIS_ANO,
			ISNULL(EXC.VLA_COF,0) AS VLR_COF_ANO,
			ISNULL(EXC.BSM_COF,0) AS BASE_PC_MES,
			ISNULL(EXC.VLM_PIS,0) AS VLR_PIS_MES,
			ISNULL(EXC.VLM_COF,0) AS VLR_COF_MES,
			N1.N1_BAIXA AS FN6_DTBAIX,
			'' AS MOTIVO,
			ISNULL(EXC.EXC_MES,0) AS EXC_MES, 
			ISNULL(EXC.EXC_ANO,0) AS EXC_ANO, 
			ISNULL(EXC.EXC_TOT,0) AS EXC_TOT

		FROM %Table:SN1% N1
			INNER JOIN %Table:SN3% N3 ON 
			N1.N1_CBASE = N3.N3_CBASE AND
				N1.N1_FILIAL = N3.N3_FILIAL AND
				N1.N1_ITEM  = N3.N3_ITEM AND
				N3.D_E_L_E_T_ = ''
			INNER JOIN %Table:SA2% A2 ON
			N1.N1_FORNEC = A2.A2_COD AND
				N1.N1_LOJA  =   A2.A2_LOJA AND
				A2.D_E_L_E_T_ = ''
			INNER JOIN %Table:SNG% NG ON 
			NG.NG_GRUPO = N1.N1_GRUPO AND
				NG.D_E_L_E_T_ = ''
			
		OUTER APPLY (
		SELECT SUM(CASE 
				WHEN CL2.CL2_PER LIKE %exp:_cMes% + '%'
					THEN CL2_VLEXCL
				ELSE 0
				END) AS EXC_MES
		,SUM(CASE 
				WHEN CL2.CL2_PER LIKE %exp:_cAno% + '%'
					THEN CL2_VLEXCL
				ELSE 0
				END) AS EXC_ANO,
		SUM(CASE 
				WHEN CL2.CL2_PER LIKE %exp:_cMes% + '%'
					THEN CL2_BCPIS
				ELSE 0
				END) AS BSM_PIS
		,SUM(CASE 
				WHEN CL2.CL2_PER LIKE %exp:_cMes% + '%'
					THEN CL2_VLPIS
				ELSE 0
				END) AS VLM_PIS,
		SUM(CASE 
				WHEN CL2.CL2_PER LIKE %exp:_cMes% + '%'
					THEN CL2_BCCOF
				ELSE 0
				END) AS BSM_COF
		,SUM(CASE 
				WHEN CL2.CL2_PER LIKE %exp:_cMes% + '%'
					THEN CL2_VLCOF
				ELSE 0
				END) AS VLM_COF,
		SUM(CASE 
				WHEN CL2.CL2_PER LIKE %exp:_cAno% + '%'
					THEN CL2_BCPIS
				ELSE 0
				END) AS BSA_PIS
		,SUM(CASE 
				WHEN CL2.CL2_PER LIKE %exp:_cAno% + '%'
					THEN CL2_VLPIS
				ELSE 0
				END) AS VLA_PIS,
		SUM(CASE 
				WHEN CL2.CL2_PER LIKE %exp:_cAno% + '%'
					THEN CL2_BCCOF
				ELSE 0
				END) AS BSA_COF
		,SUM(CASE 
				WHEN CL2.CL2_PER LIKE %exp:_cAno% + '%'
					THEN CL2_VLCOF
				ELSE 0
				END) AS VLA_COF
		,SUM(CL2_VLEXCL) AS EXC_TOT
		FROM 	%table:CL2% CL2 WITH (NOLOCK)
		WHERE CL2.D_E_L_E_T_ = ''
		AND CL2.CL2_FILIAL = N1.N1_FILIAL
		AND CL2.CL2_CODATF = N1.N1_CBASE
		AND CL2.CL2_ITATF = N1.N1_ITEM
		) AS EXC

			LEFT OUTER JOIN
			(SELECT REL.N1_FILIAL, REL.N1_CBASE, REL.N1_ITEM, REL.N3_TIPO, REL.N3_TXDEPR1,
				REL.TP_CREDITO,
				REL.QTD_PARCELAS,
				REL.N3_VORIG1,
				COUNT(REL.N1_FILIAL) AS MESES_DECORRIDOS,
				SUM(REL.N4_VLROC1) AS VLR_JA_DEPRECIADO,
				ROUND(SUM(CASE WHEN REL.N4_DATA LIKE %Exp:SubStr(DTOS(MV_PAR02),1,4)% +'%' AND REL.N1_CALCPIS IN ('1','3') THEN REL.BASE_PC ELSE 0 END ),2) AS BASE_PC_ANO,
				ROUND(SUM(CASE WHEN REL.N4_DATA LIKE %Exp:SubStr(DTOS(MV_PAR02),1,4)% +'%' AND REL.N1_CALCPIS IN ('1','3') THEN REL.VLR_PIS ELSE 0 END ),2) AS VLR_PIS_ANO,
				ROUND(SUM(CASE WHEN REL.N4_DATA LIKE %Exp:SubStr(DTOS(MV_PAR02),1,4)% +'%' AND REL.N1_CALCPIS IN ('1','3') THEN REL.VLR_COF ELSE 0 END ),2) AS VLR_COF_ANO,
				ROUND(SUM(CASE WHEN REL.N4_DATA LIKE %Exp:SubStr(DTOS(MV_PAR02),1,6)% +'%' AND REL.N1_CALCPIS IN ('1','3') THEN REL.BASE_PC ELSE 0 END ),2) AS BASE_PC_MES,
				ROUND(SUM(CASE WHEN REL.N4_DATA LIKE %Exp:SubStr(DTOS(MV_PAR02),1,6)% +'%' AND REL.N1_CALCPIS IN ('1','3') THEN REL.VLR_PIS ELSE 0 END ),2) AS VLR_PIS_MES,
				ROUND(SUM(CASE WHEN REL.N4_DATA LIKE %Exp:SubStr(DTOS(MV_PAR02),1,6)% +'%' AND REL.N1_CALCPIS IN ('1','3') THEN REL.VLR_COF ELSE 0 END ),2) AS VLR_COF_MES,
				ROUND(SUM( REL.VLR_PIS ),2) AS VLR_PIS,
				ROUND(SUM( REL.VLR_COF ),2) AS VLR_COF,
				MIN(REL.N4_DATA) AS PRIMEIRA,
				MAX(REL.N4_DATA) AS ULTIMA,
				MAX(REL.DEPR_MES) AS DEPR_MES
			FROM
				(SELECT SN1.N1_FILIAL, SN1.N1_CBASE, SN1.N1_ITEM, SN3.N3_TIPO,
					SN1.N1_CALCPIS, SN1.N1_ALIQPIS, SN1.N1_ALIQCOF,
					(CASE WHEN SN1.N1_CALCPIS = '3' THEN rtrim('Fracionado em '+CAST(SN1.N1_MESCPIS AS CHAR(9)))+' meses'   
						WHEN SN1.N1_CALCPIS = '1' AND SN1.N1_CODBCC != '10' THEN 'Segue a depreciao'   
						WHEN SN1.N1_CALCPIS = '1' AND SN1.N1_CODBCC = '10' AND SN1.N1_CBCPIS = '1' THEN 'Aquisio entrada nota'
						ELSE 'Sem aproveitamento de crdito'  
				END) AS TP_CREDITO,
				ROUND((
					CASE 
						WHEN SN1.N1_CALCPIS = '3' THEN SN1.N1_MESCPIS 
						WHEN SN1.N1_CALCPIS = '1' AND SN1.N1_CODBCC = '10' AND SN1.N1_CBCPIS = '1' THEN 1
						ELSE ( CASE WHEN SN3.N3_TXDEPR1 = 0 THEN 0 ELSE 100/SN3.N3_TXDEPR1 * 12 END ) 
					END),2)  AS QTD_PARCELAS,
					SN4.N4_DATA, SN3.N3_TXDEPR1, SN4.N4_VLROC1, SN3.N3_VORIG1,
					CASE 
						WHEN SN1.N1_CALCPIS = '3' THEN SN3.N3_VORIG1/SN1.N1_MESCPIS
						WHEN SN1.N1_CALCPIS = '1' AND SN1.N1_CODBCC = '10' AND SN1.N1_CBCPIS = '1'  AND SUBSTRING(SN1.N1_AQUISIC,1,6) = SUBSTRING(SN4.N4_DATA,1,6) THEN SD1.D1_VUNIT 
						WHEN SN1.N1_CALCPIS = '1' AND SN1.N1_CODBCC = '10' AND SN1.N1_CBCPIS = '1'  AND SUBSTRING(SN1.N1_AQUISIC,1,6) != SUBSTRING(SN4.N4_DATA,1,6) THEN 0
						ELSE SN4.N4_VLROC1
					END AS BASE_PC,   
					CASE 
						WHEN SN1.N1_CALCPIS = '3' THEN SN3.N3_VORIG1*SN1.N1_ALIQPIS/100/SN1.N1_MESCPIS 
						WHEN SN1.N1_CALCPIS = '1' AND SN1.N1_CODBCC = '10' AND SN1.N1_CBCPIS = '1' AND SUBSTRING(SN1.N1_AQUISIC,1,6) = SUBSTRING(SN4.N4_DATA,1,6)   THEN (CASE WHEN SD1.D1_QUANT <> 0 THEN SD1.D1_VALIMP6/SD1.D1_QUANT ELSE 0 END)
						WHEN SN1.N1_CALCPIS = '1' AND SN1.N1_CODBCC = '10' AND SN1.N1_CBCPIS = '1' AND SUBSTRING(SN1.N1_AQUISIC,1,6) != SUBSTRING(SN4.N4_DATA,1,6)   THEN 0
						ELSE SN4.N4_VLROC1*SN1.N1_ALIQPIS/100 
					END  AS VLR_PIS,   
					CASE 
						WHEN SN1.N1_CALCPIS = '3' THEN SN3.N3_VORIG1*SN1.N1_ALIQCOF/100/SN1.N1_MESCPIS 
						WHEN SN1.N1_CALCPIS = '1' AND SN1.N1_CODBCC = '10' AND SN1.N1_CBCPIS = '1' AND SUBSTRING(SN1.N1_AQUISIC,1,6) = SUBSTRING(SN4.N4_DATA,1,6)  THEN (CASE WHEN SD1.D1_QUANT <> 0 THEN  SD1.D1_VALIMP5/SD1.D1_QUANT ELSE 0 END)
						WHEN SN1.N1_CALCPIS = '1' AND SN1.N1_CODBCC = '10' AND SN1.N1_CBCPIS = '1' AND SUBSTRING(SN1.N1_AQUISIC,1,6) != SUBSTRING(SN4.N4_DATA,1,6)   THEN 0
						ELSE SN4.N4_VLROC1*SN1.N1_ALIQCOF/100 
					END  AS VLR_COF,  
					CASE 
					WHEN SN4.N4_DATA = %Exp:DTOS(MV_PAR02)%
					THEN SN4.N4_VLROC1 
					ELSE 0 
				END AS DEPR_MES
				FROM %Table:SN1% SN1 WITH (NOLOCK) 
				INNER JOIN SN4010 SN4 WITH (NOLOCK) 
					ON  SN1.N1_FILIAL = SN4.N4_FILIAL
					AND SN1.N1_CBASE = SN4.N4_CBASE
					AND SN1.N1_ITEM = SN4.N4_ITEM
					AND SN4.D_E_L_E_T_ = ''
				INNER JOIN %Table:SN3% SN3 WITH (NOLOCK) 
					ON SN3.N3_FILIAL = SN1.N1_FILIAL
					AND SN3.N3_CBASE = SN1.N1_CBASE
					AND SN3.N3_ITEM = SN1.N1_ITEM
					AND SN3.N3_TIPO = SN4.N4_TIPO
					AND SN3.D_E_L_E_T_ = ''
				LEFT JOIN  %Table:SD1%   SD1 WITH(NOLOCK) 
					ON SD1.D1_FILIAL = SN1.N1_FILIAL 
					AND SD1.D1_SERIE = SN1.N1_NSERIE
					AND SD1.D1_DOC = SN1.N1_NFISCAL
					AND SD1.D1_ITEM = SN1.N1_NFITEM
					AND SD1.D1_COD = SN1.N1_PRODUTO
					AND SD1.D1_FORNECE = SN1.N1_FORNEC
					AND SD1.D1_LOJA = SN1.N1_LOJA
				AND SD1.D_E_L_E_T_ = ''
				WHERE		SN1.D_E_L_E_T_ = ''
					AND SN4.N4_OCORR IN ('06','20') 
					AND SN4.N4_MOTIVO = ''
					AND SN4.N4_TIPOCNT = '3'  
		) AS REL
			GROUP BY REL.N1_FILIAL, REL.N1_CBASE, REL.N1_ITEM, REL.N3_TIPO, REL.N3_TXDEPR1,  
				REL.TP_CREDITO,  
				REL.QTD_PARCELAS, REL.N3_VORIG1  
		) AS PISCOF ON   
		PISCOF.N1_FILIAL = N1.N1_FILIAL
				AND PISCOF.N1_CBASE = N1.N1_CBASE
				AND PISCOF.N1_ITEM = N1.N1_ITEM
				AND PISCOF.N3_TIPO = N3.N3_TIPO

			//PEDRO AQUI
			LEFT JOIN  %Table:SD1%   SD1 WITH(NOLOCK) 
				// ON SD1.D1_FILIAL = N1.N1_FILIAL 
				ON SD1.D1_SERIE = N1.N1_NSERIE
				AND SD1.D1_DOC = N1.N1_NFISCAL
				AND SD1.D1_ITEM = N1.N1_NFITEM
				AND SD1.D1_COD = N1.N1_PRODUTO
				AND SD1.D1_FORNECE = N1.N1_FORNEC
				AND SD1.D1_LOJA = N1.N1_LOJA
			    AND SD1.D_E_L_E_T_ = ''
			
			LEFT JOIN %Table:SC7% SC7 WITH(NOLOCK)
				ON SC7.C7_FILIAL = SD1.D1_FILIAL
				AND SC7.C7_NUM  = SD1.D1_PEDIDO
				AND SC7.C7_FORNECE = SD1.D1_FORNECE
				AND SC7.C7_PRODUTO = SD1.D1_COD 
				AND SC7.C7_ITEM = SD1.D1_ITEMPC
				AND SC7.D_E_L_E_T_ = ''

			LEFT JOIN %Table:SC1% SC1 WITH(NOLOCK)
				ON SC1.C1_FILIAL = SC7.C7_FILIAL
				AND SC1.C1_NUM = SC7.C7_NUMSC
				AND SC1.C1_ITEM = SC7.C7_ITEMSC
				AND SC1.D_E_L_E_T_ = ''

			LEFT JOIN %Table:ZGD% ZGD WITH(NOLOCK)
				ON ZGD.ZGD_FILIAL = SC1.C1_FILIAL
				AND ZGD.ZGD_CODKAP = SC1.C1_ZCODKAP
				AND ZGD.ZGD_ITEM = SC1.C1_ZITEKAP	
				AND ZGD.D_E_L_E_T_ = ''


		WHERE 	
			N1.N1_FILIAL BETWEEN %Exp:MV_PAR03% AND  %Exp:MV_PAR04%		
			AND N1.N1_AQUISIC BETWEEN %Exp:DTOS(MV_PAR01)% AND  %Exp:DTOS(MV_PAR02)%
			AND N1.N1_STATUS = '1'
			AND N1.%NotDel%
			AND (N1.N1_BAIXA = '' OR N3.N3_TIPO = '03')			AND (N1.N1_BAIXA = '' OR N3.N3_TIPO = '03')

		UNION ALL

		SELECT

			COALESCE(ZGD.ZGD_CODKAP, SC1.C1_ZCODKAP, '') AS COD_CAPEX,
			COALESCE(ZGD.ZGD_ITEM, SC1.C1_ZITEKAP, '') AS ITEM_CAPEX,

			N1.N1_FILIAL    AS  FILIAL,
			N3.N3_TIPO      AS  TIPOATIVO,
			N1.N1_CBASE 	AS  CODDOBEM,
			N1.N1_ITEM      AS  ITEM,
			NG.NG_DESCRIC 	AS  DESCRICAOGRP,
			N1.N1_GRUPO 	AS  CODGRUPO,
			N1_DESCRIC      AS  DESCRICAO,
			N1.N1_AQUISIC   AS  DTAQUISICAO,
			N1.N1_CHAPA 	AS  NUMPLAQUETA,
			N1.N1_XANOMOD   AS  ANOMODELO,
			A2.A2_NOME      AS  FORNECEDOR,
			N1.N1_FORNEC    AS  CODFORNEC,
			N1.N1_LOJA      AS  LOJAFORNEC,
			N1.N1_NFISCAL   AS  NOTAFISCAL,
			N1.N1_CHASSIS   AS  NROCHASSIS,
			N1.N1_PLACA 	AS  NUMEROPLACA,
			N1.N1_XFROTA    AS  FROTA,
			N1.N1_PRODUTO   AS  CODPRODUTO,
			N1.N1_STATUS    AS  STATUSBEM,
			N1.N1_XPOTATI   AS  POTENCIA,
			N3.N3_CCONTAB   AS  N3_CONTA,
			N3.N3_CCDEPR    AS  N3_CTADEPACUM,
			N3.N3_CDEPREC   AS  N3_CTADESPDEP,
			N3.N3_DINDEPR   AS  N3_DTINDEPREC,
			N3.N3_VORIG1    AS  N3_VALORIGM1,
			N3.N3_VMXDEPR   AS  N3_VLMAXDEP,
			N3.N3_VRDACM1   AS  N3_DEPRACUMM1,
			N3.N3_VRDMES1   AS  N3_DEPRMESM1,
			N3.N3_VRDBAL1   AS  N3_DEPREBALM1,
			N3.N3_CUSTBEM   AS  N3_CCUSTOBEM,
			N3.N3_TXDEPR1   AS  N3_TXANDEPR1 ,
			N1.N1_ZINCENT,
			N1.N1_XCONSBI,
			PISCOF.TP_CREDITO, PISCOF.QTD_PARCELAS, PISCOF.MESES_DECORRIDOS,
			PISCOF.VLR_JA_DEPRECIADO, PISCOF.VLR_PIS, PISCOF.VLR_COF, PISCOF.DEPR_MES,
			PISCOF.BASE_PC_ANO-EXC.EXC_ANO AS BASE_PC_ANO ,
			PISCOF.VLR_PIS_ANO,
			PISCOF.VLR_COF_ANO,
			PISCOF.BASE_PC_MES-EXC.EXC_MES AS BASE_PC_MES ,
			PISCOF.VLR_PIS_MES,
			PISCOF.VLR_COF_MES,
			FN6.FN6_DTBAIX,
			FN6.FN6_MOTIVO+' - '+X5.X5_DESCRI AS MOTIVO,
			EXC.EXC_MES, EXC.EXC_ANO, EXC.EXC_TOT

		FROM %Table:SN1% N1
			INNER JOIN %Table:SN3% N3 ON 
			N1.N1_CBASE = N3.N3_CBASE AND
				N1.N1_FILIAL = N3.N3_FILIAL AND
				N1.N1_ITEM  = N3.N3_ITEM AND
				N3.D_E_L_E_T_ = ''
			INNER JOIN %Table:SA2% A2 ON
			N1.N1_FORNEC = A2.A2_COD AND
				N1.N1_LOJA  =   A2.A2_LOJA AND
				A2.D_E_L_E_T_ = ''
			INNER JOIN %Table:SNG% NG ON 
			NG.NG_GRUPO = N1.N1_GRUPO AND
				NG.D_E_L_E_T_ = ''
			INNER JOIN %table:FN6% FN6 ON
			FN6.FN6_FILIAL = N1.N1_FILIAL AND
			FN6.FN6_CBASE = N1.N1_CBASE AND
			FN6.FN6_CITEM = N1.N1_ITEM AND
			FN6.D_E_L_E_T_ = '' AND
			FN6.FN6_STATUS != '2'
			INNER JOIN %table:SX5% X5 ON
			X5.X5_TABELA = '16' AND
			X5.X5_CHAVE = FN6.FN6_MOTIVO AND
			X5.D_E_L_E_T_ = ''
			OUTER APPLY 

				(SELECT 	SUM(CASE WHEN CL2.CL2_PER LIKE %exp:_cMes% +'%' THEN CL2_VLEXCL ELSE 0 END) AS EXC_MES,
							SUM(CASE WHEN CL2.CL2_PER LIKE %exp:_cAno% +'%' THEN CL2_VLEXCL ELSE 0 END) AS EXC_ANO,
							SUM(CL2_VLEXCL) AS EXC_TOT
				FROM		%table:CL2% CL2 WITH(NOLOCK)
				WHERE		CL2.D_E_L_E_T_ = ''
						AND CL2.CL2_FILIAL = N1.N1_FILIAL
						AND CL2_VLEXCL <> 0 
						AND CL2.CL2_CODATF = N1.N1_CBASE
						AND CL2.CL2_ITATF =  N1.N1_ITEM   ) AS EXC

			LEFT OUTER JOIN
			(SELECT REL.N1_FILIAL, REL.N1_CBASE, REL.N1_ITEM, REL.N3_TIPO, REL.N3_TXDEPR1,
				REL.TP_CREDITO,
				REL.QTD_PARCELAS,
				REL.N3_VORIG1,
				COUNT(REL.N1_FILIAL) AS MESES_DECORRIDOS,
				SUM(REL.N4_VLROC1) AS VLR_JA_DEPRECIADO,
				ROUND(SUM(CASE WHEN REL.N4_DATA LIKE %Exp:SubStr(DTOS(MV_PAR02),1,4)% +'%' AND REL.N1_CALCPIS IN ('1','3') THEN REL.BASE_PC ELSE 0 END ),2) AS BASE_PC_ANO,
				ROUND(SUM(CASE WHEN REL.N4_DATA LIKE %Exp:SubStr(DTOS(MV_PAR02),1,4)% +'%' AND REL.N1_CALCPIS IN ('1','3') THEN REL.VLR_PIS ELSE 0 END ),2) AS VLR_PIS_ANO,
				ROUND(SUM(CASE WHEN REL.N4_DATA LIKE %Exp:SubStr(DTOS(MV_PAR02),1,4)% +'%' AND REL.N1_CALCPIS IN ('1','3') THEN REL.VLR_COF ELSE 0 END ),2) AS VLR_COF_ANO,
				ROUND(SUM(CASE WHEN REL.N4_DATA LIKE %Exp:SubStr(DTOS(MV_PAR02),1,6)% +'%' AND REL.N1_CALCPIS IN ('1','3') THEN REL.BASE_PC ELSE 0 END ),2) AS BASE_PC_MES,
				ROUND(SUM(CASE WHEN REL.N4_DATA LIKE %Exp:SubStr(DTOS(MV_PAR02),1,6)% +'%' AND REL.N1_CALCPIS IN ('1','3') THEN REL.VLR_PIS ELSE 0 END ),2) AS VLR_PIS_MES,
				ROUND(SUM(CASE WHEN REL.N4_DATA LIKE %Exp:SubStr(DTOS(MV_PAR02),1,6)% +'%' AND REL.N1_CALCPIS IN ('1','3') THEN REL.VLR_COF ELSE 0 END ),2) AS VLR_COF_MES,
				ROUND(SUM( REL.VLR_PIS ),2) AS VLR_PIS,
				ROUND(SUM( REL.VLR_COF ),2) AS VLR_COF,
				MIN(REL.N4_DATA) AS PRIMEIRA,
				MAX(REL.N4_DATA) AS ULTIMA,
				MAX(REL.DEPR_MES) AS DEPR_MES
			FROM
				(SELECT SN1.N1_FILIAL, SN1.N1_CBASE, SN1.N1_ITEM, SN3.N3_TIPO,
					SN1.N1_CALCPIS, SN1.N1_ALIQPIS, SN1.N1_ALIQCOF,
					(CASE WHEN SN1.N1_CALCPIS = '3' THEN rtrim('Fracionado em '+CAST(SN1.N1_MESCPIS AS CHAR(9)))+' meses'   
						WHEN SN1.N1_CALCPIS = '1' AND SN1.N1_CODBCC != '10' THEN 'Segue a depreciao'   
						WHEN SN1.N1_CALCPIS = '1' AND SN1.N1_CODBCC = '10' AND SN1.N1_CBCPIS = '1' THEN 'Aquisio entrada nota'
						ELSE 'Sem aproveitamento de crdito'  
				END) AS TP_CREDITO,
				ROUND((
					CASE 
						WHEN SN1.N1_CALCPIS = '3' THEN SN1.N1_MESCPIS 
						WHEN SN1.N1_CALCPIS = '1' AND SN1.N1_CODBCC = '10' AND SN1.N1_CBCPIS = '1' THEN 1
						ELSE ( CASE WHEN SN3.N3_TXDEPR1 = 0 THEN 0 ELSE 100/SN3.N3_TXDEPR1 * 12 END ) 
					END),2)  AS QTD_PARCELAS,
					SN4.N4_DATA, SN3.N3_TXDEPR1, SN4.N4_VLROC1, SN3.N3_VORIG1,
					CASE 
						WHEN SN1.N1_CALCPIS = '3' THEN SN3.N3_VORIG1/SN1.N1_MESCPIS
						WHEN SN1.N1_CALCPIS = '1' AND SN1.N1_CODBCC = '10' AND SN1.N1_CBCPIS = '1'  AND SUBSTRING(SN1.N1_AQUISIC,1,6) = SUBSTRING(SN4.N4_DATA,1,6) THEN SD1.D1_VUNIT 
						WHEN SN1.N1_CALCPIS = '1' AND SN1.N1_CODBCC = '10' AND SN1.N1_CBCPIS = '1'  AND SUBSTRING(SN1.N1_AQUISIC,1,6) != SUBSTRING(SN4.N4_DATA,1,6) THEN 0
						ELSE SN4.N4_VLROC1
					END AS BASE_PC,   
					CASE 
						WHEN SN1.N1_CALCPIS = '3' THEN SN3.N3_VORIG1*SN1.N1_ALIQPIS/100/SN1.N1_MESCPIS 
						WHEN SN1.N1_CALCPIS = '1' AND SN1.N1_CODBCC = '10' AND SN1.N1_CBCPIS = '1' AND SUBSTRING(SN1.N1_AQUISIC,1,6) = SUBSTRING(SN4.N4_DATA,1,6)   THEN (CASE WHEN SD1.D1_QUANT <> 0 THEN SD1.D1_VALIMP6/SD1.D1_QUANT ELSE 0 END)
						WHEN SN1.N1_CALCPIS = '1' AND SN1.N1_CODBCC = '10' AND SN1.N1_CBCPIS = '1' AND SUBSTRING(SN1.N1_AQUISIC,1,6) != SUBSTRING(SN4.N4_DATA,1,6)   THEN 0
						ELSE SN4.N4_VLROC1*SN1.N1_ALIQPIS/100 
					END  AS VLR_PIS,   
					CASE 
						WHEN SN1.N1_CALCPIS = '3' THEN SN3.N3_VORIG1*SN1.N1_ALIQCOF/100/SN1.N1_MESCPIS 
						WHEN SN1.N1_CALCPIS = '1' AND SN1.N1_CODBCC = '10' AND SN1.N1_CBCPIS = '1' AND SUBSTRING(SN1.N1_AQUISIC,1,6) = SUBSTRING(SN4.N4_DATA,1,6)  THEN (CASE WHEN SD1.D1_QUANT <> 0 THEN SD1.D1_VALIMP5/SD1.D1_QUANT ELSE 0 END)
						WHEN SN1.N1_CALCPIS = '1' AND SN1.N1_CODBCC = '10' AND SN1.N1_CBCPIS = '1' AND SUBSTRING(SN1.N1_AQUISIC,1,6) != SUBSTRING(SN4.N4_DATA,1,6)   THEN 0
						ELSE SN4.N4_VLROC1*SN1.N1_ALIQCOF/100 
					END  AS VLR_COF,  
					CASE 
					WHEN SN4.N4_DATA = %Exp:DTOS(MV_PAR02)%
					THEN SN4.N4_VLROC1 
					ELSE 0 
				END AS DEPR_MES
				FROM %Table:SN1% SN1 WITH (NOLOCK) 
				INNER JOIN SN4010 SN4 WITH (NOLOCK) 
					ON  SN1.N1_FILIAL = SN4.N4_FILIAL
					AND SN1.N1_CBASE = SN4.N4_CBASE
					AND SN1.N1_ITEM = SN4.N4_ITEM
					AND SN4.D_E_L_E_T_ = ''
				INNER JOIN %Table:SN3% SN3 WITH (NOLOCK) 
					ON SN3.N3_FILIAL = SN1.N1_FILIAL
					AND SN3.N3_CBASE = SN1.N1_CBASE
					AND SN3.N3_ITEM = SN1.N1_ITEM
					AND SN3.N3_TIPO = SN4.N4_TIPO
					AND SN3.D_E_L_E_T_ = ''
				LEFT JOIN  %Table:SD1%   SD1 WITH(NOLOCK) 
					ON SD1.D1_FILIAL = SN1.N1_FILIAL 
					AND SD1.D1_SERIE = SN1.N1_NSERIE
					AND SD1.D1_DOC = SN1.N1_NFISCAL
					AND SD1.D1_ITEM = SN1.N1_NFITEM
					AND SD1.D1_COD = SN1.N1_PRODUTO
					AND SD1.D1_FORNECE = SN1.N1_FORNEC
					AND SD1.D1_LOJA = SN1.N1_LOJA
				AND SD1.D_E_L_E_T_ = ''
				WHERE		SN1.D_E_L_E_T_ = ''
					AND SN4.N4_OCORR IN ('06','20') 
					AND SN4.N4_MOTIVO = ''
					AND SN4.N4_TIPOCNT = '3'  
		) AS REL
			GROUP BY REL.N1_FILIAL, REL.N1_CBASE, REL.N1_ITEM, REL.N3_TIPO, REL.N3_TXDEPR1,  
				REL.TP_CREDITO,  
				REL.QTD_PARCELAS, REL.N3_VORIG1  
		) AS PISCOF ON   
		PISCOF.N1_FILIAL = N1.N1_FILIAL
				AND PISCOF.N1_CBASE = N1.N1_CBASE
				AND PISCOF.N1_ITEM = N1.N1_ITEM
				AND PISCOF.N3_TIPO = N3.N3_TIPO

			//PEDRO AQUI
			LEFT JOIN  %Table:SD1%   SD1 WITH(NOLOCK) 
				// ON SD1.D1_FILIAL = N1.N1_FILIAL 
				ON SD1.D1_SERIE = N1.N1_NSERIE
				AND SD1.D1_DOC = N1.N1_NFISCAL
				AND SD1.D1_ITEM = N1.N1_NFITEM
				AND SD1.D1_COD = N1.N1_PRODUTO
				AND SD1.D1_FORNECE = N1.N1_FORNEC
				AND SD1.D1_LOJA = N1.N1_LOJA
			    AND SD1.D_E_L_E_T_ = ''
			
			LEFT JOIN %Table:SC7% SC7 WITH(NOLOCK)
				ON SC7.C7_FILIAL = SD1.D1_FILIAL
				AND SC7.C7_NUM  = SD1.D1_PEDIDO
				AND SC7.C7_FORNECE = SD1.D1_FORNECE
				AND SC7.C7_PRODUTO = SD1.D1_COD 
				AND SC7.C7_ITEM = SD1.D1_ITEMPC
				AND SC7.D_E_L_E_T_ = ''

			LEFT JOIN %Table:SC1% SC1 WITH(NOLOCK)
				ON SC1.C1_FILIAL = SC7.C7_FILIAL
				AND SC1.C1_NUM = SC7.C7_NUMSC
				AND SC1.C1_ITEM = SC7.C7_ITEMSC
				AND SC1.D_E_L_E_T_ = ''

			LEFT JOIN %Table:ZGD% ZGD WITH(NOLOCK)
				ON ZGD.ZGD_FILIAL = SC1.C1_FILIAL
				AND ZGD.ZGD_CODKAP = SC1.C1_ZCODKAP
				AND ZGD.ZGD_ITEM = SC1.C1_ZITEKAP	
				AND ZGD.D_E_L_E_T_ = ''

				
		WHERE 	
			N1.N1_FILIAL BETWEEN %Exp:MV_PAR03% AND  %Exp:MV_PAR04%		
			//AND N1.N1_AQUISIC BETWEEN %Exp:DTOS(MV_PAR01)% AND  %Exp:DTOS(MV_PAR02)%
			AND N1.N1_STATUS = '1'
			AND N1.%NotDel%
			AND (FN6.FN6_DTBAIX >= '20240101' OR N3.N3_TIPO = '03')			AND (FN6.FN6_DTBAIX >= '20240101' OR N3.N3_TIPO = '03')
	EndSql
  
	 
	//cQryAux := ChangeQuery(cQryAux)
	
	MemoWrite("C:\Temp\rpmati01.sql",GetLastQuery()[2])
	
	//Executando consulta e setando o total da rgua 
	(cRPMATI01)->(DbGoTop())
	Count to nTotal
	(cRPMATI01)->(DbGoTop())

	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	(cRPMATI01)->(DbGoTop())
	While ! (cRPMATI01)->(Eof())
		//Incrementando a rgua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()
		
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		(cRPMATI01)->(DbSkip())
	EndDo
	oSectDad:Finish()
	(cRPMATI01)->(DbCloseArea())
	
	RestArea(aArea)
Return
