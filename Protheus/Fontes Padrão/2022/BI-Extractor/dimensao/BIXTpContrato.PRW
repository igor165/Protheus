#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTPCONTRATO.CH"

REGISTER EXTRACTOR HON

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTpContrato
Visualiza as informa��es pelo c�digo e descri��o do tipo de contrato. 
Tipo de contrato atribui diversas caracter�sticas padronizadas para os 
contratos de trabalho, de acordo com o ramo das empresas. 
Exemplo: Terceiriza��o, loca��o de equipamentos, etc.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXTpContrato from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )  
EndClass
    
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@author  Valdiney V GOMES
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXTpContrato
	_Super:New( DIMENSION, "HON", STR0001, "CN1" ) //"Tipo de Contrato"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Tamara Clemente
@since   28/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTpContrato 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HON_TPCONT" )
	oModel:SetBK( { "HON_CODIGO" } )

	oModel:AddField( "HON_TPCONT"	, "C", 32, 0 )
	oModel:AddField( "HON_CODIGO" 	, "C", 10, 0 )
	oModel:AddField( "HON_DESC"   	, "C", 30, 0 )
	
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
@since   14/05/2017

/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTpContrato
 	Local cFlow := ""
    	
	cFlow := ::Flow( cFrom, cTo, { "CN1_CODIGO", "CN1_DESCRI", "CN1_ESPCTR"} )

 	While ! (cFlow)->( Eof() )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "CN1_CODIGO"		, (cFlow)->CN1_CODIGO )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HON_TPCONT"	, oKey:GetKey( { (cFlow)->CN1_CODIGO } ) )
		oRecord:SetValue( "HON_CODIGO"	, (cFlow)->CN1_CODIGO )
		oRecord:SetValue( "HON_DESC"	, (cFlow)->CN1_DESCRI )

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
