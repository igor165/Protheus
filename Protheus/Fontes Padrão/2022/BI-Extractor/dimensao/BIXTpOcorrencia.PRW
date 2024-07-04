#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTPOCORRENCIA.CH"

REGISTER EXTRACTOR HO8

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTpOcorrencia
Visualiza as informações pela ocorrência. Ocorrências são os fatos 
ocorridos durante uma viagem. As ocorrências representadas por esta 
dimensão serão apenas ocorrências que geraram pendências ou indenização 
durante a viagem.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXTpOcorrencia from BIXEntity
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
Method New() class BIXTpOcorrencia
	_Super:New( DIMENSION, "HO8", STR0001) //"Tipo de Ocorrência"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   14/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTpOcorrencia 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HO8_TIPOCO" )
	oModel:SetBK( { "HO8_CODIGO" } )

	oModel:AddField( "HO8_TIPOCO", "C", 32, 0 )
	oModel:AddField( "HO8_CODIGO", "C", 10, 0 )
	oModel:AddField( "HO8_DESC"  , "C", 30, 0 )
	
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
@since   14/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTpOcorrencia
	Local aTipo := TMSValField( "TIPOCO", .F., .F., .F., .T., .F., .T. )
	Local nTipo	:= 1				    

	For nTipo := 1 To Len( aTipo )
 		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HO8_TIPOCO", oKey:GetKey( { aTipo[nTipo][1] },,.F.) )		
		oRecord:SetValue( "HO8_CODIGO", aTipo[nTipo][1] )
		oRecord:SetValue( "HO8_DESC"  , aTipo[nTipo][2] )

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