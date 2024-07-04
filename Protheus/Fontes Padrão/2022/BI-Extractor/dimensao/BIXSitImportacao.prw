#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSITIMPORTACAO.CH"

REGISTER EXTRACTOR HQM

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSitImportacao
Visualiza as informações pela situação do processo de importação. 
Exemplo: Embarcado Parcial, Não Embarcado, Encerrado.

@author  BI TEAM
@since   17/11/2010
/*/
//-------------------------------------------------------------------
Class BIXSitImportacao from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Tamara Clemente
@since   05/12/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXSitImportacao
	_Super:New( DIMENSION, "HQM", STR0007) //"Situação de Importação"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXSitImportacao
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HQM_SITIMP" )
	oModel:SetBK( { "HQM_CODIGO" } )

	oModel:AddField( "HQM_SITIMP" , "C", 32, 0 )
	oModel:AddField( "HQM_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HQM_DESC"   , "C", 40, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXSitImportacao
	Local nInd := 0
	Local aSituacao := {	{ "01" , STR0001 } ,; // "AGUARDANDO EMBARQUE"
						   	{ "02" , STR0002 } ,; // "AGUARDANDO ATRACAÇÃO"
						 	{ "03" , STR0003 } ,; // "AGUARDANDO DESEMBARAÇO"
						 	{ "04" , STR0004 } ,; // "AGUARDANDO ENTREGA"
						 	{ "05" , STR0005 } ,; // "ENTREGUE"
						 	{ "06" , STR0006 } }  // "ENCERRADO"       
						 	       
	for nInd := 1 to len( aSituacao )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HQM_SITIMP", oKey:GetKey( { aSituacao[nInd][1] },,.F.) )		
		oRecord:SetValue( "HQM_CODIGO", aSituacao[nInd][1] )
		oRecord:SetValue( "HQM_DESC"  , aSituacao[nInd][2] )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next
	
 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil