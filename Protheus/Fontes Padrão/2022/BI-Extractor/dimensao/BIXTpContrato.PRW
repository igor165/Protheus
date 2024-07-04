#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTPCONTRATO.CH"

REGISTER EXTRACTOR HON

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTpContrato
Visualiza as informações pelo código e descrição do tipo de contrato. 
Tipo de contrato atribui diversas características padronizadas para os 
contratos de trabalho, de acordo com o ramo das empresas. 
Exemplo: Terceirização, locação de equipamentos, etc.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXTpContrato from BIXEntity
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
Method New() class BIXTpContrato
	_Super:New( DIMENSION, "HON", STR0001, "CN1" ) //"Tipo de Contrato"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Tamara Clemente
@since   28/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTpContrato 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HON_TPCONT" )
	oModel:SetBK( { "HON_CODIGO" } )

	oModel:AddField( "HON_TPCONT"	, "C", 32, 0 )
	oModel:AddField( "HON_CODIGO" 	, "C", 10, 0 )
	oModel:AddField( "HON_DESC"   	, "C", 30, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTpContrato
 	Local cFlow := ""
    	
	cFlow := ::Flow( cFrom, cTo, { "CN1_CODIGO", "CN1_DESCRI", "CN1_ESPCTR"} )

 	While ! (cFlow)->( Eof() )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos para customização. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "CN1_CODIGO"		, (cFlow)->CN1_CODIGO )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HON_TPCONT"	, oKey:GetKey( { (cFlow)->CN1_CODIGO } ) )
		oRecord:SetValue( "HON_CODIGO"	, (cFlow)->CN1_CODIGO )
		oRecord:SetValue( "HON_DESC"	, (cFlow)->CN1_DESCRI )

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
