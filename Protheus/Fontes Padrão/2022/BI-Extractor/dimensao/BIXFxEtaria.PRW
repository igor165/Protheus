#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFXETARIA.CH"

REGISTER EXTRACTOR HK8

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXFxEtaria
Visualiza as informações por Faixas Etária dos colaboradores. 
Os colaboradores serão enquadrados dentro de uma determinada faixa 
conforme sua idade no momento da atualização das informações.

@author  BI TEAM
@since   16/12/2010
/*/
//-------------------------------------------------------------------
Class BIXFxEtaria from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Valdiney V GOMES
@since   05/12/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXFxEtaria
	_Super:New( DIMENSION, "HK8", STR0003)  //"Faixa Etária"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXFxEtaria 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HK8_FXAETA" )
	oModel:SetBK( { "HK8_CODIGO" } )

	oModel:AddField( "HK8_FXAETA", "C", 32, 0 )
	oModel:AddField( "HK8_CODIGO", "C", 10, 0 )
	oModel:AddField( "HK8_DESC"  , "C", 30, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXFxEtaria
	Local aRange 			:= {} 	
	Local cRange			:= BIXParInfo( "FXAETA", "C", "" ) 	
	Local cLabel 			:= ""
	Local nRange			:= 0

	//-------------------------------------------------------------------
	// Recupera as faixas dos parâmetros.  
	//-------------------------------------------------------------------
	aRange := aBIToken( cRange, ";", .F. )

	//-------------------------------------------------------------------
	// Percorre as faixa de dados.
	//-------------------------------------------------------------------
	For nRange := 1 To Len( aRange ) 
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Monta a descrição.  
		//-------------------------------------------------------------------			
		If ! ( nRange == Len( aRange ) ) 
			cLabel :=  aRange[nRange] + " " + STR0002 + " " + aRange[nRange + 1] //"Maior que"	
		Else
			cLabel :=  STR0001 + " " + aRange[nRange] //"até"
		EndIf 

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HK8_FXAETA", oKey:GetKey( { cBIStr( nRange ) } ) )		
		oRecord:SetValue( "HK8_CODIGO", cBIStr( nRange ) )
		oRecord:SetValue( "HK8_DESC"  , cLabel )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next nRange

 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil