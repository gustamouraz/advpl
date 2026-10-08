#INCLUDE "OGA190.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

Static oMBrowse     := Nil
Static lF10Exec     := .T.
Static aParBal      := nil      // -- Será inicializada na funcao no Activate do Model (Devido a Error log se executado em MDI )--/
/** {Protheus.doc} ZOGA190
Rotina para pesagem avulsas em balanças cadastradas

@param:     Nil
@author:    Vinicius Becher Pagung
@since:     08/04/2016
@Uso:       SIGAARM - Originação de Grãos
*/
User Function ZOGA190()
	Local bKeyF10       := SetKey( VK_F10, { || ZOGA190VKF10(NJH->NJH_CODPAV) 			} )
	Local bKeyF12       := SetKey( VK_F12, { || aParBal:= AGRX003E( .t., 'OGA050001' )   } )

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NJH" )
	oMBrowse:SetDescription( STR0001 ) //"Pesagens Avulsas"
	oMBrowse:SetMenuDef( "ZOGA190" )
	oMBrowse:AddLegend( "NJH_STATUS=='0'", "RED"        , STR0002 )//"Sem Pesagem"
	oMBrowse:AddLegend( "NJH_STATUS=='1'", "YELLOW"     , STR0003) //"Primeira Pesagem"
	oMBrowse:AddLegend( "NJH_STATUS=='2'", "GREEN"      , STR0004) //"Segunda Pesagem"
	oMBrowse:AddLegend( "NJH_STATUS=='3'", "GRAY"       , STR0005) //"Finalizada"
	oMBrowse:AddLegend( "NJH_STATUS=='4'", "BR_CANCEL"  , STR0037) //"Cancelada"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

	SetKey( VK_F10, bKeyF10 )
	SetKey( VK_F12, bKeyF12 )

Return( )


/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param:     Nil
@return:    aRotina - Array com os itens do menu
@author:    Vinicius Becher Pagung
@since:     11/04/2016
@Uso:       ZOGA190 - Pesagens
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0007    , "PesqBrw"         , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0008    , "ViewDef.ZOGA190" , 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0009    , "ViewDef.ZOGA190" , 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0010    , "ViewDef.ZOGA190" , 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0036 	, "U_ZOGA190C"      , 0, 4, 0, Nil } ) //"Cancelar"
	aAdd( aRotina, { STR0012    , "U_ZOGA190F"      , 0, 4, 0, Nil } ) //"Finalizar"
	aAdd( aRotina, { STR0032    , "U_ZOGA190VKF10(NJH->NJH_CODPAV)", 0, 4, 0, Nil } ) //"Pesagem"
	aAdd( aRotina, { STR0013    , "U_ZOGA190REL"      , 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0014    , "ViewDef.ZOGA190" , 0, 9, 0, Nil } ) //"Copiar"

