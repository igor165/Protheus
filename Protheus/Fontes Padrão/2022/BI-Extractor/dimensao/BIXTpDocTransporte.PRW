#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTPDOCTRANSPORTE.CH"

REGISTER EXTRACTOR HO2

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTpDocTransporte
Visualiza as informações pelo tipo do documento de transporte. O tipo de 
documento de transporte caracteriza os faturamentos extras a partir do 
tipo do documento que o gerou: Reentrega e/ou devolução.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXTpDocTransporte from BIXEntity
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
Method New() class BIXTpDocTransporte
	_Super:New( DIMENSION, "HO2", STR0001 ) //"Tipo de Documento de Transporte"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Tamara Clemente
@since   28/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTpDocTransporte
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HO2_TIPDOC" )
	oModel:SetBK( { "HO2_CODIGO" } )

	oModel:AddField( "HO2_TIPDOC"	, "C", 32, 0 )
	oModel:AddField( "HO2_CODIGO" 	, "C", 10, 0 )
	oModel:AddField( "HO2_DESC"   	, "C", 30, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTpDocTransporte
	Local aTipo := TMSValField( "DOCTMS", .F., .F., .F., .T., .F., .T. )
	Local nTipo	:= 1				    

	For nTipo := 1 To Len( aTipo )
 		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HO2_TIPDOC", oKey:GetKey( { aTipo[nTipo][1] }, , .F. ) )		
		oRecord:SetValue( "HO2_CODIGO", aTipo[nTipo][1] )
		oRecord:SetValue( "HO2_DESC"  , aTipo[nTipo][2] )

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
