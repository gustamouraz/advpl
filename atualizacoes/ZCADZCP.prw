#INCLUDE "FileIO.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#Include "Totvs.ch"


//-------------------------------------------------------------------------------------------------------------------------------------------------
/*
@Autor	 		André Claro
@Contatos:		Email: andre.claro@acclaro.com.br / Cel/Whats: 55 35 9 9877-5495 / Skype: andrecclaro
@Data	 		14/08/23
@Versão:		P12.2210
@Descrição:
Programa responsável por gravar os dados da planilha a ser importada e por realizar a importação dos dados.
Programador     Data       Motivo
      
/*/
//-------------------------------------------------------------------------------------------------------------------------------------------------

User Function ZCADZCP() 

	Local cVldAlt := ".F." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
	Local cVldExc := ".F." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
	Local aBotAdc := {}

	Private cString := "ZCP"

	dbSelectArea("ZCP")
	ZCP->(DbSetOrder(1))

	//Adiciona funcao ao menu
	aAdd(aBotAdc,{"Imp Planilha Orcamentaria","u_ImpPlanOrc",0,3})
	aAdd(aBotAdc,{"Exportar Planilha","u_ZExpOrc",0,7})	
	
	AxCadastro(cString,"Dados importação Plan Orcamentaria ",cVldAlt,cVldExc,aBotAdc)

Return

User Function  ImpPlanOrc() 

	Private cArq    	:= Space(200)
	Private lSair   	:= .F.
	Private cNewPlan   	:= Space(15)
	Private cAno  		:= Space(2)
	Private cMes  		:= Space(2)
	Private dDtVenc := StoD("")
	Private oDlg        
	Private _cProc001	:= "Aguarde por favor!!!"            
	
	
	Define MsDialog oDlg Title ("Importar Arquivos") From 0,0 To 260,650 Pixel
		@005,010 To 107,320 Pixel
		@011,020 Say "Escolha a Planilha .CSV" Pixel of oDlg

		@031,020 Say "Arquivo...........:" Pixel of oDlg
		@030,080 MsGet oVar4 Var cArq    Size 215,010 Pixel of oDlg When .F. //Nao Editavel
		@029,300 Button oBtnLoc Prompt "..."       Size 013,013 Pixel Action (LocArq(),lSair:=.T.)   of oDlg
		@052,120 Button oBtnOk  Prompt "&Ok"       Size 030,013 Pixel Action (oDlg:End(),ZImpPlan(cArq)) of oDlg
		@052,180 Button oBtnCan Prompt "&Cancelar" Size 030,013 Pixel Action (lSair:=.T.,oDlg:End()) of oDlg
	Activate MsDialog oDlg Centered Valid lSair

Return
     
Static Function ZImpPlan (_cPath)

Local cProcesso
            
	oProcess := MsNewProcess():New({|| ProImpPla(_cPath, @oProcess)},"Importando registros da planilha!","Aguarde por favor!!!",.F.)
	oProcess:Activate()

Return (Nil) 

Static Function LocArq()

		//Abre tela para selecionar arquivo
	cArq   := cGetFile("Arq.separados p.virgula|*.CSV|","Selecione o diretorio",,,,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)

Return(cArq)

Static Function ProImpPla(_cPath, oProcess)

