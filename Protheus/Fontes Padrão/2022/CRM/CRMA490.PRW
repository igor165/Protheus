#INCLUDE "PROTHEUS.CH" 
#INCLUDE "CRMA490.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA490

Rotina que faz a chamada para o cadastro de concorrentes

@sample	CRMA490()

@return	Nenhum

@author	Thiago Tavares
@since		19/05/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA490()

ProcRegua( 0 ) 
IncProc( STR0001 )	// "Só um momento, localizando os concorrentes..." 

FATA020()    //Concorrentes 

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

Private aRotina := StaticCall( FATA020 , MENUDEF )

Return( aRotina )