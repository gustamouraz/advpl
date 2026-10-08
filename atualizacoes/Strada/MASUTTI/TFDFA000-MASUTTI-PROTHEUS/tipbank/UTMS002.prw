#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TopCONN.CH"
#Include "FWBrowse.ch"

//----------------------------------------------------------
/*/{Protheus.doc} UTMS002 
Função UTMS002 
@description Rotina para envio Cadastro de Viagem para Tip Bank
@author Leandro Rodrigues
@return nulo
@owner Masutti
@version Protheus 12 ou superior.
@build 1.0
@country Brasil
@language Portugues - Br
@since 26/10/2016 - Data de Revisão.

@param nulo

@sample 
@obs Rotina para envio Cadastro de Viagem para Tip Bank
	
@project TIP BANK
@history 26/10/2016, Adequação DOC , Adequação Doc Fontes. 
@table  ZZ0 - Autenticacao Tipank 
        ZZ1 - Viagens Enviadas Tip Bank
        DTA - Carregamento
        DTQ - Viagem
@see Importante: Esse Fonte deve ser compilado juntamente com os fontes UTMS001/UTMS003/TMA144MNU

/*/
//----------------------------------------------------------


User function UTMS002(nOpcao)

	Local cChave            := ""
	Local oXmlREt           := ""
	Local cChave            := ""
	Local lRet              := .T.
	Local cLogError         := ""
	Local cChaveDoc         := ""

	Static  oFrete := NIL

	oFrete := IntegraTipFrete():New()

//valida Chave de acesso
	ValidaChave(@cChave)

	If Empty(cChave )

		Help( ,, 'Help - Token Acesso',, 'Nao foi possivel obter o token de acesso a Tip Bank !', 1, 0 )
		lRet := .F.

	Endif

	if lRet

		//Preparo XML de Cadastra da Viagem
		if nOpcao == 1

			FWMsgRun(,{ || lRet := oFrete:CadastraRotaTipFrete(cChave,@cLogError) },  , "Aguarde... verificando cadastro da rota na Tip Bank...  " )

			//Cadastra Rota
			if lRet

				//Instancio o objeto para cadastro da viagemcChaveDoc
				FWMsgRun(,{ || lRet := oFrete:CadastraViagemTipFrete(cChave,@cLogError) },  , "Aguarde... Incluindo cadastro da Viagem na Tip Bank... " )

				if !lRet

					Help( ,, 'Inclusao Viagem',, cLogError, 1, 0 )
					lRet := .F.

				else

					MsgInfo("Viagem enviada para Tip Bank com sucesso!")

					//Consulta Viagem Tip Bank
					U_UTMS002(2)
					//U_UTMS002(2)
					//U_UTMS002(5)

				Endif
			else

				Help( ,, 'Cadastro Rota',, cLogError, 1, 0 )
				lRet := .F.

			Endif

		ElseIf nOpcao == 2 // Autoriza Viagem


			//valida Chave de acesso
			ValidaChave(@cChave)

			If Empty(cChave )

				Help( ,, 'Help - Token Acesso',, 'Nao foi possivel obter o token de acesso a Tip Bank !', 1, 0 )
				lRet := .F.

			Endif

			if lRet

				FWMsgRun(,{ || lRet := oFrete:ConsultaViagemTipFrete(cChave,@cLogError) },  , "Aguarde... Realizando a Consulta da Viagem na Tip Bank....  " )

				If !lRet

					Help( ,, 'Consulta Viagem',, cLogError, 1, 0 )
					lRet := .F.

				Else
					DTR->(DbSetOrder(1))
					If DTR->(DbSeek(xFilial("DTR")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM ))
						If Empty(DTR->DTR_CIOT)
							Help( ,, 'Consulta Viagem',, "Consulta realizada com sucesso, Viagem com status Apto a Autorizar", 1, 0 )
						Else
							Help( ,, 'Consulta Viagem',, "Consulta realizada com sucesso, Viagem com status Autorizado", 1, 0 )
						EndIf
					EndIf

					// ADD POR LUCAS ARRUDA - TOTVS SC
					// 20/07/2021
					//CHAMADA DE FONTE Rotina para envio de XML para proprietario de veiculo subalocado
					If MsgYesNo("Deseja enviar XML por email?", "Envio XML")
						FWMsgRun(,{ || U_UTMS004() },  , "Aguarde... Enviando XML...." )
					EndIf

				Endif

			Endif

		ElseIf nOpcao == 3 // Cancela Viagem

			If RetPosZZ1()

				If Empty(ZZ1->ZZ1_USRCAN)

					FWMsgRun(,{ || lRet := oFrete:CancelaViagemTipFrete(cChave,@cLogError) },  , "Aguarde... Cancelando Viagem na Tip Bank....  " )

					if lRet

						MsgInfo("Cancelamento realizado com sucesso !")

					Else
						Help( ,, 'Cancela Viagem',, cLogError, 1, 0 )
						lRet := .F.
					Endif
				Else

					Help( ,, 'Help - Cancelamento',, 'Viagem ja foi cancelada na Tip Bank !', 1, 0 )
					lRet := .F.

				Endif

			Endif
		ElseIf nOpcao == 4 // Download Contrato Viagem

			ValidaChave(@cChave)

			If Empty(cChave )

				Help( ,, 'Help - Token Acesso',, 'Nao foi possivel obter o token de acesso a Tip Bank !', 1, 0 )
				lRet := .F.

			Else
				If !fContrato(cChave, SM0->M0_CGC, @cLogError)

					Help( ,, 'Help - Consulta Arquivo Viagem',, cLogError, 1, 0 )
					lRet := .F.

				Else

					MsgInfo("O contrato foi baixado e aberto com sucesso!", "Consulta Arquivo Viagem")
					lRet := .T.

				EndIf
			Endif

		Elseif nOpcao == 5

			//Posiciona sequencia da viagem correta
			If RetPosZZ1()

				if Alltrim(ZZ1->ZZ1_STATUS) == "APTO AUTORIZAR"

					FWMsgRun(,{ || lRet := oFrete:AutorizaViagemTipFrete(cChave,@cLogError) },  , "Aguarde... Realizando a liberacao da Viagem na Tip Bank....  " )

					If !lRet

						Help( ,, 'Autoriza Viagem',, cLogError, 1, 0 )
						lRet := .F.

					else

						FWMsgRun(,{ || lRet := oFrete:ConsultaViagemTipFrete(cChave,@cLogError) },  , "Aguarde... Gravando Ciot....  " )

						If !lRet

							Help( ,, 'Consulta Viagem',, cLogError, 1, 0 )
							lRet := .F.

						Else
							If MsgYesNo("Viagem Autorizada com sucesso, Deseja Baixar Contrato !")

								If !fContrato(cChave, SM0->M0_CGC, @cLogError)

									Help( ,, 'Help - Consulta Arquivo Viagem',, cLogError, 1, 0 )
									lRet := .F.

								Endif
							Endif

						Endif
					Endif

				else

					Help( ,, 'Autoriza Viagem',, "Status da Viagem nao permite Autorizar, Verifica o status de retorno atraves da rotina de Consulta Viagem", 1, 0 )
					lRet := .F.

				Endif
			Endif

		Endif



	Endif


Return lRet

/*/{Protheus.doc} UTMS002
Rotina para Validar chave de acesso
@author Leandro Rodrigues
@since 03/04/2020
@version P12
@param nulo
@return nulo
/*/
Static Function ValidaChave(cChave)

	Local cQry          := ""
	Local cIntervalo    := SuperGetMv("MV_XINTAUT",,"00:30")

	ZZ0->( DbSetOrder(1))

	cQry := " SELECT"
	cQry += "   ZZ0_CHAVE"
	cQry += " FROM "+ RETSQLNAME("ZZ0") + " ZZ0"
	cQry += " WHERE ZZ0.D_E_L_E_T_ = ''"
	cQry += "   AND ZZ0_FILIAL = '" + xFilial("ZZ0")  + "'"
	cQry += "   AND ZZ0_DTENV  = '" + dTos(dDataBase) + "'"
	cQry += "   AND ZZ0_HRENV  < '" + Time()          + "'"
	cQry += "   AND ZZ0_HRVAL  > '" + Time()          + "'"

	cQry:= ChangeQuery(cQry)

	If Select("QZZ0")>1
		QZZ0->(DbCloseArea())
	Endif

	TcQuery cQry New Alias "QZZ0"

	If Empty( QZZ0->ZZ0_CHAVE )

		//Metodo de autenticado na plataforma TipFrete
		oFrete:AutenticacaoTipFrete(@cChave)

		if !Empty(cChave)

			//Valido se ja existe a chave
			If !ZZ0->(DbSeek(xFilial("ZZ0")+cChave ))

				//Gravo nova chave temporaria( 30 minutos )
				If RecLock("ZZ0",.T.)

					ZZ0->ZZ0_FILIAL     := xFilial("ZZ0")
					ZZ0->ZZ0_DTENV      := dDataBase
					ZZ0->ZZ0_HRENV      := Time()
					ZZ0->ZZ0_DTVAL      := dDataBase
					ZZ0->ZZ0_HRVAL      := Strtran(cValToChar( StrZero(SomaHoras(Time(),cIntervalo),5)),".",":")
					ZZ0->ZZ0_CHAVE      := cChave

					ZZ0->(MsUnLock())

				Endif

			Endif

		Endif

	Else

		cChave := Alltrim(QZZ0->ZZ0_CHAVE)

	Endif

