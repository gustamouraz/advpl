#INCLUDE "Totvs.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} TMA310GRV
Ponto de entrada para validar o piso minimo do frete no fechamento da viagem
@type user function
@author Iago Tramontin
@since 23/06/2026
/*/
User Function TMA310GRV()
	Local lRet           := .T.
	Local nOpcx          := PARAMIXB[1]
	Local cFilOri        := PARAMIXB[2]
	Local cViagem        := PARAMIXB[3]
	Local cFrovei        := ''
	Local lValidaPropria := SuperGetMv("MV_XVLDPRP",,.F.)
	Local lTac           := .F.
	Local cChave         := fChave()
	Local cCgcContratante:= SM0->M0_CGC
	Local cErro          := ''
	Local nValMin        := 0
	Local aAreas  := {Getarea(), DTR->(GetArea()), DA3->(GetArea()), SA2->(GetArea())}
	Local nValFre := 0

	If nOpcx == 3
		DTR->(DbSetOrder(1))
		If DTR->(DbSeek(DTQ->DTQ_FILIAL+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))

			cFrovei := Posicione("DA3", 1, xFilial("DA3") + DTR->DTR_CODVEI, "DA3_FROVEI")

			If Empty(cFrovei)
				FWAlertError("Frota do veículo não identificada", "Atenção")
				lRet := .F.
			Else
				If cFrovei == '1'
					// Frota própria não tem como ser TAC.
					If lValidaPropria
						nValMin := fValMinFrt(cChave, cCgcContratante, @cErro)

						If !Empty(cErro)
							FWAlertError(cErro, "Atenção")
							lRet := .F.
						ElseIf nValMin > 0
							DVW->(DbSetOrder(1))
							If DVW->(DbSeek(DTQ->DTQ_FILIAL+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM+'02'))
								If DVW->DVW_VALOR < nValMin
									FWAlertError('Valor do frete não atingiu o piso mínimo de ' + cValToChar(nValMin), "Atenção")
									lRet := .F.
								Endif
							Else
								If DTR->DTR_VALFRE < nValMin
									FWAlertError('Valor do frete não atingiu o piso mínimo de ' + cValToChar(nValMin), "Atenção")
									lRet := .F.
								Endif
							EndIf
						Endif
					Endif

				ElseIf cFrovei $ '23'
					If SA2->(MsSeek(xFilial("SA2")+ DTR->DTR_CODFOR+DTR->DTR_LOJFOR ))

						If SA2->A2_ZTAC $ '123'
							nValMin := fValMinFrt(cChave, cCgcContratante, @cErro)

							If !Empty(cErro)
								FWAlertError(cErro, "Atenção")
								lRet := .F.
							ElseIf nValMin > 0
								nValFre := RetValFre()

								If nValFre > 0
									If nValFre < nValMin
										FWAlertError('Valor do frete do contrato carreteiro ' + cValToChar(nValFre) +' não atingiu o piso mínimo de ' + cValToChar(nValMin), "Atenção")
										lRet := .F.
									Endif
								Else
									DVW->(DbSetOrder(1))
									If DVW->(DbSeek(DTQ->DTQ_FILIAL+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM+'02'))
										If DVW->DVW_VALOR < nValMin
											FWAlertError('Valor do frete não atingiu o piso mínimo de ' + cValToChar(nValMin), "Atenção")
											lRet := .F.
										Endif
									Else
										If DTR->DTR_VALFRE < nValMin
											FWAlertError('Valor do frete não atingiu o piso mínimo de ' + cValToChar(nValMin), "Atenção")
											lRet := .F.
										Endif
									EndIf
								Endif
							Endif

						ElseIf Empty(SA2->A2_ZTAC)
							lTac := fConsuTac(cChave, cCgcContratante, SA2->A2_RNTRC, SA2->A2_CGC, @cErro)

							If !Empty(cErro)
								FWAlertError(cErro, "Atenção")
								lRet := .F.
							ElseIf lTac
								nValMin := fValMinFrt(cChave, cCgcContratante, @cErro)

								If !Empty(cErro)
									FWAlertError(cErro, "Atenção")
									lRet := .F.
								ElseIf nValMin > 0

									// REPLIQUEI A VALIDAÇÃO DO CONTRATO AQUI
									nValFre := RetValFre()

									If nValFre > 0
										If nValFre < nValMin
											FWAlertError('Valor do frete do contrato carreteiro ' + cValToChar(nValFre) +' não atingiu o piso mínimo de ' + cValToChar(nValMin), "Atenção")
											lRet := .F.
										Endif
									Else
										DVW->(DbSetOrder(1))
										If DVW->(DbSeek(DTQ->DTQ_FILIAL+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM+'02'))
											If DVW->DVW_VALOR < nValMin
												FWAlertError('Valor do frete não atingiu o piso mínimo de ' + cValToChar(nValMin), "Atenção")
												lRet := .F.
											Endif
										Else
											If DTR->DTR_VALFRE < nValMin
												FWAlertError('Valor do frete não atingiu o piso mínimo de ' + cValToChar(nValMin), "Atenção")
												lRet := .F.
											Endif
										EndIf
									Endif
									// FIM DA REPLICAÇÃO

								Endif
							Endif
						Endif
					Else
						FWAlertError("Fornecedor proprietário do veículo terceiro não encontrado!", "Atenção")
						lRet := .F.
					Endif
				Else
					FWAlertError("Tipo de frota do veículo (" + cFrovei + ") é inválido.", "Atenção")
					lRet := .F.
				EndIf
			EndIf
		EndIf
	Endif

	AEval(aAreas,{|x| RestArea(x) })

Return lRet


/*/{Protheus.doc} fConsuTac
    (long_description)
    @type  Static Function
    @author Iago Tramontin
    @since 23/06/2026
/*/
Static Function fConsuTac(cChave, cCgcContra, cRNTRC, cCgcCtado, cErro)
	Local cJson         := ""
	Local cJsonRet      := ""
	Local cError        := ""
	Local cWarning      := ""
	Local oRest         := Nil
	Local oXmlRet       := Nil
	Local lRet          := .F.
	Local cUrl := SuperGetMV("MV_XAPTPFT",,"https://appslab.marketpay.com.br/hwsconvenio/")
	Local aHeader := {}

	oRest := FWRest():New(cUrl)
	oRest:SetPath("resources/consultaSituacaoTransportador/")

	Aadd(aHeader, "Content-Type:application/xml")

	//Preparo json de envio
	cJson := "<situacaoTransportador>"
	cJson += "     <chave>"            + AllTrim(cChave) +    "</chave>"
	cJson += "     <cnpjContratante>"  + AllTrim(cCgcContra) + "</cnpjContratante>"
	cJson += "     <cnpj>"             + AllTrim(cCgcCtado) +     "</cnpj>"
	cJson += "     <rntrc>"            + AllTrim(cRNTRC) +  "</rntrc>"
	cJson += "</situacaoTransportador>"

	// seto a string Json
	oRest:SetPostParams(cJson)

	If oRest:Post(aHeader)

		cJsonRet :=  oRest:GetResult()

		if !Empty(cJsonRet)

			oXmlRet := XmlParser( cJsonRet, "_", @cError, @cWarning )

			If XmlChildEx(oXmlRet, "_RETORNOSITUACAOTRANSPORTADOR") != Nil
				If XmlChildEx(oXmlRet:_RETORNOSITUACAOTRANSPORTADOR, "_TRANSPORTADOR") != Nil
					If XmlChildEx(oXmlRet:_RETORNOSITUACAOTRANSPORTADOR:_TRANSPORTADOR, "_MSG") != Nil
						If Upper(Alltrim(oXmlRet:_RETORNOSITUACAOTRANSPORTADOR:_TRANSPORTADOR:_MSG:TEXT)) == 'SUCESSO'
							If Upper(Alltrim(oXmlRet:_RETORNOSITUACAOTRANSPORTADOR:_TRANSPORTADOR:_TIPO:TEXT)) == 'TAC'
								If RecLock('SA2',.F.)
									If Upper(Alltrim(oXmlRet:_RETORNOSITUACAOTRANSPORTADOR:_TRANSPORTADOR:_EQUIPARADOTAC:TEXT)) == 'TRUE'
										SA2->A2_ZTAC := '2'
									Else
										SA2->A2_ZTAC := '1'
									Endif
									SA2->(MsUnlock())
								EndIf
								lRet := .T.
							ElseIf Upper(Alltrim(oXmlRet:_RETORNOSITUACAOTRANSPORTADOR:_TRANSPORTADOR:_TIPO:TEXT)) == 'ETC'
								If RecLock('SA2',.F.)
									SA2->A2_ZTAC := '3'
									SA2->(MsUnlock())
								EndIf
								lRet := .T.
							Else
								cErro := 'Não foi possível identificar se é TAC ou ETC, verifique o cadastro do fornecedor ' + cCgcCtado
							Endif
						Else
							cErro := 'Não foi possível identificar se é TAC ou ETC, verifique o cadastro do fornecedor ' + cCgcCtado
						Endif
					Else
						cErro := 'Não foi possível identificar se é TAC ou ETC, verifique o cadastro do fornecedor ' + cCgcCtado
					EndIf
				ElseIf XmlChildEx(oXmlRet:_RETORNOSITUACAOTRANSPORTADOR, "_MSG") != Nil
					cErro := oXmlRet:_RETORNOSITUACAOTRANSPORTADOR:_MSG:TEXT
				Else
					cErro := 'Não foi possível identificar se é TAC ou ETC, verifique o cadastro do fornecedor ' + cCgcCtado
				Endif

			Endif
		Endif
	Endif
Return lRet

/*/{Protheus.doc} fChave
    (long_description)
    @type  Static Function
    @author Iago Tramontin
    @since 23/06/2026
