#Include "Protheus.ch"
#Include "FileIO.ch"

/*/{Protheus.doc} LMALTVLR
Permite corrigir diferenca de arredondamento de ate R$ 0,01 nos valores da
nota de entrada (SF1), do registro fiscal (SF3) e do titulo a pagar (SE2).

O ajuste e permitido somente quando existe um unico registro de SF3 para a
chave do documento. Havendo mais de um, a distribuicao do centavo entre CFOPs
deve ser definida pelo Fiscal, nao sendo seguro escolher um registro arbitrario.

@type user function
/*/
User Function LMALTVLR()
    Local aArea      := GetArea()
    Local aAreaSD1   := SD1->(GetArea())
    Local aAreaSF3   := SF3->(GetArea())
    Local aAreaSE2   := SE2->(GetArea())
    Local aAreaSFT   := SFT->(GetArea())
    Local cAlias     := GetNextAlias()
    Local cAliasE2   := GetNextAlias()
    Local cAliasD1   := GetNextAlias()
    Local cAliasFT   := GetNextAlias()
    Local cDoc       := AllTrim(SF1->F1_DOC)
    Local cSerie     := AllTrim(SF1->F1_SERIE)
    Local cPrefixo   := AllTrim(GetMV("MV_2DUPREF"))
    Local cFornec    := AllTrim(SF1->F1_FORNECE)
    Local cLoja      := AllTrim(SF1->F1_LOJA)
    Local cEspecie   := AllTrim(SF1->F1_ESPECIE)
    Local cTipo      := AllTrim(SF1->F1_TIPO)
    Local nRecSF1    := SF1->(RecNo())
    Local nAtual     := Round(SF1->F1_VALBRUT, 2)
    Local nNovo      := nAtual
    Local dDataFec   := SuperGetMV("MV_ULMES",.F.)
    Local nRecSF3    := 0
    Local nQtdSF3    := 0
    Local nRecSD1    := 0
    Local nQtdSD1    := 0
    Local nEscolha   := 0
    Local cProduto   := ""
    Local cItem      := ""
    Local aItens     := {}
    Local aEscolhas  := {}
    Local aRecSFT    := {}
    Local nRecSE2    := 0
    Local nQtdSE2    := 0
    Local nE2Valor   := 0
    Local nE2Saldo   := 0
    Local nDelta     := 0
    Local lConfirma  := .F.
    Local lEscolheu  := .F.
    Local lGravou    := .T.
    Local lF3        := .T.
    Local oDlg
    Local oDlgItens
    Local oListItens

    If Select("SF1") == 0 .Or. Empty(cDoc)
        MsgAlert("Posicione um Documento de Entrada antes de executar a acao.", "Ajustar Vlr. Bruto")
        RestArea(aArea)
        Return
    EndIf

    If !LMUSRAUT(.T.) .And. !FWIsAdmin()
        RestArea(aAreaSF3)
        RestArea(aAreaSE2)
        RestArea(aAreaSD1)
        RestArea(aAreaSFT)
        RestArea(aArea)
        Return
    EndIf

    // Bloqueia a alteracao antes de abrir o modal quando o periodo ja foi fechado.
    If dDataFec >= dDataBase .Or. dDataFec >= SF1->F1_DTDIGIT
        MsgAlert("O periodo do documento esta fechado. Reabra o periodo para ajustar o valor bruto.", "Ajustar Vlr. Bruto")
        RestArea(aAreaSF3)
        RestArea(aAreaSE2)
        RestArea(aAreaSD1)
        RestArea(aAreaSFT)
        RestArea(aArea)
        Return
    EndIf

    DEFINE MSDIALOG oDlg TITLE "Ajustar Vlr. Bruto" FROM 000, 000 TO 210, 620 PIXEL
        @ 18, 18 SAY "Valor atual:" OF oDlg SIZE 75, 12 PIXEL
        @ 18, 68 SAY Transform(nAtual, PesqPict("SF1", "F1_VALBRUT")) OF oDlg SIZE 105, 12 PIXEL
        @ 38, 18 SAY "Novo valor:" OF oDlg SIZE 70, 12 PIXEL
        @ 36, 68 GET nNovo PICTURE PesqPict("SF1", "F1_VALBRUT") OF oDlg SIZE 115, 14 PIXEL

        @ 68, 130 BUTTON "Confirmar" SIZE 75, 16 OF oDlg PIXEL ACTION (lConfirma := .T., oDlg:End())
        @ 68, 215 BUTTON "Cancelar"  SIZE 70, 16 OF oDlg PIXEL ACTION oDlg:End()
    ACTIVATE MSDIALOG oDlg CENTERED

    If !lConfirma
        RestArea(aAreaSF3)
        RestArea(aAreaSE2)
        RestArea(aAreaSD1)
        RestArea(aAreaSFT)
        RestArea(aArea)
        Return
    EndIf

    nNovo := Round(nNovo, 2)
    If Round(Abs(nNovo - nAtual), 2) > 0.01
        MsgAlert("O novo valor deve variar no maximo R$ 0,01 para mais ou para menos.", "Ajustar Vlr. Bruto")
        RestArea(aAreaSF3)
        RestArea(aAreaSE2)
        RestArea(aAreaSD1)
        RestArea(aAreaSFT)
        RestArea(aArea)
        Return
    EndIf

    // Tambem permite reconciliar os itens caso o bruto ja esteja correto,
    // mas F1_VALMERC/SD1 tenham sido alterados em uma execucao anterior.
    If nNovo == nAtual
        MsgInfo("Nenhuma alteracao foi realizada.", "Ajustar Vlr. Bruto")
        RestArea(aAreaSF3)
        RestArea(aAreaSE2)
        RestArea(aAreaSD1)
        RestArea(aAreaSFT)
        RestArea(aArea)
        Return
    EndIf

    BeginSql Alias cAlias
        SELECT R_E_C_N_O_ AS RECNO
          FROM %table:SF3%
         WHERE %notDel%
           AND F3_FILIAL   = %xFilial:SF3%
           AND F3_NFISCAL  = %exp:cDoc%
           AND F3_SERIE    = %exp:cSerie%
           AND F3_CLIEFOR  = %exp:cFornec%
           AND F3_LOJA     = %exp:cLoja%
    EndSql

    (cAlias)->(DbGoTop())
    While !(cAlias)->(Eof())
        nQtdSF3++
        nRecSF3 := (cAlias)->RECNO
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())

    If nQtdSF3 = 0 .AND. cEspecie $ "NFS|NFSC|FTF|TCB|ND|RC"
        lF3 := .F.
    ElseIf nQtdSF3 > 1
        (FwAlert("Foram encontrados " + cValToChar(nQtdSF3) + " registros na SF3 para esta nota." +  CRLF + ;
                 "O ajuste nao foi efetuado para nao alterar a distribuicao fiscal entre CFOPs.", "Ajustar Vlr. Bruto"))
        RestArea(aAreaSF3)
        RestArea(aAreaSE2)
        RestArea(aAreaSD1)
        RestArea(aAreaSFT)
        RestArea(aArea)
            Return
        
    EndIf

    // Financeiro segue o valor bruto; SD1 e SFT seguem a mercadoria.
    // Os dois podem ter valores diferentes antes do ajuste.
    nDelta     := nNovo - nAtual

    // Quando houver mais de um item, o usuario define qual deles absorvera a
    // diferenca de mercadoria. A soma da SD1/SFT acompanha F1_VALMERC.
    BeginSql Alias cAliasD1
        SELECT SD1.R_E_C_N_O_ AS RECNO, SD1.D1_ITEM, SD1.D1_COD, SD1.D1_TOTAL,
               SB1.B1_DESC
          FROM %table:SD1% SD1
          LEFT JOIN %table:SB1% SB1
            ON SB1.%notDel%
           AND SB1.B1_FILIAL = %xFilial:SB1%
           AND SB1.B1_COD    = SD1.D1_COD
         WHERE SD1.%notDel%
           AND SD1.D1_FILIAL  = %xFilial:SD1%
           AND SD1.D1_DOC     = %exp:cDoc%
           AND SD1.D1_SERIE   = %exp:cSerie%
           AND SD1.D1_FORNECE = %exp:cFornec%
           AND SD1.D1_LOJA    = %exp:cLoja%
         ORDER BY SD1.D1_ITEM
    EndSql

    (cAliasD1)->(DbGoTop())
    While !(cAliasD1)->(Eof())
        nQtdSD1++
        AAdd(aItens, { (cAliasD1)->RECNO, (cAliasD1)->D1_COD, (cAliasD1)->D1_ITEM, (cAliasD1)->D1_TOTAL })
        AAdd(aEscolhas, PadR((cAliasD1)->D1_ITEM, 6) + "  " + PadR((cAliasD1)->D1_COD, 15) + "  " + ;
                         PadR((cAliasD1)->B1_DESC, 45) + "  " + ;
                         Transform((cAliasD1)->D1_TOTAL, PesqPict("SD1", "D1_TOTAL")))
        (cAliasD1)->(DbSkip())
    EndDo
    (cAliasD1)->(DbCloseArea())

    If nQtdSD1 == 0
        MsgAlert("Nao foram encontrados itens na SD1 para o documento posicionado.", "Ajustar Vlr. Bruto")
        RestArea(aAreaSF3)
        RestArea(aAreaSE2)
        RestArea(aAreaSD1)
        RestArea(aAreaSFT)
        RestArea(aArea)
        Return
    EndIf

    If nQtdSD1 == 1
        nEscolha := 1
    Else
        nEscolha := 1
        DEFINE MSDIALOG oDlgItens TITLE "Selecionar item para ajuste" FROM 000, 000 TO 370, 620 PIXEL
            @ 18, 18 SAY "Selecione o item que recebera o ajuste de mercadoria:" OF oDlgItens SIZE 320, 12 PIXEL
            oListItens := TListBox():New(42, 18, {|u| If(PCount() > 0, nEscolha := u, nEscolha)}, ;
                                         aEscolhas, 280, 80, , oDlgItens,,,,.T.)
            @ 138, 130 BUTTON "Confirmar" SIZE 75, 16 OF oDlgItens PIXEL ACTION (lEscolheu := .T., oDlgItens:End())
            @ 138, 215 BUTTON "Cancelar"  SIZE 75, 16 OF oDlgItens PIXEL ACTION oDlgItens:End()
        ACTIVATE MSDIALOG oDlgItens CENTERED

        If !lEscolheu
            RestArea(aAreaSF3)
            RestArea(aAreaSE2)
            RestArea(aAreaSD1)
            RestArea(aAreaSFT)
            RestArea(aArea)
            Return
        EndIf
    EndIf

    nRecSD1 := aItens[nEscolha][1]
    cProduto := aItens[nEscolha][2]
    cItem := aItens[nEscolha][3]

    // SFT pode nao existir para determinadas especies. Quando existir, atualiza
    // somente o espelho fiscal do item selecionado.
    BeginSql Alias cAliasFT
        SELECT R_E_C_N_O_ AS RECNO
          FROM %table:SFT%
         WHERE %notDel%
           AND FT_FILIAL   = %xFilial:SFT%
           AND FT_TIPOMOV  = 'E'
           AND FT_NFISCAL  = %exp:cDoc%
           AND FT_SERIE    = %exp:cSerie%
           AND FT_CLIEFOR  = %exp:cFornec%
           AND FT_LOJA     = %exp:cLoja%
           AND FT_PRODUTO  = %exp:cProduto%
           AND FT_ITEM     = %exp:cItem%
    EndSql

    (cAliasFT)->(DbGoTop())
    While !(cAliasFT)->(Eof())
        AAdd(aRecSFT, (cAliasFT)->RECNO)
        (cAliasFT)->(DbSkip())
    EndDo
    (cAliasFT)->(DbCloseArea())

    // Em caso de varias parcelas, o centavo e aplicado na ultima duplicata,
    // preservando a soma dos titulos e evitando rateio com fracao de centavo.
    BeginSql Alias cAliasE2
        SELECT R_E_C_N_O_ AS RECNO, E2_VALOR, E2_SALDO
          FROM %table:SE2%
         WHERE %notDel%
           AND E2_FILIAL  = %xFilial:SE2%
           AND E2_FORNECE = %exp:cFornec%
           AND E2_LOJA    = %exp:cLoja%
           AND (E2_PREFIXO = %exp:cSerie% OR E2_PREFIXO = %exp:cPrefixo%)
           AND E2_NUM     = %exp:cDoc%
         ORDER BY R_E_C_N_O_
    EndSql

    (cAliasE2)->(DbGoTop())
    While !(cAliasE2)->(Eof())
        nQtdSE2++
        nRecSE2  := (cAliasE2)->RECNO
        nE2Valor := (cAliasE2)->E2_VALOR
        nE2Saldo := (cAliasE2)->E2_SALDO
        (cAliasE2)->(DbSkip())
    EndDo
    (cAliasE2)->(DbCloseArea())

    If nQtdSE2 > 0 .And. Round(nE2Saldo - nE2Valor, 2) <> 0
        If !(FwAlertYesNo("A ultima duplicata da nota possui baixa ou saldo divergente." + CRLF + ;
                 "O ajuste nao foi efetuado para nao alterar um titulo financeiro movimentado.", "Ajustar Vlr. Bruto"))
            RestArea(aAreaSF3)
            RestArea(aAreaSE2)
            RestArea(aAreaSD1)
            RestArea(aAreaSFT)
            RestArea(aArea)
            Return
        EndIf
    EndIf

    BEGIN TRANSACTION
        DbSelectArea("SF1")
        SF1->(DbGoTo(nRecSF1))
        If RecLock("SF1", .F.)
            SF1->F1_VALBRUT := nNovo
            SF1->F1_VALMERC := nNovo
            MsUnlock("SF1")
        Else
            lGravou := .F.
            DisarmTransaction()
        EndIf

        If lGravou
            DbSelectArea("SD1")
            SD1->(DbGoTo(nRecSD1))
            If RecLock("SD1", .F.)
                SD1->D1_TOTAL := Round(SD1->D1_TOTAL + nDelta, TamSX3("D1_TOTAL")[2])
                MsUnlock("SD1")
            Else
                lGravou := .F.
                DisarmTransaction()
            EndIf
        EndIf

        If lGravou .And. lF3 .And. nQtdSF3 > 0
            For nEscolha := 1 To Len(aRecSFT)
                DbSelectArea("SFT")
                SFT->(DbGoTo(aRecSFT[nEscolha]))
                If RecLock("SFT", .F.)
                    SFT->FT_TOTAL := Round(SFT->FT_TOTAL + nDelta, TamSX3("FT_TOTAL")[2])
                    MsUnlock("SFT")
                Else
                    lGravou := .F.
                    DisarmTransaction()
                    Exit
                EndIf
            Next nEscolha
        EndIf

        If lGravou .And. lF3 .And. nQtdSF3 > 0
            DbSelectArea("SF3")
            SF3->(DbGoTo(nRecSF3))
            If RecLock("SF3", .F.)
                SF3->F3_VALCONT := nNovo
                MsUnlock("SF3")
            Else
                lGravou := .F.
                DisarmTransaction()
            EndIf
        EndIf

        If lGravou .And. nQtdSE2 > 0
            DbSelectArea("SE2")
            SE2->(DbGoTo(nRecSE2))
            If RecLock("SE2", .F.)
                SE2->E2_VALOR := Round(nE2Valor + nDelta, TamSX3("E2_VALOR")[2])
                SE2->E2_SALDO := Round(nE2Saldo + nDelta, TamSX3("E2_SALDO")[2])
                MsUnlock("SE2")
            Else
                lGravou := .F.
                DisarmTransaction()
            EndIf
        EndIf
    END TRANSACTION

    If lGravou
        MsgInfo("Valor bruto ajustado de " + AllTrim(Transform(nAtual, PesqPict("SF1", "F1_VALBRUT"))) + ;
                " para " + AllTrim(Transform(nNovo, PesqPict("SF1", "F1_VALBRUT"))) + ".", "Ajustar Vlr. Bruto")
        LMGRVLG(cDoc, cSerie, cFornec, cLoja, cEspecie, cTipo, nAtual, nNovo, cItem, cProduto, nRecSF1, nRecSD1, nRecSF3, nRecSE2, aRecSFT)
        LMMAILALT(cDoc, cSerie, cFornec, cLoja, cEspecie, cTipo, nAtual, nNovo, cItem, cProduto)
    Else
        MsgAlert("Nao foi possivel bloquear a SF1, SD1, SF3, SFT ou SE2. Nenhuma alteracao foi gravada.", "Ajustar Vlr. Bruto")
    EndIf

    RestArea(aAreaSF3)
    RestArea(aAreaSE2)
    RestArea(aAreaSD1)
    RestArea(aAreaSFT)
    RestArea(aArea)
