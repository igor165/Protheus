#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPEDIDOSJURIDICO.CH"

REGISTER EXTRACTOR HYL

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPedidosJuridico
Visualiza as informações do assuntors jurídicos de acordo com os tipo 
de pedidos realizados em um processo.

@author  Jorge Luis Branco Martins Junior
@since   23/05/2016
/*/
//-------------------------------------------------------------------
Class BIXPedidosJuridico from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass
   
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@author  Jorge Luis Branco Martins Junior
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXPedidosJuridico
	_Super:New( DIMENSION, "HYL", STR0001, "NSP" ) //"Pedidos Jurídico"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   02/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXPedidosJuridico 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HYL_PEDJUR" )
	oModel:SetBK( { "HYL_CODIGO" } )

	oModel:AddField( "HYL_PEDJUR" , "C", 32, 0 )
	oModel:AddField( "HYL_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HYL_DESC"   , "C", 100, 0 )		
	oModel:AddField( "HYL_TIPO"   , "C", 15, 0 )		
	
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
@since   02/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXPedidosJuridico
 	Local cFlow := ""
	
	cFlow := ::Flow( cFrom, cTo, { "NSP_COD", "NSP_DESC", "NSP_TIPO" } )
	
 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "NSP_COD", (cFlow)->NSP_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HYL_PEDJUR" , oKey:GetKey( { (cFlow)->NSP_COD } ) )		
		oRecord:SetValue( "HYL_CODIGO" , (cFlow)->NSP_COD )
		oRecord:SetValue( "HYL_DESC"   , (cFlow)->NSP_DESC )
		oRecord:SetValue( "HYL_TIPO"   , (cFlow)->NSP_TIPO )
		
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
