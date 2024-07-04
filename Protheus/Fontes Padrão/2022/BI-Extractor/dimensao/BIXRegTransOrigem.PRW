#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXREGTRANSORIGEM.CH"

REGISTER EXTRACTOR HO0

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRegTransOrigem
Visualiza as informações pela região que originou o transporte. 
As regiões de transporte não são necessariamente regiões geográficas, 
podendo ser definidas de acordo com trajeto e preços aplicados pela 
transportadora.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXRegTransOrigem from BIXEntity
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
Method New() class BIXRegTransOrigem
	_Super:New( DIMENSION, "HO0", STR0001, "DUY" ) //"Região de Transporte de Origem"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXRegTransOrigem 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HO0_REGTRA" )
	oModel:SetBK( { "HO0_CODIGO" } )

	oModel:AddField( "HO0_REGTRA" , "C", 32, 0 )
	oModel:AddField( "HO0_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HO0_DESC"   , "C", 30, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXRegTransOrigem
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "DUY_GRPVEN", "DUY_DESCRI" } )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "DUY_GRPVEN", 	(cFlow)->DUY_GRPVEN )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HO0_REGTRA", oKey:GetKey( { (cFlow)->DUY_GRPVEN } ) )		
		oRecord:SetValue( "HO0_CODIGO", (cFlow)->DUY_GRPVEN )
		oRecord:SetValue( "HO0_DESC"  , (cFlow)->DUY_DESCRI )
		
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