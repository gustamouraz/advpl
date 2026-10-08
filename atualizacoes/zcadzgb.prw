#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "FINA820.ch"
#Include "Fileio.ch"
#INCLUDE "TBICONN.CH"
//PRD_05
Static __lIsBlind	:= IsBlind()
Static __cArq		:= ""
Static __cDir		:= ""
Static __cCpf		:= ""
Static __cTmpFVV	:= ""
Static __cTmpFVG	:= ""
Static __cTmpCVB	:= ""
Static __cFilOri	:= ""
Static __cFlAntOd	:= ""
Static __cFVUCod	:= ""
Static __nTamFlA6	:= 0
Static __nPropBx	:= 1
Static __nVlFun		:= 0
Static __nVlNota	:= 0
Static __nTxMoeda	:= 0
Static __lF820Qry	:= .F.
Static __lF820Reg	:= .F.
Static __lF820Bco	:= .F.
Static __lImpHist	:= .F.
Static __lFunrural	:= .F.
Static __lPrinted	:= .F.
Static __lNftot		:= .F.
Static __lLibChq
Static __oTmpFil
Static __oTmpFVIG
Static __oTmpBco
Static __oTSlCred
Static __oCredRec
Static __oCredPag
Static __nFilSE5
Static __nFilSE1
Static __nFilSE2
Static __nFilSF1
Static __nFilSF2
Static __nAbtNF
Static __nDecs
Static __nLOEmp
Static __nLOUnN
Static __nLOFil
Static __cTamSE5
Static __cTamSEF
Static __oTmpCheq
Static __cDBName
Static __aTpReg
Static __cLCDPRPA
Static __cLCDPRRA

#DEFINE DEC   		"LCDPR"
#DEFINE EXT   		"txt"
#DEFINE TPDOCNF		"1"
#DEFINE TPDOCFT		"2"
#DEFINE TPDOCRC		"3"
#DEFINE TPDOCCT		"4"
#DEFINE TPDOCFP		"5"
#DEFINE TPDOCOU		"6"
#DEFINE BL0000		"0000"
#DEFINE BL0010		"0010"
#DEFINE BL0030		"0030"
#DEFINE BL0040		"0040"
#DEFINE BL0045		"0045"
#DEFINE BL0050		"0050"
#DEFINE BLQ100		"Q100"
#DEFINE BLQ200		"Q200"
#DEFINE BL9999		"9999"
#DEFINE Dv			"|"
#DEFINE ENTER		Chr(13) + Chr(10)

User Function ZCADZGB() 

	Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
	Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
	Local lRPC := .F.
	Local aBotAdc := {}
	Private cString := "ZGB"


        If Select("SX2") == 0
            RpcClearEnv()
            RPCSetType(3)    //NAO CONSOME LICENSA DE USO
            If(!RpcSetEnv("01", "020101", "", "", "CTB",,{"CT2"}))
                Return(Nil)
            EndIf
            lRPC := .T.
        EndIf
	aAdd(aBotAdc,{"LCPDR Masutti","U_ZFINA820()",0,3})
	aadd(aBotAdc,{'Exporta Planilha','U_ZIMPZGBR()' , 0 , 3})
    aadd(aBotAdc,{'Importa Planilha','U_ZIMPZGB(2)' , 0 , 3})

	aadd(aBotAdc,{'Exce��es','U_ZEXCZGB()' , 0 , 4})

	aadd(aBotAdc,{'Inc. Reg. pela Z41','U_ACZGBZ41()' , 0 , 4}) 


	dbSelectArea("ZGB")
	ZGB->(DbSetOrder(1))
	
    AxCadastro(cString,"Livro Caixa Masutti ",cVldAlt,cVldExc,aBotAdc)

Return




//------------------------------------------------------------------------------
/*/	{Protheus.doc} LCDPR

Extrator do Livro Caixa Digital do Produtor Rural

@sample	LCDPR
@return		
@author		Rodrigo Oliveira
@version	12.1.27
/*/
//------------------------------------------------------------------------------
User Function ZFINA820(aParamIni As Array, aSelFil As Array, aBancos As Array, aContador As Array, aDtPeriodo As Array)
	Local lGerado	As Logical
	Local lWzd		As Logical
	Local aRetTela	As Array
	Local cArquivo	As Character
		
	Private _cCodParc := ""
	Default aParamIni	:= {}
	Default aSelFil		:= {}
	Default aBancos		:= {}
	Default aContador	:= {}
	Default aDtPeriodo	:= {}

	Private _aFieldRel := {} //Vou copiar os campos padrões e adicionar da contabilidade (Aline Rover / André Claro)
	Private oIMPREL 
	Private _cFildRel := ""

 	lGerado		:= .F.
 	lWzd		:= .F.
	aRetTela	:= {}
	cArquivo 	:= ''
	__cDBName	:= Alltrim(Upper(TCGetDB()))
	__cLCDPRPA	:= SUPERGETMV("MV_LCDPRPA",,"C")
	__cLCDPRRA	:= SUPERGETMV("MV_LCDPRRA",,"C")
	
	/*------------------------------------------|
	|	Estruturas dos aArrays:					|
	|				         					|
	|	a-) aParamIni:         					|
	|	[1] - Cód. da versão do leiaute			|
	|	[2] - Cpf do declarante					|
	|	[3] - Reservado p/ o nome do declarante |
	|	[4] - Indicador do início do período	|
	|		0 - Regular         				|
	|		1 - Abertura         				|
	|		2 - Início da obrigatoriedade		|
	|	[5] - Indicador de Sit. Especial		|
	|		0 - Normal          				|
	|		1 - Falecimento      				|
	|		2 - Espólio                  		|
	|		3 - Sapida definitiva do País		|
	|	[6] - Data da situação especial			|
	|	[7] - Data do início do período			|
	|	[8] - Data Final do período				|
	|	[9] - Forma de apuração    				|
	|		1 - Livro Caixa     				|
	|		2 - Apuração Lucro p/ Lei 8023/90	|
	|	[10] - Diretório de gravação do arquivo	|
	|	[11] - Nome do arquivo					|
	|					         				|
	|	b-) aSelFil:           					|
	|	[1] - Cód. da Filial (9901)				|
	|					         				|
	|	c-) aBancos:	  	       				|
	|	[1] - Cód. do Banco                  	|
	|	[2] - Agência                 			|
	|	[3] - Núm. da Conta          			|
	|	[4] - Díg. verificador da conta			|
	|	[5] - Filial                  			|
	|	[6] - País                   			|
	|	[7] - Cód. Banco no BACEN  				|
	|					         				|
	|	d-) aContador:  	       				|
	|	[1] - Cód. da Filial do contador (9901)	|
	|	[2] - Código do contador (CVB)			|
	|					         				|
	|	e-) aDtPeriodo:  	       				|
	|	[1] - 1- Dt da baixa; 2- Dt Credito		|
	|				         					|
	|------------------------------------------*/

	If TemLCDPR()

		If Empty(aParamIni)

			If !GetHlpLGPD({'FVU_NOME','FVU_CNPJ','A6_COD', 'A6_AGENCIA', 'A6_NUMCON'})
				aRetTela := FINA820A()
			EndIf

			If Len(aRetTela) > 0
				If !aRetTela[6]
					aParamIni	:= aRetTela[1]
					aSelFil		:= aRetTela[2]
					aBancos		:= aRetTela[3]
					aContador	:= aRetTela[4]
					aDtPeriodo	:= aRetTela[5]

					If Alltrim(aParamIni[2]) $ "63083167172"
						_cCodParc := "000005"
					ElseIf Alltrim(aParamIni[2]) $ "01153082101"
						_cCodParc := "000004"
					ElseIf Alltrim(aParamIni[2]) $ "02482557976"
						_cCodParc := "000003"
					ElseIf Alltrim(aParamIni[2]) $ "79947646904"
						_cCodParc := "000002"
					ElseIf Alltrim(aParamIni[2]) $ "20374070253"
						_cCodParc := "000001"
					EndIf
				EndIf
			EndIf
			lWzd	:= .T.

		EndIf
		
		If ( !Empty(aParamIni) .And. !Empty(aSelFil) .And. !Empty(aBancos) .And. !Empty(aContador) .And. !Empty(aDtPeriodo) )
			__cCpf		:= AllTrim(aParamIni[2])
			Processa({|| lGerado := GeraArq(aParamIni, aSelFil, aBancos, aContador, aDtPeriodo[1])})
			
			If !__lIsBlind .And. lGerado
				MsgInfo( STR0015 + Lower(__cDir + __cArq) + "." + EXT, STR0016 ) // "Arquivo gerado com sucesso: "
			EndIf
			If lGerado
				cArquivo := Lower(__cDir + __cArq) + "." + EXT
			EndIf
		ElseIf !lWzd .Or. ( lWzd .And. Len(aRetTela) > 0 .And. !aRetTela[6] ) 
			Help(' ',1, STR0012,, STR0013 + ENTER + STR0014,2,0,,,,,,) // "LCDPR NÃO GERADO." ## "Verifique os parâmetros selecionados" ## "e repita o processo para a correta geração. "		
		EndIf
	EndIf
	ZeraStatic()
	
Return ({ lGerado , cArquivo }) 

//------------------------------------------------------------------------------
/*/	{Protheus.doc} GeraArq

Gera arquivo TXT com base nos parâmetros passados

@sample	GeraArq

@param aParamIni	= Parâmetros iniciais do wizard da rotina LCDPR
@param aSelFil		= Filiais / Imóveis selecionados
@param aContador	= Filial e código do contador responsável pela declaração

@return	lRet	= retorna .T. caso o arquivo seja gerado corretamente
		
@author		Rodrigo Oliveira
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function GeraArq(aParamIni As Array, aSelFil As Array, aBancos As Array, ;
 						aContador As Array, cDtPeriodo As Character) As Logical
	Local lRet		As Logical
	Local lRegValid As Logical
	Local lE5Cgc	As Logical
	Local lVlLiqR	As Logical
	Local lVlLiqP	As Logical
	Local lNaoInt	As Logical
	Local lTipoVa	As Logical
	Local lMercosul As Logical
	Local nHdl		As Numeric
	Local nI		As Numeric
	Local nQtdLin	As Numeric
	Local cTipo		As Character
	Local cConta	As Character
	Local cImov		As Character
	Local cFiliais	As Character
	Local cNatSld	As Character
	Local cTpPartic	As Character
	Local cMes		As Character
	Local cOldMes	As Character
	Local cNumDoc	As Character
	Local cPict		As Character
	Local cPictR	As Character
	Local cLinha	As Character
	Local cLinAux	As Character
	Local cLin200	As Character
	Local cUniao	As Character
	Local cMunic	As Character
	Local cSecEst	As Character
	Local cHist		As Character
	Local cCnpj		As Character
	Local cPais		As Character
	Local cMoeda	As Character
	Local cIE		As Character
	Local cMoedAux	As Character
	Local cAntFil	As Character
	Local cBanco	As Character
	Local cCxFin	As Character
	Local cRotOri	As Character
	Local cFilOri	As Character
	Local cHistC	As Character
	Local cHistNF	As Character
	Local cSaldoR   As Character 
	Local cSaldoP   As Character
	Local cSld200	As Character
	Local cValor    As Character
	Local cSaldo    As Character
	Local cVlFun    As Character
	Local cCodBco 	As Character
	Local cDecParc	As Character
	Local cDtCheq	As Character
	Local nValCorr 	As Numeric
	Local nValNF 	As Numeric
	Local nVlNFE1	As Numeric
	Local nVlNFE2	As Numeric
	Local nValor	As Numeric
	Local nTamFil	As Numeric
	Local nSaldo	As Numeric
	Local nSld200	As Numeric
	Local nSaldoR	As Numeric
	Local nSaldoP	As Numeric
	Local nTamSx3	As Numeric
	Local nProp		As Numeric
	Local nCaso		As Numeric
	Local nCount	As Numeric
	Local nAbat		As Numeric
	Local nAbtTotal As Numeric
	Local nTamTitR 	As Numeric
	Local nTamTitP 	As Numeric
	Local nVlCruz	As Numeric
	Local nTamPart  As Numeric
	Local nDecPart	As Numeric
	Local nTxMTit 	As Numeric
	Local aStruFil	As Array
	Local aStruBco	As Array
	Local aTpReg	As Array
	Local aFXV		As Array
	Local aFVVAux	As Array
	Local aAuxSE	As Array
	Local aAuxCx	As Array
	Local aCxFin	As Array
	Local aAuxFVG	As Array

	Local lDecPrinc As Logical
	Local lDecPrin  As Logical
	Local lTemBcOfi As Logical
	Local lAchou	As Logical
	Local lTemCompl As Logical
	Local aAuxDec   As Array
	Local aAux1 	As Array
	Local aAux2 	As Array

	Local _nRecACC := 0
	Local _nPagACC := 0
	Local _aTempVal := {}
	Local _nSldACC := 0	
	Local _cLinACC := ""

	Local oExcel 		:= FWMsExcelEx():New()
	Local cFile			:= ""
	Local cNomePlan	:= ""
	Local cTituloPlan	:= ""
	Local _cAlias1		:= ""
	Local _nMax := 0
	Local _nX := 0
	Local _nRow := 0

	local oPrtXlsx as object
	local cFilename as character
	local lRet as logical
	Local cFont := ""
	Local nSize := 11
	Local lItalic := .F.
	Local lBold := .T.
	Local lUnderlined := .F.

	Local cHorAlignment := "" 
	Local cVertAlignment := ""
	Local lWrapText := .F.
	Local nRotation := 0 
	Local cCustomFormat := ""
	Local cColor := "000000" // Cor preta!
	Local cColorF := "3CB371" 


	static oCellHorAlign := FwXlsxCellAlignment():Horizontal()
	static oCellVertAlign := FwXlsxCellAlignment():Vertical()

	Local lTop := .T.
	Local lBottom := .T.
	Local lLeft:= .T.
	Local lRight := .T.
	Local cStyle := FwXlsxBorderStyle():DashDot()
	Local cColor := "87CEEB"
	Local _cFile := 'c:\Temp\LCPRD_'+DToS(Date())+StrTran(Time(),":","")
	Local _cRastro := ""
	Local _nX := 0
	Local _cAlias := ""
	Local _cDtIni := ''
	Local _cDtFim := ''
	Local _cTabTemp := ''
	Local _cQryRel := ''
	Local _aArrumaLN := {}
	
	PRIVATE oTRB100
	
	lRet		:= .F.
	lAchou		:= .F.
	lTemBcOfi	:= .F.
	lRegValid	:= .T.
	lNaoInt		:= .F.
	lTipoVa		:= .F.
	lMercosul   := .F.
	lVlLiqR		:= SuperGetMV("MV_BQ10925",.F.,"1") == "2"
	lVlLiqP		:= SuperGetMV("MV_BP10925",.F.,"1") == "2"
	lE5Cgc		:= SE5->(ColumnPos('E5_CGC') ) > 0
	nHdl		:= 0
	nI			:= 0
	nCount		:= 0
	nQtdLin		:= 3
	nTxMTit		:= 1
	nTamTitR	:= TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]+1
	nTamTitP	:= TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+1
	cTipo		:= ""
	cLinha		:= ""
	cFiliais	:= ""
	cNatSld		:= ""
	cTpPartic	:= ""
	cPais		:= ""
	cMoeda		:= ""
	cIE			:= ""
	cHist		:= ""
	cMoedAux	:= ""
	cAntFil		:= ""
	cBanco		:= ""
	cFilOri		:= ""
	cHistC		:= ""
	cHistNF		:= ""		
	cSaldoR   	:= ""
	cSaldoP   	:= ""
	cSld200		:= ""
	cValor      := ""
	cSaldo      := ""
	cVlFun      := ""
	cCodBco 	:= ""
	cDtCheq		:= ""
	cUniao		:= SuperGetMV("MV_UNIAO",,"UNIAO")
	cMunic		:= SuperGetMV("MV_MUNIC",,"MUNIC")
	cSecEst		:= SuperGetMV("MV_RECEST",,"ESTADO")
	cCxFin		:= SuperGetMV("MV_CXFIN",,"CX1")
	cPrefSen	:= SuperGetMV("MV_PFSENAR",,"SEN")
	aStruFil	:= {}
	aStruBco	:= {}
	aTpReg		:= {}
	aFXV		:= {}
	aFVVAux		:= {}
	aAuxSE		:= {}
	aAuxCx		:= {}
	aCxFin		:= {}
	aAuxFVG		:= {}
	nSaldo		:= 0
	nValor		:= 0
	nSld200		:= 0
	nTamFil		:= TamSX3("A6_FILIAL")[1]
	nTamSx3		:= TamSX3("E5_VALOR")[1]
	nTamPart	:= TamSX3("FVV_PARTIC")[1]
	nDecPart	:= TamSX3("FVV_PARTIC")[2]
	cDecParc	:= ""
	cPict		:= StrTran(Space(nTamSx3), " ", "9") + ".99"
	cPictR		:= "@E 9,999,999,999,999.99"
	__cDir		:= AllTrim(aParamIni[10]) // Diretório para geração do arquivo
	nVlNFE1		:= 0
	nVlNFE2		:= 0
	nValCorr	:= 0
	nValNF		:= 0
	nAbat		:= 0
	nAbtTotal	:= 0
	nVlCruz		:= 0

	lDecPrinc 	:= .F.
	lDecPrin 	:= .F.
	aAuxDec     := {}
	aAux1 		:= {}
	aAux2 		:= {}

	If (Right(AllTrim(aParamIni[10]),1) $ "\/" )
		if Empty(aParamIni[11])
			__cArq		:= DEC + "_" + DtoS(Date()) + "_" + StrTran(Time(), ":", "_" )
		Else
			__cArq		:= aParamIni[11] // nome do arquivo via testcase
		EndIf
	EndIf
	
	__lF820Qry	:= .f.// ExistBlock("F820Qry")
	__lF820Reg	:= .F. //ANDRECCLARO 29/11/2022 // ExistBlock("F820Reg")
	__lF820Bco	:= ExistBlock("F820Bco")

	If ( nHdl := FCreate(__cDir + __cArq  + "." + EXT,,, .T.) ) > 0
		// Imprime os parametros iniciais
		DbSelectArea("FVU")
		FVU->(DbSetOrder(3))
			
		If FVU->(DbSeek(xFilial("FVU") + __cCpf))
			aParamIni[3] 	:= AllTrim(FVU->FVU_NOME)
			__cFVUCod		:= FVU->FVU_CODIGO
			// Abertura e identificação do arquivo (bl. 0000)
				
			cLinha := BL0000 + Dv + DEC + Dv + PadL(StrTran(aParamIni[1],".",""), 4, "0") + Dv + __cCpf + Dv + aParamIni[3] + Dv + aParamIni[4] + Dv ;
				 	+ aParamIni[5] + Dv + If( !Empty(aParamIni[6]), FormatDt(aParamIni[6]), '' ) + Dv + FormatDt(aParamIni[7]) + Dv + FormatDt(aParamIni[8]) + ENTER
	
			// Forma de apuração (bl. 0010)
			cLinha += BL0010 + Dv + aParamIni[9] + ENTER
		
			PrintLn(nHdl, cLinha)
			
			// Imprimir o contribuinte com base no cadastro (FVU)
			// (Bl. 0030)
			cLinha := ""
			
			SX5->(DbSeek(xFilial("SX5") + 'AA' + FVU->FVU_EST) )
						
			cLinha	:= BL0030 + Dv + AllTrim(FVU->FVU_END) + Dv + IIf(FVU->FVU_NUM <> 0 , AllTrim(STR(FVU->FVU_NUM)), "s/n" ) + Dv + AllTrim(FVU->FVU_COMPL) + Dv + AllTrim(FVU->FVU_BAIRRO) + Dv ;
			   		+ FVU->FVU_EST + Dv + SubStr(AllTrim(SX5->X5_DESCRI),2,2) + FVU->FVU_CODMUN + Dv + AllTrim(FVU->FVU_CEP) + Dv + AllTrim(FVU->FVU_FONE) + Dv + AllTrim(FVU->FVU_EMAIL) + ENTER
			PrintLn(nHdl, cLinha)
		EndIf
			
		If !Empty(cLinha)
			If __oTmpFil <> Nil
				__oTmpFil:Delete()
				__oTmpFil := Nil
			EndIf
				
			aAdd(aStruFil, {'FILIAL', 'C', nTamFil, 0})
			aAdd(aStruFil, {'COD', 'C', 3, 0})
			aAdd(aStruFil, {'VER', 'C', 4, 0})
			aAdd(aStruFil, {'NUMIMO', 'C', 3, 0})
			aAdd(aStruFil, {'DTINI', 'C', 8, 0})
			aAdd(aStruFil, {'DTFIM', 'C', 8, 0})

			__oTmpFil := FwTemporaryTable():New( 'TRF' )
			__oTmpFil:SetFields(aStruFil)
			__oTmpFil:AddIndex('1', {'FILIAL'})
			
			__oTmpFil:Create()
			
			For nI := 1 To Len(aSelfil)
				RecLock('TRF', .T.)
				TRF->FILIAL 	:= aSelFil[nI]
				TRF->(MsUnlock())
			Next

			cFiliais := "%FVV_FILIAL " + GetRngFil(aSelFil,"FVV",.T.,) + "%"
			
			// Filiais / Imóveis selecionados
			ArqTmp( '1', aSelFil,, cFiliais )
			
			// Terceiros dos Imóveis selecionados
			ArqTmp( '2',,, cFiliais )
			 	
			cLinha := ""
				
			ProcRegua((__cTmpFVV)->(RecCount()))

			cImov	:= "000"	
			// Imprimir as filiais / imóveis com base no aSelFil (Bl. 0040)
			TRF->(DbGoTop())
			While !TRF->(Eof())
				lDecPrinc := GetAdvFVal("FVV","FVV_CODPES",(__cTmpFVV)->FVV_FILIAL + (__cTmpFVV)->FVV_CODIGO,1) == __cFVUCod

				While !(__cTmpFVV)->(Eof()) .And. TRF->FILIAL == (__cTmpFVV)->(FVV_FILIAL)
							
					_lAddACC := .t.
					
					If !Empty((__cTmpFVV)->(FVV_VIGINI)) .and. STod((__cTmpFVV)->(FVV_VIGINI)) > aParamIni[8] //Se a data inicio for maior que a fim
						_lAddACC := .F.
					EndIf
					If !Empty((__cTmpFVV)->(FVV_VIGFIM)) .and. Stod((__cTmpFVV)->(FVV_VIGFIM)) < aParamIni[7]
						_lAddACC := .F.
					EndIf

					If _lAddACC

						cImov	:= Soma1(cImov)
						If cAntFil != (__cTmpFVV)->(FVV_FILIAL)
							RecLock("TRF", .F.)
								TRF->VER	:= (__cTmpFVV)->(FVV_VERSAO)
								TRF->NUMIMO	:= (__cTmpFVV)->(NUMIMO)
								TRF->DTINI	:= If( !Empty((__cTmpFVV)->(FVV_VIGINI)), (__cTmpFVV)->(FVV_VIGINI), DTOS(aParamIni[7]) )
								TRF->DTFIM	:= If( !Empty((__cTmpFVV)->(FVV_VIGFIM)), (__cTmpFVV)->(FVV_VIGFIM), DTOS(aParamIni[8]) )
								TRF->COD	:= cImov
							TRF->(MsUnLock())
						Else
							aAdd( aFVVAux, { (__cTmpFVV)->(FVV_FILIAL), (__cTmpFVV)->(FVV_VERSAO), (__cTmpFVV)->(NUMIMO), ;
											If( !Empty((__cTmpFVV)->(FVV_VIGINI)), (__cTmpFVV)->(FVV_VIGINI), DTOS(aParamIni[7]) ), ;
											If( !Empty((__cTmpFVV)->(FVV_VIGFIM)), (__cTmpFVV)->(FVV_VIGFIM), DTOS(aParamIni[8]) ), cImov } )
						EndIf
						cAntFil := (__cTmpFVV)->(FVV_FILIAL)
						SX5->(DbSeek(xFilial("SX5") + 'AA' + (__cTmpFVV)->(UF)) )
							
						cTpPartic	:= (__cTmpFVV)->TIPO
						If (__cTmpFVV)->TAB == 'FVGMN' .And. (__cTmpFVV)->TPPES == '1'
							cTpPartic	:= AllTrim(Str( Val((__cTmpFVV)->TIPO) + 1 ) )	
						EndIf
						
						cPartic 	:= Iif("." $ Str((__cTmpFVV)->PERC) ,PadL( Substr(ALLTRIM(Str((__cTmpFVV)->PERC)),1, Rat(".", AllTrim(Str((__cTmpFVV)->PERC)) ) -1 ),3 , "0"),  PADL(ALLTRIM(STR((__cTmpFVV)->PERC)),3,"0") )
						cDecParc	:= Iif("." $ Str((__cTmpFVV)->PERC), Substr(Padr(SubStr(AllTrim(Str(Round((__cTmpFVV)->PERC,2))), Rat(".", AllTrim(Str((__cTmpFVV)->PERC)) ) +1, nDecPart),nDecPart,"0") ,1,2), Replicate("0",2))
			
						cLinha	+= BL0040 + Dv + cImov + Dv + AllTrim((__cTmpFVV)->FVV_PAIS) + Dv + AllTrim((__cTmpFVV)->FVV_MOEDA) + Dv + AllTrim((__cTmpFVV)->FVV_CAFIR) + Dv + AllTrim((__cTmpFVV)->CAEPF) + Dv ;
								+ AllTrim((__cTmpFVV)->IE) + Dv + AllTrim((__cTmpFVV)->FVV_NOME) + Dv + AllTrim((__cTmpFVV)->FVV_END) + Dv + IIf((__cTmpFVV)->FVV_NUM <> 0, AllTrim(Str((__cTmpFVV)->FVV_NUM)), "s/n")  + Dv + AllTrim((__cTmpFVV)->FVV_COMPL) + Dv ;
								+ AllTrim((__cTmpFVV)->FVV_BAIRRO) + Dv + AllTrim((__cTmpFVV)->UF) + Dv + SubStr(AllTrim(SX5->X5_DESCRI),2,2) + AllTrim((__cTmpFVV)->FVV_CODMUN) + Dv + AllTrim((__cTmpFVV)->FVV_CEP);
								+ Dv + cTpPartic + Dv  + cPartic +cDecParc + ENTER
					
						nQtdLin++
							
						// Imprimir terceiros com base no cadastro (FVG) (Bl. 0045)
						(__cTmpFVG)->(DbGoTop() )
						While !(__cTmpFVG)->(Eof())
							If TRF->FILIAL == (__cTmpFVG)->FVV_FILIAL
								If !( AllTrim((__cTmpFVG)->FVU_CNPJ) == __cCpf ) .And. (__cTmpFVV)->(FVV_VERSAO) == (__cTmpFVG)->VER .And. TRF->NUMIMO == (__cTmpFVG)->NUMIMO
									cTpPartic	:= ""
									Do Case
										Case (__cTmpFVG)->TAB $ ('FVV|FXV')
											cTpPartic	:= AllTrim(Str( Val((__cTmpFVG)->TIPO) -1 ) )
										OtherWise
											cTpPartic	:= (__cTmpFVG)->TIPO	
									EndCase
									cDecParc	:= Iif("." $ Str((__cTmpFVG)->PERC), Substr(Padr(SubStr(AllTrim(Str(Round((__cTmpFVG)->PERC,2))), Rat(".", AllTrim(Str((__cTmpFVG)->PERC)) ) +1, nDecPart),nDecPart,"0") ,1,2), Replicate("0",2))								
									cPartic 	:= Iif("." $ Str((__cTmpFVG)->PERC) ,PadL( Substr(ALLTRIM(Str((__cTmpFVG)->PERC)),1, Rat(".", AllTrim(Str((__cTmpFVG)->PERC)) ) -1 ),3 , "0"),  PADL(ALLTRIM(STR((__cTmpFVG)->PERC)),3,"0") )
																			
									cLinha	+= BL0045 + Dv + If(Empty(TRF->COD) .Or. ( TRF->VER != (__cTmpFVG)->VER ), cImov, TRF->COD) + Dv + cTpPartic + Dv + AllTrim((__cTmpFVG)->FVU_CNPJ) + Dv + AllTrim((__cTmpFVG)->FVU_NOME) + Dv + ;
											cPartic + cDecParc + ENTER

									nQtdLin++
									(__cTmpFVG)->(DbSkip())
								Else
									(__cTmpFVG)->(DbSkip())
								EndIf
							Else
								(__cTmpFVG)->(DbSkip())
							EndIf
						EndDo
						cPais	:= (__cTmpFVV)->FVV_PAIS
						cMoeda	:= (__cTmpFVV)->FVV_MOEDA
						cIE		:= (__cTmpFVV)->IE

						If ( aScan( aFXV, { |x| x == (__cTmpFVV)->FVV_FILIAL } ) ) == 0
							aAdd(aFXV, (__cTmpFVV)->FVV_FILIAL )
							nCount	:= FilCompl((__cTmpFVV)->FVV_CODIGO)

							If nCount > 0
						
								FXV->(DbSetOrder(2))
								FXV->(DbGoTop())
								FXV->(DbSeek((__cTmpFVV)->FVV_FILIAL + (__cTmpFVV)->FVV_CODIGO ))

								lTemCompl	:= .T.
								If !lDecPrinc .Or. ( FXV->FXV_CODPES != __cFVUCod )
									lAchou	:= .F.
									FVG->(DbSetOrder(2))
									FVG->(DbGoTop())
									FVG->(DbSeek((__cTmpFVV)->FVV_FILIAL + (__cTmpFVV)->FVV_CODIGO ) )
									While !FVG->(Eof()) .And. !lAchou .And. FXV->FXV_FILIAL == FVG->FVG_FILIAL
										If FXV->FXV_CODIGO == FVG->FVG_CODIMO .And. FXV->FXV_VERSAO == FVG->FVG_VERSAO .AND. FVG->FVG_NUMIMO == FXV->FXV_NUMIMO .And. FVG->FVG_CODPES == __cFVUCod
										
											aAux1 := {}
											aAux2 := {}
											aAdd(aAuxDec, {"DEC", __cFVUCod, FVG->FVG_PERC, FVG->FVG_TIPO} )
											aAux1 := GetAdvFVal("FXV", {"FXV_CODPES","FXV_PARTIC"},(__cTmpFVV)->FVV_FILIAL + (__cTmpFVV)->FVV_CODIGO,2)
											aAux2 := GetAdvFVal("FVU", {"FVU_NOME","FVU_CNPJ"},SPACE(nTamFil) + aAux1[1],1)
											aAdd(aAuxDec, {"TEC", aAux1[1], aAux1[2], aAux2[1], aAux2[2] })
											lAchou	:= .T.
										EndIf
										FVG->(DbSkip())
									EndDo
								EndIf
															
								While !FXV->(Eof())
									If TRF->FILIAL == FXV->FXV_FILIAL
										cImov	:= Soma1(cImov)
										SX5->(DbSeek(xFilial("SX5") + 'AA' + FXV->FXV_UF) )
										
										cTpPartic	:= FXV->FXV_TIPOEX

										If lDecPrinc .And. Len(aAuxDec) == 0 
											cPartic 	:= Iif("." $ Str(FXV->FXV_PARTIC) ,PadL( Substr(ALLTRIM(Str(FXV->FXV_PARTIC)),1, Rat(".", AllTrim(Str(FXV->FXV_PARTIC)) ) -1 ),3 , "0"), PADL(ALLTRIM(STR(FXV->FXV_PARTIC)),3,"0") )
											cDecParc	:= Iif("." $ Str(FXV->FXV_PARTIC), Substr(Padr(SubStr(AllTrim(Str(Round(FXV->FXV_PARTIC,2))), Rat(".", AllTrim(Str(FXV->FXV_PARTIC)) ) +1, nDecPart),nDecPart,"0") ,1,2), Replicate("0",2))
										Else
											If lAchou
												cPartic 	:= Iif("." $ Str(aAuxDec[1][3]) ,PadL( Substr(ALLTRIM(Str(aAuxDec[1][3])),1, Rat(".", AllTrim(Str(aAuxDec[1][3])) ) -1 ),3 , "0"), PADL(ALLTRIM(STR(aAuxDec[1][3])),3,"0") )
												cDecParc	:= Iif("." $ Str(aAuxDec[1][3]), Substr(Padr(SubStr(AllTrim(Str(Round(aAuxDec[1][3],2))), Rat(".", AllTrim(Str(aAuxDec[1][3])) ) +1, nDecPart),nDecPart,"0") ,1,2), Replicate("0",2))
												cTpPartic	:= AllTrim(Str(Val(aAuxDec[1][4]) + 1))	
											Else	
												lTemCompl	:= .F.
											EndIf
										EndIf
			
										If lTemCompl
											cLinha	+= BL0040 + Dv + cImov + Dv + AllTrim(cPais) + Dv + AllTrim(cMoeda) + Dv + AllTrim(FXV->FXV_CAFIR) + Dv + AllTrim(FXV->FXV_CAEPF) + Dv ;
													+ AllTrim(cIE) + Dv + AllTrim(FXV->FXV_NOME) + Dv + AllTrim(FXV->FXV_END) + Dv + AllTrim(Str(FXV->FXV_NUM) ) + Dv + AllTrim(FXV->FXV_COMPL) + Dv ;
													+ AllTrim(FXV->FXV_BAIRRO) + Dv + AllTrim(FXV->FXV_UF) + Dv + SubStr(AllTrim(SX5->X5_DESCRI),2,2) + AllTrim(FXV->FXV_CODMUN) + Dv + AllTrim(FXV->FXV_CEP) ;
													+ Dv + cTpPartic + Dv + cPartic +cDecParc+ ENTER
											nQtdLin++
										
											FVG->(DbSetOrder(2))
											FVG->(DbGoTop())
											FVG->(DbSeek((__cTmpFVV)->FVV_FILIAL + (__cTmpFVV)->FVV_CODIGO ) )
											While !FVG->(Eof()) .And. FXV->FXV_FILIAL == FVG->FVG_FILIAL
												If FXV->FXV_CODIGO == FVG->FVG_CODIMO .And. FXV->FXV_VERSAO == FVG->FVG_VERSAO .AND. FVG->FVG_NUMIMO == FXV->FXV_NUMIMO
													
													lDecPrin := GetAdvFVal("FXV","FXV_CODPES",FVG->(FVG_FILIAL + FVG_CODPES),2) == __cFVUCod

													If lDecPrin
														cTpPartic	:= AllTrim(Str( Val(FXV->FXV_TIPOEX)-1 ) )											
													Else
														cTpPartic	:= AllTrim(Str( Val(FVG->FVG_TIPO) ) )											
													EndIf
													
													FVU->(DbSetOrder(1))
													FVU->(DbGoTop())
													FVU->(DbSeek(xFilial("FVU") + FVG->FVG_CODPES))
													
													If Len(aAuxDec) == 0 .Or. ( Len(aAuxDec) > 0 .And. ascan(aAuxdec,{|x| x[2]== FVG->FVG_CODPES}) == 0 )
														cDecParc	:= Iif("." $ Str(FVG->FVG_PERC), Substr(Padr(SubStr(AllTrim(Str(Round(FVG->FVG_PERC,2))), Rat(".", AllTrim(Str(FVG->FVG_PERC)) ) +1, nDecPart),nDecPart,"0") ,1,2), Replicate("0",2))
														cPartic 	:= Iif("." $ Str(FVG->FVG_PERC) ,PadL( Substr(ALLTRIM(Str(FVG->FVG_PERC)),1, Rat(".", AllTrim(Str(FVG->FVG_PERC)) ) -1 ),3 , "0"),  PADL(ALLTRIM(STR(FVG->FVG_PERC)),3,"0") )
														cLinha	+= BL0045 + Dv + cImov + Dv + cTpPartic + Dv + AllTrim(FVU->FVU_CNPJ) + Dv + AllTrim(FVU->FVU_NOME) + Dv + ;
																cPartic +cDecParc+ ENTER												
													Else
														cDecParc	:= Iif("." $ Str(aAuxDec[2,3]), Substr(Padr(SubStr(AllTrim(Str(Round(aAuxDec[2,3],2))), Rat(".", AllTrim(Str(aAuxDec[2,3])) ) +1, nDecPart),nDecPart,"0") ,1,2), Replicate("0",2))
														cPartic 	:= Iif("." $ Str(aAuxDec[2,3]) ,PadL( Substr(ALLTRIM(Str(aAuxDec[2,3])),1, Rat(".", AllTrim(Str(aAuxDec[2,3])) ) -1 ),3 , "0"),  PADL(ALLTRIM(STR(aAuxDec[2,3])),3,"0") )												
														cLinha	+= BL0045 + Dv + cImov + Dv + cTpPartic + Dv + AllTrim(aAuxDec[2,5]) + Dv + AllTrim(aAuxDec[2,4]) + Dv + ;
																	cPartic + cDecParc+ENTER
													EndIf
													
													nQtdLin++

													FVG->(DbSkip())
												Else
													FVG->(DbSkip())
												EndIf
											EndDo
										EndIf
									EndIf
									FXV->(DbSkip())
								EndDo
							EndIf
						EndIf
					EndIf
					(__cTmpFVV)->(DbSkip())
				EndDo
					
				TRF->(DbSkip())
			EndDo

			(__cTmpFVV)->(DbCloseArea())
			PrintLn(nHdl, cLinha)
			
			For nI:= 1 To Len(aFVVAux)
				RecLock("TRF", .T.)
					TRF->FILIAL := aFVVAux[nI][1]
					TRF->VER	:= aFVVAux[nI][2]
					TRF->NUMIMO	:= aFVVAux[nI][3]
					TRF->DTINI	:= aFVVAux[nI][4]
					TRF->DTFIM	:= aFVVAux[nI][5]
					TRF->COD	:= aFVVAux[nI][6]
				TRF->(MsUnLock())
			Next nI

			// Imprimir contas com base no cadastro de Bancos (Bl. 0050)
			cLinha	:= ""
				
			If __oTmpBco <> Nil
				__oTmpBco:Delete()
				__oTmpBco := Nil
			EndIf
				
			aAdd(aStruBco, {'BANCO', 'C', 3, 0})
			aAdd(aStruBco, {'AGENCIA', 'C', 5, 0})
			aAdd(aStruBco, {'CONTA', 'C', 16, 0})
			aAdd(aStruBco, {'COD', 'C', 3, 0})
			aAdd(aStruBco, {'FIL', 'C', nTamFil, 0})
				
			__oTmpBco := FwTemporaryTable():New( 'TRB' )
			__oTmpBco:SetFields(aStruBco)
			__oTmpBco:AddIndex('1', {'BANCO', 'AGENCIA', 'CONTA'})
			
			__oTmpBco:Create()
			
			cConta		:= "000"
			__nTamFlA6	:= Len(AllTrim(aBancos[1][5]))
			lTemBcOfi 	:= Len(aBancos[1]) > 6

			If __lF820Bco
				aBancos		:= ExecBlock('F820Bco', .F., .F., { aBancos } )
			EndIf

			cCxFin		:= SuperGetMV("MV_CXFIN",,"CX1")

			_aAuxCx 	:= STRTOKARR(cCxFin, '/')
			_aCxFin 	:= {}
			For nI	:= 1 To Len(_aAuxCx)
				If Len(_aAuxCx[nI]) == 3
					aAdd(_aCxFin, AllTrim(_aAuxCx[nI]))
				EndIf
			Next
			// ANDRE CLARO 25/04/2025 - TRATAMENTO PARA CONSIDERAR APENAS BANCOS QUE N�O S�O CAIXAS.
			For nI := 1 To Len(aBancos)
				If aScan(_aCxFin, { |x| x == AllTrim(aBancos[nI][1]) } ) == 0
					If lTemBcOfi .And. !Empty(aBancos[nI][7])
						SX5->(DbSeek(xFilial("SX5") + "0N" + aBancos[nI][7]) )
					Else
						SX5->(DbSeek(xFilial("SX5") + "0N" + aBancos[nI][1]) )
					EndIf
					cConta	:= Soma1(cConta)
					
					cLinha	+= BL0050 + Dv + cConta + Dv + AllTrim(aBancos[nI][6]) + Dv + If(lTemBcOfi .And. !Empty(aBancos[nI][7]), aBancos[nI][7], AllTrim(aBancos[nI][1]) ) + Dv + SubStr( AllTrim(Iif(!Empty(SX5->X5_DESCRI), SX5->X5_DESCRI, STR0011)), 1, 30 ) + Dv + SubStr( AllTrim(aBancos[nI][2]), 1, 4 ) + Dv + PadL(AllTrim(aBancos[nI][3]) + Iif( IsAlpha(aBancos[nI][4]) , "0", AllTrim(aBancos[nI][4]) ), 16, "0" ) + ENTER // Banco LCDPR

					RecLock('TRB', .T.)
					TRB->BANCO		:= AllTrim(aBancos[nI][1])
					TRB->AGENCIA	:= AllTrim(aBancos[nI][2])
					TRB->CONTA		:= AllTrim(aBancos[nI][3])
					TRB->COD		:= cConta
					TRB->FIL		:= AllTrim(aBancos[nI][5])
					TRB->(MsUnLock())
					
					nQtdLin++
				EndIf
			Next
			
			PrintLn(nHdl, cLinha)
			
			cLinha := ""
			// Imprimir movimentos retornado na MontaLCDPR (Bl. Q100)
			ArqTmp( '0',,, cFiliais, aParamIni, cDtPeriodo )
			
			cLinAux	:= ""
			cLin200	:= ""
			nSaldo	:= 0
			nValor	:= 0
			nSaldoR	:= 0
			nSaldoP	:= 0
			cMes	:= ""
			cOldMes	:= ""
			cNatSld	:= ""
			
			aAuxCx 	:= STRTOKARR(cCxFin, '/')
			For nI	:= 1 To Len(aAuxCx)
				If Len(aAuxCx[nI]) == 3
					aAdd(aCxFin, AllTrim(aAuxCx[nI]))
				EndIf
			Next
					
			TRB100->(DbGoTop())
			_nX := 0 
			While !TRB100->(Eof()) //andrecclaro 29/11/2022 - lentidão
				_nX ++

				//_cRastro += char(13)+char(10)+ StrZero(_nX,5)+" "+Alltrim(TRB100->NUMDOC)+"  - Hr. inicio |"+Time()
				//_cRastro += char(13)+char(10)+ Space(10)+"LN802 - Hr. inicio |"+Time()
				IF (__cLCDPRRA == "D" .AND. TRB100->TPDOC == "CP" .AND.; 
					!EMPTY(TRB100->E1_VLCRUZ)) .OR. ;
					(__cLCDPRPA == "D" .AND. TRB100->TPDOC == "CP" .AND. !EMPTY(TRB100->E2_VLCRUZ)) ;
					.OR. AllTrim(TRB100->E5_MOTBX) $ "LIQ|FAT|STP|DSD" //ANDRECCLARO 

					RecLock("TRB100",.F.)
						TRB100->OBSACC := "Compensa��o ou LIQ/FAT/STP/DSD"
					MsUnLock()

					TRB100->(DbSkip())

					IF TRB100->(Eof())
						Exit
					ELSE
						Loop
					ENDIF
				ENDIF
				//_cRastro += char(13)+char(10)+Space(10)+" LN820 - Hr. inicio |"+Time()
				
				__nVlNota	:= 0
				__nVlFun	:= 0
				__lFunrural	:= .F.
				__lNftot	:= .F.
				nValCorr	:= 0
				nAbat		:= 0
				nAbtTotal	:= 0
				lTipoVA 	:= TRB100->TPDOC $ "JR|DC|MT"

				cBanco		:= ""
				lRegValid	:= .T.
				If ValType(TRB100->MOEDA) == 'N'
					cMoedAux	:= PadL(TRB100->MOEDA, 2, "0" )
				Else
					cMoedAux	:= AllTrim(TRB100->MOEDA)
				EndIf
				If AllTrim(TRB100->TPDOC) $ 'BA' .And. TRB100->E5_MOTBX $ "'CMP'|'FAT'"
					lRegValid	:= .F.
				EndIf

				If lRegValid
					// Se for um recebimento de Titulo pago em dinheiro originado pelo SIGALOJA, nao imprime o mov.
					If TRB100->TPDOC == "BA" .and. TRB100->E5_MOTBX == "LOJ" .And. IsMoney(cMoedAux)
						RecLock("TRB100",.F.)
							TRB100->OBSACC := "TipoDoc = BA e Mot. Baixa = LOJ"
						MsUnLock()					
						lRegValid := .F.
					EndIf
				EndIf
				//_cRastro += char(13)+char(10)+Space(10)+" LN854 - Hr. inicio |"+Time()
				cRotOri	:= ""
				cFilOri	:= ""
				aSize(aAuxSE, 0)
				aAuxSE	:= Nil
				aAuxSE	:= {}
				//Tratamento p/ ñ imp tít aglutinador quando o mesmo não estiver sofrido baixa.
				If !Empty(TRB100->REC) .AND. !('IMPZGB' $  TRB100->ORI )
					If !(__lF820Qry) .Or. (__lF820Qry .And. ( Empty(TRB100->CODEMP) .Or. (!Empty(TRB100->CODEMP) .And. cEmpAnt == TRB100->CODEMP ) ) )
						aAuxSE	:= RotOri(TRB100->RECPAG, TRB100->SEFIL, TRB100->PREFIXO, TRB100->NUMDOC, TRB100->PARC, TRB100->E5_TIPO, TRB100->CLIFOR, TRB100->LOJA)
						cRotOri		:= aAuxSE[1]
						__cFilOri	:= cFilOri := SE5->E5_FILORIG
						__nTxMoeda	:= SE5->E5_TXMOEDA
	
						DbSelectArea("SE5")
						SE5->( DbGoTo(TRB100->REC) )
						
						RecLock("TRB100",.F.)
							If TRB100->TPDOC == "CP" .And. TRB100->E5_MOTBX $ "CMP"
								If TRB100->RECPAG == "R" .And. Substr(SE5->E5_DOCUMEN,nTamTitR,3) $ MV_CRNEG //NCC
									lRegValid := .F.
							//		RecLock("TRB100",.F.)
										TRB100->OBSACC := "Contas a receber e Tipo Adiantamento (MV_CRNEG)"
							//		MsUnLock()								
								ElseIf TRB100->RECPAG == "P" .And. Substr(SE5->E5_DOCUMEN,nTamTitP,3) $ MV_CPNEG //NDF
									lRegValid := .F.
							//		RecLock("TRB100",.F.)
										TRB100->OBSACC := "Contas a pagar e Tipo Adiantamento (MV_CPNEG) "
							//		MsUnLock()								
								EndIf
							EndIf
							If lRegValid .And. Empty(SE5->(E5_TIPO+E5_DOCUMEN+E5_IDMOVI+E5_FILORIG+E5_MOEDA))
								//RecLock("TRB100",.F.)
									TRB100->OBSACC := "Chave (SE5->(E5_TIPO+E5_DOCUMEN+E5_IDMOVI+E5_FILORIG+E5_MOEDA)) vazia! "
								//MsUnLock()							
								lRegValid 	:= .F.
							EndIf
							If lRegValid .And. AllTrim(SE5->E5_ORIGEM) != 'FINA100' .And. Empty(SE5->E5_TIPODOC) .And. Empty(SE5->E5_NUMERO)
								//	RecLock("TRB100",.F.)
										TRB100->OBSACC := "Origem <> Fina100 e  ( Tipodoc e Numero) vazio  "
								//	MsUnLock()							
								lRegValid 	:= .F.
							EndIf
							cBanco	:= SE5->E5_BANCO
						
							If lRegValid .And. TRB100->RECPAG == 'P' .And. !Empty(SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ) ) .And. SE5->E5_TIPODOC == 'BA'
								If !FTemChq(SE5->E5_FILIAL, SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_NUMCHEQ)
									lRegValid	:= .F.
									//RecLock("TRB100",.F.)
										TRB100->OBSACC := "Contas a pagar com cheque e motivo de baixa BA"
									//MsUnLock()									
								ElseIf cDtPeriodo == '2'
									If TRB100->TPDOC == 'BA'
										lRegValid	:= .F.
									//	RecLock("TRB100",.F.)
											TRB100->OBSACC := "Tipodoc = BA "
									//	MsUnLock()										
									Else
										cDtCheq := GetAdvFVal("SEF","EF_DATA", FwxFilial("SEF", cFilOri) + SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ),1)
													// EF_FILIAL, EF_BANCO, EF_AGENCIA, EF_CONTA, EF_NUM
										If !( aParamIni[7] <= cDtCheq .And. cDtCheq <= aParamIni[8] )
											lRegValid	:= .F.
									//		RecLock("TRB100",.F.)
												TRB100->OBSACC := "Dt. Cheque menor que data inicial  "
									//		MsUnLock()											
										EndIf
									EndIf
								EndIf
							EndIf
						MsUnLock()											
						nValCorr 	:= SE5->E5_VLCORRE 
					EndIf
				Else
					aAuxSE	:= RotOri(TRB100->RECPAG, TRB100->SEFIL, TRB100->PREFIXO, TRB100->NUMDOC, TRB100->PARC, TRB100->E5_TIPO, TRB100->CLIFOR, TRB100->LOJA)
					cRotOri	:= aAuxSE[1]
					cFilOri	:= aAuxSE[2]
				EndIf
				//_cRastro += char(13)+char(10)+Space(10)+" LN828 - Hr. inicio |"+Time()

				RecLock("TRB100",.F.)
					If ( !Empty(TRB100->E5_TIPO) .And. TRB100->E5_TIPO $ MVPAGANT ) .And. ( AllTrim(TRB100->TPDOC) = 'BA'; 
							.And. TRB100->E5_MOTBX != 'CEC' )
						lRegValid	:= .F.
				//		RecLock("TRB100",.F.)
							TRB100->OBSACC := "Tipo pgto antecipado e Tipodoc = BA e NÃO É CEC "
				//		MsUnLock()						
					EndIf

					If ( !Empty(TRB100->E5_TIPO) .And. TRB100->E5_TIPO $ MVPAGANT ) .And. ;
						( ( TRB100->RECPAG == 'R' .And. TRB100->E5_MOTBX != 'CMP' ) )
						lRegValid	:= .F.
				//		RecLock("TRB100",.F.)
							TRB100->OBSACC := "Tipo pgto antecipado e Contas a receber e MotBx <> CMP"
				//		MsUnLock()
					EndIf

					If ( !Empty(TRB100->E5_TIPO) .And. TRB100->E5_TIPO $ MVPAGANT ) .And. ;
						( ( TRB100->RECPAG == 'R' .And. TRB100->E5_MOTBX != 'CMP' ) )
						lRegValid	:= .F.
				//		RecLock("TRB100",.F.)
							TRB100->OBSACC := "Tipo rec. antecipado e Contas a receber e MotBx <> CMP"
				//		MsUnLock()					
					EndIf

					If ( !Empty(TRB100->E5_TIPO) .And. TRB100->E5_TIPO $ MVRECANT ) .And. ;
						( ( TRB100->RECPAG == 'P' .And. TRB100->E5_MOTBX != 'CMP' ) )
						lRegValid	:= .F.
				//		RecLock("TRB100",.F.)
							TRB100->OBSACC := "Tipo pgto antecipado e Contas a receber e MotBx <> CMP"
				//		MsUnLock()
					EndIf
				MsUnLock()
				/*
				_cRastro += char(13)+char(10)+Space(10)+" LN961 - Hr. inicio |"+Time()
				If __lF820Reg .and. !("IMPZGB" $ Alltrim(TRB100->ORI))
					If __aTpReg <> Nil
						lRegValid	:= ExecBlock('F820Reg', .F., .F., { TRB100->REC, {}, lRegValid } )[1]
					Else
						__aTpReg	:= { {""}, {""}, {""}, {""}, {""} }
						aTpReg		:= ExecBlock('F820Reg', .F., .F., { TRB100->REC, __aTpReg, lRegValid } )
						lRegValid	:= aTpReg[1]
						__aTpReg 	:= aClone(aTpReg[2] )
					EndIf
				EndIf

				If !lRegValid
					RecLock("TRB100",.F.)
						TRB100->OBSACC := "Retorno negativo do PE F820REG "
					MsUnLock()				
					TRB100->(DbSkip())
					Loop
				EndIf
				*/
				//_cRastro += char(13)+char(10)+Space(10)+" LN982 - Hr. inicio |"+Time()
				If lRegValid
					cMes 	:= TRB100->MES_ANO
					nProp	:= If(TRB100->PERC > 0, TRB100->PERC, 100) / 100

					//Alert("Cod.: "+_cCodParc)
					IF "IMPZGB" $ TRB100->ORI
						If TRB100->REC > 0 
							ZGB->(DbGotop())
							ZGB->(DbGoTo(TRB100->REC))
							If ZGB->(RECNO()) == TRB100->REC
								If _cCodParc $  ZGB->ZGB_PARTIC
									nProp := 1
								EndIf
							EndIf
						EndIf
					//ElseIf _cCodParc == "000005"
					//	If Alltrim(cValToChar(TRB100->REC)) $ "545327,545328,545132,545548,545549,545544,545550,545551,545545,545552,545553,545546,545554,545555,545547,545538,545539,545535,545541,545542,545540,572715,587715,588760,588956,590053,590054,590044,589669,590052,590043,589675,590051,590055,590042,589663,590050,590056,590047,626513,626512,626470,626468,626518,630407,630406,630409,630410,664775,664777,664773,664776"
					//		nProp := 1
					//	EndIf
					EndIf

					If TRB100->RECPAG == 'P'
						If !lTipoVA .And. ( lVlLiqP .Or. ( !Fn820Abat(TRB100->RECPAG,TRB100->E5_TIPO) .And. TRB100->E2_VLCRUZ <> TRB100->VALOR ) )
							DbSelectArea("SE2")
							DbSetOrder(1)
							DbSeek(xFilial("SE2", cFilOri ) + TRB100->PREFIXO + TRB100->NUMDOC + TRB100->PARC + TRB100->E5_TIPO + TRB100->CLIFOR + TRB100->LOJA )
							nAbtTotal	:= SumAbatPag( TRB100->PREFIXO, TRB100->NUMDOC, TRB100->PARC, TRB100->CLIFOR, Val(TRB100->MOEDA), "V", CTOD(TRB100->DDATA), TRB100->LOJA )
							nTxMTit		:= SE2->E2_TXMOEDA
						EndIf
						//_cRastro += char(13)+char(10)+Space(10)+" LN997 - Hr. inicio |"+Time()
					ElseIf !lTipoVA .And. ( lVlLiqR .Or. ( !Fn820Abat(TRB100->RECPAG,TRB100->E5_TIPO) .And. TRB100->E1_VLCRUZ <> TRB100->VALOR ) )
						DbSelectArea("SE1")
						DbSetOrder(2)
						DbSeek(xFilial("SE1", cFilOri ) + TRB100->CLIFOR + TRB100->LOJA + TRB100->PREFIXO + TRB100->NUMDOC + TRB100->PARC + TRB100->E5_TIPO )
						nAbtTotal := SumAbatRec( TRB100->PREFIXO, TRB100->NUMDOC, TRB100->PARC, Val(TRB100->MOEDA), "V", CTOD(TRB100->DDATA) ) 	
						nTxMTit		:= SE1->E1_TXMOEDA
						//_cRastro += char(13)+char(10)+Space(10)+" LN1003 - Hr. inicio |"+Time()
					EndIf
					If nAbtTotal > 0 .And. Val(TRB100->MOEDA) > 1
						nAbtTotal := xMoeda(nAbtTotal,Val(TRB100->MOEDA),1,TRB100->DDATA,__nDecs + 1,If(__nTxMoeda > 1, __nTxMoeda, If( nTxMTit <> 0, nTxMTit, RecMoeda(TRB100->DDATA,Val(TRB100->MOEDA)))) )
						//_cRastro += char(13)+char(10)+Space(10)+" LN1008 - Hr. inicio |"+Time()
					EndIf

					__nAbtNF	:= 0
					If !( "FIN" $ cRotOri ) .And. !lTipoVA
						If !("IMPZGB" $ Alltrim(TRB100->ORI))
							nValor := ValBruNf(TRB100->RECPAG, cFilOri, TRB100->PREFIXO, TRB100->NUMDOC, TRB100->PARC, TRB100->E5_TIPO, TRB100->CLIFOR, TRB100->LOJA, TRB100->RECSF12, TRB100->VBRUT12,TRB100->VSENA12,TRB100->VINSS12,TRB100->COSOC12)
							nValor := Val(StrTran(Transform( If( !Empty(cMoedAux) .And. !cMoedAux $ '01|M1' .And. TRB100->VLMOED2 > 0, If(FMoedTit(cMoedAux, cFilOri, @nVlCruz), nVlCruz, TRB100->VLMOED2) / __nPropBx, nValor) * nProp, cPict), ".", "") )
							//_cRastro += char(13)+char(10)+Space(10)+" LN1016 - Hr. inicio |"+Time()
						Else
							nValor := TRB100->VALOR //  ValBruNf(TRB100->RECPAG, cFilOri, TRB100->PREFIXO, TRB100->NUMDOC, TRB100->PARC, TRB100->E5_TIPO, TRB100->CLIFOR, TRB100->LOJA, TRB100->RECSF12, TRB100->VBRUT12,TRB100->VSENA12,TRB100->VINSS12,TRB100->COSOC12)
							nValor := Val(StrTran(Transform( If( !Empty(cMoedAux) .And. !cMoedAux $ '01|M1' .And. TRB100->VLMOED2 > 0, If(FMoedTit(cMoedAux, cFilOri, @nVlCruz), nVlCruz, TRB100->VLMOED2) / __nPropBx, nValor) * nProp, cPict), ".", "") )
							//_cRastro += char(13)+char(10)+Space(10)+" LN1020 - Hr. inicio |"+Time()
						EndIf 
					Else
						nValor		:= Val(StrTran(Transform( If( !Empty(cMoedAux) .And. !cMoedAux $ '01|M1' .And. TRB100->VLMOED2 > 0, If(FMoedTit(cMoedAux, cFilOri, @nVlCruz), nVlCruz,TRB100->VLMOED2), TRB100->VALOR) * nProp, cPict), ".", "") )
						//_cRastro += char(13)+char(10)+Space(10)+" LN91024 - Hr. inicio |"+Time()
						If AllTrim(TRB100->TPDOC) == "CH"
							__nPropBx	:= 1
							//_cRastro += char(13)+char(10)+Space(10)+" LN1027 - Hr. inicio |"+Time()
						Else
							__nPropBx	:= If(Val(TRB100->MOEDA) > 1, ( ( nValor / 100 ) / nProp ), TRB100->VALOR ) / If(TRB100->RECPAG == "R", TRB100->E1_VLCRUZ-nAbtTotal, TRB100->E2_VLCRUZ - nAbtTotal)
							//_cRastro += char(13)+char(10)+Space(10)+" LN1030 - Hr. inicio |"+Time()
						EndIf
						
					EndIf
					//_cRastro += char(13)+char(10)+Space(10)+" LN1022 - Hr. inicio |"+Time()
					nAbtTotal := nAbtTotal - __nAbtNF
					If nAbtTotal < 0
						nAbtTotal := 0
					EndIf
					If !Empty(TRB100->REC)
						If !(__lF820Qry) .Or. (__lF820Qry .And. ( Empty(TRB100->CODEMP) .Or. (!Empty(TRB100->CODEMP) .And. cEmpAnt == TRB100->CODEMP ) ) )
							If nAbtTotal > 0 .And. !__lNftot
								nAbat	+= ( ( nAbtTotal * nProp ) * 100 ) * __nPropBx
								nValor	+= nAbat
								nValor 	:= Val(StrTran(Transform( nValor / 100, cPict), ".", "") )
							EndIf
						EndIf
					EndIf
					
					IF (__cLCDPRRA == "D" .AND. TRB100->E5_TIPO == "RA " ) .AND. !EMPTY(TRB100->E1_VLCRUZ)
						nValor := Round((TRB100->VALOR * nProp),2)*100
					ENDIF

					IF (__cLCDPRPA == "D" .AND. TRB100->E5_TIPO == "PA " ) .AND. !EMPTY(TRB100->E2_VLCRUZ)
					
						nValor := Round((TRB100->VALOR * nProp),2)*100
					ENDIF

					nSaldo 	+= Iif( ( TRB100->RECPAG == 'R' .Or. TRB100->E5_TIPO $ MV_CPNEG ) .And. TRB100->E5_TIPO # MV_CRNEG .And. nValor >= 0, nValor, ( nValor * -1 ) )

					cNatSld	:= Iif( nSaldo < 0, "N", "P")
					If "IMPZGB" $ TRB100->ORI
						cNumDoc	:= 'XRT-'+TRB100->NUMDOC
					Else
						cNumDoc	:= "" 
					EndIf
					nCaso 	:= 0

					If TRB100->E5_TIPO == "AB-"
						cHist 	:= STR0023 + AllTrim(TRB100->NUMDOC)
					ElseIf TRB100->E5_TIPO == "IN-"
						cHist 	:= STR0024 + AllTrim(TRB100->NUMDOC)
					ElseIf Empty( AllTrim(TRB100->HIST) ) 
						cHist 	:= Iif( Empty(AllTrim(TRB100->NUMDOC)), STR0019, STR0018 + AllTrim(TRB100->NUMDOC) ) // "S/Num. de documento" # "No. Documento: "
					Else
						cHist	:= FwNoAccent(AllTrim(TRB100->HIST))
						If !Empty(TRB100->E5_MOTBX) .AND. !EMPTY(TRB100->NUMDOC)
							If TRB100->E5_MOTBX $ "CMP|CEC"
								cHist := IIF(TRB100->RECPAG=="R","Comp. Rec.: ","Comp. Pag.: ")+Alltrim(TRB100->E5_TIPO)+" ";
											+Alltrim(TRB100->NUMDOC)+IIF(Empty(TRB100->PARC),"",Alltrim(TRB100->PARC)); //+" "+Alltrim(TRB100->E5_BENEF)
											+" "+Alltrim(GetAdvFVal("SED","ED_DESCRIC",xFilial("SED") + TRB100->E5_NATUREZ,1,"" )) 
							Else
								cHist := IIF(TRB100->RECPAG=="R","Rec.: ","Pag.: ")+Alltrim(TRB100->E5_TIPO)+" ";
											+Alltrim(TRB100->NUMDOC)+IIF(Empty(TRB100->PARC),"",Alltrim(TRB100->PARC); //+" "+Alltrim(TRB100->E5_BENEF)
											+" "+Alltrim(GetAdvFVal("SED","ED_DESCRIC",xFilial("SED") + TRB100->E5_NATUREZ,1,"" )))
							EndIf
						EndIf
					EndIf

					If "IMPZGB" $ TRB100->ORI .AND. "XRT" $ AllTrim(TRB100->HIST)
						If Empty( TRB100->CNPJFOR )
							If lE5Cgc .And. !Empty( TRB100->CGC )
								cCnpj	:= TRB100->CGC
							Else
								cCnpj	:= __cCpf
							EndIf
						Else
							cCnpj	:= TRB100->CNPJFOR
						EndIf
					ElseIf !Empty( TRB100->CNPJCLI ) .AND. TRB100->RECPAG == "R"
						cCnpj	:= 	TRB100->CNPJCLI
					Else
						If Empty( TRB100->CNPJFOR )
							If lE5Cgc .And. !Empty( TRB100->CGC )
								cCnpj	:= TRB100->CGC
							Else
								cCnpj	:= __cCpf
							EndIf
						Else
							cCnpj	:= TRB100->CNPJFOR
						EndIf	
					EndIf
					//_cRastro += char(13)+char(10)+Space(10)+" LN1077 - Hr. inicio |"+Time()
					Do Case
						Case TRB100->E5_TIPO $ MVNOTAFIS + Iif(__lF820Reg, "|" + __aTpReg[1][1], "") .AND. !lTipoVA
							cTipo	:= TPDOCNF
							nCaso 	:= 1

							//Pagina 26 do Anexo ao Ato Declaratório Executivo COPES no 1/2020 – Manual de Preenchimento do LCDPR
							//Caso o país esteja no bloco Mercosul, preencher com número da Nota Fiscal
							//Caso o país não seja parte do bloco Mercosul, preencher com o número da Declaração de Importação/Exportação
							DbSelectArea("SYA")
							SYA->(DbSetOrder(1))//YA_FILIAL + YA_CODGI
							If SYA->(DbSeek(FwxFilial("SYA") + TRB100->PAISFOR ))
								lMercosul := IIF(SYA->YA_MERCOSU == "1", .T., .F.)
							EndIf
							
							DbSelectArea("CD5")
							CD5->(DbSetOrder(1))//CD5_FILIAL + CD5_DOC + CD5_SERIE 
							If !lMercosul .AND. CD5->(DbSeek(FwxFilial("CD5") + TRB100->NUMDOC + AllTrim(TRB100->PREFIXO) ))
								cNumDoc := Alltrim(CD5->CD5_DOCIMP)
							Else
								cNumDoc	:= AllTrim(TRB100->NUMDOC) + Iif( !Empty(AllTrim(TRB100->PREFIXO)), "/" + AllTrim(TRB100->PREFIXO), "") 
							EndIf
						Case TRB100->E5_TIPO $ MVFATURA + Iif(__lF820Reg, "|" + __aTpReg[2][1], "") .AND. !lTipoVA
							cTipo 	:= TPDOCFT
							cNumDoc	:= Iif( !Empty(AllTrim(TRB100->PREFIXO)), AllTrim(TRB100->PREFIXO) + "/", "" ) + AllTrim(TRB100->NUMDOC)
						Case TRB100->E5_TIPO $ 'RC ' + Iif(__lF820Reg, "|" + __aTpReg[3][1], "") .AND. !lTipoVA
							cTipo := TPDOCRC
							cNumDoc	:= Iif( !Empty(AllTrim(TRB100->PREFIXO)), AllTrim(TRB100->PREFIXO) + "/", "" ) + AllTrim(TRB100->NUMDOC)
						Case TRB100->E5_TIPO $ 'C01' + Iif(__lF820Reg, "|" + __aTpReg[4][1], "") .AND. !lTipoVA
							cTipo := TPDOCCT
							cNumDoc	:= Iif( !Empty(AllTrim(TRB100->PREFIXO)), AllTrim(TRB100->PREFIXO) + "/", "" ) + AllTrim(TRB100->NUMDOC)
						Case TRB100->E5_TIPO $ 'FOL|FER' + Iif(__lF820Reg, "|" + __aTpReg[5][1], "") .AND. !lTipoVA
							cTipo := TPDOCFP
							cNumDoc	:= Iif( !Empty(AllTrim(TRB100->PREFIXO)), AllTrim(TRB100->PREFIXO) + "/", "" ) + AllTrim(TRB100->NUMDOC)
						OtherWise
							cTipo := TPDOCOU
							cNumDoc	:= Iif( !Empty(AllTrim(TRB100->PREFIXO)), AllTrim(TRB100->PREFIXO) + "/", "" ) + AllTrim(TRB100->NUMDOC)
					EndCase
					//_cRastro += char(13)+char(10)+Space(10)+" LN1115 - Hr. inicio |"+Time()
					nVlNFE1		:= Iif(__lFunrural .Or. __nVlNota > 0,__nVlNota,TRB100->E1_VLCRUZ)
					nVlNFE2		:= Iif(__lFunrural .Or. __nVlNota > 0,__nVlNota,TRB100->E2_VLCRUZ)
					nValNF 		:= Iif(TRB100->VBRUT12 > 0, TRB100->VBRUT12, Iif(nVlNFE2>0,nVlNFE2,If(nVlNFE1 > 0, nVlNFE1, TRB100->VALOR + nAbtTotal)) )
					//_cRastro += char(13)+char(10)+Space(10)+" LN1119 - Hr. inicio |"+Time()
					IF "IMPZGB" $ TRB100->ORI
						If TRB100->REC > 0 
							ZGB->(DbGotop())
							ZGB->(DbGoTo(TRB100->REC))
							If ZGB->(RECNO()) == TRB100->REC
								nValCorr := ZGB->ZGB_VLCORR
								If nValCorr > 0
									cHistC := STR0022 + Alltrim(Transform(Abs(nValCorr),cPictR)) // " - C/ correc. monet. negat.: "
								ElseIf nValCorr < 0
									cHistC := STR0021 + Alltrim(Transform(Abs(nValCorr),cPictR)) // " - C/ correc. monet. posit.: " 
								Else
									cHistC := ""
								EndIf								
							EndIf
						EndIf
					Else
						If nValCorr > 0
							cHistC := STR0021 + Alltrim(Transform(Abs(nValCorr),cPictR)) // " - C/ correc. monet. posit.: " 
						ElseIf nValCorr < 0
							cHistC := STR0022 + Alltrim(Transform(Abs(nValCorr),cPictR)) // " - C/ correc. monet. negat.: "
						Else
							cHistC := ""
						EndIf
					EndIf
					
					//_cRastro += char(13)+char(10)+Space(10)+" LN1153 - Hr. inicio |"+Time()
					
					If lTipoVA
						cHistNF := STR0025+ AllTrim(TRB100->NUMDOC)
					Else
						cHistNF := STR0017 + AllTrim(Transform(nValNF, cPictR))
					EndIf	

					cValor := IIf(Abs(nValor) >= 100 , AllTrim(Str(Abs(nValor))) ,  Padl(AllTrim(Str(Abs(nValor))), nTamSx3 , "0"))
					cSaldo := IIf(Abs(nSaldo) >= 100 , AllTrim(Str(Abs(nSaldo))) ,  Padl(AllTrim(Str(Abs(nSaldo))), nTamSx3 , "0"))

					//_cRastro += char(13)+char(10)+Space(10)+" LN1164 - Hr. inicio |"+Time()
					
					cCodBco := ''
					If Empty(TRB100->BANCO) .And. lTipoVA 		// lTipoVA 	:= TRB100->TPDOC $ "JR|DC|MT"
						cCodBco := '999'
					ElseIf !Empty(TRB100->BANCO) .and. aScan(aCxFin, { |x| x == TRB100->BANCO } ) == 0
						cCodBco := TRB100->BANCO
					ElseIf Empty(TRB100->BANCO) .And. TRB100->E5_MOTBX == 'CMP'
						cCodBco := BcoAdto()
					ElseIf TRB100->E5_MOTBX == 'ESP' .OR. TRB100->MOEDA == 'R$' .OR. ( !Empty(TRB100->BANCO) .And. aScan(aCxFin, { |x| x == TRB100->BANCO } ) > 0 )
						cCodBco := "000"
					Else
						cCodBco := '999'
					EndIf

					_cLinACC	:= BLQ100 + Dv + TRB100->DIA + TRB100->MES_ANO + Dv + TRB100->FILCOD + Dv + cCodBco + Dv + cNumDoc + Dv + cTipo + Dv + ;
							Iif( __lImpHist, cHist, Iif(nCaso == 1 .Or. lTipoVA , cHist + " - " + cHistNF + cHistC, IIF( "IMPZGB" $ TRB100->ORI , cHist + cHistC, cHist ) ) ) + Dv + ;
							AllTrim(Iif( TRB100->CLIFOR $ cUniao + '|' + cMunic + '|' + cSecEst .And. TRB100->RECPAG == 'P', __cCpf, AllTrim(cCnpj) ) ) + Dv+;
							Iif( TRB100->TPDOC $ MVPAGANT .Or. (TRB100->E5_MOTBX == "CMP" .And. TRB100->RECPAG == 'P'), '3|0000000000000000|' + cValor, ;
							Iif( TRB100->TPDOC $ MVRECANT .Or. (TRB100->E5_MOTBX == 'CMP' .And. TRB100->RECPAG == 'R'), '3|' + cValor + '|0000000000000000',; 
							Iif( ( ( TRB100->RECPAG == 'R' .And. TRB100->TPDOC # MVRECANT ) .Or. TRB100->E5_TIPO $ MV_CPNEG ) .And. TRB100->E5_TIPO # MV_CRNEG, ;
							"1|" + cValor + "|0000000000000000", "2|0000000000000000|" + cValor ) ) ) + Dv + cSaldo + Dv + cNatSld + ENTER
					cLinha += _cLinACC
						_nRecACC := 0
						_nPagACC := 0
						_nSldACC := 0

						If !Empty(Iif( TRB100->TPDOC $ MVRECANT .Or. (TRB100->E5_MOTBX $ 'CMP|CEC|REC' .And. TRB100->RECPAG == 'R').OR. (TRB100->RECPAG=="R".AND."IMPZGB" $ TRB100->ORI),  cValor , "" ))
							_nRecACC := Val(SubStr(cValor,1,Len(cValor)-2))
							_nRecACC += Val( SubStr(cValor, Len(cValor )-1, 2))/100
						Else
							_nPagACC := Val(SubStr(cValor,1,Len(cValor)-2))
							_nPagACC += Val( SubStr(cValor, Len(cValor )-1, 2))/100
						EndIf

						_aTempVal := {}
						_aTempVal :=  strtoarray(StrTran(_cLinACC,"||","|ABCDEFG|"),"|") //strtoarray(_cLinACC,"|")
						If Len(_aTempVal) > 0 
							If Val(_aTempVal[10])
								_nRecACC := Val(SubStr(cValor,1,Len(cValor)-2))
								_nRecACC += Val( SubStr(cValor, Len(cValor )-1, 2))/100
								_nPagACC := 0 
							ElseIf Val(_aTempVal[11]) > 0 
							_nPagACC := Val(SubStr(cValor,1,Len(cValor)-2))
							_nPagACC += Val( SubStr(cValor, Len(cValor )-1, 2))/100
							_nRecACC := 0
							EndIf
						EndIf

						_nSldACC := Val(SubStr(cSaldo,1,Len(cSaldo)-2))
						_nSldACC += Val( SubStr(cSaldo, Len(cSaldo )-1, 2))/100

						RecLock("TRB100",.F.)
							TRB100->NRECACC := _nRecACC
							TRB100->NPAGACC := _nPagACC
							TRB100->CNATSLD := cNatSld
							TRB100->NSLDACC := _nSldACC
							TRB100->CLINACC := _cLinACC
							TRB100->LCPRDSN := "S"
						MsUnLock()
					
					//_cRastro += char(13)+char(10)+Space(10)+" LN1208 - Hr. inicio |"+Time()
					
					nQtdLin++

					If __lFunrural .And. !lTipoVA .AND. "ALINE" == "ANDRECCLARO"
						__nVlFun 	:= __nVlFun * nProp
						If Abs(__nVlFun) > 0 
							nSaldo 		-= Val(StrTran(Transform(ABS(__nVlFun), cPict), ".", "") )
							__nVlFun	:= Val(StrTran(Transform( __nVlFun, cPict), ".", "") )
							cVlFun := IIf(Abs(__nVlFun) >= 100 , AllTrim(Str(Abs(__nVlFun))) ,  Padl(AllTrim(Str(Abs(__nVlFun))), nTamSx3 , "0"))
							cSaldo := IIf(Abs(nSaldo) >= 100 , AllTrim(Str(Abs(nSaldo))) ,  Padl(AllTrim(Str(Abs(nSaldo))), nTamSx3 , "0"))
						
							cLinha	+= BLQ100 + Dv + TRB100->DIA + TRB100->MES_ANO + Dv + TRB100->FILCOD + Dv + "999" + Dv + cNumDoc + Dv + TPDOCOU + Dv + ;
								Iif( __lImpHist, cHist, Iif(nCaso == 1 .And. TRB100->E1_VLCRUZ > 0 .And. ( ( TRB100->E1_VLCRUZ * 100 )/ nProp ) <> nValor, cHist, ;
								Iif( nCaso == 1 .And. TRB100->E2_VLCRUZ > 0 .And. ( ( TRB100->E2_VLCRUZ * 100 )/ nProp ) <> nValor, cHist, cHist ) ) ) + Dv + ;
								AllTrim(Iif( TRB100->CLIFOR $ cUniao + '|' + cMunic + '|' + cSecEst .And. TRB100->RECPAG == 'P', __cCpf, AllTrim(cCnpj) ) ) + Dv + "2|0000000000000000|" + cVlFun + Dv + cSaldo + Dv + Iif( nSaldo - __nVlFun < 0, "N", "P") + ENTER

							  nQtdLin++
						EndIf
					EndIf
					__nVlFun := 0
					__nVlFun:= Abs(__nVlFun)
					
					If !Empty(cOldMes)						
						If cMes != cOldMes
							nSaldoR	:= 0
							nSaldoP	:= 0
							If (( TRB100->RECPAG == 'R' .Or. TRB100->E5_TIPO $ MV_CPNEG ) .And. TRB100->E5_TIPO # MV_CRNEG)
								nSaldoR := Abs(nValor)
								nSld200	+= nSaldoR
								If __lFunrural
									nSaldoP += ( __nVlFun * -1 )
									nSld200	+= ( __nVlFun * -1 )
								Else
									nSaldoP	:= 0
								EndIf
							Else
								nSaldoP := ( nValor * -1 )
								nSld200	+= nSaldoP
								nSaldoR	:= 0
								If __lFunrural
									nSaldoP += ( __nVlFun * -1 )
									nSld200	+= ( __nVlFun * -1 )
								EndIf
							EndIf
							
					 		cOldMes := cMes
					 		cLin200	+= cLinAux
							
							cNatSld	:= Iif( nSld200 < 0, "N", "P")
							cSaldoR := IIf(nSaldoR >= 100 .Or. nSaldoR <= -1 , AllTrim(Str(nSaldoR)) ,  Padl(AllTrim(Str(nSaldoR)), nTamSx3 , "0"))
							cSaldoP := IIf(Abs(nSaldoP) >= 100 , AllTrim(Str(Abs(nSaldoP))) ,  Padl(AllTrim(Str(Abs(nSaldoP))), nTamSx3 , "0"))
							cSld200 := IIf(Abs(nSld200) >= 100 , AllTrim(Str(Abs(nSld200))) ,  Padl(AllTrim(Str(Abs(nSld200))), nTamSx3 , "0"))
							
							cLinAux	:= BLQ200 + Dv + TRB100->MES_ANO + Dv + cSaldoR + Dv + cSaldoP + Dv + ;
					 					cSld200 + Dv + cNatSld + ENTER
							nQtdLin++
						Else
							If ( TRB100->RECPAG == 'R' .Or. TRB100->E5_TIPO $ MV_CPNEG ) .And. TRB100->E5_TIPO # MV_CRNEG
							 	nSaldoR += Abs(nValor)
								nSld200	+= nValor
								If __lFunrural
									nSaldoP += ( __nVlFun * -1 )
									nSld200	+= ( __nVlFun * -1 )
								EndIf
							Else
								nSaldoP += ( nValor * -1 )
								nSld200	-= nValor
								If __lFunrural
									nSaldoP += ( __nVlFun * -1 )
									nSld200	+= ( __nVlFun * -1 )
								EndIf
							EndIf
						
							cNatSld	:= Iif( nSld200 < 0, "N", "P")
							cSaldoR := IIf(nSaldoR >= 100 .Or. nSaldoR <= -1 , AllTrim(Str(nSaldoR)) ,  Padl(AllTrim(Str(nSaldoR)), nTamSx3 , "0"))
							cSaldoP := IIf(Abs(nSaldoP) >= 100 , AllTrim(Str(Abs(nSaldoP))) ,  Padl(AllTrim(Str(Abs(nSaldoP))), nTamSx3 , "0"))
							cSld200 := IIf(Abs(nSld200) >= 100 , AllTrim(Str(Abs(nSld200))) ,  Padl(AllTrim(Str(Abs(nSld200))), nTamSx3 , "0"))
							
							cLinAux	:= BLQ200 + Dv + TRB100->MES_ANO + Dv + cSaldoR + Dv + cSaldoP + Dv + ;
					 					cSld200 + Dv + cNatSld + ENTER
						
					 	EndIf
					 	
					Else
						cOldMes := cMes
						If ( TRB100->RECPAG == 'R' .Or. TRB100->E5_TIPO $ MV_CPNEG ) .And. TRB100->E5_TIPO # MV_CRNEG
							nSaldoR := Abs(nValor)
							nSld200	+= nSaldoR
							If __lFunrural
								nSaldoP += ( __nVlFun * -1 )
								nSld200	+= ( __nVlFun * -1 )
							EndIf	
						Else
							nSaldoP := ( nValor * -1 )
							nSld200	+= nSaldoP
							If __lFunrural
								nSaldoP += ( __nVlFun * -1 )
								nSld200	+= ( __nVlFun * -1 )
							EndIf
						EndIf						
						
						cNatSld	:= Iif( nSld200 < 0, "N", "P")
						cSaldoR := IIf(nSaldoR >= 100 .Or. nSaldoR <= -1 , AllTrim(Str(nSaldoR)) ,  Padl(AllTrim(Str(nSaldoR)), nTamSx3 , "0"))
						cSaldoP := IIf(Abs(nSaldoP) >= 100 , AllTrim(Str(Abs(nSaldoP))) ,  Padl(AllTrim(Str(Abs(nSaldoP))), nTamSx3 , "0"))
						cSld200 := IIf(Abs(nSld200) >= 100 , AllTrim(Str(Abs(nSld200))) ,  Padl(AllTrim(Str(Abs(nSld200))), nTamSx3 , "0"))

						_nRecACC := 0
						_nPagACC := 0
						_nSldACC := 0

						//If !Empty(Iif( TRB100->TPDOC $ MVRECANT .Or. (TRB100->E5_MOTBX == 'CMP' .And. TRB100->RECPAG == 'R'),  cValor , "" ))
						If !Empty(Iif( TRB100->TPDOC $ MVRECANT .Or. (TRB100->E5_MOTBX $ 'CMP|CEC|REC' .And. TRB100->RECPAG == 'R').OR. (TRB100->RECPAG=="R".AND."IMPZGB" $ TRB100->ORI),  cValor , "" ))
							_nRecACC := Val(SubStr(cValor,1,Len(cValor)-2))
							_nRecACC += Val( SubStr(cValor, Len(cValor )-1, 2))/100
						Else
							_nPagACC := Val(SubStr(cValor,1,Len(cValor)-2))
							_nPagACC += Val( SubStr(cValor, Len(cValor )-1, 2))/100
						EndIf

						_aTempVal := {}
						_aTempVal := strtoarray(StrTran(_cLinACC,"||","|ABCDEFG|"),"|") //strtoarray(_cLinACC,"|")
						If Len(_aTempVal) > 0 
							If Val(_aTempVal[10])
								_nRecACC := Val(SubStr(cValor,1,Len(cValor)-2))
								_nRecACC += Val( SubStr(cValor, Len(cValor )-1, 2))/100
								_nPagACC := 0 
							ElseIf Val(_aTempVal[11]) > 0 
							_nPagACC := Val(SubStr(cValor,1,Len(cValor)-2))
							_nPagACC += Val( SubStr(cValor, Len(cValor )-1, 2))/100
							_nRecACC := 0
							EndIf
						EndIf

						_nSldACC := Val(SubStr(cSaldo,1,Len(cSaldo)-2))
						_nSldACC += Val( SubStr(cSaldo, Len(cSaldo )-1, 2))/100

						RecLock("TRB100",.F.)
							TRB100->NRECACC := _nRecACC
							TRB100->NPAGACC := _nPagACC
							TRB100->CNATSLD := cNatSld
							TRB100->NSLDACC := _nSldACC
							TRB100->CLINACC := _cLinACC
							TRB100->LCPRDSN := "S"
						MsUnLock()
					
						

						cLinAux	:= BLQ200 + Dv + TRB100->MES_ANO + Dv + cSaldoR + Dv + cSaldoP + Dv + ;
					 					cSld200 + Dv + cNatSld + ENTER
						//_cRastro += char(13)+char(10)+Space(10)+" LN1338 - Hr. inicio |"+Time()

					EndIf
					/* Desativado - André Claro 17/03/2023
						If !Empty(cLinha) //Ajuste gravação dos dados
							_aArrumaLN := zRetItXls(cLinha) //
							RecLock("TRB100",.F.)
								TRB100->NRECACC := _aArrumaLN[2]
								TRB100->NPAGACC := _aArrumaLN[1]
								TRB100->CNATSLD := _aArrumaLN[4]
								TRB100->NSLDACC := _aArrumaLN[3]
								TRB100->LCPRDSN := "S"

								//DESPESA, RECEITA, SALDO, TP SALDO
							MsUnLock()						
						EndIf
					*/
					TRB100->(DbSkip())
				Else
					TRB100->(DbSkip())
				EndIf
				//_cRastro += char(13)+char(10)+Space(10)+" - Hr. Final |"+Time() + CHAR(13)+CHAR(10)+ CHAR(13)+CHAR(10)
				//MemoWrite("C:\Temp\Log_LCPRD.TXT",_cRastro)
			EndDo

			/*
				André Claro
				25/10/2022
				Geração da planilha com o detalhamento.
				ANDRECCLARO_RELATORIO
			*/
			
// DESATIVADO POR QUE EST� COM A PRINTER.EXE DESATUALIZADA
    cFilename := _cFile+'.rel'
    ferase(cFilename)
    oPrtXlsx := FwPrinterXlsx():New(.T.)
    lRet := oPrtXlsx:Activate(cFilename)
    
    lRet := oPrtXlsx:AddSheet("LCPRD_MASUTTI")
    
    cFont := FwPrinterFont():Calibri()
    nSize := 14
    lItalic := .F.
    lBold := .T.
    lUnderlined := .F.
    lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)
    _nRow ++ //soma 1 linha para os títulos
	lRet := oPrtXlsx:SetText(_nRow, 1 , 'Dia')
	lRet := oPrtXlsx:SetText(_nRow, 2 , 'Mês/Ano')
	lRet := oPrtXlsx:SetText(_nRow, 3 , 'Data')
	lRet := oPrtXlsx:SetText(_nRow, 4 , 'Filial')
	lRet := oPrtXlsx:SetText(_nRow, 5 , 'Percentual')
	lRet := oPrtXlsx:SetText(_nRow, 6 , 'Banco')
	lRet := oPrtXlsx:SetText(_nRow, 7 , 'Prefixo')
	lRet := oPrtXlsx:SetText(_nRow, 8 , 'Num. Doc')
	lRet := oPrtXlsx:SetText(_nRow, 9 , 'Histórico')
	lRet := oPrtXlsx:SetText(_nRow, 10 , 'CNPJ/CPF Cliente')
	lRet := oPrtXlsx:SetText(_nRow, 11 , 'Pais Cliente')
	lRet := oPrtXlsx:SetText(_nRow, 12 , 'CNPJ/CPF Fornecedor')
	lRet := oPrtXlsx:SetText(_nRow, 13 , 'Pais Fornec.')
	lRet := oPrtXlsx:SetText(_nRow, 14 , 'Tp. Doc')
	lRet := oPrtXlsx:SetText(_nRow, 15 , 'E5_TIPO')
	lRet := oPrtXlsx:SetText(_nRow, 16 , 'Rec/Pag')
	lRet := oPrtXlsx:SetText(_nRow, 17 , 'E1_VLCRUZ')
	lRet := oPrtXlsx:SetText(_nRow, 18 , 'E2_VLCRUZ')
	lRet := oPrtXlsx:SetText(_nRow, 19 , 'Sld. Receber')
	lRet := oPrtXlsx:SetText(_nRow, 20 , 'Sld. Pagar')
	lRet := oPrtXlsx:SetText(_nRow, 21 , 'Mot. Baixa')
	lRet := oPrtXlsx:SetText(_nRow, 22 , 'REC')
	lRet := oPrtXlsx:SetText(_nRow, 23 , 'CLIFOR')
	lRet := oPrtXlsx:SetText(_nRow, 24 , 'Valor')
	lRet := oPrtXlsx:SetText(_nRow, 25 , 'Cgc')
	lRet := oPrtXlsx:SetText(_nRow, 26 , 'Vlmoed2')
	lRet := oPrtXlsx:SetText(_nRow, 27 , 'Moeda')
	lRet := oPrtXlsx:SetText(_nRow, 28 , 'Origem')
	lRet := oPrtXlsx:SetText(_nRow, 29 , 'Parcela')
	lRet := oPrtXlsx:SetText(_nRow, 30 , 'Loja')
	lRet := oPrtXlsx:SetText(_nRow, 31 , 'Cod. Empresa')
	lRet := oPrtXlsx:SetText(_nRow, 32 , 'Sefil')
	lRet := oPrtXlsx:SetText(_nRow, 33 , 'Recsf12')
	lRet := oPrtXlsx:SetText(_nRow, 34 , 'Vbrut12')
	lRet := oPrtXlsx:SetText(_nRow, 35 , 'Vsena12')
	lRet := oPrtXlsx:SetText(_nRow, 36 , 'Vinss12')
	lRet := oPrtXlsx:SetText(_nRow, 37 , 'Cosoc12')
	lRet := oPrtXlsx:SetText(_nRow, 38 , 'Nftotal')
	lRet := oPrtXlsx:SetText(_nRow, 39 , 'Funrural')
	lRet := oPrtXlsx:SetText(_nRow, 40 , 'Vlsenar')
	lRet := oPrtXlsx:SetText(_nRow, 41 , 'Valins')
	lRet := oPrtXlsx:SetText(_nRow, 42 , 'Vlfetfac')
	lRet := oPrtXlsx:SetText(_nRow, 43 , 'Gerou arquivo LCPRD?')
	lRet := oPrtXlsx:SetText(_nRow, 44 , 'Obs. ACC')
	lRet := oPrtXlsx:SetText(_nRow, 45 , 'Recno ACC')
	lRet := oPrtXlsx:SetText(_nRow, 46 , 'Receita Arquivo')
	lRet := oPrtXlsx:SetText(_nRow, 47 , 'Despesa Arquivo')
	lRet := oPrtXlsx:SetText(_nRow, 48 , 'Natureza Saldo')
	lRet := oPrtXlsx:SetText(_nRow, 49 , 'Saldo')
	lRet := oPrtXlsx:SetText(_nRow, 50 , 'Linha do arquivo')
	lRet := oPrtXlsx:SetText(_nRow, 51 , 'Natureza Financeira')

	cFont := FwPrinterFont():Calibri()
    nSize := 11
    lItalic := .F.
    lBold := .F.
    lUnderlined := .F.
    lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)


    TRB100->(DbGoTop())
    _nAtu := 0

	DbSelectArea("ZGL")
	ZGL->(DbSetOrder(1))
	_cZGLID := DtoS(Date())+SubStr(StrTran(Time(),":",""),1,4)+__cUserId
	_cFilZGL := xFilial("ZGL")
	_cNomeDec := GetAdvFVal("FVU","FVU_NOME",xFilial("FVU")+__cFVUCod,1,"")

	While TRB100->(!EOF())
		_nAtu ++
		If 	ZGL->(RecLock("ZGL",.T.))
				ZGL->ZGL_FILIAL := _cFilZGL
				ZGL->ZGL_ID := _cZGLID
				ZGL->ZGL_USERID := __cUserId
				ZGL->ZGL_DIA := TRB100->DIA
				ZGL->ZGL_MES := TRB100->MES_ANO
				ZGL->ZGL_DATA := Stod(TRB100->DDATA)
				ZGL->ZGL_FILCOD := TRB100->FILCOD
				ZGL->ZGL_PERC := TRB100->PERC
				ZGL->ZGL_BANCO := TRB100->BANCO
				ZGL->ZGL_PREF := TRB100->PREFIXO
				ZGL->ZGL_NDOC := TRB100->NUMDOC
				ZGL->ZGL_HIST := TRB100->HIST
				ZGL->ZGL_CGCCL := TRB100->CNPJCLI
				ZGL->ZGL_PAISCL := TRB100->PAISCLI
				ZGL->ZGL_CGCFO := TRB100->CNPJFOR
				ZGL->ZGL_PAISFO := TRB100->PAISFOR
				ZGL->ZGL_TPDOC := TRB100->TPDOC
				ZGL->ZGL_E5TIPO := TRB100->E5_TIPO
				ZGL->ZGL_RECPG := TRB100->RECPAG
				ZGL->ZGL_E1VLCR := TRB100->E1_VLCRUZ
				ZGL->ZGL_E2VLCR := TRB100->E2_VLCRUZ
				ZGL->ZGL_SLDREC := TRB100->SLDREC
				ZGL->ZGL_SLDPAG := TRB100->SLDPAG
				ZGL->ZGL_E5MOTB := TRB100->E5_MOTBX
				ZGL->ZGL_REC := TRB100->REC
				ZGL->ZGL_CLIFOR := TRB100->CLIFOR
				ZGL->ZGL_VALOR := TRB100->VALOR
				ZGL->ZGL_CGC := TRB100->CGC
				ZGL->ZGL_VLMOE2 := TRB100->VLMOED2
				ZGL->ZGL_MOEDA := TRB100->MOEDA
				ZGL->ZGL_ORI := TRB100->ORI
				ZGL->ZGL_PARC := TRB100->PARC
				ZGL->ZGL_LOJA := TRB100->LOJA
				ZGL->ZGL_CODEMP := TRB100->CODEMP
				ZGL->ZGL_SEFIL := TRB100->SEFIL
				ZGL->ZGL_RSF12 := TRB100->RECSF12
				ZGL->ZGL_VBRT12 := TRB100->VBRUT12
				ZGL->ZGL_VSEN12 := TRB100->VSENA12
				ZGL->ZGL_VINS12 := TRB100->VINSS12
				ZGL->ZGL_COSO12 := TRB100->COSOC12
				ZGL->ZGL_NFTOT := TRB100->NFTOTAL
				ZGL->ZGL_FUNRUR := TRB100->FUNRURAL
				ZGL->ZGL_VSENAR := TRB100->VLSENAR
				ZGL->ZGL_VALINS := TRB100->VALINS
				ZGL->ZGL_VFETFA := TRB100->VLFETFAC
				ZGL->ZGL_NATURE := TRB100->E5_NATUREZ
				ZGL->ZGL_LCPRSN := TRB100->LCPRDSN
				ZGL->ZGL_OBSACC := TRB100->OBSACC
				ZGL->ZGL_RECACC := TRB100->RECACC
				
				IF ALLTRIM(TRB100->RECPAG)=="R"
					ZGL->ZGL_NRCACC := TRB100->NRECACC + TRB100->NPAGACC
				ELSE
					ZGL->ZGL_NPGACC := TRB100->NRECACC + TRB100->NPAGACC
				ENDiF
				
				
				ZGL->ZGL_NATSLD := TRB100->CNATSLD
				ZGL->ZGL_SLDACC := TRB100->NSLDACC
				ZGL->ZGL_LINACC := TRB100->CLINACC
				ZGL->ZGL_DTEXEC := Date()
				ZGL->ZGL_DECLAR := __cFVUCod
				ZGL->ZGL_NOMEDE := _cNomeDec
				ZGL->ZGL_ITEM := STRZERO(_nAtu,5)
			ZGL->(MsUnlock())
		EndIf

		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 1, TRB100->DIA)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 2, TRB100->MES_ANO)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 3, DtoC(StoD(TRB100->DDATA)))
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 4, TRB100->FILCOD)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 5, TRB100->PERC)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 6, TRB100->BANCO)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 7, TRB100->PREFIXO)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 8, TRB100->NUMDOC)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 9, TRB100->HIST)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 10, TRB100->CNPJCLI)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 11, TRB100->PAISCLI)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 12, TRB100->CNPJFOR)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 13, TRB100->PAISFOR)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 14, TRB100->TPDOC)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 15, TRB100->E5_TIPO)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 16, TRB100->RECPAG)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 17, TRB100->E1_VLCRUZ)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 18, TRB100->E2_VLCRUZ)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 19, TRB100->SLDREC)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 20, TRB100->SLDPAG)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 21, TRB100->E5_MOTBX)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 22, TRB100->REC)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 23, TRB100->CLIFOR)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 24, TRB100->VALOR)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 25, TRB100->CGC)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 26, TRB100->VLMOED2)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 27, TRB100->MOEDA)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 28, TRB100->ORI)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 29, TRB100->PARC)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 30, TRB100->LOJA)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 31, TRB100->CODEMP)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 32, TRB100->SEFIL)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 33, TRB100->RECSF12)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 34, TRB100->VBRUT12)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 35, TRB100->VSENA12)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 36, TRB100->VINSS12)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 37, TRB100->COSOC12)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 38, TRB100->NFTOTAL)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 39, TRB100->FUNRURAL)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 40, TRB100->VLSENAR)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 41, TRB100->VALINS)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 42, TRB100->VLFETFAC)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 43, TRB100->LCPRDSN)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 44, TRB100->OBSACC)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 45, TRB100->RECACC)
		
		//lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 46, TRB100->NRECACC)
		//lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 47, TRB100->NPAGACC)

		IF ALLTRIM(TRB100->RECPAG)=="R"
			lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 46, TRB100->NRECACC + TRB100->NPAGACC)
			lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 47, 0)
		ELSE
			lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 46, 0)
			lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 47, TRB100->NRECACC + TRB100->NPAGACC)
		ENDiF


		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 48, TRB100->CNATSLD)
		lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 49, TRB100->NSLDACC)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 50, TRB100->CLINACC)
		lRet := oPrtXlsx:SetText(_nAtu+_nRow, 51, TRB100->E5_NATUREZ + " - " + AllTrim(GetAdvFVal("SED", 'ED_DESCRIC', xFilial("SED")+TRB100->E5_NATUREZ, 1, "" )))

	TRB100->(DbSkip())
	EndDo


	


    lRet := oPrtXlsx:toXlsx()
    oPrtXlsx:DeActivate()
	shellExecute("Open", "excel", _cFile, "C:\", 1 )


			If !Empty(cMes) .And. cMes == cOldMes
				cLin200	+= cLinAux
				nQtdLin++
			EndIf
			
			TRB100->(DbCloseArea())
			
			PrintLn(nHdl, cLinha)

			PrintLn(nHdl, cLin200)
				
			// Imprimir contador (Bl. 9999 - Encerramento)
			cLinha 		:= ""
							
			If Len(AllTrim(aContador[2])) > 0
				cFiliais	:= ""
				cFiliais	:= "%CVB_FILIAL = '" + aContador[1] + "' %"
					
				ArqTmp( '3',, aContador, cFiliais )
				
				If !(__cTmpCVB)->(Bof()) .And. !(__cTmpCVB)->(Eof())
								
					cLinha	:= BL9999 + Dv + AllTrim((__cTmpCVB)->CVB_NOME) + Dv + AllTrim(Iif(!Empty((__cTmpCVB)->CVB_CPF), (__cTmpCVB)->CVB_CPF, (__cTmpCVB)->CVB_CGC)) + Dv ;
							+ AllTrim((__cTmpCVB)->CVB_CRC) + Dv + SubStr( AllTrim((__cTmpCVB)->CVB_EMAIL), 1, 115 ) + Dv + SubStr( AllTrim((__cTmpCVB)->CVB_TEL), 1, 15 ) + Dv
				Else
					cLinha	:= BL9999 + Dv + Dv + Dv + Dv + Dv + Dv
				EndIf
				nQtdLin++
				
				(__cTmpCVB)->(DbCloseArea())
			Else
				cLinha	:= BL9999 + Dv + Dv + Dv + Dv + Dv + Dv
				nQtdLin++
			EndIf
			cLinha += AllTrim(Str(nQtdLin))
				
			PrintLn(nHdl, cLinha)
				
		EndIf
		
		If FClose(nHdl) .And. __lPrinted
			lRet	:= .T.
		EndIf
	Else
		Help(' ',1, STR0007,, STR0008 + ENTER + STR0009 + ENTER + STR0010 + ENTER + __cDir,2,0,,,,,,) // "Falha na geração do arquivo." ## "Verifique se o diretório existe " ## " ou se o arquivo já existe nesse diretório" ## " e / ou se esse usuário tem acesso de gravação no diretório: " 
	EndIf
	
Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} PrintLn

