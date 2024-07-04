#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCONDICAOPAGTO.CH"

REGISTER EXTRACTOR HJA

//--------------------------------------------------------------------
/*/{Protheus.doc} BIXCondicaoPagto
As informações são visualizadas por código ou descrição da Condição de Pagamento.

@author  Helio Leal
@since   24/04/2017
/*/
//-------------------------------------------------------------------
Class BIXCondicaoPagto from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrão.

@Return Self, Instância da classe.

@author  Helio Leal
@since   24/04/2017
/*/
//-------------------------------------------------------------------
Method New() Class BIXCondicaoPagto
	_Super:New( DIMENSION, "HJA", STR0001, "SE4"  )	//"Condição de pagamento"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   24/04/2017
/*/
//-------------------------------------------------------------------
Method Model() Class BIXCondicaoPagto
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJA_CONDPG" )
	oModel:SetBK( { "HJA_CODIGO" } )

	oModel:AddField("HJA_CONDPG", "C",  32, 0 )
	oModel:AddField("HJA_CODIGO", "C",  10, 0 )
	oModel:AddField("HJA_DESC" 	, "C",  35, 0 )

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

@author  Helio Leal
@since   24/04/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXCondicaoPagto
	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "E4_CODIGO", "E4_DESCRI" } )

	While ! (cFlow)->( Eof() )
		//-------------------------------------------------------------------
		// Inicializa o registro.
		//-------------------------------------------------------------------
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de customização.
		//-------------------------------------------------------------------
		oRecord:SetValue( "E4_CODIGO"	, (cFlow)->E4_CODIGO )

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJA_CONDPG"	, oKey:GetKey( { (cFlow)->E4_CODIGO } ) )
		oRecord:SetValue( "HJA_CODIGO"	, (cFlow)->E4_CODIGO )
		oRecord:SetValue( "HJA_DESC"	, (cFlow)->E4_DESCRI )

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