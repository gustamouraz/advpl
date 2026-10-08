#include 'protheus.ch'
#include "rwmake.ch"
#include 'topconn.ch'

User Function LMRTMS01()
	Local   oReport
	Private cPerg   	:= "LMRTMS01"
	Private oSec1 		:= Nil
	Private _cMyAlias	:= GetNextAlias()
 	
	If !Pergunte(cPerg,.T.)
		Return Nil
	EndIf

	oReport  := ReportDef()
	oReport:PrintDialog() 
    
return

Static Function ReportDef(cPerg)

	Local oReport
	Local cNomeRel	:= "afrmm" ///nome arquivo
	Local cTitulo	:= "CT-e - AFRMM" // titulo do pdf
	Local cDescRel	:= "Relatorio de valores do AFRMM de CT-e Fluvial" ///descrição na geracao do arquivo

	oReport  := TReport():New( cNomeRel, cTitulo, cPerg, { | oReport | ReportPrint( oReport ) }, cDescRel )
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
	oReport:Page()

	oSec1  :=  TRSection():New(oReport, "CT-e Fluvial") ///nome planilha

	TRCell():New(oSec1,"FILIAL"		,,"Filial"				,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"CTE"		,,"CT-e"				,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"SERIE"		,,"Série"				,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"DATA"		,,"Data CT-e"			,"@D"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"VAL_FRETE"	,,"Vlr Frete"			,"@E 999,999,999.999999",,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"AFRMM"		,,"AFRMM"				,"@E 999,999,999.999999",,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"NF_CLIEN"	,,"NF Cliente"			,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"MANIFES"	,,"Manifesto"			,"@!"					,,,,,.T.,,,,.T.,,,.T.)
	TRCell():New(oSec1,"SISTEMA"	,,"Sistema"				,"@!"					,,,,,.T.,,,,.T.,,,.T.)

return( oReport )

Static Function ReportPrint( oReport )
	Local nTotal		:= 0
	Local nAtual 		:= 0
	Local aAreaAtual	:= {}

	Default _cMyAlias	:= GetNextAlias()


	oSec1 := oReport:Section(1)

	BeginSql alias _cMyAlias
		%noParser%
		WITH ManifestosUnicos AS (
    SELECT
        DL2_FILIAL,
        DL2_DOC,
        DL2_SERIE,
        STRING_AGG(CONCAT(DL2_MANIFE,'-',DL2_SERMAN),' | ') AS MANIFES_UNICO
    FROM DL2010 WITH(NOLOCK)
    WHERE D_E_L_E_T_ = ''
    GROUP BY 
        DL2_FILIAL,
        DL2_DOC,
        DL2_SERIE
	)
	SELECT DISTINCT
	     DTC.DTC_FILORI [FILIAL]
	    ,DTC.DTC_DOC [CTE]
	    ,DTC.DTC_SERIE [SERIE]
	    ,(DTC.DTC_DATENT) [DATA]
	    ,DT6.DT6_VALFRE [VAL_FRETE]
	    ,ROUND(DT6.DT6_VALFRE * (SELECT X6_CONTEUD FROM SX6010 WITH(NOLOCK) WHERE X6_VAR = 'MV_ZAFRMM')/100,2) [AFRMM]
	    ,STRING_AGG(CONCAT(DTC.DTC_NUMNFC,'-',DTC.DTC_SERNFC),' | ') [NF_CLIEN]
	    ,MU.MANIFES_UNICO [MANIFES]
	    ,'PROTHEUS' [SISTEMA]
	FROM DTC010 DTC WITH(NOLOCK) 
	INNER JOIN DT6010 DT6 WITH(NOLOCK) ON 
	    DT6.D_E_L_E_T_ = '' AND 
	    DT6_FILIAL = DTC.DTC_FILIAL AND 
	    DT6_DOC = DTC.DTC_DOC AND 
	    DT6_SERIE = DTC.DTC_SERIE 
	LEFT JOIN ManifestosUnicos MU ON
	    MU.DL2_FILIAL = DTC.DTC_FILIAL AND
	    MU.DL2_DOC = DTC.DTC_DOC AND
	    MU.DL2_SERIE = DTC.DTC_SERIE
	WHERE DTC.DTC_ZAQUAV = '1' AND 
	    DTC.D_E_L_E_T_ = '' AND 
	    DTC.DTC_DATENT BETWEEN %Exp:DToS(MV_PAR01)% AND %Exp:DToS(MV_PAR02)%
	GROUP BY
	     DTC.DTC_FILORI
	    ,DTC.DTC_DOC
	    ,DTC.DTC_SERIE
	    ,DTC.DTC_DATENT
	    ,DT6.DT6_VALFRE
	    ,MU.MANIFES_UNICO

	UNION ALL

	SELECT DISTINCT
	     F2_FILIAL
	    ,F2_DOC
	    ,F2_SERIE
	    ,(F2_EMISSAO)
	    ,F2_VALMERC 
	    ,ROUND(F2_VALMERC * (SELECT X6_CONTEUD FROM SX6010 WITH(NOLOCK) WHERE X6_VAR = 'MV_ZAFRMM')/100,2) AFRMM
	    ,''
	    ,''
	    ,'BSOFT' SISTEMA
	FROM SF2010 F2 WITH(NOLOCK)
	WHERE F2_ESPECIE = 'CTE' AND
	    F2_CHVNFE = '' AND 
	    F2.D_E_L_E_T_ = '' AND
	    F2_EMISSAO BETWEEN %Exp:DToS(MV_PAR01)% AND %Exp:DToS(MV_PAR02)%

	ORDER BY [DATA] 
	
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
		oSec1:Cell("FILIAL"		):SetValue((_cMyAlias)->FILIAL		)
		oSec1:Cell("CTE"		):SetValue((_cMyAlias)->CTE			)
		oSec1:Cell("SERIE"		):SetValue((_cMyAlias)->SERIE		)
		oSec1:Cell("DATA"		):SetValue(STOD((_cMyAlias)->DATA)	)
		oSec1:Cell("VAL_FRETE"	):SetValue((_cMyAlias)->VAL_FRETE	)
		oSec1:Cell("AFRMM"		):SetValue((_cMyAlias)->AFRMM		)
		oSec1:Cell("NF_CLIEN"	):SetValue((_cMyAlias)->NF_CLIEN	)
		oSec1:Cell("MANIFES"	):SetValue((_cMyAlias)->MANIFES		)
		oSec1:Cell("SISTEMA"	):SetValue((_cMyAlias)->SISTEMA		)
		oSec1:Printline()

		(_cMyAlias)->(DbSkip())

	Enddo

	oSec1:Finish()

return
