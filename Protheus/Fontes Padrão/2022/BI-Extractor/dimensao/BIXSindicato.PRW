#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSINDICATO.CH"

REGISTER EXTRACTOR HJV

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSindicato
As informações são visualizadas por código ou descrição dos Sindicatos 
aos quais os colaboradores estão associados. Os Sindicatos são associações
com a finalidade de estudo, defesa e coordenação dos interesses econômicos
e profissionais de todos aqueles que exerçam atividades ou profissões 
idênticas ou similares.

@author  BI TEAM
@since   09/08/2010
/*/
//-------------------------------------------------------------------
Class BIXSindicato from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Valdiney V GOMES
@since   04/01/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXSindicato
	_Super:New( DIMENSION, "HJV", STR0001, "RCE" ) //"Sindicato"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXSindicato
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJV_SINDIC" )
	oModel:SetBK( { "HJV_CODIGO" } )

	oModel:AddField( "HJV_SINDIC" , "C", 32, 0 )
	oModel:AddField( "HJV_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HJV_DESC"   , "C", 120, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXSindicato
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "RCE_CODIGO", "RCE_DESCRI" } )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "RCE_CODIGO", 	(cFlow)->RCE_CODIGO )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJV_SINDIC", oKey:GetKey( { (cFlow)->RCE_CODIGO } ) )		
		oRecord:SetValue( "HJV_CODIGO", (cFlow)->RCE_CODIGO )
		oRecord:SetValue( "HJV_DESC"  , (cFlow)->RCE_DESCRI )
		
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