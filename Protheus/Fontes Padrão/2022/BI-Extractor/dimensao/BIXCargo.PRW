#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCARGO.CH"

REGISTER EXTRACTOR HJP

//--------------------------------------------------------------------
/*/{Protheus.doc} BIXCargo
Visualiza as informações por código ou descrição do cargo dos 
colaboradores. Os Cargos descriminam as funções exercidas dentro da 
organização.

@author  BI TEAM
@since   11/08/2010

/*/
//-------------------------------------------------------------------
Class BIXCargo from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@author  Marcia Junko
@since   01/05/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXCargo
	_Super:New( DIMENSION, "HJP", STR0001, "SRJ" ) //"Cargo"
Return Self 


//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXCargo 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJP_CARGO" )
	oModel:SetBK( { "HJP_CODIGO" } )

	oModel:AddField( "HJP_CARGO" 	, "C", 32, 0 )
	oModel:AddField( "HJP_CODIGO" 	, "C", 20, 0 )
	oModel:AddField( "HJP_NIVEL"  	, "C", 16, 0 )
	oModel:AddField( "HJP_DESC"  	, "C", 40, 0 )
	oModel:AddField( "HJP_CC"  		, "C", 25, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXCargo
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "RJ_FUNCAO", "RJ_DESC"} )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "RJ_FUNCAO", 	(cFlow)->RJ_FUNCAO )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJP_CARGO" , oKey:GetKey( { (cFlow)->RJ_FUNCAO } ) )		
		oRecord:SetValue( "HJP_CODIGO", (cFlow)->RJ_FUNCAO )
		oRecord:SetValue( "HJP_DESC"  , (cFlow)->RJ_DESC )
		oRecord:SetValue( "HJP_NIVEL" , ' ' )
		oRecord:SetValue( "HJP_CC"    , ' ' )
		
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