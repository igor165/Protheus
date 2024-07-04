#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSTATUSREQUISICAO.CH"

REGISTER EXTRACTOR HQE

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXStatusRequisicao
As informações são visualizadas por status em que se encontra a requisição
 de contratação. Exemplo: Em Andamento, Aprovada, Pendente etc. 

@author  BI TEAM
@since   17/11/2010
/*/
//-------------------------------------------------------------------
Class BIXStatusRequisicao from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Valdiney V GOMES
@since   17/11/2010
/*/
//-------------------------------------------------------------------  
Method New() class BIXStatusRequisicao
	_Super:New( DIMENSION, "HQE", STR0003 ) //"Status de Requisição"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXStatusRequisicao
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HQE_STAREQ" )
	oModel:SetBK( { "HQE_CODIGO" } )

	oModel:AddField( "HQE_STAREQ" , "C", 32, 0 )
	oModel:AddField( "HQE_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HQE_DESC"   , "C", 20, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXStatusRequisicao
	Local aStatus := {}
	Local nStatus  := 0
	
	aAdd( aStatus, { "F", STR0001 } ) //"FINALIZADA" 
	aAdd( aStatus, { "A", STR0002 } ) //"ABERTA" 

	For nStatus := 1 To Len( aStatus )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HQE_STAREQ", oKey:GetKey( { aStatus[nStatus][1] },,.F.) )		
		oRecord:SetValue( "HQE_CODIGO", aStatus[nStatus][1] )
		oRecord:SetValue( "HQE_DESC"  , aStatus[nStatus][2] )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next nStatus

 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil
