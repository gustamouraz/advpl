#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} User Function MT103EXC
    Ponto de entrada para validação da exclusão do documento de entrada.
    @type  Function
    @author Willian Kaneta
    @since 14/05/2020
    @version 1.0
    @return lRet - .T. Para excluir o documento; .F. Para não excluir o documento;
    @example
    (examples)
    @see (links_or_references)
/*/
User Function MT103EXC()
	Local lRet      := .T.
	Local _aAreaSF1 := SF1->(GetArea())
	Local _aAreaSE2 := SE2->(GetArea())
	Local _aAreaZMV := ZMV->(GetArea())
	Local cAliasZA1 := "TMP"+GetNextAlias()
	Local cQry := ""
	Local _aArea    := GetArea()
	Local cPrefix   := &(SuperGetMV("MV_2DUPREF"))
	Local aArray    := {}

	Private lMsErroAuto := .F.

	oLog             := MASXLOG():New()
	cIdtoken         := oLog:idtoken //110110

	cPrefix += Space(Len(SE2->E2_PREFIXO) - Len(cPrefix))
	cPrefix := SUBSTR(cPrefix,1,TamSX3("E2_PREFIXO")[1])


	If !Empty(SF1->F1_XDTCLAS) .AND. (dDataBase < SF1->F1_XDTCLAS)
		MsgAlert("Nao é permitido estornar o documento com data menor que " + DtoC(SF1->F1_XDTCLAS),"MT103EXC")
		lRet := .F.
	EndIf

	If FieldPos("E2_XPREAGE") > 0
		If SE2->E2_XPREAGE == 'S'
			MsgAlert("Nao é permitido estornar o documento com pagamento pré-agendado!" + CRLF + ;
				"Em caso de dúvidas entrar em contato com a Célula de Contas a Pagar CSC.","MT103EXC")
			lRet := .F.
		EndIf
	EndIf



	If lRet .AND. Alltrim(SF1->F1_ESPECIE) $ "FTF;ND"
		DbSelectArea("SE2")
		SE2->(DbSetOrder(6))
		//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		If  SE2->(MsSeek(xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+cPrefix+SF1->F1_DOC))
			While SE2->(!EOF()) .AND. SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM == xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+cPrefix+SF1->F1_DOC
				If Alltrim(SE2->E2_TIPO) $ "FTF;ND"
					aArray := { {"E2_PREFIXO" ,SE2->E2_PREFIXO , NIL },;
						{"E2_NUM"     ,SE2->E2_NUM     , NIL },;
						{"E2_FILIAL"  ,SE2->E2_FILIAL  , NIL },;
						{"E2_FORNECE" ,SE2->E2_FORNECE , NIL },;
						{"E2_LOJA"    ,SE2->E2_LOJA    , NIL },;
						{"E2_PARCELA" ,SE2->E2_PARCELA , NIL },;
						{"E2_TIPO"    ,SE2->E2_TIPO    , NIL }}

					MsExecAuto( { |x,y,z| FINA050(x,y,z)},aArray,, 5) //5 - Exclusão
					If lMsErroAuto
						lRet := .F.
						MostraErro()
					Else
						MsgInfo("Realizado a exclusão do Título com sucesso!")
					Endif
				Else
					lRet := .F.
					MsgAlert("Titulo(s) não excluído(s). Não será possível excluir o documento de entrada.","Atenção")
				EndIf
				SE2->(DbSkip())
			EndDo
		EndIf
	EndIf

	IF lRet .AND. Alltrim(SF1->F1_ESPECIE) == 'CTE'

		cQry += "SELECT ZA1_FILDOC "+CRLF
		cQry += "FROM ZA1010 ZA1 "+CRLF
		cQry += "WHERE ZA1_FILDCE = ? AND "+CRLF
		cQry += "ZA1_DOCENT = ? AND "+CRLF
		cQry += "ZA1_SERENT = ? AND "+CRLF
		cQry += "ZA1.D_E_L_E_T_ = ' ' "+CRLF
		oQuery := FWPreparedStatement():New(cQry)
		oQuery:setParams({xFilial("SF1"),SF1->F1_DOC,SF1->F1_SERIE})
		MPSysOpenQuery(oQuery:getFixQuery(), cAliasZA1)

		IF !(cAliasZA1)->(Eof())

			oLog:GRAVALOG("I001",cIdtoken, "Doc. de Entrada excluido com sucesso." ," ","1","CTE",ZA1->ZA1_FILDOC+SF1->F1_DOC+SF1->F1_SERIE)

			DBSELECTAREA('ZMV')
			ZMV->(DBSETORDER(4))
			If Dbseek(xfilial("ZMV")+(cAliasZA1)->ZA1_FILDOC+SF1->F1_DOC+SF1->F1_SERIE)
				RecLock('ZMV',.F.)
				ZMV->ZMV_CHSEE2  := "SF1"
				ZMV->ZMV_SEE2    :=  xFilial("SF1")+SF1->F1_DOC+SF1->F1_SERIE
				ZMV->(MsUnLock())
			ENDIF
		ENDIF

		(cAliasZA1)->(DBCLOSEAREA())

	ENDIF

	RestArea(_aArea)
	RestArea(_aAreaSE2)
	RestArea(_aAreaSF1)
	RestArea(_aAreaZMV)
	
Return lRet
