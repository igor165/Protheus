#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCONTRATO.CH"

REGISTER EXTRACTOR HOJ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXContrato
Visualiza as informações pelo código e revisão do contrato. 
Contrato é o acordo firmado entre as partes que define os recursos 
necessários na contratação da prestação do serviço.

@author  Valdiney V GOMES
@since   27/03/2014
/*/
//-------------------------------------------------------------------
Class BIXContrato from BIXEntity
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
Method New() class BIXContrato
	_Super:New( DIMENSION, "HOJ", STR0001, "CN9" ) //"Contrato"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXContrato 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HOJ_CONTRA" )
	oModel:SetBK( { "HOJ_CODIGO" } )

	oModel:AddField( "HOJ_CONTRA", "C", 60, 0 )
	oModel:AddField( "HOJ_CODIGO", "C", 15, 0 )
	oModel:AddField( "HOJ_REVISA", "C", 3, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXContrato
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "CN9_NUMERO", "CN9_REVISA"} )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "CN9_NUMERO", 	(cFlow)->CN9_NUMERO )
		oRecord:SetValue( "CN9_REVISA", 	(cFlow)->CN9_REVISA )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HOJ_CONTRA" , oKey:GetKey( { (cFlow)->CN9_NUMERO, (cFlow)->CN9_REVISA } ) )		
		oRecord:SetValue( "HOJ_CODIGO", (cFlow)->CN9_NUMERO )
		oRecord:SetValue( "HOJ_REVISA"  , (cFlow)->CN9_REVISA )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 

 		(cFlow)->( DBSkip() ) 
 	EndDo  

 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil