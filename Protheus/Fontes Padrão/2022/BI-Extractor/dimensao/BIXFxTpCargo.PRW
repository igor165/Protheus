#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFXETARIA.CH"

REGISTER EXTRACTOR HKI

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXFxTpCargo
Visualiza as informações por Faixas de Tempo de Cargo dos colaboradores. 
Os colaboradores estão enquadrados dentro de uma determinada faixa 
conforme seu tempo no cargo (em anos) no momento da atualização das 
informações.

@author  BI TEAM
@since   16/12/2010
/*/
//-------------------------------------------------------------------
Class BIXFxTpCargo from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Valdiney V GOMES
@since   04/01/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXFxTpCargo
	_Super:New( DIMENSION, "HKI", STR0003) //"Faixa Tempo de Cargo"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXFxTpCargo 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HKI_TPCARG" )
	oModel:SetBK( { "HKI_CODIGO" } )

	oModel:AddField( "HKI_TPCARG", "C", 32, 0 )
	oModel:AddField( "HKI_CODIGO", "C", 16, 0 )
	oModel:AddField( "HKI_DESC"  , "C", 60, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXFxTpCargo
	Local aRange 			:= {} 	
	Local cRange			:= BIXParInfo( "TPCARG", "C", "" ) 	
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
		oRecord:SetValue( "HKI_TPCARG", oKey:GetKey( { cBIStr( nRange ) } ) )		
		oRecord:SetValue( "HKI_CODIGO", cBIStr( nRange ) )
		oRecord:SetValue( "HKI_DESC"  , cLabel )

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