#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA010C.CH"

#DEFINE _PICTURE		16

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Este Log é um recurso a ser habilitado pelo departamento de desenvolvimento para averigua-³
//³ção de possíveis problemas de transações TEF.                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE LOG_TEF 	IIf( File(GetClientDir()+"SIGALOJA.INI") .AND. ;
                         GetPvProfString("Logs TEF","Habilita","01",GetClientDir()+"SIGALOJA.INI") == "01", ;
                         "\AUTOCOM\TEF"+cEmpAnt+cFilAnt+"\", ;
                         "" )

//Localizacoes 23/01/2002
//Copia dos diversos arrays utilizados para o calculo dos impostos variaveis...
//Venda Balcao e Rapida
STATIC aImpsTmp    
STATIC aImpSF2Tmp
STATIC aImpDupTmp 
STATIC nTmpLiq         
STATIC nValTotTmp
STATIC nValBaseTmp

//Front Office
STATIC aImpTmpSL1 
STATIC aImpTmpSL2 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis estaticas utilizadas para o controle da exibicao³
//³da tela de permissao de desconto                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static __lAplicDesc	:= .F.				//Variavel logica de aplicacao do desconto
Static __nDescPer	:= 0				//Variavel com a porcentagem de desconto
Static __nDescLoj	:= 0				//Variavel com o valor de desconto


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj010Receb³ Autor ³ Vendas Clientes       ³ Data ³		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ao mudar o folder, inicializa opcoes na tela 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Receb(	nOption     , oCombo      , cCombo     , aCondicoes, oReceb    , ;
						oEntrada    , oNumParcelas, oFinanciado, nValorBase, cForma    , ;
						nEntrada    , nFinanciado , oTxJuros   , oIntervalo, nParcelas , ;
						nIntervalo  , lCalcEntrada, nEntrAnt   , nEntrOrig , aParcelas , ;
						nNumParcelas, nCondicao   , cCondicao  , lCheck3   , oCheck3   , ;
						nLiq        , oVlrLiq1    , oVlrLiq2   , lFirstJur , nTipoJur  , ;
						cComboAnt2  , nTxDescon   , oTxDescon  , lUsouFator, cAdmFator , ;
						oFolder     , nDescLoj    , nDescPer   , oVlrImpos , cTipoJuros, ;
						oTipoJuros  , oVlrTotVen )

Local n
Local nX
Local nY
Local nZ
Local lInfChq 		:= SuperGetMV("MV_INFCHEQ")
Local nCMC7CHQ 		:= SuperGetMV("MV_CMC7CHQ")
Local nValorTotal 	:= 0
Local nPosVlr		:= aScan( aHeader, {|x| Alltrim(Upper(x[2]))=="L2_VLRITEM" } )

If nOption == 3
	nFolder := 3
	If Len(aReceb) <> Len(aPgtos)
		aReceb := {}
		For n := 1 To Len(aPgtos)
			AaDD(aReceb,{aPgtos[n][1],aPgtos[n][2],aPgtos[n][3],CriaVar("L4_ADMINIS"),;
			CriaVar("L4_NUMCART"),CriaVar("L4_AGENCIA"),CriaVar("L4_CONTA"),CriaVar("L4_RG"),;
			CriaVar("L4_TELEFON"),.F.,aPgtos[n][4],CriaVar("L4_MESACTA"),CriaVar("L4_ANOACTA"),;
			CriaVar("L4_TIPOCHQ"),CriaVar("L4_CGC"),CriaVar("L4_NOMECLI"),CriaVar("L4_SERCHQ"),;
			CriaVar("L4_COMP")})
		Next n
	Else
		For nX := 1 to Len(aPgtos)
			For nY := 1 to 3
				If aPgtos[nX][nY] <> aReceb[nX][nY]
					LimpaArray(nX)
					For nZ := 1 to 3
						aReceb[nX][nZ] := aPgtos[nX][nZ]
					Next nZ
				Endif
			Next nY
			aReceb[nX][11] := aPgtos[nX][4]
		Next nX
	Endif
	
	*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	*³ Chama janela de dados dos t¡tulos ³
	*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj010DadPg(oReceb,,.F.,oCheck3,@lCheck3,@lUsouFator,cAdmFator,@oFolder)

	oReceb:SetArray( aReceb )
	oReceb:bLine := {|| {aReceb[oReceb:nAt,1],;
	Transform(aReceb[oReceb:nAt,2],PesqPict("SL1","L1_VLRTOT",_PICTURE,aReceb[oReceb:nAt,11])),;
	aReceb[oReceb:nAt,3],;
	aReceb[oReceb:nAt,4],;
	aReceb[oReceb:nAt,5],;
	aReceb[oReceb:nAt,6],;
	aReceb[oReceb:nAt,7],;
	aReceb[oReceb:nAt,8],;
	aReceb[oReceb:nAt,9],;
	aReceb[oReceb:nAt,11],;
	aReceb[oReceb:nAt,12],;
	aReceb[oReceb:nAt,13],;
	aReceb[oReceb:nAt,14],;
	aReceb[oReceb:nAt,15],;
	aReceb[oReceb:nAt,16],;
	aReceb[oReceb:nAt,17],;
	aReceb[oReceb:nAt,18]} }
	oReceb:Refresh()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso informa dados do Cheque ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lInfChq
		For n := 1 to Len(aReceb)
			If cSimbCheq $ aReceb[n][3] .AND. Iif(nCMC7CHQ == 1,!Empty(aReceb[n][4]),.T.)
				If lUsaCH
					oCheck3:Enable()
					lCheck3:= .T.
					oChecK3:Refresh()
				Endif
				Exit
			Else
				lCheck3:= .F.
				oCheck3:Disable()
				oChecK3:Refresh()
			Endif
		Next n
	Else
		lCheck3:= .F.
		oCheck3:Disable()
		oChecK3:Refresh()
	Endif
	
	lFirst3 := .F.
	
ElseIf nOption == 2
	
	If nOption == 2 .AND. lFirst2 .AND. !lCarregouSL4
		nValorTotal := 0
		aEval( aCols, {|x| nValorTotal += x[nPosVlr] })
		If (nValorTotal + nVlrAcrs - nVlrDesc) <> (nLiq + nVlrAcrs)	
			lj010box(@nEntrada,@nParcelas,@nIntervalo,@nValorBase,;
			oEntrada,oTxJuros,oNumParcelas,oIntervalo,;
			@aCondicoes,@nFinanciado,@cForma,oFinanciado,;
			@lCalcEntrada,@nEntrAnt,@nEntrOrig,@aParcelas,@cCombo,oCombo,;
			@nNumParcelas,@nLiq,@oVlrLiq1,@oVlrLiq2,@lFirstJur,@nTipoJur,;
			@nCondicao,@cCondicao,@cComboAnt2,@nTxDescon,oTxDescon,;
			nDescLoj,nDescPer,oVlrImpos,cTipoJuros,oTipoJuros,oVlrTotVen)
		Endif
	Endif
	
	nFolder := 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Refresh de dados do folder 2 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oEntrada:Refresh()
	oFinanciado:Refresh()
	oTxJuros:Refresh()
	oNumParcelas:Refresh()
	oIntervalo:Refresh()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o array aPgtos esta vazio, p/ utilizar a Cod. Pag padrao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aPgtos[1][1])
		aPgtos[1][1] := dDataBase
		aPgtos[1][2] := nValorBase                             
		aPgtos[1][4] := nMoedaCor
        If cPaisLoc <> "BRA"
			aPgtos[1][3] := If(!(SuperGetMV("MV_FORMPAD")$"CC/CD/CH/VA/FI"),SuperGetMV("MV_SIMB"+Str(nMoedaCor,1)),SuperGetMV("MV_FORMPAD"))
			aPgtos[1][5] := dDataBase          
		Else
			aPgtos[1][3] := SuperGetMV("MV_FORMPAD")
		Endif
	Endif
	oPgtos:SetArray( aPgtos )
    If cPaisLoc == "BRA"
		oPgtos:bLine 	:= {||{aPgtos[oPgtos:nAt,1],;
						Transform(aPgtos[oPgtos:nAt,2],PesqPict("SL1","L1_VLRTOT",_PICTURE,aPgtos[oPgtos:nAt,4])),;
						aPgtos[oPgtos:nAt,3],aPgtos[oPgtos:nAt,4]}}
	Else
		oPgtos:bLine	:= {||{DtoC(aPgtos[oPgtos:nAt,1]),;
						Transform(aPgtos[oPgtos:nAt,2],PesqPict("SL1","L1_VLRTOT",_PICTURE,aPgtos[oPgtos:nAt,4])),;
						aPgtos[oPgtos:nAt,3],aPgtos[oPgtos:nAt,4],DtoC(aPgtos[oPgtos:nAt,5])}}
	Endif
	oPgtos:Refresh()
	aParcTef := aClone(aPgtos)
Else
	nFolder := 1
Endif

If oBtnTab <> NIL
	If nFolder <> 1
		oBtnTab:Disable()
		oBtnEst:Disable()
		oBtnAut:Disable()
		oBtnReserva:Disable()
		oBtnConsRes:Disable()
		Set Key 1 to
		Set Key 5 to
		Set Key 16 to
	Else
		// Para o estado do Amazonas, Minas Gerais e Sao Paulo nao e permitido 
		// alterar o preco do produto no momento da venda para quem usa ECF
		If LjAnalisaLeg(5)[1] .AND. lFiscal
			oBtnTab:Disable()
	    Else
			oBtnTab:Enable()
			SetKey(16,oBtnTab:bAction)
		Endif 
		oBtnEst:Enable()
		oBtnAut:Enable()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³So habilita o botao das reservas se existir alguma loja cadastrada.    ³
		//³e se estiver no primeiro folder 	                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SLJ->(dbGoTop())
		If ! SLJ->(Eof())
			oBtnConsRes:Enable()
			oBtnReserva:Enable()
		Endif
		SetKey(1,oBtnAut:bAction)
		SetKey(5,oBtnEst:bAction)
	Endif
	oBtnTab:Refresh()
	oBtnEst:Refresh()
	oBtnAut:Refresh()
	oBtnReserva:Refresh()
	oBtnConsRes:Refresh()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe pagamento em CH, p/ preencher o CheckBox ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFirst3 .AND. nFolder == 3
	For n:=1 to Len(aPgtos)
		If lInfChq
			If Alltrim(aPgtos[n][3]) == cSimbCheq .AND. Iif(nCMC7CHQ == 1,!Empty(aReceb[n][4]),.T.)
				If lUsaCH
					lCheck3:=.T.
					oCheck3:Enable()
					oCheck3:Refresh()
				Endif
				Exit
			Else
				lCheck3:=.F.
				oCheck3:Disable()
				oCheck3:Refresh()
			Endif
		Else
			lCheck3:= .F.
			oCheck3:Disable()
			oChecK3:Refresh()
		Endif
	Next n
Endif

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Refresh na Entrada e no Vlr. Financiado ³
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEntrada:Refresh()
oFinanciado:Refresh()

nParcelas := Len(aPgtos)

If nOption == 2
	lFirst2 := .F.
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³lj010Paint³ Autor ³ Pilar S Albaladejo    ³ Data ³		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pinta bitmap e totais ao escolher o produto na getdados	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA010.PRW 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010Paint(oBmp,oDesc,cDesc,nVlrTot,nVlrItens,nVlrLiq,nValorBase,;
nLiq,nDescloj,nPos22,oVlrTot,oVlrItens,oVlrLiq,oVlrLiq1,oVlrLiq2,oDescPer,;
nDescPer,oDescont,lMudouLin,nLinIni,cFirstProd,lFirstProd,lVazio,;
lUsaFoto,nDifDesc,oVlrTotVen,nVlrIpi)

Local nCol		 := aPosicoes[9][2]
Local nRec		 := SB1->(Recno())
Local nRowPos	 := n
Local lNothing  := .F.
Local cAlias	 := Alias()

*** Grade
Local nGrade	  := Ascan(aCampos,"L2_GRADE")
Local cGrade	  := If(!__lPyme,aCols[n][nGrade],"N")

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Caso utiliza foto de produto mostra na tela ³
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lUsaFoto
	If lFirstProd
		cFirstProd := aCols[nRowPos][nCol]
		lFirstProd := .F.
	Endif
	
	*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	*³ Verifica se Mudou a Linha para n„o re-pintar a foto ³
	*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lVazio
		If nRowPos <> nLinIni
			nLinIni	  := nRowPos
			lMudouLin  := .T.
			lFirstProd := .T.
		Else
			lMudouLin  := .F.
			lFirstProd := .F.
			If Empty(aCols[nRowPos][nCol])
				lFirstProd := .T.
			Endif
		Endif
	Endif
	
	If lMudouLin .OR. Alltrim(aCols[nRowPos][nCol]) <> Alltrim(cFirstProd);
		.OR. lVazio
		cFirstProd := aCols[nRowPos][nCol]
		lVazio := .F.
		If !Empty(aCols[nRowPos][nCol])
			If cGrade == "S"
				dbSelectArea("SB4")
				dbSetOrder(1)
				If (MsSeek(xFilial("SB4") + aCols[nRowPos][nCol]))
					If !Empty(SB4->B4_BITMAP)
						oBmp:lVisible := .T.
						ShowBitMap(oBmp,SB4->B4_BITMAP,"SEMFOTO")
						cDesc := SB4->B4_DESC
						oDesc:Refresh(.T.)
						dbGoto(nRec)
					Else
						oBmp:lVisible := .T.
						ShowBitMap(oBmp,"SEMFOTO")
						cDesc := SB4->B4_DESC
						oDesc:Refresh()
						oBmp:Refresh(.T.)
					Endif
					dbSelectArea(cAlias)
				Else
					lNothing := .T.
				Endif
			Else
				dbSelectArea("SB1")
				dbSetOrder(1)
				If (MsSeek(xFilial("SB1") + aCols[nRowPos][nCol]))
					If !Empty(SB1->B1_BITMAP)
						oBmp:lVisible := .T.
						ShowBitMap(oBmp,SB1->B1_BITMAP,"SEMFOTO")
						cDesc := SB1->B1_DESC
						oDesc:Refresh(.T.)
						dbGoto(nRec)
					Else
						oBmp:lVisible := .T.
						ShowBitMap(oBmp,"SEMFOTO")
						cDesc := SB1->B1_DESC
						oDesc:Refresh()
						oBmp:Refresh(.T.)
					Endif
					dbSelectArea(cAlias)
				Else
					lNothing := .T.
				Endif
			Endif
		Else
			lNothing := .T.
		Endif
		If lNothing
			oBmp:lVisible := .T.
			ShowBitMap(oBmp,"LOJAWIN")
			cDesc := STR0002				// SIGALOJA   PARA	 WINDOWS
			oDesc:Refresh()
			oBmp:lVisible := .T.
			oBmp:Refresh(.T.)
			lVazio := .T.
			Return .T.
		Endif
	Endif
Else
	If !Empty(aCols[nRowPos][nCol])
		If cGrade == "S"
			dbSelectArea("SB4")
			dbSetOrder(1)
			If (MsSeek(xFilial("SB4") + aCols[nRowPos][nCol]))
				cDesc := SB4->B4_DESC
				oDesc:Refresh(.T.)
				dbSelectArea(cAlias)
			Else
				lNothing := .T.
			Endif
		Else
			dbSelectArea("SB1")
			dbSetOrder(1)
			If (MsSeek(xFilial("SB1") + aCols[nRowPos][nCol]))
				cDesc := SB1->B1_DESC
				oDesc:Refresh(.T.)
				dbSelectArea(cAlias)
			Else
				lNothing := .T.
			Endif
		Endif
	Else
		lNothing := .T.
	Endif
	If lNothing
		cDesc := STR0002			  // SIGALOJA	 PARA 	WINDOWS
		oDesc:Refresh()
		Return .T.
	Endif
Endif

nVlrItens := 0
AEval(aCols, {|x| If(!x[Len(x)], nVlrItens++,)})
oVlrItens:Refresh()

SayWinSub(@nVlrTot,@nVlrLiq,@nValorBase,@nLiq,@nDescloj,nPos22,;
@oVlrTot,oVlrLiq,oVlrLiq1,oVlrLiq2,oDescPer,@nDescPer,oDescont,;
"PAINT",@nDifDesc,oVlrTotVen,@nVlrIpi)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³lj010ValOk³ Autor ³ Pilar S. Albaladejo   ³ Data ³		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se total dos pagamentos esta correto 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function Lj010ValOk(nFinanciado,nEntrada)

Local j
Local nValor  := 0
Local lFinanc := .F.

If Len(aPgtos) == 0 .OR. Empty(aPgtos[1][1])
	aPgtos:={}
	If cPaisLoc == "BRA"
		aPgtos:={{CtoD("  /  /  "),0,Space(15),nMoedaCor}}
	Else
		aPgtos:={{CtoD("  /  /  "),0,Space(15),nMoedaCor,CtoD("  /  /  ")}}
	Endif
	oPgtos:Refresh()
	aParcTef := aClone(aPgtos)
	Return .T.
Endif

If !Empty(aPgtos)
	For j := 1 To Len(aPgtos)
		nValor += Round(xMoeda(NoRound(aPgtos[j][2],4),aPgtos[j][4],nMoedaCor,dDatabase),nDecimais)
		If IsMoney(aPgtos[j][3]) .AND. j > 1 .AND. aPgtos[j][1] > dDataBase
			Help( " ", 1, "NOPRAZO" )
			Return .F.
		Endif
		
		If aPgtos[j][3] == "FI"
			lFinanc := .T.
		Endif
		
	Next j
	
	If Round(NoRound(nValor,2),2) <> Round(NoRound(nFinanciado+nEntrada,2),2)
		If lFinanc
			
			// O valor total da venda n„o est  de acordo com o valor
			// financiado somado ao valor da entrada.  poss¡vel que haja algum
			// Problema com a condi‡„o de pagamento e o valor dos Juros.
			
			MsgInfo(STR0003+STR0004+STR0005)
			Return .F.
		Endif
	Endif
Endif

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³lj010DtPag³ Autor ³ Pilar S. Albaladejo   ³ Data ³		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se parcelas correspondem ao tipo de pagamento 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function Lj010DtPag( cComboPag  ,nParcela   ,aItens   ,dDataForm   ,;
                     lCheckPag  ,lValidParc )

Local lRet := .T.
Local cForma
Local nEl := Ascan( aItens, { |x| x[1] = cComboPag } )

DEFAULT lValidParc  := .T.

cForma := aItens[nEl][2]

If lValidParc
   If (IsMoney(cForma) .AND. nParcela <> 1 .AND. IIf(cPaisLoc == "BRA",.T.,dDataForm > dDataBase)) .OR.;
	  (IsMoney(cForma) .AND. dDataForm > dDataBase .AND. nParcela == 1)
	  Help( " ", 1, "LJNODINHEI" )
	  lRet := .F.
   Endif	  
Else
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³Validacao acionada quando muda a forma de pagamento de uma parcela ³
   //³quando uma das transacoes TEF eh rejeitada. Nao valida se a parcela³
   //³em Dinheiro eh a primeira porque, neste momento, ainda nao re-orde-³   
   //³nou  as parcelas													 ³      
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If (IsMoney(cForma) .AND. dDataForm > dDataBase)   
	  Help( " ", 1, "LJNODINHEI" )
	  lRet := .F.      
   Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³GravaCond ³ Autor ³ Wagner Xavier 	    ³ Data ³ 16/08/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava informacoes da forma de pagamento negociada			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³LOJA010													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Luiz Couto³21/02/05³710   ³- BOPS: 78471 - Correcao do controle de des-³±±
±±³          ³        ³      ³conto do venda-balcao para a utilizacao     ³±±
±±³          ³        ³      ³correta do desconto financeiro              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010GrCond(nCondicao,nEntrada,nFinanciado,nTxDesc,;
nParcelas,nIntervalo,nValorBase,cForma,cCondicao,;
nDescloj,nFator,lUsouFator,cAdmFator,nTipoJur,lFinalVend)

Local nRndFat := MsDecimais(nMoedaCor)

SL1->(RecLock("SL1"))
Lj010RetPos(@nEntrada)
SL1->L1_ENTRADA:= Round(nEntrada,nRndFat)
Lj010RetPos(@nFinanciado)
SL1->L1_FINANC := Round(nFinanciado,nRndFat)
SL1->L1_JUROS	:= nTxJuros
SL1->L1_TXDESC := nTxDesc
SL1->L1_PARCELA:= nParcelas
SL1->L1_INTERV := nIntervalo
If nValorBase == 0
	If lTroca
		SL1->L1_VLRLIQ := Round(nCredito - nNccGerada + nNccUsada ,2)
	Else
		SL1->L1_VLRLIQ := Round(nNccUsada - nNccGerada,2)
	Endif
Else
	If cPaisLoc == "BRA"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valor liquido da venda = Valor Base (s/ desconto financeiro) + ³
		//³Valor do Desconto Manual - Valor do Desconto Total             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SL1->L1_VLRLIQ := Round( ( ( nValorBase + nDescLoj ) - nVlrDesc ) + ( nNccUsada - nNccGerada ), nRndFat )
	Else
		SL1->L1_VLRLIQ := SL1->L1_VALMERC
	Endif
Endif
SL1->L1_FORMPG := aPgtos[1][3]
SL1->L1_CONDPG := cCondicao
SL1->L1_FATOR	:= Iif( lUsouFator, nFator, 0 )
SL1->L1_ADMFIN := cAdmFator
SL1->L1_TIPOJUR := nTipoJur
If SL1->(FieldPos("L1_DIAFIXO"))>0	
	SL1->L1_DIAFIXO := If(lDiaFixo,"1","2")
Endif
SL1->(msUnlock())

If ExistTemplate("LJ010GRVCN")
   ExecTemplate("LJ010GRVCN",.F.,.F.,{lFinalVend})
Endif

If ExistBlock("LJ010GRVCN")
   Execblock("LJ010GRVCN",.F.,.F.,{lFinalVend})
Endif          

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj010GrLojºAutor  ³Wagner Xavier        º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chama todas as funcoes de gravacao.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Venda Balcao                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010GrLoj(	cNumOrc			, cCliente		, cVendLoja		, nVlrTot		,;
						nDescloj		, nVlrLiq		, dDtlim		, nCondicao		,;
						nEntrada		, nFinanciado	, nTxDesc		, nParcelas		,;
						nIntervalo		, nValorBase	, cForma		, cCondicao		,;
						nCheck			, lCheck3		, cLoja			, oGet			,;
						lFinalVend		, lInclui		, lAltera		, aCondicoes	,;
						cCombo			, oEntrada		, oNumParcelas	, oFinanciado	,;
						nNumParcelas	, oTxJuros		, cComboAnt2	, nTxDescon		,;
						oTxDescon		, cNroPCli		, nFator		, lUsouFator	,;
						cAdmFator		, nDescPer		, nLiq			, nTroco		,;
						cNumSx8			, oGetOrca		, aCpoEnchoice	, lLjMontP		,;
						oVlrImpos		, nTipoJur		, oTipoJuros	, cTipoJuros	,;
						oCombo			, oIntervalo	, cLJDTORC		, lLJDTOrc		,;
						aMoedas			, oVlrTotVen	, cLjArq		, aCloaCols		,;
						nHandle )

Local lOk		:= .F.
Local lSL4Ok	:= .F.
Local lContinua:= .T.
Local i					 //tef
Local lCartao	:= .F. //tef
Local lRet		:= .T.
Local lInfChq  := SuperGetMV("MV_INFCHEQ")
LocaL aChDados 	:={}
Local cBanco   	:= CriaVar("SA6->A6_COD")
Local cAgencia 	:= CriaVar("SA6->A6_AGENCIA")
Local cConta   	:= CriaVar("SA6->A6_NUMCON")
Local cTelefone := Iif(Empty(SA1->A1_TEL),CriaVar("A1_TEL"),SA1->A1_TEL)
Local cRg	 	:= Iif(Empty(SA1->A1_RG ),CriaVar("A1_RG" ),SA1->A1_RG )
Local cCheque	:= CriaVar("EF_NUM")
Local cComp     := CriaVar("EF_COMP")
Local nVlrCart	:= Criavar("E1_VALOR")
Local lCheckCh  := .F.
Local lSaida	:= .F.
Local dDtVenc	:= Ctod("  /  /  ")
Local lCheckTe  := .F.
Local nParc 	:= 0
Local nPos   	:= 0
Local lEdit     := .F.
Local cFavorec  := SM0->M0_NOME
Local cCidade	:= IIf(Empty(Substr(SM0->M0_CIDCOB,1,15)),"Sao Paulo",Substr(SM0->M0_CIDCOB,1,15))
Local dEmissao  := dDataBase
Local cObs 		:= ''
Local cVerso 	:= ''
Local nLocSaveSx8 := GetSx8Len()

// Integracao Servidor de Consultas Cheque-Pre
Local cMesActa
Local cAnoActa
Local lTipoChq
Local cSerChq
Local cCgcChq
Local cNomeCli
Local cDDDCli := space(3)
Local cPreTelCli := space(4)
Local cSufTelCli := space(4)
Local cSrvCns // Servidor de consultas do cheque-pre.com
Local cArqEnt // SErvidor de consultas do cheque-pre.com
Local aArqSai // Servidor de consultas do cheque-pre.com
LOCAL cSrvCnsSai // Servidor de consultas do cheque-pre.com
LOCAL cChqInvalid // Servidor de consultas do cheque-pre.com
LOCAL nH // Servidor de consultas do cheque-pre.com
LOCAL cCodRet // Codigo da ocorrencia retornada
Local oLbListBox // servidor de consultas do cheque-pre.com
Local aDados := {}  // servidor de consultas do cheque-pre.com
Local nPosVlrItem := aScan( aHeader, {|x| Alltrim(Upper(x[2]))=="L2_VLRITEM" } )
Local nVlraCols := 0
Local nX := 0
Local nDecs   := 2
Local lTroco  := .F.
Local cTipoCli  := SA1->A1_TIPO
Local cTipoDocCF:= ""  
Local cNumDocCF := ""
Local lDocCF    := .F.
Local cClienteCF:= ""
Local cEnderCF  := ""
Local cTipoCI   := ""  
Local nLimCFis  := 0
Local cCodEnd	:= ""
Local cMay      := ""
Local nTent     := 0
Local nOpcao    

Private oObjCor1:= LoadBitmap( GetResources(), "ENABLE" ) // servidor de consultas do cheque-pre.com
Private oObjCor2:= LoadBitmap( GetResources(), "DISABLE")// servidor de consultas do cheque-pre.com
Private oObjCor3:= LoadBitmap( GetResources(), "BR_AMARELO" ) // servidor de consultas do cheque-pre.com
Private lTefOk := .F. //tef

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|                  **** Problema encontrado: ****					|
//| - Acesse a Venda Balcão											|
//| - Digite uma porcentagem de desconto maior que o valor			|
//| máximo permitido para o caixa									|
//| - Inclua um item												|
//| - Confirme a venda												|
//| O sistema deixará ser feita a inclusão da venda, mesmo que a	|
//| porcentagem do desconto e o valor do desconto estejam abaixo	|
//| do valor máximo permitido para o caixa.							|
//|                         **** Solução ****						|
//| Foi adicionado o acesso ao perfil do caixa antes da inclusão da	|
//| venda, isso garante, que os descontos sejam permitidos para o 	|
//| caixa.															|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "LJPSWSUP" )
	If ExecBlock( "LJPSWSUP", .F., .F., { nDescPer, nDescLoj, lFinalVend } )
		If !LjProfile( 11,,, nDescPer, nDescLoj )
			Return .F.
		Endif
	Endif
Else
	If !LjProfile( 11,,, nDescPer, nDescLoj )
		Return .F.
	Endif
Endif

//Nao deixar gravar qdo nao houver produto no orcameno
aEval( aCols, {|x| Iif(x[Len(x)],,nVlraCols+=x[nPosVlrItem] )})
If nVlraCols == 0
   Return .F.
Endif  

If SuperGetMV("MV_LJMOD3")
	If !Obrigatorio(aGets,aTela)
		Return .F.
	Endif
Endif

If cPaisLoc == "ARG"
	cNumDocCF  := Space(TamSX3("LS_DOCCF")[1])
    cClienteCF := Space(TamSX3("LS_CLIECF")[1])
    cEnderCF   := Space(TamSX3("MAD_END")[1])       
    nLimCFis   := SuperGetMV("MV_LIMCFIS",,1000)       
    cCodEnd	   := GetSxeNum("MAD","MAD_CODEND") 
    lDocCF     := .T.
Endif

//Permitir o ingresso de valores negativos para os casos de adiantamento(Localizacoes)
If IIf(cPaisLoc == "BRA",nValorBase < 0,.F.)
	Help(" ",1,"SemDados")
	Return .F.
ElseIf oFolder:nOption == 3
	If Empty(aPgtos[1][1])
		Help(" ",1,"SemDados")
		lFirst3 := .T.
		lFinalVend := .F.
		Return .F.
	Else
		lFirst3	:= .F.
	Endif
ElseIf oFolder:nOption == 2
	lFirst3 := .T.
ElseIf oFolder:nOption == 1
	lFirst3 := .T.
Endif

If cPaisLoc <> "BRA" .AND. (SuperGetMV("MV_LJTRLOC",,.F.))
   For nX := 1 to Len(aMoedas)   
      nDecs  := MsDecimais(aMoedas[nX][6])
      If aMoedas[nX][2] >= (1/(10**nDecs))
         lTroco  := .T.
         Exit
      Endif
   Next nX
   If lTroco
      //"Existe saldo de troco para a venda, o que pode causar inconsistencia na base de dados."	 	
      //"Deseja continuar mesmo assim?"	 			
      If !MsgYesNo(OemToAnsi(STR0071)+chr(13)+OemToAnsi(STR0072))
         Return (.F.)
      Endif
   Endif
Endif
If cPaisLoc == "GUA"
   If lNFManual
      nOpcao := Aviso(STR0044,STR0086,{STR0084,STR0085}) //"Aten‡„o"###"Sera gravada uma Nota Fiscal MANUAL. Confirma a operacao?"###"Confirma"###"Cancela" 	    	    
      If nOpcao == 2
         Return (.F.)
      Endif
   Endif   
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta as formas de pagamento se alterar/incluir produtos, ou     ³
//³ o usuario nao passar pela pasta "Como Pagar". Se as parcelas     |
//| forem alteradas a LJ010MontP nao serah executada. (no caso de    ³
//| gravacao do orcamento)                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLjMontP .AND. !lFinalVend
	Lj010MontP(aCondicoes,@cCombo,oEntrada,oNumParcelas,;
	oFinanciado,@nValorBase,@cForma,@nEntrada,@nFinanciado,@nCondicao,;
	@cCondicao,@nNumParcelas,oTxJuros,@cComboAnt2,@nTxDescon,oTxDescon,nIntervalo,;
	nDescLoj,.T.,@nLiq,nDescPer,oVlrImpos,@nTipoJur,@cTipoJuros,oTipoJuros,oCombo,;
	oIntervalo,oVlrTotVen) 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alteracoes especificas para o estado do Amazonas, por imposicao do SEFAZ-AM. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(LjAnalisaLeg(4)[1] .AND. SuperGetMv("MV_LJPGCC"))
	If !lFirst2
	
		If ! lj010ComVl(( nValorBase + iIf( lTroca, nCredito, 0 ) ), nVlrAcrs, nVlrTxDesc)
			Return .F.
		Endif

	Endif

Endif

//Isto quer dizer que o numero de orcamento ainda nao foi validado
//Bruno
If !SuperGetMV("MV_LJMOD3")
	If cNumOrc <> oGetOrca:Cargo
		EVAL(oGetOrca:bValid)
		//Foco no oBrowse para o usuario verificar os novos dados carregados no aCols pela
		//Validacao do Orcamento
		//Bruno
		SetFocus(oGet:oBrowse:hWnd)
		Return .F.
	Endif
Endif

If lFinalVend .AND. SuperGetMv("MV_CMC7CHQ") = 2
	For nPos := 1 to nNumParcelas
		If AllTrim(aReceb[nPos][3]) == cSimbCheq
			While .T.
				aChDados :=LjLeCmc7(nPos)
				If Len(aChDados) > 4
					cBanco	:= aChDados[1]
					cCheque	:= aChDados[2]
					cAgencia := aChDados[3]
					cConta	:= aChDados[4]
					cComp := aChDados[5]
					exit
				Else
					If !MsgYesNo(STR0043,STR0044)  //"Erro ao tentar ler o cheque , Tentar novamente ou cancelar e informar manualmente?"
						Exit
					Endif
				Endif
			End
			
			nVlrCart := aReceb[nPos][2]
			dDtVenc	:= aReceb[nPos][1]
			nParc 	:= nPos
			If !lCheckCh
				// Verifica se o CheckBox "Utiliza nas próximas parcelas" vira marcado ou desmarcado
				lCheckCh := (Alltrim(aReceb[nPos][3]) $ SuperGetMv("MV_PRXPARC"))
				LJVisChq(@cBanco,@cAgencia,@cConta,@cTelefone,@cRg,@cCheque,@nVlrCart,@lCheckTe,@lCheckCh,@lSaida,;
				@lOk,@nParc,lEdit,lContinua,lInfchq,@dDtVenc,@cCgcchq,@cNomeCli,@cSerChq,@cMesActa,@cAnoActa,;
				@lTipoChq,@cComp, @cdddcli, @cpretelcli, @csuftelcli)
				If lsrvcns
					cTelefone := cdddcli + cpretelcli + csuftelcli 
				Endif
				If lOk
					lCancelChq:= .F.
				Else
					lContinua := .F.
					lCancelChq:= .T.
					Exit
				Endif
			Endif
			If lCheck3
				
				Iif(lUsaCh,LjImpCheque( cBanco, cAgencia, cConta, cCheque, @nVlrCart, @cFavorec, @cCidade,;
				@dEmissao, @cObs, @cVerso ),.T.)
			Endif
		Endif
	Next
	nPos   	:= 0
Endif
If lFinalVend
	If ! CheckPaper()
		oDlgLoja:End()
		Return .F.
	Endif
	If lCancelChq
		lCancelChq := .F.
		For nPos := 1 to Len(aReceb)
			If Alltrim(aReceb[nPos,3]) == cSimbCheq
				lCancelChq := .T.
			Endif
		Next nPos
	Endif

	If lInfChq
		For nX := 1 to Len( aReceb )
			If Alltrim(aReceb[nX][3]) == 'CH' .AND. (Empty(aReceb[nX][4]).OR.Empty(aReceb[nX][5]))
				lCancelChq := .T.
			Endif
		Next nX
		If lCancelChq
			MsgInfo(STR0045,STR0044)
			Return .F.
		Endif
	Endif
Endif

//Tela para indicar tipo e numero de documento quando consumidor final e venda maior que 
//o determinado no parametro MV_LIMCFIS
If cPaisLoc == "ARG" .AND. lDocCF .AND. lFinalVend .AND. cTipoCli == "F" .AND. nLiq >= nLimCFis
   If !Lj010DocsCF(@cTipoDocCF,@cNumDocCF,@cClienteCF,@cEnderCF,@cTipoCI)   
      Return .F.
   Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pontos de Entrada      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistTemplate("LJCNFGRV") .AND. ! ExecTemplate("LJCNFGRV",.F.,.F.,{lFinalVend,cNumOrc})
	Return .F.
Endif

If ExistBlock("LJCNFGRV") .AND. ! ExecBlock("LJCNFGRV",.F.,.F.,{lFinalVend,cNumOrc})
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se foram digitados os campos obrigatorios da enchoice ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lSrvCns  .AND. lFinalVend // servidor de consultas do cheque-pre.com
	aArqSai := {}
	cSrvcns := ""
	For nPos := 1 to Len(aReceb)
		If Alltrim(aReceb[nPos,3]) == cSimbCheq
			cArqEnt := StrTran(Time(),":","")
			cSrvCns := "rde="             + LjGetStation("LG_REDECNS") + chr(13) + chr(10)
			cSrvCns += "rdelja="          + LjGetStation("LG_LOJACNS") + chr(13) + chr(10)
			cSrvCns += "ctr="             + LjGetStation("LG_CTRCNS") + chr(13) + chr(10)
			cSrvCns += "srvcns=1"              				   + chr(13) + chr(10)
			cSrvCns += "tbrddocdoc="      + Alltrim(aReceb[nPos,14])   + chr(13) + chr(10)
			cSrvCns += "tbrddocbco="      + LimpaChar(aReceb[nPos,04]) + chr(13) + chr(10)
			cSrvCns += "tbrddocbcoagn="   + LimpaChar(aReceb[nPos,06]) + chr(13) + chr(10)
			cSrvCns += "tbrddocbcocta="   + Right(LimpaChar(aReceb[nPos,07]),6) + chr(13) + chr(10)
			cSrvCns += "tbrddocdocser="   + LimpaChar(aReceb[nPos,17]) + chr(13) + chr(10)
			cSrvCns += "tbrddocdocnum="   + LimpaChar(aReceb[nPos,05]) + chr(13) + chr(10)
			cSrvCns += "tbrddocdatvctdd=" + StrZero(Day((aReceb[nPos,01])),2) + chr(13) + chr(10)
			cSrvCns += "tbrddocdatvctmm=" + StrZero(Month((aReceb[nPos,01])),2) + chr(13) + chr(10)
			cSrvCns += "tbrddocdatvctaa=" + StrZero(Year((aReceb[nPos,01])),4) + chr(13) + chr(10)
			cSrvCns += "tbrddocvlrint="   + Alltrim(Str(Int((aReceb[nPos,02])))) + chr(13) + chr(10)
			cSrvCns += "tbrddocvlrfrc="   + IIf( aReceb[nPos,02] - Int((aReceb[nPos,02])) = 0 , "00" , Substr(Str(aReceb[nPos,02] - Int (aReceb[nPos,02])), AT(".",Str(aReceb[nPos,02] - Int (aReceb[nPos,02]))) + 1,2) ) + chr(13) + chr(10)
			cSrvCns += "tbrddocemi="      + IIf(alltrim(aReceb[npos,16])= "" ,"NAO+INFORMADO" , StrTran(Alltrim(aReceb[nPos,16])," ","+")) + chr(13) + chr(10)
			cSrvCns += "tbrddocemicpfcgc=" + LimpaChar(aReceb[nPos,15]) + chr(13) + chr(10)
			cSrvCns += "tbrddocemirginsc="  + LimpaChar(aReceb[nPos,08]) + chr(13) + chr(10)
			cSrvCns += "tbrddocctaabrmm="   + aReceb[nPos,12] + chr(13) + chr(10)
			cSrvCns += "tbrddocctaabraa="   + aReceb[nPos,13] + chr(13) + chr(10)
			cSrvCns += "tassteldd=" 		+ Iif(len(LimpaChar(aReceb[nPos,9])) > 8, Substr(LimpaChar(aReceb[nPos,9]),1,3),"011") + chr(13) + chr(10)
			cSrvCns += "tasstelprf="        + Substr(LimpaChar(aReceb[nPos,9]),Len(LimpaChar(aReceb[nPos,9]))-7,4) + chr(13) + chr(10)
			cSrvCns += "tasstelsfx="       + Right(LimpaChar(aReceb[nPos,9]),4) + chr(13) + chr(10)
			cSrvCns += "tmprec=1" + chr(13) + chr(10)
			cSrvCns += "tmpchqdev=1" + chr(13) + chr(10)
			cSrvCns += "tmpchqsus=1" + chr(13) + chr(10)
			cSrvCns += "tmpoutres=1" + chr(13) + chr(10)
			cSrvCns	+= "tmptel=" + Iif(!Empty(Right(LimpaChar(aReceb[nPos,9]),4)),"1","0") + chr(13) + chr(10)
			MemoWrite(LjGetStation("LG_DIRORI") +  Alltrim(cArqEnt) + ".ENT" ,cSrvCns)
			AADD ( aArqSai ,{ LJGetStation("LG_DIRDES") +  Alltrim(cArqEnt) + ".SAI" , LimpaChar(aReceb[nPos,05]) } )
			while .T.
				nH := FOpen(LjGetStation("LG_DIRORI") +  Alltrim(cArqEnt) + ".ENT",2)
				If nH # -1
					fClose(nH)
					Exit
				Endif
				sleep(1000)
			End
		Endif
	Next
	If !Empty(cSrvCns)
	WinExec(LJGetStation("LG_DIREXEC")+"SRVCNS.EXE",1)
	For nPos =1 to Len(aArqSai)
		While .T.
			nH := Fopen(aArqSai[nPos,1],2)
			If nH # -1
				fclose(nH)
				exit
			Endif
			sleep(100)
		End
		FT_FUSE(aArqSai[nPos,1])
		FT_FGOTOP()
		While !FT_FEOF()
			cSrvCnsSai   := FT_FREADLN()
			cCodRet := Substr(cSrvCnsSai,1,At("|", cSrvCnsSai)-1)
			If Val(cCodRet) >= 0
					If Val(cCodRet) < 10   .OR. Val(cCodRet) = 50
					cSrvCnsSai :=  Substr( cSrvCnsSai,1,Len(Alltrim(cSrvCnsSai))-1)
					cChqInvalid = Substr(cSrvCnsSai,Rat("|",cSrvCnsSai) + 1 )+ chr(13) + chr(10)
					aadd(aDados,{Val(cCodRet),cChqInvalid})
				Endif
			Endif
			FT_FSKIP()
		End
		FT_FUSE()
			
		DEFINE MSDIALOG oDlg FROM 0,0 TO 450,410  Pixel TITLE OemToAnsi(STR0061 +  aArqSai[nPos,2]  )
		DEFINE SBUTTON FROM 210,170 TYPE 1 ACTION oDlg:End()ENABLE OF oDlg
		@ 001,.1 LISTBOX oLbListBox FIELDS HEADER  "",;                   // Indicador de Resultado
		OemToAnsi(STR0062);
		COLSIZES 10,90;
		SIZE 200,200 OF oDlg PIXEL
			If Len(aDados) < 1
				aadd(aDados,{0," "})
			Endif
		oLbListBox:SetArray(aDados)
		oLbListBox:bLine := { || { IIf(aDados[oLbListBox:nAt,1]==2,oObjCor3,Iif(aDados[oLbListBox:nAt,1]==1,oObjCor2,Iif(aDados[oLbListBox:nAt,1]=9,oObjCor3,oObjCor1))),aDados[oLbListBox:nAt,2],"@!"}}
		ACTIVATE MSDIALOG oDlg CENTERED
	Next
	If len(aDados) >= 1 .AND. (aDados[1,1] == 1  .OR. aDados[1,1] == 9)
		lFinalVend := .F.
		Return .F.
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava informacoes do Orcamento	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Lj010Grava(@cNumOrc,cCliente,cVendLoja,nVlrTot,@nDescloj,@nVlrLiq,;
	dDtlim,cLoja,nCheck,lCheck3,cNroPCli,@nValorBase,@nDescPer,@nLiq,;
	lFinalVend,lInclui,aCpoEnchoice,@cLJDTORC,@lLJDTOrc,aMoedas,nTxDescon)
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava informacoes da condicao negociada	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Lj010GrCond(nCondicao,nEntrada,nFinanciado,;
nTxDesc,nParcelas,nIntervalo,nValorBase,cForma,cCondicao,;
nDescLoj,nFator,lUsouFator,cAdmFator,nTipoJur,lFinalVend)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alteracoes especificas para o estado do Amazonas, por imposicao do SEFAZ-AM. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If LjAnalisaLeg(4)[1] .AND. SuperGetMv("MV_LJPGCC")
	lSL4Ok := .F.
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava informacoes do arquivo de forma de pagamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lSL4Ok := Lj010GrSL4(cNumOrc)
Endif

If !lSL4Ok
	lFinanlVend := .F.
Endif

// Verifica se algumas das parcelas ‚ Cartao de Cr‚dito, Cartao de d‚bito ou Cheque (TEF DISCADO)
aParcTef := {}
For i:= 1 To Len(aPgtos)
	If AllTrim(aPgtos[i][3]) $ "CC;CD" .OR. (AllTrim(aPgtos[i][3]) == cSimbCheq .AND. At("S",LjGetStation("TEFCONS"))<>0)
		lCartao:= .T.
		aAdd( aParcTef, aClone(aPgtos[i]) )
	Endif
Next i

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³LOG TEF                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(LOG_TEF)
	LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', 'LOJA010C'+Replicate('-',40) )
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apos ser realizado a impressao do cupom TEF, eh gerado um  |
//³ arquivo para a sua reimpressao, exceto VISANET. Este       |
//³ arquivo deve ser apagado sempre que iniciar uma nova venda |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
L010DelImp()
If !lFirst3 .AND. lUsaTef .AND. lFinalVend .AND. lCartao .AND. cTipTEF $ "2;3;4" // Sem Client / Com Client / Discado
	If !Empty(LOG_TEF)
		LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '1)  Iniciar Venda Tef')
	Endif
	lTefOk := LOJA010T( "V" , ,aReceb)
	If !Valtype(lTefOK) == "L"
		lTefOK := .F.
	ElseIf !lTefOK
		//HOMOLOGACAO: Enviar o desfazimento da operação TEF para impedir transações pendentes no Sitef
		If TEF_lEnvDF()
			If LOJA010T("F","D")
				MsgInfo(STR0082) 	//"Transação TEF cancelada!"
			Endif
			//Na versào 3.00 do TEF qdo quando ocorre erro nao e necessario cancelar enviei o desfazimento, respeito as versoes anteriores do Sitef
		ElseIf !(SuperGetMV("MV_TEFVERS") == "03.00")
			If LOJA010T("F","N")	//Antigamente esta função nao retornava verdadeiro ou falso
				MsgInfo(STR0082) 	//"Transação TEF cancelada!"
			Endif				
		Endif
	Endif
	If !lTefOk
		lContinua:=LojaOk(STR0083)	//"Continua Manualmente?"
		SetKEY(15,oBtOk:bAction)
		SetKEY(24,oBtCan:bAction)
	Endif
Endif
If !Empty(LOG_TEF)
	LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '2)  Venda TEF OK?'+If(lTefok,'S','N')+'/'+If(lcontinua,'S','N')+'/'+If(lFinalVend,'S','N'))
Endif	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o estoque esta negativo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua
	If lFinalVend
		If ExistBlock("LJCKSALD")
			lFinalVend:= ExecBlock("LJCKSALD",.F.,.F.)
		Else
			If !LjVerEstoq()
				lFinalVend := .F.
				lContinua := .F.
			Endif
		Endif
		If !Empty(LOG_TEF)
			LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '3)  Verifica estoque ?'+If(lcontinua,'S','N')+'/'+If(lFinalVend,'S','N'))
		Endif			
		//Efetuar o Desfazimento da Transação TEF
		If !lFinalVend .AND. lTefOK
		   If LOJA010T("F","N")
		  	  MsgInfo(STR0081) //"Transação TEF não efetuada, favor reter o cupom!"
		   Endif			  	   
		Endif	
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava informacoes de forma de pagto etc... ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(LOG_TEF)
		LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '4)  Gravar Informacoes ?'+If(lFirst3,'S','N')+'/'+If(lcontinua,'S','N')+'/'+If(lFinalVend,'S','N'))
	Endif
			
	If !lFirst3 .AND. lFinalVend
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Entrada do Template deve sempre ser antes do ponto de entrada        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistTemplate("SACI003")
			lRet:=ExecTemplate("SACI003",.F.,.F.)
			If lRet == Nil
				lRet:=.T.
			Endif
			If !Empty(LOG_TEF)
				LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '5) Template SACI003'+If(lret,'S','N'))
			Endif				
			If !lRet
				// Efetuar o Desfazimento da Transação TEF
				If lTefOK 
					If LOJA010T("F","N")
				  	  MsgInfo(STR0081) //"Transação TEF não efetuada, favor reter o cupom!"
					Endif						
				Endif	
				Return .F.
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chamada do Ponto de Entrada                                          |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("SACI003")
			lRet:=ExecBlock("SACI003",.F.,.F.)
			If lRet == Nil
				lRet:=.T.
			Endif
			If !Empty(LOG_TEF)
				LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '5) Ponto de Entrada SACI003'+If(lret,'S','N'))
			Endif				
			If !lRet
				// Efetuar o Desfazimento da Transação TEF
				If lTefOK 
					If LOJA010T("F","N")
	 			  	  MsgInfo(STR0081) //"Transação TEF não efetuada, favor reter o cupom!"
					Endif						
				Endif	
				Return .F.
			Endif
		Endif
		
		If !Empty(LOG_TEF)
			LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '6) Entrar na Gravacao')
		Endif			

		//Gera o codigo que sera utilizado para a gravacao do 
		//endereco do consumidor final...				
		If cPaisLoc == "ARG" .AND. lDocCF
			cMay := Alltrim(xFilial("MAD"))+cCodEnd
			FreeUsedCode()				
				
			dbSelectArea("MAD")
			dbSetOrder(1)
			While MsSeek(xFilial("MAD")+cCodEnd) .OR. !MayIUseCode(cMay)
				If ++nTent > 20
					MsgStop(STR0078)  //"Nao foi possivel gerar numero sequencial de endereco corretamente."                
					Return .F.
				Endif
				While (GetSX8Len() > nLocSaveSx8)
					ConfirmSx8()
				End
				cCodEnd := GetSxeNum("MAD","MAD_CODEND")
				FreeUsedCode()
				cMay := Alltrim(xFilial("MAD"))+cCodEnd
			End     
		Endif
		
		lOk := lj010Dados(nEntrada,nFinanciado,nDescloj,cForma,nValorBase,;
		nCheck,lUsouFator,cNumOrc,nTxDescon,nDescPer,nLiq,nTroco,cCombo,cTipoDocCF,;
		cNumDocCF,cClienteCF,cEnderCF,cCodEnd,cCliente,cLoja,cLjArq,aCloaCols,nHandle,;
		cTipoCI)
		If !lOk
			If !Empty(LOG_TEF)
				LjWriteLog( LOG_TEF + SL1->L1_NUM + '.TXT', '7) Falhou a gravacao')
			Endif				
			If cPaisLoc == "ARG" .AND. lDocCF
				If __lSx8
					While (GetSX8Len() > nLocSaveSx8)
						ConfirmSX8()
					End
				Endif
			Endif
			
			lFirst3 := .T.
			If __lSx8
				While (GetSX8Len() > nLocSaveSx8)
					ConfirmSx8()
				End
			Endif
			Return .F.
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama a funcao de impressao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lOk .AND. lFinalVend .AND. IIf(cPaisLoc == "GUA",!lNFManual,.T.)
		lj010Imp(nCheck,lCheck3,cCondicao,nValorBase,nTroco)
	Endif
Endif

Return lContinua

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj010DadPg³ Autor ³ Fernando Godoy		³ Data ³ 16/08/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria tela com os dados do pagamento						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³LOJA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010DadPg(oReceb,nPos,lEdit,oCheck3,lCheck3,lUsouFator,;
cAdmFator,oFolder)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cBanco
Local cAgencia
Local cConta
Local cNumCart :=Space(20)
Local cTelefone
Local cRg
Local cJanela
Local cCheque	:= CriaVar("EF_NUM")
Local cComp 	:= CriaVar("EF_COMP")
Local cTipoAtu
Local nVlrCart := Criavar("E1_VALOR")
Local i
Local n
Local nJ
Local nZ
Local nParc 	:= 0
Local aCartoes
Local lOk		 := .F.
Local lInfChq	 := SuperGetMV("MV_INFCHEQ")
Local lCheckOu  := .F.
Local lCheckCh  := .F.
Local lSaida	 := .F.
Local dDtVenc	 := Ctod("  /  /  ")
Local aCmc7
Local aArea 	 := GetArea()
Local lContinua := .T.
Local lCheckTe  := .F.
Local LLjBiling := ExistBlock("LjBiling")
Local nContador
Local aRecebTmp
Local iPos
Local nCMC7CHQ := SuperGetMV("MV_CMC7CHQ")

// Integracao Servidor de Consultas Cheque-Pre
Local cMesActa
Local cAnoActa
Local lTipoChq
Local cTipoChq
Local cSerChq
Local cCgcChq
Local cNomeCli
Local cDDDcli    := space(3)
Local cPreTelCli := space(4)
Local cSufTelCli := space(4)
Local nFor 		 := 0
Local lRepete	 := .F.


Default cAdmFator := ""

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Caso a chamada for na mudan‡a de pagina ³
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lEdit
	For nPos := 1 to Len(aReceb)
		
		If Empty(aReceb[nPos,4])
			*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			*³ Verifica se o tipo de pagto ‚ Dinheiro p/ nao executar a  ³
			*³ rotina                                                    ³
			*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If IsMoney(aReceb[nPos,3]) .OR. (cPaisLoc$"EUA|POR" .AND. lLayAway)
				Loop
			Endif
			
			*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			*³ Executa se o tipo for Cheque ³
			*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Alltrim(aReceb[nPos,3]) == cSimbCheq
				*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				*³ Verifica se trabalha ou n„o com Cheque "MV_INFCHEQ" ³
				*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lInfChq
					cBanco	 := CriaVar("SA6->A6_COD")
					cAgencia  := CriaVar("SA6->A6_AGENCIA")
					cConta	 := CriaVar("SA6->A6_NUMCON")
					cCheque	 := CriaVar("SEF->EF_NUM")
					cTelefone := Iif(Empty(SA1->A1_TEL),CriaVar("A1_TEL"),SA1->A1_TEL)
					cRg		 := Iif(Empty(SA1->A1_RG ),CriaVar("A1_RG" ),SA1->A1_RG )
					If lSrvCns
						cCgcChq  := Iif(Empty(SA1->A1_CGC ),CriaVar("A1_CGC" ),SA1->A1_CGC )
						cNomecli := Iif(Empty(SA1->A1_NOME ),CriaVar("A1_NOME" ),SA1->A1_NOME )
						cSerChq  := CriaVar("SL4->L4_SERCHQ")
						cMesACta := CriaVar("SL4->L4_MESACTA")
						cAnoACta := CriaVar("SL4->L4_ANOACTA")
						cTipoChq := CriaVar("SL4->L4_TIPOCHQ")
					Endif
					cComp := CriaVar("SEF->EF_COMP")
					*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					*³ Procura pelo banco,agencia,conta e cheque ³
					*³ ao passar do folder 2 p/ o 3					³
					*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nJ:=1
					For i:=1 To nPos
						For n:=nPos-1 to 1 Step -1
							If AllTrim(aReceb[n][3])==cSimbCheq
								nJ := n
								cBanco	 := aReceb[nJ,4]
								cCheque	 := Soma1(aReceb[nJ,5],Len(cCheque))
								cAgencia  := aReceb[nJ,6]
								cConta	 := aReceb[nJ,7]
								cRg		 := aReceb[nJ,8]
								cTelefone := aReceb[nJ,9]
								lCheckTe  := aReceb[nJ,10]
								If lSrvCns
									cMesACta  := aReceb[nJ,12]
									cAnoACta  := aReceb[nJ,13]
									lTipoChq := IiF(aReceb[nJ,14]="2", .T., .F.)
									cTipochq := aReceb[nJ,14]
									cCgcChq  := aReceb[nJ,15]
									cNomeCli := aReceb[nJ,16]
									cSerChq  := aReceb[nJ,17]
									cDDDcli    := Iif(len(LimpaChar(aReceb[nj,9])) > 8, Substr(LimpaChar(aReceb[nj,9]),1,3),"011")
									cPreTelCli := Substr(LimpaChar(aReceb[nj,9]),Len(LimpaChar(aReceb[nj,9]))-7,4)
									cSufTelCli := Right(LimpaChar(aReceb[nj,9]),4)            
									If empty(cDDDcli)
										cDDDcli := space(3)
									Endif
									If Empty(cPretelcli)
										cPretelcli := space(4)
									Endif
									If Empty(cSufTelCli)
										cSufTelCli := space(4)
									Endif		                    
								Endif
								cComp := aReceb[nJ,18]
								Exit
							Endif
						Next n
					Next i
					
					If !lCheckCh .AND. lUsaCmc7 .AND. nCMC7CHQ == 1
						While .T.
							aCmc7 := LjLeCmc7(nPos)
							If Len(aCmc7) > 3
								cBanco	:= aCmc7[1]
								cCheque	:= aCmc7[2]
								cAgencia := aCmc7[3]
								cConta	:= aCmc7[4]
								cComp	:= aCmc7[5]
								exit
							Else
								If !MsgYesNo(STR0043,STR0044)  //"Erro ao tentar ler o cheque , Tentar novamente ou cancelar e informar manualmente?"
									Exit										 //Oemtoansi("Aten‡„o")
								Endif
							Endif
						End
					Endif
					*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					*³ Carrega com o Valor e data da parcela ³
					*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nVlrCart := aReceb[nPos][2]
					dDtVenc	 := aReceb[nPos][1]
					nParc 	 := nPos
					
					If !lCheckCh  .AND. nCMC7CHQ == 1
						
						// Verifica se o CheckBox "Utiliza nas próximas parcelas" vira marcado ou desmarcado
						
						lCheckCh := (Alltrim(aReceb[nPos][3]) $ SuperGetMV("MV_PRXPARC"))
						LJVisChq(@cBanco,@cAgencia,@cConta,@cTelefone,@cRg,@cCheque,@nVlrCart,@lCheckTe,@lCheckCh,;
						@lSaida,@lOk,@nParc,lEdit,lContinua,lInfchq,@dDtVenc,@cCgcchq,@cNomeCli,@cSerChq,@cMesActa,;
						@cAnoActa,@lTipoChq,cComp,@cdddcli,@cpretelcli,@csuftelcli)
					Else
						Lj010Cheq(cBanco,cAgencia,cConta,cCheque,nPos,cRg,cTelefone,lCheckTe,cMesACta,cAnoACta,lTipoChq,CCgcChq,cNomeCli,cSerChq,cComp, cdddcli, cpretelcli, csuftelcli)
					Endif       
					If lsrvcns
						cTelefone := cdddcli + cpretelcli + csuftelcli 
					Endif
					
					*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					*³ Verifica se digitou os dados do CH ³
					*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lOk
						If !lUsaCH
							lCheck3 := .F.
							oCheck3:Disable()
						else
							lCheck3 := .T.
							oCheck3:Enable()
						Endif
						oCheck3:Refresh()
						lCancelChq:= .F.
					Else
						lContinua := .F.
						lCheck3 := .F.
						oCheck3:Disable()
						oCheck3:Refresh()
						lCancelChq:= .T.
						Exit
					Endif
				Else
					lCheck3 := .F.
					oCheck3:Disable()
					oCheck3:Refresh()
				Endif
			Else
				If Alltrim(aReceb[nPos,3])=="CO"
					cJanela := OemToAnsi(STR0017)  // Convˆnio
				ElseIf Alltrim(aReceb[nPos,3])=="VA"
					cJanela := OemToAnsi(STR0018)  // Vale
				ElseIf Alltrim(aReceb[nPos,3])=="CC"
					cJanela := OemToAnsi(STR0019)  // Cart„o de Cr‚dito
				ElseIf AllTrim(aReceb[nPos,3])=="FI"
					cJanela := OemToAnsi(STR0020)  // Financiadora
				Else
					cJanela := Lj010AdmPer(aReceb[nPos,3])
				Endif
				*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				*³ Monta ¡tens do ComboBox ³
				*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCartoes := Lj010LerCartao(aReceb[nPos,3])
				If Len(aReceb) > 1
					cCartao := Iif(Empty(aReceb[nPos][4]),aCartoes[1],aReceb[nPos][4])
				Else
					cCartao	:= Iif(Empty(aReceb[nPos][4]),aCartoes[1],aReceb[nPos][4])
				Endif
				
				*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				*³ Verifica se existe tipo cadastrado ³
				*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cTipoAtu := AllTrim(aReceb[nPos][3])
				For i:=1 To nPos
					For n := nPos-1 to 1 Step -1
						If AllTrim(aReceb[n][3]) == cTipoAtu
							cNumCart := aReceb[n][5]
							Exit
						Else
							cNumCart := Space(20)
						Endif
					Next n
				Next i

	
				*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				*³ Carrega com o Valor e data da parcela ³
				*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nVlrCart := aReceb[nPos][2]
				dDtVenc	:= aReceb[nPos][1]
				nParc 	:= nPos
				lSaida	:= .F.
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³S¢ abre a janela se nao atualizar todas as parcelas              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Foi incluída a checagem do tipo de pgto "CS" nesta condicional   ³
				//³devido a resolucao do bops no. 999999                            ³
				//³Criado controle via parâmetro MV_LJNCART, nesse caso, poderão ser³
				//³incluídos mais tipos de cartão para uso do PE LJBILING           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lLJBILING .AND. Alltrim(aReceb[nPos,3]) $ SuperGetMv("MV_LJNCART")
					cNumCart:=ExecBlock("LJBILING",.F.,.F.)
					lOk:=.T.
					lCheckOu:=.T.
				Else
					If ExistBlock("LJADMINS")
						ExecBlock("LJADMINS",.F.,.F.)
					Else										
						// Verifica se o CheckBox "Utiliza nas próximas parcelas" vira marcado ou desmarcado
						
						lCheckOu := (AllTrim(aReceb[nPos][3]) $ SuperGetMV("MV_PRXPARC"))
						
						DEFINE MSDIALOG oDlgLojaDadPag FROM 12, 20 TO 26, 60 TITLE cJanela;
						STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oDlgLoja
						
						DEFINE FONT oFont  NAME "Arial" SIZE 5,15
						DEFINE FONT oFont2 NAME "Arial" SIZE 10,15
						
						@ 00.3 , 01 TO 6,18.9 OF oDlgLojaDadPag
						
						// Valor do t¡tulo:
						@ 01.0 , 02.0 SAY OemToAnsi(STR0021) SIZE 10,1
						@ 01.0 , 11.0 SAY oVlrCart VAR nVlrCart FONT oFont COLOR CLR_HBLUE SIZE 7,1 ;
						Picture PesqPict("SL1","L1_VLRTOT",_PICTURE,nMoedaCor)
						// Data do Vencimento:
						@ 02.0 , 02.0 SAY OemToAnsi(STR0022) SIZE 10,1
						@ 02.0 , 9.0 SAY oDtVenc VAR dDtVenc FONT oFont COLOR CLR_HRED SIZE 8,1
						// Parcela:
						@ 02.0 , 13.0 SAY OemToAnsi(STR0023) SIZE 5,1
						@ 02.0 , 16.0 SAY oParc VAR nParc FONT oFont COLOR CLR_HRED SIZE 1,1
						
						If ! lUsaTef
							//N£mero:
							@ 03.0 , 02.0 SAY OemToAnsi(STR0024)
							@ 37.0 , 60.5 MSGET cNumCart RIGHT SIZE 62,10 OF oDlgLojaDadPag PIXEL Valid IIf(ExistBlock("LjVnCart"),Execblock("LjVnCart",.F.,.F.,{cNumCart}),.T.)
						Endif
						
						//Administradora:
						@ 04.0 , 02.0 SAY OemToAnsi(STR0025)
						@ 04.0 , 07.5 MSCOMBOBOX oComboCC VAR cCartao ITEMS aCartoes OF oDlgLojaDadPag SIZE 80,40 When (IIf(Len(aCartoes) > 1,.T.,.F.))
								
						// Utiliza nas pr¢ximas parcelas
						@ 67.0 , 16.2 CHECKBOX oCheckOu VAR lCheckOu PROMPT OemToAnsi(STR0026) SIZE 90,8 FONT oFont ;
						When Len(aReceb) > 1 OF oDlgLojaDadPag
						
						DEFINE SBUTTON FROM 88,088 TYPE 1 ACTION (lOk:= .T.,lSaida:= .T.,oDlgLojaDadPag:End()) ENABLE OF oDlgLojaDadPag
						DEFINE SBUTTON FROM 88,121.1 TYPE 2 ACTION (lOk:= .F.,lSaida:= .T.,oDlgLojaDadPag:End()) DISABLE OF oDlgLojaDadPag
						
						ACTIVATE MSDIALOG oDlgLojaDadPag Valid lSaida
					Endif
				Endif
				
				If lOk
					If lCheckOu
						For nZ := nPos to Len(aReceb)
							If Alltrim(aReceb[nZ,3]) == cTipoAtu
								If Len(aCartoes) == 1
									cCartao := Alltrim(aCartoes[1])
								Endif
								aReceb[nZ,4] := cCartao
								aReceb[nZ,5] := cNumCart
								//cCartao := Substr(aReceb[nZ][4],1,3)
								cCartao := aReceb[nZ][4]
							Endif
						Next nZ
					Else
						If Len(aCartoes) == 1
							cCartao := Alltrim(aCartoes[1])
						Endif
						aReceb[nPos,4] := cCartao
						aReceb[nPos,5] := cNumCart
						cCartao := Substr(aReceb[nPos][4],1,3)
					Endif
				Else
					lContinua := .F.
					oFolder:SetOption( 2 )
					oFolder:Refresh()
					Exit
				Endif
			Endif
		Endif
	Next nPos
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trecho do programa q verifica a duplicidade da   ³
	//³ forma de pagto (mesma data, administradora e num.³
	//³ de cartao.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRecebTmp   := aClone( aReceb )
	aSort( aRecebTmp ,,, {|x,y| dtos(x[1])+x[4]+x[5] < dtos(y[1])+y[4]+y[5]} )
	
	If cPaisLoc == "BRA"
		For nContador := 2 to Len( aRecebTmp )
			If aRecebTmp[ nContador-1 ][ 1 ] == aRecebTmp[ nContador ][ 1 ] .AND. ;
				aRecebTmp[ nContador-1 ][ 4 ] == aRecebTmp[ nContador ][ 4 ] .AND. ;
				aRecebTmp[ nContador-1 ][ 5 ] == aRecebTmp[ nContador ][ 5 ]
				MsgStop( OemToAnsi( STR0050 ), OemToAnsi( STR0051 ) )
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se houver administradoras iguais para a mesma data ³
				//³de pagto deleta a administradora do aReceb para o  ³
				//³usuario informar os dados novamente                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				While .T.
					If ( iPos := ASCAN( aReceb, { |x| DTOS(x[1])+x[4]+x[5] == DTOS(aRecebTmp[nContador-1][1])+aRecebTmp[nContador-1][4]+aRecebTmp[nContador-1][5] } ) ) == 0
						Exit
					Else
						aReceb[ iPos ][4] := " " // Space(Len(aRecebTmp[1][4]))
						aReceb[ iPos ][5] := " " // Space(Len(aRecebTmp[1][5]))
					Endif
				End
				oFolder:SetOption( 2 )
			Endif
		Next
	Endif
Else
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o tipo de pagto ‚ R$ p/ nao executar a rotina ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If IsMoney(aReceb[nPos,3])
		// A forma de pagamento Dinheiro n„o possui detalhes.
		MsgInfo(STR0027)
		lContinua := .F.
	Endif
	
	If lContinua
		If lUsouFator
			
			// Os Detalhes desta parcela n„o poder„o ser alteradas,
			// porque se trata de um Financiamento por Fator. Para alterar, escolha
			// em 'Como Pagar' outra financiadora ou outra condi‡„o de pagamento.
			
			MsgInfo(STR0028 + STR0029 + STR0030)
			lContinua := .F.
		Endif
	Endif
	
	If lContinua
		*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		*³ Executa se o tipo for Cheque ³
		*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Alltrim(aReceb[nPos,3]) == cSimbCheq
			*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			*³ Verifica se trabalha ou n„o com Cheque "MV_INFCHEQ" ³
			*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lInfChq
				*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				*³ Caso tenha gravado, Recupera os dados ³
				*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cBanco	 := aReceb[nPos][4]
				cCheque	 := aReceb[nPos][5]
				cAgencia  := aReceb[nPos][6]
				cConta	 := aReceb[nPos][7]
				cRg		 := aReceb[nPos][8]
				cTelefone := aReceb[nPos][9]
				lCheckTe  := aReceb[nPos][10]
				If lSrvCns
					cMesACta   := aReceb[nPos,12]
					cAnoACta   := aReceb[nPos,13]
					lTipoChq   := IiF(aReceb[nPos,14]="2", .T., .F.)
					cTipoChq   := aReceb[nPos,14]
					cCgcChq    := aReceb[nPos,15]
					cNomeCli   := aReceb[nPos,16]
					cSerChq    := aReceb[nPos,17]
					cDDDcli    := Iif(len(LimpaChar(aReceb[nPos,9])) > 8, Substr(LimpaChar(aReceb[nPos,9]),1,3),"011")
					cPreTelCli := Substr(LimpaChar(aReceb[nPos,9]),Len(LimpaChar(aReceb[nPos,9]))-7,4)
					cSufTelCli := Right(LimpaChar(aReceb[nPos,9]),4)
					If empty(cDDDcli)
						cDDDcli:= space(3)
					Endif
					If Empty(cPreTelCli)
						cPreTelcli := space(4)
					Endif
					If Empty(cSufTelCli)
						cSuftelcli := space(4)
					Endif			
					cTelefone := cdddcli + cpretelcli + csuftelcli
				Endif
				cComp := aReceb[nPos,18]
				*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				*³ Carrega com o Valor e data da parcela ³
				*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nVlrCart := aReceb[nPos][2]
				dDtVenc	:= aReceb[nPos][1]
				nParc 	:= nPos
				LJVisChq(@cBanco,@cAgencia,@cConta,@cTelefone,@cRg,@cCheque,@nVlrCart,@lCheckTe,@lCheckCh,@lSaida,;
				@lOk,@nParc,lEdit,lContinua,lInfchq,@dDtVenc,@cCgcchq,@cNomeCli,@cSerChq,@cMesActa,@cAnoActa,;
				@lTipoChq,@cComp,@cdddcli,@cpretelcli,@csuftelcli)
				*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				*³ Verifica se digitou os dados do CH ³
				*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lsrvcns
					cTelefone := cdddcli + cpretelcli + csuftelcli 
				Endif
				If lOk
					If !lUsaCH
						lCheck3 := .F.
						oCheck3:Disable()
					else
						lCheck3 := .T.
						oCheck3:enable()
					Endif
					oCheck3:Refresh()
					lCancelChq:= .F.
				Else
					lCheck3 := .F.
					oCheck3:Disable()
					oCheck3:Refresh()
					lCancelChq:= .T.
				Endif
			Else
				Help(" ","1","LJNINFCHQ")
			Endif
		Else
			If Alltrim(aReceb[nPos,3])=="CO"
				cJanela := OemToAnsi(STR0017) 		 // Convˆnio
			ElseIf Alltrim(aReceb[nPos,3])=="VA"
				cJanela := OemToAnsi(STR0018) 		 // Vale
			ElseIf Alltrim(aReceb[nPos,3])=="CC"
				cJanela := OemToAnsi(STR0019) 		 // Cart„o de Cr‚dito
			ElseIf AllTrim(aReceb[nPos,3])=="FI"
				cJanela := OemToAnsi(STR0020) 		 // Financiadora
			Else
				cJanela := Lj010AdmPer(aReceb[nPos,3])
			Endif
			*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			*³ Monta ¡tens do ComboBox ³
			*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCartoes := Lj010LerCartao(aReceb[nPos,3])
			
			If Len(aReceb) > 1
				cCartao := Iif(Empty(aReceb[nPos][4]),aCartoes[1],aReceb[nPos][4])
			Else
				cCartao	:= Iif(Empty(aReceb[nPos][4]),aCartoes[1],aReceb[nPos][4])
			Endif
			
			cNumCart := aReceb[nPos][5]
			
			*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			*³ Carrega com o Valor e data da parcela ³
			*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nVlrCart := aReceb[nPos][2]
			dDtVenc	:= aReceb[nPos][1]
			nParc 	:= nPos
			
			*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			*³ S¢ abre a janela se nao atualizar todas as parcelas ³
			*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lLJBILING .AND. Alltrim(aReceb[nPos,3])=="CO"
				cNumCart:=ExecBlock("LJBILING",.F.,.F.)
				lOk:=.T.
			Else
				lSaida:= .F.
				
				DEFINE MSDIALOG oDlgLojaDadPag FROM 12, 20 TO 26, 60 TITLE cJanela;
				STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oDlgLoja
				
				DEFINE FONT oFont  NAME "Arial" SIZE 5,15
				DEFINE FONT oFont2 NAME "Arial" SIZE 10,15
				
				@ 00.3 , 01 TO 6,18.9 OF oDlgLojaDadPag
				
				// Valor do t¡tulo:
				@ 01.0 , 02.0 SAY OemToAnsi(STR0021) SIZE 45,9
				@ 01.0 , 11.0 SAY oVlrCart VAR nVlrCart FONT oFont COLOR CLR_HBLUE SIZE 55,9 ;
				Picture PesqPict("SL1","L1_VLRTOT",_PICTURE,nMoedaCor)
				//Data do Vencimento:
				@ 02.0 , 02.0 SAY OemToAnsi(STR0022) SIZE 55,9
				@ 02.0 , 9.0 SAY oDtVenc VAR dDtVenc FONT oFont COLOR CLR_HRED SIZE 55,9
				//Parcela:
				@ 02.0 , 13.0 SAY OemToAnsi(STR0023) SIZE 25,9
				@ 02.0 , 17.0 SAY oParc VAR nParc FONT oFont COLOR CLR_HRED SIZE 7,9
				
				// N£mero:
				@ 03.0 , 02.0 SAY OemToAnsi(STR0024)
				@ 37.0 , 60.5 MSGET cNumCart RIGHT SIZE 62,10 OF oDlgLojaDadPag PIXEL //PICTURE "9999.9999.9999.9999"
				//Administradora:
				@ 04.0 , 02.0 SAY OemToAnsi(STR0025)
				@ 04.0 , 07.5 MSCOMBOBOX oComboCC VAR cCartao ITEMS aCartoes OF oDlgLojaDadPag SIZE 80,40 When (IIf(Len(aCartoes) > 1,.T.,.F.))
				
				DEFINE SBUTTON FROM 082,095	TYPE 1 ACTION (lOk:= .T.,lSaida:= .T.,oDlgLojaDadPag:End()) ENABLE OF oDlgLojaDadPag
				DEFINE SBUTTON FROM 082,124.1 TYPE 2 ACTION (lOk:= .F.,lSaida:= .T.,oDlgLojaDadPag:End()) ENABLE OF oDlgLojaDadPag
				
				ACTIVATE MSDIALOG oDlgLojaDadPag Valid lSaida
				
			Endif
			If lOk
				If Len(aCartoes) == 1
					cCartao := Alltrim(aCartoes[1])
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se durante a alteração o operador não digitou forma de pagamento repetida|
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lRepete := .F.
				
				If Len(aReceb) > 1
					For nFor := 1 To Len(aReceb)
						If DTOS(aReceb[nFor][1])+aReceb[nFor][4]+aReceb[nFor][5] == DTOS(aReceb[nPos][1])+aReceb[nPos][4]+aReceb[nPos][5] .AND. nFor <> nPos
							lRepete := .T.
						Endif
					Next nFor						
				Else
					lRepete := .F.
				Endif					
					
				If lRepete
				    MsgStop( STR0050 , STR0051 )
					aReceb[ nPos ][4] := " "
					aReceb[ nPos ][5] := " "
				Else
					aReceb[ nPos ][4] := cCartao
					aReceb[ nPos ][5] := cNumCart
				Endif
				
				cCartao := Substr( aReceb[ nPos ][4],1,3)
			Endif
		Endif
	Endif
Endif

If lContinua
	oReceb:SetArray( aReceb )
	oReceb:bLine := {||{aReceb[oReceb:nAt,1],;
	Transform(aReceb[oReceb:nAt,2],PesqPict("SL1","L1_VLRTOT",_PICTURE,aReceb[oReceb:nAt,11])),;
	aReceb[oReceb:nAt,3],;
	aReceb[oReceb:nAt,4],;
	aReceb[oReceb:nAt,5],;
	aReceb[oReceb:nAt,6],;
	aReceb[oReceb:nAt,7],;
	aReceb[oReceb:nAt,8],;
	aReceb[oReceb:nAt,9],;
	aReceb[oReceb:nAt,11],;
	aReceb[oReceb:nAt,12],;
	aReceb[oReceb:nAt,13],;
	aReceb[oReceb:nAt,14],;
	aReceb[oReceb:nAt,15],;
	aReceb[oReceb:nAt,16],;
	aReceb[oReceb:nAt,17],;
	aReceb[oReceb:nAt,18]}}
	oReceb:Refresh()
Endif

RestArea( aArea )

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³lj010JurCo³ Autor ³ Fernando Godoy	    ³ Data ³ 08.01.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Janela para condicao negociada (Juros etc...)				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³1 - Tipo de Calculo (Antecipado - "A" ou Postecipado - "P") ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³SigaLoja													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010JurCom(cTipoCalc)

If cTipoCalc == "A"
	Help(" ","1","NAODISP")
ElseIf cTipoCalc == "P"
	Help(" ","1","NAODISP")
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³lj010JurPr³ Autor ³ Fernando Godoy        ³ Data ³ 08.01.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calculo de Juros pela Tabela Price.						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SigaLoja 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010JurPri(nEntNeg,nTxjNeg,cComboJur,nIntNeg,nValorBase)

Local nValor := 0

nValor := lj010FRC(nEntNeg,nTxjNeg,cComboJur,nIntNeg,nValorBase)

Return nValor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³lj010JurSa³ Autor ³ Fernando Godoy	    ³ Data ³ 08.01.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Janela para condicao negociada (Juros etc...) 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SigaLoja 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010JurSac()

Help(" ","1","NAODISP")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³lj010UsaFi³ Autor ³ Fernando Godoy	    ³ Data ³ 03.07.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Lj010UsaFi(ExpC1)											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Administradora escolhida. 		    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Fun‡„o para utilizar Fator de Multiplic.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Nil 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SigaLoja 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010UsaFin(cComboAdm)

Local aArea 	 := GetArea()
Local cAdmin	 := Substr( cComboAdm,1,3 )
Local lUsaFator := .F.

dbSelectArea("SAE")
dbSetOrder(1)
MsSeek( xFilial("SAE") + cAdmin )

lUsaFator := Iif( Upper(SAE->AE_USAFATO) == "S",.T.,.F.)

If lUsaFator
	
Endif

RestArea( aArea )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³lj010box	³ Autor ³ Fernando Godoy		³ Data ³ 08.01.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se utiliza cond de pagto. negociada ou uma j  Cad. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SigaLoja 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010box(nEntrada,nParcelas,nIntervalo,nValorBase,;
oEntrada,oTxJuros,oNumParcelas,oIntervalo,aCondicoes,;
nFinanciado,cForma,oFinanciado,lCalcEntrada,nEntrAnt,nEntrOrig,;
aParcelas,cCombo,oCombo,nNumParcelas,nLiq,oVlrLiq1,oVlrLiq2,lFirstJur,;
nTipoJur,nCondicao,cCondicao,cComboAnt2,nTxDescon,oTxDescon,;
nDescLoj,nDescPer,oVlrImpos,cTipoJuros,oTipoJuros,oVlrTotVen)

Local lRet      	:= .T.
Local lLjAtuCmb 	:= ExistBlock("LJATUCMB")
Local nl        	:= 0
Local nVTotInt  	:= 0
Local nValorTotal 	:= 0
Local nPosVlr 		:= aPosicoes[2][2]

