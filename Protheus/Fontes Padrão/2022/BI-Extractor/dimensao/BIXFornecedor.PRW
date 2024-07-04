#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFORNECEDOR.CH"

REGISTER EXTRACTOR HKJ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXFornecedor
As informações são visualizadas por código ou nome do Fornecedor. 

@author  BI TEAM
@since   14/06/2010
/*/
//-------------------------------------------------------------------
Class BIXFornecedor from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Helio leal
@since   08/11/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXFornecedor
	_Super:New( DIMENSION, "HKJ", STR0002, "SA2" ) //"Fornecedor"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Tamara Clemente
@since   03/03/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXFornecedor 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HKJ_FORNEC" )
	oModel:SetBK( { "HKJ_CODIGO", "HKJ_LOJA" } )

	oModel:AddUnifier( { "A2_COD" }, STR0003 ) //"Código do Fornecedor"
	oModel:AddUnifier( { "A2_CGC" }, STR0004 ) //"CPF do Fornecedor"

	oModel:AddField( "HKJ_FORNEC" , "C", 32, 0 )
	oModel:AddField( "HKJ_CODIGO" , "C", 25, 0 )
	oModel:AddField( "HKJ_LOJA"   , "C", 02, 0 )
	oModel:AddField( "HKJ_FORNMT" , "C", 25, 0 )
	oModel:AddField( "HKJ_NOME"   , "C", 60, 0 )
	oModel:AddField( "HKJ_MATRIZ" , "C", 60, 0 )
	oModel:AddField( "HKJ_RAMO"   , "C", 30, 0 )
	oModel:AddField( "HKJ_MATFOR" , "C", 32, 0, .T. )
	oModel:AddField( "HKJ_CREJUR" , "C", 01, 0 )
	
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
@since   22/07/2010
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXFornecedor
 	Local cFlow := ""
    	
	cFlow := ::Flow( cFrom, cTo, { "A2_COD", "A2_LOJA", "A2_CGC", "A2_NOME", "A2_ATIVIDA", "A2_MJURIDI" } )

 	While ! (cFlow)->( Eof() )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 		
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de customização. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "A2_COD"		, (cFlow)->A2_COD )
		oRecord:SetValue( "A2_LOJA"		, (cFlow)->A2_LOJA )
		oRecord:SetValue( "A2_CGC"		, (cFlow)->A2_CGC )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HKJ_FORNEC"	, oKey:GetKey( { (cFlow)->A2_COD, (cFlow)->A2_LOJA } ) )
		oRecord:SetValue( "HKJ_CODIGO"	, (cFlow)->A2_COD )
		oRecord:SetValue( "HKJ_LOJA"	, (cFlow)->A2_LOJA )
		oRecord:SetValue( "HKJ_NOME"	, (cFlow)->A2_NOME )
		oRecord:SetValue( "HKJ_RAMO"	, (cFlow)->A2_ATIVIDA )
		oRecord:SetValue( "HKJ_MATFOR"	, oKey:GetKey( { UNDEFINED } ) )
		oRecord:SetValue( "HKJ_MATRIZ"	, STR0005 ) //"INDEFINIDO"
		oRecord:SetValue( "HKJ_FORNMT"	, UNDEFINED )

		If (cFlow)->A2_MJURIDI == "1"
			oRecord:SetValue( "HKJ_CREJUR"	, "S" )
		Else
			oRecord:SetValue( "HKJ_CREJUR"	, "N" )
		EndIf
		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------	
		oOutput:Send( oRecord ) 

 		(cFlow)->( DBSkip() ) 
 	EndDo 
 
 	//-------------------------------------------------------------------
	// Inicializa o registro. 
	//------------------------------------------------------------------- 		
	oRecord:Init()
	
	oRecord:SetValue( "A2_COD"		, PadL( FWCompany() + FWFilial() , 6 , "#" ) )
	oRecord:SetValue( "A2_LOJA"		, "00" )
	
	oRecord:SetValue( "HKJ_FORNEC"	, oKey:GetKey( { PadL(FWCompany() + FWFilial() , 6 , "#"), "00" } ) )
	oRecord:SetValue( "HKJ_CODIGO"	, PadL(FWCompany() + FWFilial() , 6 , "#") )
	oRecord:SetValue( "HKJ_LOJA"	, "00" )
	oRecord:SetValue( "HKJ_NOME"	, FWGrpName() + " " + STR0001 )//"(Processo Interno)"
	oRecord:SetValue( "HKJ_RAMO"	, UNDEFINED ) 
	oRecord:SetValue( "HKJ_MATFOR"	, oKey:GetKey( { UNDEFINED } ) )
	oRecord:SetValue( "HKJ_MATRIZ"	, STR0005 ) //"INDEFINIDO"
	oRecord:SetValue( "HKJ_FORNMT"	, UNDEFINED )
	oRecord:SetValue( "HKJ_CREJUR"	, "N" )
 	
	//-------------------------------------------------------------------
	// Envia o registro para o pool de gravação da Fluig Smart Data. 
	//-------------------------------------------------------------------	
	oOutput:Send( oRecord )  
		
	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil