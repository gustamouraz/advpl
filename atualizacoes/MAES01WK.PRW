#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
#include 'report.ch'

/*/{Protheus.doc} MAES01WK
//TODO
@description Relatrio Kardex Global - Grupo Masutti 
@author Willian Kaneta
@since 30/05/2019
@version 1.0
@type function
/*/
user function MAES01WK()
	Local	oReport		:= Nil
	
	Private cPerg   	:= "MAES01WK"
	Private cMyAlias	:= GetNextAlias()	
	
	/*
	[Alessandre Antoniassi - 21/11/2020]
	Conforme orientao codeanalisis 
	CriaSX1(cPerg)
	*/
	If !Pergunte(cPerg,.T.)

		Return Nil

	EndIf

	oReport  := ReportDef()
	oReport:PrintDialog()

Return Nil

/*/{Protheus.doc} ReportDef
//TODO	Define o Objeto da Classe TReport utilizado na impresso do relatrio
@author Willian Kaneta
@since 27/03/2019
@version 1.0
@type function
/*/
Static Function ReportDef()	
	Local oReport	:= Nil
	Local oSec0		:= Nil
	Local oSec1		:= Nil
	Local cRptTitle	:= "Relatrio Kardex Global - Grupo Masutti" 
	Local cRptDescr	:= "Este programa emite a Impresso do Relatrio Relatrio Kardex Global" 

	DEFINE REPORT oReport NAME "KARDEXGLOBAL" TITLE cRptTitle PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION cRptDescr	TOTAL IN COLUMN
	oReport:SetLandscape()
		
	DEFINE SECTION oSec0 OF oReport TITLE cRptTitle TABLES "cMyAlias" TOTAL IN COLUMN
	DEFINE CELL NAME "TIPOMOV" 	OF 	oSec0 ALIAS "cMyAlias"	
	
	DEFINE SECTION oSec1 			OF  oSec0   									 	  		                                            				TITLE ''  	          TABLES "cMyAlias" TOTAL IN COLUMN
	DEFINE CELL NAME "TIPOMOV" 		OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Tipo Mov.'      SIZE 10
	DEFINE CELL NAME "FILIAL" 		OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Filial'         SIZE 08
	DEFINE CELL NAME "CONTA" 		OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Cta Cont.'      SIZE 09
	DEFINE CELL NAME "PRODUTO" 		OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Cod. Prod.'     SIZE 12
	DEFINE CELL NAME "TIPO" 		OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Tp. Prod.'      SIZE 04
	DEFINE CELL NAME "UM" 			OF 	oSec1 ALIAS "cMyAlias"   TITLE 'UM'             SIZE 02
	DEFINE CELL NAME "GRUPO"		OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Grp. Prod.'     SIZE 03
	DEFINE CELL NAME "DESCPROD"		OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Desc. Prod.'    SIZE 11
	DEFINE CELL NAME "SEQCALC" 		OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Seq.Recalc.'    SIZE 11
	DEFINE CELL NAME "DTDIGIT" 		OF 	oSec1 ALIAS "cMyAlias"   TITLE 'DT Dig.'	    SIZE 12
	DEFINE CELL NAME "TES" 			OF 	oSec1 ALIAS "cMyAlias"   TITLE 'TES'		    SIZE 04
	DEFINE CELL NAME "MOVEST" 		OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Mov. Est.'      SIZE 08
	DEFINE CELL NAME "CF" 			OF 	oSec1 ALIAS "cMyAlias"   TITLE 'C.F.'   	    SIZE 04
	DEFINE CELL NAME "SEQUENCIA" 	OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Num.Seq.'       SIZE 08
	DEFINE CELL NAME "DOCUMENTO" 	OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Documento'      SIZE 09
	DEFINE CELL NAME "SERIE" 		OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Serie'          SIZE 03
	DEFINE CELL NAME "BOLETIM" 		OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Boletim'        SIZE 10
	DEFINE CELL NAME "QUANTIDADE" 	OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Quant.'         SIZE 16
	DEFINE CELL NAME "VALOR" 		OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Custo Moeda 1'  SIZE 16
	DEFINE CELL NAME "ARMAZEM" 		OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Armazem'        SIZE 06
	DEFINE CELL NAME "FORNECEDOR" 	OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Forn/Clie'      SIZE 09
	DEFINE CELL NAME "LOJA"			OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Loja'           SIZE 03
	DEFINE CELL NAME "TIPONF"		OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Tp NF'          SIZE 05
	DEFINE CELL NAME "LOTE" 		OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Lote'           SIZE 10
	DEFINE CELL NAME "ARMLOC" 		OF 	oSec1 ALIAS "cMyAlias"   TITLE 'Armaz. Local'   SIZE 10
	
	oSec1:Cell("TIPOMOV"	):nAlign	:= 2
	oSec1:Cell("FILIAL" 	):nAlign	:= 2
	oSec1:Cell("CONTA" 		):nAlign	:= 2
	oSec1:Cell("PRODUTO" 	):nAlign	:= 2
	oSec1:Cell("TIPO" 		):nAlign	:= 2
	oSec1:Cell("UM" 		):nAlign	:= 2
	oSec1:Cell("GRUPO"		):nAlign	:= 2
	oSec1:Cell("DESCPROD"	):nAlign	:= 2
	oSec1:Cell("SEQCALC" 	):nAlign	:= 2
	oSec1:Cell("DTDIGIT" 	):nAlign	:= 2
	oSec1:Cell("TES" 		):nAlign	:= 2
	oSec1:Cell("MOVEST" 	):nAlign	:= 2
	oSec1:Cell("CF" 		):nAlign	:= 2
	oSec1:Cell("SEQUENCIA" 	):nAlign	:= 2
	oSec1:Cell("DOCUMENTO" 	):nAlign	:= 2
	oSec1:Cell("SERIE" 		):nAlign	:= 2
	oSec1:Cell("BOLETIM" 	):nAlign	:= 2
	oSec1:Cell("QUANTIDADE" ):nAlign	:= 2
	oSec1:Cell("VALOR" 		):nAlign	:= 2
	oSec1:Cell("ARMAZEM" 	):nAlign	:= 2
	oSec1:Cell("FORNECEDOR" ):nAlign	:= 2
	oSec1:Cell("LOJA"		):nAlign	:= 2
	oSec1:Cell("TIPONF"		):nAlign	:= 2
	oSec1:Cell("LOTE" 		):nAlign	:= 2
	oSec1:Cell("ARMLOC" 	):nAlign	:= 2
	
	oTotal := TRSection():New(oSec1,"Totais",{"SE5"},/*[Ordem]*/ )

	TRCell():New(oTotal,"DESCRICAO"  ,,"DESCRICAO" 				,,30,,)
	TRCell():New(oTotal,"TOTQUANT" 	 ,,"TOTAL QUANTIDADE"   	,,20,,)
	TRCell():New(oTotal,"TOTVALOR" 	 ,,"TOTAL VALOR" 			,,20,,)
	
	oTotal:SetLeftMargin(50)		
		
Return oReport

/*/{Protheus.doc} PrintReport
//TODO	Realiza a impresso do relatrio
@author Willian Kaneta
@since 27/03/2019
@version 1.0
@type function
/*/
Static Function PrintReport(oReport)
	Local oSec0			:= oReport:Section(1)
	Local oSec1			:= oReport:Section(1):Section(1)
	Local oTotal		:= oReport:Section(1):Section(1):Section(1)
	Local aTotais		:= {}
	Local aTotEstr		:= {}
	Local nPosTMGrup	:= 0
    Local nTotal		:= 0
    Local nAtual 		:= 0
    Local cMovAnt		:= ""
    Local cGrupAnt 		:= ""
    Local _nTotalQTD	:= 0
    Local _nTotalVLR	:= 0
    Local nX			:= 0
    Local cPicture		:= "@E 999,999,999,999.99"
    				
	Default cMyAlias	:= GetNextAlias()	

    If( MV_PAR26 == 	1 )
		BeginSql alias cMyAlias		
			SELECT DISTINCT 
				'SALDO INICIAL' 	AS TIPOMOV,
				SB9.B9_FILIAL 		AS FILIAL,
				SB1.B1_CONTA 		AS CONTA,
				SB9.B9_COD 			AS PRODUTO,
				SB1.B1_TIPO 		AS TIPO,
				SB1.B1_UM			AS UM,   			
				SB1.B1_GRUPO		AS GRUPO,      
				SB1.B1_DESC			AS DESCPROD,  
				SB1.B1_POSIPI		AS POSIPI, 
				'' 					AS SEQCALC,
				SB9.B9_DATA 		AS DTDIGIT,
				'' 					AS TES,
				'' 					AS CF,
				'' 					AS SEQUENCIA,
				'' 					AS DOCUMENTO,		
				'' 					AS SERIE,
				'' 					AS BOLETIM,
				//Quantidade		
				CASE SB1.B1_RASTRO 
					WHEN 'L' THEN SBJ.BJ_QINI 
					ELSE SB9.B9_QINI 
				END AS QUANTIDADE,				
				//Valor
			    CASE SB1.B1_RASTRO 
			    	WHEN 'L' THEN
				    	CASE WHEN SB9.B9_VINI1 = 0 OR SB9.B9_QINI = 0
							THEN 0 			
						ELSE
							(SB9.B9_VINI1/SB9.B9_QINI * SBJ.BJ_QINI) 
						END
				ELSE
					SB9.B9_VINI1 	
				END AS VALOR,
				SB9.B9_LOCAL        AS ARMAZEM,		
				'' 					AS FORNECEDOR,	
				'' 					AS LOJA,			
				'' 					AS TIPONF,
				//Lote		
			    CASE SB1.B1_RASTRO WHEN 'L'	THEN SBJ.BJ_LOTECTL ELSE  '' END	AS LOTE,	   	
				SB9.B9_LOCAL 		AS ARMLOC
			
			FROM %table:SB9% SB9
			INNER JOIN %table:SB1% SB1 
					ON SB9.B9_COD 		= SB1.B1_COD
			LEFT  JOIN %table:SBJ% SBJ 
					ON 	SB1.B1_COD 		= SBJ.BJ_COD
					AND SBJ.BJ_FILIAL 	= SB9.B9_FILIAL 
                    AND SBJ.BJ_LOCAL 	= SB9.B9_LOCAL
                    AND SBJ.BJ_DATA 	= SB9.B9_DATA
                    AND SBJ.D_E_L_E_T_  <> '*'
                    
			WHERE	SB1.D_E_L_E_T_ 		<> '*'
			        AND SB9.D_E_L_E_T_ 	<> '*'
			        AND SB9.B9_FILIAL BETWEEN  %EXP:MV_PAR01% AND %EXP:MV_PAR02%
			        AND SB1.B1_GRUPO  BETWEEN  %EXP:MV_PAR03% AND %EXP:MV_PAR04%
			        AND SB9.B9_DATA  	=  	   %EXP:DtoS(MV_PAR07)%
			        AND SB9.B9_LOCAL  BETWEEN  %EXP:MV_PAR08% AND %EXP:MV_PAR09%
			        AND SB9.B9_COD	  BETWEEN  %EXP:MV_PAR10% AND %EXP:MV_PAR11%	
			        
			ORDER BY GRUPO 			     		     
	    					
		EndSql
		   
    ElseIf( MV_PAR26 == 2 )   
	   	BeginSql alias cMyAlias
			SELECT DISTINCT  	
				'ENTRADA' 			AS TIPOMOV, 	
				SD1.D1_FILIAL		AS FILIAL,			
				SB1.B1_CONTA	    AS CONTA,    
				SB1.B1_COD          AS PRODUTO,    
				SB1.B1_TIPO         AS TIPO,    
				SB1.B1_UM			AS UM,   		
				SB1.B1_GRUPO	    AS GRUPO,        
				SB1.B1_DESC		    AS DESCPROD,     
				SB1.B1_POSIPI	    AS POSIPI,     
				SD1.D1_SEQCALC 	    AS SEQCALC,    
				SD1.D1_DTDIGIT 	    AS DTDIGIT,       
				SD1.D1_TES 			AS TES,	
				SD1.D1_CF 		    AS CF,    
				SD1.D1_NUMSEQ 	    AS SEQUENCIA,    
				SD1.D1_DOC 		    AS DOCUMENTO,    
				SD1.D1_SERIE 	    AS SERIE,   
				'' 					AS BOLETIM, 
				SD1.D1_QUANT 	    AS QUANTIDADE,    
				SD1.D1_CUSTO 		AS VALOR,	
				SD1.D1_LOCAL 		AS ARMAZEM,		
				SD1.D1_FORNECE 	    AS FORNECEDOR,
				SD1.D1_LOJA 	    AS LOJA,		
				SD1.D1_TIPO 	    AS TIPONF,
				SD1.D1_LOTECTL		AS LOTE,	
				SD1.D1_LOCAL 		AS ARMLOC
			FROM %table:SB1% SB1
			INNER JOIN %table:SD1% SD1 
				ON SD1.D1_COD 	  = SB1.B1_COD
			INNER JOIN %table:SF4% SF4
				ON 	SF4.F4_CODIGO = SD1.D1_TES
				AND SF4.F4_FILIAL = SUBSTRING(SD1.D1_FILIAL,1,4)
			
			WHERE SD1.D1_FILIAL    BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02%
			    AND SB1.B1_GRUPO   BETWEEN %EXP:MV_PAR03% AND %EXP:MV_PAR04%	
				AND SD1.D1_DTDIGIT BETWEEN %EXP:DtoS(MV_PAR05)% AND %EXP:DtoS(MV_PAR06)%
				AND SD1.D1_LOCAL   BETWEEN %EXP:MV_PAR08% AND %EXP:MV_PAR09%
				AND SB1.B1_COD	   BETWEEN %EXP:MV_PAR10% AND %EXP:MV_PAR11%
				AND SD1.D1_LOTECTL BETWEEN %EXP:MV_PAR12% AND %EXP:MV_PAR13%
				AND SD1.D1_FORNECE BETWEEN %EXP:MV_PAR14% AND %EXP:MV_PAR15%
				AND SD1.D1_LOJA	   BETWEEN %EXP:MV_PAR16% AND %EXP:MV_PAR17%
				AND SD1.D1_DOC	   BETWEEN %EXP:MV_PAR18% AND %EXP:MV_PAR19%
				AND SD1.D1_TES	   BETWEEN %EXP:MV_PAR20% AND %EXP:MV_PAR21%
				AND SF4.F4_ESTOQUE =  'S'
				AND	SD1.D1_ORIGLAN <> 'LF'
				AND SB1.D_E_L_E_T_ <>'*'
				AND SD1.D_E_L_E_T_ <>'*' 
				AND SF4.D_E_L_E_T_ <>'*'
				
			ORDER BY GRUPO
					
		EndSql
		
    ElseIf( MV_PAR26 == 3 )	   
	   	BeginSql alias cMyAlias
			SELECT DISTINCT 'SAIDA' 		AS TIPOMOV, 	
				SD2.D2_FILIAL				AS FILIAL,		
				SB1.B1_CONTA				AS CONTA,    
				SB1.B1_COD					AS PRODUTO,    
				SB1.B1_TIPO					AS TIPO,    
				SB1.B1_UM					AS UM,   		
				SB1.B1_GRUPO				AS GRUPO,      
				SB1.B1_DESC					AS DESCPROD,   
				SB1.B1_POSIPI				AS POSIPI,     
				SD2.D2_SEQCALC				AS SEQCALC,    
				SD2.D2_EMISSAO				AS DTDIGIT,    
				SD2.D2_TES					AS TES,	
				SD2.D2_CF					AS CF,    
				SD2.D2_NUMSEQ				AS SEQUENCIA,  
				SD2.D2_DOC					AS DOCUMENTO,  
				SD2.D2_SERIE				AS SERIE,
				'' 							AS BOLETIM,
				SD2.D2_QUANT *-1			AS QUANTIDADE, 
				SD2.D2_CUSTO1 *-1			AS VALOR,	
				SD2.D2_LOCAL				AS ARMAZEM,		
				SD2.D2_CLIENTE				AS FORNECEDOR,
				SD2.D2_LOJA					AS LOJA,		
				SD2.D2_TIPO					AS TIPONF,
				SD2.D2_LOTECTL				AS LOTE,	
				SD2.D2_LOCAL                AS ARMLOC
			FROM %table:SB1% SB1
			INNER JOIN %table:SD2% SD2 
				ON SD2.D2_COD 		= SB1.B1_COD
			INNER JOIN %table:SF4% SF4 
				ON SF4.F4_CODIGO 	= SD2.D2_TES
				AND SF4.F4_FILIAL 	= SUBSTRING(SD2.D2_FILIAL,1,4)			
			
			WHERE SD2.D2_FILIAL    BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02%
				AND SB1.B1_GRUPO   BETWEEN %EXP:MV_PAR03% AND %EXP:MV_PAR04%			
				AND	SD2.D2_EMISSAO BETWEEN %EXP:DtoS(MV_PAR05)%	AND %EXP:DtoS(MV_PAR06)%
				AND SD2.D2_LOCAL   BETWEEN %EXP:MV_PAR08% AND %EXP:MV_PAR09%
				AND SD2.D2_COD	   BETWEEN %EXP:MV_PAR10% AND %EXP:MV_PAR11%
				AND SD2.D2_LOTECTL BETWEEN %EXP:MV_PAR12% AND %EXP:MV_PAR13%
				AND SD2.D2_CLIENTE BETWEEN %EXP:MV_PAR22% AND %EXP:MV_PAR23%
				AND SD2.D2_LOJA	   BETWEEN %EXP:MV_PAR24% AND %EXP:MV_PAR25%
				AND SD2.D2_DOC	   BETWEEN %EXP:MV_PAR18% AND %EXP:MV_PAR19%
				AND SD2.D2_TES	   BETWEEN %EXP:MV_PAR20% AND %EXP:MV_PAR21%									
				AND SF4.F4_ESTOQUE =  'S'
				AND	SD2.D2_ORIGLAN <> 'LF'
				AND SD2.D_E_L_E_T_ <>'*'
				AND SF4.D_E_L_E_T_ <>'*'
				AND SB1.D_E_L_E_T_ <>'*'
			
			ORDER BY GRUPO
			
		EndSql	
		
    ElseIf( MV_PAR26 == 4 )	   
	   	BeginSql alias cMyAlias
			SELECT DISTINCT 	
				'INTERNA'		AS TIPOMOV, 	
				SD3.D3_FILIAL	AS FILIAL,		
				SB1.B1_CONTA	AS CONTA,    
				SB1.B1_COD		AS PRODUTO,   
				SB1.B1_TIPO		AS TIPO,    
				SB1.B1_UM		AS UM,   		
				SB1.B1_GRUPO	AS GRUPO,     
				SB1.B1_DESC		AS DESCPROD,  
				SB1.B1_POSIPI	AS POSIPI,    
				SD3.D3_SEQCALC	AS SEQCALC,   
				SD3.D3_EMISSAO	AS DTDIGIT,   
				SD3.D3_TM		AS TES,				
				SD3.D3_CF		AS CF,    
				SD3.D3_NUMSEQ	AS SEQUENCIA, 
				SD3.D3_DOC		AS DOCUMENTO, 
				'' 				AS SERIE,
				SD3.D3_NRBPIMS 	AS BOLETIM,				
				//Quantidade
				CASE 
					WHEN SD3.D3_TM > 499 THEN SD3.D3_QUANT*-1 
					ELSE SD3.D3_QUANT 
				END             AS QUANTIDADE,
				//Valor
				CASE 
					WHEN SD3.D3_TM > 499 THEN SD3.D3_CUSTO1*-1
					 ELSE SD3.D3_CUSTO1 
				END				AS VALOR,
				SD3.D3_LOCAL	AS ARMAZEM,		
				SD3.D3_TRT		AS FORNECEDOR,
				''				AS LOJA,		
				''				AS TIPONF,
				SD3.D3_LOTECTL	AS LOTE,	
				SD3.D3_LOCAL    AS ARMLOC
			
			FROM %table:SB1% SB1
			INNER JOIN %table:SD3% SD3 
				ON SD3.D3_COD 	= SB1.B1_COD
			
			WHERE	SD3.D3_FILIAL  BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02%
				AND SB1.B1_GRUPO   BETWEEN %EXP:MV_PAR03% AND %EXP:MV_PAR04%		
				AND SD3.D3_EMISSAO BETWEEN %exp:DtoS(MV_PAR05)% AND %EXP:DtoS(MV_PAR06)%
				AND SD3.D3_LOCAL   BETWEEN %EXP:MV_PAR08% AND %EXP:MV_PAR09%
				AND SB1.B1_COD	   BETWEEN %EXP:MV_PAR10% AND %EXP:MV_PAR11%
				AND SD3.D3_LOTECTL BETWEEN %EXP:MV_PAR12% AND %EXP:MV_PAR13%
				AND SD3.D3_DOC	   BETWEEN %EXP:MV_PAR18% AND %EXP:MV_PAR19%
				AND SD3.D3_TM	   BETWEEN %EXP:MV_PAR20% AND %EXP:MV_PAR21%				
				AND SD3.D_E_L_E_T_ <> '*'
				AND SB1.D_E_L_E_T_ <> '*'
			
			ORDER BY GRUPO
			
		EndSql			
		
    ElseIf( MV_PAR26 == 5 )
		BeginSql alias cMyAlias
			SELECT * FROM (
				SELECT DISTINCT 
					'SALDO INICIAL' 	AS TIPOMOV,
					SB9.B9_FILIAL 		AS FILIAL,
					SB1.B1_CONTA 		AS CONTA,
					SB9.B9_COD 			AS PRODUTO,
					SB1.B1_TIPO 		AS TIPO,
					SB1.B1_UM			AS UM,   			
					SB1.B1_GRUPO		AS GRUPO,      
					SB1.B1_DESC			AS DESCPROD,  
					SB1.B1_POSIPI		AS POSIPI, 
					'' 					AS SEQCALC,
					SB9.B9_DATA 		AS DTDIGIT,
					'' 					AS TES,
					'' 					AS CF,
					'' 					AS SEQUENCIA,
					'' 					AS DOCUMENTO,		
					'' 					AS SERIE,
					'' 					AS BOLETIM,
					//Quantidade		
					CASE SB1.B1_RASTRO 
						WHEN 'L' THEN SBJ.BJ_QINI 
						ELSE SB9.B9_QINI 
					END AS QUANTIDADE,				
					//Valor
				    CASE SB1.B1_RASTRO 
				    	WHEN 'L' THEN
					    	CASE WHEN SB9.B9_VINI1 = 0 OR SB9.B9_QINI = 0
								THEN 0 			
							ELSE
								(SB9.B9_VINI1/SB9.B9_QINI * SBJ.BJ_QINI) 
							END
					ELSE
						SB9.B9_VINI1 	
					END AS VALOR,
					SB9.B9_LOCAL        AS ARMAZEM,		
					'' 					AS FORNECEDOR,	
					'' 					AS LOJA,			
					'' 					AS TIPONF,
					//Lote		
				    CASE SB1.B1_RASTRO WHEN 'L'	THEN SBJ.BJ_LOTECTL ELSE  '' END	AS LOTE,	   	
					SB9.B9_LOCAL 		AS ARMLOC
				
				FROM %table:SB9% SB9
				INNER JOIN %table:SB1% SB1 ON SB9.B9_COD = SB1.B1_COD
				LEFT  JOIN %table:SBJ% SBJ 
						ON 	SB1.B1_COD 		= SBJ.BJ_COD
						AND SBJ.BJ_FILIAL 	= SB9.B9_FILIAL 
	                    AND SBJ.BJ_LOCAL 	= SB9.B9_LOCAL
	                    AND SBJ.BJ_DATA 	= SB9.B9_DATA
	                    AND SBJ.D_E_L_E_T_  <> '*'
	                    
				WHERE	SB1.D_E_L_E_T_ 		<> '*'
				        AND SB9.D_E_L_E_T_ 	<> '*'
				        AND SB9.B9_FILIAL BETWEEN  %EXP:MV_PAR01% AND %EXP:MV_PAR02%
				        AND SB1.B1_GRUPO  BETWEEN  %EXP:MV_PAR03% AND %EXP:MV_PAR04%
				        AND SB9.B9_DATA  	=  	   %EXP:DtoS(MV_PAR07)%
				        AND SB9.B9_LOCAL  BETWEEN  %EXP:MV_PAR08% AND %EXP:MV_PAR09%
				        AND SB9.B9_COD	  BETWEEN  %EXP:MV_PAR10% AND %EXP:MV_PAR11%
				     
				UNION 
				
				SELECT DISTINCT  	
					'ENTRADA' 			AS TIPOMOV, 	
					SD1.D1_FILIAL		AS FILIAL,			
					SB1.B1_CONTA	    AS CONTA,    
					SB1.B1_COD          AS PRODUTO,    
					SB1.B1_TIPO         AS TIPO,    
					SB1.B1_UM			AS UM,   		
					SB1.B1_GRUPO	    AS GRUPO,        
					SB1.B1_DESC		    AS DESCPROD,     
					SB1.B1_POSIPI	    AS POSIPI,     
					SD1.D1_SEQCALC 	    AS SEQCALC,    
					SD1.D1_DTDIGIT 	    AS DTDIGIT,       
					SD1.D1_TES 			AS TES,	
					SD1.D1_CF 		    AS CF,    
					SD1.D1_NUMSEQ 	    AS SEQUENCIA,    
					SD1.D1_DOC 		    AS DOCUMENTO,    
					SD1.D1_SERIE 	    AS SERIE,   
					'' 					AS BOLETIM, 
					SD1.D1_QUANT 	    AS QUANTIDADE,    
					SD1.D1_CUSTO 		AS VALOR,	
					SD1.D1_LOCAL 		AS ARMAZEM,		
					SD1.D1_FORNECE 	    AS FORNECEDOR,
					SD1.D1_LOJA 	    AS LOJA,		
					SD1.D1_TIPO 	    AS TIPONF,
					SD1.D1_LOTECTL		AS LOTE,	
					SD1.D1_LOCAL 		AS ARMLOC
				FROM %table:SB1% SB1
				INNER JOIN %table:SD1% SD1 ON SD1.D1_COD = SB1.B1_COD
				INNER JOIN %table:SF4% SF4
					ON 	SF4.F4_CODIGO = SD1.D1_TES
					AND SF4.F4_FILIAL = SUBSTRING(SD1.D1_FILIAL,1,4)
				
				WHERE SD1.D1_FILIAL    BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02%
				    AND SB1.B1_GRUPO   BETWEEN %EXP:MV_PAR03% AND %EXP:MV_PAR04%	
					AND SD1.D1_DTDIGIT BETWEEN %EXP:DtoS(MV_PAR05)% AND %EXP:DtoS(MV_PAR06)%
					AND SD1.D1_LOCAL   BETWEEN %EXP:MV_PAR08% AND %EXP:MV_PAR09%
					AND SB1.B1_COD	   BETWEEN %EXP:MV_PAR10% AND %EXP:MV_PAR11%
					AND SD1.D1_LOTECTL BETWEEN %EXP:MV_PAR12% AND %EXP:MV_PAR13%
					AND SD1.D1_FORNECE BETWEEN %EXP:MV_PAR14% AND %EXP:MV_PAR15%
					AND SD1.D1_LOJA	   BETWEEN %EXP:MV_PAR16% AND %EXP:MV_PAR17%
					AND SD1.D1_DOC	   BETWEEN %EXP:MV_PAR18% AND %EXP:MV_PAR19%
					AND SD1.D1_TES	   BETWEEN %EXP:MV_PAR20% AND %EXP:MV_PAR21%
					AND SF4.F4_ESTOQUE =  'S'
					AND	SD1.D1_ORIGLAN <> 'LF'
					AND SB1.D_E_L_E_T_ <>'*'
					AND SD1.D_E_L_E_T_ <>'*' 
					AND SF4.D_E_L_E_T_ <>'*'
				
				UNION
				
				SELECT DISTINCT 'SAIDA' 		AS TIPOMOV, 	
					SD2.D2_FILIAL				AS FILIAL,		
					SB1.B1_CONTA				AS CONTA,    
					SB1.B1_COD					AS PRODUTO,    
					SB1.B1_TIPO					AS TIPO,    
					SB1.B1_UM					AS UM,   		
					SB1.B1_GRUPO				AS GRUPO,      
					SB1.B1_DESC					AS DESCPROD,   
					SB1.B1_POSIPI				AS POSIPI,     
					SD2.D2_SEQCALC				AS SEQCALC,    
					SD2.D2_EMISSAO				AS DTDIGIT,    
					SD2.D2_TES					AS TES,	
					SD2.D2_CF					AS CF,    
					SD2.D2_NUMSEQ				AS SEQUENCIA,  
					SD2.D2_DOC					AS DOCUMENTO,  
					SD2.D2_SERIE				AS SERIE,
					'' 							AS BOLETIM,
					SD2.D2_QUANT *-1			AS QUANTIDADE, 
					SD2.D2_CUSTO1 *-1			AS VALOR,	
					SD2.D2_LOCAL				AS ARMAZEM,		
					SD2.D2_CLIENTE				AS FORNECEDOR,
					SD2.D2_LOJA					AS LOJA,		
					SD2.D2_TIPO					AS TIPONF,
					SD2.D2_LOTECTL				AS LOTE,	
					SD2.D2_LOCAL                AS ARMLOC
				FROM %table:SB1% SB1
				INNER JOIN %table:SD2% SD2 
					ON SD2.D2_COD 		= SB1.B1_COD
				INNER JOIN %table:SF4% SF4 
					ON SF4.F4_CODIGO 	= SD2.D2_TES
					AND SF4.F4_FILIAL 	= SUBSTRING(SD2.D2_FILIAL,1,4)			
				
				WHERE SD2.D2_FILIAL    BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02%
					AND SB1.B1_GRUPO   BETWEEN %EXP:MV_PAR03% AND %EXP:MV_PAR04%			
					AND	SD2.D2_EMISSAO BETWEEN %EXP:DtoS(MV_PAR05)%	AND %EXP:DtoS(MV_PAR06)%
					AND SD2.D2_LOCAL   BETWEEN %EXP:MV_PAR08% AND %EXP:MV_PAR09%
					AND SD2.D2_COD	   BETWEEN %EXP:MV_PAR10% AND %EXP:MV_PAR11%
					AND SD2.D2_LOTECTL BETWEEN %EXP:MV_PAR12% AND %EXP:MV_PAR13%
					AND SD2.D2_CLIENTE BETWEEN %EXP:MV_PAR22% AND %EXP:MV_PAR23%
					AND SD2.D2_LOJA	   BETWEEN %EXP:MV_PAR24% AND %EXP:MV_PAR25%
					AND SD2.D2_DOC	   BETWEEN %EXP:MV_PAR18% AND %EXP:MV_PAR19%
					AND SD2.D2_TES	   BETWEEN %EXP:MV_PAR20% AND %EXP:MV_PAR21%									
					AND SF4.F4_ESTOQUE =  'S'
					AND	SD2.D2_ORIGLAN <> 'LF'
					AND SD2.D_E_L_E_T_ <>'*'
					AND SF4.D_E_L_E_T_ <>'*'
					AND SB1.D_E_L_E_T_ <>'*'
				
				UNION
				
				SELECT DISTINCT 	
					'INTERNA'		AS TIPOMOV, 	
					SD3.D3_FILIAL	AS FILIAL,		
					SB1.B1_CONTA	AS CONTA,    
					SB1.B1_COD		AS PRODUTO,   
					SB1.B1_TIPO		AS TIPO,    
					SB1.B1_UM		AS UM,   		
					SB1.B1_GRUPO	AS GRUPO,     
					SB1.B1_DESC		AS DESCPROD,  
					SB1.B1_POSIPI	AS POSIPI,    
					SD3.D3_SEQCALC	AS SEQCALC,   
					SD3.D3_EMISSAO	AS DTDIGIT,   
					SD3.D3_TM		AS TES,				
					SD3.D3_CF		AS CF,    
					SD3.D3_NUMSEQ	AS SEQUENCIA, 
					SD3.D3_DOC		AS DOCUMENTO, 
					'' 				AS SERIE,
					SD3.D3_NRBPIMS 	AS BOLETIM,				
					//Quantidade
					CASE 
						WHEN SD3.D3_TM > 499 THEN SD3.D3_QUANT*-1 
						ELSE SD3.D3_QUANT 
					END             AS QUANTIDADE,
					//Valor
					CASE 
						WHEN SD3.D3_TM > 499 THEN SD3.D3_CUSTO1*-1
						 ELSE SD3.D3_CUSTO1 
					END				AS VALOR,
					SD3.D3_LOCAL	AS ARMAZEM,		
					SD3.D3_TRT		AS FORNECEDOR,
					''				AS LOJA,		
					''				AS TIPONF,
					SD3.D3_LOTECTL	AS LOTE,	
					SD3.D3_LOCAL    AS ARMLOC
				
				FROM %table:SB1% SB1
				INNER JOIN %table:SD3% SD3 
					ON SD3.D3_COD 	= SB1.B1_COD
				
				WHERE	SD3.D3_FILIAL  BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02%
					AND SB1.B1_GRUPO   BETWEEN %EXP:MV_PAR03% AND %EXP:MV_PAR04%		
					AND SD3.D3_EMISSAO BETWEEN %exp:DtoS(MV_PAR05)% AND %EXP:DtoS(MV_PAR06)%
					AND SD3.D3_LOCAL   BETWEEN %EXP:MV_PAR08% AND %EXP:MV_PAR09%
					AND SB1.B1_COD	   BETWEEN %EXP:MV_PAR10% AND %EXP:MV_PAR11%
					AND SD3.D3_LOTECTL BETWEEN %EXP:MV_PAR12% AND %EXP:MV_PAR13%
					AND SD3.D3_DOC	   BETWEEN %EXP:MV_PAR18% AND %EXP:MV_PAR19%
					AND SD3.D3_TM	   BETWEEN %EXP:MV_PAR20% AND %EXP:MV_PAR21%				
					AND SD3.D_E_L_E_T_ <> '*'
					AND SB1.D_E_L_E_T_ <> '*'		     
	        	) AS KARDEX
	        	ORDER BY KARDEX.GRUPO				
		EndSql
		
	EndIf
	
	//MemoWrite("C:\Users\005642\Downloads\kardexGlobal.txt",getlastquery()[2])
	Count to nTotal
	oReport:SetMeter(nTotal)
	oSec1:Init()
	
	(cMyAlias)->(DbGoTop())
	While !oReport:Cancel() .AND. !(cMyAlias)->(Eof())
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()
		
		If Len(aTotais) <> 0
			nPosTMGrup 	:= AScan(aTotais, {|x| x[5] == (cMyAlias)->TIPOMOV+(cMyAlias)->GRUPO })	
		EndIf
		
		If cMovAnt <> (cMyAlias)->TIPOMOV .AND. cGrupAnt <> (cMyAlias)->GRUPO .AND. Len(aTotais) == 0
			AADD( aTotais,{(cMyAlias)->TIPOMOV,(cMyAlias)->GRUPO,(cMyAlias)->QUANTIDADE,(cMyAlias)->VALOR,(cMyAlias)->TIPOMOV+(cMyAlias)->GRUPO})
		ElseIf nPosTMGrup == 0 .AND. Len(aTotais) <> 0
			AADD( aTotais,{(cMyAlias)->TIPOMOV,(cMyAlias)->GRUPO,(cMyAlias)->QUANTIDADE,(cMyAlias)->VALOR,(cMyAlias)->TIPOMOV+(cMyAlias)->GRUPO})
		Else 
			aTotais[nPosTMGrup,3] += NOROUND((cMyAlias)->QUANTIDADE	, 2)
			aTotais[nPosTMGrup,4] += NOROUND((cMyAlias)->VALOR		, 2)  
		EndIf
		
		oSec1:Cell( "TIPOMOV" 		):SetValue( (cMyAlias)->TIPOMOV 	                                                )
		oSec1:Cell( "FILIAL" 		):SetValue( (cMyAlias)->FILIAL		                                                )
		oSec1:Cell( "CONTA" 		):SetValue( (cMyAlias)->CONTA                                                       )
		oSec1:Cell( "PRODUTO" 		):SetValue( (cMyAlias)->PRODUTO                                                     )
		oSec1:Cell( "TIPO" 		    ):SetValue( (cMyAlias)->TIPO                                                        )
		oSec1:Cell( "UM" 			):SetValue( (cMyAlias)->UM   		                                                )
		oSec1:Cell( "GRUPO"		    ):SetValue( (cMyAlias)->GRUPO                                                       )
		oSec1:Cell( "DESCPROD"		):SetValue( (cMyAlias)->DESCPROD                                                    )
		oSec1:Cell( "SEQCALC" 		):SetValue( (cMyAlias)->POSIPI                                                      )
		oSec1:Cell( "DTDIGIT" 		):SetValue( DTOC(STOD((cMyAlias)->DTDIGIT))                                         )
		oSec1:Cell( "TES" 			):SetValue( (cMyAlias)->TES                                                     	)
		oSec1:Cell( "MOVEST" 		):SetValue( TESMVEST( (cMyAlias)->TIPOMOV,(cMyAlias)->TES,(cMyAlias)->QUANTIDADE )  ) 	
		oSec1:Cell( "CF" 			):SetValue( (cMyAlias)->CF                                                          )
		oSec1:Cell( "SEQUENCIA" 	):SetValue( (cMyAlias)->SEQUENCIA                                                   )
		oSec1:Cell( "DOCUMENTO" 	):SetValue( (cMyAlias)->DOCUMENTO                                                   )
		oSec1:Cell( "SERIE" 		):SetValue( (cMyAlias)->SERIE                                                       )
		oSec1:Cell( "BOLETIM" 		):SetValue( (cMyAlias)->BOLETIM                                                     )
		oSec1:Cell( "QUANTIDADE" 	):SetValue( NOROUND((cMyAlias)->QUANTIDADE	, 2)									)
		oSec1:Cell( "VALOR" 		):SetValue( NOROUND((cMyAlias)->VALOR		, 2)									)
		oSec1:Cell( "ARMAZEM" 		):SetValue( (cMyAlias)->ARMAZEM		                                                )
		oSec1:Cell( "FORNECEDOR" 	):SetValue( (cMyAlias)->FORNECEDOR                                                  )
		oSec1:Cell( "LOJA"			):SetValue( (cMyAlias)->LOJA		                                                )
		oSec1:Cell( "TIPONF"		):SetValue( (cMyAlias)->TIPONF                                                      )
		oSec1:Cell( "LOTE" 		    ):SetValue( (cMyAlias)->LOTE	                                                    )
		oSec1:Cell( "ARMLOC" 	 	):SetValue( (cMyAlias)->ARMLOC														)
					
		//Imprimindo a linha atual
		oSec1:PrintLine()
		
		cMovAnt	 	:= (cMyAlias)->TIPOMOV
		cGrupAnt 	:= (cMyAlias)->GRUPO
				
		(cMyAlias)->(DbSkip())
	EndDo
	
	oSec1:Cell( "TIPOMOV" 		):SetValue(" ")
	oSec1:Cell( "FILIAL" 		):SetValue(" ")
	oSec1:Cell( "CONTA" 		):SetValue(" ")
	oSec1:Cell( "PRODUTO" 		):SetValue(" ")
	oSec1:Cell( "TIPO" 		    ):SetValue(" ")
	oSec1:Cell( "UM" 			):SetValue(" ")
	oSec1:Cell( "GRUPO"		    ):SetValue(" ")
	oSec1:Cell( "DESCPROD"		):SetValue(" ")
	oSec1:Cell( "SEQCALC" 		):SetValue(" ")
	oSec1:Cell( "DTDIGIT" 		):SetValue(" ")
	oSec1:Cell( "TES" 			):SetValue(" ")
	oSec1:Cell( "MOVEST" 		):SetValue(" ") 	
	oSec1:Cell( "CF" 			):SetValue(" ")
	oSec1:Cell( "SEQUENCIA" 	):SetValue(" ")
	oSec1:Cell( "DOCUMENTO" 	):SetValue(" ")
	oSec1:Cell( "SERIE" 		):SetValue(" ")
	oSec1:Cell( "BOLETIM" 		):SetValue(" ")
	oSec1:Cell( "QUANTIDADE" 	):SetValue(" ")
	oSec1:Cell( "VALOR" 		):SetValue(" ")
	oSec1:Cell( "ARMAZEM" 		):SetValue(" ")
	oSec1:Cell( "FORNECEDOR" 	):SetValue(" ")
	oSec1:Cell( "LOJA"			):SetValue(" ")
	oSec1:Cell( "TIPONF"		):SetValue(" ")
	oSec1:Cell( "LOTE" 		    ):SetValue(" ")
	oSec1:Cell( "ARMLOC" 	 	):SetValue(" ")
				                             
	//Imprimindo a linha atual
	oSec1:PrintLine()	
	
	//Totalizadores
	AADD( aTotEstr ,{"RESUMO DOS MOVIMENTOS........: "})
	
	cMovAnt := ""
	
	For nX := 1 to Len(aTotais)
		If Len(aTotEstr) == 1
			AADD( aTotEstr ,{aTotais[nX][1] + "........................:",,})
		ElseIf cMovAnt <> aTotais[nX][1] .AND. Len(aTotEstr) > 1
			AADD( aTotEstr ,{aTotais[nX][1] + "........................:",,})
		EndIf
		
		AADD( aTotEstr ,{"Grupo "+ cValToChar(aTotais[nX,2]),aTotais[nX,3],aTotais[nX,4]})

		_nTotalQTD += aTotais[nX,3]
		_nTotalVLR += aTotais[nX,4]
					
		If nX == Len(aTotais)
			AADD( aTotEstr ,{"TOTAL........................:",_nTotalQTD,_nTotalVLR})	
		EndIf
		
		cMovAnt := aTotais[nX][1]		
	Next nX

	oTotal:Init()
	
	oTotal:Cell("DESCRICAO"):HideHeader()
	oTotal:Cell("TOTQUANT"):SetHeaderAlign("CENTER")
	oTotal:Cell("TOTVALOR"):SetHeaderAlign("CENTER")
		
	For nX := 1 to Len(aTotEstr)
		oTotal:Cell("DESCRICAO"):SetBlock( { || aTotEstr[nX][1] } )
		oTotal:Cell("TOTQUANT"):SetBlock( { || If(SUBSTR(aTotEstr[nX][1],1,5) == "Grupo" .OR. SUBSTR(aTotEstr[nX][1],1,5) == "TOTAL",NOROUND(aTotEstr[nX][2], 2),"")} )
		oTotal:Cell("TOTVALOR"):SetBlock( { || If(SUBSTR(aTotEstr[nX][1],1,5) == "Grupo" .OR. SUBSTR(aTotEstr[nX][1],1,5) == "TOTAL",NOROUND(aTotEstr[nX][3], 2),"")} )
		If nX == Len(aTotEstr)
			oReport:SkipLine()
		EndIf
		oTotal:PrintLine()
	Next nX

	oTotal:Finish()	
	oSec1:Finish()
	
