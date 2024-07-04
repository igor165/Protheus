#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
 
WSRESTFUL UBAW14 DESCRIPTION "Rest da Entidade Blocos para App"

WSDATA dateDiff AS STRING OPTIONAL
WSDATA page     AS INTEGER OPTIONAL
WSDATA pageSize AS INTEGER OPTIONAL

WSMETHOD GET 		 		DESCRIPTION "Retorna uma lista de blocos instruídos" 	   	   PATH "/v1/expeditionPacks" 				 		PRODUCES APPLICATION_JSON
WSMETHOD GET GetDiff 		DESCRIPTION "Retorna uma lista de blocos instruídos - Diff"    PATH "/v1/expeditionPacks/diff/{dateDiff}" 		PRODUCES APPLICATION_JSON
WSMETHOD GET SldPack        DESCRIPTION "Retorna uma lista de Blocos - Saldo Fardos"  	   PATH "/v1/expeditionPacks/sld/"                  PRODUCES APPLICATION_JSON
WSMETHOD GET SldDiff        DESCRIPTION "Retorna uma lista de Blocos - Saldo Fardos- Diff"  PATH "/v1/expeditionPacks/sld/diff/{dateDiff}"   PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET QUERYPARAM page, pageSize WSSERVICE UBAW14
	Local lPost        := .T.
	Local oPack		   := JsonObject():New()
	Local cDateTime	   := ""
	Local oPage        := {}
	Local nPage 	   := IIf(!Empty(::page),::page,1)
	Local nPageSize    := IIf(!Empty(::pageSize),::pageSize,30)
	Local nCount	   := 0
	Local lHasNext	   := .F.
	Local cDesIE	   := ""
	Local cAuts		   := ""
			
	oPage := FwPageCtrl():New(nPageSize,nPage)	
	
	// Coloca a data e hora atual
	// Formato UTC aaaa-mm-ddThh:mm:ss-+Time Zone (coloca a hora local + o timezone (ISO 8601))
	cDateTime := FWTimeStamp(5)	
	
	::SetContentType("application/json")
	
    cAlias := GetNextAlias()
	cQuery := " SELECT DXD.R_E_C_N_O_ DXDREC, DXD.DXD_FILIAL, DXD.DXD_SAFRA, DXD.DXD_CODIGO, DXD.DXD_LOCAL "
	cQuery += "   FROM " + RetSqlName("DXD") + " DXD "
	cQuery += "  WHERE DXD.D_E_L_E_T_ <> '*' "
	cQuery += "    AND EXISTS (SELECT DXI_CODIGO "
	cQuery += "                  FROM " + RetSqlName("DXI") + " DXI "
	cQuery += "                 WHERE DXI.D_E_L_E_T_ = '' "
	cQuery += "			  		  AND DXI.DXI_FILIAL = DXD.DXD_FILIAL "
	cQuery += "              	  AND DXI.DXI_SAFRA  = DXD.DXD_SAFRA "
	cQuery += "			  		  AND DXI.DXI_BLOCO  = DXD.DXD_CODIGO "
	cQuery += "			  		  AND DXI.DXI_STATUS IN ('90','100')) "
	cQuery += " UNION "
	cQuery += " SELECT DXD.R_E_C_N_O_ DXDREC, DXD.DXD_FILIAL, DXD.DXD_SAFRA, DXD.DXD_CODIGO, DXD.DXD_LOCAL "
	cQuery += "   FROM " + RetSqlName("DXD") + " DXD "
	cQuery += "  WHERE DXD.D_E_L_E_T_ <> '*' "
	cQuery += "    AND EXISTS (SELECT N83_BLOCO "
	cQuery += "			 		 FROM " + RetSqlName("N83") + " N83 "
	cQuery += "					WHERE N83.D_E_L_E_T_ <> '*' "
	cQuery += "			  		  AND N83.N83_FILORG = DXD.DXD_FILIAL "
	cQuery += "			  		  AND N83.N83_SAFRA	 = DXD.DXD_SAFRA "
	cQuery += "			  		  AND N83.N83_BLOCO  = DXD.DXD_CODIGO "
	cQuery += "			  		  AND N83.N83_FRDMAR = '2') "
   	cQuery += "    AND NOT EXISTS (SELECT N9D_BLOCO "
	cQuery += "				 		 FROM " + RetSqlName("N9D") + " N9D "
	cQuery += "						WHERE N9D.D_E_L_E_T_ <> '*' "
	cQuery += "			      		  AND N9D.N9D_FILIAL = DXD.DXD_FILIAL "
	cQuery += "			      		  AND N9D.N9D_SAFRA  = DXD.DXD_SAFRA "
	cQuery += "			      		  AND N9D.N9D_BLOCO  = DXD.DXD_CODIGO "
	cQuery += "				  		  AND N9D.N9D_TIPMOV = '04' "
	cQuery += "				  		  AND N9D.N9D_STATUS = '2') "
    	
	cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)	
	
	oPack["hasNext"]         := .F.
    oPack["items"]           := Array(0)
    oPack["totvs_sync_date"] := cDateTime
    
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

			cDesIE := BuscaIEs((cAlias)->DXD_FILIAL, (cAlias)->DXD_SAFRA, (cAlias)->DXD_CODIGO)
			cAuts  := BuscaAuts((cAlias)->DXD_FILIAL, (cAlias)->DXD_SAFRA, (cAlias)->DXD_CODIGO)
			            	
			Aadd(oPack["items"], JsonObject():New())
			
			aTail(oPack["items"])['recno']   	   := (cAlias)->DXDREC
			aTail(oPack["items"])['code']   	   := (cAlias)->DXD_CODIGO  
			aTail(oPack["items"])['crop']    	   := (cAlias)->DXD_SAFRA  
			aTail(oPack["items"])['instructions']  := cDesIE
			aTail(oPack["items"])['autorizations'] := cAuts
			aTail(oPack["items"])['local']	 	   := (cAlias)->DXD_LOCAL
			
			aTail(oPack["items"])['deleted']  := .F.		
	            	            		
			(cAlias)->(DbSkip())
        EndDo
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oPack["hasNext"] := lHasNext
        
        cResponse := EncodeUTF8(FWJsonSerialize(oPack, .F., .F., .T.))        
        ::SetResponse(cResponse)
        
    Else    
        cResponse := FWJsonSerialize(oPack, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf
    
     (cAlias)->(DbCloseArea())   
Return lPost

Static Function BuscaIEs(cFilBlc, cSafra, cBloco)

	Local cAliasIE := GetNextAlias()
	Local cQueryIE := ""
	Local cDesIE   := ""
		
	cQueryIE := " SELECT DISTINCT N7Q.N7Q_DESINE "
	cQueryIE += "   FROM " + RetSqlName("N9D") + " N9D "
	cQueryIE += " INNER JOIN " + RetSqlName("N7Q") + " N7Q ON N7Q.N7Q_FILIAL = N9D.N9D_FILORG AND N7Q.N7Q_CODINE = N9D.N9D_CODINE AND N7Q.D_E_L_E_T_ <> '*' "
	cQueryIE += "  WHERE N9D.D_E_L_E_T_ <> '*' "
	cQueryIE += "	 AND N9D.N9D_FILIAL = '" + cFilBlc + "' "
	cQueryIE += "	 AND N9D.N9D_SAFRA  = '" + cSafra + "' "
	cQueryIE += "	 AND N9D.N9D_BLOCO  = '" + cBloco + "' "
	cQueryIE += "	 AND N9D.N9D_TIPMOV = '04' "
	cQueryIE += "	 AND N9D.N9D_STATUS = '2' "
	cQueryIE += "    AND EXISTS (SELECT DXI_CODIGO "
	cQueryIE += "                  FROM " + RetSqlName("DXI") + " DXI "
	cQueryIE += "                 WHERE DXI.D_E_L_E_T_ = '' "
	cQueryIE += "			  		  AND DXI.DXI_FILIAL = N9D.N9D_FILIAL "
	cQueryIE += "              	  	  AND DXI.DXI_SAFRA  = N9D.N9D_SAFRA "
	cQueryIE += "			  		  AND DXI.DXI_BLOCO  = N9D.N9D_BLOCO "
	cQueryIE += "			  		  AND DXI.DXI_STATUS IN ('90','100')) "
	cQueryIE += " UNION "
	cQueryIE += " SELECT DISTINCT N7Q.N7Q_DESINE "
	cQueryIE += "   FROM " + RetSqlName("N83") + " N83 "
	cQueryIE += " INNER JOIN " + RetSqlName("N7Q") + " N7Q ON N7Q.N7Q_FILIAL = N83.N83_FILIAL AND N7Q.N7Q_CODINE = N83.N83_CODINE AND N7Q.D_E_L_E_T_ <> '*' "
	cQueryIE += "  WHERE N83.D_E_L_E_T_ <> '*' "
	cQueryIE += "	 AND N83.N83_FILORG = '" + cFilBlc + "' "
	cQueryIE += "	 AND N83.N83_SAFRA  = '" + cSafra + "' "
	cQueryIE += "	 AND N83.N83_BLOCO  = '" + cBloco + "' "
	cQueryIE += "	 AND N83.N83_FRDMAR = '2' "
	cQueryIE += "    AND NOT EXISTS (SELECT N9D_BLOCO "
	cQueryIE += "				 		 FROM " + RetSqlName("N9D") + " N9D "
	cQueryIE += "						WHERE N9D.D_E_L_E_T_ <> '*' "
	cQueryIE += "			      		  AND N9D.N9D_FILIAL = N83.N83_FILORG "
	cQueryIE += "			      		  AND N9D.N9D_SAFRA  = N83.N83_SAFRA "
	cQueryIE += "			      		  AND N9D.N9D_BLOCO  = N83.N83_BLOCO "
	cQueryIE += "                         AND N9D.N9D_FILORG = N83.N83_FILIAL "
	cQueryIE += "                         AND N9D.N9D_CODINE = N83.N83_CODINE "
	cQueryIE += "				  		  AND N9D.N9D_TIPMOV = '04' "
	cQueryIE += "				  		  AND N9D.N9D_STATUS = '2') "

	cQueryIE := ChangeQuery(cQueryIE)
	MPSysOpenQuery(cQueryIE, cAliasIE)

	cDesIE := ""

	If (cAliasIE)->(!Eof())    
		While (cAliasIE)->(!Eof()) 

			If At(Alltrim((cAliasIE)->N7Q_DESINE), cDesIE) > 0
				(cAliasIE)->(DbSkip())
				LOOP
			EndIf

			If Empty(cDesIE)
				cDesIE := Alltrim((cAliasIE)->N7Q_DESINE)
			Else
				cDesIE += "||" + Alltrim((cAliasIE)->N7Q_DESINE)
			EndIf

			(cAliasIE)->(DbSkip())
		EndDo
	EndIf
	
Return cDesIE

Static Function BuscaAuts(cFilBlc, cSafra, cBloco)

	Local cAliasAut := GetNextAlias()
	Local cQueryAut := ""
	Local cAuts     := ""
		
	cQueryAut := " SELECT DISTINCT N9D.N9D_FILORG AS FILAUT, N9D.N9D_CODAUT AS CODAUT, N9D.N9D_ITEMAC AS ITAUT "
	cQueryAut += "   FROM " + RetSqlName("N9D") + " N9D "	
	cQueryAut += "  WHERE N9D.D_E_L_E_T_ <> '*' "
	cQueryAut += "	  AND N9D.N9D_FILIAL = '" + cFilBlc + "' "
	cQueryAut += "	  AND N9D.N9D_SAFRA  = '" + cSafra + "' "
	cQueryAut += "	  AND N9D.N9D_BLOCO  = '" + cBloco + "' "
	cQueryAut += "	  AND N9D.N9D_TIPMOV = '10' "
	cQueryAut += "	  AND N9D.N9D_STATUS = '2' "
	cQueryAut += "    AND EXISTS (SELECT DXI_CODIGO "
	cQueryAut += "                  FROM " + RetSqlName("DXI") + " DXI "
	cQueryAut += "                 WHERE DXI.D_E_L_E_T_ = '' "
	cQueryAut += "			  		 AND DXI.DXI_FILIAL = N9D.N9D_FILIAL "
	cQueryAut += "              	 AND DXI.DXI_SAFRA  = N9D.N9D_SAFRA "
	cQueryAut += "			  		 AND DXI.DXI_BLOCO  = N9D.N9D_BLOCO "
	cQueryAut += "			  		 AND DXI.DXI_STATUS IN ('90','100')) "
	cQueryAut += " UNION "
	cQueryAut += " SELECT DISTINCT N8P.N8P_FILIAL AS FILAUT, N8P.N8P_CODAUT AS CODAUT, N8P.N8P_ITEMAC AS ITAUT "
	cQueryAut += "   FROM " + RetSqlName("N8P") + " N8P "	
	cQueryAut += "  WHERE N8P.D_E_L_E_T_ <> '*' "
	cQueryAut += "	  AND N8P.N8P_FILORG = '" + cFilBlc + "' "
	cQueryAut += "	  AND N8P.N8P_SAFRA  = '" + cSafra + "' "
	cQueryAut += "	  AND N8P.N8P_BLOCO  = '" + cBloco + "' "
	cQueryAut += "	  AND N8P.N8P_QTDAUT > 0 "
	cQueryAut += "    AND NOT EXISTS (SELECT N9D_BLOCO "
	cQueryAut += "				 		FROM " + RetSqlName("N9D") + " N9D "
	cQueryAut += "					   WHERE N9D.D_E_L_E_T_ <> '*' "
	cQueryAut += "			      		 AND N9D.N9D_FILIAL = N8P.N8P_FILORG "
	cQueryAut += "			      		 AND N9D.N9D_SAFRA  = N8P.N8P_SAFRA "
	cQueryAut += "			      		 AND N9D.N9D_BLOCO  = N8P.N8P_BLOCO "
	cQueryAut += "                       AND N9D.N9D_FILORG = N8P.N8P_FILIAL "
	cQueryAut += "                       AND N9D.N9D_CODAUT = N8P.N8P_CODAUT "
	cQueryAut += "                       AND N9D.N9D_ITEMAC = N8P.N8P_ITEMAC "
	cQueryAut += "				  		 AND N9D.N9D_TIPMOV = '10' "
	cQueryAut += "				  		 AND N9D.N9D_STATUS = '2') "

	cQueryAut := ChangeQuery(cQueryAut)
	MPSysOpenQuery(cQueryAut, cAliasAut)

	cAuts := ""
	
	If (cAliasAut)->(!Eof())    
		While (cAliasAut)->(!Eof()) 
					

			If At(Alltrim((cAliasAut)->FILAUT+(cAliasAut)->CODAUT+(cAliasAut)->ITAUT), cAuts) > 0
				(cAliasAut)->(DbSkip())
				LOOP
			EndIf

			If Empty(cAuts)
				cAuts := Alltrim((cAliasAut)->FILAUT+(cAliasAut)->CODAUT+(cAliasAut)->ITAUT)
			Else
				cAuts += "||" + Alltrim((cAliasAut)->FILAUT+(cAliasAut)->CODAUT+(cAliasAut)->ITAUT)
			EndIf

			(cAliasAut)->(DbSkip())
		EndDo
	EndIf

Return cAuts

WSMETHOD GET GetDiff QUERYPARAM page, pageSize PATHPARAM dateDiff WSSERVICE UBAW14

	Local lPost        := .T.
	Local oPack  	   := JsonObject():New()
	Local cDateTime	   := ""
	Local cDateDiff	   := ::dateDiff
	Local oPage        := {}
	Local nPage 	   := IIf(!Empty(::page),::page,1)
	Local nPageSize    := IIf(!Empty(::pageSize),::pageSize,30)
	Local nCount	   := 0
	Local lHasNext	   := .F.
	Local cDesIE	   := ""
	Local cAuts        := ""
			
	oPage := FwPageCtrl():New(nPageSize,nPage)	
	
	// Coloca a data e hora atual
	// Formato UTC aaaa-mm-ddThh:mm:ss-+Time Zone (coloca a hora local + o timezone (ISO 8601))
	cDateTime := FWTimeStamp(5)	

	aData := FWDateTimeToLocal(cDateDiff)
	
	::SetContentType("application/json")

	oPack["hasNext"]         := .F.
    oPack["items"]           := Array(0)
    oPack["totvs_sync_date"] := cDateTime
	
    cAlias := GetNextAlias()
	cQuery := " SELECT DXD.R_E_C_N_O_ DXDREC, DXD.DXD_FILIAL, DXD.DXD_SAFRA, DXD.DXD_CODIGO, DXD.DXD_LOCAL, "
	cQuery += "        (CASE WHEN DXD.D_E_L_E_T_ = '*' THEN 1 ELSE 2 END) AS DELDXD "
	cQuery += "   FROM " + RetSqlName("DXD") + " DXD "

	cData := Year2Str(Year(aData[1])) + Month2Str(Month(aData[1])) + Day2Str(Day(aData[1]))
	cHora := aData[2] 

	cQuery += "  WHERE ((DXD.DXD_DATATU > '"+cData+"') OR (DXD.DXD_DATATU = '"+cData+"' AND DXD.DXD_HORATU >= '"+cHora+"')) "
    		
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

			cDesIE := BuscaIEs((cAlias)->DXD_FILIAL, (cAlias)->DXD_SAFRA, (cAlias)->DXD_CODIGO)
			cAuts  := BuscaAuts((cAlias)->DXD_FILIAL, (cAlias)->DXD_SAFRA, (cAlias)->DXD_CODIGO)

			lDeletado := .F.

			If (cAlias)->DELDXD = 1  .OR. Empty(cDesIE)
				lDeletado := .T.
			EndIf

			Aadd(oPack["items"], JsonObject():New())
			
			aTail(oPack["items"])['recno']   	   := (cAlias)->DXDREC
			aTail(oPack["items"])['code']   	   := (cAlias)->DXD_CODIGO  
			aTail(oPack["items"])['crop']    	   := (cAlias)->DXD_SAFRA  
			aTail(oPack["items"])['instructions']  := cDesIE
			aTail(oPack["items"])['autorizations'] := cAuts
			aTail(oPack["items"])['local']	 	   := (cAlias)->DXD_LOCAL
			
			aTail(oPack["items"])['deleted']  := lDeletado		
	            	            		
			(cAlias)->(DbSkip())
        EndDo
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oPack["hasNext"] := lHasNext
        
        cResponse := EncodeUTF8(FWJsonSerialize(oPack, .F., .F., .T.))        
        ::SetResponse(cResponse)
        
    Else    
        cResponse := FWJsonSerialize(oPack, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf
    
     (cAlias)->(DbCloseArea())   
Return lPost




WSMETHOD GET SldPack QUERYPARAM page, pageSize WSSERVICE UBAW14
	Local lPost        := .T.
	Local oSldPack	   := JsonObject():New()
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
    cQuery := " SELECT 'N83' TYPE, N83.R_E_C_N_O_ REC, N83.N83_FILIAL FILIAL, N83.N83_CODINE COD, '' ITEM, N83.N83_FILORG FILIAL_BLC, "
    cQuery += "        N83.N83_BLOCO BLOCO, N83.N83_SAFRA SAFRA, N83.N83_QUANT QTD "    
    cQuery += "   FROM " + RetSqlName("N83") + " N83 "
    cQuery += "  WHERE (SELECT COUNT(*) "
    cQuery += "           FROM " + RetSqlName("N9D") + " N9D "
    cQuery += "          WHERE N9D.N9D_FILIAL = N83.N83_FILORG "
	cQuery += "			   AND N9D.N9D_SAFRA  = N83.N83_SAFRA "
	cQuery += "			   AND N9D.N9D_BLOCO  = N83.N83_BLOCO "
    cQuery += "            AND N9D.N9D_FILORG = N83.N83_FILIAL " 
    cQuery += "            AND N9D.N9D_CODINE = N83.N83_CODINE "
    cQuery += "            AND N9D.N9D_TIPMOV = '04' "
    cQuery += "            AND N9D.N9D_STATUS <> '3' "
    cQuery += "            AND N9D.D_E_L_E_T_ <> '*') < N83.N83_QUANT "
    cQuery += "    AND N83.N83_FRDMAR = '2' "
    cQuery += "    AND N83.D_E_L_E_T_ <> '*'  "
	cQuery += " UNION "
	cQuery += "	SELECT 'N8P' TYPE, N8P.R_E_C_N_O_ REC, N8P.N8P_FILIAL FILIAL, N8P.N8P_CODAUT COD, N8P.N8P_ITEMAC ITEM, N8P.N8P_FILORG FILIAL_BLC, "
	cQuery += " 	   N8P.N8P_BLOCO BLOCO, N8P.N8P_SAFRA SAFRA, N8P.N8P_QTDAUT QTD "	
	cQuery += "   FROM " + RetSqlName("N8P") + " N8P "
	cQuery += "  WHERE (SELECT COUNT(*) "
	cQuery += "           FROM " + RetSqlName("N9D") + " N9D " 
	cQuery += "			 WHERE N9D.N9D_FILIAL = N8P.N8P_FILORG "
	cQuery += "			   AND N9D.N9D_SAFRA  = N8P.N8P_SAFRA "
	cQuery += "			   AND N9D.N9D_BLOCO  = N8P.N8P_BLOCO "
	cQuery += "            AND N9D.N9D_FILORG = N8P.N8P_FILIAL "
	cQuery += "            AND N9D.N9D_CODAUT = N8P.N8P_CODAUT "
	cQuery += "            AND N9D.N9D_ITEMAC = N8P.N8P_ITEMAC "
	cQuery += "            AND N9D.N9D_TIPMOV = '10' "
	cQuery += "            AND N9D.N9D_STATUS <> '3' "
	cQuery += "            AND N9D.D_E_L_E_T_ <> '*') < N8P.N8P_QTDAUT "
	cQuery += "    AND N8P.D_E_L_E_T_ <> '*' "

 	cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)	   	

	oSldPack["hasNext"]         := .F.
    oSldPack["items"]           := Array(0)
    oSldPack["totvs_sync_date"] := cDateTime
    
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
	    
        	Aadd(oSldPack["items"], JsonObject():New())        	
        	        	
            aTail(oSldPack["items"])['type']       := IIf((cAlias)->TYPE == "N83", 1, 2)
            aTail(oSldPack["items"])['recno']      := (cAlias)->TYPE + cValToChar((cAlias)->REC)
            aTail(oSldPack["items"])['packbranch'] := (cAlias)->FILIAL_BLC
            aTail(oSldPack["items"])['packCode']   := (cAlias)->BLOCO  
            aTail(oSldPack["items"])['crop']       := (cAlias)->SAFRA
            aTail(oSldPack["items"])['quantity']   := (cAlias)->QTD
            
            If (cAlias)->TYPE == 'N83'            
            	aTail(oSldPack["items"])['entityCode']  := (cAlias)->COD
            Else
            	aTail(oSldPack["items"])['entityCode']  := AllTrim((cAlias)->FILIAL+AllTrim((cAlias)->COD)+(cAlias)->ITEM)
            EndIf 
	        
	        aTail(oSldPack["items"])['deleted'] := .F.		
	            
			(cAlias)->(DbSkip())			
        EndDo
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oSldPack["hasNext"] := lHasNext
        
        cResponse := EncodeUTF8(FWJsonSerialize(oSldPack, .F., .F., .T.))        
        ::SetResponse(cResponse)
        
    Else    
        cResponse := FWJsonSerialize(oSldPack, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf	    
     
     (cAlias)->(DbCloseArea())   
     
Return lPost

WSMETHOD GET SldDiff QUERYPARAM page, pageSize PATHPARAM dateDiff WSSERVICE UBAW14
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
	
	::SetContentType("application/json")
	
    cAlias := GetNextAlias()
    
    aData := FWDateTimeToLocal(cDateDiff)
    
    cData := Year2Str(Year(aData[1])) + Month2Str(Month(aData[1])) + Day2Str(Day(aData[1]))
	cHora := aData[2] 
    
	// blocos disponíveis para carregar ou que estão vinculados a uma instrução de embarque (próximos embarques).
 
    cQuery := " SELECT 'N83' TYPE, N83.R_E_C_N_O_ REC, N83.N83_FILIAL FILIAL, N83.N83_CODINE COD, '' ITEM, N83.N83_FILORG FILIAL_BLC, "
    cQuery += "        N83.N83_BLOCO BLOCO, N83.N83_SAFRA SAFRA, N83.N83_QUANT QTD, N83.D_E_L_E_T_ DEL "    
    cQuery += "   FROM " + RetSqlName("N83") + " N83 "
    cQuery += "  WHERE (SELECT COUNT(*) "
    cQuery += "           FROM " + RetSqlName("N9D") + " N9D "
    cQuery += "          WHERE N9D.N9D_FILIAL = N83.N83_FILORG "
	cQuery += "			   AND N9D.N9D_SAFRA  = N83.N83_SAFRA "
	cQuery += "			   AND N9D.N9D_BLOCO  = N83.N83_BLOCO "
    cQuery += "            AND N9D.N9D_FILORG = N83.N83_FILIAL " 
    cQuery += "            AND N9D.N9D_CODINE = N83.N83_CODINE "
    cQuery += "            AND N9D.N9D_TIPMOV = '04' "
    cQuery += "            AND N9D.N9D_STATUS <> '3' ) < N83.N83_QUANT "
    cQuery += "    AND N83.N83_FRDMAR = '2' "
    cQuery += "    AND ( N83.N83_DATATU > '"+cData+"' OR (N83.N83_DATATU = '"+cData+"' AND N83.N83_HORATU >= '"+cHora+"' )) "
	cQuery += " UNION "
	cQuery += "	SELECT 'N8P' TYPE, N8P.R_E_C_N_O_ REC, N8P.N8P_FILIAL FILIAL, N8P.N8P_CODAUT COD, N8P.N8P_ITEMAC ITEM, N8P.N8P_FILORG FILIAL_BLC, "
	cQuery += " 	   N8P.N8P_BLOCO BLOCO, N8P.N8P_SAFRA SAFRA, N8P.N8P_QTDAUT QTD, N8P.D_E_L_E_T_ DEL "	
	cQuery += "   FROM " + RetSqlName("N8P") + " N8P "
	cQuery += "  WHERE (SELECT COUNT(*) "
	cQuery += "           FROM " + RetSqlName("N9D") + " N9D " 
	cQuery += "			 WHERE N9D.N9D_FILIAL = N8P.N8P_FILORG "
	cQuery += "			   AND N9D.N9D_SAFRA  = N8P.N8P_SAFRA "
	cQuery += "			   AND N9D.N9D_BLOCO  = N8P.N8P_BLOCO "
	cQuery += "            AND N9D.N9D_FILORG = N8P.N8P_FILIAL "
	cQuery += "            AND N9D.N9D_CODAUT = N8P.N8P_CODAUT "
	cQuery += "            AND N9D.N9D_ITEMAC = N8P.N8P_ITEMAC "
	cQuery += "            AND N9D.N9D_TIPMOV = '10' "
	cQuery += "            AND N9D.N9D_STATUS <> '3' ) < N8P.N8P_QTDAUT "
	cQuery += "   AND ( N8P.N8P_DATATU > '"+cData+"' OR (N8P.N8P_DATATU = '"+cData+"' AND N8P.N8P_HORATU >= '"+cHora+"' )) "

	cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)	
	
	oClassifier["hasNext"]         := .F.
    oClassifier["items"]           := Array(0)
    oClassifier["totvs_sync_date"] := cDateTime
    
    
    If (cAlias)->(!Eof())  
      
	    While (cAlias)->(!Eof()) 

        	Aadd(oSldPack["items"], JsonObject():New())        	
        	        	
            aTail(oSldPack["items"])['type']       := IIf((cAlias)->TYPE == "N83", 1, 2)
            aTail(oSldPack["items"])['recno']      := (cAlias)->TYPE + cValToChar((cAlias)->REC)
            aTail(oSldPack["items"])['packbranch'] := (cAlias)->FILIAL_BLC
            aTail(oSldPack["items"])['packCode']   := (cAlias)->BLOCO  
            aTail(oSldPack["items"])['crop']       := (cAlias)->SAFRA
            aTail(oSldPack["items"])['quantity']   := (cAlias)->QTD
            
            If (cAlias)->TYPE == 'N83'            
            	aTail(oSldPack["items"])['entityCode']  := (cAlias)->COD
            Else
            	aTail(oSldPack["items"])['entityCode']  := AllTrim((cAlias)->FILIAL)+AllTrim((cAlias)->COD)+AllTrim((cAlias)->ITEM)
            EndIf
	        
	        aTail(oSldPack["items"])['deleted'] := IIF( (cAlias)->DEL <> '*', .F., .T.)
			
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