Imprime a linha no arquivo do Extrator do Livro Caixa
	Digital do Produtor Rural

@sample	LCDPR
@return		
@author		Rodrigo Oliveira
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function PrintLn(nHdl As Numeric, cLinha As Character)
	FWrite(nHdl, cLinha)
	__lPrinted	:= .T.
Return



Static Function zRetItXls(_cBuffer)

Local _aLin   := Separa(_cBuffer,"|")
Local _nLinha := 0
Local _nPosRec := 10 
Local _nPosDesp := 11 
Local _nPosSld := 12 
Local _nPosTpSld := 13 
Local _nValTemp := 0
Local _aRet := {}

	If !Empty(_cBuffer) .and. Len(_aLin) > 0 
		_aRet := {0,0,0,""} //DESPESA, RECEITA, SALDO, TP SALDO

/*
			_aTemp := {}
			aAdd(_aTemp, _aLin[_nPosReg]) 
			_dDate := Stod(SubStr(_aLin[_nPosDt ],5,4) +SubStr(_aLin[_nPosDt ],3,2) +SubStr(_aLin[_nPosDt ],1,2))
			aAdd(_aTemp, _dDate) 
			aAdd(_aTemp, _aLin[_nPosImov]) 
			aAdd(_aTemp, _aLin[_nPosBco ]) 
			aAdd(_aTemp, _aLin[_nPosDoc ]) 
			aAdd(_aTemp, _aLin[_nPosTpD ]) 
			aAdd(_aTemp, _aLin[_nPosHist]) 
			aAdd(_aTemp, _aLin[_nPosCGC]) 
			aAdd(_aTemp, _aLin[_nPosTpMov]) 
			_nValTemp := Val(SubStr(_aLin[_nPosRec ],1,Len(_aLin[_nPosRec ])-2))
			_nValTemp += Val( SubStr(_aLin[_nPosRec ], Len(_aLin[_nPosRec ])-1, 2))/100
			//aAdd(_aTemp, _nValTemp ) 
			_nValTemp := Val(SubStr(_aLin[_nPosDesp ],1,Len(_aLin[_nPosDesp ])-2))
			_nValTemp += Val( SubStr(_aLin[_nPosDesp ], Len(_aLin[_nPosDesp ])-1, 2))/100
			_aRet[1] := _nValTemp //DESPESA, RECEITA, SALDO, TP SALDO
			aAdd(_aTemp, _nValTemp ) 	
			_nValTemp := Val(SubStr(_aLin[_nPosSld ],1,Len(_aLin[_nPosSld ])-2))
			_nValTemp += Val( SubStr(_aLin[_nPosSld ], Len(_aLin[_nPosSld ])-1, 2))/100
			_aRet[3] := _nValTemp //DESPESA, RECEITA, SALDO, TP SALDO
			aAdd(_aTemp, _nValTemp )                         
			
			aAdd(_aTemp, _aLin[_nPosTpSld])
			_aRet[4] := _aLin[_nPosTpSld] //DESPESA, RECEITA, SALDO, TP SALDO
			aAdd(_aPlanilha, _aTemp )					
*/			
			_nValTemp := Val(SubStr(_aLin[_nPosRec ],1,Len(_aLin[_nPosRec ])-2))
			_nValTemp += Val( SubStr(_aLin[_nPosRec ], Len(_aLin[_nPosRec ])-1, 2))/100
			_aRet[2] := _nValTemp //DESPESA, RECEITA, SALDO, TP SALDO

			_nValTemp := Val(SubStr(_aLin[_nPosDesp ],1,Len(_aLin[_nPosDesp ])-2))
			_nValTemp += Val( SubStr(_aLin[_nPosDesp ], Len(_aLin[_nPosDesp ])-1, 2))/100
			_aRet[1] := _nValTemp //DESPESA, RECEITA, SALDO, TP SALDO

			_nValTemp := Val(SubStr(_aLin[_nPosSld ],1,Len(_aLin[_nPosSld ])-2))
			_nValTemp += Val( SubStr(_aLin[_nPosSld ], Len(_aLin[_nPosSld ])-1, 2))/100
			_aRet[3] := _nValTemp //DESPESA, RECEITA, SALDO, TP SALDO
			_aRet[4] := _aLin[_nPosTpSld] //DESPESA, RECEITA, SALDO, TP SALDO

		_nLinha ++
	EndIf

Return _aRet



//------------------------------------------------------------------------------
/*/	{Protheus.doc} ArqTmp

Consulta dados para a geração do arquivo LCDPR

@sample	LCDPR
@return		
@author		Rodrigo Oliveira
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function ArqTmp(cQry As Character, aSelFil As Array, aContador As Array, cFiliais As Character, aParamIni As Array, cDtPeriodo As Character)
	Local cCampos	As Character
	Local cQuery	As Character
	Local cQryAux	As Character
	Local cQryFix	As Character
	Local cCond		As Character
	Local cCondAux	As Character
	Local cNatPis	As Character
	Local cNatCof	As Character
	Local cNatCsl	As Character
	Local cNatSes	As Character
	Local cNatIss	As Character
	Local cNatIns	As Character
	Local cNatIrf	As Character
	Local cTamSEV 	As Character
	Local cTamSE5 	As Character
	Local cTamSED 	As Character
	Local cTamSA6 	As Character
	Local cTamSA1 	As Character
	Local cTamSA2 	As Character
	Local cTamSE1 	As Character
	Local cTamSE2	As Character
	Local cTamSF1 	As Character
	Local cTamSF2	As Character
	Local cSelUsr	As Character
	Local cHist		As Character
	Local cPercPE	As Character
	Local aAretPE	As Array
	Local aParPE	As Array
	Local nLOEmp	As Numeric
	Local nLOUnN	As Numeric
	Local nLOFil	As Numeric
	Local nPosFim	As Numeric
	Local nPosIni	As Numeric
	Local lE5Cgc	As Logical
	Local cTmpFil   as Character 
	Local cTmpBco	as Character
	Local aFldTRB	as Array
	Local nLoop		as Numeric
	Local cFields	as Character
	Local cReplace	as Character
	Local cCampoChq as Character
		
	Default aSelFil		:= {}
	Default aContador	:= {}
	Default aParamIni	:= {}
	
	cCampos		:= ""
	cQuery		:= ""
	cQryAux		:= ""
	cQryFix		:= ""
	cCond		:= ""
	cCondAux	:= ""
	cSelUsr		:= ""
	cHist		:= ""
	cPercPE		:= ""
	cTamSEV 	:= "0"
	cTamSE5 	:= "0"
	cTamSED 	:= "0"
	cTamSA6 	:= "0"
	cTamSA1 	:= "0"
	cTamSA2 	:= "0"
	cTamSE1 	:= "0"
	cTamSE2		:= "0"
	cTamSF1		:= "0"
	cTamSF2		:= "0"
	nLOEmp		:= 0
	nLOUnN		:= 0
	nLOFil		:= 0
	nPosFim		:= 0
	nPosIni		:= 0
	aAretPE		:= {}
	aParPE		:= {}
	cTmpFil		:= ""
	cTmpBco		:= ""
	cCampoChq 	:= Padr("", TamSX3("E5_NUMCHEQ")[1])

	Do Case
		Case cQry == '1'	 // Imóveis
			If !Empty(cFiliais)
				__cTmpFVV	:= GetNextAlias()
				cOrder		:= '%FVV_FILIAL, FVV_CODIGO, FVV_VERSAO%'
				BeginSql Alias __cTmpFVV
					Select FVV_FILIAL, FVV_PAIS, FVV_MOEDA, FVV_CAFIR, FVV_CAEPF CAEPF, FVV_INSCR IE, FVV_NOME, FVV_END, FVV_NUM, '0000' AS NUMIMO, FVV_VERSAO,
						FVV_COMPL, FVV_BAIRRO, FVV_UF AS UF, FVV_CODMUN, FVV_CEP, FVV_TIPOEX TIPO, FVV_PARTIC PERC, FVV_CODIGO, FVU_CNPJ, 'FVV' AS TAB, ' ' AS TPPES, FVV_VIGINI, FVV_VIGFIM
					 From %Table:FVV% FVV,
					 	%Table:FVU% FVU
					 where %Exp:cFiliais%
					 	And ( FVV_CODPES = FVU_CODIGO 
					 	And FVU_CNPJ = %Exp:__cCpf% )
					 	And FVV.%NotDel%
					 	And FVU.%NotDel%
					Union
					Select FVV_FILIAL, FVV_PAIS, FVV_MOEDA, FVV_CAFIR, FVG_CAEPF AS CAEPF, FVV_INSCR IE, FVV_NOME, FVV_END, FVV_NUM, '0000' AS NUMIMO, FVG_VERSAO,
						FVV_COMPL, FVV_BAIRRO, FVV_UF AS UF, FVV_CODMUN, FVV_CEP, FVG_TIPO TIPO, FVG_PERC PERC, FVV_CODIGO, FVU_CNPJ, 'FVGMN' AS TAB, FVG_TPPES AS TPPES, FVV_VIGINI, FVV_VIGFIM
					 From %Table:FVV% FVV,
					 	%Table:FVU% FVU,
					 	%Table:FVG% FVG
					 where %Exp:cFiliais%
					 	And FVG_NUMIMO = '000'
					 	And ( FVG_CODPES = FVU_CODIGO
					 	And FVG_CODIMO = FVV_CODIGO
					 	And FVU_CNPJ = %Exp:__cCpf% )
					 	And FVG_TPPES = '1'
						And FVV_VERSAO = FVG_VERSAO
					 	And FVV.%NotDel%
					 	And FVU.%NotDel%
					 	And FVG.%NotDel%
					 Order By %Exp:cOrder%
				EndSql
			EndIf
		Case cQry == '2'	// Terceiros
			If !Empty(cFiliais)			
				__cTmpFVG := GetNextAlias()
				
				cOrder	:= '%FVV_FILIAL%'
				BeginSql Alias __cTmpFVG
					Select FVV_FILIAL, FVV_TIPOEX TIPO, FVU_CNPJ, FVU_NOME, FVV_PARTIC PERC, 'FVV' AS TAB, ' ' AS TPPES, '000' AS NUMIMO, FVV_VIGINI, FVV_VIGFIM, FVV_VERSAO VER
					 From %Table:FVV% FVV,  
					 	%Table:FVU% FVU,
					 	%Table:FVG% FVG  
					 where  %Exp:cFiliais%
					 	And FVV_CODIGO = FVG_CODIMO
					    And FVU_CODIGO = FVV_CODPES 
					    And FVV.%NotDel%
					    And FVU.%NotDel%
					    And FVG.%NotDel%
					UNION
					Select FVV_FILIAL, FVG_TIPO TIPO, FVU_CNPJ, FVU_NOME, FVG_PERC PERC, 'FVG' AS TAB, FVG_TPPES AS TPPES, FVG_NUMIMO AS NUMIMO, FVV_VIGINI, FVV_VIGFIM, FVG_VERSAO VER
					 From %Table:FVG% FVG,
					 	%Table:FVV% FVV,
					 	%Table:FVU% FVU
					 where %Exp:cFiliais%
					  	And FVV_CODIGO = FVG_CODIMO
					  	And FVU_CODIGO = FVG_CODPES
						And FVV_VERSAO = FVG_VERSAO
					 	And FVG.%NotDel%
					 	And FVV.%NotDel%
					 	And FVU.%NotDel%
					 Order By %Exp:cOrder%
				EndSql
			EndIf
						
		Case cQry == '3'	// Dados do contabilista responsável pela declaração
			If !Empty(cFiliais)
				__cTmpCVB := GetNextAlias()
				
				BeginSql Alias __cTmpCVB
					Select CVB_NOME, CVB_CPF, CVB_CGC, CVB_CRC, CVB_EMAIL, CVB_TEL
					 From %Table:CVB% CVB
					 where %Exp:cFiliais%
					  	And CVB_CODCTB = %Exp:aContador[2]%
					 	And CVB.%NotDel%
				EndSql
			EndIf
		OtherWise

			cTmpFil := __oTmpFil:GetRealName()
			cTmpBco := __oTmpBco:GetRealName()
			lE5Cgc	:= SE5->(ColumnPos('E5_CGC') ) > 0

			nLOEmp	:= Len(FWSM0LayOut(,1))
			nLOUnN	:= Len(FWSM0LayOut(,2))
			nLOFil	:= Len(FWSM0LayOut(,3))

			cTamSEV := ModeAccess( "SEV", nLOEmp, nLOUnN, nLOFil )
			cTamSE5 := ModeAccess( "SE5", nLOEmp, nLOUnN, nLOFil )
			cTamSED := ModeAccess( "SED", nLOEmp, nLOUnN, nLOFil )
			cTamSA6 := ModeAccess( "SA6", nLOEmp, nLOUnN, nLOFil )
			cTamSA1 := ModeAccess( "SA1", nLOEmp, nLOUnN, nLOFil )
			cTamSA2 := ModeAccess( "SA2", nLOEmp, nLOUnN, nLOFil )
			cTamSE1 := ModeAccess( "SE1", nLOEmp, nLOUnN, nLOFil )
			cTamSE2 := ModeAccess( "SE2", nLOEmp, nLOUnN, nLOFil )
			cTamSF1 := ModeAccess( "SF1", nLOEmp, nLOUnN, nLOFil )
			cTamSF2 := ModeAccess( "SF2", nLOEmp, nLOUnN, nLOFil )

			If __nFilSE5 == Nil
				__nFilSE5	:= Val(cTamSE5)
			EndIf
			If __nFilSE1 == Nil
				__nFilSE1	:= Val(cTamSE1)
			EndIf
			If __nFilSE2 == Nil
				__nFilSE2	:= Val(cTamSE2)
			EndIf
			If __nFilSF1 == Nil
				__nFilSF1	:= Val(cTamSF1)
			EndIf
			If __nFilSF2 == Nil
				__nFilSF2	:= Val(cTamSF2)
			EndIf

			If __cTamSE5 == Nil
				__cTamSE5	:= cTamSE5
			EndIf
			If __cTamSEF == Nil
				__cTamSEF	:= ModeAccess( "SEF", __nLOEmp, __nLOUnN, __nLOFil )
			EndIf
	

			cNatPis	:= SuperGetMV("MV_PISNAT",,"PIS")
			cNatSes	:= SuperGetMV("MV_SEST",,"SEST")
			cNatIss	:= SuperGetMV("MV_APURISS",,"ISS")
			cNatCof	:= SuperGetMV("MV_COFINS",,"COFINS")
			cNatCsl	:= SuperGetMV("MV_CSLL",,"CSLL")
			cNatIns	:= StrTran(SuperGetMV("MV_INSS",,"INSS"), '"', "")
			cNatIrf	:= StrTran(SuperGetMV("MV_IRF",,"IRF"), '"', "")
			
			aAdd(aParPE, {__cCpf, aParamIni, cDtPeriodo, __oTmpBco, __oTmpFil, cTamSEV, cTamSE5, cTamSED, cTamSA6, ;
			 cTamSA1, cTamSA2, cTamSE1, cTamSE2, cNatPis, cNatSes, cNatIss, cNatCof, cNatCsl, cNatIns, cNatIrf, lE5Cgc} )

			aFldTRB := {}
			AADD(aFldTRB,{"DIA","C",2,0})
			AADD(aFldTRB,{"MES_ANO","C",6,0})
			AADD(aFldTRB,{"DDATA","C",8,0})
			AADD(aFldTRB,{"FILCOD","C",3,0})
			AADD(aFldTRB,{"PERC","N",TAMSX3("FVV_PARTIC")[1],TAMSX3("FVV_PARTIC")[2]})
			AADD(aFldTRB,{"BANCO","C",3,0})
			AADD(aFldTRB,{"PREFIXO","C",TAMSX3("E1_PREFIXO")[1],0})
			AADD(aFldTRB,{"NUMDOC","C",TAMSX3("E5_NUMERO")[1],0})
			AADD(aFldTRB,{"HIST","C",255,0})
			AADD(aFldTRB,{"CNPJCLI","C",TAMSX3("A1_CGC")[1],0})
			AADD(aFldTRB,{"PAISCLI","C",TAMSX3("A1_PAIS")[1],0})
			AADD(aFldTRB,{"CNPJFOR","C",TAMSX3("A2_CGC")[1],0})
			AADD(aFldTRB,{"PAISFOR","C",TAMSX3("A2_PAIS")[1],0})
			AADD(aFldTRB,{"TPDOC","C",TAMSX3("E5_TIPODOC")[1],0})
			AADD(aFldTRB,{"E5_TIPO","C",TAMSX3("E5_TIPO")[1],0})
			AADD(aFldTRB,{"RECPAG","C",1,0})
			AADD(aFldTRB,{"E1_VLCRUZ","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"E2_VLCRUZ","N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]})
			AADD(aFldTRB,{"SLDREC","N",TAMSX3("E2_SALDO")[1],TAMSX3("E2_SALDO")[2]})
			AADD(aFldTRB,{"SLDPAG","N",TAMSX3("E2_SALDO")[1],TAMSX3("E2_SALDO")[2]})
			AADD(aFldTRB,{"E5_MOTBX","C",TAMSX3("E5_MOTBX")[1],0})
			AADD(aFldTRB,{"REC","N",10,0})
			AADD(aFldTRB,{"CLIFOR","C",TAMSX3("E5_CLIFOR")[1],0})
			AADD(aFldTRB,{"VALOR","N",TAMSX3("E5_VALOR")[1],TAMSX3("E5_VALOR")[2]})
			AADD(aFldTRB,{"CGC","C",TAMSX3("E5_CGC")[1],0})
			AADD(aFldTRB,{"VLMOED2","N",TAMSX3("E5_VLMOED2")[1],TAMSX3("E5_VLMOED2")[2]})
			AADD(aFldTRB,{"MOEDA","C",TAMSX3("E5_MOEDA")[1],0})
			AADD(aFldTRB,{"ORI","C",TAMSX3("E5_ORIGEM")[1],0})
			AADD(aFldTRB,{"PARC","C",TAMSX3("E5_PARCELA")[1],0})
			AADD(aFldTRB,{"LOJA","C",TAMSX3("E5_LOJA")[1],0})
			AADD(aFldTRB,{"CODEMP","C",1,0})
			AADD(aFldTRB,{"SEFIL","C",TAMSX3("E5_FILIAL")[1],0})
			AADD(aFldTRB,{"RECSF12","N",10,0})
			AADD(aFldTRB,{"VBRUT12","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"VSENA12","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"VINSS12","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"COSOC12","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"NFTOTAL","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"FUNRURAL","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"VLSENAR","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"VALINS","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"VLFETFAC","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"E5_NATUREZ","C",12,0})
			AADD(aFldTRB,{"LCPRDSN","C",1,0})
			AADD(aFldTRB,{"OBSACC","C",254,0})
			AADD(aFldTRB,{"RECACC","N",10,0})
			
			AADD(aFldTRB,{"NRECACC","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"NPAGACC","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"CNATSLD","C",1,0})
			AADD(aFldTRB,{"NSLDACC","N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
			AADD(aFldTRB,{"CLINACC","C",254,0})
			
			_aFieldRel := aClone(aFldTRB)
			oTRB100 := FWTemporaryTable():New( "TRB100" )
			oTRB100:SetFields(aFldTRB) 
			oTRB100:AddIndex("1", {"DDATA"},{"FILCOD"}, {"BANCO"}, {"NUMDOC"},{"PREFIXO"},{"PARC"},{"E5_TIPO"},{"TPDOC"})
			
			oTRB100:Create()

			cFields := ""
			
			//Pega todos os campos para efetuar a cópia dos dados
			For nLoop := 1 to Len(aFldTRB)
				cFields += aFldTRB[nLoop][1] + ","//Nome do campo
			Next

			cFields := Left(cFields, Len(cFields) -1) //Remover a ultima vírgula

			If cDtPeriodo == '1'
				cCampos	:= "SUBSTRING(E5_DATA,7,2) DIA, SUBSTRING(E5_DATA, 5, 2) || SUBSTRING(E5_DATA, 1, 4) MES_ANO, E5_DATA DDATA, "
			Else
				cCampos	:= "SUBSTRING(E5_DTDISPO,7,2) DIA, SUBSTRING(E5_DTDISPO, 5, 2) || SUBSTRING(E5_DTDISPO, 1, 4) MES_ANO, E5_DTDISPO DDATA, "
			EndIf
			cCampos	+= " TRFIL.COD FILCOD, ISNULL(FVV.FVV_PARTIC, FVG.FVG_PERC) AS PERC, ISNULL(TRBCO.COD,'') BANCO, E5_PREFIXO PREFIXO, E5_NUMERO NUMDOC, E5_HISTOR HIST, "
			cCampos	+= " ISNULL(SA1.A1_CGC,'') CNPJCLI, ISNULL(SA1.A1_PAIS,'') PAISCLI, ISNULL(SA2.A2_CGC,' ') CNPJFOR, ISNULL(SA2.A2_PAIS,' ') PAISFOR, E5_TIPODOC TPDOC, E5_TIPO, CASE WHEN (E5_TIPODOC = 'DC' AND E5_RECPAG = 'R')  THEN 'P' WHEN (E5_TIPODOC = 'DC' AND E5_RECPAG = 'P')  THEN 'R' ELSE E5_RECPAG END RECPAG, "
			cCampos	+= " ISNULL(E1_VLCRUZ,0) E1_VLCRUZ, ISNULL(E2_VLCRUZ,0) E2_VLCRUZ, ISNULL(E1_SALDO,0) SLDREC, ISNULL(E2_SALDO,0) SLDPAG, E5_MOTBX, SE5.R_E_C_N_O_ REC, E5_CLIFOR CLIFOR, "
			If SuperGetMV("MV_MULNATR",,".F.") .Or. SuperGetMV("MV_MULNATP",,".F.")
				//ANDRECCLARO JUROS
				//cCampos	+= " ( ( E5_VALOR + E5_VRETPIS + E5_VRETCOF + E5_VRETCSL + ( CASE WHEN E5_PRETIRF != '1' THEN E5_VRETIRF ELSE 0 END ) + E5_VRETISS + E5_VRETINS + E5_VLDESCO - E5_VLJUROS - E5_VLMULTA ) * ( Select ISNULL( Sum(EV_PERC), 1 ) From " + RetSqlName("SEV") + " SEV "
				cCampos	+= " ( ( E5_VALOR + E5_VRETPIS + E5_VRETCOF + E5_VRETCSL + ( CASE WHEN E5_PRETIRF != '1' THEN E5_VRETIRF ELSE 0 END ) + E5_VRETISS + E5_VRETINS ) * ( Select ISNULL( Sum(EV_PERC), 1 ) From " + RetSqlName("SEV") + " SEV "
				cCampos	+= " Inner Join " + RetSqlName ("SED") + " SED "
				If cTamSEV == cTamSED
					cCampos	+= " ON EV_FILIAL = ED_FILIAL "
				ElseIf Val(cTamSED) == 0
					cCampos	+= " ON ED_FILIAL = ' ' "
				ElseIf Val(cTamSEV) > Val(cTamSED)
					cCampos	+= " ON SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(EV_FILIAL,1, " + cTamSED + ") "
				Else
					cCampos	+= " ON SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(E5_FILORIG,1, " + cTamSED + ") "
				EndIf
				cCampos	+= " AND EV_NATUREZ = ED_CODIGO AND ED_LCDPR = '1' AND SED.D_E_L_E_T_ = '' " 
				cCampos	+= " WHERE " + CompTab("SEV", "EV_FILIAL", , cTamSEV ) + " AND EV_PREFIXO = E5_PREFIXO AND EV_NUM = E5_NUMERO AND EV_PARCELA = E5_PARCELA "
				cCampos	+= " AND EV_CLIFOR = E5_CLIFOR AND EV_LOJA = E5_LOJA AND EV_TIPO = E5_TIPO AND EV_RECPAG = E5_RECPAG "
				cCampos	+= " AND ( ( EV_IDENT = '2' AND EV_SEQ = E5_SEQ ) OR ( EV_IDENT = '1' AND E5_MOTBX IN ( 'CMP', 'CEC' )) ) "
				cCampos	+= " AND EV_SITUACA = ' ' AND SEV.D_E_L_E_T_ = ' ' ) ) AS VALOR "
			Else
				//ANDRECCLARO JUROS
				cCampos	+= " ( E5_VALOR + ( E5_VRETPIS + E5_VRETCOF + E5_VRETCSL + ( CASE WHEN E5_PRETIRF != '1' THEN E5_VRETIRF ELSE 0 END ) + E5_VRETISS + E5_VRETINS  ) ) AS VALOR "
				//cCampos	+= " ( E5_VALOR + ( E5_VRETPIS + E5_VRETCOF + E5_VRETCSL + ( CASE WHEN E5_PRETIRF != '1' THEN E5_VRETIRF ELSE 0 END ) + E5_VRETISS + E5_VRETINS + E5_VLDESCO - E5_VLJUROS - E5_VLMULTA ) ) AS VALOR "
			EndIf
			If lE5Cgc
				cCampos	+= " , E5_CGC CGC"
			EndIf

			cCampos	+= " , E5_VLMOED2 VLMOED2, E5_MOEDA MOEDA, E5_ORIGEM ORI , E5_PARCELA PARC , E5_LOJA LOJA, '' CODEMP, E5_FILIAL SEFIL "
			cCampos	+= " , ISNULL(CASE "
			cCampos	+= " WHEN E1_VLCRUZ > 0"
			cCampos	+= " THEN SF2IMP.R_E_C_N_O_"
			cCampos	+= " ELSE SF1IMP.R_E_C_N_O_     "
			cCampos	+= " END,0)									  RECSF12 "
			cCampos	+= " , ISNULL(CASE "
			cCampos	+= " WHEN E1_VLCRUZ > 0"
			cCampos	+= " THEN SF2IMP.F2_VALBRUT"
			cCampos	+= " ELSE SF1IMP.F1_VALBRUT     "
			cCampos	+= " END,0)                                   VBRUT12 "
			cCampos	+= " , ISNULL(CASE "
			cCampos	+= " WHEN E1_VLCRUZ > 0"
			cCampos	+= " THEN SF2IMP.F2_VLSENAR"
			cCampos	+= " ELSE SF1IMP.F1_VLSENAR     "
			cCampos	+= " END,0)                                     VSENA12 "
			cCampos	+= " , ISNULL(CASE "
			cCampos	+= " WHEN E1_VLCRUZ > 0 "
			cCampos	+= " THEN SF2IMP.F2_VALINSS"
			cCampos	+= " ELSE SF1IMP.F1_INSS     "
			cCampos	+= " END,0)                                    VINSS12 "
			cCampos	+= " , ISNULL(CASE "
			cCampos	+= " WHEN E1_VLCRUZ > 0"
			cCampos	+= " THEN SF2IMP.F2_CONTSOC"
			cCampos	+= " ELSE SF1IMP.F1_CONTSOC     "
			cCampos	+= " END,0)                                     COSOC12 " 
			cCampos	+= " , NULL NFTOTAL "
			cCampos	+= " , NULL FUNRURAL "
			cCampos	+= " , NULL VLSENAR "
			cCampos	+= " , NULL VALINS "
			cCampos += " , NULL VLFETFAC "
			
			If cDtPeriodo == '1'
				cCond	:= " E5_DATA BETWEEN '" + DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' "
			Else
				cCond	:= " ( E5_DTDISPO BETWEEN '" + DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "') "
			EndIf
			cCond	+= " AND E5_DTCANBX = ' ' AND E5_MOVCX <> 'S' AND E5_SITUACA != 'C' "
			If SuperGetMV("MV_ZLCDPA",.F. , .T.) //Se ativo considera s� o PA
				cCond	+= " AND ( E5_TIPODOC NOT IN " + FormatIn(MVRECANT +  "|ES","|") + " )  "

				cCond	+= " AND  NOT(       ( E5_MOTBX = 'CMP' AND E5_RECPAG = 'P' AND E5_TIPODOC <> 'ES'  )  "   
				cCond	+= " 	 	  OR ( E5_MOTBX = 'CMP' AND E5_RECPAG = 'R' AND E5_TIPODOC = 'ES'  )  "   
				cCond	+= "      )   AND  "   

			Else
				cCond	+= " AND ( E5_TIPODOC NOT IN " + FormatIn(MVRECANT + "|" + MVPAGANT + "|ES","|") + " ) AND "
			EndIf

			cCond	+= " ((E5_TIPODOC = 'CD' AND E5_VENCTO <= E5_DATA) OR "
			cCond	+= " (E5_TIPODOC != 'CD')) "
			cCond	+= " AND E5_HISTOR NOT LIKE '%" + STR0020 + "%'" // "Baixa Automatica / Lote"
			cCond	+= " AND SE5.E5_HISTOR NOT LIKE '%Baixa de Titulos p/Lote%'  "
			cCond	+= " AND E5_TIPODOC NOT IN ('DC','D2','JR','J2','CH','TL','MT','M2','VM','CM','C2','ES','VA','E2','TE','TR','CB' )"
			If cDtPeriodo == '1'
				cCond	+= " AND ( E5_TIPODOC != 'CH' OR  ( ( E5_TIPODOC = 'CH' AND E5_ORIGEM LIKE 'GPE%') OR ( E5_TIPODOC = 'CH' AND E5_ORIGEM LIKE 'APT%' ) ) ) "
			EndIf
			cCond	+= " AND SE5.R_E_C_N_O_ NOT IN ( SELECT SE5AINC.R_E_C_N_O_ "
			cCond	+= " FROM " + RetSqlName('SE5') + " SE5AINC "
			cCond	+= " WHERE SE5AINC.E5_TIPODOC = 'BA ' AND ( SE5AINC.E5_TIPO IN " + FormatIn(MVRECANT + "|" + MVPAGANT, "|") + " "
			cCond	+= " AND SE5AINC.E5_MOTBX != 'CEC' ) "
			cCond	+= " AND SE5AINC.E5_DOCUMEN = ' ' AND SE5AINC.D_E_L_E_T_ = ' ' ) "
			cCond	+= " AND E5_MOTBX NOT IN ('LIQ', 'DSD', 'DAC' ) "
			cCond	+= " AND E5_TIPO NOT IN " + FormatIn(MV_CRNEG + "|" + MV_CPNEG, "|") + " "
			cCond	+= " AND E5_SITUACA NOT IN ('C','E','X') AND NOT EXISTS ( "
			cCond	+= "	SELECT SE5ES.E5_NUMERO " 
			cCond	+= "  		FROM "+ RetSqlName("SE5") + " SE5ES " 
			cCond	+= "     		WHERE SE5ES.E5_FILIAL  = SE5.E5_FILIAL "  
			cCond	+= "      			AND SE5ES.E5_PREFIXO = SE5.E5_PREFIXO "
			cCond	+= "     			AND SE5ES.E5_NUMERO  = SE5.E5_NUMERO " 
			cCond	+= "     			AND SE5ES.E5_NUMCHEQ = ' ' "
			cCond	+= "         		AND SE5ES.E5_PARCELA = SE5.E5_PARCELA " 
			cCond	+= "        		AND SE5ES.E5_TIPO    = SE5.E5_TIPO " 
			cCond	+= "     			AND SE5ES.E5_CLIFOR  = SE5.E5_CLIFOR " 
			cCond	+= "          		AND SE5ES.E5_LOJA    = SE5.E5_LOJA " 
			cCond	+= "     			AND SE5ES.E5_SEQ     = SE5.E5_SEQ " 
			cCond	+= "        		AND SE5ES.E5_BANCO   = SE5.E5_BANCO "
			cCond	+= "           		AND SE5ES.E5_AGENCIA = SE5.E5_AGENCIA "
			cCond	+= "        		AND SE5ES.E5_CONTA   = SE5.E5_CONTA "
			cCond	+= "         		AND SE5ES.E5_TIPODOC = 'ES' "
			cCond	+= "           		AND SE5ES.E5_ORIGEM <> 'FINA100 ' AND SE5ES.E5_KEY NOT LIKE '%PA%' "
			cCond	+= "           		AND SE5ES.D_E_L_E_T_ = ' ' ) "
			cCond	+= " AND SE5.D_E_L_E_T_ = ' ' "
			cCond	+= " AND (SE5.E5_ORDREC = ' ' OR (SE5.E5_ORDREC <> ' ' AND SE5.E5_MOTBX <> ' ' )) "
			MemoWrite("C:\Temp\F820COND.sql", cCond)
			cQryAux	:= " SELECT "
			If __lF820Qry
				aAretPE	:= ExecBlock( "F820Qry",.F., .F., {cCond, cCampos, aParPE})
				If ValType(aAretPE[2]) == 'C'
					cHist 	:= aAretPE[2]
				EndIf
				If ValType(aAretPE[3]) == 'C'
					cSelUsr	:= aAretPE[3]
				EndIf
				If !Empty(AllTrim(cSelUsr))
					nPosFim	:= Rat(" PERC", cSelUsr)
					nPosIni	:= Rat(",", SubStr(cSelUsr, 1, nPosFim) )
					cPercPE := AllTrim(SubStr(cSelUsr, nPosIni, nPosFim - nPosIni))
					If Right(cPercPE, 2) == "AS"
						cPercPE	:= AllTrim(SubStr(cPercPE, 2, Len(cPercPE) - 3))
					EndIf
					If !Empty(cHist)
						cQryAux 	+= StrTran( cSelUsr, "E5_HISTOR", "ISNULL(Substring("+cHist+",1,255),' ')")						 
						__lImpHist	:= .T.
					Else
						cQryAux += cSelUsr
					EndIf
				Else
					If !Empty(cHist)
						cQryAux 	+= StrTran( cCampos, "E5_HISTOR", cHist)
						__lImpHist	:= .T.
					Else
						cQryAux += cCampos
					EndIf
				EndIf
			Else
				cQryAux += cCampos+", E5_NATUREZ "
			EndIf
			cQryFix	:= " FROM " //+ RetSqlName("SE5") + " SE5 "
			//Tratamento para considerar o valor principal tamb�m quando gerado direto pela SE5 / ANDRE CLARO EM 23/06/2026
			_nPercXRT := SuperGetMV("MV_ZPERXRT",.F., 0.1 )
			cQryFix	+= " (SELECT 	E5_FILIAL, E5_DATA, E5_TIPO, " 
			
			cQryFix	+= " (CASE WHEN (E5_VLCORRE <> 0 AND E5_DOCUMEN LIKE 'XRT%' AND E5_HISTOR LIKE 'PRI%' ) THEN '01' ELSE E5_MOEDA END) AS E5_MOEDA,

			cQryFix	+= " (CASE 	WHEN (E5_VLCORRE <> 0 AND E5_DOCUMEN LIKE 'XRT%' AND E5_HISTOR LIKE 'PRI%' ) THEN E5_VLCORRE * "+cValToChar(_nPercXRT)+" ELSE E5_VALOR END) AS E5_VALOR,   "
			cQryFix += " E5_NATUREZ, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_NUMCHEQ, E5_DOCUMEN, E5_VENCTO, E5_RECPAG, 
			cQryFix	+= " 			E5_BENEF, E5_HISTOR, E5_TIPODOC, 
			cQryFix	+= " (CASE WHEN (E5_VLCORRE <> 0 AND E5_DOCUMEN LIKE 'XRT%' AND E5_HISTOR LIKE 'PRI%' ) THEN 0 ELSE E5_VLMOED2 END) AS E5_VLMOED2,
			cQryFix	+= " 			E5_LA, E5_SITUACA, E5_LOTE, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_CLIFOR, E5_LOJA, E5_DTDIGIT, 
			cQryFix	+= " 			E5_TIPOLAN, E5_DEBITO, E5_CREDITO, E5_MOTBX, E5_RATEIO, E5_RECONC, E5_SEQ, E5_DTDISPO, E5_CCD, E5_CCC, E5_OK, E5_ARQRAT, E5_IDENTEE, 
			cQryFix	+= " 			E5_ORDREC, E5_FILORIG, E5_ARQCNAB, E5_VLJUROS, E5_VLMULTA, 
			//cQryFix	+= " (CASE WHEN (E5_VLCORRE <> 0 AND E5_DOCUMEN LIKE 'XRT%' AND E5_HISTOR LIKE 'PRI%' ) THEN 0 ELSE E5_VLCORRE END) AS E5_VLCORRE,	
			cQryFix += "   E5_VLCORRE,    "		
			cQryFix	+= " 			E5_VLDESCO, E5_CNABOC, E5_SITUA, E5_ITEMD, E5_ITEMC, E5_CLVLDB, 
			cQryFix	+= " 			E5_CLVLCR, E5_PROJPMS, E5_EDTPMS, E5_TASKPMS, E5_MODSPB, E5_FATURA, E5_TXMOEDA, E5_FATPREF, E5_CODORCA, E5_SITCOB, E5_FORNADT, E5_LOJAADT, 
			cQryFix	+= " 			E5_CLIENTE, E5_FORNECE, E5_SERREC, E5_OPERAD, E5_MOVCX, E5_KEY, E5_MULTNAT, E5_AGLIMP, E5_VLACRES, E5_VLDECRE, E5_VRETPIS, E5_VRETCOF, 
			cQryFix	+= " 			E5_VRETCSL, E5_PRETPIS, E5_PRETCOF, E5_PRETCSL, E5_AUTBCO, E5_PRETIRF, E5_VRETIRF, E5_VRETISS, E5_NUMMOV, E5_PROCTRA, E5_IDMOVI, E5_BASEIRF, 
			cQryFix	+= " 			E5_ORIGEM, E5_DTCANBX, E5_DIACTB, E5_NODIA, E5_FLDMED, E5_TPDESC, E5_PRINSS, E5_VRETINS, E5_PRETINS, E5_CCUSTO, E5_FORMAPG, E5_SDOCREC, 
			cQryFix	+= " 			E5_MOVFKS, E5_IDORIG, E5_TABORI, E5_SEQCON, E5_PRISS, E5_CGC, SE5.D_E_L_E_T_, SE5.R_E_C_N_O_, SE5.R_E_C_D_E_L_, E5_USERLGI, E5_USERLGA, E5_XCLVL, 
			cQryFix	+= " 			E5_MSIDENT, E5_MSFIL, E5_MSEMP, E5_XCODSAF, E5_XCONJU, E5_XLEGEND, E5_XVLM1
			cQryFix	+= " FROM		"+RetSqlName("SE5")+" SE5 LEFT OUTER JOIN "+RetSqlName("ZGX")+" ZGX  ON
			cQryFix	+= " 			SE5.E5_FILIAL = ZGX.ZGX_FILIAL
			cQryFix	+= " 		AND SE5.E5_PREFIXO = ZGX.ZGX_PREFIX
			cQryFix	+= " 		AND SE5.E5_NUMERO = ZGX.ZGX_NUMERO
			cQryFix	+= " 		AND SE5.E5_PARCELA = ZGX.ZGX_PARCEL
			cQryFix	+= " 		AND SE5.E5_TIPO = ZGX.ZGX_TIPO
			cQryFix	+= " 		AND SE5.E5_CLIFOR = ZGX.ZGX_CLIFOR
			cQryFix	+= " 		AND SE5.E5_LOJA = ZGX.ZGX_LOJA
			cQryFix	+= " 		AND SE5.E5_SEQ = ZGX.ZGX_SEQ
			cQryFix	+= " 		AND SE5.E5_MOTBX = ZGX.ZGX_MOTBX
			cQryFix	+= " 		AND SE5.E5_DATA = ZGX.ZGX_DATA
			cQryFix	+= " 		AND ZGX.D_E_L_E_T_ = ''


			cQryFix	+= " WHERE		SE5.D_E_L_E_T_ = ''  AND ISNULL(ZGX.ZGX_FILIAL,'EXCLUI') = 'EXCLUI'    "
			
			If SuperGetMv("MV_ZXRTLCP",.F.,.T.) //Considera planilha  do XRT? .T. = SIM, .F. = NÃO
				cQryFix	+= " 		AND SE5.E5_DOCUMEN NOT LIKE 'XRT:%' "
			Else
				cQryFix	+= " 		AND SE5.E5_NATUREZ NOT IN ('410203')
			EndIf

			//cQryFix	+= " 		AND SE5.E5_NATUREZ NOT IN ('220305','410201','410202','410204','410205','410206','410207')
			cQryFix	+= " 		AND NOT( ( SE5.E5_TIPO IN ('NCC','NDF') OR SE5.E5_DOCUMEN LIKE '%NCC%' OR SE5.E5_DOCUMEN LIKE '%NDF%' ) AND SE5.E5_MOTBX = 'CMP'   ) "
			
			If Alltrim(__cCpf) <> "63083167172"
				cQryFix	+= " 		AND NOT(SE5.R_E_C_N_O_ IN (545327,545328,545132,545548,545549,545544,545550,545551,545545,545552,545553,545546,545554,545555,545547,545538,545539,545535,545541,545542,545540,572715,587715,588760,588956,590053,590054,590044,589669,590052,590043,589675,590051,590055,590042,589663,590050,590056,590047,626513,626512,626470,626468,626518,630407,630406,630409,630410,664775,664777,664773,664776))
			EndIf
			cQryFix	+= " UNION ALL

			cQryFix	+= " SELECT	E5_FILIAL, E5_DATA, E5_TIPO, E5_MOEDA, E5_VALOR, E5_NATUREZ, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_NUMCHEQ, E5_DOCUMEN, E5_VENCTO, E5_RECPAG, 
			cQryFix	+= " 		E5_BENEF, E5_HISTOR, E5_TIPODOC, E5_VLMOED2, '' AS E5_LA, '' AS  E5_SITUACA, '' AS E5_LOTE, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_CLIFOR, 
			cQryFix	+= " 		E5_LOJA, E5_DTDIGIT, '' AS E5_TIPOLAN, '' AS E5_DEBITO, '' AS E5_CREDITO, E5_MOTBX, '' AS E5_RATEIO, E5_RECONC, '' AS E5_SEQ, 
			cQryFix	+= " 		E5_DTDISPO, '' AS E5_CCD, '' AS E5_CCC, '' AS E5_OK, '' AS E5_ARQRAT, '' AS E5_IDENTEE, '' AS E5_ORDREC, 
			cQryFix	+= " 		E5_FILORIG, 
			cQryFix	+= " 		'' AS E5_ARQCNAB, 0 AS E5_VLJUROS, 0 E5_VLMULTA, E5_VLCORRE, 0 E5_VLDESCO, '' E5_CNABOC, '' E5_SITUA, '' E5_ITEMD, '' E5_ITEMC, '' E5_CLVLDB, 
			cQryFix	+= " 		'' E5_CLVLCR, '' E5_PROJPMS, '' E5_EDTPMS, '' E5_TASKPMS, '' E5_MODSPB, '' E5_FATURA, E5_TXMOEDA, '' E5_FATPREF,'' E5_CODORCA,'' E5_SITCOB, 
			cQryFix	+= " 		''E5_FORNADT, ''E5_LOJAADT,'' E5_CLIENTE,'' E5_FORNECE,'' E5_SERREC,'' E5_OPERAD,'' E5_MOVCX,'' E5_KEY,'' E5_MULTNAT,'' E5_AGLIMP,0 E5_VLACRES, 
			cQryFix	+= " 		0 E5_VLDECRE, 0 E5_VRETPIS, 0 E5_VRETCOF,0 E5_VRETCSL,'' E5_PRETPIS,'' E5_PRETCOF,'' E5_PRETCSL,'' E5_AUTBCO,'' E5_PRETIRF,0 E5_VRETIRF,0 E5_VRETISS, 
			cQryFix	+= " 		''E5_NUMMOV,'' E5_PROCTRA,'' E5_IDMOVI,0 E5_BASEIRF, 
			cQryFix	+= " 		(CASE WHEN E5_VLCORRE = 0 THEN 'IMPZGBV' WHEN E5_VLCORRE > 0 THEN 'IMPZGBP' ELSE 'IMPZGBN' END) E5_ORIGEM,
			cQryFix	+= " 		'' E5_DTCANBX, '' E5_DIACTB,'' E5_NODIA,'' E5_FLDMED,'' E5_TPDESC, 
			cQryFix	+= " 		0 E5_PRINSS,0 E5_VRETINS,0 E5_PRETINS,'' E5_CCUSTO,'' E5_FORMAPG,'' E5_SDOCREC,'' E5_MOVFKS,'' E5_IDORIG,'' E5_TABORI,'' E5_SEQCON,0 E5_PRISS, 
			cQryFix	+= " 		''E5_CGC, D_E_L_E_T_, R_E_C_N_O_, R_E_C_D_E_L_,'' E5_USERLGI,'' E5_USERLGA,'IMPZGB' E5_XCLVL,'' E5_MSIDENT,'' E5_MSFIL,'' E5_MSEMP,'' E5_XCODSAF, 
			cQryFix	+= " 		''E5_XCONJU, '' E5_XLEGEND, 0 E5_XVLM1
			cQryFix	+= " FROM
			cQryFix	+= " (SELECT 	ZGB_FILIAL AS E5_FILIAL, ZGB_DATA AS E5_DATA, ZGB_TIPO AS E5_TIPO, 
			cQryFix	+= " 		ZGB_MOEDA AS E5_MOEDA, ZGB_VALOR AS E5_VALOR, 
			cQryFix	+= " 		ZGB_NATURE AS E5_NATUREZ, ZGB_BANCO AS E5_BANCO, ZGB_AGENCI AS E5_AGENCIA, 
			cQryFix	+= " 		ZGB_CONTA AS E5_CONTA, ZGB_NUMCHE AS E5_NUMCHEQ, 
			cQryFix	+= " 		ZGB_DOCUME AS E5_DOCUMEN, ZGB_VENCTO AS E5_VENCTO, ZGB_RECPAG AS E5_RECPAG, 
			cQryFix	+= " 		ZGB_BENEF AS E5_BENEF, SUBSTRING('XRT - '+ZGB_HISTOR,1,255) AS E5_HISTOR, 
			cQryFix	+= " 		ZGB_TIPODO AS E5_TIPODOC, 
			cQryFix	+= " 		ZGB_TXMOED AS E5_TXMOEDA,
			cQryFix	+= " 		ZGB_MOTBX AS E5_MOTBX,
			cQryFix	+= " 		ZGB_VLMOE2 AS E5_VLMOED2,
			cQryFix	+= " 		ZGB_FILORI AS E5_FILORIG,
			cQryFix	+= " 		ZGB_NUMERO AS E5_NUMERO, ZGB_PARCEL AS E5_PARCELA, 
			cQryFix	+= " 		ZGB_CLIFOR AS E5_CLIFOR, ZGB_LOJA AS E5_LOJA, ZGB_DTDIGI AS E5_DTDIGIT, 
			cQryFix	+= " 		ZGB_RECONC AS E5_RECONC, ZGB_DTDISP AS E5_DTDISPO, ZGB_VLCORR AS E5_VLCORRE, ZGB_PREFIX AS E5_PREFIXO, D_E_L_E_T_, R_E_C_N_O_, R_E_C_D_E_L_
			cQryFix	+= " FROM 	"+RetSqlName("ZGB")
			cQryFix	+= " WHERE 	D_E_L_E_T_ = '' AND ZGB_VALOR > 0 "
			
			If !SuperGetMv("MV_ZXRTLCP",.F.,.T.) //Considera planilha  do XRT? .T. = SIM, .F. = NÃO
				cQryFix	+= " 	AND 1 = 2  "
			EndIf
			
			cQryFix	+= " 	AND (ZGB_PARTIC = '' OR ZGB_PARTIC LIKE '%'+'"+_cCodParc+"'+'%' ) "


			cQryFix	+= " ) AS SE5
			cQryFix	+= " ) AS SE5


			cQryFix	+= " INNER JOIN " + RetSqlName("SED") + " SED "
			If cTamSED == cTamSE5
				cQryFix	+= " ON ED_FILIAL = E5_FILIAL "
			Else
				If Val(cTamSED) == 0
					cQryFix	+= " ON ( ED_FILIAL = ' ' "
				Else
					cQryFix	+= " ON ( SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(E5_FILORIG,1, " + cTamSED + ") "
				EndIf
				cQryFix	+= " OR ( (E5_ORIGEM LIKE 'GPE%' AND " + CompTab("SE5", "E5_FILIAL", , cTamSE5) + ") "
				cQryFix	+= " OR (E5_ORIGEM LIKE 'ADT%' AND " + CompTab("SE5", "E5_FILIAL", , cTamSE5) + " ) ) ) "
			EndIf
			cQryFix	+= " AND ED_CODIGO = E5_NATUREZ 

			cQryFix	+= " AND ( 
			cQryFix	+= " 			ED_LCDPR = '1' OR E5_XCLVL = 'IMPZGB' 
			// 23/06/2026 - Cria��o de regra para adicionar os registros do XRT de varia��o cambial
			cQryFix	+= " 		OR (E5_VLCORRE <> 0 AND E5_DOCUMEN LIKE 'XRT%' AND E5_HISTOR LIKE 'PRI%')
			cQryFix	+= " ) "








			cQryFix	+= " AND SED.D_E_L_E_T_ = ' ' "
			cQryFix	+= " INNER JOIN " + cTmpFil + " TRFIL "
			cQryFix	+= " ON ( E5_FILORIG IN ( SELECT TRFIL.FILIAL FROM " + cTmpFil + " ) "
			cQryFix	+= " OR ( (E5_ORIGEM LIKE 'GPE%' AND " + CompTab("SE5", "E5_FILIAL", , cTamSE5) + ") "
			cQryFix	+= " OR (E5_ORIGEM LIKE 'ADT%' AND " + CompTab("SE5", "E5_FILIAL", , cTamSE5) + " ) ) ) "

			If cDtPeriodo == '1'
				cQryFix	+= " AND E5_DATA >= TRFIL.DTINI "
				cQryFix	+= " AND E5_DATA <= TRFIL.DTFIM "
				cQryFix	+= " AND SE5.D_E_L_E_T_ = ' ' "
				cQryFix	+= " LEFT JOIN " + RetSqlName("FVV") + " FVV "
				cQryFix	+= " ON ( FVV_FILIAL = E5_FILORIG "
				cQryFix	+= " AND E5_DATA BETWEEN '" + DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' ) "
				
				cQryFix	+= " AND FVV_CODPES = '" + __cFVUCod + "' AND SE5.D_E_L_E_T_ = ' ' AND FVV.D_E_L_E_T_ = ' ' "

				cQryFix	+= " LEFT JOIN " + RetSqlName("FVG") + " FVG ON ( FVG_FILIAL = E5_FILORIG "
				cQryFix	+= " AND E5_DATA BETWEEN '" + DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' ) "
				cQryFix	+= " AND FVG_CODPES = '" + __cFVUCod + "' "
				cQryFix	+= " AND FVG_TPPES = '1' "
				cQryFix	+= " AND FVG_NUMIMO = '000' "
				cQryFix	+= " AND SE5.D_E_L_E_T_ = ' ' "
				cQryFix	+= " AND FVG.D_E_L_E_T_ = ' ' "
			Else
				cQryFix	+= " AND ( E5_DTDISPO >= TRFIL.DTINI "
				cQryFix	+= " AND E5_DTDISPO <= TRFIL.DTFIM) "

				cQryFix	+= " LEFT JOIN " + RetSqlName("FVV") + " FVV "
				cQryFix	+= " ON ( FVV_FILIAL = E5_FILORIG ) "

				cQryFix	+= " AND ( SE5.E5_DTDISPO BETWEEN '" + DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' ) "
				cQryFix	+= " AND FVV_CODPES = '" + __cFVUCod + "' AND SE5.D_E_L_E_T_ = ' ' AND FVV.D_E_L_E_T_ = ' ' "

				cQryFix	+= " LEFT JOIN " + RetSqlName("FVG") + " FVG ON ( FVG_FILIAL = SE5.E5_FILORIG "
				cQryFix	+= " AND ( E5_DTDISPO BETWEEN '" + DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' ) ) "
				cQryFix	+= " AND FVG_CODPES = '" + __cFVUCod + "' "
				cQryFix	+= " AND FVG_TPPES = '1' "
				cQryFix	+= " AND FVG_NUMIMO = '000' "
				cQryFix	+= " AND SE5.D_E_L_E_T_ = ' ' "
				cQryFix	+= " AND FVG.D_E_L_E_T_ = ' ' "

			EndIf
			
			cQryFix	+= " LEFT JOIN " + cTmpBco + " TRBCO "
			cQryFix	+= " ON " + CompTab("TRBCO", "FIL", , cTamSA6)
			cQryFix	+= " AND E5_BANCO = TRBCO.BANCO AND E5_AGENCIA = TRBCO.AGENCIA AND E5_CONTA = TRBCO.CONTA "
			
			cQryFix	+= " LEFT JOIN " + RetSqlName("SA1") + " SA1 "
			If cTamSA1 == cTamSE5
				cQryFix	+= " ON A1_FILIAL = E5_FILIAL "
			Else
				If Val(cTamSA1) == 0
					cQryFix	+= " ON A1_FILIAL = ' ' "
				Else
					cQryFix	+= " ON SUBSTRING(A1_FILIAL,1, " + cTamSA1 + ") = SUBSTRING(E5_FILORIG,1, " + cTamSA1 + ") "
				EndIf
			EndIf
			cQryFix	+= " AND E5_CLIFOR = A1_COD AND E5_LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = ' ' "
			
			cQryFix	+= " LEFT JOIN " + RetSqlName("SA2") + " SA2 "
			If cTamSA2 == cTamSE5
				cQryFix	+= " ON A2_FILIAL = E5_FILIAL "
			Else
				If Val(cTamSA2) == 0
					cQryFix	+= " ON A2_FILIAL = ' ' "
				Else
					cQryFix	+= " ON SUBSTRING(A2_FILIAL,1, " + cTamSA2 + ") = SUBSTRING(E5_FILORIG,1, " + cTamSA2 + ") "
				EndIf
			EndIf
			cQryFix	+= " AND E5_CLIFOR = A2_COD AND E5_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' "

			cQryFix	+= " LEFT JOIN " + RetSqlName("SE1") + " SE1 "
			cQryFix	+= " ON " + CompTab("SE1", "E1_FILIAL", , cTamSE1)
			cQryFix	+= " AND ( E5_PREFIXO = E1_PREFIXO AND E5_NUMERO = E1_NUM AND E5_PARCELA = E1_PARCELA AND E5_TIPO = E1_TIPO "
			cQryFix	+= " AND E5_CLIFOR = E1_CLIENTE AND E5_LOJA = E1_LOJA AND E5_TABORI = 'FK1' AND SE1.D_E_L_E_T_ = ' ' ) "
			cQryFix	+= " LEFT JOIN " + RetSqlName("SE2") + " SE2 "
			cQryFix	+= " ON " + CompTab("SE2", "E2_FILIAL", , cTamSE2)
			cQryFix	+= " AND ( E5_PREFIXO = E2_PREFIXO AND E5_NUMERO = E2_NUM AND E5_PARCELA = E2_PARCELA AND E5_TIPO = E2_TIPO " 
			cQryFix	+= " AND E5_CLIFOR = E2_FORNECE AND E5_LOJA = E2_LOJA AND E5_TABORI = 'FK2' AND SE2.D_E_L_E_T_ = ' ' ) "
			cQryFix	+= "LEFT JOIN " + RetSqlName("SF2") + " SF2IMP "
            cQryFix	+= 		"ON SE1.E1_FILORIG = SF2IMP.F2_FILIAL "
            cQryFix	+= 			"AND SE1.E1_CLIENTE = SF2IMP.F2_CLIENTE "
            cQryFix	+=       	"AND SE1.E1_LOJA = SF2IMP.F2_LOJA "
            cQryFix	+=       	"AND SE1.E1_NUM = SF2IMP.F2_DOC "
            cQryFix	+=       	"AND SE1.E1_PREFIXO = SF2IMP.F2_SERIE "
            cQryFix	+=  	  	"AND SE1.D_E_L_E_T_ = ' ' "
			cQryFix	+=       	"AND SF2IMP.D_E_L_E_T_ = ' ' "
			cQryFix	+= "LEFT JOIN " + RetSqlName("SF1") + " SF1IMP "
			cQryFix	+=  	"ON SE2.E2_FILORIG = SF1IMP.F1_FILIAL "
			cQryFix	+= 			"AND SE2.E2_FORNECE = SF1IMP.F1_FORNECE "
			cQryFix	+=  		"AND SE2.E2_LOJA = SF1IMP.F1_LOJA "
			cQryFix	+=  		"AND SE2.E2_NUM = SF1IMP.F1_DOC "
			cQryFix	+=  		"AND SE2.E2_PREFIXO = SF1IMP.F1_SERIE "
			cQryFix	+=  		"AND SE2.D_E_L_E_T_ = ' ' "
			cQryFix	+=       	"AND SF1IMP.D_E_L_E_T_ = ' ' "
			cQryFix	+= "WHERE  "
			cQryAux	+= cQryFix
			
			If __lF820Qry .and. 1 == 2
				cCondAux 	:= If( ValType(aAretPE[1]) == 'C', aAretPE[1], "" )
				If !Empty(cCondAux)
					cQryAux += cCondAux
				Else
					cQryAux += cCond
				EndIf
			Else
				cQryAux += cCond
			EndIf
			
			cQuery	:= cQryAux
			
			cQryAux	:= ""
			cQryAux	+= " UNION "
			cQryAux	+= " SELECT SUBSTRING(SE1IMP.E1_BAIXA,7,2) DIA, SUBSTRING(SE1IMP.E1_BAIXA, 5, 2) || SUBSTRING(SE1IMP.E1_BAIXA, 1, 4) MES_ANO, SE1IMP.E1_BAIXA DDATA, TRFIL.COD FILCOD, "
			
			If !Empty(cPercPE) .And. ( ValType(Val(cPercPE)) == 'N' .And. Val(cPercPE) > 0 )
				cQryAux	+= cPercPE + " AS PERC, "
			Else
				cQryAux	+= " COALESCE(FVV1I.FVV_PARTIC, FVG_PERC) AS PERC, "
			EndIf
			cQryAux	+= " ISNULL(TRBCO.COD,'') BANCO, SE1IMP.E1_PREFIXO PREFIXO, SE1IMP.E1_NUM NUMDOC, SE1IMP.E1_HIST HIST, ISNULL(SA1.A1_CGC,'') CNPJCLI, ISNULL(SA1.A1_PAIS,'') PAISCLI, ' ' CNPJFOR, ' ' PAISFOR, "
			cQryAux	+= " ' ' TPDOC, SE1IMP.E1_TIPO E5_TIPO, 'P' RECPAG,ISNULL( SE1IMP.E1_VLCRUZ,0) E1_VLCRUZ, 0, 0 SLDREC, ISNULL(SE1IMP.E1_SALDO,0) SLDPAG, ' ', 0 REC, SE1IMP.E1_CLIENTE CLIFOR, SE1IMP.E1_VALOR AS VALOR "
			If lE5Cgc
				cQryAux	+= " , ' ' CGC "
			EndIf
			cQryAux	+= " , SE1IMP.E1_VLCRUZ VLMOED2, '0' || CAST(SE1IMP.E1_MOEDA AS VARCHAR(2) ) MOEDA "
			cQryAux	+= " , SE1IMP.E1_ORIGEM ORI, SE1IMP.E1_PARCELA PARC, SE1IMP.E1_LOJA LOJA, ' ' CODEMP, SE1IMP.E1_FILIAL SEFIL "
			cQryAux	+= " , NULL RECSF12 "
			cQryAux	+= " , NULL VBRUT12 "
	   		cQryAux	+= " , NULL VSENA12 " 
	   		cQryAux	+= " , NULL VINSS12 "
	   		cQryAux	+= " , NULL COSOC12 "
			cQryAux	+= " , NULL NFTOTAL "
			cQryAux	+= " , NULL FUNRURAL "
			cQryAux	+= " , NULL VLSENAR "
			cQryAux	+= " , NULL VALINS "
			cQryAux += " , NULL VLFETFAC , SE1IMP.E1_NATUREZ"
			cQryAux	+= " FROM " + RetSqlName("SE1") + " SE1IMP "
			
			cQryAux	+= " INNER JOIN " + cTmpFil + " TRFIL "
			cQryAux	+= " ON SE1IMP.E1_FILORIG IN ( SELECT TRFIL.FILIAL FROM " + cTmpFil + " ) "
			cQryAux	+= " AND SE1IMP.E1_BAIXA >= TRFIL.DTINI "
   			cQryAux	+= " AND SE1IMP.E1_BAIXA <= TRFIL.DTFIM "
   			cQryAux	+= " AND SE1IMP.D_E_L_E_T_ = ' ' "

			cQryAux	+= " LEFT JOIN " + RetSqlName("FVV") + " FVV1I "
			cQryAux	+= " ON FVV_FILIAL = SE1IMP.E1_FILORIG "
			
			cQryAux	+= " AND ( ( ( FVV_VIGINI = ' ' AND SE1IMP.E1_BAIXA >= '" + DTOS(aParamIni[7]) + "' ) OR SE1IMP.E1_BAIXA >= FVV_VIGINI ) AND
			cQryAux	+= " ( ( FVV_VIGFIM = ' ' AND SE1IMP.E1_BAIXA <= '" + DTOS(aParamIni[8]) + "' ) OR SE1IMP.E1_BAIXA <= FVV_VIGFIM ) ) "
			cQryAux	+= " AND SE1IMP.E1_BAIXA BETWEEN '" +  DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' "
			cQryAux	+= " AND FVV1I.FVV_CODPES = '" + __cFVUCod + "' AND SE1IMP.D_E_L_E_T_ = ' ' AND FVV1I.D_E_L_E_T_ = ' ' "

			cQryAux	+= " LEFT JOIN " + RetSqlName("FVG") + " FVG ON ( FVG_FILIAL = SE1IMP.E1_FILORIG "
			cQryAux	+= " AND SE1IMP.E1_BAIXA BETWEEN '" + DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' ) "
			cQryAux	+= " AND FVG_CODPES = '" + __cFVUCod + "' "
			cQryAux	+= " AND FVG_TPPES = '1' "
			cQryAux	+= " AND SE1IMP.D_E_L_E_T_ = ' ' "
			cQryAux	+= " AND FVG.D_E_L_E_T_ = ' ' "

			cQryAux	+= " LEFT JOIN " + cTmpBco + " TRBCO "
			cQryAux	+= " ON " + StrTran( CompTab("TRBCO", "FIL", "SE1", cTamSA6), "E1_FILIAL", "SE1IMP.E1_FILIAL" )
			cQryAux	+= " AND SE1IMP.E1_PORTADO = TRBCO.BANCO AND SE1IMP.E1_AGEDEP = TRBCO.AGENCIA AND SE1IMP.E1_CONTA = TRBCO.CONTA "
			
			cQryAux	+= " INNER JOIN " + RetSqlName("SE1") + " SE1PAI "
			cQryAux	+= " ON SE1IMP.E1_TITPAI = SE1PAI.E1_PREFIXO || SE1PAI.E1_NUM || SE1PAI.E1_PARCELA || SE1PAI.E1_TIPO || SE1PAI.E1_CLIENTE || SE1PAI.E1_LOJA 
			cQryAux	+= " AND SE1PAI.D_E_L_E_T_ = ' ' "
			cQryAux	+= " INNER JOIN " + RetSqlName("SED") + " SED "
			
			If cTamSED == cTamSE1
				cQryAux	+= " ON ED_FILIAL = SE1PAI.E1_FILIAL "
			Else
				If Val(cTamSED) == 0
					cQryAux	+= " ON ED_FILIAL = ' ' "
				Else
					cQryAux	+= " ON SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(SE1PAI.E1_FILORIG,1, " + cTamSED + ") "
				EndIf
			EndIf

			cQryAux += " AND ED_CODIGO = SE1PAI.E1_NATUREZ AND (ED_LCDPR = '1' ) AND SED.D_E_L_E_T_ = ' ' "
			cQryAux	+= " INNER JOIN " + RetSqlName("SA1") + " SA1 "

			If cTamSA1 == cTamSE1
				cQryAux	+= " ON A1_FILIAL = SE1PAI.E1_FILIAL "
			Else
				If Val(cTamSA1) == 0
					cQryAux	+= " ON A1_FILIAL = ' ' "
				Else
					cQryAux	+= " ON SUBSTRING(A1_FILIAL,1, " + cTamSA1 + ") = SUBSTRING(SE1PAI.E1_FILORIG,1, " + cTamSA1 + ") "
				EndIf
			EndIf

			cQryAux	+= " AND SE1PAI.E1_CLIENTE = A1_COD AND SE1PAI.E1_LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = ' ' "

			cQryAux	+= " WHERE SE1IMP.E1_SALDO = 0 AND SE1IMP.E1_TIPO IN ('TX ', 'TXA', '"
			cQryAux	+= cNatPis + "', '" + cNatSes + "', '" + cNatIss + "', '" + cNatCof + "', '" + cNatCsl + "', '" + cNatIns + "', '" + cNatIrf + "', 'FB-', 'FC-', 'FU-', 'FE-', 'IN-' , 'IS-' , 'AB-' ) "
			cQryAux	+= " AND SE1IMP.E1_BAIXA BETWEEN '" +  DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' "
			cQryAux	+= " AND SE1IMP.E1_NUMLIQ = ' ' AND ( SE1IMP.E1_FATURA = '" + Space(Len(SE1->E1_FATURA)) + "' OR SE1IMP.E1_FATURA = 'NOTFAT' ) AND SE1IMP.D_E_L_E_T_ = ' ' "
			
			cQryAux	+= " UNION "
			cQryAux	+= " SELECT SUBSTRING(SE2IMP.E2_BAIXA,7,2) DIA, SUBSTRING(SE2IMP.E2_BAIXA, 5, 2) || SUBSTRING(SE2IMP.E2_BAIXA, 1, 4) MES_ANO, SE2IMP.E2_BAIXA DDATA, TRFIL.COD FILCOD, "
			If !Empty(cPercPE) .And. ( ValType(Val(cPercPE)) == 'N' .And. Val(cPercPE) > 0 )
				cQryAux	+= cPercPE + " AS PERC, "
			Else
				cQryAux	+= " COALESCE(FVV2I.FVV_PARTIC, FVG_PERC) AS PERC, "
			EndIf
			cQryAux	+= " ' ' BANCO, SE2IMP.E2_PREFIXO PREFIXO, SE2IMP.E2_NUM NUMDOC, SE2IMP.E2_HIST HIST, ' ' CNPJCLI, ' ' PAISCLI, '" + __cCpf + "' CNPJFOR, ' ' PAISFOR,"
			cQryAux	+= " ' ' TPDOC, SE2IMP.E2_TIPO E5_TIPO," 
			cQryAux	+= " CASE WHEN SE2IMP.E2_TIPO = 'AB-' THEN 'R' ELSE 'P' END RECPAG," 
			cQryAux	+= " ISNULL(SE2IMP.E2_VLCRUZ,0) E2_VLCRUZ, 0, 0 SLDREC, ISNULL(SE2IMP.E2_SALDO,0) SLDPAG, ' ', 0 REC, SE2IMP.E2_FORNECE CLIFOR, SE2IMP.E2_VALOR AS VALOR "
			If lE5Cgc
				cQryAux	+= " , ' ' CGC "
			EndIf
			cQryAux	+= " , SE2IMP.E2_VLCRUZ VLMOED2, '0' || CAST(SE2IMP.E2_MOEDA AS VARCHAR(2) ) MOEDA "
			cQryAux	+= " , SE2IMP.E2_ORIGEM ORI, SE2IMP.E2_PARCELA PARC, SE2IMP.E2_LOJA LOJA, ' ' CODEMP, SE2IMP.E2_FILIAL SEFIL "
			cQryAux	+= " , NULL RECSF12 "
			cQryAux	+= " , NULL VBRUT12 "
	   		cQryAux	+= " , NULL VSENA12 " 
	   		cQryAux	+= " , NULL VINSS12 "
	   		cQryAux	+= " , NULL COSOC12 "
			cQryAux	+= " , NULL NFTOTAL "
			cQryAux	+= " , NULL FUNRURAL "
			cQryAux	+= " , NULL VLSENAR "
			cQryAux	+= " , NULL VALINS "
			cQryAux += " , NULL VLFETFAC, SE2IMP.E2_NATUREZ "	   

			cQryAux	+= " FROM " + RetSqlName("SE2") + " SE2IMP "
			
			cQryAux	+= " INNER JOIN " + cTmpFil + " TRFIL "
			cQryAux	+= " ON SE2IMP.E2_FILORIG IN ( SELECT TRFIL.FILIAL FROM " + cTmpFil + " ) "
			cQryAux	+= " AND SE2IMP.E2_BAIXA >= TRFIL.DTINI "
   			cQryAux	+= " AND SE2IMP.E2_BAIXA <= TRFIL.DTFIM "
   			cQryAux	+= " AND SE2IMP.D_E_L_E_T_ = ' ' "

			cQryAux	+= " LEFT JOIN " + RetSqlName("FVV") + " FVV2I "
			cQryAux	+= " ON FVV_FILIAL = SE2IMP.E2_FILORIG "
			
			cQryAux	+= " AND ( ( ( FVV_VIGINI = ' ' AND SE2IMP.E2_BAIXA >= '" + DTOS(aParamIni[7]) + "' ) OR SE2IMP.E2_BAIXA >= FVV_VIGINI ) AND
			cQryAux	+= " ( ( FVV_VIGFIM = ' ' AND SE2IMP.E2_BAIXA <= '" + DTOS(aParamIni[8]) + "' ) OR SE2IMP.E2_BAIXA <= FVV_VIGFIM ) ) "
			cQryAux	+= " AND SE2IMP.E2_BAIXA BETWEEN '" +  DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' "
			cQryAux	+= " AND FVV2I.FVV_CODPES = '" + __cFVUCod + "' AND SE2IMP.D_E_L_E_T_ = ' ' AND FVV2I.D_E_L_E_T_ = ' ' "

			cQryAux	+= " LEFT JOIN " + RetSqlName("FVG") + " FVG ON ( FVG_FILIAL = SE2IMP.E2_FILORIG "
			cQryAux	+= " AND SE2IMP.E2_BAIXA BETWEEN '" + DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' ) "
			cQryAux	+= " AND FVG_CODPES = '" + __cFVUCod + "' "
			cQryAux	+= " AND FVG_TPPES = '1' "
			cQryAux	+= " AND SE2IMP.D_E_L_E_T_ = ' ' "
			cQryAux	+= " AND FVG.D_E_L_E_T_ = ' ' "

			cQryAux	+= " INNER JOIN " + RetSqlName("SE2") + " SE2PAI "
			cQryAux	+= " ON SE2IMP.E2_TITPAI = SE2PAI.E2_PREFIXO || SE2PAI.E2_NUM || SE2PAI.E2_PARCELA || SE2PAI.E2_TIPO || SE2PAI.E2_FORNECE || SE2PAI.E2_LOJA 
			cQryAux	+= " AND SE2PAI.D_E_L_E_T_ = ' ' "
			cQryAux	+= " INNER JOIN " + RetSqlName("SED") + " SED "
			
			If cTamSED == cTamSE2
				cQryAux	+= " ON ED_FILIAL = SE2PAI.E2_FILIAL "
			Else
				If Val(cTamSED) == 0
					cQryAux	+= " ON ED_FILIAL = ' ' "
				Else
					cQryAux	+= " ON SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(SE2PAI.E2_FILORIG,1, " + cTamSED + ") "
				EndIf
			EndIf

			cQryAux	+= " AND ED_CODIGO = SE2PAI.E2_NATUREZ AND (ED_LCDPR = '1' ) AND SED.D_E_L_E_T_ = ' ' "

			cQryAux	+= " WHERE SE2IMP.E2_SALDO = 0 AND SE2IMP.E2_TIPO IN ('TX ', 'TXA', '"
			cQryAux	+= cNatPis + "', '" + cNatSes + "', '" + cNatIss + "', '" + cNatCof + "', '" + cNatCsl + "', '" + cNatIns + "', '" + cNatIrf + "' , 'AB-' ) "
			cQryAux	+= " AND SE2IMP.E2_BAIXA BETWEEN '" +  DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' "
			cQryAux	+= " AND SE2IMP.E2_NUMLIQ = ' ' AND ( SE2IMP.E2_FATURA = '" + Space(Len(SE2->E2_FATURA)) + "' OR SE2IMP.E2_FATURA = 'NOTFAT' ) AND SE2IMP.D_E_L_E_T_ = ' ' "  

			IF __cLCDPRRA == "D"

				cQryAux	+= " UNION " 
				cQryAux	+= " SELECT SUBSTRING(SE1ADTO.E1_EMISSAO,7,2) DIA, SUBSTRING(SE1ADTO.E1_EMISSAO, 5, 2) || SUBSTRING(SE1ADTO.E1_EMISSAO, 1, 4) MES_ANO, SE1ADTO.E1_EMISSAO DDATA, TRFIL.COD FILCOD, " 
				cQryAux	+= " COALESCE(FVV1.FVV_PARTIC, FVG_PERC) AS PERC, ISNULL(TRBCO.COD,'') BANCO, SE1ADTO.E1_PREFIXO PREFIXO, SE1ADTO.E1_NUM NUMDOC, SE1ADTO.E1_HIST HIST, ISNULL(SA1.A1_CGC,'') CNPJCLI, ' ' PAISCLI, ' ' CNPJFOR, ' ' PAISFOR, " 
				cQryAux	+= " ' ' TPDOC, SE1ADTO.E1_TIPO E5_TIPO, 'R' RECPAG, SE1ADTO.E1_VALOR, 0, ISNULL(SE1ADTO.E1_SALDO,0) SLDREC, 0 SLDPAG, ' ', 0 REC, SE1ADTO.E1_CLIENTE CLIFOR "
				If SuperGetMV("MV_MULNATR",,".F.")
					cCampos	:= " , E1_VLCRUZ * ( Select ISNULL( Sum(EV_PERC), 1 ) From " + RetSqlName("SEV") + " SEV "
					cCampos	+= " Inner Join " + RetSqlName ("SED") + " SED "
					If cTamSEV == cTamSED
						cCampos	+= " ON EV_FILIAL = ED_FILIAL "
					ElseIf Val(cTamSED) == 0
						cCampos	+= " ON ED_FILIAL = ' ' "
					ElseIf Val(cTamSEV) > Val(cTamSED)
						cCampos	+= " ON SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(EV_FILIAL,1, " + cTamSED + ") "
					Else
						cCampos	+= " ON SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(E1_FILORIG,1, " + cTamSED + ") "
					EndIf
					cCampos	+= " AND EV_NATUREZ = ED_CODIGO AND ED_LCDPR = '1' AND SED.D_E_L_E_T_ = '' " 
					cCampos	+= " WHERE " + CompTab("SEV", "EV_FILIAL", "SE1", cTamSEV ) + " AND EV_PREFIXO = E1_PREFIXO AND EV_NUM = E1_NUM AND EV_PARCELA = E1_PARCELA "
					cCampos	+= " AND EV_CLIFOR = E1_CLIENTE AND EV_LOJA = E1_LOJA AND EV_TIPO = E1_TIPO AND EV_RECPAG = 'R' "
					cCampos	+= " AND EV_IDENT = '1' AND EV_SITUACA = ' ' AND SEV.D_E_L_E_T_ = ' ' ) AS VALOR "
				Else
					cCampos	+= " , SE1ADTO.E1_VLCRUZ AS VALOR "
				EndIf

				_cRegraXRT	:= " (CASE WHEN (E5_VLCORRE <> 0 AND E5_DOCUMEN LIKE 'XRT%' AND E5_HISTOR LIKE 'PRI%' ) THEN 0 ELSE E5_VLCORRE END) AS E5_VLCORRE

				cCampos := Replace(cCampos, "E5_VLCORRE", _cRegraXRT)


				cQryAux += cCampos	
				If lE5Cgc
					cQryAux	+= " , ' ' CGC "
				EndIf
				cQryAux	+= " , SE1ADTO.E1_VLCRUZ VLMOED2, '0' || CAST(SE1ADTO.E1_MOEDA AS VARCHAR(2) ) MOEDA "
				cQryAux	+= " , SE1ADTO.E1_ORIGEM ORI, SE1ADTO.E1_PARCELA PARC, SE1ADTO.E1_LOJA LOJA, ' ' CODEMP, SE1ADTO.E1_FILIAL SEFIL "
				cQryAux += " , NULL RECSF12 "
				cQryAux	+= " , NULL VBRUT12 "
	   			cQryAux	+= " , NULL VSENA12 " 
	   			cQryAux	+= " , NULL VINSS12 "
	   			cQryAux	+= " , NULL COSOC12 "
				cQryAux	+= " , NULL NFTOTAL "
				cQryAux	+= " , NULL FUNRURAL "
				cQryAux	+= " , NULL VLSENAR "
				cQryAux	+= " , NULL VALINS "
				cQryAux += " , NULL VLFETFAC "
				cQryAux	+= " FROM " + RetSqlName("SE1") + " SE1ADTO "
				
				cQryAux	+= " INNER JOIN " + cTmpFil+ " TRFIL "
				cQryAux	+= " ON SE1ADTO.E1_FILORIG IN ( SELECT TRFIL.FILIAL FROM " + cTmpFil+ " ) "
				cQryAux	+= " AND SE1ADTO.E1_EMISSAO >= TRFIL.DTINI "
				cQryAux	+= " AND SE1ADTO.E1_EMISSAO <= TRFIL.DTFIM "
				cQryAux	+= " AND SE1ADTO.D_E_L_E_T_ = ' ' "

				cQryAux	+= " LEFT JOIN " + RetSqlName("FVV") + " FVV1 "
				cQryAux	+= " ON FVV_FILIAL = SE1ADTO.E1_FILORIG "
				
				cQryAux	+= " AND ( ( ( FVV_VIGINI = ' ' AND SE1ADTO.E1_EMISSAO >= '" + DTOS(aParamIni[7]) + "' ) OR SE1ADTO.E1_EMISSAO >= FVV_VIGINI ) AND
				cQryAux	+= " ( ( FVV_VIGFIM = ' ' AND SE1ADTO.E1_EMISSAO <= '" + DTOS(aParamIni[8]) + "' ) OR SE1ADTO.E1_EMISSAO <= FVV_VIGFIM ) ) "
				cQryAux	+= " AND SE1ADTO.E1_EMISSAO BETWEEN '" +  DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' "
				cQryAux	+= " AND FVV_CODPES = '" + __cFVUCod + "' AND SE1ADTO.D_E_L_E_T_ = ' ' AND FVV1.D_E_L_E_T_ = ' ' "

				cQryAux	+= " LEFT JOIN " + RetSqlName("FVG") + " FVG ON ( FVG_FILIAL = SE1ADTO.E1_FILORIG "
				cQryAux	+= " AND SE1ADTO.E1_EMISSAO BETWEEN '" + DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' ) "
				cQryAux	+= " AND FVG_CODPES = '" + __cFVUCod + "' "
				cQryAux	+= " AND FVG_TPPES = '1' "
				cQryAux	+= " AND SE1ADTO.D_E_L_E_T_ = ' ' "
				cQryAux	+= " AND FVG.D_E_L_E_T_ = ' ' "

				cQryAux	+= " LEFT JOIN " + cTmpBco + " TRBCO "
				cQryAux	+= " ON " + StrTran( CompTab("TRBCO", "FIL", "SE1", cTamSA6), "E1_FILIAL", "SE1ADTO.E1_FILIAL" )
				cQryAux	+= " AND SE1ADTO.E1_PORTADO = TRBCO.BANCO AND SE1ADTO.E1_AGEDEP = TRBCO.AGENCIA AND SE1ADTO.E1_CONTA = TRBCO.CONTA "
			
				cQryAux	+= " INNER JOIN " + RetSqlName("SED") + " SED " // ON " + StrTran( CompTab("SED", "ED_FILIAL", "SE1", cTamSED) , "E1_FILIAL", "SE1ADTO.E1_FILIAL" )
	
				If cTamSED == cTamSE1
					cQryAux	+= " ON ED_FILIAL = SE1ADTO.E1_FILIAL "
				Else
					If Val(cTamSED) == 0
						cQryAux	+= " ON ED_FILIAL = ' ' "
					Else
						cQryAux	+= " ON SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(SE1ADTO.E1_FILORIG,1, " + cTamSED + ") "
					EndIf
				EndIf
		
				cQryAux	+= " AND ED_CODIGO = SE1ADTO.E1_NATUREZ AND (ED_LCDPR = '1' ) AND SED.D_E_L_E_T_ = ' ' "
				cQryAux	+= " INNER JOIN " + RetSqlName("SA1") + " SA1 "

				If cTamSA1 == cTamSE1
					cQryAux	+= " ON A1_FILIAL = SE1ADTO.E1_FILIAL "
				Else
					If Val(cTamSA1) == 0
						cQryAux	+= " ON A1_FILIAL = ' ' "
					Else
						cQryAux	+= " ON SUBSTRING(A1_FILIAL,1, " + cTamSA1 + ") = SUBSTRING(SE1ADTO.E1_FILORIG,1, " + cTamSA1 + ") "
					EndIf
				EndIf
				cQryAux	+= " AND SE1ADTO.E1_CLIENTE = A1_COD AND SE1ADTO.E1_LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = ' '
				cQryAux	+= " WHERE SE1ADTO.E1_TIPO IN ('" + MVRECANT + "') AND "
				cQryAux	+= " SE1ADTO.E1_EMISSAO BETWEEN '" +  DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' "
				cQryAux	+= " AND ED_LCDPR = '1' AND SE1ADTO.D_E_L_E_T_ = ' ' "

			ENDIF

			IF __cLCDPRPA == "D"

				cQryAux	+= " UNION "
				cQryAux	+= " SELECT SUBSTRING(SE2ADTO.E2_EMISSAO,7,2) DIA, SUBSTRING(SE2ADTO.E2_EMISSAO, 5, 2) || SUBSTRING(SE2ADTO.E2_EMISSAO, 1, 4) MES_ANO, SE2ADTO.E2_EMISSAO DDATA, TRFIL.COD FILCOD, " 
				cQryAux	+= " COALESCE(FVV2.FVV_PARTIC, FVG_PERC) AS PERC, ISNULL(TRBCO.COD,'') BANCO, SE2ADTO.E2_PREFIXO PREFIXO, SE2ADTO.E2_NUM NUMDOC, SE2ADTO.E2_HIST HIST, ' ' CNPJCLI, ' ' PAISCLI, SA2.A2_CGC CNPJFOR, SA2.A2_PAIS PAISFOR, "
				cQryAux	+= " ' ' TPDOC, SE2ADTO.E2_TIPO E5_TIPO, 'P' RECPAG, 0, SE2ADTO.E2_VALOR,  0 SLDREC, ISNULL(SE2ADTO.E2_SALDO,0) SLDPAG, ' ', 0 REC, SE2ADTO.E2_FORNECE CLIFOR "
				
				If SuperGetMV("MV_MULNATP",,".F.")
					cCampos	:= " , E2_VLCRUZ * ( Select ISNULL( Sum(EV_PERC), 1 ) From " + RetSqlName("SEV") + " SEV "
					cCampos	+= " Inner Join " + RetSqlName ("SED") + " SED "
					If cTamSEV == cTamSED
						cCampos	+= " ON EV_FILIAL = ED_FILIAL "
					ElseIf Val(cTamSED) == 0
						cCampos	+= " ON ED_FILIAL = ' ' "
					ElseIf Val(cTamSEV) > Val(cTamSED)
						cCampos	+= " ON SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(EV_FILIAL,1, " + cTamSED + ") "
					Else
						cCampos	+= " ON SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(E2_FILORIG,1, " + cTamSED + ") "
					EndIf
					cCampos	+= " AND EV_NATUREZ = ED_CODIGO AND ED_LCDPR = '1' AND SED.D_E_L_E_T_ = '' " 
					cCampos	+= " WHERE " + CompTab("SEV", "EV_FILIAL", "SE2", cTamSEV ) + " AND EV_PREFIXO = E2_PREFIXO AND EV_NUM = E2_NUM AND EV_PARCELA = E2_PARCELA "
					cCampos	+= " AND EV_CLIFOR = E2_FORNECE AND EV_LOJA = E2_LOJA AND EV_TIPO = E2_TIPO AND EV_RECPAG = 'P' "
					cCampos	+= " AND EV_IDENT = '1' AND EV_SITUACA = ' ' AND SEV.D_E_L_E_T_ = ' ' ) AS VALOR "
				Else
					cCampos	+= " , SE2ADTO.E2_VLCRUZ AS VALOR "
				EndIf

				cQryAux	+= cCampos
				If lE5Cgc
					cQryAux	+= " , ' ' CGC "
				EndIf
				cQryAux	+= " , SE2ADTO.E2_VLCRUZ VLMOED2, '0' || CAST(SE2ADTO.E2_MOEDA AS VARCHAR(2) ) MOEDA "
				cQryAux	+= " , SE2ADTO.E2_ORIGEM ORI, SE2ADTO.E2_PARCELA PARC, SE2ADTO.E2_LOJA LOJA, ' ' CODEMP, SE2ADTO.E2_FILIAL SEFIL "
				cQryAux += " , NULL RECSF12 "
				cQryAux	+= " , NULL VBRUT12 "
	   			cQryAux	+= " , NULL VSENA12 " 
	   			cQryAux	+= " , NULL VINSS12 "
	   			cQryAux	+= " , NULL COSOC12 "
				cQryAux	+= " , NULL NFTOTAL "
				cQryAux	+= " , NULL FUNRURAL "
				cQryAux	+= " , NULL VLSENAR "
				cQryAux	+= " , NULL VALINS "
				cQryAux += " , NULL VLFETFAC "

				cQryAux	+= " FROM " + RetSqlName("SE2") + " SE2ADTO "
				
				cQryAux	+= " INNER JOIN " + RetSqlName("SE5") + " SE5 "
				cQryAux	+= " ON " + StrTran( CompTab("SE5", "E5_FILIAL", "SE2", cTamSE5), "E2_FILIAL", "SE2ADTO.E2_FILIAL" )
				cQryAux	+= " AND SE5.E5_PREFIXO = SE2ADTO.E2_PREFIXO AND SE5.E5_NUMERO = SE2ADTO.E2_NUM AND SE5.E5_PARCELA = SE2ADTO.E2_PARCELA AND SE5.E5_TIPO = SE2ADTO.E2_TIPO " 
				cQryAux	+= " AND SE5.E5_CLIFOR = SE2ADTO.E2_FORNECE AND SE5.E5_LOJA = SE2ADTO.E2_LOJA "
				cQryAux += " AND ((SE5.E5_TIPODOC = 'PA' ) OR (SE5.E5_TIPODOC = 'BA' AND SE5.E5_NUMCHEQ <> '" + cCampoChq + "' ) OR "
				cQryAux += "(SE5.E5_TIPODOC = 'CH' AND SE5.E5_NUMCHEQ <> '" + cCampoChq + "')) "
				cQryAux += " AND SE5.D_E_L_E_T_ = ' ' "

				cQryAux	+= " INNER JOIN " + cTmpFil+ " TRFIL "
				cQryAux	+= " ON SE2ADTO.E2_FILORIG IN ( SELECT TRFIL.FILIAL FROM " + cTmpFil+ " ) "
				cQryAux	+= " AND SE2ADTO.E2_EMISSAO >= TRFIL.DTINI "
				cQryAux	+= " AND SE2ADTO.E2_EMISSAO <= TRFIL.DTFIM "
				cQryAux	+= " AND SE2ADTO.D_E_L_E_T_ = ' ' "

				cQryAux	+= " LEFT JOIN " + RetSqlName("FVV") + " FVV2 "
				cQryAux	+= " ON FVV_FILIAL = SE2ADTO.E2_FILORIG "
				
				cQryAux	+= " AND ( ( ( FVV_VIGINI = ' ' AND SE2ADTO.E2_EMISSAO >= '" + DTOS(aParamIni[7]) + "' ) OR SE2ADTO.E2_EMISSAO >= FVV_VIGINI ) AND
				cQryAux	+= " ( ( FVV_VIGFIM = ' ' AND SE2ADTO.E2_EMISSAO <= '" + DTOS(aParamIni[8]) + "' ) OR SE2ADTO.E2_EMISSAO <= FVV_VIGFIM ) ) "
				cQryAux	+= " AND SE2ADTO.E2_EMISSAO BETWEEN '" +  DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' "
				cQryAux	+= " AND FVV_CODPES = '" + __cFVUCod + "' AND SE2ADTO.D_E_L_E_T_ = ' ' AND FVV2.D_E_L_E_T_ = ' ' "

				cQryAux	+= " LEFT JOIN " + RetSqlName("FVG") + " FVG ON ( FVG_FILIAL = SE2ADTO.E2_FILORIG "
				cQryAux	+= " AND SE2ADTO.E2_EMISSAO BETWEEN '" + DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' ) "
				cQryAux	+= " AND FVG_CODPES = '" + __cFVUCod + "' "
				cQryAux	+= " AND FVG_TPPES = '1' "
				cQryAux	+= " AND SE2ADTO.D_E_L_E_T_ = ' ' "
				cQryAux	+= " AND FVG.D_E_L_E_T_ = ' ' "

				cQryAux	+= " INNER JOIN " + cTmpBco + " TRBCO "
				cQryAux	+= " ON " + StrTran( CompTab("TRBCO", "FIL", "SE2", cTamSA6), "E2_FILIAL", "SE2ADTO.E2_FILIAL" )
				cQryAux	+= " AND SE5.E5_BANCO = TRBCO.BANCO "
				cQryAux	+= " AND SE5.E5_AGENCIA = TRBCO.AGENCIA "
				cQryAux	+= " AND SE5.E5_CONTA = TRBCO.CONTA "
				
				cQryAux	+= " INNER JOIN " + RetSqlName("SED") + " SED "
				If cTamSED == cTamSE2
					cQryAux	+= " ON ED_FILIAL = E2_FILIAL "
				Else
					If Val(cTamSED) == 0
						cQryAux	+= " ON  ED_FILIAL = ' ' "
					Else
						cQryAux	+= " ON ( SUBSTRING(ED_FILIAL,1, " + cTamSED + ") = SUBSTRING(SE2ADTO.E2_FILORIG,1, " + cTamSED + ")) "
					EndIf				
				EndIf				
				cQryAux	+= " AND ED_CODIGO = SE2ADTO.E2_NATUREZ AND (ED_LCDPR = '1' ) AND SED.D_E_L_E_T_ = ' '  "
				cQryAux	+= " INNER JOIN " + RetSqlName("SA2") + " SA2 "
				
				If cTamSA2 == cTamSE2
					cQryAux	+= " ON A2_FILIAL = SE2ADTO.E2_FILIAL "
				Else
					If Val(cTamSA2) == 0
						cQryAux	+= " ON A2_FILIAL = ' ' "
					Else
						cQryAux	+= " ON SUBSTRING(A2_FILIAL,1, " + cTamSA2 + ") = SUBSTRING(SE2ADTO.E2_FILORIG,1, " + cTamSA2 + ") "
					EndIf
				EndIf
				cQryAux	+= " AND SE2ADTO.E2_FORNECE = A2_COD AND SE2ADTO.E2_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' '
				cQryAux	+= " WHERE SE2ADTO.E2_TIPO IN ('" + MVPAGANT + "') AND "
				cQryAux	+= " SE2ADTO.E2_EMISSAO BETWEEN '" +  DTOS(aParamIni[7]) + "' AND '" + DTOS(aParamIni[8]) + "' "
				cQryAux	+= " AND ED_LCDPR = '1' AND SE2ADTO.D_E_L_E_T_ = ' ' "
			
			ENDIF

			cQuery	+= cQryAux
			cQryAux	:= ""
			cQuery := " SELECT REL.*, 'N' AS LCPRDSN, '' AS OBSACC, ROW_NUMBER() OVER(ORDER BY DIA, MES_ANO) AS RECACC, 0 AS NRECACC, 0 AS NPAGACC, '' AS CNATSLD, 0 AS NSLDACC, '' AS CLINACC FROM ( " + cQuery+" ) AS REL"
			//cQuery += "     WHERE    NUMDOC LIKE '%01082025%'"
			cQuery	+= " ORDER BY DDATA, FILCOD, BANCO, NUMDOC, PREFIXO, PARC, E5_TIPO, TPDOC"
			cQuery	:= ChangeQuery(cQuery)
			MemoWrite("C:\Temp\LCPDR_acc.sql", cQuery)
			
			//Alert("pega a query") 
			//SELECT NA TEMPORARIA
			//Criação do insert into
			cReplace := "INSERT INTO " + oTRB100:GetRealName()
			MemoWrite("C:\Temp\Inter_001",cReplace)

			_cFildRel := cFields
			cReplace += " (" + cFields + ") "
			MemoWrite("C:\Temp\Inter_002",cReplace)
			cReplace += " ( SELECT"
			MemoWrite("C:\Temp\Inter_003",cReplace)
			//COLOCO INSERT INTO NO COMEÇO DA QUERY
			cQuery		:= StrTran( cQuery, "SELECT", cReplace , 1 , 1 )
			MemoWrite("C:\Temp\Inter_004",cReplace)
			//FECHO O PARENTESES PARA AGREGAR O SELECT COM SEUS POSSÝVEIS UNIONS
			cReplace 	:= "ORDER BY  DDATA, FILCOD, BANCO, NUMDOC, PREFIXO, PARC, E5_TIPO, TPDOC"		
			MemoWrite("C:\Temp\Inter_005",cReplace)
			cQuery		:= StrTran( cQuery, cReplace, " ) " + cReplace , 1 , 1 )
			MemoWrite("C:\Temp\Inter_006",cReplace)
			//RETIRO TODOS OS NULL QUE SÃO NUMÉRICOS E COLOCO ZERO NA CRIAÇÃO
			cQuery		:= StrTran( cQuery, "NULL", "0" )
			


			MemoWrite("C:\Temp\LCPDR_INSERT_PADRAO.SQL",cQuery) //AQUI EU PEGO O INSERT
			//If Alltrim(cUserName)=="andre.claro"
				//Alert("Passou por aqui")
			//EndIf
			
			TCSQLEXEC(cQuery)
			cNewTab := "DROP TABLE LCPRD_ACC_2024_01_01  "
			TCSQLEXEC(cNewTab)			

			cNewTab := "SELECT * INTO LCPRD_ACC_2024_01_01 FROM " + oTRB100:GetRealName()

			If __cUserID == "000503"
				//Alert("pega a query na temp")
				Memowrite("C:\Temp\VALIDACAO.SQL", cNewTab)
			EndIf
			TCSQLEXEC(cNewTab)			
			
	EndCase
		
Return				

//------------------------------------------------------------------------------
/*/	{Protheus.doc} TemLCDPR

Verifica configuração do LCDPR

@sample	TemLCDPR(cTipPes)
@return		lRet		 .T. se o LCDPR está configurado corretamente
@author		rafael rondon
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function TemLCDPR() As Logical

	Local lRet As Logical
	
	lRet := .F.

	If AliasInDic('FVU') .AND. AliasInDic('FVV') .AND. AliasInDic('FVG') .AND. AliasInDic('FXV')
		ChkFile("FVV")
		ChkFile("FVU")
		ChkFile("FVG")
		ChkFile("FXV")

		If FWModeAccess("FVV",3) == "E" .AND. FWModeAccess("FVG",3) == "E" .AND. FWModeAccess("FXV",3) == "E"
			lRet := .T.
		Else
			Help(' ',1,STR0001 ,,STR0002,2,0,,,,,,STR0003 ) // 'Compartilhamento Tabelas' ; 'As tabelas FVV e FVG devem ser obrigatoriamente exclusivas' ; 'Favor ajustar as tabelas FVV e FVG para modo totalmente exclusivo no módulo SIGACFG- Configurador'
		EndIf
	ElseIf !IsBlind()	
		Help(" ",1,"DESATUAL",, STR0004, 1, 0,,,,, {STR0005 + CRLF + STR0006}) // Sistema desatualizado para uso do LCDPR. ## Necessária a atualização do sistema ## (dicionário e repositório) para uso dessa rotina.
	EndIf
	
Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} PicCgc

