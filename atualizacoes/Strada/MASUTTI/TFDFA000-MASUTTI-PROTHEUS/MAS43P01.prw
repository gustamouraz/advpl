#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TbiConn.ch"

/*/{Protheus.doc} MAS43P01
    (long_description)
    @type  Function
    @author user
    @since 13/03/2024
	PROCESSAMENTO DE DOCUMENTO DE ENTRADA
/*/
User Function MAS43P01(cFildoc, cDocCte, cSeriecte, cChaCTE)

	Local aAreas       := {SA2->(Getarea()),DT6->(GetArea()),ZA1->(GetArea()),GetArea()}
	Local aCab         := {}
	Local aItem        := {}
	Local aItens       := {}
	Local aErros       := {}
	Local aCgcFor      := {}
	Local nOpc         := 3
	Local lRet         := .F.
	Local cFilbckp 	   := cFilAnt
	Local cFornec      := " "
	Local cLoja        := " "
	Local cFilBaZMV    := cFildoc
	Local cDocBakZMV   := cDocCte
	Local cSerBakZMV   := cSeriecte
	Local cPath        := GetSrvProfString("StartPath", "\undefined")
	Local cFileLog     := "Erro log Intercompany"
	Local nSuce        as numeric
	Local cProduto     := " "
	Local cTes         := " "
	Local cFilDe	   := POSICIONE("SA1",1,xFilial("SA1")+DT6->DT6_CLIDEV+DT6->DT6_LOJDEV,"A1_FILTRF")
	Local cCCdtc 	   := ""
	Local cModal       := ""
	Local cEstOri 	   := GetUF(SUBSTR(DT6->DT6_CDRORI,1,1),2) 
	Local cEstDes      := GetUF(SUBSTR(DT6->DT6_CDRCAL,1,1),2)
	Local cMunOri      := SUBSTR(DT6->DT6_CDRORI,2,5)
	Local cMunCal      := SUBSTR(DT6->DT6_CDRCAL,2,5)

	DEFAULT cFildoc    := " "
	DEFAULT cDocCte    := " "
	DEFAULT cSeriecte  := " "
	PRIVATE cNatZNC    := ""
	PRIVATE nPesoKg    := DT6->DT6_PESO
	PRIVATE nQuant     := 0
	PRIVATE nValUni    := 0
	PRIVATE lretPes    := .T.

	oLog             := MASXLOG():New()
	cIdtoken         := oLog:idtoken

	ZNC->(dbSetOrder(3))
	IF ZNC->(dbSeek(xFilial('ZNC') + ZA1->ZA1_ZNCCOD ))
		cProduto := ZNC->ZNC_PRODUT
		cTes	 := ZNC->ZNC_TES
		cNatZNC  := ZNC->ZNC_NATURE
		cCCdtc   := ZNC->ZNC_CC
		IF EMPTY(cCCdtc)
			cCCdtc   := POSICIONE("DTC",1,xFilial("DTC")+DT6->DT6_FILORI+DT6->DT6_LOTNFC,"DTC_ZCCUST")
		ENDIF
		//01=Rodoviario;02=Aereo;03=Aquaviario;04=Ferroviario;05=Dutoviario;06=Multimodal
		cModal := IIF( POSICIONE("DTC",1,xFilial("DTC")+DT6->DT6_FILORI+DT6->DT6_LOTNFC,"DTC_ZAQUAV") == "2", "01", "03")
		lretPes := PesoDtc(cProduto)

		IF lretPes == .F.
			Return .F.
		ENDIF

		IF (Round((nValUni*nQuant),2) <> DT6->DT6_VALFRE)

			cErro := "O valor do Documento de entrada é divergente do valor do frete do CTE, Favor verificar"
			oLog:GRAVALOG("I001",cIdtoken, "Valor do Documento de entrada divirgente ao do CTE" ,cErro,"2","CTE",cFildoc+" / "+cDocCte+" / "+cSeriecte)
			aErros := U_MASENVEM(cFildoc,cDocCte,cSeriecte, cChaCTE, cErro)
			Return .F.

		ENDIF

	ELSE

		cErro := "Documento sem regra CTB"
		oLog:GRAVALOG("I001",cIdtoken, "Documento sem regra CTB" ,cErro,"2","CTE",cFildoc+" / "+cDocCte+" / "+cSeriecte)
		aErros := U_MASENVEM(cFildoc,cDocCte,cSeriecte, cChaCTE, cErro)
		Return .F.

	ENDIF

	aCgcFor := FWSM0Util():GetSM0Data(, cFildoc, { "M0_CGC" } )
	SA2->(DBSETORDER(3))
	If SA2->(DbSeek(xFilial("SA2")+aCgcFor[1][2]))
		cFornec := SA2->A2_COD
		cLoja   := SA2->A2_LOJA
	EndIf

	IF cFildoc <> " " .AND. cDocCte <> " " .AND. cSeriecte <> " "

		//CabeÃ§alho
		aadd(aCab,{"F1_TIPO"       ,"N"        ,NIL})
		aadd(aCab,{"F1_MODAL"      ,cModal     ,NIL})
		aadd(aCab,{"F1_FORMUL"     ,"N"        ,NIL})
		aadd(aCab,{"F1_TPCTE"      ,"N"        ,NIL})
		aadd(aCab,{"F1_DOC"        , cDocCte   ,NIL})
		aadd(aCab,{"F1_SERIE"      , cSeriecte ,NIL})
		aadd(aCab,{"F1_EMISSAO"    , DDATABASE ,NIL})
		aadd(aCab,{"F1_DTDIGIT"    , DDATABASE ,NIL})
		aadd(aCab,{"F1_FORNECE"    , cFornec   ,NIL})
		aadd(aCab,{"F1_LOJA"       , cLoja     ,NIL})
		aadd(aCab,{"F1_ESPECIE"    ,"CTE"      ,NIL})
		IF !EMPTY(cChaCTE)
			aadd(aCab,{"F1_CHVNFE" , cChaCTE   ,NIL})
		ENDIF
		IF !EMPTY(ZNC->ZNC_COND)
			aadd(aCab,{"F1_COND"   , ZNC->ZNC_COND ,NIL})
		ENDIF
		aadd(aCab,{"F1_STATUS"      , "A"      ,Nil})
		aadd(aCab,{"F1_UFORITR"     , cEstOri      ,Nil})
		aadd(aCab,{"F1_MUORITR"     , cMunOri      ,Nil})
		aadd(aCab,{"F1_UFDESTR"     , cEstDes      ,Nil})
		aadd(aCab,{"F1_MUDESTR"     , cMunCal      ,Nil})
		aadd(aCab,{"F1_TPFRETE"     ,  IIF(DT6->DT6_TIPFRE == "1","C","F") ,Nil})
		aadd(aCab,{"F1_PLIQUI"       , DT6->DT6_PESLIQ ,Nil})
		aadd(aCab,{"F1_PBRUTO"      ,  DT6->DT6_PESO   ,Nil})

		aItem := {}
		aadd(aItem,{"D1_ITEM"    ,   "0001"        ,NIL})
		aadd(aItem,{"D1_COD"     ,    cProduto     ,NIL})
		aadd(aItem,{"D1_QUANT"   ,    nQuant       ,NIL}) //"1"
		aadd(aItem,{"D1_VUNIT"   ,    nValUni      ,NIL})
		//aadd(aItem,{"D1_TOTAL"   ,    nTotal       ,NIL})
		aadd(aItem,{"D1_TES"     ,    cTes         ,NIL})
		aadd(aItem,{"D1_CC"   ,       cCCdtc       ,NIL})

		aAdd(aItens,aItem)

		cFilAnt := cFilDe
		lMsErroAuto := .F.
		MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aItens,nOpc,,,)

		If !lMsErroAuto

			lRet := .T.

			oLog:GRAVALOG("I001",cIdtoken, "Sucesso ao Incluir o documento" ," ","1","CTE",Alltrim(cFildoc+" / "+cDocCte+" / "+cSeriecte))

			DBSELECTAREA('ZMV')
			ZMV->(DBSETORDER(2))
			If	ZMV->(Dbseek(xfilial("ZMV")+cIdtoken))
				RecLock('ZMV',.F.)
				ZMV->ZMV_CHSEE2  := "SF1"
				ZMV->ZMV_SEE2    :=  Alltrim(xFilial("SD1")+" / "+cDocCte+" / "+cSeriecte)
				ZMV->(MsUnLock())
			ENDIF

			DBSELECTAREA("ZA1")
			ZA1->(DBSETORDER(1))
			IF ZA1->(DBSEEK(DT6->DT6_FILIAL+cFildoc+cDocBakZMV+cSeriecte))
				If RecLock('ZA1',.F.)
					ZA1->ZA1_FILDCE := xFilial("SD1")
					ZA1->ZA1_DOCENT := cDocCte
					ZA1->ZA1_SERENT := cSeriecte
					ZA1->ZA1_FORNEC := cFornec
					ZA1->ZA1_LOJA   := cLoja
					ZA1->(MsUnlock())
				ENDIF
			ENDIF

		ELSE

			lRet := .F.
			cErro := MostraErro( cPath, cFileLog ) // Analisar - gravar o erro correto.
			nSuce := FErase(cPath+cFileLog) // Sucesso retorna 0, erro = -1
			oLog:GRAVALOG("I001",cIdtoken, "Erro ao Incluir o documento" ,cErro,"2","CTE",Alltrim(cFildoc+" / "+cDocCte+" / "+cSeriecte))
			aErros := U_MASENVEM(cFildoc,cDocCte,cSeriecte, cChaCTE, cErro)
			//ERRO AO ENVIAR E-MAIL
			IF !EMPTY(cErro)
				DBSELECTAREA('ZMV')
				ZMV->(DBSETORDER(4))
				IF Dbseek(xfilial("ZMV")+cFilBaZMV+cDocBakZMV+cSerBakZMV)
					RecLock('ZMV',.F.)
					ZMV->ZMV_DADOS := cErro
					ZMV->(MsUnLock())
				ENDIF
			ENDIF
		ENDIF



	ENDIF

	cFilAnt := cFilbckp
	AEval(aAreas,{|x,y| RestArea(x) })

Return lRet

/*/{Protheus.doc} PesoDtc
	(long_description)
	@Ajusta de quantidade baseada no peso e no conf do peso do produto. e o val unitário
	@Daniel Victor da Rosa
	@since 28/06/2024
/*/
Static Function PesoDtc(cProduto)

	Local cProd := cProduto
	Local cUnidMed1 :=  " "

	SB1->(DbSetOrder(1))
	IF SB1->(DBSEEK(xFilial("SB1")+cProd))
		cUnidMed1  := SB1->B1_UM
		IF Alltrim(cUnidMed1) == "TON"
			nQuant  := nPesoKg/1000
			nValUni := DT6->DT6_VALFRE/nQuant
		ELSE
			nValUni := DT6->DT6_VALFRE/nPesoKg
			nQuant  := nPesoKg
		ENDIF

	ELSE

		cErro:= "Erro ao Incluir o documento, regra sem Produto, ou Produto nao cadastrado"
		oLog:GRAVALOG("I001",cIdtoken, "Erro ao Incluir o documento, regra sem Produto, ou Produto nao cadastrado" ,cErro,"2","CTE",Alltrim(cFildoc+" / "+cDocCte+" / "+cSeriecte))
		aErros := U_MASENVEM(cFildoc,cDocCte,cSeriecte, cChaCTE, cErro)
		lretPes := .F.

	ENDIF

