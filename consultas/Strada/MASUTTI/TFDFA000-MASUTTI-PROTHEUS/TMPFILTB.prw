#Include 'TOTVS.CH'

/*/{Protheus.doc} nomeFunction
(long_description)
@type user function
@author user
@since 29/05/2024
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function tpmfiltb()

	rpcsetenv('01','010101')

	Local aArea := ZA1->(GetArea())
  Local aArea2 := DT6->(GetArea())

	If RecLock('ZA1',.T.)

    ZA1->ZA1_FILIAL := xFilial("DT6")
		ZA1->ZA1_FILDOC := '020106'
		ZA1->ZA1_CTEDOC:= '001599'
		ZA1->ZA1_CTESER:= '5'
		ZA1->ZA1_CANCEL:= 'N'
		ZA1->ZA1_STATUS:= ''
		ZA1->ZA1_FILDCE:= '010101'
		ZA1->ZA1_DOCENT:= '001599'
		ZA1->ZA1_SERENT:= '5'
		ZA1->ZA1_FORNEC:= '000507'
		ZA1->ZA1_LOJA:= '1'

		ZA1->(MsUnlock())
	EndIf

	RestArea(aArea)

	rpcclearenv()

Return
