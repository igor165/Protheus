#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSITCOMPRA.CH"

REGISTER EXTRACTOR HQG

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSitCompra
As informa��es s�o visualizadas pela situa��o do processo de compra.

@author  BI TEAM
@since   22/07/2010
/*/
//-------------------------------------------------------------------
Class BIXSitCompra from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author  Valdiney V GOMES
@since   21/11/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXSitCompra
	_Super:New( DIMENSION, "HQG", STR0006) //"Situa��o de Compra"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXSitCompra 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HQG_SITCMP" )
	oModel:SetBK( { "HQG_CODIGO" } )

	oModel:AddField( "HQG_SITCMP" , "C", 32, 0 )
	oModel:AddField( "HQG_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HQG_DESC"   , "C", 40, 0 )		
	
	oModel:FreeField() 
Return oModel
	
//-------------------------------------------------------------------
/*/{Protheus.doc} Run
Extra��o dos dados para entidade. 
 
@param cFrom, caracter, Data inicial de extra��o. 
@param cTo, caracter, Data final de extra��o.
@param dToday, data, Data de inicio do processo de extra��o.  
@param oOutput, objeto, Objeto para grava��o dos dados.
@param oRecord, objeto, Objeto para extra��o dos dados.
@param oKey, objeto, Objeto para gera��o da surrogate key.

@author  Marcia Junko
@since   01/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXSitCompra
	Local nStatus := 0
	Local aStatus := {}          

	aAdd( aStatus, { "F", STR0001 } ) //"CONFIRMADA"
	aAdd( aStatus, { "P", STR0002 } ) //"PROGRAMADA" 
	aAdd( aStatus, { "R", STR0003 } ) //"RECEBIDA PARCIALMENTE" 
	aAdd( aStatus, { "I", STR0004 } ) //"RECEBIDA INTEGRALMENTE" 
	aAdd( aStatus, { "D", STR0005 } ) //"DEVOLVIDA" 

	For nStatus := 1 To Len( aStatus )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HQG_SITCMP", oKey:GetKey( { aStatus[nStatus][1] },,.F.) )			                                                      
		oRecord:SetValue( "HQG_CODIGO", aStatus[nStatus][1] )
		oRecord:SetValue( "HQG_DESC"  , aStatus[nStatus][2] )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next
 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return NIL