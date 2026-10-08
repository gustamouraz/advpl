#Include "TOTVS.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} RPMATI02
Relatorio de Ativos - Depreciacao Fiscal e Societaria.

@type  Function
@author Agropecuaria Masutti
@since  09/09/2026

SX1 requerido: grupo RPMATI02
    MV_PAR01 - Data de corte (tipo Data)
/*/
User Function RPMATI02()
    Local aArea   := GetArea()
    Local oReport := Nil

    Private cPerg    := "RPMATI02"
    Private cAlias   := GetNextAlias()
    Private dDtCorte := Ctod("")

    If ! Pergunte(PadR(cPerg, 10), .T.)
        MsgStop("Cadastre o grupo de perguntas " + cPerg + " no SX1.", "Ativos - Depreciacao")
        RestArea(aArea)
        Return
    EndIf

    dDtCorte := MV_PAR01
    If Empty(dDtCorte)
        MsgStop("Informe uma data de corte valida.", "Ativos - Depreciacao")
        RestArea(aArea)
        Return
    EndIf

    oReport := RptDef()
    oReport:PrintDialog()

    RestArea(aArea)
Return

/*/{Protheus.doc} RptDef
Monta a estrutura do TReports.
/*/
Static Function RptDef()
    Local oReport := Nil
    Local oSection := Nil

    oReport := TReport():New("RPMATI02", ;
        "Ativos - Depreciacao Fiscal e Societaria", ;
        cPerg, ;
        {|oRep| RptPrint(oRep)}, ;
        "Posicao dos bens disponiveis para venda, incluindo manutencao e depreciacoes fiscal e societaria.")

    oReport:SetTotalInLine(.F.)
    oReport:lParamPage := .F.
    oReport:oPage:SetPaperSize(9)
    oReport:SetLandscape()

    oSection := TRSection():New(oReport, "Ativos", {cAlias})
    oSection:SetTotalInLine(.F.)

    AddCells(oSection)
Return oReport

/*/{Protheus.doc} AddCells
Define as colunas disponibilizadas no TReports e nas exportacoes.
/*/
Static Function AddCells(oSection)
    TRCell():New(oSection, "FILIAL",          cAlias, "Filial",                  "@!",  6)
    TRCell():New(oSection, "TIPO_ATIVO",      cAlias, "Tipo Ativo",              "@!",  3)
    TRCell():New(oSection, "COD_BEM",         cAlias, "Cod. Bem",                "@!", 15)
    TRCell():New(oSection, "ITEM",            cAlias, "Item",                    "@!",  4)
    TRCell():New(oSection, "DESC_GRUPO",      cAlias, "Descricao Grupo",         "@!", 40)
    TRCell():New(oSection, "COD_GRUPO",       cAlias, "Cod. Grupo",              "@!", 10)
    TRCell():New(oSection, "QUANTIDADE",      cAlias, "Quantidade",              "@E 999,999,999.99", 14)
    TRCell():New(oSection, "DESCRICAO",       cAlias, "Descricao",               "@!", 50)
    TRCell():New(oSection, "DT_AQUISICAO",    cAlias, "Data Aquisicao",          "@!", 10)
    TRCell():New(oSection, "PATRIMONIO",      cAlias, "Patrimonio",              "@!", 20)
    TRCell():New(oSection, "ANO_MODELO",      cAlias, "Ano/Modelo",              "@!", 12)
    TRCell():New(oSection, "FORNECEDOR",      cAlias, "Fornecedor",              "@!", 50)
    TRCell():New(oSection, "COD_FORNEC",      cAlias, "Cod. Fornecedor",         "@!", 12)
    TRCell():New(oSection, "LOJA_FORNEC",     cAlias, "Loja Fornecedor",         "@!",  6)
    TRCell():New(oSection, "NOTA_FISCAL",     cAlias, "Nota Fiscal",             "@!", 12)
    TRCell():New(oSection, "CHASSI_SERIE",    cAlias, "Chassi/Serie",            "@!", 30)
    TRCell():New(oSection, "PLACA",           cAlias, "Placa",                   "@!", 10)
    TRCell():New(oSection, "FROTA",           cAlias, "Frota",                   "@!", 15)
    TRCell():New(oSection, "COD_DISP",        cAlias, "Cod. Disponibilidade",    "@!",  5)
    TRCell():New(oSection, "DISPONIB",        cAlias, "Disponibilidade",         "@!", 20)
    TRCell():New(oSection, "COD_BEM_MNT",     cAlias, "Cod. Bem Manutencao",     "@!", 15)
    TRCell():New(oSection, "COD_IMOB_MNT",    cAlias, "Cod. Imobilizado Mnt.",   "@!", 20)
    TRCell():New(oSection, "HOR_ATUAL",       cAlias, "Horimetro/KM Atual",      "@E 999,999,999.99", 16)
    TRCell():New(oSection, "HOR_ACUM",        cAlias, "Horimetro/KM Acumulado",  "@E 999,999,999.99", 16)
    TRCell():New(oSection, "GASTO_MNT_ATU",   cAlias, "Gasto Manut. Atual",      "@E 999,999,999,999.99", 18)
    TRCell():New(oSection, "GASTO_MNT_HIS",   cAlias, "Gasto Manut. Historico",  "@E 999,999,999,999.99", 18)
    TRCell():New(oSection, "GASTO_MNT_ACU",   cAlias, "Gasto Acum. Manut.",      "@E 999,999,999,999.99", 18)
    TRCell():New(oSection, "QTD_LANC_MNT",    cAlias, "Qtd. Lanc. Manut.",       "@E 999,999,999", 12)
    TRCell():New(oSection, "MARCA",           cAlias, "Marca",                   "@!", 20)
    TRCell():New(oSection, "COD_PRODUTO",     cAlias, "Cod. Produto",            "@!", 15)
    TRCell():New(oSection, "STATUS_BEM",      cAlias, "Status Bem",              "@!",  5)
    TRCell():New(oSection, "POTENCIA",        cAlias, "Potencia",                "@!", 15)
    TRCell():New(oSection, "CTA_AQUIS",       cAlias, "Conta Aquisicao",         "@!", 20)
    TRCell():New(oSection, "CTA_DEPR_ACU",    cAlias, "Conta Depr. Acumulada",   "@!", 20)
    TRCell():New(oSection, "CTA_DESP_DEPR",   cAlias, "Conta Desp. Depr.",       "@!", 20)
    TRCell():New(oSection, "VALOR_BEM",       cAlias, "Valor do Bem",            "@E 999,999,999,999.99", 18)
    TRCell():New(oSection, "VALOR_RESID",     cAlias, "Valor Residual",          "@E 999,999,999,999.99", 18)
    TRCell():New(oSection, "VALOR_AVAL",      cAlias, "Valor Avaliacao",         "@E 999,999,999,999.99", 18)
    TRCell():New(oSection, "DEPR_FISCAL",     cAlias, "Depr. Acum. Fiscal",      "@E 999,999,999,999.99", 18)
    TRCell():New(oSection, "DEPR_SOC",        cAlias, "Depr. Acum. Societaria",  "@E 999,999,999,999.99", 18)
    TRCell():New(oSection, "CENTRO_CUSTO",    cAlias, "Centro de Custo",         "@!", 15)
    TRCell():New(oSection, "TAXA_DEPR",       cAlias, "Taxa Depreciacao",        "@E 999.99", 10)
    TRCell():New(oSection, "INCENTIVADA",     cAlias, "Incentivada",             "@!",  3)
    TRCell():New(oSection, "CONSIDERA_BI",    cAlias, "Considera BI",            "@!",  3)
    TRCell():New(oSection, "INVENTARIO",      cAlias, "Inventario",              "@!",  3)
    TRCell():New(oSection, "UNIDADE_ATUAL",   cAlias, "Unidade Atual",           "@!", 10)
    TRCell():New(oSection, "DT_ULT_ALTER",    cAlias, "Data Ult. Alteracao",     "@!", 10)
    TRCell():New(oSection, "NF_MOVIMENTO",    cAlias, "NF Movimento",            "@!", 12)
    TRCell():New(oSection, "USUARIO",         cAlias, "Usuario",                 "@!", 20)
    TRCell():New(oSection, "RENAVAM",         cAlias, "Renavam",                 "@!", 15)
    TRCell():New(oSection, "OBSERVACAO",      cAlias, "Observacao",              "@!", 60)
    TRCell():New(oSection, "COMPLEXO",        cAlias, "Complexo",                "@!", 10)
    TRCell():New(oSection, "GRUPO_MACRO",     cAlias, "Grupo Macro",             "@!", 20)
    TRCell():New(oSection, "NEGOCIOS",        cAlias, "Negocios",                "@!", 20)
    TRCell():New(oSection, "AREA_IMOVEL",     cAlias, "Area Imovel",             "@!", 15)
    TRCell():New(oSection, "INTEGRA_PIMS",    cAlias, "Integra PIMS",            "@!",  3)
Return

/*/{Protheus.doc} RptPrint
Executa a consulta e imprime a secao de dados.
/*/
Static Function RptPrint(oReport)
    Local aArea    := GetArea()
    Local oSection := oReport:Section(1)
    Local nTotal   := 0
    Local nAtual   := 0

    BeginSql Alias cAlias
        %noParser%
        SELECT
            N1.N1_FILIAL AS FILIAL,
            N3.N3_TIPO AS TIPO_ATIVO,
            N1.N1_CBASE AS COD_BEM,
            N1.N1_ITEM AS ITEM,
            NG.NG_DESCRIC AS DESC_GRUPO,
            N1.N1_GRUPO AS COD_GRUPO,
            N1.N1_QUANTD AS QUANTIDADE,
            N1.N1_DESCRIC AS DESCRICAO,
            N1.N1_AQUISIC AS DT_AQUISICAO,
            N1.N1_CHAPA AS PATRIMONIO,
            N1.N1_XANOMOD AS ANO_MODELO,
            A2.A2_NOME AS FORNECEDOR,
            N1.N1_FORNEC AS COD_FORNEC,
            N1.N1_LOJA AS LOJA_FORNEC,
            N1.N1_NFISCAL AS NOTA_FISCAL,
            N1.N1_CHASSIS AS CHASSI_SERIE,
            N1.N1_PLACA AS PLACA,
            N1.N1_XFROTA AS FROTA,
            N1.N1_XSTS AS COD_DISP,
            CASE N1.N1_XSTS WHEN '1' THEN 'Em Uso' WHEN '2' THEN 'Disponivel Venda' ELSE '' END AS DISPONIB,
            T9.T9_CODBEM AS COD_BEM_MNT,
            T9.T9_CODIMOB AS COD_IMOB_MNT,
            ISNULL(T9.T9_POSCONT, 0) AS HOR_ATUAL,
            ISNULL(T9.T9_CONTACU, 0) AS HOR_ACUM,
            CAST(ISNULL(CUSTO_MNT.VLR_STL, 0) AS DECIMAL(18,2)) AS GASTO_MNT_ATU,
            CAST(ISNULL(CUSTO_MNT.VLR_STT, 0) AS DECIMAL(18,2)) AS GASTO_MNT_HIS,
            CAST(ISNULL(CUSTO_MNT.VLR_MANUTENCAO, 0) AS DECIMAL(18,2)) AS GASTO_MNT_ACU,
            ISNULL(CUSTO_MNT.QTD_LANCAMENTOS, 0) AS QTD_LANC_MNT,
            N1.N1_XMARCA AS MARCA,
            N1.N1_PRODUTO AS COD_PRODUTO,
            N1.N1_STATUS AS STATUS_BEM,
            N1.N1_XPOTATI AS POTENCIA,
            N3.N3_CCONTAB AS CTA_AQUIS,
            N3.N3_CCDEPR AS CTA_DEPR_ACU,
            N3.N3_CDEPREC AS CTA_DESP_DEPR,
            CAST(ISNULL(N3.N3_VORIG1, 0) AS DECIMAL(18,2)) AS VALOR_BEM,
            CAST(ISNULL(N3.N3_VORIG1, 0) - ISNULL(DEPR_SOC.VLR_DEPR_ACUM_SOC, 0) AS DECIMAL(18,2)) AS VALOR_RESID,
            CAST(ISNULL(N1.N1_VLRAVA, 0) AS DECIMAL(18,2)) AS VALOR_AVAL,
            CAST(ISNULL(N3.N3_VRDACM1, 0) AS DECIMAL(18,2)) AS DEPR_FISCAL,
            CAST(ISNULL(DEPR_SOC.VLR_DEPR_ACUM_SOC, 0) AS DECIMAL(18,2)) AS DEPR_SOC,
            N3.N3_CUSTBEM AS CENTRO_CUSTO,
            N3.N3_TXDEPR1 AS TAXA_DEPR,
            N1.N1_ZINCENT AS INCENTIVADA,
            N1.N1_XCONSBI AS CONSIDERA_BI,
            N1.N1_XINVENT AS INVENTARIO,
            N1.N1_UNIDATU AS UNIDADE_ATUAL,
            N1.N1_XDTINV AS DT_ULT_ALTER,
            N1.N1_XNFMOV AS NF_MOVIMENTO,
            N1.N1_USUARIO AS USUARIO,
            N1.N1_XRENAV AS RENAVAM,
            N1.N1_XOBS AS OBSERVACAO,
            N1.N1_UNIDATU AS COMPLEXO,
            CASE N1.N1_XGPM WHEN 1 THEN 'Imoveis Rurais' WHEN 2 THEN 'Bens Imoveis' WHEN 3 THEN 'Bens Moveis' ELSE '' END AS GRUPO_MACRO,
            CASE N1.N1_XNG WHEN 1 THEN 'Agricola' WHEN 2 THEN 'Agroindustria' WHEN 3 THEN 'Log Fluvial' WHEN 4 THEN 'Log Rodoviaria' WHEN 5 THEN 'Matriz' WHEN 6 THEN 'Oper Portuarias' WHEN 7 THEN 'Pecuaria' WHEN 8 THEN 'Sso' WHEN 9 THEN 'Diretoria' ELSE '' END AS NEGOCIOS,
            N1.N1_AREAIMO AS AREA_IMOVEL,
            N3.N3_INTP AS INTEGRA_PIMS
        FROM %table:SN1% N1 WITH (NOLOCK)
        INNER JOIN %table:SN3% N3 WITH (NOLOCK) ON N1.N1_CBASE = N3.N3_CBASE AND N1.N1_FILIAL = N3.N3_FILIAL AND N1.N1_ITEM = N3.N3_ITEM AND N3.D_E_L_E_T_ = ''
        INNER JOIN %table:SA2% A2 WITH (NOLOCK) ON N1.N1_FORNEC = A2.A2_COD AND N1.N1_LOJA = A2.A2_LOJA AND A2.D_E_L_E_T_ = ''
        INNER JOIN %table:SNG% NG WITH (NOLOCK) ON NG.NG_GRUPO = N1.N1_GRUPO AND NG.D_E_L_E_T_ = ''
        OUTER APPLY (
            SELECT TOP 1 S9.T9_FILIAL, S9.T9_CODBEM, S9.T9_CODIMOB, S9.T9_POSCONT, S9.T9_CONTACU
            FROM %table:ST9% S9 WITH (NOLOCK)
            WHERE S9.D_E_L_E_T_ = ''
              AND RTRIM(LTRIM(S9.T9_CODIMOB)) = RTRIM(LTRIM(N1.N1_CBASE)) + RTRIM(LTRIM(N1.N1_ITEM))
            ORDER BY CASE WHEN S9.T9_FILIAL = N1.N1_FILIAL THEN 1 WHEN LTRIM(RTRIM(S9.T9_FILIAL)) = '' THEN 2 ELSE 3 END
        ) T9
        OUTER APPLY (
            SELECT SUM(X.CUSTO) AS VLR_MANUTENCAO,
                   SUM(CASE WHEN X.ORIGEM = 'STL' THEN X.CUSTO ELSE 0 END) AS VLR_STL,
                   SUM(CASE WHEN X.ORIGEM = 'STT' THEN X.CUSTO ELSE 0 END) AS VLR_STT,
                   COUNT(*) AS QTD_LANCAMENTOS
            FROM (
                SELECT 'STL' AS ORIGEM, CAST(ISNULL(TL.TL_CUSTO, 0) AS DECIMAL(18,2)) AS CUSTO
                FROM %table:STL% TL WITH (NOLOCK)
                WHERE TL.D_E_L_E_T_ = '' AND RTRIM(LTRIM(TL.TL_CODBEM)) = RTRIM(LTRIM(T9.T9_CODBEM))
                  AND LTRIM(RTRIM(TL.TL_SEQRELA)) NOT IN ('', '0')
                UNION ALL
                SELECT 'STT' AS ORIGEM, CAST(ISNULL(TT.TT_CUSTO, 0) AS DECIMAL(18,2)) AS CUSTO
                FROM %table:STT% TT WITH (NOLOCK)
                WHERE TT.D_E_L_E_T_ = '' AND RTRIM(LTRIM(TT.TT_CODBEM)) = RTRIM(LTRIM(T9.T9_CODBEM))
                  AND LTRIM(RTRIM(TT.TT_SEQRELA)) NOT IN ('', '0')
            ) X
        ) CUSTO_MNT
        OUTER APPLY (
            SELECT SUM(ISNULL(NS.N3_VRDACM1, 0)) AS VLR_DEPR_ACUM_SOC
            FROM %table:SN3% NS WITH (NOLOCK)
            WHERE NS.D_E_L_E_T_ = '' AND NS.N3_FILIAL = N1.N1_FILIAL AND NS.N3_CBASE = N1.N1_CBASE
              AND NS.N3_ITEM = N1.N1_ITEM AND NS.N3_TIPO IN ('10', '12')
        ) DEPR_SOC
        WHERE N1.N1_BAIXA = ''
          AND N1.N1_AQUISIC BETWEEN '19000101' AND %exp:DTOS(dDtCorte)%
          AND N1.N1_STATUS = '1'
          AND N3.N3_TIPO = '01'
          AND N1.N1_XSTS = '2'
          AND N1.D_E_L_E_T_ = ''
        ORDER BY N1.N1_FILIAL, N1.N1_CBASE, N1.N1_ITEM
    EndSql

    (cAlias)->(DbGoTop())
    Count To nTotal
    (cAlias)->(DbGoTop())

    oReport:SetMeter(nTotal)
    oSection:Init()

    While ! (cAlias)->(Eof())
        nAtual++
        oReport:SetMsgPrint("Imprimindo registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
        oReport:IncMeter()
        oSection:PrintLine()
        (cAlias)->(DbSkip())
    EndDo

    oSection:Finish()
    (cAlias)->(DbCloseArea())
    RestArea(aArea)
Return
