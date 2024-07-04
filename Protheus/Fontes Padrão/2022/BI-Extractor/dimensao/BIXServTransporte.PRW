#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSERVTRANSPORTE.CH"

REGISTER EXTRACTOR HO1

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXServTransporte
Visualiza as informações pelo tipo do serviço prestado no transporte.
O serviço de transporte caracterizada cada uma das etapas de trabalho 
da transportadora.

@author  Helio Leal
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXServTransporte from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass
  
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@author  Helio Leal
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXServTransporte
	_Super:New( DIMENSION, "HO1", STR0001 ) // "Serviço de Transporte" 
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXServTransporte
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HO1_SERTRA" )
	oModel:SetBK( { "HO1_CODIGO" } )

	oModel:AddField( "HO1_SERTRA" , "C", 32, 0 )
	oModel:AddField( "HO1_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HO1_DESC"   , "C", 20, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXServTransporte
	Local aTipo := TMSValField( "SERTMS", .F., .F., .F., .T., .F., .T. )
	Local nTipo	:= 1				    
	
	For nTipo := 1 To Len( aTipo )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HO1_SERTRA", oKey:GetKey( { aTipo[nTipo][1] }, , .F. ) )		
		oRecord:SetValue( "HO1_CODIGO", aTipo[nTipo][1] )
		oRecord:SetValue( "HO1_DESC"  , aTipo[nTipo][2] )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 

	Next nTipo 		
 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
return nil