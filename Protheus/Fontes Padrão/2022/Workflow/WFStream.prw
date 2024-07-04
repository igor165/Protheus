#include "sigawf.CH"

function WFStream( cText )
return TWFStream():New( cText )


class TWFStream
	data cBuffer
	method New( cText ) constructor
	method Find( cText, lSensitive )
	method Pos( cText, lSensitive )
	method Replace( cSearch, cText, nStart, nCount )
	method Clear()
	method Concat( cText )
	method Left( nCount )
	method Right( nCount )
	method SubStr( nStart, nCount )
	method UpperStr()
	method LowerStr()
	method IsEmpty()
	method IsUpper()
	method IsLower()
	method IsDigit()
	method IsAlpha()
	method HardCR()
	method Compare( cText, lSensitive )
	method WriteLN( cText )
	method ReadLN( nLineNumber, nLineLenght, nTabSize, lWrap )
	method SetBuffer( cText )
	method GetBuffer()
endclass

method New( cText ) class TWFStream
	default cText := ""
	::cBuffer := cText
return

method Clear() class TWFStream
	::cBuffer := ""
return

method Find( cText, lSensitive ) class TWFStream
	local Result := 0
	if ValType( cText ) == "C"
		Result := ::Pos( cText, lSensitive ) > 0
	end
return Result

method Pos( cText, lSensitive ) class TWFStream
	local Result := 0
	default lSensitive := .t.
	if ValType( cText ) == "C"
		Result := if( lSensitive, At( cText, ::cBuffer ), At( Lower( cText ), Lower( ::cBuffer ) ) )
	end
return Result

method Replace( cSearch, cText, nStart, nCount ) class TWFStream
	default nStart := 1
	if ValType( cSearch ) == "C" .and. ValType( cText ) == "C"
		::cBuffer := StrTran( ::cBuffer, cSearch, cText, nStart, nCount )
	end
return

method SetBuffer( cText ) class TWFStream
	if cText <> nil 
		::cBuffer := AsString( cText )
	end
return

method GetBuffer( lHTML ) class TWFStream  
    Default lHTML := .F. 
    
    If ( lHTML )
      	::cBuffer := StrTran( ::cBuffer, Chr( 13 ) + Chr( 10 ) , '<br>' ) 
    EndIf 		
return ::cBuffer

method IsEmpty() class TWFStream
return Empty( ::cBuffer )

method Concat( cText ) class TWFStream
	if cText <> nil .and. ::cBuffer <> nil
		::cBuffer += cText
	end
return ::cBuffer

method Left( nCount ) class TWFStream
	default nCount := 0
return Left( ::cBuffer, nCount )

method Right( nCount ) class TWFStream
	default nCount := 0
return Right( ::cBuffer, nCount )

method SubStr( nStart, nCount ) class TWFStream
return SubStr( ::cBuffer, nStart, nCount )

method UpperStr( cText ) class TWFStream
return Upper( ::cBuffer )

method LowerStr( cText ) class TWFStream
return Lower( ::cBuffer )

method IsUpper() class TWFStream
return IsUpper( ::cBuffer )

method IsLower() class TWFStream
return IsLower( ::cBuffer )

method IsDigit() class TWFStream
return IsDigit( ::cBuffer )

method IsAlpha() class TWFStream
return IsAlpha( ::cBuffer )

method HardCR() class TWFStream
return StrTran( ::cBuffer, Chr( 141 ), Chr( 13 ) )

method Compare( cText, lSensitive ) class TWFStream
	local Result := .f.
	default lSensitive := .t.
	if ValType( cText ) == "C"
		Result := if( lSensitive, ( cText == ::cBuffer ), ( Lower( cText ) == Lower( ::cBuffer ) ) )
	end
return Result

method WriteLN( cText ) class TWFStream
	if cText <> nil
		::Concat( Chr( 13 ) + Chr( 10 ) + AsString( cText ) )
	end
return

method ReadLN( nLineNumber, nLineLenght, nTabSize, lWrap ) class TWFStream
	local Result := ""
	default nLineNumber := 1, nLineLenght := 254, nTabSize := 3, lWrap := .f.
	if !Empty( ::cBuffer )
		Result := MemoLine( ::HardCR(), nLineLenght, nLineNumber, nTabSize, lWrap )
	end
return Result
