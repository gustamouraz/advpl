#Include "Protheus.ch"

User function ZLPCT596(_cTipo) 
Local _cRet := ""
Local _aArea 	:= GetArea()
Local _aAreSE5	:= SE5->(GetArea())
Local _cFilial 	:= ""
Local _cData := ""
Local _cDocumen := ""
Local _cSequenc := ""
Local _cAlias := GetNextAlias()
Local _cDocPos := ""
Local _cMsIdent := ""   
Local _lEstorno := Empty(SE5->E5_NUMERO)
Local _cTeste := ""
Local _nRecBKP := SE5->(RECNO()) //Vou precisar desposicionar a SE5.
Local _nMoedOri := 1
Local _cMV_ZCLIAD2 := SuperGetMv("MV_ZCLIAD2",.F.,'')
Local _cMV_ZCLIND  := SuperGetMv("MV_ZCLIND",.F.,'')
Local _cMV_ZCLINF2 := SuperGetMv("MV_ZCLINF2",.F.,'')
Local _cMVZTPMOD2 := SuperGetMv("MV_ZTPMOE2",.F.,"NF|FT")
Local _nVlrTemp := 0 

Default _cTipo := "" //Debito ou crédito

_cFilial	:= '%'+ValToSql(SE5->E5_FILIAL) + '%'
_cData 	:= '%'+ValToSql(SE5->E5_DTDISPO) + '%'
//_cDocumen   := '%'+ValToSql(SE5->E5_DOCUMEN) + '%'
_cDocumen := '%'+ValToSql(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)) + '%'
_cSequenc := '%'+ValToSql(SE5->E5_SEQ)+'%'
_cDocPos := '%'+ValToSql(SE5->E5_DOCUMEN)+'%'
_cTeste := "Numero"+ SE5->E5_NUMERO+char(13)+char(10)
_cTeste += "Prefixo"+ SE5->E5_PREFIXO+char(13)+char(10)
_cTeste += "Parcela"+ SE5->E5_PARCELA+char(13)+char(10)
_cTeste += "Tipo"+ SE5->E5_TIPO+char(13)+char(10)
_cTeste += "Mot. Baixa"+ SE5->E5_MOTBX+char(13)+char(10)
_cTeste += "Estorno: "+ SE5->E5_SITUACA+char(13)+char(10)


If !Empty(SE5->E5_NUMERO) .AND. Empty(SE5->E5_KEY)
    BeginSql alias _cAlias 
        %noparser%
        SELECT  TOP 1 RTRIM(SE5.E5_TIPO) AS E5_TIPO, SE5.E5_PREFIXO, SE5.E5_VALOR, SED.ED_CONTA, SE5.E5_VLMULTA, 
                SE5.E5_VLJUROS, SE5.E5_VLDESCO,
                ISNULL(SE1.E1_ORIGEM,'') AS E1_ORIGEM, SE5.R_E_C_N_O_ AS RECSE5
        FROM        %table:SE5% SE5 WITH(NOLOCK) 
                    INNER JOIN %table:SED% SED WITH(NOLOCK) ON
                    SED.ED_CODIGO = SE5.E5_NATUREZ
                AND SED.ED_FILIAL = %exp:xFilial("SED")%
                AND SED.D_E_L_E_T_ = ''
                    LEFT OUTER JOIN %table:SE1% SE1 WITH(NOLOCK) ON
                    SE1.E1_FILIAL = SE5.E5_FILIAL
                AND SE1.E1_NUM = SE5.E5_NUMERO
                AND SE1.E1_PREFIXO = SE5.E5_PREFIXO
                AND SE1.E1_TIPO = SE5.E5_TIPO
                AND SE1.E1_PARCELA = SE5.E5_PARCELA
                AND SE1.E1_CLIENTE = SE5.E5_CLIFOR
                AND SE1.E1_LOJA = SE5.E5_LOJA
                AND SE1.D_E_L_E_T_ = ''                
        WHERE       SE5.D_E_L_E_T_ = ''
                AND SE5.E5_SITUACA = ''
                AND SE5.E5_TIPODOC IN ('BA','CP')
                AND SE5.E5_MOTBX = 'CMP'
                AND SE5.E5_FILIAL = %exp:_cFilial%
                AND SE5.E5_DTDISPO = %exp:_cData%
                AND SE5.E5_DOCUMEN = %exp:_cDocumen%
                AND SE5.E5_SEQ = %exp:_cSequenc%
                AND SE5.E5_PREFIXO+SE5.E5_NUMERO+SE5.E5_PARCELA+SE5.E5_TIPO+SE5.E5_CLIFOR+SE5.E5_LOJA = %exp:_cDocPos%
    EndSql
