#include "protheus.ch"

/*/{Protheus.doc} RVFMNT
Retorna o status da manutencao posicionada na STF (SIGAMNT / MNTA120).
Retorno: "4"=Inativa(cinza)  "3"=Atrasada(vermelho)  "2"=A vencer(amarelo)  "1"=Em dia(verde)
/*/
User Function RVFMNT()
    Local aArea  := GetArea()
    Local lOk    := .F.
    Local nAcum  := 0
    Local nMeta  := 0
    Local nFalta := 0
    Local nVarDia := 0
    Local dUltAc := dDataBase
    Local dProx  := dDataBase

    // A inatividade nao pode ser sobrescrita pelas demais condicoes.
    If STF->TF_ATIVO == "N"
        Return "4"
    EndIf

    dbSelectArea("ST9")
    ST9->(dbSetOrder(1)) // T9_FILIAL + T9_CODBEM
    lOk := ST9->(dbSeek(xFilial("ST9") + STF->TF_CODBEM))
    If lOk
        dUltAc  := ST9->T9_DTULTAC
        nVarDia := ST9->T9_VARDIA
        nAcum   := ST9->T9_CONTACU
        nMeta   := STF->TF_CONMANU + STF->TF_INENMAN
        nFalta  := nMeta - nAcum
    EndIf
    RestArea(aArea)

    // Sem acompanhamento ou sem variacao diaria nao ha como projetar a data.
    If !lOk .Or. Empty(dUltAc) .Or. nVarDia <= 0
        Return "1"
    EndIf

    // Proxima manutencao = ((meta - acumulado) / variacao dia) + ultimo acompanhamento.
    dProx := dUltAc + ((nMeta - nAcum) / nVarDia)
    If dProx < SToD("18991231")
        dProx := SToD("18991231")
    EndIf

    Do Case
        Case dProx < dDataBase
            Return "3" // Atrasada: data projetada ja venceu.
        Case nFalta <= STF->TF_TOLECON
            Return "2" // A vencer: dentro da tolerancia do contador.
    EndCase

Return "1"
