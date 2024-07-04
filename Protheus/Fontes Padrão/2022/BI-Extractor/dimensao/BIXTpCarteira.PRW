#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTPCARTEIRA.CH"                                                                                                                                                                                                                                               

REGISTER EXTRACTOR HYX

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTpCarteira
As informações são visualizadas por tipo de carteira. O tipo da operação 
indica-se a carteira é do tipo Previsto ou Realizado. 

@author  Valdiney V GOMES
@since   07/03/2014
/*/
//-------------------------------------------------------------------
Class BIXTpCarteira from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Valdiney V GOMES
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXTpCarteira
	_Super:New( DIMENSION, "HYX", STR0003 ) //"Tipo de Carteira"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  BI TEAM
@since   26/07/2010	
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTpCarteira 
	Local oModel := BIXModel():Build( Self )
	
	oModel:SetSK( "HYX_TPCART" )
	oModel:SetBK( { "HYX_CODIGO" } )	
	
	oModel:AddField( "HYX_TPCART" , "C", 32, 0 )
	oModel:AddField( "HYX_CODIGO" , "C", 10, 0 )
	oModel:AddField( "HYX_DESC"   , "C", 20, 0 )

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
@since   26/07/2010
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTpCarteira
	Local aCarteira 	:= {} 
	Local nCarteira		:= 1				    
	
	aAdd( aCarteira, {"P", STR0001 } ) //"PREVISTO"
	aAdd( aCarteira, {"R", STR0002 } ) //"REALIZADO"	 
	
	For nCarteira := 1 To Len( aCarteira )
 		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HYX_TPCART"	, oKey:GetKey( { aCarteira[nCarteira][1] }, .T., .F. ) )
		oRecord:SetValue( "HYX_CODIGO"	, aCarteira[nCarteira][1] )
		oRecord:SetValue( "HYX_DESC"	, aCarteira[nCarteira][2] )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------	
		oOutput:Send( oRecord ) 
	Next nCarteira 	
	
	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()	
Return nil