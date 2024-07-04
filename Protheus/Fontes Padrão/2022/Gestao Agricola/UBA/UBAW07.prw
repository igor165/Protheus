#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
 
Static aErros := {}

WSRESTFUL UBAW07 DESCRIPTION "Cadastro de Blocos - DXD"

WSDATA dateDiff AS STRING OPTIONAL
WSDATA page     AS INTEGER OPTIONAL
WSDATA pageSize AS INTEGER OPTIONAL

WSMETHOD GET 		        DESCRIPTION "Retorna uma lista de blocos" 		  PATH "/v1/packs" 				   PRODUCES APPLICATION_JSON
WSMETHOD GET  GetDiff       DESCRIPTION "Retorna uma lista de blocos - Diff"  PATH "/v1/packs/diff/{dateDiff}" PRODUCES APPLICATION_JSON
WSMETHOD POST embedding     DESCRIPTION "Atualiza um bloco" 	    	  	  PATH "/v1/embedding" 		       PRODUCES APPLICATION_JSON
WSMETHOD POST packMove   	DESCRIPTION "Grava o movimento de local do bloco" PATH "/v1/packMove"    	       PRODUCES APPLICATION_JSON 	
	

END WSRESTFUL

WSMETHOD GET QUERYPARAM page, pageSize WSSERVICE UBAW07
	Local lPost     := .T.
	Local oPack     := JsonObject():New()
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
    
    oPack["hasNext"] := .F.
    oPack["items"]   := Array(0)
    oPack["totvs_sync_date"] := cDateTime
    
    cAlias := GetNextAlias()
    
    cQuery := " SELECT DXD.R_E_C_N_O_, " 
    cQuery += "        DXD.DXD_FILIAL, "
    cQuery += "    	   DXD.DXD_SAFRA, "
    cQuery += "    	   DXD.DXD_CODIGO, "
    cQuery += "    	   DXD.DXD_CODUNI, "    
    cQuery += "    	   DXD.DXD_LOCAL, "
    cQuery += "    	   DXD.DXD_STATUS "
    cQuery += " FROM " + RetSqlName("DXD") + " DXD "
	cQuery += "	WHERE EXISTS "
	cQuery += "	    ( SELECT 1 "
	cQuery += "	     FROM " + RetSqlName("DXI") + " DXI "
	cQuery += "	     WHERE (DXI_STATUS BETWEEN '10' AND '90') "
	cQuery += "	       AND DXI_FILIAL = DXD_FILIAL"
	cQuery += "	       AND DXI_BLOCO = DXD_CODIGO"
	cQuery += "	       AND DXI_SAFRA = DXD_SAFRA )"  	
	cQuery += "   AND DXD.D_E_L_E_T_ <> '*' "

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
        	
            Aadd(oPack["items"], JsonObject():New())
            
            aTail(oPack["items"])['recno']      := (cAlias)->R_E_C_N_O_
            aTail(oPack["items"])['branchCode'] := Alltrim((cAlias)->DXD_FILIAL)
            aTail(oPack["items"])['crop']       := Alltrim((cAlias)->DXD_SAFRA)
            aTail(oPack["items"])['code'] 		:= Alltrim((cAlias)->DXD_CODIGO)
            aTail(oPack["items"])['barCode'] 	:= Alltrim((cAlias)->DXD_CODUNI)
            aTail(oPack["items"])['local']   	:= Alltrim((cAlias)->DXD_LOCAL)  
            aTail(oPack["items"])['status']   	:= Alltrim((cAlias)->DXD_STATUS)
            aTail(oPack["items"])['deleted']  	:= .F.
            
            (cAlias)->(DbSkip())
        End
        
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

WSMETHOD GET GetDiff QUERYPARAM page, pageSize PATHPARAM dateDiff WSSERVICE UBAW07
	Local lPost        := .T.
	Local oPack		   := JsonObject():New()
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
    
    oPack["hasNext"] := .F.
    oPack["items"]   := Array(0)
    oPack["totvs_sync_date"] := cDateTime
    
    cAlias := GetNextAlias()
    cQuery := " SELECT DXD.R_E_C_N_O_, " 
    cQuery += "        DXD.DXD_FILIAL, "
    cQuery += "    	   DXD.DXD_SAFRA, "
    cQuery += "    	   DXD.DXD_CODIGO, "
    cQuery += "    	   DXD.DXD_CODUNI, "    
    cQuery += "    	   DXD.DXD_STATUS, "   
    cQuery += "    	   DXD.DXD_LOCAL, "
    cQuery += "        ( Select COUNT(*) from " + RetSqlName("DXI") + " DXI  Where (DXI_STATUS BETWEEN '10' AND '90') AND DXI_FILIAL = DXD_FILIAL AND DXI_BLOCO = DXD_CODIGO AND DXI_SAFRA = DXD_SAFRA) AS FARDOS, "  
    cQuery += "        (CASE WHEN DXD.D_E_L_E_T_ = '*' THEN 1 ELSE 2 END) AS DELDXD "        
    cQuery += " FROM " + RetSqlName("DXD") + " DXD "
    
    cData := Year2Str(Year(aData[1])) + Month2Str(Month(aData[1])) + Day2Str(Day(aData[1]))
	cHora := aData[2] 
    
    cQuery += "  WHERE (DXD.DXD_DATATU > '"+cData+"') OR (DXD.DXD_DATATU = '"+cData+"' AND DXD.DXD_HORATU >= '"+cHora+"') "
    	
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
       
        	If (cAlias)->DELDXD = 1 .OR. (cAlias)->FARDOS == 0
        		lDeletado := .T.
        	EndIf
        
            Aadd(oPack["items"], JsonObject():New())
            
            aTail(oPack["items"])['recno']      := (cAlias)->R_E_C_N_O_
            aTail(oPack["items"])['branchCode'] := Alltrim((cAlias)->DXD_FILIAL)
            aTail(oPack["items"])['crop']       := Alltrim((cAlias)->DXD_SAFRA)
            aTail(oPack["items"])['code'] 		:= Alltrim((cAlias)->DXD_CODIGO)
            aTail(oPack["items"])['barCode'] 	:= Alltrim((cAlias)->DXD_CODUNI)        
            aTail(oPack["items"])['local']   	:= Alltrim((cAlias)->DXD_LOCAL)
            aTail(oPack["items"])['status']   	:= Alltrim((cAlias)->DXD_STATUS)    
            aTail(oPack["items"])['deleted']  	:= lDeletado
            
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

WSMETHOD POST embedding WSREST UBAW07
	
	Local lPost  	 := .T.	
	Local oResponse  := JsonObject():New()	
    Local oRequest   := JsonObject():New()
    Local cRecDate	 := ""   
    Local cRecHora	 := ""
    Local cRecUsu	 := ""
    Local cFilMala   := ""
    Local cCodBarMl  := ""
    Local cSafra	 := ""
    Local cErro		 := ""
    Local cTpOper	 := ""
    Local oChvSinc	 := {}
    Local cFilSinc   := ""
    Local cDataSinc  := ""
    Local cHoraSinc  := "" 
    Local cSeqSinc	 := "" 
    Local aErros     := {}     
          
    // define o tipo de retorno do método
	::SetContentType("application/json")
	
	oRequest:fromJson(::GetContent())
    
	cFilMala := PADR(oRequest["branch"], TamSX3("N72_FILIAL")[1])
	cSafra   := PADR(oRequest["crop"], TamSX3("N72_SAFRA")[1])
	cFardo   := PADR(oRequest["code"], TamSX3("DXI_CODIGO")[1])
    cCodLoc  := PADR(oRequest["local"], TamSX3("DXD_LOCAL")[1])
	
	BEGIN TRANSACTION		
		
		// Inclusão da sincronização
		cTpOper := IIf(!Empty(cRecDate),"1","2")
	
		oChvSinc := UBIncSinc(cTpOper,"3","1",cCodBarMl,"","",cRecDate,cRecHora,cRecUsu)
		
		cFilSinc  := oChvSinc[1]
		cDataSinc := oChvSinc[2]
		cHoraSinc := oChvSinc[3]
		cSeqSinc  := oChvSinc[4]
		
		// Realiza a alteração da mala (Recebimento ou estorno)											
		aErros := UBW07AltBlc(cTpOper, cCodLoc, cFilMala, cSafra, cFardo, cRecDate, cRecHora, cRecUsu, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
						
	END TRANSACTION		
	
	If Len(aErros) == 0 
		lPost := .T.
		
		oResponse["content"] := JsonObject():New()			
		oResponse["content"]["Message"]	:= "Alteração do bloco realizado com sucesso."
							            
		cResponse := EncodeUTF8(FWJsonSerialize(oResponse, .F., .F., .T.))
		::SetResponse(cResponse)
	Else	
		lPost := .F.
		
		cErro := "Ocorreu erro no emblocamento."
			
		SetRestFault(400, EncodeUTF8(cErro))
	EndIf
	
Return lPost

/**---------------------------------------------------------------------
{Protheus.doc} UBW07AltBlc
Altera??o da mala - Recebimento ou Estorno

@param: cTpOper, character, Tipo de Opera??o (1=Recebimento;2=Estorno)
@param: nRecno, number, Recno da mala a ser alterada
@param: cFilMala, character, Filial da mala
@param: cCodMala, character, C?digo da mala
@param: cSafra, character, Safra da mala
@param: cCodRem, character, C?digo da remessa
@param: cRecDate, character, Data do recebimento (Apenas para opera??o 1=Recebimento)
@param: cRecHora, character, Hora do recebimento (Apenas para opera??o 1=Recebimento)
@param: cRecUsu, character, Usu?rio que efetuou o recebimento (Apenas para opera??o 1=Recebimento)
@param: cFilSinc, character, Filial da sincroniza??o
@param: cDataSinc, character, Data da sincroniza??o
@param: cHoraSinc, character, Hora da sincroniza??o
@param: cSeqSinc, character, Sequencia da sincroniza??o
@author: francisco.nunes
@since: 26/07/2018
---------------------------------------------------------------------**/
Function UBW07AltBlc(cTpOper, cLocal , cFilBlc, cSafra, cFardo, cRecDate, cRecHora, cRecUsu, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
	
	Local cCodErro := ""      
    Local cErro	   := ""
    Local cBloco   := "" 
    Local lEmbFinalizado := .T. 
       		
	DbSelectArea('DXI')
	DXI->(DbSetOrder(7)) 	//DXI_FILIAL+DXI_SAFRA+DXI_CODIGO 
	If DXI->(DbSeek(cFilBlc+cSafra+cFardo)) 	
        
        cBloco := DXI->DXI_BLOCO
        
        If RecLock("DXI", .F.)
	        DXI->DXI_LOCAL  := cLocal
	        DXI->DXI_DATATU := dDatabase
	        DXI->DXI_HORATU := Time()
	        DXI->DXI_EMBFIS := '1'
            DXI->(MsUnlock())
        EndIf

        DbSelectArea("DXI")
		DXI->(DbSetOrder(4)) // DXI_FILIAL+DXI_SAFRA+DXI_BLOCO
		If DXI->(DbSeek(cFilBlc+cSafra+cBloco)) 	
			While DXI->(!Eof())  .AND. cFilBlc+cSafra+cBloco ==  DXI->DXI_FILIAL + DXI->DXI_SAFRA + DXI->DXI_BLOCO	.AND. lEmbFinalizado						
				
				If DXI->DXI_EMBFIS == '2' .OR. Empty(DXI->DXI_EMBFIS)
					lEmbFinalizado := .F. 
                EndIf
                
				DXI->(dbSkip())
			EndDo
		EndIf	   
		
		DbselectArea("DXD")
        DbSetOrder(1)
        If DbSeek(cFilBlc+cSafra+cBloco)
		    If RecLock("DXD", .F.)                   		        		       
		        DXD->DXD_LOCAL  := cLocal
			    DXD->DXD_DATATU := dDatabase
				DXD->DXD_HORATU := Time()
				DXD->DXD_STATUS := IIF(lEmbFinalizado,'4','5') //Embloc iniciado
				
				DXD->(MsUnlock())
			EndIf
		EndIf
							
	Else
		cCodErro := "00005"    	  	
		cErro    := "Bloco não encontrado."
		
		Aadd(aErros, {cCodErro, cErro})
		
		// Inclus?o do erro de sincroniza??o na tabela NC4
		UBIncErro(cFilSinc,cDataSinc,cHoraSinc,cSeqSinc,cCodErro,cErro,"3",DXD-DXD_FILIAL,DXD->DXD_CODIGO)
		// Altera??o do status da sincroniza??o para "2=Erro de sincronização"
		UBAltStSin(cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, "2")
	EndIf

	DXD->(dbCloseArea())
		

Return aErros

WSMETHOD POST packMove  WSREST UBAW07
	Local oResponse 	:= JsonObject():New()
    Local oRequest  	:= Nil
	local lRetorno         := .T.
	     
	::SetContentType("application/json")
	cContent := ::GetContent()
	FWJsonDeserialize(cContent,@oRequest)

	BEGIN Transaction		
			
		cFilblock := PadR(oRequest["SOURCEBRANCH"] 	 ,TamSX3("DXD_FILIAL")[1] )	//--Filial Bloco
		cBloco    := PadR(oRequest["PACK"] 			 ,TamSX3("DXD_CODIGO")[1] )	//--Bloco
		cLocal    := PadR(oRequest["WAREHOUSE"]		 ,TamSX3("DXD_LOCAL")[1]  )	//--Local
		cSafra    := PadR(oRequest["CROP"] 			 ,TamSX3("DXD_SAFRA")[1] )	//--Safra
		
		oChvSinc  := UBIncSinc("6","2","1",cFilblock + cSafra + cBloco , , , , , , , , , , cLocal  )
		             
		cFilSinc  := oChvSinc[1]
		cDataSinc := oChvSinc[2]
		cHoraSinc := oChvSinc[3]
		cSeqSinc  := oChvSinc[4]
			
		DbSelectArea("NNR")
		DbSetOrder(1)
		If DbSeek(xFilial("NNR") + cLocal ) // busca o local no sistema 
		
			DbSelectArea("DXD")
			DbSetOrder(1)
			If DbSeek(cFilblock+cSafra+cBloco) .AND. RecLock("DXD", .F.)    
				DXD->DXD_LOCAL  := cLocal
		        DXD->DXD_DATATU := dDatabase
		        DXD->DXD_HORATU := Time()	
				DXD->(MsUnLock())
			Else
				cCodErr := "00002"    	  	
				cErro    := "Erro no posicionamento/alocação da tabela de blocos para alteração do local"
	
				lRetorno := .F.
			EndIf
		
			DbSelectArea("DXI")
			DbSetOrder(4) //DXI_FILIAL+DXI_SAFRA+DXI_BLOCO
			IF lRetorno .AND. DbSeek(cFilblock+cSafra+cBloco)
				While DXI->(!Eof()) .AND. DXI->DXI_FILIAL + DXI->DXI_SAFRA + DXI->DXI_BLOCO  == cFilblock + cSafra + cBloco 
					
					If RecLock("DXI", .F.)  
						DXI->DXI_LOCAL := cLocal
				        DXI->DXI_DATATU := dDatabase
				        DXI->DXI_HORATU := Time()			
						DXI->(MsUnLock())
					Else
						cCodErr := "00003"    	  	
						cErro    := "Erro no posicionamento/alocação da tabela de fardos para alteração do local"
			
						lRetorno := .F.
					EndIf	
					DXI->(DbSkip())
				EndDo
			EndIf
		Else
			cCodErr := "00001"    	  	
			cErro    := "Não foi possivel encontrar o local informado no sistema"
			
			lRetorno := .F.
		EndIf
		
	END Transaction
     
    If !lRetorno
		
		SetRestFault(400, EncodeUTF8("Não houve alteração."))
		
		UBAltStSin(cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, "2")
    	UBIncErro(cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, cCodErr, cErro, "2", cFilblock, "")	
    	
	Else		
					
		oResponse["content"] := JsonObject():New()	
    	oResponse["content"]["Message"]	:= "Movimentação realizada com sucesso."
		
		cRetorno := EncodeUTF8(FWJsonSerialize(oResponse, .F., .F., .T.))    	
	    
	    ::SetResponse(cRetorno)		
	EndIf 
    
Return lRetorno 

/*{Protheus.doc} UBW07CERR
Verificar se os erros relacionados a classificação / revisão do tipo foram corrigidos
Caso sejam, será modificado o status do erro da sincronização para corrigido

@author felipe.mendes
@since 30/07/2018
@param: cFilNC4, character, Filial da sincronização
@param: cDatNC4, character, Data da sincronização
@param: cHoraNC4, character, Hora da sincronização
@param: cCodUn, character, Código único (Filtro)
@return: lErroSinc, boolean, .T. - Possui erro de sincronismo; .F. - Não possui erro de sincronismo
@type function
*/
Function UBW07CERR(cFilNC4, cDatNC4, cHoraNC4, cCodUn)

	Local lErroSinc := .F.
	Local cDatNC41  := ""
	Local cDatNC42  := ""
	Local lAlterado := .T.
	
	cDatNC41 := Year2Str(Year(cDatNC4)) + Month2Str(Month(cDatNC4)) + Day2Str(Day(cDatNC4))
	
	DbSelectArea("NC4")
	NC4->(DbSetOrder(1)) // NC4_FILIAL+DTOS(NC4_DATA)+NC4_HORA+NC4_SEQSIN+NC4_SEQUEN
	If NC4->(DbSeek(cFilNC4+cDatNC41+cHoraNC4))
		While !NC4->(Eof())  
		
			cDatNC42 := Year2Str(Year(NC4->NC4_DATA)) + Month2Str(Month(NC4->NC4_DATA)) + Day2Str(Day(NC4->NC4_DATA))
		
			If NC4->NC4_FILIAL+cDatNC42+NC4->NC4_HORA != cFilNC4+cDatNC41+cHoraNC4
				NC4->(DbSkip())
				LOOP
			ElseIf NC4->NC4_STATUS != "1"
				NC4->(DbSkip())
				LOOP
			EndIf
		
			If Alltrim(NC4->NC4_CODERR) == "00001" //"ERRO:Não foi possivel encontrar o local informado no sistema"
				//NC2_FILIAL+DTOS(NC2_DATA)+NC2_HORA+NC2_SEQUEN
				//NC4_FILIAL+DTOS(NC4_DATA)+NC4_HORA+NC4_SEQSIN+NC4_SEQUEN  
				DbSelectArea("NNR")
				DbSetOrder(1)
				If DbSeek(xFilial("NNR") + ALLTRIM(POSICIONE("NC2",1,NC4->NC4_FILIAL+DTOS(NC4->NC4_DATA)+NC4->NC4_HORA+NC4->NC4_SEQSIN,"NC2_CODALT"))  ) // busca o local no sistema 
					If RecLock("NC4", .F.)
						NC4->NC4_STATUS := "2"
						NC4->NC4_DATATU := dDatabase
						NC4->NC4_HORATU := Time()
						NC4->(MsUnlock())
					EndIf
				EndIf
			
			ElseIf Alltrim(NC4->NC4_CODERR) == "00002" //"Erro no posicionamento/alocação da tabela de blocos para alteração do local"
				DbSelectArea("NC2")
				DbSetOrder(1)
				If DbSeek(cFilNC4+cDatNC41+cHoraNC4+NC4->NC4_SEQSIN)
					
					DbSelectArea("DXD")
					DbSetOrder(1)
					If DbSeek(NC2->NC2_CODUN) .AND. DXD->DXD_LOCAL == ALLTRIM(NC2->NC2_CODALT) //verifica se o codigo do local do bloco ja foi alterado
						If RecLock("NC4", .F.)
							NC4->NC4_STATUS := "2"
							NC4->NC4_DATATU := dDatabase
							NC4->NC4_HORATU := Time()
							NC4->(MsUnlock())
						EndIf
					EndIf
						
				EndIf
			ElseIf Alltrim(NC4->NC4_CODERR) == "00003" //"Erro no posicionamento/alocação da tabela de fardos para alteração do local"
				
				DbSelectArea("NC2")
				DbSetOrder(1)
				If DbSeek(cFilNC4+cDatNC41+cHoraNC4+NC4->NC4_SEQSIN) 
					
					DbSelectArea("DXI") //busca todos os fardo do bloco
					DbSetOrder(4)
					DbSeek(ALLTRIM(NC2->NC2_CODUN))
					While DXI->(!Eof()) .AND. DXI->DXI_FILIAL + DXI->DXI_SAFRA + DXI->DXI_BLOCO  == ALLTRIM(NC2->NC2_CODUN)
						
						If DXI->DXI_LOCAL <> ALLTRIM(NC2->NC2_CODALT) //verifica se há fardo que não tiveram seu local alterado
							lAlterado := .F.
						EndIf
						
						DXI->(DbSkip())
					EndDo
					
					If lAlterado //se não encontrar fardo não alterados
						If RecLock("NC4", .F.)
							NC4->NC4_STATUS := "2"
							NC4->NC4_DATATU := dDatabase
							NC4->NC4_HORATU := Time()
							NC4->(MsUnlock())
						EndIf						
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
/**---------------------------------------------------------------------
{Protheus.doc} UBW07Revisao
Revisão do movimento de bloco

@param: cCodUn, character, Código único (Filtro)
@param: cFilSinc, character, Filial da sincronização
@param: cDataSinc, character, Data da sincronização
@param: cHoraSinc, character, Hora da sincronização
@param: cSeqSinc, character, Sequencia da sincronização
@param: cValor, character, Valor da Alteração
@author: francisco.nunes
@since: 27/07/2018
---------------------------------------------------------------------**/
Function UBW07Revisao(cCodUn, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, cValor)
         
	DbSelectArea("NNR")
	DbSetOrder(1)
	If DbSeek(xFilial("NNR") + cValor ) // busca o local no sistema 
	
		DbSelectArea("DXD")
		DbSetOrder(1) //DXD_FILIAL+DXD_SAFRA+DXD_CODIGO
		If DbSeek(cCodUn) .AND. RecLock("DXD", .F.)    
			DXD->DXD_LOCAL  := cValor
	        DXD->DXD_DATATU := dDatabase
	        DXD->DXD_HORATU := Time()
			DXD->(MsUnLock())
		Else
			cCodErro := "00002"    	  	
			cErro    := "Erro no posicionamento/alocação da tabela de blocos para alteração do local"
		
			Aadd(aErros, {cCodErro, cErro})
		
		EndIf
	
		DbSelectArea("DXI")
		DbSetOrder(4)//DXI_FILIAL+DXI_SAFRA+DXI_BLOCO
		DbSeek(cCodUn)
		While DXI->(!Eof()) .AND. DXI->DXI_FILIAL + DXI->DXI_SAFRA + DXI->DXI_BLOCO  == ALLTRIM(cCodUn) 
			
			If RecLock("DXI", .F.)  
				DXI->DXI_LOCAL := cValor
				DXI->DXI_DATATU := dDatabase
				DXI->DXI_HORATU := Time()				
				DXI->(MsUnLock())
			Else
				cCodErro := "00003"    	  	
				cErro    := "Erro no posicionamento/alocação da tabela de fardos para alteração do local"
	
				Aadd(aErros, {cCodErro, cErro})		
			EndIf	
			DXI->(DbSkip())
		EndDo
	Else
		cCodErro := "00001"    	  	
		cErro    := "Não foi possivel encontrar o local informado no sistema"
		
		Aadd(aErros, {cCodErro, cErro})	
		lRetorno := .F.
	EndIf

Return aErros