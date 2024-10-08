#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXORIGEM.CH"

REGISTER EXTRACTOR HK7

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCliente
Visualiza as informa��es por Origem que refere-se � origem da 
composi��o das informa��es apresentadas. Exemplo: Contas a Receber, 
Contas A Pagar, Pedido de Venda, Pedido de Compra, Aplica��o Financeira, 
Empr�stimo Financeiro. 

@author  BI TEAM
@since   17/11/2010
/*/
//-------------------------------------------------------------------
Class BIXOrigem from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@Return Self, Inst�ncia da classe.

@author  Valdiney V GOMES
@since   08/03/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXOrigem
	_Super:New( DIMENSION, "HK7", STR0010 ) //"Origem"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Valdiney V GOMES
@since   20/02/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXOrigem 
	Local oModel := BIXModel():Build( Self )
	
	oModel:SetSK( "HK7_ORIGEM" )
	oModel:SetBK( { "HK7_CODIGO" } )	
	
	oModel:AddField( "HK7_ORIGEM" , "C", 32, 0 )
	oModel:AddField( "HK7_CODIGO" , "C", 10, 0 )
	oModel:AddField( "HK7_DESC"   , "C", 32, 0 )

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

@author  BI TEAM
@since   26/07/2010
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXOrigem
	Local aOrigem 	:= {} 
	Local nOrigem	:= 1				    
	
	aAdd( aOrigem, {"1", STR0001 } ) //"TITULOS A RECEBER"
	aAdd( aOrigem, {"2", STR0002 } ) //"TITULOS A PAGAR" 
	aAdd( aOrigem, {"3", STR0003 } ) //"COMISSOES" 
	aAdd( aOrigem, {"4", STR0004 } ) //"PEDIDO DE VENDA" 
	aAdd( aOrigem, {"5", STR0005 } ) //"PEDIDO DE COMPRA" 
	aAdd( aOrigem, {"6", STR0006 } ) //"APLICACOES" 
	aAdd( aOrigem, {"7", STR0007 } ) //"EMPRESTIMOS" 
	aAdd( aOrigem, {"8", STR0008 } ) //"CHEQUES NAO LIBERADOS" 
	aAdd( aOrigem, {"9", STR0009 } ) //"DOCTOS. DE TRANSPORTE" 
	
	For nOrigem := 1 To Len( aOrigem )
 		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HK7_ORIGEM"	, oKey:GetKey( { aOrigem[nOrigem][1] }, .T., .F. ) )
		oRecord:SetValue( "HK7_CODIGO"	, aOrigem[nOrigem][1] )
		oRecord:SetValue( "HK7_DESC"	, aOrigem[nOrigem][2] )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------	
		oOutput:Send( oRecord ) 
	Next nOrigem 	
	
	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()	
Return nil