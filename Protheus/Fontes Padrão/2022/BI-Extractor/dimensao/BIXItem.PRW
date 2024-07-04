#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXITEM.CH"

REGISTER EXTRACTOR HJ8

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXItem
Visualiza as informações por código ou descrição do Item. 
Item é todo e qualquer material individualmente considerado e mantido 
em estoque, com o objetivo de venda, consumo ou transformação. 
Estes itens podem ser os itens fabricados que são vendidos, ou itens 
que são componentes de produtos comerciais.

@author  BI TEAM
@since   16/06/2010
/*/
//-------------------------------------------------------------------
Class BIXITEM from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Tamara Clemente
@since   28/04/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXItem
	_Super:New( DIMENSION, "HJ8", STR0001, "SB1", /*aApp*/, /*lShare*/, .T. ) //"Item"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Tamara Clemente
@since   28/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXItem 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJ8_ITEM" )
	oModel:SetBK( { "HJ8_CODIGO" } )

	oModel:AddUnifier( { "B1_COD" }, STR0002 ) //"Código do item"

	oModel:AddField( "HJ8_ITEM"		, "C", 32, 0 )
	oModel:AddField( "HJ8_CODIGO" 	, "C", 30, 0 )
	oModel:AddField( "HJ8_DESC"   	, "C", 60, 0 )
	oModel:AddField( "HJ8_TIPO" 	, "C", 04, 0 )
	oModel:AddField( "HJ8_UNITEM" 	, "C", 05, 0 )
	oModel:AddField( "HJ8_CFITEM"   , "C", 10, 0 )
	oModel:AddField( "HJ8_DESCTP" 	, "C", 30, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXITEM
 	Local cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "B1_COD", "B1_DESC", "B1_POSIPI" } )

 	While ! (cFlow)->( Eof() )  
 		If oRecord:ChkModify( (cFlow)->USERLGI, (cFlow)->USERLGA )
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 		
			oRecord:Init()
	
			//-------------------------------------------------------------------
			// Alimenta os campos para customização. 
			//-------------------------------------------------------------------
			oRecord:SetValue( "B1_COD"		, (cFlow)->B1_COD )
			
			//-------------------------------------------------------------------
			// Alimenta os campos de negócio. 
			//-------------------------------------------------------------------
			oRecord:SetValue( "HJ8_ITEM"	, oKey:GetKey( { (cFlow)->B1_COD } ) )
			oRecord:SetValue( "HJ8_CODIGO"	, (cFlow)->B1_COD )
			oRecord:SetValue( "HJ8_DESC"	, (cFlow)->B1_DESC )
			oRecord:SetValue( "HJ8_CFITEM"	, (cFlow)->B1_POSIPI )
			oRecord:SetValue( "HJ8_TIPO"	, " " )		
			oRecord:SetValue( "HJ8_UNITEM"	, " " )
			oRecord:SetValue( "HJ8_DESCTP"	, " " )
	
			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação da Fluig Smart Data. 
			//-------------------------------------------------------------------	
			oOutput:Send( oRecord ) 
		EndIf
		
 		(cFlow)->( DBSkip() )
 	EndDo  
 	
	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
 
Return nil