Return
/*/{Protheus.doc} LMMAIL01
Envia o arquivo consolidado dos ajustes de valor bruto da semana anterior.
Agende esta funcao no AppServer para executar toda segunda-feira.

@type user function
/*/
User Function LMMAIL01()
    Local dInicioSemana := Date() - 7
    Local cArquivo      := LMNOMARQ(dInicioSemana)
    Local cDestinatarios:= ""
    Local cAssunto      := "Relatorio semanal - Ajustes de Valor Bruto"
    Local cCorpo        := ""
    Local lEnviado      := .F.

    If Select("SX2") == 0
	    RpcClearEnv()
	    RPCSetType(3)	//NAO CONSOME LICENSA DE USO
	    If(!RpcSetEnv("01", "060110", "", "", "CTB",,{"SN3"}))
	    	Return(Nil)
	    EndIf
	    lRPC := .T.
    EndIf
    
    cDestinatarios := AllTrim(SuperGetMV("MV_Z103EML", .F., "luiz.moura@masutti.com.br"))

    If Empty(cDestinatarios)
        ConOut("LMMAIL01: parametro MV_Z103EML nao informado.")
        Return .F.
    EndIf

    If !File(cArquivo)
        ConOut("LMMAIL01: nao houve ajustes na semana iniciada em " + DToC(dInicioSemana) + ".")
        Return .T.
    EndIf

    cCorpo := LMCRPEML(cArquivo, dInicioSemana)
    lEnviado := GEnvMail(cDestinatarios, cAssunto, cCorpo, { cArquivo }, .F., .T.)
    If !lEnviado
        ConOut("LMMAIL01: falha ao enviar o relatorio semanal de ajustes de valor bruto.")
    EndIf
