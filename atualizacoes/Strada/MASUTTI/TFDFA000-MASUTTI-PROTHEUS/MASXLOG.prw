#INCLUDE 'TOTVS.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} MASXLOG
Classe para geração de log e IDToken de integração
@type Class
@version 
@author  
@Since   
/*/
//-------------------------------------------------------------------
Class MASXLOG

	Data tipo
	Data dtger
	Data hrger
	Data erro
	Data errome
	Data idtoken
	Data status
	Method NEW() constructor
	Method GRAVALOG()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} NEW
Metodo Construtor da Classe, e retorno do token  propriedade ::idtoken
@version 
@author  
@Since   
/*/
//-------------------------------------------------------------------
Method NEW() Class MASXLOG

	sleep(1) // Necessario fazer o Sleep, pois quando for efetuado varias requisições deverá fazer um intervalo de um milisegundos
	Self:tipo    := ""
	Self:erro    := ""
	Self:errome  := ""
	Self:idtoken := MD5(dtos(date())+time()+cvaltochar(MICROSECONDS()),2)
	Self:status  := ""
	Self:dtger   := ""
	Self:hrger   := ""

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} GRAVALOG
Metodo para gração do Log
@version 
@author  
@Since   
@param  ctipo, C,|P001| Documentos 
@param  cidtoken, C, ID Token de integração
@param  cErro, C, Mensagem de Erro
@param  cErrome, C, Mensagem de Erro completa - Exemplo: ErrorLog
@param  cStatus, C, Status 1=Ok;2=Erro;3=Reprocessado com Sucesso   
@return lOk , Retorno lógico que indica se gravou corretamente o LOG. 

/*/
//-------------------------------------------------------------------
Method GRAVALOG(ctipo,cidtoken,cErro,cErrome,cStatus,cChseek,cSeek) Class MASXLOG

	LOCAL lRet     := .T.

	IF EMPTY(ctipo) .OR. EMPTY(cidtoken)
		RETURN .F.
	ENDIF

	DbSelectArea("ZMV")
	DbSetorder(2)
	IF DBSEEK(  xFilial("ZMV")+cidtoken )
		RECLOCK("ZMV",.F.)
	Else
		RECLOCK("ZMV",.T.)
	EndIf

	ZMV->ZMV_FILIAL	:=  xFilial("ZMV")
	ZMV->ZMV_TIPO	:=  ctipo
	ZMV->ZMV_IDTOKE	:=  cidtoken
	ZMV->ZMV_DTGER	:=  DATE()
	ZMV->ZMV_HRGER	:=  TIME()
	ZMV->ZMV_ERRO	:=  IIF( Empty(cErro) ,Self:erro, cErro)
	ZMV->ZMV_ERROME	:=  IIF( Empty(cErrome),Self:errome, cErrome)
	ZMV->ZMV_STATUS	:=  IIF(empty(cStatus), Self:status, cStatus)
	ZMV->ZMV_CHSEEK :=  IIF(empty(cChseek), "", cChseek)
	ZMV->ZMV_SEEK 	:=  IIF(empty(cSeek), "", cSeek)
	ZMV->(MsUnlock())

return lRet
