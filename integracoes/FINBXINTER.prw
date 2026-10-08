#Include "Protheus.ch"

/*/{Protheus.doc} F070BtOK
Valida a baixa manual de Contas a Receber.

- Bloqueia baixa anterior a emissao do titulo;
- Alerta, sem bloquear, quando o cliente pertence a uma filial do grupo.

O ponto de entrada e executado na confirmacao da FINA070 e deve retornar
logico. A data informada na tela esta na variavel private dBaixa.
/*/
User Function F070BtOK()

    Local lRet := .T.
    Local dEmissao := SE1->E1_EMISSAO
    Local nAbt := 0
    Local nRec := 0
    Local nAcre := 0
    Local nOrig := 0

    If Type("nAbatim") == "N"
        nAbt += nAbatim
    EndIf

    If Type("nDecresc") == "N"
        nAbt += nDecresc
    EndIf

    If Type("nValRec") == "N"
        nRec += nValRec
    EndIf

    If Type("nMulta") == "N"
        nAcre += nMulta
    EndIf

    If Type("nJuros") == "N"
        nAcre += nJuros
    EndIf

    If Type("nAcresc") == "N"
        nAcre += nAcresc
    EndIf

    If Type("nValTot") == "N"
        nOrig += nValTot
    EndIf

    // O valor recebido nao pode ultrapassar o saldo que permanece
    // disponivel depois do abatimento informado nesta baixa.
    If !fVldVlrBx(SE1->E1_SALDO, nAbt, nAcre, nRec, nTxMoeda, nOrig,"Contas a Receber")
        Return .F.
    EndIf

    If SuperGetMV("MV_XFINT", .F., .F.)
        If !Empty(dEmissao) .And. dBaixa < dEmissao
            MsgStop("A data da baixa (" + DToC(dBaixa) + ") nao pode ser anterior " + ;
                    "a data de emissao do titulo (" + DToC(dEmissao) + ").", ;
                    "F070BtOK")
            Return .F.
        EndIf
    
        If fIntercompany("R")
            MsgAlert("Titulo de operacao entre empresas do grupo." + CRLF + CRLF + ;
                     "Verifique se foi realizada a baixa no Contas a Pagar da empresa envolvida na operacao.", ;
                     "F070BtOK")
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} FA080LIB
Valida a baixa manual de Contas a Pagar.

- Bloqueia baixa anterior a classificacao/emissao 1 do titulo;
- Alerta, sem bloquear, quando o fornecedor pertence a uma filial do grupo.

O ponto de entrada e executado na confirmacao da FINA080 e deve retornar
logico. A data informada na tela esta na variavel private dBaixa.
/*/
User Function FA080LIB()

    Local lRet := .T.
    Local dEmissao := SE2->E2_EMISSAO
    Local nDesc := 0
    Local nPgto := 0
    Local nAcre := 0
    Local nOrig := 0

    If Type("nDescont") == "N"
        nDesc += nDescont
    EndIf

    If Type("nDecresc") == "N"
        nDesc += nDecresc
    EndIf

    If Type("nPagtoParcial") == "N"
        nDesc += nPagtoParcial
    EndIf

    If Type("nAcresc") == "N"
        nAcre += nAcresc
    EndIf

    If Type("nMulta") == "N"
        nAcre += nMulta
    EndIf

    If Type("nValPgto") == "N"
        nPgto := nValPgto
    EndIf

    If Type("nValTot") == "N"
        nOrig += nValTot
    EndIf

    // Em contas a pagar, o desconto informado reduz o valor que ainda
    // pode ser pago na baixa atual.
    If !fVldVlrBx(SE2->E2_SALDO, nDesc, nAcre, nPgto, nTxMoeda, nOrig, "Contas a Pagar")
        Return .F.
    EndIf

    If SuperGetMV("MV_XFINT", .F., .F.)
        If !Empty(dEmissao) .And. dBaixa < dEmissao
            MsgStop("A data da baixa (" + DToC(dBaixa) + ") nao pode ser anterior " + ;
                    "a data de classificacao/emissao do titulo (" + DToC(dEmissao) + ").", ;
                    "FA080LIB")
            Return .F.
        EndIf

        If fIntercompany("P")
            MsgAlert("Titulo de operacao entre empresas do grupo." + CRLF + CRLF + ;
                     "Verifique se foi realizada a baixa no Contas a Receber da empresa envolvida na operacao.", ;
                     "FA080LIB")
        EndIf
    EndIf

Return lRet

/*/
    Identifica operacao intercompany pelo campo de filial de transferencia
    do cadastro do cliente (SA1) ou fornecedor (SA2).
