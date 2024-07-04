#INCLUDE "PROTHEUS.CH" 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA400

Rotina que faz a chamada para a estrutura de clientes

@sample	CRMA400()

@return	Nenhum

@author	Thiago Tavares
@since		19/05/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA400()

FATA120( /*lVis*/, .T. )		// Estrutura de Clientes

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

Private aRotina := StaticCall( FATA120 , MENUDEF )

Return( aRotina )