#include 'protheus.ch'
#include "rwmake.ch"
#include 'topconn.ch'

User Function RPMAUD01()
	Local   oReport
	Local aFiliais  := AdmGetFil(.F.,.F.)
	Private cPerg   	:= "RPMAUD01"
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
	Local cNomeRel	:= "pedido_nota_variancia" ///nome arquivo
	Local cTitulo	:= "Variancia Pedido x Nota" // titulo do pdf
	Local cDescRel	:= "Relatorio que confornta Pedido e Nota Fiscal e traz aqueles com variância acima da permitida" ///descrição na geracao do arquivo

	oReport  := TReport():New( cNomeRel, cTitulo, cPerg, { | oReport | ReportPrint( oReport ) }, cDescRel )
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
	oReport:Page()

	oSec1  :=  TRSection():New(oReport, "Pedido x Notas") ///nome planilha
	TRCell():New(oSec1,"FILIAL"		,,"Filial"     				,"@!"			          )
	TRCell():New(oSec1,"CODFOR"		,,"Cod. Forn."				,"@!"			          )
	TRCell():New(oSec1,"LOJA"		,,"Loja"					,"@!"			          )
	TRCell():New(oSec1,"FORNECE"	,,"Fornecedor"				,"@!"			          )
	TRCell():New(oSec1,"PEDIDO"		,,"Num. Pedido"				,"@!"			          )
	TRCell():New(oSec1,"EMISSAO"	,,"Dt. Emissão"				,"@D"			          )
	TRCell():New(oSec1,"ITEM_PC"	,,"Item Ped."				,"@!"			          )
	TRCell():New(oSec1,"PRODUTO"	,,"Produto"					,"@!"			          )
	TRCell():New(oSec1,"MOEDA"		,,"Moeda"					,"@!"			          )
	TRCell():New(oSec1,"VALORPC"	,,"Valor Pedido"    		,"@E 999,999,999.999999"  )
	TRCell():New(oSec1,"VALORNF"	,,"Valor Notas"     		,"@E 999,999,999.999999"  )
	TRCell():New(oSec1,"QTDPC"		,,"Qtd. Pedido"     		,"@E 999,999,999.999999"  )
	TRCell():New(oSec1,"QTDNF"		,,"Qtd. Notas"     			,"@E 999,999,999.999999"  )
	TRCell():New(oSec1,"VAR_VALOR"	,,"Var. Valor (%)" 			,"@E 999,999,999.999999"  )
	TRCell():New(oSec1,"VAR_QTD"	,,"Var. Qtd. (%)"  			,"@E 999,999,999.999999"  )
	TRCell():New(oSec1,"NF_IT_CLA"	,,"Nota/Item/Classificador"	,"@!"			          )
	
	
	
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
	SELECT 
		FILIAL ,
		CODFOR,
		LOJA,
		FORNECE,
		PEDIDO,
		EMISSAO,
		ITEM_PC,
		PRODUTO,
		MOEDA,
		VALORPC,
		VALORNF,
		QTDPC,
		QTDNF,
		ROUND( 100 - ((X.VALORPC / X.VALORNF ) * 100),2) 'VAR_VALOR',
		ROUND( 100 - ((X.QTDPC / X.QTDNF ) * 100),2) 'VAR_QTD'
	 FROM (
	    SELECT 
	    D1.D1_FILIAL FILIAL ,
	    A2.A2_COD    CODFOR,
	    A2.A2_LOJA   LOJA,
	    A2.A2_NREDUZ FORNECE,
	    D1.D1_PEDIDO PEDIDO,
		C7.C7_EMISSAO EMISSAO,
	    C7.C7_ITEM ITEM_PC,
	    CONCAT(B1.B1_COD,' - ', RTRIM(B1.B1_DESC),' - ',RTRIM(B1.B1_UM)) PRODUTO,
	    C7.C7_MOEDA  MOEDA,
	    ROUND(C7.C7_PRECO,2) VALORPC,
	    ROUND((SUM(D1.D1_TOTAL) / SUM(D1.D1_QUANT)),2) VALORNF,
	    ROUND(SUM(D1.D1_QTDPEDI),2)  QTDPC,
	    ROUND(SUM(D1.D1_QUANT),2)  QTDNF  
	    FROM SC7010 C7 
	    INNER JOIN SB1010 B1 ON
	        B1.B1_COD = C7.C7_PRODUTO AND
	        B1.D_E_L_E_T_ = ''
	    INNER JOIN SD1010 D1  ON
	        D1.D1_PEDIDO = C7.C7_NUM AND 
	        D1.D1_FILIAL = C7.C7_FILIAL AND 
	        D1.D1_COD = C7.C7_PRODUTO AND
	        D1.D1_ITEMPC = C7.C7_ITEM AND
	        D1.D_E_L_E_T_ = ''
	    INNER JOIN SF1010 F1  ON
	        F1.F1_DOC = D1.D1_DOC AND 
	        F1.F1_FILIAL = D1.D1_FILIAL AND 
	        F1.F1_FORNECE = D1.D1_FORNECE AND
	        F1.F1_LOJA = D1.D1_LOJA AND
	        F1.D_E_L_E_T_ = ''
	    INNER JOIN SA2010 A2 ON 
	        A2.A2_COD = C7.C7_FORNECE AND 
	        A2.A2_LOJA = C7.C7_LOJA AND 
	        A2.D_E_L_E_T_ = ''
	    WHERE C7.D_E_L_E_T_ = ''  
	    AND C7.C7_FORNECE BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
	    AND C7.C7_LOJA BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
	    AND C7.C7_EMISSAO BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
	    AND F1.F1_XDTCLAS BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
	    AND D1.D1_GRUPO NOT IN ('821', '826') 
	    AND D1.D1_QTDPEDI <> '0'
		AND C7.C7_FILIAL IN %Exp:cFilWhere% 

	    GROUP BY 
	    D1.D1_FILIAL ,
	    A2.A2_COD    ,
	    A2.A2_LOJA   ,
	    A2.A2_NREDUZ ,
	    D1.D1_PEDIDO ,
	    C7.C7_MOEDA  , 
	    C7.C7_PRECO  ,
		C7.C7_EMISSAO,
	    C7.C7_ITEM   ,
	    B1.B1_COD    ,
	    B1.B1_UM     ,
	    B1.B1_DESC   
		) X WHERE ((100 - ((X.QTDPC / X.QTDNF ) * 100) > 2) OR ( (100 - ((X.VALORPC / X.VALORNF ) * 100)) > 2)) AND X.MOEDA <> '2' 
    ORDER BY X.FILIAL, X.PEDIDO
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

		oSec1:Cell("FILIAL"   	):SetValue( (_cMyAlias)->FILIAL		)
		oSec1:Cell("CODFOR"   	):SetValue( (_cMyAlias)->CODFOR		)
		oSec1:Cell("LOJA"   	):SetValue( (_cMyAlias)->LOJA		)
		oSec1:Cell("FORNECE"   	):SetValue( (_cMyAlias)->FORNECE	)
		oSec1:Cell("PEDIDO"   	):SetValue( (_cMyAlias)->PEDIDO		)
		oSec1:Cell("EMISSAO"   	):SetValue( STOD((_cMyAlias)->EMISSAO))
		oSec1:Cell("ITEM_PC"   	):SetValue( (_cMyAlias)->ITEM_PC	)
		oSec1:Cell("PRODUTO"   	):SetValue( (_cMyAlias)->PRODUTO	)
		oSec1:Cell("MOEDA"   	):SetValue( (_cMyAlias)->MOEDA		)
		oSec1:Cell("VALORPC"   	):SetValue( (_cMyAlias)->VALORPC	)
		oSec1:Cell("VALORNF"   	):SetValue( (_cMyAlias)->VALORNF	)
		oSec1:Cell("QTDPC"   	):SetValue( (_cMyAlias)->QTDPC		)
		oSec1:Cell("QTDNF"   	):SetValue( (_cMyAlias)->QTDNF		)
		oSec1:Cell("VAR_VALOR"  ):SetValue( (_cMyAlias)->VAR_VALOR	)
		oSec1:Cell("VAR_QTD"   	):SetValue( (_cMyAlias)->VAR_QTD	)
		oSec1:Cell("NF_IT_CLA" 	):SetValue( LMRETNF((_cMyAlias)->FILIAL,(_cMyAlias)->CODFOR,(_cMyAlias)->LOJA,(_cMyAlias)->PEDIDO,(_cMyAlias)->ITEM_PC)	)
		oSec1:Printline()

		(_cMyAlias)->(DbSkip())

	Enddo

	oSec1:Finish()

return

Static Function LMRETNF(cFil, cFor, cLoj, cNum, cItem)

	Local cAlias 	:= GetNextAlias()
	Local cRet 		:= ""

	BeginSql alias cAlias
		%noParser%

		SELECT DISTINCT CONCAT(RTRIM(F1_DOC),' : ',RTRIM(D1_ITEM),' : ',RTRIM(F1_XUSUCLA)) 'NF_IT_CLA' FROM SF1010 
		INNER JOIN SD1010 ON SD1010.D_E_L_E_T_ = '' AND D1_DOC = F1_DOC AND D1_FILIAL = F1_FILIAL AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA

		WHERE SF1010.D_E_L_E_T_ = ''
		AND D1_FILIAL = %Exp:cFil%	
		AND D1_FORNECE = %Exp:cFor%	
		AND D1_PEDIDO = %Exp:cNum%	
		AND D1_ITEMPC = %Exp:cItem%

	EndSql

	While !(cAlias)->(eof())
		cRet += (cAlias)->NF_IT_CLA + ' | '
		(cAlias)->(DbSkip())
	End

return cRet
