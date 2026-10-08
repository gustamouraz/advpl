#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#include 'parmtype.ch'

/*
@Autor:     AndrÃ© Claro 35 99877-5495
@Data:      26/05/21
@DescriÃ§Ã£o: Ponto de entrada para permitir ou nÃ£o confirmar o romaneio.
*/

User Function ATORIG()

Local cMvEnt := Supergetmv("MV_XENTMAS")
Local cTpRom := Supergetmv("MV_XTPROM")
Local cChave
Local cRom := NJJ_CODROM
Local cFil := NJJ_FILIAL
Local cCodEnt := NJJ_CODENT
Local cCodTp  := NJJ_TIPO
LOCAL lAgro     := .F.
Local cMsg      := ""
Local cMsg2     := ""
Local lChv      :=  .T.
Local iRet := .T.
Local cIndEnt   := ""
Local cUmidade  := Posicione("NJK",1,NJJ_FILIAL+NJJ_CODROM+'0011', "NJK_PERDES")
Local cImpureza := Posicione("NJK",1,NJJ_FILIAL+NJJ_CODROM+'0021', "NJK_PERDES")
Local cAvariado := Posicione("NJK",1,NJJ_FILIAL+NJJ_CODROM+'0031', "NJK_PERDES")
Local cOutros   := Posicione("NJK",1,NJJ_FILIAL+NJJ_CODROM+'0041', "NJK_PERDES")
Default cMyAlias	:= GetNextAlias()
Default cMyAlias2	:= GetNextAlias()
BeginSql alias cMyAlias	
%noparser%  	
SELECT 
NJM_CHVNFE,
NJM_QTDFCO,
NJM_CODENT,
NJM_LOJENT
FROM NJM010 NJM WITH(NOLOCK) 
WHERE 
    NJM.NJM_CODROM = %EXP:cRom% AND 
    NJM.NJM_FILIAL = %EXP:cFil% AND 
    NJM.D_E_L_E_T_ = ''
EndSql	
(cMyAlias)->(DbGoTop())

