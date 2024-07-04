#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXMIDIA.CH"

REGISTER EXTRACTOR HS6

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXMidia
Visualiza as informações por código e descrição do canal de mídia. 
Os canais de mídia descriminam as formas pelas quais os clientes 
conheceram a loja.

@author  Helio Leal
@since   29/05/2017
/*/
//-------------------------------------------------------------------
Class BIXMidia from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )   
EndClass
     
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@author  Helio Leal
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXMidia
	_Super:New( DIMENSION, "HS6", STR0001, "SUH" ) // "Canal de Mídia" 
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXMidia 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HS6_CANMID" )
	oModel:SetBK( { "HS6_CODIGO" } )

	oModel:AddField( "HS6_CANMID" , "C", 32, 0 )
	oModel:AddField( "HS6_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HS6_DESC"   , "C", 55, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXMidia
 	Local cFlow := ""
	
	cFlow := ::Flow( cFrom, cTo, { "UH_MIDIA", "UH_DESC"} )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "UH_MIDIA", 	(cFlow)->UH_MIDIA )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HS6_CANMID" , oKey:GetKey( { (cFlow)->UH_MIDIA } ) )		
		oRecord:SetValue( "HS6_CODIGO", (cFlow)->UH_MIDIA )
		oRecord:SetValue( "HS6_DESC"  , (cFlow)->UH_DESC )
		
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