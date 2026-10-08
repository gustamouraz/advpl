#INCLUDE "PROTHEUS.CH"

// ///// EXEMPLO DA CHAMADA DA ROTINA
// User Function ACEXEMPLO()

// Local _aMensagem := {}

// aAdd( _aMensagem, "MENSAGEM 01 "  )
// aAdd( _aMensagem, "MENSAGEM 02 "  )
// aAdd( _aMensagem, "MENSAGEM 03 "  )
// aAdd( _aMensagem, "MENSAGEM 04 "  )

// // ARRAY COM 4 MENSAGENS NO MÁXIMO E O TEMPO PARA FICAR NA TELA
// U_ACSHWMSG(_aMensagem, 5 )

// Return 

User Function ACSHWMSG(_aMsg, _nTime)

Local oDlg, oMainWnd, oTimer
Local _nX := 0
Local _cLinha1 := ""
Local _cLinha2 := ""
Local _cLinha3 := ""
Local _cLinha4 := ""

Default _nTime := 10

If _nTime < 0 
    _nTime := 10
EndIf

_nTot := Iif( Len(_aMsg) < 4, Len(_aMsg), 4 ) 

    For _nX := 1 to _nTot
        &("_cLinha"+cValToChar(_nX)) := _aMsg[_nX]
    Next _nX 

	DEFINE MSDIALOG oDlg FROM  100,100 TO 275,580 TITLE "Avisos - Masutti" PIXEL STYLE DS_MODALFRAME OF oMainWnd   
	@ 05,015 TO 63,230 LABEL "" OF oDlg  PIXEL
	oTimer:= TTimer():New(_nTime,{|| oDlg:End() },oDlg)
	oTimer:Activate()

    @ 014,025 SAY  _cLinha1 SIZE 180,8 OF oDlg PIXEL
    @ 024,025 SAY  _cLinha2 SIZE 180,8 OF oDlg PIXEL
    @ 034,025 SAY  _cLinha3 SIZE 180,8 OF oDlg PIXEL
    @ 044,025 SAY  _cLinha4 SIZE 180,8 OF oDlg PIXEL
	
	ACTIVATE MSDIALOG oDlg VALID (oTimer:End(),.T.) CENTERED

Return 
