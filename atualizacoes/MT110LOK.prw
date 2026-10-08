#Include 'Protheus.ch'
#Include "Totvs.ch"

/*
@Autor:       Andr Claro
@Data:        11/09/2023
@Descrio:   Validao dos itens da solicitao de compras
*/

User Function MT110LOK()  

	Local _lRet		  := .T.
	Local _aAreaSBM   := SBM->(GetArea())
	Local _aAreaSB1   := SB1->(GetArea())
	Local _cProduto	  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_PRODUTO'})]
	Local _cRateio	  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_RATEIO'})]
	Local _cCusto	  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CC'})]
	Local _cCLVL	  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CLVL'})]
	Local _cFilCTT    := xFilial("CTT")
	Local _cChvZGD    := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_ZCODKAP'})]+ aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_ZREVKAP'})] + aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_ZITEKAP'})]
  
	Local _cItem	  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_ITEM'})]
	Local _cBolPims	  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_NRBPIMS'})]
	Local _cUserGrp   := SuperGetMv("MV_ZUSRGRP",.F.,"") // Usurios que podem dar manuteno nos PC/SC especficos
	Local _cGrpUser   := SuperGetMv("MV_ZGRBLSC",.F.,"") // Grupos especficos
	Local _cGrpProd   := "" 
	Local aArea 	  := GetArea()
	Local _cCtaOrc    := ""
	Local _nX 		  := 0
	Local _nY 		  := 0
	Local _nVlrPCO    := 0
	Local _nPosPrc    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_PRECO'})
	Local _nQtdSC     := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_QUANT'})]
	Local _cAplDir    := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_ZAPLDIR'})] 
	Local _cNRBPIMS   := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_NRBPIMS'})]
	Local _lVldTpSV   := SUPERGETMV("MV_ZPCOTSV", .F., .F. )
	Local _cUsrTI	  := SuperGetMv("MV_ZUSERTI",.F.,"")
	Local _cCCTI	  := SuperGetMv("MV_ZCCTI",.F.,"")
	Local _lMVZVLDPCO := SuperGetMv("MV_ZVLDPCO",.F.,.T.) //usa validao do PCO ou no?
	Local _nDprdobsol := SuperGetMv("MV_XDOBSOL",.F.,365) //Quantidade de dias, produto Obsoleto. 
	Local _lCapex 	  := .F.

	Local cMyAliasQRY := GetNextAlias()
	Local nDias       := 0

	If SuperGetMv("MV_ZSCKAPX",.F.,.T.)
		_lCapex := Type("_cCapOpex")<>"U" .and. SC1->(FieldPos("C1_ZTIPOSC")) > 0
		If _lCapex 
			_lCapex := SubStr(_cCapOpex,1,1) == "C"
		EndIf
	EndIf 

	//Caso esteja deletado a linha no considera retorna TRUE
	If aCols[n][Len(aHeader)+1]
		RestArea(aArea)
		Return .T. 
	EndIf

	If _cRateio <> "1" .and. Empty(_cCusto) //Se no tem rateio
		Aviso("ATENO","C. Custo Obrigatrio para incluso de SC sem rateio.",{"REVISAR"},2, "SC sem RATEIO com CC vazio.")
		_lRet := .F. 
		Return _lRet 
	EndIf


/*
	If Alltrim(_cCusto) $ _cCCTI .and. !Empty(_cUsrTI)
		If !(__cUserID $ _cUsrTI)
			Aviso("Usurio sem autorizao para o Centro de Custo: "+_cCusto,;
			"O centro de custo "+_cCusto+" s poder ser usado pelos usurios: "+_cUsrTI, {"Revisar"} , 2 , "Uso indevido de centro de custo: ")
			Return .F.
		Elseif _cRateio == "1" //Se tiver rateio e for centro de custo de TI
			Aviso("Centros de Custo de TI no devem ter rateio: "+_cCusto,;
			"O centro de custo "+_cCusto+" s poder ser usado sem rateio. ", {"Revisar"} , 2 , "Uso indevido de centro de custo com rateio. ")
			Return .F.
		EndIf 
	EndIf
*/

