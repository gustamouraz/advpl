#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'RestFul.ch'
#INCLUDE "FWMVCDEF.CH"

User function M140API()
	
return

/*/{Protheus.doc} PROD
@description WebService Rest para realizar a inclusão na MATA140.
@author Johnny Santos
@since 20/01/2025
@type class 

Deve ser aplicado no Serciço REST
Modelo de Requisição 

{	 "aCabec": [{  "F1_FILIAL":"01",
									"F1_TIPO":"N",
									"F1_FORMUL":"N",
									"F1_DOC":"20250919I",
									"F1_SERIE":"ACC",
									"F1_EMISSAO":"20250919",
									"F1_DTDIGIT":"20250919",
									"F1_FORNECE":"000006",
									"F1_LOJA":"01",
									"F1_ESPECIE":"NFS",
									"F1_SEGURO":0,
									"F1_FRETE":0,
									"F1_DESPESA":0,
									"F1_VALMERC":1000,
									"F1_VALBRUT":1000,
									"F1_COND":"009",
									"E2_NATUREZ":"000001" }  ] ,
    "aItens" :[{    "D1_FILIAL": "01"    ,          
                    "D1_ITEM": "0001"      ,      
                    "D1_COD": "000003",          
                    "D1_LOCAL": "01"	      ,          
                    "D1_QUANT": 1		      ,          
                    "D1_VUNIT": 1000		  ,              
                    "D1_TOTAL": 1000  	  ,	            		
                    "D1_TES": "001"	      ,              
                    "D1_CC": " " 	     ,
                    "D1_PEDIDO": " " 	     },
							 
                {   "D1_FILIAL": "01"    ,          
                    "D1_ITEM": "0002"      ,      
                    "D1_COD": "000003",          
                    "D1_LOCAL": "01"	      ,          
                    "D1_QUANT": 1		      ,          
                    "D1_VUNIT": 1000		  ,              
                    "D1_TOTAL": 1000  	  ,	            		
                    "D1_TES": "001"	      ,              
                    "D1_CC": "      " 	   ,
                    "D1_PEDIDO": "" 	    } ]
}

URl da requisição
http://claideslazareti139199.protheus.cloudtotvs.com.br:4050/rest/M140API
http://claideslazareti139201.protheus.cloudtotvs.com.br:4050/rest/M140API
https://claideslazareti136123.protheus.cloudtotvs.com.br:4050/rest/M140API
/*/
WSRESTFUL M140API DESCRIPTION "Serviço REST Integração de Documento de Entrada"
WSDATA RECEIVE As String //Json Recebido no corpo da requição
WSMETHOD POST  	DESCRIPTION "INCLUI MATA140" 		 WSSYNTAX "/M140API || /M140API/{}"   
END WSRESTFUL

WSMETHOD POST WSRECEIVE RECEIVE WSSERVICE M140API

	Local cJSON := Self:GetContent() // Pega a string do JSON
	Local oParseJSON := JsonObject():New()
    Local oJsonRet 	 := JsonObject():New()
    Local aItem := {}
    Local aItens:= {}
    Local _cFilial := ""
    Local _nX
    Local cError      	:= ""
	Local oError     	:= ErrorBlock({|e| cError := e:Description + e:ErrorStack})
    Local lRpc := .F.
    Local _aCabec := {}
    Private lMsHelpAuto := .F.
    Private lMsErroAuto := .F.

BEGIN SEQUENCE

If Select("SX2") == 0
    RpcClearEnv()
    RPCSetType(3)
    If(!RpcSetEnv("99", "01", "", "", "COM",,{"SF1","SD1","SF4","SB1","SE4","SA2"}))
        Return(Nil)
    EndIf
    lRPC := .T.
EndIf

ConOut(cJSON)

_aRet := oParseJson:FromJson(cJson)
ConOut("conout _aRet")
ConOut(_aRet)

ConOut("conout Json")
Conout(oParseJSON:ToJson())

If oParseJSON:hasProperty("aCabec") 
ConOut(oParseJson)
Conout(oParseJSON["aCabec"])
    For _nX := 1 to Len(oParseJSON["aCabec"])
        _cFilial := oParseJSON["aCabec"][_nX]["F1_FILIAL"]
        aAdd(_aCabec, {"F1_FILIAL",  oParseJSON["aCabec"][_nX]["F1_FILIAL"], Nil }   ) //01
        aAdd(_aCabec, {"F1_TIPO",    oParseJSON["aCabec"][_nX]["F1_TIPO"], Nil }   ) //02
        aAdd(_aCabec, {"F1_FORMUL",    oParseJSON["aCabec"][_nX]["F1_FORMUL"], Nil }   ) //03
        aAdd(_aCabec, {"F1_DOC",    oParseJSON["aCabec"][_nX]["F1_DOC"], Nil }   )  //04
        aAdd(_aCabec, {"F1_SERIE",    oParseJSON["aCabec"][_nX]["F1_SERIE"], Nil }   ) //05
        aAdd(_aCabec, {"F1_EMISSAO",    StoD(  oParseJSON["aCabec"][_nX]["F1_EMISSAO"])   , Nil }   ) //06
        aAdd(_aCabec, {"F1_DTDIGIT",    StoD(  oParseJSON["aCabec"][_nX]["F1_DTDIGIT"])   , Nil }   ) //07
        aAdd(_aCabec, {"F1_FORNECE",    oParseJSON["aCabec"][_nX]["F1_FORNECE"], Nil }   ) //08
        aAdd(_aCabec, {"F1_LOJA",    oParseJSON["aCabec"][_nX]["F1_LOJA"], Nil }   )     // 09
        aAdd(_aCabec, {"F1_ESPECIE",    oParseJSON["aCabec"][_nX]["F1_ESPECIE"], Nil }   ) //10
        aAdd(_aCabec, {"F1_SEGURO",    oParseJSON["aCabec"][_nX]["F1_SEGURO"]  , Nil } ) //11
        aAdd(_aCabec, {"F1_FRETE",    oParseJSON["aCabec"][_nX]["F1_FRETE"]  , Nil } )  //12
        aAdd(_aCabec, {"F1_DESPESA",    oParseJSON["aCabec"][_nX]["F1_DESPESA"] , Nil }  )  //13
        aAdd(_aCabec, {"F1_VALMERC",    oParseJSON["aCabec"][_nX]["F1_VALMERC"] , Nil }  )  //14
        aAdd(_aCabec, {"F1_VALBRUT",    oParseJSON["aCabec"][_nX]["F1_VALBRUT"] , Nil }  )  //15
        aAdd(_aCabec, {"F1_COND",    oParseJSON["aCabec"][_nX]["F1_COND"] , Nil }  )     //16
        aAdd(_aCabec, {"E2_NATUREZ",    oParseJSON["aCabec"][_nX]["E2_NATUREZ"] , Nil }  )  //17
    Next
EndIf

If oParseJSON:hasProperty("aItens") 
ConOut(oParseJson)
Conout(oParseJSON["aItens"])
    For _nX := 1 to Len(oParseJSON["aItens"])
        Conout("passou pela linha "+cvaltochar(_nX))
        aAdd(aItem, {"D1_FILIAL",   oParseJSON["aItens"][_nX]["D1_FILIAL"], Nil }   )   //01
        aAdd(aItem, {"D1_ITEM",   oParseJSON["aItens"][_nX]["D1_ITEM"] , Nil }  )   //02
        aAdd(aItem, {"D1_COD",   oParseJSON["aItens"][_nX]["D1_COD"], Nil }   )   //03
        aAdd(aItem, {"D1_LOCAL",   oParseJSON["aItens"][_nX]["D1_LOCAL"] , Nil }  )   //04
        aAdd(aItem, {"D1_QUANT",   oParseJSON["aItens"][_nX]["D1_QUANT"] , Nil }  )   //05
        aAdd(aItem, {"D1_VUNIT",   oParseJSON["aItens"][_nX]["D1_VUNIT"] , Nil }  )   //06
        aAdd(aItem, {"D1_TOTAL",   oParseJSON["aItens"][_nX]["D1_TOTAL"] , Nil }  )   //07
        aAdd(aItem, {"D1_TES",   oParseJSON["aItens"][_nX]["D1_TES"] , Nil }  )   //08
        aAdd(aItem, {"D1_CC",   oParseJSON["aItens"][_nX]["D1_CC"] , Nil }  )   //09
        aAdd(aItem, {"D1_PEDIDO",   oParseJSON["aItens"][_nX]["D1_PEDIDO"] , Nil }  )   //10

        AADD(aItens,aItem)
        aItem := {}
    Next
EndIf

    //Trecho que gera a Entrada
	If Len(aItens) > 0  .and. Len(_aCabec) > 0 
		lMsHelpAuto := .F.
		lMsErroAuto := .F.

		If _cFilial <> cFilAnt .and. !Empty(_cFilial)
			cFilAnt := _cFilial
			OpenSM0(cEmpAnt + cFilAnt)
		Endif

		MATA140(_aCabec, aItens, 3, .F.,/**/,/**/,/**/,)
		If lMsErroAuto
			_lRet := .F.
		    CONOUT("ERRO NA EXECAUTO")
            oJsonRet['MostraErro'] := MostraErro()
		Else    
			_lRet := .T.

			ConOut(DtoC(Date())+" "+Time()+"Inclusão de NF pela ACMAT140 com sucesso.")
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
