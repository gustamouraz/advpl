#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'RestFul.ch'
#INCLUDE "FWMVCDEF.CH"

User function M103API()
	
return

/*/{Protheus.doc} PROD
@description WebService Rest para realizar a inclusão na MATA103.
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
                    "D1_OPER": "51"	     } ,              
							 
                {   "D1_FILIAL": "01"    ,          
                    "D1_ITEM": "0002"      ,      
                    "D1_COD": "000003",          
                    "D1_LOCAL": "01"	      ,          
                    "D1_QUANT": 1		      ,          
                    "D1_VUNIT": 1000		  ,              
                    "D1_TOTAL": 1000  	  ,	            		
                    "D1_TES": "001"	      ,              
                    "D1_CC": "      " 	    ,
                    "D1_OPER": "51"	      } ],              
    "aCodBar" :[{   "E2_PARCELA": "001"    ,          
                    "E2_LINDIG": "00190000090350182472000549857175114830000015900"   }
            ]
}

// OBSERVAÇÃO
O ARRAY aCodBar recebe extamente o conteúdo do campo E2_PARCELA, então se em seu ambiente estiver gravando a parcela como:
Letras ou vazio, ou com quantidade de algarismos personalizado, deverá vir exatamente igual.
Quando no Protheus é gerado somente uma parcela, normalmente não grava o campo E2_PARCELA.
Nesse caso, sugiro enviar as duas opções, exemplo:
E2_PARCELA, "" E;
E2_PARCELA, "001"

Eu faço a busca de conteúdo exatamente igual ao campo gravado na SE2.

URl da requisição
http://claideslazareti139199.protheus.cloudtotvs.com.br:4050/rest/M103API
http://claideslazareti139201.protheus.cloudtotvs.com.br:4050/rest/M103API
https://claideslazareti136123.protheus.cloudtotvs.com.br:4050/rest/M103API
/*/
WSRESTFUL M103API DESCRIPTION "Serviço REST Integração de Documento de Entrada"
WSDATA RECEIVE As String //Json Recebido no corpo da requiçãO
WSMETHOD POST  	DESCRIPTION "INCLUI MATA103" 		 WSSYNTAX "/M103API || /M103API/{}"   
END WSRESTFUL

WSMETHOD POST WSRECEIVE RECEIVE WSSERVICE M103API

	Local cJSON := Self:GetContent() // Pega a string do JSON
	Local oParseJSON := JsonObject():New()
    Local oJsonRet 	 := JsonObject():New()
    Local aItem := {}
    Local aItens:= {}
    Local _cFilial := ""
    Local _aCodBar := {}
    Local _nX
    Local _nTitulos := 0
    Local _nLinhasGravadas := 0
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
        If oParseJSON["aItens"][_nX]:HasProperty("D1_OPER")
            aAdd(aItem, {"D1_OPER", oParseJSON["aItens"][_nX]["D1_OPER"], Nil}) //10
            aAdd(aItem, {"D1_CF", oParseJSON["aItens"][_nX]["D1_CF"], Nil}) //11
        EndIf
        AADD(aItens,aItem)
        aItem := {}
    Next
EndIf

If oParseJSON:hasProperty("aCodBar") 
    For _nX := 1 to Len(oParseJSON["aCodBar"])
        aItem := {}
        aAdd(aItem, oParseJSON["aCodBar"][_nX]["E2_PARCELA"]  )

        // O codigo de barras e gerado pelo Protheus a partir da linha digitavel.
        If oParseJSON["aCodBar"][_nX]:hasProperty("E2_LINDIG")
            aAdd(aItem, "E2_LINDIG")
            aAdd(aItem, oParseJSON["aCodBar"][_nX]["E2_LINDIG"])
            AADD(_aCodBar,aItem)
        EndIf
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

		MATA103(_aCabec, aItens, 3, .F.,/**/,/**/,/**/,)
		If lMsErroAuto
			_lRet := .F.
		    CONOUT("ERRO NA EXECAUTO")
            oJsonRet['MostraErro'] := MostraErro()
		Else    
			_lRet := .T.
            If Len(_aCodBar ) > 0 
                _cQuery := " SELECT SE2.R_E_C_N_O_ AS RECSE2, SE2.E2_PARCELA "
                _cQuery += " FROM "+RetSqlName("SE2")+" SE2 "
                _cQuery += " WHERE SE2.D_E_L_E_T_ <> '*' AND SE2.E2_FILIAL = '"+xFilial("SE2")+"' "
                _cQuery += "         AND SE2.E2_PREFIXO = '"+SF1->F1_PREFIXO+"' "
                // Dependendo da configuração financeira, a MATA103 pode gerar
                // E2_NUM a partir da duplicata ou do nÃºmero do documento.
                _cQuery += "         AND (SE2.E2_NUM = '"+SF1->F1_DUPL+"' "
                _cQuery += "              OR SE2.E2_NUM = '"+SF1->F1_DOC+"') "
                _cQuery += "         AND SE2.E2_TIPO = 'NF' "
                _cQuery += "         AND SE2.E2_FORNECE = '"+SF1->F1_FORNECE+"' "
                _cQuery += "         AND SE2.E2_LOJA = '"+SF1->F1_LOJA+"' "
                _cQuery += "         AND SE2.E2_ORIGEM LIKE 'MATA10%'  " //SÃ“ ATUALIZO AS QUE FORAM GERADAS PELA MATA 100 OU 103
                _cAlias := GetNextAlias()
                MpSysOpenQuery(_cQuery, _cAlias)
                If (_cAlias)->(!EOF())
                    While (_cAlias)->(!EOF())
                        _nTitulos := _nTitulos + 1
                        (_cAlias)->(DbSkip())
                    EndDo
                    (_cAlias)->(DbGoTop())
                    DbSelectArea("SE2")
                    While (_cAlias)->(!EOF())
                        _nPos := aScan(_aCodBar,{|x| Alltrim(x[1]) == Alltrim((_cAlias)->E2_PARCELA)  })

                        // Em documentos com apenas uma parcela, o Protheus pode
                        // gravar E2_PARCELA em branco. Havendo somente um titulo e
                        // uma linha digitavel recebida, ela pertence a esse titulo.
                        If _nPos == 0 .and. _nTitulos == 1 .and. Len(_aCodBar) == 1
                            _nPos := 1
                        EndIf

                        If _nPos > 0 
                            SE2->(DbGoTo((_cAlias)->RECSE2))
                            If SE2->(RECNO()) == (_cAlias)->RECSE2
                                If  SE2->(Reclock("SE2",.F.))
                                    SE2->E2_LINDIG := _aCodBar[_nPos][3]
                                    SE2->E2_CODBAR := FinLDCB(_aCodBar[_nPos][3])
                                    SE2->(MsUnLock())
                                    _nLinhasGravadas := _nLinhasGravadas + 1
                                EndIf
                            Endif
                        EndIf
                        (_cAlias)->(DbSkip())
                    EndDo
                EndIf
                (_cAlias)->(DbCloseArea())

                oJsonRet['titulosLocalizados'] := _nTitulos
                oJsonRet['linhasDigitaveisGravadas'] := _nLinhasGravadas
            EndIf
			ConOut(DtoC(Date())+" "+Time()+"Inclusão de NF pela ACMAT103 com sucesso.")
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

