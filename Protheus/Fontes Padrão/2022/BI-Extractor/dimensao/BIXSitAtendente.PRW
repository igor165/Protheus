#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSITATENDENTE.CH" 

REGISTER EXTRACTOR HOM

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSitAtendente
Visualiza as informações pelo código e descrição da situação do atendente.
Situação do atendente é a classificação do atendente quanto a sua agenda.
Exemplo: Alocado, Ocioso, etc.

@author  Valdiney V GOMES
@since   27/03/2014
/*/
//-------------------------------------------------------------------
Class BIXSitAtendente from BIXEntity
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
Method New() class BIXSitAtendente
	_Super:New( DIMENSION, "HOM", STR0004 ) //"Situação do Atendente"
Return Self   
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXSitAtendente 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HOM_SITATE" )
	oModel:SetBK( { "HOM_CODIGO" } )

	oModel:AddField( "HOM_SITATE" , "C", 32, 0 )
	oModel:AddField( "HOM_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HOM_DESC"   , "C", 15, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXSitAtendente
	Local aSituacao 	:= {} 
	Local nSituacao		:= 1 
	
	aAdd( aSituacao, {"01", STR0001 } ) //"Alocado"  
	aAdd( aSituacao, {"02", STR0002 } ) //"Ocioso"
	aAdd( aSituacao, {"03", STR0003 } ) //"Folga"

	For nSituacao := 1 To Len( aSituacao )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HOM_SITATE", oKey:GetKey( { aSituacao[nSituacao][1] },,.F.) )		
		oRecord:SetValue( "HOM_CODIGO", aSituacao[nSituacao][1] )
		oRecord:SetValue( "HOM_DESC"  , aSituacao[nSituacao][2] )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next nTipo 	
 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil