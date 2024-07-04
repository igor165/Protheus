#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCLASSEVL.CH"

REGISTER EXTRACTOR HG8

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXClasseVl
As informações são visualizadas por Classe de Valor. Classe de valor é 
uma subdivisão dos custos contábeis que separa os valores dos centros de custo.

@author  Helio Leal
@since   22/02/2017
/*/
//-------------------------------------------------------------------
Class BIXClasseVl from BIXEntity
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
Method New() class BIXClasseVl
	_Super:New( DIMENSION, "HG8", STR0001, "CTH" ) //"Classe Valor"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   22/02/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXClasseVl 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HG8_CLVL" )
	oModel:SetBK( { "HG8_CODIGO" } )
	
	oModel:AddField( "HG8_CLVL"   , "C", 32, 0 		)
	oModel:AddField( "HG8_CODIGO" , "C", 10, 0 		)
	oModel:AddField( "HG8_DESC"   , "C", 60, 0 		) 
	oModel:AddField( "HG8_CLVLP"  , "C", 32, 0, .T. )
	oModel:AddField( "HG8_CODPAI" , "C", 10, 0 		)

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXClasseVl
	Local aUpper	:= {}
	Local cUpper	:= ""
	Local cFlow 	:= ""

	cFlow := ::Flow( cFrom, cTo, { "CTH_CLVL", "CTH_DESC01", "CTH_CLSUP", "CTH_CLASSE" } )	
	
	While ! ( (cFlow)->( Eof() ) )  
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Alimenta os campos para customização e consolidação. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "CTH_CLVL", 	(cFlow)->CTH_CLVL )
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HG8_CLVL"	, oKey:GetKey( { (cFlow)->CTH_CLVL } ) )
		oRecord:SetValue( "HG8_CODIGO"	, (cFlow)->CTH_CLVL )
		oRecord:SetValue( "HG8_DESC"	, (cFlow)->CTH_DESC01 )

		//-------------------------------------------------------------------
		// Recupera as informações da conta superior.
		//-------------------------------------------------------------------
		cUpper := (cFlow)->CTH_CLSUP

		//-------------------------------------------------------------------
		// Verifica se a conta superior é sintética.
		//-------------------------------------------------------------------
		If ( CTH->( DBSeek(xFilial("CTH") + cUpper) ) .And. CTH->CTH_CLASSE == "1" ) 
			oRecord:SetValue( "HG8_CODPAI", cUpper )
			oRecord:SetValue( "HG8_CLVLP",  oKey:GetKey( { cUpper },,,,.F. ) )
		Else
			oRecord:SetValue( "HG8_CLVLP", oKey:GetKey( { UNDEFINED },,,,.F. ) )
			oRecord:SetValue( "HG8_CODPAI", UNDEFINED )

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
		BIXSetLog( LOG_RUNNING, "HG8",,,,, STR0001 + " " + BIXConcatWSep( ",", aUpper ) + STR0002 ) //"Classe Valor"###" indicado(s) como superior não é sintética."    
	EndIf
Return nil