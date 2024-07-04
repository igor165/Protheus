#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSITUCONTATO.CH"  

REGISTER EXTRACTOR HOL

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSituContato
Visualiza as informações pelo código e descrição da situação do contrato. 
Situação do contrato é a classificação da atividade do contrato. 
Exemplo: Vigente, Paralisado, Revisado, etc.

@author  Valdiney V GOMES
@since   27/03/2014
/*/
//-------------------------------------------------------------------
Class BIXSituContato from BIXEntity
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
Method New() class BIXSituContato
	_Super:New( DIMENSION, "HOL", STR0011 ) //"Situação do Contrato"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXSituContato
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HOL_SITCON" )
	oModel:SetBK( { "HOL_CODIGO" } )

	oModel:AddField( "HOL_SITCON" , "C", 32, 0 )
	oModel:AddField( "HOL_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HOL_DESC"   , "C", 24, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXSituContato
	Local aSituacao 	:= {} 
	Local nSituacao		:= 1	 
	
	aAdd( aSituacao, { "01", STR0001 } ) //"Cancelado"
	aAdd( aSituacao, { "02", STR0002 } ) //"Elaboração"
	aAdd( aSituacao, { "03", STR0003 } ) //"Emitido"
	aAdd( aSituacao, { "04", STR0004 } ) //"Aprovação"
	aAdd( aSituacao, { "05", STR0005 } ) //"Vigente"
	aAdd( aSituacao, { "06", STR0006 } ) //"Paralisado"
	aAdd( aSituacao, { "07", STR0007 } ) //"Solicitada Finalização"
	aAdd( aSituacao, { "08", STR0008 } ) //"Finalizado"
	aAdd( aSituacao, { "09", STR0009 } ) //"Revisão"
	aAdd( aSituacao, { "10", STR0010 } ) //"Revisado"
	
	For nSituacao := 1 To Len( aSituacao )
 		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HOL_SITCON", oKey:GetKey( { aSituacao[nSituacao][1] },,.F.) )		
		oRecord:SetValue( "HOL_CODIGO", aSituacao[nSituacao][1] )
		oRecord:SetValue( "HOL_DESC"  , aSituacao[nSituacao][2] )

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
