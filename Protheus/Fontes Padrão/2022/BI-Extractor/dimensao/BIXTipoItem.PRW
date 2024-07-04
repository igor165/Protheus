#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTIPOITEM.CH"

REGISTER EXTRACTOR HGC

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTipoItem
Visualiza as informações de tipo de item entre Comprados, Fabricados 
e Material.

@author  BI TEAM
@since   26/07/2010
/*/
//-------------------------------------------------------------------
Class BIXTipoItem from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Helio Leal
@since   02/12/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXTipoItem
	_Super:New( DIMENSION, "HGC", STR0004)  //"Tipo de Item"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTipoItem
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HGC_TIPITM" )
	oModel:SetBK( { "HGC_CODIGO" } )

	oModel:AddField( "HGC_TIPITM" , "C", 32, 0 )
	oModel:AddField( "HGC_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HGC_DESC"   , "C", 30, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTipoItem
 	Local nInd := 0
	Local aOrigem := {{ "1", STR0001 },; // "COMPRADO" 
						{ "2", STR0002 },; // "FABRICADO" 
						{ "3", STR0003 }}  // "MATERIA PRIMA" 

	for nInd := 1 to len( aOrigem )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HGC_TIPITM", oKey:GetKey( { aOrigem[nInd][1] },,.F.) )		
		oRecord:SetValue( "HGC_CODIGO", aOrigem[nInd][1] )
		oRecord:SetValue( "HGC_DESC"  , aOrigem[nInd][2] )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	next
 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil