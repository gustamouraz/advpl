
#include "Protheus.ch"


User Function ACVSLDB2(_lPergunta)
Local _aArea := GetArea()
Local _lRet := .T.
Local _nX := 0
Local _nPProd  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_PRODUTO'})
Local _nPQuant := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_QUANT'})
Local _nPMovEst := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_ZAPLDIR'})
Local _nPUrgent := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_YURGENT'})
Local _aProds := {} //"produto / quantidade"
Local _nPDel := Len(aHeader)
Local _cAlias := ''
Local _cQuery := ''
Local _cFilBkp := cFilAnt
Local _nSaldo := 0 
Local _aSaldos := {}
Local cLocTrf :=  SuperGetMv("MV_XLOCTRF",.F.,'87')

cFilTrf :=  SuperGetMv("MV_XFILTRF",.F.,'')
Default _lPergunta := .T.

If !Empty(cFilTrf)
	cFilTrf := StrTran(cFilTrf, ",", "','")
	cFilTrf := "('"+ cFilTrf + "')"
Endif
cLocTrf := StrTran(cLocTrf, ",", "','")
cLocTrf := "('"+ cLocTrf + "')"



For _nX := 1 to Len(aCols)
    If !aCols[_nX][_nPDel]
        _nPos := aScan(_aProds,{|x| AllTrim(x[1]) == Alltrim(aCols[_nX][_nPProd])})
        If _nPos > 0 
            _aProds[_nPos][2] += aCols[_nX][_nPQuant]
            _aProds[_nPos][3] += aCols[_nX][_nPMovEst]
            _aProds[_nPos][4] += aCols[_nX][_nPUrgent]
        Else
            aAdd(_aProds, {Alltrim(aCols[_nX][_nPProd]),  aCols[_nX][_nPQuant], aCols[_nX][_nPMovEst], aCols[_nX][_nPUrgent]  } )
        EndIf 
    EndIf
Next _nX 

//Até aqui terei um array com todos os produtos e quantidades necessárias:

