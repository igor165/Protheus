#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXEMPRESA.CH"

REGISTER EXTRACTOR HJ4

//--------------------------------------------------------------------
/*/{Protheus.doc} BIXEmpresa
As informações são visualizadas por código ou nome da empresa.

@author  BI TEAM
@since   22/07/2010
/*/
//-------------------------------------------------------------------
Class BIXEmpresa from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
	Method Company( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Tamara Clemente
@since   04/11/2016
/*/
//-------------------------------------------------------------------  
Method New() Class BIXEmpresa
	_Super:New( DIMENSION, "HJ4", STR0001 )	//"Empresa"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Company  
Define a empresa da entidade. 

@Return cCompany, Empresa da entidade.

@author  Valdiney V GOMES
@since   20/02/2016
/*/
//-------------------------------------------------------------------  
Method Company() Class BIXEmpresa	
Return FWCompany( ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Valdiney V GOMES
@since   20/02/2016
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXEmpresa 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJ4_EMPRES" )
	oModel:SetBK( { "HJ4_CDEMPR" } )

	oModel:AddField("HJ4_EMPRES" , "C",  32, 0 )
	oModel:AddField("HJ4_CODIGO" , "C",  10, 0 )
	oModel:AddField("HJ4_DESCGR" , "C",  60, 0 )
 	oModel:AddField("HJ4_NOME"	 , "C", 100, 0 )
	oModel:AddField("HJ4_FLUIG"  , "C",  50, 0 )

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXEmpresa
 	Local cCompany		:= ""
	Local cTitle 		:= ""
	Local lUseFilOrig   := SuperGetMV("MV_BIXFORI", .F., .F.)
	Local aAllCompany	:= {}
	Local nAllCompany	:= 0
	Local cCompDesc		:= ""

	If lUseFilOrig
		aAllCompany := FWAllCompany()
	EndIf
	
	If Empty(aAllCompany)
		cCompany  := FWGrpCompany( )
		
		If ! ( Empty( cCompany ) )	
			cTitle := Trim( FWGrpName( ) )
		
			If ! ( Empty( FWCompany( ) ) )
				cCompany += "|" + FWCompany( ) 
		
				If ! ( Empty( FWCompanyName( ) ) )
					cTitle += "|" + FWCompanyName( ) 
				EndIf
			EndIf
			
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 	
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Alimenta os campos de negócio. 
			//-------------------------------------------------------------------			
			oRecord:SetValue( "HJ4_EMPRES"	, oKey:GetKey( { cCompany + iif(Empty(FWCompany()), "|", "") }, .T., .F., .F. ) )
			oRecord:SetValue( "HJ4_CODIGO"	, cCompany )
			oRecord:SetValue( "HJ4_DESCGR"	, FWGrpName( ) )
			oRecord:SetValue( "HJ4_NOME"	, cTitle )
			oRecord:SetValue( "HJ4_FLUIG"	, FWGrpFluigID( ) )
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação da Fluig Smart Data. 
			//-------------------------------------------------------------------			
			oOutput:Send( oRecord ) 
			
		 	//-------------------------------------------------------------------
			// Libera o pool de gravação. 
			//-------------------------------------------------------------------		
		 	oOutput:Release() 
	 	EndIf
	Else
		For nAllCompany := 1 to Len(aAllCompany)
			cCompany 	:= FWGrpCompany( ) + "|" + aAllCompany[nAllCompany]
			cCompDesc	:= FWEmpName( aAllCompany[nAllCompany] )
			cTitle		:= Trim( FWGrpName( ) ) + Iif( !Empty(cCompDesc), "|" + cCompDesc , "")
			
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Alimenta os campos de negócio. 
			//-------------------------------------------------------------------		
			oRecord:SetValue( "HJ4_EMPRES"	, oKey:GetKey( { cCompany }, .T., .F., .F. ) )
			oRecord:SetValue( "HJ4_CODIGO"	, cCompany )
			oRecord:SetValue( "HJ4_CDEMPR"	, aAllCompany[nAllCompany] )
			oRecord:SetValue( "HJ4_DESCGR"	, FWGrpName( ) )
			oRecord:SetValue( "HJ4_NOME"	, cTitle )
			
			oRecord:SetValue( "HJ4_FLUIG"	, FWGrpFluigID( ) )
				
				
			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação da Fluig Smart Data. 
			//-------------------------------------------------------------------			
			oOutput:Send( oRecord ) 
		Next

	 	//-------------------------------------------------------------------
		// Libera o pool de gravação. 
		//-------------------------------------------------------------------		
	 	oOutput:Release() 
	EndIf 	
 	
 	
Return nil 