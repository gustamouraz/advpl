#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#include 'parmtype.ch'

/*
@Autor:     André Claro 35 99877-5495
@Data:      26/05/21
@Descrição: Ponto de entrada para permitir ou não confirmar o romaneio.
*/

User Function OG250NFVD
    Local _cFatAgrp := GetAdvFVal("NJR","NJR_ZFATAG",NJJ->(PadR(SubString(NJJ_FILIAL,1,4),6," ")+NJJ_CODCTR),1,"")
    Local cFilPed	:= PARAMIXB[1]
    Local cNumRom	:= PARAMIXB[2]
    Local lRet 		:= .T.
    Local cProd     := Posicione("NJJ",1,cFilPed + cNumRom,"NJJ_CODPRO")
    Local cTpRom    := Posicione("NJJ",1,cFilPed + cNumRom,"NJJ_TIPO")
    Local cQtd      := Posicione("NJJ",1,cFilPed + cNumRom,"NJJ_PESO3")
    Local cLocal    := Posicione("NJJ",1,cFilPed + cNumRom,"NJJ_LOCAL")
    Local cTotal    := Posicione("SB2",1,cFilPed + cProd + cLocal,"B2_QATU")
    Local cEmp      := Posicione("SB2",1,cFilPed + cProd + cLocal,"B2_RESERVA")
    Local cTabctr   := Posicione("NJR",1,FWxFilial('NJR')+NJJ_CODCTR, "NJR_TABELA")
    Local cLiq
    Local cTesRom    := Posicione("NJJ",1,cFilPed + cNumRom,"NJJ_TES")
    Local cMovEst    := Posicione("SF4",1,xFilial("SF4")+ cTesRom ,"F4_ESTOQUE")
    Local cTipoEnt  := "2;4;6;8;B"
    Local cMsg      := ""

    IF NJJ_TABELA <> cTabctr
                Aviso("Corrija as Divergencias!" , "Tabela de desconto divergente com o Contrato!"+CRLF + "Tabela do Contrato: " + cTabctr , {"Sair"}, 1)
                Return .F.
    endif

    cLiq := cTotal - cEmp

    IF cTpRom $ cTipoEnt
        IF cMovEst == 'S'
            if cQtd > cLiq
                cMsg += "Estoque Atual : " + cValToChar(cTotal) +CRLF
                cMsg += "Reserva : " + cValToChar(cEmp) + CRLF 
                cMsg += "Saldo (Atual - Reserva) : " + cValToChar(cLiq) +CRLF 
                cMsg += "Peso do Romaneio : " + cValToChar(cQtd) +CRLF 
                if cEmp > 0 
                    cMsg += "Verificar Pedidos Pendentes ou Confirmados Parcialmente"             
                else   
                cMsg += "Saldo Insuficiente"
                endif

                ShowHelpDlg( "Atenção", { "Nao sera possivel a Confirmação do Romaneio" }, 5, {  cMsg }, 5 )
            //Alert("Não serÃ¡ possÃ­vel confirmar o romaneio pois não existe saldo disponivel para o produto informado!")
                lRet := .F.
                Return lRet
            endIf
        endIf
    endIf	

    If _cFatAgrp == "S" 
        U_ZGERFATF()
        lRet := .F. 
    EndIf
    IF !(FPMOD())
        lRet := .F.
    EndIf
    
Return lRet

Static Function FPMOD()
    Local iRet := .T.
    Local cMvEnt := Supergetmv("MV_XENTMAS")
    Local cTpRom := Supergetmv("MV_XTPROM")
    Local cUmidade  := Posicione("NJK",1,NJJ_FILIAL+NJJ_CODROM+'0011', "NJK_PERDES")
    Local cImpureza := Posicione("NJK",1,NJJ_FILIAL+NJJ_CODROM+'0021', "NJK_PERDES")
    Local cAvariado := Posicione("NJK",1,NJJ_FILIAL+NJJ_CODROM+'0031', "NJK_PERDES")
    Local cOutros   := Posicione("NJK",1,NJJ_FILIAL+NJJ_CODROM+'0041', "NJK_PERDES")
    Local nPeso     := NJJ_PSSUBT
    Local cIndEnt   := NJJ_CODENT + NJJ_LOJENT 
    Local cChave    := NJJ_CHVNFE
    Local cMsg      := ""
    lOCAL lAgro     := .F.
    Local cFilDest  := NJJ_FILIAL
    Local cRomDest  := NJJ_CODROM
    
    Default cMyAlias	:= GetNextAlias()

    IF NJJ_CODENT $  cMvEnt .AND. NJJ_TIPO $ cTpRom .AND. NJJ->NJJ_TPFORM != '1'
        //Verifica se Existe a Chave na SF2
        DbSelectArea('SF2')
        SF2->(DbSetOrder(17)) // F2_CHVNFE
        If !(SF2->(DbSeek(cChave)))
            cMsg := "Chave não localizada na Origem " +CRLF 
            cMsg += cChave 
            Alert(cMsg)
            iRet := .F.
            Return iRet
        else
            cFilNf  := SF2->F2_FILIAL
            cNf     := SF2->F2_DOC
            cSer    := SF2->F2_SERIE 
            //Verifica se é Compartilhamento de Produção
            cIndideC6 := cFilNf + cNf + cSer
                DbSelectArea('SC5')
                SC5->(DbSetOrder(1)) // Filial + Nf + Serie
                If SC5->(DbSeek(cFilNf + Posicione("SC6",4,cIndideC6,"C6_NUM")))
                    IF alltrim(SC5->C5_ZEXCNF) = 'N'
                    //ALERT('Agro ' + SC5->C5_ZEXCNF)
                        lAgro := .T.                  
                    EndIf
                else
                    cMsg := "Não Foi localizado o Pedido de Origem."  + CRLF 
                    cMsg += "Filial: " + cFilNf  + CRLF
                    cMsg += "Nota: " + cNf     + CRLF
                    cMsg += "Serie: " + cSer    + CRLF 
                    ALERT(cMsg)
                EndIf
        EndIf
        SF2->(dbCloseArea())

        IF lAgro // Se for Compartilhamento de produção
            BeginSql alias cMyAlias	
                %noparser%  	
                    SELECT 
                        NJJ_FILIAL,
                        NJJ_CODROM
                    FROM NJJ010 
                    WHERE 
                        NJJ_DOCNUM  = %EXP:cNf%         AND 
                        NJJ_DOCSER  = %EXP:cSer%        AND
                        NJJ_ZFILDE = %EXP:cFilNf%      AND
                        NJJ_TIPO IN ('2','4','6','8')   AND 
                        NJJ010.D_E_L_E_T_ = ''
                EndSql	
        else
            BeginSql alias cMyAlias	
                %noparser%  	
                    SELECT 
                        NJJ_FILIAL,
                        NJJ_CODROM
                    FROM NJJ010 
                    WHERE 
                        NJJ_DOCNUM  = %EXP:cNf%        AND 
                        NJJ_DOCSER  = %EXP:cSer%       AND
                        NJJ_FILIAL =  %EXP:cFilNf%      AND
                        NJJ_TIPO IN ('2','4','6','8')  AND 
                        NJJ010.D_E_L_E_T_ = ''
            EndSql	
        EndIf
        (cMyAlias)->(DbGoTop())
        cIndiceNJM := (cMyAlias)->NJJ_FILIAL + (cMyAlias)->NJJ_CODROM
        If lAgro
        aSM0Data1 := FWSM0Util():GetSM0Data( "01" , cFilNf , { "M0_CGC","M0_INSC","M0_FILIAL" } ) 
        else
        aSM0Data1 := FWSM0Util():GetSM0Data( "01" , (cMyAlias)->NJJ_FILIAL , { "M0_CGC","M0_INSC","M0_FILIAL" } ) 
        endif
        if lAgro 
        //Alert(cNf + cSer + cFilNf )
        endif
        DBSelectArea("NJM")
            NJM->(DBSetOrder(1))
            IF NJM->(DBSeek(cIndiceNJM + '01'))    
                    DBSelectArea("NJ0")
                    NJ0->(DBSetOrder(1))
                    IF NJ0->(DBSeek(xFilial("NJ0") + cIndEnt))
                            IF AllTrim(aSM0Data1[1][2]) = Alltrim(NJ0->NJ0_CGC) .AND.  AllTrim(aSM0Data1[2][2]) = Alltrim(NJ0->NJ0_INSCR)
                                If NJM->(RecLock("NJM",.F.))
                                    NJM->NJM_XOUTRO := cOutros
                                    NJM->NJM_XAVARI := cAvariado
                                    NJM->NJM_XIMPUR := cImpureza
                                    NJM->NJM_XUMIDA := cUmidade
                                    NJM->NJM_XPEDES := nPeso
                                    NJM->NJM_XDTREC := Date()
                                    NJM->NJM_XHRREC := SubStr(FwTimeUF("RO")[2],1,5)
                                    NJM->NJM_XROMDE := cRomDest
                                    NJM->NJM_XFILDE := cFilDest
                                    NJM->NJM_XDIFPE := NJM->NJM_QTDFCO - nPeso
                                    NJM->(Msunlock())
                                    MsgInfo("Os dados de Peso e Qualidade foram Gravados na Origem!")           
                                EndIf           
                            else            
                                cMsg := "A Entidade do Romaneio não consiste com a Empresa de Origem"   + CRLF                         + CRLF 
                                cMsg += "Entidade do Romaneio"                                                                          + CRLF 
                                cMsg += "-------------------------------------------------------------"                                 + CRLF 
                                cMsg += "Entidade: "                                                    + NJ0->NJ0_CODENT               + CRLF 
                                cMsg += "Loja: "                                                        + NJ0->NJ0_LOJENT               + CRLF 
                                cMsg += "Nome: "                                                         +NJ0->NJ0_NOME                 + CRLF 
                                cMsg += "CNPJ/CPF: "                                                    + NJ0->NJ0_CGC                  + CRLF 
                                cMsg += "Inscricao Estadual: "                                          + NJ0->NJ0_INSCR                + CRLF
                                cMsg += "-------------------------------------------------------------"                                 + CRLF 
                                cMsg += "Empresa de Origem da Nota Fiscal"                                                              + CRLF 
                                cMsg += "-------------------------------------------------------------"                                 + CRLF 
                                cMsg += "Empresa: "                                                     + aSM0Data1[3][2]               + CRLF
                                cMsg += "CNPJ: "                                                        + cvaltochar(aSM0Data1[2][2])   + CRLF
                                cMsg += "IE: "                                                          + cvaltochar(aSM0Data1[1][2])   + CRLF
                                MsgInfo(cMsg ,"Inconsistencia de Entidade")
                                iRet := .F.
                            ENDIF
                    else
                        MsgInfo("Entidade Nao Localizada","Inconsistencia de Entidade")
                        iRet := .F.
                    ENDIF    
            else
                MsgInfo("Não foi Localizado o Romaneio de Origem , Favor verificar!","Chave Divergente")
                iRet := .F.
            ENDIF
        
        SC5->(dbCloseArea())
        SC6->(dbCloseArea())
        NJM->(dbCloseArea())
        NJ0->(dbCloseArea())
    EndIf

Return iRet
