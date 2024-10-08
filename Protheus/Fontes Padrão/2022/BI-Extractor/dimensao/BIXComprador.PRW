#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCOMPRADOR.CH"

REGISTER EXTRACTOR HJZ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXComprador
Visualiza as informa��es por Comprador. O Comprador est� relacionado 
�s diversas movimenta��es de compras, devolu��es e recebimentos.

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
M�todo construtor.  

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
Defini��o do modelo de dados da entidade.  
           
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
Extra��o dos dados para entidade. 
 
@param cFrom, caracter, Data inicial de extra��o. 
@param cTo, caracter, Data final de extra��o.
@param dToday, data, Data de inicio do processo de extra��o.  
@param oOutput, objeto, Objeto para grava��o dos dados.
@param oRecord, objeto, Objeto para extra��o dos dados.
@param oKey, objeto, Objeto para gera��o da surrogate key.

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
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "Y1_COD", 	(cFlow)->Y1_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJZ_CMPRDR" , oKey:GetKey( { (cFlow)->Y1_COD } ) )		
		oRecord:SetValue( "HJZ_CODIGO", (cFlow)->Y1_USER )
		oRecord:SetValue( "HJZ_NOME"  , (cFlow)->Y1_NOME )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 

 		(cFlow)->( DBSkip() ) 
 	EndDo  

 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil
