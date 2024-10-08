#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCENTROCUSTO.CH"

REGISTER EXTRACTOR HJ5

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCentroCusto
As informa��es s�o visualizadas por c�digo ou descri��o do Centro de 
Custo. Centro de Custo � o identificador da se��o de uma empresa que 
recebe as cargas dos custos e/ou receitas obtidas na elabora��o de bens 
e servi�os, possibilitando saber o quanto se aplicou para mant�-la.

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
M�todo construtor.  

@author  Helio Leal
@since   22/02/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXCentroCusto
	_Super:New( DIMENSION, "HJ5", STR0001, "CTT" ) //"Centro de Custo"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
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
Extra��o dos dados para entidade. 
 
@param cFrom, caracter, Data inicial de extra��o. 
@param cTo, caracter, Data final de extra��o.
@param dToday, data, Data de inicio do processo de extra��o.  
@param oOutput, objeto, Objeto para grava��o dos dados.
@param oRecord, objeto, Objeto para extra��o dos dados.
@param oKey, objeto, Objeto para gera��o da surrogate key.

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
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "CTT_CUSTO", 	(cFlow)->CTT_CUSTO )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJ5_CCUSTO"	, oKey:GetKey( { (cFlow)->CTT_CUSTO } ) )
		oRecord:SetValue( "HJ5_CODIGO"	, (cFlow)->CTT_CUSTO )
		oRecord:SetValue( "HJ5_DESC"	, (cFlow)->CTT_DESC01 )
		oRecord:SetValue( "HJ5_PLCUST"	, UNDEFINED )

		//-------------------------------------------------------------------
		// Recupera as informa��es da conta superior.
		//-------------------------------------------------------------------
		cUpper := (cFlow)->CTT_CCSUP

		//-------------------------------------------------------------------
		// Verifica se a conta superior � sint�tica.
		//-------------------------------------------------------------------
		If ( CTT->( DBSeek( xFilial("CTT") + cUpper ) ) .And. CTT->CTT_CLASSE == "1" )
			oRecord:SetValue( "HJ5_CODPAI", cUpper )
			oRecord:SetValue( "HJ5_CCPAI",  oKey:GetKey( { cUpper },,, .T.,.F. ) )
		Else			
			oRecord:SetValue( "HJ5_CCPAI", oKey:GetKey( { UNDEFINED },,, .F.,.F. ) )
			oRecord:SetValue( "HJ5_CODPAI", UNDEFINED )
			
			//-------------------------------------------------------------------
			// Lista as contas superiores que n�o s�o sint�ticas. 
			//-------------------------------------------------------------------	
			If ! ( Empty( cUpper ) )
				If ( aScan( aUpper, {|x| Alltrim(x) == Alltrim( cUpper ) } ) == 0 )
					Aadd( aUpper, AllTrim( cUpper ) )
				EndIf
			EndIf
		EndIf

		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 

 		(cFlow)->( DBSkip() ) 
 	EndDo

 	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()

   	//-------------------------------------------------------------------
	// Loga as contas superiores n�o sint�ticas. 
	//-------------------------------------------------------------------	
	If ! ( Empty( aUpper ) )
		BIXSetLog( LOG_RUNNING, "HJ5",,,,, STR0001 + " " + BIXConcatWSep( ",", aUpper ) + STR0002 ) //"Centro de Custo"###" indicado(s) como superior n�o � sint�tica."    
	EndIf
Return nil