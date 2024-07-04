#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCATEGSALARIAL.CH"

REGISTER EXTRACTOR HJT

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCategSalarial
Visualiza as informações por código ou descrição da Categoria Salarial 
dos colaboradores. Categoria Salarial é a forma como são calculados os 
vencimentos dos funcionários cadastrados no sistema. 
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
Construtor do extrator para a dimensão Categoria Salarial do Projeto Extrator TOTVS B.I.

@author  BI TEAM
@since   12/08/2010
/*/
//-------------------------------------------------------------------
method New() class BIXCategSalarial
	_Super:New( DIMENSION, "HJT", STR0001, "SX5" ) //"Categoria Salarial"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
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
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "X5_CHAVE", 	aContent[nI][3] ) 
		oRecord:SetValue( "X5_TABELA", 	aContent[nI][2] ) 
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJT_CATSAL", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HJT_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HJT_DESC"  , aContent[nI][4] )
		
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