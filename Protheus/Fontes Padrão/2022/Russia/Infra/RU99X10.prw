#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "FwMvcDef.ch"
#include "RU99X10.CH"

/*/{Protheus.doc} RU99X10
Routine responsible to manage Users Group Access in Managerial Views

@type function
@author Alison Kaique
@since May|2019
/*/
Function RU99X10()
	Local aSize  := FWGetDialogSize(oMainWnd)
	Local cTitle := STR0001 //"Views x Users Group Access"
	Local bOk    := {|| RUF6VStore() }
	Local bClose := {|| oDlg:End() }
	Local oArea  := Nil

	Private oDlg       := Nil
	Private cViewCode  := F6Q->F6Q_CODVIS
	Private cViewTitle := F6Q->F6Q_TITULO
	Private oGetData   := Nil
	Private cCadastro  := STR0002 + Alltrim(cViewCode) + " - " + Alltrim(cViewTitle) //View x Users Group Access referring to:

	ChkFile("F6V")

	oDlg := MsDialog():New(aSize[1], aSize[2], aSize[3], aSize[4], cTitle,,,, nOr(WS_VISIBLE, WS_POPUP),,,,, .T.,,,, .F.)

	oLayer := FWLayer():New()
	oLayer:Init(oDlg, .T.)
	oLayer:AddLine("LINE01", 90)
	oLayer:AddCollumn("BOX01", 100,, "LINE01")
	oLayer:AddWindow("BOX01", "PANEL01",	cCadastro, 100, .F.,,, "LINE01")

	RU01Panel(oLayer:GetWinPanel("BOX01", "PANEL01", "LINE01"))

	oDlg:bInit := EnchoiceBar(oDlg,bOk, bClose,,)
	oDlg:Activate()
Return

/*/{Protheus.doc} RU01Panel
Creation of GetDados

@type function
@author Alison Kaique
@since May|2019
@param oPanelPar, object, Panel's Object
/*/
Static Function RU01Panel(oPanelPar)
	Local aHeadScreen := {}
	Local aHeadAux    := {}
	Local aColsScreen := {}

	//Header Array
	Aadd(aHeadAux,{, "F6V_CODGRP"})
	Aadd(aHeadAux,{, "F6V_NOMGRP"})
	Aadd(aHeadAux,{, "F6V_ATIVO"})

	aHeadScreen	:= RUHeader(aHeadAux)
	aColsScreen	:= RUCols(aHeadScreen)

	oGetData := MsNewGetDados():New(0, 0, 0, 0, GD_INSERT+GD_UPDATE+GD_DELETE,,,, Nil, 0, 99,,,, oPanelPar, aHeadScreen, aColsScreen)
	oGetData:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
Return

/*/{Protheus.doc} RUHeader
Header Definitions

@type function
@author Alison Kaique
@since May|2019
@param aHeadPar, array, Header Fields
@return aReturn, array, Final Header
/*/
Static Function RUHeader(aHeadPar)
	Local aReturn := {}
	Local ii      := 01
	Local aAuxRet := {}

	For ii := 1 To Len(aHeadPar)
		SX3->(DBSetOrder(2)) //X3_CAMPO
		If SX3->(dbSeek(aHeadPar[ii][2]))
			If X3USO(SX3->X3_USADO)
				aAuxRet := {}
				Aadd(aAuxRet, X3Titulo())
				Aadd(aAuxRet, SX3->X3_CAMPO)
				Aadd(aAuxRet, SX3->X3_PICTURE)
				Aadd(aAuxRet, SX3->X3_TAMANHO)
				Aadd(aAuxRet, SX3->X3_DECIMAL)
				Aadd(aAuxRet, SX3->X3_VALID)
				Aadd(aAuxRet, SX3->X3_USADO)
				Aadd(aAuxRet, SX3->X3_TIPO)
				Aadd(aAuxRet, SX3->X3_F3)
				Aadd(aAuxRet, SX3->X3_CONTEXT)

				Aadd(aReturn, ACLONE(aAuxRet))
			EndIf
		EndIf
	Next ii
Return aReturn

/*/{Protheus.doc} RUCols
Columns Definitions

@type function
@author Alison Kaique
@since May|2019
@param aHeadPar, array, Header Fields
@return aReturn, array, Data According Table F6V
/*/
Static Function RUCols(aHeadPar)
	Local aReturn := {}
	Local ii      := 1
	Local aAuxRet := {}

	F6V->(DBSetOrder(1)) //F6V_FILIAL + F6V_CODVIS
	If F6V->(dbSeek(FWxFilial("F6V") + F6Q->F6Q_CODVIS))
		While F6V->(!EOF()) .AND. F6V->F6V_CODVIS == F6Q->F6Q_CODVIS
			aAuxRet := {}
			For ii := 1 To Len(aHeadPar)
				SX3->(DBSetOrder(2)) //X3_CAMPO
				If SX3->(dbSeek(aHeadPar[ii][2]))
					If SX3->X3_CONTEXTO <> "V"
						cCampoF6V := "F6V->" + aHeadPar[ii][2]
						Aadd(aAuxRet, &(cCampoF6V))
					Else
						Aadd(aAuxRet, &(SX3->X3_RELACAO))
					EndIf
				EndIf
			Next ii
			Aadd(aAuxRet, .F.)
			Aadd(aReturn, ACLONE(aAuxRet))
			F6V->(dbSkip())
		EndDo
	EndIf
