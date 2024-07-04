#INCLUDE "PROTHEUS.CH" 
#INCLUDE "CRMA350.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA350

Rotina que faz a chamada para o cadastro de scripts dinamicos

@sample	CRMA350()

@return	Nenhum

@author	Thiago Tavares
@since		19/05/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA350()

Local aAddFil	:= {} 
Local cFilPri	:= ""
Local cCodUsr	:= IIF(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
Local lMsg	:= .T.	

If MPUserHasAccess("TMKA360",/*nOpc*/,cCodUsr,lMsg)
	
	cFilPri := CRMXFilEnt( "SUZ", .T.)
	
	If !Empty( cFilPri ) 
		aAdd( aAddFil, { STR0002, cFilPri, .T., .T., "AO4", /*lFilterAsk*/, /*aFilParser*/, "AO4_FILENT" } ) //"Filtro CRM"
	EndIf
	
	TMKA360( /*cFilDef*/, aAddFil )		// Scripts Dinâmico
EndIf

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

Private aRotina := StaticCall( TMKA360 , MENUDEF )

Return( aRotina )