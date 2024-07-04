#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPROBABILIDADE.CH"

REGISTER EXTRACTOR HSH

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXProbabilidade
Representação do extrator.

@author  Valdiney V GOMES
@version P12 
@since   23/04/2014
/*/
//-------------------------------------------------------------------
Class BIXProbabilidade from BIXEntity
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
Method New() class BIXProbabilidade
	_Super:New( DIMENSION, "HSH", STR0001 ) //"Probabilidade"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   02/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXProbabilidade 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HSH_PROBAB" )
	oModel:SetBK( { "HSH_CODIGO" } )

	oModel:AddField( "HSH_PROBAB" , "C", 32, 0 )
	oModel:AddField( "HSH_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HSH_DESC"   , "C", 40, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXProbabilidade
	Local aProbabilidade  	:= {} 
	Local nProbabilidade   	:= 1	       

	SX3->( DBSetOrder( 2 ) )        
	
	If ( SX3->( DBSeek( "AD1_FEELIN" ) ) )  
		aProbabilidade  := aBIToken( X3CBox(), ";" )
	EndIf

	For nProbabilidade  := 1 To Len( aProbabilidade  )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HSH_PROBAB" , oKey:GetKey( { aBIToken( aProbabilidade[nProbabilidade], "=", .F. )[1] },,.F.) )		
		oRecord:SetValue( "HSH_CODIGO" , aBIToken( aProbabilidade[nProbabilidade], "=", .F. )[1] )
		oRecord:SetValue( "HSH_DESC" , aBIToken( aProbabilidade[nProbabilidade], "=", .F. )[2] )

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