#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"

#DEFINE ENTER  Chr(13) + Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} MAS06R01
Controle Contrato Tip Bank
@author  TSCB24 - Vangunther Bohn Junior
@since  "05/03/2021"
@update Thiago.Zoppi 12/03/2021
/*/
//-------------------------------------------------------------------
User Function MAS06R01()
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Declaracao de variaveis                   ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Private oReport  := Nil
	Private oSecCab	 := Nil
	Private oSecTot	 := Nil
	Private oBreak	 := Nil

	Private cPerg 	 := "RSFT001" // PadR("RSFT001", Len(SX1->X1_GRUPO))

	If Pergunte(cPerg,.T.) //Pergunta para afunilar a consulta
		ReportDef()
		oReport:PrintDialog()
	EndIf

Return Nil


Static Function ReportDef()

	Private nLast := 0

	oReport := TReport():New("MAS06R01","Controle Contrato Tip Bank",/*cPerg*/,{|oReport| PrintReport(oReport)},"Impress„o Tip Bank.")
	oReport:SetLandscape(.T.)

	oSecCab := TRSection():New( oReport , "TIPBANK", {"QRY"}, , .F., .T. )
	TRCell():New( oSecCab, "DATASE5"                , "QRY","Data"         ,"@!",10)
	TRCell():New( oSecCab, "CONTRATO_TIP"           , "QRY","Contrato"     ,"@!",25)
	TRCell():New( oSecCab, "DESCRICAO_MOVIMENTACAO" , "QRY","Movimentacao" ,"@!",30)
	TRCell():New( oSecCab, "OBSERVACAO"             , "QRY","Obs"          ,"@!",40)
	TRCell():New( oSecCab, "TIPO_OPERACAO"          , "QRY","OperaÁaı"     ,"@!",20)
	TRCell():New( oSecCab, "VALOR"                  , "QRY","Valor"        ,"@E 999,999,999.99",12)
	TRCell():New( oSecCab, "NOME_BANCO"             , "QRY","Banco"        ,"@!",15)
	TRCell():New( oSecCab, "BANCO"                  , "QRY","Cod Banco"    ,"@!",10)
	TRCell():New( oSecCab, "AGENCIA"                , "QRY","Agencia"      ,"@!",10)
	TRCell():New( oSecCab, "CONTA"                  , "QRY","Conta"        ,"@!",10)
	TRCell():New( oSecCab, "BENEFICIARIO"           , "QRY","Beneficiario" ,"@!",30)

	oSecTot := TRSection():New( oReport , "TOTAL"  , {"QRY"},                         , .F.          , .T. )
	TRCell():New( oSecTot               , "VALORC" , "QRY"   ,"Entrada"                  ,PesqPict("SE5","E5_VALOR"),12)
	TRCell():New( oSecTot               , "VALORD" , "QRY"   ,"Saida"                  ,PesqPict("SE5","E5_VALOR"),12)
	TRCell():New( oSecTot               , "VALORSAL" , "QRY" ,"Saldo" ,PesqPict("SE5","E5_VALOR"),12)


	//oReport:SetTotalInLine(.F.)

	oBreak := TRBreak():New(oSecCab,oSecCab:Cell("DATASE5"),"                                                                                                  Total Saldo MovimentaÁ„o di·ria:") //TRBreak() Faz a quebra por AFU_DATA
	//TRFunction():New(oSecCab:Cell("VALOR"),"VALOR" ,"SUM",oBreak,,"@E 999,999,999.99",,.T.,.F.) //FunÁ„o de totalizador dentro do oBreak

	//nLast := oSecCab:GetFunction("VALOR"):GetLastValue()
	// oBreak1 := TRBreak():New(oSecCab,oSecCab:Cell("DATASE5"),"DiferenÁa dia anterior:")
	//bBlock :=  TRFunction():GetLastValue() - oReport:GetFunction("VALOR"):GetValue()
	//  TRFunction():New(oSecCab:Cell("VALOR"), "VALOR" , 'SUM' , /*oBreak1*/ , '' , "@E 999,999,999.99" ,/*{||oSecCab:GetFunction("VALOR"):GetLastValue() - nLast}*/,.T. , .F., /*<lEndPage>*/ , /*<oParent>*/ , /*<bCondition>*/, /*<lDisable>*/ , /*<bCanPrint>*/ )
	//oReport:GetFunction("VALOR"):uReport := (oReport:GetFunction("VALOR"):GetValue())//TRFunction():GetLastValue()
	//TRFunction():New(oSection1:Cell("nCusto"),NIL,"ONPRINT",oBreak,"",cPictVl,{|| oSection1:GetFunction("CALC_AP2"):GetLastValue()/oSection1:GetFunction("CALC_MOV"):GetLastValue() },.F.,.T.)

