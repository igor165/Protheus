#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"



STATIC lA103Rat :=  FindFunction("A103GRatIr")
/*
MaFisIR -Alexandre Lemes -06/11/2012
Calculo do IR pessoa Fisica e Juridica
*/
Function FISXIR(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cExecuta, lIRRFSemDu,dVencReal,lVisual,aUltPesq)

Local aIRprg    := {}
Local cPessoa	:= Iif(Len(Alltrim(aNfCab[NF_CNPJ]))< 14,"F","J")
Local cWhere    := ""
Local cCliFor   := aNfCab[NF_CODCLIFOR]
Local cLoja     := aNfCab[NF_LOJA]
Local nAliquota	:= aNfCab[NF_ALIQIR]
Local nSomaIRF  := 0
Local nX        := 0
Local nDebDep   := 0
Local nSldDep   := 0
Local lUsaTbPrg := .F.
Local lVldBseIR := .T.
Local lCtrAuto  := aSX6[MV_CTRAUTO] .And. aNfCab[NF_TIPONF] == "C" .And. aNfCab[NF_TPCOMP] == "F" .And. !Empty(aNfCab[NF_NATUREZA])
Local lTribGen 	:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_IR)
Local nPosTgIR	:= 0

#IFNDEF TOP
	Local dDtSeek
	Local bDataImp
#ENDIF

DEFAULT dVencReal := dDataBase
DEFAULT cExecuta  := "BSE|ALQ|VLR"
DEFAULT lVisual	  := .F.


IF !lTribGen //Recebe cálculo do configurador

	//Define BASE do IRRF - IT_BASEIRR
	If "BSE" $ cExecuta

		aNfItem[nItem][IT_BASEIRR] := 0

		If aPE[PE_MAFISBIR]
			lVldBseIR := ExecBlock( "MAFISBIR",.F.,.F.,{aNfItem[nItem,IT_TES],aNfItem[nItem,IT_PRODUTO],aNfCab[NF_CLIFOR],aNfCab[NF_OPERNF],aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA]})
		EndIf

		If lVldBseIR .And. (aNFItem[nItem][IT_TS][TS_DUPLIC] == "S" .Or. lIRRFSemDu) .And. !Empty(aInfNat[NT_CODIGO]) .And. ( aInfNat[NT_CALCIRF] == "S" .Or. aSX6[MV_IRSEMNT] )

			If aNfItem[nItem][IT_PRD][SB_IRRF] == "S" .Or. lCtrAuto .Or. (aNfCab[NF_OPIRRF] == "EP" .And. aNfCab[NF_RECIRRF] == "1" .And. !aSX6[MV_RETEMPU])
				//O parametro MV_CTRAUTO define se para notas fiscais de complemento de frete deve ser considerado as informacoes
				//de IRRF e INSS (calculo e reducao) da natureza ou do cad de produtos. .T.= Natureza - .F.= Produto (DEFAULT)
				//MV_RETEMPU Define a forma de calculo de retenção para empresas publicas, caso esteja = .T. passará a validar informações dos campos de retenção do cadastro de produtos e não mais do cadastro de clientes. 
				aNfItem[nItem][IT_REDIR] := aNfItem[nItem][IT_PRD][SB_REDIRRF]

				If (Empty(aNfItem[nItem][IT_REDIR]) .And. !Empty(aNfCab[NF_NATUREZA]))
					If aInfNat[NT_BASEIRF] > 0
						aNfItem[nItem][IT_REDIR] := aInfNat[NT_BASEIRF]
					ElseIf aInfNat[NT_IRRFCAR] == "S" .And. aInfNat[NT_BASEIRC] > 0
						aNfItem[nItem][IT_REDIR] := aInfNat[NT_BASEIRC]
					EndIf
				EndIf

				If lCtrAuto .Or. ( Empty(aNfItem[nItem][IT_REDIR]) .And. !Empty(aNfCab[NF_NATUREZA]) )
					aNfItem[nItem][IT_REDIR] := aInfNat[NT_BASEIRF]
				EndIf

				aNfItem[nItem][IT_BASEIRR] := aNfItem[nItem][IT_TOTAL]

				If aNFItem[nItem][IT_TS][TS_DESCOND] == "1"	//Incluir o valor do desconto na base de IRRF
					aNfItem[nItem][IT_BASEIRR] := aNfItem[nItem][IT_BASEIRR] +aNfItem[nItem][IT_DESCONTO]
				EndIf

				//Indica se o valor do IPI deve compor a base de calculo do PIS/COFINS de ST.
				//1=Sim (Compoe) e 2=Nao(Nao Compoe)
				If aNFItem[nItem][IT_TS][TS_IPIPC]=="2"
					aNfItem[nItem][IT_BASEIRR] -= aNfItem[nItem][IT_VALIPI]
				Endif

				//Verifica se o valor do ICMS Solidario esta agregado ao valor total
				If !(aNFItem[nItem][IT_TS][TS_INCSOL]$"A,N,D")
					aNfItem[nItem][IT_BASEIRR] -= aNfItem[nItem][IT_VALSOL]
				Endif

				//Agrega o Valor do ICMS Retido - Somente para Empresa Publica
				If aNFItem[nItem][IT_TS][TS_DBSTIRR] == "1" .And. (aNFCab[NF_OPIRRF] == "EP" .Or. (aSX6[MV_ISPPUBL] == "1" .And. aNfCab[NF_OPERNF] == "E"))
					aNfItem[nItem][IT_BASEIRR] += aNfItem[nItem][IT_VALSOL]
				Endif

				//O INSS devera ser deduzido da base do IR e nao do valor dos
				//servicos. Portanto, quando ha reducao na base de calculo, primeiro
				//efetua-se a reducao e depois a deducao do INSS.
				aNfItem[nItem][IT_BASEIRR] := aNfItem[nItem][IT_BASEIRR] * IIf( aNfItem[nItem][IT_REDIR] > 0 , aNfItem[nItem][IT_REDIR] / 100 , 1 )
				If !Len(AllTrim(aNFCAB[NF_CNPJ])) == 14
					aNfItem[nItem][IT_BASEIRR] := IIf(( aSX6[MV_INSIRF]=="1"),aNfItem[nItem][IT_BASEIRR]-aNfItem[nItem][IT_VALINS],aNfItem[nItem][IT_BASEIRR])
				Endif

				// Verificar se Fornecedor eh Pessoa Fisica
				// - Se Nao possui tratamento de base redutora IRPF
				// 	* Para este caso, nao calcular ou gravar o IRPF
				// - Se possui tratamento de base redutora IRPF
				// 	* Para este caso, nao zero a base de IRPF
				//Se nao possui tratamento de base redutora de IRRF

				// Chamado TQMMO9 - Comentado trecho abaixo para que a base do IR nao seja zerada quando o calculo for na baixa (aNfCab[NF_MODIRF] == "2").
				// Se a base for zerada neste ponto, o calculo da retenção na baixa do titulo no financeiro sera feito pelo valor total da nota/titulo
				// e se houver itens que não calculam IR na NF o valor sera calculado incorretamente, pois o valor destes itens nao deve compor a base.


				//Calculo da Base do IR com desconto de DEPENDENTES por item Chamado SCHLLN 29/12/2009
				If  aNfCab[NF_TPCLIFOR] == "F" .And. aNfItem[nItem][IT_BASEIRR] > 0 .And. cPessoa == "F"  .And. aNfCab[NF_NUMDEP] > 0 .And. aPos[FP_D1_SLDDEP]

					dbSelectArea("SD1")
					nSldDep  := ( aSX6[MV_TMSVDEP] * aNfCab[NF_NUMDEP])
					#IFDEF TOP
						cWhere := ""
						If aSX6[MV_ACMIRPF] == "2" //1 = Emissao 2= Vencimento Real 3=Data Contabilizacao
							cWhere += "%SE2.E2_VENCREA  BETWEEN '"+Dtos(FirstDay(dDataBase))+"' AND '"+Dtos(LastDay(dDataBase))+"' AND%"
						ElseIf aSX6[MV_ACMIRPF] == "1"
							cWhere += "%SE2.E2_EMISSAO  BETWEEN '"+Dtos(FirstDay(dDataBase))+"' AND '"+Dtos(LastDay(dDataBase))+"' AND%"
						Else
							cWhere += "%SE2.E2_EMIS1  BETWEEN '"+Dtos(FirstDay(dDataBase))+"' AND '"+Dtos(LastDay(dDataBase))+"' AND%"
						EndIf

						BeginSql Alias "MaTbDepPF"
							SELECT	SUM(D1_SLDDEP) SLDDEP
							FROM %Table:SE2% SE2,%Table:SF1% SF1,%Table:SD1% SD1
							WHERE
							SE2.E2_FILIAL  = %xFilial:SE2% AND
							SE2.E2_FORNECE = %Exp:cCliFor% AND
							SE2.E2_LOJA    = %Exp:cLoja% AND
							SF1.F1_FILIAL  = %xFilial:SF1% AND
							SE2.E2_PREFIXO = SF1.F1_PREFIXO AND
							SE2.E2_NUM     = SF1.F1_DOC AND
							SE2.E2_FORNECE = SF1.F1_FORNECE AND
							SE2.E2_LOJA    = SF1.F1_LOJA AND
							SE2.E2_EMISSAO = SF1.F1_EMISSAO AND
							SF1.F1_FILIAL  = SD1.D1_FILIAL AND
							SF1.F1_SERIE   = SD1.D1_SERIE AND
							SF1.F1_DOC     = SD1.D1_DOC AND
							SF1.F1_FORNECE = SD1.D1_FORNECE AND
							SF1.F1_LOJA    = SD1.D1_LOJA AND
							%exp:cWhere%
							SD1.D1_FILIAL = %xFilial:SD1% AND
							SD1.D1_SLDDEP > 0  AND
							SE2.%notdel% AND
							SF1.%notdel% AND
							SD1.%notdel%
						EndSql

						dbSelectArea("MaTbDepPF")
						While !(MaTbDepPF->(Eof()))
							nDebDep  += SLDDEP
							MaTbDepPF->(dbSkip())
						EndDo
						MaTbDepPF->(dbCloseArea())
					#ELSE
						aArea := GetArea()
						For nX := 1 to Day(LastDay(dDataBase))
							dbSelectArea("SE2")
							If aSX6[MV_ACMIRPF] == "2"
								dDtSeek  := Dtos(Ctod(StrZero(nX)+"/"+SubStr(Dtoc(dVencReal),4,Iif(Len(Dtoc(dVencReal)) == 10, 7, 5))))
								bDataImp := {||SE2->E2_VENCREA}
								SE2->(dbSetOrder(3))
							Else
								dDtSeek := Dtos(Ctod(StrZero(nX)+"/"+SubStr(Dtoc(dDataBase),4,Iif(Len(Dtoc(dDataBase)) == 10, 7, 5))))
								bDataImp := Iif( aSX6[MV_ACMIRPF] == "1"  ,  {||SE2->E2_EMISSAO} , {||SE2->E2_EMIS1} )
								SE2->(dbSetOrder(5))
							EndIf
							If SE2->( MsSeek(xFilial("SE2") + dDtSeek + aNfCab[NF_NREDUZ] , .T. ) )
								Do While SE2->(!Eof()) .And. xFilial("SE2") == SE2->E2_FILIAL .And. Dtos(Eval(bDataImp))==dDtSeek .And. SE2->E2_NOMFOR == aNfCab[NF_NREDUZ]
									DbSelectArea("SD1")
									SD1->(dbSetOrder(1))//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
									If SD1->(MsSeek(xFilial("SD1")+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA))
										Do While SD1->(!Eof())
											If SD1->D1_SLDDEP > 0
												nDebDep  += SD1->D1_SLDDEP
											Endif
											SD1->(dbSkip())
										EndDo
									Endif
									SE2->(dbSkip())
								EndDo
							EndIf
						Next nX
						RestArea(aArea)
					#ENDIF

					If GdFieldPos("D1_SLDDEP") > 0  // Alemes refazer, retirar acols Chamado SCHLLN 29/12/2009
						nSldDep:=nSldDep-nDebDep
						aCols[nItem][GdFieldPos("D1_SLDDEP")]:= 0
						If aNfItem[nItem][IT_BASEIRR]>0
							For nX :=1 To Len(aCols)
								If !aCols[nX][Len(aCols[nX])]//Somente linhas nao deletadas
									nSldDep -= aCols[nX][GdFieldPos("D1_SLDDEP")]
								Endif
							Next nX
							If nSldDep > 0
								If aNfItem[nItem][IT_BASEIRR] > nSldDep
									aNfItem[nItem][IT_BASEIRR] -= nSldDep
									If GdFieldPos("D1_SLDDEP") > 0
										aCols[nItem][GdFieldPos("D1_SLDDEP")]:= nSldDep
									EndIf
								Else
									aCols[nItem][GdFieldPos("D1_SLDDEP")]:= aNfItem[nItem][IT_BASEIRR]
									aNfItem[nItem][IT_BASEIRR] := 0
								Endif
							Endif
						Endif
					EndIf

				Endif
			EndIf
		EndIf
	EndIf

	//Define ALIQUOTA IRRF - IT_ALIQIRR
	If "ALQ" $ cExecuta
		If !Empty(aNfCab[NF_NATUREZA]) .And. aNfCab[NF_MODIRF] <> "3"
			If aNfCab[NF_CLIFOR] == "C"
				Do Case
					Case aNfCab[NF_ALIQIR] > 0
						If aSX6[MV_IRSEMNT] // Parametro = .T. deixa gerar o IR mesmo que a natureza esteja para NAO calcular
							nAliquota := aNfCab[NF_ALIQIR]
						Else
							If aInfNat[NT_CALCIRF] == "S"
								nAliquota := aNfCab[NF_ALIQIR]
							EndIf
						EndIf
					Case aInfNat[NT_CALCIRF] == "S" .And. (Len(AllTrim(aNFCAB[NF_CNPJ])) == 14 .Or. aNfCab[NF_MODIRF] == "2" )
						nAliquota := IIf( aInfNat[NT_PERCIRF] > 0 , aInfNat[NT_PERCIRF] , aSX6[MV_ALIQIRF] )
					Case aInfNat[NT_CALCIRF] == "S" .And. Len(AllTrim(aNFCAB[NF_CNPJ])) <> 14
						If aNfCab[NF_MODIRF] == "4" .Or. ( aNFCab[NF_TPCLIFOR] == "X" .And. aNFCab[NF_PESSOA] == "J" )   //aNfCab[NF_MODIRF] == "4" --> Empresa Individual
							nAliquota := IIf( aInfNat[NT_PERCIRF] > 0 , aInfNat[NT_PERCIRF] , aSX6[MV_ALIQIRF] )
						Else
							lUsaTbPrg := .T.
						EndIf
				EndCase
			Else
				If aInfNat[NT_CALCIRF] == "S" .And. aNfItem[nItem][IT_BASEIRR] > 0
					If aNfCab[NF_TPCLIFOR] == "F" .And. aNfCab[NF_MODIRF] <> "2" .And. aNfCab[NF_IRPROG] <> "1"
						//--Empresa Individual OU para atender ao disposto no MAFON - 2016 - alíquotas que não fazem parte da tabela progressiva
						If aNfCab[NF_MODIRF] == "4" .OR. (cPessoa == "F" .And. aInfNat[NT_PERCIRF] > 0 .And. aNfCab[NF_IRPROG] == "2")
							nAliquota := IIf( aInfNat[NT_PERCIRF] > 0 , aInfNat[NT_PERCIRF] , aSX6[MV_ALIQIRF] )
						Else
							lUsaTbPrg := .T.
						EndIf
					ElseIf aNfCab[NF_IRPROG] == "1" .And. cPessoa == "J"
						lUsaTbPrg := .T.
					Else
						// Verificar se Fornecedor utiliza MP232
						// Para este caso, nao calcular ou gravar o IRPF
						If aPos[FP_A2_CALCIRF] .And. aPos[FP_E2_VRETIRF] .And. aPos[FP_E2_PRETIRF] .And. aPos[FP_E5_VRETIRF] .And. ;
							aPos[FP_E5_PRETIRF] .And. aNfCab[NF_MODIRF] == "2"
							nAliquota := 0
						Else
							nAliquota := IIf( aInfNat[NT_PERCIRF] > 0 , aInfNat[NT_PERCIRF] , aSX6[MV_ALIQIRF] )
						EndIf
					EndIf
				EndIf
			EndIf		
			If lUsaTbPrg
				aEval(aNfItem,{|x| nSomaIRF += IIf(!x[IT_DELETED],x[IT_BASEIRR],0)})		
				aIRprg := xFisIRFPF(aNfCab, aNFItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, aNfItem[nItem][IT_BASEIRR],nSomaIRF-aNfItem[nItem][IT_BASEIRR],Iif(lVisual,.F.,.T.),aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA],dVencReal,cPessoa,aUltPesq)
				nAliquota := aIRprg[2]
			EndIf

			// Verificar se Fornecedor pessoa juridica realiza calculo do IRR no momento da baixa.
			If aInfNat[NT_CALCIRF] == "S" .And. (cPessoa == "J" .OR. aNFCab[NF_TPCLIFOR] == "X") .And. aNfCab[NF_MODIRF] == "2"
				nAliquota := IIf( aInfNat[NT_PERCIRF] > 0 , aInfNat[NT_PERCIRF] , aSX6[MV_ALIQIRF] )
			EndIf
		EndIf

		aNfItem[nItem][IT_ALIQIRR]	:= nAliquota

	EndIf
	//Estou verificando novamente cExecuta, pois preciso da alíquota do IR pronta para que eu possa incluir na base de cálculo, ao invés de fazer uma chamada recursiva, adicionei este complemento da base de cálculo
	If "BSE" $ cExecuta .AND.  aNfItem[nItem][IT_BASEIRR] > 0 .AND. xFisGIR(nItem, aNFItem, aNfCab, "IRRF") //Verifica se deverá considerar GrossUp do IRRF
		//Esta opção significa que deverá incluir o valor do IR na base de cálculo
		aNfItem[nItem][IT_BASEIRR]	:= aNfItem[nItem][IT_VALMERC] / ( 1 - ( aNfItem[nItem][IT_ALIQIRR] / 100 ) )
	EndIF
	//Define VALOR do IRRF - IT_VALIRR
	If "VLR" $ cExecuta 

		aNfItem[nItem][IT_VALIRR] := 0

		If aNfItem[nItem][IT_ALIQIRR] <> 0 .And. aNfItem[nItem][IT_BASEIRR] > 0 .And. ( (cPessoa == "F" .And. aNfCab[NF_IRPROG] <> "2") .Or. aNfCab[NF_IRPROG] == "1" ) .And. ;
			(aNfCab[NF_CLIFOR] == "F" .Or. ( aNfCab[NF_CLIFOR] == "C" .And. aNfCab[NF_ALIQIR] == 0 ) .Or. aNfCab[NF_IRPROG] == "1" )
			lUsaTbPrg := .T.
		EndIf

		If (aNfCab[NF_CLIFOR] == "C" .And. aNFCab[NF_TPCLIFOR] == "X" .And. aNFCab[NF_PESSOA] == "J" ) .Or. ;
			(aNfCab[NF_CLIFOR] == "F" .And. aNfCab[NF_IRPROG] <> "1" .And.   aNFCab[NF_TPCLIFOR] == "X" ) //retenção de IR para operação de importação [artigos  706 e 719 do Decreto n3000, de março de 1999 (http://www.receita.fazenda.gov.br/Legislacao/rir/Livro3.htm)
			lUsaTbPrg := .F.
		EndIf

		If lUsaTbPrg
			If nSomaIRF == 0
				aEval(aNfItem,{|x| nSomaIRF += IIf(!x[IT_DELETED],x[IT_BASEIRR],0)})
				aIRprg := xFisIRFPF(aNfCab, aNFItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc,aNfItem[nItem][IT_BASEIRR],nSomaIRF-aNfItem[nItem][IT_BASEIRR],.T.,aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA],dVencReal,cPessoa,aUltPesq)
			EndIf
			If aNfCab[NF_MODIRF] <> "2"
				For nX := 1 To Len(aNFItem)
					If aNFItem[nX][IT_BASEIRR] > 0 //Somente atualiza a aliquota de IR para os itens que possuem Base de Cálculo
						aNFItem[nX][IT_ALIQIRR] := aIRprg[2]
						aNfItem[nX][IT_VALIRR]  := (aNFItem[nX][IT_BASEIRR] * (aNFItem[nX][IT_ALIQIRR] / 100)) - ((aNFItem[nX][IT_BASEIRR] / nSomaIRF) * aIRprg[3])
					EndIf
				Next nX
				//TODO verificar como fazer RatRes e It2Cab
				If aIRprg[1] > 0
					MaFisRatRes("IT_VALIRR",aIRprg[1],aIRprg[2],"IT_ALIQIRR","IT_BASEIRR",nItem)
					MaIt2Cab(nItem)
				else
					MaIt2Cab(nItem)		
				EndIf
			Else
				If aNfItem[nItem][IT_BASEIRR]- aIRprg[4] > 0
					If aPos[FP_A2_CALCIRF] .And. aPos[FP_E2_VRETIRF] .And. aPos[FP_E2_PRETIRF] .And. aPos[FP_E5_VRETIRF] .And. ;
						aPos[FP_E5_PRETIRF] .And. aNfCab[NF_MODIRF] == "2" // Se Fornecedor utiliza MP232 NAO calcular ou gravar IRPF
						aNfItem[nItem][IT_VALIRR] := 0
					Else
						aNfItem[nItem][IT_VALIRR] := aNfItem[nItem][IT_BASEIRR] * aNfItem[nItem][IT_ALIQIRR] /100
					Endif
				Else
					aNfItem[nItem][IT_VALIRR] := 0
				EndIf
			EndIf
		Else
			aNfItem[nItem][IT_VALIRR] := aNfItem[nItem][IT_BASEIRR] * aNfItem[nItem][IT_ALIQIRR] / 100
		EndIf

		MaItArred(nItem, {"IT_VALIRR"})

	EndIf
