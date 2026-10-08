#Include "Protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"

/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  MT120TEL                                                                                              |
 | Desc:  Ponto de Entrada para adicionar campos no cabeçalho do pedido de compra                               |
 | Link:  http://tdn.totvs.com/display/public/mp/MT120TEL                                                       |
 | Autor: Andriel Matos          												                                |
 | Data:  23/08/2017    Versão:1.0 																				|
 *--------------------------------------------------------------------------------------------------------------*/
 
User Function MT120TEL()
    Local aArea     := GetArea()
    Local oDlg      := PARAMIXB[1]
    Local aPosGet   := PARAMIXB[2]
    Local nOpcx     := PARAMIXB[4]
    Local nRecPC    := PARAMIXB[5]
    Local lEdit     := IIF(nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx ==  9, .T., .F.) //Somente será editável, na Inclusão, Alteração e Cópia
    Local _aEscolh	:=	{"","Sim","Não"} 
    Local oXAnoSaf
    Local oXPedFor
    Local oXRecort 
    
    Public cXPedFor := ""
    Public lXRecort := ""
    Public cFuncao  := FunName()   

    if type('cXAnoSaf') = 'U'
        Public cXAnoSaf := ""
    endif
    	
    AAdd( aTitles, 'Financeiro' )
         
    //Define o conteúdo para os campos
    SC7->(DbGoTo(nRecPc))
    If nOpcx == 3
        cXPedFor := CriaVar("C7_XPEDFOR",.F.)
        if empty(cXAnoSaf)
            cXAnoSaf := CriaVar("C7_XSAFRA",.F.)
        endif
        lXRecort := If(nOpcX<>3,If(SC7->C7_XRECORT=="S","Sim","Não"),"Não")            
    Else
        cXPedFor := SC7->C7_XPEDFOR
        cXAnoSaf := SC7->C7_XSAFRA
        lXRecort := SC7->C7_XRECORT      
    EndIf
     
    //Criando na janela o campo Safra
    @ 064, aPosGet[1,5] -40 SAY Alltrim(RetTitle("C7_XPEDFOR")) OF oDlg PIXEL SIZE 030,6
    @ 062, aPosGet[1,5] -10 MSGET oXPedFor VAR cXPedFor  PICTURE '@R 999999999' SIZE 030, 6 OF oDlg COLORS 0, 16777215  PIXEL 
    oXPedFor:bHelp := {|| ShowHelpCpo( "C7_XPEDFOR", {GetHlpSoluc("C7_XPEDFOR")[1]}, 5  )}
    @ 064, aPosGet[1,6] -25 SAY Alltrim(RetTitle("C7_XSAFRA")) OF oDlg PIXEL SIZE 015, 6
    @ 062, aPosGet[1,6] -4 MSGET oXAnoSaf VAR cXAnoSaf  PICTURE '@R 9999/9999' SIZE 015, 6 OF oDlg COLORS 0, 16777215  PIXEL 
    oXAnoSaf:bHelp := {|| ShowHelpCpo( "C7_XSAFRA", {GetHlpSoluc("C7_XSAFRA")[1]}, 5  )}
    @ 064, aPosGet[1,7] -40 SAY Alltrim(RetTitle("C7_XRECORT")) OF oDlg PIXEL SIZE 30,10
    @ 062, aPosGet[1,7] -10 COMBOBOX oXRecort VAR lXRecort Items _aEscolh When (nOpcX=3 .Or. nOpcX=4) OF oDlg COLORS 0, 16777215  PIXEL SIZE 30,10 
    oXRecort:bHelp := {|| ShowHelpCpo( "C7_XRECORT", {GetHlpSoluc("C7_XRECORT")[1]}, 5  )} 

     
    //Se não houver edição, desabilita os gets
    If !lEdit
        oXPedFor:lActive := .F.
        oXAnoSaf:lActive := .F.
        oXRecort:lActive := .F. 
    EndIf
     
    RestArea(aArea)
    
Return Nil

/*--------------------------------------------------------------------------------------------------------------*
 | P.E.:  MTA120G2                                                                                              |
 | Desc:  Ponto de Entrada para gravar campos no cabeçalho do pedido de compra                                  |
 | Link:  http://tdn.totvs.com/pages/releaseview.action?pageId=6085572 											|
 | Autor: Andriel Matos       												                                    |
 | Data:  23/08/2017    Versão:1.0 																				|
 *--------------------------------------------------------------------------------------------------------------*/

User Function MTA120G2()

    Local aArea := GetArea()

    If Type("cXPedFor") == "C"
        SC7->C7_XPEDFOR := cXPedFor
    EndIf
    If Type("cXAnoSaf") == "C"
        SC7->C7_XSAFRA := cXAnoSaf
    EndIf

    If Type("lXRecort") == "C" 
        SC7->C7_XRECORT := lXRecort
    EndIf
    
    RestArea( aArea )
Return
