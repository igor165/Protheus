#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXITEMCONT.CH"

REGISTER EXTRACTOR HG9

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXItemCont
Visualiza as informações por Item Contábil. Item Contábil é uma subdivisão
das classes de valor dentro da hierarquia dos custos contábeis.

@author  BI TEAM
@since   18/11/2010
/*/
//-------------------------------------------------------------------
Class BIXItemCont from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Helio Leal
@since   10/04/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXItemCont
	_Super:New( DIMENSION, "HG9", STR0001, "CTD" ) //"Item Contábil"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   10/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXItemCont 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HG9_ITMCTB" )
	oModel:SetBK( { "HG9_CODIGO" } )

	oModel:AddField( "HG9_ITMCTB" , "C", 32, 0 )
	oModel:AddField( "HG9_ITMCTP" , "C", 32, 0, .T. )	
	oModel:AddField( "HG9_CODPAI" , "C", 10, 0 )
	oModel:AddField( "HG9_CODIGO" , "C", 10, 0 )
	oModel:AddField( "HG9_DESC"   , "C", 60, 0 )
	
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
@since   10/04/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXItemCont
	Local cUpper 	:= ""
	Local cFlow 	:= ""
	Local aUpper	:= {}
    	
	cFlow := ::Flow( cFrom, cTo, { "CTD_ITEM", "CTD_DESC01", "CTD_ITSUP", "CTD_CLASSE" } )
	
	While ! ( (cFlow)->( Eof() ) ) 
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
	
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "CTD_ITEM", 	(cFlow)->CTD_ITEM )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HG9_ITMCTB"	, oKey:GetKey( { (cFlow)->CTD_ITEM } ) )		
		oRecord:SetValue( "HG9_CODIGO"	, (cFlow)->CTD_ITEM )
		oRecord:SetValue( "HG9_DESC"	, (cFlow)->CTD_DESC01 )
		
		//-------------------------------------------------------------------
		// Recupera as informações da conta superior.
		//-------------------------------------------------------------------
		cUpper := (cFlow)->CTD_ITSUP

		//-------------------------------------------------------------------
		// Verifica se a conta superior é sintética.
		//-------------------------------------------------------------------
		If ( CTD->( DBSeek( xFilial("CTD") + cUpper ) ) .And. CTD->CTD_CLASSE == "1" )
			oRecord:SetValue( "HG9_CODPAI", cUpper )
			oRecord:SetValue( "HG9_ITMCTP",  oKey:GetKey( { cUpper },,,,.F. ) )
		Else
			oRecord:SetValue( "HG9_ITMCTP", oKey:GetKey( { UNDEFINED },,,,.F. ) )
			oRecord:SetValue( "HG9_CODPAI", UNDEFINED )

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
		BIXSetLog( LOG_RUNNING, "HG9",,,,, STR0001 + " " + BIXConcatWSep( ",", aUpper ) + STR0002 ) //"Item Contábil"###" indicado(s) como superior não é sintética."    
	EndIf
Return nil