Return lEnviado

/*/{Protheus.doc} LMMAILALT
Envia a notificacao imediata de um ajuste confirmado de valor bruto. Os
destinatarios sao os mesmos do relatorio semanal (MV_Z103EML).
/*/
Static Function LMMAILALT(cDoc, cSerie, cFornec, cLoja, cEspecie, cTipo, nAtual, nNovo, cItem, cProduto)
    Local cDestinatarios := AllTrim(SuperGetMV("MV_Z103EML", .F., "luiz.moura@masutti.com.br"))
    Local cAssunto       := "Alerta - Ajuste de Valor Bruto - NF " + AllTrim(cDoc)
    Local cCorpo         := ""
    Local cDelta         := IIf(nNovo - nAtual >= 0, "+ R$ ", "- R$ ") + ;
                           AllTrim(Transform(Abs(nNovo - nAtual), "@E 999,999,999.99"))
    Local lEnviado       := .F.

    If Empty(cDestinatarios)
        ConOut("LMMAILALT: parametro MV_Z103EML nao informado.")
        Return .F.
    EndIf

    cCorpo := '<!DOCTYPE html><html lang="pt-BR"><head><meta charset="utf-8"></head>' + ;
              '<body style="margin:0;background:#f5f8f7;font-family:Arial,Helvetica,sans-serif;color:#023941;">' + ;
              '<table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="padding:24px 8px;"><tr><td align="center">' + ;
              '<table role="presentation" width="600" cellspacing="0" cellpadding="0" style="max-width:600px;width:100%;background:#fff;border-radius:12px;overflow:hidden;">' + ;
              '<tr><td style="background:#023941;padding:22px 28px;color:#fff;"><img src="https://masutti.com.br/site/assets/img/logo-neg.svg" alt="Masutti" width="190" style="display:block;width:190px;max-width:100%;height:auto;border:0;">' + ;
              '<div style="font-size:13px;color:#f9b000;font-weight:700;margin-top:8px;">Ajustes de Valor Bruto</div><div style="font-size:13px;color:#d5eeee;margin-top:4px;">Notificacao imediata de auditoria</div></td></tr>' + ;
              '<tr><td style="padding:28px;"><div style="display:inline-block;background:#e3f4f2;color:#00616f;border-radius:12px;padding:6px 10px;font-size:11px;font-weight:700;">AJUSTE CONFIRMADO</div>' + ;
              '<h1 style="margin:16px 0 4px;font-size:24px;">Valor bruto alterado</h1><p style="margin:0;color:#45646a;font-size:14px;">O ajuste foi concluido e registrado na auditoria.</p>' + ;
              '<table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="margin-top:22px;border:1px solid #d3e2e1;border-collapse:collapse;font-size:13px;">' + ;
              '<tr><td style="padding:10px 12px;background:#f1f7f6;color:#45646a;width:40%;">Documento</td><td style="padding:10px 12px;">NF ' + LM103Html(cDoc) + ' - Serie ' + LM103Html(cSerie) + '</td></tr>' + ;
              '<tr><td style="padding:10px 12px;background:#f1f7f6;color:#45646a;">Fornecedor / Loja</td><td style="padding:10px 12px;">' + LM103Html(cFornec) + ' / ' + LM103Html(cLoja) + '</td></tr>' + ;
              '<tr><td style="padding:10px 12px;background:#f1f7f6;color:#45646a;">Especie / Tipo</td><td style="padding:10px 12px;">' + LM103Html(cEspecie) + ' / ' + LM103Html(cTipo) + '</td></tr>' + ;
              '<tr><td style="padding:10px 12px;background:#f1f7f6;color:#45646a;">Item / Produto</td><td style="padding:10px 12px;">' + LM103Html(cItem) + ' / ' + LM103Html(cProduto) + '</td></tr>' + ;
              '<tr><td style="padding:10px 12px;background:#f1f7f6;color:#45646a;">Valor anterior</td><td style="padding:10px 12px;text-decoration:line-through;">R$ ' + AllTrim(Transform(nAtual, PesqPict("SF1", "F1_VALBRUT"))) + '</td></tr>' + ;
              '<tr><td style="padding:10px 12px;background:#f1f7f6;color:#45646a;">Novo valor</td><td style="padding:10px 12px;font-weight:700;color:#023941;">R$ ' + AllTrim(Transform(nNovo, PesqPict("SF1", "F1_VALBRUT"))) + ' <span style="color:' + IIf(nNovo - nAtual >= 0, '#009a93', '#b42318') + ';">(' + cDelta + ')</span></td></tr>' + ;
              '<tr><td style="padding:10px 12px;background:#f1f7f6;color:#45646a;">Alterado por</td><td style="padding:10px 12px;">' + LM103Html(UsrRetName(RetCodUsr())) + ' (' + LM103Html(RetCodUsr()) + ') em ' + DToC(Date()) + ' ' + Time() + '</td></tr>' + ;
              '</table></td></tr><tr><td style="background:#e8f5f4;padding:18px 28px;color:#45646a;font-size:11px;">Notificacao automatica do Protheus. O ajuste tambem constara no relatorio semanal.</td></tr>' + ;
              '</table></td></tr></table></body></html>'

    lEnviado := GEnvMail(cDestinatarios, cAssunto, cCorpo, {}, .F., .T.)
    If !lEnviado
        ConOut("LMMAILALT: falha ao enviar a notificacao imediata de ajuste de valor bruto.")
    EndIf
