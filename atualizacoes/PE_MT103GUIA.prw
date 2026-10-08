#include 'protheus.ch'

USER FUNCTION MT103GUIA

	Local lRet      := .T.
	Local cAliasTmp := getNextAlias()
	Local cTabela   := paramIXB[1]
	// Local cEspecie  := paramIXB[6]

	If cTabela = 'SF1'

		BeginSql alias cAliasTmp
            SELECT *
              FROM %table:SE2% (nolock)
             WHERE E2_FILIAL  = %xFilial:SE2%
               AND E2_PREFIXO = 'ICM'
               AND E2_NUM     = %exp:SF1->F1_DOC%
               AND E2_TIPO    = 'TX'
               AND E2_ORIGEM  = 'MATA103'
               AND %notdel%
		EndSql

		(cAliasTmp)->(dbGoTop())

		If !(cAliasTmp)->(eof())

			// lRet := .F.

			// If !empty(SF1->F1_CHVNFE)
            //     /*TiLogCarga(cSeveri , cTpDoc                         , cChave         , cDesc                    , cMemo , cVersao , cFilLog        , cNomeAq , nIdRet, cNomePrg   ) */
			// 	u_TiLogCarga('C'     , iIf(cEspecie = 'SPED','1','2') , SF1->F1_CHVNFE , 'Imposto em duplicidade' ,       , '1.0'   , xFilial('SF1') , ''      , 0     , 'MT103GUIA')
			// EndIf
			Msgalert('Imposto em duplicidade, não será possível gerar o arquivo para o documento ' + SF1->F1_DOC + '!', 'MT103GUIA')
		EndIf

		(cAliasTmp)->(dbCloseArea())

	EndIf

return lRet
