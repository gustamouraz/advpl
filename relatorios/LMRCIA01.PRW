#include "totvs.ch"
#include 'protheus.ch'
#include 'parmtype.ch' 
#include 'report.ch'

User Function LMRCIA01()

    Local cName     := "LMRCIA01"
    Local oReport   := NIL
    Private cLMRCIA01   := "" 
    Private aColunas    := {}
    
    If ParamRel(cName)
        cLMRCIA01   := GetNextAlias()
        oReport     := ReportDef(cName)
        If oReport != NIL
            oReport:PrintDialog()
            FreeObj(oReport)
            oReport := NIL
        EndIf
    EndIf

Return

/*
Definies de estrutura do Relatório
*/
Static Function ReportDef( _name )

    Local cRptTitle := "Relatório Fardos Beneficiados"      
    Local oReport   := NIL
    Local oSection  := NIL 
    Local nC        := 1

    DEFINE REPORT oReport NAME "FARDOSBENE" TITLE cRptTitle ACTION {|oReport| PrintReport(oReport)} DESCRIPTION cRptTitle    TOTAL IN COLUMN  
    oReport:HideParamPage()
    DEFINE SECTION oSection OF  oReport TITLE cRptTitle TABLES cLMRCIA01 TOTAL IN COLUMN
     
    GenerateCells()
    
    For nC := 1 To Len(aColunas) 
        DEFINE CELL NAME aColunas[nC][1] OF oSection ALIAS cLMRCIA01   TITLE aColunas[nC][2]  SIZE aColunas[nC][4]
    Next nC 


 
Return oReport

/*
Funo de preenchimento das celulas do relatório
*/
Static Function PrintReport( oReport )

    Local oSection          := oReport:aSection[1]
    Local cFilStts          := ''
    Local nTotal, nAtual    := 0
    // Local nC        := 1

    MV_PAR07 := IIF(ValType(MV_PAR07) != 'C', CValToChar(MV_PAR07), MV_PAR07)
    
    Do Case
        Case MV_PAR07 == "4"
            cFilStts := "% DXL.DXL_STATUS IN ('5','6') %"
        Case MV_PAR07 == "3"
            cFilStts := "% DXL.DXL_STATUS = '6' AND SUBSTRING(DXB.DXB_EMISSA,1,6) > SUBSTRING(DXL.DXL_DTBEN,1,6) %"
        OtherWise
            cFilStts := "% DXL.DXL_STATUS = '"+(MV_PAR07)+"' %"
    EndCase

    BeginSql Alias cLMRCIA01
        %noparser%
        SELECT
			    DXL.DXL_FAZ AS [FAZENDA],
			    DXL.DXL_SAFRA AS [SAFRA],
			    DXL.DXL_CODIGO AS [FARDAO],
			    DXL.DXL_DTDIGI AS [DT_DIGIT],
			    DXL.DXL_FILBEN AS [FIL_BEN],
			    DXL.DXL_DTBEN AS [DT_BEN],
			    DXB.DXB_EMISSA AS [DT_ENC],
			    DXL.DXL_STATUS AS [CD_ST],
			    CASE 
			        WHEN DXL.DXL_STATUS = '1' THEN 'PREVISTO'
			        WHEN DXL.DXL_STATUS = '2' THEN 'EM ROMANEIO'
			        WHEN DXL.DXL_STATUS = '3' THEN 'DISPONIVEL'
			        WHEN DXL.DXL_STATUS = '4' THEN 'EM BENEFICIAMENTO'
			        WHEN DXL.DXL_STATUS = '5' THEN 'BENEFICIADO'
			        WHEN DXL.DXL_STATUS = '6' AND SUBSTRING(DXB.DXB_EMISSA,1,6) > SUBSTRING(DXL.DXL_DTBEN,1,6) THEN 'FINALIZADO EM OUTRO MÊS'
			        WHEN DXL.DXL_STATUS = '6' THEN 'FINALIZADO'
			    ELSE 'INDEFINIDO' END AS [STATUS]
			FROM %table:DXL% DXL WITH(NOLOCK)
			    LEFT JOIN %table:DXB% DXB WITH(NOLOCK) ON
			        DXB.DXB_FARDAO = DXL.DXL_CODIGO AND
			        DXB.DXB_PRDTOR = DXL.DXL_PRDTOR AND
			        DXB.DXB_LJPRO = DXL.DXL_LJPRO   AND
			        DXB.DXB_FAZ = DXL.DXL_FAZ       AND
			        DXB.DXB_CODPRO = DXL.DXL_CODPRO AND
			        DXB.D_E_L_E_T_ = ''
			WHERE
			    DXL.D_E_L_E_T_ = ''                 AND
			    DXL.DXL_FAZ BETWEEN %Exp:(MV_PAR01)% AND %Exp:(MV_PAR02)%					AND
			    DXL.DXL_SAFRA BETWEEN %Exp:(MV_PAR03)% AND %Exp:(MV_PAR04)%					AND
			    DXL.DXL_DTDIGI BETWEEN %Exp:DToS(MV_PAR05)% AND %Exp:DToS(MV_PAR06)%		AND
                %Exp:cFilStts%
			ORDER BY
			    DXL.DXL_FILBEN,
			    DXL.DXL_FAZ,
			    DXL.DXL_CODIGO,
			    DXL.DXL_DTDIGI
    EndSql

    (cLMRCIA01)->(DBGoTop())   
    Count to nTotal
	oReport:SetMeter(nTotal) 
    (cLMRCIA01)->(DbGoTop())

    oSection:Init()
    
    While (cLMRCIA01)->(!EOF())

        If oReport:lCanceled
            Exit 
        EndIf 

        nAtual++
        oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
        oReport:IncMeter()  
        //  GenerateCells()
    
        //     For nC := 1 To Len(aColunas) 
        //         oSection:Cell(IIF(ValType(aColunas[nC][1]) != 'C', CValToChar(aColunas[nC][1]), aColunas[nC][1])):SetValue( (cLMRCIA01)->aColunas[nC][1]		)
        //     Next nC 
            oSection:Cell("FAZENDA" ):SetValue((cLMRCIA01)->FAZENDA )
            oSection:Cell("SAFRA"   ):SetValue((cLMRCIA01)->SAFRA   )
            oSection:Cell("FARDAO"  ):SetValue((cLMRCIA01)->FARDAO  )
            oSection:Cell("DT_DIGIT"):SetValue(STOD((cLMRCIA01)->DT_DIGIT)  )
            oSection:Cell("FIL_BEN" ):SetValue((cLMRCIA01)->FIL_BEN )
            oSection:Cell("DT_BEN"  ):SetValue(STOD((cLMRCIA01)->DT_BEN)    )
            oSection:Cell("DT_ENC"  ):SetValue(STOD((cLMRCIA01)->DT_ENC)    )
            oSection:Cell("CD_ST"   ):SetValue((cLMRCIA01)->CD_ST   )
            oSection:Cell("STATUS"  ):SetValue((cLMRCIA01)->STATUS  )

        oSection:PrintLine()
        (cLMRCIA01)->(DbSkip())
    EndDo

    oSection:Finish()
    (cLMRCIA01)->(DbCloseArea())
Return 


Static Function GenerateCells()
    //TRCell(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHead erAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
    Aadd(aColunas, { "FAZENDA"      ,"Fazenda"      , "!@", 2 })
    Aadd(aColunas, { "SAFRA"        ,"Safra"        , "!@", 2 })
    Aadd(aColunas, { "FARDAO"       ,"Fardão"       , "!@", 11 })
    Aadd(aColunas, { "DT_DIGIT"     ,"Dt. Digit."   , PesqPict("DXL","DXL_DTDIGI")  , 11 })
    Aadd(aColunas, { "FIL_BEN"      ,"Filial Ben."  , "!@", 6 })
    Aadd(aColunas, { "DT_BEN"       ,"Dt. Ben."     , PesqPict("DXL","DXL_DTBEN")   , 11 })
    Aadd(aColunas, { "DT_ENC"       ,"Dt. Enc."     , PesqPict("DXB","DXB_EMISSA")  , 11 })
    Aadd(aColunas, { "CD_ST"        ,"Cd. Status"   , "!@", 1 })
    Aadd(aColunas, { "STATUS"       ,"Status"       , "!@", 23 })

Return

Static Function ParamRel( cTitle )

    Local lRet      := .F.
    Local aParam    := {} 
    Local aOptions  := {}
    aAdd(aOptions, "1=Beneficiado")
    aAdd(aOptions, "2=Finalizado")
    aAdd(aOptions, "3=Final. outro mês")
    aAdd(aOptions, "4=Ambos")
    
    aAdd(aParam, { 1, "Fazenda de:"             ,/*init*/ "01" , "", /*valid*/".T.", "",/*when*/ ".T.", 80, .F.})
    aAdd(aParam, { 1, "Fazenda até:"            ,/*init*/ "99" , "", /*valid*/".T.", "",/*when*/ ".T.", 80, .T.})
    aAdd(aParam, { 1, "Safra de:"               ,/*init*/ Space(TamSX3('DXL_SAFRA')[01]) , "", /*valid*/".T.", "",/*when*/ ".T.", 80, .F.})
    aAdd(aParam, { 1, "Safra até:"              ,/*init*/ PadR("Z",TamSX3('DXL_SAFRA')[1],"Z") , "", /*valid*/".T.", "",/*when*/ ".T.", 80, .T.})
    aAdd(aParam, { 1, "Data Digitação de:"      ,/*init*/ Date()-7 , "", /*valid*/".T.", "",/*when*/ ".T.", 80, .F.})
    aAdd(aParam, { 1, "Data Digitação até:"     ,/*init*/ Date()  , "", /*valid*/".T.", "",/*when*/ ".T.", 80, .T.})
    aAdd(aParam, { 2, "Situação"  , 4   , aOptions           , 080, ".T.", .T.})
 

    lRet := ParamBox(aParam, cTitle)

Return lRet
