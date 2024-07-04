#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXMOTIVOAFASTAMENTO.CH"

REGISTER EXTRACTOR HJS

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXMotivoAfastamento
Visualiza as informações por código ou descrição do motivo de 
movimentação. Representa os motivos dos desligamentos, contratações, 
afastamentos, aumentos salariais e transferências de colaboradores na 
empresa.

@author  BI TEAM
@since   09/08/2010
/*/
//-------------------------------------------------------------------
Class BIXMotivoAfastamento from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Valdiney V GOMES
@since   09/08/2010
/*/
//-------------------------------------------------------------------  
Method New() class BIXMotivoAfastamento
	_Super:New( DIMENSION, "HJS", STR0001, "SX5" ) //"Motivo de Afastamento"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXMotivoAfastamento 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJS_MOTMOV" )
	oModel:SetBK( { "HJS_CODIGO" } )

	oModel:AddField( "HJS_MOTMOV" , "C", 32, 0 )
	oModel:AddField( "HJS_CODIGO" , "C", 60, 0 )		
	oModel:AddField( "HJS_DESC"   , "C", 55, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXMotivoAfastamento
 	Local aContent := {}
	Local nI := 0

	aContent := FWGetSX5( "30" )

	For nI := 1 to Len( aContent )
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "X5_CHAVE", 	aContent[nI][3] ) 
		oRecord:SetValue( "X5_TABELA", 	aContent[nI][2] ) 
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJS_MOTMOV", oKey:GetKey( { aContent[nI][3] } ) )		
		oRecord:SetValue( "HJS_CODIGO", aContent[nI][3] )
		oRecord:SetValue( "HJS_DESC"  , aContent[nI][4] )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 

	Next

	//-------------------------------------------------------------------
	// Muda tabela de origem em tempo de execução.
	//-------------------------------------------------------------------		
	::SetTable( "SRX" )
	cFlow := ""

	cFlow := ::Flow( cFrom, cTo, { "RX_COD", "RX_TXT" }, { { "RX_TIP", "=", "32" } } )

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "X5_CHAVE", 	(cFlow)->RX_COD )
		oRecord:SetValue( "X5_TABELA", 	'32' )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJS_MOTMOV", oKey:GetKey( { (cFlow)->RX_COD } ) )		
		oRecord:SetValue( "HJS_CODIGO", (cFlow)->RX_COD )
		oRecord:SetValue( "HJS_DESC"  , (cFlow)->RX_TXT )
		
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

	FWFreeArray( aContent )
Return nil