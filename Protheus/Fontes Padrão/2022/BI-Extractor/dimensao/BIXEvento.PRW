#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXEVENTO.CH"

REGISTER EXTRACTOR HJR 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXEvento
Visualiza as informações por código ou descrição do evento da folha 
de pagamento. Evento representa as ocorrências da folha de pagamento 
do colaborador, as variáveis que envolvem todos os cálculos 
(proventos e descontos) correspondentes aos funcionários e suas 
incidências legais (INSS, FGTS, Imposto de Renda).

@author  BI TEAM
@since   10/08/2010
/*/
//-------------------------------------------------------------------
Class BIXEvento from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )  
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Valdiney V GOMES
@since   10/08/2010
/*/
//-------------------------------------------------------------------  
Method New() class BIXEvento
	_Super:New( DIMENSION, "HJR", STR0001, "SRV" ) //"Evento"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXEvento 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJR_EVENTO" )
	oModel:SetBK( { "HJR_CODIGO" } )

	oModel:AddField( "HJR_EVENTO" , "C", 32, 0 )
	oModel:AddField( "HJR_CODIGO" , "C", 40, 0 )		
	oModel:AddField( "HJR_DESC"   , "C", 80, 0 )		
	oModel:AddField( "HJR_INCIDE" , "C", 60, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXEvento
 	Local cFlow := ""
		
	cFlow := ::Flow( cFrom, cTo, { "RV_COD", "RV_DESC"} )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "RV_COD", 	(cFlow)->RV_COD )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJR_EVENTO" ,  oKey:GetKey( { (cFlow)->RV_COD } ) )		
		oRecord:SetValue( "HJR_CODIGO" , (cFlow)->RV_COD  )
		oRecord:SetValue( "HJR_DESC"   , (cFlow)->RV_DESC )
		oRecord:SetValue( "HJR_INCIDE" , ' ' )
		
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