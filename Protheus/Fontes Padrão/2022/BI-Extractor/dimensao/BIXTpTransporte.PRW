#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTPTRANSPORTE.CH"

REGISTER EXTRACTOR HHX

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTpTransporte
Visualiza as informações por tipo de transporte. O tipo de transporte 
refere-se ao tipo de serviço prestado pela transportado para entrega 
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
Construtor padrão.  

@author  Helio Leal
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXTpTransporte
	_Super:New( DIMENSION, "HHX", STR0001 ) // "Tipo de Transporte" 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
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
Extração dos dados para entidade. 
 
@param cFrom, caracter, Data inicial de extração. 
@param cTo, caracter, Data final de extração.
@param dToday, data, Data de inicio do processo de extração.  
@param oOutput, objeto, Objeto para gravação dos dados.
@param oRecord, objeto, Objeto para extração dos dados.
@param oKey, objeto, Objeto para geração da surrogate key.

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
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HHX_TIPTRA", oKey:GetKey( { aTipo[nTipo][1] }, , .F. ) )
		oRecord:SetValue( "HHX_CODIGO", aTipo[nTipo][1] )
		oRecord:SetValue( "HHX_DESC"  , aTipo[nTipo][2] )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next nTipo 		

 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil