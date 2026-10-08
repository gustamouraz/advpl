#INCLUDE "PROTHEUS.CH"

User Function OGX008IT()
    Local cAliasNJM    := PARAMIXB[1]
    Local aLinha       := PARAMIXB[2]
    Local lRemFutOrdem := PARAMIXB[3]
    FwAlertError("ALERT","OGX008IT")

    // O fonte padrao deixa C6_OPER vazio especificamente nos subtipos 44 e 46.
    If lRemFutOrdem .And. !Empty((cAliasNJM)->NJM_OPEFIS)
        OGXSetOper(@aLinha, (cAliasNJM)->NJM_OPEFIS)
    EndIf

Return aLinha

Static Function OGXSetOper(aLinha, cOperacao)
    Local nPosOper := AScan(aLinha, {|x| AllTrim(x[1]) == "C6_OPER"})
    Local nPosTes  := AScan(aLinha, {|x| AllTrim(x[1]) == "C6_TES"})

    If nPosOper > 0
        aLinha[nPosOper][2] := cOperacao
    ElseIf nPosTes > 0
        // Mantem C6_OPER antes de C6_TES, como no fonte padrao OGX008.
        AIns(aLinha, nPosTes)
        aLinha[nPosTes] := {"C6_OPER", cOperacao, Nil}
    Else
        AAdd(aLinha, {"C6_OPER", cOperacao, Nil})
    EndIf

Return
