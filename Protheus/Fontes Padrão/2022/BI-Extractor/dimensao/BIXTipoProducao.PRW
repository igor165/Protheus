#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTIPOPRODUCAO.CH"

REGISTER EXTRACTOR HQU

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTipoProducao
Visualiza as informações por Tipo de Produção. É uma classificação 
das informações de produção. Exemplos: Produção Interna, Produção 
Externa, Produção Ativo Fixo, Produção Manutenção.

@author  BI TEAM
@since   26/07/2010
/*/
//-------------------------------------------------------------------
Class BIXTipoProducao from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Tamara Clemente
@since   05/12/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXTipoProducao
	_Super:New( DIMENSION, "HQU", STR0003 ) //"Tipo de Produção"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTipoProducao
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HQU_TIPPRD" )
	oModel:SetBK( { "HQU_CODIGO" } )

	oModel:AddField( "HQU_TIPPRD" , "C", 32, 0 )
	oModel:AddField( "HQU_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HQU_DESC"   , "C", 60, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTipoProducao
	Local aType 	:= {}  
	Local nCombo 	:= 1      
	Local aCombo	:= {}

	SX3->( DBSetOrder( 2 ) )        
	
	If ( SX3->( DBSeek( "C2_TPOP" ) ) )  
		aCombo := aBIToken( X3CBox(), ";" )
	
		For nCombo := 1 To Len( aCombo )
			aType := aBIToken( aCombo[nCombo], "=", .F. )
			
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//-------------------------------------------------------------------   	
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Alimenta os campos de negócio. 
			//-------------------------------------------------------------------
			oRecord:SetValue( "HQU_TIPPRD", oKey:GetKey( { aType[1] },,.F.) )		
			oRecord:SetValue( "HQU_CODIGO", aType[1] )
			oRecord:SetValue( "HQU_DESC"  , aType[2] )
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação da Fluig Smart Data. 
			//-------------------------------------------------------------------		
			oOutput:Send( oRecord ) 
		Next	

		//-------------------------------------------------------------------
		// Libera o pool de gravação. 
		//-------------------------------------------------------------------	
		oOutput:Release()
	EndIf
Return nil