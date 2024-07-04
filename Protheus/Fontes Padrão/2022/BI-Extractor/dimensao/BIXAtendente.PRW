#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXATENDENTE.CH"

REGISTER EXTRACTOR HOH

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXAtendente
Visualiza as informações pelo código e nome do atendente. 
Atendente representa a pessoa/recurso disponível para a prestação 
de serviços contratados.

@author  Valdiney V GOMES
@since   27/03/2014
/*/
//-------------------------------------------------------------------
Class BIXAtendente from BIXEntity
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
Method New() class BIXAtendente
	_Super:New( DIMENSION, "HOH", STR0001, "AA1" ) //"Atendente"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXAtendente 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HOH_ATENDE" )
	oModel:SetBK( { "HOH_CODIGO" } )

	oModel:AddField( "HOH_ATENDE" , "C", 32, 0 )
	oModel:AddField( "HOH_CODIGO" , "C", 30, 0 )
	oModel:AddField( "HOH_NOME"   , "C", 30, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXAtendente
 	Local cFlow  := ""

	cFlow := ::Flow( cFrom, cTo, { "AA1_CODTEC", "AA1_NOMTEC" } )

 	While ! ( (cFlow)->( Eof() ) )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Alimenta os campos para customização. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "AA1_CODTEC"		, (cFlow)->AA1_CODTEC )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------		
		oRecord:SetValue( "HOH_ATENDE"	, oKey:GetKey( { (cFlow)->AA1_CODTEC } ) )	
		oRecord:SetValue( "HOH_CODIGO"	, (cFlow)->AA1_CODTEC )
		oRecord:SetValue( "HOH_NOME"	, (cFlow)->AA1_NOMTEC )
		
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
