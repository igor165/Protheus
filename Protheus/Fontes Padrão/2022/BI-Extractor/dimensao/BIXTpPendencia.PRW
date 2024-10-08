#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTPPENDENCIA.CH"

REGISTER EXTRACTOR HHY

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTpPendencia
Visualiza as informa��es por tipo de pend�ncia gerada durante o processo 
de entrega da mercadoria. O tipo da pend�ncia � o detalhe da ocorr�ncia 
de viagem, quando esta gera alguma pend�ncia no processo.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXTpPendencia from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass
   
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@author  Valdiney V GOMES
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXTpPendencia
	_Super:New( DIMENSION, "HHY", STR0001) //"Tipo de Pend�ncia"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   14/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTpPendencia
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HHY_TIPPEN" )
	oModel:SetBK( { "HHY_CODIGO" } )

	oModel:AddField( "HHY_TIPPEN", "C", 32, 0 )
	oModel:AddField( "HHY_CODIGO", "C", 10, 0 )
	oModel:AddField( "HHY_DESC"  , "C", 20, 0 )
	
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
@since   14/05/2017

/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTpPendencia
	Local aTipo := TMSValField( "TIPPND", .F., .F., .F., .T., .F., .T. )
	Local nTipo	:= 1				    
	
	For nTipo := 1 To Len( aTipo )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HHY_TIPPEN"	, oKey:GetKey( { aTipo[nTipo][1] },,.F.) )
		oRecord:SetValue( "HHY_CODIGO"	, aTipo[nTipo][1] )
		oRecord:SetValue( "HHY_DESC"	, aTipo[nTipo][2] )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------	
		oOutput:Send( oRecord ) 

 	Next nTipo  
 	
	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil

