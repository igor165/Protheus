#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXMOTIVOREJEICAO.CH"

REGISTER EXTRACTOR HK0

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXMotivoRejeicao
Visualiza as informações por código ou descrição do motivo de rejeição. 
Possibilita analisar o motivo da rejeição e aprovação condicional dos 
roteiros de inspeção pela empresa.

@author  BI TEAM
@since   11/08/2010
/*/
//-------------------------------------------------------------------
Class BIXMotivoRejeicao from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Helio Leal
@since   02/12/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXMotivoRejeicao
	_Super:New( DIMENSION, "HK0", STR0001, "EY1" ) //"Motivo de Rejeição"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXMotivoRejeicao 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HK0_MOTREJ" )
	oModel:SetBK( { "HK0_CODIGO" } )

	oModel:AddField( "HK0_MOTREJ" , "C", 32, 0 )
	oModel:AddField( "HK0_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HK0_DESC"   , "C", 40, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXMotivoRejeicao
 	Local cFlow := ""
	
	cFlow := ::Flow( cFrom, cTo, { "EY1_CLAREJ", "EY1_DSCREJ"} )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "EY1_CLAREJ", 	(cFlow)->EY1_CLAREJ )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HK0_MOTREJ" , oKey:GetKey( { (cFlow)->EY1_CLAREJ } ) )		
		oRecord:SetValue( "HK0_CODIGO", (cFlow)->EY1_CLAREJ )
		oRecord:SetValue( "HK0_DESC"  , (cFlow)->EY1_DSCREJ )
		
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