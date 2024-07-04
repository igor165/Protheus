#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
 
WSRESTFUL UBAW13 DESCRIPTION "Rest da Entidade Instrução de Embarque para App"

WSDATA dateDiff AS STRING OPTIONAL
WSDATA page     AS INTEGER OPTIONAL
WSDATA pageSize AS INTEGER OPTIONAL

WSMETHOD GET 		   DESCRIPTION "Retorna uma lista de " 	                               PATH "/v1/shippingInstruction"                  PRODUCES APPLICATION_JSON
WSMETHOD GET GetDiff   DESCRIPTION "Retorna uma lista de contaminantes - Diff" 	    	   PATH "/v1/shippingInstruction/diff/{dateDiff}"  PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET QUERYPARAM page, pageSize WSSERVICE UBAW13
	Local lPost        := .T.
	Local oClassifier  := JsonObject():New()
	Local cDateTime	   := ""
	Local oPage        := {}
	Local nPage 	   := IIf(!Empty(::page),::page,1)
	Local nPageSize    := IIf(!Empty(::pageSize),::pageSize,30)
	Local nCount	   := 0
	Local lHasNext	   := .F.
		
	oPage := FwPageCtrl():New(nPageSize,nPage)	
	
	// Coloca a data e hora atual
	// Formato UTC aaaa-mm-ddThh:mm:ss-+Time Zone (coloca a hora local + o timezone (ISO 8601))
	cDateTime := FWTimeStamp(5)	
	
	::SetContentType("application/json")
	
    cAlias := GetNextAlias()

    cQuery := " SELECT 'INSERT' OPERATION, N7Q.R_E_C_N_O_, N7Q_DESINE, SUM(N83.N83_QUANT) QUANT , N7Q_LIMMAX,  N7Q_PERMAX, SUM(N83.N83_PSLIQU) PESOLIQ  "
    cQuery += "     FROM       " + RetSqlName("N7Q") + " N7Q "
    cQuery += "     INNER JOIN " + RetSqlName("N83") + " N83 ON N83.N83_FILIAL = N7Q.N7Q_FILIAL AND N83.N83_CODINE = N7Q.N7Q_CODINE AND N83.D_E_L_E_T_ <> '*' "
    cQuery += " WHERE N7Q.D_E_L_E_T_ <> '*' "
    cQuery += " 	AND EXISTS (
    cQuery += "					SELECT 1 FROM " + RetSqlName("N7S") + " N7S 
    cQuery += "                        WHERE N7S.N7S_FILIAL = N7Q.N7Q_FILIAL AND N7S.N7S_CODINE = N7Q.N7Q_CODINE AND N7S.D_E_L_E_T_ <> '*'    AND 
    cQuery += "                              ( N7S.N7S_DATINI >= '"+dtos(DDATABASE)      + "' OR N7S.N7S_DATFIM >= '"+dtos(DDATABASE)     +"') AND 
    cQuery += "                              ( N7S.N7S_DATINI <= '"+dtos(DDATABASE + 30) + "' OR N7S.N7S_DATFIM <= '"+dtos(DDATABASE + 30)+"' ) ) "
	cQuery += " GROUP BY N7Q.R_E_C_N_O_, N7Q_CODINE, N7Q_DESINE, N7Q_DTCARG, N7Q_LIMMAX, N7Q_PERMAX "	
		
	cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)	
	
	oClassifier["hasNext"]         := .F.
    oClassifier["items"]           := Array(0)
    oClassifier["totvs_sync_date"] := cDateTime
    
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
			
			nLimite := (cAlias)->N7Q_LIMMAX - ((cAlias)->N7Q_LIMMAX * (cAlias)->N7Q_PERMAX / 100)	

			Aadd(oClassifier["items"], JsonObject():New())
            
            aTail(oClassifier["items"])['recno']    		:= (cAlias)->R_E_C_N_O_            
            aTail(oClassifier["items"])['code']    		    := Alltrim((cAlias)->N7Q_DESINE )
            
            aTail(oClassifier["items"])['balesQt']    		:= (cAlias)->QUANT   
            aTail(oClassifier["items"])['weightLimitInst']  := nLimite
            aTail(oClassifier["items"])['balesWeight']    	:= (cAlias)->PESOLIQ
          
            aTail(oClassifier["items"])['deleted']  := .F.			
		
		
			(cAlias)->(DbSkip())
        EndDo
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oClassifier["hasNext"] := lHasNext
        
        cResponse := EncodeUTF8(FWJsonSerialize(oClassifier, .F., .F., .T.))        
        ::SetResponse(cResponse)
        
    Else    
        cResponse := FWJsonSerialize(oClassifier, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf
    
     (cAlias)->(DbCloseArea())   
Return lPost

WSMETHOD GET GetDiff QUERYPARAM page, pageSize PATHPARAM dateDiff WSSERVICE UBAW13
	Local lPost        := .T.
	Local oClassifier  := JsonObject():New()
	Local cDateTime	   := ""
	Local oPage        := {}
	Local nPage 	   := IIf(!Empty(::page),::page,1)
	Local nPageSize    := IIf(!Empty(::pageSize),::pageSize,30)
	Local nCount	   := 0
	Local lHasNext	   := .F.
	Local cDateDiff	   := ::dateDiff
			
	oPage := FwPageCtrl():New(nPageSize,nPage)	
	
	// Coloca a data e hora atual
	// Formato UTC aaaa-mm-ddThh:mm:ss-+Time Zone (coloca a hora local + o timezone (ISO 8601))
	cDateTime := FWTimeStamp(5)	
	
	aData := FWDateTimeToLocal(cDateDiff)
	
	cData := Year2Str(Year(aData[1])) + Month2Str(Month(aData[1])) + Day2Str(Day(aData[1]))
	
	::SetContentType("application/json")
	
    cAlias := GetNextAlias()
    cQuery := " SELECT 'INSERT' OPERATION, N7Q.R_E_C_N_O_, N7Q_DESINE, SUM(N83.N83_QUANT) QUANT , N7Q_LIMMAX,  N7Q_PERMAX, SUM(N83.N83_PSLIQU) PESOLIQ  "
    cQuery += "     FROM       " + RetSqlName("N7Q") + " N7Q "
    cQuery += "     INNER JOIN " + RetSqlName("N83") + " N83 ON N83.N83_FILIAL = N7Q.N7Q_FILIAL AND N83.N83_CODINE = N7Q.N7Q_CODINE AND N83.D_E_L_E_T_ <> '*' "
    cQuery += " WHERE N7Q.D_E_L_E_T_ <> '*' "
    cQuery += " 	AND EXISTS (
    cQuery += "					SELECT 1 FROM " + RetSqlName("N7S") + " N7S 
    cQuery += "                        WHERE N7S.N7S_FILIAL = N7Q.N7Q_FILIAL AND N7S.N7S_CODINE = N7Q.N7Q_CODINE AND N7S.D_E_L_E_T_ <> '*'    AND 
    cQuery += "                              ( N7S.N7S_DATINI >= '"+dtos(DDATABASE)      + "' OR N7S.N7S_DATFIM >= '"+dtos(DDATABASE)     +"') AND 
    cQuery += "                              ( N7S.N7S_DATINI <= '"+dtos(DDATABASE + 30) + "' OR N7S.N7S_DATFIM <= '"+dtos(DDATABASE + 30)+"' ) ) "
	cQuery += " GROUP BY N7Q.R_E_C_N_O_, N7Q_CODINE, N7Q_DESINE, N7Q_DTCARG, N7Q_LIMMAX, N7Q_PERMAX "	
	cQuery += " UNION "
	cQuery += " SELECT 'DELETE' OPERATION, N7Q.R_E_C_N_O_, N7Q_DESINE, SUM(N83.N83_QUANT) QUANT , N7Q_LIMMAX,  N7Q_PERMAX, SUM(N83.N83_PSLIQU) PESOLIQ  "
    cQuery += "     FROM       " + RetSqlName("N7Q") + " N7Q "
    cQuery += "     INNER JOIN " + RetSqlName("N83") + " N83 ON N83.N83_FILIAL = N7Q.N7Q_FILIAL AND N83.N83_CODINE = N7Q.N7Q_CODINE AND N83.D_E_L_E_T_ <> '*' "
    cQuery += " WHERE N7Q.D_E_L_E_T_ <> '*' "
    cQuery += " 	AND EXISTS (
    cQuery += "                 SELECT 1 FROM " + RetSqlName("N7S") + " N7S 
    cQuery += "                        WHERE N7S.N7S_FILIAL = N7Q.N7Q_FILIAL AND N7S.N7S_CODINE = N7Q.N7Q_CODINE AND N7S.D_E_L_E_T_ <> '*' AND 
    cQuery += "                              ( N7S.N7S_DATFIM >= '"+cData+ "' AND N7S.N7S_DATFIM < '"+dtos(DDATABASE)+"' ) ) "
	cQuery += " GROUP BY N7Q.R_E_C_N_O_, N7Q_CODINE, N7Q_DESINE, N7Q_DTCARG, N7Q_LIMMAX, N7Q_PERMAX "	

	cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)	
	
	oClassifier["hasNext"]         := .F.
    oClassifier["items"]           := Array(0)
    oClassifier["totvs_sync_date"] := cDateTime
    
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
			
			nLimite := (cAlias)->N7Q_LIMMAX - ((cAlias)->N7Q_LIMMAX * (cAlias)->N7Q_PERMAX / 100)	

			Aadd(oClassifier["items"], JsonObject():New())
            
            aTail(oClassifier["items"])['recno']    		:= (cAlias)->R_E_C_N_O_            
            aTail(oClassifier["items"])['code']    		    := Alltrim((cAlias)->N7Q_DESINE )
            
            aTail(oClassifier["items"])['balesQt']    		:= (cAlias)->QUANT   
            aTail(oClassifier["items"])['weightLimitInst']  := nLimite
            aTail(oClassifier["items"])['balesWeight']    	:= (cAlias)->PESOLIQ
          
            aTail(oClassifier["items"])['deleted']          := IIF((cAlias)->OPERATION == 'DELETE',.T.,.F.)			
		
			(cAlias)->(DbSkip())
        EndDo
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oClassifier["hasNext"] := lHasNext
        
        cResponse := EncodeUTF8(FWJsonSerialize(oClassifier, .F., .F., .T.))        
        ::SetResponse(cResponse)
        
    Else    
        cResponse := FWJsonSerialize(oClassifier, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf
    
    (cAlias)->(DbCloseArea())   
	
Return lPost

