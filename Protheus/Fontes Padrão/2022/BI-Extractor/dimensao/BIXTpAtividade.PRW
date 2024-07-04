#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTPATIVIDADE.CH"

REGISTER EXTRACTOR HSL

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTpAtividade
Visualiza as informações pelo tipo da atividade. As atividades são tarefas, 
compromissos ou e-mails gerados pelos usuários para execução de alguma 
ação que deve ser realizada para completar um trabalho.

@author  Valdiney V GOMES
@since   23/04/2014
/*/
//-------------------------------------------------------------------
Class BIXTpAtividade from BIXEntity
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
Method New() class BIXTpAtividade
	_Super:New( DIMENSION, "HSL", STR0001 ) //"Tipo de Atividade"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   03/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXTpAtividade
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HSL_TIPATV" )
	oModel:SetBK( { "HSL_CODIGO" } )

	oModel:AddField( "HSL_TIPATV" , "C", 32, 0 )
	oModel:AddField( "HSL_CODIGO" , "C", 10, 0 )		
	oModel:AddField( "HSL_DESC"   , "C", 12, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXTpAtividade
	Local aTipo  	:= {} 
	Local nCombo	:= 1	       
	Local aCombo	:= {}

	SX3->( DBSetOrder( 2 ) )        
	
	If ( SX3->( DBSeek( "AOF_TIPO" ) ) )  
		aCombo  := aBIToken( X3CBox(), ";" )

		For nCombo := 1 To Len( aCombo )
			aTipo := aBIToken( aCombo[nCombo], "=", .F. )
			
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//-------------------------------------------------------------------   	
			oRecord:Init()

			//-------------------------------------------------------------------
			// Alimenta os campos de negócio. 
			//-------------------------------------------------------------------
			oRecord:SetValue( "HSL_TIPATV", oKey:GetKey( { aTipo[1] },,.F.) )		
			oRecord:SetValue( "HSL_CODIGO", aTipo[1] )
			oRecord:SetValue( "HSL_DESC"  , aTipo[2] )
			
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
return NIL