#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

Static aErros := {}

WSRESTFUL UBAW05 DESCRIPTION "Cadastro de Malas - DXJ"

WSDATA code 	AS STRING OPTIONAL
WSDATA dateDiff AS STRING OPTIONAL
WSDATA page     AS INTEGER OPTIONAL
WSDATA pageSize AS INTEGER OPTIONAL

WSMETHOD GET 		 DESCRIPTION "Retorna uma lista de malas" 		 PATH "/v1/cases/" 	   		   	  PRODUCES APPLICATION_JSON
WSMETHOD GET GetDiff DESCRIPTION "Retorna uma lista de malas - Diff" PATH "/v1/cases/diff/{dateDiff}" PRODUCES APPLICATION_JSON
WSMETHOD PUT 		 DESCRIPTION "Atualiza uma mala" 		  		 PATH "/v1/cases/{code}" 		  PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET QUERYPARAM page, pageSize WSSERVICE UBAW05
	Local lPost     := .T.
	Local oCase     := JsonObject():New()
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
    
    oCase["hasNext"] := .F.
    oCase["items"]   := Array(0)
    oCase["totvs_sync_date"] := cDateTime
    
    cAlias := GetNextAlias()
    cQuery := " SELECT DXJ.R_E_C_N_O_, " 
    cQuery += "        DXJ.DXJ_FILIAL, "
    cQuery += "    	   DXJ.DXJ_SAFRA, "
    cQuery += "    	   DXJ.DXJ_CODIGO, "
    cQuery += "    	   DXJ.DXJ_CODBAR, "
    cQuery += "    	   DXJ.DXJ_TIPO, "    
    cQuery += "    	   DXJ.DXJ_DATREC, "
    cQuery += "    	   DXJ.DXJ_HORREC, "
    cQuery += "    	   DXJ.DXJ_USRREC, "    
    cQuery += "    	   DXJ.DXJ_STATUS, "
    cQuery += "    	   DXJ.DXJ_QTVINC, "
    cQuery += "    	   DXJ.DXJ_FRDINI, "
    cQuery += "    	   DXJ.DXJ_FRDFIM, "
    cQuery += "    	   N73.N73_CODREM "        
    cQuery += " FROM " + RetSqlName("DXJ") + " DXJ "
    cQuery += " INNER JOIN " + RetSqlName("N73") + " N73 ON N73.N73_FILIAL = DXJ.DXJ_FILIAL "
    cQuery += "   AND N73.N73_CODMAL = DXJ.DXJ_CODIGO AND N73.N73_TIPO = DXJ.DXJ_TIPO "
    cQuery += "   AND N73.D_E_L_E_T_ <> '*' "
    cQuery += " WHERE DXJ.DXJ_STATUS IN ('1','2','4','5') "
    cQuery += "   AND DXJ.D_E_L_E_T_ <> '*' "
    cQuery += "   AND DXJ.DXJ_DATENV <> '' "
    	
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
        
            Aadd(oCase["items"], JsonObject():New())
            
            aTail(oCase["items"])['recno']      		:= (cAlias)->R_E_C_N_O_            
            aTail(oCase["items"])['branchCode']    		:= Alltrim((cAlias)->DXJ_FILIAL)
            aTail(oCase["items"])['crop']       		:= Alltrim((cAlias)->DXJ_SAFRA)
            aTail(oCase["items"])['code'] 				:= Alltrim((cAlias)->DXJ_CODIGO)
            aTail(oCase["items"])['barCode'] 			:= Alltrim((cAlias)->DXJ_CODBAR)
            aTail(oCase["items"])['classificationType']	:= (cAlias)->DXJ_TIPO
            aTail(oCase["items"])['status']				:= (cAlias)->DXJ_STATUS
            aTail(oCase["items"])['balesQuantity']		:= (cAlias)->DXJ_QTVINC
            aTail(oCase["items"])['baleInitialCode']	:= Alltrim((cAlias)->DXJ_FRDINI)
            aTail(oCase["items"])['baleFinalCode']		:= Alltrim((cAlias)->DXJ_FRDFIM)            
            aTail(oCase["items"])['shippingCode']		:= Alltrim((cAlias)->N73_CODREM)
            aTail(oCase["items"])['receiptDate']		:= (cAlias)->DXJ_DATREC
            aTail(oCase["items"])['receiptHour']		:= (cAlias)->DXJ_HORREC
            aTail(oCase["items"])['receiptUser']		:= Alltrim((cAlias)->DXJ_USRREC)                                               
            aTail(oCase["items"])['deleted']  			:= .F.
            
            (cAlias)->(DbSkip())
        End
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oCase["hasNext"] := lHasNext
        
        cResponse := EncodeUTF8(FWJsonSerialize(oCase, .F., .F., .T.))
        ::SetResponse(cResponse)
    Else
        cResponse := FWJsonSerialize(oCase, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf
    
    (cAlias)->(DbCloseArea())
Return lPost

WSMETHOD GET GetDiff QUERYPARAM page, pageSize PATHPARAM dateDiff WSSERVICE UBAW05
	Local lPost      := .T.
	Local oCase      := JsonObject():New()
	Local cDateDiff	 := ::dateDiff
	Local lDeletado  := .F.
	Local cData		 := ""
	Local cHora		 := ""
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
	
	aData := FWDateTimeToLocal(cDateDiff)
    
    oCase["hasNext"] := .F.
    oCase["items"]   := Array(0)
    oCase["totvs_sync_date"] := cDateTime
    
    cAlias := GetNextAlias()
    cQuery := " SELECT DXJ.R_E_C_N_O_, " 
    cQuery += "        DXJ.DXJ_FILIAL, "
    cQuery += "    	   DXJ.DXJ_SAFRA, "
    cQuery += "    	   DXJ.DXJ_CODIGO, "
    cQuery += "    	   DXJ.DXJ_CODBAR, "
    cQuery += "    	   DXJ.DXJ_TIPO, "    
    cQuery += "    	   DXJ.DXJ_DATREC, "
    cQuery += "    	   DXJ.DXJ_HORREC, "
    cQuery += "    	   DXJ.DXJ_USRREC, "    
    cQuery += "    	   DXJ.DXJ_STATUS, "
    cQuery += "    	   DXJ.DXJ_QTVINC, "
    cQuery += "    	   DXJ.DXJ_FRDINI, "
    cQuery += "    	   DXJ.DXJ_FRDFIM, "
    cQuery += "		   DXJ.DXJ_DATENV, "
    cQuery += "        (CASE WHEN DXJ.D_E_L_E_T_ = '*' THEN 1 ELSE 2 END) AS DELDXJ, "    
    cQuery += "    	   N73.N73_CODREM "    
    cQuery += " FROM " + RetSqlName("DXJ") + " DXJ "
    cQuery += " LEFT JOIN " + RetSqlName("N73") + " N73 ON N73.N73_FILIAL = DXJ.DXJ_FILIAL "
    cQuery += "   AND N73.N73_CODMAL = DXJ.DXJ_CODIGO AND N73.N73_TIPO = DXJ.DXJ_TIPO "
    cQuery += "   AND N73.D_E_L_E_T_ <> '*' "
    
    cData := Year2Str(Year(aData[1])) + Month2Str(Month(aData[1])) + Day2Str(Day(aData[1]))
	cHora := aData[2] 
    
    cQuery += " WHERE ((DXJ.DXJ_DATATU > '"+cData+"') OR (DXJ.DXJ_DATATU = '"+cData+"' AND DXJ.DXJ_HORATU >= '"+cHora+"')) "
    	
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
        
        	If (cAlias)->DELDXJ = 1 .OR. Empty((cAlias)->N73_CODREM) .OR. Empty((cAlias)->DXJ_DATENV) .OR.; 
        		!(cAlias)->DXJ_STATUS $ "1|2|4|5"
        		lDeletado := .T.
        	EndIf
        
        	Aadd(oCase["items"], JsonObject():New())
            
            aTail(oCase["items"])['recno']      		:= (cAlias)->R_E_C_N_O_            
            aTail(oCase["items"])['branchCode']    		:= Alltrim((cAlias)->DXJ_FILIAL)
            aTail(oCase["items"])['crop']       		:= Alltrim((cAlias)->DXJ_SAFRA)
            aTail(oCase["items"])['code'] 				:= Alltrim((cAlias)->DXJ_CODIGO)
            aTail(oCase["items"])['barCode'] 			:= Alltrim((cAlias)->DXJ_CODBAR)
            aTail(oCase["items"])['classificationType']	:= (cAlias)->DXJ_TIPO
            aTail(oCase["items"])['status']				:= (cAlias)->DXJ_STATUS
            aTail(oCase["items"])['balesQuantity']		:= (cAlias)->DXJ_QTVINC
            aTail(oCase["items"])['baleInitialCode']	:= Alltrim((cAlias)->DXJ_FRDINI)
            aTail(oCase["items"])['baleFinalCode']		:= Alltrim((cAlias)->DXJ_FRDFIM)
            aTail(oCase["items"])['shippingCode']		:= Alltrim((cAlias)->N73_CODREM)
            aTail(oCase["items"])['receiptDate']		:= (cAlias)->DXJ_DATREC
            aTail(oCase["items"])['receiptHour']		:= (cAlias)->DXJ_HORREC
            aTail(oCase["items"])['receiptUser']		:= Alltrim((cAlias)->DXJ_USRREC)            
            aTail(oCase["items"])['deleted']  			:= lDeletado
            
            (cAlias)->(DbSkip())        	
        EndDo
        
        If nCount > (nPageSize * nPage)
        	lHasNext := .T.
        EndIf
        
        oCase["hasNext"] := lHasNext
        
		cResponse := EncodeUTF8(FWJsonSerialize(oCase, .F., .F., .T.))
        ::SetResponse(cResponse)
    Else
        cResponse := FWJsonSerialize(oCase, .F., .F., .T.)
        ::SetResponse(cResponse)
    EndIf

	(cAlias)->(DbCloseArea())
Return lPost

WSMETHOD PUT PATHPARAM code WSREST UBAW05
	
	Local lPost  	 := .F.	
	Local oResponse  := JsonObject():New()	
    Local oRequest   := JsonObject():New()
    Local nRecno	 := Val(::code)
    Local cRecDate	 := ""   
    Local cRecHora	 := ""
    Local cRecUsu	 := ""
    Local cFilMala   := ""
    Local cCodBarMl  := ""
    Local cCodMala 	 := ""        
    Local cSafra	 := ""
    Local cCodRem	 := ""    
    Local cErro		 := ""
    Local cTpOper	 := ""
    Local oChvSinc	 := {}
    Local cFilSinc   := ""
    Local cDataSinc  := ""
    Local cHoraSinc  := "" 
    Local cSeqSinc	 := "" 
               
    // define o tipo de retorno do método
	::SetContentType("application/json")
	
	oRequest:fromJson(::GetContent())
	
	cFilMala := PADR(oRequest["branchCode"], TamSX3("N72_FILIAL")[1])
	cSafra   := PADR(oRequest["crop"], TamSX3("N72_SAFRA")[1])
	cCodRem  := PADR(oRequest["shippingCode"], TamSX3("N72_CODREM")[1])
		
	If Empty(cSafra)
		cErro := "Não foi informada a safra da mala."			
	ElseIf Empty(cCodRem)
		cErro := "Não foi informada o código da remessa."			
	EndIf
	
	If Empty(cErro)
		BEGIN TRANSACTION
		
			cRecDate  := oRequest["receiptDate"]
			cRecHora  := oRequest["receiptHour"]
			cRecUsu   := oRequest["receiptUser"]
			cCodBarMl := PADR(oRequest["barCode"], TamSX3("DXJ_CODBAR")[1])
			cCodMala  := PADR(oRequest["code"], TamSX3("DXJ_CODIGO")[1])
			
			// Inclusão da sincronização
			cTpOper := IIf(!Empty(cRecDate),"1","2")
		
			oChvSinc := UBIncSinc(cTpOper,"3","1",cCodBarMl,"","",cRecDate,cRecHora,cRecUsu)
			
			cFilSinc  := oChvSinc[1]
			cDataSinc := oChvSinc[2]
			cHoraSinc := oChvSinc[3]
			cSeqSinc  := oChvSinc[4]
			
			// Realiza a alteração da mala (Recebimento ou estorno)											
			UBW05AltMl(cTpOper, nRecno, cFilMala, cCodMala, cSafra, cCodRem, cRecDate, cRecHora, cRecUsu, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
							
		END TRANSACTION		
	EndIf
	
	If Len(aErros) == 0 .AND. Empty(cErro)
		lPost := .T.
		
		oResponse["content"] := JsonObject():New()			
		oResponse["content"]["Message"]	:= "Alteração da mala realizada com sucesso."
							            
		cResponse := EncodeUTF8(FWJsonSerialize(oResponse, .F., .F., .T.))
		::SetResponse(cResponse)
	Else	
		lPost := .F.
		
		If Len(aErros) > 0
			If cTpOper == "1"
				cErro := "Ocorreu erro de negócio no recebimento da mala."
			Else 
				cErro := "Ocorreu erro de negócio no estorno da mala."
			EndIf			
		EndIf
			
		SetRestFault(400, EncodeUTF8(cErro))
	EndIf
	
Return lPost

/**---------------------------------------------------------------------
{Protheus.doc} UBW05AltMl
Alteração da mala - Recebimento ou Estorno

@param: cTpOper, character, Tipo de Operação (1=Recebimento;2=Estorno)
@param: nRecno, number, Recno da mala a ser alterada
@param: cFilMala, character, Filial da mala
@param: cCodMala, character, Código da mala
@param: cSafra, character, Safra da mala
@param: cCodRem, character, Código da remessa
@param: cRecDate, character, Data do recebimento (Apenas para operação 1=Recebimento)
@param: cRecHora, character, Hora do recebimento (Apenas para operação 1=Recebimento)
@param: cRecUsu, character, Usuário que efetuou o recebimento (Apenas para operação 1=Recebimento)
@param: cFilSinc, character, Filial da sincronização
@param: cDataSinc, character, Data da sincronização
@param: cHoraSinc, character, Hora da sincronização
@param: cSeqSinc, character, Sequencia da sincronização
@author: francisco.nunes
@since: 26/07/2018
---------------------------------------------------------------------**/
Function UBW05AltMl(cTpOper, nRecno, cFilMala, cCodMala, cSafra, cCodRem, cRecDate, cRecHora, cRecUsu, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
	
	Local nQtdRec  := 0
	Local nQtdMala := 0
	Local cCodErro := ""      
    Local cErro	   := ""
       		
	DbSelectArea('DXJ')
	DXJ->(DbGoTo(nRecno))
	If !DXJ->(Eof())
	
		 DbSelectArea("N72")
		 N72->(DbSetOrder(1)) // N72_FILIAL+N72_SAFRA+N72_CODREM
		 If !N72->(DbSeek(cFilMala+cSafra+cCodRem))
		   	cCodErro := "00004"					
		   	cErro    := "Remessa da mala não encontrada."
				
		   	Aadd(aErros, {cCodErro, cErro})
				
			// Inclusão do erro de sincronização na tabela NC4
			UBIncErro(cFilSinc,cDataSinc,cHoraSinc,cSeqSinc,cCodErro,cErro,"3",DXJ->DXJ_FILIAL,DXJ->DXJ_CODBAR)
		ElseIf (cTpOper == "2" .AND. !Empty(DXJ->DXJ_DATREC)) .AND. !Empty(DXJ->DXJ_DATANA)
			// Caso esteja estornando um mala e a mesma já foi classificada			
			cCodErro := "00001"
			cErro    := "Não é possível estornar o recebimento de uma mala classificada."
			
			Aadd(aErros, {cCodErro, cErro})
			
			// Inclusão do erro de sincronização na tabela NC4
			UBIncErro(cFilSinc,cDataSinc,cHoraSinc,cSeqSinc,cCodErro,cErro,"3",DXJ-DXJ_FILIAL,DXJ->DXJ_CODBAR)									
		ElseIf DXJ->DXJ_TIPO == "2"
			// Caso seja estorno/recebimento de uma mala com tipo HVI					
						
			If cTpOper == "2" // Estono da mala	
				cCodErro := "00002"
				cErro    := "Não é possível estornar uma mala com tipo HVI."
			ElseIf cTpOper == "1" // Recebimento da mala	
				cCodErro := "00003"
				cErro    := "Não é possível efetuar o recebimento de uma mala com tipo HVI."
			EndIf
			
			Aadd(aErros, {cCodErro, cErro})
			
			// Inclusão do erro de sincronização na tabela NC4
			UBIncErro(cFilSinc,cDataSinc,cHoraSinc,cSeqSinc,cCodErro,cErro,"3",DXJ-DXJ_FILIAL,DXJ->DXJ_CODBAR)
		EndIf			
						
		If Len(aErros) == 0
		
			If RecLock("DXJ", .F.)
			                       		        		       
		        If !Empty(cRecDate)	.AND. ValType(cRecDate) != "D"	        
			        cRecDate := cToD(SUBSTR(cRecDate, 7, 2) + "/" + SUBSTR(cRecDate, 5, 2) + "/" + SUBSTR(cRecDate, 1, 4))			        
			    ElseIf Empty(cRecDate)
			    	cRecDate := cToD("")
			    	cRecHora := ""
			    	cRecUsu  := ""
			    EndIf
			    
			    DXJ->DXJ_DATREC := cRecDate
			    DXJ->DXJ_HORREC := cRecHora
			    DXJ->DXJ_USRREC := cRecUsu
			    DXJ->DXJ_DATATU := dDatabase
				DXJ->DXJ_HORATU := Time()
				
				DXJ->(MsUnlock())
			EndIf
		       	        	        	        		        	        	       
            DbSelectArea("N72")
			N72->(DbSetOrder(1)) // N72_FILIAL+N72_SAFRA+N72_CODREM
			If N72->(DbSeek(cFilMala+cSafra+cCodRem)) 	        	
	        												
				// Verifica as datas de recebimento das malas da remessa para modificar o status da mesma
				// Seta a data, hora e usuário de recebimento da mala
				DbSelectArea("N73")
				N73->(DbSetOrder(1)) // N73_FILIAL+N73_CODSAF+N73_CODREM+N73_CODMAL
				If N73->(DbSeek(N72->(N72_FILIAL+N72_SAFRA+N72_CODREM)))
					While !N73->(Eof()) .AND. N73->(N73_FILIAL+N73_CODSAF+N73_CODREM) == N72->(N72_FILIAL+N72_SAFRA+N72_CODREM) 
						
						nQtdMala++
						
						If Alltrim(N73->N73_CODMAL) == Alltrim(cCodMala)
							If RecLock("N73", .F.)
								N73->N73_DATREC := cRecDate
								N73->N73_HORREC := cRecHora
								N73->N73_USRREC := cRecUsu
								N73->(MsUnlock())
							EndIf
						EndIf
						
						If !Empty(N73->N73_DATREC)
							nQtdRec++
						EndIf
						
						N73->(DbSkip())
					EndDo
				EndIf
				
				If RecLock("N72", .F.)				
					N72->N72_DATATU := dDatabase
					N72->N72_HORATU := Time()
												
					If nQtdRec = 0 
						N72->N72_STATUS := "2" // 2=Enviada 
					ElseIf nQtdMala = nQtdRec
						N72->N72_STATUS := "3" // 3=Entregue
					Else
						N72->N72_STATUS := "4" // 4=Entregue Parcial
					EndIf
					
					N72->(MsUnlock())
				EndIf																            														            			
			EndIf	   
		EndIf
	Else
		cCodErro := "00005"    	  	
		cErro    := "Mala não encontrada."
		
		Aadd(aErros, {cCodErro, cErro})
		
		// Inclusão do erro de sincronização na tabela NC4
		UBIncErro(cFilSinc,cDataSinc,cHoraSinc,cSeqSinc,cCodErro,cErro,"3",DXJ-DXJ_FILIAL,DXJ->DXJ_CODBAR)
	EndIf
		
	If Len(aErros) > 0
		// Alteração do status da sincronização para "2=Erro de sincronização"
		UBAltStSin(cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, "2")
	EndIf

Return aErros

/*{Protheus.doc} UBW05CERR
Verificar se os erros relacionados ao recebimento ou estorno de malas foram corrigidos
Caso sejam, será modificado o status do erro da sincronização

@author francisco.nunes
@since 30/07/2018
@param: cFilNC4, character, Filial da sincronização
@param: cDatNC4, character, Data da sincronização
@param: cHoraNC4, character, Hora da sincronização
@return: lErroSinc, boolean, .T. - Possui erro de sincronismo; .F. - Não possui erro de sincronismo
@type function
*/
Function UBW05CERR(cFilNC4, cDatNC4, cHoraNC4)

	Local lErroSinc := .F.
	Local cDatNC42	:= ""

	cDatNC4 := Year2Str(Year(cDatNC4)) + Month2Str(Month(cDatNC4)) + Day2Str(Day(cDatNC4))
		
	DbSelectArea('DXJ')

	DbSelectArea("NC4")
	NC4->(DbSetOrder(1)) // NC4_FILIAL+NC4_DATA+NC4_HORA
	If NC4->(DbSeek(cFilNC4+cDatNC4+cHoraNC4))
		While !NC4->(Eof()) 
		
			cDatNC42 := Year2Str(Year(NC4->NC4_DATA)) + Month2Str(Month(NC4->NC4_DATA)) + Day2Str(Day(NC4->NC4_DATA))
		
			If NC4->NC4_FILIAL+cDatNC42+NC4->NC4_HORA != cFilNC4+cDatNC4+cHoraNC4
				NC4->(DbSkip())
				LOOP
			ElseIf NC4->NC4_STATUS != "1"
				NC4->(DbSkip())
				LOOP
			EndIf
					
			DXJ->(DbSetOrder(2)) // DXJ_FILIAL+DXJ_CODBAR
			If DXJ->(DbSeek(NC4->(NC4_FILENT+NC4_CODBAR)))
								
				If Alltrim(NC4->(NC4_CODERR)) == "00004"
				
					// Remessa da mala não encontrada					
					cAlias := GetNextAlias()
				    cQuery := " SELECT N72.N72_CODREM "
				    cQuery += "   FROM " + RetSqlName("N72") + " N72 "
				    cQuery += " INNER JOIN " + RetSqlName("N73") + " N73 ON N73.N73_FILIAL = N72.N72_FILIAL "
				    cQuery += "   AND N73.N73_CODREM = N72.N72_CODREM AND N73.D_E_L_E_T_ <> '*' "
				    cQuery += "  WHERE N73.N73_FILIAL = '" + DXJ->DXJ_FILIAL + "' "
				    cQuery += "    AND N73.N73_CODMAL = '" + DXJ->DXJ_CODIGO + "' "
				    cQuery += "    AND N72.D_E_L_E_T_ <> '*' "
				    
				    cQuery := ChangeQuery(cQuery)
				    MPSysOpenQuery(cQuery, cAlias)
    	
    				If (cAlias)->(!Eof())    					
						If RecLock("NC4", .F.)
							NC4->NC4_STATUS := "2"
							NC4->NC4_DATATU := dDatabase
							NC4->NC4_HORATU := Time()
							NC4->(MsUnlock())
						EndIf
    				EndIf		
					
				ElseIf Alltrim(NC4->(NC4_CODERR)) == "00005"
					
					// Mala não encontrada					
					If RecLock("NC4", .F.)
						NC4->NC4_STATUS := "2"
						NC4->NC4_DATATU := dDatabase
						NC4->NC4_HORATU := Time()
						NC4->(MsUnlock())
					EndIf
					
				EndIf
			EndIf
			
			If NC4->(NC4_STATUS) == "1"
				lErroSinc := .T.
			EndIf
										
			NC4->(DbSkip())
		EndDo
	EndIf

Return lErroSinc