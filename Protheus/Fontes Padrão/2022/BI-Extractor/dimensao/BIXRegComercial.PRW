#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXREGCOMERCIAL.CH"

REGISTER EXTRACTOR HGD

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRegComercial
Visualiza as informações por Região Comercial. Regiões comerciais 
são localizações comerciais na qual a empresa, seus estabelecimentos, 
clientes e representantes atuam.

@author  Helio Leal
@since   24/04/2017
/*/
//-------------------------------------------------------------------
Class BIXRegComercial From BIXEntity
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
Method New() class BIXRegComercial
	_Super:New( DIMENSION, "HGD", STR0001, "ACY" ) //"Região Comercial"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   20/02/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXRegComercial
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HGD_REGCOM" )
	oModel:SetBK( { "HGD_CODIGO" } )

	oModel:AddField( "HGD_REGCOM" , "C", 32, 0 )
	oModel:AddField( "HGD_CODIGO" , "C", 12, 0 )
	oModel:AddField( "HGD_DESC"   , "C", 40, 0 )

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
@since   26/07/2010
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXRegComercial
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "ACY_GRPVEN", "ACY_DESCRI" } )

 	While ! (cFlow)->( Eof() )
		//-------------------------------------------------------------------
		// Inicializa o registro.
		//-------------------------------------------------------------------
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de customização.
		//-------------------------------------------------------------------
		oRecord:SetValue( "ACY_GRPVEN"		, (cFlow)->ACY_GRPVEN )

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio.
		//-------------------------------------------------------------------
		oRecord:SetValue( "HGD_REGCOM"	, oKey:GetKey( { (cFlow)->ACY_GRPVEN } ) )
		oRecord:SetValue( "HGD_CODIGO"	, (cFlow)->ACY_GRPVEN )
		oRecord:SetValue( "HGD_DESC"	, (cFlow)->ACY_DESCRI )

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