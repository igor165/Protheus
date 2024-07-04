#Include "Protheus.Ch"
#Include "RwMake.Ch"
#Include "TbiConn.Ch"
#Include "Colors.Ch"
#Include "RptDef.Ch"  
#Include "FwPrintSetup.Ch"      
#Include "Tafr105.ch"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFR105
Livro Registro de Entrada - RE - Modelo P1         

Esta rotina tem como objetivo realizar a impressao do Modelo P1, algumas Funcoes genericas 
utilizadas estao no fonte TAFRFUN

@Retorno ( Nil )

@author Rodrigo Aguilar
@since 26/10/2012
@version 1.0
/*/  
//--------------------------------------------------------------------------------------------------
Function TAFR105()

	TafXDescont(STR0007)  //"TAFR105 - Livro Registro de Entrada - RE - Modelo P1" 

Return ( )				
