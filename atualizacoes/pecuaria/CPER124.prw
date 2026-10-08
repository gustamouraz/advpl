#Include 'Protheus.ch'

/*/{Protheus.doc} CPER124
@description Relatorio Posicao Media de Consumo
@author Jared Ribeiro
@since 03/11/2024
@version 1.0
@type user function
/*/
User Function CPER124()

	Local oReport := Nil

	Private cPerg      := "CPER124A"

    oFazendaSel := PCDTCSelecFazenda():New()
	oFazendaSel:VldAcessoFaz()

	If ( oFazendaSel:nQtdFaz = 1 )

		oFazendaSel:nOpcCF      := 0
		oFazendaSel:lMarcado    := .T.

	ElseIf ( oFazendaSel:nQtdFaz > 1 )

		oFazendaSel:MontarBrowse()

	EndIf

    If ( oFazendaSel:nOpcCF = 0 .and. oFazendaSel:lMarcado )

        AjustaSX1(cPerg)

        Pergunte( cPerg, .t. )

        oReport := ReportDef()
        oReport:PrintDialog()

    else
        If oFazendaSel:nQtdFaz = 0
			MsgAlert( "Nao existe fazenda vinculado ao seu usuario. Verificar com o responsavel!" )
		EndIf
    Endif

Return

