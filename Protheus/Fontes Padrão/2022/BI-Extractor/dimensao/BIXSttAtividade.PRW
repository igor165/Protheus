#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSTTATIVIDADE.CH"

REGISTER EXTRACTOR HSK

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSttAtividade
Visualiza as informações pelo status em que se encontra a atividade. 

@author  Valdiney V GOMES
@since   23/04/2014
/*/
//-------------------------------------------------------------------
Class BIXSttAtividade from BIXEntity
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
Method New() class BIXSttAtividade
	_Super:New( DIMENSION, "HSK", STR0001 ) //"Status da Atividade"
Return Self  
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXSttAtividade
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HSK_STTATV" )
	oModel:SetBK( { "HSK_CODIGO" } )

	oModel:AddField( "HSK_STTATV" , "C", 32, 0 )
	oModel:AddField( "HSK_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HSK_DESC"   , "C", 20, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXSttAtividade
	Local aStatus  	:= {} 
	Local nCombo   := 1	       
	Local aCombo	:= {}

	SX3->( DBSetOrder( 2 ) )        
	
	If ( SX3->( DBSeek( "AOF_STATUS" ) ) )  
		aCombo  := aBIToken( X3CBox(), ";" )
	EndIf

	For nCombo := 1 To Len( aCombo )
		aStatus := aBIToken( aCombo[nCombo], "=", .F. )
		
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HSK_STTATV", oKey:GetKey( { aStatus[1] },,.F.) )		
		oRecord:SetValue( "HSK_CODIGO", aStatus[1] )
		oRecord:SetValue( "HSK_DESC"  , aStatus[2] )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next		
 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil	