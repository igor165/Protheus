#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSITEXPORTACAO.CH"

REGISTER EXTRACTOR HGJ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSitExportacao
As informações são visualizadas pela situação do processo de exportação. 
Exemplo: Aberto, Faturado, Embarcado, Cancelado. 

@author  BI TEAM
@since   12/08/2010
/*/
//-------------------------------------------------------------------
Class BIXSitExportacao from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Valdiney V GOMES
@since   18/11/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXSitExportacao
	_Super:New( DIMENSION, "HGJ", STR0001, "SX5" )//Situação de Exportação 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXSitExportacao 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HGJ_SITEXP" )
	oModel:SetBK( { "HGJ_CODIGO" } )

	oModel:AddField( "HGJ_SITEXP" , "C", 32, 0 )
	oModel:AddField( "HGJ_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HGJ_DESC"   , "C", 55, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXSitExportacao
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "YC" )

	For nI := 1 to Len( aContent )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização
		//-------------------------------------------------------------------	
		oRecord:SetValue( "X5_CHAVE", 	aContent[nI][3] ) 
		oRecord:SetValue( "X5_TABELA", 	aContent[nI][2] ) 
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HGJ_SITEXP", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HGJ_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HGJ_DESC"  , aContent[nI][4] )
		
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