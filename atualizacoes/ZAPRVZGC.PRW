#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "fileio.ch"
#INCLUDE "TopConn.ch"
#Define ENTER CHAR(13)+CHAR(10)

/*
@Autor:         André Claro - andrecclaro@hotmail.com / 35 99877-5495
@Data:          04/04/2022
@Descrição:     Aprovação Niveis 
*/

User Function ZAPRVZGC(_cTpAprov)
Local oGroup1
Local oSay2, oSay3, oSay4
Local lRPC := .F.
Local _cTitTela := ""

Default _cTpAprov := 0

Private oGet3, oGet4, oGet5,  oGet6, oGet7
Private dGet3		:= Date()
Private dGet4		:= Date()

Private dDtIni := Stod("")
Private dDtFim := Stod("")

Private cGet5		:= Space(100)
Private cGet6		:= Space(100)
Private cGet7		:= Space(100)
Private aSize		:= {}
Private aPosObj		:= {}
Private aObjects	:= {}
Private aSortGrd	:= {}
Private aCabec		:= {}
Private aItens		:= {}
Private oMSNewGe1
Private oMSNewGe2
Private oDlg
Private _aNomeRot := {} 
Private _lMuda := .T.
Private cAnoMes := Space(7)
Private _aRetRec := {}
Private oButton1, oButton2, oBut1, oBut2, oBut3, oBut4, oBut5, oBut6, oBut7
Private oButInc1, oButInc2, oButInc3, oButInc4, oButInc5, oButInc6, oButInc7
Private _nVlrAprov := 0.00
Private _nVlrPend := 0.00
Private _cNegocios := ""
Private _aDados := {}
Private cEstilo1,cEstilo2,cEstilo3,cEstilo4,cEstilo5,cEstilo6,cEstilo7
Private _cTpCPX := ZGC->ZGC_TPCAPX

If !U_ZVLDALTER(ZGC->ZGC_CRONOG, _cTpAprov,, ZGC->ZGC_TPCAPX)
    MsgStop("Operação vencida para o cronograma informado!","FORA DA DATA")
    Return .F.
EndIf

If Select("SX2") == 0
    RpcClearEnv()
    RPCSetType(3)
    If(!RpcSetEnv("01", "010101", "", "", "ATF",,{"SN1"}))
        Return(Nil)
    EndIf
    lRPC := .T.
EndIf

    cEstilo1 := ""
    cEstilo1 += "QPushButton{ background-color: #00FF00; "
    cEstilo1 += "border: none; "
    cEstilo1 += "color: #FFFAFA;" 
    cEstilo1 += "padding: 2px 5px;" 
    cEstilo1 += "text-align: center; "
    cEstilo1 += "text-decoration: none; "
    cEstilo1 += "display: inline-block; "
    cEstilo1 += "font-size: 16px; "
    cEstilo1 += "border: none; "
    cEstilo1 += "border-radius: 2px "
    cEstilo1 += "}"

    cEstilo2 := ""
    cEstilo2 += "QPushButton{ background-color: #FF0000; "
    cEstilo2 += "border: none; "
    cEstilo2 += "color: #FFFAFA;" 
    cEstilo2 += "padding: 2px 5px;" 
    cEstilo2 += "text-align: center; "
    cEstilo2 += "text-decoration: none; "
    cEstilo2 += "display: inline-block; "
    cEstilo2 += "font-size: 16px; "
    cEstilo2 += "border: none; "
    cEstilo2 += "border-radius: 2px "
    cEstilo2 += "}"
    
    
    cEstilo3 := ""
    cEstilo3 += "QPushButton{ background-color: #00FF00; "
    cEstilo3 += "border: none; "
    cEstilo3 += "color: #FFFAFA;" 
    cEstilo3 += "padding: 2px 5px;" 
    cEstilo3 += "text-align: center; "
    cEstilo3 += "text-decoration: none; "
    cEstilo3 += "display: inline-block; "
    cEstilo3 += "font-size: 22px; "
    cEstilo3 += "border: none; "
    cEstilo3 += "border-radius: 2px "
    cEstilo3 += "}"   
    
    cEstilo4 := ""
    cEstilo4 += "QPushButton{ background-color: #01584A; "
    cEstilo4 += "border: none; "
    cEstilo4 += "color: #F5FFFA;" 
    cEstilo4 += "padding: 2px 5px;" 
    cEstilo4 += "text-align: center; "
    cEstilo4 += "text-decoration: none; "
    cEstilo4 += "display: inline-block; "
    cEstilo4 += "font-size: 12px; "
    cEstilo4 += "border: none; "
    cEstilo4 += "border-radius: 2px "
    cEstilo4 += "}"
        
        
    cEstilo5 := ""
    cEstilo5 += "QPushButton{ background-color: #54A833; "
    cEstilo5 += "border: none; "
    cEstilo5 += "color: #F5FFFA;" 
    cEstilo5 += "padding: 2px 5px;" 
    cEstilo5 += "text-align: center; "
    cEstilo5 += "text-decoration: none; "
    cEstilo5 += "display: inline-block; "
    cEstilo5 += "font-size: 12px; "
    cEstilo5 += "border: none; "
    cEstilo5 += "border-radius: 2px "
    cEstilo5 += "}"        
    
    cEstilo6 := ""
    cEstilo6 += "QPushButton{ background-color: #098D37; "
    cEstilo6 += "border: none; "
    cEstilo6 += "color: #F5FFFA;" 
    cEstilo6 += "padding: 2px 5px;" 
    cEstilo6 += "text-align: center; "
    cEstilo6 += "text-decoration: none; "
    cEstilo6 += "display: inline-block; "
    cEstilo6 += "font-size: 12px; "
    cEstilo6 += "border: none; "
    cEstilo6 += "border-radius: 2px "
    cEstilo6 += "}"
    
    cEstilo7 := ""
    cEstilo7 += "QPushButton{ background-color: #01584A; "
    cEstilo7 += "border: none; "
    cEstilo7 += "color: #F5FFFA;" 
    cEstilo7 += "padding: 2px 5px;" 
    cEstilo7 += "text-align: center; "
    cEstilo7 += "text-decoration: none; "
    cEstilo7 += "display: inline-block; "
    cEstilo7 += "font-size: 12px; "
    cEstilo7 += "border: none; "
    cEstilo7 += "border-radius: 2px "
    cEstilo7 += "}"

//"CO|FC|N1|N2|RH|SU"
DbSelectArea("ZGE")
ZGE->(DbSetOrder(1))
ZGE->(DbGoTop())

If ZGE->(DbSeek(xFilial("ZGE") + __cUserId + _cTpAprov ))
    While ZGE->(!EOF()) .AND. __cUserId == ZGE->ZGE_USER .AND. _cTpAprov == ZGE->ZGE_TPAPRO
        _cNegocios += ZGE->ZGE_CODNEG+"|"
    ZGE->(DbSkip())
    EndDo
ElseIf _cTpAprov $ "SC|TD|TP|TF"

    If __cUserId <> ZGC->ZGC_USER .and. _cTpAprov <> "SC"
        MsgStop("Usuario sem permissão. Apenas o usuário "+ZGC->ZGC_USER+" poderá gerar/estornar SC para esse CAPEX.","SEM PERMISSAO")
        Return    
    //ElseIf  !U_ZZGCINFR(ZGC->ZGC_FILIAL, ZGC->ZGC_CODKAP, ZGC->ZGC_REVISA, ZGC->ZGC_USER)
    ElseIf  !U_ZZGCINFR(.T.)
        MsgStop("Usuario sem permissão. Apenas o usuário "+ZGC->ZGC_USER+" poderá gerar/estornar SC para esse CAPEX.","SEM PERMISSAO")
        Return
    EndIf
ElseIf _cTpAprov <> "ES"
    MsgStop("Usuario sem permissão. Revise o cadastro de Aprovadores CAPEX","SEM PERMISSAO")
    Return
EndIf

If _cTpAprov == "N1" //Nivel 1
    _cTitTela := "Aprovação Nivel 1"
ElseIf _cTpAprov == "SU" //Suprimentos
    _cTitTela := "Atualização Valores - Suprimentos"
ElseIf _cTpAprov == "N2" //Nível 2 
    _cTitTela := "Aprovação Nível 2"
ElseIf _cTpAprov == "RH" //RH 
    _cTitTela := "Gestão de Pessoas / Legislação"
ElseIf _cTpAprov == "CO" //Conselho 
    _cTitTela := "Aprovação Conselho"
ElseIf _cTpAprov == "FC" //Fluxo de Caixa
    _cTitTela := "Atualização Fluxo de Caixa"
ElseIf _cTpAprov == "ES" //Estorno para Suprimentos
    _cTitTela := "Estorno de movimentação para Suprimentos"
ElseIf _cTpAprov == "SC" //Inclusão de SC
    _cTitTela := "Geração de Solicitação de Compras"
ElseIf _cTpAprov == "TP" //Troca de Produto
    _cTitTela := "Troca de item já aprovado"
ElseIf _cTpAprov == "TD" //Troca de Data de Entrega
    _cTitTela := "Troca de data de Entrega"    
ElseIf _cTpAprov == "PR" //Validação Patrimônio
    _cTitTela := "Validação Equipe Patrimônio"
EndIf

cAnoMes := SubStr(DtoS(dDatabase),1,4) + SubStr(DtoS(dDatabase),5,2)

	aSize := MsAdvSize()
	aAdd(aObjects, {50, 50, .T., .T. })
	aInfo := {aSize[1], aSize[2], aSize[3], aSize[4], 5, 5}
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	DEFINE MSDIALOG oDlg TITLE _cTitTela FROM aSize[7], 0 TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL
		@ 001, 001 GROUP oGroup1 TO 052, aPosObj[1,4] OF oDlg COLOR 0, 16777215 PIXEL
        
        RecDados(,_cTpAprov)
        fMSNewGe1(_cTpAprov)

        oBut1 := TButton():New(aPosObj[1,2]-3,005,"Aprovado " +ENTER+Alltrim(Transform(_nVlrAprov,"@E 9,999"));
                ,oDlg,;
                {|| _zVisual(0) },80,33,,,.F.,.T.,.F.,,.F.,,,.F. )

        oBut1:SetCss(cEstilo1)

        oBut2 := TButton():New(aPosObj[1,2]-3,120,"Pendente"+ENTER+Alltrim(Transform(_nVlrPend,"@E 9,999"));
                ,oDlg,;
                {|| _zVisual(1), },80,33,,,.F.,.T.,.F.,,.F.,,,.F. )

        oBut2:SetCss(cEstilo2)

        If _cTpCPX == "C"
            oBut1 := TButton():New(aPosObj[1,2]-3,300,"Atenção!!! CAPEX COMPLEMENTAR " ;
                    ,oDlg,;
                    {|| _zVisual(0) },280,33,,,.F.,.T.,.F.,,.F.,,,.F. )

            oBut1:SetCss(cEstilo3)
        ElseIf _cTpCPX == "M"
            oBut1 := TButton():New(aPosObj[1,2]-3,300,"Atenção!!! CAPEX COMPL. MANUTENÇÃO " ;
                    ,oDlg,;
                    {|| _zVisual(0) },280,33,,,.F.,.T.,.F.,,.F.,,,.F. )

            oBut1:SetCss(cEstilo3)

        ElseIf _cTpCPX == "I"
            oBut1 := TButton():New(aPosObj[1,2]-3,300,"Atenção!!! CAPEX REF. TROCA DE ITEM " ;
                    ,oDlg,;
                    {|| _zVisual(0) },280,33,,,.F.,.T.,.F.,,.F.,,,.F. )

            oBut1:SetCss(cEstilo3)
        ElseIf _cTpCPX == "D"
            oBut1 := TButton():New(aPosObj[1,2]-3,300,"Atenção!!! CAPEX REF. TROCA DE DATA " ;
                    ,oDlg,;
                    {|| _zVisual(0) },280,33,,,.F.,.T.,.F.,,.F.,,,.F. )

            oBut1:SetCss(cEstilo3)            
        ElseIf _cTpCPX == "F"
            oBut1 := TButton():New(aPosObj[1,2]-3,300,"Atenção!!! CAPEX REF. TROCA DE FILIAL " ;
                    ,oDlg,;
                    {|| _zVisual(0) },280,33,,,.F.,.T.,.F.,,.F.,,,.F. )

            oBut1:SetCss(cEstilo3)
        EndIf

        If _cTpAprov $  "N1/N2/CO"
            @ aPosObj[1,2] , aPosObj[1,4] - 042 BUTTON oButton2 PROMPT "Aprovar"   SIZE 037, 012 OF oDlg ACTION MsgRun(OemToAnsi("Processando Registros Selecionados... Aguarde..."),"",{||  _zRetRec(.T., "A",oDlg, _cTpAprov)}) PIXEL
            @ aPosObj[1,2]+14 , aPosObj[1,4] - 042 BUTTON oButton2 PROMPT "Rejeitar"   SIZE 037, 012 OF oDlg ACTION MsgRun(OemToAnsi("Processando Registros Selecionados... Aguarde..."),"",{||  _zRetRec(.T., "R",oDlg, _cTpAprov)}) PIXEL
        ElseIf _cTpAprov $  "SC"
            @ aPosObj[1,2] , aPosObj[1,4] - 042 BUTTON oButton2    PROMPT "Gerar SC"   SIZE 037, 012 OF oDlg ACTION MsgRun(OemToAnsi("Processando Registros Selecionados... Aguarde..."),"",{||  _zRetRec(.T., "G",oDlg, _cTpAprov)}) PIXEL
            @ aPosObj[1,2]+14 , aPosObj[1,4] - 042 BUTTON oButton2 PROMPT "Estornar SC"   SIZE 037, 012 OF oDlg ACTION MsgRun(OemToAnsi("Processando Registros Selecionados... Aguarde..."),"",{||  _zRetRec(.T., "E",oDlg, _cTpAprov)}) PIXEL
        ElseIf _cTpAprov $  "SU/RH/FC/ES/TP/TD/PR"
            @ aPosObj[1,2] , aPosObj[1,4] - 042 BUTTON oButton2 PROMPT "Salvar"   SIZE 037, 012 OF oDlg ACTION MsgRun(OemToAnsi("Processando Registros Selecionados... Aguarde..."),"",{||  _zRetRec(.T., "A",oDlg, _cTpAprov)}) PIXEL
        EndIf

        @ aPosObj[1,2] +28, aPosObj[1,4] - 042 BUTTON oButton2 PROMPT "Cancelar"   SIZE 037, 012 OF oDlg ACTION MsgRun(OemToAnsi("Processando Registros Selecionados... Aguarde..."),"",{||  _zRetRec(.F.,"",oDlg, _cTpAprov)}) PIXEL
	ACTIVATE MSDIALOG oDlg CENTERED

Return(_aRetRec)

Static Function RecDados(lDelObj, _cTpAprov)
Local _cQuery	:= ""
Local cNewAlias	:= GetNextAlias()
Local aStru		:= {}
Local nPos		:= 0
Local _nX		:= 0
Local _nPosRot := 0
Local _cNomRot := ""
Default lDelObj	:= .T.

	If(lDelObj)
		oMSNewGe1	:= Nil
		oMSNewGe2	:= Nil
	EndIf

	aCabec		:= {}
	aItens		:= {}
	cGet5		:= Upper(cGet5)
	cGet6		:= Upper(cGet6)
	cGet7		:= Upper(cGet7)
	
	_cQuery := " " + CRLF
	_cQuery += " SELECT 	ZGD_FILIAL,ZGD_DABERT,ZGD_ANO,ZGD_MES,ZGD_CODNEG,ZGD_DESNEG,ZGD_CODITE,ZGD_DESCRI, ZGD_QUANT, " + CRLF 
    _cQuery += " ZGD_CONSTR,ZGD_PRIORI,ZGD_PRECO,ZGD_TOTAL, ZGD_RHQLDE, ZGD_RHLEGI, ZGD.R_E_C_N_O_ AS RECZGD, " + CRLF
    _cQuery += "    ZGD.ZGD_STAPN1, ZGD.ZGD_STAPSP,ZGD.ZGD_STAPN2,ZGD.ZGD_STAPRH, ZGD.ZGD_NUMSC,
    _cQuery += "    ZGD.ZGD_STAPCA, ZGD.ZGD_STAPFC, ZGD.ZGD_OBSERV, ZGD_CCUSTO, ZGD_CLVL "    
	_cQuery += " FROM		"+RetSqlName("ZGD")+" ZGD WITH(NOLOCK) " + CRLF

    _cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON  " + CRLF
    _cQuery += "    SB1.B1_FILIAL =  '"+xFilial("SB1")+"' AND SB1.B1_COD = ZGD.ZGD_CODITE AND SB1.D_E_L_E_T_ = '' " + CRLF

	_cQuery += " WHERE		ZGD.D_E_L_E_T_ = '' " + CRLF
	_cQuery += " 		AND ZGD.ZGD_CODKAP = '"+ZGC->ZGC_CODKAP+"' " + CRLF
    _cQuery += " 		AND ZGD.ZGD_REVISA = '"+ZGC->ZGC_REVISA+"' " + CRLF
	_cQuery += " 		AND ZGD.ZGD_FILIAL = '"+xFilial("ZGD")+"' AND ZGD.ZGD_RESIDU = '' " + CRLF

    If _cTpAprov <> "ES" .AND. !_cTpAprov $ "SC|TD|TP|TF|PR"
        _cQuery += "        AND ZGD.ZGD_CODNEG IN " + FormatIn(_cNegocios,"|") + CRLF
    EndIf

    If _cTpAprov == "N1" //Nivel 1
        _cQuery += "        AND ZGD.ZGD_STAPSP <> 'A' " //Suprimentos
        _cQuery += "        AND ZGD.ZGD_STAPCA <> 'A' " // Liberação Conselho Adm
        _cQuery += "        AND ZGD.ZGD_STAPFC <> 'A' " // Liberação Fluxo de Caixa

    ElseIf _cTpAprov == "SU" //Suprimentos
        _cQuery += "        AND ZGD.ZGD_STAPN1  = 'A' "  // Status N1
        _cQuery += "        AND ZGD.ZGD_STAPCA <> 'A' " // Liberação Conselho Adm
        _cQuery += "        AND ZGD.ZGD_STAPFC <> 'A' " // Liberação Fluxo de Caixa

    ElseIf _cTpAprov == "CO" //Conselho 
        _cQuery += "        AND ZGD.ZGD_STAPN1 = 'A' "  // Status N1
        _cQuery += "        AND ZGD.ZGD_STAPSP = 'A' " //Suprimentos
        _cQuery += "        AND ZGD.ZGD_STAPFC <> 'A' " // Liberação Fluxo de Caixa
    
    ElseIf _cTpAprov == "FC" //Fluxo de Caixa
        _cQuery += "        AND ZGD.ZGD_STAPN1 = 'A' "  // Status N1
        _cQuery += "        AND ZGD.ZGD_STAPSP = 'A' " //Suprimentos
        _cQuery += "        AND ZGD.ZGD_STAPCA = 'A' " // Liberação Conselho Adm

    ElseIf _cTpAprov == "ES" //Estorno para Suprimentos        
        _cQuery += "        AND ZGD.ZGD_STAPN1 = 'A' "  // Status N1
        _cQuery += "        AND ZGD.ZGD_STAPSP = 'A' " //Suprimentos
    
    ElseIf _cTpAprov == "PR"
        /*
        If !__cUserId $ SuperGetMv("MV_ZUINFRA",.F.,"000270") .AND. !Empty(SuperGetMv("MV_ZGRINFR",.F.,"103"))
            _cQuery += "        AND SB1.B1_GRUPO <> '"+SuperGetMv("MV_ZGRINFR",.F.,"103")+"' "  // Status N1
        EndIf
        */
        _cQuery += "        AND ZGD.ZGD_STAPN1 = 'A' "  // Status N1
        _cQuery += "        AND ZGD.ZGD_STAPSP = 'A' " //Suprimentos
        _cQuery += "        AND ZGD.ZGD_STAPFC = 'A' " // Liberação Fluxo de Caixa
        _cQuery += "        AND ZGD.ZGD_STAPCA = 'A' " // Liberação Conselho Adm

    ElseIf _cTpAprov == "SC"
        /*
        If !__cUserId $ SuperGetMv("MV_ZUINFRA",.F.,"000270") .AND. !Empty(SuperGetMv("MV_ZGRINFR",.F.,"103"))
            _cQuery += "        AND SB1.B1_GRUPO <> '"+SuperGetMv("MV_ZGRINFR",.F.,"103")+"' "  // Status N1
        EndIf
        */

        _cQuery += "        AND ZGD.ZGD_STAPN1 = 'A' "  // Status N1
        _cQuery += "        AND ZGD.ZGD_STAPSP = 'A' " //Suprimentos
        _cQuery += "        AND ZGD.ZGD_STAPFC = 'A' " // Liberação Fluxo de Caixa
        _cQuery += "        AND ZGD.ZGD_STAPCA = 'A' " // Liberação Conselho Adm
        _cQuery += "        AND ZGD.ZGD_STAPPR = 'A' " // Liberação Patrimonio
        
    ElseIf _cTpAprov $ "TP/TD|TF"
        _cQuery += "        AND ZGD.ZGD_STAPN1 = 'A' "  // Status N1
        _cQuery += "        AND ZGD.ZGD_STAPSP = 'A' " //Suprimentos
        _cQuery += "        AND ZGD.ZGD_STAPFC = 'A' " // Liberação Fluxo de Caixa
        _cQuery += "        AND ZGD.ZGD_STAPCA = 'A' " // Liberação Conselho Adm
        _cQuery += "        AND ZGD.ZGD_NUMSC = ''   " // Liberação Fluxo de Caixa
    EndIf