Return lretPes
 
/*/{Protheus.doc} GetUF
    (Recebe o código do estado e retorna a Sigla)
    @type  Static Function
    @author
    @since
/*/
Static Function GetUF(cCodUF,nOpc)
	Local cRet       := ""

	IF nOpc == 1
		Do Case
			Case cCodUF == "11"
				cRet := "RO"
			Case cCodUF == "12"
				cRet := "AC"
			Case cCodUF == "13"
				cRet := "AM"
			Case cCodUF == "14"
				cRet := "RR"
			Case cCodUF == "15"
				cRet := "PA"
			Case cCodUF == "16"
				cRet := "AP"
			Case cCodUF == "17"
				cRet := "TO"
			Case cCodUF == "21"
				cRet := "MA"
			Case cCodUF == "22"
				cRet := "PI"
			Case cCodUF == "23"
				cRet := "CE"
			Case cCodUF == "24"
				cRet := "RN"
			Case cCodUF == "25"
				cRet := "PB"
			Case cCodUF == "26"
				cRet := "PE"
			Case cCodUF == "27"
				cRet := "AL"
			Case cCodUF == "28"
				cRet := "SE"
			Case cCodUF == "29"
				cRet := "BA"
			Case cCodUF == "31"
				cRet := "MG"
			Case cCodUF == "32"
				cRet := "ES"
			Case cCodUF == "33"
				cRet := "RJ"
			Case cCodUF == "35"
				cRet := "SP"
			Case cCodUF == "41"
				cRet := "PR"
			Case cCodUF == "42"
				cRet := "SC"
			Case cCodUF == "43"
				cRet := "RS"
			Case cCodUF == "50"
				cRet := "MS"
			Case cCodUF == "51"
				cRet := "MT"
			Case cCodUF == "52"
				cRet := "GO"
			Case cCodUF == "53"
				cRet := "DF"
			Case cCodUF == "99"
				cRet := "EX"
		EndCase

	ELSEIF nOpc == 2
		Do Case
			CASE cCodUF == 'L'
				cRet := 'RO'
			CASE cCodUF == '1'
				cRet := 'AC'
			CASE cCodUF == '3'
				cRet := 'AM'
			CASE cCodUF == 'M'
				cRet := 'RR'
			CASE cCodUF == 'E'
				cRet := 'PA'
			CASE cCodUF == '4'
				cRet := 'AP'
			CASE cCodUF == 'R'
				cRet := 'TO'
			CASE cCodUF == 'A'
				cRet := 'MA'
			CASE cCodUF == 'H'
				cRet := 'PI'
			CASE cCodUF == '6'
				cRet := 'CE'
			CASE cCodUF ==  'K'
				cRet := 'RN'
			CASE cCodUF == 'F'
				cRet := 'PB'
			CASE cCodUF == 'G'
				cRet := 'PE'
			CASE cCodUF == '2'
				cRet := 'AL'
			CASE cCodUF == 'B'
				cRet := 'MG'
			CASE cCodUF == '8'
				cRet := 'ES'
			CASE cCodUF == 'J'
				cRet := 'RJ'
			CASE cCodUF == 'Q'
				cRet := 'SP'
			CASE cCodUF == 'I'
				cRet := 'PR'
			CASE cCodUF == 'O'
				cRet := 'SC'
			CASE cCodUF == 'N'
				cRet := 'RS'
			CASE cCodUF == 'C'
				cRet := 'MS'
			CASE cCodUF == 'D'
				cRet := 'MT'
			CASE cCodUF == '9'
				cRet := 'GO'
			CASE cCodUF == '7'
				cRet := 'DF'
			CASE cCodUF == 'P'
				cRet := 'SE'
			CASE cCodUF == '5'
				cRet := 'BA'
		ENDCASE
	ENDIF
Return cRet