/*/{Protheus.doc} ReportDef
@description  Definicoes da estrutura do relatorio
@author Jared Ribeiro
@since 03/11/2024
@version 1.0
@type user function
/*/
Static Function ReportDef()

	Local oReport	 := Nil
	Local oSection1	 := Nil 
    Local oSection2	 := Nil 
	Local oSection3	 := Nil
	Local oBrkTotal  := Nil

	oReport := TReport():New("CPER124", "Relatorio Posicao Media de Consumo",, {| oReport | PrintReport( oReport ) }, "")
	oReport:SetTotalInLine( .f. )
	oReport:SetLandScape()
	oReport:DisableOrientation()
    oReport:SetDevice(2)            // Define o tipo de impressao selecionado. Opcoes: 1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html.
	oReport:SetEnvironment(2)       // Define o ambiente para impressao. Ambiente: 1-Server e 2-Cliente

	oSection1 := TRSection():New( oReport, "Fazenda", {})
    TRCell():New( oSection1, "NAS_CODFAZ" , , "Fazenda" 		   , x3Picture('NAS_CODFAZ') , 8                      , , , "LEFT"  , , "LEFT" )
	TRCell():New( oSection1, "NAF_NOME"   , , "Nome da Fazenda"    , x3Picture('NAF_NOME')   , TamSx3("NAF_NOME")[1]  , , , "LEFT"  , , "LEFT" )
    TRCell():New( oSection1, "NAS_DTBASE" , , "Data Base"          , x3Picture('NAS_DATINI') , 10                     , , , "LEFT"  , , "LEFT" )
    TRCell():New( oSection1, "NAS_RETRO"  , , "Media Retroativa (D-?)",                      , 25                     , , , "RIGHT" , , "RIGHT" )

    oSection1:SetPageBreak(.f.)

    oSection2 := TRSection():New( oReport, "Consumos", {})	 
    TRCell():New( oSection2, "NAT_TIPLOT" , , "Tipo"           , x3Picture('NAS_TIPLOT')         , 8                     , , , "LEFT"  , , "LEFT" )                                                           		                                                             
	TRCell():New( oSection2, "NAT_NOMPAS" , , "Area"           ,                                 , 15  , , , "LEFT"  , , "LEFT" )
    TRCell():New( oSection2, "NAT_NOMLOT" , , "Lote"           ,                                 , 26  , , , "LEFT"  , , "LEFT" )
    TRCell():New( oSection2, "NAT_QTDANI" , , "Cab"                    , x3Picture('NAT_QTDANI') , 4                      , , , "RIGHT" , , "LEFT") 
	TRCell():New( oSection2, "NAS_ZSEXO"   , , "Sexo"                   , "@!"                  , 10                     , , , "LEFT"  , , "LEFT")
	TRCell():New( oSection2, "NAS_ZCATEG"  , , "Categoria"              , "@!"                  , 12                     , , , "LEFT"  , , "LEFT")
    TRCell():New( oSection2, "NAT_RACA"   , , "Racas"                  , "@!"                    , 10                     , , , "LEFT"  , , "LEFT" )
    TRCell():New( oSection2, "NAS_DATINI" , , "Data" +CRLF+ "Entrada"  , x3Picture('NAS_DATINI') , 10                     , , , "LEFT"  , , "LEFT" )
    TRCell():New( oSection2, "NAS_PESO"   , , "Peso" +CRLF+ "Entrada"  , x3Picture('NAS_PESO')   , 8                      , , , "RIGHT" , , "RIGHT")
    TRCell():New( oSection2, "NAT_PESO"   , , "Peso" +CRLF+ "Atual"    , x3Picture('NAT_PESO')   , 8                      , , , "RIGHT" , , "RIGHT")
    TRCell():New( oSection2, "NAT_DIAS"   , , "Dias" +CRLF+ "Cocho"    , "999"                   , 5                      , , , "RIGHT" , , "RIGHT")
    TRCell():New( oSection2, "NAP_DESCRA" , , "Dieta Atual"            ,                         , 20                     , , , "LEFT"  , , "LEFT" )
    TRCell():New( oSection2, "NAT_DIARAC" , , "Dias" +CRLF+ "Dieta"    , "999"                   , 5                      , , , "RIGHT" , , "RIGHT")
    TRCell():New( oSection2, "NAT_CONATU" , , "Consumo"  +CRLF+ "Dt Base"                        , "@E 99.99" , 11        , , , "RIGHT" , , "RIGHT")  
    TRCell():New( oSection2, "NAT_CONONT" , , "Consumo"  +CRLF+ "D-1"                            , "@E 99.99" , 7         , , , "RIGHT" , , "RIGHT")
    TRCell():New( oSection2, "NAT_CONPAR" , , "Consumo"  +CRLF+ "D-"+cValToChar(mv_par02)        , "@E 99.99" , 7         , , , "RIGHT" , , "RIGHT")
    TRCell():New( oSection2, "NAT_CONMED" , , "Consumo"  +CRLF+ "Geral"                          , "@E 99.99" , 8         , , , "RIGHT" , , "RIGHT")
    TRCell():New( oSection2, "NAT_PVATU"  , , "Cons %PV" +CRLF+ "Dt Base"                        , "@E 99.99" , 11        , , , "RIGHT" , , "RIGHT")  
    TRCell():New( oSection2, "NAT_PVONT"  , , "Cons %PV" +CRLF+ "D-1"                            , "@E 99.99" , 9         , , , "RIGHT" , , "RIGHT")
    TRCell():New( oSection2, "NAT_PVPAR"  , , "Cons %PV" +CRLF+ "D-"+cValToChar(mv_par02)        , "@E 99.99" , 9         , , , "RIGHT" , , "RIGHT")
    TRCell():New( oSection2, "NAT_PVMED"  , , "Cons %PV" +CRLF+ "Geral"                          , "@E 99.99" , 9         , , , "RIGHT" , , "RIGHT")
    TRCell():New( oSection2, "NAT_NOTATU"  , , "Leitura" +CRLF+ "Dt Base"                        , x3Picture('NAR_NOTSCR') , 8 , , , "LEFT" , , "LEFT")  
    TRCell():New( oSection2, "NAT_NOTONT"  , , "Leitura" +CRLF+ "D-1"                            , x3Picture('NAR_NOTSCR') , 7 , , , "LEFT" , , "LEFT")
    TRCell():New( oSection2, "NAT_NOTANT"  , , "Leitura" +CRLF+ "D-2"                            , x3Picture('NAR_NOTSCR') , 7 , , , "LEFT" , , "LEFT")                                                 		                                                             
    TRCell():New( oSection2, "NAT_QUEBRA"  , , ""           ,, 5                     , , , "LEFT"  , , "LEFT" )                                                           	                                                             

	// Criar os campos NAS_ZSEXO e NAS_ZCATEG no SX3 da tabela NAS.
	// Eles registram a classificacao informada no Planejamento Nutricional.
	oSection3 := TRSection():New( oReport, "Resumo por Sexo", {})
	TRCell():New( oSection3, "CPER_DESC"  , , "Resumo"        , "@!"           , 24, , , "LEFT" , , "LEFT" )
	TRCell():New( oSection3, "CPER_QTD"   , , "Qtde. Cabecas" , "@!"          , 28, , , "RIGHT", , "RIGHT")


	oBrkTotal  := TRBreak():New(oSection2, {||.t.}  ,"Total Dieta",,"TOTRACAO")	
    TRFunction():New(oSection2:Cell("NAT_NOMPAS") ,"","COUNT"   ,oBrkTotal,,"9999",,.f.,.f.)
	TRFunction():New(oSection2:Cell("NAT_QTDANI") ,"","SUM"     ,oBrkTotal,,x3Picture("NAT_QTDANI") ,,.f.,.f.)
	TRFunction():New(oSection2:Cell("NAS_PESO")   ,"","AVERAGE" ,oBrkTotal,,x3Picture("NAS_PESO")  ,,.f.,.f.)
	TRFunction():New(oSection2:Cell("NAT_PESO")   ,"","AVERAGE" ,oBrkTotal,,x3Picture("NAT_PESO") ,,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_DIAS")   ,"","AVERAGE" ,oBrkTotal,,x3Picture("NAT_DIAS"),,.f.,.f.)
	TRFunction():New(oSection2:Cell("NAT_DIARAC") ,"","AVERAGE" ,oBrkTotal,,x3Picture("NAT_DIARAC") ,,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_CONATU") ,"","AVERAGE" ,oBrkTotal,,"@E 99.99" ,,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_CONONT") ,"","AVERAGE" ,oBrkTotal,,"@E 99.99" ,,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_CONPAR") ,"","AVERAGE" ,oBrkTotal,,"@E 99.99" ,,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_CONMED") ,"","AVERAGE" ,oBrkTotal,,"@E 99.99" ,,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_PVATU")  ,"","AVERAGE" ,oBrkTotal,,"@E 99.99" ,,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_PVONT")  ,"","AVERAGE" ,oBrkTotal,,"@E 99.99" ,,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_PVPAR")  ,"","AVERAGE" ,oBrkTotal,,"@E 99.99" ,,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_PVMED")  ,"","AVERAGE" ,oBrkTotal,,"@E 99.99" ,,.f.,.f.)

    oBrkTipo  := TRBreak():New(oSection2, {||.t.}  ,"Total Tipo Lote",,"TOTTIPO")	
	//TRFunction():New(oSection2:Cell("NAT_DIARAC") ,"","AVERAGE" ,oBrkTipo,,x3Picture("NAT_DIARAC") ,,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_CONATU") ,"","AVERAGE" ,oBrkTipo,,"@E 99.99" ,,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_CONONT") ,"","AVERAGE" ,oBrkTipo,,"@E 99.99" ,,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_CONPAR") ,"","AVERAGE" ,oBrkTipo,,"@E 99.99" ,,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_CONMED") ,"","AVERAGE" ,oBrkTipo,,"@E 99.99" ,,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_PVATU")  ,"","AVERAGE" ,oBrkTipo,,"@E 99.99" ,,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_PVONT")  ,"","AVERAGE" ,oBrkTipo,,"@E 99.99" ,,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_PVPAR")  ,"","AVERAGE" ,oBrkTipo,,"@E 99.99" ,,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_PVMED")  ,"","AVERAGE" ,oBrkTipo,,"@E 99.99" ,,.f.,.f.)

    oBrkFaz  := TRBreak():New(oSection2, {||.t.}  ,"Total Fazenda",,"TOTFAZ")	
	//TRFunction():New(oSection2:Cell("NAT_DIARAC") ,"","AVERAGE" ,oBrkFaz,,x3Picture("NAT_DIARAC") ,,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_CONATU") ,"","AVERAGE" ,oBrkFaz,,"@E 99.99" ,,.f.,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_CONONT") ,"","AVERAGE" ,oBrkFaz,,"@E 99.99" ,,.f.,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_CONPAR") ,"","AVERAGE" ,oBrkFaz,,"@E 99.99" ,,.f.,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_CONMED") ,"","AVERAGE" ,oBrkFaz,,"@E 99.99" ,,.f.,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_PVATU")  ,"","AVERAGE" ,oBrkFaz,,"@E 99.99" ,,.f.,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_PVONT")  ,"","AVERAGE" ,oBrkFaz,,"@E 99.99" ,,.f.,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_PVPAR")  ,"","AVERAGE" ,oBrkFaz,,"@E 99.99" ,,.f.,.f.,.f.)
    TRFunction():New(oSection2:Cell("NAT_PVMED")  ,"","AVERAGE" ,oBrkFaz,,"@E 99.99" ,,.f.,.f.,.f.)

