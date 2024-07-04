#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSTTOPORTUNIDADE.CH"

REGISTER EXTRACTOR HSG

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSttOportunidade
Visualiza as informações pelo status em que se encontra a oportunidade 
de venda. Ex: aberta, suspensa, ganha, etc.

@author  Valdiney V GOMES
@since   23/04/2014
/*/
//-------------------------------------------------------------------
Class BIXSttOportunidade from BIXEntity
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
Method New() class BIXSttOportunidade
	_Super:New( DIMENSION, "HSG", STR0001 ) //"Status da Oportunidade"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXSttOportunidade
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HSG_STTOPO" )
	oModel:SetBK( { "HSG_CODIGO" } )

	oModel:AddField( "HSG_STTOPO" , "C", 32, 0 )
	oModel:AddField( "HSG_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HSG_DESC"   , "C", 10, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXSttOportunidade
	Local aStatus 	:= {}  
	Local nCombo 	:= 1      
	Local aCombo	:= {}

	SX3->( DBSetOrder( 2 ) )        
	
	If ( SX3->( DBSeek( "AD1_STATUS" ) ) )  
		aCombo := aBIToken( X3CBox(), ";" )

		For nCombo := 1 To Len( aCombo )
			aStatus := aBIToken( aCombo[nCombo], "=", .F. )
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//-------------------------------------------------------------------   	
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Alimenta os campos de negócio. 
			//-------------------------------------------------------------------
			oRecord:SetValue( "HSG_STTOPO", oKey:GetKey( { aStatus[1] },,.F.) )		
			oRecord:SetValue( "HSG_CODIGO", aStatus[1] )
			oRecord:SetValue( "HSG_DESC"  , aStatus[2] )
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação da Fluig Smart Data. 
			//-------------------------------------------------------------------		
			oOutput:Send( oRecord ) 
		Next		
		//-------------------------------------------------------------------
		// Libera o pool de gravação. 
		//-------------------------------------------------------------------	
		oOutput:Release()
	EndIf
Return nil