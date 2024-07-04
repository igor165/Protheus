#INCLUDE "ISISS.ch"
#INCLUDE "Protheus.ch"

/*	
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณISISS     บAutor  ณAndressa Ataides    บ Data ณ 05/05/2005  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera as informacoes necessarias para declaracao Mensal de   บฑฑ
ฑฑบ          ณServicos Prestados e/ou Tomados do municipio de Vitoria -ES บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaFis                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function ISISS(dDtInicial,dDtFinal) // Inicio da funcao Isiss
                                                                  
	Local aTRBs	:= ISISSTemp()
	
	If ISISSWiz() // Executa Wizard	   
		ISISSProc(dDtInicial,dDtFinal,aTRBs)
	Endif
	
Return aTRBs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณISISSWiz    บAutor  ณAndressa Ataides    บ Data ณ 05/05/2005  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a wizard com as perguntas necessarias                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณISISS                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ISISSWiz()

	// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	// ณDeclaracao das variaveisณ
	// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	Local aTxtPre 		:= {}
	Local aPaineis 		:= {}
	Local cTitObj1		:= ""                
	Local nPos			:= 0
	Local lRet			:= 0

	
	// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	// ณMonta wizard com as perguntas necessariasณ
	// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    // ordem de acordo com a posicao do array
	
	aAdd(aTxtPre,STR0001) //"ISISS - Vitoria ES"
	aAdd(aTxtPre,STR0002) //"Atencao"
	aAdd(aTxtPre,STR0003) //"Preencha corretamente as informacoes solicitadas."
	aAdd(aTxtPre,STR0004+STR0005)	//"Esta rotina ira gerar as informacoes referentes a ISISS: "
									//"Internet Sistema de Impostos sobre Servicos  - Vitoria - ES"

	// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	// ณPainel 1 - Informacoes da Empresa    ณ
	// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis) 
	aAdd(aPaineis[nPos],STR0006) //"Assistente de parametrizacao"  -- primeira posicao (titulo)
	aAdd(aPaineis[nPos],STR0007) //"Informacoes sobre a empresa: " -- segunda posicao (subtitulo)
	aAdd(aPaineis[nPos],{}) 
	//
	cTitObj1 :=	STR0008 //"Numero da Inscricao Municipal: "  -- terceira posicao
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,Replicate("X",14),1,,,,14}) // 14 posicoes
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})	
    //
	cTitObj1 :=	STR0009 //"Numero AIDF: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,}) 
	aAdd(aPaineis[nPos][3],{2,,Replicate("X",6),1,,,,6}) // caracter -- passar tamanho do campo (mascara). 
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})	
	//
	cTitObj1 :=	STR0010 //"Ano AIDF: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})            
	aAdd(aPaineis[nPos][3],{2,,"XXXX",1,,,,4}) // 4 posicoes
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=	STR0012 //"Data Pagamento do Documento Fiscal: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})            
	aAdd(aPaineis[nPos][3],{2,,"@d",3,,,,8}) // 8 posicoes
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	//
	cTitObj1 :=STR0013 //"C๓digo do Municํpio" 
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,Replicate("X",5),1,,,,5}) // 5 posicoes
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})	
	//
	aAdd(aPaineis[nPos][3],{1,Space(01),,,,,,})		
	//
	lRet :=	xMagWizard(aTxtPre,aPaineis,"ISISS") // executa wizard(xMagWizard)
	
Return(lRet)   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณISISSProc   บAutor  ณAndressa Ataides    บ Data ณ 05/05/2005  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa os movimentos                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณISISS                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ISISSProc(dDtInicial,dDtFinal)

	Local aWizard		:= {}
	Local lRet			:= !xMagLeWiz("ISISS",@aWizard,.T.)
    Local cNumAidf		:= Alltrim(aWizard[01][02])
    Local cAnoAidf		:= Alltrim(aWizard[01][03])
	Local cPagament		:= SubStr(Alltrim(aWizard[01][04]),7,2) + "/" + SubStr(Alltrim(aWizard[01][04]),5,2) + "/" + SubStr(Alltrim(aWizard[01][04]),1,4)
    
	Local cAliasSF3		:= "SF3"    // tabela livros fiscais
	Local cAliasSF2		:= "SF2"
	Local cAliasSF1		:= "SF1" 
	Local cCNPJ         := ""
    Local cRecISS 		:= ""
    Local nValISSRet    := 0
	Local cCondicao		:= ""
	Local cIndex		:= ""
	Local nIndex		:= ""
	Local cInscM		:= "" 
	Local cMun          := Alltrim(Upper(GetNewPar("MV_CIDADE","")))
	Local nSeqItem      := 0 
	Local nValTotSer    := 0
	Local nQtdItem      := 0
	Local nOutRet       := 0
	Local nTotAbImp     := 0
	Local lDescSB5      := SuperGetMv("MV_SB5ISI",,.F.) 
	Local aChaveSF3		:=	{}
	Local cChaveSF3		:= ""
	
	
	
	#IFDEF TOP  // Verificando as variaveis utilizadas em cada ambiente (TOP/CODBASE)
		Local nX		:= 0
		Local aStruSF3	:= {}
		Local lQuery	:= .F.
	#ENDIF

	If lRet
		Return
	Endif            
	                                                
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณProcessamento dos documentos Fiscais                                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	dbSelectArea("SF3") // Varrendo a tabela SF3
	dbSetOrder(1) // Primeiro indice da tabela
	ProcRegua(LastRec()) // Numero maximo de registro p/ fazer barra de progresso
	
	#IFDEF TOP
	    If TcSrvType()<>"AS/400"
	    	lQuery	  := .T.       
	    	cAliasSF3 := "SF3_ISISS"	
			aStruSF3  := SF3->(dbStruct())
			cQuery := "SELECT SE2.E2_BAIXA, SF3.* "
			cQuery += "FROM " + RetSqlName("SF3")+ " SF3 "
			cQuery += "JOIN "+ RetSqlName("SE2")+" SE2 ON "
			cQuery += "SF3.F3_NFISCAL = SE2.E2_NUM AND SF3.F3_SERIE = SE2.E2_PREFIXO AND "
			cQuery += "SF3.F3_CLIEFOR = SE2.E2_FORNECE AND SF3.F3_LOJA = SE2.E2_LOJA "
			cQuery += "WHERE SF3.F3_FILIAL='" + xFilial("SF3") + "' AND " // padrao filial
			cQuery += "SE2.E2_FILIAL='" + xFilial("SE2") + "' AND " // padrao filial"
			cQuery += "SE2.E2_BAIXA <> '' AND "
			cQuery += "SE2.E2_BAIXA >= '" + Dtos(dDtInicial) + "' AND "
			cQuery += "SE2.E2_BAIXA <= '" + Dtos(dDtFinal) + "' AND "                
			cQuery += "SF3.F3_TIPO = 'S' AND "  // = S (notas de servicos -- ISS)
			cQuery += "SF3.D_E_L_E_T_ = ' ' AND SE2.D_E_L_E_T_ = ' ' "
		
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3)
		
			For nX := 1 To len(aStruSF3) // le estrutura da tabela sf3 -- padrao
				If aStruSF3[nX][2] <> "C" .And. FieldPos(aStruSF3[nX][1])<>0
					TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
				EndIf
			Next nX
			dbSelectArea(cAliasSF3)	
		Else
	#ENDIF
		    cIndex    := CriaTrab(NIL,.F.)
		    cCondicao := 'F3_FILIAL == "' + xFilial("SF3") + '" .And. '
		   	cCondicao += 'DTOS(F3_ENTRADA) >= "' + DTOS(dDtInicial) + '" '
		   	cCondicao += '.And. DTOS(F3_ENTRADA) <= "' + DTOS(dDtFinal) + '"'
			cCondicao += '.And. F3_TIPO == "S" '
		    IndRegua(cAliasSF3,cIndex,SF3->(IndexKey()),,cCondicao) // efetua o filtro
		    nIndex := RetIndex("SF3")
			#IFNDEF TOP
				dbSetIndex(cIndex+OrdBagExt())
				dbSelectArea("SF3")
			    dbSetOrder(nIndex+1)
			#ENDIF    
		    dbSelectArea(cAliasSF3)
		    ProcRegua(LastRec())
	    	dbGoTop()
	#IFDEF TOP
		Endif                                           
	#ENDIF
	                                                   
	Do While !(cAliasSF3)->(Eof()) // inicio processo 
	        
		cChaveSF3 := xFilial("SF3")+(cAliasSF3)->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)
		If aScan(aChaveSF3,cChaveSF3)==0
			aAdd(aChaveSF3,cChaveSF3)
		Else
			(cAliasSF3)->(dbSkip())
			Loop
		EndIf
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCliente/Fornecedorณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cRecISS := ""                                                     
      	cCNPJ 	:= ""
		cInscM  := "" 
		cEst    := ""
		cCidade := ""
		cNome   := ""
		cEnd    := ""
		cCep    := ""
		cEmail  := ""
				
		If SubStr((cAliasSF3)->F3_CFO,1,1) >= "5" // NF SAIDA -- se for nf de saida
			If (cAliasSF3)->F3_TIPO$"DB" // verifica se a nf saida e devolucao/beneficiamento (fornecedor)
				If ! SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)) // se nao localizada nota
					(cAliasSF3)->(dbSkip()) // proximo registro
					Loop                
				Else // localizou nota...armazena valor do cgc/cpf	
                	cCNPJ 	:= SA2->A2_CGC
	   				cInscM  := SA2->A2_INSCRM
	   				cEst    := SA2->A2_EST
					cCidade := SA2->A2_MUN
					cNome   := SA2->A2_NOME
					cEnd    := SA2->A2_END
					cCep    := If ((SA2->A2_CEP =' '),"99999",SA2->A2_CEP)
					cEmail  := SA2->A2_EMAIL
					cRecISS := SA2->A2_RECISS
				Endif 
			Else // se nao for nf de devolucao/beneficiamento (cliente)
				If ! SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					(cAliasSF3)->(dbSkip())
					Loop				    
				Else	
                	cCNPJ 	:= SA1->A1_CGC              
	   				cInscM  := SA1->A1_INSCRM
	   				cEst    := SA1->A1_EST
   			    	cCidade := SA1->A1_MUN
					cNome   := SA1->A1_NOME
					cEnd    := SA1->A1_END
					cCep    := If ((SA1->A1_CEP =' '),"99999",SA1->A1_CEP)
					cEmail  := SA1->A1_EMAIL
					cRecISS := SA1->A1_RECISS
				Endif
			Endif
		Else    // NF ENTRADA 
			If (cAliasSF3)->F3_TIPO$"DB" // verifica se a nf entrada e devolucao/beneficiamento (cliente)
				If ! SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)) // se nao localizada nota
					(cAliasSF3)->(dbSkip()) // proximo registro
					Loop
				Else
                	cCNPJ 	:= SA1->A1_CGC // localizou nota...armazena valor do cgc/cpf
	   			    cInscM  := SA1->A1_INSCRM
   					cEst    := SA1->A1_EST
					cCidade := SA1->A1_MUN
					cNome   := SA1->A1_NOME
					cEnd    := SA1->A1_END
					cCep    := If ((SA1->A1_CEP =' '),"99999",SA1->A1_CEP)
					cEmail  := SA1->A1_EMAIL
					cRecISS := SA1->A1_RECISS

				Endif
			Else // se nao for nf de devolucao/beneficiamento (fornecedor)
				If ! SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					(cAliasSF3)->(dbSkip())
					Loop
				Else
                	cCNPJ 	:= SA2->A2_CGC
   					cInscM  := SA2->A2_INSCRM
	   				cEst    := SA2->A2_EST
					cCidade := SA2->A2_MUN
					cNome   := SA2->A2_NOME
					cEnd    := SA2->A2_END
					cCep    := If ((SA2->A2_CEP =' '),"99999",SA2->A2_CEP)
					cEmail  := SA2->A2_EMAIL
					cRecISS := SA2->A2_RECISS
					
				Endif
			Endif
		Endif
        
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se recolhe ISS Retido ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		
		cRecISS := (cAliasSF3)->F3_RECISS
		                                     
	    If cRecISS $ "2N"
	    	nValISSRet := (cAliasSF3)->F3_VALICM
	    Else
			nValISSRet := 0
		Endif

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณInserindo dados nas tabelas temporariasณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ALLTRIM((cAliasSF3)->F3_ESPECIE)=="RPS"// RECIBO PROVISORIO DE SERVICO
        	
        	//Alimento primeiro a Tabela T03 para acumular os valores que serใo utilizados na T01 
        	  		
        			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPosiciona tabela SD1/SD2  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			nSeqItem:=1
			nValTotSer:=0 
        	nQtdItem:=0 
						
		    If SubStr((cAliasSF3)->F3_CFO,1,1) >= "5" //NF SAIDA
			   	//Armazeno outras retencoes 
				DbSelectArea("SE1")
				SE1->(dbSetOrder(2))                   
				If SE1->(dbSeek(xFilial("SE1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL))		
				nTotAbImp:= SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"V",SE1->E1_BAIXA)
					If nTotAbImp > 0
						nOutRet	 := nTotAbImp-nValISSRet
						nTotAbImp:=0
			   		Else
				   		nOutRet:=0
				   	Endif
				EndIf
		    
					DbSelectArea("SD2")
					SD2->(dbSetOrder(3)) 
					
					If SD2->(dbSeek(F3Filial("SD2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))		
					  
					 	While !SD2->(Eof()) .And. D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA == F3Filial("SF3")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA
					                                                        
					      If SD2->D2_BASEISS <> 0 .And. SD2->D2_VALISS <> 0                
					                      
							DbSelectArea("SB1")
							SB1->(dbSetOrder(1))
							If SB1->(dbSeek(F3Filial("SB1")+SD2->D2_COD))	
						       If lDescSB5                                     
	   							DbSelectArea("SB5")
								SB5->(dbSetOrder(1))
								SB5->(dbSeek(F3Filial("SB5")+SD2->D2_COD))	
					   		   EndIf						       
						       RecLock("T03",.T.) //cria reg. em branco na tabela T03 -- reservando a tabela T03
							    nQtdItem++
								T03->TIP    := "T3"
							    T03->NUM    := SD2->D2_DOC
								T03->SEQITE := nSeqItem++
								T03->QTDSER := SD2->D2_QUANT
								T03->UNMED  := SD2->D2_UM
					  				T03->DESC   := If (lDescSB5 .And. !Empty(SB5->B5_CEME),SB5->B5_CEME,SB1->B1_DESC)
								If !Empty((cAliasSF3)->F3_DTCANC) .Or. ('CANCELAD'$(cAliasSF3)->F3_OBSERV) // se nf cancelada		    
									T03->VLRUNI := 0
									T03->VLTOT  := 0
								Else
									T03->VLRUNI := SD2->D2_PRCVEN
									T03->VLTOT  := SD2->D2_TOTAL 
									DbSelectArea("SF2")              		
									SF2->(dbSetOrder(1))
								   	If SF2->(dbSeek(F3Filial("SD2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA))	                             
										nValTotSer  := (cAliasSF2)->F2_VALBRUT
								   	EndIf
								EndIf	
									
							   MsUnlock()// Destrava tabela T03
							EndIf
						  EndIf	
						SD2->(dbSkip())	
						Enddo
					EndIf	
			Else       
			
			//Armazeno outras retencoes 
			DbSelectArea("SF1")
			SF1->(dbSetOrder(1))                   
			If SF1->(dbSeek(F3Filial("SF1")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))		
			   nOutRet:= (SF1->F1_INSS + SF1->F1_IRRF+SF1->F1_ICMSRET)	
			Else
			   nOutRet:=0
			EndIf  
			
				DbSelectArea("SD1")
					SD1->(dbSetOrder(1))
					If SD1->(dbSeek(F3Filial("SD1")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))		
					    
					 	While !SD1->(Eof()) .And. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == F3Filial("SF3")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA
					      
					      If SD1->D1_BASEISS <> 0 .And. SD1->D1_VALISS <> 0 
					                      
							DbSelectArea("SB1")
							SB1->(dbSetOrder(1))
							If SB1->(dbSeek(F3Filial("SB1")+SD1->D1_COD))	
							   If lDescSB5                                     
	   							DbSelectArea("SB5")
								SB5->(dbSetOrder(1))
								SB5->(dbSeek(F3Filial("SB5")+SD1->D1_COD))	
					   		   EndIf				
				   		       RecLock("T03",.T.) //cria reg. em branco na tabela T03 -- reservando a tabela T03
								nQtdItem++
								T03->TIP    := "T3"
							    T03->NUM    := SD1->D1_DOC
								T03->SEQITE := nSeqItem++
								T03->QTDSER := SD1->D1_QUANT
								T03->UNMED  := SD1->D1_UM
								T03->DESC   := If (lDescSB5 .And. !Empty(SB5->B5_CEME),SB5->B5_CEME,SB1->B1_DESC) 
								If !Empty((cAliasSF3)->F3_DTCANC) .Or. ('CANCELAD'$(cAliasSF3)->F3_OBSERV) // se nf cancelada		    
									T03->VLRUNI := 0
									T03->VLTOT  := 0
								Else                             
									T03->VLRUNI := SD1->D1_VUNIT
									T03->VLTOT  := SD1->D1_TOTAL
									DbSelectArea("SF1")
									SF1->(dbSetOrder(1))
								   	If SF1->(dbSeek(F3Filial("SD1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
										nValTotSer  := (cAliasSF1)->F1_VALBRUT
									EndIf
								EndIf	
							  MsUnlock()// Destrava tabela T03
		                    EndIf
		                  EndIf  
						SD1->(dbSkip())	
						Enddo
			        EndIf
			EndIf        
			
					
			//Alimento depois para pegar os acumuladores da T03
			RecLock("T01",.T.) // cria reg. em branco na tabela T01 -- reservando a tabela T01
		    T01->TIP    := "T2"
		    T01->NUM    := (cAliasSF3)->F3_NFISCAL
		    T01->EMISS  := (cAliasSF3)->F3_EMISSAO 
		    T01->NOME   := cNome
			    If cEst=="EX"
			    	T01->TPPES  := "Estrangeira"
			    ElseIf RetPessoa(cCNPJ) == "F" 
			    	T01->TPPES  := "Fisica"
			    Else
			    	T01->TPPES  := "Juridica"
			    EndIf
			    If RetPessoa(cCNPJ)=="J" .Or. (cEst == "EX")	
			    	T01->CNPJ   := cCNPJ
			    Else
			        T01->CPF    := cCNPJ
			    EndIf    
				If cMun<>Alltrim(Upper(cCidade)) .Or. RetPessoa(cCNPJ) == "F" 
					T01->INSCM  := ""
				Else
		    		T01->INSCM  := cInscM
		    	EndIf	
		    	  
		    T01->ENDE   := cEnd
		    T01->CIDADE := cCidade
		    T01->ESTADO := cEst
		    T01->CEP    := cCep
		    T01->EMAIL  := cEmail
            	If !Empty((cAliasSF3)->F3_DTCANC) .Or. ('CANCELAD'$(cAliasSF3)->F3_OBSERV) // se nf cancelada		    
				    T01->ISS    := 0 
				    T01->VLRDOC := 0
			        T01->QTDITE := 0
				    T01->OUTRET := 0
				    T01->VLRPG  := 0
				    T01->VLRDED := 0
				    T01->VLBASE := 0
				Else
			        T01->ISS    := nValISSRet 
			        T01->VLRDOC := nValTotSer
			        T01->QTDITE := nQtdItem
				    T01->OUTRET := nOutRet
				    T01->VLRPG  := (nValTotSer - nValISSRet - nOutRet)
				    T01->VLRDED := (cAliasSF3)->F3_ISSSUB
				    T01->VLBASE := (nValTotSer-(cAliasSF3)->F3_ISSSUB)
				EndIf
				    
			If ExistBlock("ISVITOBS")   
				T01->OBSER  := Execblock("ISVITOBS", .F., .F., {cAliasSF3})
			Else		    
			    T01->OBSER  := (cAliasSF3)->F3_OBSERV
			EndIf
	    	MsUnlock() // Destrava tabela T01
	    				
		ElseIf SubStr((cAliasSF3)->F3_CFO,1,1) >= "5" // NF SAIDA
			RecLock("P02",.T.) // cria reg. em branco na tabela P02 -- reservando a tabela P02
			P02->NF		:= (cAliasSF3)->F3_NFISCAL
 			P02->NAIDF	:= cNumAidf
			P02->AAIDF	:= cAnoAidf
			P02->EMISS	:= (cAliasSF3)->F3_EMISSAO
			If !Empty((cAliasSF3)->F3_DTCANC) .Or. ('CANCELAD'$(cAliasSF3)->F3_OBSERV) // se nf cancelada			
				P02->SITNF	:= "Cancelado"
				P02->CNAE 	:= "0"
				P02->TPPES	:= "Fisica"
			Else
				P02->SITNF	:= "Normal"				
				P02->CNAE	:= SM0->M0_CNAE
				P02->VLRDOC	:= (cAliasSF3)->F3_VALCONT
				P02->BASE	:= (cAliasSF3)->F3_BASEICM
				If SA1->A1_EST == "EX"
	 				P02->TPPES	:= "Estrangeira"
 	            Elseif RetPessoa(cCNPJ) == "F" 
	 				P02->TPPES	:= "Fisica"
	 			Else	 	             							
					P02->TPPES	:= "Juridica"
				Endif	     
				P02->ISS := nValISSRet
				If !"FISICA"$AllTrim(P02->TPPES)
					P02->CNPJ	:= cCNPJ
				Endif	
			Endif 
			MsUnlock() // Destrava tabela P02
		Else // NF ENTRADA
			If !Empty((cAliasSF3)->F3_DTCANC) .Or. ('CANCELAD'$(cAliasSF3)->F3_OBSERV) // se nf for cancelada nao faz nada...
				(cAliasSF3)->(dbSkip())
				Loop				   
			Endif	     			
			RecLock("T02",.T.)
			T02->NF		:= (cAliasSF3)->F3_NFISCAL
 			T02->MODNF	:= AModNot((cAliasSF3)->F3_ESPECIE) // Funcao AModNot --> pega modelo da nota fiscal
			T02->SERIE	:= SerieNfId(cAliasSF3,2,"F3_SERIE")
			T02->TPNF	:= "Nota Fiscal"
			T02->NCONTR	:= "0"                    // verificar
			T02->EMISS	:= (cAliasSF3)->F3_EMISSAO
			T02->PAGAM	:= SubStr(Alltrim((cAliasSF3)->E2_BAIXA),7,2) + "/" + SubStr(Alltrim((cAliasSF3)->E2_BAIXA),5,2) + "/" + SubStr(Alltrim((cAliasSF3)->E2_BAIXA),1,4) //cPagament
			If !Empty((cAliasSF3)->F3_DTCANC) .Or. ('CANCELAD'$(cAliasSF3)->F3_OBSERV)
				T02->SITNF	:= "Cancelado"
			Else
				T02->SITNF	:= "Normal"
			Endif
			T02->ALIQ	:= (cAliasSF3)->F3_ALIQICM
			T02->VLRDOC	:= (cAliasSF3)->F3_VALCONT
			T02->VLRMAT	:= (cAliasSF3)->F3_ISSMAT				
			T02->VLRSUB	:= (cAliasSF3)->F3_ISSSUB
			T02->ISS	:= nValISSRet
			If RetPessoa(cCNPJ)=="J" .Or. (cEst == "EX")
				T02->CNPJ	:= cCNPJ
            Else
				T02->CPF	:= cCNPJ
			Endif
			MsUnlock() // Destrava tabela T02
		Endif
		(cAliasSF3)->(dbSkip()) // Proximo registro
	Enddo                 
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณISISSTemp   บAutor  ณAndressa Ataides    บ Data ณ 05/05/2005  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria os arquivos temporarios                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณISISS                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ISISSTemp() 

	Local aTrbs	  	:= {}
	Local aStruP02	:= {}	// registro 02 -- prestados
	Local aStruT02	:= {}  // registro 02 -- tomados
	Local aStruT01  := {}  // registro 01 -- recibos provisorios
	Local aStruT03  := {}  // registro 03 -- itens recibos provisorios
	Local cArqP02	:= ""
	Local cArqT02	:= ""

                            
/* Criacao dos campos na tabela temporaria P02 --> tabela de servicos prestados registro 02*/
	AADD(aStruP02,{"NF"	   	,"C",TamSX3("F2_DOC")[1],0})
	AADD(aStruP02,{"NAIDF"	,"C",006,0})
	AADD(aStruP02,{"AAIDF"	,"C",004,0})
	AADD(aStruP02,{"EMISS"	,"D",008,0})
	AADD(aStruP02,{"SITNF"	,"C",017,0})
	AADD(aStruP02,{"CNAE"	,"C",007,0})
	AADD(aStruP02,{"VLRDOC"	,"N",014,2})
	AADD(aStruP02,{"BASE"	,"N",014,2})
	AADD(aStruP02,{"TPPES"	,"C",011,0})
	AADD(aStruP02,{"ISS"	,"N",014,2})
	AADD(aStruP02,{"INSC"	,"C",014,0})
	AADD(aStruP02,{"CNPJ"	,"C",014,0})
	//
	cArqP02	:=	CriaTrab(aStruP02)
	dbUseArea(.T.,__LocalDriver,cArqP02,"P02")
	IndRegua("P02",cArqP02,"NF") // ordernar por nf -- chave NF


