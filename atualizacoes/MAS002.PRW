#include "protheus.ch"
#include "fina435.ch"
#Include "AP5MAIL.CH"
#include "FINA205.ch"
#INCLUDE "FINA590.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "rwmake.ch"
#Include "Protheus.ch"
#Include "Totvs.ch"


/*/{Protheus.doc} FINA435
Retorno de comunicação bancária a pagar - via Job.

@param   cParm01    Código da empresa.
@param   cParm02    Código da filial.

@author  Aldo Barbosa dos Santos
@since   31/05/2011
/*/
User Function MAS002()
Local aEmpresa  := {}
Local nEmpresa  := 0 
Private lExecJob := .T.
Private aMsgSch  := {}
Private aFA205R  := {}

//aAdd(aEmpresa,{"01","02","03","04","05","06","07","08","09","10","11","12","13","30","40","60","98"})

//For nEmpresa := 1 to Len(aEmpresa)
	lExecJob := .T.
	aMsgSch  := {}
	aFA205R  := {}

If Select("SX2") == 0
    RpcClearEnv()
    RPCSetType(3)
    If(!RpcSetEnv("01", "050101", "", "", "FIN",,{"SE5"}))
        Return(Nil)
    EndIf
    lRPC := .T.
EndIf

	//RpcSetEnv('01', '0501', Nil, Nil, Nil, "FIN")
		FA435JOB() 
	//RpcClearEnv()
//Next nEmpresa
Return

/*/{Protheus.doc} FA435JOB
Retorno de comunicação bancária a pagar - via Job.

@author  Aldo Barbosa dos Santos
@since   31/05/2011
/*/
Static Function FA435JOB()

Local cPerg	:= "AFI430"
Local tRetPg:= .T.
//Local aVetPar // vetor das perguntas
Local cQuery  // query de bancos que serao executados automaticamente
Local cAlias := ''
Local cBarra := If(IsSrvUnix(), "/", "\")
Local nA
local nI		:= 0 

Local aArq
Local cArquivo
Local cDirArq
Local cDirBkp

Local cPathArq := ""
Local cPathBkp := ""

Local lDirInc  := .F.
Local cDirInc  := ""
Local _aArqSEE := {} //RecnoSEE / EMPRESA, FILIAL, PATH E ARQUIVO 
Local _aTemp :=  {}
Local _aEmpFil := {}
Local _nX := 0 
Local _cEmpresa := ""
Local _cFilial := ""

/*André Claro
@Autor:       André Claro
@Data:        09/09/2024
@Descrição:   Realiza leitura da SEE e compara com os arquivos;
			  Realiza a composição dos arquivos por filial

*/



//// ANDRÉ CLARO - SEGUIREI COM A MESMA LÓGICA JÁ UTILIZADA

SEE->(dbsetorder(1))  // EE_FILIAL, EE_CODIGO, EE_AGENCIA, EE_CONTA, EE_SUBCTA.

lDirInc	:= SEE->(ColumnPos("EE_INCPAG")) > 0

cQuery := "SELECT SEE.R_E_C_N_O_ REGSEE, SA6.A6_XEMP "
cQuery += "FROM " + RetSqlName("SEE") + " SEE  INNER JOIN "+RetSqlName("SA6")+" SA6 ON "
cQuery += "			SEE.EE_FILIAL = SA6.A6_FILIAL "
cQuery += "		AND SA6.A6_COD = SEE.EE_CODIGO "
cQuery += "		AND SA6.A6_AGENCIA = SEE.EE_AGENCIA "
cQuery += "		AND SA6.A6_NUMCON = SEE.EE_CONTA  "
cQuery += "		AND SA6.D_E_L_E_T_ = '' " 
cQuery += "WHERE EE_FILIAL = '" + xFilial("SEE") + "' "
cQuery += "AND EE_RETAUT IN ('2', '3') " // 1.recebimento; 2.pagamento; 3.ambos
cQuery += "AND EE_DIRPAG <> ' ' " // Somente contas com diretório preenchido.
cQuery += "AND SEE.D_E_L_E_T_ = ' ' "

cAlias := GetNextAlias()

cAlias := MPSysOpenQuery(ChangeQuery(cQuery))
Do While (cAlias)->(!Eof())
	SEE->(dbGoto((cAlias)->REGSEE))
	If !fFA205ERRO()
		// le os arquivos do diretorio configurado 
		cDirArq := Alltrim(SEE->EE_DIRPAG)
		cDirBkp := Alltrim(SEE->EE_BKPPAG)

		// Verifica se os diretórios estão com a barra no final.
		If right(cDirArq, 1) <> cBarra
			cDirArq += cBarra
		Endif
		If !empty(cDirBkp) .and. right(cDirBkp, 1) <> cBarra
			cDirBkp += cBarra
		Endif
		sEE_EXTRET := 'RET'  //SEE->EE_EXTRET 
		// Lê os arquivos a serem processados.
		aArq := Directory(cDirArq + "*." + AllTrim(sEE_EXTRET) + "*")

		For nA := 1 to Len(aArq)

			// Armazena o nome do arquivo nos parâmetros.
			cArquivo := aArq[nA, 1]

			_aTemp := {}
			_aTemp := ACBUSCAFI(cDirArq, cArquivo) //retorna CEMP ANT E CFILANT

			If !Empty(_aTemp)
				If SubStr(_aTemp[3],1,4) $ Alltrim((cAlias)->A6_XEMP)
					aAdd(_aArqSEE, {_aTemp[1],_aTemp[2], (cAlias)->REGSEE, cDirArq, cArquivo }) //emp, fil, RECSEE, path, arq
				EndIf
			EndIf

		Next nA
	EndIf

	(cAlias)->(DbSkip())
EndDo

(cAlias)->(DbCloseArea())

_cImprime := ""
For _nX := 1 to Len(_aArqSEE)
	_cImprime += "EMP: "+_aArqSEE[_nX][1]+" FIL: "+_aArqSEE[_nX][2]+" REGSEE: "+CVALTOCHAR(_aArqSEE[_nX][3])+" PATH: "+_aArqSEE[_nX][4]+" ARQ: "+_aArqSEE[_nX][5]+CHAR(13)+CHAR(10)
Next _nX 

MemoWrite("C:\Temp\ARQUIVOS.TXT",_cImprime )

For _nX := 1 to Len(_aArqSEE)  //emp, fil, path, arq

	SEE->(dbsetorder(1))  // EE_FILIAL, EE_CODIGO, EE_AGENCIA, EE_CONTA, EE_SUBCTA.

	lDirInc	:= SEE->(ColumnPos("EE_INCPAG")) > 0

	// Lê as perguntas do FINA430 que serão modificadas de acordo com os novos campos da tabela de bancos.
	// Pergunte(cPergunta,lAsk,cTitle,lOnlyView,oDlg,lUseProf,aPerg,lBreakLine,lHasHelp)
	Pergunte(cPerg, .F., Nil, Nil, Nil, .F.)

		SEE->(dbGoto(_aArqSEE[_nX][3]))
		IF SEE->(RECNO()) == _aArqSEE[_nX][3] 

			_cEmpresa := _aArqSEE[_nX][1] 
			_cFilial := _aArqSEE[_nX][2] 
			_cDirArq := _aArqSEE[_nX][4] 
			_cArquivo := _aArqSEE[_nX][5]
			_nRecSEE := _aArqSEE[_nX][3] 
			_cLog := "Empresa "+_cEmpresa + CRLF
			_cLog += "Filial "+_cFilial + CRLF
			_cLog += "Pasta "+_cDirArq + CRLF
			_cLog += "Arquivo "+_cArquivo + CRLF

			MemoWrite("C:\Temp\ACMAS002"+_cArquivo+".TXT", _cLog )
			//StartJob("U_ACMAS002", GetEnvServer(), .F., _cEmpresa,  _cFilial, _cDirArq, _nRecSEE, _cArquivo )

			U_ACMAS002( _cEmpresa,  _cFilial, _cDirArq, _nRecSEE, _cArquivo )
		EndIf
Next _nX 

Return



    


User Function ACMAS002(_cEmp, _cFil, _cDirArq, _nRecSEE, _cArquivo)


Local cPerg	:= "AFI430"
Local tRetPg:= .T.
//Local aVetPar // vetor das perguntas
Local cQuery  // query de bancos que serao executados automaticamente
Local cAlias := ''
Local cBarra := If(IsSrvUnix(), "/", "\")
Local nA
local nI		:= 0 

Local aArq
Local cArquivo
Local cDirArq
Local cDirBkp

Local cPathArq := ""
Local cPathBkp := ""

Local lDirInc  := .F.
Local cDirInc  := ""
Local cLog := ""

    

		RpcClearEnv()
        RpcSetEnv(_cEmp, _cFil)

        cLog := "Início: " + Dtoc(Date()) + " " + Time()

        FWLogMsg("U_ACMAS002 "+cLog)
		DbSelectArea("SEE")

		SEE->(DbGoTo(_nRecSEE))
		// Verifica se todos os parâmetros necessários foram preechindos e grava no log.
		If !fFA205ERRO()

			// le os arquivos do diretorio configurado
			cDirArq := _cDirArq 
			cDirBkp := Alltrim(SEE->EE_BKPPAG)

			// Verifica se os diretórios estão com a barra no final.
			If right(cDirArq, 1) <> cBarra
				cDirArq += cBarra
			Endif
			If !empty(cDirBkp) .and. right(cDirBkp, 1) <> cBarra
				cDirBkp += cBarra
			Endif
			sEE_EXTRET := 'RET'  //SEE->EE_EXTRET 

				// Armazena o nome do arquivo nos parâmetros.
				cArquivo := _cArquivo

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica as perguntas selecionadas                 ³
				//³                                                    ³
				//³ Parametros                                         ³
				//³                                                    ³
				//³ MV_PAR01: Mostra Lanc. Contab  ? Sim Nao           ³
				//³ MV_PAR02: Aglutina Lanc. Contab? Sim Nao           ³
				//³ MV_PAR03: Arquivo de Entrada   ?                   ³
				//³ MV_PAR04: Arquivo de Config    ?                   ³
				//³ MV_PAR05: Banco                ?                   ³
				//³ MV_PAR06: Agencia              ?                   ³
				//³ MV_PAR07: Conta                ?                   ³
				//³ MV_PAR08: SubConta             ?                   ³
				//³ MV_PAR09: Contabiliza          ?                   ³
				//³ MV_PAR10: Padrao Cnab          ? Modelo1 Modelo 2  ³
				//³ MV_PAR11: Processa filiais     ? Modelo1 Modelo 2  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				// Atualiza o pergunte do FINA200 de acordo com a tabela de bancos
				aVet650 := {{'mv_par01', 2					},; // 01	Mostra Lanc Contab ?
							{'mv_par02', Val(SEE->EE_AGLCTB)},; // 02	Aglut Lancamentos ?
							{'mv_par03', cDirArq + cArquivo	},; // 03	Arquivo de Entrada ?
							{'mv_par04', SEE->EE_CFGPAG		},; // 04	Arquivo de Config ?
							{'mv_par05', SEE->EE_CODIGO		},; // 05	Codigo do Banco ?
							{'mv_par06', SEE->EE_AGENCIA	},; // 06	Codigo da Agencia ?
							{'mv_par07', SEE->EE_CONTA		},; // 07	Codigo da Conta ?
							{'mv_par08', SEE->EE_SUBCTA		},; // 08	Codigo da Sub-Conta ?
							{'mv_par09', 2					},; // 09	Contabiliza On Line ?
							{'mv_par10', Val(SEE->EE_CNABPG)},; // 10	Configuracao CNAB ?
							{'mv_par11', Val(SEE->EE_PROCFL)},; // 11	Processa Filial?
							{'mv_par12', 2					}}  // 12	Considera Multiplas naturezas ?

				// Controle de mensagens de erro.
				aMsgSch := {}

				// Executa o programa de recebimento.
				tRetPg := u_MAS001(1,aVet650)

				// Envia e-mail (FINA205) das mensagens de erro
				u_zFA205MAIL("Retorno Bancario Automatico (Pagar)", cDirArq + cArquivo, aMsgSch) // 

				If lDirInc
					cDirInc := Alltrim(SEE->EE_INCPAG)
				EndIf

				If Len(aMsgSch) == 0
					If !Empty(cDirBkp)
						cPathArq := cDirArq + cArquivo
						cPathBkp := cDirBkp + cArquivo
						If !_CopyFile(cPathArq, cPathBkp) //copia o arquivo para o diretorio de backup
							ConOut("Não foi possível copiar o arquivo " + cPathArq + " para o diretório " + cDirBkp) // "Não foi possível copiar o arquivo " # " para o diretório "
						Else
							// Exclui o arquivo processado.
							If FErase(cPathArq) < 0
								ConOut("Não foi possível excluir o arquivo " + cPathArq) // "Não foi possível excluir o arquivo "
								ConOut("fErase: " + "Erro " + cValToChar(FError()))  // "Erro "
							EndIf
						EndIf
					EndIf
				Else
					If lDirInc
						//Gera aquivo com erros encontrados
						nHandle := FCreate(cDirInc+left(alltrim(cArquivo),len(alltrim(cArquivo))-3)+'ERR')
						For nI := 1 to Len(aMsgSch)
							FWrite(nHandle, aMsgSch[nI])
						Next nI
						FClose(nHandle)
						cPathArq := cDirArq + cArquivo
						cPathInc := cDirInc + cArquivo		
						If !_CopyFile(cPathArq, cPathInc) //copia o arquivo para o diretorio de Inconsistencia.
							ConOut("Não foi possível copiar o arquivo " + cPathArq + " para o diretório " + cDirInc) // "Não foi possível copiar o arquivo " # " para o diretório "
						Else
							FErase(cPathArq)
						EndIf	
					EndIf
				EndIf
		EndIf
		
		cLog := "Finalizado: " + Dtoc(Date()) + " " + Time()
        FWLogMsg("ACMAS002 "+cLog  )

Return 

/*
??????????????????????????????????????
???????????????????????????????????????
???????????????????????????????????????
??un?o    ?A205Erro ?Autor ?Aldo Barbosa dos Santos        ?9/06/11??
???????????????????????????????????????
??escricao ?e os dados do pergunte												  ??
???????????????????????????????????????
???????????????????????????????????????
??????????????????????????????????????/
*/
Static Function fFA205ERRO()
Local aCpoVld := {}		// vetor com as validacoes dos campos necess?ios para o processamento
Local lErrVld := .F.		// controle de mensagem de alerta na validacao dos campos
Local nA

//If __lDirPag == Nil
	__lDirPag	:= SEE->(ColumnPos("EE_INCPAG")) > 0
//EndIf

//If __lDirRec == Nil
	__lDirRec	:= SEE->(ColumnPos("EE_INCREC")) > 0
//EndIf

// validacao dos campos necessarios para o processamento automatico
if SEE->EE_RETAUT $ '1|3' // receber ou ambos
	AAdd(aCpoVld,{'EE_ATUMOE',	{|| SEE->EE_ATUMOE <> ' ' }	,.F.})	// Atualiza Moeda
	AAdd(aCpoVld,{'EE_DIRREC',	{|| SEE->EE_DIRREC <> ' ' }	,.F.})	// Diretorio de Importacao Recebimento
	AAdd(aCpoVld,{'EE_CFGREC',	{|| SEE->EE_CFGREC <> ' ' }	,.F.})	// Diretorio de Configuracao Recebimento
	AAdd(aCpoVld,{'EE_BKPREC',	{|| SEE->EE_BKPREC <> ' ' }	,.F.})	// Diretorio de Backup Recebimento
	AAdd(aCpoVld,{'EE_DESCOM',	{|| SEE->EE_DESCOM <> ' ' }	,.F.})	// Abate desconto da Comissao
	AAdd(aCpoVld,{'EE_CNABRC',	{|| SEE->EE_CNABRC <> ' ' }	,.F.})	// Configuracao CNAB Recebimento
	AAdd(aCpoVld,{'EE_PROCFL',	{|| SEE->EE_PROCFL <> ' ' }	,.F.})	// Processa Filial

	If __lDirRec
		AAdd(aCpoVld,{'EE_INCREC',	{|| SEE->EE_INCREC <> ' ' }	,.F.})	// Diretorio de Arquivo Inconsistente
	EndIf

Endif	
if SEE->EE_RETAUT $ '2|3'  // pagar ou ambos
	AAdd(aCpoVld,{'EE_DIRPAG',	{|| SEE->EE_DIRPAG <> ' ' }	,.F.})	// Diretorio de Importacao Recebimento
	AAdd(aCpoVld,{'EE_CFGPAG',	{|| SEE->EE_CFGPAG <> ' ' }	,.F.})	// Diretorio de Configuracao Recebimento
	AAdd(aCpoVld,{'EE_BKPPAG',	{|| SEE->EE_BKPPAG <> ' ' }	,.F.})	// Diretorio de Backup Recebimento
	AAdd(aCpoVld,{'EE_CNABPG',	{|| SEE->EE_CNABPG <> ' ' }	,.F.})	// Configuracao CNAB Recebimento

	If __lDirPag
		AAdd(aCpoVld,{'EE_INCPAG',	{|| SEE->EE_INCPAG <> ' ' }	,.F.})	// Diretorio de Arquivo Inconsistente
	EndIf

Endif
if SEE->EE_RETAUT == '3'  //  ambos
	AAdd(aCpoVld,{'EE_AGLCTB',	{|| SEE->EE_AGLCTB <> ' ' }	,.F.})	// Aglutina lancamento contabil
	AAdd(aCpoVld,{'EE_MULTNT',	{|| SEE->EE_MULTNT <> ' ' }	,.F.})	// Considera Multiplas naturezas
Endif

lErrVld := .F.
For nA := 1 to Len(aCpoVld)
	if ! Eval(aCpoVld[nA,2])
		aCpoVld[nA,3] := .T.  // marca o campo com erro
		lErrVld := .T.
	Endif
Next

// se existe campos que nao atendam a validacao deve gravar o problema no log
if lErrVld
	ProcLogAtu("INICIO","Retorno Bancario Automatico (Receber) - Parametros de Bancos - Banco:"+SEE->EE_CODIGO+" "+SEE->EE_AGENCIA+" "+SEE->EE_CONTA+" "+SEE->EE_SUBCTA) // "Retorno Bancario Automatico (Receber) # "Parametros de Bancos - Banco:"
	For nA := 1 to Len(aCpoVld)
		if aCpoVld[nA,3]
			ProcLogAtu("ALERTA","Campo:"+aCpoVld[nA,1]+" com conteudo invalido ou nao informado.") // "Campo:" # " com conteudo invalido ou nao informado."
		Endif
	Next
	ProcLogAtu("FIM","Retorno Bancario Automatico (Receber) - Parametros de Bancos - Banco:"+SEE->EE_CODIGO+" "+SEE->EE_AGENCIA+" "+SEE->EE_CONTA+" "+SEE->EE_SUBCTA) // "Retorno Bancario Automatico (Receber) # "Parametros de Bancos - Banco:"
Endif		

Return( lErrVld )


**********************************************************
User Function zFA205MAIL(cTitulo,cArq, aMsgSch, lEnvAtch) // Envia email
*************
Local aArea			:= GetArea()
Local lSendMail	:= .F.
Local nAux			:= 0
Local cSubject		:= ""
Local cBody			:= ""
Local	cMsgErr     := ""
Local aDestE		:= {}
Local cDestE      := GetMv("MV_RETMAIL") // destinatarios do email de retorno automatico via schedule
Local cAttach     := ""
Local cFile		  := ""				

Default cTitulo := "Retorno Bancario Automatico"
Default cArq    := "ARQ.NAO.INFORMADO"
Default lEnvAtch:= .T.  // envia ou nao o arquivo como attach

// se o parametro de destinatarios de envio de email estiver vazio ignora o envio
If ValType(cDestE) <> "C" .or. Empty(cDestE)
	Return Nil
EndIf

aDestE := StrTokArr(cDestE,";")
If Len(aDestE) == 0
	Return Nil
EndIf

cSubject	:= cTitulo + ' - Arquivo: '+cArq + '  Processamento: ' +Dtoc(dDataBase) + ' - ' + Time()

// corpo principal do email com o resumo do emvio
cBody	:= '<HTML>'
cBody	+= ' <HEAD>'
cBody	+= '  <TITLE>'+cTitulo+' - Arquivo: '+cArq+'</TITLE>'
cBody	+= ' </HEAD>'
cBody	+= ' <BODY>'
cBody	+= '  <H1>'
cBody	+= '   <FONT SIZE="4" COLOR="#000099">'
cBody	+= '    <B>'+cTitulo+'</B>'
cBody	+= '   </FONT>'
cBody	+= '  </H1>'
cBody += '  <BR>
cBody	+= '   <FONT SIZE="3" COLOR="#000099">'
cBody	+= '    <B>Arquivo: '+cArq+'</B>'
cBody	+= '   </FONT>'
cBody	+= '  <H1><HR></H1>'

// adiciona as mensagens contidas no vetor
If Len(aMsgSch) >= 0
	cBody	+= '  <H1>'
	cBody	+= '   <FONT SIZE="3" COLOR="#000000">'
	cBody	+= '    Mensagens do Processamento : '
	cBody	+= '   </FONT>'
	cBody	+= '  </H1>'

	//??????????
	//?ONTAGEM DO E-MAIL?
	//??????????
	if Len(aMsgSch) == 0
		cBody += '<BR>&nbsp;&nbsp;-&nbsp;Processamento sem inconsistencias'
	Else
		For nAux := 1 To Len(aMsgSch)
			cBody += '<BR>&nbsp;&nbsp;-&nbsp;' + aMsgSch[nAux]
		Next
	Endif	
	cBody	+= '  <H1><HR></H1>'
EndIf

cBody	+= '  <H1>'
cBody	+= '   <FONT SIZE="2" COLOR="#FF0000">'
cBody	+= '    '+cSubject
cBody	+= '   </FONT>'
cBody	+= '  </H1>'
cBody	+= ' </BODY>'
cBody	+= '</HTML>'


// processa o relatorio de processamento e grava fisicamente no disco retornando o nome com o caminho
if lEnvAtch
	cPath		:=ALLTRIM(GETMV('MV_RELT'))
	cFile	 	:= Substr(cArq,rat("\",cArq)+1,len(cArq))          
	cFile		:= Substr(cFile,1, rat(".",cFile)-1)
	if File(cPath+cFile+".PDF")
		cAttach := cPath+cFile+".PDF"
	Endif	
Endif
// se nao tem assunto, ou corpo, ou destinatario - nao envia email para nao dar erro
If ! Empty(cSubject) .and. !Empty(cBody) .and. !Empty(aDestE)

     lSendMail := U_GEnvMail(cDestE, "RETORNO CNAB ITAU" , cBody , {}, /*MsgLog*/.F. , /*lTLS*/ .T. )

//	lSendMail 	:= FA205SENDMAIL(aDestE, cSubject, cBody, cAttach)

  	If !lSendMail .And. !Empty(cMsgErr)
  		ConOut(cMsgErr)  //-- Ocorreu um problema no envio do e-mail:
  	EndIf
EndIf

RestArea(aArea)

Return Nil


//Função que retorna o CNPJ dentro do arquivo.
// Retorno _cEmpFil - {01 , 060101}   //emp , filial
Static Function ACBUSCAFI(_cPath, _cFile)

Local _aEmpFil := {}
Local _cAlias1 := GetNextAlias()
Local _cQuery := "SELECT DISTINCT M0_CODFIL, M0_CODIGO, M0_FILIAL, M0_CGC, M0_INSC FROM SYS_COMPANY WHERE D_E_L_E_T_ = '' "
Local _cBuffer      := ""
Local _nTamE5FIL := 0
Local _aAreaSE5 := SE5->(GetArea())

DbSelectArea("SE5")
DBGOBOTTOM(  )

RestArea(_aAreaSE5)

_nTamE5FIL := Len(Alltrim(SE5->E5_FILIAL))
_nTamE5FIL := IIF(	_nTamE5FIL <= 0	,	TamSx3("E5_FILIAL")[1]	,	_nTamE5FIL)

    
FT_FUSE(_cPath+_cFile)  
FT_FGOTOP()
_nLinha := 0 

While !FT_FEOF() .and. Empty(_cBuffer)
	_cBuffer := ""
	_cBuffer := AllTrim(FT_FREADLN()) //conteúdo da primeira linha, onde consta o cnpj
	Exit	
	FT_FSKIP()
EndDo
FT_FUSE()

MPSysOpenQuery(_cQuery, _cAlias1)

While (_cAlias1)->(!eof()) .and. Empty(_aEmpFil)
	If Alltrim((_cAlias1)->M0_CGC) $ _cBuffer
		_aEmpFil := { Alltrim((_cAlias1)->M0_CODIGO) , Alltrim((_cAlias1)->M0_CODFIL), SubStr((_cAlias1)->M0_CODFIL,1,_nTamE5FIL) }
	EndIf
(_cAlias1)->(dbSkip())
EndDo
(_cAlias1)->(DbCloseArea())

Return _aEmpFil

