#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} TMSAF63G
Rotina de Validação da Linha da Viagem Modelo 3 - Integração TMS x GFE
@type Function
@author Katia
@since 10/08/2020
@version 12.1.30
@param param, param_type, param_descr
@return lRet
*///-------------------------------------------------------------------
Function TMSAF63G(oModel,nLine,cAction,cIDField,xValue,xCurrentValue,cValid)

Local lRet		:= .T.
Local cModel    := ""

Default oModel	:= FWModelActive()

cModel:= Upper(oModel:cId)

If cModel == Upper("MdGridDM8")
	If cValid == "POS"
		lRet:= LinePosDM8(oModel)
	ElseIf cValid == "PRE"
		lRet:= LinePreDM8(oModel,nLine,cAction,cIDField,xValue,xCurrentValue)
	EndIf
ElseIf cModel == Upper("MdGridDJN")
	If cValid == "POS"
		lRet:= LinePosDJN(oModel,nLine)
	ElseIf cValid == "PRE"
		lRet:= LinePreDJN(oModel,nLine,cAction,cIDField,xValue,xCurrentValue)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/* LinePosDM8
Função do Linha Ok da Grid dos Documentos (DM8) da Viagem Modelo 3 
@type Function
@author Katia
@since 10/08/2020
@version 12.1.30
@param param, param_type, param_descr
@return lRet
*/
//-------------------------------------------------------------------
Static Function LinePosDM8(oMdlGridDM8,nLine)
Local lRet       	:= .T.

If lRet //.And. (lTMS3GFE .Or. lTmsRdpU)  //-- Integracao Viagem TMS x GFE
	If M->DTQ_PAGGFE == StrZero(1,Len(DTQ->DTQ_PAGGFE)) .And. M->DTQ_SERTMS <> StrZero(2,Len(DTQ->DTQ_SERTMS))
		If !Empty(FwFldGet('DM8_DOC')) 
			If Empty(FwFldGet('DM8_UFDES')) 
				Help('',1,"OBRIGAT2",,RetTitle('DM8_UFDES'),04,01)
				lRet:= .F.
			ElseIf Empty(FwFldGet('DM8_CDMUND'))
				Help('',1,"OBRIGAT2",,RetTitle('DM8_CDMUND'),04,01)
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/* LinePreDM8
Função do Pre Validação (bLinePre) da Linha da Grid dos Documentos (DM8)
@type Function
@author Katia
@since 10/08/2020
@version 12.1.30
@param param, param_type, param_descr
@return lRet
*/
//-------------------------------------------------------------------
Static Function LinePreDM8(oMdlGridDM8,nLine,cAction,cIDField,xValue,xCurrentValue)
Local lRet       := .T.

If cAction == "CANSETVALUE"
	If M->DTQ_PAGGFE <> StrZero(1,Len(DTQ->DTQ_PAGGFE))
		lRet:= .F.
	Else
		If !Empty(FwFldGet("DM3_FILDOC")) .And. !Empty(FwFldGet("DM3_DOC")) .And. !Empty(FwFldGet("DM3_SERIE"))
			If FwFldGet("DM3_STATUS") <> StrZero(1,Len(DUD->DUD_STATUS)) 
				lRet:= .F.
			EndIf
		Else
			lRet:= .F.
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/* LinePosDJN
Função do Linha Ok da Grid do Redespacho Adicional (DJN) 
@type Static Function
@author Katia
@since 10/08/2020
@version 12.1.30
@param param, param_type, param_descr
@return lRet
*/
//-------------------------------------------------------------------
Static Function LinePosDJN(oMdlGridDJN,nLine)
Local lRet      := .T.

If M->DTQ_SERTMS <> StrZero(3,Len(DC5->DC5_SERTMS)) .Or. FwFldGet('DM3_SERIE') == 'COL'
	Help('',1,'TMSA14442') //"Permitido incluir os Redespachos da Viagem somente para Documentos com Serviço de Transporte de ENTREGA.        
	lRet:= .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/* LinePreDJN
Função do Pre Validação (bLinePre) do Redespacho Adicional (DJN)
@type Static Function
@author Katia
@since 10/08/2020
@version 12.1.30
@param param, param_type, param_descr
@return lRet
*/
//-------------------------------------------------------------------
Static Function LinePreDJN(oMdlGridDJN,nLine,cAction,cIDField,xValue,xCurrentValue)
Local lRet    := .T.
Local lValida := .F.
Local nX      := 0
Local lDocRed := .F.

If cAction == "CANSETVALUE"

	//Nao habilita para Coleta e Transferencia
	If M->DTQ_SERTMS <> StrZero(3,Len(DC5->DC5_SERTMS)) 
		lRet:= .F.
	Else
		cFilDoc:= FwFldGet("DM3_FILDOC")
		cDoc   := FwFldGet("DM3_DOC")
		cSerie := FwFldGet("DM3_SERIE")

		If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)			
			If cSerie == 'COL'
				lRet:= .F.
			Else
				lRet:= FwFldGet('DM3_STATUS') == StrZero(1,Len(DUD->DUD_STATUS)) 
				If lRet
					lDocRed:= TMA360IDFV(cFilDoc,cDoc,cSerie)
					If lDocRed
						lRet:= .F.
					EndIf
				EndIf
			EndIf
		Else	
			lRet:= .F.
		EndIf
	EndIf		

	If !lRet .And. !lDocRed
		Help('',1,'TMSA14442') //"Permitido incluir os Redespachos da Viagem somente para Documentos com Serviço de Transporte de ENTREGA.        
	EndIf
	
ElseIf cAction == "SETVALUE"
	lValida:= TF64GetSt('lAltRomeio')
	If lValida 	.And. oMdlGridDJN:Length() > 1	
		aSaveLines := FWSaveRows()	
		For nX:= 1 To oMdlGridDJN:Length()
			oMdlGridDJN:GoLine(nX)
			If !oMdlGridDJN:IsDeleted() .And. !oMdlGridDJN:IsEmpty()
				If nX <> nLine .And. FwFldGet('DJN_CDTPOP') <> xValue
					lRet:= .F.
					Exit
				EndIf
			EndIF
		Next nX
		FWRestRows( aSaveLines )
		If !lRet
			Help(' ', 1, 'TMSA14446') //-- O Tipo de Operação deve ser igual para todos os Itens do Redespacho Adicional.		
		EndIf
	EndIf
EndIf

Return lRet
