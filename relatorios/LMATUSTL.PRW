#Include "Protheus.ch"
#Include "TopConn.ch"

// Mantem os vinculos de Compras nos insumos da Ordem de Servico (STL).
// SC: grava a SC gerada a partir da SA.
// NF: grava a NF vinculada ao pedido e a SC.
User Function LMATUSTL(cEvento, cFilSTL, cNumero, cItem, cDoc, cSerie)

// SC: U_LMATUSTL("SC", filial, numSA, itemSA, numSC, itemSC)
// NF: U_LMATUSTL("NF", filial, docNF, serieNF, fornecNF, lojaNF)

    Do Case
    Case (cEvento) == "SC"
        // cNumero/cItem = SA; cDoc/cSerie = SC.
        fSTLPorSA(cFilSTL, cNumero, cItem, cDoc, cSerie)
    Case (cEvento) == "NF"
        // cNumero/cItem/cDoc/cSerie = doc/serie/fornecedor/loja da NF.
        fSTLPorNF(cFilSTL, cNumero, cItem, cDoc, cSerie)
    EndCase

Return Nil

Static Function fSTLPorSA(cFilSTL, cNumSA, cItemSA, cNumSC, cItemSC)

    Local cAlias := GetNextAlias()

    If Empty(cFilSTL) .Or. Empty(cNumSA) .Or. Empty(cItemSA) .Or. Empty(cNumSC)
        Return Nil
    EndIf

    BeginSql Alias cAlias
        %noparser%
        SELECT STL.R_E_C_N_O_ AS RECSTL
          FROM %table:STL% STL
         WHERE STL.D_E_L_E_T_ = ''
           AND STL.TL_FILIAL  = %exp:cFilSTL%
           AND STL.TL_NUMSA   = %exp:cNumSA%
           AND STL.TL_ITEMSA  = %exp:cItemSA%
    EndSql

    While (cAlias)->(!Eof())
        DbSelectArea("STL")
        STL->(DbGoTo((cAlias)->RECSTL))
        If STL->(RecNo()) == (cAlias)->RECSTL .And. STL->(RecLock("STL", .F.))
            STL->TL_NUMSC := cNumSC
            STL->TL_ITEMSC := cItemSC
            STL->(MsUnlock())
        EndIf
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())

Return Nil

Static Function fSTLPorNF(cFilSTL, cDoc, cSerie, cFornec, cLoja)

    Local cAlias := GetNextAlias()

    If Empty(cFilSTL) .Or. Empty(cDoc)
        Return Nil
    EndIf

    BeginSql Alias cAlias
        %noparser%
        SELECT DISTINCT SC7.C7_FILIAL, SC7.C7_NUMSC, SC7.C7_ITEMSC
          FROM %table:SD1% SD1
         INNER JOIN %table:SC7% SC7
            ON SC7.C7_FILIAL = SD1.D1_FILIAL
           AND SC7.C7_NUM    = SD1.D1_PEDIDO
           AND SC7.C7_ITEM   = SD1.D1_ITEMPC
           AND SC7.D_E_L_E_T_ = ''
         WHERE SD1.D_E_L_E_T_ = ''
           AND SD1.D1_FILIAL  = %exp:cFilSTL%
           AND SD1.D1_DOC     = %exp:cDoc%
           AND SD1.D1_SERIE   = %exp:cSerie%
           AND SD1.D1_FORNECE = %exp:cFornec%
           AND SD1.D1_LOJA    = %exp:cLoja%
           AND SC7.C7_NUMSC <> ''
    EndSql

    While (cAlias)->(!Eof())
        fSTLPorSC((cAlias)->C7_FILIAL, (cAlias)->C7_NUMSC, (cAlias)->C7_ITEMSC, cDoc, cSerie, cFornec, cLoja)
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())

Return Nil

Static Function fSTLPorSC(cFilSTL, cNumSC, cItemSC, cDoc, cSerie, cFornec, cLoja)

    Local cAlias := GetNextAlias()

    BeginSql Alias cAlias
        %noparser%
        SELECT STL.R_E_C_N_O_ AS RECSTL
          FROM %table:STL% STL
         WHERE STL.D_E_L_E_T_ = ''
           AND STL.TL_FILIAL  = %exp:cFilSTL%
           AND STL.TL_NUMSC   = %exp:cNumSC%
           AND STL.TL_ITEMSC  = %exp:cItemSC%
    EndSql

    While (cAlias)->(!Eof())
        DbSelectArea("STL")
        STL->(DbGoTo((cAlias)->RECSTL))
        If STL->(RecNo()) == (cAlias)->RECSTL .And. STL->(RecLock("STL", .F.))
            STL->TL_NOTFIS := cDoc
            STL->TL_SERIE := cSerie
            STL->TL_FORNEC := cFornec
            STL->TL_LOJA := cLoja
            STL->(MsUnlock())
        EndIf
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())

Return Nil
