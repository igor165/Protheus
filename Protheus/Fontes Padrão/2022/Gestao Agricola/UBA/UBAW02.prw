#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

Static aLancInc := {}
Static aErros	:= {}

WSRESTFUL UBAW02 DESCRIPTION "Lançamento de Contaminante - NPX"

WSMETHOD POST contamination DESCRIPTION "Realiza o lançamento de contminantes"  PATH "/v1/contamination" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD POST contamination WSREST UBAW02
	
	Local lPost		  := .F.
    Local oResponse   := JsonObject():New()                 
    Local oRequest	  := JsonObject():New()
    Local aErros	  := {}    
    Local cErro 	  := ""
    Local nIt		  := 0    
    Local cTpEntSinc  := ""
    Local oChvSinc	  := {}
    Local cFilSinc    := ""
    Local cDataSinc   := ""
    Local cHoraSinc   := ""
    Local cSeqSinc	  := ""
    Local cContam	  := ""
    Local cTipoResult := ""
    Local cResult	  := ""
    Local cSeqCont	  := ""         
                
	// define o tipo de retorno do método
	::SetContentType("application/json")
		           
    oRequest:fromJson(::GetContent())
    
    cTipoEnt   := oRequest["objectType"]
	cFiltro	   := oRequest["filterType"]
	cCodUn     := oRequest["uniqueCode"]
	cCodIni    := oRequest["initialCode"]
	cCodFin    := oRequest["finalCode"]
	cObserv    := oRequest["comments"]
	cAtuDat    := oRequest["updateDate"]
	cAtuUsu    := oRequest["updateUser"]
	aContam	   := oRequest["contaminants"]
	
	If Empty(cTipoEnt)
		cErro := "Tipo de entidade não informado."
	ElseIf Empty(cFiltro)
		cErro := "Tipo de filtro não informado."
	ElseIf cFiltro == "1" .AND. Empty(cCodUn)
		cErro := "Código único não informado."
	ElseIf cFiltro == "2" .AND. (Empty(cCodIni) .OR. Empty(cCodFin))
		cErro := "Intervalo não informado."
	ElseIf Empty(cAtuDat)
		cErro := "Data de lançamento de contaminantes não foi informado."
	ElseIf Empty(cAtuUsu)
		cErro := "Usuário que realizou o lançamento de contaminantes não foi informado."
	ElseIf Len(aContam) == 0
		cErro := "Não foram informados os contaminantes."				
	Else
	
		For nIt := 1 to Len(aContam)
		
			If Empty(aContam[nIt]["code"])
				cErro := "Não foi informado o código do contaminante."				
			Else				
				DbSelectArea("N76")
				N76->(DbSetOrder(1)) // N76_FILIAL+N76_CODIGO
				If !N76->(DbSeek(FWxFilial("N76")+aContam[nIt]["code"]))
					cErro := "Contaminante " + aContam[nIt]["code"] + " não foi encontrado no sistema."
				ElseIf Empty(aContam[nIt]["typeResult"])
					cErro := "Não foi informado o tipo de resultado para o contaminante " + Alltrim(aContam[nIt]["code"]) + "."
				ElseIf Empty(aContam[nIt]["result"])
					cErro := "Não foi informado o resultado para o contaminante " + Alltrim(aContam[nIt]["code"]) + "."
				EndIf			
			EndIf		
				
		Next nIt
			
	EndIf
				
	If Empty(cErro)
			
		BEGIN TRANSACTION
		
			If cTipoEnt == "1" // Mala
				cTpEntSinc := "3"
			ElseIf cTipoEnt == "2" // Fardo
				cTpEntSinc := "1"
			Else // Bloco
				cTpEntSinc := "2"
			EndIf
							
			// Inclusão da sincronização
			oChvSinc := UBIncSinc("4",cTpEntSinc,cFiltro,cCodUn,cCodIni,cCodFin,cAtuDat,"",cAtuUsu,cObserv)
			
			cFilSinc  := oChvSinc[1]
			cDataSinc := oChvSinc[2]
			cHoraSinc := oChvSinc[3]
			cSeqSinc  := oChvSinc[4]
			
			For nIt := 1 to Len(aContam)
				
				cContam 	:= PADR(aContam[nIt]["code"], TamSX3("NC3_CODCON")[1])
				cTipoResult := PADR(aContam[nIt]["typeResult"], TamSX3("NC3_TPRES")[1])
				cResult	    := PADR(aContam[nIt]["result"], TamSX3("NC3_RESULT")[1])
								
				// Inclusão dos contaminantes na sincronização
				UBIncCont(cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, @cSeqCont, cContam, cTipoResult, cResult)
			Next nIt
			
		END TRANSACTION
			
		BEGIN TRANSACTION
			
			// Inclusão dos lançamentos de contminantes
			aErros := UB02IncLC(cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin, cAtuDat, cAtuUsu, aContam, cObserv, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
			
			If Len(aErros) > 0
				DisarmTransaction()
			EndIf
				
		END TRANSACTION
		
		BEGIN TRANSACTION
							
			If Len(aErros) > 0
			
				For nIt := 1 to Len(aErros)
				
					cCodErro := aErros[nIt][1]
					cErro    := aErros[nIt][2]
					cTpEnt   := aErros[nIt][3]
					cFilEnt  := aErros[nIt][4]
					cCodBar  := aErros[nIt][5]
					
					// Inclusão do erro de sincronização na tabela NC4
					UBIncErro(cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, cCodErro, cErro, cTpEnt, cFilEnt, cCodBar) 
					
				Next nIt
			
				// Alteração do status da sincronização para "2=Erro de sincronização"
				UBAltStSin(cFilSinc, cDataSinc, cHoraSinc, cSeqSinc, "2")
			EndIf
						
		END TRANSACTION
		
	EndIf			
	
	If Len(aErros) > 0 .OR. !Empty(cErro)
		lPost := .F.
		
		If Len(aErros) > 0
			cErro := "Ocorreu erro de negócio na análise de contaminantes."		
		EndIf
		
		SetRestFault(400, EncodeUTF8(cErro))			
	Else		
		lPost := .T.
					
		oResponse["content"] := JsonObject():New()
    	
    	oResponse["content"]["Message"]	:= "Lançamentos de contaminantes incluídos com sucesso."    	
    	oResponse["content"]["Items"] 	:= {}
    	
    	For nIt := 1 to Len(aLancInc)
    	
    		Aadd(oResponse["content"]["Items"], JsonObject():New())
    		
    		aTail(oResponse["content"]["Items"])["branch"]     := aLancInc[nIt][1]
    		aTail(oResponse["content"]["Items"])["crop"]       := aLancInc[nIt][2]
    		aTail(oResponse["content"]["Items"])["entType"]    := aLancInc[nIt][3]
    		aTail(oResponse["content"]["Items"])["barcode"]    := aLancInc[nIt][4]
    		aTail(oResponse["content"]["Items"])["resultType"] := aLancInc[nIt][5]
    		aTail(oResponse["content"]["Items"])["result"]     := aLancInc[nIt][6]
    		aTail(oResponse["content"]["Items"])["resultDesc"] := aLancInc[nIt][7]    	
    			    	
    	Next nIt
    	
    	cRetorno := EncodeUTF8(FWJsonSerialize(oResponse, .F., .F., .T.))
    
    	::SetResponse(cRetorno)			
	EndIf	
	
Return lPost

/**---------------------------------------------------------------------
{Protheus.doc} UB02IncLC
Inclusão dos Lançamentos de contaminantes

@param: cTipoEnt, character, Tipo de entidade (1=Mala;2=Fardo;3=Bloco)
@param: cFiltro, character, Tipo de filtro (1=Código único;2=Intervalo)
@param: cCodUn, character, Código único (Filtro)
@param: cCodIni, character, Código inicial (Filtro Intervalo)
@param: cCodFin, character, Código final (Filtro Intervalo)
@param: cAtuDat, data, Data da análise de contaminantes
@param: cAtuUsu, character, Usuário que realizou a análise de contaminantes
@param: aContam, array, Lista de contaminantes informados
@param: cObserv, character, Observação do Contaminante
@param: cSeqSinc, character, Sequencia da sincronização
@author: francisco.nunes
@since: 27/07/2018
---------------------------------------------------------------------**/
Function UB02IncLC(cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin, cAtuDat, cAtuUsu, aContam, cObserv, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
	
	Local lPost		:= .T.
	Local aLancCont := {}
	Local nIt		:= 1
	Local aTabEnt	:= {}	
	Local cCodErro	:= ""
	Local cErro		:= ""

	aLancCont := UBW02GetLC(cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin, cAtuDat, cAtuUsu, aContam, cObserv)
						
	If Len(aLancCont) == 0		
		cCodErro := "00001"
		cErro    := "Não foram encontrados entidades para lançamento de contaminantes."
		
		Aadd(aErros, {cCodErro, cErro, "", "", ""})			
	EndIf
							
	For nIt := 1 to Len(aLancCont)
						    	    	       	    		    		  
    	cFilCor := cFilAnt
    	cFilAnt := PADR(aLancCont[nIt]["branch"], TamSX3('NPX_FILIAL')[1])
	    		    	
    	cSafra 	    := PADR(aLancCont[nIt]["crop"],TamSX3('NPX_CODSAF')[1])
    	cMala  	    := PADR(aLancCont[nIt]["case"],TamSX3('NPX_CDUMAL')[1])
    	cBloco 	    := PADR(aLancCont[nIt]["pack"],TamSX3('NPX_CDUBLC')[1])
    	cFardo 	    := PADR(aLancCont[nIt]["bale"],TamSX3('NPX_ETIQ')[1])
    	cContam     := PADR(aLancCont[nIt]["contaminant"],TamSX3('NPX_CODTA')[1])
    	cUsuCont    := aLancCont[nIt]["updateUser"]
    	dDataCont   := aLancCont[nIt]["updateDate"]    	
    	cObservacao := aLancCont[nIt]["notes"]
    			    				    		    		   
    	If !Empty(cFardo)
    		cTabEnt := "DXI"
    		cCodBar := cFardo		
    	ElseIf !Empty(cBloco)
    		cTabEnt := "DXD"
    		cCodBar := cBloco
    	Else
    		cTabEnt := "DXJ"
    		cCodBar := cMala
    	EndIf
	    	
    	aResult := {}	
    	
    	cTipoResul := Posicione("N76", 1, FWxFilial("N76")+cContam, "N76_TPCON") // 1=Numérico;2=Texto;3=Data;4=Lista;5=Faixa 		    
    		    	
    	Do Case
			Case cTipoResul == "1" //Numerico
				Aadd(aResult, aLancCont[nIt]["resultValue"])					
			Case cTipoResul == "2" //Texto
				Aadd(aResult, aLancCont[nIt]["resultText"])					
			Case cTipoResul == "3" //Data
				Aadd(aResult, aLancCont[nIt]["resultDate"])						    				
			Case cTipoResul == "4" //Lista
				Aadd(aResult, aLancCont[nIt]["resultText"])
			Case cTipoResul == "5" //Faixa
				Aadd(aResult, aLancCont[nIt]["resultValue"])
				Aadd(aResult, RetDFaixa(cContam, aResult[1]))
		EndCase   
				    			 		    		    		    		    	   		 		
		// Inclusão do lançamento de contaminante
		lPost := IncLancCont(cTabEnt, cSafra, cCodBar, cContam, cUsuCont, dDataCont, cTipoResul, aResult, cObservacao, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
									
		// Inclui a ánalise de contaminantes (NPX) para os fardos do bloco ou mala
	    If lPost .AND. cTabEnt $ "DXD|DXJ"		 
	    	aTabEnt := {}
	       			    
	    	If cTabEnt == "DXD"
	    		DbSelectArea("DXD")
				DXD->(DbSetOrder(2)) // DXD_FILIAL+DXD_CODUNI
				If DXD->(DbSeek(FWxFilial('DXD')+cCodBar))
					cCodBloco := DXD->DXD_CODIGO							
				EndIf		    	
	    	
	    		Aadd(aTabEnt, cCodBloco)
	    		Aadd(aTabEnt, cSafra)
	    		nTipEnt := 1
	    	Else
	    		DbSelectArea("DXJ")
				DXJ->(DbSetOrder(2)) // DXJ_FILIAL+DXJ_CODBAR
				If DXJ->(DbSeek(FWxFilial('DXJ')+cCodBar))
					cCodMala  := DXJ->DXJ_CODIGO
					cTipoMala := DXJ->DXJ_TIPO								
				EndIf    	
	    	
	    		Aadd(aTabEnt, cCodMala)
	    		Aadd(aTabEnt, cTipoMala)
	    		nTipEnt := 2
	    	EndIf
	    			    			    
	    	lPost := IncNPXFrd(nTipEnt, aTabEnt, cContam, cUsuCont, dDataCont, cTipoResul, aResult, cObservacao, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)	    			    
	    EndIf
	    
	    cFilAnt := cFilCor
	    
	    If !lPost
	    	EXIT
	    EndIf
	    
	Next nIt
			
Return aErros

/*{Protheus.doc} UBW02GetLC
Monta os lançamentos de contaminantes

@author francisco.nunes
@since 19/07/2018
@param cTipoEnt, characters, Tipo de Objeto do Filtro (1=Mala;2=Fardo;3=Bloco)
@param cFiltro,  characters, Tipo de Filtro (1=Código único;2=Intervalo)
@param cCodUn,   characters, Código único
@param cCodIni,  characters, Código de barras inicial
@param cCodFin,  characters, Código de brras final
@param cAtuDat,  characters, Data do lançamento de contaminante
@param cAtuUsu,  characters, Usuário que realizou o lançamento de contaminante
@param aContam,  characters, Array com os contaminantes informados
@param cObserv,  characters, Observação
@type function
*/
Static Function UBW02GetLC(cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin, cAtuDat, cAtuUsu, aContam, cObserv)

	Local aLancsCont := {}
	Local aEntidades := {}
	Local nIt		 := 0
	Local nX		 := 0
	Local oLancCont  := {}
	
	aEntidades := UBW02GetEnt(cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin)
	
    For nIt := 1 to Len(aContam)
    
    	For nX := 1 to Len(aEntidades)
    	
    		oLancCont := JsonObject():New()
    		
    		oLancCont["branch"] 	 := aEntidades[nX][2]
    		oLancCont["crop"] 		 := aEntidades[nX][3]
    		oLancCont["contaminant"] := aContam[nIt]["code"]
    		oLancCont["updateDate"]  := cAtuDat
    		oLancCont["updateUser"]  := cAtuUsu
    		oLancCont["notes"]  	 := cObserv
    		    		    	
    		If cTipoEnt == "1" // Mala                
                oLancCont["case"] := aEntidades[nX][1]                
            ElseIf cTipoEnt == "2" // Fardo                
                oLancCont["bale"] := aEntidades[nX][1]                
            Else // Bloco                
                oLancCont["pack"] := aEntidades[nX][1]                
            EndIf
            
            If aContam[nIt]["typeResult"] == "1"            	
            	oLancCont["resultValue"] := Val(aContam[nIt]["result"])            	
            ElseIf aContam[nIt]["typeResult"] == "2"            
            	oLancCont["resultText"]  := aContam[nIt]["result"]            
            ElseIf aContam[nIt]["typeResult"] == "3"            
            	oLancCont["resultDate"]  := StrTran(aContam[nIt]["result"],"-","")            
            ElseIf aContam[nIt]["typeResult"] == "4"            
            	oLancCont["resultText"]  := aContam[nIt]["result"]
            Else            
            	oLancCont["resultValue"] := Val(aContam[nIt]["result"])            
            EndIf
    		   		    		
    		Aadd(aLancsCont, oLancCont)
    	
    	Next nX
    
    Next nIt  	
	
Return aLancsCont

/*{Protheus.doc} UBW02GetEnt
Buscas as entidades (Malas;Fardos;Blocos) que receberão o lançamento de contaminantes

@author francisco.nunes
@since 19/07/2018
@param cTipoEnt, characters, Tipo de Objeto do Filtro (1=Mala;2=Fardo;3=Bloco)
@param cFiltro,  characters, Tipo de Filtro (1=Código único;2=Intervalo)
@param cCodUn,   characters, Código único
@param cCodIni,  characters, Código de barras inicial
@param cCodFin,  characters, Código de brras final
@type function
*/
Static Function UBW02GetEnt(cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin)

	Local aEntidades := {}
	
	cAlias := GetNextAlias()
	
	If cTipoEnt == "1" // Mala
		
		cQuery := " SELECT DXJ.DXJ_CODBAR AS BARCODE, "
		cQuery += " 	   DXJ.DXJ_FILIAL AS FILIAL, "
		cQuery += " 	   DXJ.DXJ_SAFRA  AS SAFRA "
	    cQuery += "   FROM " + RetSqlName("DXJ") + " DXJ "
	    cQuery += "  WHERE DXJ.D_E_L_E_T_ <> '*' "
	    cQuery += "    AND DXJ.DXJ_CODBAR = '" + cCodUn + "' "	
		
	ElseIf cTipoEnt == "2" // Fardo
			
	    cQuery := " SELECT DXI.DXI_ETIQ   AS BARCODE, "
	    cQuery += " 	   DXI.DXI_FILIAL AS FILIAL, "
		cQuery += " 	   DXI.DXI_SAFRA  AS SAFRA "
	    cQuery += "   FROM " + RetSqlName("DXI") + " DXI "
	    cQuery += "  WHERE DXI.D_E_L_E_T_ <> '*' "
	    
	    If cFiltro == "1" // Código único    	
    		cQuery += " AND DXI.DXI_ETIQ = '" + cCodUn + "' "
    	Else
    		cQuery += " AND DXI.DXI_ETIQ BETWEEN '" + cCodIni + "' AND '" + cCodFin + "' " 
    	EndIf    	    
		
	Else // Bloco
	
		cQuery := " SELECT DXD.DXD_CODUNI AS BARCODE, "
		cQuery += " 	   DXD.DXD_FILIAL AS FILIAL, "
		cQuery += " 	   DXD.DXD_SAFRA  AS SAFRA "
	    cQuery += "   FROM " + RetSqlName("DXD") + " DXD "
	    cQuery += "  WHERE DXD.D_E_L_E_T_ <> '*' "
	    
	    If cFiltro == "1" // Código único    	
    		cQuery += " AND DXD.DXD_CODUNI = '" + cCodUn + "' "
    	Else
    		cQuery += " AND DXD.DXD_CODUNI BETWEEN '" + cCodIni + "' AND '" + cCodFin + "' " 
    	EndIf  
		
	EndIf
	
	cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAlias)
    	
	If (cAlias)->(!Eof())
        While (cAlias)->(!Eof())
        	
        	Aadd(aEntidades, {(cAlias)->BARCODE, (cAlias)->FILIAL, (cAlias)->SAFRA})
        
        	(cAlias)->(DbSkip())
        EndDo
    EndIf

	(cAlias)->(DbCloseArea())	

Return aEntidades

/*{Protheus.doc} IncLancCont
Inclui o lançamento de contaminantes (NPX) pelo modelo da UBAW050

@author francisco.nunes
@since 18/06/2018
@param cTabEnt, character, DXI - Fardo; DXD - Bloco; DXJ - Mala
@param cSafra, character, Safra
@param cCodBar, character, Código de barras da mala / bloco / fardo
@param cContam, character, Código do contaminante
@param cUsuCont, character, Usuário de inclusão / alteração
@param dDataCont, character, Data de inclusão / alteração
@param cTipoResul, character, "1" - Numerico; "2" - Texto; "3" - Data; "4" - Lista; "5" - Faixa
@param aResult, array, [1] = Resultado Númerico / Texto / Data
					   [2] = Resultado Text (quando tipo de resultado 5 - Faixa)
@param cObservacao, character, Observação					   
@param: cFilSinc, character, Filial da sincronização
@param: cDataSinc, character, Data da sincronização
@param: cHoraSinc, character, Hora da sincronização
@param: cSeqSinc, character, Sequencia da sincronização 
@type function
*/
Static Function IncLancCont(cTabEnt, cSafra, cCodBar, cContam, cUsuCont, dDataCont, cTipoResul, aResult, cObservacao, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
	Local cFardo    := ""
	Local cCodFardo := ""
	Local cBloco    := ""
	Local cCodBloco := ""
	Local cMala     := ""
	Local cCodMala  := ""	
	Local cProdutor := ""
	Local cLojProd  := ""
	Local cFazenda  := ""
	Local cLote		:= ""
	Local cUpdDate	:= ""
	Local cResDate	:= ""
	Local nSeq		:= 1
	Local oModelNPX	:= {}
	Local aError	:= {}
	Local cDTipoRes := ""
	Local cTipoMala	:= ""
	Local oLancInc	:= {}
	Local cDesCont	:= ""
	Local cTipoVal	:= ""
	Local cTpEnt	:= ""
	Local cFilEnt	:= ""
	Local lRet		:= .T.
					
	If cTabEnt == "DXI" // Fardo
		cFardo := cCodBar
		
		DbSelectArea("DXI")
		DXI->(DbSetOrder(1)) // DXI_FILIAL+DXI_SAFRA+DXI_ETIQ
		If DXI->(DbSeek(FWxFilial('DXI')+cSafra+cFardo))
			cCodFardo := DXI->DXI_CODIGO
			cProdutor := DXI->DXI_PRDTOR
			cLojProd  := DXI->DXI_LJPRO
			cFazenda  := DXI->DXI_FAZ
			cLote	  := cTabEnt + cValtoChar(DXI->(Recno()))
			cFilEnt	  := DXI->DXI_FILIAL		
		EndIf	    		
	ElseIf cTabEnt == "DXD" // Bloco
		cBloco := cCodBar
		
		DbSelectArea("DXD")
		DXD->(DbSetOrder(2)) // DXD_FILIAL+DXD_CODUNI
		If DXD->(DbSeek(FWxFilial('DXD')+cBloco))
			cCodBloco := DXD->DXD_CODIGO
			cProdutor := DXD->DXD_PRDTOR
			cLojProd  := DXD->DXD_LJPRO
			cFazenda  := DXD->DXD_FAZ
			cLote	  := cTabEnt + cValtoChar(DXD->(Recno()))
			cFilEnt	  := DXD->DXD_FILIAL		
		EndIf
	Else
		cMala := cCodBar
		
		DbSelectArea("DXJ")
		DXJ->(DbSetOrder(2)) // DXJ_FILIAL+DXJ_CODBAR
		If DXJ->(DbSeek(FWxFilial('DXJ')+cMala))
			cCodMala  := DXJ->DXJ_CODIGO
			cProdutor := DXJ->DXJ_PRDTOR
			cLojProd  := DXJ->DXJ_LJPRO
			cFazenda  := DXJ->DXJ_FAZ
			cTipoMala := DXJ->DXJ_TIPO
			cLote	  := cTabEnt + cValtoChar(DXJ->(Recno()))
			cFilEnt	  := DXJ->DXJ_FILIAL		
		EndIf
	EndIf  		    
			
	// Inativa os registros anteriores
	DbSelectArea("NPX")
	NPX->(DbSetOrder(1))
	If NPX->(DbSeek(FWxFilial('NPX')+cSafra+PADR('',TamSX3('NPX_CODPRO')[1])+PADR(cLote,TamSX3('NPX_LOTE')[1])+;
		  			PADR(cContam,TamSX3('NPX_CODTA')[1])+PADR(cContam,TamSX3('NPX_CODVA')[1])))
		   
		While NPX->(!Eof())                      .And. ;
			NPX->NPX_FILIAL = FWxFilial('NPX')   .And. ;
			NPX->NPX_CODSAF = cSafra             .And. ;				
			NPX->NPX_LOTE   = PADR(cLote,TamSX3('NPX_LOTE')[1])    .And. ;
			NPX->NPX_CODTA  = PADR(cContam,TamSX3('NPX_CODTA')[1]) .And. ;
			NPX->NPX_CODVA  = PADR(cContam,TamSX3('NPX_CODVA')[1])    
					
			If NPX->NPX_ATIVO  = "1"
				If RecLock("NPX", .F.)
					NPX->NPX_ATIVO  := "2"
					NPX->NPX_USUATU := cUsuCont
					NPX->(MsUnlock())
				EndIf
			EndIf
			
			nSeq++
			NPX->(DbSkip())
		EndDo
	EndIf
		    		    		    
	oModelNPX := FwLoadModel("UBAW050")
	oModelNPX:SetOperation(MODEL_OPERATION_INSERT)
	oModelNPX:Activate()
		    		   
	oModelNPX:GetModel('RESTNPX'):SetValue("NPX_CODSAF", cSafra)
	oModelNPX:GetModel('RESTNPX'):SetValue("NPX_LOTE", cLote)
	oModelNPX:GetModel('RESTNPX'):SetValue("NPX_CODTA", cContam)
	oModelNPX:GetModel('RESTNPX'):SetValue("NPX_CODVA", cContam)
	oModelNPX:GetModel('RESTNPX'):SetValue("NPX_SEQ", cValToChar(nSeq))
	oModelNPX:GetModel('RESTNPX'):SetValue("NPX_ATIVO", "1")
			
	Do Case
		Case cTipoResul == "1" //Numerico
			oModelNPX:GetModel('RESTNPX'):SetValue("NPX_RESNUM", aResult[1])
			cTipoVal  := "1"
			cDTipoRes := "1 - Numérico"							
		Case cTipoResul == "2" //Texto
			oModelNPX:GetModel('RESTNPX'):SetValue("NPX_RESTXT", aResult[1])
			cTipoVal  := "2"
			cDTipoRes := "2 - Texto"					
		Case cTipoResul == "3" //Data
			cResDate := cToD(SUBSTR(aResult[1], 7, 2) + "/" + SUBSTR(aResult[1], 5, 2) + "/" + SUBSTR(aResult[1], 1, 4))
			oModelNPX:GetModel('RESTNPX'):SetValue("NPX_RESDTA", cResDate)
			cTipoVal  := "3"
			cDTipoRes := "3 - Data"		    					
		Case cTipoResul == "4" //Lista
			oModelNPX:GetModel('RESTNPX'):SetValue("NPX_RESTXT", aResult[1])
			cTipoVal  := "2"
			cDTipoRes := "4 - Lista"
		Case cTipoResul == "5" //Faixa
			oModelNPX:GetModel('RESTNPX'):SetValue("NPX_RESNUM", aResult[1])
			oModelNPX:GetModel('RESTNPX'):SetValue("NPX_RESTXT", aResult[2])
			cTipoVal  := "1"
			cDTipoRes := "5 - Faixa"
	EndCase   	
	
	oModelNPX:GetModel('RESTNPX'):SetValue("NPX_TIPOVA", cTipoVal)
			    
    cUpdDate := cToD(SUBSTR(dDataCont, 7, 2) + "/" + SUBSTR(dDataCont, 5, 2) + "/" + SUBSTR(dDataCont, 1, 4))
    		    	    
	oModelNPX:GetModel('RESTNPX'):SetValue("NPX_DTATU", cUpdDate)
	oModelNPX:GetModel('RESTNPX'):SetValue("NPX_USUATU", cUsuCont)
	
	Do Case
		Case cTabEnt == "DXI" // Fardo
			oModelNPX:GetModel('RESTNPX'):SetValue("NPX_ETIQ", cFardo)
			oModelNPX:GetModel('RESTNPX'):SetValue("NPX_FARDO", cCodFardo)
			cTipoEnt := "Fardo"
			
		Case cTabEnt == "DXD" // Bloco
			oModelNPX:GetModel('RESTNPX'):SetValue("NPX_CDUBLC", cBloco)
			oModelNPX:GetModel('RESTNPX'):SetValue("NPX_BLOCO", cCodBloco)
			cTipoEnt := "Bloco"
			
		Case cTabEnt == "DXJ" // Mala    		
			oModelNPX:GetModel('RESTNPX'):SetValue("NPX_CDUMAL", cMala)
			oModelNPX:GetModel('RESTNPX'):LoadValue("NPX_ROMCLA", cCodMala) 
			oModelNPX:GetModel('RESTNPX'):LoadValue("NPX_TPMALA", cTipoMala) // 1=Visual;2=HVI
			cTipoEnt := "Mala"
	EndCase
	
	oModelNPX:GetModel('RESTNPX'):SetValue("NPX_PRDTOR", cProdutor)
	oModelNPX:GetModel('RESTNPX'):SetValue("NPX_LJPRO", cLojProd)
	oModelNPX:GetModel('RESTNPX'):SetValue("NPX_FAZ", cFazenda)
	
	oModelNPX:GetModel('RESTNPX'):SetValue("NPX_OBSERV", cObservacao)
		    	
	If (oModelNPX:VldData() .and. oModelNPX:CommitData())        
        cDesCont := ""
        
        If cTipoResul == "5" //Faixa
        	cDesCont := aResult[2]
        EndIf
                           
        oLancInc := {FWxFilial('NPX'), cSafra, cTipoEnt, cCodBar, cDTipoRes, aResult[1], cDesCont}
        
        Aadd(aLancInc, oLancInc)            	       
    Else
    	lRet := .F.
    	
        aError := oModelNPX:GetErrorMessage()
        
        cCodErro := "00002"
        cErro 	 := "Ocorreu um erro de validação ao salvar o lançamento do contaminante " + Alltrim(cContam) + " : " + aError[6]
                                      
        If cTabEnt == "DXI" 
        	// Fardo
        	cTpEnt  := "1"        	
        ElseIf cTabEnt == "DXD"
        	// Bloco
        	cTpEnt := "2"
        Else
        	// Mala
        	cTpEnt := "3"
        EndIf
        
        Aadd(aErros, {cCodErro, cErro, cTpEnt, cFilEnt, cCodBar})                  
    EndIf
    
    oModelNPX:DeActivate()

Return lRet

/*{Protheus.doc} IncNPXFrd
Inclui o lançamento de contaminantes (NPX) para os fardos do bloco ou mala

@author francisco.nunes
@since 18/06/2018
@param nTipEnt, number, 1 - Bloco; 2 - Mala
@param oTabEnt, object, [1] = Código Bloco / Mala; [2] = Safra (Bloco); Tipo de Mala (Mala)
@param cContam, character, Código do contaminante
@param cUsuCont, character, Usuário de inclusão / alteração
@param dDataCont, character, Data de inclusão / alteração
@param cTipoResul, character, "1" - Numerico; "2" - Texto; "3" - Data; "4" - Lista; "5" - Faixa
@param aResult, array, [1] = Resultado Númerico / Texto / Data
					   [2] = Resultado Text (quando tipo de resultado 5 - Faixa)
@param cObservacao, character, Observação
@param: cFilSinc, character, Filial da sincronização
@param: cDataSinc, character, Data da sincronização
@param: cHoraSinc, character, Hora da sincronização
@param: cSeqSinc, character, Sequencia da sincronização
@type function
*/
Static Function IncNPXFrd(nTipEnt, oTabEnt, cContam, cUsuCont, dDataCont, cTipoResul, aResult, cObservacao, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
	Local cQuery    := ""
	Local cAliasQry := GetNextAlias()
	Local lRet		:= .T.
	
	cQuery := "SELECT DXI_SAFRA, DXI_ETIQ, DXI_PRDTOR, DXI_LJPRO, DXI_FAZ, DXI.R_E_C_N_O_ AS RECNUM "
	cQuery += "  FROM " + RetSqlName("DXI") + " DXI "
	
	If nTipEnt = 2 // Mala 
		cQuery += " INNER JOIN " + RetSqlName("DXK") + " DXK ON DXK.DXK_FILIAL = '" + FWxFilial("DXK") + "' "
		cQuery += " AND DXK.DXK_SAFRA = DXI.DXI_SAFRA AND DXK.DXK_ETIQ = DXI.DXI_ETIQ AND DXK.D_E_L_E_T_ <> '*' "
	EndIf
	
	cQuery += " WHERE DXI_FILIAL = '" + FWxFilial("DXI") + "' "
	cQuery += "   AND DXI.D_E_L_E_T_ <> '*' "
	
	If nTipEnt = 1 // Bloco
		cQuery += " AND DXI.DXI_SAFRA  = '" + oTabEnt[2] + "' "
		cQuery += " AND DXI.DXI_BLOCO  = '" + oTabEnt[1] + "' "
	Else
		cQuery += " AND DXK.DXK_CODROM = '" + oTabEnt[1] + "' "
	    cQuery += " AND DXK.DXK_TIPO   = '" + oTabEnt[2] + "' "
	EndIf
	
	cQuery := ChangeQuery(cQuery)	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	
	If !(cAliasQry)->(Eof())
		While !(cAliasQry)->(Eof())
			
			lRet := IncLancCont("DXI", (cAliasQry)->DXI_SAFRA, (cAliasQry)->DXI_ETIQ, cContam, cUsuCont, dDataCont, cTipoResul, aResult, cObservacao, cFilSinc, cDataSinc, cHoraSinc, cSeqSinc)
			
			If !lRet
				EXIT
			EndIf
			
			(cAliasQry)->(DbSkip())
		EndDo
	EndIf
	(cAliasQry)->(dbCloseArea())	

Return lRet

/*{Protheus.doc} RetDFaixa
Retorna a descrição da faixa do resultado

@author francisco.nunes
@since 18/06/20108
@param cContamin, characters, Código do contaminante
@param nValor, number, Valor do contaminante
@type function
*/
Static Function RetDFaixa(cContamin, nValor)	
	Local cQuery    := ""
	Local cAliasQry := GetNextAlias()
	Local cDescFaix := ""
	
	cQuery := " SELECT N77_RESULT "
	cQuery += "   FROM " + RetSqlName("N77") + " N77 "
	cQuery += "  WHERE N77.D_E_L_E_T_ <> '*' "
	cQuery += "    AND N77.N77_CODCTM = '" + cContamin + "'
	cQuery += "    AND N77.N77_FAIINI <= " + cValToChar(nValor)
	cQuery += "    AND N77.N77_FAIFIM >= " + cValToChar(nValor)
	
	cQuery := ChangeQuery(cQuery)	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	
	If (cAliasQry)->(!Eof())
		cDescFaix := (cAliasQry)->N77_RESULT
	Else
		cDescFaix := "ERROR"
	Endif
		
Return cDescFaix

/*{Protheus.doc} UBW02CERR
Verificar se os erros relacionados ao lançamento de contaminantes foram corrigidos 
Caso sejam, será modificado o status do erro da sincronização

@author francisco.nunes
@since 30/07/2018
@param: cFilNC4, character, Filial da sincronização
@param: cDatNC4, character, Data da sincronização
@param: cHoraNC4, character, Hora da sincronização
@return: lErroSinc, boolean, .T. - Possui erro de sincronismo; .F. - Não possui erro de sincronismo
@type function
*/
Function UBW02CERR(cFilNC4, cDatNC4, cHoraNC4, cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin)
	
	Local lErroSinc := .F.
	Local cDatNC42	:= ""
	
	cDatNC4 := Year2Str(Year(cDatNC4)) + Month2Str(Month(cDatNC4)) + Day2Str(Day(cDatNC4))
	
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
		
			If Alltrim(NC4->NC4_CODERR) == "00001"
				
				aEntidades := UBW02GetEnt(cTipoEnt, cFiltro, cCodUn, cCodIni, cCodFin)
							
				If Len(aEntidades) > 0		
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