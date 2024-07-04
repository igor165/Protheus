#INCLUDE "PROTHEUS.CH" 
#INCLUDE "CRMA520.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA520

Rotina que faz a chamada para o cadastro de vendedores

@sample	CRMA520()

@return	Nenhum

@author	Thiago Tavares
@since		19/05/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA520()

ProcRegua( 0 ) 
IncProc( STR0001 )	// "Só um momento, localizando os vendedores..." 

MATA040( /*aAuto*/, /*nOpcAuto*/ )    // Vendedores

Return Nil


//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

MenuDef - Operações que serão utilizadas pela aplicação

@return   	aRotina - Array das operações

@author		Vendas CRM
@since		15/05/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Private aRotina := StaticCall( MATA040 , MENUDEF )

Return( aRotina )