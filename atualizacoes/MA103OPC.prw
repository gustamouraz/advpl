#Include "Protheus.ch"

/*/{Protheus.doc} MA103OPC
Inclui a acao de ajuste de arredondamento do valor bruto no Documento de Entrada.

@type  user function
@return array, opcoes adicionais do menu
/*/
User Function MA103OPC()
    Local aOpcoes := {}

    // Opcao 2 = Visualizar. A rotina trabalha sobre o documento ja gravado.
    If SuperGetMV("MV_ZM103OP",.F.,.F.) .And. (U_LMUSRPAR(.F.) .Or. FWIsAdmin())
        AAdd(aOpcoes, { "Ajustar Vlr. Bruto", "U_LMALTVLR()", 0, 2, 0, Nil })
    EndIf

Return aOpcoes
