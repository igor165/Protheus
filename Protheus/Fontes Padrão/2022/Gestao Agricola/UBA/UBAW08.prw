#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
 
WSRESTFUL UBAW08 DESCRIPTION "Cadastro de Fardos - DXI"

WSDATA dateDiff AS STRING  OPTIONAL
WSDATA page     AS INTEGER OPTIONAL
WSDATA pageSize AS INTEGER OPTIONAL

WSMETHOD GET 		 DESCRIPTION "Retorna uma lista de fardos" 		  PATH "/v1/bales" 	    		   PRODUCES APPLICATION_JSON
WSMETHOD GET GetDiff DESCRIPTION "Retorna uma lista de fardos - Diff" PATH "/v1/bales/diff/{dateDiff}" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET QUERYPARAM page, pageSize WSSERVICE UBAW08
	Local lPost     := .T.
	Local oBale     := JsonObject():New()
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
    
    oBale["hasNext"] := .F.
    oBale["items"]   := Array(0)
    oBale["totvs_sync_date"] := cDateTime
    
    cAlias := GetNextAlias()
    cQuery := " SELECT DXI.R_E_C_N_O_, " 
    cQuery += "        DXI.DXI_FILIAL, "
    cQuery += "    	   DXI.DXI_SAFRA, "
    cQuery += "    	   DXI.DXI_CODIGO, "
    cQuery += "    	   DXI.DXI_ETIQ, "
    cQuery += "    	   DXK.DXK_FILIAL, "
    cQuery += "    	   DXK.DXK_CODROM, "
    cQuery += "    	   DXI.DXI_BLOCO, "
    cQuery += "    	   DXI.DXI_STATUS, "
    cQuery += "    	   DXD.DXD_DATAEM, "
    cQuery += "    	   DXD.DXD_STATUS "
    cQuery += "   FROM " + RetSqlName("DXI") + " DXI "
    cQuery += " INNER JOIN " + RetSqlName("DXK") + " DXK ON DXK.DXK_SAFRA = DXI.DXI_SAFRA AND DXK.DXK_ETIQ = DXI.DXI_ETIQ " 
    cQuery += "   AND DXK.DXK_TIPO = '1' AND DXK.D_E_L_E_T_ <> '*' "
    cQuery += " INNER JOIN " + RetSqlName("DXJ") + " DXJ ON DXJ.DXJ_FILIAL = DXK.DXK_FILIAL AND DXJ.DXJ_CODIGO = DXK.DXK_CODROM "
    cQuery += "  AND DXJ.DXJ_TIPO = DXK.DXK_TIPO AND DXJ.D_E_L_E_T_ <> '*' "
    cQuery += "  LEFT JOIN " + RetSqlName("DXD") + " DXD ON DXD.DXD_FILIAL = DXI.DXI_FILIAL AND DXD.DXD_SAFRA = DXI.DXI_SAFRA "
    cQuery += "  AND DXD.DXD_CODIGO = DXI.DXI_BLOCO AND DXD.D_E_L_E_T_ <> '*' "
    cQuery += "  WHERE DXI.D_E_L_E_T_ <> '*' "
    cQuery += "    AND DXI.DXI_EMBFIS != '1' "
    cQuery += "    AND DXJ.DXJ_DATENV <> '' "
    	
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
        
            Aadd(oBale["items"], JsonObject():New())
            
            aTail(oBale["items"])['recno']        := (cAlias)->R_E_C_N_O_
            aTail(oBale["items"])['branchCode']   := Alltrim((cAlias)->DXI_FILIAL)
            aTail(oBale["items"])['crop']         := Alltrim((cAlias)->DXI_SAFRA)
            aTail(oBale["items"])['code'] 		  := Alltrim((cAlias)->DXI_CODIGO)
            aTail(oBale["items"])['barCode'] 	  := Alltrim((cAlias)->DXI_ETIQ)
            aTail(oBale["items"])['caseBranch']	  := Alltrim((cAlias)->DXK_FILIAL)
            aTail(oBale["items"])['caseCode']	  := Alltrim((cAlias)->DXK_CODROM)
            aTail(oBale["items"])['packCode']	  := Alltrim((cAlias)->DXI_BLOCO)
            aTail(oBale["items"])['status']		  := AllTrim((cAlias)->DXI_STATUS)
            aTail(oBale["items"])['packDate']	  := AllTrim((cAlias)->DXD_DATAEM)            
            aTail(oBale["items"])['embedding'] 	  := IIf(AllTrim((cAlias)->DXD_STATUS) == "5", .T., .F.)
            aTail(oBale["items"])['deleted']  	  := .F.
            
            (cAlias)->(DbSkip())
        EndDo
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oBale["hasNext"] := lHasNext
        
        cResponse := EncodeUTF8(FWJsonSerialize(oBale, .F., .F., .T.))
        ::SetResponse(cResponse)
    Else
        cResponse := FWJsonSerialize(oBale, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf
    
    (cAlias)->(DbCloseArea())
Return lPost

WSMETHOD GET GetDiff QUERYPARAM page, pageSize PATHPARAM dateDiff WSSERVICE UBAW08
	Local lPost        := .T.
	Local oBale		   := JsonObject():New()
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
	
    ::SetContentType("application/json")
    
    aData := FWDateTimeToLocal(cDateDiff)
    
    oBale["hasNext"] := .F.
    oBale["items"]   := Array(0)
    oBale["totvs_sync_date"] := cDateTime
    
    cAlias := GetNextAlias()
    cQuery := " SELECT DXI.R_E_C_N_O_, " 
    cQuery += "        DXI.DXI_FILIAL, "
    cQuery += "    	   DXI.DXI_SAFRA, "
    cQuery += "    	   DXI.DXI_CODIGO, "
    cQuery += "    	   DXI.DXI_ETIQ, "      
    cQuery += "    	   DXI.DXI_BLOCO, "
    cQuery += "    	   DXI.DXI_STATUS, "
    cQuery += "    	   DXI.DXI_EMBFIS, "
    cQuery += "    	   DXJ.DXJ_FILIAL, "
    cQuery += "    	   DXJ.DXJ_CODIGO, "
    cQuery += "        DXJ.DXJ_DATENV, "   
    cQuery += "    	   DXD.DXD_DATAEM, "
    cQuery += "    	   DXD.DXD_STATUS, " 
    cQuery += "        (CASE WHEN DXI.D_E_L_E_T_ = '*' THEN 1 ELSE 2 END) AS DELDXI "    
    cQuery += "   FROM " + RetSqlName("DXI") + " DXI "
    cQuery += " LEFT JOIN " + RetSqlName("DXK") + " DXK ON DXK.DXK_SAFRA = DXI.DXI_SAFRA AND DXK.DXK_ETIQ = DXI.DXI_ETIQ "
    cQuery += "  AND DXK.DXK_TIPO = '1' AND DXK.D_E_L_E_T_ <> '*' "
    cQuery += " LEFT JOIN " + RetSqlName("DXJ") + " DXJ ON DXJ.DXJ_FILIAL = DXK.DXK_FILIAL AND DXJ.DXJ_CODIGO = DXK.DXK_CODROM "
    cQuery += "  AND DXJ.DXJ_TIPO = DXK.DXK_TIPO AND DXJ.D_E_L_E_T_ <> '*' "
    cQuery += "  LEFT JOIN " + RetSqlName("DXD") + " DXD ON DXD.DXD_FILIAL = DXI.DXI_FILIAL AND DXD.DXD_SAFRA = DXI.DXI_SAFRA "
    cQuery += "  AND DXD.DXD_CODIGO = DXI.DXI_BLOCO AND DXD.D_E_L_E_T_ <> '*' "
        
    cData := Year2Str(Year(aData[1])) + Month2Str(Month(aData[1])) + Day2Str(Day(aData[1]))
	cHora := aData[2] 
    
    cQuery += "  WHERE (((DXI.DXI_DATATU > '"+cData+"') OR (DXI.DXI_DATATU = '"+cData+"' AND DXI.DXI_HORATU >= '"+cHora+"')) "
    cQuery += "     OR  ((DXJ.DXJ_DATATU > '"+cData+"') OR (DXJ.DXJ_DATATU = '"+cData+"' AND DXJ.DXJ_HORATU >= '"+cHora+"'))) "
        	
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
        	
        	If (cAlias)->DELDXI = 1 .OR. Empty((cAlias)->DXJ_CODIGO) .OR. Empty((cAlias)->DXJ_DATENV) .OR.; 
        	   (cAlias)->DXI_EMBFIS == "1"       		
        		lDeletado := .T.
        	EndIf
        
            Aadd(oBale["items"], JsonObject():New())
            
            aTail(oBale["items"])['recno']      := (cAlias)->R_E_C_N_O_
            aTail(oBale["items"])['branchCode'] := Alltrim((cAlias)->DXI_FILIAL)
            aTail(oBale["items"])['crop']       := Alltrim((cAlias)->DXI_SAFRA)
            aTail(oBale["items"])['code'] 		:= Alltrim((cAlias)->DXI_CODIGO)
            aTail(oBale["items"])['barCode'] 	:= Alltrim((cAlias)->DXI_ETIQ)
            aTail(oBale["items"])['caseBranch']	:= Alltrim((cAlias)->DXJ_FILIAL)
            aTail(oBale["items"])['caseCode']	:= Alltrim((cAlias)->DXJ_CODIGO)
            aTail(oBale["items"])['packCode']	:= Alltrim((cAlias)->DXI_BLOCO)
            aTail(oBale["items"])['status']		:= AllTrim((cAlias)->DXI_STATUS) 
            aTail(oBale["items"])['packDate']	:= AllTrim((cAlias)->DXD_DATAEM)            
            aTail(oBale["items"])['embedding'] 	:= IIf(AllTrim((cAlias)->DXD_STATUS) == "5", .T., .F.)        
            aTail(oBale["items"])['deleted']  	:= lDeletado
            
            (cAlias)->(DbSkip())
        EndDo
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oBale["hasNext"] := lHasNext
    
    	cResponse := EncodeUTF8(FWJsonSerialize(oBale, .F., .F., .T.))
        ::SetResponse(cResponse)
    Else
        cResponse := FWJsonSerialize(oBale, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf

	(cAlias)->(DbCloseArea())
Return lPost