If Len(_aProds) > 0 
    DbSelectARea("SB2")
    SB2->(DbSetOrder(1))
    For _nX := 1 to Len(_aProds)
        _cQuery := " 
		_cQuery += " SELECT B2_FILIAL, B2_COD, B2_LOCAL "
		_cQuery += " FROM 		"+RetSqlName("SB2")+" SB2 INNER JOIN SYS_COMPANY EMP ON "
		_cQuery += " 			SB2.B2_FILIAL = EMP.M0_CODFIL"
		_cQuery += " 		AND EMP.D_E_L_E_T_ = ''"
		_cQuery += " 		AND EMP.M0_CODIGO = '"+cEmpAnt+"'"
		_cQuery += " WHERE 		SB2.D_E_L_E_T_ = '' "
		_cQuery += " 		AND SB2.B2_COD <> '' "
		_cQuery += " 		AND SB2.B2_COD = '"+_aProds[_nX][1]+"'"
		_cQuery += " 		AND SB2.B2_QATU <> 0 "
		_cQuery += " 		AND SB2.B2_LOCAL <> 95 "
		if !Empty(cFilTrf)
			_cQuery += " 		AND SB2.B2_FILIAL IN " + cFilTrf 
		endif
		_cQuery += " 		AND SB2.B2_LOCAL IN " + cLocTrf 
		_cQuery += " UNION ALL "
		_cQuery += " SELECT ZZF_FILIAL, ZZF_CODPRO, 'ZZ' "
		_cQuery += " FROM 		"+RetSqlName("ZZF")+" ZZF INNER JOIN SYS_COMPANY EMP ON "
		_cQuery += " 			ZZF.ZZF_FILIAL = EMP.M0_CODFIL"
		_cQuery += " 		AND EMP.D_E_L_E_T_ = ''"
		_cQuery += " 		AND EMP.M0_CODIGO = '"+cEmpAnt+"'"
		_cQuery += " WHERE 		ZZF.D_E_L_E_T_ = '' "
		_cQuery += " 		AND ZZF.ZZF_CODPRO <> '' "
		_cQuery += " 		AND ZZF.ZZF_CODPRO = '"+_aProds[_nX][1]+"'"
		if !Empty(cFilTrf)
			_cQuery += " 		AND ZZF.ZZF_FILIAL IN " + cFilTrf 
		endif

        _cAlias := GetNextAlias()
        MpSysOpenQuery(_cQuery, _cAlias)
        While (_cAlias)->(!eof())
            cFilAnt := (_cAlias)->B2_FILIAL
            OpenSm0(cEmpAnt + cFilAnt)
            SB2->(DbGoTop())
            If SB2->(DbSeek((_cAlias)->B2_FILIAL +(_cAlias)->B2_COD + (_cAlias)->B2_LOCAL ))
                If GetMV("MV_TPSALDO") == "C"
                    _nSaldo := SaldoSB2(,,,,,"SB2")
                Else
                    _nSaldo := SB2->(  B2_QATU-B2_QACLASS-B2_RESERVA   )
                EndIf  
                If !(_aProds[_nX][3] = "N" .OR. _aProds[_nX][4] = "S") //Se não movimenta estoque ou quando é urgente 
					If _nSaldo <> 0
                	    aAdd(_aSaldos, {SB2->B2_FILIAL, SB2->B2_COD, SB2->B2_LOCAL, _nSaldo})
                	EndIf
				EndIf
            EndIf            
            If ZZF->(DbSeek((_cAlias)->B2_FILIAL +(_cAlias)->B2_COD ))
            	_nSaldo := ZZF->(ZZF_QUANT)  
            	If !(_aProds[_nX][3] = "N" .OR. _aProds[_nX][4] = "S") //Se não movimenta estoque ou quando é urgente
					If _nSaldo <> 0
            		    aAdd(_aSaldos, {ZZF->ZZF_FILIAL, ZZF->ZZF_CODPRO, 'ZZ', _nSaldo})
            		EndIf
				EndIf
            EndIf

        	(_cAlias)->(DbSkip())
        EndDo
        (_cAlias)->(DbCloseArea())
    Next _nX 

    If Len(_aSaldos) > 0 
    /*
        _cAviso := ""
        For _nX := 1 to len(_aSaldos)
            _cAviso += char(13)+char(10)+"Prod.:" +Alltrim(_aSaldos[_nX][2]) +"Filial: "+_aSaldos[_nX][1] + " Arm.: "+_aSaldos[_nX][3] + " Saldo: "+Transform(_aSaldos[_nX][4], "@E 99,999,999,999.999")
        Next _nX
         _cAviso += char(13)+char(10)+"Verificar a Possibilidade de Transferencia entre filiais antes de realizar a compra!"
        If _lPergunta
            If Aviso("ATENÇÃO","Existem saldos em outras filiais para os produtos: "+_cAviso,{"Revisar","Continuar"}, 2 ) == 1
                _lRet := .F.
            EndIf
        Else
             Aviso("ATENÇÃO","Existem saldos em outras filiais para os produtos: "+_cAviso,{"Continuar"}, 2 ) 
        EndIf 
    */

        _lRet := MostraTela(_aSaldos)       
    EndIf
EndIf

cFilAnt := _cFilBkp
OpenSm0(cEmpAnt + cFilAnt ) 

RestArea(_aArea)

Return _lRet 







//Função para apresentar a tela com o resultado do pco / Necessário ordenar 
Static Function MostraTela(_aDados)

Local oGroup1
Local oSay2, oSay3, oSay4

Private oGet3, oGet4, oGet5,  oGet6, oGet7
Private dGet3		:= Date()
Private dGet4		:= Date()

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
Private _lRet := .F.

Private oButton1, oButton2, oButton3
Private  _cOrdTela1  := ""
Private  _cOrdTela2  := ""

	aSize := MsAdvSize()

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


	aAdd(aObjects, {50, 50, .T., .T. })
	aInfo := {aSize[1], aSize[2], aSize[3], aSize[4], 5, 5}
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	DEFINE MSDIALOG oDlg TITLE "SALDO DISPONÍVEL EM OUTRAS FILIAIS" FROM aSize[7], 0 TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL
		@ 003, 007 GROUP oGroup1 TO 052, aPosObj[1,4] OF oDlg COLOR 0, 16777215 PIXEL

        @ (aPosObj[1,2]) + 010, 015 SAY oSay4 PROMPT "Verificar a Possibilidade de Transferencia entre filiais antes de realizar a compra!"  SIZE 150, 007 OF oDlg COLORS 0, 16777215 PIXEL
        
        oSay4:SetCss(cEstilo1)
        oSay4:Refresh()

        fMSNewGe1(_aDados)
        
        @ aPosObj[1,2] +10   , aPosObj[1,4] - 042 BUTTON oButton2 PROMPT "Revisar"           SIZE 037, 012 OF oDlg ACTION MsgRun(OemToAnsi("Saindo... Aguarde..."),"",{||  oDlg:End()  }) PIXEL
        // @ aPosObj[1,2] +10   , aPosObj[1,4] - 082 BUTTON oButton2 PROMPT "Prosseguir"           SIZE 037, 012 OF oDlg ACTION MsgRun(OemToAnsi("Saindo... Aguarde..."),"",{|| _lRet := .T., oDlg:End()  }) PIXEL
	ACTIVATE MSDIALOG oDlg CENTERED