Return Nil

/*/{Protheus.doc} CriaSx1
//TODO
@description Cria grupo de pergunta
@author Willian Kaneta
@since 29/08/2016
@version 1.0
@type function
/*/
/*
[Alessandre Antoniassi - 21/11/2020]
Orientado pelo CodeAnalysis no se pode manipular dados do Metadados se no pelo configurador

Static Function CriaSx1()
	Local aRegs := {}
	Local nX := 0

	/*-----------------------MV_PAR01--------------------------*/
//	aAdd(aRegs,{cPerg,'01','Filial De ?'		,'Filial De ?'			,'Filial De ?'			,'mv_ch1' ,'C',06,0,0,'G','','MV_PAR01',''             ,'',''    ,'SM0'	,	  ''        ,  ''   ,'' })
                                                                                                                                                                                                 
	/*-----------------------MV_PAR02--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'02','Filial At'			,'Filial Ate'			,'Filial Ate'			,'mv_ch2' ,'C',06,0,0,'G','','MV_PAR02',''             ,'',''    ,'SM0'	,	  ''        ,  ''   ,'' })
	                                                                                                                                                                                             
	/*-----------------------MV_PAR03--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'03','Grupo Prod. De ?'	,'Grupo Prod. De ?'		,'Grupo Prod. De ?'		,'mv_ch3' ,'C',06,0,0,'G','','MV_PAR03',''             ,'',''    ,'SBM'	,	  ''        ,  ''   ,'' })
                                                                                                                                                                                                 
	/*-----------------------MV_PAR04--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'04','Grupo Prod. At ?'	,'Grupo Prod. At ?'	,'Grupo Prod. At ?'	,'mv_ch4' ,'C',06,0,0,'G','','MV_PAR04',''             ,'',''    ,'SBM'	,	  ''        ,  ''   ,'' })
                                                                                                                                                                                                 
	/*-----------------------MV_PAR05--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'05','Data De ?'			,'Data De ?'			,'Data De ?'			,'mv_ch5' ,'D',08,0,0,'G','','MV_PAR05',''             ,'',''    ,''   	,	  ''        ,  ''   ,'' })
	                                                                                                                                                                                             
	/*-----------------------MV_PAR06--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'06','Data Ate ?'			,'Data Ate ?'			,'Data Ate ?'			,'mv_ch6' ,'D',08,0,0,'G','','MV_PAR06',''             ,'',''    ,''   	,	  ''        ,  ''   ,'' })
                                                                                                                                                                                                 
//	/*-----------------------MV_PAR07--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'07','Dt. Utimo Fech. ?'	,'Dt. Utimo Fech.?'		,'Dt. Utimo Fech.?'		,'mv_ch7' ,'D',08,0,0,'G','','MV_PAR07',''             ,'',''    ,''   	,	  ''        ,  ''   ,'' })
//	                                                                                                                                                                                             
	/*-----------------------MV_PAR08--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'08','Local Estoque De ?'	,'Local Estoque De ?'	,'Local Estoque De ?'	,'mv_ch8' ,'C',02,0,0,'G','','MV_PAR08',''             ,'',''    ,'NNR'	,	  ''        ,  ''   ,'' })
	                                                                                                                                                                                             
	/*-----------------------MV_PAR09--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'09','Local Estoque Ate ?','Local Estoque Ate ?'	,'Local Estoque Ate ?'	,'mv_ch9' ,'C',02,0,0,'G','','MV_PAR09',''             ,'',''    ,'NNR'	,	  ''        ,  ''   ,'' })		
	                                                                                                                                                                                             
	/*-----------------------MV_PAR10--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'10','Produto de ?'		,'Produto de ?'			,'Produto de ?'			,'mv_ch10','C',10,0,0,'G','','MV_PAR10',''			   ,'',''    ,'SB1'	,	  ''        ,  ''   ,'' })	
	                                                                                                                                                                                             
	/*-----------------------MV_PAR11--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'11','Produto Ate ?'		,'Produto Ate ?'		,'Produto Ate ?'		,'mv_ch11','C',10,0,0,'G','','MV_PAR11',''             ,'',''    ,'SB1'	,	  ''        ,  ''   ,'' })
                                                                                                                                                                                                 
	/*-----------------------MV_PAR12--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'12','Lote de ?'			,'Lote de ?'			,'Lote de ?'			,'mv_ch12','C',15,0,0,'G','','MV_PAR12',''             ,'',''    ,''  	,	  ''        ,  ''   ,'' })	
	                                                                                                                                                                                             
	/*-----------------------MV_PAR13--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'13','Lote Ate ?'			,'Lote Ate ?'			,'Lote Ate ?'			,'mv_ch13','C',15,0,0,'G','','MV_PAR13',''             ,'',''    ,''  	,	  ''        ,  ''   ,'' })
	                                                                                                                                                                                             
	/*-----------------------MV_PAR14--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'14','Fornecedor de ?'	,'Fornecedor de ?'		,'Fornecedor de ?'		,'mv_ch14','C',06,0,0,'G','','MV_PAR14',''             ,'',''    ,'SA2'	,	  ''        ,  ''   ,'' })	
	                                                                                                                                                                                             
	/*-----------------------MV_PAR15--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'15','Fornecedor  Ate ?'	,'Fornecedor  Ate ?'	,'Fornecedor  Ate ?'	,'mv_ch15','C',06,0,0,'G','','MV_PAR15',''             ,'',''    ,'SA2'	,	  ''        ,  ''   ,'' })	
	                                                                                                                                                                                             
	/*-----------------------MV_PAR16--------------------------*/                                                                                                                                
	                                                                                                                                                                                             