While (cMyAlias)->(!EOF())
cChave := (cMyAlias)->(NJM_CHVNFE)
nPeso  := (cMyAlias)->(NJM_QTDFCO)
cIndEnt := (cMyAlias)->(NJM_CODENT) + (cMyAlias)->(NJM_LOJENT)
    IF cCodEnt  $  cMvEnt .AND. cCodTp $ cTpRom
            //Verifica se Existe a Chave na SF2
            DbSelectArea('SF2')
            SF2->(DbSetOrder(17)) // F2_CHVNFE
            If !(SF2->(DbSeek(cChave)))
            IF lChv
                cMsg += "Chave não localizada na Origem " +CRLF 
            ENDIF
                cMsg += "---------------------------------------------------------"
                cMsg += cChave  +CRLF 
                lChv := .F.
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
                        ELSE    
                            lAgro := .F.              
                        EndIf
                    else
                        cMsg := "N�o Foi localizado o Pedido de Origem."  + CRLF 
                        cMsg += "Filial: " + cFilNf  + CRLF
                        cMsg += "Nota: " + cNf     + CRLF
                        cMsg += "Serie: " + cSer    + CRLF 
                        ALERT(cMsg)
                    EndIf
            EndIf
            SF2->(dbCloseArea())

        IF lAgro // Se for Compartilhamento de produção
            BeginSql alias cMyAlias2	
                %noparser%  	
                    SELECT 
                        NJJ_FILIAL,
                        NJJ_CODROM
                    FROM NJJ010 
                    WHERE 
                        NJJ_DOCNUM  = %EXP:cNf%         AND 
                        NJJ_DOCSER  = %EXP:cSer%        AND
                        NJJ_ZFILDE =  %EXP:cFilNf%      AND
                        NJJ_TIPO IN ('2','4','6','8')   AND 
                        NJJ010.D_E_L_E_T_ = ''
                EndSql	
        else
            BeginSql alias cMyAlias2	
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

    //===========================================
    /*IF lAgro 
        Alert(cNf + cSer + cFilNf + ' AGRO')
    else 
    Alert(cNf + cSer + cFilNf )
    endif
    */
        (cMyAlias2)->(DbGoTop())
        cIndiceNJM := (cMyAlias2)->NJJ_FILIAL + (cMyAlias2)->NJJ_CODROM
        If lAgro
        aSM0Data1 := FWSM0Util():GetSM0Data( "01" , cFilNf , { "M0_CGC","M0_INSC","M0_FILIAL" } ) 
        else
        aSM0Data1 := FWSM0Util():GetSM0Data( "01" , (cMyAlias2)->NJJ_FILIAL , { "M0_CGC","M0_INSC","M0_FILIAL" } ) 
        endif
        DBSelectArea("NJM")
            NJM->(DBSetOrder(1))
            IF NJM->(DBSeek(cIndiceNJM + '01'))    
                    DBSelectArea("NJ0")
                    NJ0->(DBSetOrder(1))
                    IF NJ0->(DBSeek(xFilial("NJ0") + cIndEnt))
                            IF AllTrim(aSM0Data1[1][2]) = Alltrim(NJ0->NJ0_CGC) .AND.  AllTrim(aSM0Data1[2][2]) = Alltrim(NJ0->NJ0_INSCR)
                                If NJM->(RecLock("NJM",.F.))
                                //ALERT("Achei esse "  + cIndiceNJM)
                                    NJM->NJM_XOUTRO := cOutros
                                    NJM->NJM_XAVARI := cAvariado
                                    NJM->NJM_XIMPUR := cImpureza
                                    NJM->NJM_XUMIDA := cUmidade
                                    NJM->NJM_XPEDES := nPeso
                                    NJM->NJM_XDTREC := Date()
                                    NJM->NJM_XHRREC := SubStr(FwTimeUF("RO")[2],1,5)
                                    NJM->NJM_XROMDE := cRom
                                    NJM->NJM_XFILDE := cFil
                                    NJM->NJM_XDIFPE := NJM->NJM_QTDFCO - nPeso
                                    NJM->(Msunlock())     


                                cMsg2 += "**********************************************************************"+ CRLF
                                cMsg2 += "* -  Dados Atualizados na Origem "    + CRLF
                                cMsg2 += "* -  Empresa: "                       + aSM0Data1[3][2]               + CRLF
                                cMsg2 += "* -  Filial Origem: "                 +(cMyAlias2)->NJJ_FILIAL + CRLF 
                                cMsg2 += "* -  Romaneio Origem: "               +(cMyAlias2)->NJJ_CODROM + CRLF
                                cMsg2 += "* -  Peso: "                          + cvaltochar(nPeso)   + CRLF
                                cMsg2 += "* -  Umidade: "                       + cvaltochar(cOutros)   + CRLF
                                cMsg2 += "* -  Avariado: "                      + cvaltochar(cAvariado)   + CRLF
                                cMsg2 += "* -  Impureza: "                      + cvaltochar(cImpureza)   + CRLF
                                cMsg2 += "* -  Outros: "                        + cvaltochar(cUmidade)   + CRLF
                                

                                EndIf           
                            else     
                                cMsg2 += "*************************************************************************************"         + CRLF
                                cMsg2 += "A Entidade do Romaneio n�o consiste com a Empresa de Origem"                                   + CRLF 
                                cMsg2 += "Entidade do Romaneio"                                                                          + CRLF 
                                cMsg2 += "-------------------------------------------------------------"                                 + CRLF 
                                cMsg2 += "Entidade: "                                                    + NJ0->NJ0_CODENT               + CRLF 
                                cMsg2 += "Loja: "                                                        + NJ0->NJ0_LOJENT               + CRLF 
                                cMsg2 += "Nome: "                                                         +NJ0->NJ0_NOME                 + CRLF 
                                cMsg2 += "CNPJ/CPF: "                                                    + NJ0->NJ0_CGC                  + CRLF 
                                cMsg2 += "Inscricao Estadual: "                                          + NJ0->NJ0_INSCR                + CRLF
                                cMsg2 += "-------------------------------------------------------------"                                 + CRLF 
                                cMsg2 += "Empresa de Origem da Nota Fiscal"                                                              + CRLF 
                                cMsg2 += "-------------------------------------------------------------"                                 + CRLF 
                                cMsg2 += "Empresa: "                                                     + aSM0Data1[3][2]               + CRLF
                                cMsg2 += "CNPJ: "                                                        + cvaltochar(aSM0Data1[2][2])   + CRLF
                                cMsg2 += "IE: "                                                          + cvaltochar(aSM0Data1[1][2])   + CRLF
                                iRet := .F.
                            ENDIF
                    else
                        cMsg2 += "******************************************--" + CRLF
                        cMsg2 += "Entidade Nao Localizada" + CRLF
                        iRet := .F.
                    ENDIF    
            else
                cMsg2 += "******************************************--" + CRLF
                cMsg2 += cIndiceNJM + CRLF
                cMsg2 += "N�o foi Localizado o Romaneio de Origem " + CRLF
                iRet := .F.
            ENDIF
        
        SC5->(dbCloseArea())
        SC6->(dbCloseArea())
        NJM->(dbCloseArea())
        NJ0->(dbCloseArea())
    //===========================================
    EndIf
(cMyAlias2)->(dbCloseArea())
(cMyAlias)->(DbSkip())
ENDDO
(cMyAlias)->(dbCloseArea())
if !(lChv)
    MsgAlert(cMsg, 'Falha ao Verificar a Chave de Origem ')
endif
if !(iRet)
     MsgInfo(cMsg2 ,"Inconsistencia")
else 
     MsgInfo(cMsg2, "Dados Atualziados na Origem") 
endif

Return iRet
