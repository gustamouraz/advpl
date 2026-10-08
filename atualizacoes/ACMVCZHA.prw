#Include "Totvs.ch"
#include "rwmake.ch"
#INCLUDE 'FWMVCDef.ch'
#include 'PROTHEUS.CH'
#Include 'topconn.ch'

/* AL�ADAS CAPEX - DEZ 2025
@Autor:         Andr� Claro
@Data:          26/01/2025
@Descri��o:     Aprovadores de Capex
*/
Static cTitulo := "Monitor de Importa��o NFe Combustiveis"

User Function ACMVCZHA() 

    Local aArea   := GetArea()
    Local oBrowse

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZHA")
    oBrowse:SetDescription(cTitulo)
 
    oBrowse:AddLegend( "ZHA_INTEGR == 'P' " , "RED",              "Problemas" )
    oBrowse:AddLegend( "ZHA_INTEGR == 'N' " , "YELLOW",              "Pendente Integ. NF" )
    oBrowse:AddLegend( "ZHA_INTEGR == 'S' " , "GREEN",              "NF Integrada" )
    
    DbSelectArea("ZHC")

    oBrowse:Activate()

    RestArea(aArea)

Return 


Static Function MenuDef()
    Local aRot := {}
      
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ACMVCZHA' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    //ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.ACMVCZHA' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.ACMVCZHA' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	//ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.ACMVCZHA' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE 'Integra API'    ACTION 'U_INTX7' OPERATION 3 ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE 'Proc. Entrada NFe'    ACTION 'U_ACZHANFE' OPERATION 3 ACCESS 0 //OPERATION 5

    

Return aRot
 
Static Function ModelDef()
    Local oModel      := NIL
    Local oStruCab    := FWFormStruct(1, 'ZHA'  )
    Local oStruGrid   := FWFormStruct(1, 'ZHB'  )

    oModel := MPFormModel():New('CADZHAM', {|| AVLVZHAALT() }, {|oModel| ACTUDOOK(oModel)},  {|oModel| fCommit(oModel) } , /*bCancel*/ )

    //Agora, define no modelo de dados, que terá um Cabeçalho e uma Grid apontando para estruturas acima
    oModel:AddFields('MdFieldZHA', NIL, oStruCab)
    oModel:AddGrid('MdGridZHA', 'MdFieldZHA', oStruGrid, , )
 
    //Monta o relacionamento entre Grid e Cabeçalho, as expressões da Esquerda representam o campo da Grid e da direita do Cabeçalho
    oModel:SetRelation('MdGridZHA', {;
            {'ZHB_FILIAL', 'ZHA_FILIAL'},;
            {'ZHB_NUMSEQ', 'ZHA_NUMSEQ'};
        }, ZHB->(IndexKey(1))) //ZHB_FILIAL+ZHB_NUMSEQ + ZHB_ITEM

    //Definindo outras informações do Modelo e da Grid
    oModel:GetModel("MdGridZHA"):SetMaxLine(999)
    oModel:SetDescription("API Combust�veis")
    
    oModel:SetPrimaryKey({"ZHA_FILIAL","ZHA_NUMSEQ","ZHB_ITEM"})
 
Return oModel
 
Static Function ViewDef()
    //Na montagem da estrutura da visualização de dados, vamos chamar o modelo criado anteriormente, no cabeçalho vamos mostrar somente 3 campos, e na grid vamos carregar conforme a função fViewStruct
    Local oView        := NIL
    Local oModel    := FWLoadModel('ACMVCZHA')
    Local oStruCab  := FWFormStruct(2, "ZHA")
    Local oStruGRID := FWFormStruct(2, "ZHB")
 
    oStruCab:SetNoFolder()
    oStruCab:RemoveField("ZHA_FILIAL")

    oStruGRID:RemoveField("ZHA_FILIAL")
    oStruGRID:RemoveField("ZHA_NUMSEQ")

    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
 
    oView:AddField('VIEW_ZHA', oStruCab, 'MdFieldZHA')
    oView:AddGrid ('GRID_ZHA', oStruGRID, 'MdGridZHA' )
    oView:CreateHorizontalBox("MAIN", 40)
    oView:CreateHorizontalBox("GRID", 60)
    oView:SetOwnerView('VIEW_ZHA', 'MAIN')
    oView:SetOwnerView('GRID_ZHA', 'GRID')
    oView:EnableControlBar(.T.)
     oView:AddIncrementField('GRID_ZHA', 'ZHA_ITEM')

    oView:SetAfterViewActivate({|oView| _IniCpos(oView)} ) 
Return oView
 
//Função chamada para montar o modelo de dados da Grid
Static Function fModStruct()
    Local oStruct
    oStruct := FWFormStruct(1, 'ZHA')
Return oStruct
 
//Função chamada para montar a visualização de dados da Grid
Static Function fViewStruct()
    Local oStruct
 
    oStruct := FWFormStruct(2, "ZHA")
Return oStruct

Static Function ACTUDOOK(oModelGrid)
Local _lRet		:= .T.
Local oModel	:= FWModelActive()
Local oGridZHA	:= oModel:GetModel("MdGridZHA")
Local _nI        	:= 0
Local _aSaveLines:= FWSaveRows()

For _nI := 1 To  oGridZHA:Length()
    
Next _nI
 
 FWRestRows( _aSaveLines )

 Return _lRet

static function fCommit(oModel)
Local lRet := .T.
    FWFormCommit( oModel )
Return lRet


Static Function AVLVZHAALT()
Local _lRet := .T.
Return _lRet

Static Function _IniCpos(oView)

Local nOperation := oView:GetOperation() 
Local oModel := FWModelActive() 
Local oModelZHA := oModel:GetModel("MdFieldZHA")//MdGridZGQ

If nOperation == 3
    oModelZHA:LoadValue("ZHA_FILIAL" , xFilial("ZHA") )
    oView:Refresh()
EndIf

Return



User Function ACZHANFE()

	oProcess := MsNewProcess():New({  || ACEXECUTE(@oProcess)},"Integrando NFe...","Aguarde por favor!!!",.T.)
	oProcess:Activate()

Return 

Static Function ACEXECUTE(oProcess)
Local _cErro := ""
Local _cDetalhe := ""
Local _nRecno := ZHA->(RECNO())

    If U_ACAUTZHA(ZHA->ZHA_NUMSEQ, @_cErro)
        If  ZHA->(RecLock("ZHA",.F.))
                ZHA->ZHA_INTEGR := "S"
            ZHA->(MsUnLock())
        EndIf
    Else
        _cDetalhe := Alltrim(ZHA->ZHA_DETERR)
        _cDetalhe := CRLF + DtoC(Date()) + " " + Time()+" " + Alltrim(_cErro)

        ZHA->(DbGoTo( _nRecno  ))
        If ZHA->(RECNO()) == _nRecno
            If  ZHA->(RecLock("ZHA",.F.))
                    ZHA->ZHA_DETERR := _cDetalhe
                    ZHA->ZHA_INTEGR := "P"
                ZHA->(MsUnLock())
            EndIf
        Endif
    EndIf

Return 