Else
    IF (nPosTgIR := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_IR})) >0  
    
        aNfItem[nItem][IT_VALIRR] := aNfItem[nItem][IT_TRIBGEN][nPosTgIR][TG_IT_VALOR]
        aNfItem[nItem][IT_BASEIRR]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIR][TG_IT_BASE]
        aNfItem[nItem][IT_ALIQIRR]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIR][TG_IT_ALIQUOTA]

    Endif

Endif

Return

/*/
MaTbIrfPF-Eduardo/Edson   -31.01.2004
Inicializa o Calculo das operacoes Fiscais
Retorno   ExpA: [1] Valor do IRPF
[2] Aliquota do IRPF
[3] Dedução  do IRPF
Parametros ExpN1 : Valor do IRPF
ExpN2 : Valor acumulado do IRPF
*/
Function xFisIRFPF(aNfCab, aNFItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, nBaseIRF, nTotIrf, lSE2, cFornece, cLoja, dVencReal, cPessoa, aUltPesq)

Local aArea     := GetArea()
Local aTabela   := {}
Local cQrySE2 	:= "'"+ xFilial("SE2") + "'"
Local cQrySD1 	:= "'"+ xFilial("SD1") + "'"
Local cQrySED 	:= "'"+ xFilial("SED") + "'"
Local aFilial	:= Iif(cPessoa == "F", {"%%","%%","%%"},{"%SE2.E2_FILIAL = "+cQrySE2+" AND%","%SD1.D1_FILIAL = "+cQrySD1+" AND%","%SED.ED_FILIAL = "+cQrySED+" AND%"})
Local aFilCnpj	:= Iif(cPessoa == "F",MatFilCalc(.F.),{})
Local cAddWhere := ""
Local cBuffer   := ""
Local nX        := 0
Local nBase     := 0
Local nAliq     := 0
Local nValor    := 0
Local nDed      := 0
Local nIsento   := 0
Local nTotTit 	:= 0
Local nTotInss	:= 0
Local nTotIrrf	:= 0
Local nVenctoPF := aSX6[MV_ACMIRPF]
Local nVenctoPJ := aSX6[MV_ACMIRPJ]   //1 = Emissao    2= Vencimento Real	3=Data Contabilizacao
Local lContrRet := aPos[FP_E2_VRETPIS] .And. aPos[FP_E2_VRETCOF] .And. aPos[FP_E2_VRETCSL] .And. aPos[FP_E2_PRETPIS] .And. aPos[FP_E2_PRETCOF] .And. aPos[FP_E2_PRETCSL]
Local lPCCBaixa := aSX6[MV_BX10925]== "1" .And. aPos[FP_E5_VRETPIS] .And. aPos[FP_E5_VRETCOF] .And. aPos[FP_E5_VRETCSL] .And. aPos[FP_E5_PRETPIS] .And. aPos[FP_E5_PRETCOF] .And. aPos[FP_E5_PRETCSL] .And. aPos[FP_E2_SEQBX] .And. aPos[FP_FQ_SEQDES]
Local dDataEmi	:=	dDataBase
Local cFilQrySE2 := ""
Local aNfProc := {}
Local oRatIRF := If(lA103Rat,A103GRatIr(),NIL)
Local cIdOrig := ""

#IFNDEF TOP
	Local nLastDay:= Day(LastDay(dDataBase))
	Local dDtSeek
	Local bDataImp
#ELSE
	Local cWhere    := ""
	Local cSepNeg   := If("|"$MV_CPNEG,"|",",")
	Local cSepProv  := If("|"$MVPROVIS,"|",",")
	Local cSepRec   := If("|"$MVPAGANT,"|",",")
#ENDIF

DEFAULT nTotIrf   := 0
DEFAULT lSE2      := .F.
DEFAULT dVencReal := dDataBase

//dDataEmi para respeitar os parametros MV_ACMIRPF e  MV_ACMIRPJ
If Type("dDEmissao") == "D" .And. !Empty(dDEmissao)
	dDataEmi	:=	dDEmissao
Endif

If FWModeAccess( "SE2" , 3 ) == "C"
	cFilOri := "E2_FILORIG"
Else
	cFilOri := "E2_FILIAL"
EndIf

// Calcula o valor do IRF ocorrido no mes
If lSE2 .And. ( !(aUltPesq[1] == dDataBase .And. aUltPesq[2] == cFornece .And. aUltPesq[3] == cLoja))

	//Define o fornecedor e loja que seram utilizados para criação 
	//da estrutura do rateio de aluguel
	If !Empty(oRatIRF)
		oRatIRF:SetForLoja(cFornece, cLoja)
	EndIf
	#IFDEF TOP
		cWhere := ""
		If cPessoa == "F" .Or. aNfCab[NF_IRPROG] == "1"
			If nVenctoPF == "2"
				//Se for no mesmo mês uso a DataBase senão uso a Data do Vencimento Real
				If Dtos(FirstDay(dVencReal))<= Dtos(dDataBase) .And. Dtos(LastDay(dVencReal))>= Dtos(dDataBase)
					cWhere += "%SE2.E2_VENCREA  BETWEEN '"+Dtos(FirstDay(dDataBase))+"' AND '"+Dtos(LastDay(dDataBase))+"' AND "
				Else
					cWhere += "%SE2.E2_VENCREA  BETWEEN '"+Dtos(FirstDay(dVencReal))+"' AND '"+Dtos(LastDay(dVencReal))+"' AND "
				EndIf
			ElseIf nVenctoPF == "1"
				cWhere += "%SE2.E2_EMISSAO  BETWEEN '"+Dtos(FirstDay(dDataEmi))+"' AND '"+Dtos(LastDay(dDataEmi))+"' AND "
			Else
				cWhere += "%SE2.E2_EMIS1  BETWEEN '"+Dtos(FirstDay(dDataBase))+"' AND '"+Dtos(LastDay(dDataBase))+"' AND "
			EndIf
		Else
			If nVenctoPJ == "2"
				If Dtos(dDataBase)==Dtos(dVencReal)
					cWhere += "%SE2.E2_VENCREA  = '" + Dtos(dDataBase) + "' AND "
				Else
					cWhere += "%SE2.E2_VENCREA  = '" + Dtos(dVencReal) + "' AND "	//Totaliza pelo vencimento real
				EndIf
			ElseIf nVenctoPJ == "1"
				cWhere += "%SE2.E2_EMISSAO  = '" + Dtos(dDataEmi) + "' AND "
			Else
				cWhere += "%SE2.E2_EMIS1  = '" + Dtos(dDataBase) + "' AND "
			EndIf
		EndIf
		cWhere += "SE2.E2_TIPO NOT IN "+FormatIn(MVABATIM,"|")+" AND "
		cWhere += "SE2.E2_TIPO NOT IN "+FormatIn(MV_CPNEG,cSepNeg)+" AND "
		cWhere += "SE2.E2_TIPO NOT IN "+FormatIn(MVPROVIS,cSepProv)+" AND "
		cWhere += "SE2.E2_TIPO NOT IN "+FormatIn(MVPAGANT,cSepRec)+" AND "
		cWhere += "SE2.E2_FATURA NOT IN ('NOTFAT') "
		If aPE[PE_MACALIRRF]
			cAddWhere := ExecBlock("MACALIRRF",.F.,.F., {cWhere} )
			If ValType(cAddWhere) == "C" .And. !Empty(cAddWhere)
				cWhere += " AND " + cAddWhere
			EndIf
		EndIf
		cWhere += " AND %"
		BeginSql Alias "MaTbIrfPF"
			SELECT E2_FILIAL,E2_VALOR,E2_IRRF,E2_BASEIRF,E2_INSS,E2_ISS,E2_SEST,E2_PRETPIS,E2_PRETCOF,E2_PRETCSL,E2_VRETPIS,E2_VRETCOF,E2_VRETCSL,
			E2_TIPO,E2_NUM,E2_PREFIXO,E2_FORNECE,E2_LOJA,E2_ORIGEM,E2_FATURA,E2_FILORIG,E2_PARCELA
			FROM %Table:SE2% SE2
			WHERE
			%exp:aFilial[1]%
			SE2.E2_FORNECE = %Exp:cFornece% AND
			SE2.E2_LOJA = %Exp:cLoja% AND
			SE2.%notdel% AND
			%exp:cWhere%
			EXISTS (
			SELECT SED.ED_CODIGO
			FROM %Table:SED% SED
			WHERE
			%exp:aFilial[3]%
			SED.ED_CALCIRF = 'S' AND
			SED.ED_CODIGO = SE2.E2_NATUREZ AND
			SE2.%notdel% AND
			SED.%notdel%)
		EndSql

		dbSelectArea("MaTbIrfPF")

		While !(MaTbIrfPF->(Eof()))
			If 	MaTbIrfPF->(E2_TIPO) == MVNOTAFIS .And. Alltrim(MaTbIrfPF->(E2_ORIGEM)) == "MATA100"

				cFilQrySE2 := Iif(cFilOri == "E2_FILIAL",MaTbIrfPF->E2_FILIAL,MaTbIrfPF->E2_FILORIG)

				If cPessoa == "F"
					aFilial[2] := "%SF1.F1_FILIAL = '" + cFilQrySE2 + "' AND%"
					If (nX := aScan(aFilCnpj,{|x| x[2] == cFilQrySE2})) == 0 .Or. ;
						Substr(aFilCnpj[nX,4],1,8) <> Substr(SM0->M0_CGC,1,8)
						dbSkip()
						Loop
					EndIf
				EndIf
			
				// Validacao para que os valores de uma NF que tenha mais de uma parcela nao sejam acumulados indevidamente.
				// Nestes casos a query na SE2 retorna mais de uma linha, porem soh preciso dos dados da SD1 uma vez...então
				// soh executo a query na SD1 uma vez.
				If aScan(aNfProc, {|x| x[1]+x[2]+x[3]+x[4]+x[5] == cFilQrySE2 + MaTbIrfPF->(E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA)}) == 0

					BeginSql Alias "TMPSD1"
						SELECT SUM(D1_BASEIRR) BASEIRR, SUM(D1_VALINS) VALINS
						FROM %Table:SD1% SD1, %Table:SF1% SF1
						WHERE
						%Exp:aFilial[2]%
						SF1.F1_DOC = %Exp:MaTbIrfPF->(E2_NUM)% AND
						SF1.F1_PREFIXO = %Exp:MaTbIrfPF->(E2_PREFIXO)% AND
						SF1.F1_FORNECE = %Exp:MaTbIrfPF->(E2_FORNECE)% AND
						SF1.F1_LOJA = %Exp:MaTbIrfPF->(E2_LOJA)% AND
						SF1.%notdel% AND
						SD1.D1_FILIAL = SF1.F1_FILIAL AND
						SD1.D1_DOC = SF1.F1_DOC AND
						SD1.D1_SERIE = SF1.F1_SERIE AND
						SD1.D1_FORNECE = SF1.F1_FORNECE AND
						SD1.D1_LOJA = SF1.F1_LOJA AND
						SD1.%notdel%
					EndSql

					nTotTit	+= BASEIRR
					dbCloseArea()

					aAdd(aNfProc, {cFilQrySE2, MaTbIrfPF->(E2_NUM), MaTbIrfPF->(E2_PREFIXO), MaTbIrfPF->(E2_FORNECE), MaTbIrfPF->(E2_LOJA)})

				EndIf
			// So executa para titulos avulsos
			// Nesse caso o valor da BASEIRF não pode ser somado com o IR novamente, por que dessa forma não bate com os mesmo calculos realizado no tirulo avulso no financeiro
			Else
				If aSX6[MV_INSIRF]=="1"
					nTotTit	+= (E2_BASEIRF - E2_INSS) + E2_ISS
				Else
					nTotTit +=  E2_BASEIRF + E2_ISS
				EndIf
				
			EndIf
			dbSelectArea("MaTbIrfPF")
			If lContrRet .And. !lPccBaixa .And. (E2_PRETPIS == " " .And. E2_PRETCOF == " " .And. E2_PRETCSL == " ")
				nTotTit	+= E2_VRETPIS+E2_VRETCOF+E2_VRETCSL
			Endif
			nTotInss += E2_INSS
			nTotIrrf += E2_IRRF

			//Verifica o valor de IR Retido por CPF
			//Rateio de IR Aluguel
			If !Empty(oRatIRF)
				cIdOrig := oRatIRF:GetIdDoc(E2_FILIAL + "|" + E2_PREFIXO + "|" + E2_NUM + "|" + E2_PARCELA + "|" + E2_TIPO + "|" + E2_FORNECE + "|" + E2_LOJA)
				oRatIRF:GetIRRetido(cIdOrig)
			EndIf

			dbSkip()
		EndDo
		MaTbIrfPF->(dbCloseArea())
		dbSelectArea("SA2")
	#ELSE
		dbSelectArea("SA2")
		dbSetOrder(1)
		MsSeek(xFilial("SA2")+cFornece+cLoja)
		dbSelectArea("SE2")
		If cPessoa == "F" .Or. aNfCab[NF_IRPROG]=="1"
			If nVenctoPF == "2"
				//Se for no mesmo mês uso a DataBase senão uso a Data do Vencimento Real
				If Dtos(FirstDay(dVencReal))<= Dtos(dDataBase) .And. Dtos(LastDay(dVencReal))>= Dtos(dDataBase)
					nLastDay := Day(LastDay(dDataBase))
				Else
					nLastDay := Day(LastDay(dVencReal))
				EndIf
				bDataImp := {||SE2->E2_VENCREA}
				dbSetOrder(3)
			ElseIf nVenctoPF == "1"
				bDataImp := {||SE2->E2_EMISSAO}
				dbSetOrder(5)
			Else// nVenctoPF == "3"
				bDataImp := {||SE2->E2_EMIS1}
				dbSetOrder(5)
			EndIf
			nStart:= 1
		Else
			If nVenctoPJ == "2"
				//Se for no mesmo dia uso a DataBase senão uso a Data do Vencimento Real
				If Dtos(dDataBase)==Dtos(dVencReal)
					nLastDay := Day(dDataBase)
				Else
					nLastDay := Day(dVencReal)
				EndIf
				nStart	:= nLastDay
				bDataImp := {||SE2->E2_VENCREA}
				dbSetOrder(3)
			ElseIf nVenctoPJ == "1"
				bDataImp := {||SE2->E2_EMISSAO}
				nLastDay := Day(dDataBase)
				nStart	:= nLastDay
				dbSetOrder(5)
			Else// nVenctoPJ == "3"
				bDataImp := {||SE2->E2_EMIS1}
				nLastDay := Day(dDataBase)
				nStart	:= nLastDay
				dbSetOrder(5)
			EndIf
		EndIf
		For nX := nStart to nLastDay
			If nVenctoPF == "2" .Or. nVenctoPJ == "2"
				dDtSeek := Dtos(Ctod(StrZero(nX)+"/"+SubStr(Dtoc(dVencReal),4,Iif(Len(Dtoc(dVencReal)) == 10, 7, 5))))
			Else
				dDtSeek := Dtos(Ctod(StrZero(nX)+"/"+SubStr(Dtoc(dDataBase),4,Iif(Len(Dtoc(dDataBase)) == 10, 7, 5))))
			EndIf
			If MsSeek(xFilial("SE2")+dDtSeek+SA2->A2_NREDUZ,.T.)
				While !Eof() .And. xFilial("SE2") == E2_FILIAL .And. Dtos(Eval(bDataImp))==dDtSeek .And. E2_NOMFOR == SA2->A2_NREDUZ
					SED->(MsSeek(xFilial("SED")+SE2->E2_NATUREZ))
					If E2_FORNECE+E2_LOJA == SA2->A2_COD+SA2->A2_LOJA .And. !(E2_TIPO $ MVABATIM+"/"+MV_CPNEG+"/"+MVPAGANT+"/"+MVPROVIS) .And. SED->ED_CALCIRF=="S" .And. !(E2_FATURA == "NOTFAT")
						nTotTit	+= E2_BASEIRF+E2_IRRF+E2_ISS+E2_SEST
						If lContrRet .And. !lPccBaixa .And. (E2_PRETPIS == " " .And. E2_PRETCOF == " " .And. E2_PRETCSL == " ")
							nTotTit	+= E2_VRETPIS+E2_VRETCOF+E2_VRETCSL
						Endif
						nTotInss += E2_INSS
						nTotIrrf += E2_IRRF

						//Verifica o valor de IR Retido por CPF
						//Rateio de IR Aluguel
						If !Empty(oRatIRF)
							cIdOrig := oRatIRF:GetIdDoc(E2_FILIAL + "|" + E2_PREFIXO + "|" + E2_NUM + "|" + E2_PARCELA + "|" + E2_TIPO + "|" + E2_FORNECE + "|" + E2_LOJA)
							oRatIRF:GetIRRetido(cIdOrig)
						EndIf

					Endif
					dbSkip()
				EndDo
			EndIf
		Next nX
	#ENDIF

	//MV_INSIRF == "1" Ja grava o valor da BASE do IRFF no E2_BSEIRF/D1_BASEIRR descontando o valor do INSS nao sendo necessario tratar o parametro nesta funcao para somar ou subtrair o INSS da base do IR
	aUltPesq:= {dDataBase,cFornece,cLoja, nTotTit ,nTotIRRF}

EndIf

nBaseIRF += aUltPesq[4]

//Tratamento para o rateio de IR Aluguel
//Define a base do IRPF que sera aplicada no calculo
If !Empty(oRatIRF)
	oRatIRF:SetBaseIr(nBaseIRF+nTotIrf)
EndIf	

// Aplica a tabela progressiva
If File("SIGAADV.IRF")
	FT_FUse("SIGAADV.IRF")
	FT_FGotop()
		While ( !FT_FEof() )
			cBuffer := FT_FReadLn()
			aadd(aTabela,{Val(SubStr(cBuffer,1,15)),Val(SubStr(cBuffer,17,6)),Val(SubStr(cBuffer,24,15))})
			FT_FSkip()
		EndDo
		FT_FUse()
		
		For nX := 1 To Len(aTabela)
			nBase := aTabela[nX,1]
			nAliq := aTabela[nX,2]
			nDed  := aTabela[nX,3]
			If nAliq == 0
				nIsento := nBase
			EndIf
			
			If nBaseIRF+nTotIrf <= aTabela[nX][1]
				Exit
			EndIf
		Next nX
		nValor := NoRound(((nBaseIRF+nTotIrf)*nAliq/100),3)-nDed-aUltPesq[5]
		nValor := Max(nValor,0)

		
		
EndIf

If !Empty(oRatIRF) .and. Len(oRatIRF:aRatIrf) > 1 .and. oRatIRF:CalcRatIr() > 0
	nValor := oRatIRF:CalcRatIr()
	nAliq := 0 
EndIF
	
RestArea(aArea)


Return({nValor,nAliq,nDed,nIsento})

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisGIR()
Verifica se deverá realizar o GrossUp do Imposto de Renda

@return   lRet 	   - Retorna se deverá ou não fazer o GrossUp do IRRF

@author Erick Gonçalves Dias
@since 17/04/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function xFisGIR(nItem, aNFItem, aNfCab, cOpcao)
Local lRet		:= .F.
Local lGrossUp	:= .F.
Default cOpcao	:= ""

/*Opções do NF_GROSSIR
0 = Sem Gross
1 = Imp. Serv. IRRF
2 = Imp. Serv. IRRF + CIDE
3 = Imp. Serv. IRRF + Valor do Serviço
*/

If cOpcao $ "ISS/VALCONT/" .AND. aNfCab[NF_GROSSIR] == "3"
	//Usuário configurou para que realize o GrossUP do IRRF também na base do ISS, por este motivo o valor do serviço é alterado, bem como valor contábil e valor da duplicata
	lGrossUp	:= .T.

