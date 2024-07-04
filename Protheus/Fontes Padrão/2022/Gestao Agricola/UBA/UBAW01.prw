#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

WSRESTFUL UBAW01 DESCRIPTION "Cadastro de Classificadores - NNA"

WSDATA dateDiff AS STRING OPTIONAL
WSDATA page     AS INTEGER OPTIONAL
WSDATA pageSize AS INTEGER OPTIONAL

WSMETHOD GET 		 DESCRIPTION "Retorna uma lista de classificadores" 	   PATH "/v1/classifiers" 				  PRODUCES APPLICATION_JSON
WSMETHOD GET GetDiff DESCRIPTION "Retorna uma lista de classificadores - Diff" PATH "/v1/classifiers/diff/{dateDiff}" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET QUERYPARAM page, pageSize WSSERVICE UBAW01
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
    cQuery := " SELECT NNA.R_E_C_N_O_, " 
    cQuery += "        NNA.NNA_CODIGO, "
    cQuery += "    	   NNA.NNA_NOME "
    cQuery += " FROM " + RetSqlName("NNA") + " NNA "
    cQuery += " WHERE NNA.D_E_L_E_T_ <> '*' "
    	
	cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)
    
    oClassifier["hasNext"] := .F.
    oClassifier["items"]   := Array(0)
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
           
        	Aadd(oClassifier["items"], JsonObject():New())
                
            aTail(oClassifier["items"])['recno']    := (cAlias)->R_E_C_N_O_
            aTail(oClassifier["items"])['code']     := Alltrim((cAlias)->NNA_CODIGO)
            aTail(oClassifier["items"])['name']     := Alltrim((cAlias)->NNA_NOME)
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

WSMETHOD GET GetDiff QUERYPARAM page, pageSize PATHPARAM dateDiff WSSERVICE UBAW01
	Local lPost        := .T.
	Local oClassifier  := JsonObject():New()
	Local cDateDiff	   := ::dateDiff
	Local lDeletado    := .F.
	Local cData		   := ""
	Local cHora		   := ""
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
	
	aData := FWDateTimeToLocal(cDateDiff)
		
    ::SetContentType("application/json")  
        
    cAlias := GetNextAlias()
    cQuery := " SELECT NNA.R_E_C_N_O_, " 
    cQuery += "        NNA.NNA_CODIGO, "
    cQuery += "    	   NNA.NNA_NOME, "
    cQuery += "        (CASE WHEN NNA.D_E_L_E_T_ = '*' THEN 1 ELSE 2 END) AS DELNNA, "
    cQuery += "        NNA.NNA_DATINC, "
	cQuery += "        NNA.NNA_HORINC "
    cQuery += " FROM " + RetSqlName("NNA") + " NNA "
           
	cData := Year2Str(Year(aData[1])) + Month2Str(Month(aData[1])) + Day2Str(Day(aData[1]))
	cHora := aData[2]

    cQuery += " WHERE (((NNA.NNA_DATINC > '"+cData+"') OR (NNA.NNA_DATINC = '"+cData+"' AND NNA.NNA_HORINC >= '"+cHora+"')) "
    cQuery += "     OR ((NNA.NNA_DATATU > '"+cData+"') OR (NNA.NNA_DATATU = '"+cData+"' AND NNA.NNA_HORATU >= '"+cHora+"'))) "
		     	
	cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)
    
    oClassifier["hasNext"] := .F.
    oClassifier["items"]   := Array(0)
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
        
        	lDeletado := IIf((cAlias)->DELNNA = 1, .T., .F.)
        	
        	// Caso seja para enviar o classificador como deletado, verifica se o mesmo foi incluído depois da última
        	// sincronização, caso o mesmo tenha sido incluído, não será enviado para o aplicativo
        	If lDeletado .AND. (((cAlias)->NNA_DATINC > cData) .OR.;
        		((cAlias)->NNA_DATINC = cData .AND. (cAlias)->NNA_HORINC >= cHora))
        		(cAlias)->(DbSkip())
        		LOOP        		
        	EndIf
        
        	Aadd(oClassifier["items"], JsonObject():New())
                
            aTail(oClassifier["items"])['recno']    := (cAlias)->R_E_C_N_O_
            aTail(oClassifier["items"])['code']     := Alltrim((cAlias)->NNA_CODIGO)
            aTail(oClassifier["items"])['name']     := Alltrim((cAlias)->NNA_NOME)
            aTail(oClassifier["items"])['deleted']  := lDeletado
                                               
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
