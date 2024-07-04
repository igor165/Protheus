#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXGRPESTOQUE.CH"

REGISTER EXTRACTOR HG3

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGrpEstoque
Visualiza as informações por código ou descrição do Grupo de Estoque. 
Grupo de Estoque é um agrupamento de itens com características 
homogêneas, definidos segundo critérios contábeis.

@author  BI TEAM
@since   30/07/2010
/*/
//-------------------------------------------------------------------
Class BIXGrpEstoque from BIXEntity
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
Method New() class BIXGrpEstoque
	_Super:New( DIMENSION, "HG3", STR0001, "SBM" ) //"Grupo de Estoque"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Tamara Clemente
@since   28/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXGrpEstoque 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HG3_GRPEST" )
	oModel:SetBK( { "HG3_CODIGO" } )

	oModel:AddField( "HG3_GRPEST"	, "C", 32, 0 )
	oModel:AddField( "HG3_CODIGO" 	, "C", 10, 0 )
	oModel:AddField( "HG3_DESC"   	, "C", 30, 0 )
	
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
@since   30/07/2010
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXGrpEstoque
 	Local cFlow := ""
    	
	cFlow := ::Flow( cFrom, cTo, { "BM_GRUPO", "BM_DESC"} )

 	While ! (cFlow)->( Eof() )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de customização. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "BM_GRUPO"		, (cFlow)->BM_GRUPO )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HG3_GRPEST"	, oKey:GetKey( { (cFlow)->BM_GRUPO } ) )
		oRecord:SetValue( "HG3_CODIGO"	, (cFlow)->BM_GRUPO )
		oRecord:SetValue( "HG3_DESC"	, (cFlow)->BM_DESC )

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