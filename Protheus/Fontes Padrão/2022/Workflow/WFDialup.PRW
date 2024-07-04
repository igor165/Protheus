#INCLUDE "WFDialup.ch"
#include "SigaWF.CH"


/******************************************************************************
	WFDialUpObj()
	Retorna o objeto da classe TDialUpConnection()
 *****************************************************************************/
function TWFDialUpObj()
return TDialUpConnection():New()


// ----------------------------------------------------------------------------
// TDialUpConnection
// Classe para "Conexao DialUp"
// ----------------------------------------------------------------------------
class TDialUpConnection
	data cEntry
	data cUserName
	data cPassword
	data cFoneNumber
	data cDevice
	data nTimeOut
	method New() CONSTRUCTOR
	method Setup( _cEntry, _cUserName, _cPassword, _cFoneNumber, _cDispDevice, _nTimeOut )
	method IsConnected() 
	method Connect( oLogFile )
	method Disconnect( oLogFile )
endclass

// Construtor da classe TDialUpConnection
method New() class TDialUpConnection
	::Setup()
return 

method Setup( _cEntry, _cUserName, _cPassword, _cFoneNumber, _cDispDevice, _nTimeOut ) class TDialUpConnection
	default _cEntry := "", _cUserName := "", _cPassword := "", _cFoneNumber := "", _cDispDevice := "", _nTimeOut := 60
	::cEntry := AllTrim( _cEntry )
	::cUserName	:= AllTrim( _cUserName )
	::cPassword := AllTrim( _cPassword )
	::cFoneNumber := AllTrim( _cFoneNumber )
	::cDevice := AllTrim( _cDispDevice )
	::nTimeOut := _nTimeOut
return 

// Api de baixo nivel retorna valor booleano de acordo com status DialUp do Windows...
method IsConnected() class TDialUpConnection
return MSRASIsConnected()

// Metodo abre conexao Dial-Up
method Connect( oLogFile ) class TDialUpConnection
	local cMsg
	local lResult := .f.
	local nC := 1, nMax := 4, nCount

	default oLogFile := WFStream()
	
	while ( nC <= nMax ) .and. !( lResult )
	
		if nC > 1
			::Disconnect( oLogFile )
			if nC < nMax
				cMsg := FormatStr( STR0001, nC ) //"%99n# - Proxima tentativa de conexao em 20 segundos."
			else
				cMsg := FormatStr( STR0002, nC ) //"%99n# - Ultima tentativa de conexao em 20 segundos."
			end
			WFConOut( cMsg, oLogFile, .f. )
			Sleep( 20000 )
		end	

		cMsg := FormatStr( STR0003 + "...[ %c ]", ::cEntry ) //"Discando a conexao Dial-up
		WFConOut( cMsg, oLogFile, .f. )
		nCount := 1
		
		while ( nCount < 5 ) .and. !( lResult )

			if !( lResult := MSRASDial( ::cEntry, ::cUserName, ::cPassword, ::cFoneNumber ) )
				Sleep( 2000 )
			end

			nCount++
		end

		if !( lResult )
//			cMsg := "Nao foi possivel discar a conexao Dial-up. Erro: " + MSRASGetStringError( MSRASGetLastError() )
			cMsg := STR0004 //"Nao foi possivel discar a conexao Dial-up."
			WFConOut( cMsg, oLogFile, .f. )
		end

		nC++
	end
	
return lResult

// Metodo encerra a conexao
method Disconnect( oLogFile ) class TDialUpConnection
	local cMsg := FormatStr( STR0005 + "...[ %c ]", ::cEntry ) //"Desconectando a conexão Dial-up

	if ::IsConnected()
		WFConOut( cMsg, oLogFile, .f. )
		MSRASHangUp()
	end	
	
return
