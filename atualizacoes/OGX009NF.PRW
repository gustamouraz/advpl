#include "REPORT.CH"
#include "PROTHEUS.CH"    
#include "TOPCONN.CH"    
#Include 'FWMVCDef.ch'


User Function OGX009NF()
    Local aCab   := aClone(PARAMIXB[1])
    Local aItens := aClone(PARAMIXB[2])
    Local aDados := {}
    Local aRet   := {}
    Local cChave 
    Local lChave := .F.
    Local cDoc := SPACE(TamSX3("D1_NFORI")[1])
    Local cSer := SPACE(TamSX3("D1_SERIORI")[1])
    Local cFor := SPACE(TamSX3("D1_FORNECE")[1])
    Local cLj  := SPACE(TamSX3("D1_LOJA")[1])

    If SuperGetMV("MV_ZOGXNF",.F.,.F.) .AND. NJJ->NJJ_TPFORM = "1"  //Se for formulario proprio chama tela para transmissão
    // INVIABILIZADO SUBSTITUIDO POR ALERTA
    //     spednfe()
        MsgAlert("Para romaneios com Form. Próprio = 'Sim' É NECESSÁRIO TRANSMITIR!" + Chr(13) + Chr(10) + " Outras Ações > Sped Nfe","!!! ATENÇÃO !!!")
    EndIf

    // If  ALLTRIM(NJJ->NJJ_CODCTR) $ SUPERGETMV("MV_XCTRREF",.F.,"600652") //Parâmetro substituido por campo NJR_XREFNF
    If  ALLTRIM(NJR->NJR_XREFNF) == "S" 
        cChave := CHVNFE()

        DbSelectArea( 'SF1' )
        SF1->(DbSetOrder(8))
        SF1->(DbGoTop())
        If SF1->(DbSeek(xFilial("SF1") + cChave ))
            cDoc := SF1->F1_DOC
            cSer := SF1->F1_SERIE
            cFor := SF1->F1_FORNECE
            cLj  := SF1->F1_LOJA
            lChave := .T.
        Else
            MsgInfo('Chave Informada no Localizada, verifique em Documento de Entrada', 'Ateno Divergencia na Chave')

        EndIf
        If lChave
            DbSelectArea( 'SD1' )
            SD1->(DbSetOrder(19))
            SD1->(DbGoTop())
            If SD1->(DbSeek(xFilial("SD1")  + cDoc + cSer + cFor + cLj ))
                MsgInfo('Chave Informada j foi Referenciada em Outra nota, Verifique!', 'Ateno Divergencia na Chave')
                lChave := .F.
            EndIf
        EndIf

        If lChave
            aDados := VLDCHV(cChave)
            aadd(aItens[1], {'D1_NFORI',   aDados[1],Nil})
            aadd(aItens[1], {'D1_SERIORI', aDados[2],Nil})
            aadd(aItens[1], {'D1_ITEMORI', aDados[3],Nil})
        Else 
            alert('Existe Uma divergencia na Operaao verifique e Corrija!')
        EndIf
        aRet := {aCab, aItens}
    EndIf
Return aRet

Static Function CHVNFE()                        
    Local oButton1
    Local oGet1
    Local oSay1
    Local cTexto    := SPACE(TamSX3("F1_CHVNFE")[1])
    Static oDlg

        DEFINE MSDIALOG oDlg TITLE "Chave da NF Referenciada" STYLE DS_MODALFRAME FROM 000, 000  TO 150, 400 COLORS 0, 16777215 PIXEL
        oDlg:lEscClose := .F.

            @ 007, 025 SAY oSay1 PROMPT "Informe a Chave da Nota Referenciada" SIZE 145, 009 OF oDlg COLORS 0, 16777215 PIXEL
            @ 025, 009 MSGET oGet1 VAR cTexto SIZE 183, 010 OF oDlg COLORS 0, 16777215 PIXEL
            @ 052, 078 BUTTON oButton1 PROMPT "Salvar" ACTION( oDlg:End()) SIZE 037, 012 OF oDlg PIXEL

        ACTIVATE MSDIALOG oDlg CENTERED

Return cTexto

Static Function VLDCHV(cChave)
    Local aDados := {}
    DEFAULT cMyAlias := GetNextAlias()
    BEGINSQL Alias cMyAlias
    	%noparser%
        SELECT  * FROM SF1010 SF1 WITH(NOLOCK)	
        INNER JOIN SD1010 SD1 WITH(NOLOCK) ON 
    			SF1.F1_DOC 		= SD1.D1_DOC 		AND 
    			SF1.F1_SERIE 	= SD1.D1_SERIE 		AND 
    			SF1.F1_FORNECE 	= SD1.D1_FORNECE 	AND 
    			SF1.F1_LOJA 	= SD1.D1_LOJA 		AND 
    			SF1.F1_FILIAL 	= SD1.D1_FILIAL 	AND 
    			SD1.%NotDel%	
        WHERE 
    		SF1.F1_CHVNFE = %exp:cChave% 			AND 
    		SF1.%NotDel%
    ENDSQL
    (cMyAlias)->(DbGoTop())
    If !(cMyAlias)->(EoF()) 
        aDados :=  {(cMyAlias)->(D1_DOC),(cMyAlias)->(D1_SERIE), (cMyAlias)->(D1_ITEM)}
    EndIf
    (cMyAlias)->(dbCloseArea())


Return aDados
    
    
    