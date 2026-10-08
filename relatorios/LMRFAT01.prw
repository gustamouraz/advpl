#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} LMRFAT01
Relatório de MDF-e de frota própria
@type  User Function
/*/
User Function LMRFAT01()

    Local oReport  := Nil
    Local oSection := Nil

    oReport := TReport():New( ;
        "LMRFAT01", ;
        "MDF-e Frota Própria", ;
        "", ;
        {|oRep| fImpMDFE(oRep)}, ;
        "Relatório de MDF-e autorizado ou encerrado, com NF-e vinculada." )

    oSection := TRSection():New(oReport, "MDF-e")

    oSection:Cell("FILIAL"   , "QRYMDFE", "Filial"         , "@!", 12)
    oSection:Cell("DATA"     , "QRYMDFE", "Data Emissão"   , "@D", 10)
    oSection:Cell("MDFE"     , "QRYMDFE", "MDF-e"          , "@!", 15)
    oSection:Cell("COLETA"   , "QRYMDFE", "Local Coleta"   , "@!", 35)
    oSection:Cell("DESCARGA" , "QRYMDFE", "Local Descarga" , "@!", 35)
    oSection:Cell("PESO"     , "QRYMDFE", "Peso"           , "@E 999,999,999.999", 16)
    oSection:Cell("PLACA"    , "QRYMDFE", "Placa Veículo"  , "@!", 12)

    oReport:PrintDialog()

Return


/*/{Protheus.doc} fImpMDFE
Monta e imprime os dados do relatório.
@type Static Function
/*/
Static Function fImpMDFE(oReport)

    Local aPergs    := {}
    Local aParam    := {}
    Local cDataIni  := ""
    Local cDataFim  := ""
    Local cAlias    := GetNextAlias()
    Local oSection  := oReport:Section(1)

    aAdd(aPergs, {1, "Data inicial", dDataBase(), "", ".T.", "", "", 80, .T.})
    aAdd(aPergs, {1, "Data final"  , dDataBase(), "", ".T.", "", "", 80, .T.})

    If !ParamBox(aPergs, "Parâmetros do relatório", @aParam)
        Return
    EndIf

    cDataIni := DToS(aParam[1])
    cDataFim := DToS(aParam[2])

    BeginSql Alias cAlias
        %NoParser%

        WITH MDFE AS
        (
            SELECT
                CC0.CC0_FILIAL,
                CC0.CC0_SERMDF,
                CC0.CC0_NUMMDF,
                CC0.CC0_DTEMIS,
                CC0.CC0_PESOB,
                CC0.CC0_VEICUL,
                CC0.CC0_STATUS,
                CONVERT(VARCHAR(MAX), CC0.CC0_XMLMDF) AS XML_TEXTO
            FROM %table:CC0% CC0
            WHERE CC0.D_E_L_E_T_ = ' '
              AND CC0.CC0_DTEMIS BETWEEN %exp:cDataIni% AND %exp:cDataFim%
              AND CC0.CC0_STATUS IN ('3', '6')
        )
        SELECT
            M.CC0_FILIAL AS FILIAL,
            CONVERT(CHAR(8), CONVERT(DATE, M.CC0_DTEMIS, 112), 112) AS DATA,
            M.CC0_SERMDF + '-' + M.CC0_NUMMDF AS MDFE,

            CASE
                WHEN P.POS_COLETA > 0
                 AND P.FIM_COLETA > P.POS_COLETA
                THEN SUBSTRING(
                    M.XML_TEXTO,
                    P.POS_COLETA + LEN('<xMunCarrega>'),
                    P.FIM_COLETA - (P.POS_COLETA + LEN('<xMunCarrega>'))
                )
            END AS COLETA,

            CASE
                WHEN P.POS_DESCARGA > 0
                 AND P.FIM_DESCARGA > P.POS_DESCARGA
                THEN SUBSTRING(
                    M.XML_TEXTO,
                    P.POS_DESCARGA + LEN('<xMunDescarga>'),
                    P.FIM_DESCARGA - (P.POS_DESCARGA + LEN('<xMunDescarga>'))
                )
            END AS DESCARGA,

            M.CC0_PESOB AS PESO,
            V.DA3_PLACA AS PLACA

        FROM MDFE M

        CROSS APPLY
        (
            SELECT TOP 1
                DA3.DA3_PLACA,
                DA3.DA3_FROVEI
            FROM %table:DA3% DA3
            WHERE DA3.D_E_L_E_T_ = ' '
              AND DA3.DA3_COD = M.CC0_VEICUL
            ORDER BY CASE
                WHEN DA3.DA3_FILIAL = M.CC0_FILIAL THEN 0
                ELSE 1
            END
        ) V

        CROSS APPLY
        (
            SELECT
                CHARINDEX('<xMunCarrega>', M.XML_TEXTO) AS POS_COLETA,
                CHARINDEX('</xMunCarrega>', M.XML_TEXTO) AS FIM_COLETA,
                CHARINDEX('<xMunDescarga>', M.XML_TEXTO) AS POS_DESCARGA,
                CHARINDEX('</xMunDescarga>', M.XML_TEXTO) AS FIM_DESCARGA
        ) P

        WHERE V.DA3_FROVEI = '1'
          AND M.XML_TEXTO LIKE '%<infNFe>%'
          AND M.XML_TEXTO NOT LIKE '%<infCTe>%'
          AND M.XML_TEXTO NOT LIKE '%<infMDFeTransp>%'

        ORDER BY
            M.CC0_DTEMIS DESC,
            M.CC0_SERMDF,
            M.CC0_NUMMDF
    EndSql

    dbSelectArea(cAlias)
    dbGoTop()

    oSection:Init()

    While !Eof()

        If oReport:Cancel()
            Exit
        EndIf

        oSection:PrintLine()
        dbSkip()
    EndDo

    oSection:Finish()
    (cAlias)->(dbCloseArea())

Return