//	aAdd(aRegs,{cPerg,'16','Loja de ?'			,'Loja de ?'			,'Loja de ?'			,'mv_ch16','C',02,0,0,'G','','MV_PAR16',''             ,'',''    ,''  	,	  ''        ,  ''   ,'' })	
	                                                                                                                                                                                             
	/*-----------------------MV_PAR17--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'17','Loja  Ate ?'		,'Loja  Ate ?'			,'Loja  Ate ?'			,'mv_ch17','C',02,0,0,'G','','MV_PAR17',''             ,'',''    ,''  	,	  ''        ,  ''   ,'' })	
                                                                                                                                                                                                 
	/*-----------------------MV_PAR18--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'18','Documento de ?'		,'Documento de ?'		,'Documento de ?'		,'mv_ch18','C',09,0,0,'G','','MV_PAR18',''             ,'',''    ,''  	,     ''        ,  ''   ,'' })	
	                                                                                                                                                                                             
	/*-----------------------MV_PAR19--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'19','Documento  Ate ?'	,'Documento  Ate ?'		,'Documento  Ate ?'		,'mv_ch19','C',09,0,0,'G','','MV_PAR19',''             ,'',''    ,''  	,	  ''        ,  ''   ,'' })	
                                                                                                                                                                                                 
	/*-----------------------MV_PAR20--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'20','TES de ?'			,'TES de ?'				,'TES de ?'				,'mv_ch20','C',03,0,0,'G','','MV_PAR20',''             ,'',''    ,'SF4'	,	  ''        ,  ''   ,'' })	
	                                                                                                                                                                                             
	/*-----------------------MV_PAR21--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'21','TES  Ate ?'			,'TES  Ate ?'			,'TES  Ate ?'			,'mv_ch21','C',03,0,0,'G','','MV_PAR21',''             ,'',''    ,'SF4'	,	  ''        ,  ''   ,'' })
	                                                                                                                                                                                             
	/*-----------------------MV_PAR22--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'22','Cliente de ?'		,'Cliente de ?'		    ,'Cliente de ?'			,'mv_ch22','C',06,0,0,'G','','MV_PAR22',''             ,'',''    ,'SA1'	,	  ''        ,  ''   ,'' })	
	                                                                                                                                                                                             
	/*-----------------------MV_PAR23--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'23','Cliente  Ate ?'		,'Cliente  Ate ?'		,'Cliente  Ate ?'		,'mv_ch23','C',06,0,0,'G','','MV_PAR23',''             ,'',''    ,'SA1'	,	  ''        ,  ''   ,'' })	
	                                                                                                                                                                                             
	/*-----------------------MV_PAR24--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'24','Loja de ?'			,'Loja de ?'			,'Loja de ?'			,'mv_ch24','C',02,0,0,'G','','MV_PAR24',''             ,'',''    ,''  	,	  ''        ,  ''   ,'' })	
	                                                                                                                                                                                             
	/*-----------------------MV_PAR25--------------------------*/                                                                                                                                
