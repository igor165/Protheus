#include "protheus.ch"
#include "Constant.ch"
#include "Colors.ch"

#define COLOR_WINDOW              5
#define COLOR_WINDOWTEXT          8
#define COLOR_BTNFACE            15
#define COLOR_BTNSHADOW          16
#define COLOR_BTNHIGHLIGHT  20
#define FD_BORDER                         8
#define FD_HEIGHT                        22
#define DT_CENTER                         1
#define DT_VCENTER                        4
#define WINDING                           2
#define SC_KEYMENU               61696  // 0xF100
#define TCM_FIRST                 4864  // 0x1300
#define TCM_SETBKCOLOR    4865
#define TCM_GETITEMCOUNT  4868

CLASS TQPages FROM TControl

	CLASSDATA lRegistered AS LOGICAL

	DATA     nOption
	DATA     aDialogs
	DATA     aActive

	METHOD New( nTop, nLeft, nBottom, nRight, oWnd, aDialogs, nOption, bChange, aActive, oFont ) CONSTRUCTOR

	METHOD Default()

	METHOD SetOption( nOption )

	METHOD GoPrev( oBtn1, oBtn2, oDlg )

	METHOD GoNext( oBtn1, oBtn2, oDlg )
						
	METHOD GotFocus()
	
	METHOD ChangeCap( oBtn1, oBtn2 )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nBottom, nRight, oWnd, aDialogs, nOption, bChange, aActive, oFont ) CLASS TQPages
:New( oWnd , NIL )

	Local n := 1
	Local oDlg
	Local nLoop := 1

	DEFAULT nTop := 0, nLeft := 0, nBottom := 100, nRight := 100,;
			  oWnd := GetWndDefault(),aDialogs := {},nOption := 1,;
			  bChange := {|| Nil }, aActive := {}

	::nTop    = nTop
	::nLeft   = nLeft
	::nBottom  = nBottom
	::nRight   = nRight
	::SetColor( 0,GetSysColor( COLOR_BTNFACE ) )
	::aDialogs = Array(Len(aDialogs))
	::aActive  = Aclone(aActive)
	::nOption  = nOption
	::bChange  = bChange
	::oFont   = oWnd:oFont
	
	If Len(::aActive) == 0
		::aActive  = Array(Len(::aDialogs))
		For nLoop := 1 To Len(::aActive)
			::aActive[nLoop] := .T.
		Next nLoop
	Else
		If Len(::aActive) == Len(::aDialogs)
			For nLoop := 1 To Len(::aActive)
				If ValType(::aActive[nLoop]) <> "L"
					::aActive  = Array(Len(::aDialogs))
					For nLoop := 1 To Len(::aActive)
						::aActive[nLoop] := .T.
					Next nLoop
					Exit                                    
				EndIf
			Next nLoop
		Else
			::aActive  = Array(Len(::aDialogs))
			For nLoop := 1 To Len(::aActive)
				::aActive[nLoop] := .T.
			Next nLoop
		EndIf
	EndIf
	
	for n = 1 to Len( aDialogs )
		oDlg := tPanel():New( nTop*2, nLeft, "", oWnd, oWnd:oFont, .F., .F., 0,GetSysColor( COLOR_BTNFACE ), nRight * 2, nBottom * 2,.F.,.F.)
		::aDialogs[ n ] := oDlg
		oDlg:Hide()
	next n

	::Default()

return nil

//----------------------------------------------------------------------------//

METHOD Default() CLASS TQPages

	Local nProx := ::nOption

	if Len( ::aDialogs ) > 0
		if ::nOption <= Len( ::aDialogs )
			While .T.
				If nProx <= Len(::aDialogs)
					If ::aActive[ nProx ]
						::aDialogs[ nProx ]:Show()
						::aDialogs[ nProx ]:Refresh()
						::nOption := nProx
						Exit
					EndIf
					nProx ++
				Else
					Exit
				EndIf
			EndDo
		endif
	endif
	
return nil

//----------------------------------------------------------------------------//

METHOD GotFocus() CLASS TQPages

	Super:GotFocus()

	if ::nOption <= Len( ::aDialogs )
		::aDialogs[ ::nOption ]:SetFocus()
		::aDialogs[ ::nOption ]:Refresh()
	endif

return 0

//----------------------------------------------------------------------------//

