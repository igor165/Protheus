#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTIPOPODER3.CH"

REGISTER EXTRACTOR HQX

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTipoPoder3
Visualiza as informa��es por Tipo de Poder de Terceiros. 
O tipo caracteriza a modalidade do poder de terceiro exercido, 
podendo ser interno ou externo.

@author  BI TEAM
@since   17/11/2010
/*/
//-------------------------------------------------------------------
Class BIXTipoPoder3 from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author  Helio Leal
@since   02/12/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXTipoPoder3
	_Super:New( DIMENSION, "HQX", STR0003 ) //"Tipo de Poder Terceiro" 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTipoPoder3 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HQX_TPODER" )
	oModel:SetBK( { "HQX_CODIGO" } )

	oModel:AddField( "HQX_TPODER" , "C", 32, 0 )
	oModel:AddField( "HQX_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HQX_DESC"   , "C", 20, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTipoPoder3
	Local nInd := 0
	Local aTipo := {{ "1", STR0001 } ,; // "INTERNO" 
					  { "2", STR0002 } }  // "EXTERNO" 

	for nInd := 1 to len( aTipo )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HQX_TPODER", oKey:GetKey( { aTipo[nInd][1] },,.F.) )		
		oRecord:SetValue( "HQX_CODIGO", aTipo[nInd][1] )
		oRecord:SetValue( "HQX_DESC"  , aTipo[nInd][2] )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	next
 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil