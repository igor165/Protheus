#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCENTROCUSTO.CH"

REGISTER EXTRACTOR HJ5

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCentroCusto
As informações são visualizadas por código ou descrição do Centro de 
Custo. Centro de Custo é o identificador da seção de uma empresa que 
recebe as cargas dos custos e/ou receitas obtidas na elaboração de bens 
e serviços, possibilitando saber o quanto se aplicou para mantê-la.

@author  Helio Leal
@since   22/02/2017
/*/
//-------------------------------------------------------------------
Class BIXCentroCusto from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Helio Leal
@since   22/02/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXCentroCusto
	_Super:New( DIMENSION, "HJ5", STR0001, "CTT" ) //"Centro de Custo"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   22/02/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXCentroCusto 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJ5_CCUSTO" )
	oModel:SetBK( { "HJ5_CODIGO" } )

	oModel:AddUnifier( { "CTT_CUSTO" }, STR0001 ) //"Centro de Custo"

	oModel:AddField( "HJ5_CCUSTO" , "C", 32, 0 		)
	oModel:AddField( "HJ5_CODIGO" , "C", 25, 0 		)
	oModel:AddField( "HJ5_DESC"   , "C", 60, 0 		) 
	oModel:AddField( "HJ5_PLCUST" , "C", 08, 0		)
	oModel:AddField( "HJ5_CCPAI"  , "C", 32, 0, .T.  )
	oModel:AddField( "HJ5_CODPAI" , "C", 25, 0 		)

	oModel:HasFormula( .T. )

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
@since   22/02/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXCentroCusto
	Local aUpper	:= {}
	Local cUpper	:= ""
 	Local cFlow 	:= ""

	cFlow := ::Flow( cFrom, cTo, { "CTT_CUSTO", "CTT_DESC01", "CTT_CCSUP", "CTT_CLASSE" } )	

 	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "CTT_CUSTO", 	(cFlow)->CTT_CUSTO )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJ5_CCUSTO"	, oKey:GetKey( { (cFlow)->CTT_CUSTO } ) )
		oRecord:SetValue( "HJ5_CODIGO"	, (cFlow)->CTT_CUSTO )
		oRecord:SetValue( "HJ5_DESC"	, (cFlow)->CTT_DESC01 )
		oRecord:SetValue( "HJ5_PLCUST"	, UNDEFINED )

		//-------------------------------------------------------------------
		// Recupera as informações da conta superior.
		//-------------------------------------------------------------------
		cUpper := (cFlow)->CTT_CCSUP

		//-------------------------------------------------------------------
		// Verifica se a conta superior é sintética.
		//-------------------------------------------------------------------
		If ( CTT->( DBSeek( xFilial("CTT") + cUpper ) ) .And. CTT->CTT_CLASSE == "1" )
			oRecord:SetValue( "HJ5_CODPAI", cUpper )
			oRecord:SetValue( "HJ5_CCPAI",  oKey:GetKey( { cUpper },,, .T.,.F. ) )
		Else			
			oRecord:SetValue( "HJ5_CCPAI", oKey:GetKey( { UNDEFINED },,, .F.,.F. ) )
			oRecord:SetValue( "HJ5_CODPAI", UNDEFINED )
			
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
		BIXSetLog( LOG_RUNNING, "HJ5",,,,, STR0001 + " " + BIXConcatWSep( ",", aUpper ) + STR0002 ) //"Centro de Custo"###" indicado(s) como superior não é sintética."    
	EndIf
Return nil