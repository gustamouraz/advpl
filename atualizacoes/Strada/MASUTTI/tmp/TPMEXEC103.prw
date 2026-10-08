//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} zDelDoc
Função para excluir vários documentos de entrada ao mesmo tempo
@author Atilio
@since 23/02/2018
@version 1.0
@type function
/*/

User Function TPMEXECDE()
	RpcSetEnv('01','020106')

	Local aArea      := GetArea()
	Local cPerg      := "X_PTCOMM07"
	Local dUltFec    := GetMV('MV_ULMES')
	Private cFornec  := ""
	Private cLoja    := ""
	Private dDataAux := sToD("")

	Processa({|| fProcDel()}, "Excluindo Docs de Entrada...")

	RpcClearEnv()
Return

Static Function fProcDel()
	Local cQrySF1       := ""
	Local nTotal        := 0
	Local nAtual        := 0
	Local cDocs         := ""
	Local lErro         := .F.
	Local aLinha        := {}
	Local aCabSF1       := {}
	Local aDadSD1       := {}
	Local nRecBkp       := 0
	Local cDocBkp       := ""
	Local cKeyBkp       := ""
	Local cError        := ""
	Private lMsErroAuto := .F.

	DbSelectArea('SF1')
	SF1->(DbSetOrder(1)) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	SF1->(DbGoTop())
	DbSelectArea('SD1')
	SD1->(DbSetOrder(1)) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	SD1->(DbGoTop())
	DbSelectArea('SA2')
	SA2->(DbSetOrder(1)) // A2_FILIAL+A2_COD+A2_LOJA
	SA2->(DbGoTop())

	If SA2->(DbSeek(FWxFilial('SA2') + '000507' + '4'))

		//Pega todos os dados via query
		cQrySF1 := " SELECT "                                                               + CRLF
		cQrySF1 += "     SF1.R_E_C_N_O_ AS F1REC, "                                          + CRLF
		cQrySF1 += "     F1_DOC AS DOCUMENTO, "                                              + CRLF
		cQrySF1 += "     F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO AS CHAVE "     + CRLF
		cQrySF1 += " FROM "                                                                 + CRLF
		cQrySF1 += "     " + RetSQLName('SF1') + " SF1 "                                     + CRLF
		cQrySF1 += " WHERE "                                                                + CRLF
    cQrySF1 += "     F1_DTDIGIT >= '20240509' "                     + CRLF
		cQrySF1 += "     AND SF1.D_E_L_E_T_ = ' ' "                                          + CRLF
		TCQuery cQrySF1 New Alias "QRY_SF1"

		//Pega o tamanho total de registros e seta na régua
		Count To nTotal
		ProcRegua(nTotal)
		QRY_SF1->(DbGoTop())

		//Se houver dados na Query
		If ! QRY_SF1->(EoF())

			//Enquanto houver dados
			While ! QRY_SF1->(EoF())
				nAtual++
				IncProc("Analisando documento " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

				//Atualiza a variável
				cDocs += '- ' + Alltrim(QRY_SF1->DOCUMENTO) + ';' + CRLF

				QRY_SF1->(DbSkip())
			EndDo

			cDocs := "Fornecedor: " + SA2->A2_COD + ' / ' + SA2->A2_LOJA + ' (' + Alltrim(SA2->A2_NOME) + ')' + CRLF +;
				'Terá o(s) seguinte(s) documento(s) excluído(s) - Tanto o Documento de Entrada como a Pré Nota: ' + CRLF + cDocs + CRLF + CRLF + 'Confirma?'

			//Mostra a pergunta se realmente quer continuar
			If Aviso("Atenção", cDocs, {"Sim","Nao"}, 3) == 1
				ProcRegua(nTotal)
				nAtual := 0

				//Posiciona no topo da query, e percorre os dados
				QRY_SF1->(DbGoTop())
				While ! QRY_SF1->(EoF())
					nAtual++
					IncProc("Excluindo documento " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

					//Armazena o RecNo, e a chave da tabela, e o documento
					lErro   := .F.
					aCabSF1 := {}
					aDadSD1 := {}
					nRecBkp := QRY_SF1->F1REC
					cDocBkp := QRY_SF1->DOCUMENTO
					cKeyBkp := QRY_SF1->CHAVE

					//Posiciona na SF1, monta o cabeçalho do array
					SF1->(DbGoTop())
					If SF1->(DbSeek(cKeyBkp))
						aAdd(aCabSF1, {"F1_DOC",     SF1->F1_DOC,     Nil})
						aAdd(aCabSF1, {"F1_SERIE",   SF1->F1_SERIE,   Nil})
						aAdd(aCabSF1, {"F1_FORNECE", SF1->F1_FORNECE, Nil})
						aAdd(aCabSF1, {"F1_LOJA",    SF1->F1_LOJA,    Nil})
						aAdd(aCabSF1, {"F1_TIPO",    SF1->F1_TIPO,    Nil})
						aAdd(aCabSF1, {"F1_ESPECIE", SF1->F1_ESPECIE, Nil})

						//Posiciona na SD1
						SD1->(DbGoTop())
						If SD1->(DbSeek(FWxFilial('SD1') + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))

							//Percorre os itens e monta o array de itens
							While ! SD1->(EoF())               .And.;
									SD1->D1_DOC     == SF1->F1_DOC     .And.;
									SD1->D1_SERIE   == SF1->F1_SERIE   .And.;
									SD1->D1_FORNECE == SF1->F1_FORNECE .And.;
									SD1->D1_LOJA    == SF1->F1_LOJA

								aLinha := {}
								aAdd(aLinha,  {"D1_DOC",     SD1->D1_DOC,     Nil})
								aAdd(aLinha,  {"D1_SERIE",   SD1->D1_SERIE,   Nil})
								aAdd(aLinha,  {"D1_FORNECE", SD1->D1_FORNECE, Nil})
								aAdd(aLinha,  {"D1_LOJA",    SD1->D1_LOJA,    Nil})
								aAdd(aLinha,  {"D1_TIPO",    SD1->D1_TIPO,    Nil})
								aAdd(aLinha,  {"D1_ITEM",    SD1->D1_ITEM,    Nil})
								aAdd(aLinha,  {"D1_COD",     SD1->D1_COD,     Nil})
								aAdd(aDadSD1, aClone(aLinha))

								SD1->(DbSkip())
							EndDo

							//Ordena pelo número do item
							aSort(aDadSD1, , , { |x, y| x[6] < y[6] })
						EndIf

						//Começa o controle de transação
						Begin Transaction

							//Caso haja Status, é Documento de Entrada
							If ! Empty(SF1->F1_STATUS)

								//Chama o Execauto de exclusão de documento de entrada
								lMsErroAuto := .F.
								MSExecAuto({|x, y, z| MATA103(x, y, z)}, aCabSF1, aDadSD1, 5)

								//Se houve erro, mostra o erro, disarma a transação e atualiza a variável
								If lMsErroAuto
									MostraErro()
									DisarmTransaction()
									lErro := .T.
									cError += "- Documento '" + cDocBkp + "', não foi possível excluir Documento de Entrada!" + CRLF
								EndIf
							EndIf

							//Caso não haja erro
							If ! lErro

								//Posiciona novamente no documento
								SF1->(DbGoTop())
								If SF1->(DbSeek(cKeyBkp))

									//Se for o mesmo, verifica se o status está em branco (é uma pré nota)
									If Empty(SF1->F1_STATUS)

										//Chama o Execauto de exclusão da pré nota
										lMsErroAuto := .F.
										MSExecAuto({|x, y, z| MATA140(x, y, z)}, aCabSF1, aDadSD1, 5)

										//Se houve erro, mostra o erro, disarma a transação e atualiza a variável
										If lMsErroAuto
											MostraErro()
											DisarmTransaction()
											lErro := .T.
											cError += "- Documento '" + cDocBkp + "', não foi possível excluir a Pré Nota de Entrada!" + CRLF
										EndIf
									EndIf
								EndIf
							EndIf

						End Transaction

					Else
						cError += "- Documento '" + cDocBkp + "' não encontrado!" + CRLF
					EndIf

					QRY_SF1->(DbSkip())
				EndDo

				//Caso tenha algum log de erro, mostra ao usuário com todos os docs listados
				If ! Empty(cError)
					Aviso("Atenção", "Houveram os seguintes erros na atualização: " + CRLF + cError, {"Ok"}, 3)

				Else
					MsgInfo("Processo finalizado!", "Atenção")
				EndIf
			EndIf

		Else
			MsgStop("Não há dados para esse fornecedor, nessa data de digitação!", "Atenção")
		EndIf

		QRY_SF1->(DbCloseArea())

	Else
		MsgStop("Fornecedor não encontrado!", "Atenção")
	EndIf

Return
