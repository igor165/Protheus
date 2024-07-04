#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TCFA030.CH"


Function TCFA030()
	Local cFilRH2:= xFilial("RH2")
	Local cCateg
	
	If !PosSRAUser()
		Return
	EndIf

	DBSelectArea("RH2")
	DBSetOrder(2)
	DBGoTop()	

	oHtml := THtmlWindow():New(STR0001)			//"Poupa Tempo"

	RH2->(DBSeek(cFilRH2))
	
	While !RH2->(Eof()) .AND. RH2->RH2_FILIAL == cFilRH2
		If cCateg == NIL .OR. cCateg != RH2_CODCAT
			cCateg := RH2->RH2_CODCAT
			         
			oHtml:AddImage("FOLDER6.PNG")
			oHtml:AddText(AllTrim(FDesc("SX5", "JO"+cCateg, "X5_DESCRI")))
			oHtml:LineBreak()
		EndIf

		oHtml:AddSpace(25)
		oHtml:AddImage("ALTERA.PNG")
		oHtml:AddLink(AllTrim(RH2->RH2_DESC), CreateLink(	RH2->RH2_CODIGO,;
															RH2->RH2_ACAO,;
															Val(RH2->RH2_TIPO),;
															SRA->RA_FILIAL,;
															SRA->RA_MAT	) )
		oHtml:LineBreak()
		
		DBSkip()
	EndDo

	oHtml:Activate()
Return


Static Function CreateLink(cArtefato, cAcao, nTipo, cFil, cMat)
	Local bLink
	
	If nTipo == 1
		bLink:= &("{|| ShellExecute('open', '" + AllTrim(cAcao) + "', '', '', 1)}")
	ElseIf nTipo == 2
		bLink:= &("{|| ShellExecute('open', '" + AllTrim(cAcao) + "', '', '', 1)}")
	ElseIf nTipo == 3
		bLink:= &("{|| " + AllTrim(cAcao) + " }")	
	ElseIf nTipo == 4
		bLink:= &("{|| TCFA030Solicita('" + cFil + "', '" + cMat + "', '" + cArtefato + "', '" + cAcao + "') }")
	Else
		bLink:= {||}
	EndIf
Return bLink


Function TCFA030Solicita(cFil, cMat, cArtefato, cAcao)
	Local oModel:= FWLoadModel("TCFA040")
	
	If ExistCpo("RH3", cMat + PadR(cArtefato, TamSX3("RH3_ORIGEM")[1])  +"1", 2, NIL, .F.)
		MsgAlert(STR0002 + CRLF + STR0003, STR0004)			//"Já existe uma solicitacao realizada!"###"Por favor, aguarde o atendimento da mesma."###"Aviso!"
		Return
	EndIf
	
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()
	oModel:SetValue("TCFA040_RH3", "RH3_FILIAL",	xFilial("RH3", cFil))
	oModel:SetValue("TCFA040_RH3", "RH3_MAT",		cMat)
	oModel:SetValue("TCFA040_RH3", "RH3_TIPO",		"1")
	oModel:SetValue("TCFA040_RH3", "RH3_STATUS",	"1")
	oModel:SetValue("TCFA040_RH3", "RH3_ORIGEM",	cArtefato)
	oModel:SetValue("TCFA040_RH3", "RH3_DTSOLI",	dDataBase)	
	
	If oModel:VldData()
		oModel:CommitData()
		MsgAlert(STR0006, STR0004)					//"Solicitação realizada com sucesso!"###"Aviso"
	Else
		MsgAlert(oModel:GetErrorMessage()[6], STR0005)					//"Atencao!"
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewWebDef
Gera o XML para Web

@author Rogerio Ribeiro da Cruz
@since 29/06/2009
@version 1.0
@protected
/*/
//-------------------------------------------------------------------
Static Function ViewWebDef(nOperation, cPk, cFormMVC)
	Local oView := ViewDef()
Return oView:GetXML2Web(nOperation, cPk, cFormMVC)