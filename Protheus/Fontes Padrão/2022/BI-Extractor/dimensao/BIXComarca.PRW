#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCOMARCA.CH"

REGISTER EXTRACTOR HYH

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXComarca
Representação do extrator.

@author  Jorge Luis Branco Martins Junior
@since   19/05/2016
/*/
//-------------------------------------------------------------------
Class BIXComarca from BIXEntity
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
Method New() class BIXComarca
	_Super:New( DIMENSION, "HYH", STR0001, "NQ6" ) //"Comarca"
Return Self  
 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXComarca 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HYH_COMARC" )
	oModel:SetBK( { "HYH_CODIGO" } )

	oModel:AddField( "HYH_COMARC"	, "C", 32, 0 )
	oModel:AddField( "HYH_CODIGO"	, "C", 10, 0 )
	oModel:AddField( "HYH_UF"		, "C", 02, 0 )
	oModel:AddField( "HYH_DESC" 	, "C", 50, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXComarca
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "NQ6_COD", "NQ6_UF", "NQ6_DESC"} )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "NQ6_COD", 	(cFlow)->NQ6_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HYH_COMARC" , oKey:GetKey( { (cFlow)->NQ6_COD } ) )		
		oRecord:SetValue( "HYH_CODIGO", (cFlow)->NQ6_COD )
		oRecord:SetValue( "HYH_UF"  , (cFlow)->NQ6_UF )
		oRecord:SetValue( "HYH_DESC"  , (cFlow)->NQ6_DESC )
		
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
