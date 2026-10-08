#INCLUDE "TOTVS.CH"

/*
{Protheus.doc} User Function MAS43T03
@TELA PARA OS TIPOS DE OPERAÇÕES. 
@Daniel Victor da Rosa
@since 02/04/2024
*/
User Function MAS43T03()

    Local aArea      := FWGetArea()
    Local cDelOk   := ".T."
    Local cFunTOk  := ".T." 

    AxCadastro('ZNB', 'Cadastro de Operações', cDelOk, cFunTOk)

    FWRestArea(aArea)
Return
