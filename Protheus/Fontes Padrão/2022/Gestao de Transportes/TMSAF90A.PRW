#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAF90.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} TF90LstDoc
Tela para seleção múltipla de documentos
@type Static Function
@author Valdemar Roberto Mognon
@since 23/09/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TF90LstDoc()
Local aAreas     := {DTQ->(GetArea()),GetArea()}
Local lRet       := .T.
Local oModel     := FWModelActive()
Local oMdFldDM6  := oModel:GetModel("MdFieldDM6")
Local nOperation := oModel:GetOperation()

If nOperation != MODEL_OPERATION_INSERT .And. nOperation != MODEL_OPERATION_UPDATE
	lRet := .F. 
Else
	If !Empty(FwFldGet("DM6_FILORI")) .And. !Empty(FwFldGet("DM6_VIAGEM"))
		DTQ->(DbSetOrder(2))
		If DTQ->(DbSeek(xFilial("DTQ") + FwFldGet("DM6_FILORI") + FwFldGet("DM6_VIAGEM")))
			TF60F3Doc(.T.)
		EndIf
	Else
		Help("",1,"OBRIGAT",,FWX3Titulo("DTQ_VIAGEM"),04,01)
	EndIf
EndIf 

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet 

/*{Protheus.doc} TF90BipDoc
Tela para seleção de documentos por código de barras
@type Static Function
@author Valdemar Roberto Mognon
@since 23/09/2020
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TF90BipCod()
Local aAreas   := {DTQ->(GetArea()),GetArea()}
Local cCodbar  := Space(Len(DT6->DT6_CHVCTE) + 1)
Local cCodbar2 := Space(Len(DT6->DT6_CHVCTE) + 1)
Local oGetBar  := Nil
Local lRet     := .T.
Local oModel   := FwModelActive()
Local oView    := FwViewActive()

Local oDlgBar := NIl

If !Empty(FwFldGet("DM6_FILORI")) .And. !Empty(FwFldGet("DM6_VIAGEM"))
	DTQ->(DbSetOrder(2))
	If DTQ->(DbSeek(xFilial("DTQ") + FwFldGet("DM6_FILORI") + FwFldGet("DM6_VIAGEM")))
		DEFINE DIALOG oDlgBar FROM 0,0 TO 100,400 TITLE STR0014 Of oMainWnd PIXEL	//-- "Leitura do Cód. de Barras por Documento."
		
		@ 16,10 SAY STR0015 Of oDlgBar PIXEL SIZE 100,10	//-- Cód de barras
		@ 26,10 MSGET oGetBar VAR cCodbar SIZE 160,10 Picture "@!" VALID (TMF60PRE(@cCodBar,@oGetBar,oModel,oView,2)) PIXEL
		@ 25,11 MSGET oGetBar2 VAR cCodbar2 SIZE 1,1	//-- Campo para mudanca de foco e execução do valid
		
		ACTIVATE DIALOG oDlgBar CENTERED 
	EndIf
Else
	Help("",1,"OBRIGAT",,FWX3Titulo("DTQ_VIAGEM"),04,01)
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet
