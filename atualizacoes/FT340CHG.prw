/*
@Autor:     Pedro
@Data:      25/04/2025
@Descrição:	PE altera caracteres especiais no nome do arquivo.	
*/

User Function FT340CHG()

Local _cRet := paramixb[1] 
// Local nI, cChar
Local cNome := ""
Local _cAliasACB := GetNextAlias()
Local cAliasNome   := SF1->F1_FILIAL + AllTrim(SF1->F1_DOC) + AllTrim(SF1->F1_ESPECIE)  

    // If AllTrim(cEspecie) == "NFS" 
        cNome := AllTrim(cAliasNome)        
    // Else
        // For nI := 1 To Len(_cRet)
        //     cChar := SubStr(_cRet, nI, 1)
        //     If IsAlpha(cChar) .Or. IsDigit(cChar) .Or. cChar $ "-_."
        //         cNome += cChar
        //     Else
        //         cNome += "_"
        //     EndIf
        // Next
    // EndIf    

        // Consulta SQL - Verifica duplicidade no banco de conhecimento 
    BeginSql alias _cAliasACB
        SELECT COUNT(ACB_OBJETO) ARQUIVOS
        FROM ACB010 
        WHERE D_E_L_E_T_ = '' 
          AND ACB_OBJETO LIKE %exp:cNome% + '%'
    EndSql
    
    If (_cAliasACB)->ARQUIVOS > 0 
        cNome += "_"
        cNome += AllTrim(Str( (_cAliasACB)->ARQUIVOS + 1 ))
    EndIf
        cNome += Alltrim(Substr(_cRet, At(".",_cRet)))

(_cAliasACB)->(DbCloseArea())

Return cNome
