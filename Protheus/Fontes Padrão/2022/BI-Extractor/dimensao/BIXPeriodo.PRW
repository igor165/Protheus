#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPERIODO.CH" 

REGISTER EXTRACTOR HK2

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPeriodo
As informações são visualizadas por Período de tempo. As divisões de 
Período podem ser Ano, Semestre, Trimestre, Mês e Data.

@author  BI TEAM
@since   23/06/2010
/*/
//-------------------------------------------------------------------
Class BIXPeriodo from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Valdiney V GOMES
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXPeriodo
	_Super:New( DIMENSION, "HK2", STR0001 ) //"Período"
Return Self 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Valdiney V GOMES
@since   04/11/2016
/*/
//------------------------------------------------------------------- 
Method Model() class BIXPeriodo 
	Local oModel := BIXModel():Build( Self, .F. )

	oModel:SetSK( "HK2_DATA" )
	oModel:SetBK( { "HK2_DATA" } )
	
	oModel:HasUndefined( .F. )

	oModel:AddField( "HK2_DATA" 	, "D", 8 , 0 )
	oModel:AddField( "HK2_ANO"  	, "N", 4 , 0 )
	oModel:AddField( "HK2_SMESTR"	, "C", 12, 0 )
	oModel:AddField( "HK2_TRIMST"	, "C", 13, 0 )
	oModel:AddField( "HK2_MES"		, "N", 4 , 0 )
	oModel:AddField( "HK2_NOMEMS"	, "C", 12, 0 )
	oModel:AddField( "HK2_DIA"		, "N", 4 , 0 )
	oModel:AddField( "HK2_DIASEM"	, "N", 4 , 0 )
	oModel:AddField( "HK2_SEMNOM"	, "C", 13, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXPeriodo
	Local dFrom 		:= nil 
	Local dTo			:= nil 
	Local nMonth		:= 0
	Local nDecrement	:= 0
	Local nIncrement	:= 0

	nDecrement 	:= SuperGetMv( "MV_BIXPERI", , 10 )
	nIncrement	:= SuperGetMv( "MV_BIXPERF", , 10 )
    dFrom 		:= FirstDay( StoD( cBIStr( Year( SToD( cFrom ) ) - nDecrement )  + "0101" ) ) 
    dTo 		:= LastDay( StoD( cBIStr( Year( SToD( cTo ) ) + nIncrement )  + "0101" ) ) 

	While ( dFrom <= dTo )
		nMonth := Month( dFrom )
	
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------  
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HK2_DATA"	, dFrom )
		oRecord:SetValue( "HK2_ANO"		, Year(dFrom ) )
		oRecord:SetValue( "HK2_SMESTR"	, If ( nMonth < 7 , "1", "2" ) )

	   	Do Case
	   		Case nMonth > 0 .And. nMonth < 4
	   			oRecord:SetValue( "HK2_TRIMST", "1" )
	   		Case nMonth > 3 .And. nMonth < 7
	   			oRecord:SetValue( "HK2_TRIMST", "2" )
	   		Case nMonth > 6 .And. nMonth < 10
	   			oRecord:SetValue( "HK2_TRIMST", "3" )
	   		Case nMonth > 9 .And. nMonth < 13
	   			oRecord:SetValue( "HK2_TRIMST", "4" )
	   	EndCase

	   	oRecord:SetValue( "HK2_MES"		, nMonth )
		oRecord:SetValue( "HK2_NOMEMS"	, CMonth( dFrom ) )
		oRecord:SetValue( "HK2_DIA"		, Day( dFrom ) )
		oRecord:SetValue( "HK2_DIASEM"	, Dow( dFrom ) )
		oRecord:SetValue( "HK2_SEMNOM"	, CDow( dFrom ) )
		
		dFrom ++
		
		//---------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//---------------------------------------------------------------
		oOutput:Send( oRecord ) 
	EndDo
	
 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()
Return nil