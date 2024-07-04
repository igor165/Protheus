#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXDOCESPEC.CH"

REGISTER EXTRACTOR HJG

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXDocEspec
Visualiza as informações por espécie de documento utilizado pela 
empresa. Espécies de documentos identificam os tipos de documentos 
utilizados dentro da organização, facilitando o controle.

@author  BI TEAM
@since   22/02/2017
/*/
//-------------------------------------------------------------------
Class BIXDocEspec from BIXEntity
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
Method New() class BIXDocEspec
	_Super:New( DIMENSION, "HJG", STR0001 , "SX5" ) //"Espécie do Documento"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@version P12 
@since   22/02/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXDocEspec
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJG_ESPDOC" )
	oModel:SetBK( { "HJG_CODIGO" } )

	oModel:AddField( "HJG_ESPDOC" 	, "C", 32, 0 )
	oModel:AddField( "HJG_TIPO" 	, "C", 1, 0  )
	oModel:AddField( "HJG_CODIGO" 	, "C", 10, 0 )
	oModel:AddField( "HJG_DESC"   	, "C", 55, 0 )

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
method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXDocEspec
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "05" )

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
		oRecord:SetValue( "HJG_ESPDOC", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HJG_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HJG_DESC"  , aContent[nI][4] )
		oRecord:SetValue( "HJG_TIPO"  , "" )
	
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