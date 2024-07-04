#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPOSTO.CH"

REGISTER EXTRACTOR HOI

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPosto
Visualiza as informações pelo código e descrição do posto. 
Posto é o local exato para a prestação de serviço. 
Exemplo: Posto TOTVS Braz Leme 2º andar
	
@author  Valdiney V GOMES
@since   27/03/2014
/*/
//-------------------------------------------------------------------
Function BIXPosto( aParam )
	BIXPosto():BIXPosto( aParam )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPosto
Representação do extrator.

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
Construtor padrão.  

@author  Valdiney V GOMES
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXPosto
	_Super:New( DIMENSION, "HOI", STR0001, "ABS" ) //"Posto"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
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
Extração dos dados para entidade. 
 
@param cFrom, caracter, Data inicial de extração. 
@param cTo, caracter, Data final de extração.
@param dToday, data, Data de inicio do processo de extração.  
@param oOutput, objeto, Objeto para gravação dos dados.
@param oRecord, objeto, Objeto para extração dos dados.
@param oKey, objeto, Objeto para geração da surrogate key.

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
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "ABS_LOCAL", (cFlow)->ABS_LOCAL )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HOI_POSTO" , oKey:GetKey( { (cFlow)->ABS_LOCAL } ) )		
		oRecord:SetValue( "HOI_CODIGO" , (cFlow)->ABS_LOCAL )
		oRecord:SetValue( "HOI_DESC"   , (cFlow)->ABS_DESCRI )
		
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