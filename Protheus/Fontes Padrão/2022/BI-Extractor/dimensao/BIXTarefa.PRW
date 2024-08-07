#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTAREFA.CH"

REGISTER EXTRACTOR HO4

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTarefa
Visualiza as informa��es por tarefa. Tarefa � o conjunto de atividades 
realizadas durante uma opera��o, como Chegada, Sa�da, etc.

@author  Valdiney V GOMES
@since   06/03/2014
/*/
//-------------------------------------------------------------------
Class BIXTarefa from BIXEntity
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
Method New() class BIXTarefa
	_Super:New( DIMENSION, "HO4", STR0001, "SX5" ) //"Tarefa"
Return Self 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTarefa
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HO4_TAREFA" )
	oModel:SetBK( { "HO4_CODIGO" } )

	oModel:AddField( "HO4_TAREFA" , "C", 32, 0 )
	oModel:AddField( "HO4_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HO4_DESC"   , "C", 55, 0 )		
	
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
@since   01/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTarefa
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "L2" )

	For nI := 1 to Len( aContent )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "X5_CHAVE", 	aContent[nI][3] ) 
		oRecord:SetValue( "X5_TABELA", 	aContent[nI][2] ) 
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HO4_TAREFA", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HO4_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HO4_DESC"  , aContent[nI][4] )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 

	Next

 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()

	FWFreeArray( aContent )
Return nil