/*
Andr Claro
Tratamento para informar ou bloquear a incluso de produtos controlados por CD.
*/

If !ISINCALLSTACK( "U_ACMVCZGQ" )  //PROJETO CD - 2024
	_lValZGN := .f.
	DbSelectArea("ZGM")
	ZGM->(DbSetOrder(1))
	ZGM->(DbGoTop())
	While ZGM->(!EOF())
		If ZGM->ZGM_MSBLQL <> '1' .AND. ZGM->ZGM_FILORI == cFilAnt
			_lValZGN := .T.
			Exit
		EndIf
	ZGM->(DbSkip())
	EndDo
	If _lValZGN
		DbSelectArea("ZGN")
		ZGN->(DbSetOrder(1))
		ZGN->(DbGoTop())
		If ZGN->(DbSeek(xFilial("ZGN") + _cProduto ))
			If ZGN->ZGN_MSBLQL <> "1"
				If SuperGetMv("MV_ZZGNBLQ",.F.,.F.)
					Aviso("ATENO","Esse produto  controlado por Centro de Distribuo. Utilize a Requisio ao CD para solicitar.",{"OK"},2)
					Return .F.
				Else
					Aviso("ATENO","Esse produto  controlado por Centro de Distribuo. Utilize a Requisio ao CD para solicitar.",{"OK"},2)
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+_cProduto))

		/*Inicio Ajuste Capex Andr Claro 12/2022
		@Autor:      Andr Claro
		@Data:       02/12/2022
		@Descrio:  Ajuste Capex - Solicitao de compras dos grupos de capex somente via Capex.
		*/
		If Alltrim(SB1->B1_GRUPO) $ SuperGetMv("MV_ZGRPCPX",.F.,"") .and. !IsInCallStack("U_ZAPRVZGC")
			Aviso("Grupo de produtos referente a CAPEX",;
				"O produto "+Alltrim(_cProduto)+" pertence ao grupo "+Alltrim(SB1->B1_GRUPO)+" o qual refere-se";
				+" ao Capex. Para solicitar esse produto utilize o processo de Capex." ,{"Sair"}, 2,"No  possvel incluir SC de produto do Grupo de Capex ")
			_lRet := .F.
			RestArea(_aAreaSBM)
			RestArea(_aAreaSB1)
			RestArea(aArea)
			Return _lRet
		EndIf
		/*Fim Ajuste Capex Andr Claro 12/2022*/


		    /*
			@Autor:       Andr Claro
			@Data:        13/09/2023
			@Descrio:   Se todas validaes do ponto de entrada chegaram ok at aqui, 
						  sigo para a validao do PCO desde que a filial valide PCO e no esteja sendo includa pelo Capex (ZAPRVZGC)
			*/
		If _lMVZVLDPCO .and. !IsInCallStack("U_ZAPRVZGC")  .and. !IsInCallStack("U_ACMVZC8A") //.AND. Empty(_cBolPims) //Se valida PCO e numero do boletim do pims no foi preenchido.
			DbSelectArea("SBM")
			SBM->(DbSetOrder(1))
			SBM->(DbGoTop())
			If SBM->(DbSeek(xFilial("SBM") + SB1->B1_GRUPO ))
				If SBM->BM_ZMOVEST <> "N" .OR. !SuperGetMV("MV_ZPCOSBM",.F.,.F.)
					_cCtaOrc := IIF(cFilAnt $ GetMv("MV_ZFLPCOD"), SB1->B1_XCTADES, SB1->B1_RCONTA)
					If _cAplDir == "S" .and. SuperGetMV('MV_ZAPLDIR',.F.,.T.)//Se estoque e usando conta de estoque //PCO2025//Se estoque
						_cCtaOrc := SB1->B1_CONTA
					Else
						_cCtaOrc := IIF(cFilAnt $ GetMv("MV_ZFLPCOD"), SB1->B1_XCTADES, SB1->B1_RCONTA)
						// 202409 - VALIDAO SE O CENTRO DE CUSTO  OPERACIONAL OU ADM.
						_cCtaOrc := U_ACRCTAPCO(_cCtaOrc, _cProduto, _cCusto)
					EndIf

					If SubStr(_cCtaOrc,1,1) > '2' .OR. 1 == 1 /////validaremos contas de estoque tambm.
						If _cRateio <> "1" //Se no tem rateio
							If SubStr(_cCusto,1,1) <> '9' .AND. GetAdvFVal("CTT","CTT_XBIPCO", xFilial("CTT") + _cCusto,1,"" ) <> "2"
								If U_ACEXCZMC("900051", "", SB1->B1_COD, _cCtaOrc, _cCusto, "", "")
									If !U_ACTemOrc(cFilAnt, _cCtaOrc, _cCusto, SubStr(DtoS(dDataBase),1,6), _nVlrPCO )
										_lRet := .F. 
										Return _lRet 
									EndIf
								EndIf
							EndIf
						Else
							If Len(ACPISCX) > 0
								For _nX := 1 to Len(ACPISCX) //todos itens do rateio
									If ACPISCX[_nX][1] == _cItem //Tenho que validar somente o item corrente!
										For _nY := 1 to Len( ACPISCX[_nX][2] )
											_cCusto := ACPISCX[_nX][2][_nY][3]
											
											// no rateio, s vou chamar a rotina caso a conta no seja de estoque.
											If ! (_cAplDir == "S" .and. SuperGetMV('MV_ZAPLDIR',.F.,.T.) )  //Se estoque e usando conta de estoque //PCO2025//Se estoque
												// 202409 - VALIDAO SE O CENTRO DE CUSTO  OPERACIONAL OU ADM.
												_cCtaOrc := U_ACRCTAPCO(_cCtaOrc, _cProduto, _cCusto)
											EndIf									
											
											If SubStr(_cCusto,1,1) <> '9' ;
												.AND. GetAdvFVal("CTT","CTT_XBIPCO", xFilial("CTT") + _cCusto ,1,"" ) <> "2" ///// ANDRE CLARO 06/09/2023 AJUSTE PARA DESCONSIDERAR CCs QUE NO VO PARA O PCO.
												If U_ACEXCZMC("900051", "", SB1->B1_COD, _cCtaOrc, _cCusto, "", "")
													If !U_ACTemOrc(cFilAnt, _cCtaOrc, _cCusto,;
															SubStr(DtoS(dDataBase),1,6), 0 )
														_lRet := .F.  
														Return _lRet 
													EndIf
												EndIf
											EndIf
										Next _nY
									EndIf
								Next _nX
							EndIf		
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Endif

	
	

	_cGrpProd := POSICIONE("SB1",1,xFilial("SB1")+_cProduto,"B1_GRUPO")

		//Valida Grupos 444 e 901 
	If _lRet .AND. Alltrim(_cGrpProd) == "901" .AND. !(Alltrim(__cUserID) $ SUPERGETMV("MV_XNOBLSC",.F.,"000000"))
		Help(NIL, NIL, "HELP", NIL, "Usurio sem permisso para incluso de SC com o Grupo de Produto 901. Somente usurios includos no parmetro MV_XNOBLSC tem permisso para utilizar o grupo de produtos 901.", 1,0, NIL, NIL, NIL, NIL, NIL,;
			{"Dvidas entrar em contato com o time de Governana de Cadastros"})
		_lRet := .F.
	EndIf

	If _lRet .AND.  Alltrim(_cGrpProd) == "444" .AND. !(Alltrim(__cUserID) $ SUPERGETMV("MV_XNBL444",.F.,"000000"))
		Help(NIL, NIL, "HELP", NIL, "Usurio sem permisso para incluso de SC com o Grupo de Produto 444. Somente usurios includos no parmetro MV_XNBL444 tem permisso para utilizar o grupo de produtos 444.", 1,0, NIL, NIL, NIL, NIL, NIL,;
			{"Dvidas entrar em contato com o time de Governana de Cadastros"})
		_lRet := .F.
	EndIf 

	If _lRet .AND.  Alltrim(_cGrpProd) == "102" .AND. _cAplDir == "S" .AND. !(Alltrim(__cUserID) $ SUPERGETMV("MV_XNBL102",.F.,"000000"))
			MsgAlert("Produtos do grupo 102 no devem movimentar estoque!", "TOTVS")
		_lRet := .F.
	EndIf

