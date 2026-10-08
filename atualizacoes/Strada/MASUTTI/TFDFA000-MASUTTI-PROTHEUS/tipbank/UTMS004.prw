#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TopCONN.CH"
#Include "FWBrowse.ch"

//----------------------------------------------------------
/*/{Protheus.doc} UTMS004 
Função UTMS004 
Data  07/2021
@description Rotina para envio de XML para proprietario de veiculo subalocado 
@author Totvs SC
@return nulo
@owner Masutti
@version Protheus 12 ou superior.
/*/
//----------------------------------------------------------
User function UTMS004()

    Local cXMLCTe   := "" 
    Local cXMLCTeEnv   := ""
    Local nTry      := 1
	Local nMaxTry	:= 10
    Local lEnvMail  := .F.
   
    // DTQ->(DbSelectArea("DTQ"))
	// DTQ->(DbSetOrder(2))
	// DTQ->(DbSeek(xFilial("DTQ") + '020101' + '004078' ))
     
    
    DbSelectArea("DTA")
    DTA->(DbSetOrder(2))
    If DTA->(DbSeek(xFilial("DTA")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM ))

        DbSelectArea("DA3")
        DA3->(DbSetOrder(1))

        While DTA->(!EOF()) ;
            .AND. xFilial("DTA")+DTA->DTA_FILORI+DTA->DTA_VIAGEM == xFilial("DTQ")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM
           
            IF DA3->(DbSeek(xFilial("DA3")+DTA->DTA_CODVEI))
                IF DA3->DA3_FROVEI == "2" // TERCEIRO 

                    DbSelectArea("DT6")
                    DT6->(DbSetOrder(1))
                    IF DT6->(DbSeek(xFilial("DT6")+DTA->DTA_FILORI+DTA->DTA_DOC+DTA->DTA_SERIE)) 

                        cTo := Alltrim(Posicione("SA2",1, xFilial("SA2") + DA3->DA3_CODFOR + DA3->DA3_LOJFOR ,"A2_EMAIL"))

                        if !EMPTY(cTo)

                            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                            //³   *******  1 - CAPTURA O XML DO CTES  *******    ³
                            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                            //³ Identificacao do Ambiente.                                      ³
                            //³ 1 - Producao                                                    ³
                            //³ 2 - Homologacao                                                 ³
                            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                            cCAmbiente  := Alltrim(DT6->DT6_AMBIEN)
                            cSerie      := PadR( DTA->DTA_SERIE  ,TamSx3("F2_SERIE")[1]) 
                            cNota       := PadR( DTA->DTA_DOC  ,TamSx3("F2_DOC")[1]) 
                            ClieFor     := PadR( DT6->DT6_CLIDEV  ,TamSx3("F2_CLIENTE")[1])
                            cLojaFor    := PadR( DT6->DT6_LOJDEV  ,TamSx3("F2_LOJA")[1])
 

                            cXMLCTe := U_GSPEDXML(AllTrim(cSerie+cNota),'57', .T.)

                            //ConOut(cXMLCTe)

                            If Empty(cXMLCTe)
                                MsgAlert("Não foi possivel obter o XML do CT-e.", "XML CT-e")
                                Exit
                            EndIf

                            cXMLCTeEnv := '<?xml version="1.0" encoding="UTF-8"?>'
                            cXMLCTeEnv += '<cteProc versao="3.00" xmlns="http://www.portalfiscal.inf.br/cte">'
                            cXMLCTeEnv += cXMLCTe
                            cXMLCTeEnv += '</cteProc>'

                            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                            //³   *******  2 - GERA O ARQUIVOS XML     *******   ³
                            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                            cDirect  := "\temp\"
                            cArquivo := "XML_CTE_"  + alltrim(cNota) + alltrim(cSerie) +  alltrim(ClieFor) + alltrim(ClieFor) + ".xml"

                            //Cria o arquivo
                            nHdl := fCreate(cDirect+cArquivo)   
                            //Se houve erro na criação
                            If nHdl == -1
                                ConOut(" **** UTMS004 - Rotina para envio de XML para proprietario de veiculo subalocado  ")
                                ConOut("Não foi possível gerar o arquivo!")
                            Else
                                fWrite(nHdl, cXMLCTeEnv )
                                //Finalizando o Handle
                                fClose(nHdl)
                            Endif

                            cNomeFornecedor := Alltrim(Posicione("SA2",1, xFilial("SA2") + DA3->DA3_CODFOR + DA3->DA3_LOJFOR ,"A2_NREDUZ"))
                            cViagemEnv := alltrim(DTQ->DTQ_VIAGEM)


                            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                            //³   *******  3 - ENVIA O ARQUIVOS XML     *******  ³
                            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                            

                            cSubject := "XML(s) de CTE(s) de Subcontratação de Transporte - Masutti "
                            cMSGHTML := getHTML( cNomeFornecedor , cViagemEnv , ALLTRIM( DTA->DTA_DOC ) +'/'+ ALLTRIM(DTA->DTA_SERIE) )    
                            lTLS := .T. 
                            aAnexos := {}
                            aAdd(aAnexos, cDirect+cArquivo )

                            //U_GEnvMail(cTo, cSubject , cMSGHTML , aAnexos , .T. , lTLS)
                            //Tratativa para tentar reenviar email quando houver falha
                            For nTry := 1 To nMaxTry 
                                FWMsgRun(, {|| lEnvMail := U_GEnvMail(cTo, cSubject , cMSGHTML , aAnexos , .T. , lTLS) }, "Enviando e-mail", "Tentativa " + CValToChar(nTry) + " de " + CValToChar(nMaxTry)+ "...")
                                If lEnvMail
                                    EXIT
                                EndIf
                            Next nTry

                            If lEnvMail
                                MsgInfo("Sucesso ao enviar e-mail", "Sucesso")
                            EndIf

                            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                            //³   *******  4 - APAGA O ARQUIVOS XML     *******  ³
                            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                            FERASE(cDirect+cArquivo)
                        ELSE 
                            ConOut(" **** UTMS004 - Rotina para envio de XML para proprietario de veiculo subalocado  ")
                            ConOut(" **** EMAIL DE FORNECEDOR NÃO PREENCHIDO - COD/LOJA FORNECEDOR : " +  DA3->DA3_CODFOR + '/' + DA3->DA3_LOJFOR  )
                        Endif
                    
                    Endif

                    DT6->(DbCloseArea()) 
                Endif
            Endif
            
            DTA->(DbSkip())
        EndDo

        DA3->(DbCloseArea())

    Endif
 
    DTA->(DbCloseArea())

    //RESET ENVIRONMENT

Return 

 
//----------------------------------------------------------
/*/{Protheus.doc} getHTML 
Função getHTML 
Data  07/2021
@description funcao para montagem de HMTL DE ENVIO DE E-MAIL
@author Totvs SC
@return cHTML
@owner Masutti
@version Protheus 12 ou superior.
/*/
//----------------------------------------------------------
Static Function getHTML( cNomeFornecedor , cViagemEnv , cDocSerie)

cHTML :=''
cHTML +=' <cHTML>                                                                                                                                                                                                                                                      '
cHTML +='    <head>                                                                                                                                                                                                                                                   '
cHTML +='       <style>                                                                                                                                                                                                                                               '
cHTML +='          .banner-color {                                                                                                                                                                                                                                    '
cHTML +='          background-color: #eb681f;                                                                                                                                                                                                                         '
cHTML +='          }                                                                                                                                                                                                                                                  '
cHTML +='          .title-color {                                                                                                                                                                                                                                     '
cHTML +='          color: #3a55ad;                                                                                                                                                                                                                                    '
cHTML +='          }                                                                                                                                                                                                                                                  '
cHTML +='          .button-color {                                                                                                                                                                                                                                    '
cHTML +='          background-color: #3a55ad;                                                                                                                                                                                                                         '
cHTML +='          }                                                                                                                                                                                                                                                  '
cHTML +='          @media screen and (min-width: 500px) {                                                                                                                                                                                                             '
cHTML +='          .banner-color {                                                                                                                                                                                                                                    '
cHTML +='          background-color: #3a55ad;                                                                                                                                                                                                                         '
cHTML +='          }                                                                                                                                                                                                                                                  '
cHTML +='          .title-color {                                                                                                                                                                                                                                     '
cHTML +='          color: #0e277a;                                                                                                                                                                                                                                    '
cHTML +='          }                                                                                                                                                                                                                                                  '
cHTML +='          .button-color {                                                                                                                                                                                                                                    '
cHTML +='          background-color: #3a55ad;                                                                                                                                                                                                                         '
cHTML +='          }                                                                                                                                                                                                                                                  '
cHTML +='          }                                                                                                                                                                                                                                                  '
cHTML +='       </style>                                                                                                                                                                                                                                              '
cHTML +='    </head>                                                                                                                                                                                                                                                  '
cHTML +='    <body>                                                                                                                                                                                                                                                   '
cHTML +='       <div style="background-color:#ececec;padding:0;margin:0 auto;font-weight:200;width:100%!important">                                                                                                                                                   '
cHTML +='          <table align="center" border="0" cellspacing="0" cellpadding="0" style="table-layout:fixed;font-weight:200;font-family:Helvetica,Arial,sans-serif" width="100%">                                                                                   '
cHTML +='             <tbody>                                                                                                                                                                                                                                         '
cHTML +='                <tr>                                                                                                                                                                                                                                         '
cHTML +='                   <td align="center">                                                                                                                                                                                                                       '
cHTML +='                      <center style="width:100%">                                                                                                                                                                                                            '
cHTML +='                         <table bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0" style="margin:0 auto;max-width:512px;font-weight:200;width:inherit;font-family:Helvetica,Arial,sans-serif" width="512">                                         '
cHTML +='                            <tbody>                                                                                                                                                                                                                          '
cHTML +='                                                                                                                                                                                                                                                             '
cHTML +='                               <tr>                                                                                                                                                                                                                          '
cHTML +='                                  <td align="left">                                                                                                                                                                                                          '
cHTML +='                                     <table border="0" cellspacing="0" cellpadding="0" style="font-weight:200;font-family:Helvetica,Arial,sans-serif" width="100%">                                                                                          '
cHTML +='                                           <tr>                                                                                                                                                                                                              '
cHTML +='                                              <td width="100%">                                                                                                                                                                                              '
cHTML +='                                                 <table border="0" cellspacing="0" cellpadding="0" style="font-weight:200;font-family:Helvetica,Arial,sans-serif" width="100%">                                                                              '
cHTML +='                                                    <tbody>                                                                                                                                                                                                  '
cHTML +='                                                                                                                                                                                                                                                             '
cHTML +='                                                       <tr>                                                                                                                                                                                                  '
cHTML +='                                                          <td align="center" style="padding:20px 0 10px 0">                                                                                                                                                  '
cHTML +='                                                             <table border="0" cellspacing="0" cellpadding="0" style="font-weight:200;font-family:Helvetica,Arial,sans-serif" width="100%">                                                                  '
cHTML +='                                                                <tbody>                                                                                                                                                                                      '
cHTML +='                                                                   <tr>                                                                                                                                                                                      '
cHTML +='                                                                      <td align="center" width="100%" style="padding: 0 15px;text-align: justify;color: rgb(76, 76, 76);font-size: 12px;line-height: 18px;">                                                 '
cHTML +='                                                                         <h3 style="font-weight: 600; padding: 0px; margin: 0px; font-size: 16px; line-height: 24px; text-align: center;" class="title-color">Olá '+cNomeFornecedor+',</h3>                      '
cHTML +='                                                                         <p style="margin: 20px 0 30px 0;font-size: 15px;text-align: center;">Segue em anexo XML(s) de CTE(s) de Subcontratação</p>                                                       '
cHTML +='                                                                         <p style="margin: -25px 0 30px 0;font-size: 15px;text-align: center;">da Viagem Nº <b>'+cViagemEnv+'</b> </p>                                                      '
cHTML +='                                                                         <p style="margin: -25px 0 30px 0;font-size: 15px;text-align: center;">Num/Serie CTE <b>'+cDocSerie+'</b> </p>                                                      '

