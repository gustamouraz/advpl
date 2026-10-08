#Include "PROTHEUS.CH"

/*/{Protheus.doc} ZPGCA010
Abre as perguntas de filtro antes de executar o programa padrao PGCA010.
O ponto de entrada NFCFILTSC devolve o conteudo de cZPGCA010Filter.
@type  User Function
/*/
User Function ZPGCA010()

   Local cSrv := "N"
   Local cUrg := "N"
   Public cZPGCA010Filter := ""

   // Grupo SX1 cadastrado com as perguntas de Servicos e Urgentes.
   If !Pergunte("NFCFILTSC", .T.)
      Return
   EndIf

   cSrv := PGCA010A(MV_PAR01)
   cUrg := PGCA010A(MV_PAR02)

   cZPGCA010Filter := PGCA010F(cSrv, cUrg)

   ConOut("ZPGCA010 - filtro selecionado: " + cZPGCA010Filter)

   PGCA010()

Return


Static Function PGCA010A(cAnswer)

   Local cValue := Upper(AllTrim(cAnswer))

   // O SX1 informado possui as opcoes Sim/Nao. Mantem compatibilidade
   // tambem com cadastros que retornem diretamente S/N.
   If Left(cValue, 1) == "S"
      Return "S"
   EndIf

Return "N"


Static Function PGCA010F(cSrv, cUrg)

   Local cFilter := ""

   // Servico: S = somente servicos; N = sem restricao por tipo.
   If cSrv == "S"
      cFilter := 'UPPER(C1_XSERVI)=="S"'
   EndIf

   // Urgente: S = somente urgentes; N = sem restricao por urgencia.
   If cUrg == "S"
      If !Empty(cFilter)
         cFilter += " .AND. "
      EndIf

      cFilter += 'UPPER(C1_YURGENT)=="S"'
   EndIf

Return cFilter
