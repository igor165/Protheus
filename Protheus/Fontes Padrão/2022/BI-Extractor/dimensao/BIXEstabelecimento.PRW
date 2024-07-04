#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXESTABELECIMENTO.CH"

REGISTER EXTRACTOR HKK

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXEstabelecimento
Visualiza as informações por código ou nome do Estabelecimento ou 
Filial da Empresa.

@author  BI TEAM
@since   02/08/2010
/*/
//-------------------------------------------------------------------
Class BIXEstabelecimento from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
	Method Filial( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author Helio Leal
@since  08/11/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXEstabelecimento
	_Super:New( DIMENSION, "HKK", STR0001 ) //"Estabelecimento"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author Valdiney V GOMES
@since  20/02/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXEstabelecimento 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HKK_ESTABL" )
	oModel:SetBK( { "HKK_CDEMPR", "HKK_CDUNEG", "HKK_FILIAL" } )

	oModel:AddField( "HKK_ESTABL" , "C", 32 , 0 )
	oModel:AddField( "HKK_CODIGO" , "C", 12 , 0 )
	oModel:AddField( "HKK_NOME"   , "C", 100, 0 ) 
	
	oModel:FreeField() 
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} Filial
Define a filial da entidade.  
           
@Return cFilial, Filial da entidade. 

@author Valdiney V GOMES
@since  20/02/2017
/*/
//-------------------------------------------------------------------
Method Filial() class BIXEstabelecimento 
	Local _cFilial := cFilAnt
