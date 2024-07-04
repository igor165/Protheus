#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTIPOCURSO.CH"

REGISTER EXTRACTOR HG6

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTipoCurso
As informações são visualizadas por código ou descrição do tipo de curso. 
O Tipo de Curso visa classificar e/ou agrupar os diversos cursos fornecidos
pela empresa. Exemplo: Curso Administrativo, Curso Técnico, Curso de Idiomas. 

@author  BI TEAM
@since   16/12/2010
/*/
//-------------------------------------------------------------------
Class BIXTipoCurso from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Valdiney V GOMES
@since   16/12/2010
/*/
//-------------------------------------------------------------------  
Method New() class BIXTipoCurso
	_Super:New( DIMENSION, "HG6", STR0001, "SQX" ) //"Tipo de Curso"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTipoCurso 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HG6_TIPCUR" )
	oModel:SetBK( { "HG6_CODIGO" } )

	oModel:AddField( "HG6_TIPCUR" , "C", 32, 0 )
	oModel:AddField( "HG6_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HG6_DESC"   , "C", 40, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTipoCurso
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "QX_CODIGO", "QX_DESC" } )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "QX_CODIGO", 	(cFlow)->QX_CODIGO )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HG6_TIPCUR", oKey:GetKey( { (cFlow)->QX_CODIGO } ) )		
		oRecord:SetValue( "HG6_CODIGO", (cFlow)->QX_CODIGO )
		oRecord:SetValue( "HG6_DESC"  , (cFlow)->QX_DESC )
		
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