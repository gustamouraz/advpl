#include "totvs.ch"
#include 'protheus.ch'
#include 'parmtype.ch' 
#include 'report.ch'

User Function LMRATI01()

    Local cName     := "LMRATI01"
    Local oReport   := NIL
    Private cLMRATI01   := "" 
    Private aColunas    := {}
    
    cLMRATI01   := GetNextAlias()
    oReport     := ReportDef(cName)
    If oReport != NIL
        oReport:PrintDialog()
        FreeObj(oReport)
        oReport := NIL
    EndIf

Return

/*
Definies de estrutura do Relatório
*/
Static Function ReportDef( _name )

    Local cRptTitle := "Relatório Máquinas Agrícolas"      
    Local oReport   := NIL
    Local oSection  := NIL 
    Local nC        := 1

    DEFINE REPORT oReport NAME "MAQAGRIC" TITLE cRptTitle ACTION {|oReport| PrintReport(oReport)} DESCRIPTION cRptTitle    TOTAL IN COLUMN  
    oReport:HideParamPage()
    DEFINE SECTION oSection OF  oReport TITLE cRptTitle TABLES cLMRATI01 TOTAL IN COLUMN
     
    GenerateCells()
    
    For nC := 1 To Len(aColunas) 
        DEFINE CELL NAME aColunas[nC][1] OF oSection ALIAS cLMRATI01   TITLE aColunas[nC][2]  SIZE aColunas[nC][4]
    Next nC 


 
Return oReport

/*
Funo de preenchimento das celulas do relatório
*/
Static Function PrintReport( oReport )

    Local oSection          := oReport:aSection[1]
    Local nTotal, nAtual    := 0
    // Local nC        := 1

    BeginSql Alias cLMRATI01
        %noparser%
        SELECT 
		    N1.N1_FILIAL  AS  'FILIAL', 
		    TRIM(NG.NG_DESCRIC)  AS  'DESCR_GRUPO', 
		    N1.N1_GRUPO  AS  'COD_GRUPO', 
		    N1.N1_QUANTD AS 'QUANTIDADE',
		    TRIM(N1.N1_DESCRIC)  AS  'DESCR', 
		    N1.N1_AQUISIC  AS  'DT_AQUIS', 
		    N1.N1_CHAPA  AS  'PATRIM', 
		    N1.N1_XANOMOD  AS  'ANO_MODELO', 
		    A2.A2_NOME  AS  'FORNECEDOR', 
		    N1.N1_FORNEC  AS  'COD_FORN', 
		    N1.N1_LOJA  AS  'LOJA_FORN', 
		    N1.N1_NFISCAL  AS  'NF', 
		    N1.N1_CHASSIS  AS  'CHASSI_SERIE', 
		    N1.N1_PLACA  AS  'PLACA', 
		    N1.N1_XFROTA  AS  'FROTA',
		    N1.N1_XMARCA AS 'MARCA', 
		    N1.N1_PRODUTO  AS  'COD_PROD', 
		    N1.N1_XPOTATI  AS  'POTENCIA', 
		    N3.N3_CCONTAB  AS  'CT_AQUIS', 
		    N3.N3_VORIG1  AS  'VALOR_BEM', 
		    N3.N3_CUSTBEM  AS  'CC',
		    N3.N3_TXDEPR1  AS  'TX_DEPR', 
		    N1.N1_XINVENT AS 'INVENT',
		    N1.N1_UNIDATU AS 'UNID_ATUAL',
		    N1.N1_XDTINV  AS 'DT_ULT_ALTER',
		    N1.N1_XNFMOV AS 'NF_MOVIMENTO',
		    N1.N1_DTINICI AS 'DT_INI_LOC',
		    N1.N1_DTFIM AS 'DT_FIM_LOC',
		    N1.N1_USUARIO AS 'USUARIO',
		    N1.N1_XRENAV AS 'RENAVAM',
		    N1.N1_XOBS AS  'OBSERVACAO',
		    N3.N3_INTP AS  'INT_PIMS'

		FROM  SN1010 N1 
		    INNER JOIN  SN3010 N3 ON 
		        N1.N1_CBASE = N3.N3_CBASE AND 
		        N1.N1_FILIAL = N3.N3_FILIAL AND 
		        N1.N1_ITEM = N3.N3_ITEM AND 
		        N3.D_E_L_E_T_ = '' 
		    INNER JOIN  SA2010 A2 ON 
		        N1.N1_FORNEC = A2.A2_COD AND 
		        N1.N1_LOJA = A2.A2_LOJA AND 
		        A2.D_E_L_E_T_ = '' 
		    INNER JOIN  SNG010 NG ON 
		        NG.NG_GRUPO = N1.N1_GRUPO AND 
		        NG.D_E_L_E_T_ = '' 
		WHERE 
		    N1.N1_BAIXA = ''  
		    AND N1.N1_STATUS = '1' 
		    AND N1.D_E_L_E_T_= ' '
		    AND N3.N3_TIPO IN ('01')
		    AND N1.N1_GRUPO IN ('01','02','06','07','08','09','10','19','20','21','24','25','26','27','28','29','31','33','36','40','44','47','50','52','53','54','57','58','59')                      

    EndSql

    (cLMRATI01)->(DBGoTop())   
    Count to nTotal
	oReport:SetMeter(nTotal) 
    (cLMRATI01)->(DbGoTop())

    oSection:Init()
    
    While (cLMRATI01)->(!EOF())

        If oReport:lCanceled
            Exit 
        EndIf 

        nAtual++
        oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
        oReport:IncMeter()  
        //  GenerateCells()
    
        //     For nC := 1 To Len(aColunas) 
        //         oSection:Cell(IIF(ValType(aColunas[nC][1]) != 'C', CValToChar(aColunas[nC][1]), aColunas[nC][1])):SetValue( (cLMRATI01)->aColunas[nC][1]		)
        //     Next nC 
			oSection:Cell("FILIAL"):SetValue((cLMRATI01)->FILIAL)
			oSection:Cell("DESCR_GRUPO"):SetValue((cLMRATI01)->DESCR_GRUPO)
			oSection:Cell("COD_GRUPO"):SetValue((cLMRATI01)->COD_GRUPO)
			oSection:Cell("QUANTIDADE"):SetValue((cLMRATI01)->QUANTIDADE)
			oSection:Cell("DESCR"):SetValue((cLMRATI01)->DESCR)
			oSection:Cell("DT_AQUIS"):SetValue(STOD((cLMRATI01)->DT_AQUIS))
			oSection:Cell("PATRIM"):SetValue((cLMRATI01)->PATRIM)
			oSection:Cell("ANO_MODELO"):SetValue((cLMRATI01)->ANO_MODELO)
			oSection:Cell("FORNECEDOR"):SetValue((cLMRATI01)->FORNECEDOR)
			oSection:Cell("COD_FORN"):SetValue((cLMRATI01)->COD_FORN)
			oSection:Cell("LOJA_FORN"):SetValue((cLMRATI01)->LOJA_FORN)
			oSection:Cell("NF"):SetValue((cLMRATI01)->NF)
			oSection:Cell("CHASSI_SERIE"):SetValue((cLMRATI01)->CHASSI_SERIE)
			oSection:Cell("PLACA"):SetValue((cLMRATI01)->PLACA)
			oSection:Cell("FROTA"):SetValue((cLMRATI01)->FROTA)
			oSection:Cell("MARCA"):SetValue((cLMRATI01)->MARCA)
			oSection:Cell("COD_PROD"):SetValue((cLMRATI01)->COD_PROD)
			oSection:Cell("POTENCIA"):SetValue((cLMRATI01)->POTENCIA)
			oSection:Cell("CT_AQUIS"):SetValue((cLMRATI01)->CT_AQUIS)
			oSection:Cell("VALOR_BEM"):SetValue((cLMRATI01)->VALOR_BEM)
			oSection:Cell("CC"):SetValue((cLMRATI01)->CC)
			oSection:Cell("TX_DEPR"):SetValue((cLMRATI01)->TX_DEPR)
			oSection:Cell("INVENT"):SetValue((cLMRATI01)->INVENT)
			oSection:Cell("UNID_ATUAL"):SetValue((cLMRATI01)->UNID_ATUAL)
			oSection:Cell("DT_ULT_ALTER"):SetValue(STOD((cLMRATI01)->DT_ULT_ALTER))
			oSection:Cell("NF_MOVIMENTO"):SetValue((cLMRATI01)->NF_MOVIMENTO)
			oSection:Cell("DT_INI_LOC"):SetValue(STOD((cLMRATI01)->DT_INI_LOC))
			oSection:Cell("DT_FIM_LOC"):SetValue(STOD((cLMRATI01)->DT_FIM_LOC))
			oSection:Cell("USUARIO"):SetValue((cLMRATI01)->USUARIO)
			oSection:Cell("RENAVAM"):SetValue((cLMRATI01)->RENAVAM)
			oSection:Cell("OBSERVACAO"):SetValue((cLMRATI01)->OBSERVACAO)
			oSection:Cell("INT_PIMS"):SetValue((cLMRATI01)->INT_PIMS)
        oSection:PrintLine()
        (cLMRATI01)->(DbSkip())
    EndDo

    oSection:Finish()
    (cLMRATI01)->(DbCloseArea())
Return 


Static Function GenerateCells()
    //TRCell(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHead erAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
	aAdd(aColunas, {"FILIAL"		,"Filial"				,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"DESCR_GRUPO"	,"Descrição Grupo"		,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"COD_GRUPO"		,"Cód. Grupo"			,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"QUANTIDADE"	,"Quantidade"			,"@E 999,999,999.999999",,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"DESCR"			,"Descrição"			,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"DT_AQUIS"		,"Data Aquisição"		,"@D"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"PATRIM"		,"Patrimônio"			,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"ANO_MODELO"	,"Ano/Modelo"			,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"FORNECEDOR"	,"Fornecedor"			,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"COD_FORN"		,"Cód. Fornecedor"		,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"LOJA_FORN"		,"Loja Fornecedor"		,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"NF"			,"Nota Fiscal"			,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"CHASSI_SERIE"	,"Chassi/Série"			,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"PLACA"			,"Placa"				,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"FROTA"			,"Frota"				,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"MARCA"			,"Marca"				,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"COD_PROD"		,"Cód. Produto"			,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"POTENCIA"		,"Potência"				,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"CT_AQUIS"		,"Conta Aquisição"		,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"VALOR_BEM"		,"Valor Bem"			,"@E 999,999,999.999999",,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"CC"			,"Centro de Custo"		,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"TX_DEPR"		,"Taxa Depreciação"		,"@E 999,999,999.999999",,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"INVENT"		,"Inventário"			,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"UNID_ATUAL"	,"Unidade Atual"		,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"DT_ULT_ALTER"	,"Data Últ. Alteração"	,"@D"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"NF_MOVIMENTO"	,"NF de Movimento"		,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"DT_INI_LOC"	,"Data Início Locação"	,"@D"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"DT_FIM_LOC"	,"Data Fim Locação"		,"@D"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"USUARIO"		,"Usuário"				,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"RENAVAM"		,"Renavam"				,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"OBSERVACAO"	,"Observação"			,"@!"					,,,,,.T.,,,,.T.,,,.T. })
	aAdd(aColunas, {"INT_PIMS"		,"Integra PIMS?"		,"@!"					,,,,,.T.,,,,.T.,,,.T. })
Return