Local _cBuffer 	:= ""   
Local _aLin   	:= {} 
Local _cErro	:= ""
Local _nLinha	:= 0
Local _nLinImp	:= 0
Local _aPlanil	:= {}
Local _aAgId	:= {} // Array que irá aglutinar os ID com base no período
Local _nX	:= 0
Local _cCodPla	:= ""
Local _cQuery	:= ""
Local _dDataDe	:= STOD("")
Local _dDataAt	:= STOD("") 
Local _cAK2ID	:= "0000"
Local _cIDAK2	:= "" 
Local _nAcumul	:= 0
Local _nCount	:= 0
Local _nTotAK2	:= 0
Local _nLimTran	:= SuperGetMv("MV_PCOLIMI",.T.,9999)
Local _cRevisa	:= ""
Local _cFiliais	:= ""
Local _aFiliais	:= {} 
Local _lAK3OK	:= .F.   
Local nTotReg	:= 0
Local nTotTmp	:= 0
Local _nCntAK2	:= 1
Local _nCntAK3	:= 1  
Local _aParametros := {} 
Local _cTempId := "0001"
Local _CTPORC := ""
Local _cCCBloq := ""
Local _cCOBloq := ""
Local _cLocServ := SuperGetMv("MV_ZSRVPCO",.F.,"IMPPCO\")
Local _cNomeArq := Dtos(Date())+StrTran(Time(),":","")+".csv"
Local _cTabTMP := '#TMP'+Dtos(Date())+StrTran(Time(),":","")
Local _cAlias := ''
Local _aHeader := {}

Local nZCP_FILIAL   := 0
Local nZCP_CO       := 0
Local nZCP_CCUSTO   := 0
Local nZCP_VALOR    := 0
Local nZCP_CODPLA   := 0
Local nZCP_REVISA   := 0
Local nZCP_PERIOD   := 0
Local nZCP_OPER     := 0
Local nZCP_CLASSE   := 0
Local nZCP_CLVL 	:= 0
Local _lFilial := .F.
Local _lRet := .T.
Local _cIdSQL := ''
Local _cValida := ''
Local _nVldTemp := 0 
Local _aFilial := {}
Local _aPlanilhas := {}
Local _lInsert := .T.
Local _cFilAK2 := xFilial("AK2")
Local aAutoItens := {} 
Local aAutoCab := {}

Default _cPath := ""

If !File(_cPath)
  ConOut("erro...")
  Return(Nil)
EndIf

DbSelectArea("ZCP")
ZCP->(DbSetOrder(1))

FT_FUSE(_cPath)  

// Processa Validações
FT_FGOTOP()

DbSelectArea("AK5")
AK5->(DbSetOrder(1)) //Filial + C.O

oProcess:SetRegua1(0)
oProcess:SetRegua2(0)
oProcess:IncRegua1("Validando dados para importação")
oProcess:IncRegua2("Processando arquivo!")

DbSelectArea("AK5")
AK5->(DbSetOrder(1))

DbSelectArea("CTT")
CTT->(DbSetOrder(1))

_cZPCID := Dtos(Date())+StrTran(Time(),":","")+__cUserID
_cIdSQL := '%'+ValToSql(_cZPCID)+'%'


While !FT_FEOF() .and. _lRet
	_cBuffer := AllTrim(FT_FREADLN())
	_aLin   := Separa(_cBuffer,";")
	_nLinha ++

	If _nLinha == 1 
		_aHeader := aClone(_aLin)
		FT_FSKIP()
		Loop
	EndIf

	If ZCP->(RecLock("ZCP",.T.))
		ZCP->ZCP_ID := _cZPCID
		ZCP->ZCP_TEXTO := Alltrim(_cBuffer)
		For _nX := 1 To Len(_aHeader)
			IF FwSX3Util():GetFieldType(Alltrim(_aHeader[_nX])) == "C"
				&( "ZCP->"+	Alltrim(_aHeader[_nX]) ) := Alltrim(_aLin[_nX])
			ElseIf FwSX3Util():GetFieldType(Alltrim(_aHeader[_nX])) == "N"
				&( "ZCP->"+ Alltrim(_aHeader[_nX]) ) := Val(Alltrim(_aLin[_nX]))
			ElseIF FwSX3Util():GetFieldType(Alltrim(_aHeader[_nX])) == "D"
				&( "ZCP->"+ Alltrim(_aHeader[_nX]) ) := cToD(Alltrim(_aLin[_nX]))
			EndIf
		Next _nX
		ZCP->(MsUnlock())
	EndIf

	FT_FSKIP()
EndDo

_cAlias := GetNextAlias()

BeginSql alias _cAlias
	%noparser%
	COLUMN ZCP_PERIOD AS DATE
	SELECT	*
	FROM
	(SELECT	ZCP.*, 
			(CASE 
				WHEN ISNULL(AK5.AK5_CODIGO,'') = '' THEN 'CONTA ORC. NÃO EXISTE / ' 
				WHEN ISNULL(AK5.AK5_MSBLQL,'') = '1' THEN 'CONTA ORC BLOQUEADA / '
				ELSE ''
			END) +
			(CASE 
				WHEN ISNULL(CTT.CTT_CUSTO,'') = '' THEN 'C. CUSTO NÃO EXISTE / ' 
				WHEN ISNULL(CTT.CTT_BLOQ,'') = '1' THEN 'C. CUSTO BLOQUEADO / '
				ELSE ''
			END) +
			(CASE 
				WHEN ISNULL(CTH.CTH_CLVL,'') = '' AND ZCP.ZCP_CLVL <> '' THEN 'CL. VALOR NÃO EXISTE / ' 
				WHEN ISNULL(CTH.CTH_BLOQ,'') = '1' THEN 'CL. VALOR BLOQUEADA / '
				ELSE ''
			END) +
			(CASE 
				WHEN ISNULL(AK6.AK6_CODIGO,'') = '' THEN 'CLASSE ORC NÃO EXISTE / ' 
				ELSE ''
			END) +
			(CASE 
				WHEN ISNULL(AKF.AKF_CODIGO,'') = '' AND ZCP.ZCP_OPER <> '' THEN 'OPERACAO NÃO EXISTE / ' 
				ELSE ''
			END) +
			(CASE 
				WHEN ISNULL(AK1.AK1_CODIGO,'') <> '' THEN 'PLANILHA' + ZCP.ZCP_CODPLA+'-'+ZCP.ZCP_REVISA+' JÁ EXISTE / ' 
				ELSE ''
			END) AS VALIDA_ENTIDADES
	FROM 		ZCP010 ZCP  WITH(NOLOCK)
				LEFT OUTER JOIN AK5010 AK5 WITH(NOLOCK) ON
				AK5.AK5_FILIAL = %exp:xFilial("AK5")%
			AND AK5.AK5_CODIGO = ZCP.ZCP_CO
			AND AK5.D_E_L_E_T_ = '' 
				LEFT OUTER JOIN CTT010 CTT WITH(NOLOCK) ON
				CTT.CTT_FILIAL = ''
			AND CTT.CTT_CUSTO = ZCP.ZCP_CCUSTO
			AND CTT.D_E_L_E_T_ = ''
				LEFT OUTER JOIN CTH010 CTH WITH(NOLOCK) ON
				ZCP.ZCP_CLVL = CTH.CTH_CLVL
			AND CTH.D_E_L_E_T_ = ''
			AND CTH.CTH_FILIAL = ''
				LEFT OUTER JOIN AK6010 AK6 WITH(NOLOCK) ON
				AK6.AK6_FILIAL = ''
			AND AK6.AK6_CODIGO = ZCP.ZCP_CLASSE
			AND AK6.D_E_L_E_T_ = '' 	
				LEFT OUTER JOIN AKF010 AKF WITH(NOLOCK) ON
				AKF.AKF_FILIAL = %exp:xFilial("AKF")%
			AND AKF.AKF_CODIGO = ZCP.ZCP_OPER
			AND AKF.D_E_L_E_T_ = '' 
				LEFT OUTER JOIN AK1010 AK1 ON
				AK1.AK1_FILIAL = ZCP.ZCP_FILIAL
			AND AK1.AK1_CODIGO = ZCP.ZCP_CODPLA
			AND AK1.AK1_VERSAO = ZCP.ZCP_REVISA
			AND AK1.D_E_L_E_T_ = ''				
	WHERE 		ZCP.D_E_L_E_T_ = ''
			AND ZCP.ZCP_ID = %exp:_cIdSQL%
	) AS REL
EndSql

If (_cAlias)->(!eof())
	_cTPORC :=  (_cAlias)->ZCP_ZTPORC
	While (_cAlias)->(!eof())
		_nTotAK2 ++ //Quantidade de registrs que serão importados
		_nVldTemp :=  aScan(_aFiliais, Alltrim((_cAlias)->ZCP_FILIAL) )
		If _nVldTemp == 0
			aAdd(_aFiliais, Alltrim((_cAlias)->ZCP_FILIAL)) //Adiciono as filiais... teoricamente, só poderá ter uma! 
		EndIf

		_nVldTemp :=  aScan(_aPlanilhas, Alltrim((_cAlias)->ZCP_CODPLA) + Alltrim((_cAlias)->ZCP_REVISA) )
		If _nVldTemp = 0
			aAdd(_aPlanilhas, Alltrim((_cAlias)->ZCP_CODPLA) + Alltrim((_cAlias)->ZCP_REVISA) ) //Adiciono as planilhas... teoricamente só poderá ter 1 também.
		EndIf
		If !Empty(Alltrim((_cAlias)->VALIDA_ENTIDADES))
			_cValida += 'CO: '+(_cAlias)->ZCP_CO+ '| CLASSE: '+(_cAlias)->ZCP_CO+ '| CC: '+(_cAlias)->ZCP_CCUSTO;
					+ '| OPER: '+(_cAlias)->ZCP_OPER+ '| CL. VALOR: '+(_cAlias)->ZCP_CLVL;
					+ '| PLANILHA: '+(_cAlias)->ZCP_CODPLA+'| '+ (_cAlias)->VALIDA_ENTIDADES +CHAR(13)+CHAR(10)
		EndIf

		If Empty(_dDataDe)
			_cCodPla := (_cAlias)->ZCP_CODPLA
			_dDataDe	:= FirstDate( (_cAlias)->ZCP_PERIOD )
		ElseIf _dDataDe > FirstDate((_cAlias)->ZCP_PERIOD)
			_dDataDe := FirstDate((_cAlias)->ZCP_PERIOD)
		EndIf

		If Empty(_dDataAt)
			_dDataAt := LastDate( (_cAlias)->ZCP_PERIOD )
		ElseIf _dDataAt < LastDate( (_cAlias)->ZCP_PERIOD )
			_dDataAt := LastDate( (_cAlias)->ZCP_PERIOD )
		EndIf

	(_cAlias)->(DbSkip())
	EndDo
	If !Empty(_cValida)
		If Aviso("Itens com problemas de validação", _cValida, {"Sair","Visual TXT"} , 2 , "Algumas linhas da planilha apresentaram problemas de validação nas entidades.") == 2
			MAKEDIR( "C:\Temp")
			MemoWrite("C:\Temp\VALIDA"+_cZPCID+".txt",_cValida )
			shellExecute("Open", "notepad", "C:\Temp\VALIDA"+_cZPCID+".txt", "C:\Temp", 1 )
		Endif
		Return 
	ElseIf Len(_aPlanilhas) > 1 
		Aviso("Foram informadas mais de uma planilha no arquivo de importação.", "Apenas uma planilha deverá ser importada por aquivo.", {"Sair"} , 2 , "Revise o arquivo .csv e tenta novamente.")
		Return 
	ElseIf Len(_aFiliais) > 1 
		Aviso("Foram informadas mais de uma filial no arquivo de importação.", "Apenas uma filial deverá ser importada por aquivo.", {"Sair"} , 2 , "Revise o arquivo .csv e tenta novamente.")
		Return 		
	EndIf
EndIf

If Empty(_aFiliais)
	Alert("Não foram importados registros!")
	Return 
ElseIf _aFiliais[1] <> cFilAnt
	cFilAnt := _aFiliais[1]
	OpenSm0(cEmpAnt + cFilAnt)
EndIf
(_cAlias)->(DbGoTop())

(_cAlias)->(DbCloseArea())

If _nTotAK2 > 0 //Se existem registros para serem importados e passou pelas validações acima, faço a inclusão da SN1 /N2/ N3 e depois AKD

	//inclusão da AK1
	_cQuery := ''
	_cQuery += " INSERT INTO AK1010 (AK1_FILIAL, AK1_CODIGO, AK1_VERSAO, AK1_DESCRI, AK1_NMAX, AK1_TPPERI, AK1_INIPER, AK1_FIMPER, AK1_TPREV, AK1_STATUS, 
	_cQuery += " AK1_CTRUSR, AK1_FASE, AK1_ZTPORC, R_E_C_N_O_)
	_cQuery += " SELECT TOP 1 ZCP.ZCP_FILIAL AS AK1_FILIAL, ZCP.ZCP_CODPLA AS AK1_CODIGO, ZCP.ZCP_REVISA AS AK1_VERSAO, 
	_cQuery += " 		'ORC: '+ZCP.ZCP_CODPLA AS AK1_DESCRI, 
	_cQuery += " 		8 AS AK1_NMAX, '3'AK1_TPPERI, 
	_cQuery += " 		MIN(ZCP_PERIOD) AS AK1_INIPER, 
	_cQuery += " 		Substring(replace(MAX(eomonth(ZCP_PERIOD)),'-',''),1,8) AS AK1_FIMPER, 
	_cQuery += " 		'1' AK1_TPREV, '1' AS AK1_STATUS, '2' AS AK1_CTRUSR, '001' AS AK1_FASE, 
	_cQuery += " 		MAX(ZCP.ZCP_ZTPORC) AS  AK1_ZTPORC,
	_cQuery += " ROW_NUMBER() OVER(ORDER BY ZCP_FILIAL, ZCP_CODPLA, ZCP_REVISA) +(SELECT MAX(R_E_C_N_O_) FROM AK1010) AS R_E_C_N_O_
	_cQuery += " FROM		ZCP010 ZCP
	_cQuery += " WHERE		ZCP.D_E_L_E_T_ = '' AND ZCP.ZCP_FILIAL = '"+cFilAnt+"' "
	_cQuery += " 		AND ZCP.ZCP_ID = '"+_cZPCID+"'
	_cQuery += " GROUP BY 	ZCP.ZCP_FILIAL, ZCP.ZCP_CODPLA, ZCP.ZCP_REVISA, 'ORC: '+ZCP.ZCP_CODPLA  "

	If !ZEXECQRY(_cQuery)
		_lInsert := .F.
	EndIf


		If _lInsert

		_cQuery := " "
		_cQuery += " WITH ESTR_AK3 (FILIAL, CONTA, DESCRICAO, TIPO, NIVEL, CTASUPER) AS   
		_cQuery += "   (  
		_cQuery += " 	SELECT 	'"+cFilAnt+"' AS NIVEL, AK5.AK5_CODIGO AS CONTA, AK5.AK5_DESCRI AS DESCRICAO, AK5.AK5_TIPO AS TIPO, 2 AS NIVEL, AK5.AK5_COSUP AS CTASUPER
		_cQuery += " 	FROM		AK5010 AK5 
		_cQuery += " 	WHERE		AK5.D_E_L_E_T_ = ''
		_cQuery += " 			AND AK5.AK5_TIPO = '1'
		_cQuery += " 			AND AK5.AK5_FILIAL = '"+xFilial("AK5")+"' "
		_cQuery += " 			AND SUBSTRING(AK5.AK5_CODIGO,1,1) IN (SELECT DISTINCT SUBSTRING(ZCP_CO,1,1) AS CONTA FROM ZCP010 ZCP WHERE D_E_L_E_T_ = '' AND ZCP.ZCP_ID = '"+_cZPCID+"' AND ZCP.ZCP_FILIAL = '"+cFilAnt+"' ) "
		_cQuery += "      UNION ALL  
		_cQuery += " 	SELECT 	'"+cFilAnt+"' AS FILIAL, AK5.AK5_CODIGO AS CONTA, AK5.AK5_DESCRI AS DESCRICAO, AK5.AK5_TIPO AS TIPO, NIVEL+1, AK5.AK5_COSUP AS CTASUPER
		_cQuery += " 	FROM		AK5010 AK5 INNER JOIN ZCP010 ZCP ON
		_cQuery += " 				AK5.AK5_FILIAL = '"+xFilial("AK5")+"' "
		_cQuery += " 			AND ZCP.ZCP_CO = AK5.AK5_CODIGO
		_cQuery += " 			AND ZCP.D_E_L_E_T_ = ''
		_cQuery += " 				INNER JOIN ESTR_AK3 AS AK3 ON
		_cQuery += " 				AK3.CONTA = AK5.AK5_COSUP
		_cQuery += " 			AND AK5.AK5_COSUP <> ''
		_cQuery += " 	WHERE		AK5.D_E_L_E_T_ = ''
		_cQuery += " 			AND ZCP.ZCP_ID = '"+_cZPCID+"' AND ZCP.ZCP_FILIAL = '"+cFilAnt+"' "
		_cQuery += "   )  
		_cQuery += " INSERT INTO AK3010 (AK3_FILIAL, AK3_ORCAME, AK3_VERSAO, AK3_CO, AK3_PAI, AK3_TIPO, AK3_NIVEL, AK3_DESCRI, R_E_C_N_O_)
		_cQuery += " SELECT AK3_FILIAL, AK3_ORCAME, AK3_VERSAO, AK3_CO, AK3_PAI, AK3_TIPO, AK3_NIVEL, AK3_DESCRI,
		_cQuery += " 		ROW_NUMBER() OVER(ORDER BY TEMP.ORDEM) + (SELECT MAX(R_E_C_N_O_) FROM AK3010) AS R_E_C_N_O_
		_cQuery += " FROM (  
		_cQuery += " 		SELECT	REL.AK3_FILIAL, REL.AK3_ORCAME, REL.AK3_VERSAO, REL.AK3_CO, 
		_cQuery += " 				REL.AK3_PAI, REL.AK3_TIPO, 
		_cQuery += " 				RIGHT('000'+RTRIM(CAST( (CASE 
		_cQuery += " 							WHEN REL.AK3_PAI = '' THEN '001'
		_cQuery += " 							WHEN REL.AK3_PAI = REL.AK3_ORCAME THEN '002'
		_cQuery += " 							ELSE LEN(RTRIM(REL.AK3_PAI))+2
		_cQuery += " 						END) AS CHAR(3) )),3) AS AK3_NIVEL, 
		_cQuery += " 				REL.AK3_DESCRI,
		_cQuery += " 				(CASE 
		_cQuery += " 					WHEN AK3_PAI = '' THEN '000001'
		_cQuery += " 					WHEN AK3_PAI = AK3_ORCAME THEN '000002'
		_cQuery += " 					ELSE AK3_CO
		_cQuery += " 				END) AS ORDEM
		_cQuery += " 		FROM
		_cQuery += " 	  	(SELECT AK3.FILIAL AS AK3_FILIAL, ZCP.ZCP_CODPLA AS AK3_ORCAME, ZCP.ZCP_REVISA AS AK3_VERSAO,
		_cQuery += " 	  			AK3.CONTA AS AK3_CO, (CASE WHEN AK3.CTASUPER = '' THEN ZCP.ZCP_CODPLA ELSE AK3.CTASUPER END) AS AK3_PAI,
		_cQuery += " 	  			0 AS AK3_NIVEL, '1' AS AK3_TIPO,
		_cQuery += " 	  			AK3.DESCRICAO AS AK3_DESCRI
		_cQuery += " 	  	FROM	(SELECT DISTINCT * FROM ESTR_AK3 WHERE TIPO = '1' ) AK3 INNER JOIN (SELECT TOP 1 * FROM ZCP010 ZCP WHERE ZCP.D_E_L_E_T_ = '' AND ZCP.ZCP_ID = '"+_cZPCID+"' AND ZCP.ZCP_FILIAL = '"+cFilAnt+"' ) AS ZCP ON "
		_cQuery += " 	  			ZCP.ZCP_FILIAL = AK3.FILIAL
		_cQuery += " 	  	UNION
		_cQuery += " 		SELECT 	ZCP.ZCP_FILIAL AS AK3_FILIAL, ZCP.ZCP_CODPLA AS AK3_ORCAME, ZCP.ZCP_REVISA AS AK3_VERSAO,
		_cQuery += " 	  			AK5.AK5_CODIGO AS AK3_CO, AK5.AK5_COSUP AS AK3_PAI,
		_cQuery += " 	  			0 AS AK3_NIVEL, AK5.AK5_TIPO,
		_cQuery += " 	  			AK5.AK5_DESCRI
		_cQuery += " 		FROM		AK5010 AK5 INNER JOIN ZCP010 ZCP ON
		_cQuery += " 					AK5.AK5_FILIAL = '"+xFilial("AK5")+"' "
		_cQuery += " 				AND ZCP.ZCP_CO = AK5.AK5_CODIGO
		_cQuery += " 				AND ZCP.D_E_L_E_T_ = ''
		_cQuery += " 		WHERE		AK5.D_E_L_E_T_ = ''
		_cQuery += " 				AND ZCP.ZCP_ID = '"+_cZPCID+"'  AND ZCP.ZCP_FILIAL = '"+cFilAnt+"' ) AS REL "
		_cQuery += " 		UNION
		_cQuery += "   		SELECT 	ZCP.ZCP_FILIAL AS AK3_FILIAL, ZCP.ZCP_CODPLA AS AK3_ORCAME, ZCP.ZCP_REVISA AS AK3_VERSAO, 
		_cQuery += " 				ZCP.ZCP_CODPLA AS AK3_CO, 
		_cQuery += " 				'' AS AK3_PAI, '' AS AK3_TIPO, '001' AS AK3_NIVEL,
		_cQuery += " 				'ORC: '+ZCP.ZCP_CODPLA  AS AK3_DESCRI, '000001' AS ORDEM
		_cQuery += " 		FROM		ZCP010 ZCP
		_cQuery += " 		WHERE		ZCP.D_E_L_E_T_ = ''
		_cQuery += " 				AND ZCP.ZCP_ID = '"+_cZPCID+"' AND ZCP.ZCP_FILIAL = '"+cFilAnt+"' "
		_cQuery += " 		GROUP BY 	ZCP.ZCP_FILIAL, ZCP.ZCP_CODPLA, ZCP.ZCP_REVISA, 'ORC: '+ZCP.ZCP_CODPLA		
		_cQuery += " ) AS TEMP ORDER BY TEMP.ORDEM

		MemoWrite("C:\Temp\ZCADZCP.SQL", _cQuery)
			If !ZEXECQRY(_cQuery)
				_lInsert := .F.
			EndIf
			
			//inclusão da ak2
			If _lInsert
				_cAlias := GetNextAlias()

				_dDataDe := FirstDate(_dDataDe)
				_dDataAt := LastDate(_dDataAt)  
				_dDtTemp := _dDataDe
				_aPeriodos := {}

				If _dDtTemp < _dDataAt
					aAdd( _aPeriodos , { "P01", SubStr(DtoS(_dDtTemp),1,6) } )
					_nPer := 1 
					_dDtTemp := LastDate(_dDtTemp)+1
					While _dDtTemp < _dDataAt
						_nPer ++
						aAdd( _aPeriodos , { "P"+STRZERO( _nPer , 2 ), SubStr(DtoS(_dDtTemp),1,6)  } )
						_dDtTemp := LastDate(_dDtTemp)+1
					EndDo
				EndIf

				_cQuery := "  "
				_cQuery += " 			SELECT	ZCP_CODPLA, ZCP_REVISA, ZCP_CO, ZCP_CCUSTO, ZCP_CLASSE, ZCP_CLVL, ZCP_OPER, ZCP_MOEDA, ZCP_DESCRI
				For _nX := 1 to Len(_aPeriodos)
					_cQuery += " 				,	["+_aPeriodos[_nX][1]+"] AS "+_aPeriodos[_nX][1]+" "
				Next _nX

				//_cQuery += " 					[P01] AS P01,[P02] AS P02 ,[P03] AS P03 ,[P04] AS P04,[P05] AS P05,[P06] AS P06,
				//_cQuery += " 					[P07] AS P07,[P08] AS P08 ,[P09] AS P09 , [P10] AS P10,[P11] AS P11, [P12] AS P12
				_cQuery += " 			FROM	   ( 


				_cQuery += " 							SELECT ZCP_CODPLA, ZCP_REVISA, ZCP_CO, ZCP_CCUSTO, ZCP_CLASSE, ZCP_CLVL, ZCP_OPER, ZCP_MOEDA, ZCP_DESCRI, 
//				_cQuery += " 									'P'+RIGHT('00'+RTRIM(CAST(PER AS CHAR(2))),2) AS PERIODO,


				_cQuery += " 		(CASE 

				For _nX := 1 to Len(_aPeriodos)
					_cQuery += " 				WHEN PERIODO = '"+_aPeriodos[_nX][2]+"' THEN '"+_aPeriodos[_nX][1]+"' 
				Next _nX

				_cQuery += " 		ELSE '' END) AS PERIODO,


				_cQuery += " 									ZCP_VALOR
				_cQuery += " 							FROM
				_cQuery += " 							(SELECT  *, ROW_NUMBER() OVER (PARTITION BY ZCP_CODPLA, ZCP_REVISA, ZCP_CO, ZCP_CCUSTO, ZCP_CLASSE, ZCP_CLVL, ZCP_OPER, ZCP_MOEDA ORDER BY 
				_cQuery += " 									ZCP_CODPLA, ZCP_REVISA, ZCP_CO, ZCP_CCUSTO, ZCP_CLASSE, ZCP_CLVL, ZCP_OPER, ZCP_MOEDA, PERIODO  ) AS PER
				_cQuery += " 							FROM
				_cQuery += " 							(SELECT 	ZCP.ZCP_CODPLA, ZCP.ZCP_REVISA, ZCP.ZCP_CO, ZCP.ZCP_CCUSTO, ZCP.ZCP_CLASSE, ZCP.ZCP_CLVL, 
				_cQuery += " 									ZCP.ZCP_OPER, ZCP.ZCP_MOEDA, ZCP_DESCRI, 
				_cQuery += " 									SUBSTRING(ZCP.ZCP_PERIOD,1,6) PERIODO, 
				_cQuery += " 									SUM(ZCP.ZCP_VALOR) AS ZCP_VALOR
				_cQuery += " 							FROM 	"+RetSqlName("ZCP")+" ZCP 
				_cQuery += " 							WHERE 	ZCP.D_E_L_E_T_ = ''
				_cQuery += " 								AND ZCP.ZCP_ID = '"+_cZPCID+"' AND ZCP.ZCP_FILIAL = '"+cFilAnt+"' "
				_cQuery += " 							GROUP BY ZCP.ZCP_CODPLA, ZCP.ZCP_REVISA, ZCP.ZCP_CO, ZCP.ZCP_CCUSTO, ZCP.ZCP_CLASSE, ZCP.ZCP_CLVL, 
				_cQuery += " 									ZCP.ZCP_OPER, ZCP.ZCP_MOEDA,  SUBSTRING(ZCP.ZCP_PERIOD,1,6), ZCP.ZCP_DESCRI
				_cQuery += " 							) AS BASE
				_cQuery += " 							) AS ZCP
				

				_cQuery += " 			) AS ZCP
				_cQuery += " 			PIVOT 
				_cQuery += " 			(
				_cQuery += " 			SUM(ZCP.ZCP_VALOR)
				//_cQuery += " 			FOR ZCP.PERIODO IN (   [P01],[P02],[P03],[P04],[P05],[P06],[P07],[P08],[P09],[P10],[P11],[P12]  )
				_cQuery += " 			FOR ZCP.PERIODO IN (   
				For _nX := 1 to Len(_aPeriodos)
					If _nX == 1 
						_cQuery += " 					["+_aPeriodos[_nX][1]+"] 
					ElseIf _nX == Len(_aPeriodos)
						_cQuery += " 				,	["+_aPeriodos[_nX][1]+"] )
					Else
						_cQuery += " 				,	["+_aPeriodos[_nX][1]+"]  " 
					EndIf
					
				Next _nX

				_cQuery += " 			) AS PIVOT_TABLE;

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)
				
				If (_cAlias)->(!Eof())
					_cValida := ''
					While (_cAlias)->(!Eof())
						aAutoCab := {}
						aAutoItens := {}
						
						aAutoCab := { ;
							{"AK2_ORCAME", (_cAlias)->ZCP_CODPLA , nil},;
							{"AK2_VERSAO", (_cAlias)->ZCP_REVISA , nil},;
							{"AK2_CO" , (_cAlias)->ZCP_CO , nil}; 
							}

						_aDadTemp := {}

						aAdd(_aDadTemp, 	{'AK2_ORCAME' , (_cAlias)->ZCP_CODPLA , NIL}   )
						aAdd(_aDadTemp, 	{'AK2_VERSAO' ,(_cAlias)->ZCP_REVISA , NIL}    )
						aAdd(_aDadTemp, 	{'AK2_CO' ,(_cAlias)->ZCP_CO , NIL}            )
						aAdd(_aDadTemp, 	{'AK2_ID' ,'*', NIL} ) //para inclusão de novo item da planilha deve ser passado no conteúdo "*" e nao deve ser utilizado LINPOS
						aAdd(_aDadTemp, 	{'AK2_CLASSE' ,(_cAlias)->ZCP_CLASSE , NIL} )
						aAdd(_aDadTemp, 	{'AK2_CC' ,(_cAlias)->ZCP_CCUSTO , NIL} )
						aAdd(_aDadTemp, 	{'AK2_MOEDA' ,(_cAlias)->ZCP_MOEDA , NIL} )
						aAdd(_aDadTemp, 	{'AK2_DESCRI' ,(_cAlias)->ZCP_DESCRI , NIL} )
						aAdd(_aDadTemp, 	{'AK2_CLVLR' ,(_cAlias)->ZCP_CLVL , NIL} )
						aAdd(_aDadTemp, 	{'AK2_OPER' ,(_cAlias)->ZCP_OPER , NIL} )
						
						For _nX := 1 to Len(_aPeriodos)
							aAdd(_aDadTemp, 	{_aPeriodos[_nX][1] ,  &("(_cAlias)->"+_aPeriodos[_nX][1]) , NIL} )
						Next _nX						

						aAdd(aAutoItens, _aDadTemp )

						If !ACADDAK2(aAutoCab, aAutoItens)
							_cValida +=  "Planilha: "+ (_cAlias)->ZCP_CODPLA;
										+"Versão" + (_cAlias)->ZCP_REVISA;
										+"CO "+ (_cAlias)->ZCP_CO ;
										+"CLASSE"+ (_cAlias)->ZCP_CLASSE;
										+"AK2_CC" +(_cAlias)->ZCP_CCUSTO;
										+"CLVL" +(_cAlias)->ZCP_CLVL;
										+"AK2_OPER" +(_cAlias)->ZCP_OPER
						EndIf
					
					(_cAlias)->(DbSkip())
					EndDo
					If !Empty(_cValida)
						If Aviso("Problema na inclusão dos itens da planilha", _cValida, {"Sair","Visual TXT"} , 2 , "Algumas linhas da planilha apresentaram problemas na inclusão dos itens.") == 2
							MAKEDIR( "C:\Temp")
							MemoWrite("C:\Temp\VALIDA_itens"+_cZPCID+".txt",_cValida )
							shellExecute("Open", "notepad", "C:\Temp\VALIDA_itens"+_cZPCID+".txt", "C:\Temp", 1 )
						Endif
					EndIf
				Return 

				EndIf

			EndIf


		EndIf


	If !_lInsert
		Aviso("ATENÇÃO","NÃO FOI POSSÍVEL INCLUIR A PLANILHA ORÇAMENTÁRIA",{"OK"},2)
		Return 
	EndIf
EndIf

Aviso("ATENÇÃO","PLANILHA INCLUÍDA COM SUCESSO!",{"OK"},2)

Return 





User Function ZExcOrc ()

Local cProcesso
Private _cProc001	:= "Aguarde por favor!!!" 

	oProcess := MsNewProcess():New({|| ZSExcOrc(@oProcess)},"Excluindo registros da planilha!",_cProc001,.F.)
	oProcess:Activate()

Return (Nil) 

Static Function ZSExcOrc

Local _cChave	:= ZCP->(ZCP_FILIAL+ZCP_CODPLA)
Local _cCodPla	:= Alltrim(ZCP->ZCP_CODPLA)
Local _nCount	:= 0
Local nTotReg := 0

DbSelectArea("ZCP")
ZCP->(DbSetOrder(2)) // Filial + Planilha
ZCP->(DbGoTop())

//Count To nTotReg //A variavel nTotReg é declarada no inicio da rotina
oProcess:SetRegua1(nTotReg)	
oProcess:SetRegua2(nTotReg)	

If ZCP->(DbSeek(_cChave ))
    If MSGYESNO("Deseja excluir os dados da importação da planilha "+Alltrim(ZCP->ZCP_CODPLA)+"?"     )
		DbSelectArea("AK1")
		AK1->(DbSetOrder(1)) //Filial + Planilha
		AK1->(DbGoTop())
		If AK1->(DbSeek(xFilial("AK1")+ZCP->ZCP_CODPLA ))
			MSGINFO("A planilha "+Alltrim(ZCP->ZCP_CODPLA)+" existe no PCO! Realize a exclusão da planilha "+CHAR(13)+CHAR(10);
					+"para que seja possível a exclusão dos dados de importação!","Exclusão não permitida. Planilha ativa no PCO!  ")
		Else
		
		
			// Contando total de Registros!
			While ZCP->(!EOF()) .and. ZCP->(ZCP_FILIAL+ZCP_CODPLA) == _cChave
				nTotReg ++ 
			ZCP->(DbSkip())
			Enddo
//			_cProc001	:= "Exclusão da Planilha "+_cCodPla+" da filial "+cFilAnt
			oProcess:IncRegua1("Exclusão da Planilha "+_cCodPla+" da filial "+cFilAnt)	//DETALHE DA REGUA DE PROCESSAMENTO				
			oProcess:SetRegua2(nTotReg)
			ZCP->(DbGoTop())	
			If ZCP->(DbSeek(_cChave ))
				While ZCP->(!EOF()) .and. ZCP->(ZCP_FILIAL+ZCP_CODPLA) == _cChave
					_nCount ++ 
					oProcess:IncRegua2("Excluindo "+cValToChar(_nCount)+" de "+ cValTochar(nTotReg))	//DETALHE DA REGUA DE PROCESSAMENTO				
					ZCP->(RecLock("ZCP",.F.))
						ZCP->(DbDelete())		
					ZCP->(MsUnlock())
				ZCP->(DbSkip())
				Enddo
			EndIf
		EndIf
	EndIf
EndIf

If _nCount > 0 
	MsgInfo("Foram excluídos "+cValToChar(_nCount)+" registros referente a importação da planilha "+_cCodPla+"!","Sucesso")
Else
	MsgInfo("Sem registros para exclusão","Problema")
EndIf

Return





Static Function ZEXECQRY(_cQuery)
Local nStatus := 0 
Local _lRet := .T.

Default _cQuery := ""

If Empty(_cQuery)
    Return .F.
EndIf

TCLink()

nStatus := TCSqlExec(_cQuery)
   
If (nStatus < 0)
    alert("TCSQLError() " + TCSQLError())
	_lRet := .F.
else
    //Alert("SUCESSO!")
Endif
   
TCUnlink()

Return _lRet

////GERAR BASE DE RELATÓRIO.
User Function ZExpOrc()
Local _nX := 0
Local _aAllField := {}
Local cCpo := ''
Local _aHeader := {}
Local _aItens := {}



       _aAllField := FWSX3Util():GetAllFields( "ZCP" , .F. )
       
        For _nX := 1 to Len(_aAllField)
            cCpo := alltrim(_aAllField[_nX])
            If(!Empty(FwSX3Util():GetFieldType(cCpo)))
                If GetSx3Cache(cCpo, "X3_CONTEXT") <> "V" .and. cCpo <> "ZCP_TEXTO"
					If GetSx3Cache(cCpo, "X3_TIPO") $ "CND" 
						aAdd(_aHeader, {cCpo, GetSx3Cache(cCpo, "X3_TIPO"), GetSx3Cache(cCpo, "X3_TAMANHO") })
					EndIf
				EndIf
			EndIf
		Next _nX

		For _nX := 1 to Len(_aHeader)
			aAdd(_aItens, &("ZCP->"+Alltrim(_aHeader[_nX][1]))    )
		Next _nX 

ZEXECREL(_aItens, _aHeader)

Return 

Static Function ACADDAK2(_aAutoCab, _aAutoItens)
Local _lRet := .T.
Default _aAutoCab := {}
Default _aAutoItens := {} 

Private lMsErroAuto := .F.

	MSExecAuto( {|x,y,z,a,b,c| PCOA100(x,y,z, a, b, c)}, 4/*nCallOpcx*/,/*cRevisa*/, /*lRev*/, /*lSim*/,_aAutoCab, _aAutoItens) //4=alteração para manipular itens da planilha

If lMsErroAuto
	msgalert("Erro na alteracao inclusão / alteração de itens na planilha!")
	MostraErro()
	_lRet := .F.
EndIf

Return _lRet




#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"


Static Function ZEXECREL(_aItens, _aHeader)

Local _nX := 0
Local _nY := 0 
Local _nRow := 0
local oPrtXlsx as object
local cFilename as character
local lRet as logical
Local cFont := ""
Local nSize := 11
Local lItalic := .F.
Local lBold := .T.
Local lUnderlined := .F.
Local _cNomArq := 'c:\Temp\ZCADZCP_'+DToS(Date())+StrTran(Time(),":","")
Local cColor := "000000" // Cor preta!
Local cColorF := "FFFFFF" 

static oCellHorAlign := FwXlsxCellAlignment():Horizontal()
static oCellVertAlign := FwXlsxCellAlignment():Vertical()

cFilename := _cNomArq+'.rel'
ferase(cFilename)
oPrtXlsx := FwPrinterXlsx():New(.T.)
lRet := oPrtXlsx:Activate(cFilename)

    
    lRet := oPrtXlsx:AddSheet("Base para Importação")
    
    cFont := FwPrinterFont():Calibri()
    nSize := 14
    lItalic := .F.
    lBold := .T.
    lUnderlined := .F.
    lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)
    _nRow ++ //soma 1 linha para os tÃ­tulos
    
	For _nX := 1 to Len(_aHeader)
		lRet := oPrtXlsx:SetText(_nRow, _nX , _aHeader[_nX][1] )
	Next _nX

    cFont := FwPrinterFont():Calibri()
    nSize := 11
    lItalic := .F.
    lBold := .F.
    lUnderlined := .F.
    lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)

		_nRow ++
		For _nY := 1 to Len(_aHeader)

            cHorAlignment := oCellHorAlign:LEFT()
            cVertAlignment := oCellVertAlign:Center()
            lWrapText := .F.
            nRotation := 0
            cCustomFormat := ""
            lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, cColor, cColorF, cCustomFormat)

			If _aHeader[_nY][2] == "C"
				lRet := oPrtXlsx:SetText(_nRow, _nY, _aItens[_nY] )
			ElseIf _aHeader[_nY][2] == "N"
				cCustomFormat := "0.00"
				cHorAlignment   := oCellHorAlign:Right()
				lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, cColor, cColorF, cCustomFormat)
				lRet := oPrtXlsx:SetNumber(_nRow, _nY, _aItens[_nY] )
			ElseIf _aHeader[_nY][2] == "D"
				cCustomFormat := "dd/mm/yyyy"
				lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, cColor, cColorF, cCustomFormat)
				lRet := oPrtXlsx:SetDate(_nRow, _nY, _aItens[_nY])
			EndIf
		Next _nY
          
	lRet := oPrtXlsx:toXlsx()
 
    oPrtXlsx:DeActivate()
    shellExecute("Open", "excel", _cNomArq+".xlsx", "C:\", 1 )
    MsgInfo('Arquivo gerado com sucesso: '+cFilename,"Sucesso")

    
Return()
