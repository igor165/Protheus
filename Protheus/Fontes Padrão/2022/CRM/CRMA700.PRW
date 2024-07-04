#INCLUDE "PROTHEUS.CH" 
#Include 'CRMA700.CH'
#Include 'FWMVCDEF.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA700

Rotina que faz a chamada para o cadastro de Prospect

@sample	CRMA700(cVisao)

@param		cVisao - Nome da visão a ser aberta inicialmente no browse 

@return	Nenhum

@author	 Totvs
@since	 15/05/2015
@version P12          
/*/
//------------------------------------------------------------------------------
Function CRMA700(cVisao,aAddFil)

Local cFilPri	:= ""
Local cCodUsr	:= If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
Local lMsg		:= .T.	

Default cVisao	:= ""
Default aAddFil	:= {}

If MPUserHasAccess("TMKA260",/*nOpc*/,cCodUsr,lMsg)
	
	If Empty( aAddFil )
		cFilPri	:= CRMXFilEnt( "SUS", .T. )	
		If !Empty( cFilPri ) 
			aAdd( aAddFil, { STR0002, cFilPri, .T., .T., "AO4", /*lFilterAsk*/, /*aFilParser*/, "AO4_FILENT" } ) 
		EndIf
	EndIf
		
	TMKA260( /*xRotAuto*/, /*nOpc*/, /*oDlgOwner*/,/*cFilDef*/, aAddFil, cVisao ) // Prospect
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

Local nPos        := 0
Local aEntRelac   := {}
Local aAtiv       := {}
Local aAnotac     := {}
Local aApont      := {}
Local aOpor       := {}
Local aCamp       := {}
Local aRotina     := FWLoadMenuDef("TMKA260")
Local nX          := 0
Local nPosEntR    := 0

aEntRelac := CRMXINCROT( "SUS", aEntRelac )

ADD OPTION aCamp TITLE STR0003   ACTION "CRMA360(,'SUS')"	 OPERATION  8 ACCESS 0  //"Campanhas"
ADD OPTION aCamp TITLE STR0004   ACTION "CRMA250('SUS')"	 OPERATION  8 ACCESS 0  //"Campanhas Rápidas"	

ADD OPTION aEntRelac TITLE STR0003   ACTION aCamp	           OPERATION  8 ACCESS 0  //"Campanhas"
ADD OPTION aEntRelac TITLE STR0005   ACTION "CRMA200('SUS')"   OPERATION  8 ACCESS 0  //"Privilégios"

ADD OPTION aOpor     TITLE STR0006   ACTION "CRMXNewOpo('SUS',SUS->US_COD,SUS->US_LOJA)"	 OPERATION  8 ACCESS 0  //"Nova Oportunidade"
ADD OPTION aOpor     TITLE STR0007   ACTION "CRMA110()"	 OPERATION  8 ACCESS 0  //"Todas as Oportunidades"

ADD OPTION aEntRelac TITLE STR0008   ACTION aOpor	 OPERATION  8 ACCESS 0  //"Oportunidades"
		
ADD OPTION aApont    TITLE  STR0009 ACTION "CRMXNewApo('SUS',SUS->US_COD,SUS->US_LOJA)" OPERATION  8 ACCESS 0  //"Novo Apontamento"
ADD OPTION aApont    TITLE  STR0010	ACTION "CRMA330()"	 OPERATION  8 ACCESS 0  //"Todos os Apontamentos"

ADD OPTION aEntRelac TITLE  STR0011 ACTION aApont	 OPERATION  8 ACCESS 0         //"Apontamentos"
ADD OPTION aEntRelac TITLE  STR0012 ACTION "CRMA620(NIL, 'SUS', SUS->US_COD,SUS->US_LOJA, SUS->US_CODSEG, 4)" OPERATION  4 ACCESS 0 //Subsegmentos
 	 
nPos := aScan(aEntRelac, { |x| IIF(ValType(x[2]) == "C", x[2] == "CRMA190Con()",Nil) })
If nPos > 0 
	ADD OPTION aRotina TITLE aEntRelac[nPos][1] ACTION aEntRelac[nPos][2] OPERATION 8  ACCESS 0//"Conectar"
	Adel(aEntRelac,nPos)
	Asize(aEntRelac,Len(aEntRelac)-1)
EndIf
	
nPos := aScan(aEntRelac, { |x|  IIF(ValType(x[2]) == "C", x[2] == "CRMA180()", Nil) })
If nPos > 0
	ADD OPTION aAtiv   TITLE STR0013 ACTION "CRMA180(,,,3,,)" OPERATION 3  ACCESS 0 //"Nova Atividade" 
	ADD OPTION aAtiv   TITLE STR0014 ACTION "CRMA180()"       OPERATION 8  ACCESS 0 //"Todas as ATividades"
	aEntRelac[nPos][2] := aAtiv
EndIf

nPos := aScan(aEntRelac, { |x| IIF(ValType(x[2]) == "C", x[2] == "CRMA090()", Nil)})
If nPos > 0
	ADD OPTION aAnotac   TITLE STR0015 ACTION "CRMA090(3)" OPERATION 3  ACCESS 0 //"Nova Anotação"
	ADD OPTION aAnotac   TITLE STR0016 ACTION "CRMA090()"  OPERATION 8  ACCESS 0 //"Todas as Anotações" 
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