#include "sigawf.ch"

Function WFFileSpec( cFile )
return WFTFileSpec():New( cFile )

class WFTFileSpec
	data hFile
	data cFileName
	method New( cFile ) constructor
	method HardCR()
	method WriteLN( cLineText )
	method ReadLN( nLineNumber, nLineLenght, nTabSize, lWrap )
	method Replace( cSearch, cText, nStart, nCount )
	method SetBuffer( cText )
	method GetBuffer()
	method Pos( cText, lSensitive )
	method Close()
	method Open( cFile )
endclass

method New( cFile ) class WFTFileSpec
	::Open( cFile )
return

method HardCR() class WFTFileSpec
return StrTran( ::GetBuffer(), Chr( 141 ), Chr( 13 ) )

method WriteLN( cLineText ) class WFTFileSpec
	default cLineText := ""
	if ( ::hFile <> -1 )
		cLineText += Chr( 13 ) + Chr( 10 )
		WFSeek( ::hFile, 0, FS_END )
		WFWrite( ::hFile, cLineText )
	end
return

method ReadLN( nLineNumber, nLineLenght, nTabSize, lWrap ) class WFTFileSpec
	default nLineNumber := 1, nLineLenght := 254, nTabSize := 3, lWrap := .f.
return MemoLine( ::HardCR(), nLineLenght, nLineNumber, nTabSize, lWrap )

method Replace( cSearch, cText, nStart, nCount ) class WFTFileSpec
	default nStart := 1
	if ValType( cSearch ) == "C" .and. ValType( cText ) == "C"
		::SetBuffer( StrTran( ::GetBuffer(), cSearch, cText, nStart, nCount ) )
	end
return

method SetBuffer( cBuffer ) class WFTFileSpec
	local lResult := .f.
	default cBuffer := ""
	if ( ::hFile <> -1 )
		cBuffer := AsString( cBuffer )
		lResult := ( WFWrite( ::hFile, cBuffer, Len( cBuffer ) ) <> -1 )
	end
return lResult

method GetBuffer() class WFTFileSpec
	local cResult := "", cBuffer := ""
	local nLen, nBytes := 4096
	if ( ::hFile <> -1 )
		nLen := WFSeek( ::hFile, 0, FS_END )
		WFSeek( ::hFile, 0, FS_SET )
		while nLen > 0
			if nBytes > nLen
				nBytes := nLen
			end
			nBytes := WFRead( ::hFile, @cBuffer, nBytes )
			cResult += cBuffer
			nLen -= nBytes
		end
	end	
return cResult

method Pos( cText, lSensitive ) class WFTFileSpec
	local nResult := 0
	default lSensitive := .t.
	if ValType( cText ) == "C"
		nResult := if( lSensitive, At( cText, ::GetBuffer() ), At( Lower( cText ), Lower( ::GetBuffer() ) ) )
	end
return nResult

method Close() class WFTFileSpec
	if ( ::hFile <> -1 )
		FClose( ::hFile )
	end
	::hFile := -1
return 

method Open( cFile ) class WFTFileSpec
	local lResult := .f.
	::Close()
	if file( cFile )
		lResult := ( ::hFile := WFOpen( cFile, FO_READWRITE ) ) <> -1
	else
		lResult := ( ::hFile := WFCreate( cFile ) ) <> -1
	end
return lResult
