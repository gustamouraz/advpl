#Include "Protheus.ch"
#Include "Totvs.ch"


User Function  ACTRFCSV() 

	Private cArq    	:= Space(200)
	Private lSair   	:= .F.
	Private cNewPlan   	:= Space(15)
	Private cAno  		:= Space(2)
	Private cMes  		:= Space(2)
	Private dDtVenc := StoD("")
	Private oDlg        
	Private _cProc001	:= "Aguarde por favor!!!"            
	
	
	Define MsDialog oDlg Title ("Importar Arquivos Transf. Estoque") From 0,0 To 260,650 Pixel
		@005,010 To 107,320 Pixel
		@011,020 Say "Escolha a Planilha .CSV" Pixel of oDlg

		@031,020 Say "Arquivo...........:" Pixel of oDlg
		@030,080 MsGet oVar4 Var cArq    Size 215,010 Pixel of oDlg When .F. //Nao Editavel
		@029,300 Button oBtnLoc Prompt "..."       Size 013,013 Pixel Action (LocArq(),lSair:=.T.)   of oDlg
		@052,120 Button oBtnOk  Prompt "&Ok"       Size 030,013 Pixel Action (oDlg:End(),ACIMPORTA(cArq)) of oDlg
		@052,180 Button oBtnCan Prompt "&Cancelar" Size 030,013 Pixel Action (lSair:=.T.,oDlg:End()) of oDlg
	Activate MsDialog oDlg Centered Valid lSair

Return
     
Static Function ACIMPORTA (_cPath)

Local oProcess
            
	oProcess := MsNewProcess():New({|| ProImpPla(_cPath, @oProcess)},"Importando registros da planilha!","Aguarde por favor!!!",.F.)
	oProcess:Activate()

Return (Nil) 

Static Function LocArq()
	cArq   := cGetFile("Arq.separados p.virgula|*.CSV|","Selecione o diretorio",,,,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)
Return(cArq)

Static Function ProImpPla(_cPath, oProcess)

Local _cBuffer 	:= ""   
Local _aLin   	:= {} 
Local _nLinha	:= 0
Local _nX	:= 0
Local _cQuery	:= ""
Local _cAlias := ''
Local _aHeader := {}
Local _lRet := .T.
Local _aFields := {}

Local _nFILIAL := 1 
Local _nPRODORI := 2
Local _nLOCORI := 3
Local _nDEMISSAO := 4 
Local _nPRODEST := 5
Local _nLOCDES := 6
Local _nQUANT := 7
Local _nLOTEORI := 8 
Local _nLOTEDES := 9
Local _nLOCLIZO := 10
Local _nLOCLIZD := 11
Local _nNUMSERO := 12
Local _nNUMSERD := 13

Local _cFilBkp := cFilAnt
Local _dDataBkp := dDataBase
Local _cNumDocs := ""
Local _cNumDoc := ""

Default _cPath := ""

If !File(_cPath)
  ConOut("erro...")
  Return(Nil)
EndIf

_cId := __cUserId + DtoS(DATE())+SubStr(Time(),1,2) +SubStr(Time(),4,2) //16

aadd(_aFields,{ "FILIAL"    , "C" ,  TamSx3("D3_FILIAL")[1] , 0 })
aadd(_aFields,{ "PRODORI"   , "C" ,  TamSx3("D3_COD")[1] , 0 })
aadd(_aFields,{ "LOCORI"    , "C" ,  TamSx3("D3_LOCAL")[1]  , 0 })
aadd(_aFields,{ "DEMISSAO"  , "D" ,  TamSx3("D3_EMISSAO")[1]  , 0 })
aadd(_aFields,{ "PRODEST"   , "C" ,  TamSx3("D3_COD")[1] , 0 })
aadd(_aFields,{ "LOCDES"    , "C" ,  TamSx3("D3_LOCAL")[1]  , 0 })
aadd(_aFields,{ "QUANT"     , "N" ,  TamSx3("D3_QUANT")[1] , TamSx3("D3_QUANT")[2] })
aadd(_aFields,{ "LOTEORI"    , "C" , TamSx3("D3_LOTECTL")[1]  , 0 })
aadd(_aFields,{ "LOTEDES"    , "C" , TamSx3("D3_LOTECTL")[1]  , 0 })
aadd(_aFields,{ "LOCLIZO"    , "C" , TamSx3("D3_LOCALIZ")[1]  , 0 })
aadd(_aFields,{ "LOCLIZD"    , "C" , TamSx3("D3_LOCALIZ")[1]  , 0 })
aadd(_aFields,{ "NUMSERO"    , "C" , TamSx3("D3_NUMSERI")[1]  , 0 })
aadd(_aFields,{ "NUMSERD"    , "C" , TamSx3("D3_NUMSERI")[1]  , 0 })

aadd(_aFields,{ "CID"    , "C" , 20  , 0 })


oTempTable := FWTemporaryTable():New( GetNextAlias() )

oTemptable:SetFields( _aFields )
oTempTable:AddIndex("1", {"FILIAL","PRODORI","LOCORI"} )
oTempTable:Create()

FT_FUSE(_cPath)  
FT_FGOTOP()

oProcess:SetRegua1(0)
oProcess:SetRegua2(0)
oProcess:IncRegua1("Validando dados para importação")
oProcess:IncRegua2("Processando arquivo!")

_lRet := .T.

Begin Transaction

    While !FT_FEOF() .and. _lRet
        _cBuffer := AllTrim(FT_FREADLN())
        _aLin   := Separa(_cBuffer,";")
        
        //Se viver linha vazia, ignoro!
        If Empty(_aLin[_nFILIAL]) 
            FT_FSKIP()
            Loop
        EndIf
        
        _nLinha ++
        
        If _nLinha == 1 
            _aHeader := aClone(_aLin)
            FT_FSKIP()
            Loop
        EndIf

        _cQuery := ""
        _cQuery += "INSERT INTO "+oTemptable:GetRealName() +" (FILIAL,PRODORI,LOCORI,DEMISSAO,PRODEST,LOCDES,QUANT,LOTEORI,LOTEDES,LOCLIZO,LOCLIZD,NUMSERO,NUMSERD,CID)  "

        _cQuery += "VALUES (   
        
            _cQuery += " '"+Alltrim(_aLin[_nFILIAL])    +"',"
            _cQuery += " '"+Alltrim(_aLin[_nPRODORI])   +"',"
            _cQuery += " '"+Alltrim(_aLin[_nLOCORI])    +"',"
            _cQuery += " '"+DtoS(CtoD(_aLin[_nDEMISSAO]))     +"',"
            _cQuery += " '"+Alltrim(_aLin[_nPRODEST])   +"',"
            _cQuery += " '"+Alltrim(_aLin[_nLOCDES])    +"',"
            _cQuery += " "+cValToChar(Val(_aLin[_nQUANT]))         +","
            _cQuery += " '"+Alltrim(_aLin[_nLOTEORI])   +"',"
            _cQuery += " '"+Alltrim(_aLin[_nLOTEDES])   +"',"
            _cQuery += " '"+Alltrim(_aLin[_nLOCLIZO])   +"',"
            _cQuery += " '"+Alltrim(_aLin[_nLOCLIZD])   +"',"
            _cQuery += " '"+Alltrim(_aLin[_nNUMSERO])   +"',"
            _cQuery += " '"+Alltrim(_aLin[_nNUMSERD])   +"', "
            _cQuery += " '"+ _cId  +"'  "
        
        _cQuery += " )"

        _nStatus := TCSqlExec(_cQuery)

        If _nStatus < 0
            _lRet := .F.            
        EndIf

        FT_FSKIP()
    EndDo

    If !_lRet
        DisarmTransaction()
    EndIf

End Transaction

    If !_lRet
        Aviso("ATENÇÃO","Houveram erros no arquivo que impediram a importação! Verifique se os campos estão corretos e com os tipos corretos.",{"REVISAR"},2)
        Return
    EndIf

    _cAlias := GetNextAlias()

    _cQuery := ""
    _cQuery := "SELECT FILIAL, DEMISSAO FROM "+oTempTable:GetRealName()+" WHERE CID = '"+_cId+"' GROUP BY FILIAL, DEMISSAO"

    MpSysOpenQuery(_cQuery, _cAlias)
    _aFilPer := {}
    While (_cAlias)->(!eof())
        aAdd(_aFilPer, { (_cAlias)->FILIAL, (_cAlias)->DEMISSAO })
    (_cAlias)->(DbSkip())
    EndDo
    (_cAlias)->(DbCloseArea())
    For _nX := 1 to Len(_aFilPer)
        _cAlias := GetNextAlias()
        _cQuery := ""
        _cQuery := "SELECT * FROM "+oTempTable:GetRealName()+" WHERE CID = '"+_cId+"' ORDER BY PRODORI

        MpSysOpenQuery(_cQuery, _cAlias)
        TcSetField(_cAlias,"DEMISSAO","D",8)
        _aItens := {}
        If (_cAlias)->(!eof())
            cFilAnt := (_cAlias)->FILIAL
            dDataBase := (_cAlias)->DEMISSAO
            OpenSm0(cEmpAnt + cFilAnt)
            While (_cAlias)->(!eof())
                aAdd(_aItens, {  ;
                                (_cAlias)->PRODORI,;
                                (_cAlias)->LOCORI,;
                                (_cAlias)->PRODEST,;
                                (_cAlias)->LOCDES,;
                                (_cAlias)->QUANT,;
                                (_cAlias)->LOTEORI,;
                                (_cAlias)->LOTEDES,;
                                (_cAlias)->LOCLIZO,;
                                (_cAlias)->LOCLIZD,;
                                (_cAlias)->NUMSERO,;
                                (_cAlias)->NUMSERD })
            (_cAlias)->(DbSkip())
            EndDo
            _cNumDoc := ""
            If U_ACMTA261(_aItens, @_cNumDoc)
                _cNumDocs += "Filial: "+cFilAnt + " Data: "+DtoC(dDataBase) + " Doc: "+_cNumDoc
            EndIf
        Endif
        (_cAlias)->(DbCloseArea())
    Next _nX 

If !Empty(_cNumDocs)
    Aviso("ATENÇÃO",_cNumDocs,{"OK"},2,"Documentos gerados com sucesso:")
EndIf


cFilAnt :=  _cFilBkp
dDataBase := _dDataBkp

OpenSm0(cEmpAnt + cFilAnt)

Return 




User Function ACMTA261(_aItens, _cNumDoc)

Local aAutoItens := {}
Local cNumDoc := {}
Local _lRet := .T.
Local _nX := 0

Local _cProdDes := ""
Local _cDesDes := ""
Local _cUmDes := ""
Local _cLoclizD := ""
Local _cProdOri := ""
Local _cDesOri := ""
Local _cUmOri := ""
Local _cLoclizO := ""

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

DbSelectArea("SB1")
SB1->(DbSetOrder(1))

    _cNumDoc		:= GetSxENum("SD3", "D3_DOC", 1)
    aAutoItens	:= {}
    aAdd(aAutoItens, {	cNumDoc,;		// numero do documento de transferencia
                        dDataBase})		// data da transferencia

    For _nX := 1 to Len(_aItens)
        SB1->(dbGoTop())
        IF SB1->(dbSeek(xFilial("SB1") + _aItens[_nX][1] ))
            _cProdOri := SB1->B1_COD
            _cDesOri := SB1->B1_DESC
            _cUmOri := SB1->B1_UM
            _cLoclizO := _aItens[_nX][8]

            ZVLDSB2(cFilAnt, _cProdOri, _aItens[_nX][2])

            SB1->(dbGoTop())
            IF SB1->(dbSeek(xFilial("SB1") + _aItens[_nX][3] ))
                _cProdDes := SB1->B1_COD
                _cDesDes := SB1->B1_DESC
                _cUmDes := SB1->B1_UM
                _cLoclizD := _aItens[_nX][8]

                ZVLDSB2(cFilAnt, _cProdDes, _aItens[_nX][4]  )
            Else
                _cProdDes := _cProdOri
                _cDesDes := _cDesOri
                _cUmDes := _cUmOri
                _cLoclizD := _cLoclizO
                ZVLDSB2(cFilAnt, _cProdDes, _aItens[_nX][4]  )
            EndIf

			aAdd(aAutoItens, {	_cProdOri           	,; // produto de origem
                                _cDesOri				,; // DESCRICAO
                                _cUmOri					,; // Unidade de Medida
                                _aItens[_nX][2]    		,; // armazem de origem
                                _cLoclizO		    ,; // ENDERECO de origem
                                _cProdDes			,; // produto de destino
                                _cDesDes				,; // Descricao
                                _cUmDes				,; // Unidade de Medida
                                _aItens[_nX][4]				,; // armazem de destino
                                _cLoclizD		,; // Endereco de destino
                                _aItens[_nX][10]		,; // Numero de serie
                                _aItens[_nX][6]							,; // lote de origem
                                CriaVar('D3_NUMLOTE')		,; // sub lote
                                CriaVar('D3_DTVALID')		,; // Data de validade
                                CriaVar('D3_POTENCI')		,; // Potencia
                                _aItens[_nX][5]    	,; // Quantidade
                                CriaVar('D3_QTSEGUM')		,; // Quantidade na 2 UM
                                CriaVar('D3_ESTORNO')		,; // Estorno
                                CriaVar('D3_NUMSEQ')		,; // numero Sequencia
                                _aItens[_nX][7]							,; // Lote de Destino
                                CriaVar('D3_DTVALID')		,; // Data de validade
                                CriaVar('D3_ITEMGRD')		,; // item da grade
                                "CSV Importado via ACMTA261" ,; // Observacao
                                CriaVar("D3_CODSAF")         })      

        EndIf
    Next _nX 

If(Len(aAutoItens) > 1)
    Begin Transaction
        lMsHelpAuto := .T.
        lMsErroAuto := .F.
        MsExecAuto({|x,y| mata261(x,y)}, aAutoItens , 3)

        If lMsErroAuto
            MostraErro()
            DisarmTransaction()
            _lRet := .F.
            _cNumDoc := ""
        EndIf
    End Transaction
EndIf

Return _lRet







Static Function ZVLDSB2(_cFilDest, _cProduto, _cLocProd)

Local _lRet := .T.
Local _aAreaSM0  := GetArea("SM0")                      	
Local _aArea   := GetArea()  
Local _cFilBkp :=  cFilant
Local _nFilNNR := ""
Local _aDados := {}

PRIVATE lMsErroAuto := .F.

If Empty(_cLocProd) .or. Empty(_cProduto) .or. Empty(_cFilDest)
	Return .F.
EndIf

_cFilBkp := cFilAnt
cFilAnt  := _cFilDest
OpenSM0(cEmpAnt + cFilAnt)

_nFilNNR := xFilial("SB2")


DbSelectArea("SB1")
SB1->(DbSetOrder(1))
SB1->(DbGoTop())

If SB1->(DbSeek(xFilial("SB1") + _cProduto ))
    DbSelectArea("SB2")
    SB2->(DbSetOrder(1))
    SB2->(DbGoTop())
    If !SB2->(DbSeek(_nFilNNR+ SB1->B1_COD + _cLocProd))
        _aDados :={;
                    {"B9_FILIAL", _nFilNNR   , Nil},;
                    {"B9_COD",    _cProduto  , Nil},;
                    {"B9_LOCAL",  _cLocProd  , Nil},;
                    {"B9_DATA",   Stod("")     , Nil},;
                    {"B9_QINI",   0          , Nil};
                }
    
        MSExecAuto({|x, y| Mata220(x, y)}, _aDados, 3)

        If lMsErroAuto
            MostraErro()
            _lRet := .F.
        else
            _lRet := .T.
        EndIf
    Else
        _lRet := .T.
    EndIf
EndIf

cFilAnt  := _cFilBkp
OpenSM0(cEmpAnt + cFilAnt)

RestArea(_aAreaSM0)
RestArea(_aArea)

Return _lRet
