#INCLUDE "PROTHEUS.CH" 
#INCLUDE "CRMA360.CH" 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA360

Rotina que faz a chamada para o cadastro de campanhas

@sample		CRMA360( cVisao )

@param		cVisao - Nome da visão a ser aberta inicialmente no browse 

@return		Nenhum

@author		Thiago Tavares
@since		19/05/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA360( cVisao, cAlias )

Local cFiltroEnt:= ""
Local aAddFil   := {}
Local aDadosSX2	:= {}
Local cCodUsr	:= If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
Local lMsg		:= .T.	
Local cFilPri   := ""

Default cVisao 	:= ""
Default cAlias	:= ""

If MPUserHasAccess("TMKA310",/*nOpc*/,cCodUsr,lMsg)
	
	cFilPri := CRMXFilEnt( "SUO", .T.)
	
	If !Empty( cFilPri ) 
		aAdd( aAddFil, { STR0002, cFilPri, .T., .T., "AO4", /*lFilterAsk*/, /*aFilParser*/, "AO4_FILENT" } ) //"Filtro CRM"
	EndIf
	
	If !( FunName() == "CRMA360" ) .And. ProcName( 2 ) <> "CRMA290RFUN" 
		aDadosSX2  := CRMXGetSX2(cAlias)
		If !Empty(aDadosSX2)
			cCodEnt := (cAlias)->&(aDadosSX2[1])
			cFiltroEnt := "AOG_ENTIDA = '"+cAlias+"' AND AOG_CHAVE = '"+xFilial(cAlias)+cCodEnt+"' AND D_E_L_E_T_ = ''"
			aAdd( aAddFil, {STR0003, cFiltroEnt, .T., .T., "AOG", /*lFilterAsk*/, /*aFilParser*/, "AOG_FILENT" } ) //"Filtro de Entidade"
		EndIf	
	EndIf
	
	TMKA310( /*cFilDef*/, aAddFil, cVisao )		// Campanhas
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

Private aRotina := StaticCall( TMKA310 , MENUDEF )

Return( aRotina )