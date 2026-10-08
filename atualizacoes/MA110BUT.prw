#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

/*/{Protheus.doc} MA110BUT
Ponto de entrada que e executado na validação da aprovação do documento
@author Danyel Bernuci
@since 04/02/2019
@version 1.0

Ponto de entrada chama função MSCO002D na opção Lead Time nas outras ações ao visualizar a SC.
/*/

User function MA110BUT()
Local	_nOpcx		:=	ParamIxb[1]
Local	_aBut110	:=	ParamIxb[2]
Local _nX := 0
Local _cUsrHProd := SuperGetMv("MV_ZC1HPRD",.F.,"00050A3") //Usuários que podem visualizar o botão histórico de produtos!

If ExistBlock("MSCO002D") .And. _nOpcx==2 
	If !AtIsRotina("MSCO002D")
		aadd(_aBut110,{"BMPORD1", {|| ExecBlock( "MSCO002D",.F.,.F.,2)},"Lead Time","Lead Time"})
	Endif	
EndIf

//Se o usuário não tem acesso e o parametro não está vazio
If !Empty(_cUsrHProd) .and. !(__cuserId$_cUsrHProd)
	For _nX := 1 to Len(_aBut110)
		If _aBut110[_nX][1] $ "S4WB005N"
			_aBut110[_nX][2] := {|| U_AC110NOAC()  }
		EndIf
	Next _nX 
EndIf

return _aBut110


User Function AC110NOAC()

	Aviso("ATENÇÃO","Usuário sem Acesso a rotina!",{"SAIR"},2,"PROBLEMA: MV_ZC1HPRD - Usuário sem acesso!")

Return
