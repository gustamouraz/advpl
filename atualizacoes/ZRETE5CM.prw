#include 'protheus.ch'
#include 'TopConn.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} ZRETE5CM
//TODO
@description Função para retornar a correção monetária!
@author André Claro
@since 03/05/2021
@version 1.0
@type function 
/*/

user function ZRETE5CM(_nTipo)
	Local aArea 	:= GetArea()
	Local _aAreSE5	:= SE5->(GetArea())
	Local _aRet 	:= {} //Tipo, Valor, Conta
	Local _cFilial 	:= ""
	Local _cPrefixo := ""
	Local _cNum := ""
	Local _cParcela := ""
	Local _cTipo := ""
	Local _cCliFor := ""
	Local _cLoja := ""
	Local _cData := ""
	Local _cSeq 	:= ""
    Local _cDocumen := ""
	Local _cAlias := ''
	Local _nValCM := 0 //Valor da correção (E5_VALOR - LINHA DA CORREÇÃO) 
	Local _nValor := 0 // VALOR DA SE5_VALOR
	Local _nRecSE5 := SE5->(RECNO())
	Default _nTipo := 0 
	
    If !_nRecSE5 > 0 .or. !_nTipo > 0
		aAdd(_aRet,"" )
        aAdd(_aRet, 0 )
        aAdd(_aRet, "")
        Return _aRet
	EndIf



    _cAlias := GetNextAlias()
	
	DbSelectArea("SE5")
	SE5->(DbGoTo(_nRecSE5))
	
	If SE5->(RECNO()) == _nRecSE5 //estou posicionado no mesmo recno da contabilização. 
        If SE5->E5_MOEDA = '01'
            _nValor	:= SE5->E5_VALOR
        Else 
            _nValor	:= SE5->E5_VLMOED2        
        EndIf
        
        /*
        ElseIf SE5->E5_MOEDA = '02'
            _nValor	:= SE5->E5_VLMOED2
        ElseIf SE5->E5_MOEDA = '03'
            _nValor	:= SE5->E5_VLMOED3
        ElseIf SE5->E5_MOEDA = '04'
            _nValor	:= SE5->E5_VLMOED4
        ElseIf SE5->E5_MOEDA = '05'
            _nValor	:= SE5->E5_VLMOED5
        EndIf
        */

        If _nTipo == 1 //NF 
            If Alltrim(SE5->E5_TIPO) == "PA"
                _cFilial	:= '%'+ValToSql(SE5->E5_FILIAL) + '%'
                _cPrefixo  := '%'+ValToSql(SE5->E5_PREFIXO) + '%'
                _cNum 		:= '%'+ValToSql(SE5->E5_NUMERO) + '%'
                _cParcela 	:= '%'+ValToSql(SE5->E5_PARCELA) + '%'
                _cTipo 	:= '%'+ValToSql(SE5->E5_TIPO) + '%'
                _cCliFor 	:= '%'+ValToSql(SE5->E5_CLIFOR) + '%'
                _cLoja 	:= '%'+ValToSql(SE5->E5_LOJA) + '%'
                _cData 	:= '%'+ValToSql(SE5->E5_DTDISPO) + '%'
                _cSeq		:= '%'+ValToSql(SE5->E5_SEQ) + '%'
                _cDocumen   := '%'+ValToSql(SE5->E5_DOCUMEN) + '%'
                BeginSql alias _cAlias 
                    %noparser%
                    SELECT  TOP 1 SE5.E5_TIPO, SE5.E5_VALOR, SED.ED_CONTA, SE5.E5_NATUREZ,
                                SED.ED_XCTRECT, SED.ED_XCTDESP, SED.ED_CTATIVO, SED.ED_XCTPASS, SED.ED_XCTADTO, SED.ED_XCONTB,
                                SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_MOEDA, SA2.A2_CONTA, SA2.A2_XCADTO
                    FROM        %table:SE5% SE5 WITH(NOLOCK) INNER JOIN %table:SED% SED WITH(NOLOCK) ON
                                SED.ED_CODIGO = SE5.E5_NATUREZ
                            AND SED.ED_FILIAL = %exp:xFilial("SED")%
                            AND SED.D_E_L_E_T_ = ''
                                LEFT OUTER JOIN %table:SA2% SA2 WITH(NOLOCK) ON
                                SA2.A2_FILIAL = %exp:xFilial("SA2")%
                            AND SA2.A2_COD = SE5.E5_CLIFOR AND SA2.A2_LOJA = SE5.E5_LOJA
                            AND SA2.D_E_L_E_T_ = ''                            
                    WHERE       SE5.D_E_L_E_T_ = ''
                            AND SE5.E5_SITUACA = ''
                            AND SE5.E5_TIPODOC = 'CM'
                            AND SE5.E5_MOTBX = 'CMP'
                            AND SE5.E5_FILIAL = %exp:_cFilial%
                            AND SE5.E5_DTDISPO = %exp:_cData%
                            AND SE5.E5_DOCUMEN = %exp:_cDocumen%
                EndSql

            Else
                _cFilial	:= '%'+ValToSql(SE5->E5_FILIAL) + '%'
                _cPrefixo  := '%'+ValToSql(SE5->E5_PREFIXO) + '%'
                _cNum 		:= '%'+ValToSql(SE5->E5_NUMERO) + '%'
                _cParcela 	:= '%'+ValToSql(SE5->E5_PARCELA) + '%'
                _cTipo 	:= '%'+ValToSql(SE5->E5_TIPO) + '%'
                _cCliFor 	:= '%'+ValToSql(SE5->E5_CLIFOR) + '%'
                _cLoja 	:= '%'+ValToSql(SE5->E5_LOJA) + '%'
                _cData 	:= '%'+ValToSql(SE5->E5_DTDISPO) + '%'
                _cSeq		:= '%'+ValToSql(SE5->E5_SEQ) + '%'

                BeginSql alias _cAlias 
                    %noparser%
                    SELECT  TOP 1 SE5.E5_TIPO, SE5.E5_VALOR, SED.ED_CONTA, SE5.E5_NATUREZ,
                                SED.ED_XCTRECT, SED.ED_XCTDESP, SED.ED_CTATIVO, SED.ED_XCTPASS, SED.ED_XCTADTO, SED.ED_XCONTB ,
                                SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_MOEDA, SA2.A2_CONTA, SA2.A2_XCADTO
                    FROM        %table:SE5% SE5 WITH(NOLOCK) INNER JOIN %table:SED% SED WITH(NOLOCK) ON
                                SED.ED_CODIGO = SE5.E5_NATUREZ
                            AND SED.ED_FILIAL = %exp:xFilial("SED")%
                            AND SED.D_E_L_E_T_ = ''
                                LEFT OUTER JOIN %table:SA2% SA2 WITH(NOLOCK) ON
                                SA2.A2_FILIAL = %exp:xFilial("SA2")%
                            AND SA2.A2_COD = SE5.E5_CLIFOR AND SA2.A2_LOJA = SE5.E5_LOJA
                            AND SA2.D_E_L_E_T_ = ''                            
                    WHERE       SE5.D_E_L_E_T_ = ''
                            AND SE5.E5_SITUACA = ''
                            AND SE5.E5_TIPODOC = 'CM'
                            AND SE5.E5_MOTBX = 'CMP'
                            AND SE5.E5_FILIAL = %exp:_cFilial%
                            AND SE5.E5_PREFIXO = %exp:_cPrefixo%
                            AND SE5.E5_NUMERO = %exp:_cNum%
                            AND SE5.E5_PARCELA = %exp:_cParcela%
                            AND SE5.E5_TIPO = %exp:_cTipo%
                            AND SE5.E5_CLIFOR = %exp:_cCliFor%
                            AND SE5.E5_LOJA = %exp:_cLoja%
                            AND SE5.E5_DTDISPO = %exp:_cData%
                            AND SE5.E5_SEQ = %exp:_cSeq%
                EndSql
                MemoWrite("C:\Temp\zrete5cm01.sql",GetLastQuery()[2])
            EndIf
        Else //2 - PA
            If Alltrim(SE5->E5_TIPO) == "PA"
                _cFilial	:= '%'+ValToSql(SE5->E5_FILIAL) + '%'
                _cPrefixo  := '%'+ValToSql(SE5->E5_PREFIXO) + '%'
                _cNum 		:= '%'+ValToSql(SE5->E5_NUMERO) + '%'
                _cParcela 	:= '%'+ValToSql(SE5->E5_PARCELA) + '%'
                _cTipo 	:= '%'+ValToSql(SE5->E5_TIPO) + '%'
                _cCliFor 	:= '%'+ValToSql(SE5->E5_CLIFOR) + '%'
                _cLoja 	:= '%'+ValToSql(SE5->E5_LOJA) + '%'
                _cData 	:= '%'+ValToSql(SE5->E5_DTDISPO) + '%'
                _cSeq		:= '%'+ValToSql(SE5->E5_SEQ) + '%'

                BeginSql alias _cAlias 
                    %noparser%
                    SELECT  TOP 1 SE5.E5_TIPO, SE5.E5_VALOR, SED.ED_CONTA, SE5.E5_NATUREZ,
                                SED.ED_XCTRECT, SED.ED_XCTDESP, SED.ED_CTATIVO, SED.ED_XCTPASS, SED.ED_XCTADTO, SED.ED_XCONTB ,
                                SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_MOEDA, SA2.A2_CONTA, SA2.A2_XCADTO
                    FROM        %table:SE5% SE5 WITH(NOLOCK) INNER JOIN %table:SED% SED WITH(NOLOCK) ON
                                SED.ED_CODIGO = SE5.E5_NATUREZ
                            AND SED.ED_FILIAL = %exp:xFilial("SED")%
                            AND SED.D_E_L_E_T_ = ''
                                LEFT OUTER JOIN %table:SA2% SA2 WITH(NOLOCK) ON
                                SA2.A2_FILIAL = %exp:xFilial("SA2")%
                            AND SA2.A2_COD = SE5.E5_CLIFOR AND SA2.A2_LOJA = SE5.E5_LOJA
                            AND SA2.D_E_L_E_T_ = ''                            
                    WHERE       SE5.D_E_L_E_T_ = ''
                            AND SE5.E5_SITUACA = ''
                            AND SE5.E5_TIPODOC = 'CM' AND SE5.E5_MOTBX = 'CMP'
                            AND SE5.E5_FILIAL = %exp:_cFilial%
                            AND SE5.E5_PREFIXO = %exp:_cPrefixo%
                            AND SE5.E5_NUMERO = %exp:_cNum%
                            AND SE5.E5_PARCELA = %exp:_cParcela%
                            AND SE5.E5_TIPO = %exp:_cTipo%
                            AND SE5.E5_CLIFOR = %exp:_cCliFor%
                            AND SE5.E5_LOJA = %exp:_cLoja%
                            AND SE5.E5_DTDISPO = %exp:_cData%
                            AND SE5.E5_SEQ = %exp:_cSeq%
                EndSql

            Else
                _cFilial	:= '%'+ValToSql(SE5->E5_FILIAL) + '%'
                _cPrefixo  := '%'+ValToSql(SE5->E5_PREFIXO) + '%'
                _cNum 		:= '%'+ValToSql(SE5->E5_NUMERO) + '%'
                _cParcela 	:= '%'+ValToSql(SE5->E5_PARCELA) + '%'
                _cTipo 	:= '%'+ValToSql(SE5->E5_TIPO) + '%'
                _cCliFor 	:= '%'+ValToSql(SE5->E5_CLIFOR) + '%'
                _cLoja 	:= '%'+ValToSql(SE5->E5_LOJA) + '%'
                _cData 	:= '%'+ValToSql(SE5->E5_DTDISPO) + '%'
                _cSeq		:= '%'+ValToSql(SE5->E5_SEQ) + '%'
                _cDocumen   := '%'+ValToSql(SE5->E5_DOCUMEN) + '%'

                BeginSql alias _cAlias 
                    %noparser%
                    SELECT  TOP 1 SE5.E5_TIPO, SE5.E5_VALOR, SED.ED_CONTA, SE5.E5_NATUREZ,
                                SED.ED_XCTRECT, SED.ED_XCTDESP, SED.ED_CTATIVO, SED.ED_XCTPASS, SED.ED_XCTADTO, SED.ED_XCONTB,
                                SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_MOEDA, SA2.A2_CONTA, SA2.A2_XCADTO
                    FROM        %table:SE5% SE5 WITH(NOLOCK) INNER JOIN %table:SED% SED WITH(NOLOCK) ON
                                SED.ED_CODIGO = SE5.E5_NATUREZ
                            AND SED.ED_FILIAL = %exp:xFilial("SED")%
                            AND SED.D_E_L_E_T_ = ''
                                LEFT OUTER JOIN %table:SA2% SA2 WITH(NOLOCK) ON
                                SA2.A2_FILIAL = %exp:xFilial("SA2")%
                            AND SA2.A2_COD = SE5.E5_CLIFOR AND SA2.A2_LOJA = SE5.E5_LOJA
                            AND SA2.D_E_L_E_T_ = ''
                    WHERE       SE5.D_E_L_E_T_ = ''
                            AND SE5.E5_SITUACA = ''
                            AND SE5.E5_TIPODOC = 'CM'
                            AND SE5.E5_MOTBX = 'CMP'
                            AND SE5.E5_FILIAL = %exp:_cFilial%
                            AND SE5.E5_DTDISPO = %exp:_cData%
                            AND SE5.E5_DOCUMEN = %exp:_cDocumen%
                EndSql
                MemoWrite("C:\Temp\zrete5cm02.sql",GetLastQuery()[2])
            EndIf        
        EndIf
	EndIf

	If (_cAlias)->(!EOF())
		_nValCM := (_cAlias)->E5_VALOR          
		aAdd(_aRet, (_cAlias)->E5_TIPO   )      // 01
        aAdd(_aRet, _nValCM    )                // 02
        aAdd(_aRet, (_cAlias)->ED_CONTA )       // 03
        aAdd(_aRet, (_cAlias)->E5_NATUREZ )     // 04
        aAdd(_aRet, (_cAlias)->ED_XCTRECT )     // 05
        aAdd(_aRet, (_cAlias)->ED_XCTDESP )     // 06
        aAdd(_aRet, (_cAlias)->ED_CTATIVO)      // 07
        aAdd(_aRet, (_cAlias)->ED_XCTPASS)      // 08
        aAdd(_aRet, (_cAlias)->ED_XCTADTO)      // 09
        aAdd(_aRet, (_cAlias)->ED_XCONTB )      // 10
        aAdd(_aRet, (_cAlias)->E5_CLIFOR )      // 11
        aAdd(_aRet, (_cAlias)->E5_LOJA)         // 12
        aAdd(_aRet, (_cAlias)->E5_MOEDA )       // 13
        aAdd(_aRet, (_cAlias)->A2_CONTA)    // 14
        aAdd(_aRet, (_cAlias)->A2_XCADTO)       // 15
	Else
		aAdd(_aRet,"" ) // TIPO
        aAdd(_aRet, 0 ) // VARICAO CAMBIAL
        aAdd(_aRet, "") // CONTA
        aAdd(_aRet, "") // NATUREZA
        aAdd(_aRet, "") // ED_XCTRECT
        aAdd(_aRet, "") // ED_XCTDESP
        aAdd(_aRet, "") // ED_CTATIVO
        aAdd(_aRet, "") // ED_XCTPASS
        aAdd(_aRet, "") // ED_XCTADTO
        aAdd(_aRet, "") // ED_XCONTB
        aAdd(_aRet, "") // E5_CLIFOR
        aAdd(_aRet, "") // E5_LOJA
        aAdd(_aRet, "") // E5_MOEDA
        aAdd(_aRet, "") // A2_CONTA
        aAdd(_aRet, "") // A2_XCADTO
	EndIf
    (_cAlias)->(DbCloseArea())
	SE5->(DbGoTo(_nRecSE5)) //Recupero o mesmo RECNO que estava na chamada da função!
	RestArea(_aAreSE5)
	RestArea(aArea)


return _aRet




User function ZLPCT597(_cTipo)
Local _cRet := ""
Local _aArea 	:= GetArea()
Local _aAreSE5	:= SE5->(GetArea())
Local _cFilial 	:= ""
Local _cData := ""
Local _cDocumen := ""
Local _cSequenc := ""
Local _cAlias := ''
Local _cDocPos := ""
Local _cMsIdent := ""
Local _lEstorno := Empty(SE5->E5_NUMERO)
Local _cTeste := ""
Local _nRecBKP := SE5->(RECNO()) //Vou precisar desposicionar a SE5.
Local _nMoedOri := 1
Local _cMV_ZFORNF2 := SuperGetMv("MV_ZFORNF2",.F.,'')
Local _cMV_ZFORNDF := SuperGetMv("MV_ZFORNDF",.F.,'') //FORMULA PARA CONTA DE NDF NA COMPENSAÇÃO
Local _cMV_ZFORMPA := SuperGetMv("MV_ZFORMPA",.F.,'') //FORMULA PARA CONTA DE PA NA COMPENSAÇÃO
Local _cMVZTPMOD2 := SuperGetMv("MV_ZTPMOE2",.F.,"NF|FT")
Local _lCpoAdto := .F.
Local _cCpoAdto := Alltrim(SuperGetMv("MV_Z597NAT",.F.,"ED_XCTADTO"))
Local _cCpoAdtSQL := ''
Local _nVlrTemp := 0 
Default _cTipo := "" //Debito ou crédito

/*   Variáveis
Private _lEst := .F.
Private _lAdto := SE5->E5_TIPO $ MVPAGANT
Private _cNatNF := ""
Private _cNatAdto := ""
Private _cNatXAdto := ""

*/


DbSelectArea("SED")

_cCpoAdtSQL := '%'+"ED_CONTA"+'%'

If SED->(ColumnPos(_cCpoAdto) ) > 0
    If _cCpoAdto <> "ED_CONTA"
        _cCpoAdtSQL := '%'+_cCpoAdto+'%'
        _lCpoAdto := .T.
        _cMV_ZFORNF2 := StrTran(_cMV_ZFORNF2,"ED_CONTA",_cCpoAdto)
        _cMV_ZFORNDF := StrTran(_cMV_ZFORNDF,"ED_CONTA",_cCpoAdto)
        _cMV_ZFORMPA := StrTran(_cMV_ZFORMPA,"ED_CONTA",_cCpoAdto)
    Endif
Else 
    _cCpoAdto := "ED_CONTA"
EndIf

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
    If !Empty(_cAlias)
        (_cAlias)->(DbCloseArea())
    EndIf
    _cAlias := GetNextAlias()
    BeginSql alias _cAlias 
        %noparser%
        SELECT  TOP 1 RTRIM(SE5.E5_TIPO) AS E5_TIPO, SE5.E5_PREFIXO, SE5.E5_VALOR, SED.%exp:_cCpoAdtSQL% AS ED_CONTA, SE5.E5_VLMULTA, 
                SE5.E5_VLJUROS, SE5.E5_VLDESCO,
                ISNULL(SE2.E2_ORIGEM,'') AS E2_ORIGEM, SE5.R_E_C_N_O_ AS RECSE5, ISNULL(SE2.R_E_C_N_O_, 0 ) AS RECSE2
        FROM        %table:SE5% SE5 WITH(NOLOCK) 
                    INNER JOIN %table:SED% SED WITH(NOLOCK) ON
                    SED.ED_CODIGO = SE5.E5_NATUREZ
                AND SED.ED_FILIAL = %exp:xFilial("SED")%
                AND SED.D_E_L_E_T_ = ''
                    LEFT OUTER JOIN %table:SE2% SE2 WITH(NOLOCK) ON
                    SE2.E2_FILIAL = SE5.E5_FILIAL
                AND SE2.E2_NUM = SE5.E5_NUMERO
                AND SE2.E2_PREFIXO = SE5.E5_PREFIXO
                AND SE2.E2_TIPO = SE5.E5_TIPO
                AND SE2.E2_PARCELA = SE5.E5_PARCELA
                AND SE2.E2_FORNECE = SE5.E5_CLIFOR
                AND SE2.E2_LOJA = SE5.E5_LOJA
                AND SE2.D_E_L_E_T_ = ''                
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
                        WHEN ISNULL(SE2.E2_TIPO,'') IN ('PA','NDF') THEN SUBSTRING(SE5.E5_DOCUMEN,16,3)
                        ELSE SE2.E2_TIPO
                END) E5_TIPO, 
                RTRIM(CASE 
                        WHEN ISNULL(SE2.E2_TIPO,'') IN ('PA','NDF') THEN SUBSTRING(SE5.E5_DOCUMEN,1,3)
                        ELSE SE2.E2_PREFIXO
                END) E5_PREFIXO,
                SE5.E5_VALOR, 
                (CASE 
                    WHEN ISNULL(SE2.E2_TIPO,'') IN ('PA','NDF') THEN SEDD.%exp:_cCpoAdtSQL%
                    ELSE SED.%exp:_cCpoAdtSQL%
                END) AS ED_CONTA, 
                (CASE 
                    WHEN ISNULL(SE2.E2_TIPO,'') IN ('PA','NDF') THEN SE2.E2_ORIGEM
                    ELSE ''
                END) AS E2_ORIGEM,                
                SE5.E5_VLMULTA, SE5.E5_VLJUROS, SE5.E5_VLDESCO, SE5.R_E_C_N_O_ AS RECSE5, ISNULL(SE2.R_E_C_N_O_, 0 ) AS RECSE2
        FROM        %table:SE5% SE5 WITH(NOLOCK) INNER JOIN %table:SED% SED WITH(NOLOCK) ON
                    SED.ED_CODIGO = SE5.E5_NATUREZ
                AND SED.ED_FILIAL = %exp:xFilial("SED")%
                AND SED.D_E_L_E_T_ = ''
                    LEFT OUTER JOIN %table:SE2% SE2 ON
                    SE2.E2_FILIAL = SE5.E5_FILIAL
                AND SE5.E5_KEY = SE2.E2_PREFIXO+SE2.E2_NUM+SE2.E2_PARCELA+SE2.E2_TIPO+SE2.E2_FORNECE+SE2.E2_LOJA
                    LEFT OUTER JOIN %table:SED% SEDD ON
                    SEDD.ED_CODIGO = SE2.E2_NATUREZ
                AND SEDD.ED_FILIAL = %exp:xFilial("SED")%
                AND SEDD.D_E_L_E_T_ = ''
        WHERE       SE5.D_E_L_E_T_ = ''
                AND SE5.E5_SITUACA = ''
                AND SE5.E5_TIPODOC IN ('BA','CP')
                AND SE5.E5_MOTBX = 'CMP'
                AND SE5.E5_FILIAL = %exp:_cFilial%
                AND SE5.E5_DTDISPO = %exp:_cData%
                AND SE5.E5_MSIDENT = %exp:_cMsIdent%
        ORDER BY SE5.E5_DOCUMEN, SE2.D_E_L_E_T_                
    EndSql
Else

    If _cTipo == "D" // Baixando fornecedor
        Return ""
    ElseIf _cTipo == "C"  //Baixando adiantamento
        Return ""
    ElseIf _cTipo == "NJ" //Juros
        Return 0
    ElseIf _cTipo == "NX" //Desconto
        Return 0
    ElseIf _cTipo == "AJ" //Juros
        Return 0
    ElseIf _cTipo == "AX" //Desconto
        Return 0
    EndIf

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
                        WHEN ISNULL(SE2.E2_TIPO,'') IN ('PA','NDF') THEN SUBSTRING(SE5.E5_DOCUMEN,16,3)
                        ELSE SE2.E2_TIPO
                END) E5_TIPO, 
                RTRIM(CASE 
                        WHEN ISNULL(SE2.E2_TIPO,'') IN ('PA','NDF') THEN SUBSTRING(SE5.E5_DOCUMEN,1,3)
                        ELSE SE2.E2_PREFIXO
                END) E5_PREFIXO,
                SE5.E5_VALOR, 
                (CASE 
                    WHEN ISNULL(SE2.E2_TIPO,'') IN ('PA','NDF') THEN SEDD.%exp:_cCpoAdtSQL%
                    ELSE SED.%exp:_cCpoAdtSQL%
                END) AS ED_CONTA, 
                (CASE 
                    WHEN ISNULL(SE2.E2_TIPO,'') IN ('PA','NDF') THEN SE2.E2_ORIGEM
                    ELSE ''
                END) AS E2_ORIGEM,
                SE5.E5_VLMULTA, SE5.E5_VLJUROS, SE5.E5_VLDESCO, SE5.R_E_C_N_O_ AS RECSE5, ISNULL(SE2.R_E_C_N_O_, 0 ) AS RECSE2
        FROM        %table:SE5% SE5 WITH(NOLOCK) INNER JOIN %table:SED% SED WITH(NOLOCK) ON
                    SED.ED_CODIGO = SE5.E5_NATUREZ
                AND SED.ED_FILIAL = %exp:xFilial("SED")%
                AND SED.D_E_L_E_T_ = ''
                    LEFT OUTER JOIN %table:SE2% SE2 ON
                    SE2.E2_FILIAL = SE5.E5_FILIAL
                AND SE5.E5_DOCUMEN = SE2.E2_PREFIXO+SE2.E2_NUM+SE2.E2_PARCELA+SE2.E2_TIPO+SE2.E2_FORNECE+SE2.E2_LOJA
                    LEFT OUTER JOIN %table:SED% SEDD ON
                    SEDD.ED_CODIGO = SE2.E2_NATUREZ
                AND SEDD.ED_FILIAL = %exp:xFilial("SED")%
                AND SEDD.D_E_L_E_T_ = ''
        WHERE       SE5.D_E_L_E_T_ = ''
                AND SE5.E5_SITUACA = ''
                AND SE5.E5_TIPODOC IN ('BA','CP','ES')
                AND SE5.E5_MOTBX = 'CMP'
                AND SE5.E5_FILIAL = %exp:_cFilial%
                AND SE5.E5_DTDISPO = %exp:_cData%
                AND SE5.E5_MSIDENT = %exp:_cMsIdent%
        ORDER BY SE5.E5_DOCUMEN, SE2.D_E_L_E_T_
    EndSql
