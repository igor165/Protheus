#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXDEPOSITO.CH"

REGISTER EXTRACTOR HJD

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXDeposito
Visualiza as informações por código ou descrição do depósito. 
Depósito é o local físico onde são armazenados itens diversos 
(matérias-primas, componentes, produtos acabados).

@author  BI TEAM
@since   06/08/2010
/*/
//-------------------------------------------------------------------
Class BIXDeposito from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( ) 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Método construtor.  

@author  Helio Leal
@version P12 
@since   02/12/2016
/*/
//-------------------------------------------------------------------  
Method New() class BIXDeposito
	_Super:New( DIMENSION, "HJD", STR0001, "SB2" ) //"Depósito"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXDeposito 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJD_DEPOSI" )
	oModel:SetBK( { "HJD_CODIGO" } )

	oModel:AddField( "HJD_DEPOSI" , "C", 32, 0 )
	oModel:AddField( "HJD_CODIGO" , "C", 15, 0 )		
	oModel:AddField( "HJD_DESC"   , "C", 40, 0 )		
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXDeposito
 	Local cFlow := ""
	Local cDescri := ""
	Local cIdioma := FWRetIdiom()
	Local aArmazen := {}
	
	If cIdioma == "es"
		cDescri := GetSx3Cache("B2_LOCAL","X3_TITSPA")
	Else
		If cIdioma == "en"
			cDescri := GetSx3Cache("B2_LOCAL","X3_TITENG")
		Else
			cDescri := GetSx3Cache("B2_LOCAL","X3_TITULO")
		EndIf
	EndIf

 	cDescri := alltrim(cDescri) + " "
	
	cFlow := ::Flow( cFrom, cTo, { "B2_LOCAL" } )

 	While ! ( (cFlow)->( Eof() ) ) 
 		If !Empty( (cFlow)->B2_LOCAL) .and. aScan(aArmazen,{|x| x == (cFlow)->B2_LOCAL }) == 0		
			aAdd(aArmazen, (cFlow)->B2_LOCAL)
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//-------------------------------------------------------------------   	
			oRecord:Init()
		
			//-------------------------------------------------------------------
			// Alimenta os campos para customização e consolidação. 
			//-------------------------------------------------------------------
			oRecord:SetValue( "B2_COD", 	' ' )
			oRecord:SetValue( "B2_LOCAL", 	(cFlow)->B2_LOCAL )			
			//-------------------------------------------------------------------
			// Alimenta os campos de negócio. 
			//-------------------------------------------------------------------
			oRecord:SetValue( "HJD_DEPOSI" , oKey:GetKey( { (cFlow)->B2_LOCAL, } ) )		
			oRecord:SetValue( "HJD_CODIGO" , (cFlow)->B2_LOCAL )
			oRecord:SetValue( "HJD_DESC"   , cDescri + (cFlow)->B2_LOCAL )
			
			//--------------------------------------------------------------------
			// Envia o registro para o pool de gravação da Fluig Smart Data. 
			//--------------------------------------------------------------------		
			oOutput:Send( oRecord )
		EndIf
		(cFlow)->( DBSkip() )  
	EndDo  

 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
Return nil
