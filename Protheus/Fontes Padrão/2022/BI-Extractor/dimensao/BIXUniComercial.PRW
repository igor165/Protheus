#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXUNICOMERCIAL.CH"

REGISTER EXTRACTOR HSP

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXUniComercial
Visualiza as informações por código ou descrição da unidade comercial. 
A unidade comercial permite o controle das unidades de negócio de uma 
organização ou empresa, como: filiais, franquias e revendas.

@author  Valdiney V GOMES
@since   23/04/2014
/*/
//-------------------------------------------------------------------
Class BIXUniComercial from BIXEntity
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
Method New() class BIXUniComercial
	_Super:New( DIMENSION, "HSP", STR0001, "ADK" ) //"Unidade Comercial"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   14/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXUniComercial
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HSP_UNICOM" )
	oModel:SetBK( { "HSP_CODIGO" } )

	oModel:AddField( "HSP_UNICOM"	, "C", 32, 0 )
	oModel:AddField( "HSP_CODIGO" 	, "C", 10, 0 )
	oModel:AddField( "HSP_NOME"   	, "C", 40, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXUniComercial
 	Local cFlow := ""
    	
	cFlow := ::Flow( cFrom, cTo, { "ADK_COD", "ADK_NOME"} )

 	While ! (cFlow)->( Eof() )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos para customização. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "ADK_COD"		, (cFlow)->ADK_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HSP_UNICOM"	, oKey:GetKey( { (cFlow)->ADK_COD } ) )
		oRecord:SetValue( "HSP_CODIGO"	, (cFlow)->ADK_COD )
		oRecord:SetValue( "HSP_NOME"	, (cFlow)->ADK_NOME )

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
