#include "totvs.ch"
#include 'protheus.ch'
#include 'parmtype.ch' 
#include 'report.ch'

User Function LMREST01()

    Local cName     := "LMREST01"
    Local oReport   := NIL
	Local aFiliais  := AdmGetFil(.F.,.F.)
    Private cLMREST01   := "" 
    Private aColunas    := {}
    
	cLMREST01   := GetNextAlias()

	If Len(aFiliais) > 0
        cFiliais := AsString(aFiliais)
        cFiliais := StrTran(cFiliais,"{","'")
        cFiliais := StrTran(cFiliais,"}","'")
        cFiliais := StrTran(cFiliais,",","','")
    	
		If !Pergunte(cName,.T.)
			Return Nil
		EndIf

    	oReport     := ReportDef(cName)
    	If oReport != NIL
    	    oReport:PrintDialog()
    	    FreeObj(oReport)
    	    oReport := NIL
    	EndIf
	Else         
        Help(" ",1,"AF271FIL",,"Selecione a filial para consulta", 1, 0 )
    EndIf

Return

/*
Definies de estrutura do Relatório
*/
Static Function ReportDef( _name )

    Local cRptTitle := "Relatório Movimentações de Baixa"      
    Local oReport   := NIL
    Local oSection  := NIL 
    Local nC        := 1

    DEFINE REPORT oReport NAME "MOVIMEN" TITLE cRptTitle ACTION {|oReport| PrintReport(oReport)} DESCRIPTION cRptTitle    TOTAL IN COLUMN  
    oReport:HideParamPage()
    DEFINE SECTION oSection OF  oReport TITLE cRptTitle TABLES cLMREST01 TOTAL IN COLUMN
     
    GenerateCells()
    
    For nC := 1 To Len(aColunas) 
        DEFINE CELL NAME aColunas[nC][1] OF oSection ALIAS cLMREST01   TITLE aColunas[nC][2]  SIZE aColunas[nC][4]
    Next nC 


 
Return oReport

