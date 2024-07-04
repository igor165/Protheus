#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXUNORGANIZACIONAL.CH"

REGISTER EXTRACTOR HQ8

//--------------------------------------------------------------------
/*/{Protheus.doc} BIXUnOrganizacional
Visualiza as informações por Unidade Organizacional. 
Este conceito trata a forma de organizar um grupo empresarial, que 
pode ser feito, por exemplo, por divisão, grupo, empresa, estabelecimento.

@author  BI TEAM
@since   22/07/2010
/*/
//-------------------------------------------------------------------
Class BIXUnOrganizacional from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Helio Leal
@since   10/04/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXUnOrganizacional
	_Super:New( DIMENSION, "HQ8", STR0001 )	//"Unidade Organizacional"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   10/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXUnOrganizacional 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HQ8_UNIORG" )
	oModel:SetBK( { "HQ8_CODIGO" } )

	oModel:AddField("HQ8_UNIORG" , "C",  32, 0 )
	oModel:AddField("HQ8_CODIGO" , "C",  10, 0 )
	oModel:AddField("HQ8_DESC" 	 , "C",  40, 0 )

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

@author  Helio Leal
@since   10/04/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXUnOrganizacional
 	Local cCompany		:= ""

	cCompany  := FWGrpCompany( )
	
	If ! ( Empty( cCompany ) )	
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 	
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------			
		oRecord:SetValue( "HQ8_UNIORG"	, oKey:GetKey( { cCompany }, .T., .F., .F. ) )
		oRecord:SetValue( "HQ8_CODIGO"	, cCompany )
		oRecord:SetValue( "HQ8_DESC"	, FWGrpName( ) )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------			
		oOutput:Send( oRecord ) 
		
	 	//-------------------------------------------------------------------
		// Libera o pool de gravação. 
		//-------------------------------------------------------------------		
	 	oOutput:Release() 
 	EndIf
Return Nil