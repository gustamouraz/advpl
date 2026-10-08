#include "TOTVS.CH"

User Function VLAMBUSR()

	Local cUserId 	:= PARAMIXB[1] 
	Local cUserCod 	:= PARAMIXB[2] 
	Local _aArea := GetArea()
	Local cAmbLog	:= Upper(GetEnvServer())
	Local cDtLog	:= DTOS(Date())
	Local cHrLog	:= SubStr(FwTimeUF("RO")[2],1,5)
	Local aUserGrp := UsrRetGrp(cUserId)
	Local cLog := ""
	Local cVLAMBUSR :=  GetNextAlias()
	Local aAmbBlq 	:= {"QKQQVJ_PRD_01","QKQQVJ_PRD_02","QKQQVJ_PRD_03","QKQQVJ_PRD_04","QKQQVJ_PRD_05","QKQQVJ_PRD_06","QKQQVJ_PROMOV","QKQQVJ_VALIDA","QKQQVJ_UBA","QKQQVJ_COMP","QKQQVJ_FINA","QKQQVJ_MIGRACAO","QKQQVJ_PADRAO","QKQQVJ_WS","QKQQVJ_WS_REST"}

    BeginSql Alias cVLAMBUSR
        %noparser%
		SELECT * FROM ZMP010 
        WHERE ZMP_USER = %Exp:cUserId%
        AND ZMP_AMBIEN = %Exp:cAmbLog%
        AND ZMP_DTINI + ZMP_HRINI <= %Exp:cDtLog% + %Exp:cHrLog% 
        AND ZMP_DTFIM + ZMP_HRFIM >= %Exp:cDtLog% + %Exp:cHrLog% 

    EndSql

	If !(aScan(aUserGrp, "000000") > 0) .AND. aScan(aAmbBlq, {|cValor| cValor == cAmbLog}) > 0 

		If !((cVLAMBUSR)->R_E_C_N_O_ > 0)
			cLog += ' Ambiente : ' + cAmbLog + ' Usuário : ' + cUserCod
 			U_FMKLOGTI("\logs\ambiente", "negado", cLog )
			Final("Acesso restrito! Ambiente nao liberado para uso do usuario.")
		Else
			cLog += 'Ambiente: ' + cAmbLog + ' Usuário: ' + cUserCod
 			U_FMKLOGTI("\logs\ambiente", "acesso", cLog )
		EndIf
	
	EndIf

	RestArea(_aArea)

Return
