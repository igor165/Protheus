#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXOPORTUNIDADE.CH"

REGISTER EXTRACTOR HSM

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXOportunidade
Visualiza as informações por código ou descrição da oportunidade de 
venda. A oportunidade de venda é destinada ao acompanhamento de uma 
venda potencial, visando a geração de receita e que precisa ser 
monitorada através de um processo de venda até sua conclusão.

@author  Helio Leal
@since   30/05/2017
/*/
//-------------------------------------------------------------------
Class BIXOportunidade from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )    
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@author  Helio Leal
@since   30/05/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXOportunidade
	_Super:New( DIMENSION, "HSM", STR0001, "AD1" ) // Oportunidade de venda
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   30/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXOportunidade 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HSM_OPOVEN" )
	oModel:SetBK( { "HSM_CODIGO" } )

	oModel:AddField( "HSM_OPOVEN" , "C", 32, 0 )
	oModel:AddField( "HSM_CODIGO" , "C", 10, 0 )
	oModel:AddField( "HSM_DESC"   , "C", 30, 0 )
	oModel:AddField( "HSM_REVISA" , "C", 03, 0 )

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
@since   30/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXOportunidade
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "AD1_NROPOR", "AD1_DESCRI", "AD1_REVISA" } )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "AD1_NROPOR", 	(cFlow)->AD1_NROPOR )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HSM_OPOVEN", oKey:GetKey( { (cFlow)->AD1_NROPOR } ) )		
		oRecord:SetValue( "HSM_CODIGO", (cFlow)->AD1_NROPOR )
		oRecord:SetValue( "HSM_DESC"  , (cFlow)->AD1_DESCRI )
		oRecord:SetValue( "HSM_REVISA", (cFlow)->AD1_REVISA )

		
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