Return lEnviado

/*/{Protheus.doc} LMUSRPAR
Expõe a consulta de acesso para uso no ponto de entrada MA103OPC.
/*/
User Function LMUSRPAR(lExibeMensagem)
Return LMUSRAUT(lExibeMensagem)
/*/{Protheus.doc} LMUSRAUT
Valida os IDs configurados no parametro MV_Z103USR. Informe os
usuarios autorizados separados por barra vertical, por exemplo: 000001|000002.
/*/
Static Function LMUSRAUT(lExibeMensagem)
    Local cUsuarios := Upper(AllTrim(SuperGetMV("MV_Z103USR", .F., "|000756|")))
    Local cUsuario  := Upper(AllTrim(RetCodUsr()))
    Local lRet      := .F.

    Default lExibeMensagem := .F.
    cUsuarios := StrTran(cUsuarios, ";", "|")
    cUsuarios := StrTran(cUsuarios, ",", "|")

    If Empty(cUsuarios)
        If lExibeMensagem
            MsgAlert("A acao nao esta configurada. Informe os IDs autorizados no parametro MV_Z103USR.", "Ajustar Vlr. Bruto")
        EndIf
        Return .F.
    EndIf

    lRet := ("|" + cUsuario + "|") $ ("|" + cUsuarios + "|")
    If !lRet .And. lExibeMensagem
        MsgAlert("Usuario sem permissao para ajustar o valor bruto.", "Ajustar Vlr. Bruto")
    EndIf
Return lRet

/*/{Protheus.doc} LMGRVLG
Acrescenta o ajuste confirmado ao CSV da respectiva semana. O arquivo e usado
pela rotina LMMAIL01 para compor e enviar o relatorio semanal.
/*/
Static Function LMGRVLG(cDoc, cSerie, cFornec, cLoja, cEspecie, cTipo, nAtual, nNovo, cItem, cProduto, nRecSF1, nRecSD1, nRecSF3, nRecSE2, aRecSFT)
    Local dInicioSemana := Date() - IIf(DoW(Date()) == 1, 6, DoW(Date()) - 2)
    Local cArquivo      := LMNOMARQ(dInicioSemana)
    Local cCabecalho    := "Data;Hora;Usuario ID;Usuario;Filial;Documento;Serie;Fornecedor;Loja;Especie;Tipo;Valor anterior;Valor novo;Item;Produto;Tabelas e RECNOs" + CRLF
    Local cAuditoria    := LMAUDIT(nRecSF1, nRecSD1, nRecSF3, nRecSE2, aRecSFT)
    Local cLinha        := DToC(Date()) + ";" + Time() + ";" + AllTrim(RetCodUsr()) + ";" + ;
                           AllTrim(UsrRetName(RetCodUsr())) + ";" + xFilial("SF1") + ";" + ;
                           AllTrim(cDoc) + ";" + AllTrim(cSerie) + ";" + AllTrim(cFornec) + ";" + ;
                           AllTrim(cLoja) + ";" + AllTrim(cEspecie) + ";" + AllTrim(cTipo) + ";" + ;
                           AllTrim(Transform(nAtual, PesqPict("SF1", "F1_VALBRUT"))) + ";" + ;
                           AllTrim(Transform(nNovo, PesqPict("SF1", "F1_VALBRUT"))) + ";" + ;
                           AllTrim(cItem) + ";" + AllTrim(cProduto) + ";" + cAuditoria + CRLF
    Local nHandle       := -1

    If !File(cArquivo)
        nHandle := FCreate(cArquivo)
        If nHandle >= 0
            FWrite(nHandle, cCabecalho)
        EndIf
    Else
        nHandle := FOpen(cArquivo, FO_READWRITE)
        If nHandle >= 0
            FSeek(nHandle, 0, FS_END)
        EndIf
    EndIf

    If nHandle >= 0
        FWrite(nHandle, cLinha)
        FClose(nHandle)
    Else
        ConOut("LMALTVLR: nao foi possivel gravar o log semanal em " + cArquivo + ".")
    EndIf