ElseIf cOpcao == "DUP" .AND. aNfCab[NF_GROSSIR] $ "3|2|1" .And. aNfCab[NF_MODIRF] == "2"
	// A adição do valor de IRRF no valor do título deve ocorrer somente quando houver dedução do IRRF na baixa do título.
	lGrossUp	:= .T.

ElseIF cOpcao == "CIDE" .AND. aNfCab[NF_GROSSIR] $ "3|2"
	//Usuário configurou para que realize o GrossUP do IRRF também na base da CIDE
	lGrossUp	:= .T.
ElseIF cOpcao $ "IRRF/PISCOFIMP" .AND. aNfCab[NF_GROSSIR] $ "1/2/3"
	//Usuário configurou para que realize o GrossUP do IRRF, qualquer uma das opções fará gross up na base do IRRF e PIS e COFINS Importação
	lGrossUp	:= .T.
EndIF

//Verifica se é uma operação de serviço tomado do exterior
IF lGrossUp 							       .And. ;
   !Empty(aNfItem[nItem][IT_CODISS]) 		   .And. ;
   aNfItem[nItem][IT_ALIQIRR] 			> 0	   .And. ;
   aNFCab[NF_OPERNF] 					== "E" .And. ;
   aNFCab[NF_CLIFOR] 					== "F" .And. ;
   aNFCab[NF_TPCLIFOR] 					== "X" .And. ;
   Substr(aNfItem[nItem][IT_CF],1,1)	== "3" .And. ;
   aNFItem[nItem][IT_TS][TS_ISS] 		== "S"

	lRet := .T. //Deverá realizr o GrossUp

