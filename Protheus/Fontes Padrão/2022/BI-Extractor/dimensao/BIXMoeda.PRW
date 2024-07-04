#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXMOEDA.CH"

REGISTER EXTRACTOR HJ6

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXMoeda
As informações são visualizadas por nome ou símbolo da Moeda e dizemos
que moeda é uma unidade financeira utilizada quando se faz necessária 
a conversão de valores.

@author  BI TEAM
@since   23/06/2010
/*/
//-------------------------------------------------------------------
Class BIXMoeda from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Valdiney V GOMES
@since   07/11/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXMoeda
	_Super:New( DIMENSION, "HJ6", STR0001 ) //"Moeda"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Valdiney V GOMES
@since   20/02/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXMoeda 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJ6_MOEDA" )
	oModel:SetBK( { "HJ6_CODIGO" } )

	oModel:AddField( "HJ6_MOEDA"  , "C", 32, 0  )
	oModel:AddField( "HJ6_CODIGO" , "C", 10, 0  )
	oModel:AddField( "HJ6_NOME"   , "C", 40, 0  ) 
	
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

@author  BI TEAM
@since   26/07/2010
/*/
//-------------------------------------------------------------------
method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXMoeda
  	Local aMoeda  		:= {}
  	Local nMoeda  		:= 0
  	Local lConsolidate 	:= BIXParInfo( "BIX_CMOEDA", "L", .F. )  

  	aMoeda  := BIXLoadMoeda()
 	  	
  	For nMoeda := 1 To Len( aMoeda )
 		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   		  
	   	oRecord:Init()
	   	
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
    	If ( lConsolidate )
	    	oRecord:SetValue( "HJ6_MOEDA"	, BIXCMValue( cBIStr( nMoeda ), 1 ) ) 
    	Else
	    	oRecord:SetValue( "HJ6_MOEDA"	, oKey:GetKey( { BIXCMValue( cBIStr( nMoeda ), 1 ) },.T., .F. ) ) 
    	EndIf
    	
    	oRecord:SetValue( "HJ6_CODIGO"	, BIXCMValue( cBIStr( nMoeda ), 1 ) )
	    oRecord:SetValue( "HJ6_NOME"	, BIXCMValue( cBIStr( nMoeda ), 2 ) )
	    
		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------	
		oOutput:Send( oRecord ) 	    	
    Next nMoeda
    
 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------
 	oOutput:Release()
Return nil 