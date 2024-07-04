#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TJurCmbBox
CLASS TJurCmbBox

@author Felipe Bonvicini Conti
@since 16/09/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function __JurCmbBox() // Function Dummy
ApMsgInfo( 'JurCmbBox -> Utilizar Classe ao inves da funcao' )
Return NIL 

CLASS TJurCmbBox

  DATA oPanel
  DATA nRow
  DATA nCol
  DATA nWidth
  DATA nHeight
  DATA oCombo
  DATA oGet
  DATA lVisible
  DATA cValor
  DATA aItems
  DATA nAt
  DATA bChange
  DATA lPanel
  DATA bWhen
  DATA cDescProperty

METHOD New(nRow, nCol, nWidth, nHeight, oWnd, aItens, bChange) CONSTRUCTOR
	METHOD Destroy()
	METHOD SetAlign()
	METHOD Refresh()
	METHOD RefreshTam()
	METHOD Select()
	METHOD SetItems()
	METHOD Enable()
	METHOD Disable()
	METHOD GetnAt()
	METHOD GetcAt()
	METHOD Visible()
	METHOD Hide()
	METHOD Show()
	METHOD SetbChange() 
	
ENDCLASS

METHOD New(nRow, nCol, nWidth, nHeight, oWnd, aItems, bChange, lPanel, bWhen, cDescProperty) Class TJurCmbBox

Default lPanel        := .T.
Default bWhen         := {|| .T.}
Default cDescProperty := '::cValor'

::lVisible      := .T.
::nRow          := nRow
::nCol          := nCol
::nWidth        := nWidth
::nHeight       := nHeight
::aItems        := aItems
::bChange       := bChange
::cValor        := GetSizeValue(::aItems)
::lPanel        := lPanel
::bWhen         := bWhen
::cDescProperty := cDescProperty

if ::lPanel
	::oPanel := tPanel():New(::nRow,::nCol,'',oWnd,,,,,,::nWidth,::nHeight,.T.,.T.)
	::oCombo := TComboBox():New(1,1,{|u|if(PCount()>0,::cValor:=u,::cValor)},::aItems,::nWidth,::nHeight,;
  												  ::oPanel,,{||::nAt := ::oCombo:nAt, EVal(::bChange)},,,,.T.,,,,,,,,,::cDescProperty)
	::oCombo:Align := CONTROL_ALIGN_ALLCLIENT
	
	::oGet := TGet():New(::oCombo:nTop,::oCombo:nLeft,{|u| if(Pcount( )>0,::cValor := u,::cValor) },;
				    				   ::oPanel,::oCombo:nClientWidth,::oCombo:nClientHeight,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,::cDescProperty,,,,) 
	::oGet:Hide()
else
	::oCombo := TComboBox():New(::nRow,::nCol,{|u|if(PCount()>0,::cValor:=u,::cValor)},::aItems,::nWidth,::nHeight,;
  												  oWnd,,{||::nAt := ::oCombo:nAt, EVal(::bChange)},,,,.T.,,,,::bWhen,,,,,::cDescProperty)
endif
	

Return Self

METHOD Destroy() Class TJurCmbBox
	::oCombo:bSetGet := {|| }
	::oGet:bSetGet   := {|| }
Return NIL

METHOD Refresh() Class TJurCmbBox
	If ::lPanel
		::oPanel:Refresh()
		::oCombo:Refresh()
		::oGet:Refresh()
	Else
		::oCombo:Refresh()
	EndIf
Return NIL

METHOD SetAlign(nAlign) Class TJurCmbBox
	if ::lPanel
		::oPanel:Align := nAlign
	endif
Return NIL

METHOD Select(nItem) Class TJurCmbBox
  ::oCombo:Select(nItem)
  ::nAt := ::oCombo:nAt
Return NIL

METHOD SetItems(aItems) Class TJurCmbBox
	::aItems := {}
	::aItems := aItems
	::oCombo:SetItems(aItems)
Return NIL

METHOD RefreshTam() Class TJurCmbBox
  if ::lPanel
	  ::oPanel:nTop 	 := ::nRow
	  ::oPanel:nBottom := ::nCol
	  ::oPanel:nWidth  := ::nWidth
	  ::oPanel:nHeight := ::nHeight
  endif
  ::Refresh()
Return NIL

METHOD Enable() Class TJurCmbBox
	::oPanel:Enable()
Return NIL

METHOD Disable() Class TJurCmbBox
	::oPanel:Disable()
Return NIL

METHOD GetnAt() Class TJurCmbBox
Return IIF(::oCombo:nAt==NIL, LEN(::oCombo:aItems), ::oCombo:nAt)

METHOD GetcAt() Class TJurCmbBox
Return IIF(::oCombo:nAt==NIL, AllTrim(Str(LEN(::oCombo:aItems))), AllTrim(Str(::oCombo:nAt)))

METHOD Visible(lVisible) Class TJurCmbBox
Default lVisible := .T.
	If ValType(lVisible) == "L"
		::lVisible := lVisible
	  if ::lVisible
	    ::oPanel:Show()
	  Else
	    ::oPanel:Hide()
	  EndIF
	EndIf
Return Nil

METHOD Hide() Class TJurCmbBox
Return ::Visible(.F.)

METHOD Show() Class TJurCmbBox
Return ::Visible(.T.)

METHOD SetbChange(bChange) Class TJurCmbBox

	If ValType(bChange) == "B"
		::bChange := bChange
	EndIf

Return ::bChange == bChange

// --- FUNCTIONS ---

Static function GetSizeValue(aItems)
Local nQtd  := Len(aItems)
Local nSize := 0
Local nI

	For nI := 1 To nQtd

		If nI == 1
			nSize := Len(aItems[nI])
		Else

			If nSize < Len(aItems[nI])
				nSize := Len(aItems[nI])
			EndIf

		EndIf

	Next

Return PadR("", nSize)
