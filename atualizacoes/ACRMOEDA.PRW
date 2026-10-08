#Include "Protheus.ch"

/*
@Autor:     André Claro - 35 998775495 - andre.claro@acclaro.com.br
@Data:      12/10/2023
@Descrição: Rotina responsável por retornar qual a moeda original 
            do registro em questão.
@Parametros: _cOrigem - Qual rotina está chamando essa função?
                CR – Contas a Receber
                CP – Contas a pagar 
                MR - Movimento bancário a receber 
                MP – Movimento bancário a pagar
                NS – Documento de saída
                NE – Documento de entrada
*/

User Function ACRMOEDA(_cOrigem)

Local _nMoeda := 1 
Local _aArea := GetArea()
Local _aAreaSE1 := SE1->(GetArea())
Local _aAreaSE2 := SE2->(GetArea())
Local _aAreaSE5 := SE5->(GetArea())
Local _aAreaSF1 := SF1->(GetArea())
Local _aAreaSF2 := SF2->(GetArea())
Local _cAlias := ''

Default _cOrigem := ''

If Valtype(_cOrigem) <> "C"
    MsgAlert("A Função ACRMOEDA recebeu parâmetros inválidos e retornará moeda 1.")
    Return _nMoeda
ElseIf Empty(_cOrigem)
    MsgAlert("A Função ACRMOEDA recebeu parâmetros inválidos e retornará moeda 1.")
    Return _nMoeda
EndIf

If _cOrigem == 'CR' //Contas a Receber
    _nMoeda :=  ZMOEDPVCT(  SE1->E1_FILORIG, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_EMISSAO, SE1->E1_CLIENTE,; 
                SE1->E1_LOJA, SE1->E1_MOEDA, SE1->E1_VLCRUZ / SE1->E1_VALOR)[1]
ElseIf _cOrigem == 'CP' //Contas a pagar
    If SE2->E2_MOEDA > 0 
        _nMoeda := SE2->E2_MOEDA
    EndIf
ElseIf _cOrigem == 'MR' //Movimento bancário a receber
    If !Empty(_cAlias)
        (_cAlias)->(DbCloseArea())
    EndIf
    _cAlias := GetNextAlias()
    If Alltrim(SE5->E5_TIPO) == "RA" .OR. Alltrim(SE5->E5_TIPO) == "NCC"
        BeginSql alias _cAlias
            %noparser%
                SELECT 	SE1.E1_FILORIG, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_EMISSAO, SE1.E1_CLIENTE, 
                        SE1.E1_LOJA, SE1.E1_MOEDA, SE1.E1_VLCRUZ, SE1.E1_VALOR, SE1.R_E_C_N_O_ AS RECSE1
                FROM		%table:SE1% SE1 WITH(NOLOCK)
                WHERE		SE1.D_E_L_E_T_ = ''
                        AND SE1.E1_FILIAL = %exp:SE5->E5_FILIAL%
                        AND SE1.E1_PREFIXO + SE1.E1_NUM + SE1.E1_PARCELA + SE1.E1_TIPO + SE1.E1_LOJA = %exp:SE5->E5_DOCUMEN%
        EndSql
    Else
        BeginSql alias _cAlias
            %noparser%
                SELECT 	SE1.E1_FILORIG, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_EMISSAO, SE1.E1_CLIENTE, 
                        SE1.E1_LOJA, SE1.E1_MOEDA, SE1.E1_VLCRUZ, SE1.E1_VALOR, SE1.R_E_C_N_O_ AS RECSE1
                FROM		%table:SE1% SE1 WITH(NOLOCK)
                WHERE		SE1.D_E_L_E_T_ = ''
                        AND SE1.E1_FILIAL = %exp:SE5->E5_FILIAL%
                        AND SE1.E1_NUM = %exp:SE5->E5_NUMERO%
                        AND SE1.E1_PREFIXO = %exp:SE5->E5_PREFIXO%
                        AND SE1.E1_PARCELA = %exp:SE5->E5_PARCELA%
                        AND SE1.E1_TIPO = %exp:SE5->E5_TIPO%
                        AND SE1.E1_CLIENTE = %exp:SE5->E5_CLIFOR%
                        AND SE1.E1_LOJA = %exp:SE5->E5_LOJA%
        EndSql
    EndIf

    If (_cAlias)->(!eof())
        _nMoeda :=  ZMOEDPVCT(  (_cAlias)->E1_FILORIG, (_cAlias)->E1_PREFIXO, (_cAlias)->E1_NUM, (_cAlias)->E1_EMISSAO,; 
                    (_cAlias)->E1_CLIENTE,  (_cAlias)->E1_LOJA, (_cAlias)->E1_MOEDA, (_cAlias)->E1_VLCRUZ / (_cAlias)->E1_VALOR)[1]
    ElseIf SE5->E5_MOEDA == "01"
        _nMoeda := 1  
    ElseIf SE5->E5_MOEDA == "02"
        _nMoeda := 2
    EndIf 

    (_cAlias)->(DbCloseArea())
ElseIf _cOrigem == 'MP' //Movimento bancário a pagar
    If !Empty(_cAlias)
        (_cAlias)->(DbCloseArea())
    EndIf
    _cAlias := GetNextAlias()

    BeginSql alias _cAlias
        %noparser%
        SELECT	TOP 1 SE2.E2_MOEDA
        FROM		%table:SE2% SE2 WITH(NOLOCK)
        WHERE		SE2.D_E_L_E_T_ = ''
                AND SE2.E2_FILIAL = %exp:SE5->E5_FILIAL%
                AND SE2.E2_PREFIXO =  %exp:SE5->E5_PREFIXO%
                AND SE2.E2_NUM = %exp:SE5->E5_NUMERO%
                AND SE2.E2_FORNECE = %exp:SE5->E5_CLIFOR%
                AND SE2.E2_LOJA =  %exp:SE5->E5_LOJA%
                AND SE2.E2_MOEDA > 0
        ORDER BY SE2.E2_MOEDA DESC    
    EndSql

    If (_cAlias)->(!Eof())
        _nMoeda := (_cAlias)->E2_MOEDA
    ElseIf SE5->E5_MOEDA == "01"
        _nMoeda := 1  
    ElseIf SE5->E5_MOEDA == "02"
        _nMoeda := 2
    EndIf
    
    (_cAlias)->(DbCloseArea())

ElseIf _cOrigem == 'NS' //Nota Fiscal de saída
    If !Empty(_cAlias)
        (_cAlias)->(DbCloseArea())
    EndIf
    _cAlias := GetNextAlias()

    BeginSql alias _cAlias
        %noparser%
            SELECT 	SE1.E1_FILORIG, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_EMISSAO, SE1.E1_CLIENTE, 
                    SE1.E1_LOJA, SE1.E1_MOEDA, SE1.E1_VLCRUZ, SE1.E1_VALOR, SE1.R_E_C_N_O_ AS RECSE1
            FROM		%table:SE1% SE1 WITH(NOLOCK)
            WHERE		SE1.D_E_L_E_T_ = ''
                    AND SE1.E1_FILORIG = %exp:SF2->F2_FILIAL%
                    AND SE1.E1_NUM = %exp:SF2->F2_DUPL%
                    AND SE1.E1_PREFIXO = %exp:SF2->F2_PREFIXO%
                    AND SE1.E1_TIPO = 'NF'
                    AND SE1.E1_CLIENTE = %exp:SF2->F2_CLIENTE%
                    AND SE1.E1_LOJA = %exp:SF2->F2_LOJA%
    EndSql

    If (_cAlias)->(!eof())
        _nMoeda :=  ZMOEDPVCT((_cAlias)->E1_FILORIG, (_cAlias)->E1_PREFIXO, (_cAlias)->E1_NUM, (_cAlias)->E1_EMISSAO, (_cAlias)->E1_CLIENTE,; 
                    (_cAlias)->E1_LOJA, (_cAlias)->E1_MOEDA, (_cAlias)->E1_VLCRUZ / (_cAlias)->E1_VALOR)[1]
    
        (_cAlias)->(DbCloseArea())
    Else
        //Se não achou pelo financeiro, vou tentar achar pelo pedido
        If !Empty(_cAlias)
            (_cAlias)->(DbCloseArea())
        EndIf        
        _cAlias := GetNextAlias()

        BeginSql alias _cAlias
            %noparser%
            SELECT	TOP 1 SC5.C5_MOEDA
            FROM		%table:SD2% SD2 INNER JOIN %table:SC5% SC5 ON
                        SC5.C5_FILIAL = SD2.D2_FILIAL
                    AND SC5.C5_NUM = SD2.D2_PEDIDO
                    AND SC5.D_E_L_E_T_ = ''
            WHERE		SD2.D_E_L_E_T_ = ''
                    AND SD2.D2_FILIAL = %exp:SF2->F2_FILIAL%
                    AND SD2.D2_DOC = %exp:SF2->F2_DOC%
                    AND SD2.D2_SERIE= %exp:SF2->F2_SERIE%
                    AND SD2.D2_CLIENTE= %exp:SF2->F2_CLIENTE%
                    AND SD2.D2_LOJA= %exp:SF2->F2_LOJA%
                    AND SC5.C5_MOEDA > 0 
            ORDER BY SC5.C5_MOEDA DESC        
        EndSql

        If (_cAlias)->(!eof())
            If (_cAlias)->C5_MOEDA > 0 
                _nMoeda := (_cAlias)->C5_MOEDA
            EndIf
        ElseIf SF2->F2_MOEDA >= 1 
            _nMoeda := SF2->F2_MOEDA
        EndIf 
        
        (_cAlias)->(DbCloseArea())

    EndIf

    
ElseIf _cOrigem == 'NE' //Nota Fiscal de entrada
    If !Empty(_cAlias)
        (_cAlias)->(DbCloseArea())
    EndIf
    _cAlias := GetNextAlias()

    BeginSql alias _cAlias
        %noparser%
            SELECT	TOP 1 SE2.E2_MOEDA
            FROM		%table:SE2% SE2 WITH(NOLOCK)
            WHERE		SE2.D_E_L_E_T_ = ''
                    AND SE2.E2_FILORIG = %exp:SF1->F1_FILIAL%
                    AND SE2.E2_PREFIXO =  %exp:SF1->F1_PREFIXO%
                    AND SE2.E2_NUM = %exp:SF1->F1_DUPL%
                    AND SE2.E2_FORNECE = %exp:SF1->F1_FORNECE%
                    AND SE2.E2_LOJA =  %exp:SF1->F1_LOJA%
                    AND SE2.E2_MOEDA > 0
            ORDER BY SE2.E2_MOEDA DESC   
    EndSql

    If (_cAlias)->(!eof())
        _nMoeda :=  (_cAlias)->E2_MOEDA
    ElseIf SF1->F1_MOEDA >= 1 
        _nMoeda := SF1->F1_MOEDA
    EndIf

    (_cAlias)->(DbCloseArea())

EndIf


RestArea(_aArea)
RestArea(_aAreaSE1)
RestArea(_aAreaSE2)
RestArea(_aAreaSE5)
RestArea(_aAreaSF1)
RestArea(_aAreaSF2)

Return _nMoeda




// Função que retorna a moeda do pedido de vendas ou retorna a própria moeda do título.
Static Function ZMOEDPVCT(_cFil, _cPref, _cNum, _cEmis, _cClie, _cLj, _nE1MOEDA, _nTxSE1)

Local _aRet := {1 , 1} //Moeda 1 e taxa 1 
Local _cFilial := '%'+ValToSql(_cFil)+'%'
Local _cPrefixo := '%'+ValToSql(_cPref)+'%'
Local _cNumero := '%'+ValToSql(_cNum)+'%'
Local _cEmissao := '%'+ValToSql(_cEmis)+'%'
Local _cCliente := '%'+ValToSql(_cClie)+'%'
Local _cLoja := '%'+ValToSql(_cLj)+'%'
Local _cAlias1 := GetNextAlias()

BeginSql alias _cAlias1
    %noparser%
    SELECT	MAX(SC5.C5_MOEDA) AS NMOEDA, MAX(SC5.C5_TXMOEDA) AS NTXMOEDA
    FROM		%table:SF2% SF2 WITH(NOLOCK) INNER JOIN %table:SD2% SD2 WITH(NOLOCK) ON
                SF2.F2_FILIAL = SD2.D2_FILIAL
            AND SF2.F2_DOC = SD2.D2_DOC
            AND SF2.F2_SERIE = SD2.D2_SERIE
            AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
            AND SF2.F2_LOJA = SD2.D2_LOJA
            AND SD2.D_E_L_E_T_ = ''
                INNER JOIN %table:SC5% SC5 WITH(NOLOCK) ON
                SC5.C5_FILIAL = SD2.D2_FILIAL
            AND SC5.C5_NUM = SD2.D2_PEDIDO
            AND SC5.D_E_L_E_T_ = ''
    WHERE		SF2.D_E_L_E_T_ = ''
            AND SF2.F2_FILIAL = %exp:_cFilial%
            AND SF2.F2_EMISSAO = %exp:_cEmissao%
            AND SF2.F2_PREFIXO = %exp:_cPrefixo%
            AND SF2.F2_DUPL = %exp:_cNumero%
            AND SF2.F2_CLIENTE = %exp:_cCliente%
            AND SF2.F2_LOJA = %exp:_cLoja%
EndSql

If (_cAlias1)->(!EOF())
    _nMoeda := (_cAlias1)->NMOEDA
    If (_cAlias1)->NMOEDA > 0 
        _aRet[1] := (_cAlias1)->NMOEDA
    Else
        _aRet[1] := _nE1MOEDA
    EndIf
    If _aRet[1] > 1
        _aRet[2] := (_cAlias1)->NTXMOEDA
    EndIf
else
    _aRet[1] := _nE1MOEDA
EndIf

(_cAlias1)->(DbCloseArea())

If _aRet[1] > 1 
    If !(_aRet[2] > 1 )
        If _nTxSE1 > 1 
            _aRet[2] := _nTxSE1
        Else
            _aRet[2] := RecMoeda( _cEmis, _aRet[1] )
        EndIf
    EndIf
Else
    _aRet[2] := RecMoeda( _cEmis, 2 )
EndIf

Return _aRet


