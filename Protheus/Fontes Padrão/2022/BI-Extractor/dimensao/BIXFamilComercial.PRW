#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFAMILCOMERCIAL.CH"

REGISTER EXTRACTOR HG1

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXFamilComercial
Visualiza as informa��es por c�digo ou descri��o da Fam�lia Comercial. 
Fam�lia Comercial � um conjunto de itens do estoque, agrupados segundo 
crit�rios comerciais, que possibilitam � �rea comercial um melhor 
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
Construtor padr�o.  

@Return Self, Inst�ncia da classe.

@author  Tamara Clemente
@since   28/04/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXFamilComercial
	_Super:New( DIMENSION, "HG1", STR0001, "ACU" ) //"Fam�lia Comercial"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Tamara Clemente
@since   28/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXFamilComercial 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HG1_FAMCOM" )
	oModel:SetBK( { "HG1_CODIGO" } )

	oModel:AddUnifier( { "ACU_COD" }, STR0001 ) //"Fam�lia Comercial"

	oModel:AddField( "HG1_FAMCOM"	, "C", 32, 0 )
	oModel:AddField( "HG1_CODIGO" 	, "C", 10, 0 )
	oModel:AddField( "HG1_DESC"   	, "C", 30, 0 )
	oModel:AddField( "HG1_UNFACO"  	, "C", 05, 0 )
	
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
		// Alimenta os campos para customiza��o. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "ACU_COD"		, (cFlow)->ACU_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HG1_FAMCOM"	, oKey:GetKey( { (cFlow)->ACU_COD } ) )
		oRecord:SetValue( "HG1_CODIGO"	, (cFlow)->ACU_COD )
		oRecord:SetValue( "HG1_DESC"	, (cFlow)->ACU_DESC )
		oRecord:SetValue( "HG1_UNFACO"	, " " )

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