/*/
Static Function fIntercompany(cCarteira)

    Local cFilTransf := ""

    If cCarteira == "R"
        cFilTransf := Posicione("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA, "A1_FILTRF")
    Else
        cFilTransf := Posicione("SA2", 1, xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA, "A2_FILTRF")
    EndIf

Return !Empty(AllTrim(cFilTransf))

/*/
    Impede que o valor financeiro informado na baixa seja superior ao
    saldo do titulo, descontado do abatimento/desconto aplicado na mesma
    operacao. Juros, multa e impostos seguem o calculo padrao da rotina e
    nao sao tratados como valor recebido/pago nesta consistencia.
/*/
Static Function fVldVlrBx(nSaldo, nReducao, nAcrescimo, nValorBaixa, nTxMoeda, nOrig, cRotina)

    Local nLimite := IIF(nTxMoeda > 0, Round((nOrig - nReducao + nAcrescimo) * nTxMoeda, 2), Round(nOrig - nReducao + nAcrescimo, 2))

    If nLimite < 0
        nLimite := 0
    EndIf

    If Round(nValorBaixa, 2) > nLimite
        MsgStop("O valor da baixa de R$ " + Transform(nValorBaixa, "@E 999,999,999,999.99") + ;
                " e maior que o saldo disponivel de R$ " + Transform(nLimite, "@E 999,999,999,999.99") + ;
                ", considerando o abatimento/desconto informado.", cRotina)
        Return .F.
    EndIf

Return .T.

/*/{Protheus.doc} F070EST
Recompoe o saldo liquido do titulo apos o estorno da baixa a receber.
O ponto de entrada e executado apos a atualizacao da SE1 e a gravacao do
movimento de estorno na SE5.
/*/
User Function F070EST()

    fRecSldLiq()

Return Nil

/*/{Protheus.doc} F330VEEX
Executado apos exclusao ou estorno de compensacao de Contas a Receber.

O saldo deve permanecer no valor bruto recomposto pelo padrao. Na FINA330,
o valor remanescente ja e calculado com o abatimento ativo; liquida-lo aqui
faria com que o FETHAB fosse descontado uma segunda vez.
/*/
User Function F330VEEX()

Return Nil

/*/
    O cancelamento padrao da baixa pode devolver E1_SALDO ao valor bruto
    quando a baixa cancelada era a ultima do titulo. Se ainda existirem
    abatimentos ativos, o saldo disponivel deve permanecer liquido deles.
/*/
Static Function fRecSldLiq()

    Local nAbatimento := 0
    Local nSaldoLiquido := 0

    nAbatimento := SumAbatRec(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, ;
                              SE1->E1_MOEDA, "S", dDataBase)

    // So atua na situacao de recomposicao integral feita pelo padrao.
    If nAbatimento > 0 .And. Round(SE1->E1_SALDO, 2) == Round(SE1->E1_VALOR, 2)
        nSaldoLiquido := Max(0, Round(SE1->E1_VALOR - nAbatimento, 2))

        RecLock("SE1", .F.)
            SE1->E1_SALDO := nSaldoLiquido

            If SE1->(FieldPos("E1_SLPLAID")) > 0
                SE1->E1_SLPLAID := nSaldoLiquido
            EndIf
        MsUnlock()
    EndIf

Return Nil