If lCarregouSL4 .AND. SE4->E4_CODIGO == Left(cCombo,3) .AND. SL1->L1_CONDPG == Left(cCombo,3)
	Return (.T.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Como esta funcao eh executada se a condicao nao for ³
//³negociada, o Intervalo eh zerado.                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If SubStr(Upper(cCombo),1,2) <> "CN"
	nIntervalo := 0
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se a somatoria dos valores dos itens das linhas do aCols e maior que 0(zero).³
//³Nao permitindo que seja enviado valor 0(zero) a funcao LJ010MontP().                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nl:= 1 to Len(aCols)
	nVTotInt += aCols[nl][aPosicoes[2][2]]
Next nl
If nVTotInt > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se e necessario recalcular as parcelas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValorTotal := 0
	aEval(aCols, {|x| nValorTotal += x[nPosVlr] } )
	If (oCombo:lModified) .OR. (nValorTotal + nVlrAcrs - nVlrDesc) <> (nLiq + nVlrAcrs)
		lRet := Lj010MontP(aCondicoes,@cCombo,oEntrada,oNumParcelas,;
		oFinanciado,@nValorBase,@cForma,@nEntrada,@nFinanciado,@nCondicao,;
		@cCondicao,@nNumParcelas,oTxJuros,@cComboAnt2,@nTxDescon,oTxDescon,nIntervalo,;
		nDescLoj,.T.,@nLiq,nDescPer,oVlrImpos,@nTipoJur,@cTipoJuros,oTipoJuros,oCombo,;
		oIntervalo,oVlrTotVen) 
	Endif
Endif
If lLjAtuCmb
	aPgtos:=ExecBlock("LjAtuCmb",.F.,.F.,{aPgtos})
	If Len(aPgtos) > 0   //Compatibilizacao dos rdmakes com a nova posicao Moeda do array aPgtos
		If Len(aPgtos[1]) == 3
		   AEval( aPgtos, { |x| Aadd(x,nMoedaCor) } )
		Endif
		If cPaisLoc <> "BRA" .AND. Len(aPgtos[1]) == 4	//Data de emissao da parcela		
		   AEval( aPgtos, { |x| Aadd(x,dDataBase) } )
		Endif
	Endif
	oPgtos:Refresh()
	aParcTef := aClone(aPgtos)
Endif

If !lRet
	LjAtualComb(@cCombo,oCombo,@aCondicoes,@cCondicao,cComboAnt2)
Endif

oVlrLiq1:Refresh()
oIntervalo:Refresh()
cComboAnt2 := cCombo

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³lj010IniCo³ Autor ³ Fernando Godoy	    ³ Data ³ 08.01.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se existe a condicao de pagto padrao e inicializa ³±±
±±³			 ³ o ComboBox e variaveis. 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SigaLoja 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010IniCom(aCondicoes,cCombo,oEntrada,;
oNumParcelas,oFinanciado,nValorBase,cForma,nEntrada,nFinanciado,;
nCondicao,cCondicao,nNumParcelas,oTxJuros,cDescCond,;
lUsouFator,lInclui,nOpcx)

Local cAlias := Alias()

// Carrega a condicao de pagamento do SL1 somente na finalizacao de orcamento.
If !EMPTY( SL1->L1_CONDPG ) .AND. ! lInclui .AND. nOpcx <> 4
	If ALLTRIM( SL1->L1_CONDPG ) == "CN"
		cDescCond := STR0026 				 // Condi‡„o Negoc.
		cCondicao := "CN "
	Else
		DBSelectArea("SE4")
		SE4->(DBSetOrder(1))
		If SE4->( MsSeek( xFilial("SE4") + cCondicao ) )
			cDescCond := LEFT( SE4->E4_DESCRI, 12 )
			
			If !lUsouFator
				nTxJuros  := SE4->E4_ACRSFIN
			Endif
			// 		  nTxDescon := SE4->E4_DESCFIN
		Else
			If SE4->( MsSeek( xFilial("SE4") + "001" ) )
				cCondicao := "001"
				cDescCond := LEFT( SE4->E4_DESCRI, 12 )
				nTxJuros  := SE4->E4_ACRSFIN
				// 			  nTxDescon := SE4->E4_DESCFIN
			Else
				CriaCondPad()
				cCondicao := "001"
				cDescCond := LEFT( SE4->E4_DESCRI, 12 )
				nTxJuros  := SE4->E4_ACRSFIN
				// 			  nTxDescon := SE4->E4_DESCFIN
			Endif
		Endif
	Endif
Else
	If ALLTRIM( SL1->L1_CONDPG ) == "CN"
		cDescCond := STR0026 				 // Condi‡„o Negoc.
		cCondicao := "CN "
	Else
		If cConfCli == "S"  .AND. nOpcx <> 4
			cCondicao := SA1->A1_COND
		Endif
		
		DBSelectArea("SE4")
		SE4->(DBSetOrder(1))
		If SE4->( MsSeek( xFilial("SE4") + cCondicao ) )
			cDescCond := LEFT( SE4->E4_DESCRI, 12)
			nTxJuros  := SE4->E4_ACRSFIN
			// 	  nTxDescon := SE4->E4_DESCFIN
		Else
			If SE4->( MsSeek( xFilial("SE4") + "001" ) )
				cCondicao := "001"
				cDescCond := LEFT( SE4->E4_DESCRI, 12)
				nTxJuros  := SE4->E4_ACRSFIN
				// 		  nTxDescon := SE4->E4_DESCFIN
			Else
				CriaCondPad()
				cCondicao := "001"
				cDescCond := LEFT( SE4->E4_DESCRI, 12 )
				nTxJuros  := SE4->E4_ACRSFIN
				// 		  nTxDescon := SE4->E4_DESCFIN
			Endif
		Endif
	Endif
Endif

DBSelectArea(cAlias)

Return (cCondicao + " - " + cDescCond)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³lj010CondP³ Autor ³ Wagner Xavier 	    ³ Data ³		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta Array com as condi‡”es de pagamento. 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpA1:=lj010CondP( )										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Retorna array com as condi‡”es cadastradas.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA010												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function lj010CondP( )

Local aCondicoes := {}
Local lLj010Cond := ExistBlock("LJ010CON")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega com as condi‡”es gravadas no SE4 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !lLayAway
	If !lLj010Cond 
		dbSelectArea("SE4")
		MsSeek(xFilial("SE4"))
		While !Eof() .AND. SE4->E4_FILIAL == xFilial("SE4")
			If cPaisLoc $ "EUA|POR"
				If SE4->E4_CODIGO == "LAY"
					DbSkip()
					Loop
				Endif
			Endif
		
			Iif(SE4->E4_TIPO <> "9",Aadd(aCondicoes ,SE4->E4_CODIGO + " - " + SubStr( E4_DESCRI, 1, 20 )),.T.)
			dbSkip()
		End
	Else
		aCondicoes:= ExecBlock("LJ010CON",.F.,.F.)  // Ponto de Entrada para condi‡äes de pagamento
	Endif 													  // Solicitado por Joel SigaAracaj£
Else
	Aadd(aCondicoes,"LAY - "+OemToAnsi(STR0067))  //"Lay-Away"
Endif

Return aCondicoes

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³lj010FRC	³ Autor ³ Fernando Godoy	    ³ Data ³ 03/07/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula o Fator de Recupera‡„o de Capital. 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpA1:=lj010FRC()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Valor da Parcela.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³1 - Entrada. 												  ³±±
±±³			 ³2 - Taxa de Juros. 										  ³±±
±±³			 ³3 - Tipo de intervalo (Mensal, Di rio...). 				  ³±±
±±³			 ³4 - Intervalo entre as parcelas.							  ³±±
±±³			 ³5 - Valor total a ser financiado. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³LOJA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function lj010FRC(nEntNeg,nTxjNeg,cComboJur,nIntNeg,nValorBase)

Local nValor := 0
Local nTaxaJur  := nTxjNeg/100

nValor := nValorBase * (1 / (1 + nTaxaJur))
nValor := nValor * ((((1+nTaxaJur)**nIntNeg)*nTaxaJur)/(((1+nTaxaJur)**nIntNeg)-1))

Return nValor


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ljw10TudOk³ Autor ³ Wagner Xavier 		³ Data ³		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia geral dos itens do Orcamento. 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ExpN1 = ljw10TudOk 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 = Valor devolvido pela fun‡…o						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³Generico													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function ljw10TudOk( o )

Static nErro	  := 0
Local lRet		  := .T.
Local nDif		  := 0
Local nValIcms   := 0
Local nUltIt	  := 0
Local nColIcm	  := 0
Local nPosPrcTab := aPosicoes[13][2]
Local nPosQuant  := aPosicoes[11][2]
Local nPosValDes := aPosicoes[3][2]
Local nPosTotal  := aPosicoes[2][2]
Local nx 		  := 0
Local ny 		  := 0
Local nMaxArray  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria um Clone do Acols ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFirstaCols
	aColsBak := aClone(aCols)
	lFirstaCols := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ verifica se o ultimo elemento do array esta em branco		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nMaxArray := Len(aCols)

If Empty(aCOLS[nMaxArray][1])
	nMaxArray--
End

If nMaxArray == 0
	lRet := .T.
Endif

If lRet
	For ny := 1 to Len(aHeader)
		If Empty(aCols[nMaxArray][ny]) .AND. !aCols[nMaxArray][nUsado+1]
			If (Trim(aHeader[ny][2]) == "L2_QUANT"   .OR.;
				Trim(aHeader[ny][2]) == "L2_VRUNIT"  .OR.;
				Trim(aHeader[ny][2]) == "L2_VLRITEM" .OR.;
				Trim(aHeader[ny][2]) == "L2_TES" )
				Help(" ",1,"A010VAZ")
				lRet := .F.
				nMaxArray--
				nErro++
				Exit
			Endif
		Endif
	Next nY
Endif

If lRet
	For nx := 1 to nMaxArray
		If !aCols[nx][Len(aCols[nx])]
			For ny := 1 to Len(aHeader)
				// Deve calcular independente de ser Tributado, Isento ou Outras
				If Trim(aHeader[ny][2]) == "L2_VALICM"
					nValIcms 	  := lj010Icms(nx,@nDif)
					aCols[nx][ny] := nValIcms
					nUltIt		  := IIf(nValIcms > 0,nx,nUltIt)
					nColIcm		  := ny
				Endif
				If Trim(aHeader[ny][2]) == "L2_TES"
					dbSelectArea( "SF4" )
					If !(MsSeek( cFilial + aCols[nx][ny] ) )
						Help( " ",1,"A010TES")
						lRet := .F.
					Endif
				Endif
			Next ny
		Endif
	Next nx
Endif

If lRet
	nDIf := Noround(nDif,2)
	
	If nDIf >= 0.01 .AND. nUltIt > 0 .AND. nColIcm > 0
		aCols[nUltIt][nColIcm] += nDif
	Endif
Endif

For ny := 1 to len(aCols)
	If aCols[ny][nPosValDes] >= (aCols[ny][nPosQuant]*aCols[ny][nPosPrcTab]) .AND. ! aCols[ny][Len(aHeader)+1] .AND. aCols[ny][nPosTotal] > 0
		lRet := .F.
		// Desconto maior que o valor no item:
		MsgStop(STR0064+AllTrim(Str(ny)))
		Exit
	Endif
Next ny


If ExistTemplate("LJ010OK")
	lRet := ExecTemplate( "LJ010OK", .F., .F. , {lRet})
Endif

If ExistBlock("LJ010OK")
	lRet := ExecBlock( "LJ010OK", .F., .F. , {lRet})
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ljw10Desc ³ Autor ³ Fernando Godoy        ³ Data ³ 11.07.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula desconto em funcao do percentual.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ljw010Desc(nVlrLiq,nVlrTot,nValorBase,nLiq,oVlrLiq,oVlrLiq1,oVlrLiq2,nDescloj,oDescPer,;
	nDescPer,oDescont,nVlrImpInc,oAutorDesc)

Local lRet 			:=	.T.
Local nVlrTotAnt	:=	nVlrTot + IIf(cPaisLoc<>"BRA",nVlrImpInc,0) // Armazenando total sem avaliar tes de gera‡Æo de duplicatas
Local aValores   	:=	{}
Local lLjDescNv 	:= ExistBlock("LJDESCNV")
Local lDescOk 		:= .T.
Local lNoArredDesc  := nDecimais == 0  
Local nArredDesc    := TamSX3("L1_DESCNF")[2]
Local nDecs         := IIf(lNoArredDesc,nArredDesc,nDecimais)
Local aDesc
Local lAjusta       := ExistBlock("Ajusta")				// Verifica se existe o PE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se houve alteracao na porcentagem de desconto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !( nDescPer == __nDescPer ) .OR. !( nDescLoj == __nDescLoj )
	__lAplicDesc 	:= .F.				//Seta a variavel de aplicacao de desconto como falso
	__nDescPer 		:= nDescPer			//Seta a variavel com a porcentagem de desconto com a nova porcentagem de desconto
	__nDescLoj 		:= nDescLoj			//Seta a variavel com o valor de desconto com o novo valor de desconto
Endif

If  lAjusta
	aValores	:=	{0,0}
	aValores	:=	ExecBlock("AJusta",.F.,.F.)
	lSayWin		:=	.F. 		// False para que a funcao SayWinSub nao seja executada
	nVlrTot		:=	aValores[1] + aValores[2] // ValorBase + Ipi
	nVlrTot		:=	nVlrTot - If(lTroca,nCredito,0) + nNccGerada - nNccUsada - LJPCCRet() - npValISS
Endif

If nDescPer > 0
	
	If SuperGetMV( "MV_ARREFAT" ) == "S"
		// Não recalcular se não foi alterado - gera diferença de centavos
		If ! nDescPer == Round((nDescloj * 100) / nVlrTot, nDecs )
			nDescloj := Round( ( ( nDescPer * nVlrTot ) / 100 ), nDecimais )
		Endif
	Else
		If ! nDescPer == NoRound((nDescLoj * 100) / nVlrTot, nDecs )
			nDescloj := NoRound( ( ( nDescPer * nVlrTot ) / 100 ), nDecimais )
		Endif
	Endif
	
	If nVlrTot > 0 .AND. nDescLoj >= nVlrTot - 0.01
		nDescLoj := nVlrTot - 0.01
	Endif
	
	// Valor do desconto nao permitido para o caixa atual / Desconto nao autorizado
	
	If lLjDescNv
		If !__lAplicDesc	
			lDescOk 		:= ExecBlock("LJDESCNV",.F.,.F.,{nDescPer,nDescLoj,nVlrTot,cAutorDesc,aDesc})
			__lAplicDesc 	:= lDescOk
		Endif
	Else		         
		If nDescPer > 0 
			aDesc := {'P',nDescPer}
		Else
		    aDesc := {'V', nDescLoj}
		Endif 
	    If !Ljprofile(11,@cAutorDesc,aDesc,nDescPer,nDescLoj)
			lDescOk := .F.
		Endif
		If !Empty(cAutorDesc)
			cAutorDesc += DToC(dDataBase)
		Endif
	Endif 
	
	If !lDescOk	
		nDescloj := 0
		nDescPer := 0
		nLiq	 := nVlrTotAnt
		nVlrLiq  := nVlrTotAnt
		nValorBase  := nVlrTotAnt
		lRet     := .F.
	Endif	
Else
	nDescLoj := 0
Endif

nVlrTot	:=nVlrTotAnt
oDescont:ReFresh()
oDescPer:Refresh()
oVlrLiq:Refresh()
oAutorDesc:Refresh()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³lj010Mostr³ Autor ³ Fernando Godoy	    ³ Data ³ 11.07.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra na tela os Dados Atualizados. 	    				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³SigaLoja													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Mostra(nEntrada,nParcelas,nIntervalo,nValorBase,;
oEntrada,oTxJuros,oNumParcelas,oIntervalo,aCondicoes,;
nFinanciado,oFinanciado,cCombo,oCombo,nLiq,oVlrLiq,;
oVlrLiq1,oVlrLiq2,nTipoJur,cCondicao,oFnt2,;
nVlrTot,nDescloj,oDescPer,nDescPer,nVlrLiq,nVlrAcrs,;
nVlrDesc,cTipoJuros,oVlrAcrs,oVlrDesc,oTipoJuros)

oEntrada:Refresh()
oFinanciado:Refresh()
oTxJuros:Refresh()
oNumParcelas:Refresh()
oIntervalo:Refresh()
oVlrDesc:Refresh()
oVlrAcrs:Refresh()
oTipoJuros:Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LimpaArray³ Autor ³ Fernando Godoy		  ³ Data ³ 11.07.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Limpa uma Linha do Array aReceb.									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³SigaLoja																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LimpaArray(nLinha)

Local nI

For nI := 4 to 9
	aReceb[nLinha][nI] := Space(1)
Next nI
aReceb[nLinha][10]:= .F.
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj010AdmPe³ Autor ³ Fernando Godoy		  ³ Data ³ 11.07.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna o Nome da Forma Personalizada							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³SigaLoja																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function  Lj010AdmPer(cTipo)

Local nReg	 := Recno()
Local cAlias := Alias()
Local nOrder := IndexOrd()
Local cDescricao

dbSelectArea("SX5")
dbSetOrder(1)
MsSeek(xFilial("SX5")+"24"+cTipo)

cDescricao := Capital(X5Descri())

dbSelectArea(cAlias)
dbSetOrder(nOrder)
dbGoto(nReg)

Return cDescricao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj010CbFor³ Autor ³ Fernando Godoy	    ³ Data ³ 31.07.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida forma do ComboBox 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³SigaLoja													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010CbFor(oCheckPag,lCheckPag,aMatriz,cComboPag,aItens)

Local cEspecie := "DINHEIRO"

If cPaisLoc <> "BRA" .AND. SX5->(MsSeek( cFilial+"24"+Alltrim(SuperGetMV("MV_SIMB1"))))
	cEspecie := AllTrim(X5Descri())
Endif
If Len(aPgtos) > 1
	
	If Upper(cComboPag) == cEspecie
		lCheckPag := .F.
		oCheckPag:Disable()
		oCheckPag:Refresh()
	Else
		// Verifica se o CheckBox "Utiliza nas próximas parcelas" vira marcado ou desmarcado
		lCheckPag := (AllTrim(aItens[Ascan( aItens, { |x| x[1] = cComboPag } )][2]) $ SuperGetMV("MV_PRXPARC"))
		oCheckPag:Enable()
		oCheckPag:Refresh()
	Endif
Else
	lCheckPag := .F.
	oCheckPag:Disable()
	oCheckPag:Refresh()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjVerEstoq³ Autor ³ Fernando Godoy		³ Data ³ 05.08.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se existe saldo em estoque para validar a venda.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³SigaLoja													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjVerEstoq()

Local lRet	  		:= .T.
Local nX 	  		:= 0
Local cCodigo 		:= CriaVar("L2_PRODUTO")
Local cMens 		:= ""                           
Local cMensDisp     := ""
Local nPosQuant  	:= aPosicoes[11][2] // L2_QUANT
Local nPosProd   	:= aPosicoes[09][2] // L2_PRODUTO
Local nPosTes		:= aPosicoes[05][2] // L2_TES
Local nPosLocal 	:= aPosicoes[14	][2] // L2_LOCAL
Local nPosReserva   := GdFieldPos( "L2_RESERVA" ) //Posicao do campo de reserva 
Local nSaldoEst     := 0                 // Saldo do Estoque
Local aCopyaCols    := {}                // Copia do aCols
Local cChave        := ""                // Chave para concatenacao
Local aProds        := {}                // Produtos para verificacao do estoque

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se o parametro MV_ESTNEG esta habilitado para barrar o estoque   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMV( "MV_ESTNEG" ) == "N"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faco a ordenacao por codigo + local do produto para concatenacao da qtde. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCopyaCols := aSort(aCols,,, { |x, y| x[nPosProd]+x[nPosLocal] < y[nPosProd]+y[nPosLocal] })
	
	For nX := 1 to Len( aCopyaCols )
		If !aTail( aCopyaCols[nX] )
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifico se a TES está habilitada para uso do controle de estoque.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF4->( MsSeek( xFilial( "SF4" ) + aCopyaCols[nX][nPosTES] ))
			If SF4->F4_ESTOQUE == "S"
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quebra por produto + local para montagem da array com os prods.           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cChave <> aCopyaCols[nX][nPosProd]+aCopyaCols[nX][nPosLocal]
					cChave := aCopyaCols[nX][nPosProd]+aCopyaCols[nX][nPosLocal]
					
					AAdd( aProds, Array(4) )
					aProds[Len(aProds)][1] := aCopyaCols[nX][nPosProd]
					aProds[Len(aProds)][2] := aCopyaCols[nX][nPosLocal]
					aProds[Len(aProds)][3] := aCopyaCols[nX][nPosReserva]
					aProds[Len(aProds)][4] := 0
				Endif
	
				aProds[Len(aProds)][4] += aCopyaCols[nX][nPosQuant]
				
			Endif
		Endif
		
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Iniciando verificacao de saldo junto ao arquivo SB2.                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len( aProds )
		If (SB2->(MsSeek(xFilial("SB2")+aProds[nX][1]+aProds[nX][2])))
			If !Empty( aProds[nX][3] )
				nSaldoEst := SB2->B2_QATU
			Else
				nSaldoEst := SaldoSB2()
			Endif
			        
			If SldBlqSB2(,,,.F.)
				If nSaldoEst < aProds[nX][4]
					lRet := .F.      
					cMens += Alltrim(aProds[nX][1]) + " - " + Alltrim(Posicione("SB1",1,xFilial("SB1")+aProds[nX][1],"B1_DESC")) + Chr(10)
				Endif
			Else
				cMensDisp += Trim(cCodigo) + " - " + Trim(Posicione("SB1",1,xFilial("SB1")+cCodigo,"B1_DESC")) + CHR(13) + CHR(10)
			Endif
		Else
			lRet := .F.      
			cMens += Alltrim(aProds[nX][1]) + " - " + Alltrim(Posicione("SB1",1,xFilial("SB1")+aProds[nX][1],"B1_DESC")) + Chr(10)
		Endif
	
	Next nX
	
	If !Empty( cMensDisp )
		MsgInfo( STR0068 + CHR(13) + CHR(10) + CHR(13) +  CHR(10) + cMensDisp, STR0069 )
		lRet := .F.
	Endif

	If !Empty( cMens )
		MsgInfo( cMens, STR0063 )	//"Produto com estoque negativo"
		lRet := .F.
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ljAtualCom³ Autor ³ Fernando Godoy		  ³ Data ³ 05/08/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o ComboBox com a condicao padrao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ljAtualCom																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SLJ010																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjAtualComb(cCombo,oCombo,aCondicoes,cCondicao,cComboAnt2)

Local nI

cCondicao := Upper(Substr(cComboAnt2,1,3))

For nI := 1 to Len(aCondicoes)
	If Upper(Alltrim(Substr(aCondicoes[nI],1,3)))==Upper(SubsTr(cCondicao,1,3))
		cCombo := aCondicoes[nI]
		oCombo:nAt := nI
		oCombo:Refresh()
		Exit
	Endif
Next nI

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ljVerChq	³ Autor ³ Fernando Godoy		  ³ Data ³ 05/08/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o cheque ja esta cadastrado						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ljVerChq 																  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SLJ010																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjVerChq(	cBanco    , cAgencia  , cConta   , cCheque  , oBanco    , ;
					oAgencia  , oConta    , oCheque  , npos     , cMesACta  , ;
					cAnoACta  , lTipoChq  , cCgcChq  , cNomeCli , cDddCli   , ;
					CPreTelCli, cSufTelCli, cSerChq  , oMesACta , oAnoACta  , ;
					oTipoChq  , oCgcChq   , oNomeCli , oDddCli  , oPreTelCli, ;
					oSufTelCli, oSerChq   , cTelefone, oTelefone, cRg       , ;
					oRg       , cComp     , oComp )

Local lRet      := .T.
Local cArea 	:= Alias()
Local nReg		:= Recno()
Local nIndex	:= IndexOrd()
Local cCheqDig  := cBanco + cAgencia + cConta + cCheque
Local cCheqCad
Local nI

If Empty(cBanco)
	Help(" ","1","NAOPREENBC")
	lRet := .F.
ElseIf Empty(cAgencia)
	Help(" ","1","NAOPREENAG")
	lRet := .F.
ElseIf Empty(cConta)
	Help(" ","1","NAOPREENCT")
	lRet := .F.
ElseIf Empty(cCheque)
	Help(" ","1","NAOPREENCH")
	lRet := .F.
Endif

If lSrvCns // Servidor de Consulta do Cheque-pre.com
	If Limpachar(cCgcChq) = ""
		Help(" ","1","NAOPREENCG")
		lRet := .F.
	Endif
	If Limpachar(cRG) = ""
		Help(" ","1","NAOPREENRG")
		lRet := .F.
	Endif
	If Limpachar(cMesACta) = ""
		Help(" ","1","NAOPREENMA")
		lRet := .F.
	Endif
	If Limpachar(cAnoACta) = ""
		Help(" ","1","NAOPREENCA")
		lRet := .F.
	Endif
Endif
If lRet
	dbSelectArea("SEF")
	dbSetOrder(1)
	If MsSeek( xFilial("SEF") + cCheqDig )
		Help(" ","1","CHEQJACAD")
		lRet := .F.
	Else
		For nI := 1 to Len(aReceb)
			If Upper(Alltrim(aReceb[nI][3])) == cSimbCheq
				cCheqCad := Alltrim(aReceb[nI][4]) + Alltrim(aReceb[nI][6]) +;
				Alltrim(aReceb[nI][7]) + Alltrim(aReceb[nI][5])
				If cCheqDig == cCheqCad .AND. nPos <> nI
					Help(" ","1","CHEQJAINF")
					lRet := .F.
					Exit
				Endif
			Endif
		Next nI
	Endif
Endif

*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ Retorna a Area anterior ³
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cArea)
dbSetOrder(nIndex)
dbGoto(nReg)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³MontParcel³ Autor ³ Antonio Maniero Jr.   ³ Data ³ 10/08/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Array com Parcelas de acordo com o digitado			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³LOJA010													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MontParcelas(aCondicoes,lEntrada,nValorBase,nEntrada,nFinanciado,;
                      nTxDesc,nParcelas,nIntervalo,nTipoJur,nDescLoj,nLiq,;
                      nDescPer)

Local aParc 		:= {}
Local nValorTotal 	:= 0.00
Local lPrice	  	:= Iif(SuperGETMV("MV_PRICE")   == "S",.T.,.F.)
Local lCalcFin    	:= Iif(SuperGETMV("MV_TXVISTA") == "S",.T.,.F.)
Local lArreFat      := ( SuperGetMV("MV_ARREFAT") <> "N" )
Local lAcrBru     	:= IIf(FUnname() == "LOJA220",.F.,SuperGetMV("MV_LJACBRU")) // Define se o Acrescimo eh pelo valor Bruto (T) ou pelo Liquido (F)
Local i			  	:= 1
Local j
Local nValor, nDivisor, nPrestacao
Local nValImps 		:= 0
Local nPrcParc 		:= 0
Local dDataRef
Local nValRateado 	:= 0
Local lCondNeg 		:= If(nIntervalo>0,.T.,.F.) 	// Indica se e condicao negociada ou nao
Local nDescDif		:= 0
Local nTotVenc      := 0
Local nDecs         := MsDecimais(nMoedaCor)
Local nValAcrs      := 0
Local dDataVcto
Local nTotAux
Local nValParc

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³nTipoJur = 1 - Simples | 2 - Serie Pgtos | 3 - Price            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipoJur := If(ValType(nTipoJur)=="U",1, nTipoJur)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ajuste das variáveis para tratamento das parcelas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dDataRef := If(dDataCN==NIL,aAltDtBase[2],dDataCN)
lEntrada := If(nEntrada>0,.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento do lCalcFin                                                                 ³
//³So pode ser False, quando a dDatabase = data 1a parcela e o parametro MV_TXVISTA = "N" ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lCalcFin
	If lCondNeg
		lCalcFin := If( dDataRef == aAltDtBase[2], .F., .T. )
	Else
		lCalcFin := If( aCondicoes[1][1] == dDataBase, .F., .T. )
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula e monta as parcelas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cPaisLoc <> "BRA")
	If FunName() == "FRTA010" 
		//Caso exista desconto ou acrescimo financeiro eh necessario exibir
		//mensagem, pois o processo eh um pouco lento...
		If (nTxJuros > 0) .OR. (nTxDesc > 0)
		    //"Fazendo o calculo do acrescimo/desconto e o recalculo dos impostos..."
			LJMsgRun(STR0070,,{|| nValImps:=Lj010RecVB(@nValorBase,nTxJuros,nTxDesc,nDescLoj,@nLiq,nDescPer,nTipoJur,nParcelas,nEntrada)})
		Else 
			nValImps:=Lj010RecVB(@nValorBase,nTxJuros,nTxDesc,nDescLoj,@nLiq,nDescPer,nTipoJur,nParcelas,nEntrada)		
		Endif
	ElseIf FunName() $ "LOJA010|LOJA220" 
		nValImps := Lj010RecVB(@nValorBase,nTxJuros,nTxDesc,nDescLoj,@nLiq,nDescPer,nTipoJur,nParcelas,nEntrada)		
	Endif
Endif


If (lPrice .AND. !lCondNeg) .OR. (nTipoJur == 3 .AND. lCondNeg) .AND. nTxJuros > 0
	nValor := nValorBase+If(lAcrBru,nDescLoj,0)-LJ010VlrFSD()
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a entrada já vier informada via parâmetro eh porque  foi digitada via condicao negociada    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValorAux := nValorBase+if(lAcrBru,nDescLoj,0)-LJ010VlrFSD()
	nEntrada  := If(nEntrada<>0,nEntrada,If(!lCalcFin,(nValorAux+If(cPaisLoc<>"BRA",nValImps,0))/nParcelas,0))

	If !lCalcFin // Calcula Juros pelo Valor Financiado
		nFinanciado:= nValorAux - nEntrada
		// Verifica Se e Pagamento a Vista, Senao Abate a Entrada....
		nValor := Round(nValorAux - nEntrada,nDecimais)
		// .. e Calcula Juros sobre Valor Final
		If nTipoJur = 1 .AND. nTxJuros > 0
			nValor  := Round(nValorAux+((nValorAux-nEntrada)*nTxJuros/100),nDecimais)
		ElseIf nTipoJur = 2 .AND. nTxJuros > 0
			nValor  := Round(nFinanciado * (( 1+ ( nTxJuros/100 ) ) ^ (nParcelas - (if(nEntrada>0,1,0)))) ,nDecimais)
			nValor += nEntrada
		Else
			nValor += nEntrada
		Endif
	Else
		nValor	 := nValorAux
		// Calcula Juros pelo Montante
		If nTipoJur = 1 .AND. nTxJuros > 0
			nValor := IIf( lArreFat,Round(nValor+(nValor*nTxJuros/100),nDecimais),NoRound(nValor+(nValor*nTxJuros/100),nDecimais))
		ElseIf nTipoJur = 2 .AND. nTxJuros > 0
			nValor := IIf( lArreFat,Round(nValor * (( 1+ ( nTxJuros/100 ) ) ^ nParcelas) ,nDecimais),NoRound(nValor * (( 1+ ( nTxJuros/100 ) ) ^ nParcelas) ,nDecimais))
		Endif
	Endif
	nValor -= if(lAcrBru,nDescLoj,0)
Endif

// Verifica Se Ha Desconto na forma de pagto
// e calcul	a Desconto na Entrada Tambem, Se Houver...
If cPaisLoc == "BRA"
	If nTxDesc <> 0
		If lPrice
			nValor -= If(lAcrBru,nDescLoj,0)
		Endif
		nVlrTxDesc := nValor*nTxDesc/100
		nValor := Round(nValor-nVlrTxDesc,nDecimais)
		nEntrada := Round(nValor / nParcelas,nDecimais)
		lEntrada   := .T.
	Else
		nVlrTxDesc := 0
	Endif
Else
	If nTxDesc <> 0
		nVlrTxDesc := aDadosJur[9]
		nValor     -= nVlrTxDesc
		nEntrada   := Round((nValor+nValImps) / nParcelas,nDecimais)
		lEntrada   := .T.
	Else
		nVlrTxDesc := 0
	Endif
Endif

//Agrega o valor do imposto para o calculo do valor da(s) parcela(s)              
//e tambem do valor financiado.
If cPaisLoc <> "BRA"
	If Round(nValor-nValorBase,nDecimais) > aDadosJur[1]
		nValor -= (nValor-nValorBase)
		nValor += aDadosJur[1]
	ElseIf (Round(nValor-nValorBase,nDecimais) < aDadosJur[1]) .AND. (nTipoJur == 2)
		aDadosJur[1] -= (aDadosJur[1] - (nValor-nValorBase))
	Endif
	nValor += nValImps
Endif

// Se os Juros sao Pelo Montante Entao Abate, apos descontos, a entrada
If !lCalcFin
	nFinanciado := Round(nValor - nEntrada,nDecimais)
Else
	nFinanciado := Round(nValor,nDecimais)
Endif

If nEntrada <> 0
	Aadd( aParc, { Iif(nIntervalo<>0 .OR. !lEntrada,dDataRef,aCondicoes[1][1]) , Iif(nParcelas==1,nValor,nEntrada) } )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for separar o acrescimo, precisa recalcular a proporcao de valores das parcelas, pois quando se utiliza ³
//³condicao tipo 8, os percentuais podem variar e o recalculo, neste caso - com tipo 8 e acrescimo separado - ³
//³deve ignorar o percentual da primeira parcela, onde vai ficar apenas o acrescimo                           ³
//³                                                                                                           ³
//³Esta variavel nTotAux sera utilizada para recalcular esta proporcao.                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SE4->E4_ACRES == "S" .AND. !lCondNeg
	nTotAux	 := 0
	for i := 2 to nParcelas
		nTotAux += aCondicoes[i,2]
	next i
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Checa se ha valor de frete/seguro/desp. para ser rateado entre as parcelas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For j := If(nEntrada>0,2,1) to nParcelas
	dDataVcto := If(!lCondNeg, aCondicoes[j][1], dDataRef+(nIntervalo*(j-1)) )
	nValAcrs := Max( 0, nFinanciado - nValorBase )
	
	If SE4->E4_ACRES == "S" .AND. !lCondNeg
		If j == 1
			nValParc := Round( nValAcrs, nDecs )
		else
			aCondicoes[j,2] := (nFinanciado-nValAcrs) * ( aCondicoes[j,2] / nTotAux )
			nValParc := Round((nFinanciado-nValAcrs-If(lCalcFin,nEntrada,0))*(aCondicoes[j,2]/(nFinanciado-nValAcrs)), nDecs)
		Endif
	ElseIf SE4->E4_ACRES == "J" .AND. !lCondNeg
		nValParc := Round((nFinanciado-nValAcrs-If(lCalcFin,nEntrada,0))*(aCondicoes[j,2]/(nFinanciado-nValAcrs)), nDecs) + if( J == 1, nValAcrs, 0 )
	Else
		If lCondNeg
			nValParc := Round((nFinanciado-If(lCalcFin,nEntrada,0))/(nParcelas-Iif(nEntrada==0,0,1)) ,nDecs  )
		ElseIf AllTrim(SE4->E4_TIPO) == "8"
			nValParc := Round((nFinanciado-If(lCalcFin,nEntrada,0))*(aCondicoes[j,2]/(nFinanciado-nValAcrs)), nDecs)
		Else
			nValParc := Round((nFinanciado-If(lCalcFin,nEntrada,0))/(nParcelas-Iif(nEntrada==0,0,1)) ,nDecs  )
		Endif
	Endif
	aAdd( aParc, { dDataVcto, nValParc } )
Next j

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se sera usado a tabela PRICE para	³
//³ calcular o valor das parcelas				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ((lPrice .AND. !lCondNeg) .OR. (nTipoJur == 3 .AND. lCondNeg)) .AND. nTxJuros > 0

	nEntrada := 0
	nPrcParc := nParcelas
	If lEntrada		// Verifica se foi digitada a entrada via condicao negociada.
		For j  := 1 To Len(aParc)
			If aParc[j][1] == aAltDtBase[2]
				nEntrada += aParc[j][2]
				nPrcParc --
			Endif
		Next j
	Endif
	nValTaxa := nTxJuros / 100
	nDivisor := (1 + nValTaxa) ^ nPrcParc

	nPrestacao := (nValor-nEntrada) * ((nDivisor * nValTaxa) / (nDivisor -1))
	
	nFinanciado := 0
	For j  := 1 To Len(aParc)
		If aParc[j][1] <> aAltDtBase[2] .OR. !lEntrada
			aParc[j][2]	:= Round(nPrestacao,nDecimais)
			nFinanciado += aParc[j][2]
		Endif
	Next j

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se calcula o juros sobre o valor bruto ou liquido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAcrBru
		nDescDIf 	:= 0
		nValRateado := NoRound(nDescLoj / Len(aParc),2)
		If (nValRateado * Len(aParc)) <> nDescLoj
			nDescDIf := nDescLoj - (nValRateado * Len(aParc))
		Endif
		nFinanciado := 0
		For j := 1 To Len(aParc)
			aParc[j][2] := aParc[j][2] - nValRateado - If(j=Len(aParc),nDescDif,0)
			nFinanciado += aParc[j][2]
		Next j		
		nVlrDesc := nDescLoj
		oVlrDesc:Refresh()		
	Endif
	
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se e necessario mexer no arredondamento das parcelas ³
	//³para evitar o SOMAPARCOK                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValorTotal := 0
	aEval( aParc, {|x| nValorTotal += x[2] } )
	If (nValorTotal) <> (nFinanciado + If(!lCalcFin,nEntrada,0))
		aParc[Len(aParc)][2] += ((nFinanciado + If(!lCalcFin,nEntrada,0)) - nValorTotal)
	Endif

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se eh necessario ratear o valor do frete ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nVlrFSD > 0
	nDescDIf 	:= 0
	nValRateado := NoRound(LJ010VlrFSD() / Len(aParc),2)
	For j := 1 to Len(aParc)
		aParc[j][2] += nValRateado
	Next j
	If (nValRateado * Len(aParc)) <> LJ010VlrFSD()
		aParc[Len(aParc)][2] += (LJ010VlrFSD() - (nValRateado * Len(aParc)))
	Endif
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ajusta o valor do acrescimo e nFinanciado        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nValorTotal := 0
aEval( aParc, {|x| nValorTotal += x[2] } )
nVlrAcrs := nValorTotal - nValorBase

nFinanciado := nValorTotal - If(lEntrada,nEntrada,0)

If cPaisLoc <> "BRA"
	nTotVenc := 0	
	For i := 1 to Len(aParc)-1
		aParc[i][2] := Round(aParc[i][2],MsDecimais(nMoedaCor))
		nTotVenc += aParc[i][2]
	Next i
	aParc[Len(aParc)][2] := Round(nValorTotal-nTotVenc,MsDecimais(nMoedaCor))
	nValorBase := nValorTotal
Endif

Return aParc


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³CalcFator³ Autor ³ Fernando Godoy 		  ³ Data ³ 08/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Array com Parcelas de acordo com o digitado			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ 																			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Calcula e mostra as parcelas com fator financeiro. 		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CalcFator(oDlgLojaJur,aLbxFator,oLbxFator,lUsaAdmFin,;
cComboAdm,cCondicao)
/*
Local aCoors
Local aArea   := GetArea( )
Local lRet	  := .T.
Local cCodFin := Substr( cComboAdm, 1,3 )
Static nDlgHeight
Static nVezes := 1

oDlgLojaJur:CoorsUpdate( ) 	// Atualiza as coordenadas da janela
aCoors:= GetClientRect( oDlgLojaJur:hWnd )	// Pega as coordenadas

If nVezes == 1
nDlgHeight := oDlgLojaJur:nHeight	// pega a altura da janela
Endif

nVezes ++

If lUsaAdmFin
oDlgLojaJur:nHeight := nDlgHeight + 100
oLbxFator:Enable( )
WndCenter( oDlgLojaJur:hWnd ) // Centraliza a janela

nFAtorCond := 0.36035
nTotalFat  := 100
nParceFat  := 3
nUnitFat   := 0
nParc 	  := 3
nEnt		  := 0
aParcel	  := { "   ","1121"}

//lRet := RetFator( cCodFin, @nFatorCond, cCondicao )

If lRet
aParFator := l010CalcFat(@nFatorCond,@nTotalFat,@nParceFat, @nUnitFat,;
aParcel,nParc,nEnt)
Endif
Else
oDlgLojaJur:nHeight := nDlgHeight
oLbxFator:Disable( )
WndCenter( oDlgLojaJur:hWnd ) // Centraliza a janela
Endif

RestArea( aArea )
*/
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³CalcFatWin³ Autor ³ Fernando Godoy	     ³ Data ³ 14/04/98³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula as parcelas com fator multiplicador.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ExpA1 - Parcelas em um array multidimencional (Data - Valor)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³SigaLoja													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DATA     ³ BOPS ³Prograd.³ALTERACAO                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|09/08/05  ³082979³Hanna   ³Implementada a alteracao do calculo do fator|±±
±±|          ³      ³        ³na venda balcao                             |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CalcFatWin(aValores,nEntrada,nTotFat,nNumParc,cCondPag,cCodAdm,nFator)
Local aParcFat   := {}
Local aArea 	 := GetArea()
Local nTotalRes  := 0
Local nDif		 := 0
Local cIncideEnt := 0
Local cTipoFin   := SuperGetMV("MV_TPFATOR") //Tipo de Fator no Total ou por Parcelas
Local lLjAdmTax  := ExistBlock("LJADMTAX")
Local nAdmTax    := 0
Local lArreFin   := SuperGetMV("MV_ARREFIN")
Local nI         := 0

If lLjAdmTax
	nAdmTax:= ExecBlock("LJADMTAX",.F.,.F.,{cCodAdm})
Endif

dbSelectArea("SAF")
dbSetOrder(1)
MsSeek( xFilial("SAF") + cCodAdm + cCondPag )

cIncideEnt := SAF->AF_ENTRADA
         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se houver entrada e nao incidir na entrada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nEntrada > 0 .AND. lEntFin) .AND. (cIncideEnt <> "S")
	nNumParcRes := nNumParc - 1
	
	nUnitFat	 	:= nTotFat
	
	If (cTipoFin == "T")                   //Fator de multiplicacao no total
		nUnitFat	 	:= (nTotFat * nFator)
		nUnitFat		:= ((nUnitFat - nEntrada) / nNumParcRes)
		
		If lArreFin
			nTotFat	:= Round(( nTotFat * nFator ),2 )
		Else
			nTotFat	:= NoRound(( nTotFat * nFator),2 )
		Endif
		
	Else //fator de multiplicacao por parcelas
		nUnitFat		:= ((nUnitFat - nEntrada) / nNumParcRes)
		
		If lArreFin
			nTotFat	:= Round( (nUnitFat * nNumParcRes * nFator) + nEntrada, 2)
		Else
			nTotFat	:= NoRound( (nUnitFat * nNumParcRes * nFator) + nEntrada, 2)
		Endif
		
	Endif
	
	If lArreFin
		Aadd( aParcFat , { aValores[1][1],Round(nEntrada + nAdmTax,2) } )
	Else
		Aadd( aParcFat , { aValores[1][1],NoRound(nEntrada + nAdmTax,2) } )
	Endif
	
	nTotalRes   := nEntrada
	For nI := 2 to Len(aValores)
		If lArreFin
			If cTipoFin == "T"					//Fator de multiplicacao no total
				Aadd( aParcFat , { aValores[nI][1],Round(nUnitFat + nAdmTax,2) } )
				nTotalRes += Round(nUnitFat,2)
			Else								//Fator de multiplicacao nas parcelas
				Aadd( aParcFat , { aValores[nI][1],Round((nUnitFat + nAdmTax) * nFator ,2) } )
				nTotalRes += Round(nUnitFat * nFator ,2)
			Endif
		Else
			If cTipoFin == "T"					//Fator de multiplicacao no total
				Aadd( aParcFat , { aValores[nI][1],NoRound(nUnitFat + nAdmTax,2) } )
				nTotalRes += NoRound(nUnitFat,2)
			Else								//Fator de multiplicacao nas parcelas
				Aadd( aParcFat , { aValores[nI][1],NoRound((nUnitFat + nAdmTax) * nFator ,2) } )
				nTotalRes += NoRound(nUnitFat * nFator ,2)
			Endif
		Endif
	Next nI
	
	nNumParcRes := nNumParc
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se houver entrada e incidir na entrada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nEntrada > 0 .AND. lEntFin) .AND. (cIncideEnt == "S")
		nNumParcRes := nNumParc
		
		nUnitFat 	:= nTotFat + nAdmTax
		
		If (cTipoFin == "T")                 //Fator de multiplicacao no total
			nUnitFat 	:= (nTotFat + nAdmTax) * nFator
			nUnitFat 	:= nUnitFat / nNumParcRes
			
			If lArreFin
				nTotFat	:= Round(nTotFat * nFator,2)
			Else
				nTotFat	:= NoRound(nTotFat * nFator,2)
			Endif
		Else                               //Fator de multiplicacao por parcelas
			nUnitFat		:= nUnitFat  / nNumParcRes
			If lArreFin
				nTotFat	:= Round(nUnitFat * nNumParcRes * nFator ,2)
			Else
				nTotFat	:= NoRound(nUnitFat * nNumParcRes * nFator ,2)
			Endif
		Endif
		nTotalRes	:= 0
		
		If lEntFin
			For nI := 1 to Len(aValores)
				If lArreFin
					If cTipoFin == "T"						//Fator de multiplicacao no total
						Aadd( aParcFat , { aValores[nI][1],Round(nUnitFat + nAdmTax,2)} )
						nTotalRes += Round(nUnitFat,2)
					Else									//Fator de multiplicacao nas parcelas
						Aadd( aParcFat , { aValores[nI][1],Round((nUnitFat + nAdmTax) * nFator ,2)} )
						nTotalRes += Round(nUnitFat * nFator ,2)
					Endif
				Else
					If cTipoFin == "T"						//Fator de multiplicacao no total
						Aadd( aParcFat , { aValores[nI][1],NoRound(nUnitFat + nAdmTax,2)} )
						nTotalRes += NoRound(nUnitFat,2)
					Else									//Fator de multiplicacao nas parcelas
						Aadd( aParcFat , { aValores[nI][1],NoRound((nUnitFat + nAdmTax) * nFator ,2)} )
						nTotalRes += NoRound(nUnitFat * nFator ,2)
					Endif
				Endif
			Next nI
		Else
			If lArreFin
				If cTipoFin == "T"							//Fator de multiplicacao no total
					Aadd( aParcFat , { aValores[1][1],Round(nEntrada + nAdmTax,2) } )
				Else										//Fator de multiplicacao nas parcelas
					Aadd( aParcFat , { aValores[1][1],Round((nEntrada + nAdmTax) * nFator ,2) } )
				Endif
			Else
				If cTipoFin == "T"							//Fator de multiplicacao no total
					Aadd( aParcFat , { aValores[1][1],NoRound(nEntrada + nAdmTax,2) } )
				Else										//Fator de multiplicacao nas parcelas
					Aadd( aParcFat , { aValores[1][1],NoRound((nEntrada + nAdmTax) * nFator ,2) } )
				Endif
			Endif
			
			For nI := 2 to Len(aValores)
				Aadd( aParcFat , { aValores[nI][1],Round(nUnitFat + nAdmTax,2)} )
				
				If lArreFin
					nTotalRes += Round(nUnitFat,2)
				Else
					nTotalRes += NoRound(nUnitFat,2)
				Endif
			Next nI
			
		Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao houver entrada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Else
		
		nTotFat := nTotFat + nAdmTax
		
		nNumParcRes := nNumParc
		
		If lArreFin
			nUnitFat 	:= Round(nTotFat * nFator ,2)	 // Vlr de Cada parc
		Else
			nUnitFat 	:= NoRound(nTotFat * nFator ,2)	 // Vlr de Cada parc
		Endif
		
		If (cTipoFin == "T")               //Fator de multiplicacao no total
			nUnitFat := NoRound(nUnitFat / nNumParc,2)
			
			If lArreFin
				nTotFat  := Round(nTotFat * nFator,2)
			Else
				nTotFat  := NoRound(nTotFat * nFator,2)
			Endif
		Else                               //Fator de multiplicacao por parcelas
			nTotFat		:= nUnitFat
			If lArreFin
				nUnitFat	:= Round(nUnitFat / nNumParc,2)
			Else
				nUnitFat	:= NoRound(nUnitFat / nNumParc,2)
			Endif
		Endif
		
		nTotalRes	:= 0
		If lEntFin
			
			For nI := 1 to Len(aValores)
				If Trim(aPgtos[nI][3]) == "FI"
					Aadd( aParcFat , { aValores[nI][1],Round(nUnitFat + nAdmTax,2)} )
					             
					If lArreFin
						nTotalRes += Round(nUnitFat,2)
					Else
						nTotalRes += NoRound(nUnitFat,2)
					Endif
				Endif
			Next nI
			
		Else              
			If AllTrim(aPgtos[1][3]) == "FI"
				If lArreFin
					Aadd( aParcFat , { aValores[1][1],Round(nEntrada + IIf(lEntFin,nAdmTax,0),2) } )
				Else
					Aadd( aParcFat , { aValores[1][1],NoRound(nEntrada + IIf(lEntFin,nAdmTax,0),2) } )
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso exista entrada, realizo o calculo a partir da 2 parcela³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nI := 2 to Len(aValores)
				If Trim(aPgtos[nI][3]) == "FI"
					Aadd( aParcFat , { aValores[nI][1],Round(nUnitFat + nAdmTax,2)} )
					
					If lArreFin
						nTotalRes += Round(nUnitFat,2)
					Else
						nTotalRes += NoRound(nUnitFat,2)
					Endif
				Endif
			Next nI
			
		Endif
	Endif
Endif

If lArreFin
	If Round(nTotFat,2) <> Round(nTotalRes,2)
		nDIf := Abs(nTotalRes - nTotFat)
	Endif
Else
	If Round(NoRound(nTotFat,2),2) <> Round(NoRound(nTotalRes,2),2)
		nDIf := Abs(nTotalRes - nTotFat)
	Endif
Endif

If (Abs( nDIf ) > 0)
	If lArreFin
		aParcFat[Len(aParcFat)][2] := Round(nUnitFat + nDIf + nAdmTax,2)
	Else
		aParcFat[Len(aParcFat)][2] := NoRound(nUnitFat + nDIf + nAdmTax,2)
	Endif
	
	nTotFat += nDif
Endif

RestArea(aArea)

Return aParcFat


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LJRecalTri³ Autor ³ Fernando Godoy		³ Data ³ 05/05/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Func„o utilizada para recalcular os tributos quando houver ³±±
±±³			 ³ desconto no total ou na condicao de pagamento.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³ ExpC1 - Define a origem do Recalculo						  ³±±
±±³			 ³ 	Ex: LjOriRecal("Desconto") - O recalculo parte do Desc    ³±±
±±³			 ³ 	no Total da nota fiscal.								  ³±±
±±³			 ³ ExpL1 - Venda com fator financeiro ou n„o 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ NIL														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Sigaloja 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DATA     ³ BOPS ³Prograd.³ALTERACAO                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|15/12/05  ³089947³Geronimo³Implementada correcao para correta gravacao |±±
±±|          ³      ³        ³dos campos de valores nas vendas financiadas|±±
±±|          ³      ³        ³com uso da tabela price.                    |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|24/01/06  ³091959³Geronimo³Implementada correcao no recalculo da base e|±±
±±|          ³      ³        ³valor do Icms quando existe desconto no     |±±
±±|          ³      ³        ³total e tambem na cond. pagto. (E4_DESCFIN) |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ljRecalTrib(cOriRecal    ,lFator    ,cNumOrc    ,nTxDescon   ,;
					 nEntrada     ,nDescloj  ,nValorBase ,nLiq         )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de Vari veis Locais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nTotIcms  		:= 0
