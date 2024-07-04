#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFXHORA.CH"

REGISTER EXTRACTOR HS8
   
Static aFxHora := Nil    
           
//-------------------------------------------------------------------
/*/{Protheus.doc} BIXFxHora
Visualiza as informações classificadas por faixa de horas para 
identificação de picos de venda.

@author  Valdiney V GOMES
@since   10/04/2014
/*/
//-------------------------------------------------------------------
Class BIXFxHora from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )  
EndClass
     
//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@author  Valdiney V GOMES
@since   07/03/2014
/*/
//-------------------------------------------------------------------  
Method New() class BIXFxHora
	_Super:New( DIMENSION, "HS8", STR0002 ) // "Faixa de Hora" 
Return Self   

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   01/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXFxHora 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HS8_FXHORA" )
	oModel:SetBK( { "HS8_CODIGO" } )

	oModel:AddField( "HS8_FXHORA", "C", 32, 0 )
	oModel:AddField( "HS8_CODIGO", "C", 10, 0 )
	oModel:AddField( "HS8_DESC"  , "C", 40, 0 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXFxHora
	Local aInterval := SetBIXFxHora()
	Local nInterval	:= 1     

	For nInterval := 1 To Len( aInterval )   
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()

		//-------------------------------------------------------------------
		// Alimenta os campos de negócio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HS8_FXHORA", oKey:GetKey( { cBIStr( nInterval )}, , .F. ) )		
		oRecord:SetValue( "HS8_CODIGO", cBIStr( nInterval ) )
		oRecord:SetValue( "HS8_DESC"  , I18n( STR0001, { aInterval[nInterval][1], aInterval[nInterval][2] } ) ) //"Entre #1 e #2"	  	 
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 
	Next nInterval

 	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
return nil
       
//-------------------------------------------------------------------
/*/{Protheus.doc} SetBIXFxHora
Método responsável pela extração dos dados. 

@author  Valdiney V GOMES
@version P12 
@since   10/04/2014  
/*/
//-------------------------------------------------------------------
Static Function SetBIXFxHora()   
	Local aInterval			:= {}  
	Local nMinute	 			:= 0 
	Local nInitialHour    	:= 0
	Local nInitialMinute   	:= 0
	Local nFinalHour      	:= 0
	Local nFinalMinute    	:= 0  
	Local nInterval	   		:= BIXParInfo( "BIX_FXHORA", "N", 5 )  
	Local cInitialTime   	:= ""
	Local cFinalTime      	:= "" 
	Local cMidnight			:= ""

	For nMinute := 0 To 1440 Step nInterval    
		//-------------------------------------------------------------------
		// Calcula a hora incial do intevalo. 
		//------------------------------------------------------------------- 
		nInitialHour 	:= Int( ( nMinute / 60 ) )
		nInitialMinute	:= Abs( ( ( nMinute / 60 ) - nInitialHour ) * 60 )
		cInitialTime	:= StrZero( nInitialHour, 2) + ":" + StrZero( nInitialMinute, 2 ) 

		//-------------------------------------------------------------------
		// Calcula a hora final do intervalo. 
		//------------------------------------------------------------------- 
		nFinalHour 		:= Int( ( nMinute + nInterval ) / 60 )
		nFinalMinute	:= Abs( ( ( ( nMinute / 60 ) - nFinalHour ) * 60 ) + nInterval )
		cFinalTime		:= StrZero( nFinalHour, 2) + ":" + StrZero( nFinalMinute, 2 ) 		
 		  
  		//-------------------------------------------------------------------
		// Lista os intervalos. 
		//-------------------------------------------------------------------  
		If ! ( nInitialHour == 24 )    
			cMidnight := If( cFinalTime > "23:59", "00:00", cFinalTime )
		    cMidnight := If( nInterval == 1440, "23:59", "00:00" )
	   		aAdd( aInterval, { cInitialTime, If( cFinalTime > "23:59", cMidnight, cFinalTime ) } ) 
		EndIf 	   	 
	Next nMinute
Return aInterval

//-------------------------------------------------------------------
/*/{Protheus.doc} GetBIXFxHora
Método responsável pela extração dos dados. 

@param cTime	 Hora que será classificada dentro de uma faixa. 

@author  Valdiney V GOMES
@version P12 
@since   10/04/2014  
/*/
//-------------------------------------------------------------------
Function GetBIXFxHora( cTime )   		       
    Local nInterval := 1
    Local cRange 	:= ""
    
    If ( aFxHora == Nil )
    	aFxHora := SetBIXFxHora()  
    EndIf 
     
    For nInterval := 1 To Len( aFxHora )    
    	If ( cTime >= aFxHora[nInterval][1] .And. cTime <= aFxHora[nInterval][2] )
    	  	cRange := cBIStr( nInterval )
    	  	Exit
    	EndIf    
    Next nInterval
Return cRange