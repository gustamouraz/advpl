#INCLUDE 'TOTVS.CH'
#INCLUDE 'TOPCONN.CH'

/*/{Protheus.doc} PROCDOCE
Job - Executa a chamada do processamento dos Documentos de Entrada
@type user function
@author Pedro Lindenberg
@since 13/03/2024
@version version
/*/
User Function PROCDOCE()
 
	Local cQry             := ""
	Local cAlias           := 'TRB1' + GetNextAlias()
	Local aAreas           := {}
	Local lRetD            := .F.
	Local lRpc             := .F.
	Local lIsAut           := .T.
	Local cFuncKey         := "U_PROCDOCE"
	Local cFilBkp
	Private oQuery
	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .T.

	If !(Type("oMainWnd")=="O")
		lRpc := RpcSetEnv('01','010102',,,,GetEnvServer(),)
	EndIf

	aAreas := {DT6->(GetArea()),ZA1->(GetArea()),GetArea()}
	cFilBkp := cFilAnt
	IF !LockReg(cFuncKey)
		RETURN .T.
	ENDIF

	cQry += "SELECT ZA1.R_E_C_N_O_ AS Rec" + CRLF
	cQry += "FROM "+ RetSqlName("ZA1") +" ZA1 " + CRLF
	cQry += "WHERE ZA1.D_E_L_E_T_ = ' ' " + CRLF
	cQry += "AND ZA1.ZA1_CANCEL = 'N' " + CRLF
	cQry += "AND (ZA1.ZA1_STATUS = ' ' OR ZA1.ZA1_STATUS = 'I')" + CRLF
	oQuery := FWPreparedStatement():New(cQry)
	MPSysOpenQuery(oQuery:getFixQuery(), cAlias)

	(cAlias)->(DbGoTop())

	While !(cAlias)->(EOF())

		ZA1->(DbGoTo((cAlias)->Rec))

		DBSELECTAREA("DT6")
		DT6->(DbSetOrder(1))
		If DT6->(DbSeek(ZA1->ZA1_FILIAL+ZA1->ZA1_FILDOC+ZA1->ZA1_CTEDOC+ZA1->ZA1_CTESER))

			IF EMPTY(ZA1->ZA1_CTECHV) .AND. !EMPTY(DT6->DT6_CHVCTE)
				If RecLock('ZA1',.F.)
					ZA1->ZA1_CTECHV := DT6->DT6_CHVCTE
					ZA1->(MsUnlock())
				EndIf
			ENDIF

			lIsAut := fCteAut(Dt6->DT6_FILIAL,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)

			if lIsAut

				cFilAnt := DT6->DT6_FILDOC
				lRetD := U_MAS43P01(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,DT6->DT6_CHVCTE)

				if lRetD
					IF ZA1->ZA1_STATUS == ' '
						If RecLock("ZA1",.F.)
							ZA1->ZA1_STATUS := 'S'
							ZA1->(MsUnlock())
						EndIf
					ELSE
						If RecLock("ZA1",.F.)
							ZA1->ZA1_STATUS := 'R'
							ZA1->(MsUnlock())
						EndIf
					ENDIF
				else
					If RecLock("ZA1",.F.)
						ZA1->ZA1_STATUS := 'E'
						ZA1->(MsUnlock())
					EndIf
				endif

			endif

		EndIf

		(cAlias)->(DbSkip())
	EndDo

	(cAlias)->(dbCloseArea())
	cFilAnt := cFilBkp
	UnLockReg(cFuncKey)

	AEval(aAreas,{|x,y| RestArea(x) })

	If lRpc
		RpcClearEnv()
	Endif

Return

/*/{Protheus.doc} nomeStaticFunction
    Funcao para validar se o CTE está autorizado
    @type  Static Function
    @author Pedro Lindenberg
    @since 13/03/2024
    @version version
/*/
Static Function fCteAut(cFil,cFildoc,cDoc,cSerie)
	Local aAreas   := {DT6->(GetArea()),GetArea()}
	Local lIsAut := .T.

	DBSELECTAREA("DT6")
	DT6->(DbSetOrder(1))
	If DT6->(DbSeek(cFil+cFildoc+cDoc+cSerie))

		IF DT6->DT6_IDRCTE == ' '
			lIsAut := .F.
		ELSEIF DT6->DT6_PROCTE == ' '
			lIsAut := .F.
		ELSEIF DT6->DT6_CHVCTE == ' '
			lIsAut := .F.
		ELSEIF DT6->DT6_SITCTE != '2'
			lIsAut := .F.
		ELSEIF DT6->DT6_RETCTE == ' '
			lIsAut := .F.
		ENDIF

	EndIf

	AEval(aAreas,{|x,y| RestArea(x) })

Return lIsAut

//-------------------------------------------------------------------
/*/{Protheus.doc} LockReg
Bloquear Registro
@author  Thiago.Zoppi
@Since   "08/03/2023"
/*/
//-------------------------------------------------------------------
Static Function LockReg(cChave)
	Local lOk  := .T.
	Local nTry := 0

	While !LockByName(cChave,.F.,.F.)
		nTry++
		If nTry >  4
			lOk := .F.
			Exit
		EndIf
		Sleep(500)
	End
Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} UnLock
DesBloquear Registro
@author  Thiago.Zoppi
@Since   "08/03/2023"
/*/
//-------------------------------------------------------------------
Static Function UnLockReg(cChave)
	UnLockByName(cChave,.F.,.F.)
Return Nil
