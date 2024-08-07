#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPOSTO.CH"

REGISTER EXTRACTOR HOI

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPosto
Visualiza as informa��es pelo c�digo e descri��o do posto. 
Posto � o local exato para a presta��o de servi�o. 
Exemplo: Posto TOTVS Braz Leme 2� andar
	
@author  Valdiney V GOMES
@since   27/03/2014
/*/
//-------------------------------------------------------------------
Function BIXPosto( aParam )
	BIXPosto():BIXPosto( aParam )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPosto
Representa��o do extrator.

@author  Valdiney V GOMES
@since   27/03/2014
/*/
//-------------------------------------------------------------------
Class BIXPosto from BIXEntity
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
Method New() class BIXPosto
	_Super:New( DIMENSION, "HOI", STR0001, "ABS" ) //"Posto"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   02/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXPosto 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HOI_POSTO" )
	oModel:SetBK( { "HOI_CODIGO" } )

	oModel:AddField( "HOI_POSTO"   , "C", 32, 0 )
	oModel:AddField( "HOI_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HOI_DESC"   , "C", 50, 0 )		
	
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
@since   02/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXPosto
 	Local cFlow := ""
	
	cFlow := ::Flow( cFrom, cTo, { "ABS_LOCAL", "ABS_DESCRI" } )
	
 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "ABS_LOCAL", (cFlow)->ABS_LOCAL )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HOI_POSTO" , oKey:GetKey( { (cFlow)->ABS_LOCAL } ) )		
		oRecord:SetValue( "HOI_CODIGO" , (cFlow)->ABS_LOCAL )
		oRecord:SetValue( "HOI_DESC"   , (cFlow)->ABS_DESCRI )
		
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