#Include 'Protheus.ch'
#Include 'FWEditPanel.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} MASMONIT
description
@type function
@version
@author tkz
/*/
User Function MASMONIT()

	Private cStatus1 := .T.
	Private cStatus2 := .T.
	Private cRepStat := .T.
	Private aEnableButtons := {{.f.,Nil},{.f.,Nil},{.f.,Nil},{.f.,Nil},{.f.,Nil},{.f.,Nil},{.f.,Nil},{.t.,"Fechar"},{.f.,Nil},{.f.,Nil},{.f.,Nil},{.f.,Nil},{.f.,Nil},{.f.,Nil}} //###"Fechar"
	FWExecView("Pesquisar","VIEWDEF.MASMONIT", 3, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, 	aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, /*oModel*/ )

Return

Static Function ModelDef()

	Local oModel
	Local oStrCab := GETSTCAB(1)
	Local oStrTab := GETSTTAB(1) // ZMV

	/*Campo Markbrowse*/
	bBloc:=FWBuildFeature(STRUCT_FEATURE_VALID,"U_CARX558()")
	oStrTab:AddField(' ', ' ', 'SELECT', 'L', 1, 0, bBloc ,, {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, ".F."))

	oModel := MPFormModel():New('MDMASMONIT',/*bPreValidacao*/,  /*{|oModel| u_validtok(oModel)} /* bTudoOK*/ ,  {|| .f.})

	oModel:SetDescription('Tela')
	oModel:addFields('MASTER',,oStrCab)
	oModel:getModel("MASTER"):SetDescription("MASMONIT")

	oModel:getModel("MASTER"):SetDescription("Grid")
	oModel:SetDescription("Monitor de Integra��es - Logs")

	oModel:addGrid('GRID1','MASTER',oStrTab)

	oStrTab:SetProperty("SELREG",MODEL_FIELD_WHEN,{|oModel,a,b,c,d|u_FWhen(a,b,c,d)} )

	oModel:GetModel("GRID1"):SetMaxLine( 999999 )

	oModel:SetPrimaryKey({})

	oModel:GetModel('GRID1'):SetOptional( .T. )

	oModel:GetModel( 'MASTER' ):SetOnlyQuery ( .T. ) //Não gravar dados de um componente do modelo de dados (SetOnlyQuery)

Return oModel

User Function FWhen(a,b,c,d)

	Local oModel     := FWModelActive()
	Local oDadosGd1  := oModel:GetModel("GRID1")
	Local lRet := .f.

	Private cTIPINTE := GetMV('MV_TIPINTE')

	if alltrim(oDadosGd1:GetValue("xSTATUS2",c)) == "2"

		nPos := AT( alltrim(oDadosGd1:GetValue("TIPO",c)), cTIPINTE )
		If nPos == 0
			MsgAlert('Tipo não parametrizado para reenvio. MV_TIPINTE', 'Atenção')
			lRet := .f.
		else
			lRet := .t.
		end
	ENDIF

Return lRet

Static Function ViewDef()

	Local oView
	Local oModel  := ModelDef()
	Local oStrCab := GETSTCAB(2)
	Local oStrTab := GETSTTAB(2) // ZMV

	oStrTab:RemoveField("xSTATUS2")
	oStrTab:RemoveField("ID")
	oStrTab:RemoveField("STATUS")
	oStrTab:RemoveField("SELREG")

	//Adicionando Campo de Markbrowse
	oStrTab:AddField( 'SELECT','00','','',, 'Check')

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('FORMCAB' , oStrCab,'MASTER' )
	oView:AddGrid('FORMTAB'  , oStrTab,'GRID1') //ZMV

	oView:AddUserButton( 'Excluir',        '', {|oView| LOADTAB('E')} )
	oView:AddUserButton( 'Resetar Status', '', {|oView| LOADTAB('R')} )

	oView:CreateHorizontalBox( 'BOXFORMCAB', 20) //Cabeçalho
	oView:SetOwnerView('FORMCAB','BOXFORMCAB')

	oView:CreateHorizontalBox( 'BOXDIV', 80) // Box horizontal

	oView:CreateVerticalBox( 'BOXDIREITA', 100, 'BOXDIV')
	oView:CreateHorizontalBox( 'BOXFORMTAB', 100, 'BOXDIREITA')
	oView:SetOwnerView('FORMTAB','BOXFORMTAB')

	oView:SetViewProperty('FORMCAB', 'SETCOLUMNSEPARATOR', {05})
	oView:SetViewProperty( "FORMCAB", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP  ,   } )

	oView:SetViewProperty("FORMTAB","GRIDNOORDER")

Return oView

