#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} ACPCOLSD3
Rotina que permite ao usuario informar um periodo de Emissao, uma faixa de
Centro de Custo e uma faixa de Produto e, a partir da baixa de estoque
registrada na SD3 (considerando apenas a filial logada), lanca os movimentos
no PCO atraves do processo "000151" (Movimentos Internos).

Segue o mesmo padrao da rotina ACREPRPCO.prw (integracao offline do PCO para
o processo 000151): exige TES (SF5) com F5_XBIPCO = '1', ignora movimentos
com D3_CUSTO1 = 0 ou estornados, define o item do PcoDetLan conforme
D3_TM > '500' ('02') ou nao ('01'), e so lanca registros de SD3 que ainda nao
possuem um lancamento correspondente na AKD (mesma chave/processo/item),
evitando duplicidade. A SD3 e posicionada diretamente (sem staging via ZH1) e
chamado PcoIniLan/PcoDetLan/PcoFinLan em lote, como o ACREPRPCO faz.

Ao final e apresentado um resumo do processamento na tela, incluindo a
contagem de lancamentos efetivamente localizados na AKD para o processo
000151 dentro do periodo/C.Custo informados.
@type  Function
@author Johnny Santos
@since 20/08/2026
@version 3.0
/*/
User Function ACPCOLSD3()

Local oProcess := Nil

	oProcess := MsNewProcess():New({  || ZEXECREL(@oProcess)},"Integração Mov. Internos no PCO","Aguarde por favor!!!",.T.)
	oProcess:Activate()

Return 




Static Function ZEXECREL(oProcess)

Local _aParamBox    := {}
Local _cAliasQry    := ""
Local _cQuery       := ""
Local _cQryAKD      := ""
Local _cAliasAKD    := ""
Local _cItem        := ""
Local _nTamCC       := TamSX3("D3_CC")[1]
Local _nTamProd     := TamSX3("D3_COD")[1]
Local _nRegSD3      := 0
Local _nJaLancado   := 0
Local _nProcessados := 0
Local _cDetAKD      := ""
Local _cResumo      := ""
Local _dDataBkp     := dDataBase
Local _cFilSB1 := xFilial("SB1")
Local _nTotInd := 0
Local _aFiliais := {}
Local _nX := 0
Local _nPercentual := 0
Local _cProcess := "000151"

If Empty(SuperGetMv("MV_ZCCPCOA",.F.,""))
    Aviso("Atenção","Configure o parametro MV_ZCCPCOA com o centro de custo que será usado no débito desses lançamentos de crédito no PCO",{"SAIR"},2)
    Return
EndIf


If !ParamBox({;
        {1,"Data De"     ,CtoD("//")      ,"","","",".T.",50,.F.},;
        {1,"Data Ate"    ,CtoD("//")      ,"","","",".T.",50,.T.},;
        {1,"C.Custo De"  ,Space(_nTamCC)  ,"","","CTT",".T.",50,.F.},;
        {1,"C.Custo Ate" ,Space(_nTamCC)  ,"","","CTT",".T.",50,.T.},;
        {1,"Produto De"  ,Space(_nTamProd),"","","SB1",".T.",50,.F.},;
        {1,"Produto Ate" ,Space(_nTamProd),"","","SB1",".T.",50,.T.},;
        {1,"Grupo De"  ,Space(TamSX3("B1_GRUPO")[1]),"","","SBM",".T.",50,.F.},;
        {1,"Grupo Ate" ,Space(TamSX3("B1_GRUPO")[1]),"","","SBM",".T.",50,.T.},;
        {1,"Conta De"  ,Space(TamSX3("CT1_CONTA")[1]),"","","CT1",".T.",50,.F.},;
        {1,"Conta Ate" ,Space(TamSX3("CT1_CONTA")[1]),"","","CT1",".T.",50,.T.},;
        {1,"Filial De"  ,Space(TamSX3("D3_FILIAL")[1]),"","","SM0",".T.",50,.F.},;
        {1,"Filial Ate" ,Space(TamSX3("D3_FILIAL")[1]),"","","SM0",".T.",50,.T.};        
        },;
        "Lancamento PCO - Baixa de Estoque (SD3)",_aParamBox,,,,,,,,.T.,.T.)
    MsgStop("Operacao cancelada!","ACPCOLSD3")
    Return Nil
EndIf

_cQuery := " SELECT D3.D3_FILIAL, D3.R_E_C_N_O_ AS RECSD3, D3.D3_TM AS D3_TM, D3.D3_DOC AS D3_DOC, "
_cQuery += "        ISNULL(AKD.R_E_C_N_O_,0) AS RECAKD "
_cQuery += " FROM "+RetSqlName("SD3")+" D3 WITH(NOLOCK) "
_cQuery += " INNER JOIN "+RetSqlName("SB1")+" B1 WITH(NOLOCK) ON "
_cQuery += "     B1.B1_COD = D3.D3_COD "
_cQuery += " AND B1.D_E_L_E_T_ = '' "
_cQuery += " INNER JOIN "+RetSqlName("SF5")+" F5 WITH(NOLOCK) ON "
_cQuery += "     F5.F5_FILIAL = '' "
_cQuery += " AND F5.F5_CODIGO = D3.D3_TM "
_cQuery += " AND F5.D_E_L_E_T_ = '' "
_cQuery += " AND F5.F5_XBIPCO = '1' "
_cQuery += " LEFT JOIN "+RetSqlName("DHN")+" DHN WITH(NOLOCK) ON "
_cQuery += "     DHN.DHN_FILIAL = D3.D3_FILIAL "
_cQuery += " AND DHN.DHN_ITORI  = D3.D3_ITEMSA "
_cQuery += " AND DHN.DHN_DOCORI = D3.D3_NUMSA "
_cQuery += " AND DHN.D_E_L_E_T_ = '' "
_cQuery += " LEFT JOIN "+RetSqlName("AKD")+" AKD WITH(NOLOCK) ON "
_cQuery += "     AKD.AKD_FILIAL = D3.D3_FILIAL "
_cQuery += " AND AKD.AKD_CHAVE  = 'SD3'+D3.D3_FILIAL+D3.D3_COD+D3.D3_LOCAL+D3.D3_NUMSEQ+D3.D3_CF "
_cQuery += " AND AKD.AKD_PROCES = '"+_cProcess+"' "
_cQuery += " AND AKD.AKD_ITEM   = (CASE WHEN D3.D3_TM > '500' THEN '02' ELSE '01' END) "
_cQuery += " AND AKD.D_E_L_E_T_ = '' "
_cQuery += " AND AKD.AKD_TIPO   = '1' "
_cQuery += " WHERE D3.D_E_L_E_T_ = '' "
_cQuery += " AND D3.D3_FILIAL  >= '"+MV_PAR11+"' AND D3.D3_FILIAL <= '"+MV_PAR12+"' "
_cQuery += " AND D3.D3_EMISSAO >= '"+DtoS(mv_par01)+"' "
_cQuery += " AND D3.D3_EMISSAO <= '"+DtoS(mv_par02)+"' "
_cQuery += " AND D3.D3_CC      >= '"+mv_par03+"' "
_cQuery += " AND D3.D3_CC      <= '"+mv_par04+"' "
_cQuery += " AND D3.D3_COD     >= '"+mv_par05+"' "
_cQuery += " AND D3.D3_COD     <= '"+mv_par06+"' "

_cQuery += " AND B1.B1_GRUPO     >= '"+mv_par07+"' "
_cQuery += " AND B1.B1_GRUPO     <= '"+mv_par08+"' "
_cQuery += " AND B1.B1_RCONTA     >= '"+mv_par09+"' "
_cQuery += " AND B1.B1_RCONTA     <= '"+mv_par10+"' "



//_cQuery += " AND SUBSTRING(D3.D3_TM,1,1)    = '5' "
_cQuery += " AND D3.D3_TM > '500' "
_cQuery += " AND SUBSTRING(B1.B1_GRUPO,1,1) = '4' "
_cQuery += " AND DHN.DHN_DOCDES IS NULL "
_cQuery += " AND D3.D3_ESTORNO = '' "
_cQuery += " AND D3.D3_CUSTO1 <> 0 "
_cQuery += " ORDER BY D3.D3_FILIAL, D3.D3_EMISSAO, D3.D3_DOC "

MemoWrite("C:\Temp\ACPCOLSD3.SQL", _cQuery)

ConOut(_cQuery)

_cAliasQry := GetNextAlias()
MpSysOpenQuery(_cQuery, _cAliasQry)

_nTotInd := 0 
While (_cAliasQry)->(!eof())
    If aScan(_aFiliais, (_cAliasQry)->D3_FILIAL ) == 0 
        aAdd(_aFiliais, (_cAliasQry)->D3_FILIAL )
    EndIf
    _nTotInd++
(_cAliasQry)->(DbSkip())
EndDo

oProcess:SetRegua1( _nTotInd )

(_cAliasQry)->(DbGoTop())
DbSelectArea("SD3")
SD3->(DbSetOrder(1))

DbSelectArea("SB1")
SB1->(DbSetOrder(1))

For _nX := 1 to Len(_aFiliais)
    cFilAnt := _aFiliais[_nX]
    OpenSm0(cEmpAnt + cFilAnt)
    (_cAliasQry)->(DbGoTop())
    If (_cAliasQry)->(!Eof())
        PcoIniLan(_cProcess)

        While (_cAliasQry)->(!Eof())
            If (_cAliasQry)->D3_FILIAL == cFilAnt
                _nRegSD3++
                _nPercentual := Min(100, Round(_nRegSD3 / _nTotInd * 100, 2))
                oProcess:IncRegua1("Processando (" + cValToChar(_nPercentual) + "%)")

                SD3->(DbGoTo((_cAliasQry)->(RECSD3)))
                If SD3->(RECNO()) == (_cAliasQry)->(RECSD3)
                    SB1->(DbGoTop())
                    If SB1->(DbSeek(_cFilSB1 + SD3->D3_COD))
                        If (_cAliasQry)->RECAKD > 0
                            _nJaLancado++
                        Else
                            _cItem := IIf((_cAliasQry)->(D3_TM) > "500", "02", "01")
                            dDataBase := SD3->(D3_EMISSAO)
                            PcoDetLan(_cProcess,_cItem,"ACPCOLSD3")
                            _nProcessados++
                        EndIf
                    EndIf
                EndIf
            EndIf

            (_cAliasQry)->(DbSkip())
        EndDo

        PcoFinLan(_cProcess)
        dDataBase := _dDataBkp
    EndIf
Next _nX
(_cAliasQry)->(DbCloseArea())

If _nRegSD3 == 0
    MsgAlert("Nenhum movimento encontrado na SD3 para os parametros informados (verifique tambem se a TES do movimento tem F5_XBIPCO = '1')." + CRLF + "Filial logada: " + Alltrim(xFilial("SD3")) + " - " + Alltrim(FwFilialName()) + CRLF + CRLF + "Query executada:" + CRLF + _cQuery,"ACPCOLSD3")
    Return Nil
EndIf

oProcess:SetRegua1( 0 )
oProcess:IncRegua1("Validando registros gerados") 

//Diagnostico: lancamentos efetivados na AKD (processo 000151) por status, para este usuario/filial/CC/periodo
_cQryAKD := " SELECT AKD_STATUS, COUNT(*) AS CONTADOR "
_cQryAKD += " FROM "+RetSqlName("AKD")+" WITH(NOLOCK) "
_cQryAKD += " WHERE D_E_L_E_T_ = '' AND AKD_PROCES = '"+_cProcess+"' "
_cQryAKD += " AND AKD_FILIAL = '"+xFilial("AKD")+"' "
_cQryAKD += " AND AKD_USER   = '"+__cuserId+"' "
_cQryAKD += " AND AKD_CC    >= '"+mv_par03+"' AND AKD_CC <= '"+mv_par04+"' "
_cQryAKD += " AND AKD_DATA  >= '"+DtoS(mv_par01)+"' AND AKD_DATA <= '"+DtoS(mv_par02)+"' "
_cQryAKD += " GROUP BY AKD_STATUS "

_cAliasAKD := GetNextAlias()
MpSysOpenQuery(_cQryAKD, _cAliasAKD)
If (_cAliasAKD)->(!Eof())
    While (_cAliasAKD)->(!Eof())
        _cDetAKD += "Status "+Alltrim((_cAliasAKD)->AKD_STATUS)+": "+Alltrim(Str((_cAliasAKD)->CONTADOR))+" registro(s); "
        (_cAliasAKD)->(DbSkip())
    EndDo
EndIf
(_cAliasAKD)->(DbCloseArea())

_cResumo := "Filial: " + Alltrim(FwFilialName())                                                                        + CRLF
_cResumo += "Periodo informado: " + DtoC(mv_par01) + " a " + DtoC(mv_par02)                                             + CRLF
_cResumo += "C.Custo informado: " + Alltrim(mv_par03) + " a " + Alltrim(mv_par04)                                       + CRLF
_cResumo += "Produto informado: " + Alltrim(mv_par05) + " a " + Alltrim(mv_par06)                                       + CRLF
_cResumo += Replicate("-",50)                                                                                           + CRLF
_cResumo += "Movimentos SD3 encontrados (com TES XBIPCO)..: " + AllTrim(Str(_nRegSD3))                                  + CRLF
_cResumo += "Ja possuiam lancamento na AKD (ignorados)....: " + AllTrim(Str(_nJaLancado))                               + CRLF
_cResumo += "Lancamentos enviados ao PCO agora (PcoDetLan): " + AllTrim(Str(_nProcessados))                             + CRLF
_cResumo += Replicate("-",50)                                                                                           + CRLF
_cResumo += "Lancamentos localizados na AKD (processo "+_cProcess+"):" + CRLF
_cResumo += If(Empty(_cDetAKD), "Nenhum registro localizado na AKD para o periodo/C.Custo informados.", _cDetAKD)

If _nProcessados > 0 .And. Empty(_cDetAKD)
    MsgAlert(_cResumo,"Resumo do Processamento - ACPCOLSD3 (verifique)")
Else
    MsgInfo(_cResumo,"Resumo do Processamento - ACPCOLSD3")
EndIf

Return Nil
