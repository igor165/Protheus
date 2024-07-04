#INCLUDE "PROTHEUS.CH" 
#INCLUDE "CRMA530.CH"
#INCLUDE "CRMDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA530

Rotina que faz a chamada para o cadastro de metas de venda  

@sample		CRMA530( cVisao )

@param		cVisao - Nome da visão a ser aberta inicialmente no browse 

@return		Nenhum

@author		Thiago Tavares
@since		19/05/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA530( cVisao, aFilter )

Local aAddFil  	:= {}
Local cFilPri  	:= ""
Local nX 		:= 0
Local cCodUsr	:= If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
Local lMsg		:= .T.

Default cVisao := ""
Default aFilter := {}

If MPUserHasAccess("TMKA061",/*nOpc*/,cCodUsr,lMsg)
	
	cFilPri  := CRMXFilEnt( "SU4", .T.)
	
	If !Empty( cFilPri ) 
		aAdd( aAddFil, { STR0002, cFilPri, .T., .T., "AO4", /*lFilterAsk*/, /*aFilParser*/, "AO4_FILENT" } ) //"Filtro CRM"
	EndIf
	
	// adicionando filtro para ver somente listas criadas no modulo crm
	aAdd( aAddFil, { STR0003, "!Empty( U4_ENTIDA )", .T., .T.,, /*lFilterAsk*/, /*aFilParser*/, "SU4_LISTCRM" } ) //"Listas CRM"
	
	If !Empty(aFilter)
		For nX := 1 To Len(aFilter)
			aAdd( aAddFil, {aFilter[nX][ADDFIL_TITULO], aFilter[nX][ADDFIL_EXPR], aFilter[nX][ADDFIL_NOCHECK],;
							  aFilter[nX][ADDFIL_SELECTED], aFilter[nX][ADDFIL_ALIAS], aFilter[nX][ADDFIL_FILASK], aFilter[nX][ADDFIL_FILPARSER], aFilter[nX][ADDFIL_ID] } )
		Next nX
	EndIf
	
	TMKA061( /*xAutoCab*/, /*xAutoItens*/, /*nOpcAuto*/, /*cFilDef*/, aAddFil, cVisao )    // Listas de Contatos
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

Private aRotina := StaticCall( TMKA061 , MENUDEF )

Return( aRotina )