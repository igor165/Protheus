#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFAMILMATERIAL.CH"

REGISTER EXTRACTOR HG2

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXFamilMaterial
Visualiza as informações por código ou descrição da Família de 
Material. Família de Material é um conjunto de itens do estoque, 
agrupados segundo critérios técnicos de afinidade de materiais, como 
natureza, composição e aplicação, voltada para a área industrial.

@author  BI TEAM
@since   05/08/2010
/*/
//-------------------------------------------------------------------
Class BIXFamilMaterial from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Tamara Clemente
@since   28/04/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXFamilMaterial
	_Super:New( DIMENSION, "HG2", STR0001, "SX5" ) //"Família Material"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Tamara Clemente
@since   28/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXFamilMaterial 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HG2_FAMMAT" )
	oModel:SetBK( { "HG2_CODIGO" } )

	oModel:AddField( "HG2_FAMMAT"	, "C", 32, 0 )
	oModel:AddField( "HG2_CODIGO" 	, "C", 10, 0 )
	oModel:AddField( "HG2_DESC"   	, "C", 30, 0 )
	oModel:AddField( "HG2_UNFAMA"  	, "C", 05, 0 )
	
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
@since   25/10/2013
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXFamilMaterial
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "02" )

	For nI := 1 to Len( aContent )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de customização. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "X5_CHAVE", 	aContent[nI][3] ) 
		oRecord:SetValue( "X5_TABELA", 	aContent[nI][2] ) 
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HG2_FAMMAT"	, oKey:GetKey( { aContent[nI][3] } ) )
		oRecord:SetValue( "HG2_CODIGO"	, aContent[nI][3] )
		oRecord:SetValue( "HG2_DESC"	, aContent[nI][4] )
		oRecord:SetValue( "HG2_UNFAMA"	, " " )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------	
		oOutput:Send( oRecord ) 

	NEXT
	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()

	FWFreeArray( aContent )
Return nil