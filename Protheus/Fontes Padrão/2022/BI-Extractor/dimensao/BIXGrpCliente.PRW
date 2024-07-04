#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXGRPCLIENTE.CH"

REGISTER EXTRACTOR HJ0

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGrpCliente
As informações são visualizadas por código ou descrição do Grupo de 
Clientes, que é o agrupamento dos mesmos com características comuns.
Exemplo: Atacadista, Varejista, Consumidor Final.

@author  BI TEAM
@since   22/07/2010
/*/
//-------------------------------------------------------------------
Class BIXGrpCliente from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da Classe.

@author  Tamara Clemente
@since   04/11/2016
/*/
//-------------------------------------------------------------------  
Method New() Class BIXGrpCliente
	_Super:New( DIMENSION, "HJ0", STR0001 ) //"Grupo de Clientes"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Valdiney V GOMES
@since   20/02/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXGrpCliente 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJ0_GRPCLI" )
	oModel:SetBK( { "HJ0_CODIGO" } )

	oModel:AddField( "HJ0_GRPCLI" , "C", 32, 0 )
	oModel:AddField( "HJ0_CODIGO" , "C", 11, 0 )
	oModel:AddField( "HJ0_DESC"   , "C", 40, 0 ) 

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
@since   26/07/2010
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) Class BIXGrpCliente
	Local aGroup := {}
	Local nGroup := 0	

	SX3->( DBSetOrder( 2 ) )        
	
	If ( SX3->( DBSeek("A1_TIPO" ) ) )
		aGroup := aBIToken( X3CBox(), ";" )
	
		For nGroup := 1 to Len( aGroup )	
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Alimenta os campos de negócio. 
			//-------------------------------------------------------------------	
	    	oRecord:SetValue( "HJ0_GRPCLI", oKey:GetKey( { aBIToken( aGroup[nGroup], "=", .F. )[1] },.T., .F. ) )
			oRecord:SetValue( "HJ0_CODIGO", aBIToken( aGroup[nGroup], "=", .F. )[1] )
			oRecord:SetValue( "HJ0_DESC"  , aBIToken( aGroup[nGroup], "=", .F. )[2] )
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação da Fluig Smart Data. 
			//-------------------------------------------------------------------		
			oOutput:Send( oRecord ) 		
		Next nGroup
	EndIf
	
	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------
 	oOutput:Release()	
Return nil 