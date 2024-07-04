#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXROTA.CH"

REGISTER EXTRACTOR HGI

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRota
Visualiza as informações por Rota. Rota são itinerários (caminhos) 
definidos pela transportadora.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXRota from BIXEntity
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
Method New() class BIXRota
	_Super:New( DIMENSION, "HGI", STR0001, "DA8" )//Rota 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXRota 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HGI_ROTA" )
	oModel:SetBK( { "HGI_CODIGO" } )

	oModel:AddField( "HGI_ROTA"   , "C", 32, 0 )
	oModel:AddField( "HGI_CODIGO" , "C", 12, 0 )		
	oModel:AddField( "HGI_DESC"   , "C", 40, 0 )		
	
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
@since   03/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXRota
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "DA8_COD", "DA8_DESC" } )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "DA8_COD", 	(cFlow)->DA8_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HGI_ROTA", oKey:GetKey( { (cFlow)->DA8_COD } ) )		
		oRecord:SetValue( "HGI_CODIGO", (cFlow)->DA8_COD )
		oRecord:SetValue( "HGI_DESC"  , (cFlow)->DA8_DESC )
		
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