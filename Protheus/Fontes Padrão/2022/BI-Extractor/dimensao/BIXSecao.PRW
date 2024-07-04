#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSECAO.CH"

REGISTER EXTRACTOR HQ0

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSecao
As informações são visualizadas pelas seções onde os funcionários estão 
alocados, como: Endereço, Filial, Departamento, Dados para INSS, etc. 
Cada funcionário está vinculado a uma seção, exemplo: Funcionários da 
área administrativa estão vinculados a seção Administrativa. Funcionários 
do departamento de Desenvolvimento estão vinculados a seção relativa ao 
Desenvolvimento

@author  BI TEAM
@since   11/08/2010
/*/
//-------------------------------------------------------------------
Class BIXSecao from BIXEntity
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
Method New() class BIXSecao
	_Super:New( DIMENSION, "HQ0", STR0001, "SQB" ) //"Seção"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXSecao 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HQ0_SECAO" )
	oModel:SetBK( { "HQ0_CODIGO" } )

	oModel:AddField( "HQ0_SECAO" , "C", 32, 0 )
	oModel:AddField( "HQ0_CODIGO" , "C", 35, 0 )		
	oModel:AddField( "HQ0_DESC"   , "C", 60, 0 )		
	
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
@since   03/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXSecao
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "QB_DEPTO", "QB_DESCRIC" } )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "QB_DEPTO", 	(cFlow)->QB_DEPTO )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HQ0_SECAO", oKey:GetKey( { (cFlow)->QB_DEPTO } ) )		
		oRecord:SetValue( "HQ0_CODIGO", (cFlow)->QB_DEPTO )
		oRecord:SetValue( "HQ0_DESC"  , (cFlow)->QB_DESCRIC )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 

 		(cFlow)->( DBSkip() ) 
 	EndDo
 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil