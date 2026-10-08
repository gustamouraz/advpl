#Include "Protheus.ch"
#Include "Totvs.ch"
#Include "TopConn.ch"

/*
    Recalcula o saldo conciliado bancario usando:
    - saldo anterior em SE8010.E8_SALRECO
    - movimentos do dia em FK5010

    A rotina abre uma janela para informar data, banco, agencia e conta,
    exibe a conferencia e somente grava apos aprovacao do usuario.
*/
User Function ZSALDBCO()
    Local aArea         := GetArea()
    Local aParamBox     := {}
    Local aRet          := {}
    Local dSaldo        := Date()
    Local cBanco        := Space(TamSx3("A6_COD")[1])
    Local cAgencia      := Space(TamSx3("A6_AGENCIA")[1])
    Local cConta        := Space(TamSx3("A6_NUMCON")[1])
    Local cAliasSaldo   := GetNextAlias()
    Local cAliasMov     := GetNextAlias()
    Local cQuerySaldo   := ""
    Local cQueryMov     := ""
    Local cWhereSE8     := ""
    Local cWhereFK5     := ""
    Local dDataAnterior := STOD("")
    Local nSaldoAnt     := 0
    Local nSaldoAtual   := 0
    Local nSaldoNovo    := 0
    Local nEntradas     := 0
    Local nSaidas       := 0
    Local nQtdSaldoDia  := 0
    Local nQtdMov       := 0
    Local cResumo       := ""
    Local cUpdate       := ""
    Local cDataAnt      := ""

    aAdd(aParamBox, {1, "Data do saldo", dSaldo,   "", "", "", 80, .T.})
    aAdd(aParamBox, {1, "Banco",         cBanco,   "", "", "", 80, .T.})
    aAdd(aParamBox, {1, "Agencia",       cAgencia, "", "", "", 80, .T.})
    aAdd(aParamBox, {1, "Conta",         cConta,   "", "", "", 80, .T.})

    If !ParamBox(aParamBox, "Recalculo do saldo bancario", @aRet)
        RestArea(aArea)
        Return .F.
    EndIf

    dSaldo   := ZSBToDate(aRet[1])
    cBanco   := AllTrim(aRet[2])
    cAgencia := AllTrim(aRet[3])
    cConta   := AllTrim(aRet[4])

    If Empty(dSaldo)
        Help("", 1, "ZSBDATA",, "Informe a data em formato valido.", 1, 0)
        RestArea(aArea)
        Return .F.
    EndIf

    If Empty(cBanco) .Or. Empty(cAgencia) .Or. Empty(cConta)
        Help("", 1, "ZSBPARAM",, "Informe banco, agencia e conta para recalcular o saldo bancario.", 1, 0)
        RestArea(aArea)
        Return .F.
    EndIf

    If !ZSBValConta(cBanco, cAgencia, cConta)
        Help("", 1, "ZSBCONTA",, "Conta bancaria nao localizada no cadastro SA6. Revise banco, agencia e conta informados.", 1, 0)
        RestArea(aArea)
        Return .F.
    EndIf

    cWhereSE8 := " AND E8_BANCO = " + ZSBQuote(cBanco)
    cWhereSE8 := cWhereSE8 + " AND E8_AGENCIA = " + ZSBQuote(cAgencia)
    cWhereSE8 := cWhereSE8 + " AND E8_CONTA = " + ZSBQuote(cConta)

    cWhereFK5 := " AND FK5_BANCO = " + ZSBQuote(cBanco)
    cWhereFK5 := cWhereFK5 + " AND FK5_AGENCI = " + ZSBQuote(cAgencia)
    cWhereFK5 := cWhereFK5 + " AND FK5_CONTA = " + ZSBQuote(cConta)

    cQuerySaldo := " SELECT MAX(E8_DTSALAT) AS DATA_ANT, " + ;
                   "        COALESCE(MAX(CASE WHEN E8_DTSALAT < " + ZSBDateSql(dSaldo) + " THEN E8_SALRECO END), 0) AS SALDO_ANT, " + ;
                   "        SUM(CASE WHEN E8_DTSALAT = " + ZSBDateSql(dSaldo) + " THEN 1 ELSE 0 END) AS QTD_DIA, " + ;
                   "        COALESCE(MAX(CASE WHEN E8_DTSALAT = " + ZSBDateSql(dSaldo) + " THEN E8_SALRECO END), 0) AS SALDO_DIA " + ;
                   "   FROM SE8010 " + ;
                   "  WHERE D_E_L_E_T_ = '' " + cWhereSE8 + ;
                   "    AND E8_DTSALAT <= " + ZSBDateSql(dSaldo)

    dbUseArea(.T., "TOPCONN", TcGenQry(,, ChangeQuery(cQuerySaldo)), cAliasSaldo, .T., .T.)

    If !(cAliasSaldo)->(Eof())
        cDataAnt := AllTrim((cAliasSaldo)->DATA_ANT)
        If !Empty(cDataAnt)
            dDataAnterior := STOD(cDataAnt)
        EndIf

        nSaldoAnt    := Val(AllTrim((cAliasSaldo)->SALDO_ANT))
        nQtdSaldoDia := Val(AllTrim((cAliasSaldo)->QTD_DIA))
        nSaldoAtual  := Val(AllTrim((cAliasSaldo)->SALDO_DIA))
    EndIf

    (cAliasSaldo)->(DbCloseArea())

    If nQtdSaldoDia == 0
        Help("", 1, "ZSBNREG",, "Nao existe registro de saldo em SE8010 para a data informada.", 1, 0)
        RestArea(aArea)
        Return .F.
    EndIf

    If nQtdSaldoDia > 1
        Help("", 1, "ZSBMULT",, "Existe mais de um saldo em SE8010 para a data informada. Ajuste o filtro antes de atualizar.", 1, 0)
        RestArea(aArea)
        Return .F.
    EndIf

    cQueryMov := " SELECT COUNT(1) AS QTDMOV, " + ;
                 "        COALESCE(SUM(CASE WHEN FK5_RECPAG = 'R' THEN FK5_VALOR ELSE 0 END), 0) AS ENTRADAS, " + ;
                 "        COALESCE(SUM(CASE WHEN FK5_RECPAG = 'P' THEN FK5_VALOR ELSE 0 END), 0) AS SAIDAS " + ;
                 "   FROM FK5010 " + ;
                 "  WHERE D_E_L_E_T_ = '' " + cWhereFK5 + ;
                 "    AND FK5_DATA = " + ZSBDateSql(dSaldo)

    dbUseArea(.T., "TOPCONN", TcGenQry(,, ChangeQuery(cQueryMov)), cAliasMov, .T., .T.)

    If !(cAliasMov)->(Eof())
        nQtdMov   := Val(AllTrim((cAliasMov)->QTDMOV))
        nEntradas := Val(AllTrim((cAliasMov)->ENTRADAS))
        nSaidas   := Val(AllTrim((cAliasMov)->SAIDAS))
    EndIf

    (cAliasMov)->(DbCloseArea())

    nSaldoNovo := nSaldoAnt + nEntradas - nSaidas

    cResumo := "Conferencia do saldo bancario" + CRLF + CRLF
    cResumo := cResumo + "Tabela saldo.: SE8010" + CRLF
    cResumo := cResumo + "Tabela movto.: FK5010" + CRLF
    cResumo := cResumo + "Banco........: " + cBanco + CRLF
    cResumo := cResumo + "Agencia......: " + cAgencia + CRLF
    cResumo := cResumo + "Conta........: " + cConta + CRLF
    cResumo := cResumo + "Data.........: " + Dtoc(dSaldo) + CRLF

    If Empty(dDataAnterior)
        cResumo := cResumo + "Data anterior: <nao localizada>" + CRLF
    Else
        cResumo := cResumo + "Data anterior: " + Dtoc(dDataAnterior) + CRLF
    EndIf

    cResumo := cResumo + "Saldo ant....: " + Transform(nSaldoAnt, "@E 999,999,999,999.99") + CRLF
    cResumo := cResumo + "Entradas.....: " + Transform(nEntradas, "@E 999,999,999,999.99") + CRLF
    cResumo := cResumo + "Saidas.......: " + Transform(nSaidas, "@E 999,999,999,999.99") + CRLF
    cResumo := cResumo + "Saldo gravado: " + Transform(nSaldoAtual, "@E 999,999,999,999.99") + CRLF
    cResumo := cResumo + "Saldo calcul.: " + Transform(nSaldoNovo, "@E 999,999,999,999.99") + CRLF
    cResumo := cResumo + "Diferenca....: " + Transform(nSaldoNovo - nSaldoAtual, "@E 999,999,999,999.99") + CRLF
    cResumo := cResumo + "Movimentos...: " + AllTrim(Str(nQtdMov)) + CRLF + CRLF
    cResumo := cResumo + "Confirma a gravacao do novo saldo?"

    If !MsgYesNo(cResumo, "Atualizacao saldo bancario")
        MsgInfo("Processamento cancelado pelo usuario.", "Saldo bancario")
        RestArea(aArea)
        Return .F.
    EndIf

    cUpdate := " UPDATE SE8010 SET E8_SALRECO = " + ZSBNumSql(nSaldoNovo, 2) + ;
               " WHERE D_E_L_E_T_ = '' " + cWhereSE8 + ;
               "   AND E8_DTSALAT = " + ZSBDateSql(dSaldo)

    If TCSqlExec(ChangeQuery(cUpdate)) < 0
        ShowLog("Falha ao atualizar o saldo em SE8010." + CRLF + CRLF + TCSQLError(), "Erro")
        RestArea(aArea)
        Return .F.
    EndIf

    MsgInfo("Saldo atualizado com sucesso para " + Dtoc(dSaldo) + ".", "Saldo bancario")

    RestArea(aArea)
