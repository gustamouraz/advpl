#INCLUDE 'PROTHEUS.CH'


/*/{Protheus.doc} MT103NTZ
@description Ponto de Entrada que obtem a Natureza Financeira a ser usada para geração de Titulos
da Nota Fiscal de Entrada.
@author    DBIT - Helitom Silva
@since     30/10/2018
@version   1.0
@return    lRet, Logico, Se .t. os campo snão podem ser alterados

/*/
User Function MT103NTZ()
	Local aArea  	:= GetArea()
	Local cRet      := ''
	Local cZEPNat   := ''
	Local cNaturAtu := ParamIXB[1]
	Local nPedido	:= Ascan(aHeader,{|x| Upper(Alltrim(x[2])) == "D1_PEDIDO" })
	
	If nPedido > 0	
		
		dbSelectArea("ZEP")
		ZEP->(dbSetOrder(1))
		ZEP->(dbGoTop())
		If ZEP->(dbSeek(xFilial("ZEP") + aCols[1, nPedido]))
		    cZEPNat := ZEP->ZEP_NATURE
		EndIf
		
	EndIf
	
	If Empty(cZEPNat) .AND. !Empty(SF1->F1_XNATURE) .AND. Empty(cNaturAtu)
		cZEPNat := SF1->F1_XNATURE
	EndIf
	
	If !Empty(cZEPNat)
		cRet := cZEPNat 	
	ElseIf Empty(cZEPNat) .and. .not. Empty(cNaturAtu)
		cRet := cNaturAtu 
	Else
		cRet := Space(TamSX3('E2_NATUREZ')[1])
	EndIf

	IF IsInCallStack('U_PROCDOCE') .OR. IsInCallStack("U_MAS43P01")
		cRet := cNatZNC
	ENDIF
	
	RestArea(aArea)	

	
Return cRet