//Se for via integracao não valida prod obsoleto
If Empty(_cNRBPIMS) 
	// Valida produto obsoleto no armazm 87
	If _lRet 
	    DbSelectArea("SB2")
	    DbSetOrder(1)  // ndice Produto + Armazm 

		If DbSeek(xFilial("SB2") + _cProduto + "87") .AND. (SB2->B2_QATU > 0) 
		    MsgAlert("O produto " + _cProduto + " est obsoleto e no pode ser solicitado para compra at que seu saldo seja consumido!" + ;
		            CHR(13) + CHR(10) + ;
		            "Saldo atual: " + Str(SB2->B2_QATU), "Ateno")
		    _lRet := .F. 
		EndIf
		
	    DbCloseArea()
	EndIf
	// Verifica a ltima movimentao na SD3
	If _lRet           
        // Executa a consulta e armazena no alias "cMyAliasQRY"
        BeginSQL Alias cMyAliasQRY
		 %noparser%
 			SELECT FORMAT(CONVERT(DATE,MAX(ULTIMA_MOV)), 'dd/MM/yyyy') AS ULTIMA_MOV 
			FROM (
			 	SELECT MAX(D3.D3_EMISSAO) AS ULTIMA_MOV
			            FROM SD3010 AS D3 WITH(NOLOCK)
						INNER JOIN  SB2010 AS B2 WITH(NOLOCK) 
							ON D3.D3_FILIAL = B2.B2_FILIAL 
							AND D3.D3_COD = B2.B2_COD
							AND B2.D_E_L_E_T_ = ''
			            WHERE B2.B2_QATU > 0 AND D3.D_E_L_E_T_ = '' AND D3.D3_ESTORNO = ''
							AND D3.D3_COD  = %exp:_cProduto%
			            	AND D3.D3_FILIAL = %exp:xFilial('SD3')%
			UNION ALL
			 	SELECT MAX(D2.D2_EMISSAO) AS ULTIMA_MOV
			            FROM SD2010 AS D2 WITH(NOLOCK)
						INNER JOIN  SB2010 AS B2 WITH(NOLOCK) 
							ON D2.D2_FILIAL = B2.B2_FILIAL 
							AND D2.D2_COD = B2.B2_COD
							AND B2.D_E_L_E_T_ = ''
			            WHERE B2.B2_QATU > 0 AND D2.D_E_L_E_T_ = ''  
							AND D2.D2_COD  = %exp:_cProduto%
			            	AND D2.D2_FILIAL = %exp:xFilial('SD2')%
			UNION ALL
			 	SELECT MAX(D1.D1_EMISSAO) AS ULTIMA_MOV
			            FROM SD1010 AS D1 WITH(NOLOCK)
						INNER JOIN  SB2010 AS B2 WITH(NOLOCK) 
							ON D1.D1_FILIAL = B2.B2_FILIAL 
							AND D1.D1_COD = B2.B2_COD
							AND B2.D_E_L_E_T_ = ''
			            WHERE B2.B2_QATU > 0 AND D1.D_E_L_E_T_ = ''  
							AND D1.D1_COD  = %exp:_cProduto%
			            	AND D1.D1_FILIAL = %exp:xFilial('SD1')%		
			)MOVIMENTACAO		
			EndSQL 

        DbSelectArea(cMyAliasQRY)
        If !Empty((cMyAliasQRY)->ULTIMA_MOV)
			nDias := DateDiffDay( Date() , CToD(AllTrim((cMyAliasQRY)->ULTIMA_MOV)) )
        EndIf

        DbCloseArea()

	    // Se a ultima movimentao foi ha _nDprdobsol dias ou mais, bloqueia a solicitao
    	If nDias >= _nDprdobsol
    	    MsgAlert("O produto " + _cProduto + " esta obsoleto e nao pode ser solicitado para compra ate que seu saldo seja consumido!", "Atencao")
    	    _lRet := .F. 
    	EndIf
	EndIf
EndIf	


	//Valida grupo de produtos TI 
	/*
	If !Empty(_cUserGrp) .AND. !Empty(_cGrpUser)
		If Alltrim(_cGrpProd) $ _cGrpUser .and. !Alltrim(__cUserId) $ _cUserGrp
			_lRet := .F. 
			MsgAlert('Usuario sem permisso para solicitar produtos de TI. Por gentileza abra um chamado solicitando o produto.')		
		EndIf
	EndIf
*/

// Comentado para processo PCO
//Funo para realizar a validao Grupo de Produtos X Usurio na rotina Solicitao de Compras
/*	
    If _lRet .AND. ExistBlock("'FSCO04WK") 
        _lRet := ExecBlock("FSCO04WK",.F.,.F.,{'C1_PRODUTO'})
    EndIf
*/

/*
	If _lRet .AND. ExistBlock("FSC1ITECTA") 
        _lRet := ExecBlock("FSC1ITECTA",.F.,.F.,{'C1_CC', 'C1_ITEMCTA'})
    EndIf
*/

	/*VALIDAES CAPEX 
	@Autor:      Andr Claro    andre.claro@acclaro.com.br / 35 998775495
	@Descrio:  Validaes quanto ao itens de Capex
	*/
	If _lCapex

		/*Itens Capex no podem ser para estoque*/

		If _lCapex //_cCapOpex
			If _cAplDir == "S"
				Aviso("SC DO TIPO CAPEX",;
					"O produto "+Alltrim(_cProduto)+" est marcado para MOVIMENTAR ESTOQUE. ";
					+" Solicitaes de CAPEX no devem movimentar estoque." ,{"Sair"}, 2,;
					CHAR(13)+CHAR(10)+"Revise o campo aplicao direta para que fique coerente com o tipo da SC.")
				_lRet := .F.
			EndIf
		EndIf

			//Valida Grupo 102  
		If _lRet .AND.  Alltrim(_cGrpProd) == "102"
			Help(NIL, NIL, "HELP", NIL, "Grupo de produto 102 no  permitido para SC Capex.", 1,0, NIL, NIL, NIL, NIL, NIL,;
				{"Duvidas entrar em contato com o time de Cadastro CSC"})
			_lRet := .F.
		EndIf 

		If Empty(_cCLVL) .AND. _lRet
			Aviso("SC DO TIPO CAPEX - CLASSE DE VALOR",;
				"Classe de valor obrigatria para imobilizado em andamento. " ,{"Sair"}, 2,;
				CHAR(13)+CHAR(10)+"Revise o campo classe de valor.")
				_lRet := .F.
		Else
			DbSelectArea("ZGD")
			ZGD->(DbSetOrder(1))
			ZGD->(DbGoTop())
			If Empty(_cChvZGD)
				Aviso("SC DO TIPO CAPEX - CODIGO CAPEX",;
					"O Capex / Item no foi informado" ,{"Sair"}, 2,;
					CHAR(13)+CHAR(10)+"Revise o campo Capex / item Capex")
					_lRet := .F.							
			ElseIf ZGD->(DbSeek(xFilial("ZGD") + _cChvZGD ))
				If ZGD->ZGD_CLVL <> _cCLVL
					Aviso("SC DO TIPO CAPEX - CLASSE DE VALOR",;
						"O Classe de valor informada ("+_cCLVL+")  diferente da informada no Capex ("+Alltrim(ZGD->ZGD_CLVL)+")" ,{"Sair"}, 2,;
						CHAR(13)+CHAR(10)+"Revise o campo Capex / item Capex")	
						_lRet := .F.				
				ElseIf ZGD->ZGD_STAPPR <> "A"

					Aviso("SC DO TIPO CAPEX - NO APROVADO",;
						"O Capex informado ainda no foi aprovado pelo Setor Patrimnio!" ,{"Sair"}, 2,;
						CHAR(13)+CHAR(10)+"Entre em contato com o setor de Patrimnio")	
						_lRet := .F.								
				EndIf
			Else
				Aviso("SC DO TIPO CAPEX - CODIGO CAPEX",;
					"O Capex / Item informado no existe nessa filial " ,{"Sair"}, 2,;
					CHAR(13)+CHAR(10)+"Revise o campo Capex / item Capex")
					_lRet := .F.
			EndIf
		EndIf

		If _lRet
			DbSelectArea("CTT")
			CTT->(DbSetOrder(1))

			If _cRateio <> "1" //Se no tem rateio
				CTT->(DbGoTop())
				If CTT->(DbSeek(_cFilCTT + _cCusto))
					If CTT->CTT_XTIPO <> "5"
						Aviso("SC DO TIPO CAPEX - CC INVLIDO",;
							"O Centro de Custo "+_cCusto+" no se trata de imobilizado em andamento. " ,{"Sair"}, 2,;
							CHAR(13)+CHAR(10)+"Revise o campo centro de custo.")
						_lRet := .F. 
					EndIf
				EndIf 
			Else
				If Len(ACPISCX) > 0
					For _nX := 1 to Len(ACPISCX) //todos itens do rateio
						If ACPISCX[_nX][1] == _cItem //Tenho que validar somente o item corrente!
							For _nY := 1 to Len( ACPISCX[_nX][2] )
								_cCusto := ACPISCX[_nX][2][_nY][3]
								CTT->(DbGoTop())
								If CTT->(DbSeek(_cFilCTT + _cCusto))
									If CTT->CTT_XTIPO <> "5"
										Aviso("SC DO TIPO CAPEX - CC INVLIDO",;
											"O Centro de Custo "+_cCusto+" no se trata de imobilizado em andamento. " ,{"Sair"}, 2,;
											CHAR(13)+CHAR(10)+"Revise o campo centro de custo.")
										_lRet := .F.
										Exit
									EndIf
								EndIf
							Next _nY
						EndIf
					Next _nX
				EndIf		
			EndIf
		EndIf
	else

		If _lRet
			DbSelectArea("CTT")
			CTT->(DbSetOrder(1))

			If _cRateio <> "1" //Se no tem rateio
				CTT->(DbGoTop())
				If CTT->(DbSeek(_cFilCTT + _cCusto))
					If CTT->CTT_XTIPO == "5"
						Aviso("SC NO  CAPEX - CC INVLIDO",;
							"O Centro de Custo "+_cCusto+" se trata de imobilizado em andamento. " ,{"Sair"}, 2,;
							CHAR(13)+CHAR(10)+"Altere o tipo da SC para CAPEX.")
						_lRet := .F.
					EndIf
				EndIf
			Else
				If Len(ACPISCX) > 0
					For _nX := 1 to Len(ACPISCX) //todos itens do rateio
						If ACPISCX[_nX][1] == _cItem //Tenho que validar somente o item corrente!
							For _nY := 1 to Len( ACPISCX[_nX][2] )
								_cCusto := ACPISCX[_nX][2][_nY][3]
								CTT->(DbGoTop())
								If CTT->(DbSeek(_cFilCTT + _cCusto))
									If CTT->CTT_XTIPO == "5"
										Aviso("SC NO  CAPEX - CC INVLIDO",;
											"O Centro de Custo "+_cCusto+" se trata de imobilizado em andamento. " ,{"Sair"}, 2,;
											CHAR(13)+CHAR(10)+"Altere o tipo da SC para CAPEX.")
										_lRet := .F.
										Exit
									EndIf
								EndIf
							Next _nY
						EndIf
					Next _nX
				EndIf		
			EndIf
		EndIf

	EndIf


	RestArea(_aAreaSBM)
	RestArea(_aAreaSB1)
	RestArea(aArea)

Return(_lRet)
