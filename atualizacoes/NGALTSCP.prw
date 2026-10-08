#Include "Protheus.ch"

User Function NGALTSCP()

    Local aItens  := aClone(ParamIXB[1])
    Local aCabec  := aClone(ParamIXB[2])
    Local aDadosSTL := {}
    Local nPosSrv := 0
    Local nPosUrg := 0
    Local nPosJus := 0
    Local cServico := "N"
    Local cUrg := "N"
    Local cJusUrg := ""

    /*
       O alias STL nao pode ser utilizado diretamente aqui: durante a
       geracao de S.A. aglutinada ele pode estar posicionado em outro
       insumo. Localiza o registro pela chave que compoe o item da S.A.
    */
    aDadosSTL := fDadosSTL(aItens)
    cServico := aDadosSTL[1]
    cUrg := aDadosSTL[2]
    cJusUrg := aDadosSTL[3]

    nPosSrv := aScan(aItens, {|aCampo| AllTrim(aCampo[1]) == "CP_XSERVI"})
    nPosUrg := aScan(aItens, {|aCampo| AllTrim(aCampo[1]) == "CP_YURGENT"})
    nPosJus := aScan(aItens, {|aCampo| AllTrim(aCampo[1]) == "CP_XJUSURG"})

    If nPosSrv > 0
        aItens[nPosSrv][2] := cServico
    Else
        aAdd(aItens, {"CP_XSERVI", cServico, Nil})
    EndIf
    If nPosUrg > 0
        aItens[nPosUrg][2] := cUrg
    Else
        aAdd(aItens, {"CP_YURGENT", cUrg, Nil})
    EndIf
    If nPosJus > 0
        aItens[nPosJus][2] := cJusUrg
    Else
        aAdd(aItens, {"CP_XJUSURG", cJusUrg, Nil})
    EndIf

Return {aItens, aCabec}


/*/{Protheus.doc} fDadosSTL
    Retorna os dados do insumo da OS que originou o item da S.A.
    A busca e feita por O.S., produto e local, em vez de depender do
    ponteiro corrente do alias STL.
/*/
Static Function fDadosSTL(aItens)

    Local cOS      := Substr(fConteudoCampo(aItens, "CP_OP"), 1, 6)
    Local cProduto := fConteudoCampo(aItens, "CP_PRODUTO")
    Local cLocal   := fConteudoCampo(aItens, "CP_LOCAL")
    Local cAlias   := GetNextAlias()
    Local cQuery   := ""
    Local aRet     := {"N", "N", ""}

    If Empty(cOS) .Or. Empty(cProduto)
        Return aRet
    EndIf

    cQuery := " SELECT top 1 STL.TL_XSERVI, STL.TL_YURGENT, STL.TL_XJUSURG "
    cQuery += " FROM " + RetSqlName("STL") + " STL "
    cQuery += " WHERE STL.TL_FILIAL  = " + ValToSQL(xFilial("STL"))
    cQuery += " AND STL.TL_ORDEM   = " + ValToSQL(cOS)
    cQuery += " AND STL.TL_CODIGO  = " + ValToSQL(cProduto)
    cQuery += " AND STL.TL_LOCAL   = " + ValToSQL(cLocal)
    cQuery += " AND STL.D_E_L_E_T_ = ' ' ORDER BY STL.R_E_C_N_O_ DESC"
    cQuery := ChangeQuery(cQuery)

    MPSysOpenQuery(cQuery, cAlias)
    (cAlias)->(dbGoTop())

    If !((cAlias)->(EoF()))
        aRet[1] := (cAlias)->TL_XSERVI
        aRet[2] := (cAlias)->TL_YURGENT
        aRet[3] := (cAlias)->TL_XJUSURG
    EndIf

    (cAlias)->(dbCloseArea())

Return aRet


/*/{Protheus.doc} fConteudoCampo
    Retorna o conteudo de um campo da estrutura recebida no ponto de entrada.
/*/
Static Function fConteudoCampo(aCampos, cCampo)

    Local nPos := aScan(aCampos, {|aCampo| AllTrim(aCampo[1]) == cCampo})

    If nPos > 0
        Return aCampos[nPos][2]
    EndIf

Return ""
