#Include "SEFINSC.ch"
#Include "Protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SEFINSC   ³ Autor ³  Luciana Pires        ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³SEFINNET - Sistema Eletrônico de Declaração de ISS - do     ³±±
±±³          ³Município de Santa Catarina - SC   						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD -> Data inicial do periodo - mv_par01     			  ³±±
±±³          ³ExpD -> Data final do periodo - mv_par02                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SEFINSC(dDtInicial, dDtFinal)
	Local aTrbs		:= {}
	Private aCfp 	:= {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera arquivos temporarios            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTrbs := GeraTemp()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rotina Cfp                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Cfp()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recupera dados do arquivo Cfp                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		xMagLeWiz("SEFINSC",@aCfp,.T.)
	
		Processa({||ProcSEFIN(dDtInicial, dDtFinal)})
	Endif

Return (aTrbs)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcSEFIN  ³ Autor ³Luciana Pires          ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro do SEFIN de Santa Catarina - SC            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcSEFIN(dDtInicial, dDtFinal)
Local cTpDecl	:= Alltrim(aCfp[1][01])
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa os Registros                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
	// Para todos os tipos de declaração serão gerados os Registros Tipo H e C.
	ProcRegH()			 								//Registro Tipo H - Cabecalho
	ProcRegC()							  				//Registro Tipo C - Contribuinte

	If Left(cTpDecl,1) == "1"
		ProcRegP(dDtInicial, dDtFinal)					//Registro Tipo P - Prestadores, Tomadores e Gráfica que emite o talonário do contribuinte
		ProcRegT(dDtInicial, dDtFinal)     				//Registro Tipo T - Talonario dos Contribuintes
		If Dtos(dDtInicial) >="20040401"
			ProcRegE(dDtInicial, dDtFinal)				//Registro Tipo E - Nota Fiscal Emitida
			ProcRegF(dDtInicial, dDtFinal)        		//Registro Tipo F - Nota Fiscal Emitida para Pessoa Física
		Endif
	ElseIf Left(cTpDecl,1) == "2"
		ProcRegP(dDtInicial, dDtFinal)					//Registro Tipo P - Prestadores, Tomadores e Gráfica que emite o talonário do contribuinte
		If Dtos(dDtInicial) >="20040401"
			ProcRegR(dDtInicial, dDtFinal)				//Registro Tipo R - Nota Fiscal Recebida
		Endif
	ElseIf Left(cTpDecl,1) == "3"
		If Dtos(dDtInicial) >= "20040701"
			aItens := ProcRegI(dDtInicial, dDtFinal)	//Registro Tipo I - GIF-PJ e GIF-ST Guia de Informacoes Fiscais         
			ProcRegJ(dDtInicial, dDtFinal,aItens)		//Registro Tipo J - GIF-PJ e GIF-ST Itens da Guia de Informacoes Fiscaise GIF Ajuste
			If Left(Alltrim(aCfp[2][01]),1) == "3"
				ProcRegA(dDtInicial, dDtFinal,aItens)		//Registro Tipo A - e GIF Ajuste
			EndIf
		Endif
	ElseIf Left(cTpDecl,1) == "4"
		If Dtos(dDtInicial) >= "20040701"
			aItens := ProcRegI(dDtInicial, dDtFinal)	//Registro Tipo I - GIF-PJ e GIF-ST Guia de Informacoes Fiscais         
			ProcRegJ(dDtInicial, dDtFinal,aItens)		//Registro Tipo J - GIF-PJ e GIF-ST Itens da Guia de Informacoes Fiscais e GIF Ajuste
		Endif	
	Endif                                
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegH   ³ Autor ³Luciana Pires          ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo H - Cabecalho					       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegH

	dbSelectArea("RTH")
	RecLock("RTH",.T.)	
	RTH->VERSAO		:= Alltrim(aCfp[1][02])
	MsUnlock() 
	
Return Nil 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegC   ³ Autor ³Luciana Pires          ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo C - Contribuinte                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegC
Local cEndereco := AllTrim(SM0->M0_ENDENT)	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Incluindo dados na Tabela RTC              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("RTC")
	RecLock("RTC",.T.)	

	RTC->CMC		:= RetNf(SM0->M0_INSCM,7,"N")
	RTC->CNPJ		:= Alltrim(SM0->M0_CGC)
	RTC->RSOCIAL   	:= AllTrim(SM0->M0_NOMECOM)
	RTC->NOMEFANT	:= AllTrim(SM0->M0_NOME)
	RTC->INSCREST	:= Alltrim(SM0->M0_INSC)
	RTC->ENDERECO	:= Substr(cEndereco, 1, At(",", cEndereco)-1)
	RTC->NUMERO		:= StrZero(Val(Alltrim(Substr(cEndereco, At(",",cEndereco)+1, (At(" ",cEndereco))))),10)
	RTC->COMPL		:= Alltrim(Substr(cEndereco,At("-",cEndereco)+1,Len(cEndereco)))
	RTC->BAIRRO		:= Alltrim(SM0->M0_BAIRENT)
	RTC->CIDADE		:= Alltrim(SM0->M0_CIDENT)
	RTC->UF			:= Alltrim(SM0->M0_ESTENT)
	RTC->CEP		:= Alltrim(SM0->M0_CEPENT)
	RTC->DDD		:= Substr(Alltrim(SM0->M0_TEL),1,2)
	RTC->FONE		:= Substr(Alltrim(SM0->M0_TEL),3)
	RTC->FAX		:= Substr(Alltrim(SM0->M0_FAX),3)
	RTC->EMAIL		:= Alltrim(aCfp[1][03])

	MsUnlock() 
	
Return Nil 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegP   ³ Autor ³Luciana Pires          ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo P - Prestadores de outros municípios  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegP(dDtInicial,dDtFinal)
	Local aMVGRAFICA	:= IIF(!Empty((GetNewPar("MV_GRAFICA", "{}"))),&(GetNewPar("MV_GRAFICA", "{}")),"")  //Campo da tabela SA1/SA2 que indica se eh Grafica ou nao
	Local cAliasSF3		:= "SF3"
	Local cRSocial		:= ""
	Local cNome			:= ""			
	Local cCNPJ			:= ""
	Local cEndereco		:= ""
	Local cNumero		:= ""
	Local cComplem		:= ""
	Local cBairro 		:= ""
	Local cCidade		:= ""		
	Local cEstado		:= ""		
	Local cCep   		:= ""		
	Local cDDD			:= ""			
	Local cFone			:= ""	   
	Local cGrafica		:= ""
	
	#IFDEF TOP
		Local nX		:= 0     
		Local aStruSF3	:= {}                                       
		Local lQuery	:= .F.
	#ENDIF
     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona a Movimentação de Entradas e Saidas para selecionar os Clientes/Fornecedores	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	dbSelectArea("SF3")
	dbSetOrder(1)               
	ProcRegua(LastRec())
	
	#IFDEF TOP    
	    If TcSrvType()<>"AS/400"
			lQuery		:= .T.
			cAliasSF3	:= "SF3_SEF"
			aStruSF3	:= SF3->(dbStruct())
			cQuery		:= "SELECT F3_CFO, F3_CLIEFOR, F3_LOJA "
			cQuery    	+= "FROM " + RetSqlName("SF3") + " "
			cQuery    	+= "WHERE F3_FILIAL = '" + xFilial("SF3") + "' AND "
			cQuery 		+= "F3_ENTRADA >= '" + Dtos(dDtInicial) + "' AND "
			cQuery 		+= "F3_ENTRADA <= '" + Dtos(dDtFinal) + "' AND "  
			cQuery 		+= "F3_TIPO = 'S' AND "  			
			cQuery 		+= "D_E_L_E_T_ = ' ' "
			cQuery 		+= "ORDER BY "+SqlOrder(SF3->(IndexKey()))
			cQuery 		:= ChangeQuery(cQuery)                       			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3)   
				
			For nX := 1 To len(aStruSF3)
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
		   	cCondicao += '.And. DTOS(F3_ENTRADA) <= "' + DTOS(dDtFinal) + '" '
		   	cCondicao += '.And. F3_TIPO $ "S" '
		    IndRegua(cAliasSF3,cIndex,SF3->(IndexKey()),,cCondicao)
		    nIndex := RetIndex("SF3")
				
			#IFNDEF TOP
				dbSetIndex(cIndex+OrdBagExt())
			#ENDIF    
			dbSelectArea("SF3")
		    dbSetOrder(nIndex+1)
		    dbSelectArea(cAliasSF3)
		    ProcRegua(LastRec())
	    	dbGoTop()
	#IFDEF TOP
		Endif                                           
	#ENDIF

	Do While !(cAliasSF3)->(Eof())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cliente/Fornecedor³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If SubStr((cAliasSF3)->F3_CFO,1,1) >= "5"
			If !SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				(cAliasSF3)->(dbSkip())
				Loop				
			Else
				If (Alltrim(SA1->A1_MUN)$"FLORIANOPOLIS/FLORIANÓPOLIS" .And. SA1->A1_EST=="SC")
					(cAliasSF3)->(dbSkip())
					Loop				
				Else
					cInscm      := SA1->A1_INSCRM
					cRSocial	:= SA1->A1_NOME
					cCNPJ		:= SA1->A1_CGC 
					cNome		:= SA1->A1_NREDUZ	
					cCidade		:= SA1->A1_MUN		
					cEstado		:= SA1->A1_EST		
					cEndereco	:= Substr(SA1->A1_END, 1, At(",", SA1->A1_END)-1)
					cNumero		:= StrZero(Val(Alltrim(Substr(SA1->A1_END, At(",",SA1->A1_END)+1, (At(" ",SA1->A1_END))))),10)
					cComplem	:= Alltrim(Substr(SA1->A1_END, At("-",SA1->A1_END)+1, Len (AllTrim (SA1->A1_END))))
					cBairro 	:= SA1->A1_BAIRRO
					cCep   		:= RetNf(SA1->A1_CEP,8,"N")
					cDDD		:= RetNf(SA1->A1_DDD,2,"N")
					cFone		:= SA1->A1_TEL
					cGrafica	:= Iif(Len(aMVGRAFICA)>0,If (SA1->(FieldPos(aMVGRAFICA[1]))<>0, Iif(!Empty(SA1->&(aMVGRAFICA[1])),SA1->&(aMVGRAFICA[1]),"0"),"0"),"0")
				Endif
			Endif
		Else
			If ! SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				(cAliasSF3)->(dbSkip())
				Loop
			Else
				If (Alltrim(SA2->A2_MUN)$"FLORIANOPOLIS/FLORIANÓPOLIS" .And. SA2->A2_EST=="SC")
					(cAliasSF3)->(dbSkip())
					Loop				
				Else 
					cInscm      := SA1->A1_INSCRM				
					cRSocial	:= SA2->A2_NOME
					cNome		:= SA2->A2_NREDUZ	
					cCNPJ		:= SA2->A2_CGC 
					cCidade		:= SA2->A2_MUN		
					cEstado		:= SA2->A2_EST		
					cEndereco	:= Substr(SA2->A2_END, 1, At(",", SA2->A2_END)-1)
					cNumero		:= StrZero(Val(Alltrim(Substr(SA2->A2_END, At(",",SA2->A2_END)+1, (At(" ",SA2->A2_END))))),10)
					cComplem	:= Alltrim(Substr(SA2->A2_END, At("-",SA2->A2_END)+1, Len (AllTrim (SA2->A2_END))))
					cBairro 	:= SA2->A2_BAIRRO
					cCep   		:= RetNf(SA2->A2_CEP,8,"N")
					cDDD		:= RetNf(SA2->A2_DDD,2,"N")
					cFone		:= SA2->A2_TEL
					cGrafica	:= Iif(Len(aMVGRAFICA)>0,If (SA2->(FieldPos(aMVGRAFICA[2]))<>0, Iif(!Empty(SA2->&(aMVGRAFICA[2])),SA2->&(aMVGRAFICA[2]),"0"),"0"),"0")
				Endif
			Endif 		
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Incluindo dados na Tabela RTP              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		dbSelectArea("RTP")
		RecLock("RTP",.T.)	
		RTP->CMC		:= RetNf(cInscm,7,"N")
		RTP->CNPJ		:= cCNPJ 
		RTP->RSOCIAL   	:= cRSocial
		RTP->NOMEFANT	:= cNome
		RTP->ENDERECO	:= cEndereco
		RTP->NUMERO		:= cNumero
		RTP->COMPL		:= cComplem
		RTP->BAIRRO		:= cBairro
		RTP->CEP		:= cCep
		RTP->CIDADE		:= cCidade
		RTP->UF			:= cEstado
		RTP->DDD		:= cDDD
		RTP->FONE		:= cFone
		RTP->GRAFICA	:= cGrafica
	
		MsUnlock() 
	
	(cAliasSF3)->(dbSkip())		           
	Enddo 	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SF3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery
		RetIndex("SF3")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
	Else
		dbSelectArea(cAliasSF3)
		dbCloseArea()
	Endif
	
Return Nil 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegT   ³ Autor ³Luciana Pires          ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo T - Talonários dos Contribuintes      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegT(dDtInicial, dDtFinal)
Local aMVGRAFICA	:= IIF(!Empty((GetNewPar("MV_GRAFICA", "{}"))),&(GetNewPar("MV_GRAFICA", "{}")),"")  //Campo da tabela SA1/SA2 que indica se eh Grafica ou nao

Local cAliasSF3	:= "SF3"                      
Local cCnpj		:= ""
Local cMun		:= "" 		
Local cInscm 	:= "" 	
Local cCMC		:= RetNf(SM0->M0_INSCM,7,"N")
Local cCnpjC    := RetNf(SM0->M0_CGC,14,"N")
Local cNumAidf 	:= ""
Local cNumINI	:= ""
Local cNumFIM	:= ""

//Aidf -  1 - Numero da AIDF
		//2 - Tipo de Impressao ou Dispositivo
		//3 - Numero Inicial
		//4 - Numero Final
		//5 - Data de Autorizacao
		//6 - Modelo da Nota Fiscal

	#IFDEF TOP
		Local nX		:= 0     
		Local aStruSF3	:= {}                                       
		Local lQuery	:= .F.
	#ENDIF
     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona a Movimentação de Entradas e Saidas para selecionar as NF's					   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	dbSelectArea("SF3")
	dbSetOrder(1)               
	ProcRegua(LastRec())
	
	#IFDEF TOP    
	    If TcSrvType()<>"AS/400"
			lQuery		:= .T.
			cAliasSF3	:= "SF3_SEF"
			aStruSF3	:= SF3->(dbStruct())
			cQuery		:= "SELECT F3_CFO, F3_CLIEFOR, F3_LOJA, F3_NFISCAL, F3_SERIE, "+SerieNfId('SF3',3,'F3_SERIE')+" F3_SERIEX "
			cQuery    	+= "FROM " + RetSqlName("SF3") + " "
			cQuery    	+= "WHERE F3_FILIAL = '" + xFilial("SF3") + "' AND "
			cQuery 		+= "F3_ENTRADA >= '" + Dtos(dDtInicial) + "' AND "
			cQuery 		+= "F3_ENTRADA <= '" + Dtos(dDtFinal) + "' AND "  
			cQuery 		+= "F3_TIPO = 'S' AND "  			
			cQuery 		+= "D_E_L_E_T_ = ' ' "
			cQuery 		+= "ORDER BY "+SqlOrder(SF3->(IndexKey()))
			cQuery 		:= ChangeQuery(cQuery)                       			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3)   
				
			For nX := 1 To len(aStruSF3)
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
		   	cCondicao += '.And. DTOS(F3_ENTRADA) <= "' + DTOS(dDtFinal) + '" '
		   	cCondicao += '.And. F3_TIPO $ "S" '
		    IndRegua(cAliasSF3,cIndex,SF3->(IndexKey()),,cCondicao)
		    nIndex := RetIndex("SF3")
				
			#IFNDEF TOP
				dbSetIndex(cIndex+OrdBagExt())
			#ENDIF    
			dbSelectArea("SF3")
		    dbSetOrder(nIndex+1)
		    dbSelectArea(cAliasSF3)
		    ProcRegua(LastRec())
	    	dbGoTop()
	#IFDEF TOP
		Endif                                           
	#ENDIF

	Do While !(cAliasSF3)->(Eof())
	
		If SubStr((cAliasSF3)->F3_CFO,1,1) >= "5"
			If !SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				(cAliasSF3)->(dbSkip())
				Loop				
			Else  
			
				If Len(aMVGRAFICA)>0
					If ((SA1->(FieldPos(aMVGRAFICA[1]))<>0) .And. (SA1->&(aMVGRAFICA[1]) == "0")) //Nao é grafica
						(cAliasSF3)->(dbSkip())
						Loop						
					Else
						cCnpj	:= SA1->A1_CGC
						cMun	:= Iif(Alltrim(SA1->A1_MUN)$"FLORIANOPOLIS/FLORIANÓPOLIS" .And. SA1->A1_EST=="SC","1","0")
					Endif                                                                             
				Else
					cCnpj	:= SA1->A1_CGC
					cMun	:= Iif(Alltrim(SA1->A1_MUN)$"FLORIANOPOLIS/FLORIANÓPOLIS" .And. SA1->A1_EST=="SC","1","0")
				Endif                                                                             
			Endif
		Else
			If !SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				(cAliasSF3)->(dbSkip())
				Loop				
			Else
				If Len(aMVGRAFICA)>0 
					If ((SA2->(FieldPos(aMVGRAFICA[2]))<>0) .And. (SA2->&(aMVGRAFICA[2]) == "0")) //Nao é grafica
							(cAliasSF3)->(dbSkip())
							Loop				
					Else
						cCnpj	:= SA2->A2_CGC
						cMun	:= Iif(Alltrim(SA2->A2_MUN)$"FLORIANOPOLIS/FLORIANÓPOLIS" .And. SA2->A2_EST=="SC","1","0")
					Endif
		   		Else
					cCnpj	:= SA2->A2_CGC
					cMun	:= Iif(Alltrim(SA2->A2_MUN)$"FLORIANOPOLIS/FLORIANÓPOLIS" .And. SA2->A2_EST=="SC","1","0")
				Endif
			Endif
		Endif

		cNumAidf := RetAIDF((cAliasSF3)->F3_NFISCAL, (cAliasSF3)->F3_SERIE)[1]
		cNumAidf := RetNf(cNumAidf,40,"N")
		cNumINI	 := RetAIDF((cAliasSF3)->F3_NFISCAL, (cAliasSF3)->F3_SERIE)[3]
		cNumINI	 := RetNf(cNumINI,10,"N")
		cNumFIM	 := RetAIDF((cAliasSF3)->F3_NFISCAL, (cAliasSF3)->F3_SERIE)[4]
		cNumFIM	 := RetNf(cNumFIM,10,"N")
	    cSerie   := (cAliasSF3)->F3_SERIEX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Incluindo dados na Tabela RTT              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				  		
		If !Empty(Alltrim(cNumAidf))
			dbSelectArea("RTT")
			If !RTT->(DbSeek(cCMC+cMun+cCnpj+cNumAidf+cNumINI+cNumFIM))
				RecLock("RTT",.T.)	
				RTT->CMC		:= cCMC 
				RTT->CNPJC		:= cCnpjC 
				RTT->SERIE		:= cSerie
				RTT->MUNGRAF  	:= cMun
				RTT->CNPJGRAF  	:= cCnpj
				RTT->AIDF     	:= cNumAidf
				RTT->NUMNFINI 	:= cNumINI
				RTT->NUMNFFIM  	:= cNumFIM
				MsUnlock() 
			Endif
		Endif

		(cAliasSF3)->(dbSkip())		           
	Enddo 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SF3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery
		RetIndex("SF3")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
	Else
		dbSelectArea(cAliasSF3)
		dbCloseArea()
	Endif

Return Nil 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegE   ³ Autor ³Luciana Pires          ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo E - Nota Fiscal Emitida			   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegE(dDtInicial,dDtFinal)
	Local cAliasSF3		:= "SF3"
	Local cCMCT			:= ""
	Local cCNPJ			:= ""
	Local cSitTrib		:= ""
	Local cNumIni		:= ""
	
	#IFDEF TOP
		Local nX		:= 0     
		Local aStruSF3	:= {}                                       
		Local lQuery	:= .F.
	#ENDIF
     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 	//³Seleciona a Movimentação de Saidas 														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	dbSelectArea("SF3")
	dbSetOrder(1)               
	ProcRegua(LastRec())
	
	#IFDEF TOP    
	    If TcSrvType()<>"AS/400"
			lQuery		:= .T.
			cAliasSF3	:= "SF3_SEF"
			aStruSF3	:= SF3->(dbStruct())
			cQuery		:= "SELECT * "
			cQuery    	+= "FROM " + RetSqlName("SF3") + " "
			cQuery    	+= "WHERE F3_FILIAL = '" + xFilial("SF3") + "' AND "
			cQuery 		+= "F3_ENTRADA >= '" + Dtos(dDtInicial) + "' AND "
			cQuery 		+= "F3_ENTRADA <= '" + Dtos(dDtFinal) + "' AND "  
			cQuery 		+= "F3_TIPO = 'S' AND "  			
			cQuery 		+= "F3_CFO >= '5' AND " 
			cQuery 		+= "D_E_L_E_T_ = ' ' AND "
			cQuery			+= "F3_NFELETR <> ' ' "
			cQuery 		+= "ORDER BY "+SqlOrder(SF3->(IndexKey()))
			cQuery 		:= ChangeQuery(cQuery)                       			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3)   
				
			For nX := 1 To len(aStruSF3)
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
		   	cCondicao += '.And. DTOS(F3_ENTRADA) <= "' + DTOS(dDtFinal) + '" '
		   	cCondicao += '.And. F3_TIPO $ "S" '
		   	cCondicao += '.And. F3_CFO >= "5" '
		    IndRegua(cAliasSF3,cIndex,SF3->(IndexKey()),,cCondicao)
		    nIndex := RetIndex("SF3")
				
			#IFNDEF TOP
				dbSetIndex(cIndex+OrdBagExt())
			#ENDIF    
			dbSelectArea("SF3")
		    dbSetOrder(nIndex+1)
		    dbSelectArea(cAliasSF3)
		    ProcRegua(LastRec())
	    	dbGoTop()
	#IFDEF TOP
		Endif                                           
	#ENDIF

	Do While !(cAliasSF3)->(Eof())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cliente           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If !SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			(cAliasSF3)->(dbSkip())
			Loop				
		Else
			// Faco esta verificacao pois se for pessoa fisica deverá ser informado no registro F
			If Alltrim(SA1->A1_PESSOA)=="F"
				(cAliasSF3)->(dbSkip())
				Loop			
			Else
				cCNPJ	:= SA1->A1_CGC
				cCMCT   := RetNf(SA1->A1_INSCRM,7,"N")
			Endif
		Endif
		// Nota Inicial do Talonário - AIDF
		cNumIni	:= RetAIDF((cAliasSF3)->F3_NFISCAL, (cAliasSF3)->F3_SERIE)[3]	
		cSerie  := (cAliasSF3)->F3_SERIE 
		
		// Buscando Situação Tributária da TES
		SFT->(dbSetOrder(3))  
    	If SFT->(dbSeek(xFilial("SF3")+"S"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT))
			cSitTrib	:= SFT->FT_CSTISS
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Incluindo dados na Tabela RTE              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea ("SB1")
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SFT->FT_PRODUTO))        

		dbSelectArea("RTE")
		RecLock("RTE",.T.)	
			
		RTE->CMC		:= RetNf(SM0->M0_INSCM,7,"N")
		RTE->CNPJC      := RetNf(SM0->M0_CGC,14,"N")
		RTE->SERIE      := cSerie 
		RTE->NUMINITAL	:= RetNf(cNumIni,10,"N")
		RTE->DATANF	    := DataInt((cAliasSF3)->F3_EMISSAO)
		RTE->NUMNF		:= RetNf((cAliasSF3)->F3_NFELETR,15,"N")
		RTE->CMCTOM		:= cCMCT
		RTE->CNPJTOMA	:= cCNPJ
		RTE->CNAE		:= RetNf(SB1->B1_DIFCNAE,11,"N")
		RTE->TIPO		:= Iif(!Empty((cAliasSF3)->F3_DTCANC),"C","E")
		RTE->VLRCONT	:= (cAliasSF3)->F3_VALCONT
		RTE->BASECALC	:= (cAliasSF3)->F3_BASEICM
		RTE->OBSERV		:= Iif(!Empty((cAliasSF3)->F3_DTCANC),(cAliasSF3)->F3_OBSERV,Space(50))
		RTE->CFPS		:= RetNf((cAliasSF3)->F3_CFPS,4,"N")
		RTE->CST		:= RetNf(cSitTrib,3,"N")
		RTE->ALIQ		:= (cAliasSF3)->F3_ALIQICM
		RTE->VLRISS		:= (cAliasSF3)->F3_VALICM
			
		MsUnlock() 
				
		(cAliasSF3)->(dbSkip())		           
	Enddo 
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SF3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery
		RetIndex("SF3")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
	Else
		dbSelectArea(cAliasSF3)
		dbCloseArea()
	Endif
	
Return Nil 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegF   ³ Autor ³Luciana Pires          ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo F - Nota Fiscal Emitida Pessoa Fisica ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegF(dDtInicial,dDtFinal)
	Local cAliasSF3		:= "SF3"
	Local cSitTrib		:= ""
	Local cNumIni		:= ""

	#IFDEF TOP
		Local nX		:= 0     
		Local aStruSF3	:= {}                                       
		Local lQuery	:= .F.
	#ENDIF
     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 	//³Seleciona a Movimentação de Saidas 														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	dbSelectArea("SF3")
	dbSetOrder(1)               
	ProcRegua(LastRec())
	
	#IFDEF TOP    
	    If TcSrvType()<>"AS/400"
			lQuery		:= .T.
			cAliasSF3	:= "SF3_SEF"
			aStruSF3	:= SF3->(dbStruct())
			cQuery		:= "SELECT * "
			cQuery    	+= "FROM " + RetSqlName("SF3") + " "
			cQuery    	+= "WHERE F3_FILIAL = '" + xFilial("SF3") + "' AND "
			cQuery 		+= "F3_ENTRADA >= '" + Dtos(dDtInicial) + "' AND "
			cQuery 		+= "F3_ENTRADA <= '" + Dtos(dDtFinal) + "' AND "  
			cQuery 		+= "F3_TIPO = 'S' AND "  			
			cQuery 		+= "F3_CFO >= '5' AND " 
			cQuery 		+= "D_E_L_E_T_ = ' ' AND "			 
			cQuery			+= "F3_NFELETR <> ' ' "
			cQuery 		+= "ORDER BY "+SqlOrder(SF3->(IndexKey()))
			cQuery 		:= ChangeQuery(cQuery)                       			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3)   
				
			For nX := 1 To len(aStruSF3)
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
		   	cCondicao += '.And. DTOS(F3_ENTRADA) <= "' + DTOS(dDtFinal) + '" '
		   	cCondicao += '.And. F3_TIPO $ "S" '
		   	cCondicao += '.And. F3_CFO >= "5" '
		    IndRegua(cAliasSF3,cIndex,SF3->(IndexKey()),,cCondicao)
		    nIndex := RetIndex("SF3")
				
			#IFNDEF TOP
				dbSetIndex(cIndex+OrdBagExt())
			#ENDIF    
			dbSelectArea("SF3")
		    dbSetOrder(nIndex+1)
		    dbSelectArea(cAliasSF3)
		    ProcRegua(LastRec())
	    	dbGoTop()
	#IFDEF TOP
		Endif                                           
	#ENDIF

	Do While !(cAliasSF3)->(Eof())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cliente           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If !SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			(cAliasSF3)->(dbSkip())
			Loop				
		Else
			// Faco esta verificacao pois se for diferente de pessoa fisica deverá ser informado no registro E
			If Alltrim(SA1->A1_PESSOA)<>"F"
				(cAliasSF3)->(dbSkip())
				Loop			
			Endif
		Endif

		// Nota Inicial do Talonário - AIDF
		cNumIni		:= RetAIDF((cAliasSF3)->F3_NFISCAL, (cAliasSF3)->F3_SERIE)[3]	
		cSerie  	:= (cAliasSF3)->F3_SERIE 
			
		// Buscando Situação Tributária da TES
		SFT->(dbSetOrder(3))  
    	If SFT->(dbSeek(xFilial("SF3")+"S"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT))
			cSitTrib	:= SFT->FT_CSTISS
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Incluindo dados na Tabela RTF              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea ("SB1")
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SFT->FT_PRODUTO)) 
		 
		dbSelectArea("RTF")
		RecLock("RTF",.T.)	
			
		RTF->CMC		:= RetNf(SM0->M0_INSCM,7,"N")  
		RTF->CNPJC      := RetNf(SM0->M0_CGC,14,"N")
		RTF->SERIE      := cSerie 
		RTF->NUMINITAL	:= RetNf(cNumIni,15,"N")
		RTF->DATAEMINF	:= DataInt((cAliasSF3)->F3_EMISSAO)
		RTF->NUMNFINI	:= RetNf((cAliasSF3)->F3_NFELETR,15,"N")
		RTF->NUMNFFIM	:= RetNf((cAliasSF3)->F3_NFELETR,15,"N")
		RTF->CNAE		:= RetNf(SB1->B1_DIFCNAE,11,"N")
		RTF->TIPO		:= Iif(!Empty((cAliasSF3)->F3_DTCANC),"C","E")
		RTF->VLRCONT	:= (cAliasSF3)->F3_VALCONT
		RTF->BASECALC	:= (cAliasSF3)->F3_BASEICM
		RTF->OBSERV		:= Iif(!Empty((cAliasSF3)->F3_DTCANC),(cAliasSF3)->F3_OBSERV,Space(50))
		RTF->CFPS		:= RetNf((cAliasSF3)->F3_CFPS,4,"N")
		RTF->CST		:= RetNf(cSitTrib,3,"N")
		RTF->ALIQ		:= (cAliasSF3)->F3_ALIQICM
		RTF->VLRISS		:= (cAliasSF3)->F3_VALICM
			
		MsUnlock() 
				
		(cAliasSF3)->(dbSkip())		           
	Enddo 
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SF3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery
		RetIndex("SF3")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
	Else
		dbSelectArea(cAliasSF3)
		dbCloseArea()
	Endif
	
