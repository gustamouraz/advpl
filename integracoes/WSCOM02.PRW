#Include 'totvs.ch'
#Include 'restful.ch'

/*/{Protheus.doc} User Function WSCOM02
	Reserva o nome da funo no RPO
	@type  Function
	@author Willian Kaneta
	@since 23/01/2023
	
	@version 1.0
	/*/
USER FUNCTION WSCOM02()

RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} WSMASUTTI_QUOTATION
    WsRest para consulta cotação - Novo portal fornecedor Masutti

    @Type Class

    @author  Willian Kaneta
    @since   23/01/2023
    @version 1.0.20230123

    @param idSubsidiary, character, código da Filial do sistema
    @param Token, character, Token para o fornecedor acessar a cotação
/*/
//-------------------------------------------------------------------
WSRESTFUL WSMASUTTI_QUOTATION DESCRIPTION "Serviço para Consulta Dados da Cotação para o Fornecedor." FORMAT application_json
	WsData IdSubsidiary 		As String
	WsData Token 				As String

	WSMETHOD GET 	RetDetailQuotation   	DESCRIPTION "Serviço para Consulta Dados da Cotação para o Fornecedor."   WSSYNTAX  "/WSMASUTTI_QUOTATION/" PRODUCES APPLICATION_JSON
	WSMETHOD POST 	UpdateQuotation     	DESCRIPTION "Serviço para Atualizar Dados da Cotação para o Fornecedor."  WSSYNTAX  "/WSMASUTTI_QUOTATION/" PRODUCES APPLICATION_JSON

END WSRESTFUL 

/*/{Protheus.doc} WSMASUTTI_QUOTATION
    WsRest para consulta dados da cotação

    @Type Class

    @author  Willian Kaneta
    @since   23/01/2023
    @version 1.0.20230123

    @param idSubsidiary, character, código da Filial do sistema
    @param Token, character, Token para o fornecedor acessar a cotação

    @return oRetDetailSC8, object, Classe WSMASUTTI_TOKENQUOTATION

/*/
WSMETHOD GET RetDetailQuotation WSRECEIVE IdSubsidiary, Token WSREST WSMASUTTI_QUOTATION

	Local lRet			:= .F.
	Local nA			:= 0
	Local cAliasTMP 	:= GetNextAlias()
	Local cTMPSC8 		:= GetNextAlias()
	Local aErro     	:= {}
	Local aCond 		:= {}
	Local oItemsSC8 	:= {}
	Local oRetDetailSC8 := Nil
	Local aAreaSM0 		:= SM0->(GetArea())
	Local aFieldSM0 	:= { ;
		"M0_CODIGO",;    //Posição [1]
		"M0_CODFIL",;    //Posição [2]
		"M0_NOMECOM",;   //Posição [3]
		"M0_CGC",;       //Posição [4]
		"M0_INSCM",;     //Posição [5]
		"M0_CIDENT",;    //Posição [6]
		"M0_ESTENT",;    //Posição [7]
		"M0_ENDENT",;    //Posição [8]
		"M0_BAIRENT",;   //Posição [9]
		"M0_CEPENT",;    //Posição [10]
		"M0_COMPENT",;   //Posição [11]
		"M0_TEL",;        //Posição [12]
		"M0_FILIAL",;	//Posição [13]
		"M0_ENDCOB",;	//Posição [14]
		"M0_CIDCOB",;	//Posição [15]
		"M0_ESTCOB",;	//Posição [16]
		"M0_CEPCOB"; 	//Posição [17]
	}
 
	Local aSM0Quotation	:= {}
	Local cDesTec		:= ""

	Default IdSubsidiary   := Self:IdSubsidiary
    Default Token          := Self:Token

	If ! Empty( IdSubsidiary ) .and. ! Empty( Token )
		lRet := .T.
		BeginSQL Alias cAliasTMP
		
			SELECT ZX3.*, SC8.C8_VALIDA
			FROM %TABLE:ZX3% ZX3 
			INNER JOIN %TABLE:SC8%  SC8 
				ON C8_FILIAL = ZX3_FILIAL
				AND C8_NUM = ZX3_NUMSC8
				AND C8_FORNECE = ZX3_FORNEC
				AND C8_LOJA = ZX3_LOJA
				AND C8_ITEM = '0001'
				AND SC8.%NOTDEL%
			 WHERE ZX3.ZX3_FILIAL = %EXP:IdSubsidiary%
			   AND ZX3.ZX3_TOKEN  = %EXP:Token%
			   AND ZX3.%NOTDEL%
			  
		EndSQL
		
		If !(cAliasTMP)->(EoF())
			
			oRetDetailSC8 := JsonObject():New()
			
			If SToD((cAliasTMP)->C8_VALIDA) >= Date()
				If Empty((cAliasTMP)->ZX3_FLAG )
					
					BeginSQL Alias cTMPSC8
			
						SELECT  SC8.C8_FILIAL,
								SC8.C8_NUM,
								SC8.C8_FORNECE,
								SC8.C8_LOJA, 
								SC8.C8_FORNOME,
								SC8.C8_FORMAIL,
								SC8.C8_VALIDA,
								SC8.C8_CONTATO,
								SC8.C8_XUSRCOD,
								SC8.C8_PRODUTO,
								SC8.C8_ITEM,
								SC8.C8_QUANT,
								SC8.C8_UM,
								SC8.C8_XMARCA,
								SC8.C8_PRECO,
								SC8.C8_VLDESC,
								SC8.C8_DESC,
								SC8.C8_TOTAL,
								SC8.C8_DATPRF,
								COALESCE((CONVERT(CHAR(50),SC8.C8_OBS)),'') AS C8_OBS,
								COALESCE((CONVERT(CHAR(50),SC8.C8_XOBSFN)),'') AS C8_XOBSFN, 
								COALESCE((CONVERT(CHAR(50),SC8.C8_XDESTEC)),'') AS C8_XDESTEC, 
								SC8.C8_NUMSC
						FROM %TABLE:SC8% SC8
						WHERE SC8.C8_NUM    	= %EXP:(cAliasTMP)->ZX3_NUMSC8%
							AND SC8.C8_FORNECE    = %EXP:(cAliasTMP)->ZX3_FORNEC%
							AND SC8.C8_LOJA    	= %EXP:(cAliasTMP)->ZX3_LOJA%
							AND SC8.C8_FILIAL 		= %EXP:(cAliasTMP)->ZX3_FILIAL%
							AND SC8.%NOTDEL%					
					EndSQL

					If !(cTMPSC8)->(EoF())
						_cC8_NUM     	:= (cTMPSC8)->C8_NUM
						_cC8_FORNECE 	:= (cTMPSC8)->C8_FORNECE
						_cC8_LOJA    	:= (cTMPSC8)->C8_LOJA

						aSM0Quotation := FWSM0Util():GetSM0Data(, idSubsidiary, aFieldSM0)

						oRetDetailSC8["code"]        		:= 200
						oRetDetailSC8["companyName"]  		:= AllTrim(aSM0Quotation[3][2])
						oRetDetailSC8["IdSubsidiary"]  		:= AllTrim(aSM0Quotation[13][2])
						oRetDetailSC8["address"]  			:= AllTrim(aSM0Quotation[14][2])
						oRetDetailSC8["city"]  				:= AllTrim(aSM0Quotation[15][2])
						oRetDetailSC8["state"]  			:= AllTrim(aSM0Quotation[16][2])
						oRetDetailSC8["zipCode"]  			:= AllTrim(aSM0Quotation[17][2])
						oRetDetailSC8["cgc"] 	 			:= AllTrim(aSM0Quotation[4][2])
						oRetDetailSC8["munRegistration"]	:= AllTrim(aSM0Quotation[5][2])
						oRetDetailSC8["phone"]				:= TRANSFORM(FWSM0Util():GetSM0Data(, "060110", aFieldSM0)[12][2],"@R (99) 9999-9999")

						RestArea(aAreaSM0)
						oRetDetailSC8["quotationCode"]  	:= (cTMPSC8)->C8_NUM     											
						oRetDetailSC8["quotationValidity"]  := Dtoc(STOD((cTMPSC8)->C8_VALIDA))  									
						oRetDetailSC8["quotationSupplier"]  := (cTMPSC8)->C8_FORNECE 											
						oRetDetailSC8["quotationStore"]  	:= (cTMPSC8)->C8_LOJA    											
						oRetDetailSC8["quotationContact"]  	:= (cTMPSC8)->C8_CONTATO    											
						oRetDetailSC8["quotationNameUser"]  := Posicione('SY1', 3, PadR( SubStr((cTMPSC8)->C8_FILIAL, 1, 4),TamSx3("C8_FILIAL")[1])  + (cTMPSC8)->C8_XUSRCOD , 'Y1_NOME' )	
						oRetDetailSC8["quotationPhone"]  	:= Posicione('SY1', 3, PadR( SubStr((cTMPSC8)->C8_FILIAL, 1, 4),TamSx3("C8_FILIAL")[1])  + (cTMPSC8)->C8_XUSRCOD, 'Y1_TEL' )	
						
						DbSelectArea("SA2")
						SA2->(DbSetOrder(1))

						SA2->(MsSeek(xFilial("SA2")+(cTMPSC8)->C8_FORNECE+(cTMPSC8)->C8_LOJA ))

						oRetDetailSC8["supplierId"]  		:= AllTrim(SA2->A2_NOME  	)
						oRetDetailSC8["supplierAddress"]  	:= AllTrim(SA2->A2_END   	)
						oRetDetailSC8["supplierCity"]  		:= AllTrim(SA2->A2_MUN   	)
						oRetDetailSC8["supplierDistrict"] 	:= AllTrim(SA2->A2_BAIRRO	)
						oRetDetailSC8["supplierTelephone"]	:= AllTrim(SA2->A2_TEL   	)
						oRetDetailSC8["supplierFax"]		:= AllTrim(SA2->A2_FAX   	)
						oRetDetailSC8["supplierCgc"]		:= AllTrim(SA2->A2_CGC   	)
						oRetDetailSC8["supplierTip"]		:= AllTrim(SA2->A2_TIPO   	)

						// Busca Condição de Pagamento
						DBSelectArea("SE4")
						SE4->(DbSetOrder(1))
						SE4->(DBGoTop())
						While SE4->(!Eof())				
							DbSelectArea("ZPA") // Fornecedor X Condição de Pagamento
							ZPA->(DbSetOrder(2))
							ZPA->(DBGoTop())							
							If ZPA->(MsSeek(xFilial("ZPA")+_cC8_FORNECE+_cC8_LOJA+SE4->E4_CODIGO))
								If Ascan(aCond,ZPA->ZPA_CONDPG+"-"+Alltrim(ZPA->ZPA_CONDIC))==0
									Aadd(aCond,ZPA->ZPA_CONDPG+"-"+Alltrim(ZPA->ZPA_CONDIC))
								Endif
							EndIf				
							SE4->(DBSkip())
						Enddo
						
						oACondPag   := {}
						For nA := 1 To Len( aCond )
							aAdd( oACondPag, aCond[ nA ] )
						Next nA

						oRetDetailSC8["paymentCondition"] := oACondPag
						
						While !(cTMPSC8)->(EoF())
							aAdd( oItemsSC8, JsonObject():New() )
							nPos := Len( oItemsSC8 ) 
							
							cDesTec := AllTrim(U_GDESCTECPROD((cTMPSC8)->C8_PRODUTO))

							DBSelectArea("SB1")
							SB1->(DBSetOrder(1))
							SB1->(DBSeek(xFilial("SB1") + (cTMPSC8)->C8_PRODUTO ))

							oItemsSC8[ nPos ]["item"] 			:= (cTMPSC8)->C8_ITEM
							oItemsSC8[ nPos ]["description"] 	:= IIF(!Empty(cDesTec), cDesTec, AllTrim(SB1->B1_DESC) )
							oItemsSC8[ nPos ]["codReference"] 	:= AllTrim(SB1->B1_XCODFAB)
							oItemsSC8[ nPos ]["fabric"] 	:= AllTrim(SB1->B1_FABRIC)
							oItemsSC8[ nPos ]["quantity"] 		:= (cTMPSC8)->C8_QUANT
							oItemsSC8[ nPos ]["um"] 			:= AllTrim((cTMPSC8)->C8_UM)
							oItemsSC8[ nPos ]["brand"] 			:= Iif(!Empty((cTMPSC8)->C8_XMARCA), (cTMPSC8)->C8_XMARCA, '')
							oItemsSC8[ nPos ]["price"] 			:= (cTMPSC8)->C8_PRECO  
							oItemsSC8[ nPos ]["discount"] 		:= (cTMPSC8)->C8_VLDESC 
							oItemsSC8[ nPos ]["pdiscount"] 		:= (cTMPSC8)->C8_DESC
							oItemsSC8[ nPos ]["value"] 			:= (cTMPSC8)->C8_TOTAL  
							oItemsSC8[ nPos ]["date"] 			:= DTOC(STOD((cTMPSC8)->C8_DATPRF)) 						 
							oItemsSC8[ nPos ]["obs"] 			:= Iif(!Empty((cTMPSC8)->C8_OBS), (cTMPSC8)->C8_OBS, '')
							oItemsSC8[ nPos ]["obsSupplier"]	:= Iif(!Empty((cTMPSC8)->C8_XOBSFN), (cTMPSC8)->C8_XOBSFN, '' )
							oItemsSC8[ nPos ]["desctec"] 		:= Iif(!Empty((cTMPSC8)->C8_XDESTEC), (cTMPSC8)->C8_XDESTEC, '')  
							oItemsSC8[ nPos ]["request"] 		:= (cTMPSC8)->C8_NUMSC
							
							(cTMPSC8)->(DbSkip())
						EndDo
						
						oRetDetailSC8["items"] := oItemsSC8

						FreeObj( oItemsSC8 )
					
					Else
						aErro := { 404, 'Not Found', 404, 'Not Found SC8' }	
						lRet := .F.
					EndIf
				Else
					oRetDetailSC8["tokenActive"] := .F.
					oRetDetailSC8["code"]        := 200
					oRetDetailSC8["message"]     := "Token Expired"
				EndIf
			Else
				oRetDetailSC8["tokenActive"] := .F.
				oRetDetailSC8["code"]        := 200
				oRetDetailSC8["message"]     := "Quotation Expired"
			EndIf

		Else
			aErro := { 404, 'Token Not Found', 404, 'Token Not Found' }	
			lRet := .F.
		EndIf
	Else
        aErro := { 400, 'Parametros Não preenchidos', 400, 'Um ou mais parmetros da requisição não foram preenchidos' }
    EndIf

	If lRet
        ::SetResponse(  oRetDetailSC8:toJSON() )
    Else
        If len( aErro ) > 0
			SetRestFault( aErro[ 1 ], EncodeUTF8( aErro[ 2 ] ), .T., aErro[ 3 ], EncodeUTF8( aErro[ 4 ] ) )
		Else
			SetRestFault( 501, EncodeUTF8( 'Erro Indeterminado' ), .T., 501, EncodeUTF8( 'Erro Indeterminado' ) )
		EndIf
    EndIf

	FreeObj( oRetDetailSC8 )
Return(lRet)


/*/{Protheus.doc} WSMASUTTI_QUOTATION
    WsRest para consulta dados da cotação

    @Type Class

    @author  Willian Kaneta
    @since   23/01/2023
    @version 1.0.20230123

    @param idSubsidiary, character, código da Filial do sistema
    @param Token, character, Token para o fornecedor acessar a cotação

    @return oRetDetailSC8, object, Classe WSMASUTTI_TOKENQUOTATION