/*
Funo de preenchimento das celulas do relatório
*/
Static Function PrintReport( oReport )

    Local oSection          := oReport:aSection[1]
    Local nTotal, nAtual    := 0
	Local cFilWhere 	:= '%('+cFiliais+')%'

    // Local nC        := 1

    BeginSql Alias cLMREST01
        %noparser%
		SELECT 
		    D3_EMISSAO
		    , D3_FILIAL
			, CASE D3_FILIAL
		        WHEN '060101' THEN 'SDD'
		        WHEN '060102' THEN 'JK'
		        WHEN '060103' THEN 'JAQ'
		        WHEN '010101' THEN 'SDD'
		        WHEN '010102' THEN 'JK'
		        WHEN '020101' THEN 'CGM'
		        WHEN '020102' THEN 'CGM'
		        WHEN '010103' THEN 'JAQ'
		        WHEN '010104' THEN 'VNT'
		        WHEN '010105' THEN 'TRF'
		        WHEN '010106' THEN 'CPV'
		        WHEN '010107' THEN 'PRS'
		        WHEN '010109' THEN 'MAS'
		        WHEN '010110' THEN 'CBX'
		        WHEN '030101' THEN 'BST'
		        WHEN '030102' THEN 'BDP'
		        WHEN '030103' THEN 'JAQ'
		        WHEN '030104' THEN 'MST'
		        WHEN '040101' THEN 'PTN'
		        WHEN '040102' THEN 'PXI'
		        WHEN '040103' THEN 'PRS'
		        WHEN '040104' THEN 'TRF'
		        WHEN '050101' THEN 'ARM'
		        WHEN '050102' THEN 'ARM'
		        WHEN '050103' THEN 'ARM'
		        WHEN '010111' THEN 'MST'
		        WHEN '030105' THEN 'JK'
		        WHEN '040105' THEN 'CPV'
		        WHEN '040106' THEN 'ALG'
		        WHEN '100101' THEN 'INT'
		        WHEN '800101' THEN 'IMB'
		        WHEN '110101' THEN 'SEM'
		        WHEN '120101' THEN 'LZR'
		        WHEN '010112' THEN 'BFR'
		        WHEN '010113' THEN 'CEN'
		        WHEN '130101' THEN 'VTN'
		        WHEN '060102' THEN 'JK'
		        WHEN '060111' THEN 'CD'
		        WHEN '060110' THEN 'ESC'
		        WHEN '060103' THEN 'JAQ'
		        WHEN '060104' THEN 'BFR'
		        WHEN '060105' THEN 'TRF'
		        WHEN '060106' THEN 'PRS'
		        WHEN '060107' THEN 'MST'
		        WHEN '060108' THEN 'VTN'
		        WHEN '060109' THEN 'CEN'
		        WHEN '010114' THEN 'CD'
		        WHEN '010115' THEN 'SB'
		        WHEN '050104' THEN 'JK'
		        WHEN '120102' THEN 'CPV'
		        WHEN '050105' THEN 'JAQ'
		        WHEN '030106' THEN 'BFR'
		        WHEN '060112' THEN 'SB'
		        WHEN '060113' THEN 'CPV'
		        WHEN '020104' THEN 'CGM'
		        WHEN '020105' THEN 'CGM'
		        WHEN '020106' THEN 'CGM'
		        WHEN '050106' THEN 'AGD'
		        WHEN '060114' THEN 'PPL'
		        WHEN '300101' THEN 'ALX'
		        WHEN '400101' THEN 'MAF'
		        WHEN '010116' THEN 'LNV'
		        WHEN '400102' THEN 'BJD'
		        WHEN '020103' THEN 'CGM'
		        WHEN '060115' THEN 'ALX'
		        WHEN '060116' THEN 'YPE'
		        WHEN '400103' THEN 'MAS'
		        WHEN '400104' THEN 'ALG'
		        WHEN '310101' THEN 'ALX'
		        WHEN '320101' THEN 'VIC'
		        WHEN '300102' THEN 'BHA'
		        WHEN '060117' THEN 'RLZ'
		        WHEN '060118' THEN 'LZR'
		        WHEN '060119' THEN 'DMC'
		        WHEN '330101' THEN 'ENZ'
		        WHEN '020107' THEN 'CGM'
		        WHEN '400105' THEN 'BHA'
		    ELSE NULL END UP
		    , CTT_CUSTO
		    , TRIM(CTT_DESC01) CTT_DESC01
		    , BM_GRUPO
		    , TRIM(BM_DESC) BM_DESC
		    , D3_COD
		    , TRIM(B1_DESC) B1_DESC
		    , D3_QUANT
		    , D3_CUSTO1
		    , YEAR(D3_EMISSAO) ANO
		    , TRIM(B1_XCODFAB) B1_XCODFAB
		    , TRIM(B1_FABRIC) B1_FABRIC
		    , B1_XATIVO
		FROM SD3010 WITH(NOLOCK) 
		INNER JOIN CTT010 WITH(NOLOCK) ON CTT_CUSTO = D3_CC AND CTT010.D_E_L_E_T_ = ''
		INNER JOIN SB1010 WITH(NOLOCK) ON B1_COD = D3_COD AND SB1010.D_E_L_E_T_ = ''
		INNER JOIN SBM010 WITH(NOLOCK) ON BM_GRUPO = B1_GRUPO AND SBM010.D_E_L_E_T_ = ''

		WHERE SD3010.D_E_L_E_T_ = '' AND D3_ESTORNO = ''     
		AND D3_TM LIKE '5%'               
		AND D3_EMISSAO BETWEEN %Exp:DToS(MV_PAR01)% AND %Exp:DToS(MV_PAR02)%
		AND D3_FILIAL IN %Exp:cFilWhere%

    EndSql

    (cLMREST01)->(DBGoTop())   
    Count to nTotal
	oReport:SetMeter(nTotal) 
    (cLMREST01)->(DbGoTop())

    oSection:Init()
    
    While (cLMREST01)->(!EOF())

        If oReport:lCanceled
            Exit 
        EndIf 

        nAtual++
        oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
        oReport:IncMeter()  

			oSection:Cell("D3_EMISSAO"):SetValue(STOD((cLMREST01)->D3_EMISSAO))
			oSection:Cell("D3_FILIAL"):SetValue((cLMREST01)->D3_FILIAL)
			oSection:Cell("UP"):SetValue((cLMREST01)->UP)
			oSection:Cell("CTT_CUSTO"):SetValue((cLMREST01)->CTT_CUSTO)
			oSection:Cell("CTT_DESC01"):SetValue((cLMREST01)->CTT_DESC01)
			oSection:Cell("BM_GRUPO"):SetValue((cLMREST01)->BM_GRUPO)
			oSection:Cell("BM_DESC"):SetValue((cLMREST01)->BM_DESC)
			oSection:Cell("D3_COD"):SetValue((cLMREST01)->D3_COD)
			oSection:Cell("B1_DESC"):SetValue((cLMREST01)->B1_DESC)
			oSection:Cell("D3_QUANT"):SetValue((cLMREST01)->D3_QUANT)
			oSection:Cell("D3_CUSTO1"):SetValue((cLMREST01)->D3_CUSTO1)
			oSection:Cell("ANO"):SetValue((cLMREST01)->ANO)
			oSection:Cell("B1_XCODFAB"):SetValue((cLMREST01)->B1_XCODFAB)
			oSection:Cell("B1_FABRIC"):SetValue((cLMREST01)->B1_FABRIC)
			oSection:Cell("B1_XATIVO"):SetValue((cLMREST01)->B1_XATIVO)
        oSection:PrintLine()
        (cLMREST01)->(DbSkip())
    EndDo

    oSection:Finish()
    (cLMREST01)->(DbCloseArea())
Return 


Static Function GenerateCells()
    //TRCell(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHead erAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
	aAdd(aColunas, {"D3_EMISSAO"	,"Dt. Emissão"			,"@D"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"D3_FILIAL"		,"Filial"				,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"UP"			,"UP"					,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"CTT_CUSTO"		,"Cód. Custo"			,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"CTT_DESC01"	,"Descrição Custo"		,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"BM_GRUPO"		,"Cód. Grupo"			,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"BM_DESC"		,"Descrição Grupo"		,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"D3_COD"		,"Cód. Prod."			,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"B1_DESC"		,"Descrição Produto"	,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"D3_QUANT"		,"Quantidade"			,"@E 999,999,999.999999",,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"D3_CUSTO1"		,"Custo"				,"@E 999,999,999.999999",,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"ANO"			,"Ano"					,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"B1_XCODFAB"	,"Cód. Fabricante"		,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"B1_FABRIC"		,"Atendimento"			,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"B1_XATIVO"		,"Ativo?"				,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	
Return
