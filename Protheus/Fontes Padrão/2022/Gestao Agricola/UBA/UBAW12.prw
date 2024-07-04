#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
 
WSRESTFUL UBAW12 DESCRIPTION "Rest da Entidade Carregamentos para App"

WSDATA dateDiff AS STRING OPTIONAL
WSDATA page     AS INTEGER OPTIONAL
WSDATA pageSize AS INTEGER OPTIONAL

WSMETHOD GET 		 DESCRIPTION "Retorna uma lista de carregamentos " 	   	 PATH "/v1/loads" 				  PRODUCES APPLICATION_JSON
WSMETHOD GET GetDiff DESCRIPTION "Retorna uma lista de carregamentos - Diff" PATH "/v1/loads/diff/{dateDiff}" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET QUERYPARAM page, pageSize WSSERVICE UBAW12
	Local lPost        := .T.
	Local oLoad		   := JsonObject():New()
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
    cQuery := " SELECT NJJ.R_E_C_N_O_ NJJREC, N7Q.R_E_C_N_O_ N7QREC, NJJ_CODROM, NJJ_PLACA, NJJ_STATUS, N7Q_CODINE, N7Q_DESINE, N9E.N9E_FILIAL, "
    cQuery += "		   N9E.N9E_CODAUT, N9E.N9E_ITEMAC, N7Q.N7Q_LIMMAX, N7Q.N7Q_PERMAX, N7Q.N7Q_QTDREM, N9D.QTDFRD AS QTDFRD_ROM, N9D.PESFRD AS PESFRD_ROM "
    cQuery += "   FROM " + RetSqlName("NJJ") + " NJJ "
    cQuery += "  INNER JOIN " + RetSqlName("N9E") + " N9E ON N9E.N9E_FILIAL = NJJ.NJJ_FILIAL AND N9E.N9E_CODROM = NJJ.NJJ_CODROM AND N9E.D_E_L_E_T_ <> '*' "
    cQuery += "  INNER JOIN " + RetSqlName("N7Q") + " N7Q ON N7Q.N7Q_CODINE = N9E.N9E_CODINE AND N7Q.D_E_L_E_T_ <> '*' "    
	cQuery += "  INNER JOIN " + RetSqlName("SB5") + " SB5 ON SB5.B5_COD     = NJJ.NJJ_CODPRO AND SB5.D_E_L_E_T_ <> '*' "

	cQuery += "    LEFT OUTER JOIN (SELECT N9D_FILORG, N9D_CODROM, N9D_CODINE, COUNT(N9D_FARDO) AS QTDFRD, SUM(N9D_PESFIM) AS PESFRD "
	cQuery += "    					  FROM " + RetSqlName("N9D") + " N9D "
	cQuery += "						 WHERE N9D.N9D_TIPMOV =  '07' AND N9D.N9D_STATUS IN ('1', '2') AND N9D.D_E_L_E_T_ <> '*'   "
	cQuery += "    					GROUP BY N9D_FILORG, N9D_CODROM, N9D_CODINE)  N9D "
	cQuery += "     ON N9D.N9D_FILORG = NJJ.NJJ_FILIAL AND N9D.N9D_CODROM = NJJ.NJJ_CODROM AND N9D.N9D_CODINE = N7Q.N7Q_CODINE  "

    cQuery += " WHERE NJJ.D_E_L_E_T_ <> '*' AND NJJ.NJJ_STATUS IN ('0','1') AND NJJ.NJJ_PLACA <> '' "
	cQuery += "   AND SB5.B5_TPCOMMO = '2' "	
	cQuery += " GROUP BY NJJ.R_E_C_N_O_, N7Q.R_E_C_N_O_, NJJ.NJJ_CODROM, NJJ.NJJ_PLACA, NJJ_STATUS, N7Q_CODINE, N7Q_DESINE, N9E.N9E_FILIAL, N9E.N9E_CODAUT, N9E.N9E_ITEMAC, N7Q.N7Q_LIMMAX, N7Q.N7Q_PERMAX, N7Q.N7Q_QTDREM, N9D.QTDFRD, N9D.PESFRD "	
	
	cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)	
	
	oLoad["hasNext"] 		 := .F.
    oLoad["items"]   		 := Array(0)
    oLoad["totvs_sync_date"] := cDateTime
	
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
			
			Aadd(oLoad["items"], JsonObject():New())
			
			aTail(oLoad["items"])['recno']    			 := Alltrim(STR((cAlias)->NJJREC)) + AllTrim(STR((cAlias)->N7QREC))
			aTail(oLoad["items"])['romaneio']   		 := Alltrim((cAlias)->NJJ_CODROM )
			aTail(oLoad["items"])['statusRomaneio']  	 := Alltrim((cAlias)->NJJ_STATUS )
			aTail(oLoad["items"])['vehiclePlate']  		 := Alltrim((cAlias)->NJJ_PLACA  )
			aTail(oLoad["items"])['shippingInstruction'] := Alltrim((cAlias)->N7Q_DESINE )
			aTail(oLoad["items"])['codeInstruction']     := Alltrim((cAlias)->N7Q_CODINE )
			aTail(oLoad["items"])['autorization']        := IIf(!Empty((cAlias)->N9E_CODAUT),Alltrim((cAlias)->N9E_FILIAL+(cAlias)->N9E_CODAUT+(cAlias)->N9E_ITEMAC),"")
			
			aTail(oLoad["items"])['weightBalesInst']     := (cAlias)->N7Q_QTDREM // Peso Remetido IE			
			aTail(oLoad["items"])['quantityBalesR']		 := (cAlias)->QTDFRD_ROM // Quantidade Romaneio para IE
			aTail(oLoad["items"])['weightBalesR'] 		 := (cAlias)->PESFRD_ROM // Peso Romaneio para IE	

			nLimMax := (cAlias)->N7Q_LIMMAX - ((cAlias)->N7Q_LIMMAX * (cAlias)->N7Q_PERMAX / 100)
			
			aTail(oLoad["items"])['weightLimitInst'] := nLimMax // Limite de Peso IE			
			aTail(oLoad["items"])['quantityVehicle'] := 110 	// Limite de Quantidade Veículo
								
			//Busca capacidade de carga do veiculo 
			DbSelectArea("DA3")
			DA3->(DbSetOrder(3)) //DA3_FILIAL+DA3_PLACA
			If DA3->(DbSeek(xFilial("DA3") + (cAlias)->NJJ_PLACA))
				aTail(oLoad["items"])['weightVehicle'] := DA3->DA3_CAPACN // Limite de Peso Veículo    		            
			Else
				aTail(oLoad["items"])['weightVehicle'] := 0  			  // Limite de Peso Veículo
			EndIf	
			
	        aTail(oLoad["items"])['deleted']  := .F.			
			
		    (cAlias)->(DbSkip())
        EndDo
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oLoad["hasNext"] := lHasNext
        
        cResponse := EncodeUTF8(FWJsonSerialize(oLoad, .F., .F., .T.))        
        ::SetResponse(cResponse)
        
    Else    
        cResponse := FWJsonSerialize(oLoad, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf
    
     (cAlias)->(DbCloseArea())   
Return lPost

WSMETHOD GET GetDiff QUERYPARAM page, pageSize PATHPARAM dateDiff WSSERVICE UBAW12
	Local lPost        := .T.
	Local oLoad		   := JsonObject():New()
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

	oLoad["hasNext"] 		 := .F.
    oLoad["items"]   		 := Array(0)
    oLoad["totvs_sync_date"] := cDateTime

	cAlias := GetNextAlias()
    cQuery := " SELECT NJJ.R_E_C_N_O_ NJJREC, N7Q.R_E_C_N_O_ N7QREC, NJJ_CODROM, NJJ_PLACA, NJJ_STATUS, N7Q.N7Q_CODINE, N7Q.N7Q_DESINE, N9E.N9E_FILIAL, "
    cQuery += "        N9E.N9E_CODAUT, N9E.N9E_ITEMAC, N7Q.N7Q_LIMMAX, N7Q.N7Q_PERMAX, N7Q.N7Q_QTDREM, SB5.B5_TPCOMMO, "
	cQuery += "        SUM(N83.N83_QUANT) QUANT, SUM(N83.N83_PSLIQU) PESOLIQ, N9D.QTDFRD AS QTDFRD_ROM, N9D.PESFRD AS PESFRD_ROM, "
	cQuery += "        (CASE WHEN NJJ.D_E_L_E_T_ = '*' THEN 1 ELSE 2 END) AS DELNJJ, "
	cQuery += "        (CASE WHEN N9E.D_E_L_E_T_ = '*' THEN 1 ELSE 2 END) AS DELN9E, "
	cQuery += "        (CASE WHEN N7Q.D_E_L_E_T_ = '*' THEN 1 ELSE 2 END) AS DELN7Q "
    cQuery += "     FROM " + RetSqlName("NJJ") + " NJJ "
    cQuery += "     LEFT JOIN " + RetSqlName("N9E") + " N9E ON N9E.N9E_FILIAL = NJJ.NJJ_FILIAL AND N9E.N9E_CODROM = NJJ.NJJ_CODROM "
    cQuery += "     LEFT JOIN " + RetSqlName("N7Q") + " N7Q ON N7Q.N7Q_CODINE = N9E.N9E_CODINE "
    cQuery += "     LEFT JOIN " + RetSqlName("N83") + " N83 ON N83.N83_FILIAL = N7Q.N7Q_FILIAL AND N83.N83_CODINE = N7Q.N7Q_CODINE AND N83.D_E_L_E_T_ <> '*' "
	cQuery += "     LEFT JOIN " + RetSqlName("SB5") + " SB5 ON SB5.B5_COD     = NJJ.NJJ_CODPRO AND SB5.D_E_L_E_T_ <> '*' "

	cQuery += "    LEFT OUTER JOIN (   "
	cQuery += "    					SELECT N9D_FILORG, N9D_CODROM, N9D_CODINE, COUNT(N9D_FARDO) AS QTDFRD, SUM(N9D_PESFIM) AS PESFRD "
	cQuery += "    					FROM " + RetSqlName("N9D") + " N9D WHERE N9D.N9D_TIPMOV =  '07' AND N9D.N9D_STATUS IN ('1', '2') AND N9D.D_E_L_E_T_ <> '*'   "
	cQuery += "    					GROUP BY N9D_FILORG, N9D_CODROM, N9D_CODINE)  N9D  "
	cQuery += "     ON N9D.N9D_FILORG = NJJ.NJJ_FILIAL AND N9D.N9D_CODROM = NJJ.NJJ_CODROM AND N9D.N9D_CODINE = N7Q.N7Q_CODINE  "

	cData := Year2Str(Year(aData[1])) + Month2Str(Month(aData[1])) + Day2Str(Day(aData[1]))
	cHora := aData[2] 
    
    cQuery += "  WHERE (NJJ.NJJ_DTULAL > '"+cData+"') OR (NJJ.NJJ_DTULAL = '"+cData+"' AND NJJ.NJJ_HRULAL >= '"+cHora+"') "
	cQuery += "     OR (N7Q.N7Q_DTULAL > '"+cData+"') OR (N7Q.N7Q_DTULAL = '"+cData+"' AND N7Q.N7Q_HRULAL >= '"+cHora+"') "
	cQuery += " GROUP BY NJJ.R_E_C_N_O_, N7Q.R_E_C_N_O_, NJJ.NJJ_CODROM, NJJ.NJJ_PLACA, NJJ.NJJ_STATUS, "
	cQuery += "          N7Q.N7Q_CODINE, N7Q.N7Q_DESINE, N9E.N9E_FILIAL, N9E.N9E_CODAUT, N9E.N9E_ITEMAC, N7Q.N7Q_LIMMAX, N7Q.N7Q_PERMAX, N7Q.N7Q_QTDREM, SB5.B5_TPCOMMO, N9D.QTDFRD, N9D.PESFRD, NJJ.D_E_L_E_T_, N9E.D_E_L_E_T_, N7Q.D_E_L_E_T_ "
	
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
        
        	If (cAlias)->DELNJJ = 1 .OR. (cAlias)->DELN9E = 1 .OR. (cAlias)->DELN7Q = 1 .OR.; 
				!(cAlias)->NJJ_STATUS $ '0|1' .OR. Empty((cAlias)->NJJ_PLACA) .OR.;
        		(cAlias)->B5_TPCOMMO <> '2'
        		lDeletado := .T.
        	EndIf
			
			Aadd(oLoad["items"], JsonObject():New())
			
			aTail(oLoad["items"])['recno']    			 := Alltrim(STR((cAlias)->NJJREC)) + AllTrim(STR((cAlias)->N7QREC))
			aTail(oLoad["items"])['romaneio']   		 := Alltrim((cAlias)->NJJ_CODROM)
			aTail(oLoad["items"])['statusRomaneio']  	 := Alltrim((cAlias)->NJJ_STATUS)
			aTail(oLoad["items"])['vehiclePlate']  		 := Alltrim((cAlias)->NJJ_PLACA)
			aTail(oLoad["items"])['shippingInstruction'] := Alltrim((cAlias)->N7Q_DESINE)			
			aTail(oLoad["items"])['codeInstruction']     := Alltrim((cAlias)->N7Q_CODINE)
			aTail(oLoad["items"])['autorization']        := IIf(!Empty((cAlias)->N9E_CODAUT),Alltrim((cAlias)->N9E_FILIAL+(cAlias)->N9E_CODAUT+(cAlias)->N9E_ITEMAC),"")
			
			aTail(oLoad["items"])['weightBalesInst']     := (cAlias)->N7Q_QTDREM // Peso Remetido IE			
			aTail(oLoad["items"])['quantityBalesR']		 := (cAlias)->QTDFRD_ROM // Quantidade Romaneio para IE
			aTail(oLoad["items"])['weightBalesR'] 		 := (cAlias)->PESFRD_ROM // Peso Romaneio para IE	

			nLimMax := (cAlias)->N7Q_LIMMAX - ((cAlias)->N7Q_LIMMAX * (cAlias)->N7Q_PERMAX / 100)
			
			aTail(oLoad["items"])['weightLimitInst'] := nLimMax // Limite de Peso IE			
			aTail(oLoad["items"])['quantityVehicle'] := 110 	// Limite de Quantidade Veículo
								
			//Busca capacidade de carga do veiculo 
			DbSelectArea("DA3")
			DA3->(DbSetOrder(3)) //DA3_FILIAL+DA3_PLACA
			If DA3->(DbSeek(xFilial("DA3") + (cAlias)->NJJ_PLACA))
				aTail(oLoad["items"])['weightVehicle'] := DA3->DA3_CAPACN // Limite de Peso Veículo    		            
			Else
				aTail(oLoad["items"])['weightVehicle'] := 0  			  // Limite de Peso Veículo
			EndIf	
							
			aTail(oLoad["items"])['deleted'] := lDeletado
			
		    (cAlias)->(DbSkip())
        EndDo
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oLoad["hasNext"] := lHasNext
        
        cResponse := EncodeUTF8(FWJsonSerialize(oLoad, .F., .F., .T.))        
        ::SetResponse(cResponse)
        
    Else    
        cResponse := FWJsonSerialize(oLoad, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf

	(cAlias)->(DbCloseArea())
Return lPost