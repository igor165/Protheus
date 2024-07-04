#INCLUDE "PROTHEUS.CH" 
#INCLUDE "CRMA070.CH" 
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA070

Chamada para rotina do cadastro de clientes.

@sample		CRMA070()

@param	    cVisaoSA1 - Nome da visão a ser aberta inicialmente no browse de Clientes

@return		Nenhum

@author		Enaldo Cardoso
@since		08/11/2013
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRMA070(cVisaoSA1)

Local aAddFil 	:= {}
Local cFilPri	:= ""
Local cCodUsr	:= IIF(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
Local lMsg		:= .T.

Private aRotina    := {}
Private cCadastro  := ""  
Private lNewClient := .T.

Default cVisaoSA1  := ""

If MPUserHasAccess("MATA030",/*nOpc*/,cCodUsr,lMsg)

	cFilPri	:= CRMXFilEnt( "SA1", .T. )
	cCadastro := STR0001	// "Clientes"
	aRotina   := FwLoadMenuDef( "MATA030" )
	
	If lNewClient
		If !Empty( cFilPri ) 
			aAdd( aAddFil, { STR0006, cFilPri, .T., .T., "AO4", /*lFilterAsk*/, /*aFilParser*/, "AO4_FILENT" } )		// "Filtro CRM"
		EndIf
		
		MATA030( , , , , aAddFil,cVisaoSA1)	
		lNewClient := .F.	
	EndIf
	
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
Local aRotina    := {}
Local nPosEntR   := 0
Local lMVC       := SuperGetMv("MV_MVCSA1",,.F.)
Local aPerfil360 := {}

If !lMVC
	aRotina := FwLoadMenuDef("MATA030")
Else
	aRotina := FwLoadMenuDef("CRMA980")
EndIf

If ( !IsBlind() .And. cPaisLoc <> "RUS" )
	aPerfil360 := CRM710P360()
EndIf

If Empty(aPerfil360)
	aEntRelac := CRMXINCROT("SA1",aEntRelac)
					
	Aadd(aCamp,{STR0009," CRMA360(,'SA1')",0,8,0,NIL})// "Campanhas"
	Aadd(aCamp,{STR0011,"CRMA250('SA1')",0,8,0,NIL})// "Campanhas Rápidas"
	Aadd(aEntRelac,{STR0009,aCamp,0,8,0,NIL})// "Campanhas"			
		
	nPos := aScan(aEntRelac, { |x| IIF(ValType(x[2]) == "C", x[2] == "CRMA190Con()",Nil) })
	If nPos > 0 
		ADD OPTION aRotina TITLE aEntRelac[nPos][1] ACTION aEntRelac[nPos][2] OPERATION 8  ACCESS 0//"Conectar"
		Adel(aEntRelac,nPos)
		Asize(aEntRelac,Len(aEntRelac)-1)
	EndIf
				
	nPos := aScan(aEntRelac, { |x|  IIF(ValType(x[2]) == "C", x[2] == "CRMA180()", Nil) })
	If nPos > 0
		ADD OPTION aAtiv   TITLE STR0011  ACTION "CRMA180(,,,3,,)" OPERATION 3  ACCESS 0 //"Nova Atividade" 
		ADD OPTION aAtiv   TITLE STR0012  ACTION "CRMA180()" OPERATION 8  ACCESS 0 //"Todas as ATividades"
		aEntRelac[nPos][2] := aAtiv
	EndIf
				
	nPos := aScan(aEntRelac, { |x| IIF(ValType(x[2]) == "C", x[2] == "CRMA090()", Nil)})
	If nPos > 0
		ADD OPTION aAnotac   TITLE STR0013 ACTION "CRMA090(3)" OPERATION 3  ACCESS 0 //"Nova Anotação"
		ADD OPTION aAnotac   TITLE STR0014 ACTION "CRMA090()" OPERATION 8  ACCESS 0 //"Todas as Anotações" 
		aEntRelac[nPos][2] := aAnotac
	EndIf

	nPosEntR := aScan(aRotina,{|x| ValType(x[2]) == "A"})
	If nPosEntR > 0 
		For nX := 1 To Len(aEntRelac)
			aAdd(aRotina[nPosEntR][2],aEntRelac[nX])
		Next nX
		Asort(aRotina[nPosEntR][2],,,{|x,y| y[1] > x[1]})
	EndIf
EndIf

Return( aRotina )