//Bibliotecas
#Include "TOTVS.ch" 

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)

User Function LMRTMS02()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	
	Private cLMRTMS02   := GetNextAlias()
	Private cPerg := "LMRTMS02"
	 
	 
	If !Pergunte(PadR( cPerg , 10),.T.)
		MsgStop("Não foi possivel localizar as perguntas do grupo " + cPerg, "LMRTMS02")
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
 | Desc:  Função que monta a definição do relatório                              |
 *-------------------------------------------------------------------------------*/
	
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	
	// Local oBreak := Nil
	
	//Criao do componente de impresso
	oReport := TReport():New(	"LMRTMS02",;		//Nome do Relatrio
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
									{cLMRTMS02})		//Tabelas utilizadas, a primeira ser considerada como principal da seo
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores sero impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatrio
	TRCell():New(oSectDad, "DTC_FILORI", cLMRTMS02, "Filial", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DTC_DOC", cLMRTMS02, "CT-e", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DTC_SERIE", cLMRTMS02, "Série", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DTC_DATENT", cLMRTMS02, "Data", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DTC_NUMNFC", cLMRTMS02, "NF Cliente", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DTC_SERNFC", cLMRTMS02, "Série Cliente", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DTC_NFEID", cLMRTMS02, "Chave NF Cliente", /*Picture*/, 48, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)



Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Função que imprime o relatório       									 |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea    := GetArea() 
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0

	//Pegando as sees do relatrio
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	BeginSql Alias cLMRTMS02
		%noparser%

		SELECT DTC_FILORI
			, DTC_DOC
			, DTC_SERIE
			, DTC_DATENT
			, DTC_NUMNFC
			, DTC_SERNFC
			, DTC_NFEID
		FROM DTC010 WITH(NOLOCK)
		WHERE D_E_L_E_T_ = ''
		AND DTC_DATENT BETWEEN %Exp:MV_PAR01% AND  %Exp:MV_PAR02%
		ORDER BY DTC_DATENT

	EndSql
  
	 
	//cQryAux := ChangeQuery(cQryAux)
	
	MemoWrite("C:\Temp\LMRTMS02.sql",GetLastQuery()[2])
	
	//Executando consulta e setando o total da rgua 
	(cLMRTMS02)->(DbGoTop())
	Count to nTotal
	(cLMRTMS02)->(DbGoTop())

	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	(cLMRTMS02)->(DbGoTop())
	While ! (cLMRTMS02)->(Eof())
		//Incrementando a rgua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()
		
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		(cLMRTMS02)->(DbSkip())
	EndDo
	oSectDad:Finish()
	(cLMRTMS02)->(DbCloseArea())
	
	RestArea(aArea)
Return
