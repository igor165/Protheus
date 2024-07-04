#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
 
WSRESTFUL UBAW15 DESCRIPTION "Rest da Entidade Fardos para App"

WSDATA dateDiff AS STRING OPTIONAL
WSDATA page     AS INTEGER OPTIONAL
WSDATA pageSize AS INTEGER OPTIONAL

WSMETHOD GET 		  DESCRIPTION "Retorna uma lista de fardos a carregar" 	       PATH "/v1/expeditionBales" 				  PRODUCES APPLICATION_JSON
WSMETHOD GET GetDiff  DESCRIPTION "Retorna uma lista de fardos a carregar - Diff"  PATH "/v1/expeditionBales/diff/{dateDiff}" PRODUCES APPLICATION_JSON
WSMETHOD GET EmblocBales   DESCRIPTION "Retorna uma lista de fardos em emblocamento parcial"           PATH "/v1/embbales"                PRODUCES APPLICATION_JSON

END WSRESTFUL
WSMETHOD GET QUERYPARAM page, pageSize WSSERVICE UBAW15
	Local lPost        := .T.
	Local oBale		   := JsonObject():New()
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
	
	cQuery  :=  " SELECT '1' AS TIPFRD, DXI.R_E_C_N_O_ DXI, DXI.DXI_LOCAL, DXI.DXI_ETIQ, DXI.DXI_CODIGO, DXI.DXI_SAFRA ,DXI.DXI_BLOCO, DXI.DXI_FILIAL, AVG(DXI.DXI_PSESTO) PSESTO from " + RetSqlName("DXI") + " DXI "
	cQuery  +=	"	where  DXI_STATUS = '90' OR DXI_STATUS = '100'"
	cQuery  +=  "	Group by  DXI.R_E_C_N_O_,DXI.DXI_LOCAL,DXI.DXI_ETIQ, DXI.DXI_CODIGO, DXI.DXI_SAFRA ,DXI.DXI_BLOCO, DXI.DXI_FILIAL "
	cQuery  +=  " UNION "
	cQuery  +=  " SELECT '2' AS TIPFRD, DXI.R_E_C_N_O_ DXI, DXI.DXI_LOCAL, DXI.DXI_ETIQ, DXI.DXI_CODIGO, DXI.DXI_SAFRA ,DXI.DXI_BLOCO, DXI.DXI_FILIAL, AVG(DXI.DXI_PSESTO) PSESTO from " + RetSqlName("DXI") + " DXI "
	cQuery  += 	"	INNER JOIN " + RetSqlName("N83") + " N83 ON DXI.DXI_BLOCO  = N83.N83_BLOCO  AND DXI.DXI_SAFRA  = N83.N83_SAFRA  AND DXI.D_E_L_E_T_ <> '*'  AND N83.N83_FRDMAR = '2'"
	cQuery  += 	"	Where DXI.DXI_STATUS = '70' OR  DXI.DXI_STATUS = '80' "
	cQuery  += 	"	Group by  DXI.R_E_C_N_O_,DXI.DXI_LOCAL,DXI.DXI_ETIQ, DXI.DXI_CODIGO, DXI.DXI_SAFRA ,DXI.DXI_BLOCO, DXI.DXI_FILIAL "
	
	cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)	
	
	oBale["hasNext"]         := .F.
    oBale["items"]           := Array(0)
    oBale["totvs_sync_date"] := cDateTime
    
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
        	
            aTail(oBale["items"])['recno']    		:= (cAlias)->DXI
			aTail(oBale["items"])['branch']    		:= (cAlias)->DXI_FILIAL
            aTail(oBale["items"])['baleTag']    	:= (cAlias)->DXI_ETIQ     
            aTail(oBale["items"])['baleCode']    	:= (cAlias)->DXI_CODIGO 
            aTail(oBale["items"])['block']    		:= (cAlias)->DXI_BLOCO  
            aTail(oBale["items"])['crop']     		:= (cAlias)->DXI_SAFRA  
            aTail(oBale["items"])['stockWeight']    := (cAlias)->PSESTO   
			aTail(oBale["items"])['local']          := (cAlias)->DXI_LOCAL   
            
            aTail(oBale["items"])['codine']    		:= ''
            aTail(oBale["items"])['desine']    		:= ''
            aTail(oBale["items"])['romaneio'] 		:= ''
            aTail(oBale["items"])['codaut']   		:= ''
            
            If (cAlias)->TIPFRD == '1' // Fardos Selecionados na IE c/ Status 90 ou 100            
	            //Preenche o campo de CODINE e DESINE
	            RelacaoN9D((cAlias)->DXI_FILIAL,(cAlias)->DXI_SAFRA,(cAlias)->DXI_ETIQ,'04',@oBale) 
	            
	            //Preenche o codigo do romaneio	             	
	            RelacaoN9D((cAlias)->DXI_FILIAL,(cAlias)->DXI_SAFRA,(cAlias)->DXI_ETIQ,'07',@oBale) 
	            
	            //Preenche o codigo de autorização	            
	            RelacaoN9D((cAlias)->DXI_FILIAL,(cAlias)->DXI_SAFRA,(cAlias)->DXI_ETIQ,'10',@oBale) 
	        Else // Fardos do Bloco selecionado na IE (Informado qtd de fardos manualmente)
	        	
	        	//Preenche o campo de CODINE e DESINE
	            BuscaIEs((cAlias)->DXI_FILIAL,(cAlias)->DXI_SAFRA,(cAlias)->DXI_BLOCO,,@oBale) 
	            	            	        
	        EndIf
	        
	        //Preenche o codigo de autorização (Busca para os fardos que não tem movimento do fardo)	             
	        BuscaAuts((cAlias)->DXI_FILIAL,(cAlias)->DXI_SAFRA,(cAlias)->DXI_BLOCO,(cAlias)->DXI_ETIQ, @oBale)
            
            aTail(oBale["items"])['deleted']  := .F.		
          
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

Static Function RelacaoN9D(cCodFilial,cSafra,cFardo,cTipMov, oBale)

	DbSelectArea("N9D")
	DbSetOrder(5)
	If DbSeek(cCodFilial+cSafra+cFardo+cTipMov) //N9D_FILIAL+N9D_SAFRA+N9D_FARDO+    
		While N9D->(!Eof()) .AND. cCodFilial+cSafra+cFardo+cTipMov == N9D->N9D_FILIAL+N9D->N9D_SAFRA+N9D->N9D_FARDO+N9D->N9D_TIPMOV 
			If cTipMov == '04' .AND. N9D->N9D_STATUS <> '3' //IE

				aTail(oBale["items"])['codine']    += N9D->N9D_CODINE + "||"
				aTail(oBale["items"])['desine']    += Posicione("N7Q",1,N9D->N9D_FILORG+N9D->N9D_CODINE,"N7Q_DESINE")  + "||"
				
			ElseIf cTipMov == '07' .AND. N9D->N9D_STATUS <> '3' //Romaneio

				aTail(oBale["items"])['romaneio']  += N9D->N9D_CODROM + "||" 	

			ElseIf cTipMov == '10' .AND. N9D->N9D_STATUS <> '3' //Autorização

				aTail(oBale["items"])['codaut']    += AllTrim(N9D->N9D_FILORG+N9D->N9D_CODAUT+N9D->N9D_ITEMAC) + "||"

			EndIf
			N9D->(DbSkip())
		EndDO
	EndIf


Return 

Static Function BuscaIEs(cFilFrd, cSafra, cBloco, cFardo, oBale)
		
	Local cQueryIEs := ""
	Local cAliasIEs := GetNextAlias()
	
	Default cFardo := ""

	cQueryIEs := " SELECT N83.N83_CODINE, N7Q.N7Q_DESINE "
	cQueryIEs += "   FROM " + RetSqlName("N83") + " N83 "
	cQueryIEs += "  INNER JOIN " + RetSqlName("N7Q") + " N7Q ON N7Q.N7Q_FILIAL = N83.N83_FILIAL AND N7Q.N7Q_CODINE = N83.N83_CODINE AND N7Q.D_E_L_E_T_ <> '*' "
    cQueryIEs += "  WHERE (SELECT COUNT(*) "
    cQueryIEs += "           FROM " + RetSqlName("N9D") + " N9D " 
    cQueryIEs += "          WHERE N9D.N9D_FILORG = N83.N83_FILIAL "
    cQueryIEs += "            AND N9D.N9D_CODINE = N83.N83_CODINE "
    cQueryIEs += "            AND N9D.N9D_FILIAL = N83.N83_FILORG "
    cQueryIEs += "            AND N9D.N9D_SAFRA  = N83.N83_SAFRA "
    cQueryIEs += "            AND N9D.N9D_BLOCO  = N83.N83_BLOCO "
    cQueryIEs += "            AND N9D.N9D_TIPMOV = '04' "
    cQueryIEs += "            AND N9D.N9D_STATUS <> '3'
    cQueryIEs += "            AND N9D.D_E_L_E_T_ <> '*') < N83.N83_QUANT " 
    cQueryIEs += "    AND N83.N83_FRDMAR = '2' "
    cQueryIEs += "    AND N83.D_E_L_E_T_ <> '*'  "
    cQueryIEs += "    AND N83.N83_FILORG = '" + cFilFrd + "' "
    cQueryIEs += "    AND N83.N83_SAFRA  = '" + cSafra + "' "
    cQueryIEs += "    AND N83.N83_BLOCO  = '" + cBloco + "' "
    
    If !Empty(cFardo)    	
    	cQueryIEs += " AND NOT EXISTS (SELECT N9D.N9D_CODINE "
    	cQueryIEs += "                   FROM " + RetSqlName("N9D") + " N9D "
    	cQueryIEs += "          		WHERE N9D.N9D_FILORG = N83.N83_FILIAL "
	    cQueryIEs += "            		  AND N9D.N9D_CODINE = N83.N83_CODINE "
	    cQueryIEs += "            		  AND N9D.N9D_FILIAL = N83.N83_FILORG "
	    cQueryIEs += "            		  AND N9D.N9D_SAFRA  = N83.N83_SAFRA "
	    cQueryIEs += "            		  AND N9D.N9D_FARDO  = '" + cFardo + "' "
	    cQueryIEs += "            		  AND N9D.N9D_TIPMOV = '04' "
	    cQueryIEs += "            		  AND N9D.N9D_STATUS <> '3' "
	    cQueryIEs += "            		  AND N9D.D_E_L_E_T_ <> '*') "   	
    EndIf
        
    cQueryIEs := ChangeQuery(cQueryIEs)
    MPSysOpenQuery(cQueryIEs, cAliasIEs)	
    
    If (cAliasIEs)->(!Eof())  
      
	    While (cAliasIEs)->(!Eof())
	    
	    	aTail(oBale["items"])['codine'] += (cAliasIEs)->N83_CODINE + "||"
			aTail(oBale["items"])['desine'] += (cAliasIEs)->N7Q_DESINE + "||"
			
			(cAliasIEs)->(DbSkip())
	    
	    EndDo
	EndIf
	
	(cAliasIEs)->(DbCloseArea()) 
	
Return

Static Function BuscaAuts(cFilFrd, cSafra, cBloco, cFardo, oBale)
	
	Local cQueryAuts := ""
	Local cAliasAuts := GetNextAlias()
	
	Default cFardo := ""

	cQueryAuts := " SELECT N8P.N8P_FILIAL, N8P.N8P_CODAUT, N8P.N8P_ITEMAC "
	cQueryAuts += "   FROM " + RetSqlName("N8P") + " N8P "	
    cQueryAuts += "  WHERE (SELECT COUNT(*) "
    cQueryAuts += "           FROM " + RetSqlName("N9D") + " N9D " 
    cQueryAuts += "          WHERE N9D.N9D_FILORG = N8P.N8P_FILIAL "
    cQueryAuts += "            AND N9D.N9D_CODAUT = N8P.N8P_CODAUT "
    cQueryAuts += "            AND N9D.N9D_ITEMAC = N8P.N8P_ITEMAC "  
    cQueryAuts += "            AND N9D.N9D_FILIAL = N8P.N8P_FILORG "
    cQueryAuts += "            AND N9D.N9D_SAFRA  = N8P.N8P_SAFRA "
    cQueryAuts += "            AND N9D.N9D_BLOCO  = N8P.N8P_BLOCO "  
    cQueryAuts += "            AND N9D.N9D_TIPMOV = '10' "
    cQueryAuts += "            AND N9D.N9D_STATUS <> '3'
    cQueryAuts += "            AND N9D.D_E_L_E_T_ <> '*') < N8P.N8P_QTDAUT "     
    cQueryAuts += "    AND N8P.D_E_L_E_T_ <> '*'  "
    cQueryAuts += "    AND N8P.N8P_FILORG = '" + cFilFrd + "' "
    cQueryAuts += "    AND N8P.N8P_SAFRA  = '" + cSafra + "' "
    cQueryAuts += "    AND N8P.N8P_BLOCO  = '" + cBloco + "' "
    
    If !Empty(cFardo)    	
    	cQueryAuts += " AND NOT EXISTS (SELECT N9D.N9D_CODAUT "
    	cQueryAuts += "                   FROM " + RetSqlName("N9D") + " N9D "
    	cQueryAuts += "          		 WHERE N9D.N9D_FILORG = N8P.N8P_FILIAL "
	    cQueryAuts += "            		   AND N9D.N9D_CODAUT = N8P.N8P_CODAUT "
	    cQueryAuts += "            		   AND N9D.N9D_ITEMAC = N8P.N8P_ITEMAC "
	    cQueryAuts += "            		   AND N9D.N9D_FILIAL = N8P.N8P_FILORG "
	    cQueryAuts += "            		   AND N9D.N9D_SAFRA  = N8P.N8P_SAFRA "
	    cQueryAuts += "            		   AND N9D.N9D_FARDO  = '" + cFardo + "' "
	    cQueryAuts += "            		   AND N9D.N9D_TIPMOV = '10' "
	    cQueryAuts += "            		   AND N9D.N9D_STATUS <> '3' "
	    cQueryAuts += "            		   AND N9D.D_E_L_E_T_ <> '*') "   	
    EndIf
        
    cQueryAuts := ChangeQuery(cQueryAuts)
    MPSysOpenQuery(cQueryAuts, cAliasAuts)	
    
    If (cAliasAuts)->(!Eof())  
      
	    While (cAliasAuts)->(!Eof())
	    
	    	aTail(oBale["items"])['codaut'] += AllTrim((cAliasAuts)->N8P_FILIAL+(cAliasAuts)->N8P_CODAUT+(cAliasAuts)->N8P_ITEMAC) + "||"
			
			(cAliasAuts)->(DbSkip())
	    
	    EndDo
	EndIf
	
	(cAliasAuts)->(DbCloseArea())

