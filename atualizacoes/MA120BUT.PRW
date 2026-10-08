#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

/*/{Protheus.doc} MA120BUT
Ponto de entrada para adicionar botoes nas acoes relacionadas do pedido de compras
@author 
@since 
@version 1.0
/*/

user function MA120BUT()

	Local aButtons	:=	{}
	
	If ExistBlock("MACO01WA")
		aadd(aButtons,{"BUDGETY", {|| ExecBlock( "MACO01WA", .F., .F. )},"Parcelas","Parcelas"})
	EndIf 

	If ExistBlock("MSCO002D")
		If !AtIsRotina("MSCO002D")
			aadd(aButtons,{"BMPORD1", {|| ExecBlock( "MSCO002D",.F.,.F.,1)},"Lead Time","Lead Time"})
		Endif	
	EndIf 

	If ExistBlock("LMFPEC01")
		If !AtIsRotina("LMFPEC01")
			aadd(aButtons,{"BUDGETY", {|| ExecBlock( "LMFPEC01",.F.,.F.,1)},"Pecuária","Pecuária"})
		Endif	
	EndIf 
	
return aButtons