Return _lRet



Static Function fMSNewGe1(_aDados)
Local _nX			:= 0
Local aHeaderEx		:= {}
Local aColsEx		:= {}
Local aFieldFill	:= {}
Local _cFilSB1 := xFilial("SB1")
Local aFields		:= {  "B2_FILIAL", "B2_COD","B1_DESC", "B2_LOCAL","B2_QATU" }

Local aAlterFields	:= {}
Local aExc			:= {}

	aAdd(aExc, {"X3_VALID", ".T."})
	For _nX := 1 to Len(aFields)
			aAdd(aHeaderEx, GetSX3(aFields[_nX], aExc))
	Next _nX

	If(Len(aCabec) == 0)
		//Define field values
		For _nX := 1 to Len(_aDados)
			aFieldFill := {}
					aAdd(aFieldFill,  Alltrim(_aDados[_nX][1]) ) //filial
                    aAdd(aFieldFill,  Alltrim(_aDados[_nX][2]) ) //Produto
					aAdd(aFieldFill,GetAdvFVal("SB1","B1_DESC",_cFilSB1 + _aDados[_nX][2]))
					aAdd(aFieldFill, Alltrim(_aDados[_nX][3]) )
					aAdd(aFieldFill,_aDados[_nX][4])
					aAdd(aFieldFill, .F. )
			aAdd(aColsEx, aFieldFill)
		Next _nX
	Else
		aColsEx	:= aClone(aCabec)
		aCabec	:= Nil
		aCabec	:= {}
	EndIf

	oMSNewGe1 := MsNewGetDados():New(aPosObj[1,1]+25, aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], /*GD_INSERT+GD_DELETE+GD_UPDATE*/, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
	oMSNewGe1:oBrowse:lUseDefaultColors := .T.
	oMSNewGe1:oBrowse:SetBlkBackColor({|| GETDCLR(oMSNewGe1:aCols, oMSNewGe1:nAt, oMSNewGe1:aHeader, oMSNewGe1)})

	oMSNewGe1:Refresh()
	oMSNewGe1:oBrowse:Refresh()

	oDlg:Refresh()

Return(Nil)

Static Function GETDCLR(aLinha, nLinha, aHeader, oMSNewGe1)
Local nVermelh	:= RGB( 9, 255, 120 )
Local nPosSaldo	:= aScan(aHeader,{|x| Alltrim(x[2]) == "B2_QATU"})
Local nRet     	:= oMSNewGe1:oBrowse:NCLRFOREFOCUS

	If(aLinha[nLinha][nPosSaldo] > 0 )
		nRet := nVermelh
	Else
		nRet := RGB(230,0,0)
	EndIf

Return(nRet)


Static Function SelItens()
Local _nX		:= 0
Local nPosOk	:= aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "CHECKBOL"})
Local nPRecno	:= aScan(oMSNewGe1:aHeader, {|x| AllTrim(x[2]) == "REC_WT"})

	oMSNewGe1:aCols[oMSNewGe1:nAt][nPosOk] := IIf(oMSNewGe1:aCols[oMSNewGe1:nAt][nPosOk] == "LBOK", "LBNO", "LBOK")
	If(oMSNewGe1:aCols[oMSNewGe1:nAt][nPosOk] == "LBOK")
		
	EndIf

	oMSNewGe1:Refresh()			//Atualiza a Getdados
	oMSNewGe1:oBrowse:Refresh()	//Atualiza a Getdados do browse em tela.
	oDlg:Refresh()

Return(Nil)

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