Return

WSMETHOD GET GetDiff QUERYPARAM page, pageSize PATHPARAM dateDiff WSSERVICE UBAW15
	Local lPost        := .T.
	Local oBale		   := JsonObject():New()
	Local cDateTime	   := ""
	Local oPage        := {}
	Local nPage 	   := IIf(!Empty(::page),::page,1)
	Local nPageSize    := IIf(!Empty(::pageSize),::pageSize,30)
	Local nCount	   := 0
	Local lHasNext	   := .F.
	Local cHora        := ''
	Local cData        := ''
	Local cDateDiff	   := ::dateDiff
	Local lDeletado    := .F.
			
	oPage := FwPageCtrl():New(nPageSize,nPage)	
	
	// Coloca a data e hora atual
	// Formato UTC aaaa-mm-ddThh:mm:ss-+Time Zone (coloca a hora local + o timezone (ISO 8601))
	cDateTime := FWTimeStamp(5)	
	
	aData := FWDateTimeToLocal(cDateDiff)
	
	cData := Year2Str(Year(aData[1])) + Month2Str(Month(aData[1])) + Day2Str(Day(aData[1]))
	cHora := aData[2]
		
	::SetContentType("application/json")
	
    cAlias := GetNextAlias()
	
	cQuery := " SELECT DXI.R_E_C_N_O_ DXI, DXI.DXI_LOCAL, DXI.DXI_ETIQ, DXI.DXI_CODIGO, DXI.DXI_SAFRA ,DXI.DXI_BLOCO, DXI.DXI_FILIAL, AVG(DXI.DXI_PSESTO) PSESTO, "
	cQuery += "        DXI.DXI_STATUS, (CASE WHEN DXI.D_E_L_E_T_ = '*' THEN 1 ELSE 2 END) AS DELDXI "
	cQuery += "   FROM " + RetSqlName("DXI") + " DXI "
	cQuery += "	 WHERE (DXI.DXI_DATATU > '"+cData+"' OR (DXI.DXI_DATATU = '"+cData+"' AND DXI.DXI_HORATU >= '"+cHora+"' )) "
	cQuery += "	GROUP BY  DXI.R_E_C_N_O_,DXI.DXI_LOCAL,DXI.DXI_ETIQ, DXI.DXI_CODIGO, DXI.DXI_BLOCO, DXI.DXI_SAFRA, DXI.DXI_FILIAL, DXI.DXI_STATUS, DXI.D_E_L_E_T_ "
		
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery, cAlias)	
	
	oBale["hasNext"]         := .F.
    oBale["items"]           := Array(0)
    oBale["totvs_sync_date"] := cDateTime
    
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
        	
            aTail(oBale["items"])['recno']    	 := (cAlias)->DXI
			aTail(oBale["items"])['branch']    	 := (cAlias)->DXI_FILIAL
            aTail(oBale["items"])['baletag']     := (cAlias)->DXI_ETIQ     
            aTail(oBale["items"])['balecode']    := (cAlias)->DXI_CODIGO 
            aTail(oBale["items"])['block']    	 := (cAlias)->DXI_BLOCO  
            aTail(oBale["items"])['crop']     	 := (cAlias)->DXI_SAFRA  
            aTail(oBale["items"])['stockweight'] := (cAlias)->PSESTO   
			aTail(oBale["items"])['local']       := (cAlias)->DXI_LOCAL   
            
            aTail(oBale["items"])['codine']    	 := ''
            aTail(oBale["items"])['desine']    	 := ''
            aTail(oBale["items"])['romaneio']    := ''
            aTail(oBale["items"])['codaut']    	 := ''
                                   
	        //Preenche o campo de CODINE e DESINE
	        RelacaoN9D((cAlias)->DXI_FILIAL,(cAlias)->DXI_SAFRA,(cAlias)->DXI_ETIQ,'04',@oBale) 
	            
	        //Preenche o codigo do romaneio	             	
	        RelacaoN9D((cAlias)->DXI_FILIAL,(cAlias)->DXI_SAFRA,(cAlias)->DXI_ETIQ,'07',@oBale) 
	            
	        //Preenche o codigo de autorização	            
	        RelacaoN9D((cAlias)->DXI_FILIAL,(cAlias)->DXI_SAFRA,(cAlias)->DXI_ETIQ,'10',@oBale) 
	        	        	
	        //Preenche o campo de CODINE e DESINE (Busca para os fardos que não tem movimento do fardo)
	        BuscaIEs((cAlias)->DXI_FILIAL,(cAlias)->DXI_SAFRA,(cAlias)->DXI_BLOCO,(cAlias)->DXI_ETIQ,@oBale) 
	            
	        //Preenche o codigo de autorização (Busca para os fardos que não tem movimento do fardo)	             
	        BuscaAuts((cAlias)->DXI_FILIAL,(cAlias)->DXI_SAFRA,(cAlias)->DXI_BLOCO,(cAlias)->DXI_ETIQ,@oBale)
	        		        	       
	        lDeletado := .F.
	        
	        If !AllTrim((cAlias)->DXI_STATUS) $ '70|80|90|100' .Or. (cAlias)->DELDXI = 1 .Or. Empty(oBale["items"][Len(oBale["items"])]['codine'])
	        	lDeletado := .T. 
	        EndIf
            
            aTail(oBale["items"])['deleted'] := lDeletado		
          
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

WSMETHOD GET EmblocBales QUERYPARAM page, pageSize WSSERVICE UBAW15
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
	
	cQuery  :=  " SELECT DXI.R_E_C_N_O_ DXI, DXI_FILIAL, DXI_ETIQ, DXI_CODIGO, DXI_BLOCO, DXI_SAFRA, DXI_PSESTO, DXI_LOCAL, DXD_DATAEM from " + RetSqlName("DXI") + " DXI "
	cQuery  +=  "        INNER JOIN " + RetSqlName("DXD") + " DXD ON DXI.DXI_FILIAL = DXD.DXD_FILIAL AND DXI.DXI_SAFRA = DXD.DXD_SAFRA AND DXI.DXI_BLOCO = DXD.DXD_CODIGO WHERE DXD.DXD_STATUS = '3' AND DXI.D_E_L_E_T_  <>  '*' AND DXD.D_E_L_E_T_  <> '*' "
	
	
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
		    	
        	Aadd(oClassifier["items"], JsonObject():New())

            aTail(oClassifier["items"])['recno']    		:= (cAlias)->DXI
			aTail(oClassifier["items"])['branch']    		:= (cAlias)->DXI_FILIAL
            aTail(oClassifier["items"])['baleTag']    		:= (cAlias)->DXI_ETIQ     
            aTail(oClassifier["items"])['baleCode']    		:= (cAlias)->DXI_CODIGO 
            aTail(oClassifier["items"])['block']    		:= (cAlias)->DXI_BLOCO  
            aTail(oClassifier["items"])['crop']     		:= (cAlias)->DXI_SAFRA  
            aTail(oClassifier["items"])['stockWeight']      := (cAlias)->DXI_PSESTO   
			aTail(oClassifier["items"])['local']            := (cAlias)->DXI_LOCAL
            aTail(oClassifier["items"])['dataemb']          := (cAlias)->DXD_DATAEM
            
            aTail(oClassifier["items"])['deleted']  		:= .F.
            				      	      
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

