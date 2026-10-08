#INCLUDE "rwmake.ch"



#include 'protheus.ch'
#include 'fwmvcdef.ch'   
#Include 'topconn.ch'

Static cTitulo := "CFOP X USUARIOS"

User Function ACCADZGK() 
    Local aArea   := GetArea()
    Local oBrowse
	//Local _cFiltro := ""
    
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZGK")
    oBrowse:SetDescription(cTitulo)

	//_cFiltro += "  "
	
	//oBrowse:SetFilterDefault( "@"  + _cFiltro )  
    oBrowse:Activate()
      
    RestArea(aArea)
Return Nil
 
Static Function MenuDef()
    Local aRot := {}
      
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ACCADZGK' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.ACCADZGK' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.ACCADZGK' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.ACCADZGK' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 5

Return aRot
 
Static Function ModelDef()
    //Na montagem da estrutura do Modelo de dados, o cabeçalho filtrará e exibirá somente alguns campos, já a grid irá carregar a estrutura inteira conforme função fModStruct
    Local oModel      := NIL
    Local oStruCab    := FWFormStruct(1, 'ZGK', {|cCampo| AllTRim(cCampo) $ "ZGK_CFOP, ZGK_DESCRI, ZGK_REMDEV, ZGK_ATFIXO, ZGK_CFORIG"})
    Local oStruGrid   := FWFormStruct(1, 'ZGK', {|cCampo| AllTrim(cCampo) $ "ZGK_CFOP, ZGK_ITEM, ZGK_USER, ZGK_NOMEU, ZGK_PERMNF, ZGK_PROD"})
    

    oModel := MPFormModel():New('CADZGKM', {|| AVLVZGKALT() }, {|oModel| fValidGrid(oModel)}, {|oModel| fCommit(oModel) } , /*bCancel*/ )
 
    //Agora, define no modelo de dados, que terá um Cabeçalho e uma Grid apontando para estruturas acima
    oModel:AddFields('MdFieldZGK', NIL, oStruCab)
    oModel:AddGrid('MdGridZGK', 'MdFieldZGK', oStruGrid, , )
 
    //Monta o relacionamento entre Grid e Cabeçalho, as expressões da Esquerda representam o campo da Grid e da direita do Cabeçalho
    oModel:SetRelation('MdGridZGK', {;
            {'ZGK_FILIAL', 'xFilial("ZGK")'},;
            {"ZGK_CFOP",  "ZGK_CFOP"};
        }, ZGK->(IndexKey(1)))

    oStruCab:SetProperty("ZGK_CFOP", MODEL_FIELD_OBRIGAT, .T.)
    oStruCab:SetProperty("ZGK_DESCRI", MODEL_FIELD_OBRIGAT, .T.)
    oStruCab:SetProperty("ZGK_REMDEV", MODEL_FIELD_OBRIGAT, .T.)
    
    oStruGrid:SetProperty("ZGK_CFOP", MODEL_FIELD_OBRIGAT, .F.)

	//oStruGrid:SetProperty('ZGK_NOMMUN', MODEL_FIELD_INIT,  {|| GetAdvFVal("CC2", 'CC2_MUN'   , FwXFilial("CC2") + ZGK->ZGK_UF+ ZGK->ZGK_CODMUN, 1, "" )   }  )
	//oStruGrid:SetProperty('ZGK_TPVDES', MODEL_FIELD_INIT,  {|| GetAdvFVal("DUT", 'DUT_DESCRI', FwXFilial("DUT") + ZGK->ZGK_TPVEIC             , 1, "" )   }  )
	
	//oStruGrid:AddTrigger("ZGK_CODMUN", "ZGK_NOMMUN"	, {|| .T. }, {| oFields| GetAdvFVal("CC2", 'CC2_MUN', FwXFilial("CC2") + oFields:GetValue("ZGK_UF")+ oFields:GetValue("ZGK_CODMUN"), 1, "" )   })
    //oStruGrid:AddTrigger("ZGK_TPVEIC", "ZGK_TPVDES"	, {|| .T. }, {| oFields| GetAdvFVal("DUT", 'DUT_DESCRI', FwXFilial("DUT") + oFields:GetValue("ZGK_TPVEIC"), 1, "" )   })
    
    //Definindo outras informações do Modelo e da Grid
    oModel:GetModel("MdGridZGK"):SetMaxLine(9999)
    oModel:SetDescription("CFOP X Usuários")
    
    oModel:SetPrimaryKey({"ZGK_FILIAL","ZGK_CFOP","ZGK_USER, ZGK_PROD"})
 
Return oModel
 