Return( aRotina )


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param:     Nil
@return:    oModel - Modelo de dados
@author:    Vinicius Becher Pagung
@since:     11/04/2016
@Uso:       ZOGA190 - Pesagens
*/
Static Function ModelDef()

    Local oStru := FWFormStruct(1, "NJH")
    Local oModel
    Local bPre := Nil
    Local bPos := {| oModel | PosModelo( oModel ) }
    Local bCommit := {| oModel | GrvModelo( oModel ) }
    Local bCancel := Nil

    //Cria o modelo de dados para cadastro
    oModel := MPFormModel():New("FPMNJHO", bPre, bPos, bCommit, bCancel)
    oModel:AddFields("NJHUNICO", /*cOwner*/, oStru)
    oModel:SetDescription(STR0015) //"Pesagem Avulsa"
    oModel:GetModel("NJHUNICO"):SetDescription( "Dados de - " + STR0016 ) //"Dados da Pesagem"
    oModel:SetPrimaryKey({'NJH_FILIAL','NJH_CODPAV'})
	oModel:SetDeActivate( { | oModel | fFimModelo( oModel )                        } )
	oModel:SetVldActivate( { | oModel | IniModelo( oModel, oModel:GetOperation() ) } )

	// If cFilAnt $ SuperGetMv("MV_ZCTFILR", .F., "020101")
    // 	oStru:SetProperty("NJH_XCTE", MODEL_FIELD_OBRIGAT, .T.)
    // 	oStru:SetProperty("NJH_CODTRA", MODEL_FIELD_OBRIGAT, .T.)
	// EndIf

Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param:     Nil
@return:    oView - View do modelo de dados
@author:    Vinicius Becher Pagung
@since:     11/04/2016
@Uso:       ZOGA190 - Pesagens
*/
Static Function ViewDef()

	Local oModel := FWLoadModel("ZOGA190")
    Local oStru := FWFormStruct(2, "NJH")
    Local oView
 
    //Cria a visualizacao do cadastro
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_NJH", oStru, "NJHUNICO")
 
    //Partes da tela
    oView:CreateHorizontalBox("CABEC", 100)
    oView:SetOwnerView("VIEW_NJH", "CABEC")
    oView:EnableControlBar(.T.)

    //Titulos
    oView:EnableTitleView("VIEW_NJH", "Dados de " + STR0015) //"Pesagem Avulsa"

	///=== Define métodos do View ===/// 
	oView:SetAfterViewActivate( { | oModel | fAftViewActiv( oModel ) } )
	oView:AddUserButton( STR0017, "BALANCA", {| x | ZOGA190PESA( oModel , "VIEW"  ) } ) //"Capturar Peso"

	oView:SetCloseOnOk( {||.T.} )
  
Return( oView )

/** {Protheus.doc} IniModelo
Função que valida a inicialização do modelo de dados

@param:     oModel - Modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Vinicius Becher Pagung
@since:     18/04/2016
@Uso:       ZOGA190 - Pesagem Avulsa.
*/
Static Function IniModelo( oModel, nOperation)
	Local lRetorno   := .T.
    
	If nOperation == MODEL_OPERATION_UPDATE
		IF NJH->NJH_STATUS = '3' .or. NJH->NJH_STATUS = '4'
			Help( , ,STR0026, , STR0038, 1, 0 )
			lRetorno := .F.
		EndIf
	EndIf
    
Return(lRetorno)

/** {Protheus.doc} PosModelo
Função que valida o modelo de dados após a confirmação

@param:     oModel - Modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Vinicius Becher Pagung
@since:     08/04/2016
@Uso:       ZOGA190 - Pesagens
*/
Static Function PosModelo( oModel )
	Local lRetorno   := .t.
	Local nOperation := oModel:GetOperation()

	If nOperation == MODEL_OPERATION_DELETE
		Help( ,, STR0018,, STR0019, 1, 0) //"HELP"###"Nenhum registro pode ser excluido!!!"
		lRetorno := .f.
	EndIf
	If GetRpoRelease() >= "12.1.033"  .AND. NJH->(ColumnPos('NJH_CGC')) > 0 //Campos novo romaneio
		If !Empty( oModel:GetValue( "NJHUNICO", "NJH_CODMOT" ) )
			DbSelectArea("DA4")
			DBSetOrder(1)
			If DbSeek( FWxFilial("DA4") + oModel:GetValue( "NJHUNICO", "NJH_CODMOT" ) ) .AND. oModel:GetValue( "NJHUNICO", "NJH_CGC" ) <> DA4->DA4_CGC
				Help( ,, STR0018,, STR0044, 1, 0) //"HELP"###"O CPF/CNPJ informado para o transportador não corresponde com o valor cadastrado no sistema"
				lRetorno := .f.
			EndIf
		EndIf
		If !Empty( oModel:GetValue( "NJHUNICO", "NJH_CGC" ) ) .AND. !CGC( oModel:GetValue( "NJHUNICO", "NJH_CGC" ) )
			Help( ,, STR0018,, STR0045, 1, 0) //"HELP"###""O CPF/CNPJ informado possui formato invalido"                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
			lRetorno := .f.
		EndIf
	EndIf
