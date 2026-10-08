
//Bibliotecas
#Include "Protheus.ch"


User Function MASENVEM(cFildoc,cDocCte,cSeriecte, cChaCTE, cErro)

	Local cPara         := SUPERGETMV("MV_DSEMAIL",.F.," ") 
	Local cAssunto      := " "
	Local cCorpo        := " "
	Local cDads         := " "
	Local aErrosEmi     := {}
	DEFAULT cDocCte     := ""
	DEFAULT cSeriecte   := ""
	DEFAULT cFildoc     := ""
	DEFAULT cChaCTE     := ""
	DEFAULT cErro       := ""

	IF FWIsInCallStack("U_TM200EXC")

        cDads:= "Informações do Documento de entrada"+CRLF+"<br>"
		cDads+= "Filial: "+ cFildoc +CRLF+"<br>"
		cDads+= "Numero: " + cDocCte +CRLF+"<br>"
		cDads+= "Serie: " + cSeriecte +CRLF+"<br>"+"<br>"+"<br>"

		cDads+= "Informações do Cte Estornado"+CRLF+"<br>"
		cDads+= "Filial: "+ SubStr(cChaCTE,1,6) +CRLF+"<br>"
		cDads+= "Numero: " + SubStr(cChaCTE,8,9) +CRLF+"<br>"
		cDads+= "Serie: " + SubStr(cChaCTE,18,2) +CRLF+"<br>"+"<br>"+"<br>"

		cDads+= "Erro: "+ cErro +CRLF

		cAssunto += "Problema na Exclusão do Documento de Entrada"
		cCorpo += "<b>"+ cDads +"<b>"
		aErrosEmi := GEnvMail(cPara, cAssunto, cCorpo, , .T.)

	ELSE

		cDads:= "Numero: " + cDocCte +CRLF+"<br>"
		cDads+= "Serie: " + cSeriecte +CRLF+"<br>"
		cDads+= "CTE gerado na Filial: "+ cFildoc +CRLF+"<br>"
		cDads+= "Chave do CTE: "+ cChaCTE +CRLF+"<br>"+"<br>"+"<br>"
		cDads+= "Erro: "+ cErro +CRLF

		cAssunto += "Problema na inclusão do Documento de Entrada "
		cCorpo += "<b>"+ cDads +"<b>"
		aErrosEmi := GEnvMail(cPara, cAssunto, cCorpo, , .T.)

	ENDIF



Return aErrosEmi

/*/{Protheus.doc} zEnvMail
Função para disparo do e-mail utilizando TMailMessage e tMailManager com opção de múltiplos anexos
@author TOTVS SC
@since 07/2021
@version 1.0
@type function
    @param cPara, characters, Destinatário que irá receber o e-Mail
    @param cAssunto, characters, Assunto do e-Mail
    @param cCorpo, characters, Corpo do e-Mail (com suporte à html)
    @param aAnexos, array, Anexos que estarão no e-mail (devem estar na mesma pasta da protheus data)
    @param lMostraLog, logical, Define se será mostrado mensagem de log ao usuário (uma tela de aviso)
    @param lUsaTLS, logical, Define se irá utilizar o protocolo criptográfico TLS
    @return lRet, Retorna se houve falha ou não no disparo do e-Mail
@example Exemplos:
    -----
    1 - Mensagem Simples de envio
    u_zEnvMail("teste@servidor.com.br", "Teste", "Teste TMailMessage - Protheus", , .T.)
 
    -----
    2 - Mensagem com anexos (devem estar dentro da Protheus Data)
    aAnexos := {}
    aAdd(aAnexos, "\pasta\arquivo1.pdf")
    aAdd(aAnexos, "\pasta\arquivo2.pdf")
    aAdd(aAnexos, "\pasta\arquivo3.pdf")
    u_zEnvMail("teste@servidor.com.br", "Teste", "Teste TMailMessage com anexos - Protheus", aAnexos)
 
@obs Deve-se configurar os parâmetros:
    * MV_RELACNT - Conta de login do e-Mail    - Ex.: email@servidor.com.br
    * MV_RELPSW  - Senha de login do e-Mail    - Ex.: senha
    * MV_RELSERV - Servidor SMTP do e-Mail     - Ex.: smtp.servidor.com.br:587
    * MV_RELTIME - TimeOut do e-Mail           - Ex.: 120
/*/

