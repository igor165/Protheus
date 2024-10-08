#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTIPOHORAS.CH"

REGISTER EXTRACTOR HJI

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTipoHoras
As informa��es s�o visualizadas por c�digo e descri��o do tipos de horas. 
Referem-se aos tipos de horas cadastrados no Ponto Eletr�nico (Banco de Horas). 
Exemplo: Extras, Lan�amento Positivo Banco Horas, Hora Usada na Compensa��o, 
Hora Extra n�o Autorizada. 

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
M�todo construtor.  

@author  Valdiney V GOMES
@since   11/08/2010
/*/
//-------------------------------------------------------------------  
Method New() class BIXTipoHoras
	_Super:New( DIMENSION, "HJI", STR0007 ) //"Tipo de Horas"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
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
			// Alimenta os campos de neg�cio. 
			//-------------------------------------------------------------------
			oRecord:SetValue( "HJI_TIPHRS", oKey:GetKey( { aType[1] },,.F.) )		
			oRecord:SetValue( "HJI_CODIGO", aType[1] )
			oRecord:SetValue( "HJI_DESC"  , aType[2] )
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de grava��o da Fluig Smart Data. 
			//-------------------------------------------------------------------		
			oOutput:Send( oRecord ) 
		Next	
		//-------------------------------------------------------------------
		// Libera o pool de grava��o. 
		//-------------------------------------------------------------------	
		oOutput:Release()
	EndIf	
Return nil

