#include 'protheus.ch'
#include "rwmake.ch"
#include 'topconn.ch'

/*/{Protheus.doc} User ZALMOXAR
    @description Relatório Almoxarifado e CD filtra as movimentações diárias de saída de estoque dos armazéns das Unidades
    @type  Function
    @author Luiz Moura
    @since 20/06/2022
    @version 1.0
/*/
User Function ZALMOXAR()
	Local   oReport
	Local aFiliais  := AdmGetFil(.F.,.F.)
	Private cPerg   	:= "ZALMOXAR"
	Private oSec1 		:= Nil

	Private cFiliais	:= ""
	Private cMyAlias	:= GetNextAlias()
 
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

/*/{Protheus.doc} ReportDef
//TODO
@description Report Treport
@author Willian Kaneta
@since 17/03/2017
@version 1.0
@param cPergA, characters, descricao
@type function
/*/
Static Function ReportDef(cPerg)

	Local oReport
	Local cNomeRel	:= "movimentacoes_diarias_v2"
	Local cTitulo	:= "Relatório Movimentações por Produto (Armazem " + MV_PAR03 + " à " + MV_PAR04 + ")"
	Local cDescRel	:= "Movimentações por Produto"
	// Local cUsuario 	:= RetUsrName()

	oReport  := TReport():New( cNomeRel, cTitulo, cPerg, { | oReport | ReportPrint( oReport ) }, cDescRel )
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
	oReport:Page()

	oSec1  :=  TRSection():New(oReport, "Movimentações Cabeçalho + Itens")
	TRCell():New(oSec1,"FILIAL"  		,,"Filial"     		,"@!"			            ,8)
	TRCell():New(oSec1,"DT_MOVI"  		,,"Data Movim."     ,"@!"			            ,14)
	TRCell():New(oSec1,"ARMAZEM"     	,,"Armazém"       	,"@!"			            ,2)
	TRCell():New(oSec1,"ENDERECO"    	,,"Endereço"   		,"@!"			            ,8)
	TRCell():New(oSec1,"COD_DESC"		,,"Produto"			,"@!"			            ,45)
	TRCell():New(oSec1,"LOTE"			,,"Lote"			,"@!"			            ,)
	TRCell():New(oSec1,"Q_ENT"    		,,"Qt. Entrada"  	,"@E 999,999,999.999999"    ,)
	TRCell():New(oSec1,"Q_SAI"    		,,"Qt. Saída"  		,"@E 999,999,999.999999"    ,)
	TRCell():New(oSec1,"SALDATUAL"    	,,"Sld. Atual"  	,"@E 999,999,999.999999"    ,)
	TRCell():New(oSec1,"SALDO_FIS"    	,,"Sld. Físico"  	,"@!"    					,)
	
return( oReport )