Return

/*/{Protheus.doc} UTMS002
Rotina posicionar na ultima sequencia da ZZ1
@author Leandro Rodrigues
@since 03/04/2020
@version P12
@param nulo
@return nulo
/*/
Static Function RetPosZZ1()

	Local cQry   := ""
	Local lRet   := .F.

	cQry := " SELECT"
	cQry += "   MAX(R_E_C_N_O_) RECZZ1"
	cQry += " FROM " + RETSQLNAME("ZZ1")
	cQry += " WHERE D_E_L_E_T_ = ' '"
	cQry += "   AND ZZ1_FILIAL ='" + xFilial("ZZ1")   + "'"
	cQry += "   AND ZZ1_VIAGEM ='" +  DTQ->DTQ_VIAGEM + "'"
//cQry += "   AND ZZ1_DOCCTE ='" +  StrTran(cChaveDoc," ","") + "'"

	cQry := ChangeQuery(cQry)

	If Select("QZZ1") > 1
		QZZ1->(DbCloseArea())
	Endif

	TcQuery cQry New Alias "QZZ1"

	If QZZ1->(!EOF())

		ZZ1->(DbGoTo(QZZ1->RECZZ1))
		lRet   := .T.

	Endif

Return lRet

/*/{Protheus.doc} UTMS002
Monta tela para Selecionar Viagem
@author Leandro Rodrigues
@since 05/05/2020
@version P12
@param nulo
@return nulo
/*/
Static Function GetDocViagem()

	Local oPanel    := Nil
	Local oBrowse   := Nil
	Local oBrowse   := Nil
	Local lOk       := .F.

	DEFINE DIALOG oDlg TITLE 'Documentos Viagem' PIXEL

	oDlg:nWidth := 520
	oDlg:nHeight:= 315

	oPanel      := TPanel():New(0,0,"",oDlg  ,,,,,,40,40)
	oBtnPanel   := TPanel():New(0,0,"",oPanel,,,,,,40,120)

	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	oBtnPanel:Align := CONTROL_ALIGN_TOP

//Cria tabela temporaria que vai conter os dADOS
	CriaTabTemp("QDTA")

	If QDTA->(RECCOUNT()) > 1

		// Define o Browse
		oBrowse := FWBrowse():New(oBtnPanel)
		oBrowse:SetDataTable(.T.)
		oBrowse:SetAlias("QDTA")
		oBrowse:DisableReport()

		// Cria uma coluna de marca/desmarca
		oColumn := oBrowse:AddMarkColumns({||If( QDTA->DTA_OK == 'T','LBOK','LBNO')},{|oBrowse| MarkBrowse( oBrowse,"QDTA","DTA_OK" ) },{|oBrowse|/* Função de HEADERCLICK*/})

		ADD COLUMN oColumn DATA { || DTA_VIAGEM  } TITLE Alltrim(GetSx3Cache("DTA_VIAGEM","X3_TITULO")) SIZE TamSx3("DTA_VIAGEM")[1]  OF oBrowse
		ADD COLUMN oColumn DATA { || DTA_DOC     } TITLE Alltrim(GetSx3Cache("DTA_DOC"   ,"X3_TITULO")) SIZE TamSx3("DTA_DOC")[1]     OF oBrowse
		ADD COLUMN oColumn DATA { || DTA_SERIE   } TITLE Alltrim(GetSx3Cache("DTA_SERIE" ,"X3_TITULO")) SIZE TamSx3("DTA_SERIE")[1]   OF oBrowse

		@ 125, 165 BUTTON oBtnPanel PROMPT "Confirmar" SIZE 037, 015 OF oPanel PIXEL ACTION (lOk:=.T.,oDlg:End())
		@ 125, 210 BUTTON oBtnPanel PROMPT "Cancelar"  SIZE 037, 015 OF oPanel PIXEL ACTION (lOk:=.F.,oDlg:End())


		oBrowse:SetSeek()
		oBrowse:Activate()

		ACTIVATE DIALOG oDlg CENTER

	else
		lOk := .T.
	Endif

	QDTA->(DbGoTop())

