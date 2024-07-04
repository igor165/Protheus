#INCLUDE "PROTHEUS.CH" 
#INCLUDE "CRMA330.CH"
 
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA330

Rotina que faz a chamada para o cadastro de apontamentos 

@sample		CRMA330( cVisao )

@param		cVisao - Nome da visão a ser aberta inicialmente no browse 

@return		Nenhum

@author		Victor Bitencourt
@since		19/05/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA330( cVisao, aFilter )

Local cAlias    := Alias()
Local aAddFil   := {}
Local cFilPri   := ""	
Local lNoCheck  := .T. 
Local lSelected := .T.
Local cAliasFil := "AO4"
Local cFilEnt   := "" //Varialvel com filtro para registro posicionado
Local nX        := 0
Local lMsg		:= .T.
Local cCodUsr	:= If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())

Default cVisao	:= ""  
Default aFilter	:= {} 

Static aCRM330Ent	:= {}

If MPUserHasAccess("FATA310",/*nOpc*/,cCodUsr,lMsg)
	
	cFilPri := CRMXFilEnt("AD5",.T.)
	
	If !Empty(aFilter)
		For nX := 1 to Len(aFilter) 
			aAdd( aAddFil, { STR0001, aFilter[nX][2], lNoCheck, lSelected, aFilter[nX][5], /*lFilterAsk*/, /*aFilParser*/, aFilter[nX][8] } ) //"Filtro CRM"
		Next
	EndIf
	
	If !Empty( cFilPri ) 
		aAdd( aAddFil, { STR0001, cFilPri, lNoCheck, lSelected, cAliasFil, /*lFilterAsk*/, /*aFilParser*/, "AO4_FILENT" } ) //"Filtro CRM"
	EndIf
	
	If !( FunName() == "CRMA330" ) .And. ProcName( 2 ) <> "CRMA290RFUN" 
		Do Case 
			Case cAlias == "SA1"
				cFilEnt := "AD5_FILIAL = '" + xFilial( "AD5" ) + "' .AND. AD5_CODCLI = '" + SA1->A1_COD + "' .AND. AD5_LOJA = '" + SA1->A1_LOJA + "'"
				aCRM330Ent := { "SA1", SA1->A1_COD, SA1->A1_LOJA }
			Case cAlias == "SUS"
				cFilEnt := "AD5_FILIAL = '" + xFilial( "AD5" ) + "' .AND. AD5_PROSPE = '" + SUS->US_COD + "' .AND. AD5_LOJPRO = '" + SUS->US_LOJA + "'"
				aCRM330Ent := { "SUS", SUS->US_COD, SUS->US_LOJA }
			Case cAlias == "AD1"
				cFilEnt := "AD5_FILIAL = '" + xFilial( "AD5" ) + "' .AND. AD5_NROPOR = '" + AD1->AD1_NROPOR + "'"
		EndCase		
	EndIf
	
	If !Empty( cFilEnt )
		aAdd( aAddFil, { STR0002, cFilEnt, lNoCheck, lSelected, "AD5", /*lFilterAsk*/, /*aFilParser*/, "FIL_ENT" } ) //"Filtro de Entidade"
	EndIf

	FATA310( /*xAutoCab*/, /*xAutoItens*/, /*nOpcAuto*/, /*cFilDef*/, aAddFil, cVisao )	// Apontamentos

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

Private aRotina := StaticCall( FATA310 , MENUDEF )

Return( aRotina )

/*/ {Protheus.doc} CRMA330Ent

Rotina para retornar o valora da variavel aCRM330Ent que contem os valores do registro posicionado

@sample	CRMA330Ent()

@param		Nenhum

@return   Array contendo os dados do registro posicionado	

@author	Victor Bitencourt
@since		01/04/2014
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA330Ent()
Return ( aCRM330Ent )
