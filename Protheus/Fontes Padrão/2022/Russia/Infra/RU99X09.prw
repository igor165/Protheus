#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "FwMvcDef.ch"
#include "RU99X09.CH"

#include "msmgadd.ch"

#define MAX_ORDERS 35

/*/{Protheus.doc} RU99X09
Routine responsible to create index for Queries

@type function
@author Alison Kaique
@since Apr|2019
/*/
Function RU99X09()
	Local aSize   := FWGetDialogSize(oMainWnd)
	Local cTitle  := STR0001 //Query Indexes
	Local bOk     := {|| RUF6VStore() }
	Local bClose  := {|| oDlg:End() }
	Local oArea   := Nil

	Private oDlg
	Private cCodQuery    := F6R->F6R_CODQRY
	Private oGetData     := Nil
	Private cCadastro    := STR0001 + Alltrim(cCodQuery) + " - " + Alltrim(F6R->F6R_TITULO) //"Query Indexes: "

	Private aTitSubQuery := {}
	Private aLabel       := {}
	Private	aMask        := {}
	Private aStructQry   := {}
	Private aDelIndex    := {}

	Private cSelcField := '' // Fields selected by user

	ChkFile("F6S")

	oDlg := MsDialog():New(aSize[1], aSize[2], aSize[3], aSize[4], cTitle,,,, nOr(WS_VISIBLE, WS_POPUP),,,,, .T.,,,, .F.)

	oLayer := FWLayer():New()
	oLayer:Init(oDlg, .T.)
	oLayer:AddLine("LINE01", 10) //Actions
	oLayer:AddLine("LINE02", 85) //Indexes
	//Actions
	oLayer:AddCollumn("BOX01", 100,, "LINE01")
	oLayer:AddWindow("BOX01", "PANEL01", STR0004, 100, .F.,,, "LINE01") //Actions
	//Indexes
	oLayer:AddCollumn("BOX02", 100,, "LINE02")
	oLayer:AddWindow("BOX02", "PANEL02", cCadastro, 100, .F.,,, "LINE02")

	RU01Panel(oLayer:GetWinPanel("BOX01", "PANEL01", "LINE01")) //Actions
	RU02Panel(oLayer:GetWinPanel("BOX02", "PANEL02", "LINE02")) //Indexes

	//oDlg:bInit := EnchoiceBar(oDlg,bOk, bClose,,) //removed the opstion to save
	oDlg:Activate()
Return

/*/{Protheus.doc} RU01Panel
Creation of Actions Buttons

@type function
@author Alison Kaique
@since Apr|2019
@param oPanelPar, object, Panel's object
/*/
Static Function RU01Panel(oPanelPar)
	Local oBtView   := Nil //Operation View
	Local oClose    := Nil //Operation Close
	Local nOper     := 0 //Operation
	Local bClsoe     :=  {|| oDlg:End() } //CodeBlock for Close

	oBtView   := TButton():New(005, 005, STR0008, oPanelPar, bClsoe  , 090, 015,,,,.T.)	//View
	oClose   := TButton():New(005, 005, "Exit", oPanelPar, bClsoe  , 090, 105,,,,.T.)	//Exit

Return