Return lOk

/*/{Protheus.doc} 
Cria Tabela temporaria
@author Leandro Rodrigues
@since 05/05/2020
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function CriaTabTemp(cAlias)

	Local oTable 	:= Nil
	Local aCampos	:= {}
	Local cIndice1	:= ""
	Local cIndice2	:= ""

	aCampos:= {	{"DTA_OK"		,"C",001,0},;
		{"DTA_VIAGEM"	,"C",TamSX3("DTA_VIAGEM")[1]    ,0},;
		{"DTA_DOC"   	,"C",TamSX3("DTA_DOC")[1]       ,0},;
		{"DTA_SERIE"   	,"C",TamSX3("DTA_SERIE")[1]     ,0} }

	cIndice1 := "DTA_DOC"
	cIndice2 := "DTA_OK"

//Valida se ja existe a tabela criada
	if Select(cAlias) > 1
		(cAlias)->(DbCloseArea())
	endif

	oTable:= FWTemporaryTable():New(cAlias)

//Inserindo campos no alias temporario
	oTable:SetFields(aCampos)

//---------------------
//Criação dos índices
//---------------------
	oTable:AddIndex("01", { cIndice1	} )
	oTable:AddIndex("02", { cIndice2	} )

//---------------------------------------------------------------
//tabela criado no espaço temporário do DB
//---------------------------------------------------------------
	oTable:Create()
//------------------------------------

//Carrega dados na tebela temporaria
	GetTabTemp(cAlias)

Return

/*/{Protheus.doc} Pag2Layout
Rotina para carregar Tabela temporaria
@author Leandro Rodrigues
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function GetTabTemp(cAlias)

	DTA->(DbSetOrder(2))

	If DTA->(DbSeek(xFilial("DTA")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM ))

		While DTA->(!EOF()) ;
				.AND. xFilial("DTA")+DTA->DTA_FILORI+DTA->DTA_VIAGEM == xFilial("DTQ")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM

			Reclock("QDTA",.T.)

			QDTA->DTA_OK 		:= "T"
			QDTA->DTA_VIAGEM	:= DTA->DTA_VIAGEM
			QDTA->DTA_DOC		:= DTA->DTA_DOC
			QDTA->DTA_SERIE	    := DTA->DTA_SERIE

			QDTA->(MsUnLock())

			DTA->(DbSkip())
		EndDo

	endif

Return

/*/{Protheus.doc} 
Marca e desmarca Browse
@author Leandro Rodrigues
@since 05/05/2020
@version P12
@param Nao recebe parametros
@return nulo
/*/

Static Function MarkBrowse(oBrowse,cAlias)

	Local lRet 	   := .T.
	Local nPosAtu  := oBrowse:At()
	Local aArea	   := (cAlias)->(GetArea())

	(cAlias)->(DbSetOrder(1))

//Valido se tem algum item ja marcado
	if (cAlias)->(DbSeek((cAlias)->DTA_DOC))

		//Desmarco item
		Reclock(cAlias,.F.)
		(cAlias)->DTA_OK := iif( (cAlias)->DTA_OK == "T","","T" )
		(cAlias)->(MsUnLock())

	endif

	oBrowse:Refresh()
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} fContrato
    Realiza a consulta de arquivos de viagem via API Strada/Marketpay
    @type  Static Function
    @author Iago Tramontin
    @since 26/06/2026
