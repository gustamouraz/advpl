#Include "Protheus.ch"
/*
@Autor:     André Claro
@Data:      20/10/2025
@Descrição:
            LOCALIZAÇÃO : Function A170POINT() - Responsável por gerar as solicitações de compra.
            EM QUE PONTO : Apos a gravacao do SC1, que é a ultima, todos os outros arquivos ja foram atualizados.

            Está posicionado na SC1.
*/

User Function MT170SC1()
Local _aArea := GetArea()
Local _aAreaSC1 := SC1->(GetArea())
Local _lAtivo := SuperGetMV("MV_ZEXSCPP", .F., .T.) .And. FindFunction("U_ACVLPCOSC")
Local _lRet := .T.
Local _lIntPCO := FindFunction("U_ACVLDPCO")
Local _lAprSC := FindFunction("U_ACATC1APR")
Local _cCusto := "2105"
Local _cCstDsc := AllTrim(Posicione("CTT",1,xFilial("CTT")+_cCusto,"CTT_DESC01"))
Local _cFilial := SC1->C1_FILIAL
Local _cNumSC := SC1->C1_NUM
Local _cItemSC := SC1->C1_ITEM
Local _nRecSC1 := SC1->(RECNO())
Local _cAprov := ""

//Valida orçamento após a geração da SC. Se não tem orçamento, mantém a SC bloqueada para aprovação.
If _lAtivo
    If !U_ACVLPCOSC(_cFilial, _cNumSC, _cItemSC)
        SC1->(DbGoTo(_nRecSC1))
        If SC1->(RECNO()) == _nRecSC1
            If  SC1->(Reclock("SC1",.F.))
                    SC1->C1_OBS   := "Sem Saldo Orçamentário | "+Alltrim(SC1->C1_OBS)
                    SC1->C1_APROV := "B"
                SC1->(MsUnLock())
            EndIf
        EndIf
    Else

        aAdd(_aRelat, { SC1->C1_FILIAL,SC1->C1_NUM, SC1->C1_ITEM,  SC1->C1_PRODUTO, SC1->C1_QUANT, "", "", 0, "SC gerada com sucesso!" } )
        // INTEGRA O PCO
        If _lIntPCO
            U_ACVLDPCO(SC1->C1_FILIAL, SC1->C1_NUM, 1 , .T. )//Chamada da integração do PCO pelas SCs
            U_ACVLDPCO(SC1->C1_FILIAL, SC1->C1_NUM, 1 , .F. )//Chamada da integração do PCO pelas SCs
        EndIf
    EndIf
EndIf

RestArea(_aAreaSC1)
RestArea(_aArea)

/// Ajuste para preencher os campos base da SC por ponto de pedido - Luiz Moura - 05/05/2026
DbSelectArea("SC1")
SC1->(DbGoTo(_nRecSC1))
If SC1->(RECNO()) == _nRecSC1 .And. SC1->(Reclock("SC1",.F.))
    SC1->C1_APROV   := "B"
    SC1->C1_ZAPLDIR := "S"
    SC1->C1_CC      := _cCusto
    SC1->C1_YDESCCC := _cCstDsc

    If Posicione("SB1",1,xFilial("SB1")+SC1->C1_PRODUTO,"B1_TIPO") == 'SV'
        SC1->C1_XSERVI := "S"
    Else
        SC1->C1_XSERVI := "N"
    EndIf
    SC1->(MsUnLock())
EndIf

If _lAprSC
    U_ACATC1APR(_cFilial, _cNumSC)
EndIf

DbSelectArea("SC1")
SC1->(DbGoTo(_nRecSC1))
If SC1->(RECNO()) == _nRecSC1 .And. Empty(AllTrim(SC1->C1_ZUSRAPR))
    _cAprov := fMT170Apr(_cFilial, _cNumSC)
    If !Empty(_cAprov) .And. SC1->(Reclock("SC1",.F.))
        SC1->C1_ZUSRAPR := _cAprov
        SC1->(MsUnLock())
    EndIf
EndIf

Return  _lRet

Static Function fMT170Apr(_cFilial, _cNumSC)
Local _cAlias := GetNextAlias()
Local _cRet := ""
Local _cFilQry := "%" + ValToSql(_cFilial) + "%"
Local _cNumQry := "%" + ValToSql(_cNumSC) + "%"

BeginSql Alias _cAlias
    %noparser%
    SELECT TOP 1
        RTRIM(CAST(REPLACE((
            SELECT RTRIM(ISNULL(ZX2.ZX2_GESTOR,'')) + '#'
            FROM %table:SC1% SC1 WITH(NOLOCK)
            INNER JOIN %table:ZX2% ZX2 WITH(NOLOCK)
                    ON ZX2.ZX2_FILIAL = SC1.C1_FILIAL
                   AND ZX2.ZX2_CC = SC1.C1_CC
                   AND ZX2.ZX2_APROVA = 'S'
                   AND ZX2.ZX2_EMAIL <> ''
                   AND ZX2.D_E_L_E_T_ = ''
            INNER JOIN %table:CTT% CTT WITH(NOLOCK)
                    ON CTT.CTT_FILIAL = %exp:xFilial("CTT")%
                   AND CTT.CTT_CUSTO = SC1.C1_CC
                   AND CTT.D_E_L_E_T_ = ''
            WHERE SC1.D_E_L_E_T_ = ''
              AND SC1.C1_FILIAL = %exp:_cFilQry%
              AND SC1.C1_NUM = %exp:_cNumQry%
            FOR XML PATH('')
        ), '#', ',') AS VARCHAR(240))) AS APROVADORES
EndSql

If Select(_cAlias) > 0
    If (_cAlias)->(!Eof())
        _cRet := AllTrim((_cAlias)->APROVADORES)
    EndIf
    (_cAlias)->(DbCloseArea())
EndIf

Return _cRet
