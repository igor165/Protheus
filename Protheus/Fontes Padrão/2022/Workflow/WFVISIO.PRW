#INCLUDE "WFVISIO.ch"
#include "SIGAWF.ch"
#INCLUDE "APVISIO.CH"

STATIC __cProcessID := nil

class TWFVisioApp
	data oVisio
	data oShapes
	data oDocument
	data cProcCode
	data cProcID
	data cFileName
	data cOnCellChange
	method New( cCode, cID, cOnChgEvent ) CONSTRUCTOR
	method Release()
	method SetProcCode( cCode )
	method SetProcID( cID )
	method SetCellChange( cOnChange )
	method OpenDocument( cDocument )
	method LoadShapes()
	method LoadWFC()
	method SaveWFC()
endclass

method New( cCode, cID, cOnChgEvent ) class TWFVisioApp
	::oVisio := VisioApp():New()
	::SetCellChange( cOnChgEvent )
	::oShapes := TWFShapes():New( self )
	::SetProcCode( cCode )
	::SetProcID( cID )
return

method Release() class TWFVisioApp
	::oVisio:CellChanged := ""
	::oVisio:Release()
	::oVisio := nil
return

method SetProcCode( cCode ) class TWFVisioApp
	default cCode := ""
	::cProcCode := upper( Left( cCode + Space( 6 ),6 ) )
return

method SetProcID( cID ) class TWFVisioApp
	default cID := ""
	::cProcID := lower( Left( cID + Space( 5 ),5 ) )
return

method SetCellChange( cOnChange ) class TWFVisioApp
	default cOnChange := ""
	::cOnCellChange := cOnChange
	::oVisio:CellChanged := cOnChange
return

method OpenDocument( cDocument ) class TWFVisioApp
	if valtype( cDocument ) == "C"
		::oDocument := ::oVisio:Documents:Open( cDocument )
	elseif valtype( cDocument ) == "N"
		::oDocument := ::oVisio:Documents:Item( cDocument )
	else
		::oDocument := nil
	end
	::LoadShapes()
return

method LoadShapes() class TWFVisioApp
	local nError := 0
	local lError := .f.
	local oPages, oPage
	local bLastError
	
	::oVisio:CellChanged := ''

	bLastError := ErrorBlock( { |e| lError := .t., nError++ } )

	while nError < 5
		BEGIN SEQUENCE
			if ( ::oVisio <> nil ) .and. ( ::oDocument <> nil )
				oPages := ::oDocument:Pages
				oPage := oPages:Item(1)
				::oShapes:Load( oPage:GetShapes() )
				lError := .f.
			end
		END SEQUENCE
		if !(lError)
			exit
		end
	end
	
	ErrorBlock( bLastError )
	
	::oVisio:CellChanged := ::cOnCellChange
return

method LoadWFC() class TWFVisioApp
	local nC
	local oShape
	
	dbSelectArea( "WFC" )
	dbSetOrder(1) // WFC_FILIAL + WFC_SHAPE

	if ::oShapes:GetCount() > 0
	   for nC := 1 to ::oShapes:GetCount()
			oShape := ::oShapes:GetItem( nC )
  			if dbSeek( xFilial( "WFC" ) + ::cProcCode + StrZero( oShape:nID,4 ) )
  				oShape:cName := WFC_NOME
   			oShape:cText := WFC_DESC
  				oShape:cExecFunc := WFC_ACAO
  				oShape:cParentID := WFC_DEPANT
			end
  		next
	end
	
return

method SaveWFC() class TWFVisioApp
	local nC
	local oShape
	
	if ::oShapes:GetCount() > 0
		dbSelectArea( "WFC" )
		dbSetOrder( 1 )
	   for nC := 1 to ::oShapes:GetCount()
			oShape := ::oShapes:GetItem( nC )
			dbSeek( xFilial( "WFC" ) + ::cProcCode + StrZero( oShape:nID,4 ) )
			if Reclock( "WFC", !Found() )
				WFC_FILIAL	:= xFilial( "WFC" )
				WFC_PROCES	:= ::cProcCode
				WFC_TIPO		:= StrZero( oShape:nType,2 )
				WFC_SHAPE	:= StrZero( oShape:nID,4 )
				WFC_NOME		:= oShape:cName
				WFC_DESC		:= oShape:cText
				WFC_ACAO		:= oShape:cExecFunc
				WFC_DEPANT	:= oShape:cParentID
				MsUnlock( "WFC" )
			end
  		next
  	end

return


/**************************************************
 CLASS TWFSHAPES
**************************************************/

class TWFShapes
	data aShapeList
	data oVisioApp
	data oShapesRef
	data oShapeFocus
	data lPaintShapes
	method New( oOwner ) CONSTRUCTOR
	method Load( oShapes )
	method FindItem( uShape )
	method GetCount()
	method GetItem( nItemIndex )
	method SetFocusShape( oShape )
	method GetFocusShape()
	method PaintShapes()
endclass

method New( oOwner ) class TWFShapes
	::lPaintShapes := .f.
	::oVisioApp := oOwner
	::Load()
return

method GetCount() class TWFShapes
return len( ::aShapeList )

method GetItem( nItemIndex ) class TWFShapes
	default nItemIndex := 0
	if ( nItemIndex > 0 ) .and. ( nItemIndex <= ::GetCount() )
		return ::aShapeList[ nItemIndex ]
	end
return nil

method SetFocusShape( oShape ) class TWFShapes
	::oShapeFocus := oShape
return

method GetFocusShape() class TWFShapes
return ::oShapeFocus

method Load( oShapes ) class TWFShapes
	local nC
	local oWFShape, oShape
	
	::aShapeList := {}

	if oShapes == nil 
		return
	end

   for nC := 1 to oShapes:GetCount()
  		oWFShape := TWFShape():New( self )
  		oShape := oShapes:Item( nC )
		
		if oWFShape:Load( oShape )
  			AAdd( ::aShapeList, oWFShape )
   	end
	next
	
	::oShapesRef := oShapes
return

method PaintShapes() class TWFShapes
	Local nC		:= 0
	Local cFindKey  := ""
	Local oShape	:= Nil
	Local oCell     := Nil
	
	if !(::lPaintShapes)
		return
	end
	
	dbSelectArea("WF3")
	dbSetOrder( 2 )

	cFindKey := xFilial("WF3")
	cFindKey += ::oVisioApp:cProcCode
	cFindKey += left( ::oVisioApp:cProcID + ".00" + Space(100),100 )

	if dbSeek( cFindKey )
		::oVisioApp:oVisio:VisioIsIdle := ''
		::oVisioApp:oVisio:CellChanged := ''
		dbSelectArea("WFD")
		dbSetOrder(1)

		cFindKey := xFilial("WFD") + ::oVisioApp:cProcCode + ::oVisioApp:cProcID
		dbSeek( cFindKey )
		
		while !eof() .and. (WFD_FILIAL + WFD_PROCES + WFD_PROCID) == cFindKey

			for nC := 1 to ::GetCount()
				oShape := ::GetItem( nC )
				if oShape:nID == val( WFD_SHAPE )
					oCell := oShape:oShapeRef:CellsSRC( visSectionObject, visRowFill, 0 )
					oCell:Formula := if( WFD_FLAG,3,2 )
				end
			next
			
			dbSkip()
		end

		SysRefresh()
		::oVisioApp:oVisio:CellChanged := ::oVisioApp:cOnCellChange
	end
	
	::lPaintShapes := .f.			
return

method FindItem( uShape ) class TWFShapes
	local nPos
	local oShape
	do case
		case valtype( uShape ) == "N"
			nPos := AScan( ::aShapeList, { |x| x:oShapeRef:ID == uShape } )
		case valtype( uShape ) == "C"
			nPos := AScan( ::aShapeList, { |x| upper( x:oShapeRef:cNameU ) == upper( Alltrim( uShape ) ) } ) 
		case valtype( uShape ) == "O"
			nPos := AScan( ::aShapeList, { |x| x == uShape } )
	end
	oShape := ::GetItem( nPos )
return oShape



/**************************************************
 CLASS TWFSHAPE
**************************************************/

class TWFShape
	data nID
	data nType
	data nItemIndex
	data nFillForegnd
	data cTypeName
	data cName
	data cNameU
	data cText
	data cExecFunc
	data cParentID
	data cDependence
	data lFlag
	data oOwner
	data oShapeRef
	method New( oOwner ) CONSTRUCTOR
	method Load( oShape )
	method FillForegnd( nColor )
	method Properties()
	method Execute()
	method ShowDlg01()
	method ShowDlg02()
	method ShowDlg07()
	method ShowDlg08()
	method ShowDlg09()	
	method ShowDlg06()
endclass

method New( oParent ) class TWFShape
	::oOwner := oParent
return

method Load( oShape ) class TWFShape
	local nC := 0
	local oCell
	
	::nItemIndex := 0
	::nType := -1
	::nFillForegnd := 0
	::cExecFunc := space(50)
 	::cParentID := "0000"
 	::cTypeName := ""
	::lFlag := .f.

	if ( oShape == nil )
		return .f.
	end
	
	::oShapeRef := oShape

	::nID := oShape:ID
	::cName := Left( oShape:Name + space(20),20 )
	::cNameU := Alltrim( oShape:NameU )
	::cText := Left( oShape:Text + space(30),30 )

	oCell := oShape:Cells("User.visWFShapeType")

	::nType := oCell:Formula
	
	if empty( ::nType )
		::nType := -1
	else
		::nType := val(::nType)
		if ::nType == 0
			::nType := -1
		end
	end

	if ( ::nType <> -1 )

		do case
			case ::nType == 1
				::cTypeName := STR0001 //"Inicio"
			case ::nType == 2
				::cTypeName := STR0002 //"Termino"
			case ::nType == 3
				::cTypeName := STR0003 //"Processo"
			case ::nType == 4
				::cTypeName := STR0004 //"Condicao"
			case ::nType == 5
				::cTypeName := STR0005 //"Processo pre-definido"
			case ::nType == 6
				::cTypeName := STR0006 //"E-mail"
			case ::nType == 7
				::cTypeName := STR0007 //"TimeOut"
			case ::nType == 8
				::cTypeName := STR0007 //"TimeOut"
			case ::nType == 9
				::cTypeName := STR0008 //"Destinatarios"
			Otherwise
				::cTypeName := STR0009 //"Outros"
		endcase
		
	end
	
return ( ::nType <> -1 )

method Properties() class TWFShape
	Local lOk := .f.
	Local nC, nFolder := 1
   Local cCaption := STR0010, cExecFunc1, cExecFunc2 //"Propriedade"
   Local aFolders := {}, aParentID := {}
	Local oDlg, oFolder, oID, oName, oText, oParentID, oExecFunc
	
   cCaption += ' - ' + ::cName
   AAdd( aParentID, "0000 - <" + STR0011 + ">" ) //"Nenhum"
	AAdd( aFolders, ::cTypeName )	
	AAdd( aFolders, STR0012 ) //"Executar"
	
	for nC := 1 to ::oOwner:GetCount()
		if ( ::oOwner:aShapeList[ nC ]:nID <> ::nID )
			AAdd( aParentID, strzero( ::oOwner:aShapeList[ nC ]:nID,4 ) + " - " + ::oOwner:aShapeList[ nC ]:cText )
		end
		if ( strzero( ::oOwner:aShapeList[ nC ]:nID,4 ) == ::cParentID )
			::cParentID := aParentID[ len( aParentID ) ]
		end
	next
	
	DEFINE MSDIALOG oDlg FROM 92,69 TO 380,465 TITLE cCaption PIXEL

   @ 15,05 FOLDER oFolder ITEMS aFolders[1], aFolders[2] OPTION nFolder SIZE 190,120 OF oDlg PIXEL

	@ 15,05 SAY WFX3Title( "WFC_SHAPE" ) OF oFolder:aDialogs[ nFolder ] PIXEL
	@ 15,55 MSGET oID VAR ::nID READONLY SIZE 20,10 PICTURE "9999" OF oFolder:aDialogs[ nFolder ] PIXEL
	@ 28,05 SAY WFX3Title( "WFC_NOME" ) OF oFolder:aDialogs[ nFolder ] PIXEL
	@ 28,55 MSGET oName VAR ::cName PICTURE "@!" SIZE 100,10 OF oFolder:aDialogs[ nFolder ] PIXEL
	@ 41,05 SAY WFX3Title( "WFC_DESC" ) OF oFolder:aDialogs[ nFolder ] PIXEL
	@ 41,55 GET oText VAR ::cText MEMO SIZE 130,60 OF oFolder:aDialogs[ nFolder ] PIXEL
	
	nFolder++

	@ 15,05 SAY WFX3Title( "WFC_DEPANT" ) OF oFolder:aDialogs[ nFolder ] PIXEL
	@ 15,55 COMBOBOX oParentID VAR ::cParentID ITEMS aParentID SIZE 130,10 OF oFolder:aDialogs[ nFolder ] PIXEL
	@ 28,05 SAY WFX3Title( "WFC_ACAO" ) OF oFolder:aDialogs[ nFolder ] PIXEL
	@ 28,55 MSGET oExecFunc VAR ::cExecFunc PICTURE "@!" SIZE 130,10 OF oFolder:aDialogs[ nFolder ] PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar( oDlg, {|| lOk := .t., oDlg:End() },{|| oDlg:End()} ) )

	::cParentID := left( ::cParentID,4 )
return
                   
method Execute() class TWFShape
	local nPos
	local cFuncName
	local bLastError
	
	if ( ::oShapeRef == nil )
		return
	end
	
	if !Empty( cFuncName := AllTrim( ::cExecFunc ) )
	
		if ( nPos := at( "(", cFuncName ) ) > 0
			cFuncName := left( cFuncName, nPos -1 )
		end

		if FindFunction( cFuncName )
			if at( "(", cFuncName ) == 0
				cFuncName += "("
			end
			if at( ")", cFuncName ) == 0
				cFuncName += ")"
			end

//			bLastError := ErrorBlock( { |e| WFErrorBlock( e, cMsgError ) } )

			BEGIN SEQUENCE
				&cFuncName
			END SEQUENCE
	
//			ErrorBlock( bLastError )
		end
		
	else
		do case
			case ::nType == 1	//Inicio
				conout("SHAPE = 1")
				::ShowDlg01()
			case ::nType == 2
				conout("SHAPE = 2")
				::ShowDlg02()
			case ::nType == 3
				conout("SHAPE = 3")
			case ::nType == 4
				conout("SHAPE = 4")
			case ::nType == 5
				conout("SHAPE = 5")
			case ::nType == 6
				conout("SHAPE = 6")
			case ::nType == 7 
				conout("SHAPE = 7")
			case ::nType == 8	// TIMEOUT
				conout("SHAPE = 8")
				::ShowDlg08()
			case ::nType == 9	// DESTINATARIOS
				conout("SHAPE = 9")
				::ShowDlg09()
			otherwise
				conout("SHAPE = " + alltrim(str(::nType)))
			
		endcase
	end
	
return


/******************************************************************************
 SHOWDLG01
 BEGIN PROCESS
******************************************************************************/
method ShowDlg01() class TWFShape
	local oDlg, oSelf := self
	local nC, nPos
	local lOk := .f.
	local cF3Key, cFindKey
	local aFields := Array(2), aObjFields := Array(2), aSXB := SeleF3()
	
	aFields[1] := Space(5)
	aFields[2] := Space(5)
	
	dbSelectArea("WF1")
	dbSeek( xFilial("WF1") + ::oOwner:oVisioApp:cProcCode )

	if !empty( cF3Key := AllTrim( WF1->WF1_SXB ) )
		if ( nPos := At( "-", cF3Key ) ) > 0
			cF3Key := Left( AllTrim( Left( cF3Key, nPos -1 ) ) + Space( 6 ), 6 )
		end
		if ( nPos := AScan( aSXB, { |x| Left( x, len( cF3Key ) ) == cF3Key } ) ) > 0
			aFields[1] := aSXB[ nPos ]
		end
	end

	if Empty( cF3Key )
		cF3Key := "XXXXXX"
	end

	DEFINE MSDIALOG oDlg FROM 0,0 TO 130,350 TITLE STR0013 PIXEL //"Localizar Processo"

	@  15, 05 GROUP oGroup TO 58,170 LABEL STR0014 PIXEL OF oDlg //" Localizar: "
	
	@  25, 15 SAY WFX3Title( "WF1_SXB" ) COLOR CLR_BLUE PIXEL OF oDlg 
	@  25, 50 COMBOBOX aObjFields[1] VAR aFields[1] ITEMS aSXB PIXEL SIZE 110,10 OF oDlg ;
		ON CHANGE (aObjFields[2]:cF3 := left(aFields[1],6), aFields[2] := Space(5))
	@  38, 15 SAY STR0015 COLOR CLR_BLUE PIXEL OF oDlg //"Processo:"
	@  38, 50 MSGET aObjFields[2] VAR aFields[2] F3 cF3Key PICTURE "@!" PIXEL SIZE 50, 10 OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar( oDlg, {|| lOk := .t., oDlg:End() }, {|| oDlg:End()} ) )
			
	if lOk
		::oOwner:oVisioApp:cProcID := aFields[2]
		::oOwner:lPaintShapes := .t.
		::oOwner:PaintShapes()
	end

return

method ShowDlg02() class TWFShape

	if empty( ::oOwner:oVisioApp:cProcID )
		MsgAlert( STR0016 ) //"O código do processo não foi especificado."
		return
	end
	
	dbSelectArea("WF3")
	dbSetOrder(1)
	
	if dbSeek( xFilial("WF3") + PadR( ::oOwner:oVisioApp:cProcID + ".00", 100 ) + "000099" )
		MsgAlert( STR0017, STR0018 ) //"Este processo ja se encontra finalizado."###"Finalizar"
	else
		if MsgYesNo( STR0019, STR0018 ) //"Deseja finalizar este processo ?"###"Finalizar"
			WFKillProcess( ::oOwner:oVisioApp:cProcID )
		end
	end
	
return


