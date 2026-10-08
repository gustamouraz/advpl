  #Include "Protheus.ch"

/*---------------------------------------------------------------------------*
 | Func:  U_MNTA080                                                          |
 | Autor: Luiz Moura                                                         |
 | Desde: 20/06/2022                                                         |
 | Desc:  Sincroniza T9_XCHASSI -> T9_CHASSI no cadastro de bens (MNTA080)   |
 *--------------------------------------------------------------------------*/

User Function MNTA080()

      Local oObj     := Nil
      Local cEvento  := ""
      Local cRotina  := ""
      Local cCodBem  := ""
      Local cValor   := ""
      Local aArea    := GetArea()

      If ValType(ParamIxb) <> "A" .Or. Len(ParamIxb) < 3
          RestArea(aArea)
          Return .T.
      EndIf

      oObj    := ParamIxb[1]
      cEvento := AllTrim(IIf(ValType(ParamIxb[2]) == "C", ParamIxb[2], ""))
      cRotina := AllTrim(IIf(ValType(ParamIxb[3]) == "C", ParamIxb[3], ""))

      If cEvento == "MODELCOMMITNTTS" .And. cRotina == "MNTA080" .And. ValType(oObj) == "O"

          cCodBem := AllTrim( oObj:GetValue( "T9_CODBEM" ) )
          cValor  := AllTrim( oObj:GetValue( "T9_XCHASSI" ) )
          
          If !Empty(cCodBem)
              DbSelectArea("ST9")
              ST9->(DbSetOrder(1))

              If ST9->(DbSeek(xFilial("ST9") + cCodBem))
                  If AllTrim(ST9->T9_CHASSI) <> cValor
                      RecLock("ST9", .F.)
                      ST9->T9_CHASSI := PadR(cValor, TamSX3("T9_CHASSI")[1])
                      MsUnlock()
                  EndIf
              EndIf
          EndIf
      EndIf

      RestArea(aArea)

  Return .T.
