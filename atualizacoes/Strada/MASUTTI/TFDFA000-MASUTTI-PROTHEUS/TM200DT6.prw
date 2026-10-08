#INCLUDE 'TOTVS.CH'
#INCLUDE 'TOPCONN.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} TM200DT6
TM200DT6 - Gravação do Documento de Transporte
Este Ponto de Entrada, localizado no TMSA200(Cálculo de Frete), é executado após a gravação do Documento de Transporte (DT6).
@author  Pedro Lindenberg
@Since   "13/03/2024"
/*/
//-------------------------------------------------------------------
User Function TM200DT6()
	Local cFilDoc   := PARAMIXB[1]
	Local cDocto    := PARAMIXB[2]
	Local cSerie    := PARAMIXB[3]
	Local cCodRegra := DTC->DTC_ZNCCOD
	Local aAreas    := {DTC->(GetArea()),ZA1->(GetArea()),ZNC->(GetArea()),GetArea()}
	Local lIsFil    := fVldFil()

	IF lIsFil
		DBSELECTAREA("ZA1")
		ZA1->(DBSETORDER(1))
		IF !ZA1->(DBSEEK(xFilial("DT6")+cFilDoc+cDocto+cSerie))
			ZA1->(RECLOCK("ZA1",.T.))
			ZA1->ZA1_FILIAL := DT6->DT6_FILIAL
			ZA1->ZA1_FILDOC := cFilDoc
			ZA1->ZA1_CTEDOC := cDocto
			ZA1->ZA1_CTESER := cSerie
			ZA1->ZA1_CTECHV := DT6->DT6_CHVCTE
			ZA1->ZA1_CANCEL := 'N'
			ZA1->ZA1_ZNCCOD := cCodRegra
			ZA1->(MSUNLOCK())
		ENDIF

	ENDIF

	AEval(aAreas,{|x,y| RestArea(x) })

Return Nil

/*/{Protheus.doc} fVldFil
    Função responsável por validar se o cliente é Filial
    @type  Static Function
    @author Pedro Lindenberg
    @since 13/03/2024
/*/
Static Function fVldFil()

	Local lIsFil := .T.
	Local cFilAlias := "TRB2" + GetNextAlias() + StrTran(Time(), ":", "")
	Local nContTRB := 0
	Local cQry := ""
	Local cCliCgc := ""
	Private oQuery

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1")+DT6->DT6_CLIDEV+DT6->DT6_LOJDEV))
		cCliCgc := SA1->A1_CGC
	EndIf

	cQry += "SELECT M0_CODIGO, M0_CODFIL FROM SYS_COMPANY SYS" + CRLF
	cQry += "WHERE SYS.D_E_L_E_T_ = ' ' "     + CRLF
	cQry += "AND SYS.M0_CGC = ? " + CRLF
	oQuery := FWPreparedStatement():New(cQry)
	oQuery:setParams({cCliCgc})
	MPSysOpenQuery(oQuery:getFixQuery(), cFilAlias)

	(cFilAlias)->(DBGoTop())
	(cFilAlias)->(DBEval({|| nContTRB++}))
	(cFilAlias)->(DBGoTop())

	IF !(cFilAlias)->(Eof())
		lIsFil := .T.
	ELSE
		lIsFil := .F.
	ENDIF

	(cFilAlias)->(DbCloseArea())

Return lIsFil
