#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'RestFul.ch'
#INCLUDE "FWMVCDEF.CH"

User Function M261API()

Return

/*/{Protheus.doc} M261API
@description WebService Rest para gerar Transferência de Estoque entre Locais/Armazéns via ExecAuto MATA261.
Sempre grava o log de integração nas tabelas custom ZPJ (cabeçalho) e ZPK (itens) - tanto em caso de sucesso
quanto de falha (validação de campos/itens ou erro do ExecAuto) - seguindo o mesmo padrão de campos usado em
TI/Rotinas/IMPTAPI.prw, com ZPJ_ALIAS/ZPK_ALIAS fixos em "SD3". Em falha, ZPK_OBS recebe a mensagem de erro
(de validação ou do ExecAuto) no lugar da observação original do item.
@author Johnny Santos
@since 04/08/2025
@type class

Deve ser aplicado no Serviço REST
Modelo de Requisição

{	"cabecalho": {
		"filial":            "0101",
		"documento":         "ORIGEM-000123",
		"usuario":           "johnny.santos",
		"dataTransferencia": "20260804"
	},
	"itens": [
		{	"produtoOrigem":    "000001",
			"armazemOrigem":    "01",
			"enderecoOrigem":   "",
			"produtoDestino":   "000001",
			"armazemDestino":   "02",
			"enderecoDestino":  "",
			"quantidade":       10,
			"loteOrigem":       "",
			"loteDestino":      "",
			"subLote":          "",
			"dataValidade":     "",
			"potencia":         "",
			"quantidade2UM":    "",
			"numeroSerie":      "",
			"itemGrade":        "",
			"observacao":       "Transferência gerada via API"
		}
	]
}

OBSERVAÇÃO
- "documento" é obrigatório: identifica o registro no sistema de origem (gravado em ZPJ_DOC/ZPK_DOC).
  Se já existir um registro em ZPJ com o mesmo ZPJ_FILIAL+ZPJ_ALIAS('SD3')+ZPJ_DOC e ZPJ_STATUS='3'
  (importado com sucesso), a requisição é rejeitada (evita processar a mesma origem duas vezes).
- "usuario" é obrigatório: gravado em ZPJ_SOLICI (solicitante da transferência).
- O documento SD3 (D3_DOC) é sempre gerado automaticamente (GetSxENum) - não é informado na requisição,
  apenas devolvido na resposta em "documentoSD3". É gravado também em ZPJ_SERIE/ZPK_SERIE, para rastreio.
- Campos opcionais do item (subLote, dataValidade, potencia, quantidade2UM, itemGrade) podem vir
  vazios/ausentes; nesse caso assumem o valor padrão do dicionário de dados (CriaVar).
- O array de itens enviado ao ExecAuto MATA261 possui exatamente 23 campos, conforme o layout retornado
  pela própria mensagem de ajuda "AJUDA:OCORRENCIA" deste ambiente (não inclui código de safra).
- "produtoOrigem"/"produtoDestino" precisam existir cadastrados na SB1 da filial informada.

URL da requisição
http://<host>:<porta>/rest/MT261API
/*/
WSRESTFUL MT261API DESCRIPTION "Serviço REST - Transferência de Estoque (ExecAuto MATA261)"
	WSDATA RECEIVE As String //Json recebido no corpo da requisição
	WSMETHOD POST DESCRIPTION "Gera Transferência de Estoque via MATA261" WSSYNTAX "/MT261API || /MT261API/{}"
END WSRESTFUL

