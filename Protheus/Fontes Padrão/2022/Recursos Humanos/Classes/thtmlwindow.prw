#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

Class THtmlWindow from TDialog
	Data oScroll
	Data oPanel
	Data nTopComponent
	Data nLeftComponent
	Data nHigher
	Data aFonts
	Data aComponents
 
	Method New(cTitle) CONSTRUCTOR
	Method AddText(cText)
	Method AddLink(cText, bLink)
	Method AddImage(cResource)
	Method AddSpace(nSize)
	Method LineBreak()
	Method GetWidth(cText) 
	
	Method AddTable(nLines, nColumns)
EndClass

Method New(cTitle) Class THtmlWindow
	:New(MsAdvSize()[7], 0, MsAdvSize()[6], MsAdvSize()[5], cTitle,,,,,,,,,.T.)	
	
	SELF:aComponents:= {}
	SELF:oFont:= TFont():New('Verdana', NIL, 14)
	SELF:aFonts:= GetFontPixWidths(	SELF:oFont:Name,;
									SELF:oFont:nHeight,;
									SELF:oFont:Bold,;
									SELF:oFont:Italic,;
									SELF:oFont:Underline)
	
	SELF:oPanel:= TPanel():New(0, 0, "", SELF)	
	SELF:oScroll := TScrollArea():New(SELF)
	SELF:oScroll:Align := CONTROL_ALIGN_ALLCLIENT
	SELF:oScroll:SetFrame(SELF:oPanel)
	
	SELF:nTopComponent := 0
	SELF:nLeftComponent := 0	
	SELF:nHigher := 0
Return



Method AddText(cText, oFont) Class THtmlWindow
	Local oSay
	Default cText:= ""
	Default oFont:= SELF:oFont
	                                        
	oSay:= TSay():Create(SELF:oPanel)
	oSay:SetFont(oFont)
	oSay:SetText(cText)
	oSay:nTop := SELF:nTopComponent
	oSay:nLeft := SELF:nLeftComponent
	oSay:nWidth := SELF:GetWidth(cText)
	oSay:nHeight := SELF:oFont:nHeight
	
	SELF:nLeftComponent+= oSay:nWidth
	
	AAdd(SELF:aComponents, oSay)
Return


Method AddLink(cText, bLink) Class THtmlWindow
	Local oLink := TLink():New(SELF:oPanel)
	oLink:SetFont(SELF:oFont)
	oLink:SetText(cText)
	oLink:SetLeftClick(bLink)
	oLink:nTop := SELF:nTopComponent
	oLink:nLeft := SELF:nLeftComponent
	oLink:nWidth := SELF:GetWidth(cText)
	oLink:nHeight := SELF:oFont:nHeight

	SELF:nLeftComponent+= oLink:nWidth

	AAdd(SELF:aComponents, oLink)
Return

Method AddImage(cResource) Class THtmlWindow
	Local oIcon:= TBitmap():Create(NIL, SELF:nTopComponent, SELF:nLeftComponent, NIL, NIL, cResource)
	Local nTmpWidth
	Local nTmpHeight

	oIcon:lAutoSize := .T.

	nTmpWidth := oIcon:nClientWidth
	nTmpHeight := oIcon:nClientHeight

	oIcon:End()

	oIcon:= TBitmap():Create(SELF:oPanel)
	oIcon:nTop := SELF:nTopComponent
	oIcon:nLeft := SELF:nLeftComponent
	oIcon:SetBmp(cResource)	
	oIcon:nWidth := nTmpWidth
	oIcon:nHeight := nTmpHeight
	
	SELF:nLeftComponent+= oIcon:nWidth
	
	AAdd(SELF:aComponents, oIcon)
Return

Method AddSpace(nSize) Class THtmlWindow
	SELF:nLeftComponent+= nSize
Return 


Method LineBreak() Class THtmlWindow
	Local nHigher:= 0
	Local nCount
	
	For nCount:= 1 To Len(SELF:aComponents)
		If SELF:aComponents[nCount]:nHeight > nHigher
			nHigher:= SELF:aComponents[nCount]:nHeight
		EndIf
	Next

	For nCount:= 1 To Len(SELF:aComponents)
		SELF:aComponents[nCount]:nTop:= SELF:nTopComponent + (nHigher/2) - (SELF:aComponents[nCount]:nHeight/2)
	Next

	SELF:aComponents := {}
	SELF:oPanel:nHeight += nHigher
	SELF:nTopComponent += nHigher	
	SELF:nLeftComponent := 0	
Return


Method GetWidth(cText) Class THtmlWindow
	Local nTempWidth:= 0
	Local nX
	
	For nX := 1 to Len(cText)
		nTempWidth += SELF:aFonts[ Asc(SubStr(cText, nX, 1) ) ]
	Next nX
Return ((nTempWidth * 0.6) + 2)			//(nTempWidth / 1.35)
  

Method AddTable(aColumns, aLines, nPadding) Class THtmlWindow
	Local oLine
	Local nContLine
	Local oColumn
	Local nContColumn
	Local oTable
	Local nSize
	Local nLines	:= Len(aLines)
	Local nColumns	:= Len(aColumns)	
	Default nPadding:= 0
	
	oTable:= TPanel():Create(SELF:oPanel)
	oTable:nTop:= SELF:nTopComponent
	oTable:nLeft:= SELF:nLeftComponent
	oTable:nWidth:= (nSize * nColumns) + (nPadding * 2) + (nPadding * nColumns * 2)
	oTable:nHeight:= (nSize * nLines) + (nPadding * 2) + (nPadding * nLines * 2)
	oTable:nClrPane:= CLR_BLUE	
	
	For nContLine:= 0 To nLines-1
   		nSize:= IIf(aLines[nContLine] != NIL, Self:nHeight * aLines[nContLine] / 100, 10)
	   			
		oLine:= TPanel():Create(oTable)
		oLine:nTop:= (nSize * nContLine) + (nContLine*nPadding*2) + nPadding
		oLine:nLeft:= nPadding
		oLine:nWidth:= (nSize + (nPadding*2)) * nColumns
		oLine:nHeight:= nSize + (nPadding*2)
		oLine:nClrPane:= CLR_RED
		
	   	For nContColumn:= 0 To nColumns - 1
	   		nSize:= IIf(aColumns[nContColumn] != NIL, Self:nWidth * aColumns[nContColumn] / 100, 10)
			oColumn:= TPanel():Create(oLine)
			oColumn:nTop:= nPadding
			oColumn:nLeft:= (nSize * nContColumn) + (nContColumn*nPadding*2) + nPadding
			oColumn:nWidth:= nSize
			oColumn:nHeight:= nSize
			oColumn:nClrPane:= CLR_YELLOW		   	
   		Next
	Next

	SELF:nLeftComponent+= oTable:nWidth	
	AAdd(SELF:aComponents, oTable)
Return



/*
Method AddTable(nLines, nColumns, nPadding) Class THtmlWindow
	Local oLine
	Local nContLine
	Local oColumn
	Local nContColumn
	Local oTable
	Local nSize := 20
	Default nPadding:= 0
	
	oTable:= TPanel():Create(SELF:oPanel)
	oTable:nTop:= SELF:nTopComponent
	oTable:nLeft:= SELF:nLeftComponent
	oTable:nWidth:= (nSize * nColumns) + (nPadding * 2) + (nPadding * nColumns * 2)
	oTable:nHeight:= (nSize * nLines) + (nPadding * 2) + (nPadding * nLines * 2)
	//oTable:nClrPane:= CLR_BLUE	
	
	For nContLine:= 0 To nLines-1
		oLine:= TPanel():Create(oTable)
		oLine:nTop:= (nSize * nContLine) + (nContLine*nPadding*2) + nPadding
		oLine:nLeft:= nPadding
		oLine:nWidth:= (nSize + (nPadding*2)) * nColumns
		oLine:nHeight:= nSize + (nPadding*2)
		//oLine:nClrPane:= CLR_RED
		
	   	For nContColumn:= 0 To nColumns - 1
			oColumn:= TPanel():Create(oLine)
			oColumn:nTop:= nPadding
			oColumn:nLeft:= (nSize * nContColumn) + (nContColumn*nPadding*2) + nPadding
			oColumn:nWidth:= nSize
			oColumn:nHeight:= nSize
			//oColumn:nClrPane:= CLR_YELLOW		   	
   		Next
	Next

	SELF:nLeftComponent+= oTable:nWidth	
	AAdd(SELF:aComponents, oTable)
Return
*/

/*
Method AddTable()
	Local oTable:= TPanel():Create(SELF:oPanel)
	oTable:nTop:= SELF:nTopComponent
	oTable:nLeft:= SELF:nLeftComponent		

	AAdd(SELF:aComponents, oTable)
Return

Method EndTable()
	oTable:= ATail(SELF:aComponents)

	SELF:nLeftComponent+= oTable:nWidth	
Return

Method AddTableRow()
	oTable:= ATail(SELF:aComponents)
	
	oLine:= TPanel():Create(oTable)
	oLine:nTop:= (nSize * nContLine) + (nContLine*nPadding*2) + nPadding
	oLine:nLeft:= nPadding
	oLine:nWidth:= (nSize + (nPadding*2)) * nColumns
	oLine:nHeight:= nSize + (nPadding*2)
	//oLine:nClrPane:= CLR_RED
Return

Method EndTableRow()
Return

Method AddTableData()
Return

Method EndTableData()
Return
*/


/*
Class THtmlTable From TPanel
	Data oRows
	Data oCels
	Data nPadding

	Method New() CONSTRUCTOR
	Method AddRow()
	Method AddCell()
EndClass

Method New(oParent) Class THtmlTable
	:Create(oParent)

	oRows:= ArrayList():New()
	oCels:= ArrayList():New()
	
	//Self:nTop:= oParent:nTopComponent
	//Self:nLeft:= oParent:nLeftComponent			
Return

Method AddRow() Class THtmlTable
	Local oLine:= TPanel():Create(oTable)

	Self:oRows:Add(oLine)
	Self:oCels:Add(ArrayList():New())
Return


Method AddCell() Class THtmlTable
	Local oLine
	Local oColumn
	
    oLine:= Self:oRows:GetItem(Self:oRows:GetCount())
	oColumn:= TPanel():Create(oLine)
	//oColumn:nTop:= Self:nPadding
	//oColumn:nLeft:= (nSize * nContColumn) + (nContColumn*nPadding*2) + nPadding
	//oColumn:nWidth:= nSize
	//oColumn:nHeight:= nSize
    
	
	Self:oCels:Add(oColumn)
Return

Method SetCellWidth() Class THtmlTable
	Local oCell:=
Return
                                       
Method SetCellHeight() Class THtmlTable

Return

Method Resize() Class THtmlTable
	Local nMaxCols:= Self:GetMaxCols()

	Self:nWidth	:= 0
	Self:nHeight:= 0
	
	oTable:= TPanel():Create(SELF:oPanel)
	oTable:nTop:= SELF:nTopComponent
	oTable:nLeft:= SELF:nLeftComponent
	oTable:nWidth:= (nSize * nColumns) + (nPadding * 2) + (nPadding * nColumns * 2)
	oTable:nHeight:= (nSize * nLines) + (nPadding * 2) + (nPadding * nLines * 2)
	//oTable:nClrPane:= CLR_BLUE	
	
	For nContLine:= 0 To nLines-1
		oLine:= TPanel():Create(oTable)
		oLine:nTop:= (nSize * nContLine) + (nContLine*nPadding*2) + nPadding
		oLine:nLeft:= nPadding
		oLine:nWidth:= (nSize + (nPadding*2)) * nColumns
		oLine:nHeight:= nSize + (nPadding*2)
		//oLine:nClrPane:= CLR_RED
		
	   	For nContColumn:= 0 To nColumns - 1
			oColumn:= TPanel():Create(oLine)
			oColumn:nTop:= nPadding
			oColumn:nLeft:= (nSize * nContColumn) + (nContColumn*nPadding*2) + nPadding
			oColumn:nWidth:= nSize
			oColumn:nHeight:= nSize
			//oColumn:nClrPane:= CLR_YELLOW		   	
   		Next
	Next

	Self:nHeight+= nRowHeight
	Self:nWidth+= nColWidth
	
Return

Method GetMaxCols() Class THtmlTable
	Local nMaxQtd:= 0
	Local nContLine

	For nContLine:= 1 To oCels:GetCount()
		nMaxQtd:= Max(nMaxQtd, oCels:GetItem(nContLine):GetCount())
	Next	
Return nMaxQtd

Method GetColSize(nCol) Class THtmlTable
	Local nMaxSize:= 0
	Local nContLine

	For nContLine:= 1 To oCels:GetCount()
		nMaxSize:= Max(nMaxSize, oCels:GetItem(nContLine):GetItem(nCol):nWidth)
	Next	
Return nMaxSize
*/




Class TLink from THButton
	Data aFonts
	
	Method New(oParent) CONSTRUCTOR
	Method SetText(cText)
	Method SetFont(oFont)
	Method SetLeftClick(bAction)
EndClass

Method New(oParent) Class TLink
	:New(0, 0, "", oParent)	
                                    
	SELF:oFont:= TFont():New("FW Microsiga", 0, 10, .T.)
	SELF:aFonts := GetFontPixWidths(SELF:oFont:Name,;
									SELF:oFont:nHeight,;
									SELF:oFont:Bold,;
									SELF:oFont:Italic,;
									SELF:oFont:Underline)
Return

Method SetText(cText) Class TLink
	Local nX     := 0
	Local nTempWidth := 0

	Self:cCaption:= cText

	For nX := 1 to Len(cText)
		nTempWidth += SELF:aFonts[ Asc(SubStr(cText, nX, 1) ) ]
	Next nX

	SELF:nWidth := (nTempWidth / 1.4) //(nTempWidth / 1.35)
Return

Method SetFont(oFont) Class TLink
	SELF:oFont := oFont
	SELF:aFonts := GetFontPixWidths(oFont:Name,;
									oFont:nHeight,;
									oFont:Bold,;
									oFont:Italic,;
									oFont:Underline)
Return

Method SetLeftClick(bAction) Class TLink
	SELF:bLClicked := bAction
Return
	