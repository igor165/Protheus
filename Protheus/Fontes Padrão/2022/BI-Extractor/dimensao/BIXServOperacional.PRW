#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSERVOPERACIONAL.CH"

REGISTER EXTRACTOR HO3

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXServOperacional
Visualiza as informações pelo serviço operacional. O serviço operacional 
caracteriza a execução de uma ou mais tarefas, como Viagem SP x RJ, 
Viagem SC X AM, etc.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXServOperacional from BIXEntity
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
Method New() class BIXServOperacional
	_Super:New( DIMENSION, "HO3", STR0001, "SX5" ) //"Serviço Operacional"
Return Self  
//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXServOperacional 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HO3_SEROPE" )
	oModel:SetBK( { "HO3_CODIGO" } )

	oModel:AddField( "HO3_SEROPE" , "C", 32, 0 )
	oModel:AddField( "HO3_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HO3_DESC"   , "C", 55, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXServOperacional
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "L4" )

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
		oRecord:SetValue( "HO3_SEROPE", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HO3_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HO3_DESC"  , aContent[nI][4] )
		
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