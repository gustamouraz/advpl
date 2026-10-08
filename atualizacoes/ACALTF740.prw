#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} User Function ZALTF740
    (Altera em lote as contas a receber, a partir da query)
    @type  Function
    @author André Claro
    @since 12/2024
/*/


//	aAdd( aRotina,{ "Alterar em lote", "U_ZALTF750" , 0 , 4})
User Function ACALTF740()

    Local cPerg     := "ALTF750"
    Local cQuery    := ""
    Local nTotal    := 0
    Local aTipo     := {}
    Local nFor1
    Local oTempTable
    Local aCampos   := {}
    Local lMarcar  	:= .F.
    Local oBrowse 	:= Nil

    If !Pergunte(cPerg,.T.)
        Return
    Endif

    aTipo := STRTOKARR(MV_PAR05,";")

    cQuery := "SELECT SE1.E1_FILIAL,SE1.E1_EMISSAO,SE1.E1_CLIENTE,SE1.E1_LOJA,SA1.A1_NOME,SA1.A1_CGC,SE1.E1_PREFIXO,SE1.E1_TIPO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_VENCTO,"+CRLF
    cQuery += "SE1.E1_MOEDA,SE1.E1_VALOR,SE1.E1_SALDO,SE1.E1_HIST,SE1.E1_XCTRPAI,SE1.E1_CODBAR,SE1.E1_PORTADO, SE1.E1_XCGC E1_XCNPJ, SE1.E1_XNATUR, '' AS E1_YNOMCON, SE1.E1_NATUREZ, SA1.A1_BCO1 AS A1_BANCO, SA1.A1_CGC AS A1_XCGC, SE1.E1_USERLGI, SE1.E1_USERLGA"+CRLF
    cQuery += "FROM "+RETSQLNAME("SE1")+" SE1"+CRLF
    cQuery += "JOIN "+RETSQLNAME("SA1")+" SA1"+CRLF
    cQuery += "ON SE1.E1_CLIENTE=SA1.A1_COD AND SE1.E1_LOJA=SA1.A1_LOJA"+CRLF
    cQuery += "WHERE SE1.D_E_L_E_T_=' ' AND SA1.D_E_L_E_T_=' '"+CRLF
    cQuery += " AND SE1.E1_FILIAL >="+VALTOSQL(xFilial("SE1",MV_PAR01))+CRLF
    cQuery += " AND SE1.E1_FILIAL <="+VALTOSQL(xFilial("SE1",MV_PAR02))+CRLF
    cQuery += " AND SE1.E1_VENCTO >="+VALTOSQL(DTOS(MV_PAR03))+CRLF
    cQuery += " AND SE1.E1_VENCTO <="+VALTOSQL(DTOS(MV_PAR04))+CRLF

    FOR nFor1 := 1 to Len(aTipo)
        cQuery += " AND SE1.E1_TIPO <>"+VALTOSQL(aTipo[nFor1])+CRLF
    NEXT nFor1

    IF !EMPTY(MV_PAR06)
        cQuery += " AND SE1.E1_HIST NOT LIKE "+VALTOSQL(Alltrim(UPPER(MV_PAR06)))+CRLF
    ENDIF

    IF (MV_PAR07) == 1
        cQuery += " AND SE1.E1_SALDO > 0"
    ELSE
        cQuery += " AND SE1.E1_SALDO = 0"
    ENDIF

    IF (MV_PAR08) == 1
        cQuery += " AND SE1.E1_NUMBOR <>' '"
    ELSE
        cQuery += " AND SE1.E1_NUMBOR =' '"
    ENDIF

    IF SELECT('cAlias') > 0
        Dbselectarea('cAlias')
        cAlias->(DbClosearea())
    ENDIF

    TcQuery cQuery New Alias cAlias
    Count To nTotal
    cAlias->(DbGoTop())

    //Criar a tabela temporária
    AADD(aCampos, {'TRB_OK'     , 'C', 002, 0})
    AADD(aCampos, {'E1_FILIAL'  , 'C', 004, 0})
    AADD(aCampos, {'E1_EMISSAO' , 'D', 008, 0})
    AADD(aCampos, {'E1_CLIENTE' , 'C', 006, 0})
    AADD(aCampos, {'E1_LOJA'    , 'C', 002, 0})
    AADD(aCampos, {'A1_NOME'    , 'C', 040, 0})
    AADD(aCampos, {'A1_CGC'     , 'C', 014, 0})
    AADD(aCampos, {'E1_TIPO'    , 'C', 003, 0})
    AADD(aCampos, {'E1_PREFIXO' , 'C', 009, 0})
    AADD(aCampos, {'E1_NUM'     , 'C', 009, 0})
    AADD(aCampos, {'E1_PARCELA' , 'C', 003, 0})
    AADD(aCampos, {'E1_VENCTO'  , 'D', 008, 0})
    AADD(aCampos, {'E1_MOEDA'   , 'N', 002, 0})
    AADD(aCampos, {'E1_VALOR'   , 'N', 016, 2})
    AADD(aCampos, {'E1_SALDO'   , 'N', 016, 2})
    AADD(aCampos, {'E1_HIST'    , 'C', 040, 0})
    AADD(aCampos, {'E1_CODBAR'  , 'C', 044, 0})
    AADD(aCampos, {'E1_PORTADO' , 'C', 003, 0})
    AADD(aCampos, {'E1_XCNPJ'   , 'C', 014, 0})
    AADD(aCampos, {'E1_XNATUR'  , 'C', 050, 0})
    AADD(aCampos, {'E1_YNOMCON' , 'C', 040, 0})
    AADD(aCampos, {'E1_NATUREZ' , 'C', 010, 0})
    AADD(aCampos, {'E1_XBANCO'  , 'C', 003, 0})
    AADD(aCampos, {'E1_XCGC'    , 'C', 018, 0})
    AADD(aCampos, {'E1_USERLGI' , 'C', 017, 0})
    AADD(aCampos, {'E1_USERLGA' , 'C', 017, 0})
    AADD(aCampos, {'E1_XCTRPAI' , 'C', 012, 0})

    

    IF SELECT('TRB') > 0
        Dbselectarea('TRB')
        TRB->(DbClosearea())
    ENDIF
    oTempTable:= FWTemporaryTable():New("TRB")
    oTempTable:SetFields( aCampos )
    oTempTable:Create()

    WHILE cAlias->(!EOF())
        IF RecLock("TRB",.T.)
            TRB->TRB_OK      := ''
            TRB->E1_FILIAL   := cAlias->E1_FILIAL
            TRB->E1_EMISSAO  := StoD(cAlias->E1_EMISSAO)
            TRB->E1_CLIENTE  := cAlias->E1_CLIENTE
            TRB->E1_LOJA     := cAlias->E1_LOJA
            TRB->A1_NOME     := cAlias->A1_NOME
            TRB->A1_CGC      := cAlias->A1_CGC
            TRB->E1_TIPO     := cAlias->E1_TIPO
            TRB->E1_PREFIXO  := cAlias->E1_PREFIXO
            TRB->E1_NUM      := cAlias->E1_NUM
            TRB->E1_PARCELA  := cAlias->E1_PARCELA
            TRB->E1_VENCTO   := StoD(cAlias->E1_VENCTO)
            TRB->E1_MOEDA    := cAlias->E1_MOEDA
            TRB->E1_VALOR    := cAlias->E1_VALOR
            TRB->E1_SALDO    := cAlias->E1_SALDO
            TRB->E1_HIST     := cAlias->E1_HIST
            TRB->E1_CODBAR   := cAlias->E1_CODBAR
            TRB->E1_PORTADO  := cAlias->E1_PORTADO
            TRB->E1_XCNPJ    := cAlias->E1_XCNPJ
            TRB->E1_XNATUR   := cAlias->E1_XNATUR
            TRB->E1_YNOMCON  := cAlias->E1_YNOMCON
            TRB->E1_NATUREZ  := cAlias->E1_NATUREZ
            TRB->E1_XBANCO   := cAlias->A1_BANCO
            TRB->E1_XCGC     := cAlias->A1_XCGC
            TRB->E1_XCTRPAI  := cAlias->E1_XCTRPAI
            TRB->E1_USERLGI  := UsrRetName(SUBSTRING(cAlias->E1_USERLGI, 11,1)+SUBSTRING(cAlias->E1_USERLGI, 15,1)+ SUBSTRING(cAlias->E1_USERLGI, 2, 1)+SUBSTRING(cAlias->E1_USERLGI, 6, 1)+ SUBSTRING(cAlias->E1_USERLGI, 10,1)+SUBSTRING(cAlias->E1_USERLGI, 14,1)+ SUBSTRING(cAlias->E1_USERLGI, 1, 1)+SUBSTRING(cAlias->E1_USERLGI, 5, 1)+ SUBSTRING(cAlias->E1_USERLGI, 9, 1)+SUBSTRING(cAlias->E1_USERLGI, 13,1)+ SUBSTRING(cAlias->E1_USERLGI, 17,1)+SUBSTRING(cAlias->E1_USERLGI, 4, 1)+ SUBSTRING(cAlias->E1_USERLGI, 8, 1))
            TRB->E1_USERLGA  := UsrRetName(SUBSTRING(cAlias->E1_USERLGA, 11,1)+SUBSTRING(cAlias->E1_USERLGA, 15,1)+ SUBSTRING(cAlias->E1_USERLGA, 2, 1)+SUBSTRING(cAlias->E1_USERLGA, 6, 1)+ SUBSTRING(cAlias->E1_USERLGA, 10,1)+SUBSTRING(cAlias->E1_USERLGA, 14,1)+ SUBSTRING(cAlias->E1_USERLGA, 1, 1)+SUBSTRING(cAlias->E1_USERLGA, 5, 1)+ SUBSTRING(cAlias->E1_USERLGA, 9, 1)+SUBSTRING(cAlias->E1_USERLGA, 13,1)+ SUBSTRING(cAlias->E1_USERLGA, 17,1)+SUBSTRING(cAlias->E1_USERLGA, 4, 1)+ SUBSTRING(cAlias->E1_USERLGA, 8, 1))
            TRB->(MsUnLock())
        ENDIF
        cAlias->(DbSkip())
    ENDDO

    TRB->(DbGoTop())

    IF TRB->(!Eof())

        //Agora iremos usar a classe FWMarkBrowse
        oBrowse:= FWMarkBrowse():New()
        oBrowse:oBrowse:ForceQuitButton(.T.)
        oBrowse:SetMenuDef("")
        oBrowse:SetIgnoreARotina(.T.)
        oBrowse:SetDescription("Seleção das contas para alteração") //Titulo da Janela
        oBrowse:SetAlias("TRB") //Indica o alias da tabela que será utilizada no Browse
        oBrowse:SetFieldMark("TRB_OK") //Indica o campo que deverá ser atualizado com a marca no registro
        oBrowse:oBrowse:SetDBFFilter(.T.)
        oBrowse:oBrowse:SetUseFilter(.T.) //Habilita a utilização do filtro no Browse
        oBrowse:oBrowse:SetFixedBrowse(.T.)
        oBrowse:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
        oBrowse:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
        oBrowse:SetTemporary() //Indica que o Browse utiliza tabela temporária
        oBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse



        //Adiciona uma coluna no Browse em tempo de execução
        oBrowse:SetColumns({{'FILIAL'      ,{|| TRB->E1_FILIAL }  ,, "@!",,004,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'PREFIXO'     ,{|| TRB->E1_PREFIXO } ,, "@!",,009,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'NUM'         ,{|| TRB->E1_NUM }     ,, "@!",,009,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'PARCELA'     ,{|| TRB->E1_PARCELA } ,, "@!",,002,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'EMISSAO'     ,{|| TRB->E1_EMISSAO } ,, ""  ,,008,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'VENCIMENTO'  ,{|| TRB->E1_VENCTO }  ,, ""  ,,008,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'VALOR'       ,{|| TRB->E1_VALOR }   ,, "@E 9,999,999,999,999.99",,016,2,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'SALDO'       ,{|| TRB->E1_SALDO }   ,, "@E 9,999,999,999,999.99",,016,2,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'HISTORICO'   ,{|| TRB->E1_HIST }    ,, "@!",,040,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'COD. NATUREZA',{|| TRB->E1_NATUREZ },, "@!",,010,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'COD. FORNEC' ,{|| TRB->E1_CLIENTE } ,, "@!",,006,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'LOJA'        ,{|| TRB->E1_LOJA }    ,, "@!",,002,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'NOME FORNEC' ,{|| TRB->A1_NOME }    ,, "@!",,040,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'CNPJ FORNEC' ,{|| TRB->A1_CGC }     ,, "@R 99.999.999/9999-99",,014,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'MOEDA'       ,{|| TRB->E1_MOEDA }   ,, "@!",,002,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'TIPO'        ,{|| TRB->E1_TIPO }    ,, "@!",,003,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'COD. BARRAS' ,{|| TRB->E1_CODBAR }  ,, "@!",,044,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'BCO. DEP'    ,{|| TRB->E1_XBANCO }  ,, "@!",,003,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'CNPJ/CPF DEP',{|| TRB->E1_XCGC }    ,, "@R 99.999.999/9999-99",,018,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'E1_PORTADO'  ,{|| TRB->E1_PORTADO } ,, "@!",,003,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'E1_XCNPJ'    ,{|| TRB->E1_XCNPJ  }  ,, "@R 99.999.999/9999-99",,014,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'E1_XNATUR'   ,{|| TRB->E1_XNATUR }  ,, "@!",,050,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'E1_YNOMCON'  ,{|| TRB->E1_YNOMCON}  ,, "@!",,040,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'User Inc'    ,{|| TRB->E1_USERLGI}  ,,     ,,017,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'User Alt'    ,{|| TRB->E1_USERLGA}  ,,     ,,017,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})
        oBrowse:SetColumns({{'Contrato Pai'   ,{|| TRB->E1_XCTRPAI }  ,, "@!",,015,0,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,}})

        

        //Adiciona botoes na janela
        oBrowse:AddButton("CONFIRMAR", {||FwMsgRun(NIL, {|oSay| AltCheck(oSay,@oBrowse)}, "Processando", "Selecionando os registros...")})
        oBrowse:AddButton("FECHAR" , {|| CloseBrowse()})


        //Indica o Code-Block executado no clique do header da coluna de marca/desmarca
        oBrowse:bAllMark := { || MCFG6Invert(oBrowse:Mark(),lMarcar := !lMarcar ), oBrowse:Refresh(.T.)  }


        //Método de ativação da classe
        oBrowse:Activate()

        oBrowse:oBrowse:Setfocus() //Seta o foco na grade
    ELSE
        MsgInfo("Listagem Vazio. Favor verificar os parâmetros informados", "ALERTA")
        Return
    ENDIF
Return

Static Function AltCheck(oSay, oBrowse)

    Local aMark     := {}
    Local oButton1
    Local oButton2
    Local oComboBo1
    Local oComboBo2
    Local oGroup1
    Local oGroup2
    Local oSay1
    Local oSay2
    Private oDlg
    Private cComboBo1
    Private cComboBo2
    Private oGet1
    Private oGet2
    Private dGet1     := Date()
    Private cGet2     := Space(40)

    TRB->(DbGoTop())
    WHILE TRB->(!EOF())
        IF oBrowse:IsMark(oBrowse:Mark())
            AADD(aMark,{PADR(Alltrim(TRB->E1_FILIAL),TamSX3("E1_FILIAL")[1])+PADR(Alltrim(TRB->E1_PREFIXO),TamSX3("E1_PREFIXO")[1])+PADR(Alltrim(TRB->E1_NUM),TamSX3("E1_NUM")[1])+PADR(Alltrim(TRB->E1_PARCELA),TamSX3("E1_PARCELA")[1])+PADR(Alltrim(TRB->E1_TIPO),TamSX3("E1_TIPO")[1])+PADR(Alltrim(TRB->E1_CLIENTE),TamSX3("E1_CLIENTE")[1])+PADR(Alltrim(TRB->E1_LOJA),TamSX3("E1_LOJA")[1])})
        ENDIF
        TRB->(DbSkip())
    ENDDO



    DEFINE MSDIALOG oDlg TITLE "ALTERAR EM LOTE" FROM 000, 000  TO 320, 480 COLORS 0, 16777215 PIXEL

    @ 130, 144 BUTTON oButton1 PROMPT "CONFIRMAR" SIZE 037, 012 OF oDlg ACTION fAltera(aMark) PIXEL
    @ 130, 101 BUTTON oButton2 PROMPT "CANCELAR" SIZE 037, 012 OF oDlg ACTION oDlg:end() PIXEL
    @ 015, 034 GROUP oGroup1 TO 058, 185 PROMPT "Vencimento" OF oDlg COLOR 0, 16777215 PIXEL
    @ 069, 034 GROUP oGroup2 TO 123, 185 PROMPT "Histórico" OF oDlg COLOR 0, 16777215 PIXEL
    @ 039, 100 MSGET oGet1 VAR dGet1 SIZE 065, 010 OF oDlg VALID DataValida() WHEN ZWHEN(1) COLORS 0, 16777215 HASBUTTON PIXEL
    @ 041, 043 SAY oSay1 PROMPT "Data de Vencimento" SIZE 057, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 025, 043 MSCOMBOBOX oComboBo1 VAR cComboBo1 ITEMS {"1=SIM","2=NAO"} SIZE 035, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 081, 043 MSCOMBOBOX oComboBo2 VAR cComboBo2 ITEMS {"1=SIM","2=NAO"} SIZE 035, 010 OF oDlg COLORS 0, 16777215 ON CHANGE {||IIF(cComboBo2=="2",oGet2:lReadOnly:=.F.,oGet2:lReadOnly:=.T.),oGet2:Refresh()} PIXEL
    @ 100, 042 SAY oSay2 PROMPT "Histórico" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 099, 072 MSGET oGet2 VAR cGet2 SIZE 104, 010 OF oDlg PICTURE "@!" WHEN ZWHEN(2) COLORS 0, 16777215 PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

Return

Static Function fAltera(aMark)

    Local nFor1
    Local aErro := {}
    Local cErro := ""

    SE1->(DbSetOrder(1))
    FOR nFor1 := 1 to Len(aMark)
        IF SE1->(DbSeek(aMark[nFor1][1]))
            IF DtoS(SE1->E1_EMISSAO)<DtoS(dGet1) .and. DtoS(SE1->E1_VENCTO) <= DtoS(dGet1)
                IF cComboBo1=="1"
                    RecLock("SE1", .F.)
                    //SE1->E1_VENCTO  := dGet1
                    If FieldPos("E1_XPREAGE") > 0
                        SE1->E1_XPREAGE := 'S'
                    EndIf
                    SE1->E1_VENCREA := DataValida(dGet1,.T.)
                    SE1->(MsUnlock())
                ENDIF
                IF cComboBo2=="1"
                    RecLock("SE1", .F.)
                    SE1->E1_HIST    := cGet2
                    SE1->(MsUnlock())
                ENDIF 
            ELSE
                AADD(aErro,{"Filial:"+SE1->E1_FILIAL+" Num: "+SE1->E1_NUM+" Parcela: "+SE1->E1_PARCELA+" Forn: "+SE1->E1_CLIENTE+" "+SE1->E1_LOJA+CRLF})
            ENDIF
        ELSE
            AADD(aErro, "Chave: "+aMark[nFor1][1])
        ENDIF
    NEXT nFor1

    IF !EMPTY(aErro)
        cErro := ArrTokStr(aErro)
        cErro := StrTran(cErro,"|",+CRLF)
        MsgInfo("As contas a seguir não puderam ser alteradas. Favor verificar."+CRLF+cErro, "ALERTA")
    ENDIF

    oDlg:end()
    CloseBrowse()


Return

Static Function ZWHEN(nGET)

    lRet := .T.
    IF nGET==1
        IF cComboBo1=="2"
            lRet := .F.
        ENDIF
    ELSEIF nGet==2
        IF cComboBo2=="2"
            lRet := .F.
        ENDIF
    ENDIF

Return lRet




/*/{Protheus.doc} User Function MCFG6Invert
    (Altera em lote as contas a pagar, a partir da query)
    @type  Function
    @author Luan Woichechoscki
    @since 17/10/2022
    @param lMarca, Logic, informa se o check está marcado ou não
/*/
Static Function MCFG6Invert(cMarca,lMarcar)
    Local cAlias := 'TRB'
    Local aArea  := (cAlias)->( GetArea() )

    dbSelectArea(cAlias)
    (cAlias)->( dbGoTop() )
    While !(cAlias)->( Eof() )
        RecLock( (cAlias), .F. )
        (cAlias)->TRB_OK := IIf( lMarcar, cMarca, '  ' )
        (cAlias)->(MsUnlock())
        (cAlias)->( dbSkip() )
    EndDo

    RestArea( aArea )
Return .T.
