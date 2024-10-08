#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCURSO.CH"

REGISTER EXTRACTOR HJL

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCurso
Visualiza as informa��es por c�digo ou descri��o do Curso. Curso � um 
treinamento fornecido e controlado pela empresa aos seus colaboradores.

@author  BI TEAM
@since   09/08/2010
/*/
//-------------------------------------------------------------------
Class BIXCurso from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author  Valdiney V GOMES
@version P12 
@since   05/12/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXCurso
	_Super:New( DIMENSION, "HJL", STR0001, "RA1" ) //"Curso"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXCurso 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJL_CURSO" )
	oModel:SetBK( { "HJL_CODIGO" } )

	oModel:AddField( "HJL_CURSO" , "C", 32, 0 )
	oModel:AddField( "HJL_CODIGO", "C", 16, 0 )
	oModel:AddField( "HJL_DESC"  , "C", 120, 0 )		
	
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
@since   01/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXCurso
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "RA1_CURSO", "RA1_DESC"} )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "RA1_CURSO", 	(cFlow)->RA1_CURSO )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJL_CURSO" , oKey:GetKey( { (cFlow)->RA1_CURSO } ) )		
		oRecord:SetValue( "HJL_CODIGO", (cFlow)->RA1_CURSO )
		oRecord:SetValue( "HJL_DESC"  , (cFlow)->RA1_DESC )
		
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
