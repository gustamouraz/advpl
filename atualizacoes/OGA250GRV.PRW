#Include 'Protheus.ch'

User Function OGA250GRV()

    Local oModel := PARAMIXB[1] // Model referente ao OGA250
   // Local cPosModelo := PARAMIXB[2] 
   // Local cRotina := PARAMIXB[3] 
    Local lRetorno  := .T. 
    Local cChave    := FWFldGet("NJM_CHVNFE")
    Local cEntRom   := FWFldGet("NJM_CODENT")
    Local cMvEnt := Supergetmv("MV_XENTMAS")
    Local nQuant, nTotal := 0
    Local cNota, cSerie, cEmissao, cMsg ,cTipo, cClie, cLClie :=  ''
    Local _cFilBkp := cFilAnt
    Local aSM0Data1 := FWSM0Util():GetSM0Data( "01" , _cFilBkp , { "M0_CGC","M0_INSC","M0_FILIAL" } ) 
    Local _cLocal   := M->NJJ_LOCAL
    Local _cAutr    := M->NJJ_CODAUT
    Local _cCodctr  := M->NJJ_CODCTR //WSB
    Local _cLocAutr := Posicione("NJP",1,xFilial("NJP") +NJJ_CODCTR+NJJ_CODAUT,'NJP_XLOCAL')   
    //Local cIndEnt   := FWFldGet("NJM_CODENT") + FWFldGet("NJM_LOJENT")
    Local oModelNJJ   	:= oModel:GetModel( "NJJUNICO" )
    Default cMyalias2   := GetNextAlias()
    Local _nPosTIPO   := M->NJJ_TIPO //WSB
    Local _cRetUser := RetCodUsr() //WSB
    Local _cPosTrnf := Posicione("NJP",1,xFilial("NJP") +NJJ_CODCTR+NJJ_CODAUT,'NJP_ZTRCNF')  //WSB
    Local _nPosChavnf   := M->NJJ_ZCHVNF //WSB
    //LUIZ MOURA 03/03/2025 - AJUSTE PARA ATENDAR O CHAMADO 7084
    Local aTipos        := {} 
    Local cQuery        := "" 
    Local cAlias        := ""
    //

    if cEntRom $ cMvEnt
        if !Empty(cChave)  .AND. oModelNJJ:GetValue("NJJ_TPFORM") != '1'
            DbSelectArea('SF2')
            SF2->(DbSetOrder(17)) // F2_CHVNFE
            If SF2->(DbSeek(cChave))
                cNota       := SF2->F2_DOC
                cSerie      := SF2->F2_SERIE
                cEmissao    := SF2->F2_EMISSAO
                cTipo       := SF2->F2_TIPO
                cClie       := SF2->F2_CLIENTE
                cLClie      := SF2->F2_LOJA

                    BeginSql alias cMyAlias2	
                    %noparser%  	
                    SELECT 
                    SUM(D2_QUANT) AS QTD, SUM(D2_TOTAL) AS TOTAL
                    FROM SD2010 WHERE 
                        D2_DOC      = %EXP:cNota%               AND 
                        D2_SERIE    = %EXP:cSerie%              AND 
                        D2_FILIAL   = %EXP:SF2->F2_FILIAL%      AND
                        SD2010.D_E_L_E_T_ = ''
                    EndSql
                    (cMyAlias2)->(DbGoTop())

            
                    nQuant :=   (cMyAlias2)->QTD
                    nTotal :=   (cMyAlias2)->TOTAL

            else
                MsgAlert("Chave não Localizada!, Favor corrigir.","Atenção")
                lRetorno := .F.
                Return lRetorno
            endif
    IF _cFilBkp <> '020101'
        IF cTipo $ 'B' .OR. cTipo $ 'D'
            IF _cFilBkp <> Posicione("SA2",1,xFilial("SA2") +cClie + cLClie,'A2_FILTRF'  )

                cMsg := "Chave divergente com Filial"                                                       + CRLF 
                cMsg += "Filial Informada: " + _cFilBkp + '-' + aSM0Data1[3][2]
                cMsg += "Filial Correta: " + Posicione("SA2",1,xFilial("SA2") +cClie + cLClie,'A2_FILTRF') + " - " +Posicione("SA2",1,xFilial("SA2") +cClie + cLClie,'A2_NREDUZ') + CRLF 
                MsgAlert(cMsg,"Atenção")
                lRetorno := .F.
                Return lRetorno
            endif
        else
            IF _cFilBkp <> Posicione("SA1",1,xFilial("SA1") +cClie + cLClie,'A1_FILTRF'  )

                cMsg := "Chave divergente com Filial"      + CRLF  
                cMsg += "Filial Informada: " + _cFilBkp + '-' + aSM0Data1[3][2]                                                 + CRLF 
                cMsg += "Filial Correta: " + Posicione("SA1",1,xFilial("SA1") +cClie + cLClie,'A1_FILTRF'  ) + " - " +Posicione("SA1",1,xFilial("SA1") +cClie + cLClie,'A1_NREDUZ') + CRLF 
                MsgAlert(cMsg,"Atenção")
                lRetorno := .F.
                Return lRetorno
            endif
        endif
    endif


        IF FWFldGet("NJM_QTDFIS") <> nQuant
            cMsg := "Quantidade Fiscal Divergente!"  + CRLF 
            cMsg += "Origem: " + cvaltochar(nQuant) + CRLF 
            cMsg += "Informado: " + cvaltochar(FWFldGet("NJM_QTDFIS"))  + CRLF 
            MsgAlert(cMsg,"Atenção")
            lRetorno := .F.
            Return lRetorno
        endif
        IF FWFldGet("NJM_DOCNUM") <> cNota
            cMsg := "Numero da Nota Fiscal Divergente!"  + CRLF 
            cMsg += "Origem: " + cNota + CRLF 
            cMsg += "Informado: " + FWFldGet("NJM_DOCNUM")  + CRLF 
            MsgAlert(cMsg,"Atenção")
            lRetorno := .F.
            Return lRetorno
        endif
        IF FWFldGet("NJM_DOCSER") <> cSerie
            cMsg := "Serie da Nota Fiscal Divergente!"  + CRLF 
            cMsg += "Origem: " + cSerie + CRLF 
            cMsg += "Informado: " + FWFldGet("NJM_DOCSER")  + CRLF 
            MsgAlert(cMsg,"Atenção")
            lRetorno := .F.
            Return lRetorno
        endif
        IF DTOS(FWFldGet("NJM_DOCEMI")) <> DTOS(cEmissao)
            cMsg := "Emissão da Nota Fiscal Divergente!"  + CRLF 
            cMsg += "Origem: " + cvaltochar(cEmissao) + CRLF 
            cMsg += "Informado: " + cvaltochar(FWFldGet("NJM_DOCEMI"))  + CRLF 
            MsgAlert(cMsg,"Atenção")
            lRetorno := .F.
            Return lRetorno
        endif
        IF ROUND(FWFldGet("NJM_VLRTOT"),2) <> nTotal
            cMsg := "Emissão da Nota Fiscal Divergente!"  + CRLF 
            cMsg += "Origem: R$ " + cValToChar(nTotal) + CRLF 
            cMsg += "Informado: R$ " + cValToChar(FWFldGet("NJM_VLRTOT"))  + CRLF 
            MsgAlert(cMsg,"Atenção")
            lRetorno := .F.
            Return lRetorno
        endif
        endif

    endif

   //valida local de estoque NJJ x NJP 
    IF _cLocal <> _cLocAutr .AND. !Empty(_cAutr)
        MsgAlert('Local de estoque deve ser o mesmo informado na Autorizacao de Embarque: '+_cLocAutr, 'OGA250GRV') 
        lRetorno := .F.
    EndIF

    //Valida TROCA NF Wendeo Barreto
    IF _cPosTrnf =='S' .AND. Empty(_nPosChavnf) .AND. !Empty(_cAutr)
        MsgAlert('Por gentileza, informar a chave relacionado a troca de nota codigo do contrato '+_cCodctr +_cAutr, 'OGA250GRV') 
        lRetorno := .F.
    EndIF

    //justificativa de pesagem manual
    IF (M->NJJ_MODPS1 ='M' .OR. M->NJJ_MODPS2 ='M') .AND. M->NJJ_TIPENT != "2" //QUANDO FOR PESAGEM MANUAL E NÃO FOR ROMANEIO SEM PESAGEM
        WHILE !(U_JUSPES(cAlias))
    		MsgInfo("Informar uma justicativa de pesagem manual","Alerta")
    	ENDDO
    EndIf

    //LUIZ MOURA 03/03/2025 - AJUSTE PARA ATENDAR O CHAMADO 7084

    cQuery := " SELECT DISTINCT ZZB.ZZB_TIPO   "
    cQuery += " FROM ZZB010 ZZB WITH(NOLOCK)  "
    cQuery += " WHERE D_E_L_E_T_ = ''"
    cAlias := GetNextAlias()

    MPSysOpenQuery(cQuery , cAlias)

    While (cAlias)->(!eof())		
        aAdd(aTipos, (cAlias)->ZZB_TIPO)
        (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(DbCloseArea())

    IF aScan(aTipos ,M->NJJ_TIPO ) > 0 
    //
        //Wendel Barreto 14/10/2024 validação ZZB
        // IF M->NJJ_TIPO ='9'
        DbSelectArea("ZZB")
        ZZB->(DbSetOrder(1))
        ZZB->(DbGoTop())

    //Realiza a busca na tabela ZZB
        If ZZB->(DbSeek(xFilial("ZZB") + _cRetUser + _nPosTIPO))
            //Verifica se o registro encontrado corresponde ao usuário e ao tipo de romaneio
            If ZZB->ZZB_USER == __cUserId .AND. ZZB->ZZB_TIPO == _nPosTIPO
            Else
            MsgAlert('Usuário sem permissão para incluir romaneio do tipo '+M->NJJ_TIPO+' '+AllTrim(Posicione("SX5",1,xFilial("SX5")+"K5"+M->NJJ_TIPO,"X5_DESCRI"))+'.'+CRLF+'Entre em contato com time CSC - FISCAL', 'ATENÇÃO')
                Return 
            EndIf
        Else
            MsgAlert('Usuário sem permissão para incluir romaneio do tipo '+M->NJJ_TIPO+' '+AllTrim(Posicione("SX5",1,xFilial("SX5")+"K5"+M->NJJ_TIPO,"X5_DESCRI"))+'.'+CRLF+'Entre em contato com time CSC - FISCAL', 'ATENÇÃO')
            Return 
        EndIf
    EndIf

    //Valida se for entrada na filial (MV_ZCTFILR) campo NJJ_XCTE e NJJ_CODTRA deve ser preenchido quando for tipo Entrada - Luiz Moura 12/12/2025
    If (Empty(M->NJJ_XCTE) .OR. Empty(M->NJJ_CODTRA)) .AND. cFilAnt $ SuperGetMv("MV_ZCTFILR", .F., "020101") .AND. LEFT(Posicione("SX5",1,xFilial("SX5")+"K5"+M->NJJ_TIPO,"X5_DESCRI"),3) == "(E)"
        MsgAlert('Por gentileza, informar o CTe e o Código do Transportador para entrada na filial '+cFilAnt, 'OGA250GRV') 
        lRetorno := .F.
    EndIf


Return lRetorno
