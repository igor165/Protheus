#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

WSRESTFUL UBAW03 DESCRIPTION "Cadastro de Contaminantes - N76/N77"

WSDATA dateDiff AS STRING OPTIONAL
WSDATA page     AS INTEGER OPTIONAL
WSDATA pageSize AS INTEGER OPTIONAL

WSMETHOD GET 		   DESCRIPTION "Retorna uma lista de contaminantes" 				   PATH "/v1/contaminants" 		 		 	  	 PRODUCES APPLICATION_JSON
WSMETHOD GET GetDiff   DESCRIPTION "Retorna uma lista de contaminantes - Diff" 	    	   PATH "/v1/contaminants/diff/{dateDiff}" 	  	 PRODUCES APPLICATION_JSON
WSMETHOD GET GetValues DESCRIPTION "Retorna uma lista de valores dos contaminantes" 	   PATH "/v1/contaminantsValues" 		 		 PRODUCES APPLICATION_JSON
WSMETHOD GET GetVDiff  DESCRIPTION "Retorna uma lista de valores dos contaminantes - Diff" PATH "/v1/contaminantsValues/diff/{dateDiff}" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET QUERYPARAM page, pageSize WSSERVICE UBAW03
	Local lPost        := .T.
	Local oContaminat  := JsonObject():New()
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
    cQuery := " SELECT N76.R_E_C_N_O_, " 
    cQuery += "        N76.N76_CODIGO, "
    cQuery += "    	   N76.N76_NMCON, "
    cQuery += "    	   N76.N76_TPCON, "
    cQuery += "    	   N76.N76_TMCON, "
    cQuery += "    	   N76.N76_VLPRC "    
    cQuery += "   FROM " + RetSqlName("N76") + " N76 "
    cQuery += "  WHERE N76.D_E_L_E_T_ <> '*' "
    cQuery += "    AND N76.N76_SITCON = '1' "
    cQuery += "    AND N76.N76_DISPWS = '1' "
    	
	cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)
    
    oContaminat["hasNext"] := .F.
    oContaminat["items"]   := Array(0)
    oContaminat["totvs_sync_date"] := cDateTime
    
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
        
        	Aadd(oContaminat["items"], JsonObject():New())
                    
            aTail(oContaminat["items"])['recno']      := (cAlias)->R_E_C_N_O_
            aTail(oContaminat["items"])['code']       := (cAlias)->N76_CODIGO
            aTail(oContaminat["items"])['name']       := (cAlias)->N76_NMCON
            aTail(oContaminat["items"])['typeResult'] := (cAlias)->N76_TPCON
            aTail(oContaminat["items"])['size'] 	  := (cAlias)->N76_TMCON
            aTail(oContaminat["items"])['accuracy']	  := (cAlias)->N76_VLPRC
            aTail(oContaminat["items"])['deleted']    := .F.
                        
            (cAlias)->(DbSkip())
        End
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oContaminat["hasNext"] := lHasNext
        
        cResponse := EncodeUTF8(FWJsonSerialize(oContaminat, .F., .F., .T.))
        ::SetResponse(cResponse)
    Else
        cResponse := FWJsonSerialize(oContaminat, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf
    
    (cAlias)->(DbCloseArea())
Return lPost

WSMETHOD GET GetDiff QUERYPARAM page, pageSize PATHPARAM dateDiff WSSERVICE UBAW03
	Local lPost        := .T.
	Local oContaminat  := JsonObject():New()
	Local cDateDiff	   := ::dateDiff
	Local aData		   := {}
	Local cData		   := ""	
	Local cHora		   := ""
	Local lDelete	   := .F.
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
    
    oContaminat["hasNext"] := .F.
    oContaminat["items"]   := Array(0)
    oContaminat["totvs_sync_date"] := cDateTime
    
    aData := FWDateTimeToLocal(cDateDiff)
    
    cAlias := GetNextAlias()
    cQuery := " SELECT N76.R_E_C_N_O_, " 
    cQuery += "        N76.N76_CODIGO, "
    cQuery += "    	   N76.N76_NMCON, "
    cQuery += "    	   N76.N76_TPCON, "
    cQuery += "    	   N76.N76_TMCON, "
    cQuery += "    	   N76.N76_VLPRC, "
    cQuery += "        (CASE WHEN N76.D_E_L_E_T_ = '*' THEN 1 ELSE 2 END) AS DELN76, "
    cQuery += "        N76.N76_SITCON, "
    cQuery += "        N76.N76_DISPWS, "
    cQuery += "        N76.N76_DATINC, "
	cQuery += "        N76.N76_HORINC "    
    cQuery += "   FROM " + RetSqlName("N76") + " N76 "
    
    cData := Year2Str(Year(aData[1])) + Month2Str(Month(aData[1])) + Day2Str(Day(aData[1]))
    cHora := aData[2]

    cQuery += " WHERE (((N76.N76_DATINC > '"+cData+"') OR (N76.N76_DATINC = '"+cData+"' AND N76.N76_HORINC >= '"+cHora+"')) "
    cQuery += "     OR ((N76.N76_DATATU > '"+cData+"') OR (N76.N76_DATATU = '"+cData+"' AND N76.N76_HORATU >= '"+cHora+"'))) "
        	
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
        
        	Aadd(oContaminat["items"], JsonObject():New())
        	
        	lDelete := .F.
        	
        	If (cAlias)->DELN76 = 1 .OR. (cAlias)->N76_SITCON == "2" .OR. (cAlias)->N76_DISPWS == "2"
        		lDelete := .T.
        	EndIf
        	
        	// Caso seja para enviar o contaminante como deletado, verifica se o mesmo foi incluído depois da última
        	// sincronização, caso o mesmo tenha sido incluído, não será enviado para o aplicativo
        	If lDelete .AND. (((cAlias)->N76_DATINC > cData) .OR.;
        		((cAlias)->N76_DATINC = cData .AND. (cAlias)->N76_HORINC >= cHora))
        		(cAlias)->(DbSkip())
        		LOOP        		
        	EndIf
                    
            aTail(oContaminat["items"])['recno']      := (cAlias)->R_E_C_N_O_
            aTail(oContaminat["items"])['code']       := (cAlias)->N76_CODIGO
            aTail(oContaminat["items"])['name']       := (cAlias)->N76_NMCON
            aTail(oContaminat["items"])['typeResult'] := (cAlias)->N76_TPCON
            aTail(oContaminat["items"])['size'] 	  := (cAlias)->N76_TMCON
            aTail(oContaminat["items"])['accuracy']	  := (cAlias)->N76_VLPRC
            aTail(oContaminat["items"])['deleted']    := lDelete
                        
            (cAlias)->(DbSkip())
        End
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oContaminat["hasNext"] := lHasNext
        
        cResponse := EncodeUTF8(FWJsonSerialize(oContaminat, .F., .F., .T.))
        ::SetResponse(cResponse)
    Else
        cResponse := FWJsonSerialize(oContaminat, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf
    
    (cAlias)->(DbCloseArea())
Return lPost

WSMETHOD GET GetValues QUERYPARAM page, pageSize WSSERVICE UBAW03
	Local lPost        := .T.
	Local oContValues  := JsonObject():New()
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
    cQuery := " SELECT N77.R_E_C_N_O_, " 
    cQuery += "        N77.N77_CODCTM, "
    cQuery += "        N77.N77_SEQ, "
    cQuery += "    	   N77.N77_RESULT, "
    cQuery += "    	   N77.N77_FAIINI, "
    cQuery += "    	   N77.N77_FAIFIM "    
    cQuery += "   FROM " + RetSqlName("N77") + " N77 "
    cQuery += " INNER JOIN " + RetSqlName("N76") + " N76 ON N76.N76_FILIAL = N77.N77_FILIAL "
    cQuery += "   AND N76.N76_CODIGO = N77.N77_CODCTM AND N76.D_E_L_E_T_ <> '*' AND N76.N76_SITCON = '1' AND N76.N76_DISPWS = '1' "
    cQuery += "  WHERE N77.D_E_L_E_T_ <> '*' "
    	
	cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)
    
    oContValues["hasNext"] := .F.
    oContValues["items"]   := Array(0)
    oContValues["totvs_sync_date"] := cDateTime
    
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
        
            Aadd(oContValues["items"], JsonObject():New())
            
            aTail(oContValues["items"])['recno']      	:= (cAlias)->R_E_C_N_O_
            aTail(oContValues["items"])['contaminant']  := (cAlias)->N77_CODCTM
            aTail(oContValues["items"])['sequence']     := (cAlias)->N77_SEQ
            aTail(oContValues["items"])['result']       := (cAlias)->N77_RESULT
            aTail(oContValues["items"])['initialRange'] := (cAlias)->N77_FAIINI
            aTail(oContValues["items"])['finalRange'] 	:= (cAlias)->N77_FAIFIM            
            aTail(oContValues["items"])['deleted']  	:= .F.
                        
            (cAlias)->(DbSkip())
        End
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oContValues["hasNext"] := lHasNext
        
        cResponse := EncodeUTF8(FWJsonSerialize(oContValues, .F., .F., .T.))
        ::SetResponse(cResponse)
    Else
        cResponse := FWJsonSerialize(oContValues, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf
    
    (cAlias)->(DbCloseArea())
Return lPost

WSMETHOD GET GetVDiff QUERYPARAM page, pageSize PATHPARAM dateDiff WSSERVICE UBAW03
	Local lPost        := .T.
	Local oContValues  := JsonObject():New()	
	Local cDateDiff	   := ::dateDiff
	Local aData		   := {}
	Local cData		   := ""
	Local cHora		   := ""
	Local lDelete	   := .F.
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
    
    oContValues["hasNext"] := .F.
    oContValues["items"]   := Array(0)
    oContValues["totvs_sync_date"] := cDateTime
    
    aData := FWDateTimeToLocal(cDateDiff)
               
    cAlias := GetNextAlias()
    cQuery := " SELECT N77.R_E_C_N_O_, " 
    cQuery += "        N77.N77_CODCTM, "
    cQuery += "        N77.N77_SEQ, "
    cQuery += "    	   N77.N77_RESULT, "
    cQuery += "    	   N77.N77_FAIINI, "
    cQuery += "    	   N77.N77_FAIFIM, "
    cQuery += "        (CASE WHEN N77.D_E_L_E_T_ = '*' THEN 1 ELSE 2 END) AS DELN77, "
    cQuery += "        N76.N76_SITCON, "
    cQuery += "        N76.N76_DISPWS, "
    cQuery += "        N77.N77_DATINC, "
	cQuery += "        N77.N77_HORINC "    
    cQuery += "   FROM " + RetSqlName("N77") + " N77 "
    cQuery += " INNER JOIN " + RetSqlName("N76") + " N76 ON N76.N76_FILIAL = N77.N77_FILIAL "
    cQuery += "   AND N76.N76_CODIGO = N77.N77_CODCTM "
    
    cData := Year2Str(Year(aData[1])) + Month2Str(Month(aData[1])) + Day2Str(Day(aData[1]))
    cHora := aData[2]
    
    cQuery += " WHERE (((N77.N77_DATINC > '"+cData+"') OR (N77.N77_DATINC = '"+cData+"' AND N77.N77_HORINC >= '"+cHora+"')) "
    cQuery += "     OR ((N77.N77_DATATU > '"+cData+"') OR (N77.N77_DATATU = '"+cData+"' AND N77.N77_HORATU >= '"+cHora+"')) "
    cQuery += "     OR ((N76.N76_DATATU > '"+cData+"') OR (N76.N76_DATATU = '"+cData+"' AND N76.N76_HORATU >= '"+cHora+"'))) "
        	
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
                       
            lDelete := .F.
            
            If (cAlias)->DELN77 = 1 .OR. (cAlias)->N76_SITCON == "2" .OR. (cAlias)->N76_DISPWS == "2"
            	lDelete := .T.
            EndIf  
            
            // Caso seja para enviar o valor do contaminante como deletado, verifica se o mesmo foi incluído depois da última
        	// sincronização, caso o mesmo tenha sido incluído, não será enviado para o aplicativo
        	If lDelete .AND. (((cAlias)->N77_DATINC > cData) .OR.;
        		((cAlias)->N77_DATINC = cData .AND. (cAlias)->N77_HORINC >= cHora))
        		(cAlias)->(DbSkip())
        		LOOP        		
        	EndIf   
        	
        	Aadd(oContValues["items"], JsonObject():New())      
            
            aTail(oContValues["items"])['recno']      	:= (cAlias)->R_E_C_N_O_
            aTail(oContValues["items"])['contaminant']  := (cAlias)->N77_CODCTM
            aTail(oContValues["items"])['sequence']     := (cAlias)->N77_SEQ
            aTail(oContValues["items"])['result']       := (cAlias)->N77_RESULT
            aTail(oContValues["items"])['initialRange'] := (cAlias)->N77_FAIINI
            aTail(oContValues["items"])['finalRange'] 	:= (cAlias)->N77_FAIFIM            
            aTail(oContValues["items"])['deleted']  	:= lDelete
                        
            (cAlias)->(DbSkip())
        End
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oContValues["hasNext"] := lHasNext
        
        cResponse := EncodeUTF8(FWJsonSerialize(oContValues, .F., .F., .T.))
        ::SetResponse(cResponse)
    Else
        cResponse := FWJsonSerialize(oContValues, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf
    
    (cAlias)->(DbCloseArea())
Return lPost
