#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPAISORIGEM.CH"

REGISTER EXTRACTOR HQL

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPaisOrigem
Visualiza as informa��es pelo pa�s de origem da mercadoria no 
processo de importa��o.

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
M�todo construtor.  

@author  Tamara Clemente
@since   05/12/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXPaisOrigem
	_Super:New( DIMENSION, "HQL", STR0001, "SYA" ) //"Pais de Origem"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
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
Extra��o dos dados para entidade. 
 
@param cFrom, caracter, Data inicial de extra��o. 
@param cTo, caracter, Data final de extra��o.
@param dToday, data, Data de inicio do processo de extra��o.  
@param oOutput, objeto, Objeto para grava��o dos dados.
@param oRecord, objeto, Objeto para extra��o dos dados.
@param oKey, objeto, Objeto para gera��o da surrogate key.

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
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "YA_CODGI", (cFlow)->YA_CODGI )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HQL_PAIS" , oKey:GetKey( { (cFlow)->YA_CODGI } ) )		
		oRecord:SetValue( "HQL_CODIGO" , (cFlow)->YA_CODGI )
		oRecord:SetValue( "HQL_DESC"   , (cFlow)->YA_DESCR )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 

		(cFlow)->( DBSkip() ) 
	EndDo  

 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil
