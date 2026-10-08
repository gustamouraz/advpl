#INCLUDE 'TOTVS.CH'
#INCLUDE "XMLXFUN.CH"
#Include 'FWADAPTEREAI.CH'

User function INTDEP()
    Local aArea      := GetArea()
    Local _cPerg := "INTDEP"

    If Select("SX2") == 0
        RpcClearEnv()
        RPCSetType(3)    //NAO CONSOME LICENSA DE USO
        If(!RpcSetEnv("99", "01", "", "", "CTB",,{"CT2"}))
            Return(Nil)
        EndIf
        lRPC := .T.
    EndIf

    if MSGYESNO( 'Essa rotina ira enviar a Depreciaao de Ativos ao PIMS MC, deseja mesmo seguir?', 'Integracao AssetDepreciation' )
        If !Pergunte(_cPerg,.T.)
        Return
        EndIf
        Processa({|| INTEGRA()}, "Integrando")
    endif
       
    RestArea(aArea)
Return

Static Function INTEGRA()
Local cXml		:= ''
Local cAlias    := getNextAlias()
Local cFil := ''
Local nAtual := 0
Private nX
Private aDados := {}
Private cMsg := ''
Private cId       := ''


BeginSQL Alias cAlias
	%noparser%
    WITH CTE_BASE AS (
        SELECT 
            TRIM(SN4.N4_FILIAL) FILIAL,
                    CASE 
                WHEN LEFT(SN3.N3_CUSTBEM,2) IN ('21','22','23','24') THEN ''
                WHEN SN3.N3_CUSTBEM IN ('2620','2621') THEN ''
            ELSE SN1.N1_XFROTA END FROTA,
            SN4.N4_VLROC1 VALOR,
            0 'PIS',
            0 'COFINS',
            TRIM(SN3.N3_CUSTBEM) CC,
            SN1.N1_CBASE
        FROM SN1010 SN1 WITH(NOLOCK) 
                INNER JOIN SN3010 SN3 WITH(NOLOCK) ON        
                    SN3.N3_CBASE =  SN1.N1_CBASE                    AND
                    SN3.N3_ITEM =   SN1.N1_ITEM                     AND
                    SN3.N3_FILIAL = SN1.N1_FILIAL                   AND
                    SN3.D_E_L_E_T_ = ''
                INNER JOIN SN4010 SN4 WITH(NOLOCK) ON    
                    SN4.N4_CBASE =  SN1.N1_CBASE                    AND
                    SN4.N4_ITEM =   SN1.N1_ITEM                     AND
                    SN4.N4_FILIAL = SN1.N1_FILIAL                   AND
                    SN4.D_E_L_E_T_ = ''                             AND
                    SN4.N4_TIPO = SN3.N3_TIPO                           
        WHERE
            LEFT(SN3.N3_FILIAL,2) IN ('01','06')                    AND
            SN1.D_E_L_E_T_ = ''                                     AND

            SN4.N4_DATA BETWEEN %Exp:DtoS(MV_PAR01)%   AND  %Exp:DtoS(MV_PAR02)%                      AND
            SN4.N4_VLROC1 > 0                                       AND
            TRIM(SN3.N3_CDEPREC) = '41102003'                       AND
            SN4.N4_TIPO IN ('10','12')                              AND
            SN4.N4_TIPOCNT = '4'                                    AND
            SN4.N4_QUANTD = 0                                       AND
            (SN1.N1_BAIXA = '' OR SN1.N1_BAIXA >= %Exp:DtoS(MV_PAR02)%)                                         
    UNION ALL 
        SELECT
            TRIM(CL2.CL2_FILIAL) FILIAL,
            CASE 
                WHEN LEFT(CL2.CL2_CCUS,2) IN ('21','22','23','24') THEN ''
                WHEN CL2.CL2_CCUS IN ('2620','2621') THEN ''
            ELSE SN1.N1_XFROTA END FROTA,
            0 VALOR,
            IIF(CL2.CL2_REG = 'F130' AND SN1.N1_MESCPIS = 0,0,CL2.CL2_VLPIS) PIS,
            IIF(CL2.CL2_REG = 'F130' AND SN1.N1_MESCPIS = 0,0,CL2.CL2_VLCOF) COFINS,        
            TRIM(CL2.CL2_CCUS) CC,
            SN1.N1_CBASE
        FROM  CL2010 CL2 WITH(NOLOCK) 
            INNER JOIN SN1010 SN1 WITH(NOLOCK) ON 
                SN1.N1_FILIAL = CL2.CL2_FILIAL AND
                SN1.N1_CBASE = CL2.CL2_CODATF AND
                SN1.N1_ITEM = CL2.CL2_ITATF AND 
                SN1.D_E_L_E_T_ = ''
            INNER JOIN SN3010 SN3 WITH(NOLOCK) ON        
                SN3.N3_CBASE =  SN1.N1_CBASE                    AND
                SN3.N3_ITEM =   SN1.N1_ITEM                     AND
                SN3.N3_FILIAL = SN1.N1_FILIAL                   AND
                SN3.D_E_L_E_T_ = ''
        WHERE 
            CL2.D_E_L_E_T_ = ''                                     AND 
            CL2.CL2_ITATF !=''                                      AND
            CL2.CL2_PER BETWEEN %Exp:DtoS(MV_PAR01)% AND %Exp:DtoS(MV_PAR02)%                         AND 
            LEFT(CL2.CL2_FILIAL,2) IN('01','06')                    AND
            TRIM(SN3.N3_CDEPREC) = '41102003'                       AND                       
            SN3.N3_TIPO IN ('01')  
        ) 
    SELECT
        BS.FILIAL,
        TRIM(IIF(BS.FROTA='',BS.FILIAL+BS.CC,BS.FROTA)) FROTA,
        SUM(BS.VALOR) - SUM(BS.PIS) - SUM(BS.COFINS) AS VALOR,
        BS.CC
    FROM CTE_BASE BS
    WHERE BS.FILIAL NOT IN ('060110','060111','010114')
    AND LEFT(BS.CC,2) NOT IN ('11')
    AND BS.CC NOT IN ('2636')
    AND NOT (BS.FILIAL = '060102' AND LEFT(BS.CC,2) = '23')
    GROUP BY
        BS.FILIAL,
        BS.FROTA,
        BS.CC

    ORDER BY 
        BS.FILIAL,
        BS.FROTA,
        BS.CC
    
EndSQL
(cAlias)->(dbGoTop())
While !(cAlias)->(Eof())
AADD( aDados, {(cAlias)->(FILIAL), (cAlias)->(FROTA), (cAlias)->(VALOR), (cAlias)->(CC)})
(cAlias)->(DbSkip())
EndDo


cData := cvaltochar(year(ddatabase))+'-'+;
                        strzero(month(ddatabase),2)+'-'+;
                        strzero(day(ddatabase),2)+;
                        strzero(val(substr(time(),1,2)),2)+':'+;
                        strzero(val(substr(time(),4,2)),2)+':'+;
                        strzero(val(substr(time(),7,2)),2)
Count To len(aDados)
ProcRegua(len(aDados))
cMsg += CVALTOCHAR( FWTimeStamp(2) ) + CRLF
for nX := 1 to len(aDados)
    if cFil <> aDados[nX][1] 

    If nX > 1 .AND. cFil <> aDados[nX][1] 
        cXml += '    </ListOfAssetDepreciation> '       + CRLF
        cXml += '    </BusinessContent> '               + CRLF
        cXml += '    </BusinessMessage> '               + CRLF
        
        ENVPIMS(cXml)

    EndIf

    cId := FWUUIDV4(.t.)
        cXml := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"' + CRLF
        cXml += 'xmlns:tot="http://www.totvs.com/">' + CRLF
        cXml += '	<soapenv:Header/> ' + CRLF
        cXml += '	<soapenv:Body> ' + CRLF
        cXml += '		<tot:receiveMessage> ' + CRLF
        cXml += '			<tot:inMsg><![CDATA[<TOTVSMessage> ' + CRLF
        cXml +='	<MessageInformation version="1.000">' + CRLF
        cXml += '		<UUID>'+cId+'</UUID> ' + CRLF
        cXml +='		<Type>BusinessMessage</Type>' + CRLF
        cXml +='		<Transaction>ASSETDEPRECIATION</Transaction>' + CRLF
        cXml +='		<StandardVersion>1.000</StandardVersion>' + CRLF
        cXml +='		<SourceApplication>QKQQVJ_DEV</SourceApplication>' + CRLF
        cXml +='		<CompanyId>01</CompanyId>' + CRLF
        cXml += '		<BranchId>'+alltrim( aDados[nX][1] )+'</BranchId> ' + CRLF
        cXml +='		<Enterprise>01</Enterprise>' + CRLF
        cXml +='		<BusinessUnit>01</BusinessUnit>' + CRLF
        cXml +='		<Product name="PROTHEUS" version="12"/>' + CRLF
        cXml +='		<GeneratedOn>'+cData+'</GeneratedOn> ' + CRLF
        cXml +='		<DeliveryType>Sync</DeliveryType>' + CRLF
        cXml +='	</MessageInformation>' + CRLF
        cXml +='                    <BusinessMessage> ' + CRLF
        cXml +='            <BusinessEvent> ' + CRLF
        cXml +='            <Entity>AssetDepreciation</Entity> ' + CRLF
        cXml +='            <Event>upsert</Event> ' + CRLF
        cXml +='            <Identification> ' + CRLF
        cXml +='            <key name="InternalId">06011500104     0001</key> ' + CRLF
        cXml +='            </Identification> ' + CRLF
        cXml +='            </BusinessEvent> ' + CRLF
        cXml +='            <BusinessContent> ' + CRLF
        cXml +='            <SelectionInformation> ' + CRLF
        cXml +='                <AssetInformation> ' + CRLF
        cXml +='                    <AssetIni/> ' + CRLF
        cXml +='                    <AssetFin/> ' + CRLF
        cXml +='                </AssetInformation> ' + CRLF
        cXml +='                <CostCenterInformation> ' + CRLF
        cXml +='                    <CostCenterIni/> ' + CRLF
        cXml +='                    <CostCenterFin/> ' + CRLF
        cXml +='                </CostCenterInformation> ' + CRLF
        cXml +='                <ListOfRuleInformation> ' + CRLF
        cXml +='                    <RuleInformation> ' + CRLF
        cXml +='                        <RuleType/> ' + CRLF
        cXml +='                        <InitialValue>0</InitialValue> ' + CRLF
        cXml +='                        <FinalValue>0</FinalValue> ' + CRLF
        cXml +='                    </RuleInformation> ' + CRLF
        cXml +='                </ListOfRuleInformation> ' + CRLF
        cXml +='            </SelectionInformation> ' + CRLF
        cXml +='            <ParametersInformation> ' + CRLF
        cXml +='                <PeriodInformation> ' + CRLF
        cXml +='                    <DateIni>'+SubStr(CVALTOCHAR(MV_PAR01),7,4) + '-' + SubStr(CVALTOCHAR(MV_PAR01),4,2) + '-' + SubStr(CVALTOCHAR(MV_PAR01),1,2)+'</DateIni> ' + CRLF
        cXml +='                    <DateFin>'+SubStr(CVALTOCHAR(MV_PAR02),7,4) + '-' + SubStr(CVALTOCHAR(MV_PAR02),4,2) + '-' + SubStr(CVALTOCHAR(MV_PAR02),1,2)+'</DateFin> ' + CRLF
        cXml +='                </PeriodInformation> ' + CRLF
        cXml +='                <FirstPart>.T.</FirstPart> ' + CRLF
        cXml +='            </ParametersInformation> ' + CRLF
        cXml +='    <ListOfAssetDepreciation>   ' + CRLF

    endif
        cXml +='    <AssetDepreciation>   ' + CRLF
        cXml +='            <AssetInformation>   ' + CRLF
        cXml +='                <CompanyId>01</CompanyId>   ' + CRLF
        cXml +='                <BranchId>'+alltrim( aDados[nX][1] )+'</BranchId>   ' + CRLF
        cXml +='                <CompanyInternalId>01|'+alltrim( aDados[nX][1] )+'</CompanyInternalId>   ' + CRLF
        cXml +='                <AssetCode>'+alltrim( aDados[nX][2] )+'</AssetCode>   ' + CRLF
        cXml +='                <CostCenterCode>'+alltrim( aDados[nX][4] )+'</CostCenterCode>   ' + CRLF
        cXml +='            </AssetInformation>   ' + CRLF
        cXml +='            <ListOfDepreciation>   ' + CRLF
        cXml +='                <Depreciation>   ' + CRLF
        cXml +='                    <PeriodDepreciationAmount>'+cValtochar(aDados[nX][3]) +'</PeriodDepreciationAmount>   ' + CRLF
        cXml +='                    <PeriodAmortizationAmount>0</PeriodAmortizationAmount>   ' + CRLF
        cXml +='                </Depreciation>   ' + CRLF
        cXml +='            </ListOfDepreciation>   ' + CRLF
        cXml +='        </AssetDepreciation>   ' + CRLF

        If nX = len(aDados)
            cXml += '    </ListOfAssetDepreciation> '       + CRLF
            cXml += '    </BusinessContent> '               + CRLF
            cXml += '    </BusinessMessage> '               + CRLF
            
            ENVPIMS(cXml)

        EndIf

cFil := aDados[nX][1]
nAtual++
IncProc("Processando registro " + cValToChar(nAtual) + " de " + cValToChar(len(aDados)) )

next 
MsgAlert('Foram Processados ' + cvaltochar(nAtual) + ' Ativos Depreciados')
Return Nil


Static Function ENVPIMS(cXml)
Local nTimeOut 	:= 240
Local aHead 	:= {}
Local cHeadRet 	:= ""
Local cRetConn, cDesc, cMsgRetorno
Local aError   := {}
Local cLastData := ''
Local nWarn   := 0
Local nSuce   := 0
Local cLog		:= ''
Local nY
// Grava Log 
cLog := ', Data de : ' + cvaltochar(MV_PAR01) + ' Data Ate : ' + cvaltochar(MV_PAR02) 
cLog += ' - ' + UsrRetName(RetCodUsr()) + CRLF
U_FMKLOGTI("\logs\fechamento\intdep", "inicio", cLog ) 

cXml += '</TOTVSMessage>]]></tot:inMsg> ' + CRLF
cXml += '		</tot:receiveMessage> ' + CRLF
cXml += '	</soapenv:Body> ' + CRLF
cXml += '</soapenv:Envelope> ' + CRLF

cUrl := SuperGetMv("MV_EAIURL2",.F.,   'http://claides.pimsconnector-teste.totvs.com.br/PIMSConnectorWS/EAIService')
            aadd(aHead,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
            aadd(aHead,'Content-Type: application/xml')
cLastData := SUBSTR(CVALTOCHAR(MV_PAR06),7,4) +  '-' + SUBSTR(CVALTOCHAR(MV_PAR06),4,2) + '-' + SUBSTR(CVALTOCHAR(MV_PAR06),1,2) 

cMsgRetorno := HttpPost( cUrl, nil, cXml, nTimeOut , aHead , @cHeadRet )
cRetConn := CValToChar(HttpGetStatus(@cDesc))
    If cRetConn = '200'
			cMsg += cId + ';'
                if '&lt;Status>OK&lt;/Status>' $ cMsgRetorno  
                cMsg +=  CVALTOCHAR(aDados[nX][1]) + ';'+ CVALTOCHAR(aDados[nX][2]) + ';'+ CVALTOCHAR(aDados[nX][3]) + ';'+ CVALTOCHAR(aDados[nX][4]) + ';Sucesso'+ CRLF
				  MSGINFO( 'Integração Enviada', 'Sucesso' )
				nSuce++
                else
				
				cMsg +=  CVALTOCHAR(aDados[nX][1]) + ';'+ CVALTOCHAR(aDados[nX][2]) + ';'+ CVALTOCHAR(aDados[nX][3]) + ';'+ CVALTOCHAR(aDados[nX][4]) + ';Falha'
					if 'type="WARNING">'$ cMsgRetorno 
					aError := STRTOKARR(cMsgRetorno, ';')
					for nY := 1 to LEN( aError )
						if 'WARNING' $ STRTOKARR(cMsgRetorno, ';')[nY]
							cMsg += STRTOKARR(cMsgRetorno, ';')[nY]
						ENDIF
					next 
						cMsg += SUBSTR( cMsgRetorno,  At('<Message code="AE003" type="WARNING">',cMsgRetorno,1), At('</Message>',cMsgRetorno,1) )
						nWarn++
					endif
				cMsg += CRLF
                endif
            
    else
		cMsg +=  CVALTOCHAR(aDados[nX][1]) + ';'+ CVALTOCHAR(aDados[nX][2]) + ';'+ CVALTOCHAR(aDados[nX][3]) + ';'+ CVALTOCHAR(aDados[nX][4]) + ';Falha' + ';Erro na Autenticaao
		nWarn++
    endif    

Return Nil 
