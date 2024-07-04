#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXASSUNTOJURIDICO.CH"

REGISTER EXTRACTOR HYO

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXAssuntoJuridico
Visualiza as informações dos assuntos jurídicos de acordo com o tema 
do processo. Ex: contecioso, cível, societário, etc..

@author  Jorge Luis Branco Martins Junior
@since   23/05/2016
/*/
//-------------------------------------------------------------------
Class BIXAssuntoJuridico from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass
   
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@author  Jorge Luis Branco Martins Junior
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXAssuntoJuridico
	_Super:New( DIMENSION, "HYO", STR0001, "NYB" ) //"Assunto Jurídico"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXAssuntoJuridico 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HYO_ASSUNT" )
	oModel:SetBK( { "HYO_CODIGO" } )

	oModel:AddField( "HYO_ASSUNT" , "C", 32, 0 )
	oModel:AddField( "HYO_CODIGO" , "C", 10, 0 )
	oModel:AddField( "HYO_DESC"   , "C", 40, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXAssuntoJuridico
 	Local cFlow  := ""

	cFlow := ::Flow( cFrom, cTo, { "NYB_COD", "NYB_DESC" } )

 	While ! ( (cFlow)->( Eof() ) )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Alimenta os campos para customização. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "NYB_COD"		, (cFlow)->NYB_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------		
		oRecord:SetValue( "HYO_ASSUNT"	, oKey:GetKey( { (cFlow)->NYB_COD } ) )	
		oRecord:SetValue( "HYO_CODIGO"	, (cFlow)->NYB_COD )
		oRecord:SetValue( "HYO_DESC"	, (cFlow)->NYB_DESC )
		
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
