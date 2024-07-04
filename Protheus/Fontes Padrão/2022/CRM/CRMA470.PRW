#INCLUDE "PROTHEUS.CH" 
#INCLUDE "CRMA470.CH"
#INCLUDE "CRMDEF.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA470

Rotina que faz a chamada para o cadastro de contatos  

@sample		CRMA470( cVisao )

@param		cVisao - Nome da visão a ser aberta inicialmente no browse 

@return		Nenhum

@author		Thiago Tavares
@since		19/05/2014
@version	P12
/*/
//------------------------------------------admin------------------------------------
Function CRMA470( cVisao , aFilter)

Local aAddFil  := {}
Local cFilPri  := CRMXFilEnt( "SU5", .T. )
Local nX := 0

Default cVisao  := ""
Default aFilter := {}

ProcRegua( 0 ) 
IncProc( STR0001 )   // "Só um momento, localizando os contatos..." 


If !Empty( cFilPri )
	aAdd( aAddFil, { STR0002, cFilPri, .T., .T., "AO4", /*lFilterAsk*/, /*aFilParser*/, "AO4_FILENT" } ) 	// "Filtro CRM"
EndIf	

If !Empty(aFilter)
	For nX := 1 To Len(aFilter)
		aAdd( aAddFil, {aFilter[nX][ADDFIL_TITULO], aFilter[nX][ADDFIL_EXPR], aFilter[nX][ADDFIL_NOCHECK],;
						  aFilter[nX][ADDFIL_SELECTED], aFilter[nX][ADDFIL_ALIAS], aFilter[nX][ADDFIL_FILASK], aFilter[nX][ADDFIL_FILPARSER], aFilter[nX][ADDFIL_ID] } )
	Next nX
EndIf

TMKA070(/*aRotAuto*/, /*nOpc*/, /*xAutoAGA*/, /*xAutoAGB*/, /*xPrefSU5*/, /*cFilDef*/, aAddFil, cVisao) 
		 
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
Local aRotina    := FWLoadMenuDef("TMKA070")
Local nX         := 0
Local nPosEntR   := 0

Aadd(aEntRelac,{STR0003,"CRMA200('SU5')", 0 , 8,0,NIL })//"Privilégios" 
Aadd(aEntRelac,{STR0004,"CRMA440", 0 , 2,3,.T. })//"Perfil"
	
aEntRelac := CRMXINCROT("SU5",aEntRelac)
	
Aadd(aCamp,{STR0005," CRMA360(,'SU5')",0,8,0,NIL})// "Campanhas"
Aadd(aCamp,{STR0006,"CRMA250('SU5')",0,8,0,NIL})// "Campanhas Rápidas"
	
Aadd(aEntRelac,{STR0005	,aCamp,0,8,0,NIL})// "Campanhas"		
	
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