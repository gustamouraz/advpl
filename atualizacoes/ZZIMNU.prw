#include "REPORT.CH"
#include "PROTHEUS.CH"    
#include "TOPCONN.CH"    
#Include 'FWMVCDef.ch'

  User Function ZZIMNU()
      Local aArea  := FWGetArea()
      Local cFilPC := SC7->C7_FILIAL
      Local cNumPC := SC7->C7_NUM
      Local oModel := Nil

      DbSelectArea("ZZI")
      ZZI->(DbSetOrder(1))

      If ZZI->(DbSeek(cFilPC + cNumPC))
          FWExecView("", "VIEWDEF.LMFCOM02", MODEL_OPERATION_UPDATE, , {|| .T. })
      Else
          oModel := FWLoadModel("LMFCOM02")
          oModel:SetOperation(MODEL_OPERATION_INSERT)
          oModel:Activate()

          oModel:SetValue("FORMZZI", "ZZI_FILIAL", cFilPC)
          oModel:SetValue("FORMZZI", "ZZI_NUMPC" , cNumPC)

          FWExecView("", "VIEWDEF.LMFCOM02", MODEL_OPERATION_INSERT, , {|| .T. }, , , , , , , oModel)

          oModel:DeActivate()
          oModel:Destroy()
      EndIf

      FWRestArea(aArea)
  Return Nil