Return
/*/{Protheus.doc} LMCRPEML
Monta o digest HTML do relatorio semanal a partir do CSV de auditoria.
/*/
Static Function LMCRPEML(cArquivo, dInicioSemana)
    Local aLinhas   := StrTokArr(MemoRead(cArquivo), Chr(10))
    Local aCampos   := {}
    Local cHtml     := ""
    Local cLinhas   := ""
    Local cDelta    := ""
    Local nLinha    := 0
    Local nQtd      := 0
    Local nAnterior := 0
    Local nNovo     := 0
    Local nDelta    := 0

    For nLinha := 2 To Len(aLinhas)
        If !Empty(AllTrim(aLinhas[nLinha]))
            aCampos := StrTokArr(AllTrim(aLinhas[nLinha]), ";")
            If Len(aCampos) >= 16
                nAnterior := LMVLCSV(aCampos[12])
                nNovo     := LMVLCSV(aCampos[13])
                nDelta   += nNovo - nAnterior
                nQtd++
                cDelta := IIf(nNovo - nAnterior >= 0, "+ R$ ", "- R$ ") + AllTrim(Transform(Abs(nNovo - nAnterior), "@E 999,999,999.99"))
                cLinhas += '<tr><td style="padding:14px 12px;border-bottom:1px solid #d3e2e1;"><strong>NF ' + LM103Html(aCampos[6]) + '</strong><br><span style="font-size:12px;color:#45646a;">Serie ' + LM103Html(aCampos[7]) + ' • ' + LM103Html(aCampos[1]) + ' ' + LM103Html(aCampos[2]) + '</span></td>' + ;
                           '<td style="padding:14px 12px;border-bottom:1px solid #d3e2e1;color:#344054;">' + LM103Html(aCampos[8]) + '<br><span style="font-size:12px;color:#45646a;">Alterado por: ' + LM103Html(aCampos[5]) + ' (' + LM103Html(aCampos[4]) + ')<br>' + LM103Html(aCampos[16]) + '</span></td>' + ;
                           '<td style="padding:14px 12px;border-bottom:1px solid #d3e2e1;text-align:right;color:#45646a;text-decoration:line-through;">R$ ' + LM103Html(aCampos[12]) + '</td>' + ;
                           '<td style="padding:14px 12px;border-bottom:1px solid #d3e2e1;text-align:right;color:#023941;font-weight:700;">R$ ' + LM103Html(aCampos[13]) + '<br><span style="font-size:12px;color:' + IIf(nNovo - nAnterior >= 0, '#009a93', '#b42318') + ';">' + cDelta + '</span></td></tr>'
            EndIf
        EndIf
    Next nLinha

    If Empty(cLinhas)
        cLinhas := '<tr><td colspan="4" style="padding:20px;text-align:center;color:#45646a;">Nenhum ajuste encontrado no periodo.</td></tr>'
    EndIf

    cHtml := '<!DOCTYPE html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><style>@media only screen and (max-width:620px){.container{width:100%!important}.content{padding:20px!important}.metric{display:block!important;width:100%!important;box-sizing:border-box!important;border-right:0!important;border-bottom:8px solid #fff!important}.audit-table,.audit-table tbody,.audit-table tr,.audit-table td{display:block!important;width:100%!important;box-sizing:border-box!important}.audit-table th{display:none!important}.audit-table td{text-align:left!important;padding:10px 12px!important}.audit-table td:nth-child(3),.audit-table td:nth-child(4){text-align:right!important}.audit-table tr{border-bottom:8px solid #f5f8f7!important}}</style></head><body style="margin:0;background:#f5f8f7;font-family:Arial,Helvetica,sans-serif;color:#023941;"><table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="padding:24px 8px;"><tr><td align="center"><table role="presentation" class="container" width="600" cellspacing="0" cellpadding="0" style="max-width:600px;width:100%;background:#fff;border-radius:12px;overflow:hidden;">' + ;
             '<tr><td style="background:#023941;padding:22px 28px;color:#fff;"><img src="https://masutti.com.br/site/assets/img/logo-neg.svg" alt="Masutti" width="190" style="display:block;width:190px;max-width:100%;height:auto;border:0;"><div style="font-size:13px;color:#f9b000;font-weight:700;margin-top:8px;">Ajustes de Valor Bruto</div><div style="font-size:13px;color:#d5eeee;margin-top:4px;">Resumo semanal de auditoria</div></td></tr><tr><td class="content" style="padding:28px;">' + ;
             '<div style="display:inline-block;background:#e3f4f2;color:#00616f;border-radius:12px;padding:6px 10px;font-size:11px;font-weight:700;">ALERTA SEMANAL DE AUDITORIA</div><h1 style="margin:16px 0 4px;font-size:24px;">' + cValToChar(nQtd) + ' ajuste(s) de valor bruto</h1><p style="margin:0;color:#45646a;font-size:14px;">Periodo apurado: <strong style="color:#023941;">' + DToC(dInicioSemana) + ' a ' + DToC(dInicioSemana + 6) + '</strong></p>' + ;
             '<table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="margin-top:22px;background:#e8f5f4;border-radius:10px;"><tr><td class="metric" style="padding:18px;width:50%;border-right:8px solid #fff;"><div style="font-size:12px;color:#45646a;">VARIACAO LIQUIDA</div><div style="margin-top:6px;font-size:22px;font-weight:700;">' + IIf(nDelta >= 0, "+ R$ ", "- R$ ") + AllTrim(Transform(Abs(nDelta), "@E 999,999,999.99")) + '</div></td><td class="metric" style="padding:18px;"><div style="font-size:12px;color:#45646a;">REGISTROS AUDITADOS</div><div style="margin-top:6px;font-size:22px;font-weight:700;">' + cValToChar(nQtd) + '</div></td></tr></table>' + ;
             '<h2 style="margin:28px 0 10px;font-size:18px;">Documentos com alteracoes</h2><table role="presentation" class="audit-table" width="100%" cellspacing="0" cellpadding="0" style="border:1px solid #d3e2e1;border-collapse:separate;border-spacing:0;font-size:13px;"><tr style="background:#f1f7f6;color:#45646a;font-size:11px;"><th align="left" style="padding:10px 12px;">DOCUMENTO</th><th align="left" style="padding:10px 12px;">FORNECEDOR / USUARIO</th><th align="right" style="padding:10px 12px;">ANTERIOR</th><th align="right" style="padding:10px 12px;">NOVO VALOR</th></tr>' + cLinhas + '</table>' + ;
             '<div style="margin-top:22px;padding:14px 16px;background:#d5eeee;border-radius:10px;font-size:12px;line-height:18px;color:#344054;"><strong style="color:#023941;">Integridade da auditoria.</strong> Este relatorio foi gerado automaticamente a partir dos ajustes autorizados no Documento de Entrada.</div></td></tr>' + ;
             '<tr><td style="background:#e8f5f4;padding:18px 28px;color:#45646a;font-size:11px;">Relatorio automatico do Protheus • Arquivo CSV detalhado anexado a esta mensagem.</td></tr></table></td></tr></table></body></html>'
