#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXUNIDADENEGOCIO.CH"

REGISTER EXTRACTOR HJ1

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXNatOperacao
Visualiza as informa��es por c�digo ou nome da Unidade de Neg�cio. 
Unidades de Neg�cio s�o divis�es que identificam as atividades 
desenvolvidas pelos estabelecimentos ou filiais de um grupo empresarial.

@author  Helio Leal
@since   21/02/2017
/*/
//-------------------------------------------------------------------
Class BIXUnidadeNegocio from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
	Method UnitBusiness()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@author  Helio Leal
@since   21/02/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXUnidadeNegocio
	_Super:New( DIMENSION, "HJ1", STR0001 ) //"Unidade de Neg�cio"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   21/02/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXUnidadeNegocio 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJ1_UNDNEG" )
	oModel:SetBK( { "HJ1_CDEMPR", "HJ1_CDUNEG" } )

	oModel:AddField( "HJ1_UNDNEG" , "C", 32, 0 )
	oModel:AddField( "HJ1_CODIGO" , "C", 10, 0 )
	oModel:AddField( "HJ1_NOME"   , "C", 40, 0 )

	oModel:FreeField() 
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} UnitBusiness
Define a regra da unidade de neg�cio para a entidade. 

@Return cUnitBusiness, Unidade de neg�cio da entidade.  

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method UnitBusiness() class BIXUnidadeNegocio 
Return FWUnitBusiness()

//-------------------------------------------------------------------
/*/{Protheus.doc} Run
Extra��o dos dados para entidade. 
 
@param cFrom, caracter, Data inicial de extra��o. 
@param cTo, caracter, Data final de extra��o.
@param dToday, data, Data de inicio do processo de extra��o.  
@param oOutput, objeto, Objeto para grava��o dos dados.
@param oRecord, objeto, Objeto para extra��o dos dados.
@param oKey, objeto, Objeto para gera��o da surrogate key.

@author  Helio Leal
@since   21/02/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXUnidadeNegocio
	Local cUnitBusiness	:= ""
	Local cTitle		:= ""
	Local lUseFilOrig   := SuperGetMV("MV_BIXFORI", .F., .F.)
	Local aAllFil		:= {}
	Local aUnitAux	    := {}
	Local nAllFil		:= 0
	Local cUnitDesc	    := ""
	
	If !lUseFilOrig
		If ! ( Empty( FWUnitBusiness( ) ) )
			If ! ( Empty( FWCompany( ) ) )
				cUnitBusiness += FWCompany( ) + "|"
				
				If !( Empty(FWCompanyName( ) ) )
					cTitle += Trim( FWCompanyName( ) ) + "|"
				EndIf
			EndIf
	
			cUnitBusiness 	+= FWUnitBusiness()
			cTitle			+= FWUnitName()
	
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//-------------------------------------------------------------------   
			oRecord:Init()
	
			//-------------------------------------------------------------------
			// Alimenta os campos de neg�cio. 
			//-------------------------------------------------------------------
			oRecord:SetValue( "HJ1_CDEMPR"	, FWCompany( ) )		
			oRecord:SetValue( "HJ1_UNDNEG"	, oKey:GetKey( { cUnitBusiness },,.F., .F. )  )
			oRecord:SetValue( "HJ1_CODIGO"	, cUnitBusiness  )
			oRecord:SetValue( "HJ1_NOME"	, cTitle )
	
			//-------------------------------------------------------------------
			// Envia o registro para o pool de grava��o da Fluig Smart Data. 
			//-------------------------------------------------------------------	
			oOutput:Send( oRecord )
	
			//-------------------------------------------------------------------
			// Libera o pool de grava��o. 
			//-------------------------------------------------------------------	
			oOutput:Release()
		EndIf
	Else
		aAllFil := FWLoadSM0(.F. , .F.)
		
		For nAllFil := 1 to Len(aAllFil)
			cUnitBusiness := ''
			If aAllFil[nAllFil][SM0_GRPEMP] == cEmpAnt
				If ! ( Empty( aAllFil[nAllFil][SM0_UNIDNEG] ) ) .And. ( Ascan( aUnitAux, {|x| x == aAllFil[nAllFil][SM0_EMPRESA]+aAllFil[nAllFil][SM0_UNIDNEG] }) == 0 )
					If ! ( Empty( aAllFil[nAllFil][SM0_EMPRESA] ) )
						cUnitBusiness += aAllFil[nAllFil][SM0_EMPRESA] + "|"
						cUnitDesc	:= FWCompanyName( aAllFil[nAllFil][SM0_GRPEMP], aAllFil[nAllFil][SM0_CODFIL] )
						
						If !( Empty(cUnitDesc ) )
							cTitle += Trim( cUnitDesc ) + "|"
						EndIf
					EndIf
			
					cUnitBusiness += aAllFil[nAllFil][SM0_UNIDNEG]
					cTitle			+= FWUnitName( aAllFil[nAllFil][SM0_GRPEMP], aAllFil[nAllFil][SM0_CODFIL] )
			
					//-------------------------------------------------------------------
					// Inicializa o registro. 
					//-------------------------------------------------------------------   
					oRecord:Init()
			
					//-------------------------------------------------------------------
					// Alimenta os campos de neg�cio. 
					//-------------------------------------------------------------------
					oRecord:SetValue( "HJ1_CDEMPR"	, aAllFil[nAllFil][SM0_EMPRESA] )
					oRecord:SetValue( "HJ1_CDUNEG"	, aAllFil[nAllFil][SM0_UNIDNEG] )			
					oRecord:SetValue( "HJ1_UNDNEG"	, oKey:GetKey( { cUnitBusiness },,.F., .F. )  )
					oRecord:SetValue( "HJ1_CODIGO"	, cUnitBusiness  )
					oRecord:SetValue( "HJ1_NOME"	, cTitle )
			
					//-------------------------------------------------------------------
					// Envia o registro para o pool de grava��o da Fluig Smart Data. 
					//-------------------------------------------------------------------	
					oOutput:Send( oRecord )
					
					Aadd(aUnitAux, aAllFil[nAllFil][SM0_EMPRESA]+aAllFil[nAllFil][SM0_UNIDNEG])
				EndIf
			EndIf
		Next	
		//-------------------------------------------------------------------
		// Libera o pool de grava��o. 
		//-------------------------------------------------------------------	
		oOutput:Release()
	EndIf 	
Return nil