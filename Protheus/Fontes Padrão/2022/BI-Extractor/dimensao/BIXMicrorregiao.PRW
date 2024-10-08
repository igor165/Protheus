#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXMICRORREGIAO.CH"

REGISTER EXTRACTOR HGB

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXMicrorregiao
As informa��es s�o visualizadas pela Microrregi�o que s�o subdivis�es 
de uma regi�o comercial.

@author  BI TEAM
@since   30/07/2010
/*/
//-------------------------------------------------------------------
Class BIXMicrorregiao from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@Return Self, Inst�ncia da classe.

@author  Valdiney V GOMES
@since   04/11/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXMicrorregiao
	_Super:New( DIMENSION, "HGB", STR0001 , "SA1" ) // "Microrregi�o"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Valdiney V GOMES
@since   04/11/2016
/*/
//------------------------------------------------------------------- 
Method Model() class BIXMicrorregiao 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HGB_MICREG" )
	oModel:SetBK( { "HGB_CODIGO" } )

	oModel:AddField( "HGB_MICREG" , "C", 32, 0 )
	oModel:AddField( "HGB_CODIGO" , "C", 12, 0 )
	oModel:AddField( "HGB_DESC"   , "C", 40, 0 ) 
	
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

@author  BI TEAM
@since   26/07/2010
/*/
//-------------------------------------------------------------------
method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXMicrorregiao
	Local aRegion 	:= {}	
	Local cTitle	:= ""
 	Local cFlow 	:= ""

 	//-------------------------------------------------------------------
	// Recupera a descri��o do campo de acordo com o idioma. 
	//-------------------------------------------------------------------
	cTitle := ConvertTitle()
 
	cFlow := ::Flow( cFrom, cTo, { "A1_REGIAO" }, { { "A1_REGIAO", "<>", ' ' } } )
	
 	While ! ( (cFlow)->( Eof() ) )  
 		//-------------------------------------------------------------------
  		// Verifica o hist�rico das regi�es processadas. 
		//-------------------------------------------------------------------		   
 		If ( aScan( aRegion, {|x| x == (cFlow)->A1_REGIAO} ) == 0 )
			oRecord:Init()

			oRecord:SetValue( "A1_COD"	  , (cFlow)->A1_REGIAO )
			oRecord:SetValue( "A1_LOJA"	  , "" )
		
			oRecord:SetValue( "HGB_MICREG", oKey:GetKey( { (cFlow)->A1_REGIAO, "" } ) )
			oRecord:SetValue( "HGB_CODIGO", (cFlow)->A1_REGIAO ) 
			oRecord:SetValue( "HGB_DESC"  , cTitle + " " + ( cFlow )->A1_REGIAO )
	
			oOutput:Send( oRecord ) 

			aAdd( aRegion, (cFlow)->A1_REGIAO )
		Endif
		(cFlow)->( DBSkip() )
	EndDo

 	oOutput:Release()
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ConvertDescription
Retorna a descri��o correta acordo com o pais.

@author  Helio Leal
@since   03/05/2017
/*/
//-------------------------------------------------------------------
Static Function ConvertTitle()
	Local cTitle := "" 
	Local cLang := FWRetIdiom()

	//-------------------------------------------------------------------
	// Recupera a descri��o do campo de acordo com o idioma. 
	//-------------------------------------------------------------------
	If cLang == "es"
		cTitle := GetSx3Cache("A1_REGIAO","X3_TITSPA")
	Else
		If cLang == "en"
			cTitle := GetSx3Cache("A1_REGIAO","X3_TITENG")
		Else
			cTitle := GetSx3Cache("A1_REGIAO","X3_TITULO")
		EndIf
	EndIf
Return AllTrim( cTitle )