Return Nil 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegR   ³ Autor ³Luciana Pires          ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo R - Nota Fiscal Recebida			   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegR(dDtInicial,dDtFinal)
	Local cAliasSF3		:= "SF3"
	Local cCNPJ			:= ""    
	Local cCMCPREST		:= ""
	Local cSitTrib		:= ""

	#IFDEF TOP
		Local nX		:= 0     
		Local aStruSF3	:= {}                                       
		Local lQuery	:= .F.
	#ENDIF
     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 	//³Seleciona a Movimentação de Entradas														   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	dbSelectArea("SF3")
	dbSetOrder(1)               
	ProcRegua(LastRec())
	
	#IFDEF TOP    
	    If TcSrvType()<>"AS/400"
			lQuery		:= .T.
			cAliasSF3	:= "SF3_SEF"
			aStruSF3	:= SF3->(dbStruct())
			cQuery		:= "SELECT * "
			cQuery    	+= "FROM " + RetSqlName("SF3") + " "
			cQuery    	+= "WHERE F3_FILIAL = '" + xFilial("SF3") + "' AND "
			cQuery 		+= "F3_ENTRADA >= '" + Dtos(dDtInicial) + "' AND "
			cQuery 		+= "F3_ENTRADA <= '" + Dtos(dDtFinal) + "' AND "  
			cQuery 		+= "F3_TIPO = 'S' AND "  			
			cQuery 		+= "F3_CFO < '5' AND " 
			cQuery 		+= "D_E_L_E_T_ = ' ' "
			cQuery 		+= "ORDER BY "+SqlOrder(SF3->(IndexKey()))
			cQuery 		:= ChangeQuery(cQuery)                       			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3)   
				
			For nX := 1 To len(aStruSF3)
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
		   	cCondicao += '.And. DTOS(F3_ENTRADA) <= "' + DTOS(dDtFinal) + '" '
		   	cCondicao += '.And. F3_TIPO $ "S" '
		   	cCondicao += '.And. F3_CFO < "5" '
		    IndRegua(cAliasSF3,cIndex,SF3->(IndexKey()),,cCondicao)
		    nIndex := RetIndex("SF3")
				
			#IFNDEF TOP
				dbSetIndex(cIndex+OrdBagExt())
			#ENDIF    
			dbSelectArea("SF3")
		    dbSetOrder(nIndex+1)
		    dbSelectArea(cAliasSF3)
		    ProcRegua(LastRec())
	    	dbGoTop()
	#IFDEF TOP
		Endif                                           
	#ENDIF                       

	Do While !(cAliasSF3)->(Eof())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Fornecedor        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If !SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			(cAliasSF3)->(dbSkip())
			Loop				
		Else
			cCNPJ		:= SA2->A2_CGC
			cCMCPREST   := SA2->A2_INSCRM
		Endif

		// Buscando Situação Tributária da TES
		SFT->(dbSetOrder(3))  
    	If SFT->(dbSeek(xFilial("SF3")+"E"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT))
			cSitTrib	:= SFT->FT_CSTISS
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Incluindo dados na Tabela RTR              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea ("SB1")
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SFT->FT_PRODUTO))         

		dbSelectArea("RTR")
		RecLock("RTR",.T.)	
			
		RTR->CMC		:= RetNf(SM0->M0_INSCM,7,"N")
		RTR->CNPJC		:= RetNf(SM0->M0_CGC,14,"N")
		RTR->CMCPREST	:= cCMCPREST
		RTR->CNPJPREST	:= cCNPJ  
		RTR->NUMNF		:= RetNf((cAliasSF3)->F3_NFISCAL,15,"N")
		RTR->SERIE		:= (cAliasSF3)->F3_SERIE  
		RTR->CNAE		:= RetNf(SB1->B1_DIFCNAE,11,"N")
		RTR->DATANF	    := DataInt((cAliasSF3)->F3_EMISSAO)
		RTR->VLRCONT	:= (cAliasSF3)->F3_VALCONT
		RTR->BASECALC	:= (cAliasSF3)->F3_BASEICM
		RTR->OBSERV		:= (cAliasSF3)->F3_OBSERV
		RTR->CFPS		:= RetNf((cAliasSF3)->F3_CFPS,4,"N")
		RTR->CST		:= RetNf(cSitTrib,3,"N")
		RTR->ALIQ		:= (cAliasSF3)->F3_ALIQICM
		RTR->VLRISS		:= (cAliasSF3)->F3_VALICM
			
		MsUnlock() 
				
		(cAliasSF3)->(dbSkip())		           
	Enddo 
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SF3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery
		RetIndex("SF3")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
	Else
		dbSelectArea(cAliasSF3)
		dbCloseArea()
	Endif
	
Return Nil 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegI   ³ Autor ³Luciana Pires          ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo I - GIF-PJ ,GIF-ST OU GIF Ajuste      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegI(dDtInicial,dDtFinal)
	
	Local aItens		:= {}	//"",; 	//Numero da NF
							 	//"",;	//Tipo da NF (se "C"-Cancelada,"R"-Retida ou "N"-Normal)
							 	// 0,; 	//Valor ISS (Retido ou Devido)
							 	// 0,;	//Valor Contabil
							 	// 0,;	//Base
							 	// 0,;	//Aliquota
							 	// "",;	//CNAE
							 	// "",;	//CFPS
							 	// "",;	//CST
							 	// "",; //DATAEMISSAO
							 	// ""}		//NFELETR
							
	Local lMov			:= .T.
	Local lMVRECISS		:= GetNewPar("MV_F3RECIS", .F.)
	Local lRetido		:= lMVRECISS
	
	Local cAliasSF3		:= "SF3"
	Local cRetido		:= ""
	Local cIssSub		:= ""
	Local cNFCanc		:= ""
	Local cNFRet		:= ""
	Local cSitTrib		:= ""
		
	Local nTotRet		:= 0
	Local i				:= 0

	#IFDEF TOP
		Local nX		:= 0     
		Local aStruSF3	:= {}                                       
		Local lQuery	:= .F.
	#ENDIF
     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 	//³Seleciona a Movimentação de Entradas e Saídas											   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	dbSelectArea("SF3")
	dbSetOrder(1)               
	ProcRegua(LastRec())
	
	#IFDEF TOP    
	    If TcSrvType()<>"AS/400"
			lQuery		:= .T.
			cAliasSF3	:= "SF3_SEF"
			aStruSF3	:= SF3->(dbStruct())
			cQuery		:= "SELECT * "
			cQuery    	+= "FROM " + RetSqlName("SF3") + " "
			cQuery    	+= "WHERE F3_FILIAL = '" + xFilial("SF3") + "' AND "
			cQuery 		+= "F3_ENTRADA >= '" + Dtos(dDtInicial) + "' AND "
			cQuery 		+= "F3_ENTRADA <= '" + Dtos(dDtFinal) + "' AND "  
			cQuery 		+= "F3_TIPO = 'S' AND " 			

			If Left(Alltrim(aCfp[2][01]),1) == "1" 
				cQuery 	+= "F3_CFO >= '5' AND "  //GIF-PJ			
			Else
				cQuery 	+= "F3_CFO < '5' AND "  //GIF-ST 			
			Endif
			
			cQuery 		+= "D_E_L_E_T_ = ' ' "
			cQuery 		+= "ORDER BY "+SqlOrder(SF3->(IndexKey()))
			cQuery 		:= ChangeQuery(cQuery)                       			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3)   
				
			For nX := 1 To len(aStruSF3)
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
		   	cCondicao += '.And. DTOS(F3_ENTRADA) <= "' + DTOS(dDtFinal) + '" '
		   	cCondicao += '.And. F3_TIPO $ "S" '
			
			If Left(Alltrim(aCfp[2][01]),1) == "1" .Or. Left(Alltrim(aCfp[2][01]),1) == "3" 
				cCondicao += '.And. F3_CFO >= "5" '  //GIF-PJ			
			Else
				cCondicao += '.And. F3_CFO < "5" '  //GIF-ST 			
			Endif

		    IndRegua(cAliasSF3,cIndex,SF3->(IndexKey()),,cCondicao)
		    nIndex := RetIndex("SF3")
				
			#IFNDEF TOP
				dbSetIndex(cIndex+OrdBagExt())
			#ENDIF    
			dbSelectArea("SF3")
		    dbSetOrder(nIndex+1)
		    dbSelectArea(cAliasSF3)
		    ProcRegua(LastRec())
	    	dbGoTop()
	#IFDEF TOP
		Endif                                           
	#ENDIF                       

	Do While !(cAliasSF3)->(Eof())
		
		lMov	:= .F.
		
		// Buscando Cliente/Fornecedor
		If (cAliasSF3)->F3_CFO >= "5"
			SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
		Else
			SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)) 
			
			//Regulamento do ISSQN de Florianópolis (DECRETO MUNICIPAL Nº. 2.154/2003)
			//CFPS que geram valor de impostos a recolher para o município de Florianópolis são os CFPS 9.201, 9.302, 9.303 e 9.304							
			If !(Left(Alltrim(aCfp[2][01]),1) == "1" .Or. Left(Alltrim(aCfp[2][01]),1) == "3") .And. ;
			   SA2->A2_EST == "SC" .And. SA2->A2_COD_MUN == "05407" .And. SubStr((cAliasSF3)->F3_CFO,1,1) == "1" .And. ;
			   !(Alltrim((cAliasSF3)->F3_CFPS) $ ("9201|9302|9303|9304"))
			   
				(cAliasSF3)->(dbSkip())
				Loop
			EndIf 
		Endif
		
		//Verificando se ISS Retido	
		cRetido := Iif(lRetido,(cAliasSF3)->F3_RECISS,Iif((cAliasSF3)->F3_CFO >="5", SA1->A1_RECISS, SA2->A2_RECISS))
		cIssSub := Iif((cAliasSF3)->F3_CFO >= "5",Iif(cRetido$"S/1","1","0"),Iif(cRetido$"N/2","1","0"))		

		// Buscando Situação Tributaria
		If (cAliasSF3)->F3_CFO >= "5"
			SFT->(dbSetOrder(3))  
	    	If SFT->(dbSeek(xFilial("SF3")+"S"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT))
				cSitTrib	:= SFT->FT_CSTISS
			Endif
	    Else
			SFT->(dbSetOrder(3))  
	    	If SFT->(dbSeek(xFilial("SF3")+"E"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT))
				cSitTrib	:= SFT->FT_CSTISS
			Endif
		Endif
		DbSelectArea ("SB1")
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SFT->FT_PRODUTO)) 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Incluindo dados no array aItens            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd( aItens,{	(cAliasSF3)->F3_NFISCAL,;
						Iif(!Empty((cAliasSF3)->F3_DTCANC), "C", Iif(!Empty(Alltrim(cRetido)) .And. Alltrim(cIssSub)$"1", "R", "N")) ,;
						(cAliasSF3)->F3_VALICM,;
						(cAliasSF3)->F3_VALCONT,;
						(cAliasSF3)->F3_BASEICM,;
						(cAliasSF3)->F3_ALIQICM,;
						RetNF(SB1->B1_DIFCNAE,11,"N"),;
						RetNF((cAliasSF3)->F3_CFPS,4,"N"),;
						RetNF(cSitTrib,3,"N"),;
						RetNF(DataInt((cAliasSF3)->F3_EMISSAO)),;
						IF((cAliasSF3)->F3_CFO >= "5" .And. !Alltrim((cAliasSF3)->F3_NFELETR) == "", (cAliasSF3)->F3_NFELETR, (cAliasSF3)->F3_NFISCAL)})			// Adicionado condição if Valdemir José 24/04/2018
				
		(cAliasSF3)->(dbSkip())		           
	Enddo 
                    

 	If lMov

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Sem movimento para o período selecionado   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		dbSelectArea("RTI")
		RecLock("RTI",.T.)	                                      
		RTI->CMCCONTR 	:= RetNf(SM0->M0_INSCM,7,"N")
		RTI->CNPJCONTR 	:= SM0->M0_CGC
		RTI->MES      	:= Month(dDtInicial)
		RTI->ANO     	:= Year(dDtInicial)
		RTI->NFCANCEL	:= Space(255)
		RTI->SEMMOV	    := "1"
		RTI->TIPOGIF	:= Iif(Substr(Alltrim(aCfp[2][01]),1,1) == "1","0",Iif(Substr(Alltrim(aCfp[2][01]),1,1) == "2","1","6"))		
		RTI->RETIF  	:= Iif(Substr(Alltrim(aCfp[2][02]),1,1)== "1","1","0")
		MsUnlock() 
	Else
		// Preenche as variaveis
		
		For i:=1 to Len(aItens)
			If aItens[i,2]=="C" .And. aItens[i,11] <> ' '
				cNFCanc += aItens[i,11]+","		//Numero NF
			ElseIf aItens[i,2]=="R"
				cNFRet 	+= aItens[i,11]+","   	//Numero NF
				nTotRet	+= aItens[i,3] 			//Valor ISS
			Endif				
		Next		

		dbSelectArea("RTI")
		RecLock("RTI",.T.)	
		RTI->CMCCONTR 	:= RetNf(SM0->M0_INSCM,7,"N")
		RTI->CNPJCONTR 	:= SM0->M0_CGC
		RTI->MES      	:= Month(dDtInicial)
		RTI->ANO     	:= Year(dDtInicial)
		RTI->NFCANCEL	:= Substr(cNFCanc,1,len(cNFCanc)-1)
		RTI->SEMMOV	    := "0"
		RTI->TIPOGIF	:= Iif(Substr(Alltrim(aCfp[2][01]),1,1) == "1","0",Iif(Substr(Alltrim(aCfp[2][01]),1,1) == "2","1","6"))				
		RTI->RETIF  	:= Iif(Substr(Alltrim(aCfp[2][02]),1,1)== "1","1","0")
		MsUnlock() 

	Endif
			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exclui area de trabalho utilizada - SF3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lQuery
		RetIndex("SF3")	
		dbClearFilter()	
		Ferase(cIndex+OrdBagExt())
	Else
		dbSelectArea(cAliasSF3)
		dbCloseArea()
	Endif
	
