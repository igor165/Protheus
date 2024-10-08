#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXGRPESTOQUE.CH"

REGISTER EXTRACTOR HG3

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGrpEstoque
Visualiza as informa��es por c�digo ou descri��o do Grupo de Estoque. 
Grupo de Estoque � um agrupamento de itens com caracter�sticas 
homog�neas, definidos segundo crit�rios cont�beis.

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
Construtor padr�o.  

@Return Self, Inst�ncia da classe.

@author  Tamara Clemente
@since   28/04/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXGrpEstoque
	_Super:New( DIMENSION, "HG3", STR0001, "SBM" ) //"Grupo de Estoque"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
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
Extra��o dos dados para entidade. 
 
@param cFrom, caracter, Data inicial de extra��o. 
@param cTo, caracter, Data final de extra��o.
@param dToday, data, Data de inicio do processo de extra��o.  
@param oOutput, objeto, Objeto para grava��o dos dados.
@param oRecord, objeto, Objeto para extra��o dos dados.
@param oKey, objeto, Objeto para gera��o da surrogate key.

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
		// Alimenta os campos de customiza��o. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "BM_GRUPO"		, (cFlow)->BM_GRUPO )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HG3_GRPEST"	, oKey:GetKey( { (cFlow)->BM_GRUPO } ) )
		oRecord:SetValue( "HG3_CODIGO"	, (cFlow)->BM_GRUPO )
		oRecord:SetValue( "HG3_DESC"	, (cFlow)->BM_DESC )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------	
		oOutput:Send( oRecord ) 

 		(cFlow)->( DBSkip() ) 
 	EndDo  
 	
	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil