#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXATIVIDADE.CH"

REGISTER EXTRACTOR HO5

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXAtividade
Visualiza as Informações por atividade. Atividade é a ação executada 
por um recurso humano ou físico dentro do armazem ou da transportadora, 
como Refeição, Descanso, etc..

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXAtividade from BIXEntity
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
Method New() class BIXAtividade
	_Super:New( DIMENSION, "HO5", STR0001, "SX5" ) //"Atividade"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXAtividade 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HO5_ATIVID" )
	oModel:SetBK( { "HO5_CODIGO" } )

	oModel:AddField( "HO5_ATIVID" , "C", 32, 0 )
	oModel:AddField( "HO5_CODIGO" , "C", 10, 0 )
	oModel:AddField( "HO5_DESC"   , "C", 55, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXAtividade
 	Local aContent := {}
	local nI 	   := 0

	aContent := FWGetSX5("L3")

 	for nI := 1 to Len( aContent )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "X5_CHAVE",  aContent[nI][3] ) 
		oRecord:SetValue( "X5_TABELA", aContent[nI][2] ) 
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HO5_ATIVID", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HO5_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HO5_DESC"  , aContent[nI][4] )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 

	Next

 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()

	FWFreeArray( aContent ) 
Return nil
