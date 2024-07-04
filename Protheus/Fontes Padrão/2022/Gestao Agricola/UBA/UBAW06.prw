#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

WSRESTFUL UBAW06 DESCRIPTION "Cadastro de Remessas - N72"

WSDATA dateDiff AS STRING OPTIONAL 
WSDATA page     AS INTEGER OPTIONAL
WSDATA pageSize AS INTEGER OPTIONAL

WSMETHOD GET 		 DESCRIPTION "Retorna uma lista de remessas" 		PATH "/v1/shipments" 		  		 PRODUCES APPLICATION_JSON
WSMETHOD GET GetDiff DESCRIPTION "Retorna uma lista de remessas - Diff" PATH "/v1/shipments/diff/{dateDiff}" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET QUERYPARAM page, pageSize WSSERVICE UBAW06
	Local lPost  	 := .T.
	Local oShipping  := JsonObject():New()
	Local cDateTime	 := ""
	Local oPage      := {}
	Local nPage 	 := IIf(!Empty(::page),::page,1)
	Local nPageSize  := IIf(!Empty(::pageSize),::pageSize,30)
	Local nCount	 := 0
	Local lHasNext	 := .F.
	
	oPage := FwPageCtrl():New(nPageSize,nPage)
	
	// Coloca a data e hora atual
	// Formato UTC aaaa-mm-ddThh:mm:ss-+Time Zone (coloca a hora local + o timezone (ISO 8601))
	cDateTime := FWTimeStamp(5)
    
    ::SetContentType("application/json")
    
    oShipping["hasNext"] := .F.
    oShipping["items"]   := Array(0)
    oShipping["totvs_sync_date"] := cDateTime
          
    cAlias := GetNextAlias()
    cQuery := " SELECT N72.R_E_C_N_O_, " 
    cQuery += "        N72.N72_FILIAL, "
    cQuery += "    	   N72.N72_SAFRA, "
    cQuery += "    	   N72.N72_CODREM, "
    cQuery += "    	   N72.N72_CODBAR, "
    cQuery += "    	   N72.N72_STATUS "    
    cQuery += " FROM " + RetSqlName("N72") + " N72 "
    cQuery += " WHERE N72.N72_STATUS IN ('2','3','4') " // 2=Enviada; 3=Entregue; 4=Entregue Parcial;
    cQuery += "   AND N72.N72_TIPO = '1' " // 1=Visual
    cQuery += "   AND N72.D_E_L_E_T_ <> '*' "
    
    // Condição abaixo: Considera apenas as remesas que possuem malas com classificação visual pendente
    // Caso já tenha iniciado o processo de classificação (Visual Parcial) a remessa não será mais considerada
    cQuery += "   AND EXISTS (SELECT 1 "
    cQuery += "   	            FROM " + RetSqlName("N73") + " N73 "
    cQuery += "                INNER JOIN " + RetSqlName("DXJ") + " DXJ ON DXJ_FILIAL = N73_FILIAL AND DXJ_CODIGO = N73_CODMAL "
    cQuery += "                  AND DXJ_TIPO = N73_TIPO AND DXJ.D_E_L_E_T_ <> '*' "
    cQuery += "                WHERE N73.N73_FILIAL = N72.N72_FILIAL "
    cQuery += "                  AND N73.N73_CODSAF = N72.N72_SAFRA "
    cQuery += "                  AND N73.N73_CODREM = N72.N72_CODREM "
    cQuery += "                  AND N73.D_E_L_E_T_ <> '*' "
    cQuery += "                  AND DXJ.DXJ_STATUS = '1') "
    	
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
        
        	Aadd(oShipping["items"], JsonObject():New())
        
            aTail(oShipping["items"])['recno']   	:= (cAlias)->R_E_C_N_O_
            aTail(oShipping["items"])['branchCode'] := Alltrim((cAlias)->N72_FILIAL)
            aTail(oShipping["items"])['crop']    	:= Alltrim((cAlias)->N72_SAFRA)
            aTail(oShipping["items"])['code'] 	 	:= Alltrim((cAlias)->N72_CODREM)
            aTail(oShipping["items"])['barCode'] 	:= Alltrim((cAlias)->N72_CODBAR)           
            aTail(oShipping["items"])['status']	 	:= (cAlias)->N72_STATUS            
            aTail(oShipping["items"])['deleted'] 	:= .F.
            
            (cAlias)->(DbSkip())
        End
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oShipping["hasNext"] := lHasNext
        
        cResponse := EncodeUTF8(FWJsonSerialize(oShipping, .F., .F., .T.))
        ::SetResponse(cResponse)
    Else
        cResponse := FWJsonSerialize(oShipping, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf
    
    (cAlias)->(DbCloseArea())
Return lPost

WSMETHOD GET GetDiff QUERYPARAM page, pageSize PATHPARAM dateDiff WSSERVICE UBAW06
	Local lPost        := .T.
	Local oShipping    := JsonObject():New()
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
    
    oShipping["hasNext"] := .F.
    oShipping["items"]   := Array(0)
    oShipping["totvs_sync_date"] := cDateTime
          
    cAlias := GetNextAlias()
    cQuery := " SELECT N72.R_E_C_N_O_, " 
    cQuery += "        N72.N72_FILIAL, "
    cQuery += "    	   N72.N72_SAFRA, "
    cQuery += "    	   N72.N72_CODREM, "
    cQuery += "    	   N72.N72_CODBAR, "
    cQuery += "    	   N72.N72_STATUS, "
    cQuery += "        (CASE WHEN N72.D_E_L_E_T_ = '*' THEN 1 ELSE 2 END) AS DELN72, "
    cQuery += "    	   N72.N72_DATA, "
    cQuery += "    	   N72.N72_HORA "    
    cQuery += " FROM " + RetSqlName("N72") + " N72 "
    cQuery += "  WHERE N72.N72_TIPO = '1' " // 1=Visual 
    
    cData := Year2Str(Year(aData[1])) + Month2Str(Month(aData[1])) + Day2Str(Day(aData[1]))
	cHora := aData[2] 
    
    cQuery += "    AND (((N72.N72_DATATU > '"+cData+"') OR (N72.N72_DATATU = '"+cData+"' AND N72.N72_HORATU >= '"+cHora+"')) "
    cQuery += "    OR EXISTS (SELECT 1 "
    cQuery += "   	            FROM " + RetSqlName("N73") + " N73 "
    cQuery += "                INNER JOIN " + RetSqlName("DXJ") + " DXJ ON DXJ.DXJ_FILIAL = N73.N73_FILIAL "
    cQuery += "                  AND DXJ.DXJ_CODIGO = N73.N73_CODMAL AND DXJ.DXJ_TIPO = N73.N73_TIPO AND DXJ.D_E_L_E_T_ <> '*' "
    cQuery += "                WHERE N73.N73_FILIAL = N72.N72_FILIAL "
    cQuery += "                  AND N73.N73_CODSAF = N72.N72_SAFRA "
    cQuery += "                  AND N73.N73_CODREM = N72.N72_CODREM "
    cQuery += "                  AND N73.D_E_L_E_T_ <> '*' "
    cQuery += "                  AND ((DXJ.DXJ_DATATU > '"+cData+"') OR (DXJ.DXJ_DATATU = '"+cData+"' AND DXJ.DXJ_HORATU >= '"+cHora+"')))) "
            
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
        
        	If (cAlias)->DELN72 = 1 .OR. !(cAlias)->N72_STATUS $ "2|3|4" .Or.;
        		UBW06StMl((cAlias)->N72_FILIAL, (cAlias)->N72_SAFRA, (cAlias)->N72_CODREM)
        		
        		lDeletado := .T.        	
        	EndIf
        	
        	// Caso seja para enviar a remessa como deletada, verifica se a mesma foi incluída depois da última
        	// sincronização, caso tenha sido incluída, não será enviada para o aplicativo
        	If lDeletado .AND. (((cAlias)->N72_DATA > cData) .OR.;
        		((cAlias)->N72_DATA = cData .AND. (cAlias)->N72_HORA >= cHora))
        		(cAlias)->(DbSkip())
        		LOOP        		
        	EndIf
        
        	Aadd(oShipping["items"], JsonObject():New())
        
            aTail(oShipping["items"])['recno']   	:= (cAlias)->R_E_C_N_O_
            aTail(oShipping["items"])['branchCode'] := Alltrim((cAlias)->N72_FILIAL)
            aTail(oShipping["items"])['crop']    	:= Alltrim((cAlias)->N72_SAFRA)
            aTail(oShipping["items"])['code'] 	 	:= Alltrim((cAlias)->N72_CODREM)
            aTail(oShipping["items"])['barCode'] 	:= Alltrim((cAlias)->N72_CODBAR)           
            aTail(oShipping["items"])['status']	 	:= (cAlias)->N72_STATUS            
            aTail(oShipping["items"])['deleted'] 	:= lDeletado
            
            (cAlias)->(DbSkip())
        End
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oShipping["hasNext"] := lHasNext
        
        cResponse := EncodeUTF8(FWJsonSerialize(oShipping, .F., .F., .T.))
        ::SetResponse(cResponse)
    Else
        cResponse := FWJsonSerialize(oShipping, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf

	(cAlias)->(DbCloseArea())
Return lPost

/**---------------------------------------------------------------------
{Protheus.doc} UBW06StMl
Verifica o status das malas vinculadas a remessa, caso possua alguma mala com status
1 - Visual Pendente, retornará .F., caso não possua retornará .T. 

@param:  cFilRem, character, Filial da Remessa
@param:  cSafra, character, Safra da Remessa
@param:  cCodRem, character, Código da Remessa
@author: francisco.nunes
@since: 29/06/2018
---------------------------------------------------------------------**/
Static Function UBW06StMl(cFilRem, cSafra, cCodRem)
	Local lRet 		 := .F.
	Local cAliasMala := ""
	Local cQueryMala := ""
		
	// Considera apenas as remesas que possuem malas com classificação visual pendente
    // Caso já tenha iniciado o processo de classificação (Visual Parcial) a remessa não será mais considerada
    cAliasMala := GetNextAlias()
    cQueryMala := "   SELECT 1 "
    cQueryMala += "     FROM " + RetSqlName("N73") + " N73 "
    cQueryMala += "    INNER JOIN " + RetSqlName("DXJ") + " DXJ ON DXJ.DXJ_FILIAL = N73.N73_FILIAL " 
    cQueryMala += "      AND DXJ.DXJ_CODIGO = N73.N73_CODMAL AND DXJ.DXJ_TIPO = N73.N73_TIPO AND DXJ.D_E_L_E_T_ <> '*' "
    cQueryMala += "    WHERE N73.N73_FILIAL = '" + cFilRem + "' "
    cQueryMala += "      AND N73.N73_CODSAF = '" + cSafra + "' "
    cQueryMala += "      AND N73.N73_CODREM = '" + cCodRem + "' "
    cQueryMala += "      AND N73.D_E_L_E_T_ <> '*' "
    cQueryMala += "      AND DXJ.DXJ_STATUS = '1' "
    
    cQueryMala := ChangeQuery(cQueryMala)
    MPSysOpenQuery(cQueryMala, cAliasMala)
    
    If (cAliasMala)->(!Eof())
    	lRet := .F.
    Else
    	lRet := .T.
    EndIf	

Return lRet
