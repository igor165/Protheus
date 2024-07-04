#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSITUACOLABORADOR.CH"

REGISTER EXTRACTOR HKA

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSituaColaborador
As informações são visualizadas por código ou descrição da Situação do 
colaborador junto a empresa. As situações são: Situação Trabalhando, 
Saída por Transferência, Férias, Rescisão, Afastado.

@author  BI TEAM
@since   11/08/2010
/*/
//-------------------------------------------------------------------
Class BIXSituaColaborador from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Valdiney V GOMES
@since   11/08/2010
/*/
//-------------------------------------------------------------------  
Method New() class BIXSituaColaborador
	_Super:New( DIMENSION, "HKA", STR0001, "SX5" ) //"Situação do Colaborador"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXSituaColaborador
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HKA_SITCLB" )
	oModel:SetBK( { "HKA_CODIGO" } )

	oModel:AddField( "HKA_SITCLB" , "C", 32, 0 )
	oModel:AddField( "HKA_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HKA_DESC"   , "C", 50, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXSituaColaborador
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "31" )

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
		oRecord:SetValue( "HKA_SITCLB",  oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HKA_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HKA_DESC"  , aContent[nI][4] )
		
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
