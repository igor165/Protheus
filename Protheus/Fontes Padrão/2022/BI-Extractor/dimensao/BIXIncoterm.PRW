#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXINCOTERM.CH"

REGISTER EXTRACTOR HGM

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXIncoterm
Visualiza as informações por modalidade de negociação do mercado 
Internacional.

@author  BI TEAM
@since   27/07/2010
/*/
//-------------------------------------------------------------------
Class BIXIncoterm from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Helio Leal
@since   18/11/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXIncoterm
	_Super:New( DIMENSION, "HGM", STR0001, "SYJ" ) //Incoterm
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXIncoterm 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HGM_INCOTR" )
	oModel:SetBK( { "HGM_CODIGO" } )

	oModel:AddField( "HGM_INCOTR" , "C", 32, 0 )
	oModel:AddField( "HGM_CODIGO" , "C", 03, 0 )		
	oModel:AddField( "HGM_DESC"   , "C", 30, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXIncoterm
 	Local cFlow := ""
	
	cFlow := ::Flow( cFrom, cTo, { "YJ_COD", "YJ_DESCR"} )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização.
		//-------------------------------------------------------------------	
		oRecord:SetValue( "YJ_COD", 	(cFlow)->YJ_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HGM_INCOTR" , oKey:GetKey( { (cFlow)->YJ_COD } ) )		
		oRecord:SetValue( "HGM_CODIGO", (cFlow)->YJ_COD )
		oRecord:SetValue( "HGM_DESC"  , (cFlow)->YJ_DESCR )
		
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
