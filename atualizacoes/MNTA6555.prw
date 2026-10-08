
  #include "Protheus.ch"

  User Function MNTA6555()

      Local aArea     := GetArea()
      Local aAreaSTP  := STP->(GetArea())
      Local lConfirm  := PARAMIXB[1]
      Local nOpc      := PARAMIXB[2]
      Local cFilRef   := ""
      Local cFilSTP   := ""
      Local cChaveSTP := ""

      // Somente exclusão confirmada
      If !lConfirm .Or. nOpc != 5
          Return
      EndIf

      /*
       * Não utilizar ST9->T9_FILIAL, pois o bem compartilhado
       * possui filial física em branco.
       */
      If Type("M->TQN_FILORI") == "C" .And. !Empty(M->TQN_FILORI)
          cFilRef := M->TQN_FILORI
      ElseIf Type("M->TQN_FILIAL") == "C" .And. !Empty(M->TQN_FILIAL)
          cFilRef := M->TQN_FILIAL
      ElseIf Type("cFilAnt") == "C"
          cFilRef := cFilAnt
      EndIf

      /*
       * xFilial aplicará corretamente o compartilhamento da STP:
       * - STP compartilhada: filial em branco;
       * - STP exclusiva: filial operacional.
       */
      cFilSTP := xFilial("STP", cFilRef)

      cChaveSTP := cFilSTP             +;
                   M->TQN_FROTA        +;
                   DToS(M->TQN_DTABAS) +;
                   M->TQN_HRABAS

      DbSelectArea("STP")
      DbSetOrder(5)

      If DbSeek(cChaveSTP) .And. !STP->(Deleted())

          If RecLock("STP", .F.)
            MsgInfo(;
              "Registro histórico (STP) localizado." + CRLF +;
              "Filial: "   + STP->TP_FILIAL + CRLF +;
              "Bem: "      + STP->TP_CODBEM + CRLF +;
              "Data: "     + DToC(STP->TP_DTLEITU) + CRLF +;
              "Hora: "     + STP->TP_HORA + CRLF +;
              "Recno: "    + cValToChar(STP->(Recno())),;
              "MNTA6555")
              DbDelete()
              MsUnlock("STP")

          Else

              MsgStop(;
                  "Não foi possível bloquear o registro da STP para exclusão.",;
                  "Exclusão do apontamento")

          EndIf

      EndIf

      RestArea(aAreaSTP)
      RestArea(aArea)

  Return
