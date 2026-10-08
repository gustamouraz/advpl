#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
   
User Function EXEC140I()
   
Local nOpc := 3
   
    Private aCabec      := {}
    Private aItens      := {}
    Private aLinha      := {}
    Private lMsErroAuto := .F.
   
    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" MODULO "COM" TABLES "SF1","SD1" USER "SEU_USUARIO" PASSWORD "SUA_SENHA"
   
    aAdd(aCabec,{'F1_FILIAL','060101',NIL})
    aAdd(aCabec,{'F1_TIPO','N',NIL})
    aAdd(aCabec,{'F1_FORMUL','N',NIL})
    aAdd(aCabec,{'F1_DOC','INC000001',NIL})
    aAdd(aCabec,{"F1_SERIE","25",NIL})
    aAdd(aCabec,{"F1_EMISSAO",dDataBase,NIL})
    aAdd(aCabec,{'F1_FORNECE','000070',NIL})
    aAdd(aCabec,{'F1_LOJA','2',NIL})
    aAdd(aCabec,{"F1_ESPECIE","NFS",NIL})
    aAdd(aCabec,{"F1_STATUS",'',NIL})
    aAdd(aCabec,{"F1_ORIGEM",'EXEC140I',NIL})
        
    // aAdd(aItens,{'D1_FILIAL','060101',NIL})
    // aAdd(aItens,{'D1_DOC','INC000001',NIL})
    aAdd(aItens,{'D1_ITEM',StrZero(1,4),NIL})
    aAdd(aItens,{'D1_CC','2606',NIL})
    aAdd(aItens,{'D1_COD',"4330010657",NIL})
    aAdd(aItens,{"D1_PEDIDO","098665",Nil})
    aAdd(aItens,{"D1_QUANT",1,Nil})
    aAdd(aItens,{"D1_VUNIT",1293.47,Nil})
    aAdd(aItens,{"D1_TOTAL",1293.47,Nil})
    // aAdd(aItens,{"D1_TES",'',NIL})
        
    aAdd(aLinha,aItens)
        
    MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)}, aCabec, aLinha, nOpc,,)
        
    If lMsErroAuto
        mostraerro()
    Else
        Alert("Execauto MATA140 de inclusão executado com sucesso!")
    EndIf
    
    RESET ENVIRONMENT
    
Return
