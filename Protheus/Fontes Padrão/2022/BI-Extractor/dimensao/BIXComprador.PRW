#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCOMPRADOR.CH"

REGISTER EXTRACTOR HJZ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXComprador
Visualiza as informações por Comprador. O Comprador está relacionado 
às diversas movimentações de compras, devoluções e recebimentos.

@author  BI TEAM
@since   26/06/2010
/*/
//-------------------------------------------------------------------
Class BIXComprador from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Valdiney V GOMES
@version P12 
@since   21/11/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXComprador
	_Super:New( DIMENSION, "HJZ", STR0001, "SY1" ) //"Comprador"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXComprador 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJZ_CMPRDR" )
	oModel:SetBK( { "HJZ_CODIGO" } )

	oModel:AddField( "HJZ_CMPRDR", "C", 32, 0 )
	oModel:AddField( "HJZ_CODIGO", "C", 16, 0 )
	oModel:AddField( "HJZ_NOME"  , "C", 80, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXComprador
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "Y1_COD", "Y1_USER", "Y1_NOME"} )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "Y1_COD", 	(cFlow)->Y1_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJZ_CMPRDR" , oKey:GetKey( { (cFlow)->Y1_COD } ) )		
		oRecord:SetValue( "HJZ_CODIGO", (cFlow)->Y1_USER )
		oRecord:SetValue( "HJZ_NOME"  , (cFlow)->Y1_NOME )
		
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
