#include "Protheus.ch"

//ExecBlock("A261LOC",.F.,.F., {aCols[n,nPosCODOri],cLocal,nOrigDest})
User Function A261LOC()

Local _cProduto := ParamIxb[1] // Produto
Local _cLocal   := ParamIxb[2] // Local
Local _nOpc  := ParamIxb[3]  //- 1 Origem, 2 Destino

If !IsBlind()
    dbSelectArea("SB2")
    SB2->(dbSetOrder(1))
    SB2->(DbGoTop())
    If !SB2->(dbSeek(xFilial('SB2')+_cProduto+_cLocal ))
        If Aviso("Atenção","Deseja criar o saldo inicial para o produto "+Alltrim(_cProduto)+" no armazém "+_cLocal +"?",{"Sim","Não"},2) == 1 
            ZVLDSB2(cFilAnt, _cProduto, _cLocal)
        EndIf
    EndIf

EndIf
 
Return 




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

DbSelectArea("SB2")
SB2->(DbSetOrder(1))
SB2->(DbGoTop())
If !SB2->(DbSeek(_nFilNNR+_cProduto + _cLocProd))
	_aDados :={;
				{"B9_FILIAL", _nFilNNR   , Nil},;
				{"B9_COD",    _cProduto  , Nil},;
				{"B9_LOCAL",  _cLocProd  , Nil},;
				{"B9_DATA",   Stod("")     , Nil},;
				{"B9_QINI",   0          , Nil};
			}
 
    MSExecAuto({|x, y| Mata220(x, y)}, _aDados, 3)
     
    //Se houve erro, mostra mensagem
    If lMsErroAuto
        MostraErro()
		_lRet := .F.
	else
		_lRet := .T.
    EndIf
Else
	_lRet := .T.
EndIf

cFilAnt  := _cFilBkp
OpenSM0(cEmpAnt + cFilAnt)

RestArea(_aAreaSM0)
RestArea(_aArea)

Return _lRet
