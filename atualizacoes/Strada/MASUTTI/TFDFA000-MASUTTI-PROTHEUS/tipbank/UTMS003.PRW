//----------------------------------------------------------
/*/{Protheus.doc} UTMS003 
Função UTMS003 
@description Rotina conferencia processmaento do contrato carreteiro x para Tip Bank
@author Leandro Rodrigues
@return nulo
@owner Masutti
@version Protheus 12 ou superior.
@build 1.0
@country Brasil
@language Portugues - Br
@since 26/10/2016 - Data de Revisão.

@param nulo

@sample 
@obs Rotina conferencia processmaento do contrato carreteiro x para Tip Bank
	
@project TIP BANK
@history 26/10/2016, Adequação DOC , Adequação Doc Fontes. 
@table  DTQ - Viagem
@see Importante: Esse Fonte deve ser compilado juntamente com os fontes UTMS001/UTMS002/TMA144MNU

/*/
//----------------------------------------------------------

User Function UTMS003

Local lRet := .F.
Local aVisErr := {}
Private lVgeExpr := .F.
Private lPreview := .F.


Pergunte("TMA250",.F.)

Processa({|lEnd| lRet := TMSA250Prc("DTQ", 3, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, .F., , aVisErr,,,,,lVgeExpr, lPreview)},"Contrato de Carreteiro", "Gerando os Contratos de Carreteiros ...",.F.)


Return