Return .T.

Static Function ZSBValConta(cBanco, cAgencia, cConta)
    Local aArea := GetArea()
    Local lRet  := .F.
    Local cChv  := xFilial("SA6") + PadR(AllTrim(cBanco), TamSx3("A6_COD")[1]) + ;
                   PadR(AllTrim(cAgencia), TamSx3("A6_AGENCIA")[1]) + ;
                   PadR(AllTrim(cConta), TamSx3("A6_NUMCON")[1])

    dbSelectArea("SA6")
    SA6->(dbSetOrder(1))

    If SA6->(dbSeek(cChv)) .And. SA6->D_E_L_E_T_ == ""
        lRet := .T.
    EndIf

    RestArea(aArea)
Return lRet

Static Function ZSBToDate(uData)
    Local dRet := STOD("")
    Local cDat := ""

    Do Case
    Case ValType(uData) == "D"
        dRet := uData
    Case ValType(uData) == "C"
        cDat := AllTrim(uData)
        If Len(cDat) == 8
            dRet := STOD(cDat)
        EndIf
    EndCase

Return dRet

Static Function ZSBQuote(cValor)
Return "'" + StrTran(AllTrim(cValor), "'", "''") + "'"

Static Function ZSBDateSql(dData)
Return ZSBQuote(DToS(ZSBToDate(dData)))

Static Function ZSBNumSql(nValor, nDec)
    Local cValor := ""

    Default nDec := 2

    cValor := AllTrim(Str(nValor, 18, nDec))
    cValor := StrTran(cValor, ",", ".")
Return cValor