Return( lRetorno )


/** {Protheus.doc} GrvModelo
Função que grava o modelo de dados após a confirmação

@param:     oModel - Modelo de dados
@return:    lRetorno - verdadeiro ou falso
@author:    Vinicius Becher Pagung
@since:     11/04/2016
@Uso:       ZOGA190 - Pesagens
*/
Static Function GrvModelo( oModel )
	Local nOperation    := oModel:GetOperation()
	Local nPeso1        := oModel:GetValue( "NJHUNICO", "NJH_PESO1" )
	Local nPeso2        := oModel:GetValue( "NJHUNICO", "NJH_PESO2" )
	Local lRet := .T.

	If nOperation = MODEL_OPERATION_INSERT .Or. nOperation = MODEL_OPERATION_UPDATE

		If nPeso1 > 0
			oModel:SetValue( "NJHUNICO", "NJH_STATUS", "1" )
		EndIf
		
		If nPeso2 > 0 
			oModel:SetValue( "NJHUNICO", "NJH_STATUS", "2" )
		EndIf
    
    	If !(LMNJHVLD())
			lRet := .F.
		EndIf
	
	EndIf

	FWFormCommit( oModel )

Return( lRet )


/** {Protheus.doc} ZOGA190PESA
Função que cria interface para captura de peso da balança

@param:     oView - View do modelo de dados
@return:    .t. - sempre verdadeiro
@author:    Vinicius Becher Pagung
@since:     11/04/2016
@Uso:       ZOGA190 - Pesagens
*/
Static Function ZOGA190PESA( oModel, cOrigem )

	Local oView         := FWViewActive()
	Local aAreaAtu      := GetArea()
	Local oFldNJH       := oModel:GetModel( "NJHUNICO" )
	Local nOperation    := oModel:GetOperation()

	Local nPeso1        := oFldNJH:GetValue( "NJH_PESO1" )
	Local nPeso2        := oFldNJH:GetValue( "NJH_PESO2" )
	Local lPeso1        := oFldNJH:GetValue( "NJH_PESO1" ) = 0
	Local lPeso2        := oFldNJH:GetValue( "NJH_PESO2" ) = 0
	Local lPeso3        := oFldNJH:GetValue( "NJH_PESO1" ) > 0 .And. oFldNJH:GetValue( "NJH_PESO2" ) > 0
	Local nNJHRECNO     := NJH->( Recno() )
	Local oDlg          := Nil
	Local oCombo        := Nil
	Local cCombo        := ""
	Local nItem         := 1
	Local nPeso         := 0
	Local lPesagManu	:= .f.

	IF aParBal == nIl     // Para Ser Inicializado Somente Qdo ainda não foi
		aParBal := AGRX003E( .f., 'OGA050001' )
	EndIF

	If nOperation = MODEL_OPERATION_INSERT .Or. nOperation = MODEL_OPERATION_UPDATE

		If oFldNJH:GetValue( "NJH_STATUS" ) == "3"
			Help( ,, STR0021,, STR0033, 1, 0) //'HELP'###'Esta pesagem nao pode ser finalizada.'
			Return( Nil )
		EndIf
		If lPeso3 //Ja possui as duas pesagens

			oDlg    := TDialog():New(0,0,24,300,"",,,,,CLR_BLACK,CLR_WHITE,,,.T.)
			oCombo  := TComboBox():New( 001, 001, { |u| If( PCount() > 0, cCombo := u, cCombo ) }, {STR0003, STR0004}, 100, 020, oDlg, , { || nItem := oCombo:nAt }, , , , .t., , , , , , , , , "cCombo" ) //"Primeira Pesagem"###"Segunda Pesagem"
			oTButt  := TButton():New( 001, 104, STR0020, oDlg, { || oDlg:End() }, 040, 010, , , .f., .t., .f., , .f., , , .f. ) //"Confirma"
			oDlg:Activate( , , , .t., { || .t. }, , { || } )

			If nItem = 1
				lPeso1 := .t.
				lPeso2 := .f.
			ElseIf nItem = 2
				lPeso1 := .f.
	 			lPeso2 := .t.
			EndIf

		EndIf
		
		AGRX003A( @nPeso, .t., aParBal, /*cMask*/,@lPesagManu, nPeso1, nPeso2 )
		FwDateUpd(.F.,.F.) //atualiza database sistema na virada do dia  

		If nPeso > 0
			If lPeso1
				If nPeso <> nPeso2
					
					oFldNJH:SetValue( "NJH_DATPS1", dDataBase )
					oFldNJH:SetValue( "NJH_HORPS1", Substr( Time(), 1, 5 ) )
					oFldNJH:SetValue( "NJH_PESO1" , nPeso )
					oFldNJH:SetValue( "NJH_MODPS1", IIf( lPesagManu, "M", "A" ) )
					oFldNJH:SetValue( "NJH_PSSUBT", Abs( nPeso - nPeso2 ) )
					IF nPeso2 = 0
						oFldNJH:SetValue( "NJH_STATUS" , "1" )
					Else
						oFldNJH:SetValue( "NJH_STATUS" , "2" )
					EndIf
					If cOrigem == "VIEW"
						oView:ValidField("NJHUNICO","NJH_DATPS1",fWFldGet('NJH_DATPS1'),.T.)
					Else
						If oModel:VldData()
							oModel:CommitData()	
							oModel:DeActivate() // Desativa o modelo
							oModel:Destroy() // Destroy o objeto modelo	
						Else
							AutoGrLog(oModel:GetErrorMessage()[6])
							AutoGrLog(oModel:GetErrorMessage()[7])
							If !Empty(oModel:GetErrorMessage()[2]) .And. !Empty(oModel:GetErrorMessage()[9])
								AutoGrLog(oModel:GetErrorMessage()[2] + " = " + cValToChar(oModel:GetErrorMessage()[9]))
							EndIf
							MostraErro()
						EndIf					
					EndIf
				Else
					Help( ,, STR0021,, STR0034, 1, 0) //'HELP'###'Esta pesagem nao pode ser finalizada.'
					Return( .f. )
				EndIf
			ElseIf lPeso2 //Segunda Pesagem
				If nPeso <> nPeso1 // Consistência para não permitir 2 pesos iguais
					
					oFldNJH:SetValue( "NJH_DATPS2", dDataBase )
					oFldNJH:SetValue( "NJH_HORPS2", Substr( Time(), 1, 5 ) )
					oFldNJH:SetValue( "NJH_PESO2" , nPeso )
					oFldNJH:SetValue( "NJH_MODPS2", IIf( lPesagManu, "M", "A" ) )
					oFldNJH:SetValue( "NJH_PSSUBT", Abs( nPeso - nPeso1 ) )
					oFldNJH:SetValue( "NJH_STATUS" , "2" )
					If cOrigem == "VIEW"
						oView:ValidField("NJHUNICO","NJH_DATPS2",fWFldGet('NJH_DATPS2'),.T.)
					Else
						If oModel:VldData()
							oModel:CommitData()	
							oModel:DeActivate() // Desativa o modelo
							oModel:Destroy() // Destroy o objeto modelo	
						Else
							AutoGrLog(oModel:GetErrorMessage()[6])
							AutoGrLog(oModel:GetErrorMessage()[7])
							If !Empty(oModel:GetErrorMessage()[2]) .And. !Empty(oModel:GetErrorMessage()[9])
								AutoGrLog(oModel:GetErrorMessage()[2] + " = " + cValToChar(oModel:GetErrorMessage()[9]))
							EndIf
							MostraErro()
						EndIf			
					EndIf
				Else
					Help( ,, STR0021,, STR0035, 1, 0) //'HELP'###'Esta pesagem nao pode ser finalizada.'
					Return( .f. )
				EndIf
			EndIf
		EndIf
	EndIf

	If .Not. lF10Exec
		oView:Refresh()
	Else
		NJH->( DbGoTo( nNJHRECNO ) )
		oMBrowse:Refresh()
	Endif
	RestArea( aAreaAtu )
Return( .t. )


/** {Protheus.doc} ZOGA190F
Rotina para estorno do fechamento de pesagem

@param:     oModel - Modelo de Dados
@return:    lRetorno - .t. ou .f.
@author:    Vinícius Becher Pagung
@since:     11/04/2016
@Uso:       ZOGA190 - Pesagem avulsa
*/
User Function ZOGA190F( cAlias, nReg, nOpcao )
	Local lRetorno      := .t.
	Local aAreaAtu      := GetArea()

	If NJH->( NJH_STATUS ) <> "2"
		Help( ,, STR0021,, STR0028, 1, 0) //'HELP'###'Esta pesagem nao pode ser finalizada.'
		Return( Nil )
	EndIf

	If .Not. MsgYesNo(STR0029, STR0030) //""###"Finalizar Pesagem"
		Return( Nil )
	EndIf

	If lRetorno
		If RecLock( "NJH", .f. )
			NJH->( NJH_STATUS ) := "3"
			MsUnLock()
		EndIf
	EndIf

	RestArea( aAreaAtu )
Return( Nil )

/** {Protheus.doc} ZOGA190C
Rotina para o Cancelamento das pesagens

@param:     oModel - Modelo de Dados
@return:    lRetorno - .t. ou .f.
@author:    Vinícius Becher Pagung
@since:     11/04/2016
@Uso:       ZOGA190 - Pesagem avulsa
*/
User Function ZOGA190C( cAlias, nReg, nOpcao )
	Local lRetorno      := .t.
	Local aAreaAtu      := GetArea()

	If NJH->( NJH_STATUS ) == "3"
		Help( ,, STR0021,, STR0039, 1, 0) //'HELP'###'Esta pesagem nao pode ser cancelada.'
		Return( Nil )
	EndIf

	If .Not. MsgYesNo(STR0029, STR0040) //""###"Cancelar Pesagem"
		Return( Nil )
	EndIf

	If lRetorno
		If RecLock( "NJH", .f. )
			NJH->( NJH_STATUS ) := "4"
			MsUnLock()
		EndIf
	EndIf

	RestArea( aAreaAtu )
Return( Nil )


/** {Protheus.doc} ZOGA190VKF10
Função auxililar para chamar a rotina de pesagem

@param:     oModel - Modelo de Dados
@return:    Nil
@author:    Bruna Rocio
@since:     11/11/2014
@Uso:       OGA250 - Romaneio
*/

User Function ZOGA190VKF10(cCodigoPav)
	Local aAreaAtu  := GetArea()
	Local oModel    := FwModelActive()
    
	If lF10Exec = .T.
		dbSelectArea("NJH")
		dbSetOrder(1)
		If dbSeek( xFilial('NJH')+ cCodigoPav)

			oModel := FWLoadModel( "ZOGA190" )

			oModel:SetOperation( MODEL_OPERATION_UPDATE )
            
			IF ! oModel:Activate() // Verificando se o VldActivate Falhou
				cMsg := oModel:GetErrorMessage()[3] + oModel:GetErrorMessage()[6]
				Help( ,,"ERRO",,cMsg, 1, 0 ) //"Ajuda"
				Return (.f.)
			EndIF

			ZOGA190PESA( oModel, "GRID" )

		Else
		
			Help(, , STR0026, , STR0041 + Alltrim(cCodigoPav) + STR0042, 1, 0 )
			
		Endif

		If oModel != Nil
			// Desativamos o Model
			oModel:DeActivate()
		EndIf
	Else
		ZOGA190PESA( oModel, "VIEW" )
	Endif

	RestArea( aAreaAtu )
	DBSELECTAREA('NJH')
