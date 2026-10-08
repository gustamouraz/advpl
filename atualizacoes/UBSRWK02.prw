
#Include 'protheus.ch'
#include 'report.ch'

/*/{Protheus.doc} User Function UBSRWK02
    RELATÓRIO DE CONTROLE DE LOTES SEMENTES (TERCEIROS)
    @type  Function
    @author Willian Kaneta
    @since 01/07/2021
    @version 1.0
    /*/
User Function UBSRWK02()
    Private cPerg   	   := "UBSRWK02"
    Private cMyAlias	   := GetNextAlias()	

    CriaSX1()

    If !Pergunte(cPerg,.T.)
		Return Nil
	EndIf

    oReport  := ReportDef()
	oReport:PrintDialog()

Return Nil

/*/{Protheus.doc} ReportDef
//TODO	Define o Objeto da Classe TReport utilizado na impressão do relatório
@author Willian Kaneta
@since 27/03/2019
@version 1.0
@type function
/*/
Static Function ReportDef()	
	Local oReport	:= Nil
	Local oSec1		:= Nil
	Local cRptTitle	:= "Relatório de Controle de Lote de Sementes - Grupo Masutti" 
	Local cRptDescr	:= "Este programa emite a Impressão do Relatório de Controle de Lote de Sementes "
    
	DEFINE REPORT oReport NAME "UBSREL02" TITLE cRptTitle PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION cRptDescr	TOTAL IN COLUMN
	oReport:SetLandscape()

	DEFINE SECTION oSec1 			OF  oReport TITLE cRptTitle TABLES "cMyAlias" TOTAL IN COLUMN
    DEFINE CELL NAME 'FILUBS'  OF oSec1 ALIAS "cMyAlias"   TITLE 'Filial' 
    DEFINE CELL NAME 'SAFRA'   OF oSec1 ALIAS "cMyAlias"   TITLE 'Safra' 
    DEFINE CELL NAME 'CODPROD' OF oSec1 ALIAS "cMyAlias"   TITLE 'Cod. Produto'
    DEFINE CELL NAME 'DESCPRD' OF oSec1 ALIAS "cMyAlias"   TITLE 'Desc. Produto'
    DEFINE CELL NAME 'DESCFOR' OF oSec1 ALIAS "cMyAlias"   TITLE 'Desc. Fornecedor'
    DEFINE CELL NAME 'NOTAFIS' OF oSec1 ALIAS "cMyAlias"   TITLE 'Nota Fiscal'
    DEFINE CELL NAME 'SERIENF' OF oSec1 ALIAS "cMyAlias"   TITLE 'Série da NF'
    DEFINE CELL NAME 'DTNF'    OF oSec1 ALIAS "cMyAlias"   TITLE 'Data da Nota Fiscal'
    DEFINE CELL NAME 'DTPRD'   OF oSec1 ALIAS "cMyAlias"   TITLE 'Produção' 
    DEFINE CELL NAME 'VARIED'  OF oSec1 ALIAS "cMyAlias"   TITLE 'Variedade' 
    DEFINE CELL NAME 'LOTE'    OF oSec1 ALIAS "cMyAlias"   TITLE 'Lote' 
    DEFINE CELL NAME 'CATEGO'  OF oSec1 ALIAS "cMyAlias"   TITLE 'Categoria' 
    DEFINE CELL NAME 'PENEIR'  OF oSec1 ALIAS "cMyAlias"   TITLE 'Peneira' 
    DEFINE CELL NAME 'PMS'     OF oSec1 ALIAS "cMyAlias"   TITLE 'PMS' 
    DEFINE CELL NAME 'VLPRDSC' OF oSec1 ALIAS "cMyAlias"   TITLE 'Volume Total Produzido (SC)'
    DEFINE CELL NAME 'VLTOPRD' OF oSec1 ALIAS "cMyAlias"   TITLE 'Volume Total Produzido (KG)'
    DEFINE CELL NAME 'FATURAD' OF oSec1 ALIAS "cMyAlias"   TITLE 'Faturado (KG)'
    DEFINE CELL NAME 'DESCART' OF oSec1 ALIAS "cMyAlias"   TITLE 'Descartado (KG)'
    DEFINE CELL NAME 'DEVOLVI' OF oSec1 ALIAS "cMyAlias"   TITLE 'Devolvido (KG)'
    DEFINE CELL NAME 'SALDOKG' OF oSec1 ALIAS "cMyAlias"   TITLE 'Saldo (KG)'
					
Return oReport

/*/{Protheus.doc} PrintReport
//TODO	Realiza a impressão do relatório
@author Willian Kaneta
@since 27/03/2019
@version 1.0
@type function
/*/
Static Function PrintReport(oReport)
	Local oSec1	    := oReport:Section(1)
    Local nAtual    := 0
    Local nTotal    := 0
    
    // SQL Server: preserva OUTER APPLY no SQL enviado ao DBAccess.
    BeginSql alias cMyAlias
        %noparser%
        
        SELECT  A.FILIAL
                ,A.SAFRA
                ,A.B1_COD
                ,A.B1_DESC
                ,ISNULL(FORN.A2_NOME, '') AS DESC_FORNECEDOR
                ,ISNULL(NF.F1_DOC, '') AS NOTA_FISCAL
                ,ISNULL(NF.F1_SERIE, '') AS SERIE_NF
                ,ISNULL(NF.F1_EMISSAO, '') AS DATA_NF
                ,A.DATA_PRODUCAO
                ,A.VARIEDADE
                ,A.LOTE
                ,A.CATEGORIA
                ,A.PENEIRA
                ,A.PMS
                ,A.VOLUME_TOTAL_PRODUZIDO_SC
                ,A.VOLUME_TOTAL_PRODUZIDO
                ,A.FATURADO
                ,A.DESCARTADO
                ,A.DEVOLVIDO
                ,((A.VOLUME_TOTAL_PRODUZIDO - (A.FATURADO + A.DESCARTADO)) + A.DEVOLVIDO) AS SALDO_KG
        FROM (
            SELECT  NP9.NP9_FILIAL AS FILIAL
                    ,NP9.NP9_CODSAF AS SAFRA
                    ,B1_COD
                    ,B1_DESC
                    ,NP9_DATA AS DATA_PRODUCAO
                    ,NP9.NP9_CTVAR AS VARIEDADE
                    ,NP9.NP9_LOTE AS LOTE
                    ,NP9.NP9_CATEG AS CATEGORIA
                    ,NP9.NP9_PENE AS PENEIRA
                    ,NP9.NP9_PSMDSC AS PMS
                    ,NP9.NP9_QTD2UM AS VOLUME_TOTAL_PRODUZIDO_SC
                    ,NP9.NP9_QUANT AS VOLUME_TOTAL_PRODUZIDO
                    ,ISNULL((
                            SELECT SUM(D2.D2_QUANT)
                            FROM %table:SD2% AS D2
                            WHERE NP9.NP9_TIPLOT = 2
                                AND NP9.NP9_LOTE = D2.D2_LOTECTL
                                AND D2.D2_FILIAL = NP9.NP9_FILIAL
                                AND D2.D_E_L_E_T_ <> '*'
                            ), 0) AS FATURADO
                    ,ISNULL((
                            SELECT SUM(D3_QUANT)
                            FROM %table:SD3%
                            WHERE D3_LOTECTL = NP9.NP9_LOTE
                                AND D3_LOCAL = '16'
                                AND D3_GRUPO = SUBSTRING(NP9.NP9_PROD, 1, 3)
                                AND D3_OP = ''
                                AND D3_CF = 'DE4'
                                AND D3_TM = '499'
                                AND D3_FILIAL = NP9.NP9_FILIAL
                                AND D3_DOC IN (
                                    SELECT D3_DOC
                                    FROM %table:SD3%
                                    WHERE D3_LOTECTL = NP9.NP9_LOTE
                                        AND D3_LOCAL = NP9.NP9_LOCAL
                                        AND D3_GRUPO = SUBSTRING(NP9.NP9_PROD, 1, 3)
                                        AND D3_OP = ''
                                        AND D3_CF = 'RE4'
                                        AND D3_TM = '999'
                                        AND D3_LOCAL = '25'
                                        AND D3_FILIAL = NP9.NP9_FILIAL
                                        AND D_E_L_E_T_ <> '*'
                                        AND D3_ESTORNO = ''
                                    )
                                AND D_E_L_E_T_ <> '*'
                                AND D3_ESTORNO = ''
                            ), 0) AS TRANSFERIDO
                    ,ISNULL((
                            SELECT SUM(D3_QUANT)
                            FROM %table:SD3%
                            WHERE D3_LOTECTL = ' '
                                AND (
                                    D3_LOCAL = '01'
                                    OR D3_LOCAL = '30'
                                    )
                                AND D3_GRUPO = '325'
                                AND D3_OP = ''
                                AND D3_CF = 'DE4'
                                AND D3_TM = '499'
                                AND D3_FILIAL = NP9.NP9_FILIAL
                                AND D3_DOC IN (
                                    SELECT D3_DOC
                                    FROM %table:SD3%
                                    WHERE D3_LOTECTL = NP9.NP9_LOTE
                                        AND D3_LOCAL = NP9.NP9_LOCAL
                                        AND D3_GRUPO = SUBSTRING(NP9.NP9_PROD, 1, 3)
                                        AND D3_OP = ''
                                        AND D3_CF = 'RE4'
                                        AND D3_TM = '999'
                                        AND D3_FILIAL = NP9.NP9_FILIAL
                                        AND D_E_L_E_T_ <> '*'
                                        AND D3_ESTORNO = ''
                                    )
                                AND D_E_L_E_T_ <> '*'
                                AND D3_ESTORNO = ''
                            ), 0) AS DESCARTADO
                    ,ISNULL((
                            SELECT SUM(D3_QUANT)
                            FROM %table:SD3%
                            WHERE D3_LOTECTL = NP9.NP9_LOTE
                                AND D3_LOCAL = '25'
                                AND D3_GRUPO = SUBSTRING(NP9.NP9_PROD, 1, 3)
                                AND D3_OP = ''
                                AND D3_CF = 'DE4'
                                AND D3_TM = '499'
                                AND D3_FILIAL = NP9.NP9_FILIAL
                                AND D3_DOC IN (
                                    SELECT D3_DOC
                                    FROM %table:SD3%
                                    WHERE D3_LOTECTL = NP9.NP9_LOTE
                                        AND D3_LOCAL = NP9.NP9_LOCAL
                                        AND D3_GRUPO = SUBSTRING(NP9.NP9_PROD, 1, 3)
                                        AND D3_OP = ''
                                        AND D3_CF = 'RE4'
                                        AND D3_TM = '999'
                                        AND D3_LOCAL = '16'
                                        AND D3_FILIAL = NP9.NP9_FILIAL
                                        AND D_E_L_E_T_ <> '*'
                                        AND D3_ESTORNO = ''
                                    )
                                AND D_E_L_E_T_ <> '*'
                                AND D3_ESTORNO = ''
                            ), 0) AS DEVOLVIDO
                FROM %table:NP9% AS NP9
                INNER JOIN %table:SB1% AS B1 ON NP9.NP9_PROD = B1.B1_COD
                    AND B1.D_E_L_E_T_ <> '*'
                INNER JOIN %table:SBM% AS BM ON BM.BM_GRUPO = B1.B1_GRUPO
                    AND BM.D_E_L_E_T_ <> '*'
                WHERE NP9.D_E_L_E_T_ <> '*'
                    AND BM.BM_GRUPO = '325'
                    AND NP9.NP9_TIPLOT = 2
                    AND NP9.NP9_CODSAF = %EXP:MV_PAR01%
                    AND NP9.NP9_FILIAL = %EXP:MV_PAR02%
                    AND NP9.NP9_LOCAL  = %EXP:MV_PAR03%
            ) A            
        OUTER APPLY (
            SELECT TOP (1)
                   F1.F1_DOC
                  ,F1.F1_SERIE
                  ,F1.F1_EMISSAO
                  ,F1.F1_FORNECE
                  ,F1.F1_LOJA
            FROM %table:SF1% AS F1
            WHERE F1.F1_FILIAL = A.FILIAL
              AND F1.F1_TIPO = 'N'
              AND F1.D_E_L_E_T_ <> '*'
              AND EXISTS (
                  SELECT 1
                  FROM %table:SD1% AS D1
                  WHERE D1.D1_FILIAL = F1.F1_FILIAL
                    AND D1.D1_DOC = F1.F1_DOC
                    AND D1.D1_SERIE = F1.F1_SERIE
                    AND D1.D1_FORNECE = F1.F1_FORNECE
                    AND D1.D1_LOJA = F1.F1_LOJA
                    AND D1.D1_COD = A.B1_COD
                    AND D1.D1_LOTECTL = A.LOTE
                    AND D1.D_E_L_E_T_ <> '*'
              )
            ORDER BY F1.F1_DTDIGIT ASC, F1.R_E_C_N_O_ ASC
        ) AS NF
        OUTER APPLY (
            SELECT TOP (1) A2.A2_NOME
            FROM %table:SA2% AS A2
            WHERE A2.A2_FILIAL = %xFilial:SA2%
              AND A2.A2_COD = NF.F1_FORNECE
              AND A2.A2_LOJA = NF.F1_LOJA
              AND A2.D_E_L_E_T_ <> '*'
            ORDER BY A2.R_E_C_N_O_ ASC
        ) AS FORN
    EndSql

    Count to nTotal
	oReport:SetMeter(nTotal)
    (cMyAlias)->(DbGoTop())

	oSec1:Init()		
    
   While !oReport:Cancel() .AND. (cMyAlias)->(!EOF())
        nAtual++
        oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
        oReport:IncMeter()

        oSec1:Cell('FILUBS'  ):SetValue((cMyAlias)->FILIAL                      )
        oSec1:Cell('SAFRA'   ):SetValue((cMyAlias)->SAFRA                       )
        oSec1:Cell('CODPROD' ):SetValue((cMyAlias)->B1_COD                      )
        oSec1:Cell('DESCPRD' ):SetValue((cMyAlias)->B1_DESC                     )
        oSec1:Cell('DESCFOR' ):SetValue((cMyAlias)->DESC_FORNECEDOR             )
        oSec1:Cell('NOTAFIS' ):SetValue((cMyAlias)->NOTA_FISCAL                 )
        oSec1:Cell('SERIENF' ):SetValue((cMyAlias)->SERIE_NF                    )
        oSec1:Cell('DTNF'    ):SetValue(DTOC(STOD((cMyAlias)->DATA_NF))         )
        oSec1:Cell('DTPRD'   ):SetValue(DTOC(STOD((cMyAlias)->DATA_PRODUCAO))   )
        oSec1:Cell('VARIED'  ):SetValue((cMyAlias)->VARIEDADE                   )
        oSec1:Cell('LOTE'    ):SetValue((cMyAlias)->LOTE                        )      
        oSec1:Cell('CATEGO'  ):SetValue((cMyAlias)->CATEGORIA                   )
        oSec1:Cell('PENEIR'  ):SetValue((cMyAlias)->PENEIRA                     )
        oSec1:Cell('PMS'     ):SetValue((cMyAlias)->PMS                         )
        oSec1:Cell('VLPRDSC' ):SetValue((cMyAlias)->VOLUME_TOTAL_PRODUZIDO_SC   )
        oSec1:Cell('VLTOPRD' ):SetValue((cMyAlias)->VOLUME_TOTAL_PRODUZIDO      )
        oSec1:Cell('FATURAD' ):SetValue((cMyAlias)->FATURADO                    )
        oSec1:Cell('DESCART' ):SetValue((cMyAlias)->DESCARTADO                  )
        oSec1:Cell('DEVOLVI' ):SetValue((cMyAlias)->DEVOLVIDO                   )
        oSec1:Cell('SALDOKG' ):SetValue((cMyAlias)->SALDO_KG                    )

        //Imprimindo a linha atual
        oSec1:PrintLine()
        (cMyAlias)->(DBSkip())
    EndDo

	oSec1:Finish()
	