Local nTotIpi			:= 0
Local nTotIss			:= 0
Local nTotItem  		:= 0
Local nBaseIcms 		:= 0
Local nVlrIss			:= 0
Local nVlrIpi			:= 0
Local nValIcms  		:= 0
Local nDescTot  		:= 0
Local nAcrsTot  		:= 0
Local nVlrTotOrc		:= 0
Local nVlrTotDes		:= 0
Local nEntradRat		:= 0
Local lTxVista  		:= Iif(SuperGetMv("MV_TXVISTA")=="S",.T.,.F.)
Local lCalcFin  		:= Iif(SuperGetMv("MV_CALCFIN")=="F",.T.,.F.)
Local lAcrBru   		:= SuperGetMV("MV_LJACBRU") // Define se o Acrescimo eh pelo valor Bruto (T) ou pelo Liquido (F)
Local nValSemAcr		:= 0
Local nA 				:= 0
Local nRegis			:= 0
Local nI, nX 			:= 0
Local nDifer			:= 0
Local nTotalGer			:= 0
Local nTotalSL1 		:= 0
Local nTotalSL2 		:= 0
Local nPosTotal 		:= aPosicoes[2][2]
Local nRndFat 			:= MsDecimais(nMoedaCor)
Local nRndItem			:=	Iif(cPaisLoc=="BRA",TAMSX3("L2_VRUNIT")[2],Iif(TAMSX3("L2_VRUNIT")[2]<=2,nRndFat,TAMSX3("L2_VRUNIT")[2]))
Local cCampo 			:= ""
Local aImpsSL1 			:= {}
Local nPos				:= 0
Local nVlrAux			:= 0
Local lPrice	  		:= Iif(SuperGETMV("MV_PRICE")   == "S",.T.,.F.)// Verifica se estah usando Tabela Price
Local lCondNeg     		:= ( Trim( SL1->L1_CONDPG ) == "CN" )    	// Verifica se eh condicao negociada
Local nDescAux 			:= 0										// Desconto total da Venda (sem o desconto financeiro)
Local nDescProPercen	:= 0										// Percentual deste desconto
Local nDescFimAux 		:= 0 										// Desconto total do Item (sem o desconto financeiro)
Local cMVArreFat		:= SuperGetMv("MV_ARREFAT")					// Indica se arredonda o total da venda.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no primeiro registro do orcamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SL2")
dbSetorder(1)
MsSeek( xFilial("SL2") + cNumOrc )
nRegis	:= recno()
nX 		:= 0
nDif		:= 0
nTotIcms := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia o processo de transa‡„o        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recalcula todos os Itens do or‡amento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While SL2->L2_FILIAL == xFilial("SL2") .AND. SL2->L2_NUM == SL1->L1_NUM 	.AND. !Eof()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no produto em questao no orcamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SB1")
	dbSetOrder(1)
	MsSeek(xFilial("SB1") + SL2->L2_PRODUTO)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no Tes em questao no orcamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF4")
	dbSetOrder(1)
	MsSeek(xFilial("SF4") + SL2->L2_TES)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna o Foco para o arquivo de orcamentos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SL2")
	
	nX++
	
	If cPaisLoc == "BRA"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso a origem for para recalculo em virtude 	  ³
		//³ de acrescimo ou Desconto na condicao de pagamento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If UPPER(cOriRecal) == "CONDPAG"
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o produto em questao ‚ ³
			//³ isento de todas os tributos. 	   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !((SF4->F4_LFIPI == "I" .OR. SF4->F4_LFIPI == "N" .OR. SF4->F4_LFIPI == " ") .AND.;
				(SF4->F4_LFICM == "I"   .OR. SF4->F4_LFICM == "N" .OR. SF4->F4_LFICM == " ") .AND.;
				(SF4->F4_LFISS == "I"   .OR. SF4->F4_LFISS == "N" .OR. SF4->F4_LFISS == " "))
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Obtem o valor total do item da mesma maneira   ³
				//³ que o gatilho. (Valor Ja sem desconto no item) ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nTotItem  := NoRound(SL2->L2_PRCTAB - ((SL2->L2_PRCTAB * SL2->L2_DESC) /100),nRndFat)
				nTotItem  := NoRound(nTotItem * SL2->L2_QUANT,nRndFat)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Proporcionaliza a Entrada caso Exista ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nTxJuros > 0 .AND. nEntrada > 0
					nValSemAcr := 0
					For nA:= 1 to Len(aCols)
						nValSemAcr += aCols[nA][nPosTotal]
					Next nA
					nValSemAcr -= nDescLoj
					nEntradRat := nEntrada * (SL2->L2_VLRITEM / nValSemAcr)
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso o juros nao incidir na parcela a vista, ³
				//³ subtrai a entrada proporcionalizada			 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nEntrada > 0
					If lCalcFin .AND. nTxJuros > 0		  // Calculo pelo valor financiado
						nTotItem := (nTotItem - nEntradRat)
					ElseIf !lCalcFin .AND. nTxJuros > 0   // Calculo pelo vlr total (Montante).
						If !lTxVista .AND. nTxJuros > 0
							nTotItem := (nTotItem - nEntradRat)
						Endif
					Endif
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se nao houver juros e entrada pego desconto direto da base.                   ³
				//³ Se houver carrego desconto no total proporcionalizado no item                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nDescTot  := SL2->L2_DESCPRO
				If nTxJuros > 0 .AND. nEntrada > 0
					If nTxDescon > 0
						nDescAux := SL1->L1_VALMERC - SL1->L1_VLRTOT   // Desconto total da Venda (sem o desconto financeiro)
						nDescProPercen := nDescAux / SL1->L1_VALMERC	// Percentual deste desconto
						nDescFimAux := nTotItem * nDescProPercen		// Desconto total do Item (sem o desconto financeiro)
						If cMVArreFat == "S"
							nDescTot  := Round((( (nTotItem - nDescFimAux ) * nTxDescon)/100),2)		// Calculo o desconto financeiro do item
							nDescTot  := nDescTot + nDescFimAux			// Somo ao desconto financeiro o desconto do Item
						Else
							nDescTot  := NoRound((( (nTotItem - nDescFimAux ) * nTxDescon)/100),2)		// Calculo o desconto financeiro do item
							nDescTot  := nDescTot + nDescFimAux			// Somo ao desconto financeiro o desconto do Item
						Endif
					Endif
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega o Acrescimo no total do item ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ! ((lPrice .AND. !lCondNeg) .OR. ( SL1->L1_TIPOJUR == 3 .AND. lCondNeg))
					If cMVArreFat == "S"
						If lAcrBru
							nAcrsTot  := Round((((SL2->L2_PRCTAB * SL2->L2_QUANT) * nTxJuros)/100),2)
						Else
							nAcrsTot  := Round(((nTotItem * nTxJuros)/100),2)
						Endif
					Else
						If lAcrBru
							nAcrsTot  := NoRound((((SL2->L2_PRCTAB * SL2->L2_QUANT) * nTxJuros)/100),2)
						Else
							nAcrsTot  := NoRound(((nTotItem * nTxJuros)/100),2)
						Endif
					Endif
				Else
					nVlrAux := 0
					aEval( aPgtos, {|x| nVlrAux += x[2] } )
					nVlrAux -= (nValorBase + LJ010VlrFSD())
					If cMVArreFat == "S"					
						nAcrsTot := NoRound( nVlrAux * (nTotItem / nValorBase), 2 )
					Else
						nAcrsTot := Round( nVlrAux * (nTotItem / nValorBase), 2 )
					Endif
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Soma os Juros no total do item ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nEntrada > 0
					If lCalcFin .AND. nTxJuros > 0	 // Calculo pelo valor financiado
						nTotItem := (nTotItem + nEntradRat)
					ElseIf !lCalcFin .AND. nTxJuros > 0 // Calculo pelo vlr total.
						If !lTxVista .AND. nTxJuros > 0
							nTotItem := (nTotItem + nEntradRat + nAcrsTot)
						Else
							nTotItem := (nTotItem + nAcrsTot)
						Endif
					Endif
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso Exista IPI recalcula ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF4->F4_IPI == "S"
 				   nVlrIpi := Lj010Ipi(SL2->L2_PRCTAB,SL2->L2_QUANT,SL2->L2_DESC,nTxDescon,SL2->L2_TES,FRTPegaIT( SL2->L2_ITEM ),SL2->L2_PRODUTO,,SL2->L2_VALFRE,SL2->L2_SEGURO,SL2->L2_DESPESA)
				Else
					nVlrIpi := 0
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso Exista ICMS recalcula ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nBaseIcms := SL2->L2_BASEICM
				If SF4->F4_ICM == "S"
					If nEntrada > 0
						If nDescTot > 0
							nBaseIcms := nTotItem - nDescTot
						ElseIf nAcrsTot > 0 .AND. lCalcFin
							nBaseIcms := nTotItem + nAcrsTot
							nTotItem  := nBaseIcms
						Else
							nBaseIcms := nTotItem
						Endif
					Else
						If nAcrsTot > 0
							nBaseIcms := nTotItem + nAcrsTot
						ElseIf nDescTot > 0
							nBaseIcms := nTotItem - nDescTot
						Endif
					Endif
					nBaseIcms += LJ010VlrFSD()	// O valor do frete deve compor a base de calculo
					nValIcms := lj010Icms(nx,@nDif,@nBaseIcms,"CONDPAG",nVlrIpi)
				Else
					nValIcms := 0
				Endif
				
				// Recalcula o ISS
				If SF4->F4_ISS == "S"
					If nTxJuros > 0
						nVlrIss := Lj010Iss(nTotItem-If(nEntrada > 0 .AND. nAcrsTot > 0,nAcrsTot,0),.T.,,nTxJuros)
					Else
						nVlrIss := Lj010Iss(nTotItem-If(nEntrada > 0 .AND. nAcrsTot > 0,nAcrsTot,0),.T.,nTxDescon,)
					Endif
				Else
					nVlrISS := 0
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Adiciona ou Subtrai as Taxas para gravar no SL2 e SL1 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nEntrada == 0
					If nAcrsTot > 0
						nTotItem += nAcrsTot
					ElseIf nDescTot > 0
						nTotItem -= nDescTot
					Endif
				Endif
				
			Else
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Obtem o valor total do item da mesma maneira	³
				//³ que o gatilho. (Valor Ja sem desconto no item) ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nTotItem  := NoRound(SL2->L2_PRCTAB - ((SL2->L2_PRCTAB * SL2->L2_DESC) /100),nRndFat)
				nTotItem  := NoRound(nTotItem * SL2->L2_QUANT,nRndFat)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Proporcionaliza a Entrada caso Exista ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nTxJuros > 0 .AND. nEntrada > 0
					nValSemAcr := 0
					For nA:= 1 to Len(aCols)
						nValSemAcr += aCols[nA][nPosTotal]
					Next nA
					nValSemAcr -= nDescLoj
					nEntradRat := nEntrada * (SL2->L2_VLRITEM / nValSemAcr)
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso o juros nao incidir na parcela a vista, ³
				//³ subtrai a entrada proporcionalizada			 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nEntrada > 0
					If lCalcFin .AND. nTxJuros > 0		  // Calculo pelo valor financiado
						nTotItem := (nTotItem - nEntradRat)
					ElseIf !lCalcFin .AND. nTxJuros > 0   // Calculo pelo vlr total (Montante).
						If !lTxVista .AND. nTxJuros > 0
							nTotItem := (nTotItem - nEntradRat)
						Endif
					Endif
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se nao houver juros e entrada pego desconto direto da base.                   ³
				//³ Se houver carrego desconto no total proporcionalizado no item                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nDescTot  := SL2->L2_DESCPRO
				If nTxJuros > 0 .AND. nEntrada > 0
					If nTxDescon > 0
						nDescAux := SL1->L1_VALMERC - SL1->L1_VLRTOT
						nDescProPercen := nDescAux / SL1->L1_VALMERC
						nDescFimAux := nTotItem * nDescProPercen						
						If cMVArreFat == "S"
							nDescTot  := Round((( (nTotItem - nDescFimAux ) * nTxDescon)/100),2)
							nDescTot  := nDescTot + nDescFimAux
						Else
							nDescTot  := NoRound((( (nTotItem - nDescFimAux ) * nTxDescon)/100),2)
							nDescTot  := nDescTot + nDescFimAux
						Endif
					Endif
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega o Acrescimo no total do item ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lAcrBru
					If cMVArreFat == "S"
						nAcrsTot  := Round((((SL2->L2_PRCTAB * SL2->L2_QUANT) * nTxJuros)/100),2)
					Else
						nAcrsTot  := NoRound((((SL2->L2_PRCTAB * SL2->L2_QUANT) * nTxJuros)/100),2)
					Endif
				Else
					If cMVArreFat == "S"
						nAcrsTot  := Round(((nTotItem * nTxJuros)/100),2)
					Else
						nAcrsTot  := NoRound(((nTotItem * nTxJuros)/100),2)
					Endif
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Soma os Juros no total do item ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nEntrada > 0
					If lCalcFin .AND. nTxJuros > 0	 // Calculo pelo valor financiado
						nTotItem := (nTotItem + nEntradRat + nAcrsTot)
					ElseIf !lCalcFin .AND. nTxJuros > 0 // Calculo pelo vlr total.
						If !lTxVista .AND. nTxJuros > 0
							nTotItem := (nTotItem + nEntradRat + nAcrsTot)
						Else
							nTotItem := (nTotItem + nAcrsTot)
						Endif
					Endif
				Endif
				
			Endif
			
		ElseIf UPPER(cOriRecal) == "DESCONTO" .AND. !lFator
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso a origem for para recalculo em virtude ³
			//³ de Desconto no total da NF						³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTotItem  := NoRound((SL2->L2_PRCTAB - ((SL2->L2_PRCTAB * SL2->L2_DESC) /100)),nRndFat)
			nTotItem  := NoRound(nTotItem * SL2->L2_QUANT,nRndFat)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso Exista IPI recalcula ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SF4->F4_IPI == "S"
 				nVlrIpi := Lj010Ipi(SL2->L2_PRCTAB,SL2->L2_QUANT,SL2->L2_DESC,SL1->L1_DESCNF,SL2->L2_TES,FRTPegaIT( SL2->L2_ITEM ),SL2->L2_PRODUTO,,SL2->L2_VALFRE,SL2->L2_SEGURO,SL2->L2_DESPESA)				
			Else
				nVlrIPI := 0
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso Exista ICMS Recalcula ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTotItem := SL2->L2_VLRITEM
			
			nBaseIcms := SL2->L2_BASEICM
			If SF4->F4_ICM == "S"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Aplica a desconto na Base e recalcula o Icms ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( SL1->L1_FRETE > 0 .OR. SL1->L1_DESPESA > 0 .OR. SL1->L1_SEGURO > 0 ) .AND. lVlrFSD
					nBaseIcms := SL2->L2_VLRITEM + SL2->L2_VALFRE + SL2->L2_DESPESA + SL2->L2_SEGURO
				Else
					nBaseIcms := SL2->L2_VLRITEM
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se tem base reduzida, e Se o Ipi Incide na Base ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nBaseIcms := lj010verBaseicms(nBaseIcms,nVlrIpi,.F.)
				
				nValIcms  := lj010Icms(nx,@nDif,@nBaseIcms)
			Else
				nValIcms := 0
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso a origem for para recalculo em virtude ³
			//³ de Desconto no total da NF					³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTotItem  := NoRound((SL2->L2_PRCTAB - ((SL2->L2_PRCTAB * SL2->L2_DESC) /100)),nRndFat)
			nTotItem  := NoRound(nTotItem * SL2->L2_QUANT,nRndFat)
			
			// Recalcula o ISS
			
			If SF4->F4_ISS == "S"
				nVlrIss := Lj010Iss(nTotItem,.T.,SL1->L1_DESCNF,)
			Else
				nVlrISS := 0
			Endif
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava no SL2 os valores recalculados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Reclock("SL2")
		SL2->L2_VALICM := nValIcms
		SL2->L2_VALIPI := nVlrIpi
		SL2->L2_VALISS := nVlrIss
		SL2->L2_BASEICM:= nBaseIcms
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Caso tenha acréscimo, soma ao valor do item. Mais abaixo no código é feito uma adequação dos valores. |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nAcrsTot > 0
			SL2->L2_VLRITEM := nTotItem
			If cMVArreFat == "S"			
				SL2->L2_VRUNIT  := Round(( SL2->L2_VLRITEM / SL2->L2_QUANT ), nDecimais)
			Else
				SL2->L2_VRUNIT  := NoRound(( SL2->L2_VLRITEM / SL2->L2_QUANT ), nDecimais)
			Endif
		Endif
	
	Else 
		Reclock("SL2")
		For nA := 1 To Len(aImps[nX][6])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravar os Impostos gerados atrav‚s do Roteiro de c lculo da ³
			//³ Amarra‡Æo Tes X Impostos...											 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Subs(aImps[nX,6,nA,7],3,7) == "_BASIMP"
				cCampo := "L2"+Subs(aImps[nX,6,nA,7],3,8)
				If FieldPos( cCampo ) > 0
					SL2->( FieldPut( FieldPos( cCampo ), Round(aImps[nX,6,nA,3],nDecimais) ) )
				Endif
			Endif                                                       
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Grava os dados no Array aImpsSL1 para futura gravacao do arquivo SL1                                  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( nPos := ASCAN( aImpsSL1, { |x| TRIM(x[1]) == "L1" + SUBSTR( aImps[ nX ][6][ nA ][7], 3, 8 ) } ) ) > 0
				aImpsSL1[ nPos ][2] += Round( aImps[ nX ][6][ nA ][3], nDecimais )
			Else
			    AADD(aImpsSL1,{"L1"+Subs(aImps[nX,6,nA,7],3,8),Round(aImps[nX,6,nA,3],nDecimais)})
			Endif
			If SUBSTR( aImps[ nX ][6][ nA ][6], 3, 7) == "_VALIMP"
				cCampo := "L2" + SUBSTR( aImps[ nX ][6][ nA ][6], 3, 8)
				If FieldPos( cCampo ) > 0
					SL2->( FieldPut( FieldPos( cCampo ), Round( aImps[ nX ][6][ nA ][4], nDecimais ) ) )
				Endif
			Endif                                                       
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|  Grava os dados no Array aImpsSL1 para futura gravacao do arquivo SL1				                  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( nPos := ASCAN(aImpsSL1,{|x| TRIM(x[1]) == "L1" + SUBSTR( aImps[ nX ][6][ nA ][6], 3, 8)})) > 0
				aImpsSL1[ nPos ][2] += Round( aImps[ nX ][6][ nA ][4], nDecimais)
			Else
			    AADD( aImpsSL1,{ "L1" + SUBSTR( aImps[ nX ][6][ nA ][6], 3, 8),Round( aImps[ nX ][6][ nA ][4], nDecimais ) } )
			Endif
		Next nA	
		SL2->L2_VRUNIT  := aImps[ nX ][2]
		SL2->L2_VLRITEM := aImps[ nX ][3] - IIf(nTxDescon > 0, SL2->L2_DESCPRO,0) 
	Endif
	MsUnlock()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acumula os Valores para gravar no SL1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrTotOrc += SL2->L2_VLRITEM
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Totaliza os Tributos da Nota Fiscal ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotIpi	+= nVlrIpi
	nTotIcms += nValIcms
	nTotIss	+= nVlrIss
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Zera as vari veis ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrIpi	:= 0
	nVlrIss	:= 0
	nValIcms := 0
	nDescTot := 0
	nAcrsTot := 0
	nTotItem := 0
	nBaseIcms:= 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Totaliza a vari vel para verificar difern‡a posterior ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotalSL2 += SL2->L2_VLRITEM + SL2->L2_VALIPI
	
	dbSelectArea("SL2")
	dbSkip()
End

RecLock("SL1",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava no SL1 os valores recalculados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (UPPER(cOriRecal) == "CONDPAG") .AND. (cPaisLoc == "BRA")
	If nTxDescon > 0
		SL1->L1_DESCONT := noRound((nValorbase * nTxDescon)  / 100,2)
		SL1->L1_VLRLIQ  := Round(nValorbase-(nValorbase* nTxDescon/100),2)
		SL1->L1_DESCNF  := nTxDescon
		SL1->L1_VLRTOT  := nValorbase
		SL1->L1_VALBRUT := SL1->L1_VLRTOT
		SL1->L1_VALMERC := SL1->L1_VLRLIQ
	ElseIf nTxJuros > 0
		SL1->L1_JUROS	 := NoRound(nTxJuros,2)
		SL1->L1_VLRTOT  := Round(nLiq + nVlrAcrs + SL1->L1_DESCONT - LJ010VlrFSD() ,2)
		SL1->L1_VLRLIQ  := Round(nLiq + nVlrAcrs - LJ010VlrFSD(),2)
		SL1->L1_VALBRUT := SL1->L1_VLRTOT
		SL1->L1_VALMERC := SL1->L1_VLRLIQ
	Endif
Endif

If cPaisLoc <> "BRA"
	SL1->L1_JUROS  := NoRound(nTxJuros,2)
	SL1->L1_VLRTOT := Round(((nLiq-aDadosJur[6])+aDadosJur[4]+aDadosJur[1])-nVlrFSD-aDadosJur[9],nDecimais)
	SL1->L1_VLRLIQ := Round(((nLiq-aDadosJur[6])+aDadosJur[1])-nVlrFSD-aDadosJur[9],nDecimais)
	SL1->L1_VALBRUT := SL1->L1_VLRTOT
	SL1->L1_VALMERC := SL1->L1_VLRLIQ

	For nI := 1 To Len(aImpsSL1)
		cCampo := aImpsSL1[nI][01]
		SL1->( FieldPut( FieldPos( cCampo ), aImpsSL1[nI][02] ) )	
	Next nI
Endif

If cPaisLoc == "BRA"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o total dos tributos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SL1->L1_VALICM := nTotIcms
	SL1->L1_VALIPI := nTotIpi
	SL1->L1_VALISS := nTotIss

	MsUnlock()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Acerto da diferen‡a de centavos caso haja ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If UPPER(cOriRecal) == "DESCONTO"
	nTotalSL1 := nLiq
Else
	nTotalSL1 := ( SL1->L1_VLRTOT - SL1->L1_DESCONT )
Endif

nTotalGer := Round(nTotalSL1,2) - NoRound(nTotalSL2,2) + iIf( lTroca, SL1->L1_CREDITO, 0 )
If Abs(nTotalGer) > 0
	nDifer := nTotalGer
Endif

If nDifer <> 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //| Vou localizar o ultimo item com a ultima possibilidade de gravacao possivel ZZ                                    |
	//| Se o numero do orcamento for diferente ele se posicionou no proximo, desta forma e so voltar ao Registro Anterior |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SL2")
	dbSetOrder(1)
	MsSeek(xFilial("SL2") + cNumOrc + "ZZ", .T.)
	If L2_FILIAL+L2_NUM <> xFilial("SL2")+cNumOrc
		dbSkip(-1)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Posiciona na TES correspondente                                                                       |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF4")
	dbSetOrder(1)
	MsSeek(xFilial("SF4") + SL2->L2_TES)

	dbSelectArea("SL2")
	Reclock("SL2",.F.)
	If cPaisLoc == "BRA"
		SL2->L2_VLRITEM += nDifer
		If cMVArreFat == "S"
			SL2->L2_VRUNIT := Max(Round( SL2->L2_VLRITEM / SL2->L2_QUANT , nRndItem ),1/(10^nRndItem))
		Else
			SL2->L2_VRUNIT := Max(NoRound( SL2->L2_VLRITEM / SL2->L2_QUANT , nRndItem ),1/(10^nRndItem))
		Endif
	Endif
	MsUnlock()
	
	If UPPER(cOriRecal) == "CONDPAG"
		If SF4->F4_IPI == "S"
			nVlrIpi := Lj010Ipi(SL2->L2_PRCTAB,SL2->L2_QUANT,SL2->L2_DESC,SL1->L1_DESCNF,SL2->L2_TES,FRTPegaIT( SL2->L2_ITEM ),SL2->L2_PRODUTO,,SL2->L2_VALFRE,SL2->L2_SEGURO,SL2->L2_DESPESA)
		Else
			nVlrIpi := 0
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso Exista ICMS recalcula ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nBaseIcms := SL2->L2_BASEICM
		If SF4->F4_ICM == "S"
			nBaseIcms := SL2->L2_VLRITEM
			nDif		 := 0
			nValIcms := lj010Icms(FRTPegaIT(SL2->L2_ITEM),@nDif,@nBaseIcms,"CONDPAG",nVlrIpi)
		Else
			nValIcms := 0
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//|  Recalcula o ISS     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If SF4->F4_ISS == "S"
			If nTxJuros > 0
				nVlrIss := Lj010Iss(SL2->L2_VLRITEM,.T.,,nTxJuros)
			Else
				nVlrIss := Lj010Iss(SL2->L2_VLRITEM,.T.,nTxDescon,)
			Endif
		Else
			nVlrIss := 0
		Endif
		
	ElseIf( cOriRecal ) == "DESCONTO"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso Exista IPI recalcula ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTotItem := SL2->L2_VLRITEM
		If SF4->F4_IPI == "S"
			nVlrIpi := Lj010Ipi(SL2->L2_PRCTAB,SL2->L2_QUANT,SL2->L2_DESC,SL1->L1_DESCNF,SL2->L2_TES,FRTPegaIT( SL2->L2_ITEM ),SL2->L2_PRODUTO,,SL2->L2_VALFRE,SL2->L2_SEGURO,SL2->L2_DESPESA)
		Else
			nVlrIpi := 0
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso Exista ICMS Recalcula ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nBaseIcms := SL2->L2_BASEICM
		If SF4->F4_ICM == "S"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Aplica a desconto na Base e recalcula o Icms ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nBaseIcms := SL2->L2_VLRITEM
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se tem base reduzida, e Se o Ipi Incide na Base ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nBaseIcms := lj010verBaseicms(nBaseIcms,nVlrIpi,.F.)
			nDif		 := 0
			nValIcms  := lj010Icms(FRTPegaIT(SL2->L2_ITEM),@nDif,@nBaseIcms)
		Else
			nValIcms	:= 0
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Recalcula o ISS    |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If SF4->F4_ISS == "S"
			nVlrIss := Lj010Iss(nTotItem,.T.,SL1->L1_DESCNF)
		Else
			nVlrIss := 0
		Endif
		
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava no SL2 os valores recalculados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Reclock("SL2")
	SL2->L2_VALICM := nValIcms
	SL2->L2_VALIPI := nVlrIpi
	SL2->L2_VALISS := nVlrIss
	SL2->L2_BASEICM:= nBaseIcms
	MsUnLock()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Termina o processo de transa‡„o       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
End Transaction
Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³lj010Iss	³ Autor ³ Fernando Godoy		  ³ Data ³ 06/05/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula valor do ISS													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1 - Valor total do item 											  ³±±
±±³			 ³ 2 - Recalcula ou Nao o ISS 										  ³±±
±±³			 ³ 3 - Taxa de Desconto para o Iss									  ³±±
±±³			 ³ 4 - Taxa de Juros para o Iss										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LojA010																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010Iss(nVlrTot,lRecalcula,nTxDescIss,nTxJurIss,lDifer)

Local aArea 	  := GetArea()
Local nValIss	  := 0
Local nPosTes	  := aPosicoes[5][2]
Local nPosValIss := aPosicoes[8][2]
Local nPosTotal  := aPosicoes[2][2]
*** Grade
Local nGrade	  := Ascan(aCampos,"L2_GRADE")
Local cGrade	  := If(!__lPyme,aCols[n][nGrade],"N")

If cPaisLoc <> "BRA"
	Return( 0.00 )
Endif

//-- Utilizando o mesmo conceito do MATXFIS (funções fiscais).
If ( SA1->A1_RECISS == "1" .AND. GetNewPar("MV_DESCISS", .F.) ) .OR. ( SA1->A1_RECISS <> "1" )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se os parametros existem ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrTot	   := Iif(nVlrTot    == NIL, 0   , nVlrTot	  )
	lRecalcula := Iif(lRecalcula == NIL, .F. , lRecalcula )
	nTxDescIss := Iif(nTxDescIss == NIL, 0   , nTxDescIss )
	nTxJurIss  := Iif(nTxJurIss  == NIL, 0   , nTxJurIss  )
	lDifer     := Iif(lDifer     == NIL, .F. , lDifer     )
	
	If lRecalcula
		dbSelectArea("SF4")
		MsSeek( xFilial("SF4")+SL2->L2_TES)
		nValIss := 0
		If SF4->F4_ISS == "S"
			If nTxJurIss > 0
				If !lDifer
					nVlrTot += (nVlrTot * nTxJurIss) /100
				Endif
				If cGrade == "S"
					nValIss := nVlrTot * Iif(SB4->B4_ALIQISS > 0,SB4->B4_ALIQISS/100,SuperGetMv("MV_ALIQISS")/100)
				Else
					nValIss := nVlrTot * Iif(SB1->B1_ALIQISS > 0,SB1->B1_ALIQISS/100,SuperGetMv("MV_ALIQISS")/100)
				Endif
			ElseIf nTxDescIss > 0
				nVlrTot -= (nVlrTot * nTxDescIss) /100
				If cGrade  == "S"
					nValIss := nVlrTot * Iif(SB4->B4_ALIQISS > 0,SB4->B4_ALIQISS/100,SuperGetMv("MV_ALIQISS")/100)
				Else
					nValIss := nVlrTot * Iif(SB1->B1_ALIQISS > 0,SB1->B1_ALIQISS/100,SuperGetMv("MV_ALIQISS")/100)
				Endif
			Else
				If cGrade  == "S"
					nValIss := nVlrTot * Iif(SB4->B4_ALIQISS > 0,SB4->B4_ALIQISS/100,SuperGetMv("MV_ALIQISS")/100)
				Else
					nValIss := nVlrTot * Iif(SB1->B1_ALIQISS > 0,SB1->B1_ALIQISS/100,SuperGetMv("MV_ALIQISS")/100)
				Endif
			Endif
		Endif
	Else
		dbSelectArea( "SF4" )
		MsSeek( xFilial("SF4")+aCols[n][nPosTes])
		nValIss := 0
		If SF4->F4_ISS == "S"
			If cGrade == "S"
				nValIss := aCols[n][nPosTotal] * Iif(SB4->B4_ALIQISS>0,SB4->B4_ALIQISS/100,SuperGetMv("MV_ALIQISS")/100)
			Else
				nValIss := aCols[n][nPosTotal] * Iif(SB1->B1_ALIQISS>0,SB1->B1_ALIQISS/100,SuperGetMv("MV_ALIQISS")/100)
			Endif
		Endif
		If nPosValIss > 0
			aCols[n][nPosValIss] := nValIss
		Endif
	Endif

Endif

RestArea( aArea )

Return nValIss

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LjVisChq   | Autor ³ Eduardo J. Zanardo  ³ Data ³29/05/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualiza os dados do Cheque.                              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LjVisChq()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja010a                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjVisChq(cBanco,cAgencia,cConta,cTelefone,cRg,cCheque,nVlrCart,lCheckTe,lCheckCh,lSaida,lOk,nParc,lEdit,;
lContinua,lInfchq,dDtVenc,cCgcchq,cNomeCli,cSerChq,cMesActa,cAnoActa,lTipoChq,cComp,cdddcli,cpretelcli,csuftelcli)

Local oBanco
Local oAgencia
Local oCheque
Local oComp
Local oConta
Local oTelefone
Local oRg
Local oDlgLojaDadPag
Local oCheckCh
Local oFont
Local oFont2
Local oVlrCart
Local oDtVenc
Local oParc
Local oCheckTe
Local oWindow

// Integracao Servidor de Consultas Cheque-Pre
Local oMesActa
Local oAnoActa
Local oTipoChq
Local oCgcChq
Local oNomeCli
Local oDDDCli
Local oPreTelCli
Local oSufTelCli
Local oSerChq

Local bBtn1 := { |oWindow| If(LjVerChq(cBanco,cAgencia,cConta,cCheque,oBanco,oAgencia,oConta,oCheque,nparc,;
cMesACta,cAnoACta,lTipoChq,cCgcChq,cNomeCli,cDddCli,CPreTelCli,cSufTelCli,cSerChq,oMesACta,oAnoACta,oTipoChq,;
oCgcChq,oNomeCli,oDddCli,oPreTelCli,oSufTelCli,oSerChq,ctelefone,otelefone,cRg,oRg,cComp,oComp),(Lj010Cheq(cBanco,;
cAgencia,cConta,cCheque,nparc,cRg,cTelefone,lCheckTe,cMesACta,cAnoACta,lTipoChq,CCgcChq,cNomeCli,cSerChq,cComp, cdddcli, cpretelcli, csuftelcli),;
lSaida := .T.,lOk:= .T.,If(ValType(oWindow)=="O",oWindow:End(),Nil)),(lSaida := .F.,lOk:= .T.,If(ValType(oWindow)=="O",oWindow:End(),Nil)))}

Local bBtn2 := { |oWindow| (lSaida := .T.,Iif(Empty(Alltrim(aReceb[nParc][4])),lOk := .F.,lOk := .T.),If(ValType(oWindow)=="O",oWindow:End(),Nil))}
Local cLabelDoc  := AllTrim(RetTitle("A1_RG"))+":"		
Local lTabBC     := SX5->(MsSeek(xFilial("SX5")+"BC")) 

If ExistBlock("LJ010CHQ")
	aOk := Execblock("LJ010CHQ",.F.,.F.,{nVlrCart,dDtVenc,nParc,cBanco,cAgencia,cConta,cCheque,cComp,cRg,cTelefone,lCheckCh,lCheckTe,cSerChq,lTipoChq,cCGCchq,cDDDcli,cPreTelCli,cSufTelCli,cNomeCli,cMesACta,cAnoACta})
	lOk := aOk[1]
	If lOk
		cBanco := aOk[2]
		cAgencia := aOk[3]
		cConta := aOk[4]
		cCheque := aOk[5]
		cComp := aOk[6]
		cRg := aOk[7]
		cTelefone := aOk[8]
		lCheckCh := aOk[9]
		lCheckTe := aOk[10]
		cSerChq := aOk[11]
		cTipoChq := aOk[12]
		lTipochq := Iif(aOK[12] = "2", .T. , .F.)
		cCGCchq := aOk[13]
		cDDDcli := aOk[14]
		cPreTelCli := aOk[15]
		cSufTelCli := aOk[16]
		cNomeCli := aOk[17]
		cMesACta := aOk[18]
		cAnoACta := aOk[19]
		If lSrvcns
			cTelefone := aOk[14] + aOK[15] + aOK[16]
		Endif
		
		Eval(bBtn1,Nil)
		
	Endif
	
Else
	
	// Dados do Cheque
	If ! lSrvCns
		DEFINE MSDIALOG oDlgLojaDadPag FROM 12, 13 TO 29, 66 TITLE OemToAnsi(STR0006) STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oDlgLoja
	Else
		DEFINE MSDIALOG oDlgLojaDadPag FROM 12, 13 TO 35, 66 TITLE OemToAnsi(STR0006) STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oDlgLoja
	Endif
	
	DEFINE FONT oFont NAME "Arial" SIZE 5,15
	DEFINE FONT oFont2 NAME "Arial" SIZE 10,15
	
	@ .3,1 TO 2.9,25.2 OF oDlgLojaDadPag
	
	// Valor do t¡tulo:
	@ 01.0 , 02.0 SAY OemToAnsi(STR0007) SIZE 17,1
	@ 01.0 , 12.0 SAY oVlrCart VAR nVlrCart FONT oFont COLOR CLR_HBLUE SIZE 10,1 ;
	Picture PesqPict("SL1","L1_VLRTOT",_PICTURE,nMoedaCor)
	
	// Data do Vencimento:
	@ 02.0 , 02.0 SAY OemToAnsi(STR0008) SIZE 17,1
	@ 02.0 , 9.0 SAY oDtVenc VAR dDtVenc FONT oFont COLOR CLR_HRED SIZE 8,1
	
	// Parcela:
	@ 02.0 , 13.0 SAY OemToAnsi(STR0009) SIZE 8,1
	@ 02.0 , 16.8 SAY oParc VAR nParc FONT oFont COLOR CLR_HRED SIZE 5,1
	
	If ! lSrvCns
		@ 3,1 TO 7.8,25.2 OF oDlgLojaDadPag
	Else
		// SERVIDOR DE CONSULTAS CHEQUE-PRE
		@ 3,1 TO 11.1,25.2 OF oDlgLojaDadPag
	Endif
	
	If ! lSrvCns
	// &Banco:
	@ 4.0,02 Say OemToAnsi(STR0010) SIZE 10,1
	If cPaisLoc <> "BRA" .AND. lTabBC
		@ 4.0,4.3 MSGET oBanco VAR cBanco Picture PesqPict("SEF","EF_BANCO",3) F3 "BC" VALID Lj010VldBco(cBanco) SIZE 15, 1 OF oDlgLojaDadPag
	Else
		@ 4.0,5.0 MSGET oBanco VAR cBanco Picture PesqPict("SEF","EF_BANCO",3) SIZE 15, 1 OF oDlgLojaDadPag
	Endif
	
	// &Agˆncia:
	@ 4.0,08 Say OemToAnsi(STR0011) SIZE 10,1
	@ 4.0,11 MSGET oAgencia VAR cAgencia Picture PesqPict("SEF","EF_AGENCIA",5) SIZE 18, 1 OF oDlgLojaDadPag
	
	// &Conta:
	@ 4.0,16 Say OemToAnsi(STR0012) SIZE 5,1
	@ 4.0,18 MSGET oConta VAR cConta Picture PesqPict("SEF","EF_CONTA",10) SIZE 36, 1 OF oDlgLojaDadPag
	
	// &Num Cheque:
	@ 5.0,02 Say OemToAnsi(STR0013) SIZE 15,1
	@ 5.0,07 MSGET oCheque VAR cCheque Picture PesqPict("SEF","EF_NUM",15) SIZE 51, 1  OF oDlgLojaDadPag
	
	// Compensação:
	@ 5.0,14 Say STR0065 SIZE 10,1
	@ 5.0,19 MSGET oComp VAR cComp Picture PesqPict("SL4","L4_COMP",3) SIZE 10,1 OF oDlgLojaDadPag
	
	// &RG:
	If cPaisLoc == "BRA"
		@ 6.0,02 Say OemToAnsi(STR0014) SIZE 10,1
	Else
		@ 6.0,02 Say cLabelDoc SIZE 10,1		
	Endif
	@ 6.0,04 MSGET oRg VAR cRg Picture PesqPict("SEF","EF_RG",15) SIZE 51, 1 OF oDlgLojaDadPag
	
		//&Telefone:
		@ 6.0,11 Say OemToAnsi(STR0015) SIZE 10,1
		@ 6.0,14 MSGET oTelefone VAR cTelefone Picture PesqPict("SEF","EF_TEL",15) SIZE 51,1 OF oDlgLojaDadPag
		
		If ! (lEdit .AND. lContinua .AND. lInfChq)
			@ 95,17 CHECKBOX oCheckCh VAR lCheckCh PROMPT OemtoAnsi(STR0016) SIZE 90,7 When Len(aReceb) > 1 FONT oFont OF oDlgLojaDadPag
		Endif
		
		@ 95,120 CHECKBOX oCheckTe VAR lCheckTe PROMPT OemtoAnsi(STR0040) SIZE 70,7 FONT oFont OF oDlgLojaDadPag
		
		DEFINE SBUTTON FROM 110,137 TYPE 1 ACTION Eval(bBtn1,oDlgLojaDadPag) ENABLE OF oDlgLojaDadPag
		
		DEFINE SBUTTON FROM 110,171.1 TYPE 2 ACTION Eval(bBtn2,oDlgLojaDadPag) ENABLE OF oDlgLojaDadPag
		
	Else
		// servidor cheque-pre
		// &Banco:
		@ 4.0,02 Say OemToAnsi(STR0010) SIZE 10,1
		@ 4.0,05 MSGET oBanco VAR cBanco Picture "999"  SIZE 15, 1 OF oDlgLojaDadPag
	
		// &Agˆncia:
		@ 4.0,08 Say OemToAnsi(STR0011) SIZE 10,1
		@ 4.0,11 MSGET oAgencia VAR cAgencia Picture "9999" SIZE 18, 1 OF oDlgLojaDadPag
	
		// &Conta:
		@ 4.0,16 Say OemToAnsi(STR0012) SIZE 5,1
		@ 4.0,18 MSGET oConta VAR cConta Picture "999999" SIZE 36, 1 OF oDlgLojaDadPag
	
		// &Num Cheque:
		@ 5.0,02 Say OemToAnsi(STR0013) SIZE 10,1
		@ 5.0,07 MSGET oCheque VAR cCheque Picture "999999" SIZE 21, 1  OF oDlgLojaDadPag
	
	
		// &Serie
		@ 5.0,11 Say OemToAnsi(STR0052) SIZE 10,1
		@ 5.0,13 MSGET oSerChq VAR cSerChq Picture "@!" SIZE 18, 1 OF oDlgLojaDadPag
		
		// Compensação:
		@ 5.0,17 Say STR0065 SIZE 10,1
		@ 5.0,22 MSGET oComp VAR cComp Picture PesqPict("SL4","L4_COMP",3) SIZE 10,1 OF oDlgLojaDadPag

		// &RG:
		If cPaisLoc == "BRA"
			@ 6.0,02 Say OemToAnsi(STR0014) SIZE 10,1
		Else
			@ 6.0,02 Say cLabelDoc SIZE 10,1  
		Endif
		@ 6.0,04 MSGET oRg VAR cRg Picture PesqPict("SEF","EF_RG",15) SIZE 51, 1 OF oDlgLojaDadPag
		
		//&CGC
		@ 6.0,11 Say OemToAnsi(STR0054) SIZE 10,1
		@ 6.0,15 MSGET oCgcChq VAR cCGCchq PICT "@!" SIZE 50,1 OF oDlgLojaDadPag
		
		//&DDD:
		@ 7.0,02 Say OemToAnsi(STR0055) SIZE 5,1
		@ 7.0,04 MSGET oDDDcli VAR cDDDcli Picture "999" SIZE 15,1 OF oDlgLojaDadPag
		
		//&Prefixo Telefone do Cliente
		@ 7.0,08 Say OemToAnsi(STR0056) SIZE 5,1
		@ 7.0,12 MSGET oPreTelCli VAR cPreTelCli Picture "9999" SIZE 15,1 OF oDlgLojaDadPag
		
		//&Sufixo Telefone Cliente
		@ 7.0,17 Say OemToAnsi(STR0057) SIZE 5,1
		@ 7.0,20.5 MSGET oSufTelCli VAR cSufTelCli Picture "9999" SIZE 15,1 OF oDlgLojaDadPag
		
		//&Nome Cliente
		@ 8.0,02 Say OemToAnsi(STR0058) SIZE 10,1
		@ 8.0,05 MSGET oNomeCli VAR cNomeCli Picture "@!" SIZE 90,1 OF oDlgLojaDadPag
		
		//&Mes de Abertura da Conta
		@ 9.0,02 Say OemToAnsi(STR0059) SIZE 10,1
		@ 9.0,09 MSGET oMesActa VAR cMesACta  Picture "99" SIZE 15,1 OF oDlgLojaDadPag
		
		//&Ano de Abertura da Conta
		@ 9.0,12 Say OemToAnsi(STR0060) SIZE 10,1
		@ 9.0,19 MSGET oAnoActa VAR cAnoACta Picture "9999" SIZE 15,1 OF oDlgLojaDadPag
		
		//&Utiliza nas pr¢ximas parcelas
		@ 130,17 CHECKBOX oCheckCh VAR lCheckCh PROMPT OemtoAnsi(STR0016) SIZE 90,7 ;
		When Len(aReceb) > 1 FONT oFont OF oDlgLojaDadPag
		
		If ! (lEdit .AND. lContinua .AND. lInfChq)
			@ 130,17 CHECKBOX oCheckCh VAR lCheckCh PROMPT OemtoAnsi(STR0016) SIZE 90,7 When Len(aReceb) > 1 FONT oFont OF oDlgLojaDadPag
		Endif
		
		@ 130,120 CHECKBOX oCheckTe VAR lCheckTe PROMPT OemtoAnsi(STR0040) SIZE 70,7 FONT oFont OF oDlgLojaDadPag
		
		//Cheque Especial
		@ 140.0,17 CHECKBOX oTipoChq VAR lTipoChq PROMPT OemtoAnsi(STR0053) SIZE 60,7 ;
		FONT oFont OF oDlgLojaDadPag
		
		DEFINE SBUTTON FROM 156,142 TYPE 1 ACTION Eval(bBtn1,oDlgLojaDadPag) ENABLE OF oDlgLojaDadPag
		
		DEFINE SBUTTON FROM 156,171.1 TYPE 2 ACTION Eval(bBtn2,oDlgLojaDadPag) ENABLE OF oDlgLojaDadPag
		
	Endif
	
	ACTIVATE MSDIALOG oDlgLojaDadPag VALID lSaida
	
Endif

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LimpaChar³ Autor ³Claudia Cabral         ³ Data ³ 23/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retira Caracteres especiais da string                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LimpaChar(ExpC1)             							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Expc1 = String a ser retirado os caracteres				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LimpaChar(cString)
LOCAL cLimpa
LOCAL nPos
LOCAL cCar
cLimpa := ""
For nPos = 1 to Len(Alltrim(cString))
	cCar := Substr(cString,nPos,1)
	If cCar $ "!@#$%.-&*()\/{}[]|{}"
		cCar := ""
	Endif
	cLimpa += cCar
Next
Return cLimpa

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj010RecVB    ³ Autor ³Julio Cesar            ³ Data ³ 23/04/01   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Faz o recalculo do valor base da venda para que o                ³±± 
±±³          ³ acrescimo seja aplicado corretamente. Especifico para            ³±± 
±±³          ³ localizacoes.                                                    ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj010RecVB(Expn1,Expn2,Expn3,Expn4,Expn5,Expn6,Expn7,Expn8,Expn9)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Expn1 = Valor base da venda               				        ³±± 
±±³          ³ Expn2 = Taxa de juros               				                ³±±
±±³          ³ Expn3 = Desconto atribuido no total da venda                     ³±±
±±³          ³ Expn4 = Taxa de desconto            				                ³±±
±±³          ³ Expn5 = Valor liquido da venda                                   ³±±
±±³          ³ Expn6 = Percentual de desconto      				                ³±±
±±³          ³ Expn7 = Tipo de juros (1=>Simples / 2=>Composto)                 ³±±
±±³          ³ Expn8 = Numero de parcelas do orcamento/venda                    ³±±
±±³          ³ Expn9 = Valor recebido na entrada                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Lj010RecVB(nValorBase,nTxJuros,nTxDesc,nDescLoj,nLiq,nDescPer,nTipoJur,;
                    nNumParcelas,nEntrada,lJurEntrada)

Local lExpress    := .F.
Local lCalcFin    := Iif(SuperGETMV("MV_TXVISTA") == "S",.F.,.T.)
Local nI:=0,nX:=0,nK:=0,nA:=0,nY:=0,nC:=0
Local nAcresItem:=0,nDescItem:=0
Local nValImps:=0
Local cProg       := FunName()
Local nPosDescPro := Iif(cProg<>"LOJA701",Ascan(aHeader,{|x|Trim(x[2])=="L2_DESCPRO"}),aPosCpoDet[10][2]) 
Local nPosValItem := Iif(cProg<>"LOJA701",Ascan(aHeader,{|x|Trim(x[2])=="L2_VLRITEM"}),aPosCpo[6][2])
Local nPosValUnit := Iif(cProg<>"LOJA701",Ascan(aHeader,{|x|Trim(x[2])=="L2_VRUNIT"}),aPosCpo[5][2])
Local nPosQtdItem := Iif(cProg<>"LOJA701",Ascan(aHeader,{|x|Trim(x[2])=="L2_QUANT"}),aPosCpo[4][2])
Local nPosTes     := Iif(cProg<>"LOJA701",Ascan(aHeader,{|x|Trim(x[2])=="L2_TES"}),aPosCpoDet[03][2])
Local nPosProd    := Iif(cProg<>"LOJA701",Ascan(aHeader,{|x|Trim(x[2])=="L2_PRODUTO"}),aPosCpo[2][2]) 
Local nPosItem    := Iif(cProg<>"LOJA701",Ascan(aHeader,{|x|Trim(x[2])=="L2_ITEM"}),aPosCpo[1][2]) 
Local nDecs       := MsDecimais(nMoedaCor)
Local nArredIt	  := If(nDecs==0,nDecs,TAMSX3("L2_VRUNIT")[2])
Local nValIT      := 0
Local nDifIT      := 0
Local aTmpAcols   := aClone(aCols)
Local aImposto    := {}
Local aProdSL2    := {}
Local aSL2        := {}
Local aInfImp     := {}
Local cCodProd    := ""
Local lItem		  := (nArredIt > TAMSX3("L2_VLRITEM")[2])
Local nValJurOri  := aDadosJur[1]
Local nValDescOri := aDadosJur[9]
Local nValTaxa    := 0
Local nDivisor    := 0
Local nAcresTot   := 0
Local nPerAcrs    := 0

Default lJurEntrada := .T.

If Type("nDecimais")=="U"
   nDecimais  := 2
Endif
nDecs		:= If(lItem,nArredIt,nDecimais)
nArredImp   := nDecs

If cPaisLoc == "ARG" .AND. !(SA1->A1_TIPO $ "NI")
	nArredImp	:=	nDecs
Endif

If ((aImpsTmp   == Nil) .OR. (aImpTmpSL1 == Nil) .OR. (aImpTmpSL2 == Nil) .OR.;
	(aImpSF2Tmp == Nil) .OR. (aImpDupTmp == Nil))
   
	aImpsTmp   := {}
   	aImpSF2Tmp := {}                            
 	aImpDupTmp := {}
   	aImpTmpSL1 := {}
   	aImpTmpSL2 := {}
	nValTotTmp := 0
	nValBaseTmp:= 0
Endif

If (nTmpLiq == Nil)
	nTmpLiq := 0
Endif

//Zera o array aDadosJur
AEval(aDadosJur,{|x,y| aDadosJur[y]:=0 })

//Caso a taxa de juros seja igual a Zero a rotina nao eh executada.
If ((nTxjuros == 0) .AND. (nTxDesc == 0)) .AND. ((cProg <> "LOJA010") .AND. (cProg <> "FRTA010"))
	Return(0)
Endif
                                          
//Variavel que determina a formula para calculo dos juros
If cProg <> "FRTA010" .OR. cProg <> "LOJA701"
	nTipoJur := Iif(nTipoJur==Nil,1,nTipoJur)
	If nTipoJur == 2                                             
		nNumParcelas := Iif(lCalcFin,nNumParcelas-1,nNumParcelas)
	Endif
Else 
	nNumParcelas -= If(nEntrada == 0,0,1)
Endif

If (cProg <> "FRTA010" .AND. cProg <> "LOJA701") .AND. (Empty(aImpsTmp) .OR. (nLiq <> nTmpLiq))
	aImpsTmp := {}
	aImpsTmp := aClone(aImps)
	aImps    := {}
	                              
	aImpSF2Tmp:= {} 
	aImpSF2Tmp:= aClone(aImpVarSF2)
	aImpVarSF2:= {}
	                              
	aImpDupTmp:= {} 
	aImpDupTmp:= aClone(aImpVarDup)
	aImpVarDup:= {}
	
	nValTotTmp:= 0
	nValTotTmp:= nValTotIV 
	nValTotIV := 0
	              
	nValBaseTmp:= 0
	nValBaseTmp:= nValBaseIV 
	nValBaseIV := 0
ElseIf (cProg == "FRTA010" .OR. cProg == "LOJA701") .AND. ((Empty(aImpTmpSL1) .AND. Empty(aImpTmpSL2)) .OR. (nLiq <> nTmpLiq))
	aImpTmpSL1 := aClone(aImpsSL1) 
	aImpTmpSL2 := aClone(aImpsSL2)
Endif

//Armazena o valor Liquido Original da Venda
aDadosJur[2] := nLiq
nTmpLiq      := nLiq

//Verfica se o imposto eh incluido ou descriminado e calcula o novo
//valor base.
If (cProg <> "FRTA010") .AND. (cProg <> "LOJA701")
	For nI := 1 To Len(aImpsTmp)
		For nX := 1 To Len(aImpsTmp[nI][06])
			If Substr(aImpsTmp[nI,6,nX,5],2,1) == "1"
				nValorBase   -= aImpsTmp[nI,6,nX,4]
				aDadosJur[6] += aImpsTmp[nI,6,nX,4]
			Endif
		Next nX
	Next nI                          
Else
	If cProg == "FRTA010"
		For nI := 1 To Len(aImpTmpSL1)
			If aImpTmpSL1[nI,6] == "1"
				nValorBase  -= aImpTmpSL1[nI,3]
				aDadosJur[6]+= aImpTmpSL1[nI,3]
			Endif
		Next nI
	Else 
		nValorBase  := (nValorBase - Lj7T_ImpsV("1",2)) - nValJurOri + nValDescOri
		aDadosJur[6]+= nValorBase
	Endif	       
Endif

aDadosJur[3] := nValorBase

//Aqui sera realizado o calculo do acrescimo e tb do desconto, caso o mesmo 
//exista.         
If (nTxJuros == 0) .AND. (nTxDesc == 0)          
	If (cProg <> "FRTA010") .AND. (cProg <> "LOJA701")
		aImps     := aClone(aImpsTmp)
		aImpVarSF2:= aClone(aImpSF2Tmp)
		aImpVarDup:= aClone(aImpDupTmp)
		nValTotIV := nValTotTmp
		nValBaseIV:= nValBaseTmp
	Else        
		aImpsSL1 := aClone(aImpTmpSL1)	 
		aImpsSL2 := aClone(aImpTmpSL2)	
	Endif
Else
	If cProg == "FRTA010" .OR. cProg == "LOJA701"
	    aImpsSL1 := {}
	    aImpsSL2 := {}
	Else
		aImps     := {}
		aImpVarSF2:= {}
		aImpVarDup:= {}        
		nValTotIV := 0
		nValBaseIV:= 0
	Endif       
	
	For nI := 1 To Len(aTmpAcols)
		lExpress := IIf(cProg=="LOJA010",!aTmpAcols[nI][Len(aHeader)+1],.T.)
		If lExpress
			//Calcula o novo valor do item - Desconto no Total
			If (nDescPer > 0) .AND. (cProg <> "FRTA010") .AND. (cProg <> "LOJA701")      
				nDescItem    := Round((aTmpAcols[nI][nPosValItem] * nDescPer)/100,nDecimais)
				aDadosJur[5] += nDescItem
				aTmpAcols[nI][nPosValItem] := aTmpAcols[nI][nPosValItem]-nDescItem
			Else
				nDescItem := 0		
			Endif 
			
			//Calcula o novo valor do item - Desconto na condicao de pagamento
			If nTxDesc > 0 
				nDescItem    := Round((aTmpAcols[nI][nPosValItem] * nTxDesc)/100,nDecimais)
				aDadosJur[9] += nDescItem
				aTmpAcols[nI][nPosValItem] := aTmpAcols[nI][nPosValItem]-nDescItem
				//A posicao so existe qdo a venda esta sendo realizada no 
				//modulo Front Office.
				If nPosDescPro > 0
					If cProg $ "FRTA010|LOJA010"
						aTmpAcols[nI][nPosDescPro] := nDescItem	
					Else
						aColsDet[nI][nPosDescPro] := nDescItem	
					Endif
				Endif		
			Else
				nDescItem := 0		
			Endif
			
			//Verificacao do tipo de juros aplicado.
			//Tipo 1 => Juros Simples
			//Tipo 2 => Juros Composto	
			//Tipo 3 => Tabela Price				
			If nTipoJur == 1
				If cProg <> "FRTA010" .AND. cProg <> "LOJA701"
					If lJurEntrada
						nAcresItem := Round((aTmpAcols[nI][nPosValItem] * nTxJuros)/100,nDecimais)
					Else
						If aTmpAcols[nI][nPosValItem] < nEntrada
							nValIT   := 0
							nEntrada -=	aTmpAcols[nI][nPosValItem]
						Else
							nValIT   := aTmpAcols[nI][nPosValItem] - nEntrada
							nEntrada := 0
						Endif							
							
						If nValIT > 0 
							nAcresItem := Round((nValIT * nTxJuros)/100,nDecimais)
						Endif
					Endif
				Else
					//So calcula acrescimo para itens que nao foram excluidos da venda...
					If !aTmpAcols[nI][Len(aHeader)+1]
						If lJurEntrada
							nAcresItem := NoRound((aTmpAcols[nI][nPosValItem] * nTxJuros)/100,nDecimais)
						Else
							If aTmpAcols[nI][nPosValItem] < nEntrada
								nValIT   := 0
								nEntrada -=	aTmpAcols[nI][nPosValItem]
							Else
								nValIT   := aTmpAcols[nI][nPosValItem] - nEntrada
								nEntrada := 0
							Endif							
								
							If nValIT > 0 
								nAcresItem := NoRound((nValIT * nTxJuros)/100,nDecimais)
							Endif								
						Endif
			   		Endif
				Endif
			ElseIf nTipoJur == 2
				If lJurEntrada				             
					nAcresItem := Round((aTmpAcols[nI][nPosValItem] * (( 1 + (nTxJuros/100)) ^ nNumParcelas)) - aTmpAcols[nI][nPosValItem],nDecimais)
				Else 
					If aTmpAcols[nI][nPosValItem] < nEntrada
						nValIT   := 0
						nEntrada -=	aTmpAcols[nI][nPosValItem]
					Else
						nValIT   := aTmpAcols[nI][nPosValItem] - nEntrada
						nEntrada := 0
					Endif							
								
					If nValIT > 0 
						nAcresItem := Round((nValIT * (( 1 + (nTxJuros/100)) ^ nNumParcelas)) - nValIT,nDecimais)
					Endif								
				Endif				
			ElseIf nTipoJur == 3
				If nI == 1
					nValTaxa   := nTxJuros / 100
					nDivisor   := (1 + nValTaxa) ^ nNumParcelas
					nPrestacao := Round((nValorBase-nEntrada) * ((nDivisor * nValTaxa) / (nDivisor -1)),nDecimais)
					nAcresTot  := (nPrestacao * nNumParcelas) - nValorBase
					nDifer     := nAcresTot
				Endif	
				
				nPerAcrs   := Round((aTmpAcols[nI][nPosValItem] * 100) / nValorBase,2)
				nAcresItem := Round((nAcresTot * nPerAcrs) / 100,nDecimais)
				nDifer     -= nAcresItem
				If (nI == Len(aTmpAcols)) .AND. (nDifer <> 0)
					nAcresItem += nDifer
				Endif
			Endif

			aDadosJur[1] += nAcresItem
	        aDadosJur[7] := nTxJuros
			aTmpAcols[nI][nPosValItem] := Round(aTmpAcols[nI][nPosValItem]+nAcresItem,nDecimais)		
	
			//Calcula o novo valor unitario considerando o acrescimo proporcional
			aTmpAcols[nI][nPosValUnit] := Round(aTmpAcols[nI][nPosValItem] / aTmpAcols[nI][nPosQtdItem],If(cProg=="FRTA010".OR.cProg=="LOJA701",nDecimais+1,nDecimais))
	        
			If cProg <> "FRTA010" .AND. cProg <> "LOJA701"
				SF4->( dbSetOrder(1) )
				SF4->( MsSeek( xFilial("SF4")+aTmpAcols[nI][nPosTes]) )
			
				aImpVarSD2[1] := aTmpAcols[nI][nPosQtdItem]
				aImpVarSD2[2] := aTmpAcols[nI][nPosValUnit]
				aImpVarSD2[3] := aTmpAcols[nI][nPosValItem]
				If (cProg == "LOJA010") .AND. (M->L1_FRETE > 0 .OR. M->L1_SEGURO > 0 .OR. M->L1_DESPESA > 0) .AND. lVlrFSD
					aImpVarSD2[4] := LjRatFrete(If(nI==1,.T.,.F.),nI)
				Else
					aImpVarSD2[4] := 0.00			
				Endif
				aImpVarSD2[5] := 0.00
				aImpVarSD2[6] := {}
				If cPaisLoc == "COL"
					aImpVarSD2[7] := SA1->A1_CGC // NIT Terceros
				Endif
				cCodProd := aTmpAcols[nI][nPosProd]
				CalcTesxIp( "S", (aTmpAcols[nI][nPosValItem]-nAcresItem)+nDescItem, aTmpAcols[nI][nPosValItem],cCodProd,0,nI,"BALCAO",0)
				AADD(aImps,aClone(aImpVarSD2))
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava Base de c lculo e Valor do impostos obtidos atrav‚s do ³
				//³ Roteiro da Amarra‡„o Tes X Impostos no array aCols...        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nC := 1 To Len( aImps[nI,6] )
					If aImps[nI,6,nC,4] <> 0.00 .AND. !Empty( aImps[nI,6,nC,6] )
						If ( nE := ASCAN( aImpVarSF2,{ |x| x[1] == aImps[ nI ][6][ nC ][8] } ) ) == 0
							AADD( aImpVarSF2, { aImps[ nI ][6][ nC ][8], 0.00 , aImps[ nI ][6][ nC ][2]  } )
							nE := Len( aImpVarSF2 )
						Endif

						aImpVarSF2[ nE ][2] += Round( NoRound( aImps[ nI ][6][ nC ][4], nDecs+1), nDecs)

						If ( nE := ASCAN( aImpVarSF2,{ |x| x[1] == aImps[ nI ][6][ nC ][9]  } ) ) == 0
							AADD( aImpVarSF2, { aImps[ nI ][6][ nC ][9], 0.00 , aImps[ nI ][6][ nC ][2]  } )
							nE := Len( aImpVarSF2 )
						Endif

						aImpVarSF2[ nE,2 ] += Round(NoRound(aImps[nI,6,nC,3],nDecs+1),nDecs)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Acumula em "aImpVarDup" os Impostos que Incidem no Valor  ³
						//³ Total Base da Duplicata...                                ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If SubStr( aImps[nI,6,nC,5],1,1 ) == "1"
							AAdd(aImpVarDup,{aImps[nI,6,nC,1],aImps[nI,6,nC,4]})
						Endif
					Endif
				Next nC
				
				//Acertar arredondamentos se calculou algum imposto
				If Len(aImpVarSF2) > 0
					aRedo := {}
					For nX	:=	1	To Len(aImps)
						For nY	:=	1	To Len(aImps[ nX ][6])
							If aImps[ nX ][6][ nY ][4] <> 0
								aImps[ nX ][6][ nY ][4] := Round( NoRound( aImps[ nX ][6][ nY ][4], nDecs+1),nDecs)
								aImps[ nX ][6][ nY ][3] := Round( NoRound( aImps[ nX ][6][ nY ][3], nDecs+1),nDecs)
								If ( nPosImp := ASCAN( aRedo,{ |x| x[1]== aImps[ nX ][6][ nY ][8] .AND. x[2]== aImps[ nX ][6][ nY ][9] } ) ) == 0
									AADD( aRedo,{ aImps[ nX ][6][ nY ][8], aImps[ nX ][6][ nY ][9], aImps[ nX ][6][ nY ][4],aImps[ nX ][6][ nY ][3]})
								Else
									aRedo[ nPosImp ][3] += aImps[ nX ][6][ nY ][4]
									aRedo[ nPosImp ][4] += aImps[ nX ][6][ nY ][3]
								Endif
							Endif
						Next nY
					Next nX
				   
					For nX	:=	1	To Len(aRedo)
						//Acertar el redondeo en la base del impuesto
						nPosImp	:=	Ascan( aImpVarSF2,{ |x| x[1] == aRedo[ nX ][1]})
						aImpVarSF2[ nPosImp ][2] := Round( NoRound( aImpVarSF2[ nPosImp ][2], nDecs+1), nDecs)
						nDif	:=	aImpVarSF2[ nPosImp ][2] - aRedo[ nX ][3]
						lAchou	:=	.F.
						While !lAchou
							For nY	:=	1	To Len(aImps)
								If ( nPosIt := ASCAN( aImps[ nY ][6],{ |X| x[8] == aRedo[ nX ][1] } ) ) > 0
									aImps[ nY ][6][ nPosIt ][4] += nDif
									lAchou	:=	.T.
									nY	:=	Len(aImps)+1
								Endif
							Next nY
						End
						//Acertar el redondeo en el valor del impuesto
						nPosImp	:=	Ascan(aImpVarSF2,{|x| x[1]==aRedo[nX][2]})
						aImpVarSF2[ nPosImp ][2] := Round( NoRound( aImpVarSF2[ nPosImp ][2], nDecs+1), nDecs)
						nDif	:=	aImpVarSF2[ nPosImp ][2] - aRedo[ nX ][4]
						lAchou	:=	.F.
						While !lAchou
							For nY	:=	1	To Len(aImps)
								If ( nPosIt := ASCAN( aImps[ nY ][6],{|X| x[9] == aRedo[ nX ][2] } ) ) > 0
									aImps[ nY ][6][ nPosIt ][3] += nDif
									lAchou	:=	.T.
									nY	:=	Len(aImps)+1
								Endif
							Next nY
						End
					Next nX
				Endif
			Else                         
				If cProg == "FRTA010"
					If !aTmpAcols[nI][Len(aHeader)+1]
						lRecalImp := .T. //Determina que ocorreu um calculo de acrescimo...
						//Calcula o novo valor do item
						nValIT    := (aTmpAcols[nI][nPosQtdItem] * aTmpAcols[nI][nPosValUnit])
						nDifIT    += nValIT - NoRound(aTmpAcols[nI][nPosQtdItem]*aTmpAcols[nI][nPosValUnit],nDecimais)              
						nVlrTotIT := NoRound(aTmpAcols[nI][nPosQtdItem]*aTmpAcols[nI][nPosValUnit],nDecimais)
						If nI == Len(aTmpAcols)
							nVlrTotIT += nDifIT				
							aTmpAcols[nI][nPosValItem] := nVlrTotIT
						Endif
						nTotImp   := 0
					    aInfImp   := TesImpInf(aTmpAcols[nI][nPosTes])
						MaFisIni(SA1->A1_COD, SA1->A1_LOJA, "C", "S", SA1->A1_TIPO,,, .F., "SBI")
						MaFisAdd(aTmpAcols[nI][nPosProd],aTmpAcols[nI][nPosTes],aTmpAcols[nI][nPosQtdItem],aTmpAcols[nI][nPosValUnit], 0, "", "",, 0, 0, 0, 0, nVlrTotIT, 0)
					    Aadd(aImpsSL2,{aTmpAcols[nI][nPosProd],aTmpAcols[nI][nPosTes],{}})
					    For nA := 1 to Len(aInfImp)
					       	If ( nE := ASCAN( aImpsSL1,{ |x| x[1] == aInfImp[ nA ][1] } ) ) == 0
					        	Aadd( aImpsSL1,{ aInfImp[ nA ][1], "L1_" + SUBSTR( aInfImp[ nA ][6], 4, 7), 0, "L1_" + SUBSTR( aInfImp[ nA ][8], 4, 7), 0, aInfImp[ nA ][3], aInfImp[ nA ][9] } )
					        	nE := Len(aImpsSL1)
					       	Endif   
					       	cIndImp   := SUBSTR( aInfImp[ nA ][2], 10, 1)               
					       	cCampoVal := "IT_VALIV"  + cIndImp		    
					       	cCampoAlq := "IT_ALIQIV" + cIndImp
					       	nValImp   := Round(MaFisRet(nI,cCampoVal),nDecimais) 
					       	FRTGeraImp(@aImposto,aInfImp[nA],nValImp,aTmpAcols[nI][nPosQtdItem],aTmpAcols[nI][nPosValUnit],nI,cIndImp)			   
						   	AAdd(aImpsSL2[nI][3],aClone(aImposto))
						   	nTotImp += (nValImp * aImposto[10,Val(Subs(aImposto[5],2,1))])			   
						   	aImpsSL1[ nE,3 ] += aImpsSL2[len(aImpsSL2)][3][nA][4]	//Valor do imposto no cabecalho		   			   
						   	aImpsSL1[ nE,5 ] += aImpsSL2[len(aImpsSL2)][3][nA][3]	//Base do imposto no cabecalho		   			   		   
					    Next nA      
					    AAdd(aImpsSL2[nI],aTmpAcols[nI][nPosItem])
					    AAdd(aImpsSL2[nI],.F.)
					                         
						aTmpAcols[nI][nPosValUnit] := Round(aTmpAcols[nI][nPosValUnit],nDecimais)			    
						aProdSL2 := {	{"L2_VRUNIT" , aTmpAcols[nI][nPosValUnit]},;
						             	{"L2_VLRITEM", nVlrTotIT},;
									    {"L2_ITEM"   , aTmpAcols[nI][nPosItem]},;
	   								    {"L2_DESCPRO", aTmpAcols[nI][nPosDescPro]}}
					
						For nK := 1 to Len(aImpsSL2[nI][3])
					    	Aadd(aProdSL2,{aImpsSL2[nI][3][nK][6],aImpsSL2[nI][3][nK][4]})   //Valor do imposto
				            Aadd(aProdSL2,{aImpsSL2[nI][3][nK][7],aImpsSL2[nI][3][nK][3]})   //Base do imposto         
				            Aadd(aProdSL2,{"L2_ALQIMP"+Substr(aImpsSL2[nI][3][nK][7],10,1),aImpsSL2[nI][3][nK][2]})   //Aliquota do imposto                           
				        Next nK   
						AAdd(aSL2,aClone(aProdSL2))
						nValImps += Round(nTotImp,nDecimais) 
					Else                                     
						//Insere linha original no aImpsSL2 para que ele permaneca
						//com o mesmo tamanho...
					    AAdd(aImpsSL2,aClone(aImpTmpSL2[nI]))
					Endif
				Else
					nValIT    := (aTmpAcols[nI][nPosQtdItem] * aTmpAcols[nI][nPosValUnit])
					nDifIT    += nValIT - NoRound(aTmpAcols[nI][nPosQtdItem]*aTmpAcols[nI][nPosValUnit],nDecimais)              
					nVlrTotIT := NoRound(aTmpAcols[nI][nPosQtdItem]*aTmpAcols[nI][nPosValUnit],nDecimais)
					If nI == Len(aTmpAcols)
						nVlrTotIT += nDifIT				
						aTmpAcols[nI][nPosValItem] := nVlrTotIT
					Endif
					aTmpAcols[nI][nPosValUnit] := Round(aTmpAcols[nI][nPosValUnit],nDecimais)			    

					// Acerta o valor unitario nas funcoes fiscais...
					MaFisAlt("IT_PRCUNI",aTmpAcols[nI][nPosValUnit],nI)
					
					// Executa o recalculo dos impostos variaveis...
					Lj7RecalImp(nI,6,"IT_VALMERC",aTmpAcols[nI][nPosValItem])	
					                       
					If nI == Len(aTmpAcols)						
						nValImps := Lj7T_ImpsV("1",2)           

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Ajusta os valores de desconto (valor e percentual)           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If aDadosJur[9] <> 0
						    Lj7T_DescV( 2, aDadosJur[9] )
						    LJ7T_DescP( 2, nTxDesc )
						    aDesconto[1] := 2
						Endif
					Endif
				Endif
			Endif
		Endif
	Next nI      
	       
	If cProg <> "FRTA010" .AND. cProg <> "LOJA701"
		//Verifica se o imposto eh incluido ou descriminado
		For nI := 1 To Len(aImps)
			For nX := 1 To Len(aImps[nI][06])
				If Substr(aImps[nI,6,nX,5],2,1) == "1"
					nValImps += Round(aImps[nI,6,nX,4],nDecimais)
				Endif
			Next nX
		Next nI
		
		For nX	:= 1 To Len(aImps)
			aInfImp	:=	TesImpInf(aTmpAcols[nX][nPosTes])
			For nY	:=	1	To Len(aImps[nX][6])
				If ( aInfImp[nY][3]=="1" )
					nValTotIV	+= aImps[nX][6][nY][4]
				Endif
			Next nY
		Next nX
		nValTotIV  := Round(NoRound(nValTotIV,nArredImp+1),nArredImp )
		nValBaseIV := Round(NoRound(nValTotIV,nArredImp+1),nArredImp )	
	Else 
		If cProg == "FRTA010"
			MaFisEnd()
			FRTGravaSL2(aSL2) //Função para atulizar o arquivo SL2 -  Localizações			   
		Endif
	Endif
	aDadosJur[4] := nValImps
	aDadosJur[7] := nTxJuros  
	aDadosJur[8] := nDescLoj
Endif

If nValImps == 0
	nValImps := aDadosJur[6]
	If cProg == "FRTA010"
		For nI := 1 To Len(aTmpAcols)
			If !aTmpAcols[nI][Len(aHeader)+1]
	   			aProdSL2  := {}
				nVlrTotIT := aTmpAcols[nI][nPosQtdItem] * aTmpAcols[nI][nPosValUnit]
				aProdSL2 := {	{"L2_VRUNIT" , aTmpAcols[nI][nPosValUnit]},;
				             	{"L2_VLRITEM", nVlrTotIT},;
							    {"L2_ITEM"   , aTmpAcols[nI][nPosItem]}}	
				
				For nK := 1 to Len(aImpTmpSL2[nI][03])
		    		Aadd(aProdSL2,{aImpTmpSL2[nI][03][nK][6],aImpTmpSL2[nI][03][nK][4]})   //Valor do imposto
	            	Aadd(aProdSL2,{aImpTmpSL2[nI][03][nK][7],aImpTmpSL2[nI][03][nK][3]})   //Base do imposto         
	            	Aadd(aProdSL2,{"L2_ALQIMP"+Substr(aImpTmpSL2[nI][03][nK][7],10,1),aImpTmpSL2[nI][03][nK][2]})   //Aliquota do imposto                           
		        Next nK   
	   			AAdd(aSL2,aClone(aProdSL2))
	   		Endif						    
		Next nI
		FRTGravaSL2(aSL2)
		
		//Zera o array aDadosJur
		If (nTxjuros == 0) .AND. (nTxDesc == 0)
			AEval(aDadosJur,{|x,y| aDadosJur[y]:=0 })
		Endif 
	Endif
Endif

Return(nValImps)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj010DocsC³ Autor ³Fernando Machima       ³ Data ³ 10/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela para digitacao de documentos para clientes tipo Consu-³±±
±±³          ³ midor Final cuja venda seja superior ao determinado no pa- ³±±
±±³          ³ rametro MV_LIMCFIS                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj010DocsCF(cTipoDocCF,cNumDocCF,cClienteCF,cEnderCF,      ³±±
±±³          ³ cTipoCI)                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Venda Balcao (Loc. Argentina)                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj010DocsCF(cTipoDocCF,cNumDocCF,cClienteCF,cEnderCF,cTipoCI)   
LOCAL lRet      := .F.
LOCAL cCbxTpDoc := ""
LOCAL nPosDocCF
LOCAL aTipoDoc  := {}
Local aTipoCI   := {}
LOCAL aArea     := GetArea()
LOCAL oDlgLojaDocs
LOCAL oTipoDoc
Local oTipoCI

DbSelectArea("SX3")
DbSetOrder(2)
If MsSeek("LS_TPDOCCF")
   cCbxTpDoc  := X3CBox()  //O combo box pode variar de impressora para impressora
Endif   
While .T.
   nPosDocCF  := At(";",cCbxTpDoc)
   If !Empty(cCbxTpDoc) 
      If nPosDocCF > 0  //Preenche no array aTipoDoc com as opcoes disponiveis
         Aadd(aTipoDoc,Substr(cCbxTpDoc,1,nPosDocCF-1))   
      Else //Ultimo elemento
         nPosDocCF  := Len(cCbxTpDoc)
         Aadd(aTipoDoc,Substr(cCbxTpDoc,1,nPosDocCF))         
         Exit
      Endif   
      cCbxTpDoc  := Substr(cCbxTpDoc,nPosDocCF+1)
   Else
      Exit   
   Endif
End

//Busca os tipos de CI na tabela "OC" do arq. SX5
DbSelectArea("SX5")
If MsSeek(xFilial("SX5")+"OC")
   While xFilial("SX5")+"OC" == SX5->X5_FILIAL+AllTrim(SX5->X5_TABELA)
      If Substr(X5Descri(),4,3) == "CI "
         Aadd(aTipoCI,Substr(X5Descri(),1,2)+"-"+Substr(X5Descri(),4))
      Endif
      DbSkip()
   End
Endif

DEFINE MSDIALOG oDlgLojaDocs FROM 12, 14 TO 23, 80 TITLE STR0073; //"Dados para Consumidor Final"
STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oDlgLoja
												
@ 00.3 , 01 TO 5,31.2 OF oDlgLojaDocs

@ 01.0 , 01.5 SAY STR0074 //"Tipo do Documento"
@ 12.0 , 69.5 MSCOMBOBOX oTipoDoc VAR cTipoDocCF ITEMS aTipoDoc OF oDlgLojaDocs SIZE 92,40 ON CHANGE Lj010TipoDoc(cTipoDocCF,oTipoCI) PIXEL

//Tipo CI
@ 12.0 , 163  MSCOMBOBOX oTipoCI VAR cTipoCI ITEMS aTipoCI OF oDlgLojaDocs SIZE 82,40 PIXEL
						
@ 02.0 , 01.5 SAY STR0075 //"Numero do Documento"
@ 25.0 , 69.5 MSGET cNumDocCF RIGHT SIZE 92,10 OF oDlgLojaDocs PIXEL PICTURE PesqPict("SLS","LS_DOCCF");
               VALID Lj010Cuit(cNumDocCF,cTipoDocCF)

@ 03.0 , 01.5 SAY STR0076 //"Nome do Cliente"
@ 37.0 , 69.5 MSGET cClienteCF RIGHT SIZE 175,10 OF oDlgLojaDocs PIXEL 

@ 04.0 , 01.5 SAY STR0077 //"Endereco"
@ 49.0 , 69.5 MSGET cEnderCF RIGHT SIZE 175,10 OF oDlgLojaDocs PIXEL 
					

DEFINE SBUTTON FROM 70,103 TYPE 1 ACTION (IIf(Lj010VldCF(cTipoDocCF,cNumDocCF,cClienteCF,cEnderCF),;
lRet := .F.,(lRet:= .T.,IIf(cTipoDocCF<>"6",cTipoCI := "",cTipoCI := Substr(cTipoCI,1,2));
,oDlgLojaDocs:End()))) ENABLE OF oDlgLojaDocs

DEFINE SBUTTON FROM 70,136 TYPE 2 ACTION (lRet:= .F.,oDlgLojaDocs:End()) ENABLE OF oDlgLojaDocs
						
ACTIVATE MSDIALOG oDlgLojaDocs ON INIT Lj010TipoDoc(cTipoDocCF,oTipoCI)

RestArea(aArea)

Return (lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj010VldCF³ Autor ³Fernando Machima       ³ Data ³ 10/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se todos os dados do Cliente foram digitados na   ³±±
±±³          ³ tela quando Consumidor Final e venda > MV_LIMCFIS          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj010VldCF()                 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Venda Balcao (Loc. Argentina)                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj010VldCF(cTipoDocCF,cNumDocCF,cClienteCF,cEnderCF)

LOCAL lRet  

lRet  := Empty(cTipoDocCF) .OR. Empty(cNumDocCF) .OR. Empty(cClienteCF) .OR. Empty(cEnderCF)

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o   ³lj10DescV ³ Autor ³ Adrianne Furtado      ³ Data ³ 11.03.03   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o³ Desconto em valor - Verifica se o valor e o percentual estao ³±±
±±³         ³ dentro do limite do usuario								   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso     ³ SigaLoja                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DATA    ³ BOPS ³Program. ³ALTERACAO                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³01/09/06 ³105104³Guilherme³ Alteracao da Funcao lj10DescV, para corre-  ³±±
±±³         ³      ³Santos   ³ cao de inconsistencia durante a validacao   ³±±
±±³         ³      ³         ³ do desconto.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010DescV(	nVlrTot,	oDescont,	nDescloj,	oDescPer,;
						nDescPer,	cNumOrc,	oVlrLiq,	nVlrImpInc,;
						oAutorDesc,	cAutorDesc,	nLiq)

Local lLjDescNv 	:= ExistBlock("LJDESCNV")
Local lDescOK 		:= .T.
Local nVlrTotAnt 	:= nVlrTot + IIf(cPaisLoc <> "BRA", nVlrImpInc, 0)
Local lNoArredDesc  := nDecimais == 0  
Local nArredDesc    := TamSX3("L1_DESCNF")[2]
Local nDecs         := IIf(lNoArredDesc,nArredDesc,nDecimais)
Local aAreaX3   	:= SX3->( GetArea() )
Local aArea     	:= GetArea()
If nDescLoj > 0
	nDescPer := Round((nDescloj * 100) / nVlrTot, nDecs )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se houve alteracao na porcentagem de desconto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !( nDescPer == __nDescPer ) .OR. !( nDescLoj == __nDescLoj )
		__lAplicDesc 	:= .F.				//Seta a variavel de aplicacao de desconto como falso
		__nDescPer 		:= nDescPer			//Seta a variavel com a porcentagem de desconto com a nova porcentagem de desconto
		__nDescLoj 		:= nDescLoj			//Seta a variavel com o valor de desconto com o novo valor de desconto
	Endif

	// Valor do desconto nao permitido para o caixa atual / Desconto nao autorizado
	
	If lLjDescNv
		If !__lAplicDesc	
		   lDescOk := ExecBlock("LJDESCNV",.F.,.F.,{nDescPer,nDescLoj,nVlrTot})
		   __lAplicDesc  := lDescOk
		Endif
	Else		         
	    aDesc := {'V', nDescLoj}
	    If !Ljprofile(11,@cAutorDesc,aDesc, nDescPer, nDescLoj )
			lDescOk := .F.
		Endif	
		If !Empty(cAutorDesc)
			cAutorDesc += DToC(dDataBase)
		Endif
	Endif 
Endif
	
If !lDescOk
    lRet       := .F.
    nDescLoj   := 0
    nDescPer   := 0
    nLiq       := nVlrTotAnt
    nVlrLiq    := nVlrTotAnt
    nValorBase := nVlrTotAnt
Endif

oDescont:ReFresh()
oDescPer:Refresh()
oVlrLiq:Refresh()
oAutorDesc:Refresh()
	
If Len(aAreaX3) > 0
	RestArea(aAreaX3)
Endif	
If Len(aArea) > 0
	RestArea(aArea)
Endif	

Return lDescOk

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj010TipoD³ Autor ³Fernando Machima       ³ Data ³ 23/05/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tratamento para tipo de documento CI                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj010TipoDoc(cTipoDocCF,oTipoCI)							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Venda Balcao (Loc. Argentina)                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj010TipoDoc(cTipoDocCF,oTipoCI)

If cTipoDocCF == "6"  //CI
   oTipoCI:Show()              		   		   
Else
   oTipoCI:Hide()              		   		      
Endif
oTipoCI:Refresh()		   		                   		      
   
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj010Cuit ³ Autor ³Fernando Machima       ³ Data ³ 29/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do CUIT                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj010Cuit(cNumDocCF,cTipoDocCF)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Venda Balcao (Loc. Argentina)                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj010Cuit(cNumDocCF,cTipoDocCF)

Local lRet  := .T.

If !Empty(cNumDocCF) .AND. cTipoDocCF == "1"  //CUIT
   lRet  := Cuit(cNumDocCF,"A1_CGC")
Endif

Return (lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj010VldBco ³ Autor ³Fernando Machima       ³ Data ³ 29/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o codigo do Banco informado, na tela de captacao dos  ³±±
±±³          ³ cheques.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj010VldBco(cBanco)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Venda Balcao (Localizacoes)                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj010VldBco(cBanco)

Local lRet     := .T.        
Local aAreaAtu := GetArea()
Local aAreaSX5 := {}

cBanco := cBanco+Space(TamSx3("X5_CHAVE")[1] - Len(cBanco))

dbSelectArea("SX5")
aAreaSX5 := GetArea()
dbSetOrder(1)
If !MsSeek(xFilial("SX5")+"BC"+cBanco)
	lRet := MsgYesNo(STR0079+AllTrim(cBanco)+STR0080) //"Confirma el Codigo "###", mismo el no existiendo en la tabla 'BC' del archivo SX5"
Endif             

// Restaura as areas originais...
RestArea(aAreaSX5)
RestArea(aAreaAtu)

Return(lRet)
