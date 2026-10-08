#Include "Protheus.ch"
#Include "TopConn.ch"

/*
    Hooks do conciliador financeiro.
    - F475PGRV: recalcula o saldo da data do movimento conciliado.
    - F475PCAN: recalcula o saldo ao cancelar a conciliacao.

    Regra aplicada:
    saldo do dia = saldo anterior + entradas do dia - saidas do dia

    Gravacao:
    - SE8010.E8_SALRECO

    Premissas validadas no ambiente:
    - FK5010: FK5_BANCO, FK5_AGENCI, FK5_CONTA, FK5_DTDISP, FK5_VALOR, FK5_RECPAG
    - SE8010: E8_BANCO, E8_AGENCIA, E8_CONTA, E8_DTSALAT, E8_SALRECO
*/

User Function F475PGRV(nRecSIG, nRecFK5)
    Local aArea := GetArea()
    Local lRet  := .T.

    Default nRecSIG := 0
    Default nRecFK5 := 0

    If nRecFK5 > 0
        lRet := ZF4RecalcByRec(nRecFK5)
    EndIf

    RestArea(aArea)
Return lRet

User Function F475PCAN(aRecSIG, aRecFK5)
    Local aArea   := GetArea()
    Local aChaves := {}
    Local nX      := 0

    Default aRecSIG := {}
    Default aRecFK5 := {}

    For nX := 1 To Len(aRecFK5)
        If aRecFK5[nX] > 0
            ZF4AddKey(aChaves, aRecFK5[nX])
        EndIf
    Next nX

    For nX := 1 To Len(aChaves)
        ZF4Recalc(aChaves[nX][1], aChaves[nX][2], aChaves[nX][3], aChaves[nX][4])
    Next nX

    RestArea(aArea)
Return .T.

Static Function ZF4AddKey(aChaves, nRecFK5)
    Local aArea    := GetArea()
    Local cBanco   := ""
    Local cAgencia := ""
    Local cConta   := ""
    Local dData    := STOD("")
    Local cChave   := ""
    Local nPos     := 0

    dbSelectArea("FK5")
    FK5->(dbGoTo(nRecFK5))

    If FK5->(Eof()) .Or. FK5->D_E_L_E_T_ <> ""
        RestArea(aArea)
        Return
    EndIf

    cBanco   := AllTrim(FK5->FK5_BANCO)
    cAgencia := AllTrim(FK5->FK5_AGENCI)
    cConta   := AllTrim(FK5->FK5_CONTA)
    dData    := FK5->FK5_DTDISP
    cChave   := cBanco + "|" + cAgencia + "|" + cConta + "|" + DToS(dData)

    nPos := aScan(aChaves, {|aItem| aItem[5] == cChave})
    If nPos == 0
        aAdd(aChaves, {cBanco, cAgencia, cConta, dData, cChave})
    EndIf

    RestArea(aArea)
Return

Static Function ZF4RecalcByRec(nRecFK5)
    Local aArea    := GetArea()
    Local cBanco   := ""
    Local cAgencia := ""
    Local cConta   := ""
    Local dData    := STOD("")
    Local lRet     := .F.

    dbSelectArea("FK5")
    FK5->(dbGoTo(nRecFK5))

    If !FK5->(Eof()) .And. FK5->D_E_L_E_T_ == ""
        cBanco   := AllTrim(FK5->FK5_BANCO)
        cAgencia := AllTrim(FK5->FK5_AGENCI)
        cConta   := AllTrim(FK5->FK5_CONTA)
        dData    := FK5->FK5_DTDISP
        lRet     := ZF4Recalc(cBanco, cAgencia, cConta, dData)
    EndIf

    RestArea(aArea)
Return lRet

Static Function ZF4Recalc(cBanco, cAgencia, cConta, dData)
    Local cAliasSaldo := GetNextAlias()
    Local cAliasMov   := GetNextAlias()
    Local cWhereSE8   := ""
    Local cWhereFK5   := ""
    Local cQuerySaldo := ""
    Local cQueryMov   := ""
    Local cUpdate     := ""
    Local nSaldoAnt   := 0
    Local nEntradas   := 0
    Local nSaidas     := 0
    Local nSaldoNovo  := 0
    Local nQtdSaldo   := 0

    If Empty(cBanco) .Or. Empty(cAgencia) .Or. Empty(cConta) .Or. Empty(dData)
        Return .F.
    EndIf

    cWhereSE8 := " AND E8_BANCO = " + ZF4Quote(cBanco)
    cWhereSE8 += " AND E8_AGENCIA = " + ZF4Quote(cAgencia)
    cWhereSE8 += " AND E8_CONTA = " + ZF4Quote(cConta)

    cWhereFK5 := " AND FK5_BANCO = " + ZF4Quote(cBanco)
    cWhereFK5 += " AND FK5_AGENCI = " + ZF4Quote(cAgencia)
    cWhereFK5 += " AND FK5_CONTA = " + ZF4Quote(cConta)

    cQuerySaldo := " SELECT " + ;
                   " COALESCE(MAX(CASE WHEN E8_DTSALAT < " + ZF4DateSql(dData) + " THEN E8_SALRECO END), 0) AS SALDO_ANT, " + ;
                   " SUM(CASE WHEN E8_DTSALAT = " + ZF4DateSql(dData) + " THEN 1 ELSE 0 END) AS QTD_DIA " + ;
                   " FROM SE8010 " + ;
                   " WHERE D_E_L_E_T_ = '' " + cWhereSE8 + ;
                   " AND E8_DTSALAT <= " + ZF4DateSql(dData)

    dbUseArea(.T., "TOPCONN", TcGenQry(,, ChangeQuery(cQuerySaldo)), cAliasSaldo, .T., .T.)
    If !(cAliasSaldo)->(Eof())
        nSaldoAnt := Val(AllTrim((cAliasSaldo)->SALDO_ANT))
        nQtdSaldo := Val(AllTrim((cAliasSaldo)->QTD_DIA))
    EndIf
    (cAliasSaldo)->(DbCloseArea())

    If nQtdSaldo <> 1
        ConOut("ZF475SAL: saldo nao atualizado. Conta " + cBanco + "/" + cAgencia + "/" + cConta + ;
               " data " + DToC(dData) + " com quantidade de registros SE8 = " + AllTrim(Str(nQtdSaldo)))
        Return .F.
    EndIf

    cQueryMov := " SELECT " + ;
                 " COALESCE(SUM(CASE WHEN FK5_RECPAG = 'R' THEN FK5_VALOR ELSE 0 END), 0) AS ENTRADAS, " + ;
                 " COALESCE(SUM(CASE WHEN FK5_RECPAG = 'P' THEN FK5_VALOR ELSE 0 END), 0) AS SAIDAS " + ;
                 " FROM FK5010 " + ;
                 " WHERE D_E_L_E_T_ = '' " + cWhereFK5 + ;
                 " AND FK5_DTDISP = " + ZF4DateSql(dData)

    dbUseArea(.T., "TOPCONN", TcGenQry(,, ChangeQuery(cQueryMov)), cAliasMov, .T., .T.)
    If !(cAliasMov)->(Eof())
        nEntradas := Val(AllTrim((cAliasMov)->ENTRADAS))
        nSaidas   := Val(AllTrim((cAliasMov)->SAIDAS))
    EndIf
    (cAliasMov)->(DbCloseArea())

    nSaldoNovo := nSaldoAnt + nEntradas - nSaidas

    cUpdate := " UPDATE SE8010 " + ;
               " SET E8_SALRECO = " + ZF4NumSql(nSaldoNovo, 2) + ;
               " WHERE D_E_L_E_T_ = '' " + cWhereSE8 + ;
               " AND E8_DTSALAT = " + ZF4DateSql(dData)

    If TCSqlExec(ChangeQuery(cUpdate)) < 0
        ConOut("ZF475SAL: erro ao atualizar SE8. " + TCSqlError())
        Return .F.
    EndIf

Return .T.

Static Function ZF4Quote(cValor)
Return "'" + StrTran(AllTrim(cValor), "'", "''") + "'"

Static Function ZF4DateSql(dData)
Return ZF4Quote(DToS(dData))

Static Function ZF4NumSql(nValor, nDec)
    Local cValor := ""

    Default nDec := 2

    cValor := AllTrim(Str(nValor, 18, nDec))
    cValor := StrTran(cValor, ",", ".")
Return cValor
