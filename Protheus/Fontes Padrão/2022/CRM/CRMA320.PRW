#INCLUDE "PROTHEUS.CH" 
#INCLUDE "CRMA320.CH"
#INCLUDE "CRMDEF.CH"
#INCLUDE "TCBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA320

Rotina que faz a chamada para o cadastro de Suspects

@sample	CRMA320()

@return	Nenhum

@author	Victor Bitencourt 
@since		19/05/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA320(aFilter)

Local cFilPri 		:= ""
Local lNoCheck  	:= .T. 
Local lSelected 	:= .T.
Local nX 			:= 0
Local aAddFil 		:= {}
Local cCodUsr		:= If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
Local lMsg			:= .T.	

Default aFilter 	:= {}

If MPUserHasAccess("TMKA341",/*nOpc*/,cCodUsr,lMsg)
	
	cFilPri	:= CRMXFilEnt( "ACH", .T. )
	
	If !Empty( cFilPri ) 
		aAdd( aAddFil, { STR0002, cFilPri, .T., .T., "AO4", /*lFilterAsk*/, /*aFilParser*/, "AO4_FILENT" } ) //"Filtro CRM"
	EndIf
	
	If !Empty(aFilter)
		For nX := 1 To Len(aFilter)
			aAdd( aAddFil, {aFilter[nX][ADDFIL_TITULO], aFilter[nX][ADDFIL_EXPR], aFilter[nX][ADDFIL_NOCHECK],;
							  aFilter[nX][ADDFIL_SELECTED], aFilter[nX][ADDFIL_ALIAS], aFilter[nX][ADDFIL_FILASK], aFilter[nX][ADDFIL_FILPARSER], aFilter[nX][ADDFIL_ID] } )
		Next nX
	EndIf
	
	TMKA341( /*xRotAuto*/, /*nOpc*/, /*cFilDef*/, aAddFil ) // Suspects 

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

Local nPos       := 0
Local aEntRelac  := {}
Local aAtiv      := {}
Local aAnotac    := {}
Local aCamp      := {}
Local nX		 := 0
Local aRotina    := FWLoadMenuDef("TMKA341")
Local nPosEntR   := 0

ADD OPTION aCamp	 TITLE STR0003   ACTION "CRMA360(,'ACH')"	 OPERATION  8 ACCESS 0  //"Campanhas"
ADD OPTION aCamp 	 TITLE STR0004   ACTION "CRMA250('ACH')"	 OPERATION  8 ACCESS 0  //"Campanhas Rápidas"	
ADD OPTION aEntRelac TITLE STR0003   ACTION aCamp	             OPERATION  8 ACCESS 0  //"Campanhas"
ADD OPTION aEntRelac TITLE STR0005   ACTION "CRMA200('ACH')" 	 OPERATION 8  ACCESS 0//"Privilégios"
ADD OPTION aEntRelac TITLE STR0006   ACTION "CRMA620(Nil, 'ACH', ACH->ACH_CODIGO, ACH->ACH_LOJA, ACH->ACH_CODSEG, 1)"  OPERATION 2  ACCESS 0 	//Subsegmentos

aEntRelac := CRMXINCROT( "ACH", aEntRelac )
	
nPos := aScan(aEntRelac, { |x| IIF(ValType(x[2]) == "C", x[2] == "CRMA190Con()",Nil) })
If nPos > 0 
	ADD OPTION aRotina TITLE aEntRelac[nPos][1] ACTION aEntRelac[nPos][2] OPERATION 8  ACCESS 0//"Conectar"
	Adel(aEntRelac,nPos)
	Asize(aEntRelac,Len(aEntRelac)-1)
EndIf

nPos := aScan(aEntRelac, { |x|  IIF(ValType(x[2]) == "C", x[2] == "CRMA180()", Nil) })
If nPos > 0
	ADD OPTION aAtiv   TITLE STR0007 ACTION "CRMA180(,,,3,,)" OPERATION 3  ACCESS 0 //"Nova Atividade" 
	ADD OPTION aAtiv   TITLE STR0008 ACTION "CRMA180()"       OPERATION 8  ACCESS 0 //"Todas as ATividades"
	aEntRelac[nPos][2] := aAtiv
EndIf
	
nPos := aScan(aEntRelac, { |x| IIF(ValType(x[2]) == "C", x[2] == "CRMA090()", Nil)})
If nPos > 0
	ADD OPTION aAnotac   TITLE STR0009 ACTION "CRMA090(3)" OPERATION 3  ACCESS 0 //"Nova Anotação"
	ADD OPTION aAnotac   TITLE STR0010 ACTION "CRMA090()"  OPERATION 8  ACCESS 0 //"Todas as Anotações" 
	aEntRelac[nPos][2] := aAnotac
EndIf

nPosEntR := aScan(aRotina,{|x| ValType(x[2]) == "A"})
If nPosEntR > 0 
	For nX := 1 To Len( aEntRelac )
		aAdd(aRotina[nPosEntR][2],aEntRelac[nX])
	Next nX
	Asort(aRotina[nPosEntR][2],,,{ | x,y | y[1] > x[1] } )
EndIf

Return( aRotina )