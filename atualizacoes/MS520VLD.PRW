#Include "Protheus.ch"

/*
@Autor:      AndrÃ© Claro
@Data:       04/06/2025
@Descrição:  Ponto de entrada para validar exclusão de nota fiscal de saída.
*/

User Function MS520VLD()
Local _aArea := GetArea()
Local _aAreaSF2 := Sf2->(GetArea())
Local _aAreaSD2 := SD2->(GetArea())
Local _lRet := .T.
Local _cAlias := ''
Local _cQuery := ''
Local _aItens := {}
Local _aCabec := {}
Local _cChvNFE := ""

Local _cFilBkp := cFilAnt 

    //valida cadastro de usuarios cancelamento (rotina: WUSRCANC) - Luiz Moura
    If !(SX5->(DbSeek(xFilial("SX5") + 'UC' + RetCodUsr() )) .or. aScan(UsrRetGrp(), "000000") > 0) 
        FWAlertHelp("Usuário sem permissão para cancelamento","Entre em contato com o time de CSC para o cancelamento")
        _lRet := .F.
    EndIf

If _lRet .And. !Empty(SF2->F2_CHVNFE)
    _cChvNFE := SF2->F2_CHVNFE
    _cQuery := " SELECT F1_FILIAL, COUNT(*) AS QUANTAS FROM "+RetSqlName("SF1")+" WHERE D_E_L_E_T_ = '' AND F1_CHVNFE <> '' AND F1_CHVNFE = '"+SF2->F2_CHVNFE+"' GROUP BY F1_FILIAL "
    
    _cAlias := GetNextAlias()
    
    MpsysopenQuery(_cQuery, _cAlias)
    If (_cAlias)->(!eof())
        If (_cAlias)->QUANTAS > 1 
            AVISO(      "Ponto de Entrada: MS520VLD",;
                    "A NF: " + ALLTRIM(SF2->F2_DOC) + "/" + ALLTRIM(SF2->F2_SERIE) + " está lançada em mais de uma filial. ";
                    +". Exclua a NF nas filiais de entrada e tente novamente.",;
                    {"REVISAR"}   ,   2    )
                    _lRet := .F.
        ElseIf AVISO(      "Ponto de Entrada: MS520VLD",;
                    "A NF: " + ALLTRIM(SF2->F2_DOC) + "/" + ALLTRIM(SF2->F2_SERIE) + " está lançada na filial ";
                    +(_cAlias)->F1_FILIAL+". Exclua a NF na filial de entrada e tente novamente.",;
                    {"REVISAR","EXCLUI NF ENTRADA"}   ,   2    ) == 2
            (_cAlias)->(DbCloseArea())

            _cQuery := " SELECT F1_FILIAL, SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_TIPO, SF1.F1_ESPECIE, 
            _cQuery += " SD1.D1_ITEM, SD1.D1_COD
            _cQuery += " FROM "+RetSqlName("SF1")+" SF1  INNER JOIN "+RetSqlName("SD1")+" SD1 ON "
            _cQuery += "            SD1.D1_FILIAL = SF1.F1_FILIAL AND SD1.D1_DOC = SF1.F1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE
            _cQuery += "            AND SD1.D1_FORNECE = SF1.F1_FORNECE AND SD1.D1_LOJA = SF1.F1_LOJA AND SD1.D_E_L_E_T_ = '' 
            _cQuery += " WHERE SF1.D_E_L_E_T_ = '' AND F1_CHVNFE <> '' AND F1_CHVNFE = '"+SF2->F2_CHVNFE+"'  ""

            _cAlias := GetNextAlias()

            MpsysopenQuery(_cQuery, _cAlias)

            If (_cAlias)->(!eof())
                cFilAnt := (_cAlias)->F1_FILIAL
                OpenSm0(cEmpAnt + cFilAnt)
                _aItens := {}
                _aCabec := {}
                
                aAdd(_aCabec, {"F1_DOC",     (_cAlias)->F1_DOC,     Nil})
                aAdd(_aCabec, {"F1_SERIE",   (_cAlias)->F1_SERIE,   Nil})
                aAdd(_aCabec, {"F1_FORNECE", (_cAlias)->F1_FORNECE, Nil})
                aAdd(_aCabec, {"F1_LOJA",    (_cAlias)->F1_LOJA,    Nil})
                aAdd(_aCabec, {"F1_TIPO",    (_cAlias)->F1_TIPO,    Nil})
                aAdd(_aCabec, {"F1_ESPECIE", (_cAlias)->F1_ESPECIE, Nil})

                While (_cAlias)->(!eof())
                    _aLinha := {}
                    aAdd(_aLinha,  {"D1_DOC",     (_cAlias)->F1_DOC,     Nil})
                    aAdd(_aLinha,  {"D1_SERIE",   (_cAlias)->F1_SERIE,   Nil})
                    aAdd(_aLinha,  {"D1_FORNECE", (_cAlias)->F1_FORNECE, Nil})
                    aAdd(_aLinha,  {"D1_LOJA",    (_cAlias)->F1_LOJA,    Nil})
                    aAdd(_aLinha,  {"D1_TIPO",    (_cAlias)->F1_TIPO,    Nil})
                    aAdd(_aLinha,  {"D1_ITEM",    (_cAlias)->D1_ITEM,    Nil})
                    aAdd(_aLinha,  {"D1_COD",     (_cAlias)->D1_COD,     Nil})
                    aAdd(_aItens, aClone(_aLinha))
                (_cAlias)->(DbSkip())
                EndDo

                lMsErroAuto := .F.
                MSExecAuto({|x, y, z| MATA103(x, y, z)}, _aCabec, _aItens, 5)

                If lMsErroAuto
                    MostraErro()
                    _lRet := .F.
                EndIf

                cFilAnt := _cFilBkp
                OpenSm0(cEmpAnt + cFilAnt)
            EndIf
        Else
            _lRet := .F.
        EndIf
    EndIf
    (_cAlias)->(DbCloseArea())

    /*
    @Autor:     AndrÃ© Claro
    @Data:      06/12/2025
    @Descrição: Valida se existe NJJ de entrada com a mesma chave.
    */
    If _lRet
        _lRet := U_ACVEXCNJJ(_cChvNFE)
    EndIf

    If _lRet .And. SuperGetMv("MV_XVDOC", .F., .T.)
        _lRet := VLDENT(SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA)
    EndIf


EndIf

RestArea(_aAreaSD2)
RestArea(_aAreaSF2)
RestArea(_aArea)

Return _lRet

Static Function VLDENT(cDoc, cSerie, cCliente, cLojaCli)
    Local lRet      := .T.
    Local cForn     := ""
    Local cLojaForn := ""
    Local nTotal    := 0
    Local cMyAlias  := ""
    Local aArea     := GetArea()
    Local aAreaSA2  := {}

    Default cDoc     := ""
    Default cSerie   := ""
    Default cCliente := ""
    Default cLojaCli := ""

    // A validação é somente de leitura. A versão anterior invertia as
    // atribuições e tentava gravar A2_COD/A2_LOJA com variáveis vazias.
    If Empty(cDoc) .Or. Empty(cSerie) .Or. Empty(cCliente)
        FWAlertWarning("Não foi possível identificar o documento ou o cliente da NF de saída.", ;
            "[MS520VLD] - Erro na verificação de documento de entrada")
        lRet := .F.

    ElseIf Select("SA2") <= 0
        FWAlertWarning("A tabela de fornecedores (SA2) não está disponível para a validação.", ;
            "[MS520VLD] - Erro na verificação de documento de entrada")
        lRet := .F.

    ElseIf SA2->(FieldPos("A2_CLIENTE")) == 0 .Or. SA2->(FieldPos("A2_LOJCLI")) == 0
        FWAlertWarning("Os campos de vínculo Cliente/Fornecedor não estão disponíveis na SA2.", ;
            "[MS520VLD] - Erro na verificação de documento de entrada")
        lRet := .F.

    Else
        aAreaSA2 := SA2->(GetArea())
        SA2->(DbSetOrder(3))

        If SA2->(DbSeek(xFilial("SA2") + cCliente + cLojaCli))
            cForn     := SA2->A2_COD
            cLojaForn := SA2->A2_LOJA
        Else
            FWAlertWarning("Não foi possível localizar o fornecedor vinculado ao cliente da NF de saída.", ;
                "[MS520VLD] - Erro na verificação de documento de entrada")
            lRet := .F.
        EndIf
    EndIf

    If lRet
        cMyAlias := GetNextAlias()

        BeginSql Alias cMyAlias
            %NoParser%
            SELECT COUNT(*) AS QTDE
              FROM %table:SF1% SF1 WITH (NOLOCK)
             WHERE SF1.D_E_L_E_T_ = ''
               AND SF1.F1_DOC     = %exp:cDoc%
               AND SF1.F1_SERIE   = %exp:cSerie%
               AND SF1.F1_FORNECE = %exp:cForn%
               AND SF1.F1_LOJA    = %exp:cLojaForn%
        EndSql

        If Select(cMyAlias) > 0 .And. !(cMyAlias)->(Eof())
            nTotal := Val((cMyAlias)->QTDE)
        EndIf

        If Select(cMyAlias) > 0
            (cMyAlias)->(DbCloseArea())
        EndIf

        If nTotal > 0
            FWAlertWarning("Ainda existem NFs de entrada para este documento. A NF de saída não pode ser excluída até o ajuste da entrada." + ;
                CRLF + "Documento: " + cDoc + CRLF + "Série: " + cSerie, ;
                "[MS520VLD] - Falha na exclusão")
            lRet := .F.
        EndIf
    EndIf

    If !Empty(aAreaSA2)
        RestArea(aAreaSA2)
    EndIf
    RestArea(aArea)

Return lRet
