#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXBCO.CH"

REGISTER EXTRACTOR HGK

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXBco
Visualiza as informações por Banco. Banco é a instituição financeira 
e não a agência bancária.

@author  BI TEAM
@since   26/07/2010
/*/
//-------------------------------------------------------------------
Class BIXBco from BIXEntity
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
Method New() class BIXBco
	_Super:New( DIMENSION, "HGK", STR0001, "SA6" ) //"Banco"
Return Self  


//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXBco 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HGK_BCO" )
	oModel:SetBK( { "HGK_CODIGO" } )

	oModel:AddUnifier( { "A6_COD + A6_AGENCIA + A6_NUMCON" }, STR0001 ) //"Banco, agência e conta"
	
	
	oModel:AddField( "HGK_BCO" 		, "C", 32, 0 )
	oModel:AddField( "HGK_CODIGO" 	, "C", 8,  0 )
	oModel:AddField( "HGK_DESC"   	, "C", 30, 0 )
	oModel:AddField( "HGK_AGECIA"   , "C", 10, 0 )
	oModel:AddField( "HGK_NUMCON"   , "C", 10, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXBco
 	Local cFlow  := ""

	cFlow := ::Flow( cFrom, cTo, { "A6_COD", "A6_AGENCIA", "A6_NUMCON", "A6_NOME" } )

 	While ! ( (cFlow)->( Eof() ) )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Alimenta os campos para customização. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "A6_COD"		    , (cFlow)->A6_COD )
		oRecord:SetValue( "A6_AGENCIA"		, (cFlow)->A6_AGENCIA )
		oRecord:SetValue( "A6_NUMCON"		, (cFlow)->A6_NUMCON )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------		
		oRecord:SetValue( "HGK_BCO"	, oKey:GetKey( { (cFlow)->A6_COD, A6_AGENCIA, A6_NUMCON } ) )	
		oRecord:SetValue( "HGK_CODIGO"	, (cFlow)->A6_COD )
		oRecord:SetValue( "HGK_DESC"	, (cFlow)->A6_NOME )
		oRecord:SetValue( "HGK_AGECIA"	, (cFlow)->A6_AGENCIA )
		oRecord:SetValue( "HGK_NUMCON"	, (cFlow)->A6_NUMCON )
		
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