cHTML +='                                                                         <br>                                                                                                                                                                                '
cHTML +='                                                                      </td>                                                                                                                                                                                  '
cHTML +='                                                                   </tr>                                                                                                                                                                                     '
cHTML +='                                                                </tbody>                                                                                                                                                                                     '
cHTML +='                                                             </table>                                                                                                                                                                                        '
cHTML +='                                                          </td>                                                                                                                                                                                              '
cHTML +='                                                       </tr>                                                                                                                                                                                                 '
cHTML +='                                                       <tr>                                                                                                                                                                                                  '
cHTML +='                                                       </tr>                                                                                                                                                                                                 '
cHTML +='                                                       <tr>                                                                                                                                                                                                  '
cHTML +='                                                       </tr>                                                                                                                                                                                                 '
cHTML +='                                                    </tbody>                                                                                                                                                                                                 '
cHTML +='                                                 </table>                                                                                                                                                                                                    '
cHTML +='                                              </td>                                                                                                                                                                                                          '
cHTML +='                                           </tr>                                                                                                                                                                                                             '
cHTML +='                                        </tbody>                                                                                                                                                                                                             '
cHTML +='                                     </table>                                                                                                                                                                                                                '
cHTML +='                                  </td>                                                                                                                                                                                                                      '
cHTML +='                               </tr>                                                                                                                                                                                                                         '
cHTML +='                               <tr>                                                                                                                                                                                                                          '
cHTML +='                                  <td align="left">                                                                                                                                                                                                          '
cHTML +='                                     <table bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0" style="padding:0 24px;color:#999999;font-weight:200;font-family:Helvetica,Arial,sans-serif" width="100%">                                           '
cHTML +='                                        <tbody>                                                                                                                                                                                                              '
cHTML +='                                           <tr>                                                                                                                                                                                                              '
cHTML +='                                              <td align="center" width="100%">                                                                                                                                                                               '
cHTML +='                                                 <table border="0" cellspacing="0" cellpadding="0" style="font-weight:200;font-family:Helvetica,Arial,sans-serif" width="100%">                                                                              '
cHTML +='                                                    <tbody>                                                                                                                                                                                                  '
cHTML +='                                                       <tr>                                                                                                                                                                                                  '
cHTML +='                                                          <td align="center" valign="middle" width="100%" style="border-top:1px solid #d9d9d9;padding:12px 0px 20px 0px;text-align:center;color:#4c4c4c;font-weight:200;font-size:12px;line-height:18px">    '
cHTML +='  															  Enviado Automaticamente p/ Protheus                                                                                                                                                            '
cHTML +='                                                             <br><b>MASUTTI - ' +  STR( YEAR(DATE()) ) + ' </b>                                                                                                                                                                       '
cHTML +='                                                          </td>                                                                                                                                                                                              '
cHTML +='                                                       </tr>                                                                                                                                                                                                 '
cHTML +='                                                    </tbody>                                                                                                                                                                                                 '
cHTML +='                                                 </table>                                                                                                                                                                                                    '
cHTML +='                                              </td>                                                                                                                                                                                                          '
cHTML +='                                           </tr>                                                                                                                                                                                                             '
cHTML +='                                           <tr>                                                                                                                                                                                                              '
cHTML +='                                              <td align="center" width="100%">                                                                                                                                                                               '
cHTML +='                                                 <table border="0" cellspacing="0" cellpadding="0" style="font-weight:200;font-family:Helvetica,Arial,sans-serif" width="100%">                                                                              '
cHTML +='                                                    <tbody>                                                                                                                                                                                                  '
cHTML +='                                                       <tr>                                                                                                                                                                                                  '
cHTML +='                                                          <td align="center" style="padding:0 0 8px 0" width="100%"></td>                                                                                                                                    '
cHTML +='                                                       </tr>                                                                                                                                                                                                 '
cHTML +='                                                    </tbody>                                                                                                                                                                                                 '
cHTML +='                                                 </table>                                                                                                                                                                                                    '
cHTML +='                                              </td>                                                                                                                                                                                                          '
cHTML +='                                           </tr>                                                                                                                                                                                                             '
cHTML +='                                        </tbody>                                                                                                                                                                                                             '
cHTML +='                                     </table>                                                                                                                                                                                                                '
cHTML +='                                  </td>                                                                                                                                                                                                                      '
cHTML +='                               </tr>                                                                                                                                                                                                                         '
cHTML +='                            </tbody>                                                                                                                                                                                                                         '
cHTML +='                         </table>                                                                                                                                                                                                                            '
cHTML +='                      </center>                                                                                                                                                                                                                              '
cHTML +='                   </td>                                                                                                                                                                                                                                     '
cHTML +='                </tr>                                                                                                                                                                                                                                        '
cHTML +='             </tbody>                                                                                                                                                                                                                                        '
cHTML +='          </table>                                                                                                                                                                                                                                           '
cHTML +='       </div>                                                                                                                                                                                                                                                '
cHTML +='    </body>                                                                                                                                                                                                                                                  '
cHTML +=' </cHTML>'

Return cHTML