If _cTpAprov == "N1" //Nivel 1
    _cQuery += "        AND ZGD.ZGD_CODNEG IN " + FormatIn(_cNegocios,"|") + CRLF
    _cTitTela := "Aprovação Nivel 1"
ElseIf _cTpAprov == "SU" //Suprimentos
    _cTitTela := "Atualização Valores - Suprimentos"
ElseIf _cTpAprov == "N2" //Nível 2 
    _cTitTela := "Aprovação Nível 2"
ElseIf _cTpAprov == "RH" //RH 
    _cTitTela := "Gestão de Pessoas / Legislação"
ElseIf _cTpAprov == "CO" //Conselho 
    _cTitTela := "Aprovação Conselho"
ElseIf _cTpAprov == "FC" //Fluxo de Caixa
    _cTitTela := "Atualização Fluxo de Caixa"
ElseIf _cTpAprov == "ES" //Estorno para Suprimentos       
    _cTitTela := "Estorno para suprimentos"
ElseIf _cTpAprov == "SC" //Inclusão de SC
    _cTitTela := "Inclusão de Solicitação de Compras"
ElseIf _cTpAprov == "TP" //Troca de Produto
    _cTitTela := "Troca de item já aprovado"
ElseIf _cTpAprov == "TD" //Troca de Data de Entrega
    _cTitTela := "Troca de data de Entrega"
ElseIf _cTpAprov == "PR" //Validação Patrimônio
    _cTitTela := "Validação Equipe Patrimônio"    
EndIf

    _cQuery += " ORDER BY ZGD_ANO, ZGD_MES, ZGD_CODITE    "
    MemoWrite("C:\Temp\zaprvzgc.sql",_cQuery)
	If(Select(cNewAlias) <> 0)
		dbSelectArea(cNewAlias)
		dbCloseArea()
	EndIf
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cNewAlias,.T.,.T.)
	aStru := dbStruct()

	For _nX := 1 to Len(aStru)
		If(!Empty(FwSX3Util():GetFieldType(ALLTRIM(aStru[_nX][1]))))
			TCSetField(cNewAlias,;
						zSetField(aStru[_nX][1], "X3_CAMPO"),;
						zSetField(aStru[_nX][1], "X3_TIPO"),;
						zSetField(aStru[_nX][1], "X3_TAMANHO"),;
						zSetField(aStru[_nX][1], "X3_DECIMAL"))
		Else
			TCSetField(cNewAlias, aStru[_nX][1], aStru[_nX][2], aStru[_nX][3], aStru[_nX][4])
		EndIf
	Next _nX
    _nVlrAprov := 0
    _nVlrPend := 0
	If !(cNewAlias)->(EOF())
	        While !(cNewAlias)->(EOF())
                            If _cTpAprov == "TD"
                                aAdd(aCabec,    {"LBNO",;
                                            (cNewAlias)->ZGD_FILIAL,;
                                            (cNewAlias)->ZGD_DABERT,;
                                            (cNewAlias)->ZGD_ANO,;
                                            (cNewAlias)->ZGD_MES,;
                                            (cNewAlias)->ZGD_CODNEG,;
                                            (cNewAlias)->ZGD_DESNEG,;
                                            (cNewAlias)->ZGD_CODITE,;
                                            (cNewAlias)->ZGD_DESCRI,;
                                            (cNewAlias)->ZGD_CONSTR,;
                                            (cNewAlias)->ZGD_PRIORI,;
                                            (cNewAlias)->ZGD_QUANT,;
                                            (cNewAlias)->ZGD_PRECO,;
                                            (cNewAlias)->ZGD_TOTAL, (cNewAlias)->ZGD_NUMSC,;
                                            (cNewAlias)->ZGD_RHQLDE,;
                                            (cNewAlias)->ZGD_RHLEGI,"    ","  ",(cNewAlias)->ZGD_OBSERV,;
                                            (cNewAlias)->RECZGD,;
                                            .F.})
                            ElseIf _cTpAprov == "TP"
                                aAdd(aCabec,    {"LBNO",;
                                                (cNewAlias)->ZGD_FILIAL,;
                                                (cNewAlias)->ZGD_DABERT,;
                                                (cNewAlias)->ZGD_ANO,;
                                                (cNewAlias)->ZGD_MES,;
                                                (cNewAlias)->ZGD_CODNEG,;
                                                (cNewAlias)->ZGD_DESNEG,;
                                                (cNewAlias)->ZGD_CODITE,;
                                                (cNewAlias)->ZGD_DESCRI,;
                                                (cNewAlias)->ZGD_CONSTR,;
                                                (cNewAlias)->ZGD_PRIORI,;
                                                (cNewAlias)->ZGD_QUANT,;
                                                (cNewAlias)->ZGD_PRECO,;
                                                (cNewAlias)->ZGD_TOTAL,  (cNewAlias)->ZGD_NUMSC,;
                                                (cNewAlias)->ZGD_RHQLDE,;
                                                (cNewAlias)->ZGD_RHLEGI,;
                                                " ",;
                                                Space(TamSX3("B1_COD")[1]),;
                                                Space(TamSX3("B1_DESC")[1]),;
                                                0.00,;
                                                (cNewAlias)->ZGD_OBSERV,;
                                                (cNewAlias)->RECZGD,;
                                                .F.})
                            ElseIf _cTpAprov == "N1"
                                aAdd(aCabec,    {"LBNO",;
                                                (cNewAlias)->ZGD_FILIAL,;
                                                (cNewAlias)->ZGD_DABERT,;
                                                (cNewAlias)->ZGD_ANO,;
                                                (cNewAlias)->ZGD_MES,;
                                                (cNewAlias)->ZGD_CODNEG,;
                                                (cNewAlias)->ZGD_DESNEG,;
                                                (cNewAlias)->ZGD_CODITE,;
                                                (cNewAlias)->ZGD_DESCRI,;
                                                (cNewAlias)->ZGD_CONSTR,;
                                                (cNewAlias)->ZGD_PRIORI,;
                                                (cNewAlias)->ZGD_QUANT,;
                                                (cNewAlias)->ZGD_PRECO,;
                                                (cNewAlias)->ZGD_TOTAL, (cNewAlias)->ZGD_OBSERV,;
                                                (cNewAlias)->RECZGD,;
                                                .F.})                                               
                            ElseIf _cTpAprov == "PR"
                                    aAdd(aCabec,    {"LBNO",;
                                            (cNewAlias)->ZGD_FILIAL,;
                                            (cNewAlias)->ZGD_DABERT,;
                                            (cNewAlias)->ZGD_ANO,;
                                            (cNewAlias)->ZGD_MES,;
                                            (cNewAlias)->ZGD_CODNEG,;
                                            (cNewAlias)->ZGD_DESNEG,;
                                            (cNewAlias)->ZGD_CODITE,;
                                            (cNewAlias)->ZGD_DESCRI,;
                                            (cNewAlias)->ZGD_CONSTR,;
                                            (cNewAlias)->ZGD_PRIORI,;
                                            (cNewAlias)->ZGD_QUANT,;
                                            (cNewAlias)->ZGD_PRECO,;
                                            (cNewAlias)->ZGD_TOTAL, (cNewAlias)->ZGD_CCUSTO, ;
                                            (cNewAlias)->ZGD_CLVL,;
                                            (cNewAlias)->ZGD_OBSERV,;
                                            (cNewAlias)->RECZGD,;
                                            .F.})   

                            ElseIf _cTpAprov == "SC"
                                    aAdd(aCabec,    {"LBNO",;
                                            (cNewAlias)->ZGD_FILIAL,;
                                            (cNewAlias)->ZGD_DABERT,;
                                            (cNewAlias)->ZGD_ANO,;
                                            (cNewAlias)->ZGD_MES,;
                                            (cNewAlias)->ZGD_CODNEG,;
                                            (cNewAlias)->ZGD_DESNEG,;
                                            (cNewAlias)->ZGD_CODITE,;
                                            (cNewAlias)->ZGD_DESCRI,;
                                            (cNewAlias)->ZGD_CONSTR,;
                                            (cNewAlias)->ZGD_PRIORI,;
                                            (cNewAlias)->ZGD_QUANT,;
                                            (cNewAlias)->ZGD_PRECO,;
                                            (cNewAlias)->ZGD_TOTAL, (cNewAlias)->ZGD_NUMSC, ;
                                            (cNewAlias)->ZGD_FILIAL,;
                                            (cNewAlias)->ZGD_OBSERV,;
                                            (cNewAlias)->RECZGD,;
                                            .F.})  
                            Else
                                aAdd(aCabec,    {"LBNO",;
                                            (cNewAlias)->ZGD_FILIAL,;
                                            (cNewAlias)->ZGD_DABERT,;
                                            (cNewAlias)->ZGD_ANO,;
                                            (cNewAlias)->ZGD_MES,;
                                            (cNewAlias)->ZGD_CODNEG,;
                                            (cNewAlias)->ZGD_DESNEG,;
                                            (cNewAlias)->ZGD_CODITE,;
                                            (cNewAlias)->ZGD_DESCRI,;
                                            (cNewAlias)->ZGD_CONSTR,;
                                            (cNewAlias)->ZGD_PRIORI,;
                                            (cNewAlias)->ZGD_QUANT,;
                                            (cNewAlias)->ZGD_PRECO,;
                                            (cNewAlias)->ZGD_TOTAL, (cNewAlias)->ZGD_NUMSC, ;
                                            (cNewAlias)->ZGD_RHQLDE,;
                                            (cNewAlias)->ZGD_RHLEGI,(cNewAlias)->ZGD_OBSERV,;
                                            (cNewAlias)->RECZGD,;
                                            .F.})
                            EndIf                                                        

                If _cTpAprov == "N1" //Nivel 1
                    If (cNewAlias)->ZGD_STAPN1 == "A" //Aprovado
                        _nVlrAprov ++
                    Else
                        _nVlrPend ++
                    EndIf
                ElseIf _cTpAprov == "SU" //Suprimentos
                    If (cNewAlias)->ZGD_STAPSP == "A" //Aprovado
                        _nVlrAprov ++
                    Else
                        _nVlrPend ++
                    EndIf
                ElseIf _cTpAprov == "N2" //Nível 2 
                    If (cNewAlias)->ZGD_STAPN2 == "A" //Aprovado
                        _nVlrAprov ++
                    Else
                        _nVlrPend ++
                    EndIf
                ElseIf _cTpAprov == "RH" //RH 
                    If (cNewAlias)->ZGD_STAPRH == "A" //Aprovado
                        _nVlrAprov ++
                    Else
                        _nVlrPend ++
                    EndIf
                ElseIf _cTpAprov == "CO" //Conselho 
                    If (cNewAlias)->ZGD_STAPCA == "A" //Aprovado
                        _nVlrAprov ++
                    Else
                        _nVlrPend ++
                    EndIf
                ElseIf _cTpAprov == "FC" //Fluxo de Caixa
                    If (cNewAlias)->ZGD_STAPFC == "A" //Aprovado
                        _nVlrAprov ++
                    Else
                        _nVlrPend ++
                    EndIf
                EndIf

		        (cNewAlias)->(dbSkip())
	        EndDo
        EndIf

	dbSelectArea(cNewAlias)
	dbCloseArea()

Return(Nil)

Static Function fMSNewGe1(_cTpAprov)
Local _nX			:= 0
Local aHeaderEx		:= {}
Local aColsEx		:= {}
Local aFieldFill	:= {}
Local aFields		:= {} //{ "ZGD_FILIAL","ZGD_DABERT","ZGD_ANO","ZGD_MES","ZGD_CODNEG","ZGD_DESNEG","ZGD_CODITE","ZGD_DESCRI","ZGD_CONSTR","ZGD_PRIORI","ZGD_QUANT","ZGD_PRECO","ZGD_TOTAL","ZGD_RHQLDE","ZGD_RHLEGI"}
Local aAlterFields	:= {}
Local aExc			:= {}

If _cTpAprov == "TP"
   aFields := { "ZGD_FILIAL","ZGD_DABERT","ZGD_ANO","ZGD_MES","ZGD_CODNEG","ZGD_DESNEG","ZGD_CODITE","ZGD_DESCRI","ZGD_CONSTR","ZGD_PRIORI",;
                "ZGD_QUANT","ZGD_PRECO","ZGD_TOTAL","ZGD_NUMSC","ZGD_RHQLDE","ZGD_RHLEGI","TPREGP","C1_PRODUTO","B1_DESC","NEWQTD","C1_OBS"}
ElseIf _cTpAprov == "TD"
   aFields := { "ZGD_FILIAL","ZGD_DABERT","ZGD_ANO","ZGD_MES","ZGD_CODNEG","ZGD_DESNEG","ZGD_CODITE","ZGD_DESCRI","ZGD_CONSTR","ZGD_PRIORI","ZGD_QUANT","ZGD_PRECO","ZGD_TOTAL","ZGD_NUMSC","ZGD_RHQLDE","ZGD_RHLEGI","NEW_ANO","NEW_MES","C1_OBS"}
ElseIf _cTpAprov == "N1"
   aFields := { "ZGD_FILIAL","ZGD_DABERT","ZGD_ANO","ZGD_MES","ZGD_CODNEG","ZGD_DESNEG","ZGD_CODITE","ZGD_DESCRI","ZGD_CONSTR","ZGD_PRIORI","ZGD_QUANT","ZGD_PRECO","ZGD_TOTAL","C1_OBS"}
ElseIf _cTpAprov == "SC"
   aFields := { "ZGD_FILIAL","ZGD_DABERT","ZGD_ANO","ZGD_MES","ZGD_CODNEG","ZGD_DESNEG","ZGD_CODITE","ZGD_DESCRI","ZGD_CONSTR","ZGD_PRIORI","ZGD_QUANT","ZGD_PRECO","ZGD_TOTAL","ZGD_NUMSC","C1_FILENT","C1_OBS"}
ElseIf _cTpAprov == "PR"
    aFields := { "ZGD_FILIAL","ZGD_DABERT","ZGD_ANO","ZGD_MES","ZGD_CODNEG","ZGD_DESNEG","ZGD_CODITE","ZGD_DESCRI","ZGD_CONSTR","ZGD_PRIORI","ZGD_QUANT","ZGD_PRECO","ZGD_TOTAL","ZGD_CCUSTO","ZGD_CLVL","C1_OBS"}
Else
    aFields := { "ZGD_FILIAL","ZGD_DABERT","ZGD_ANO","ZGD_MES","ZGD_CODNEG","ZGD_DESNEG","ZGD_CODITE","ZGD_DESCRI","ZGD_CONSTR","ZGD_PRIORI","ZGD_QUANT","ZGD_PRECO","ZGD_TOTAL","ZGD_NUMSC","ZGD_RHQLDE","ZGD_RHLEGI","C1_OBS"} 
Endif

If _cTpAprov == "SU"
    aAlterFields	:= {"ZGD_PRECO","ZGD_TOTAL"}
ElseIf _cTpAprov == "SC"
    aAlterFields	:= {"ZGD_QUANT","C1_FILENT"}
ElseIf _cTpAprov == "RH"
    aAlterFields	:= {"ZGD_RHQLDE","ZGD_RHLEGI"}
ElseIf _cTpAprov == "TP"
    aAlterFields	:= {"TPREGP","C1_PRODUTO","B1_DESC","NEWQTD","C1_OBS"}
ElseIf _cTpAprov == "TD"
    aAlterFields	:= {"NEW_ANO","NEW_MES","C1_OBS"}    
ElseIf _cTpAprov == "PR" //Patrimonio - Pessoal vai ter a opção de alterar mais campos que o normal
    aAlterFields	:= {"ZGD_ANO","ZGD_MES","ZGD_CCUSTO","ZGD_CLVL","ZGD_CODITE"}       
