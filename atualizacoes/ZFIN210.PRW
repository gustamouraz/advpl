#INCLUDE "FINA210.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE 'FWLIBVERSION.CH'

Static lFWCodFil := .T.
Static __lSchedule  := FWGetRunSchedule()
Static __lUsAllFls	:= .T.
Static __lF210QRY	:= ExistBlock("FI210QRY")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ZFin210  ³ Autor ³ Wagner Xavier         ³ Data ³ 01.12.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recalcula os saldos bancarios dentro de um determinado     ³±±
±±³          ³ periodo                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ZFin210(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Claudio  ³13/07/00³xxxxxx³ Retirar todas as chamadas a WriteSx2       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ZFin210(lDireto)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aButtons		:= {}
LOCAL cProcessa 	:= ""
Local cFunction		:= "ZFIN210"
Local cTitle		:= STR0004
Local cDescription	:= STR0005 + STR0006 + STR0007 + STR0008 + STR0009
Local cPerg			:="FIN210"
Local oProcess
Local aInfoCustom 	:= {}

DEFAULT lDireto := .F.

Private cCadastro := OemToAnsi(STR0004)  //"Reconcilia‡„o de Saldos Banc rios"
Private lFA210FK5 := ExistBlock("FA210FK5")
Private lFA210SE8 := ExistBlock("FA210SE8")
Private lSol2C2	As Logical

lSol2C2 := FwModeAccess("SA6",3) == 'E'.and. FwModeAccess("FK5",3) == 'C'.and. FwModeAccess("SE8",3) == 'C'

//Valida se tem acesso a visualização de bancos -- LGPD
If !( IsBlind() .Or. lDireto) .And. GetHlpLGPD({"A6_COD", "A6_AGENCIA", "A6_NUMCON"})
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o log de processamento                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If IsBlind() .Or. lDireto
	ProcLogIni( aButtons )
	
	cProcessa := "Processa({|lEnd| U_ZFA210Process(.T.)})"
	
	ProcLogAtu("INICIO")
	BatchProcess(	cCadastro, 	STR0005 + Chr(13) + Chr(10) +;
								STR0006 + Chr(13) + Chr(10) +;
								STR0007 + Chr(13) + Chr(10) +;
								STR0008 + Chr(13) + Chr(10) +;
								STR0009, "ZFIN210",;
						{ || &cProcessa }, { || .F. } )
	ProcLogAtu("FIM")
	Return .T.
Endif


oProcess := tNewProcess():New( cFunction, cTitle, {|oSelf| FA210NewPerg ( oSelf ) }, cDescription, cPerg,;
							  aInfoCustom                       /*aInfoCustom*/  ,;
                              .T.                               /*lPanelAux*/    ,;
                              5                                 /*nSizePanelAux*/,;
                              cDescription    					/*cDescriAux*/   ,;
                              .T.                               /*lViewExecute*/ ,;
                              .F.                               /*lOneMeter*/    ,;
                              .T.                               /*lSchedAuto*/ ) 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA210NewPergºAutor³ALvaro Camillo Neto º Data ³  05/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tratamento para a utilização do tNewProcess                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA210NewPerg( oSelf )

Local lFilsUsr	As Logical
Local cFils		As Character

lFilsUsr	:= FindFunction("FilsUsr")
cFils		:= ""

//*************************************************************************************************
// Solucao | Multi filial | A6 | FK5 | E8 | Descricao                                              *
//     1   |     Sim      | E  | E  | E  | Rodar Multi filial filtrando filial no A6, FK5          *
//     2   |     Sim      | E  | E  | C  | Normal com filial do A6 e no FK5 de '  ' ate 'ZZ'       *
//     3   |     Sim      | E  | C  | E  | Rodar Multi filial filtrando filial no A6 e FK5_FILORI  *
//         |     Sim      | E  | C  | C  | Idem a Solucao 2                                       *
//         |     Sim      | C  | E  | E  | Idem a Solucao 1                                       *
//         |     Nao      | C  | E  | C  | Idem a Solucao 2                                       *
//         |     Sim      | C  | C  | E  | Idem a Solucao 3                                       *
//     4   |     Nao      | C  | C  | C  | Rodar Normal sem filtro                                *
//*************************************************************************************************

If lFilsUsr
	If !Empty(FwFilial("SE8")) //Não verifica permissão de acesso as filiais quando a SE8 estiver compartilhada
		__lUsAllFls := FilsUsr(MV_PAR09, MV_PAR10, @cFils)
	Endif
EndIf

If __lUsAllFls
	If MV_PAR08 == 1 .And. ( !Empty(FwFilial("SE8")) .or. !Empty(FwFilial("SA6")) ) .And. !lSol2C2
		FA210FIL( MV_PAR09, MV_PAR10, .F. , oSelf )
	Else
		U_ZFA210Process(.F.,oSelf)
	EndIf
Else
	If Empty(cFils)
		Help(" ", 1, "NOFIL", NIL, STR0022, 1, 0)		//"Operador não tem acesso as Filiais Informadas nos parâmetros."
	Else
		Help(" ",1,"FILSACS",,STR0020+; //"Operador não tem acesso a todas às Filiais."
										STR0021,1,0) //"O Saldo do banco não considerará movimentos das filiais negadas."
		U_ZFA210Process(.F.,oSelf,,cFils)
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA210Fil ºAutor  ³Alvaro Camillo Neto º Data ³  21/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa o processamento para cada filial                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ZFIN210                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA210Fil(cFilDe,cFilAte,lAuto,oSelF)

Local cFilIni 	:= cFIlAnt
Local aArea		:= GetArea()
Local nInc		:= 0
Local aSM0		:= AdmAbreSM0()

For nInc := 1 To Len( aSM0 )
	If aSM0[nInc][1] == cEmpAnt .AND. aSM0[nInc][2] >= cFilDe .and. aSM0[nInc][2] <= cFilAte
		cFilAnt := aSM0[nInc][2]

		oSelf:SaveLog( "MENSAGEM: EXECUTANDO A APURACAO DA FILIAL " + cFilAnt)
		
		U_ZFA210Process(lAuto,oSelF,nInc == 1)
	EndIf
Next

cFIlAnt := cFilIni
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Fa210pro ³ Autor ³ Wagner Xavier         ³ Data ³ 09.03.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recalcula os saldos bancarios dentro de um determinado     ³±±
±±³          ³ periodo para versao TopConnect                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ZFA210Process()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ZFA210Process( lBat As Logical, oSelf As Object,lFirst As Logical, cFils As Character )

	Local nSaldoIni  As Numeric
	Local nEntradas  As Numeric	
	Local nSaidas 	 As Numeric
	Local nData		 As Date 
	Local cQuery 	 As Character
	Local dDataMovto As Date
	Local nSalRecIni As Numeric
	Local nEntrRec 	 As Numeric
	Local nSaidRec 	 As Numeric
	Local lCxLoja  	 As Logical
	Local cTabela14  As Character
	Local cFilTRB 	 As Character
	Local cFilSE8	 As Character
	Local cFilSE82 	 As Character
	Local nTamFilFK5 As Numeric
	Local nTamFilSE8 As Numeric
	Local lComp		 As Logical
	Local lAreaRest  As Logical
	Local cChaveFK5  As Character
	Local aTabela14  As Array 
	Local aAreaAtu   As Array
	
	//Controle para verificações no caso da tabela FK5 possuir um compartilhamento superior a SE8
	Local cFilFK5 	 As Character
	Local cFilAux 	 As Character  
	Local bBncFilIgl As Block
	Local lSolucao3  As Logical 
	Local lSolucao2	 As Logical
	Local nNewSald   As Numeric
	Local ny		 As Numeric
	Local cBanco	 As Character
	Local cAgencia	 As Character
	Local cConta 	 As Character
	Local nMoeda 	 As Numeric
	Local cFilSA6	 As Character
	Local nTamEmp	 As Numeric
	Local nTamUni	 As Numeric
	Local nTamFil	 As Numeric
	Local lBcoExcl	 As Logical
	Local cFilialSE8 As Character
	Local cChaveSE8  As Character
	Local cLibLabel  As Character
    Local lLibSchedule	As Logical 

	nSaldoIni 	:= 0
	nEntradas	:= 0
	nSaidas		:= 0
	nData		:= 0
	cQuery		:= ""
	dDataMovto	:= 0
	nSalRecIni	:= 0   //Saldo Reconciliado Inicial
	nEntrRec	:= 0		//Entrada ja conciliada
	nSaidRec	:= 0		//Saida ja conciliada
	lCxLoja		:= GetNewPar("MV_CXLJFIN",.F.)
	cTabela14	:= ""
	cFilTRB		:= ""
	cFilSE8		:= ""
	cFilSE82 	:= ""
	cFilFK52 	:= ""
	nTamFilFK5 	:= 0
	nTamFilSE8 	:= 0
	lComp		:= FwModeAccess("SE8",3) == "C" .And. FwModeAccess("FK5",3) == "E"  // Verifico o compartilhamento das duas tabelas apenas uma vez para melhorar o desempenho 
	lAreaRest	:= .F.
	cChaveFK5	:= ""
	aTabela14	:= {}
	aAreaAtu	:= {}
	//Controle para verificações no caso da tabela FK5 possuir um compartilhamento superior a SE8
	cFilFK5		:= ""
	cFilAux		:= ""
	bBncFilIgl	:= { || ( ( Substr(TRB210->FK5_FILIAL,1,nTamFilSE8)+TRB210->FK5_BANCO+TRB210->FK5_AGENCI+TRB210->FK5_CONTA == Substr(cFilSE8,1,nTamFilSE8)+cBanco+cAgencia+cConta ) .Or. ( lSolucao3 .And. Empty( FWFilial("FK5") ) .And. TRB210->FK5_BANCO+TRB210->FK5_AGENCI+TRB210->FK5_CONTA == cBanco+cAgencia+cConta ) ) }
	lSolucao3	:= FWSizeFilial() > 2 .And. AllTrim( xFilial( "SE8" ) ) > AllTrim( xFilial( "FK5" ) )//Filial da FK5 pode possuir compartilhamento somente na filial, não estando vazia
	lSolucao2	:= .F.
	nNewSald	:= 0
	ny			:= 0
	cBanco   	:= ""
	cAgencia 	:= ""
	cConta   	:= ""
	nMoeda 	 	:= 0
	cFilSA6  	:= ""
	nTamEmp	 	:= Len(FWSM0Layout(cempant,1))
	nTamUni	 	:= Len(FWSM0Layout(cempant,2))
	nTamFil	 	:= Len(FWSM0Layout(cempant,3))
	lBcoExcl    := Alltrim(FWModeAccess("SA6",1)) == "E" .Or. Alltrim(FWModeAccess("SA6",2)) == "E" .Or. Alltrim(FWModeAccess("SA6",3)) == "E"
	cFilialSE8  := ""
	cChaveSE8   := ""
	cLibLabel 	:= "20240520"
    lLibSchedule	:= FwLibVersion() >= cLibLabel

	Default lFirst  := .T. 
	Default cFils	:= ""

	lBat := if( ValType( lBat ) <> 'L', .F., lBat)
	oSelf := if( ValType( oSelf ) <> 'O', nil, oSelf)

	If !lBat .Or. lLibSchedule
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula total de registros a serem processados corretamente ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "SELECT COUNT( R_E_C_N_O_ ) TOTREG "
		cQuery += " FROM " + RetSqlName("SA6")
		cQuery += " WHERE A6_FILIAL ='" + xFilial("SA6") + "'"
		cQuery += " AND   A6_COD     between '" + mv_par01 + "' AND '" + mv_par02 + "'"
		cQuery += " AND   A6_AGENCIA between '" + mv_par03 + "' AND '" + mv_par04 + "'"
		cQuery += " AND   A6_NUMCON  between '" + mv_par05 + "' AND '" + mv_par06 + "'"
		cQuery += " AND D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TRBTOT',.T.,.T.)

		If oSelf <> nil
			oSelf:Savelog("INICIO")
			oSelf:SetRegua1(TRBTOT->TOTREG)
			oSelf:SetRegua2(TRBTOT->TOTREG)
		Else
			ProcRegua(TRBTOT->TOTREG)
		EndIf
	EndIf


	TRBTOT->( dbCloseArea() )

	If !DtMovFin(mv_par07,.T.,"3")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento com o erro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oSelf <> nil
			oSelf:Savelog("ERRO","DATAFIN",STR0016+STR0017)	//"Processamento iniciado."
		Else
			ProcLogAtu("ERRO","DATAFIN",STR0016+STR0017)	//"Processamento iniciado."
		EndIf

		Return
	Endif

	// Carrega a tabela 14 do SX5
	aTabela14 := FWGetSX5( "14" )
	For ny:=1 To Len(aTabela14)
		cTabela14 += (Alltrim(aTabela14[ny][3]) + "/")
	Next ny
	cTabela14 += If(cPaisLoc=="BRA","","/$ ")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01 // Do Banco                                         ³
	//³ mv_par02 // Ate o Banco                                      ³
	//³ mv_par03 // Da Agˆncia                                       ³
	//³ mv_par04 // At‚ a Agˆncia                                    ³
	//³ mv_par05 // Da Conta                                         ³
	//³ mv_par06 // At‚ a Conta                                      ³
	//³ mv_par07 // A partir da Data                                 ³
	//³ mv_par08 // Seleciona Filiais?                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia rec lculo dos saldos, atrav‚s da movimenta‡„o banc ria³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT SA6.R_E_C_N_O_ A6_RECNO,"
	cQuery += " FK5_FILIAL, FK5_BANCO, FK5_AGENCI, FK5_CONTA, FK5_DTDISP, FK5_TPDOC, FK5_MOEDA,"
	cQuery += " FK5_NUMCH, FK5_RECPAG, FK5_VALOR, FK5_DOC, FK5_DTCONC, FK5_SEQ, FK5_FILORI, A6_MOEDA "
	cQuery += " FROM " + RetSqlName("SA6") + " SA6, " + RetSqlName("FK5") + " FK5"
	cQuery += " WHERE SA6.D_E_L_E_T_ = ' '"
	cQuery += " AND FK5.D_E_L_E_T_ = ' '"

	//**************************************************************************************************
	// Solucao | Multi filial | A6 | FK5 | E8 | Descricao                                              *
	//     1   |     Sim      | E  |  E  | E  | Rodar Multi filial filtrando filial no A6, FK5         *
	//     2   |     Sim      | E  |  E  | C  | Normal com filial do A6 e no FK5 de '  ' ate 'ZZ'      *
	//     3   |     Sim      | E  |  C  | E  | Rodar Multi filial filtrando filial no A6 e FK5_FILORI *
	//         |     Sim      | E  |  C  | C  | Idem a Solucao 2                                       *
	//         |     Sim      | C  |  E  | E  | Idem a Solucao 1                                       *
	//         |     Nao      | C  |  E  | C  | Idem a Solucao 2                                       *
	//         |     Sim      | C  |  C  | E  | Idem a Solucao 3                                       *
	//     4   |     Nao      | C  |  C  | C  | Rodar Normal sem filtro                                *
	//**************************************************************************************************

	cQuery += " AND A6_COD between '" + mv_par01 + "' AND '" + mv_par02 + "'"
	cQuery += " AND A6_AGENCIA between '" + mv_par03 + "' AND '" + mv_par04 + "'"
	cQuery += " AND A6_NUMCON between '" + mv_par05 + "' AND '" + mv_par06 + "'"

	cQuery += " AND A6_COD = FK5_BANCO"
	cQuery += " AND A6_AGENCIA = FK5_AGENCI"
	cQuery += " AND A6_NUMCON = FK5_CONTA"
	cQuery += " AND FK5_TPDOC NOT IN ('BA','DC','JR','MT','CM','D2','J2','M2','C2','V2','CP','TL','VA') "
	cQuery += " AND FK5_DTDISP >= '" + dtos(mv_par07) + "'"

	cQuery += " ORDER BY FK5_BANCO, FK5_AGENCI, FK5_CONTA, FK5_DTDISP"

	cQuery := ChangeQuery(cQuery)

	dbSelectArea("FK5")
	FK5->( DbSetOrder(12) )

	dbSelectArea("SE8")

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TRB210',.T.,.T.)
	TcSetField("TRB210", "FK5_DTDISP", "D")

	While TRB210->(!Eof())
		
		If !lBat .Or. lLibSchedule
			If oSelf <> nil
				oSelf:IncRegua1(STR0015)
				oSelf:IncRegua2()
			Else
				IncProc()
			EndIf
		EndIf
		
		dbSelectArea("TRB210")

		//********************
		// Solução 1 , 2 e 4 *
		//********************
		If Empty(FwFilial("FK5")) .And. lBcoExcl
			cFilAux    := FK5_FILORI
			cFilTRB    := FwxFilial("SA6",cFilAux)
			cFilialSE8 := FwxFilial("SE8", cFilAux) 
		Else
			cFilAux := FK5_FILIAL
			cFilTRB := FwxFilial("FK5",cFilAux)
		EndIf
		
		cFilSE8  := FwxFilial("SE8",cFilAux)
		cFilFK5  := FwxFilial("FK5",cFilAux)
		nTamFilFK5 := Len(Alltrim(cFilFK5))
		nTamFilSE8 := Len(Alltrim(cFilSE8))	
		cBanco   := FK5_BANCO
		cAgencia := FK5_AGENCI
		cConta   := FK5_CONTA
		nMoeda 	 := A6_MOEDA
		nSaldoIni:= 0
		nEntradas:= 0
		nSaidas  := 0
		nEntrRec := 0
		nSaidRec := 0
		cFilSE82 := xFilial("SE8", cFilTRB)
		cFilFK52 := FWxFilial("FK5",cFilFK5)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Localiza Saldo de Partida.                              ³
		//³ Observe que o programa retorna um registro no banco de  ³
		//³ dados, portanto a data de referencia ‚  a data em que   ³
		//³ o saldo ficou errado, n„o a data correta do saldo.      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SE8->(dbSeek( cFilSE8+cBanco+cAgencia+cConta+Dtos(mv_par07),.T. ))
		SE8->(dbSkip( -1 ))
		
		If SE8->E8_FILIAL != cFilSE8 .or. SE8->E8_BANCO != cBanco .or. SE8->E8_AGENCIA != cAgencia .or. SE8->E8_CONTA != cConta .or. SE8->(BOF()) .or. SE8->(EOF())
			nSaldoIni := 0
			nSalRecIni := 0   //Saldo Reconciliado Inicial
		Else
			nSaldoIni := SE8->E8_SALATUA
			nSalRecIni := SE8->E8_SALRECO   //Saldo Reconciliado Inicial
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Localiza movimenta‡„o banc ria                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("TRB210")
		While TRB210->(!Eof()) .and. Eval( bBncFilIgl )
			dDataMovto := TRB210->FK5_DTDISP
			
			dbSelectArea("TRB210")
			While TRB210->(!Eof()) .and. Eval( bBncFilIgl ) .And. TRB210->FK5_DTDISP == dDataMovto
				If Empty(cFilSA6)
					cFilSA6 := TRB210->FK5_FILORI
				EndIf
			
				// Controle de acesso de Usuário às filiais selecionadas.
				If !lSolucao2
					If !__lUsAllFls
						If lSolucao3
							If !TRB210->FK5_FILORI $ cFils
								TRB210->(dbSkip())
								Loop
							EndIf
						ElseIf !TRB210->FK5_FILIAL $ cFils
							If Empty(FWxFilial("FK5"))
								If !cFilAnt $ cFils
									TRB210->(dbSkip())
									Loop
								EndIf
							Else
								TRB210->(dbSkip())
								Loop
							EndIf
						EndIf
					EndIf
				ElseIf lSol2C2
					If !TRB210->FK5_FILORI $ cFilSA6
						cFilSA6 += "/" + TRB210->FK5_FILORI
					EndIf
				EndIf
				
				If TRB210->FK5_MOEDA $ "C1/C2/C3/C4/C5/CH" .and. Empty(TRB210->FK5_NUMCH) .and. !(TRB210->FK5_TPDOC $ "TR#TE")
					TRB210->(dbSkip())
					Loop
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Na transferencia somente considera nestes numerarios 		  ³
				//³ No Fina100 ‚ tratado desta forma.                    		  ³
				//³ As transferencias TR de titulos p/ Desconto/Cau‡Æo (FINA060) ³
				//³ nÆo sofrem mesmo tratamento dos TR bancarias do FINA100      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If TRB210->FK5_TPDOC $ "TR/TE"
					If !(TRB210->FK5_MOEDA $ cTabela14)
						TRB210->(dbSkip())
						Loop
					Endif
				Endif

				If TRB210->FK5_TPDOC $ "TR/TE" .and. (Substr(TRB210->FK5_NUMCH,1,1)=="*" ;
					.or. Substr(TRB210->FK5_DOC,1,1) == "*" )
					TRB210->(dbSkip())
					Loop
				Endif

				If TRB210->FK5_MOEDA == "CH" .and. (IsCaixaLoja(TRB210->FK5_BANCO) .And. !lCxLoja .And. TRB210->FK5_TPDOC $ "TR/TE")	// Sangria
					TRB210->(dbSkip())
					Loop
				Endif

				If SubStr(TRB210->FK5_NUMCH,1,1)=="*"      //cheque para juntar (PA)
					TRB210->(dbSkip())
					Loop
				Endif

				If TRB210->FK5_RECPAG = "R"
					nEntradas += TRB210->FK5_VALOR
					nEntrRec += TRB210->FK5_VALOR
				Else
					nSaidas += TRB210->FK5_VALOR
					nEntrRec += TRB210->FK5_VALOR
				Endif
				If lFA210FK5
					ExecBlock("FA210FK5",.F.,.F.)
				EndIf
				TRB210->(dbSkip())
			Enddo  // Quebra da data
			
			cFilialSE8 := IIf(Empty(cFilialSE8), FwxFilial("SE8",cFilTRB), cFilialSE8)
			cChaveSE8  := ((cFilialSE8 + cBanco + cAgencia + cConta) + Dtos(dDataMovto))
			
			SE8->(dbSeek(cChaveSE8))
			
			IF SE8->(Eof())
				RecLock("SE8",.t.)
			Else
				RecLock("SE8",.f.)
			Endif
			
			SE8->E8_FILIAL  := cFilialSE8
			SE8->E8_BANCO   :=  cBanco
			SE8->E8_AGENCIA :=  cAgencia
			SE8->E8_CONTA   :=  cConta
			SE8->E8_DTSALAT :=  dDataMovto
			SE8->E8_SALATUA :=  nSaldoIni+nEntradas-nSaidas
			SE8->E8_SALRECO :=  nSalRecIni+nEntrRec-nSaidRec
			SE8->E8_MOEDA   := Str(Max(nMoeda,1),2)
			SE8->( MsUnlock() )

			If lFA210SE8
				ExecBlock("FA210SE8",.F.,.F.)
			EndIf
			
			If !(TRB210->(EoF())) .AND. TRB210->(FK5_BANCO+FK5_AGENCI+FK5_CONTA) == cBanco+cAgencia+cConta

				cQuery	:= " SELECT SE8.R_E_C_N_O_ RECNOSE8"
				cQuery	+= " FROM " + RetSqlName("SE8") + " SE8 "
				cQuery	+= " WHERE SE8.E8_DTSALAT BETWEEN '" + DToS(dDataMovto+1) + "' AND '" + DToS( (TRB210->FK5_DTDISP) - 1) + "' AND "
				cQuery	+= 			" SE8.E8_FILIAL = '" + cFilSE82 + "' AND "
				cQuery	+= 			" SE8.E8_BANCO = '" + cBanco + "' AND "
				cQuery	+= 			" SE8.E8_AGENCIA = '" + cAgencia + "' AND "
				cQuery	+= 			" SE8.E8_CONTA = '" + cConta + "' AND "
				cQuery	+= 			" SE8.D_E_L_E_T_ = '' "
				
				If lComp
					cQuery	+= 			" AND Not Exists ( "
					cQuery	+= 						" SELECT FK5.R_E_C_N_O_ RECNOFK5 "
					cQuery	+= 						" FROM	" + RetSqlName("FK5") + " FK5 "
					cQuery	+= 						" WHERE SE8.E8_DTSALAT = FK5.FK5_DTDISP AND "
					cQuery	+= 							" FK5.FK5_FILIAL = '" + cFilFK52 + "' AND "
					cQuery	+= 							" FK5.FK5_BANCO = SE8.E8_BANCO AND "
					cQuery	+= 							" FK5.FK5_AGENCI = SE8.E8_AGENCIA AND "
					cQuery	+= 							" FK5.FK5_CONTA = SE8.E8_CONTA AND "
					cQuery	+= 							" FK5.FK5_NUMCH = '" + TRB210->FK5_NUMCH + "' AND "
					cQuery  += 							" FK5.FK5_TPDOC NOT IN ('BA','DC','JR','MT','CM','D2','J2','M2','C2','V2','CP','TL','VA') AND "				
					cQuery	+= 							" FK5.D_E_L_E_T_ = '' "
					cQuery	+= 					" ) "
				EndIf
				
				cQuery := ChangeQuery(cQuery)
				
				DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), 'TRBSE8', .T., .T. )
				
				While !(TRBSE8->(Eof()))
					SE8->( DbGoTo( TRBSE8->RECNOSE8 ) )
					
					RecLock( "SE8", .F., .T. )
						SE8->( DbDelete() )
					SE8->( MsUnlock() )
					
					TRBSE8->( DbSkip() )
				EndDo
				
				TRBSE8->( DbCloseArea() )
				
			Else
			
				nData := dDataMovto
			
			EndIf

			If TRB210->(Eof()) .OR. TRB210->(FK5_BANCO+FK5_AGENCI+FK5_CONTA) != cBanco + cAgencia + cConta
				
				SE8->( DbSeek(FwxFilial("SE8",cFilTRB)+cBanco+cAgencia+cConta+dtos(dDataMovto+1), .T. ) )
				While !Eof() .and. FwxFilial("SE8",cFilTRB)+cBanco+cAgencia+cConta == SE8->(E8_FILIAL+E8_BANCO+E8_AGENCIA+E8_CONTA)
					RecLock("SE8",.F.,.T.)
					If lComp
						cChaveFK5 := TRB210->(FK5_BANCO+FK5_AGENCI+FK5_CONTA)+dtos(nData)+TRB210->FK5_NUMCH 
						aAreaAtu := GetArea()
						
						If FK5->(!DbSeek(FwxFilial("FK5",cFilTRB)+cChaveFK5))
							lAreaRest := .T.
							RestArea(aAreaAtu)
							SE8->(dbDelete())
						EndIf
						
						If !lAreaRest
							RestArea(aAreaAtu)
						EndIf
						
						lAreaRest := .F.				
					Else						
						SE8->(dbDelete())
					EndIf												
					SE8->(MsUnlock())
					SX2->(MsUnlock())
					SE8->(dbSkip())
				Enddo
			Endif
		
		Enddo  // Fecha Primeiro Loop do FK5

		If Empty(FwFilial("SA6")) .and. !Empty(FwFilial("SE8")) .and. !Empty(FwFilial("FK5"))	
			If lFirst
				dbSelectArea("SA6")
				If SA6->(dbSeek( xFilial("SA6")+cBanco+cAgencia+cConta))
					RecLock("SA6")
					Replace A6_SALATU With nSaldoIni+nEntradas-nSaidas
					SA6->(MsUnLock())
				EndIf
			Else	
				dbSelectArea("SA6")
				If SA6->(dbSeek( xFilial("SA6")+cBanco+cAgencia+cConta))
					RecLock("SA6")
					nNewSald := A6_SALATU + nSaldoIni+nEntradas-nSaidas
					Replace A6_SALATU With nNewSald
					SA6->(MsUnLock())
				EndIf
			EndIf	
		Else
			dbSelectArea("SA6")
			If lSolucao2 .and. lSol2C2				
				cQuery := "UPDATE " + RetSqlName("SA6") + " SET "
				cQuery += " A6_SALATU = " + Alltrim(Str(nSaldoIni+nEntradas-nSaidas))
				cQuery += " WHERE D_E_L_E_T_ = ' '"
				cQuery += " AND A6_FILIAL IN " + FormatIn(cFilSA6,"/")
				cQuery += " AND A6_COD = '" + cBanco + "'"
				cQuery += " AND A6_AGENCIA = '" + cAgencia + "'"
				cQuery += " AND A6_NUMCON = '" + cConta + "'"

				If TCSqlExec(cQuery) != 0
					Help(" ", 1, "FN210SLDBC", NIL, STR0023 + cBanco + " / " + cAgencia + " / " + cConta, 1, 0)	
					RollBackDelTran()
				EndIf
				
				cFilSA6 := ""
			Else
				If SA6->(dbSeek( xFilial("SA6")+cBanco+cAgencia+cConta))
					RecLock("SA6")
					Replace A6_SALATU With nSaldoIni+nEntradas-nSaidas
					SA6->(MsUnLock())
				EndIf
			EndIf
		Endif	
				

		dbSelectArea("TRB210")
	Enddo

	TRB210->(DbCloseArea())

	If oSelf <> nil
		oSelf:Savelog("FIM")
	EndIf

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AdmAbreSM0³ Autor ³ Orizio                ³ Data ³ 22/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array com as informacoes das filias das empresas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AdmAbreSM0()
	Local aArea			:= SM0->( GetArea() )
	Local aAux			:= {}
	Local aRetSM0		:= {}
	Local lFWLoadSM0	:= .T.
	Local lFWCodFilSM0 	:= .T.

	If lFWLoadSM0
		aRetSM0	:= FWLoadSM0()
	Else
		DbSelectArea( "SM0" )
		SM0->( DbGoTop() )
		While SM0->( !Eof() )
			aAux := { 	SM0->M0_CODIGO,;
						IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
						"",;
						"",;
						"",;
						SM0->M0_NOME,;
						SM0->M0_FILIAL }

			aAdd( aRetSM0, aClone( aAux ) )
			SM0->( DbSkip() )
		End
	EndIf

	RestArea( aArea )
Return aRetSM0

/*/{Protheus.doc} SchedDef
Uso - Execucao da rotina via Schedule.

Permite usar o botao Parametros da nova rotina de Schedule
para definir os parametros(SX1) que serao passados a rotina agendada.

@return  aParam
/*/

Static Function SchedDef(aEmp)

Local aParam := {}

aParam :=	{"P"		,;	//Tipo R para relatorio P para processo
			"FIN210"	,;	//Nome do grupo de perguntas (SX1)
			Nil			,;	//cAlias (para Relatorio)
			Nil			,;	//aArray (para Relatorio)
			Nil			}	//Titulo (para Relatorio)

Return aParam
