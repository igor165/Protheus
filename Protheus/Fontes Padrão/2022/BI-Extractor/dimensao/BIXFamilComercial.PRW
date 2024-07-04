#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFAMILCOMERCIAL.CH"

REGISTER EXTRACTOR HG1

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXFamilComercial
Visualiza as informações por código ou descrição da Família Comercial. 
Família Comercial é um conjunto de itens do estoque, agrupados segundo 
critérios comerciais, que possibilitam à área comercial um melhor 
gerenciamento sobre produtos vendidos.

@author  BI TEAM
@since   05/08/2010
/*/
//-------------------------------------------------------------------
Class BIXFamilComercial from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Tamara Clemente
@since   28/04/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXFamilComercial
	_Super:New( DIMENSION, "HG1", STR0001, "ACU" ) //"Família Comercial"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Tamara Clemente
@since   28/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXFamilComercial 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HG1_FAMCOM" )
	oModel:SetBK( { "HG1_CODIGO" } )

	oModel:AddUnifier( { "ACU_COD" }, STR0001 ) //"Família Comercial"

	oModel:AddField( "HG1_FAMCOM"	, "C", 32, 0 )
	oModel:AddField( "HG1_CODIGO" 	, "C", 10, 0 )
	oModel:AddField( "HG1_DESC"   	, "C", 30, 0 )
	oModel:AddField( "HG1_UNFACO"  	, "C", 05, 0 )
	
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

@author  BI TEAM
@since  05/08/2010
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXFamilComercial
 	Local cFlow := ""
    	
	cFlow := ::Flow( cFrom, cTo, { "ACU_COD", "ACU_DESC"} )

 	While ! (cFlow)->( Eof() )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos para customização. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "ACU_COD"		, (cFlow)->ACU_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HG1_FAMCOM"	, oKey:GetKey( { (cFlow)->ACU_COD } ) )
		oRecord:SetValue( "HG1_CODIGO"	, (cFlow)->ACU_COD )
		oRecord:SetValue( "HG1_DESC"	, (cFlow)->ACU_DESC )
		oRecord:SetValue( "HG1_UNFACO"	, " " )

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