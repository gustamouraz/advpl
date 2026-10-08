#INCLUDE "FileIO.CH"
//#INCLUDE "FINA370.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWLIBVERSION.CH"


User Function ACTBAFIN()

Local _aArea := GetArea()

Private _nValor := 0
Private _lCtb   := .T.      // Variavel que indica se esse registro será integrado ou não.
Private _cNatDeb := ""      //Natureza do título de débito
Private _cNatAdt := ""      //Natureza do título de Adiantamento

Private _EDaCONTA := ""     //ED_CONTA do título Adto
Private _EDdCONTA := ""     //ED_CONTA do tíulo de Débito

// Conta do título de débito
Private _EDdXCTRECT := ""   //Conta _ED_XCTRECT do título de débito
Private _EDdXCTDESP := ""   //Conta _ED_XCTDESP do título de débito
Private _EDdCTATIVO := ""   //Conta _ED_CTATIVO do título de débito
Private _EDdXCTPASS := ""   //Conta _ED_XCTPASS do título de débito
Private _EDdXCTADTO := ""   //Conta _ED_XCTADTO do título de débito
Private _EDdXCONTB  := ""   //Conta _ED_XCONTB do título de débito
Private _EDdXCTADCR := ""   // Conta ED_XCTADCR do título de Débito
Private _E5dTipo := ""      //E5_TIPO do título de débito
Private _nValCMDeb := 0     //Variação Cambial título de débito
Private _nMoedDeb := 0      //Moeda do título do débito

// Conta do tipo de adto
Private _EDaXCTRECT := ""   // Conta _ED_XCTRECT do título de Adiantamento
Private _EDaXCTDESP := ""   // Conta _ED_XCTDESP do título de Adiantamento
Private _EDaCTATIVO := ""   // Conta _ED_CTATIVO do título de Adiantamento
Private _EDaXCTPASS := ""   // Conta _ED_XCTPASS do título de Adiantamento
Private _EDaXCTADTO := ""   // Conta _ED_XCTADTO do título de Adiantamento
Private _EDaXCONTB  := ""   // Conta ED_XCONTB do título de Adiantamento
Private _EDaXCTADCR := ""   // Conta ED_XCTADCR do título de Adiantamento
Private _E5aTipo := ""      // E5_TIPO do adiantamento
Private _nValCMAdt := 0     //Variação cambial do adiantamento
Private _nMoedAdt := 0      // Moeda do título de adiantamento

Private _cFornDeb := ""     // Fornecedor Título de débito
Private _cLjDeb := ""       // Loja Forn. Título Débito
Private _cFornAdt := ""     // Fornecedor Título de Adto
Private _cLjAdt := ""       // Loja Forn. Título Adto
Private _cA2aConta := ""    // Conta do Fornecedor Adto (A2_XCTADTO) (Ref. ao título de adto)
Private _cA2dConta := ""    // Conta do Fornecedor (A2_CONTA)        (Ref. ao título de adto)
Private _cA2dCtAdto := ""   // Conta do Fornecedor Adto (A2_XCTADTO) (Ref. ao título de Débito)
Private _cA2aCtAdto := ""   // Conta do Fornecedor (A2_CONTA)        (Ref. ao título de Débito)

Private _cE5dNUM := ""        // Numero do título de débito
Private _cE5dPREF := ""        // Prefixo do título de débito
Private _cE5dDOC := ""        // Documento do título de débito
Private _cE2dORIG := ""        // Origem do título de débito
Private _cE5dCC := ""        // Centro de Custo do título de débito
Private _cA2dItem := ""        // Item Contabil do Fornecedor título de débito
Private _lDebNac := .T.        // Titulo de débito é Nacional 
Private _nJurDeb := 0           // Juros do título de débito
Private _nDescDeb := 0          // Desconto do título de débito
Private _nMDebOrig := 0         // Moeda de origem do título de débito

Private _cE5aNUM := ""        // Numero do título de Adiantamento
Private _cE5aPREF := ""        // Prefixo do título de Adiantamento
Private _cE5aDOC := ""        // Documento do título de Adiantamento
Private _cE2aORIG := ""        // Origem do título de Adiantamento
Private _cE5aCC := ""           // Centro de Custo do título de Adiantamento
Private _cA2aItem := ""        // Item Contabil do Fornecedor título de Adiantamento
Private _lAdtNac := .T.        // Titulo de Adiantamento é Nacional 
Private _nJurAdt := 0           // Juros do título de Adiantamento
Private _nDescAdt := 0          // Desconto do título de Adiantamento
Private _nMAdtOrig := 0         // Moeda de origem do título de Adiantamento

SetFunName("CTBAFIN")
CTBAFIN(.F.)


RestArea(_aArea)

Return 


User Function ACTBAF597()

Local _aArea := GetArea()
Local _aAreaSE5 := SE5->(GetArea())
Local _cChave := xFilial("CVA")
Local _nRecSE5 := SE5->(RECNO())
Local _aTemp := {}
Local _aTemp2 := {}

_cChave += "597"



If Alltrim(SE5->E5_TIPO) ==  "PA" .or. Alltrim(SE5->E5_TIPO) ==  "NDF"
    _cNatAdt := Alltrim(SE5->E5_NATUREZ)
Else
    _cNatDeb := Alltrim(SE5->E5_NATUREZ)
EndIf


// Carregando as variáveis Tipo e Variação cambial
_aTemp := {}
_aTemp := U_ZRETE5CM(1) // 1-nf /// tipo, cm e ed_conta
_nValCMDeb := _aTemp[2] // Variação cambial do título débito

_aTemp := {}
_aTemp := ACRETE5CM(1) // 1-nf /// tipo, cm e ed_conta
_E5dTipo := Alltrim(_aTemp[1]) //E5_TIPO do título de débito

_EDdCONTA := Alltrim(_aTemp[3]) // ED_CONTA do tíulo de Débito
_cNatDeb := Alltrim(_aTemp[4]) // Natureza débito
// Conta do título de débito
_EDdXCTRECT := Alltrim(_aTemp[5])
_EDdXCTDESP := Alltrim(_aTemp[6])
_EDdCTATIVO := Alltrim(_aTemp[7])
_EDdXCTPASS := Alltrim(_aTemp[8])
_EDdXCTADTO := Alltrim(_aTemp[9])
_EDdXCONTB  := Alltrim(_aTemp[10])
_cFornDeb   := Alltrim(_aTemp[11])
_cLjDeb     := Alltrim(_aTemp[12])
_nMoedDeb   := _aTemp[13]
_cA2dConta  := Alltrim(_aTemp[14])
_cA2dCtAdto := Alltrim(_aTemp[15])

_cE5dNUM    := Alltrim(_aTemp[16])        // Numero do título de débito
_cE5dPREF   := Alltrim(_aTemp[17])        // Prefixo do título de débito
_cE5dDOC    := Alltrim(_aTemp[18])        // Documento do título de débito
_cE2dORIG   := Alltrim(_aTemp[19])        // Origem do título de débito
_cE5dCC     := Alltrim(_aTemp[20])        // Centro de Custo do título de débito
_cA2dItem   := Alltrim(_aTemp[21])        // Item Contabil do Fornecedor título de débito
_lDebNac    := IIF(_aTemp[22]=="EX",.F.,.T.)       // Titulo de débito é Nacional 
_nMDebOrig := _aTemp[23]  
_nJurDeb    := U_ZLPCT597("NJ")           // Juros do título de débito
_nDescDeb   := U_ZLPCT597("NX")         // Desconto do título de débito

SE5->(DbGoTo(_nRecSE5)) //Recupero o mesmo RECNO que estava na chamada da função!

_aTemp2 := {}
_aTemp2 := U_ZRETE5CM(2) // 1-nf /// tipo, cm e ed_conta
_nValCMAdt := _aTemp2[2] //Variação cambial do adiantamento

_aTemp2 := {}
_aTemp2 := ACRETE5CM(2) // 1-nf /// tipo, cm e ed_conta
_E5aTipo := Alltrim(_aTemp2[1]) // E5_TIPO do adiantamento

_EDaCONTA := Alltrim(_aTemp2[3]) //ED_CONTA do título Adto
_cNatAdt :=  Alltrim(_aTemp2[4]) // Natureza crédito
// Contas natureza de adiantamento
_EDaXCTRECT := Alltrim(_aTemp2[05])
_EDaXCTDESP :=  Alltrim(_aTemp2[06])
_EDaCTATIVO :=  Alltrim(_aTemp2[07])
_EDaXCTPASS :=  Alltrim(_aTemp2[08])
_EDaXCTADTO :=  Alltrim(_aTemp2[09])
_EDaXCONTB  :=  Alltrim(_aTemp2[10])
_cFornAdt   :=  Alltrim(_aTemp2[11])
_cLjAdt     :=  Alltrim(_aTemp2[12])
_nMoedAdt   :=  _aTemp2[13]
_cA2aConta  :=  Alltrim(_aTemp2[14])
_cA2aCtAdto :=  Alltrim(_aTemp2[15])

_cE5aNUM    := Alltrim(_aTemp2[16])        // Numero do título de débito
_cE5aPREF   := Alltrim(_aTemp2[17])        // Prefixo do título de débito
_cE5aDOC    := Alltrim(_aTemp2[18])        // Documento do título de débito
_cE2aORIG   := Alltrim(_aTemp2[19])        // Origem do título de débito
_cE5aCC     := Alltrim(_aTemp2[20])        // Centro de Custo do título de débito
_cA2aItem   := Alltrim(_aTemp2[21])        // Item Contabil do Fornecedor título de débito
_lAdtNac    := IIF(_aTemp2[22]=="EX",.F.,.T.)       // Titulo de débito é Nacional 
_nMAdtOrig := _aTemp2[23]  
_nJurAdt    := U_ZLPCT597("AJ")           // Juros do título de débito
_nDescAdt   := U_ZLPCT597("AX")         // Desconto do título de débito

Private _nValor := 0



RestArea(_aAreaSE5)
RestArea(_aArea)

Return _cChave










//Função para retornar os dados da SE5 / SED/ SA2/ SE2
Static function ACRETE5CM(_nTipo)
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
                If !Empty(_cAlias)
                    (_cAlias)->(DbCloseArea())
                EndIf
                _cAlias := GetNextAlias()
                BeginSql alias _cAlias 
                    %noparser%
                    SELECT  TOP 1 SE5.E5_TIPO, SE5.E5_VALOR, SED.ED_CONTA, SE5.E5_NATUREZ,
                                SED.ED_XCTRECT, SED.ED_XCTDESP, SED.ED_CTATIVO, SED.ED_XCTPASS, SED.ED_XCTADTO, SED.ED_XCONTB,
                                SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_MOEDA, SA2.A2_CONTA, SA2.A2_XCADTO,
                                SE5.E5_NUMERO, SE5.E5_PREFIXO, SE5.E5_DOCUMEN, SE2.E2_ORIGEM,SE5.E5_CCUSTO,SA2.A2_ITEMCC, SA2.A2_EST,
                                SE5.R_E_C_N_O_ AS RECSE5
                    FROM        %table:SE5% SE5 WITH(NOLOCK) INNER JOIN %table:SED% SED WITH(NOLOCK) ON
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
                                LEFT OUTER JOIN %table:SA2% SA2 WITH(NOLOCK) ON
                                SA2.A2_FILIAL = %exp:xFilial("SA2")%
                            AND SA2.A2_COD = SE5.E5_CLIFOR AND SA2.A2_LOJA = SE5.E5_LOJA
                            AND SA2.D_E_L_E_T_ = ''                            
                    WHERE       SE5.D_E_L_E_T_ = ''
                            AND SE5.E5_SITUACA = ''
                            AND SE5.E5_MOTBX = 'CMP'
                            AND SE5.E5_FILIAL = %exp:_cFilial%
                            AND SE5.E5_DTDISPO = %exp:_cData%
                            AND SE5.E5_PREFIXO+SE5.E5_NUMERO+SE5.E5_PARCELA+SE5.E5_TIPO+SE5.E5_CLIFOR+SE5.E5_LOJA = %exp:_cDocumen%
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
                
                If !Empty(_cAlias)
                    (_cAlias)->(DbCloseArea())
                EndIf
                _cAlias := GetNextAlias()
                
                BeginSql alias _cAlias 
                    %noparser%
                    SELECT  TOP 1 SE5.E5_TIPO, SE5.E5_VALOR, SED.ED_CONTA, SE5.E5_NATUREZ,
                                SED.ED_XCTRECT, SED.ED_XCTDESP, SED.ED_CTATIVO, SED.ED_XCTPASS, SED.ED_XCTADTO, SED.ED_XCONTB ,
                                SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_MOEDA, SA2.A2_CONTA, SA2.A2_XCADTO,
                                SE5.E5_NUMERO, SE5.E5_PREFIXO, SE5.E5_DOCUMEN, SE2.E2_ORIGEM,SE5.E5_CCUSTO,SA2.A2_ITEMCC, SA2.A2_EST,
                                SE5.R_E_C_N_O_ AS RECSE5
                    FROM        %table:SE5% SE5 WITH(NOLOCK) INNER JOIN %table:SED% SED WITH(NOLOCK) ON
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
                                LEFT OUTER JOIN %table:SA2% SA2 WITH(NOLOCK) ON
                                SA2.A2_FILIAL = %exp:xFilial("SA2")%
                            AND SA2.A2_COD = SE5.E5_CLIFOR AND SA2.A2_LOJA = SE5.E5_LOJA
                            AND SA2.D_E_L_E_T_ = ''                            
                    WHERE       SE5.D_E_L_E_T_ = ''
                            AND SE5.E5_SITUACA = ''
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
                
                If !Empty(_cAlias)
                    (_cAlias)->(DbCloseArea())
                EndIf
                _cAlias := GetNextAlias()
                
                BeginSql alias _cAlias 
                    %noparser%
                    SELECT  TOP 1 SE5.E5_TIPO, SE5.E5_VALOR, SED.ED_CONTA, SE5.E5_NATUREZ,
                                SED.ED_XCTRECT, SED.ED_XCTDESP, SED.ED_CTATIVO, SED.ED_XCTPASS, SED.ED_XCTADTO, SED.ED_XCONTB ,
                                SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_MOEDA, SA2.A2_CONTA, SA2.A2_XCADTO,
                                SE5.E5_NUMERO, SE5.E5_PREFIXO, SE5.E5_DOCUMEN, SE2.E2_ORIGEM,SE5.E5_CCUSTO,SA2.A2_ITEMCC, SA2.A2_EST,
                                SE5.R_E_C_N_O_ AS RECSE5
                    FROM        %table:SE5% SE5 WITH(NOLOCK) INNER JOIN %table:SED% SED WITH(NOLOCK) ON
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
                                LEFT OUTER JOIN %table:SA2% SA2 WITH(NOLOCK) ON
                                SA2.A2_FILIAL = %exp:xFilial("SA2")%
                            AND SA2.A2_COD = SE5.E5_CLIFOR AND SA2.A2_LOJA = SE5.E5_LOJA
                            AND SA2.D_E_L_E_T_ = ''                            
                    WHERE       SE5.D_E_L_E_T_ = ''
                            AND SE5.E5_SITUACA = ''
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

                If !Empty(_cAlias)
                    (_cAlias)->(DbCloseArea())
                EndIf
                _cAlias := GetNextAlias()

                BeginSql alias _cAlias 
                    %noparser%
                    SELECT  TOP 1 SE5.E5_TIPO, SE5.E5_VALOR, SED.ED_CONTA, SE5.E5_NATUREZ,
                                SED.ED_XCTRECT, SED.ED_XCTDESP, SED.ED_CTATIVO, SED.ED_XCTPASS, SED.ED_XCTADTO, SED.ED_XCONTB,
                                SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_MOEDA, SA2.A2_CONTA, SA2.A2_XCADTO,
                                SE5.E5_NUMERO, SE5.E5_PREFIXO, SE5.E5_DOCUMEN, SE2.E2_ORIGEM,SE5.E5_CCUSTO,SA2.A2_ITEMCC, SA2.A2_EST,
                                SE5.R_E_C_N_O_ AS RECSE5
                    FROM        %table:SE5% SE5 WITH(NOLOCK) INNER JOIN %table:SED% SED WITH(NOLOCK) ON
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
                                LEFT OUTER JOIN %table:SA2% SA2 WITH(NOLOCK) ON
                                SA2.A2_FILIAL = %exp:xFilial("SA2")%
                            AND SA2.A2_COD = SE5.E5_CLIFOR AND SA2.A2_LOJA = SE5.E5_LOJA
                            AND SA2.D_E_L_E_T_ = ''
                    WHERE       SE5.D_E_L_E_T_ = ''
                            AND SE5.E5_SITUACA = ''
                            AND SE5.E5_MOTBX = 'CMP'
                            AND SE5.E5_FILIAL = %exp:_cFilial%
                            AND SE5.E5_DTDISPO = %exp:_cData%
                            AND SE5.E5_PREFIXO+SE5.E5_NUMERO+SE5.E5_PARCELA+SE5.E5_TIPO+SE5.E5_CLIFOR+SE5.E5_LOJA = %exp:_cDocumen%
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

        aAdd(_aRet, (_cAlias)->E5_NUMERO   )    //16
        aAdd(_aRet, (_cAlias)->E5_PREFIXO  )    //17
        aAdd(_aRet, (_cAlias)->E5_DOCUMEN  )    //18
        aAdd(_aRet, (_cAlias)->E2_ORIGEM   )    //19
        aAdd(_aRet, (_cAlias)->E5_CCUSTO   )    //20
        aAdd(_aRet, (_cAlias)->A2_ITEMCC   )    //21
        aAdd(_aRet, (_cAlias)->A2_EST      )    //22

        DbSelectArea("SE5")
        SE5->(DbGoto(( (_cAlias)->RECSE5   )))
        _nMoedOrig := U_ACRMOEDA("MP")
        aAdd(_aRet, _nMoedOrig     )            //23

        SE5->(DbGoTo(_nRecSE5)) //Recupero o mesmo RECNO que estava na chamada da função!

	Else
		aAdd(_aRet,"" ) //01 TIPO
        aAdd(_aRet, 0 ) //02 VARICAO CAMBIAL
        aAdd(_aRet, "") //03 CONTA
        aAdd(_aRet, "") //04 NATUREZA
        aAdd(_aRet, "") //05 ED_XCTRECT
        aAdd(_aRet, "") //06 ED_XCTDESP
        aAdd(_aRet, "") //07 ED_CTATIVO
        aAdd(_aRet, "") //08 ED_XCTPASS
        aAdd(_aRet, "") //09 ED_XCTADTO
        aAdd(_aRet, "") //10 ED_XCONTB
        aAdd(_aRet, "") //11 E5_CLIFOR
        aAdd(_aRet, "") //12 E5_LOJA
        aAdd(_aRet, "") //13 E5_MOEDA
        aAdd(_aRet, "") //14 A2_CONTA
        aAdd(_aRet, "") //15 A2_XCADTO

        aAdd(_aRet, "") //16 E5_NUMERO   )    //16
        aAdd(_aRet, "") //17 E5_PREFIXO  )    //17
        aAdd(_aRet, "") //18 E5_DOCUMEN  )    //18
        aAdd(_aRet, "") //19 E2_ORIGEM   )    //19
        aAdd(_aRet, "") //20 E5_CCUSTO   )    //20
        aAdd(_aRet, "") //21 A2_ITEMCC   )    //21
        aAdd(_aRet, "") //22 A2_EST      )    //22
        aAdd(_aRet, 0 ) //23 MOEDA ORIG )

	EndIf
    (_cAlias)->(DbCloseArea())
	SE5->(DbGoTo(_nRecSE5)) //Recupero o mesmo RECNO que estava na chamada da função!
	RestArea(_aAreSE5)
	RestArea(aArea)
	


return _aRet





