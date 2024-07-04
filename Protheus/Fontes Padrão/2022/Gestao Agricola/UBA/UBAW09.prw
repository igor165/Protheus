#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

Static aErros := {}

WSRESTFUL UBAW09 DESCRIPTION "Classifica��o visual do tipo de algod�o"

WSMETHOD POST classification DESCRIPTION "Realiza a classifica��o do algod�o"   PATH "/v1/classification" PRODUCES APPLICATION_JSON
WSMETHOD POST typeRevision   DESCRIPTION "Realiza a revis�o do tipo do algod�o" PATH "/v1/typeRevision"   PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD POST classification WSSERVICE UBAW09
	
	Local lPost		:= .F.
	Local oResponse := JsonObject():New()                   
    Local oRequest	:= JsonObject():New()
    Local cErro 	:= ""
              
	// define o tipo de retorno do m�todo
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
		cErro := "Classificador n�o informado."
	ElseIf Empty(cTipoEnt)
		cErro := "Tipo de entidade n�o informado."
	ElseIf Empty(cFiltro)
		cErro := "Tipo de filtro n�o informado."
	ElseIf cFiltro == "1" .AND. Empty(cCodUn)
		cErro := "C�digo �nico n�o informado."
	ElseIf cFiltro == "2" .AND. (Empty(cCodIni) .OR. Empty(cCodFin))
		cErro := "Intervalo n�o informado."	
	ElseIf Empty(cTipoClass)
		cErro := "Tipo de classifica��o n�o informado."
	ElseIf Empty(cClassData)
		cErro := "Data da classifica��o n�o informada."
	ElseIf Empty(cClassHora)
		cErro := "Hora da classifica��o n�o informada."
	ElseIf Empty(cClassUsur)
		cErro := "Usu�rio que realizou a classifica��o n�o informado."
	Else
		
		DbSelectArea("NNA")
		NNA->(DbSetOrder(1)) // NNA_FILIAL+NNA_CODIGO
		If !NNA->(DbSeek(FWxFilial("NNA")+cClassific))
			cErro := "Classificador informado n�o foi encontrado no sistema."		
		ElseIf Len(cTipoClass) != 4
			cErro := "Tipo de classifica��o informado incorreto."				
		Else			
			cTipo  := SUBSTR(cTipoClass, 1, 1)
			cCor   := SUBSTR(cTipoClass, 2, 1)
			cDiv   := SUBSTR(cTipoClass, 3, 1)
			cFolha := SUBSTR(cTipoClass, 4, 1)
			
			If (!cTipo $ "1|2|3|4|5|6|7|8") .OR. (!cCor $ "1|2|3|4|5|6") .OR. (cDiv != "-") .OR. (!cFolha $ "1|2|3|4|5|6|7")
				cErro := "Tipo de classifica��o informado incorreto."
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
		
			// Inclus�o da sincroniza��o
			oChvSinc := UBIncSinc("3",cTpEnt,cFiltro,cCodUn,cCodIni,cCodFin,cClassData,cClassHora,cClassUsur,"", cTipoClass, cClassific)
			
			cFilSinc  := oChvSinc[1]
			cDataSinc := oChvSinc[2]
			cHoraSinc := oChvSinc[3]
			cSeqSinc  := oChvSinc[4]
			
			// Classifica��o do algod�o
			UBW09Class(cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin, cClassData, cClassHora, cClassUsur, cTipoClass, cClassific, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
										
		END TRANSACTION		
	EndIf
	
	If Len(aErros) > 0 .OR. !Empty(cErro)
		lPost := .F.
		
		If Len(aErros) > 0
			cErro := "Ocorreu erro de neg�cio na classifica��o."		
		EndIf
		
		SetRestFault(400, EncodeUTF8(cErro))
	Else		
		lPost := .T.
					
		oResponse["content"] := JsonObject():New()	
    	oResponse["content"]["Message"]	:= "Classifica��o realizada com sucesso."
		
		cRetorno := EncodeUTF8(FWJsonSerialize(oResponse, .F., .F., .T.))    	
	    
	    ::SetResponse(cRetorno)		
	EndIf

Return lPost

/**---------------------------------------------------------------------
{Protheus.doc} UBW09Class
Classifica��o do algod�o

@param: cTipoEnt, character, Tipo de entidade (1=Fardo;2=Mala)
@param: cFiltro, character, Tipo de filtro (1=C�digo �nico;2=Intervalo)
@param: cCodUn, character, C�digo �nico (Filtro)
@param: cCodIni, character, C�digo inicial (Filtro Intervalo)
@param: cCodFin, character, C�digo final (Filtro Intervalo)
@param: cClassData, character, Data da classifica��o
@param: cClassHora, character, Hora da classifica��o
@param: cClassUsur, character, Usu�rio que realizou a classifica��o
@param: cTipoClass, character, Tipo de classifica��o
@param: cClassific, character, C�digo do classificador
@param: cFilSinc, character, Filial da sincroniza��o
@param: cDataSinc, character, Data da sincroniza��o
@param: cHoraSinc, character, Hora da sincroniza��o
@param: cSeqSinc, character, Sequencia da sincroniza��o
@author: francisco.nunes
@since: 27/07/2018
---------------------------------------------------------------------**/
Function UBW09Class(cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin, cClassData, cClassHora, cClassUsur, cTipoClass, cClassific, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
		
	Local oEntidade	:= {}
    Local aFardos	:= {}
    Local aMalas	:= {}
    Local nIt		:= 0  
    Local cStatusMl	:= ""    
    
    // Buscar os fardos e malas que receber�o a classifica��o de acordo com os campos de filtro informados
	oEntidade := UBW09GetEnt(cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
	
	If Len(aErros) == 0
		aFardos := oEntidade[1]
		aMalas  := oEntidade[2]  
	
		If Len(aFardos) = 0	
			cCodErro := "00001"
			cErro 	 := "N�o foram encontrados fardos para classifica��o."
			
			Aadd(aErros, {cCodErro, cErro})
			
			// Inclus�o do erro de sincroniza��o na tabela NC4
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
		// Altera��o do status da sincroniza��o para "2=Erro de sincroniza��o"
		UBAltStSin(cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, "2")
	EndIf

Return aErros

/*{Protheus.doc} UBW09GetEnt
Busca os fardos e malas que receber�o a classifica��o

@author francisco.nunes
@since 19/07/2018
@param cTipoEnt, characters, Tipo de entidade do filtro (1=Fardo;2=Mala)
@param cFiltro,  characters, Tipo de filtro (1=C�digo �nico;2=Intervalo)
@param cCodUn,   characters, C�digo �nico
@param cCodIni,  characters, C�digo de barras inicial
@param cCodFin,  characters, C�digo de barras final
@param cFilSinc, character, Filial da sincroniza��o
@param cDataSinc, character, Data da sincroniza��o
@param cHoraSinc, character, Hora da sincroniza��o
@param: cSeqSinc, character, Sequencia da sincroniza��o
@param: lChecCor, logical, .T. - Checagem do erro (N�o � inserido novos erros); .F. - Outros
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
    
    	If cFiltro == "1" // C�digo �nico    	
    		cQuery += " AND DXI.DXI_ETIQ = '" + cCodUn + "' "
    	Else
    		cQuery += " AND DXI.DXI_ETIQ BETWEEN '" + cCodIni + "' AND '" + cCodFin + "' " 
    	EndIf
    	
    ElseIf cTipoEnt == "2" // Mala
    	
    	If cFiltro == "1" // C�digo �nico    	
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
        		cErro    := "N�o foi encontrada mala para o fardo. "
        		
        		Aadd(aErros, {cCodErro, cErro})
        		
        		// Inclus�o do erro de sincroniza��o na tabela NC4
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
		        	cErro	 := "Mala a ser classificada n�o foi recebida."
		        	
		        	Aadd(aErros, {cCodErro, cErro})
		        
		        	// Inclus�o do erro de sincroniza��o na tabela NC4
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
        
	// define o tipo de retorno do m�todo
	::SetContentType("application/json")
		           
    oRequest:fromJson(::GetContent())
    
    cCodUn     := oRequest["uniqueCode"]
	cTipoClass := oRequest["typeClass"]
	
	If Empty(cCodUn) 
		cErro := "C�digo �nico n�o informado."
	ElseIf Empty(cTipoClass)
		cErro := "Tipo de classifica��o n�o informado."
	Else
		
		If Len(cTipoClass) != 4		
			cErro := "Tipo de classifica��o informado incorreto."			
		Else			
			cTipo  := SUBSTR(cTipoClass, 1, 1)
			cCor   := SUBSTR(cTipoClass, 2, 1)
			cDiv   := SUBSTR(cTipoClass, 3, 1)
			cFolha := SUBSTR(cTipoClass, 4, 1)
			
			If (!cTipo $ "1|2|3|4|5|6|7|8") .OR. (!cCor $ "1|2|3|4|5|6") .OR. (cDiv != "-") .OR. (!cFolha $ "1|2|3|4|5|6|7")				
				cErro := "Tipo de classifica��o informado incorreto."
			EndIf						
		EndIf
		
	EndIf
	
	If Empty(cErro)
		    	
		BEGIN TRANSACTION
		
			// Inclus�o da sincroniza��o
			oChvSinc := UBIncSinc("5","2","1",cCodUn,"","","","","","", cTipoClass)
				
			cFilSinc  := oChvSinc[1]
			cDataSinc := oChvSinc[2]
			cHoraSinc := oChvSinc[3]
			cSeqSinc  := oChvSinc[4]
			
			// Revis�o do tipo de classifica��o
			UBW09TeRev(cCodUn, cTipoClass, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
					    		    		   
		END TRANSACTION
	
	EndIf
		
	If Len(aErros) == 0	.AND. Empty(cErro)
		lPost := .T.
	
		oResponse["content"] := JsonObject():New()			
		oResponse["content"]["Message"]	:=  "Revis�o do tipo realizada com sucesso."
							            
		cResponse := EncodeUTF8(FWJsonSerialize(oResponse, .F., .F., .T.))
		::SetResponse(cResponse)
	Else
		lPost := .F.
		
		If Len(aErros) > 0
			cErro := "Ocorreu erro de neg�cio na revis�o do tipo."			
		EndIf
			
		SetRestFault(400, EncodeUTF8(cErro))
	EndIf

Return lPost

/**---------------------------------------------------------------------
{Protheus.doc} UBW09TeRev
Revis�o do tipo de classifica��o

@param: cCodUn, character, C�digo �nico (Filtro)
@param: cTipoClass, character, Tipo de classifica��o
@param: cFilSinc, character, Filial da sincroniza��o
@param: cDataSinc, character, Data da sincroniza��o
@param: cHoraSinc, character, Hora da sincroniza��o
@param: cSeqSinc, character, Sequencia da sincroniza��o
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
		cErro    := "N�o foi encontrado bloco para revis�o do tipo de classifica��o."
		
		Aadd(aErros, {cCodErro, cErro})
		
		// Inclus�o do erro de sincroniza��o na tabela NC4
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
		// Altera��o do status da sincroniza��o para "2=Erro de sincroniza��o"
		UBAltStSin(cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, "2")
	EndIf

Return aErros

/*{Protheus.doc} UBW09GetBlc
Busca o recno do bloco que receber� a revis�o do tipo de classifica��o

@author francisco.nunes
@since 19/07/2018
@param cCodUn, characters, C�digo �nico do bloco
@param: cFilSinc, character, Filial da sincroniza��o
@param: cDataSinc, character, Data da sincroniza��o
@param: cHoraSinc, character, Hora da sincroniza��o
@param: cSeqSinc, character, Sequencia da sincroniza��o
@param: lChecCor, logical, .T. - Checagem do erro (N�o � inserido novos erros); .F. - Outros
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
			cErro    := "Bloco n�o pode ser reclassificado, pois est� reservado."
			
			Aadd(aErros, {cCodErro, cErro})
			
			// Inclus�o do erro de sincroniza��o na tabela NC4
			UBIncErro(cFilSinc,cDataSinc,cHoraSinc,cSeqSinc,cCodErro,cErro,"2",(cAlias)->DXD_FILIAL,(cAlias)->DXD_CODUNI)
		Else
			nRecnoBlc := (cAlias)->DXD_REC
		EndIf		
    EndIf

	(cAlias)->(DbCloseArea())
	    
Return nRecnoBlc

/*{Protheus.doc} UBW09CERR
Verificar se os erros relacionados a classifica��o / revis�o do tipo foram corrigidos
Caso sejam, ser� modificado o status do erro da sincroniza��o para corrigido

@author francisco.nunes
@since 30/07/2018
@param: cFilNC4, character, Filial da sincroniza��o
@param: cDatNC4, character, Data da sincroniza��o
@param: cHoraNC4, character, Hora da sincroniza��o
@param: cTpOpe, character, Tipo de opera��o (1=Classifica��o;2=Revis�o do tipo)
@param: cTipoEnt, character, Tipo de entidade (1=Fardo;2=Mala)
@param: cFiltro, character, Tipo de filtro (1=C�digo �nico;2=Intervalo)
@param: cCodUn, character, C�digo �nico (Filtro)
@param: cCodIni, character, C�digo inicial (Filtro Intervalo)
@param: cCodFin, character, C�digo final (Filtro Intervalo)
@return: lErroSinc, boolean, .T. - Possui erro de sincronismo; .F. - N�o possui erro de sincronismo
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
		
			If cTpOpe == "1" // Classifica��o
				lErroSinc := UBW09CCLAS(cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin, cFilNC4, cDatNC4, cHoraNC4)
			ElseIf cTpOpe == "2" // Revis�o do tipo
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
Verificar se os erros relacionados a classifica��o
Caso sejam, ser� modificado o status do erro da sincroniza��o para corrigido

@author francisco.nunes
@since 30/07/2018
@param: cTipoEnt, character, Tipo de entidade (1=Fardo;2=Mala)
@param: cFiltro, character, Tipo de filtro (1=C�digo �nico;2=Intervalo)
@param: cCodUn, character, C�digo �nico (Filtro)
@param: cCodIni, character, C�digo inicial (Filtro Intervalo)
@param: cCodFin, character, C�digo final (Filtro Intervalo)
@param: cFilSinc, character, Filial da sincroniza��o
@param: cDataSinc, character, Data da sincroniza��o
@param: cHoraSinc, character, Hora da sincroniza��o
@param: cSeqSinc, character, Sequencia da sincroniza��o
@return: lErroSinc, boolean, .T. - Possui erro de sincronismo; .F. - N�o possui erro de sincronismo
@type function
*/
Static Function UBW09CCLAS(cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
	
	Local lErroSinc := .F.
	Local oEntidade := {}
	
	If Alltrim(NC4->NC4_CODERR) == "00001"
		// Buscar os fardos e malas que receber�o a classifica��o de acordo com os campos de filtro informados
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
Verificar se os erros relacionados a revis�o do tipo de classifica��o
Caso sejam, ser� modificado o status do erro da sincroniza��o para corrigido

@author francisco.nunes
@since 30/07/2018
@param: cCodUn, character, C�digo �nico (Filtro)
@param: cFilSinc, character, Filial da sincroniza��o
@param: cDataSinc, character, Data da sincroniza��o
@param: cHoraSinc, character, Hora da sincroniza��o
@param: cSeqSinc, character, Sequencia da sincroniza��o
@return: lErroSinc, boolean, .T. - Possui erro de sincronismo; .F. - N�o possui erro de sincronismo
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