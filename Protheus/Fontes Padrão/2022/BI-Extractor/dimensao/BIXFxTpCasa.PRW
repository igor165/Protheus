#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFXTPCASA.CH"

REGISTER EXTRACTOR HKH

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXFxTpCasa
Visualiza as informa��es por Tempo de Casa dos colaboradores. 
Os colaboradores est�o enquadrados dentro de uma determinada faixa 
conforme seu tempo na empresa (em anos) no momento da atualiza��o das 
informa��es.

@author  BI TEAM
@since   16/12/2010
/*/
//-------------------------------------------------------------------
Class BIXFxTpCasa from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
M�todo construtor.  

@author  Valdiney V GOMES
@since   16/12/2010
/*/
//-------------------------------------------------------------------  
Method New() class BIXFxTpCasa
	_Super:New( DIMENSION, "HKH", STR0003 ) //"Faixa Tempo de Casa"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXFxTpCasa 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HKH_TPCASA" )
	oModel:SetBK( { "HKH_CODIGO" } )

	oModel:AddField( "HKH_TPCASA", "C", 32, 0 )
	oModel:AddField( "HKH_CODIGO", "C", 16, 0 )
	oModel:AddField( "HKH_DESC"  , "C", 60, 0 )
	
	oModel:FreeField() 
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} Run
Extra��o dos dados para entidade. 
 
@param cFrom, caracter, Data inicial de extra��o. 
@param cTo, caracter, Data final de extra��o.
@param dToday, data, Data de inicio do processo de extra��o.  
@param oOutput, objeto, Objeto para grava��o dos dados.
@param oRecord, objeto, Objeto para extra��o dos dados.
@param oKey, objeto, Objeto para gera��o da surrogate key.

@author  Marcia Junko
@since   01/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXFxTpCasa
	Local aRange 			:= {} 	
	Local cRange			:= BIXParInfo( "TPCASA", "C", "" ) 	
	Local cLabel 			:= ""
	Local nRange			:= 0

	//-------------------------------------------------------------------
	// Recupera as faixas dos par�metros.  
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
		// Monta a descri��o.  
		//-------------------------------------------------------------------			
		If ! ( nRange == Len( aRange ) ) 
			cLabel :=  aRange[nRange] + " " + STR0002 + " " + aRange[nRange + 1] //"Maior que"	
		Else
			cLabel :=  STR0001 + " " + aRange[nRange] //"at�"
		EndIf 

		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HKH_TPCASA", oKey:GetKey( { cBIStr( nRange ) } ) )		
		oRecord:SetValue( "HKH_CODIGO", cBIStr( nRange ) )
		oRecord:SetValue( "HKH_DESC"  , cLabel )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next nRange

 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil