#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTPOPERACAO.CH"

REGISTER EXTRACTOR HO6

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTpOperacao
Visualiza as informações por tipo de operação. O tipo da operação indica 
se o serviço operacional é do tipo transporte ou carregamento.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXTpOperacao from BIXEntity
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
Method New() class BIXTpOperacao
	_Super:New( DIMENSION, "HO6", STR0003) //"Tipo de Operação"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   14/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTpOperacao 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HO6_TIPOPE" )
	oModel:SetBK( { "HO6_CODIGO" } )

	oModel:AddField( "HO6_TIPOPE", "C", 32, 0 )
	oModel:AddField( "HO6_CODIGO", "C", 10, 0 )
	oModel:AddField( "HO6_DESC"  , "C", 12, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTpOperacao
	Local aOperacao 	:= { {"1", "CARREGAMENTO" }, {"2", "TRANSPORTE" } }  //"CARREGAMENTO"###"TRANSPORTE"
	Local nOperacao		:= 1				    
	
	For nOperacao := 1 To Len( aOperacao )
 		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HO6_TIPOPE", oKey:GetKey( { aOperacao[nOperacao][1] },,.F.) )		
		oRecord:SetValue( "HO6_CODIGO", aOperacao[nOperacao][1] )
		oRecord:SetValue( "HO6_DESC"  , aOperacao[nOperacao][2] )

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