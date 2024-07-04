#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXMODALCOBRANCA.CH

REGISTER EXTRACTOR HJF

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXNatOperacao
Visualiza as informações por modalidade de cobrança. 
Exemplos: Cobrança Simples, Caução, Vendor, Carteira, Representante, 
Desconto, Cheque, Nota Promissória.

@author  BI TEAM
@since   22/02/2017
/*/
//-------------------------------------------------------------------
Class BIXModalCobranca from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@author  Helio Leal
@since   22/02/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXModalCobranca
	_Super:New( DIMENSION, "HJF", STR0001, "SX5" ) //"Modalidade de Cobrança"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   22/02/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXModalCobranca
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJF_MODALI" )
	oModel:SetBK( { "HJF_CODIGO" } )

	oModel:AddField( "HJF_MODALI" , "C", 32, 0 )
	oModel:AddField( "HJF_CODIGO" , "C", 20, 0 )
	oModel:AddField( "HJF_DESC"   , "C", 40, 0 )

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

@author  BI TEAM
@since   22/02/2017
/*/
//-------------------------------------------------------------------
method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXModalCobranca
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "07" )

	For nI := 1 to Len( aContent )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "X5_CHAVE", 	aContent[nI][3] ) 
		oRecord:SetValue( "X5_TABELA", 	aContent[nI][2] ) 
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJF_MODALI", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HJF_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HJF_DESC"  , aContent[nI][4] )
	
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