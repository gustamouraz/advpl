#Include "PROTHEUS.CH"

/*/{Protheus.doc} NFCFILTSC
Monta o filtro das solicitacoes de compra a partir das escolhas do usuario.
@type User Function
/*/
User Function NFCFILTSC()

   Local cFilter := ""
   Local lServico := .F.
   Local lUrgente := .F.

   lServico := FWAlertYesNo("Filtrar apenas solicitacoes de servico?", ;
                             "Filtro de Solicitacoes de Compra")

   lUrgente := FWAlertYesNo("Filtrar apenas solicitacoes urgentes?", ;
                             "Filtro de Solicitacoes de Compra")

   If lServico
      cFilter := 'UPPER(C1_XSERVI)=="S"'
   EndIf

   If lUrgente
      If !Empty(cFilter)
         cFilter += " .AND. "
      EndIf

      cFilter += 'UPPER(C1_YURGENT)=="S"'
   EndIf

Return cFilter
