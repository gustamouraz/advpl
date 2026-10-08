#include 'totvs.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"

static oAlinHor := FwXlsxCellAlignment():Horizontal()
static oAlinVer := FwXlsxCellAlignment():Vertical()

/*
@Autor:    AndrÈ Claro / 35 99877-5495 / andre.claro@acclaro.com.br
@Data:     12/04/2026
@DescriÁao: RelatÛrio que lista os CTeS de balsa.
*/

User Function ACRCTEXCEL(_aFiliais, _aLocais, _aGrupos)	
Local oProcess := Nil
Local _cPerg := "ACRCTEXCEL"
Local _cFolder := ""

_cFolder := ACSELFOLD()

While Empty(_cFolder)
	_cFolder := ACSELFOLD()
	If Empty(_cFolder)
		If Aviso("ATEN«√O","Nao foi selecionada uma pasta valida! Deseja selecionar novamente? ",{"Sim","N√o"},2) == 2 
			Return 
		EndIf
	EndIf
EndDo


If !Pergunte(_cPerg,.T.)
    Return
EndIf

MAKEDIR( _cFolder )

oProcess := MsNewProcess():New({  || ACSINTET(@oProcess, _cFolder)},"Imprimindo relatÛrio...","Aguarde por favor!!!",.T.)
oProcess:Activate()

shellExecute("Open", "explorer", _cFolder, "C:\", 1 )
MsgInfo('Arquivos gerados com sucesso: '+_cFolder,"Sucesso")

Return

Static Function ACSINTET(oProcess, _cFolder)

Local _cAlias := ''
Local _cQuery := " "

_cQuery += " SELECT	DTX_MANIFE+' '+RIGHT('000'+RTRIM(CAST(ROW_NUMBER() OVER(PARTITION BY SUBSTRING(DTX_DATMAN,1,4) ORDER BY DTX_VIAGEM, DTX_DATMAN ) AS CHAR(3) )),3)+ ' ' + SUBSTRING(DTX_DATMAN,3,2) AS COLUNA1,  "+ CRLF
_cQuery += " 		M0_CGC, DTC_CODPRO,   "+ CRLF
_cQuery += " 		DTX_QTDCTE,   "+ CRLF
_cQuery += " 		DTX_DATMAN,   "+ CRLF
_cQuery += " 		DTX_MANIFE, DTX_VIAGEM, DTX_HORMAN, DTX_FILORI, DTX_FILDCA,   "+ CRLF
_cQuery += " 		DTW_DATPRE, ZB2_DPORTO, A1_NOME, NAV_IRIN  "+ CRLF
_cQuery += " FROM  "+ CRLF
_cQuery += " (SELECT 	DTX.DTX_VIAGEM, SM0.M0_CGC, DTC_CODPRO, DTX_QTDCTE, DTX_DATMAN, DTW_DATPRE, ZB2_DPORTO, A1_NOME, DTX_MANIFE,DTX_HORMAN, DTX_FILORI, DTX_FILDCA,   "+ CRLF
_cQuery += " 		TRIM(DTQ.DTQ_ZIRIN) + '-'+ (CASE DTQ.DTQ_ZCODEM WHEN 1 THEN 'GERMANO LAZZARETTI' WHEN 2 THEN 'RICIERI MASUTTI' WHEN 3 THEN 'VALDIR MASUTTI II' WHEN 4 THEN 'VOLNEI MASUTTI' END) AS NAV_IRIN  "+ CRLF
_cQuery += " FROM 		DTX010 DTX WITH(NOLOCK) ---MANIFESTO  "+ CRLF
_cQuery += " 			INNER JOIN DL2010 DL2 WITH(NOLOCK) ON ---DOCUMENTOS DO MANIFESTO  "+ CRLF
_cQuery += " 		    DL2.D_E_L_E_T_ = ''   "+ CRLF
_cQuery += " 		AND DTX.DTX_FILIAL = DL2.DL2_FILIAL  "+ CRLF
_cQuery += " 		AND DTX.DTX_FILORI = DL2.DL2_FILORI  "+ CRLF
_cQuery += " 		AND DTX.DTX_MANIFE = DL2.DL2_MANIFE  "+ CRLF
_cQuery += " 		AND DTX.DTX_VIAGEM = DL2.DL2_VIAGEM  "+ CRLF
_cQuery += " 			INNER JOIN DT6010 DT6 WITH(NOLOCK) ON ---CTE  "+ CRLF
_cQuery += " 		    DT6.D_E_L_E_T_ = ''  "+ CRLF
_cQuery += "     	AND DL2.DL2_FILIAL = DT6.DT6_FILIAL  "+ CRLF
_cQuery += "     	AND DL2.DL2_FILORI = DT6.DT6_FILORI  "+ CRLF
_cQuery += "     	AND DL2.DL2_DOC = DT6.DT6_DOC  "+ CRLF
_cQuery += " 			INNER JOIN DTC010 DTC WITH(NOLOCK) ON ---CTE  "+ CRLF
_cQuery += "     		DTC.D_E_L_E_T_ = ''  "+ CRLF
_cQuery += "     	AND DTC.DTC_FILIAL = DT6.DT6_FILIAL  "+ CRLF
_cQuery += "     	AND DTC.DTC_FILORI = DT6.DT6_FILORI  "+ CRLF
_cQuery += "     	AND DTC.DTC_DOC = DT6.DT6_DOC  "+ CRLF
_cQuery += " 			INNER JOIN DTQ010 DTQ WITH(NOLOCK) ON ---VIAGEM  "+ CRLF
_cQuery += "     		DTQ.D_E_L_E_T_ = ''  "+ CRLF
_cQuery += "     	AND DTQ.DTQ_FILIAL = DTX.DTX_FILIAL  "+ CRLF
_cQuery += "     	AND DTQ.DTQ_FILORI = DTX.DTX_FILORI  "+ CRLF
_cQuery += "     	AND DTQ.DTQ_VIAGEM = DTX.DTX_VIAGEM  "+ CRLF
_cQuery += " 			LEFT JOIN DTW010 DTW WITH(NOLOCK) ON ---OPERA«’ES DA VIAGEM  "+ CRLF
_cQuery += "     		DTW.D_E_L_E_T_ = ''   "+ CRLF
_cQuery += "     	AND DTX.DTX_FILIAL = DTW.DTW_FILIAL   "+ CRLF
_cQuery += "     	AND DTX.DTX_VIAGEM = DTW.DTW_VIAGEM  "+ CRLF
_cQuery += "     	AND DTW.DTW_ATIVID = '050'  "+ CRLF
_cQuery += " 			LEFT JOIN ZB3010 ZB3 WITH(NOLOCK) ON ---BALSAS  "+ CRLF
_cQuery += "     		ZB3.D_E_L_E_T_ = ''  "+ CRLF
_cQuery += "     	AND DTC.DTC_ZBALSA = ZB3.ZB3_CBALSA   "+ CRLF
_cQuery += " 			LEFT JOIN ZB2010 ZB2 WITH(NOLOCK) ON ---PORTOS  "+ CRLF
_cQuery += "     		ZB2.D_E_L_E_T_ = ''  "+ CRLF
_cQuery += "     	AND DTC.DTC_ZPORTO = ZB2.ZB2_CODPOR  "+ CRLF
_cQuery += " 			LEFT JOIN SYS_COMPANY SM0 WITH(NOLOCK) ON ---FILIAL  "+ CRLF
_cQuery += "     		SM0.D_E_L_E_T_ = ''  "+ CRLF
_cQuery += "     	AND DTX.DTX_FILMAN = SM0.M0_CODFIL  "+ CRLF
_cQuery += " 			LEFT JOIN SA1010 SA1 WITH(NOLOCK) ON ---RECEBEDOR  "+ CRLF
_cQuery += "     		SA1.D_E_L_E_T_ = ''  "+ CRLF
_cQuery += "     	AND DTC.DTC_CLIREC = SA1.A1_COD  "+ CRLF
_cQuery += "     	AND DTC.DTC_LOJREC = SA1.A1_LOJA  "+ CRLF
_cQuery += " 			LEFT JOIN SB1010 SB1 WITH(NOLOCK) ON ---PRODUTO  "+ CRLF
_cQuery += "     		SB1.D_E_L_E_T_ = ''  "+ CRLF
_cQuery += "     	AND DTC.DTC_CODPRO = SB1.B1_COD  "+ CRLF
_cQuery += " WHERE 		DTC_ZAQUAV = '1'  "+ CRLF
_cQuery += " 	    AND DTX.D_E_L_E_T_ = ''  "+ CRLF
_cQuery += " 		AND DTX_DATMAN BETWEEN  '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'    "+CRLF
_cQuery += " 		AND DTX_MANIFE  BETWEEN  '"+MV_PAR03+"' AND '"+MV_PAR04+"'    "+CRLF

_cQuery += " GROUP BY DTX.DTX_VIAGEM, SM0.M0_CGC, DTC_CODPRO,DTX_QTDCTE, DTX_DATMAN, DTW_DATPRE, ZB2_DPORTO, ZB2_DPORTO,	A1_NOME, DTX_MANIFE,  "+ CRLF
_cQuery += " 			DTX_HORMAN, DTX_FILORI, DTX_FILDCA,   "+ CRLF
_cQuery += " 		TRIM(DTQ.DTQ_ZIRIN) + '-'+ (CASE DTQ.DTQ_ZCODEM WHEN 1 THEN 'GERMANO LAZZARETTI' WHEN 2 THEN 'RICIERI MASUTTI' WHEN 3 THEN 'VALDIR MASUTTI II' WHEN 4 THEN 'VOLNEI MASUTTI' END)   "+ CRLF
_cQuery += " ) AS BASE


_cAlias := GetNextAlias()
MpSysOpenQuery(_cQuery, _cAlias)
TcSetField(_cAlias,"DTW_DATPRE","D")
TcSetField(_cAlias,"DTX_DATMAN","D")
TcSetField(_cAlias,"DTX_DATIMP","D")

(_cAlias)->(DbGoTop())
_nCount := 0
While (_cAlias)->(!EOF())
    _nCount++
(_cAlias)->(DbSkip())
EndDo
oProcess:SetRegua1( 0 )
oProcess:SetRegua2(_nCount)
    
		(_cAlias)->(DbGoTop())
		_nAtu := 0
		If (_cAlias)->(!EOF())

			While (_cAlias)->(!EOF())
				_nAtu ++
				oProcess:IncRegua1( "Viagem "+(_cAlias)->DTX_VIAGEM )
				oProcess:IncRegua2("Processando ("+cValTochar(Round(_nAtu / _nCount*100,2))+"%) " )
                ZEXECREL(oProcess, (_cAlias)->COLUNA1, (_cAlias)->M0_CGC, (_cAlias)->DTC_CODPRO,;
                             (_cAlias)->DTX_QTDCTE, (_cAlias)->DTX_DATMAN, (_cAlias)->DTX_MANIFE,;
                              (_cAlias)->DTX_FILORI, (_cAlias)->DTX_FILDCA, (_cAlias)->DTW_DATPRE,;
                              (_cAlias)->DTX_VIAGEM, (_cAlias)->DTX_HORMAN, (_cAlias)->ZB2_DPORTO, (_cAlias)->A1_NOME, (_cAlias)->NAV_IRIN, _cFolder )
                (_cAlias)->(DbSkip())
            EndDo
        EndIf

Return 




Static Function ZEXECREL(oProcess, _cCOLUNA1, _cM0_CGC, _cDTC_CODPRO,_cDTX_QTDCTE, _dDTX_DATMAN, _cDTX_MANIFE,_cDTX_FILORI, _cDTX_FILDCA, _dDTW_DATPRE,_cDTX_VIAGEM, _cDTX_HORMAN, _cZB2_DPORTO, _cA1_NOME, _cNAV_IRIN, _cFolder)
Local _cAlias1 := ''
Local _nRow := 0

local oPrtXlsx as object
local cFilename as character
local lRet as logical
Local cFont := ""
Local nSize := 11
Local lItalic := .F.
Local lBold := .T.
Local lUnderlined := .F.
Local cColor := "000000" //Preta
Local _cNomArq := _cFolder+"\"+Alltrim(_cDTX_VIAGEM)+"-"+Alltrim(_cDTX_MANIFE)
Local cColorF := "FFFFFF" //Branco
Local _cCorAzul := "002060"
Local cStyle := FwXlsxBorderStyle():Thin() //Medium()
Local lTop := .T.
Local lBottom := .T.
Local lLeft:= .T.
Local lRight := .T.

Local _nCol1 := 4
Local _nCol2 := 5 

static oCellHorAlign := FwXlsxCellAlignment():Horizontal()
static oCellVertAlign := FwXlsxCellAlignment():Vertical()

cFilename := _cNomArq+'.rel'

ferase(cFilename)
oPrtXlsx := FwPrinterXlsx():New(.T.)
lRet := oPrtXlsx:Activate(cFilename)
lRet := oPrtXlsx:SetBorder(lLeft, lTop, lRight, lBottom, cStyle, cColor)
	

_cQuery := " "

_cQuery += " SELECT DISTINCT DTC_ZBALSA,ZB3_DBALSA	  "+ CRLF
_cQuery += " FROM DTX010 DTX WITH (NOLOCK) ---MANIFESTO  "+ CRLF
_cQuery += " INNER JOIN DL2010 DL2 WITH (NOLOCK) ON ---DOCUMENTOS DO MANIFESTO  "+ CRLF
_cQuery += " 	DL2.D_E_L_E_T_ = ''  "+ CRLF
_cQuery += " 	AND DTX.DTX_FILIAL = DL2.DL2_FILIAL  "+ CRLF
_cQuery += " 	AND DTX.DTX_FILORI = DL2.DL2_FILORI  "+ CRLF
_cQuery += " 	AND DTX.DTX_MANIFE = DL2.DL2_MANIFE  "+ CRLF
_cQuery += " 	AND DTX.DTX_VIAGEM = DL2.DL2_VIAGEM  "+ CRLF
_cQuery += " INNER JOIN DT6010 DT6 WITH (NOLOCK) ON ---CTE  "+ CRLF
_cQuery += " 	DT6.D_E_L_E_T_ = ''  "+ CRLF
_cQuery += " 	AND DL2.DL2_FILIAL = DT6.DT6_FILIAL  "+ CRLF
_cQuery += " 	AND DL2.DL2_FILORI = DT6.DT6_FILORI  "+ CRLF
_cQuery += " 	AND DL2.DL2_DOC = DT6.DT6_DOC  "+ CRLF
_cQuery += " INNER JOIN DTC010 DTC WITH (NOLOCK) ON ---CTE  "+ CRLF
_cQuery += " 	DTC.D_E_L_E_T_ = ''  "+ CRLF
_cQuery += " 	AND DTC.DTC_FILIAL = DT6.DT6_FILIAL  "+ CRLF
_cQuery += " 	AND DTC.DTC_FILORI = DT6.DT6_FILORI  "+ CRLF
_cQuery += " 	AND DTC.DTC_DOC = DT6.DT6_DOC  "+ CRLF
_cQuery += " LEFT JOIN DTW010 DTW WITH (NOLOCK) ON ---OPERA«’ES DA VIAGEM  "+ CRLF
_cQuery += " 	DTW.D_E_L_E_T_ = ''  "+ CRLF
_cQuery += " 	AND DTX.DTX_FILIAL = DTW.DTW_FILIAL  "+ CRLF
_cQuery += " 	AND DTX.DTX_VIAGEM = DTW.DTW_VIAGEM  "+ CRLF
_cQuery += " 	AND DTW.DTW_ATIVID = '050'  "+ CRLF
_cQuery += " LEFT JOIN ZB3010 ZB3 WITH (NOLOCK) ON ---BALSAS  "+ CRLF
_cQuery += " 	ZB3.D_E_L_E_T_ = ''  "+ CRLF
_cQuery += " 	AND DTC.DTC_ZBALSA = ZB3.ZB3_CBALSA  "+ CRLF
_cQuery += " LEFT JOIN ZB2010 ZB2 WITH (NOLOCK) ON ---PORTOS  "+ CRLF
_cQuery += " 	ZB2.D_E_L_E_T_ = ''  "+ CRLF
_cQuery += " 	AND DTC.DTC_ZPORTO = ZB2.ZB2_CODPOR  "+ CRLF
_cQuery += " LEFT JOIN SYS_COMPANY SM0 WITH (NOLOCK) ON ---FILIAL  "+ CRLF
_cQuery += " 	SM0.D_E_L_E_T_ = ''  "+ CRLF
_cQuery += " 	AND DTX.DTX_FILMAN = SM0.M0_CODFIL  "+ CRLF
_cQuery += " LEFT JOIN SA1010 SA1 WITH (NOLOCK) ON ---RECEBEDOR  "+ CRLF
_cQuery += " 	SA1.D_E_L_E_T_ = ''  "+ CRLF
_cQuery += " 	AND DTC.DTC_CLIREC = SA1.A1_COD  "+ CRLF
_cQuery += " 	AND DTC.DTC_LOJREC = SA1.A1_LOJA  "+ CRLF
_cQuery += " LEFT JOIN SB1010 SB1 WITH (NOLOCK) ON ---PRODUTO  "+ CRLF
_cQuery += " 	SB1.D_E_L_E_T_ = ''  "+ CRLF
_cQuery += " 	AND DTC.DTC_CODPRO = SB1.B1_COD  "+ CRLF
_cQuery += " WHERE 		DTC_ZAQUAV = '1'   "+CRLF
_cQuery += " 	    AND DTX.D_E_L_E_T_ = ''   "+CRLF
_cQuery += "        AND DTX_MANIFE = '"+_cDTX_MANIFE+"'  " +CRLF 
_cQuery += "        AND DTX_VIAGEM = '"+ _cDTX_VIAGEM +"' "  +CRLF 
_cQuery += "        AND DTX_DATMAN = '"+DtOs(_dDTX_DATMAN)+"'"   +CRLF 
_cQuery += "        AND DTX_HORMAN = '"+ _cDTX_HORMAN +"' "   +CRLF 
_cQuery += "        AND DTX_FILORI = '"+_cDTX_FILORI+"'   "   +CRLF 
_cQuery += "        AND DTX_FILDCA = '"+_cDTX_FILDCA+"'  "   +CRLF 
_cQuery += "        AND DTW_DATPRE = '"+dToS(_dDTW_DATPRE)+"' "   +CRLF 


_cAlias1 := GetNextAlias()
MpSysOpenQuery(_cQuery, _cAlias1)
TcSetField(_cAlias1,"DTW_DATPRE","D")
TcSetField(_cAlias1,"DTX_DATMAN","D")
TcSetField(_cAlias1,"DTX_DATIMP","D")

(_cAlias1)->(DbGoTop())
_nCount := 0
While (_cAlias1)->(!EOF())
    _nCount++
(_cAlias1)->(DbSkip())
EndDo
oProcess:SetRegua1( 0 )
oProcess:SetRegua2(_nCount)
    
    lRet := oPrtXlsx:AddSheet("V"+_cDTX_VIAGEM+"_M"+_cDTX_MANIFE)
    
        cHorAlignment := oCellHorAlign:LEFT()
        cVertAlignment := oCellVertAlign:Center()
        lWrapText := .F.
        nRotation := 0
        cCustomFormat := ""

		cFont := FwPrinterFont():Calibri()
		nSize := 20
		lItalic := .F.
		lBold := .T.
		lUnderlined := .F.
		lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)
		_nRow := 1

        lRet := oPrtXlsx:SetColumnsWidth(_nCol1, _nCol1, 70)
        lRet := oPrtXlsx:SetColumnsWidth(_nCol2, _nCol2, 70)

        cHorAlignment   := oCellHorAlign:Center()
        //Azul de Fundo e branco de cor
        lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, cColorF, _cCorAzul, cCustomFormat)	        

		cFont := FwPrinterFont():Calibri()
		nSize := 14
		lItalic := .F.
		lBold := .T.
		lUnderlined := .F.
		lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)

        _nRow := 1
        lRet := oPrtXlsx:MergeCells(_nRow, _nCol1 , _nRow , _nCol2) 
        lRet := oPrtXlsx:SetText(_nRow, _nCol1 , 'InformaÁıes para Envio')
        _nRow ++ 

        cHorAlignment   := oCellHorAlign:Left()
        lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, cColor, cColorF, cCustomFormat)	 

        lRet := oPrtXlsx:SetText(_nRow, _nCol1 , "N˙mero da viagem (Sequencial no Ano):")
        lRet := oPrtXlsx:SetText(_nRow, _nCol2 , _cCOLUNA1)

//_cCOLUNA1, _cM0_CGC, _cDTC_CODPRO,_cDTX_QTDCTE, _dDTX_DATMAN, _cDTX_MANIFE,_cDTX_FILORI, _cDTX_FILDCA, _dDTW_DATPRE,_cDTX_VIAGEM, _cDTX_HORMAN, _cZB2_DPORTO, _cA1_NOME, _cNAV_IRIN
        _nRow ++ 
        lRet := oPrtXlsx:SetText(_nRow, _nCol1 , "CNPJ da Empresa de NavegaÁ„o:" )
        lRet := oPrtXlsx:SetText(_nRow, _nCol2 , _cM0_CGC)
        _nRow ++ 
        lRet := oPrtXlsx:SetText(_nRow, _nCol1 , "CNPJ da AgÍncia de NavegaÁ„o:" )
        lRet := oPrtXlsx:SetText(_nRow, _nCol2 , _cM0_CGC)
        _nRow ++ 
        lRet := oPrtXlsx:SetText(_nRow, _nCol1 , "Mercadoria Predominante no Comboio:	" )
        lRet := oPrtXlsx:SetText(_nRow, _nCol2 , Alltrim(GetAdvFVal("SB1","B1_DESC",xFilial("SB1") +  _cDTC_CODPRO ,1, "")  ) )
        _nRow ++ 
        lRet := oPrtXlsx:SetText(_nRow, _nCol1 , "Quantidade de CT-es da Viagem:	" )
        lRet := oPrtXlsx:SetNumber(_nRow, _nCol2 , _cDTX_QTDCTE)
        _nRow ++ 
        lRet := oPrtXlsx:SetText(_nRow, _nCol1 , "Data de Encerramento do Manifesto (SaÌda Viagem):" )
        _nRow ++ 
        lRet := oPrtXlsx:SetText(_nRow, _nCol1 , "Data Prevista para atracaÁ„o no Destino Final:" )

        cCustomFormat := "dd/mm/yyyy"
        cHorAlignment   := oCellHorAlign:Left()
        lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, cColor, cColorF, cCustomFormat)	
        lRet := oPrtXlsx:SetDate(_nRow-1, _nCol2 , _dDTX_DATMAN)
        If !Empty(_dDTW_DATPRE)
            lRet := oPrtXlsx:SetDate(_nRow, _nCol2 ,_dDTW_DATPRE )
        Else
            lRet := oPrtXlsx:SetText(_nRow, _nCol2 , " "   )
        EndIf

        cHorAlignment   := oCellHorAlign:Left()
        lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, cColor, cColorF, cCustomFormat)	

        _nRow ++ 
        lRet := oPrtXlsx:SetText(_nRow, _nCol1 , "Porto de Origem:	" )
        lRet := oPrtXlsx:SetText(_nRow, _nCol2 , _cZB2_DPORTO)

        _nRow ++ 
        lRet := oPrtXlsx:SetText(_nRow, _nCol1 , "Terminal Portu·rio de Origem:	" )
        lRet := oPrtXlsx:SetText(_nRow, _nCol2 , _cZB2_DPORTO )
        _nRow ++ 
        lRet := oPrtXlsx:SetText(_nRow, _nCol1 , "Porto de Destino:	" )
        lRet := oPrtXlsx:SetText(_nRow, _nCol2 , _cA1_NOME )
        _nRow ++ 
        lRet := oPrtXlsx:SetText(_nRow, _nCol1 , "Terminal Portu·rio de Destino:	" )
        lRet := oPrtXlsx:SetText(_nRow, _nCol2 , _cA1_NOME)
        _nRow ++ 
        lRet := oPrtXlsx:SetText(_nRow, _nCol1 , "CÛdigo e DescriÁ„o da EmbarcaÁ„o Principal:" )
        lRet := oPrtXlsx:SetText(_nRow, _nCol2 , _cNAV_IRIN  )

       
        cHorAlignment   := oCellHorAlign:Center()
        //Azul de Fundo e branco de cor
        lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, cColorF, _cCorAzul, cCustomFormat)	        

		cFont := FwPrinterFont():Calibri()
		nSize := 14
		lItalic := .F.
		lBold := .T.
		lUnderlined := .F.
		lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)
        
        _nRow ++ 
        //lRet := oPrtXlsx:MergeCells(_nCol1, 1, _nCol2, 2) 
        lRet := oPrtXlsx:MergeCells(_nRow, _nCol1 , _nRow , _nCol2) 
        lRet := oPrtXlsx:SetText(_nRow, _nCol1 , 'Comboio')
        
		cFont := FwPrinterFont():Calibri()
		nSize := 10
		lItalic := .F.
		lBold := .F.
		lUnderlined := .F.
		lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)

        cStyle := FwXlsxBorderStyle():Medium()
        lRet := oPrtXlsx:SetBorder(lLeft, lTop, lRight, lBottom, cStyle, cColor)

		(_cAlias1)->(DbGoTop())
		_nAtu := 0
		If (_cAlias1)->(!EOF())
			While (_cAlias1)->(!EOF())
				_nAtu ++
				oProcess:IncRegua1( "Detalhando Viagem "+_cDTX_VIAGEM )
				oProcess:IncRegua2("Processando ("+cValTochar(Round(_nAtu / _nCount*100,2))+"%) " )

                cHorAlignment := oCellHorAlign:LEFT()
                cVertAlignment := oCellVertAlign:Center()
                lWrapText := .F.
                nRotation := 0
                cCustomFormat := ""
                
                lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, cColor, cColorF, cCustomFormat)
                lRet := oPrtXlsx:SetText(_nAtu+_nRow, _nCol1, "CÛdigo e DescriÁ„o da EmbarcaÁ„o "+StrZero(_nAtu,3)+":" )
                lRet := oPrtXlsx:SetText(_nAtu+_nRow, _nCol2, Alltrim((_cAlias1)->DTC_ZBALSA) + "-" + Alltrim( (_cAlias1)->ZB3_DBALSA)  )

				(_cAlias1)->(DbSkip())
			EndDo
		EndIf

    (_cAlias1)->(dbCloseArea())

	lRet := oPrtXlsx:toXlsx()
 
    oPrtXlsx:DeActivate()
   

Return()




Static Function ACSELFOLD()
    Local aArea   := GetArea()
    Local cDirIni := GetTempPath(.F.)
    Local cTipArq := " "
    Local cTitulo := "Selecao de Pasta para Salvar arquivo"
    Local lSalvar := .t.
    Local cPasta  := ""
 
    //Se n√o estiver sendo executado via job
    If ! IsBlind()  
        //Chama a fun√ß√o para buscar arquivos
        cPasta := tFileDialog(;
            cTipArq,;                  // Filtragem de tipos de arquivos que ser√o selecionados
            cTitulo,;                  // T√≠tulo da Janela para sele√ß√o dos arquivos
            ,;                         // Compatibilidade
            cDirIni,;                  // Diret√≥rio inicial da busca de arquivos
            lSalvar,;                  // Se for .T., ser√° uma Save Dialog, sen√o ser√° Open Dialog
            GETF_RETDIRECTORY;         // Se n√o passar par√¢metro, ir√° pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT ser√° poss√≠vel pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY ser√° poss√≠vel selecionar o diret√≥rio
        )
 
    EndIf
 	//cPasta := "c:\temp\"
    RestArea(aArea)
Return cPasta
