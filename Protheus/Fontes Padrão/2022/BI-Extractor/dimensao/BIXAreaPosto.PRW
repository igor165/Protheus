#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXAREAPOSTO.CH"

REGISTER EXTRACTOR HOK

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXAreaPosto
Representação do extrator.

@author  Valdiney V GOMES
@author  Marcia Junko
@since   01/05/2017
/*/
//-------------------------------------------------------------------
Class BIXAreaPosto from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass
   
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@author  Marcia Junko
@since   01/05/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXAreaPosto
	_Super:New( DIMENSION, "HOK", STR0001, "SX5" ) //"Área do Posto"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXAreaPosto 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HOK_AREA" )
	oModel:SetBK( { "HOK_CODIGO" } )

	oModel:AddField( "HOK_AREA" , "C", 32, 0 )
	oModel:AddField( "HOK_CODIGO" , "C", 10, 0 )
	oModel:AddField( "HOK_DESC"   , "C", 55, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXAreaPosto
 	Local aContent := {}
	Local nI	   := 0

	aContent := FWGetSX5( "A2" )

	For nI := 1 to Len( aContent ) 
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "X5_CHAVE",  aContent[nI][3] ) 
		oRecord:SetValue( "X5_TABELA", aContent[nI][2] ) 
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HOK_AREA", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HOK_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HOK_DESC"  , aContent[nI][4] )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
 	Next

 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()

	FWFreeArray( aContent )
Return nil