Ajusta picture do campo FVU_CNPJ de acordo com o tipo de Pessoa (F/J)

@sample	PicPes(cTipPes)

@param		cTipPes = Tipo de Pessoa			 

@return	cPict

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function PicCgc(cTipPes As Character) As Character
	Local cPict As Character
	
	cPict := ""
	
	If cTipPes == "1"
		cPict := "@R 999.999.999-99"		
	Else
		If Len(AllTrim(M->FVU_CNPJ)) <> 14
			M->FVU_CNPJ := Space(Len(FVU->FVU_CNPJ))	
		EndIf
		cPict := "@R 99.999.999/9999-99"
	EndIf	
	
	cPict := cPict + "%C"

Return cPict

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CompTab

Tratamento de compartilhamento entre as tabelas

@sample	CompTab()

@param		

@return	

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function CompTab(cAlias As Character, cCampo As Character, cTab As Character, cTamOut As Character) As Character
	Local cCond		As Character
	Local cCpo		As Character
	Local nTamFil	As Numeric
	Local nTam		As Numeric

	Default cTab	:= "SE5"
	Default cTamOut	:= "0"
	
	If cAlias <> "TRBCO"
		nTamFil	:= Val(cTamOut)
	Else
		nTamFil := __nTamFlA6
	EndIf

	If cTab == "SE5"
		cCpo	:= "E5_"
		nTam	:= __nFilSE5
	ElseIf cTab == "SE1"
		cCpo	:= "E1_"
		nTam	:= __nFilSE1
	Else
		cCpo	:= "E2_"
		nTam	:= __nFilSE2
	EndIf

	If nTam	== nTamFil
		cCond	:= cCpo + "FILIAL = " + cCampo
	ElseIf nTam == 0 .Or. nTamFil == 0
		If Val(cTamOut) > 0
			cCond	:= " " + cCampo + " = SUBSTRING(" + cCpo	+ "FILORIG, 1, " + cTamOut + ") "
		Else
			cCond	:= " " + cCampo + " = ' ' "
		EndIf
	ElseIf nTam > nTamFil
		If "MSSQL" $ __cDBName 
			cCond	:= " SUBSTRING(" + cCpo	+ "FILIAL, 1, " + cTamOut + ") = " + cCampo + " "
		Else
			cCond	:= " SUBSTRING(" + cCpo	+ "FILIAL, 1, " + cTamOut + ") = " + cCampo + " "
		EndIf
	ElseIf cTab == "SE5" .And. ( nTam < nTamFil ) .And.  cAlias $ "SE1|SE2" // Caso SE1 e SE2 menos compartilhada que a SE5
		cCond	:= " " + cCampo + " = SUBSTRING(" + cCpo	+ "FILORIG, 1, " + cTamOut + ") "
	Else
		If "MSSQL" $ __cDBName
			cCond	:= " SUBSTRING(" + cCampo + ", 1, " + Str(nTam) + ") = " + cCpo	+ "FILIAL "
		Else
			cCond	:= " SUBSTRING(" + cCampo + ", 1, " + Str(nTam) + ") = " + cCpo + "FILIAL "
		EndIf
	EndIf
	
Return cCond

//------------------------------------------------------------------------------
/*/	{Protheus.doc} GetVerLCD

Define a versão do Leiaute do LCDPR

@sample	GetVerLCD()

@param		

@return	cVersion = versão do leiaute do arquivo LCDPR

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function GetVerLCD() As Character
	Local cVersion As Character
	
	cVersion	:= "1.3"
	
Return cVersion

//------------------------------------------------------------------------------
/*/	{Protheus.doc} FormatDt
Formata as datas recebidas do Wizard

@sample	FormatDt()

@param		

@return	cRet = data formatada e convertida em caracter

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function FormatDt( dData As Date) As Character
	Local cRet As Character
	
	cRet 	:= DtoS(dData)
	cRet	:= SubStr(cRet, 7, 2) + SubStr(cRet, 5, 2) + SubStr(cRet, 1, 4) 
	
Return cRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} ModeAccess
Verifica o modo de acesso da tabela e retorna o um caracter com o tamanho
do campo filial

@sample	ModeAccess()

@param		

@return	cTam = Tamanho do campo filial

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function ModeAccess(cTab As Character, nTamEmp As Numeric, nTamUnN As Numeric)
	Local cTam As Character
	
	If FwModeAccess( cTab, 3 ) == "E"
		cTam	:= Str(Len(FwSM0LayOut()))
	ElseIf FwModeAccess( cTab, 1 ) == "C"
		cTam	:= "0"
	ElseIf FwModeAccess( cTab, 2 ) == "E"
		cTam := Str( nTamEmp + nTamUnN )
	Else	
		cTam := Str( nTamEmp )
	EndIf

Return cTam

//------------------------------------------------------------------------------
/*/	{Protheus.doc} ZeraStatic()
Reseta o valor das Variáveis estáticas

@sample	ZeraStatic()

@param		

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function ZeraStatic()

	__cArq		:= ""
	__cDir		:= ""
	__lPrinted	:= .F.
	__cCpf		:= ""
	__cTmpFVV	:= ""
	__cTmpFVG	:= ""
	__cTmpCVB	:= ""
	__lF820Qry	:= .F.
	__lF820Reg	:= .F.
	__lF820Bco	:= .F.
	__lImpHist	:= .F.
	
	If __oTmpFil <> Nil
		__oTmpFil:Delete()
		__oTmpFil := Nil
	EndIf
		
	If __oTmpBco <> Nil
		__oTmpBco:Delete()
		__oTmpBco := Nil
	EndIf

	If __oTSlCred <> Nil
		__oTSlCred:Delete()
		__oTSlCred := Nil
	EndIf
			
	__nFilSE5	:= Nil
	__nFilSE1	:= Nil
	__nFilSE2	:= Nil
	__aTpReg	:= {}
	__aTpReg	:= Nil
	
Return

//------------------------------------------------------------------------------
/*/	{Protheus.doc} FilCompl()
Verifica se a filial tem complemento

@param cCodigo - código da filial

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function FilCompl(cCodigo As Character) As Numeric
	Local cQuery	As Character
	Local nRet		As Numeric

	Default cCodigo := " "

	cQuery 	:= " Select Count(FXV_FILIAL) AS FIL From " + RetSqlName("FXV") + " FXV "
	cQuery	+= " Where FXV_CODIGO = '" + cCodigo + "' And FXV.D_E_L_E_T_ = ' ' " 
     
    nRet	:= MpSysExecScalar(cQuery,"FIL")

Return nRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} FTemChq()
Verifica se há cheque compensado para o registro

@param cBanco - código do banco do cheque
@param cAgencia - código da agencia do banco
@param cConta - código da conta do banco
@param cCheque - número do cheque a ser buscado

@return lRet - se existe cheque compensado (.T.) ou não

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function FTemChq(cFil As Character, cBanco As Character, cAgencia As Character, cConta As Character, cCheque As Character) As Logical
	Local cQuery	As Character
	Local nRet		As Numeric
	Local aArea		As Array
	Local aAreaSE5	As Array
		
	Default cBanco 		:= ""
	Default cAgencia	:= ""
	Default cConta 		:= ""
	Default cCheque		:= ""
	Default cFil		:= ""

	If __nLOEmp == Nil
		__nLOEmp	:= Len(FWSM0LayOut(,1))
	EndIf
	If __nLOUnN	== Nil
		__nLOUnN := Len(FWSM0LayOut(,2))
	EndIf
	If __nLOFil == Nil
		__nLOFil	:= Len(FWSM0LayOut(,3))
	EndIf

	If __cTamSE5 == Nil
		__cTamSE5	:= ModeAccess( "SE5", __nLOEmp, __nLOUnN, __nLOFil )
	EndIf
	If __cTamSEF == Nil
		__cTamSEF	:= ModeAccess( "SEF", __nLOEmp, __nLOUnN, __nLOFil )
	EndIf
	If __lLibChq == Nil
		__lLibChq	:= SuperGetMV("MV_LIBCHEQ",,'S') == "N"
	EndIf
	
	If __lLibChq .And. Empty(AllTrim(cCheque))
		nRet := 0
	Else
		aArea		:= GetArea()
		aAreaSE5	:= SE5->(GetArea()) 

		If __oTmpCheq == Nil
			cQuery 	:= " Select Count(EF_FILIAL) AS FIL "
			cQuery 	+= " From " + RetSqlName("SE5") + " SE5 "
			cQuery 	+= " INNER JOIN " + RetSqlName("SEF") + " SEF "

			If __cTamSE5 == __cTamSEF
				cQuery	+= " ON EF_FILIAL = E5_FILIAL "
			ElseIf Val(__cTamSEF) == 0
				cQuery	+= " ON EF_FILIAL = ' ' "
			ElseIf Val(__cTamSE5) > Val(__cTamSEF)
				cQuery	+= " ON SUBSTRING(EF_FILIAL,1, " + __cTamSEF + ") = SUBSTRING(E5_FILIAL,1, " + __cTamSEF + ") "
			Else
				cQuery	+= " ON SUBSTRING(EF_FILIAL,1, " + __cTamSEF + ") = SUBSTRING(E5_FILORIG,1, " + __cTamSEF + ") "
			EndIf
			
			cQuery 	+= " AND E5_NUMCHEQ = EF_NUM "
			cQuery 	+= " AND E5_BANCO = EF_BANCO "
			cQuery 	+= " AND E5_AGENCIA = EF_AGENCIA "
			cQuery 	+= " AND E5_CONTA = EF_CONTA "
			cQuery	+= " Where E5_FILIAL = ? "
			cQuery	+= " And E5_BANCO = ? "
			cQuery	+= " And E5_AGENCIA = ? "
			cQuery	+= " And E5_CONTA = ? "
			cQuery	+= " And E5_NUMCHEQ = ? "
			If __lLibChq
				cQuery	+= " And EF_LIBER = 'S' "
			EndIf
			cQuery	+= " And SE5.D_E_L_E_T_ = ' ' " 
			cQuery	+= " And SEF.D_E_L_E_T_ = ' ' " 
			
			cQuery	:= ChangeQuery(cQuery)

			__oTmpCheq :=FWPreparedStatement():New(cQuery)
				
		EndIf

		__oTmpCheq:SetString(1,cFil)
		__oTmpCheq:SetString(2,cBanco)
		__oTmpCheq:SetString(3,cAgencia)
		__oTmpCheq:SetString(4,cConta)
		__oTmpCheq:SetString(5,cCheque)
		cQuery := __oTmpCheq:GetFixQuery()
			
		nRet	:= MpSysExecScalar(cQuery,"FIL")

		RestArea(aAreaSE5)
		RestArea(aArea)
	EndIf

Return ( nRet > 0 )