EndIf

	aAdd(aExc, {"X3_VALID", ".T."})
	aAdd(aHeaderEx, {"","CHECKBOL","@BMP",10,0,,,"C",,"V",,,"mark","V","S"})

	For _nX := 1 to Len(aFields)
		If Alltrim(afields[_nX]) $ "ZGD_ANO"
			aAdd(aExc, {"X3_VALID", ".T."})
			aAdd(aExc, {"X3_RELACAO", " "})
			aAdd(aHeaderEx, GetSX3(aFields[_nX], aExc))
			aExc := {}
			aAdd(aExc, {"X3_VALID", ".T."})
        ElseIf  Alltrim(afields[_nX]) $ "C1_PRODUTO"
			//aAdd(aExc, {"X3_VALID", ".T."})
            aAdd(aExc, {"X3_VALID", "U_ZGDC1PRD()"})
			aAdd(aExc, {"X3_RELACAO", " "})
            aAdd(aExc, {"X3_PICTURE", "@!"})
            aAdd(aExc, {"X3_TAMANHO", TamSX3("C1_PRODUTO")[1]})
            
			aAdd(aHeaderEx, GetSX3(aFields[_nX], aExc))
			aExc := {}
			aAdd(aExc, {"X3_VALID", ".T."})

        ElseIf  Alltrim(afields[_nX]) $ "ZGD_DESNEG|ZGD_DESCRI"
            aAdd(aExc, {"X3_TAMANHO", 25})
			aAdd(aHeaderEx, GetSX3(aFields[_nX], aExc))
			aExc := {}
			aAdd(aExc, {"X3_VALID", ".T."})
        ElseIf Alltrim(afields[_nX]) $ "NEW_ANO"
            aAdd(aExc, {"X3_VALID", ".T."})
			aAdd(aExc, {"X3_RELACAO", " "})
            aAdd(aExc, {"X3_CAMPO", "NEW_ANO"})
            aAdd(aExc, {"X3_TITULO", "Novo Ano "})              
			aAdd(aHeaderEx, GetSX3("ZGD_ANO", aExc))
			aExc := {}
			aAdd(aExc, {"X3_VALID", ".T."})        
        ElseIf Alltrim(afields[_nX]) $ "NEW_MES"
            aAdd(aExc, {"X3_VALID", ".T."})
			aAdd(aExc, {"X3_RELACAO", " "})
            aAdd(aExc, {"X3_CAMPO", "NEW_MES"})
            aAdd(aExc, {"X3_TITULO", "Novo Mês "})            
			aAdd(aHeaderEx, GetSX3("ZGD_MES", aExc))
			aExc := {}
			aAdd(aExc, {"X3_VALID", ".T."})

        ElseIf Alltrim(afields[_nX]) $ "NEWQTD"
            aAdd(aExc, {"X3_VALID", ".T."})
			aAdd(aExc, {"X3_RELACAO", " "})
            aAdd(aExc, {"X3_CAMPO", "NEWQTD"})
            aAdd(aExc, {"X3_TITULO", "Nova Qtde. "})
			aAdd(aHeaderEx, GetSX3("ZGD_QUANT", aExc))
			aExc := {}
			aAdd(aExc, {"X3_VALID", ".T."})

        ElseIf Alltrim(afields[_nX]) $ "ZGD_QUANT"
            aAdd(aExc, {"X3_VALID", "U_ZZGDSC1S()"})
			aAdd(aHeaderEx, GetSX3("ZGD_QUANT", aExc))
			aExc := {}
			aAdd(aExc, {"X3_VALID", ".T."})
            
        ElseIf Alltrim(afields[_nX]) $ "TPREGP"
            aAdd(aExc, {"X3_VALID", ".T."})
			aAdd(aExc, {"X3_RELACAO", " "})
            aAdd(aExc, {"X3_CAMPO", "TPREGP"})
            aAdd(aExc, {"X3_TITULO", "Construção? "})            
			aAdd(aHeaderEx, GetSX3("ZGD_CONSTR", aExc))
			aExc := {}
			aAdd(aExc, {"X3_VALID", ".T."})
        Else
			aExc := {}
			aAdd(aExc, {"X3_VALID", ".T."})        
			aAdd(aHeaderEx, GetSX3(aFields[_nX], aExc))
		EndIf
	Next _nX
	aAdd(aHeaderEx, {"Recno WT","REC_WT","",10,0,NIL,"û", "N",,"V"})

	If(Len(aCabec) == 0)
		aAdd(aFieldFill, "LBNO")

		For _nX := 1 to Len(aFields)
			If(!Empty(FwSX3Util():GetFieldType(aFields[_nX])))
				aAdd(aFieldFill, CriaVar(aFields[_nX]))
            ElseIf aFields[_nX] == "NEWQTD"
                aAdd(aFieldFill,  0 )
            ElseIf aFields[_nX] == "NEW_ANO"
                aAdd(aFieldFill,  '' )
            ElseIf aFields[_nX] == "NEW_MES"
                aAdd(aFieldFill,  '' )
            ElseIf aFields[_nX] == "TPREGP"
                aAdd(aFieldFill,  '' )    
			EndIf
		Next _nX
		aAdd(aFieldFill, 0)
		aAdd(aFieldFill, .F.)
		aAdd(aColsEx, aFieldFill)
	Else
		aColsEx	:= aClone(aCabec)
		aCabec	:= Nil
		aCabec	:= {}
	EndIf

    oMSNewGe1 := MsNewGetDados():New(aPosObj[1,1]+25, aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
	oMSNewGe1:oBrowse:bHeaderClick := {|oMSNewGe1, nCol| Ordena(nCol, Time())}

	oMSNewGe1:oBrowse:bLDblClick   := {|| SelItens()}

	oMSNewGe1:oBrowse:lUseDefaultColors := .T.
	oMSNewGe1:oBrowse:SetBlkBackColor({|| GETDCLR(oMSNewGe1:aCols, oMSNewGe1:nAt, oMSNewGe1:aHeader, oMSNewGe1, _cTpAprov)})

Return(Nil)

Static Function GETDCLR(aLinha, nLinha, aHeader, oMSNewGe1, _cTpAprov)
Local nVermelh	:= RGB(128, 255, 000)
Local nPosOk	:= aScan(aHeader,{|x| Alltrim(x[2]) == "CHECKBOL"})
Local nPRecno	:= aScan(aHeader,{|x| Alltrim(x[2]) == "REC_WT"})
Local nRet     	:= oMSNewGe1:oBrowse:NCLRFOREFOCUS

	If(aLinha[nLinha][nPosOk] == "LBOK")
		nRet := nVermelh
	EndIf
    DbSelectArea("ZGD")
    ZGD->(DbSetOrder(1))
    ZGD->(DbGoTop())
    ZGD->(DbGoTo(aLinha[nLinha][nPRecno] ))

    If ZGD->(RECNO()) == aLinha[nLinha][nPRecno]
            If !Empty(ZGD->ZGD_NUMSC)
                nRet := nVermelh
            ElseIf _cTpAprov == "N1" //Nivel 1
                If ZGD->ZGD_STAPN1 == "A" //Aprovado
                    nRet := nVermelh
                ElseIf ZGD->ZGD_STAPN1 == "R" //Rejeitado
                    nRet := RGB( 255, 0, 0 )
                EndIf
            ElseIf _cTpAprov == "SU" //Suprimentos
                If ZGD->ZGD_STAPSP == "A" //Aprovado
                    nRet := nVermelh
                ElseIf ZGD->ZGD_STAPSP == "R" //Rejeitado
                    nRet := RGB( 255, 0, 0 )
                EndIf
            ElseIf _cTpAprov == "N2" //Nível 2 
                If ZGD->ZGD_STAPN2 == "A" //Aprovado
                    nRet := nVermelh
                ElseIf ZGD->ZGD_STAPN2 == "R" //Rejeitado
                    nRet := RGB( 255, 0, 0 )
                EndIf
            ElseIf _cTpAprov == "RH" //RH 
                If ZGD->ZGD_STAPRH == "A" //Aprovado
                    nRet := nVermelh
                ElseIf ZGD->ZGD_STAPRH == "R" //Rejeitado
                    nRet := RGB( 255, 0, 0 )
                EndIf
            ElseIf _cTpAprov == "CO" //Conselho 
                If ZGD->ZGD_STAPCA == "A" //Aprovado
                    nRet := nVermelh
                ElseIf ZGD->ZGD_STAPCA == "R" //Rejeitado
                    nRet := RGB( 255, 0, 0 )
                EndIf
            ElseIf _cTpAprov == "FC" //Fluxo de Caixa
                If ZGD->ZGD_STAPFC == "A" //Aprovado
                    nRet := nVermelh
                ElseIf ZGD->ZGD_STAPFC == "R" //Rejeitado
                    nRet := RGB( 255, 0, 0 )
                EndIf
            EndIf
    EndIf
Return(nRet)


Static Function Ordena(nCol, cTime)
Local aCoBrw1	:= oMSNewGe1:aCols
Local nPosOk		:= aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "CHECKBOL"})
Local _nX		:= 0
Local cOdem		:= ""

If nCol == 1  
	If _lMuda
		For _nX := 1 to Len(oMSNewGe1:aCols)
			If oMSNewGe1:aCols[_nX][nPosOk] == "LBOK"
				oMSNewGe1:aCols[_nX][nPosOk] := "LBNO"
			Else
				oMSNewGe1:aCols[_nX][nPosOk] := "LBOK"
			EndIf
		Next _nX 
		_lMuda := .F.
		oMSNewGe1:Refresh()			//Atualiza a Getdados
		oMSNewGe1:oBrowse:Refresh()	//Atualiza a Getdados do browse em tela.
		oDlg:Refresh()
	Else
		_lMuda := .T.
	EndIf
Else
	For _nX := 1 to Len(aSortGrd)
		If(aSortGrd[_nX][01] == nCol)
			If(aSortGrd[_nX][02] == Time())
				Return(Nil)
			Else
				cOdem := aSortGrd[_nX][03]
			EndIf
		EndIf
	Next _nX

	If(cOdem == "" .OR. cOdem == "C")
		aAdd(aSortGrd, {nCol, cTime, "D"})
		aCoBrw1 := aSort(aCoBrw1,,,{|x,y| x[nCol] < y[nCol]})
	Else
		aAdd(aSortGrd, {nCol, cTime, "C"})
		aCoBrw1 := aSort(aCoBrw1,,,{|x,y| x[nCol] > y[nCol]})
	EndIf

	oMSNewGe1:setArray(aCoBrw1) 
	oMSNewGe1:oBrowse:Refresh() 
EndIf
Return(Nil)

Static Function SelItens()
Local _nX		:= 0
Local nPosOk	:= aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "CHECKBOL"})
Local nPRecno	:= aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "REC_WT"})
Local nPTotal	:= aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "ZGD_TOTAL"})

	oMSNewGe1:aCols[oMSNewGe1:nAt][nPosOk] := IIf(oMSNewGe1:aCols[oMSNewGe1:nAt][nPosOk] == "LBOK", "LBNO", "LBOK")
	If(oMSNewGe1:aCols[oMSNewGe1:nAt][nPosOk] == "LBOK")
		_nVlrAprov += oMSNewGe1:aCols[oMSNewGe1:nAt][nPTotal]
        _nVlrPend -= oMSNewGe1:aCols[oMSNewGe1:nAt][nPTotal]
    Else
		_nVlrAprov -= oMSNewGe1:aCols[oMSNewGe1:nAt][nPTotal]
        _nVlrPend += oMSNewGe1:aCols[oMSNewGe1:nAt][nPTotal]
	EndIf

	oMSNewGe1:Refresh()			//Atualiza a Getdados
	oMSNewGe1:oBrowse:Refresh()	//Atualiza a Getdados do browse em tela.
	oDlg:Refresh()

Return(Nil)


// Retorna os recnos selecionados.
Static Function _zRetRec(_lAtu, _cStatus, oDlg,_cTpAprov) //_nOpc = 1 ok, 2 cancela

Local _aArea		:= GetArea()
Local _aAreaZGD := ZGD->(GetArea())
Local nPosOk		:= 0 // aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "CHECKBOL"})
Local nPRecno		:= 0 // aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "REC_WT"})
Local _nPosVlr      := 0
Local _nPosQtd      := 0
Local _nPosprc      := 0
Local _nPC1FILENT      := 0
Local _cFilBkp := ''
Local _nPRHleg      := 0
Local _nPRHQld      := 0
Local _aDadEmail := {}
Local _nX 			:= 0 
Local _nZ := 0
Local _aEnvMail := {}
Local _aLinhaC1 := {}
Local _aCabSC   := {}
Local _aItensSC := {}
Local _cFilSB1 := xFilial("SB1")
Local _cFilZGC := xFilial("ZGC")
Local _cFilCTT := xFilial("CTT")
Local _cFilCTH := xFilial("CTH")
Local _cFilSC1 := xFilial("SC1")
Local _cFilBkp := ''
Local _cLogSC := ""
Local _cLogSCOK := ""
Local _aDadTela := {} //Dados para estorno da SC
Local _aRecSC1Es := {} // Recnos selecionados para estorno da SC
Local _cDoc := ''
Local _nPNewProd := 0
Local _nPNewDesc := 0
Local _nPC1OBS    := 0
Local _nPTPRegP    := 0
Local _nPNewAno := 0
Local _nPNewMes := 0
Local _nPNqtd    := 0
Local _aFielZGC := {}
Local _aFielZGD := {}
Local _aAllFZGC := {}
Local _aAllFZGD := {}
Local _cNaoAtual := ""
Local _nzgdprc := 0 
Local _aNewZGD := {}

Local _aNewCap := {}
Local _cRevisa := ""
Local _nRecZGC := ZGC->(RECNO())
Local _nPCC := 0
Local _nPClvl := 0
Local _nPProd := 0
Local _nPAno := 0
Local _nPMes := 0


Private lMsErroAuto := .F.

