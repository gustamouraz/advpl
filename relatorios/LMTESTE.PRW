#include "REPORT.CH"
#include "PROTHEUS.CH"    
#include "TOPCONN.CH"    
#Include 'FWMVCDef.ch'

User Function LMTESTE()

Local _aMensagem := {}

    aAdd( _aMensagem, "!!! ATENÇÃO !!!")
    aAdd( _aMensagem, "Para romaneios com Form. Próprio = Sim")
    aAdd( _aMensagem, "É NECESSÁRIO TRANSMITIR")
    aAdd( _aMensagem, "Outras Ações > Sped Nfe")
    U_ACSHWMSG(_aMensagem, 10 )

Return
