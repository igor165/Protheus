#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXEQUIPE.CH"

REGISTER EXTRACTOR HSO

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXEquipe
Visualiza as informações por código ou descrição da equipe de venda. 
Equipe de venda é um grupo de vendedores ou representantes destinados 
à realização de vendas.

@author  Valdiney V GOMES
@version P12 
@since   23/04/2014
/*/
//-------------------------------------------------------------------
Class BIXEquipe from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )   
EndClass
     
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@author  Valdiney V GOMES
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXEquipe
	_Super:New( DIMENSION, "HSO", STR0001, "ACA" ) //"Equipe"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXEquipe
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HSO_EQUVEN" )
	oModel:SetBK( { "HSO_CODIGO" } )

	oModel:AddField( "HSO_EQUVEN" , "C", 32, 0 )
	oModel:AddField( "HSO_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HSO_DESC"   , "C", 30, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXEquipe
 	Local cFlow := ""
	
	cFlow := ::Flow( cFrom, cTo, { "ACA_GRPREP", "ACA_DESCRI"} )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "ACA_GRPREP", 	(cFlow)->ACA_GRPREP )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HSO_EQUVEN" , oKey:GetKey( { (cFlow)->ACA_GRPREP } ) )		
		oRecord:SetValue( "HSO_CODIGO", (cFlow)->ACA_GRPREP )
		oRecord:SetValue( "HSO_DESC"  , (cFlow)->ACA_DESCRI )
		
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