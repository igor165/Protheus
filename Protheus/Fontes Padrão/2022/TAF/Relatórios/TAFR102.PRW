#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "TAFR102.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFR102
Geracao da Guia Nacional de Recolhimento (GNRE) 

@author Rodrigo Aguilar
@since 17/09/2012
@version 1.0
/*/  
//-------------------------------------------------------------------
Function TAFR102()
	TafXDescont(STR0051)   //"TAFR102 - Geracao da Guia Nacional de Recolhimento (GNRE)"
Return ( )