Default _lAtu := .T.
Default _cStatus := ""
If _lAtu 
    nPosOk		:= aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "CHECKBOL"})
    nPRecno		:= aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "REC_WT"})

    If _cTpAprov == "SU"
        For _nX := 1 to Len(oMSNewGe1:aCols)
            If(oMSNewGe1:aCols[_nX][nPRecno] > 0 .AND. oMSNewGe1:aCols[_nX][nPosOk] == "LBOK")

                _nPosprc    := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "ZGD_PRECO"})
                _nPosVlr    := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "ZGD_TOTAL"})                        

                If oMSNewGe1:aCols[_nX][_nPosprc] <= 0 .or. oMSNewGe1:aCols[_nX][_nPosVlr] <= 0 
                    MsgInfo("Informe o preço unitário e total para prosseguir!","VLR NAO INFORMADO")
                    Return 
                EndIf
            EndIf
        Next _nX
    EndIf

    If !_cTpAprov $ "SC|TD|TP|TF|PR"
        For _nX := 1 to Len(oMSNewGe1:aCols)
            If(oMSNewGe1:aCols[_nX][nPRecno] > 0 .AND. oMSNewGe1:aCols[_nX][nPosOk] == "LBOK")
                DbSelectArea("ZGD")
                ZGD->(DbSetOrder(1))
                ZGD->(DbGoTo(oMSNewGe1:aCols[_nX][nPRecno]))
                If ZGD->(RECNO()) == oMSNewGe1:aCols[_nX][nPRecno]
                    DbSelectArea("ZGC")
                    ZGC->(DbSetOrder(1))
                    ZGC->(DbGoTop())
                    _aDadEmail := {}
                    If ZGC->(DbSeek(xFilial("ZGC") + ZGD->ZGD_CODKAP  ))
                        aAdd(_aDadEmail, ZGC->ZGC_FILIAL ) 
                        aAdd(_aDadEmail, ZGC->ZGC_CODKAP ) 
                        aAdd(_aDadEmail, ZGC->ZGC_DESCRI ) 
                    EndIf

                    If  ZGD->(RecLock("ZGD",.F.))
                        If _cTpAprov == "N1" //Nivel 1

                            
                            If _cStatus == "D" //Devolve
                                ZGD->ZGD_USERN1 := ""
                                ZGD->ZGD_DTSTN1 := sTOD("")                       
                                ZGD->ZGD_STAPN1 := "P" //P/A/R/D
                            ElseIf _cStatus == "R" //Rejeita
                                ZGD->ZGD_USERN1 := cUserName
                                ZGD->ZGD_DTSTN1 := Date()                        
                                ZGD->ZGD_STAPN1 := _cStatus //P/A/R/D
                                ZGD->ZGD_STAPSP := _cStatus
                                ZGD->ZGD_STAPCA := _cStatus
                                ZGD->ZGD_STAPFC := _cStatus

                            Else
                                ZGD->ZGD_USERN1 := cUserName
                                ZGD->ZGD_DTSTN1 := Date()                        
                                ZGD->ZGD_STAPN1 := _cStatus //P/A/R/D
                                aAdd(_aDadEmail, ZGD->ZGD_GESTOR ) 
                                aAdd(_aDadEmail, ZGD->ZGD_CODNEG ) 
                                aAdd(_aDadEmail, ZGD->ZGD_DESNEG ) 
                                aAdd(_aDadEmail, ZGD->ZGD_CODITE ) 
                                aAdd(_aDadEmail, ZGD->ZGD_DESCRI ) 
                                aAdd(_aDadEmail, ZGD->ZGD_OBSERV ) 
                                aAdd(_aDadEmail, "   " ) 
                                aAdd(_aDadEmail, ZGD->ZGD_TOTAL ) 
                                aAdd(_aDadEmail, ZGD->ZGD_CLVL ) 
                                aAdd(_aDadEmail, ZGD->ZGD_FILIAL ) 
                                aAdd(_aEnvMail, _aDadEmail )
                            EndIf
                            
                        ElseIf _cTpAprov == "SU" //Suprimentos
                            _nPosprc    := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "ZGD_PRECO"})
                            _nPosVlr    := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "ZGD_TOTAL"})                        
                            ZGD->ZGD_USERSU := cUserName

                            ZGD->ZGD_DTSTSU := Date()
                            ZGD->ZGD_PRECO := oMSNewGe1:aCols[_nX][_nPosprc]
                            ZGD->ZGD_TOTAL := oMSNewGe1:aCols[_nX][_nPosVlr]

                            If _cStatus == "D" //Devolve
                                ZGD->ZGD_STAPSP := "1"
                            Else
                                ZGD->ZGD_STAPSP := _cStatus
                                aAdd(_aDadEmail, ZGD->ZGD_GESTOR ) 
                                aAdd(_aDadEmail, ZGD->ZGD_CODNEG ) 
                                aAdd(_aDadEmail, ZGD->ZGD_DESNEG ) 
                                aAdd(_aDadEmail, ZGD->ZGD_CODITE ) 
                                aAdd(_aDadEmail, ZGD->ZGD_DESCRI ) 
                                aAdd(_aDadEmail, ZGD->ZGD_OBSERV ) 
                                aAdd(_aDadEmail, "   " ) 
                                aAdd(_aDadEmail, ZGD->ZGD_TOTAL ) 
                                aAdd(_aDadEmail, ZGD->ZGD_CLVL ) 
                                aAdd(_aDadEmail, ZGD->ZGD_FILIAL ) 
                                
                                aAdd(_aEnvMail, _aDadEmail )                            
                            EndIf
                            


                        ElseIf _cTpAprov == "CO" //Conselho 
                        
                            ZGD->ZGD_USERCA := cUserName
                            ZGD->ZGD_DTSTCA := Date()

                            If _cStatus == "D" //Devolve
                                ZGD->ZGD_STAPCA := "4"
                            ElseIf _cStatus == "R" //Rejeita
                                ZGD->ZGD_USERCA := cUserName
                                ZGD->ZGD_DTSTCA := Date()
                                ZGD->ZGD_STAPN1 := _cStatus //P/A/R/D
                                ZGD->ZGD_STAPSP := _cStatus
                                ZGD->ZGD_STAPCA := _cStatus
                                ZGD->ZGD_STAPFC := _cStatus 
                            Else
                                ZGD->ZGD_STAPCA := _cStatus
                                aAdd(_aDadEmail, ZGD->ZGD_GESTOR ) 
                                aAdd(_aDadEmail, ZGD->ZGD_CODNEG ) 
                                aAdd(_aDadEmail, ZGD->ZGD_DESNEG ) 
                                aAdd(_aDadEmail, ZGD->ZGD_CODITE ) 
                                aAdd(_aDadEmail, ZGD->ZGD_DESCRI ) 
                                aAdd(_aDadEmail, ZGD->ZGD_OBSERV ) 
                                aAdd(_aDadEmail, "   " ) 
                                aAdd(_aDadEmail, ZGD->ZGD_TOTAL ) 
                                aAdd(_aDadEmail, ZGD->ZGD_CLVL )   
                                aAdd(_aDadEmail, ZGD->ZGD_FILIAL )                           
                                aAdd(_aEnvMail, _aDadEmail )                            
                            EndIf
                        
                        ElseIf _cTpAprov == "FC" //Fluxo de Caixa

                            ZGD->ZGD_USERFC := cUserName
                            ZGD->ZGD_DTSTFC := Date()
                            
                            If _cStatus == "D" //Devolve
                                ZGD->ZGD_STAPFC := "5"
                            ElseIf _cStatus == "R" //Rejeita
                                ZGD->ZGD_USERFC := cUserName
                                ZGD->ZGD_DTSTFC := Date()
                                ZGD->ZGD_STAPN1 := _cStatus //P/A/R/D
                                ZGD->ZGD_STAPSP := _cStatus
                                ZGD->ZGD_STAPCA := _cStatus
                                ZGD->ZGD_STAPFC := _cStatus                             
                            Else
                                ZGD->ZGD_STAPFC := _cStatus
                                aAdd(_aDadEmail, ZGD->ZGD_GESTOR ) 
                                aAdd(_aDadEmail, ZGD->ZGD_CODNEG ) 
                                aAdd(_aDadEmail, ZGD->ZGD_DESNEG ) 
                                aAdd(_aDadEmail, ZGD->ZGD_CODITE ) 
                                aAdd(_aDadEmail, ZGD->ZGD_DESCRI ) 
                                aAdd(_aDadEmail, ZGD->ZGD_OBSERV ) 
                                aAdd(_aDadEmail, "   " ) 
                                aAdd(_aDadEmail, ZGD->ZGD_TOTAL ) 
                                aAdd(_aDadEmail, ZGD->ZGD_CLVL )  
                                aAdd(_aDadEmail, ZGD->ZGD_FILIAL )                              
                                aAdd(_aEnvMail, _aDadEmail )                            
                            EndIf
                        ElseIf _cTpAprov == "ES" //Estorno para suprimentos

                            If !Empty(ZGD->ZGD_USERCA) .AND. !Empty(ZGD->ZGD_STAPCA)
                                ZGC->(DbGoTop())
                                _aDadEmail := {}
                                If ZGC->(DbSeek(xFilial("ZGC") + ZGD->ZGD_CODKAP  ))
                                    aAdd(_aDadEmail, ZGC->ZGC_FILIAL ) 
                                    aAdd(_aDadEmail, ZGC->ZGC_CODKAP ) 
                                    aAdd(_aDadEmail, ZGC->ZGC_DESCRI ) 
                                EndIf                        
                                aAdd(_aDadEmail, ZGD->ZGD_GESTOR ) 
                                aAdd(_aDadEmail, ZGD->ZGD_CODNEG ) 
                                aAdd(_aDadEmail, ZGD->ZGD_DESNEG ) 
                                aAdd(_aDadEmail, ZGD->ZGD_CODITE ) 
                                aAdd(_aDadEmail, ZGD->ZGD_DESCRI ) 
                                aAdd(_aDadEmail, ZGD->ZGD_OBSERV ) 
                                aAdd(_aDadEmail, "   " ) 
                                aAdd(_aDadEmail, ZGD->ZGD_TOTAL ) 
                                aAdd(_aDadEmail, ZGD->ZGD_CLVL ) 
                                aAdd(_aDadEmail, ZGD->ZGD_FILIAL ) 
                                
                                aAdd(_aEnvMail, _aDadEmail )                          
                                ZNOTIFICA("ES", ZGD->ZGD_CODNEG, _aEnvMail, ZGC->ZGC_USER, ZGD->ZGD_USERCA)
                            EndIf


                            ZGD->ZGD_USERCA := ""
                            ZGD->ZGD_STAPCA := ''
                            ZGD->ZGD_DTSTCA := Stod("")

                            If !Empty(ZGD->ZGD_USERFC) .AND. !Empty(ZGD->ZGD_STAPFC)
                                ZGC->(DbGoTop())
                                _aDadEmail := {}
                                If ZGC->(DbSeek(xFilial("ZGC") + ZGD->ZGD_CODKAP  ))
                                    aAdd(_aDadEmail, ZGC->ZGC_FILIAL ) 
                                    aAdd(_aDadEmail, ZGC->ZGC_CODKAP ) 
                                    aAdd(_aDadEmail, ZGC->ZGC_DESCRI ) 
                                EndIf                        
                                aAdd(_aDadEmail, ZGD->ZGD_GESTOR ) 
                                aAdd(_aDadEmail, ZGD->ZGD_CODNEG ) 
                                aAdd(_aDadEmail, ZGD->ZGD_DESNEG ) 
                                aAdd(_aDadEmail, ZGD->ZGD_CODITE ) 
                                aAdd(_aDadEmail, ZGD->ZGD_DESCRI ) 
                                aAdd(_aDadEmail, ZGD->ZGD_OBSERV ) 
                                aAdd(_aDadEmail, "   " ) 
                                aAdd(_aDadEmail, ZGD->ZGD_TOTAL ) 
                                aAdd(_aDadEmail, ZGD->ZGD_CLVL ) 
                                aAdd(_aDadEmail, ZGD->ZGD_FILIAL ) 
                                aAdd(_aEnvMail, _aDadEmail )                          
                                ZNOTIFICA("ES", ZGD->ZGD_CODNEG, _aEnvMail, ZGC->ZGC_USER, ZGD->ZGD_USERFC)
                            EndIf

                            ZGD->ZGD_USERFC := ""
                            ZGD->ZGD_STAPFC := ''
                            ZGD->ZGD_DTSTFC := Stod("")
                        EndIf                    

                        ZGD->(MsUnlock())
                    EndIf
                EndIf
            EndIf
        Next _nX
    EndIf

    If _cTpAprov == "N1" //Nivel 1
        ZNOTIFICA("SU",ZGD->ZGD_CODNEG, _aEnvMail, ZGC->ZGC_USER)
    ElseIf _cTpAprov == "SU" //Suprimentos
        ZNOTIFICA("CO", ZGD->ZGD_CODNEG, _aEnvMail, ZGC->ZGC_USER)
    ElseIf _cTpAprov == "CO" //Conselho 
        ZNOTIFICA("FC", ZGD->ZGD_CODNEG, _aEnvMail, ZGC->ZGC_USER)
    ElseIf _cTpAprov == "FC" //Fluxo de Caixa
        ZNOTIFICA("PR", ZGD->ZGD_CODNEG, _aEnvMail, ZGC->ZGC_USER)
    ElseIf _cTpAprov == "PR" //Patrimonio
        ZNOTIFICA("FI", ZGD->ZGD_CODNEG, _aEnvMail, ZGC->ZGC_USER)        
    EndIf 

    /*
    @Autor:    André Claro
    @Data:     14/12/2022
    @Descrição: Geração das SC para os itens selecionados
    */


    If _cTpAprov == "SC"

        If _cStatus == "G" //Gerar SC
            DbSelectArea("SC1")
            SC1->(DbSetOrder(1))
            SC1->(DbGoTop())
            _nPosVlr    := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "ZGD_TOTAL"}) 
            _nPosQtd    := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "ZGD_QUANT"}) 
            _nPC1FILENT := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "C1_FILENT"}) 
            
            For _nX := 1 to Len(oMSNewGe1:aCols)
                _aDadEmail := {}
                If(oMSNewGe1:aCols[_nX][nPRecno] > 0 .AND. oMSNewGe1:aCols[_nX][nPosOk] == "LBOK")
                    DbSelectArea("ZGD")
                    ZGD->(DbSetOrder(1))
                    ZGD->(DbGoTo(oMSNewGe1:aCols[_nX][nPRecno]))
                    If ZGD->(RECNO()) == oMSNewGe1:aCols[_nX][nPRecno]
                        If !Empty(ZGD->ZGD_NUMSC)
                            _cLogSC += "Item: "+Alltrim(ZGD->ZGD_CODITE)+"-"+ZGD->ZGD_DESCRI+" já gerou a SC ("+ZGD->ZGD_NUMSC+")"+CHAR(13)+CHAR(10)
                        ElseIf (ZGD->ZGD_ANO+ZGD->ZGD_MES) > Substring(DTOS(Date()),1,6)
                            _cLogSC += "Item: "+Alltrim(ZGD->ZGD_CODITE)+"-"+ZGD->ZGD_DESCRI+" deverá ser gerado em "+ZGD->ZGD_ANO+"/"+ZGD->ZGD_MES+CHAR(13)+CHAR(10)
                        Else
                            _nQtScAnt := ACVLDSC1(ZGD->ZGD_FILIAL, ZGD->ZGD_CODKAP, ZGD->ZGD_ITEM)
                            If (ZGD->ZGD_QUANT -_nQtScAnt ) < oMSNewGe1:aCols[_nX][_nPosQtd] 
                                 _cLogSC += "Item: "+Alltrim(ZGD->ZGD_CODITE)+"-"+ZGD->ZGD_DESCRI+" SC Gerada Anteriormente"+CValToChar(_nQtScAnt)+" Saldo: "+cValToChar(ZGD->ZGD_QUANT -_nQtScAnt)  +CHAR(13)+CHAR(10)
                            Else
                                If SB1->(DbSeek(_cFilSB1 + ZGD->ZGD_CODITE ))
                                    _cFilBkp := cFilAnt
                                    If oMSNewGe1:aCols[_nX][_nPC1FILENT]  <> cFilAnt
                                        _cFilBkp := cFilAnt
                                        cFilAnt := oMSNewGe1:aCols[_nX][_nPC1FILENT]
                                        OpenSm0(cEmpAnt + cFilAnt )
                                    EndIf

                                    lMsErroAuto := .F.
                                    While .T.
                                        _cDoc := ""
                                        _cDoc := GetSXENum("SC1","C1_NUM")
                                        SC1->(dbGoTop())
                                        If SC1->(dbSeek(oMSNewGe1:aCols[_nX][_nPC1FILENT] + _cDoc ))
                                            ConfirmSX8()
                                        Else
                                            Exit
                                        EndIf
                                    EndDo

                                    _aCabSC := {}
                                    aadd(_aCabSC,{"C1_NUM"       ,_cDoc       })
                                    aadd(_aCabSC,{"C1_SOLICIT"   ,cUserName  })
                                    aadd(_aCabSC,{"C1_EMISSAO"   ,dDataBase  })
                                    aadd(_aCabSC,{"C1_XSERVI"   ,"N"  })

                                    _aLinhaC1 := {}
                                    _aItensSC := {}
                                    aadd(_aLinhaC1,{"C1_ITEM"   , StrZero(_nX,TamSx3("C1_ITEM")[1]) ,  Nil  })
                                    aadd(_aLinhaC1,{"C1_PRODUTO", SB1->B1_COD                       , Nil})
                                    aadd(_aLinhaC1,{"C1_QUANT"  , oMSNewGe1:aCols[_nX][_nPosQtd]    , Nil})
                                    aadd(_aLinhaC1,{"C1_ZUPRC"  , (oMSNewGe1:aCols[_nX][_nPosVlr] / oMSNewGe1:aCols[_nX][_nPosQtd]  )    , Nil})
                                    //aadd(_aLinhaC1,{"C1_PRECO"  , (oMSNewGe1:aCols[_nX][_nPosVlr] / oMSNewGe1:aCols[_nX][_nPosQtd]  )  , Nil})
                                    //aadd(_aLinhaC1,{"C1_TOTAL"  , oMSNewGe1:aCols[_nX][_nPosVlr]    , Nil})
									aadd(_aLinhaC1,{"C1_XSERVI", IIF(SB1->B1_TIPO=="SV","S","N")    , Nil})

                                    aadd(_aLinhaC1,{"C1_ZTIPOSC"  , "C"    , Nil})
                                    aadd(_aLinhaC1,{"C1_CC"     , ZGD->ZGD_CCUSTO                   , Nil})
                                    aadd(_aLinhaC1,{"C1_XSERVI"     , "N"                   , Nil})
                                    aadd(_aLinhaC1,{"C1_OBS" , "Ref. Capex "+Alltrim(ZGD->ZGD_CODKAP)+"/"+ZGD->ZGD_ITEM+" - "+Alltrim(ZGD->ZGD_OBSERV) ,Nil})

                                    aadd(_aItensSC,_aLinhaC1)

                                    MSExecAuto({|x,y| mata110(x,y,3)}, _aCabSC , _aItensSC)
                                    If lMsErroAuto
                                        MostraErro()
                                    Else
                                        _cLogSCOK += "Item "+ZGD->ZGD_ITEM+" Gerou a SC: "+_cDoc+CHAR(13)+CHAR(10)
                                        /*
                                        If  ZGD->(RecLock("ZGD",.F.))
                                                ZGD->ZGD_NUMSC := _cDoc
                                            ZGD->(MsUnlock())
                                        EndIf
                                        */

                                        aAdd(_aDadEmail, ZGC->ZGC_FILIAL ) 
                                        aAdd(_aDadEmail, ZGC->ZGC_CODKAP ) 
                                        aAdd(_aDadEmail, ZGC->ZGC_DESCRI ) 
                                        aAdd(_aDadEmail, ZGD->ZGD_GESTOR ) 
                                        aAdd(_aDadEmail, ZGD->ZGD_CODNEG ) 
                                        aAdd(_aDadEmail, ZGD->ZGD_DESNEG ) 
                                        aAdd(_aDadEmail, ZGD->ZGD_CODITE ) 
                                        aAdd(_aDadEmail, ZGD->ZGD_DESCRI ) 
                                        aAdd(_aDadEmail, ZGD->ZGD_OBSERV ) 
                                        aAdd(_aDadEmail, _cDoc           ) 
                                        aAdd(_aDadEmail, oMSNewGe1:aCols[_nX][_nPosVlr]  ) 
                                        aAdd(_aDadEmail, ZGD->ZGD_CLVL )  
                                        aAdd(_aDadEmail, oMSNewGe1:aCols[_nX][_nPC1FILENT] ) 
                                        aAdd(_aEnvMail, _aDadEmail ) 
                                        


                                        DbSelectArea("SC1")
                                        SC1->(DbSetOrder(1))
                                        SC1->(DbGoTop())
                                        If SC1->(DbSeek(xFilial("SC1") + _cDoc ))
                                            If  SC1->(RecLock("SC1",.F.))
                                                    SC1->C1_APROV := "L"
                                                    SC1->C1_NOMAPRO := "ZAPRVZGC"
                                                    //SC1->C1_PRECO := ZGD->ZGD_PRECO
                                                    //SC1->C1_TOTAL := oMSNewGe1:aCols[_nX][_nPosVlr]
                                                    SC1->C1_ZCODKAP := ZGD->ZGD_CODKAP
                                                    SC1->C1_ZITEKAP := ZGD->ZGD_ITEM
                                                    SC1->C1_ZREVKAP := ZGD->ZGD_REVISA
                                                    SC1->C1_ZFILKAP := ZGD->ZGD_FILIAL
                                                SC1->(MsUnlock())
                                            EndIf
                                        EndIf

                                        
                                        If _cFilBkp  <> cFilAnt
                                            _cFilBkp := ''
                                            cFilAnt := cFilAnt
                                            OpenSm0(cEmpAnt + cFilAnt )
                                        EndIf

                                    EndIf
                                Else
                                    _cLogSC += "Item: "+Alltrim(ZGD->ZGD_CODITE)+"-"+ZGD->ZGD_DESCRI+" não existe no cadastro de produtos"+CHAR(13)+CHAR(10)
                                EndIf
                            EndIf
                        EndIf
                    EndIf
                EndIf
            Next _nX
            If !Empty(_cLogSC)
                Aviso("Problema na inclusão de SCs", _cLogSC, {"Sair"} , 2 , "Alguns itens não poderão gerar SCs")
            EndIf
            If !Empty(_cLogSCOK)
                Aviso("Inclusão de SCs", _cLogSCOK, {"Sair"} , 2 , "Foram geradas Solicitações de Compras")
                If Len(_aEnvMail) > 0 
                    ZNOTIFICA("SC", ZGD->ZGD_CODNEG, _aEnvMail, ZGC->ZGC_USER)
                EndIf
            EndIf            

        ElseIf _cStatus == "E" //Estorno de SC
            _aEnvMail := {}
            DbSelectArea("SC1")
            SC1->(DbSetOrder(1))
            SC1->(DbGoTop())
            For _nX := 1 to Len(oMSNewGe1:aCols)
                If(oMSNewGe1:aCols[_nX][nPRecno] > 0 .AND. oMSNewGe1:aCols[_nX][nPosOk] == "LBOK")
                    DbSelectArea("ZGD")
                    ZGD->(DbSetOrder(1))
                    ZGD->(DbGoTo(oMSNewGe1:aCols[_nX][nPRecno]))
                    If ZGD->(RECNO()) == oMSNewGe1:aCols[_nX][nPRecno]
                        SC1->(DbGoTop())
                        If !Empty(ZGD->ZGD_NUMSC)
                            If ZGD->ZGD_FILORI <> ZGD->ZGD_FILIAL .AND. !Empty(ZGD->ZGD_FILIAL)
                                _cFilBkp := cFilAnt
                                _cFilSC1 := ZGD->ZGD_FILORI
                                cFilAnt := ZGD->ZGD_FILORI
                                OpenSm0( cEmpAnt + cFilAnt )
                            EndIf
                            If SC1->(DbSeek(_cFilSC1 + ZGD->ZGD_NUMSC))
                                IF !Empty(SC1->C1_COTACAO) .or. !EMPTY(SC1->C1_PEDIDO) .OR. Alltrim(SC1->C1_RESIDUO) == "S" .or.  SC1->C1_QUJE <> 0
                                    _cLogSC += "A SC "+SC1->C1_NUM+" já está em processo de Cotação ou já gerou Ped. Compra ou teve resíduo eliminado."+CHAR(13)+CHAR(10)
                                ElseIf Empty(ZGD->ZGD_NUMSC)
                                    _cLogSC += "O item "+ZGD->ZGD_ITEM+" não gerou SC"+CHAR(13)+CHAR(10)
                                Else
                                    lMsErroAuto := .F.

                                    _aCabSC := {}
                                    _cDoc := SC1->C1_NUM
                                    aadd(_aCabSC,{"C1_NUM"       , SC1->C1_NUM       })
                                    aadd(_aCabSC,{"C1_SOLICIT"   , SC1->C1_SOLICIT   })
                                    aadd(_aCabSC,{"C1_EMISSAO"   , SC1->C1_EMISSAO   })

                                    _aDadEmail := {}
                                    aAdd(_aDadEmail, ZGC->ZGC_FILIAL ) 
                                    aAdd(_aDadEmail, ZGC->ZGC_CODKAP ) 
                                    aAdd(_aDadEmail, ZGC->ZGC_DESCRI ) 
                                    aAdd(_aDadEmail, ZGD->ZGD_GESTOR ) 
                                    aAdd(_aDadEmail, ZGD->ZGD_CODNEG ) 
                                    aAdd(_aDadEmail, ZGD->ZGD_DESNEG ) 
                                    aAdd(_aDadEmail, ZGD->ZGD_CODITE ) 
                                    aAdd(_aDadEmail, ZGD->ZGD_DESCRI ) 
                                    aAdd(_aDadEmail, ZGD->ZGD_OBSERV ) 
                                    aAdd(_aDadEmail, _cDoc           ) 
                                    aAdd(_aDadEmail, SC1->C1_TOTAL ) 
                                    aAdd(_aDadEmail, ZGD->ZGD_CLVL )
                                    aAdd(_aDadEmail, ZGC->ZGC_FILIAL ) 

                                    _aLinhaC1 := {}
                                    _aItensSC := {}

                                    MSExecAuto({|x,y| mata110(x,y,5)}, _aCabSC , _aLinhaC1)
                                    If lMsErroAuto
                                        MostraErro()
                                    Else
                                        _cLogSCOK += _cDoc+"|"
                                        aAdd(_aEnvMail, _aDadEmail ) 

                                        If  ZGD->(RecLock("ZGD",.F.))
                                                ZGD->ZGD_NUMSC := ""
                                            ZGD->(MsUnlock())
                                        EndIf                                
                                    EndIf
                                EndIf
                            EndIf

                                If _cFilBkp <> cFilAnt
                                    _cFilSC1 := _cFilBkp
                                    cFilAnt := _cFilBkp
                                    OpenSm0( cEmpAnt + cFilAnt )
                                EndIf  

                        Else
                            _cAliasSC1 := GetNextAlias()
                            BeginSql alias _cAliasSC1
                                %noparser%
                                COLUMN C1_EMISSAO AS DATE
                                SELECT  SC1.C1_FILIAL, SC1.C1_NUM, SC1.C1_ITEM, SC1.C1_PRODUTO, SC1.C1_DESCRI, SC1.C1_QUANT,
                                        (CASE WHEN SC1.C1_ZUPRC <> 0 THEN SC1.C1_ZUPRC ELSE SC1.C1_PRECO END) AS C1_PRECO,
                                        ROUND(SC1.C1_QUANT * (CASE WHEN SC1.C1_ZUPRC <> 0 THEN SC1.C1_ZUPRC ELSE SC1.C1_PRECO END),2) AS C1_TOTAL,
                                        SC1.R_E_C_N_O_ AS RECSC1, SC1.C1_EMISSAO
                                FROM        %table:SC1% SC1 WITH(NOLOCK)
                                WHERE		SC1.D_E_L_E_T_ = ''
                                        AND (CASE WHEN SC1.C1_ZFILKAP = '' THEN SC1.C1_FILIAL ELSE SC1.C1_ZFILKAP END) = %exp:ZGD->ZGD_FILIAL%
                                        AND SC1.C1_ZCODKAP =  %exp:ZGD->ZGD_CODKAP%
                                        AND SC1.C1_ZITEKAP =  %exp:ZGD->ZGD_ITEM%
                                        AND SC1.C1_ZCODKAP <> ''
                            EndSql

                            // Abrir tela para seleção das SCs... gravar com base no retorno, realizar a exclusão 

                            While (_cAliasSC1)->(!eof())
                                aAdd(_aDadTela , { "LBNO", (_cAliasSC1)->C1_FILIAL,(_cAliasSC1)->C1_EMISSAO, (_cAliasSC1)->C1_NUM, (_cAliasSC1)->C1_ITEM,; 
                                                    (_cAliasSC1)->C1_PRODUTO, (_cAliasSC1)->C1_DESCRI, (_cAliasSC1)->C1_QUANT,;
                                                    (_cAliasSC1)->C1_PRECO, (_cAliasSC1)->C1_TOTAL, (_cAliasSC1)->RECSC1, .F. } )
                                aAdd(_aRecSC1Es, (_cAliasSC1)->RECSC1 )
                            (_cAliasSC1)->(DbSkip())
                            EndDo

                            If Len(_aRecSC1Es) > 1 
                                _aRecSC1Es := {}
                                _aRecSC1Es := ACRECSC1(_aDadTela)
                            EndIf

                            If Len(_aRecSC1Es) < 1 
                                _cLogSC += "Não foram selecionadas SCs para estorno! "+CHAR(13)+CHAR(10)
                            Else

                                (_cAliasSC1)->(DbGoTop())
                                While (_cAliasSC1)->(!eof())
                                    SC1->(DbGoTop())
                                    SC1->(DbGoTo((_cAliasSC1)->RECSC1))
                                    If SC1->(RECNO()) == (_cAliasSC1)->RECSC1 .and. aScan(_aRecSC1Es, (_cAliasSC1)->RECSC1 ) > 0 
                                        IF !Empty(SC1->C1_COTACAO) .or. !EMPTY(SC1->C1_PEDIDO) .OR. Alltrim(SC1->C1_RESIDUO) == "S" .or.  SC1->C1_QUJE <> 0
                                            _cLogSC += "A SC "+SC1->C1_NUM+" já está em processo de Cotação ou já gerou Ped. Compra ou teve resíduo eliminado."+CHAR(13)+CHAR(10)
                                        Else
                                            lMsErroAuto := .F.

                                            _aCabSC := {}
                                            _cDoc := SC1->C1_NUM
                                            aadd(_aCabSC,{"C1_NUM"       , SC1->C1_NUM       })
                                            aadd(_aCabSC,{"C1_SOLICIT"   , SC1->C1_SOLICIT   })
                                            aadd(_aCabSC,{"C1_EMISSAO"   , SC1->C1_EMISSAO   })

                                            _aLinhaC1 := {}
                                            _aItensSC := {}

                                            If SC1->C1_FILIAL <> cFilAnt
                                                _cFilBkp := cFilAnt
                                                cFilAnt := SC1->C1_FILIAL
                                                OpenSm0( cEmpAnt + cFilAnt )
                                            EndIf

                                            MSExecAuto({|x,y| mata110(x,y,5)}, _aCabSC , _aLinhaC1)
                                            If lMsErroAuto
                                                MostraErro()
                                            Else
                                                _aDadEmail := {}

                                                aAdd(_aDadEmail, ZGC->ZGC_FILIAL ) 
                                                aAdd(_aDadEmail, ZGC->ZGC_CODKAP ) 
                                                aAdd(_aDadEmail, ZGC->ZGC_DESCRI ) 
                                                aAdd(_aDadEmail, ZGD->ZGD_GESTOR ) 
                                                aAdd(_aDadEmail, ZGD->ZGD_CODNEG ) 
                                                aAdd(_aDadEmail, ZGD->ZGD_DESNEG ) 
                                                aAdd(_aDadEmail, ZGD->ZGD_CODITE ) 
                                                aAdd(_aDadEmail, ZGD->ZGD_DESCRI ) 
                                                aAdd(_aDadEmail, ZGD->ZGD_OBSERV ) 
                                                aAdd(_aDadEmail, _cDoc           ) 
                                                aAdd(_aDadEmail, ZGD->ZGD_TOTAL ) 
                                                aAdd(_aDadEmail, ZGD->ZGD_CLVL ) 
                                                aAdd(_aDadEmail, SC1->C1_FILIAL ) 

                                                _cLogSCOK += _cDoc+"|"
                                                aAdd(_aEnvMail, _aDadEmail ) 

                                                If  ZGD->(RecLock("ZGD",.F.))
                                                        ZGD->ZGD_NUMSC := ""
                                                    ZGD->(MsUnlock())
                                                EndIf   

                                                If _cFilBkp <> cFilAnt
                                                    cFilAnt := _cFilBkp
                                                    OpenSm0( cEmpAnt + cFilAnt )
                                                EndIf                                                                             
                                            EndIf
                                        EndIf
                                    EndIf
                                (_cAliasSC1)->(DbSkip())
                                EndDo
                            EndIf
                            (_cAliasSC1)->(DbCloseArea())

                        EndIf                       
                    EndIf
                EndIf
            Next _nX


            If !Empty(_cLogSC)
                Aviso("Problema no estorno da SC", _cLogSC, {"Sair"} , 2 , "Alguns itens não poderão gerar SCs")
            EndIf
            If !Empty(_cLogSCOK)
                Aviso("Estorno de SCs", _cLogSCOK, {"Sair"} , 2 , "Foram estornadas Solicitações de Compras")
                If Len(_aEnvMail) > 0 
                    ZNOTIFICA("SC", ZGD->ZGD_CODNEG, _aEnvMail, ZGC->ZGC_USER,,.T.)
                EndIf
            EndIf
        EndIf


    ////// patrimonio
    ElseIf _cTpAprov == "PR"

        _nPCC := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "ZGD_CCUSTO"})      
        _nPClvl := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "ZGD_CLVL"})      
        _nPProd := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "ZGD_CODITE"})      
        _nPAno := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "ZGD_ANO"})     
        _nPMes := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "ZGD_MES"})      

        DbSelectArea("CTT")
        CTT->(DbSetOrder(1))
        DbSelectArea("SB1")
        SB1->(DbSetOrder(1))        
        For _nX := 1 to Len(oMSNewGe1:aCols)
            If(oMSNewGe1:aCols[_nX][nPRecno] > 0 .AND. oMSNewGe1:aCols[_nX][nPosOk] == "LBOK")
                If Empty(oMSNewGe1:aCols[_nX][_nPCC] )
                    _cLogSC += "Item: "+Alltrim(ZGD->ZGD_CODITE)+"-"+ZGD->ZGD_DESCRI+" sem C. Custo"+CHAR(13)+CHAR(10)
                Else
                    CTT->(DbGoTop())
                    If CTT->(DbSeek(_cFilCTT + oMSNewGe1:aCols[_nX][_nPCC]))
                        If CTT->CTT_BLOQ == "1"
                            _cLogSC += "Item: "+Alltrim(ZGD->ZGD_CODITE)+"-"+ZGD->ZGD_DESCRI+" C. Custo "+oMSNewGe1:aCols[_nX][_nPCC]+" bloqueado"+CHAR(13)+CHAR(10)
                        ElseIf CTT->CTT_CLASSE == "1"
                            _cLogSC += "Item: "+Alltrim(ZGD->ZGD_CODITE)+"-"+ZGD->ZGD_DESCRI+" C. Custo "+oMSNewGe1:aCols[_nX][_nPCC]+" sintático"+CHAR(13)+CHAR(10)
                        EndIf
                    Else
                        _cLogSC += "Item: "+Alltrim(ZGD->ZGD_CODITE)+"-"+ZGD->ZGD_DESCRI+" C. Custo "+oMSNewGe1:aCols[_nX][_nPCC]+" não existe"+CHAR(13)+CHAR(10)
                    EndIf
                EndIf

                If Empty(oMSNewGe1:aCols[_nX][_nPProd] )
                    _cLogSC += "Item: "+Alltrim(ZGD->ZGD_CODITE)+"-"+ZGD->ZGD_DESCRI+" sem produto"+CHAR(13)+CHAR(10)
                Else
                    SB1->(DbGoTop())
                    If SB1->(DbSeek(_cFilSB1 + oMSNewGe1:aCols[_nX][_nPProd]))
                        If SB1->B1_MSBLQL == "1"
                            _cLogSC += "Item: "+Alltrim(ZGD->ZGD_CODITE)+"-"+ZGD->ZGD_DESCRI+" produto "+oMSNewGe1:aCols[_nX][_nPCC]+" bloqueado"+CHAR(13)+CHAR(10)
                        ElseIf Alltrim(SB1->B1_COD) $ SuperGetMv("MV_ZZGDPRD",.F.,"") 
                            If Empty(oMSNewGe1:aCols[_nX][_nPClvl]) //Se for contrução em andamento
                                _cLogSC += "Item: "+Alltrim(ZGD->ZGD_CODITE)+"-"+ZGD->ZGD_DESCRI+" Construção em Andamento sem CLVL "+CHAR(13)+CHAR(10)
                            Else
                                CTH->(DbGoTop())
                                If CTH->(DbSeek(_cFilCTH + oMSNewGe1:aCols[_nX][_nPClvl]))
                                    If CTH->CTH_BLOQ == "1"
                                        _cLogSC += "Item: "+Alltrim(ZGD->ZGD_CODITE)+"-"+ZGD->ZGD_DESCRI+" Cl. Valor "+oMSNewGe1:aCols[_nX][_nPClvl]+" bloqueado"+CHAR(13)+CHAR(10)
                                    ElseIf CTH->CTH_CLASSE == "1"
                                        _cLogSC += "Item: "+Alltrim(ZGD->ZGD_CODITE)+"-"+ZGD->ZGD_DESCRI+" Cl. Valor "+oMSNewGe1:aCols[_nX][_nPClvl]+" sintético"+CHAR(13)+CHAR(10)
                                    EndIf
                                Else
                                    _cLogSC += "Item: "+Alltrim(ZGD->ZGD_CODITE)+"-"+ZGD->ZGD_DESCRI+" Cl. Valor "+oMSNewGe1:aCols[_nX][_nPClvl]+" não existe"+CHAR(13)+CHAR(10)
                                EndIf
                            EndIf
                        EndIf
                    Else
                        _cLogSC += "Item: "+Alltrim(ZGD->ZGD_CODITE)+"-"+ZGD->ZGD_DESCRI+" produto "+oMSNewGe1:aCols[_nX][_nPCC]+" não existe"+CHAR(13)+CHAR(10)
                    EndIf
                EndIf

            EndIf
        Next _nX 

        If !Empty(_cLogSC)
            Aviso("Problema na inclusão de SCs", _cLogSC, {"Sair"} , 2 , "Alguns itens não poderão gerar SCs")
            Return .f.
        Else
            For _nX := 1 to Len(oMSNewGe1:aCols)
                _aDadEmail := {}
                If(oMSNewGe1:aCols[_nX][nPRecno] > 0 .AND. oMSNewGe1:aCols[_nX][nPosOk] == "LBOK")
                    DbSelectArea("ZGD")
                    ZGD->(DbSetOrder(1))
                    ZGD->(DbGoTo(oMSNewGe1:aCols[_nX][nPRecno]))
                    If ZGD->(RECNO()) == oMSNewGe1:aCols[_nX][nPRecno]
                        If  ZGD->(RecLock("ZGD",.F.))
                                ZGD->ZGD_CCUSTO := oMSNewGe1:aCols[_nX][_nPCC]
                                ZGD->ZGD_CLVL := oMSNewGe1:aCols[_nX][_nPClvl]
                                ZGD->ZGD_CODITE := oMSNewGe1:aCols[_nX][_nPProd]
                                ZGD->ZGD_ANO := oMSNewGe1:aCols[_nX][_nPAno]
                                ZGD->ZGD_MES := oMSNewGe1:aCols[_nX][_nPMes]
                                ZGD->ZGD_USERPR := cUserName
                                ZGD->ZGD_DTSTPR := Date()
                                ZGD->ZGD_STAPPR := _cStatus
                            ZGD->(MsUnlock())
                        EndIf


                        aAdd(_aDadEmail, ZGC->ZGC_FILIAL ) 
                        aAdd(_aDadEmail, ZGC->ZGC_CODKAP ) 
                        aAdd(_aDadEmail, ZGC->ZGC_DESCRI ) 
                        aAdd(_aDadEmail, ZGD->ZGD_GESTOR ) 
                        aAdd(_aDadEmail, ZGD->ZGD_CODNEG ) 
                        aAdd(_aDadEmail, ZGD->ZGD_DESNEG ) 
                        aAdd(_aDadEmail, ZGD->ZGD_CODITE ) 
                        aAdd(_aDadEmail, ZGD->ZGD_DESCRI ) 
                        aAdd(_aDadEmail, ZGD->ZGD_OBSERV ) 
                        aAdd(_aDadEmail, _cDoc           ) 
                        aAdd(_aDadEmail, ZGD->ZGD_TOTAL ) 
                        aAdd(_aDadEmail, ZGD->ZGD_CLVL ) 
                        aAdd(_aDadEmail, ZGD->ZGD_FILIAL ) 
                        aAdd(_aEnvMail, _aDadEmail ) 

                    EndIf
                EndIf
            Next _nX
            ////AQUI ANDRE CLARO 08/11/23 AS 12:30
            If Len(_aEnvMail) > 0 
                ZNOTIFICA("FI", ZGD->ZGD_CODNEG, _aEnvMail, ZGC->ZGC_USER)
            EndIf

        EndIf
        

    ElseIf _cTpAprov == "TD" //TROCA DATA

        _nPNewAno := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "NEW_ANO"})
        _nPNewMes := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "NEW_MES"})
        _nPC1OBS    := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "C1_OBS"})

        For _nX := 1 to Len(oMSNewGe1:aCols)
            If(oMSNewGe1:aCols[_nX][nPRecno] > 0 .AND. oMSNewGe1:aCols[_nX][nPosOk] == "LBOK")
                If Empty(oMSNewGe1:aCols[_nX][_nPNewAno])
                    Aviso("Definição do novo registro", "Informe o novo ano.", {"Sair"} , 2 , "Confira os itens e tente novamente!")
                    Return 
                ElseIf Empty(oMSNewGe1:aCols[_nX][_nPNewMes])
                    Aviso("Definição do novo registro", "Informe o novo mês.", {"Sair"} , 2 , "Confira os itens e tente novamente!")
                    Return 
                ElseIf Empty(oMSNewGe1:aCols[_nX][_nPC1OBS])
                    Aviso("Definição do novo registro", "Informe o motivo da troca.", {"Sair"} , 2 , "Confira os itens e tente novamente!")
                    Return 
                ElseIf oMSNewGe1:aCols[_nX][_nPNewAno]+oMSNewGe1:aCols[_nX][_nPNewMes] < SubStr(DtoS(Date()),1,6)
                    Aviso("Definição do novo registro", "Não é permitido alteração de vencimento para data anterior a hoje!", {"Sair"} , 2 , "Confira os itens e tente novamente!")
                    Return 
                EndIf
            EndIf
        Next _nX

        DbSelectArea("ZGC")
        ZGC->(DbSetOrder(1))
        
        For _nX := 1 to Len(oMSNewGe1:aCols)
            _aDadEmail := {}
            If(oMSNewGe1:aCols[_nX][nPRecno] > 0 .AND. oMSNewGe1:aCols[_nX][nPosOk] == "LBOK")
                DbSelectArea("ZGD")
                ZGD->(DbSetOrder(1))
                ZGD->(DbGoTo(oMSNewGe1:aCols[_nX][nPRecno]))
                If ZGD->(RECNO()) == oMSNewGe1:aCols[_nX][nPRecno]
                        If Empty(_aFielZGC)
                            _aAllFZGC := FWSX3Util():GetAllFields( "ZGC" , .F. )
                            ZGC->(DbGoTop())
                            If ZGC->(DbSeek( _cFilZGC + ZGD->ZGD_CODKAP  ))   
                                _cRevisa := ZGCREVIS(_cFilZGC, ZGD->ZGD_CODKAP)
                                For _nZ := 1 to Len(_aAllFZGC)
                                    If(!Empty(FwSX3Util():GetFieldType(alltrim(_aAllFZGC[_nZ]))))
                                        If GetSx3Cache(alltrim(_aAllFZGC[_nZ]), "X3_CONTEXT") <> "V"
                                            If Alltrim(_aAllFZGC[_nZ]) == "ZGC_REVISA"
                                                aAdd(_aFielZGC, { Alltrim(_aAllFZGC[_nZ]), _cRevisa  } )
                                            ElseIf Alltrim(_aAllFZGC[_nZ]) == "ZGC_TPCAPX" //Troca Data
                                                aAdd(_aFielZGC, { Alltrim(_aAllFZGC[_nZ]), "D"  } )
                                            Else
                                                aAdd(_aFielZGC, { Alltrim(_aAllFZGC[_nZ]), &('ZGC->'+Alltrim(_aAllFZGC[_nZ]) )  } )
                                            EndIf
                                        EndIf
                                    EndIf 
                                Next _nZ                                                
                            EndIf
                        EndIf
                        If !Empty(_aFielZGC) 
                            _aAllFZGD := FWSX3Util():GetAllFields( "ZGD" , .F. )
                            _aFielZGD := {}

                            _cNaoAtual := ""
                            _cNaoAtual += "ZGD_STAPCA|ZGD_DTSTCA|ZGD_USERCA|ZGD_STAPFC|ZGD_DTSTFC|ZGD_USERFC|"

                            For _nZ := 1 to Len(_aAllFZGD)
                                If !Alltrim(_aAllFZGD[_nZ]) $ _cNaoAtual

                                    If(!Empty(FwSX3Util():GetFieldType(alltrim(_aAllFZGD[_nZ]))))
                                        If GetSx3Cache(alltrim(_aAllFZGD[_nZ]), "X3_CONTEXT") <> "V"
                                            If Alltrim(_aAllFZGD[_nZ]) == "ZGD_REVISA"
                                                aAdd(_aFielZGD, { Alltrim(_aAllFZGD[_nZ]), _cRevisa  } )
                                            ElseIf Alltrim(_aAllFZGD[_nZ]) == "ZGD_ANO" //Ano
                                                aAdd(_aFielZGD, { Alltrim(_aAllFZGD[_nZ]), oMSNewGe1:aCols[_nX][_nPNewAno]  } )
                                            ElseIf Alltrim(_aAllFZGD[_nZ]) == "ZGD_MES" //Mês
                                                aAdd(_aFielZGD, { Alltrim(_aAllFZGD[_nZ]), oMSNewGe1:aCols[_nX][_nPNewMes]  } )
                                            ElseIf Alltrim(_aAllFZGD[_nZ]) == "ZGD_OBSERV" //Observação
                                                aAdd(_aFielZGD, { Alltrim(_aAllFZGD[_nZ]), oMSNewGe1:aCols[_nX][_nPC1OBS]  } )
                                            Else
                                                aAdd(_aFielZGD, { Alltrim(_aAllFZGD[_nZ]), &('ZGD->'+Alltrim(_aAllFZGD[_nZ]) )  } )
                                            EndIf
                                        EndIf
                                    EndIf 
                                EndIf
                            Next _nZ  
                            If Len(_aFielZGD) > 0 
                                aAdd(_aNewZGD, _aFielZGD )
                                aAdd(_aNewCap, oMSNewGe1:aCols[_nX][nPRecno] )
                            EndIf
                        Else
                            MsgStop("Não foi possível criar vetor de transferência de data.","PROBLEMA")
                            Exit
                        EndIf
                EndIf
            EndIf
        Next _nX


        If len(_aNewCap) > 0 .and. Len(_aNewZGD) > 0 .and. Len(_aFielZGC) > 0 
            Begin Transaction
                
                For _nX := 1 to Len(_aNewCap)
                    DbSelectArea("ZGD")
                    ZGD->(DbSetOrder(1))
                    ZGD->(DbGoTo(_aNewCap[_nX]))
                    If ZGD->(RECNO()) == _aNewCap[_nX]
                        If  ZGD->(RecLock("ZGD",.F.))
                                ZGD->ZGD_RESIDU := "D"
                                ZGD->ZGD_REVDES := _cRevisa
                            ZGD->(MsUnlock())
                        EndIf
                    EndIf        
                Next _nX
                //Criando o cabeçalho
                ZGC->(RecLock("ZGC",.T.))
                    For _nX := 1 to Len(_aFielZGC)
                        &('ZGC->'+Alltrim(_aFielZGC[_nX][1])) := _aFielZGC[_nX][2]
                    Next _nX 
                ZGC->(MsUnlock())
                _aDadEmail := {}
                _aEnvMail := {}


                
                For _nX := 1 to Len(_aNewZGD)
                    ZGD->(RecLock("ZGD",.T.))
                        For _nZ := 1 to Len(_aNewZGD[_nX])
                            &('ZGD->'+Alltrim(_aNewZGD[_nX][_nZ][1])) := _aNewZGD[_nX][_nZ][2]
                        Next _nZ 
                    ZGD->(MsUnlock())

                    aAdd(_aDadEmail, ZGC->ZGC_FILIAL )
                    aAdd(_aDadEmail, ZGC->ZGC_CODKAP )
                    aAdd(_aDadEmail, ZGC->ZGC_DESCRI )
                    aAdd(_aDadEmail, ZGD->ZGD_GESTOR )
                    aAdd(_aDadEmail, ZGD->ZGD_CODNEG )
                    aAdd(_aDadEmail, ZGD->ZGD_DESNEG )
                    aAdd(_aDadEmail, ZGD->ZGD_CODITE )
                    aAdd(_aDadEmail, ZGD->ZGD_DESCRI )
                    aAdd(_aDadEmail, ZGD->ZGD_OBSERV ) 
                    aAdd(_aDadEmail, "   " ) 
                    aAdd(_aDadEmail, ZGD->ZGD_TOTAL ) 
                    aAdd(_aDadEmail, ZGD->ZGD_CLVL ) 
                    aAdd(_aDadEmail, ZGD->ZGD_FILIAL )                     
                    aAdd(_aEnvMail, _aDadEmail )

                Next _nX 
                If Len(_aEnvMail) > 0 
                    ZNOTIFICA("ND", ZGD->ZGD_CODNEG, _aEnvMail, ZGC->ZGC_USER) //Novo Capex por troca de Data
                EndIf
            End Transaction 
        EndIf
            
            
               

    ElseIf _cTpAprov == "TP" //TROCA PRODUTO

        _nPNewProd := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "C1_PRODUTO"})
        _nPNewDesc := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "B1_DESC"})
        _nPC1OBS    := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "C1_OBS"})
        _nPTPRegP    := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "TPREGP"})
        _nPNqtd    := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "NEWQTD"})
        //ZGD_CONSTR
        For _nX := 1 to Len(oMSNewGe1:aCols)
            If(oMSNewGe1:aCols[_nX][nPRecno] > 0 .AND. oMSNewGe1:aCols[_nX][nPosOk] == "LBOK")
                If Empty(oMSNewGe1:aCols[_nX][_nPTPRegP])
                    Aviso("Definição do novo registro", "Informe se o novo registro trata-se de uma construção ou não.", {"Sair"} , 2 , "Confira os itens e tente novamente!")
                    Return 
                ElseIf Empty(oMSNewGe1:aCols[_nX][_nPNewProd]) .AND. oMSNewGe1:aCols[_nX][_nPTPRegP] <> "S"
                    Aviso("Definição do novo registro", "Informe o novo produto.", {"Sair"} , 2 , "Confira os itens e tente novamente!")
                    Return 
                ElseIf Empty(oMSNewGe1:aCols[_nX][_nPC1OBS]) .AND. oMSNewGe1:aCols[_nX][_nPTPRegP] == "S"
                    Aviso("Definição do novo registro", "Informe a descrição da construção", {"Sair"} , 2 , "Confira os itens e tente novamente!")
                    Return 
                ElseIf oMSNewGe1:aCols[_nX][_nPNqtd] <= 0
                    Aviso("Definição do novo registro", "Informe a quantidade para o novo registro", {"Sair"} , 2 , "Confira os itens e tente novamente!")
                    Return 
                EndIf
                If oMSNewGe1:aCols[_nX][_nPTPRegP] <> "S"
                    DbSelectArea("SB1")
                    SB1->(DbSetOrder(1))
                    SB1->(DbGoTop())
                    If SB1->(DbSeek(_cFilSB1 + oMSNewGe1:aCols[_nX][_nPNewProd]))
                        If SB1->B1_MSBLQL == "1"
                        Aviso("Definição do novo registro", "O produto "+Alltrim(SB1->B1_COD)+" selecionado está bloqueado!", {"Sair"} , 2 , "Confira os itens e tente novamente!")
                        Return 
                        EndIf
                    Else
                        Aviso("Definição do novo registro", "O produto"+oMSNewGe1:aCols[_nX][_nPNewProd]+" não existe no cadastro de produtos!", {"Sair"} , 2 , "Confira os itens e tente novamente!")
                        Return 
                    EndIf
                EndIf
            EndIf
        Next _nX

        DbSelectArea("ZGC")
        ZGC->(DbSetOrder(1))
        
        For _nX := 1 to Len(oMSNewGe1:aCols)
            _aDadEmail := {}
            If(oMSNewGe1:aCols[_nX][nPRecno] > 0 .AND. oMSNewGe1:aCols[_nX][nPosOk] == "LBOK")
                DbSelectArea("ZGD")
                ZGD->(DbSetOrder(1))
                ZGD->(DbGoTo(oMSNewGe1:aCols[_nX][nPRecno]))
                If ZGD->(RECNO()) == oMSNewGe1:aCols[_nX][nPRecno]
                        If Empty(_aFielZGC)
                            _aAllFZGC := FWSX3Util():GetAllFields( "ZGC" , .F. )
                            ZGC->(DbGoTop())
                            If ZGC->(DbSeek( _cFilZGC + ZGD->ZGD_CODKAP  ))   
                                _cRevisa := ZGCREVIS(_cFilZGC, ZGD->ZGD_CODKAP)
                                For _nZ := 1 to Len(_aAllFZGC)
                                    If(!Empty(FwSX3Util():GetFieldType(alltrim(_aAllFZGC[_nZ]))))
                                        If GetSx3Cache(alltrim(_aAllFZGC[_nZ]), "X3_CONTEXT") <> "V"
                                            If Alltrim(_aAllFZGC[_nZ]) == "ZGC_REVISA"
                                                aAdd(_aFielZGC, { Alltrim(_aAllFZGC[_nZ]), _cRevisa  } )
                                            ElseIf Alltrim(_aAllFZGC[_nZ]) == "ZGC_TPCAPX" //Troca de Item
                                                aAdd(_aFielZGC, { Alltrim(_aAllFZGC[_nZ]), "I"  } )
                                            Else