Return Nil

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  PrintReport     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function PrintReport(oReport)

	Local cQuery     := ""
	Local nTotald    := 0
	Local nTotalc    := 0
	Local nSaldoAtu  := 0
	Local cData      := ""
	Local lInicio    := .T.
	Local nSldAnt	:= 0
	
	cQuery += " SELECT  CONVERT(VARCHAR(10),CONVERT(date,E5.E5_DATA,103),103) AS DATASE5, E5_TIPO, E5_PREFIXO, E5_NUMERO, E5_CLIFOR, E5_PARCELA, E5_RECPAG, " + ENTER
    /* Verifico o n˙mero do contrato na Tip Bank */
	cQuery += "     CASE    WHEN E5.E5_TIPO ='PA' AND E5.E5_MOEDA IN ('01','02') AND E5.E5_TIPODOC ='PA' THEN ( SELECT TOP 1 TQ.DTQ_IDOPE" + ENTER
	cQuery += "                                                                                               FROM  " + RetSqlName("DTQ") + " AS TQ " + ENTER
	cQuery += "                                                                                              WHERE  TQ.DTQ_FILIAL = E5.E5_FILIAL " + ENTER
	cQuery += "                                                                                                AND TQ.DTQ_VIAGEM = E5.E5_NUMERO " + ENTER
	cQuery += "                                                                                                AND TQ.D_E_L_E_T_='' )" + ENTER
	cQuery += "             WHEN E5.E5_TIPO ='CAR' AND E5.E5_MOEDA IN ('01','02') AND E5.E5_TIPODOC ='VL' THEN ( SELECT TOP 1 TQ.DTQ_IDOPE" + ENTER
	cQuery += "                                                                                               FROM  " + RetSqlName("DTQ") + " AS TQ " + ENTER
	cQuery += "                                                                                              WHERE  TQ.DTQ_FILIAL = E5.E5_FILIAL" + ENTER
	cQuery += "                                                                                                AND TQ.DTQ_VIAGEM = (SELECT TOP 1 TY.DTY_VIAGEM" + ENTER
	cQuery += "                                                                                                                       FROM " + RetSqlName("DTY") + " AS TY" + ENTER
	cQuery += "                                                                                                                      WHERE TY.D_E_L_E_T_ =''" + ENTER
	cQuery += "                                                                                                                        AND SUBSTRING(TY.DTY_FILIAL,1,4) =  E5.E5_FILIAL" + ENTER
	cQuery += "                                                                                                                        AND TY.DTY_NUMCTC = E5.E5_NUMERO) )" + ENTER
	cQuery += "             WHEN E5.E5_MOEDA = 'M1' AND E5.E5_PREFIXO ='CQ' THEN E5.E5_DOCUMEN" + ENTER
	cQuery += "             WHEN E5.E5_MOEDA = 'M1' AND E5.E5_PREFIXO ='CP' THEN E5.E5_DOCUMEN" + ENTER
	cQuery += "             WHEN E5.E5_MOEDA IN ('01','M1') AND E5.E5_PREFIXO IN ('CQ','CP','TX','CAR') AND E5.E5_TIPO = '' AND E5.E5_TIPODOC = '' THEN E5.E5_DOCUMEN" + ENTER
	cQuery += "             WHEN E5.E5_TIPODOC = 'ES' AND E5.E5_HISTOR IN ('Exclusao de Titulo PA') THEN IIF( (SELECT TOP 1 TQ.DTQ_IDOPE" + ENTER
	cQuery += "                                                                                               FROM  " + RetSqlName("DTQ") + " AS TQ " + ENTER
	cQuery += "                                                                                              WHERE  TQ.DTQ_FILIAL = E5.E5_FILIAL " + ENTER
	cQuery += "                                                                                                AND TQ.DTQ_VIAGEM = TRIM(SUBSTRING(E5.E5_KEY,4,6))) =''," + ENTER
	cQuery += "                                                                                                    CONCAT('TMS: ',TRIM(SUBSTRING(E5.E5_KEY,4,6)))," + ENTER
	cQuery += "                                                                                                    (SELECT TQ.DTQ_IDOPE" + ENTER
	cQuery += "                                                                                                               FROM  " + RetSqlName("DTQ") + " AS TQ " + ENTER
	cQuery += "                                                                                                              WHERE  TQ.DTQ_FILIAL = E5.E5_FILIAL " + ENTER
	cQuery += "                                                                                                                AND TQ.DTQ_VIAGEM = TRIM(SUBSTRING(E5.E5_KEY,4,6))))" + ENTER
	cQuery += "             WHEN E5.E5_TIPODOC = 'PA' AND E5.E5_TIPO =' ' THEN IIF( (SELECT TOP 1 TQ.DTQ_IDOPE" + ENTER
	cQuery += "                                                                       FROM  " + RetSqlName("DTQ") + " AS TQ " + ENTER
	cQuery += "                                                                      WHERE  TQ.DTQ_FILIAL = E5.E5_FILIAL " + ENTER
	cQuery += "                                                                        AND TQ.DTQ_VIAGEM = TRIM(SUBSTRING(E5.E5_KEY,4,6))) =''," + ENTER
	cQuery += "                                                                             CONCAT('TMS: ',TRIM(SUBSTRING(E5.E5_KEY,4,6)))," + ENTER
	cQuery += "                                                                               (SELECT TOP 1 TQ.DTQ_IDOPE" + ENTER
	cQuery += "                                                                                  FROM  " + RetSqlName("DTQ") + " AS TQ " + ENTER
	cQuery += "                                                                                  WHERE  TQ.DTQ_FILIAL = E5.E5_FILIAL " + ENTER
	cQuery += "                                                                                    AND TQ.DTQ_VIAGEM = TRIM(SUBSTRING(E5.E5_KEY,4,6))))      " + ENTER
	cQuery += "     ELSE ''" + ENTER
	cQuery += "    END CONTRATO_TIP," + ENTER

    /* Ajusto a descriÁ„o para ficar igual a Tip */
	cQuery += "     CASE WHEN E5.E5_TIPO ='' AND E5.E5_MOEDA ='TB' AND E5.E5_TIPODOC ='TR' THEN 'INSERCAO DE SALDO CLIENTE'" + ENTER
	cQuery += "          WHEN E5.E5_TIPO ='PA' AND E5.E5_MOEDA IN ('01','02') AND E5.E5_TIPODOC ='PA' THEN 'ADIANTAMENTO'" + ENTER
	cQuery += "          WHEN E5.E5_TIPO =' ' AND E5.E5_MOEDA IN ('01','02') AND E5.E5_TIPODOC ='PA' THEN 'ADIANTAMENTO'" + ENTER
	cQuery += "          WHEN E5.E5_TIPO ='CAR' AND E5.E5_MOEDA IN ('01','02') AND E5.E5_TIPODOC ='VL' THEN 'FINALIZACAO'" + ENTER
	cQuery += "          WHEN E5.E5_MOEDA IN ('M1','01') AND E5.E5_PREFIXO ='TX' THEN 'DEBITO TAXAS FATURAMENTO'" + ENTER
	cQuery += "          WHEN E5.E5_MOEDA IN ('M1','01') AND E5.E5_PREFIXO ='CQ' THEN 'CALCULO QUEBRA'" + ENTER
	cQuery += "          WHEN E5.E5_MOEDA IN ('M1','01') AND E5.E5_PREFIXO ='CP' THEN 'CALCULO PERDA'" + ENTER
	cQuery += "          WHEN E5.E5_MOEDA IN ('M1','01') AND E5.E5_PREFIXO ='SC' THEN 'SEGURO DE CARGAR'" + ENTER
	cQuery += "          WHEN E5.E5_MOEDA IN ('M1','01') AND E5.E5_PREFIXO ='CAR' THEN 'FINALIZACAO'" + ENTER
	cQuery += "          WHEN E5.E5_TIPODOC = 'ES' AND E5.E5_HISTOR IN ('Exclusao de Titulo PA')  THEN 'ADIANTAMENTO ESTORNO'  " + ENTER
	cQuery += "     ELSE ''" + ENTER
	cQuery += "     END DESCRICAO_MOVIMENTACAO," + ENTER
    /* Ajusto a ObservaÁ„o para ficar igual a Tip  */  
	cQuery += "     CASE    WHEN  E5.E5_TIPO ='CAR' AND E5.E5_MOEDA IN ('01','02') AND E5.E5_TIPODOC ='VL' THEN CONCAT('VIAGEM:',' '," + ENTER
	cQuery += "                                                                                                     ( SELECT TOP 1 TRIM(TQ.DTQ_IDOPE)" + ENTER
	cQuery += "                                                                                                         FROM  " + RetSqlName("DTQ") + " AS TQ " + ENTER
	cQuery += "                                                                                                         WHERE  TQ.DTQ_FILIAL = E5.E5_FILIAL" + ENTER
	cQuery += "                                                                                                           AND TQ.D_E_L_E_T_ =''" + ENTER
	cQuery += "                                                                                                           AND TQ.DTQ_VIAGEM = (SELECT TOP 1 TY.DTY_VIAGEM" + ENTER
	cQuery += "                                                                                                                                  FROM " + RetSqlName("DTY") + " AS TY" + ENTER
	cQuery += "                                                                                                                                 WHERE TY.D_E_L_E_T_ =''" + ENTER
	cQuery += "                                                                                                                                   AND SUBSTRING(TY.DTY_FILIAL,1,4) =  E5.E5_FILIAL" + ENTER
	cQuery += "                                                                                                                                   AND TY.DTY_NUMCTC = E5.E5_NUMERO)  ),' / ', 'TMS:',(SELECT TOP 1 TY.DTY_VIAGEM" + ENTER
	cQuery += "                                                                                                                                                                                          FROM " + RetSqlName("DTY") + " AS TY" + ENTER
	cQuery += "                                                                                                                                                                                         WHERE TY.D_E_L_E_T_ =''" + ENTER
	cQuery += "                                                                                                                                                                                           AND SUBSTRING(TY.DTY_FILIAL,1,4) =  E5.E5_FILIAL" + ENTER
	cQuery += "                                                                                                                                                                                           AND TY.DTY_NUMCTC = E5.E5_NUMERO))" + ENTER
	cQuery += "             WHEN E5.E5_TIPO ='PA' AND E5.E5_MOEDA IN ('01','02') AND E5.E5_TIPODOC ='PA' THEN CONCAT('VIAGEM:',' ',( SELECT TOP 1 TRIM(TQ.DTQ_IDOPE)" + ENTER
	cQuery += "                                                                                                                       FROM  " + RetSqlName("DTQ") + " AS TQ " + ENTER
	cQuery += "                                                                                                                      WHERE  TQ.DTQ_FILIAL = E5.E5_FILIAL " + ENTER
	cQuery += "                                                                                                                        AND TQ.DTQ_VIAGEM = E5.E5_NUMERO " + ENTER
	cQuery += "                                                                                                                        AND TQ.D_E_L_E_T_='' ), ' / ', 'TMS:', E5.E5_NUMERO)" + ENTER
	cQuery += "             WHEN E5.E5_TIPO ='' AND E5.E5_MOEDA ='TB' AND E5.E5_TIPODOC ='TR' THEN  E5.E5_HISTOR " + ENTER
	cQuery += "             WHEN E5.E5_MOEDA = 'M1' AND E5.E5_PREFIXO ='TX' THEN E5.E5_DOCUMEN" + ENTER
	cQuery += "             WHEN E5.E5_MOEDA IN ('01') AND E5.E5_PREFIXO IN ('CQ','CP','TX','CAR') AND E5.E5_TIPO = '' AND E5.E5_TIPODOC = '' THEN E5.E5_HISTOR" + ENTER
	cQuery += "             WHEN E5.E5_MOEDA = 'M1' AND E5.E5_PREFIXO ='CQ' THEN CONCAT('VIAGEM:',' ',TRIM(E5.E5_DOCUMEN), ' / ', 'TMS:', (SELECT TOP 1 TRIM(TQ.DTQ_VIAGEM)" + ENTER
	cQuery += "                                                                                                         FROM  " + RetSqlName("DTQ") + " AS TQ " + ENTER
	cQuery += "                                                                                                         WHERE TQ.D_E_L_E_T_ =''" + ENTER
	cQuery += "                                                                                                             AND  TQ.DTQ_FILIAL = E5.E5_FILIAL" + ENTER
	cQuery += "                                                                                                             AND  TRIM(TQ.DTQ_IDOPE) = TRIM(E5.E5_DOCUMEN)))" + ENTER
	cQuery += "             WHEN E5.E5_MOEDA = 'M1' AND E5.E5_PREFIXO ='CP' THEN CONCAT('VIAGEM:',' ',TRIM(E5.E5_DOCUMEN), ' / ', 'TMS:', (SELECT TOP 1 TRIM(TQ.DTQ_VIAGEM)" + ENTER
	cQuery += "                                                                                                         FROM  " + RetSqlName("DTQ") + " AS TQ " + ENTER
	cQuery += "                                                                                                         WHERE TQ.D_E_L_E_T_ =''" + ENTER
	cQuery += "                                                                                                             AND  TQ.DTQ_FILIAL = E5.E5_FILIAL" + ENTER
	cQuery += "                                                                                                             AND  TRIM(TQ.DTQ_IDOPE) = TRIM(E5.E5_DOCUMEN)))  " + ENTER
	cQuery += "              WHEN E5.E5_TIPODOC = 'ES' AND E5.E5_HISTOR IN ('Exclusao de Titulo PA') THEN IIF( (SELECT TOP 1 TQ.DTQ_IDOPE" + ENTER
	cQuery += "                                                                                               FROM  " + RetSqlName("DTQ") + " AS TQ " + ENTER
	cQuery += "                                                                                              WHERE  TQ.DTQ_FILIAL = E5.E5_FILIAL " + ENTER
	cQuery += "                                                                                                AND TQ.DTQ_VIAGEM = TRIM(SUBSTRING(E5.E5_KEY,4,6))) =''," + ENTER
	cQuery += "                                                                                                    CONCAT('TMS: ',TRIM(SUBSTRING(E5.E5_KEY,4,6)))," + ENTER
	cQuery += "                                                                                                    CONCAT('VIAGEM: ',(SELECT TOP 1 TQ.DTQ_IDOPE" + ENTER
	cQuery += "                                                                                                               FROM  " + RetSqlName("DTQ") + " AS TQ " + ENTER
	cQuery += "                                                                                                              WHERE  TQ.DTQ_FILIAL = E5.E5_FILIAL " + ENTER
	cQuery += "                                                                                                                AND TQ.DTQ_VIAGEM = TRIM(SUBSTRING(E5.E5_KEY,4,6))), ' / '," + ENTER
	cQuery += "                                                                                                                'TMS: ',TRIM(SUBSTRING(E5.E5_KEY,4,6))" + ENTER
	cQuery += "                                                                                                     ))" + ENTER
	cQuery += "             WHEN E5.E5_TIPODOC = 'PA' AND E5.E5_TIPO =' ' THEN IIF( (SELECT TOP 1 TQ.DTQ_IDOPE" + ENTER
	cQuery += "                                                                       FROM  " + RetSqlName("DTQ") + " AS TQ " + ENTER
	cQuery += "                                                                      WHERE  TQ.DTQ_FILIAL = E5.E5_FILIAL " + ENTER
	cQuery += "                                                                        AND TQ.DTQ_VIAGEM = TRIM(SUBSTRING(E5.E5_KEY,4,6))) =''," + ENTER
	cQuery += "                                                                             CONCAT('TMS: ',TRIM(SUBSTRING(E5.E5_KEY,4,6)))," + ENTER
	cQuery += "                                                                               (SELECT TOP 1 TQ.DTQ_IDOPE" + ENTER
	cQuery += "                                                                                  FROM  " + RetSqlName("DTQ") + " AS TQ " + ENTER
	cQuery += "                                                                                  WHERE  TQ.DTQ_FILIAL = E5.E5_FILIAL " + ENTER
	cQuery += "                                                                                    AND TQ.DTQ_VIAGEM = TRIM(SUBSTRING(E5.E5_KEY,4,6))))     " + ENTER
	cQuery += "     ELSE ''" + ENTER
	cQuery += "     END OBSERVACAO," + ENTER
	cQuery += "     IIF(E5.E5_RECPAG ='P','Debito','Credito') AS TIPO_OPERACAO," + ENTER
	cQuery += "     IIF(E5.E5_RECPAG ='P',E5.E5_VALOR * -1,E5.E5_VALOR) AS VALOR," + ENTER
	cQuery += "     A6.A6_NOME AS NOME_BANCO," + ENTER
	cQuery += "     E5.E5_BANCO AS BANCO," + ENTER
	cQuery += "     E5.E5_AGENCIA AS AGENCIA," + ENTER
	cQuery += "     E5.E5_CONTA AS CONTA," + ENTER
	//cQuery += "     E5.E5_BENEF AS BENEFICIARIO " + ENTER
	cQuery += "     CASE WHEN E5.E5_BENEF <> '' THEN E5_BENEF" + ENTER
	cQuery += "          ELSE 'MASUTTI'" + ENTER
	cQuery += "          END AS BENEFICIARIO " + ENTER

	cQuery += "  FROM " + RetSqlName("SE5") + " AS E5" + ENTER
	// cQuery += "  LEFT JOIN DTQ010 AS TQ ON TQ.DTQ_FILIAL = E5.E5_FILIAL AND TQ.DTQ_VIAGEM = E5.E5_NUMERO AND TQ.D_E_L_E_T_=''" + ENTER
	cQuery += "  LEFT JOIN SA6010 AS A6 ON A6.A6_COD = E5.E5_BANCO" + ENTER
	cQuery += "     WHERE E5.D_E_L_E_T_ =''" + ENTER
	cQuery += "         AND E5.E5_BANCO ='998'" + ENTER
	cQuery += "         AND E5.E5_CONTA ='1'" + ENTER
	cQuery += "         AND E5.E5_AGENCIA='1'" + ENTER
	cQuery += "         AND E5.E5_SITUACA <>'C'" + ENTER
	cQuery += "         AND E5.E5_FILIAL ='0201'" + ENTER
	//filtra por data
	If !Empty(MV_PAR01)
		cQuery += "         AND E5.E5_DATA >= '" + DTOS(MV_PAR01) + "' " + ENTER
	EndIf
	If !Empty(MV_PAR02)
		cQuery += "         AND E5.E5_DATA <= '" + DTOS(MV_PAR02) + "' " + ENTER
	EndIf
	cQuery += "     ORDER BY E5.E5_DATA" + ENTER
	cQuery := ChangeQuery(cQuery)

	If Select("QRY") > 0
		Dbselectarea("QRY")
		QRY->(DbClosearea())
	EndIf

	TcQuery cQuery New Alias "QRY"
	oSecCab:Init()
	nSaldoIni := 0

	
	WHILE QRY->(!Eof())

		If oReport:Cancel()
			Exit
		EndIf

		oReport:IncMeter()


		IF QRY->VALOR  < 0
			nTotald += QRY->VALOR
		Else
			nTotalc += QRY->VALOR
		ENDIF
		cData := QRY->DATASE5

		IF QRY->E5_TIPO == "CAR"
			cAliasSE2 := GetNextAlias() 
 
			cQuery := "SELECT R_E_C_N_O_ RECNO,E2_VALOR,E2_TIPO "
			cQuery += "FROM "+RetSqlName("SE2")+" SE2 "
			cQuery += "WHERE SE2.E2_FILIAL='"+xFilial("SE2")+"' AND "
			cQuery += "SE2.E2_PREFIXO	='"+QRY->E5_PREFIXO+"' AND "
			cQuery += "SE2.E2_NUM 		='"+QRY->E5_NUMERO+"' AND "
			cQuery += "SE2.E2_FORNECE 	='"+QRY->E5_CLIFOR+"' AND "
			cQuery += "SE2.E2_TIPO		='NDF' AND "
			cQuery += "SE2.D_E_L_E_T_=' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2,.T.,.T.)
			dbSelectArea(cAliasSE2)

			IF (cAliasSE2)->(!Eof())

				oSecCab:Cell("DATASE5"                 ):SetValue(QRY->DATASE5)
				oSecCab:Cell("CONTRATO_TIP"            ):SetValue(QRY->CONTRATO_TIP)
				oSecCab:Cell("DESCRICAO_MOVIMENTACAO"  ):SetValue(QRY->DESCRICAO_MOVIMENTACAO)
				oSecCab:Cell("OBSERVACAO"              ):SetValue(QRY->OBSERVACAO)
				oSecCab:Cell("TIPO_OPERACAO"           ):SetValue(QRY->TIPO_OPERACAO)
				IF (QRY->E5_RECPAG == 'P')
					oSecCab:Cell("VALOR"                   ):SetValue(QRY->VALOR - (cAliasSE2)->E2_VALOR)
				ELSE
					oSecCab:Cell("VALOR"                   ):SetValue(QRY->VALOR + (cAliasSE2)->E2_VALOR)
				ENDIF
				oSecCab:Cell("NOME_BANCO"              ):SetValue(QRY->NOME_BANCO)
				oSecCab:Cell("BANCO"                   ):SetValue(QRY->BANCO)
				oSecCab:Cell("AGENCIA"                 ):SetValue(QRY->AGENCIA)
				oSecCab:Cell("CONTA"                   ):SetValue(QRY->CONTA)
				oSecCab:Cell("BENEFICIARIO"            ):SetValue(QRY->BENEFICIARIO)

				oSecCab:Printline()

				oSecCab:Cell("DATASE5"                 ):SetValue(QRY->DATASE5)
				oSecCab:Cell("CONTRATO_TIP"            ):SetValue(QRY->CONTRATO_TIP)
				oSecCab:Cell("DESCRICAO_MOVIMENTACAO"  ):SetValue("SEGURO")
				oSecCab:Cell("OBSERVACAO"              ):SetValue(QRY->OBSERVACAO)
				IF (QRY->E5_RECPAG <> 'P')
					oSecCab:Cell("TIPO_OPERACAO"           ):SetValue("D…BITO")
					oSecCab:Cell("VALOR"                   ):SetValue(((cAliasSE2)->E2_VALOR)* -1)
				ELSE
					oSecCab:Cell("TIPO_OPERACAO"           ):SetValue("CR…DITO")
					oSecCab:Cell("VALOR"                   ):SetValue((cAliasSE2)->E2_VALOR)
				ENDIF
				oSecCab:Cell("NOME_BANCO"              ):SetValue(QRY->NOME_BANCO)
				oSecCab:Cell("BANCO"                   ):SetValue(QRY->BANCO)
				oSecCab:Cell("AGENCIA"                 ):SetValue(QRY->AGENCIA)
				oSecCab:Cell("CONTA"                   ):SetValue(QRY->CONTA)
				oSecCab:Cell("BENEFICIARIO"            ):SetValue(QRY->BENEFICIARIO)

				oSecCab:Printline()

			ELSE
				oSecCab:Cell("DATASE5"                 ):SetValue(QRY->DATASE5)
				oSecCab:Cell("CONTRATO_TIP"            ):SetValue(QRY->CONTRATO_TIP)
				oSecCab:Cell("DESCRICAO_MOVIMENTACAO"  ):SetValue(QRY->DESCRICAO_MOVIMENTACAO)
				oSecCab:Cell("OBSERVACAO"              ):SetValue(QRY->OBSERVACAO)
				oSecCab:Cell("TIPO_OPERACAO"           ):SetValue(QRY->TIPO_OPERACAO)
				oSecCab:Cell("VALOR"                   ):SetValue(QRY->VALOR)
				oSecCab:Cell("NOME_BANCO"              ):SetValue(QRY->NOME_BANCO)
				oSecCab:Cell("BANCO"                   ):SetValue(QRY->BANCO)
				oSecCab:Cell("AGENCIA"                 ):SetValue(QRY->AGENCIA)
				oSecCab:Cell("CONTA"                   ):SetValue(QRY->CONTA)
				oSecCab:Cell("BENEFICIARIO"            ):SetValue(QRY->BENEFICIARIO)

				oSecCab:Printline()
			ENDIF	

			(cAliasSE2)->(DbCloseArea())

		ELSE
			oSecCab:Cell("DATASE5"                 ):SetValue(QRY->DATASE5)
			oSecCab:Cell("CONTRATO_TIP"            ):SetValue(QRY->CONTRATO_TIP)
			oSecCab:Cell("DESCRICAO_MOVIMENTACAO"  ):SetValue(QRY->DESCRICAO_MOVIMENTACAO)
			oSecCab:Cell("OBSERVACAO"              ):SetValue(QRY->OBSERVACAO)
			oSecCab:Cell("TIPO_OPERACAO"           ):SetValue(QRY->TIPO_OPERACAO)
			oSecCab:Cell("VALOR"                   ):SetValue(QRY->VALOR)
			oSecCab:Cell("NOME_BANCO"              ):SetValue(QRY->NOME_BANCO)
			oSecCab:Cell("BANCO"                   ):SetValue(QRY->BANCO)
			oSecCab:Cell("AGENCIA"                 ):SetValue(QRY->AGENCIA)
			oSecCab:Cell("CONTA"                   ):SetValue(QRY->CONTA)
			oSecCab:Cell("BENEFICIARIO"            ):SetValue(QRY->BENEFICIARIO)

			oSecCab:Printline()
		ENDIF

		QRY->(DBSKIP())

		//Imprime Section TOTAL e Saldo
		IF !(cData == QRY->DATASE5) .OR. QRY->(EOF())

			/* IF lInicio
				nSaldoAtu := nTotal
			ELSE
				nSaldoAtu :=  nTotal + nSaldoAtu
			ENDIF */ 
			//nSaldoAtu := CalcSld(dtos(MV_PAR01))  // Pega o Saldo Inicial

			//Ajuste feito por Johnny, para pegar o primeiro Saldo inicial e calcular a partir dele
			IF lInicio						
				nSaldoAtu 	:=  nTotalc +nTotald + CalcSld(dtos(ctod(cData)))  //Saldo  nSaldoAtu + despesa 
				nSldAnt 	:= nSaldoAtu
			else 
				nSaldoAtu := nTotalc +nTotald + nSldAnt 
				nSldAnt 	:= nSaldoAtu
			endif
			oSecTOT:Init()
			oSecTOT:Cell("VALORC"):SetValue(nTotalc)
			oSecTOT:Cell("VALORD"):SetValue(nTotald)
			oSecTOT:Cell("VALORSAL"):SetValue(nSaldoAtu)
			oSecTOT:Printline()
			oSecTOT:Finish()

			nTotald  := 0
			nTotalc  := 0
			lInicio := .F.

		EndIf

	ENDDO

	oSecTOT:Finish()
	//oSecCab:Finish()

 /*   oSecCab:setQuery("QRY",cQuery)
    oSecCab:Print()*/

Return Nil


Static Function CalcSld(cdata)
	
	Local cBanco 	:= PadR('998',TAMSX3("E8_BANCO")[1])
	Local cAg 		:= PadR('1',TAMSX3("E8_AGENCIA")[1])
	Local cConta    := PadR('1',TAMSX3("E8_CONTA")[1])
	Local nSaldoAtu := 0 
	dbSelectArea("SE8")
	dbSetOrder(1)
	If 	dbSeek(xFilial("SE8")+cBanco+cAg+cConta+cdata,.T.)
		dbSkip(-1)
		nSaldoAtu := SE8->E8_SALATUA
	EndIf
	

Return nSaldoAtu
