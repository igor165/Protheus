#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
 
WSRESTFUL UBAW10 DESCRIPTION "Cadastro de Locais - NNR"

WSDATA dateDiff AS STRING OPTIONAL
WSDATA page     AS INTEGER OPTIONAL
WSDATA pageSize AS INTEGER OPTIONAL

WSMETHOD GET 		 DESCRIPTION "Retorna uma lista de locais" 	      PATH "/v1/locals" 				  PRODUCES APPLICATION_JSON
WSMETHOD GET GetDiff DESCRIPTION "Retorna uma lista de locais - Diff" PATH "/v1/locals/diff/{dateDiff}" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET QUERYPARAM page, pageSize WSSERVICE UBAW10
	Local lPost     := .T.
	Local oLocal    := JsonObject():New()	
	Local cDateTime	:= ""
	Local cQuery    := ""
	Local oPage     := {}
	Local nPage 	:= IIf(!Empty(::page),::page,1)
	Local nPageSize := IIf(!Empty(::pageSize),::pageSize,30)
	Local nCount	:= 0
	Local lHasNext	:= .F.
	
	oPage := FwPageCtrl():New(nPageSize,nPage)
	
	// Coloca a data e hora atual
	// Formato UTC aaaa-mm-ddThh:mm:ss-+Time Zone (coloca a hora local + o timezone (ISO 8601))
	cDateTime := FWTimeStamp(5)
    
    ::SetContentType("application/json")
    
    oLocal["hasNext"] := .F.
    oLocal["items"]   := Array(0)
    oLocal["totvs_sync_date"] := cDateTime
    
    cAlias := GetNextAlias()
    cQuery := " SELECT NNR.NNR_FILIAL, "            
	cQuery += "        NNR.NNR_CODIGO, "            
    cQuery += "        (CASE WHEN NNR.D_E_L_E_T_ = '*' THEN 1 ELSE 2 END) AS DELNNR "        
    cQuery += " FROM " + RetSqlName("NNR") + " NNR "
	
	cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)
        
	If (cAlias)->(!Eof())      
        While (cAlias)->(!Eof())
        
        	nCount++
			If !oPage:CanAddLine()							
				If nCount <= (nPageSize * nPage)
					(cAlias)->(DbSkip())
					LOOP					
				Else
					EXIT
				EndIf
			EndIf
        
        	lDeletado := .F.
       
        	If (cAlias)->DELNNR = 1 
        		lDeletado := .T.
        	EndIf
        
            Aadd(oLocal["items"], JsonObject():New())            
            
			aTail(oLocal["items"])['branch']    := Alltrim((cAlias)->NNR_FILIAL)            			
            aTail(oLocal["items"])['code'] 		:= Alltrim((cAlias)->NNR_CODIGO)            			
            aTail(oLocal["items"])['deleted']  	:= lDeletado
            
            (cAlias)->(DbSkip())
        EndDo
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oLocal["hasNext"] := lHasNext
        
    	cResponse := EncodeUTF8(FWJsonSerialize(oLocal, .F., .F., .T.))
        ::SetResponse(cResponse)
    Else
        cResponse := FWJsonSerialize(oLocal, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf

	(cAlias)->(DbCloseArea())
               
Return lPost

WSMETHOD GET GetDiff QUERYPARAM page, pageSize PATHPARAM dateDiff WSSERVICE UBAW10
	Local lPost     := .T.
	Local oLocal    := JsonObject():New()	
	Local cDateTime	:= ""
	Local oPage     := {}
	Local nPage 	:= IIf(!Empty(::page),::page,1)
	Local nPageSize := IIf(!Empty(::pageSize),::pageSize,30)
	Local nCount	:= 0
	Local lHasNext	:= .F.
	
	oPage := FwPageCtrl():New(nPageSize,nPage)
	
	// Coloca a data e hora atual
	// Formato UTC aaaa-mm-ddThh:mm:ss-+Time Zone (coloca a hora local + o timezone (ISO 8601))
	cDateTime := FWTimeStamp(5)
	
	::SetContentType("application/json")
    
    oLocal["hasNext"] := .F.
    oLocal["items"]   := Array(0)
    oLocal["totvs_sync_date"] := cDateTime
    
    cAlias := GetNextAlias()
    cQuery := " SELECT NNR.NNR_FILIAL, "            
	cQuery += "        NNR.NNR_CODIGO, "            
    cQuery += "        (CASE WHEN NNR.D_E_L_E_T_ = '*' THEN 1 ELSE 2 END) AS DELNNR "        
    cQuery += " FROM " + RetSqlName("NNR") + " NNR "
	
	cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)
        
	If (cAlias)->(!Eof())      
        While (cAlias)->(!Eof())
        
        	nCount++
			If !oPage:CanAddLine()							
				If nCount <= (nPageSize * nPage)
					(cAlias)->(DbSkip())
					LOOP					
				Else
					EXIT
				EndIf
			EndIf
        
        	lDeletado := .F.
       
        	If (cAlias)->DELNNR = 1 
        		lDeletado := .T.
        	EndIf
        
            Aadd(oLocal["items"], JsonObject():New())            
            
			aTail(oLocal["items"])['branch']    := Alltrim((cAlias)->NNR_FILIAL)            			
            aTail(oLocal["items"])['code'] 		:= Alltrim((cAlias)->NNR_CODIGO)            
            aTail(oLocal["items"])['deleted']  	:= lDeletado
            
            (cAlias)->(DbSkip())
        EndDo
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oLocal["hasNext"] := lHasNext
        
    	cResponse := EncodeUTF8(FWJsonSerialize(oLocal, .F., .F., .T.))
        ::SetResponse(cResponse)
    Else
        cResponse := FWJsonSerialize(oLocal, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf

	(cAlias)->(DbCloseArea())
                      
Return lPost
