#INCLUDE "PROTHEUS.CH" 
#INCLUDE "CRMA340.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA340

Rotina que faz a chamada para o cadastro de eventos

@sample	CRMA340()

@return	Nenhum

@author	Thiago Tavares
@since		19/05/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA340()

Local aAddFil := {}
Local cCodUsr := If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
Local cFilPri := ""
Local lMsg    := .T.

If MPUserHasAccess("TMKA340",/*nOpc*/,cCodUsr,lMsg)

	cFilPri := CRMXFilEnt( "ACD", .T. )
	
	If !Empty( cFilPri ) 
		aAdd( aAddFil, { STR0002, cFilPri, .T., .T., "AO4", /*lFilterAsk*/, /*aFilParser*/, "AO4_FILENT" } ) //"Filtro CRM"
	EndIf
	
	TMKA340( /*cFilDef*/, aAddFil )    // Eventos
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

Private aRotina := StaticCall( TMKA340 , MENUDEF )

Return( aRotina )