WSMETHOD POST WSRECEIVE RECEIVE WSSERVICE MT261API

	Local cJson      	:= Self:GetContent() // Pega a string do JSON
	Local oParseJson 	:= JsonObject():New()
	Local oJsonRet   	:= JsonObject():New()
	Local cError     	:= ""
	Local oError     	:= ErrorBlock({|e| cError := e:Description + e:ErrorStack, Break(e)})
	Local lRpc       	:= .F.

	Local cFilBkp    	:= ""
	Local dDtBkp     	:= StoD("")
	Local cFil    	:= ""
	Local cDocumento 	:= ""
	Local cDocOrigem	:= ""
	Local cUsuario   	:= ""
	Local cAliasChk  	:= ""
	Local dDtTransf  	:= StoD("")

	Local aAutoItens 	:= {}
	Local aLogAuto   	:= {}
	Local aItemErro  	:= {}
	Local oItemJson  	:= Nil
	Local cProdOri   	:= ""
	Local cDesOri    	:= ""
	Local cUmOri     	:= ""
	Local cProdDes   	:= ""
	Local cDesDes    	:= ""
	Local cUmDes     	:= ""
	Local dDtValid   	:= StoD("")
	Local lItemOk    	:= .T.
	Local cZpkCod    	:= ""
	Local cZpkLocal  	:= ""
	Local nZpkQuant  	:= 0
	Local nX         	:= 0
	Local nY         	:= 0
	Local lRet       	:= .T.

	Private lMsHelpAuto    := .T.
	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T. // Mantém o log do ExecAuto em memória (GetAutoGRLog), sem gravar em arquivo/tela

	BEGIN SEQUENCE

		If Select("SX2") == 0
			RpcClearEnv()
			RPCSetType(3)	//NAO CONSOME LICENCA DE USO
			If ( !RpcSetEnv("01", "010101") )
				cError := "Falha ao abrir o ambiente RPC"
				Break
			EndIf
			lRpc := .T.
		EndIf

		oParseJson:FromJson(cJson)

		If !oParseJson:hasProperty("cabecalho") .or. !oParseJson:hasProperty("itens")
			cError := "JSON inválido: as propriedades 'cabecalho' e 'itens' são obrigatórias"
			Break
		EndIf

		cFil       := oParseJson["cabecalho"]["filial"]
		cDocOrigem := oParseJson["cabecalho"]["documento"]
		cUsuario   := oParseJson["cabecalho"]["usuario"]

		If Empty(cFil)
			cError := "Campo 'cabecalho.filial' é obrigatório"
			Break
		EndIf

		If Empty(cDocOrigem)
			cError := "Campo 'cabecalho.documento' é obrigatório"
			Break
		EndIf

		If Empty(cUsuario)
			cError := "Campo 'cabecalho.usuario' é obrigatório"
			Break
		EndIf

		If Empty(oParseJson["cabecalho"]["dataTransferencia"])
			cError := "Campo 'cabecalho.dataTransferencia' é obrigatório (formato AAAAMMDD)"
			Break
		EndIf
		dDtTransf := StoD(oParseJson["cabecalho"]["dataTransferencia"])

		If Len(oParseJson["itens"]) == 0
			cError := "Campo 'itens' é obrigatório e deve conter ao menos 1 item"
			Break
		EndIf

		cAliasChk := GetNextAlias()
		BeginSQL Alias cAliasChk
			SELECT ZPJ.ZPJ_DOC
			FROM %Table:ZPJ% ZPJ
			WHERE ZPJ.ZPJ_FILIAL = %Exp:cFil%
			  AND ZPJ.ZPJ_ALIAS  = 'SD3'
			  AND ZPJ.ZPJ_DOC    = %Exp:cDocOrigem%
			  AND ZPJ.ZPJ_STATUS = '3'
			  AND ZPJ.%NotDel%
		EndSQL
		If !(cAliasChk)->(Eof())
			cError := "Documento de origem '" + cDocOrigem + "' já foi importado com sucesso anteriormente (ZPJ_ALIAS=SD3, ZPJ_STATUS=3)"
			(cAliasChk)->(DbCloseArea())
			Break
		EndIf
		(cAliasChk)->(DbCloseArea())

		cFilBkp := cFilAnt
		dDtBkp  := dDataBase

		If AllTrim(cFil) <> AllTrim(cFilAnt)
			cFilAnt := cFil
			OpenSM0(cEmpAnt + cFilAnt)
		EndIf
		dDataBase := dDtTransf

		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))

		cDocumento := GetSxENum("SD3", "D3_DOC", 1) // D3_DOC sempre autogerado, não vem na requisição

		aAdd(aAutoItens, { cDocumento, dDtTransf }) // Cabeçalho: [1] Documento [2] Data de Emissão

		For nX := 1 to Len(oParseJson["itens"])

			oItemJson := oParseJson["itens"][nX]
			lItemOk   := .T.

			If Empty(oItemJson["produtoOrigem"])
				lItemOk := .F.
			ElseIf Empty(oItemJson["armazemOrigem"])
				lItemOk := .F.
			ElseIf Empty(oItemJson["produtoDestino"])
				lItemOk := .F.
			ElseIf Empty(oItemJson["armazemDestino"])
				lItemOk := .F.
			ElseIf ValType(oItemJson["quantidade"]) <> "N"
				lItemOk := .F.
			ElseIf oItemJson["quantidade"] <= 0
				lItemOk := .F.
			EndIf

			If !lItemOk
				aAdd(aItemErro, "Item " + cValToChar(nX) + ": campos obrigatórios ausentes (produtoOrigem, armazemOrigem, produtoDestino, armazemDestino, quantidade > 0)")
				Loop
			EndIf

			If !SB1->(DbSeek(xFilial("SB1") + PadR(AllTrim(oItemJson["produtoOrigem"]), TamSx3("B1_COD")[1])))
				aAdd(aItemErro, "Item " + cValToChar(nX) + ": produtoOrigem '" + AllTrim(oItemJson["produtoOrigem"]) + "' não encontrado na SB1")
				Loop
			EndIf
			cProdOri := SB1->B1_COD
			cDesOri  := SB1->B1_DESC
			cUmOri   := SB1->B1_UM

			If !SB1->(DbSeek(xFilial("SB1") + PadR(AllTrim(oItemJson["produtoDestino"]), TamSx3("B1_COD")[1])))
				aAdd(aItemErro, "Item " + cValToChar(nX) + ": produtoDestino '" + AllTrim(oItemJson["produtoDestino"]) + "' não encontrado na SB1")
				Loop
			EndIf
			cProdDes := SB1->B1_COD
			cDesDes  := SB1->B1_DESC
			cUmDes   := SB1->B1_UM

			If Empty(oItemJson["dataValidade"])
				dDtValid := CriaVar("D3_DTVALID")
			Else
				dDtValid := StoD(oItemJson["dataValidade"])
			EndIf

			aAdd(aAutoItens, {	cProdOri											,; // 01 - Produto origem
								cDesOri												,; // 02 - Descrição
								cUmOri												,; // 03 - Unidade de medida
								AllTrim(oItemJson["armazemOrigem"])				,; // 04 - Armazém origem
								IIf(Empty(oItemJson["enderecoOrigem"]), CriaVar("D3_LOCALIZ"), oItemJson["enderecoOrigem"])	,; // 05 - Endereço origem
								cProdDes											,; // 06 - Produto destino
								cDesDes												,; // 07 - Descrição
								cUmDes												,; // 08 - Unidade de medida
								AllTrim(oItemJson["armazemDestino"])				,; // 09 - Armazém destino
								IIf(Empty(oItemJson["enderecoDestino"]), CriaVar("D3_LOCALIZ"), oItemJson["enderecoDestino"])	,; // 10 - Endereço destino
								IIf(Empty(oItemJson["numeroSerie"]), CriaVar("D3_NUMSERI"), oItemJson["numeroSerie"])			,; // 11 - Número de série
								IIf(Empty(oItemJson["loteOrigem"]), CriaVar("D3_LOTECTL"), oItemJson["loteOrigem"])			,; // 12 - Lote origem
								IIf(Empty(oItemJson["subLote"]), CriaVar("D3_NUMLOTE"), oItemJson["subLote"])					,; // 13 - Sub lote
								dDtValid											,; // 14 - Data de validade origem
								IIf(Empty(oItemJson["potencia"]), CriaVar("D3_POTENCI"), oItemJson["potencia"])				,; // 15 - Potência
								oItemJson["quantidade"]							,; // 16 - Quantidade
								IIf(Empty(oItemJson["quantidade2UM"]), CriaVar("D3_QTSEGUM"), oItemJson["quantidade2UM"])		,; // 17 - Quantidade na 2ª UM
								CriaVar("D3_ESTORNO")								,; // 18 - Estorno
								CriaVar("D3_NUMSEQ")								,; // 19 - Número sequência
								IIf(Empty(oItemJson["loteDestino"]), CriaVar("D3_LOTECTL"), oItemJson["loteDestino"])			,; // 20 - Lote destino
								dDtValid											,; // 21 - Data de validade destino
								IIf(Empty(oItemJson["itemGrade"]), CriaVar("D3_ITEMGRD"), oItemJson["itemGrade"])				,; // 22 - Item da grade
								IIf(Empty(oItemJson["observacao"]), "Transferência gerada via MT261API", oItemJson["observacao"])	})  // 23 - Observação

		Next nX

		If Len(aItemErro) > 0
			cError := ""
			For nY := 1 to Len(aItemErro)
				cError += aItemErro[nY] + CRLF
			Next nY
			lRet := .F. // não chama o ExecAuto, mas ainda grava o log (ZPJ/ZPK) mais abaixo com esse erro de validação
		ElseIf Len(aAutoItens) <= 1 // só o cabeçalho, nenhum item válido
			cError := "Nenhum item válido para gerar a transferência"
			lRet := .F. // idem: sem ExecAuto, mas com log
		Else

			Begin Transaction

				lMsHelpAuto := .T.
				lMsErroAuto := .F.

				MsExecAuto({|x, y| Mata261(x, y)}, aAutoItens, 3)

				If lMsErroAuto
					aLogAuto := GetAutoGRLog()
					cError := ""
					For nY := 1 to Len(aLogAuto)
						cError += aLogAuto[nY] + CRLF
					Next nY
					If Empty(cError)
						cError := "O ExecAuto da MATA261 reportou erro, porém sem detalhamento retornado pelo GetAutoGRLog(). Verifique o console do AppServer."
					EndIf
					DisarmTransaction()
					lRet := .F.
				EndIf

			End Transaction

		EndIf

		// Log de integração (ZPJ cabeçalho / ZPK itens), mesmo padrão de campos do IMPTAPI.prw.
		// Sempre grava - sucesso ou falha do ExecAuto acima - por isso fica em transação própria,
		// separada da transação da MATA261 (senão um DisarmTransaction() no ExecAuto apagaria o log também).
		// ZPJ_STATUS: 1=Pendente(falhou) 2=Processando 3=Importado(sucesso) 4=Cancelado
		Begin Transaction

			DbSelectArea("ZPJ")
			If ZPJ->(RecLock("ZPJ", .T.))
				ZPJ->ZPJ_ALIAS  := "SD3"
				ZPJ->ZPJ_FILIAL := cFil
				ZPJ->ZPJ_DOC    := cDocOrigem   // documento/referência do sistema de origem
				ZPJ->ZPJ_SERIE  := IIf(lRet, cDocumento, "")   // documento SD3 gerado, só quando importado com sucesso
				ZPJ->ZPJ_EMISSA := dDtTransf
				ZPJ->ZPJ_SOLICI := cUsuario
				ZPJ->ZPJ_STATUS := IIf(lRet, "3", "1")
				ZPJ->(MsUnlock())
			Else
				DisarmTransaction()
				ConOut("MT261API: falha ao gravar log de integração ZPJ - documento=" + cDocOrigem)
			EndIf

			For nX := 1 to Len(oParseJson["itens"])
				oItemJson := oParseJson["itens"][nX]

				// Campos podem estar ausentes/inválidos justamente quando a falha é de validação -
				// nunca usar o valor cru sem checar o tipo, para não travar a gravação do próprio log.
				If ValType(oItemJson["produtoOrigem"]) == "C"
					cZpkCod := PadR(AllTrim(oItemJson["produtoOrigem"]), TamSx3("ZPK_COD")[1])
				Else
					cZpkCod := ""
				EndIf

				If ValType(oItemJson["armazemDestino"]) == "C"
					cZpkLocal := AllTrim(oItemJson["armazemDestino"])
				Else
					cZpkLocal := ""
				EndIf

				If ValType(oItemJson["quantidade"]) == "N"
					nZpkQuant := oItemJson["quantidade"]
				Else
					nZpkQuant := 0
				EndIf

				DbSelectArea("ZPK")
				If ZPK->(RecLock("ZPK", .T.))
					ZPK->ZPK_ALIAS  := "SD3"
					ZPK->ZPK_FILIAL := cFil
					ZPK->ZPK_DOC    := cDocOrigem
					ZPK->ZPK_SERIE  := IIf(lRet, cDocumento, "")
					ZPK->ZPK_ITEM   := StrZero(nX, 4)
					ZPK->ZPK_COD    := cZpkCod
					ZPK->ZPK_LOCAL  := cZpkLocal
					ZPK->ZPK_QUANT  := nZpkQuant
					If lRet
						ZPK->ZPK_OBS := IIf(Empty(oItemJson["observacao"]), "", oItemJson["observacao"])
					Else
						ZPK->ZPK_OBS := cError // erro do ExecAuto ou da validação, em caso de falha
					EndIf
					ZPK->(MsUnlock())
				Else
					DisarmTransaction()
					ConOut("MT261API: falha ao gravar log de integração ZPK item " + cValToChar(nX) + " - documento=" + cDocOrigem)
					Exit
				EndIf
			Next nX

		End Transaction

	END SEQUENCE

	ErrorBlock(oError)

	If !Empty(cFilBkp)
		cFilAnt   := cFilBkp
		dDataBase := dDtBkp
		OpenSM0(cEmpAnt + cFilAnt)
	EndIf

	If Empty(cError) .and. lRet
		oJsonRet["sucesso"]      := .T.
		oJsonRet["documentoSD3"] := cDocumento
		oJsonRet["mensagem"]     := "Transferência gerada com sucesso"
		Self:SetStatus(200)
	Else
		oJsonRet["sucesso"]  := .F.
		oJsonRet["mensagem"] := EncodeUTF8(AllTrim(cError))
		Self:SetStatus(400)
	EndIf

	Self:SetResponse(oJsonRet:toJson())

	FreeObj(oParseJson)
	FreeObj(oJsonRet)

	If lRpc
		RpcClearEnv()
	EndIf

Return
