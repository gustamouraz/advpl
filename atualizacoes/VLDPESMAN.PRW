#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'


User Function JUSPES(cAlias)
Local aItems:= {}
Local lRet := .F.
//Local cMyAlias2    := "NJJ"

DEFAULT cMyAlias2 := GetNextAlias()

BEGINSQL Alias cMyAlias2
%noparser%
    SELECT * FROM ZM7010 WITH(NOLOCK) 
    WHERE ZM7_ALIAS = "NJJ"  AND ZM7010.D_E_L_E_T_ = ''
	ENDSQL
    (cMyAlias2)->(DbGoTop())
    While !(cMyAlias2)->(Eof())
        AAdd(aItems, (cMyAlias2)->ZM7_DESCJU)
        (cMyAlias2)->(dbSkip())
    EndDo
(cMyAlias2)->(dbCloseArea())

cCombo:= aItems[1]
SetPrvt("oDlg1","oSay1","oCBox1","oSBtn1","oSBtn2")


oDlg1      := MSDialog():New( 146,440,272,941,"Justificativa",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 004,008,{||"Informe a Justificativa"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,220,008)
oCBox1     := TComboBox():New( 016,008,{|u|if(PCount()>0,cCombo:=u,cCombo)}, aItems,224,010,oDlg1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )
oSBtn1     := SButton():New( 036,204,1,{|| if (GRVZZ2(cCombo,cAlias),(lRet := .T.,oDlg1:End() ), oDlg1:End() ) },oDlg1,,"", )
oSBtn2     := SButton():New( 036,168,2,{|| oDlg1:End()},oDlg1,,"", )



oDlg1:Activate(,,,.T.)

Return lRet

Static Function GRVZZ2(cCombo,cAlias)
lRet := .F.
        DbSelectArea("ZZ2")
        ZZ2->(DbSetOrder(1))
                If RecLock("ZZ2", .T.)
                    ZZ2->ZZ2_FILIAL := xFilial("ZZ2")
                    ZZ2->ZZ2_NUM    := M->NJJ_CODROM
                    ZZ2->ZZ2_MOTEXC := Alltrim(cCombo)
                    ZZ2->ZZ2_USER   := UsrFullName(__cUserID)
                    ZZ2->ZZ2_DTEXCL := DATE()
                    ZZ2->ZZ2_ALIAS  := "NJJ"
                    ZZ2->(MsUnlock())
                lRet := .T.
                else
                MsgInfo("Houve um Erro ao Gravar a Justificativa. Favor Verificar com TI.","Atenção")
            EndIf
Return lRet

