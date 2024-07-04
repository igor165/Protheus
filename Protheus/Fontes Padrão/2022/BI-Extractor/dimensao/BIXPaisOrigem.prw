#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPAISORIGEM.CH"

REGISTER EXTRACTOR HQL

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPaisOrigem
Visualiza as informações pelo país de origem da mercadoria no 
processo de importação.

@author  BI TEAM
@since   27/07/2010
/*/
//-------------------------------------------------------------------
Class BIXPaisOrigem from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Tamara Clemente
@since   05/12/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXPaisOrigem
	_Super:New( DIMENSION, "HQL", STR0001, "SYA" ) //"Pais de Origem"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   02/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXPaisOrigem 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HQL_PAIS" )
	oModel:SetBK( { "HQL_CODIGO" } )

	oModel:AddField( "HQL_PAIS"   , "C", 32, 0 )
	oModel:AddField( "HQL_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HQL_DESC"   , "C", 40, 0 )		
	
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
@since   02/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXPaisOrigem
 	Local cFlow := ""
	
	cFlow := ::Flow( cFrom, cTo, { "YA_CODGI", "YA_DESCR" } )
	
 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "YA_CODGI", (cFlow)->YA_CODGI )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HQL_PAIS" , oKey:GetKey( { (cFlow)->YA_CODGI } ) )		
		oRecord:SetValue( "HQL_CODIGO" , (cFlow)->YA_CODGI )
		oRecord:SetValue( "HQL_DESC"   , (cFlow)->YA_DESCR )
		
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