Return aReturn

/*/{Protheus.doc} RUF6VStore
Store informations in Table F6V

@type function
@author Alison Kaique
@since May|2019
/*/
Static Function RUF6VStore()
	Local aStoreCols := ACLONE(oGetData:ACOLS)
	Local aStoreHead := ACLONE(oGetData:AHEADER)
	Local ii         := 0
	Local jj         := 0
	Local lStore     := MsgYesNo(STR0003) //"Do you want store this informations?"
	Local nPosCodGRP := AScan(aStoreHead, {|x| Alltrim(x[02]) == "F6V_CODGRP"})

	lValidated := RUValidate()

	If lStore .AND. lValidated .AND. nPosCodGRP > 0
		F6V->(DBSetOrder(1)) //F6V_FILIAL + F6V_CODVIS + F6V_CODGRP

		For jj := 1 To Len(aStoreCols)
			lFound := F6V->(dbSeek(FWxFilial("F6V") + cViewCode + aStoreCols[jj, nPosCodGRP]))

			If aStoreCols[jj][Len(aStoreHead)+1] == .F.
				If RecLock("F6V", !lFound)
					F6V->F6V_FILIAL := FWxFilial("F6V")
					F6V->F6V_CODVIS := cViewCode
					For ii := 1 To Len(aStoreHead)
						cF6VCampo := aStoreHead[ii][2]
						SX3->(DBSetOrder(2)) //X3_CAMPO
						If SX3->(dbSeek(cF6VCampo))
							If SX3->X3_CONTEXT <> "V"
								cCpoReal := "F6V->" + cF6VCampo
								&(cCpoReal) := aStoreCols[jj][ii]
							EndIf
						EndIf
					Next ii
					F6V->(MsUnlock())
				EndIf
			Else
				If lFound .AND. RecLock("F6V", .F.)
					F6V->(dbDelete())
					F6V->(MsUnlock())
				EndIf
			EndIf
		Next jj

		oDlg:End()
	EndIf
Return

/*/{Protheus.doc} RUValidate
Validate informations before store in table F6V

@type function
@author Alison Kaique
@since May|2019
@return lReturn, logical, Validation Return
/*/
Static Function RUValidate()
	Local ii			:= 1
	Local jj			:= 1
	Local aColsScreen	:= ACLONE(oGetData:ACOLS)
	Local aHeadScreen	:= ACLONE(oGetData:AHEADER)
	Local lReturn	    := .T.

	//Verify if any mandatory field is empty
	lReturn := .T.
	For ii := 1 To Len(aColsScreen)
		If aColsScreen[ii][Len(aHeadScreen)+1] == .F.
			For jj := 1 To Len(aHeadScreen)
				If Empty(aColsScreen[ii][jj])
					cMsgScreen := ""
					cMsgScreen += STR0004 + StrZero(ii, 3) + CRLF //Line:
					cMsgScreen += STR0005 + aHeadScreen[jj][1] + CRLF //Field:
					cMsgScreen += STR0006 //Must be filled!
					Aviso("RUValidate", cMsgScreen, {STR0007}) //Close
					lReturn := .F.
					Exit
				EndIf
			Next jj
		EndIf
	Next ii

	//Verify duplicated Users Group
	If lReturn
		nPosGRP := aScan(aHeadScreen, { |x| Alltrim(Upper(x[2])) == Alltrim(Upper("F6V_CODGRP")) })
		For ii := 1 To Len(aColsScreen)
			If aColsScreen[ii][Len(aHeadScreen)+1] == .F.
				cUsuAtu := aColsScreen[ii][nPosGRP]
				For jj := 1 To Len(aColsScreen)
					If aColsScreen[jj][Len(aHeadScreen)+1] == .F.
						If ii <> jj
							If cUsuAtu == aColsScreen[jj][nPosGRP]
								cMsgScreen := ""
								cMsgScreen += STR0004 + StrZero(jj, 3) + CRLF //Line:
								cMsgScreen += STR0008 + cUsuAtu + CRLF //Users Group:
								cMsgScreen += STR0009 //Duplicated Users Group!
								Aviso("RUValidate", cMsgScreen, {STR0007}) //Close
								lReturn := .F.
								Exit
							EndIf
						EndIf
					EndIf
				Next jj

				If !lReturn
					Exit
				EndIf

			EndIf
		Next ii
	EndIf
Return lReturn

Function GetF6VGroup(cGroupCode)
	Local aArea      := GetArea() //Save Area
	Local aGroupsF6V := AllGroups() //All Users Group
	Local nPos       := 0 //Position in Array
	Local cGroupName := "" //Group Name

	//Seek Group Code in Array
	nPos := AScan(aGroupsF6V, {|x| Alltrim(x[01, 01]) == Alltrim(cGroupCode)})

	//Return Information
	If (nPos > 0)
		cGroupName := Left(aGroupsF6V[nPos][01, 03], TamSX3("F6V_NOMGRP")[01])
	EndIf

	RestArea(aArea) //Restoring Area
Return cGroupName