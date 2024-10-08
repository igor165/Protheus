#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSINDICATO.CH"

REGISTER EXTRACTOR HJV

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSindicato
As informa��es s�o visualizadas por c�digo ou descri��o dos Sindicatos 
aos quais os colaboradores est�o associados. Os Sindicatos s�o associa��es
com a finalidade de estudo, defesa e coordena��o dos interesses econ�micos
e profissionais de todos aqueles que exer�am atividades ou profiss�es 
id�nticas ou similares.

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
M�todo construtor.  

@author  Valdiney V GOMES
@since   04/01/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXSindicato
	_Super:New( DIMENSION, "HJV", STR0001, "RCE" ) //"Sindicato"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
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
Extra��o dos dados para entidade. 
 
@param cFrom, caracter, Data inicial de extra��o. 
@param cTo, caracter, Data final de extra��o.
@param dToday, data, Data de inicio do processo de extra��o.  
@param oOutput, objeto, Objeto para grava��o dos dados.
@param oRecord, objeto, Objeto para extra��o dos dados.
@param oKey, objeto, Objeto para gera��o da surrogate key.

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
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "RCE_CODIGO", 	(cFlow)->RCE_CODIGO )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJV_SINDIC", oKey:GetKey( { (cFlow)->RCE_CODIGO } ) )		
		oRecord:SetValue( "HJV_CODIGO", (cFlow)->RCE_CODIGO )
		oRecord:SetValue( "HJV_DESC"  , (cFlow)->RCE_DESCRI )
		
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