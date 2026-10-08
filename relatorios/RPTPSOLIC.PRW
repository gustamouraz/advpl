#include 'protheus.ch'
#include 'rwmake.ch'
#include 'topconn.ch'
 
User Function RPTPSOLIC()
    Local oReport
    Local aFiliais := AdmGetFil(.F.,.F.)
    Private cPerg := "RPTPSOLIC"
    Private oSec1
    Private cFiliais := ""
    Private cMyAlias := GetNextAlias()
 
    If Len(aFiliais) > 0
        cFiliais := AsString(aFiliais)
        cFiliais := StrTran(cFiliais,"{","'")
        cFiliais := StrTran(cFiliais,"}","'")
        cFiliais := StrTran(cFiliais,",","','")
 
        If !Pergunte(cPerg,.T.)
            Return Nil
        EndIf
 
        oReport := ReportDef()
        oReport:PrintDialog()
    Else
        Help(" ",1,"AF271FIL",,"Selecione a filial para consulta", 1, 0)
    EndIf
Return
 
Static Function ReportDef()
    Local oReport
    Local cNomeRel := "Relatorio Solicitação de Compras"
    Local cTitulo  := "Relatorio Solicitação de Compras"
    Local cDescRel := "Relatorio de Solicitação de Compras"
 
    oReport := TReport():New(cNomeRel, cTitulo, "RPTPSOLIC", {|oRep| ReportPrint(oRep)}, cDescRel)
    oReport:SetPortrait()
    oReport:SetTotalInLine(.F.)
    oReport:ShowHeader()
    oReport:Page()
 
    oSec1 := TRSection():New(oReport, "Dados das Solicitações")
    TRCell():New(oSec1,"Filial"         ,,"Filial"                  ,"@!")
    TRCell():New(oSec1,"DeFilial"       ,,"Desc. Filial"            ,"@!")
    TRCell():New(oSec1,"UsuarioSC"      ,,"Usuario SC"              ,"@!")
    TRCell():New(oSec1,"NumSC"          ,,"Num. Solicitação"        ,"@!")
    TRCell():New(oSec1,"DataSC"         ,,"Data Solicitação"        ,"@D")
    TRCell():New(oSec1,"Urgente"        ,,"Urgente"                 ,"@!")
    TRCell():New(oSec1,"ElimRes"        ,,"Eliminação Resid"        ,"@!")
    TRCell():New(oSec1,"CodFor"         ,,"Cod. Fornecedor"         ,"@!")
    TRCell():New(oSec1,"NomeFor"        ,,"Nome Fornecedor"         ,"@!")
    TRCell():New(oSec1,"ValorSC"        ,,"Valor Solicitação"       ,"@E 999,999,999.99")
    TRCell():New(oSec1,"Aprov"          ,,"Aprovadores"             ,"@!")
    TRCell():New(oSec1,"GrpAprov"       ,,"Grupo Aprovadores"       ,"@!")
 
Return oReport
 
Static Function ReportPrint(oReport)
    Local cMyAlias := GetNextAlias()
    Local nTotal   := 0
    Local nAtual   := 0
    Local aArea    := {}
    Local cFilWhere := '%('+cFiliais+')%'
 
    oSec1 := oReport:Section(1)
 
    BeginSql alias cMyAlias
        %NoParser%
 
            SELECT DISTINCT
            SC1.C1_FILIAL AS Filial,
            TRIM(SUBSTRING(M0_FILIAL,6,50)) AS DeFilial,
            SC1.C1_NUM AS NumSC,
            CASE 
                WHEN SC1.C1_NRBPIMS IS NOT NULL AND SC1.C1_NRBPIMS <> '' THEN 'Integração'
                ELSE USI.USR_CODIGO

            END AS UsuarioSC,
            CONVERT(VARCHAR(10), CONVERT(DATE, SC1.C1_EMISSAO), 103) AS DataSC,
            CASE WHEN SC1.C1_YURGENT = 'S' THEN 'Sim' ELSE 'Não' END AS Urgente,
            CASE WHEN SUM(CASE WHEN SC1.C1_RESIDUO = 'S' THEN 1 ELSE 0 END) > 0 THEN 'Sim' ELSE 'Não' END AS ElimRes,
            SC1.C1_FORNECE AS CodFor,
            SA2.A2_NOME AS NomeFor,
            CASE 
                WHEN SUM(SC1.C1_TOTAL) > 0 THEN SUM(SC1.C1_TOTAL)  
                ELSE SUM(SC1.C1_ZUPRC * SC1.C1_QUANT)
            END AS ValorSC   
        FROM
            SC1010 SC1
            LEFT JOIN SYS_USR USI ON
                USI.USR_ID = SC1.C1_USER
            INNER JOIN SA2010 SA2 ON
                SC1.C1_FORNECE = SA2.A2_COD AND
                A2_LOJA = SC1.C1_LOJA AND
                SA2.D_E_L_E_T_ = ''
            LEFT JOIN SB1010 B1 ON
                SC1.C1_PRODUTO = B1.B1_COD AND
                B1.D_E_L_E_T_ = ''
            LEFT JOIN SYS_COMPANY M0 ON
                M0.M0_CODFIL = C1_FILIAL AND
                M0.D_E_L_E_T_ = ''
        WHERE
            SC1.D_E_L_E_T_ = ''
            AND SC1.C1_FILIAL IN %Exp:cFilWhere%
            AND SC1.C1_EMISSAO BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
            AND SC1.C1_CC BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%    
 
        GROUP BY
            SC1.C1_FILIAL
            ,M0.M0_FILIAL
            ,USI.USR_CODIGO
            ,SC1.C1_NUM
            ,SC1.C1_EMISSAO
            ,SC1.C1_FORNECE
            ,SA2.A2_NOME
            ,SC1.C1_YURGENT
            ,SC1.C1_NRBPIMS
        ORDER BY
            NumSC DESC
 
    EndSql
 
    Count to nTotal
    oReport:SetMeter(nTotal)
    oSec1:Init()
 
    (cMyAlias)->(DbGoTop())
    While !oReport:Cancel() .AND. !(cMyAlias)->(Eof())
        nAtual++
        aArea := GetArea()
        oReport:SetMsgPrint("Imprimindo registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal))
        oReport:IncMeter()
 
        oSec1:Cell("Filial"     ):SetValue((cMyAlias)->Filial)
        oSec1:Cell("DeFilial"   ):SetValue((cMyAlias)->DeFilial)
        oSec1:Cell("UsuarioSC"  ):SetValue((cMyAlias)->UsuarioSC)
        oSec1:Cell("NumSC"      ):SetValue((cMyAlias)->NumSC)
        oSec1:Cell("DataSC"     ):SetValue((cMyAlias)->DataSC)
        oSec1:Cell("Urgente"    ):SetValue((cMyAlias)->Urgente)
        oSec1:Cell("ElimRes"    ):SetValue((cMyAlias)->ElimRes)
        oSec1:Cell("CodFor"     ):SetValue((cMyAlias)->CodFor)
        oSec1:Cell("NomeFor"    ):SetValue((cMyAlias)->NomeFor)
        oSec1:Cell("ValorSC"    ):SetValue((cMyAlias)->ValorSC)
        oSec1:Cell("Aprov"      ):SetValue(LMRETAPR((cMyAlias)->Filial,(cMyAlias)->NumSC))
        oSec1:Cell("GrpAprov"   ):SetValue(LMRETGRP((cMyAlias)->Filial,(cMyAlias)->NumSC))
        oSec1:PrintLine()
        (cMyAlias)->(DbSkip())
    EndDo
 
    oSec1:Finish()
Return
 
Static Function LMRETAPR(cFil, cNum)
    Local cAlias := GetNextAlias()
    Local cRet := ""
 
    BeginSql alias cAlias
        %noParser%
 
        SELECT DISTINCT USR_CODIGO
        FROM SCR010 SCR
        INNER JOIN SYS_USR USR ON
        USR_ID = CR_USER AND
        USR.D_E_L_E_T_ = ''
 
        WHERE
        CR_FILIAL = %Exp:cFil% AND
        CR_NUM = %Exp:cNum% AND
        CR_TIPO = 'SC' AND
        CR_STATUS = '03' AND
        SCR.D_E_L_E_T_ = ''
 
    EndSql
 
    While !(cAlias)->(Eof())
        cRet += AllTrim((cAlias)->USR_CODIGO)
        (cAlias)->(DbSkip())
        If !(cAlias)->(Eof())
            cRet += " | "
        EndIf
    EndDo
 
    (cAlias)->(DbCloseArea())
Return cRet
 
 
Static Function LMRETGRP(cFil, cNum)
    Local cAlias := GetNextAlias()
    Local cRet := ""
 
    BeginSql alias cAlias
        %noParser%
 
        SELECT DISTINCT AL_COD +" : "+AL_DESC AS GRUPO
        FROM SCR010 SCR
        INNER JOIN SAL010 SAL ON
        AL_COD = CR_GRUPO AND
        (AL_FILIAL = '' OR AL_FILIAL = CR_FILIAL) AND
        AL_MSBLQL <> '1' AND 
        SAL.D_E_L_E_T_ = ''
 
        WHERE
        CR_FILIAL = %Exp:cFil% AND
        CR_NUM = %Exp:cNum% AND
        CR_TIPO = 'SC' AND
        CR_STATUS = '03' AND 
        SCR.D_E_L_E_T_ = ''
 
    EndSql
 
    While !(cAlias)->(Eof())
        cRet += AllTrim((cAlias)->GRUPO)
        (cAlias)->(DbSkip())
        If !(cAlias)->(Eof())
            cRet += " | "
        EndIf
    EndDo
 
    (cAlias)->(DbCloseArea())
Return cRet
