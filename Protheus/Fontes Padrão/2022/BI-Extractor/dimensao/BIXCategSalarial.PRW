#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCATEGSALARIAL.CH"

REGISTER EXTRACTOR HJT

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCategSalarial
Visualiza as informa��es por c�digo ou descri��o da Categoria Salarial 
dos colaboradores. Categoria Salarial � a forma como s�o calculados os 
vencimentos dos funcion�rios cadastrados no sistema. 
Exemplo: Mensalista, Semanalista, Horista, Tarefista.

@author  BI TEAM
@since   12/08/2010
/*/
//-------------------------------------------------------------------
Class BIXCategSalarial from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCategSalarial
Construtor do extrator para a dimens�o Categoria Salarial do Projeto Extrator TOTVS B.I.

@author  BI TEAM
@since   12/08/2010
/*/
//-------------------------------------------------------------------
method New() class BIXCategSalarial
	_Super:New( DIMENSION, "HJT", STR0001, "SX5" ) //"Categoria Salarial"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXCategSalarial 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJT_CATSAL" )
	oModel:SetBK( { "HJT_CODIGO" } )

	oModel:AddField( "HJT_CATSAL", "C", 32, 0 )
	oModel:AddField( "HJT_CODIGO", "C", 10, 0 )
	oModel:AddField( "HJT_DESC"  , "C", 50, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXCategSalarial
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "28" )

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
		oRecord:SetValue( "HJT_CATSAL", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HJT_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HJT_DESC"  , aContent[nI][4] )
		
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