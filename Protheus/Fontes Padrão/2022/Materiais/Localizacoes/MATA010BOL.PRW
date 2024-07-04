#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'MATA010BOL.CH'

/*/{Protheus.doc} MATA010BOL
Productos (Bolivia)
@author 	raul.medina
@since 		17/02/2022
@version	12.1.27 / Superior
/*/
Function MATA010BOL(xRotAuto,nOpc)

	MATA010(xRotAuto,nOpc)
	
Return(.T.)


/*/{Protheus.doc} ModelDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		17/02/2022
@version	12.1.27 / Superior
/*/
Static Function ModelDef()
Local oModel		:= FwLoadModel("MATA010")
Local oEvtVul		:= Nil

	If (SuperGetmv("MV_CFDUSO", , "") <> "0") .and. ("VULCAN" $ SuperGetMV("MV_PROVFE", , ""))
		oEvtVul := MATA010VUL():New()
		oModel:InstallEvent("MATA010VUL", /*cOwner*/, oEvtVul)
	EndIf

Return oModel

/*/{Protheus.doc} ViewDef
Definición del View
@author	 	raul.medina
@since 		17/02/2022
@version	12.1.27 / Superior
/*/
Static Function ViewDef()
Local oView 	:= FWLoadView("MATA010")
oView:oModel	:= FwLoadModel("MATA010")

Return oView

/*/{Protheus.doc} MenuDef
Definición del View
@author	 	raul.medina
@since 		17/02/2022
@version	12.1.27 / Superior
/*/
Static Function MenuDef()
Local aRotina	:= FWLoadMenuDef("MATA010")

	If (SuperGetmv("MV_CFDUSO", , "") <> "0") .and. ("VULCAN" $ SuperGetMV("MV_PROVFE", , "")) .and. FindFunction("ImpProdVul")
		aAdd(aRotina, {OemtoAnsi(STR0001), "ImpProdVul", 0, 0, 0, .F.} )		//"Informar productos a Vulcan"
	EndIf

Return aRotina
