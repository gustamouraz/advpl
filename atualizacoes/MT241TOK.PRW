#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} MT241TOK
Validação na confirmação da movimentação interna mod 2
@author Wendel Barreto
@since 26/02/2024
@version 1.0
/*/

User Function MT241TOK()
    Local lRet := .T.
    Local aArea := GetArea()

     
    IF DA241DATA > dDatabase
        MSGINFO("Data de inclusão da movimentação diferente da data atual","PE MT241TOK")
        lRet := .F.
    ENDIF
    
    Return lRet
