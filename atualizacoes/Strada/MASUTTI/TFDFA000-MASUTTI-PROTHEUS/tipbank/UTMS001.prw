
#Include "Totvs.ch"
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} FwRestTipFrt
Metodos de integracao Rest com Tip Bank
@author Leandro Rodrigues
@since 03/04/2020
@version P12
@param nulo
@return nulo
/*/

Class IntegraTipFrete

	Data aHeadOut
	Data nTimeOut
	Data cApiTipFrete
	Data cPathAut
	Data cPathCadVi
	Data cPathRota
	Data cPathAutoriza
	Data cPathCRota
	Data cPathConVi
	Data cPathObtCusto
	Data cUserAut
	Data cPswAut
	Data Contratante

	Method New() Constructor		        // Metodo Construtor
	Method AutenticacaoTipFrete() 	     	// Metodo que faz autenticacao na TipFrete
	Method CadastraViagemTipFrete() 	   	// Metodo que faz cadastro da viagem na TipFrete
	Method ConsultaViagemTipFrete() 	   	// Metodo que consulta da viagem na TipFrete
	Method CadastraRotaTipFrete() 	    	// Metodo para cadastrar rota viagem na TipFrete
	Method ConsultaRotaTipFrete() 	    	// Metodo para Consultar rota viagem na TipFrete
	Method AutorizaViagemTipFrete() 	  	// Metodo para fazer a autorizadao da viagem na TipFrete
	Method CancelaViagemTipFrete() 	    	// Metodo para fazer o cancelamento da viagem na TipFrete
	Method ObterCustoPedagioTipFrete()		// Metodo para obter o valor do pedagio da viagem

EndClass

/*/{Protheus.doc} FwRestTipFrt
Construtor da Classe de Integracao Virtus
@author Leandro Rodrigues
@since 03/04/2020
@version P12
@param nulo
@return nulo
/*/

Method New() Class IntegraTipFrete

	Self:cApiTipFrete   := SuperGetMV("MV_XAPTPFT",,"https://appslab.marketpay.com.br/hwsconvenio/")
	Self:cUserAut		:= Alltrim(SuperGetMv("MV_XUSETIP",,"masutti"))
	Self:cPswAut		:= Alltrim(SuperGetMv("MV_XPSWTIP",,"Qgxu2tUZ"))
	Self:Contratante    := '02900972000400'//SM0->M0_CGC
	Self:aHeadOut		:= {}
	Self:nTimeOut		:= 15
	Self:cPathAut	    := "resources/autenticacaoViagem/"
	Self:cPathCadVi	    := "resources/cadastroViagemSec/"
	Self:cPathRota	    := "resources/criaRota/"
	Self:cPathCRota	    := "resources/consultaRota/"
	Self:cPathAutoriza  := "resources/autorizacaoCancelamentoViagemSec/"
	Self:cPathConVi     := "resources/consultaResgateViagemSec/"
	Self:cPathObtCusto  := "resources/pedagio/obtercusto/"

	Aadd(Self:aHeadOut,"Content-Type:application/xml")

Return()

/*/{Protheus.doc} RUTIL019
Metodo para fazer a autenticacao do acesso na TipFrete
@author Leandro Rodrigues
@since 03/03/2020
@version P12
@param Filtro
@return nulo
/*/

Method AutenticacaoTipFrete(cChave) Class IntegraTipFrete

	Local cJson         := ""
	Local cJsonRet      := ""
	Local cError        := ""
	Local cWarning      := ""
	Local oRest         := Nil
	Local oXmlRet       := Nil

//Instancia objeto de conexao
	oRest := FWRest():New(Self:cApiTipFrete)

// informo o path do metodo
	oRest:SetPath(Self:cPathAut)

//Preparo json de envio
	cJson := "<autenticacao>"
	cJson += "     <usuario>"  + Self:cUserAut +"</usuario>"
	cJson += "     <senha>"    + Self:cPswAut  +"</senha>"
	cJson += "</autenticacao>"

// seto a string Json
	oRest:SetPostParams(cJson)

	If oRest:Post(Self:aHeadOut)

		cJsonRet :=  oRest:GetResult()

		if !Empty(cJsonRet)

			oXmlRet := XmlParser( cJsonRet, "_", @cError, @cWarning )

			//Pego retorno do json
			cChave  := Alltrim(oXmlRet:_RETORNOAUTENTICACAO:_CHAVE:TEXT)

		Endif
	Endif

Return

/*/{Protheus.doc} RUTIL019
Metodo para fazer o Cadastro da Viagem na TipFrete
@author Leandro Rodrigues
@since 03/03/2020
@version P12
@param Filtro
@return nulo
/*/
Method CadastraViagemTipFrete(cChave,cLogError) Class IntegraTipFrete

	Local nQtdVol       := 0
	Local nVlrCarga     := 0
	Local nValFrete     := 0
	Local nPesoCarga    := 0
	Local cJson         := ""
	Local cJsonRet      := ""
	Local cError        := ""
	Local cWarning      := ""
	Local cNatCarga     := ""
	Local cDesProd      := ""
	Local cUnidade      := ""
	Local cDataInicio   := ""
	Local cDataFim      := ""
	Local cDataNasc     := ""
	Local cDtVenCnh     := ""
	Local lRet          := .T.
	Local cNumero       := "S/N"
	Local oRest         := Nil
	Local oXmlRet       := Nil
	Local cVersao       := SuperGetMv("MV_XVERXML",,"1.0.0")
	Local cTipoCarga    := SuperGetMv("MV_XTIPCAF",,"01")
	Local cModelo       := SuperGetMv("MV_XMODNFE",,"1")
	Local nPerToler     := SuperGetMv("MV_XTOLPED",,"025")
	Local cSequencia    := "001"
	Local cIdViagem     := ""
	Local _cCodUser := RetCodUsr()
	Local nA := 0
	Local aDocsCTES     := {}
	Local lTac := .F.
	Local cData := ''
	Local cFrovei := ''
	Local lValidaPropria := SuperGetMv("MV_XVLDPRP",,.F.)
	Local cErroTac := ''
	Local aDadosPedagio := {}
	Local nVlPedagio    := 0
	Local nPrcPedagio   := 0
	Local cAdmPdg := ''

	DTR->(DbSetOrder(1))
	DUP->(DbSetOrder(1))
	DA4->(DbSetOrder(1))
	DTA->(DbSetOrder(2))
	SA1->(DbSetOrder(1))
	DUD->(DbSetOrder(1))
	DTC->(DbSetOrder(1))
	SB1->(DbSetOrder(1))
	SA2->(DbSetOrder(1))
	DT6->(DbSetOrder(1))


//Valido se ja foi autorizado
	If ConsultaEnvio( ,@cSequencia,.T.)
		cLogError   := " ja foi autorizada, nao será possivel re-enviar !"
		lRet        := .F.
//Valido se viagem ja foi enviada alguma vez
	Elseif ConsultaEnvio( ,@cSequencia,.F.,@cIdViagem)

		If !MsgYesNo("Esta viagem ja foi enviada para Tip Bank, deseja Re-enviar")

			lRet := .F.

		Endif

	Endif

	If lRet

		//Instancia objeto de conexao
		oRest := FWRest():New(Self:cApiTipFrete)

		//informo o path do metodo
		oRest:SetPath(Self:cPathCadVi)

		//Posiciona no veiculo da viagem
		If DTR->(DbSeek(xFilial("DTR")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM ))

			//====================================================
			//Monta dados da viagem
			//====================================================
			If Empty(DTR->DTR_DATINI)

				cDataInicio := Substr(dTos(dDataBase),7,2) +Substr(dTos(dDataBase),5,2)+Substr(dTos(dDataBase),1,4)

			Else

				cDataInicio := Substr(dTos(DTQ->DTQ_DATGER),7,2) +Substr(dTos(DTQ->DTQ_DATGER),5,2)+Substr(dTos(DTQ->DTQ_DATGER),1,4)

			Endif

			//Valido se a data fim foi informada
			If Empty(DTR->DTR_DATFIM)

				cDataFim := DaySum( dDataBase , SuperGetMv("MV_XDIAFIM",,7)) //Defino um intervalo
				cDataFim := Substr(dTos(dDataBase),7,2) +Substr(dTos(dDataBase),5,2)+Substr(dTos(dDataBase),1,4)

			Else

				cDataFim    := Alltrim(Substr(dTos(DTR->DTR_DATFIM),7,2)+Substr(dTos(DTR->DTR_DATFIM),5,2)+Substr(dTos(DTR->DTR_DATFIM),1,4))

			Endif

			HoraInicio  := DTQ->DTQ_HORGER+"00"

			//Posiciono no cadastro da rota
			if Empty(DTR->DTR_CODFOR)

				cLogError   := "O campo Proprietario no complemento da viagem deve ser informado !"
				lRet        := .F.

			Elseif !DA8->(DbSeek(xFilial("DA8") + DTQ->DTQ_ROTA ))

				cLogError   := "Codigo da Rota na Tip Bank nao foi encontrado para Rota "+ Alltrim(DTQ->DTQ_ROTA) + "!"
				lRet := .F.

			endif

			if DA8->DA8_KMTIP == 0
				cLogError   := "O campo Km Da Viagem é obrigatório !"
				lRet        := .F.
			EndIf

			// If !lValidaPropria
			// 	cFrovei := Posicione("DA3", 1, xFilial("DA3") + DTR->DTR_CODVEI, "DA3_FROVEI")

			// 	If cFrovei $ '23'
			// 		If SA2->(MsSeek(xFilial("SA2")+ DTR->DTR_CODFOR+DTR->DTR_LOJFOR ))

			// 			If SA2->A2_ZTAC $ '12'
			// 				lTac := .T.
			// 			ElseIf SA2->A2_ZTAC == '3'
			// 				lTac := .F.
			// 			Else
			// 				lTac := fConsuTac(Self:cApiTipFrete, Self:aHeadOut, cChave, Self:Contratante, SA2->A2_RNTRC, SA2->A2_CGC, @cErroTac)

			// 				If !lTac
			// 					cLogError := cErroTac
			// 					lRet      := .F.
			// 				Else
			// 					lTac := SA2->A2_ZTAC $ '12'
			// 				Endif
			// 			Endif
			// 		Else
			// 			cLogError := "Fornecedor proprietário do veículo não encontrado!"
			// 			lRet      := .F.
			// 		Endif
			// 	Else
			// 		cLogError := "Veículo não configurado como terceiro (Frota atual: " + cFrovei + ")!"
			// 		lRet      := .F.
			// 	Endif
			// Else
			// 	cFrovei := Posicione("DA3", 1, xFilial("DA3") + DTR->DTR_CODVEI, "DA3_FROVEI")

			// 	If SA2->(MsSeek(xFilial("SA2")+ DTR->DTR_CODFOR+DTR->DTR_LOJFOR ))
			// 		If cFrovei == '1'
			// 			lTac := .F.
			// 		ElseIf cFrovei $ '23'
			// 			If SA2->A2_ZTAC $ '12'
			// 				lTac := .T.
			// 			ElseIf SA2->A2_ZTAC == '3'
			// 				lTac := .F.
			// 			Else
			// 				lTac := fConsuTac(Self:cApiTipFrete, Self:aHeadOut, cChave, Self:Contratante, SA2->A2_RNTRC, SA2->A2_CGC, @cErroTac)

			// 				If !Empty(cErroTac)
			// 					cLogError := cErroTac
			// 					lRet      := .F.
			// 				Else
			// 					lTac := SA2->A2_ZTAC $ '12'
			// 				Endif
			// 			Endif
			// 		Else
			// 			cLogError := "Verifique a frota do veiculo " + DTR->DTR_CODVEI + "!"
			// 			lRet      := .F.
			// 		Endif
			// 	Else
			// 		cLogError := "Fornecedor proprietário do veículo não encontrado!"
			// 		lRet      := .F.
			// 	Endif
			// Endif

			If DTQ->DTQ_STATUS != '5'
				cLogError := "Antes de enviar para TipBank é necessário fechar a viagem!"
				lRet      := .F.
			Endif

			If lRet

				cIdViagem := Alltrim(xFilial("DTR"))+DTQ->DTQ_VIAGEM+cSequencia //Alltrim(xFilial("DTR"))+cDocCte+cSequencia

				cJson := "<viagem>"
				cJson +=    "<versao>"                      + cVersao                       + "</versao>"
				cJson +=    "<chave>"                       + cChave                        + "</chave>"
				cJson +=    "<rota>"                        + AllTrim(DA8->DA8_XCODTP)      + "</rota>"

				If DA8->DA8_XPED = '1'
					cAdmPdg := Posicione('DA3', 1, xfilial('DA3')+DTR->DTR_CODVEI, 'DA3_ZADMPG')
					cJson +=    "<admPedagio>"                  + cAdmPdg                       + "</admPedagio>"
				EndIf

				cJson +=    "<distanciaTotal>"              + cValToChar(DA8->DA8_KMTIP)    + "</distanciaTotal>"
				cJson +=    "<eixos>"                       + cValToChar(DTR->DTR_QTDEIX)   + "</eixos>"
				cJson +=    "<cnpjContratante>"             + Self:Contratante              + "</cnpjContratante>"
				cJson +=    "<idSolicitacaoContratante>"    + cIdViagem                      + "</idSolicitacaoContratante>"
				cJson +=    "<dataSolicitacao>"             + cDataInicio+HoraInicio        + "</dataSolicitacao>"
				cJson +=    "<dataInicioFrete>"             + cDataInicio                   + "</dataInicioFrete>"
				cJson +=    "<dataFimFrete>"                + cDataFim                      + "</dataFimFrete>"
/*
            cJson := "<viagem>"
            cJson +=    "<versao>"                      + cVersao                       + "</versao>"
            cJson +=    "<chave>"                       + cChave                        + "</chave>"
            cJson +=    "<rota>"                        + cValToChar(DA8->DA8_XCODTP)   + "</rota>"
            cJson +=    "<admPedagio>"                  + cAdmPed                       + "</admPedagio>"
            cJson +=    "<distanciaTotal>"              + cValToChar(DTQ->DTQ_KMVGE)    + "</distanciaTotal>"
            cJson +=    "<eixos>"                       + cValToChar(DTR->DTR_QTDEIX)   + "</eixos>"
            cJson +=    "<cnpjContratante>"             + Self:Contratante              + "</cnpjContratante>"
            cJson +=    "<idSolicitacaoContratante>"    + cIdViagem                      + "</idSolicitacaoContratante>"
            cJson +=    "<dataSolicitacao>"             + cDataInicio+HoraInicio        + "</dataSolicitacao>"
            cJson +=    "<dataInicioFrete>"             + cDataInicio                   + "</dataInicioFrete>"
            cJson +=    "<dataFimFrete>"                + cDataFim                      + "</dataFimFrete>"
*/
				//=======================================================
				//Monta dados do parceiro
				//=======================================================
				If DUP->(DbSeek(xFilial("DUP")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM ))

					//Posiciono no cadastro do motorista
					If DA4->(DbSeek(xFilial("DA4")+DUP->DUP_CODMOT))

						//Verifico o numero no endereco
						if Empty(DA4->DA4_END)

							cLogError   := "O endereco no cadastro do motorista Codigo " + Alltrim(DUP->DUP_CODMOT) +" deve ser informado!"
							lRet        := .F.

						Elseif At(DA4->DA4_END,",") > 0

							cNumero := Alltrim(SubStr(DA4->DA4_END,At(DA4->DA4_END,",")+1,Len(DA4->DA4_END)))

						Endif

						if lRet

							cDataNasc := Alltrim(Substr(dTos(DA4->DA4_DATNAS),7,2)+Substr(dTos(DA4->DA4_DATNAS),5,2)+Substr(dTos(DA4->DA4_DATNAS),1,4))
							cDtVenCnh := Alltrim(Substr(dTos(DA4->DA4_DTVCNH),7,2)+Substr(dTos(DA4->DA4_DTVCNH),5,2)+Substr(dTos(DA4->DA4_DTVCNH),1,4))

							//-----------------------------------------------------------------------------------
							// É necessario que seja informado o parceiro Motorista, remetente e destinatario
							//-----------------------------------------------------------------------------------
							cJson +=    "<parceiros>"

							//-----------------------------------------------------------------------------------
							//1- Paceiro Motorista
							//-----------------------------------------------------------------------------------
							cJson +=        "<parceiro>"
							cJson +=            "<tipo>"                + "05"                               + "</tipo>"
							cJson +=            "<nome>"                + Alltrim(DA4->DA4_NOME)             + "</nome>"
							cJson +=            "<nomeMae>"             + Alltrim(DA4->DA4_MAE)              + "</nomeMae>"
							cJson +=            "<nomePai>"             + Alltrim(DA4->DA4_PAI)              + "</nomePai>"
							cJson +=            "<sexo>"                + "M"                                + "</sexo>"
							cJson +=            "<dataNascimento>"      + cDataNasc                          + "</dataNascimento>"
							cJson +=            "<numeroCPF>"           + Alltrim(DA4->DA4_CGC)              + "</numeroCPF>"
							cJson +=            "<numeroRG>"            + Alltrim(DA4->DA4_RG)               + "</numeroRG>"
							cJson +=            "<orgaoEmissorRg>"      + Alltrim(DA4->DA4_RGORG)            + "</orgaoEmissorRg>"
							cJson +=            "<ufRG>"                + Alltrim(DA4->DA4_RGEST)            + "</ufRG>"
							cJson +=            "<numeroCNH>"           + Alltrim(DA4->DA4_NUMCNH)           + "</numeroCNH>"
							cJson +=            "<ufCNH>"               + Alltrim(DA4->DA4_ESTCNH)           + "</ufCNH>"
							cJson +=            "<dataVencimentoCNH>"   + cDtVenCnh                          + "</dataVencimentoCNH>"
							cJson +=            "<endereco>"
							cJson +=                "<logradouro>"      + FwCutOff(Alltrim(DA4->DA4_END),.t.)  + "</logradouro>"
							cJson +=                "<numero>"          + cNumero                            + "</numero>"
							cJson +=                "<bairro>"          + Alltrim(DA4->DA4_BAIRRO)           + "</bairro>"
							cJson +=                "<codigoMunicipio>" + RetCodUf(DA4->DA4_EST)+Alltrim(DA4->DA4_CODMUN)      + "</codigoMunicipio>"
							cJson +=                "<cep>"             + Alltrim(DA4->DA4_CEP)              + "</cep>"
							cJson +=                "<fone>"            + Alltrim(DA4->DA4_DDD)+Alltrim(DA4->DA4_TEL) + "</fone>"
							cJson +=             "</endereco>"
							cJson +=        "</parceiro>"

							//Relaciona os documentos carregados
							If DTA->(DbSeek(xFilial("DTA")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM /*+DTQ->DTQ_FILORI /*+cChaveDoc*/ ))

								//Posiciona no CT-e
								if DT6->(DbSeek(xFilial("DT6")+DTA->DTA_FILORI+DTA->DTA_DOC+DTA->DTA_SERIE))

									//-----------------------------------------------------------------------------------
									//2- Paceiro Remetente
									//-----------------------------------------------------------------------------------

									//Posiciona no cadastro de cliente
									If SA1->(DbSeek(xFilial("SA1")+DT6->DT6_CLIREM+DT6->DT6_LOJREM))

										cJson +=        "<parceiro>"
										cJson +=            "<tipo>"                     + "01"                               + "</tipo>"
										cJson +=            "<nome>"                     + Alltrim(SA1->A1_NOME)              + "</nome>"

										If SA1->A1_PESSOA == "J"

											cJson +=             "<numeroCNPJ>"          + Alltrim(SA1->A1_CGC)         + "</numeroCNPJ>"

										else

											cJson +=             "<numeroCPF>"          + Alltrim(SA1->A1_CGC)           + "</numeroCPF>"

										Endif

										cJson +=            "<endereco>"
										cJson +=                "<logradouro>"      + FwCutOff(Alltrim(SA1->A1_END),.T.)               + "</logradouro>"
										cJson +=                "<numero>"          + "S/N"                              + "</numero>"
										cJson +=                "<bairro>"          + Alltrim(SA1->A1_BAIRRO)            + "</bairro>"
										cJson +=                "<codigoMunicipio>" + RetCodUf(SA1->A1_EST)+Alltrim(SA1->A1_COD_MUN)      + "</codigoMunicipio>"
										cJson +=                "<cep>"             + Alltrim(SA1->A1_CEP)               + "</cep>"
										cJson +=                "<fone>"            + Alltrim(SA1->A1_DDD)+Alltrim(SA1->A1_TEL)   + "</fone>"
										cJson +=             "</endereco>"
										cJson +=        "</parceiro>"

									Endif

									//-----------------------------------------------------------------------------------
									//3- Paceiro Destinatario
									//-----------------------------------------------------------------------------------

									//Posiciona no cadastro de cliente
									If SA1->(DbSeek(xFilial("SA1")+DT6->DT6_CLIDES+DT6->DT6_LOJDES))

										cJson +=        "<parceiro>"
										cJson +=            "<tipo>"                    + "02"                               + "</tipo>"
										cJson +=            "<nome>"                    + Alltrim(SA1->A1_NOME)              + "</nome>"

										If SA1->A1_PESSOA == "J"

											cJson +=             "<numeroCNPJ>"         + ALltrim(SA1->A1_CGC)           + "</numeroCNPJ>"

										else

											cJson +=             "<numeroCPF>"          + ALltrim(SA1->A1_CGC)           + "</numeroCPF>"

										Endif

										cJson +=            "<endereco>"
										cJson +=                "<logradouro>"      + FwCutOff(Alltrim(SA1->A1_END),.T.)               + "</logradouro>"
										cJson +=                "<numero>"          + "S/N"                              + "</numero>"
										cJson +=                "<bairro>"          + Alltrim(SA1->A1_BAIRRO)            + "</bairro>"
										cJson +=                "<codigoMunicipio>" + RetCodUf(SA1->A1_EST)+Alltrim(SA1->A1_COD_MUN)      + "</codigoMunicipio>"
										cJson +=                "<cep>"             + Alltrim(SA1->A1_CEP)               + "</cep>"
										cJson +=                "<fone>"            + Alltrim(SA1->A1_DDD)+Alltrim(SA1->A1_TEL)   + "</fone>"
										cJson +=             "</endereco>"
										cJson +=        "</parceiro>"

									Endif

								else

									cLogErro := "Falha ao posicionar no CT-e "+ DTA->DTA_DOC
									lRet     := .F.

								Endif

								cJson +=        "</parceiros>"

								//cIdViagem := Alltrim(xFilial("DTR"))+ ( alltrim(DTA->DTA_DOC) + alltrim(DTA->DTA_SERIE) ) + cSequencia
								//cJson +=    "<idSolicitacaoContratante>"    + cIdViagem   + "</idSolicitacaoContratante>"


								If lRet

									cJson +=    "<carga>"

									cJson +=       "<ctes>"

									aDocsCTES := {}

									While DTA->(!EOF()) ;
											.AND. xFilial("DTA")+DTA->DTA_FILORI+DTA->DTA_VIAGEM == xFilial("DTQ")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM

										dbSelectArea("DT6")
										DT6->(dbSetOrder(1))
										IF dbSeek(xFilial("DT6")  + DTA->DTA_FILORI + DTA->DTA_DOC + DTA->DTA_SERIE )

											// ** array para adicionar na ZZ1
											AADD( aDocsCTES , { DT6->DT6_DOC , DT6->DT6_SERIE } )

											cJson +=     "<cte>"
											cJson +=        "<modeloConhecimento>1</modeloConhecimento>"
											cJson +=        "<serieConhecimento>"+alltrim(DT6->DT6_SERIE)+"</serieConhecimento>"
											cJson +=        "<numeroConhecimento>"+alltrim(DT6->DT6_DOC)+"</numeroConhecimento>"

											dbselectarea("DTC")
											DTC->(dbsetorder(3))
											IF dbSeek(xFilial("DTC")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE )

												//=======================================================
												//Monta dados da Nota
												//=======================================================

												cJson +=     "<notas>"

												while !EOF() .AND. DTC->DTC_FILDOC ==  DT6->DT6_FILDOC .AND. DTC->DTC_DOC == DT6->DT6_DOC .AND. DTC->DTC_SERIE == DT6->DT6_SERIE


													//Posiciono no produto para pegar a unidade medida
													//Alterado por Lucas Arruda - 08/01/2020
													If SB1->(DbSeek(xFilial("SB1")+DTC->DTC_CODPRO))
														cNatCarga := Alltrim(SB1->B1_POSIPI)
														cDesProd  := Alltrim(SB1->B1_DESC)
														cUnidade  := Alltrim(SB1->B1_UM)
													else
														cNatCarga := ""
														cDesProd  := ""
														cUnidade  := ""
														cLogError   := "Cadastor do produto " + DTC->DTC_CODPRO  + " NÂO encontrato !"
														lRet        := .F.
													endif


													cJson +=  "<nota>"
													cJson +=    "<numeroNF>"           + Alltrim(DTC->DTC_NUMNFC)    + "</numeroNF>"
													cJson +=    "<serie>"              + Alltrim(DTC->DTC_SERNFC)    + "</serie>"

													//Modelo na nota
													If !Empty(DTC->DTC_MODELO)

														cModelo := DTC->DTC_MODELO
													Endif

													cJson +=    "<modelo>"             + Alltrim(cModelo)           + "</modelo>"
													cJson +=    "<chaveNFe>"           + Alltrim(DTC->DTC_NFEID)    + "</chaveNFe>"

													//Posiciono no cliente remetente
													if SA1->(DbSeek(xFilial("SA1")+DT6->DT6_CLIREM+DT6->DT6_LOJREM ))

														cJson += "<remetenteNome>"      + Alltrim(SA1->A1_NOME) + "</remetenteNome>"

														If SA1->A1_PESSOA == "F"

															cJson += "<remetenteCPF>"   + Alltrim(SA1->A1_CGC) + "</remetenteCPF>"

														else

															cJson += "<remetenteCNPJ>"  + Alltrim(SA1->A1_CGC) + "</remetenteCNPJ>"

														endif
													else

														cLogError := "Cliente remetente nao foi encontrado!"

													Endif

													cJson +=    "<volumeTotalNota>"       + FormValor(DTC->DTC_PESO,"DTC","DTC_PESO")       + "</volumeTotalNota>"
													cJson +=    "<precisaoVolTotalNota>"  + cValToChar(TamSx3("DTC_PESO")[2])               + "</precisaoVolTotalNota>"


													//Alterado por Lucas Arruda - 08/01/2020
													cJson +=  "<unidadeMedida>" + cUnidade             + "</unidadeMedida>"


													cJson +=    "<valorTotalNota>"        + FormValor(DTC->DTC_VALOR,"DTC","DTC_VALOR")        + "</valorTotalNota>"
													cJson +=    "<precisaoTotalNota>"     + cValToChar(TamSx3("DTC_VALOR")[2])                 + "</precisaoTotalNota>"

													cJson +=  "</nota>"

													//Quantidade volumes
													nQtdVol     += DTC->DTC_QTDVOL
													nVlrCarga   += DTC->DTC_VALOR
													nPesoCarga  += DTC->DTC_PESO

													DTC->(dbskip())

												enddo

												cJson +=  "</notas>"

											ENDIF
											DTC->(dbCloseArea())
										ELSE
											cLogErro := "Falha ao posicionar no CT-e "+ DTA->DTA_DOC
											lRet     := .F.
										ENDIF

										cJson +=      "</cte>"

										//DT6->(dbCloseArea())

										DTA->(DbSkip())
									EndDo
									cJson +=       "</ctes>"

									cJson +=        "<codigoNaturezaCarga>" + Substr(cNatCarga,1,4)                   + "</codigoNaturezaCarga>"
									cJson +=        "<quantidadeTotal>"     + FormValor(nPesoCarga,"DTC","DTC_PESO")  + "</quantidadeTotal>"
									cJson +=        "<precisao>"            + cValtoChar(TamSx3("DTC_PESO")[2])       + "</precisao>"
									cJson +=        "<unidadeMedida>"       + cUnidade                                + "</unidadeMedida>"
									cJson +=        "<descricaoProduto>"    + Alltrim(cDesProd)                       + "</descricaoProduto>"
									cJson +=        "<tipoCarga>"           + cTipoCarga                              + "</tipoCarga>"
									cJson +=    "</carga>"

								endif

							endif

						endif

					else

						cLogError   := "Cadastro do motorista nao foi encontrato !"
						lRet        := .F.

					Endif

					//Busco valor do frete
					nValFrete := RetValFre()

					//=======================================================
					//Monta dados de informacoes Acessorias
					//=======================================================
					cJson += "<informacoesAcessorias>"
					cJson +=      "<percentualTolerancia>"     + StrTran(nPerToler,".","")                   + "</percentualTolerancia>"
					cJson +=      "<precisaoTolerancia>"       + "2"                                         + "</precisaoTolerancia>"
					cJson +=      "<valorUnitMercPerda>"       + FormValor(Round(nVlrCarga / nPesoCarga,TamSx3("DTR_VALFRE")[2]),"DTR","DTR_VALFRE")+ "</valorUnitMercPerda>"
					//cJson +=      "<valorUnitMercPerda>"       + FormValor(Round(nVlrCarga / (nPesoCarga/1000),TamSx3("DTR_VALFRE")[2]),"DTR","DTR_VALFRE")+ "</valorUnitMercPerda>"
					cJson +=      "<precisaoUnitMercPerda>"    + cValtoChar(TamSx3("DTR_VALFRE")[2])         + "</precisaoUnitMercPerda>"
					cJson +=      "<unidMedUnitMercPerda>"     + cUnidade                                    + "</unidMedUnitMercPerda>"
					//cJson +=      "<unidMedUnitMercPerda>"     + "TON"                                    + "</unidMedUnitMercPerda>"
					//**** ALTERADO POR LUCAS ARRUDA - 21/01/2021
					IF Round(( nValFrete / (nPesoCarga/1000)) ,2) == int(Round(( nValFrete / (nPesoCarga/1000)) ,2))
						//**** SEM CASA DECIMAL
						cJson +=      "<valorUnitNegociadoFrete>"  +  StrTran(StrTran(Alltrim(Transform(Round(( nValFrete / (nPesoCarga/1000)) ,2),"@! 999,999,999.99")),",",""),".","") + "</valorUnitNegociadoFrete>"
					ELSE
						//**** COM CASA DECIMAL
						cJson +=      "<valorUnitNegociadoFrete>"  +  StrTran(StrTran(Alltrim(Transform(Round(( nValFrete / (nPesoCarga/1000)) ,2),"@! 999,999,999.99")),",",""),".","") + "</valorUnitNegociadoFrete>"
					ENDIF
					//cJson +=      "<valorUnitNegociadoFrete>"  + StrTran(StrTran(Alltrim(Transform(Round(nValFrete / nPesoCarga,2),"@E99,999.99")),",",""),".","")+ "</valorUnitNegociadoFrete>"
					cJson +=      "<precisaoValorNegociado>"   + "2"                                        + "</precisaoValorNegociado>"
					//cJson +=      "<unidMedUnitNegociadoFrete>"+ cUnidade                                    + "</unidMedUnitNegociadoFrete>"
					cJson +=      "<unidMedUnitNegociadoFrete>"+ "TON"                                    + "</unidMedUnitNegociadoFrete>"
					cJson +=      "<flagCalculoPerda>"         + "S"                                         + "</flagCalculoPerda>"
					cJson +=      "<flagCalculoQuebra>"        + "S"                                         + "</flagCalculoQuebra>"
					cJson +=      "<flagLiberacaoAdiantamento>"+ iif(DTR->DTR_ADIFRE > 0 ,"S","N")           + "</flagLiberacaoAdiantamento>"
					cJson +=      "<flagLiberacaoFinalizacao>" + "S"                                         + "</flagLiberacaoFinalizacao>"
					cJson += "</informacoesAcessorias>"


					//=======================================================
					//Monta dados de informacoes Acessorias
					//=======================================================
					//Posiciona no cadastro do fornecedor
					If SA2->(MsSeek(xFilial("SA2")+ DTR->DTR_CODFOR+DTR->DTR_LOJFOR ))

						If Empty(SA2->A2_RNTRC)

							cLogError   := "O campo RNTRC no cadastro do fornecedor deve ser preenchido !"
							lRet := .F.

						Elseif Empty(SA2->A2_TEL)

							cLogError   := "O campo telefone no cadastro do fornecedor Codigo "+ Alltrim(DTR->DTR_CODFOR) + " deve ser preenchido !"
							lRet := .F.

						Elseif Empty(SA2->A2_ZTAC)
							cLogError   := "O campo Tipo Transp no cadastro do fornecedor Codigo "+ Alltrim(DTR->DTR_CODFOR) + " deve ser preenchido !"
							lRet := .F.
						Endif

						If lRet

							cJson +=    "<itens>"
							cJson +=        "<item>"
							cJson +=            "<contratado>"
							cJson +=                "<rntrc>"               + Alltrim(SA2->A2_RNTRC)   + "</rntrc>"
							cJson +=                "<nome>"                + Alltrim(SA2->A2_NOME)    + "</nome>"

							//Valida o tipo do fornecedor
							If  Alltrim(SA2->A2_TIPO) == "J"

								cJson +=            "<numeroCNPJ>"          + Alltrim(SA2->A2_CGC)     + "</numeroCNPJ>"

							else

								cJson +=            "<numeroCPF>"           + Alltrim(SA2->A2_CGC)     + "</numeroCPF>"

							Endif

							cJson +=                "<tipoContratado/>"
							cJson +=                "<logradouro>"          + FwCutOff(Alltrim(SA2->A2_END),.T.)                  + "</logradouro>"
							cJson +=                "<numero>"              + iif(Empty(SA2->A2_NR_END),"S/N", Alltrim(SA2->A2_NR_END))  + "</numero>"
							cJson +=                "<complemento>"         + Alltrim(SA2->A2_COMPLEM)              + "</complemento>"
							cJson +=                "<bairro>"              + Alltrim(SA2->A2_BAIRRO)               + "</bairro>"
							cJson +=                "<codigoMunicipio>"     + RetCodUf(SA2->A2_EST)+Alltrim(SA2->A2_COD_MUN) + "</codigoMunicipio>"
							cJson +=                "<cep>"                 + Alltrim(SA2->A2_CEP)                  + "</cep>"
							cJson +=                "<fone>"                + Alltrim(SA2->A2_DDD)+Alltrim(SA2->A2_TEL) + "</fone>"
							cJson +=                "<banco>"               + Alltrim(SA2->A2_BANCO)                 + "</banco>"
							cJson +=                "<agencia>"             + Alltrim(SA2->A2_AGENCIA)              + "</agencia>"
							cJson +=                "<conta>"               + Alltrim(SA2->A2_NUMCON)+"-"+Alltrim(SA2->A2_DVCTA) + "</conta>"
							cJson +=                "<tipoconta>"           + "C"                                   + "</tipoconta>"
							cJson +=                "<cnpjRecebedor>"       + Alltrim(SA2->A2_CGC)                  +"</cnpjRecebedor>"

							If Alltrim(SA2->A2_ZTAC) $ "12"
								cData := Dtos(SA2->A2_DTNASC)
								cData := Substr(cData, 7, 2) + Substr(cData, 5, 2) + Substr(cData, 1, 4)

								cJson +=                "<sexo>"                        + Alltrim('')                   +"</sexo>"
								cJson +=                "<dataNascimento>"              + Alltrim(cData)                +"</dataNascimento>"
								cJson +=                "<numeroPIS>"                   + Alltrim('')                   +"</numeroPIS>"
								cJson +=                "<localNascimento>"             + Alltrim('')                   +"</localNascimento>"
								cJson +=                "<nacionalidade>"               + Alltrim('')                   +"</nacionalidade>"
								cJson +=                "<quantidadeDependentesIr>"     + Alltrim(cValToChar(SA2->A2_NUMDEP))       +"</quantidadeDependentesIr>"
							Endif

							cJson +=            "</contratado>"

							//Alterado por Lucas Arruda - 08/01/2020
							//Posiciono no cadastro do veiculo
							//*** LOGICA VEICULO PRINCIPAL
							If DA3->(DbSeek(xFilial("DA3")+DTR->DTR_CODVEI))

								//*** INICIO LOGICA VEICULOS
								cJson +=  "<veiculos>"

								If Empty(DA3->DA3_XCDMUN)

									cLogError   := "O codigo do municipio no cadastro do veiculo Placa " + Alltrim(DTR->DTR_CODVEI) +" deve ser preenchido!"
									lRet        := .F.

								Endif

								if  nValFrete == 0

									cLogError   := "O campo Valor do Frete é obrigatório !"
									lRet       := .F.

								Endif

								if lRet

									cJson +=          "<veiculo>"
									cJson +=              "<placa>"           + Alltrim(DTR->DTR_CODVEI)    + "</placa>"
									cJson +=              "<renavam>"         + Alltrim(DA3->DA3_RENAVA)    + "</renavam>"
									cJson +=              "<codigoMunicipio>" + RetCodUf(DA3->DA3_ESTPLA)+Alltrim(DA3->DA3_XCDMUN)+ "</codigoMunicipio>"
									cJson +=              "<rntrc>"           + Alltrim(Posicione("SA2",1, xFilial("SA2") + DA3->DA3_CODFOR + DA3->DA3_LOJFOR ,"A2_RNTRC")) /* Alltrim(SA2->A2_RNTRC) */    + "</rntrc>"
									cJson +=              "<tipoVeiculo>"     + "0"                         + "</tipoVeiculo>" //0 – TRAÇÃO / 1 - REBOQUE
									cJson +=              "<eixos>"           + cValToChar(DA3->DA3_QTDEIX) + "</eixos>"
									cJson +=              "<tagCaminhao>"     + ''                          + "</tagCaminhao>"
									cJson +=          "</veiculo>"

									//*** LOGICA REBOQUE 1
									If DA3->(DbSeek(xFilial("DA3")+DTR->DTR_CODRB1))

										If Empty(DA3->DA3_XCDMUN)

											cLogError   := "O codigo do municipio no cadastro do veiculo Placa " + Alltrim(DTR->DTR_CODRB1) +" deve ser preenchido!"
											lRet        := .F.

										Endif

										if lRet

											cJson +=          "<veiculo>"
											cJson +=              "<placa>"           + Alltrim(DTR->DTR_CODRB1)    + "</placa>"
											cJson +=              "<renavam>"         + Alltrim(DA3->DA3_RENAVA)    + "</renavam>"
											cJson +=              "<codigoMunicipio>" + RetCodUf(DA3->DA3_ESTPLA)+Alltrim(DA3->DA3_XCDMUN)+ "</codigoMunicipio>"
											cJson +=              "<rntrc>"           + Alltrim(Posicione("SA2",1, xFilial("SA2") + DA3->DA3_CODFOR + DA3->DA3_LOJFOR ,"A2_RNTRC"))    + "</rntrc>"
											cJson +=              "<tipoVeiculo>"     + "1"                         + "</tipoVeiculo>" //0 – TRAÇÃO / 1 - REBOQUE
											cJson +=              "<eixos>"           + cValToChar(DA3->DA3_QTDEIX) + "</eixos>"
											cJson +=              "<tagCaminhao>"     + ''                          + "</tagCaminhao>"
											cJson +=          "</veiculo>"

										endif

									endif

									//*** LOGICA REBOQUE 2
									If DA3->(DbSeek(xFilial("DA3")+DTR->DTR_CODRB2))

										If Empty(DA3->DA3_XCDMUN)

											cLogError   := "O codigo do municipio no cadastro do veiculo Placa " + Alltrim(DTR->DTR_CODRB2) +" deve ser preenchido!"
											lRet        := .F.

										Endif

										if lRet

											cJson +=          "<veiculo>"
											cJson +=              "<placa>"           + Alltrim(DTR->DTR_CODRB2)    + "</placa>"
											cJson +=              "<renavam>"         + Alltrim(DA3->DA3_RENAVA)    + "</renavam>"
											cJson +=              "<codigoMunicipio>" + RetCodUf(DA3->DA3_ESTPLA)+Alltrim(DA3->DA3_XCDMUN)+ "</codigoMunicipio>"
											cJson +=              "<rntrc>"           + Alltrim(Posicione("SA2",1, xFilial("SA2") + DA3->DA3_CODFOR + DA3->DA3_LOJFOR ,"A2_RNTRC"))     + "</rntrc>"
											cJson +=              "<tipoVeiculo>"     + "1"                         + "</tipoVeiculo>" //0 – TRAÇÃO / 1 - REBOQUE
											cJson +=              "<eixos>"           + cValToChar(DA3->DA3_QTDEIX) + "</eixos>"
											cJson +=              "<tagCaminhao>"     + ''                          + "</tagCaminhao>"
											cJson +=          "</veiculo>"

										endif

									endif


									//*** LOGICA REBOQUE 3
									If DA3->(DbSeek(xFilial("DA3")+DTR->DTR_CODRB3))

										If Empty(DA3->DA3_XCDMUN)

											cLogError   := "O codigo do municipio no cadastro do veiculo Placa " + Alltrim(DTR->DTR_CODRB3) +" deve ser preenchido!"
											lRet        := .F.

										Endif

										if lRet

											cJson +=          "<veiculo>"
											cJson +=              "<placa>"           + Alltrim(DTR->DTR_CODRB3)    + "</placa>"
											cJson +=              "<renavam>"         + Alltrim(DA3->DA3_RENAVA)    + "</renavam>"
											cJson +=              "<codigoMunicipio>" + RetCodUf(DA3->DA3_ESTPLA)+Alltrim(DA3->DA3_XCDMUN)+ "</codigoMunicipio>"
											cJson +=              "<rntrc>"           + alltrim(Posicione("SA2",1, xFilial("SA2") + DA3->DA3_CODFOR + DA3->DA3_LOJFOR ,"A2_RNTRC"))    + "</rntrc>"
											cJson +=              "<tipoVeiculo>"     + "1"                         + "</tipoVeiculo>" //0 – TRAÇÃO / 1 - REBOQUE
											cJson +=              "<eixos>"           + cValToChar(DA3->DA3_QTDEIX) + "</eixos>"
											cJson +=              "<tagCaminhao>"     + ''                          + "</tagCaminhao>"
											cJson +=          "</veiculo>"

										endif

									endif

								endif

								cJson +=   "</veiculos>"

							Else
								cLogError   := "Codigo/Placa do Veiculo Principal/Tração NÃO foi encontrado no cadastro de veiculos! Cod DTR_CODVEI:  " + DTR->DTR_CODVEI
								lRet        := .F.
							Endif

							if lRet
								// ===============================================================
								// NOVO BLOCO: OBTENÇÃO DO CUSTO DO PEDÁGIO
								// ===============================================================
								aDadosPedagio := {}
								nVlPedagio    := DTR->DTR_VALPDG // Inicia com o valor do banco caso não tenha pedágio
								nPrcPedagio   := TamSx3("DTR_VALPDG")[2]

								// Verifica se a Rota tem pedágio (1=Sim) e se o veículo tem Adm. configurada
								If DA8->DA8_XPED == '1'
									cAdmPdg := Posicione('DA3', 1, xfilial('DA3')+DTR->DTR_CODVEI, 'DA3_ZADMPG')
									If !Empty(cAdmPdg)
										// Chama a API Nova
										aDadosPedagio := Self:ObterCustoPedagioTipFrete(cChave, Self:Contratante, cAdmPdg, DA8->DA8_XCODTP, DTR->DTR_QTDEIX, DTR->DTR_CODVEI, DA4->DA4_CGC, @cLogError)

										If Len(aDadosPedagio) > 0
											nVlPedagio  := aDadosPedagio[1]
											nPrcPedagio := aDadosPedagio[2]
										Else
											lRet := .F.
										EndIf
									Else
										cLogError := "Rota possui pedágio, mas Veículo não possui Administradora (DA3_ZADMPG) informada."
										lRet := .F.
									EndIf
								EndIf

								if lRet

									cJson +=       "<servico>"
									cJson +=           "<valorPedagio>"            + StrTran(cValToChar(nVlPedagio),'.','')     		+ "</valorPedagio>"
									cJson +=           "<precisaoPedagio>"         + cValToChar(nPrcPedagio)               			+ "</precisaoPedagio>"
									cJson +=           "<valorSeguro>"             + StrTran(cValToChar(DUP->DUP_VALSEG),'.','')     + "</valorSeguro>"
									cJson +=           "<precisaoSeguro>"          + cValToChar(TamSx3("DUP_VALSEG")[2])                + "</precisaoSeguro>"
									cJson +=           "<impostos>"
									cJson +=               "<imposto>"
									cJson +=                   "<nome>"            + 'INSS'                                             + "</nome>"
									cJson +=                   "<valor>"           + cValToChar(DTR->DTR_INSRET)      + "</valor>"
									cJson +=                   "<precisao>"        + cValToChar(TamSx3("DTR_INSRET")[2])                + "</precisao>"
									cJson +=               "</imposto>"
									cJson +=           "</impostos>"
									cJson +=           "<valorContratoFrete>"          + FormValor(nValFrete,"DTR","DTR_VALFRE")        + "</valorContratoFrete>"
									cJson +=           "<precisaoContratoFrete>"       + cValToChar(TamSx3("DTR_VALFRE")[2])            + "</precisaoContratoFrete>"
									cJson +=           "<limiteAdiantamento>"          + FormValor(DTR->DTR_ADIFRE,"DTR","DTR_ADIFRE")  + "</limiteAdiantamento>"
									cJson +=           "<precisaoLimAdiantamento>"     + cValToChar(TamSx3("DTR_ADIFRE")[2])            + "</precisaoLimAdiantamento>"
									cJson +=           "<dataPrevisaoAdiantamento>"    + cDataInicio                                    + "</dataPrevisaoAdiantamento>"
									cJson +=           "<periodoRepasseFinalizacao>"   + ''                                             + "</periodoRepasseFinalizacao>"
									cJson +=           "<unidadeRepasseFinalizacao>"   + ''                                             + "</unidadeRepasseFinalizacao>"
									cJson +=       "</servico>"
									cJson +=    "</item>"
									cJson += "</itens>"

								endif
							endif

						Endif

					Endif

				Endif

			Endif

			cJson += "</viagem>"

		else

			cLogError   := "Nao foi localizado veiculo amarrado a esta Viagem!"
			lRet        := .F.

		endif

		if lRet

			// seto a string Json
			oRest:SetPostParams(cJson)

			If oRest:Post(Self:aHeadOut)

				cJsonRet :=  oRest:GetResult()

				if !Empty(cJsonRet)

					oXmlRet := XmlParser( cJsonRet, "_", @cError, @cWarning )

					If At("<msg>",cJsonRet) > 0

						//Pedro TSC - Validação p/ retorno com Erro no XML - 28/07/2026
						If ValType(oXmlRet) == "O"

							If AttIsMemberOf(oXmlRet,"_RETORNOSOLICITACAOCIOT")

								//Valida Retorno do Metodo
								If oXmlRet:_RETORNOSOLICITACAOCIOT:_MSG:TEXT == "OK"

									for nA := 1 to len(aDocsCTES)

										ZZ1->(DbSetOrder(1))

										cDocA := alltrim(aDocsCTES[nA][1])
										cSerA := alltrim(aDocsCTES[nA][2])

										//Gravo tabela de Viagens enviadas
										If !ZZ1->(DbSeek(xFilial("ZZ1")+DTQ->DTQ_VIAGEM+PADR( ( cDocA + cSerA )  ,TamSx3("ZZ1_DOCCTE")[1])+cSequencia))

											RecLock("ZZ1",.T.)

											ZZ1->ZZ1_FILIAL := xFilial("ZZ1")
											ZZ1->ZZ1_VIAGEM := DTQ->DTQ_VIAGEM
											ZZ1->ZZ1_SEQ    := cSequencia
											ZZ1->ZZ1_DTENV  := dDataBase
											ZZ1->ZZ1_HRENV  := Time()
											ZZ1->ZZ1_USER   := _cCodUser
											ZZ1->ZZ1_JSENV  := cJson
											ZZ1->ZZ1_JSRET  := cJsonRet
											ZZ1->ZZ1_DTRET  := dDataBase
											ZZ1->ZZ1_HRRET  := Time()
											ZZ1->ZZ1_STATUS := oXmlRet:_RETORNOSOLICITACAOCIOT:_MSG:TEXT
											ZZ1->ZZ1_PROTOC := Val(oXmlRet:_RETORNOSOLICITACAOCIOT:_NUMEROPROTOCOLO:TEXT)
											ZZ1->ZZ1_DOCCTE := cDocA + cSerA

											ZZ1->(MsUnLock())
										Else

											RecLock("ZZ1",.F.)

											ZZ1->ZZ1_DTENV  := dDataBase
											ZZ1->ZZ1_HRENV  := Time()
											ZZ1->ZZ1_USER   := _cCodUser
											ZZ1->ZZ1_JSENV  := cJson
											ZZ1->ZZ1_JSRET  := cJsonRet
											ZZ1->ZZ1_DTRET  := dDataBase
											ZZ1->ZZ1_HRRET  := Time()
											ZZ1->ZZ1_STATUS := oXmlRet:_RETORNOSOLICITACAOCIOT:_MSG:TEXT
											ZZ1->ZZ1_DOCCTE := DocA + cSerA

										Endif

									next nA

								else

									cLogError   := Alltrim(oXmlRet:_RETORNOSOLICITACAOCIOT:_MSG:TEXT)
									lRet        := .F.

								Endif

							Elseif AttIsMemberOf(oXmlRet,"_RETORNOPADRAO")

								cLogError   := Alltrim(oXmlRet:_RETORNOPADRAO:_MSG:TEXT)
								lRet        := .F.

							Else

								cLogError   := "Erro interno - Verifique o XML e Status de funcionamento do Servidor Tip Bank"
								lRet        := .F.

							Endif

						Endif

					else
						cLogError   :="Retorno falhou - Nao foi possivel obter o retorno da Tip Bank"
						lRet        := .F.

					Endif
				Endif

			else

				cLogError   := "Falha na construção do Xml ou erro no retorno da Tip Bank"
				lRet        := .F.

			Endif

		Endif

	Endif

Return lRet

/*/{Protheus.doc} FwRestTipFrt
Metodo de Cadastramento de Rota
@author Leandro Rodrigues
@since 03/04/2020
@version P12
@param nulo
@return nulo
/*/

Method CadastraRotaTipFrete(cChave,cLogError) Class IntegraTipFrete

	Local oXmlRet   := Nil
	Local cJson     := ""
	Local cJsonRet  := ""
	Local cError    := ""
	Local cWarning  := ""
	Local cRetOrig  := SuperGetmv("MV_XTPFORG",,"1")
	Local oRota     := ""
	Local lRet      := .T.

	DA8->(DbSetOrder(1))
	DUY->(DbSetOrder(1))
	DUD->(DbSetOrder(1))

//Instancia objeto de conexao
	oRota := FWRest():New(Self:cApiTipFrete)

//informo o path do metodo
	oRota:SetPath(Self:cPathRota)

//Consulta se rota ja foi existe9
	If DA8->(DbSeek(xFilial("DA8") + DTQ->DTQ_ROTA )) .AND. (DA8->DA8_XCODTP=' ')

		cJson   := "<rota>"
		cJson   +=      "<chave>"           + cChave                    + "</chave>"
		cJson   +=      "<cnpjContratante>" + Self:Contratante          + "</cnpjContratante>"
		cJson   +=      "<retornoOrigem>"   + cRetOrig                  + "</retornoOrigem>"
		cJson   +=      "<cidades>"

		//Codigo municipio de origem
		If DUY->(DbSeek(xFilial("DUY")+DA8->DA8_CDRORI ))

			cJson   +=          "<codigoCidade>" + RetCodUf(DUY->DUY_EST)+DUY->DUY_CODMUN     +"</codigoCidade>"

		endif

		//Codigo municipio de destino
		// If DUY->(DbSeek(xFilial("DUY")+"L00056" ))
		If DUY->(DbSeek(xFilial("DUY")+DA8->DA8_XCDREG ))

			cJson   +=  "<codigoCidade>" + RetCodUf(DUY->DUY_EST)+DUY->DUY_CODMUN     +"</codigoCidade>"

		endif


		cJson   +=      "</cidades>"
		cJson   += "</rota>"

		// seto a string Json
		oRota:SetPostParams(cJson)

		If oRota:Post(Self:aHeadOut)

			cJsonRet :=  oRota:GetResult()

			if !Empty(cJsonRet)

				oXmlRet := XmlParser( cJsonRet, "_", @cError, @cWarning )

				//Valido se retornou a tag codigo da rota
				if At("<codigoRota>",cJsonRet) > 0

					//Grava codigo da rota criada na Tip Bank
					RecLock("DA8",.F.)
					DA8->DA8_XCODTP := oXmlRet:_RETORNOROTA:_CODIGOROTA:TEXT
					DA8->(MsUnLock())

/*                RecLock("DA8",.F.)
                    DA8->DA8_XCODTP := Val(oXmlRet:_RETORNOROTA:_CODIGOROTA:TEXT)
                DA8->(MsUnLock())*/

            else

                cLogError   := "Erro "+ oXmlRet:_RETORNOROTA:_MSG:TEXT
                lRet        := .F.

            Endif
        endif

    endif

endif

Return lRet

/*/{Protheus.doc} ConsultaViagemTipFrete
Metodo para consultar Viagem Tip Bank
@author Leandro Rodrigues
@since 03/04/2020
@version P12
@param nulo
@return nulo
/*/
Method ConsultaViagemTipFrete(cChave,cLogError) Class IntegraTipFrete

Local cJson         := ""
Local cError        := ""
Local cWarning      := ""
Local lRet          := .F.
Local oRest         := Nil
Local oXmlRet       := Nil
Local cDataHora     := Substr(dTos(dDataBase),7,2) +Substr(dTos(dDataBase),5,2)+Substr(dTos(dDataBase),1,4)
Local cSequencia    := ""
Local cCodStrada    := AllTrim(SuperGetmv("MV_ZSTRCOD",,"008628"))
Local cLojStrada    := AllTrim(SuperGetmv("MV_ZSTRLOJ",,"1"))

ZZ1->(DbSetOrder(1))

//Instancia objeto de conexao
oRest := FWRest():New(Self:cApiTipFrete)

//informo o path do metodo
oRest:SetPath(Self:cPathConVi)

//Pego ultima seqeuncia enviada
ConsultaEnvio( ,@cSequencia,.F.)


cQry := " SELECT"
cQry += "   R_E_C_N_O_ as RECZZ1"
cQry += " FROM " + RETSQLNAME("ZZ1")
cQry += " WHERE D_E_L_E_T_ = ' '"
cQry += "   AND ZZ1_FILIAL ='" + xFilial("ZZ1")   + "'"
cQry += "   AND ZZ1_VIAGEM ='" +  DTQ->DTQ_VIAGEM + "'"
cQry += "   AND ZZ1_SEQ    ='" +  cSequencia + "'"
cQry := ChangeQuery(cQry)
If Select("QZZ1") > 1
    QZZ1->(DbCloseArea())
Endif
TcQuery cQry New Alias "QZZ1"

If QZZ1->(!EOF())

    ZZ1->(DbGoTo(QZZ1->RECZZ1))

    cDataHora := Substr(dTos(ZZ1->ZZ1_DTENV),7,2) +Substr(dTos(ZZ1->ZZ1_DTENV),5,2)+Substr(dTos(ZZ1->ZZ1_DTENV),1,4)
    cDataHora += StrTran(ZZ1->ZZ1_HRENV,":","")+"00"

    //Preparo json de envio
    cJson := "<consultaViagem>"
    cJson +=    "<numeroProtocolo>" +   cValToChar(ZZ1->ZZ1_PROTOC)    + "</numeroProtocolo>"
    cJson +=    "<dataRequisicao>"  +   cDataHora                      + "</dataRequisicao>"
    cJson +=    "<chave>"           +   Alltrim(cChave)                + "</chave>"
    cJson +=  "</consultaViagem>"

    // seto a string Json
    oRest:SetPostParams(cJson)

    If oRest:Post(Self:aHeadOut)

        cJsonRet :=  oRest:GetResult()

        if !Empty(cJsonRet)

            oXmlRet := XmlParser( cJsonRet, "_", @cError, @cWarning )
            // alert(oXmlRet:_RETORNOVIAGEM:_RETORNOITENS:_RETORNOITEM:_CODIGOTIPOCONTRATADO:TEXT)

            if oXmlRet:_RETORNOVIAGEM:_STATUSOPERACAO:TEXT == "ERRO"

                cLogError   := oXmlRet:_RETORNOVIAGEM:_MSG:TEXT
                lRet        := .F.

                cViagem := ZZ1->ZZ1_VIAGEM
                cSequen := ZZ1->ZZ1_SEQ
                cQry := " SELECT"
                cQry += "   R_E_C_N_O_ as RECZZ1"
                cQry += " FROM " + RETSQLNAME("ZZ1")
                cQry += " WHERE D_E_L_E_T_ = ' '"
                cQry += "   AND ZZ1_FILIAL ='" + xFilial("ZZ1")   + "'"
                cQry += "   AND ZZ1_VIAGEM ='" +  cViagem + "'"
                cQry += "   AND ZZ1_SEQ    ='" +  cSequen + "'"
                cQry := ChangeQuery(cQry)
                If Select("Q2ZZ1") > 1
                    Q2ZZ1->(DbCloseArea())
                Endif
                TcQuery cQry New Alias "Q2ZZ1"

                While Q2ZZ1->(!EOF())

                    ZZ1->(DbGoTo(Q2ZZ1->RECZZ1))

                    //Gravo msg no registro
                    Reclock("ZZ1",.F.)
                    ZZ1->ZZ1_STATUS := "FALHA LIBERACAO"
                    ZZ1->ZZ1_JSERRO := cJsonRet

                    if At("<idOperacaoViagem>",cJsonRet) > 0

                        ZZ1->ZZ1_IDVIAG := Val(oXmlRet:_RETORNOVIAGEM:_IDOPERACAOVIAGEM:TEXT)

                    Endif

                    ZZ1->(MsUnLock())


                    Q2ZZ1->(dbskip())
                enddo
                Q2ZZ1->(DbCloseArea())

            Elseif oXmlRet:_RETORNOVIAGEM:_STATUSOPERACAO:TEXT == "AUTORIZADO"

				if At("<numeroCIOT>",cJsonRet) > 0

                    cViagem := ZZ1->ZZ1_VIAGEM
                    cSequen := ZZ1->ZZ1_SEQ
                    cQry := " SELECT"
                    cQry += "   R_E_C_N_O_ as RECZZ1"
                    cQry += " FROM " + RETSQLNAME("ZZ1")
                    cQry += " WHERE D_E_L_E_T_ = ' '"
                    cQry += "   AND ZZ1_FILIAL ='" + xFilial("ZZ1")   + "'"
                    cQry += "   AND ZZ1_VIAGEM ='" +  cViagem + "'"
                    cQry += "   AND ZZ1_SEQ    ='" +  cSequen + "'"
                    cQry := ChangeQuery(cQry)
                    If Select("Q2ZZ1") > 1
                        Q2ZZ1->(DbCloseArea())
                    Endif
                    TcQuery cQry New Alias "Q2ZZ1"

                    While Q2ZZ1->(!EOF())

                        ZZ1->(DbGoTo(Q2ZZ1->RECZZ1))

                        //Gravo msg no registro
                        Reclock("ZZ1",.F.)
                        ZZ1->ZZ1_IDVIAG := Val(oXmlRet:_RETORNOVIAGEM:_IDOPERACAOVIAGEM:TEXT)
                        ZZ1->ZZ1_STATUS := "AUTORIZADO"
                        ZZ1->ZZ1_JSERRO := cJsonRet
                        ZZ1->(MsUnLock())

                        Q2ZZ1->(dbskip())
                    enddo
                    Q2ZZ1->(DbCloseArea())

                Endif

				DTR->(DbSetOrder(1))
				If DTR->(DbSeek(xFilial("DTR")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM ))
					If RecLock('DTR',.F.)
						DTR->DTR_CIOT := alltrim(oXmlRet:_RETORNOVIAGEM:_RETORNOITENS:_RETORNOITEM:_NUMEROCIOT:TEXT)
						DTR->DTR_FOROPE := cCodStrada
						DTR->DTR_LOJOPE := cLojStrada
						DTR->DTR_FORCTO := Posicione('DA3', 1, xFilial('DA3')+DTR->DTR_CODVEI, 'DA3_CODFOR')
						DTR->DTR_LOJCTO := Posicione('DA3', 1, xFilial('DA3')+DTR->DTR_CODVEI, 'DA3_LOJFOR')
						DTR->(MsUnlock())
					EndIf
				EndIf

                lRet := .T.

            Elseif oXmlRet:_RETORNOVIAGEM:_STATUSOPERACAO:TEXT != "PROCESSANDO"

                if At("<idOperacaoViagem>",cJsonRet) > 0

                    cViagem := ZZ1->ZZ1_VIAGEM
                    cSequen := ZZ1->ZZ1_SEQ
                    cQry := " SELECT"
                    cQry += "   R_E_C_N_O_ as RECZZ1"
                    cQry += " FROM " + RETSQLNAME("ZZ1")
                    cQry += " WHERE D_E_L_E_T_ = ' '"
                    cQry += "   AND ZZ1_FILIAL ='" + xFilial("ZZ1")   + "'"
                    cQry += "   AND ZZ1_VIAGEM ='" +  cViagem + "'"
                    cQry += "   AND ZZ1_SEQ    ='" +  cSequen + "'"
                    cQry := ChangeQuery(cQry)
                    If Select("Q2ZZ1") > 1
                        Q2ZZ1->(DbCloseArea())
                    Endif
                    TcQuery cQry New Alias "Q2ZZ1"

                    While Q2ZZ1->(!EOF())

                        ZZ1->(DbGoTo(Q2ZZ1->RECZZ1))

                        //Gravo msg no registro
                        Reclock("ZZ1",.F.)
                        ZZ1->ZZ1_IDVIAG := Val(oXmlRet:_RETORNOVIAGEM:_IDOPERACAOVIAGEM:TEXT)
                        ZZ1->ZZ1_STATUS := "APTO AUTORIZAR"
                        ZZ1->ZZ1_JSERRO := cJsonRet
                        ZZ1->(MsUnLock())

                        Q2ZZ1->(dbskip())
                    enddo
                    Q2ZZ1->(DbCloseArea())

                Endif

                //***ADICIONADO POR LUCAS ARRUDA - 21/01/2021
                DTQ->(RecLock("DTQ",.F.))
                DTQ->DTQ_IDOPE := alltrim(oXmlRet:_RETORNOVIAGEM:_RETORNOITENS:_RETORNOITEM:_NUCONTRATO:TEXT)
                DTQ->(MsUnlock())
                //DTQ->(DbSkip())

                DbSelectArea("DTY")
                DTY->(dbSetOrder(2))
                DTY->(dbSeek(xFilial("DTY")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM ))
                DTY->(RecLock("DTY",.F.))
                DTY->DTY_IDOPE := alltrim(oXmlRet:_RETORNOVIAGEM:_RETORNOITENS:_RETORNOITEM:_NUCONTRATO:TEXT)
                DTY->(MsUnlock())

                lRet := .T.

            Endif

        Endif

    Endif
Else

   cLogError := "Viagem ainda nao foi enviada para Tip Bank!"

Endif

Return lRet

/*/{Protheus.doc} AutorizaViagemTipFrete
Metodo para fazer a autorizacao da viagem
@author Leandro Rodrigues
@since 03/04/2020
@version P12
@param nulo
@return nulo
/*/
Method AutorizaViagemTipFrete(cChave,cLogError) Class IntegraTipFrete

Local cJson         := ""
Local cError        := ""
Local cWarning      := ""
Local lRet          := .F.
Local oRest         := Nil
Local oXmlRet       := Nil
Local cDataHora     := ""
Local cSequencia    := ""

ZZ1->(DbSetOrder(1))
DTA->(DbSetOrder(2))

//Instancia objeto de conexao
oRest := FWRest():New(Self:cApiTipFrete)

//informo o path do metodo
oRest:SetPath(Self:cPathAutoriza)

//Pego a ultima sequencia enviada
ConsultaEnvio( ,@cSequencia,.F.)

cQry := " SELECT"
cQry += "   R_E_C_N_O_ as RECZZ1"
cQry += " FROM " + RETSQLNAME("ZZ1")
cQry += " WHERE D_E_L_E_T_ = ' '"
cQry += "   AND ZZ1_FILIAL ='" + xFilial("ZZ1")   + "'"
cQry += "   AND ZZ1_VIAGEM ='" +  DTQ->DTQ_VIAGEM + "'"
cQry += "   AND ZZ1_SEQ    ='" +  cSequencia + "'"
cQry := ChangeQuery(cQry)
If Select("QZZ1") > 1
    QZZ1->(DbCloseArea())
Endif
TcQuery cQry New Alias "QZZ1"

If QZZ1->(!EOF())

    ZZ1->(DbGoTo(QZZ1->RECZZ1))

    cDataHora := Substr(dTos(ZZ1->ZZ1_DTENV),7,2) +Substr(dTos(ZZ1->ZZ1_DTENV),5,2)+Substr(dTos(ZZ1->ZZ1_DTENV),1,4)
    cDataHora += StrTran(ZZ1->ZZ1_HRENV,":","")+"00"

    //Relaciona os documentos carregados
    //If DTA->(DbSeek(xFilial("DTA")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM+DTQ->DTQ_FILORI+cChaveDoc ))
    If DTA->(DbSeek(xFilial("DTA")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM ))
            //Preparo json de envio
            cJson := "<confirmacaoViagem>"
            cJson +=    "<tipoOperacao>"        +   "01"                         + "</tipoOperacao>"
            cJson +=    "<idOperacaoViagem>"    +   cValToChar(ZZ1->ZZ1_IDVIAG)  + "</idOperacaoViagem>"
            cJson +=    "<dataRequisicao>"      +   cDataHora                    + "</dataRequisicao>"
            cJson +=    "<chave>"               +   cChave                       + "</chave>"
            cJson +=    "<modeloConhecimento>"  +   "1"                          + "</modeloConhecimento>"
            cJson +=    "<serieConhecimento>"   +   DTA->DTA_SERIE               + "</serieConhecimento>"
            cJson +=    "<numeroConhecimento>"  +   DTA->DTA_DOC                 + "</numeroConhecimento>"
            cJson += "</confirmacaoViagem>"
    Endif
Endif

// seto a string Json
oRest:SetPostParams(cJson)

If oRest:Post(Self:aHeadOut)

    cJsonRet :=  oRest:GetResult()

    if !Empty(cJsonRet)

        oXmlRet := XmlParser( cJsonRet, "_", @cError, @cWarning )

        //Se Autorizou Gravo link do contrato
        If oXmlRet:_CONFIRMACAOVIAGEM:_MENSAGEM:TEXT == "SUCESSO"

            RecLock("ZZ1",.F.)
            ZZ1->ZZ1_STATUS := "VIAGEM AUTORIZADA"
            ZZ1->ZZ1_CTR    := oXmlRet:_CONFIRMACAOVIAGEM:_LINKCONTRATO:TEXT
            ZZ1->(MsUnLock())

            lRet := .T.
        else

            cLogError := oXmlRet:_CONFIRMACAOVIAGEM:_MENSAGEM:TEXT
            lRet      := .F.

        Endif
    Endif

Endif

Return lRet

/*/{Protheus.doc} RetCodUf
Funcao para retornar o codigo IBGE da UF
@author Leandro Rodrigues
@since 03/04/2020
@version P12
@param nulo
@return nulo
/*/

Static Function RetCodUf(cUf)

Local aUF       := {}
Local cCodUf    := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna codigo corresponodente do IBGE para a UF                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if cUF == "RO"
   cCodUf := "11"
ElseIf cUF == "AC"
   cCodUf := "12"
ElseIf cUF == "AM"
   cCodUf:= "13"
ElseIf cUF == "RR"
   cCodUf:= "14"
ElseIf cUF == "PA"
   cCodUf:= "15"
ElseIf cUF == "AP"
   cCodUf:= "16"
ElseIf cUF == "TO"
   cCodUf:= "17"
ElseIf cUF == "MA"
   cCodUf:= "21"
ElseIf cUF == "PI"
   cCodUf:= "22"
ElseIf cUF == "CE"
   cCodUf:= "23"
ElseIf cUF == "RN"
   cCodUf:= "24"
ElseIf cUF == "PB"
   cCodUf:= "25"
ElseIf cUF == "PE"
   cCodUf:= "26"
ElseIf cUF == "AL"
   cCodUf:= "27"
ElseIf cUF == "MG"
    cCodUf:= "31"
ElseIf cUF == "ES"
   cCodUf:= "32"
ElseIf cUF == "RJ"
   cCodUf:= "33"
ElseIf cUF == "SP"
   cCodUf:= "35"
ElseIf cUF == "PR"
   cCodUf:= "41"
ElseIf cUF == "SC"
   cCodUf:= "42"
ElseIf cUF == "RS"
   cCodUf:= "43"
ElseIf cUF == "MS"
   cCodUf:= "50"
ElseIf cUF == "MT"
   cCodUf:= "51"
ElseIf cUF == "GO"
   cCodUf:= "52"
ElseIf cUF == "DF"
   cCodUf:= "53"
ElseIf cUF == "SE"
   cCodUf:= "28"
ElseIf cUF == "BA"
   cCodUf:= "29"
Endif

return cCodUf


/*/{Protheus.doc} RetCodUf
Valida Se é reenvio de viagem
@author Leandro Rodrigues
@since 03/04/2020
@version P12
@param nulo
@return nulo
/*/

Static Function ConsultaEnvio(cDocCte,cSequencia,lOk,cIdViagem)

Local cQry          := ""
Local lRet          := .F.

Default cSequencia  := ""
Default cIdViagem   := ""
Default cDocCte   := ""

cQry := " SELECT"
cQry += "   MAX(R_E_C_N_O_) RECZZ1"
cQry += " FROM " + RETSQLNAME("ZZ1")
cQry += " WHERE D_E_L_E_T_ = ' '"
cQry += "   AND ZZ1_FILIAL ='" + xFilial("ZZ1")   + "'"

//Valido se ja foi autorizado
If lOk

    cQry += "   AND ZZ1_CTR <> ' '"
    cQry += "   AND ZZ1_DTCANC = ' '

Endif

IF !EMPTY(cDocCte)
    cQry += "   AND ZZ1_DOCCTE ='" +  cDocCte       + "'"
ENDIF

cQry += "   AND ZZ1_VIAGEM ='" +  DTQ->DTQ_VIAGEM + "'"

cQry := ChangeQuery(cQry)

If Select("QZZ1") > 1
    QZZ1->(DbCloseArea())
Endif

TcQuery cQry New Alias "QZZ1"

If QZZ1->(!EOF())

    ZZ1->(DbGoTo(QZZ1->RECZZ1))

    If !Empty(ZZ1->ZZ1_VIAGEM)

        If !Empty(cSequencia)

            cSequencia  := Soma1(ZZ1->ZZ1_SEQ)

        Else

            cSequencia := ZZ1->ZZ1_SEQ

        Endif

        cIdViagem := ZZ1->ZZ1_IDVIAG
        lRet := .T.

    endif
Endif

Return lRet


/*/{Protheus.doc} AutorizaViagemTipFrete
Metodo para fazer O cancelamento da viagem
@author Leandro Rodrigues
@since 03/04/2020
@version P12
@param nulo
@return nulo
/*/
Method CancelaViagemTipFrete(cChave,cLogError) Class IntegraTipFrete

Local cJson         := ""
Local cError        := ""
Local cWarning      := ""
Local lRet          := .F.
Local oRest         := Nil
Local oXmlRet       := Nil
Local cDataHora     := ""
Local cSequencia    := ""

ZZ1->(DbSetOrder(1))
DTA->(DbSetOrder(2))

//Instancia objeto de conexao
oRest := FWRest():New(Self:cApiTipFrete)

//informo o path do metodo
oRest:SetPath(Self:cPathAutoriza)

ConsultaEnvio( ,@cSequencia,.F.)

cQry := " SELECT"
cQry += "   R_E_C_N_O_ as RECZZ1"
cQry += " FROM " + RETSQLNAME("ZZ1")
cQry += " WHERE D_E_L_E_T_ = ' '"
cQry += "   AND ZZ1_FILIAL ='" + xFilial("ZZ1")   + "'"
cQry += "   AND ZZ1_VIAGEM ='" +  DTQ->DTQ_VIAGEM + "'"
cQry += "   AND ZZ1_SEQ    ='" +  cSequencia + "'"
cQry := ChangeQuery(cQry)
If Select("QZZ1") > 1
    QZZ1->(DbCloseArea())
Endif
TcQuery cQry New Alias "QZZ1"

If QZZ1->(!EOF())

    ZZ1->(DbGoTo(QZZ1->RECZZ1))

    cDataHora := Substr(dTos(ZZ1->ZZ1_DTENV),7,2) +Substr(dTos(ZZ1->ZZ1_DTENV),5,2)+Substr(dTos(ZZ1->ZZ1_DTENV),1,4)
    cDataHora += StrTran(ZZ1->ZZ1_HRENV,":","")+"00"

      //Relaciona os documentos carregados
    //If DTA->(DbSeek(xFilial("DTA")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM+DTQ->DTQ_FILORI+cChaveDoc ))

        //Preparo json de envio do cancelamento
        cJson := "<confirmacaoViagem>"
        cJson +=    "<tipoOperacao>"        +   "02"                        + "</tipoOperacao>"
        cJson +=    "<idOperacaoViagem>"    +   cValToChar(ZZ1->ZZ1_IDVIAG)  + "</idOperacaoViagem>"
        cJson +=    "<dataRequisicao>"      +   cDataHora                    + "</dataRequisicao>"
        cJson +=    "<motivoCancelamento>"  +   "Cancelamento de Viagem"     + "</motivoCancelamento>"
        cJson +=    "<chave>"               +   cChave                       + "</chave>"
        cJson += "</confirmacaoViagem>"

    //Endif

Endif

// seto a string Json
If !Empty(cJson)
    oRest:SetPostParams(cJson)

    If oRest:Post(Self:aHeadOut)

        cJsonRet :=  oRest:GetResult()

        if !Empty(cJsonRet)

            oXmlRet := XmlParser( cJsonRet, "_", @cError, @cWarning )

            If oXmlRet:_CONFIRMACAOVIAGEM:_MENSAGEM:TEXT == "SUCESSO" //oXmlRet:_RETORNOPADRAO:_MSG

                Reclock("ZZ1",.F.)
                ZZ1->ZZ1_USRCAN := RetCodUsr()
                ZZ1->ZZ1_DTCANC := dDataBase
                ZZ1->ZZ1_HRCANC := Time()
                ZZ1->(MsUnLock())

                lRet        := .T.

            else

                cLogError   := oXmlRet:_CONFIRMACAOVIAGEM:_MENSAGEM:TEXT
                lRet        := .F.

            Endif

        Endif

    Endif
Else
    cLogError   := 'Viagem não encontrada na TipBank'
    lRet        := .F.
Endif

Return lRet

/*/{Protheus.doc}
Metodo retorna o valor do frete somado
@author Leandro Rodrigues
@since 03/04/2020
@version P12
@param nulo
@return nulo
/*/
Static Function RetValFre()

Local cQry      := ""
Local nValFre   := 0

cQry := " SELECT"
cQry += "   SUM(DTY_VALFRE) VALFRE"
cQry += " FROM " + RETSQLNAME("DTY") + " DTY"
//cQry += " INNER JOIN " + RETSQLNAME("DT6") + " DT6"
//cQry += "   ON DT6_FILIAL = DTA_FILIAL"
//cQry += "   AND DT6_FILDOC = DTA_FILDOC"
//cQry += "   AND DT6_DOC = DTA_DOC"
//cQry += "   AND DT6_SERIE = DTA_SERIE"
cQry += " WHERE DTY.D_E_L_E_T_ = ' '"
cQry += "   AND DTY_FILIAL = '" + xFilial("DTY")  + "'"
cQry += "   AND DTY_VIAGEM = '" + DTQ->DTQ_VIAGEM + "'"
//cQry += "   AND DTA_DOC+DTA_SERIE  = '" + cChaveDoc + "'"

cQry += changeQuery(cQry)

If Select("QDTY")> 1

    QDTY->(DbCloseArea())

Endif

TcQuery cQry New Alias "QDTY"

If QDTY->(!EOF())

    nValFre := QDTY->VALFRE

Endif

Return nValFre

/*/{Protheus.doc}
Funcao para formatar o valor conforme Tip Bank
@author Leandro Rodrigues
@since 03/04/2020
@version P12
@param nulo
@return nulo
/*/
Static Function FormValor(nValFor,cTabela,cCampo,nTamanaho)

nValFor := Alltrim(Transform(nValFor,PesqPict(cTabela,cCampo)))
nValFor := StrTran(StrTran(nValFor,",",""),".","")

Return nValFor


/*/{Protheus.doc} fConsuTac
    (long_description)
    @type  Static Function
    @author Iago Tramontin
    @since 23/06/2026
/*/
Static Function fConsuTac(cUrl, aHeader, cChave, cCgcContra, cRNTRC, cCgcCtado, cErro)
    Local cJson         := ""
    Local cJsonRet      := ""
    Local cError        := ""
    Local cWarning      := ""
    Local oRest         := Nil
    Local oXmlRet       := Nil
    Local lRet          := .F.

    //Instancia objeto de conexao
    oRest := FWRest():New(cUrl)

    // informo o path do metodo
    oRest:SetPath("resources/consultaSituacaoTransportador/")

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

            If ValType(oXmlRet:_RETORNOSITUACAOTRANSPORTADOR:_TRANSPORTADOR:_MSG) == 'O'
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
				else
					cErro := 'Não foi possível identificar se é TAC ou ETC, verifique o cadastro do fornecedor ' + cCgcCtado
				Endif
			else
				cErro := 'Não foi possível identificar se é TAC ou ETC, verifique o cadastro do fornecedor ' + cCgcCtado
			Endif
        Endif
    Endif
Return lRet

/*/{Protheus.doc} ObterCustoPedagioTipFrete
    Metodo para consultar valor do pedagio online na Strada
    @type  Static Function
    @author Iago Tramontin
    @since 23/06/2026
/*/
Method ObterCustoPedagioTipFrete(cChave, cCnpjContra, cAdmPed, cCodRota, nQtdEixos, cPlaca, cCpfCnpjCtado, cLogError) Class IntegraTipFrete
    Local cXml         := ""
    Local cXmlRet      := ""
    Local cError       := ""
    Local cWarning     := ""
    Local oRest        := Nil
    Local oXmlRet      := Nil
    Local aRetPedagio  := {} // Posição 1: Valor, Posição 2: Precisao
		Local nFrmtVal := 0
		Local cValRet := ""

    cLogError := ""

    oRest := FWRest():New(Self:cApiTipFrete)
    oRest:SetPath(Self:cPathObtCusto)

    // Prepara o XML de envio conforme a documentação
    cXml := "<obtercusto>"
    cXml += "    <chave>"               + AllTrim(cChave)           + "</chave>"
    cXml += "    <cnpjContratante>"     + AllTrim(cCnpjContra)      + "</cnpjContratante>"
    cXml += "    <admPedagio>"          + AllTrim(cAdmPed)          + "</admPedagio>"
    cXml += "    <codigoRota>"          + AllTrim(cCodRota)         + "</codigoRota>"
    cXml += "    <quantidadeEixos>"     + cValToChar(nQtdEixos)     + "</quantidadeEixos>"
    cXml += "    <placa>"               + AllTrim(cPlaca)           + "</placa>"
    cXml += "    <cpfCnpjContratado>" + AllTrim(cCpfCnpjCtado)  + "</cpfCnpjContratado>"
    cXml += "</obtercusto>"

    oRest:SetPostParams(cXml)

    If oRest:Post(Self:aHeadOut)
        cXmlRet := oRest:GetResult()

        If !Empty(cXmlRet)
            oXmlRet := XmlParser( cXmlRet, "_", @cError, @cWarning )

			If Empty(cError) .And. ValType(oXmlRet:_OBTERCUSTO) == "O"

				If At("<msg>", cXmlRet) > 0 .And. ValType(oXmlRet:_OBTERCUSTO:_MSG) == "O"
					cLogError := "Erro API Pedágio: " + oXmlRet:_OBTERCUSTO:_MSG:TEXT
				ElseIf At("<valorTotalRota>", cXmlRet) > 0 .And. ValType(oXmlRet:_OBTERCUSTO:_VALORTOTALROTA) == "O"
					cValRet := oXmlRet:_OBTERCUSTO:_VALORTOTALROTA:TEXT
					nFrmtVal := Val(cValRet)
					AAdd(aRetPedagio, nFrmtVal)
					AAdd(aRetPedagio, Val(oXmlRet:_OBTERCUSTO:_PRECISAOVALORTOTALROTA:TEXT))
				Else
					cLogError := "API de Pedágio retornou XML inesperado, sem valorTotalRota e sem msg de erro."
				EndIf

			Else
				cLogError := "Erro no parser do retorno do pedágio."
			EndIf
        Else
            cLogError := "Retorno da API obter-custo-pedagio vazio."
        EndIf
    Else
        cLogError := "Erro de comunicação (Timeout/Falha) na API obter-custo-pedagio."
    EndIf

Return aRetPedagio