Static function GETSTCAB(nTipo)
	Local oStruct   := NIL
	Local bValid    := NIl
	Local nI        := 0
	Local bInic     := NIL
	Local bWhen     := NIL
	Local aLista    := NIL
	Local cLista    := "STATUS"
	Local cTipCampo := ""
	Local aCampos   := {{'DATA DE'      ,'DATA DE'  ,'DTINI' ,'D',8 ,0,,''},;
		{'DATA AT�'     ,'DATA AT�' ,'DTFIM' ,'D',8 ,0,,''},;
		{'DADOS ORIGEM'        ,'DADOS ORIGEM'    ,'CHAVESEEK','C',66,0,,''},;
		{'DADOS DESTINO'        ,'DADOS DESTINO'    ,'CHAVESEE2','C',40,0,,''},;
		{'STATUS'       ,'STATUS'   ,'STATUS','C',1,0,,''},;
		{'TOP REG.'     ,'TOP REG.' ,'TOP'   ,'C',6,0,,''},;
		{'CONSULTAR/ATUALIZAR'    ,'CONSULTAR/ATUALIZAR','LOAD'  ,'C',1 ,0,,''},;
		{'MARCAR TODOS OS REGISTROS'    ,'MARCAR TODOS OS REGISTROS','FILTRO2'  ,'C',1 ,0,,''}}

	If nTipo == 1	// Model

		oStruct := FWFormModelStruct():New()
		oStruct:AddTable('TMP',,'TMP')
		oStruct:AddIndex( 1 , '' , 'DTINI', '' , '' , '', .F. )

		For nI := 1 to len(aCampos)
			bValid := ""
			bInic  := ""
			bWhen	:= Nil
			aLista := NIL

			IF aCampos[nI,3] == "LOAD" // Campo - Botao Atualizar
				bValid := "u_LOADING()"
				aCampos[nI,4] := 'BT'
			ENDIF

			IF aCampos[nI,3] == "FILTRO2" // Campo - Botao Atualizar os registros
				bValid := "u_fMark2()"
				aCampos[nI,4] := 'BT'
			ENDIF

			bValid := FwBuildFeature(1,bValid)

			If !Empty(bWhen)
				bWhen	:= FwBuildFeature(2,bWhen)
			EndIf

			bInic  := FwBuildFeature(3,bInic)

			oStruct:AddField(          ;
				aCampos[nI,1]		     , ;  // [01] Titulo do campo
			aCampos[nI,2]		     , ;  // [02] ToolTip do campo
			aCampos[nI,3]            , ;  // [03] Id do Field
			aCampos[nI,4]            , ;  // [04] Tipo do campo
			aCampos[nI,5]	         , ;  // [05] Tamanho do campo
			aCampos[nI,6]            , ;  // [06] Decimal do campo
			bValid                   , ;  // [07] Code-block de validação do campo
			bWhen		             , ;  // [08] Code-block de validação When do campo
			aLista                   , ;  // [09] Lista de valores permitido do campo
			NIL						 , ;  // [10] Indica se o campo tem preenchimento obrigatório
			bInic              		 , ;  // [11] Code-block de inicializacao do campo
			NIL                      , ;  // [12] Indica se trata-se de um campo chave
			.F.                      , ;  // [13] Indica se o campo pode receber valor em uma operação de update.
			.T.  )                        // [14] Indica se o campo é virtual

		NEXT nI

	ELSE

		oStruct := FWFormViewStruct():New()

		For nI := 1 to len(aCampos)

			IF(aCampos[nI,3]$cLista)
				cTipCampo := 'COMBO'
			else
				cTipCampo :='GET'
			ENDIF

			IF aCampos[nI,3] == "LOAD"
				cTipCampo := 'BT' // Quando o campo for do tipo Btn.
			ENDIF

			IF aCampos[nI,3] == "FILTRO2"
				cTipCampo := 'BT' // Quando o campo for do tipo Btn.
			ENDIF

			aLista := NIL

			IF aCampos[nI,3] == "STATUS"
				aLista := {"1=PROCESSADO COM SUCESSO","2=ERRO AO PROCESSAR","3=REPROCESSADO"}
			ELSEIF aCampos[nI,3] == "TOP"
				aLista := {"100","1000","5000","TODOS"}
			ENDIF

			oStruct:AddField( 			   ;
				aCampos[nI,3]  				 , ;                // [01] Campo
			STRZERO(nI,2)    			 , ;                // [02] Ordem
			aCampos[nI,1]				 , ;                // [03] Titulo
			aCampos[nI,2]			     , ;                // [04] Descricao
			NIL                          , ;                // [05] Help
			cTipCampo                    , ;      			// [06] Tipo do campo   COMBO, Get ou CHECK
			aCampos[nI,7]                , ;                // [07] Picture
			NIL                          , ;                // [08] PictVar
			aCampos[nI,8]                , ;                // [09] F3
			.T.	                         , ;                // [10] Editavel
			NIL               			 , ;                // [11] Folder
			NIL               			 , ;                // [12] Group
			aLista                       , ;                // [13] Lista Combo
			NIL                    		 , ;                // [14] Tam Max Combo
			NIL                			 , ;                // [15] Inic. Browse
			.T.                		    	)               // [16] Virtual
		Next nI

	ENDIF

