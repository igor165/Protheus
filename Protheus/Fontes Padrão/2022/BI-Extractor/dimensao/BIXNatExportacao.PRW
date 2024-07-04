#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXNATEXPORTACAO.CH"

REGISTER EXTRACTOR HGP

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXNatExportacao
Visualiza as informações pelos tipo de natureza de operação de 
exportação. Exemplo: Exportação Direta, Exportação Indireta.

@author  BI TEAM
@since   26/07/2010
/*/
//-------------------------------------------------------------------
Class BIXNatExportacao from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Helio Leal
@since   18/11/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXNatExportacao
	_Super:New( DIMENSION, "HGP", STR0010)//Natureza Exportação 
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   02/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXNatExportacao 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HGP_NATEXP" )
	oModel:SetBK( { "HGP_CODIGO" } )

	oModel:AddField( "HGP_NATEXP" , "C", 32, 0 )
	oModel:AddField( "HGP_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HGP_DESC"   , "C", 55, 0 )		
	
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
@since   02/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXNatExportacao
	Local nInd := 0
	Local aOrigem := {{ "1" , STR0001 },; // "EMBARQUE REGULAR"
						{ "2" , STR0002 },; // "EMBARQUE DE REMESSA POR CONSIGNACAO"
						{ "3" , STR0003 },; // "EMBARQUE DE VENDA POR CONSIGNACAO COM BACK TO BACK"
						{ "4" , STR0004 },; // "EMBARQUE DE BACK TO BACK REGULAR"
						{ "5" , STR0005 },; // "EMBARQUE DE REMESSA POR CONSIGNACAO COM BACK TO BACK"
						{ "6" , STR0006 },; // "EMBARQUE DE VENDA POR CONSIGNACAO"
						{ "7" , STR0007 },; // "EMBARQUE DE VENDA POR CONSIGNACAO COM BACK TO BACK"
						{ "8" , STR0008 },; // "EMBARQUE DE EXPORTACAO DE CAFE"
						{ "9" , STR0009 }}  // "EMBARQUE DE EXPORTACAO DE ACUCAR"                     

	For nInd := 1 To Len( aOrigem )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HGP_NATEXP", oKey:GetKey( { aOrigem[nInd][1] } , , .F. ))		
		oRecord:SetValue( "HGP_CODIGO", aOrigem[nInd][1] )
		oRecord:SetValue( "HGP_DESC"  , aOrigem[nInd][2] )

		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next

 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil