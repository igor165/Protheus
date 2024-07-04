#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA010B.CH"

#DEFINE _PICTURE		16

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Este Log é um recurso a ser habilitado pelo departamento de desenvolvimento para averigua-³
//³ção de possíveis problemas de transações TEF.                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE LOG_TEF 	If( File(GetClientDir()+"SIGALOJA.INI") .AND. ;
                         GetPvProfString("Logs TEF","Habilita","01",GetClientDir()+"SIGALOJA.INI") == "01", ;
                         "\AUTOCOM\TEF"+cEmpAnt+cFilAnt+"\", ;
                         "" )

STATIC lFiltSer
STATIC __lDescPerg 	:= .F. //Variavel para mostrar tela novamente ou nao

//Variavel utilizada para a escolha do desconto sobre o valor total 
//Valor ou Porcentagem
STATIC __cTpDesc 	:= "V"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj010Num  ³ Autor ³ Vendas Clientes       ³ Data ³ 08.06.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica numero do or‡amento.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Num(	cNumOrc,		cNumSX8,		lInclui,		lAltera,;
					cCliente,		cLoja,			nDescloj,		nVlrLiq,;
					cVendLoja,		dDtLim,			nVlrTot,		nEntrada,;
					nFinanciado,	nParcelas,		nIntervalo,		oCliente,;
					oLoja,			oAutorDesc,		oDescont,		oVlrLiq,;
					oVlrLiq1,		oVlrLiq2,		oVend,			oVlrTot,;
					oDtLim,			cCombo,			oCombo,			cComboAnt2,;
					cCondicao,		cDescCond,		lFirstAlter,	aCondicoes,;
					oEntrada,		oNumParcelas,	oFinanciado,	nValorBase,;
					cForma,			nCondicao,		nNumParcelas,	oTxJuros,;
					oReceb,			nCheck,			lCheck3,		oCheck1,;
					oCheck3,		oGetOrca,		cNumOrcAnt,		nVlrAcrs,;
					oVlrAcrs,		oNroPCli,		cNroPCli,		nFator,;
					lUsouFator,		cAdmFator,		cTipoJuros,		oTipoJuros,;
					nLiq,			oVlrItens,		nVlrItens,		nDescPer,;
					cDesc,			oDesc,			lLjMontP,		nTipoJur,;
					cLJDTORC,		lLJDTOrc,		aMoedas,		aTroco,;
					nOpcx,			nTxDescon,		cMoeda,			aMoeda)

Local nI
Local lAchou    := .F.
Local lLj10Num  := ExistBlock("LJ10NUM")
Local aCRec		:= {}
Local nDecs     := MsDecimais(nMoedaCor)
Local nOrderSL1
Local lLjMod3 	:= SuperGetMV("MV_LJMOD3")
Local cNumOrcAtu
Local nLinProd  := 0
Local nPosProd  := 0
Local aParcAtu
Local aParcOrig
Local aParcCor
Local lAlt		:=.F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis utilizadas para as funcoes de auxilio do calculo³
//³do desconto manual e financeiro.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nVlrOri 	:= 0
Local nDescTot 	:= 0
Local nDescFin 	:= 0
Local nTamL1_DESCNF	:= TamSX3( "L1_DESCNF" )[2]	// Tamanho do campo L1_DESCNF

lLjMontP := .T. 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O parametro MV_LJDTORC definira o ajuste das datas do orcamento, sendo:    ³
//³ "N" - Nunca Ajusta as datas, ou seja, sempre a que foi gravada             ³
//³ "S" - Sempre Ajusta as datas, ou seja, Atualiza a data baseado no dia atual³
//³ "P" - Pergunta, ou seja, fara uma pergunta se deseja ajustar as datas      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cLJDTORC := SuperGetMV("MV_LJDTORC")
lLJDTOrc := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o numero do orçamento atual. Se estiver utilizando        ³
//³o modelo 3 então pega da variavel M->L1_NUM, caso contrario        ³
//³pega do objeto oGetOrca.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLJMod3
	cNumOrcAtu := M->L1_NUM
Else
	cNumOrcAtu := oGetorca:Cargo
Endif

If dDataBase <= If(FindFunction("MVUlmes"),MVUlmes(),GetMV("MV_ULMES"))
	Help(" ",1,"MV_ULMES")
	Return .F.
EndIf

If lLj10Num
	
	// Permitira carregar o aCols sem necessariamente os dados estarem no Siga.
	
	If ! ExecBlock("LJ10NUM",.F.,.F.)
		Return .T.
	EndIf
EndIf

DBSelectArea("SL1")
nOrderSL1 := IndexOrd()
DBSetOrder(1)
lCombo:=.T.

If cNumOrc == cNumOrcAtu .AND. !LjExiLog( cNumOrc )[1] //O Numero digitado nao mudou
	Return .T.
Else
	If Empty(cNumOrc)
		cNumOrc := cNumOrcAtu
	Endif
Endif

If !(DbSeek(xFilial("SL1") + cNumOrc)) //.AND. &(ReadVar()) <> cNumOrc
	//Libera os registros lockados...
	MsUnLockAll()
	nDesPerTot:= 00.00
	lFirstAlter := .T.
	
	If cNumOrc # cNumOrcAnt
		lFirstOrc := .T.
		lInclui := .T.
		lAltera := .F.
		If cNumOrc > cNumOrcAtu .AND. cNumOrc <= cNumSx8
			If lLjMod3
				M->L1_NUM := cNumOrc
			Else
				oGetOrca:Cargo := cNumOrc
			Endif
		EndIf
	EndIf
	
	If (lFirstOrc .AND. cNumOrc == cNumOrcAtu) .OR. (cNumOrc < cNumOrcAtu)
		lInclui		:= .T.
		If cNumOrc > cNumSx8
			Help( " ",1,"FORA_SEQ")
			lFirstOrc := .T.
			lInclui	 := .T.
			lAltera	 := .F.
			Return .F.
		EndIf
		lAltera		:= .F.
		lFirstAlter := .T.
		nDescloj 	:= 0
		nVlrliq		:= 0
		dDtlim		:= dDataBase + SuperGetMV("MV_DTLIMIT")
		nVlrtot		:= 0
		nEntrada 	:= 0
		nFinanciado := 0
		nTxJuros 	:= 0
		nParcelas	:= 1
		nIntervalo	:= 0
		aPgtos		:= {{Ctod("  /  /  "),0,Space(15),nMoedaCor}}
		aParcTef := aClone(aPgtos)
		cCondicao	:= PADR(SuperGetMV("MV_CONDPAD"),3)
		cNroPCli 	:= Space(9)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega o Log de Recuperacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCRec := LjRecLog(cNumOrc) // Log de Recuperacao
		If Len(aCRec[1]) >= 1
			aCols := aCRec
			SayWinSub(@nVlrTot    ,@nVlrLiq        ,@nValorBase     ,@nLiq     ,;
			          @nDescloj   ,aPosicoes[2][2] ,@oVlrTot        ,oVlrLiq   ,;
			          oVlrLiq1    ,oVlrLiq2         ,oDesc           ,@nDescPer,;
			          oDescont    ,"DESCVAL"        ,0               ,;
			                      ,0                ,1               ,;
			          0           )
		Else
			Lj010Det(cCliente   ,cNumOrc    ,.F.    ,.T.     ,;
					 @oVlrItens ,@nVlrItens )
		Endif
		oGet:oBrowse:Refresh()
		If lLjMod3
			M->L1_NUM := cNumOrc
		Else
			oGetorca:Cargo := cNumOrc
		Endif
		lFirstOrc		:= .F.
		cNumOrcAnt		:= cNumOrc
		cOrcamen       := cNumOrc
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Refresh dos dados do Folder1 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ! lLjMod3
			oCliente:Refresh()
			oLoja:Refresh()
			oVend:Refresh()
			oDtLim:Refresh()
			oNroPCli:Refresh()
		Endif
		oDescont:Refresh()
		oVlrLiq:Refresh()
		oVlrLiq1:Refresh()
		oVlrLiq2:Refresh()
		oVlrTot:Refresh()
		oCheck1:Refresh()
		oCheck3:Refresh()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega o combo com a condicao de pagto padrao e calcula ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCombo := lj010IniCom(aCondicoes    ,@cCombo     ,oEntrada    ,oNumParcelas    ,;
		                      oFinanciado   ,@nValorBase ,@cForma     ,@nEntrada       ,;
							  @nFinanciado  ,@nCondicao  ,@cCondicao  ,@nNumParcelas   ,;
							  oTxJuros      ,@cDescCond  ,lUsouFator   ,lInclui        ,;
							  nOpcx         )
		
		For nI := 1 to Len(aCondicoes)
			If Upper(Substr(aCondicoes[nI],1,3)) == Upper(SubsTr(cCombo,1,3))
				cCombo := aCondicoes[nI]
				oCombo:nAt := nI
				Exit
			EndIf
		Next nI
		
		oCombo:Refresh()
		cComboAnt2 := cCombo
	EndIf
Else
	lAchou :=.T.
	If cNumOrc # cNumOrcAtu .OR. cNumOrc # cNumOrcAnt
		If !Empty(SL1->L1_DOC)
			Help(" ",1,"VENDIDO")
			aCols := {}
			Lj010Det(cCliente,cNumOrc,.T.,.T.,@oVlrItens,@nVlrItens)
			lAltera		 := .F.
			lInclui		 := .T.
			lFirstAlter  := .T.
			lFirstOrc	 := .T.
			Return .F.
		EndIf
		
		MsUnLockAll() // Libera os registros travados pelo SoftLock()
		
		If !SoftLock("SL1")
			Return (.F.)
		Endif
		
		lFirstOrc := .T.
		If cNumOrc # cNumOrcAnt
			lFirstAlter := .T.
		EndIf
		If lFirstAlter
			lAltera		 := .T.
			lInclui		 := .F.
			lFirstAlter  := .F.
			
			// Verifica a data de validade do Orcamento antes de carregar outros dados.
			dDtLim		 := SL1->L1_DTLIM
			
			If !Lj010DtLim(dDtLim,cCliente,cNumOrc)
				lFirstAlter  := .T.
				lAltera		 := .F.
				lInclui		 := .T.
				Return .F.
			EndIf
			
			If lLjMod3
				M->L1_NUM := cNumOrc
			Else
				oGetOrca:Cargo := cNumOrc
			Endif
			
			cNumOrcAnt	 := cNumOrc
			cOrcamen     := cNumOrc
			
			cCliente 	 := SL1->L1_CLIENTE
			cLoja 		 := SL1->L1_LOJA
			SA1->(DBSetOrder(1))
			SA1->(DbSeek(xFilial("SA1")+cCliente+cLoja))
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calculo dos descontos manual e financeiro tendo como ³
			//³base o desconto total da venda                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTxDescon 	:= LJ010DesFin( SL1->L1_CONDPG )
			nVlrLiq		:= SL1->L1_VLRLIQ
			nDescTot 	:= ( SL1->L1_DESCONT / ( nVlrLiq + SL1->L1_DESCONT ) ) * 100

			If nDescFin <> nDescTot
				LJ010VlrOri( @nVlrOri, nVlrLiq, nDescTot, nTxDescon )
				LJ010DesMan( nVlrOri, nTxDescon, @nDescLoj, @nDescPer, nDescTot )
			Else
				nDescLoj     := SL1->L1_DESCONT
				nDescPer     := Round( ( ( SL1->L1_DESCONT / SL1->L1_VLRTOT ) * 100 ), nTamL1_DESCNF )
			EndIf

			nVlrtot		 := SL1->L1_VLRTOT
		
			If ( nVlrTxDesc := ( SL1->L1_DESCONT - nDescLoj ) ) <= 0
				nVlrTxDesc := 0
			EndIf
			
			nVlrLiq		 := SL1->L1_VLRLIQ + If( lVlrFSD, SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA, 0 )
			cVendLoja	 := SL1->L1_VEND
			nEntrada 	 := SL1->L1_ENTRADA
			nTxJuros 	 := SL1->L1_JUROS
			nFinanciado  := SL1->(L1_CHEQUES+L1_CARTAO+L1_CONVENI+L1_VALES+L1_FINANC+L1_OUTROS)
			nParcelas	 := SL1->L1_PARCELA
			nNumParcelas := SL1->L1_PARCELA
			nIntervalo	 := SL1->L1_INTERV
			nFator		 := SL1->L1_FATOR
			cAdmFator	 := SL1->L1_ADMFIN
			cCondicao    := SL1->L1_CONDPG
			cBlCred      := SL1->L1_BLCRED			
			cAutorDesc   := SL1->L1_LOGDESC
			M->L1_CLIENTE:=cCliente
			If SL1->L1_TIPOJUR == 0 .OR. SL1->L1_TIPOJUR == 1
				nTipoJur := 1
				cTipoJuros := STR0091 //Simples
			Else
				nTipoJur := SL1->L1_TIPOJUR   
				cTipoJuros := STR0092 //Serie Pgto.
			EndIf
			
			If cPaisLoc <> "BRA"
				nMoedaCor	:= SL1->L1_MOEDA
				nTaxaMoeda 	:= SL1->L1_TXMOEDA 
				cMoeda 		:= aMoeda[nMoedaCor]
				nVlrLiq   	:= Round(SL1->L1_VLRTOT,nDecs)
				nVlrTot   	:= Round(SL1->L1_VLRLIQ,nDecs)
				lCredFisc	:= SA1->A1_TIPO $ "1|4"
			EndIf
			lUsouFator	 := ( SL1->L1_FATOR > 0 )
			nValorBase   := nVlrLiq
			nLiq         := nValorBase
			If lUsouFator
				
				// Fator - Pr¢prio / Fator - Outros / Simples
				
				SAE->(DbSeek( xFilial("SAE") + cAdmFator ))
				SAE->(If(!Eof(),If( SAE->AE_FINPRO == "S",;
				cTipoJuros := STR0001,;
				cTipoJuros := STR0002),cTipoJuros := STR0003 ) )
			EndIf
			If Round(NoRound(nValorBase,nDecs),nDecs) > Round(NoRound(nFinanciado +;
				nEntrada,nDecs),nDecs)
				nVlrAcrs  := 0
			ElseIf nTxJuros > 0
				nVlrFSD  := SL1->L1_FRETE + SL1->L1_SEGURO + SL1->L1_DESPESA
				nVlrAcrs := ((nFinanciado + nEntrada) - SL1->L1_VLRLIQ) - LJ010VlrFSD()
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Checa a opcao de impressao que foi gravada no orcamento ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nCheck   := Val(Substr(SL1->L1_IMPRIME,1,1))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida se o ncheck não for 2, o MV_FISNOTA for verdadeiro e também se o MV_LOJAOPI for 2 (NF)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(nCheck == 2 .AND. SuperGetMV("MV_FISNOTA") .AND. SuperGetMV("MV_LOJAOPI") == 2)
				nCheck   := If( lFiscal, If( nCheck > 1, 1, nCheck ), If( nCheck == 1, 2, nCheck ) )
			Endif		

			lCheck3	 := If(Substr(SL1->L1_IMPRIME,2,1) == "S",.T.,.F.)
            If lFiscal // Impressora Fiscal nao exibira a opcao Nao Imprimir
               If !SuperGetMV("MV_FISNOTA")
              	  nCheck := 1
               EndIf	  
            EndIf
			cNroPCli := SL1->L1_NROPCLI

			cLJDTORC:=If(SL1->L1_EMISSAO=dDataBase,'N',cLJDTORC)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gerar um array com os dados da condicao de pagamento        ³
			//³original e um array com as condicao se fosse calculada hj   ³
			//³para efeito de comparacao se foi alterado o calculo original³
			//³somente qdo nao for condicao negociada ( CN ) ou parametro  ³
			//³estiver habilitado para ajustar as datas e se a data de     ³
			//³geracao do orcamento for diferente da data do fechamento do ³
			//³orcamento                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SL1->L1_CONDPG<>'CN'.AND.cLJDTORC$'SP'
				aParcAtu  := Condicao( nValorBase , cCondicao,,, nRetICMS )
				aParcOrig := Condicao( nValorBase , cCondicao,,SL1->L1_EMISSAO, nRetICMS )
			Else
				lAlt:=.T.
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega matriz de parcelas a partir do SL4	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DBSelectArea("SL4")
			SL4->( DBSetOrder(1) )
			
			If SL4->( DbSeek(xFilial("SL4") + cNumOrc) )
				aPgtos := {}
				aReceb := {}
				aParcCor := {}
				While !Eof() .AND. xFilial("SL4") == SL4->L4_FILIAL .AND. cNumOrc == SL4->L4_NUM
				    If cPaisLoc == "BRA"
						Aadd(aPgtos,{SL4->L4_DATA,SL4->L4_VALOR,SL4->L4_FORMA,nMoedaCor})
				    Else 
				       Aadd(aPgtos,{SL4->L4_DATA,SL4->L4_VALOR,SL4->L4_FORMA,If(SL4->L4_MOEDA>0,SL4->L4_MOEDA,nMoedaCor),dDatabase})
				   	EndIf  
					Aadd(aReceb,{SL4->L4_DATA,SL4->L4_VALOR,SL4->L4_FORMA,SL4->L4_ADMINIS,SL4->L4_NUMCART,;
					SL4->L4_AGENCIA,SL4->L4_CONTA,SL4->L4_RG,SL4->L4_TELEFON,SL4->L4_TERCEIR,If(SL4->L4_MOEDA>0,SL4->L4_MOEDA,nMoedaCor),;
					SL4->L4_MESACTA,SL4->L4_ANOACTA,SL4->L4_TIPOCHQ,SL4->L4_CGC,SL4->L4_NOMECLI,SL4->L4_SERCHQ,;
					SL4->L4_COMP})
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³carregando um array com as datas, somando a quantidade de³
					//³dias negociado                                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aadd(aParcCor,dDataBase+(SL4->L4_DATA-SL1->L1_EMISSAO))
					dbSkip()
					lCarregouSL4 := .T.
				End
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ O parametro MV_LJDTORC definira o ajuste das datas do orcamento, sendo:    ³
				//³ "N" - Nunca Ajusta as datas, ou seja, sempre a que foi gravada             ³
				//³ "S" - Sempre Ajusta as datas, ou seja, Atualiza a data baseado no dia atual³
				//³ "P" - Pergunta, ou seja, fara uma pergunta se deseja ajustar as datas ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cLJDTORC$'SP'
					lLJDTOrc:=.T.
					If cLJDTORC=='P'
						lLJDTOrc:=MsgYesNo( STR0126 )  //"Deseja ajustar as datas das parcelas do orcamento, com base na data de hoje?"
					EndIf
					If lLJDTOrc
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verificando se dados da condicao de pagamento originalmente, foi alterada.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !lAlt // Somente se nao for CONDICAO NEGOCIADA "CN"
							For nI:= 1 to Len(aPgtos)
								If aPgtos[nI,1]<>aParcOrig[nI,1]
									lAlt:=.T.
									Exit
								EndIf
							Next nI
						EndIf
						For nI:= 1 to Len(aPgtos)
							aPgtos[nI,1]:=If(lAlt,aParcCor[nI],aParcAtu[nI,1])
						Next nI
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se o parametro MV_LJMOD3 estiver ativo, atualizar a     ³
						//³Variavel de memoria da data de emissao com a data atual.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lLjMod3
							M->L1_EMISSAO := dDataBase
						EndIf						
					EndIf
				Endif
				aParcTef := aClone(aPgtos)
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
				
				//Monta o Array para o calculo do troco...
				If (cPaisLoc <> "BRA") .AND. SuperGetMV("MV_LJTRLOC")
					CalcValTrc(nValorBase,aPgtos,cSimbCheq,@aMoedas,@aTroco,nOpcx)
				EndIf
			EndIf
			
			*------------ Carrega o aCols -------------
			If !Lj010Det(cCliente,cNumOrc,.F.,.F.,@oVlrItens,@nVlrItens)
				Return .F.
			EndIf
			//Carregar os impostos para Localizações
			If cPaisLoc <> "BRA"
				M->L1_FRETE   := SL1->L1_FRETE
				M->L1_SEGURO  := SL1->L1_SEGURO
				M->L1_DESPESA := SL1->L1_DESPESA
				Eval(oGet:oBrowse:bGotFocus)
                lDetalhe   := .F.        //Indica que deve recalcular os impostos variaveis			    				
			Endif
			nPosProd  := ASCAN( aHeader,{ |x| TRIM( x[2] ) == "L2_DESCRI" } )
			nLinProd  := ASCAN( aCols, { |x| !(x[Len(x)])})
			If nLinProd > 0 .AND. nPosProd > 0
				cDesc := aCols[ nLinProd ][ nPosProd ]
				oDesc:Refresh()
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Refresh dos dados do Folder1 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ! lLjMod3
				oCliente:Refresh()
				oLoja:Refresh()
				oVend:Refresh()
				oDtLim:Refresh()
				oNroPCLi:Refresh()
			Endif
			oAutorDesc:Refresh()
			oDescont:Refresh()
			oVlrLiq:Refresh()
			oVlrLiq1:Refresh()
			oVlrLiq2:Refresh()
			oVlrTot:Refresh()
			oVlrAcrs:Refresh()
			oCheck1:Refresh()
			oCheck3:Refresh()
			oTxJuros:Refresh()
			oTipoJuros:Refresh()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega o combo com a condicao de pagto padrao e calcula ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCombo := lj010IniCom(aCondicoes,@cCombo,oEntrada,;
			oNumParcelas,oFinanciado,@nValorBase,@cForma,@nEntrada,;
			@nFinanciado,@nCondicao,@cCondicao,@nNumParcelas,;
			oTxJuros,@cDescCond,lUsouFator,lInclui,nOpcx)
			
			For nI := 1 to Len(aCondicoes)
				If Upper(Substr(aCondicoes[nI],1,3)) == Upper(SubsTr(cCombo,1,3))
					cCombo := aCondicoes[nI]
					oCombo:nAt := nI
					Exit
				EndIf
			Next nI
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicializado dados do frete, caso o orçamento ja exista e nao³
			//³vai usar o botao de frete. Qdo atualizar este ponto atualizar³
			//³tb o LOJA010D - Lj010Frete()                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			M->L1_TRANSP  := SL1->L1_TRANSP
			M->L1_ENDCOB  := SL1->L1_ENDCOB
			M->L1_ENDENT  := SL1->L1_ENDENT
			M->L1_TPFRET  := SL1->L1_TPFRET
			M->L1_BAIRROC := SL1->L1_BAIRROC
			M->L1_CEPC    := SL1->L1_CEPC
			M->L1_MUNC    := SL1->L1_MUNC
			M->L1_ESTC    := SL1->L1_ESTC
			M->L1_BAIRROE := SL1->L1_BAIRROE
			M->L1_CEPE    := SL1->L1_CEPE
			M->L1_MUNE    := SL1->L1_MUNE
			M->L1_ESTE    := SL1->L1_ESTE
			M->L1_FRETE   := SL1->L1_FRETE
			M->L1_SEGURO  := SL1->L1_SEGURO
			M->L1_PLIQUI  := SL1->L1_PLIQUI
			M->L1_PBRUTO  := SL1->L1_PBRUTO
			M->L1_DESPESA := SL1->L1_DESPESA
			M->L1_ESPECIE := SL1->L1_ESPECIE
			M->L1_VOLUME  := SL1->L1_VOLUME
			M->L1_MARCA   := SL1->L1_MARCA
			M->L1_NUMERO  := SL1->L1_NUMERO
			M->L1_PLACA   := SL1->L1_PLACA
			M->L1_UFPLACA := SL1->L1_UFPLACA
			M->L1_ESPECI1 := SL1->L1_ESPECI1
			
			oCombo:Refresh()
			cComboAnt2 := cCombo
			nDecimais       :=      MsDecimais(nMoedaCor)
			Lj010SetPict()
			lLjMontP := .F.
			
			If cPaisLoc == "BRA"
				CalcIcmSol(@nLiq,cCliente,cLoja,oVlrLiq,@nValorBase,@nVlrLiq)
			EndIf

		EndIf
	EndIf
EndIf
SL1->(DBSetOrder(nOrderSL1))
If cNumOrc > cNumSx8 .AND. !lAchou
	Help( " ",1,"FORA_SEQ")
	lFirstOrc := .T.
	lInclui	 := .T.
	lAltera	 := .F.
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a Checagem da aCols ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CheckAcols( aHeader, aCols, cNumOrc )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010DtLim³ Autor ³ Vendas Clientes       ³ Data ³ 06.06.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica data de validade do orcamento                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010DtLim(dDtLim,cCliente,cNumOrc)

