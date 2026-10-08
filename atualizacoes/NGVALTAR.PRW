#Include "Protheus.ch"

/*/{Protheus.doc} NGVALTAR
Ponto de entrada para validar tarefas na Alteracao de O.S. (MNTA265).

Permite utilizar tarefas genericas da TT9 em qualquer O.S. de plano,
sem exigir o vinculo da tarefa na manutencao (ST5).

As tarefas utilizadas devem ter a caracteristica Preventiva ou Todos.
@type function
/*/
User Function NGVALTAR()
    Local cTarefa   := ""
    Local cPreChave := ""
    Local lRet      := .F.

    If ValType(PARAMIXB) == "A"
        cTarefa   := IIf(Len(PARAMIXB) >= 1 .And. ValType(PARAMIXB[1]) == "C", PARAMIXB[1], "")
        cPreChave := IIf(Len(PARAMIXB) >= 2 .And. ValType(PARAMIXB[2]) == "C", PARAMIXB[2], "")
    EndIf

    If MNTOSGlb()
        lRet := MNTValGlb(cTarefa)
    Else
        // Mantem a regra padrao nas demais rotinas e tipos de O.S.
        lRet := NGSTLTAR(cPreChave, cTarefa)
    EndIf

Return lRet

/*/{Protheus.doc} NGTROCF3
Ponto de entrada que define a consulta F3 do campo de tarefa.

Na Alteracao de O.S., apresenta as tarefas genericas da TT9, em vez
das tarefas vinculadas a manutencao (ST5).
@type function
/*/
User Function NGTROCF3()
    Local cAlias := "ST5"

    If MNTOSGlb()
        cAlias := "TT9"
    EndIf

Return cAlias

/*/{Protheus.doc} MNTOSGlb
Indica se a execucao corresponde a uma O.S. de plano na MNTA265.
@type function
/*/
Static Function MNTOSGlb()
    Local lRet := .F.

    If IsInCallStack("MNTA265") .And. Select("STJ") > 0
        lRet := AllTrim(STJ->TJ_PLANO) <> "000000"
    EndIf

Return lRet

/*/{Protheus.doc} MNTValGlb
Valida uma tarefa generica disponivel para O.S. preventiva.
@type function
/*/
Static Function MNTValGlb(cTarefa)
    Local aArea  := GetArea()
    Local lRet   := .F.
    Local cTar   := PadR(AllTrim(cTarefa), TamSX3("TT9_TAREFA")[1])

    If Empty(AllTrim(cTarefa))
        RestArea(aArea)
        Return .T.
    EndIf

    DbSelectArea("TT9")
    TT9->(DbSetOrder(1)) // TT9_FILIAL + TT9_TAREFA

    If TT9->(MsSeek(FWxFilial("TT9") + cTar)) .And. !TT9->(Deleted())
        // 1 = Preventiva / 4 = Todos
        lRet := TT9->TT9_CARACT $ "1/4"
    EndIf

    RestArea(aArea)

Return lRet
