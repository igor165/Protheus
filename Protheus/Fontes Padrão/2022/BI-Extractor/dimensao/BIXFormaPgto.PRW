#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFORMAPGTO.CH"

REGISTER EXTRACTOR HS9

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXFormaPgto
Visualiza as informações por código e descrição da forma de pagamento. 
A forma de pagamento é o meio oferecido ao cliente para que efetue o 
pagamento de suas compras. Exemplo: Cartão de Crédito, Dinheiro, etc.

@author  Valdiney V GOMES
@version P12 
@since   10/04/2014
/*/
//-------------------------------------------------------------------
Class BIXFormaPgto from BIXEntity
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
Method New() class BIXFormaPgto
	_Super:New( DIMENSION, "HS9", STR0010) // "Forma de Pagamento" 
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXFormaPgto 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HS9_FORPAG" )
	oModel:SetBK( { "HS9_CODIGO" } )

	oModel:AddField( "HS9_FORPAG", "C", 32, 0 )
	oModel:AddField( "HS9_CODIGO", "C", 10, 0 )
	oModel:AddField( "HS9_DESC"  , "C", 20, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXFormaPgto
	Local aForma 	:= {}
	Local nForma	:= 1  
	
	aAdd( aForma, {"CC", STR0001} ) //"Cartão de Crédito"				    
	aAdd( aForma, {"VA", STR0002} )	//"Vales"
	aAdd( aForma, {"CO", STR0003} ) //"Convênio"	
	aAdd( aForma, {"FI", STR0004} ) //"Financiado"	
	aAdd( aForma, {"CD", STR0005} ) //"Cartão de Débito"
	aAdd( aForma, {"CH", STR0006} ) //"Cheque"	
	aAdd( aForma, {"CR", STR0007} ) //"Crédito"	
	aAdd( aForma, {"R$", STR0008} ) //"Dinheiro"		
	aAdd( aForma, {"FID", STR0009} ) //"Cartão Fidelidade"	
			
	For nForma := 1 To Len( aForma )
 		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HS9_FORPAG", oKey:GetKey( { aForma[nForma][1] }, , .F. ) )		
		oRecord:SetValue( "HS9_CODIGO", aForma[nForma][1] )
		oRecord:SetValue( "HS9_DESC"  , aForma[nForma][2] )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next nTipo 	

 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil	