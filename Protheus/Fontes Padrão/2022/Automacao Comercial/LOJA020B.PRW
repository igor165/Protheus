#INCLUDE "LOJA020B.CH"
#INCLUDE "PROTHEUS.CH"

Static cSE5Documen
Static nSE1Recno

/*                         
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A020WTroca³ Autor ³ Adriano Sacomani      ³ Data ³ 04.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega Acols Conforme nota                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A020WTroca(cNum_Troca,cSerie_Tro)
Local nCnt, nC, nE
Local lLj020Ite	:= ExistBlock("LJ020ITE")	//Controla a existencia do ponto de entrada LJ020ITE
Local lPermite	:= .T.						//Permite ou nao a adicao do item do SL2
Local nDecs     := MsDecimais(IIf(Type("nMoedaTr")=="N",nMoedaTr,1))
Local nI      

IF !lFirst .and. !lTrocLoja
	 lFirst:=.T.
	 If cPaisLoc != "ARG"
	    A020Form() 
	 EndIf   
	 oCliente:SetFocus()
	 Return .F.
Endif  
  
If Upper(cComprou) <> "S" .and. Upper(cComprou) <> "N"
	Help(" ","1","NOANSWER")
	Return .F.
Endif 
	
If (UPPER(cComprou) == "S") .And. (!Empty(SL1->L1_DOC) .Or. !Empty(SL1->L1_DOCPED))
	cNumNota := SL1->L1_DOC
	cSerie	 := SL1->L1_SERIE  
	cDatEmi  := SL1->L1_EMISSAO
	cNumPdv	 := SL1->L1_PDV
	lExistNota:= .T.
	cNum_troca := cNumNota
	cSerie_tro := cSerie
	cCliente   := SL1->L1_CLIENTE
	cLoja 	   := SL1->L1_LOJA
ElseIf Empty(SL1->L1_DOC) .And. Upper(cComprou) != "N" .And. Empty(SL1->L1_DOCPED)
	Help(" ","1","NOVENDIDO")
	A020FIM(oDlg1)
	cComprou:=Space(01)
	Return  .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso a nota n„o tenha numero, significa que n„o h  nota original   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( cNumNota )
	nDescont   :=Iif(!Empty(SL1->L1_DESCONT),SL1->L1_DESCONT,0)
	lExistNota := .T.
	cCLiente   := SL1->L1_CLIENTE
	cLoja      := SL1->L1_LOJA
Else
	DbSeek( xFilial("SL1") )
EndIf

//Montando Acols
If !lExistNota .And. SL1->L1_TIPO <> "P"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona ponteiro do arquivo cabeca e inicializa variaveis  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsado:=0
	DbSelectArea("SX3")
	DbSeek( "SL2" )
	While !Eof() .And. x3_arquivo == "SL2"
		If (x3Uso(x3_usado) .And. cNivel >= x3_nivel .And.	alltrim(x3_campo)!="L2_NUM") .or. Alltrim(X3_campo) == "L2_ITEM"
			nUsado++
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Array de 1 elemento ³
			//³ vazio. Se inclus„o. 	  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If x3_tipo == "C"
				aCOLS[1][nUsado] := SPACE(x3_tamanho)
			ElseIf x3_tipo == "N"
				aCOLS[1][nUsado] := 0
			ElseIf x3_tipo == "D"
				aCOLS[1][nUsado] := dDataBase
			Else
				aCOLS[1][nUsado] := .F.
			EndIf
		EndIf
		dbSkip()
	End
	aCOLS[1][nUsado+1] := .F.
	lCnd:=.T.
	oCliente:SetFocus()
Else
	DbSelectArea( "SL2" )
	DbSetOrder( 1 )
	DbSeek( cFilial+SL1->L1_NUM )
	nCnt	 := 0
	nUsado	 := 0
	nDescont := 0
	nMerc 	 := 0
	nTItens  := 0                  
	aRetencoes := {}
	While !Eof( ) .And. L2_FILIAL+L2_NUM==cFilial+SL1->L1_NUM
		
		If L2_STATUS == "D" .Or. (L2_VENDIDO != "S" .And. SL1->L1_TIPO <> "P") .Or. (!Empty(SL1->L1_ORCRES) .And. SL2->L2_STATUS <> "T")
			dbSkip( )
			Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de entrada que valida a adicao do item no aCols³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lLj020Ite
			lPermite := ExecBlock("LJ020ITE",.F.,.F.)
			If (ValType(lPermite) == "L") .AND. !(lPermite)
				SL2->(dbSkip())
				Loop				
			EndIf	
		EndIf
			
		nTItens  ++
		nDescont += SL2->L2_DESCPRO + SL2->L2_VALDESC
		If cPaisLoc == "BRA"
			nMerc 	+= SL2->L2_VLRITEM+SL2->L2_VALIPI + Iif(LJ020ICMSSol(SL2->L2_TES)[1],SL2->L2_ICMSRET,0)
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Considerar todos os impostos que incidem no Total da Nota ³
			//³ baseando se na Roteiro Amarracao Tes X Impostos.          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMerc += SL2->L2_VLRITEM
			cTesImp := SL2->L2_TES
			aImposto := DefImposto( SL2->L2_TES )
			For nC := 1 To Len(aImposto)
				cImposto := aImposto[nC][2]
				For nE := 1 To 6
					cCampo := "VALIMP"+Str(nE,1)
					If cCampo == cImposto .And. aImposto[nC][3] == "1"  //Determina se imposto incide ou nao na nota
						cCampo := "SL2->L2_"+cCampo
						nMerc += &cCampo.
					EndIf	
				Next nE
			Next nC
		EndIf

		nCnt++
		If nCnt > Len(Acols)
			AADD(aCols,Array(nUsado+1))
		Endif 
		nUsado:=0
		DbSelectArea("SX3")
		DbSeek( "SL2" )
		While !Eof() .And. x3_arquivo == "SL2"
			If (x3Uso(x3_usado) .And. cNivel >= x3_nivel .And. alltrim(x3_campo)!="L2_NUM") .or. Alltrim(X3_campo) == "L2_ITEM"
				nUsado++
				If  X3_CONTEXT<>"V"
					aCOLS[nCnt][nUsado]     :=&(" SL2->"+x3_campo)
				Else
					aCOLS[nCnt][nUsado]     :=Criavar(x3_campo)
				EndIf
				
				if Upper(AllTrim(x3_campo)) == "L2_VALDESC"
					aCOLS[nCnt][nUsado] += SL2->L2_DESCPRO
				EndIf
				if Upper(AllTrim(x3_campo)) == "L2_DESCPRO"
					aCOLS[nCnt][nUsado] := 0
				EndIF
				if Upper(AllTrim(x3_campo)) == "L2_DESC"
					aCOLS[nCnt][nUsado] := ((SL2->L2_DESCPRO + SL2->L2_VALDESC)/SL2->L2_QUANT/SL2->L2_PRCTAB)*100
				EndIF
            EndIf
			dbSkip()
		End

		If GetMV("MV_LJDELTD") == "S"
			aCols[nCnt][nUsado+1] := .T.
		Else
			aCols[nCnt][nUsado+1] := .F.
		EndIf

		If SL2->(FieldPos( "L2_VALPIS" )) > 0 .And. SL2->(FieldPos( "L2_VALCOFI" )) > 0 .And. ;
		   SL2->(FieldPos( "L2_VALCSLL" )) > 0 .AND. SL1->(FieldPos("L1_ABTOPCC")) > 0 .AND. ;
		   SL1->L1_ABTOPCC > 0

			aAdd(aRetencoes, { ( ( SL2->L2_VALPIS / SL2->L2_VLRITEM ) * 100 ), ( ( SL2->L2_VALCSLL / SL2->L2_VLRITEM ) * 100 ), ;
			                   ( ( SL2->L2_VALCOFI / SL2->L2_VLRITEM ) * 100 ), 0, .F. })

		Else

			aAdd(aRetencoes, { 0, 0, 0, 0, .F. })

		EndIf
		
		If LJ220AbISS()
			aRetencoes[Len(aRetencoes)][04] := ( ( SL2->L2_VALISS / SL2->L2_VLRITEM ) * 100 )
		EndIf

		Aadd(aQtde,aCols[nCnt][nPosQuant])
		DbSelectArea( "SL2" )
		dbSkip()
	End
        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se houver descto. financeiro, ele deve ser tambem  ³
	//³ descontado do valor das mercadorias                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    DbSelectArea("SE4")
    DbSetOrder(1)
    If DbSeek(xFilial("SE4")+SL1->L1_CONDPG)
    	//Se houver desct. financ. e nao houve desconto no total da venda
    	If (SE4->E4_DESCFIN > 0) .AND. (SL1->L1_DESCNF == 0)
    		nMerc := 0
    		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se houver descto. financeiro, ele deve ser descontado  ³
			//³ na variavel nMerc e tambem em cada item (aCols)        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			for nI := 1 to len(aCols)
	    		aCOLS[nI][nPosTotal]	:= Round((aCOLS[nI][nPosPrcTab]*aCOLS[nI][nPosQuant]) - ( (aCOLS[nI][nPosPrcTab]*aCOLS[nI][nPosQuant]) * (SE4->E4_DESCFIN / 100) ) ,nDecs)
	    		aCOLS[nI][nPosUnit]		:= Round( aCOLS[nI][nPosTotal] / aCOLS[nI][nPosQuant] ,nDecs)
	    		nMerc += aCOLS[nI][nPosTotal]
			Next nI
		Endif
    Endif
    
    //Ponto de entrada para alterar o Tes no momento da troca.
	
    If ExistBlock('LJ020TES')
       ExecBlock('LJ020TES',.F.,.F.)
    EndIf   
	If Empty(aCols[1][1])
		If !Empty(SL1->L1_ORCRES) .And. !Empty(SL1->L1_FILRES)
			// "Atenção" / "Esse orçamento foi gerado através de um pedido e para liberar sua devolução deverá primeiramente ser feita a devolução do pedido que o originou. Filial: " / " Orçamento: "
			Aviso(STR0004, STR0005 + SL1->L1_FILRES + STR0006 + SL1->L1_ORCRES + ".", {"Ok"} )
		Else
			Help(" ",1,"SEMTROCA")
		Endif
		nTroc   := 0
		nMerc   := 0   
		nTIens  := 0
		cComprou:=Space(1)
		cLoja   := GetMv("MV_LOJAPAD")
		cCliente:= GetMv("MV_CLIPAD")
		cDescCli:=Space(40)
		A020Fim(oDlg1)
		Return .f.
	Else
		// Atualizando Objetos
		oGet:ForceRefresh()		
		nTroc    := ( nMerc - LJ020SumRet() )
		nCredito -= ( LJ020SumRet() )
		cCliente := SL1->L1_Cliente
		cLoja    := SL1->L1_Loja
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+cCliente+cLoja)
		cDescCli:=Sa1->A1_Nome
		lCnd:=.F.
	Endif 
	oCliente:Refresh()
	oLoja:Refresh()
	oDesc:Refresh()
	oTroc:Refresh()
	oMerc:Refresh()
    oTItens:Refresh()
	DbSelectArea("SL1")
Endif
If cPaisLoc != "ARG"
   A020Form()
EndIf   
lComprou:=.F.
If ! lTrocLoja
	oCliente:Refresh()
Endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj020TudOk³ Autor ³ Adriano Sacomani      ³ Data ³ 04.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de Tudo Ok da Troca                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj020TudOk(nBicms,nVlrIcms)
Local i
lj020Total()
If nBicms <> Nil
	If cPaisLoc=="BRA"
		lj020ICMS(@nBicms,@nVlrIcms,nTroc)
	EndIf	
Endif 

For i := 1 To Len(aCols)
	// verifica a quantidade devolvida para troca da loja
	If aCols[i][nPosQuant] > aQtde[i]
		Help(" ",1,"LJ020QUANT")
		aCols[i][nPosQuant] := aQtde[i]
		lRet := .F.
	EndIf
Next i
 
Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj020Entra³ Autor ³ Fernando Godoy        ³ Data ³ 12.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria um registro de entrada no SD1 e SF1, como uma NF de	  ³±±
±±³          ³devolu‡„o, recalculando o saldo em estoque, bem como o custo³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³lj020Entra()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  DATA    ³ BOPS ³Program.³   ALTERACAO                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³05/01/00  ³84755 ³Henry F ³Tratamento realizado para troca de outra    ³±±
±±³          ³      ³        ³loja para que se baseie no SL1 local        ³±±
±±³02/09/05  ³885843³Marcos R³Tratamento realizado para gravar em SF1     ³±±
±±³          ³      ³        ³SD1 os campos ref. ao Imposto Solidario     ³±±
±±³02/09/05  ³DELLA ³Marcos R³Incluido na MAFISADD no parametro 5 o       ³±±
±±³          ³VIA   ³        ³desconto, pois estava calculando o imposto  ³±±
±±³          ³      ³        ³sobre o preço de tabela e não sobre o valor ³±±
±±³          ³      ³        ³com desconto                                ³±± 
±±³05/12/05  ³089250³Geronimo³Gravo no L2_ITEMSD1 o conteudo do D1_NUMSEQ ³±± 
±±³          ³      ³        ³para correto relacionamento das tabs SD1xSL2³±± 
±±³          ³      ³        ³para uso no relatorio de devoluçoes lojr075.³±± 
±±³          ³      ³        ³(O SL2 ja esta posicionado )                ³±± 
±±³15/12/05  ³090188³Marcos R³Verifica se o L2_ITEMSD1 ja foi gravado,    ³±± 
±±³          ³      ³        ³pois este campo entrou na chave unica do SL2³±± 
±±³          ³      ³        ³para evitar error.log na devolucao parcial  ³±± 
±±³          ³      ³        ³caso nao tenha sido gravado faz a gravacao  ³±± 
±±³22/02/06  ³099248³Norbert ³Atualiza o Saldo de Titulos do cliente apos ³±±
±±³          ³      ³        ³a geracao da NCC.                           ³±± 
±±³09/03/06  ³094105³Marcos R³Na gravacao do L2_ITEMSD1, somente gravar se³±± 
±±³          ³      ³        ³for troca da loja.                          ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj020Entra(aCols_1		,  nX		, nItem		, cTabela	,;
					cTes		, cLocal	, cProduto	, cDescri	,;
					nVlrItem	, nDesc		, nValDesc	, cUM		,;
					cCF			, cItem		, nQuant	, nVunit	,;
					nValIcms	, nValIss	, nValIpi	, nBaseIcm	,;
					nBicms		, nVlrIcms	, nItens	, nF1ValMerc,;
					nF1ValBrut	, nF1Baseicm, nF1Valicm	, nF1Valipi	,;
					cNSerie		, cLotectl	, cNLote	, cLocaliz	,;
					nMaxItens	, nDescPro	, nPrctab	, cNumAnt	,;
					cSerAnt		, cDatAnt	, nVlrTroca , nVlrFrete	,;
					nVlrSeguro	, nVlrDespesa, cProxnum)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Vari veis Locais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nPos		:= 0
Local aArea
Local aCustoEnt
Local aCusto    := {}
Local nRegSF4   := 0
Local lLjD1Tes  := (ExistBlock("LJD1TES"))
Local lLjD1Tsp  := (ExistBlock("LJD1TSP"))
Local lLjD1TesT := (ExistBlock("LJD1TesT"))
Local aRet      := {}
Local cTESTroca	:= SuperGetMv("MV_TESTROCA")
Local cCFTroca 	:= ""
LOCAL aGetBook  := {}
Local nPosTES   := Ascan(aHeader,{|x|AllTrim(x[2])=="L2_TES"})
Local nPosCF    := Ascan(aHeader,{|x|AllTrim(x[2])=="L2_CF"})
Local nDecs     := MsDecimais(IIf(Type("nMoedaTr")=="N",nMoedaTr,1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis para geracao da NCC referente Troca                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cParcela,lConfNCC,nValorCred,cDocNCC
Local nMoedaBco  := 1 
Local nRndBco    := 2
Local nJurosSL1  := 0
Local aRelImp	 := MaFisRelImp("MT100",{ "SF1","SD1" })
Local nScanBsPis := 0
Local nScanVlPis := 0
Local nScanAlPis := 0
Local cCpBasePIS := ""
Local cCpValPIS  := ""
Local cCpAlqPIS  := ""
Local nScanBsCof := 0
Local nScanVlCof := 0
Local nScanAlCof := 0
Local cCpBaseCOF := ""
Local cCpValCOF  := ""
Local cCpAlqCOF  := ""
Local nItemFis   := 0
Local lIcmsSol   := .T.

Local  nBsIcmRet := 0
Local  nVlIcmRet := 0
Local lGrvItemSd1:= .F.

Default nVlrTroca:= 0                
Default cProxnum := ""			//Numero que faz a amaracao entre L2_ITEMSD1 e o D1_NUMSEQ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o L2_ITEMSD1 ja foi gravado, senao faz a gravacao do campo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( cProxNum )
	lGrvItemSd1 := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria uma nota no MatxFis para gravacao dos impostos variaveis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "BRA" .And. MaFisFound("NF")
	MaFisEnd()
EndIf

If !(aCols_1[nx][nUsado+1])		// Se nao estiver Deletado
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ P.E. "LJD1TesT" -> Altera a TES de Troca Para o SD1.                  ³
	//³ O Retorno Esperado eh Um Array Que Pode Ser Utilizado Posteriormente. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc != "BRA"
		If nPosTES > 0 .And. aCols_1[nX][nPosTES] < "500"
			cTESTroca := aCols_1[nX][nPosTES]
			If nPosCF > 0
				cCFTroca  := aCols_1[nX][nPosCF]
			EndIf
		EndIf
	EndIf

	If lLjD1TesT
		aRet := ExecBlock("LJD1TesT",.F.,.F.,{cTESTroca,cProduto,nX})
		If ValType(aRet) == "A"
			cTESTroca := aRet[1]
		EndIf
	ElseIf nModulo <> 72
	   cTesTroca := LJ020ICMSSOL(aCols_1[nx][nPosTes])[2]
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Localiza o cliente.           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SA1")
	SA1->( DbSetOrder(1) )
	SA1->( DbSeek( xFilial("SA1") + cCliente + cLoja) )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Localiza registro do Produto. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SB1")
	SB1->( DbSetOrder(1) )
	SB1->( DbSeek(xFilial("SB1")+cProduto) )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua estorno do estoque. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SF4")
	SF4->( DbSetOrder(1) )
	SF4->( DbSeek( xFilial("SF4") + cTESTroca) )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se TES agrega imposto solidario no valor total do produto.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SF4->F4_INCSOL == "N"
		lIcmsSol := .F.
	EndIf
	//Valida o estado do cliente/fornecedor
	If SA1->A1_EST == GetMV("MV_ESTADO") .And. SA1->A1_TIPO # "X" .Or. SA1->(Eof())
		cCFTroca := "1" + SubStr(SF4->F4_CF, 2, LEN(SF4->F4_CF)-1)
	ElseIf SA1->A1_TIPO#"X"
		cCFTroca := "2" + SubStr(SF4->F4_CF, 2, LEN(SF4->F4_CF)-1)
	Else
		cCFTroca := "3" + SubStr(SF4->F4_CF, 2, LEN(SF4->F4_CF)-1)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera registro de entrada no estoque para itens devolvidos. ³
	//³ registro do cabecalho                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SF1")
	SF1->( DbSetOrder(1) )
	If SF1->( DbSeek(xFilial()+cNumTroc+cSerieDev+cCliente+cLoja) )
		Reclock(  "SF1" , .F. )
		If cPaisLoc == "BRA"
			SF1->F1_VALMERC	:= nF1ValMerc
			SF1->F1_VALBRUT := nF1ValBrut
			If SF4->F4_ICM == "S"
				SF1->F1_BASEICM += nBaseIcm
				SF1->F1_VALICM  += nValIcms
			EndIf
			If SF4->F4_IPI == "S"
				SF1->F1_BASEIPI += nBaseIcm
				SF1->F1_VALIPI  += nValIPI
			EndIf
			SF1->F1_FRETE += nVlrFrete
			SF1->F1_SEGURO += nVlrSeguro
			SF1->F1_DESPESA += nVlrDespesa
		Else
			SF1 -> F1_VALMERC+= Round(nVUnit * nQuant,nDecs)
			Lj020GrImp( cTesTroca, nX, 'SF1', '+' ) //Grava Impostos ( valor e base )
		EndIf
		MsUnlock()
		
		If cPaisLoc == "BRA"
			If MaFisFound("NF")
				MaFisEnd()
			EndIf
		        
			MaFisIni(SF1->F1_FORNECE,SF1->F1_LOJA,"C","D",Nil,MaFisRelImp("MT100",{"SF1","SD1"}),,)
		EndIf		
	Else
		Reclock( "SF1" , .T. )
		SF1->F1_FILIAL	:= xFilial()
		SF1->F1_DOC    	:= cNumTroc
		SF1->F1_DUPL  	:= cNumNota
		SF1->F1_SERIE	:= cSerieDev
		SF1->F1_FORNECE	:= cCliente
		SF1->F1_LOJA	:= cLoja
		SF1->F1_EMISSAO	:= dDataBase
		SF1->F1_VALMERC	:= nF1ValMerc
		If cPaisLoc == "BRA"
			SF1->F1_VALBRUT	:= nF1ValBrut + nVlrFrete + nVlrSeguro + nVlrDespesa
			SF1->F1_FRETE 	+= nVlrFrete
			SF1->F1_SEGURO 	+= nVlrSeguro
			SF1->F1_DESPESA	+= nVlrDespesa
		Else
			//Gravacao integral do total da nota devido os impostos variaveis
			SF1->F1_VALBRUT	:= Round(nMerc,nDecs)
			SF1->F1_ESPECIE	:= "NCC"
		EndIf
		SF1->F1_DTDIGIT	:= dDataBase
		SF1->F1_RECBMTO	:= SF1->F1_DTDIGIT
		SF1->F1_TIPO	:= "D"
		SF1->F1_DESCONT	:= nDescont
		SF1->F1_EST 	:= SA1->A1_EST
		SF1->F1_FORMUL	:= cFormPro
		If cPaisLoc == "BRA"
			If SF4->F4_ICM == "S"
				SF1->F1_BASEICM := nBaseIcm
				SF1->F1_VALICM  := nValIcms
			EndIf
			If SF4->F4_IPI == "S"
				SF1->F1_BASEIPI := nBaseIcm
				SF1->F1_VALIPI  := nF1Valipi
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravar os Impostos baseados no Roteiro de C lculo para os  ³
			//³ paises do MercoSul...                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Lj020GrImp( cTesTroca, nX, 'SF1', '+' ) //Grava Impostos ( valor e base )
		EndIf
		SF1->F1_STATUS  := "A"
		SF1->F1_PREFIXO := &( GETMV("MV_2DUPREF") )
		MsUnlock()
		
		If cPaisLoc == "BRA"
			If MaFisFound("NF")
				MaFisEnd()
			EndIf
		        
			MaFisIni(SF1->F1_FORNECE,SF1->F1_LOJA,"C","D",Nil,MaFisRelImp("MT100",{"SF1","SD1"}),,)
		EndIf
		
		// Inicio da geracao da NNC Ref Troca
		
		If !Empty(cSE5Documen) .And. !Empty(nSE1Recno)
			
			SE1->(DbGoto(nSE1Recno))
			
			nValorCred := SE1->E1_SALDO
			
			cParcela := GetMV("MV_1DUP")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Sempre que houver credito deixar o parametro MV_DEVNCC     ³
			//³ decidir se gera NCC                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nCredito >0
			    If !ExistBlock('LJCFGNCC')		
					If GetMV("MV_DEVNCC") == "1"
						lConfNcc := .F.
					Elseif GetMV("MV_DEVNCC") == "2"
						lConfNcc := .T.
					Elseif GetMV("MV_DEVNCC") == "3"
						lConfNcc := MsgYesNo(OemToAnsi(STR0002),OemToAnsi(STR0003))  //"Deseja Gerar NCC(Nota de Credito ao Cliente) para o Financeiro"  "Gera NCC"
					ElseIf GetMV("MV_DEVNCC") == "4"
						lConfNcc := .T.
					Endif
				Else            
					lConfNCC := ExecBlock('LJCFGNCC',.F.,.F.,{cNumAnt,cSerAnt})
				Endif
				
				If lConfNcc
					While SE1->(DbSeek(cFilial+SF1->F1_PREFIXO+cNumTroc+cParcela+"NCC"))
						cParcela := CHR(ASC(cParcela)+1)
					End
					RecLock("SE1",.T.)
					SE1->E1_FILIAL 		:= xFilial("SE1")
					SE1->E1_PREFIXO	 	:= SF1->F1_PREFIXO
					SE1->E1_NUM 		:= cNumTroc
					SE1->E1_PARCELA 	:= cParcela
					SE1->E1_NATUREZ 	:= &(GetMV("MV_NATNCC"))			// NOTA DE CREDITO
					SE1->E1_PORTADO 	:= xNumCaixa()
					If cPaisLoc <> "BRA" .And. nMoedaTr > 1
						SE1->E1_AGEDEP := GetMV("MV_SIMB"+Str(nMoedaTr,1))
					Else
						SE1->E1_AGEDEP := "."
					EndIf
					SE1->E1_CONTA 		:= "."
					SE1->E1_TIPO 		:= MV_CRNEG
					SE1->E1_EMISSAO 	:= dDataBase
					SE1->E1_EMIS1 		:= dDataBase
					SE1->E1_VALOR 		:= nCredito
					SE1->E1_VENCREA 	:= dDataBase
					SE1->E1_SALDO 		:= nCredito
					SE1->E1_VENCTO 		:= dDataBase
					SE1->E1_VENCORI		:= ddataBase
					SE1->E1_CLIENTE 	:= cCliente
					SE1->E1_LOJA 		:= cLoja
					SE1->E1_NOMCLI 		:= SA1->A1_NREDUZ
					SE1->E1_MOEDA 		:= 1
					SE1->E1_VLCRUZ 		:= xMoeda(SE1->E1_VALOR,1,1,SE1->E1_EMISSAO)
					SE1->E1_STATUS 		:= "A"
					SE1->E1_SITUACA 	:= "0"
					SE1->E1_ORIGEM 		:= "LOJA020"
					SE1->E1_SERIE 		:= cSerieDev
					dbCommit()
					MsUnlock()
					
					cDocNCC := SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_LOJA
					
					RecLock("SE5",.T.)
					SE5->E5_FILIAL  := xFilial("SE5")
					SE5->E5_DATA    := dDataBase
					SE5->E5_TIPODOC := "BA"
					If cPaisLoc == "BRA"
						SE5->E5_VALOR	 := xMoeda(nValorCred,SE1->E1_MOEDA,1)
					Else
						If !Empty(SE1->E1_PORTADO)
							SA6->(DbSetOrder(1))
							If SA6->(DbSeek( xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA))
								nMoedaBco := Max(SA6->A6_MOEDA,1)
								nRndBco := MsDecimais(nMoedaBco)
							EndIf
						EndIf
						SE5->E5_VALOR	 := Round(xMoeda(nValorCred,SE1->E1_MOEDA,nMoedaBco,dDataBase,nRndBco+1),nRndBco)
						SE5->E5_MOEDA	 :=	StrZero(nMoedaBco,2)
					EndIf
					SE5->E5_VLMOED2	:= nValorCred
					SE5->E5_DTDIGIT	:= dDataBase
					SE5->E5_NATUREZ	:= SE1->E1_NATUREZ
					SE5->E5_DTDISPO	:= SE5->E5_DATA
					SE5->E5_BANCO	:= SE1->E1_PORTADO
					SE5->E5_AGENCIA	:= If(cPaisLoc=="BRA",".",SE1->E1_AGEDEP)
					SE5->E5_CONTA	:= "."
					SE5->E5_DOCUMEN	:= cSE5Documen
					SE5->E5_RECPAG	:= "R"
					SE5->E5_MOTBX	:= "CMP"
					SE5->E5_PREFIXO	:= SE1->E1_PREFIXO
					SE5->E5_NUMERO	:= SE1->E1_NUM
					SE5->E5_PARCELA	:= SE1->E1_PARCELA
					SE5->E5_TIPO	:= SE1->E1_TIPO
					SE5->E5_CLIFOR	:= SE1->E1_CLIENTE
					SE5->E5_CLIENTE	:= SE1->E1_CLIENTE
					SE5->E5_LOJA	:= SE1->E1_LOJA
					SE5->E5_HISTOR	:= OemToAnsi(STR0001)
					MsUnLock()
					
					RecLock("SE1",.F.)
					SE1->E1_SALDO := SE1->E1_SALDO - nValorCred
					If SE1->E1_SALDO == 0
						SE1->E1_STATUS := "B"
						SE1->E1_BAIXA := dDataBase
					EndIf
					MsUnLock()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza saldo dos titulos do cliente³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ! SuperGetMV( "MV_CLIPAD" )+ SuperGetMV( "MV_LOJAPAD" ) == SA1->A1_COD+SA1->A1_LOJA
			          	AtuSalDup("-",SE1->E1_SALDO,SE1->E1_MOEDA,SE1->E1_TIPO,,SE1->E1_EMISSAO)
					EndIf	
				
					SE1->(DbGoto(nSE1Recno))
					
					RecLock("SE5",.T.)
					SE5->E5_FILIAL  := xFilial("SE5")
					SE5->E5_DATA	 := dDataBase
					SE5->E5_TIPODOC := "CP"
					If cPaisLoc == "BRA"
						SE5->E5_VALOR	 := xMoeda(nValorCred,SE1->E1_MOEDA,1)
					Else
						SE5->E5_VALOR	 := Round(xMoeda(nValorCred,SE1->E1_MOEDA,nMoedaBco,dDataBase,nRndBco+1),nRndBco)
						SE5->E5_MOEDA	 :=	StrZero(nMoedaBco,2)
					EndIf
					SE5->E5_VLMOED2	:= nValorCred
					SE5->E5_DTDIGIT	:= dDataBase
					SE5->E5_NATUREZ	:= SE1->E1_NATUREZ
					SE5->E5_DTDISPO	:= SE5->E5_DATA
					SE5->E5_BANCO	:= SE1->E1_PORTADO
					SE5->E5_AGENCIA	:= If(cPaisLoc=="BRA",".",SE1->E1_AGEDEP)
					SE5->E5_CONTA	:= "."
					SE5->E5_DOCUMEN	:= cDocNCC
					SE5->E5_RECPAG	:= "R"
					SE5->E5_MOTBX	:= "CMP"
					SE5->E5_PREFIXO	:= SE1->E1_PREFIXO
					SE5->E5_NUMERO	:= SE1->E1_NUM
					SE5->E5_PARCELA	:= SE1->E1_PARCELA
					SE5->E5_TIPO	:= SE1->E1_TIPO
					SE5->E5_CLIFOR	:= SE1->E1_CLIENTE
					SE5->E5_CLIENTE	:= SE1->E1_CLIENTE
					SE5->E5_LOJA	:= SE1->E1_LOJA
					SE5->E5_HISTOR	:= OemToAnsi(STR0001)
					MsUnLock()
					
					RecLock("SE1",.F.)
					SE1->E1_SALDO := SE1->E1_SALDO - nValorCred
					If SE1->E1_SALDO == 0
						SE1->E1_STATUS := "B"
						SE1->E1_BAIXA := dDataBase
					EndIf
					MsUnLock()
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Decrementa a variavel Credito                              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					IF lTroca
						cSE5Documen := ""
						nSE1Recno   := 0
					ENDIF
				Else    
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³A delecao do titulo de credito abaixo corresponde a geracao ³
					//³indevida pela rotina de venda balcao, pois como default, eh ³
					//³gerado para ser abatido junto com o titulo de NCC, mas como ³
					//³nao existe como prever antecipadamente se o usuario deseja  ³
					//³gerar o titulo em NCC, caso o usuario nao escolha, o titulo ³
					//³eh deletado.                                                ³
					//³                                                            ³
					//³04/12/2003                                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
					RecLock( "SE1", .F. )
					dbDelete()
					MsUnlock()
				EndIf
			Else

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³A delecao do titulo de credito abaixo corresponde a geracao ³
				//³indevida pela rotina de venda balcao, pois como default, eh ³
				//³gerado para ser abatido junto com o titulo de NCC, mas como ³
				//³nao existe como prever antecipadamente se o usuario deseja  ³
				//³gerar o titulo em NCC, caso o usuario nao escolha, o titulo ³
				//³eh deletado.                                                ³
				//³                                                            ³
				//³04/12/2003                                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				RecLock( "SE1", .F. )
				dbDelete()
				MsUnlock()
				
			EndIf
		EndIF
		
		// Fim da Geracao da NCC referente Troca
		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca o numero do item na nota fiscal de saida ³
	//³somente se for troca da loja                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTrocLoja

		cItem := StrZero(nItens,2)

		SD2->(DbSetOrder(3))
		SD2->(DBGoTop())

		If SD2->(DbSeek(xFilial("SD2") + SL2->L2_DOC + SL2->L2_SERIE + SL1->L1_CLIENTE + SL1->L1_LOJA))
		
			While SD2->D2_FILIAL == xFilial( "SD2" ) .AND. SD2->D2_DOC == SL2->L2_DOC .AND. ;
			      SD2->D2_SERIE == SL2->L2_SERIE .AND. SD2->D2_CLIENTE == SL1->L1_CLIENTE .AND. ;
			      SD2->D2_LOJA == SL1->L1_LOJA .AND. ! SD2->(EOF())
			
				If SD2->D2_COD == SL2->L2_PRODUTO .AND. SD2->D2_ITEMPV == SL2->L2_ITEM
					cItem := SD2->D2_ITEM
					Exit
				EndIf
				
				SD2->(DBSkip())

			End
			
		Endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Incrementa item da NF ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cItem := StrZero(nItens,2)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera registro de entrada no estoque para  ³
	//³ itens devolvidos.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If lTrocLoja
		nJurosSL1 := SL1->L1_JUROS
	Else
		nJurosSL1 := 0
	EndIf
	
	Reclock( "SD1" , .T. )
	REPLACE SD1->D1_FILIAL	With xFilial()
	REPLACE SD1->D1_COD		With SB1->B1_COD
	REPLACE SD1->D1_UM		With SB1->B1_UM
	REPLACE SD1->D1_GRUPO	With SB1->B1_GRUPO
	REPLACE SD1->D1_TIPO	With "D"

	If !Empty(cNumNota) .And. lTrocLoja
		REPLACE SD1->D1_ITEMORI With cItem
	Endif

	REPLACE SD1->D1_FORMUL	With cFormPro
	REPLACE SD1->D1_ORIGLAN	With "LO"
	REPLACE SD1->D1_TP		With SB1->B1_TIPO

	If Empty(cProxnum)
		REPLACE SD1->D1_NUMSEQ	With ProxNum()
	Else
		REPLACE SD1->D1_NUMSEQ	With cProxnum
	EndIf

	REPLACE SD1->D1_QUANT	With nQuant

	If cPaisLoc == "BRA"
		REPLACE SD1->D1_VUNIT	With nPrcTab + Round((((nPrcTab - (SL2->L2_VALDESC + SL2->L2_DESCPRO)) * nJurosSL1) / 100),nDecs)
		REPLACE SD1->D1_TOTAL	With ((nPrcTab + Round((((nPrcTab - (SL2->L2_VALDESC + SL2->L2_DESCPRO)) * nJurosSL1)/ 100),nDecs)) * nQuant)
	Else
		REPLACE SD1->D1_VUNIT	With nVUnit
		REPLACE SD1->D1_TOTAL	With Round(nVUnit * nQuant,nDecs)
	EndIf

	REPLACE SD1->D1_TES		With cTESTroca
	REPLACE SD1->D1_CF		With cCFTroca
	REPLACE SD1->D1_FORNECE	With SF1->F1_FORNECE
	REPLACE SD1->D1_LOJA	With cLoja
	REPLACE SD1->D1_DOC		With cNumTroc
	REPLACE SD1->D1_EMISSAO	With dDataBase
	REPLACE SD1->D1_DTDIGIT	With dDataBase
	REPLACE SD1->D1_SERIE	With SF1->F1_SERIE
	REPLACE SD1->D1_SERIORI	With cSerAnt
	REPLACE SD1->D1_NFORI	With cNumAnt
	REPLACE SD1->D1_DATORI	With cDatAnt
	REPLACE SD1->D1_NUMCQ	With xNumCaixa()  //para identificacao da origem no resumo de cx.
	REPLACE SD1->D1_LOCAL	With cLocal
	REPLACE SD1->D1_ITEM	With StrZero(nItens,2)
	REPLACE SD1->D1_DESC	With Round(nDesc,nDecimais)
	REPLACE SD1->D1_VALDESC	With nValDesc
	REPLACE SD1->D1_LOTECTL	With cLoteCtl

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Lote somente é gravado qdo trabalhado com SubLote³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Rastro(SB1->B1_COD,"L")
		REPLACE SD1->D1_NUMLOTE	With cNLote    
    EndIf

	nRegSF4 := Sf4->(Recno())
	If cPaisLoc == "BRA"
		If SF4->F4_ICM == "S"
			REPLACE SD1->D1_VALICM	With nValIcms
			REPLACE SD1->D1_PICM	With Lj010VerIcm(nItem,nBaseIcm,cTESTroca,SB1->B1_COD)
			REPLACE SD1->D1_BASEICM	With nBaseIcm
			REPLACE SD1->D1_VALFRE	With nVlrFrete
			REPLACE SD1->D1_SEGURO	With nVlrSeguro
			REPLACE SD1->D1_DESPESA	With nVlrDespesa
		EndIf
		SF4->( DBGoto( nRegSF4 ) )
		If SF4->F4_IPI == "S"
			REPLACE SD1->D1_VALIPI	With nValIPI
			REPLACE SD1->D1_IPI		With SB1->B1_IPI
			REPLACE SD1->D1_BASEIPI	With nBaseIcm
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravar os Impostos baseados no Roteiro de C lculo para os  ³
		//³ paises do MercoSul...                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Lj020GrImp( cTesTroca, nX, 'SD1', '+' ) //Grava Impostos ( valor e base )
		
		aImpVarSD1[1] := nQuant
		aImpVarSD1[2] := nVUnit
		aImpVarSD1[3] := nVUnit * nQuant
		aImpVarSD1[4] := 0
		aImpVarSD1[5] := 0
		aImpVarSD1[6] := {}
		CalcTesxIp( "E", (nVUnit*nQuant), nVUnit,SD1->D1_COD,1,nX,"BALCAO" )
		cNFiscal  := SD1->D1_DOC
		
		// Calcula o Livro
		aLivroF := GetBook( @aGetBook, aImpVarSD1, "V", nTaxaMoeda, aLivroF, "E" )
	EndIf
	     
	//Realiza a gravação dos dados de Pis/COfins/CSLL
	If cPaisLoc == "BRA"
		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Incluido o desconto no parametro 5.                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaFisAdd(SB1->B1_COD, cTESTroca, nQuant,Iif(cPaisLoc == "BRA",nPrcTab+Round((((nPrcTab-(SL2->L2_VALDESC+SL2->L2_DESCPRO))*SL1->L1_JUROS)/100),nDecs),nVUnit), (SL2->L2_VALDESC+SL2->L2_DESCPRO), "", "",, 0, 0, 0, 0, Iif(cPaisLoc == "BRA",((nPrcTab+Round((((nPrcTab-(SL2->L2_VALDESC+SL2->L2_DESCPRO))*SL1->L1_JUROS)/100),nDecs)) * nQuant),Round(nVUnit*nQuant,nDecs)), 0, SB1->(RecNo()))	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso Exista ICM Retido na Fonte e Cliente Tipo "S"olidario Grava e TES Agrupa Solidario no Valor total ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nBsIcmRet := 0
		nVlIcmRet := 0
		If lIcmsSol
			nBsIcmRet 	:= MaFisRet(1,"IT_BASESOL")   
			nVlIcmRet	:= MaFisRet(1,"IT_VALSOL")              
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se as variaveis referentes ao imposto solidario esta nula³
		//³antes de gravar no SD1.                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
        If Empty(nBsIcmRet)
        	nBsIcmRet	:= 0
        EndIf
        
        If Empty(nVlIcmRet)
        	nVlIcmRet	:= 0
        EndIf
                                        
	   	RecLock("SF1",.F.)
			SF1->F1_BRICMS 	+=	nBsIcmRet
			SF1->F1_ICMSRET	+=	nVlIcmRet
	 	SF1->(MsUnlock())
		
		SD1->D1_BRICMS 	:=	nBsIcmRet
		SD1->D1_ICMSRET	:=	nVlIcmRet
		
		
		If !Empty( nScanBsPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_BASEPS2"} ) ) .And. ;
			!Empty( nScanVlPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALPS2"} ) ) .And. ;
			!Empty( nScanAlPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_ALIQPS2"} ) )		
			cCpBasePIS  := aRelImp[nScanBsPis,2]
			cCpValPIS   := aRelImp[nScanVlPis,2]
			cCpAlqPIS   := aRelImp[nScanAlPis,2]		
		EndIf
		
		If !Empty( nScanBsCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_BASECF2"} ) ) .And. ;
			!Empty( nScanVlCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALCF2"} ) ) .And. ;
			!Empty( nScanAlCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_ALIQCF2"} ) )
			cCpBaseCOF  := aRelImp[nScanBsCOF,2]
			cCpValCOF   := aRelImp[nScanVlCOF,2]
			cCpAlqCOF   := aRelImp[nScanAlCOF,2] 
		EndIf		
		                                     
		nItemFis += 1
		SD1->&( cCpBasePIS ) := MaFisRet(nItemFis,"IT_BASEPS2")
		SD1->&( cCpValPIS  ) := MaFisRet(nItemFis,"IT_VALPS2")
		SD1->&( cCpAlqPIS  ) := MaFisRet(nItemFis,"IT_ALIQPS2")
		
		SD1->&( cCpBaseCOF ) := MaFisRet(nItemFis,"IT_BASECF2")
		SD1->&( cCpValCOF  ) := MaFisRet(nItemFis,"IT_VALCF2")
		SD1->&( cCpAlqCOF  ) := MaFisRet(nItemFis,"IT_ALIQPS2")
	EndIf
	
	If ExistBlock( "LJ020SD1" )
		ExecBlock( "LJ020SD1" , .F. , .F. , {nQuant,nPrcTab,nVUnit} )
	EndIf
	
	MsUnlock()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva os dados da tabela SD1 para futura utilizacao      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArea := GetArea()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para a grava‡Æo do campo SD1->D1_TES    ³
	//³  com um TES diferente do parametro MV_TESTROCA           ³
	//³  Solicitado pelo cliente Praticca.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If lLjD1Tes
		ExecBlock("LJD1TES",.F.,.F.)
	EndIf
	
	If lLjD1Tsp
		cTESTroca :=ExecBlock("LJD1TSP",.F.,.F.,{cNumNota,cSerie})
	Else
		cTESTroca:= LJ020ICMSSOL(aCols_1[nx][nPosTes])[2]
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravo no L2_ITEMSD1 o conteudo do campo D1_NUMSEQ para o correto relacionamento das tabelas SD1 e SL2     ³
	//³no relatorio de devoluçoes lojr075 (O SL2 ja esta posicionado ). Alteracao somente para troca da loja     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SL2->(FieldPos("L2_ITEMSD1")) > 0 .AND. lGrvItemSd1 .AND. lTrocLoja
		DbSelectArea( "SL2" )
		RecLock("SL2",.F.)
		SL2->L2_ITEMSD1 := SD1->D1_NUMSEQ
		MsUnlock()
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua estorno do estoque. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea( "SF4" )
	DbSeek( xFilial("SF4") + cTESTroca )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura a Area da tabela SD1                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RestArea( aArea )
	If SF4->F4_ESTOQUE == "S"
		
		If !EMPTY( SD1->D1_COD )
			
			aArea := GetArea()
			
			aCusto := { {SD1->D1_TOTAL-IIF(SF4->F4_IPI=="R",0,SD1->D1_VALIPI)+SD1->D1_ICMSCOM-If(SF4->F4_INCSOL=="S",SD1->D1_ICMSRET,0),;
			SD1->D1_VALIPI,;
			SD1->D1_VALICM,;
			SF4->F4_CREDIPI,;
			SF4->F4_CREDICM,;
			SD1->D1_NFORI,;
			SD1->D1_SERIORI,;
			SD1->D1_COD,;
			SD1->D1_LOCAL,;
			SD1->D1_QUANT,;
			IIf(SF4->F4_IPI=="R",SD1->D1_VALIPI,0) ,;
			SF4->F4_CREDST,;
			SD1->D1_ICMSRET,;
			SF4->F4_PISCOF,;
			SF4->F4_PISCRED,;
			0 } }
			
			aCustoEnt := RetCusEnt(, aCusto, "D")
			
			RestArea( aArea )
			
			DbSelectArea("SD1")
			For nPos := 1 TO LEN( aCustoEnt )
				RecLock("SD1",.F.)
				SD1->D1_CUSTO  := aCustoEnt[ nPos ][1]
				SD1->D1_CUSTO2 := aCustoEnt[ nPos ][2]
				SD1->D1_CUSTO3 := aCustoEnt[ nPos ][3]
				SD1->D1_CUSTO4 := aCustoEnt[ nPos ][4]
				SD1->D1_CUSTO5 := aCustoEnt[ nPos ][5]
				MsUnlock()
			Next nPos
		EndIf
		
		B2AtuComD1(1)
		SB2->(MsUnlock())
	EndIf
	
EndIf
     
If MaFisFound("NF") .And. cPaisLoc == "BRA"
	MaFisEnd()
EndIf

Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj020Itens³ Autor ³ Fernando Godoy        ³ Data ³ 13.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Separa linha do aCols_1 em vari veis formando a registro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj020Itens(   aCols_1   ,   aHeader_1   ,   nx   ,   cTabela   ,;
					   cTes      ,   cLocal      ,cProduto,   cDescri   ,;
					   nVlrItem  ,   nDesc       ,nValDesc,   cUM       ,;
					   cCF       ,   cItem       ,nQuant  ,   nVunit    ,;
					   nValIcms  ,   nValIss     ,nValIpi ,   nBaseIcm  ,;
    				   cNSerie   ,   cLotectl    ,cNLote  ,   cLocaliz  ,;
    				   nDescPro  ,   nPrcTab    )


Local nPosProduto 	:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_PRODUTO" } )
Local nPosValIcm 	:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_VALICM" } )
Local nPosTes 		:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_TES" } )
Local nPosItem 		:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_ITEM" } )
Local nPosValISS	:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_VALISS" } )
Local nPosValIPI	:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_VALIPI" } )
Local nPosBaseICM	:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_BASEICM" } )
Local nPosTabela	:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_TABELA" } )
Local nPosLocal		:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_LOCAL" } )
Local nPosDescri	:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_DESCRI" } )
Local nPosQuant		:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_QUANT" } )
Local nPosVrUnit	:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_VRUNIT" } )
Local nPosVlrItem	:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_VLRITEM" } )
Local nPosUM		:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_UM" } )
Local nPosDesc		:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_DESC" } )
Local nPosValdesc	:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_VALDESC" } )
Local nPosCF		:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_CF" } )
Local nPosNSerie	:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_NSERIE" } )
Local nPosLoteCTL	:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_LOTECTL" } )
Local nPosNLote		:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_NLOTE" } )
Local nPosLocaliz	:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_LOCALIZ" } )
Local nPosPrcTab	:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_PRCTAB" } )
Local nPosDescPro	:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_DESCPRO" } )
Local nPosValFre	:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_VALFRE" } )
Local nPosSeguro	:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_SEGURO" } )
Local nPosDespesa	:= aScan( aHeader_1, { |x| Alltrim(Upper(x[2]))=="L2_DESPESA" } )

cProduto := aCols[nx][nPosProduto]
cTes	 := aCols[nx][nPosTes]
cItem    := aCols[nx][nPosItem]
nValIss  := aCols[nx][nPosValISS]
nValIpi  := aCols[nx][nPosValIPI]
nBaseIcm := aCols[nx][nPosBaseICM]
nValIcms := aCols[nx][nPosValIcm]

SF4->(DbSetOrder(1))	
SF4->(DbSeek(xFilial("SF4")+aCols[nx][nPosTes]))

If nPosValFre > 0 .And. nPosSeguro > 0 .And. nPosDespesa > 0 .And. ( aCols[nx][nPosValFre] + aCols[nx][nPosSeguro] + aCols[nx][nPosDespesa] ) > 0 .And. SF4->F4_ICM == "S"
	nBaseIcm := aCols[nx][nPosVlrItem]
	If SF4->F4_INCIDE == "S"
		nBaseIcm += aCols[nx][nPosValIPI]
	EndIf
	nBaseIcm *= Iif(SF4->F4_BASEICM > 0, SF4->F4_BASEICM/100, 1)
	nValIcms := NoRound( nBaseIcm * AliqIcms("N","S",SA1->A1_TIPO,"I") / 100, 2 )
Endif
cTabela  := aCols[nx][nPosTabela]
cLocal   := aCols[nx][nPosLocal]
cDescri	 := aCols[nx][nPosDescri]
nQuant	 := aCols[nx][nPosQuant]
nVunit	 := aCols[nx][nPosVrUnit]
nVlrItem := aCols[nx][nPosVlrItem]
cUM	     := aCols[nx][nPosUM]
nDesc    := aCols[nx][nPosDesc]
nValDesc := aCols[nx][nPosValDesc]
cCF	     := aCols[nx][nPosCF]
cNSERIE  := aCols[nx][nPosNSerie]
If !__lPyme
	cLOTECTL := aCols[nx][nPosLoteCTL]
	cNLOTE	 := aCols[nx][nPosNLote]
	cLocaliz := aCols[nx][nPosLocaliz]
Else
	cLOTECTL := Space(Len(SLR->LR_LOTECTL))
	cNLOTE	 := Space(Len(SLR->LR_NLOTE))
	cLocaliz := Space(Len(SLR->LR_LOCALIZ))
EndIf
nPrcTab  := aCols[nx][nPosPrcTab]
nDescPro := aCols[nx][nPosDescPro]


Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj020Total³ Autor ³ Fernando              ³ Data ³ 12.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Soma as Mercadorias Trocadas.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³                         ATUALIZACOES SOFRIDAS                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³           Motivo da Alteracao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Magh Moura  ³18.08.05³085345³Somado no valor da mercadoria nMerc e no  ³±±
±±³            ³        ³      ³valor da Troca nTroc o campo L2_ICMSRET   ³±±
±±³            ³        ³      ³(refer. a ICMS Solidario).                ³±±
±±³Magh Moura  ³13.10.05³Della ³Soma no valor da mercadoria nMerc o campo ³±±
±±³            ³        ³Via   ³L2_ICMSRET somente se na TES o campo      ³±±
±±³            ³        ³      ³F4_INCSOL for diferente de "N". Chama a   ³±±
±±³            ³        ³      ³funcao LJ020ICMSSol para validar.         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj020Total()
Local nI
Local nC
Local nE

nTroc   := 0
nMerc   := 0
nTItens := 0
For nI:=1 To Len(aCols) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o registro não estiver Deletado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !aCols[nI][nUsado+1]
	    nTItens ++                    
		If cPaisLoc == "BRA"
			If ( nPosTotal > 0 .AND. nPosValIpi > 0 ) //JOSELUCAS
				nMerc+= aCols[nI][nPosTotal] + aCols[nI][nPosValIpi] + Iif(LJ020ICMSSol(aCols[nI,nPosTes])[1],aCols[nI][nPosIcmsRet],0)
				nTroc+= aCols[nI][nPosTotal] + aCols[nI][nPosValIpi] + Iif(LJ020ICMSSol(aCols[nI,nPosTes])[1],aCols[nI][nPosIcmsRet],0)
			ElseIf ( nPosTotal > 0 .AND. nPosIcmsRet > 0)
				nMerc+= aCols[nI][nPosTotal] + Iif(LJ020ICMSSol(aCols[nI,nPosTes])[1],aCols[nI][nPosIcmsRet],0)
				nTroc+= aCols[nI][nPosTotal] + Iif(LJ020ICMSSol(aCols[nI,nPosTes])[1],aCols[nI][nPosIcmsRet],0)					
			EndIf	                                             
			
		Else	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Considerar todos os impostos que incidem no Total da Nota ³
			//³ baseando se na Roteiro Amarracao Tes X Impostos.          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMerc+=aCols[nI][nPosTotal]
			nTroc+=aCols[nI][nPosTotal]
			cTesImp := aCols[nI][nPosTes]
			aImposto := DefImposto( cTesImp )
			For nC := 1 To Len(aImposto)
				cImposto := aImposto[nC][2]
				For nE := 1 To Len(aHeader)
					If Subs(aHeader[nE][2],4,7) == cImposto .And. aImposto[nC][3] == "1"  //Determina se imposto incide ou nao na nota
						nMerc += aCols[nI][nE]
						nTroc += aCols[nI][nE]
					EndIf	
				Next nE
			Next nC
		EndIf
	EndIf
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ajusta o valor da troca ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTroc += ( aFrete[1] + aFrete[2] + aFrete[3] )
nTroc -= LJ020SumRet()

oMerc:Refresh()
oTroc:Refresh()      
oTItens:Refresh()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj020ICMS ³ Autor ³ Fernando              ³ Data ³ 12.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula o ICMS                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parƒmetro³ 1 - Valor total da Base do Icms                            ³±±
±±³          ³ 2 - Valor total do Icms                                    ³±±
±±³          ³ 3 - Total da troca                                         ³±±
±±³          ³ 4 - Indica se a nota ja existe ou nao                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj020ICMS(nBicms,nVlrIcms,nTotTroca)

Local nI 		:= 0
Local nPerDesc  := 0
Local nConst	:= 0
nDescont	    := 0	
For nI:=1 to Len(aCols)
	If !aCols[nI][nUsado+1] 
		nDescont += aCols[nI][nPosValDes]
		nBicms	 += aCols[nI][nPosBsIcms]
		nVlrIcms += aCols[nI][nPosValIcm]
	EndIf
Next nI

nConst  := 100 * nDescont
nPerDesc:= nConst / nTroc

If !lExistNota
	nBicms:=nBicms - nDescont
EndIf

If nDescont > 0
	nVlrIcms := nVlrIcms - ((nVlrIcms * nPerDesc) / 100 )
EndIf

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj020VALNF³ Autor ³ Wagner Xavier         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida nota informada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LojA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj020VALNF()
Local xAlias
Local lRet:=.T.
Local nRec

xAlias := Alias( )
DbSelectArea("SL1")
nRec := RecNo( )
DbSetOrder(2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a nota ja existe no SF1  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	DbSelectArea("SF1")
	DbSetOrder(1)
	If (DbSeek(xFilial()+cNumTroc+cSerieDev+cCodCli+cLojaTrc))
		Help(" ",1,"LJ010NOTA")
		lRet := .F.
	EndIf
EndIf

DbSelectArea("SL1")
dbGoTo( nRec )
DbSetOrder( 1 )
DbSelectArea(xAlias)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A020Fim() ³ Autor ³ Adriano Sacomani      ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Encerra a Tela de Troca e volta para o Browse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LojA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A020Fim(oDlg1)
DbSelectArea("SL1")
DbSetOrder(2)
oDlg1:End()
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A020Fim() ³ Autor ³ Adriano Sacomani      ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Encerra a Tela de Troca e volta para o Browse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LojA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A020FimX(oDlg1)
DbSelectArea("SL1")
DbSetOrder(2)
lFim:=.t.
lDevoluca:=.f.
oDlg1:End()
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ Lj020GrImp º Autor ³      Nava       º Data ³  31/05/01   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Grava os impostos variaveis (Localizacoes)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ Lj020GrImp( cTes, nLine, cAlias, cOperator )              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametro ³ cTes 		- Numero da Tes                               ³±±
±±³           ³ nLine		- Numero da Linha do Acols                    ³±±
±±³           ³ cAlias		- Nome do Alias que irah ser gravado          ³±±
±±³           ³ cOperator 	- '+' -> Acrescenta ao valor existente        ³±±
±±³           ³                 - '-' -> Diminui do valor existente       ³±±
±±³           ³         	- '=' -> Substitui o valor existente          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno   ³ NIL                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SigaLoja - Localizacoes                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj020GrImp( cTes, nLine, cAlias, cOperator )

Local nI
Local nPosL2Base :=0
Local nPosL2Valor:=0
Local cCampoBase
Local cCampoValor
Local nPosBase
Local nPosValor
Local cBase
Local cValor
Local nDecs     := MsDecimais(IIf(Type("nMoedaTr")=="N",nMoedaTr,1))

For nI := 1 TO Len( aPosImps )
	If Substr(aPosImps[nI][1],4,6) = "BASIMP" 
	   cBase := Substr( aPosImps[nI][1], 3 ,8 )
	   nPosL2Base	:= Ascan( aCampos, "L2" + cBase  )
    ElseIf Substr(aPosImps[nI][1],4,6) = "VALIMP" 
	   cValor := Substr( aPosImps[nI][1],3 ,8 )
	   nPosL2Valor	:= Ascan( aCampos, "L2" + cValor )
    Endif	

    If nPosL2Base > 0 .AND. nPosL2Valor > 0
	   cCampoBase	:= Subst(cAlias, 2 ) + cBase
	   cCampoValor	:= Subst(cAlias, 2 ) + cValor
   	   If ( nPosBase := ( cAlias )->( FieldPos( cCampoBase ) ) ) > 0 .AND. ( nPosValor := ( cAlias )->( FieldPos( cCampoValor ) ) ) > 0
		  If (aCols[nLine][nPosL2Base] > 0) .and. (aCols[nLine][nPosL2Valor] > 0)
			 Do Case
				Case cOperator == '='
					( cAlias )->( FieldPut( nPosBase,	aCols[nLine][nPosL2Base] ) )
					( cAlias )->( FieldPut( nPosValor,Round(aCols[nLine][nPosL2Valor],nDecs) ) )
				Case cOperator == '+'
					( cAlias )->( FieldPut( nPosBase, FieldGet( nPosBase )  + aCols[nLine][nPosL2Base] ) )
					( cAlias )->( FieldPut( nPosValor,FieldGet( nPosValor ) + Round(aCols[nLine][nPosL2Valor],nDecs) ) )
				Case cOperator == '-'
					( cAlias )->( FieldPut( nPosBase, FieldGet( nPosBase )  - aCols[nLine][nPosL2Base] ) )
					( cAlias )->( FieldPut( nPosValor,FieldGet( nPosValor ) - Round(aCols[nLine][nPosL2Valor],nDecs) ) )
			 EndCase
		     nPosL2Base :=0
             nPosL2Valor:=0 
		  EndIf
	   EndIf
	EndIf
Next nI

Return .T.

Function Lj020Saida (cDocumen,nRecno)
cSE5Documen := cDocumen
nSE1Recno := nRecno
Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ LJ020AltStatus() ³ Autor ³ Fabiano Banin      ³ Data ³ 01/07/2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Altera o status do orçamento na exclusão da devolução.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Chamado pelo fonte MATA103X.PRX                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ020AltStatus(cPFilial, cPSerie, cPDoc, cPProduto, cPItem)

Local aArea := GetArea()

SL2->(DbSetOrder(3))
SL2->(DBGoTop())
	
If SL2->(DbSeek(cPFilial + cPSerie + cPDoc + cPProduto))
	
	While SL2->L2_FILIAL == cPFilial .AND. SL2->L2_SERIE == cPSerie .AND. SL2->L2_DOC == cPDoc .AND. ;
	      SL2->L2_PRODUTO == cPProduto .AND. ! SL2->(EOF())

		If SL2->L2_ITEM == cPItem .AND. SL2->L2_STATUS == "D"

			RecLock("SL2", .F.)
			SL2->L2_STATUS := " "
			Exit

		EndIf
            
		SL2->(DBSkip())
		
	End
            
EndIf

RestArea(aArea)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ LJ020SumRet º Autor ³ Fabiano Banin      º Data ³ 14/07/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Soma os valores de retenções (PIS/COFINS/CSLL).              º±±
±±º          ³                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ020SumRet(nImp)

Local nRet        := 0
Local nPosVlrItem := aScan(aHeader, { |x| Alltrim(Upper(x[2])) == "L2_VLRITEM" })

Default nImp := 0

aEval(aRetencoes, { |x,y| nRet += If( ! x[Len(x)], If( nImp == 0, ( ( ( aCols[y,nPosVlrItem] * x[01] ) / 100 ) + ;
                                                                    ( ( aCols[y,nPosVlrItem] * x[02] ) / 100 ) + ;
                                                                    ( ( aCols[y,nPosVlrItem] * x[03] ) / 100 ) + ;
                                                                    ( ( aCols[y,nPosVlrItem] * x[04] ) / 100 ) ), ;
                                                                    ( ( aCols[y,nPosVlrItem] * x[nImp] ) / 100 ) ), 0 ) })

Return nRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ020ICMSSolºAutor  ³Magh Moura          º Data ³  10/13/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se a TES Agrega o valor do icms solidario no totalº±±
±±º          ³ da Nota ou Nao.                                            º±±
±±º          ³ Se lRet = .T. Soma o Valor do ICMS Solidario no Total      º±±
±±º          ³ da Nota, caso contrario nao soma.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parƒmetro³ 1 - TES de SAIDA                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function LJ020ICMSSol(cTes)

Local aAreaSF4 := SF4->(GetArea())
Local aArea    := GetArea()             
Local cTESParam:= GetNewPar("MV_TESTROCA","132") 

Local aRet     := {.T.,GetNewPar("MV_TESTROCA","132")}
                           
DbSelectArea("SF4")
DbSetOrder(1)
If DbSeek(xFilial("SF4")+cTes)
	If !Empty(SF4->F4_TESDV)
		If DbSeek(xFIlial("SF4")+SF4->F4_TESDV)
			aRet[2] := SF4->F4_CODIGO
			If SF4->F4_INCSOL == "N"
			   aRet[1] := .F.
			Endif
		Else	
			If DbSeek(xFIlial("SF4")+cTESParam)			               
				If SF4->F4_INCSOL == "N"
				   aRet[1] := .F.
				Endif
			Endif	
		Endif
	Else
		If DbSeek(xFIlial("SF4")+cTESParam)			               
			If SF4->F4_INCSOL == "N"
			   aRet[1] := .F.
			Endif
		Endif	
	Endif
Else
	If DbSeek(xFIlial("SF4")+cTESParam)			               
		If SF4->F4_INCSOL == "N"
		   aRet[1] := .F.
		Endif
	Endif	                                                    
Endif
	
RestArea(aAreaSF4)
RestArea(aArea)

Return (aRet)
