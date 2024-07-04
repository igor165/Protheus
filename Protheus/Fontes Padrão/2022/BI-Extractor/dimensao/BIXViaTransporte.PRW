#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXVIATRANSPORTE.CH"
 
REGISTER EXTRACTOR HGR

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXViaTransporte
Visualiza as informações por Via de Transporte. Trata-se da via de 
transporte usada na negociação das importações e exportações. 
Exemplo: via marítimo, via aéreo.

@author  BI TEAM
@since   12/08/2010
/*/
//-------------------------------------------------------------------
Class BIXViaTransporte from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@author  Tamara Clemente
@since   04/05/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXViaTransporte
	_Super:New( DIMENSION, "HGR", STR0001, "SX5" ) //Via Transporte
Return Self  


//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Tamara Clemente
@since   04/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXViaTransporte 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HGR_VIATRA" )
	oModel:SetBK( { "HGR_CODIGO" } )

	oModel:AddField( "HGR_VIATRA" 	, "C", 32, 0 )
	oModel:AddField( "HGR_CODIGO" 	, "C", 12, 0 )
	oModel:AddField( "HGR_DESC"   	, "C", 40, 0 )
	
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

@author  Tamara Clemente
@since   04/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXViaTransporte
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "Y3" )

	For nI := 1 to Len( aContent ) 
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "X5_CHAVE", 	aContent[nI][3] ) 
		oRecord:SetValue( "X5_TABELA", 	aContent[nI][2] ) 
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HGR_VIATRA", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HGR_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HGR_DESC"  , aContent[nI][4] )
		
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