METHOD SetOption( nOption ) CLASS TQPages

	local nOldOption

	if nOption > 0 .and. nOption != ::nOption
		if ::nOption <= Len( ::aDialogs ) .and. ::aDialogs[ ::nOption ] != nil
			::aDialogs[ ::nOption ]:Hide()
			::aDialogs[ nOption ]:Refresh()			
		endif
		nOldOption = ::nOption
		::nOption  = nOption
		if nOption <= Len( ::aDialogs ) .and. ::aDialogs[ nOption ] != nil
			if ::bChange != nil
				Eval( ::bChange, nOption, nOldOption )
			endif
			::aDialogs[ nOption ]:Show()
			::aDialogs[ nOption ]:SetFocus()
			::aDialogs[ nOption ]:Refresh()
		endif
	endif

return nil

//----------------------------------------------------------------------------//

METHOD GoNext( oBtn1, oBtn2, oDlg ) CLASS TQPages

	Local nProx := 1
	Local lRet      := .F.
	Local nLoop := 0

	If ::nOption == Len(::aDialogs)
		lRet := .T.
	Else
		For nLoop := ::nOption To Len(::aDialogs)
			If ::aActive[nLoop]
				lRet := .F.
			Else
				lRet := .T.
			EndIf
		Next nLoop
	EndIf

	While .T.
		If ::nOption < Len( ::aDialogs )
			If ( ::nOption + nProx ) <= Len( ::aDialogs )
				If ::aActive[::nOption + nProx]
					::SetOption( ::nOption + nProx )
					::ChangeCap( oBtn1, oBtn2 )
					Exit
				EndIf
				nProx++
			Else
				If oDlg <> Nil
					::ChangeCap( oBtn1, oBtn2 )
					oDlg:End()
				EndIf
				Exit
			Endif
		Else
			If oDlg <> Nil
				::ChangeCap( oBtn1, oBtn2 )
				oDlg:End()
			EndIf
			Exit
		Endif
	EndDo

	If oBtn1 <> NIL
		oBtn1:Refresh()
	Endif
	If oBtn2 <> NIL
		oBtn1:Refresh()
	Endif

Return lRet

//----------------------------------------------------------------------------//

METHOD GoPrev( oBtn1, oBtn2, oDlg ) CLASS TQPages

	Local nPrev := 1

	While .T.
		If ::nOption > 1
			If ( ::nOption - nPrev ) > 0
				If ::aActive[::nOption - nPrev]
					::SetOption( ::nOption - nPrev )
					::ChangeCap( oBtn1, oBtn2 )
					Exit
				EndIf
				nPrev++
			Else
				If oDlg <> Nil
					::ChangeCap( oBtn1, oBtn2 )
					oDlg:End()
				EndIf
				Exit
			EndIf
		Else
			If oDlg <> Nil
				::ChangeCap( oBtn1, oBtn2 )
				oDlg:End()
			EndIf
			Exit
		Endif
	EndDo
	
	If oBtn1 <> NIL
		oBtn1:Refresh()
	Endif
	If oBtn2 <> NIL
		oBtn1:Refresh()
	Endif

Return Nil

//----------------------------------------------------------------------------//

METHOD ChangeCap( oBtn1, oBtn2 ) CLASS TQPages

Local nTotal := Len(::aDialogs)
Local nLoop  := 0

If oBtn1 <> Nil .And. oBtn2 <> Nil

	oBtn1:cTitle := "&Cancelar"
	oBtn2:cTitle := "&Concluir"

	If ::nOption == 1
		If nTotal > 1
			For nLoop := 2 To nTotal
				If ::aActive[nLoop]
					oBtn1:cTitle := "&Cancelar"
					oBtn2:cTitle := "&Avancar >>"
					Exit
				Else
					oBtn1:cTitle := "&Cancelar"
					oBtn2:cTitle := "&Concluir"
				EndIf
			Next nLoop
		Else
			oBtn1:cTitle := "C&ancelar"
			oBtn2:cTitle := "&Concluir"
		EndIf
	Else
		For nLoop := ::nOption - 1 To 1 Step - 1
			If ::aActive[nLoop]
				oBtn1:cTitle := "<< &Voltar"
				Exit
			Else
				oBtn1:cTitle := "&Cancelar"
			EndIf
		Next nLoop

		For nLoop := ::nOption + 1 To nTotal
			If ::aActive[nLoop]
				oBtn2:cTitle := "&Avancar >>"
				Exit
			Else
				oBtn2:cTitle := "&Concluir"
			EndIf
		Next nLoop

	EndIf

	oBtn1:Refresh()
	oBtn2:Refresh()

EndIf

Return Nil