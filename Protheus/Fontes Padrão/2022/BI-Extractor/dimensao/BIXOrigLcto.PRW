#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXORIGLCTO.CH"

REGISTER EXTRACTOR HS7

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXOrigLcto
Visualiza as informações pela origem do lançamento. A origem do 
lançamento determina se ele é proveniete do módulo de faturamento ou 
do varejo.

@author  Valdiney V GOMES
@since   10/04/2014
/*/
//-------------------------------------------------------------------
Class BIXOrigLcto from BIXEntity
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
Method New() class BIXOrigLcto
	_Super:New( DIMENSION, "HS7", STR0004 ) // "Origem do Lançamento" 
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   02/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXOrigLcto 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HS7_ORILAN" )
	oModel:SetBK( { "HS7_CODIGO" } )

	oModel:AddField( "HS7_ORILAN" , "C", 32, 0 )
	oModel:AddField( "HS7_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HS7_DESC"   , "C", 15, 0 )		
	
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
@since   02/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXOrigLcto
	Local aOrigem 	:= {}
	Local nOrigem	:= 1  
	
	aAdd( aOrigem, {"LF", STR0001} ) //"Livro Fiscal"			    
	aAdd( aOrigem, {"VD", STR0002} ) //"Venda Direta"
	aAdd( aOrigem, {"LO", STR0003} ) //"Loja"
			
	For nOrigem := 1 To Len( aOrigem )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		oRecord:SetValue( "HS7_ORILAN" , oKey:GetKey( { aOrigem[nOrigem][1] }, , .F. ) )		
		oRecord:SetValue( "HS7_CODIGO" , aOrigem[nOrigem][1] )
		oRecord:SetValue( "HS7_DESC"   , aOrigem[nOrigem][2] )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next nTipo 	

 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
return nIL