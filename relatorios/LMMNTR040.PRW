#INCLUDE "MNTR040.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

Static _cAlias := ""

/*/{Protheus.doc} LMMNTR040
Mapa de Consumo Diario de Combustivel em TReport.
O TReport disponibiliza as saidas padrao do Protheus, incluindo PDF e Excel.
@type function
@author Luiz Moura
@since 20/06/2022
/*/
User Function LMMNTR040()

	Local oReport := ReportDef()

	If oReport != Nil
		oReport:PrintDialog()
	EndIf

Return

/*/{Protheus.doc} ReportDef
Cria a estrutura do relatorio e mantem o grupo de perguntas MNT040.
/*/
Static Function ReportDef()

	Local oReport  := Nil
	Local oSection := Nil
	Private cPerg  := "MNT040"
	_cAlias := GetNextAlias()

	If !Pergunte(cPerg,.T.)
		Return Nil
	EndIf

	DEFINE REPORT oReport NAME "LMMNTR040" TITLE "Mapa de Consumo Diario de Combustivel" ;
		ACTION {|oRep| rPrint(oRep)} ;
		DESCRIPTION "Mapa de consumo diario de combustivel com exportacao padrao."

	oReport:SetLandscape()
	oReport:SetUseGC(.F.)
	DEFINE SECTION oSection OF oReport TITLE "Abastecimentos" TABLES _cAlias
	oSection:SetTotalInLine(.F.)

	DEFINE CELL NAME "DATA"       OF oSection ALIAS _cAlias TITLE "Data"             PICTURE "@D" SIZE 10
	DEFINE CELL NAME "HORA"       OF oSection ALIAS _cAlias TITLE "Hora"             SIZE 5
	DEFINE CELL NAME "FROTA"      OF oSection ALIAS _cAlias TITLE "Frota"            SIZE 12
	DEFINE CELL NAME "NOME"       OF oSection ALIAS _cAlias TITLE "Descricao Frota"  SIZE 30
	DEFINE CELL NAME "PLACA"      OF oSection ALIAS _cAlias TITLE "Placa"            SIZE 10
	DEFINE CELL NAME "CCUSTO"     OF oSection ALIAS _cAlias TITLE "Centro Custo"     SIZE 12
	DEFINE CELL NAME "TANQUE"     OF oSection ALIAS _cAlias TITLE "Tanque"           SIZE 8
	DEFINE CELL NAME "COMB"       OF oSection ALIAS _cAlias TITLE "Combustivel"      SIZE 25
	DEFINE CELL NAME "CONTADOR"   OF oSection ALIAS _cAlias TITLE "Contador"         PICTURE "@E 999,999,999" SIZE 14
	DEFINE CELL NAME "REALIZADO"  OF oSection ALIAS _cAlias TITLE "Realizado"        PICTURE "@E 999,999,999" SIZE 14
	DEFINE CELL NAME "INCREMENTO" OF oSection ALIAS _cAlias TITLE "Incremento"       PICTURE "@E 999,999,999" SIZE 14
	DEFINE CELL NAME "ABASTEC"    OF oSection ALIAS _cAlias TITLE "Abastecido"       PICTURE "@E 999,999,999.999" SIZE 16
	DEFINE CELL NAME "UMCOMB"     OF oSection ALIAS _cAlias TITLE "UM Comb."         SIZE 8
	DEFINE CELL NAME "MEDIA"      OF oSection ALIAS _cAlias TITLE "Media"            PICTURE "@E 999,999,999.99" SIZE 14
	DEFINE CELL NAME "UMMEDIA"    OF oSection ALIAS _cAlias TITLE "Unid. Media"      SIZE 12
	DEFINE CELL NAME "VALTOT"     OF oSection ALIAS _cAlias TITLE "Valor Total"      PICTURE "@E 999,999,999,999,999.99" SIZE 18
	DEFINE CELL NAME "VALUNI"     OF oSection ALIAS _cAlias TITLE "Valor Unitario"   PICTURE "@E 999,999,999.999999" SIZE 16
	DEFINE CELL NAME "DTLCTO"     OF oSection ALIAS _cAlias TITLE "Data Lancamento" PICTURE "@D" SIZE 12
	DEFINE CELL NAME "ABACUM"     OF oSection ALIAS _cAlias TITLE "Abast. Acumulado" PICTURE "@E 999,999,999.999" SIZE 16
	DEFINE CELL NAME "UMCONT"     OF oSection ALIAS _cAlias TITLE "Unid. Contador"   SIZE 10

Return oReport

/*/{Protheus.doc} rPrint
Consulta e alimenta a secao do TReport. As celulas sao preenchidas
explicitamente para que a mesma estrutura seja usada em tela, PDF e Excel.
/*/
Static Function rPrint(oReport)

	Local oSection := oReport:Section(1)
	Local nTotal := 0
	Local nAtual := 0
	Local nKmRod := 0
	Local nLtAcu := 0
	Local nMedia := 0
	Local cTipCont := ""
	Local cUM := ""
	Local cUnMedia := ""
	Local cFrotaAnt := ""
	Private nKmAnt := 0

	BeginSql Alias _cAlias
		SELECT TQN.TQN_TANQUE, TQN.TQN_CODCOM, TQN.TQN_DTABAS, TQN.TQN_HRABAS, TQN.TQN_QUANT,
			TQN.TQN_VALTOT, TQN.TQN_VALUNI, TQN.TQN_DTDIGI, TQN.TQN_FROTA,
			ST9.T9_FILIAL, ST9.T9_CODBEM, ST9.T9_CCUSTO, ST9.T9_NOME, ST9.T9_PLACA,
			STP.TP_CODBEM, STP.TP_POSCONT, STP.TP_ACUMCON, TQM.TQM_NOMCOM, TQM.TQM_UM,
			ST6.T6_TIPO1, ST6.T6_MEDIA1
		FROM %table:TQN% TQN
		JOIN %table:ST9% ST9 ON TQN.TQN_FROTA = ST9.T9_CODBEM
			AND ST9.T9_FILIAL = %xFilial:ST9% AND ST9.%NotDel%
		JOIN %table:STP% STP ON STP.TP_CODBEM = TQN.TQN_FROTA
			AND STP.TP_DTLEITU = TQN.TQN_DTABAS AND STP.TP_HORA = TQN.TQN_HRABAS
			AND STP.TP_TIPOLAN = 'A' AND STP.TP_FILIAL = %xFilial:STP% AND STP.%NotDel%
		JOIN %table:ST6% ST6 ON ST9.T9_CODFAMI = ST6.T6_CODFAMI
			AND ST6.T6_FILIAL = %xFilial:ST6% AND ST6.%NotDel%
		JOIN %table:TQM% TQM ON TQN.TQN_CODCOM = TQM.TQM_CODCOM
			AND TQM.TQM_FILIAL = %xFilial:TQM% AND TQM.%NotDel%
		JOIN %table:TQF% TQF ON TQN.TQN_POSTO = TQF.TQF_CODIGO AND TQN.TQN_LOJA = TQF.TQF_LOJA
			AND TQF.TQF_FILIAL = %xFilial:TQF% AND TQF.%NotDel%
		WHERE TQN.TQN_DTABAS BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			AND ST9.T9_CODFAMI BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			AND ST9.T9_TIPMOD BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
			AND ST9.T9_CCUSTO BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
			AND ST9.T9_CODBEM BETWEEN %Exp:MV_PAR09% AND %Exp:MV_PAR10%
			AND TQF.TQF_CONVEN = TQM.TQM_CONVEN AND TQN.TQN_FILIAL = %xFilial:TQN% AND TQN.%NotDel%
		ORDER BY ST9.T9_CODBEM, TQN.TQN_CODCOM, TQN.TQN_TANQUE, TQN.TQN_DTABAS, TQN.TQN_HRABAS
	EndSql

	(_cAlias)->(DbGoTop())
	Count To nTotal
	(_cAlias)->(DbGoTop())
	oReport:SetMeter(nTotal)
	oSection:Init()

	While (_cAlias)->(!Eof())
		If oReport:lCanceled
			Exit
		EndIf

		If nKmAnt <> 0 .And. (_cAlias)->T9_CODBEM <> cFrotaAnt
			nKmAnt := 0
		EndIf
		cFrotaAnt := (_cAlias)->T9_CODBEM
		cTipCont := AllTrim((_cAlias)->T6_TIPO1)
		cUM := AllTrim((_cAlias)->TQM_UM)
		cUnMedia := UndCont(cTipCont,cUM,AllTrim((_cAlias)->T6_MEDIA1))
		nKmRod := KmAnt((_cAlias)->TQN_DTABAS,(_cAlias)->TQN_HRABAS,(_cAlias)->T9_FILIAL,(_cAlias)->T9_CODBEM)
		nLtAcu := LtAcu((_cAlias)->TQN_DTABAS,(_cAlias)->TQN_HRABAS,(_cAlias)->T9_FILIAL,(_cAlias)->T9_CODBEM)
		nMedia := 0
		If (_cAlias)->TQN_QUANT <> 0 .And. nKmRod <> 0
			nMedia := IIf(AllTrim((_cAlias)->T6_MEDIA1) == "2",(_cAlias)->TQN_QUANT / nKmRod,nKmRod / (_cAlias)->TQN_QUANT)
		EndIf

		oSection:Cell("DATA"):SetValue(Stod((_cAlias)->TQN_DTABAS))
		oSection:Cell("HORA"):SetValue((_cAlias)->TQN_HRABAS)
		oSection:Cell("FROTA"):SetValue((_cAlias)->T9_CODBEM)
		oSection:Cell("NOME"):SetValue((_cAlias)->T9_NOME)
		oSection:Cell("PLACA"):SetValue((_cAlias)->T9_PLACA)
		oSection:Cell("CCUSTO"):SetValue((_cAlias)->T9_CCUSTO)
		oSection:Cell("TANQUE"):SetValue((_cAlias)->TQN_TANQUE)
		oSection:Cell("COMB"):SetValue((_cAlias)->TQN_CODCOM+" - "+AllTrim((_cAlias)->TQM_NOMCOM))
		oSection:Cell("CONTADOR"):SetValue((_cAlias)->TP_POSCONT)
		oSection:Cell("REALIZADO"):SetValue((_cAlias)->TP_ACUMCON)
		oSection:Cell("INCREMENTO"):SetValue(nKmRod)
		oSection:Cell("ABASTEC"):SetValue((_cAlias)->TQN_QUANT)
		oSection:Cell("UMCOMB"):SetValue(cUM)
		oSection:Cell("MEDIA"):SetValue(nMedia)
		oSection:Cell("UMMEDIA"):SetValue(cUnMedia)
		oSection:Cell("VALTOT"):SetValue((_cAlias)->TQN_VALTOT)
		oSection:Cell("VALUNI"):SetValue((_cAlias)->TQN_VALUNI)
		oSection:Cell("DTLCTO"):SetValue(Stod((_cAlias)->TQN_DTDIGI))
		oSection:Cell("ABACUM"):SetValue(nLtAcu)
		oSection:Cell("UMCONT"):SetValue(cTipCont)
		oSection:PrintLine()

		nAtual++
		oReport:IncMeter()
		oReport:SetMsgPrint("Processando registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		(_cAlias)->(DbSkip())
	EndDo

	oSection:Finish()
	(_cAlias)->(DbCloseArea())
Return

Static Function KmAnt(dData,cHora,cFilBem,cCodBem)
	Local nKmRod := 0
	Local nKmAtual := (_cAlias)->TP_ACUMCON

	If (_cAlias)->(!Eof() .And. !Bof()) .And. cCodBem == (_cAlias)->TQN_FROTA
		nKmRod := BuscaIncr(dData,cHora,nKmAtual)
		nKmAnt := (_cAlias)->TP_ACUMCON
	EndIf
Return nKmRod

Static Function LtAcu(dData,cHora,cFilBem,cCodBem)
	Local aArea := GetArea()
	Local nSomaLt := 0
	Local cComb := ""

	DbSelectArea("TQN")
	DbSetOrder(1)
	DbSeek(NGTROCAFILI("TQN",cFilBem)+cCodBem+dData+cHora)
	cComb := TQN->TQN_CODCOM
	DbSeek(NGTROCAFILI("TQN",cFilBem)+cCodBem)
	While !Eof() .And. TQN->TQN_FILIAL == xFilial("TQN") .And. TQN->TQN_FROTA == cCodBem .And. DTOS(TQN->TQN_DTABAS) <= dData
		If !(DTOS(TQN->TQN_DTABAS) == dData .And. TQN->TQN_HRABAS > cHora) .And. TQN->TQN_CODCOM == cComb
			nSomaLt += TQN->TQN_QUANT
		EndIf
		DbSkip()
	EndDo
	RestArea(aArea)
Return nSomaLt

Static Function UndCont(cTipo,cUnid,cTpUn)
	Local cT := IIf(Empty(cTipo),"---",cTipo)
	Local cU := IIf(Empty(cUnid),"--",cUnid)
Return IIf(cTpUn == "1",cT+"/"+cU,IIf(cTpUn == "2",cU+"/"+cT,""))

Static Function BuscaIncr(dData,cHora,nKmAtual)
	Local cCond := "STP->TP_TIPOLAN == 'I' .Or. STP->TP_TIPOLAN == 'A'"
	Local aSTP := NGACUMEHIS((_cAlias)->TP_CODBEM,sToD(dData),cHora,1,"A",xFilial("STP"),cCond,,(_cAlias)->T9_PLACA)
Return nKmAtual - aSTP[2]
