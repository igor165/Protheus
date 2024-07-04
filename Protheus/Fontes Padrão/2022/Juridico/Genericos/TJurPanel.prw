#INCLUDE "PROTHEUS.CH"
#INCLUDE "TJURPANEL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TJurPanel
CLASS TJurPanel

@author Felipe Bonvicini Conti
@since 17/02/11
@version 1.0
/*/
//-------------------------------------------------------------------

Function __TJurPanel() // Function Dummy
	ApMsgInfo( 'TJurPanel -> Utilizar Classe ao inves da funcao' )
Return NIL 

CLASS TJurPanel

  DATA oTela
  DATA aPanel
  DATA oPanel
  DATA cDesc
  DATA nRow
  DATA nCol
  DATA nWidth
  DATA nHeight
  DATA lLowered
  DATA lRaised
  DATA nAlign
  DATA oFWLayer

  METHOD New(nRow, nCol, nWidth, nHeight, oWnd, cDesc, lLowered, lRaised, nAlign) CONSTRUCTOR
	METHOD AddHorizontalPanel()
	METHOD AddVerticalPanel()
	METHOD GetPanel()
  	
ENDCLASS


METHOD New(nRow, nCol, nWidth, nHeight, oWnd, cDesc, lLowered, lRaised, nAlign) Class TJurPanel

Default lLowered := .F.
Default lRaised	 := .F.
Default nAlign	 := NIL
	
	::oTela	    := oWnd
	::aPanel    := {}
  ::nRow 	    := nRow
  ::nCol 	    := nCol
  ::nWidth    := nWidth
  ::nHeight   := nHeight
  ::cDesc	    := cDesc
  ::lLowered  := lLowered
  ::lRaised	  := lRaised
  ::nAlign	  := nAlign


	::oPanel := tPanel():New(::nRow,::nCol,::cDesc,Self:oTela,,,,,CLR_BLUE,::nWidth,::nHeight, ::lLowered, ::lRaised)
	IF !Empty(::nAlign)
		::oPanel:Align := ::nAlign
	EndIF
	::oPanel:ReadClientCoors(.T.,.T.)

Return Self


METHOD AddHorizontalPanel(nPercent, lLowered, lRaised) Class TJurPanel
Local nHeight := (nPercent * (::oPanel:nHeight/2)) / 100
Local nAt := LEN(::aPanel)+1

Default lLowered := ::lLowered
Default lRaised  := ::lRaised

	aAdd(::aPanel, { "ROOT.", tPanel():New(0,0,"",::oPanel,,,,,,0,nHeight, lLowered, lRaised), {} } )
	::aPanel[nAt][2]:Align := CONTROL_ALIGN_TOP
	::aPanel[nAt][2]:ReadClientCoors(.T.,.T.)
	
	::aPanel[nAt][1] += PADL(Alltrim(STR(nAt)), 3, '0')

Return ::aPanel[nAt][1]


METHOD AddVerticalPanel(nPercent, cIDPai, nColor, lLowered, lRaised) Class TJurPanel
Local nWidth := (nPercent * (::oPanel:nWidth/2)) / 100
Local nI := 0, nAt := 0, nAtF := 0

Default nColor := NIL
Default lLowered := ::lLowered
Default lRaised  := ::lRaised

	For nI := 1 to LEN(::aPanel)
		IF cIDPai == ::aPanel[nI][1]
			nAt := nI
			Exit
		EndIF
	Next

  IF nAt > 0
		aAdd(::aPanel[nAt][3], { ::aPanel[nAt][1]+".", tPanel():New(0,0,"",::aPanel[nAt][2],,,,,nColor, nWidth,0, lLowered, lRaised) } )
	
		nAtF 														:= LEN(::aPanel[nAt][3])
		::aPanel[nAt][3][nAtF][2]:Align := CONTROL_ALIGN_LEFT	
		::aPanel[nAt][3][nAtF][2]:ReadClientCoors(.T.,.T.)
		::aPanel[nAt][3][nAtF][1] 			+= PADL(Alltrim(STR(nAtF)), 3, '0')
	Else
		Alert(STR0001) // "Panel horizontal não encontrado."
	EndIF

Return ::aPanel[nAt][3][nAtF][1]


METHOD GetPanel(cID) Class TJurPanel
Local oPnl := Nil
Local nI, nY

	For nI := 1 to LEN(::aPanel)
		
		IF cID == ::aPanel[nI][1]
			oPnl := ::aPanel[nI][2]
			Exit
		EndIF
		
		For nY := 1 to LEN(::aPanel[nI][3])

			IF cID == ::aPanel[nI][3][nY][1]
				oPnl := ::aPanel[nI][3][nY][2]
				Exit
			EndIF

		Next

		IF !Empty(oPnl)
			Exit
		EndIf

	Next

Return oPnl