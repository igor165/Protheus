#Include "Protheus.Ch"
#Include "Davinci.Ch"

Static oTmpTabLCV

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³Libro Digital   ³ Autor ³                 ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³Preparacao do meio-magnetico para a importacion no SIAT|    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³          ³                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LIBBOL(cLivro, cFilIni, cFilFim,cTipDoc,cTipoExc)

	Local aArea			:= GetArea()
	Local aTpNf			:= &(GetNewPar("MV_DAVINC1","{}"))
	Local cCpoPza		:= GetNewPar("MV_DAVINC2", "")	//Campo da tabela SF1: que contem o Numero de Poliza de Importacion
	Local cCpoDta		:= GetNewPar("MV_DAVINC3", "")	//Campo da tabela SF1: que contem a Data de Poliza de Importacion
	Local lPeriodoOK	:= (FunName() <> "MATA950")
	Local lProc			:= .T.
	Local cFiltro		:= "3" //1=Manual , 2=Online,3=Ambas
	
	Default cFilIni	 	:= xFilial("SF3")
	Default cFilFim	 	:= xFilial("SF3")
	Default cTipDoc		:= "3" 
	Default cTipoExc	:= "1"   // Tipo Excell ( 1=XML /2 =XLXS) 
	
	cTipDoc		:= Subs(cTipDoc,1,1) 
	cTipoExc	:= Subs(cTipoExc,1,1)   
	
	If SF2->(ColumnPos("F2_CODDOC")) >0 .and. SF1->(ColumnPos("F1_CODDOC"))>0 
		If cTipDoc=="2"
			cFiltro:= "2"
		ElseIf cTipDoc=="1"
			cFiltro:= "1"
		EndIf	 	
	EndIf 

	GeraTemp(cLivro,cFiltro)

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
				ProcLivro(cLivro,cFilIni,cFilFim,cFiltro)
				GeraXLS(cLivro,cTipoExc)
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraTemp   ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos temporarios                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GeraTemp(cLivro,cFiltro)

	Local aStru		:= {}
	Local aOrdem	:= {}
	
	Default cLivro   := "V"
	Default cFiltro :="3"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Temporario LCV - Livro de Compras e Vendas IVA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aStru, {"NUMSEQ"	, "C", 008, 0})
	aAdd(aStru, {"TIPONF"	, "C", 001, 0})
	aAdd(aStru, {"NIT"		, "C", 015, 0})
	aAdd(aStru, {"RAZSOC"	, "C", 240, 0})
	aAdd(aStru, {"NFISCAL"	, "C", 020, 0})
	aAdd(aStru, {"POLIZA"	, "C", 015, 0})
	aAdd(aStru, {"NUMAUT"	, "C", 100, 0})
	aAdd(aStru, {"EMISSAO"	, "D", 010, 0})
	aAdd(aStru, {"VALCONT"	, "N", 014, 2})
	aAdd(aStru, {"EXPORT"	, "N", 014, 2})
	aAdd(aStru, {"EXENTAS"	, "N", 014, 2})
	aAdd(aStru, {"TAXAZERO"	, "N", 014, 2})
	aAdd(aStru, {"SUBTOT"	, "N", 014, 2})
	aAdd(aStru, {"DESCONT"	, "N", 014, 2})
	aAdd(aStru, {"BASEIMP"	, "N", 014, 2})
	aAdd(aStru, {"VALIMP"	, "N", 014, 2})
	aAdd(aStru, {"STATUSNF"	, "C", 001, 0})
	aAdd(aStru, {"CODCTR"	, "C", 017, 0})
	aAdd(aStru, {"DATAORD"	, "C", 010, 0})
	aAdd(aStru, {"DTNFORI"	, "D", 010, 0}) 
	aAdd(aStru, {"NFORI"	, "C", 015, 0})
	aAdd(aStru, {"AUTNFORI"	, "C", 100, 0})
	aAdd(aStru, {"VALNFORI"	, "N", 014, 2})	
	aAdd(aStru, {"VALICE"	, "N", 014, 2})
	aAdd(aStru, {"VALEHD"	, "N", 014, 2})
	aAdd(aStru, {"VALIPJ"	, "N", 014, 2})
	aAdd(aStru, {"VALTAS"	, "N", 014, 2})
	aAdd(aStru, {"VALOTR"	, "N", 014, 2})
	aAdd(aStru, {"VALGIFT"	, "N", 014, 2})
	aAdd(aStru, {"COMP"		, "C", 005, 0})
	
	aOrdem := {"DATAORD"}
	
	oTmpTabLCV := FWTemporaryTable():New("LCV")
	oTmpTabLCV:SetFields(aStru)
	oTmpTabLCV:AddIndex("IN1", aOrdem)
	oTmpTabLCV:Create()

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcLivro  ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa o Livro de Compras e Vendas IVA                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ProcLivro(cLivro,cFilIni,cFilFim,cFiltro)

	Local aImp		:= {}
	Local aAlias	:= {"SF3", ""}
	Local cTop		:= ""
	Local cDbf		:= ""
	Local cNIT		:= ""
	Local cCompl	:= ""
	Local cRazSoc	:= ""
	Local cArray	:= GetNewPar("MV_DAVINC1", "{}")	//Tipo de Factura: 1-Compras para Mercado Interno;2-Compras para Exportacoes;3-Compras tanto para o Mercado Intero como para Exportacoes
	Local aTpNf		:= &cArray
	Local cTpNf		:= "1"								//1-Compras para Mercado Interno;2-Compras para Exportacoes;3-Compras tanto para o Mercado Intero como para Exportacoes
	Local nPos		:= 0
	Local nPosIVA	:= 0
	Local cCpoPza	:= GetNewPar("MV_DAVINC2", "")		//Campo da tabela SF1: que contem o Numero de Poliza de Importacion
	Local cCpoDta	:= GetNewPar("MV_DAVINC3", "")		//Campo da tabela SF1: que contem a Data de Poliza de Importacion
	Local lOrdem	:= GetNewPar("MV_DAVINC4", .T.)     //Indica se arquivo sera ordenado por Emissao ou Entrada sendo F=Emissao e T=Entrada
	Local cChave	:= ""
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
	Local lExport	:= .F.                          
	Local lPassag 	:= 	cPaisLoc == "BOL" .And. GetNewPar("MV_PASSBOL",.F.) .And.;
					SF3->(ColumnPos("F3_COMPANH")) > 0 .And. ;
					SF3->(ColumnPos("F3_LOJCOMP")) > 0 .And. ;
					SF3->(ColumnPos("F3_PASSAGE")) > 0 .And. ;
					SF3->(ColumnPos("F3_DTPASSA")) > 0 .And. ;
					SF1->(ColumnPos("F1_COMPANH")) > 0 .And. ;
					SF1->(ColumnPos("F1_LOJCOMP")) > 0 .And. ;
					SF1->(ColumnPos("F1_PASSAGE")) > 0 .And. ;
					SF1->(ColumnPos("F1_DTPASSA")) > 0  
	Local cStatus	:=""
	Local cTesTas	:= GetNewPar("MV_TLIBTAS", "")			
	Local cTesOTR	:= GetNewPar("MV_TLIBOTR", "")
	 
	Default cFilIni	 := xFilial("SF3")
	Default cFilFim	 := xFilial("SF3")
	Default cFiltro	 :="3"
	
	If cLivro == "C"	//Compras

		cTop := "F3_FILIAL >= '" + cFilIni + "' AND F3_FILIAL <= '" + cFilFim + "' AND SUBSTRING(F3_CFO,1,1) < '5' AND F3_EMISSAO >= '" + ;
			DTOS(mv_par01) + "' AND F3_EMISSAO <= '" + DTOS(mv_par02) + "' AND F3_ESPECIE = 'NF'"
		cDbf := "F3_FILIAL >= '" + cFilIni + "' .And. F3_FILIAL <= '" + cFilFim + "' .And.  SUBSTRING(F3_CFO,1,1) < '5' .And. DTOS(F3_EMISSAO) >= '" + ;
			DTOS(mv_par01) + "' .And. DTOS(F3_EMISSAO) <= '" + DTOS(mv_par02) + "' .And. ALLTRIM(F3_ESPECIE) == 'NF'"

		cTop += " AND F3_RECIBO <> '1'"
		cDbf += " .And. F3_RECIBO <> '1'"

		SF1->(dbSetOrder(1))
		If !lOrdem
			LCV->(DBSetOrder(1))
		EndIf

	ElseIf cLivro == "V"	//Vendas
		cTop := "F3_FILIAL >= '" + cFilIni + "' AND F3_FILIAL <= '" + cFilFim + "' AND SUBSTRING(F3_CFO,1,1) >= '5' AND F3_EMISSAO >= '" + ;
			DTOS(mv_par01) + "' AND F3_EMISSAO <= '" + DTOS(mv_par02)+ "' AND F3_ESPECIE = 'NF'"
		cDbf := "F3_FILIAL >= '" + cFilIni + "' .And. F3_FILIAL <= '" + cFilFim + "' .And.   SUBSTRING(F3_CFO,1,1) >= '5' .And. DTOS(F3_EMISSAO) >= '" + ;
			DTOS(mv_par01) + "' .And. DTOS(F3_EMISSAO) <= '" + DTOS(mv_par02) + "' .And. ALLTRIM(F3_ESPECIE) == 'NF'"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta aImp com as informacoes dos impostos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SFB")
	dbSetOrder(1)
	dbGoTop()

	aAdd(aImp,{"IVA",""})
	aAdd(aImp,{"ICE",""})
	aAdd(aImp,{"IEH",""})
	aAdd(aImp,{"IUE",""})
	aAdd(aImp,{"ITU",""})
	While !SFB->(Eof())
		If !(Subs(SFB->FB_CODIGO,1,2) $ "IT|IC|IE|IU" )
			nPos := aScan(aImp,{|x| "IV" $ SFB->FB_CODIGO })
			If nPos > 0
				aImp[nPos,2] := SFB->FB_CPOLVRO
			Else        
				If cLivro$"C|V"
					If Empty(aScan(aCposIsen,{|x| SFB->FB_CPOLVRO $ x[1]})) .AND. (SFB->FB_CPOLVRO # aImp[1,2])
						aAdd(aCposIsen,{SFB->FB_CPOLVRO,SF3->(ColumnPos("F3_VALIMP"+SFB->FB_CPOLVRO))}) 
					EndIf               
				EndIf
			EndIf
		ElseIf Subs(SFB->FB_CODIGO,1,2) == "IC" 
			nPos := aScan(aImp,{|x| "ICE" $ x[1]})
			If nPos > 0
				aImp[nPos,2] := SFB->FB_CPOLVRO
			EndIf
		ElseIf Subs(SFB->FB_CODIGO,1,2) == "IE" 
			nPos := aScan(aImp,{|x| "IEH" $ x[1]})
			If nPos > 0
				aImp[nPos,2] := SFB->FB_CPOLVRO
			EndIf	
		ElseIf Subs(SFB->FB_CODIGO,1,2) == "IU" 
			nPos := aScan(aImp,{|x| "IUE" $ x[1]})
			If nPos > 0
				aImp[nPos,2] := SFB->FB_CPOLVRO
			EndIf		
		ElseIf Subs(SFB->FB_CODIGO,1,2) == "IT" 
			nPos := aScan(aImp,{|x| "ITU" $ x[1]})
			If nPos > 0
				aImp[nPos,2] := SFB->FB_CPOLVRO
			EndIf			
		EndIf	
		dbSkip()
	EndDo
	
	aSort(aImp,,,{|x,y| x[2] < y[2]})

	//Impuestos
	nPosIVA := Ascan(aImp,{|imp| imp[1] == "IVA"})

	aAdd(aImp[nPosIVA],SF3->(ColumnPos("F3_BASIMP"+aImp[nPosIVA][2])))		//Base de Calculo
	aAdd(aImp[nPosIVA],SF3->(ColumnPos("F3_VALIMP"+aImp[nPosIVA][2])))		//Valor do Imposto

	nPosICE := Ascan(aImp,{|imp| imp[1] == "ICE"})

	aAdd(aImp[nPosICE],SF3->(ColumnPos("F3_BASIMP"+aImp[nPosICE][2])))		//Base de Calculo
	aAdd(aImp[nPosICE],SF3->(ColumnPos("F3_VALIMP"+aImp[nPosICE][2])))		//Valor do Imposto

	nPosIEH := Ascan(aImp,{|imp| imp[1] == "IEH"})

	aAdd(aImp[nPosIEH],SF3->(ColumnPos("F3_BASIMP"+aImp[nPosIEH][2])))		//Base de Calculo
	aAdd(aImp[nPosIEH],SF3->(ColumnPos("F3_VALIMP"+aImp[nPosIEH][2])))		//Valor do Imposto
	
	nPosIUE := Ascan(aImp,{|imp| imp[1] == "IUE"})

	aAdd(aImp[nPosIUE],SF3->(ColumnPos("F3_BASIMP"+aImp[nPosIUE][2])))		//Base de Calculo
	aAdd(aImp[nPosIUE],SF3->(ColumnPos("F3_VALIMP"+aImp[nPosIUE][2])))		//Valor do Imposto

	nPosITU := Ascan(aImp,{|imp| imp[1] == "ITU"})

	aAdd(aImp[nPosITU],SF3->(ColumnPos("F3_BASIMP"+aImp[nPosITU][2])))		//Base de Calculo
	aAdd(aImp[nPosITU],SF3->(ColumnPos("F3_VALIMP"+aImp[nPosITU][2])))		//Valor do Imposto

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
		EndIf
		If cLivro == "C"  
			SF1->(DbSetOrder(1))
			If !Empty(cFilIni) .AND. !Empty(xFilial("SF1"))
				SF1->(MsSeek(SF3->F3_FILIAL+SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA))
			Else
				SF1->(MsSeek(xFilial("SF1")+SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA))
			EndIf
			// Filtro Eletronica
			If SF1->(ColumnPos("F1_FLFTEX")) >0
				If cFiltro =="1"  .AND. !Empty(SF1->F1_FLFTEX) 
					lProcLiv := .F.
				ElseIf cFiltro =="2" .AND. Empty(SF1->F1_FLFTEX)
					lProcLiv := .F.
				EndIf
			EndIF
		Else
			SF2->(DbSetOrder(1))
			If !Empty(cFilIni) .AND. !Empty(xFilial("SF2"))
				SF2->(MsSeek(SF3->F3_FILIAL+SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA))
			Else
				SF2->(MsSeek(xFilial("SF2")+SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA))
			EndIf
			// Filtro Eletronica
			If SF2->(ColumnPos("F2_FLFTEX")) >0
				If cFiltro =="1"  .AND. !Empty(SF2->F2_FLFTEX) 
					lProcLiv := .F.
				ElseIf cFiltro =="2" .AND. Empty(SF2->F2_FLFTEX)
					lProcLiv := .F.
				EndIf
			EndIF
		EndIf	
		If SF3->(FieldGet(aImp[nPosIUE][3])) > 0  .And. SF3->(FieldGet(aImp[nPosITU][3]))  > 0       
			lProcLiv :=.F.
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
						SF1->(MsSeek(SF3->F3_FILIAL+SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA))
					Else
						SF1->(MsSeek(xFilial("SF1")+SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA))
					EndIf
				ElseIf SF3->F3_TIPOMOV == "V"   //Vendas 
					If !Empty(cFilIni) .AND. !Empty(xFilial("SF2"))
						SF2->(MsSeek(SF3->F3_FILIAL+SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA))
					Else
						SF2->(MsSeek(xFilial("SF2")+SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA))
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
					cCompl:=""
					If SA1->(ColumnPos("A1_CLDOCID")) > 0
						cCompl:=Posicione("SA1",1,xFilial("SA1")+SF3->(F3_CLIEFOR+F3_LOJA),"A1_CLDOCID")
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
				//³5-Compras tanto para o Mercado Interno como para Exportacoes         ³
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
				LCV->NUMAUT		:= SF3->F3_NUMAUT
				LCV->COMP		:= cCompl
				lImport:=.F.
				
				If cLivro == "C"
					nDescont := xMoeda(SF1->F1_DESCONT,SF1->F1_MOEDA,1,SF1->F1_EMISSAO,,SF1->F1_TXMOEDA )
					If !lOrdem
						LCV->DATAORD := Dtos(SF3->F3_EMISSAO)
					EndIf
						LCV->POLIZA		:= "0"
					If !Empty(SF1->&(cCpoPza))		//Numero da Poliza de Importacion
						LCV->POLIZA		:= SF1->&(cCpoPza)
						LCV->NFISCAL	:= "0"
						lImport:= .T.
					EndIf
					If !Empty(SF1->&(cCpoDta))		//Data da Poliza de Importacion
						LCV->EMISSAO	:= SF1->&(cCpoDta)
					EndIf
					If  (cFiltro =="2" .or. cFiltro =="3"  ).And. SF2->(ColumnPos("F2_CODDOC"))>0 .and. SF1->(ColumnPos("F1_CODDOC"))>0 .And. Val(SF1->F1_CODDOC) > 0 
						LCV->NUMAUT		:= SF1->F1_CODDOC
					EndIf	
				ElseIf cLivro == "V"
					nDescont := 0
					nDescont := xMoeda(SF2->F2_DESCONT,SF2->F2_MOEDA,1,SF2->F2_EMISSAO,,SF2->F2_TXMOEDA )
					If  (cFiltro =="2" .or. cFiltro =="3"  ).And. SF2->(ColumnPos("F2_CODDOC")) .and. SF1->(ColumnPos("F1_CODDOC")) .And. Val(SF2->F2_CODDOC) > 0 
						LCV->NUMAUT		:= SF2->F2_CODDOC
					EndIf				
				EndIf
				LCV->STATUSNF	:= IIf(!Empty(SF3->F3_DTCANC),IIf(SF3->F3_STATUS$"EN",SF3->F3_STATUS,"A"),"V")	//NF Valida / Anulada / Extraviada ou Não utilizada
				LCV->CODCTR	:=Iif(Empty(SF3->F3_CODCTR),"0",SF3->F3_CODCTR) 
				If LCV->STATUSNF == "V"
					LCV->DTNFORI  := dDtNFOri
					LCV->NFORI    := cNFOri
					LCV->AUTNFORI := cAutNFOri
					LCV->VALNFORI := nValNFOri
				EndIf
				lCont:=.F.
				lExport:=.F. 
				If LCV->STATUSNF=="V" .And. cLivro == "V"
					aAreaTU:= GetArea()
					SFP->(DbSetOrder(6))
					If SFP->(MsSeek(xfilial("SFP")+cfilant+"1"+SF2->F2_SERIE)) 
						If SFP->FP_LOTE=="1"
							lCont:=.T.   	
						EndIf
						If SFP->(ColumnPos("FP_TPDOC")) > 0 .And. SFP->FP_TPDOC=="2"
							lExport:=.T. 
						EndIf
					EndIf	
					RestArea(aAreaTU)
					If lCont
						LCV->STATUSNF	:= "C"
					EndIf		
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
			Else
				LCV->TAXAZERO += SF3->(FieldGet(aImp[nPosIVA][3]))   //IVA com taxa zero
			EndIf   

			If SF3->(FieldGet(aImp[nPosICE][4])) > 0        
				If cStatus =="V"
					LCV->VALICE  += SF3->(FieldGet(aImp[nPosICE][4]))		//Valor do Imposto
				Else
					LCV->VALICE  :=0	//Valor do Imposto
				EndIf	
         	EndIf
         	
         	If SF3->(FieldGet(aImp[nPosIEH][4])) > 0        
				If cStatus =="V"
					LCV->VALEHD  += SF3->(FieldGet(aImp[nPosIEH][4]))		//Valor do Imposto
				Else
					LCV->VALEHD  :=0	//Valor do Imposto
				EndIf	
         	EndIf
         	
         	If SF3->F3_TES $ cTesTas 
         		LCV->VALTAS	:= LCV->VALTAS	+  SF3->F3_VALCONT
         	EndIf         				
         	
         	If SF3->F3_TES $  cTesOTR	
				LCV->VALOTR	:= LCV->VALOTR	+  SF3->F3_EXENTAS
			EndIf
			LCV->VALIPJ	:= 0
			If cLivro $ "C|V"
				For nInd:=1 To Len(aCposIsen)	
					If cStatus =="V" 
						If !(SF3->F3_TES $ cTesTas)
							If !(SF3->F3_TES $ cTesOTR)
								LCV->EXENTAS += IIf(aCposIsen[nInd][2]>0,SF3->(FieldGet(aCposIsen[nInd][2])),0)
							EndIf
						EndIf
	 				Else
						LCV->EXENTAS :=0
					EndIf	
				Next           
				If cLivro == "V" .And. Empty(SF3->(FieldGet(aImp[nPosIVA][3])))
					If cStatus =="V" 
						If !(SF3->F3_TES $ cTesTas)
							If !(SF3->F3_TES $ cTesOTR)
								LCV->EXPORT += SF3->F3_EXENTAS
							EndIf
						EndIf
					Else
						LCV->EXPORT :=0
					EndIf
				EndIf
				
				If cLivro == "C" .And. (SF3->F3_EXENTAS > 0)
					If cStatus =="V"
						If !(SF3->F3_TES $ cTesTas)
							If !(SF3->F3_TES $ cTesOTR)
								LCV->EXENTAS += SF3->F3_EXENTAS
							EndIf
						ENdIf
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
					LCV->VALCONT := LCV->VALCONT + LCV->DESCONT
					// Importaciones
					If cLivro == "C" .And. lImport .And. LCV->BASEIMP >0
						LCV->VALCONT := LCV->BASEIMP + LCV->DESCONT  
					EndIf 
					If cLivro == "V" .And. lExport .And. LCV->EXPORT == 0
						LCV->EXPORT := LCV->VALCONT
					EndIf
					// Calcular el SubTotal
					LCV->SUBTOT := LCV->VALCONT-  (LCV->VALICE+LCV->VALEHD+LCV->VALIPJ	+LCV->VALTAS+LCV->VALOTR +LCV->EXPORT+LCV->TAXAZERO+LCV->EXENTAS)
					// Retira Desconto de la nueva base
					LCV->BASEIMP:= LCV->SUBTOT  - LCV->DESCONT
				Else
					LCV->CODCTR		:="0"
					LCV->DESCONT 	:= 0
					LCV->SUBTOT 	:= 0                        
				EndIf
			EndIf
			LCV->(MsUnlock())
			// Criar PE para permitir campo do registro na tabela temporaria  // posicionado na tabla SF1 o SF2 e temporal LCV
			If ExistBlock('LIBBOLT')
				ExecBlock('LIBBOLT',.F.,.F.,{cLivro,cStatus})   // Libro (C=Cmpras/V= Ventas)     Status(V=Valida)
			Endif
		EndIf
	EndDo
	FsQuery(aAlias,2)
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³Programa  ³Libro Digital ³ Autor ³.   ³Fecha ³                          ³±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cierra y elimina archivo temporal LCV                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LIBBOLDel()
	If oTmpTabLCV <> Nil
		oTmpTabLCV:Delete()
		oTmpTabLCV := Nil
	EndIf
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³Programa  ³Libro Digital ³ Autor ³.   ³Fecha ³                          ³±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria  arquivo Excel                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GeraXLS(cLivro,cTipoExc)
	Local aArea        := GetArea()
	Local oFWMsExcel
	Local cDirec:= Alltrim(MV_PAR05)
	Local cArquivo    := ""
	Default cTipoExc  := "1" 
     
    //Criando o objeto que irá gerar o conteúdo do Excel
    If cTipoExc =="1"
    	cArquivo    :=  cDirec + Alltrim(MV_PAR04)+'.xml'
    	oFWMsExcel := FWMSExcel():New()
    Else
    	cArquivo    :=  cDirec + Alltrim(MV_PAR04)+'.XLSX'
    	oFWMsExcel := FwMsExcelXlsx():New()
    EndIf	
    //Aba 01 - Teste
    cNome:="Ventas"
    If cLivro =="C"
    	cNome:="Compras"
    EndIf
    oFWMsExcel:AddworkSheet(cNome)
    //Criando a Tabela
    oFWMsExcel:AddTable(cNome,"Productos")
	If cLivro =="V"
		oFWMsExcel:AddColumn(cNome,"Productos","Nº",1)
		oFWMsExcel:AddColumn(cNome,"Productos","ESPECIFICACION",1)
		oFWMsExcel:AddColumn(cNome,"Productos","FECHA DE LA FACTURA",1)
		oFWMsExcel:AddColumn(cNome,"Productos","N° DE LA FACTURA",1)
		oFWMsExcel:AddColumn(cNome,"Productos","CODIGO DE AUTORIZACION",1)
		oFWMsExcel:AddColumn(cNome,"Productos","NIT / CI CLIENTE",1)
		oFWMsExcel:AddColumn(cNome,"Productos","COMPLEMENTO",1)
		oFWMsExcel:AddColumn(cNome,"Productos","NOMBRE O RAZON SOCIAL",1)
		oFWMsExcel:AddColumn(cNome,"Productos","IMPORTE TOTAL DE LA VENTA",1)
		oFWMsExcel:AddColumn(cNome,"Productos","IMPORTE ICE",1)
		oFWMsExcel:AddColumn(cNome,"Productos","IMPORTE IEHD",1)
		oFWMsExcel:AddColumn(cNome,"Productos","IMPORTE IPJ",1)
		oFWMsExcel:AddColumn(cNome,"Productos","TASAS",1)
		oFWMsExcel:AddColumn(cNome,"Productos","OTROS NO SUJETOS AL IVA",1)
		oFWMsExcel:AddColumn(cNome,"Productos","EXPORTACIONES Y OPERACIONES EXENTAS",1)
		oFWMsExcel:AddColumn(cNome,"Productos","VENTAS GRAVADAS A TASA CERO",1)
		oFWMsExcel:AddColumn(cNome,"Productos","SUBTOTAL",1)
		oFWMsExcel:AddColumn(cNome,"Productos","DESCUENTOS, BONIFICACIONES Y REBAJAS SUJETAS AL IVA",1)
		oFWMsExcel:AddColumn(cNome,"Productos","IMPORTE GIFT CARD",1)
		oFWMsExcel:AddColumn(cNome,"Productos","IMPORTE BASE PARA DEBITO FISCAL",1)
		oFWMsExcel:AddColumn(cNome,"Productos","DEBITO FISCAL",1)
		oFWMsExcel:AddColumn(cNome,"Productos","ESTADO",1)
		oFWMsExcel:AddColumn(cNome,"Productos","CODIGO DE CONTROL",1)
		oFWMsExcel:AddColumn(cNome,"Productos","TIPO DE VENTA",1)
	Else
		oFWMsExcel:AddColumn(cNome,"Productos","Nº",1)
		oFWMsExcel:AddColumn(cNome,"Productos","ESPECIFICACION",1)
		oFWMsExcel:AddColumn(cNome,"Productos","NIT PROVEEDOR",1)
		oFWMsExcel:AddColumn(cNome,"Productos","RAZON SOCIAL PROVEEDOR",1)
		oFWMsExcel:AddColumn(cNome,"Productos","CODIGO DE AUTORIZACION",1)
		oFWMsExcel:AddColumn(cNome,"Productos","NUMERO FACTURA",1)
		oFWMsExcel:AddColumn(cNome,"Productos","NUMERO DUI/DIM",1)
		oFWMsExcel:AddColumn(cNome,"Productos","FECHA DE FACTURA/DUI/DIM",1)
		oFWMsExcel:AddColumn(cNome,"Productos","IMPORTE TOTAL COMPRA",1)
		oFWMsExcel:AddColumn(cNome,"Productos","IMPORTE ICE",1)
		oFWMsExcel:AddColumn(cNome,"Productos","IMPORTE IEHD",1)
		oFWMsExcel:AddColumn(cNome,"Productos","IMPORTE IPJ",1)
		oFWMsExcel:AddColumn(cNome,"Productos","TASAS",1)
		oFWMsExcel:AddColumn(cNome,"Productos","OTRO NO SUJETO A CREDITO FISCAL",1)
		oFWMsExcel:AddColumn(cNome,"Productos","IMPORTES EXENTOS",1)
		oFWMsExcel:AddColumn(cNome,"Productos","IMPORTE COMPRAS GRAVADAS A TASA CERO",1)
		oFWMsExcel:AddColumn(cNome,"Productos","SUBTOTAL",1)
		oFWMsExcel:AddColumn(cNome,"Productos","DESCUENTOS/BONIFICACIONES /REBAJAS SUJETAS AL IVA",1)
		oFWMsExcel:AddColumn(cNome,"Productos","IMPORTE GIFT CARD",1)
		oFWMsExcel:AddColumn(cNome,"Productos","IMPORTE BASE CF",1)
		oFWMsExcel:AddColumn(cNome,"Productos","CREDITO FISCAL",1)
		oFWMsExcel:AddColumn(cNome,"Productos","TIPO COMPRA",1)
		oFWMsExcel:AddColumn(cNome,"Productos","CODIGO DE CONTROL",1)  
	EndIf      
	//Criando as Linhas... Enquanto não for fim da query
	LCV->(DbGotop())
	While !(LCV->(EoF()))
		If cLivro =="C"
			nNumFact:= Val(LCV->NFISCAL)
			cNumFAt:=ALLTRIM(Str(nNumFact))
			oFWMsExcel:AddRow(cNome,"Productos", { ;
				LCV->NUMSEQ,;
				"1",;
				LCV->NIT,;
				LCV->RAZSOC,;
				LCV->NUMAUT,;
				cNumFAt,;
				LCV->POLIZA,;
				DtoC(LCV->EMISSAO),;
				IIf(Empty(LCV->VALCONT),"0",Str(LCV->VALCONT,14,2)),;
				IIf(Empty(LCV->VALICE),"0",Str(LCV->VALICE,14,2)),;
				IIf(Empty(LCV->VALEHD),"0",Str(LCV->VALEHD,14,2)),;
				IIf(Empty(LCV->VALIPJ),"0",Str(LCV->VALIPJ,14,2)),;
				IIf(Empty(LCV->VALTAS),"0",Str(LCV->VALTAS,14,2)),;
				IIf(Empty(LCV->VALOTR),"0",Str(LCV->VALOTR,14,2)),;
				IIf(Empty(LCV->EXENTAS),"0",Str(LCV->EXENTAS,14,2)),;
				IIf(Empty(LCV->TAXAZERO),"0",Str(LCV->TAXAZERO,14,2)),;
				IIf(Empty(LCV->SUBTOT),"0",Str(LCV->SUBTOT,14,2)),;
				IIf(Empty(LCV->DESCONT),"0",Str(LCV->DESCONT,14,2)),;
				IIf(Empty(LCV->VALGIFT),"0",Str(LCV->VALGIFT,14,2)),;
				IIf(Empty(LCV->BASEIMP),"0",Str(LCV->BASEIMP,14,2)),;
				IIf(Empty(LCV->VALIMP),"0",Str(LCV->VALIMP,14,2)),;
				LCV->TIPONF,;
				LCV->CODCTR })
		Else
			nNumFact:= Val(LCV->NFISCAL)
			cNumFAt:=ALLTRIM(Str(nNumFact))
			oFWMsExcel:AddRow(cNome,"Productos",{ ;
				LCV->NUMSEQ,;
				"2",;
				Left(DtoC(LCV->EMISSAO),6)+Str(Year(LCV->EMISSAO),4),;
				cNumFAt,;
				LCV->NUMAUT,;
				LCV->NIT,;
				LCV->COMP,;
				LCV->RAZSOC,;
				IIf(Empty(LCV->VALCONT),"0",Str(LCV->VALCONT,14,2)),;
				IIf(Empty(LCV->VALICE),"0",Str(LCV->VALICE,14,2)),;
				IIf(Empty(LCV->VALEHD),"0",Str(LCV->VALEHD,14,2)),;
				IIf(Empty(LCV->VALIPJ),"0",Str(LCV->VALIPJ,14,2)),;
				IIf(Empty(LCV->VALTAS),"0",Str(LCV->VALTAS,14,2)),;
				IIf(Empty(LCV->VALOTR),"0",Str(LCV->VALOTR,14,2)),;
				IIf(Empty(LCV->EXPORT),"0",Str(LCV->EXPORT,14,2)),;
				IIf(Empty(LCV->TAXAZERO),"0",Str(LCV->TAXAZERO,14,2)),;
				IIf(Empty(LCV->SUBTOT),"0",Str(LCV->SUBTOT,14,2)),;
				IIf(Empty(LCV->DESCONT),"0",Str(LCV->DESCONT,14,2)),;
				IIf(Empty(LCV->VALGIFT),"0",Str(LCV->VALGIFT,14,2)),;
				IIf(Empty(LCV->BASEIMP),"0",Str(LCV->BASEIMP,14,2)),;
				IIf(Empty(LCV->VALIMP),"0",Str(LCV->VALIMP,14,2)),;
				LCV->STATUSNF,;
				LCV->CODCTR,;
				"0" })  
		EndIf
		//Pulando Registro
		LCV->(DbSkip())
	EndDo
    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
    RestArea(aArea)
Return
