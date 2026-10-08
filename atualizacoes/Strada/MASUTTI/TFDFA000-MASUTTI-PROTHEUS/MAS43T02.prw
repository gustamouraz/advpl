#INCLUDE "TOTVS.CH"

/*
{Protheus.doc} User Function MAS43T02
@TELA PARA OS TIPOS DE MODAIS. 
@Daniel Victor da Rosa
@since 02/04/2024
*/
User Function MAS43T02()

    Local aArea      := FWGetArea()
    Local cDelOk   := ".T."
    Local cFunTOk  := ".T." 
  
    AxCadastro('ZNA', 'Cadastro de Modais', cDelOk, cFunTOk)
  
    FWRestArea(aArea)
Return