/*/{Protheus.doc} RU01Panel
Action for Query Indexes

@type function
@author Alison Kaique
@since Apr|2019
@param nOper, numeric, Operation
/*/
Static Function RUAction(nOper)
	Local aGetHead  := oGetData:aHeader //aHeader according GetData
	Local nPosOrder := GDFieldPos("ORDER"      , aGetHead) //Position of Field ORDER
	Local nPosDescr := GDFieldPos("DESCRIPTION", aGetHead) //Position of Field DESCRIPTION
	Local nPosKey   := GDFieldPos("KEY"        , aGetHead) //Position of Field KEY
	Local nLine     := 0 //Currently Line
	Local aIndex    := {} //Control of Index
	Local cOrder    := "" //Order
	Local cDescr    := "" //Description
	Local cKey      := "" //Key

	//Verify Fields Positions
	If (nPosOrder > 0 .AND. nPosDescr > 0 .AND. nPosKey > 0)
		//Verify if empty File and Operation
		If (((Len(oGetData:aCols) == 1 .AND. Empty(oGetData:aCols[01, nPosKey])) .OR. Len(oGetData:aCols) == 0) .AND. !(nOper == MODEL_OPERATION_INSERT))
			Help(" ", 1, "RUAction", , STR0009, 4, 15) //Only Include Operation for an Empty File!
		Else
			//Check Operation
			Do Case
				Case nOper == MODEL_OPERATION_INSERT //Add
					aIndex := RUIndex(nOper, "", "", "", aStructQry)
					If (aIndex[01])
						cKey   := aIndex[02]
						cDescr := aIndex[03]

						//Verify if already exists Index for the key
						If !(RUExistKey(cKey))
							//Check Line
							If (Len(oGetData:aCols) == 1 .AND. Empty(oGetData:aCols[01, nPosKey]))
								nLine := 01
								cOrder := "1"
								//Put informations
								oGetData:aCols[nLine, nPosOrder] := cOrder
								oGetData:aCols[nLine, nPosDescr] := cDescr
								oGetData:aCols[nLine, nPosKey]   := cKey
							Else
								nLine := Len(oGetData:aCols)
								//Get Last Order
								cOrder := oGetData:aCols[nLine, nPosOrder]
								//Increment Order
								cOrder := Soma1(cOrder)
								//Add New Line
								If (oGetData:AddLine())
									nLine := Len(oGetData:aCols)
									//Put informations
									oGetData:aCols[nLine, nPosOrder] := cOrder
									oGetData:aCols[nLine, nPosDescr] := cDescr
									oGetData:aCols[nLine, nPosKey]   := cKey
									oGetData:AddLastEdit(nLine)
								ElseIf (Len(oGetData:aCols) == MAX_ORDERS)
									Help(" ", 01, "RUAction", , STR0010, 04, 15) //Reached the maximum number of records!
								EndIf
							EndIf
						EndIf
					EndIf
					//Refresh
					oGetData:ForceRefresh()
					oGetData:Refresh()
				Case nOper == MODEL_OPERATION_UPDATE //Edit
					nLine := oGetData:nAt //Get Currently Line

					//Set Informations
					cOrder := oGetData:aCols[nLine, nPosOrder]
					cDescr := oGetData:aCols[nLine, nPosDescr]
					cKey   := oGetData:aCols[nLine, nPosKey]

					aIndex := RUIndex(nOper, cOrder, cDescr, cKey, aStructQry)

					If (aIndex[01])
						cKey   := aIndex[02]
						cDescr := aIndex[03]

						//Verify if already exists Index for the key
						If !(RUExistKey(cKey, nLine))
							//Put informations
							oGetData:aCols[nLine, nPosOrder] := cOrder
							oGetData:aCols[nLine, nPosDescr] := cDescr
							oGetData:aCols[nLine, nPosKey]   := cKey
						EndIf
					EndIf
					//Refresh
					oGetData:ForceRefresh()
					oGetData:Refresh()
				Case nOper == MODEL_OPERATION_DELETE //Delete
					nLine := oGetData:nAt //Get Currently Line

					//Set Informations
					cOrder := oGetData:aCols[nLine, nPosOrder]
					cDescr := oGetData:aCols[nLine, nPosDescr]
					cKey   := oGetData:aCols[nLine, nPosKey]

					aIndex := RUIndex(nOper, cOrder, cDescr, cKey, aStructQry)

					If (aIndex[01])
						oGetData:aCols[nLine, Len(aGetHead) + 01] := .T.
					EndIf
					//Reordering
					FWMsgRun( , {|| RUOrder() } ,, STR0022 ) //"Ordering... "
					//Refresh
					oGetData:ForceRefresh()
					oGetData:Refresh()
				Case nOper == MODEL_OPERATION_VIEW //View
					nLine := oGetData:nAt //Get Currently Line

					//Set Informations
					cOrder := oGetData:aCols[nLine, nPosOrder]
					cDescr := oGetData:aCols[nLine, nPosDescr]
					cKey   := oGetData:aCols[nLine, nPosKey]

					aIndex := RUIndex(nOper, cOrder, cDescr, cKey, aStructQry)
			EndCase
		EndIf
	EndIf
Return

/*/{Protheus.doc} RU02Panel
Creation of GetDados

@type function
@author Alison Kaique
@since Apr|2019
@param oPanelPar, object, Panel's object
/*/
Static Function RU02Panel(oPanelPar)
	Local aHeadScreen := {}
	Local aHeadAux    := {}
	Local aColsScreen := {}
	Local cQuery      := ""
	Local cMsgHelp    := ""
	Local cPergSX1    := ""
	Local cLineOK     := ""

	cPergSX1 := F6R->F6R_X1PERG

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
	aStructQry  := aHeadAux
	aHeadScreen	:= RUHeader(aHeadAux)
	aColsScreen	:= RUCols(aHeadScreen)
	cLineOK     := "RUX99LOK()" //Incremental Fields

	oGetData := MsNewGetDados():New(0, 0, 0, 0, GD_INSERT + GD_UPDATE, cLineOK, , , Nil, 0, MAX_ORDERS,,,, oPanelPar, aHeadScreen, aColsScreen)
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
	Local aReturn   := {}
	Local aAuxRet   := {}
    Local cValidCPO := "AllwaysTrue()"

    SX3->(DBSetOrder(2)) //X3_CAMPO
	SX3->(DBSeek("A1_COD"))

    //ORDER
    aAuxRet := {}
    AAdd(aAuxRet, STR0013) //Title //Order
    AAdd(aAuxRet, "ORDER") //Field
    AAdd(aAuxRet, "@!") //Picture
    AAdd(aAuxRet, 01) //Size
    AAdd(aAuxRet, 0) //Decimals
    AAdd(aAuxRet, cValidCPO) //Validation
    AAdd(aAuxRet, SX3->X3_USADO) //Used
    AAdd(aAuxRet, "C") //Type
    AAdd(aAuxRet, "") //Standard Query
    AAdd(aAuxRet, SX3->X3_CONTEXT)

    AAdd(aReturn, AClone(aAuxRet))

    //Description
    aAuxRet := {}
    AAdd(aAuxRet, STR0014) //Title //Description
    AAdd(aAuxRet, "DESCRIPTION") //Field
    AAdd(aAuxRet, "@!") //Picture
    AAdd(aAuxRet, 250) //Size
    AAdd(aAuxRet, 0) //Decimals
    AAdd(aAuxRet, cValidCPO) //Validation
    AAdd(aAuxRet, SX3->X3_USADO) //Used
    AAdd(aAuxRet, "C") //Type
    AAdd(aAuxRet, "") //Standard Query
    AAdd(aAuxRet, SX3->X3_CONTEXT)

    AAdd(aReturn, AClone(aAuxRet))

    //Key
    aAuxRet := {}
    AAdd(aAuxRet, STR0015) //Title //Key
    AAdd(aAuxRet, "KEY") //Field
    AAdd(aAuxRet, "@!") //Picture
    AAdd(aAuxRet, 250) //Size
    AAdd(aAuxRet, 0) //Decimals
    AAdd(aAuxRet, cValidCPO) //Validation
    AAdd(aAuxRet, SX3->X3_USADO) //Used
    AAdd(aAuxRet, "C") //Type
    AAdd(aAuxRet, "") //Standard Query
    AAdd(aAuxRet, SX3->X3_CONTEXT)

    AAdd(aReturn, AClone(aAuxRet))

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

	DBSelectArea('F6T')
	F6T->(DBSetOrder(01)) //F6T_FILIAL + F6T_CODQRY

	//Verify if exists indexes for Query
	If (F6T->(DBSeek(FWxFilial("F6T") + cCodQuery)))
		//Loop in Indexes
		While (!F6T->(EOF()) .AND. F6T->F6T_CODQRY == cCodQuery)
			//Add in Cols
			AAdd(aReturn, {F6T->F6T_ORDER, F6T->F6T_DESCRI, F6T->F6T_KEY, .F.})
			F6T->(DBSkip())
		EndDo
	Else
		AAdd(aReturn, {"", "", "", .F.})
	EndIf

Return aReturn

/*/{Protheus.doc} RUF6VStore
Store informations in Table F6V

@type function
@author Alison Kaique
@since Apr|2019
/*/
Static Function RUF6VStore()
	Local aGetCols  := AClone(oGetData:aCols)
	Local aGetHead  := AClone(oGetData:aHeader)
	Local nPosOrder := GDFieldPos("ORDER"      , aGetHead) //Position of Field ORDER
	Local nPosDescr := GDFieldPos("DESCRIPTION", aGetHead) //Position of Field DESCRIPTION
	Local nPosKey   := GDFieldPos("KEY"        , aGetHead) //Position of Field KEY
	Local nI        := 0
	Local lStore    := MsgYesNo(STR0003) //Do you want store this informations?
	Local lFound    := .T. //Found register ?

	If lStore
		//Verify Fields Positions
		If (nPosOrder > 0 .AND. nPosDescr > 0 .AND. nPosKey > 0)
			F6T->(DBSetOrder(01)) //F6T_FILIAL+F6T_CODQRY+F6T_ORDER

			Begin Transaction

			//Loop Deleted Indexes
			For nI := 01 To Len(aDelIndex)
				//Deleting
				F6T->(DBGoTo(aDelIndex[nI]))
				If (F6T->(Recno()) == aDelIndex[nI])
					If (RecLock("F6T", .F.))
						F6T->(DBDelete())
						F6T->(MsUnlock())
					EndIf
				EndIf
			Next nI

			If ((Len(aGetCols) == 01 .AND. !Empty(aGetCols[01, nPosOrder])) .OR. Len(aGetCols) > 01)
				//If Deleted Indexes, delete all others .. because the Order is changed
				If (Len(aDelIndex) > 0)
					If (F6T->(DBSeek(FWxFilial("F6T") + cCodQuery)))
						While (!F6T->(EOF()) .AND. F6T->F6T_CODQRY == cCodQuery)
							If (RecLock("F6T", .F.))
								F6T->(DBDelete())
								F6T->(MsUnlock())
							EndIf
							F6T->(DBSkip())
						EndDo
					EndIf
				EndIf

				//Loop Indexes
				For nI := 01 To Len(aGetCols)
					oGetData:GoTo(nI) //Go to Line
					//Verify Empty Values
					If !(RUX99LOK())
						DisarmTransaction()
						lStore := .F.
						Exit
					EndIf
					//Store Informations
					lFound := F6T->(DBSeek(FWxFilial("F6T") + cCodQuery + aGetCols[nI, nPosOrder]))
					If (RecLock("F6T", !lFound))
						F6T->F6T_FILIAL := FWxFilial("F6T")
						F6T->F6T_CODQRY := cCodQuery
						F6T->F6T_ORDER  := aGetCols[nI, nPosOrder]
						F6T->F6T_DESCRI := aGetCols[nI, nPosDescr]
						F6T->F6T_KEY    := aGetCols[nI, nPosKey]
						F6T->(MsUnlock())
					EndIf
				Next nI
			ElseIf (Len(aGetCols) == 01 .AND. Empty(aGetCols[01, nPosOrder])) //Delete All
				If (F6T->(DBSeek(FWxFilial("F6T") + cCodQuery)))
					While (!F6T->(EOF()) .AND. F6T->F6T_CODQRY == cCodQuery)
						If (RecLock("F6T", .F.))
							F6T->(DBDelete())
							F6T->(MsUnlock())
						EndIf
						F6T->(DBSkip())
					EndDo
				EndIf
			EndIf

			End Transaction
		EndIf
	EndIf //lStore

	//Close Dialog
	If (lStore)
		oDlg:End()
	EndIf
Return

/*/{Protheus.doc} RUDblClick
Double Click Function for SubQuery

@type function
@author Alison Kaique
@since Apr|2019
/*/
Static Function RUDblClick()
	RUAction(MODEL_OPERATION_VIEW)
Return

/*/{Protheus.doc} RUIndex
Compose Index according Fields in Query

@type function
@author Alison Kaique
@since Apr|2019
@param nOper  , numeric  , Operation
@param cOrder , character, Order of Index
@param cDescr , character, Description
@param cKey   , character, Key (Fields)
@param aStruct, array    , Struct of Query

@return array [01] - lIXUpdate, logical  , Process Control
			  [02] - cKey     , character, Key composed
			  [03] - cDescr   , character, Description
/*/
Function RUIndex(nOper, cOrder, cDescr, cKey, aStruct)
	Local oDlg      := Nil
	Local oEnchoice := Nil
	Local cTitle    := ""
	Local cType     := ""
	Local nI        := 0
	Local aFld      := {}
	Local aFldTitle := {}
	Local aInfo     := {}
	Local aButton   := {}
	Local xVar      := Nil
	Local lIXUpdate := .F.
	Local cField    := ""
	Local aStru     := {}

	//Compose arrays aFld and aFldTitle
	For nI := 01 To Len(aStruct)
		AAdd(aFldTitle, aStruct[nI, 01])
		AAdd(aFld     , {aStruct[nI, 02], aStruct[nI, 01]})
	Next nI

	If nOper == MODEL_OPERATION_VIEW
		cTitle := STR0017 + cDescr	//"View Index: "
	ElseIf nOper == MODEL_OPERATION_INSERT
		cTitle := STR0018	//"New Index"
		cDescr := STR0018	//"New Index"
	ElseIf nOper == MODEL_OPERATION_UPDATE
		cTitle := STR0019 + cDescr	//"Edit Index: "
	ElseIf nOper == MODEL_OPERATION_DELETE
		cTitle := STR0020 + cDescr	//"Delete Index: "
	EndIf

	If nOper == MODEL_OPERATION_INSERT .OR. nOper == MODEL_OPERATION_UPDATE
		AAdd(aButton, {"RPMCPO", {|| RUIndexExp(aFld, aFldTitle), oEnchoice:Refresh()}, STR0011, STR0012})	//"Consult Fields" # "Fields"
	EndIf

	ADD FIELD aInfo	TITULO STR0015 CAMPO "CHAVE" TIPO "C" TAMANHO 160 DECIMAL 0 PICTURE "@!" VALID RUVldKey(aStruct) OBRIGAT NIVEL 1	//"Key"

	ADD FIELD aInfo	TITULO STR0014 CAMPO "DESCENG" TIPO "C" TAMANHO 70 DECIMAL 0 OBRIGAT NIVEL 1	//"Description"

	DbSelectArea("SIX")
	aStru := SIX->(DbStruct())
	For nI := 01 To Len(aStru)
		xVar := FieldGet(nI)
		cField := aStru[nI, 01]
		If nOper == MODEL_OPERATION_INSERT
			cType := ValType(xVar)
			If cType $ "CM"
				xVar := Space(Len(xVar))
			ElseIf cType == "N"
				xVar := 0
			ElseIf cType == "D"
				xVar := Ctod("")
			ElseIf cType == "L"
				xVar := .F.
			EndIf
		Else
			nPos := SIX->(FieldPos(cField))
			If nPos > 0
				If (AllTrim(cField) == "CHAVE")
					xVar := PadR(cKey, Len(xVar))
				ElseIf (AllTrim(cField) == "DESCENG")
					xVar := PadR(cDescr, Len(xVar))
				EndIf
			EndIf
		EndIf
		&("M->" + Field(nI)) := xVar
	Next nI

	DEFINE MSDIALOG oDlg TITLE cTitle FROM 0,0 TO 200,450 PIXEL

		oEnchoice := MsmGet():New("SIX", , nOper, , , , , {13,0,__DlgHeight(oDlg),__DlgWidth(oDlg)}, , , , , , oDlg, , , .T., , , , aInfo)
		oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(oEnchoice:aGets,oEnchoice:aTela),(lIXUpdate := .T.,oDlg:End()),)},;
	{|| oDlg:End()},,aButton)

Return {(lIXUpdate .AND. !(nOper == MODEL_OPERATION_VIEW)), AllTrim(M->CHAVE), AllTrim(M->DESCENG)}

/*/{Protheus.doc} RUIndexExp
Show Dialog to compose index

@type function
@author Alison Kaique
@since Apr|2019
@param aFld     , array, Field's Name
@param aFldTitle, array, Field's Title
/*/
Static Function RUIndexExp(aFld, aFldTitle)
	Local nPos

	nPos := MDConPad(aFldTitle, STR0011, .T.)	//"Consult Fields"
	If nPos > 0
		M->DESCENG := PadR(IIf(Empty(M->DESCENG), aFldTitle[nPos], Trim(M->DESCENG) + "+" + aFldTitle[nPos]), Len(M->DESCENG))
		M->CHAVE   := PadR(IIf(Empty(M->CHAVE), aFld[nPos, 01], Trim(M->CHAVE) + "+" + aFld[nPos, 01]), Len(M->CHAVE))
	EndIf
Return

/*/{Protheus.doc} RUVldKey
Validation of Key

@type function
@author Alison Kaique
@since Apr|2019
@param aStruct, array, Struct according Query

@return lRet, logical, Process Control
/*/
Static Function RUVldKey(aStruct)
	Local nI
	Local nAt1
	Local aKey := StrTokArr(M->CHAVE,"+")
	Local lRet := .T.

	If "++" $ M->CHAVE
		MsgStop(STR0016) //"Type correctly the Key"
		lRet := .F.
	Else
		For nI := 1 To Len(aKey)
			If Empty(aKey[nI])
				MsgStop(STR0016) //"Type correctly the Key"
				lRet := .F.
				Exit
			Else
				aKey[nI] := AllTrim(aKey[nI])
				If ( '(' $ aKey[nI] )
					nAt1 := At('(', aKey[nI] )
					While ( nAt1 > 0 )
						aKey[nI]	:= Subs( aKey[nI], nAt1 + 1 )
						nAt1	:= At('(', aKey[nI] )
					End

					nAt1 := At(',', aKey[nI] )

					If ( nAt1 > 0 )
						aKey[nI] := Subs( aKey[nI], 1, nAt1 - 1 )
					EndIf

					nAt1 := At(')', aKey[nI] )

					If ( nAt1 > 0 )
						aKey[nI] := Subs( aKey[nI], 1, nAt1 - 1 )
					EndIf
				EndIf

				If ( '->' $ aKey[nI] )
					aKey[nI] := Subs(aKey[nI],At('->',aKey[nI])+2)
				EndIf

				//Verify if Field containg in Query (in cases of Group By and SUM for example)
				If (AScan(aStruct, {|x| AllTrim(x[02]) == AllTrim(aKey[nI])}) == 0)
					MsgStop(STR0016) //"Type correctly the Key"
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next
	EndIf
Return lRet

/*/{Protheus.doc} RUX99LOK
LineOK Function

@type function
@author Alison Kaique
@since Apr|2019

@return lReturn, logical, Process Control
/*/
Function RUX99LOK()
	Local lReturn   := .T.
	Local nLine     := oGetData:nAt
	Local aGetHead  := oGetData:aHeader //aHeader according GetData
	Local nPosOrder := GDFieldPos("ORDER"      , aGetHead) //Position of Field ORDER
	Local nPosDescr := GDFieldPos("DESCRIPTION", aGetHead) //Position of Field DESCRIPTION
	Local nPosKey   := GDFieldPos("KEY"        , aGetHead) //Position of Field KEY

	//Verify Fields Positions
	If (nPosOrder > 0 .AND. nPosDescr > 0 .AND. nPosKey > 0)
		//Verify if all fields was filled
		If (Empty(oGetData:aCols[nLine, nPosOrder]) .OR. Empty(oGetData:aCols[nLine, nPosDescr]) .OR. Empty(oGetData:aCols[nLine, nPosKey]))
			Help(" ", 1, "RUX99LOK", , STR0021, 4, 15) //All Fields must be filled!
			lReturn := .F.
		EndIf
	EndIf
Return lReturn

/*/{Protheus.doc} RUOrder
Reordering...

@type function
@author Alison Kaique
@since Apr|2019
/*/
Static Function RUOrder()
	Local aNewCols  := {} //New aCols
	Local aGetHead  := oGetData:aHeader //aHeader according GetData
	Local nI        := 0 //Loop Control
	Local nPosOrder := GDFieldPos("ORDER", aGetHead) //Position of Field KEY
	Local cOrder    := "0"

	//Verify Field Position
	If (nPosOrder > 0)
		//Loop aCols
		For nI := 01 To Len(oGetData:aCols)
			//Verify isn't deleted
			If !(oGetData:aCols[nI, Len(aGetHead) + 01])
				AAdd(aNewCols, AClone(oGetData:aCols[nI]))
				//Compose Order
				cOrder := Soma1(cOrder)
				aNewCols[Len(aNewCols), nPosOrder] := cOrder
			Else
				//Including in Deleted Array
				If (F6T->(DBSeek(FWxFilial("F6T") + cCodQuery + oGetData:aCols[nI, nPosOrder])))
					AAdd(aDelIndex, F6T->(Recno()))
				EndIf
			EndIf
		Next nI
		//Create Empty Array
		If (Len(aNewCols) == 0)
			AAdd(aNewCols, {"", "", "", .F.})
		EndIf
		//Set Array
		oGetData:SetArray(aNewCols, .T.)
	EndIf
Return

/*/{Protheus.doc} RUExistKey
Verify if Key already exists in aCols

@type function
@author Alison Kaique
@since Apr|2019

@return lReturn, logical, Process Control
/*/
Static Function RUExistKey(cKey, nLine)
	Local lReturn  := .F. //Process Control
	Local aGetCols := oGetData:aCols //aCols
	Local aGetHead := oGetData:aHeader //aHeader according GetData
	Local nPosKey  := GDFieldPos("KEY", aGetHead) //Position of Field KEY
	Local nPos     := 0 //Position to verify

	Default nLine := 0 //Currently Line

	If (nPosKey > 0)
		//Get Position
		nPos := AScan(aGetCols, {|x| AllTrim(x[nPosKey]) == AllTrim(cKey)})
		If (nPos > 0 .AND. !(nPos == nLine))
			Help(" ", 1, "RUExistKey", , STR0023 + AllTrim(cKey) + STR0024 + cValToChar(nPos), 4, 15) //Already exists Key: [#], in Line: "
			lReturn := .T.
		EndIf
	EndIf

Return lReturn