Return _cFilial

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
method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXEstabelecimento
	Local cKey			:= ""
	Local cTemp			:= ""
	Local cDML			:= ""
	Local cGroup		:= ""
	Local cCompany		:= ""
	Local cUnitBusiness	:= ""
	Local cBranch		:= ""
	Local lUnique		:= .T. 
	Local lUseFilOrig   := SuperGetMV("MV_BIXFORI", .F., .F.)
	Local aAllFil		:= {}
	Local nAllFil		:= 0
	

 	cGroup := FWGrpCompany( )

	If ! ( Empty( FWSM0Layout(, 1) ) ) .Or. ! ( Empty( FWSM0Layout(, 2) ) )
		If ! ( Empty( FWCompany( ) ) )
			cBranch 	+= FWCompany( ) + "|"
			cCompany 	+= FWCompany( )  
		EndIf

		If ! ( Empty( FWUnitBusiness( ) ) )
			cBranch		 	+= FWUnitBusiness( ) + "|"
			cUnitBusiness 	+= FWCompany( ) + "|" + FWUnitBusiness() 
		EndIf
	EndIf

	cBranch += FWFilial()

	//-------------------------------------------------------------------
	// Grava o Grupo de empresa.
	//-------------------------------------------------------------------
	If ! ( Empty( cGroup ) )
		cKey 	:= oKey:GetKey( { cGroup + "|__" }, .F., .F., .F. )
		cDML 	:= "SELECT COUNT( HKK_ESTABL ) TOTAL FROM HKK WHERE HKK_ESTABL = '" + cKey + "'"
		lUnique	:= .T.
		
		If ! ( Empty( BIXLinkFSD( ) ) )	
			DBUseArea( .T., "TOPCONN", TCGenQry( ,,cDML ), cTemp := GetNextAlias(), .F., .T. ) 	
			
			//-------------------------------------------------------------------
			// Identifica se o grupo foi inserido na dimensão.
			//-------------------------------------------------------------------		
			lUnique := Empty( nBIVal( (cTemp)->TOTAL ) )
			
			(cTemp)->( DBCloseArea( ) )
			BIXUnlinkFSD( )
		EndIf
		
		//-------------------------------------------------------------------
		// Impede a duplicidade de grupo de empresas na dimensão.
		//-------------------------------------------------------------------			
		If ( lUnique )
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 	
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Alimenta os campos de negócio. 
			//-------------------------------------------------------------------				
			oRecord:SetValue( "HKK_FILIAL"	, "__" )	
			oRecord:SetValue( "HKK_CDUNEG"	, "" )
			oRecord:SetValue( "HKK_CDEMPR"	, "" )	
			oRecord:SetValue( "HKK_ESTABL"	, cKey )
			oRecord:SetValue( "HKK_CODIGO"	, cGroup )
			oRecord:SetValue( "HKK_NOME"	, AllTrim( FWGrpName( ) )  + " (" + STR0002 + ")" ) //"Compartilhado"
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação da Fluig Smart Data. 
			//-------------------------------------------------------------------					
			oOutput:Send( oRecord ) 
		EndIf
	EndIf
	
	//-------------------------------------------------------------------
	// Grava a Empresa.
	//-------------------------------------------------------------------
	If ! ( Empty( cCompany ) )
		cKey 	:= oKey:GetKey( { cCompany + "|__" },.T., .F., .F. )
		cDML 	:= "SELECT COUNT( HKK_ESTABL ) TOTAL FROM HKK WHERE HKK_ESTABL = '" + cKey + "'"
		lUnique	:= .T.
				
		If ! ( Empty( BIXLinkFSD( ) ) )	
			DBUseArea( .T., "TOPCONN", TCGenQry( ,,cDML ), cTemp := GetNextAlias(), .F., .T. ) 	
			
			//-------------------------------------------------------------------
			// Identifica se o grupo foi inserido na dimensão.
			//-------------------------------------------------------------------		
			lUnique := Empty( nBIVal( (cTemp)->TOTAL ) )
			
			(cTemp)->( DBCloseArea( ) )
			BIXUnlinkFSD( )
		EndIf
		
		//-------------------------------------------------------------------
		// Impede a duplicidade de grupo de empresas na dimensão.
		//-------------------------------------------------------------------			
		If ( lUnique )	
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Alimenta os campos de negócio. 
			//-------------------------------------------------------------------		
			oRecord:SetValue( "HKK_FILIAL"	, "__" )	
			oRecord:SetValue( "HKK_CDUNEG"	, "" )
			oRecord:SetValue( "HKK_CDEMPR"	, FWCompany( ) )	
			oRecord:SetValue( "HKK_ESTABL"	, cKey )
			oRecord:SetValue( "HKK_CODIGO"	, cCompany )
			oRecord:SetValue( "HKK_NOME"	, AllTrim( FWCompanyName( ) )  + " (" + STR0002 + ")" ) //"Compartilhado"
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação da Fluig Smart Data. 
			//-------------------------------------------------------------------					
			oOutput:Send( oRecord ) 
		EndIf	
	EndIf

	//-------------------------------------------------------------------
	// Grava a Unidade de negócio.
	//-------------------------------------------------------------------	
	If ! ( Empty( cUnitBusiness ) )
		cKey 	:= oKey:GetKey( { cUnitBusiness + "|__" },.T., .F., .F. )
		cDML 	:= "SELECT COUNT( HKK_ESTABL ) TOTAL FROM HKK WHERE HKK_ESTABL = '" + cKey + "'"
		lUnique	:= .T.
				
		If ! ( Empty( BIXLinkFSD( ) ) )	
			DBUseArea( .T., "TOPCONN", TCGenQry( ,,cDML ), cTemp := GetNextAlias(), .F., .T. ) 	
			
			//-------------------------------------------------------------------
			// Identifica se o grupo foi inserido na dimensão.
			//-------------------------------------------------------------------		
			lUnique := Empty( nBIVal( (cTemp)->TOTAL ) )
			
			(cTemp)->( DBCloseArea( ) )
			BIXUnlinkFSD( )
		EndIf
		
		//-------------------------------------------------------------------
		// Impede a duplicidade de grupo de empresas na dimensão.
		//-------------------------------------------------------------------			
		If ( lUnique )	
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Alimenta os campos de negócio. 
			//-------------------------------------------------------------------			
			oRecord:SetValue( "HKK_FILIAL"	, "__" )
			oRecord:SetValue( "HKK_CDUNEG"	, FWUnitBusiness( ) )
			oRecord:SetValue( "HKK_CDEMPR"	, FWCompany( ) )
			oRecord:SetValue( "HKK_ESTABL"	, cKey )
			oRecord:SetValue( "HKK_CODIGO"	, cUnitBusiness )
			oRecord:SetValue( "HKK_NOME"	, AllTrim( FWUnitName( ) ) + " (" + STR0002 + ")" ) //"Compartilhado"
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação da Fluig Smart Data. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		EndIf
	EndIf
	
	//-------------------------------------------------------------------
	// Grava o Filial.
	//-------------------------------------------------------------------
	If !lUseFilOrig
		If ! ( Empty( cBranch ) )
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Alimenta os campos de negócio. 
			//-------------------------------------------------------------------		
			oRecord:SetValue( "HKK_FILIAL"	, ::Filial( ) )
			oRecord:SetValue( "HKK_CDUNEG"	, FWUnitBusiness( ) )
			oRecord:SetValue( "HKK_CDEMPR"	, FWCompany( ) )	
			oRecord:SetValue( "HKK_ESTABL"	, oKey:GetKey( { cBranch },.T., .F., .F. ) )
			oRecord:SetValue( "HKK_CODIGO"	, cBranch )
			oRecord:SetValue( "HKK_NOME"	, FWFilialName() )
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação da Fluig Smart Data. 
			//-------------------------------------------------------------------			
			oOutput:Send( oRecord ) 
		EndIf
	Else
		aAllFil := FWLoadSM0(.F. , .F.)
	
		For nAllFil := 1 to Len(aAllFil)
			cBranch := ''
			If aAllFil[nAllFil][SM0_GRPEMP] == cEmpAnt
				If !Empty(aAllFil[nAllFil][SM0_EMPRESA])
					cBranch := aAllFil[nAllFil][SM0_EMPRESA]+'|'
				EndIf
				
				If !Empty(aAllFil[nAllFil][SM0_UNIDNEG])
					cBranch += aAllFil[nAllFil][SM0_UNIDNEG]+'|'
				EndIf
					
				cBranch += aAllFil[nAllFil][SM0_FILIAL]
				
				//-------------------------------------------------------------------
				// Inicializa o registro. 
				//------------------------------------------------------------------- 
				oRecord:Init()
				
				//-------------------------------------------------------------------
				// Alimenta os campos de negócio. 
				//-------------------------------------------------------------------		
				oRecord:SetValue( "HKK_FILIAL"	, aAllFil[nAllFil][SM0_CODFIL]  )
				oRecord:SetValue( "HKK_CDUNEG"	, aAllFil[nAllFil][SM0_UNIDNEG]  )
				oRecord:SetValue( "HKK_CDEMPR"	, aAllFil[nAllFil][SM0_EMPRESA]  )	
				oRecord:SetValue( "HKK_ESTABL"	, oKey:GetKey( { cBranch  },.T., .F., .F. ) )
				oRecord:SetValue( "HKK_CODIGO"	, cBranch )
				oRecord:SetValue( "HKK_NOME"	, aAllFil[nAllFil][SM0_NOMRED] )
				
				//-------------------------------------------------------------------
				// Envia o registro para o pool de gravação da Fluig Smart Data. 
				//-------------------------------------------------------------------			
				oOutput:Send( oRecord ) 
			EndIf
		Next
	EndIf	
	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------		
 	oOutput:Release()	
Return nil