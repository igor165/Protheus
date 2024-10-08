#INCLUDE "PROTHEUS.CH" 
#INCLUDE "CRMA510.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA510

Rotina que faz a chamada para o cadastro de fornecedores

@sample	CRMA510()

@return	Nenhum

@author	Thiago Tavares
@since		19/05/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA510()

ProcRegua( 0 ) 
IncProc( STR0001 )	// "S� um momento, localizando os fornecedores..." 

MATA020( /*aRotAuto*/, /*nOpcAuto*/ )    // Fornecedores

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

Private aRotina := StaticCall( MATA020 , MENUDEF )

Return( aRotina )