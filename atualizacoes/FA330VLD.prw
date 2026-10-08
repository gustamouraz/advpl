#Include "Totvs.Ch"
#Include "Protheus.Ch"
#Include "TopConn.Ch"
#Include "RwMake.Ch"

User Function FA330VLD()

	Local lRetorno := .T.
	Local aArea    := GetArea()
	Local nTit     := 0
	Local cQuery   := ""


	dbSelectArea("Z40")
	dbSetOrder(1)
	dbGoTop()

	If AllTrim( Z40->Z40_ATIVO ) == "S" .And. AllTrim( Z40->Z40_INTFIN ) == "S"
		If AllTrim( SE1->E1_TIPO ) == "RA"
			cQuery := "SELECT E5_RECONC FROM " + RetSqlName("SE5") + " AS SE5 WITH (NOLOCK) "
			cQuery += "WHERE E5_FILIAL = '" + xFilial("SE5") + "' "
			cQuery += "AND E5_PREFIXO = '" + SE1->E1_PREFIXO + "' "
			cQuery += "AND E5_NUMERO = '" + SE1->E1_NUM + "' "
			cQuery += "AND E5_PARCELA = '" + SE1->E1_PARCELA + "' "
			cQuery += "AND E5_TIPO = '" + SE1->E1_TIPO + "' "
			cQuery += "AND E5_CLIFOR = '" + SE1->E1_CLIENTE + "' "
			cQuery += "AND E5_LOJA = '" + SE1->E1_LOJA + "' "
			cQuery += "AND SE5.D_E_L_E_T_ = ' ' "

			TCQuery cQuery New Alias "TMPSE5"
			dbSelectArea("TMPSE5")
			dbGoTop()

			If !TMPSE5->( Eof() )
				If Empty( TMPSE5->E5_RECONC )
					Aviso( "FA330VLD", "Integracao XRT Ativo, nao e permitida a compensacao de RA sem que esteja conciliada no XRT!", {"Ok"}, 1)
					lRetorno := .F.
				EndIf
			Else
				Aviso( "FA330VLD", "Integracao XRT Ativo, titulo nao encontrado na movimentacao bancaria, favor abrir chamado!", {"Ok"}, 1)
				lRetorno := .F.
			EndIf

			TMPSE5->( dbCloseArea() )
		Else
			For nTit := 1 To Len( aTitulos )
				If aTitulos[nTit][08]
					If AllTrim( aTitulos[nTit][04] ) == "RA"
						cQuery := "SELECT E5_RECONC FROM " + RetSqlName("SE5") + " AS SE5 WITH (NOLOCK) "
						cQuery += "WHERE E5_FILIAL = '" + xFilial("SE5") + "' "
						cQuery += "AND E5_PREFIXO = '" + aTitulos[nTit][01] + "' "
						cQuery += "AND E5_NUMERO = '" + aTitulos[nTit][02] + "' "
						cQuery += "AND E5_PARCELA = '" + aTitulos[nTit][03] + "' "
						cQuery += "AND E5_TIPO = '" + aTitulos[nTit][04] + "' "
						cQuery += "AND E5_CLIFOR + E5_LOJA = '" + aTitulos[nTit][10] + "' "
						cQuery += "AND SE5.D_E_L_E_T_ = ' ' "

						TCQuery cQuery New Alias "TMPSE5"
						dbSelectArea("TMPSE5")
						dbGoTop()

						If !TMPSE5->( Eof() )
							If Empty( TMPSE5->E5_RECONC )
								Aviso( "FA330VLD", "Integracao XRT Ativo, nao e permitida a compensacao de RA sem que esteja conciliada no XRT!", {"Ok"}, 1)
								lRetorno := .F.
							EndIf
						Else
							Aviso( "FA330VLD", "Integracao XRT Ativo, titulo nao encontrado na movimentacao bancaria, favor abrir chamado!", {"Ok"}, 1)
							lRetorno := .F.
						EndIf

						TMPSE5->( dbCloseArea() )
					EndIf
				EndIf
			Next
		EndIf
	EndIf

	lRetorno := lRetorno .And. fValidTit(aTitulos)

	If lRetorno .And. SuperGetMV("MV_ZLMVFIL",.F.,.F.)
		lRetorno := lRetorno .And. LMVALFIL()
	EndIf

	RestArea( aArea )

