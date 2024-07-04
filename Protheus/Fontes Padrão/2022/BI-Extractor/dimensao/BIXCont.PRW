#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCONT.CH"

REGISTER EXTRACTOR HJE

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCont
Visualiza as informações código ou nome da Conta Contábil que está relacionada a um 
plano de contas. Conta Contábil é o elemento contábil destinado a sintetizar, mediante
débitos e créditos, as operações financeiras e patrimoniais, classificadas segundo os 
tipos dos componentes do patrimônio (bens, direitos e obrigações), dos custos, despesas 
ou consumos, das rendas ou receitas, do capital e dos lucros ou perdas.

@author  BI TEAM
@since   18/11/2010
/*/
//-------------------------------------------------------------------
Class BIXCont from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Helio Leal
@since   07/04/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXCont
	_Super:New( DIMENSION, "HJE", STR0001, "CT1" ) //"Conta Contábil"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   07/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXCont 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJE_CNTCTB" )
	oModel:SetBK( { "HJE_CODIGO" } )

	oModel:AddField( "HJE_CNTCTB" , "C", 32, 0 )
	oModel:AddField( "HJE_CNTCTP" , "C", 32, 0, .T. )	
	oModel:AddField( "HJE_PLCONT" , "C", 08, 0 )
	oModel:AddField( "HJE_CNTPAI" , "C", 40, 0 )
	oModel:AddField( "HJE_CODIGO" , "C", 40, 0 )
	oModel:AddField( "HJE_DESC"   , "C", 40, 0 )	
	
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

@author  Helio Leal
@since   07/04/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXCont
	Local aUpper	:= {}
	Local cUpper 	:= ""
	Local cSup		:= ""
	Local nCount	:= 0
	Local cFlow 	:= ""
    	
	cFlow := ::Flow( cFrom, cTo, { "CT1_CONTA", "CT1_DESC01", "CT1_CTASUP", "CT1_CLASSE" } )

	While ! ( (cFlow)->( Eof() ) ) 
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "CT1_CONTA", 	(cFlow)->CT1_CONTA )

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJE_CNTCTB"	, oKey:GetKey( { (cFlow)->CT1_CONTA } ) )		
		oRecord:SetValue( "HJE_CODIGO"	, (cFlow)->CT1_CONTA )
		oRecord:SetValue( "HJE_DESC"	, (cFlow)->CT1_DESC01 )
		oRecord:SetValue( "HJE_PLCONT"	, UNDEFINED )

		//-------------------------------------------------------------------
		// Recupera as informações da conta superior.
		//-------------------------------------------------------------------
		cUpper := (cFlow)->CT1_CTASUP
		
		//-------------------------------------------------------------------
		// Verifica se a conta superior é sintética.
		//-------------------------------------------------------------------
		If ( CT1->( DBSeek( xFilial("CT1") + cUpper ) ) .And. CT1->CT1_CLASSE == "1" )
			oRecord:SetValue( "HJE_CNTPAI", cUpper )
			oRecord:SetValue( "HJE_CNTCTP",  oKey:GetKey( { cUpper },,,,.F. ) )
		Else			
			oRecord:SetValue( "HJE_CNTCTP", oKey:GetKey( { UNDEFINED },,,,.F. ) )
			oRecord:SetValue( "HJE_CNTPAI", UNDEFINED )
			
			//-------------------------------------------------------------------
			// Lista as contas superiores que não são sintéticas. 
			//-------------------------------------------------------------------	
			If ! ( Empty( cUpper ) )
				If ( aScan( aUpper, {|x| Alltrim(x) == Alltrim( cUpper ) } ) == 0 )
					Aadd( aUpper, AllTrim( cUpper ) )
				EndIf
			EndIf			
		EndIf
		
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
	
	//-------------------------------------------------------------------
	// Loga as contas superiores não sintéticas. 
	//-------------------------------------------------------------------	
	If ! ( Empty( aUpper ) )
		BIXSetLog( LOG_RUNNING, "HJE",,,,, STR0001 + " " + BIXConcatWSep( ",", aUpper ) + STR0002 ) //"Conta Contábil"###" indicado(s) como superior não é sintética."    
	EndIf
Return nil