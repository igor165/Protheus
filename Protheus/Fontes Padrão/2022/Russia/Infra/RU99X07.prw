#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "FwMvcDef.ch"
#include "RU99X07.CH"

/*/{Protheus.doc} RU99X07
Routine responsible to manage User Access in Managerial Views

@type function
@author Alison Kaique
@since Apr|2019
/*/
Function RU99X07()
	Local aSize  := FWGetDialogSize(oMainWnd)
	Local cTitle := STR0001 //"Views x User Access"
	Local bOk    := {|| RUF6UStore() }
	Local bClose := {|| oDlg:End() }
	Local oArea  := Nil

	Private oDlg         := Nil
	Private cViewCode  := F6Q->F6Q_CODVIS
	Private cViewTitle := F6Q->F6Q_TITULO
	Private oGetData     := Nil
	Private cCadastro    := STR0002 + Alltrim(cViewCode) + " - " + Alltrim(cViewTitle) //View x User Access referring to:

	ChkFile("F6U")

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
@since Apr|2019
@param oPanelPar, object, Panel's Object
/*/
Static Function RU01Panel(oPanelPar)
	Local aHeadScreen := {}
	Local aHeadAux    := {}
	Local aColsScreen := {}

	//Header Array
	Aadd(aHeadAux,{, "F6U_CODUSR"})
	Aadd(aHeadAux,{, "F6U_NOMUSR"})
	Aadd(aHeadAux,{, "F6U_ATIVO"})

	aHeadScreen	:= RUHeader(aHeadAux)
	aColsScreen	:= RUCols(aHeadScreen)

	oGetData := MsNewGetDados():New(0, 0, 0, 0, GD_INSERT+GD_UPDATE+GD_DELETE,,,, Nil, 0, 99,,,, oPanelPar, aHeadScreen, aColsScreen)
	oGetData:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
Return

/*/{Protheus.doc} RUHeader
Header Definitions

@type function
@author Alison Kaique
@since Apr|2019
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
@since Apr|2019
@param aHeadPar, array, Header Fields
@return aReturn, array, Data According Table F6U
/*/
Static Function RUCols(aHeadPar)
	Local aReturn := {}
	Local ii      := 1
	Local aAuxRet := {}

	F6U->(DBSetOrder(1)) //F6U_FILIAL + F6U_CODVIS
	If F6U->(dbSeek(FWxFilial("F6U") + F6Q->F6Q_CODVIS))
		While F6U->(!EOF()) .AND. F6U->F6U_CODVIS == F6Q->F6Q_CODVIS
			aAuxRet := {}
			For ii := 1 To Len(aHeadPar)
				SX3->(DBSetOrder(2)) //X3_CAMPO
				If SX3->(dbSeek(aHeadPar[ii][2]))
					If SX3->X3_CONTEXTO <> "V"
						cCampoF6U := "F6U->" + aHeadPar[ii][2]
						Aadd(aAuxRet, &(cCampoF6U))
					Else
						Aadd(aAuxRet, &(SX3->X3_RELACAO))
					EndIf
				EndIf
			Next ii
			Aadd(aAuxRet, .F.)
			Aadd(aReturn, ACLONE(aAuxRet))
			F6U->(dbSkip())
		EndDo
	Else
		For ii := 1 To Len(aHeadPar)
			SX3->(DBSetOrder(2)) //X3_CAMPO
			If SX3->(dbSeek(aHeadPar[ii][2]))
				cCampoF6U := aHeadPar[ii][2]
				Aadd(aAuxRet, CriaVar(cCampoF6U, .T.))
			EndIf
		Next ii
		Aadd(aAuxRet, .F.)
		Aadd(aReturn, ACLONE(aAuxRet))
	EndIf
Return aReturn

/*/{Protheus.doc} RUF6UStore
Store informations in Table F6U

@type function
@author Alison Kaique
@since Apr|2019
/*/
Static Function RUF6UStore()
	Local aStoreCols := ACLONE(oGetData:ACOLS)
	Local aStoreHead := ACLONE(oGetData:AHEADER)
	Local ii         := 0
	Local jj         := 0
	Local lStore     := MsgYesNo(STR0003) //"Do you want store this informations?"
	Local nPosCodUsr := AScan(aStoreHead, {|x| Alltrim(x[02]) == "F6U_CODUSR"})

	lValidated := RUValidate()

	If lStore .AND. lValidated .AND. nPosCodUsr > 0
		F6U->(DBSetOrder(1)) //F6U_FILIAL + F6U_CODVIS + F6U_CODUSR

		For jj := 1 To Len(aStoreCols)
			lFound := F6U->(dbSeek(FWxFilial("F6U") + cViewCode + aStoreCols[jj, nPosCodUsr]))

			If aStoreCols[jj][Len(aStoreHead)+1] == .F.
				If RecLock("F6U", !lFound)
					F6U->F6U_FILIAL := FWxFilial("F6U")
					F6U->F6U_CODVIS := cViewCode
					For ii := 1 To Len(aStoreHead)
						cF6UCampo := aStoreHead[ii][2]
						SX3->(DBSetOrder(2)) //X3_CAMPO
						If SX3->(dbSeek(cF6UCampo))
							If SX3->X3_CONTEXT <> "V"
								cCpoReal := "F6U->" + cF6UCampo
								&(cCpoReal) := aStoreCols[jj][ii]
							EndIf
						EndIf
					Next ii
					F6U->(MsUnlock())
				EndIf
			Else
				If lFound .AND. RecLock("F6U", .F.)
					F6U->(dbDelete())
					F6U->(MsUnlock())
				EndIf
			EndIf
		Next jj

		oDlg:End()
	EndIf
Return

/*/{Protheus.doc} RUValidate
Validate informations before store in table F6U

@type function
@author Alison Kaique
@since Apr|2019
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

	//Verify duplicated users
	If lReturn
		nPosUsr := aScan(aHeadScreen, { |x| Alltrim(Upper(x[2])) == Alltrim(Upper("F6U_CODUSR")) })
		For ii := 1 To Len(aColsScreen)
			If aColsScreen[ii][Len(aHeadScreen)+1] == .F.
				cUsuAtu := aColsScreen[ii][nPosUsr]
				For jj := 1 To Len(aColsScreen)
					If aColsScreen[jj][Len(aHeadScreen)+1] == .F.
						If ii <> jj
							If cUsuAtu == aColsScreen[jj][nPosUsr]
								cMsgScreen := ""
								cMsgScreen += STR0004 + StrZero(jj, 3) + CRLF //Line:
								cMsgScreen += STR0008 + cUsuAtu + CRLF //User:
								cMsgScreen += STR0009 //Duplicated User!
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