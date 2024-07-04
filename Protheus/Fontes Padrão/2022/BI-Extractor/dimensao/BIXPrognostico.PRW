#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPROGNOSTICO.CH"

REGISTER EXTRACTOR HYI

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPrognostico
Representação do extrator.

@author  Jorge Luis Branco Martins Junior
@since   19/05/2016
/*/
//-------------------------------------------------------------------
Class BIXPrognostico from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass
   
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@author  Jorge Luis Branco Martins Junior
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXPrognostico
	_Super:New( DIMENSION, "HYI", STR0001, "NQ7" )//"Prognóstico" 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXPrognostico 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HYI_PROGNO" )
	oModel:SetBK( { "HYI_CODIGO" } )

	oModel:AddField( "HYI_PROGNO" , "C", 32, 0 )
	oModel:AddField( "HYI_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HYI_DESC"   , "C", 50, 0 )		
	oModel:AddField( "HYI_PORCEN" , "N", 04, 0 )		
	oModel:AddField( "HYI_TIPO"   , "C", 10, 0 )		
	
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
@since   03/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXPrognostico
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "NQ7_COD", "NQ7_DESC", "NQ7_PORCEN", "NQ7_TIPO" } )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "NQ7_COD", 	(cFlow)->NQ7_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HYI_PROGNO", oKey:GetKey( { (cFlow)->NQ7_COD } ) )		
		oRecord:SetValue( "HYI_CODIGO", (cFlow)->NQ7_COD )
		oRecord:SetValue( "HYI_DESC"  , (cFlow)->NQ7_DESC )
		oRecord:SetValue( "HYI_PORCEN"  , (cFlow)->NQ7_PORCEN )
		oRecord:SetValue( "HYI_TIPO"  , (cFlow)->NQ7_TIPO )
		
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
