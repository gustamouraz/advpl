#Include 'Protheus.ch'

User Function AGRA750()

    Local aParam    := PARAMIXB
    Local oObj      := Nil
    Local cIdPonto  := ""
    Local cIdModel  := ""
    Local lRet      := .T.

    If aParam <> Nil
        oObj     := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]

        Do Case
        Case cIdPonto == "FORMLINEPOS" .And. cIdModel == "MDGRIDDXT"
            lRet := fA750LoadHead(oObj)

        Case cIdPonto == "MODELPOS"
            lRet := fA750LoadHead(oObj)

            If lRet .And. ( Empty(DXS_ZCLENT) .Or. Empty(DXS_ZLJENT) )
                DbSelectArea("ADB")
                ADB->(DbSetOrder(1))

                If ADB->(MsSeek(xFilial("ADB") + DXS_CODCTP + "01"))
                    DbSelectArea("SF4")
                    SF4->(DbSetOrder(1))

                    If SF4->(MsSeek(xFilial("SF4") + ADB->ADB_TES))
                        If SF4->F4_PODER3 == "R"
                            lRet := .F.
                            MsgInfo("Cliente e Loja de Entrega obrigatorio para Contratos de Remessa!", SF4->F4_TEXTO)
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndCase
    EndIf

Return lRet

Static Function fA750LoadHead(oModel)
    Local aArea     := GetArea()
    Local aAreaDXN  := DXN->(GetArea())
    Local oMdlHead  := Nil
    Local oMdlGrid  := Nil
    Local nLine     := 0
    Local cNumIE    := ""
    Local cCliFat   := ""
    Local cLojFat   := ""
    Local cCliEnt   := ""
    Local cLojEnt   := ""
    Local cCliAux   := ""
    Local cLojAux   := ""
    Local cEntAux   := ""
    Local cLjEAux   := ""
    Local lFound    := .F.
    Local lRet      := .T.

    If ValType(oModel) <> "O"
        Return .T.
    EndIf

    oMdlHead := oModel:GetModel("MDFIELDDXS")
    oMdlGrid := oModel:GetModel("MDGRIDDXT")

    If oMdlHead == Nil .Or. oMdlGrid == Nil
        Return .T.
    EndIf

    DXN->(DbSetOrder(1))

    For nLine := 1 To oMdlGrid:Length()
        oMdlGrid:GoLine(nLine)

        If oMdlGrid:IsDeleted()
            Loop
        EndIf

        cNumIE := AllTrim(oMdlGrid:GetValue("DXT_NUMIE"))

        If Empty(cNumIE)
            Loop
        EndIf

        // Mapeamento validado: DXT_NUMIE -> DXN_CODIGO na mesma filial.
        If !DXN->(MsSeek(xFilial("DXN") + cNumIE))
            Loop
        EndIf

        cCliAux := AllTrim(DXN->DXN_ZCLIEN)
        cLojAux := AllTrim(DXN->DXN_ZLOJA)
        cEntAux := AllTrim(DXN->DXN_ZCLENT)
        cLjEAux := AllTrim(DXN->DXN_ZLJENT)

        If Empty(cCliAux) .Or. Empty(cLojAux)
            Loop
        EndIf

        If Empty(cEntAux)
            cEntAux := cCliAux
        EndIf

        If Empty(cLjEAux)
            cLjEAux := cLojAux
        EndIf

        If !lFound
            cCliFat := cCliAux
            cLojFat := cLojAux
            cCliEnt := cEntAux
            cLojEnt := cLjEAux
            lFound  := .T.
        ElseIf cCliFat <> cCliAux .Or. cLojFat <> cLojAux .Or. cCliEnt <> cEntAux .Or. cLojEnt <> cLjEAux
            lRet := .F.
            MsgStop("As instrucoes de embarque selecionadas possuem dados de faturamento/entrega divergentes na DXN. Revise o romaneio antes de confirmar.", "AGRA750")
            Exit
        EndIf
    Next nLine

    If lRet .And. lFound
        oMdlHead:SetValue("DXS_ZCLIEN", cCliFat)
        oMdlHead:SetValue("DXS_ZLOJA" , cLojFat)
        oMdlHead:SetValue("DXS_ZCLENT", cCliEnt)
        oMdlHead:SetValue("DXS_ZLJENT", cLojEnt)
    EndIf

    RestArea(aAreaDXN)
    RestArea(aArea)

Return lRet