/*/
Static Function fContrato(cChave, cCnpjContra, cErro)
	Local cXml          := ""
	Local cXmlRet       := ""
	Local cError        := ""
	Local cWarning      := ""
	Local oRest         := Nil
	Local oXmlParsed    := Nil
	Local lRet          := .F.
	Local cUrl          := SuperGetMV("MV_XAPTPFT",,"https://appslab.marketpay.com.br/hwsconvenio/")
	Local aHeader       := {}
	Local cNomeArq      := ""
	Local cBase64       := ""
	Local cConteudo     := ""
	Local cTempPath     := ""

	cErro               := ""

	// Inicializa a classe REST com a URL base
	oRest := FWRest():New(cUrl)
	oRest:SetPath("resources/consultaArquivosViagem/")

	Aadd(aHeader, "Content-Type:application/xml")

	// Prepara o XML de envio
	cXml := "<consultaArquivosViagem>"
	cXml += "    <chave>"           + AllTrim(cChave)      + "</chave>"
	cXml += "    <cnpjContratante>" + AllTrim(cCnpjContra) + "</cnpjContratante>"
	cXml += "    <nuContrato>"      + AllTrim(DTQ->DTQ_IDOPE) + "</nuContrato>"
	cXml += "    <tipoArquivo>"     + "CONTRATO"            + "</tipoArquivo>"
	cXml += "</consultaArquivosViagem>"

	// Seta a string XML no corpo da requisição
	oRest:SetPostParams(cXml)

	If oRest:Post(aHeader)

		cXmlRet := oRest:GetResult()

		If !Empty(cXmlRet)

			// Faz o parser do retorno XML
			oXmlParsed := XmlParser( cXmlRet, "_", @cError, @cWarning )

			If Empty(cError)

				If ValType(oXmlParsed:_CONSULTAARQUIVOSVIAGEMRESPONSE) == "O"

					If ValType(oXmlParsed:_CONSULTAARQUIVOSVIAGEMRESPONSE:_MENSAGEM) == "O"

						If ValType(oXmlParsed:_CONSULTAARQUIVOSVIAGEMRESPONSE:_MENSAGEM:TEXT) == "C" .And. ;
								Upper(Alltrim(oXmlParsed:_CONSULTAARQUIVOSVIAGEMRESPONSE:_MENSAGEM:TEXT)) == "SUCESSO"

							If ValType(oXmlParsed:_CONSULTAARQUIVOSVIAGEMRESPONSE:_ARQUIVO) == "O" .And. ;
									ValType(oXmlParsed:_CONSULTAARQUIVOSVIAGEMRESPONSE:_ARQUIVO:_NOME) == "O" .And. ;
									ValType(oXmlParsed:_CONSULTAARQUIVOSVIAGEMRESPONSE:_ARQUIVO:_DADOS) == "O"

								cNomeArq := AllTrim(oXmlParsed:_CONSULTAARQUIVOSVIAGEMRESPONSE:_ARQUIVO:_NOME:TEXT)
								cBase64  := oXmlParsed:_CONSULTAARQUIVOSVIAGEMRESPONSE:_ARQUIVO:_DADOS:TEXT

								cConteudo := Decode64(cBase64)
								cTempPath := AllTrim(GetTempPath()) + cNomeArq

								MemoWrite(cTempPath, cConteudo)
								ShellExecute("Open", cTempPath, "", AllTrim(GetTempPath()), 1)

								If nRet <= 32
									cErro := "Não foi possível abrir o arquivo " +cTempPath+ "!"
									lRet := .F.
								Else
									lRet := .T.
								EndIf

							Else
								cErro := "As tags <arquivo>, <nome> ou <dados> não foram encontradas no XML."
							EndIf

						Else
							cErro := oXmlParsed:_CONSULTAARQUIVOSVIAGEMRESPONSE:_MENSAGEM:Text
						EndIf
					Else
						cErro := "A tag <mensagem> não foi encontrada no retorno."
					EndIf
				Else
					cErro := "A tag raiz <consultaArquivosViagemResponse> não foi encontrada."
				EndIf
			Else
				cErro := "Erro ao realizar o parser do XML: " + cError
			EndIf

		Else
			cErro := "Retorno da API vazio."
		EndIf
	Else
		cErro := "Erro na requisição POST: " + oRest:GetLastError()
	EndIf

Return lRet
