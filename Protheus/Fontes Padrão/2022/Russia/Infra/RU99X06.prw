#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "FwMvcDef.ch"
#include "RU99X06.CH"

/*/{Protheus.doc} RU99X06
Routine responsible to make a link with Fields in Query and SubQueries

@type function
@author Alison Kaique
@since Apr|2019
/*/
Function RU99X06()
	Local aSize   := FWGetDialogSize(oMainWnd)
	Local cTitle  := STR0001 //Fields x Queries
	Local bOk     := {|| RUF6SStore() }
	Local bClose  := {|| oDlg:End() }
	Local oArea   := Nil

	Private oDlg
	Private cCodQuery    := F6R->F6R_CODQRY
	Private oGetData     := Nil
	Private cCadastro    := STR0002 + Alltrim(cCodQuery) + " - " + Alltrim(F6R->F6R_TITULO) //"Query Link: "

	Private aTitSubQuery := {}
	Private aLabel       := {}
	Private	aMask        := {}

	Private cSelcField := '' // Fields selected by user

	//ChkFile("F6S")

	oDlg := MsDialog():New(aSize[1], aSize[2], aSize[3], aSize[4], cTitle,,,, nOr(WS_VISIBLE, WS_POPUP),,,,, .T.,,,, .F.)

	oLayer := FWLayer():New()
	oLayer:Init(oDlg, .T.)

	oLayer:AddLine("LINE01", 10) //Actions
	oLayer:AddLine("LINE02", 90) //SubQuery
	//Actions
	oLayer:AddCollumn("BOX01", 100,, "LINE01")
	oLayer:AddWindow("BOX01", "PANEL01", "Actions", 100, .F.,,, "LINE01") //Actions
	//Indexes
	oLayer:AddCollumn("BOX02", 100,, "LINE02")
	oLayer:AddWindow("BOX02", "PANEL02", cCadastro, 100, .F.,,, "LINE02")

	//Actions
	oBtView   := TButton():New(005, 005, "Exit", oLayer:GetWinPanel("BOX01", "PANEL01", "LINE01"), bClose  , 090, 015,,,,.T.)	//Exit

	//RU01Panel(oLayer:GetWinPanel("BOX01", "PANEL01", "LINE01")) //Actions
	//RU02Panel(oLayer:GetWinPanel("BOX02", "PANEL02", "LINE02")) //Indexes

	oLayer:AddCollumn("BOX01", 100,, "LINE02")
	oLayer:AddWindow("BOX01", "PANEL02", cCadastro, 100, .F.,,, "LINE02")

	RU01Panel(oLayer:GetWinPanel("BOX02", "PANEL02", "LINE02"))

	//oDlg:bInit := EnchoiceBar(oDlg,bOk, bClose,,) //Remove OK/Confimations temporary
	oDlg:Activate()
Return

/*/{Protheus.doc} RU01Panel
Creation of GetDados

@type function
@author Alison Kaique
@since Apr|2019
@param oPanelPar, object, Panel's object
/*/
Static Function RU01Panel(oPanelPar)
	Local aHeadScreen := {}
	Local aHeadAux    := {}
	Local aColsScreen := {}
	Local cQuery      := ""
	Local cMsgHelp    := ""
	Local cPergSX1    := ""

	cPergSX1 := alltrim(F6R->F6R_X1PERG)

	If !Empty(cPergSX1)
		aSX1Perg := RUSX1Trat(cPergSX1,.F.)
		aSX1Perg := AClone(aSX1Perg[2])
	Else
		aSX1Perg := {}
	EndIf

	cQuery      := F6R->F6R_QUERY
	cNewQuery   := RUNewQry(cQuery, aSX1Perg)

	aRetVis	    := RUViewData(cNewQuery)

	aHeadAux	:= AClone(aRetVis[1])
	aHeadScreen	:= RUHeader(aHeadAux)
	aColsScreen	:= RUCols(aHeadScreen)

	oGetData := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE,,,, Nil, 0, Len(aColsScreen),,,, oPanelPar, aHeadScreen, aColsScreen)
	oGetData:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetData:oBrowse:blDblClick := {|| RUDblClick() }
Return

/*/{Protheus.doc} RUHeader
Definition of Header

@type function
@author Alison Kaique
@since Apr|2019
@param aHeadPar, array, Informations about Header
@return aReturn, array, Return with Header
/*/
Static Function RUHeader(aHeadPar)
	Local aReturn := {}
	Local ii := 1
	Local aAuxRet := {}

	SX3->(dbSetOrder(2)) //X3_CAMPO
	SX3->(dbSeek("F6S_QRYMEM"))

	For ii := 1 To Len(aHeadPar)
		cCampo := aHeadPar[ii][2]
		cValidCPO := "RUVISV04()"

		aAuxRet := {}
		Aadd(aAuxRet, cCampo)
		Aadd(aAuxRet, cCampo)
		Aadd(aAuxRet, SX3->X3_PICTURE)
		Aadd(aAuxRet, SX3->X3_TAMANHO)
		Aadd(aAuxRet, SX3->X3_DECIMAL)
		Aadd(aAuxRet, cValidCPO)
		Aadd(aAuxRet, SX3->X3_USADO)
		Aadd(aAuxRet, SX3->X3_TIPO)
		Aadd(aAuxRet, SX3->X3_F3)
		Aadd(aAuxRet, SX3->X3_CONTEXT)

		Aadd(aReturn, AClone(aAuxRet))
	Next ii
Return aReturn

/*/{Protheus.doc} RUCols
Definition of informations in array aCols

@type function
@author Alison Kaique
@since Apr|2019
@param aHeadPar, array, Informations about Header
@return aReturn, array, Data according Table F6S
/*/
Static Function RUCols(aHeadPar)
	Local aReturn  := {}
	Local ii       := 1
	Local nSizeQry := TAMSX3("F6S_CPOQRY")[1]
	Local aAuxRet1 := {}

	F6S->(dbSetOrder(1)) //F6S_FILIAL, F6S_CODQRY, F6S_CPOQRY

	For ii := 1 To Len(aHeadPar)
		If F6S->(dbSeek(FWxFilial("F6S") + cCodQuery + PADR(aHeadPar[ii][2],nSizeQry)))
			Aadd(aAuxRet1, F6S->F6S_QRYMEM)
			Aadd(aTitSubQuery, F6S->F6S_TITSUB)
			Aadd(aLabel, F6S->F6S_LABEL)
			Aadd(aMask, F6S->F6S_MASCAR)
		Else
			Aadd(aAuxRet1, CriaVar("F6S_QRYMEM") 	)
			Aadd(aTitSubQuery, CriaVar("F6S_TITSUB"))
			Aadd(aLabel, CriaVar("F6S_LABEL"))
			Aadd(aMask, CriaVar("F6S_MASCAR"))
		EndIf
	Next ii

	Aadd(aAuxRet1, .F.)
	Aadd(aReturn, AClone(aAuxRet1))
Return aReturn


/*/{Protheus.doc} RUF6SStore
Store informations in Table F6S

@type function
@author Alison Kaique
@since Apr|2019
/*/
Static Function RUF6SStore()
	Local aStoreCols := AClone(oGetData:ACOLS)
	Local aStoreHead := AClone(oGetData:AHEADER)
	Local ii         := 0
	Local lStore     := MsgYesNo(STR0004) //Do you want store this informations?

	If lStore
		F6S->(dbSetOrder(1)) //F6S_FILIAL + F6S_CODQRY + F6S_CPOQRY

		For ii := 01 To Len(aStoreHead)
			lFound := F6S->(dbSeek(FWxFilial("F6S") + cCodQuery + aStoreHead[ii][2]))

			If aStoreCols[Len(aStoreCols)][Len(aStoreHead)+1] == .F.
				If RecLock("F6S", !lFound)
					F6S->F6S_FILIAL := FWxFilial("F6S")
					F6S->F6S_CODQRY := cCodQuery
					F6S->F6S_CPOQRY := aStoreHead[ii][2]
					F6S->F6S_QRYMEM := aStoreCols[Len(aStoreCols)][ii]
					F6S->F6S_TITSUB := aTitSubQuery[ii]
					F6S->F6S_LABEL := aLabel[ii]
					F6S->F6S_MASCAR := aMask[ii]
					F6S->(MsUnlock())
				EndIf
			Else
				If lFound .AND. RecLock("F6S", .F.)
					F6S->(dbDelete())
					F6S->(MsUnlock())
				EndIf
			EndIf
		Next ii

		oDlg:End()
	EndIf //lStore
Return

