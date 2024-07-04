#Include "Protheus.Ch"
#Include "RwMake.Ch"
#Include "TbiConn.Ch"
#Include "Colors.Ch"
#Include "RptDef.Ch"  
#Include "FwPrintSetup.Ch" 
#Include "Tafr108.ch"     

#Define Imp_Spool 	2
#Define cPicture 	"@E 999,999,999,999,999.99"
#Define oArial06	TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
#Define oArial09N	TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFR108
Livro Registro de Saidas - RS - Modelo P2/A         

Esta rotina tem como objetivo realizar a impressao do Modelo P2A, algumas Funcoes genericas 
utilizadas estao no fonte TAFRFUN

@Retorno ( Nil )

@author Rodrigo Aguilar
@since 13/11/2012
@version 1.0
/*/  
//--------------------------------------------------------------------------------------------------
Function TAFR108()

	TafXDescont(STR0011)  //"TAFR108 - Livro Registro de Saidas - RS - Modelo P2/A" 

Return (  )