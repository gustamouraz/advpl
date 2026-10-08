#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TMA144MNU
Pe para inclusao de Menu
@author Leandro Rodrigues
@since 03/04/2020
@version P12
@param nulo
@return nulo
/*/

User Function TMA144MNU() 

Local aTipFrete  :={}

aTipFrete := {	{ "Envio/Re-Envio"      , "U_UTMS002(1)"  ,0 ,3 },; 
            	{ "Consultar Viagem"    , "U_UTMS002(2)"  ,0 ,3 },; 
				{ "Cancela Viagem"      , "U_UTMS002(3)"  ,0 ,4 },;
				{ "Download Contrato"	, "U_UTMS002(4)"  ,0 ,4 },;
				{ "Autoriza Viagem"		, "U_UTMS002(5)"  ,0 ,4 }}
					//{ "Contrato Terceiro"   , "U_UTMS003( )"  ,0 ,3 },; 

Aadd(aRotina,{'Tip Bank',aTipFrete , 0 , 3 ,0 ,NIL})   

//aRotina[7][2][5][2] := "U_TROCAMNU()"

Return

User function TrocaMnu()

Local aVisErr := {}
Local aArea	  := GetArea()

Local lVgeExpr := .F.
Local lPreview := .F.
Local lRet := .T.
Local cTipCTC    	:= Padr( GetMV("MV_TPTCTC"), Len( SE2->E2_TIPO ) ) 

//Public cNatureza := GetMv("MV_NATDEB")

//IIF(IsInCallStack( 'U_TMA144MNU' ) .and. M->E2_TIPO = 'NDF', GetMV("MV_TPTCTC") ,"")

	TMSA144Sub(4,2)

	dbSelectArea("DTW")
	DTW->(dbSetOrder(1))
	DTW->(dbGotop())
	If DTW->(dbSeek(DTQ->DTQ_FILIAL+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
		Pergunte("TMA250",.F.) // SAIU DA LINHA 61 E VEIO PARA FORA DO WHILE - ANDRECCLARO 27/10/2022
		While !DTW->(Eof()) .And. DTW->DTW_VIAGEM=DTQ->DTQ_VIAGEM .AND. DTW->DTW_FILORI=DTQ->DTQ_FILORI

			If DTW_ATIVIDA="049" .AND. DTW_STATUS="2"

			 	If DUP->(DbSeek(xFilial("DUP")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM ))

                	//Posiciono no cadastro do motorista
                	If DA4->(DbSeek(xFilial("DA4")+DUP->DUP_CODMOT))

						If DA4->DA4_XCTTIP!= 0
							If !TemDTY(DTQ->DTQ_VIAGEM)
    							//Pergunte("TMA250",.F.) //// SAIU DA LINHA 61 E FOI PARA A LINHA 49 FORA DO WHILE - ANDRECCLARO 27/10/2022


								MV_PAR01:= DTQ->DTQ_VIAGEM
								MV_PAR02:= DTQ->DTQ_VIAGEM
								//msginfo("TMA144MNU")

    							//Processa({|lEnd| lRet := U_XTMSA250Prc("DTQ", 3, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, .F., , aVisErr,,,,,lVgeExpr, lPreview, cTipCTC)},"Contrato de Carreteiro", "Gerando os Contratos de Carreteiros ...",.F.)
								//Processa({|lEnd| lRet := TMSA250Prc("DTQ", 3, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, .F., , aVisErr,,,,,lVgeExpr, lPreview, cTipCTC)},"Contrato de Carreteiro", "Gerando os Contratos de Carreteiros ...",.F.)						
								//Envia Viagem para a TipBank
								//U_UTMS002(1)
								//Consulta Viagem Tip Bank
								//U_UTMS002(2)
								//Autoriza Viagem Tip Bank
								//U_UTMS002(5)
							EndIf
						
						EndIf
					EndIf		
				EndIf
			EndIf
			DTW->(dbSkip())
		EndDo	
	EndIf
	RestArea(aArea)

Return
/*
Função que verifica se já existe contrato
Se já existir não gera novamente.
*/

Static Function TemDTY(cViagem)
Local lRet :=.F.
Local cQuery :=''
Local cAlias := GetNextAlias()

cQuery := " SELECT ISNULL(COUNT(*),0) AS TOTAL FROM "+ RetSQLName("DTY")
cQuery += " WHERE DTY_FILIAL='"+XFilial("DTY")+"'"
cQuery += " AND DTY_VIAGEM = '" + cViagem + "' "
cQuery += " AND D_E_L_E_T_= ' ' "

If Select(cAlias)>0
	(cAlias)->(dbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),(cAlias),.F.,.F.)

If (cAlias)->(TOTAL)>0
	lRet :=.T.
EndIf

(cAlias)->(dbCloseArea())

return lRet