If dDataBase > dDtLim
	Lj010Det(cCliente,cNumOrc,.F.,.T.)
	Help(" ",1,"DTVALIDADE")
	Return .F.
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010Produ³ Autor ³ Vendas Clientes       ³ Data ³ 06.06.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia do Produto                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010Produto(cProdGrd )
Local cAlias     := Alias( )
Local lRet	     := .T.
Local nPosQuant  := aPosicoes[11][2]
Local cTes       := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !(FindFunction("SIGACUS_V") .AND. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .AND. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .AND. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

lGradProd	 := .F.

If lGrade          
	LJSB1SLK( @cProdGrd, @aCols[n][nPosQuant] )
	lGradProd := a010ProdRF(cProdGrd)
	
	If Len(aListaProd) == 0
		lAlterou := .F.
	ElseIf cProdGrd <> aListaProd[n]
		lAlterou := .T.
	Else
		lAlterou := .F.
	Endif
	// Retorno de lGradProd eh    0 = .F. --> nao Grade
	// 							  1 = .T. --> Grade
	// 							  2 = .F. --> nao esta cadastrado nem no sb1 e nem no sb4
	If lGradProd == 1
		lGradProd := .T.
	Elseif lGradProd == 2
		lGradProd :=.F.
		DBSelectArea(cAlias)
		Return .F.
	Else
		lGradProd := .F.
	Endif
		
	If lGradProd
		If ( nX := ASCAN( aHeader, { |x| TRIM( x[2] ) == "L2_GRADE" } ) ) > 0
			aCols[ n ][ nX ] := "S"
			cGrade := "S"
		EndIf
	Else
		If ( nX := ASCAN( aHeader, { |x| TRIM( x[2] ) == "L2_GRADE" } ) ) > 0
			aCols[ n ][ nX ] := "N"
			cGrade := "N"
			aCols[n][nPosQuant] := If( aCols[n][nPosQuant]==0, 1, aCols[n][nPosQuant])	
			LJSB1SLK( @M->L2_PRODUTO, @aCols[n][nPosQuant] )
			cProdRef := If(lGrade,Substr(M->L2_PRODUTO,1,nTamRef),cProdGrd)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta o AcolsGrade e o AheadGrade para este item	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			a010Mont(n,cProdRef,cGrade)
		Endif
	Endif
Else
	aCols[n][nPosQuant] := If( aCols[n][nPosQuant]==0, 1, aCols[n][nPosQuant])
	lRet := LJSB1SLK( @M->L2_PRODUTO, @aCols[n][nPosQuant] )
Endif

    // Os estados Amazonas, Minas Gerais e Sao Paulo não permitem alterar o preco do produto no momento da venda.
If cPaisLoc == "BRA"
   If LjAnalisaLeg(2)[1]
      If Lj010Preco() == 0
		 LjMsgLeg(LjAnalisaLeg(2))
         Help( " ", 1, "NOPRECO" )
         lRet:=.F.
      EndIf
   EndIf      
ElseIf lRet 
    //Caso o pais seja diferente de Brasil talvez exista tratamento especifico
    //para o TES.
	If cPaisLoc == "ARG"
		If Type("CSERIE") <> "U" .AND. Subs(cSerie,1,1) $ "A"
			cTes := RetFldProd(SB1->B1_COD,"B1_TS")
		ElseIf Type("CSERIE") <> "U" .AND. Subs(cSerie,1,1) $ "B"
			cTes := SuperGetMV("MV_TESSAI")
		EndIf
	EndIf    
		 
	If Empty(cTes)
		cTes := If(!Empty(RetFldProd(SB1->B1_COD,"B1_TS")),RetFldProd(SB1->B1_COD,"B1_TS"),SuperGetMV("MV_TESSAI"))
	EndIf
	
	SF4->(DBSetOrder(1) )
	SF4->(DbSeek(xFiliaL("SF4")+cTes))
			
	If ( nPosTes := ASCAN( aHeader, { |x| SUBSTR( x[2], 1, 6) == "L2_TES" } ) ) > 0
		aCols[ n ][ nPosTes ] := cTES
	EndIf
			
	If ( nPosCFO := ASCAN( aHeader, { |x| SUBSTR( x[2], 1, 5 ) == "L2_CF" } ) ) > 0
		aCols[ n ][ nPosCFO ] := SF4->F4_CF
	EndIf
EndIf
                                                   
//Realiza o rateio dos valores de Frete para o item
If nVlrFSD > 0 .AND. Type("oBtOk") == "O"
	LjRateioFret()
EndIf

DBSetOrder( 1 )      
DBSelectArea(cAlias) 

If Type("oBtOk") == "O"
	SetKey(15,oBtOk:bAction)
EndIf
If Type("oBtCan") == "O"
	SetKey(24,oBtCan:bAction)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj010Liq	³ Autor ³ Vendas Clientes       ³ Data ³ 06.06.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula e mostra valor liquido.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010Liq(	nVlrLiq,	nVlrTot,	nValorBase,	nLiq,;
					oVlrLiq,	oVlrLiq1,	oVlrLiq2,	nDescloj,;
					oDescPer,	nDescPer,	oVlrTotVen,	nMMM,;
					nVlrImpos,	oVlrImpos,	nVlrImpInc,	oVlrTot,;
					oDescont,	cNumOrc)

Local nAuxFor1	:= 0							// Auxilia no For do aCols
Local nAuxFor2	:= 0							// Auxilia no For do array dos impostos
Local nAuxFor3	:= 0							// Auxilia no For de cada um dos impostos
Local nPosTotal	:= aPosicoes[2][2]				// Posicao do valor total no array aPosicoes
Local nPosTes	:= aPosicoes[5][2]				// Posicao do TES no array aPosicoes
Local nValAtuIpi:= 0							// Valor atual do IPI
Local nTotItem	:= 0							// Valor total do item do aCols
Local nDecs		:= MsDecimais(nMoedaCor)		// Define as casas decimais

Local lRet		:= .T.							// Retorna se a funcao foi valida
Local lAgreg	:= .T.							// Verifica se agrega valor de acordo com o TES e o usuario fiscal

If	(cPaisLoc <> "BRA" .AND. nValorBase < 0 .AND. !lTroca)
	Help(" ","1","LJDESCINV")
	lRet := .F.
EndIf

If (cPaisLoc <> "BRA" .AND. nValorBase == 0 .AND. nDescloj > 0 .AND. !lTroca)
	Help(" ","1","LJDESCINV")
	lRet := .F.
EndIf

If lRet

	nValorBase := 0
	nValAtuIPI := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Varre todo o aCols³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nAuxFor1 := 1 To Len( aCols )
	
		If ! ( lAgreg := ( Posicione("SF4", 1, xFilial("SF4") + aCols[nAuxFor1][nPosTes], "F4_AGREG") <> "N" ) )
			lAgreg := lFiscal        //-- Se for caixa (utiliza ECF) deve somar sempre.
		EndIf
	
		If ! aCols[nAuxFor1][nUsado+1]
			If lAgreg
				nValorBase += aCols[nAuxFor1][nPosTotal]
				nValAtuIpi += Lj010Ipi(,,,nDescPer,,nAuxFor1,,,gdFieldGet("L2_VALFRE",nAuxFor1),gdFieldGet("L2_SEGURO",nAuxFor1),gdFieldGet("L2_DESPESA",nAuxFor1))
				nTotItem   += aCols[nAuxFor1][nPosTotal]
			Else
				nValorBase += 0
				nValAtuIpi += 0
				nTotItem   += 0
			Endif
		EndIf

	Next nAuxFor1
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somado ao valor liquido, o valor total - desconto + Ret ICMS + IPI³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrliq	   := nVlrTot - nDescloj + nacRetIcms + nValAtuIpi

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valor Liquido nao pode ser negativo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nVlrLiq < 0
		nVlrLiq	:= 0
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao for troca, o credito sera zerado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTroca
		nCredito	:= 0
	Endif
	
	nValorbase := nTotItem - nCredito + nValAtuIpi + nNccGerada - nNccUsada - nDescLoj + nacRetIcms - LJPCCRet() - npValISS
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existem dados do frete / seguros / despesas acess. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( M->L1_FRETE > 0 .OR. M->L1_SEGURO > 0 .OR. M->L1_DESPESA > 0 ) .AND. lVlrFSD
		nVlrliq 	+= M->L1_FRETE + M->L1_SEGURO + M->L1_DESPESA
		nValorBase	+= M->L1_FRETE + M->L1_SEGURO + M->L1_DESPESA
	Endif

	If cPaisLoc <> "BRA"
		nVlrLiq := Round( ( nTotItem + M->L1_FRETE + M->L1_SEGURO + M->L1_DESPESA ) - nDescloj,nDecs )
		nVlrTot := nTotItem + M->L1_FRETE + M->L1_SEGURO + M->L1_DESPESA             
		
		If !lDetalhe
			aImps     := RoteiroCalc(nVlrTot,nDescLoj)
			lDetalhe  := .T.
		EndIf
		
		nVlrTot		:= nVlrLiq-LJ010VlrFSD()
		nVlrliq		+= Round( nValTotIV,nDecs )     //Considerar impostos variaveis
		nVlrImpos	:=	0
		nVlrImpInc	:=	0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Varre os impostos que retornaram da funcao RoteiroCalc³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nAuxFor2	:= 1 To Len( aImps )
			aPropImp	:= TesImpInf( aCols[nAuxFor2][nPosTes] )

			For nAuxFor3:=	1 To Len(aImps[nAuxFor2][6])
				nVlrImpos	+= aImps[nAuxFor2][6][nAuxFor3][4]
				If ( aPropImp[nAuxFor3][3] == "1" )
					nVlrImpInc	+= aImps[nAuxFor2][6][nAuxFor3][4]
				Endif
			Next nAuxFor3

		Next nAuxFor2

		nVlrImpos	:=	Round( nVlrImpos ,nDecs )
		nVlrImpInc	:=	Round( nVlrImpInc,nDecs )
		nValorBase  += nVlrImpInc

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa os Refreshs³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oVlrImpos:Refresh()
		oVlrTot:Refresh()
		oGet:oBrowse:Refresh()
	EndIf

	nLiq	:= nValorBase

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa os Refreshs³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oVlrTotVen:Refresh()
	oVlrLiq:Refresh()
	oVlrLiq1:Refresh()
	oVlrLiq2:Refresh()
EndIf

If oDescPer:lModified .OR. oDescont:lModified
	nVlrDesc := nDescLoj + nVlrTxDesc
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa os Refreshs³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Valtype( oDescont ) == "O"
	oDescont:ReFresh()
EndIf
If Valtype( oDescPer ) == "O"
	oDescPer:Refresh()
EndIf
If Valtype( oVlrLiq ) == "O"
	oVlrLiq:Refresh()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ SayWinSub³ Autor ³ Vendas Clientes       ³ Data ³ 20.03.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa a Soma das Mercadorias Vendidas.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SayWinSub(	nVlrTot	, nVlrLiq	, nValorBase	, nLiq		,;
					nDescloj, nPosTotal	, oVlrTot		, oVlrLiq	,;
					oVlrLiq1, oVlrLiq2	, oDescPer		, nDescPer	,;
					oDescont, cOrigem	, nDifDesc		, oVlrTotVen,;
					nVlrIpi	, nNewOption )

Local cAlias	:= Alias()							// Salva o alias em uso

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³1 - Valor do Desconto     ³
//³2 - Porc. Desconto        ³
//³3 - Mostra tela de escolha³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cTipoCalc	:= GetNewPar( "MV_LJTPCAL", "3" )	//Tipo de Calculo de desconto

Local nAuxFor1	:= 0								//Auxilia no For do aCols
Local nAuxFor2	:= 0								//Auxilia no For do array dos impostos
Local nValAtuIpi:= 0								//Valor atual do IPI
Local nPosTes	:= aPosicoes[5][2]					//Posicao do TES no array aPosicoes
Local nPosQtd	:= aPosicoes[11][2]					//Posicao da quantidade no array aPosicoes
Local nPosPreco	:= aPosicoes[1][2]					//Posicao do preco no array aPosicoes
Local nPosPrTab := aPosicoes[13][2]					//Posicao do preco de tabela no array aPosicoes
Local nPosTab   := aPosicoes[10][2] 				//Posicao da tabela de preco no array aPosicoes
Local nVlDesT	:= 0 								//Vari vel criada para ajudar no controle do Tes
Local nTotQtd	:= 0								//Quantidade Total
Local nArredDesc:= TamSX3("L1_DESCNF")[2]			//Tamanho do L1_DESCNF
Local nDecs		:= 0								//Valida as casas decimais
Local nPos		:= 0								//Posicao de campos no aHeader
Local nAliqImp	:= 0								//Aliquota do imposto (Utilizada no pais El Salvador)
Local nPreco    := 0								//Calcula o preco (Utilizada no pais El Salvador)

Local lAjusta	:= (ExistBlock("Ajusta"))			//Valida se existe execblock "AJUSTA"
Local lArreFat	:= (SuperGetMV("MV_ARREFAT") == "S")	//Valida se existe arredondamento
Local lNoArredDesc:= nDecimais == 0					//Nao arredonda o desconto em percentual considerando as decimais da moeda
Local lCalcImp  := .T.								//Valida de calcula imposto de acordo com o A1_TIPO (Utilizada no pais El Salvador)
Local lAgreg	:= .T.								//Verifica se agrega valor de acordo com o TES e o usuario fiscal

Local aArea		:= GetArea()						//Salva a area em uso
Local aDesc		:= {'V'}							//Array com os descontos
Local aTesImpInf:= {}								//Array com o conteudo da funcao TesImpInf (Utilizada no pais El Salvador)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para a tela de escolha	   ³
//³ da utilizacao do valor do desconto ou da       ³
//³ porcentagem do desconto.					   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cFormDesc := GetNewPar("MV_LJFORMD","1")	// Valida a forma de desconto de acordo com o parametro
Local oDescWnd
Local oFntDesc
Local oFntDesc1
Local oDescSay1
Local oDescSay2
Local oDescPerg
Local nDescRad									// Valida o tipo de desconto (Botao radio)
Local lDescPerg									// Valida se o desconto foi para todos os itens do cupom
Local lLj010krm  :=ExistBlock( "LJ010KRM" )   	// Verifica se existe o PE

If lNoArredDesc
	nDecs	:= nArredDesc
Else
	nDecs	:= nDecimais
Endif


//Se a variavel lSayWin estiver False, significa que algum calculo
//esta sendo executado e que esta funcao de atualiza‡ao nao deve rodar.
If !lSayWin .AND. nNewOption <> 1
	Return .T.
Endif

If cOrigem == NIL
	cOrigem	  := ""
Endif

If oFolder:nOption == 2
	Return .T.
Endif

nValorBase := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Varre todo o aCols³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nAuxFor1 := 1 To Len(aCols)

	If ! ( lAgreg := ( Posicione("SF4", 1, xFilial("SF4") + aCols[nAuxFor1][nPosTes], "F4_AGREG") <> "N" ) )
		lAgreg := lFiscal  //-- Se for caixa (utiliza ECF) deve somar sempre.
	EndIf

	If lAgreg
		If aCols[nAuxFor1][nUsado+1]
			nValorBase -= aCols[nAuxFor1][nPosTotal]
			nTotQtd    -= aCols[nAuxFor1][nPosQtd]
			nValAtuIpi -= Lj010Ipi(,,,nDescPer,,nAuxFor1,,,gdFieldGet("L2_VALFRE",nAuxFor1),gdFieldGet("L2_SEGURO",nAuxFor1),gdFieldGet("L2_DESPESA",nAuxFor1))
		Endif
		nValorBase += aCols[nAuxFor1][nPosTotal]
		nTotQtd    += aCols[nAuxFor1][nPosQtd]
		nValAtuIpi += Lj010Ipi(,,,nDescPer,,nAuxFor1,,,gdFieldGet("L2_VALFRE",nAuxFor1),gdFieldGet("L2_SEGURO",nAuxFor1),gdFieldGet("L2_DESPESA",nAuxFor1))
    Endif

Next nAuxFor1

nVlrIpi := nValAtuIpi
nVlrTot := nValorBase

If oVlrTot <> nil
	oVlrTot :Refresh()
Endif            

nVlDesT	:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se houver ponto de entrada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAjusta .OR. nModulo == 72
	cAlias	:=Alias()

	For nAuxFor1 := 1 To Len(aCols)
		If !aCols[nAuxFor1][nUsado+1]
			DBSelectArea("SF4")
			DBSetOrder(1)
			If DbSeek( xFilial("SF4")+aCols[nAuxFor1][nPosTes] )
				If SF4->F4_Duplic == "S"
					nVlDesT := nVlDesT + aCols[nAuxFor1][nPosTotal]
					nVlDest := nVlDesT + Lj010Ipi(,,,nDescPer,,nAuxFor1,,,gdFieldGet("L2_VALFRE",nAuxFor1),gdFieldGet("L2_SEGURO",nAuxFor1),gdFieldGet("L2_DESPESA",nAuxFor1))
				Endif
			Endif
		Endif
	Next nAuxFor1

	DBSelectArea(cAlias)
Else
	nVlDesT	:= nVlrTot
Endif

If Upper(cOrigem) == "DESCVAL"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso o usuario zere o desconto, mostra tela de ³
	//³ perguntas novamente. 						   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nDescPer == 0
		__lDescPerg := .F.
	EndIf

	If nVlDesT > 0
		If lArreFat
		   nDescPer := Round( ( nDescloj * 100 ) / nVlDesT, nDecs )
		Else
		   nDescPer := NoRound( ( nDescLoj * 100 ) / nVlDesT, nDecs )
		Endif
	EndIf

	lDetalhe := .F.

ElseIf Upper(cOrigem) == "DESCPER"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso o usuario zere o desconto, mostra tela de ³
	//³ perguntas novamente. 						   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nDescPer == 0
		__lDescPerg := .F.
	EndIf

	If lArreFat
		// Não recalcular se não foi alterado - gera diferença de centavos
		If !nDescPer == Round( ( nDescloj * 100 ) / nVlDesT, nDecs )
			nDescloj := Round( nVlDesT * nDescPer / 100,nDecimais )
		EndIf
	Else
		If ! nDescPer == NoRound( ( nDescLoj * 100 ) / nVlDesT, nDecs )
			nDescloj := NoRound( nVlDesT * nDescPer / 100,nDecimais )
		EndIf
	Endif
	lDetalhe := .F.

ElseIf Upper(cOrigem) == "PAINT"
	Do Case
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valor do Desconto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cTipoCalc == "1"
			__cTpDesc := "V"

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Porcentagem de Desconto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cTipoCalc == "2"
			__cTpDesc := "P" //Porcentagem do Desconto

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tela de Escolhas do tipo de Calculo do Desconto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cTipoCalc == "3"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tela utilizada para a escolha do tipo de desconto				 ³
			//³ que vai ser utilizado no desconto do valor total.				 ³
			//³ Problema encontrado: 											 ³
			//³ Ex:																 ³
			//³ 1 - Incluir item												 ³
			//³ 2 - Alterar porcentagem do desconto								 ³
			//³ 3 - Incluir novo item											 ³
			//³ 4 - Se o valor do desconto calculado automaticamente ultrapassar ³
			//³ o valor permitido para o caixa, mas o que foi alterado foi a 	 ³
			//³ porcentagem do desconto e o parametro MV_LJFORMD for 1,			 ³
			//³ é mostrado a tela para a digitacao da senha do superior,		 ³
			//³ mesmo que a porcentagem seja inferior à permitida.				 ³
			//³ 																 ³
			//³ Com esta tela, caso a escolha seja Manter o Porcentagem do		 ³
			//³ Desconto, nao ocorre o problema relacionado acima. 				 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nDescPer > 0 .OR. nDescLoj > 0
				If !__lDescPerg
					DEFINE MSDIALOG oDescWnd TITLE STR0160 FROM 10, 15 TO 230, 400 OF GetWndDefault() PIXEL //"Desconto"
					
					DEFINE FONT oFntDesc  NAME "Ms Sans Serif" BOLD
					DEFINE FONT oFntDesc1 NAME "Arial" SIZE 15, 20 BOLD
					
					@ 15, 15 SAY oDescSay1 VAR STR0161 SIZE 200, 10 PIXEL OF oDescWnd Font oFntDesc //"Foi detectado uma alteração no desconto do Valor Total."
					@ 30, 15 SAY oDescSay2 VAR STR0162 SIZE 99, 10 PIXEL OF oDescWnd Font oFntDesc //"Você deseja:"
					@ 45, 15 RADIO oDescRad VAR nDescRad 3D SIZE 99, 10 PROMPT STR0163, ; //"Manter o Valor do Desconto?"
									 STR0164, ; //"Manter a Porcentagem do Desconto?"
									 STR0165 OF oDescWnd PIXEL //"Zerar o valor e a porcentagem?"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Manter a escolha feita na tela para todos os itens sem que 		 ³
					//³ haja a necessidade de aparecer novamente a tela.				 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					@ 80, 15 CHECKBOX oDescPerg VAR lDescPerg PROMPT STR0166 SIZE 150,10 OF oDescWnd PIXEL //"Manter a escolha acima para todos os itens deste cupom."
					
					DEFINE SBUTTON FROM 95, 70 TYPE 1 ACTION ( nOpcA := 1, oDescWnd:End() ) ENABLE PIXEL OF oDescWnd
					DEFINE SBUTTON FROM 95, 100 TYPE 2 ACTION oDescWnd:End() ENABLE PIXEL OF oDescWnd
					
					ACTIVATE DIALOG oDescWnd CENTERED
					
					If nOpcA == 1
						If lDescPerg
							__lDescPerg := .T. //Mostrar tela novamente
						Else
							__lDescPerg := .F. //Nao mostrar mais a tela
						EndIf
		
						Do Case
							Case nDescRad == 1
								__cTpDesc := "V" //Valor do Desconto
							Case nDescRad == 2
								__cTpDesc := "P" //Porcentagem do Desconto
							Case nDescRad == 3
								__lDescPerg := .F.
								nDescLoj := 0
								nDescPer := 0
						EndCase
					EndIf
				EndIf
			EndIf
	EndCase
	
	If nDescLoj > nVlDesT .OR. nVlDesT > 0
		If cFormDesc == "1"
			Do Case
				Case __cTpDesc == "V" //Checa somente o valor do desconto
					aDesc := { __cTpDesc, nDescLoj }
				Case __cTpDesc == "P" //Checa somente a porcentagem do desconto
					aDesc := { __cTpDesc, nDescPer }
			EndCase
		EndIf
		
		LJProfile( 11,, aDesc, @nDescPer, @nDescLoj )	
		
		If lArreFat
			// Não recalcular o valor se o percentual não foi alterado - gera diferença de centavos
			If nDescPer <> Round( ( nDescLoj * 100 ) / nVlDesT, nDecs )
				If __cTpDesc == "V"
					//Atualiza porcentagem do desconto
					nDescPer := Round( ( nDescLoj / nVlDesT ) * 100, nDecs )
				Else
					//Atualiza valor do desconto
					nDescloj := Round( nVlDesT * nDescPer / 100, nDecimais )
				EndIf
			EndIf
		Else
			If nDescPer <> NoRound( ( nDescLoj * 100) / nVlDesT, nDecs )
				If __cTpDesc == "V"
					//Atualiza porcentagem do desconto
					nDescPer := NoRound( ( nDescLoj / nVlDesT ) * 100, nDecs )
				Else
					//Atualiza valor do desconto
					nDescloj := Round( nVlDesT * nDescPer / 100, nDecimais )
				EndIf
			EndIf
		Endif
	EndIf
EndIf

If ( ( cConfCli == "S" ) .AND. ( ( nVlrTot > 0 ) .OR. ( cOrigem == "PAINT" ) ) )
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Verifica a Existencia do PE para validacao de mais de³
    //³ um item na aCols, do contrario busca o desconto do   ³
    //³ cliente se for o primeiro produto e estiver desenhado³
    //³ na tela.                                             ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lLj010krm 
		nDescPer := ExecBlock( "LJ010KRM", .F., .F., { nDescPer, cOrigem } )
		If ValType( nDescPer ) <> "N"
			nDescPer := 0
		EndIf
	ElseIf Len( aCols ) == 1 .AND. cOrigem == "PAINT"
		nDescPer:= SA1->A1_DESC
	Endif
	
	If lArreFat
		// Não recalcular o valor se o percentual não foi alterado - gera diferença de centavos
		If ! nDescPer == Round( ( nDescloj * 100 ) / nVlDesT, nDecs )
			nDescloj := Round( nVlDesT * nDescPer / 100,nDecimais )
		EndIf
	Else
		If ! nDescPer == NoRound( ( nDescLoj * 100 ) / nVlDesT, nDecs )
			nDescloj := NoRound( nVlDesT * nDescPer / 100,nDecimais )
		EndIf
	Endif
EndIf

// Nao permitir valor zerado no total (100% no valor)
If nDescLoj > Abs( nVlrTot-( 0.01 * nTotQtd ) )
	If nVlrTot <> 0
		nDescLoj := nVlrTot-( 0.01 * nTotQtd )
	Endif
	If lArreFat
		nDescPer := Round( ( nDescloj * 100 ) / nVlDesT, nDecs )
	Else
		nDescPer := NoRound( ( nDescLoj * 100 ) / nVlDesT, nDecs )
	Endif
EndIf

// Nao permitir 100% de desconto
If nDescPer > 99.99
	nDescPer := 99.99
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somado ao valor liquido, o valor total - desconto + Ret ICMS + IPI³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlrliq		:= nVlrTot - nDescloj + nacRetIcms + nValAtuIpi

If nVlrLiq < 0
	nVlrLiq := 0
Else
	nVlrLiq := Round(nVlrLiq,nDecimais)
Endif

If !lTroca
	nCredito	:= 0
Endif

nValorbase	:= nVlrLiq - nCredito + nNccGerada - nNccUsada
nLiq		:= nValorBase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existem dados do frete / seguros / despesas acess. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( M->L1_FRETE > 0 .OR. M->L1_SEGURO > 0 .OR. M->L1_DESPESA > 0 ) .AND. lVlrFSD
	nVlrliq		+= M->L1_FRETE + M->L1_SEGURO + M->L1_DESPESA
	nValorBase	+= M->L1_FRETE + M->L1_SEGURO + M->L1_DESPESA
	nLiq		+= M->L1_FRETE + M->L1_SEGURO + M->L1_DESPESA
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribuir total para os paises do MercoSul...		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA"                                                     
	If !lDetalhe	             
		nVlrTot := 0        

		For nAuxFor1 := 1 To Len( aCols )

			If nAuxFor1 <= Len( aImps )
				For nAuxFor2 := 1 To Len(aImps[ nAuxFor1 ][6])
					nPos := ASCAN( aHeader,{|x| TRIM(x[2]) == TRIM(aImps[ nAuxFor1 ][6][ nAuxFor2 ][6])}) //Valor	
					aCols[ nAuxFor1 ][ nPos ] := 0
					
					nPos := ASCAN( aHeader,{|x| TRIM(x[2]) == TRIM(aImps[ nAuxFor1 ][6][ nAuxFor2 ][7])}) //Base								
 					aCols[ nAuxFor1 ][ nPos ] := 0
				Next nAuxFor2
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Tirar o valor do imposto IVA para TES isento ou Cliente ³
            //³que nao seja Contribuinte ou Natural                    ³            
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "SAL"
				lCalcImp    := SA1->A1_TIPO $ "1|2"
				aTesImpInf  := TesImpInf(aCols[nAuxFor1][nPosTES])

				//TES isento de imposto ou IVA 0%
				If 	( Len( aTesImpInf ) == 0 .OR. !lCalcImp .OR. Lj010ImpZero( aTesImpInf ) ) .AND.;
					aCols[nAuxFor1][nPosPrTab] > 0 .AND. Val( aCols[nAuxFor1][nPosTab] ) > 0
                  
					SFB->(DBSetOrder(1))
					If SFB->( DbSeek( xFilial("SFB")+"IVA" ) )
						nAliqImp  := SFB->FB_ALIQ
					EndIf

					nPreco						:= aCols[nAuxFor1][nPosPrTab]
					aCols[nAuxFor1][nPosPreco]	:= Round( ( nPreco/( 1 + ( nAliqImp/100 ) ) ),nDecimais )
					aCols[nAuxFor1][nPosTotal]	:= aCols[nAuxFor1][nPosPreco] * aCols[nAuxFor1][nPosQtd]
				EndIf   
			EndIf
            
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³O total da venda é a soma de todos os itens NAO deletados³
			//³da GetDados                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !aCols[nAuxFor1][nUsado + 1]
				nVlrTot += aCols[nAuxFor1][nPosTotal]
			EndIf
		Next nAuxFor1
		
		aImps     := RoteiroCalc( nVlrTot, nDescLoj )
		lDetalhe := .T.
	EndIf
	nVlrLiq    := ( nVlrTot - nDescLoj ) + Round( nValTotIV,nDecimais ) + Round( LJ010VlrFSD(),nDecimais )
	nLiq       := nVlrLiq
EndIf

If oDescont <> nil
	oDescont:Refresh()
Endif
If oVlrTotVen <> nil
	oVlrTotVen:Refresh()
Endif
If oDescPer <> nil
	oDescPer:Refresh()
Endif
If oVlrTot <> nil .AND. cPaisLoc == "BRA"
	oVlrTot :Refresh()
Endif
If oVlrLiq <> nil
	oVlrLiq :Refresh()
Endif
If oVlrLiq1 <> nil
	oVlrLiq1:Refresh()
Endif
If oVlrLiq2 <> nil
	oVlrLiq2:Refresh()
Endif

RestArea( aArea )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj010EvaLi³ Autor ³ Vendas Clientes       ³ Data ³ 13/10/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica a validade da linha digitada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³lj010EvaLi()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LojA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±                                     
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010EvaLi( o )
Local cProduto   := ""
Local cArea      := Alias()
Local cTes       := ""
Local nQtdVen    := 0
Local cSerial    := ""
Local cLocal     := ""
Local cLoteCtl   := ""
Local cNlote     := ""
Local cLocaliza  := ""
Local lRet	     := .T.
Local nX
Local nPos
Local nVrUnit    := 0
Local nVlrItem   := 0
Local lLog4      := Subs(LJGetProfile("LOGERRO"),4,1) == "S" // Log Recuperacao
Local nPosLote   := 0
Local nPosSLote  := 0
Local nQuant
Local lLocaliza  := .F.
Local nQtdeLote  := 0

For nx := 1 To Len(aHeader)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta chave do registro. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Trim(aHeader[nx][2]) == "L2_PRODUTO"
		cProduto := aCols[n][nx]
	ElseIf Trim(aHeader[nx][2]) == "L2_QUANT"
		nQtdVen  := aCols[n][nx]
	ElseIf Trim(aHeader[nx][2]) == "L2_TES"
		cTES  := aCols[n][nx]
	ElseIf Trim(aHeader[nx][2]) == "L2_LOCAL"
		cLocal   := aCols[n][nx]
	ElseIf Trim(aHeader[nx][2]) == "L2_LOTECTL"
		nPosLote := nx
		cLoteCtl := aCols[n][nx]
	ElseIf Trim(aHeader[nx][2]) == "L2_NLOTE"
		nPosSLote := nx
		cNLote    := aCols[n][nx]
	ElseIf Trim(aHeader[nx][2]) == "L2_LOCALIZ"
		cLocaliza := aCols[n][nx]
	ElseIf Trim(aHeader[nx][2]) == "L2_NSERIE"
		cSerial  := aCols[n][nx]
	ElseIf Trim(aHeader[nx][2]) == "L2_VRUNIT"
		nVrUnit  := aCols[n][nx]
	ElseIf Trim(aHeader[nx][2]) == "L2_VLRITEM"
		nVlrItem := aCols[n][nx]
	EndIf
Next nx

Do case
	Case acols[n][(Len(aHeader)+1)]
		lRet := .T.
		
	case Empty(cProduto) .OR. Empty(nVrUnit) .OR.;
		Empty(nVlRitem) .OR. Empty(nQtdVen)
		If Len(aCols) <> 1 .AND. !Empty(cProduto)
			Help(" ",1,"A010VAZ")
		EndIf
		lRet := .F.
		
	Case !SF4->(DbSeek( xFilial("SF4") + cTes ) )
		Help( " ",1,"A010TES")
		lRet := .F.
		
	Case Localiza(cProduto)
		DBSelectArea("SBF")
		if Empty(cSerial)
			If Empty( cLocaliza )
				nQuant := 0
				FOR nPos := 1 TO Len( aCols )
					IF GDFieldGet("L2_PRODUTO", nPos ) == cProduto
						nQuant += GDFieldGet("L2_QUANT", nPos )
					ENDIF
				NEXT nPos
				IF nQuant <= SaldoSBF(cLocal,NIL,cProduto,NIL,NIL,NIL,.F.,NIL)
					lLocaliza := .F.
					lRet := .T.
				ENDIF
			Else
				DBSetOrder(1)
				lRet := DbSeek(xFilial()+cLocal+cLocaliza+cProduto+cSerial+cLotectl+If(Rastro(cProduto, 'S'),cNLote,''))
			Endif
		Else
			DBSetOrder(3)
			lRet := DbSeek(xfilial()+cSerial)
		EndIf
		If lRet
			Do Case
				Case SBF->BF_PRODUTO  <> cProduto
					// str0100 "Serial Pertence a outro Produto....Produto"
					MsgAlert(STR0100+SBF->BF_PRODUTO)
					lRet := .F.
				Case SBF->BF_LOCAL    <> cLocal
					// str0102 "Rever Localizaçäo do Produto... Local: "
					MsgAlert(STR0102+SBF->BF_LOCAL)
					lRet := .F.
				Case SBF->BF_LOCALIZ  <> clocaliza .AND. lLocaliza
					// str0103 "Rever Localizaçäo do Produto... Localizaçäo: "
					MsgAlert(STR0103+SBF->BF_LOCALIZ)
					lRet := .F.
				Case SBF->BF_NUMLOTE  <> cNLote .AND. Rastro(cProduto, 'S')
					// str0105 "Rever Localizaçäo do Produto... Sub-Lote: "
					MsgAlert(STR0105+SBF->BF_NUMLOTE)
					lRet := .F.
				Case SBF->BF_LOTECTL  <> cLotectl
					// str0104 "Rever Localizaçäo do Produto... Lote: "
					MsgAlert(STR0104+SBF->BF_LOTECTL)
					lRet := .F.
				Case SF4->F4_ESTOQUE == "S" .AND. SaldoSBF( cLocal, cLocaliza, cProduto, cSerial, cLoteCtl, If(Rastro(cProduto, 'S'),cNLote,'') ) < nQtdVen
					// str0105 "Quantidade solicitada maior que a dispon¡vel nesta localiza‡„o."
					MsgAlert(STR0118+cLocaliza)
					lRet := .F.
			EndCase
		Else
			If Empty(cSerial)
				// Produto nao encontrado nesta localizacao
				MsgAlert(STR0117)
			Else
				// str0106 "Näo existe este Numero de Serial disponivel p/ uso..."
				MsgAlert(STR0106)
			EndIf
		EndIf
		DBSetOrder(1)
		DBSelectArea(cArea)
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Legislacao El Salvador;                                 ³
//³Caso o CAMPO B1_CONTSER estiver habilitado              ³
//³valida o produto no aCols se o L2_NSERIE esta preenchido³
//³e se a quantidade eh igual a 1 (um).                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
If cPaisLoc == "SAL" .AND. SB1->(FieldPos("B1_CONTSER")) > 0
	If SB1->B1_CONTSER == "1"
		If Empty(cSerial) .AND. nQtdVen <> 1
			//"Preencher o campo Numero Serie "+"A quantidade deve ser igual a 1","Conceito de Numero de Serie habilitado"
			MsgAlert("1 . "+STR0171+Chr(10)+Chr(10)+"2 . "+STR0172,STR0170)		
			lRet := .F.
		ElseIf Empty(cSerial)
				//"Preencher o campo Numero Serie ","Conceito de Numero de Serie habilitado"
				MsgAlert(STR0171,STR0170)
				lRet := .F.
		ElseIf nQtdVen <> 1
				//"A quantidade deve ser igual a 1","Conceito de Numero de Serie habilitado"
				MsgAlert(STR0172,STR0170)
				lRet := .F.								   
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao para calculo do Saldo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Lj010Sld(	.T.,		n,			cProduto,	cLocal,;
			nQtdVen,	cLoteCtl,	cNlote,		cLocaliza,;
			cSerial,	nPosLote,	nPosSlote,	nQtdeLote)



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para validacao das linhas do aCols para uso exclusivo de Template³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistTemplate("Lj010EvaLi")
	lRet := ExecTemplate("Lj010EvaLi",.F.,.F.,{lRet})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validacao das linhas do aCols ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("Lj010EvaLi")
	lRet := ExecBlock("Lj010EvaLi",.F.,.F.,{lRet})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Log de Recuperacao  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLog4 .AND. lRet
	LjGrLogR(corcamen ,aCols,n)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj010First³ Autor ³ Vendas Clientes       ³ Data ³    07/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica a Entrada na condicao negociada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³lj010First( )                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010First(nValorBase,	nEntNeg,	nFinanciado,	nParcelas,;
					nParNeg,	oParNeg,	oEntNeg	)

Local lRet := .T.

If nEntNeg > nValorBase
	Help( " ", 0, "ENTRADA" )
	lRet := .F.
EndIf
If lRet
	If nEntNeg <> 0 .AND. nParcelas==1 .AND. nEntNeg < nValorBase .AND.;
		nEntNeg > 0
		nParcelas++
	EndIf
	If nEntNeg == nValorBase
		nParcelas := 1
	EndIf
	
	nFinanciado := nValorBase - nEntNeg
	
	If nEntNeg == nValorBase
		nParNeg := 1
		oParNeg:Refresh()
	ElseIf nEntNeg < nValorBase .AND. nParNeg < 2
		nParNeg := 2
		oParNeg:Refresh()
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj010Fisc ³ Autor ³ Vendas Clientes       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Processa a impressora fiscal.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³lj010Fisc()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010Fisc(	nDescLoj,	nDinheiro,	nValorCart,		nCheques,; 
					nValorVale,	nValorFin, 	nValorConv, 	nOutros,; 
					nTroco,		nValorDebi,	cVinculado,		cCombo,;
					nLiq,		nModoPrint )

Local nCrediLoja := nNccUsada - nNccGerada
Local lRet := .T.
Local nDescFin   := Posicione( "SE4", 1, xFilial( "SE4" ) + SubStr(cCombo,1,3), "E4_DESCFIN" )
Local nValDescFin:= 0

IF lTroca
	nCrediLoja += nCredito
Endif

if nTroco > 0
	lRet := LjEnvSup(nTroco,nDinheiro)
endif

If nDescFin > 0 
	nValDescFin := (nLiq * nDescFin) / 100
EndIf	

If cPaisLoc == "POR" .AND. !lLayAway .AND. lTroca   
   nTroco  := If(nLiq < 0,Abs(nLiq),nTroco)
EndIf

SL1->( RecLock( "SL1" , .F. ) )

if lRet
	LjMsgRun(STR0096,,{ || lRet := ExecBlock(SuperGetMV("MV_SCRFIS"),.F.,.F.,{nDescLoj,nDinheiro,nCheques,nValorCart,;
	nValorFin,nValorVale,nValorConv,nOutros,nTxJuros,nTroco,nValorDebi,nCrediLoja,cVinculado,nValDescFin,nModoPrint}),CLR_HRED})
endif

SL1->( MsUnlock() )

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010Optio³ Autor ³ Vendas Clientes       ³ Data ³ 29/10/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida a mudanca de pagina do folder                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Lj010Option                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Option(	aCondicoes	, cCombo		, oEntrada		, oNumParcelas	,;
						oFinanciado	, nValorBase	, cForma		, nEntrada		,;
						nFinanciado	, nCondicao		, cCondicao		, nNumParcelas	,;
						oTxJuros	, nNewOption	, oFolder		, nLiq			,;
						cNumOrc		, lInclui		, lAltera		, cComboAnt2	,;
						nTxDescon	, oTxDescon		, nIntervalo	, nVlrLiq		,;
						nVlrTot		, nDescLoj		, oDescont		, oVlrLiq		,;
						oVlrLiq1	, oVlrLiq2		, lUsouFator	, cTipoJuros	,;
						oTipoJuros	, oReceb		, oCheck3		, lCheck3		,;
						cAdmFator	, nVlrIpi		, oVlrTotVen	, oVlrTot		,;
						nDescPer	, oCombo		, cCliente		, cLoja			,;
						nOpcx		, aCpoEnchoice	, cVendedor		, oVlrImpos		,;
						nTipoJur	, oGroup1		, oGroup2		, oIntervalo	,;
						aMoedas		, aTroco		, lAtuParc		, lLjMod3		,;
						lGravOrc	, cCliAnt		, cLojAnt		, oDescPer		,;
						nVlrImpos	, lMudaPagina )

Local nPos
Local nCount
Local nPointer
Local nY
Local nZ
Local lRet		 	:= .T.
Local lLj010NCC  	:= ( ExistBlock( "Lj010NCC" ) )
Local lLj010Fol  	:= ( ExistBlock( "Lj010Fol" ) )
Local lLj010New  	:= ( ExistBlock( "Lj010New" ) )
Local lLj010Run  	:= ( ExistBlock( "Lj010Run" ) ) 
Local lL10HabFr 	:= ( ExistBlock( "L10HabFr" ) )
Local lBloqLomb  	:= ( ExistBlock( "BloqLomb" ) )
Local lAjusta	 	:= ( ExistBlock( "Ajusta"))
Local nPosTes	 	:= aPosicoes[5][2]
Local nValAtuIpi 	:= 0
Local nDescItens 	:= 0
Local aValores   	:= {}
Local lItens		:=.F.
Local lRetNew	 	:=.T.
Local nPosCond    	:= 0
Local oOk         	:= LoadBitmap( GetResources(), "LBOK" )
Local oNo         	:= LoadBitmap( GetResources(), "LBNO" )
Local oNcc
Local oNccWindow
Local oNccUsada
Local oFntNcc
Local nDecs       	:= MsDecimais( nMoedaCor )
Local lNCC        	:= .T.
Local nPosLojaRes 	:= aScan( aHeader, { |z| Alltrim( Upper( z[2] ) ) == "L2_LOJARES" } )
Local nPosPedFat  	:= aScan( aHeader, { |z| Alltrim( Upper( z[2] ) ) == "L2_PEDFAT" } )
Local lReservas   	:= .F.
Local lRetFrete		:= .F.
Local cOldAlias
Local nValImps    	:= 0
Local nTotAux     	:= 0
Local cTotal
Local nDifer      	:= 0
Local nVlrTotal   	:= 0
Local nDifValor   	:= 0
Local nPosLay     	:= aScan( aHeader, { |X| Alltrim( X[2] ) == "L2_NUMLAY" } )
Local nPosVlrIPI  	:= aPosicoes[7][2]
Local nValorTotal 	:= 0
Local lDifere     	:= .F.
Local aCond010Run 	:= {}
Local aTesImpInf  	:= {}
Local nSldMoedCor 	:= 0
Local lChgCond    	:= .F.
Local lUsaAcrs    	:= .F.
Local nPosValDesc 	:= 0
Local nPosVlrUnit 	:= aPosicoes[1][2]
Local nPosVlrItem 	:= aPosicoes[2][2] 
Local nPosDesc    	:= aPosicoes[4][2]
Local nPosQuant   	:= aPosicoes[11][2]
Local nPosPrcTab  	:= aPosicoes[13][2]
Local nAliqImps   	:= 0
Local nTotItem    	:= 0
Local nTotItemImps	:= 0
Local nPosValImps 	:= 0
Local cCampoImps  	:= ""
Local nArredIt    	:= 0
Local nValAntMerc 	:= 0
Local nLJValPis   	:= 0
Local nLJValCof   	:= 0
Local nLJValCSL   	:= 0
Local nPosNumLay  	:= 0
Local nDifReten   	:= 0
Local nX	 	  	:= 0
Local nCountIVA   	:= 0
Local nDiferenca  	:= 0       //Diferenca de arredondamento na conversao de moedas
Local nToler      	:= 0       //Tolerancia permitida no arredondamento para conversao de moedas
Local lIVAIsent   	:= .F.
Local lIVAReten   	:= .F.
Local lL010RecJur 	:= ExistBlock( "L010RecJur" )
Local aRecJur		:= {}

DEFAULT lGravOrc 	:= .F. //Indica que a funcao foi chamada a partir da gravacao do orcamento
DEFAULT lMudaPagina	:= .F. //Indica se mudou a pagina do Folder. Se pagina for 1 Nao chama funcao abertura de Caixa                             

lFirst2 := .F.

//Atualizar o valor de cliente
If oFolder:nOption == 1 .AND. ( nNewOption == 2 .OR. nNewOption == 3 )

	//Realiza o rateio dos valores de Frete para o item
	If nVlrFSD > 0
		LjRateioFret()
	EndIf
	
	npValISS := 0
	
	//Verifico se o sistema possui valor de PIS/COFINS
	If SA1->A1_RECPIS  == "S" .OR. ;
	   SA1->A1_RECCOFI == "S" .OR. ;
	   SA1->A1_RECCSLL == "S" .OR. ;
	   ( SA1->A1_RECISS == "1" .AND. GetNewPar("MV_DESCISS", .F.) )
	   
		MaFisIni(SA1->A1_COD, SA1->A1_LOJA, "C", "S", SA1->A1_TIPO,,, .F., "SB1")
		SB1->( DBSetOrder( 1 ))
		SF4->( DBSetOrder( 1 ))
	   
		For nX := 1 to Len( aCols )
			If ! GdDeleted(nX)
				SB1->( DbSeek( xFilial( "SB1" ) + GdFieldGet("L2_PRODUTO",nX) ))
				SF4->( DbSeek( xFilial( "SF4" ) + GdFieldGet("L2_TES    ",nX) ))
			
				MaFisAdd(SB1->B1_COD, SF4->F4_CODIGO, GdFieldGet("L2_QUANT  ",nX),GdFieldGet("L2_VRUNIT ",nX), 0, "", "",, 0, 0, 0, 0, GdFieldGet("L2_VLRITEM",nX), 0, SB1->(RecNo()))
			EndIf
		Next nX

		If SA1->A1_RECPIS  == "S" .OR. ;
		   SA1->A1_RECCOFI == "S" .OR. ;
		   SA1->A1_RECCSLL == "S"
	
			//-- Inicialização do PIS/COFINS/CSLL
			LJPCCIni(SA1->A1_COD, SA1->A1_LOJA, dDataBase)
	
	        //Declaro o Desconto no Total para retirar o calculo correto
			MaFisAlt("NF_DESCONTO",nDescLoj)
			
			nLjValPis := MaFisRet(,'NF_VALPIS')
			nLjValCof := MaFisRet(,'NF_VALCOF')
			nLjValCsl := MaFisRet(,'NF_VALCSL')
			
			If ( nLjValCof <= SuperGetMV("MV_VRETCOF")  ) // VerIfica se o Cofins pode ser retido
				nLjValCof := 0							  // Valor menor que MV_VRETCOF e' dispensado de recolhimento
			EndIf
			If ( nLjValPis <= SuperGetMV("MV_VRETPIS")  ) // VerIfica se o Pis pode ser retido
				nLjValPis := 0							  // Valor menor que MV_VRETPIS e' dispensado de recolhimento
			EndIf
			If ( nLjValCsl <= SuperGetMV("MV_VRETCSL")  ) // VerIfica se o Csll pode ser retido
				nLjValCsl := 0							  // Valor menor que MV_VRETCSL e' dispensado de recolhimento
			EndIf
			
			LJPCCAlt("SL", { nValorBase, nLJValPis, nLJValCof, nLJValCSL })
	
			nValorBase -= LJPCCRet()
	
		EndIf

		If SA1->A1_RECISS == "1" .AND. GetNewPar("MV_DESCISS", .F.)
			npValISS   := MaFisRet(, 'NF_VALISS')
			nValorBase -= npValISS
		EndIf

		MaFisEnd()

	EndIf

	If ExistBlock( "LJ020ACRS" ) .AND. FunName() == "LOJA020"
		lUsaAcrs := ExecBlock( "LJ020ACRS" , .F. , .F. )
	EndIf

	If nValorBase < 0 .AND. FunName() == "LOJA020" .AND. lUsaAcrs
		If (MsgYesNo( STR0134 , STR0044 ))//"Existe um credito adicional sendo considerado nesta troca, deseja utiliza-lo como acréscimo?"//"Atenção"
			nVlrliq  += Abs( nLiq )
			nTxJuros := Round((Abs( nLiq ) * 100) / (nCredito-Abs( nLiq )),2)
		EndIf
	EndIf

	If lLjMod3
		Lj010CondCli(@cCliAnt,@cLojAnt,@cCliente,@cLoja,@lAtuParc,@oCombo,@cCombo,@aCondicoes)
		If cCliente+cLoja <> M->L1_CLIENTE+M->L1_LOJA
			cCliente   := M->L1_CLIENTE
			cLoja      := M->L1_LOJA 
			aNccItens  := {}
			nNccGerada := 0
			nNccUsada  := 0
		EndIf
	EndIf
ElseIf nNewOption == 1

	LJPCCAlt("SL", { nValorBase, 0, 0, 0 })
	npValISS := 0

EndIf

//
// Indica se e opcao Finaliza Venda ou nao.
//
nOpcx := If( ValType( nOpcx ) = "U", 1, nOpcx )
      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se foi esclolhida a opcao "Finaliza Venda" faz o tratamento no valor do frete ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == 4 .AND. nVlrIPI == 0 .AND. cPaisLoc == "BRA"
	AEVAL( aCols, { |x| nVlrIPI += If( ATAIL(x), 0, x[ nPosVlrIPI ]  ) } )
Endif

If oFolder:nOption == 1
	cOldAlias := Alias()
	
	// Valida o Campo Codigo do Vendedor
	DBSelectArea( "SA3" )
	If !( SA3->( DbSeek( xFilial("SA3") + cVendedor ) ) )
		Help(" ",1,"LJ010VEND" )
		LJPCCAlt("SL", { nValorBase, 0, 0, 0 })
		npValISS := 0
		Return .F.
	EndIf
	
	If !Empty( cCliEntrega ) .OR. !Empty( cLojEntrega )
		If !( SA1->( DbSeek(xFilial("SA1") + cCliEntrega + cLojEntrega ) ) )
			Help(" ",1,"LJ010CLIEN" )
			LJPCCAlt("SL", { nValorBase, 0, 0, 0 })
			npValISS := 0
			Return .F.
		EndIf	
	EndIf

	// Valida o Campo Codigo do Cliente
	DBSelectArea( "SA1" )
	If !( SA1->( DbSeek(xFilial("SA1") + cCliente + cLoja ) ) )
		Help(" ",1,"LJ010CLI" )
		LJPCCAlt("SL", { nValorBase, 0, 0, 0 })
		npValISS := 0
		Return .F.
	EndIf
	DBSelectArea( cOldAlias )
EndIf

If nNewOption == 1 .AND. (oFolder:nOption ==2 .OR. oFolder:nOption == 3)
	lSayWin:=.T. //True para habilitar novamente a funcao SayWinSub
Endif

If oFolder:nOption == 1 .AND. nNewOption <> 1
	//Desabilitando Paint da Getdados - GPF Bausch Lomb
	oGet:oBrowse:lDisablePaint:=.T.
Endif

If oFolder:nOption == 1 .AND. (nNewOption == 2 .OR. nNewOption == 3)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se os itens do orcamento nao estao deletados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FOR nPos := 1 TO Len( aCols )
		If !aCols[ nPos ][ nUsado+1 ]
			lItens:=.T.
			Exit
		Endif
	NEXT nPos
	If cPaisLoc$"EUA|POR" .AND. nPosLay > 0	
		FOR nPos := 1 to Len( aCols )
			If !Empty( aCols[ nPos ][ nPosLay ] )
			    nPosNumLay  := Ascan(aNumLay,aCols[nPos][nPosLay])
			    If nPosNumLay == 0
			       Aadd(aNumLay,aCols[nPos][nPosLay])
			    EndIf   			
				lLayAway := .T.
				oGroup1:cCaption := STR0128  //"Total Pago"
				oGroup1:Refresh()
				oGroup2:cCaption := STR0128  //"Total Pago"
				oGroup2:Refresh()				
			EndIf
	  	NEXT nPos
	EndIf
	IF !lItens
		Help(" ",1,"A010VAZ")
		oGet:oBrowse:lDisablePaint:=.F.
		LJPCCAlt("SL", { nValorBase, 0, 0, 0 })
		npValISS := 0
		Return .F.
	Endif
	If lLayAway
		Lj010CbPag(@aCondicoes)
		oCombo:SetItems(aCondicoes)
		oCombo:Refresh()
    EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe reservas em outras lojas.                                  ³
	//³Se afirmativo checa se é para gerar os arquivos para o faturamento (SC5/SC6) e³
	//³retirá-los do aCols                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos := 1
	While ( nPos <= Len( aCols ) ) .AND. !lReservas
		If !Empty(aCols[ nPos ][ nPosLojaRes ] ) .AND. Empty( aCols[ nPos ][ nPosPedFat ] )
			lReservas := .T.
		Endif
		nPos++
	End
	If lReservas
		LjChkReserva()
	Endif
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para permitir a exibicao do botao frete a um³
//³usuario fiscal                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lL10HabFr
	lRetFrete := ExecBlock( "L10HabFr", .F. , .F. )
	If ValType( lRetFrete ) <> "L"
		lRetFrete := .F.
	Endif
Endif 

If (nNewOption == 2)
	if Empty(cCliente)
		Help(" ",1,"A010VAZ")
		oGet:oBrowse:lDisablePaint:=.F.
		LJPCCAlt("SL", { nValorBase, 0, 0, 0 })
		npValISS := 0
		Return (.F.)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A ocorrencia 29 (ACS), verifica se o usu rio poder  ou n„o  ³
	//³ efetuar o Como Pagar.										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alteracoes especificas para o estado do Amazonas, por imposicao do SEFAZ-AM. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lGravOrc .AND. (!ChkPsw( 29 ) .OR. (LjAnalisaLeg(4)[1] .AND. SuperGetMV("MV_LJPGCC")))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura a integridade da janela ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oGet:oBrowse:lDisablePaint:=.F.
		LJPCCAlt("SL", { nValorBase, 0, 0, 0 })
		npValISS := 0
		Return .F.
	EndIf
	
	If Substr(SuperGetMV("MV_USACRED"),2,1) == "S"
		
		If Len(aNccItens) = 0
			
			If lLj010NCC
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Permite adcionar as NCC's conforme uma regra de negocio do ³
				//³cliente.                                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ExecBlock("LJ010NCC", .F., .F.)
			Else
				
				SE1->(DBSetOrder(8))
				SE1->(DbSeek(xFilial("SE1")+cCliente+cLoja+"A",.T.))
				While ! SE1->(Eof()) .AND. SE1->E1_CLIENTE == cCliente .AND.;
					SE1->E1_LOJA == cLoja .AND. SE1->E1_STATUS == "A"
					If SE1->E1_TIPO $ MV_CRNEG
						If cPaisLoc == "BRA"
							aAdd(aNccItens, {.F., SE1->E1_SALDO, SE1->E1_NUM, SE1->E1_EMISSAO, SE1->(Recno())})
						Else
							nSldMoedCor := Round(xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,nMoedaCor,dDataBase,nDecimais+1,SE1->E1_TXMOEDA,nTaxaMoeda),nDecimais) 
							aAdd(aNccItens, {.F.,nSldMoedCor,SE1->E1_NUM,SE1->E1_EMISSAO,SE1->(Recno()),SE1->E1_SALDO,SuperGetMV("MV_MOEDA"+Str(SE1->E1_MOEDA,1))})
						EndIf
					EndIf
					SE1->(DbSkip())
				End
				If Len(aNccItens) > 0
					aNccItens := aSort(aNccItens,,,{|x,y| x[4]<y[4]})
				EndIf
				SE1->(DBSetOrder(1))
				
			EndIf
			
		EndIf
		
		If Len(aNccItens) > 0 .AND. !lAtuOrc
			If !lAtuNcc //Var atualizada somente quando eh gravado um Orcamento
			
				DEFINE MSDIALOG oNccWindow TITLE STR0110 FROM 10,15 TO 270,280 OF GetWndDefault() PIXEL
				
				DEFINE FONT oFntNcc  NAME "Ms Sans Serif" BOLD
				DEFINE FONT oFntNcc1 NAME "Arial" SIZE 15,20 BOLD
				
				@ 90,02 TO 111,132 LABEL STR0111 OF oNccWindow PIXEL
				@ 98,30 SAY oNccUsada VAR nNccUsada SIZE 99,10 PIXEL OF oNccWindow Picture PesqPict("SE1","E1_SALDO") RIGHT COLOR CLR_HRED Font oFntNcc1
				
				If cPaisLoc == "BRA"				
					@ 2,2 LISTBOX oNcc FIELDS HEADER "",STR0112,STR0113,STR0114;
					FIELDSIZES 14, 40, 30, 30 SIZE 130,83  PIXEL OF oNccWindow
				Else 
					@ 2,2 LISTBOX oNcc FIELDS HEADER "",STR0131,STR0113,STR0114,;
					STR0132,STR0133;
					FIELDSIZES 14, 40, 30, 30 SIZE 130,83  PIXEL OF oNccWindow				
				EndIf
				
				oNcc:SetArray(aNccItens)
				
				oNcc:bLDblClick := { || ( aNccItens[ oNcc:nAt ][1] := ! aNccItens[ oNcc:nAt ][1]),;
				nNccUsada := 0 ,;
				AEVAL(aNccItens,{ |x| nNccUsada += if( x[1], x[2], 0 ) } ) ,;
				oNccUsada:Refresh() }
				
				If cPaisLoc == "BRA"
					oNcc:bLine := { || {If(aNccItens[ oNcc:nAt ][1],oOk,oNo),;
					Transform(aNccItens[ oNcc:nAt ][2],PesqPict("SE1","E1_SALDO")),;
					aNccItens[ oNcc:nAt ][3],;
					aNccItens[ oNcc:nAt ][4]}}
				Else
					oNcc:bLine := { || {If(aNccItens[oNcc:nAt,1],oOk,oNo),;
					Transform(aNccItens[ oNcc:nAt ][2],PesqPict("SE1","E1_SALDO")),;
					aNccItens[ oNcc:nAt ][3],;
					aNccItens[ oNcc:nAt ][4],;
					Transform(aNccItens[ oNcc:nAt ][6],PesqPict("SE1","E1_SALDO")),;
					aNccItens[ oNcc:nAt ][7]}}
				EndIf
				
				DEFINE SBUTTON FROM 115,105 TYPE 1 ACTION oNccWindow:End()ENABLE PIXEL OF oNccWindow
				
				ACTIVATE DIALOG oNccWindow CENTERED 
			EndIf
			
		Else
			nNccUsada := 0
		Endif
	ENDIF
	
	IF lLj010Run .AND. !lAtuOrc
		aCond010Run := ExecBlock("Lj010Run",.F.,.F.)
		Aadd(aCond010Run,"CN " + " - " + STR0026)
		                                                     
		lDifere := .F.
		If Len(aCond010Run) <> Len(aCondicoes)
			lDifere := .T.
		Else
			FOR nPos := 1 TO Len( aCond010Run )
				If aCond010Run[ nPos ] <> aCondicoes[ nPos ]
					lDifere := .T.
				Endif
			NEXT nPos
		Endif
		
		If lDifere		
			aCondicoes := aClone(aCond010Run)
			cCombo:=aCondicoes[1]
			oCombo:SetItems(aCondicoes)
			oCombo:nAt:=1
                        
			If !lAltera
				If cConfCli == "S" .AND. !Empty(SA1->A1_COND)
					If ( nPosCond := aScan( aCondicoes, SA1->A1_COND ) ) > 0
						oCombo:nAt := nPosCond
					EndIf
				Endif	
			Else
				If ( nPosCond := Ascan(aCondicoes,SL1->L1_CONDPG) ) > 0
					oCombo:nAt:= nPosCond
				EndIf	
			EndIf
			
			oCombo:Refresh()  
			Eval(bComboChg)
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Habilita o botao dos dados do frete   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lFiscal .OR. lRetFrete
		oBtnTransp:Enable()
		SetKey(20,oBtnTransp:bAction)
		oBtnTransp:Refresh()
	Endif
Else

	If (nNewOption == 3)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Desabilita o botao dos dados do frete ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Set Key 20 to
		oBtnTransp:Disable()	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ A ocorrencia 30 (ACS), verifica se o usu rio poder  ou n„o  ³
		//³ efetuar um Recebimento.										³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alteracoes especificas para o estado do Amazonas, por imposicao do SEFAZ-AM. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !ChkPsw( 30 ) .OR. (LjAnalisaLeg(4)[1] .AND. SuperGetMV("MV_LJPGCC"))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Restaura a integridade da janela ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oGet:oBrowse:lDisablePaint:=.F.
			LJPCCAlt("SL", { nValorBase, 0, 0, 0 })
			npValISS := 0
			Return .F.
		EndIf
	Else
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Habilita o botao dos dados do frete   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lFiscal .OR. lRetFrete
			oBtnTransp:Enable()
			SetKey(20,oBtnTransp:bAction)
			oBtnTransp:Refresh()
		Endif
	
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz a validação dos campos da enchoice do cabecalho do orcamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMV("MV_LJMOD3")
	If !Obrigatorio(aGets,aTela)
		lFirst2 := .T.
		LJPCCAlt("SL", { nValorBase, 0, 0, 0 })
		npValISS := 0
		Return .F.
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Caixa esta Aberto. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMudaPagina
    If !ljCxAberto()
   		oGet:oBrowse:lDisablePaint:=.F.
		lFirst2 := .T.
		LJPCCAlt("SL", { nValorBase, 0, 0, 0 })
		npValISS := 0
		Return .F.
    Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLj010Fol
	ExecBlock("LJ010FOL",.F.,.F.,{nDescPer,nNewOption,oFolder})
EndIf

If lLj010New
	lRetNew:=ExecBlock("LJ010NEW",.F.,.F.,{nDescPer,nNewOption,oFolder,aPgtos,nDescLoj,cCondicao,nLiq})
EndIf

If lBloqLomb
	lRet:=ExecBlock("BloqLomb",.F.,.F.,{cNumOrc, nDescLoj, nDescPer})
	If !lRet
		oGet:oBrowse:lDisablePaint:=.F.
		LJPCCAlt("SL", { nValorBase, 0, 0, 0 })
		npValISS := 0
		Return lRet
	EndIf
Endif

If lAjusta .AND. (nNewOption == 2 .OR. nNewOption == 3) .AND. (lRet .AND. lRetNew)
	lSayWin    := .F. //False para que a funcao SayWinSub nao seja executada
	aValores   :={nValorBase,nValAtuIpi}
	aValores   :=ExecBlock("AJusta",.F.,.F.)
	nValorBase := aValores[1]
	nValAtuIpi := aValores[2]
	nVlrIpi    := nValAtuIpi
	nVlrTot    := nValorBase
	nVlrliq    := nVlrTot-nDescloj + nacRetIcms - nVlrTxDesc
	nVlrliq    := If(nVlrLiq<0 .AND. cPaisLoc == "BRA",0,Round(nVlrLiq,nDecs))
	nValorbase := nVlrLiq - If(lTroca,nCredito,0) + nNccGerada - nNccUsada

	LJPCCAlt("SL", { nValorBase })
	
	nValorBase -= ( LJPCCRet() + npValISS )
	nLiq       := nValorBase
	
	oVlrtot:Refresh()
	oVlrtotven:Refresh()
	oVlrLiq:Refresh()
	oVlrLiq1:Refresh()
	oVlrLiq2:Refresh()
	
	lRet:=.T.
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alteracoes especificas para o estado do Amazonas, por imposicao do SEFAZ-AM. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(LjAnalisaLeg(4)[1] .AND. SuperGetMV("MV_LJPGCC"))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Compara os valores digitados nas parcelas com o valor total³
		//³ do or‡amento, caso hajam divergˆncias retorna FALSE. 		³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (oFolder:nOption == 1 .OR. oFolder:nOption == 2) .AND. nNewOption == 3 .AND. (lRet .AND. lRetNew)
 
			lRet := lj010ComVl(( nValorBase + If( lTroca, nCredito, 0 ) ), nVlrAcrs, nVlrTxDesc)
 
			If lRet .AND. cPaisLoc == "PAR"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Faz a avaliacao de credito. Se for Finaliza Venda verifica ³
				//³ se houve bloqueio de credito, senao avalia o credito.      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nOpcx == 4
					lRet := (Empty(SL1->L1_BLCRED)) .OR. SL1->L1_BLCRED == "20"
				EndIf
				If lRet .AND. SL1->L1_BLCRED <> "20"  //20 - credito ja liberado pela rotina LOJA460
					lRet := Lj010AvCred()
				EndIf
				If !lRet                       
				    //"Bloqueio de Credito. Sera necessario executar a Liberacao antes de Finalizar Venda"
					MsgStop(STR0127)
				EndIf
			EndIf
		EndIf
	EndIf
Endif

If (lRet .AND. lRetNew)
    If (cPaisLoc <> "BRA") .AND. SuperGetMV("MV_LJTRLOC") .AND. nNewOption == 3
      CalcValTrc(nValorBase,aPgtos,cSimbCheq,@aMoedas,@aTroco,nOpcx)
    EndIf

	If (ReadVar() == "NDESCLOJ") .AND. (oFolder:nOption == 1)
		oGet:oBrowse:SetFocus()
		lRet := Eval(oDescont:bValid)
		If ValType(lRet) <> "L"
			lRet := .T.
		EndIf		

		nVlrliq	  := nVlrTot-nDescloj + nacRetIcms
	ElseIf (ReadVar() == "NDESCPER") .AND. (oFolder:nOption == 1)
		oGet:oBrowse:SetFocus()
		lRet := Eval(oDescPer:bValid)
		If ValType(lRet) <> "L"
			lRet := .T.
		EndIf		

		nVlrliq	  := nVlrTot-nDescloj + nacRetIcms
	EndIf
	
	nVlrliq	   := If(cPaisLoc == "BRA",If(nVlrLiq < 0,0,Round(nVlrLiq,nDecs)),Round(nVlrLiq,nDecs))
	nValorbase := nVlrLiq - If(lTroca,nCredito,0) + If(cPaisLoc == "BRA",nNccGerada,If(nVlrLiq > 0 .AND. !lTroca,nNccGerada,0)) - nNccUsada
	
	//-- Inicialização do PIS/COFINS/CSLL
	LJPCCIni(SA1->A1_COD, SA1->A1_LOJA, dDataBase)
	LJPCCAlt("SL", { nValorBase })
	
	nValorBase -= ( LJPCCRet() + npValISS )
	nLiq       := nValorBase
	
	If cPaisLoc == "BRA"
		CalcIcmSol(@nLiq,cCliente,cLoja,oVlrLiq,@nValorBase,@nVlrLiq)
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para alteracao dos Juros³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lL010RecJur
		aRecJur := ExecBlock( "L010RecJur", .F. , .F. )
	Endif
	
	If ValType( aRecJur ) == "A" .AND. Len( aRecJur ) > 0 .AND. ( aRecJur[1] > 0 .OR. aRecJur[2] > 0 )
		SetARecJur( aRecJur )
	Endif

	oVlrTotVen:Refresh()
	oVlrLiq:Refresh()
	oVlrLiq1:Refresh()
	oVlrLiq2:Refresh()
	
	If nNewOption == 3 .AND. lFirst2 .AND. nOpcx # 4
		Help(" ",1,"LJ010NOSEL")
		lRet := .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se passou pelo folder Como Pagar para depois ³
	//³ ir para o Folder Recebimento						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If ! lFirst2 .AND. nNewOption <> 1 //ja passou no como pagar antes
		nY := 0
		FOR nPos := 1 TO Len( aPgtos )
			If cPaisLoc == "BRA"
				nY += aPgtos[ nPos ][2]
			Else
				nY += xMoeda( aPgtos[ nPos ][2], aPgtos[ nPos ][4], nMoedaCor, dDatabase,,, nTaxaMoeda )
			Endif
		Next nPos
		If nNewOption == 3
			//Permitir o tratamento de valores negativos para os casos de adiantamento(Localizacoes)
			If (If(cPaisLoc == "BRA",.T.,nLiq >= 0))
				nValorBase -= nNccGerada
				nLiq -= nNccGerada
				nNccGerada := 0
				lNCC       := .T.
			Else
				nValorBase := nLiq
				nNccGerada := Abs(nLiq)
				lNCC       := .F.
				If !lAtuNcc
					//"Irá restar um crédito no valor de: "
					MsgInfo(STR0109+SuperGetMV("MV_SIMB1")+" "+Alltrim(Transform(nNccGerada,PesqPict("SE1","E1_VALOR"))))
				EndIf
			EndIf
			If nLiq < 0 .AND. lNCC
				If Substr(SuperGetMV("MV_USACRED"),1,1) == "S"
					nNccGerada := Abs(nLiq)
					nLiq += nNccGerada
					nValorBase := Round(nLiq,nDecs)
					oVlrTotVen:Refresh()
					oVlrLiq:Refresh()
					oVlrLiq1:Refresh()
					oVlrLiq2:Refresh()
					If !lAtuNcc
						//"Irá restar um crédito no valor de: "
						MsgInfo(STR0109+SuperGetMV("MV_SIMB1")+" "+Alltrim(Transform(nNccGerada,PesqPict("SE1","E1_VALOR"))))
					EndIf
				Else
					Help(" ",1,"VALORNEGATIV")
					lRet := .F.
				Endif
			EndIf
		EndIf
		If( If( cPaisLoc == "BRA", .T., lValTot ) )
			If cPaisLoc == "BRA"
				cTotal  :=  Str(nLiq+nVlrAcrs-nVlrTxDesc,15,nDecimais)
			Else
				cTotal := If(nVlrAcrs>0,Str((nLiq-aDadosJur[6])+aDadosJur[4]+aDadosJur[1],15,nDecimais),Str(nLiq,15,nDecimais))
				nVlrTotal := Val(cTotal)
				nDifer    := (1/(10**nDecimais))   //Intervalo de tolerancia para diferencas de arredondamento na conversao de valores
				nDifValor := Abs( Round( nVlrTotal, nDecimais) - nY)
				If nDifValor <= nDifer .AND. nDifValor > 0
					nY := nVlrTotal              //Ha uma diferenca de arredondamento
				EndIf
			EndIf
			If cTotal <> STR( nY, 15, nDecimais ) .OR. lChgCond
				If nNewOption == 3 .AND. oFolder:nOption <> 2 .AND. nOpcx <> 4
					Help(" ",1,"SOMAPARCOK")
					oGet:oBrowse:lDisablePaint:=.F.
					LJPCCAlt("SL", { nValorBase, 0, 0, 0 })
					npValISS := 0
					Return .F.
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Recalcula a condicao de pagto ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cCondicao <> "CN"
					cTipoJuros := STR0003  //"Simples"
				EndIf
				oTipoJuros:Refresh()
				lUsouFator := .F.
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se e necessario recalcular as parcelas ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nValorTotal := 0
				AEVAL( aPgtos, { |x| nValorTotal += x[2] } )
				If ( nValorTotal <> nLiq + nVlrAcrs - nVlrTxDesc ) .OR. lChgCond
					Lj010MontP(aCondicoes,@cCombo,oEntrada,oNumParcelas,;
					oFinanciado,@nValorBase,@cForma,@nEntrada,@nFinanciado,@nCondicao,;
					@cCondicao,@nNumParcelas,oTxJuros,cComboAnt2,@nTxDescon,oTxDescon,nIntervalo,;
					nDescLoj,.F.,@nLiq,nDescPer,oVlrImpos,@nTipoJur,@cTipoJuros,oTipoJuros,oCombo,;
					oIntervalo,oVlrTotVen)
					
					lAtuParc := .F.
                Endif

				if ! nLiq == 0
					lFirst2 := .T.
				Endif
			EndIf
		Else
			If (nNewOption == 2)
				If SubStr(cComboAnt2,1,2) == "CN"
					nValImps:= Lj010RecVB(@nValorBase,nTxJuros,nTxDescon,nDescLoj,;
					@nLiq,nDescPer,nTipoJur,nNumParcelas,nEntrada)
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica se e necessario recalcular as parcelas ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nValorTotal := 0
					AEVAL( aPgtos, { |x| nValorTotal += Round(xMoeda(x[2],x[4],nMoedaCor,dDatabase,nDecimais+1),nDecimais)})
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tratar diferencas de arredondamento quando as moedas das parcelas sao diferentes da moeda da venda³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    nDiferenca  := nValorTotal - (nLiq + nVlrAcrs - nVlrTxDesc)
					nToler      := 1/(10**nDecimais)
					If nDiferenca <> 0 .AND. ABS(nDiferenca) <= nToler
					   nValorTotal := nLiq + nVlrAcrs - nVlrTxDesc
					EndIf								
					If nValorTotal <> nLiq + nVlrAcrs - nVlrTxDesc
						Lj010MontP(aCondicoes,@cCombo,oEntrada,oNumParcelas,;
						oFinanciado,@nValorBase,@cForma,@nEntrada,@nFinanciado,@nCondicao,;
						@cCondicao,@nNumParcelas,oTxJuros,cComboAnt2,@nTxDescon,oTxDescon,;
						nIntervalo,nDescLoj,.F.,@nLiq,nDescPer,oVlrImpos,@nTipoJur,@cTipoJuros,oTipoJuros,oCombo,;
						oIntervalo,oVlrTotVen)
	
						lAtuParc := .F.						

					Endif
				EndIf
				//Como o calculo do acrescimo e especifico quando o pais e diferente
				//de Brasil e necessario atualizar os totais em tela.
				If (nOpcx == 4) .AND. (nTxJuros > 0)
					oVlrLiq1:Refresh()
					oVlrLiq2:Refresh()
					oVlrImpos:Refresh()
					oVlrAcrs:Refresh()
					oVlrDesc:Refresh()
					If nTipoJur == 2
						cTipoJuros := STR0092  //"Serie Pgtos"
						oTipoJuros:Refresh()
					EndIf
				EndIf
				FOR nPos := 1 TO Len( aCols )
					If ( nPosValDesc := ASCAN( aHeader, { |x| TRIM( x[2] ) == "L2_VALDESC" } ) ) > 0
				        //Para documento Credito Fiscal, o desconto deve ser aplicado sobre o valor
				        //do produto sem imposto - Loc. El Salvador						
						If cPaisLoc == "SAL" .AND. lCredFisc .AND. aCols[nPos][nPosValDesc] > 0
						   If nAliqImps == 0
                              SFB->(DBSetOrder(1))
                              If SFB->(DbSeek(xFilial("SFB")+"IVA"))
                                nAliqImps  := SFB->FB_ALIQ
                              EndIf    		
                           EndIf   
						   nTotItem  := Round((aCols[nPos][nPosPrcTab]/(1+(nAliqImps/100))),nDecimais)*aCols[nPos][nPosQuant]			
						   aCols[nPos][nPosValDesc]  := Round(nTotItem*(aCols[nPos][nPosDesc]/100),nDecimais)
						   aTesImpInf    := TesImpInf(aCols[nPos][nPosTES])
						   nTotItemImps  := 0
						   For nZ := 1 to Len(aTesImpInf)
						      cCampoImps  := "L2_"+Substr(aTesImpInf[nZ][2],4,7)
						      If ( nPosValImps := ASCAN( aHeader, { |x| TRIM( x[2] ) == cCampoImps } ) ) > 0						      
						         nTotItemImps  += aCols[nPos][nPosValImps]
						      EndIf   
						   Next nZ
						   nValAntMerc := aCols[nPos][nPosVlrItem]
						   aCols[nPos][nPosVlrItem]  := nTotItem - aCols[nPos][nPosValDesc] + nTotItemImps  						                    
						   If Abs(nArredIt := aCols[nPos][nPosVlrItem] - nValAntMerc) <= 1/(10^nDecimais)
						   		aCols[nPos][nPosVlrItem] += (nArredIt * -1)
						   EndIf						   
						   aCols[nPos][nPosVlrUnit]  := Round(aCols[nPos][nPosVlrItem]/aCols[nPos][nPosQuant],nDecimais)						   
				        EndIf					
						nDescItens += aCols[ nPos ][ nPosValDesc ]
					EndIf
				Next nPos
				nVlrDesc := nDescLoj+nDescItens+aDadosJur[9]  //Atualiza o valor do desconto caso este seja alterado
				oVlrDesc:Refresh()
			ElseIf (nNewOption == 3)
				nValImps:= Lj010RecVB(@nValorBase,nTxJuros,nTxDescon,nDescLoj,;
				@nLiq,nDescPer,nTipoJur,nNumParcelas,nEntrada)
				
				nTotAux   := If(nVlrAcrs>0.OR.aDadosJur[9]>0,(nLiq-aDadosJur[6])+aDadosJur[4]+aDadosJur[1]-aDadosJur[9],nLiq)
				nDifer    := (1/(10**nDecimais))   //Intervalo de tolerancia para diferencas de arredondamento na conversao de valores
				nDifValor := Abs( Round( nTotAux, nDecimais) - Round(nY,nDecimais))
				If nDifValor <= nDifer .AND. nDifValor > 0
					nY := nTotAux              //Ha uma diferenca de arredondamento
				EndIf
				
				IF Str(nTotAux,15,nDecimais) > Str(nY,15,nDecimais)   // Nao permite valor das parcelas menor que o valor da fatura ( Localizacoes )
					Help(" ",1,"SOMAPARCOK")
					oGet:oBrowse:lDisablePaint:=.F.
					LJPCCAlt("SL", { nValorBase, 0, 0, 0 })
					npValISS := 0
					Return .F.
				EndIf
				If Len(aReceb) <> Len(aPgtos)
					aReceb := {}
					FOR nPos := 1 TO Len( aPgtos )
						AaDD(aReceb,{ aPgtos[ nPos ][1], aPgtos[ nPos ][2], aPgtos[ nPos ][3], CriaVar("L4_ADMINIS"),;
						CriaVar("L4_NUMCART"), CriaVar("L4_AGENCIA"), CriaVar("L4_CONTA"), CriaVar("L4_RG"),;
						CriaVar("L4_TELEFON"), .F., aPgtos[ nPos ][4], CriaVar("L4_MESACTA"), CriaVar("L4_ANOACTA"),;
						CriaVar("L4_TIPOCHQ"), CriaVar("L4_CGC"), CriaVar("L4_NOMECLI"), CriaVar("L4_SERCHQ"),;
						CriaVar("L4_COMP")})
					NEXT nPos
				Else
					FOR nPos := 1 TO Len( aPgtos )
						FOR nCount := 1 to 3
							If aPgtos[ nPos ][ nCount ] <> aReceb[ nPos ][ nCount ]
								LimpaArray( nPos )
								FOR nPointer := 1 TO 3
									aReceb[ nPos ][ nPointer ] := aPgtos[ nPos ][ nPointer ]
								NEXT nPointer
							EndIf
						NEXT nCount
						aReceb[ nPos ][11] := aPgtos[ nPos ][4]  //Preenche com a moeda da parcela
					Next nPos
				EndIf
				//Como o calculo do acrescimo e especifico quando o pais e diferente
				//de Brasil e necessario atualizar os totais em tela.
				If (nOpcx == 4) .AND. (nTxJuros > 0)
					nVlrAcrs := aDadosJur[1]
					oVlrLiq1:Refresh()
					oVlrLiq2:Refresh()
					oVlrImpos:Refresh()
					oVlrAcrs:Refresh()
					oVlrDesc:Refresh()
					If nTipoJur == 2
						cTipoJuros := STR0092  //"Serie Pgtos"
						oTipoJuros:Refresh()
					EndIf
				EndIf
				FOR nPos := 1 TO Len( aCols )
					If ( nPosValDesc := ASCAN( aHeader, { |x| TRIM( x[2] ) == "L2_VALDESC" } ) ) > 0
						nDescItens += aCols[ nPos ][ nPosValDesc ]
					EndIf
				NEXT nPos
				nVlrDesc := nDescLoj+nDescItens  //Atualiza o valor do desconto caso este seja alterado
				oVlrDesc:Refresh()
			EndIf
		EndIf
		oVlrLiq2:Refresh()
	EndIf
EndIf

If (lRet .AND. lRetNew)
	If oFolder:nOption == 2
		If Len(aPgtos) > 1
			FOR nPos := 2 TO Len( aPgtos )
				If IsMoney( aPgtos[ nPos ][3]) .AND. If( cPaisLoc == "BRA",.T.,aPgtos[ nPos ][1] > dDatabase)
					Help(" ",1,"NOPRAZO")
					lRet := .F.
					Exit
				EndIf
			Next nPos
		EndIf
	EndIf
	
	If oFolder:nOption == 1 .AND. (lRet .AND. lRetNew)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a Func„o tudoOk da GetDados, para Verificar os Dados. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRet := oGet:TudoOk()
	EndIf
	
	If ((lRet .AND. lRetNew) .AND. Empty(aPgtos) .AND. lInclui) .OR. ((lRet .AND. lRetNew) .AND. lFirst2 .AND. lInclui)
		lUsouFator := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se e necessario recalcular as parcelas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValorTotal := 0
		AEVAL( aPgtos, { |x| nValorTotal += x[2] })
		If nValorTotal <> nLiq + nVlrAcrs - nVlrTxDesc
			lRet := Lj010MontP(aCondicoes,@cCombo,oEntrada,;
			oNumParcelas,oFinanciado,@nValorBase,@cForma,@nEntrada,@nFinanciado,;
			@nCondicao,@cCondicao,@nNumParcelas,oTxJuros,cComboAnt2,;
			@nTxDescon,oTxDescon,nIntervalo,nDescLoj,.F.,@nLiq,nDescPer,oVlrImpos,@nTipoJur,@cTipoJuros,oTipoJuros,oCombo,;
			oIntervalo,oVlrTotVen)

			lAtuParc := .F.			
			
		Endif
	EndIf
	
EndIf

If nNewOption == 1 .AND. (oFolder:nOption ==2 .OR. oFolder:nOption == 3)
	nNccGerada := 0
Endif

if nNewOption == 3
	cForma := aPgtos[1][3]
	FOR nPos := 1 TO Len( aPgtos )
		if aPgtos[ nPos ][3] $ "CC;CD"
			cForma := aPgtos[ nPos ][3]
			Exit
		Endif
	NEXT nPos
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o tipo do cliente esta em conformidade ³
	//³com as formas pagamento Isencao ou Retencao de IVA ³	
	//³Loc. Guatemala                                     ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "GUA"             
       SA1->( DBSetOrder(1) )
       SA1->( DbSeek( xFilial( "SA1" ) + cCliente + cLoja ) )                	
       nCountIVA   := 0
	   For nPos := 1 to Len( aPgtos )	   
 	      If AllTrim(aPgtos[nPos][3]) == "IS"
             lRet  := (SA1->A1_TIPO == "2")  //Tipo: Isento de IVA
             lIVAIsent := .T.
	         If !lRet
	            //"Atenção"###"O tipo do cliente nao permite o recebimento de Certificados de Isencao de IVA."        
	            //"O cliente deve ser do tipo 2(Isencao de IVA)."
	            Aviso(STR0044,STR0146+chr(13)+STR0147,{STR0145})  
	            Exit   
	         EndIf             
	         nCountIVA++
 	      ElseIf AllTrim(aPgtos[nPos][3]) == "RI"
             lRet  := (SA1->A1_TIPO == "3")  //Tipo: Ag. de Retencao de IVA
             lIVAReten := .T.             
	         If !lRet
	            //"Atenção"###"O tipo do cliente nao permite o recebimento de Certificados de Retencao de IVA."        
	            //"O cliente deve ser do tipo 3(Agente dde Retencao de IVA)."
	            Aviso(STR0044,STR0148+chr(13)+STR0149,{STR0145})  
	            Exit   
	         EndIf                          
	         nCountIVA++
	      EndIf
	      If nCountIVA > 1
	         //"Atencao"
	         //"Nao e permitido ter 2 ou mais parcelas de Retencao ou Isencao de IVA."                
	         //"Corrija a forma de pagamento de uma das parcelas."             
	         //"Ok"   
	         Aviso(STR0044,STR0153+chr(13)+STR0154,{STR0145})  
	         lRet  := .F.
	         Exit   
	      EndIf
	   Next nPos   
	   If lRet .AND. (lIVAIsent .OR. lIVAReten)
	      For nPos := 1 to Len(aPgtos)
 	         If AllTrim(aPgtos[nPos][3]) $ "IS|RI"	      
                nDifReten := aPgtos[nPos][2] - nVlrImpos
	            If nDifReten <> 0  
	               //"O valor do IVA na venda, "        
	               //", nao corresponde ao valor do titulo da retencao/isencao."               
	               //"Confirma a atualizacao da diferenca em outra parcela?"         
	               lRet  := MsgYesNo(STR0150+AllTrim(Str(nVlrImpos,11,2))+STR0151+chr(13)+STR0152)   
	               If lRet
	                  For nX := 1 to Len(aPgtos)   
	                     If nX <> nPos
	                        aPgtos[nX][2] += nDifReten      
	                        nDifReten      := 0
	                     Else
	                        aPgtos[nX][2] := nVlrImpos
	                     EndIf
	                  Next nX
	               Else
	                  Exit   
	               EndIf   
	            EndIf                   
	         EndIf
	      Next nPos	   
	   EndIf
	EndIf		
Endif

If nNewOption <> 1 .AND.lRet .AND. lRetNew .AND. lUsaDisplay
	MsgDisplay(6,{nLiq})
EndIf

If lRet .AND. lRetNew
	// Exibe o cliente no rodape da tela de venda.
	LJ010ImpCli( cCliente, cLoja, nNewOption )
EndIf

oGet:oBrowse:lDisablePaint:=.F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³A Execucao do MontP abaixo implica no recalculo das parcelas ³
//³do orcamento caso o usuario selecione um cliente no meio do  ³
//³processo de venda, e este cliente possua uma condicao de     ³
//³pagamento padrao cadastrada (SA1->A1_COND)                   ³
//³                                                             ³
//³Variavel lAtuParc                                            ³
//³                                                             ³
//³Consiste se ja foi rodada a atual-izacao de parcelas acima,  ³
//³caso nao foi rodada, forco o recalculo                       ³
//³                                                             ³
//³                                                             ³
//³Fernando Salvatori - 20/09/2002                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAtuParc
	Lj010MontP(aCondicoes,@cCombo,oEntrada,oNumParcelas,oFinanciado,@nValorBase,@cForma,@nEntrada,@nFinanciado,;
               @nCondicao,@cCondicao,@nNumParcelas,oTxJuros,cComboAnt2,@nTxDescon,oTxDescon,nIntervalo,nDescLoj,;
               .F.,@nLiq,nDescPer,oVlrImpos,@nTipoJur,@cTipoJuros,oTipoJuros,oCombo,oIntervalo,oVlrTotVen)
               
	lAtuParc := .F.
EndIf
                                    
If cPaisLoc <> "BRA" .AND. lMudaPagina
	If nNewOption == 2 .AND. oFolder:nOption == 1
		nVlrTot := nVlrTot - nDescLoj
		oVlrTot:Refresh()
	EndIf	
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificando se o operador possui acesso para acessar as folders ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nNewOption == 1 		.AND. !ChkPsw( 25 )
   lRet := .F.
ElseIf nNewOption == 2 	.AND. !ChkPsw( 29 )
   lRet := .F.
ElseIf 	nNewOption == 3 .AND. !ChkPsw( 30 )
   lRet := .F.
EndIf

Return (lRet .AND. lRetNew)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj010Troco³ Autor ³ Vendas Clientes       ³ Data ³ 13/11/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula o troco ao consumidor                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Lj010troco                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010Troco(nValPag,nTroco,oTroco)

If nValPag < aReceb[1][2] .AND. nValPag <> 0
	Help(" ",1,"TROCOMENOR")
	Return .F.
ElseIf nValPag == 0
	nTroco:=0
	oTroco:Refresh()
	Return .T.
EndIf

nTroco:=nValPag - aReceb[1][2]

oTroco:Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj010Prod ³ Autor ³ Vendas Clientes       ³ Data ³ 13.11.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consulta ao Produto                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010Prod(cProduto,cLocal)
Local oEstoque

If !Empty( cProduto)
	oBtnEst:SetDisable(.T.)
	SetKey(5,Nil)	
EndIF

If Empty( cProduto )
	Return .T.
EndIf

DBSelectArea( "SB1" )
DbSeek( xFilial() + cProduto )

DBSelectArea( "SB2" )
DbSeek( xFilial() + cProduto + cLocal )

DBSelectArea( "SB0" )
DbSeek( xFilial() + cProduto )

DBSelectArea( "SB9" )
DbSeek( xFilial() + cProduto + cLocal )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra dados do Produto.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oEstoque FROM 10, 16 TO 29, 73.5 TITLE STR0038;  // Consulta Estoque
STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oDlgLoja

//ÚÄÄÄÄÄÄÄÄ¿
//³ Dados  ³
//ÀÄÄÄÄÄÄÄÄÙ
@	8, 2 TO	43, 187 OF oEstoque PIXEL
@ 51, 2 TO	70, 187 OF oEstoque PIXEL
@ 76, 2 TO 135, 187 OF oEstoque PIXEL

@ 4,    2 SAY STR0005 SIZE	80, 7 OF oEstoque PIXEL  // Dados do Produto:
@ 16,   4 SAY STR0006 SIZE	21, 7 OF oEstoque PIXEL  // C¢digo
@ 15,  26 MSGET SB1->B1_COD      SIZE	49, 9 OF oEstoque PIXEL When .F.
@ 16,  83 SAY STR0007 SIZE	25, 7 OF oEstoque PIXEL  // Unidade
@ 15, 110 MSGET SB1->B1_UM       SIZE	14, 9 OF oEstoque PIXEL When .F.
@ 16, 137 SAY STR0008 SIZE	18, 7 OF oEstoque PIXEL  // Grupo
@ 15, 158 MSGET SB1->B1_GRUPO    SIZE	14, 9 OF oEstoque PIXEL When .F.
@ 30,   4 SAY STR0009 SIZE	35, 7 OF oEstoque PIXEL // Descri‡Æo
@ 29,  40 MSGET SB1->B1_DESC     SIZE  130, 9 OF oEstoque PIXEL When .F.
@ 40, 335 TO 40, 335 OF oEstoque PIXEL
@ 46,   3 SAY STR0010 SIZE	28, 7 OF oEstoque PIXEL // Estoque:

//ÚÄÄÄÄÄÄÄÄ¿
//³ Saldo  ³
//ÀÄÄÄÄÄÄÄÄÙ
@ 57,   4 SAY STR0011 SIZE 21, 7 OF oEstoque PIXEL  // Inicial
@ 56,  25 MSGET SB9->B9_QINI Picture PesqPict("SB9","B9_QINI") SIZE 49, 9 OF oEstoque PIXEL When .F.
@ 57,  82 SAY STR0012 SIZE 21, 7 OF oEstoque PIXEL  // Atual
@ 56, 107 MSGET SaldoSB2() Picture PesqPict("SB2","B2_QATU") SIZE 49, 9 OF oEstoque PIXEL When .F.

//ÚÄÄÄÄÄÄÄÄÄÄ¿
//³ Precos	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÙ
@ 71,  3 SAY STR0013 SIZE 53, 7 OF oEstoque PIXEL // Pre‡os de Venda:
@ 82,  6 SAY "1 -"   SIZE 11, 7 OF oEstoque PIXEL
@ 93,  6 SAY "2 -"   SIZE 11, 7 OF oEstoque PIXEL
@ 103, 6 SAY "3 -"   SIZE 11, 7 OF oEstoque PIXEL
@ 122, 6 SAY "5 -"   SIZE 11, 7 OF oEstoque PIXEL
@ 83, 93 SAY "6 -"   SIZE 11, 7 OF oEstoque PIXEL
@ 103,93 SAY "8 -"   SIZE 11, 7 OF oEstoque PIXEL
@ 93, 93 SAY "7 -"   SIZE 11, 7 OF oEstoque PIXEL
@ 112,93 SAY "9 -"   SIZE 11, 7 OF oEstoque PIXEL
@ 112, 6 SAY "4 -"   SIZE 11, 7 OF oEstoque PIXEL

@ 82,  18 MSGET SB0->B0_PRV1 Picture PesqPict("SB0","B0_PRV1",_PICTURE,1) SIZE 49, 9 OF oEstoque PIXEL When .F.
@ 91,  18 MSGET SB0->B0_PRV2 Picture PesqPict("SB0","B0_PRV2",_PICTURE,1) SIZE 49, 9 OF oEstoque PIXEL When .F.
@ 101, 18 MSGET SB0->B0_PRV3 Picture PesqPict("SB0","B0_PRV3",_PICTURE,1) SIZE 49, 9 OF oEstoque PIXEL When .F.
@ 111, 18 MSGET SB0->B0_PRV4 Picture PesqPict("SB0","B0_PRV4",_PICTURE,1) SIZE 49, 9 OF oEstoque PIXEL When .F.
@ 121, 18 MSGET SB0->B0_PRV5 Picture PesqPict("SB0","B0_PRV5",_PICTURE,1) SIZE 49, 9 OF oEstoque PIXEL When .F.
@ 82, 106 MSGET SB0->B0_PRV6 Picture PesqPict("SB0","B0_PRV6",_PICTURE,1) SIZE 49, 9 OF oEstoque PIXEL When .F.
@ 91, 106 MSGET SB0->B0_PRV7 Picture PesqPict("SB0","B0_PRV7",_PICTURE,1) SIZE 49, 9 OF oEstoque PIXEL When .F.
@ 101,106 MSGET SB0->B0_PRV8 Picture PesqPict("SB0","B0_PRV8",_PICTURE,1) SIZE 49, 9 OF oEstoque PIXEL When .F.
@ 111,106 MSGET SB0->B0_PRV9 Picture PesqPict("SB0","B0_PRV9",_PICTURE,1) SIZE 49, 9 OF oEstoque PIXEL When .F.
DEFINE SBUTTON FROM 010,192 TYPE 1 ACTION oEstoque:End() ENABLE OF oEstoque

ACTIVATE MSDIALOG oEstoque

oBtnEst:SetDisable(.F.)
SetKey(5,oBtnEst:bAction)	
	
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj010Juros³ Autor ³ Vendas Clientes       ³ Data ³ 08.01.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Janela para condicao negociada (Juros etc...)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ010JUROS(nEntrada,		nParcelas,		nIntervalo,		nValorBase,;
					oEntrada,		oTxJuros,		oNumParcelas,	oIntervalo,;
					aCondicoes,		nFinanciado,	cForma,			oFinanciado,;
					lCalcEntrada,	nEntrAnt,		nEntrOrig,		aParcelas,;
					cCombo,			oCombo,			nNumParcelas,	nLiq,;
					oVlrLiq,		oVlrLiq1,		oVlrLiq2,		lFirstJur,;
					nTipoJur,		cCondicao,		oFnt2,			nVlrTot,;
					nDescloj,		oDescPer,		nDescPer,		nVlrLiq,;
					nVlrAcrs,		nVlrDesc,		cTipoJuros,		oVlrAcrs,;
					oVlrDesc,		oTipoJuros,		cComboAnt2,		oVlrImpos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de variaveis locais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oDlgLojaJur
Local oTipoJur
Local oDataNeg
Local oEntNeg
Local oTxjNeg
Local oParNeg
Local oIntNeg
Local oComboAdm
Local oUsaAdmFin
Local oVlrBase
Local oChkDiaFixo             
Local oIntDVenc
Local nPos, i
Local nEntNeg	 := 0
Local nTxjNeg	 := 0
Local nParNeg	 := 0
Local nIntNeg	 := 1
Local lOk		 := .F.
Local lSaida	 := .F.
Local lCalJur	 := .F.
Local lUsaAdmFin := .F.
Local lRetValue  := .F.
Local cComboAdm  := ""
Local aComboAdm  := Lj010LerCart("FI",.T.)
Local aLbxFator  := {}
Local lLjCoNeg   := ExistBlock("LJCONDNEG")
Local bChange
Local aRetNeg    := {}
//Salvando a dDataBase para posterior recuperacao.
Local dDataBak := dDataBase
Local aTipoJuros := {STR0027, STR0092, STR0093}	// Simples | Serie Pgtos | Price 
Local oFnt5
DEFINE FONT oFnt5 NAME "Arial" SIZE 10,10 BOLD

If Alltrim(Procname(2)) == "LJ010NUM"
	Return .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita a tela de condicao negociada somente se estiver    ³
//³ posicionado no segundo folder.							 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oFolder:nOption == 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A ocorrencia 35 (ACS), verifica se o usu rio poder  ou n„o  ³
	//³ efetuar o Condi‡Æo Negociada.							 	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ChkPsw( 35 )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura a integridade da janela ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Return .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se tem permissao para informar condicao negociada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLjCoNeg
		If !ExecBlock("LJCONDNEG",.F.,.F.)
			// Caixa n„o autorizado
			MsgAlert( STR0121 )
			Return .F.
		Endif
	ElseIf ! LjProfile(9)
		// Caixa n„o autorizado
		MsgAlert( STR0121 )
		Return .F.
	EndIf
	
	// NÆo podera entrar nesta condicao, caso o valor das compras seja 0
	
	If nLiq == 0
		Help(" ","1","SEMVALOR")
		Return .T.
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Administradora padr„o ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cComboAdm := aComboAdm[1]
	Aadd(aLbxFator, { "  /  /  " , "" } )
	
	aRetNeg:={{nTipoJur,"1110"},;
	{lUsaAdmFin,"1"},;
	{cComboAdm ,"1"},;
	{If(lFirstJur,dDataBase,aPgtos[1][1]),"1"},;
	{nEntrada,"1"},;
	{nTxJuros,"1"},;
	{nNumParcelas,"1"},;
	{If(nIntervalo == 0,1,nIntervalo),"1"}}
	
	If (ExistBlock("L10RETNG"))
		aRetNeg:=ExecBlock("L10RETNG",.F.,.F.,{aRetNeg})
	EndIf
	
	nTipoJur   := aRetNeg[1][1]
	lUsaAdmFin := aRetNeg[2][1]
	cComboAdm  := aRetNeg[3][1]
	dDataCN    := aRetNeg[4][1]
	nEntNeg    := aRetNeg[5][1]
	nTxjNeg    := aRetNeg[6][1]
	nParNeg    := aRetNeg[7][1]
	nIntNeg    := aRetNeg[8][1]
	
	If (ExistBlock("L10NEGOC"))
		ExecBlock("L10NEGOC",.F.,.F.)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seta que ja entrou na Rotina uma vez ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lFirstJur := .F.
	
	If Len(aRetNeg) <= 8 .OR. aRetNeg[09][01]
	
		// Condi‡„o Negociada
		DEFINE MSDIALOG oDlgLojaJur FROM 33,33 TO 315,540 TITLE STR0025 PIXEL OF oDlgLoja
		
		@ 01, 03 TO  55,120 LABEL STR0082 OF oDlgLojaJur PIXEL // C lculo de Juros
		@ 60, 03 TO 123,120 LABEL STR0083 OF oDlgLojaJur PIXEL // Administradora
		@ 01,124 TO 123,250 LABEL STR0084 OF oDlgLojaJur PIXEL // Dados do Pagamento
		// Utilizar Financiadora
		@ 70, 20 CHECKBOX oUsaAdmFin VAR lUsaAdmFin PROMPT;
		STR0129 FONT oDlgLojaJur:oFont SIZE 60,07 OF oDlgLojaJur PIXEL; //"Utilizar Financiadora"
		ON CHANGE CalcFator(oDlgLojaJur,@aLbxFator,oLbxFator,lUsaAdmFin,;
		cComboAdm,cCondicao) When .F.
		// Nome da administradora
		@ 80, 20 MSCOMBOBOX oComboAdm VAR cComboAdm ITEMS aComboAdm SIZE 75,07;
		OF oDlgLojaJur PIXEL When lUsaAdmFin
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Radio para a escolha do tipo de juros ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Simples / S‚rie Pgtos. / Price / SAC
		@	09, 07 RADIO oTipoJur VAR nTipoJur 3D SIZE 40,10 PROMPT;
		STR0091,STR0092,STR0093,STR0094 ;
		OF oDlgLojaJur PIXEL
		
		// Respeita a configuracao retornada pelo PE L10RetNG
		For i := 1 To 3
			If Substr(aRetNeg[1][2],i,1) = "1"
				oTipoJur:Enable(i)
			Else
				oTipoJur:Disable(i)
			EndIf
		Next i
		
		oTipoJur:Disable(4)	// SAC
		
		@ 07,128 TO  27,246 OF oDlgLojaJur PIXEL
		@ 15,131 SAY STR0085 SIZE 30,07 OF oDlgLojaJur PIXEL	// Valor Base
		If cPaisLoc == "BRA"
			@ 15,176 SAY oVlrBase VAR nValorBase SIZE 68,07 OF oDlgLojaJur PIXEL Picture;
			"@E 9,999,999.99" RIGHT COLOR CLR_HBLUE FONT oFnt2
		Else
			@ 16,160 SAY oVlrBase VAR nValorBase SIZE 70,10 OF oDlgLojaJur PIXEL Picture;
			PesqPict("SL1","L1_VLRTOT",_PICTURE,nMoedaCor) RIGHT COLOR CLR_HBLUE FONT oFnt5
		EndIf
		//Primeira Parcela
		If aRetNeg[4][2]<>'2'
			@ 35,131 SAY STR0130 SIZE 50,07 OF oDlgLojaJur PIXEL	// Primeira parcela
			@ 35,176 MSGET oDataNeg VAR dDataCN SIZE 40,07 OF oDlgLojaJur PIXEL ;
			Picture "99/99/99" Valid !Empty(dDataCN) .AND. dDataCN >= dDataBase ;
			WHEN aRetNeg[4][2]<>'0'
		EndIf
		//Entrada
		If aRetNeg[5][2]<>'2'
			@ 50,131 SAY STR0086 SIZE 30,07 OF oDlgLojaJur PIXEL	// Entrada
			@ 50,176 MSGET oEntNeg VAR nEntNeg SIZE 60,07 OF oDlgLojaJur PIXEL Picture;
			PesqPict("SL1","L1_VLRTOT",_PICTURE,nMoedaCor) RIGHT;
			Valid lj010First(nValorBase,nEntNeg,nFinanciado,nParcelas,@nParNeg,oParNeg,oEntNeg) ;
			WHEN aRetNeg[5][2]<>'0'
		Endif
		// Taxa Juros
		If aRetNeg[6][2]<>'2'
			@ 65,131 SAY STR0087 SIZE 30,07 OF oDlgLojaJur PIXEL	// Taxa Juros
			@ 65,176 MSGET oTxjNeg VAR nTxjNeg SIZE 20,07 OF oDlgLojaJur PIXEL ;
			PICTURE "@E 999.99" RIGHT VALID ( If(nTxjNeg >= 0, .T., (MsgStop(STR0135),.F.))); // "O campo Taxa Juros deve ter valor positivo."
			When !lUsaAdmFin .AND. aRetNeg[6][2]<>'0'
		EndIf
		// Parcelas
		If aRetNeg[7][2]<>'2'
			@ 80,131 SAY STR0088 SIZE 30,07 OF oDlgLojaJur PIXEL	// Parcelas
			@ 80,176 MSGET oParNeg VAR nParNeg SIZE 13,07 OF oDlgLojaJur PIXEL PICTURE;
			"@E 99" RIGHT ;
			Valid IIf(nEntNeg > 0 .AND. nEntNeg < nValorBase,nParNeg > 1,.T.) ;
			When (nEntNeg < nValorBase).AND.aRetNeg[7][2]<>'0'
		EndIf
		// Intervalo  // Dia Vencimento
		If aRetNeg[8][2]<>'2'
			@ 95,131 SAY oIntDVenc VAR If(lDiaFixo, STR0158, STR0089) SIZE 40,07 OF oDlgLojaJur PIXEL	// Intervalo //"Dia vencimento"		
			@ 95,176 MSGET oIntNeg VAR nIntNeg SIZE 13,07 OF oDlgLojaJur PIXEL PICTURE	"999" ;
			VALID (nIntNeg > 0) WHEN aRetNeg[8][2]<>'0'
		EndIf
		
		If SL1->(FieldPos("L1_DIAFIXO"))>0	
			@ 110, 131 CHECKBOX oChkDiaFixo VAR lDiaFixo PROMPT STR0159 SIZE 30,07;   //"Dia Fixo" 
			ON CHANGE (If (lDiaFixo,nIntNeg:=Day(dDataBase),nIntNeg := 1), oIntDVenc:Refresh(), oIntNeg:Refresh())
		EndIf
		
		DEFINE SBUTTON FROM 125,194 TYPE 1 ENABLE OF oDlgLojaJur;
		ACTION (lOk := .T.,lSaida := .T.,cCondicao := "CN",oDlgLojaJur:End())
		
		DEFINE SBUTTON FROM 125,223 TYPE 2 ENABLE OF oDlgLojaJur;
		ACTION (lOk := .F.,lSaida := .T.,oDlgLojaJur:End())
		
		ACTIVATE MSDIALOG oDlgLojaJur CENTERED

	Else
	
		// Se não entrou no IF, então o PE esta configurado para não mostrar a janela de Cond. Negociada
		// a variavel lOK fica como .T.
		lOk := .T.
	
	EndIf
	
	// Se cancelou a tela abandona a funcao
	If !lOk
		Return .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se confirmou a tela devera zerar o  desconto das       ³
	//³condicoes de pagto (Simples)                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlrDesc -= nVlrTxDesc
	nVlrTxDesc := 0
	
	// Nao aceitar data da primeira parcela invalida
	If Empty(dDataCN) .OR. dDataCN < dDataBase
		dDataCN := dDataBase
	EndIf
	
	nEntrada 	 := nEntNeg
	nTxJuros 	 := nTxjNeg
	nParcelas	 := nParNeg
	nNumParcelas := nParNeg
	nIntervalo	 := nIntNeg
	
	aAltDtBase  := {.T.,dDataBase}
	If !lDiaFixo 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o numero de parcelas for igual a 1, nao altera a data da entrada ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dDataBase := If( nEntNeg = 0 .AND. nNumParcelas > 1 , dDataCN - nIntNeg, dDataCN )
	ElseIf dDataCN > dDataBase
		dDataBase := dDataCN
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Muda o tipo de pagamento no ComboBox ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	// Condi‡„o Negoc.
	cCombo := "CN " + " - " + STR0026
	
	// Guarda a propriedade bChange que chama esta funcao em uma variavel local e
	// inicializa a propriedade bChange do combobox.
	bChange := oCombo:bChange
	oCombo:bChange := { || }
	
	// Muda a opcao do combobox para CN - Condi‡„o Negociada e executa o refresh.
	If ( nPos := ASCAN( aCondicoes, { |x| x ==  "CN " + " - " + STR0026  } ) ) > 0
		oCombo:nAt := nPos
	EndIf
	oCombo:Refresh()
	
	// Restaura a propriedade bChange do combobox.
	oCombo:bChange := bChange
	cComboAnt2 := cCombo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o tipo de juros e v lido  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipoJur == 0 .OR. nTipoJur > 4
		nTipoJur := 1
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso tenha taxa de juros especifica para calcular os juros ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTxjNeg > 0
		lCalJur := .T.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso escolha Financiadora, utiliza metodo de Tabela (Fator de Multiplic) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If !lUsaAdmFin
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama o Calculo de juros de acordo com o tipo escolhido ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lj010CalSim(aCondicoes,@nValorBase,;
		@nEntNeg,@nFinanciado,@cForma,@nParNeg,@nIntNeg,oEntrada,oTxJuros,;
		oNumParcelas,oFinanciado,@lCalcEntrada,@nEntrAnt,lCalJur,@nEntrOrig,;
		aParcelas,@cCombo,oCombo,@nNumParcelas,@nVlrAcrs,oVlrAcrs,nVlrDesc,;
		oVlrDesc,nTipoJur,nDescLoj,@nLiq,nDescPer,oVlrImpos)
		cTipoJuros := aTipoJuros[nTipoJur]
	Else
		Lj010UsaFin(cComboAdm)
		cTipoJuros := STR0032					// Financiadora
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza Valores na Tela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj010Mostra(@nEntrada,@nParcelas,@nIntervalo,@nValorBase,;
	oEntrada,oTxJuros,oNumParcelas,oIntervalo,aCondicoes,;
	@nFinanciado,oFinanciado,@cCombo,oCombo,@nLiq,oVlrLiq,;
	oVlrLiq1,oVlrLiq2,@nTipoJur,@cCondicao,oFnt2,;
	@nVlrTot,@nDescloj,oDescPer,@nDescPer,@nVlrLiq,@nVlrAcrs,;
	@nVlrDesc,@cTipoJuros,oVlrAcrs,oVlrDesc,oTipoJuros)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Refresh dos dados no folder 1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oVlrLiq:Refresh()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Refresh dos dados no folder 2 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oEntrada:Refresh()
	oTxJuros:Refresh()
	oNumParcelas:Refresh()
	oIntervalo:Refresh()
	oFinanciado:Refresh()
	oPgtos:Refresh()
	oVlrLiq1:Refresh()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Refresh dos dados no folder 3 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oVlrLiq2:Refresh()
	//Restauraando o valor de dDataBase
	dDataBase:=dDataBak
	aAltDtBase  := {.F.,dDataBase}
	
	lRetValue := .T.
Else
	lRetValue := .F.
ENDIF

RETURN( lRetValue )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj010Valid³ Autor ³ Vendas Clientes       ³ Data ³ 05/08/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a saida da janela.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ lj010Valid                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SLJ010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010Valid(nOpca,	lGravou,	lInclui,	cNumOrc,;
					lRetConc)

Local aArea			:= GetArea()
Local lRet			:= .F.
Local lL10Ok		:= (ExistBlock("L10OK"))
Local lL10Canc 		:= (ExistBlock("L10CANC"))
Local aReserva  	:= {}
Local x 			:= 0
Local nPosReserva  	:= aScan(aHeader,{|x| Alltrim(Upper(x[2]))=="L2_RESERVA"})
Local nPosDescPro 	:= aScan(aHeader,{|x| Alltrim(Upper(x[2]))=="L2_DESCRI"})
Local nPosLojaRes  	:= aScan(aHeader,{|x| Alltrim(Upper(x[2]))=="L2_LOJARES"})
Local nPosCodProd  	:= aScan(aHeader,{|x| Alltrim(Upper(x[2]))=="L2_PRODUTO"})
Local nPosLocal   	:= aScan(aHeader,{|x| Alltrim(Upper(x[2]))=="L2_LOCAL"})
Local aItensRes		:= {}
Local nPosItens		:= 0
Local cLojaLocal 	:= ""
Local cLojaReserva 	:= ""
Local cNomeCamPro   := ""
Local lLjPrdRes		:= ExistBlock("LJPRDRES") 
Local lLjPrdResT	:= ExistTemplate("LJPRDRES")
Local aLjPrdRes		:= {}  	// Retorno do P.E. LJPRDRES

//Mostra tela de perguntas da escolha do desconto para o valor total novamente.
__lDescPerg := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se deu problemas na impressão do item e foi cancelado o cupom fecho a tela |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("lVendConc") == "L" .AND. lVendConc
	If !lRetConc
	    Return(.T.)
	EndIf
EndIf

If oCliente == nil .AND. !SuperGetMV("MV_LJMOD3")
	Return .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega o codigo da loja local               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSelectArea("SLJ")
DBSetOrder(3)
If DbSeek(xFilial("SLJ")+SM0->M0_CODIGO+FWGETCODFILIAL)
	cLojaLocal := SLJ->LJ_CODIGO
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para tratamento do código e descricao do produto             ³
//³ Retorno a posicao da aCols que contem o codigo e a descricao do produto       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLjPrdResT
	aLjPrdRes := ExecTemplate("LJPRDRES",.F.,.F.,{nPosCodProd,nPosDescPro} )
	If ValType(aLjPrdRes) == "A" .AND. Len(aLjPrdRes) >= 2
		nPosCodProd	:= aLjPrdRes[1]
		nPosDescPro	:= aLjPrdRes[2]
	Endif
Endif

If lLjPrdRes
	aLjPrdRes := ExecBlock("LJPRDRES",.F.,.F.,{nPosCodProd,nPosDescPro} )
	If ValType(aLjPrdRes) == "A" .AND. Len(aLjPrdRes) >= 2
		nPosCodProd	:= aLjPrdRes[1]
		nPosDescPro	:= aLjPrdRes[2]
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se as reservas já estão gravadas na base           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSelectArea("SL2")
DBSetOrder(1)
DbSeek(xFilial("SL2")+cNumOrc)
While !Eof() .AND. SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+cNumOrc
	cNomeCamPro  := "SL2->"+aHeader[nPosCodProd,2]
	cLojaReserva := If(Empty(SL2->L2_LOJARES),cLojaLocal,SL2->L2_LOJARES)
	aAdd(aItensRes, {&cNomeCamPro, SL2->L2_RESERVA, cLojaReserva} )
	dbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se houverem reservas soh deixa cancelar o cupom se elas forem canceladas         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SL2->(DBSetOrder(2))
For x:=1 to Len(aCols)
	cLojaReserva := If(Empty(aCols[x][nPosLojaRes]),cLojaLocal,aCols[x][nPosLojaRes])
	If ValType(aCols[x][nPosCodProd]) == "C" .AND. ValType(aCols[x][nPosReserva]) == "C" .AND. ValType(cLojaReserva) == "C"	
	   nPosItens := aScan(aItensRes,{|z| z[1]+z[2]+z[3]==aCols[x][nPosCodProd]+aCols[x][nPosReserva]+cLojaReserva })
	   If !Empty(aCols[ x ][ nPosReserva ]) .AND. nPosItens == 0
		  aAdd( aReserva,{ aCols[ x ][ nPosReserva ],cLojaReserva,;
		  aCols[ x ][ nPosCodProd ], aCols[ x ][ nPosLocal ],;
		  aCols[x][GDFieldPos("L2_NLOTE")],aCols[x][GDFieldPos("L2_LOTECTL")],;
		  aCols[x][GDFieldPos("L2_LOCALIZ")],aCols[x][GDFieldPos("L2_NSERIE")]})
	   EndIf	  
	Endif
Next x

If !Empty( aReserva ) .AND. nOpca == 2
	If LojaOk("Deseja cancelar as reservas antes de anular o orçamento ?")
		LjMsgRun("Aguarde ... Cancelando a Reserva.",,{|| lRet := LjCancRes( aReserva )} )
		If !lRet
			MsgStop("Não foi possível cancelar a reserva.")
		Endif
	Else
		MsgStop("Não é permitido cancelar o cupom com reservas pendentes.")
		lRet := .F.
	Endif

Else

	If !Empty(LOG_TEF)
		LjWriteLog( LOG_TEF + cNumOrc + '.TXT', 'LOJA010B -- LJ010VALID '+Replicate('-',40) )
		LJWriteLog(LOG_TEF + cNumOrc + '.TXT', "nOpcA = " + AllTrim(Str(nOpcA)))
	EndIf

	If nOpca == 1

		If !Empty(LOG_TEF)
			LJWriteLog(LOG_TEF + cNumOrc + '.TXT', "lL10Ok = " + If( lL10Ok, "S", "N" ))
		EndIf

		If lL10Ok
			ExecBlock("L10OK",.F.,.F.,lInclui)
		EndIf
		lRet := .T.
	ElseIf nOpca == 2
		// Confirma a Saida da rotina?
		If ! CheckPaper(.F.) .OR. LojaOK(STR0033)
		
			If !Empty(LOG_TEF)
				LJWriteLog(LOG_TEF + cNumOrc + '.TXT', "! CheckPaper(.F.) = .T. / .OR. / LojaOK() = .T.")
			EndIf
		
			If lL10Canc
				ExecBlock("L10CANC",.F.,.F.,lInclui)
			EndIf
			lRet := .T.
			If lInclui
				lGravou := .F.
			EndIf
		Else
		
			If !Empty(LOG_TEF)
				LJWriteLog(LOG_TEF + cNumOrc + '.TXT', "! CheckPaper(.F.) = .F. / .OR. / LojaOK() = .F.")
			EndIf		
		
			lRet := .F.
			nOpca := 0
		EndIf
	ElseIf nOpca == 0
		// Confirma a Saida da rotina?
		If ! CheckPaper(.F.) .OR. LojaOK(STR0033)
		
			If !Empty(LOG_TEF)
				LJWriteLog(LOG_TEF + cNumOrc + '.TXT', "! CheckPaper(.F.) = .T. / .OR. / LojaOK() = .T.")
			EndIf
		
			If lL10Canc
				ExecBlock("L10CANC",.F.,.F.,lInclui)
			EndIf
			lRet := .T.
			If lInclui
				lGravou := .F.
			EndIf
		Else

			If !Empty(LOG_TEF)
				LJWriteLog(LOG_TEF + cNumOrc + '.TXT', "CheckPaper(.F.) = .T. / .OR. / LojaOK() = .F.")
			EndIf

			lRet := .F.
			nOpca := 0
		EndIf
	ElseIf nOpca == 3
		lRet := .F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se confirmou a saída da rotina vou checkar se existe cupom fiscal³
	//³em aberto para efetuar o cancelamento                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .AND. Type("lVendConc") == "L" .AND. lVendConc
		If nOpca == 1 					//Salvar orçamento
			lRet := Lj010Canc(.T.)		//.T. - Pergunta antes .F. - Não pergunta se deseja cancelar
		Else
			Lj010Canc(.F.)				//.F. - Não perfunta avisa e Cancela
		EndIf
	EndIf
	
	If !Empty(LOG_TEF)
		LJWriteLog(LOG_TEF + cNumOrc + '.TXT', "lRet = " + If( lRet, "S", "N" ))
 		LjWriteLog( LOG_TEF + cNumOrc + '.TXT', 'LOJA010B -- LJ010VALID '+Replicate('-',40) )
	EndIf	
	
Endif

RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RetFator  ³ Autor ³ Vendas Clientes       ³ Data ³ 14.04.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna o fator cadastrado para uma condicao de pagto. 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SigaLoja                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetFator( cCodFin , cCondicao, nFator )
Local lRet		  := .T.
Local aArea 	  := GetArea()

DBSelectArea("SAF")
DBSetOrder(1)

If DbSeek( xFilial( "SAF" ) + cCodFin + cCondicao )
	nFator := SAF->AF_FATOR
Else
	
	// A condi‡„o de pagamento atual n„o cont‚m
	// fator financeiro para a administradora escolhida.
	// Escolha outra condi‡„o, e caso n„o exista nenhuma, favor cadastra-l 
	// previamente.
	// Aten‡„o
	
	MsgInfo(STR0040+;
	STR0041+;
	STR0042+;
	STR0043,;
	STR0044)
	nFator := 0
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010Fator³ Autor ³ Vendas Clientes       ³ Data ³ 13.04.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Calcula e mostra em tela parcelas para fator multiplicador  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj010Fator()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Loja010 - Windows                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Fator(oDlgLoja,		cCombo,			nNumParcelas,	nLiq,;
					nEntrada,		nFinanciado,	cTipoJuros,		oReceb,;
					oTipoJuros,		lUsouFator,		oVlrLiq1,		oEntrada,;
					oFinanciado,	oTxJuros,		oNumParcelas,	nFator,;
					cAdmFator)

Local oBtn1
Local oBtn2
Local oCbxFat
Local cCbxFat	 := ""
Local aCbxFat	 := {}
Local nTotFat	 := nLiq
Local nNumParc   := 0
Local cCondicao  := Capital(Substr( cCombo, 7, Len( cCombo ) ) )
Local cCondPag   := Substr( cCombo, 1,3 )
Local lFinPro	 := .F.


// NÆo podera entrar nesta condicao, caso o valor das compras seja 0
If nLiq == 0
	Help(" ","1","SEMVALOR")
	Return Nil
Endif

// Administradora
DEFINE MSDIALOG oDlgFator FROM  34,155 TO 170,335 ;
TITLE STR0045 PIXEL OF oDlgLoja

// Administradora
@ 4, 4 TO 46, 85 LABEL STR0045 OF oDlgFator	PIXEL

@ 20, 12 COMBOBOX oCbxFat VAR cCbxFat ITEMS aCbxFat SIZE 63, 35 ;
OF oDlgFator PIXEL

DEFINE SBUTTON oBtn1 FROM 50,020 TYPE 1 ENABLE;
ACTION If(RetFator(Substr( cCbxFat,1,3 ) , cCondPag, @nFator ),;
(If(ShowFator(oDlgLoja,@nTotFat,@nNumParc,@nFator,;
@cCondicao,@cCbxFat,@cCondPag,@nEntrada,@nFinanciado,;
@cTipoJuros,@lFinPro,oReceb,oTipoJuros,;
@lUsouFator,@nLiq,@oVlrLiq1,oEntrada,oFinanciado,oTxJuros,;
@nNumParcelas,oNumParcelas,@cAdmFator,oDlgFator),;
oDlgFator:End(),)),.T.) ;
OF oDlgFator PIXEL

DEFINE SBUTTON oBtn2 FROM 50,055 TYPE 2 ENABLE ACTION oDlgFator:End( ) ;
OF oDlgFator PIXEL

ACTIVATE MSDIALOG oDlgFator CENTER ON INIT If(CarVarFat(@nTotFat,@nNumParc,;
@cCondPag,@aCbxFat,@cCbxFat,@nFator,oCbxFat),.T.,oDlgFator:End())

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CarVarFat ³ Autor ³ Vendas Clientes       ³ Data ³ 14.04.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifca se todas as vari veis necess rias para o financia-  ³±±
±±³          ³mento existem.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. ou .F.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Loja010 - Windows                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CarVarFat( nTotFat,	nNUmParc,	cCondPag,	aCbxFat,;
					cCbxFat,	nFator, 	oCbxFat )
Local lRet		  := .T.

aCbxFat	 := Lj010LerCart("FI",.T.)
If Empty( aCbxFat )
	
	// N„o existem administradoras de financiamento habilitadas
	// a utilizar Fator. Incluir uma adminitradora e cadastrar os fatores
	// referˆntes a ela.
	
	MsgInfo( STR0046 + STR0047 + STR0048 )
	lRet := .F.
Else
	oCbxFat:SetItems( aCbxFat )
	cCbxFat := aCbxFat[1]
	oCbxFat:Refresh()
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ShowFator ³ Autor ³ Vendas Clientes       ³ Data ³ 13.04.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra na tela as parcelas e totais do financiamento.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ShowFator()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Loja010 - Windows                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function ShowFator(oDlgLoja,     nTotFat,     nNumParc, nFator,;
                   cCondicao,    cCbxFat,     cCondPag, nEntrada,;
                   nFinanciado,  cTipoJuros,  lFinPro,  oReceb,;
                   oTipoJuros,   lUsouFator,  nLiq,     oVlrLiq1,;
				   oEntrada,     oFinanciado, oTxJuros, nNumParcelas,;
				   oNumParcelas, cAdmFator,   oDlgFator)
Local nI									// Contador para o for que le o array aPgtos
Local aArea:= GetArea()						// Salva area atual
Local lRet := .F.               			// Retorno da funcao
Local oDlgShow								// Objeto da janela de dialogo das parcelas de financiamento
Local oLbxFat								// Objeto listbox contendo as parcelas calculadas
Local oCondPag								// Objeto get para digitacao da variavel cCondPag - Condicao de pagamento
Local oBtn1									// Objeto do botão OK
Local oBtn2									// Objeto do botão Cancela
Local oTotFat								// Objeto get da variavel nTotFatTel - Valor toal
Local oNumParc								// Objeto get da variavel cNumParc
Local oFator								// Objeto get da variavel nFator
Local oCondicao								// Objeto get para digitacao da variavel cCondPag
Local aLbxFat   := {}						// array com as parcelas calculadas
Local cAdmin    := Substr( cCbxFat , 7, Len(cCbxFat ) )	//Nome da Administradora
Local cCodAdm   := Substr( cCbxFat ,1,3)	// Codigo da Administradora
Local aValores  := {}						// Array para calculo dos valores das parcelas
Local nTotFatTel:= 0						// Total do titulo
Local oFnt1									// Define forma e tamanho do fonte da janela
Local nDiasVenc := 0						// Dias para vencimento da parcela AE_VENCFIN
Local lLjAdmFin := ExistBlock("LJADMFIN")	// Boleana para validar a existencia do P.E. LJADMFIN
Local nTaxaJur  := 0						// Taxa de Juros
Local dDataAnt								// Data anterior da parcela 1
Local nNaoFinanc:= 0						// Total das parcelas nao financiadas
Local lContinua := .T.						// Variavel para controle do fluxo logico da funcao
Local lTemPagtFI:= .F.						// Boleana para verificar se ao menos uma parcela eh do tipo "FI"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Le array aPgto procurando se ao menos uma parcela eh "FI" para mostrar a tela das parcelas recalculadas   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len(aPgtos)
	If alltrim(aPgtos[nI,3]) == "FI"
		lTemPagtFI:= .T.
		Exit
	Endif	
Next nI

DBSelectArea("SAE")
DBSetOrder(1)
DbSeek( xFilial("SAE") + cCodAdm )
                       
If (SAE->AE_USAFATO == "S" .AND. AllTrim(SAE->AE_TIPO) == "FI") .AND. !lTemPagtFI
   lContinua:= .F.
EndIf

If lContinua

	lFinPro := ( Upper( AllTrim( SAE->AE_FINPRO)) == "S" )
	nDiasVenc := SAE->AE_VENCFIN
	
	If (nEntrada > 0) .AND. (aPgtos[1][3] <> "FI")
		nTotFat:= nTotFat - nEntrada
		lEntFin:= .F.
	Else
		lEntFin:= .T.
	EndIf
	
	If lLjAdmFin
		nTaxaJur := ExecBlock("LJADMFIN",.F.,.F.,{cCodAdm})
		nTotFat += nTaxaJur
	EndIf
	
	If cPaisLoc == "BRA"
		ddataant := aPgtos[1][1]
		aValores := Condicao( nLiq, cCondPag,,, nRetICMS )
		
		If nEntrada > 0
			aValores[1][1] := dDataAnt
		Endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Quando utilizar Roteiro de C lculo acrescentar o Array de impostos	³
		//³ para a chamada fun‡„o Condicao										³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cCalcImpV == "S"
			aValores := Condicao( nLiq, cCondPag,0.00,,0.00,aImpVarDup )
		Else
			aValores := Condicao( nLiq, cCondPag )
		EndIf
	EndIf
	
	cAdmFator := cCodAdm
	
	nNumParc:= 0
	For nI:= 1 To Len(aPgtos)
		If (AllTrim(aPgtos[nI][3]) == "FI")
			nNumParc++
		Else
			nNaoFinanc += aPgtos[nI][2]
		EndIf
	Next nI
	
	If nEntrada > 0
		nNaoFinanc -= nEntrada
		
		If nNaoFinanc < 0
			nNaoFinanc := 0
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna array com as parcelas calculadas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aLbxFat := CalcFatWin(aValores,nEntrada,(nTotFat-nNaoFinanc),nNumParc,cCondPag,cCodAdm,;
	nFator)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recalcula o valor total ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotFatTel := 0
	Aeval( aLbxFat, { |x| nTotFatTel += x[2] } )
	
	DEFINE FONT oFnt1 NAME "Arial" SIZE 8.5,14 BOLD // Largura x Altura
	
	// Financiamento
	DEFINE MSDIALOG oDlgShow FROM  34,155 TO 326,567 ;
	TITLE STR0049 PIXEL OF oDlgFator
	
	@ 4, 5 TO 56, 200 LABEL "" OF oDlgShow  PIXEL
	
	// Detalhes
	@ 61,5 TO 92, 102 LABEL STR0050 OF oDlgShow  PIXEL
	
	// Condi‡„o de pagamento:
	@ 69, 9 SAY STR0051 SIZE 65, 7 OF oDlgShow PIXEL
	@ 67, 77 MSGET oCondPag Var cCondPag SIZE 15, 08 WHEN .F. ;
	OF oDlgShow PIXEL
	
	// Financiamento Pr¢prio ?
	// Sim / N„o
	@ 80, 9 SAY STR0052 +;
	If(lFinPro,STR0053,STR0054) SIZE 85,7 OF oDlgShow PIXEL
	
	// Administradora
	@ 98,5 TO 126, 102 LABEL STR0045 OF oDlgShow  PIXEL
	
	@ 109, 9 SAY cAdmin SIZE 80,15 OF oDlgShow PIXEL COLOR CLR_BLUE FONT oFnt1
	
	// Data / Valor a pagar
	@ 63,110 LISTBOX oLbxFat FIELDS HEADER STR0055,STR0056 ;
	SIZE 90, 64 OF oDlgShow PIXEL
	oLbxFat:SetArray( aLbxFat )
	oLbxFat:bline := {|| {aLbxFat[oLbxFat:nAt,1],;
	TransForm(aLbxFat[oLbxFat:nAt,2], PesqPict("SL1","L1_VLRTOT",_PICTURE,nMoedaCor))} }
	//Datas e Valores a Pagar
	oLbxFat:cToolTip := STR0057
	//oLbxFat:aJustify := { .T.,.T. } protheus
	
	@ 12, 64 SAY oTotFat   VAR nTotFatTel SIZE 73, 10 OF oDlgShow PIXEL RIGHT;
	PICTURE PesqPict("SL1","L1_VLRTOT",_PICTURE,nMoedaCor) COLOR CLR_HRED FONT oFnt1
	@ 22, 64 SAY oNumParc  VAR nNumParc  SIZE 73, 10 OF oDlgShow PIXEL RIGHT FONT oFnt1 COLOR CLR_BLUE
	@ 32, 64 SAY oFator	  VAR nFator	 SIZE 73, 10 OF oDlgShow PIXEL RIGHT FONT oFnt1 COLOR CLR_BLUE PICTURE "@E 9.999999999"
	@ 42, 64 SAY oCondicao VAR cCondicao SIZE 73, 10 OF oDlgShow PIXEL RIGHT FONT oFnt1 COLOR CLR_BLUE
	
	@ 12, 9 SAY STR0058 SIZE 18, 7 OF oDlgShow PIXEL  // Total:
	@ 22, 9 SAY STR0059 SIZE 28, 7 OF oDlgShow PIXEL  // Parcelas:
	@ 32, 9 SAY STR0060 SIZE 18, 7 OF oDlgShow PIXEL  // Fator:
	@ 42, 9 SAY STR0061 SIZE 30, 7 OF oDlgShow PIXEL  // Condi‡Æo:
	
	DEFINE SBUTTON oBtn1 FROM 132,136 TYPE 1 ENABLE ACTION ;
	(lRet := .T.,AtuVend(@aLbxFat,   @nEntrada,  @nFinanciado,  @cTipoJuros,;
						  nTotFatTel, @lFinPro,   nNumParc,      nFator,;
						  oReceb,     oTipoJuros, @lUsouFator,   @nLiq,;
						  @oVlrLiq1,  oEntrada,   oFinanciado,   oTxJuros,;
						  cCondPag,   nDiasVenc,  @nNumParcelas, oNumParcelas),;
	oDlgShow:End( )) OF oDlgShow PIXEL
	
	DEFINE SBUTTON oBtn2 FROM 132,168 TYPE 2 ENABLE ACTION ;
	(lRet := .F.,nTotFat -= nTaxaJur,If(!lEntFin,nTotFat += nEntrada,),oDlgShow:End( )) OF oDlgShow PIXEL
	
	ACTIVATE MSDIALOG oDlgShow CENTER
	
	RestArea( aArea )

Else
	//A Condicao de Pagamento não condiz com o Tipo de Administradora selecionada. A condicao de pagamento tem que ser do tipo FI,Atencao
	msgInfo(STR0167+" "+STR0168,STR0044)
Endif


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AtuVend   ³ Autor ³ Vendas Clientes       ³ Data ³ 13.04.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza o folder 2 com os valores calculados pelo fator	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ShowFator()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Loja010 - Windows                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AtuVend(	aLbxFat,	nEntrada,	nFinanciado,	cTipoJuros,;
					nTotFatTel,	lFinPro,	nNumParc,		nFator,;
					oReceb,		oTipoJuros,	lUsouFator,		nLiq,;
					oVlrLiq1,	oEntrada,	oFinanciado,	oTxJuros,;
					cCondPag,	nDiasVenc,	nNumParcelas,	oNumParcelas)

Local nAuxFor	:= 0							// Variavel para auxiliar o For
Local lLjAtuCmb	:= ExistBlock("LJATUCMB")		// Verifica se existe execblock
Local aLbxFatBk	:= aClone( aLbxFat )			// Clone do array aLbxFat
Local nPosFat	:= 0							// Contador de quantas vezes entrou como <> de "FI"
Local nNaoFinanc:= 0							// Acumulador do valor nao financiado

lUsouFator	:= .T.
aLbxFat		:= {}

For nAuxFor := 1 to Len( aPgtos )

	If AllTrim(aPgtos[nAuxFor][3]) <> "FI"
		AAdd( aLbxFat,{ aPgtos[nAuxFor][1], aPgtos[nAuxFor][2], aPgtos[nAuxFor][3] } )
		nNaoFinanc += aPgtos[nAuxFor][2]
		nPosFat    += 1		
	Else
		AAdd( aLbxFat,{ aLbxFatBk[nAuxFor-nPosFat][1], aLbxFatBk[nAuxFor-nPosFat][2], "FI" } )
	EndIf

Next nAuxFor

If lFinPro
	cTipoJuros := STR0001					// Fator - Pr¢prio
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o valor financiado ³                       	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nFinanciado := 0
	nEntrada	:= 0

	For nAuxFor :=1 To Len( aLbxFat )

		If aLbxFat[nAuxFor][1] > dDataBase
			nFinanciado += aLbxFat[nAuxFor][2]

		ElseIf aLbxFat[nAuxFor][1] == dDataBase
			nEntrada += aLbxFat[nAuxFor][2]
		EndIf

	Next nAuxFor
	
	nTxJuros  := NoRound( ( ( (  nFinanciado + nEntrada ) - ( nLiq ) ) * 100 ) / ( nLiq ),2 )
	
	aPgtos := {}
	
	For nAuxFor := 1 To Len( aLbxFat )       
		AAdd(aPgtos , { aLbxFat[nAuxFor][1] , aLbxFat[nAuxFor][2], aLbxFat[nAuxFor][3], nMoedaCor } )
	Next nAuxFor
	
	nVlrAcrs := ( nTotFatTel + nNaoFinanc ) - ( nLiq ) // nVlrAcrs ‚ variavel Private
Else
	cTipoJuros	:= STR0002					 // Fator - Outros
	nTxJuros	:= 0
	nVlrAcrs	:= 0
	nNumParcelas:= 1
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe entrada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aLbxFat[1][1] == dDataBase .AND. !lEntFin
		nEntrada	:= aLbxFat[1][2]
		nNumParcelas+= 1
		nFinanciado	:= nLiq - nEntrada
	Else
		nFinanciado	:= nLiq
		nEntrada	:= 0
	EndIf
EndIf

oPgtos:SetArray( aPgtos )

oPgtos:bLine := {||{aPgtos[oPgtos:nAt,1],;
					Transform(aPgtos[oPgtos:nAt,2],PesqPict("SL1","L1_VLRTOT",_PICTURE,aPgtos[oPgtos:nAt,4])),;
					aPgtos[oPgtos:nAt,3],aPgtos[oPgtos:nAt,4]}}

oPgtos:Refresh()
oEntrada:Refresh()
oFinanciado:Refresh()
oTxJuros:Refresh()
oVlrLiq1:Refresh()
oVlrAcrs:Refresh()
oTipoJuros:Refresh()
oNumParcelas:Refresh()
SysRefresh()

If lLjAtuCmb

	aPgtos	:=	ExecBlock("LjAtuCmb",.F.,.F.,{aPgtos})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Compatibilizacao dos rdmakes com a nova posicao Moeda do array aPgtos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aPgtos) > 0
		If Len( aPgtos[1] ) == 3
			AEVAL( aPgtos, { |x| Aadd( x, nMoedaCor ) } )
			AEVAL( aPgtos, { |x| Aadd( x, dDataBase ) } )
		EndIf
	EndIf

	oPgtos:Refresh()
