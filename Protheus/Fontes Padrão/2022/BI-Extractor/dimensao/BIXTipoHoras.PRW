#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTIPOHORAS.CH"

REGISTER EXTRACTOR HJI

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTipoHoras
As informações são visualizadas por código e descrição do tipos de horas. 
Referem-se aos tipos de horas cadastrados no Ponto Eletrônico (Banco de Horas). 
Exemplo: Extras, Lançamento Positivo Banco Horas, Hora Usada na Compensação, 
Hora Extra não Autorizada. 

@author  BI TEAM
@since   11/08/2010
/*/
//-------------------------------------------------------------------
Class BIXTipoHoras from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Valdiney V GOMES
@since   11/08/2010
/*/
//-------------------------------------------------------------------  
Method New() class BIXTipoHoras
	_Super:New( DIMENSION, "HJI", STR0007 ) //"Tipo de Horas"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTipoHoras 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJI_TIPHRS" )
	oModel:SetBK( { "HJI_CODIGO" } )

	oModel:AddField( "HJI_TIPHRS" , "C", 32, 0 )
	oModel:AddField( "HJI_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HJI_DESC"   , "C", 55, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTipoHoras
	Local aType 	:= {}  
	Local nCombo 	:= 1      
	Local aCombo	:= {}

	SX3->( DBSetOrder( 2 ) )        
	
	If ( SX3->( DBSeek( "P9_CLASEV" ) ) )  
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
			oRecord:SetValue( "HJI_TIPHRS", oKey:GetKey( { aType[1] },,.F.) )		
			oRecord:SetValue( "HJI_CODIGO", aType[1] )
			oRecord:SetValue( "HJI_DESC"  , aType[2] )
			
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

