#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPROVENDA.CH"

REGISTER EXTRACTOR HSN

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXProVenda
Visualiza as informações por código ou descrição do processo de venda. 
O processo de venda determina o processo para realizar uma venda de 
determinada organização, contendo etapas sequenciais que determinam 
os passos para completar a venda.

@author  Valdiney V GOMES
@since   23/04/2014
/*/
//-------------------------------------------------------------------
Class BIXProVenda from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )     
	Method Flow()	
EndClass
     
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@author  Valdiney V GOMES
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXProVenda
	_Super:New( DIMENSION, "HSN", STR0001, "AC2" ) //"Processo de Venda"
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   02/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXProVenda 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HSN_PROVEN" )
	oModel:SetBK( { "HSN_CODIGO" } )

	oModel:AddField( "HSN_PROVEN" , "C", 32, 0 )
	oModel:AddField( "HSN_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HSN_DESC"   , "C", 30, 0 )		
	oModel:AddField( "HSN_CODEST" , "C", 10, 0 )		
	oModel:AddField( "HSN_DESEST" , "C", 30, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXProVenda
 	Local cFlow := ""
	
	cFlow := ::Flow( cFrom, cTo, { "AC2_PROVEN", "AC2_STAGE", "AC2_DESCRI", "AC1_DESCRI" } )
	
 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "AC2_PROVEN", (cFlow)->AC2_PROVEN )
		oRecord:SetValue( "AC2_STAGE", (cFlow)->AC2_STAGE )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HSN_PROVEN" , oKey:GetKey( { (cFlow)->AC2_PROVEN } ) )		
		oRecord:SetValue( "HSN_CODIGO" , (cFlow)->AC2_PROVEN )
		oRecord:SetValue( "HSN_CODEST"   , (cFlow)->AC2_STAGE )
		oRecord:SetValue( "HSN_DESEST"   , (cFlow)->AC2_DESCRI )
		oRecord:SetValue( "HSN_DESC"   , (cFlow)->AC1_DESCRI )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 

		(cFlow)->( DBSkip() ) 
	EndDo  

 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
	
	(cFlow)->( DBCloseArea() ) 
Return nil   			

//-------------------------------------------------------------------
/*/{Protheus.doc} Flow
Define o fluxo de dados da entidade. Pode ser usado para recuperar
dados de uma única tabela ou sobrescrito para recuperar dados de mais
de uma tabela.  

@param cFrom, caracter, Período inicial de extração.
@param cTo, caracter, Período final de extração.
@param aField, array, Lista de campos a serem recuperados. 
@param [aWhere], array, Restrição na recuperação de dados no formato {{campo, operação, valor}}. 
@return cFlow, Alias temporário. 

@author  Marcia Junko
@since   02/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXProVenda
	Local cDML	:= ""

	cDML := "SELECT AC2_PROVEN, AC2_STAGE, AC2_DESCRI, AC1_DESCRI " + ;
		"FROM " + RetSqlName("AC2") + " AC2 " + ;
		"LEFT JOIN " + RetSQLName("AC1") + " AC1 " + ;
		"ON AC1_FILIAL = '" + xFilial("AC1") + "' " + ;
			"AND AC1_PROVEN = AC2_PROVEN " + ;
			"AND AC1.D_E_L_E_T_= ' ' " + ;
		"WHERE AC2_FILIAL = '" + xFilial("AC2") + "' " + ;
			"AND AC2.D_E_L_E_T_ = ' '"
	
	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  	
	cDML := ChangeQuery( cDML )
	
	//-------------------------------------------------------------------
	// Executa o DML. 
	//-------------------------------------------------------------------  	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cDML ), ::cFlow := GetNextAlias() , .T., .F. )
Return ::cFlow