Return lRetorno

Static Function LMVALFIL()

	Local lRt
	Local nZ
	Local aFil := {}

	For nZ := 1 To Len(aTitulos)
		aAdd(aFil, AllTrim(aTitulos[nZ][16]))
	Next nZ

	If !(aScan(aFil, AllTrim(SE1->E1_FILIAL)) > 0)
		MsgStop("Para compensar esse titulo entre pela filial " + AllTrim(SE5->E5_FILIAL) + ".", "FA330VLD")
		lRt := .F.
	Else
		lRt := .T.
	EndIf

Return lRt

Static Function fValidTit( _aTitulos )

	Local lRet      := .T.
	Local nA        := 1
	Local nPosComp  := 9
	Local nPosMark  := 8
	Local nPosLimit := 0
	Local aTotTit   := {}
	Local cChave    := ""
	Local cMsgInfo  := ""
	Local nValorCmp := 0
	Local nValorLim := 0
	Local nPosTit   := 0

	If Empty(_aTitulos)
		Return lRet
	EndIf

	nPosLimit := IIF(Len(_aTitulos[1]) > 29, 25, 22)

	For nA := 1 To Len(_aTitulos)
		If Len(_aTitulos[nA]) < nPosLimit
			Loop
		EndIf

		If !_aTitulos[nA][nPosMark]
			Loop
		EndIf

		nValorCmp := fStrToVal(_aTitulos[nA][nPosComp])
		nValorLim := fStrToVal(_aTitulos[nA][nPosLimit])
			
		If SuperGetMV("MV_X330VLD", .F., .F.)

			If nValorCmp > nValorLim
				cMsgInfo += "O valor a compensar de R$ " + AllTrim(Transform(nValorCmp, "@E 999,999,999,999.99"))
				cMsgInfo += " e maior que o limite de compensacao de R$ " + AllTrim(Transform(nValorLim, "@E 999,999,999,999.99"))
				cMsgInfo += " na linha " + CValToChar(nA) + "."
				MsgStop(cMsgInfo, "FA330VLD")
				lRet := .F.
				Exit
			EndIf

			cChave := fTitKey(_aTitulos[nA])
			nPosTit := aScan(aTotTit, {|aItem| aItem[1] == cChave})

			If nPosTit == 0
				aAdd(aTotTit, {cChave, nValorCmp, nValorLim, nA})
			Else
				aTotTit[nPosTit][2] += nValorCmp

				If aTotTit[nPosTit][2] > aTotTit[nPosTit][3]
					cMsgInfo := "O total a compensar para o titulo da linha " + CValToChar(aTotTit[nPosTit][4])
					cMsgInfo += " atingiu R$ " + AllTrim(Transform(aTotTit[nPosTit][2], "@E 999,999,999,999.99"))
					cMsgInfo += ", acima do limite de compensacao de R$ " + AllTrim(Transform(aTotTit[nPosTit][3], "@E 999,999,999,999.99"))
					cMsgInfo += ". Verifique linhas duplicadas do mesmo adiantamento/titulo."
					MsgStop(cMsgInfo, "FA330VLD")
					lRet := .F.
					Exit
				EndIf
			EndIf
		EndIf
	Next nA

Return lRet

Static Function fTitKey( aTitulo )

	Local cKey := ""
	Local cCliLoja := ""

	If Len(aTitulo) >= 10
		cCliLoja := AllTrim(aTitulo[10])
	EndIf

	cKey += IIf(Len(aTitulo) >= 1, AllTrim(aTitulo[1]), "")
	cKey += "|"
	cKey += IIf(Len(aTitulo) >= 2, AllTrim(aTitulo[2]), "")
	cKey += "|"
	cKey += IIf(Len(aTitulo) >= 3, AllTrim(aTitulo[3]), "")
	cKey += "|"
	cKey += IIf(Len(aTitulo) >= 4, AllTrim(aTitulo[4]), "")
	cKey += "|"
	cKey += cCliLoja

Return cKey

Static Function fStrToVal( _Valor )

	Local nValor := 0
	Local cValor := ""

	If ValType(_Valor) == "N"
		Return _Valor
	EndIf

	cValor := AllTrim(cValToChar(_Valor))
	cValor := StrTran(cValor, ".", "")
	cValor := StrTran(cValor, ",", ".")

	nValor := Val(cValor)

Return nValor