Endif

aParcTef := aClone( aPgtos )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ImpFatWin ³ Autor ³ Vendas Clientes       ³ Data ³ 13.04.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime os dados do finaciamento.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Loja010 - Windows                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ImpFatWin( cCondicao, nValorBase )
Local aArea 	 := GetArea()
Local lScrImp	 := (ExistBlock("IMPFATOR"))
Local nI 		 := 0
Local aFatorTmp  := {}
Local nFator	 := SL1->L1_FATOR
Local cCodAdm	 := SL1->L1_ADMFIN
Local cCondPag   := SL1->L1_CONDPG
Local nTotFat	 := nValorBase
Local nNumParc   := SL1->L1_PARCELAS
Local nEntrada   := SL1->L1_ENTRADA
Local aValores   := {}

Private aParFator := {}

// Deseja imprimir o comprovante de
// Financiamento ?
// Impress„o

If MsgYesNo( STR0062 + STR0063 , STR0064 ) .AND.;
	lj010InitPrint("O")
	
	If cPaisLoc == "BRA"
		aValores := Condicao( nValorBase , cCondicao )
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Quando utilizar Roteiro de C lculo acrescentar o Array de impostos	³
		//³ para a chamada fun‡„o Condicao													³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cCalcImpV == "S"
			aValores := Condicao( nValorBase , cCondicao,0.00,,0.00,aImpVarDup )
		Else
			aValores := Condicao( nValorBase , cCondicao )
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna array com as parcelas calculadas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFatorTmp := CalcFatWin(aValores,nEntrada,nTotFat,nNumParc,;
	cCondPag,cCodAdm,nFator)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega array para impressao no Execblock ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 to Len( aFatorTmp )
		Aadd( aParFator,{Dtoc(aFatorTmp[nI,1]) + " - " + Transform(aFatorTmp[nI,2], "@E 99,999,999.99")})
	Next nI
	
	If lScrImp
		ExecBlock("IMPFATOR",.F.,.F.)
	Else
		
		// Script de impress„o para o comprovante
		// de financiamento n„o exite - Verifique se o arquivo
		// IMPFATOR.PRX e IMPFATOR._IW est„o no diret¢rio das
		// Tabelas de configura‡„o do Sistema. Normalmente \SIGAADV\.
		
		MsgStop(STR0065 + STR0066 +;
		STR0067 + STR0068)
	EndIf
	Lj010EndPrint("O")
EndIf

RestArea( aArea )

Return Nil



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj010Icms ³ Autor ³ Vendas Clientes       ³ Data ³ 09/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Verifica‡„o da Porcentagem de ICM                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LOJA010                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DATA     ³ BOPS ³Prograd.³ALTERACAO                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³21/07/06  ³103030³Cleber M³Implementacao do calculo do ICMS Diferido.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010Icms( nEl,		nDif,		nBase,	cOrigem,;
					nVlrIpi,	aDespFrete	)
Local nI										//Usada em lacos For...Next
Local aArea 		:= GetArea()				//Guarda a area atual
Local nPosTes		:= aPosicoes[5][2]			//Posicao do campo TES
Local nPosTotal		:= aPosicoes[2][2]			//Posicao do campo Total
Local nPosBsIcms	:= aPosicoes[12][2]			//Posicao do campo Base Icms
Local nPosValIpi	:= aPosicoes[7][2]			//Posicao do campo Valor IPI
Local nPosProd   	:= aPosicoes[9][2]			//Posicao do campo Produto
Local nPosValFre	:= aScan( aHeader, { |x| Alltrim(Upper(x[2]))=="L2_VALFRE" } )		//Posicao do campo Frete
Local nPosSeguro 	:= aScan( aHeader, { |x| Alltrim(Upper(x[2]))=="L2_SEGURO" } )		//Posicao do campo Seguro
Local nPosDespesa	:= aScan( aHeader, { |x| Alltrim(Upper(x[2]))=="L2_DESPESA" } )	//Posicao do campo Despesa
Local nValIcms 		:= 0						//Valor final do Icms
Local nElemFiscal 	:= 0						//Indica se encontrou o elemento fiscal
Local nPerRet									//Percentual de Icms
Local nGrade	  	:= Ascan(aCampos,"L2_GRADE")//Posicao do campo Grade
Local cGrade                                    //Conteudo do campo Grade no aCols
Local nValDiferido	:= 0						//Valor do Diferimento de ICMS

Default nEl         := n
Default nDif        := 0
Default cOrigem     := ""
Default aDespFrete  := {}

If cPaisLoc <> "BRA"
	Return( 0.00 )
EndIf

SF4->(DbSeek(xFilial("SF4")+aCols[nEl][nPosTes]))

If !__lPyme
	cGrade	:= aCols[nEl][nGrade]
EndIf

DBSelectArea( "SB0" )
DbSeek( cFilial+aCols[nEl][nPosProd])
If nBase == NIl
	DBSelectArea( "SF4" )
	DbSeek( cFilial+aCols[nEl][nPosTes])
	
	// Faz esse controle para quando carregar um orcamento na "Finaliza Venda"
	If nPosValFre > 0 .AND. nPosSeguro > 0 .AND. nPosDespesa > 0 .AND. ;
		aCols[nEl][nPosValFre] <> Nil .AND. aCols[nEl][nPosSeguro] <> Nil .AND. aCols[nEl][nPosDespesa] <> Nil .AND. ;
		( lVlrFSD )

		nBase := aCols[nEl][nPosTotal] + aCols[nEl][nPosValFre] + aCols[nEl][nPosSeguro] + aCols[nEl][nPosDespesa]

	ElseIf !Empty( aDespFrete ) .AND. ( lVlrFSD )

		nBase := aCols[nEl][nPosTotal] + aDespFrete[nEl][1] + aDespFrete[nEl][2] + aDespFrete[nEl][3]

	Else

		nBase := aCols[nEl][nPosTotal]

	Endif
	
	If SF4->F4_INCIDE == "S"
		nBase += If(nPosValIpi >0,aCOLS[nEl][nPosValIpi],0)
	EndIf
	nBase *= If(SF4->F4_BASEICM>0,SF4->F4_BASEICM/100,1)
	aCOLS[nEl][nPosBsIcms] := nBase
	nPerRet := lj010VerIcm( nEl )
ElseIf Upper(cOrigem) == "CONDPAG"
	If SF4->F4_INCIDE == "S"
		nBase += nVlrIpi
	EndIf
	nBase *= If(SF4->F4_BASEICM>0,SF4->F4_BASEICM/100,1)
	nPerRet := lj010VerIcm( nEl,nBase,SF4->F4_CODIGO )
Else
	nBase *= If(SF4->F4_BASEICM>0,SF4->F4_BASEICM/100,1)
	nPerRet := lj010VerIcm( nEl,nBase,SF4->F4_CODIGO )
EndIf

If lFiscal
	// Verifica se a aliquota esta no array aIcms previamente carregado
	// com as aliquotas de Icms
	For nI := 1 to Len(aIcms)
		If nPerRet = aIcms[nI][1]
			nElemFiscal := 1
			Exit
		EndIf
	Next nI
	If cGrade <> "S"
		If SB0->B0_ALIQRED > 0	  //Aliquota de Reducao de Icms
			nElemFiscal := 0
			For nI := 1 to Len(aIcms)
				If SB0->B0_ALIQRED = aIcms[nI][1]
					nElemFiscal := 1
					Exit
				EndIf
			Next nI
		EndIf
	Endif
	If nElemFiscal == 0 .AND. SF4->F4_ICM == "S"
		
		// A al¡quota de Icms utilizada neste produto n„o est 
		// cadastrada na Impressora fiscal. utilize a op‡„o adiciona Aliquota
		// no menu Miscelƒnea, M¢dulo fiscal, para cadastr -la na Impressora.
		// a al¡quota n„o cadastrada ‚ :
		// Aten‡„o
		
		MsgStop(STR0069 +;
				STR0070 +;
				STR0071 +;
				STR0072 + Transform(If(SB0->B0_ALIQRED>0,SB0->B0_ALIQRED,nPerRet),"@E 99.99") + "%",;
				STR0044)
		nPerRet := 0
	EndIf
EndIf
If SF4->F4_ICM <> "S" .AND. SF4->F4_ISS <> "S"
	nBase := 0
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza a Base do ICMS com o valor correto ou com zero, conforme condicoes acima. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols[nEl ] [nPosBsIcms ] := nBase

If nPerRet > 0
	nValIcms := NoRound(nBase * nPerRet / 100,2,@nDif)
	If Abs(nDif) >= 0.01
		nValIcms += NoRound(nDif)
		nDif		-= NoRound(nDif)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula ICMS Diferido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SF4->F4_ICMSDIF == "3" .AND. SF4->F4_PICMDIF > 0
		nValDiferido := NoRound(nValIcms * SF4->F4_PICMDIF / 100,2,@nDif)
		nValIcms 	 := nValIcms - nValDiferido
		If Abs(nDif) >= 0.01
			nValIcms += NoRound(nDif)
			nDif -= NoRound(nDif)
		EndIf
	EndIf
	
Else
	nValIcms := 0
EndIf

RestArea( aArea )

Return nValIcms

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010VerBa³ Autor ³ Vendas Clientes       ³ Data ³ 07/05/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Devolve a Base de Icms verificando se tem redu‡ao e se o	  ³±±
±±³          ³IPI incide ou nao na Base.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³1 -> Base de Icms                                           ³±±
±±³          ³2 -> Valor do IPI                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010VerBaseIcms( nBase, nVlrIpi, lReduzIcm )
Local cAlias	   := Alias( )
Local nPosBaseIcm  := aPosicoes[12][2]

Default lReduzIcm := .T.

DBSelectArea( "SF4" )
DbSeek( xFilial("SF4") + SL2->L2_TES)

If (nBase == NIL)
	nBase:= If(SF4->F4_ICM == "S" .OR. SF4->F4_ISS = "S",aCols[n][nPosBaseIcm],0)
Else
	nBase += If(SF4->F4_INCIDE == "S",nVlrIpi,0)
	If lReduzIcm
		nBase *= If(SF4->F4_BASEICM > 0,SF4->F4_BASEICM/100, 1)
	EndIf
EndIf

DBSelectArea(cAlias)

Return (nBase)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj010Imp  ³ Autor ³ Vendas Clientes       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Processa impress„o de cheques e boletos.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³lj010Imp()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010Imp(	nCheck,		lCheck3,	cCondicao,	nValorBase,;
					nTroco	)

Local lOk	  := .T.
Local lFator  := ( SL1->L1_FATOR > 0 )
Local nI
Local cBanco
Local cAgencia
Local cConta
Local nTemCheq := 0
Local cScrCup:= SuperGetMV("MV_SCRCUP")
Local cObs := ''
Local cVerso := ''
Local dEmissao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime ou n„o comprovante de Financiamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFator
	ImpFatWin( cCondicao, nValorbase )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime o Cupom	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nCheck == 3
	If lj010InitPrint("C")
		ExecBlock( cScrCup ,.F.,.F.,{nTroco} )
		lj010EndPrint("C")
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Nota Fiscal  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nCheck == 2
	Lojr110()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao de Cheques	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCheck3
	For nI := 1 to Len(aReceb)
		If AllTrim(aReceb[nI][3]) == cSimbCheq
			nTemCheq := 1
		EndIf
	Next nI
	
	If nTemCheq == 1
		
		Private ndllSer := 0
		
		Set Printer To (LjGetStation("PORTCHQ"))
		Set Device To Printer
		
		cTipoImp:=LjGetStation("IMPCHQ")
		If Empty(cTipoImp) .OR. cTipoImp == STR0073		// Nenhum Drive
			Help( " ", 1, "SEMDRIVE" )
			lOk:=.F.
		Else
			If SuperGetMV("MV_CMC7CHQ") == 1
				For nI := 1 To Len(aReceb)
					If AllTrim(aReceb[nI][3]) == cSimbCheq
						cBanco	 := Substr(aReceb[nI][4],1,3)
						// Utiliza a Razao Social (M0_NOMECOM) como Nome do Favorecido, se estiver em branco utiliza o nome fantasia (M0_NOME)
						cFavorec  := If(Empty(SM0->M0_NOMECOM),SM0->M0_NOME,SM0->M0_NOMECOM)
						cCidade	 := If(Empty(Substr(SM0->M0_CIDCOB,1,15)),"Sao Paulo",Substr(SM0->M0_CIDCOB,1,15))
						nValor	 := aReceb[nI][2]
						If SuperGetMV("MV_DATCHE") == "E"
							dEmissao := dDataBase
						Else
							dEmissao := aReceb[nI][1]
						EndIf
						cCheque	 := aReceb[nI][5]
						cAgencia  := aReceb[nI][6]
						cConta	 := aReceb[nI][7]
						
						lOk := LjImpCheque( cBanco, cAgencia, cConta, cCheque, @nValor, @cFavorec, @cCidade, @dEmissao, @cObs, @cVerso )
						
					Endif
				Next nI
			EndIf
		EndIf
		
	EndIf
EndIf

Set Printer To

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010Unit ³ Autor ³ Vendas Clientes       ³ Data ³ 06.06.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consiste valor unitario.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010Unit()
Local lRet			:= .T.
Local nPrecoTabela
Local cAlias	    := Alias()
Local nPosTabela    := aPosicoes[10][2]
Local nPosProd      := aPosicoes[9][2]

If !Empty(aCols)
	cTabela := aCols[n][nPosTabela]
	
	If Empty(cTabela) .OR. Empty(aCols[n][nPosProd])
		Help(" ",1,"A010VAZ")
		Return .F.
	EndIf
	
	DBSelectArea( "SB0" )
	DbSeek( cFilial+aCols[n][nPosProd])
	DBSelectArea( cAlias )
	
	nPrecoTabela := &("SB0->B0_PRV" + cTabela)
	If nPrecoTabela <> 0 .AND. nPrecoTabela <> M->L2_VRUNIT .AND. (! Alltrim(Upper(FunName())) $ "LOJA020|LOJA021" .OR. lTroca)
		Help( " ", 1, "LJ010NOVAL" )
		lRet = .F.
	EndIf
	
	If m->l2_vrunit <= 0
		lRet := .F.
	EndIf
EndIF

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj010Nota ³ Autor ³ Vendas Clientes       ³ Data ³ 11.02.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Achoice para numero e serie da nota fiscal                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observa‡Æo³ Incluido o controle de TTS solicitado pelo Wilson 14/01/98 ³±±
±±³          ³ para tratamento do SQL. (Aline)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Nota(	cMvSerie,	nCheck,			lImpCupFis,		nQtdNotas,;
					aNotas,		cNumFiscal,		lCriaSerie,		nItensVenda,;
     				nMaxItens,	lTicket,		cDocSerie,      lVendaCup )
Local aArea 	:= GetArea()
Local aSerNf	:= {}
Local oDlgLojaNota
Local lTudo 	:= .T.
Local nContErr 	:= 0
Local oQual
Local cVarQ 	:= "  "
Local nOpcA 	:= 0
Local lRetorno  := .F.
Local aRecnos	:= {}
Local cFiltSer  :=      ""
Local oTimer
Local nTimeout	:=	SuperGetMV("MV_NOTAOUT")
Local lTimeOut	:=	.F.
Local lLojaNum  := SuperGetMV("MV_LOJANUM")
Local nI, nX    := 0
Local cProg     := AllTrim(FunName())
Local lLimMax   := .F.
Local lQtdeNotas:= ValType(nItensVenda)=="N"
Local cTipoDoc  := ""
Local cSerAtu   := ""
Local nRegSX5   := 0
Local nTamSerie := TamSx3("L1_SERIE")[1]	// Tamanho do campo L1_SERIE - melhorar performance
Local nTamDoc   := TamSx3("L1_DOC")[1]		// Tamanho do campo L1_DOC - melhorar performance
Local cMV_TPNRNFS	:= LjTpNrNFS()	 		// Retorno do parametro MV_TPNRNFS, utilizado pela Sx5NumNota() de onde serah controlado o numero da NF  1=SX5  2=SXE/SXF  3=SD9
Local cFilSx5		:= If(FindFunction("LjFilSX5"),LjFilSX5(),xFilial("SX5")) // Retorna Filial SX5

DEFAULT lTicket     := .F.
DEFAULT lVendaCup	:= .T.

If lFiltSer == Nil
	lFiltSer	:=	ExistBlock("LJ010FILT")
Endif

DEFAULT cNumFiscal  := Space(TamSX3("L1_DOC")[1])
DEFAULT lCriaSerie  := .F.

