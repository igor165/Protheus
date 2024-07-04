#INCLUDE "PROTHEUS.CH"

Static _oFINA706

/* ----------------------------------------------------------------------------

FinSheet()

---------------------------------------------------------------------------- */
Class FinSheet

	Data oDlg As Object
	Data oBrowse As Object

	Data nWidth As Object
	Data nHeight As Object

	Data oParent As Object

	Data cAlias As String
	Data cFile As String
	Data cIndexFile As String
	Data cIndexOrder As String

	Data cAlign As String

	Data aColumns As Object

	Data lInit As Object

	Data bDblClickHandler As Block

	// construtor
	Method New() Constructor

	// outros
	Method AddColumn()
	Method Init()

	Method GetAlias()
	Method Refresh()

	Method DblClick()

	Method Dispose()

	Method GetFreeze()
	Method SetFreeze()

	Method GetRecno()
	Method IsOpen()
	Method SetDblClickHandler()

	Method GetWidth()
	Method SetWidth()

	Method GetHeight()
	Method SetHeight()

	Method GetOrder()
	Method SetOrder()

	Method SetAlign()
	Method GetAlign()

	Method GetIndexFilename()
	Method GetFilename()

	Method AppendChild()

	Method Clear()
EndClass

/* ----------------------------------------------------------------------------

FinSheet:New()

---------------------------------------------------------------------------- */
Method New(oParent) Class FinSheet
	Self:oDlg := Nil
	Self:oBrowse := Nil
	Self:nWidth := 320
	Self:nHeight := 240
	Self:oParent := oParent

	Self:cAlias := ""
	Self:cFile := ""

	Self:cAlign := CONTROL_ALIGN_ALLCLIENT

	Self:cIndexFile := ""
	Self:cIndexOrder := ""

	Self:aColumns := {}

	Self:bDblClickHandler := {|| }

	Self:lInit := .F.
Return

/* ----------------------------------------------------------------------------

FinSheet:Init()

---------------------------------------------------------------------------- */
Method Init() Class FinSheet

	Local oColumn := Nil

	Local i := 0

	Local aHeaders := {}
	Local aColSizes := {}

	Local aField := {}
	Local aStruct := {}

	Local aColumns := Self:aColumns
	Local nAlias := 0

	Local uData := Nil

	Self:cAlias := GetNextAlias()
	Self:cFile := Self:cAlias

	For i := 1 To Len(aColumns)
    aField := {aColumns[i][3], aColumns[i][4], aColumns[i][5], aColumns[i][6]}
	  Aadd(aStruct, aField)
 	Next

	If(_oFINA706 <> NIL )

		_oFINA706:Delete()
		_oFINA706 := NIL

	EndIf

	_oFINA706 := FwTemporaryTable():New(Self:cFile)
	_oFINA706:SetFields(aStruct)
	_oFINA706:AddIndex("1",{"ORDEM"})
	_oFINA706:Create()
	nAlias := Select(Self:cAlias)

	If nAlias == 0
		Self:lInit := .F.
		Return Self:lInit
	EndIf

	Self:oBrowse := TcBrowse():New(0, /* nRow */;
	                               0, /* nCol */;
	                               Self:nWidth / 2, /* nWidth */;
	                               Self:nHeight / 2, /* nHeigth */;
	                               , /* bFields */;
	                               aHeaders, /* aHeaders */;
	                               aColSizes, /* aColSizes */;
	                               Self:oParent, /* oDlg */;
	                               , /* cField */;
	                               , /* uValue1 */;
	                               , /* uValue2 */;
	                               , /* uChange */;
	                               {|nRow, nCol, nFlags| Self:DblClick(nRow, nCol, nFlags)}, /* {|nRow,nCol,nFlags|[uLDblClick]} */;
	                               , /* {|nRow,nCol,nFlags|[uRClick]} */;
	                               , /* oFont */;
	                               , /* oCursor */;
	                               , /* nClrFore */;
	                               , /* nClrBack */;
	                               , /* cMsg */;
	                               , /* lUpdate */;
	                               Self:cAlias, /* cAlias */;
	                               , /* lPixel */;
	                               , /* {uWhen} */;
	                               , /* lDesign */;
	                               , /* bValid */;
	                               .T., /* lHScroll */;
	                               .F.) /* lVScroll */


	Self:oBrowse:Align := Self:cAlign

	//Self:oBrowse:lUseDefaultColors := .F.
	//Self:oBrowse:SetBlkBackColor({|| Rgb(255, 255, 255)})

	dbSelectArea(Self:cAlias)

	For i := 1 To Len(aColumns)

		If !aColumns[i][9]
			Loop
		EndIf

		// se for bitmap
		If aColumns[i][10] .And. Len(aColumns[i]) > 10
			uData := aColumns[i][11]
		Else
			uData := FieldWBlock(aColumns[i][3], nAlias)
		EndIf

		oColumn := TcColumn():New(aColumns[i][1],/* cHead */;
			uData, /* uData */;
			aColumns[i][7], /* cPicture */;
			, /* uClrFore */;
			, /* uClrBack */;
			aColumns[i][8], /* cAlign */ ;
			aColumns[i][2], /* nWidth */ ;
			aColumns[i][10], /* lBit */ ;
			.F., /* lEdit */ ;
			, /* cMsg */ ;
			, /* uValid */ ;
			, /* cErr */ ;
			.T., /* lLite */ ;
		    /* cOrder */ )

		Self:oBrowse:AddColumn(oColumn)
	Next

	Self:lInit := .T.
Return Self:lInit

/* ----------------------------------------------------------------------------

FinSheet:AddColumn()

---------------------------------------------------------------------------- */
Method AddColumn(aColumn) Class FinSheet
  Local lReturn := .F.

	If !Self:lInit

		If Ascan(Self:aColumns, {|x| x[3] == Upper(AllTrim(aColumn[3])) }) > 0
			UserException("O campo " + aColumn[3] + ;
			" está duplicado, pois já foi definido na estrutura do FinSheet." + CRLF)

			lReturn := .F.
		Else
			Aadd(Self:aColumns, aColumn)

			lReturn := .T.
		EndIf
	EndIf
Return lReturn

/* ----------------------------------------------------------------------------

FinSheet:GetAlias()

---------------------------------------------------------------------------- */
Method GetAlias() Class FinSheet
Return Self:cAlias

/* ----------------------------------------------------------------------------

FinSheet:Refresh()

---------------------------------------------------------------------------- */
Method Refresh() Class FinSheet
	If Self:oBrowse # Nil
		dbSelectArea(Self:cAlias)
		Self:oBrowse:Refresh()
	EndIf
Return

/* ----------------------------------------------------------------------------

FinSheet:Dispose()

---------------------------------------------------------------------------- */
Method Dispose() Class FinSheet
	If Self:IsOpen()

		// fecha o alias
		(Self:cAlias)->(dbCloseArea())
		
		If(_oFINA706 <> NIL )

			_oFINA706:Delete()
			_oFINA706 := NIL

		EndIf
	EndIf
Return

/* ----------------------------------------------------------------------------

FinSheet:DblClick()

---------------------------------------------------------------------------- */
Method DblClick(nRow, nCol, nFlags) Class FinSheet
	If !Empty(Self:bDblClickHandler)
		Eval(Self:bDblClickHandler, Self)
	EndIf
Return

/* ----------------------------------------------------------------------------

FinSheet:SetDblClickHandler()

---------------------------------------------------------------------------- */
Method SetDblClickHandler(bBlock) Class FinSheet
	If ValType(bBlock) == "B"
		Self:bDblClickHandler := bBlock  // TODO: Verificar o tipo
	EndIf
Return

/* ----------------------------------------------------------------------------

FinSheet:GetRecno()

---------------------------------------------------------------------------- */
Method GetRecno() Class FinSheet
	If Self:IsOpen()
		Return (Self:cAlias)->(Recno())
	EndIf
Return 0

/* ----------------------------------------------------------------------------

FinSheet:IsOpen()

---------------------------------------------------------------------------- */
Method IsOpen() Class FinSheet
Return (Select(Self:cAlias) > 0)

/* ----------------------------------------------------------------------------

FinSheet:GetFreeze()

---------------------------------------------------------------------------- */
Method GetFreeze(nFreeze) Class FinSheet
Return Self:oBrowse:nFreeze

/* ----------------------------------------------------------------------------

FinSheet:SetFreeze()

---------------------------------------------------------------------------- */
Method SetFreeze(nFreeze) Class FinSheet

	//
	// TODO: Validar o nFreeze
	//
	Self:oBrowse:nFreeze := nFreeze
Return Self:oBrowse:nFreeze

/* ----------------------------------------------------------------------------

FinSheet:GetWidth()

---------------------------------------------------------------------------- */
Method GetWidth() Class FinSheet
Return Self:nWidth

/* ----------------------------------------------------------------------------

FinSheet:SetWidth()

---------------------------------------------------------------------------- */
Method SetWidth(nWidth) Class FinSheet
Return (Self:nWidth := nWidth)

/* ----------------------------------------------------------------------------

FinSheet:GetHeight()

---------------------------------------------------------------------------- */
Method GetHeight() Class FinSheet
Return Self:nHeight

/* ----------------------------------------------------------------------------

FinSheet:SetHeight()

---------------------------------------------------------------------------- */
Method SetHeight(nHeight) Class FinSheet
Return (Self:nHeight := nHeight)

/* ----------------------------------------------------------------------------

FinSheet:AppendChild()

---------------------------------------------------------------------------- */
Method AppendChild(aColumns) Class FinSheet
	Local cAlias := Self:GetAlias()
	Local i := 0

  Local nRecno := (cAlias)->(Recno())

	Reclock(cAlias, .T.)

  	For i := 1 To Len(aColumns)
			(cAlias)->(FieldPut(FieldPos(aColumns[i][1]), aColumns[i][2]))
  	Next

	MsUnlock()

	(cAlias)->(dbGoto(nRecno))

	Self:Refresh()
Return

/* ----------------------------------------------------------------------------

FinSheet:Clear()

---------------------------------------------------------------------------- */
Method Clear() Class FinSheet
	(Self:GetAlias())->(__DbZap())
Return

/* ----------------------------------------------------------------------------

FinSheet:SetOrder()

---------------------------------------------------------------------------- */
Method SetOrder(cOrder) Class FinSheet

  //
  // TODO: validar o cOrder
  //

  If !Self:lInit
		Self:cIndexOrder := cOrder
	EndIf
Return Self:cIndexOrder

/* ----------------------------------------------------------------------------

FinSheet:GetOrder()

---------------------------------------------------------------------------- */
Method GetOrder() Class FinSheet
Return Self:cIndexOrder

/* ----------------------------------------------------------------------------

FinSheet:GetIndexFilename()

---------------------------------------------------------------------------- */
Method GetIndexFilename() Class FinSheet
Return Self:cIndexFile + OrdBagExt()

/* ----------------------------------------------------------------------------

FinSheet:GetFilename()

---------------------------------------------------------------------------- */
Method GetFilename() Class FinSheet
Return _oFINA706:GetRealName()

/* ----------------------------------------------------------------------------

FinSheet:SetAlign()

---------------------------------------------------------------------------- */
Method SetAlign(cAlign) Class FinSheet
	If !Self:lInit
		Self:cAlign := cAlign
	EndIf
Return Self:cAlign

/* ----------------------------------------------------------------------------

FinSheet:GetAlign()

---------------------------------------------------------------------------- */
Method GetAlign() Class FinSheet
Return Self:cAlign