Return .t.

/** {Protheus.doc} fAftViewActiv
Função para setar o ambiente na ativação da view, chamada no SetAfterViewActivate()

@param:     oModel
@return:    NIL
@author:    Vinicius Becher Pagung
@since:     11/04/2016
@Uso:       ZOGA190 - Pesagem Avulsa
*/
Static Function fAftViewActiv( oModel )
  
	lF10Exec := .f.
   
Return NIL

/** {Protheus.doc} 7 ffimModelo
Função executada no Deactivate do modelo de dados

@param:     oModel - Modelo de dados
@param:     nOperation - Opcao escolhida pelo usuario no menu (incluir/alterar/excluir)
@return:    lRetorno - verdadeiro ou falso
@author:    E Coelho
@since:     10/09/2015
@Uso:       AgroIndustria
*/
Static Function fFimModelo( oModel )

	lF10Exec := .T.

Return(.t.)

/** {Protheus.doc} ZOGA190REL
Função que executa o relatório OGR190

@return:    lRetorno - verdadeiro ou falso
@author:    Marcos Wagner Jr.
@since:     11/01/2018
@Uso:       AgroIndustria
*/
User Function ZOGA190REL()

If NJH->NJH_PESO1 == 0 .AND. NJH->NJH_PESO2 == 0 
	If MsgYesNo(STR0043) //"Ainda não foi realizada a pesagem! Deseja imprimir mesmo assim?"
		OGR190()
	Endif
Else
	OGR190()	
EndIf

Return .t.

// /** {Protheus.doc} ZOGA190Cpf
// Função que define mascara do cpf

// @return:    lRetorno - verdadeiro ou falso
// @author:    Vanilda.moggio
// @since:     10/2020
// @Uso:       AgroIndustria
// */
// User Function ZOGA190Cpf()

//     Local cMasc := ""
//     If !Empty(M->NJH_CGC) .And. Len(AllTrim(M->NJH_CGC))<14
//         cMasc := "@R 999.999.999-99999%C" //Acrescentados 3 digitos p/ realizar a troca CPF/CNPJ 
//     Else
//         cMasc := "@R 99.999.999/9999-99%C"
//     EndIf

// Return cMasc


Static Function TrgNJH(cCampo)

	If cCampo == "NJH_CODMOT"
		Return Posicione("DA4",1,xFilial("DA4") + M->NJH_CODMOT ,"DA4_NOME")                                                                     
	Elseif cCampo == "NJH_CODTRA"
		Return Posicione("SA4",1,xFilial("SA4") + M->NJH_CODTRA,"A4_NOME")
	EndIf

Return ''

// Validação Luiz Moura 12/12/2025
Static Function LMNJHVLD()

    Local lRet  := .T. 

    Local cCte      := M->NJH_XCTE
    Local cCdTra    := M->NJH_CODTRA
    Local cCdTp     := M->NJH_XTIPO

    //Valida se for entrada na filial (MV_ZCTFILR) campo NJJ_XCTE e NJJ_CODTRA deve ser preenchido quando for tipo Entrada - Luiz Moura 12/12/2025
    If (Empty(cCte) .OR. Empty(cCdTra)) .AND. cFilAnt $ SuperGetMv("MV_ZCTFILR", .F., "020101") .AND. cCdTp = "E"
        MsgAlert('Por gentileza, informar o CTe e o Código do Transportador para entrada na filial '+cFilAnt, 'LMNJHVLD') 
        lRet := .F.
    EndIf

Return lRet