cNumNota  := If(Type("cNumNota")#"U",cNumNota,cNumFiscal)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for impr. fiscal utiliza o parametro MV_FISNOTA para verificar se per-³
//³ gunta ou nao se imprime Cupom Fiscal									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFiscal .AND. nCheck == 1
	lImpCupFis := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o tratamento de pegar o numero da nota fiscal via semaforo ou via    ³
//³ SX5 (tabela 1)                                                           ³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³ Foi feito dessa forma devido as alteracoes feitas para o cliente Cepar   ³
//³ de Joinville e para nao alterar o que ja temos em campo ja que estamos   ³
//³ terminando o desenvolvimento da versao 7.10                              ³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³ Foi incluido o tratamento do parametro MV_TPNRNFS para fazer o controle  ³
//³ da numeracao da NF por SD9                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMV("MV_LJNFSXE")
	
	// Se a serie estiver em branco abre a tela para a escolha do usuario
	If Empty(cMvSerie)
		If !Sx5NumNota(,SuperGetMv("MV_LJNRNFS",.F.,cMV_TPNRNFS))

			// Volta o padrão da variavel, pois o SX5NUMNOTA ao ser cancelado colocar NIL na variavel
			// cSerie.
			cSerie 		:= Space(nTamSerie)
			lVendaCup   := .F.
			Return .F.

		Endif
		cMvSerie := cSerie
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o MV_TPNRNFS for igual a "3" nao pega o numero da NF aqui e deixa  ³
	//³ para fazer o controle do numero dentro da transacao pelo SD9          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cMV_TPNRNFS <> "3"	
		//Quebra de Notas
		For nX := 1 to nQtdNotas
			cNumNota := NxtSX5Nota( cMvSerie,, SuperGetMV("MV_LJNRNFS",.F.,"2"))
			If LjValNota(cSerie,cNumNota) // Validar as Bases
				cNumNota := PadR( StrZero(Val(cNumNota),Len(cNumNota)) , nTamDoc ) 				
				aAdd(aNotas,{cMvSerie,cNumNota})
			EndIf
		Next nX
	Endif
	
	lRetorno := .T.
	
ElseIf cPaisLoc == "BRA" .OR. !SuperGetMV("MV_SEQESPE",,.F.)	
	
	If Empty(cMvSerie)
		If lFiltSer
			cFiltSer :=	ExecBlock("LJ010FILT",.F.,.F.)
		Endif  
		
		While .T.
			DBSelectArea("SX5")
			DbSeek( cFilSx5+"01" )
			aSerNf	:= {}
			lTudo := .T.
			While cFilSx5+"01" == X5_FILIAL+X5_TABELA
				If !Empty(cFiltSer) .AND. !(Alltrim(X5_CHAVE) $ cFiltSer)
					dbSkip()
					Loop
				Endif
				IF !MSRLock() .OR. SubStr(X5Descri(),1,1) = "*"
					lTudo := .F.
					Exit
				Endif
				
				Aadd(aRecnos,Recno())
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se a S‚rie for CPF, n„o mostra no aChoice, pois ‚ utilizada ³
				//³ internamente para emissao de Cupom Fiscal.					³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Alltrim(SX5->X5_TABELA) == "01" .AND. Alltrim(SX5->X5_CHAVE) == "CPF"
					dbSkip()
					Loop
				ElseIf nCheck == 2 .AND. Alltrim(SX5->X5_TABELA) == "01" .AND. Alltrim(SX5->X5_CHAVE) == "CP"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso seja Nota fiscal n„o exibe a s‚rie CP ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSkip()
					Loop
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso seja Nota fiscal n„o exibe a s‚rie CP ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nCheck == 3 .AND. Alltrim(SX5->X5_TABELA) == "01" .AND. Alltrim(SX5->X5_CHAVE) == "CP"
					aSerNF := {}
					Aadd(aSerNF,{Padr(X5_CHAVE,nTamSerie),Trim(X5Descri())})
					Exit
				EndIf
				
				Aadd(aSerNF,{Padr(X5_CHAVE,nTamSerie),Trim(X5Descri())})
				dbSkip()
			End
			
			If !lTudo
				nContErr ++
				If nContErr > 10
					DbSeek( cFilSx5+"01" )
					While cFilSx5+"01" == X5_FILIAL+X5_TABELA
						MsUnLock()
						dbSkip()
					End
					Help(" ",1,"NOTAPRESA")
					nCOntErr := 0
				EndIf
				Inkey(1)
				Loop
			EndIf
			Exit
		End
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Trata s‚rie e numero da nota fiscal  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// S‚rie/NF
		If cPaisLoc == "BRA"
			DEFINE MSDIALOG oDlgLojaNota TITLE STR0036 From 10,30 To 19.7,68;
			STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF GetWndDefault()
			// S‚rie / N£mero /
			@ .5,.80 LISTBOX oQual VAR cVarQ Fields HEADER STR0077,;
			STR0078 SIZE 130,42 NOSCROLL
			If lLojaNum
				oQual:bLDblClick := {|| aSerNF:=LjSx5Troca(oQual:nAt,@aSerNF),oQual:Refresh() }
			EndIf
			oQual:SetArray(aSerNF)
			oQual:bLine := { || {aSerNf[oQual:nAT,1],aSerNf[oQual:nAT,2]}}
			DEFINE SBUTTON FROM 51,78 TYPE 1 ACTION (lRetorno := LjValNota(aSerNf[oQual:nAt,1],aSerNf[oQual:nAt,2]),nOpca := 1,;
			If(If(lRetorno,LJ010ANF(oQual,aSernf),If(SuperGetMV("MV_LJSGNUM"),Lj010SugNum(@aSerNF,oQual:nAt,oQual),.F.)),;
			oDlgLojaNota:End(),nOpca:=0)) ENABLE OF oDlgLojaNota
			DEFINE SBUTTON FROM 51,107 TYPE 2 ACTION (lRetorno := .F.,oDlgLojaNota:End()) ENABLE OF oDlgLojaNota
			ACTIVATE MSDIALOG oDlgLojaNota CENTERED
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cancelada a escolha da Serie³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lRetorno
				lVendaCup := .F.
			EndIf
		Else
			If !Empty(cFiltSer)
				SX5->(DbSetFilter({|| Trim(X5_CHAVE)$cFiltSer },"Trim(X5_CHAVE)$'"+cFiltSer+"'"))
			Endif
			DEFINE MSDIALOG oDlgLojaNota TITLE STR0123 From 10,30 To 17,58; // Numeracao N.Fiscal
			STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF If(cProg == "LOJA701",oDlgVA,oDlgLoja)
			
			DEFINE TIMER oTimer INTERVAL nTimeOut*1000 ACTION (lTimeOut:=.T.,oTimer:End(),oDlgLojaNota:End())  OF oDlgLojaNota
			@ 1, 2 TO 30, 108 OF oDlgLojaNota PIXEL
			
			@ 7, 5 SAY STR0122 SIZE 22, 7 OF oDlgLojaNota PIXEL //N.Fiscal
			
			@ 6, 25 MSGET cSerie  PICTURE "!!!";
			VALID IIf(lTimeout,.T.,Lj010VlSer(cSerie,@cNumNota)) F3 "01";
			SIZE 15, 10 OF oDlgLojaNota PIXEL
			
			@ 6, 55 MSGET oNFClie VAR cNumNota PICTURE PesqPict("SF2","F2_DOC");
			VALID Lj010Zera(@cNumNota) ;
			SIZE 47, 10 OF oDlgLojaNota PIXEL
			
			DEFINE SBUTTON FROM 31,42 TYPE 1 ACTION If(Lj010NFisca(@cNumNota,,,@cSerie).AND. LjValNota(cSerie,cNumNota),;
			(lRetorno := .T.,nOpca := 1, oDlgLojaNota:End()),;
			nOpca:=0);
			ENABLE OF oDlgLojaNota
			DEFINE SBUTTON FROM 31,73 TYPE 2 ACTION (lRetorno := .F.,oDlgLojaNota:End()) ENABLE OF oDlgLojaNota
			
			ACTIVATE TIMER oTimer
			ACTIVATE MSDIALOG oDlgLojaNota CENTERED
			If !Empty(cFiltSer)
				SX5->(DbClearFilter())
			Endif
		EndIf
		If lRetorno .AND. ExistBlock("LJ010SNF")
			lRetorno := ExecBlock("LJ010SNF",.F.,.F.)
		EndIf
	Else
		DBSelectArea("SX5")
		DbSeek(xFilial()+"01"+cMVSerie)
		IF Eof()
			HELP(" ",1,"ERROSERIE")
			Return .F.
		Endif
		
		While !MsrLock()
			InKey(1)
			nContErr++
			IF nContErr > 10
				Help(" ",1,"NOTAPRESA")
				nCOntErr := 0
			End
		End
		aAdd(aRecnos,Recno())
		cNumNota := Substr(X5Descri(),1,nTamDoc)
		cSerie := cMvSerie
		
		lRetorno := LjValNota(cSerie,cNumNota)
	EndIf
	//Caso o numero maximo de itens seja determinado pelo parametro MV_SER+<serie>
	//calcular novamente a quantidade de notas a serem emitidas apos a selecao da serie
	//do documento
	If cPaisLoc <> "BRA" .AND. lRetorno .AND. lQtdeNotas
	   nMaxItens := LjGetMaxIt(cSerie) 
	   If nItensVenda > nMaxItens
	      nQtdNotas := Int(nItensVenda/nMaxItens) + If(Mod(nItensVenda,nMaxItens)>0,1,0)
	   Else
	      nQtdNotas := 1
	   Endif					   
	   //A impressao de ticket nao tem limitacao de itens - Loc. Guatemala	   
	   If lTicket 
	      nMaxItens := 999
	      nQtdNotas := 1  	      
	   EndIf	   
	EndIf
	
	nX := 1
	While nX <= nQtdNotas
		aAdd(aNotas,{cSerie,cNumNota})
		If nX < nQtdNotas
			cNumNota := PadR(StrZero(Val(cNumNota)+1,Len(cNumNota)),nTamDoc)			
		Endif
		nX ++
	End
	
	//Acertando o numero da nota no Sx5
	DBSelectArea("SX5")
	IF lRetorno
		DbSeek( cFilSx5+"01"+cSerie )
		If cPaisLoc == "SAL"
		   //Verifica se atingiu numeracao maxima
		   lLimMax  := AllTrim(X5Descri()) == Repl("9",nTamDoc)
		   nRegSX5  := Recno()
		EndIf		
		RecLock("SX5")
		SX5->X5_DESCRI  := PadR(StrZero(Val(cNumNota)+1,Len(cNumNota)) , nTamDoc )		
		SX5->X5_DESCSPA := PadR(StrZero(Val(cNumNota)+1,Len(cNumNota)) , nTamDoc )		
		SX5->X5_DESCENG := PadR(StrZero(Val(cNumNota)+1,Len(cNumNota)) , nTamDoc )		
		MsUnlock()
	Endif
	
	//Liberando registros locados
	For nI := 1 to Len(aRecnos)
		dbGoto(aRecnos[nI])
		MsUnLock()
	Next nI
	
	If cPaisLoc == "SAL" .AND. lLimMax
	   //Tipo do documento: 0=Credito Fiscal;1=Fatura;2=Nota de Remissao		      
	   DbGoto(nRegSX5)
	   cTipoDoc := Substr(SX5->X5_CHAVE,1,1)		      
	   cSerAtu  := Substr(SX5->X5_CHAVE,2,2)		      		      
	   lCriaSerie  := LjCriaSerie(cSerAtu,cTipoDoc)	
	EndIf	
//Controle da numeracao por especie de documento. Cada tipo de documento(NF, NCC, NDC, etc.)
//tera uma numeracao independente mesmo que utilizem a mesma serie
Else
	If Empty(cMvSerie)
		If lFiltSer
			cFiltSer :=	ExecBlock("LJ010FILT",.F.,.F.)
		Endif  
		If !lNFManual		
		   While .T.
			  DBSelectArea("SX5")
			  DbSeek( xFilial("SX5")+"AC"+"NF " )
			  aSerNf	:= {}
			  lTudo   := .T.
			  While xFilial("SX5")+"AC" == X5_FILIAL+X5_TABELA			
				 If !Empty(cFiltSer) .AND. !(Alltrim(X5_CHAVE) $ cFiltSer)
					dbSkip()
					Loop
				 EndIf
				 If Substr(X5_CHAVE,1,3) <> "NF "
				    DbSkip()
				    Loop
				 EndIf				
				 If !MSRLock()
				  	lTudo := .F.
					Exit
				 EndIf
				
				 Aadd(aRecnos,Recno())				
				 Aadd(aSerNF,{Substr(X5_CHAVE,4,nTamSerie),Trim(X5Descri())})
				 dbSkip()
			  End
			
			  If !lTudo
				 nContErr++
				 If nContErr > 10
					DbSeek( xFilial("SX5")+"AC"+"NF " )
					While xFilial("SX5")+"AC"+"NF " == X5_FILIAL+X5_TABELA+Substr(X5_CHAVE,1,3)
						MsUnLock()
						dbSkip()
					End
					Help(" ",1,"NOTAPRESA")
					nContErr := 0
				 EndIf
				 Inkey(1)
				 Loop
			  EndIf
			  Exit
		   End
		EndIf   
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Trata s‚rie e numero da nota fiscal  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// S‚rie/NF
        DEFINE MSDIALOG oDlgLojaNota TITLE STR0123 From 10,30 To 17,58; // Numeracao N.Fiscal
        STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF GetWndDefault()
			
		DEFINE TIMER oTimer INTERVAL nTimeOut*1000 ACTION (lTimeOut:=.T.,oTimer:End(),oDlgLojaNota:End())  OF oDlgLojaNota
		@ 1, 2 TO 30, 108 OF oDlgLojaNota PIXEL
			
		@ 7, 5 SAY STR0122 SIZE 22, 7 OF oDlgLojaNota PIXEL //N.Fiscal
		
		If lNFManual	
		   @ 6, 25 MSGET cSerie  PICTURE "!!!";
		   VALID   If(lTimeout,.T.,Lj010VlSer(cSerie,@cNumNota, .T.));
		   SIZE 15, 10 OF oDlgLojaNota PIXEL		
		Else		   
		   @ 6, 25 MSGET cSerie  PICTURE "!!!";
		   VALID   If(lTimeout,.T.,Lj010VlSer(cSerie,@cNumNota, .T.)) F3 "CHA";
		   SIZE 15, 10 OF oDlgLojaNota PIXEL
		EndIf
			
		@ 6, 55 MSGET oNFClie VAR cNumNota	 PICTURE PesqPict("SF2","F2_DOC");
		VALID Lj010Zera(@cNumNota) ;
		SIZE 47, 10 OF oDlgLojaNota PIXEL
			
		DEFINE SBUTTON FROM 31,42 TYPE 1 ACTION If(Lj010NFisca(@cNumNota,,,@cSerie).AND. LjValNota(cSerie,cNumNota),;
		(lRetorno := .T.,nOpca := 1, cDocSerie := "NF "+ cSerie,oDlgLojaNota:End()),;
		nOpca:=0);
		ENABLE OF oDlgLojaNota
		
		DEFINE SBUTTON FROM 31,73 TYPE 2 ACTION (lRetorno := .F.,oDlgLojaNota:End()) ENABLE OF oDlgLojaNota
			
		ACTIVATE TIMER oTimer
		ACTIVATE MSDIALOG oDlgLojaNota CENTERED
				
		If lRetorno .AND. ExistBlock("LJ010SNF")
			lRetorno := ExecBlock("LJ010SNF",.F.,.F.)
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o tamanho da serie for menor ou igual a 3, assume-se que nao foi  ³
		//³ gravado o tipo do documento(NF ,NFO, NFR, etc).Assumir NF como padrao³		
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	    cDocSerie  := "NF " + Padr(cMVSerie,nTamSerie)   
		DBSelectArea("SX5")
		DbSeek(xFilial()+"AC"+cDocSerie)
		IF Eof()
			HELP(" ",1,"ERROSERIE")
			Return .F.
		EndIf
		
		While !MsrLock()
			InKey(1)
			nContErr++
			IF nContErr > 10
				Help(" ",1,"NOTAPRESA")
				nContErr := 0
			EndIf
		End
		aAdd(aRecnos,Recno())
		cNumNota := Substr(X5Descri(),1,nTamDoc)
		cSerie   := cMvSerie
		
		lRetorno := LjValNota(cSerie,cNumNota)
	EndIf
	//Caso o numero maximo de itens seja determinado pelo parametro MV_SER+<serie>
	//calcular novamente a quantidade de notas a serem emitidas apos a selecao da serie
	//do documento
	If lRetorno .AND. lQtdeNotas
	   nMaxItens := LjGetMaxIt(cSerie) 
	   If nItensVenda > nMaxItens
	      nQtdNotas := Int(nItensVenda/nMaxItens) + If(Mod(nItensVenda,nMaxItens)>0,1,0)
	   Else
	      nQtdNotas := 1
	   Endif					   
	   //A impressao de ticket nao tem limitacao de itens - Loc. Guatemala	   
	   If lTicket 
	      nMaxItens := 999
	      nQtdNotas := 1  	      
	   EndIf
	EndIf
	nX := 1
	While nX <= nQtdNotas
		aAdd(aNotas,{cSerie,cNumNota})
		If nX < nQtdNotas
			cNumNota := PadR(Strzero(Val(cNumNota)+1,Len(cNumNota)),nTamDoc)			
		Endif
		nX ++
	End
	
	//Acertando o numero da nota no Sx5
	DBSelectArea("SX5")
	IF lRetorno
		If DbSeek( xFilial("SX5")+"AC"+cDocSerie )
	    	RecLock("SX5",.F.)
			SX5->X5_DESCRI  := PadR(StrZero(Val(cNumNota)+1,Len(cNumNota)) , nTamDoc )		
			SX5->X5_DESCSPA := PadR(StrZero(Val(cNumNota)+1,Len(cNumNota)) , nTamDoc )		
			SX5->X5_DESCENG := PadR(StrZero(Val(cNumNota)+1,Len(cNumNota)) , nTamDoc )		
		   	MsUnlock()
		EndIf   
	EndIf
	
	//Liberando registros locados
	For nI := 1 to Len(aRecnos)
		dbGoto(aRecnos[nI])
		MsUnLock()
	Next nI	
Endif

RestArea(aArea)
Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj010NotOk³ Autor ³ Vendas Clientes       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se o numero da NF esta correto                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³lj010NotOK()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010NotOk(aNota,		oNota,		cSerie,		oSerie,;
					lCupom,		cNumNota)

Local nTamL1_DOC	:= TamSx3("L1_DOC")[1]	// Tamanho do campo L1_DOC
Local cFilSx5		:= If(FindFunction("LjFilSX5"),LjFilSX5(),xFilial("SX5")) // Retorna Filial SX5

If cSerie == "CP "
	lCupom := .T.
End

DBSelectArea("SX5")
DbSeek( cFilSx5+"01"+cSerie )
IF Eof()
	HELP(" ",1,"ERROSERIE")
	MsUnLock()
	Return .F.
Endif
nRegx5:=Recno()
RecLock("SX5")
SX5 -> X5_DESCRI := PadR(Strzero(Val(cNumNota)+1,Len(cNumNota)),nTamL1_DOC)
SX5 -> X5_DESCSPA := PadR(Strzero(Val(cNumNota)+1,Len(cNumNota)),nTamL1_DOC)
SX5 -> X5_DESCENG := PadR(Strzero(Val(cNumNota)+1,Len(cNumNota)),nTamL1_DOC)
MsUnlock()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj010Cheq ³ Autor ³ Vendas Clientes       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Preenche dados do pagamento na matriz de recebimentos       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³lj010Cheq( )                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Cheq(	cBanco,		cAgencia,	cConta,		cCheque,;
					nPos,		cRg,		cTelefone,	lCheckTe,;
					cMesACta,	cAnoACta,	lTipoChq,	cCgcChq,;
					cNomeCli,	cSerChq,	cComp,		cdddcli,;
					cpretelcli,	csuftelcli )
If lsrvcns
	cTelefone := cdddcli + cpretelcli + csuftelcli
Endif
aReceb[nPos,4] := cBanco
aReceb[nPos,5] := cCheque
aReceb[nPos,6] := cAgencia
aReceb[nPos,7] := cConta
aReceb[nPos,8] := cRg
aReceb[nPos,9] := cTelefone
aReceb[nPos,10]:= lCheckTe
If lSrvCns // Servidor de consultas cheque-pre.com
	aReceb[nPos,12]:= cMesACta
	aReceb[nPos,13]:= cAnoACta
	aReceb[nPos,14]:= If(lTipoChq,"2","1")
	aReceb[nPos,15]:= cCgcChq
	aReceb[nPos,16]:= cNomeCli
	aReceb[nPos,17]:= cSerChq
EndIF
aReceb[nPos,18] := cComp

// Pode ser utilizado para imprimir o cheque e/ou consulta serasa, etc...

If ExistBlock("LJIMPCHQ")
	ExecBlock("LJIMPCHQ",.F.,.F.)
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj010Orc  ³ Autor ³ Vendas Clientes       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime dados do Or‡amento na impressora.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³lj010Orc( )                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010Orc()
Local lRet := .T.

If ExistBlock("LJORCADO")		// Permite executar alguma rotina SEM impressao (lj010initprint)
	lRet := Execblock("LJORCADO",.F.,.F.)
	If lRet == Nil
		lRet := .T.
	EndIf
Endif
                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuro o SetPrint para ser utilizado uma unica vez, para ³
//³evitar transtorno na porta da impressora.				   ³
//³OBS: Nao sera necessario a finalizacao da configuracao 	   ³
//³porque o mesmo serah finalizado na funcao MS_FLUSH().	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetConfigurePrinter( .T. ) 

If lRet .AND. lj010InitPrint("O")
	
	// Imprimindo o Or‡amento. Aguarde...
	
	If Alltrim(Procname(2)) == "LOJA016"
		MsgRun(STR0095,,;
		{ || ExecBlock( SuperGetMV("MV_SCRPED"),.F.,.F. ) } )
	Else
		MsgRun(STR0079,,;
		{ || ExecBlock( SuperGetMV("MV_SCRORC"),.F.,.F. ) } )
	Endif
	Lj010EndPrint("O")
EndIf

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj010ValDa³ Autor ³ Vendas Clientes       ³ Data ³ 16/07/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se a data digitada e maior que a anterior          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³lj010ValData()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010ValData( dDataDup, nEntrada, nFinanciado )
Local nPos		 := oPgtos:nAt
Local lRet 		 := .T.
Local nI
Local nA
Local nPos_2

If Len(aPgtos) > 1
	For nI := 1 to Len(aPgtos)
		If nPos == 1
			If !Empty(nEntrada) .AND. dDataDup <> dDataBase
				lRet := .F.
				Help(" ","1","DATAINV_1")
				Exit
			EndIf
			If (dDataDup < dDataBase .OR. (nFinanciado == 0 .AND. dDataDup <> dDataBase);
				.OR. (dDataDup >= aPgtos[nI][1] .AND. nI <> nPos) .AND. nEntrada > 0)
				lRet := .F.
				Help(" ","1","DATAINV_1")
				Exit
			EndIf
			If Empty(nEntrada)
				For nA := 1 to Len(aPgtos)
					If nA == 1
						Loop
					EndIf
					If (dDataDup == dDataBase)
						lRet := .F.
						Help(" ","1","DATAINV_4")
						Exit
					ElseIf (dDataDup >= aPgtos[nA][1])
						lRet := .F.
						Help(" ","1","DATAINV_3")
						Exit
					EndIf
				Next nA
				If lRet == .F.
					Exit
				EndIf
			EndIf
		Else
			For nA := 1 to Len(aPgtos)
				If nA == nPos
					exit
				EndIf
				If (dDataDup <= aPgtos[nA][1])
					lRet := .F.
					Help(" ","1","DATAINV_2")
					Exit
				EndIf
			Next nA
			If !lRet
				Exit
			EndIf
			nPos_2 := nPos+nI
			If nPos_2 > Len(aPgtos)
				Exit
			EndIf
			If (dDataDup >= aPgtos[nPos_2][1])
				lRet := .F.
				Help(" ","1","DATAINV_3")
				Exit
			EndIf
		EndIf
	Next nI
Else
	If !Empty(nEntrada) .AND. dDataDup <> dDataBase
		lRet := .F.
		Help(" ","1","DATAINV_1")
	ElseIf dDataDup < dDataBase
		lRet := .F.
		Help(" ","1","DATAINV_1")
	ElseIf Empty(nEntrada) .AND. dDataDup <= dDataBase
		lRet := .F.
		Help(" ","1","DATAINV_1")
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010GrSL4³ Autor ³ Vendas Clientes       ³ Data ³ 18/09/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava informacoes da forma de pagamento - arq SL4           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010GrSL4(cNumOrc)
Local nCont := 1
Local nDecs

DBSelectArea( "SL4" )
DBSetOrder( 1 )
DbSeek(cFilial + cNumOrc)

If Empty(Len(aPgtos))
	Return .F.
EndIf

While .T.
	nDecs := MsDecimais(aPgtos[nCont][4])
	Lj010RetPos(@aPgtos[nCont][2])
	If cFilial == SL4->L4_FILIAL .AND. cNumOrc == SL4->L4_NUM .AND. !Eof()
		Reclock("SL4")
	Else
		Reclock("SL4",.T.)
		Replace L4_NUM With cNumOrc
	EndIf
	Replace SL4->L4_FILIAL	 With cFilial
	Replace SL4->L4_DATA 	 With aPgtos[nCont][1]
	Replace SL4->L4_VALOR	 With Round(aPgtos[nCont][2],nDecs)
	Replace SL4->L4_FORMA	 With aPgtos[nCont][3]
	If cPaisLoc <> "BRA"
		Replace SL4->L4_MOEDA  with aPgtos[nCont][4]
	EndIf
	
	If oFolder:nOption == 3
		Replace SL4->L4_ADMINIST With aReceb[nCont][4]
		If If(cPaisLoc<>"BRA",!(AllTrim(aReceb[nCont][3])$"CC|CD"),.T.)		
		   Replace SL4->L4_NUMCART  With aReceb[nCont][5]
		EndIf   
		Replace SL4->L4_AGENCIA  With aReceb[nCont][6]
		Replace SL4->L4_CONTA	 With aReceb[nCont][7]
		Replace SL4->L4_RG		 With aReceb[nCont][8]
		Replace SL4->L4_TELEFON  With aReceb[nCont][9]
		Replace SL4->L4_TERCEIR  with aReceb[nCont][10]
		If lSrvCns // Servidor de Consultas Cheque-Pre.com
			Replace SL4->L4_MESACTA With aReceb[nCont,12]
			Replace SL4->L4_ANOACTA With aReceb[nCont,13]
			Replace SL4->L4_TIPOCHQ With aReceb[nCont,14]
			Replace SL4->L4_CGC With aReceb[nCont,15]
			Replace SL4->L4_NOMECLI With aReceb[nCont,16]
			Replace SL4->L4_SERCHQ With aReceb[nCont,17]
		Endif
		Replace SL4->L4_COMP With aReceb[nCont,18]
	EndIf
	MsUnlock()
	nCont++
	dbSkip()
	If nCont > Len(aPgtos)
		Exit
	EndIf
End

While !Eof() .AND. cFilial == SL4->L4_FILIAL .AND. cNumOrc == SL4->L4_NUM
	RecLock("SL4",.F.,.T.)
	dbDelete()
	dbSkip()
End

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj010Recal³ Autor ³ Vendas Clientes       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Recalcula valores caso tenha se mudado valor do pagamento   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³lj010Recal( )                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Recalc(nValor,nVlrLiq,nValAnt)

If nValor == nValAnt
	Return .T.
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjSx5Troca³ Autor ³Vendas Clientes        ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Da get no numero da nota fiscal e na serie                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjSx5Troca(nIt,aSerNF)
Local oDlgLojaNf
Local oBtn
Local cSerie	:= aSerNf[nIt,1]
Local cNumero	:= aSerNf[nIt,2]

// S‚rie/NF
DEFINE MSDIALOG oDlgLojaNf TITLE STR0036 From 13,50 To 18,65 ;
STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF GetWndDefault()
@ .8,.8 MSGET cNumero Picture "@!" Font oDlgLojaNf:oFont Valid oDlgLojaNf:End()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao invisivel para poder exibir help na validacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Sair
@ 2000, 2000 BUTTON oBtn Prompt STR0080 SIZE 44, 11 ACTION oDlgLojaNf:End() OF oDlgLojaNf PIXEL

ACTIVATE MSDIALOG oDlgLojaNf
aSerNf[nIt,2] := cNumero
cSerie :=aSerNf[nIt,1]

Return aSerNf

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj010LerCa³ Autor ³ Vendas Clientes       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Le os cartoes de credito                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³lj010LerCart(aReceb[nPos,3])                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parƒmetros³1 - Tipo de Administrador - Ex: CC, CO, VA                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010LerCarta(cTipo, lFator)
Local aCartoes  := {}

DEFAULT lFator  := .F.

DBSelectArea("SAE")
DbSeek(xFilial("SAE"))

While !Eof() .AND. xFilial("SAE") == SAE->AE_FILIAL
	If Alltrim(SAE->AE_TIPO) == AllTrim(cTipo)
		If lFator
			If Alltrim(Upper(SAE->AE_USAFATO)) == "S"
				Aadd(aCartoes , SAE->AE_COD + " - " + Capital(SubStr(SAE->AE_DESC,1,25)))
			EndIf
		Else
			Aadd(aCartoes , SAE->AE_COD + " - " + Capital(SubStr(SAE->AE_DESC,1,25)))
		EndIf
	EndIf
	dbSkip()
End

If Empty(aCartoes) //.AND. !lFator
	// Admin. n„o Cadastrada
	Aadd(aCartoes, Capital(STR0081))
EndIf

Return aCartoes


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³lj010ComVl³ Autor ³ Vendas Clientes       ³ Data ³ 19/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Compara os valores digitados nas parcelas com o valor total³±±
±±³          ³ do or‡amento, caso hajam divergˆncias retorna FALSE.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ lj010ComVl(nVlrAcrs, nVlrDesc)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nLiq     - Valor Liquido                                   ³±±
±±³          ³ nVlrAcrs - Valor de acrescimo                              ³±±
±±³          ³ nVlrDesc - Valor de desconto                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010ComVl(nLiq, nVlrAcrs, nVlrDesc)
Local lRet 		:= .T.	//Retorno da funcao
Local i			:= 0	//Contador
Local nValTot 	:= 0	//Valor total das parcelas
Local cTotal 	:= ""  	//Valor Total em string
Local nPosMoeda := 4	//Posicao da moeda no array aPagtos
Local nDif      := 0	//Intervalo de tolerancia para diferencas de arredondamento 
Local nVlrTotal := 0	//Valor total da venda 
Local nDifValor := 0 	//Diferenca de valor
Local nTotal    := 0   	//Valor total 

If lVendaRapida
	nPosMoeda   := 11
EndIf

If cPaisLoc == "BRA"            

	//Na venda rapida, o desconto e o acrescimo ja e feito no valor total...
	If lVendaRapida
		cTotal := Str(A410ARRED(nLiq, "L2_VLRITEM"),15,nDecimais)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Acerto do valor total da venda³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTotal := ( ( nLiq + ( nVlrAcrs - nVlrTxDesc ) ) * 100 ) + 0.1
		
		nTotal := A410ARRED( nTotal / 100, "L2_VLRITEM" )

		cTotal := Str( nTotal, 15, nDecimais )

	EndIf

Else
	cTotal    := If(nVlrAcrs>0,Str((nLiq-aDadosJur[6])+aDadosJur[4]+aDadosJur[1],15,nDecimais),Str(nLiq,15,nDecimais))
	nVlrTotal := Val(cTotal)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Checa se a somat¢ria das parcelas est  igual ao valor Total ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (If(cPaisLoc == "BRA",.T.,lValTot))

	For i := 1 To Len(aPgtos)
	
		If lVendaRapida
			nValTot := nValTot + A410ARRED(xMoeda(aPgtos[i][2],aPgtos[i][nPosMoeda],nMoedaCor,dDatabase,nDecimais+1,,nTaxaMoeda),"L2_VLRITEM")
		Else
			nValTot := nValTot + A410ARRED(xMoeda(aPgtos[i][2],aPgtos[i][nPosMoeda],nMoedaCor,dDatabase,nDecimais+1,,nTaxaMoeda),"L2_VLRITEM")		
		EndIf

	Next i
	
	If lTroca
		nValTot += nCredito
	EndIf
	
	If cPaisLoc <> "BRA"
		nDif := (1/(10**nDecimais))   //Intervalo de tolerancia para diferencas de arredondamento na conversao de valores
		nDifValor := Abs(Round(nVlrTotal,nDecimais) - nValTot)
		If nDifValor <= nDif .AND. nDifValor > 0
			nValTot := nVlrTotal              //Ha uma diferenca de arredondamento
		EndIf
	EndIf

	//-- Faz comparação com os valores truncados....
	If nValTot > 0
		nValTot := ( ( nValTot * 100 ) + 0.1 )
		nValTot := ( Int(nValTot) / 100 )
	Endif

	If cTotal <> Str(nValTot,15,nDecimais)
		Help(" ",1,"SOMAPARCOK")
		lRet := .F.
	EndIf

EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³lj010Dup  ³ Autor ³ Vendas Clientes       ³ Data ³ 19/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Checa se o item gera duplicata                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ lj010Dup(cTes)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTes - Tes a ser avaliado                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010Dup(cTes)
Local cAlias := Alias()
Local lRet   := .T.

DBSelectArea("SF4")
DBSetOrder(1)
If DbSeek(xFilial("SF4")+cTes)
	If F4_Duplic == "N"
		lRet:=.F.
	Endif
Endif
DBSelectArea(cAlias)      

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³lj010SugNu³ Autor ³ Vendas Clientes       ³ Data ³ 12/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Sugere proximo numero de nota corretamente                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ lj010Sugnum                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Array com numero e serie                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010SugNum(aSerNf,nItem,oQual)
Local nTamL1_DOC	:= TamSx3("L1_DOC")[1]		// Tamanho do campo L1_DOC
Local cNota 		:= STRZERO(0,nTamL1_DOC)	// Inicializacao do numero da nota
Local cFilSx5		:= If(FindFunction("LjFilSX5"),LjFilSX5(),xFilial("SX5")) // Retorna Filial SX5
Local cNumSx5      

DBSelectArea("SX5")
DbSeek( cFilSx5+"01" )
While !Eof() .AND. x5_Tabela == "01"
	If Alltrim(X5_Chave) == Alltrim(aSerNf[nItem,1])
		cNumSx5 := SubStr(X5Descri(),1,nTamL1_DOC)
		Exit
	Endif
	dbSkip()
End
If Val(aSerNf[nItem,2]) >= Val(cNumSx5)
	aSerNf[nItem,2]:= PadR(StrZero(Val(cNumSx5),Len(cNumSx5)),nTamL1_DOC) 	
	oQual:Refresh()
	Return .F.
Endif
DBSelectArea("SF2")
DBSetOrder(4)
DbSeek(xFilial()+aSerNf[nItem,1],.T.)
IF Eof()
	cNota := STRZERO(0,nTamL1_DOC)
Else
	While F2_Filial+F2_Serie == xFilial()+aSernF[nItem,1] .AND. !Eof()
		cNota:=SF2->F2_Doc
		dbSkip()
	End
Endif
aSerNf[nItem,2] := PadR(StrZero(Val(cNota)+1,Len(cNota)),nTamL1_DOC)
oQual:Refresh()
DBSelectArea("SF2")
DBSetOrder(1)
Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³lj010ANf  ³ Autor ³ Vendas Clientes       ³ Data ³ 18/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Atualiza numero de nota e serie                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ lj010ANf                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³LOJA010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj010ANf(oQual,aSerNf,cSer,cNot)
Local lRet 		 := .F.
Local nTamL1_DOC := TamSx3("L1_DOC")[1]     // Tamanho do campo L1_DOC

If LjValNota(aSerNf[oQual:nAT,1],aSerNf[oQual:nAT,2])
	If cSer == Nil .AND. cNot == Nil
		cSerie 	 := aSerNf[oQual:nAT,1]
		cNumNota := PadR(aSerNf[oQual:nAT,2],nTamL1_DOC) 
	Else
		cSer := aSerNf[oQual:nAT,1]
		cNot := PadR(aSerNf[oQual:nAT,2],nTamL1_DOC)
	Endif
	lRet := .T.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010Ser  ³ Autor ³ Vendas Clientes       ³ Data ³ 25.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia de Localizacao / Numero de Serial              ³±±
±±³          ³utilizado na consistencia do L2_Nserie                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±                                     
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Ser()
Local cProduto   := ""
Local cTes       := ""
Local nQtdVen    := 0
Local cLocal     := ""
Local cLoteCtl   := ""
Local cNlote     := ""
Local cLocaliza  := ""
Local nPosSerial := 0
Local ii         := 0
Local cProcName  := UPPER(ALLTRIM(ProcName(ii)))
Local cNSerie    := M->L2_NSERIE
Local ny
Local w1
Local lRet       := .T.
Local nX					//Controle de Loop
Local lDeletados			//Verifica se item esta deletado no aCols.

For ny := 1 to Len(aHeader)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta chave do registro. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Trim(aHeader[ny][2]) == "L2_PRODUTO"
		cProduto := aCols[n][ny]
	End
	If Trim(aHeader[ny][2]) == "L2_QUANT"
		nQtdVen  := aCols[n][ny]
	End
	If Trim(aHeader[ny][2]) == "L2_TES"
		cTES  := aCols[n][ny]
	End
	If Trim(aHeader[ny][2]) == "L2_LOCAL"
		cLocal   := aCols[n][ny]
	End
	If Trim(aHeader[ny][2]) == "L2_LOTECTL"
		cLoteCtl := aCols[n][ny]
	End
	If Trim(aHeader[ny][2]) == "L2_NLOTE"
		cNLote   := aCols[n][ny]
	End
	If Trim(aHeader[ny][2]) == "L2_LOCALIZ"
		cLocaliza := aCols[n][ny]
	End
	If Trim(aHeader[ny][2]) == "L2_NSERIE"
		nPosSerial:=ny
	EndIf
Next nY

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A rotina abaixo apenas verifica na pilha de chamda se estamos          ³
//³ utilizando o "LJ010ATE" pois esta rotina e chamada em todos os momemtos³
//³ da venda e devolucao. A nao ser no caso em que a serial devolvida      ³
//³ venha a perterncer a outra loja, neste caso pode ser qualquer numero de³
//³ serie e localizacao existente.                                         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !Empty(cProcName)
	If cProcName $ "LJ010ATE"
		Exit
	Else
		ii++
		cProcName := UPPER(AllTrim(ProcName(ii)))
	Endif
End

do case
	case acols[n][(Len(aHeader)+1)]
		lRet = .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Caso o parametro MV_LOCALIZ (localiza) estiver Sim |
	//³	entende-se que trabalha com o conceito			   ³
	//³	de Localizacao.                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Case !localiza(cProduto)                        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Legislacao El Salvador:                     ³
		//³Na mesma venda, nao repete o numero de serie³
		//³ja registrado no aCols                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If cPaisLoc == "SAL" .AND. SB1->(FieldPos("B1_CONTSER")) > 0
			If !Empty(cNSerie) 
				If SB1->B1_CONTSER == "1"
					For nX := 1 TO Len(aCols)    // Serial ja utilizaca
						lDeletados := aCols[nX][(Len(aHeader)+1)]
						If !(lDeletados) .AND. (nX <> n)
							If aCols[nX][nPosSerial] == cNSerie   
								//Numero de Serie ja utilizada nesta venda
								MsgAlert(STR0169)
								lRet := .F.
							EndIf                               
						EndIf
					Next nX
	            Else
					M->L2_NSERIE:=Space(20)
	            EndIf
	        EndIf		
		Else    		
			M->L2_NSERIE:=Space(20)           
   		EndIf

	case Empty(cLocal)                                 // Não Esta preenchido
		// STR0107 "Digitaçäo do Almoxarifado e Obrigatória..."
		MsgAlert(STR0107)
		lRet = .F.
	case !A410ValTES(cTes)                             // Tes incorreto
		//A funcao Acima ja traz a mensagem
		//MsgAlert("TES nao permite baixa do estoque...",)
		lRet = .F.
	case ! Empty(cNSerie) .AND. nQtdVen <> 1       // Quantidade = 1
		// str0098 "A Quantidade por serial deve ser igual a 1..."
		MsgAlert(STR0098)
		lRet = .F.
	case ! Empty(cNSerie)
		for w1 = 1 to Len(aCols)    // Serial ja utilizaca
			lDeletados := acols[w1][(Len(aHeader)+1)]
			if !(lDeletados) .AND. (w1 <> n)
				if aCols[w1][nPosSerial] == cNSerie   // Deve validar com relacao aos outros campos
					// esta validacao sobre o mesmo campo causa erro pois o vesmo somente e atualizado apos o valid
					// str0099 "Numero de Serial já foi utilizada...em outro item deste mesmo Pedido..."
					MsgAlert(STR0099)
					lRet = .F.
				endif
			endif
		next w1
		
		// Se for Troca de Outra Loja
		If cProcName # "LJ010ATE"
			
			DBSelectArea("SBF")
			DBSetOrder(3)
			If DbSeek(xFilial()+cNSerie)
				// str0108 "Serial Pertence a outro Produto da Loja..."
				MsgAlert(STR0108)
				lRet = .F.
			endif
			
		Else	// Caso contrario
			
			DBSelectArea("SBF")
			DBSetOrder(3)
			// Serial esta Disponivel
			If DbSeek(xFilial()+cNSerie)
				do case
					case SBF->BF_PRODUTO  <> cProduto
						// str0100 "N£mero de s‚rie pertence a outro produto... Produto: "
						MsgAlert(STR0100+SBF->BF_PRODUTO)
					case SBF->BF_LOCAL    <> cLocal
						// str0102 "Rever Localizaçäo do Produto... Local: "
						MsgAlert(STR0102+SBF->BF_LOCAL)
					case SBF->BF_LOCALIZ  <> clocaliza
						// str0103 "Rever Localizaçäo do Produto... Localizaçäo: "
						MsgAlert(STR0103+SBF->BF_LOCALIZ)
					case SBF->BF_NUMLOTE  <> cNLote .AND. Rastro(cProduto, 'S')
						// str0104 "Rever Localizaçäo do Produto... Lote: "
						MsgAlert(STR0104+SBF->BF_NUMLOTE)
					case SBF->BF_LOTECTL  <> cLotectl
						// str0105 "Rever Localizaçäo do Produto... Sub-Lote: "
						MsgAlert(STR0105+SBF->BF_LOTECTL)
				endcase
			Else
				// str0106 "Näo existe este Numero de Serial disponivel p/ uso..."
				MsgAlert(STR0106)
				lRet = .F.
			endif
		EndIf
Endcase

Return (lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj010Ver  ³ Autor ³ Vendas Clientes       ³ Data ³ 25.05.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica na Alteracao do Orcamento se Serial continua       ³±±
±±³          ³disponivel para uso.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Ver()
Local cAlias     := Alias()
Local nRecno     := Recno()
Local nOrder     := IndexOrd()
Local lReturn    := .F.
Local cNumRes    := ""
Local cProduto   := SL2->L2_PRODUTO
Local nQtdVen    := SL2->L2_QUANT
Local cNSerie    := SL2->L2_NSERIE
Local cLocal     := SL2->L2_LOCAL
Local cLoteCtl   := SL2->L2_LOTECTL
Local cNlote     := SL2->L2_NLOTE
Local cLocaliza  := SL2->L2_LOCALIZ
Local nSaldo     := SldAtuEst(cProduto,cLocal,nQtdVen,cLoteCtl,cNlote,cLocaliza,cNSerie,cNumRes)

If localiza(cProduto)  .AND. ! Empty(cNSerie)
	If nQtdVen <> 1 .OR. nSaldo < 1
		RecLock("SL2",.F.,.T.)
		Dbdelete()
		MSUNLOCK()
		lReturn := .T.
	endif
endif

DBSelectArea(cAlias)
DBSetOrder(nOrder)
dbgoto(nRecno)

Return(lReturn)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³Lj010VlSer³ Autor ³ Vendas Clientes       ³ Data ³ 11.10.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Validar a serie da Fatura                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA010B                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj010VlSer( cSerie, cNumNota, lSeqEspecie )
Local lRet 			:= .T.
Local aArea			:=   GetArea()
Local lNotaManual  	:= If(Type("lNFManual")<>"U",lNFManual,.F.)
Local nTamL1_DOC   	:= TamSx3("L1_DOC")[1]        // Tamanho do campo L1_DOC

DEFAULT lSeqEspecie  := .F.

If !lNotaManual
   DBSelectArea("SX5")
   DBSetOrder(1)
	If lSeqEspecie
	   DbSeek(xFilial()+"AC"+"NF "+cSerie)
	Else   
       DbSeek(xFilial()+"01"+cSerie)
    EndIf   
    If ! Found()
	   Help(" ",1,"LJ010SERIE")
	   lRet:=.F.
	EndIf   
	cNumNota := PadR(AllTrim(X5Descri()),nTamL1_DOC)
    RestArea(aArea)	
EndIf

Return( lRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ Lj010NFisca ³ Autor ³ Vendas Clientes    ³ Data ³ 11.10.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Validar o n£mero da Fatura                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA010B                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj010NFisca(cNFiscal,cPreNF,cSecNF,cSerie)
Local lRet 			:= .T.        
Local lReutiliza    := SuperGetMV("MV_USAMNUM",,.T.)
Local cTipContNF	:= If(lFiscal,SuperGetMV("MV_CONTNFI",,"I"),SuperGetMV("MV_CONTNF"))   
Local aArea			:= GetArea()
Local nTamL1_SERIE	:= TamSx3("L1_SERIE")[1]	// Tamanho do campo L1_SERIE
Local nTamL1_DOC    := TamSx3("L1_DOC")[1]     // Tamanho do campo L1_DOC

cNFiscal := If(cNFiscal== NIL ,"",cNFiscal)
cPreNF   := If(cPreNF  == NIL ,"",cPreNF)
cSecNF   := If(cSecNF  == NIL ,"",cSecNF)
cSerie   := If(cSerie  == NIL ,Space(nTamL1_SERIE),cSerie)

cNFiscal := PadR(cNFiscal,nTamL1_DOC)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Consiste duplicidade de digitacao de Nota Fiscal.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSelectArea("SF2")
DBSetOrder(1)

If Empty( cNFiscal)
	Help(" ",1,"A467VAZIO")
	lRet := .F.
Else
	DbSeek(xFilial("SF2")+cNFiscal+cSerie)
	If Found()
		Help(" ",1,"A467EXIST")
		lRet := .F.
	EndIf
EndIf

If lRet
   DBSelectArea("SF3")
   DBSetOrder(5)
   If DbSeek( xFilial("SF3")+cSerie+cNFiscal)
	  While !Eof() .AND. (xFilial("SF3")+cSerie+cNFiscal) == (SF3->F3_FILIAL+SF3->F3_SERIE+SF3->F3_NFISCAL)
		If If(cTipContNF=="I",Alltrim(SF3->F3_ESPECIE)$"NF|FT",.T.)
		   If !Empty(SF3->F3_DTCANC) .AND. !lReutiliza
		      Help(" ",1,"EXISTSF3")  //Ja existe um registro no Livro Fiscal com
		      lRet  := .F.            //mesmo numero e serie. Pelo parametro MV_USAMNUM
		   EndIf                      //nao eh possivel reutilizar este mesmo numero.
		Endif
		dbSkip()
	  End
   EndIf
EndIf

If lRet
	If (ExistBlock("LJ010SER"))
		lRet := ExecBlock("LJ010SER",.F.,.F.,{cSerie,cNFiscal})
	EndIf
Endif
RestArea(aArea)

Return( lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Lj010Zera   ³ Autor ³ Vendas Clientes    ³ Data ³ 12/10/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Agrega ceros a la izquierda de la variable que se ingresa  ³±±
±±³          ³ como parametro. Para ser usada en las entradas de ciertos  ³±±
±±³          ³ campos                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  Lj010Zera( @cCaptura )                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja010B                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010Zera(cCaptura)

If !Empty(cCaptura)
	cCaptura:=StrZero(val(cCaptura),Len(cCaptura))
Endif   

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Lj010ImpCli ³ Autor ³Vendas Clientes        ³ Data ³ 12/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Imprimir o codigo, descricao e status da analise de credito  ³±±
±±³          ³ do cliente no rodape da tela da Venda Balcao.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ030Nivel(ExpC1,ExpC2,ExpN3,ExpC4,ExpL5)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do cliente para busca/exibicao no rodape      ³±±
±±³          ³ ExpC2 = Codigo da loja para buscar no cadastro de cliente    ³±±
±±³          ³ ExpN3 = Numero do folder que a funcao esta sendo chamada     ³±±
±±³          ³ ExpC4 = Descricao da analise de credito do cliente           ³±±
±±³          ³ ExpL5 = Indica se eh um novo orcamento para buscar a status  ³±±
±±³          ³         de analise de credito do cliente padrao.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Venda Balcao (LOJA010A, LOJA010B, LOJXFUNB)                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ010ImpCli( cCodCli, cCodLoj, nFolder, cMotivo )
Local oFonte

SA1->( DBSetOrder(1) )
SA1->( DbSeek( xFilial( "SA1" ) + cCodCli + cCodLoj ) )

DEFINE FONT oFonte NAME "Arial" BOLD

If oNomeCli # NIL
	oNomeCli:Hide()
EndIf

// Se o motivo nao esta preenchido, chama a funcao de analise
// de credito para preenchelo.
// Caso o motivo esteja preenchido, quer dizer que esta funcao jah esta
// sendo chamada da funcao LjCreCli, e nao chama a mesma novamente.
@ 136,02 SAY oNomeCli VAR SA1->( RTrim( A1_COD ) + ' - ' + RTrim( A1_NOME ) ) + ' - ' +;
 If( cMotivo == NIL, SA1->( LJ010ImpStatus( A1_COD, A1_LOJA ) ), cMotivo );
SIZE 290,08 OF oFolder:aDialogs[nFolder] PIXEL FONT oFonte COLOR CLR_HBLUE

oNomeCli:Show()

Return( .T. )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Lj010ImpStatus ³ Autor ³Vendas Clientes     ³ Data ³ 02/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Buscar o status da analise de credito do cliente.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ010ImpStatus(ExpC1,ExpC2)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do cliente para criterio da analise de credito³±±
±±³          ³ ExpC2 = Codigo da loja do cliente para analise de credito    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA010B - Funcao LJ010ImpCli()                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ010ImpStatus( cCliente, cLoja )
Local cStatus

cStatus := ""

LjCreCli( cCliente, cLoja, , , , @cStatus )

Return( cStatus )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CheckAcols     ³ Autor ³Vendas Clientes     ³ Data ³ 28/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se houve autotecao na Acols                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CheckAcols(ExpA1,ExpA2,ExpL3)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Vetor com o cabecario da aCols.                      ³±±
±±³          ³ ExpC2 = Vetor om o conteudo da aCols.                        ³±±
±±³          ³ ExpC3 = Numero do orcamento.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA010B                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION CheckAcols( aHead, aCols, cNumOrc)
Local lRetValue := .F.
Local nPos
Local nCount

STATIC aTemp
STATIC cOrcTemp

If ValType( cOrcTemp ) == "U" .OR. cOrcTemp <> cNumOrc
   aTemp     := AClone( aCols )
   cOrcTemp  := cNumOrc
ElseIf ValType( aTemp ) <> "U" .AND. cOrcTemp == cNumOrc
   If Len( aCols ) == Len( aTemp )
      FOR nPos := 1 TO Len( aCols )
         FOR nCount := 1 TO Len( aCols[ nPos ] ) -1
            If ALLTRIM( aHead[ nCount ][2] ) <> "L2_VALISS" .AND. ;
               ALLTRIM( aHead[ nCount ][2] ) <> "L2_BASEICM".AND. ;
			   If(cPaisLoc <> "BRA",SubStr(aHead[ nCount ][2],1,9) <> "L2_BASIMP" .AND.;                
                                     SubStr(aHead[ nCount ][2],1,9) <> "L2_VALIMP" .AND.;               
                                     SubStr(aHead[ nCount ][2],1,9) <> "L2_ALQIMP" ,.T.) 

               If aCols[ nPos ][ nCount ] <> aTemp[ nPos ][ nCount ]
                  nCount    := Len( aCols[ nPos ] ) -1
                  nPos      := Len( aCols )
                  aTemp     := AClone( aCols )
                  lRetValue := .T.
               EndIf
            EndIf
         NEXT nCount
      NEXT nPos
      If lRetValue
         aTemp := AClone( aCols )
      EndIf
   ElseIf Len( aCols ) <> Len( aTemp )
      aTemp     := AClone( aCols )
      lRetValue := .T.
   EndIf
Else
   aTemp := AClone( aCols )
EndIf

RETURN( lRetValue )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Lj010RegFisc   ³ Autor ³Vendas Clientes     ³ Data ³ 05/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Mostra a tela para selecionar o Registro Fiscal do cliente u-³±±
±±³          ³ tilizado na impressao do documento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj010RegFisc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Codigo do cliente                                     ³±±
±±³          ³ ExpC2: codigo da loja                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA010B                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010RegFisc(cCliente,cLoja,oDlgLoja) 
Local oDlgReg
Local oRegFisc

If cCliente <> SuperGetMV("MV_CLIPAD") .OR. cLoja <> SuperGetMV("MV_LOJAPAD")
    //"Esta rotina somente pode ser acessada para vendas com cliente padrao."###"O codigo do cliente padrao e: "
    MsgStop(STR0141+CHR(13)+STR0142+SuperGetMV("MV_CLIPAD")+"/"+SuperGetMV("MV_LOJAPAD"))  
    Return .T.
EndIf


DEFINE MSDIALOG oDlgReg FROM 12, 14 TO 25.5, 80 TITLE STR0136; //"Tabela de Registro Fiscal"
STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF oDlgLoja
												
@ 00.3 , 01 TO 5.5,32.2 OF oDlgReg

@ 01.0 , 01.5 SAY STR0137 //"Registro Fiscal"
@ 12.0 , 69.5 MSGET oRegFisc VAR cRegFisc VALID Lj010VldRF() OF oDlgReg SIZE 70,10 F3 "SLU" PIXEL
				
@ 02.0 , 01.5 SAY STR0143 //"Nome"
@ 25.0 , 69.5 MSGET cNomeRF SIZE 185,10 OF oDlgReg PIXEL 

@ 03.0 , 01.5 SAY STR0138 //"Endereco"
@ 37.0 , 69.5 MSGET cEnderRF SIZE 175,10 OF oDlgReg PIXEL 

@ 04.0 , 01.5 SAY STR0139 //"Telefone"
@ 49.0 , 69.5 MSGET cTelefRF SIZE 50,10 OF oDlgReg PIXEL 

@ 05.0 , 01.5 SAY STR0140 //"Atividade"
@ 61.0 , 69.5 MSGET cAtivRF SIZE 165,10 OF oDlgReg PIXEL 
					
DEFINE SBUTTON FROM 84,103 TYPE 1 ACTION (lCredFisc:=!Empty(cRegFisc),oDlgReg:End()) ENABLE OF oDlgReg

DEFINE SBUTTON FROM 84,136 TYPE 2 ACTION (oDlgReg:End()) ENABLE OF oDlgReg
						
ACTIVATE MSDIALOG oDlgReg 

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Lj010VldRF     ³ Autor ³Vendas Clientes     ³ Data ³ 05/12/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Mostra os dados do cliente de endereco, telefone e atividade ³±±
±±³          ³ ao digitar o Registro Fiscal                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj010VldRF()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA010B                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj010VldRF()
Local lRet  		 := .T.
Local nTamLU_NOME	 := TamSX3("LU_NOME")[1]		// Tamanho do campo LU_NOME
Local nTamLU_END	 := TamSX3("LU_END")[1]		// Tamanho do campo LU_END
Local nTamLU_TEL	 := TamSX3("LU_TEL")[1]		// Tamanho do campo LU_TEL
Local nTamLU_ATIVIDA := TamSX3("LU_ATIVIDA")[1]	// Tamanho do campo LU_ATIVIDA

If !Empty(cRegFisc)
   SLU->(DBSetOrder(1))
   If SLU->(DbSeek(xFilial("SLU")+cRegFisc))
      cNomeRF   := SLU->LU_NOME   
      cEnderRF  := SLU->LU_END
      cTelefRF  := SLU->LU_TEL
      cAtivRF   := SLU->LU_ATIVIDA   
   Else   
      Aviso(STR0044,STR0144,{STR0145})   //"Atenção"###"Registro Fiscal nao cadastrado!"###"Ok"
      lRet      := .F.
   EndIf  
Else
   cNomeRF   := Space(nTamLU_NOME)    
   cEnderRF  := Space(nTamLU_END)    
   cTelefRF  := Space(nTamLU_TEL)
   cAtivRF   := Space(nTamLU_ATIVIDA)	       
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Lj010ImpZero   ³ Autor ³Vendas Clientes     ³ Data ³ 02/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se o TES possui imposto com aliquota 0%             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj010ImpZero(aTesImpInf)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA010B,LOJA010D                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj010ImpZero(aTesImpInf)
Local lRet  := .F.
Local nX

For nX := 1 to Len(aTesImpInf)
   SFB->(DBSetOrder(1))
   If SFB->(DbSeek(xFilial("SFB")+aTesImpInf[nX][1]))
      If lRet := SFB->FB_ALIQ == 0
         Exit
      EndIf   
   EndIf
Next nX

Return (lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ LJ010VlrFSD º Autor ³Vendas Clientesº Data ³ 06/04/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Retornar o valor do frete                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ Venda Balcão.                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ010VlrFSD()

Return If( nVlrFSD > 0 .AND. lVlrFSD, nVlrFSD, 0 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ LJ010DesFin º Autor ³Vendas Clientesº Data ³ 15/02/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Retorna o valor do desconto financeiro                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ Venda Balcão.                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ010DesFin( cCodigo )
Local aArea 	 := GetArea()
Local nTxDescFin := 0

SE4->( DBSetOrder( 1 ) )

If SE4->( DbSeek( xFilial( "SE4" ) + cCodigo ) )
	nTxDescFin := SE4->E4_DESCFIN
EndIf

RestArea( aArea )

Return nTxDescFin

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ LJ010VlrOri º Autor ³Vendas Clientesº Data ³ 16/02/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Retorna o valor original da compra sem os descontos     º±±
±±º          ³ manual e financeiro                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ Venda Balcão.                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ010VlrOri( nVlrOri, nVlrLiq, nDescTot, nDescFin )
Local aArea := GetArea()

nVlrOri := ( nVlrLiq * 100 ) / ( 100 - nDescTot )

RestArea( aArea )

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ LJ010DesMan º Autor ³Vendas Clientesº Data ³ 16/02/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Retorna o valor do desconto manual                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ Venda Balcão.                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ010DesMan(nVlrOri,	nDescFin,	nDescLoj,	nDescPer,;
					 nDescTot)

Local aArea 		:= GetArea()   // Area atual
Local nVlrTotTmp 	:= 0           // Total com desconto financeiro em cima do valor original
Local nVlrLiqTmp	:= 0           // Total com desconto da venda sobre o valor original
Local nTamL1_DESCNF	:= TamSX3( "L1_DESCNF" )[2]	// Tamanho do campo L1_DESCNF

nVlrLiqTmp 	:= nVlrOri * ( 1 - ( nDescTot / 100 ) )
nVlrTotTmp 	:= ( nVlrOri * ( 1 - ( nDescFin / 100 ) ) )
nDescPer 	:= Round( ( ( nVlrTotTmp - nVlrLiqTmp ) / nVlrTotTmp ) * 100, nTamL1_DESCNF )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|***************************ATENCAO************************|
//³ Verifica se nao existe desconto financeiro para a venda. ³
//| Se existir, DEVE SER retornado ao valor original da venda|
//| RECALCULANDO todos os descontos (manual e financeiro)    |
//| Isso TALVEZ influencie no arredondamento.                |
//|                                                          |
//| Para testes:                                             |
//| Ficha 001662/2005                                        |
//| BOPS 80928                                               |
//|**********************************************************|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nDescFin == 0
	nDescLoj 	:= SL1->L1_DESCONT
Else
	nDescLoj 	:= NoRound(nVlrOri - ( nVlrOri * ( 1 - ( nDescPer / 100 ) ) ), nDecimais)
Endif

RestArea( aArea )

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ Lj010Sld    º Autor ³Vendas Clientesº Data ³ 04/03/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Verifica o saldo em estoque do produto                  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lLinOk: Valida se a funcao esta sendo chamada pela LinOK³±±
±±³          ³ nItem : Passa a linha do aCols que esta posicionado;    ³±±
±±³          ³ cProduto: Produto que esta sendo validado;              ³±±
±±³          ³ cLocal: Armazem que esta sendo validado;                ³±±
±±³          ³ nQtdVen: Quantidade a ser analisada no estoque;         ³±±
±±³          ³ cLoteCtl: Lote do produto                               ³±±
±±³          ³ cNLote: SubLote do Produto                              ³±±
±±³          ³ cLocaliza: Endereco do Produto                          ³±±
±±³          ³ cSerial: Numero de Serie                                ³±±
±±³          ³ nPosLote: Posicao no aHeader do campo L2_LOTECTL        ³±±
±±³          ³ nPosSlote: Posicao no aHeader do campo L2_NLOTE         ³±±
±±³          ³ nQtdeLote: Quantidade disponivel que existe de saldo    ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ Venda Balcão.                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj010Sld(	lLinOk,		nItem,		cProduto,	cLocal,;
					nQtdVen,	cLoteCtl, 	cNlote, 	cLocaliza,;
					cSerial, 	nPosLote, 	nPosSlote, 	nQtdeLote)
Local aArea 			:= GetArea()			    //Salva a area
Local lEstoq			:= .T.						//Se existe Estoque disponivel
Local nLocaliza			:= 0						//Posicao no aHeader do L2_LOCALIZ
Local nSerial			:= 0						//Posicao no aHeader do L2_NSERIE
Local nPosProd			:= 0						//Posicao no aHeader do L2_PRODUTO
Local nLocal			:= 0						//Posicao no aHeader do L2_LOCAL
Local nQtd	   			:= 0						//Posicao no aHeader do L2_QUANT
Local nTamB8_LOTECTL	:= TamSx3("B8_LOTECTL")[1]	//Tamanho do campo B8_LOTECTL
Local nTamB8_NUMLOTE	:= TamSx3("B8_NUMLOTE")[1]	//Tamanho do campo B8_NUMLOTE
Local nTamB8_PRODUTO	:= TamSx3("B8_PRODUTO")[1]	//Tamanho do campo B8_PRODUTO

If Empty(cProduto) .AND. !aCols[ nItem ][ (Len(aHeader)+1) ]
	nPosProd	:= aScan(aHeader,{|x| Alltrim(x[2])=="L2_PRODUTO"})
	nLocal		:= aScan(aHeader,{|x| Alltrim(x[2])=="L2_LOCAL"})
	nQtd		:= aScan(aHeader,{|x| Alltrim(x[2])=="L2_QUANT"})
	nPosLote	:= aScan(aHeader,{|x| Alltrim(x[2])=="L2_LOTECTL"})
	nPosSlote	:= aScan(aHeader,{|x| Alltrim(x[2])=="L2_NLOTE"})
	nLocaliza	:= aScan(aHeader,{|x| Alltrim(x[2])=="L2_LOCALIZ"})
	nSerial		:= aScan(aHeader,{|x| Alltrim(x[2])=="L2_NSERIE"}) 
	
	cProduto	:= aCols[nItem][nPosProd]
	cLocal		:= aCols[nItem][nLocal]	
	nQtdVen		:= aCols[niTem][nQtd]
	If !__lPyme
	   cLoteCtl	    := aCols[nItem][nPosLote]
	   cNLote		:= aCols[nItem][nPosSlote]
	   cLocaliza	:= aCols[nItem][nLocaliza]
	EndIf   
	cSerie		:= aCols[nItem][nSerial]
Endif

If SuperGetMV("MV_RASTRO") == "S" .AND. !aCols[ nItem ][ (Len(aHeader)+1) ]
	DBSelectArea("SB1")
	SB1->( DBSetOrder(1) )
	SB1->( DbSeek( xFilial() + cProduto) )
	IF  SB1->B1_RASTRO == "N" .OR. SB1->B1_RASTRO == Space(01)
		If nPosLote > 0 .AND. nPosSlote > 0
			aCols[nItem][nPosLote]  := CriaVar("L2_LOTECTL")
			aCols[nItem][nPosSlote] := CriaVar("L2_NLOTE")
		EndIf
		cLoteCtl := CriaVar("L2_LOTECTL")
		cNLote   := CriaVar("L2_NLOTE")
	Else
		If Empty(cLoteCtl)
			nQtdeLote := SldAtuEst(cProduto,cLocal,nQtdVen)
			If nQtdeLote < nQtdVen
				// "Saldo Insuficiente", "Não há saldo disponível no lote " "Saldo Disponível: "
				If lLinOk
					Aviso(STR0155, STR0156+cLoteCtl+Chr(10)+STR0157+AllTrim(Str(nQtdeLote)), {"Ok"})
				Endif
				lEstoq	:= .F.
			EndIf
		Else
			cLoteCtl := Padr(cLoteCtl,nTamB8_LOTECTL)
			cNLote	 := Padr(cNLote,nTamB8_NUMLOTE)
			cProduto := Padr(cProduto,nTamB8_PRODUTO)
		
			DBSelectArea("SB8")
			SB8->( DBSetOrder(2) )
			SB8->( DbSeek(xFilial()+cNLote+cLoteCtl+cProduto) )
			If SB8->( Eof() )
				If lLinOk
					MsgAlert(STR0124,STR0044)
				Endif
				lEstoq	:= .F.
			Else
				nQtdeLote := SldAtuEst(cProduto,cLocal,nQtdVen,cLoteCtl,cNlote,cLocaliza,cSerial,"")
				If nQtdeLote < nQtdVen
					// "Saldo Insuficiente", "Não há saldo disponível no lote " ###/### "Saldo Disponível: "
					If lLinOk
						Aviso(STR0155, STR0156+cLoteCtl+" / "+cNlote+Chr(10)+STR0157+AllTrim(Str(nQtdeLote)), {"Ok"})
					Endif
					lEstoq	:= .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIF

RestArea( aArea )

Return(lEstoq)
