#include 'totvs.ch'

/*/{Protheus.doc} User Function MT100LOK
    PE para validar a linha digitada na rotina Doc. Entrada MATA103
    @type  Function
    @author 1.0
    @since 21/10/2021
    @version 1.0
    /*/
User Function MT100LOK()

	Local _lRet     := .T.
	Local _nPosRat  := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_RATEIO"})
	Local _nPosCC   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CC"})
	Local _nPosTES   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"})
	Local _nPosCF   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CF"})
	Local _nPPedido   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_PEDIDO"})
	Local _nPItemPC   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEMPC"})
    /*
    Local _nPosDtv  := Iif(aCols[n, Len(aCols[n])],"", GdFieldGet("D1_DTVALID"))
    Local _nPosLot  := Iif(aCols[n, Len(aCols[n])],"", AllTrim(GdFieldGet("D1_LOTECTL")))
    Local _nPosCod  := Iif(aCols[n, Len(aCols[n])],"", AllTrim(GdFieldGet("D1_COD"))) 
    */

	Local _nPosDtv := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_DTVALID"})
	Local _nPosLot := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_LOTECTL"})
	Local _nPosCod := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})

	local nPosIcm := aScan(aHeader,{|x| allTrim(x[2]) == "D1_VALICM"})
	local nPosIpi := aScan(aHeader,{|x| allTrim(x[2]) == "D1_VALIPI"})

	Local _lLoteCtl := Posicione("SB1",1,XFILIAL("SB1")+ aCols[N][_nPosCod] ,"B1_RASTRO") == "L"
	Local _cGrProd := '' //Alltrim(Posicione("SB1",1,XFILIAL("SB1")+ aCols[N][_nPosCod] ,"B1_GRUPO"))

	Local _aArea := GetArea()
	Local _aAreaSC1 := SC1->(GetArea())
	Local _aAreaSC7 := SC7->(GetArea())
	Local _aAreaSF4 := SF4->(GetArea())

	If aCols[N][Len(aHeader) + 1 ] //Se a linha estiver deletada
		Return _lRet
	Endif

	If ISINCALLSTACK( "U_ACMVCZGQ" )  //PROJETO CD - 2024
        REturn .T.
    EndIf

	//Função para realizar a validação TES CLASSIFICAÇÃO X Grupo de Produtos X CC DOC. ENTRADA
	If ExistBlock("FSCO03WK")
		_lRet := ExecBlock("FSCO03WK",.F.,.F.)
	EndIf

	//Validação Centro de custo com Item Contabil obrigatório //ANDRECCLARO 14/12/22
	If _lRet .AND. ExistBlock("FSC1ITECTA")
		_lRet := ExecBlock("FSC1ITECTA",.F.,.F.,{'D1_CC', 'D1_ITEMCTA'})
	EndIf

	If _lRet  .AND. aCols[N][_nPosRat] <> "1" .and. Empty(aCols[N][_nPosCC]) .and. lMT100TOK
		_lRet := .F.
		MsgStop("Centro de Custo Obrigatório quando não há rateio!", "CC VAZIO - MT100LOK")
	EndIf

	//Validação data lote maior que a database
	If cTipo == "N" .AND. _lLoteCtl
		//Valida se o lote foi informado no momento da inclusão
		If Empty(aCols[N][_nPosLot])
			MsgAlert("Informar o Lote para o produto " + aCols[N][_nPosCod] + ".","ATENÇÃO","ALERT")
			_lRet   := .F.
			Return(_lRet)
			//Valida se a data de validade do lote foi preenchido
		Elseif Empty(aCols[N][_nPosDtv])
			MsgAlert("Informar a Data de Validade do Lote para o produto " + aCols[N][_nPosCod] + ".","Atenção","ALERT")
			_lRet   := .F.
			Return(_lRet)
			//Verifica se a data de validade do lote é menor ou igual a data atual
		Elseif aCols[N][_nPosDtv] <= dDatabase
			MSGALERT( "Data de validade do lote ("+DtoC(aCols[N][_nPosDtv])+") do produto" + aCols[N][_nPosCod] + "é igual ou menor que a Database "+DtoC(dDataBase), "Atenção","ALERT")
			_lRet   := .F.
			Return(_lRet)
		Endif
	Endif


	If SuperGetMv("MV_ZVLCFNF",.F.,.T.)
		If !(IsInCallStack("MATA310") .OR. IsInCallStack("MATA311"))
    /*Validação quanto a acesso ao CFOP*/
		_lRet := U_ACZGHACES(aCols[N][_nPosCF] )
		EndIf
	EndIf

/*
@Autor:        André Claro
@Data:         14/08/2023
@Descrição:    Validação de amarração entre a SC x NF quanto ao campo C1_ZAPLDIR o qual:
                Aplicação direta - Tes não movimentará estoque
                Estoque - Tes deverá movimentar estoque.
*/
	If _lRet
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		SB1->(DbGoTop())
		If SB1->(DbSeek(xFilial("SB1") + aCols[N][_nPosCod] ))
			_cGrProd := alltrim(SB1->B1_GRUPO)
		EndIf

		DbSelectArea( 'SF4' )
		SF4->(DbSetOrder(1))
		SF4->(DbGoTop())
		If SF4->(DbSeek(xFilial("SF4") + aCols[N][_nPosTES] ))
			If SF4->F4_ATUATF == "S" .AND. _cGrProd $ SuperGetMv("MV_ZBEMPVL",.F.,"102")
				Aviso("Bens de pequeno valor", "O Grupo "+Alltrim(_cGrProd)+" está configurado como BEM DE PEQUENO VALOR "+" e não poderá atualizar ativo.",;
					{"Revisar"} , 2 , "O(s) grupo(s) "+Alltrim(SuperGetMv("MV_ZBEMPVL",.F.,"102"))+ " não podem atualizar ativo fixo.")
				_lRet := .F.
			EndIf
		EndIf

		If !Empty(aCols[N][_nPPedido]) .and. _lRet //Tem que ter pedido hein?
			DbSelectArea("SC7")
			SC7->(DbSetOrder(1))
			SC7->(DbGoTop())
			If SC7->(DbSeek(xFilial("SC7") + aCols[N][_nPPedido] + aCols[N][_nPItemPC] ))
				DbSelectArea("SC1")
				SC1->(DbSetOrder(1))
				SC1->(DbGoTop())
				If SC1->(DbSeek(xFilial("SC1") + SC7->C7_NUMSC + SC7->C7_ITEMSC ))
					SF4->(DbGoTop())
					If !Empty(SC1->C1_ZAPLDIR) .or. !Empty(SC1->C1_ZCODKAP)
						If SF4->(DbSeek(xFilial("SF4") + aCols[N][_nPosTES] ))
							If !Empty(SC1->C1_ZAPLDIR) .or. !Empty(SC1->C1_ZCODKAP)
								If      SC1->C1_ZAPLDIR == "S" .and. SF4->F4_ESTOQUE <> "S" //Aplicação direta TES sem estoque
									Aviso("Problema no Estoque do TES", "A solicitação de compras vinculada a essa NF foi criada para estoque. O TES deverá movimentar estoque.", {"Revisar"} , 2 , "Informe um TES condizente com a solicitação de compras.")
									_lRet := .F.
								ElseIf  SC1->C1_ZAPLDIR <> "S" .and. SF4->F4_ESTOQUE = "S" //Estoque
									Aviso("Problema no Estoque do TES", "A solicitação de compras vinculada a essa NF foi criada para aplicação direta. O TES não poderá movimentar estoque.", {"Revisar"} , 2 , "Informe um TES condizente com a solicitação de compras.")
									_lRet := .F.
								EndIf
							EndIf
							If !Empty(SC1->C1_ZCODKAP) .and. !( AllTrim(aCols[N][_nPosCF]) $ SuperGetMv("MV_CPCFOP",.F.,"")) .and. _lRet 
								DbSelectArea("ZGD")
								ZGD->(DbSetOrder(1)) //ZGD_FILIAL+ZGD_CODKAP+ZGD_REVISA+ZGD_ITEM
								ZGD->(DbGoTop())
								If ZGD->(DbSeek(xFilial("ZGD") + SC1-> (C1_ZCODKAP + C1_ZREVKAP + C1_ZITEKAP  )) )
									If ZGD->ZGD_CONSTR == 'S'
										If  !(SF4->F4_ATUATF == "S" .AND. SF4->F4_BENSATF == "2" )
											Aviso("Problema no Ativo do TES", "Operação referente a CAPEX de Construção precisa Atualizar Ativo (e Desmenbra ativo = NÃO)", {"Revisar"} , 2 , "Informe um TES que atualize ativo fixo.")
											_lRet := .F.
										EndIf
									Else
										If  !(SF4->F4_ATUATF == "S" .AND. SF4->F4_BENSATF == "1" )
											Aviso("Problema no Ativo do TES", "Operação referente a CAPEX de Aquisição precisa Atualizar Ativo (e Desmenbra ativo = Sim)", {"Revisar"} , 2 , "Informe um TES que atualize ativo fixo.")
											_lRet := .F.
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					
                    /*
                    Ticket 2812
                    @Autor: André Claro
                    @Data:  04/09/2024
                    @Descrição: TES atualiznado ativo para SC tipo OPEX.
                    */
                    If _lRet
                        SF4->(DbGoTop())
                        If SF4->(DbSeek(xFilial("SF4") + aCols[N][_nPosTES] ))
                            If SC1->C1_ZTIPOSC <> "C" .and. SF4->F4_ATUATF == "S" //Se é OPex e atualiza ativo, não pode!
                                Aviso("ATENÇÃO","A SC vinculada ao pedido dessa NF é do tipo OPEX e por isso o TES "+ SF4->F4_CODIGO +" que Atualiza Ativo não poderá ser utilizado.",{"REVISAR"},2)
                                _lRet := .F.
                            EndIf
                        EndIf
                    EndIf



				Else
					DbSelectArea( 'SF4' )
					SF4->(DbSetOrder(1))
					SF4->(DbGoTop())
					If SF4->(DbSeek(xFilial("SF4") + aCols[N][_nPosTES] ))
						If !Empty(SC7->C7_ZAPLDIR)
							If      SC7->C7_ZAPLDIR == "S" .and. SF4->F4_ESTOQUE <> "S" //Aplicação direta TES sem estoque
								Aviso("Problema no Estoque do TES", "O pedido de compras vinculada a essa NF foi criada para estoque. O TES deverá movimentar estoque.", {"Revisar"} , 2 , "Informe um TES condizente com o pedido de compras.")
								_lRet := .F.
							ElseIf  SC7->C7_ZAPLDIR <> "S" .and. SF4->F4_ESTOQUE = "S" //Estoque
								Aviso("Problema no Estoque do TES", "O pedido de compras vinculada a essa NF foi criada para aplicação direta. O TES não poderá movimentar estoque.", {"Revisar"} , 2 , "Informe um TES condizente com o pedido de compras.")
								_lRet := .F.
							EndIf
						EndIf
					EndIf
				EndIf
			Endif
		EndIf
	EndIf

	/* Inicio do bloco de validação do ICMS e IPI */
	// if _lRet .and. funName() = 'MATA103'
    if _lRet .and. !(fwisinCallStack('U_TIPROCNFE') .or. fwisinCallStack('U_TIPROCCTE'))

		cTexto := ''
		cSoluc := ''

		dbSelectArea( 'SF4' )
		SF4->(dbSetOrder(1))
		if SF4->(dbSeek(xFilial('SF4') + aCols[n][_nPosTES]))

			if nPosIcm > 0 .and. getMv('TI_VICM103',,.T.) /* Ativa a validação do ICMS no MATA103 */

				nXmlICM := aCols[n][nPosIcm]

				// if FwIsAdmin()
				// 	msgstop(cValToCHar(n),'linha')
				// 	msgstop(cValToCHar(nXmlICM),'nXmlICM')
				// 	msgstop(cFilAnt,'cFilant')
				// 	msgstop(xFilial('SF4'),'xFilial()')
				// 	msgstop(aCols[n][_nPosTES],'aCols[n][_nPosTES]')
				// 	msgstop(SF4->F4_CODIGO,'F4_CODIGO')
				// 	msgstop(SF4->F4_ICM,'F4_ICM')
				// endif

				if nXmlICM > 0 .and. SF4->F4_ICM <> 'S'
					_lRet  := .F.
					cTexto := 'Foi identificado que o TES ' + SF4->F4_CODIGO + ' não calcula ICMS, porém, há valor de ICMS no documento.'
					cSoluc := 'Selecione um TES que calcule ICMS.'
				endif

				if _lRet
					if nXmlICM = 0 .and. SF4->F4_ICM <> 'N'
						_lRet  := .F.
						cTexto := 'Foi identificado que o TES ' + SF4->F4_CODIGO + ' calcula ICMS, porém, não há valor de ICMS no documento.'
						cSoluc := 'Selecione um TES que NÃO calcule ICMS.'
					endif
				endif

			endif

			if _lRet

				if nPosIpi > 0 .and. getMv('TI_VIPI103',,.T.) /* Ativa a validação do IPI no MATA103 */

					nXmlIPI := aCols[n][nPosIpi]

					if _lRet
						if nXmlIPI > 0 .and. SF4->F4_IPI <> 'S'
							_lRet  := .F.
							cTexto := 'Foi identificado que o TES ' + SF4->F4_CODIGO + ' não calcula IPI, porém, há valor de IPI no documento.'
							cSoluc := 'Selecione um TES que calcule IPI.'
						endif
					endif

					if _lRet
						if nXmlIPI = 0 .and. SF4->F4_IPI <> 'N'
							_lRet  := .F.
							cTexto := 'Foi identificado que o TES ' + SF4->F4_CODIGO + ' calcula IPI, porém, não há valor de IPI no documento.'
							cSoluc := 'Selecione um TES que NÃO calcule IPI.'
						endif
					endif

				endif

			endif

		endif

		if !_lRet .and. !empty(cTexto)
			help('',1,'MT100LOK',,cTexto, 1, 0,Nil,Nil,Nil,Nil,Nil,{cSoluc})
		endif

	endif
	/* Fim do bloco de validação do ICMS e IPI */

	if isInCallStack('u_TiProcCTe')
		cCFOP := getCFXml(aCols[N][_nPosTES],aCols[N][_nPosCF])
		aCols[N][_nPosCF] := cCFOP
		if gdFieldPos('D1_CF') = _nPosCF
			gdFieldPut('D1_CF',cCFOP)
		endif
		if type('M->D1_CF') = 'C'
			M->D1_CF := CCFOP
		endif
	endif

	RestArea( _aArea )
	RestArea( _aAreaSC1 )
	RestArea( _aAreaSC7 )
	RestArea( _aAreaSF4 )

Return(_lRet)

static function getCFXml(cTes,cCFOP)

	local lGatCFOP := getMv('TI_GATCFOP',,.T.) .and. existBlock('TXGATCFOP') .and. FWisInCallStack('U_TIPROCCTE')
	local cRet     := cCFOP
	local cUFOri   := ''
	local cUFFim   := ''

	if lGatCFOP
		cUFOri := iif((cTabCab)->(fieldPos(cTabCab + '_UFORIT')) > 0,alltrim((cTabCab)->&(cTabCab + '_UFORIT')),'')
		cUFFim := iif((cTabCab)->(fieldPos(cTabCab + '_UFDEST')) > 0,alltrim((cTabCab)->&(cTabCab + '_UFDEST')),'')
		if !empty(cUFOri) .and. !empty(cUFOri)
			cRet   := u_txGatCfop(cTes,cUFOri,cUFFim)
		endif
	endif

return cRet
