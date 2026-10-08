#include 'protheus.ch'
#include "rwmake.ch"
#include 'topconn.ch'

User Function RPMTMS03()
	Local   oReport
	Local aFiliais  := AdmGetFil(.F.,.F.)
	Private cPerg   	:= "RPMTMS03"
	Private oSec1 		:= Nil

	Private cFiliais	:= ""
	Private _cMyAlias	:= GetNextAlias()
 
    If Len(aFiliais) > 0
        cFiliais := AsString(aFiliais)
        cFiliais := StrTran(cFiliais,"{","'")
        cFiliais := StrTran(cFiliais,"}","'")
        cFiliais := StrTran(cFiliais,",","','")
 
		If !Pergunte(cPerg,.T.)
			Return Nil
		EndIf

		oReport  := ReportDef()
		oReport:PrintDialog() 
    Else         
        Help(" ",1,"AF271FIL",,"Selecione a filial para consulta", 1, 0 )
    EndIf
	

return

Static Function ReportDef(cPerg)

	Local oReport
	Local cNomeRel	:= "romaneio_quebra" ///nome arquivo
	Local cTitulo	:= "Romaneios de Quebra" // titulo do pdf
	Local cDescRel	:= "Relatorio de Quebra Romaneios - Logística" ///descrição na geracao do arquivo

	oReport  := TReport():New( cNomeRel, cTitulo, cPerg, { | oReport | ReportPrint( oReport ) }, cDescRel )
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
	oReport:Page()

	oSec1  :=  TRSection():New(oReport, "Quebras") ///nome planilha

	TRCell():New(oSec1,"ORIGEM"		,,"Origem"				,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"FILIAL"		,,"Filial"				,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"TIPO"		,,"Tipo"				,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"ROMANEIO"	,,"Romaneio"			,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"DATROM"		,,"Data Rom."			,"@D"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"CTE"		,,"CTE"					,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"PLACA"		,,"Placa"				,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"NF_CLIENT"	,,"NF Cliente"			,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"DATNF"		,,"Data NF"				,"@D"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"CHAVE"		,,"Chave NF"			,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"COD_TRAN"	,,"Cód. T."				,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"NOM_TRAN"	,,"Transportador"		,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"COD_ENT"	,,"Cód. Ent."			,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"LOJ_ENT"	,,"Loja Ent."			,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"ENTID"		,,"Entidade"			,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"PES_ORI"	,,"Peso Origem"			,"@E 999,999,999.999999",,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"PES_REC"	,,"Peso Recebido"		,"@E 999,999,999.999999",,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"DIF_PES"	,,"Diferença Peso"		,"@E 999,999,999.999999",,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"P_TOL"		,,"0,25% Tolerado"		,"@E 999,999,999.999999",,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"STATUS"		,,"Status"				,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"PES_DESC"	,,"Peso Descontado"		,"@E 999,999,999.999999",,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"VAL_UNI"	,,"Val. Unit."			,"@E 999,999,999.999999",,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"VAL_TOT"	,,"Valor Total NF"		,"@E 999,999,999.999999",,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"VAL_DESC"	,,"Valor Descontado"	,"@E 999,999,999.999999",,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"COD_PRO"	,,"Cód. Prod."			,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"PROD"		,,"Produto"				,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"CONTRATO"	,,"Contrato"			,"@!"					,,,,,.T.,,,,.T.,,,.T.)

return( oReport )