Return oStruct

Static function GETSTTAB(nTipo)

	Local oStruct := NIL
	Local bValid  := NIl
	Local nI      := 0
	Local bInic   := NIL
	Local bWhen   := NIL
	Local aLista  := NIL
	Local cLista  := ""

	Local aCampos := {;
		{''          	       ,''                   ,'SELREG'      ,'L' ,1   ,0 , ,''} ,;
		{'FILIAL'      		   ,'FILIAL'             ,'FILIAL'      ,'C' ,2   ,0 , ,''} ,;
		{'DATA'      		   ,'DATA'               ,'DATA'        ,'D' ,8   ,0 , ,''} ,;
		{'HORA'      		   ,'HORA'               ,'HORA'        ,'C' ,5   ,0 , ,''} ,;
		{'DESCRICAO' 		   ,'DESCRICAO'          ,'DESC'        ,'C' ,250 ,0 , ,''} ,;
		{'ERRO'      		   ,'ERRO'               ,'ERRO'        ,'M' ,10  ,0 , ,''} ,;
		{'STATUS2'      	   ,'STATUS2'            ,"xSTATUS2"    ,'C' ,1   ,0 , ,''} ,;
		{'CHAVE ORIGEM'  	   ,'CHAVE ORIGEM'       ,"CHSEEKORI"   ,'C' ,15  ,0 , ,''} ,;
		{'FILDOC / DOC / SERIE ORIGEM'         ,'FILDOC / DOC / SERIE ORIGEM'        ,"SEEKORI"     ,'C' ,30  ,0 , ,''} ,;
		{'CHAVE DESTINO'  	   ,'CHAVE DESTINO'      ,"DESTINO"     ,'C' ,15  ,0 , ,''} ,;
		{'FILDOC / DOC / SERIE DESTINO'  	   ,'FILDOC / DOC / SERIE DESTINO'       ,"CHSEEKDEST"  ,'C' ,15  ,0 , ,''} ,;
		{'DADOS'  	           ,'DADOS'              ,"DADOS"       ,'M' ,10  ,0 , ,''} ,;
		{'IDTOKE'              ,'IDTOKE'             ,"IDTOKE"      ,'C' ,50  ,0 , ,''} ,;
		{'TIPO'      		   ,'TIPO'               ,'TIPO'        ,'C' ,4   ,0 , ,''}}

	If nTipo == 1	// Model

		oStruct := FWFormModelStruct():New()

		oStruct:AddTable('TMP_CAMPO',,'TMP_CAMPO')
		oStruct:AddIndex( 0, 'REG', '', '', '', '', .F. )

		For nI := 1 to len(aCampos)
			bValid := ""
			bInic  := ""
			bWhen  :=  Nil
			aLista := NIL

			bValid := FwBuildFeature(1,bValid)

			If !Empty(bWhen)
				bWhen	:= FwBuildFeature(2,bWhen)
			EndIf

			bInic  := FwBuildFeature(3,bInic)

			oStruct:AddField(;
				aCampos[nI,1]		     , ; // [01] Titulo do campo
			aCampos[nI,2]		     , ; // [02] ToolTip do campo
			aCampos[nI,3]            , ; // [03] Id do Field
			aCampos[nI,4]            , ; // [04] Tipo do campo
			aCampos[nI,5]	         , ; // [05] Tamanho do campo
			aCampos[nI,6]            , ; // [06] Decimal do campo
			bValid                   , ; // [07] Code-block de validação do campo
			bWhen		             , ; // [08] Code-block de validação When do campo
			aLista                   , ; // [09] Lista de valores permitido do campo
			NIL						 , ; // [10] Indica se o campo tem preenchimento obrigatório
			bInic              		 , ; // [11] Code-block de inicializacao do campo
			NIL                      , ; // [12] Indica se trata-se de um campo chave
			.F.                      , ; // [13] Indica se o campo pode receber valor em uma operação de update.
			.T.  )                       // [14] Indica se o campo é virtual

		NEXT nI
	ELSE

		oStruct := FWFormViewStruct():New()

		For nI := 1 to len(aCampos)

			aLista := NIL

			oStruct:AddField( 			     ;
				aCampos[nI,3]  			 , ;            // [01] Campo
			STRZERO(nI,2)    			 , ;            // [02] Ordem
			aCampos[nI,1]				 , ;            // [03] Titulo
			aCampos[nI,2]			     , ;            // [04] Descricao
			NIL                          , ;            // [05] Help
			Iif(aCampos[nI,3]$cLista,'COMBO','GET'), ;  // [06] Tipo do campo   COMBO, Get ou CHECK
			aCampos[nI,7]                , ;            // [07] Picture
			NIL                          , ;            // [08] PictVar
			aCampos[nI,8]                , ;            // [09] F3
			.T.                          , ;            // [10] Editavel
			NIL               			 , ;            // [11] Folder
			NIL               			 , ;            // [12] Group
			aLista                       , ;            // [13] Lista Combo
			NIL                    		 , ;            // [14] Tam Max Combo
			NIL                			 , ;            // [15] Inic. Browse
			.T.                		    	)           // [16] Virtual
		Next nI

	ENDIF

Return oStruct

Static function GETSTCAD(nTipo)

	Local oStruct := NIL
	Local bValid  := NIl
	Local nI      := 0
	Local bInic   := NIL
	Local bWhen   := NIL
	Local aLista  := NIL
	Local cLista  := ""

	Local aCampos := {{'','SEL','SEL','L',1,0,,''},;
		{'FILTROS','CADASTROS','CADASTROS','C',30,0,,''}}


	If nTipo == 1	// Model
		oStruct := FWFormModelStruct():New()
		oStruct:AddTable('INT',,'INT')
		oStruct:AddIndex( 0, 'SEL', '', '', '', '', .F. )

		For nI := 1 to len(aCampos)
			bValid := ""
			bInic  := ""
			bWhen  := Nil
			aLista := NIL

			bValid := FwBuildFeature(1,bValid)

			If !Empty(bWhen)
				bWhen	:= FwBuildFeature(2,bWhen)
			EndIf

			bInic  := FwBuildFeature(3,bInic)

			oStruct:AddField(              ;
				aCampos[nI,1]		     , ;          // [01] Titulo do campo
			aCampos[nI,2]		     , ;              // [02] ToolTip do campo
			aCampos[nI,3]            , ;              // [03] Id do Field
			aCampos[nI,4]            , ;              // [04] Tipo do campo
			aCampos[nI,5]	         , ;              // [05] Tamanho do campo
			aCampos[nI,6]            , ;              // [06] Decimal do campo
			bValid                   , ;              // [07] Code-block de validação do campo
			bWhen		             , ;              // [08] Code-block de validação When do campo
			aLista                   , ;              // [09] Lista de valores permitido do campo
			NIL						 , ;              // [10] Indica se o campo tem preenchimento obrigatório
			bInic              		 , ;              // [11] Code-block de inicializacao do campo
			NIL                      , ;              // [12] Indica se trata-se de um campo chave
			.F.                      , ;              // [13] Indica se o campo pode receber valor em uma operação de update.
			.T.  )                                    // [14] Indica se o campo é virtual

		NEXT nI

	ELSE

		oStruct := FWFormViewStruct():New()

		For nI := 1 to len(aCampos)

			aLista := NIL

			oStruct:AddField( 			   ;
				aCampos[nI,3]  			      , ;                // [01] Campo
			STRZERO(nI,2)    			 , ;                // [02] Ordem
			aCampos[nI,1]				 , ;                // [03] Titulo
			aCampos[nI,2]			     , ;                // [04] Descricao
			NIL                          , ;                // [05] Help
			Iif(aCampos[nI,3]$cLista,'COMBO','GET'), ;       // [06] Tipo do campo   COMBO, Get ou CHECK
			aCampos[nI,7]                , ;                // [07] Picture
			NIL                          , ;                // [08] PictVar
			aCampos[nI,8]                , ;                // [09] F3
			.T.	                         , ;                // [10] Editavel
			NIL               			 , ;                // [11] Folder
			NIL               			 , ;                // [12] Group
			aLista                       , ;                // [13] Lista Combo
			NIL                    		 , ;                // [14] Tam Max Combo
			NIL                			 , ;                // [15] Inic. Browse
			.T.                		    	)               // [16] Virtual
		Next nI

	ENDIF

Return oStruct

User function LOADING()
	Processa( { || LOADTAB( 'C' ) }, 'Carregando as informa�oes...', 'Aguarde... Executando a Consulta... ',.F.)
Return .t.

Static function LOADTAB(cOpcao)

	Local oModel      := FWModelActive()
	Local oView	      := FwViewActive()
	Local nErro       := 0
	Local cErros      := " Reset sem sucesso " +CRLF
	Local lOkay       := .F.
	Local lSEKCONT    := .F.
	Local lProces     := .T.
	Local lConti5000  := .T.
	Local nConGrid2   := 0
	Local nSuce       := 0
	Local cSeek       := ""
	Local aBindParam  := {}
	Local cQuery1     := ""
	Local cQuery2     := ""
	Local cQuery      := ""
	Local cQuery3     := ""
	Local cFilBack    := cFilAnt

	Local oStatement   := FWPreparedStatement():New()
	Local oDadosMast   := oModel:GetModel("MASTER")
	Local oDadosGd1    := oModel:GetModel("GRID1")

	ProcRegua(0)

	//Se informou o Token, desconsiderar os demais filtros.
	if Empty(oDadosMast:GetValue("CHAVESEEK")) .AND. Empty(oDadosMast:GetValue("CHAVESEE2"))
		if Empty(oDadosMast:GetValue("DTINI") )
			MsgStop("Data Inicial deve ser informada.", "Campo Obrigatorio")
			Return .T.
		ENDIF

		if Empty(oDadosMast:GetValue("DTFIM") )
			MsgStop("Data Final deve ser informada.", "Campo Obrigatorio")
			Return .T.
		ENDIF

		if Empty(oDadosMast:GetValue("STATUS") )
			oDadosMast:SetValue("STATUS","2")
		ENDIF
	ENDIF

	if Empty(oDadosMast:GetValue("TOP") )
		oDadosMast:SetValue("TOP","100")
	ENDIF

	IF cOpcao == "C"

		nTlReg2 := 0
		oDadosGd1:Cleardata()
		cAlias2 := GetNextAlias()

		//QUERY PARA CONTAR OS REGISTROS
		cQuery1 := " SELECT COUNT(*) AS COUNT FROM " + RETSQLNAME('ZMV') + " z "
		cQuery1 += " WHERE D_E_L_E_T_ = ? "
		cQuery1 += " AND ZMV_FILIAL = ? "

		//QUERY COM A QUANTIDADE DE REGISTRO <> DE TODOS
		IF ALLTRIM(oDadosMast:GetValue("TOP")) == "100"
			cQuery2 := " SELECT TOP 100 R_E_C_N_O_ AS REC FROM " + RETSQLNAME('ZMV') + " z "
		ELSEIF ALLTRIM(oDadosMast:GetValue("TOP")) == "1000"
			cQuery2 := " SELECT TOP 1000 R_E_C_N_O_ AS REC FROM " + RETSQLNAME('ZMV') + " z "
		ELSEIF ALLTRIM(oDadosMast:GetValue("TOP")) == "5000"
			cQuery2 := " SELECT TOP 5000 R_E_C_N_O_ AS REC FROM " + RETSQLNAME('ZMV') + " z "
		ENDIF

		cQuery2 += " WHERE D_E_L_E_T_ = ? "
		cQuery2 += " AND ZMV_FILIAL = ? "

		//QUERY COM A QUANTIDADE DE REGISTRO == TODOS
		cQuery3 := " SELECT R_E_C_N_O_ AS REC FROM " + RETSQLNAME('ZMV') + " z "
		cQuery3 += " WHERE D_E_L_E_T_ = ? "
		cQuery3 += " AND ZMV_FILIAL = ? "

		//PARAMETROS INICIAS PARA AS DUAS QUERYS
		aAdd( aBindParam, ' ' )
		aAdd( aBindParam, xFilial("ZMV"))


		//Se informou o Token, desconsiderar os demais filtros.
		if Empty(oDadosMast:GetValue("CHAVESEEK")) .AND. Empty(oDadosMast:GetValue("CHAVESEE2"))

			cQuery1 += " AND ZMV_DTGER  BETWEEN ? AND ?  "
			cQuery2 += " AND ZMV_DTGER  BETWEEN ? AND ?  "
			cQuery3 += " AND ZMV_DTGER  BETWEEN ? AND ?  "
			aAdd( aBindParam, DToS(oDadosMast:GetValue("DTINI")))
			aAdd( aBindParam, DToS(oDadosMast:GetValue("DTFIM")))

		ENDIF

		IF !Empty(oDadosMast:GetValue("CHAVESEEK") ) .or. !Empty(oDadosMast:GetValue("CHAVESEE2") )

			IF  !Empty(oDadosMast:GetValue("CHAVESEEK") )
				cQuery1 += " AND  ZMV_SEEK  like '%"+alltrim(oDadosMast:GetValue("CHAVESEEK"))+"%' "
				cQuery2 += " AND  ZMV_SEEK  like '%"+alltrim(oDadosMast:GetValue("CHAVESEEK"))+"%' "
				cQuery3 += " AND  ZMV_SEEK  like '%"+alltrim(oDadosMast:GetValue("CHAVESEEK"))+"%' "
				lSEKCONT := .T.
			ENDIF

			IF !Empty(oDadosMast:GetValue("CHAVESEE2") ) .AND. lSEKCONT
				cQuery1 += " OR   ZMV_SEE2  like '%"+alltrim(oDadosMast:GetValue("CHAVESEE2"))+"%' "
				cQuery2 += " OR   ZMV_SEE2  like '%"+alltrim(oDadosMast:GetValue("CHAVESEE2"))+"%' "
				cQuery3 += " OR   ZMV_SEE2  like '%"+alltrim(oDadosMast:GetValue("CHAVESEE2"))+"%' "
			ELSE
				cQuery1 += " AND  ZMV_SEE2  like '%"+alltrim(oDadosMast:GetValue("CHAVESEE2"))+"%' "
				cQuery2 += " AND  ZMV_SEE2  like '%"+alltrim(oDadosMast:GetValue("CHAVESEE2"))+"%' "
				cQuery3 += " AND  ZMV_SEE2  like '%"+alltrim(oDadosMast:GetValue("CHAVESEE2"))+"%' "
			ENDIF

		else

			//Status T = Todos
			IF oDadosMast:GetValue("STATUS") <> "T"
				cQuery1 += " AND  ZMV_STATUS  = ? "
				cQuery2 += " AND  ZMV_STATUS  = ? "
				cQuery3 += " AND  ZMV_STATUS  = ? "
				aAdd( aBindParam, oDadosMast:GetValue("STATUS"))
			ENDIF

		endif

		DbUseArea(.T.,'TOPCONN',TCGENQRY2(,,cQuery1,aBindParam),cAlias2,.T.,.T.)
		nTotalReg := Count

		IF ALLTRIM(oDadosMast:GetValue("TOP")) <> "TODOS"

			cAlias2 := GetNextAlias()
			cQuery2 += " GROUP BY R_E_C_N_O_ "
			cQuery2 += " ORDER BY R_E_C_N_O_ DESC "

			DbUseArea(.T.,'TOPCONN',TCGENQRY2(,,cQuery2,aBindParam),cAlias2,.T.,.T.)
			dbSelectArea(cAlias2)

			IF VAL(ALLTRIM(oDadosMast:GetValue("TOP"))) < nTotalReg
				nTlReg2 := VAL(ALLTRIM(oDadosMast:GetValue("TOP")))
			ENDIF
			(cAlias2)->(dbGoTop())

		ENDIF

		IF ALLTRIM(oDadosMast:GetValue("TOP")) == "TODOS"

			IF nTotalReg > 5000
				lConti5000 := MsgNoYes("Conjunto de filtros informados retornou mais de 5000 registros. Carregamento poderá demorar alguns minutos. Para otimização de tela, refine seu filtro.","Deseja continuar a consulta?")
			ENDIF

			IF lConti5000

				cAlias2 := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TCGENQRY2(,,cQuery3,aBindParam),cAlias2,.T.,.T.)
				(cAlias2)->(Dbgotop())

			ELSE
				oDadosGd1:ClearData()
				IF oView:isactive() // Está com problemas no refresh.
					oView:Refresh("GRID1")
				ENDIF
				Return .T.
			ENDIF
		ENDIF

		IF nTlReg2 <> 0
			nTotalReg := nTlReg2
		ENDIF

		ProcRegua(nTotalReg)
		cteste := " "

		nAtual := 0
		DbSelectArea("ZMV")
		If (cAlias2)->(!Eof())
			While (cAlias2)->(!Eof())

				nAtual++
				IncProc("Registro " + cValToChar(nAtual) + " de " + cValToChar(nTotalReg) + "...")
				ZMV->(DbGoto((cAlias2)->REC))

				if ZMV->ZMV_STATUS == "1"
					cStat := "BR_VERDE"
				elseif ZMV->ZMV_STATUS == "2"
					cStat := "BR_VERMELHO"
				else
					cStat := "BR_AMARELO"
				endif

				oDadosGd1:ADATAMODEL[nAtual][1][1][1]  := .F.
				oDadosGd1:ADATAMODEL[nAtual][1][1][2]  := ZMV->ZMV_FILIAL
				oDadosGd1:ADATAMODEL[nAtual][1][1][3]  := ZMV->ZMV_DTGER
				oDadosGd1:ADATAMODEL[nAtual][1][1][4]  := ZMV->ZMV_HRGER
				oDadosGd1:ADATAMODEL[nAtual][1][1][5]  := ZMV->ZMV_ERRO
				oDadosGd1:ADATAMODEL[nAtual][1][1][6]  := ZMV->ZMV_ERROME
				oDadosGd1:ADATAMODEL[nAtual][1][1][7]  := ZMV->ZMV_STATUS
				oDadosGd1:ADATAMODEL[nAtual][1][1][8]  := ZMV->ZMV_CHSEEK   //ORIGEM
				oDadosGd1:ADATAMODEL[nAtual][1][1][9]  := ZMV->ZMV_SEEK    //ORIGEM
				oDadosGd1:ADATAMODEL[nAtual][1][1][10] := ZMV->ZMV_CHSEE2 //DESTINO
				oDadosGd1:ADATAMODEL[nAtual][1][1][11] := ZMV->ZMV_SEE2    //DESTINO
				oDadosGd1:ADATAMODEL[nAtual][1][1][12] := ZMV->ZMV_DADOS
				oDadosGd1:ADATAMODEL[nAtual][1][1][13] := ZMV->ZMV_IDTOKE
				oDadosGd1:ADATAMODEL[nAtual][1][1][14] := ZMV->ZMV_TIPO

				cteste +=  ZMV->ZMV_ERROME + "  " + ZMV->ZMV_SEEK + CRLF

				(cAlias2)->(DbSkip())

				if (cAlias2)->(!Eof())
					oDadosGd1:AddLine()
				ENDIF

			ENDDO

			oDadosGd1:goline(1)
			(cAlias2)->(DbCloseArea())
		ENDIF

		if oView:isactive() // Está com problemas no refresh.
			oView:Refresh("GRID1")
		endif


		//EXCLUIR TODOS OS REGISTROS DE ACORDO COM O PERIODO E FILTROS
	ELSEIF cOpcao = 'E'

		cTexto := 'Serao excluidos os registros de acordo com o periodo, status e demais filtros informados.'
		if !MsgNoYes(cTexto, 'Confirma Exclusao?')
			MsgAlert(' Exclusao nao efetuada.', 'Excluir')
		else

			for nConGrid2 := 1 to oDadosGd1:GetQTDLine() //PEGA A QUANTIDADE DE LINHAS QUE APARECEM EM TELA

				oDadosGd1:Goline(nConGrid2) // POSICIONA NA LINHA

				IF oDadosGd1:getvalue('SELECT') // RETORNA SE A LINHA ESTÝ MARCADA

					cSeek := oDadosGd1:getvalue("SEEKORI")

					cQuery := "  UPDATE "+ RetSQLName("ZMV")
					cQuery += "  SET D_E_L_E_T_ =  ? "
					cQuery += "  ,R_E_C_D_E_L_  = R_E_C_N_O_ "
					cQuery += " WHERE D_E_L_E_T_ = ?  "
					cQuery += " AND ZMV_SEEK = ?      "
					cQuery += " AND ZMV_FILIAL = ? "

					oStatExcl:= FWPreparedStatement():New()
					oStatExcl:SetQuery(cQuery)
					oStatExcl:SetString(1, '*' )
					oStatExcl:SetString(2, ' ' )
					oStatExcl:SetString(3,Alltrim(cSeek))
					oStatExcl:SetString(4,xFilial("ZMV"))
					cQuery := oStatExcl:GetFixQuery()

					IF TCSqlExec(cQuery) < 0

						IF nErro < 1
							cErros:= "Problema em Excluir O(s) Registro: "
						ELSE
							cErros+= cSeek+CRLF
						ENDIF
						nErro += 1
					ELSE

						nSuce+= 1
					ENDIF

					oStatExcl:Destroy()

				ENDIF

			next nConGrid2

			IF  nErro > 0
				MsgAlert( cErros , 'Atencao')
				lProces := .F.
			ENDIF

			IF nSuce > 0
				MsgAlert('Exclusao efetuada com sucesso', 'Excluir')
				lProces := .F.
			ENDIF

			IF lProces
				MsgAlert('Nenhum registro foi Excluido ou apresentou erro', 'Atencao')
			ENDIF

			nErro := 0
			nSuce := 0

		ENDIF

	ELSEIF  cOpcao = 'R'

		IF  oDadosMast:GetValue("STATUS") <> "3"

			cTexto := 'Serao resetados os registros de acordo com o periodo, status e demais filtros informados.'
			if !MsgNoYes(cTexto, 'Confirma Reset?')
				MsgAlert(' Reset não efetuado.', 'Reset')
			else

				for nConGrid2 := 1 to oDadosGd1:GetQTDLine() //PEGA A QUANTIDADE DE LINHAS QUE APARECEM EM TELA

					oDadosGd1:Goline(nConGrid2) // POSICIONA NA LINHA

					IF "I001" == oDadosGd1:getvalue("TIPO") // VALIDA SE È O MESMO FILTRO E MESMO TIDO SELECIONADO PARA REPROCESSAR

						IF oDadosGd1:getvalue('SELECT') // RETORNA SE A LINHA ESTÝ MARCADA

							cSeek := oDadosGd1:getvalue("SEEKORI")
							cSeek := SubStr(cSeek,1,6)+SubStr(cSeek,10,9)+SubStr(cSeek,22,2)

							IF !EMPTY(ALLTRIM(cSeek))

								cFilAnt := SUBSTR( cSeek, 1, 4)
								
								DBSELECTAREA('ZA1')
								ZA1->(DBSETORDER(1))
								IF ZA1->(DBSEEK(xFilial('ZA1')+ALLTRIM(cSeek)))

									cFilAnt := cFilBack

									IF ALLTRIM(cSeek) == ALLTRIM(ZA1->ZA1_FILDOC+ZA1->ZA1_CTEDOC+ZA1->ZA1_CTESER)

										IF !EMPTY(ALLTRIM(ZA1->ZA1_STATUS))  

											lOkay := .F.

											//CARXFUNA() & fPopulTab()
											IF (ZA1->ZA1_STATUS ==  "E") .or. (ALLTRIM(ZA1->ZA1_STATUS) == "S") .or. (ALLTRIM(ZA1->ZA1_STATUS) == "R")                

												RecLock("ZA1" ,  .F. )
												ZA1->ZA1_STATUS := "I"
												ZA1->(MsUnlock())
												lOkay := .T.

											ENDIF

											//VALIDA��O PARA ATUALIZAR ZMV_STATUS PARA "3"
											IF lOkay

												nSuce += 1
												cQuery := " SELECT R_E_C_N_O_ AS RECNO FROM " + RETSQLNAME('ZMV')
												cQuery += " WHERE D_E_L_E_T_ = ? "
												cQuery += " AND ZMV_SEEK = ? "
												cAlias  := GetNextAlias()

												oStatement := FWPreparedStatement():New()
												oStatement:SetQuery(cQuery)
												oStatement:SetString(1, ' ')
												oStatement:SetString(2, oDadosGd1:getvalue("SEEKORI"))

												cQuery := oStatement:GetFixQuery()
												cQuery := ChangeQuery(cQuery)
												cAlias  := MPSysOpenQuery(cQuery)

												WHILE (cAlias)->(!Eof())

													DBSELECTAREA('ZMV')
													DBSETORDER(1)
													ZMV->(DbGoTo((cAlias)->RECNO))
													RecLock("ZMV" ,  .F. )
													ZMV->ZMV_STATUS := "3"
													ZMV->(MsUnlock())
													(cAlias)->(DbSkip())

												ENDDO

												(cAlias)->(DBCLOSEAREA())
												oStatement:Destroy()
												lOkay := .F.

											ELSE
												//VALIDA��O PARA GRAVAR OS REGISTRO QUE N�O ALTEREM O STATUS POR ALGUM MOTIVO
												cErros+=  cSeek  +CRLF
												nErro += 1

											ENDIF
										ENDIF
									ELSE
										//VALIDA��O PARA GRAVAR OS REGISTRO ONDEO SEEK DA ZMV EST� DIFERENTE DA ZA1
										cErros+=  cSeek + "CHAVE ZMV_SEEK <> CHAVE ZA1->ZA1_FILDOC+ZA1->ZA1_CTEDOC+ZA1->ZA1_CTESER" +CRLF
										nErro += 1

									ENDIF
								ELSE
									//VALIDA��O PARA GRAVAR OS REGISTRO SEM ONDE N�O FOI ENCONTRADO O REGISTRO NA ZA1
									cErros+=  cSeek + "RESGISTRO N�O ENCONTRADO" +CRLF
									nErro += 1

								ENDIF
							ELSE
								//VALIDA��O PARA GRAVAR OS REGISTRO SEM ZMV_SEEK
								cErros+=  " SEEK EM BRANCO "+CRLF
								nErro += 1

							ENDIF
						ENDIF
					ENDIF

				next nConGrid2

				IF  nErro > 0
					MsgAlert( cErros , 'Reset')
					lProces := .F.
				ENDIF

				IF nSuce > 0
					MsgAlert('Reset efetuado com sucesso', 'Reset')
					lProces := .F.
				ENDIF

				IF lProces
					MsgAlert('Nenhum registro foi resetado ou apresentou erro', 'Atencao')
				ENDIF

				nErro := 0

			ENDIF
		ELSE
			MSGINFO( 'Verificar Status selecionado.', 'ATENCAO !' )
		ENDIF
		oDadosGd1:Cleardata()
	ENDIF

Return .T.

//Usado para conseguir marcar a caixa de seleção, caso necessário daria para fazer uma validação aqui.
user Function CARX558()

Return .t.

user Function fMark2()

	Local oModel   := FWModelActive()
	Local oMdlZB4  := oModel:GetModel("GRID1")
	Local oView    := FWViewActive()
	Local nTamGrd  := oMdlZB4:Length(.t.)
	Local n1
	Local lMark := .f.

	For n1 := 1 to nTamGrd
		oMdlZB4:GOLINE(n1)
		if oMdlZB4:Getvalue("SELECT")
			lMark := .t.
			exit
		endif
	Next n1

	if lMark //Se tem um marcado Desmarca Todos
		For n1 := 1 to nTamGrd
			oMdlZB4:GOLINE(n1)
			oMdlZB4:setvalue("SELECT",.f.)
		Next n1
	else
		For n1 := 1 to nTamGrd
			oMdlZB4:GOLINE(n1)
			oMdlZB4:setvalue("SELECT",.t.)
		Next n1
	endif

	oMdlZB4:GOLINE(1)
	oView:Refresh()

Return .T.