Static Function GEnvMail(cPara, cAssunto, cCorpo, aAnexos, lMostraLog, lUsaTLS, cCC)

	Local aArea        := GetArea()
	Local nAtual       := 0
	Local lRet         := .T.
	Local oMsg         := Nil
	Local oSrv         := Nil
	Local nRet         := 0
	Local cFrom        := Alltrim(GetMV("MV_RELACNT"))
	Local cUser        := SubStr(cFrom, 1, At('@', cFrom)-1)
	Local cPass        := Alltrim(GetMV("MV_RELPSW"))
	Local cSrvFull     := Alltrim(GetMV("MV_RELSERV"))
	Local cServer      := Iif(':' $ cSrvFull, SubStr(cSrvFull, 1, At(':', cSrvFull)-1), cSrvFull)
	Local nPort        := Iif(':' $ cSrvFull, Val(SubStr(cSrvFull, At(':', cSrvFull)+1, Len(cSrvFull))), 587)
	Local nTimeOut     := GetMV("MV_RELTIME")
	Local cLog         := ""
	Default cPara      := ""
	Default cAssunto   := ""
	Default cCorpo     := ""
	Default aAnexos    := {}
	Default lMostraLog := .F.
	Default lUsaTLS    := .T.
	Default cCC     := ""

	//Se tiver em branco o destinatário, o assunto ou o corpo do email
	If Empty(cPara) .Or. Empty(cAssunto) .Or. Empty(cCorpo)
		cLog += "001 - Destinatario, Assunto ou Corpo do e-Mail vazio(s)!" + CRLF
		lRet := .F.
	EndIf

	If lRet
		//Cria a nova mensagem
		oMsg := TMailMessage():New()
		oMsg:Clear()

		//Define os atributos da mensagem
		oMsg:cFrom    := cFrom
		oMsg:cTo      := cPara
		oMsg:cSubject := cAssunto
		oMsg:cBody    := cCorpo
		oMsg:cCC      :=  cCC


		//Percorre os anexos
		For nAtual := 1 To Len(aAnexos)
			//Se o arquivo existir
			If File(aAnexos[nAtual])

				//Anexa o arquivo na mensagem de e-Mail
				nRet := oMsg:AttachFile(aAnexos[nAtual])
				If nRet < 0
					cLog += "002 - Nao foi possivel anexar o arquivo '"+aAnexos[nAtual]+"'!" + CRLF
				EndIf

				//Senao, acrescenta no log
			Else
				cLog += "003 - Arquivo '"+aAnexos[nAtual]+"' nao encontrado!" + CRLF
			EndIf
		Next

		//Cria servidor para disparo do e-Mail
		oSrv := tMailManager():New()

		//Define se irá utilizar o TLS
		If lUsaTLS
			oSrv:SetUseTLS(.T.)
		EndIf

		//Inicializa conexão
		nRet := oSrv:Init("", cServer, cUser, cPass, 0, nPort)
		If nRet != 0
			cLog += "004 - Nao foi possivel inicializar o servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
			lRet := .F.
		EndIf

		If lRet
			//Define o time out
			nRet := oSrv:SetSMTPTimeout(nTimeOut)
			If nRet != 0
				cLog += "005 - Nao foi possivel definir o TimeOut '"+cValToChar(nTimeOut)+"'" + CRLF
			EndIf

			//Conecta no servidor
			nRet := oSrv:SMTPConnect()
			If nRet <> 0
				cLog += "006 - Nao foi possivel conectar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
				lRet := .F.
			EndIf

			If lRet
				//Realiza a autenticação do usuário e senha
				nRet := oSrv:SmtpAuth(cFrom, cPass)
				If nRet <> 0
					cLog += "007 - Nao foi possivel autenticar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
					lRet := .F.
				EndIf

				If lRet
					//Envia a mensagem
					nRet := oMsg:Send(oSrv)
					If nRet <> 0
						cLog += "008 - Nao foi possivel enviar a mensagem: " + oSrv:GetErrorString(nRet) + CRLF
						lRet := .F.
					EndIf
				EndIf

				//Disconecta do servidor
				nRet := oSrv:SMTPDisconnect()
				If nRet <> 0
					cLog += "009 - Nao foi possivel disconectar do servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
				EndIf
			EndIf
		EndIf

		FreeObj(oMsg)
		FreeObj(oSrv)
		oMsg := NIL
		oSrv := NIL
	EndIf

	//Se tiver log de avisos/erros
	If !Empty(cLog)
		cLog := "zEnvMail - "+dToC(Date())+ " " + Time() + CRLF + ;
			"Funcao - " + FunName() + CRLF + CRLF +;
			"Existem mensagens de aviso: "+ CRLF +;
			cLog
		ConOut(cLog)

		//Se for para mostrar o log visualmente e for processo com interface com o usuário, mostra uma mensagem na tela
		If lMostraLog .And. ! IsBlind()
			Aviso("Log", cLog, {"Ok"}, 2)
		EndIf
	EndIf

	RestArea(aArea, cLog)

Return {lRet,cLog}