/*/
Static Function fChave()
	Local cJson         := ""
	Local cJsonRet      := ""
	Local cError        := ""
	Local cWarning      := ""
	Local oRest         := Nil
	Local oXmlRet       := Nil
	Local cUrl :=  AllTrim(SuperGetMV("MV_XAPTPFT",,"https://appslab.marketpay.com.br/hwsconvenio/"))
	Local cUserAut := Alltrim(SuperGetMv("MV_XUSETIP",,"masutti"))
	Local cPswAut := Alltrim(SuperGetMv("MV_XPSWTIP",,"Qgxu2tUZ"))
	Local aHeader := {}
	Local cChave := ''

	Aadd(aHeader, "Content-Type:application/xml")

	oRest := FWRest():New(cUrl)
	oRest:SetPath("resources/autenticacaoViagem/")

	cJson := "<autenticacao>"
	cJson += "     <usuario>"  + cUserAut +"</usuario>"
	cJson += "     <senha>"    + cPswAut  +"</senha>"
	cJson += "</autenticacao>"

	oRest:SetPostParams(cJson)

	If oRest:Post(aHeader)

		cJsonRet :=  oRest:GetResult()

		if !Empty(cJsonRet)

			oXmlRet := XmlParser( cJsonRet, "_", @cError, @cWarning )

			//Pego retorno do json
			cChave  := Alltrim(oXmlRet:_RETORNOAUTENTICACAO:_CHAVE:TEXT)

		Endif
	Endif

Return cChave


/*/{Protheus.doc} fValMinFrt
    Verifica o valor minimo do frete
    @type  Static Function
    @author Iago Tramontin
    @since 23/06/2026