/*/{Protheus.doc} ReportPrint
//TODO
@description ReportPrint Treport
@author Willian Kaneta
@since 15/04/2016
@version 1.0
@param oReport , object, descricao
@type function
/*/
Static Function ReportPrint( oReport )
	Local nTotal		:= 0
	Local nAtual 		:= 0
	Local aAreaAtual	:= {}
	Local cFilWhere 	:= '%('+cFiliais+')%'

	Default cMyAlias	:= GetNextAlias()


	oSec1 := oReport:Section(1)

	BeginSql alias cMyAlias
		%noParser%
		SELECT
		    D3_FILIAL AS FILIAL,
		    CONVERT(DATE, D3_EMISSAO, 112) AS [DT_MOVI],
		    D3_LOCAL AS ARMAZEM,
		    TRIM(BZ_XLOCAC) AS ENDERECO,
		    TRIM(CONCAT(D3_COD, ' - ', SB1.B1_DESC)) AS COD_DESC,
		    D3_LOTECTL AS LOTE,
			SUM(CASE WHEN D3_CF LIKE 'DE%' THEN D3_QUANT ELSE 0 END) AS "Q_ENT",
		    SUM(CASE WHEN D3_CF LIKE 'RE%' THEN D3_QUANT ELSE 0 END) AS "Q_SAI",
		    CASE
		        WHEN SD3.D3_LOTECTL != '' THEN SB8.B8_SALDO
		        ELSE SB2.B2_QATU
		    END AS [SALDATUAL],
		    '' AS [SALDO_FIS]
		FROM SD3010 SD3
		INNER JOIN SB1010 SB1
		    ON SD3.D3_COD = SB1.B1_COD
		    AND SB1.D_E_L_E_T_ = ''
		LEFT JOIN SB2010 SB2
		    ON SD3.D3_COD = SB2.B2_COD
		    AND SD3.D3_FILIAL = SB2.B2_FILIAL
		    AND SD3.D3_LOCAL = SB2.B2_LOCAL
		    AND SB2.D_E_L_E_T_ = ''
		LEFT JOIN SB8010 SB8
		    ON SD3.D3_COD = SB8.B8_PRODUTO
		    AND SD3.D3_FILIAL = SB8.B8_FILIAL
		    AND SD3.D3_LOCAL = SB8.B8_LOCAL
		    AND SD3.D3_LOTECTL = SB8.B8_LOTECTL
		    AND SB8.D_E_L_E_T_ = ''
		LEFT JOIN SBZ010 SBZ
		    ON SBZ.BZ_FILIAL = SB2.B2_FILIAL
		    AND SBZ.BZ_COD = SB2.B2_COD
		    AND SBZ.D_E_L_E_T_ = ''
		WHERE D3_EMISSAO BETWEEN %exp:DtoS(MV_PAR01)% AND %EXP:DtoS(MV_PAR02)%
    		AND D3_LOCAL BETWEEN %EXP:MV_PAR03% AND %EXP:MV_PAR04%
    		AND D3_FILIAL IN %Exp:cFilWhere%
		    AND SD3.D3_LOCAL != '95'
		    AND SD3.D_E_L_E_T_ = ''
		    AND SD3.D3_ESTORNO = ''
		    AND NOT EXISTS (
		        SELECT 1
		        FROM SD3010 SD3_TRANSITO
		        WHERE
		            SD3_TRANSITO.D3_COD = SD3.D3_COD
		            AND SD3_TRANSITO.D3_FILIAL = SD3.D3_FILIAL
		            AND SD3_TRANSITO.D3_LOTECTL = SD3.D3_LOTECTL
		            AND SD3_TRANSITO.D3_DOC = SD3.D3_DOC
		            AND SD3_TRANSITO.D3_LOCAL = '95'
		            AND SD3_TRANSITO.D_E_L_E_T_ = ''
		            AND SD3_TRANSITO.D3_ESTORNO = ''
		    )
		
		GROUP BY 
		    		D3_FILIAL, 
		    		D3_LOCAL,  
		    		CONVERT(DATE, D3_EMISSAO, 112),  
		    		D3_COD,
					D3_LOTECTL,
		    		SB1.B1_DESC,  
		    		SB8.B8_SALDO,
		    		BZ_XLOCAC,
		            SB2.B2_QATU
		
		ORDER BY
		    BZ_XLOCAC ASC,
		    D3_FILIAL,
		    D3_LOCAL,
		    CONVERT(DATE, D3_EMISSAO, 112);

	EndSql

	Count to nTotal
	oReport:SetMeter(nTotal)
	oSec1:Init()

	(cMyAlias)->(DbGoTop())
	While !oReport:Cancel() .AND. !(cMyAlias)->(Eof())

		nAtual++
		aAreaAtual	:= (GetArea())
		RestArea(aAreaAtual)
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()

		oSec1:Cell("FILIAL"     ):SetValue( (cMyAlias)->FILIAL				)
		oSec1:Cell("DT_MOVI"    ):SetValue( DTOC((cMyAlias)->DT_MOVI)		)
		oSec1:Cell("ARMAZEM"  	):SetValue( (cMyAlias)->ARMAZEM				)
		oSec1:Cell("ENDERECO"   ):SetValue( (cMyAlias)->ENDERECO			)
		oSec1:Cell("COD_DESC"   ):SetValue( (cMyAlias)->COD_DESC			)
		oSec1:Cell("LOTE"   	):SetValue( (cMyAlias)->LOTE				)
		oSec1:Cell("Q_ENT"    	):SetValue( (cMyAlias)->Q_ENT				)
		oSec1:Cell("Q_SAI"    	):SetValue( (cMyAlias)->Q_SAI				)		
		oSec1:Cell("SALDATUAL"  ):SetValue( (cMyAlias)->SALDATUAL			)		
		oSec1:Cell("SALDO_FIS"  ):SetValue( (cMyAlias)->SALDO_FIS			)
		oSec1:Printline()

		(cMyAlias)->(DbSkip())

	Enddo

	oSec1:Finish()

return
