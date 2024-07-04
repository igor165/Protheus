#INCLUDE "PROTHEUS.CH" 
#INCLUDE "CRMA380.CH"
#INCLUDE "CRMDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA380

Rotina que faz a chamada para o cadastro de banco de conhecimento

@sample	CRMA380()

@return	Nenhum

@author	Thiago Tavares
@since		19/05/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA380(aFilter)

Local aAddFil 	:= {}
Local cFilPri 	:= ""
Local nX 		:= 0
Local cCodUsr	:= If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
Local lMsg		:= .T.	

Default aFilter := {}

If MPUserHasAccess("FATA340",/*nOpc*/,cCodUsr,lMsg)

	cFilPri := CRMXFilEnt( "ACB", .T.)
	
	If !Empty( cFilPri ) 
		aAdd( aAddFil, { STR0002, cFilPri, .T., .T., "AO4", /*lFilterAsk*/, /*aFilParser*/, "AO4_FILENT" } ) //"Filtro CRM"
	EndIf
	
	If !Empty(aFilter) 
		For nX := 1 To Len(aFilter)
			aAdd( aAddFil, {	aFilter[nX][ADDFIL_TITULO]		,;
								aFilter[nX][ADDFIL_EXPR]		,;
								aFilter[nX][ADDFIL_NOCHECK]		,;
							  	aFilter[nX][ADDFIL_SELECTED]	,;
							  	aFilter[nX][ADDFIL_ALIAS]		,;
							  	aFilter[nX][ADDFIL_FILASK]		,;
							  	aFilter[nX][ADDFIL_FILPARSER]	,;
							  	aFilter[nX][ADDFIL_ID] } )
		Next nX
	EndIf
	
	FATA340( /*cRotina*/, /*bBlock*/, /*nOper*/, /*cFilDef*/, aAddFil )			// Banco de Conhecimento
	
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

Private aRotina := StaticCall( FATA340 , MENUDEF )

Return( aRotina )