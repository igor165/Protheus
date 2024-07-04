#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRMA310.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA310

Rotina que faz a chamada para o cadastro de pedidos de venda, enviando o filtro

@sample		CRMA310( cVisao )

@param		    cVisao - Nome da visão a ser aberta inicialmente no browse 
				cAlias - Alias que está chamando a rotina

@return		Nenhum

@author		Thiago Tavares
@since		19/05/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA310( cVisao, cAlias )

Local cEntida    := Alias()
Local aAddFil    := {}
Local cFiltro    := CRMXFilEnt( "SC5", .T. )  //Pedidos de Venda
Local cFiltroEnt := ""
Local cCodUsr	 := If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
Local lMsg	 	 := .T.

Default cVisao   := ""
Default cAlias   := ""

If MPUserHasAccess("MATA410",/*nOpc*/,cCodUsr,lMsg)
		
	cFiltro	:= CRMXFilEnt( "SC5", .T. )  //Pedidos de Venda
	cAlias 	:= IIF(Empty(cAlias), cEntida, cAlias)
		
	If !Empty( cFiltro )
		aAdd( aAddFil, { STR0002, cFiltro, .T., .T., "AO4", /*lFilterAsk*/, /*aFilParser*/, "AO4_FILENT" } ) 	// "Filtro CRM"
	EndIf
		
	If ( !(FunName() == "CRMA310") .And. ProcName( 2 ) <> "CRMA290RFUN" )  .Or. ProcName( 1 ) == "CRMA710"
		If cAlias == "SA1" 
			cFiltroEnt := "C5_FILIAL = '"+xFilial("SC5")+"' .AND. C5_CLIENTE = '"+SA1->A1_COD+"' .AND. C5_LOJACLI = '"+SA1->A1_LOJA+"'"
			aAdd( aAddFil, { "Filtro Entidade", cFiltroEnt,.T., .T.,, /*lFilterAsk*/, /*aFilParser*/, "SC5_FILENT" } ) 	// "Filtro Entidade"
		EndIf	
	EndIf
	
	Mata410( /*xAutoCab*/, /*xAutoIens*/, /*nOpcAuto*/, /*lSimulacao*/, /*cRotina*/, /*cCodCli*/, /*cLoja*/, /*xRatCTBPC*/, /*xAdtPC*/, /*xParamAuto*/, /*lSigaDPR*/, /*cFilDef*/, aAddFil, cVisao )
EndIf

Return Nil