/*/{Protheus.doc} RUDblClick
Double Click Function for SubQuery

@type function
@author Alison Kaique
@since Apr|2019
/*/
Static Function RUDblClick()
	Local aSize       := FWGetDialogSize(oMainWnd)
	Local nLinClick	  := oGetData:oBrowse:nAt
	Local nColClick	  := oGetData:oBrowse:nColPos
	Local aHeadScreen := AClone(oGetData:AHEADER)
	Local aColsScreen := AClone(oGetData:ACOLS)
	Local bClose      := {|| oDlgSQ:End() }
	Local cTitle      := ""
	Local oLayerSQ    := Nil
	Local oDlgSQ      := Nil
	Local cLabel      := ""
	Local cMask	      := ""
	Local oSQ03Panel  := Nil
	Local oMask	      := Nil
	Local oLabel      := Nil
	Local oSQ04Panel  := Nil

	Private cCadastro := ""

	cFieldSub := Alltrim(oGetData:AHEADER[nColClick][2])

	cTitle := STR0005 + cFieldSub //SubQuery referring to the Field:
	cCadastro := cTitle

	aSize[3] := aSize[3] - (aSize[3]*(1/100))
	aSize[4] := aSize[4] - (aSize[4]*(45/100))

	DEFINE FONT oFontMEMO NAME "Courier New" SIZE 7,14   //6,15

	oDlgSQ := MsDialog():New(aSize[1], aSize[2], aSize[3], aSize[4], cTitle,,,,,,,,, .T.)

	oDlgSQ:lCentered := .T.
	oLayerSQ := FWLayer():New()
	oLayerSQ:Init(oDlgSQ, .T.)

	oLayerSQ:AddLine("LINE02", 15)
	oLayerSQ:AddLine("LINE03", 15)
	oLayerSQ:AddLine("LINE01", 70)

	oLayerSQ:AddCollumn("BOX01", 100,, "LINE01")
	oLayerSQ:AddCollumn("BOX02", 85,, "LINE02")
	oLayerSQ:AddCollumn("BOX03", 15,, "LINE02")
	oLayerSQ:AddCollumn("BOX04", 50,, "LINE03")
	oLayerSQ:AddCollumn("BOX05", 50,, "LINE03")

	oLayerSQ:AddWindow("BOX01", "PANEL01",	STR0006, 100, .F.,,, "LINE01") //SubQuery
	oLayerSQ:AddWindow("BOX02", "PANEL02",	STR0007, 100, .F.,,, "LINE02") //SubQuery Title
	oLayerSQ:AddWindow("BOX03", "PANEL03",	STR0008, 100, .F.,,, "LINE02") //Actions
	oLayerSQ:AddWindow("BOX04", "PANEL04",	STR0009, 100, .F.,,, "LINE03") //Field Title
	oLayerSQ:AddWindow("BOX05", "PANEL05",	STR0010, 100, .F.,,, "LINE03") //Field Picture

	oSQ01Panel := oLayerSQ:GetWinPanel("BOX01", "PANEL01", "LINE01")
	cMemo := aColsScreen[nLinClick][nColClick]
	@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 380,270 OF oSQ01Panel PIXEL
	oMemo:bRClicked	:= {||AllwaysTrue()}
	oMemo:oFont		:= oFontMEMO
	oMemo:Align 		:= CONTROL_ALIGN_ALLCLIENT

	cTitSub := aTitSubQuery[nColClick]
	oSQ02Panel := oLayerSQ:GetWinPanel("BOX02", "PANEL02", "LINE02")
	@ 5,5 GET oTitSub  VAR cTitSub SIZE 380,270 Picture "@!" OF oSQ02Panel PIXEL
	oTitSub:bRClicked	:= {||AllwaysTrue()}
	oTitSub:oFont		:= oFontMEMO
	oTitSub:Align 	:= CONTROL_ALIGN_ALLCLIENT

	oSQ03Panel := oLayerSQ:GetWinPanel("BOX03", "PANEL03", "LINE02")
	oStore := TBitmap():New(001,005, 32, 32, "salvar.png",,.T.,oSQ03Panel,,,,,,,,,.T.,,,.T.)
	bStore := {|| oGetData:ACOLS[nLinClick][nColClick] := cMemo, oGetData:Refresh(), aTitSubQuery[nColClick] := cTitSub, ;
	aLabel[nColClick]:=cLabel,aMask[nColClick] := cMask,  oDlgSQ:End() }
	oStore:BLCLICKED := bStore
	oFechar := TBitmap():New(001,025, 32, 32, "final.png",,.T.,oSQ03Panel,,,,,,,,,.T.,,,.T.)
	oFechar:BLCLICKED := {|| oDlgSQ:End() }

	cLabel := aLabel[nColClick]
	oSQ03Panel := oLayerSQ:GetWinPanel("BOX04", "PANEL04", "LINE03")
	@ 5,5 GET oLabel VAR cLabel SIZE 380,270 Picture "" OF oSQ03Panel PIXEL
	oLabel:bRClicked	:= {||AllwaysTrue()}
	oLabel:oFont		:= oFontMEMO
	oLabel:Align 		:= CONTROL_ALIGN_ALLCLIENT

	cMask := aMask[nColClick]
	oSQ04Panel := oLayerSQ:GetWinPanel("BOX05", "PANEL05", "LINE03")
	@ 5,5 GET oMask  VAR cMask SIZE 380,270 Picture "@!" OF oSQ04Panel PIXEL
	oMask:bRClicked	:= {||AllwaysTrue()}
	oMask:oFont		:= oFontMEMO
	oMask:Align 		:= CONTROL_ALIGN_ALLCLIENT

	oDlgSQ:Activate()
Return