#include "protheus.ch"
#include "parmtype.ch"

/*/{Protheus.doc} OGX008PV
Ponto de entrada para complementar e validar o pedido de venda gerado pelo
romaneio na rotina OGX008.
@author Willian Kaneta
@since 26/08/2019
@version 1.1
@type function
/*/
User Function OGX008PV()
    Local aCab        := AClone(ParamIxb[1])
    Local aItens      := AClone(ParamIxb[2])
    Local cXNatur     := Posicione("NN7", 1, xFilial("NN7") + NJJ->NJJ_CODCTR, "NN7_NATURE")
    Local nPosNaturez := AScan(aCab, {|x| AllTrim(x[1]) == "C5_NATUREZ"})
    Local cNaturez    := ""

    If Empty(cXNatur)
        cXNatur := Posicione("SB1", 1, xFilial("SB1") + NJM->NJM_CODPRO, "B1_XNAT")
    EndIf

    // A regra do contrato/produto tem prioridade sobre a natureza original.
    If !Empty(cXNatur)
        cNaturez := AllTrim(cXNatur)
    ElseIf nPosNaturez > 0
        cNaturez := AllTrim(aCab[nPosNaturez][2])
    EndIf

    // Apenas orienta o usuario; a natureza deve ser cadastrada na regra do
    // contrato (NN7_NATURE) ou no cadastro do produto (SB1->B1_XNAT).
    If Empty(cNaturez) .Or. Empty(Posicione("SED", 1, FWxFilial("SED") + cNaturez, "ED_CODIGO"))
        FWAlertError("Natureza Financeira nao informada. Preencha a natureza na regra do contrato (NN7_NATURE) ou no cadastro do produto (B1_XNAT) e confirme o romaneio novamente.", "Natureza Financeira obrigatoria")
        Return {{}, {}}
    EndIf

    OGX008PVSetCampo(@aCab, "C5_NATUREZ", cNaturez)

    // Campos adicionais da customizacao original.
    OGX008PVSetCampo(@aCab, "C5_ESPECI1", NJJ->NJJ_XESPEC)
    OGX008PVSetCampo(@aCab, "C5_VOLUME1", NJJ->NJJ_XVOLUM)
    OGX008PVSetCampo(@aCab, "C5_PESOL"  , NJJ->NJJ_PSLIQU)
    OGX008PVSetCampo(@aCab, "C5_PBRUTO" , NJJ->NJJ_PSSUBT)
    OGX008PVSetCampo(@aCab, "C5_MENNOTA", NJJ->NJJ_MSGNFS)
    OGX008PVSetCampo(@aCab, "C5_XCTRPAI", NJJ->NJJ_XCTPAI)

    /*
       Antecipacao da mesma validacao do M410LIOK. U_ACZGHACES recebe o
       CFOP, obtido da TES, e exibe a mensagem de acesso restrito antes do
       Mata410 retornar a inconsistencia generica de linha.
    */
    If !OGX008PVVldAcessoCfop(aItens)
        Return {{}, {}}
    EndIf

Return {aCab, aItens}

Static Function OGX008PVVldAcessoCfop(aItens)
    Local nItem   := 0
    Local nPosTes := 0
    Local cTes    := ""
    Local cCfop   := ""

    // Mesma condicao de ativacao utilizada no M410LIOK.
    If !SuperGetMV("MV_ZVLCFNF", .F., .T.)
        Return .T.
    EndIf

    For nItem := 1 To Len(aItens)
        nPosTes := AScan(aItens[nItem], {|x| AllTrim(x[1]) == "C6_TES"})

        If nPosTes > 0
            cTes  := AllTrim(aItens[nItem][nPosTes][2])
            cCfop := AllTrim(Posicione("SF4", 1, FWxFilial("SF4") + cTes, "F4_CF"))

            // Mantem o mesmo contrato de chamada do M410LIOK.
            If !Empty(cCfop) .And. !U_ACZGHACES(cCfop)
                Return .F.
            EndIf
        EndIf
    Next nItem

Return .T.

Static Function OGX008PVSetCampo(aCab, cCampo, uValor)
    Local nPos := AScan(aCab, {|x| AllTrim(x[1]) == cCampo})

    If nPos > 0
        aCab[nPos][2] := uValor
    Else
        AAdd(aCab, {cCampo, uValor, Nil})
    EndIf

Return
