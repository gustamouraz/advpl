#include "REPORT.CH"
#include "PROTHEUS.CH"    
#include "TOPCONN.CH"    
#Include 'FWMVCDef.ch'

/*/{Protheus.doc}
    @description busca a variação cambial apenas em moeda 1 para o calculo do valor em moeda local, para os titulos que estão com diferença entre valor do faturamento e valor do pagamento, para os casos de importação.
    @localization: Function LMLP001() - Responsável por buscar a variação cambial para o calculo do valor em moeda local.
    @point: A função realiza uma consulta SQL para buscar os dados necessários e retorna um array com a diferença
    @example: LMLP001(SE5->E5_FILIAL,SE5->E5_NUMERO,SE5->E5_PARCELA,SE5->E5_TIPO,SE5->E5_FORNECE,SE5->E5_LOJA)
    @author Luiz Moura
    @since 20/06/2022
    @type class
/*/

User Function LMLP001(cFil, cTit, cParc, cTipo, cForn, cLoja)

    Local cLMLP001 := GetNextAlias()
    Local aRet     := {}

    BeginSql Alias cLMLP001
        %noparser%
        SELECT TOP 1
            V.E5_FILIAL AS [FILIAL],
            V.E5_NUMERO AS [TITULO],
            V.E5_PARCELA AS [PARCELA],
            V.E5_TIPO AS [TIPO],
            V.E5_CLIFOR AS [FORNECEDOR],
            V.E5_LOJA AS [LOJA],
            V.E5_BENEF AS [DESC_FORNECEDOR],
            V.E5_DTDISPO AS [DT_CMP],
            ROUND(V.VL2_CP_FT,2) AS [VAL_M2_COMP_FAT],
            ROUND(V.VL2_DC_FT,2) AS [VAL_M2_DC_FAT],
            ROUND(V.VL2_NF,2) AS [VAL_M2_NF],
            ROUND(V.VL2_PA,2) AS [VAL_M2_PA],
            ROUND(V.VL2_NF + V.VL2_DC_FT + V.VL2_PA,2) AS [DIFERENCA_M2],
            ROUND(V.VL_CP_FT,2) AS [VAL_M1_COMP_FAT],
            ROUND(V.VLCRUZ_DC_FT,2) AS [VAL_M1_DC_FAT],
            ROUND(V.VL_NF,2) AS [VAL_M1_NF],
            ROUND(V.VL_PA,2) AS [VAL_M1_PA],
            ROUND(V.VL_NF + V.VLCRUZ_DC_FT + V.VL_PA,2) AS [DIFERENCA_M1],
            CASE
            WHEN SA20.A2_EST = 'EX' THEN 'EXT'
            ELSE 'NAC'
            END AS [EXT_NAC],
            V.E5_IDORIG
        FROM (
            SELECT
            Y.*,
            SUM(
                CASE
                WHEN SE52.E5_RECPAG = 'P' THEN -SE52.E5_VALOR
                ELSE SE52.E5_VALOR
                END) AS [VL2_PA],
            SUM(
                CASE
                WHEN SE52.E5_RECPAG = 'P' THEN -SE52.E5_VLMOED2
                ELSE SE52.E5_VLMOED2
                END) AS [VL_PA]
            FROM (
                SELECT
                    X.*,
                    SUM(SE20.E2_VALOR) AS [VL2_NF],
                    SUM(SE20.E2_VLCRUZ) AS [VL_NF]
                FROM (
                    SELECT
                        Z.*,
                        SUM(
                            CASE
                            WHEN SE51.E5_RECPAG = 'P' THEN COALESCE(-SE51.E5_VLMOED2,0)
                            ELSE COALESCE(SE51.E5_VLMOED2,0)
                            END) AS [VL2_DC_FT],
                        SUM(
                            CASE
                            WHEN SE51.E5_RECPAG = 'P' THEN COALESCE(-SE51.E5_VALOR,0)
                            ELSE COALESCE(SE51.E5_VALOR,0)
                            END) AS [VLCRUZ_DC_FT]
                    FROM (
                        SELECT
                            SE50.E5_FILIAL,
                            SE50.E5_NUMERO,
                            SE50.E5_PARCELA,
                            SE50.E5_TIPO,
                            SE50.E5_TIPODOC,
                            SE50.E5_MOTBX,
                            SE50.E5_CLIFOR,
                            SE50.E5_LOJA,
                            SE50.E5_BENEF,
                            SE50.E5_IDORIG,
                            SE50.E5_DTDISPO,
                            SUM(
                                CASE
                                WHEN SE50.E5_RECPAG = 'P' THEN -SE50.E5_VALOR
                                ELSE SE50.E5_VALOR
                                END) AS [VL2_CP_FT],
                            SUM(
                                CASE
                                WHEN SE50.E5_RECPAG = 'P' THEN -SE50.E5_VLMOED2
                                ELSE SE50.E5_VLMOED2
                                END) AS [VL_CP_FT]
                        FROM SE5010 SE50 WITH(NOLOCK)
                        WHERE SE50.E5_TIPO = 'FT'
                            AND SE50.E5_FILIAL = %exp:cFil%
                            AND SE50.E5_NUMERO = %exp:cTit%
                            AND SE50.E5_PARCELA = %exp:cParc%
                            AND SE50.E5_TIPO = %exp:cTipo%
                            AND SE50.E5_FORNECE = %exp:cForn%
                            AND SE50.E5_LOJA = %exp:cLoja%
                            AND SE50.E5_TXMOEDA <> 1 AND SE50.E5_TXMOEDA <> 0
                            AND SE50.E5_FORNECE <> ''
                            AND SE50.E5_TIPODOC IN ('CP','ES')
                            AND SE50.D_E_L_E_T_ = ''
                        GROUP BY
                            SE50.E5_FILIAL,
                            SE50.E5_NUMERO,
                            SE50.E5_PARCELA,
                            SE50.E5_TIPO,
                            SE50.E5_TIPODOC,
                            SE50.E5_MOTBX,
                            SE50.E5_CLIFOR,
                            SE50.E5_LOJA,
                            SE50.E5_BENEF,
                            SE50.E5_IDORIG,
                            SE50.E5_DTDISPO
                    ) AS Z
                        LEFT JOIN SE5010 SE51 WITH(NOLOCK)
                        ON Z.E5_NUMERO = SE51.E5_NUMERO AND Z.E5_CLIFOR = SE51.E5_FORNECE AND Z.E5_LOJA = SE51.E5_LOJA AND Z.E5_PARCELA = SE51.E5_PARCELA
                            AND Z.E5_TIPO = SE51.E5_TIPO AND SE51.D_E_L_E_T_ = '' AND SE51.E5_TIPODOC = 'DC' AND Z.E5_FILIAL = SE51.E5_FILIAL
                    WHERE Z.VL2_CP_FT <> 0
                        AND Z.VL_CP_FT <> 0
                    GROUP BY
                        Z.E5_FILIAL,
                        Z.E5_NUMERO,
                        Z.E5_PARCELA,
                        Z.E5_TIPO,
                        Z.E5_TIPODOC,
                        Z.E5_MOTBX,
                        Z.E5_CLIFOR,
                        Z.E5_LOJA,
                        Z.E5_BENEF,
                        Z.E5_IDORIG,
                        Z.E5_DTDISPO,
                        Z.VL2_CP_FT,
                        Z.VL_CP_FT
                ) AS X
                    LEFT JOIN SE2010 SE20 WITH(NOLOCK)
                    ON SE20.E2_FATURA = X.E5_NUMERO AND SE20.E2_FORNECE = X.E5_CLIFOR AND SE20.D_E_L_E_T_ = '' AND SE20.E2_FILIAL = X.E5_FILIAL
                GROUP BY
                    X.E5_FILIAL,
                    X.E5_NUMERO,
                    X.E5_PARCELA,
                    X.E5_TIPO,
                    X.E5_TIPODOC,
                    X.E5_MOTBX,
                    X.VL_CP_FT,
                    X.VL2_CP_FT,
                    X.E5_CLIFOR,
                    X.E5_LOJA,
                    X.E5_BENEF,
                    X.VL2_DC_FT,
                    X.E5_IDORIG,
                    X.E5_DTDISPO,
                    X.VLCRUZ_DC_FT
            ) AS Y
            LEFT JOIN FK2010 FK20 WITH(NOLOCK)
            ON FK20.FK2_IDFK2 = Y.E5_IDORIG AND FK20.D_E_L_E_T_ = ''
                LEFT JOIN FK2010 FK21 WITH(NOLOCK)
                ON FK21.FK2_IDDOC = FK20.FK2_IDCOMP AND FK21.D_E_L_E_T_ = ''
                    LEFT JOIN SE5010 SE52 WITH(NOLOCK)
                    ON SE52.E5_IDORIG = FK21.FK2_IDFK2 AND SE52.D_E_L_E_T_ = '' AND SE52.E5_TIPO <> ''
            WHERE SE52.E5_MOTBX = 'CMP'
            GROUP BY
                Y.E5_FILIAL,
                Y.E5_NUMERO,
                Y.E5_PARCELA,
                Y.E5_TIPO,
                Y.E5_TIPODOC,
                Y.E5_MOTBX,
                Y.VL_CP_FT,
                Y.VL2_CP_FT,
                Y.E5_CLIFOR,
                Y.E5_LOJA,
                Y.E5_BENEF,
                Y.VL2_DC_FT,
                Y.E5_IDORIG,
                Y.E5_DTDISPO,
                Y.VLCRUZ_DC_FT,
                Y.VL2_NF,
                Y.VL_NF
        ) AS V
        LEFT JOIN SA2010 SA20 WITH(NOLOCK)
        ON SA20.A2_COD = V.E5_CLIFOR AND SA20.A2_LOJA = V.E5_LOJA AND SA20.D_E_L_E_T_ = ''
        WHERE ROUND(ISNULL(V.VL2_NF,0) + ISNULL(V.VL2_DC_FT,0) + ISNULL(V.VL2_PA,0),2) = 0
        AND ROUND(ISNULL(V.VL_NF,0) + ISNULL(V.VLCRUZ_DC_FT,0) + ISNULL(V.VL_PA,0),2) <> 0
 

    EndSql

    If Select(cLMLP001) > 0
        (cLMLP001)->(DbGoTop())

        While (cLMLP001)->(!Eof())
            aAdd(aRet,{(cLMLP001)->DIFERENCA_M1, (cLMLP001)->EXT_NAC})
            (cLMLP001)->(DbSkip())
        EndDo

        (cLMLP001)->(DbCloseArea())
    EndIf

Return aRet