Return( oReport )

/*/{Protheus.doc} PrintReport
@description  Impressao do relatorio
@author Jared Ribeiro
@since 27/10/2024
@version 1.0
@type user function
/*/
Static Function PrintReport( oReport )

    Local aNota      := {}
    Local aMedias    := {}
	Local oSection1	 := oReport:Section(1)
    Local oSection2	 := oReport:Section(2)
	Local oSection3	 := oReport:Section(3)
    Local oBrkTotal  := oSection2:GetBreak("TOTRACAO")
    Local oBrkTipo   := oSection2:GetBreak("TOTTIPO")
    Local oBrkFaz    := oSection2:GetBreak("TOTFAZ")
    Local cAlias     := GetNextAlias()
    Local cRacas     := ''
    Local cTipoLote  := ''
    Local cDieta     := ''
    Local cQuery     := ''
    Local cWhere     := ''
    Local nRegs      := 0

    Local nConsOntem := 0
    Local nPvOntem   := 0
    Local cNota      := ''
    Local cNotaOntem := ''
    Local cNotaD2    := ''
    Local cSexo      := ''
    Local cCategoria := ''
    Local cResumo    := ''
    Local cResumoQtd := ''
    Local nTotMacho  := 0
    Local nTotFemea  := 0

    Private oQueryMed := NIL

    oSection1:Cell("NAS_CODFAZ"):SetBlock({|| oFazendaSel:cCodFazenda })
    oSection1:Cell("NAF_NOME"  ):SetBlock({|| Posicione('NAF', 1, xFilial('NAF') + oFazendaSel:cCodFazenda, 'NAF_NOME' ) })
    oSection1:Cell("NAS_DTBASE"):SetBlock({|| DtoC(MV_PAR01) })
    oSection1:Cell("NAS_RETRO" ):SetBlock({|| cValToChar(MV_PAR02) +" dia(s)" })
    
    oSection2:Cell("NAT_TIPLOT"):SetBlock({|| cTipoLote })
    oSection2:Cell("NAT_NOMPAS"):SetBlock({|| (cAlias)->NAT_NOMPAS })
    oSection2:Cell("NAT_NOMLOT"):SetBlock({|| (cAlias)->NAT_NOMLOT })
    oSection2:Cell("NAT_QTDANI"):SetBlock({|| (cAlias)->NAT_QTDANI })
    oSection2:Cell("NAS_ZSEXO"  ):SetBlock({|| cSexo })
    oSection2:Cell("NAS_ZCATEG" ):SetBlock({|| cCategoria })
    oSection2:Cell("NAT_RACA"  ):SetBlock({|| cRacas })
    oSection2:Cell("NAS_DATINI"):SetBlock({|| DtoC((cAlias)->NAS_DATINI) })
    oSection2:Cell("NAS_PESO"  ):SetBlock({|| (cAlias)->NAS_PESO })
    oSection2:Cell("NAT_PESO"  ):SetBlock({|| (cAlias)->NAT_PESO })
    oSection2:Cell("NAT_DIAS"  ):SetBlock({|| DateDiffDay((cAlias)->NAS_DATINI, MV_PAR01)+1 })
    oSection2:Cell("NAP_DESCRA"):SetBlock({|| SubStr((cAlias)->NAP_DESCRA,1,20) })
    oSection2:Cell("NAT_DIARAC"):SetBlock({|| (cAlias)->NAT_DIARAC })
    oSection2:Cell("NAT_CONATU"):SetBlock({|| Round((cAlias)->NAT_CONATU,2) })
    oSection2:Cell("NAT_CONONT"):SetBlock({|| Round(nConsOntem,2) })
    oSection2:Cell("NAT_CONPAR"):SetBlock({|| Round(aMedias[1],2) })
    oSection2:Cell("NAT_CONMED"):SetBlock({|| Round(aMedias[3],2) })
    oSection2:Cell("NAT_PVATU" ):SetBlock({|| Round((cAlias)->NAT_PVATU,2) })
    oSection2:Cell("NAT_PVONT" ):SetBlock({|| Round(nPvOntem,2) })
    oSection2:Cell("NAT_PVPAR" ):SetBlock({|| Round(aMedias[2],2) })
    oSection2:Cell("NAT_PVMED" ):SetBlock({|| Round(aMedias[4],2) })
    oSection2:Cell("NAT_NOTATU"):SetBlock({|| cNota })
    oSection2:Cell("NAT_NOTONT"):SetBlock({|| cNotaOntem })
    oSection2:Cell("NAT_NOTANT"):SetBlock({|| cNotaD2 })
    oSection2:Cell("NAT_QUEBRA"):SetBlock({|| (cAlias)->NAS_TIPLOT+(cAlias)->NAP_RACAO })

    oSection3:Cell("CPER_DESC"):SetBlock({|| cResumo })
    oSection3:Cell("CPER_QTD" ):SetBlock({|| cResumoQtd })

    oBrkTotal:SetBreak( oSection2:Cell("NAT_QUEBRA") )
    oBrkTipo:SetBreak( oSection2:Cell("NAT_TIPLOT") )

    oBrkTotal:SetTitle({|| "Total "+ SubStr(cDieta,1,30) })
    oBrkTipo:SetTitle( {|| "Total "+ Upper(cTipo) })
    oBrkFaz:SetTitle( {|| "Total "+ Alltrim(Posicione('NAF', 1, xFilial('NAF') + oFazendaSel:cCodFazenda, 'NAF_NOME' ))    })

    oBrkTotal:OnPrintTotal({|| oReport:SkipLine() })
    oBrkTipo:OnPrintTotal({|| (oReport:SkipLine(),oReport:SkipLine()) })

    oSection2:Cell("NAT_QUEBRA"):Disable()

    //Monta a query da busca da media retroativa
    cQuery := "SELECT COALESCE(AVG(NAT_MEDCON),0) NAT_MEDCON, COALESCE(AVG(NAT_MEDPV),0) NAT_MEDPV "
    cQuery += "FROM ( "
    cQuery += "        SELECT CASE WHEN NAT.NAT_AJUSMS = '1' "
    cQuery += "                        THEN (NAT.NAT_QTDRMS / NAT.NAT_DIASCO / NAT.NAT_QTDANI) "
    cQuery += "                        ELSE (NAT.NAT_QJFOR / NAT.NAT_DIASCO / NAT.NAT_QTDANI) END NAT_MEDCON, "
    cQuery += "                    CASE WHEN NAT.NAT_AJUSMS = '1' "
    cQuery += "                        THEN (((NAT.NAT_QTDRMS / NAT.NAT_DIASCO / NAT.NAT_QTDANI) / NAT.NAT_PESO) * 100) 
	cQuery += "                        ELSE (((NAT.NAT_QJFOR / NAT.NAT_DIASCO / NAT.NAT_QTDANI) / NAT.NAT_PESO) * 100) END NAT_MEDPV 
    cQuery += "            FROM "+RetSqlName("NAT")+" NAT "
    cQuery += "            WHERE NAT.NAT_FILIAL = '"+ xFilial("NAT") +"' AND "
    cQuery += "                  NAT.NAT_CODFAZ = '"+ oFazendaSel:cCodFazenda +"' AND "
    cQuery += "                  NAT.NAT_CODIGO = ? AND "
    cQuery += "                  NAT.NAT_RACAO = ? AND "
    cQuery += "                  NAT.NAT_DATA BETWEEN ? AND ? AND "
    cQuery += "                  NAT.NAT_QJFOR > 0 AND "
    cQuery += "                  NAT.D_E_L_E_T_ <> '*' ) MED "

    cQuery    := ChangeQuery(cQuery)
    oQueryMed := FwPreparedStatement():New(cQuery)

    If MV_PAR03 <> 5
        cWhere := " NAS.NAS_TIPLOT = '"+cValToChar(MV_PAR03)+"' AND "
    Endif

    cWhere := '%'+cWhere+'%'

    If Select(cAlias) > 0
        (cAlias)->(DbCloseArea())
    Endif

    BeginSql Alias cAlias

		COLUMN NAS_DATINI AS DATE
		COLUMN NAT_DATA   AS DATE

        SELECT  NAS.NAS_CODIGO, NAS.NAS_CODPAS, NAS.NAS_LOTE, NAS.NAS_GMD, 
                NAA.NAA_NOME AS NAT_NOMPAS, COALESCE(NAB.NAB_NOME,'') AS NAT_NOMLOT, 
                NAS.NAS_TIPLOT, NAS.NAS_ZSEXO, NAS.NAS_ZCATEG, NAT.NAT_QTDANI, NAS.NAS_DATINI, NAS.NAS_PESO, NAT.NAT_PESO, NAT.NAT_DATA, NAP.NAP_RACAO,
                NAP.NAP_DESCRA,
                (SELECT SUM(CASE WHEN DIAS.NAT_DATA = %exp:DTOS(MV_PAR01)%
	                        THEN DIAS.NAT_DIASCO - DIAS.NAT_DIASCO + 1
	                        ELSE DIAS.NAT_DIASCO END) 
                FROM %Table:NAT% DIAS 
                WHERE DIAS.NAT_FILIAL = NAT.NAT_FILIAL AND
                        DIAS.NAT_CODFAZ = NAT.NAT_CODFAZ AND
                        DIAS.NAT_CODIGO = NAT.NAT_CODIGO AND
                        DIAS.NAT_RACAO = NAT.NAT_RACAO AND
                        DIAS.NAT_DATA <= NAT.NAT_DATA AND
                        DIAS.NAT_QJFOR > 0 AND
                        DIAS.%NotDel%) NAT_DIARAC, 
                CASE WHEN NAT.NAT_AJUSMS = '1'
                    THEN (NAT.NAT_QTDRMS / NAT.NAT_DIASCO / NAT.NAT_QTDANI)
                    ELSE (NAT.NAT_QJFOR / NAT.NAT_DIASCO / NAT.NAT_QTDANI) END NAT_CONATU,
                CASE WHEN NAT.NAT_AJUSMS = '1'
                    THEN (((NAT.NAT_QTDRMS / NAT.NAT_DIASCO / NAT.NAT_QTDANI) / NAT.NAT_PESO) * 100) 
					ELSE (((NAT.NAT_QJFOR / NAT.NAT_DIASCO / NAT.NAT_QTDANI) / NAT.NAT_PESO) * 100) END NAT_PVATU, 
                NAT.NAT_NOTSCR NAT_NOTATU
            
        FROM %Table:NAT% NAT
        INNER JOIN %Table:NAS% NAS ON NAS.NAS_FILIAL = NAT.NAT_FILIAL AND NAS.NAS_CODFAZ = NAT.NAT_CODFAZ AND 
                                NAS.NAS_CODIGO = NAT.NAT_CODIGO AND NAS.%NotDel%
        INNER JOIN %Table:NAP% NAP ON NAP.NAP_FILIAL = NAT.NAT_FILIAL AND NAP.NAP_CODFAZ = NAT.NAT_CODFAZ AND 
                                NAP.NAP_CODIGO = NAT.NAT_CODIGO AND NAP.NAP_RACAO = NAT.NAT_RACAO AND NAP.%NotDel%
        INNER JOIN %Table:NAA% NAA ON NAA.NAA_CODFAZ = NAS.NAS_CODFAZ AND NAA.NAA_CODIGO = NAS.NAS_CODPAS AND NAA.%NotDel%
        LEFT JOIN %Table:NAB% NAB ON NAB.NAB_CODFAZ = NAS.NAS_CODFAZ AND NAB.NAB_CODIGO = NAS.NAS_LOTE AND NAB.%NotDel%
        WHERE NAT.%NotDel% AND
              NAT.NAT_CODFAZ = %exp:oFazendaSel:cCodFazenda% AND
              NAT.NAT_DATA = %exp:DTOS(MV_PAR01)% AND
              %exp:cWhere%
              NAT.NAT_QJFOR > 0
        ORDER BY NAS.NAS_TIPLOT, NAP.NAP_RACAO,NAA.NAA_NOME,COALESCE(NAB.NAB_NOME,'')

    EndSql

    (cAlias)->(DbEval({|| nRegs++ }))

    (cAlias)->(DbGoTop())

    If nRegs > 0

        oReport:SetMeter(nRegs)

        cAliasMed  := GetNextAlias()

        DbSelectArea('NAT')
        NAT->(DbSetOrder(1))

        oSection1:Init()
        oSection1:PrintLine()
        oSection1:Finish()	

        oReport:SkipLine()

        oSection2:Init()

        While !(cAlias)->(Eof())
                
                If oReport:Cancel()
                    Exit
                EndIf

                oReport:SetMsgPrint("Imprimindo...")
                oReport:IncMeter()

                If (cAlias)->NAS_TIPLOT == '1'
                    cTipoLote := "Cria"
                ElseIf (cAlias)->NAS_TIPLOT == '2'
                    cTipoLote := "Recria"
                ElseIf (cAlias)->NAS_TIPLOT == '3'
                    cTipoLote := "Engorda"
                Endif

                aMedias    := {}
                nConsOntem := 0
                nPvOntem   := 0
                cNotaOntem := ''

                cNota   := (cAlias)->NAT_NOTATU
                cNotaD2 := Posicione('NAT',1,xFilial('NAT') + (cAlias)->NAS_CODIGO+oFazendaSel:cCodFazenda+(cAlias)->NAP_RACAO + DtoS(MV_PAR01-2), 'NAT_NOTSCR')
                cSexo      := xDescSexo((cAlias)->NAS_ZSEXO)
                cCategoria := xDescCategoria((cAlias)->NAS_ZCATEG)

                // A quantidade do planejamento e a quantidade de cabecas exibida na linha.
                // Ela e a base do total por sexo, e nao o numero de linhas do relatorio.
                If cSexo == "MACHO"
                    nTotMacho += (cAlias)->NAT_QTDANI
                ElseIf cSexo == "FEMEA"
                    nTotFemea += (cAlias)->NAT_QTDANI
                EndIf

                //Busca as racas do lote
                cRacas  := xBuscaRaca((cAlias)->NAS_CODIGO, (cAlias)->NAS_CODPAS,(cAlias)->NAS_LOTE)
                aMedias := xBuscaMedias((cAlias)->NAS_CODIGO, (cAlias)->NAP_RACAO, (cAlias)->NAS_DATINI)

                If NAT->(DbSeek(xFilial('NAT')+(cAlias)->NAS_CODIGO+oFazendaSel:cCodFazenda+(cAlias)->NAP_RACAO+DTOS(MV_PAR01-1)))
                    If NAT->NAT_AJUSMS = '1' .And. NAT->NAT_QTDRMS > 0
                        nConsOntem := NAT->NAT_QTDRMS / NAT->NAT_DIASCO / NAT->NAT_QTDANI
                        nPvOntem   := ((NAT->NAT_QTDRMS / NAT->NAT_DIASCO / NAT->NAT_QTDANI) / NAT->NAT_PESO) * 100
                    ElseIf NAT->NAT_AJUSMS <> '1' .And. NAT->NAT_QJFOR > 0
                        nConsOntem := NAT->NAT_QJFOR / NAT->NAT_DIASCO / NAT->NAT_QTDANI
                        nPvOntem   := ((NAT->NAT_QJFOR / NAT->NAT_DIASCO / NAT->NAT_QTDANI) / NAT->NAT_PESO) * 100
                    Endif
                    
                    cNotaOntem := NAT->NAT_NOTSCR

                Endif

                oSection2:PrintLine()
                cDieta := SubStr((cAlias)->NAP_DESCRA,1,20)
                cTipo  := cTipoLote


            (cAlias)->(DbSkip())

        Enddo

        oSection2:Finish()	

        oReport:SkipLine()
        oSection3:Init()
        cResumo := "Total Macho / Total Femea"
        cResumoQtd := AllTrim(Str(nTotMacho)) + " / " + AllTrim(Str(nTotFemea))
        oSection3:PrintLine()
        cResumo := "Total Geral (Macho/Femea)"
        cResumoQtd := AllTrim(Str(nTotMacho + nTotFemea))
        oSection3:PrintLine()
        oSection3:Finish()
		
    Endif

    (cAlias)->(DbCloseArea())

Return

/*/{Protheus.doc} xDescSexo
@description Normaliza o sexo salvo no planejamento para apresentacao no relatorio.
/*/
Static Function xDescSexo(cSexo)

    cSexo := Upper(AllTrim(cSexo))

    If cSexo == "M" .Or. cSexo == "MACHO" .Or. cSexo == "MASCULINO"
        Return("MACHO")
    ElseIf cSexo == "F" .Or. cSexo == "FEMEA" .Or. cSexo == "FEMININO"
        Return("FEMEA")
    EndIf

Return("")

/*/{Protheus.doc} xDescCategoria
@description Normaliza a categoria salva no planejamento para apresentacao no relatorio.
/*/
Static Function xDescCategoria(cCategoria)

Return(Upper(AllTrim(cCategoria)))

/*/{Protheus.doc} xBuscaRaca
@description Busca as racas de forma retroativa ou nao
@author Jared Ribeiro
@since 	03/11/2024
/*/
Static Function xBuscaRaca(xCodPla, xArea, xLote)

    Local cRacas  := ""
    Local cAlias  := GetNextAlias()
    Local cWhere  := ""

    cWhere := " NAD.NAD_STATUS = '1'"

    IF !Empty(xArea)
        cWhere += " AND NAD.NAD_PASTO = '"+xArea+"' "
    ENDIF	

    IF !Empty(xLote)
        cWhere += " AND NAD.NAD_LOTE = '"+xLote+"' "
    ENDIF

    cWhere := '%'+ cWhere +'%'

    If Select(cAlias) > 0
        (cAlias)->(DbCloseArea())
    Endif

    BeginSql Alias cAlias

        SELECT NAD.NAD_RACA, NBB.NBB_INTCER, COALESCE(NADANT.NAD_RACA,'') RACANT, COALESCE(RACANT.NBB_INTCER,'') CODANT
        FROM %Table:NAD% NAD
        INNER JOIN %Table:NBB% NBB ON NBB.NBB_FILIAL = %exp:xFilial('NBB')% AND NBB.NBB_CODIGO = NAD.NAD_RACA AND NBB.%NotDel%
        LEFT JOIN %Table:NA3% NA3 ON NA3.NA3_FILIAL = %exp:xFilial('NA3')% AND NA3.NA3_CODFAZ = NAD.NAD_CODFAZ AND NA3.NA3_CODPLA = %exp:xCodPla% AND
                                     NA3.NA3_DATA = %exp:MV_PAR01% AND NA3.%NotDel%
        LEFT JOIN %Table:NAD% NADANT ON NADANT.NAD_SISBOV = NA3.NA3_SISBOV AND NADANT.%NotDel%
        LEFT JOIN %Table:NBB% RACANT ON RACANT.NBB_FILIAL = %exp:xFilial('NBB')% AND RACANT.NBB_CODIGO = NADANT.NAD_RACA AND RACANT.%NotDel%
        WHERE NAD.NAD_CODFAZ = %exp:oFazendaSel:cCodFazenda% AND
              NAD.%NotDel% AND
              %exp:cWhere%
        GROUP BY NAD.NAD_RACA, NBB.NBB_INTCER, COALESCE(NADANT.NAD_RACA,''), COALESCE(RACANT.NBB_INTCER,'')
        ORDER BY COALESCE(RACANT.NBB_INTCER,''), NBB.NBB_INTCER

    EndSql

    While !(cAlias)->(Eof())

            If !Empty(Alltrim((cAlias)->CODANT)) 
                If !(Alltrim((cAlias)->CODANT) $ cRacas)
                    cRacas += Alltrim((cAlias)->CODANT) + '/'
                Endif
            ElseIf !Empty(Alltrim((cAlias)->NBB_INTCER)) 
                If !(Alltrim((cAlias)->NBB_INTCER) $ cRacas)
                    cRacas += Alltrim((cAlias)->NBB_INTCER) + '/'
                Endif
            Endif

        (cAlias)->(DbSkip())
    Enddo

    (cAlias)->(DbCloseArea())

    If !Empty(cRacas)
        cRacas := SubStr(cRacas,1,Len(cRacas)-1)
    Endif