Return Nil

/*/{Protheus.doc} CriaSX1
Cria perguntas no dicionario de dados
@type function
@author  Willian Kaneta
@since   22/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------

static function CriaSX1()
  
    CPCF001(cPerg,"01","Safra ?"                ,"Safra ?"              ,"Safra ?"                  , "mv_ch1"  ,"C" ,15,0,0    ,"G",""            ,"NJU"       ,"","","mv_par01","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
    CPCF001(cPerg,"02","Filial ?"               ,"Filial ?"             ,"Filial ?"                 , "mv_ch2"  ,"C" ,06,0,0    ,"G",""            ,"SM0"       ,"","","mv_par02","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
    CPCF001(cPerg,"03","Armazém ?"              ,"Armazém ?"            ,"Armazém ?"                , "mv_ch3"  ,"C" ,02,0,0    ,"G",""            ,"NNR"       ,"","","mv_par03","","","","","","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")
       
return( nil )

/*/{Protheus.doc}
@obs CPCF001
@author Willian Kaneta
@type User Function
@description Funcao para criar grupo de perguntas no mesmo molde da padrao.
@since 22/06/2021
@version Protheus 12
 
@param 01 - cGrupo  , Caracter  , Nome do grupo de pergunta.
@param 02 - cOrdem  , Caracter  , Ordem de apresentacao das perguntas na tela.
@param 03 - cPergunt , Caracter  , Texto da pergunta a ser apresentado na tela.
@param 04 - cPerSpa , Caracter  , Texto em espanhol da pergunta a ser apresentado na tela.
@param 05 - cPerEng , Caracter  , Texto em ingles da pergunta a ser apresentado na tela.
@param 06 - cVar       , Caracter  , Variavel do item.
@param 07 - cTipo      , Caracter  , Tipo do conteudo de resposta da pergunta.
@param 08 - nTamanho , Numerico  , Tamanho do campo para a resposta da pergunta.
@param 09 - nDecimal , Numerico  , Numero de casas decimais da resposta, se houver.
@param 10 - nPresel , Numerico  , Valor que define qual o item do combo estara selecionado na apresentacao da tela. Este campo somente poder ser preenchido quando o parmetro cGSC for preenchido com "C".
@param 11 - cGSC       , Caracter  , Estilo de apresentacao da pergunta na tela: - "G" - formato que permite editar o conteudo do campo. - "S" - formato de texto que no permite alterao. - "C" - formato que permite a opo de seleo de dados para o campo.
@param 12 - cValid  , Caracter  , Validacao do item de pergunta.
@param 13 - cF3     , Caracter  , Nome da consulta F3 que podera ser acionada pela pergunta.
@param 14 - cGrpSxg , Caracter  , Codigo do grupo de campos relacionado a pergunta.
@param 15 - cPyme      , Caracter  , Nulo
@param 16 - cVar01  , Caracter  , Nome do MV_PAR para a utilizacao nos programas.
@param 17 - cDef01  , Caracter  , Conteudo em portugues do primeiro item do objeto, caso seja Combo.
@param 18 - cDefSpa1 , Caracter  , Conteudo em espanhol do primeiro item do objeto, caso seja Combo.
@param 19 - cDefEng1 , Caracter  , Conteudo em ingles do primeiro item do objeto, caso seja Combo.
@param 20 - cCnt01  , Caracter  , Conteudo padrao da pergunta.
@param 21 - cDef02  , Caracter  , Conteudo em portugues do segundo item do objeto, caso seja Combo.
@param 22 - cDefSpa2 , Caracter  , Conteudo em espanhol do segundo item do objeto, caso seja Combo.
@param 23 - cDefEng2 , Caracter  , Conteudo em ingles do segundo item do objeto, caso seja Combo.
@param 24 - cDef03  , Caracter  , Conteudo em portugues do terceiro item do objeto, caso seja Combo.
@param 25 - cDefSpa3 , Caracter  , Conteudo em espanhol do terceiro item do objeto, caso seja Combo.
@param 26 - cDefEng3 , Caracter  , Conteudo em ingles do terceiro item do objeto, caso seja Combo.
@param 27 - cDef04  , Caracter  , Conteudo em portugues do quarto item do objeto, caso seja Combo.
@param 28 - cDefSpa4 , Caracter  , Conteudo em espanhol do quarto item do objeto, caso seja Combo.
@param 29 - cDefEng4 , Caracter  , Conteudo em ingles do quarto item do objeto, caso seja Combo.
@param 30 - cDef05  , Caracter  , Conteudo em portugues do quinto item do objeto, caso seja Combo.
@param 31 - cDefSpa5 , Caracter  , Conteudo em espanhol do quinto item do objeto, caso seja Combo.
@param 32 - cDefEng5 , Caracter  , Conteudo em ingles do quinto item do objeto, caso seja Combo.
@param 33 - aHelpPor , Vetor       , Help descritivo da pergunta em portugues.
@param 34 - aHelpEng , Vetor       , Help descritivo da pergunta em ingles.
@param 35 - aHelpSpa , Vetor       , Help descritivo da pergunta em Espanhol.
@param 36 - cHelp      , Caracter  , Nome do help equivalente, caso ja exista algum no sistema.
 
