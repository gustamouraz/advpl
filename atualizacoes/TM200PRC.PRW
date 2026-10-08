#Include "Protheus.ch"

/*/{Protheus.doc} TM200PRC
Converte para Normal as viagens Planejadas criadas automaticamente pelo
calculo de frete (TMSA200V) para os documentos do lote processado.

O PE TM200PRC e chamado por TMSA200Prc apos o calculo do frete. ParamIxb:
1 - Filial de origem; 2 - Lote; 3 - Resultado do processamento;
4 - Recalculo; 5 - Indicador de impressao.
/*/
User Function TM200PRC()

    Local aParam    := ParamIxb
    Local aArea     := GetArea()
    Local aAreaDTQ  := DTQ->(GetArea())
    Local cFilOri   := ""
    Local cLote     := ""
    Local cAliasQry := ""
    Local cQuery    := ""
    Local lSucesso  := .F.

    If ValType(aParam) <> "A" .Or. Len(aParam) < 3
        Return Nil
    EndIf

    cFilOri  := IIf(ValType(aParam[1]) == "C", aParam[1], "")
    cLote    := IIf(ValType(aParam[2]) == "C", aParam[2], "")
    lSucesso := IIf(ValType(aParam[3]) == "L", aParam[3], .F.)

    If !lSucesso .Or. Empty(cFilOri) .Or. Empty(cLote)
        Return Nil
    EndIf

    // A TMSA200V relaciona os documentos da viagem na DM3. Busca as viagens
    // planejadas cujos documentos pertencem ao lote que acabou de ser calculado.
    cQuery := " SELECT DISTINCT DM3.DM3_FILORI, DM3.DM3_VIAGEM "
    cQuery += " FROM " + RetSqlName("DM3") + " DM3 "
    cQuery += " INNER JOIN " + RetSqlName("DT6") + " DT6 ON "
    cQuery += " DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
    cQuery += " AND DT6.DT6_FILDOC = DM3.DM3_FILDOC "
    cQuery += " AND DT6.DT6_DOC    = DM3.DM3_DOC "
    cQuery += " AND DT6.DT6_SERIE  = DM3.DM3_SERIE "
    cQuery += " AND DT6.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSqlName("DTQ") + " DTQ ON "
    cQuery += " DTQ.DTQ_FILIAL = '" + xFilial("DTQ") + "' "
    cQuery += " AND DTQ.DTQ_FILORI = DM3.DM3_FILORI "
    cQuery += " AND DTQ.DTQ_VIAGEM = DM3.DM3_VIAGEM "
    cQuery += " AND DTQ.DTQ_TIPVIA = '3' "
    cQuery += " AND DTQ.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE DM3.DM3_FILIAL = '" + xFilial("DM3") + "' "
    cQuery += " AND DM3.DM3_FILORI = '" + cFilOri + "' "
    cQuery += " AND DM3.D_E_L_E_T_ = ' ' "
    cQuery += " AND DT6.DT6_LOTNFC = '" + cLote + "' "
    cQuery := ChangeQuery(cQuery)

    cAliasQry := GetNextAlias()
    DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T.)

    DTQ->(DbSetOrder(2)) // DTQ_FILIAL + DTQ_FILORI + DTQ_VIAGEM
    While (cAliasQry)->(!Eof())
        If DTQ->(MsSeek(xFilial("DTQ") + (cAliasQry)->DM3_FILORI + (cAliasQry)->DM3_VIAGEM)) .And. ;
                DTQ->DTQ_TIPVIA == StrZero(3, Len(DTQ->DTQ_TIPVIA))
            RecLock("DTQ", .F.)
                DTQ->DTQ_TIPVIA := StrZero(1, Len(DTQ->DTQ_TIPVIA)) // Normal
            MsUnlock()
        EndIf
        (cAliasQry)->(DbSkip())
    EndDo

    (cAliasQry)->(DbCloseArea())
    RestArea(aAreaDTQ)
    RestArea(aArea)

Return Nil