/*/
WSMETHOD POST UpdateQuotation WSRECEIVE IdSubsidiary, Token WSREST WSMASUTTI_QUOTATION

	Local lRet			:= .F.
	Local aErro     	:= {}
	Local oRetUpdateSC8 := JsonObject():New()
	Local _nInd   		:= 0
	Local cBody			:= ""
	Local oBody         := JsonObject():New()
	Local cAliasTMP 	:= GetNextAlias()
	Local cTMPSC8 		:= GetNextAlias()

	Default IdSubsidiary   := Self:IdSubsidiary
    Default Token          := Self:Token

	::SetContentType( 'application/json;charset=UTF-8' )

	cBody := ::GetContent()

	If 	! Empty( IdSubsidiary ) .and. ! Empty( Token )
		BeginSQL Alias cAliasTMP
		
			SELECT TOP 1 ZX3.*, SC8.C8_VALIDA
			FROM %TABLE:ZX3% ZX3 
			INNER JOIN %TABLE:SC8%  SC8 
				ON C8_FILIAL = ZX3_FILIAL
				AND C8_NUM = ZX3_NUMSC8
				AND C8_FORNECE = ZX3_FORNEC
				AND C8_LOJA = ZX3_LOJA
				AND SC8.%NOTDEL%
			 WHERE ZX3.ZX3_FILIAL = %EXP:AllTrim(IdSubsidiary)%
			   AND ZX3.ZX3_TOKEN  = %EXP:AllTrim(Token)%
			   AND ZX3.%NOTDEL%
			  
		EndSQL

		(cAliasTMP)->(DBGoTop())
		
		If !(cAliasTMP)->(EoF())
			
			If SToD((cAliasTMP)->C8_VALIDA) >= Date()
				If Empty((cAliasTMP)->ZX3_FLAG )
					
					BeginSQL Alias cTMPSC8
			
						SELECT 	SC8.R_E_C_N_O_ RECNOC8
						FROM %TABLE:SC8% SC8
						WHERE SC8.C8_NUM    	= %EXP:(cAliasTMP)->ZX3_NUMSC8%
							AND SC8.C8_FORNECE  = %EXP:(cAliasTMP)->ZX3_FORNEC%
							AND SC8.C8_LOJA    	= %EXP:(cAliasTMP)->ZX3_LOJA%
							AND SC8.C8_FILIAL 	= %EXP:(cAliasTMP)->ZX3_FILIAL%
							AND SC8.%NOTDEL%
						
					EndSQL

					If !(cTMPSC8)->(EoF())
						If ValType(oBody:FromJson( cBody )) == "U"
							lRet := .T.
							DBSelectArea("SC8")
							SC8->(DbGoTo((cTMPSC8)->RECNOC8))
												
							For _nInd := 1 to Len(oBody['items'])

								If oBody['items'][_nInd]['price'] <= 0
									Loop
								EndIf

								nItem := oBody['items'][_nInd]['item']
								dData := oBody['items'][_nInd]['date']
								nNum  		:= SC8->C8_NUM
								nFornec  	:= SC8->C8_FORNECE
								nLoja  		:= SC8->C8_LOJA


								DBSelectArea("SC8")
								SC8->(DBSetOrder(1))
								
								If SC8->(MsSeek((cAliasTMP)->ZX3_FILIAL+Padr(nNum,TamSx3("C8_NUM")[1])+Padr(nFornec,TamSx3("C8_FORNECE")[1])+Padr(nLoja,TamSx3("C8_LOJA")[1])+Padr(nItem,TamSx3("C8_ITEM")[1])))
									If RecLock("SC8",.F.)

										SC8->C8_XMARCA 	:= oBody['items'][_nInd]['brand']
										SC8->C8_PRECO  	:= oBody['items'][_nInd]['price']
										SC8->C8_TOTAL  	:= ROUND(oBody['items'][_nInd]['quantity'] * oBody['items'][_nInd]['price'],2)
										SC8->C8_ALIIPI 	:= 0
										// SC8->C8_PRAZO  	:= IIF(ValType(oBody['items'][_nInd]['DeliveryTerm'])=="U",0,oBody['items'][_nInd]['DeliveryTerm'])
										// SC8->C8_DATPRF 	:= CTOD(oBody['items'][_nInd]['deliveryDate'])
										SC8->C8_PRAZO 	:= DateDiffDay(Date(), CTOD(oBody['items'][_nInd]['deliveryDate']))
										SC8->C8_COND   	:= oBody['paymentCondition']
										SC8->C8_TPFRETE	:= oBody['shippingType']
										SC8->C8_VALFRE 	:= IIF(oBody['shippingType'] == "F",0,oBody['shippingValue'] / Len(oBody['items']))
										SC8->C8_DESC   	:= oBody['items'][_nInd]['pdiscount']				
										SC8->C8_VLDESC 	:= oBody['items'][_nInd]['discount']  
										If VALTYPE(oBody['items'][_nInd]['obsSupplier']) <> "U"
											SC8->C8_XOBSFN 	:= oBody['items'][_nInd]['obsSupplier']
										EndIf
										SC8->C8_YWORKFL	:= "S"				

										SC8->(MsUnlock())

									EndIf		
								Else
									lRet := .F.	
									aErro := { 500, 'SC8 not seek', 500, EncodeUTF8( 'SC8 not seek' ) }
								EndIf
							Next
							oRetUpdateSC8["success"] 	 := .T.
							oRetUpdateSC8["code"]        := 200
							oRetUpdateSC8["message"]     := "Sucess"
							lRet := .T.

							DBSelectArea("ZX3")
							ZX3->(DbGoTo((cAliasTMP)->R_E_C_N_O_))

							If RecLock("ZX3",.F.)
								ZX3->ZX3_FLAG := "S"
								ZX3->(MsUnlock())
							EndIf
						Else 
							aErro := { 400, 'Invalid Body', 400, EncodeUTF8( 'Undetermined Body' ) }
						EndIf
					Else
						aErro := { 404, 'Quotation not found', 404, 'Quotation not found' }
					EndIf
				Else
					aErro := { 403, 'Token Expired', 403, 'Token Expired' }
				EndIf
			Else
				oRetDetailSC8["tokenActive"] := .F.
				oRetDetailSC8["code"]        := 200
				oRetDetailSC8["message"]     := "Quotation Expired"
			EndIf
		Else			
			aErro := { 404, 'Token not found within quotation IdSubsidiary: ' + AllTrim(IdSubsidiary) + '| Token: ' + AllTrim(Token), 404, 'Token not found within quotation IdSubsidiary: ' + AllTrim(IdSubsidiary) + '| Token: ' + AllTrim(Token) }
		EndIf
	Else
        aErro := { 400, 'Parameters not filled in', 400, 'One or more request parameters were not filled in' }
    EndIf

	If lRet
        ::SetResponse( oRetUpdateSC8:toJSON() ) 
    Else
        If len( aErro ) > 0
			SetRestFault( aErro[ 1 ], EncodeUTF8( aErro[ 2 ] ), .T., aErro[ 3 ], EncodeUTF8( aErro[ 4 ] ) )
		Else
			SetRestFault( 501, EncodeUTF8( 'Undetermined Error' ), .T., 501, EncodeUTF8( 'Undetermined Error' ) )
		EndIf
    EndIf

	FreeObj( oRetUpdateSC8 )
Return(lRet)


