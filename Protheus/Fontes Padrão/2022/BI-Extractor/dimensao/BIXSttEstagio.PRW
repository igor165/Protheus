#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSTTESTAGIO.CH"

REGISTER EXTRACTOR HSJ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSttEstagio
Visualiza as informa��es pelo status em que se encontra o est�gio da 
oportunidade de venda. Ex: Em andamento, em Atraso, etc.

@author  Valdiney V GOMES
@since   23/04/2014
/*/
//-------------------------------------------------------------------
Class BIXSttEstagio from BIXEntity
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
Method New() class BIXSttEstagio
	_Super:New( DIMENSION, "HSJ", STR0005 ) //"Status do Est�gio"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXSttEstagio
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HSJ_STTEST" )
	oModel:SetBK( { "HSJ_CODIGO" } )

	oModel:AddField( "HSJ_STTEST" , "C", 32, 0 )
	oModel:AddField( "HSJ_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HSJ_DESC"   , "C", 20, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXSttEstagio
	Local aStatus 	:= {} 
	Local nStatus	:= 1
	
	aAdd( aStatus, {"1", STR0001 } )  //"Em Andamento"
	aAdd( aStatus, {"2", STR0002 } )  //"Em Atraso"	
	aAdd( aStatus, {"3", STR0003 } )  //"Encerrado sem Atraso"
	aAdd( aStatus, {"4", STR0004 } )  //"Encerrado com Atraso"
				    
	For nStatus := 1 To Len( aStatus )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HSJ_STTEST", oKey:GetKey( { aStatus[nStatus][1] },,.F.) )		
		oRecord:SetValue( "HSJ_CODIGO", aStatus[nStatus][1] )
		oRecord:SetValue( "HSJ_DESC"  , aStatus[nStatus][2] )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next nTipo 	
 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil