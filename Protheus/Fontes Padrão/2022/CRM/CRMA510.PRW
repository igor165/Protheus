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
IncProc( STR0001 )	// "Só um momento, localizando os fornecedores..." 

MATA020( /*aRotAuto*/, /*nOpcAuto*/ )    // Fornecedores

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

Private aRotina := StaticCall( MATA020 , MENUDEF )

Return( aRotina )