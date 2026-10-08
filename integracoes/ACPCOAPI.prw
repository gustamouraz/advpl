#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "fileio.ch"
#INCLUDE "TopConn.ch"

/*
@Autor:         André Claro - andre.claro@acclaro.com.br / 35 99877-5495
@Data:          09/07/2025
@Descrição:     Programa responsável por gerar os lançamentos de justificativa
@Parametros:    
                _aDados -> { 
                            {Filial, Conta, C.Custo, data, Classe Orc, Tp.Lcto, Valor, Histórico, Tp.Saldo },;
                            {Filial, Conta, C.Custo, data, Classe Orc, Tp.Lcto, Valor, Histórico, Tp.Saldo }
                            } (Tp.Lcto 1=Credito;2=Debito)

*/

User Function ACTPCOAPI()
Local _aDados := {}
Local _aItem1 := {"010101","35103052","1001     ",Stod("20250710"),"000001","1",100,"TESTE INCLUSAO A CREDITO" , "EM" }
Local _aItem2 := {"010101","35103052","1001     ",Stod("20250710"),"000001","2",100,"TESTE INCLUSAO A DEBITO" , "EM" }
Local lRPC := .F.

If Select("SX2") == 0
    RpcClearEnv()
    RPCSetType(3)
    If(!RpcSetEnv("01", "010101", "", "", "ATF",,{"SN1"}))
        Return(Nil)
    EndIf
    lRPC := .T.
EndIf

aAdd(_aDados, _aItem1)
aAdd(_aDados, _aItem2)

U_ACPCOAPI(_aDados)

Return 

User Function ACPCOAPI(_aDados)
Local _nX := 0 
Local _nPFilial := 1
Local _nPCta := 2  
Local _nPCC := 3  
Local _nPData := 4 
Local _nPClOrc := 5
Local _nPTpLcto := 6 
Local _nPValor := 7
Local _nPHist := 8 
Local _nPTpSald := 9
Local _nPTmOrc := 10
Local _cCodigo := ""
Local _cFilZH1 := xFilial("ZH1")
Local _aFiliais := {}
Local _cRet := ""
Local _lRet := .T.

Private _cCO := ''
Private _cCC := ''
Private _dData := Stod("")
Private _cClasse := ''
Private _nValor := ''
Private _cHist := ''
Private _cTipo := ""
Private _cTpSaldo := ''
Private _cTmOrc := ''

Default _aDados := {} //Filial, Co, CC, TpMov, Valor, Histórico,

    _cCodigo := ""

    DbSelectArea("ZH1")
    ZH1->(DbSetOrder(1))
    While .T.
        _cCodigo := ""
        _cCodigo := GetSXENum("ZH1","ZH1_CODIGO")
        ZH1->(dbGoTop())
        If ZH1->(dbSeek(_cFilZH1 + _cCodigo ))
            ConfirmSX8()
        Else
            Exit
        EndIf
    EndDo

Begin Transaction 

	For _nX := 1 to Len(_aDados)
        If aScan(_aFiliais, _aDados[_nX][_nPFilial]) == 0 
            aAdd(_aFiliais,_aDados[_nX][_nPFilial] )
        EndIf

        CONOUT("Valor" + CvALtOCHAR(_aDados[_nX][_nPValor]))

        If  ZH1->(RecLock("ZH1",.T.))
                ZH1->ZH1_FILIAL := _cFilZH1
                ZH1->ZH1_FILORI := _aDados[_nX][_nPFilial]
                ZH1->ZH1_CODIGO  := _cCodigo
                ZH1->ZH1_ITEM    := StrZero(_nX,4)
                ZH1->ZH1_CO      := _aDados[_nX][_nPCta]
                ZH1->ZH1_CC      := _aDados[_nX][_nPCC]
                ZH1->ZH1_DATA    := StoD(_aDados[_nX][_nPData])
                ZH1->ZH1_CLASSE  := _aDados[_nX][_nPClOrc]
                ZH1->ZH1_USERID  := __cuserId
                ZH1->ZH1_DTEXEC  := Date()
                ZH1->ZH1_VALOR   := _aDados[_nX][_nPValor]
                ZH1->ZH1_TIPO    := _aDados[_nX][_nPTpLcto]
                ZH1->ZH1_HIST    := _aDados[_nX][_nPHist]
                ZH1->ZH1_TPSALD  := _aDados[_nX][_nPTpSald]
                ZH1->ZH1_TMORC   := _aDados[_nX][_nPTmOrc]
            ZH1->(MsUnLock())
        EndIf
	Next _nX


    For _nX := 1 to Len(_aFiliais)
        cFilAnt := _aFiliais[_nX]
        OpenSm0(cEmpAnt + cFilAnt)
        
        _cQuery := " SELECT R_E_C_N_O_ AS RECZH1, ZH1_DATA  "
        _cQuery += " FROM "+RetSqlName("ZH1")+" WHERE D_E_L_E_T_ = '' AND ZH1_FILIAL = '"+_cFilZH1+"' " 
        _cQuery += " AND ZH1_FILORI = '"+_aFiliais[_nX]+"' AND ZH1_CODIGO = '"+_cCodigo+"' "
        _cQuery += " ORDER BY ZH1_DATA"
        
        ConOut(_cQuery)
        memowrite("C:\Temp\pegaaquery.sql" , _cQuery )
        
        _cAlias := GetNextAlias()
               
        
        MpSysOpenQuery(_cQuery, _cAlias)
        If (_cAlias)->(!eof())
            PcoIniLan("900018") 
            DbSelectArea("ZH1")
            ZH1->(DbSetOrder(2))//ZH1_FILIAL+ZH1_CODIGO+ZH1_FILORI+ZH1_ITEM  
            While (_cAlias)->(!eof())
                ZH1->(DbGoTo((_cAlias)->RECZH1))
                If ZH1->(RECNO()) == (_cAlias)->RECZH1
                    _cCO := ZH1->ZH1_CO 
                    _cCC := ZH1->ZH1_CC
                    _dData := ZH1->ZH1_DATA
                    _cClasse := ZH1->ZH1_CLASSE
                    _nValor := ZH1->ZH1_VALOR
                    _cHist := ZH1->ZH1_HIST
                    _cTipo := ZH1->ZH1_TIPO
                    _cTpSaldo := ZH1->ZH1_TPSALD
                    _cTmOrc := ZH1->ZH1_TMORC

                    PcoDetLan("900018","01","ACPCOAPI")
                Endif
            (_cAlias)->(DbSkip())
            EndDo
            PcoFinLan("900018")
            _cQryAKD := " SELECT ISNULL(COUNT(*),0) AS CONTADOR  "
            _cQryAKD += " FROM   "+RetSqlName("AKD")+" WITH(NOLOCK)  "
            _cQryAKD += " WHERE 	D_E_L_E_T_ = '' AND AKD_PROCES = '900018' AND AKD_STATUS = '1' 
		    _cQryAKD += " AND AKD_CHAVE LIKE 'ZH1"+_cFilZH1+_cCodigo+_aFiliais[_nX]+"'+'%'  "
            _cAliasAKD := GetNextAlias()
            MpSysOpenQuery(_cQryAKD, _cAliasAKD)
            If (_cAliasAKD)->(!eof())
                If (_cAliasAKD)->CONTADOR <= 0 
                    _cRet += "Problema integração registros da filial "+_aFiliais[_nX] +char(13)+char(10)
                EndIf
            Endif
            (_cAliasAKD)->(DbCloseArea())
        EndIf
        (_cAlias)->(DbCloseArea())
    Next _nX 

    If !Empty(_cRet)
        DisarmTransaction()
    Else
        // Aqui valido se todos lançamentos foram efetivados corretamente, se não foi, faço a exclusão.
        _cQuery := " SELECT ZH1.R_E_C_N_O_ AS RECZH1, ZH1_DATA, AKD.R_E_C_N_O_ AS RECAKD, AKD.AKD_STATUS   "
        _cQuery += " FROM "+RetSQLName("ZH1")+" ZH1 WITH(NOLOCK) INNER JOIN "+RetSQLName("AKD")+" AKD ON "
        _cQuery += "     AKD.AKD_FILIAL = ZH1.ZH1_FILIAL AND
        _cQuery += "     AKD.AKD_CHAVE = 'ZH1'+ZH1.ZH1_FILIAL+ZH1.ZH1_CODIGO+ZH1_FILORI+ZH1.ZH1_ITEM AND
        _cQuery += "     AKD.D_E_L_E_T_ = '' AND AKD.AKD_PROCES = '900018'  "
        _cQuery += " WHERE          ZH1.D_E_L_E_T_ = '' AND ZH1_FILIAL = '"+xFilial("ZH1")+"' " 
        _cQuery += "            AND ZH1_CODIGO = '"+_cCodigo+"' "

        _cAlias := GetNextAlias()
        MpSysOpenQuery(_cQuery, _cAlias)

        If (_cAlias)->(!eof())
            While (_cAlias)->(!eof())
                If (_cAlias)->AKD_STATUS == "2"
                    _lRet := .F.
                    Exit
                EndIf
            (_cAlias)->(DbSkip())
            EndDo
        EndIf

        (_cAlias)->(DbCloseArea())

        If !_lRet
            _cRet += "Ocorreram erro de integração no PCO. Verifique se as entidades estão corretas. "+CRLF
            DisarmTransaction()
        EndIf    
    EndIf

End Transaction

Return _cRet