Return cHtml

Static Function LMAUDIT(nRecSF1, nRecSD1, nRecSF3, nRecSE2, aRecSFT)
    Local cRet := "SF1(" + cValToChar(nRecSF1) + ")|SD1(" + cValToChar(nRecSD1) + ")"
    Local nPos := 0

    If nRecSF3 > 0
        cRet += "|SF3(" + cValToChar(nRecSF3) + ")"
    EndIf
    If nRecSE2 > 0
        cRet += "|SE2(" + cValToChar(nRecSE2) + ")"
    EndIf
    For nPos := 1 To Len(aRecSFT)
        cRet += "|SFT(" + cValToChar(aRecSFT[nPos]) + ")"
    Next nPos
Return cRet
Static Function LMVLCSV(cValor)
Return Val(StrTran(StrTran(AllTrim(cValor), ".", ""), ",", "."))

Static Function LM103Html(cTexto)
    cTexto := StrTran(cValToChar(cTexto), "&", "&amp;")
    cTexto := StrTran(cTexto, "<", "&lt;")
    cTexto := StrTran(cTexto, ">", "&gt;")
Return cTexto

Static Function LMNOMARQ(dInicioSemana)
    Local cBase := IIf(IsSrvUnix(), "logs/", "logs\")
    Local cDir  := cBase + IIf(IsSrvUnix(), "ajusteValor/", "ajusteValor\")

    // Caminho relativo ao StartPath do AppServer. A barra inicial apontava
    // para a raiz do servidor e fazia o FCreate retornar -1.
    If !ExistDir(cBase)
        MakeDir(cBase)
    EndIf
    If !ExistDir(cDir)
        MakeDir(cDir)
    EndIf
Return cDir + "ajustes_" + DToS(dInicioSemana) + ".csv"

/*/{Protheus.doc} GEnvMail
Envia e-mail SMTP com os parametros padrao do Protheus.

@param cPara, character, Destinatarios separados por ponto e virgula
@param cAssunto, character, Assunto do e-mail
@param cCorpo, character, Corpo HTML do e-mail
@param aAnexos, array, Arquivos a anexar
@param lMostraLog, logical, Exibe erros na interface quando aplicavel
@param lUsaTLS, logical, Habilita TLS no SMTP
@return logical, Indica se o envio foi concluido
/*/
Static Function GEnvMail(cPara, cAssunto, cCorpo, aAnexos, lMostraLog, lUsaTLS)
    Local aArea     := GetArea()
    Local nAtual    := 0
    Local nRet      := 0
    Local nTimeOut  := SuperGetMV("MV_RELTIME", .F., 120)
    Local nPort     := 587
    Local cFrom     := AllTrim(SuperGetMV("MV_RELACNT", .F., ""))
    Local cPass     := AllTrim(SuperGetMV("MV_RELPSW", .F., ""))
    Local cSrvFull  := AllTrim(SuperGetMV("MV_RELSERV", .F., ""))
    Local cServer   := ""
    Local cUser     := ""
    Local cLog      := ""
    Local lRet      := .T.
    Local oMsg      := Nil
    Local oSrv      := Nil

    Default cPara      := ""
    Default cAssunto   := ""
    Default cCorpo     := ""
    Default aAnexos    := {}
    Default lMostraLog := .F.
    Default lUsaTLS    := .T.

    If Empty(cPara) .Or. Empty(cAssunto) .Or. Empty(cCorpo)
        cLog += "Destinatario, assunto ou corpo do e-mail nao informado." + CRLF
        lRet := .F.
    EndIf

    If lRet .And. (Empty(cFrom) .Or. Empty(cPass) .Or. Empty(cSrvFull) .Or. At("@", cFrom) == 0)
        cLog += "Configure MV_RELACNT, MV_RELPSW e MV_RELSERV para o envio SMTP." + CRLF
        lRet := .F.
    EndIf

    If lRet
        cServer := IIf(":" $ cSrvFull, SubStr(cSrvFull, 1, At(":", cSrvFull) - 1), cSrvFull)
        nPort   := IIf(":" $ cSrvFull, Val(SubStr(cSrvFull, At(":", cSrvFull) + 1)), 587)
        cUser   := SubStr(cFrom, 1, At("@", cFrom) - 1)

        oMsg := TMailMessage():New()
        oMsg:Clear()
        oMsg:cFrom    := cFrom
        oMsg:cTo      := cPara
        oMsg:cSubject := cAssunto
        oMsg:cBody    := cCorpo

        For nAtual := 1 To Len(aAnexos)
            If File(aAnexos[nAtual])
                nRet := oMsg:AttachFile(aAnexos[nAtual])
                If nRet < 0
                    cLog += "Nao foi possivel anexar " + aAnexos[nAtual] + "." + CRLF
                EndIf
            Else
                cLog += "Arquivo de anexo nao encontrado: " + aAnexos[nAtual] + "." + CRLF
            EndIf
        Next nAtual

        oSrv := TMailManager():New()
        If lUsaTLS
            oSrv:SetUseTLS(.T.)
        EndIf

        nRet := oSrv:Init("", cServer, cUser, cPass, 0, nPort)
        If nRet <> 0
            cLog += "Falha ao inicializar SMTP: " + oSrv:GetErrorString(nRet) + CRLF
            lRet := .F.
        EndIf

        If lRet
            oSrv:SetSMTPTimeout(nTimeOut)
            nRet := oSrv:SMTPConnect()
            If nRet <> 0
                cLog += "Falha na conexao SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                lRet := .F.
            EndIf
        EndIf

        If lRet
            nRet := oSrv:SmtpAuth(cFrom, cPass)
            If nRet <> 0
                cLog += "Falha na autenticacao SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                lRet := .F.
            EndIf
        EndIf

        If lRet
            nRet := oMsg:Send(oSrv)
            If nRet <> 0
                cLog += "Falha ao enviar e-mail: " + oSrv:GetErrorString(nRet) + CRLF
                lRet := .F.
            EndIf
        EndIf

        If ValType(oSrv) == "O"
            oSrv:SMTPDisconnect()
            FreeObj(oSrv)
        EndIf
        If ValType(oMsg) == "O"
            FreeObj(oMsg)
        EndIf
    EndIf

    If !Empty(cLog)
        ConOut("GEnvMail - " + cLog)
        If lMostraLog .And. !IsBlind()
            MsgAlert(cLog, "Envio de e-mail")
        EndIf
    EndIf

    RestArea(aArea)
Return lRet
