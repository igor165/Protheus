#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXUSUARIO.CH"

REGISTER EXTRACTOR HSQ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXUsuario
Visualiza as informações por código ou nome do usuário do CRM.

@author  Valdiney V GOMES
@since   23/04/2014
/*/
//-------------------------------------------------------------------
Class BIXUsuario from BIXEntity
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
Method New() class BIXUsuario
	_Super:New( DIMENSION, "HSQ", STR0001, "AO3" ) //"Usuário"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   15/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXUsuario
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HSQ_USUARI" )
	oModel:SetBK( { "HSQ_CODIGO" } )

	oModel:AddField( "HSQ_USUARI"	, "C", 32, 0 )
	oModel:AddField( "HSQ_CODIGO" 	, "C", 10, 0 )
	oModel:AddField( "HSQ_NOME"  	, "C", 50, 0 )
	
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
@since   15/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXUsuario
 	Local cFlow := ""
    	
	cFlow := ::Flow( cFrom, cTo, { "AO3_CODUSR" } )

 	While ! (cFlow)->( Eof() )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos para customização. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "AO3_CODUSR"		, (cFlow)->AO3_CODUSR )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HSQ_USUARI"	, oKey:GetKey( { (cFlow)->AO3_CODUSR } ) )
		oRecord:SetValue( "HSQ_CODIGO"	, (cFlow)->AO3_CODUSR )
		oRecord:SetValue( "HSQ_NOME"	, UsrFullName( (cFlow)->AO3_CODUSR ) )

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