//                                                alert(_aAllFZGC[_nZ])
                                                aAdd(_aFielZGC, { Alltrim(_aAllFZGC[_nZ]), &('ZGC->'+Alltrim(_aAllFZGC[_nZ]) )  } )
                                            EndIf
                                        EndIf
                                    EndIf 
                                Next _nZ                                                
                            EndIf
                        EndIf
                        If !Empty(_aFielZGC) 
                            _aAllFZGD := FWSX3Util():GetAllFields( "ZGD" , .F. )
                            _aFielZGD := {}
                            
                            _cNaoAtual := "ZGD_STAPN1|ZGD_USERN1|ZGD_DTSTN1|ZGD_STAPSP|ZGD_TOTAL|"
                            _cNaoAtual += "ZGD_STAPCA|ZGD_DTSTCA|ZGD_USERCA|ZGD_STAPFC|ZGD_DTSTFC|ZGD_USERFC|"
                            _cNaoAtual += "ZGD_USERSU|ZGD_DTSTSU"

                            For _nZ := 1 to Len(_aAllFZGD)
                                If !Alltrim(_aAllFZGD[_nZ]) $ _cNaoAtual
                                
                                    If(!Empty(FwSX3Util():GetFieldType(alltrim(_aAllFZGD[_nZ]))))
                                        If GetSx3Cache(alltrim(_aAllFZGD[_nZ]), "X3_CONTEXT") <> "V"
                                            If Alltrim(_aAllFZGD[_nZ]) == "ZGD_REVISA"
                                                aAdd(_aFielZGD, { Alltrim(_aAllFZGD[_nZ]), _cRevisa  } )
                                            ElseIf Alltrim(_aAllFZGD[_nZ]) == "ZGD_CODITE" //PRODUTO
                                                aAdd(_aFielZGD, { Alltrim(_aAllFZGD[_nZ]), oMSNewGe1:aCols[_nX][_nPNewProd]  } )

                                            ElseIf Alltrim(_aAllFZGD[_nZ]) == "ZGD_CONSTR" //Tp produto
                                                aAdd(_aFielZGD, { Alltrim(_aAllFZGD[_nZ]), oMSNewGe1:aCols[_nX][_nPTPRegP]  } )

                                            ElseIf Alltrim(_aAllFZGD[_nZ]) == "ZGD_DESCRI" //Descrição
                                                aAdd(_aFielZGD, { Alltrim(_aAllFZGD[_nZ]), oMSNewGe1:aCols[_nX][_nPNewDesc]  } )

                                            ElseIf Alltrim(_aAllFZGD[_nZ]) == "ZGD_QUANT" //Quantidade
                                                aAdd(_aFielZGD, { Alltrim(_aAllFZGD[_nZ]), oMSNewGe1:aCols[_nX][_nPNqtd]  } )

                                            ElseIf Alltrim(_aAllFZGD[_nZ]) == "ZGD_OBSERV" //Observação
                                                aAdd(_aFielZGD, { Alltrim(_aAllFZGD[_nZ]), oMSNewGe1:aCols[_nX][_nPC1OBS]  } )

                                            ElseIf Alltrim(_aAllFZGD[_nZ]) == "ZGD_PRECO" //Observação
                                                _nzgdprc    := U_ZCDZGCPR(oMSNewGe1:aCols[_nX][_nPNewProd] )
                                                If _nzgdprc > 0 
                                                    aAdd(_aFielZGD, { Alltrim(_aAllFZGD[_nZ]), _nzgdprc  } )
                                                    aAdd(_aFielZGD, { "ZGD_TOTAL", Round((_nzgdprc*oMSNewGe1:aCols[_nX][_nPNqtd]),2)  } )
                                                Else
                                                    aAdd(_aFielZGD, { Alltrim(_aAllFZGD[_nZ]), 0  } )
                                                    aAdd(_aFielZGD, { "ZGD_TOTAL", 0  } )
                                                EndIf
                                            Else
                                                aAdd(_aFielZGD, { Alltrim(_aAllFZGD[_nZ]), &('ZGD->'+Alltrim(_aAllFZGD[_nZ]) )  } )
                                            EndIf
                                        EndIf
                                    EndIf
                                EndIf
                            Next _nZ  
                            If Len(_aFielZGD) > 0 
                                aAdd(_aNewZGD, _aFielZGD )
                                aAdd(_aNewCap, oMSNewGe1:aCols[_nX][nPRecno] )
                            EndIf
                        Else
                            MsgStop("Não foi possível criar vetor de transferência dos produtos.","PROBLEMA")
                            Exit
                        EndIf
                EndIf
            EndIf
        Next _nX


        If len(_aNewCap) > 0 .and. Len(_aNewZGD) > 0 .and. Len(_aFielZGC) > 0 
            Begin Transaction
                
                For _nX := 1 to Len(_aNewCap)
                    DbSelectArea("ZGD")
                    ZGD->(DbSetOrder(1))
                    ZGD->(DbGoTo(_aNewCap[_nX]))
                    If ZGD->(RECNO()) == _aNewCap[_nX]
                        If  ZGD->(RecLock("ZGD",.F.))
                                ZGD->ZGD_RESIDU := "P"
                                ZGD->ZGD_REVDES := _cRevisa
                            ZGD->(MsUnlock())
                        EndIf
                    EndIf        
                Next _nX
                //Criando o cabeçalho
                ZGC->(RecLock("ZGC",.T.))
                    For _nX := 1 to Len(_aFielZGC)
                        &('ZGC->'+Alltrim(_aFielZGC[_nX][1])) := _aFielZGC[_nX][2]
                    Next _nX 
                ZGC->(MsUnlock())
                _aDadEmail := {}
                _aEnvMail := {}


                
                For _nX := 1 to Len(_aNewZGD)
                    ZGD->(RecLock("ZGD",.T.))
                        For _nZ := 1 to Len(_aNewZGD[_nX])
                            &('ZGD->'+Alltrim(_aNewZGD[_nX][_nZ][1])) := _aNewZGD[_nX][_nZ][2]
                        Next _nZ 
                    ZGD->(MsUnlock())

                    aAdd(_aDadEmail, ZGC->ZGC_FILIAL )
                    aAdd(_aDadEmail, ZGC->ZGC_CODKAP )
                    aAdd(_aDadEmail, ZGC->ZGC_DESCRI )
                    aAdd(_aDadEmail, ZGD->ZGD_GESTOR )
                    aAdd(_aDadEmail, ZGD->ZGD_CODNEG )
                    aAdd(_aDadEmail, ZGD->ZGD_DESNEG )
                    aAdd(_aDadEmail, ZGD->ZGD_CODITE )
                    aAdd(_aDadEmail, ZGD->ZGD_DESCRI )
                    aAdd(_aDadEmail, ZGD->ZGD_OBSERV ) 
                    aAdd(_aDadEmail, "   " ) 
                    aAdd(_aDadEmail, ZGD->ZGD_TOTAL ) 
                    aAdd(_aDadEmail, ZGD->ZGD_CLVL ) 
                    aAdd(_aDadEmail, ZGD->ZGD_FILIAL )                     
                    aAdd(_aEnvMail, _aDadEmail )

                Next _nX 
                If Len(_aEnvMail) > 0 
                    ZNOTIFICA("NP", ZGD->ZGD_CODNEG, _aEnvMail, ZGC->ZGC_USER) //Novo Capex por troca de produtos
                EndIf
            End Transaction 
        EndIf
        
    EndIf
