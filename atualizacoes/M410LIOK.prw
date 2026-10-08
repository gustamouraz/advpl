#INCLUDE "TOTVS.CH"
#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function nomeFunction
    Validação de linha de pedido de vendas
    @type  Function
    @author Willian Kaneta
    @since 06/08/2021
    @version 1.0
    /*/
User Function M410LIOK()
	Local lRet        := .T.  
	Local nPosCFOP    := aScan(aHeader,{|x| Alltrim(x[2]) == 'C6_CF' })
	Local nPosArma    := aScan(aHeader,{|x| Alltrim(x[2]) == 'C6_LOCAL' })
    Local nPosTes     := aScan(aHeader,{|x| Alltrim(x[2]) == 'C6_TES' })
    Local nPosProd    := AScan(aHeader, {|x| AllTrim(x[2]) == "C6_PRODUTO"} ) 
    Local nPosLote    := AScan(aHeader, {|x| AllTrim(x[2]) == "C6_LOTECTL"} )
    Local nPosNFRem   := AScan(aHeader, {|x| AllTrim(x[2]) == "C6_XNFREM"} ) 
    Local nPosSerRem  := AScan(aHeader, {|x| AllTrim(x[2]) == "C6_XSERREM"} )
    Local nPosItemRem := AScan(aHeader, {|x| AllTrim(x[2]) == "C6_XITMREM"} )
    Local nPosQuant   := AScan(aHeader, {|x| AllTrim(x[2]) == "C6_QTDVEN"} )
    Local lVldNFRem   := SuperGetMV("MV_XWNFREM",.F.,.T.) //

   	Local cLocEst	  := SUPERGETMV("MV_XLOPRAG",.F.,"") // Paramêtro que define o local de estoque utilizado para compra e venda de produção agrícola de terceiros - ADD - Willian Kaneta
    Local cCFPOAGR	  := SUPERGETMV("MV_XCFVENA",.F.,"") // Paramêtro que define os CFOPs liberados para inclusão no armázen 88 -  compra e venda de produção agrícola de terceiros - ADD - Willian Kaneta
    Local lEnable   := SuperGetMV("MV_X410LOK",.F.,.T.)     //Parâmetro para ativar e desativar a validação de Lote
    Local lPrdTes   := SuperGetMV("MV_Z410LOK",.F.,.T.)     //Parâmetro para ativar e desativar a validação TES 622 / Produto 7030000006|7030000009

   	Local _MV_ZCMXCFO	  := SUPERGETMV("MV_ZCMXCFO",.F.,"") // CFOPS que irão preencher o CNPJ de Acesso XML automático.//"5501|6501|5502|6502|7504"
    Local _MV_ZCMXCGC	  := SUPERGETMV("MV_ZCMXCGC",.F.,"") // CNPJ para ser preenchido automático quando o cfop estiver contido no parametro _MV_ZCMXCFO //04055601000233

    Local nC        := 1
    Local nZ        := 1
    Local cRastro   := ""
    Local cEstoque  := ""
    Local _nX := 0 
    Local _nPosDel := Len(aHeader)+1

    Local lCnNt      := SuperGetMV("MV_ZLCNNT",.F.,.T.)     //Parâmetro para ativar e desativar a validação
    Local cFilCnNt   := '010103|010104|010105|010106|010107|010111|010112|010113|010114|010115|010116|030106|300101|300102|040101|400105|120102|130101|310101|320101|330101'
    Local cPrdCnNt   := '0000006430|0000006431|0000018924|0000018925|5030000002|5030000003|5030000004|5030000005|5030000006|5030000007|5030000008|5030000009|5030000010|5030000011|5050000005|5050000006|5050000008|5060000001|6020000026|6020000046|6020000052|5030000013'

    // validação solicitada no ticket 7321
    If lPrdTes
        For nZ := 1 To Len(aCols) 
            If aCols[nZ][nPosProd] $ "7030000009|7030000006" .AND. aCols[nZ][nPosTes] != "622"    
                MsgAlert("Para o produto "+aCols[nZ][nPosProd]+" é necessário informar a TES 622!","M410LIOK")
                lRet := .F.
            ElseIf aCols[nZ][nPosProd] != "7030000009" .AND. aCols[nZ][nPosProd] != "7030000006" .AND. aCols[nZ][nPosTes] = "622"
                MsgAlert("Para a TES "+aCols[nZ][nPosTes]+" é necessário informar o produto 7030000009 ou 7030000006!","M410LIOK")
                lRet := .F.
            EndIf
        Next nZ
    EndIf

    // validação solicitada no ticket 20239 - Luiz Moura - 04/08/2026
    If lCnNt
        For nZ := 1 To Len(aCols) 
            If cFilAnt $ cFilCnNt .AND. aCols[nZ][nPosTes] != "550" .AND. aCols[nZ][nPosTes] != "560" .AND. aCols[nZ][nPosProd] $ cPrdCnNt;
                .AND. !(AllTrim(aCols[nZ][nPosCFOP]) $ "5501|6501|5905|5906|5504|5551|5901|5124|5902|5910|000") .AND. SA1->A1_PESSOA = "J" .AND. SA1->A1_EST = "RO"

                FWAlertWarning("Venda dos produtos bovino, milho, soja e café para uma PJ situada em RO, utilize as TES 550 ou 560","M410LIOK")
                lRet := .F.

            EndIf
        Next nZ
    EndIf
    /*                      INICIO TICKET 3979-DEZ/24
    @Autor:       André Claro - Cel/Whats: 35 998775495 - Email: andre.claro@acclaro.com.br
    @Data:        03/12/2024
    @Descrição:   Ticket 3979 - Preencher o campo Acesso XML de forma automática no pedido de vendas,
                    quando utilizar CFOPs específicos.
                    Foram criados os parametros:
                    MV_ZCMXCFO - informar os CFOPs
                    MV_ZCMXCGC - informar o CNPJ
    */
    If !Empty(_MV_ZCMXCFO) .and. !Empty(_MV_ZCMXCGC) .and. Alltrim(M->C5_ZCGC) <> Alltrim(_MV_ZCMXCGC)
        For _nX := 1 to Len(aCols)
            If !aCols[_nX][_nPosDel]
                If Alltrim(aCols[_nX,nPosCFOP]) $ _MV_ZCMXCFO
                    M->C5_ZCGC := _MV_ZCMXCGC
                    Exit
                EndIf
            EndIf
        Next _nX
    EndIf
    /*                       FIM TICKET 3979-DEZ/24  */


     If lEnable 
         If !(aCols[n,nPosCFOP] $ cCFPOAGR) .AND. Alltrim(aCols[n,nPosArma]) == Alltrim(cLocEst)
            MsgAlert("Não é permido utilizar o Armazén "+Alltrim(cLocEst)+" - Compra e venda de produção agrícola de terceiros para o CFOP informado!!!","[M410LIOK]CFOP x ARMAZÉM")
            lRet := .F.
        EndIf

        If lRet .and. SuperGetMv("MV_ZVLCFNF",.F.,.T.)
            If !(IsInCallStack("MATA310") .OR. IsInCallStack("MATA311"))
                /*Validação quanto a acesso ao CFOP*/
                lRet := U_ACZGHACES(aCols[N][nPosCFOP] )
            EndIf
        EndIf

        If lRet
            For nC := 1 To Len(aCols) 

                cRastro := Posicione("SB1",1,xFilial("SB1")+AllTrim(aCols[nC][nPosProd]),"B1_RASTRO")
                cEstoque := Posicione("SF4",1,xFilial("SF4")+AllTrim(aCols[nC][nPosTes]),"F4_ESTOQUE") //F4_FILIAL, F4_CODIGO, R_E_C_N_O_, D_E_L_E_T_

                If  cRastro == "L" .And. cEstoque == "S"
                    lRet := IIF(Empty(aCols[nC][nPosLote]),.F.,.T.)
                    If !lRet
                        MessageBox("Produto " + aCols[nC][nPosProd] + " precisa que seja informado um LOTE!","[M410LIOK] Validação de Lote", 0)
                        Exit
                    EndIf
                EndIf
            Next nC
        EndIf
    EndIf 

    If lVldNFRem
        If lRet
            lRet := U_WNFREMVLD(M->C5_XCREMEX,M->C5_XCLIEX, aCols[n][nPosNFRem], aCols[n][nPosSerRem], aCols[n][nPosItemRem], aCols[n][nPosQuant] )
        EndIf
    EndIf

Return lRet