EndIF

Return lRet

/*MaRecIR - Cleber Stenio   -07.01.2009
  Descri‡…oRecalcula o Valor do IR qdo alterado a condicao de Pagamento
   do Titulo no MATA103X.*/
Function FISRECIR(aNfCab, aNFItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, dVencReal,aUltPesq,lIRRFSemDu)

Local nX  		:= 0
Local nAliquota := 0
Local lTabProg 	:= .F.
Local cPessoa	:= Iif(Len(Alltrim(aNfCab[NF_CNPJ]))< 14,"F","J")

DEFAULT dVencReal := dDataBase

aUltPesq := {ctod(""),"","",0,0}

aEval(aNfItem,{|x| nAliquota += IIf(!x[IT_DELETED],x[IT_ALIQIRR],0)}) // Para impedir o recalculo o IRRF quando o mesmo for informado Manualmente na NFE

IF ( cPessoa == "F" .Or. aNfCab[NF_IRPROG] == "1" ) .And. (aNfCab[NF_CLIFOR] == "F" .Or. ( aNfCab[NF_CLIFOR] == "C" .And. aNfCab[NF_ALIQIR] == 0 ) .Or. aNfCab[NF_IRPROG] == "1" )
	lTabProg := .T.
EndIf

If nAliquota > 0

		For nX := 1 To Len(aNFItem)
			IF aNFItem[nX][IT_BASEIRR] > 0
				FISXIR(aNfCab, aNFItem, nX, aPos, aInfNat, aPE, aSX6, aDic, aFunc, "VLR", lIRRFSemDu, dVencReal, , aUltPesq)
				MaItArred(nX)
			EndIf
		Next nX

		MaIt2Cab()

	ElseIf lTabProg

		For nX := 1 To Len(aNFItem)	
			IF aNFItem[nX][IT_BASEIRR] > 0	
				FISXIR(aNfCab, aNFItem, nX, aPos, aInfNat, aPE, aSX6, aDic, aFunc, "ALQ|VLR", lIRRFSemDu, dVencReal, , aUltPesq)
				MaItArred(nX)
			EndIf
		Next nX

		MaIt2Cab()

EndIf	

Return


/*/{Protheus.doc} IRConvRf
(Função responsavel por converter alteração de referencia legado em referencia do configurador)

@author Rafael Oliveira
@since 02/12/2020
@version 12.1.31

@param:	
aNFItem-> Array com dados item da nota
nItem  -> Item que esta sendo processado	
ccampo -> Campo que esta sendo alterado	
/*/
Function IRConvRf(aNfItem,nItem,ccampo)
Local cCampoConv := ""

IF cCampo == "IT_VALIRR"
    cCampoConv := "TG_IT_VALOR"		
Elseif cCampo == "IT_BASEIRR"	
    cCampoConv := "TG_IT_BASE"				
Elseif cCampo == "IT_ALIQIRR"
    cCampoConv := "TG_IT_ALIQUOTA"				
Endif

Return cCampoConv
