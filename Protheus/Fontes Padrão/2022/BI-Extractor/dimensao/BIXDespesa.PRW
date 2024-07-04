#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXDESPESA.CH"

REGISTER EXTRACTOR HGL

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXDespesa
Visualiza as informações por despesa / imposto dos processos de 
importação e exportação. Exemplos: Capatazia, Entreposto, Siscomex.

@author  BI TEAM
@since   12/08/2010
/*/
//-------------------------------------------------------------------
Class BIXDespesa from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Valdiney V GOMES
@version P12 
@since   18/11/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXDespesa
	_Super:New( DIMENSION, "HGL", STR0001, "SYB" ) // "Despesa" 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXDespesa 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HGL_DESPES" )
	oModel:SetBK( { "HGL_CODIGO" } )

	oModel:AddField( "HGL_DESPES" , "C", 32, 0 )
	oModel:AddField( "HGL_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HGL_DESC"   , "C", 40, 0 )		
	
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
@since   01/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXDespesa
 	Local cFlow := ""
	
	cFlow := ::Flow( cFrom, cTo, { "YB_DESP", "YB_DESCR"} )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "YB_DESP", 	(cFlow)->YB_DESP )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HGL_DESPES" , oKey:GetKey( { (cFlow)->YB_DESP } ) )		
		oRecord:SetValue( "HGL_CODIGO", (cFlow)->YB_DESP )
		oRecord:SetValue( "HGL_DESC"  , (cFlow)->YB_DESCR )
		
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