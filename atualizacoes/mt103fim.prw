#INCLUDE 'TOPCONN.CH'
#Include 'Protheus.ch'
#include "tbiconn.ch"
//--------------------------------------------------------------
/*/{Protheus.doc} MT103FIM
O ponto de entrada MT103FIM encontra-se no final da fun��o A103NFISCAL. 
Ap�s o destravamento de todas as tabelas envolvidas na grava��o do documento de entrada, 
depois de fechar a opera��o realizada neste, � utilizado para realizar 
alguma opera��o ap�s a grava��o da NFE.

@see 

@author Andr� Claro - 35 99877-5495 andrecclaro@hotmail.com
@since 21/04/2021
/*/
//--------------------------------------------------------------
Static INCLUSAO     := 3
Static CLASSIFIC    := 4
Static EXCLUSAO     := 5

User Function MT103FIM()

	Local _aArea	 	:= GetArea()
	Local _nOpcao	 	:= PARAMIXB[1]   // 3 Op��o Escolhida pelo usuario no aRotina //3-Inclus�o / 4-Classifica��o / 5-Exclus�o
	Local _nConfirma 	:= PARAMIXB[2]   // 1 Se o usuario confirmou a opera��o de grava��o da NFE
	Local cUserName 	:= UsrRetName(RetCodUsr())
	Local cHora := val(SubStr( Time(), 1, 2 ))
	Local cData := Date()
	Local cAlias    := "SF1"
	Local _cChave := SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA
	Local _lGrvSZ1 := SuperGetMv("MV_ZBKPNFE",.F.,.F.) //Executa a grava��o da SZ1?

	Local nPosOper  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_OPER"})
	Local nPosTes   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"})
	Local nPosItem  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEM"})
	Local nC        := 0
	Local lReclock  := .F.

	local lTarget := iif(type('__lTarget') = 'L',__lTarget,.F.) .or. funName() == 'TXMLV2'

	if type('paramIXB') <> 'U'
		if existBlock('TX103FIM')
			u_TX103FIM(paramIXB) /* Tem finalidade de executar as funcionalidades da Target apos as acoes do mata103 - Jan Ravier (15/08/2024) */
		endif
	endif

	//Tratativa para se a hora for 00:00 no server voltar para 23:00 sen�o sempre vai diminuir uma hora do server
	if cHora = 0
		cHora := 23
		cData := cData -1
	else
		cHora :=cHora - 1
	endif

	cHora := PadL(cHora,2,"0") + SubStr(Time(),3,3)

	If (_nOpcao == INCLUSAO .or. _nOpcao == CLASSIFIC) .and. _nConfirma == 1

		//Fun��o respons�vel por atualizar o campo F1_XNATURE com base nas duplicatas.
		U_ACF1NATUR()

		If  _lGrvSZ1
			U_ZLIMPSZ1(_cChave)
		EndIf

		cUserBkp := cUserName

		/* Inicio do bloco para identifica��o do comprador, para utiliza��o em classifica��es via aprova��o de pedido de compra */
		if (fwIsInCallStack('U_TILPCCTE') .or. fwIsInCallStack('U_MT094END')) .and. getMv('TI_GETCOMP',,.T.)
			cUserName := comprador()
		endif
		/* Fim do bloco para identifica��o do comprador, para utiliza��o em classifica��es via aprova��o de pedido de compra */

		If RecLock( "SF1", .F. )
			//Grava a data atual do sistema operacional.
			Replace SF1->F1_XDTCLAS	With cData
			Replace SF1->F1_XHRCLAS	With cHora
			Replace SF1->F1_XUSUCLA With cUserName

            /* INICIO
            @Autor:       Andr� Claro
            @Data:        23/06/2023
            @Descri��o:   Grava��o de campo personalizado com a data de inclus�o da nota fiscal no sistema
            */
			If Empty(SF1->F1_XDATINC)
				SF1->F1_XDATINC := Date()
			EndIf
            /* FINAL */

			SF1->(MsUnLock())

		Endif

		cUserName := cUserBkp

		IF SELECT("ZFM")
			DbSelectArea("ZFM")
			ZFM->(DbSetOrder(1))//ZFM_FILIAL+ZFM_DOC+ZFM_SERIE+ZFM_FORNEC+ZFM_LOJA+ZFM_ITEM

			For nC := 1 To Len(aCols)
				If !Empty(aCols[nC][nPosOper]) .AND. !Empty(aCols[nC][nPosTes])

					lReclock    := ZFM->(DbSeek(_cChave+aCols[nC][nPosItem]))

					RecLock("ZFM", !lReclock)
					ZFM->ZFM_FILIAL := SF1->F1_FILIAL
					ZFM->ZFM_DOC    := SF1->F1_DOC
					ZFM->ZFM_SERIE  := SF1->F1_SERIE
					ZFM->ZFM_FORNEC := SF1->F1_FORNECE
					ZFM->ZFM_LOJA   := SF1->F1_LOJA
					ZFM->ZFM_ITEM   := aCols[nC][nPosItem]
					ZFM->ZFM_TES    := aCols[nC][nPosTes]
					ZFM->ZFM_OPER   := aCols[nC][nPosOper]
					ZFM->(MsUnlock())
				EndIf
			Next nC

			ZFM->(DbCloseArea())
		EndIf
		
		// EST. TRANSITO AUTOMÝTICO
        U_ACESTRAT(SF1->F1_FILIAL , SF1->F1_DOC , SF1->F1_SERIE , SF1->F1_FORNECE , SF1->F1_LOJA)

        // Atualiza os dados da nota fiscal no insumo da OS (STL).
        U_LMATUSTL("NF", SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA)

	EndIf

	//Notificar Time de Patrimonio quando classificado ou estornado NF
	If (_nOpcao == EXCLUSAO .or. _nOpcao == CLASSIFIC) .and. _nConfirma == 1
		U_FNTFCLASS( aCols, aHeader, _nOpcao )
	EndIf

	If _nOpcao == EXCLUSAO .and. _nConfirma == 1
		U_FMKLOGTI("\logs\MATA103\Exclusao",SF1->F1_SERIE+SF1->F1_DOC, "Exclusao realizada pelo usu�rio " + cUserName + " DOC: " + SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA)

		DbSelectArea("ZFM")
		ZFM->(DbSetOrder(1))//ZFM_FILIAL+ZFM_DOC+ZFM_SERIE+ZFM_FORNEC+ZFM_LOJA+ZFM_ITEM

		For nC := 1 To Len(aCols)
			If ZFM->(DbSeek(_cChave+aCols[nC][nPosItem]))
				RecLock("ZFM", .F.)
				ZFM->(DbDelete())
				ZFM->(MsUnlock())
			EndIf
		Next nC

		ZFM->(DbCloseArea())

		if !lTarget /* Sera executada a funionalidade para informar a justificativa de cancelamento, caso nao esteja executando pela solu��o da Target-IT - Jan Ravier (15/08/2024) */
			WHILE !(U_JUSEXC(cAlias))
				MsgInfo("Obrigat�rio informar o motivo da exclus�o","Alerta")
			ENDDO
		endif
	EndIf


	RestArea(_aArea)

Return

/*
@Autor:     Andr� Claro
@Data:      03/05/2021
@Descri��o: Quando da classifica��o da nota fiscal, todo hist�rico existente 
            dessa nota fiscal na SZ1 ser� feita a limpeza!
*/

User Function ZLIMPSZ1(_cChave)
	Local nStatus := 0

	Default _cChave := ""

	If Empty(_cChave)
		Return
	EndIf

	TCLink()

	// Execu��o da limpeza na SZ1
	nStatus := TCSqlExec("DELETE SZ1010 WHERE Z1_FILIAL+Z1_DOC+Z1_SERIE+Z1_FORNECE+Z1_LOJA = '"+_cChave+"' ")

	If (nStatus < 0)
		conout("TCSQLError() " + TCSQLError())
	Endif

	TCUnlink()

Return

/*/{Protheus.doc} comprador
	Funcao que retorna o nome do comprador vinculado aos itens da nota fiscal de entrada.
	Essa funcao � utilizada para atualizar o campo de usu�rio que classificou a nota fiscal,
	caso a nota fiscal tenha sido classificada via aprova��o do pedido de compra.
	@type function
	@version 1.0
	@author Jan Ravier
	@since 1/27/2026
	@return character, Nome do comprador vinculado aos itens da nota fiscal de entrada.
/*/
static function comprador()

	local aArea    := fwGetArea()
	local aAreaSD1 := SD1->(fwGetArea())
	local aAreaSC7 := SC7->(fwGetArea())
	local cRet     := ''

	dbSelectArea('SD1')
	SD1->(dbSetOrder(1)) /* D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM */
	if SD1->(dbSeek(xFilial('SD1') + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))

		while !SD1->(eof()) .and.;
				SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) == xFilial('SD1') + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA .and.;
				empty(cRet)

			if !empty(SD1->D1_PEDIDO) .and. !empty(SD1->D1_ITEMPC)

				dbSelectArea('SC7')
				SC7->(dbSetOrder(1)) /* C7_FILIAL, C7_PEDIDO, C7_ITEMPC */
				if SC7->(dbSeek(xFilial('SC7') + SD1->D1_PEDIDO + SD1->D1_ITEMPC))
					cRet := usrRetName(SC7->C7_USER)
				endif

			endif

			SD1->(dbSkip())

		enddo

	endif

	fwRestArea(aAreaSC7)
	fwRestArea(aAreaSD1)
	fwRestArea(aArea)

return cRet