Static Function ReportPrint( oReport )
	Local nTotal		:= 0
	Local nAtual 		:= 0
	Local aAreaAtual	:= {}
	Local cFilWhere 	:= '%('+cFiliais+')%'

	Default _cMyAlias	:= GetNextAlias()


	oSec1 := oReport:Section(1)

	BeginSql alias _cMyAlias
		%noParser%
        SELECT      'Romaneio' ORIGEM,
		    NJJ_FILIAL AS [FILIAL],
			CASE
				WHEN NJJ_TIPO = '1' THEN '(E) ENTRADA POR PRODUCAO'
				WHEN NJJ_TIPO = '2' THEN '(S) REMESSA PARA DEPOSITO'
				WHEN NJJ_TIPO = '3' THEN '(E) ENTRADA PARA DEPOSITO'
				WHEN NJJ_TIPO = '4' THEN '(S) SAIDA POR VENDA'
				WHEN NJJ_TIPO = '5' THEN '(E) ENTRADA POR COMPRA'
				WHEN NJJ_TIPO = '6' THEN '(S) DEVOLUCAO DE DEPOSITO'
				WHEN NJJ_TIPO = '7' THEN '(E) DEVOLUCAO DE REMESSA'
				WHEN NJJ_TIPO = '8' THEN '(S) DEVOLUCAO DE COMPRA'
				WHEN NJJ_TIPO = '9' THEN '(E) DEVOLUCAO DE VENDA'
				WHEN NJJ_TIPO = 'A' THEN '(E) ENTRADA POR TRANSFERÊNCIA'
				WHEN NJJ_TIPO = 'B' THEN '(S) SAÍDA POR TRANSFERÊNCIA'
			END AS [TIPO],
		    NJJ_CODROM AS [ROMANEIO],
		    NJJ_DATA AS [DATROM],
		    CASE WHEN NJJ_XCTE IS NULL THEN TRIM(NJJ_OBS) ELSE TRIM(NJJ_XCTE) END AS [CTE],
		    TRIM(NJJ_PLACA) AS [PLACA],
		    NJJ_DOCNUM AS [NF_CLIENT],
		    NJJ_CHVNFE AS [CHAVE],
            SF1.F1_EMISSAO AS [DATNF],
		    NJJ_CODTRA AS [COD_TRAN],
		    TRIM(A4_NOME) AS [NOM_TRAN],
		    NJJ_CODENT AS [COD_ENT],
		    TRIM(NJJ_LOJENT) AS [LOJ_ENT],
		    TRIM(A1_NOME) AS [ENTID],
		    NJJ_QTDFIS AS [PES_ORI],
		    NJJ_PSSUBT AS [PES_REC],
		    ROUND(NJJ_PSSUBT - NJJ_QTDFIS,4) AS [DIF_PES],
		    ROUND((NJJ_QTDFIS)*0.25/100,3) AS [P_TOL],
		     CASE
		        WHEN (NJJ_PSSUBT - NJJ_QTDFIS) > 0
		            THEN 'DENTRO DA TOLERÂNCIA'
		        WHEN ABS(NJJ_PSSUBT - NJJ_QTDFIS) > ROUND((NJJ_QTDFIS)*0.25/100,3) 
		            THEN 'ACIMA DA TOLERÂNCIA'
		        ELSE 'DENTRO DA TOLERÂNCIA'
		     END AS [STATUS],
		     CASE 
		        WHEN (NJJ_PSSUBT - NJJ_QTDFIS) > 0
		            THEN 0
		        WHEN ABS(NJJ_PSSUBT - NJJ_QTDFIS) > ROUND((NJJ_QTDFIS)*0.25/100,3) 
		            THEN ROUND((ABS((NJJ_PSSUBT - NJJ_QTDFIS))-ROUND((NJJ_QTDFIS)*0.25/100,3)),4)
		     ELSE 0 END AS [PES_DESC],    
		    ROUND(NJJ_VLRUNI,3) AS [VAL_UNI],
		    NJJ_VLRTOT AS [VAL_TOT],
		     CASE 
		        WHEN (NJJ_PSSUBT - NJJ_QTDFIS) > 0
		            THEN 0
		        WHEN ABS(NJJ_PSSUBT - NJJ_QTDFIS) > ROUND((NJJ_QTDFIS)*0.25/100,3) 
		            THEN ROUND((ABS((NJJ_PSSUBT - NJJ_QTDFIS))-ROUND((NJJ_QTDFIS)*0.25/100,3)) * ROUND(NJJ_VLRUNI,3),4)
		     ELSE 0 END AS [VAL_DESC],    
		    NJJ_CODPRO AS [COD_PRO],
		    TRIM(B1_DESC) AS [PROD],
		    NJJ_CODCTR AS [CONTRATO]

		FROM NJJ010 NJJ WITH(NOLOCK)
		INNER JOIN SB1010 SB1 WITH(NOLOCK) ON
		    B1_COD = NJJ_CODPRO AND
		    SB1.D_E_L_E_T_ = ''
		LEFT JOIN SA4010 SA4 WITH(NOLOCK) ON
		    A4_COD = NJJ_CODTRA AND
		    SA4.D_E_L_E_T_ = ''
		LEFT JOIN SA1010 SA1 WITH(NOLOCK) ON
		    A1_COD = NJJ_CODENT AND
		    A1_LOJA = NJJ_LOJENT AND
		    SA1.D_E_L_E_T_ = ''
        LEFT JOIN SF1010 SF1 WITH(NOLOCK) ON
            SF1.D_E_L_E_T_ = '' AND
            SF1.F1_CHVNFE = NJJ.NJJ_CHVNFE AND
            SF1.F1_CHVNFE != ''

		WHERE NJJ.D_E_L_E_T_ = ''
		AND NJJ_TIPO IN ('1','3','5','7','9','A')
		AND NJJ_DATA BETWEEN %Exp:DToS(MV_PAR01)% AND %Exp:DToS(MV_PAR02)%
		AND NJJ_FILIAL IN %Exp:cFilWhere%

    UNION ALL

        SELECT      'Pesagem Avulsa',
		    NJH_FILIAL AS [FILIAL],
			CASE
				WHEN NJH_XTIPO = 'E' THEN 'ENTRADA'
				WHEN NJH_XTIPO = 'S' THEN 'SAÍDA'
			END AS [TIPO],
		    NJH_CODPAV AS [ROMANEIO],
		    NJH_DATA AS [DATROM],
		    CASE WHEN NJH_XCTE IS NULL THEN TRIM(NJH_OBS) ELSE TRIM(NJH_XCTE) END AS [CTE],
		    NJH_PLACA AS [PLACA],
		    '' AS [NF_CLIENT],
		    '' AS [CHAVE],
            '' AS [DATNF],
		    NJH_CODTRA AS [COD_TRAN],
		    TRIM(A4_NOME) AS [NOM_TRAN],
		    NJH_CODENT AS [COD_ENT],
		    TRIM(NJH_LOJENT) AS [LOJ_ENT],
		    TRIM(A1_NOME) AS [ENTID],
		    NJH_XPNF AS [PES_ORI],
		    NJH_PSSUBT AS [PES_REC],
		    ROUND(NJH_PSSUBT - NJH_XPNF,4) AS [DIF_PES],
		    ROUND((NJH_XPNF)*0.25/100,3) AS [P_TOL],
		     CASE
		        WHEN (NJH_PSSUBT - NJH_XPNF) > 0
		            THEN 'DENTRO DA TOLERÂNCIA'
		        WHEN ABS(NJH_PSSUBT - NJH_XPNF) > ROUND((NJH_XPNF)*0.25/100,3) 
		            THEN 'ACIMA DA TOLERÂNCIA'
		        ELSE 'DENTRO DA TOLERÂNCIA'
		     END AS [STATUS],
		     CASE 
		        WHEN (NJH_PSSUBT - NJH_XPNF) > 0
		            THEN 0
		        WHEN ABS(NJH_PSSUBT - NJH_XPNF) > ROUND((NJH_XPNF)*0.25/100,3) 
		            THEN ROUND((ABS((NJH_PSSUBT - NJH_XPNF))-ROUND((NJH_XPNF)*0.25/100,3)),4)
		     ELSE 0 END AS [PES_DESC],    
		    ROUND(D1_VUNIT,3) AS [VAL_UNI],
		    F1_VALMERC AS [VAL_TOT],
		     CASE 
		        WHEN (NJH_PSSUBT - NJH_XPNF) > 0
		            THEN 0
		        WHEN ABS(NJH_PSSUBT - NJH_XPNF) > ROUND((NJH_XPNF)*0.25/100,3) 
		            THEN ROUND((ABS((NJH_PSSUBT - NJH_XPNF))-ROUND((NJH_XPNF)*0.25/100,3)) * ROUND(D1_VUNIT,3),4)
		     ELSE 0 END AS [VAL_DESC],    
		    NJH_CODPRO AS [COD_PRO],
		    TRIM(B1_DESC) AS [PROD],
		    '' AS [CONTRATO]

		FROM NJH010 NJH WITH(NOLOCK)
		INNER JOIN SB1010 SB1 WITH(NOLOCK) ON
		    B1_COD = NJH_CODPRO AND
		    SB1.D_E_L_E_T_ = ''
		LEFT JOIN SA4010 SA4 WITH(NOLOCK) ON
		    A4_COD = NJH_CODTRA AND
		    SA4.D_E_L_E_T_ = ''
		LEFT JOIN SA1010 SA1 WITH(NOLOCK) ON
		    A1_COD = NJH_CODENT AND
		    A1_LOJA = NJH_LOJENT AND
		    SA1.D_E_L_E_T_ = ''
        LEFT JOIN SF1010 SF1 WITH(NOLOCK) ON
            SF1.D_E_L_E_T_ = '' AND
            SF1.F1_DOC = NJH.NJH_XCTE AND
		    SF1.F1_FILIAL = NJH_FILIAL AND
		    SF1.F1_ESPECIE = 'CTE' AND
            SF1.F1_CHVNFE != '' AND
            SF1.F1_DOC != '' 
        LEFT JOIN SD1010 SD1 WITH(NOLOCK) ON
            SD1.D_E_L_E_T_ = '' AND
            SF1.F1_DOC = SD1.D1_DOC AND
            SF1.F1_SERIE = SD1.D1_SERIE AND
		    SF1.F1_FILIAL = SD1.D1_FILIAL AND
		    SF1.F1_FORNECE = SD1.D1_FORNECE AND
		    SF1.F1_LOJA = SD1.D1_LOJA 

		WHERE NJH.D_E_L_E_T_ = ''
		AND NJH_XTIPO IN ('E')
		AND NJH_DATA BETWEEN %Exp:DToS(MV_PAR01)% AND %Exp:DToS(MV_PAR02)%
		AND NJH_FILIAL IN %Exp:cFilWhere%
	
	EndSql

	Count to nTotal
	oReport:SetMeter(nTotal)
	oSec1:Init()

	(_cMyAlias)->(DbGoTop())
		
	While !oReport:Cancel() .AND. !(_cMyAlias)->(Eof())

		nAtual++
		aAreaAtual	:= (GetArea())
		RestArea(aAreaAtual)
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()
		oSec1:Cell("ORIGEM"		):SetValue((_cMyAlias)->ORIGEM		)
		oSec1:Cell("FILIAL"		):SetValue((_cMyAlias)->FILIAL		)
		oSec1:Cell("TIPO"		):SetValue((_cMyAlias)->TIPO		)
		oSec1:Cell("ROMANEIO"	):SetValue((_cMyAlias)->ROMANEIO	)
		oSec1:Cell("DATROM"		):SetValue(STOD((_cMyAlias)->DATROM))
		oSec1:Cell("CTE"		):SetValue((_cMyAlias)->CTE			)
		oSec1:Cell("PLACA"		):SetValue((_cMyAlias)->PLACA		)
		oSec1:Cell("NF_CLIENT"	):SetValue((_cMyAlias)->NF_CLIENT	)
		oSec1:Cell("CHAVE"		):SetValue((_cMyAlias)->CHAVE		)
		oSec1:Cell("DATNF"		):SetValue(STOD((_cMyAlias)->DATNF)	)
		oSec1:Cell("COD_TRAN"	):SetValue((_cMyAlias)->COD_TRAN	)
		oSec1:Cell("NOM_TRAN"	):SetValue((_cMyAlias)->NOM_TRAN	)
		oSec1:Cell("COD_ENT"	):SetValue((_cMyAlias)->COD_ENT		)
		oSec1:Cell("LOJ_ENT"	):SetValue((_cMyAlias)->LOJ_ENT		)
		oSec1:Cell("ENTID"		):SetValue((_cMyAlias)->ENTID		)
		oSec1:Cell("PES_ORI"	):SetValue((_cMyAlias)->PES_ORI		)
		oSec1:Cell("PES_REC"	):SetValue((_cMyAlias)->PES_REC		)
		oSec1:Cell("DIF_PES"	):SetValue((_cMyAlias)->DIF_PES		)
		oSec1:Cell("P_TOL"		):SetValue((_cMyAlias)->P_TOL		)
		oSec1:Cell("STATUS"		):SetValue((_cMyAlias)->STATUS		)
		oSec1:Cell("PES_DESC"	):SetValue((_cMyAlias)->PES_DESC	)
		oSec1:Cell("VAL_UNI"	):SetValue((_cMyAlias)->VAL_UNI		)
		oSec1:Cell("VAL_TOT"	):SetValue((_cMyAlias)->VAL_TOT		)
		oSec1:Cell("VAL_DESC"	):SetValue((_cMyAlias)->VAL_DESC	)
		oSec1:Cell("COD_PRO"	):SetValue((_cMyAlias)->COD_PRO		)
		oSec1:Cell("PROD"		):SetValue((_cMyAlias)->PROD		)
		oSec1:Cell("CONTRATO"	):SetValue((_cMyAlias)->CONTRATO	)
		oSec1:Printline()

		(_cMyAlias)->(DbSkip())

	Enddo

	oSec1:Finish()

return
