#INCLUDE "PROTHEUS.CH" 
#INCLUDE "CRMA480.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA480
Rotina que faz a chamada para o cadastro de metas de venda  
@sample	CRMA480(cVisao)
@param		cVisao - Nome da visão a ser aberta inicialmente no browse 
@return	Nenhum
@author	Thiago Tavares
@since		19/05/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA480(cVisao)

Local aAddFil 	:= {}
Local cFilPri 	:= ""
Local cCodUsr	:= If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
Local lMsg		:= .T.

Default cVisao	:= ""

If MPUserHasAccess("FATA050",/*nOpc*/,cCodUsr,lMsg)
	cFilPri := CRMXFilEnt( "SCT", .T.)
	If !Empty( cFilPri )
		aAdd( aAddFil, { STR0002, cFilPri, .T., .T., "AO4", /*lFilterAsk*/, /*aFilParser*/, "AO4_FILENT" } ) //"Filtro CRM"
	EndIf
	FATA050(/*xRotAuto*/, /*aAutoItem*/, /*nOpc*/, /*cFilDef*/, aAddFil /*aAddFil*/, cVisao /*cVDefault*/)    // Metas de Venda
EndIf
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef - Operações que serão utilizadas pela aplicação
@return   	aRotina - Array das operações
@author	Vendas CRM
@since		15/05/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Private aRotina := StaticCall(FATA050, MENUDEF)
Return( aRotina )