Return(cRacas)

/*/{Protheus.doc} xBuscaMedias
@description Busca as medias retroativas
@author Jared Ribeiro
@since 	03/11/2024
/*/
Static Function xBuscaMedias(xCodPlan, xDieta, xDataIni)

    Local aMedias   := {0,0,0,0}
    Local cAliasMed := GetNextAlias()
    Local dDatRetro := MV_PAR01 - MV_PAR02

    If Select(cAliasMed) > 0
        (cAliasMed)->(DbCloseArea())
    Endif

    //Primeiro busca a media D- parametro informado no relatorio
    oQueryMed:SetString(1, xCodPlan )
    oQueryMed:SetString(2, xDieta )
    oQueryMed:SetString(3, DtoS(dDatRetro) )
    oQueryMed:SetString(4, DtoS(MV_PAR01) )

    cQuery := oQueryMed:GetFixQuery()
    MpSysOpenQuery(cQuery, cAliasMed)

    aMedias[1] := (cAliasMed)->NAT_MEDCON
    aMedias[2] := (cAliasMed)->NAT_MEDPV

    (cAliasMed)->(DbCloseArea())

    //Depois busca a media geral desde o inicio do planejamento
    oQueryMed:SetString(3, DtoS(xDataIni) )
    oQueryMed:SetString(4, DtoS(MV_PAR01) )

    cQuery := oQueryMed:GetFixQuery()
    MpSysOpenQuery(cQuery, cAliasMed)

    aMedias[3] := (cAliasMed)->NAT_MEDCON
    aMedias[4] := (cAliasMed)->NAT_MEDPV

    (cAliasMed)->(DbCloseArea())

