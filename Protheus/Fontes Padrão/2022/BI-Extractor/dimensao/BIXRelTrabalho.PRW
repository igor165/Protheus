#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXRELTRABALHO.CH"

REGISTER EXTRACTOR HKD

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRelTrabalho
As informações são visualizadas por código ou descrição da Relação de 
Trabalho entre empresa e colaborador. Exemplos: Estagiário, Cooperado, 
Funcionário, Sócio, Temporário, Contratado.

@author  BI TEAM
@since   11/08/2010
/*/
//-------------------------------------------------------------------
Class BIXRelTrabalho from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Valdiney V GOMES
@since   04/01/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXRelTrabalho
	_Super:New( DIMENSION, "HKD", STR0001, "SX5" ) //"Relação de Trabalho"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXRelTrabalho 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HKD_RELTRB" )
	oModel:SetBK( { "HKD_CODIGO" } )

	oModel:AddField( "HKD_RELTRB" , "C", 32, 0 )
	oModel:AddField( "HKD_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HKD_DESC"   , "C", 50, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXRelTrabalho
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "38" )

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
		oRecord:SetValue( "HKD_RELTRB", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HKD_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HKD_DESC"  , aContent[nI][4] )
		
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