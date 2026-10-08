#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} TM200DEL
Ponto de Entrada - executado durante o Estorno de um cálculo de frete. Vale lembrar que o PE não impede o estorno do cálculo, somente efetua procedimentos como mensagens e outras validações.
@type user function
@author Pedro Lindenberg
@since 18/03/2024
@version version
/*/
User Function TM200OK()
	Local aAreas := {Getarea(),ZA1->(GetArea()),SF1->(GetArea()),SD1->(GetArea()),SE2->(GetArea())}
	Local aCab := {}
	Local aItens := {}
	Local aLinha := {}
	Local lIsFil   := fVldFil()
	Local lErro   := .F.

	Local aLogAuto := {}
	Local cErro := ""
	Local lRet := .T.
	Local nY := 0
	Local nIsEsto := PARAMIXB[1]

	oLog             := MASXLOG():New()
	cIdtoken         := oLog:idtoken

	IF lIsFil .AND. DT6->DT6_STATUS == 'C' .AND. nIsEsto == 3

		ZA1->(DbSetOrder(1))
		IF ZA1->(DbSeek(xFilial("DT6")+DT6->DT6_FILDOC+DT6->DT6_DOC+DT6->DT6_SERIE))

			SF1->(DbSetOrder(1))
			IF SF1->(DbSeek(ZA1->ZA1_FILDCE+ZA1->ZA1_DOCENT+ZA1->ZA1_SERENT+ZA1->ZA1_FORNEC+ZA1->ZA1_LOJA))

				SD1->(DbSetOrder(1))
				IF SD1->(DbSeek(ZA1->ZA1_FILDCE+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))

					IF !EMPTY(SF1->F1_DUPL)

						cFilBkp := cFilAnt
						cFilAnt := ZA1->ZA1_FILDCE
						SE2->(DbSetOrder(1))
						IF SE2->(DbSeek(xFilial("SE2")+SF1->F1_PREFIXO+SF1->F1_DUPL))

							IF !Empty(SE2->E2_BAIXA)

								IF MSGYESNO("O Documento de Entrada não será excluído, pois existe título a pagar baixado, atrelado a ele! Deseja prosseguir com o estorno do CT-e?","ATENCAO")

									oLog:GRAVALOG("I001",cIdtoken, "O Documento de Entrada não será excluído, pois existe título a pagar baixado, atrelado a ele!" ,cErro,"2","DCE",Alltrim(cFilAnt+" / "+SF1->F1_DOC+" / "+SF1->F1_SERIE))
									U_MASENVEM( cFilAnt,SF1->F1_DOC,SF1->F1_SERIE, DT6->DT6_FILDOC+" "+DT6->DT6_DOC+" "+DT6->DT6_SERIE, cErro)

									IF RecLock('ZA1',.F.)
										ZA1->ZA1_CANCEL := 'S'
										ZA1->ZA1_DTCANC := Date()
										ZA1->(MsUnlock())
									ENDIF

									cFilAnt := cFilBkp

								ELSE

									lRet := .F.
									cFilAnt := cFilBkp
									RETURN .F.

								ENDIF

							ELSE

								aAdd(aCab, {"F1_DOC",     SF1->F1_DOC,     Nil})
								aAdd(aCab, {"F1_SERIE",   SF1->F1_SERIE,   Nil})
								aAdd(aCab, {"F1_FORNECE", SF1->F1_FORNECE, Nil})
								aAdd(aCab, {"F1_LOJA",    SF1->F1_LOJA,    Nil})
								aAdd(aCab, {"F1_TIPO",    SF1->F1_TIPO,    Nil})
								aAdd(aCab, {"F1_ESPECIE", SF1->F1_ESPECIE, Nil})

								aLinha := {}
								aAdd(aLinha,  {"D1_DOC",     SD1->D1_DOC,     Nil})
								aAdd(aLinha,  {"D1_SERIE",   SD1->D1_SERIE,   Nil})
								aAdd(aLinha,  {"D1_FORNECE", SD1->D1_FORNECE, Nil})
								aAdd(aLinha,  {"D1_LOJA",    SD1->D1_LOJA,    Nil})
								aAdd(aLinha,  {"D1_TIPO",    SD1->D1_TIPO,    Nil})
								aAdd(aLinha,  {"D1_ITEM",    SD1->D1_ITEM,    Nil})
								aAdd(aLinha,  {"D1_COD",     SD1->D1_COD,     Nil})
								aAdd(aItens, aClone(aLinha))

								//Tratativa para alterar a filial conforme o Doc. de Entrada
								lMsErroAuto := .F.
								MSExecAuto({|x, y, z| MATA103(x, y, z)}, aCab, aItens, 5)

								IF lMsErroAuto
									// MostraErro()
									aLogAuto    := GetAutoGrLog()

									FOR nY := 1 To Len(aLogAuto)
										cErro += aLogAuto[nY] + CRLF
									NEXT nY

									lRet := .F.

									oLog:GRAVALOG("I001",cIdtoken, "Erro ao Excluir o Documento de Entrada" ,cErro,"2","DCE",Alltrim(cFilAnt+" / "+SF1->F1_DOC+" / "+SF1->F1_SERIE))
									U_MASENVEM( cFilAnt,SF1->F1_DOC,SF1->F1_SERIE, DT6->DT6_FILDOC+" "+DT6->DT6_DOC+" "+DT6->DT6_SERIE, cErro)

								ELSE

									IF RecLock('ZA1',.F.)
										ZA1->ZA1_CANCEL := 'S'
										ZA1->ZA1_DTCANC := Date()
										ZA1->(MsUnlock())
									ENDIF

								ENDIF

							ENDIF

						ELSE

							lRet := .F.
							cErro := "Titulo não encontrado! Verifique"

						ENDIF

					ENDIF

				ENDIF

			ELSE

				lRet := .F.
				cErro := "Documento não encontrado! Verifique"

			ENDIF

		ENDIF

		cFilAnt := cFilBkp

	ENDIF

	IF lErro
		U_MASENVEM({ZA1->ZA1_DOCENT,ZA1->ZA1_SERENT,ZA1->ZA1_FILDCE,ZA1->ZA1_CTECHV,cErro})
	ENDIF

	AEval(aAreas,{|x,y| RestArea(x) })

RETURN lRet

/*/{Protheus.doc} fVldFil
    Função responsável por validar se o cliente é Filial
    @type  Static Function
    @author Pedro Lindenberg
    @since 13/03/2024
/*/
Static Function fVldFil()
	Local lIsFil := .T.
	Local cFilAlias := "TRB2" + GetNextAlias() + StrTran(Time(), ":", "")
	Local cQry := ""
	Local cCliCgc := ""
	Private oQuery

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	IF SA1->(DbSeek(xFilial("SA1")+DT6->DT6_CLIDEV+DT6->DT6_LOJDEV))
		cCliCgc := SA1->A1_CGC
	ENDIF

	cQry += "SELECT M0_CODIGO, M0_CODFIL FROM SYS_COMPANY SYS" + CRLF
	cQry += "WHERE SYS.D_E_L_E_T_ = ' ' "     + CRLF
	cQry += "AND SYS.M0_CGC = ? " + CRLF
	oQuery := FWPreparedStatement():New(cQry)
	oQuery:setParams({cCliCgc})
	MPSysOpenQuery(oQuery:getFixQuery(), cFilAlias)

	(cFilAlias)->(DBGoTop())

	IF !(cFilAlias)->(Eof())
		lIsFil := .T.
	ELSE
		lIsFil := .F.
	ENDIF

	(cFilAlias)->(DbCloseArea())

RETURN lIsFil
