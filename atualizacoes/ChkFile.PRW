#INCLUDE "Protheus.ch"

/* */

User Function ChkFile()
   	TmsTriggLog()
Return Nil

Static Function TmsTriggLog()

Local  cTabela   := PARAMIXB[1]
Local  cAlias    := PARAMIXB[2]

If cAlias == 'SC1'
 	//-- C1_QUANT
     FldSetTrigger(C1_QUANT,8192 + 16384 + 32768,{|X,Y,Z| u_TmststLog(x,y,z,"SC1")})
EndIf

/*If cAlias == 'SC8'
 	//-- C8_CC
     FldSetTrigger(C8_CC,8192 + 16384 + 32768,{|X,Y,Z| u_TmststLog(x,y,z,"C8_NUM")})
EndIf	*/

Return Nil


//-- FunÃ§Ã£o chamada pelo BLoco da Trigger (FldSetTrigger)
User Function TmsTstLog(cCampo, nModo, cTipReg, cAlias)
Local nCodInsert := 8192
Local nCodAlter  := 16384
Local nCodDelete := 32768
Local cTransc    := Iif( nModo == nCodDelete, '<DEL>', Iif( nModo == nCodInsert, '<INS>', '<ALT>'))

//TmsRepTrac(ProcName(4) +  " ||| Oper : " + cTransc + " ||| DTP_FILORI+DTP_LOTNFC: " +DTP->(DTP_FILORI+ "/" + DTP_LOTNFC) + " ||| DTP_STATUS: " + DTP->DTP_STATUS ,.T.) 
TmsRepTrac("("+AllToChar(ProcLine(1))+")" +;
  " <== " + ProcName(2) + "("+AllToChar(ProcLine(2))+")" +;
  " <== " + ProcName(3) + "("+AllToChar(ProcLine(3))+")" +;
  " <== " + ProcName(4) + "("+AllToChar(ProcLine(4))+")" +;
  " <== " + ProcName(5) + "("+AllToChar(ProcLine(5))+")" +;
  " <== " + ProcName(6) + "("+AllToChar(ProcLine(6))+")" +;
  " <== " + ProcName(7) + "("+AllToChar(ProcLine(7))+")" +;
  " <== " + ProcName(8) + "("+AllToChar(ProcLine(8))+")" +;
  " <== " + ProcName(9) + "("+AllToChar(ProcLine(9))+")" +;
  " <== " + ProcName(10) + "("+AllToChar(ProcLine(10))+")" +;
  " <== " + ProcName(11) + "("+AllToChar(ProcLine(11))+")" +;
  " <== " + ProcName(12) + "("+AllToChar(ProcLine(12))+")" +;
  " <== " + ProcName(13) + "("+AllToChar(ProcLine(13))+")" +;
  " <== " + ProcName(14) + "("+AllToChar(ProcLine(14))+")" +;
  " <== " + ProcName(15) + "("+AllToChar(ProcLine(15))+")" +;
  " <== " + ProcName(16) + "("+AllToChar(ProcLine(16))+")" +;
  " <== " + ProcName(17) + "("+AllToChar(ProcLine(17))+")" +;
  " <== " + ProcName(18) + "("+AllToChar(ProcLine(18))+")" +;
  " <== " + ProcName(19) + "("+AllToChar(ProcLine(19))+")" +;
  " <== " + ProcName(20) + "("+AllToChar(ProcLine(20))+")" +;
  " <== " + ProcName(21) + "("+AllToChar(ProcLine(21))+")" +;
  " <== " + ProcName(22) + "("+AllToChar(ProcLine(22))+")" +;
  " <== " + ProcName(23) + "("+AllToChar(ProcLine(23))+")" +;
  " <== " + ProcName(24) + "("+AllToChar(ProcLine(24))+")" +;
  " <== " + ProcName(25) + "("+AllToChar(ProcLine(25))+")" +;
  " <== " + ProcName(26) + "("+AllToChar(ProcLine(26))+")" +;
  " <== " + ProcName(27) + "("+AllToChar(ProcLine(27))+")" +;
  " <== " + ProcName(28) + "("+AllToChar(ProcLine(28))+")" +;
  " <== " + ProcName(29) + "("+AllToChar(ProcLine(29))+")" +;
  " <== " + ProcName(30) + "("+AllToChar(ProcLine(30))+")" +;
  " <== " + ProcName(31) + "("+AllToChar(ProcLine(31))+")" +;
  " <== " + ProcName(32) + "("+AllToChar(ProcLine(32))+")" +;
  " <== " + ProcName(33) + "("+AllToChar(ProcLine(33))+")" +;
  " <== " + ProcName(34) + "("+AllToChar(ProcLine(34))+")" +;
  " <== " + ProcName(35) + "("+AllToChar(ProcLine(35))+")" +;
  " <== " + ProcName(36) + "("+AllToChar(ProcLine(36))+")" +;
  " <== " + ProcName(37) + "("+AllToChar(ProcLine(37))+")" +;
  " <== " + ProcName(38) + "("+AllToChar(ProcLine(38))+")" +;
  " <== " + ProcName(39) + "("+AllToChar(ProcLine(39))+")" +;
  " <== " + ProcName(40) + "("+AllToChar(ProcLine(40))+")" +;
  " ||| Oper : " + cTransc + " ||| "+cCampo+": " +AllToChar((cAlias)->&(cCampo)) + ;
  " ||| (recno): " + AllTrim(AllToChar((cAlias)->(Recno()))) ;
  ,.T.,"LOG_C1_QUANT") 
Return Nil

//log gera na pasta SYSTEM