@see http://tdn.totvs.com/pages/releaseview.action?pageId=244740739
/*/
 
Static Function CPCF001( cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3, cGrpSxg,cPyme,cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)
 
   local aArea    := GetArea()
   local cKey
   local lPort    := .f.
   local lSpa     := .f.
   local lIngl    := .f.
   local cAlias   := "SX1"

   cKey  := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."
 
   cPyme    := Iif( cPyme       == Nil, " ", cPyme       )
   cF3      := Iif( cF3         == NIl, " ", cF3         )
   cGrpSxg  := Iif( cGrpSxg == Nil, " ", cGrpSxg         )
   cCnt01   := Iif( cCnt01      == Nil, "" , cCnt01      )
   cHelp    := Iif( cHelp        == Nil, "" , cHelp      )
 
   dbSelectArea( cAlias )
   dbSetOrder( 1 )
 
   cGrupo := PadR( cGrupo , Len( & ( SubS(cAlias,2,2) + "_GRUPO" ) ) , " " )
 
   If !( DbSeek( cGrupo + cOrdem ))
 
      cPergunt  := If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
      cPerSpa   := If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
      cPerEng   := If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)
 
      Reclock( cAlias , .T. )
 
      Replace &( SubS(cAlias,2,2) + "_GRUPO" )   With cGrupo
      Replace &( SubS(cAlias,2,2) + "_ORDEM" )  With cOrdem
      Replace &( SubS(cAlias,2,2) + "_PERGUNT" )  With cPergunt
      Replace &( SubS(cAlias,2,2) + "_PERSPA" ) With cPerSpa
      Replace &( SubS(cAlias,2,2) + "_PERENG" ) With cPerEng
      Replace &( SubS(cAlias,2,2) + "_VARIAVL" ) With cVar
      Replace &( SubS(cAlias,2,2) + "_TIPO" ) With cTipo
      Replace &( SubS(cAlias,2,2) + "_TAMANHO" ) With nTamanho
      Replace &( SubS(cAlias,2,2) + "_DECIMAL" ) With nDecimal
      Replace &( SubS(cAlias,2,2) + "_PRESEL" ) With nPresel
      Replace &( SubS(cAlias,2,2) + "_GSC" ) With cGSC
      Replace &( SubS(cAlias,2,2) + "_VALID" ) With cValid
 
      Replace &( SubS(cAlias,2,2) + "_VAR01" ) With cVar01
 
      Replace &( SubS(cAlias,2,2) + "_F3" ) With cF3
      Replace &( SubS(cAlias,2,2) + "_GRPSXG" ) With cGrpSxg
 
      If Fieldpos(SubS(cAlias,2,2) + "_PYME") > 0
         If cPyme != Nil
            Replace &( SubS(cAlias,2,2) + "_PYME" ) With cPyme
         Endif
      Endif
 
      Replace &( SubS(cAlias,2,2) + "_CNT01" )  With cCnt01
 
      If cGSC == "C"            // Mult Escolha
         Replace &( SubS(cAlias,2,2) + "_DEF01" )   With cDef01
         Replace &( SubS(cAlias,2,2) + "_DEFSPA1" ) With cDefSpa1
         Replace &( SubS(cAlias,2,2) + "_DEFENG1" ) With cDefEng1
 
         Replace &( SubS(cAlias,2,2) + "_DEF02" ) With cDef02
         Replace &( SubS(cAlias,2,2) + "_DEFSPA2" ) With cDefSpa2
         Replace &( SubS(cAlias,2,2) + "_DEFENG2" ) With cDefEng2
 
         Replace &( SubS(cAlias,2,2) + "_DEF03" ) With cDef03
         Replace &( SubS(cAlias,2,2) + "_DEFSPA3" ) With cDefSpa3
         Replace &( SubS(cAlias,2,2) + "_DEFENG3" ) With cDefEng3
 
         Replace &( SubS(cAlias,2,2) + "_DEF04" ) With cDef04
         Replace &( SubS(cAlias,2,2) + "_DEFSPA4" ) With cDefSpa4
         Replace &( SubS(cAlias,2,2) + "_DEFENG4" ) With cDefEng4
 
         Replace &( SubS(cAlias,2,2) + "_DEF05" ) With cDef05
         Replace &( SubS(cAlias,2,2) + "_DEFSPA5" ) With cDefSpa5
         Replace &( SubS(cAlias,2,2) + "_DEFENG5" ) With cDefEng5
      Endif
 
      Replace &( SubS(cAlias,2,2) + "_HELP" ) With cHelp
 
      CPCF002(cKey,aHelpPor,aHelpEng,aHelpSpa)
 
      MsUnlock()
 
   Else
 
      lPort := ! "?" $ &( SubS(cAlias,2,2) + "_PERGUNT" ) .And. ! Empty( &( SubS((cAlias)->cAlias,2,2) + "_PERGUNT" ) )
      lSpa  := ! "?" $ &( SubS(cAlias,2,2) + "_PERSPA" )  .And. ! Empty( &( SubS((cAlias)->cAlias,2,2) + "_PERSPA" ) )
      lIngl := ! "?" $ &( SubS(cAlias,2,2) + "_PERENG" )  .And. ! Empty( &( SubS((cAlias)->cAlias,2,2) + "_PERENG" ) )
 
      If lPort .Or. lSpa .Or. lIngl
         RecLock(cAlias,.F.)
         If lPort
            &( SubS((cAlias)->cAlias,2,2) + "_PERGUNT" ) := Alltrim( &( SubS((cAlias)->cAlias,2,2) + "_PERGUNT" ) ) +" ?"
         EndIf
         If lSpa
            &( SubS((cAlias)->cAlias,2,2) + "_PERSPA" ) := Alltrim( &( SubS((cAlias)->cAlias,2,2) + "_PERSPA" ) ) +" ?"
         EndIf
         If lIngl
            &( SubS((cAlias)->cAlias,2,2) + "_PERENG" ) := Alltrim( &( SubS((cAlias)->cAlias,2,2) + "_PERENG" ) ) +" ?"
         EndIf
         (cAlias)->(MsUnLock())
      EndIf
   Endif
 
   RestArea( aArea )
 
Return( Nil )


/*/{Protheus.doc} CPCF002
@author Willian Kaneta
@type User Function
@description Funcao para criar help de perguntas no mesmo molde da padrao. 
@obs #CONFIGURADOR #GENERICO #SX1
@since 22/06/2021
@version Protheus 12
 
@param cKey     , Caracter, Nome do help a ser cadastrado.
@param aHelpPor , Array   , Array com o texto do help em Portugues.
@param aHelpEng , Array   , Array com o texto do help em Ingles.
@param aHelpSpa , Array   , Array com o texto do help em Espanhol.
@param lUpd     , Boolean , Caso seja .T. e ja existir um help com o mesmo nome, atualiza o registro. Se for .F. nao atualiza.
@param cStatus  , Caracter, Parametro reservado.
 
@see http://tdn.totvs.com/display/public/PROT/PutSx1Help+-+Cadastro+de+Help
/*/
 
Static Function CPCF002(cKey,aHelpPor,aHelpEng,aHelpSpa,lUpd,cStatus)
Local cFilePor := "SIGAHLP.HLP"
Local cFileEng := "SIGAHLE.HLE"
Local cFileSpa := "SIGAHLS.HLS"
Local nRet
Local nT
Local nI
Local cLast
Local cNewMemo
Local cAlterPath := ''
Local nPos  
 
If ( ExistBlock('HLPALTERPATH') )
    cAlterPath := Upper(AllTrim(ExecBlock('HLPALTERPATH', .F., .F.)))
    If ( ValType(cAlterPath) != 'C' )
        cAlterPath := ''
    ElseIf ( (nPos:=Rat('\', cAlterPath)) == 1 )
        cAlterPath += '\'
    ElseIf ( nPos == 0  )
        cAlterPath := '\' + cAlterPath + '\'
    EndIf
     
    cFilePor := cAlterPath + cFilePor
    cFileEng := cAlterPath + cFileEng
    cFileSpa := cAlterPath + cFileSpa
     
EndIf
 
Default aHelpPor := {}
Default aHelpEng := {}
Default aHelpSpa := {}
Default lUpd     := .T.
Default cStatus  := ""
 
If Empty(cKey)
    Return
EndIf
 
If !(cStatus $ "USER|MODIFIED|TEMPLATE")
    cStatus := NIL
EndIf
 
cLast    := ""
cNewMemo := ""
                                                                                                 
nT := Len(aHelpPor)
 
For nI:= 1 to nT
   cLast := Padr(aHelpPor[nI],40)
   If nI == nT
      cLast := RTrim(cLast)
   EndIf
   cNewMemo+= cLast
Next
 
If !Empty(cNewMemo)
    nRet := SPF_SEEK( cFilePor, cKey, 1 )
    If nRet < 0
        SPF_INSERT( cFilePor, cKey, cStatus,, cNewMemo )
    Else
        If lUpd 
            SPF_DELETE( cFilePor, nRet ) 
            SPF_INSERT( cFilePor, cKey, cStatus,, cNewMemo )
        EndIf                                                           
    EndIf
EndIf
 
cLast    := ""
cNewMemo := ""
 
nT := Len(aHelpEng)
 
For nI:= 1 to nT
   cLast := Padr(aHelpEng[nI],40)
   If nI == nT
      cLast := RTrim(cLast)
   EndIf
   cNewMemo+= cLast
Next
 
If !Empty(cNewMemo)
    nRet := SPF_SEEK( cFileEng, cKey, 1 )
    If nRet < 0
        SPF_INSERT( cFileEng, cKey, cStatus,, cNewMemo )
    Else
        If lUpd
            SPF_DELETE( cFileEng, nRet ) 
            SPF_INSERT( cFileEng, cKey, cStatus,, cNewMemo )
        EndIf
    EndIf
EndIf
 
cLast    := ""
cNewMemo := ""
 
nT := Len(aHelpSpa)
 
For nI:= 1 to nT
   cLast := Padr(aHelpSpa[nI],40)
   If nI == nT
      cLast := RTrim(cLast)
   EndIf
   cNewMemo+= cLast
Next
 
If !Empty(cNewMemo)
    nRet := SPF_SEEK( cFileSpa, cKey, 1 )
    If nRet < 0
        SPF_INSERT( cFileSpa, cKey, cStatus,, cNewMemo )
    Else
        If lUpd
            SPF_DELETE( cFileSpa, nRet ) 
            SPF_INSERT( cFileSpa, cKey, cStatus,, cNewMemo )
        EndIf
    EndIf
EndIf
Return
