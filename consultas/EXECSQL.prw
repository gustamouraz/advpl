//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

// Executa o script inteiro em um único bloco de execução.
User function EXECSQL()
Local lRPC            := .F.
Local lDeuCerto       := .F.
Local lFalhou         := .F.
Local cMensagem       := ""
Local cQuery          := ""
Local cSqlContagem    := ""
Local cAliasContagem  := GetNextAlias()
Local nRegComando     := 0
Local nRegAfetados    := 0
Local oFile
Default lFinal := .F.

If Select("SX2") == 0
    RpcClearEnv()
    RPCSetType(3) // NAO CONSOME LICENSA DE USO
    If !RpcSetEnv("01", "060110", "", "", "CTB",, {"SN3"})
        Return Nil
    EndIf
    lRPC := .T.
EndIf

If !FwIsAdmin()
    Final("Somente usuarios Administradores podem executar este comando.")
EndIf

// Cada linha do SCRIPT.txt deve conter um UPDATE completo.
oFile := FWFileReader():New("C:\Totvs\script\SCRIPT.txt")

If oFile:Open()
    While oFile:HasLine()
        cQuery := AllTrim(oFile:GetLine())

        If Empty(cQuery)
            Loop
        EndIf

        // Para UPDATE, conta antes de executar usando o mesmo WHERE.
        // Assim, apos alterar os dados, a contagem original nao e perdida.
        nRegComando := 0
        cSqlContagem := zSqlQtdUpdate(cQuery)

        If !Empty(cSqlContagem)
            TCQuery cSqlContagem New Alias (cAliasContagem)

            If Select(cAliasContagem) > 0
                If !(cAliasContagem)->(Eof())
                    nRegComando := (cAliasContagem)->QTD_AFETADOS
                EndIf
                (cAliasContagem)->(DbCloseArea())
            EndIf
        EndIf

        If TCSqlExec(cQuery) < 0
            lFalhou := .T.

            If !IsBlind()
                cMensagem := "Falha na atualizacao do Banco de Dados!" + CRLF + CRLF
                cMensagem += "/* ==== Query: ===== */" + CRLF
                cMensagem += cQuery + CRLF + CRLF
                cMensagem += "/* ==== Mensagem: ===== */" + CRLF
                cMensagem += TCSQLError()
                ShowLog(cMensagem)
            EndIf

            If lFinal
                Final("zExecQry: Falha na operacao. Contate o Administrador.")
            EndIf
        Else
            nRegAfetados += nRegComando
            lDeuCerto := .T.
        EndIf
    EndDo

    oFile:Close()

    If lDeuCerto .And. !lFalhou
        FWAlertSuccess(CValToChar(nRegAfetados) + " registros foram alterados", "EXECSQL")
    EndIf
Else
    FWAlertError("Falha ao abrir o arquivo SCRIPT.txt", "Atencao!!")
EndIf

Return Nil

// Retorna o SELECT de contagem para comandos UPDATE simples.
Static Function zSqlQtdUpdate(cQuery)
Local cSql       := AllTrim(cQuery)
Local cSqlUpper  := Upper(cSql)
Local cTabela    := ""
Local cWhere     := ""
Local nPosSet    := 0
Local nPosWhere  := 0

If Left(cSqlUpper, 6) <> "UPDATE"
    Return ""
EndIf

nPosSet := At(" SET ", cSqlUpper)
nPosWhere := At(" WHERE ", cSqlUpper)

If nPosSet == 0 .Or. nPosWhere == 0
    Return ""
EndIf

cTabela := AllTrim(SubStr(cSql, 7, nPosSet - 7))
cWhere := AllTrim(SubStr(cSql, nPosWhere + 7))

If Right(cWhere, 1) == ";"
    cWhere := AllTrim(Left(cWhere, Len(cWhere) - 1))
EndIf

Return "SELECT COUNT(*) AS QTD_AFETADOS FROM " + cTabela + " WHERE " + cWhere

// Executa cada comando do script individualmente, linha por linha.
User function EXECSQLL()
Local lRPC            := .F.
Local lDeuCerto       := .F.
Local lFalhou         := .F.
Local cMensagem       := ""
Local cQuery          := ""
Local cSqlContagem    := ""
Local cAliasContagem  := GetNextAlias()
Local nRegComando     := 0
Local nRegAfetados    := 0
Local oFile
Default lFinal := .F.

If Select("SX2") == 0
    RpcClearEnv()
    RPCSetType(3) // NAO CONSOME LICENSA DE USO
    If !RpcSetEnv("01", "060110", "", "", "CTB",, {"SN3"})
        Return Nil
    EndIf
    lRPC := .T.
EndIf

If !FwIsAdmin()
    Final("Somente usuarios Administradores podem executar este comando.")
EndIf

// Cada linha do SCRIPT.txt deve conter um UPDATE completo.
oFile := FWFileReader():New("C:\Totvs\script\SCRIPT.txt")

If oFile:Open()
    While oFile:HasLine()
        cQuery := AllTrim(oFile:GetLine())

        If Empty(cQuery)
            Loop
        EndIf

        // Conta antes do UPDATE com o mesmo WHERE.
        nRegComando := 0
        cSqlContagem := zSqlQtdUpdate(cQuery)

        If !Empty(cSqlContagem)
            TCQuery cSqlContagem New Alias (cAliasContagem)

            If Select(cAliasContagem) > 0
                If !(cAliasContagem)->(Eof())
                    nRegComando := (cAliasContagem)->QTD_AFETADOS
                EndIf
                (cAliasContagem)->(DbCloseArea())
            EndIf
        EndIf

        If TCSqlExec(cQuery) < 0
            lFalhou := .T.

            If !IsBlind()
                cMensagem := "Falha na atualizacao do Banco de Dados!" + CRLF + CRLF
                cMensagem += "/* ==== Query: ===== */" + CRLF
                cMensagem += cQuery + CRLF + CRLF
                cMensagem += "/* ==== Mensagem: ===== */" + CRLF
                cMensagem += TCSQLError()
                ShowLog(cMensagem)
            EndIf

            If lFinal
                Final("zExecQry: Falha na operacao. Contate o Administrador.")
            EndIf
        Else
            nRegAfetados += nRegComando
            lDeuCerto := .T.
        EndIf
    EndDo

    oFile:Close()

    If lDeuCerto .And. !lFalhou
        FWAlertSuccess(CValToChar(nRegAfetados) + " registros foram alterados", "EXECSQLL")
    EndIf
Else
    FWAlertError("Falha ao abrir o arquivo SCRIPT.txt", "Atencao!!")
EndIf

Return Nil
