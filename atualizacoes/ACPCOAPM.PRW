#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'RestFul.ch'
#INCLUDE "FWMVCDEF.CH"

User function ACPCOAPM()
	
return

/*/{Protheus.doc} PROD
@description WebService Rest para realizar a inclusão na MATA103.
@author Johnny Santos
@since 20/01/2025
@type class

Deve ser aplicado no Serciço REST
Modelo de Requisição 

{

    "aItens" :[{
                    "AKD_FILIAL"            : "060101",
                    "AKD_CO"                : "41102002",
                    "AKD_CC"                : "1112",
                    "AKD_DATA"              : "20200101",
                    "AKD_CLASSE"            : "000025",
                    "AKD_TIPO"              : "1",
                    "VALOR"                 : "10",
                    "AKD_HIST"              : "TESTE TI",
                    "AKD_TPSALD"            : "RE",
                    "AKD_TMORC"             : "TR"
                },
                {
                    "AKD_FILIAL"            : "060102",
                    "AKD_CO"                : "41102001",
                    "AKD_CC"                : "1117",
                    "AKD_DATA"              : "20210101",
                    "AKD_CLASSE"            : "000010",
                    "AKD_TIPO"              : "1",
                    "VALOR"                 : "11",
                    "AKD_HIST"              : "TESTE TI",
                    "AKD_TPSALD"            : "OR",
                    "AKD_TMORC"             : "AN"     
                }
            ]
}


URl da requisição 
https://claideslazareti139201.protheus.cloudtotvs.com.br:4050/rest/ACPCOAPM
/*/
WSRESTFUL ACPCOAPM DESCRIPTION "Serviço REST Integração de Lançamento do PCO"
WSDATA RECEIVE As String //Json Recebido no corpo da requição
WSMETHOD POST  	DESCRIPTION "INCLUI PCOA500" 		 WSSYNTAX "/ACPCOAPM || /ACPCOAPM/{}"   
END WSRESTFUL

WSMETHOD POST WSRECEIVE RECEIVE WSSERVICE ACPCOAPM
	Local cJSON := Self:GetContent() // Pega a string do JSON
	Local oParseJSON := JsonObject():New()
    Local oJsonRet 	 := JsonObject():New()
    Local aItem := {}
    Local aItens:= {}
    Local _nX
    Local cError      	:= ""
	Local oError     	:= ErrorBlock({|e| cError := e:Description + e:ErrorStack})
    Local lRpc := .F.

    Private lMsHelpAuto := .F.
    Private lMsErroAuto := .F.

BEGIN SEQUENCE

If Select("SX2") == 0
    RpcClearEnv()
    RPCSetType(3)
    If(!RpcSetEnv("01", "060101", "", "", "PCO",,{"AK1","AK2","AK3","AK5","AK6","AKD"}))
        Return(Nil)
    EndIf
    lRPC := .T.
EndIf

ConOut(cJSON)

_aRet := oParseJson:FromJson(cJson)
ConOut(_aRet)

Conout(oParseJSON:ToJson())

If oParseJSON:hasProperty("aItens") 
ConOut(oParseJson)
Conout(oParseJSON["aItens"])
    For _nX := 1 to Len(oParseJSON["aItens"])
        Conout("passou pela linha "+cvaltochar(_nX))
        aAdd(aItem,  oParseJSON["aItens"][_nX]["AKD_FILIAL"]   )
        aAdd(aItem,  oParseJSON["aItens"][_nX]["AKD_CO"]   )
        aAdd(aItem,  oParseJSON["aItens"][_nX]["AKD_CC"]   )
        aAdd(aItem,  oParseJSON["aItens"][_nX]["AKD_DATA"]   )
        aAdd(aItem,  oParseJSON["aItens"][_nX]["AKD_CLASSE"]   )
        aAdd(aItem,  oParseJSON["aItens"][_nX]["AKD_TIPO"]   )
        aAdd(aItem,  oParseJSON["aItens"][_nX]["VALOR"]   )
        aAdd(aItem,  oParseJSON["aItens"][_nX]["AKD_HIST"]   )
        aAdd(aItem,  oParseJSON["aItens"][_nX]["AKD_TPSALD"]   )
        aAdd(aItem,  oParseJSON["aItens"][_nX]["AKD_TMORC"]   )

        AADD(aItens,aItem)
        aItem := {}
    Next
EndIf

	If Len(aItens) > 0 
        ConOut("Entrou nos itens")
        _cRet := U_ACPCOAPI(aItens)

		If !Empty(_cRet)
		    oJsonRet['MostraErro'] := _cRet
		Else    
			ConOut(DtoC(Date())+" "+Time()+"Inclusão de Lançamento na AKD feito com sucesso")
		EndIf
	EndIf

END SEQUENCE

ErrorBlock(oError)
	If Empty(cError)
		oJsonRet['sucesso']             := 'S'
		Self:setStatus(200)		
        Self:SetResponse(oJsonRet:toJson()) 
	Else
		oJsonRet['sucesso']     := 'N'
		oJsonRet['ErroLog']     := cError  
		Self:setStatus(500) 
        Self:SetResponse(oJsonRet:toJson()) 
	EndIf	
Return
