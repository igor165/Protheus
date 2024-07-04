#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTPPENDENCIA.CH"

REGISTER EXTRACTOR HHY

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTpPendencia
Visualiza as informações por tipo de pendência gerada durante o processo 
de entrega da mercadoria. O tipo da pendência é o detalhe da ocorrência 
de viagem, quando esta gera alguma pendência no processo.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXTpPendencia from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass
   
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@author  Valdiney V GOMES
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXTpPendencia
	_Super:New( DIMENSION, "HHY", STR0001) //"Tipo de Pendência"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   14/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTpPendencia
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HHY_TIPPEN" )
	oModel:SetBK( { "HHY_CODIGO" } )

	oModel:AddField( "HHY_TIPPEN", "C", 32, 0 )
	oModel:AddField( "HHY_CODIGO", "C", 10, 0 )
	oModel:AddField( "HHY_DESC"  , "C", 20, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTpPendencia
	Local aTipo := TMSValField( "TIPPND", .F., .F., .F., .T., .F., .T. )
	Local nTipo	:= 1				    
	
	For nTipo := 1 To Len( aTipo )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HHY_TIPPEN"	, oKey:GetKey( { aTipo[nTipo][1] },,.F.) )
		oRecord:SetValue( "HHY_CODIGO"	, aTipo[nTipo][1] )
		oRecord:SetValue( "HHY_DESC"	, aTipo[nTipo][2] )
		
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

