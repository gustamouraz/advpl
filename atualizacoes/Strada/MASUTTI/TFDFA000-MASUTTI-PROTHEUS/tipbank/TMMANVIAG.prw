#Include 'Totvs.ch'

/*/{Protheus.doc} TMMANVIAG
Ponto de entrada para validar o piso minimo do frete no fechamento da viagem
@type user function
@author Iago Tramontin
@since 25/06/2026
/*/
User Function TMMANVIAG()
	Local lRet := .T. // Por padrão, permite a operação
	Local aAreas  := {Getarea(), DTR->(GetArea()), DA3->(GetArea()), SA2->(GetArea())}
	Local lValidaPropria := SuperGetMv("MV_XVLDPRP",,.F.)
    Local cFroVei := ''

	DTR->(DbSetOrder(1))
	If DTR->(DbSeek(DTQ->DTQ_FILIAL+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
		cFrovei := Posicione("DA3", 1, xFilial("DA3") + DTR->DTR_CODVEI, "DA3_FROVEI")

		If cFrovei == '1'
			// Frota própria não tem como ser TAC.
			If lValidaPropria
				If Empty(DTR->DTR_CIOT)
					FWAlertError("Ciot da viagem não informado", "Atenção")
					lRet := .F.
				Endif
			Endif
		ElseIf cFrovei $ '23'
            If SA2->(MsSeek(xFilial("SA2")+ DTR->DTR_CODFOR+DTR->DTR_LOJFOR ))
			    If SA2->A2_ZTAC $ '123' .and. Empty(DTR->DTR_CIOT)
				    FWAlertError("Ciot da viagem não informado", "Atenção")
				    lRet := .F.
                Endif
			Endif
		Endif
	Endif

	AEval(aAreas,{|x| RestArea(x) })
Return lRet