//------------------------------------------------------------------------------
/*/	{Protheus.doc} ValBruNf()
Função para buscar o valor bruto da nota

@param cCart	- Carteira do título
@param cFil		- Filail do título
@param cPref	- Prefixo do título
@param cNumDoc	- Número do documento
@param cParc	- Parcela do título
@param cTipo	- Tipo do título
@param cCliFor	- Cliente / Fornecedor do título
@param cLoja	- Loja do cliente / fornecedor

@return nVlBrut - Valor Bruto da nota

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function ValBruNf(cCart As Character, cFil As Character, cPref As Character, cNumDoc As Character, cParc As Character, cTipo As Character, cCliFor As Character, cLoja As Character, nRecSF12 As Numeric, nVBRUT12 as Numeric, nVSENA12 as Numeric, nVINSS12 as Numeric, nCOSOC12 as Numeric ) As Numeric
		// TRB100->SEFIL, TRB100->PREFIXO, TRB100->NUMDOC, TRB100->PARC, TRB100->E5_TIPO, TRB100->CLIFOR, TRB100->LOJA, Empty(TRB100->REC)

	Local aArea		As Array
	Local aOtim		As Array
	Local nVlBrut 	As Numeric
	Local nPropBx 	As Numeric
	Local nVlFun	As Numeric
	Local nParcs	As Numeric
	Local nVlCtSq	As Numeric
	Local nVlIns	As Numeric
	Local nValDevol	As Numeric
	Local cAlias	As Character
	Local lNota		As Logical
	Local lChgFil	As Logical
	Local lDescSen	As Logical

	aArea		:= GetArea()
	cAlias		:= ""
	aOtim		:= {}
	nVlBrut		:= 0
	nPropBx		:= 1
	nVlFun		:= 0
	nVlCtSq		:= 0
	nVlIns		:= 0
	nMtImp		:= 0
	nValDevol	:= 0
	nParcs		:= 1
	lNota		:= .F.
	lChgFil		:= .F.
	lDescSen	:= .F.

	If !__lF820Qry  .Or. (__lF820Qry .And. ( Empty(TRB100->CODEMP) .Or. (!Empty(TRB100->CODEMP) .And. cEmpAnt == TRB100->CODEMP ) ) )
		If cCart == 'R'
			cAlias	:= "SF2"
			If !Empty(nRecSF12)
				If ( ( lDescSen := TRB100->E1_VLCRUZ <> nVBRUT12 ) .Or. ( ( nVSENA12 + nVINSS12 + nCOSOC12 ) > 0 ) )
					If cFilAnt <> cFil
						__cFlAntOd	:= cFilAnt
						cFilAnt		:= cFil
						lChgFil		:= .T.
					EndIf

					IF EMPTY(TRB100->NFTOTAL)

						MaFisIniNF(2,nRecSF12,@aOtim)

						nVlBrut		:= MaFisRet(, "NF_TOTAL")
						nVlCtSq		:= MaFisRet(, "NF_FUNRURAL")
						nVlFun		:= MaFisRet(, "NF_VLSENAR")
						nVlIns		:= MaFisRet(, "NF_VALINS")

						nMtImp		:= MaFisRet(, "NF_VALFAC")
						nMtImp		+= MaFisRet(, "NF_VALFET")
						nMtImp		+= MaFisRet(, "NF_VALFETR")
						nMtImp		+= MaFisRet(, "NF_VALFAB")
						
						cQuery := "UPDATE " + oTRB100:GetRealName()
						cQuery += " SET NFTOTAL = " + CVALTOCHAR(nVlBrut)
						cQuery += ", FUNRURAL = " + CVALTOCHAR(nVlCtSq)
						cQuery += ", VLSENAR = " + CVALTOCHAR(nVlFun)
						cQuery += ", VALINS = " + CVALTOCHAR(nVlIns)
						cQuery += ", VLFETFAC = " + CVALTOCHAR(nMtImp)
						cQuery += " WHERE RECSF12 = " + CVALTOCHAR(nRecSF12) 

						TCSQLEXEC( cQuery )

					ELSE

						nVlBrut		:= TRB100->NFTOTAL
						nVlCtSq		:= TRB100->FUNRURAL
						nVlFun		:= TRB100->VLSENAR
						nVlIns		:= TRB100->VALINS
						nMtImp		:= TRB100->VLFETFAC

					ENDIF

					__lFunrural := ( nVlFun + nVlCtSq ) > 0
					__nVlFun	:= nVlFun
					lNota		:= .T.
					__lNftot	:= TRB100->SLDREC == 0 .And. NumBaixas() == 1
					If lChgFil
						cFilAnt		:= __cFlAntOd
					EndIf
				Else
					nVlBrut := TRB100->VALOR
				EndIf
			Else
				nVlBrut := TRB100->VALOR
			EndIf	
		Else
			cAlias	:= "SF1"
			If !EMPTY(nRecSF12)
				If ( ( lDescSen := TRB100->E2_VLCRUZ <> nVBRUT12 ) .Or. ( nVSENA12 + nVINSS12 + nCOSOC12 ) > 0 )
					If cFilAnt <> cFil
						__cFlAntOd	:= cFilAnt
						cFilAnt		:= cFil
						lChgFil		:= .T.
					EndIf

					IF EMPTY(TRB100->NFTOTAL)

						MaFisIniNF(1,nRecSF12,@aOtim)

						nVlBrut		:= MaFisRet(, "NF_TOTAL")
						nVlCtSq		:= MaFisRet(, "NF_FUNRURAL")
						nVlFun		:= MaFisRet(, "NF_VLSENAR")
						nVlIns		:= MaFisRet(, "NF_VALINS")

						nMtImp		:= MaFisRet(, "NF_VALFAC")
						nMtImp		+= MaFisRet(, "NF_VALFET")
						nMtImp		+= MaFisRet(, "NF_VALFETR")
						nMtImp		+= MaFisRet(, "NF_VALFAB")

						cQuery := "UPDATE " + oTRB100:GetRealName()
						cQuery += " SET NFTOTAL = " + CVALTOCHAR(nVlBrut)
						cQuery += ", FUNRURAL = " + CVALTOCHAR(nVlCtSq)
						cQuery += ", VLSENAR = " + CVALTOCHAR(nVlFun)
						cQuery += ", VALINS = " + CVALTOCHAR(nVlIns)
						cQuery += ", VLFETFAC = " + CVALTOCHAR(nMtImp)
						cQuery += " WHERE RECSF12 = " + CVALTOCHAR(nRecSF12) 

						TCSQLEXEC( cQuery )
						
					ELSE

						nVlBrut		:= TRB100->NFTOTAL
						nVlCtSq		:= TRB100->FUNRURAL
						nVlFun		:= TRB100->VLSENAR
						nVlIns		:= TRB100->VALINS
						nMtImp		:= TRB100->VLFETFAC

					ENDIF

					__lFunrural := ( nVlFun + nVlCtSq ) > 0
					__nVlFun	:= nVlFun
					lNota		:= .T.
					__lNftot	:= TRB100->SLDPAG == 0 .And. NumBaixas() == 1
					If lChgFil
						cFilAnt		:= __cFlAntOd
					EndIf
				Else
					nVlBrut := TRB100->VALOR
				EndIf
			Else
				nVlBrut := TRB100->VALOR
			EndIf
		EndIf
		__nAbtNF := nVlCtSq + Iif(!lDescSen, nVlFun, 0) + nVlIns + nMtImp
	Else
		nVlBrut := TRB100->VALOR
	EndIf
	
	__nVlNota	:= nVlBrut
	If ( nParcs	:= QtdeParc(cCart, cFil) ) > 1 .And. lNota
		nVlBrut 	:= nVlBrut / nParcs
	EndIf
	If  (     lDescSen .Or. ( ( nVlFun + nVlCtSq + nVlIns + nMtImp) > 0 )   ) .and. 1 ==2
		nPropBx		:= TRB100->VALOR / ( ( nVlBrut - ( nValDevol := SldCred()) ) - ( ( nVlFun + nVlCtSq + nVlIns + nMtImp) / nParcs ) )
	Else
		nPropBx		:= TRB100->VALOR / nVlBrut
	EndIf
	__nPropBx	:= nPropBx
	If nParcs > 1 .Or. lNota
		__nVlFun	:= (nVlFun / nParcs ) * __nPropBx
	EndIf
	If __lFunRural
		If cCart == "R"
			If TRB100->E1_VLCRUZ <> nVBRUT12
				If nParcs > 1 .Or. lNota
					nVlBrut		:= ( nVlBrut - nValDevol ) * nPropBx
				Else
					nVlBrut		:= TRB100->VALOR / nPropBx
				End
			Else
				nVlBrut		:= ( nVlBrut - nValDevol ) * nPropBx
			EndIf
		Else
			If TRB100->E2_VLCRUZ <> nVBRUT12
				If nParcs > 1 .Or. lNota
					nVlBrut		:= ( nVlBrut - nValDevol ) * nPropBx
				Else
					nVlBrut		:= TRB100->VALOR / nPropBx
				EndIf
			Else
				nVlBrut		:= ( nVlBrut - nValDevol ) * nPropBx
			EndIf
		EndIf
	Else
		If nParcs > 1 .Or. lNota
			nVlBrut		:= ( nVlBrut - ( nVlFun + nVlCtSq + nVlIns ) ) * nPropBx
		Else
			nVlBrut		:= TRB100->VALOR / nPropBx
		EndIf
	EndIf
	If __nVlNota > 0 .And. nVlBrut > __nVlNota .AND. !(SE5->E5_MOTBX = "CEC" .AND. SE5->E5_VLJUROS > 0 .AND. SE5->E5_RECPAG = 'R')
		nVlBrut		:= __nVlNota
	EndIf
		
	RestArea(aArea)

Return nVlBrut

//------------------------------------------------------------------------------
/*/	{Protheus.doc} RotOri()
Função para buscar o valor bruto da nota

@param cCart	- Carteira de origem do título
@param cFil		- Filial do título
@param cPref	- Prefixo do título
@param cNumDoc	- Núremo do documento
@param cParc	- Número da parcela
@param cTipo	- Tipo do documento
@param cCliFor	- Cliente / Fornecedor do título
@param cLoja	- Loja do cliente / fornec.

@return array 	- { rotina de origem do título, filial de origem }

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function RotOri(cCart As Character, cFil As Character, cPref As Character, cNumDoc As Character, cParc As Character, cTipo As Character, cCliFor As Character, cLoja As Character) As Character
	Local aArea 	As Array
	Local aAreaSE	As Array
	Local aAreaSE5	As Array
	Local cRotina	As Character
	
	aArea		:= GetArea()
	aAreaSE		:= {}
	aAreaSE5	:= {}
	cRotina		:= ""

	If !__lF820Qry .Or. (__lF820Qry .And. ( Empty(TRB100->CODEMP) .Or. (!Empty(TRB100->CODEMP) .And. cEmpAnt == TRB100->CODEMP ) ) )
		__cFilOri	:= SubStr(Posicione("SE5", 7, cFil + cPref + cNumDoc + cParc + cTipo + cCliFor + cLoja, "E5_FILORIG") , 1,Len(cFil))
		If cCart == 'R'
			aAreaSE5	:= SE5->(GetArea())
			__cFilOri	:= SubStr(Posicione("SE5", 7, cFil + cPref + cNumDoc + cParc + cTipo, "E5_FILORIG") , 1, Len(cFil))
			__nTxMoeda	:= SE5->E5_TXMOEDA
			RestArea(aAreaSE5)
		
			aAreaSE	:= SE1->(GetArea())
			DbSelectArea("SE1")
			DbSetOrder(1)
			DbGoTop()
			If Len(AllTrim(cFil)) == 0 .Or. __nFilSE1 <> __nFilSE5 .Or. Len(AllTrim(cFil)) < __nFilSE1
				cFil	:= __cFilOri
			EndIf
			SE1->(DbSeek(PadR(SubStr(cFil,1,__nFilSE1), Len(cFil), " ") + cPref + cNumDoc + cParc + cTipo))
			cRotina	:= SE1->E1_ORIGEM
			RestArea(aAreaSE)
		Else
			aAreaSE5	:= SE5->(GetArea())
			__cFilOri	:= SubStr(Posicione("SE5", 7, cFil + cPref + cNumDoc + cParc + cTipo + cCliFor + cLoja, "E5_FILORIG") , 1,Len(cFil))
			__nTxMoeda	:= SE5->E5_TXMOEDA
			RestArea(aAreaSE5)
		
			aAreaSE	:= SE2->(GetArea())
			DbSelectArea("SE2")
			DbSetOrder(1)
			DbGoTop()
			If Len(AllTrim(cFil)) == 0 .Or. __nFilSE1 <> __nFilSE5 .Or. Len(AllTrim(cFil)) < __nFilSE2
				cFil	:= __cFilOri
			EndIf
			SE2->(DbSeek(PadR(SubStr(cFil,1,__nFilSE2), Len(cFil), " ") + cPref + cNumDoc + cParc + cTipo + cCliFor + cLoja))
			cRotina	:= SE2->E2_ORIGEM
			RestArea(aAreaSE)
		EndIf
	EndIf

	RestArea(aArea)

Return { AllTrim(cRotina), __cFilOri }

//------------------------------------------------------------------------------
/*/	{Protheus.doc} QtdeParc()
Função para buscar a qtde de parcelas na nota

@param cCart	- Define se carteira a pagar ou receber
@param cFil		- Filial do título

@return nParc - Número de parcelas do título

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function QtdeParc(cCart As Character, cFil As Character) As Numeric
	Local nParc		As Numeric
	Local aArea		As Array
	Local cAlias	As Array
	Local cFilSE	As Character
	
	nParc	:= 1
	aArea	:= {}
	cAlias	:= GetNextAlias()

	If cCart == 'R'
		aArea	:= SE1->(GetArea())
		cFilSE	:= SubStr(cFil,1,__nFilSE1)
		If __nFilSE1 == 0
			cFilSE	:= " "
		EndIf
		BeginSql Alias cAlias
			Select count(E1_NUM) QTDE
			From %Table:SE1% SE1
			Where E1_FILIAL 	= %exp:cFilSE%
				And E1_PREFIXO 	= %exp:TRB100->PREFIXO%
				And E1_NUM 		= %exp:TRB100->NUMDOC%
				And E1_TIPO		= %exp:TRB100->E5_TIPO%
				And SE1.%NotDel%
			Group By E1_NUM
		EndSql
	Else
		aArea	:= SE2->(GetArea())
		cFilSE	:= SubStr(cFil,1,__nFilSE2)
		If __nFilSE2 == 0
			cFilSE	:= " "
		EndIf
		BeginSql Alias cAlias
			Select count(E2_NUM) QTDE
			From %Table:SE2% SE2
			Where E2_FILIAL 	= %exp:cFilSE%
				And E2_PREFIXO 	= %exp:TRB100->PREFIXO%
				And E2_NUM 		= %exp:TRB100->NUMDOC%
				And E2_TIPO		= %exp:TRB100->E5_TIPO%
				And E2_FORNECE	= %exp:TRB100->CLIFOR%
				And E2_LOJA		= %exp:TRB100->LOJA%
				And SE2.%NotDel%
			Group By E2_NUM
		EndSql
	EndIf

	nParc	:= (cAlias)->QTDE
	(cAlias)->(DbCloseArea())
	RestArea(aArea)

Return If( nParc == 0, 1, nParc )

//------------------------------------------------------------------------------
/*/	{Protheus.doc} BcoAdto()
Função para buscar o banco do adiantamento compensado

@return cBco - Banco do adiantamento

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function BcoAdto() As Character
	Local cBco 		As Character
	Local cQry		As Character
	Local cTrbBcAdt	As Character
	Local cTmpBco	As Character
	
	cTmpBco		:= __oTmpBco:GetRealName()
	
	cBco 		:= '999'
	cQry		:= ""
	cTrbBcAdt	:= "BCOADT"

	If TRB100->RECPAG == 'R'
		cQry	:= " Select BCORA.COD, E5_MOTBX MOTBX, E5_MOEDA MOEDA "
		cQry	+= " From " + RetSqlName("SE5") + " SE5 "
		cQry	+= " Left Join " + cTmpBco + " BCORA "
		cQry	+= " ON E5_BANCO = BCORA.BANCO AND E5_AGENCIA = BCORA.AGENCIA AND E5_CONTA = BCORA.CONTA "
		If TRB100->E5_TIPO $ MVRECANT
			cQry	+= " Where E5_FILIAL = '" + TRB100->SEFIL + "' AND E5_TIPO = '" + TRB100->E5_TIPO + "' "
			cQry	+= " AND E5_PREFIXO = '" + TRB100->PREFIXO + "' AND E5_NUMERO = '" + TRB100->NUMDOC + "' "
			cQry	+= " AND E5_PARCELA = '" + TRB100->PARC + "' AND E5_BANCO != ' ' "
			cQry	+= " AND E5_CLIFOR = '" + TRB100->CLIFOR + "' AND E5_LOJA = '" + TRB100->LOJA + "' "
		Else
			cQry	+= " Where E5_FILIAL = '" + TRB100->SEFIL + "' AND E5_BANCO != ' ' "
			cQry	+= " AND E5_PREFIXO || E5_NUMERO || E5_PARCELA || E5_TIPO || E5_LOJA IN ( "
			cQry	+= " Select SE5A.E5_PREFIXO || SE5A.E5_NUMERO || SE5A.E5_PARCELA || SE5A.E5_TIPO || SE5A.E5_LOJA "
			cQry	+= " From " + RetSqlName("SE5") + " SE5A "
			cQry	+= " Where SE5A.E5_FILIAL = '" + TRB100->SEFIL + "' AND SE5A.E5_DOCUMEN = '" + TRB100->PREFIXO + TRB100->NUMDOC + TRB100->PARC + TRB100->E5_TIPO + TRB100->LOJA + "' "
			cQry	+= " AND SE5A.D_E_L_E_T_ = ' ' ) 	"
		EndIf
		cQry	+= " AND SE5.D_E_L_E_T_ = ' ' "
	Else
		cQry	:= " Select BCOPA.COD, E5_MOTBX MOTBX, E5_MOEDA MOEDA "
		cQry	+= " From " + RetSqlName("SE5") + " SE5 "
		cQry	+= " Left Join " + cTmpBco + " BCOPA "
		cQry	+= " ON E5_BANCO = BCOPA.BANCO AND E5_AGENCIA = BCOPA.AGENCIA AND E5_CONTA = BCOPA.CONTA "
		If TRB100->E5_TIPO $ MVPAGANT
			cQry	+= " Where E5_FILIAL = '" + TRB100->SEFIL + "' AND E5_TIPO IN " + FormatIn(MVPAGANT, "|") + " "
			cQry	+= " AND E5_PREFIXO = '" + TRB100->PREFIXO + "' AND E5_NUMERO = '" + TRB100->NUMDOC + "' "
			cQry	+= " AND E5_PARCELA = '" + TRB100->PARC + "' AND E5_BANCO != ' ' "
			cQry	+= " AND E5_CLIFOR = '" + TRB100->CLIFOR + "' AND E5_LOJA = '" + TRB100->LOJA + "' "
		Else
			cQry	+= " Where E5_FILIAL = '" + TRB100->SEFIL + "' AND E5_BANCO != ' ' "
			cQry	+= " AND E5_PREFIXO || E5_NUMERO || E5_PARCELA || E5_TIPO || E5_CLIFOR || E5_LOJA IN ( "
			cQry	+= " Select SE5A.E5_PREFIXO || SE5A.E5_NUMERO || SE5A.E5_PARCELA || SE5A.E5_TIPO || SE5A.E5_CLIFOR || SE5A.E5_LOJA "
			cQry	+= " From " + RetSqlName("SE5") + " SE5A "
			cQry	+= " Where SE5A.E5_FILIAL = '" + TRB100->SEFIL + "' AND SE5A.E5_DOCUMEN = '" + TRB100->PREFIXO + TRB100->NUMDOC + TRB100->PARC + TRB100->E5_TIPO + TRB100->CLIFOR + TRB100->LOJA + "' "
			cQry	+= " AND SE5A.D_E_L_E_T_ = ' ' ) "
		EndIf
		cQry	+= " AND SE5.D_E_L_E_T_ = ' ' "
	EndIf

	cQry	:= ChangeQuery(cQry)
	
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cTrbBcAdt, .F., .T.)

	If !Empty((cTrbBcAdt)->COD)
		cBco 	:= (cTrbBcAdt)->COD
	ElseIf (cTrbBcAdt)->MOTBX == 'ESP' .OR. (cTrbBcAdt)->MOEDA == 'R$'
		cBco	:= "000"
	Else
		cBco	:= "999"
	EndIf
	(cTrbBcAdt)->(DbCloseArea())

Return cBco

//------------------------------------------------------------------------------
/*/	{Protheus.doc} NumBaixas()
Função para buscar a qtde de baixas válidas do título

@return nBaixas - Qtde de baixas válidas do título

@author	Rodrigo Oliveira  	
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function NumBaixas() As Numeric
	Local nBaixas	As Numeric
	Local cQry		As Character
	Local cTrbBxs	As Character
	
	cQry	:= ""
	cTrbBxs	:= "TRBBXS"
	nBaixas	:= 0
	
	cQry	:= " Select Count(E5_NUMERO) QTDBX "
	cQry	+= " From " + RetSqlName("SE5") + " SE5 "
	cQry	+= " Where E5_FILIAL = '" + TRB100->SEFIL + "' AND E5_TIPO = '" + TRB100->E5_TIPO + "' "
	cQry	+= " AND E5_PREFIXO = '" + TRB100->PREFIXO + "' AND E5_NUMERO = '" + TRB100->NUMDOC + "' "
	cQry	+= " AND E5_CLIFOR = '" + TRB100->CLIFOR + "' AND E5_LOJA = '" + TRB100->LOJA + "' "
	cQry	+= " And E5_SITUACA NOT IN ('C','E','X') AND NOT EXISTS ( "
	cQry	+= " 	SELECT SE5ES.E5_NUMERO "
	cQry	+= " 		FROM " + RetSqlName("SE5") + " SE5ES "
	cQry	+= " 	    	WHERE SE5ES.E5_FILIAL  = SE5.E5_FILIAL "
	cQry	+= " 	    		AND SE5ES.E5_PREFIXO = SE5.E5_PREFIXO "
	cQry	+= " 				AND SE5ES.E5_NUMERO  = SE5.E5_NUMERO "
	cQry	+= " 				AND SE5ES.E5_NUMCHEQ = ' ' "
	cQry	+= " 		   		AND SE5ES.E5_PARCELA = SE5.E5_PARCELA "
	cQry	+= " 		   		AND SE5ES.E5_TIPO    = SE5.E5_TIPO "
	cQry	+= " 				AND SE5ES.E5_CLIFOR  = SE5.E5_CLIFOR " 
	cQry	+= " 		   		AND SE5ES.E5_LOJA    = SE5.E5_LOJA "
	cQry	+= " 				AND SE5ES.E5_SEQ     = SE5.E5_SEQ "
	cQry	+= " 		        AND SE5ES.E5_BANCO   = SE5.E5_BANCO " 
	cQry	+= " 		        AND SE5ES.E5_AGENCIA = SE5.E5_AGENCIA " 
	cQry	+= " 		        AND SE5ES.E5_CONTA   = SE5.E5_CONTA "
	cQry	+= " 		        AND SE5ES.E5_TIPODOC = 'ES' "
	cQry	+= " 		        AND SE5ES.E5_ORIGEM <> 'FINA100 ' AND SE5ES.E5_KEY NOT LIKE '%PA%' "
	cQry	+= "		        AND SE5ES.D_E_L_E_T_ = ' ' ) "
	cQry	+= " 	AND SE5.D_E_L_E_T_ = ' ' "

	cQry	:= ChangeQuery(cQry)
	
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cTrbBxs, .F., .T.)

	If !Empty((cTrbBxs)->QTDBX)
		nBaixas 	:= (cTrbBxs)->QTDBX
	EndIf
	(cTrbBxs)->(DbCloseArea())

Return nBaixas

//------------------------------------------------------------------------------
/*/	{Protheus.doc} Fn820Abat()
Função para identificar se o título é abatimento.

@param cCart	- Define se carteira a pagar ou receber
@param cFil		- Filial do título

@return lRet - Retorna se é um abatimento

@author	Simone Mie Sato Kakinoana
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function Fn820Abat(cCart As Character, cTipo As Character) As Logic

Local lRet As Logical

If cCart == "P"
	lRet := cTipo $ "|TX |TXA|AB-|IR-|" + MVPAGANT 
Else	
	lRet := cTipo $  "|TX |TXA|AB-|FB-|FC-|FU-|FE-|IN-|IS-|AB-|PIS|COF|CSL|CF-|CS-|INS|IRF|PI- |"+MVRECANT+"|" +MV_CRNEG
EndIf

Return(lRet)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} FMoedTit()
Função para verificar se a moeda do título é igual a do banco.

@param cMoeda	- Moeda do banco da movimentação
@param cFilOri	- Filial de origem do título
@param nVlCruz	- Variável com o valor em reais

@return lRet - Retorna se a moeda é igual

@author	Rodrigo.oliveira
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function FMoedTit(cMoeda As Character, cFilOri As Character, nVlCruz As Numeric) As Logical

	Local lRet	:= .F.
	Local aArea := {}
	Local nMoed	:= 0
	
	__nDecs := MsDecimais(Val(cMoeda))

	If TRB100->RECPAG == 'R'
		nMoed	:= Val(cMoeda)
		aArea 	:= SE1->(GetArea())
		SE1->(DbSetOrder(1))
		If SE1->(DbSeek(xFilial("SE1", cFilOri) + TRB100->PREFIXO + TRB100->NUMDOC + TRB100->PARC + ;
			TRB100->E5_TIPO) )
			If nMoed == SE1->E1_MOEDA
				nVlCruz := xMoeda(TRB100->VALOR,nMoed,1,TRB100->DDATA,__nDecs + 1,If(__nTxMoeda > 1, __nTxMoeda, If( SE1->E1_TXMOEDA <> 0, SE1->E1_TXMOEDA, RecMoeda(TRB100->DDATA,nMoed))) )
				lRet	:= .T.
			EndIf
		EndIf
		RestArea(aArea)
	ElseIf TRB100->RECPAG == 'P'
		nMoed	:= Val(cMoeda)
		aArea 	:= SE2->(GetArea())
		SE2->(DbSetOrder(1))
		If SE2->(DbSeek(xFilial("SE2", cFilOri) + TRB100->PREFIXO + TRB100->NUMDOC + TRB100->PARC + ;
			TRB100->E5_TIPO + TRB100->CLIFOR + TRB100->LOJA) )
			If nMoed == SE2->E2_MOEDA
				nVlCruz := xMoeda(TRB100->VALOR,nMoed,1,TRB100->DDATA,__nDecs + 1,If(__nTxMoeda > 1, __nTxMoeda, If( SE2->E2_TXMOEDA <> 0, SE2->E2_TXMOEDA, RecMoeda(TRB100->DDATA,nMoed))) )
				lRet	:= .T.
			EndIf
		EndIf
		RestArea(aArea)
	EndIf 

Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} SldCred()
Função para retornar saldo das devoluções / Compensação com NCC e NDF

@return nValRet - Valor devolvido da nota

@author	Rodrigo.oliveira
@version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function SldCred() As Numeric
	Local aStrCrd 	As Array
	Local nValRet	As Numeric
	Local cRepl		As Character
	Local cDocumen 	As Character
	Local cQuery	As Character

	aStrCrd		:= {}
	nValRet		:= 0
	cRepl		:= ""
	cDocumen	:= ""
	cQuery		:= ""

	If __oTSlCred == Nil
		aAdd(aStrCrd, {'DOCUMEN', 'C', TAMSX3("E5_DOCUMEN")[1],0})
		aAdd(aStrCrd, {'SLDCRED', 'N', TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]})
		
		__oTSlCred := FwTemporaryTable():New( 'TRCRED' )
		__oTSlCred:SetFields(aStrCrd)
		__oTSlCred:AddIndex('1', {'DOCUMEN'})
			
		__oTSlCred:Create()
	EndIf
		
	If TRB100->RECPAG == 'R'
		cDocumen	:= TRB100->(PREFIXO + NUMDOC + PARC + E5_TIPO + LOJA)
	ElseIf TRB100->RECPAG == 'P'
		cDocumen	:= TRB100->(PREFIXO + NUMDOC + PARC + E5_TIPO + CLIFOR + LOJA)
	EndIf

	If TRCRED->(DbSeek(cDocumen))
		nValRet := TRCRED->SLDCRED
	Else
		If TRB100->RECPAG == 'R'
			If __oCredRec == NIL
				cQuery := "SELECT E5_DOCUMEN, SUM(E5_VALOR) SLDCRED"
				cQuery += " FROM " + RetSqlName('SE5') + " SE5"
				cQuery += " WHERE"
				cQuery += " E5_DOCUMEN = ? AND"
				cQuery += " E5_TIPO IN " + FormatIn(MV_CRNEG,'|') + " AND"
				cQuery += " SE5.D_E_L_E_T_ = ' '"
				cQuery += " GROUP BY E5_DOCUMEN"
				
				cQuery := ChangeQuery(cQuery)
				__oCredRec:=FWPreparedStatement():New(cQuery)
			EndIf
			
			__oCredRec:SetString(1,cDocumen)
			cQuery := __oCredRec:GetFixQuery()
		ElseIf TRB100->RECPAG == 'P'
			If __oCredPag == NIL
				cQuery := "SELECT E5_DOCUMEN, SUM(E5_VALOR) SLDCRED"
				cQuery += " FROM " + RetSqlName('SE5') + " SE5"
				cQuery += " WHERE"
				cQuery += " E5_DOCUMEN = ? AND"
				cQuery += " E5_TIPO IN " + FormatIn(MV_CPNEG,'|') + " AND"
				cQuery += " SE5.D_E_L_E_T_ = ' '"
				cQuery += " GROUP BY E5_DOCUMEN"
				
				cQuery := ChangeQuery(cQuery)
				__oCredPag:=FWPreparedStatement():New(cQuery)
			EndIf
			
			__oCredPag:SetString(1,cDocumen)
			cQuery := __oCredPag:GetFixQuery()
			
		EndIf
		
		nValRet := MpSysExecScalar(cQuery,"SLDCRED")
		If !Empty(cQuery)
			cRepl := "INSERT INTO " + __oTSlCred:GetRealName()
			cRepl += " (DOCUMEN, SLDCRED) "
			cRepl += " ( " + cQuery + ") "
			TCSQLEXEC(cRepl)
		EndIf
	EndIf

Return nValRet




User Function ZIMPZGB(_nOpc)

Private cArq    	:= Space(200)
Private lSair   	:= .F.
Private cNewPlan   	:= Space(15)
Private cAno  		:= Space(2)
Private cMes  		:= Space(2)
Private dDtVenc := StoD("")
Private oDlg        
Private _cProc001	:= "Aguarde por favor!!!"            
	
Define MsDialog oDlg Title ("Importar Arquivos") From 0,0 To 260,650 Pixel
	@005,010 To 107,320 Pixel
	@011,020 Say "Escolha a Planilha .CSV" Pixel of oDlg

	@031,020 Say "Arquivo...........:" Pixel of oDlg
	@030,080 MsGet oVar4 Var cArq    Size 215,010 Pixel of oDlg When .F. //Nao Editavel
	@029,300 Button oBtnLoc Prompt "..."       Size 013,013 Pixel Action (LocArq(),lSair:=.T.)   of oDlg
	@052,120 Button oBtnOk  Prompt "&Ok"       Size 030,013 Pixel Action (oDlg:End(),ZImpPlan(cArq)) of oDlg
	@052,180 Button oBtnCan Prompt "&Cancelar" Size 030,013 Pixel Action (lSair:=.T.,oDlg:End()) of oDlg
Activate MsDialog oDlg Centered Valid lSair

Return


Static Function ZImpPlan (_cPath)

Local cProcesso
            
	oProcess := MsNewProcess():New({|| ProImpPla(_cPath, @oProcess)},"Importando registros da planilha!","Aguarde por favor!!!",.F.)
	oProcess:Activate()

Return (Nil) 

Static Function LocArq()

		//Abre tela para selecionar arquivo
	cArq   := cGetFile("Arq.separados p.virgula|*.CSV|","Selecione o diretorio",,,,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)

Return(cArq)

Static Function ProImpPla(_cPath)

Local _cBuffer 	:= ""   
Local _aLin   	:= {} 
Local _nLinha	:= 0
Local _nX	:= 0
Local _nY := 0 
Local _nTotal := 0 
Local _aHeader := {}
Local _aTemp := {}
Local _aCabec := {}
Local _aItens := {}
Local _cAlias := ""

Default _cPath := ""
PRIVATE lMsErroAuto := .F.
//For _nX := 1 to Len(_aHead)
//    _acols[_nX] := CriaVar(_aHead[_nX][2]) 
//Next _nX


If !File(_cPath)
  ConOut("erro...")
  Return(Nil)
EndIf

FT_FUSE(_cPath)  
FT_FGOTOP()

oProcess:SetRegua1(0)
oProcess:SetRegua2(0)
oProcess:IncRegua1("Validando dados para importação")
oProcess:IncRegua2("Processando arquivo!")

While !FT_FEOF()
	_cBuffer := AllTrim(FT_FREADLN())
	_aTemp := {}
    _aTemp   := Separa(_cBuffer,";")
    If _aTemp[2] <> ''
        If _nLinha == 0 //Cabeçalho
			_aHeader :=  aClone(_aTemp)
			_nLinha ++
		Else
			aAdd(_aLin,_aTemp)
			_nLinha ++
		EndIf
    EndIf
	FT_FSKIP()
EndDo

_nTotal := Len(_aLin)
oProcess:SetRegua1(_nTotal)
oProcess:SetRegua2(0)
Begin Transaction
	If _nTotal > 0 
		DbSelectArea("ZGB")
		ZGB->(DbSetOrder(1))
		
		_cAlias := GetNextAlias()
		BeginSql alias _cAlias
			%noparser%
			SELECT 	R_E_C_N_O_ AS RECZGB
			FROM 		%table:ZGB% WITH(NOLOCK)
			WHERE 		D_E_L_E_T_ = '' 
					AND ZGB_DATA BETWEEN '20210100' AND '20210100'			
					AND ZGB_FILIAL = 'APAGATUDO'
		EndSql

		While (_cAlias)->(!EOF())
			ZGB->(DbGoTop())
			ZGB->(DbGoTo((_cAlias)->RECZGB))
			If ZGB->(RECNO()) == (_cAlias)->RECZGB
				If 	ZGB->(RecLock("ZGB",.F.))
						ZGB->(DbDelete())
					ZGB->(MsUnlock())
				EndIf
			EndIf
		(_cAlias)->(DbSkip())
		EndDo

        For _nX := 1 to Len(_aLin)
            oProcess:IncRegua1("Construindo vetores de importação... ")
			ZGB->(DbGoTop())
			If ZGB->(RecLock("ZGB",.T.))
				For _nY := 1 to Len(_aHeader)
					If SubStr(_aHeader[_nY],1,4) == "ZGB_"
						If GetSX3Cache(_aHeader[_nY], "X3_TIPO") == "N"
							&("ZGB->"+Alltrim(_aHeader[_nY])) := Val(_aLin[_nX][_nY])
						ElseIf GetSX3Cache(_aHeader[_nY], "X3_TIPO") == "D"
							&("ZGB->"+Alltrim(_aHeader[_nY])) := CtoD(_aLin[_nX][_nY])
						Else
							&("ZGB->"+Alltrim(_aHeader[_nY])) := _aLin[_nX][_nY] 
						EndIf
					EndIf
				Next _nY
				ZGB->(MsUnlock())
			EndIf
        Next _nX
	EndIf
End Transaction 

Return 



// Relatório base para importação
User Function ZIMPZGBR()

Local oProcess := Nil

	oProcess := MsNewProcess():New({  || ZEXECREL(@oProcess)},"Exportando tabela base...","Aguarde por favor!!!",.T.)
	oProcess:Activate()

Return

Static Function ZEXECREL(oProcess)

Local oExcel 		:= FWMsExcelEx():New()
Local cFile			:= ""
Local cNomePlan	:= ""
Local cTituloPlan	:= ""
Local _cAlias1		:= ""
Local _nMax := 0
Local _nX := 0
Local _nRow := 0

local oPrtXlsx as object
local cFilename as character
local lRet as logical
Local cFont := ""
Local nSize := 11
Local lItalic := .F.
Local lBold := .T.
Local lUnderlined := .F.
Local _nNomArq := 'c:\Temp\ZIMPZGBR_'+DToS(Date())+StrTran(Time(),":","")

Local cHorAlignment := "" 
Local cVertAlignment := ""
Local lWrapText := .F.
Local nRotation := 0 
Local cCustomFormat := ""
Local cColor := "000000" // Cor preta!
Local cColorF := "3CB371" 


static oCellHorAlign := FwXlsxCellAlignment():Horizontal()
static oCellVertAlign := FwXlsxCellAlignment():Vertical()

    cFilename := _nNomArq+'.rel'
    ferase(cFilename)
    oPrtXlsx := FwPrinterXlsx():New(.T.)
    lRet := oPrtXlsx:Activate(cFilename)

_cAlias1 := GetNextAlias()

BeginSql alias _cAlias1  
		%noparser%
        COLUMN ZGB_DATA AS DATE
		COLUMN ZGB_VENCTO AS DATE
		COLUMN ZGB_DTDIGI AS DATE
		COLUMN ZGB_DTDISP AS DATE

		SELECT 	ZGB_FILIAL, ZGB_DATA, ZGB_TIPO, ZGB_MOEDA, ZGB_VALOR, ZGB_NATURE, ZGB_BANCO, ZGB_AGENCI, 
				ZGB_CONTA, ZGB_NUMCHE, ZGB_DOCUME, ZGB_VENCTO, ZGB_RECPAG, ZGB_BENEF, ZGB_HISTOR, ZGB_TIPODO, 
				ZGB_NUMERO, ZGB_PARCEL, ZGB_CLIFOR, ZGB_LOJA, ZGB_DTDIGI, ZGB_RECONC, ZGB_DTDISP, ZGB_VLCORR, 
				ZGB_PREFIX, ZGB_FILORI, ZGB_TXMOED, ZGB_MOTBX, ZGB_VLMOE2, R_E_C_N_O_ AS RECZGB
		FROM 		%table:ZGB% WITH(NOLOCK)
		WHERE 		D_E_L_E_T_ = '' 
				AND ZGB_DATA BETWEEN '20210101' AND '20211231'
EndSql
_cQry := GetLastQuery()[2]

(_cAlias1)->(DbGoTop())
_nCount := 0
While (_cAlias1)->(!EOF())
    _nCount++
(_cAlias1)->(DbSkip())
EndDo
oProcess:SetRegua1( 1 )
oProcess:SetRegua2(_nCount)
    
    lRet := oPrtXlsx:AddSheet("TABELA")
    
    cFont := FwPrinterFont():Calibri()
    nSize := 14
    lItalic := .F.
    lBold := .T.
    lUnderlined := .F.
    lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)
    _nRow ++ //soma 1 linha para os títulos

	lRet := oPrtXlsx:SetText(_nRow, 1 , 'ZGB_FILIAL')
	lRet := oPrtXlsx:SetText(_nRow, 2 , 'ZGB_DATA')
	lRet := oPrtXlsx:SetText(_nRow, 3 , 'ZGB_TIPO')
	lRet := oPrtXlsx:SetText(_nRow, 4 , 'ZGB_MOEDA')
	lRet := oPrtXlsx:SetText(_nRow, 5 , 'ZGB_VALOR')
	lRet := oPrtXlsx:SetText(_nRow, 6 , 'ZGB_NATURE')
	lRet := oPrtXlsx:SetText(_nRow, 7 , 'ZGB_BANCO')
	lRet := oPrtXlsx:SetText(_nRow, 8 , 'ZGB_AGENCI')
	lRet := oPrtXlsx:SetText(_nRow, 9 , 'ZGB_CONTA')
	lRet := oPrtXlsx:SetText(_nRow, 10 , 'ZGB_NUMCHE')
	lRet := oPrtXlsx:SetText(_nRow, 11 , 'ZGB_DOCUME')
	lRet := oPrtXlsx:SetText(_nRow, 12 , 'ZGB_VENCTO')
	lRet := oPrtXlsx:SetText(_nRow, 13 , 'ZGB_RECPAG')
	lRet := oPrtXlsx:SetText(_nRow, 14 , 'ZGB_BENEF')
	lRet := oPrtXlsx:SetText(_nRow, 15 , 'ZGB_HISTOR')
	lRet := oPrtXlsx:SetText(_nRow, 16 , 'ZGB_TIPODO')
	lRet := oPrtXlsx:SetText(_nRow, 17 , 'ZGB_NUMERO')
	lRet := oPrtXlsx:SetText(_nRow, 18 , 'ZGB_PARCEL')
	lRet := oPrtXlsx:SetText(_nRow, 19 , 'ZGB_CLIFOR')
	lRet := oPrtXlsx:SetText(_nRow, 20 , 'ZGB_LOJA')
	lRet := oPrtXlsx:SetText(_nRow, 21 , 'ZGB_DTDIGI')
	lRet := oPrtXlsx:SetText(_nRow, 22 , 'ZGB_RECONC')
	lRet := oPrtXlsx:SetText(_nRow, 23 , 'ZGB_DTDISP')
	lRet := oPrtXlsx:SetText(_nRow, 24 , 'ZGB_VLCORR')
	lRet := oPrtXlsx:SetText(_nRow, 25 , 'ZGB_PREFIX')
	lRet := oPrtXlsx:SetText(_nRow, 26 , 'ZGB_FILORI')
	lRet := oPrtXlsx:SetText(_nRow, 27 , 'ZGB_TXMOED')
	lRet := oPrtXlsx:SetText(_nRow, 28 , 'ZGB_MOTBX')
	lRet := oPrtXlsx:SetText(_nRow, 29 , 'ZGB_VLMOE2')

	cFont := FwPrinterFont():Calibri()
    nSize := 11
    lItalic := .F.
    lBold := .F.
    lUnderlined := .F.
    lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)

    (_cAlias1)->(DbGoTop())
    _nAtu := 0
    If (_cAlias1)->(!EOF())
        While (_cAlias1)->(!EOF())
            _nAtu ++
            oProcess:IncRegua1( "Exportando dados... " ) //+cValToChar(_nAtu)+ " de "+cValToChar(_nCount) )
            oProcess:IncRegua2("Gerando relatorio: " )

		    cCustomFormat := "dd/mm/yyyy"
			cHorAlignment := oCellHorAlign:Center()
			cVertAlignment := oCellVertAlign:Center()
			lWrapText := .F.
			nRotation := 0
			// Seta texto vermelho com alinhamento horizontal e vertical centralizado e com rotação de texto vertical
			lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, cColor, cColorF, cCustomFormat)			
			cHorAlignment := oCellHorAlign:Center()
			cVertAlignment := oCellVertAlign:Justify()  

            lRet := oPrtXlsx:SetDate(_nAtu+_nRow, 2, (_cAlias1)->ZGB_DATA)
			lRet := oPrtXlsx:SetDate(_nAtu+_nRow, 21, (_cAlias1)->ZGB_DTDIGI)
			lRet := oPrtXlsx:SetDate(_nAtu+_nRow, 23, (_cAlias1)->ZGB_DTDISP)
			If !Empty((_cAlias1)->ZGB_VENCTO)
				lRet := oPrtXlsx:SetDate(_nAtu+_nRow, 12, (_cAlias1)->ZGB_VENCTO)
			EndIf


		    cCustomFormat := ""
			cHorAlignment := oCellHorAlign:Center()
			cVertAlignment := oCellVertAlign:Center()
			lWrapText := .F.
			nRotation := 0

			lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, cColor, cColorF, cCustomFormat)			

			If Empty((_cAlias1)->ZGB_VENCTO)
				lRet := oPrtXlsx:SetText(_nAtu+_nRow, 12, "")
			EndIf

			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 11, (_cAlias1)->ZGB_DOCUME)

			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 1, (_cAlias1)->ZGB_FILIAL)
			
			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 3, (_cAlias1)->ZGB_TIPO)
			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 4, (_cAlias1)->ZGB_MOEDA)
			lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 5, (_cAlias1)->ZGB_VALOR)
			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 6, (_cAlias1)->ZGB_NATURE)
			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 7, (_cAlias1)->ZGB_BANCO)
			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 8, (_cAlias1)->ZGB_AGENCI)
			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 9, (_cAlias1)->ZGB_CONTA)
			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 10, (_cAlias1)->ZGB_NUMCHE)
			
			
			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 13, (_cAlias1)->ZGB_RECPAG)
			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 14, (_cAlias1)->ZGB_BENEF)
			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 15, (_cAlias1)->ZGB_HISTOR)
			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 16, (_cAlias1)->ZGB_TIPODO)
			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 17, (_cAlias1)->ZGB_NUMERO)
			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 18, (_cAlias1)->ZGB_PARCEL)
			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 19, (_cAlias1)->ZGB_CLIFOR)
			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 20, (_cAlias1)->ZGB_LOJA)
			
			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 22, (_cAlias1)->ZGB_RECONC)
			
			lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 24, (_cAlias1)->ZGB_VLCORR)
			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 25, (_cAlias1)->ZGB_PREFIX)
			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 26, (_cAlias1)->ZGB_FILORI)
			lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 27, (_cAlias1)->ZGB_TXMOED)
			lRet := oPrtXlsx:SetText(_nAtu+_nRow, 28, (_cAlias1)->ZGB_MOTBX)
			lRet := oPrtXlsx:SetNumber(_nAtu+_nRow, 29, (_cAlias1)->ZGB_VLMOE2)

        (_cAlias1)->(DbSkip())
        EndDo
    EndIf
    (_cAlias1)->(dbCloseArea())

    
		lRet := oPrtXlsx:toXlsx()
		oPrtXlsx:DeActivate()
		shellExecute("Open", "excel", _nNomArq, "C:\", 1 )
		MsgInfo('Arquivo gerado com sucesso: '+_nNomArq+".xlsx","Sucesso")
	
Return()


// EXCE��ES DE LCDPR
User Function ZEXCZGB()


Local oGroup1
Local oButton1, oButton2,oButton3,oButton4
Local oSay2, oSay3, oSay4

Private oSayTesS, oSayTesE
Private oGet3, oGet4, oGet5,  oGet6, oGet7, oGetTesS, oGetTesE
Private dGet3		:= Date()
Private dGet4		:= Date()
Private cGet5		:= Space(100)
Private cGet6		:= Space(100)
Private cGet7		:= Space(100)
Private aSize		:= {}
Private aPosObj		:= {}
Private aObjects	:= {}
Private aSortGrd	:= {}
Private aCabec		:= {}
Private aItens		:= {}
Private oMSNewGe1
Private oDlg
Private _aNomeRot := {} 
Private _lMuda := .T.
Private _cTipoDe := Space(2)
Private _cTipoAte := 'ZZ'
Private _cGrpDe := Space(4)
Private _cGrpAte := "ZZZZ"
Private _nTpDoc := 1
Private _nGerPCO := 3
Private _nComPC := 3
Private _nServico := 1
Private _nComVlr := 1
Private _dDtIni := dDatabase
Private _dDtFim := dDatabase
Private _nTotReg := 0 
Private oTotReg 
Private oGTotReg 

	aSize := MsAdvSize()
	aAdd(aObjects, {50, 50, .T., .T. })
	aInfo := {aSize[1], aSize[2], aSize[3], aSize[4], 5, 5}
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	DEFINE MSDIALOG oDlg TITLE "INCLUS�O DE EXCE��ES" FROM aSize[7], 0 TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL
		@ 001, 001 GROUP oGroup1 TO 030, aPosObj[1,4] OF oDlg COLOR 0, 16777215 PIXEL
		fMSNewGe1()
		@ (aPosObj[1,2])  , 005 SAY oSay4 PROMPT "Pesquisa:"  SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ (aPosObj[1,2]) -3 , 035 MSGET oGet5 VAR cGet5 SIZE 120, 010 OF oDlg COLORS 0, 16777215 ON CHANGE RecDados() PIXEL

		@ (aPosObj[1,2]) +15 , 005 SAY oTotReg PROMPT "Nro. Regs: "  SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ (aPosObj[1,2]) +12 , 035 MSGET oGTotReg VAR cValToChar(_nTotReg) SIZE 30, 010 OF oDlg COLORS 0, 16777215 PIXEL
		oGTotReg:Disable()

		@ (aPosObj[1,2])  , 200 SAY oSay4 PROMPT "Data de?"  SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ (aPosObj[1,2]) -3 , 235 MSGET oGet5 VAR _dDtIni SIZE 120, 010 OF oDlg COLORS 0, 16777215 ON CHANGE RecDados() PIXEL 

		@ (aPosObj[1,2]) +15 , 200 SAY oSay4 PROMPT "Data Ate?"  SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ (aPosObj[1,2]) +12 , 235 MSGET oGet5 VAR _dDtFim SIZE 120, 010 OF oDlg COLORS 0, 16777215 ON CHANGE RecDados() PIXEL 

		@ (aPosObj[1,2]) -3 , 365 RADIO oRadMenu1 VAR _nTpDoc ITEMS "Vinculados","Todos"  SIZE 086,016 OF oDlg  COLOR 0,16777215 ON CHANGE RecDados() PIXEL

		@ aPosObj[1,2] -3, 	  aPosObj[1,4] - 084 BUTTON oButton3 PROMPT "Atualizar"   SIZE 037, 012 OF oDlg  ACTION MsgRun(OemToAnsi("Processando Registros Selecionados... Aguarde..."),"",{||  _ACATUEXCC()}) PIXEL
		
		@ aPosObj[1,2] -3,    aPosObj[1,4] - 042 BUTTON oButton2 PROMPT "Fechar"   SIZE 037, 012 OF oDlg  ACTION Close(oDlg) PIXEL
	ACTIVATE MSDIALOG oDlg CENTERED

Return(Nil)


// Gera��o da nota fiscal conforme sele��o do usu�rio.
Static Function _ACATUEXCC()

Local _aArea		:= GetArea()
Local nPosOk		:= aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "CHECKBOL"})
Local nPRecOri	    := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "REC_ORI"})
Local nPRecSE5	    := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "REC_SE5"})
Local _nX := 0 

        DbSelectArea("ZGX")
		DbSelectArea("SE5")
        For _nX := 1 to Len(oMSNewGe1:aCols)
            If(oMSNewGe1:aCols[_nX][nPRecOri] > 0 .AND. oMSNewGe1:aCols[_nX][nPosOk] == "LBNO")
                ZGX->(DbGoTo(oMSNewGe1:aCols[_nX][nPRecOri]))
                If ZGX->(Recno()) == oMSNewGe1:aCols[_nX][nPRecOri]
                    If 	ZGX->(RecLock("ZGX",.F.))
                        	ZGX->(DbDelete())
						ZGX->(MsUnlock())
                    EndIf
                EndIf
            ElseIf (oMSNewGe1:aCols[_nX][nPRecOri] == 0 .AND. oMSNewGe1:aCols[_nX][nPosOk] == "LBOK") //INCLUS�O
                SE5->(DbGoTo(oMSNewGe1:aCols[_nX][nPRecSE5]))
                If SE5->(Recno()) == oMSNewGe1:aCols[_nX][nPRecSE5]
                    If 	ZGX->(RecLock("ZGX",.T.))
						ZGX->ZGX_FILIAL :=   SE5->E5_FILIAL
						ZGX->ZGX_DATA :=   SE5->E5_DATA
						ZGX->ZGX_TIPO :=   SE5->E5_TIPO
						ZGX->ZGX_MOEDA :=   SE5->E5_MOEDA
						ZGX->ZGX_VALOR :=   SE5->E5_VALOR
						ZGX->ZGX_NATURE :=   SE5->E5_NATUREZ
						ZGX->ZGX_BANCO :=   SE5->E5_BANCO
						ZGX->ZGX_AGENCI :=   SE5->E5_AGENCIA
						ZGX->ZGX_CONTA :=   SE5->E5_CONTA
						ZGX->ZGX_NUMCHE :=   SE5->E5_NUMCHEQ
						ZGX->ZGX_DOCUME :=   SE5->E5_DOCUMEN
						ZGX->ZGX_VENCTO :=   SE5->E5_VENCTO
						ZGX->ZGX_RECPAG :=   SE5->E5_RECPAG
						ZGX->ZGX_BENEF :=   SE5->E5_BENEF
						ZGX->ZGX_HISTOR :=   SE5->E5_HISTOR
						ZGX->ZGX_TIPODO :=   SE5->E5_TIPODOC
						ZGX->ZGX_PREFIX :=   SE5->E5_PREFIXO
						ZGX->ZGX_NUMERO :=   SE5->E5_NUMERO
						ZGX->ZGX_PARCEL :=   SE5->E5_PARCELA
						ZGX->ZGX_CLIFOR :=   SE5->E5_CLIFOR
						ZGX->ZGX_LOJA :=   SE5->E5_LOJA
						ZGX->ZGX_DTDIGI :=   SE5->E5_DTDIGIT
						ZGX->ZGX_MOTBX :=   SE5->E5_MOTBX
						ZGX->ZGX_SEQ :=   SE5->E5_SEQ
						ZGX->ZGX_DTDISP :=   SE5->E5_DTDISPO
						ZGX->ZGX_FILORI :=   SE5->E5_FILORIG
						ZGX->ZGX_VLJURO :=   SE5->E5_VLJUROS
						ZGX->ZGX_VLMULT :=   SE5->E5_VLMULTA
						ZGX->ZGX_VLCORR :=   SE5->E5_VLCORRE
						ZGX->ZGX_VLDESC :=   SE5->E5_VLDESCO
						ZGX->ZGX_TXMOED :=   SE5->E5_TXMOEDA
						ZGX->(MsUnlock())
                    EndIf
                EndIf			
            EndIf
        Next _nX
	
    RecDados(.T.) 
    
    oDlg:Refresh()		
    
    RestArea(_aArea)

Return(Nil)

Static Function RecDados(lDelObj)
Local _cQuery	:= ""
Local cNewAlias	:= GetNextAlias()
Local aStru		:= {}
Local _nX		:= 0
Default lDelObj	:= .F.

If lDelObj
	oMSNewGe1:aCols := {}
EndIf	

	aCabec		:= {}
	aItens		:= {}
	cGet5		:= Upper(cGet5)
	cGet6		:= Upper(cGet6)
	cGet7		:= Upper(cGet7)
	
    
    
        _cQuery := "" + CRLF
        _cQuery += " SELECT 	SE5.E5_FILIAL, SE5.E5_DATA, SE5.E5_TIPO, SE5.E5_MOEDA, SE5.E5_VALOR, SE5.E5_NATUREZ, SE5.E5_BANCO, SE5.E5_AGENCIA, SE5.E5_CONTA, SE5.E5_NUMCHEQ, SE5.E5_DOCUMEN, SE5.E5_VENCTO,
        _cQuery += " 		SE5.E5_RECPAG, SE5.E5_BENEF, SE5.E5_HISTOR, SE5.E5_TIPODOC, SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_DTDIGIT, SE5.E5_MOTBX, SE5.E5_SEQ,
        _cQuery += " 		SE5.E5_DTDISPO, SE5.E5_FILORIG, SE5.E5_VLJUROS, SE5.E5_VLMULTA, SE5.E5_VLCORRE, SE5.E5_VLDESCO, SE5.E5_TXMOEDA, ISNULL(ZGX.R_E_C_N_O_, 0) AS RECZGX, SE5.R_E_C_N_O_ AS RECSE5
        _cQuery += " FROM 		SE5010 SE5 WITH(NOLOCK) LEFT OUTER JOIN ZGX010 ZGX WITH(NOLOCK) ON
        _cQuery += " 			SE5.E5_FILIAL = ZGX.ZGX_FILIAL
        _cQuery += "  		AND SE5.E5_PREFIXO = ZGX.ZGX_PREFIX
        _cQuery += "  		AND SE5.E5_NUMERO = ZGX.ZGX_NUMERO
        _cQuery += "  		AND SE5.E5_PARCELA = ZGX.ZGX_PARCEL
        _cQuery += "  		AND SE5.E5_TIPO = ZGX.ZGX_TIPO
        _cQuery += "  		AND SE5.E5_CLIFOR = ZGX.ZGX_CLIFOR
        _cQuery += "  		AND SE5.E5_LOJA = ZGX.ZGX_LOJA
        _cQuery += "  		AND SE5.E5_SEQ = ZGX.ZGX_SEQ
        _cQuery += "  		AND SE5.E5_MOTBX = ZGX.ZGX_MOTBX
        _cQuery += "  		AND SE5.E5_DATA = ZGX.ZGX_DATA
        _cQuery += "  		AND ZGX.D_E_L_E_T_ = ''
        _cQuery += " WHERE 		SE5.D_E_L_E_T_ = ''
        _cQuery += " 		AND SE5.E5_SITUACA = ''

        If !Empty(cGet5)
            _cQuery += " AND UPPER(RTRIM(SE5.E5_FILIAL+SE5.E5_PREFIXO+SE5.E5_NUMERO+SE5.E5_PARCELA+SE5.E5_TIPO+SE5.E5_BENEF+SE5.E5_CLIFOR+SE5.E5_LOJA)) LIKE '%"+Alltrim(UPPER(cGet5))+"%'  " + CRLF
        EndIf

		If !Empty(_dDtIni) .and. !Empty(_dDtFim)
			_cQuery += " AND SE5.E5_DATA BETWEEN '"+DToS(_dDtIni)+"' AND '"+DToS(_dDtFim)+"' "
		EndIf

		If _nTpDoc == 1 //SOMENTE  VINCULADOS
			_cQuery += " AND ZGX.ZGX_FILIAL IS NOT NULL "
		EndIf


	_cQuery += " ORDER BY ISNULL(ZGX.R_E_C_N_O_, 0) DESC, SE5.E5_FILIAL, SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, SE5.E5_TIPO
    			

	If(Select(cNewAlias) <> 0)
		dbSelectArea(cNewAlias)
		dbCloseArea()
	EndIf
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cNewAlias,.T.,.T.)
	aStru := dbStruct()

	For _nX := 1 to Len(aStru)
		If(!Empty(FwSX3Util():GetFieldType(ALLTRIM(aStru[_nX][1]))))
			TCSetField(cNewAlias,;
						zSetField(aStru[_nX][1], "X3_CAMPO"),;
						zSetField(aStru[_nX][1], "X3_TIPO"),;
						zSetField(aStru[_nX][1], "X3_TAMANHO"),;
						zSetField(aStru[_nX][1], "X3_DECIMAL"))
		Else
			TCSetField(cNewAlias, aStru[_nX][1], aStru[_nX][2], aStru[_nX][3], aStru[_nX][4])
		EndIf
	Next _nX
	_nTotReg := 0 
	If !(cNewAlias)->(EOF())
	        While !(cNewAlias)->(EOF())
						_nTotReg ++
                        aAdd(aCabec,    {IIF(  (cNewAlias)->RECZGX > 0 , "LBOK","LBNO")  ,;
										 	(cNewAlias)-> E5_FILIAL ,;
											(cNewAlias)-> E5_DATA ,;
											(cNewAlias)-> E5_TIPO ,;
											(cNewAlias)-> E5_MOEDA ,;
											(cNewAlias)-> E5_VALOR ,;
											(cNewAlias)-> E5_NATUREZ ,;
											(cNewAlias)-> E5_BANCO ,;
											(cNewAlias)-> E5_AGENCIA ,;
											(cNewAlias)-> E5_CONTA ,;
											(cNewAlias)-> E5_NUMCHEQ ,;
											(cNewAlias)-> E5_DOCUMEN ,;
											(cNewAlias)-> E5_VENCTO ,;
											(cNewAlias)-> E5_RECPAG ,;
											(cNewAlias)-> E5_BENEF ,;
											(cNewAlias)-> E5_HISTOR ,;
											(cNewAlias)-> E5_TIPODOC ,;
											(cNewAlias)-> E5_PREFIXO ,;
											(cNewAlias)-> E5_NUMERO ,;
											(cNewAlias)-> E5_PARCELA ,;
											(cNewAlias)-> E5_CLIFOR ,;
											(cNewAlias)-> E5_LOJA ,;
											(cNewAlias)-> E5_DTDIGIT ,;
											(cNewAlias)-> E5_MOTBX ,;
											(cNewAlias)-> E5_SEQ ,;
											(cNewAlias)-> E5_DTDISPO ,;
											(cNewAlias)-> E5_FILORIG ,;
											(cNewAlias)-> E5_VLJUROS ,;
											(cNewAlias)-> E5_VLMULTA ,;
											(cNewAlias)-> E5_VLCORRE ,;
											(cNewAlias)-> E5_VLDESCO ,;
											(cNewAlias)-> E5_TXMOEDA ,;
											(cNewAlias)-> RECZGX ,(cNewAlias)-> RECSE5 ,;
                                .F.})
		        (cNewAlias)->(dbSkip())
	        EndDo
        EndIf

		oGTotReg:Refresh()
		

	oMSNewGe1:aCols := aClone(aCabec)
	oMSNewGe1:Refresh()
	dbSelectArea(cNewAlias)
	dbCloseArea()

Return(Nil)


Static Function fMSNewGe1()
Local _nX			:= 0
Local aHeaderEx		:= {}
Local aColsEx		:= {}
Local aFieldFill	:= {} 
Local aFields		:= { "E5_FILIAL","E5_DATA","E5_TIPO","E5_MOEDA","E5_VALOR","E5_NATUREZ","E5_BANCO","E5_AGENCIA","E5_CONTA","E5_NUMCHEQ","E5_DOCUMEN","E5_VENCTO","E5_RECPAG","E5_BENEF","E5_HISTOR","E5_TIPODOC","E5_PREFIXO","E5_NUMERO","E5_PARCELA","E5_CLIFOR","E5_LOJA","E5_DTDIGIT","E5_MOTBX","E5_SEQ","E5_DTDISPO","E5_FILORIG","E5_VLJUROS","E5_VLMULTA","E5_VLCORRE","E5_VLDESCO","E5_TXMOEDA"}
Local aAlterFields	:= {  }
Local aExc			:= {}

	aAdd(aExc, {"X3_VALID", ".T."})
	aAdd(aHeaderEx, {"","CHECKBOL","@BMP",10,0,,,"C",,"V",,,"mark","V","S"})

	For _nX := 1 to Len(aFields)
		aAdd(aHeaderEx, GetSX3(aFields[_nX], aExc))
	Next _nX

	aAdd(aHeaderEx, {"Recno","REC_ORI","",10,0,NIL,"�", "N",,"V"})
	aAdd(aHeaderEx, {"RecSE5","REC_SE5","",10,0,NIL,"�", "N",,"V"})


	If(Len(aCabec) == 0)
		aAdd(aFieldFill, "LBNO")
		For _nX := 1 to Len(aFields)
			If(!Empty(FwSX3Util():GetFieldType(aFields[_nX])))
				aAdd(aFieldFill, CriaVar(aFields[_nX]))
			EndIf
		Next _nX
		aAdd(aFieldFill, 0)
		aAdd(aFieldFill, 0)
		aAdd(aFieldFill, .F.)
		aAdd(aColsEx, aFieldFill)
	Else
		aColsEx	:= aClone(aCabec)
		aCabec	:= Nil
		aCabec	:= {}
	EndIf

	oMSNewGe1 := MsNewGetDados():New(aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
	oMSNewGe1:oBrowse:bHeaderClick := {|oMSNewGe1, nCol| Ordena(nCol, Time())}

	oMSNewGe1:oBrowse:bLDblClick   := {|| SelItens()}

	oMSNewGe1:oBrowse:lUseDefaultColors := .T.
	oMSNewGe1:oBrowse:SetBlkBackColor({|| GETDCLR(oMSNewGe1:aCols, oMSNewGe1:nAt, oMSNewGe1:aHeader, oMSNewGe1)})

	oMSNewGe1:Refresh()
	oMSNewGe1:oBrowse:Refresh()

	oDlg:Refresh()

Return(Nil)

Static Function GETDCLR(aLinha, nLinha, aHeader, oMSNewGe1)
Local nVermelh	:= RGB(128, 255, 000)
Local nPosOk	:= aScan(aHeader,{|x| Alltrim(x[2]) == "CHECKBOL"})
Local nRet     	:= oMSNewGe1:oBrowse:NCLRFOREFOCUS

	If(aLinha[nLinha][nPosOk] == "LBOK")
		nRet := nVermelh
	EndIf

Return(nRet)


Static Function Ordena(nCol, cTime)
Local aCoBrw1	:= oMSNewGe1:aCols
Local nPosOk		:= aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "CHECKBOL"})
Local _nX		:= 0
Local cOdem		:= ""

If nCol == 1  
	If _lMuda
		For _nX := 1 to Len(oMSNewGe1:aCols)
			If oMSNewGe1:aCols[_nX][nPosOk] == "LBOK"
				oMSNewGe1:aCols[_nX][nPosOk] := "LBNO"
			Else
				oMSNewGe1:aCols[_nX][nPosOk] := "LBOK"
			EndIf
		Next _nX 
		_lMuda := .F.
		oMSNewGe1:Refresh()			//Atualiza a Getdados
		oMSNewGe1:oBrowse:Refresh()	//Atualiza a Getdados do browse em tela.
		oDlg:Refresh()
	Else
		_lMuda := .T.
	EndIf
Else
	For _nX := 1 to Len(aSortGrd)
		If(aSortGrd[_nX][01] == nCol)
			If(aSortGrd[_nX][02] == Time())
				Return(Nil)
			Else
				cOdem := aSortGrd[_nX][03]
			EndIf
		EndIf
	Next _nX

	If(cOdem == "" .OR. cOdem == "C")
		aAdd(aSortGrd, {nCol, cTime, "D"})
		aCoBrw1 := aSort(aCoBrw1,,,{|x,y| x[nCol] < y[nCol]})
	Else
		aAdd(aSortGrd, {nCol, cTime, "C"})
		aCoBrw1 := aSort(aCoBrw1,,,{|x,y| x[nCol] > y[nCol]})
	EndIf

	oMSNewGe1:setArray(aCoBrw1) 
	oMSNewGe1:oBrowse:Refresh() 
EndIf
Return(Nil)


Static Function SelItens()
Local nPosOk	:= aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "CHECKBOL"})
	oMSNewGe1:aCols[oMSNewGe1:nAt][nPosOk] := IIf(oMSNewGe1:aCols[oMSNewGe1:nAt][nPosOk] == "LBOK", "LBNO", "LBOK")
	If(oMSNewGe1:aCols[oMSNewGe1:nAt][nPosOk] == "LBOK")

	EndIf

	oMSNewGe1:Refresh()			//Atualiza a Getdados
	oMSNewGe1:oBrowse:Refresh()	//Atualiza a Getdados do browse em tela.
	oDlg:Refresh()

Return(Nil)



Static Function GetSX3(cCpo, aExc)
Local aRet		:= {}
Local aArea		:= GetArea()
Local _nX		:= 0
Default aExc	:= {}

	If(!Empty(FwSX3Util():GetFieldType(cCpo)))
		aAdd(aRet, ALLTRIM(FwX3Titulo(cCpo)))		//[01] - X3_TITULO
		aAdd(aRet, GetSx3Cache(cCpo, "X3_CAMPO"))	//[02] - X3_CAMPO
		aAdd(aRet, GetSx3Cache(cCpo, "X3_PICTURE"))	//[03] - X3_PICTURE
		aAdd(aRet, GetSx3Cache(cCpo, "X3_TAMANHO"))	//[04] - X3_TAMANHO
		aAdd(aRet, GetSx3Cache(cCpo, "X3_DECIMAL"))	//[05] - X3_DECIMAL
		aAdd(aRet, GetSx3Cache(cCpo, "X3_VALID"))	//[06] - X3_VALID
		aAdd(aRet, GetSx3Cache(cCpo, "X3_USADO"))	//[07] - X3_USADO
		aAdd(aRet, GetSx3Cache(cCpo, "X3_TIPO"))	//[08] - X3_TIPO
		aAdd(aRet, GetSx3Cache(cCpo, "X3_F3"))		//[09] - X3_F3
		aAdd(aRet, GetSx3Cache(cCpo, "X3_CONTEXT"))	//[10] - X3_CONTEXT
		aAdd(aRet, GetSx3Cache(cCpo, "X3_CBOX"))	//[11] - X3_CBOX
		aAdd(aRet, GetSx3Cache(cCpo, "X3_RELACAO"))	//[12] - X3_RELACAO
	EndIf

	For _nX := 1 to Len(aExc)
		If(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_TITULO")		//[01] - 
			aRet[01] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_CAMPO")		//[02] - 
			aRet[02] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_PICTURE")	//[03] - 
			aRet[03] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_TAMANHO")	//[04] - 
			aRet[04] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_DECIMAL")	//[05] - 
			aRet[05] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_VALID")		//[06] - 
			aRet[06] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_USADO")		//[07] - 
			aRet[07] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_TIPO")		//[08] - 
			aRet[08] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_F3")		//[09] - 
			aRet[09] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_CONTEXT")	//[10] - 
			aRet[10] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_CBOX")		//[11] - 
			aRet[11] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_RELACAO")	//[12] - 
			aRet[12] := aExc[_nX][02]
		EndIf
	Next _nX

	RestArea(aArea)

Return(aRet)

Static Function zSetField(cCpo, cRetorno)
Local cRet	:= Nil
Local aArea := GetArea()

If(!Empty(FwSX3Util():GetFieldType(cCpo)))
        cRet := GetSx3Cache(cCpo, cRetorno)
EndIf

RestArea(aArea)

Return(cRet)
