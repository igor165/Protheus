#Include "Protheus.Ch"
#Include "Davinci.Ch"

Static oTmpTabLCV

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³DaVinci   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 25.07.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³Preparacao do meio-magnetico para o software DaVinci-LCV,   ³±±
±±³           ³geracao dos Livros de Compra e Vendas IVA.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Marco A.  ³10/01/17³SERINN001 ³Se aplica CTREE para evitar la creacion³±±
±±³            ³        ³-531      ³de tablas temporales de manera fisica  ³±±
±±³            ³        ³          ³en system.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DaVinci(cLivro, cFilIni, cFilFim)

	Local aArea	:= GetArea()
	Local aTpNf	:= &(GetNewPar("MV_DAVINC1","{}"))

	Local cCpoPza		:= GetNewPar("MV_DAVINC2", "")	//Campo da tabela SF1: que contem o Numero de Poliza de Importacion
	Local cCpoDta		:= GetNewPar("MV_DAVINC3", "")	//Campo da tabela SF1: que contem a Data de Poliza de Importacion
	Local lOrdem		:= GetNewPar("MV_DAVINC4", .T.)	//Indica se arquivo sera ordenado por Emissao ou Entrada sendo F=Emissao e T=Entrada
	Local lPeriodoOK	:= (FunName() <> "MATA950")
	Local lProc			:= .T.
	
	Default cFilIni	 := xFilial("SF3")
	Default cFilFim	 := xFilial("SF3")

	GeraTemp(cLivro)

	If lPeriodoOK .or. BOL3Periodo()

		If cPaisLoc == "BOL" .And. LocBol() 

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica a existencia dos parametros/campos                    ³
			//³Caso esses itens nao existam, nao sera efetuado o processamento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aTpNf) == 0 
				lProc := .F.
				Help(" ",1,"MV_DAVINC1")
			EndIf
			If Empty(cCpoPza) 
				lProc := .F.   
				Help(" ",1,"MV_DAVINC2")
			EndIf
			If Empty(cCpoDta)
				lProc := .F.
				Help(" ",1,"MV_DAVINC3")
			EndIf

			If lProc
				ProcLivro(cLivro,cFilIni,cFilFim)
			EndIf
		EndIf

	EndIf

	RestArea(aArea)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraTemp   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 25.07.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos temporarios                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GeraTemp(cLivro)

	Local aStru		:= {}
	Local cArq		:= ""
	Local aOrdem	:= {}
	
	Default cLivro := "V"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Temporario LCV - Livro de Compras e Vendas IVA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aStru, {"NUMSEQ"	, "C", 006, 0})
	aAdd(aStru, {"TIPONF"	, "C", 001, 0})
	aAdd(aStru, {"NIT"		, "C", 013, 0})
	aAdd(aStru, {"RAZSOC"	, "C", 150, 0})
	aAdd(aStru, {"NFISCAL"	, "C", 015, 0})
	aAdd(aStru, {"POLIZA"	, "C", 016, 0})
	aAdd(aStru, {"NUMAUT"	, "C", 015, 0})
	aAdd(aStru, {"EMISSAO"	, "D", 008, 0})
	aAdd(aStru, {"VALCONT"	, "N", 010, 2})
	aAdd(aStru, {"EXPORT"	, "N", 014, 2})
	aAdd(aStru, {"EXENTAS"	, "N", 010, 2})
	aAdd(aStru, {"TAXAZERO"	, "N", 010, 2})
	aAdd(aStru, {"SUBTOT"	, "N", 010, 2})
	aAdd(aStru, {"DESCONT"	, "N", 010, 2})
	aAdd(aStru, {"BASEIMP"	, "N", 010, 2})
	aAdd(aStru, {"VALIMP"	, "N", 010, 2})
	aAdd(aStru, {"STATUSNF"	, "C", 001, 0})
	aAdd(aStru, {"CODCTR"	, "C", 017, 0})
	aAdd(aStru, {"DATAORD"	, "C", 008, 0})
	aAdd(aStru, {"DTNFORI"	, "D", 008, 0}) 
	aAdd(aStru, {"NFORI"	, "C", 015, 0})
	aAdd(aStru, {"AUTNFORI"	, "C", 015, 0})
	aAdd(aStru, {"VALNFORI"	, "N", 010, 2})
	
	aOrdem := {"DATAORD"}
	
	oTmpTabLCV := FWTemporaryTable():New("LCV")
	oTmpTabLCV:SetFields(aStru)
	oTmpTabLCV:AddIndex("IN1", aOrdem)
	oTmpTabLCV:Create()

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcLivro  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 25.07.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa o Livro de Compras e Vendas IVA                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ProcLivro(cLivro,cFilIni,cFilFim)

	Local aImp		:= {}
	Local aAlias	:= {"SF3", ""}
	Local cTop		:= ""
	Local cDbf		:= ""
	Local cNIT		:= ""
	Local cRazSoc	:= ""
	Local cArray	:= GetNewPar("MV_DAVINC1", "{}")		//Tipo de Factura: 1-Compras para Mercado Interno;2-Compras para Exportacoes;3-Compras tanto para o Mercado Intero como para Exportacoes
	Local aTpNf		:= &cArray
	Local cTpNf		:= "1"								//1-Compras para Mercado Interno;2-Compras para Exportacoes;3-Compras tanto para o Mercado Intero como para Exportacoes
	Local nPos		:= 0
	Local nPosIVA	:= 0
	Local cCpoPza	:= GetNewPar("MV_DAVINC2", "")		//Campo da tabela SF1: que contem o Numero de Poliza de Importacion
	Local cCpoDta	:= GetNewPar("MV_DAVINC3", "")		//Campo da tabela SF1: que contem a Data de Poliza de Importacion
	Local lOrdem	:= GetNewPar("MV_DAVINC4", .T.)     //Indica se arquivo sera ordenado por Emissao ou Entrada sendo F=Emissao e T=Entrada
	Local cChave	:= ""
	Local cArqInd	:= ""
	Local nNumSeq	:= 0
	Local nDescont	:= 0
	Local lCalcLiq	:= .F.
	Local dDtNFOri	:= CTOD("")
	Local cNFOri	:= ""
	Local cAutNFOri	:= ""
	Local nValNFOri	:= 0
	Local lProcLiv	:= .T.
	Local aCposIsen	:= {}
	Local nInd		:= 0                                  
	Local lPassag 	:= 	cPaisLoc == "BOL" .And. GetNewPar("MV_PASSBOL",.F.) .And.;
					SF3->(ColumnPos("F3_COMPANH")) > 0 .And. ;
					SF3->(ColumnPos("F3_LOJCOMP")) > 0 .And. ;
					SF3->(ColumnPos("F3_PASSAGE")) > 0 .And. ;
					SF3->(ColumnPos("F3_DTPASSA")) > 0 .And. ;
					SF1->(ColumnPos("F1_COMPANH")) > 0 .And. ;
					SF1->(ColumnPos("F1_LOJCOMP")) > 0 .And. ;
					SF1->(ColumnPos("F1_PASSAGE")) > 0 .And. ;
					SF1->(ColumnPos("F1_DTPASSA")) > 0  
	Local cStatus:=""
	Default cFilIni	 := xFilial("SF3")
	Default cFilFim	 := xFilial("SF3")

	If cLivro == "C"	//Compras

		cTop := "F3_FILIAL >= '" + cFilIni + "' AND F3_FILIAL <= '" + cFilFim + "' AND SUBSTRING(F3_CFO,1,1) < '5' AND F3_EMISSAO >= '" + DTOS(mv_par01) + "' AND F3_EMISSAO <= '" + DTOS(mv_par02) + "' AND F3_ESPECIE = 'NF'"
		cDbf := "F3_FILIAL >= '" + cFilIni + "' .And. F3_FILIAL <= '" + cFilFim + "' .And.  SUBSTRING(F3_CFO,1,1) < '5' .And. DTOS(F3_EMISSAO) >= '" + DTOS(mv_par01) + "' .And. DTOS(F3_EMISSAO) <= '" + DTOS(mv_par02) + "' .And. ALLTRIM(F3_ESPECIE) == 'NF'"

		cTop += " AND F3_RECIBO <> '1'"
		cDbf += " .And. F3_RECIBO <> '1'"

		SF1->(dbSetOrder(1))
		If !lOrdem
			cArqInd := CriaTrab(Nil,.F.)
			LCV->(DBSetOrder(1))
		EndIf

	ElseIf cLivro == "V"	//Vendas
		cTop := "F3_FILIAL >= '" + cFilIni + "' AND F3_FILIAL <= '" + cFilFim + "' AND SUBSTRING(F3_CFO,1,1) >= '5' AND F3_EMISSAO >= '" + DTOS(mv_par01) + "' AND F3_EMISSAO <= '" + DTOS(mv_par02)+ "' AND F3_ESPECIE = 'NF'"
		cDbf := "F3_FILIAL >= '" + cFilIni + "' .And. F3_FILIAL <= '" + cFilFim + "' .And.   SUBSTRING(F3_CFO,1,1) >= '5' .And. DTOS(F3_EMISSAO) >= '" + DTOS(mv_par01) + "' .And. DTOS(F3_EMISSAO) <= '" + DTOS(mv_par02) + "' .And. ALLTRIM(F3_ESPECIE) == 'NF'"
	Else // Notas de Credito/Debito Compras
		cTop := "F3_FILIAL >= '" + cFilIni + "' AND F3_FILIAL <= '" + cFilFim + "' AND F3_EMISSAO >= '" + DTOS(mv_par01) + "' AND F3_EMISSAO <= '" + DTOS(mv_par02) + "' AND "
		cTop += "F3_ESPECIE <> 'NF' AND " 

		If cLivro == "CDC"
			cTop += "F3_TIPOMOV = 'V' 
		Else
			cTop += "F3_TIPOMOV = 'C' 
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta aImp com as informacoes dos impostos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SFB")
	dbSetOrder(1)
	dbGoTop()

	aAdd(aImp,{"IVA",""})
	While !SFB->(Eof())
		If Subs(SFB->FB_CODIGO,1,2) <> "IT" 
			nPos := aScan(aImp,{|x| SFB->FB_CODIGO $ x[1]})
			If nPos > 0
				aImp[nPos,2] := SFB->FB_CPOLVRO
			Else        
				If cLivro$"C|V"
					If Empty(aScan(aCposIsen,{|x| SFB->FB_CPOLVRO $ x[1]})) .AND. (SFB->FB_CPOLVRO # aImp[1,2])
						aAdd(aCposIsen,{SFB->FB_CPOLVRO,SF3->(FieldPos("F3_VALIMP"+SFB->FB_CPOLVRO))}) 
					EndIf               
				EndIf
			EndIf
		EndIf	
		dbSkip()
	EndDo
	
	aSort(aImp,,,{|x,y| x[2] < y[2]})

	nPosIVA := Ascan(aImp,{|imp| imp[1] == "IVA"})

	aAdd(aImp[nPosIVA],SF3->(FieldPos("F3_BASIMP"+aImp[nPosIVA][2])))		//Base de Calculo
	aAdd(aImp[nPosIVA],SF3->(FieldPos("F3_VALIMP"+aImp[nPosIVA][2])))		//Valor do Imposto

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria Query / Filtro                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SF3->(dbSetOrder(1))
	FsQuery(aAlias,1,cTop,cDbf,SF3->(IndexKey()))

	dbSelectArea("SF3")
	While !Eof()
		cStatus:=IIf(!Empty(SF3->F3_DTCANC),IIf(SF3->F3_STATUS$"EN",SF3->F3_STATUS,"A"),"V")	//NF Valida / Anulada / Extraviada ou Não utilizada
		If (cLivro $ "V|C")   // Livro de Venda e ou Compra 
			lProcLiv := .T.
		ElseIf !Empty(SF3->F3_DTCANC)  // Livro de Vendas/Compras Deb/Cred Canceladas
			lProcLiv := IIf(cLivro == "VDC",.F.,.T.)
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pesquisa documento de origem somente para os livros de "Vendas Deb/Cre" e "Compras Deb/Cred" ³
			//³e que nao estiverem cancelados.                                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( cChave <> SF3->F3_FILIAL + SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA ) .AND. Empty(SF3->F3_DTCANC)   // Compras Debito/Credito
				lProcLiv := PesqDocOri(@dDtNFOri,@cNFOri,@cAutNFOri,@nValNFOri,cFilIni,cLivro=="CDC")
			EndIf
		EndIf

		If lProcLiv

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Como podem existir mais de um SF3 para um mesmo documento, deve ser aglutinado³
			//³gerando apenas uma linha no arquivo magnetico.                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cChave) .Or. cChave <> SF3->F3_FILIAL + SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA

				lCalcLiq := ( Posicione("SFC",2,xFilial("SFC")+SF3->F3_TES+"IVA","FC_LIQUIDO") == "S" ) 

				If SF3->F3_TIPOMOV == "C"	//Compras(C) 
					If !Empty(cFilIni) .AND. !Empty(xFilial("SF1"))
						SF1->(dbSeek(SF3->F3_FILIAL+SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA))
					Else
						SF1->(dbSeek(xFilial("SF1")+SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA))
					EndIf
				ElseIf SF3->F3_TIPOMOV == "V"   //Vendas 
					If !Empty(cFilIni) .AND. !Empty(xFilial("SF2"))
						SF2->(dbSeek(SF3->F3_FILIAL+SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA))
					Else
						SF2->(dbSeek(xFilial("SF2")+SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA))
					EndIf
				EndIf
				cNumDoc:= SF3->F3_NFISCAL
				dDemissao:= SF3->F3_EMISSAO
				If cStatus =="V"
					If !Empty(SF3->F3_NIT)
						cNIT := SF3->F3_NIT
						Else
						If SF3->F3_TIPOMOV == "C"  //Compras(C)      
							cNIT := Posicione("SA2",1,xFilial("SA2")+SF3->(F3_CLIEFOR+F3_LOJA),"A2_CGC")	
							Else
							cNIT := Posicione("SA1",1,xFilial("SA1")+SF3->(F3_CLIEFOR+F3_LOJA),"A1_CGC")
						EndIf
					EndIf
				Else
					cNIT :="0"
				EndIf
				If cStatus =="V"
					If !Empty(SF3->F3_RAZSOC)
						cRazSoc	:= SF3->F3_RAZSOC
						Else
						If SF3->F3_TIPOMOV == "C"  //Compras(C)  
							cRazSoc	:= Posicione("SA2",1,xFilial("SA2")+SF3->(F3_CLIEFOR+F3_LOJA),"A2_NOME")
						Else
							cRazSoc	:= Posicione("SA1",1,xFilial("SA1")+SF3->(F3_CLIEFOR+F3_LOJA),"A1_NOME")
						EndIf
					EndIf
				Else
					cRazSoc	:=  STR0003
				EndIf
				
				If cStatus =="V"
					If SF3->F3_TIPOMOV == "C" .And.  lPassag .And. !Empty(SF3->F3_COMPANH) .And. !Empty(SF3->F3_LOJCOMP)  
						cNIT		:= Posicione("SA2",1,xFilial("SA2")+SF3->(F3_COMPANH+F3_LOJCOMP),"A2_CGC")
						cRazSoc		:= Posicione("SA2",1,xFilial("SA2")+SF3->(F3_COMPANH+F3_LOJCOMP),"A2_NOME")
						cNumDoc		:= SF3->F3_PASSAGE
						dDemissao	:= SF3->F3_DTPASSA
					EndIf
				EndIf	
				

				//Ú Tipo de Factura ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³1-Compras para Mercado Interno com destino a atividades gravadas     ³
				//³2-Compras para Mercado Interno com destino a atividades nao gravadas ³
				//³3-Compras sujeitas a proporcionalidade                               ³
				//³4-Compras para Exportacoes                                           ³
				//³3-Compras tanto para o Mercado Interno como para Exportacoes         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (nPos := aScan(aTpNf,{|x| Alltrim(SF3->F3_SERIE) $ x[1]})) > 0
					cTpNf := aTpNf[nPos][2]
				Else
					cTpNf := "1"
				EndIf

				RecLock("LCV",.T.)

				LCV->TIPONF		:= cTpNf
				LCV->NUMSEQ		:= StrZero(++nNumSeq,6)
				LCV->NIT		:= cNIT
				LCV->RAZSOC		:= cRazSoc
				LCV->NFISCAL	:= cNumDoc
				LCV->EMISSAO	:= dDemissao

				If cLivro == "C"

					nDescont := xMoeda(SF1->F1_DESCONT,SF1->F1_MOEDA,1,SF1->F1_EMISSAO,,SF1->F1_TXMOEDA )

					If !lOrdem
						LCV->DATAORD := Dtos(SF3->F3_EMISSAO)
					EndIf
					If !Empty(SF1->&(cCpoPza))		//Numero da Poliza de Importacion
						LCV->POLIZA		:= SF1->&(cCpoPza)
						LCV->NFISCAL	:= "0"
					EndIf
					If !Empty(SF1->&(cCpoDta))		//Data da Poliza de Importacion
						LCV->EMISSAO	:= SF1->&(cCpoDta)
					EndIf
					
				ElseIf cLivro == "V"
					nDescont := 0
					nDescont := xMoeda(SF2->F2_DESCONT,SF2->F2_MOEDA,1,SF2->F2_EMISSAO,,SF2->F2_TXMOEDA )
				EndIf

				LCV->NUMAUT		:= SF3->F3_NUMAUT
				LCV->STATUSNF	:= IIf(!Empty(SF3->F3_DTCANC),IIf(SF3->F3_STATUS$"EN",SF3->F3_STATUS,"A"),"V")	//NF Valida / Anulada / Extraviada ou Não utilizada
				LCV->CODCTR		:= SF3->F3_CODCTR

				If LCV->STATUSNF == "V"
					LCV->DTNFORI  := dDtNFOri
					LCV->NFORI    := cNFOri
					LCV->AUTNFORI := cAutNFOri
					LCV->VALNFORI := nValNFOri
				EndIf

			Else
				RecLock("LCV",.F.)
			EndIf

			If cStatus =="V"
				LCV->VALCONT += SF3->F3_VALCONT
			Else
				LCV->VALCONT:=0
			EndIf
			If SF3->(FieldGet(aImp[nPosIVA][4])) > 0        
				If cStatus =="V"
					LCV->BASEIMP += SF3->(FieldGet(aImp[nPosIVA][3]))		//Base de Calculo
					LCV->VALIMP  += SF3->(FieldGet(aImp[nPosIVA][4]))		//Valor do Imposto
				Else
					LCV->BASEIMP := 0		//Base de Calculo
					LCV->VALIMP  :=0	//Valor do Imposto
				EndIf	
			ElseIf cLivro == "V"
				LCV->TAXAZERO += SF3->(FieldGet(aImp[nPosIVA][3]))   //IVA com taxa zero
			EndIf            

			If cLivro $ "C|V"

				For nInd:=1 To Len(aCposIsen)
					If cStatus =="V"
						LCV->EXENTAS += IIf(aCposIsen[nInd][2]>0,SF3->(FieldGet(aCposIsen[nInd][2])),0)
					Else
						LCV->EXENTAS :=0
					EndIf	
				Next            

				If cLivro == "V" .And. Empty(SF3->(FieldGet(aImp[nPosIVA][3])))
					If cStatus =="V"
						LCV->EXPORT += SF3->F3_EXENTAS
					Else
						LCV->EXPORT :=0
					EndIf
				EndIf

				If cLivro == "C" .And. (SF3->F3_EXENTAS > 0)
					If cStatus =="V"
						LCV->EXENTAS += SF3->F3_EXENTAS
					Else
						LCV->EXENTAS :=0
					EndIf
				EndIf
			EndIf
			cChave := SF3->F3_FILIAL + SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA
		EndIf

		dbSelectArea("SF3")
		dbSkip()

		If lProcLiv
			If cLivro$"C|V" .AND. cChave <> SF3->F3_FILIAL + SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA 
				
				If cStatus =="V"
				
					LCV->DESCONT := IIf(lCalcLiq,nDescont,0)

					If cLivro == "C"
						LCV->SUBTOT := IIf(!Empty(LCV->BASEIMP),(LCV->VALCONT-LCV->EXENTAS),(LCV->BASEIMP+LCV->DESCONT))
					Else
						LCV->SUBTOT := LCV->VALCONT-LCV->EXENTAS-LCV->EXPORT-LCV->TAXAZERO + LCV->DESCONT
					EndIf                        
				
					If cStatus =="V"
						LCV->VALCONT := LCV->VALCONT + LCV->DESCONT
					EndIf
				
				Else
					LCV->DESCONT := 0
					LCV->SUBTOT := 0                        
				EndIf
			EndIf
			LCV->(MsUnlock())
		EndIf
	EndDo

	FsQuery(aAlias,2)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³PesqDocOri   ³ Autor ³ Marco Aurelio - Mano    ³ Data ³15/12/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Pesquisa a esxistencia de documento original para Notas de       ³±±
±±³          ³Debito/Credito                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PesqDocOri(ExpD1,ExpC1,ExpC2,ExpC3)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD1 = Data de emissao do documento original                    ³±±
±±³          ³ExpC1 = Numero do documento original                             ³±±
±±³          ³ExpC2 = Numero de autorizacao do documento original              ³±±
±±³          ³ExpC3 = Valor da do documento original                           ³±±
±±³          ³ExpC4 = Codigo da filial inical selecionada nos parametros       ³±±
±±³          ³ExpL4 = Determina a tabela a ser considerada de acordo com       ³±±
±±³          ³        o Livro a ser impresso ou gerado                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Livros - Bolivia                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Static Function PesqDocOri(dDtNFOri, cNFOri, cAutNFOri, nValNFOri, cFilIni, lTabSF2)
	
	Local cQuery	:= ""    // Auxiliar para execucao de query para insercao de registros
	Local lRet		:= .F.   // Conteudo de retorno
	Local cArqTmp	:= GetNextAlias()
	Local cFilSD1	:= ""
	Local cFilSF2	:= ""

	cFilSF1 := IIf(!Empty(cFilIni) .AND. !Empty(xFilial("SF1")),SF3->F3_FILIAL,xFilial("SF2"))
	cFilSF2 := IIf(!Empty(cFilIni) .AND. !Empty(xFilial("SF2")),SF3->F3_FILIAL,xFilial("SF2"))
	cFilSD1 := IIf(!Empty(cFilIni) .AND. !Empty(xFilial("SD1")),SF3->F3_FILIAL,xFilial("SD1"))
	cFilSD2 := IIf(!Empty(cFilIni) .AND. !Empty(xFilial("SD2")),SF3->F3_FILIAL,xFilial("SD1"))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Colunas a serem exibidas como resultado da query ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTabSF2
		cQuery := "SELECT F2_DOC, F2_EMISSAO, F2_NUMAUT, F2_VALFAT, F2_MOEDA, F2_TXMOEDA FROM "
	Else
		cQuery := "SELECT F1_DOC, F1_EMISSAO, F1_NUMAUT, F1_VALBRUT, F1_MOEDA, F1_TXMOEDA FROM "
	EndIf    

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tabela do filtro ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If AllTrim(SF3->F3_ESPECIE) $ "NCC|NDE|NDP|NCI" 
		cQuery += RetSqlName("SD1") + " SD1 " // Tabela de Itens de Compra

		If lTabSF2
			cQuery += "INNER JOIN " + RetSqlName("SF2") + " SF2 ON D1_FILIAL = '" + cFilSF2 + "' AND F2_CLIENTE = D1_FORNECE AND F2_LOJA = D1_LOJA AND F2_DOC = D1_NFORI AND F2_SERIE = D1_SERIORI AND SF2.D_E_L_E_T_ <> '*'"
		Else
			cQuery += "INNER JOIN " + RetSqlName("SF1") + " SF1 ON D1_FILIAL = '" + cFilSF1 + "' AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND F1_DOC = D1_NFORI AND F1_SERIE = D1_SERIORI AND SF1.D_E_L_E_T_ <> '*'"
		EndIf

	Else
		cQuery += RetSqlName("SD2") + " SD2 " // Tabela de Itens de Saida

		If lTabSF2
			cQuery += "INNER JOIN " + RetSqlName("SF2") + " SF2 ON D2_FILIAL = '" + cFilSF2 + "' AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA AND F2_DOC = D2_NFORI AND F2_SERIE = D2_SERIORI AND SF2.D_E_L_E_T_ <> '*'"
		Else
			cQuery += "INNER JOIN " + RetSqlName("SF1") + " SF1 ON D2_FILIAL = '" + cFilSF1 + "' AND F1_FORNECE = D2_CLIENTE AND F1_LOJA = D2_LOJA AND F1_DOC = D2_NFORI AND F1_SERIE = D2_SERIORI AND SF1.D_E_L_E_T_ <> '*'"
		EndIf

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Condicoes para filtro ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If AllTrim(SF3->F3_ESPECIE) $ "NCC|NDE|NDP|NCI" 
		cQuery += "WHERE "
		cQuery += "D1_FILIAL = '" + cFilSD1 + "' AND "
		cQuery += "D1_FORNECE = '" + SF3->F3_CLIEFOR + "' AND "
		cQuery += "D1_LOJA = '" + SF3->F3_LOJA + "' AND "
		cQuery += "D1_DOC = '" + SF3->F3_NFISCAL + "' AND "
		cQuery += "D1_SERIE = '" + SF3->F3_SERIE + "' AND "
		cQuery += "D1_NFORI <> ' ' AND "
		cQuery += "SD1.D_E_L_E_T_ = ' ' "
	Else
		cQuery += "WHERE "
		cQuery += "D2_FILIAL = '" + cFilSD2 + "' AND "
		cQuery += "D2_CLIENTE = '" + SF3->F3_CLIEFOR + "' AND "
		cQuery += "D2_LOJA = '" + SF3->F3_LOJA + "' AND "
		cQuery += "D2_DOC = '" + SF3->F3_NFISCAL + "' AND "
		cQuery += "D2_SERIE = '" + SF3->F3_SERIE + "' AND "
		cQuery += "D2_NFORI <> ' ' AND "
		cQuery += "SD2.D_E_L_E_T_ = ' ' "
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqTmp,.T.,.T.)

	If lTabSF2
		TcSetField(cArqTmp, "F2_EMISSAO", "D", 8, 0)
		TCSetField(cArqTmp, "F2_VALFAT"	, "N", TamSX3("F2_VALFAT")[1], TamSX3("F2_VALFAT")[2])
	Else
		TcSetField(cArqTmp, "F1_EMISSAO", "D", 8, 0)
		TCSetField(cArqTmp, "F1_VALBRUT", "N", TamSX3("F1_VALBRUT")[1], TamSX3("F1_VALBRUT")[2])
	EndIf    

	(cArqTmp)->(dbGoTop())

	If !(cArqTmp)->(EOF())

		lRet := .T.

		If lTabSF2
			dDtNFOri  := (cArqTmp)->F2_EMISSAO
			cNFOri    := (cArqTmp)->F2_DOC
			cAutNFOri := (cArqTmp)->F2_NUMAUT
			nValNFOri := Round(NoRound(xMoeda((cArqTmp)->F2_VALFAT,(cArqTmp)->F2_MOEDA,1,(cArqTmp)->F2_EMISSAO,,(cArqTmp)->F2_TXMOEDA )),2)
		Else
			dDtNFOri  := (cArqTmp)->F1_EMISSAO
			cNFOri    := (cArqTmp)->F1_DOC
			cAutNFOri := (cArqTmp)->F1_NUMAUT
			nValNFOri := Round(NoRound(xMoeda((cArqTmp)->F1_VALBRUT,(cArqTmp)->F1_MOEDA,1,(cArqTmp)->F1_EMISSAO,,(cArqTmp)->F1_TXMOEDA )),2)
		EndIf
	EndIf

	(cArqTmp)->(dbCloseArea())

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DavinciDel ³ Autor ³Marco A. Gonzalez R.   ³Fecha ³ 10/01/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cierra y elimina archivo temporal LCV                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DavinciDel()

	If oTmpTabLCV <> Nil
		oTmpTabLCV:Delete()
		oTmpTabLCV := Nil
	EndIf

Return