EndIf

//Atualização da ZGC com o status da ZGC
U_ZZGCSTAT()

ZGC->(DbGoTo(_nRecZGC))

    oMSNewGe1:Refresh()
    oMSNewGe1:oBrowse:Refresh()
    oDlg:Refresh()	
        
    RestArea(_aAreaZGD)
    RestArea(_aArea)
    Close(oDlg)
Return

//Função que retornar a próxima revisão disponível
Static Function ZGCREVIS(_cFil, _cCod)

Local _cRet := "0001"
Local _cFilial := '%'+ValToSql(_cFil)+'%'
Local _cCapex := '%'+ValToSql(_cCod)+'%'
Local _cAlias := GetNextAlias()

Beginsql alias _cAlias
    %noparser%
    SELECT 	ISNULL(MAX(ZGC.ZGC_REVISA),'0001') AS ZGC_REVISA
    FROM 	%table:ZGC% ZGC WITH(NOLOCK)
    WHERE		ZGC.D_E_L_E_T_ = ''
            AND ZGC.ZGC_FILIAL = %exp:_cFilial%
            AND ZGC.ZGC_CODKAP = %exp:_cCapex%
EndSql

If (_cAlias)->(!eof())
    _cRet := (_cAlias)->ZGC_REVISA
EndIf
(_cAlias)->(DbCloseArea())

_cRet := Soma1(_cRet)

Return _cRet 

