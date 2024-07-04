#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "CRMM010.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMMUSERROLES

Classe responsável por retornar os papeis do  usuário do CRM.

@author	Anderson Silva
@since		13/12/2016
@version	12.1.15
/*/
//------------------------------------------------------------------------------

WSRESTFUL CRMMUSERROLES DESCRIPTION STR0001 //"Papeis de usuário"
 
WSDATA cUserId AS STRING OPTIONAL

WSMETHOD GET DESCRIPTION STR0002 WSSYNTAX "/CRMMUSERROLES || /CRMMUSERROLES/{cUserId}" //"Retorna os papeis do usuário do CRM"
 
ENDWSRESTFUL
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GET / CRMMUSERROLES
Retorna os papeis do usuário.

@param	 cUserId	, caracter, Id do usuário do Protheus. 
@return cResponse	, caracter, JSON com os papeis do usuário. 

@author	Anderson Silva
@since		13/12/2016
@version	12.1.15 
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE cUserId WSSERVICE CRMMUSERROLES

	Local cIdUserRole		:= ""	
	Local cDescription		:= ""
	Local cResponse			:= '{ "USERROLES":[], "COUNT": 0 }'	
	Local cMessage			:= "Internal Server Error"
	Local nStatusCode		:= 500
	Local lRet	 			:= .F.

	Default Self:cUserId	:= ""
	 
	// Define o tipo de retorno do método
	Self:SetContentType("application/json")
	
	If ( Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[1] ) )
		Self:cUserId := Self:aURLParms[1]
	EndIf

	If Empty( Self:cUserId )
		Self:cUserId := __cUserId
	EndIf
	
	AO3->( dbSetOrder(1) )
	If AO3->( MSSeek(xFilial("AO3") + Self:cUserId ) )
	
		If !Empty(AO3->AO3_VEND) 
			lRet := .T.
		
			cResponse	:= ""
			cResponse	+= '{ "USERROLES":[ ' 
		
			cIdUserRole 	:= AO3->AO3_CODUSR 
			
			If !Empty( AO3->AO3_VEND )
				cDescription	+= AO3->AO3_VEND +  ": "  
			EndIf 
			
			cDescription  += Capital( CRMMText( Posicione("SA3", 1, XFILIAL("SA3") + AO3->AO3_VEND, "A3_NOME"), .F., .T. ) )
			
			cResponse += '{"ROLE_ID":"'				+ cIdUserRole 				+ '",' 
			cResponse += '"ROLE_DESCRIPTION":"'	    + EncodeUTF8(cDescription) 	+ '",'	
			cResponse += '"SALESMAN_ID":"'		 	+ AO3->AO3_VEND 			+ '",'	
			cResponse += '"MAIN_ROLE":' 			+ "true"	 				+ ','	
			cResponse += '"HIDDEN":'				+ "true"	 				+ '}' 
			cResponse += ' ] } '
		Else
			nStatusCode	:= 400
			cMessage 	:= STR0004 //"Nao foi possivel identificar vendedor deste usuario..."
		EndIf	
	Else
		nStatusCode	:= 400
		cMessage 	:= STR0005 //"Nao foi possivel identificar este usuario como usuario do CRM..."
	EndIf
	
	If lRet
		Self:SetResponse( cResponse )
	Else 
		SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
	EndIf

Return( lRet )