Return(aMedias)

/*/{Protheus.doc} AjustaSX1
@description Cria as perguntas da rotina
@author Jared Ribeiro
@since 	03/11/2024
/*/
Static Function AjustaSX1(cPerg)

    Local aRegs	    := {}
    Local i		    := 0
    Local aArea	    := GetArea()
    Local j		    := 0

    aAdd(aRegs,{cPerg,'01','Data Base?       '     ,'','','mv_ch1','D',8 ,0 ,0,'G',"" ,'mv_par01','','','','',"","","","","","","","","","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,'02','M�dia Retroativa (D-?)','','','mv_ch2','N',3 ,0 ,0,'G',"" ,'mv_par02','','','','',"","","","","","","","","","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,'03','Finalidade?      '     ,'','','mv_ch3','N',1 ,0 ,1,'C',"" ,'mv_par03','Cria'        ,'','','',"","Recria"     ,"","","","","Engorda"   ,"","","","","Reproducao","","","","","Todos","","","",""   ,"",""})

    dbSelectArea("SX1")
    SX1->(dbSetOrder(1))
    SX1->(DbGotop())

    For i:=1 to Len(aRegs)
        If !dbSeek( PadR(cPerg,10) + aRegs[i][2] )
            RecLock("SX1",.T.)
            For j := 1 to FCount()
                If j <= Len( aRegs[ i ] )
                    FieldPut( j, aRegs[ i, j ] )
                EndIf
            Next
            MsUnlock()		
        Endif
    Next

    RestArea(aArea)

Return