Return (aItens)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegA   ³ Autor ³Sueli Santos           ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo A - GIF Ajuste                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegA(dDtInicial,dDtFinal,aItens)
Local i		:= 0

	If Len(aItens)<>0
		For i:=1 to Len(aItens)
			If aItens[i,2]<>"C"  .And. Substr(Alltrim(aCfp[2][01]),1,1) == "1"
				dbSelectArea("RTA")
				If !RTA->(DbSeek(aItens[i,1]))
					RecLock("RTA",.T.)			  
					RTA->CMCCONTR 	:= SM0->M0_INSCM				
					RTA->CNPJCONTR 	:= SM0->M0_CGC
					RTA->MES      	:= Month(dDtInicial)
					RTA->ANO     	:= Year(dDtInicial)
					RTA->TIPOGIF   	:= Iif(Substr(Alltrim(aCfp[2][01]),1,1) == "1","0",Iif(Substr(Alltrim(aCfp[2][01]),1,1) == "2","1","6"))		
					RTA->ESPECIE	:= Replicate("",50)
					RTA->SERIE	    := MesExtenso(dDtInicial)
					RTA->NUMANO	    := Year(dDtInicial)
					RTA->CFPS		:= aItens[i,8]
					RTA->CST		:= aItens[i,9]
					RTA->VLRCOMP	:= aItens[i,4]
					RTA->VLRRET		:= aItens[i,3]
					RTA->DATANF		:= aItens[i,10]
					MsUnlock() 
				Else
					RecLock("RTA",.F.)
					RTA->VLRCOMP	:= aItens[i,4]
					RTA->VLRRET		:= aItens[i,3]
					MsUnLock()		
				Endif
			Endif				
		Next		
	Endif                                                                
	
Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRegJ   ³ Autor ³Luciana Pires          ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro Tipo J - Itens GIF-PJ e GIF-ST             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRegJ(dDtInicial,dDtFinal,aItens)
Local i		:= 0
Local aNumNf	:= {}

	If Len(aItens)<>0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Incluindo dados na Tabela RTJ              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		For i:=1 to Len(aItens)
			If !aItens[i,2]$"C|N"
				dbSelectArea("RTJ")
				If !RTJ->(DbSeek(aItens[i,7]+aItens[i,8]+aItens[i,9]+Alltrim(str(aItens[i,6]))))
					RecLock("RTJ",.T.)			  
					RTJ->CMCCONTR 	:= SM0->M0_INSCM				
					RTJ->CNPJCONTR 	:= SM0->M0_CGC
					RTJ->MES      	:= Month(dDtInicial)
					RTJ->ANO     	:= Year(dDtInicial)
					RTJ->TIPOGIF   	:= Iif(Substr(Alltrim(aCfp[2][01]),1,1) == "1","0",Iif(Substr(Alltrim(aCfp[2][01]),1,1) == "2","1","6"))		
					RTJ->CNAE		:= aItens[i,7]
					RTJ->CFPS		:= aItens[i,8]
					RTJ->CST		:= aItens[i,9]
					RTJ->TOTVLRCONT	:= aItens[i,4]
					RTJ->TOTBASE	:= aItens[i,5]
					RTJ->ALIQISS	:= aItens[i,6]
					RTJ->VALISS		:= aItens[i,3]
					RTJ->NFEMIREC  	:= ControlNF(aItens[i,7]+aItens[i,8]+aItens[i,9]+Alltrim(str(aItens[i,6])), @aNumNf , Alltrim(aItens[i,11]),Alltrim(RTJ->NFEMIREC))
					MsUnlock() 
				Else
					RecLock("RTJ",.F.)
					RTJ->TOTVLRCONT	+= aItens[i,4]
					RTJ->TOTBASE	+= aItens[i,5]
					RTJ->VALISS		+= aItens[i,3]
					RTJ->NFEMIREC  	:= ControlNF(aItens[i,7]+aItens[i,8]+aItens[i,9]+Alltrim(str(aItens[i,6])), @aNumNf , alltrim(aItens[i,11]),Alltrim(RTJ->NFEMIREC))
					MsUnLock()		
				Endif
			Endif				
		Next		
	Endif
Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraTemp   ³ Autor ³Luciana Pires          ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos temporarios                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function GeraTemp()
	Local aStru		:= {}
	Local aTrbs		:= {}
	Local cArq		:= ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo H - Cabecalho																					  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	AADD(aStru,{"VERSAO"	    ,"C",009,0})

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTH")                      	
	IndRegua("RTH",cArq,"VERSAO")
	AADD(aTrbs,{cArq,"RTH"})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo C - Contribuinte          																		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""	
	AADD(aStru,{"CMC"           ,"C",007,0})
	AADD(aStru,{"CNPJ"          ,"C",014,0})
	AADD(aStru,{"RSOCIAL"       ,"C",080,0})
	AADD(aStru,{"NOMEFANT"      ,"C",050,0})
	AADD(aStru,{"INSCREST"      ,"C",020,0})
	AADD(aStru,{"ENDERECO"      ,"C",080,0})
	AADD(aStru,{"NUMERO"        ,"C",010,0})
	AADD(aStru,{"COMPL"         ,"C",030,0})
	AADD(aStru,{"BAIRRO"        ,"C",050,0})
	AADD(aStru,{"CIDADE"        ,"C",050,0})
	AADD(aStru,{"UF"            ,"C",002,0})
	AADD(aStru,{"CEP"           ,"C",008,0})
	AADD(aStru,{"DDD"           ,"C",002,0})
	AADD(aStru,{"FONE"          ,"C",008,0})
	AADD(aStru,{"FAX"           ,"C",008,0})
	AADD(aStru,{"EMAIL"         ,"C",080,0})

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTC")
	IndRegua("RTC",cArq,"CMC")
	AADD(aTrbs,{cArq,"RTC"})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                           
	//³Registro Tipo P - Prestadores, Tomadores de Serviço, e Gráfica que emite Talonário do Contribuinte			  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	AADD(aStru,{"CMC"           ,"C",007,0})
	AADD(aStru,{"CNPJ"          ,"C",014,0})
	AADD(aStru,{"RSOCIAL"       ,"C",080,0})
	AADD(aStru,{"NOMEFANT"      ,"C",050,0})
	AADD(aStru,{"ENDERECO"      ,"C",080,0})
	AADD(aStru,{"NUMERO"        ,"C",010,0})
	AADD(aStru,{"COMPL"         ,"C",030,0})
	AADD(aStru,{"BAIRRO"        ,"C",050,0})
	AADD(aStru,{"CEP"           ,"C",008,0})
	AADD(aStru,{"CIDADE"        ,"C",050,0})
	AADD(aStru,{"UF"            ,"C",002,0})
	AADD(aStru,{"DDD"           ,"C",002,0})
	AADD(aStru,{"FONE"          ,"C",008,0})
	AADD(aStru,{"GRAFICA"       ,"C",001,0})
	
	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTP")
	IndRegua("RTP",cArq,"CNPJ")
	AADD(aTrbs,{cArq,"RTP"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                           
	//³Registro Tipo T - Talonário dos Contribuintes																  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	AADD(aStru,{"CMC"           ,"C",007,0}) 
	AADD(aStru,{"CNPJC"         ,"C",014,0}) 	
	AADD(aStru,{"SERIE"         ,"C",010,0}) 
	AADD(aStru,{"MUNGRAF"       ,"C",001,0})
	AADD(aStru,{"CNPJGRAF"      ,"C",014,0})
	AADD(aStru,{"AIDF"          ,"C",040,0})
	AADD(aStru,{"NUMNFINI"      ,"C",015,0})
	AADD(aStru,{"NUMNFFIM"      ,"C",015,0})

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTT")
	IndRegua("RTT",cArq,"CMC+MUNGRAF+CNPJGRAF+AIDF+NUMNFINI+NUMNFFIM")
	AADD(aTrbs,{cArq,"RTT"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo E - Nota Fiscal Emitida																		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""	
	AADD(aStru,{"CMC"           ,"C",007,0}) 
	AADD(aStru,{"CNPJC"         ,"C",014,0})
	AADD(aStru,{"SERIE"         ,"C",010,0})
	AADD(aStru,{"NUMINITAL"     ,"C",015,0})
	AADD(aStru,{"DATANF"        ,"C",008,0})
	AADD(aStru,{"NUMNF"         ,"C",015,0})
	AADD(aStru,{"CMCTOM"        ,"C",007,0})
	AADD(aStru,{"CNPJTOMA"      ,"C",014,0})
	AADD(aStru,{"CNAE"          ,"C",011,0})
	AADD(aStru,{"TIPO"          ,"C",001,0})
	AADD(aStru,{"VLRCONT"       ,"N",018,2})
	AADD(aStru,{"BASECALC"      ,"N",018,2})
	AADD(aStru,{"OBSERV"        ,"C",050,0})
	AADD(aStru,{"CFPS"          ,"C",004,0})
	AADD(aStru,{"CST"           ,"C",002,0})
	AADD(aStru,{"ALIQ"          ,"N",007,2})
	AADD(aStru,{"VLRISS"        ,"N",018,2})
	
	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTE")
	IndRegua("RTE",cArq,"CMC")
	AADD(aTrbs,{cArq,"RTE"})               
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo F - Nota Fiscal Emitida para Pessoa Fisica														  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""	
	AADD(aStru,{"CMC"           ,"C",007,0})
	AADD(aStru,{"CNPJC"         ,"C",014,0})
	AADD(aStru,{"SERIE"         ,"C",010,0})
	AADD(aStru,{"NUMINITAL"     ,"C",015,0})
	AADD(aStru,{"DATAEMINF"     ,"C",008,0})
	AADD(aStru,{"NUMNFINI"      ,"C",015,0})
	AADD(aStru,{"NUMNFFIM"      ,"C",015,0})
	AADD(aStru,{"CNAE"          ,"C",011,0})
	AADD(aStru,{"TIPO"          ,"C",001,0})
	AADD(aStru,{"VLRCONT"       ,"N",018,2})
	AADD(aStru,{"BASECALC"      ,"N",018,2})
	AADD(aStru,{"OBSERV"        ,"C",050,0})
	AADD(aStru,{"CFPS"          ,"C",004,0})
	AADD(aStru,{"CST"           ,"C",002,0})
	AADD(aStru,{"ALIQ"          ,"N",007,2})
	AADD(aStru,{"VLRISS"        ,"N",018,2})

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTF")
	IndRegua("RTF",cArq,"CMC")
	AADD(aTrbs,{cArq,"RTF"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo R - Nota Fiscal Recebida																	      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""	
	AADD(aStru,{"CMC"           ,"C",007,0})
	AADD(aStru,{"CNPJC" 	    ,"C",014,0})
	AADD(aStru,{"CMCPREST"      ,"C",007,0})
	AADD(aStru,{"CNPJPREST"     ,"C",014,0})
	AADD(aStru,{"NUMNF"         ,"C",015,0})
	AADD(aStru,{"SERIE"         ,"C",010,0})	
	AADD(aStru,{"CNAE"          ,"C",011,0})
	AADD(aStru,{"DATANF"        ,"C",008,0})
	AADD(aStru,{"VLRCONT"       ,"N",018,2})
	AADD(aStru,{"BASECALC"      ,"N",018,2})
	AADD(aStru,{"OBSERV"        ,"C",050,0})
	AADD(aStru,{"CFPS"          ,"C",004,0})
	AADD(aStru,{"CST"           ,"C",003,0})
	AADD(aStru,{"ALIQ"          ,"N",007,2})
	AADD(aStru,{"VLRISS"        ,"N",018,2})

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTR")
	IndRegua("RTR",cArq,"CMC")
	AADD(aTrbs,{cArq,"RTR"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo G - Guia de Informação Fiscal																	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""	
	AADD(aStru,{"ANO"           ,"C",004,0})
	AADD(aStru,{"MES"           ,"N",002,0})
	AADD(aStru,{"CMC"           ,"C",007,0})
	AADD(aStru,{"ALIQ"          ,"N",018,2})
	AADD(aStru,{"VLRCONT"       ,"N",018,2})
	AADD(aStru,{"BASECALC"      ,"N",018,2})
	AADD(aStru,{"IMPRETIDO"     ,"N",018,2})
	AADD(aStru,{"IMPDEVIDO"     ,"N",018,2})
	AADD(aStru,{"SEMMOV"        ,"C",001,0})
	AADD(aStru,{"ISSSUB"        ,"C",001,0})
	AADD(aStru,{"CNPJCONTR"     ,"C",014,0})

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTG")
	IndRegua("RTG",cArq,"CMC")
	AADD(aTrbs,{cArq,"RTG"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo I - GIF-PJ E GIF-ST e GIF Ajuste- Guia de Informação Fiscal												  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""	
	AADD(aStru,{"CMCCONTR"		,"C",007,0})                
	AADD(aStru,{"CNPJCONTR"     ,"C",014,0})
	AADD(aStru,{"MES"           ,"N",002,0})
	AADD(aStru,{"ANO"           ,"N",004,0})
	AADD(aStru,{"NFCANCEL"      ,"C",255,0})
	AADD(aStru,{"SEMMOV"        ,"C",001,0})
	AADD(aStru,{"TIPOGIF"       ,"C",001,0})
	AADD(aStru,{"RETIF"    		,"C",001,0})

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTI")
	IndRegua("RTI",cArq,"CNPJCONTR")
	AADD(aTrbs,{cArq,"RTI"})
      
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo A - Ajuste de GIF												  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""	
	AADD(aStru,{"CMCCONTR"		,"C",007,0})                
	AADD(aStru,{"CNPJCONTR"     ,"C",014,0})
	AADD(aStru,{"MES"           ,"N",002,0})
	AADD(aStru,{"ANO"           ,"N",004,0})
	AADD(aStru,{"TIPOGIF"       ,"C",001,0})	
	AADD(aStru,{"ESPECIE"       ,"C",050,0})
	AADD(aStru,{"SERIE"         ,"C",050,0})
	AADD(aStru,{"NUMANO"        ,"N",015,0})
	AADD(aStru,{"CFPS"    		,"C",004,0})
	AADD(aStru,{"CST"    		,"C",003,0})
	AADD(aStru,{"VLRCOMP" 		,"N",018,2})	
	AADD(aStru,{"VLRRET"  		,"N",018,2})
	AADD(aStru,{"DATANF"        ,"C",008,0})
	
	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTA")
	IndRegua("RTA",cArq,"CNPJCONTR")
	AADD(aTrbs,{cArq,"RTA"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo J - GIF-PJ E GIF-ST - Itens da Guia de Informação Fiscal										  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""	                         
	AADD(aStru,{"CMCCONTR"      ,"C",014,0})
	AADD(aStru,{"CNPJCONTR"     ,"C",014,0})
	AADD(aStru,{"MES"           ,"N",002,0})
	AADD(aStru,{"ANO"           ,"N",004,0})
	AADD(aStru,{"TIPOGIF"       ,"C",001,0})
	AADD(aStru,{"CNAE"          ,"C",011,0})
	AADD(aStru,{"CFPS"          ,"C",004,0})
	AADD(aStru,{"CST"           ,"C",003,0})
	AADD(aStru,{"TOTVLRCONT"    ,"N",018,2})
	AADD(aStru,{"TOTBASE"       ,"N",018,2})
	AADD(aStru,{"ALIQISS"       ,"N",006,2})
	AADD(aStru,{"VALISS"        ,"N",018,2})
	AADD(aStru,{"NFEMIREC"      ,"C",4000,0})

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RTJ")
	IndRegua("RTJ",cArq,"CNAE+CFPS+CST+Alltrim(str(ALIQISS))")
	AADD(aTrbs,{cArq,"RTJ"})

Return (aTrbs)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CFP        ³ Autor ³Luciana Pires		     ³ Data ³ 20.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina CFP                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CFP()
	Local aTxtPre 		:= {}
	Local aPaineis 		:= {}
	
	Local cTitObj1		:= ""
	Local cTitObj2		:= ""       

	Local nPos			:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta wizard com as perguntas necessarias³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aTxtPre,STR0001)			//"Assistente de parametrização do SEFINNET"
	AADD(aTxtPre,STR0002)			//"Atenção"
	AADD(aTxtPre,STR0003)			//"Preencha as informações solicitadas para a geração do arquivo magnÉtico: "
	AADD(aTxtPre,STR0004)	   		//"SEFINNET - Sistema eletrônico de Declaração de ISS do Município           de Florianópolis - Santa Catarina - SC"
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 1 - Informações da Declaração     											  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0005)	//"Assistente de parametrização"
	aAdd(aPaineis[nPos],STR0006)	//"Informações sobre a Declaração: "
	aAdd(aPaineis[nPos],{})
	
	cTitObj1 :=	STR0007				//"Tipo da Declaração?" 				//Cfp[1][01]
	cTitObj2 :=	STR0008				//"Versão SefinNet?"       				//Cfp[1][02]
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{3,,,,,{STR0009,STR0010,STR0011,STR0012},,})  	//"1-DES-Serviços Prestados","2-DES-Serviços Tomados","3-GIF-PJ e GIF-ST","4-GIF-PJ SS e GIF-PF"
	aAdd(aPaineis[nPos][3],{2,,"!!!!!!!!!",1,,,,9})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	
  	cTitObj1 :=	STR0016				//"Despesa com Funcionários?" 			//Cfp[2][01]
	cTitObj2 :=""
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,}) 
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,Replicate("X",80),1,,,,80}) 
  //	aAdd(aPaineis[nPos][3],{2,"",,,,,,}) 
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})		
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 2 - Registro I - GIF-PJ e GIF-ST - Guia de Informações Fiscais				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0005)	//"Assistente de parametrização"
	aAdd(aPaineis[nPos],STR0013)	//"Informações sobre o Registro I - GIF-PJ e GIF-ST - Guia de Informações Fiscais"
	aAdd(aPaineis[nPos],{})
	
                                                              
	cTitObj1 :=	STR0017				//"Tipo de indicador da GIF?"			//Cfp[2][03]
	cTitObj2 :=	STR0021				//"Gia Retificadora?		       	//Cfp[2][02]
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{3,,,,,{STR0018,STR0019,STR0020},,})  	//"1-GIF-PJ (Relação de NF Emitidas)","2-GIF-ST (Relação de NF Recebidas)"
	aAdd(aPaineis[nPos][3],{3,,,,,{STR0022,STR0023},,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})

Return(xMagWizard(aTxtPre,aPaineis,"SEFINSC")) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SEFINDel    ºAutor  ³Luciana Pires       º Data ³ 20.12.2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta os arquivos temporarios processados                    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SEFIN SC                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/         
Function SEFINDel(aDelArqs)
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

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} ControlNF()
@description Função que irá realizar o controle dos números de notas do campo RTJ->NFEMIREC
No layout diz que números adjacentes deverão ser informados com hífen, e números não adjacentes 
separados por vírgula. Por exemplo :

Notas fiscais 1,2,3,4,6 e 8 podem ser informadas como 1-4,6,8

@author Erick G. Dias
@since 26/06/2017
@version 11.90
/*/
//---------------------------------------------------------------------------------------------
Static Function ControlNF(cChave, aNumNf, cNumNf, cCmpTAb)

Local nPos	:= 0
Local cRet	:= ''

nPos := aScan(aNumNf, {|aX| aX[1] == cChave})

IF nPos == 0
	//----------------------------------
	//Inclui a primeira nota para a chave
	//----------------------------------
	aAdd(aNumNf, {})
	nPos :=	Len(aNumNf)
	aAdd(aNumNf[nPos],cChave) //Chave
	aAdd(aNumNf[nPos],cNumNf) //Número da NF
	aAdd(aNumNf[nPos],.F.)	  //Indica se já incluiu algum número adjacente
	
	//Retorna o próprio número de Nota
	cRet	:= cNumNf 

Else
	IF Val(aNumNf[nPos][2]) + 1 == Val(cNumNf)
		//-------------------------
		//Número de Nota Adjacente 
		//-------------------------
		If aNumNf[nPos][3]
			//Atualiza o último número adjacente
			cRet	:= StrTran(cCmpTAb,aNumNf[nPos][2],cNumNf)
		Else
			//Incluí novo número adjacente
			cRet	:= cCmpTAb + '-' + alltrim(cNumNf)
		EndIF
		
		//Já incluiu número adjacente		
		aNumNf[nPos][3]	:= .T.
		
	Else
		//----------------------------
		//Número de nota não adjacente
		//----------------------------
				
		//Inclui novo número não adjacente
		cRet	:=cCmpTAb +  ',' + cNumNf
		
		//Indica que incluiu um número não adjacente
		aNumNf[nPos][3]	:= .F.
	EndIF
	//Atualiza com última nota processada
	aNumNf[nPos][2]:= cNumNf
	
EndIF

Return cRet