//	aAdd(aRegs,{cPerg,'25','Loja  Ate ?'		,'Loja  Ate ?'			,'Loja  Ate ?'			,'mv_ch25','C',02,0,0,'G','','MV_PAR25',''             ,'',''    ,''  	,	  ''        ,  ''   ,'' })
	
	/*-----------------------MV_PAR26--------------------------*/
//	aAdd(aRegs,{cPerg,'26','Tipo Movimento ?'	,'Tipo Movimento ?'		,'Tipo Movimento ?'		,'mv_ch26','C',01,0,0,'C','','MV_PAR26','Saldo Inicial','Entrada','Sada','Mov. Interno','Todos','' })					
		
/*	DbSelectArea('SX1')
	DbSetOrder(1)

	For nX := 1 to Len(aRegs)
		If	!MsSeek(PadR(cPerg, Len(X1_GRUPO)) + aRegs[nX][02])
			If	RecLock('SX1',.T.)
				Replace X1_GRUPO	With aRegs[nX][01]
				Replace X1_ORDEM   	With aRegs[nX][02]
				Replace X1_PERGUNTE	With aRegs[nX][03]
				Replace X1_PERSPA	With aRegs[nX][04]
				Replace X1_PERENG	With aRegs[nX][05]
				Replace X1_VARIAVL	With aRegs[nX][06]
				Replace X1_TIPO		With aRegs[nX][07]
				Replace X1_TAMANHO	With aRegs[nX][08]
				Replace X1_DECIMAL	With aRegs[nX][09]
				Replace X1_PRESEL	With aRegs[nX][10]
				Replace X1_GSC		With aRegs[nX][11]
				Replace X1_VALID	With aRegs[nX][12]
				Replace X1_VAR01	With aRegs[nX][13]
				Replace X1_DEF01	With aRegs[nX][14]
				Replace X1_DEF02	With aRegs[nX][15]
				Replace X1_DEF03	With aRegs[nX][16]
				Replace X1_DEF04	With aRegs[nX][17]
				Replace X1_DEF05	With aRegs[nX][18]
				Replace X1_F3   	With aRegs[nX][19]
				MsUnlock('SX1')
			EndIf
		Endif
	next
	
Return
*/
/*/{Protheus.doc} TESMVEST
//TODO 
@description Funo para retornar se a TES Movimenta Estoque
@author Willian Kaneta
@since 04/06/2019
@version 1.0
@type function
/*/
Static Function TESMVEST(_TipoMov,_cTES, _nQtde)
	Local aArea  	:= GetArea()  
	Local cRet 		:= ""
			
	If(Alltrim(_TipoMov) == "ENTRADA" .OR. Alltrim(_TipoMov) == "SAIDA")
		
		DbSelectArea("SF4")
		SF4->(DbSetOrder(1))
		
		If MsSeek(xFilial("SF4")+_cTES)
			If SF4->F4_ESTOQUE == "S"
				cRet := "Sim"
			ElseIf SF4->F4_ESTOQUE == "N"
				cRet := "No"
			EndIf
		EndIf
		
	ElseIf(Alltrim(_TipoMov) == "INTERNA")
		
		DbSelectArea("SF5")
		SF5->(DbSetOrder(1))
		
		If MsSeek(xFilial("SF5")+_cTES)
			If SF5->F5_QTDZERO == "1" .AND. _nQtde == 0
				cRet := "No"
			ElseIf SF5->F5_QTDZERO == "2"
				cRet := "Sim"
			EndIf
		Elseif(_cTES == "499" .OR. _cTES == "999")
			cRet := "Sim"
		EndIf
		
	EndIf
	
	RestArea(aArea)
	
Return cRet
