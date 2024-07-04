#include "protheus.ch"

Class FinSheetCol
	Data cText As String
	Data nSize As Integer
	Data cFieldName As String
	Data cFieldType As String
	Data nFieldSize As Integer
	Data nFieldDec As Integer
	Data cPicture As Integer
	Data cAlign As String
	Data lVisible As Boolean
	Data lImage As Boolean
	Data bBlock As Block
	
	Method New() Constructor
EndClass

Method New() Class FinSheetCol

Return

Method GetText() Class FinSheetCol
Return Self:cText

Method SetText(cText) Class FinSheetCol
Return (Self:cText := cText)

Method GetSize() Class FinSheetCol
Return Self:nSize

Method SetSize(nSize) Class FinSheetCol
Return (Self:nSize := nSize)

Method GetFieldName() Class FinSheetCol
Return Self:cFieldName

Method SetFieldName(cFieldName) Class FinSheetCol
Return (Self:cFiedlName := cFieldName)

Method GetFieldType() Class FinSheetCol
Return Self:cFieldType

Method SetFieldType(cFieldType) Class FinSheetCol
Return (Self:cFieldType := cFieldType)

Method GetFieldDec() Class FinSheetCol
Return Self:nFieldDec

Method SetFieldDec(nFieldDec) Class FinSheetCol
Return (Self:nFieldDec := nFieldDec)

Method GetPicture() Class FinSheetCol
Return Self:cPicture

Method SetPicture(cPicture) Class FinSheetCol
Return (Self:cPicture := cPicture)

Method GetAlign() Class FinSheetCol
Return Self:cAlign

Method SetAlign(cAlign) Class FinSheetCol
Return (Self:cAlign := cAlign)

Method IsVisible(lVisible) Class FinSheetCol

	If lVisible == Nil
		Return Self:lVisible
	EndIf
Return (Self:lVisible := lVisible)

Method IsImage(lImage) Class FinSheetCol

	If lImage == Nil
		Return Self:lImage
	EndIf
Return (Self:lImage := lImage)

Method GetBlock() Class FinSheetCol
Return Self:bBlock

Method SetBlock(bBlock) Class FinSheetCol
Return (Self:bBlock := bBlock)