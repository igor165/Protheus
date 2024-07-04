#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

Static aErros := {}

WSRESTFUL UBAW09 DESCRIPTION "Classificação visual do tipo de algodão"

WSMETHOD POST classification DESCRIPTION "Realiza a classificação do algodão"   PATH "/v1/classification" PRODUCES APPLICATION_JSON
WSMETHOD POST typeRevision   DESCRIPTION "Realiza a revisão do tipo do algodão" PATH "/v1/typeRevision"   PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD POST classification WSSERVICE UBAW09
	
	Local lPost		:= .F.
	Local oResponse := JsonObject():New()                   
    Local oRequest	:= JsonObject():New()
    Local cErro 	:= ""
              
	// define o tipo de retorno do método
	::SetContentType("application/json")
		           
    oRequest:fromJson(::GetContent())
                   
	cClassific := PADR(oRequest["classifierCode"], TamSX3('DXJ_CODCLA')[1])
	cTipoEnt   := oRequest["objectType"]
	cFiltro	   := oRequest["filterType"]
	cCodUn     := oRequest["uniqueCode"]
	cCodIni    := oRequest["initialCode"]
	cCodFin    := oRequest["finalCode"]
	cTipoClass := oRequest["typeClass"]
	cClassData := oRequest["classificationDate"]
	cClassHora := oRequest["classiticationHour"]
	cClassUsur := oRequest["classificationUser"] 
	
	If Empty(cClassific)
		cErro := "Classificador não informado."
	ElseIf Empty(cTipoEnt)
		cErro := "Tipo de entidade não informado."
	ElseIf Empty(cFiltro)
		cErro := "Tipo de filtro não informado."
	ElseIf cFiltro == "1" .AND. Empty(cCodUn)
		cErro := "Código único não informado."
	ElseIf cFiltro == "2" .AND. (Empty(cCodIni) .OR. Empty(cCodFin))
		cErro := "Intervalo não informado."	
	ElseIf Empty(cTipoClass)
		cErro := "Tipo de classificação não informado."
	ElseIf Empty(cClassData)
		cErro := "Data da classificação não informada."
	ElseIf Empty(cClassHora)
		cErro := "Hora da classificação não informada."
	ElseIf Empty(cClassUsur)
		cErro := "Usuário que realizou a classificação não informado."
	Else
		
		DbSelectArea("NNA")
		NNA->(DbSetOrder(1)) // NNA_FILIAL+NNA_CODIGO
		If !NNA->(DbSeek(FWxFilial("NNA")+cClassific))
			cErro := "Classificador informado não foi encontrado no sistema."		
		ElseIf Len(cTipoClass) != 4
			cErro := "Tipo de classificação informado incorreto."				
		Else			
			cTipo  := SUBSTR(cTipoClass, 1, 1)
			cCor   := SUBSTR(cTipoClass, 2, 1)
			cDiv   := SUBSTR(cTipoClass, 3, 1)
			cFolha := SUBSTR(cTipoClass, 4, 1)
			
			If (!cTipo $ "1|2|3|4|5|6|7|8") .OR. (!cCor $ "1|2|3|4|5|6") .OR. (cDiv != "-") .OR. (!cFolha $ "1|2|3|4|5|6|7")
				cErro := "Tipo de classificação informado incorreto."
			EndIf		
		EndIf
		
	EndIf
	
	If Empty(cErro)
	
		BEGIN TRANSACTION
		
			If cTipoEnt == "2" // Mala
				cTpEnt := "3"
			Else // Fardo
				cTpEnt := "1"
			EndIf
		
			// Inclusão da sincronização
			oChvSinc := UBIncSinc("3",cTpEnt,cFiltro,cCodUn,cCodIni,cCodFin,cClassData,cClassHora,cClassUsur,"", cTipoClass, cClassific)
			
			cFilSinc  := oChvSinc[1]
			cDataSinc := oChvSinc[2]
			cHoraSinc := oChvSinc[3]
			cSeqSinc  := oChvSinc[4]
			
			// Classificação do algodão
			UBW09Class(cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin, cClassData, cClassHora, cClassUsur, cTipoClass, cClassific, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
										
		END TRANSACTION		
	EndIf
	
	If Len(aErros) > 0 .OR. !Empty(cErro)
		lPost := .F.
		
		If Len(aErros) > 0
			cErro := "Ocorreu erro de negócio na classificação."		
		EndIf
		
		SetRestFault(400, EncodeUTF8(cErro))
	Else		
		lPost := .T.
					
		oResponse["content"] := JsonObject():New()	
    	oResponse["content"]["Message"]	:= "Classificação realizada com sucesso."
		
		cRetorno := EncodeUTF8(FWJsonSerialize(oResponse, .F., .F., .T.))    	
	    
	    ::SetResponse(cRetorno)		
	EndIf

Return lPost

/**---------------------------------------------------------------------
{Protheus.doc} UBW09Class
Classificação do algodão

@param: cTipoEnt, character, Tipo de entidade (1=Fardo;2=Mala)
@param: cFiltro, character, Tipo de filtro (1=Código único;2=Intervalo)
@param: cCodUn, character, Código único (Filtro)
@param: cCodIni, character, Código inicial (Filtro Intervalo)
@param: cCodFin, character, Código final (Filtro Intervalo)
@param: cClassData, character, Data da classificação
@param: cClassHora, character, Hora da classificação
@param: cClassUsur, character, Usuário que realizou a classificação
@param: cTipoClass, character, Tipo de classificação
@param: cClassific, character, Código do classificador
@param: cFilSinc, character, Filial da sincronização
@param: cDataSinc, character, Data da sincronização
@param: cHoraSinc, character, Hora da sincronização
@param: cSeqSinc, character, Sequencia da sincronização
@author: francisco.nunes
@since: 27/07/2018
---------------------------------------------------------------------**/
Function UBW09Class(cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin, cClassData, cClassHora, cClassUsur, cTipoClass, cClassific, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
		
	Local oEntidade	:= {}
    Local aFardos	:= {}
    Local aMalas	:= {}
    Local nIt		:= 0  
    Local cStatusMl	:= ""    
    
    // Buscar os fardos e malas que receberão a classificação de acordo com os campos de filtro informados
	oEntidade := UBW09GetEnt(cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
	
	If Len(aErros) == 0
		aFardos := oEntidade[1]
		aMalas  := oEntidade[2]  
	
		If Len(aFardos) = 0	
			cCodErro := "00001"
			cErro 	 := "Não foram encontrados fardos para classificação."
			
			Aadd(aErros, {cCodErro, cErro})
			
			// Inclusão do erro de sincronização na tabela NC4
			UBIncErro(cFilSinc,cDataSinc,cHoraSinc,cSeqSinc,cCodErro,cErro)
		EndIf
	EndIf
	
	If Len(aErros) == 0
	
		If ValType(cClassData) != "D"
			cClassData := cToD(SUBSTR(cClassData, 7, 2) + "/" + SUBSTR(cClassData, 5, 2) + "/" + SUBSTR(cClassData, 1, 4))
		EndIf
		
		DbSelectArea("DXI")
		DbSelectArea("DXK")
				
		For nIt := 1 to Len(aFardos)
		
			nRecnoDXI := aFardos[nIt][1]
			nRecnoDXK := aFardos[nIt][2]
		
			DXI->(DbGoTo(nRecnoDXI))	
			If !DXI->(Eof())
			
				If RecLock("DXI", .F.)							
					DXI->DXI_CLAVIS := cTipoClass
		        	DXI->DXI_CLACOM := cTipoClass
		        	DXI->DXI_DATATU := dDatabase
		        	DXI->DXI_HORATU := Time()
		        	
		        	If DXI->DXI_STATUS == "10" // Beneficiamento
		        		DXI->DXI_STATUS := "20" // Classificado
		        	EndIf
		        		        	
		        	DXI->(MsUnLock())						
				EndIf
			EndIf
			
			DXK->(DbGoTo(nRecnoDXK))	
			If !DXK->(Eof())
			
				If RecLock("DXK", .F.)							
					DXK->DXK_CLAVIS := cTipoClass
					
	        		DXK->(MsUnLock())						
				EndIf														
			EndIf
		
		Next nIt	
		
		DbSelectArea("DXJ")
		DXJ->(DbSetOrder(1)) // DXJ_FILIAL+DXJ_CODIGO+DXJ_TIPO
		
		For nIt := 1 to Len(aMalas)
																			
			If DXJ->(DbSeek(aMalas[nIt]))
											
				cAlias := GetNextAlias()
			    cQuery := " SELECT 1 "  
			    cQuery += "   FROM " + RetSqlName("DXK") + " DXK "
			    cQuery += "  WHERE DXK.DXK_FILIAL = '" + DXJ->DXJ_FILIAL + "' "
			    cQuery += "    AND DXK.DXK_CODROM = '" + DXJ->DXJ_CODIGO + "' "
			    cQuery += "    AND DXK.DXK_TIPO   = '1' "
			    cQuery += "    AND DXK.DXK_CLAVIS = '' "
			    cQuery += "    AND DXK.D_E_L_E_T_ <> '*' "
			    
			    cQuery := ChangeQuery(cQuery)
			    MPSysOpenQuery(cQuery, cAlias)
			    
			    If (cAlias)->(!Eof())
			    	cStatusMl := "2"
			    Else
			    	cStatusMl := "3"
			    EndIf
			    
			    (cAlias)->(DbCloseArea())
				
				If RecLock("DXJ", .F.)
					DXJ->DXJ_DTCLAS := cClassData
					DXJ->DXJ_DATANA := cClassData
		        	DXJ->DXJ_HORANA := cClassHora
		        	DXJ->DXJ_USRANA := cClassUsur
		        	DXJ->DXJ_CODCLA := cClassific
    				DXJ->DXJ_STATUS := cStatusMl
    				DXJ->DXJ_DATATU := dDatabase
    				DXJ->DXJ_HORATU := Time()
    				DXJ->(MsUnlock())		        				
    			EndIf					
			EndIf
		
		Next nIt
	EndIf
	
	If Len(aErros) > 0
		// Alteração do status da sincronização para "2=Erro de sincronização"
		UBAltStSin(cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, "2")
	EndIf

Return aErros

/*{Protheus.doc} UBW09GetEnt
Busca os fardos e malas que receberão a classificação

@author francisco.nunes
@since 19/07/2018
@param cTipoEnt, characters, Tipo de entidade do filtro (1=Fardo;2=Mala)
@param cFiltro,  characters, Tipo de filtro (1=Código único;2=Intervalo)
@param cCodUn,   characters, Código único
@param cCodIni,  characters, Código de barras inicial
@param cCodFin,  characters, Código de barras final
@param cFilSinc, character, Filial da sincronização
@param cDataSinc, character, Data da sincronização
@param cHoraSinc, character, Hora da sincronização
@param: cSeqSinc, character, Sequencia da sincronização
@param: lChecCor, logical, .T. - Checagem do erro (Não é inserido novos erros); .F. - Outros
@type function
*/
Static Function UBW09GetEnt(cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, lChecCor)
	
	Local oEntidade := {}
	Local aFardos  	:= {}
	Local aMalas  	:= {}	
	Local cChave	:= ""
	Local lNovaMl	:= .T.
	
	Default lChecCor := .F.

	cAlias := GetNextAlias()
    cQuery := " SELECT DXI.R_E_C_N_O_ AS DXI_REC, "
    cQuery += "        DXK.R_E_C_N_O_ AS DXK_REC, "
    cQuery += "        DXI.DXI_FILIAL, "
    cQuery += "        DXI.DXI_ETIQ, "
    cQuery += "        DXJ.DXJ_FILIAL, "
    cQuery += "        DXJ.DXJ_CODBAR, "
    cQuery += "        DXJ.DXJ_CODIGO, "
    cQuery += "        DXJ.DXJ_TIPO, "    
    cQuery += "        DXJ.DXJ_DATREC "
    cQuery += "   FROM " + RetSqlName("DXI") + " DXI "
    cQuery += " LEFT JOIN " + RetSqlName("DXK") + " DXK ON DXK.DXK_SAFRA = DXI.DXI_SAFRA AND DXK.DXK_ETIQ = DXI.DXI_ETIQ " 
    cQuery += "   AND DXK.DXK_TIPO = '1' AND DXK.D_E_L_E_T_ <> '*' "
    cQuery += " LEFT JOIN " + RetSqlName("DXJ") + " DXJ ON DXJ.DXJ_FILIAL = DXK.DXK_FILIAL AND DXJ.DXJ_CODIGO = DXK.DXK_CODROM "
    cQuery += "   AND DXJ.DXJ_TIPO = DXK.DXK_TIPO AND DXJ.D_E_L_E_T_ <> '*' "
    cQuery += " WHERE DXI.D_E_L_E_T_ <> '*' "
    
    If cTipoEnt == "1" // Fardo
    
    	If cFiltro == "1" // Código único    	
    		cQuery += " AND DXI.DXI_ETIQ = '" + cCodUn + "' "
    	Else
    		cQuery += " AND DXI.DXI_ETIQ BETWEEN '" + cCodIni + "' AND '" + cCodFin + "' " 
    	EndIf
    	
    ElseIf cTipoEnt == "2" // Mala
    	
    	If cFiltro == "1" // Código único    	
    		cQuery += " AND DXJ.DXJ_CODBAR = '" + cCodUn + "' "
    	Else
    		cQuery += " AND DXJ.DXJ_CODBAR BETWEEN '" + cCodIni + "' AND '" + cCodFin + "' "
    	EndIf
    	
    EndIf   
    	
	cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)
    	
	If (cAlias)->(!Eof())
        While (cAlias)->(!Eof())
        
        	If !Empty((cAlias)->DXI_REC)        	
        		Aadd(aFardos, {(cAlias)->DXI_REC, (cAlias)->DXK_REC})
        	EndIf
        	
        	cErro := ""
        	
        	If Empty((cAlias)->DXK_REC) .AND. !lChecCor      		
    			cCodErro := "00002"
        		cErro    := "Não foi encontrada mala para o fardo. "
        		
        		Aadd(aErros, {cCodErro, cErro})
        		
        		// Inclusão do erro de sincronização na tabela NC4
        		UBIncErro(cFilSinc,cDataSinc,cHoraSinc,cSeqSinc,cCodErro,cErro,"1",(cAlias)->DXI_FILIAL,(cAlias)->DXI_ETIQ)
	        EndIf 
	        	        
	        If Empty(cErro)
	        	
	        	cChave := PADR((cAlias)->DXJ_FILIAL, TamSX3('DXJ_FILIAL')[1])
	        	cChave += PADR((cAlias)->DXJ_CODIGO, TamSX3('DXJ_CODIGO')[1])
	        	cChave += PADR((cAlias)->DXJ_TIPO, TamSX3('DXJ_TIPO')[1])
	        	
	        	lNovaMl := .F.
						
				If Len(aMalas) > 0
					
					nPos := aScan(aMalas, cChave)
					
					If nPos == 0					
						Aadd(aMalas, cChave)
						lNovaMl := .T.
					EndIf
				Else
					Aadd(aMalas, cChave)
					lNovaMl := .T.
				EndIf		     
				
				If Empty((cAlias)->DXJ_DATREC) .AND. lNovaMl .AND. !lChecCor
		        	cCodErro := "00003"
		        	cErro	 := "Mala a ser classificada não foi recebida."
		        	
		        	Aadd(aErros, {cCodErro, cErro})
		        
		        	// Inclusão do erro de sincronização na tabela NC4
	        		UBIncErro(cFilSinc,cDataSinc,cHoraSinc,cSeqSinc,cCodErro,cErro,"3",(cAlias)->DXJ_FILIAL,(cAlias)->DXJ_CODBAR)
		        EndIf
				   	
	        EndIf
        	        	        	        
        	(cAlias)->(DbSkip())
        EndDo
    EndIf

	(cAlias)->(DbCloseArea())	
	
	If Len(aErros) == 0
		oEntidade := {aFardos, aMalas}
	EndIf	

Return oEntidade

WSMETHOD POST typeRevision WSSERVICE UBAW09
	
	Local lPost		 := .F.
	Local oResponse  := JsonObject():New()                   
    Local oRequest	 := JsonObject():New()    
    Local cErro 	 := ""
    Local oChvSinc	 := {}
    Local cFilSinc   := ""
    Local cDataSinc  := ""
    Local cHoraSinc  := ""
    Local cSeqSinc	 := "" 
        
	// define o tipo de retorno do método
	::SetContentType("application/json")
		           
    oRequest:fromJson(::GetContent())
    
    cCodUn     := oRequest["uniqueCode"]
	cTipoClass := oRequest["typeClass"]
	
	If Empty(cCodUn) 
		cErro := "Código único não informado."
	ElseIf Empty(cTipoClass)
		cErro := "Tipo de classificação não informado."
	Else
		
		If Len(cTipoClass) != 4		
			cErro := "Tipo de classificação informado incorreto."			
		Else			
			cTipo  := SUBSTR(cTipoClass, 1, 1)
			cCor   := SUBSTR(cTipoClass, 2, 1)
			cDiv   := SUBSTR(cTipoClass, 3, 1)
			cFolha := SUBSTR(cTipoClass, 4, 1)
			
			If (!cTipo $ "1|2|3|4|5|6|7|8") .OR. (!cCor $ "1|2|3|4|5|6") .OR. (cDiv != "-") .OR. (!cFolha $ "1|2|3|4|5|6|7")				
				cErro := "Tipo de classificação informado incorreto."
			EndIf						
		EndIf
		
	EndIf
	
	If Empty(cErro)
		    	
		BEGIN TRANSACTION
		
			// Inclusão da sincronização
			oChvSinc := UBIncSinc("5","2","1",cCodUn,"","","","","","", cTipoClass)
				
			cFilSinc  := oChvSinc[1]
			cDataSinc := oChvSinc[2]
			cHoraSinc := oChvSinc[3]
			cSeqSinc  := oChvSinc[4]
			
			// Revisão do tipo de classificação
			UBW09TeRev(cCodUn, cTipoClass, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
					    		    		   
		END TRANSACTION
	
	EndIf
		
	If Len(aErros) == 0	.AND. Empty(cErro)
		lPost := .T.
	
		oResponse["content"] := JsonObject():New()			
		oResponse["content"]["Message"]	:=  "Revisão do tipo realizada com sucesso."
							            
		cResponse := EncodeUTF8(FWJsonSerialize(oResponse, .F., .F., .T.))
		::SetResponse(cResponse)
	Else
		lPost := .F.
		
		If Len(aErros) > 0
			cErro := "Ocorreu erro de negócio na revisão do tipo."			
		EndIf
			
		SetRestFault(400, EncodeUTF8(cErro))
	EndIf

Return lPost

/**---------------------------------------------------------------------
{Protheus.doc} UBW09TeRev
Revisão do tipo de classificação

@param: cCodUn, character, Código único (Filtro)
@param: cTipoClass, character, Tipo de classificação
@param: cFilSinc, character, Filial da sincronização
@param: cDataSinc, character, Data da sincronização
@param: cHoraSinc, character, Hora da sincronização
@param: cSeqSinc, character, Sequencia da sincronização
@author: francisco.nunes
@since: 27/07/2018
---------------------------------------------------------------------**/
Function UBW09TeRev(cCodUn, cTipoClass, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)

	Local nRecnoBlc := 0
	Local cCodErro	:= ""
	Local cErro		:= ""

	nRecnoBlc := UBW09GetBlc(cCodUn, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
		
	If Len(aErros) == 0	.AND. nRecnoBlc == 0
		cCodErro := "00002"
		cErro    := "Não foi encontrado bloco para revisão do tipo de classificação."
		
		Aadd(aErros, {cCodErro, cErro})
		
		// Inclusão do erro de sincronização na tabela NC4
		UBIncErro(cFilSinc,cDataSinc,cHoraSinc,cSeqSinc,cCodErro,cErro)
	EndIf
	
	If Len(aErros) == 0
	
		DbSelectArea('DXD')
		DXD->(DbGoTo(nRecnoBlc))	
		If !DXD->(Eof())	
		  
			If RecLock("DXD", .F.)
	        	DXD->DXD_CLACOM := cTipoClass
	        	DXD->DXD_DATATU	:= dDatabase
				DXD->DXD_HORATU := Time()
				        	
	        	DXD->(MsUnLock())
	        EndIf
	        
	        DbSelectArea("DXI")
			DXI->(DbSetOrder(4)) // DXI_FILIAL+DXI_SAFRA+DXI_BLOCO
			If DXI->(DbSeek(DXD->DXD_FILIAL+DXD->DXD_SAFRA+DXD->DXD_CODIGO))
				While !DXI->(Eof()) .AND. DXI->(DXI_FILIAL+DXI_SAFRA+DXI_BLOCO) == DXD->DXD_FILIAL+DXD->DXD_SAFRA+DXD->DXD_CODIGO
					
					If RecLock("DXI", .F.)
						DXI->DXI_CLACOM := cTipoClass
						
						DXI->(MsUnlock())
					EndIf
					
					DXI->(DbSkip())
				EndDo        			
			EndIf				     
	    EndIf
	EndIf
    
    If Len(aErros) > 0
		// Alteração do status da sincronização para "2=Erro de sincronização"
		UBAltStSin(cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, "2")
	EndIf

Return aErros

/*{Protheus.doc} UBW09GetBlc
Busca o recno do bloco que receberá a revisão do tipo de classificação

@author francisco.nunes
@since 19/07/2018
@param cCodUn, characters, Código único do bloco
@param: cFilSinc, character, Filial da sincronização
@param: cDataSinc, character, Data da sincronização
@param: cHoraSinc, character, Hora da sincronização
@param: cSeqSinc, character, Sequencia da sincronização
@param: lChecCor, logical, .T. - Checagem do erro (Não é inserido novos erros); .F. - Outros
@return: nRecnoBlc, number, Recno do bloco a ser reclassificado
@type function
*/
Static Function UBW09GetBlc(cCodUn, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, lChecCor)

	Local nRecnoBlc := 0
	Local cCodErro	:= ""
	Local cErro		:= ""
	
	Default lChecCor := .F.
		
	cAlias := GetNextAlias()
    cQuery := " SELECT DXD.R_E_C_N_O_ AS DXD_REC, "
    cQuery += "        DXD.DXD_FILIAL, "
    cQuery += "        DXD.DXD_CODUNI, "
    cQuery += "        DXQ.DXQ_CODRES "
    cQuery += "   FROM " + RetSqlName("DXD") + " DXD "
    cQuery += " LEFT JOIN " + RetSqlName("DXQ") + " DXQ ON DXQ.DXQ_FILORG = DXD.DXD_FILIAL AND DXQ.DXQ_SAFRA = DXD.DXD_SAFRA "
    cQuery += "   AND DXQ.DXQ_BLOCO = DXD.DXD_CODIGO AND DXQ.D_E_L_E_T_ <> '*' "
    cQuery += "  WHERE DXD.DXD_STATUS = '3' " // 3 - Finalizado
    cQuery += "    AND DXD.D_E_L_E_T_ <> '*' "
    cQuery += "    AND DXD.DXD_CODUNI = '" + cCodUn + "' "
	
    cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)
    	
	If (cAlias)->(!Eof())		
		
		If !Empty((cAlias)->DXQ_CODRES) .AND. !lChecCor
			cCodErro := "00001"
			cErro    := "Bloco não pode ser reclassificado, pois está reservado."
			
			Aadd(aErros, {cCodErro, cErro})
			
			// Inclusão do erro de sincronização na tabela NC4
			UBIncErro(cFilSinc,cDataSinc,cHoraSinc,cSeqSinc,cCodErro,cErro,"2",(cAlias)->DXD_FILIAL,(cAlias)->DXD_CODUNI)
		Else
			nRecnoBlc := (cAlias)->DXD_REC
		EndIf		
    EndIf

	(cAlias)->(DbCloseArea())
	    
Return nRecnoBlc

/*{Protheus.doc} UBW09CERR
Verificar se os erros relacionados a classificação / revisão do tipo foram corrigidos
Caso sejam, será modificado o status do erro da sincronização para corrigido

@author francisco.nunes
@since 30/07/2018
@param: cFilNC4, character, Filial da sincronização
@param: cDatNC4, character, Data da sincronização
@param: cHoraNC4, character, Hora da sincronização
@param: cTpOpe, character, Tipo de operação (1=Classificação;2=Revisão do tipo)
@param: cTipoEnt, character, Tipo de entidade (1=Fardo;2=Mala)
@param: cFiltro, character, Tipo de filtro (1=Código único;2=Intervalo)
@param: cCodUn, character, Código único (Filtro)
@param: cCodIni, character, Código inicial (Filtro Intervalo)
@param: cCodFin, character, Código final (Filtro Intervalo)
@return: lErroSinc, boolean, .T. - Possui erro de sincronismo; .F. - Não possui erro de sincronismo
@type function
*/
Function UBW09CERR(cFilNC4, cDatNC4, cHoraNC4, cTpOpe, cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin)

	Local lErroSinc := .F.
	Local cDatNC41  := ""
	Local cDatNC42  := ""
	
	cDatNC41 := Year2Str(Year(cDatNC4)) + Month2Str(Month(cDatNC4)) + Day2Str(Day(cDatNC4))
	
	DbSelectArea("NC4")
	NC4->(DbSetOrder(1)) // NC4_FILIAL+NC4_DATA+NC4_HORA
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
		
			If cTpOpe == "1" // Classificação
				lErroSinc := UBW09CCLAS(cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin, cFilNC4, cDatNC4, cHoraNC4)
			ElseIf cTpOpe == "2" // Revisão do tipo
				lErroSinc := UBW09CTPRV(cCodUn, cFilNC4, cDatNC4, cHoraNC4)
			EndIf
		
			If NC4->(NC4_STATUS) == "1"
				lErroSinc := .T.
			EndIf
										
			NC4->(DbSkip())
		EndDo
	EndIf

Return lErroSinc

/*{Protheus.doc} UBW09CERR
Verificar se os erros relacionados a classificação
Caso sejam, será modificado o status do erro da sincronização para corrigido

@author francisco.nunes
@since 30/07/2018
@param: cTipoEnt, character, Tipo de entidade (1=Fardo;2=Mala)
@param: cFiltro, character, Tipo de filtro (1=Código único;2=Intervalo)
@param: cCodUn, character, Código único (Filtro)
@param: cCodIni, character, Código inicial (Filtro Intervalo)
@param: cCodFin, character, Código final (Filtro Intervalo)
@param: cFilSinc, character, Filial da sincronização
@param: cDataSinc, character, Data da sincronização
@param: cHoraSinc, character, Hora da sincronização
@param: cSeqSinc, character, Sequencia da sincronização
@return: lErroSinc, boolean, .T. - Possui erro de sincronismo; .F. - Não possui erro de sincronismo
@type function
*/
Static Function UBW09CCLAS(cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
	
	Local lErroSinc := .F.
	Local oEntidade := {}
	
	If Alltrim(NC4->NC4_CODERR) == "00001"
		// Buscar os fardos e malas que receberão a classificação de acordo com os campos de filtro informados
		oEntidade := UBW09GetEnt(cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, .T.)
								
		aFardos := oEntidade[1] 
	
		If Len(aFardos) > 0 .OR. Len(aErros) > 0
			If RecLock("NC4", .F.)
				NC4->NC4_STATUS := "2"
				NC4->NC4_DATATU := dDatabase
				NC4->NC4_HORATU := Time()
				NC4->(MsUnlock())
			EndIf
		EndIf		
		
		If Len(aErros) > 0
			lErroSinc := .T.
		EndIf		
	ElseIf Alltrim(NC4->NC4_CODERR) == "00002"
		
		cAlias := GetNextAlias()
	    cQuery := " SELECT 1 "	    
	    cQuery += "   FROM " + RetSqlName("DXI") + " DXI "
	    cQuery += " INNER JOIN " + RetSqlName("DXK") + " DXK ON DXK.DXK_SAFRA = DXI.DXI_SAFRA AND DXK.DXK_ETIQ = DXI.DXI_ETIQ " 
	    cQuery += "   AND DXK.DXK_TIPO = '1' AND DXK.D_E_L_E_T_ <> '*' "
	    cQuery += "   AND DXI.DXI_FILIAL = '" + NC4->NC4_FILENT + "' "
	    cQuery += "   AND DXI.DXI_ETIQ   = '" + NC4->NC4_CODBAR + "' "
	    
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
	        	   		
	ElseIf Alltrim(NC4->NC4_CODERR) == "00003"
	
		DbSelectArea("DXJ")
		DXJ->(DbSetOrder(2)) // DXJ_FILIAL+DXJ_CODBAR
		If DXJ->(DbSeek(NC4->NC4_FILENT+NC4->NC4_CODBAR))	
			If !Empty(DXJ->DXJ_DATREC)
				If RecLock("NC4", .F.)
					NC4->NC4_STATUS := "2"
					NC4->NC4_DATATU := dDatabase
					NC4->NC4_HORATU := Time()
					NC4->(MsUnlock())
				EndIf
			EndIf		
		EndIf
						
	EndIf
	
Return lErroSinc

/*{Protheus.doc} UBW09CTPRV
Verificar se os erros relacionados a revisão do tipo de classificação
Caso sejam, será modificado o status do erro da sincronização para corrigido

@author francisco.nunes
@since 30/07/2018
@param: cCodUn, character, Código único (Filtro)
@param: cFilSinc, character, Filial da sincronização
@param: cDataSinc, character, Data da sincronização
@param: cHoraSinc, character, Hora da sincronização
@param: cSeqSinc, character, Sequencia da sincronização
@return: lErroSinc, boolean, .T. - Possui erro de sincronismo; .F. - Não possui erro de sincronismo
@type function
*/
Static Function UBW09CTPRV(cCodUn, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
	
	Local lErroSinc := .F.
	Local nRecnoBlc := 0	
	
	If Alltrim(NC4->NC4_CODERR) == "00001"		
		cAlias := GetNextAlias()
	    cQuery := " SELECT DXQ.DXQ_CODRES "
	    cQuery += "   FROM " + RetSqlName("DXD") + " DXD "
	    cQuery += " INNER JOIN " + RetSqlName("DXQ") + " DXQ ON DXQ.DXQ_FILORG = DXD.DXD_FILIAL AND DXQ.DXQ_SAFRA = DXD.DXD_SAFRA "
	    cQuery += "   AND DXQ.DXQ_BLOCO = DXD.DXD_CODIGO AND DXQ.D_E_L_E_T_ <> '*' "
	    cQuery += "  WHERE DXD.DXD_FILIAL = '" + NC4->NC4_FILENT + "' "
	    cQuery += "    AND DXD.DXD_CODUNI = '" + NC4->NC4_CODBAR + "' "
	    
	    cQuery := ChangeQuery(cQuery)
	    MPSysOpenQuery(cQuery, cAlias)
    	
	    If (cAlias)->(Eof())
	    	If RecLock("NC4", .F.)
				NC4->NC4_STATUS := "2"
				NC4->NC4_DATATU := dDatabase
				NC4->NC4_HORATU := Time()
				NC4->(MsUnlock())
			EndIf
	    EndIf
		
	ElseIf Alltrim(NC4->NC4_CODERR) == "00002"
	
		nRecnoBlc := UBW09GetBlc(cCodUn, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, .T.)
	
		If nRecnoBlc > 0 .OR. Len(aErros) > 0
			If RecLock("NC4", .F.)
				NC4->NC4_STATUS := "2"
				NC4->NC4_DATATU := dDatabase
				NC4->NC4_HORATU := Time()
				NC4->(MsUnlock())
			EndIf
		EndIf	
		
		If Len(aErros) > 0
			lErroSinc := .T.
		EndIf
	EndIf		
	
Return lErroSinc	