Endif

MemoWrite("C:\Temp\ZLPCT597_01.sql",_cTeste + GetLastQuery()[2])

DbSelectArea("SED")
SED->(DbSetOrder(1))

If (_cAlias)->(!EOF())
    If _cTipo == "D" // Baixando fornecedor
        If Alltrim(SE5->E5_TIPO) == "PA" .OR. Alltrim(SE5->E5_TIPO) == "NDF" .OR. _lEstorno
            If ( Alltrim((_cAlias)->E5_TIPO) == "NF" .AND. Alltrim((_cAlias)->E5_PREFIXO) <> "ND" )  .OR. Alltrim((_cAlias)->E5_TIPO) == "CAR";
                    .or. Alltrim((_cAlias)->E5_TIPO) == "FT"
                DbSelectArea("SE5")
                SE5->(DbGoto((_cAlias)->RECSE5 ))
                If Empty(_cMVZTPMOD2) .or. Alltrim((_cAlias)->E5_TIPO) $ _cMVZTPMOD2 
                    _nMoedOri := U_ACRMOEDA("MP")
                EndIf
                If _nMoedOri > 1
                    If Empty(_cMV_ZFORNF2)
                        _cRet := GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+ (_cAlias)->(E5_CLIFOR + E5_LOJA), 1, "" )
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
                            _cRet := GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+ (_cAlias)->(E5_CLIFOR + E5_LOJA), 1, "" )
                            If Empty(_cRet)
                                _cRet := "21101001"
                            EndIf
                        Endif
                    EndIf
                Else
                    _cRet := GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+ (_cAlias)->(E5_CLIFOR + E5_LOJA), 1, "" )
                    If Empty(_cRet)
                        _cRet := "21101001"
                    EndIf
                EndIf

                SE5->(DbGoTo(_nRecBKP)) //Volto na posição original
            Else
                _cRet := (_cAlias)->ED_CONTA
            EndIf
        Else
            If ( Alltrim(SE5->E5_TIPO) == "NF" .AND. Alltrim(SE5->E5_PREFIXO) <> "ND" )  .OR. SE5->E5_TIPO == "CAR";
                    .or. Alltrim(SE5->E5_TIPO) == "FT"   
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
            Else
                _cRet := GetAdvFVal("SED","ED_CONTA",xFilial("SED")+ SE5->E5_NATUREZ, 1, "" )
                If Empty(_cRet)
                    _cRet := "NAT S CTA"
                EndIf
            EndIf
            
        EndIf
    ElseIf _cTipo == "C"  //Baixando adiantamento
        If Alltrim(SE5->E5_TIPO) == "PA" .OR. Alltrim(SE5->E5_TIPO) == "NDF" 
            SED->(DbGoTop())
            
            If SED->(DbSeek(xFilial("SED")+SE5->E5_NATUREZ ))
                _cRet := &('SED->'+_cCpoAdto)
            EndIf
            /*
                Pego a origem da SE2
                Salvo a área para não desposicionar a contabilização!
            */
            If SE5->E5_TIPO == "NDF" 
                _aAreaSE2 := SE2->(GetArea())
                DbSelectArea("SE2")
                SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
                SE2->(DbGoTop())
                If SE2->(DbSeek(SE5->(E5_FILIAL + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + E5_CLIFOR + E5_LOJA)  ))
                    If !Empty(_cMV_ZFORNDF)
                        DbSelectArea("SED")
                        SED->(DbSetOrder(1))
                        SED->(DbGoTop())
                        DbSelectArea("SA2")
                        SA2->(DbSetOrder(1))
                        SA2->(DbGoTop())                
                        If SED->(DbSeek(xFilial("SED") + SE2->E2_NATUREZ ))
                            If SA2->(DbSeek(xFilial("SA2") + SE2->(E2_FORNECE + E2_LOJA ) ))
                                DbSelectArea("SM4")
                                SM4->(DbSetOrder(1))
                                SM4->(DbGoTop())
                                If SM4->(DbSeek(xFilial("SM4") + _cMV_ZFORNDF ))
                                    _cRet := Formula(_cMV_ZFORNDF)
                                Else
                                    _cRet := '11202014'
                                Endif
                            EndIf
                        EndIf
                    Else 
                        If ALLTRIM(SE2->E2_ORIGEM) == "MATA460"
                            _cRet := '11202014'
                        EndIf
                    EndIf
                EndIf
                //Devolvo a área da SE2 para seguir o fluxo da ctbafin.
                RestArea(_aAreaSE2)
            ElseIf !Empty(_cMV_ZFORMPA)  //Se não tiver formula, considero a conta da natureza mesmo, ou seja, a que foi preenchida acima
                DbSelectArea("SED")
                SED->(DbSetOrder(1))
                SED->(DbGoTop())
                DbSelectArea("SA2")
                SA2->(DbSetOrder(1))
                SA2->(DbGoTop())                
                If SED->(DbSeek(xFilial("SED") + SE2->E2_NATUREZ ))
                    If SA2->(DbSeek(xFilial("SA2") + SE2->(E2_FORNECE + E2_LOJA ) ))
                        DbSelectArea("SM4")
                        SM4->(DbSetOrder(1))
                        SM4->(DbGoTop())
                        If SM4->(DbSeek(xFilial("SM4") + _cMV_ZFORMPA ))
                            _cRet := Formula(_cMV_ZFORMPA)
                            If Empty(_cRet)
                                _cRet := &('SED->'+_cCpoAdto)
                            EndIf
                        Endif
                    EndIf
                EndIf
            EndIf
        Else
            SED->(DbGoTop())
            
            If SED->(DbSeek(xFilial("SED")+  (_cAlias)->ED_CONTA ))
                _cRet := SED->ED_CONTA
            EndIf

            If (_cAlias)->RECSE2 > 0 
                _aAreaSE2 := SE2->(GetArea())
                DbSelectArea("SE2")
                SE2->(DbSetOrder(1))
                SE2->(DbGoTo((_cAlias)->RECSE2))
                /*
                    Pego a origem da SE2
                    Salvo a área para não desposicionar a contabilização!
                */
                If SE2->E2_TIPO == "NDF" 
                    If !Empty(_cMV_ZFORNDF)
                        DbSelectArea("SED")
                        SED->(DbSetOrder(1))
                        DbSelectArea("SA2")
                        SA2->(DbSetOrder(1))
                        SA2->(DbGoTop())                
                        If SED->(DbSeek(xFilial("SED") + SE2->E2_NATUREZ ))
                            If SA2->(DbSeek(xFilial("SA2") + SE2->(E2_FORNECE + E2_LOJA ) ))
                                DbSelectArea("SM4")
                                SM4->(DbSetOrder(1))
                                SM4->(DbGoTop())
                                If SM4->(DbSeek(xFilial("SM4") + _cMV_ZFORNDF ))
                                    _cRet := Formula(_cMV_ZFORNDF)
                                Else
                                    _cRet := '11202014'
                                Endif
                            EndIf
                        EndIf
                    Else 
                        If ALLTRIM(SE2->E2_ORIGEM) == "MATA460"
                            _cRet := '11202014'
                        EndIf
                    EndIf
                    //Devolvo a área da SE2 para seguir o fluxo da ctbafin.
                ElseIf !Empty(_cMV_ZFORMPA)  //Se não tiver formula, considero a conta da natureza mesmo, ou seja, a que foi preenchida acima
                    DbSelectArea("SED")
                    SED->(DbSetOrder(1))
                    SED->(DbGoTop())
                    DbSelectArea("SA2")
                    SA2->(DbSetOrder(1))
                    SA2->(DbGoTop())                
                    If SED->(DbSeek(xFilial("SED") + SE2->E2_NATUREZ ))
                        If SA2->(DbSeek(xFilial("SA2") + SE2->(E2_FORNECE + E2_LOJA ) ))
                            DbSelectArea("SM4")
                            SM4->(DbSetOrder(1))
                            SM4->(DbGoTop())
                            If SM4->(DbSeek(xFilial("SM4") + _cMV_ZFORMPA ))
                                _cRet := Formula(_cMV_ZFORMPA)
                                If Empty(_cRet)
                                    _cRet := &('SED->'+_cCpoAdto)
                                EndIf
                            Endif
                        EndIf
                    EndIf
                EndIf
                RestArea(_aAreaSE2)
            Else //Se não conseguir chegar na SE2, SIGO COM A FÓRMULA ANTIGA
                If Alltrim((_cAlias)->E2_ORIGEM) == "MATA460"
                    _cRet := '11202014'
                Else    
                    _cRet := (_cAlias)->ED_CONTA
                EndIf            
            EndIf
        EndIf
    ElseIf _cTipo == "NJ" //Juros
        If ! (Alltrim(SE5->E5_TIPO) == "PA" .OR. Alltrim(SE5->E5_TIPO) == "NDF" )
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
        If ! (Alltrim(SE5->E5_TIPO) == "PA" .OR. Alltrim(SE5->E5_TIPO) == "NDF" )
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
        If Alltrim(SE5->E5_TIPO) == "PA" .OR. Alltrim(SE5->E5_TIPO) == "NDF" 
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
        If Alltrim(SE5->E5_TIPO) == "PA" .OR. Alltrim(SE5->E5_TIPO) == "NDF" 
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