*/
Static Function fValMinFrt(cChave, cCgcContra, cErro)
    Local cJson         := ""
	Local cJsonRet      := ""
	Local cError        := ""
	Local cWarning      := ""
	Local oRest         := Nil
	Local oXmlRet       := Nil
    Local cUrl :=  AllTrim(SuperGetMV("MV_XAPTPFT",,"https://appslab.marketpay.com.br/hwsconvenio/"))
    Local aHeader := {}
    Local nKmRota := 0
	Local nVal := 0

    nKmRota := Posicione('DA8', 1, xFilial("DA8") + DTQ->DTQ_ROTA, "DA8_KMTIP")

    oRest := FWRest():New(cUrl)
	oRest:SetPath("resources/pisofrete/")

    Aadd(aHeader, "Content-Type:application/xml")

	cJson := "<obterPisoFrete>"
    cJson += "     <chave>"                + cChave +                          "</chave>"
    cJson += "     <cnpjContratante>"      + cCgcContra +                      "</cnpjContratante>"
    cJson += "     <distanciaTotal>"       + cValToChar(nKmRota)  +            "</distanciaTotal>"
    cJson += "     <rota>"                 + ''  +                             "</rota>"
    cJson += "     <cidadeOrigem>"         + ''  +                             "</cidadeOrigem>"
    cJson += "     <cidadeDestino>"        + ''  +                             "</cidadeDestino>"
	If !Empty(DTR->DTR_CODRB1)
    	cJson += "     <composicaoVeicular>"   + 'S'  +                            "</composicaoVeicular>"
    Else
    	cJson += "     <composicaoVeicular>"   + 'N'  +                            "</composicaoVeicular>"
	Endif
	cJson += "     <altoDesempenho>"       + 'N'  +                            "</altoDesempenho>"
    cJson += "     <tipoCarga>"            + '01'  +                           "</tipoCarga>"
    cJson += "     <retornoVazio>"         + 'N'  +                            "</retornoVazio>"
    cJson += "     <eixos>"                + cValToChar(DTR->DTR_QTDEIX)  +    "</eixos>"
	cJson += "</obterPisoFrete>"

	oRest:SetPostParams(cJson)

    If oRest:Post(aHeader)

        cJsonRet :=  oRest:GetResult()

        if !Empty(cJsonRet)

            oXmlRet := XmlParser( cJsonRet, "_", @cError, @cWarning )

            if At("<valorPisoFrete>",cJsonRet) > 0

				cValor := oXmlRet:_RETORNOPISOFRETE:_VALORES:_VALOR:_VALORPISOFRETE:TEXT
				nVal := Val(Stuff(cValor, Len(cValor)-(Val(oXmlRet:_RETORNOPISOFRETE:_VALORES:_VALOR:_PRECISAOPISOFRETE:TEXT)-1), 0, '.'))

            else
                cErro   := "Erro "+ oXmlRet:_RETORNOPISOFRETE:_MENSAGEM:TEXT
            Endif
        endif

    endif

Return nVal

/*/{Protheus.doc} RetValFre
    Verifica o valor do contrato carreteiro, se tiver
    @type  Static Function
    @author Iago Tramontin
    @since 25/06/2026
/*/
Static Function RetValFre()
	Local cQry      := ""
	Local nValFre   := 0

	cQry := " SELECT"
	cQry += "   SUM(DTY_VALFRE) VALFRE"
	cQry += " FROM " + RETSQLNAME("DTY") + " DTY"
	cQry += " WHERE DTY.D_E_L_E_T_ = ' '"
	cQry += "   AND DTY.DTY_FILIAL = '" + xFilial("DTY")  + "'"
	cQry += "   AND DTY.DTY_FILORI = '" + DTQ->DTQ_FILORI + "'"
	cQry += "   AND DTY.DTY_VIAGEM = '" + DTQ->DTQ_VIAGEM + "'"

	cQry := ChangeQuery(cQry)

	If Select("QDTY") > 0
		QDTY->(DbCloseArea())
	Endif

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "QDTY", .F., .T.)

	If QDTY->(!EOF())
		If !Empty(QDTY->VALFRE)
			nValFre := QDTY->VALFRE
		Endif
	Endif

	QDTY->(DbCloseArea())

Return nValFre
