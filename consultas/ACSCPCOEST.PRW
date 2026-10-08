#Include "Protheus.ch"
#Include "Totvs.ch"

/*
@Autor:     André Claro / andre.claro@acclaro.com.br / 35 998775495
@Data:      28/09/2026
@Descrição: Reprocessamento das SCs com pendencia de estorno para ser gerado. 
            Irá considerar o mês corrente e o anterior.
*/

User Function ACSCPCOEST()

Local _cQuery := ""
Local _cAlias := GetNextAlias()
Local _dDataIni := FirstDate(FirstDate(date())-1)
Local _dDataFim := Date()
Local _aFiliais := {}
Local _nX := 0 


Local lRPC := .F.
If Select("SX2") == 0
    RpcClearEnv()
    RPCSetType(3)
    If(!RpcSetEnv("01", "010101", "", "", "COM",,{"SC1","AKD"}))
        Return(Nil)
    EndIf
    lRPC := .T.
EndIf


_cQuery := " SELECT	DISTINCT SC1.C1_FILIAL, SC1.C1_NUM, SC1.C1_EMISSAO " + CRLF
_cQuery += " FROM		AKD010 AKD WITH(NOLOCK) INNER JOIN SC7010 SC7 WITH(NOLOCK) ON " + CRLF
_cQuery += " 			SC7.C7_FILIAL = AKD.AKD_FILIAL " + CRLF
_cQuery += " 		AND 'SC7'+SC7.C7_FILIAL + SC7.C7_NUM + SC7.C7_ITEM = AKD.AKD_CHAVE " + CRLF
_cQuery += " 		AND SC7.D_E_L_E_T_ = '' " + CRLF
_cQuery += " 		AND SC7.C7_NUMSC <> '' " + CRLF
_cQuery += " 			INNER JOIN SC1010 SC1 WITH(NOLOCK) ON " + CRLF
_cQuery += " 			SC1.C1_FILIAL = SC7.C7_FILIAL " + CRLF
_cQuery += " 		AND SC1.C1_NUM = SC7.C7_NUMSC " + CRLF
_cQuery += " 		AND SC1.C1_ITEM = SC7.C7_ITEMSC " + CRLF
_cQuery += " 		AND SC1.D_E_L_E_T_ = '' " + CRLF
_cQuery += " 			LEFT OUTER JOIN AKD010 AKD51 WITH(NOLOCK) ON " + CRLF
_cQuery += " 			AKD51.AKD_FILIAL = AKD.AKD_FILIAL " + CRLF
_cQuery += " 		AND AKD51.AKD_CHAVE = 'SC1'+ SC7.C7_FILIAL + SC7.C7_NUMSC + SC7.C7_ITEMSC " + CRLF
_cQuery += " 		AND AKD51.D_E_L_E_T_ = '' " + CRLF
_cQuery += " 		AND AKD51.AKD_PROCES = '900051' " + CRLF
_cQuery += " WHERE		AKD.D_E_L_E_T_ = '' " + CRLF
_cQuery += " 		AND SC7.C7_EMISSAO BETWEEN '"+DToS(_dDataIni)+"' AND '"+DtoS(_dDataFim)+"' " + CRLF
_cQuery += " 		AND AKD.AKD_STATUS = '1' " + CRLF
_cQuery += " 		AND AKD.AKD_PROCES = '900052' " + CRLF
_cQuery += " 		AND AKD.AKD_SEQ = '02' " + CRLF
_cQuery += " 		AND AKD51.AKD_FILIAL IS NULL " + CRLF
_cQuery += " ORDER BY SC1.C1_FILIAL, SC1.C1_NUM " + CRLF

MpSysOpenQuery(_cQuery, _cAlias)

While (_cAlias)->(!eof())
    If aScan(_aFiliais, (_cAlias)->C1_FILIAL ) == 0 
        aAdd(_aFiliais, (_cAlias)->C1_FILIAL )
    EndIf
(_cAlias)->(DbSkip())
EndDo

For _nX := 1 to Len(_aFiliais)
    (_cAlias)->(DbGoTop())
    cFilAnt := _aFiliais[_nX]
    OpenSM0( cEmpAnt + cFilAnt )
    While (_cAlias)->(!Eof())
        If (_cAlias)->C1_FILIAL == cFilAnt
            U_ACVLDPCO(cFilAnt, (_cAlias)->C1_NUM, 1 , .T. )//Chamada da integração do PCO pelas SCs (Exclusão)
            U_ACVLDPCO(cFilAnt, (_cAlias)->C1_NUM, 1 , .F. )//Chamada da integração do PCO pelas SCs (Inclusão)
        EndIf
    (_cAlias)->(DbSkip())
    EndDo
Next _nX

Return 




//Rotina que permite rodar no Schedule sem preparar ambiente
Static Function Scheddef()
	
	Local aOrd   := {}
	Local aParam := { "P",;              // Tipo R para relatorio P para processo   
				      "PARAMDEF",;       // Pergunte do relatorio, caso nao use passar ParamDef            
				      "",;               // Alias            
				      aOrd,;             // Array de ordens   
				      ""}                // Titulo
				          
Return aParam