Static Function GetSX3(cCpo, aExc)
Local aRet		:= {}
Local aArea		:= GetArea()
Local _nX		:= 0
Default aExc	:= {}

	If(!Empty(FwSX3Util():GetFieldType(cCpo)))
		aAdd(aRet, ALLTRIM(FwX3Titulo(cCpo)))		//[01] - X3_TITULO
		aAdd(aRet, GetSx3Cache(cCpo, "X3_CAMPO"))	//[02] - X3_CAMPO
		aAdd(aRet, GetSx3Cache(cCpo, "X3_PICTURE"))	//[03] - X3_PICTURE
		aAdd(aRet, GetSx3Cache(cCpo, "X3_TAMANHO"))	//[04] - X3_TAMANHO
		aAdd(aRet, GetSx3Cache(cCpo, "X3_DECIMAL"))	//[05] - X3_DECIMAL
		aAdd(aRet, GetSx3Cache(cCpo, "X3_VALID"))	//[06] - X3_VALID
		aAdd(aRet, GetSx3Cache(cCpo, "X3_USADO"))	//[07] - X3_USADO
		aAdd(aRet, GetSx3Cache(cCpo, "X3_TIPO"))	//[08] - X3_TIPO
		aAdd(aRet, GetSx3Cache(cCpo, "X3_F3"))		//[09] - X3_F3
		aAdd(aRet, GetSx3Cache(cCpo, "X3_CONTEXT"))	//[10] - X3_CONTEXT
		aAdd(aRet, GetSx3Cache(cCpo, "X3_CBOX"))	//[11] - X3_CBOX
		aAdd(aRet, GetSx3Cache(cCpo, "X3_RELACAO"))	//[12] - X3_RELACAO
	EndIf

	For _nX := 1 to Len(aExc)
		If(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_TITULO")		//[01] - 
			aRet[01] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_CAMPO")		//[02] - 
			aRet[02] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_PICTURE")	//[03] - 
			aRet[03] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_TAMANHO")	//[04] - 
			aRet[04] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_DECIMAL")	//[05] - 
			aRet[05] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_VALID")		//[06] - 
			aRet[06] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_USADO")		//[07] - 
			aRet[07] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_TIPO")		//[08] - 
			aRet[08] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_F3")		//[09] - 
			aRet[09] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_CONTEXT")	//[10] - 
			aRet[10] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_CBOX")		//[11] - 
			aRet[11] := aExc[_nX][02]
		ElseIf(ALLTRIM(UPPER(aExc[_nX][01])) == "X3_RELACAO")	//[12] - 
			aRet[12] := aExc[_nX][02]
		EndIf
	Next _nX




	RestArea(aArea)

Return(aRet)


Static Function zSetField(cCpo, cRetorno)
Local cRet	:= Nil
Local aArea := GetArea()

If(!Empty(FwSX3Util():GetFieldType(cCpo)))
        cRet := GetSx3Cache(cCpo, cRetorno)
EndIf

RestArea(aArea)

Return(cRet)


Static Function zatuBot()

RecDados()

Return 


Static Function _zVisual(_nDia)

Return (.T.)


User Function ZVLDZAI(_nOpc)

Local _lRet := .T.

Return _lRet





/*
Função responsável por validar se deverá avisar o usuário que existem aprovações pendentes
*/
User Function zVldTlZGC(__cUserId)
Local _cQuery	:= ""
Local cNewAlias	:= GetNextAlias()
Local _cNegocios := ""
Local _aDados := {}
Local _nPos := 0 
Local _nX := 0
Local _aRet := {}
Default _cTpAprov := ""

DbSelectArea("ZGE")
ZGE->(DbSetOrder(1))
ZGE->(DbGoTop())

If ZGE->(DbSeek(xFilial("ZGE") + __cUserId + _cTpAprov ))
    While ZGE->(!EOF()) .AND. __cUserId == ZGE->ZGE_USER
        _nPos := aScan( _aDados, { |x| x[1] == ZGE->ZGE_TPAPRO } )
        If _nPos > 0 
            //_cNegocios += ZGE->ZGE_CODNEG+"|"
            _aDados[_nPos][2] += ZGE->ZGE_CODNEG+"|"
        Else
            aAdd(_aDados, { ZGE->ZGE_TPAPRO, ZGE->ZGE_CODNEG+"|"   } )
        EndIf
    ZGE->(DbSkip())
    EndDo
EndIf

For _nX := 1 to Len(_aDados)
	_cNegocios := _aDados[_nX][2]
    _cTpAprov := _aDados[_nX][1]
    
    _cQuery := " " + CRLF
	_cQuery += " SELECT 	ZGD_FILIAL,ZGD_DABERT,ZGD_ANO,ZGD_MES,ZGD_CODNEG,ZGD_DESNEG,ZGD_CODITE,ZGD_DESCRI, ZGD_QUANT, " + CRLF 
    _cQuery += " ZGD_CONSTR,ZGD_PRIORI,ZGD_PRECO,ZGD_TOTAL, ZGD_RHQLDE, ZGD_RHLEGI, R_E_C_N_O_ AS RECZGD " + CRLF
	_cQuery += " FROM		"+RetSqlName("ZGD")+" ZGD WITH(NOLOCK) " + CRLF
	_cQuery += " WHERE		ZGD.D_E_L_E_T_ = '' " + CRLF
	_cQuery += " 		AND ZGD.ZGD_FILIAL = '"+xFilial("ZGD")+"' " + CRLF
    _cQuery += "        AND ZGD.ZGD_CODNEG IN " + FormatIn(_cNegocios,"|") + CRLF


    If _cTpAprov == "N1" //Nivel 1
        _cQuery += "        AND ZGD.ZGD_STAPSP <> 'A' " //Suprimentos
        _cQuery += "        AND ZGD.ZGD_STAPCA <> 'A' " // Liberação Conselho Adm
        _cQuery += "        AND ZGD.ZGD_STAPFC <> 'A' " // Liberação Fluxo de Caixa

    ElseIf _cTpAprov == "SU" //Suprimentos
        _cQuery += "        AND ZGD.ZGD_STAPN1  = 'A' "  // Status N1
        _cQuery += "        AND ZGD.ZGD_STAPCA <> 'A' " // Liberação Conselho Adm
        _cQuery += "        AND ZGD.ZGD_STAPFC <> 'A' " // Liberação Fluxo de Caixa

    ElseIf _cTpAprov == "CO" //Conselho 
        _cQuery += "        AND ZGD.ZGD_STAPN1 = 'A' "  // Status N1
        _cQuery += "        AND ZGD.ZGD_STAPSP = 'A' " //Suprimentos
        _cQuery += "        AND ZGD.ZGD_STAPFC <> 'A' " // Liberação Fluxo de Caixa
    ElseIf _cTpAprov == "FC" //Fluxo de Caixa
        _cQuery += "        AND ZGD.ZGD_STAPN1 = 'A' "  // Status N1
        _cQuery += "        AND ZGD.ZGD_STAPSP = 'A' " //Suprimentos
        _cQuery += "        AND ZGD.ZGD_STAPCA = 'A' " // Liberação Conselho Adm
        _cQuery += "        AND ZGD.ZGD_STAPFC <> 'A' " // Liberação Conselho Adm
    EndIf

    _cQuery += "        AND ZGD.ZGD_CODNEG IN " + FormatIn(_cNegocios,"|") + CRLF

    _cQuery += " ORDER BY ZGD_ANO, ZGD_MES, ZGD_CODITE    "

	If(Select(cNewAlias) <> 0)
		dbSelectArea(cNewAlias)
		dbCloseArea()
	EndIf
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cNewAlias,.T.,.T.)
	

	If !(cNewAlias)->(EOF())
        aAdd(_aRet, { _cTpAprov, _cNegocios } )
    EndIf

	dbSelectArea(cNewAlias)
	dbCloseArea()
Next _nX

Return _aRet


Static Function ZNOTIFICA(_cTpAprov, _cNegocio,_aDadEmail, _cUserOrig, _cUAprov, _lEstSC)
Local _cAlias := ""
Local _aDados := {}
Local _cTpSql := ""
Local _cNegSql := ""
Local _cEmail := ""
Local _nX := 0
Local _cTpAprovD := ""
Local _cEmAprov := "" //Email do usuário que aprovou
Default _cTpAprov := ""
Default _cNegocio := ""
Default _cUserOrig := ""
Default _cUAprov := ""
Default _lEstSC := .F.

_cAlias := GetNextAlias()

//Se Gerou SC, enviarei email para o suprimentos informando que gerou uma SC.
If _cTpAprov == "SC"
    _cTpSql := '%'+ValToSql("SU")+'%'
Else
    _cTpSql := '%'+ValToSql(_cTpAprov)+'%'
EndIf

For _nX := 1 to Len(_aDadEmail)
    //aAdd(_aDados, _aDadEmail[_nX][5] )
    //_cNegSql += _aDadEmail[_nX][5]+"|"
    If _nX == 1
        _cNegSql := "  ZGE_CODNEG IN ('"+_aDadEmail[_nX][5]+"'"
    Else
        _cNegSql += ", '"+_aDadEmail[_nX][5]+"'  "
    EndIf

Next _nX 
    If !Empty(_cNegSql)
        _cNegSql += ")"
    Else
        _cNegSql := "  1 = 1 "
    EndIf
    //_cNegSql := ValToSql(_cNegSql)
//_cNegSql := '%'+ValToSql(_cNegocio)+'%'

If _cTpAprov $ "FI|ES|SC|NP|ND|NF" //FINAL / ESTORNO / SOLIC. COMPRA / NOVO PRODUTO / NOVA DATA / NOVA FILIAL
    
    If _cTpAprov $ "FI|ES"
        _cEmail := Alltrim(UsrRetMail(_cUserOrig))
        If !Empty(_cUAprov) .and. _cTpAprov $ "ES|SC"
            _cEmAprov := ZRETMAPRV(_cUAprov)
            If !Empty(_cEmAprov)
                _cEmail += ";"+Alltrim(UsrRetMail(_cEmAprov))
            EndIf
        EndIf

    ElseIf _cTpAprov $ "SC"
        
        _cQuery := " SELECT DISTINCT ZGE_USER 
        _cQuery += " FROM    "+RetSqlName("ZGE")+" ZGE "
        _cQuery += " WHERE       D_E_L_E_T_ = '' 
        _cQuery += "             AND ZGE_FILIAL = '"+xFilial("ZGE")+"' "
        _cQuery += "             AND ZGE_TPAPRO = '"+IIF(_cTpAprov<>"SC",_cTpAprov,"SU")+"' "
        _cQuery += "             AND "+_cNegSql

        If(Select(_cAlias) <> 0)
            dbSelectArea(_cAlias)
            dbCloseArea()
        EndIf
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

        While (_cAlias)->(!EOF())
                _nX++
                If Empty(_cEmail)
                    _cEmail += Alltrim(UsrRetMail((_cAlias)->ZGE_USER))
                Else
                    _cEmail += ";"+Alltrim(UsrRetMail((_cAlias)->ZGE_USER))
                EndIf
            (_cAlias)->(DbSkip())
        EndDo

        If !Empty(_cUserOrig)
            If !Empty(_cEmail)
                _cEmail += ";"+Alltrim(UsrRetMail(_cUserOrig))
            Else
                _cEmail := Alltrim(UsrRetMail(_cUserOrig))
            Endif
        EndIf
        If !Empty(_cEmail)
          _cEmail += ";"+"patrimonio@masutti.com.br"
        EndIf

        (_cAlias)->(DbCloseArea())



    ElseIf _cTpAprov $ "NP|ND" //Novo Capex por conta do produto / DATA
        
        _cQuery := " SELECT DISTINCT ZGE_USER 
        _cQuery += " FROM    "+RetSqlName("ZGE")+" ZGE "
        _cQuery += " WHERE       D_E_L_E_T_ = '' 
        _cQuery += "             AND ZGE_TPAPRO = 'N1' "
        _cQuery += "             AND ZGE_FILIAL = '"+xFilial("ZGE")+"' "
        _cQuery += "             AND "+_cNegSql

        If(Select(_cAlias) <> 0)
            dbSelectArea(_cAlias)
            dbCloseArea()
        EndIf
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

        While (_cAlias)->(!EOF())
                _nX++
                If Empty(_cEmail)
                    _cEmail += Alltrim(UsrRetMail((_cAlias)->ZGE_USER))
                Else
                    _cEmail += ";"+Alltrim(UsrRetMail((_cAlias)->ZGE_USER))
                EndIf
            (_cAlias)->(DbSkip())
        EndDo

        If !Empty(_cUserOrig)
            If !Empty(_cEmail)
                _cEmail += ";"+Alltrim(UsrRetMail(_cUserOrig))
            Else
                _cEmail := Alltrim(UsrRetMail(_cUserOrig))
            Endif
        EndIf
        If !Empty(_cEmail)
          _cEmail += ";"+"patrimonio@masutti.com.br"
        EndIf

        (_cAlias)->(DbCloseArea())

    EndIf
Else

 
    _cQuery := " SELECT DISTINCT ZGE_USER 
    _cQuery += " FROM    "+RetSqlName("ZGE")+" ZGE "
    _cQuery += " WHERE       ZGE.D_E_L_E_T_ = '' 
    _cQuery += "             AND ZGE_TPAPRO = '"+IIF(_cTpAprov<>"SC",_cTpAprov,"SU")+"' "
    _cQuery += "             AND ZGE_FILIAL = '"+xFilial("ZGE")+"' "
    _cQuery += "             AND "+_cNegSql

	If(Select(_cAlias) <> 0)
		dbSelectArea(_cAlias)
		dbCloseArea()
	EndIf
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

    While (_cAlias)->(!EOF())
            _nX++
            If Empty(_cEmail)
                _cEmail += Alltrim(UsrRetMail((_cAlias)->ZGE_USER))
            Else
                _cEmail += ";"+Alltrim(UsrRetMail((_cAlias)->ZGE_USER))
            EndIf
        (_cAlias)->(DbSkip())
    EndDo

    If !Empty(_cUserOrig)
        If !Empty(_cEmail)
            _cEmail += ";"+Alltrim(UsrRetMail(_cUserOrig))
        Else
            _cEmail := Alltrim(UsrRetMail(_cUserOrig))
        Endif
    EndIf

        If !Empty(_cEmail)
          _cEmail += ";"+"patrimonio@masutti.com.br"
        EndIf

    (_cAlias)->(DbCloseArea())
EndIf

If _cTpAprov == "N1" //Nivel 1
    _cTpAprovD := "Aprovação Nivel 1"
ElseIf _cTpAprov == "SU" //Suprimentos
    _cTpAprovD := "Atualização Valores - Suprimentos"
ElseIf _cTpAprov == "N2" //Nível 2 
    _cTpAprovD := "Aprovação Nível 2"
ElseIf _cTpAprov == "RH" //RH 
    _cTpAprovD := "Gestão de Pessoas / Legislação"
ElseIf _cTpAprov == "CO" //Conselho 
    _cTpAprovD := "Aprovação Conselho"
ElseIf _cTpAprov == "FC" //Fluxo de Caixa
    _cTpAprovD := "Atualização Fluxo de Caixa"
ElseIf _cTpAprov == "FI" //Fluxo de Caixa
    _cTpAprovD := "Aprovação Finalizada"
ElseIf _cTpAprov == "ES" //Estorno para Suprimentos       
    _cTpAprovD := "Estorno para suprimentos"
ElseIf _cTpAprov == "PR" //Patrimônio
    _cTpAprovD := "Validação da Equipe de Patrimônio"
ElseIf _cTpAprov == "SC" .AND. !_lEstSC //Geração de Solicitação de Compras
    _cTpAprovD := "Geração de Solicitação de Compras"
ElseIf _cTpAprov == "SC" .AND. _lEstSC //Geração de Solicitação de Compras
    _cTpAprovD := "Estorno de Solicitação de Compras"  

ElseIf _cTpAprov == "ND"  //Nova data
    _cTpAprovD := "Geração de novo Capex por troca de data"
ElseIf _cTpAprov == "NP"  //Novo produto
    _cTpAprovD := "Geração de novo Capex por troca de Item"

ElseIf _cTpAprov == "NF"  //Nova Filial
    _cTpAprovD := "Geração de novo Capex por troca de Item"
EndIf

If Len(_aDadEmail) > 0 
    ZENVMAIL(_aDadEmail, _cTpAprovD, _cEmail, _cTpAprov == "ES", _cTpAprov == "SC", _lEstSC , _cTpAprov)
EndIf

Return 


Static Function ZRETMAPRV(_cUAprov)

Local _cEmail := ""
Local aUsersAux := {}
Default _cUAprov := ""
aUsersAux := FWSFAllUsers(/*aUserList*/, {"USR_CODIGO","USR_NOME","USR_EMAIL"})

nPos := aScan(aUsersAux, {|aUsr| Upper(AllTrim(aUsr[3])) == Upper(AllTrim(_cUAprov))})

if nPos > 0
	_cEmail := aUsersAux[nPos][5]
else
	_cEmail := ""
endif

aSize(aUsersAux, 0)
aUsersAux := nil

Return _cEmail

Static Function ZENVMAIL(_aDados, _cTpAprov,  _cEmail, _lEstorno, _lGerouSC, _lEstSC ,_cTpAprvM)

Local cHtml     := ""
Local _nX       := 0   
Local cEmail 	:= 	_cEmail
Local _cCopyOc	:= ""
Local _cMailCp := ""

Default _lEstorno := .F.
Default _cTpAprov := ""
Default _lGerouSC := .F.
Default _lEstSC := .F.
               
		cHtml := '<!DOCTYPE html>
		cHtml += '<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br" xml:lang="pt-br">' + CRLF
		cHtml += '	<head>' + CRLF
		cHtml += '		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />' + CRLF
		cHtml += '		<title>' + CRLF
        If !_lEstorno .and. !_lGerouSC
            If _cTpCPX == "C" .or. _cTpCPX == "M"
		        cHtml += '			Atualização Status Capex (COMPLEMENTAR) Masutti - '+IIF(_cTpAprvM=="FI","","Aprovação Pendente")+' ('+_cTpAprov+')' +CRLF
            Else
                cHtml += '			Atualização Status Capex Masutti - '+IIF(_cTpAprvM=="FI","","Aprovação Pendente")+' ('+_cTpAprov+')' +CRLF
            EndIf
        ElseIf _lGerouSC
            If _lEstSC
                cHtml += '			Atualização Status Capex Masutti - Estorno de Solicitação de Compras' +CRLF
            Else
                cHtml += '			Atualização Status Capex Masutti - Geração de Solicitação de Compras' +CRLF
            EndIf
        Else
            If _cTpCPX == "C" .or. _cTpCPX == "M"
		        cHtml += '			Atualização Status Capex (COMPLEMENTAR) Masutti - Estorno de Aprovação p/ Ajuste de valor pelo SUPRIMENTOS' +CRLF
            Else
                cHtml += '			Atualização Status Capex Masutti - Estorno de Aprovação p/ Ajuste de valor pelo SUPRIMENTOS' +CRLF
            EndIf
        EndIf
		cHtml += '		</title>' + CRLF
        //RETIRADO DAQUI A CONFIGURAÇÃO DO CSS
        
		cHtml += '	</head>' + CRLF
		cHtml += '	<body>' + CRLF
		cHtml += '		<div class="container well">' + CRLF
		cHtml += '			<header>' + CRLF
		cHtml += '				<h1 class="titulo principal">' + CRLF
        If !_lEstorno .and. !_lGerouSC
            If _cTpCPX == "C" .or. _cTpCPX == "M"
		        cHtml += '			        Atualização Status Capex (COMPLEMENTAR) Masutti - '+IIF(_cTpAprvM=="FI","","Aprovação Pendente")+' ('+_cTpAprov+')' +CRLF
            Else
                cHtml += '			        Atualização Status Capex Masutti - '+IIF(_cTpAprvM=="FI","","Aprovação Pendente")+' ('+_cTpAprov+')' +CRLF
            EndIf
        ElseIf _lGerouSC
            If _lEstSC
                cHtml += '			Atualização Status Capex Masutti - Estorno de Solicitação de Compras' +CRLF
            Else
                cHtml += '			Atualização Status Capex Masutti - Geração de Solicitação de Compras' +CRLF
            EndIf
        Else
            If _cTpCPX == "C" .or. _cTpCPX == "M"
		        cHtml += '			        Atualização Status Capex (COMPLEMENTAR) Masutti - Estorno de Aprovação p/ Ajuste de valor pelo SUPRIMENTOS' +CRLF
            Else
                cHtml += '			        Atualização Status Capex Masutti - Estorno de Aprovação p/ Ajuste de valor pelo SUPRIMENTOS' +CRLF
            EndIf
        EndIf
		cHtml += '				</h1>' + CRLF
		cHtml += '				<br />' + CRLF
		cHtml += '				<blockquote>' + CRLF
		cHtml += '					<p>' + CRLF
		cHtml += '                      <br>Filial.....: '+Alltrim(_aDados[1][1]) + CRLF
        cHtml += '                      <br>Cod.  Capex: '+Alltrim(_aDados[1][2]) + CRLF
        cHtml += '                      <br>Desc. Capex: '+Alltrim(_aDados[1][3]) + CRLF
        cHtml += '                      <br>Gestor.....: '+Alltrim(_aDados[1][4]) + CRLF
		cHtml += '                      <br><br>' + CRLF
		cHtml += '					</p>' + CRLF 
		cHtml += '				</blockquote>' + CRLF
		cHtml += '			</header>' + CRLF
		cHtml += '				<section>' + CRLF
		cHtml += '					<table class="table" border="1">' + CRLF
		cHtml += '						<thead>' + CRLF
		cHtml += '							<tr class="titulo">' + CRLF
		cHtml += '								<th><h5>Negócio</h5></th>' + CRLF
		cHtml += '								<th><h5>Desc. Negócio</h5></th>' + CRLF			
		cHtml += '								<th><h5>Produto</h5></th>' + CRLF					
		cHtml += '								<th><h5>Desc. Produto</h5></th>' + CRLF		

        If _lGerouSC
            cHtml += '								<th><h5>Num. SC</h5></th>' + CRLF	
            cHtml += '								<th><h5>Observação</h5></th>' + CRLF	
            cHtml += '								<th><h5>Valor Total</h5></th>' + CRLF
            cHtml += '								<th><h5>Projeto</h5></th>' + CRLF
            cHtml += '								<th><h5>Filial de entrega</h5></th>' + CRLF
        Else
            cHtml += '								<th><h5>Observação</h5></th>' + CRLF	
            cHtml += '								<th><h5>Valor Total</h5></th>' + CRLF
            cHtml += '								<th><h5>Projeto</h5></th>' + CRLF            
        EndIf
		cHtml += '							</tr>' + CRLF
		cHtml += '						</thead>' + CRLF
		cHtml += '						<tbody>' + CRLF 
		
            For _nX := 1 to Len(_aDados)
					cHtml += '						<tr>' + CRLF
					cHtml += '							<td align=center><h5>'+Alltrim(_aDados[_nX][5])+'</h5></td>' + CRLF
					cHtml += '							<td align=center><h5>'+Alltrim(_aDados[_nX][6])+'</h5></td>' + CRLF
					cHtml += '							<td align=center><h5>'+Alltrim(_aDados[_nX][7])+'</h5></td>' + CRLF
					cHtml += '							<td align=center><h5>'+Alltrim(_aDados[_nX][8])+'</h5></td>' + CRLF
                    If _lGerouSC                    
                        cHtml += '							<td align=center><h5>'+Alltrim(_aDados[_nX][10])+'</h5></td>' + CRLF
                        cHtml += '							<td align=center><h5>'+Alltrim(_aDados[_nX][9])+'</h5></td>' + CRLF
                        cHtml += '							<td align=center><h5>'+Transform( _aDados[_nX][11], "@E 999,999,999.99" )+'</h5></td>' + CRLF
                        cHtml += '							<td align=center><h5>'+Alltrim(_aDados[_nX][12])+'</h5></td>' + CRLF
                        cHtml += '							<td align=center><h5>'+Alltrim(_aDados[_nX][13])+'</h5></td>' + CRLF //filial de entrega

                    Else
                        cHtml += '							<td align=center><h5>'+Alltrim(_aDados[_nX][9])+'</h5></td>' + CRLF
                        cHtml += '							<td align=center><h5>'+Transform( _aDados[_nX][11], "@E 999,999,999.99" )+'</h5></td>' + CRLF
                        cHtml += '							<td align=center><h5>'+Alltrim(_aDados[_nX][12])+'</h5></td>' + CRLF                        
                    EndIf
					cHtml += '						</tr>' + CRLF			
            Next _nX
		cHtml += '						</tbody>' + CRLF
		cHtml += '					</table>' + CRLF
		cHtml += '				</section>' + CRLF
		cHtml += '			</main>' + CRLF
		cHtml += '          <br><br>' + CRLF
		cHtml += '			<footer class="footer clearfix">' + CRLF
		cHtml += '				<span class="text-muted">' + CRLF
		cHtml += '					Masutti' + CRLF
		cHtml += '				</span>' + CRLF
		cHtml += '				<span class="text-muted pull-right">' + CRLF
		cHtml += '					WorkFlow @ Protheus | 	Atualização Capex | MASUTTI | V1.00' + CRLF
		cHtml += '				</span>' + CRLF
		cHtml += '			</footer>' + CRLF
		cHtml += '		</div>' + CRLF
		cHtml += '	</body>' + CRLF
		cHtml += '</html>' + CRLF

_cMailCp := ""

//cEmail := "wesley@masutti.com.br;andre.claro@acclaro.com.br" //ANDRECCLARO - APAGAR DEPOIS DOS TESTES

        If (_cTpCPX == "C"  .or. _cTpCPX == "M") .and. !_lGerouSC
            If !_lEstorno
                U_GEnvMail( cEmail, "Atual. Status Capex (COMPLEMENTAR) Masutti - "+IIF(_cTpAprvM=="FI","","Aprovação Pendente")+" ("+_cTpAprov+")" ,cHtml , {} , .F. , .T.)
            Else
                U_GEnvMail( cEmail, "Atual. Status Capex  (COMPLEMENTAR) Masutti - Estorno de Aprovação" ,cHtml , {} , .F. , .T.)
            EndIf
        ElseIf _lGerouSC
            If _lEstSC
                U_GEnvMail( cEmail, "Atual. Status Capex  Masutti - Estorno de Solicitação de Compras" ,cHtml , {} , .F. , .T.)
            Else
                U_GEnvMail( cEmail, "Atual. Status Capex  Masutti - Geração de Solicitação de Compras" ,cHtml , {} , .F. , .T.)
            EndIf
        Else
            If !_lEstorno
                U_GEnvMail( cEmail, "Atualização Status Capex Masutti - "+IIF(_cTpAprvM=="FI","","Aprovação Pendente")+" ("+_cTpAprov+")" ,cHtml , {} , .F. , .T.)
            Else
                U_GEnvMail( cEmail, "Atualização Status Capex Masutti - Estorno de Aprovação" ,cHtml , {} , .F. , .T.)
            EndIf        
        EndIf
            

Return(Nil)


User Function ZGDC1PRD()

Local _cProduto := M->C1_PRODUTO
Local _nPB1Desc := aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "B1_DESC"})
Local _lRet := .T.

DbSelectArea("SB1")
SB1->(DbSetOrder(1))
SB1->(DbGoTop())

If SB1->(DbSeek(xFilial("SB1") + _cProduto ))
    If SB1->B1_MSBLQL == "1"
        Alert("Produto bloqueado")
        _lRet := .F.
    Else
        oMSNewGe1:aCols[N][_nPB1Desc] := SB1->B1_DESC
    EndIf
Else
        Alert("Produto não existe")
        _lRet := .F.
EndIf

Return _lRet



User Function ZZGDSC1S()

Local _lRet := .T.
Local _nPosQtd := aScan(aHeader,{|x| Alltrim(x[2]) == "ZGD_QUANT"})
Local nPRecno	:= aScan(aHeader,{|x| Alltrim(x[2]) == "REC_WT"})
Local _cCodigo := '%'+ValToSql(ZGC->ZGC_CODKAP)+'%'
Local _cAlias := GetNextAlias()
Local _nQtdSC := 0
Local _nQtdCap := 0
Local _aArea := GetArea()
Local _aAreaZGD := ZGD->(GetArea())
Local _aAreaZGC := ZGC->(GetArea())

DbSelectArea("ZGD")
ZGD->(DbGoTo(oMSNewGe1:aCols[N][nPRecno]))
If ZGD->(RECNO()) == oMSNewGe1:aCols[N][nPRecno]

    _nQtdCap := oMSNewGe1:aCols[N][_nPosQtd]

    BeginSql alias _cAlias
        %noparser%
        SELECT ISNULL(SUM(SC1.C1_QUANT),0) AS C1_QUANT
        FROM    %table:SC1% SC1 WITH(NOLOCK)
        WHERE       SC1.D_E_L_E_T_ = ''
                AND SC1.C1_FILIAL = %exp:ZGD->ZGD_FILIAL%
                AND SC1.C1_ZCODKAP = %exp:ZGD->ZGD_CODKAP%
                AND SC1.C1_ZITEKAP = %exp:ZGD->ZGD_ITEM%
    EndSql

    If (_cAlias)->(!eof())
        _nQtdSC := (_cAlias)->C1_QUANT
    EndIf
    (_cAlias)->(DbCloseArea())
    
    If _nQtdCap > ZGD->ZGD_QUANT
        Alert("Quantidade informada ("+cValToChar(_nQtdCap)+") maior que quantidade de Capex ("+cValToChar(ZGD->ZGD_QUANT)+")")
        _lRet := .F.
    ElseIf ZGD->ZGD_QUANT <= _nQtdSC
        Alert("Quantidade gerada de SC ("+cValToChar(_nQtdSC)+") maior que quantidade de Capex ("+cValToChar(ZGD->ZGD_QUANT)+")")
        _lRet := .F.        
    EndIf
EndIf

Return _lRet


Static Function ACVLDSC1(_cFilial, _cCodKap, _cItemKap)

Local _nUsado := 0
Local _cAlias := GetNextAlias()
Local _cFilSql := '%'+ValToSql(_cFilial)+'%'
Local _cCodSql := '%'+ValToSql(_cCodKap)+'%'
Local _cIteSql := '%'+ValToSql(_cItemKap)+'%'

BeginSql alias _cAlias
    %noparser%
    SELECT	SUM(SC1.C1_QUANT - (CASE WHEN SC1.C1_RESIDUO = 'S' THEN SC1.C1_QUJE ELSE 0 END)) AS NUSADO
    FROM		%table:SC1% SC1 WITH(NOLOCK)
    WHERE		SC1.D_E_L_E_T_ = ''
            AND (CASE WHEN SC1.C1_ZFILKAP = '' THEN SC1.C1_FILIAL ELSE SC1.C1_ZFILKAP END) = %exp:_cFilSql%
            AND SC1.C1_ZCODKAP =  %exp:_cCodSql%
            AND SC1.C1_ZITEKAP =  %exp:_cIteSql%
            AND SC1.C1_ZCODKAP <> ''
EndSql

If (_cAlias)->(!eof())
    _nUsado := (_cAlias)->NUSADO
EndIf

(_cAlias)->(DbCloseArea())

Return _nUsado



/*TELA DE SELAÇÃO DAS SCs para ESTORNO */



/*
@Autor:         André Claro - andre.claro@acclaro.com.br / 35 99877-5495
@Data:          15/11/2023
@Descrição:     Programa responsável por retornar os recnos para estorno da SC1
*/

Static Function ACRECSC1(_aRecnos)
Local oGroup1
Local oButton2,oButton3
Private aSize		:= {}
Private aPosObj		:= {}
Private aObjects	:= {}
Private aSortGrd	:= {}
Private aCabec		:= {}
Private oMSNewSC1
Private oDlgSC1
Private _aRecSC1 := {}
Private _lMuda := .T.

	aSize := MsAdvSize()
	aAdd(aObjects, {50, 50, .T., .T. })
	aInfo := {aSize[1], aSize[2], aSize[3], aSize[4], 5, 5}
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	DEFINE MSDIALOG oDlgSC1 TITLE "ESTORNO DE SOLICITAÇÃO DE COMPRAS" FROM aSize[7], 0 TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL
		@ 001, 001 GROUP oGroup1 TO 030, aPosObj[1,4] OF oDlgSC1 COLOR 0, 16777215 PIXEL
		fMSNewSC1(_aRecnos)
		@ aPosObj[1,2] -3, 	  aPosObj[1,4] - 084 BUTTON oButton3 PROMPT "Estornar"   SIZE 037, 012 OF oDlgSC1  ACTION MsgRun(OemToAnsi("Processando Registros Selecionados... Aguarde..."),"",{||  _ACRETSC1(), Close(oDlgSC1) }) PIXEL
		@ aPosObj[1,2] -3,    aPosObj[1,4] - 042 BUTTON oButton2 PROMPT "Cancelar"   SIZE 037, 012 OF oDlgSC1  ACTION Close(oDlgSC1) PIXEL
	ACTIVATE MSDIALOG oDlgSC1 CENTERED

Return _aRecSC1


// SELEÇÃO DOS RECNOS A SEREM ESTORNADOS
Static Function _ACRETSC1()

Local _aArea		:= GetArea()
Local _nPosOk		:= aScan(oMSNewSC1:aHeader, {|x| AllTrim(x[2]) == "CHECKBOL"})
Local _nRecSC1 		:= aScan(oMSNewSC1:aHeader, {|x| AllTrim(x[2]) == "REC_ORI"})

Local _nX := 0 
Local _nY := 0

	For _nX := 1 to Len(oMSNewSC1:aCols)
		If(oMSNewSC1:aCols[_nX][_nPosOk] == "LBOK")
			aAdd(_aRecSC1, oMSNewSC1:aCols[_nX][_nRecSC1] )
		EndIf
	Next _nX
    
    oDlgSC1:Refresh()		
    
    RestArea(_aArea)

Return(Nil)


Static Function fMSNewSC1(_aDados)
Local _nX			:= 0
Local _cQuery		:= ""
Local aStru			:= {}
Local aHeaderEx		:= {}
Local aColsEx		:= {}
Local aFieldFill	:= {} 
Local aFields		:= { "C1_FILIAL","C1_EMISSAO", "C1_NUM", "C1_ITEM", "C1_PRODUTO", "C1_DESCRI", "C1_QUANT", "C1_PRECO", "C1_TOTAL"}
Local aAlterFields	:= { }
Local aExc			:= {}

	aAdd(aExc, {"X3_VALID", ".T."})
	aAdd(aHeaderEx, {"","CHECKBOL","@BMP",10,0,,,"C",,"V",,,"mark","V","S"})

	For _nX := 1 to Len(aFields)
		aAdd(aHeaderEx, GetSX3(aFields[_nX], aExc))
	Next _nX

	aAdd(aHeaderEx, {"Recno","REC_ORI","",10,0,NIL,"û", "N",,"V"})

	If(Len(_aDados) == 0)
		aAdd(aFieldFill, "LBNO")
		For _nX := 1 to Len(aFields)
			If(!Empty(FwSX3Util():GetFieldType(aFields[_nX])))
				aAdd(aFieldFill, CriaVar(aFields[_nX]))
			EndIf
		Next _nX
		aAdd(aFieldFill, 0 )
		aAdd(aFieldFill, .F.)
		aAdd(aColsEx, aFieldFill)
	Else
		aColsEx	:= aClone(_aDados)
		_aDados	:= Nil
		_aDados	:= {}
	EndIf

	oMSNewSC1 := MsNewGetDados():New(aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgSC1, aHeaderEx, aColsEx)
	oMSNewSC1:oBrowse:bHeaderClick := {|oMSNewSC1, nCol| OrdenSC1(nCol, Time())}

	oMSNewSC1:oBrowse:bLDblClick   := {|| SelIteSC1()}

	oMSNewSC1:oBrowse:lUseDefaultColors := .T.
	oMSNewSC1:oBrowse:SetBlkBackColor({|| GTDCLRC1(oMSNewSC1:aCols, oMSNewSC1:nAt, oMSNewSC1:aHeader, oMSNewSC1)})

	oMSNewSC1:Refresh()
	oMSNewSC1:oBrowse:Refresh()

	oDlgSC1:Refresh()

Return(Nil)

Static Function GTDCLRC1(aLinha, nLinha, aHeader, oMSNewSC1)
Local nVermelh	:= RGB(128, 255, 000)
Local nPosOk	:= aScan(aHeader,{|x| Alltrim(x[2]) == "CHECKBOL"})
Local nRet     	:= oMSNewSC1:oBrowse:NCLRFOREFOCUS

	If(aLinha[nLinha][nPosOk] == "LBOK")
		nRet := nVermelh
	EndIf

Return(nRet)


Static Function OrdenSC1(nCol, cTime)
Local aCoBrw1	:= oMSNewSC1:aCols
Local nPosOk		:= aScan(oMSNewSC1:aHeader, {|x| AllTrim(x[2]) == "CHECKBOL"})
Local _nX		:= 0
Local cOdem		:= ""

If nCol == 1  
	If _lMuda
		For _nX := 1 to Len(oMSNewSC1:aCols)
			If oMSNewSC1:aCols[_nX][nPosOk] == "LBOK"
				oMSNewSC1:aCols[_nX][nPosOk] := "LBNO"
			Else
				oMSNewSC1:aCols[_nX][nPosOk] := "LBOK"
			EndIf
		Next _nX 
		_lMuda := .F.
		oMSNewSC1:Refresh()			//Atualiza a Getdados
		oMSNewSC1:oBrowse:Refresh()	//Atualiza a Getdados do browse em tela.
		oDlgSC1:Refresh()
	Else
		_lMuda := .T.
	EndIf
Else
	For _nX := 1 to Len(aSortGrd)
		If(aSortGrd[_nX][01] == nCol)
			If(aSortGrd[_nX][02] == Time())
				Return(Nil)
			Else
				cOdem := aSortGrd[_nX][03]
			EndIf
		EndIf
	Next _nX

	If(cOdem == "" .OR. cOdem == "C")
		aAdd(aSortGrd, {nCol, cTime, "D"})
		aCoBrw1 := aSort(aCoBrw1,,,{|x,y| x[nCol] < y[nCol]})
	Else
		aAdd(aSortGrd, {nCol, cTime, "C"})
		aCoBrw1 := aSort(aCoBrw1,,,{|x,y| x[nCol] > y[nCol]})
	EndIf

	oMSNewSC1:setArray(aCoBrw1) 
	oMSNewSC1:oBrowse:Refresh() 
EndIf
Return(Nil)


Static Function SelIteSC1()
Local nPosOk	:= aScan(oMSNewSC1:aHeader, {|x| AllTrim(x[2]) == "CHECKBOL"})
	oMSNewSC1:aCols[oMSNewSC1:nAt][nPosOk] := IIf(oMSNewSC1:aCols[oMSNewSC1:nAt][nPosOk] == "LBOK", "LBNO", "LBOK")
	If(oMSNewSC1:aCols[oMSNewSC1:nAt][nPosOk] == "LBOK")

	EndIf

	oMSNewSC1:Refresh()			//Atualiza a Getdados
	oMSNewSC1:oBrowse:Refresh()	//Atualiza a Getdados do browse em tela.
	oDlgSC1:Refresh()

Return(Nil)
