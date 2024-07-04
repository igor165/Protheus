#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSITCOMPRA.CH"

REGISTER EXTRACTOR HQG

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSitCompra
As informações são visualizadas pela situação do processo de compra.

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
Método construtor.  

@author  Valdiney V GOMES
@since   21/11/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXSitCompra
	_Super:New( DIMENSION, "HQG", STR0006) //"Situação de Compra"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
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
Extração dos dados para entidade. 
 
@param cFrom, caracter, Data inicial de extração. 
@param cTo, caracter, Data final de extração.
@param dToday, data, Data de inicio do processo de extração.  
@param oOutput, objeto, Objeto para gravação dos dados.
@param oRecord, objeto, Objeto para extração dos dados.
@param oKey, objeto, Objeto para geração da surrogate key.

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
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HQG_SITCMP", oKey:GetKey( { aStatus[nStatus][1] },,.F.) )			                                                      
		oRecord:SetValue( "HQG_CODIGO", aStatus[nStatus][1] )
		oRecord:SetValue( "HQG_DESC"  , aStatus[nStatus][2] )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next
 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return NIL