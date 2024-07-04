#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRMA110.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/ {Protheus.doc} CRMA110
Rotina que faz a chamada para o cadastro oportunidades de venda, enviando o filtro
@sample		CRMA110( cVisao )
@param		cVisao - Nome da visão a ser aberta inicialmente no browse 
@return		Nenhum
@author		Anderson Silva
@since		30/04/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA110( cVisao, cAlias )

Local aAddFil   	:= {}
Local cFilPri   	:= ""
Local lNoCheck  	:= .T. 
Local lSelected		:= .T.
Local lMsg			:= .T.
Local cAliasFil		:= "AO4"
Local cFilEnt		:= ""
Local cCodUsr		:= If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr()) 	

Static aCRM110Ent := {}

Default cVisao := ""  
Default cAlias := Alias()
If MPUserHasAccess("FATA300",/*nOpc*/,cCodUsr,lMsg)
	
	cFilPri   := CRMXFilEnt( "AD1", .T. )
	
	If !Empty( cFilPri )
		aAdd( aAddFil, { STR0006, cFilPri, lNoCheck, lSelected, cAliasFil, /*lFilterAsk*/, /*aFilParser*/, "AO4_FILENT" } )		// "Filtro do CRM"
	EndIf	
	
	If ( !( FunName() == "CRMA110" ) .And. ProcName( 2 ) <> "CRMA290RFUN" ) .Or. IsInCallStack( 'CRMA710' )
		If cAlias == "SA1"
			cFilEnt := " AD1_FILIAL == '" + xFilial( "AD1" ) + "' .AND. AD1_CODCLI == '" + SA1->A1_COD + "' .AND. AD1_LOJCLI == '" + SA1->A1_LOJA + "'"
			aCRM110Ent := { "SA1", SA1->A1_COD, SA1->A1_LOJA } 
		ElseIf cAlias == "SUS"
			cFilEnt := " AD1_FILIAL == '" + xFilial( "AD1" ) + "' .AND. AD1_PROSPE == '" + SUS->US_COD + "' .AND. AD1_LOJPRO == '" + SUS->US_LOJA + "'"
			aCRM110Ent := { "SUS", SUS->US_COD, SUS->US_LOJA } 
		EndIf 
	EndIf
	
	If !Empty( cFilEnt )
		aAdd( aAddFil, { STR0007, cFilEnt, lNoCheck, lSelected, "AD1", /*lFilterAsk*/, /*aFilParser*/, "FIL_ENT" } )		// "Filtro de Entidade"
	EndIf
	
	FATA300(/*nOperation*/,/*aAD1Master*/,/*aAD2Detail*/,/*aAD3Detail*/,;
			 /*aAD4Detail*/,/*aAD9Detail*/,/*aADJDetail*/,/*cFilDef*/	 ,;
			 aAddFil, cVisao ) 

	aCRM110Ent := {}
EndIf
		 
Return Nil

//------------------------------------------------------------------------------
/*/ {Protheus.doc} CRMA110Ent
Rotina para retornar o valora da variavel aCRM110Ent que contem os valores do registro posicionado
@sample	CRMA110Ent()
@param		Nenhum
@return   Array contendo os dados do registro posicionado	
@author	Victor Bitencourt
@since		01/04/2014
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA110Ent()
Return ( aCRM110Ent )

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

Local nPos			:= 0
Local nX			:= 0
Local lPyme			:= IIf(Type("__lPyme")<>"U", __lPyme, .F.)		
Local lOrcSimp		:= SuperGetMV('MV_ORCSIMP',,'2') == '1'
Local aAtiv			:= {}
Local aAnotac		:= {}
Local aEntRelac		:= {}
Local aRotina		:= FWLoadMenuDef("FATA300")

If !lPyme .And. !lOrcSimp
	// Solicitação de Vistoria Técnica para o Módulo SIGACRM
	ADD OPTION aRotina TITLE STR0008 ACTION "TECA290" OPERATION 4 ACCESS 0 	// "Solicitação Vistoria Técnica"
EndIf

ADD OPTION aEntRelac TITLE STR0009 ACTION "CRMA200('AD1')" OPERATION 8 ACCESS 0 	// "Privilégios"

aEntRelac	:= CRMXIncRot("AD1", aEntRelac)

nPos		:= aScan(aEntRelac, {|x| IIF(ValType(x[2]) == "C", x[2] == "CRMA190Con()", Nil)})
If nPos > 0
	ADD OPTION aRotina TITLE aEntRelac[nPos][1] ACTION aEntRelac[nPos][2] OPERATION 8  ACCESS 0	// "Conectar"
	Adel(aEntRelac, nPos)
	Asize(aEntRelac, Len(aEntRelac)-1)
EndIf

nPos		:= aScan(aEntRelac, {|x|  IIF(ValType(x[2]) == "C", x[2] == "CRMA180()", Nil)})
If nPos > 0
	ADD OPTION aAtiv TITLE STR0010 ACTION "CRMA180(,,,3,,)" OPERATION 3 ACCESS 0	// "Nova Atividade"
	ADD OPTION aAtiv TITLE STR0011 ACTION "CRMA180()"       OPERATION 8 ACCESS 0	// "Todas as ATividades"
	aEntRelac[nPos][2]		:= aAtiv
EndIf

nPos		:= aScan(aEntRelac, {|x| IIF(ValType(x[2]) == "C", x[2] == "CRMA090()", Nil)})
If nPos > 0
	ADD OPTION aAnotac TITLE STR0012 ACTION "CRMA090(3)" OPERATION 3 ACCESS 0	// "Nova Anotação"
	ADD OPTION aAnotac TITLE STR0013 ACTION "CRMA090()"  OPERATION 8 ACCESS 0	// "Todas as Anotações"
	aEntRelac[nPos][2]		:= aAnotac
EndIf

If Len(aEntRelac) > 0 .AND. ( nPos := aScan(aRotina, {|x| x[1] == STR0014}) ) > 0	//"Relacionadas"
	For nX := 1 to Len(aEntRelac)
		aAdd(aRotina[nPos,02], aEntRelac[nX])
	Next nX
	aSort(aRotina[nPos,02],,,{| x,y | y[1] > x[1]})
EndIf
Return aRotina