/* Criacao dos campos na tabela temporaria T02 --> tabela de servicos tomados registro 02*/
	AADD(aStruT02,{"NF"	   	,"C",TamSX3("F2_DOC")[1],0})
	AADD(aStruT02,{"MODNF"	,"C",006,0})
	AADD(aStruT02,{"SERIE"	,"C",002,0})
	AADD(aStruT02,{"TPNF"	,"C",011,0})
	AADD(aStruT02,{"NCONTR"	,"C",009,0})
	AADD(aStruT02,{"EMISS"	,"D",008,0})
	AADD(aStruT02,{"PAGAM"	,"C",010,0})
	AADD(aStruT02,{"SITNF"	,"C",017,0})
	AADD(aStruT02,{"ALIQ"	,"N",005,2})
	AADD(aStruT02,{"VLRDOC"	,"N",014,2})
	AADD(aStruT02,{"VLRGLO"	,"N",014,2})
	AADD(aStruT02,{"VLRMAT"	,"N",014,2})
	AADD(aStruT02,{"VLRSUB"	,"N",014,2})
	AADD(aStruT02,{"ISS"	,"N",014,2})
	AADD(aStruT02,{"CNPJ"	,"C",014,0})
	AADD(aStruT02,{"CPF"	,"C",011,0})
	//                              
	cArqT02	:=	CriaTrab(aStruT02)
	dbUseArea(.T.,__LocalDriver,cArqT02,"T02")
	IndRegua("T02",cArqT02,"NF") // ordernar por nf -- chave NF]       
	
	
	/* Criacao dos campos na tabela temporaria T01 --> tabela de recibos provisorios registro 02*/
	AADD(aStruT01,{"TIP"   	,"C",002,0})
	AADD(aStruT01,{"NUM"   	,"C",TamSX3("F2_DOC")[1],0})
	AADD(aStruT01,{"EMISS"	,"D",008,0})
	AADD(aStruT01,{"NOME"	,"C",040,0})
    AADD(aStruT01,{"TPPES"	,"C",011,0})	
	AADD(aStruT01,{"CNPJ"	,"C",014,0})    
	AADD(aStruT01,{"CPF"	,"C",011,0})
    AADD(aStruT01,{"INSCM"	,"C",018,0})	
	AADD(aStruT01,{"ENDE"	,"C",040,0})    
	AADD(aStruT01,{"CIDADE"	,"C",015,0})    
	AADD(aStruT01,{"ESTADO"	,"C",002,0})    
	AADD(aStruT01,{"CEP"	,"C",008,0})    
	AADD(aStruT01,{"EMAIL"	,"C",Iif(TAMSX3("A1_EMAIL")[1]>TAMSX3("A2_EMAIL")[1],TAMSX3("A1_EMAIL")[1],TAMSX3("A2_EMAIL")[1]),0})
    AADD(aStruT01,{"VLRDOC"	,"N",014,2})    
    AADD(aStruT01,{"ISS"	,"N",014,2})    
	AADD(aStruT01,{"OUTRET"	,"N",014,2})
	AADD(aStruT01,{"VLRPG"	,"N",014,2})	
	AADD(aStruT01,{"QTDITE"	,"N",014,0})
	AADD(aStruT01,{"VLRDED"	,"N",014,2})	
    AADD(aStruT01,{"VLBASE"	,"N",014,2})
    AADD(aStruT01,{"OBSER"	,"C",TAMSX3("F3_OBSERV")[1],0})
    //	                              
	cArqT01	:=	CriaTrab(aStruT01)
	dbUseArea(.T.,__LocalDriver,cArqT01,"T01")
	IndRegua("T01",cArqT01,"NUM") // ordernar por nf -- chave NF
	
   	/* Criacao dos campos na tabela temporaria T03 --> tabela de recibos provisorios registro 03*/
	AADD(aStruT03,{"TIP"   	,"C",002,0})
	AADD(aStruT03,{"NUM"   	,"C",TamSX3("F2_DOC")[1],0})
    AADD(aStruT03,{"SEQITE"	,"N",014,0})
    AADD(aStruT03,{"QTDSER"	,"N",014,TamSX3("D2_QUANT")[2]})
    AADD(aStruT03,{"UNMED"	,"C",002,0})	
    AADD(aStruT03,{"DESC"	,"C",250,0})
    AADD(aStruT03,{"VLRUNI"	,"N",014,2})    
    AADD(aStruT03,{"VLTOT"	,"N",014,2})    
	//                              
	cArqT03	:=	CriaTrab(aStruT03)
	dbUseArea(.T.,__LocalDriver,cArqT03,"T03")
	IndRegua("T03",cArqT03,"NUM") // ordernar por nf -- chave NF	

    
	aTrbs := {{cArqP02,"P02"},{cArqT02,"T02"},{cArqT01,"T01"},{cArqT03,"T03"}}

Return aTrbs


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณISISSDel    บAutor  ณAndressa Ataides    บ Data ณ 05/05/2005  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDeleta os arquivos temporarios processados                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณISISS                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/         
Function ISISSDel(aDelArqs) // Chamada da funcao no ini.

	Local aAreaDel := GetArea()
	Local nI := 0
	
	For nI:= 1 To Len(aDelArqs)
		If File(aDelArqs[nI,1]+GetDBExtension())
			dbSelectArea(aDelArqs[ni,2])
			dbCloseArea()
			Ferase(aDelArqs[nI,1]+GetDBExtension())
			Ferase(aDelArqs[nI,1]+OrdBagExt())
		Endif	
	Next
	
	RestArea(aAreaDel)
	
Return	