Static Function ViewDef()
    //Na montagem da estrutura da visualização de dados, vamos chamar o modelo criado anteriormente, no cabeçalho vamos mostrar somente 3 campos, e na grid vamos carregar conforme a função fViewStruct
    Local oView        := NIL
    Local oModel    := FWLoadModel('ACCADZGK')
    Local oStruCab  := FWFormStruct(2, "ZGK", {|cCampo| AllTRim(cCampo) $ "ZGK_CFOP, ZGK_DESCRI, ZGK_REMDEV, ZGK_ATFIXO, ZGK_CFORIG"})
    Local oStruGRID := FWFormStruct(2, "ZGK", {|cCampo| AllTRim(cCampo) $ "ZGK_CFOP, ZGK_ITEM, ZGK_USER, ZGK_NOMEU, ZGK_PERMNF, ZGK_PROD"})
 
    oStruCab:RemoveField("ZGK_ITEM")
    	
    //Define que o cabeçalho não terá abas
    oStruCab:SetNoFolder()

    oStruGRID:RemoveField("ZGK_CFOP")
    

    //Cria o View
    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
 
    //Cria uma área de Field vinculando a estrutura do cabeçalho com MDFieldZGK, e uma Grid vinculando com MdGridZGK
    oView:AddField('VIEW_ZGK', oStruCab, 'MdFieldZGK')
    oView:AddGrid ('GRID_ZGK', oStruGRID, 'MdGridZGK' )
 
    //O cabeçalho (MAIN) terá 25% de tamanho, e o restante de 75% irá para a GRID
    oView:CreateHorizontalBox("MAIN", 40)
    oView:CreateHorizontalBox("GRID", 60)
 
    //Vincula o MAIN com a VIEW_ZGK e a GRID com a GRID_ZGK
    oView:SetOwnerView('VIEW_ZGK', 'MAIN')
    oView:SetOwnerView('GRID_ZGK', 'GRID')
    oView:EnableControlBar(.T.)
 
    //Define o campo incremental da grid como o ZGK_ITEM
    oView:AddIncrementField('GRID_ZGK', 'ZGK_ITEM')
Return oView
 
//Função chamada para montar o modelo de dados da Grid
Static Function fModStruct()
    Local oStruct
    oStruct := FWFormStruct(1, 'ZGK')
Return oStruct
 
//Função chamada para montar a visualização de dados da Grid
Static Function fViewStruct()
    Local oStruct
 
    oStruct := FWFormStruct(2, "ZGK", {|cCampo| AllTRim(cCampo) $ "ZGK_CFOP, ZGK_ITEM, ZGK_USER, ZGK_NOMEU, ZGK_PERMNF"})
Return oStruct
 
//Função que faz a validação da grid
Static Function fValidGrid(oModel)

Local _lRet     := .T.
Local _cZGKNum :=  FwFldGet("ZGK_CFOP",1,oModel)
Local _cZGKItem :=  FwFldGet("ZGK_ITEM",1,oModel)   





Return _lRet

static function fCommit(oModel)
Local lRet := .T.

FWFormCommit( oModel )

Return lRet

User Function zZGKitem()

Local _cItem := "0001"

Return _cItem



Static Function AVLVZGKALT()

//Local _oModel := FwModelActive()
//Local _cItem := _oModel:GetValue('MdGridZGK','ZGK_ITEM')
//Local _cCodigo := _oModel:GetValue('MdGridZGK','ZGK_CODIGO')
//Local _cAlias := GetNextAlias()
Local _lRet := .T.



Return _lRet



User Function ACZGHACES(_cCF, _cZGK_PROD)

Local _cCfop := ''
Local _cAlias := ''
Local _lRet := .T.

Default _cCF = ''
Default _cZGK_PROD := ''

_cCfop := '%'+ValToSql(_cCF)+'%'
_cProdGrp := '%'+ValToSql(_cZGK_PROD)+'%'

If Empty(_cCF)
    Return _lRet
EndIf

_cAlias := GetNextAlias()

BeginSql alias _cAlias 
    %noparser%
    SELECT * 
    FROM 	%table:ZGK% ZGK WITH(NOLOCK) 
    WHERE 		ZGK.D_E_L_E_T_ = ''
            AND ZGK.ZGK_FILIAL = ''
            AND ZGK.ZGK_CFOP = %exp:_cCfop%
            AND ( %exp:_cProdGrp% = '' OR ZGK.ZGK_PROD = '' OR ZGK.ZGK_PROD = %exp:_cProdGrp%   )
            AND ZGK.ZGK_PERMNF = 'S'
EndSql

If (_cAlias)->(!Eof())
    _lRet := .F.
    While (_cAlias)->(!eof())
        If (_cAlias)->ZGK_USER == __cUserId .OR. __cUserId == '000131' .OR. FwIsAdmin()
            _lRet := .T.
            Exit
        EndIf
    (_cAlias)->(DbSkip())
    EndDo
EndIf

(_cAlias)->(DbCloseArea())

If !_lRet
    Aviso("ATENÇÃO!", "O CFOP "+_cCF+" é de utilização restrita dos usuário do setor de Patrimônio. ";
    +CHAR(13)+CHAR(10)+"Solicite autorização para seu usuário ou solicite que outro usuário realize a inclusão do documento fiscal.",;
    {"SAIR"})
EndIf

Return _lRet
