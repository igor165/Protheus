#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSTATUSENTREGA.CH"

REGISTER EXTRACTOR HOA

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXStatusEntrega
Visualiza as Informações pelo status de entrega. O status de entrega 
caracteriza a condição da entrega como entrega dentro do prazo ou 
entrega fora do prazo.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXStatusEntrega from BIXEntity
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
Method New() class BIXStatusEntrega
	_Super:New( DIMENSION, "HOA", STR0003 ) //"Status de Entrega"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXStatusEntrega
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HOA_STAENT" )
	oModel:SetBK( { "HOA_CODIGO" } )

	oModel:AddField( "HOA_STAENT" , "C", 32, 0 )
	oModel:AddField( "HOA_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HOA_DESC"   , "C", 20, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXStatusEntrega
	Local aOperacao 	:= { {"1", STR0001 }, {"2", STR0002 } } //"DENTRO DO PRAZO"###"FORA DO PRAZO"
	Local nOperacao		:= 1				    
	
	For nOperacao := 1 To Len( aOperacao )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HOA_STAENT", oKey:GetKey( { aOperacao[nOperacao][1] },,.F.) )		
		oRecord:SetValue( "HOA_CODIGO", aOperacao[nOperacao][1] )
		oRecord:SetValue( "HOA_DESC"  , aOperacao[nOperacao][2] )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next nTipo 	
 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil	