#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRMA460.CH"

 //------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA460

Rotina que faz a chamada para o service tracker  

@sample	CRMA460()

@return	Nenhum

@author	Thiago Tavares
@since		10/04/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA460()

ProcRegua( 0 ) 
IncProc( STR0001 )	// "S� um momento, localizando as informa��es..." 

TECC050( .T. )    // Service Tracker 

Return Nil



//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

MenuDef - Opera��es que ser�o utilizadas pela aplica��o

@return   	aRotina - Array das opera��es

@author		Vendas CRM
@since		15/05/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Private aRotina := StaticCall( TECC050 , MENUDEF )

Return( aRotina )