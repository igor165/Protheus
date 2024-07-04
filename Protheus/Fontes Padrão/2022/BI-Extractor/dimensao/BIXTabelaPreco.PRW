#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTABELAPRECO.CH"

REGISTER EXTRACTOR HGN

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTabelaPreco
As informações são visualizadas por tabela de preço e esta contempla 
os preços de vendas dos itens atualizados na data da venda.

@author  Helio Leal
@since   24/04/2017
/*/
//-------------------------------------------------------------------
Class BIXTabelaPreco From BIXEntity
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
Method New() class BIXTabelaPreco
	_Super:New( DIMENSION, "HGN", STR0001, "DA0" ) //"Tabela de preço"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   24/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTabelaPreco
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HGN_TABPCO" )
	oModel:SetBK( { "HGN_CODIGO" } )

	oModel:AddField( "HGN_TABPCO" , "C", 32, 0 )
	oModel:AddField( "HGN_CODIGO" , "C", 08, 0 )
	oModel:AddField( "HGN_DESC"   , "C", 40, 0 )

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTabelaPreco
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "DA0_CODTAB", "DA0_DESCRI" } )

	While ! (cFlow)->( Eof() )
		//-------------------------------------------------------------------
		// Inicializa o registro.
		//-------------------------------------------------------------------
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de customização. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "DA0_CODTAB"	, (cFlow)->DA0_CODTAB )

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HGN_TABPCO"	, oKey:GetKey( { (cFlow)->DA0_CODTAB } ) )
		oRecord:SetValue( "HGN_CODIGO"	, (cFlow)->DA0_CODTAB )
		oRecord:SetValue( "HGN_DESC"	, (cFlow)->DA0_DESCRI )

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
Return Nil