#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
 
WSRESTFUL UBAW16 DESCRIPTION "Intervalo de Fardos - N7T"

WSDATA dateDiff AS STRING OPTIONAL
WSDATA page     AS INTEGER OPTIONAL
WSDATA pageSize AS INTEGER OPTIONAL

WSMETHOD GET 		 DESCRIPTION "Retorna um intervalo de fardos" 	     PATH "/v1/baleInterval" 				 PRODUCES APPLICATION_JSON
WSMETHOD GET GetDiff DESCRIPTION "Retorna um intervalo de fardos - Diff" PATH "/v1/baleInterval/diff/{dateDiff}" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET QUERYPARAM page, pageSize WSSERVICE UBAW16
	Local lPost     := .T.
	Local oInterval := JsonObject():New()		
	Local cDateTime	:= ""	
	Local cQuery    := ""
	Local oPage     := {}
	Local nPage 	:= IIf(!Empty(::page),::page,1)
	Local nPageSize := IIf(!Empty(::pageSize),::pageSize,30)
	Local nCount	:= 0
	Local lHasNext	:= .F.	

	cData := dDataBase 
	cHora := Time()

	oPage := FwPageCtrl():New(nPageSize,nPage)
	
	// Coloca a data e hora atual
	// Formato UTC aaaa-mm-ddThh:mm:ss-+Time Zone (coloca a hora local + o timezone (ISO 8601))
	cDateTime := FWTimeStamp(5)
    
    ::SetContentType("application/json")
    
    oInterval["hasNext"] := .F.
    oInterval["items"]   := Array(0)
    oInterval["totvs_sync_date"] := cDateTime
    
    cAlias := GetNextAlias()
    cQuery := " SELECT N7T.R_E_C_N_O_ N7TREC, "
    cQuery += "        N7T.N7T_FRDINI, "            
	cQuery += "        N7T.N7T_FRDFIM, "                      
	cQuery += "        N7T.N7T_SAFRA, "                      
	cQuery += "        N7T.N7T_FILIAL, "
	cQuery += "        N7T.N7T_DTENV, "
	cQuery += "        N7T.N7T_HRENV "                    
    cQuery += " FROM " + RetSqlName("N7T") + " N7T "
	cQuery += "  WHERE N7T.D_E_L_E_T_ <> '*' "
	cQuery += "    AND N7T.N7T_DTENV IS NOT NULL "
	cQuery += "    AND NOT EXISTS (SELECT 1 FROM " + RetSqlName("DXI") + " DXI "
	cQuery += "                   WHERE DXI.DXI_ETIQ BETWEEN N7T.N7T_FRDINI AND N7T.N7T_FRDFIM "
	cQuery += "                     AND DXI.D_E_L_E_T_ != '*' "
	cQuery += " 					AND DXI.DXI_EMBFIS <> '') "

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
						
			cCodIni    := POSICIONE("DXI",1,(cAlias)->N7T_FILIAL+(cAlias)->N7T_SAFRA+(cAlias)->N7T_FRDINI,"DXI_CODIGO")
			cCodFim    := POSICIONE("DXI",1,(cAlias)->N7T_FILIAL+(cAlias)->N7T_SAFRA+(cAlias)->N7T_FRDFIM,"DXI_CODIGO")
			cClassific := POSICIONE("DXI",1,(cAlias)->N7T_FILIAL+(cAlias)->N7T_SAFRA+(cAlias)->N7T_FRDFIM,"DXI_CLACOM")
		
			Aadd(oInterval["items"], JsonObject():New())            
			
			aTail(oInterval["items"])['recno']  		:= (cAlias)->N7TREC
			aTail(oInterval["items"])['classification'] := Alltrim(cClassific)
			aTail(oInterval["items"])['branch']    		:= Alltrim((cAlias)->N7T_FILIAL)						  
			aTail(oInterval["items"])['barCodeInitial']	:= (cAlias)->N7T_FRDINI
			aTail(oInterval["items"])['barCodeFinal']	:= (cAlias)->N7T_FRDFIM        			
			aTail(oInterval["items"])['codeInitial']	:= cCodIni
			aTail(oInterval["items"])['codeFinal'] 		:= cCodFim   
			aTail(oInterval["items"])['date']	 		:= (cAlias)->N7T_DTENV
			aTail(oInterval["items"])['hour']	 		:= (cAlias)->N7T_HRENV
			aTail(oInterval["items"])['deleted']  		:= .F.
						
            (cAlias)->(DbSkip())
        EndDo
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oInterval["hasNext"] := lHasNext
        
    	cResponse := EncodeUTF8(FWJsonSerialize(oInterval, .F., .F., .T.))
        ::SetResponse(cResponse)
    Else
        cResponse := FWJsonSerialize(oInterval, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf

	(cAlias)->(DbCloseArea())	
               
Return lPost

WSMETHOD GET GetDiff QUERYPARAM page, pageSize PATHPARAM dateDiff WSSERVICE UBAW16
	Local lPost     := .T.
	Local oInterval := JsonObject():New()	
	Local cDateDiff := ::dateDiff
	Local cDateTime	:= ""
	Local oPage     := {}
	Local nPage 	:= IIf(!Empty(::page),::page,1)
	Local nPageSize := IIf(!Empty(::pageSize),::pageSize,30)
	Local nCount	:= 0
	Local lHasNext	:= .F.	
	Local lDeletado := .F.
		
	oPage := FwPageCtrl():New(nPageSize,nPage)

	aData := FWDateTimeToLocal(cDateDiff)
	
	// Coloca a data e hora atual
	// Formato UTC aaaa-mm-ddThh:mm:ss-+Time Zone (coloca a hora local + o timezone (ISO 8601))
	cDateTime := FWTimeStamp(5)
	
	::SetContentType("application/json")
    
    oInterval["hasNext"] 		 := .F.
    oInterval["items"]   		 := Array(0)
    oInterval["totvs_sync_date"] := cDateTime
    
    cAlias := GetNextAlias()
   
	cData := Year2Str(Year(aData[1])) + Month2Str(Month(aData[1])) + Day2Str(Day(aData[1]))
	cHora := aData[2] 
 
    cQuery := " SELECT N7T.R_E_C_N_O_ N7TREC, "
    cQuery += "		   N7T.N7T_FRDINI, "           
	cQuery += "        N7T.N7T_FRDFIM, "                      
	cQuery += "        N7T.N7T_SAFRA, "                      
	cQuery += "        N7T.N7T_FILIAL, "
	cQuery += "        N7T.N7T_DTENV, " 
	cQuery += "        N7T.N7T_HRENV, "   
	cQuery += "        (CASE WHEN N7T.D_E_L_E_T_ = '*' THEN 1 ELSE 2 END) AS DELN7T "                      
    cQuery += "   FROM " + RetSqlName("N7T") + " N7T "
	cQuery += "  WHERE N7T_DTENV IS NOT NULL  "
	cQuery += "    AND (N7T_DATATU > '"+cData+"' OR (N7T_DATATU = '"+cData+"' AND N7T_HORATU >= '"+cHora+"')) "
	cQuery += "    AND EXISTS (SELECT 1 FROM " + RetSqlName("DXI") + " DXI "
	cQuery += "                   WHERE DXI.DXI_ETIQ BETWEEN N7T.N7T_FRDINI AND N7T.N7T_FRDFIM "
	cQuery += "                     AND DXI.D_E_L_E_T_ != '*' "
	cQuery += " 					AND DXI.DXI_EMBFIS = '') "
    
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
			
			If (cAlias)->DELN7T == 1
				lDeletado := .T.
			EndIf
					
			cCodIni    := POSICIONE("DXI",1,(cAlias)->N7T_FILIAL+(cAlias)->N7T_SAFRA+(cAlias)->N7T_FRDINI,"DXI_CODIGO")
			cCodFim    := POSICIONE("DXI",1,(cAlias)->N7T_FILIAL+(cAlias)->N7T_SAFRA+(cAlias)->N7T_FRDFIM,"DXI_CODIGO")
			cClassific := POSICIONE("DXI",1,(cAlias)->N7T_FILIAL+(cAlias)->N7T_SAFRA+(cAlias)->N7T_FRDFIM,"DXI_CLACOM")
		
			Aadd(oInterval["items"], JsonObject():New())          
			
			aTail(oInterval["items"])['recno']    	 	:= (cAlias)->N7TREC
			aTail(oInterval["items"])['classification'] := Alltrim(cClassific)
			aTail(oInterval["items"])['branch']    	 	:= Alltrim((cAlias)->N7T_FILIAL) 
			aTail(oInterval["items"])['barCodeInitial']	:= (cAlias)->N7T_FRDINI
			aTail(oInterval["items"])['barCodeFinal']	:= (cAlias)->N7T_FRDFIM           			
			aTail(oInterval["items"])['codeInitial']    := cCodIni           			
			aTail(oInterval["items"])['codeFinal'] 	 	:= cCodFim     
			aTail(oInterval["items"])['date']	 		:= (cAlias)->N7T_DTENV
			aTail(oInterval["items"])['hour']	 		:= (cAlias)->N7T_HRENV    			
			aTail(oInterval["items"])['deleted']  		:= lDeletado
						
            (cAlias)->(DbSkip())
        EndDo
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oInterval["hasNext"] := lHasNext
        
    	cResponse := EncodeUTF8(FWJsonSerialize(oInterval, .F., .F., .T.))
        ::SetResponse(cResponse)
    Else
        cResponse := FWJsonSerialize(oInterval, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf

	(cAlias)->(DbCloseArea())
                      
Return lPost
