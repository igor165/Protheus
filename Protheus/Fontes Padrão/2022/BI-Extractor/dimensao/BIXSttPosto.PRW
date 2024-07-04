#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSTTPOSTO.CH" 

REGISTER EXTRACTOR HOO

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSttPosto
Visualiza as informações pelo código e descrição do status do posto. 
Status do posto classifica o posto quanto ao atendimento dos serviços 
contratados. Exemplo: Posto Coberto, Posto Descoberto, Posto Excedido, etc.

@author  Valdiney V GOMES
@since   27/03/2014
/*/
//-------------------------------------------------------------------
Class BIXSttPosto from BIXEntity
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
Method New() class BIXSttPosto
	_Super:New( DIMENSION, "HOO", STR0005 ) //"Status do Posto"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXSttPosto
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HOO_STTPOS" )
	oModel:SetBK( { "HOO_CODIGO" } )

	oModel:AddField( "HOO_STTPOS" , "C", 32, 0 )
	oModel:AddField( "HOO_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HOO_DESC"   , "C", 30, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXSttPosto
	Local aStatus 	:= {} 
	Local nStatus	:= 1				    
	
	aAdd( aStatus, { "01", STR0001 } ) //"Posto Coberto"      
	aAdd( aStatus, { "02", STR0002 } ) //"Posto Descoberto"   
	aAdd( aStatus, { "03", STR0003 } ) //"Posto Excedido"
	aAdd( aStatus, { "04", STR0004 } ) //"Dia de Serviço não Contratado"                        
	
	For nStatus := 1 To Len( aStatus )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HOO_STTPOS", oKey:GetKey( { aStatus[nStatus][1] },,.F.) )		
		oRecord:SetValue( "HOO_CODIGO", aStatus[nStatus][1] )
		oRecord:SetValue( "HOO_DESC"  , aStatus[nStatus][2] )

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