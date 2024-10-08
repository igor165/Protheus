#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPORTADOR.CH"

REGISTER EXTRACTOR HG4

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPortador
As informa��es s�o visualizadas por c�digo ou descri��o do portador. 
Portador � a entidade que movimenta valores, recebe a posse de t�tulos 
para efetuar a cobran�a, executa pagamentos, entre outras coisas. 
Normalmente, o portador � uma entidade banc�ria, mas tamb�m podem ser 
portadores n�o banc�rios como o caixa da empresa, por exemplo.

@author  Helio Leal
@since   21/02/2017
/*/
//-------------------------------------------------------------------
Class BIXPortador from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@Return Self, Inst�ncia da classe. 

@author  Helio Leal
@since   21/02/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXPortador
	_Super:New( DIMENSION, "HG4", STR0001, "SA6" ) //"Portador"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  

@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   21/02/2017
/*/
//-------------------------------------------------------------------
Method Model() class BIXPortador
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HG4_BANCO" )
	oModel:SetBK( { "HG4_CODIGO", "HG4_AGECIA", "HG4_NUMCON" } )

	oModel:AddField("HG4_BANCO"  , "C", 32, 0 )
	oModel:AddField("HG4_CODIGO" , "C", 10, 0 )
	oModel:AddField("HG4_TIPO"   , "C", 01, 0 )
	oModel:AddField("HG4_DESC"   , "C", 40, 0 )
	oModel:AddField("HG4_DESCTP" , "C", 30, 0 )
	oModel:AddField("HG4_AGECIA" , "C", 10, 0 )
	oModel:AddField("HG4_NUMCON" , "C", 10, 0 )

	oModel:FreeField()
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} Run
Extra��o dos dados para entidade. 
 
@param cFrom	, caracter	, Data inicial de extra��o. 
@param cTo		, caracter	, Data final de extra��o.
@param dToday	, data		, Data de inicio do processo de extra��o.  
@param oOutput	, objeto	, Objeto para grava��o dos dados.
@param oRecord	, objeto	, Objeto para extra��o dos dados.
@param oKey		, objeto	, Objeto para gera��o da surrogate key.

@author  Helio Leal
@since   21/02/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXPortador
 	Local cFlow	:= ""
 	Local aBank	:= {}

 	cFlow := ::Flow( cFrom, cTo, { "A6_COD", "A6_NOME", "A6_AGENCIA", "A6_NUMCON"  } )

	While ! ( (cFlow)->( Eof() ) )
	 	//-------------------------------------------------------------------
		// Insere o registro contendo somente o banco.
		//-------------------------------------------------------------------
		If ( aScan( aBank, {|x| x == (cFlow)->A6_COD }) == 0 )
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//-------------------------------------------------------------------   
			oRecord:Init()

			//-------------------------------------------------------------------
			// Alimenta os campos para customiza��o. 
			//-------------------------------------------------------------------	
			oRecord:SetValue( "A6_COD", 	(cFlow)->A6_COD )
			oRecord:SetValue( "A6_AGENCIA", "" )
			oRecord:SetValue( "A6_NUMCON", 	"" )

			//-------------------------------------------------------------------
			// Alimenta os campos de neg�cio. 
			//-------------------------------------------------------------------
			oRecord:SetValue( "HG4_BANCO"	, oKey:GetKey( { (cFlow)->A6_COD, "", "" } ) )
			oRecord:SetValue( "HG4_CODIGO"	, (cFlow)->A6_COD )
			oRecord:SetValue( "HG4_DESC"	, (cFlow)->A6_NOME )
			oRecord:SetValue( "HG4_AGECIA"	, "" )
			oRecord:SetValue( "HG4_NUMCON"	, "" )
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de grava��o da Fluig Smart Data. 
			//-------------------------------------------------------------------
			oOutput:Send( oRecord )

			aAdd( aBank, (cFlow)->A6_COD )
		EndIf

		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   
		oRecord:Init()

	 	//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o. 
		//-------------------------------------------------------------------		  
		oRecord:SetValue( "A6_COD"		, (cFlow)->A6_COD )
		oRecord:SetValue( "A6_AGENCIA"	, (cFlow)->A6_AGENCIA )
		oRecord:SetValue( "A6_NUMCON"	, (cFlow)->A6_NUMCON )

		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HG4_BANCO"	, oKey:GetKey( { (cFlow)->A6_COD, (cFlow)->A6_AGENCIA, (cFlow)->A6_NUMCON } ) )
		oRecord:SetValue( "HG4_CODIGO"	, (cFlow)->A6_COD )
		oRecord:SetValue( "HG4_DESC" 	, (cFlow)->A6_NOME )
		oRecord:SetValue( "HG4_AGECIA"	, (cFlow)->A6_AGENCIA )
		oRecord:SetValue( "HG4_NUMCON"	, (cFlow)->A6_NUMCON )
		
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
Return nil