ElseIf Empty(SE5->E5_NUMERO) .AND. !Empty(SE5->E5_KEY)
    If !Empty(_cAlias)
        (_cAlias)->(DbCloseArea())
    EndIf
    _cAlias := GetNextAlias()
    _cMsIdent := '%'+ValToSql(SE5->E5_MSIDENT)+'%'
    BeginSql alias _cAlias 
        %noparser%
        SELECT  TOP 1 
                RTRIM(CASE 
                        WHEN ISNULL(SE1.E1_TIPO,'') IN ('RA','NCC') THEN SUBSTRING(SE5.E5_DOCUMEN,16,3)
                        ELSE SE1.E1_TIPO
                END) E5_TIPO, 
                RTRIM(CASE 
                        WHEN ISNULL(SE1.E1_TIPO,'') IN ('RA','NCC') THEN SUBSTRING(SE5.E5_DOCUMEN,1,3)
                        ELSE SE1.E1_PREFIXO
                END) E5_PREFIXO,
                SE5.E5_VALOR, 
                (CASE 
                    WHEN ISNULL(SE1.E1_TIPO,'') IN ('RA','NCC') THEN SEDD.ED_CONTA
                    ELSE SED.ED_CONTA
                END) AS ED_CONTA, 
                (CASE 
                    WHEN ISNULL(SE1.E1_TIPO,'') IN ('RA','NCC') THEN SE1.E1_ORIGEM
                    ELSE ''
                END) AS E1_ORIGEM,                
                SE5.E5_VLMULTA, SE5.E5_VLJUROS, SE5.E5_VLDESCO, SE5.R_E_C_N_O_ AS RECSE5
        FROM        %table:SE5% SE5 WITH(NOLOCK) INNER JOIN %table:SED% SED WITH(NOLOCK) ON
                    SED.ED_CODIGO = SE5.E5_NATUREZ
                AND SED.ED_FILIAL = %exp:xFilial("SED")%
                AND SED.D_E_L_E_T_ = ''
                    LEFT OUTER JOIN %table:SE1% SE1 ON
                    SE1.E1_FILIAL = SE5.E5_FILIAL
                AND SE5.E5_KEY = SE1.E1_PREFIXO+SE1.E1_NUM+SE1.E1_PARCELA+SE1.E1_TIPO+SE1.E1_CLIENTE+SE1.E1_LOJA
                    LEFT OUTER JOIN %table:SED% SEDD ON
                    SEDD.ED_CODIGO = SE1.E1_NATUREZ
                AND SEDD.ED_FILIAL = %exp:xFilial("SED")%
                AND SEDD.D_E_L_E_T_ = ''
        WHERE       SE5.D_E_L_E_T_ = ''
                AND SE5.E5_SITUACA = ''
                AND SE5.E5_TIPODOC IN ('BA','CP')
                AND SE5.E5_MOTBX = 'CMP'
                AND SE5.E5_FILIAL = %exp:_cFilial%
                AND SE5.E5_DTDISPO = %exp:_cData%
                AND SE5.E5_MSIDENT = %exp:_cMsIdent%
ORDER BY SE5.E5_DOCUMEN, SE1.D_E_L_E_T_                
    EndSql
Else
    Return _cRet
Endif


If (_cAlias)->(eof())
    If !Empty(_cAlias)
        (_cAlias)->(DbCloseArea())
    EndIf
    _cAlias := GetNextAlias()
    _cMsIdent := '%'+ValToSql(SE5->E5_MSIDENT)+'%'
    BeginSql alias _cAlias 
        %noparser%
        SELECT  TOP 1 
                RTRIM(CASE 
                        WHEN ISNULL(SE1.E1_TIPO,'') IN ('RA','NCC') THEN SUBSTRING(SE5.E5_DOCUMEN,16,3)
                        ELSE SE1.E1_TIPO
                END) E5_TIPO, 
                RTRIM(CASE 
                        WHEN ISNULL(SE1.E1_TIPO,'') IN ('RA','NCC') THEN SUBSTRING(SE5.E5_DOCUMEN,1,3)
                        ELSE SE1.E1_PREFIXO
                END) E5_PREFIXO,
                SE5.E5_VALOR, 
                (CASE 
                    WHEN ISNULL(SE1.E1_TIPO,'') IN ('RA','NCC') THEN SEDD.ED_CONTA
                    ELSE SED.ED_CONTA
                END) AS ED_CONTA, 
                (CASE 
                    WHEN ISNULL(SE1.E1_TIPO,'') IN ('RA','NCC') THEN SE1.E1_ORIGEM
                    ELSE ''
                END) AS E1_ORIGEM,
                SE5.E5_VLMULTA, SE5.E5_VLJUROS, SE5.E5_VLDESCO, SE5.R_E_C_N_O_ AS RECSE5
        FROM        %table:SE5% SE5 WITH(NOLOCK) INNER JOIN %table:SED% SED WITH(NOLOCK) ON
                    SED.ED_CODIGO = SE5.E5_NATUREZ
                AND SED.ED_FILIAL = %exp:xFilial("SED")%
                AND SED.D_E_L_E_T_ = ''
                    LEFT OUTER JOIN %table:SE1% SE1 ON
                    SE1.E1_FILIAL = SE5.E5_FILIAL
                AND SE5.E5_DOCUMEN = SE1.E1_PREFIXO+SE1.E1_NUM+SE1.E1_PARCELA+SE1.E1_TIPO+SE1.E1_CLIENTE+SE1.E1_LOJA
                    LEFT OUTER JOIN %table:SED% SEDD ON
                    SEDD.ED_CODIGO = SE1.E1_NATUREZ
                AND SEDD.ED_FILIAL = %exp:xFilial("SED")%
                AND SEDD.D_E_L_E_T_ = ''
        WHERE       SE5.D_E_L_E_T_ = ''
                AND SE5.E5_SITUACA = ''
                AND SE5.E5_TIPODOC IN ('BA','CP','ES')
                AND SE5.E5_MOTBX = 'CMP'
                AND SE5.E5_FILIAL = %exp:_cFilial%
                AND SE5.E5_DTDISPO = %exp:_cData%
                AND SE5.E5_MSIDENT = %exp:_cMsIdent%
ORDER BY SE5.E5_DOCUMEN, SE1.D_E_L_E_T_                
    EndSql
Endif

MemoWrite("C:\Temp\ZLPCT596_01.sql",_cTeste + GetLastQuery()[2])

DbSelectArea("SED")
SED->(DbSetOrder(1))

If (_cAlias)->(!EOF())
    If _cTipo == "C" // Baixando CLIENTE
        If Alltrim(SE5->E5_TIPO) == "RA" .OR. Alltrim(SE5->E5_TIPO) == "NCC" .OR. _lEstorno
            If ( (_cAlias)->E5_TIPO == "NF" .AND. Alltrim((_cAlias)->E5_PREFIXO) <> "ND" )  .OR. (_cAlias)->E5_TIPO == "CAR";
                    .or. (_cAlias)->E5_TIPO == "FT"
                DbSelectArea("SE5")
                SE5->(DbGoto((_cAlias)->RECSE5 ))
                If Empty(_cMVZTPMOD2) .or. Alltrim(SE5->E5_TIPO) $ _cMVZTPMOD2 
                    _nMoedOri := U_ACRMOEDA("MR")
                EndIf

                If _nMoedOri > 1


////// PAREI AQUI 13/10/2023
//Local _cMV_ZCLIAD2 := SuperGetMv("MV_ZCLIAD2",.F.,'')
//Local _cMV_ZCLIND  := SuperGetMv("MV_ZCLIND",.F.,'')
//Local _cMV_ZCLINF2 := SuperGetMv("MV_ZCLINF2",.F.,'')

                    If Empty(_cMV_ZFORNF2)
                        _cRet := GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+ SE5->(E5_CLIFOR + E5_LOJA), 1, "" )
                        If Empty(_cRet)
                            _cRet := "21101001"
                        EndIf                        
                    Else
                        DbSelectArea("SM4")
                        SM4->(DbSetOrder(1))
                        SM4->(DbGoTop())
                        If SM4->(DbSeek(xFilial("SM4") + _cMV_ZFORNF2 ))
                            _cRet := Formula(_cMV_ZFORNF2)
                        Else
                            _cRet := GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+ SE5->(E5_CLIFOR + E5_LOJA), 1, "" )
                            If Empty(_cRet)
                                _cRet := "21101001"
                            EndIf
                        Endif
                    EndIf
                Else
                    _cRet := GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+ SE5->(E5_CLIFOR + E5_LOJA), 1, "" )
                    If Empty(_cRet)
                        _cRet := "21101001"
                    EndIf
                EndIf

                SE5->(DbGoTo(_nRecBKP)) //Volto na posição original
            Else
                _cRet := (_cAlias)->ED_CONTA
            EndIf
        Else
            If Empty(_cMVZTPMOD2) .or. Alltrim(SE5->E5_TIPO) $ _cMVZTPMOD2 
                _nMoedOri := U_ACRMOEDA("MP")
            EndIf
                If _nMoedOri > 1
                    If Empty(_cMV_ZFORNF2)
                        _cRet := GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+ SE5->(E5_CLIFOR + E5_LOJA), 1, "" )
                        If Empty(_cRet)
                            _cRet := "21101001"
                        EndIf                        
                    Else
                        DbSelectArea("SM4")
                        SM4->(DbSetOrder(1))
                        SM4->(DbGoTop())
                        If SM4->(DbSeek(xFilial("SM4") + _cMV_ZFORNF2 ))
                            _cRet := Formula(_cMV_ZFORNF2)
                        Else
                            _cRet := GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+ SE5->(E5_CLIFOR + E5_LOJA), 1, "" )
                            If Empty(_cRet)
                                _cRet := "21101001"
                            EndIf
                        Endif
                    EndIf
                Else
                    _cRet := GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+ SE5->(E5_CLIFOR + E5_LOJA), 1, "" )
                    If Empty(_cRet)
                        _cRet := "21101001"
                    EndIf
                EndIf
        EndIf
    ElseIf _cTipo == "D"  //Baixando adiantamento
        If Alltrim(SE5->E5_TIPO) == "RA" .OR. Alltrim(SE5->E5_TIPO) == "NCC" 
            SED->(DbGoTop())
            
            If SED->(DbSeek(xFilial("SED")+SE5->E5_NATUREZ ))
                _cRet := SED->ED_CONTA
            EndIf
            /*
                Pego a origem da SE1
                Salvo a área para não desposicionar a contabilização!
            */
            If SE5->E5_TIPO == "NCC" 
                _aAreaSE1 := SE1->(GetArea())
                DbSelectArea("SE1")
                SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA
                SE1->(DbGoTop())
                If SE1->(DbSeek(SE5->(E5_FILIAL + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + E5_CLIFOR + E5_LOJA)  ))
                    If ALLTRIM(SE1->E1_ORIGEM) $ "MATA100|MATA103"
                        _cRet := '11202014'
                    EndIf
                EndIf
                //Devolvo a área da SE1 para seguir o fluxo da ctbafin.
                RestArea(_aAreaSE1)
            EndIf
        Else
            If Alltrim((_cAlias)->E1_ORIGEM) $ "MATA100|MATA103"
                _cRet := '11202014'
            Else    
                _cRet := (_cAlias)->ED_CONTA
            EndIf

        EndIf
    ElseIf _cTipo == "NJ" //Juros
        If ! (Alltrim(SE5->E5_TIPO) == "RA" .OR. Alltrim(SE5->E5_TIPO) == "NCC" )
            If !Empty(_cAlias)
                (_cAlias)->(DbCloseArea())
            EndIf
            Return SE5->E5_VLJUROS+SE5->E5_VLMULTA
        Else
            _nVlrTemp := 0
            _nVlrTemp := (_cAlias)->E5_VLJUROS+(_cAlias)->E5_VLMULTA 
            If !Empty(_cAlias)
                (_cAlias)->(DbCloseArea())
            EndIf
            Return _nVlrTemp 
        EndIf
    ElseIf _cTipo == "NX" //Desconto
        If ! (Alltrim(SE5->E5_TIPO) == "RA" .OR. Alltrim(SE5->E5_TIPO) == "NCC" )
            If !Empty(_cAlias)
                (_cAlias)->(DbCloseArea())
            EndIf        
            Return SE5->E5_VLDESCO
        Else
            _nVlrTemp := 0
            _nVlrTemp := (_cAlias)->E5_VLDESCO
            If !Empty(_cAlias)
                (_cAlias)->(DbCloseArea())
            EndIf
            Return _nVlrTemp 
        EndIf
    ElseIf _cTipo == "AJ" //Juros
        If Alltrim(SE5->E5_TIPO) == "RA" .OR. Alltrim(SE5->E5_TIPO) == "NCC" 
            If !Empty(_cAlias)
                (_cAlias)->(DbCloseArea())
            EndIf        
            Return SE5->E5_VLJUROS+SE5->E5_VLMULTA
        Else
            _nVlrTemp := 0
            _nVlrTemp := (_cAlias)->E5_VLJUROS+(_cAlias)->E5_VLMULTA 
            If !Empty(_cAlias)
                (_cAlias)->(DbCloseArea())
            EndIf
            Return _nVlrTemp 

        EndIf
    ElseIf _cTipo == "AX" //Desconto
        If Alltrim(SE5->E5_TIPO) == "RA" .OR. Alltrim(SE5->E5_TIPO) == "NCC" 
            If !Empty(_cAlias)
                (_cAlias)->(DbCloseArea())
            EndIf        
            Return SE5->E5_VLDESCO
        Else
            _nVlrTemp := 0
            _nVlrTemp := (_cAlias)->E5_VLDESCO
            If !Empty(_cAlias)
                (_cAlias)->(DbCloseArea())
            EndIf
            Return _nVlrTemp 
        EndIf
    EndIf
EndIf
(_cAlias)->(DbCloseArea())

RestArea(_aAreSE5)
RestArea(_aArea)

Return _cRet