/******************************************************************************
 SHOWDLG8
 TIMEOUT
******************************************************************************/
method ShowDlg08() class TWFShape
	local nC, nPos
	local bFunction
	local oDlg, oSelf := self, oFolder
	local lBtnOk := .f.
	local cFindKey, cID, cValFile, cValPath := WF_ROOTDIR + cEmpAnt + "\process\", cField, cMsg
	local aFields, aObjFields, aFolders, aValues, aTimeouts := {}, aAux
	
	if empty( ::oOwner:oVisioApp:cProcID )
		return
	end

	dbSelectArea("WFD")
	cFindKey := xFilial("WFD") + ::oOwner:oVisioApp:cProcCode + ::oOwner:oVisioApp:cProcID + StrZero( ::nID,4 )
 
	if dbSeek( cFindKey )
		dbSelectArea("WFA")
		dbSetOrder(2)
		cFindKey := xFilial("WFA") + lower( ::oOwner:oVisioApp:cProcID + WFD->WFD_TASKID )
		if dbSeek( cFindKey )
			cID := AllTrim( WFA_IDENT )
			cValFile := ChgFileExt( cID, ".val" )

			if file( cValPath + cValFile )
				aValues := __runcb(__compstr(WFLoadFile( cValPath + cValFile )))
				aAux := aValues[15,3]
				for nC := 1 to len( aAux )
					if len( aAux[ nC ] ) > 4
						AAdd( aTimeouts, { { aAux[nC,1], aAux[nC,5], aAux[nC,6], 3 }, "", .f., 3, 0 } )
					else
						AAdd( aTimeouts, { { aAux[nC,1], ctod("/"), "00:00", 3 }, "", .f., 3, 0 } )
					end
				next
				aAux := aValues[18,3,2,3,1]
				if ( nPos := AScan( aAux, {|x| x[1] == "WFRECNOTIMEOUT"} ) ) > 0
					aAux := aAux[nPos,2]
					for nC := 1 to len( aAux )
						aTimeouts[ nC,2 ] := aAux[nC]
					next
				end
				aValues := nil
				aAux := nil
				PRIVATE oSXM := TSXMTable():New()
			   if !oSXM:lIsOpen()
					if !oSXM:lOpen()
						return
					end
				end
				oSXM:_First()
				while !oSXM:lEof()
					if ( oSXM:xValue("XM_FILIAL") + oSXM:xValue("XM_CODIGO") ) == ( xFilial("SXM") + Left( cID,12 ) )
						if !empty( oSXM:xValue("XM_ID") )
							if ( nPos := AScan( aTimeouts, {|x| x[2] == oSXM:xValue("XM_ID") } ) ) > 0
								aTimeouts[ nPos,1,2 ] := oSXM:xValue("XM_DTPROX")
								aTimeouts[ nPos,1,3 ] := oSXM:xValue("XM_HRPROX")
								aTimeouts[ nPos,3 ] := .t.
								aTimeouts[ nPos,5 ] := oSXM:nRecNo()
							end
						end
					end
					oSXM:_Next()
				end
			else
				cMsg := STR0020 //"Nao foi encontrado o arquivo"
				cMsg += " " + lower( cValPath + cValFile )
				conout( cMsg )
				return
			end
			
		else
			cMsg := STR0021 //"Nao foi criado o processo com o codigo"
			cMsg += " " + lower( ::oOwner:oVisioApp:cProcID + WFD->WFD_TASKID )
			conout( cMsg )
			return
		end
		
	else
		cMsg := (STR0022) //"Nao foi encontrado o registro na tabela de rastreabilidade visio"
		conout( cMsg )
		return
	end

	if empty( bFunction := AllTrim( ::cExecFunc ) )
		DEFINE MSDIALOG oDlg FROM 0,0 TO 270,370 TITLE STR0023 + cID PIXEL //"Agendamento de Timeouts - Processo: "
		nPos := 1
	  	aFolders := {}
		aEval( aTimeouts, {|x| AAdd( aFolders, FormatStr( "%99nº.Timeout", nPos++ ) ) } )

	  	aFields := {}
	  	
		if len( aTimeouts ) > 0
		  	aObjFields := Array( len( aTimeouts ),6 )
			oFolder := TFolder():New( 15, 03, aFolders,, oDlg, 1,,, .T.,, 180,120 )
		
			for nC := 1 to len( aTimeouts )
				cField := aTimeOuts[ nC,1,1 ]
				@  05, 10 SAY STR0024 COLOR CLR_BLUE OF oFolder:aDialogs[nC] PIXEL //"Ação:"
				@  05, 60 MSGET aObjFields[nC,1] VAR cField PICTURE "@!" READONLY SIZE 100,10 OF oFolder:aDialogs[nC] PIXEL
				aObjFields[nC,1]:bSetGet := &( '{|x| iif( pCount()==0, aTimeouts[' + str(nC,3) + ',1,1], aTimeouts[' + str(nC,3) + ',1,1] := x ) }' )
				
				@  31, 50 SAY STR0026 COLOR CLR_BLUE OF oFolder:aDialogs[nC] PIXEL //"às"

				if aTimeOuts[ nC,3 ]
					@  18, 10 SAY STR0025 COLOR CLR_BLUE OF oFolder:aDialogs[nC] PIXEL //"Próxima execução:"
					cField := aTimeOuts[ nC,1,2 ]
					@  18, 60 MSGET aObjFields[nC,2] VAR cField PIXEL SIZE 20, 10 OF oFolder:aDialogs[nC]
					cField := aTimeOuts[ nC,1,3 ]
					@  31, 60 MSGET aObjFields[nC,3] VAR cField PICTURE "99:99" SIZE 15,10 OF oFolder:aDialogs[nC] PIXEL
				else
					@  18, 10 SAY STR0043 COLOR CLR_BLUE OF oFolder:aDialogs[nC] PIXEL //"Executado em:"
					cField := aTimeOuts[ nC,1,2 ]
					@  18, 60 MSGET aObjFields[nC,2] VAR cField READONLY PIXEL SIZE 20, 10 OF oFolder:aDialogs[nC]
					cField := aTimeOuts[ nC,1,3 ]
					@  31, 60 MSGET aObjFields[nC,3] VAR cField READONLY SIZE 15,10 OF oFolder:aDialogs[nC] PIXEL
				end

				aObjFields[nC,2]:bSetGet := &( '{|x| iif( pCount()==0, aTimeouts[' + str(nC,3) + ',1,2], aTimeouts[' + str(nC,3) + ',1,2] := x ) }' )
				aObjFields[nC,3]:bSetGet := &( '{|x| iif( pCount()==0, aTimeouts[' + str(nC,3) + ',1,3], aTimeouts[' + str(nC,3) + ',1,3] := x ) }' )

				cField := aTimeOuts[ nC,4 ]
				@  70, 10 SAY STR0027 COLOR CLR_BLUE OF oFolder:aDialogs[nC] PIXEL //"Operação:"
				if aTimeOuts[ nC,3 ]
					@  57, 60 RADIO aObjFields[nC,5] VAR cField ITEMS STR0028, STR0029, STR0030 3D SIZE 80,12 OF oFolder:aDialogs[nC] PIXEL //"Alterar"###"Remover"###"Manter"
				else
					@  57, 60 RADIO aObjFields[nC,5] VAR cField ITEMS STR0028, STR0029, STR0031 3D SIZE 80,12 OF oFolder:aDialogs[nC] PIXEL //"Alterar"###"Remover"###"Inexistente ou executado"
					aObjFields[nC,5]:SetDisable()
				end

				aObjFields[nC,5]:bSetGet := &( '{|x| iif( pCount()==0, aTimeouts[' + str(nC,3) + ',1,4], aTimeouts[' + str(nC,3) + ',1,4] := x ) }' )
			next
			
		else
			@ 50, 50 SAY STR0032 COLOR CLR_BLUE OF oDlg PIXEL //"NAO HA TIMEOUT's PARA ESSE PROCESSO."
		end
			
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar( oDlg, {|| lBtnOk := .t., oDlg:End() }, {|| oDlg:End()} ) )
			
		if lBtnOk
			for nC := 1 to len( aTimeOuts )
				if aTimeOuts[ nC,1,4 ] <> 3
					if oSXM:lGoTo( aTimeOuts[ nC,5 ] )
						if aTimeOuts[ nC,1,4 ] == 1
							oSXM:lUpdate( { { "XM_DTPROX", aTimeOuts[ nC,1,2 ] }, { "XM_HRPROX", aTimeOuts[ nC,1,3 ] } } )
						else
							oSXM:lDelete()
						end
					end
				end
			next
		end
	
	else
		if ( nPos := at( "(", bFunction ) ) > 0
			bFunction := Left( bFunction, nPos -1 )
		end
		if FindFunction( bFunction )
			bFunction := &( "{|x| " + bFunction + "( x ) }" )
			Eval( bFunction, aFields )
		end
	end
	
return

/******************************************************************************
 SHOWDLG06
 E-MAILS
******************************************************************************/
method ShowDlg06() class TWFShape
	local nPos
	local bUserFunction
	local lOk := .f.
	local oDlg, oFolder, oMail, oMailBox, oSentFolder, oP, oMsgDlg
	local cFindKey, cMailBox, cValFile, cWFMFile, cProcessDir, cValues, cStatusCode, cMsg
	local aFolders := {}, aValues := {}, aMessage

	cMailBox := WFGetMV( "MV_WFMLBOX", "" )
	cProcessDir := WF_ROOTDIR + cEmpAnt + "\process\"
	
	if empty( ::oOwner:oVisioApp:cProcID )
		MsgAlert( STR0016 ) //"O código do processo não foi especificado."
		return
	end
	
	if empty( bUserFunction := AllTrim( ::cExecFunc ) )
		dbSelectArea("WFD")
		cFindKey := xFilial("WFD") + ::oOwner:oVisioApp:cProcCode + ::oOwner:oVisioApp:cProcID + StrZero( ::nID,4 )
		if dbSeek( cFindKey )
			dbSelectArea("WFA")
			dbSetOrder(2)
			cFindKey := xFilial("WFA") + lower( ::oOwner:oVisioApp:cProcID + WFD->WFD_TASKID )
			if ( dbSeek( cFindKey ) )
				cValFile := lower( AllTrim( WFA_IDENT ) + ".val" )
				cWFMFile := lower( AllTrim( WFA_IDENT ) + ".wfm" )
				oMail := TWFMail():New()
				oMailBox := oMail:GetMailBox( cMailBox )
				if oMailBox:lExists
					oSentFolder := oMailBox:GetFolder( MBF_SENT )
					oMsgDlg := TWFMsgDialog():New()
					oMsgDlg:LoadFile( oSentFolder:cRootPath + "\" + cWFMFile )
				else
					cMsg := STR0033 //"Caixa de mensagem nao existente:"
					cMsg += " " + cMailBox + ". "
					cMsg += ( STR0034 ) //"Confirme no cadastro de parametros do workflow a caixa de correio utilizada."
					MsgAlert( cMsg )
					return
				end
			else
				MsgAlert( STR0035 ) //"Processo nao localizado."
				return
			end
		else
			MsgAlert(STR0036 ) //"Processo nao utilizado na rastreabilidade do Microsoft Visio."
			return
		end

		if oMsgDlg:Show()
			if empty( bUserFunction := AllTrim( ::cExecFunc ) )
				if file( cProcessDir + cValFile )
					if MsgYesNo( STR0037, STR0038 ) //"Deseja refazer esta tarefa de envio da mensagem?"###"Reenvio"
						dbSelectArea("WFD")
						if dbSeek( xFilial("WFD") + ::oShapes:oVisioApp:cProcCode + __cProcessID + StrZero( ::nID,4 ) )
							cStatusCode := WFD_STATUS
						else
							cStatusCode := ""
						end
						aValues := &( WFLoadFile( cProcessDir + cValFile ) )
						oP := TWFProcess():New( aValues[2,3],, aValues[1,3] + aValues[4,3] )
						oP:Finish()
						oP:NewTask( aValues[3,3], aValues[17,3], .t. )
						oP:Track( cStatusCode, AllTrim( oMsgDlg:cSubject ), "", ::cName )
						oP:cTo := AllTrim( oMsgDlg:cTo )
						oP:cCC := AllTrim( oMsgDlg:cCC )
						oP:cBCC := AllTrim( oMsgDlg:cBCC )
						oP:cSubject := AllTrim( oMsgDlg:cSubject )
						oP:bReturn := aValues[14,3]
						oP:bTimeout := aValues[15,3]
						oP:Start()
					end
				else
					// MsgBox
				end
			end
		end

	else
		if ( nPos := at( "(", bUserFunction ) ) > 0
			bUserFunction := Left( bUserFunction, nPos -1 )
		end
		if FindFunction( bUserFunction )
			bUserFunction := &( "{|x| " + bUserFunction + "( x ) }" )
			Eval( bUserFunction, oMsgDlg )
		end
	end
	
return

/******************************************************************************
 SHOWDLG09
 DESTINATARIOS
******************************************************************************/
method ShowDlg09() class TWFShape
	local nC, nPos1, nPos2, nFolder := 1
	local bUserFunction
	local lOk := .f.
	local dDtSent := dDtInbox := ctod("/")
	local cHrSent := cHrInbox := "00:00"
	local oDlg, oFolder, oMail, oMailBox, oSentFolder
	local cFindKey, cMailBox, cFileName, cProcessDir, cValues, cStatusCode, cFrom, cField, cMsg
	local aFolders := {}, aObjFields := {}, aValues := {}, aMessage, aDest

	cMailBox := WFGetMV( "MV_WFMLBOX", "" )
	cProcessDir := WF_ROOTDIR + cEmpAnt + "\process\"
	
	if empty( ::oOwner:oVisioApp:cProcID )
		MsgAlert( STR0016 ) //"O código do processo não foi especificado."
		return
	end
	
	if empty( bUserFunction := AllTrim( ::cExecFunc ) )
		dbSelectArea("WFD")
		cFindKey := xFilial("WFD") + ::oOwner:oVisioApp:cProcCode + ::oOwner:oVisioApp:cProcID + StrZero( ::nID,4 )
		if dbSeek( cFindKey )
			dbSelectArea("WFA")
			dbSetOrder(2)
			cFindKey := xFilial("WFA") + lower( ::oOwner:oVisioApp:cProcID + WFD->WFD_TASKID )
			if ( dbSeek( cFindKey ) )
				cFileName := lower( AllTrim( WFA_IDENT ) )
				oMail := TWFMail():New()
				oMailBox := oMail:GetMailBox( cMailBox )
				if oMailBox:lExists
					oSentFolder := oMailBox:GetFolder( MBF_SENT )
				else
					cMsg := STR0033 //"Caixa de mensagem nao existente:"
					cMsg += " " + cMailBox + ". "
					cMsg += STR0034 //"Confirme no cadastro de parametros do workflow a caixa de correio utilizada."
					MsgAlert( cMsg )
					return
				end
			else
				MsgAlert(STR0035 ) //"Processo nao localizado."
				return
			end
		else
			MsgAlert(STR0036 ) //"Processo nao utilizado na rastreabilidade do Microsoft Visio."
			return
		end
		
		if oSentFolder:FileExists( cFileName + ".wfm" )
			aMessage := oSentFolder:LoadFile( cFileName + ".wfm" )
			if ( nPos1 := at( "<wfbodytag>", aMessage ) ) > 0 .and. ( nPos2 := at( "</wfbodytag>", aMessage ) ) > 0
				aMessage := stuff( aMessage, nPos1, ( nPos2 + 12 ) - nPos1, "" )
			else
				aMessage := strtran( aMessage, "'+chr(10)+'", "" )
				aMessage := strtran( aMessage, "'+chr(13)+'", "" )
				aMessage := strtran( aMessage, "'+chr(34)+'", '"' )
			end
			aMessage := &(aMessage)
			if len( aFile := Directory( oSentFolder:cRootPath + "\" + cFileName + ".wfm" ) ) > 0
				dDtSent := aFile[1,3]
				cHrSent := aFile[1,4]
			end
			if len( aFile := Directory( cProcessDir + "\" + cFileName + ".oct" ) ) > 0
				dDtInbox := aFile[1,3]
				cHrInbox := aFile[1,4]
				aValues := __runcb(__compstr(wfloadfile(cProcessDir + "\" + cFileName + ".oct" )))
				cFrom := lower(aValues[5])
				aValues := nil
				if (nPos1 := at("<", cFrom)) > 0
					cFrom := Substr( cFrom, nPos1 +1 )
					if (nPos1 := at(">", cFrom)) > 0
						cFrom := Left( cFrom, nPos1 -1 )
					end
				end
			end
			aDest := WFTokenChar( lower(aMessage[2]), ";" )
			for nC := 1 to len( aDest )
				AAdd( aFolders, aDest[ nC ] )
				if ( cFrom == aDest[ nC ] )
					AAdd( aObjFields, { dDtSent, cHrSent, dDtInbox, cHrInbox } )
				else
					AAdd( aObjFields, { dDtSent, cHrSent, CtoD("/"), "00:00" } )
				end
			next
			aDest := WFTokenChar( lower(aMessage[3]), ";" )
			for nC := 1 to len( aDest )
				AAdd( aFolders, aDest[ nC ] )
				if ( cFrom == aDest[ nC ] )
					AAdd( aObjFields, { dDtSent, cHrSent, dDtInbox, cHrInbox } )
				else
					AAdd( aObjFields, { dDtSent, cHrSent, CtoD("/"), "00:00" } )
				end
			next
			aDest := WFTokenChar( lower(aMessage[4]), ";" )
			for nC := 1 to len( aDest )
				AAdd( aFolders, aDest[ nC ] )
				if ( cFrom == aDest[ nC ] )
					AAdd( aObjFields, { dDtSent, cHrSent, dDtInbox, cHrInbox } )
				else
					AAdd( aObjFields, { dDtSent, cHrSent, CtoD("/"), "00:00" } )
				end
			next
		end
		
		DEFINE MSDIALOG oDlg FROM 0,0 TO 270,370 TITLE STR0008 PIXEL //"Destinatarios"

		oFolder := TFolder():New( 15, 03, aFolders, aFolders, oDlg, nFolder,,,.T., .T., 180, 115 )
		
		for nC := 1 to len( aFolders )
			@ 15, 05 GROUP oGroup TO 50,170 LABEL STR0039 OF oFolder:aDialogs[nC] PIXEL //" Envio: "
//			@ 20, 10 SAY aFolders[nC] COLOR CLR_RED FONT oFont OF oFolder:aDialogs[nC] PIXEL
			cField := aObjFields[nC,1]
			@ 28, 10 SAY STR0040 COLOR CLR_BLUE OF oFolder:aDialogs[nC] PIXEL //"Data:"
			@ 28, 40 MSGET aObjFields[nC,1] VAR cField READONLY SIZE 40,10 OF oFolder:aDialogs[nC] PIXEL
			aObjFields[nC,1]:bSetGet := &( "{|x| iif( pCount()==0, aObjFields[" + str(nC,3) + ",1], aObjFields[" + str(nC,3) + ",1] := x ) }" )

			cField := aObjFields[nC,2]
			@ 28,100 SAY STR0041 COLOR CLR_BLUE OF oFolder:aDialogs[nC] PIXEL //"Hora:"
			@ 28,120 MSGET aObjFields[nC,2] VAR cField PICTURE "99:99" READONLY SIZE 30,10 OF oFolder:aDialogs[nC] PIXEL
			aObjFields[nC,2]:bSetGet := &( "{|x| iif( pCount()==0, aObjFields[" + str(nC,3) + ",2], aObjFields[" + str(nC,3) + ",2] := x ) }" )

			@ 60, 05 GROUP oGroup TO 95,170 LABEL STR0042 OF oFolder:aDialogs[nC] PIXEL //" Retorno: "
			cField := aObjFields[nC,3]
			@ 73, 10 SAY STR0040 COLOR CLR_BLUE OF oFolder:aDialogs[nC] PIXEL //"Data:"
			@ 73, 40 MSGET aObjFields[nC,3] VAR cField PICTURE "@!" READONLY SIZE 40,10 OF oFolder:aDialogs[nC] PIXEL
			aObjFields[nC,3]:bSetGet := &( "{|x| iif( pCount()==0, aObjFields[" + str(nC,3) + ",3], aObjFields[" + str(nC,3) + ",3] := x ) }" )

			cField := aObjFields[nC,4]
			@ 73,100 SAY STR0041 COLOR CLR_BLUE OF oFolder:aDialogs[nC] PIXEL //"Hora:"
			@ 73,120 MSGET aObjFields[nC,4] VAR cField PICTURE "@!" READONLY SIZE 30,10 OF oFolder:aDialogs[nC] PIXEL
			aObjFields[nC,4]:bSetGet := &( "{|x| iif( pCount()==0, aObjFields[" + str(nC,3) + ",4], aObjFields[" + str(nC,3) + ",4] := x ) }" )
		next
		
//	   @ 15,05 FOLDER oFolder ITEMS aFolders[1], aFolders[2] OPTION nFolder SIZE 190,120 OF oDlg PIXEL
		

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar( oDlg, {|| oDlg:End() }, {|| oDlg:End()} ) )

	else
		if ( nPos := at( "(", bUserFunction ) ) > 0
			bUserFunction := Left( bUserFunction, nPos -1 )
		end
		if FindFunction( bUserFunction )
			bUserFunction := &( "{|x| " + bUserFunction + "( x ) }" )
			Eval( bUserFunction, oMsgDlg )
		end
	end
	
return

method FillForegnd( nColor ) class TWFShape
	local oCell := ::oShapeRef:CellsSRC( visSectionObject, visRowFill, 0 )
	oCell:Formula := nColor
return
