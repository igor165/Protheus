#include "protheus.ch"
#include "fileio.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} NGIsRoute
Modelo de rotas REST

@author  Marcelo Camargo
@since   15/03/2016
@version P11/P12
@param   aUrl - Lista de paths vindos do webservice
@param   cPath - Caminho esperado com padrao para verificacao
@return  logic
/*/
//---------------------------------------------------------------------
Function NGIsRoute( aUrl, cPath )
    Local nI
    Local aPath := StrTokArr( cPath, '/' )

    If Len( aUrl ) <> Len( aPath )
        Return .F.
    EndIf

    For nI := 1 To Len( aUrl )
        If !( aPath[ nI ] == aUrl[ nI ] ) .And. !( SubStr( aPath[ nI ], 1, 1 ) == '{' )
            Return .F.
        EndIf
    Next nI
    Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ReadBytes
Captura os bytes de um arquivo

@author  Marcelo Camargo
@since   30/08/2016
@version P11/P12
@return  logic
/*/
//---------------------------------------------------------------------
Static Function ReadBytes( cFileName )
    Local nHandler := FOpen( cFileName, FO_READWRITE + FO_SHARED )
    Local nSize    := 0
    Local xBuffer  := ''

    If -1 == nHandler
        Return Nil
    EndIf

    nSize := FSeek( nHandler, 0, FS_END )
    FSeek( nHandler, 0 )
    FRead( nHandler, xBuffer, nSize )
    FClose( nHandler )
    Return xBuffer
