#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
 
WSRESTFUL UBAW17 DESCRIPTION "Privilegio de acesso - N9L"

WSDATA userlogin AS STRING OPTIONAL

WSMETHOD GET DESCRIPTION "Retorna o privilegio do usuario" PATH "/v1/role" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET QUERYPARAM userlogin WSSERVICE UBAW17
	Local lPost     	:= .T.
	Local oRole		 	:= JsonObject():New()			
	Local cUserlogin 	:= ::userlogin
	Local aAllUser 		:= FWSFALLUSERS()
	Local nCont 		:= 0
	    
    ::SetContentType("application/json")
    
    oRole["items"] := Array(0)
    
	For nCont := 1 to Len(aAllUser)
		
		If aAllUser[nCont][3] == cUserlogin

			DbSelectArea("N9L")
			N9L->(DbSetOrder(2))
			If N9L->(DbSeek(xFilial("N9L")+aAllUser[nCont][2]))
			
				Aadd(oRole["items"], JsonObject():New())
				
				aTail(oRole["items"])['name']		 	:= AllTrim(aAllUser[nCont][4])
				aTail(oRole["items"])['expedition']	 	:= N9L->N9L_APPEXP
				aTail(oRole["items"])['classification'] := N9L->N9L_APPCLA
				aTail(oRole["items"])['embedding']  	:= N9L->N9L_APPEMB				
				
			EndIf
			
			EXIT
			
		EndIf
		
	Next nCont
        
    cResponse := FWJsonSerialize(oRole, .F., .F., .T.)
    ::SetResponse(cResponse)

Return lPost
