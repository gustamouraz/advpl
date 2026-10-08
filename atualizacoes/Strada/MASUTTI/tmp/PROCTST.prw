#INCLUDE 'TOTVS.CH'
#INCLUDE 'TOPCONN.CH'

/*/{Protheus.doc} nomeFunction
(long_description)
@type user function
@author user
@since 13/03/2024
@version version
/*/
User Function PROCTST()

    RpcSetEnv('01','010102')

    // Local lRet := .F.
    // Local cFilDoc  := '020101'
	// Local cDocto   := '001499   '
	// Local cSerie   := '5  '
	// Local aAreas   := {DTC->(GetArea()),ZA1->(GetArea()),GetArea()}
	// // Local lIsFil   := fVldFil()

    // if ExistBlock('TM200DT6')
    //     ExecBlock('TM200DT6')
    // endif

    u_PROCDOCE()

    RpcClearEnv()

Return niL
