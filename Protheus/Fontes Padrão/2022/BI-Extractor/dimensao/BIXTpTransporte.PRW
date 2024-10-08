#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTPTRANSPORTE.CH"

REGISTER EXTRACTOR HHX

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTpTransporte
Visualiza as informa��es por tipo de transporte. O tipo de transporte 
refere-se ao tipo de servi�o prestado pela transportado para entrega 
da mercadoria ao cliente.

@author  Helio Leal
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXTpTransporte from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass
     
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@author  Helio Leal
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXTpTransporte
	_Super:New( DIMENSION, "HHX", STR0001 ) // "Tipo de Transporte" 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   14/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTpTransporte 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HHX_TIPTRA" )
	oModel:SetBK( { "HHX_CODIGO" } )

	oModel:AddField( "HHX_TIPTRA", "C", 32, 0 )
	oModel:AddField( "HHX_CODIGO", "C", 10, 0 )
	oModel:AddField( "HHX_DESC"  , "C", 40, 0 )
	
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
@since   14/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTpTransporte
	Local aTipo := TMSValField( "TIPTRA", .F., .F., .F., .T., .F., .T. )
	Local nTipo	:= 1				    
	
	For nTipo := 1 To Len( aTipo )
 		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HHX_TIPTRA", oKey:GetKey( { aTipo[nTipo][1] }, , .F. ) )
		oRecord:SetValue( "HHX_CODIGO", aTipo[nTipo][1] )
		oRecord:SetValue( "HHX_DESC"  , aTipo[nTipo][2] )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next nTipo 		

 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil