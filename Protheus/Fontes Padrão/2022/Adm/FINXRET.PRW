#INCLUDE "PROTHEUS.CH"
#INCLUDE "FINXRET.CH"
#INCLUDE "FWMVCDEF.CH"

Static nTamParc	:= NIL
Static oPrepSE1PC := NIL
Static oPrepSE2PC := NIL
Static lDtApur := NIL
Static lCampos := NIL
Static lFXIMPRC := ExistBlock("FXIMPRC")
Static lFXIMPPG := ExistBlock("FIMPPAG")
Static lFXIMPGR := ExistBlock("FXIMPGR")
Static lPLSTITPF	:= findFunction("PLSTITPF")
Static __lMotorRet := NIL
Static __oPreparC := NIL
Static __oPreparR := NIL
Static __oPrepCP := Nil
Static __oPreBxMR := Nil
Static __oFOSTMP := NIL
Static __oImpBor := Nil
Static __Ret1Bx := Nil
Static __oTitImp := Nil
Static __oPrepFKK := Nil
Static __oImpFis  := Nil
Static __oPreparA := NIL
Static __oRetFis  := Nil
Static __oModelMR := Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} FINXRET
Fonte com funções core do Motor de Retenção

@author  Mauricio Pequim Jr
@since 27/09/2017
@version 12
/*/
//-------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FMRCalcVc
Calcula a data de vencimento do título de imposto

@aparam	dVencto - Data base para calculo
@aparam	nVcDia  - Dia de vencimento do imposto
@aparam	cVcTipo - Define se o vencimento será fixo ou será contabilizado por período.
@aparam	cVcDuti - Define o período para determinar o vencimento será cálculo por dias corridos ou dias uteis.
					Esta parametrização se aplica apenas para casos em que o tipo de vencimento for periódico.
@aparam	cVcPeriodo - Define se o vencimento será por calculado por qual periodicidade (diária, mensal ou semanal)
@aparam	nVcQtdPer - Define a quantidade de períodos que serão contabilizados para definir o vencimento.
@aparam	cVcDtVld - Define a aplicação do DataValida() a data de vencto calculada (Antecipa ou Posterga)

@Return	dRet Data de vencimento do imposto calculado de acordo com as regras informadas na FKM - Tipo de retenção

@author  Mauricio Pequim Jr
@since 27/09/2017

@version 12
/*/
//--------------------------------------------------------------------------------------------------------------------------
//dVencto :=	FMRCalcVc(SE1->E1_EMISSAO,FRM->FRM_VCDIA , FRM->FRM_VCTIPO, FRM->FRM_VCDUTI, FRM->FRM_VCCONT,FRM->FRM_VCFAT,FRM->FRM_VDTVLD)
//dVencto :=	FMRCalcVc(dVencto        ,FKM->FKM_DIAVCT, FKM->FKM_TIPVCT, FKM->FRM_VCDUTI, FKM->FKM_PRDVCT,FKM->FKM_QTPERI,FKM->FKM_DTVLVC)
/*
FKM_DIAVCT	Dia Vencto.
FKM_TIPVCT	Tipo Vencto.
FKM_PRDVCT	Periodo Vct.
FKM_QTPERI	Qtd.Periodos
FKM_DATVCT	Tipo Dia
FKM_DTVLVC	Data Vßlida -
*/
Function FMRCalcVc(dVencto as Date ,nVcDia as Numeric ,cVcTipo as Character ,cVcDuti as Character, cVcPeriodo as Character,nVcQtdPer as Numeric ,cVcDtVld as Character) As Date

Local nDia As Numeric
Local nMes As Numeric
Local nAno As Numeric
Local nDiaSem As Numeric
Local dTemp As Date
Local nTemp As Numeric
Local nX As Numeric
Local dLastDay As Date
Local dFirstDay As Date
Local lAdianta As Logical

nDia := Day(dVencto)
nMes := Month(dVencto)
nAno := Year(dVencto)
nDiaSem := Dow(dVencto)
dTemp 	:= dVencto
nTemp 	:= 0
nX		:= 0
dLastDay := Ctod("//")
dFirstDay := Ctod("//")
lAdianta := (cVcDtVld != '1')	//1 = Adianta, 2 = Posterga (tem que ser invertido por conda da DataValida())

//Desmembro a data atual para poder calcular a data de vencimento
If cVcTipo == "1" //Vencimento fixo

	If nVcDia == 0 //Vencimento no mesmo dia
		dTemp := dVencto
	Else

		nMes  :=  Month(dTemp) +1
		nAno  :=  Year(dTemp)

		If nMes > 12
			nMes := 1
			nAno += 1
		Endif

		//Monto a data de vencimento
		dTemp := Ctod(cValToChar(nVcDia) + "/" + CValToChar(nMes) + "/" + CValToChar(nAno))
	Endif

	dTemp := DataValida(dTemp, lAdianta)

Else	//Vencimento por Periodos
	nMes  :=  Month(dTemp)
	nAno  :=  Year(dTemp)

	If cVcPeriodo == "1" 	//Contador = Mês
		If nVcQtdPer > 0
			For nX := 1 to nVcQtdPer
				nMes += 1
				If nMes > 12		//Dezembro posterga para Janeiro do próximo ano
					nMes := 1
					nAno += 1
				Endif
			Next
		EndIf
		//Verifico se são dias úteis ou dias corridos
		If cVcDuti == '1' //Dias úteis ==> nVcDia == 5 (5º dia útil do mês)
			nDia := nVcDia
			dTemp := Ctod(cValToChar(1) + "/" + CValToChar(nMes) + "/" + CValToChar(nAno))	//Primeiro dia do mês
			dLastDay := DataValida(LastDay(dTemp), .F.)									//Ultimo dia útil do mês subsequente
			For nX := 1 to nDia
				If nX == 1
					dTemp := DataValida(dTemp, .T.)
				Else
					dTemp := DataValida(dTemp + 1, .T.)
				Endif
				If dTemp > dLastDay
					dTemp := dLastDay
					Exit
				Endif
			Next
		Else			//Dias Corridos ==> nVcDia == 5 (5º dia do mês)
			dTemp := Ctod(cValToChar(nVcDia) + "/" + CValToChar(nMes) + "/" + CValToChar(nAno))
			dTemp := DataValida(dTemp, lAdianta)
		Endif

	ElseIf cVcPeriodo == "2" //Contador = Semanas
		If nVcQtdPer > 0
			nTemp :=  0
			nTemp :=  (9 - nDiaSem) + ((nVcQtdPer-1) * 7) //Calcula quantos dias faltam para iníciar a próxima, e depois adiciona o numero de dias referentes às semanas do contador
		EndIf
		dFirstDay := dVencto + nTemp		//Primeiro dia da semana
		dTemp := dFirstDay
		//Verifico se são dias úteis ou dias corridos
		If cVcDuti == '1' //Dias úteis ==> nVcDia == 5 (5º dia útil do mês)
			nVcDia := If(nVcDia > 5, 5, nVcDia)
			For nX := 1 to nVcDia
				If nX == 1
					dTemp := DataValida(dTemp, .T.)
				Else
					dTemp := DataValida(dTemp + 1, .T.)
				Endif
				//O limite de dias úteis de uma semana são 5 dias.
				//Se já estou avaliando o segundo dia útil e este fez a data mudar de semana, retorno o ultimo dia util da semana.
				If nX > 1 .and. (dTemp - dFirstDay) >= 6
					//dTemp := DataValida(dTemp - 1, .F.)
					nDia := Day(dTemp) - 1
					nMes := Month(dTemp)
					nAno := Year(dTemp)
					dTemp := Ctod(cValToChar(nDia) + "/" + CValToChar(nMes) + "/" + CValToChar(nAno))
					dTemp := DataValida(dTemp, .F.)

					Exit
				Endif
			Next
		Else			//Dias Corridos ==> nVcDia == 5 (5º dia da semana)
			dTemp := DataValida(dTemp + (nVcDia - 1), lAdianta)
		Endif
	Endif
EndIf

//Se a data calculada for menor que a emissão\vencimento original, prevalece a última
If dTemp < dVencto
	dTemp := dVencto
EndIf

dRet := dTemp

Return dRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FINCalImp()
Função de cálculo do imposto

@author  Mauricio Pequim Jr/Sivaldo Oliveira
@since 27/09/2017
@version 12
/*/
//-------------------------------------------------------------------
Function FinCalImp(cCart As Character, cNatur As Character, cCliFor As Character, cLoja As Character, cFilOrig As Character, nBaseImp As Numeric, dDtRef As Date,;
							lBaixa As Logical, aBaseImp As Array, cTipo As Character, cChaveTit As Character, cIdTit As Character, aImpCalc As Array ,;
							lBxParcial ) As Array
	Local lRet      As Logical
	Local nX        As Numeric
	Local nCasDec   As Numeric
	Local nValImp   As Numeric
	Local nBaseCalc As Numeric
	Local nValRet   As Numeric
	Local nBaseRet  As Numeric
	Local aImpos    As Array
	Local cTipoRet  As Character
	Local cNatureza As Character
	Local cFOS      As Character
	Local nPosBase  As Numeric
	Local nTamBase  As Numeric
	Local TblImp    As Character
	Local cTipImp   As Character
	Local nRecFKK   As Numeric
	Local cFilFKL   As Character
	Local cFilFOO   As Character
	Local aFKQ      As Array
	Local nPos      As Numeric
	Local nRecFOS   As Numeric
	Local nFaixa    As Numeric
	Local cCodURF	As Character
	Local nPctURF	As Numeric
	Local nFator	As Numeric
	Local cDedNF    As Character
	Local cChavFOU  As Character
	Local cCodFOU   As Character 
	Local nVlrAces  As Numeric 
	Local nValor    As Numeric
	Local aValAces  As Array
	Local lBaseDif  As Logical
	Local nVlrRet   As Numeric
	Local nVlrBas   As Numeric
	
	//Parâmetros da função
	Default cCart     := ''
	Default cNatur    := ''
	Default cCliFor   := ''
	Default cLoja     := ''
	Default cFilOrig  := cFilAnt
	Default nBaseImp  := 0
	Default dDtRef    := dDataBase
	Default lBaixa    := .F.
	Default aBaseImp  := {}
	Default cTipo     := ''
	Default cChaveTit := ""
	Default cIdTit    := ""
	Default aImpCalc  := {}
	Default lBxParcial := .F.
	
	//Inicializa as variáveis
	lRet      := .T.
	nX        := 0
	nCasDec   := 0
	nValImp   := 0
	nBaseCalc := 0
	nValRet   := 0
	nBaseRet  := 0
	aCadFKM   := {}
	aImpos    := {}
	cTipoRet  := ""
	cNatureza := ""
	cFOS      := GetNextAlias()
	nPosBase  := 0
	nTamBase  := Len(aBaseImp)
	TblImp    := ""
	cTipImp   := ""
	nImpCal   := Len(aImpCalc)
	cFilFKL   := ""
	cFilFOO   := ""
	aFKQ      := {}
	nPos      := 0
	nRecFOS := 0
	nFaixa  := 0
	cCodURF	  := ""
	nPctURF   := 0
	nFator	  := 1
	cDedNF    := ""
	cChavFOU  := ""
	cCodFOU   := "" 
	nVlrAces  := 0
	nValor    := 0
	aValAces  := {}
	lBaseDif  := .T.
	nVlrRet   := 0
	nVlrBas   := 0
	
	//Verifica os principais dados para calculo do imposto
	If Empty(cCart) .or. Empty(cNatur) .or. Empty(cCliFor) .or. Empty(cLoja)  .or. (Empty(nBaseImp) .And. nImpCal == 0) .Or. (cTipo $ MV_CPNEG) .Or. Empty(cTipo)
		lRet := .F.
	EndIf

	If lRet
		SED->(dbSetOrder(1))
		lRet := SED->(MsSeek(xFilial("SED",cFilOrig)+cNatur))

		If lRet
			cAlias := If(cCart == "1", "SA2", "SA1")
			(cAlias)->(dbSetOrder(1))
			lRet := (cAlias)->(MsSeek(xFilial(cAlias,cFilOrig) + cClifor + cLoja))
			
			If lRet
				If lBaixa .And. nImpCal == 0 .And. !Empty(cChaveTit)
					aImpCalc := FinImpFis(cChaveTit, cFilOrig, If(cCart == "1", "SE2", "SE1"), .T., nBaseImp, dDtRef, cCliFor, cLoja)
					nImpCal  := Len(aImpCalc)
				EndIf
				
				If (nTamBase != 0 .Or. nBaseImp > 0) 
					//Verifica quais impostos serão calculados (Natureza x Fornecedor ou Natureza x Cliente)
					TblImp := FinVerImp(cCart, cFilOrig, cCliFor, cLoja, cTipo, lBaixa, cNatur)	 				
					If !Empty(TblImp)
						FOS->(DbSetOrder(1))
						FOU->(DbSetOrder(1))
						FKO->(DbSetOrder(1))
						nCasDec  := MsDecimais(1)
						
						While (TblImp)->(!Eof())
							nBaseCalc	:= 0
							nBaseRet	:= 0
							nValImp		:= 0
							nValRet		:= 0
							nVlrRet     := 0
							nVlrBas     := 0
							
							If (TblImp)->FKK_ADTO != "1" .And. cTipo $ MVPAGANT+"|"+MVRECANT
								(TblImp)->(DbSkip())
								Loop
							EndIf
							
							//Regra financ vinculada a regra fiscal, mantém o cálculo do fiscal for o mesmo imposto 
							If nImpCal > 0 .And. Ascan(aImpCalc, {|x| AllTrim(x[1]) == AllTrim((TblImp)->FKK_CODIGO)}) > 0 .And.;
								Ascan(aImpCalc, {|x| AllTrim(x[8]) == AllTrim((TblImp)->FOO_CODIGO)}) > 0
								(TblImp)->(DbSkip())
								Loop
							EndIf
							
							//Verifica se já gerou os impostos para o Título na primeira baixa.
							If lBaixa .And. (TblImp)->FKK_PARCTO == "1" .And. !Empty(cIdTit)
								If FinRet1Bx(xFilial("FK0",cFilOrig), cIdTit, (TblImp)->FKK_CODIGO, cCart)
									(TblImp)->(DbSkip())
									Loop
								EndIf
							EndIf
							
							//verifica de existe base difenciada para o imposto(Ex: PLS)
							cTipImp := AllTrim((TblImp)->FOO_CODIGO)
							
							If nTamBase > 0
								nPosBase := ascan(aBaseImp, {|x| x[1] == cTipImp})
							EndIf
							
							If nPosBase > 0
								//cálculo da base diferenciada (Ex: PLS)
								nBaseCalc := aBaseImp[nPosBase,2]
								lBaseDif   := .T.
							Else
								nBaseCalc := nBaseImp
							EndIf
							
							If nBaseCalc <= 0
								(TblImp)->(DbSkip())
								Loop	
							EndIf
							
							//Valores acessórios
							If lBaixa .And. !Empty((TblImp)->FKK_CODFKU) .And. !lBxParcial
								cChavFOU := xFilial("FOU",cFilOrig) + (TblImp)->FKK_IDFKU
								
								//Valores acessórios fixos que podem ser considerados na base de cálculo
								If lBaseDif 
									aValAces := FinValAces(If(cCart == "1", "SE2", "SE1"), nBaseCalc, dDtRef)								
									lBaseDif := nPosBase > 0
								EndIf
								
								If Len(aValAces) > 0 .And. FOU->(MsSeek(cChavFOU))
									cChavFOU := AllTrim(cChavFOU)
									
									While FOU->(!Eof()) .And. AllTrim(FOU->(FOU_FILIAL+FOU_IDRET)) == cChavFOU
										If FOU->FOU_ACAO $ "2|3"
											cCodFOU := AllTrim(FOU->FOU_CODIGO)
											
											If nPos := ascan(aValAces, {|x| x[1] == cCodFOU}) 
												If nPos != 0 
													nValor := aValAces[nPos,2]
												Else //Será criado tratamento para o cadastro de valores acessórios FKC
													nValor := 0
												EndIf
												
												If nValor != 0
													If FOU->FOU_APLICA == "1"//Base
														If FOU->FOU_ACAO == "2" //soma na base
															nBaseCalc += nValor 
														Else //subtrai da base
															nBaseCalc -= nValor
														EndIf
													Else //valor
														If FOU->FOU_ACAO == "2" //soma ao imposto
															nVlrAces += nValor
														Else //subtrai do imposto
															nVlrAces -= nValor 
														EndIf 
													EndIf
												EndIf	
											EndIf
										EndIf
										
										FOU->(DbSkip())
									EndDo 
								EndIf 	
							EndIf  
							
							If Empty((TblImp)->FKN_CODFOS) //Regra de calculo
								nBaseCalc := nBaseCalc * ((TblImp)->FKN_PCBASE/100)
								
								If (TblImp)->FKN_VLRDEC == "1"
									nBaseCalc := Round(nBaseCalc, nCasDec)
									nValImp  := Round(nBaseCalc * ((TblImp)->FKN_PORCEN/100), nCasDec)
								Else
									nBaseCalc := NoRound(nBaseCalc, nCasDec)
									nValImp  := NoRound(nBaseCalc * ((TblImp)->FKN_PORCEN/100), nCasDec)
								EndIf
							Else //Tabela Progressiva
								If FOS->(MsSeek(xFilial("FOS",cFilOrig) + (TblImp)->FKN_IDFKS))
									nVlrBas := nBaseCalc 
									cFOS    := xFilial("FOS", cFilOrig) + (TblImp)->FKN_IDFKS
									
									While FOS->(!Eof())
										If nBaseCalc <= FOS->FOS_FAIXA
											exit
										ElseIf FOS->FOS_FAIXA > nFaixa
											nRecFOS := FOS->(Recno())
											nFaixa  := FOS->FOS_FAIXA
										EndIf
										FOS->(DbSkip())
									EndDo
									
									//Posiciona na maior faixa
									If nRecFOS > 0 .And. FOS->(Eof()) 
										FOS->(DbGoto(nRecFOS))
									EndIf
									
									//Recompõe a base de cálculo do imposto(IRF)
									If !Empty((TblImp)->FKK_CODFKO) .And. !Empty((TblImp)->FKK_IDFKO)   
										FinIrfRet(cCart, cCliFor, cLoja, cTipImp,(TblImp)->FKK_CODIGO, cFilOrig, (TblImp)->FKK_IDFKO, dDtRef, @nVlrRet, @nBaseCalc, lBaixa)
									EndIf									
									
									If FOS->FOS_TIPDED == "1"
										nBaseCalc -= FOS->FOS_VLRDED
									EndIf
									
									nValImp := Round(nBaseCalc * (FOS->FOS_PERC/100), nCasDec)
									
									If FOS->FOS_TIPDED == "2"
										nValImp -= FOS->FOS_VLRDED
									EndIf
									
									nBaseCalc := nVlrBas 
									nValImp   -= nVlrRet
									//Tratamento de Arredondamento
									If FKN->FKN_VLRDEC == "1"
										nValImp   := Round(If(nValImp < 0, 0, nValImp), nCasDec)
										nBaseCalc := Round(If(nBaseCalc < 0, 0, nBaseCalc), nCasDec)
									Else
										nValImp   := NoRound(If(nValImp < 0, 0, nValImp), nCasDec)
										nBaseCalc := NoRound(If(nBaseCalc < 0, 0, nBaseCalc), nCasDec)
									EndIf
								EndIf
							EndIf
							
							//Soma ou subtrai o valor acess ao imposto
							nValImp  += nVlrAces 
							//Valor e base de retenção
							nValRet	 := nValImp
							nBaseRet := nBaseCalc
							nVlrAces := 0
							
							//Descarta o imposto caso não tenha valor calculado.
							//ex: vlr do imposto = 10,00 - 15,00 desconto que subtrai do imposto
							If nValRet <= 0
								(TblImp)->(DbSkip())
								Loop	
							EndIf 
							/*-------------------------------------------
							Estrutura da aImpos
							[1]  = Codigo do tipo de imposto (FKK_CODIGO)
							[2]  = Base do imposto
							[3]  = Valor calculado do imposto
							[4]  = Base de retenção do imposto
							[5]  = Valor a reter do imposto
							[6]  = IDRET FK4
							[7]  = Array contendo os Recnos FK3 das pendências de retenção
							[8]  = Tipo do Imposto (FOO)
							[9]  = Regime (1 = Competência ou 2 = Baixa)
							[10] = Natureza do imposto
							[11] = Tabela onde foi gerado o imposto
							[12] = Recno do titulo de imposto gerado
							[13] = Ação aplicada no valor da nota (1 = subtrai, 2 = soma, 3 = sem ação)
							[14] = Carteira de movimento do imposto (1 = Pagar, 2 = Receber)
							[15] = Tipo de movimento (1 = Abtimento, 2 = Impostos)
							[16] = Define se o gera títulos provisórios
							[17] = Variável de contabilização
							[18] = Chave 32 da tabela Id de retenção (FKK)
							[19] = Ação sobre títulos de antecipação pagamento/recebimento: 1 = Retém, 3 = sem ação
							[20] = Flag que valida se houve retenção no período para o imposto
							[21] = Recno da FKK
							[22] = Valor retido previamente para determinado imposto
							[23] = Codigo de retenção
							--------------------------------------------*/
							Aadd(aImpos, { (TblImp)->FKK_CODIGO, nBaseCalc, nValImp, nBaseRet, nValRet, "", {}, cTipImp, (TblImp)->FKK_FATGER, (TblImp)->FKL_NATUR, "", 0,;
											(TblImp)->FKK_VLNOTA, (TblImp)->FKL_CARTMV, (TblImp)->FKL_TIPMOV, (TblImp)->FKK_PROVIS, (TblImp)->FKK_VARCTB, (TblImp)->FKK_IDRET, (TblImp)->FKK_ADTO, .T., (TblImp)->R_E_C_N_O_, 0,(TblImp)->FKK_CODRET })
							(TblImp)->(DbSkip())
						EndDo
						(TblImp)->(DbCloseArea())
						TblImp := ""
					EndIf
				EndIf
				
				//Cálculo já foi realizado pelo fiscal ou qualquer outro módulo
				If nImpCal > 0
					FKL->(DbSetOrder(1))
					FOO->(DbSetOrder(1))
					FKO->(dbSetOrder(2))
					cFilFKL := xFilial("FKL",cFilOrig)
					cFilFOO := xFilial("FOO",cFilOrig)
					
					For nX := 1 To nImpCal
						nRecFKK := FinFKKVig(aImpCalc[nX,1], dDtRef)
						FKK->(DbGoto(nRecFKK))
						
						If FKK->(!Eof()) .And. FKL->(MsSeek(cFilFKL+FKK->FKK_IDFKL)) .And. FOO->(MsSeek(cFilFOO+FKK->FKK_IDRET))
							nBaseCalc := aImpCalc[nX,2]
							nBaseRet  := nBaseCalc
							nValImp   := aImpCalc[nX,3]
							nValRet   := nValImp
							
							If lBaixa .And. FKO->(MsSeek(xFilial("FKO")+FKK->FKK_CODFKO)) .and. FKO->FKO_USOURF == '2'	//Baixa
								cCodURF	  := aImpCalc[nX,10]
								nPctURF	  := aImpCalc[nX,11]
									
								//Calculo utilizando URF
								If !Empty(cCodUrf)
									//Chamo a função do fiscal
									nFator := xFisGetURF(dDtRef, cCodURF, nPctURF)
									nValRet := nBaseCalc * nFator
								Endif
							Endif
							
							cDedNF := IIf( (FKK->FKK_FATGER == "1" .OR. lBaixa) , FKK->FKK_VLNOTA, "3")
							
							Aadd(aImpos, { FKK->FKK_CODIGO, nBaseCalc, nValImp, nBaseRet, nValRet, "", {}, AllTrim(FOO->FOO_CODIGO), FKK->FKK_FATGER, FKL->FKL_NATUR, "", 0,;
											cDedNF, FKL->FKL_CARTMV, FKL->FKL_TIPMOV, FKK->FKK_PROVIS, FKK->FKK_VARCTB, FKK->FKK_IDRET, FKK->FKK_ADTO, .T., nRecFKK, 0, FKK->FKK_CODRET })
						EndIf
					Next nX
					
					If lBaixa
						nImpCal := 0
					EndIf
				EndIf
				
				//cumulatividade
				FinCumult(cCart, cFilOrig, cNatur, cCliFor, cLoja, dDtRef, aImpos, lBaixa, cChaveTit)
				//Valida o valor mínimo e máximo para dispensa ou retenção
				FinMinMax(aImpos, cFilOrig)
				//Dedução de base/valor
				FinDeduc(aImpos, cFilOrig)				
				
				//Gravação da Tabela FKQ pelos documentos de entrada e saída apenas na emissão.
				If !lBaixa .And. nImpCal > 0
					nImpCal := Len(aImpos)

					For nX := 1 To nImpCal
						If nPos := ascan(aImpCalc, {|x| x[1] == aImpos[nX,1]} )
							Aadd(aFKQ, { aImpos[nX,1],  aImpos[nX,8], aImpCalc[nPos,4], aImpos[nX,9], aImpos[nX,2], aImpos[nX,3], aImpCalc[nPos,5],;
										 aImpCalc[nPos,10],aImpCalc[nPos,11]} )
							aImpCalc[nPos,1] := " "
						EndIf
					Next nX

					FGravaFKQ(aFKQ)
				EndIf
			EndIf
		EndIf
	EndIf

Return (aImpos)

//-------------------------------------------------------------------
/*/{Protheus.doc} FinVerImp()
Verifica quais impostos a serem calculados
(Natureza x Fornecedor ou Natureza x Cliente)

@author  Mauricio Pequim Jr/Sivaldo Oliveira
@since 27/09/2017
@version 12
/*/
//-------------------------------------------------------------------
Static Function FinVerImp(cCart As Character, cFilOrig As Character, cCliFor As Character, cLoja As Character, cTipo As Character, lBaixa As Logical, cNatur As Character)
	Local lRet     As Logical
	Local cAlias   As Character
	Local cQry     As Character
	Local cTblTmp  As Character	

	//Parâmetros da função
	Default cCart    := ""
	Default cFilOrig := ""
	Default cCliFor  := ""
	Default cLoja    := ""
	Default cTipo    := ""
	Default lBaixa   := .F.
	Default cNatur   := ""

	//Inicializa as variáveis
	lRet := If(lBaixa, !cTipo $ MVPAGANT, .T.) .And. !cTipo $ MV_CPNEG
	cTblTmp := ""

	If lRet
		cAlias := If(cCart == "1", "FOK", "FOJ") //1 = Pagar, 2 = Receber
		//Seleção de campos
		cQry := "SELECT FKK.FKK_CODIGO,FOO.FOO_CODIGO,FKK.FKK_FATGER,FKL.FKL_NATUR,FKK.FKK_VLNOTA,FKL.FKL_CARTMV"
		cQry += ",FKL.FKL_TIPMOV,FKK.FKK_PROVIS,FKK.FKK_VARCTB,FKK.FKK_IDRET,FKK.FKK_ADTO,FKK.FKK_VIGINI,FKK.FKK_VIGFIM"
		cQry += ",FKK.FKK_CODFKP,FKK.FKK_IDFKP,FKK.FKK_CODFKL,FKK.FKK_IDFKL,FKK.FKK_CODFKN,FKK.FKK_IDFKN,FKK.FKK_CODFKO"
		cQry += ",FKK.FKK_IDFKO,FKK.FKK_CODFKU,FKK.FKK_IDFKU,FKN.FKN_PCBASE,FKN.FKN_PORCEN,FKN.FKN_CODFOS,FKN.FKN_IDFKS"
		cQry += ",FKN.FKN_CODFOV,FKN.FKN_IDFKV,FKN.FKN_VLRDEC,FKK.FKK_PARCTO,FKK.FKK_CODRET, FKK.R_E_C_N_O_ "
		//Tabela Principal da consulta
		cQry += "FROM " + RetSqlName("FKK") + " FKK "
		//Regra Financeira x Tipo de Imposto
		cQry += "INNER JOIN " + RetSqlName("FOO") + " FOO "
		cQry += "ON (FKK.FKK_FILIAL = FOO.FOO_FILIAL AND FKK.FKK_IDRET  = FOO.FOO_IDRET) "
		//Regra Financeira x natureza
		cQry += "INNER JOIN " + RetSqlName("FOI") + " FOI "
		cQry += "ON (FKK.FKK_CODIGO = FOI.FOI_CODIGO) "
		//Regra Financeira x cliente/fornecedor
		cQry += "INNER JOIN " + RetSqlName(cAlias) + " " + cAlias + " "
		cQry += "ON (FKK.FKK_CODIGO = " + cAlias + "." + cAlias + "_CODIGO) "
		//Regra Financeira x Regra de Título
		cQry += "INNER JOIN " + RetSqlName("FKL") + " FKL "
		cQry += "ON (FKK.FKK_FILIAL = FKL.FKL_FILIAL AND FKK.FKK_CODFKL = FKL.FKL_CODIGO AND FKK.FKK_IDFKL = FKL.FKL_IDRET) "
		//Regra Financeira x Regra de Cálculo
		cQry += "LEFT JOIN " + RetSqlName("FKN") + " FKN "
		cQry += "ON (FKK.FKK_FILIAL = FKN.FKN_FILIAL AND FKK.FKK_CODFKN = FKN.FKN_CODIGO AND FKK.FKK_IDFKN = FKN.FKN_IDRET) "
		//Regra Financeira x Regra de Vencimento
		cQry += "LEFT JOIN " + RetSqlName("FKP") + " FKP "
		cQry += "ON (FKK.FKK_FILIAL = FKP.FKP_FILIAL AND FKK.FKK_CODFKP = FKP.FKP_CODIGO AND FKK.FKK_IDFKP = FKP.FKP_IDRET) "
		//Filtro da consulta
		cQry += "WHERE FKK.FKK_ATIVO = '1' AND FOO.FOO_TIPIMP = '1' "
		If lBaixa
			cQry += "AND FKK.FKK_FATGER = '2' "
		EndIf
		cQry += "AND FKK.FKK_FILIAL = ? AND FOI.FOI_FILIAL = ? "
		cQry += "AND " + cAlias + "." + cAlias + "_FILIAL = ? AND FOI.FOI_NATURE = ? "
		cQry += "AND " + If(cCart == "1", "FOK.FOK_FORNEC", "FOJ.FOJ_CLIENT") + " = ? "
		cQry += "AND " + cAlias + "." + cAlias + "_LOJA = ? AND FKK.FKK_VIGINI <= ? "
		cQry += "AND FKK.FKK_VIGFIM >= ? AND FKN.D_E_L_E_T_ = ' ' AND FKL.D_E_L_E_T_ = ' ' "
		cQry += "AND FKK.D_E_L_E_T_ = ' ' AND FOI.D_E_L_E_T_ = ' ' AND " + cAlias + ".D_E_L_E_T_ = ' ' "

		oPrepCP := FWPreparedStatement():New(cQry)
		oPrepCP:SetString(1, xFilial("FKK", cFilOrig))
		oPrepCP:SetString(2, xFilial("FOI", cFilOrig))
		oPrepCP:SetString(3, xFilial(cAlias, cFilOrig))
		oPrepCP:SetString(4, cNatur)
		oPrepCP:SetString(5, cCliFor)
		oPrepCP:SetString(6, cLoja)
		oPrepCP:SetString(7, DTOS(dDataBase))
		oPrepCP:SetString(8, DTOS(dDataBase))

		cQry := oPrepCP:GetFixQuery()
		cTblTmp := MpSysOpenQuery(cQry)

		If (cTblTmp)->(Eof())
			(cTblTmp)->(DbCloseArea())
			cTblTmp := ""
		EndIf
	EndIf
Return cTblTmp

//-------------------------------------------------------------------
/*/{Protheus.doc} FinDeduc()
Faz a dedução de base/valor dos impostos

@author  Mauricio Pequim Jr/Sivaldo Oliveira
@since 27/09/2017
@version 12
/*/
//-------------------------------------------------------------------
Static Function FinDeduc(aImpos As Array, cFilOrig As Character)
	Local cFOV    As Character
	Local nX      As Numeric
	Local nPosImp As Numeric
	Local nCasDec As Numeric
	Local nImpos  As Numeric
	Local aAreaAnt as Array

	//Parâmetros da função
	Default aImpos   := {}
	Default cFilOrig := cFilAnt

	//Inicializa as variáveis
	aAreaAnt := GetArea()
	cFOV    := ""
	nX      := 0
	nPosImp := 0
	nCasDec := MsDecimais(1)
	nImpos  := Len(aImpos)

	DbSelectArea("FOV")
	FOV->(DbSetOrder(1))
	FKN->(DbSetOrder(1))

	For nX := 1 to nImpos
		FKK->(DbGoto(aImpos[nX,21]))

		If Empty(aImpos[nX,5]) .Or. Empty(FKK->FKK_IDFKN)
			Loop
		EndIf

		If FKN->(MsSeek(xFilial("FKN",cFilOrig) + FKK->FKK_IDFKN)) .And. FKN->FKN_PORCEN > 0
			cFOV := (xFilial("FOV",cFilOrig)+FKN->FKN_IDFKV)

			If FOV->(MsSeek(cFOV)) .And. FOV->FOV_PERDED != 0
				While FOV->(!Eof()) .And. FOV->(FOV_FILIAL+FOV_IDRET) == cFOV
					If nPosImp := ascan(aImpos, {|x| x[1] == FOV->FOV_CODIGO})
						If FKN->FKN_VLRDEC == "1"
							//dedução por base
							If FOV->FOV_TIPDED == "1"
								aImpos[nX,2] -= Round((aImpos[nPosImp,5] * (FOV->FOV_PERDED / 100)), nCasDec) //refaz a base de cálculo
								aImpos[nX,4] := aImpos[nX,2] //atualiza a base de retenção
								aImpos[nX,3] := Round((aImpos[nX,2] * (FKN->FKN_PORCEN / 100)), nCasDec) //refaz o valor calculado
								aImpos[nX,5] := aImpos[nX,3] //atualiza o valor a reter
							Else //dedução por valor
								aImpos[nX,3] -= Round((aImpos[nPosImp,5] * (FOV->FOV_PERDED / 100)), nCasDec) //refaz o valor calculado
								aImpos[nX,5] := aImpos[nX,3] //atualiza o valor a reter
							EndIf
						Else
							//dedução por base
							If FOV->FOV_TIPDED == "1"
								aImpos[nX,2] -= NoRound((aImpos[nPosImp,5] * (FOV->FOV_PERDED / 100)), nCasDec) //base de cálculo
								aImpos[nX,4] := aImpos[nX,2] //base de retenção
								aImpos[nX,3] := NoRound((aImpos[nX,2] * (FKN->FKN_PORCEN / 100)), nCasDec) //valor calculado
								aImpos[nX,5] := aImpos[nX,3] //valor a reter
							Else
								aImpos[nX,3] -= NoRound((aImpos[nPosImp,5] * (FOV->FOV_PERDED / 100)), nCasDec) //valor calculado
								aImpos[nX,5] := aImpos[nX,3] //valor a reter
							EndIf
						EndIf
					EndIf
					FOV->(DbSkip())
				EndDo
			EndIf
		EndIf
	Next nX

	RestArea(aAreaAnt)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FinMinMax()

Verifica se atingiu o valor mínimo e máximo para dispensa
ou retenção do imposto

@author  Mauricio Pequim Jr/Sivaldo Oliveira
@since 27/09/2017
@version 12
/*/
//-------------------------------------------------------------------
Static Function FinMinMax(aImpos As Array, cFilOrig As Character)
	Local nY      As Numeric
	Local nMin    As Numeric
	Local nPosImp As Numeric
	Local nImpos  As Numeric
	Local cFKO    As Character
	Local aAux    As Array
	
	//Parâmetros da função
	Default aImpos		:= {}
	Default cFilOrig	:= cFilAnt
	
	  //Inicializa as variáveis
	nY      := 0
	nMin    := 0
	nPosImp := 0
	nImpos	:= Len(aImpos)
	cFKO    := ""
	
	If nImpos != 0
		aAux    := Aclone(aImpos)
		aImpos  := {}
		FKO->(DbSetOrder(1))
		FOT->(DbSetOrder(1))
		FKN->(DbSetOrder(1))
		
		For nY := 1 To nImpos
			FKK->(DbGoto(aAux[nY,21]))
			
			If FKK->(Eof()) .Or. aAux[nY,5] == 0 .Or. Empty(FKK->FKK_IDFKO)
				If aAux[nY,5] > 0 
					Aadd(aImpos, aAux[nY])
				Endif
				Loop
			EndIf
			
			cFKO := (xFilial("FKO", cFilOrig) + FKK->FKK_IDFKO) 
			
			If FKO->(DbSeek(cFKO)) .And. FKO->FKO_CUMULA $ "2|3" .And. (FKO->FKO_MAXRET != 0 .Or. FKO->FKO_MINRET != 0)
				nMin := 0
				
				If FKO->FKO_CUMULA == "2" //cumulatividade por base
					If FKO->FKO_MAXRET > 0
						If aAux[nY,22] >= FKO->FKO_MAXRET
							Loop //despreza a retenç pois já reteve o máx p/ o período 
						EndIf
						
						If (aAux[nY,22] + aAux[nY,4]) > FKO->FKO_MAXRET
							If FKN->(DbSeek(xFilial("FKN",cFilOrig) + FKK->FKK_IDFKN))
								aAux[nY,4] := (FKO->FKO_MAXRET - aAux[nY,22])
								aAux[nY,5] := Round(aAux[nY,4] * (FKN->FKN_PORCEN / 100), 2)
							EndIf
						EndIf				
					EndIf
					
					If aAux[nY,20] //Ainda não houve retenção no período
						If aAux[nY,4] > FKO->FKO_MINRET
							Aadd(aImpos, aAux[nY])
							Loop
						EndIf
						
						cFOT := xFilial("FOT",cFilOrig) + FKO->FKO_IDFKT
						nMin := aAux[nY,4]
						
						If FOT->(MsSeek(cFOT))
							While FOT->(!Eof()) .And. cFOT == FOT->(FOT_FILIAL+FOT_IDRET)
								If FOT->FOT_CODIGO != aAux[nY,1]
									If nPosImp := ascan(aAux, {|x| x[1] == FOT->FOT_CODIGO})
										nMin += aAux[nPosImp,4]
									EndIf
								EndIf
								FOT->(DbSkip())
							EndDo
						EndIf
					EndIf
				Else//cumulatividade por valor do imposto
					If FKO->FKO_MAXRET > 0
						If aAux[nY,22] >= FKO->FKO_MAXRET
							Loop //despreza a retenç pois já reteve o máx p/ o período
						EndIf
							
						If (aAux[nY,22] + aAux[nY,5]) > FKO->FKO_MAXRET
							If FKN->(DbSeek(xFilial("FKN",cFilOrig) + FKK->FKK_IDFKN))  
								aAux[nY,5] := (FKO->FKO_MAXRET - aAux[nY,22])
							EndIf
						EndIf				
					EndIf
						
					If aAux[nY,20]//Ainda não houve retenção no período
						If aAux[nY,5] > FKO->FKO_MINRET
							Aadd(aImpos, aAux[nY])
							Loop
						EndIf
						
						cFOT := xFilial("FOT",cFilOrig) + FKO->FKO_IDFKT
						nMin := aAux[nY,5]
						
						If FOT->(MsSeek(cFOT))
							While FOT->(!Eof()) .And. cFOT == FOT->(FOT_FILIAL+FOT_IDRET)
								If FOT->FOT_CODIGO != aAux[nY,1]
									If nPosImp := ascan(aAux, {|x| x[1] == FOT->FOT_CODIGO})
										nMin += aAux[nPosImp,5]
									EndIf
								EndIf
								FOT->(DbSkip())
							EndDo
						EndIf
					EndIf
				EndIf
				
				//Valida o mínimo de retenção por base e por valor
				If aAux[nY,20] .And. nMin > 0 .And. nMin <= FKO->FKO_MINRET
					aAux[nY,4] := 0 //base de retenção
					aAux[nY,5] := 0 //valor a reter
				EndIf			
			EndIf
			
			//Adiciona o array para gravação das tabelas FK3 e FK4
			Aadd(aImpos, aAux[nY])
		Next nY
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FinCumult()

Verifica a cumulatividade dos impostos

@author  Mauricio Pequim Jr/Sivaldo Oliveira
@since 27/09/2017
@version 12
/*/
//-------------------------------------------------------------------
Static Function FinCumult(cCart As Character,cFilOrig As Character,cNatur As Character,cCliFor As Character,cLoja As Character, dDtRef As Date,aImpos As Array, lBaixa As Logical, cChaveTit As Character)
	Local lRet        As Logical
	Local lFilComp    As Logical
	Local cTblTmp     As Character
	Local cTblIrf     As Character
	Local cFils	      As Character
	Local nImpos      As Numeric
	Local nY          As Numeric
	Local nCasDec     As Numeric
	Local cQryCliFor  As Character
	Local cCodFKK     As Character
	Local nMoeda      As Numeric
	Local cTblTmpBrd  As Character

	//Parâmetros da função
	Default cCart     := ""
	Default cFilOrig  := cFilAnt
	Default cNatur    := ""
	Default cCliFor   := ""
	Default cLoja     := ""
	Default dDtRef    := dDataBase
	Default aImpos    := {}
	Default lBaixa    := .F.
	Default cChaveTit := ""

	//Inicializa as variáveis
	lRet       := .T.
	cTblTmp    := ""
	cTblIrf    := ""
	cFils      := ""
	nImpos     := Len(aImpos)
	nY         := 0
	nCasDec    := 0
	cQryCliFor := ""
	cCodFKK    := ""
	nMoeda     := 0
	cTblTmpBrd := ""

	If (Empty(cCart) .Or. nImpos == 0 .Or. Empty(cNatur) .Or. Empty(cCliFor) .Or. Empty(cLoja))
		lRet := .F.
	EndIf

	If lRet
		nCasDec := MsDecimais(1)
		lFilComp := FwModeAccess("SE2",1) == "C"
		FKO->(DbSetOrder(1))

		For nY := 1 To nImpos
			FKK->(DbGoto(aImpos[nY,21]))

			If FKK->(Eof()) .Or. aImpos[nY,5] == 0 .Or. (lBaixa .And. FKK->FKK_FATGER == "1") .Or. (!lBaixa .And. FKK->FKK_FATGER == "2")
				Loop
			EndIf

			//Codigo Tipo de Retenção
			cCodFKK := aImpos[nY,1]

			If (FKO->(MsSeek(xFilial("FKO",cFilOrig)+FKK->FKK_IDFKO))) .And. FKO->FKO_CUMULA $ "2|3"
				//Filias que serão considerada na cumulatividade
				cFils := FinSelFil()

				//chama a função que monta a query da cumulatividade
				If !Empty(cFils)
					//Cria a tabela temporária com os registros de retenção FK3|FK4
					If !Empty(cCliFor+cLoja)
						cTblTmp  := FinQryCum(cCart, cCliFor, cLoja, dDtRef, cFils, cFilOrig, lFilComp, cCodFKK, lBaixa, cChaveTit)
						//Bordero - pendências
						cTblTmpBrd := FinCumBor(cCart, cCliFor, cLoja, dDtRef, cFils, cFilOrig, lFilComp, cCodFKK, cChaveTit)
					EndIf
				EndIf

				//cumulatividade
				If !Empty(cTblTmp)
					(cTblTmp)->(DbGotop())

					While (cTblTmp)->(!EOF())
						//Desconsidera o reg se já existe retenção no período
						If (cTblTmp)->FK4_VALOR > 0
							aImpos[nY,22] += If(FKO->FKO_CUMULA == "2", (cTblTmp)->FK4_BASIMP, (cTblTmp)->FK4_VALOR)
							
							If lBaixa 
								aImpos[nY,20] := .F.
								(cTblTmp)->(DbSkip())
								Loop
							Endif
						EndIf

						nBase := (cTblTmp)->FK3_BASIMP
						nMoeda := Val((cTblTmp)->FK3_MOEDA)

						If nMoeda > 1
							nBase := Round(xMoeda(nBase, nMoeda, 1, dDtRef, 3), nCasDec)
						EndIf

						//valor calculado - Valor Retido FKs
						If lBaixa
							aImpos[nY,5] += (cTblTmp)->FK3_VALOR
						Else
							aImpos[nY,5] += (cTblTmp)->FK3_VALOR - (cTblTmp)->FK4_VALOR

							//Atualiza flag de retenção no período, p/ não não vld mínimo de retenção.
							If (cTblTmp)->FK4_VALOR > 0
								aImpos[nY,20] := .F.

								//Quando a base de retenção é composta por uma nf que foi excluída.
								//atualiza a FK3_IDRET da nova nf que possui o msm valor da nf que foi excluída
								If !Empty((cTblTmp)->FK3_IDRET) .And. aImpos[nY,5] == 0
									aImpos[nY,6] := (cTblTmp)->FK3_IDRET
								EndIf
							EndIf
						EndIf

						//Base do valor retido
						If aImpos[nY,20]
							aImpos[nY,4] += nBase
						EndIf

						//Recnos dos registros pendentes de retenção.
						If Empty( (cTblTmp)->FK3_IDRET )
							Aadd(aImpos[nY,7], (cTblTmp)->FK3RECNO)
						EndIf

						(cTblTmp)->(DbSkip())
					EndDo
				EndIf

				//cumulatividade - borderô (não retidos)
				If !Empty(cTblTmpBrd)
					(cTblTmpBrd)->(DbGotop())

					While (cTblTmpBrd)->(!Eof())
						nBase  := (cTblTmpBrd)->FK3_BASIMP
						nMoeda := Val((cTblTmpBrd)->FK3_MOEDA)

						If nMoeda > 1
							nBase := Round(xMoeda(nBase, nMoeda, 1, dDtRef, 3), nCasDec)
						EndIf

						//Base do valor retido
						If aImpos[nY,20]
							aImpos[nY,4] += nBase
							aImpos[nY,5] += (cTblTmpBrd)->FK3_VALOR
						EndIf

						//Recnos dos registros pendentes de retenção.
						Aadd(aImpos[nY,7], (cTblTmpBrd)->FK3RECNO)
						(cTblTmpBrd)->(DbSkip())
					EndDo
				EndIf
			EndIf
		Next nY
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FinCumCLF()

Verifica a cumulatividade dos impostos

@author  Mauricio Pequim Jr/Sivaldo Oliveira
@since 27/09/2017
@version 12
/*/
//-------------------------------------------------------------------
Static Function FinCumCLF(cCart As Character,cCliFor As Character,cLoja As Character,cFilOrig as Character)
	Local cRaizCnpj As Character
	Local aAreaAt   As Array

	Default cCart    := ''
	Default cCliFor  := ''
	Default cloja    := ''
	Default cFilOrig := cFilAnt

	cRaizCnpj := ""
	aAreaAt	:= GetArea()

	If Empty(cCart) .Or. Empty(cCliFor) .Or. Empty(cLoja)
		cCliFor := ""
	Else
		If cCart == '1' //Fornecedor
			SA2->(dbSetOrder(1))

			If SA2->(MsSeek(xFilial("SA2",cFilOrig) + cCliFor + cLoja))
				cRaizCnpj := Substr(SA2->A2_CGC, 1, 8)
				cCliFor := ""

				Do Case
					Case FKO->FKO_MODCUM == "1" //Codigo do Cliente + Loja Atual
						cCliFor += "FK3.FK3_CLIFOR = '" + SA2->A2_COD + "' AND FK3.FK3_LOJA = '" + SA2->A2_LOJA + "' "
					Case FKO->FKO_MODCUM == "2"//Codigo do Cliente
						cCliFor += "FK3.FK3_CLIFOR = '" + SA2->A2_COD + "' "
					Case (!Empty(SA2->A2_CGC) .And. (FKO->FKO_MODCUM == "3" .Or. SA2->A2_TIPO == "F"))//Cnpj/Cpf
						cCliFor += "FK3.FK3_CGC = '" + SA2->A2_CGC + "' "
					Case !Empty(SA2->A2_CGC) .And. FKO->FKO_MODCUM == "4" .And. SubStr(SA2->A2_CGC, 1, 8) == cRaizCnpj//Raiz do Cnpj
						cCliFor += "FK3.FK3_RAICGC = '" + cRaizCnpj + "' "
				EndCase
			EndIf
		Else //Cliente
			SA1->(dbSetOrder(1))

			If SA1->(MsSeek(xFilial("SA1",cFilOrig) + cCliFor + cLoja))
				cRaizCnpj := Substr(SA1->A1_CGC, 1, 8)
				cCliFor := ""

				Do Case
					Case FKO->FKO_MODCUM == "1" //Codigo do Cliente + Loja Atual
						cCliFor += "FK3.FK3_CLIFOR = '" + SA1->A1_COD + "' AND FK3.FK3_LOJA = '" + SA1->A1_LOJA + "' "
					Case FKO->FKO_MODCUM == "2"//Codigo do Cliente
						cCliFor += "FK3.FK3_CLIFOR = '" + SA1->A1_COD + "' "
					Case (!Empty(SA1->A1_CGC) .And. (FKO->FKO_MODCUM == "3" .Or. SA1->A1_TIPO == "F"))//Cnpj/Cpf
						cCliFor += "FK3.FK3_CGC = '" + SA1->A1_CGC + "' "
					Case !Empty(SA1->A1_CGC) .And. FKO->FKO_MODCUM == "4" .And. SubStr(SA1->A1_CGC, 1, 8) == cRaizCnpj//Raiz do Cnpj
						cCliFor += "FK3.FK3_RAICGC = '" + cRaizCnpj + "' "
				EndCase
			EndIf
		EndIf
	EndIf

	RestArea(aAreaAt)
Return cCliFor


//-------------------------------------------------------------------
/*/{Protheus.doc} FinQryCum()
Filtro os movimentos de inclusão de pcc pendente de retenção, para compor
a base de cálculo para retenção por cumulatividade

@author  Mauricio Pequim Jr/Sivaldo Oliveira/Leonardo Castro
@since 16/10/2017
@version 12
/*/
//-------------------------------------------------------------------
Static Function FinQryCum(cCart As Character, cCliFor As Character, cLoja As Character, dDtRef As Date, cFils As Character, cFilOrig As Character, lFilComp As Logical, cCodFKK As Character, lBaixa As Logical, cChaveTit As Character)
	Local lRet       As Logical
	Local cCampoQry  As Character
	Local cTabQry    As Character
	Local cWherQry   As Character
	Local cQry       As Character
	Local cTblTmp    As Character
	Local lExcSedSe2 As Logical
	Local aAreaAt    As Array
	Local cCarteira  As Character
	Local cInvertC   As Character
	Local cTabOri    As Character
	Local cTabEmi    As Character

	//Parâmetros da função
	Default cCart     := ""
	Default cCliFor   := ""
	Default cLoja     := ""
	Default dDtRef    := dDataBase
	Default cFils     := ""
	Default cFilOrig  := ""
	Default lFilComp  := .F.
	Default cCodFKK   := ""
	Default lBaixa    := .F.
	Default cChaveTit := ""

	//Inicializa as variáveis
	lRet := .T.
	aAreaAt := GetArea()
	cTblTmp := ""
	cCampoQry := ""
	cTabQry := ""
	cWherQry := ""
	cQry := ""
	lExcSedSe2	:= !Empty(FWFilial("SE2")) .And. !Empty(FWFilial("SED"))
	cCarteira := ""
	cInvertC := ""
	cTabOri := ""
	cTabEmi := ""

	If cCart == "1"
		cCarteira := "P"
		cInvertC := "R"
		cTabOri := "FK2"
		cTabEmi := "SE2"
	ElseIf cCart == "2"
		cCarteira := "R"
		cInvertC := "P"
		cTabOri := "FK1"
		cTabEmi := "SE1"
	EndIf

	If Empty(cCart) .Or. Empty(cCliFor+cLoja)
		lRet := .F.
	EndIf

	cCliFor := FinCumCLF(cCart,cCliFor,cLoja,cFilOrig)

	If lRet .And. !Empty(cCliFor)
		cTblTmp := GetNextAlias()

		If lBaixa
			cQry := " SELECT "
			// Campos FKA
			cCampoQry += " FKA.FKA_IDFKA , FKA.FKA_IDPROC, "
			// Campos FK2 / FK1
			cCampoQry += Iif(cCart == "1", " FK2.FK2_IDFK2, ", " FK1.FK1_IDFK1, ")
			// Campos FK3
			cCampoQry += " FK3.FK3_FILIAL, FK3.FK3_IDFK3, FK3.FK3_DATA, FK3.FK3_VALOR, FK3.FK3_MOEDA, FK3.FK3_NATURE, FK3.FK3_RECPAG, FK3.FK3_IDRET, "+;
							" FK3.FK3_IMPOS, FK3.FK3_FILORI, FK3.FK3_BASIMP, FK3.FK3_ORIGEM, FK3.FK3_VLMOE2, FK3.FK3_IDORIG, FK3.FK3_TABORI, "+;
							" FK3.FK3_STATUS, FK3.FK3_CODFKM, FK3.FK3_CLIFOR, FK3.FK3_CGC, FK3.FK3_RAICGC, FK3.R_E_C_N_O_ FK3RECNO, "
			// Campos FK4
			cCampoQry += " ISNULL(FK4.FK4_VALOR,0) FK4_VALOR, ISNULL(FK4.FK4_VLMOE2,0) FK4_VLMOED2, ISNULL(FK4.FK4_BASIMP,0) FK4_BASIMP, "+;
							" ISNULL(FK4.FK4_DATA,' ') FK4_DATA, ISNULL(FK4.FK4_STATUS,' ') FK4_STATUS "

			// Tabelas
			cTabQry += " FROM " + RetSqlName("FKA") + " FKA "
			If cCart == "1"
				cTabQry += " INNER JOIN " + RetSqlName("FK2") + " FK2 ON ( FK2_FILIAL = FKA_FILIAL AND FK2_IDFK2 = FKA_IDORIG ) "
				cTabQry += " INNER JOIN " + RetSqlName("FK3") + " FK3 ON ( FK3_FILIAL = FK2_FILIAL AND FK3_IDORIG = FK2_IDFK2 ) "
			ElseIf cCart == "2"
				cTabQry += " INNER JOIN " + RetSqlName("FK1") + " FK1 ON ( FK1_FILIAL = FKA_FILIAL AND FK1_IDFK1 = FKA_IDORIG ) "
				cTabQry += " INNER JOIN " + RetSqlName("FK3") + " FK3 ON ( FK3_FILIAL = FK1_FILIAL AND FK3_IDORIG = FK1_IDFK1 ) "
			EndIf

			cTabQry += "  LEFT JOIN " + RetSqlName("FK4") + " FK4 ON ( FK4_FILIAL = FK3_FILIAL AND FK4_IDFK4 = FK3_IDRET ) "

			// Clausula
			cWherQry += " WHERE "
			cWherQry += " FKA.FKA_TABORI = '" + cTabOri + "' "
			cWherQry += " AND FK3.FK3_CODFKM = '" + cCodFKK + "' "
			cWherQry += " AND FK3.FK3_FILORI IN " + FinTipoIN(cFils) + " "

			If FKO->FKO_PERCUM == '1' // Diária
				cWherQry += " AND FK3.FK3_DATA = '" + DToS(dDtRef) + "' "
			ElseIf FKO->FKO_PERCUM == '4' // Mensal
				cWherQry += " AND FK3.FK3_DATA BETWEEN '"+ Dtos(FirstDay( dDtRef)) +"' AND '"+ Dtos(LastDay( dDtRef)) +"' "
			EndIf

			cWherQry += " AND " + cTabOri + ".D_E_L_E_T_ = ' ' AND FK3.D_E_L_E_T_ = ' ' AND FKA.D_E_L_E_T_ = ' ' " // Controle de Deletados

			//Clientes/Fornecedores a serem considerados na cumulatividade
			cWherQry += " AND " + cCliFor

			// Controle de Gerados
			cQry += cCampoQry + cTabQry + cWherQry + " AND FK3.FK3_STATUS = '1' AND FK3.FK3_RECPAG = '" + cCarteira + "' "

			// Controle de Estornados
			cQry += " AND FKA_IDPROC NOT IN ( SELECT FKA.FKA_IDPROC " + cTabQry + cWherQry +;
					" AND FK3.FK3_STATUS = '2' AND FK3.FK3_RECPAG = '" + cInvertC + "' "
		Else
			cQry := "SELECT "
			// Campos FK3
			cCampoQry += "FK3.FK3_VALOR, FK3.FK3_BASIMP, FK3.FK3_IMPOS, FK3.FK3_DATA, FK3.FK3_MOEDA, FK3.FK3_CODFKM, FK3.FK3_IDRET, FK3.FK3_FILORI,FK3.R_E_C_N_O_ FK3RECNO,"
			// Campos FK4
			cCampoQry += "ISNULL(FK4.FK4_VALOR, 0) FK4_VALOR "
			// Tabelas e Ralcionamentos
			cTabQry += "FROM " + RetSqlName("FKA") + " FKA "
			//Relacionamento direto FKA x FK7
			cTabQry += "INNER JOIN " + RetSqlName("FK7") + " FK7 ON (FKA.FKA_IDORIG = FK7.FK7_IDDOC AND FKA.FKA_TABORI = FK7.FK7_ALIAS AND FKA.FKA_FILIAL = FK7.FK7_FILIAL) "
			//Relacionamento direto FKA x FK3
			cTabQry += "INNER JOIN " + RetSqlName("FK3") + " FK3 ON (FKA.FKA_IDORIG = FK3.FK3_IDORIG AND FKA.FKA_FILIAL = FK3.FK3_FILIAL) "
			//Relacionamento indireto FK3 x FK4
			cTabQry += "LEFT JOIN " + RetSqlName("FK4") + " FK4 ON (FK3.FK3_IDORIG = FK4.FK4_IDORIG AND FK3.FK3_FILIAL = FK4.FK4_FILIAL AND "
			cTabQry += "FK3.FK3_CODFKM = FK4.FK4_CODFKM AND FK4.D_E_L_E_T_ = ' ') "
			//Filtro emissão.
			cWherQry += "WHERE FK3.FK3_FILORI IN " + FMRTipoIN(cFils) + " AND "

			If FKO->FKO_PERCUM == '1' // Diária
				cWherQry += "FK3.FK3_DATA = '" + DToS(dDtRef) + "' AND "
			ElseIf FKO->FKO_PERCUM == '4' // Mensal
				cWherQry += "FK3.FK3_DATA BETWEEN '"+ Dtos(FirstDay( dDtRef)) +"' AND '"+ Dtos(LastDay( dDtRef)) +"' AND "
			EndIf

			cWherQry += "FK3.FK3_CODFKM = '" + cCodFKK + "' AND "
			cWherQry += "FK3.FK3_TABORI = '" + cTabEmi + "' AND "

			//Desconsidera o título alterado
			If !Empty(cChaveTit)
				cWherQry += "FK7.FK7_CHAVE <> '" + cChaveTit + "' AND "
			EndIf

			cWherQry +=  cCliFor + " AND FKA.D_E_L_E_T_ = ' ' AND FK3.D_E_L_E_T_ = ' ' AND "
			cQry += cCampoQry + cTabQry + cWherQry
			//cQry += "FK3.FK3_IDRET = ' ' AND "
			cQry += "FK3.FK3_RECPAG = '" + cCarteira + "' AND "
			cQry += "FK3.FK3_IDORIG NOT IN ("
			//Filtro de estorno.
			cQry += "SELECT DISTINCT FKA.FKA_IDORIG " + cTabQry + cWherQry
			cQry += "FK3.FK3_RECPAG = '" + cInvertC + "')"
		EndIf

		cQry := ChangeQuery( cQry )

		If Select(cTblTmp) > 0
			(cTblTmp)->(dbCloseArea())
		Endif

		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), cTblTmp, .F., .T.)

		If (cTblTmp)->(EOF())
			(cTblTmp)->(dbCloseArea())
			cTblTmp := ""
		EndIf
	EndIf

	RestArea(aAreaAt)
Return cTblTmp

//-------------------------------------------------------------------
/*/{Protheus.doc} FinSelFil
seleciona as filiais que serão considerada na cumulatividade

@author Mauricio Pequim Jr
@since  06/01/2016
@version 12.1.7
/*/
//-------------------------------------------------------------------
Static Function FinSelFil(aFils As Array)
	Local cFils As Character
	Local cCgc  As Character
	Local nX    As Numeric
	Local aSM0  As Array
	Local nSM0  As Numeric

	aFils := {}
	
	//Inicicializa variáveis
	cFils := ""
	cCgc := ""
	nX := 0
	aSM0 := FWLoadSM0()
	nSM0 := Len(aSM0)

	//Valida o critério de geração da cumulatividade (filial corrente, fornec, cnpj ou raiz cnpj)
	If FKO->FKO_CUMFIL == "1" //Filial Corrente
		cFils := cFilAnt
	ElseIf FKO->FKO_CUMFIL == "2" //cnpj da filial (SM0)
		cCgc := SM0->M0_CGC
	Else//Raiz do cnpj (SM0)
		cCgc := Substr(SM0->M0_CGC,1,8)
	Endif

//Monto as informações das filiais para cumulatividade
//CNPJ das filiais ou raiz do CNPJ das filiais no SM0 (EMPRESA DO PROTHEUS)
If FKO->FKO_CUMFIL != "1"
	For nX := 1 To nSM0
		If aSM0[nX, 1] <> SM0->M0_CODIGO
			Exit
		EndIf

		If((FKO->FKO_CUMFIL == "2" .And. aSM0[nX, 18] == cCgc) .Or. (FKO->FKO_CUMFIL == "3" .And. SubStr(aSM0[nX, 18], 1, 8) == cCgc) .Or. FKO->FKO_CUMFIL == "4")
			cFils += aSM0[nX, 2] + "|"
			Aadd(aFils, aSM0[nX, 2]) 
		EndIf
	Next nX

	cFils := Substr(cFils,1,Len(cFils)-1)
EndIf

If Len(aFils) == 0
	Aadd(aFils, cFilAnt) 
EndIf

Return cFils

//-------------------------------------------------------------------
/*/{Protheus.doc} FinImpConf()
Verifica quais impostos estão configurados
(Natureza x Fornecedor ou Natureza x Cliente)

@author Sivaldo Oliveira
@since 08/11/2017
@version 12
/*/
//-------------------------------------------------------------------
Function FinImpConf(cCart As Character,cFilOrig As Character,cCliFor As Character,cLoja As Character, cNatur As Character) As Array
	Local lRet    As Logical
	Local cQry    As Character
	Local aImpos  As Array
	Local cAlias  As Character
	Local cTblTmp As Character
	Local aArea   As Array

	//Parâmetros da função
	Default cCart    := ""
	Default cFilOrig := cFilAnt
	Default cCliFor  := ""
	Default cLoja    := ""
	Default cNatur   := ""

	//Inicializa as variáveis
	lRet    := .T.
	cQry    := ""
	aImpos  := {}
	cTblTmp := ""

	If Empty(cCart) .Or. Empty(cCliFor) .Or. Empty(cLoja) .Or. Empty(cNatur)
		lRet := .F.
	EndIf

	If lRet
		cAlias  := If(cCart == '1', "FOK", "FOJ")
		aArea   := GetArea()

		cQry := "SELECT FOO.FOO_CODIGO,FKK.FKK_FATGER,FKK.FKK_IDRET,FKL_TIPMOV,FKL_TIPO,FKK.FKK_VLNOTA,FKK.FKK_ADTO "
		cQry += ",FKK.FKK_FILIAL, FKK.FKK_VIGINI, FKK.FKK_VIGFIM, FKK.FKK_PARCTO "

		//Tabela Principal da consulta
		cQry += "FROM " + RetSqlName("FKK") + " FKK "
		//Regra Financeira x Tipo de Imposto
		cQry += " INNER JOIN " + RetSqlName("FOO") + " FOO "
		cQry += " ON (FOO.FOO_FILIAL = FKK.FKK_FILIAL "
		cQry += " AND FOO.FOO_IDRET  = FKK.FKK_IDRET "
		cQry += " AND FOO.FOO_TIPIMP = '1' ) "
		cQry += " AND FOO.D_E_L_E_T_ = ' '"
		//Regra Financeira x natureza - > Obrigatório
		cQry += "INNER JOIN " + RetSqlName("FOI") + " FOI "
		cQry += " ON FOI.FOI_FILIAL  = ? "
		cQry += " AND FOI.FOI_CODIGO = FKK.FKK_CODIGO "
		cQry += " AND FOI.FOI_NATURE = ? "
		cQry += " AND FOI.D_E_L_E_T_ = ' '"
		//Regra Financeira x cliente/fornecedor
		cQry += "INNER JOIN " + RetSqlName(cAlias) + " " + cAlias 
		cQry += " ON " + cAlias + "." + cAlias + "_FILIAL = ? " 
		cQry += " AND "+cAlias + "." + cAlias + "_CODIGO = FKK.FKK_CODIGO "
		cQry += " AND " + If(cCart == "1", "FOK.FOK_FORNEC", "FOJ.FOJ_CLIENT") + " = ? "
		cQry += " AND " + cAlias + "." + cAlias + "_LOJA = ? "
		cQry += " AND " + cAlias + ".D_E_L_E_T_ = ' '"
		//Regra Financeira x Regra de Título
		cQry += "INNER JOIN " + RetSqlName("FKL") + " FKL "
		cQry += "ON FKL.FKL_FILIAL   = FKK.FKK_FILIAL "
		cQry += " AND FKL.FKL_IDRET  = FKK.FKK_IDFKL  "
		cQry += " AND FKL.FKL_CODIGO = FKK.FKK_CODFKL "
		cQry += " AND FKL.D_E_L_E_T_ = ' ' "

		//Regra Financeira x Regra de Cálculo
		cQry += "LEFT JOIN " + RetSqlName("FKN") + " FKN "
		cQry += "ON FKN.FKN_FILIAL   = FKK.FKK_FILIAL "
		cQry += " AND FKN.FKN_CODIGO = FKK.FKK_CODFKN "
		cQry += " AND FKN.FKN_IDRET  = FKK.FKK_IDFKN "
		cQry += " AND FKN.D_E_L_E_T_ = ' ' "
		//Regra Financeira x Regra de Vencimento
		cQry += "LEFT JOIN " + RetSqlName("FKP") + " FKP "
		cQry += "ON FKP.FKP_FILIAL   = FKK.FKK_FILIAL "
		cQry += " AND FKP.FKP_CODIGO = FKK.FKK_CODFKP "
		cQry += " AND FKP.FKP_IDRET  = FKK.FKK_IDFKP "
		cQry += " AND FKP.D_E_L_E_T_ = ' ' "

		//Filtro da consulta
		cQry += " WHERE FKK.FKK_FILIAL = ? "
		cQry += " AND FKK.FKK_ATIVO    = '1' "
		cQry += " AND FKK.D_E_L_E_T_   = ' ' "

		oPrepCP := FWPreparedStatement():New(cQry)
		oPrepCP:SetString(1, xFilial("FOI", cFilOrig))
		oPrepCP:SetString(2, cNatur)
		oPrepCP:SetString(3, xFilial(cAlias, cFilOrig))
		oPrepCP:SetString(4, cCliFor)
		oPrepCP:SetString(5, cLoja)
		oPrepCP:SetString(6, xFilial("FKK", cFilOrig))

		cQry := oPrepCP:GetFixQuery()
		cTblTmp := MpSysOpenQuery(cQry)

		While (cTblTmp)->(!Eof())
			Aadd(aImpos, { AllTrim((cTblTmp)->FOO_CODIGO), (cTblTmp)->FKK_FATGER, (cTblTmp)->(FKK_FILIAL+FKK_IDRET),;
			(cTblTmp)->FKL_TIPMOV, (cTblTmp)->FKK_VLNOTA, (cTblTmp)->FKK_ADTO, (cTblTmp)->FKK_PARCTO ,(cTblTmp)->FKL_TIPO} )
			(cTblTmp)->(DbSkip())
		EndDo
		(cTblTmp)->(DbCloseArea())

		RestArea(aArea)
		aSize(aArea,0)
		aArea := nil 
	EndIf
Return aImpos

//-------------------------------------------------------------------
/*/{Protheus.doc} FMRTipoIN
Monta a expressão do NOT IN da query

@author Mauricio Pequim Jr
@since  06/01/2016
@version 12.1.7
/*/
//-------------------------------------------------------------------

Function FMRTipoIN(cTipos As Character, lQryIn As Logical)

Default cTipos := MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM+"/"+MVFUABT
Default lQryIn := .T.

cTipos	:=	StrTran(cTipos,',','/')
cTipos	:=	StrTran(cTipos,';','/')
cTipos	:=	StrTran(cTipos,'|','/')
cTipos	:=	StrTran(cTipos,'\','/')

If lQryIn
	cTipos := Formatin(cTipos,"/")
Endif

Return cTipos


//-------------------------------------------------------------------
/*/{Protheus.doc} FinGrvImp
Gravação dos titulos de impostos - Emissão

@aparam	cCart - Carteira do processo (1- Pagar ou 2 -Receber)
@aparam	nRecTitPai - Recno do Titulo Pai
@aparam	aImpos - Array contendo os impostos a gravar
@aparam	cOrigem - Origem do Movimento (FINA040, FINA050, FINA070, FINA080 etc.)
@aparam	lBaixa - Define se os impostos estão sendo gravados por uma baixa ou geração de RA/PA
@aparam	dBaixa - Data da baixa para fins de cumulatividade do imposto
@aparam	lRatImp - Indica que possui rateio multinatureza para os impostos (SEV/SEZ)
@aparam	aRatSev - Array contendo o rateio Multinatureza a ser gravado para o titulo de imposto (SEV)
@aparam	aRatSez - Array contendo o rateio Multinatureza por C.Custo a ser gravado para o titulo de imposto (SEZ)
@aparam	lAtuSalDup - Indica que deve ser atualizado o saldo de diplicatas do Cliente ou Fornecedor
@aparam	lLojaDin - Indica que é um movimento vindo do SigaLoja e que não atualizará saldo de duplicatas
@aparam lBaixa - Indica se trata-se de gera‡?o de impostos na baixa
@aparam dBaixa - Data da baixa
@aparam cTabOri - Tabela de Origem da baixa

@Return	aRecImpos - retorna array contendo os recnos dos impostos gerados

@author Mauricio Pequim Jr
@since  06/01/2016
@version 12.1.7
/*/
//-------------------------------------------------------------------
Function FinGrvImp(cCart As Character, nRecTitPai As Numeric, aImpos As Array, cOrigem As Character, ;
					lRatImp As Logical, aRatSev As Array ,aRatSez As Array, lAtuSalDup As Logical, lLojaDin As Logical, ;
					lBaixa As Logical, dBaixa As Date, cTabOri As Character ,cSeq As Character, lGerBx AS Logical, cFilOrig as Character  ) As Array

Local aArea	As Array
Local aAreaSE As Array
Local aAreaSA As Array
Local aEmpDados	As Array
Local aRecImpos As Array
Local cNatureza	As Character
Local cTitPai As Character
Local cCodAprov As Character
Local cParcPai As Character
Local cParcela As Character
Local cGeraDirf As Character
Local cCliForImp As Character
Local cLojaImp As Character
Local cCNPJRet As Character
Local cNomeCom As Character
Local cCodIrrf As Character
Local cFatura As Character
Local cLA As Character
Local cTipoMov As Character
Local cTipoImp As Character
Local cAliasPai As Character
Local nTpInsc As Numeric
Local nSM0Recno As Numeric
Local nTamImpos As Numeric
Local nX As Numeric
Local lCampos As Logical
Local lAdianto As Logical
Local lImpEmis As Logical
Local nTaxaTit As Numeric

//Calculo da data de vencimento
Local dVencto As Date
Local nVcDia As Numeric
Local cVcTipo As Character
Local cVcDuti As Character
Local cVcPeriodo As Character
Local nVcQtdPer As Numeric
Local cVcDtVld As Character
Local dBaseCalc As Date
Local dVencImp As Date

DEFAULT cCart := ""
DEFAULT nRecTitPai := 0
DEFAULT aImpos := {}
DEFAULT cOrigem := ""
DEFAULT lBaixa := .F.
DEFAULT dBaixa := CTOD("//")
DEFAULT lRatImp := .F.
DEFAULT aRatSEV := {}
DEFAULT aRatSEZ := {}
DEFAULT lAtuSalDup	:= .T.
DEFAULT lLojaDin	:= .F. //Pagamento da loja em dinheiro
DEFAULT cSeq		:= "00"
DEFAULT lGerBx   	:= .F.
DEFAULT cFilOrig	:= cFilAnt

aArea		:= GetArea()
aAreaSE		:= If(cCart == '1', SE2->( GetArea()), SE1->( GetArea() ) )
aAreaSA		:= If(cCart == '1', SA2->( GetArea()), SA1->( GetArea() ) )
aRecImpos	:= {}
aEmpDados	:= {}
cNatureza	:= ""
cTitPai		:= ""
cParcPai	:= ""
cParcela	:= ""
cCNPJRet	:= ""
cNomeCom	:= ""
cOrigem 	:= Upper(Alltrim(cOrigem))
cFatura		:= ""
cLA			:= ""
cTipoMov	:= ""
cTipoImp	:= ""
nTpInsc		:= 0
nSM0Recno	:= 0
nTamImpos	:= Len(aImpos)
nX			:= 0
lCampos		:= If(lCampos != NIL, lCampos, (SE2->(ColumnPos("E2_NOMERET")) > 0 .and. SE2->(ColumnPos("E2_CNPJRET")) > 0 .and. SE2->(ColumnPos("E2_TPINSC")) > 0) )
lDtApur		:= If(lDtApur != NIL, lDtApur, (SE2->(ColumnPos("E2_DTAPUR")) > 0) )
lFINA061	:= (Alltrim(FunName()) $ "FINA061_FINA590" .or. FwIsInCallStack("FA061Borde"))
dBaseCalc	:= IF(lBaixa, dBaixa, dDataBase)
lAdianto	:= .F.
lImpEmis	:= .F.
nTaxaTit	:= 1

If !lBaixa
	If cCart == "1"
		FinDelEst("SE2", nRecTitPai)
	ElseIf cCart == "2"
		FinDelEst("SE1", nRecTitPai)
	EndIf
Endif

//Efetua o processo apenas se o array de impostos a serem gravados possuir dados
If nTamImpos > 0
	//Obtém informações do titulo pai a serem utilizados no processo
	If cCart == '1'	//Pagar

		SE2->(DbGoTo(nRecTitPai))
		cTitPai		:= SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
		cCliForPai	:= SE2->E2_FORNECE
		cLojaPai	:= SE2->E2_LOJA
		cTipoPai	:= SE2->E2_TIPO
		cParcPai	:= SE2->E2_PARCELA
		cFilOrig	:= If(Empty(SE2->E2_FILORIG), cFilAnt, SE2->E2_FILORIG)
		cPrefixo	:= SE2->E2_PREFIXO
		cNum		:= SE2->E2_NUM
		cGeraDirf	:= SE2->E2_DIRF
		cLA			:= SE2->E2_LA
		cNomReduz	:= SE2->E2_NOMFOR
		cCodAprov	:= SE2->E2_CODAPRO
		dEmissao 	:= SE2->E2_EMISSAO
		dVencto		:= SE2->E2_VENCREA
		dEmis1		:= SE2->E2_EMIS1
		cRETINS		:= SE2->E2_RETINS
		cAliasPai	:= "SE2"
		lAdianto	:= (cTipoPai $ MVPAGANT)

		SA2->(DbSetOrder(1))
		SA2->(dbSeek(xFilial('SA2', cFilOrig) + cCliForPai + cLojaPai) )

		cTipoFor	:= SA2->A2_TIPO
		cCNPJRET	:= SA2->A2_CGC

		If cTipoFor == "J"
			cCNPJRET := SA2->A2_CGC
		Else
			cCNPJRET := GetAdvFval("SM0","M0_CGC",cEmpAnt+xFilial("SE2"),1,"")
		EndIf

	Else

		SE1->(DbGoTo(nRecTitPai))

		cTitPai		:= SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
		cCliForPai	:= SE1->E1_CLIENTE
		cLojaPai	:= SE1->E1_LOJA
		cTipoPai	:= SE1->E1_TIPO
		cParcPai	:= SE1->E1_PARCELA
		cFilOrig	:= If(Empty(SE1->E1_FILORIG), cFilAnt, SE1->E1_FILORIG)
		cPrefixo	:= SE1->E1_PREFIXO
		cNum		:= SE1->E1_NUM
		cGeraDirf	:= ""
		cLA			:= SE1->E1_LA
		cNomReduz	:= SE1->E1_NOMCLI
		cCodAprov	:= ""
		dEmissao 	:= SE1->E1_EMISSAO
		dVencto		:= SE1->E1_VENCREA
		dEmis1		:= SE1->E1_EMIS1
		nTaxaTit	:= SE1->E1_TXMOEDA
		cCodIrrf	:= Iif(cPaisLoc == "BRA",SE1->E1_CODIRRF,"")
		cFatura		:= SE1->E1_FATURA
		cAliasPai	:= "SE1"
		lAdianto	:= (cTipoPai $ MVRECANT)

		SA1->(DbSetOrder(1))
		SA1->(dbSeek(xFilial('SA1', cFilOrig) + cCliForPai + cLojaPai))

	Endif

	/*-------------------------------------------
	Estrutura da aImpos
	[1]  = Codigo do tipo de imposto (FKK_CODIGO)
	[2]  = Base do imposto
	[3]  = Valor calculado do imposto
	[4]  = Base de retenção do imposto
	[5]  = Valor a reter do imposto
	[6]  = IDRET FK4
	[7]  = Array contendo os Recnos FK3 das pendências de retenção
	[8]  = Tipo do Imposto (FOO)
	[9]  = Regime (1 = Competência ou 2 = Baixa)
	[10] = Natureza do imposto
	[11] = Tabela onde foi gerado o imposto
	[12] = Recno do titulo de imposto gerado
	[13] = Ação aplicada no valor da nota (1 = subtrai, 2 = soma, 3 = sem ação)
	[14] = Carteira de movimento do imposto (1 = Pagar, 2 = Receber)
	[15] = Tipo de movimento (1 = Abtimento, 2 = Impostos)
	[16] = Flag que valida se houve retenção no período para o imposto
	[17] = Variável de contabilização
	[18] = Chave única da tabela Id de retenção
	[19] = Ação sobre títulos de antecipação pagamento/recebimento: 1 = Retém, 3 = sem ação
	[20] = Flag que valida se houve retenção no período para o imposto
	[21] = Recno da FKK
	[22] = Valor retido previamente para determinado imposto
	[23] = Codigo de retenção
	--------------------------------------------*/
	For nX := 1 to nTamImpos
		//Na inclusão só gera títulos conf na baixa se estiver provisionando. Exceto PAs/RAs
		If !lBaixa .And. aImpos[nX,9] == "2" .And. aImpos[nX,16] != "1" .and. !lAdianto
			Loop
		EndIf

		FKK->(DbGoto(aImpos[nX,21]))

		If !lBaixa
			lImpEmis := .T.
		Endif

		If aImpos[nX,5] > 0 .And. FKK->(!Eof())
			cTipoRet := aImpos[nX,8]
			cCodRet  := FKK->FKK_CODRET
			cRegime  := FKK->FKK_FATGER
			cNatImp :=  aImpos[nX,10]
			lCalcDtVc := .F.

			//Posiciona na Regra de Titulo - caso não tenha não gravo o imposto
			If !Empty(FKK->FKK_IDFKL)
				FKL->(DBSetOrder(1))	//filial+ idret
				FKL->(MSSeek(xfilial("FKL")+FKK->FKK_IDFKL))
			Endif

			//Posiciona na Regra de VENCIMENTO - caso não tenha não gravo o imposto
			If !Empty(FKK->FKK_IDFKP)
				FKP->(DBSetOrder(1))	//filial+ idret
				FKP->(MSSeek(xfilial("FKL")+FKK->FKK_IDFKP))
			Endif

			If lBaixa
				cTipoMov	:= FKL->FKL_TIPMOV		//1=Abatimento;2=Impostos
				cCliForImp	:= IF( cTipoMov != '1' .and. !Empty(FKL->FKL_PARTIC),FKL->FKL_PARTIC, cCliForPai)
				cLojaImp 	:= IF( cTipoMov != '1' .and. !Empty(FKL->FKL_LOJA)  ,FKL->FKL_LOJA  , cLojaPai)
				cCartMov	:= FKL->FKL_CARTMV		//Onde será gerado o titulo de imposto (SE1 ou SE2)
				cTipoImp 	:= FKL->FKL_TIPO		//Tipo do títulos de imposto

				If cTipoMov == '1'	//Abatimento
					dVencImp := dVencto
				Else
					dBaseCalc := dBaixa
					lCalcDtVc := .T.
				Endif
			Else
				cTipoMov := FKL->FKL_TIPMOV
				cTipoImp := If(aImpos[nX,9] == "2" .And. aImpos[nX,16] == "1", MVPROVIS, FKL->FKL_TIPO)

				If lAdianto
					cCliForImp := FKL->FKL_PARTIC
					cLojaImp   := FKL->FKL_LOJA
				Else
					cCliForImp	:= IF( cTipoMov != '1' .and. !Empty(FKL->FKL_PARTIC),FKL->FKL_PARTIC, cCliForPai)
					cLojaImp 	:= IF( cTipoMov != '1' .and. !Empty(FKL->FKL_LOJA)  ,FKL->FKL_LOJA  , cLojaPai)
				Endif

				cCartMov	:= FKL->FKL_CARTMV		//Onde será gerado o titulo de imposto (SE1 ou SE2)

				If cTipoMov == '1' .OR. lAdianto  //Abatimento ou retenção de adiantamento
					dVencImp := dVencto
				Else
					lCalcDtVc := .T.
				Endif
			Endif

			//Caso o movimento do imposto seja a Pagar, ajusto o nome do fornecedor
			If cCartMov == '1'
				cNomReduz	:= Posicione('SA2',1,xfilial("SA2") + cCliForImp + cLojaImp ,'A2_NREDUZ')
			Endif

			If lCalcDtVc .or. lAdianto

				nVcDia        := FKP->FKP_DIAVCT
				cVcTipo       := FKP->FKP_TIPVCT
				cVcDuti       := FKP->FKP_DATVCT
				cVcPeriodo    := FKP->FKP_PRDVCT
				nVcQtdPer     := FKP->FKP_QTPERI
				cVcDtVld      := FKP->FKP_DTVLVC

				If FKP->FKP_BASEVC == '1'		//Emissão
					dBaseCalc := dEmissao
				ElseIf FKP->FKP_BASEVC == '2'	//Vencto real (VENCREA)
					dBaseCalc := dVencto
				Else							//Emissão Contábil (EMIS1)
					dBaseCalc := dEmis1
				Endif

				//Data de vencimento
				dVencImp := FMRCalcVc(dBaseCalc, nVcDia, cVcTipo, cVcDuti, cVcPeriodo, nVcQtdPer, cVcDtVld)
			Endif

			cAliasImp := If(cCartMov == '1', 'SE2', 'SE1')

			If lAdianto .and. cCartMov == '1'
				cParcela := FinPcImp(cAliasImp,cPrefixo,cNum,cTipoImp,cCliForImp,cLojaImp,cFilOrig)
			Else
				If cTipoMov == '1'
					cParcela := cParcPai
				Else
					cParcela := FinPcImp(cAliasImp,cPrefixo,cNum,cTipoImp,cCliForImp,cLojaImp,cFilOrig)
				Endif
			Endif

			DbSelectArea(cAliasImp)
			DbSetOrder(1)
			aImpos[nX,11] := cAliasImp
			
			If !( (cAliasImp)->(Dbseek(xFilial(cAliasImp,cFilOrig) + cPrefixo + cNum + cParcela + cTipoImp + cCliForImp + cLojaImp ) ) )
				If cAliasImp == 'SE1'
					DbSelectArea("SE1")
					RecLock("SE1",.T.)
					SE1->E1_FILIAL	:= xFilial(cAliasImp,cFilOrig)
					SE1->E1_PREFIXO := cPrefixo
					SE1->E1_NUM		:= cNum
					SE1->E1_PARCELA	:= cParcela
					SE1->E1_TIPO	:= cTipoImp
					SE1->E1_CLIENTE := cCliForImp
					SE1->E1_LOJA	:= cLojaImp
					SE1->E1_EMISSAO	:= dEmissao
					SE1->E1_EMIS1	:= dDataBase
					SE1->E1_VENCTO	:= dVencImp
					SE1->E1_VENCORI	:= dVencImp
					SE1->E1_VENCREA	:= dVencImp
					SE1->E1_VALOR	:= aImpos[nX,5]
					SE1->E1_VLCRUZ	:= Round( aImpos[nX,5], MsDecimais(1) )
					SE1->E1_SALDO	:=  If(cCart == '2' .and. lGerBx,0,aImpos[nX,5])
					SE1->E1_SITUACA := "0"
					SE1->E1_NOMCLI	:= cNomReduz
					SE1->E1_MOEDA	:= If(cPaisLoc=="BRA",1,nMoeda)
					SE1->E1_OCORREN	:= "04"
					SE1->E1_ORIGEM	:= cOrigem
					SE1->E1_NATUREZ	:= cNatImp
					SE1->E1_LA		:= cLA
					SE1->E1_FATURA	:= cFatura
					SE1->E1_TXMOEDA	:= nTaxaTit
					SE1->E1_FILORIG	:= cFilOrig
					SE1->E1_TITPAI	:= cTitpai
					SE1->E1_STATUS  := Iif(SE1->E1_SALDO>0.01,"A","B")
					SE1->E1_SEQBX 	:= cSeq

					If cCart == '2' .and. lGerBx // Variavel que define se os impostos serão gerados baixados no contas a receber.
						SE1->E1_BAIXA		:= dBaixa
						SE1->E1_MOVIMEN 	:= dBaixa
						SE1->E1_SDACRES 	:= 0
						SE1->E1_SDDECRE 	:= 0
					Endif

					If cTipoRet $ 'IRF|IRRF'
						If (lBaixa .And. lFINA061)
							SE1->E1_STATUS	:= "B"
							SE1->E1_SALDO	:= 0
							SE1->E1_OCORREN	:= Space(2)
						Endif
						SE1->E1_CODIRRF	:= cCodIrrf
					Endif

					SE1->(MsUnlock())
					FKCOMMIT()
                    
                    if lPLSTITPF
					    PLSTITPF('SE1', cTitpai)
				    endIf

					//Complemento de gravação - Usuário
					If lFXIMPRC
						Execblock("FXIMPRC",.F.,.F.,nRecTitPai)
					Endif

					AADD(aRecImpos,{"SE1",SE1->(Recno())})
					aImpos[nX,12] := SE1->(Recno())

					AtuSldNat(SE1->E1_NATUREZ, SE1->E1_VENCREA, SE1->E1_MOEDA, "2", "R", SE1->E1_VALOR, SE1->E1_VLCRUZ, If(SE1->E1_TIPO $ MVABATIM,"-","+"))

					// Atualiza Saldo do Cliente
					DbSelectArea("SA1")

					If ( MsSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA) )) .And. lAtuSalDup
						If !lLojaDin	//Se NÃO for movimento do SIGALOJA em dinheiro, atualiza o saldo de duplicatas do Cliente
							AtuSalDup("-",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,SE1->E1_TXMOEDA,SE1->E1_EMISSAO,,,.T.)
						EndIf
					EndIf

					//--------------------------------------------------------------
					//Gravações complementares por tipo de imposto
					If cTipoRet $ 'IRF|IRRF'
						If cOrigem == "FINA040"
							PCODetLan("000001","06", cOrigem )
						EndIf

						DbSelectArea( 'SE1' )
						DbGoTo( nRecTitPai )
						Reclock( "SE1" , .F. )
						SE1->E1_PARCIRF := cParcela
						MsUnlock()

					ElseIf cTipoRet $ 'INS'
						If Upper(cOrigem) == "FINA040"
							PCODetLan("000001","07", cOrigem )
						EndIf
					ElseIf cTipoRet $ 'ISS'
						If cOrigem == "FINA040"
							PCODetLan("000001","08", cOrigem)
						EndIf
					Endif
				Else
					RecLock("SE2",.T.)
					SE2->E2_FILIAL  := xFilial(cAliasImp,cFilOrig)
					SE2->E2_PREFIXO := cPrefixo
					SE2->E2_NUM 	:= cNum
					SE2->E2_PARCELA := cParcela
					SE2->E2_TIPO	:= cTipoImp
					SE2->E2_FORNECE := cCliForImp
					SE2->E2_LOJA	:= cLojaImp
					SE2->E2_NOMFOR  := cNomReduz
					SE2->E2_VALOR	:= aImpos[nX,5]
					SE2->E2_SALDO	:= aImpos[nX,5]
					SE2->E2_VLCRUZ  := aImpos[nX,5]
					SE2->E2_EMISSAO := If(lBaixa,dBaixa,dEmissao)
					SE2->E2_EMIS1	:= dDataBase
					SE2->E2_VENCTO  := dVencImp
					SE2->E2_VENCORI := dVencImp
					SE2->E2_VENCREA := dVencImp
					SE2->E2_MOEDA	:= If(cPaisLoc=="BRA",1,nMoeda)
					SE2->E2_ORIGEM  := cOrigem
					SE2->E2_NATUREZ := cNatImp
					SE2->E2_LA      := cLA			// Herda do principal
					SE2->E2_FILORIG := cFilOrig 	//filial origem do titulo pai
					SE2->E2_TITPAI	:= cTitPai
					SE2->E2_CODAPRO := cCodAprov
					SE2->E2_FORMPAG := SA2->A2_FORMPAG
					SE2->E2_SEQBX 	:= cSeq

					If cPaisLoc == "BRA"
						SE2->E2_DIRF    := cGeraDirf
						SE2->E2_CODRET  := cCodRet
					Endif

					//campos novos para pagamento do cnab tributo via cnab.
					If cTipoRet $ 'IRF|IRRF'
						If Empty(SE2->E2_CNPJRET)
							If cFilOrig == FWCodFil()
								cCNPJRet	:= SM0->M0_CGC
								cNomeCom	:= SM0->M0_NOMECOM
								nTpInsc		:= SM0->M0_TPINSC
							Else
								aEmpDados:= FWArrFilAtu(,SE2->E2_FILIAL)
								cNomeCom := aEmpDados[17]// Nome da Empresa que originou o Título
								cCNPJRet := aEmpDados[18]// CNJP da Filial que originou o Título
								nSM0Recno	:= SM0->(RECNO())
								SM0->(DbSetOrder(1))
								SM0->(DbSeek( aEmpDados[1] + aEmpDados[2] ))
								nTpInsc := SM0->M0_TPINSC
								SM0->(DbGoTo(nSM0Recno))
							EndIf

							SE2->E2_NOMERET	:= cNomeCom
							SE2->E2_CNPJRET	:= cCNPJRet
							SE2->E2_TPINSC	:= IIf( nTpInsc == 3, "1", "2" )
						EndIf

						If ColumnPos("E2_DTAPUR") > 0 .and. SE2->E2_DIRF == "1" .AND. !Empty(cCodRet)
							SE2->E2_DTAPUR	:= LastDay(MonthSub(dVencImp, 1))
						Endif
					ElseIf cTipoRet $ 'INS'
						SE2->E2_RETINS := cRETINS
						SE2->E2_CNPJRET := cCNPJRET
					EndIF

					// Atualiza o campo E2_MULTNAT = '1' para que seja possivel a visualizacao do roteio atraves da rotina FINA050
					If lRatImp .And. MV_MULNATP
						SE2->E2_MULTNAT := "1"
					EndIf

					SE2->(MsUnlock())
					FKCOMMIT()
                    
                    if lPLSTITPF
					    PLSTITPF('SE2', cTitpai)
				    endIf

					AADD(aRecImpos, {"SE2", SE2->(Recno())})
					aImpos[nX,12] := SE2->(Recno())

					// Se rateia os impostos, grava o rateio multipla natureza/centro de custo
					If lRatImp .And. cCart == '1'	//Pagar
						GrvSevSezImp(aRatSev,aRatSez,SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_VALOR) // Grava SEV e SEZ dos impostos
					ElseIf cCart == '1'	//Pagar
						AtuSldNat(SE2->E2_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, "2", "P", SE2->E2_VALOR, SE2->E2_VLCRUZ, "+")
					Endif

					//Complemento de gravação - Usuário
					If lFXIMPPG
						Execblock("FXIMPPG",.F.,.F.,nRecTitPai)
					Endif

					//Gravações complementares por tipo de imposto
					If cTipoRet $ 'IRF|IRRF'
						// Grava lançamento do imposto IRRF no SIGAPCO se a rotina foi chamada do contas a pagar ³
						If cOrigem == "FINA050"
							PCODetLan("000002","06","FINA050")
						EndIf

						If cCart == '1'	//Pagar
							DbSelectArea( 'SE2' )
							DbGoTo( nRecTitPai )
							Reclock( "SE2" , .F. )
							SE2->E2_PARCIR := cParcela

							If aImpos[nX,9] == "1" .And. aImpos[nX,15] == "3"
								SE2->E2_PRETIRF := ""
								SE2->E2_VRETIRF := aImpos[nX,5]
							EndIf

							If cPaisLoc=="BRA"
								SE2->E2_DIRF    := "2"	 // Desmarca titulo principal, pois apenas o titulo de imposto vai para DIRF
							Endif

							MsUnlock()
						EndIf
					ElseIf cTipoRet $ 'ISS'
						If cOrigem == "FINA040"
							PCODetLan("000001","13", cOrigem)
						EndIf
					ElseIf cTipoRet $ 'INS|INSS'
						If cOrigem == "FINA040"
							PCODetLan("000001","07",cOrigem)
						EndIf

						If cPaisLoc=="BRA"
							If cCart == '1'	//Pagar
								DbSelectArea( "SE2" )
								DbGoTo( nRecTitPai )
								Reclock( "SE2" , .F. )
								SE2->E2_PARCINS := cParcela
								SE2->E2_DIRF    := "2"	 // Desmarca titulo principal, pois apenas o titulo de  imposto vai para DIRF
								//Titulo de Pessoa Juridica com retenção apenas de Inss.
								If !Empty(cCodRet) .And. cTipoFor == "J" .And. nTamImpos == 1
									SE2->E2_DIRF	:=	"1"
								Endif

								If aImpos[nX,9] == "1" .And. aImpos[nX,15] == "3"
									SE2->E2_PRETINS := ""
									SE2->E2_VRETINS := aImpos[nX,5]
								EndIf

								MsUnlock()
							EndIF
						Endif
					ElseIf cTipoRet $ 'PIS'
						If cOrigem $ "FINA050|FINA080"
							PCODetLan("000002","10","FINA050")
						ElseIf cOrigem == "FINA240"
							PCODetLan("000023","03","FINA240")
						EndIf

						// Grava parcela do Pis na parcela do titulo
						DbSelectArea( "SE2" )
						DbGoTo( nRecTitPai )
						Reclock( "SE2" , .F. )
						SE2->E2_PARCPIS := cParcela

						If aImpos[nX,9] == "1" .And. aImpos[nX,15] == "3"
							SE2->E2_PRETPIS := ""
							SE2->E2_VRETPIS := aImpos[nX,5]
						EndIf

						If cPaisLoc=="BRA"
							SE2->E2_DIRF    := "2"	 // Desmarca titulo principal, pois apenas o titulo de imposto var para DIRF
						Endif

						MsUnlock()
					ElseIf cTipoRet $ 'COFINS'
						If cOrigem $ "FINA050#FINA080"
							PCODetLan("000002","11","FINA050")
						ElseIf cOrigem == "FINA240"
							PCODetLan("000023","04","FINA240")
						EndIf

						// Grava parcela do COFINS na parcela do titulo
						DbSelectArea( "SE2" )
						DbGoTo( nRecTitPai )
						Reclock( "SE2" , .F. )
						SE2->E2_PARCCOF := cParcela

						If aImpos[nX,9] == "1" .And. aImpos[nX,15] == "3"
							SE2->E2_PRETCOF := ""
							SE2->E2_VRETCOF := aImpos[nX,5]
						EndIf

						If cPaisLoc=="BRA"
							SE2->E2_DIRF    := "2"	 // Desmarca titulo principal, pois apenas o titulo de imposto var para DIRF
						Endif

						MsUnlock()
					ElseIf cTipoRet $ 'CSLL'
						If cOrigem $ "FINA050#FINA080"
							PCODetLan("000002","12","FINA050")
						ElseIf cOrigem == "FINA240"
							PCODetLan("000023","05","FINA240")
						EndIf

						// Grava parcela do Csll na parcela do titulo
						DbSelectArea( "SE2" )
						DbGoTo( nRecTitPai )
						Reclock( "SE2" , .F. )
						SE2->E2_PARCSLL := cParcela

						If aImpos[nX,9] == "1" .And. aImpos[nX,15] == "3"
							SE2->E2_PRETCSL := ""
							SE2->E2_VRETCSL := aImpos[nX,5]
						EndIf

						If cPaisLoc=="BRA"
							SE2->E2_DIRF    := "2"	 // Desmarca titulo principal, pois apenas o titulo de imposto var para DIRF
						Endif

						MsUnlock()
					ElseIf cTipoRet $ 'FETH'
						//Gravar a parcela do Fethab no titulo principal
						If cCart == '1'	//Pagar
							DbSelectArea("SE2")
							DbGoTo( nRecTitPai )
							Reclock( "SE2" , .F. )
							SE2->E2_PARCFET := cParcela
							MsUnlock()
						ElseIf cCart == '2'	//Receber
							DbSelectArea("SE1")
							SE1->(DbGoTo(nRecTitPai))
							RecLock("SE1",.F.)
							SE1->E1_PARCFET	:= cParcela
							MsUnLock()
						Endif
					ElseIf cTipoRet $ 'FAB'
						//Gravar a parcela do Fethab no titulo principal
						If cCart == '1'	//Pagar
							DbSelectArea("SE2")
							DbGoTo( nRecTitPai )
							Reclock( "SE2" , .F. )
							SE2->E2_PARCFAB := cParcela
							MsUnlock()
						Endif
					ElseIf cTipoRet $ 'FACS'
						//Gravar a parcela do Fethab no titulo principal
						If cCart == '1'	//Pagar
							DbSelectArea("SE2")
							DbGoTo( nRecTitPai )
							Reclock( "SE2" , .F. )
							SE2->E2_PARCFAC := cParcela
							MsUnlock()
						ElseIf cCart == '2'	//Receber
							//Gravar a parcela do Facs no titulo principal
							DbSelectArea("SE1")
							SE1->(DbGoTo(nRecTitPai))
							RecLock("SE1",.F.)
							SE1->E1_PARCFAC	:= cParcela
							MsUnLock()
						EndIF
					ElseIf cTipoRet $ 'TPDP'
						If cCart == '2'	//Receber
							//Gravar a parcela da TPDP no titulo principal
							DbSelectArea("SE1")
							SE1->(DbGoTo(nRecTitPai))
							RecLock("SE1",.F.)
							SE1->E1_PARTPDP	:= cParcela
							MsUnLock()
						EndIF
					EndIf
				EndIF
			EndIf
		Endif
	Next

	//Gravação das FKs dos impostos - Emissão / Baixa
	If lBaixa
		FxGrvImpB(cAliasPai, nRecTitPai, aImpos, cTabOri )
	ElseIf lImpEmis
		FxGrvImpE(cAliasPai, nRecTitPai, aImpos, aRecImpos )
	EndIf

	//Complemento de gravação - Usuário
	If lFXIMPGR
		Execblock("FXIMPGR",.F.,.F.,aRecImpos)
	Endif

Endif

If oPrepSE1PC != NIL
	oPrepSE1PC:Destroy()
	oPrepSE1PC := NIL
Endif

If oPrepSE2PC != NIL
	oPrepSE2PC:Destroy()
	oPrepSE2PC := NIL
Endif

RestArea( aAreaSA )
RestArea( aAreaSE )
RestArea( aArea )

Return aRecImpos


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FinPcImp

Calcula a parcela de titulos de impostos, IR, PIS, COFINS e CSLL.

@Author	Mauricio Pequim Jr
@since	26/10/2017
/*/
//-----------------------------------------------------------------------------------------------------
Function FinPcImp(cAliasImp,cPrefixo,cNum,cTipoImp,cCliForImp,cLojaImp, cFilOrig)
Local aArea As Array
Local cParcela As Character
Local cQuery As Character

Default cAliasImp := " "
Default cPrefixo := " "
Default cNum := " "
Default cTipoImp := " "
Default cCliForImp := " "
Default cLojaImp := " "
Default cFilOrig := cFilAnt

If nTamParc == NIL
	nTamParc := TamSx3("E2_PARCELA")[1]
EndIf

If Empty(cAliasImp) .Or. Empty(cNum) .Or. Empty(cTipoImp) .Or. Empty(cCliForImp) .Or. Empty(cLojaImp)
	cParcela := STRZERO(1, nTamParc)
Else
	aArea := GetArea()
	cParcela := STRZERO(1,nTamParc)
	cQuery := ""

	If cAliasImp == "SE1"
		If oPrepSE1PC == NIL
			cQuery := "SELECT MAX(E1_PARCELA) MAXPARC1"
			cQuery += " FROM "+RetSqlName('SE1')+" SE1"
			cQuery += " WHERE SE1.E1_FILIAL= ? AND"
			cQuery += " SE1.E1_PREFIXO= ? AND"
			cQuery += " SE1.E1_NUM= ? AND"
			cQuery += " SE1.E1_TIPO= ? AND"
			cQuery += " SE1.E1_CLIENTE= ? AND"
			cQuery += " SE1.E1_LOJA= ? AND "
			cQuery += " SE1.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)
			oPrepSE1PC:=FWPreparedStatement():New(cQuery)
		Endif

		oPrepSE1PC:SetString(1,xFilial("SE1", cFilOrig))
		oPrepSE1PC:SetString(2,cPrefixo)
		oPrepSE1PC:SetString(3,cNum)
		oPrepSE1PC:SetString(4,cTipoImp)
		oPrepSE1PC:SetString(5,cCliForImp)
		oPrepSE1PC:SetString(6,cLojaImp)
		cQuery:=oPrepSE1PC:GetFixQuery()

		cParcela := Left(MpSysExecScalar(cQuery,"MAXPARC1"), nTamParc) //left incluido para corrigir problema em banco postgres - nao remover
	Else
		If oPrepSE2PC == NIL
			cQuery := "SELECT MAX(E2_PARCELA) MAXPARC2"
			cQuery += " FROM "+RetSqlName('SE2')+" SE2"
			cQuery += " WHERE SE2.E2_FILIAL= ? AND"
			cQuery += " SE2.E2_PREFIXO= ? AND"
			cQuery += " SE2.E2_NUM= ? AND"
			cQuery += " SE2.E2_TIPO= ? AND"
			cQuery += " SE2.E2_FORNECE= ? AND"
			cQuery += " SE2.E2_LOJA= ? AND"
			cQuery += " SE2.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)
			oPrepSE2PC:=FWPreparedStatement():New(cQuery)
		Endif

		oPrepSE2PC:SetString(1,xFilial("SE2",cFilOrig))
		oPrepSE2PC:SetString(2,cPrefixo)
		oPrepSE2PC:SetString(3,cNum)
		oPrepSE2PC:SetString(4,cTipoImp)
		oPrepSE2PC:SetString(5,cCliForImp)
		oPrepSE2PC:SetString(6,cLojaImp)
		cQuery:=oPrepSE2PC:GetFixQuery()

		cParcela := Left(MpSysExecScalar(cQuery,"MAXPARC2"), nTamParc) //left incluido para corrigir problema em banco postgres - nao remover
	Endif

	cParcela := Soma1(cParcela,nTamParc)
	RestArea(aArea)
EndIf

Return cParcela


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FxGrvImpE

Grava FK3/FK4/FK0 titulos de impostos, IR, PIS, COFINS e CSLL gerados na emissão

@Author	Mauricio Pequim Jr
@since	01/11/2017
/*/
//-----------------------------------------------------------------------------------------------------
Function FxGrvImpE(cAliasPai As Character, nRecTitPai As Numeric, aImpos As Array, aRecImpos As Array, lImpMR as Logical )
Local nX As Numeric
Local oModel As Object
Local oSubFK3 As Object
Local oSubFK4 As Object
Local oSubFK0 As Object
Local oSubFKA As Object
Local cIdTPai As Character
Local cChaveTit As Character
Local cCliFor As Character
Local cLoja As Character
Local cOrigem As Character
Local cCgc As Character
Local cRecPag As Character
Local cLog As Character
Local cIdDoc As Character
Local cIdFK4 As Character
Local cIdTImp As Character
Local cFilOrig As Character
Local lRotAuto As Logical
Local cChaveFKK  As Character
Local nMoeda As Numeric
Local nCasDec As Numeric
Local lRet As Logical
Local cIdFKK As Character
Local cTipo As Character
Local nY As Numeric
Local lOK as Logical
Local cCodRet as Character
Local lFKCodRet	as Logical

DEFAULT cAliasPai := ''
DEFAULT nRecTitPai := 0
DEFAULT aImpos := {}
DEFAULT aRecImpos := {}
DEFAULT lImpMR	:= .T.

nX 			:= 0
oModel 		:= NIL
oSubFK3 	:= NIL
oSubFK4 	:= NIL
oSubFK0 	:= NIL
cChaveTit 	:= ''
cIdTPai 	:= ''
cChaveTit 	:= ''
cCliFor 	:= ''
cLoja 		:= ''
cOrigem 	:= ''
cCgc 		:= ''
cRecPag 	:= ''
cFilOrig 	:= ''
cLog 		:= ''
cIdDoc 		:= ''
cIdFK4 		:= ''
cIdTImp 	:= ''
cFilOrig 	:= ''
lRotAuto 	:= .F.
cChaveFKK 	:= ""
nCasDec 	:= (MsDecimais(1) + 1)
lRet 		:= .T.
cIdFKK 		:= ""
cTipo  		:= ""
nY     		:= 0
lOK	   		:= .F.	
cCodRet		:=""
lFKCodRet	:= (cPaisLoc == "BRA" .and. FK3->(FieldPos("FK3_CODRET")) > 0 .and. FK4->(FieldPos("FK4_CODRET")) > 0)

If Len(aImpos) > 0
	oModel :=  FWLoadModel('FINM060')
	oModel:SetOperation(3) // Inclusao
	oModel:Activate()
	oModel:SetValue( "MASTER", "NOVOPROC", .T. )

	oSubFK3  := oModel:GetModel("FK3DETAIL")
	oSubFK4  := oModel:GetModel("FK4DETAIL")
	oSubFK0  := oModel:GetModel("FK0DETAIL")
	oSubFKA  := oModel:GetModel("FKADETAIL")

	//Posiciono no titulo pai e gero FK7 para om mesmo
	DbSelectArea(cAliasPai)
	(cAliasPai)->(DbGoTo(nRecTitPai))

	If cAliasPai == "SE2"
		cChaveTit := xFilial("SE2",SE2->E2_FILORIG)+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA
		cIdTPai   := FINGRVFK7('SE2', cChaveTit)
		cCliFor   := SE2->E2_FORNECE
		cLoja	  := SE2->E2_LOJA
		cOrigem   := SE2->E2_ORIGEM
		cCgc	  := Alltrim( Posicione("SA2",1,xfilial("SA2") + cCliFor + cLoja ,"A2_CGC") )
		cRecPag   := "P"
		cFilOrig  := SE2->E2_FILORIG
		lRotAuto  := (Type("lF050Auto") == "L" .and. lF050Auto)
		nMoeda    := SE2->E2_MOEDA
		nTxMoeda  := SE2->E2_TXMOEDA
		cTipo     := SE2->E2_TIPO
	Else
		cChaveTit := xFilial("SE1", SE1->E1_FILORIG)+"|"+SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA
		cIdTPai   := FINGRVFK7('SE1', cChaveTit)
		cCliFor   := SE1->E1_CLIENTE
		cLoja	  := SE1->E1_LOJA
		cOrigem   := SE1->E1_ORIGEM
		cCgc	  := Alltrim( Posicione("SA1",1,xfilial("SA1") + cCliFor + cLoja ,"A1_CGC") )
		cRecPag   := "R"
		cFilOrig  := SE1->E1_FILORIG
		lRotAuto  := (Type("lF040Auto") == "L" .and. lF040Auto)
		nMoeda    := SE1->E1_MOEDA
		nTxMoeda  := SE1->E1_TXMOEDA
		cTipo     := SE1->E1_TIPO
	EndIf

	// Grava ID do titulo
	If !oSubFKA:IsEmpty()
		oSubFKA:AddLine()
	EndIf

	oSubFKA:SetValue("FKA_IDORIG", cIdTPai   )
	oSubFKA:SetValue("FKA_TABORI", cAliasPai )

	//Grava FK3 E/OU FK4 
	For nX := 1 to Len(aImpos)
		If aImpos[nX][2] > 0
			If aImpos[nX,9] != "1" .And. IIf(cTipo $ MVRECANT+"|"+MVPAGANT, aImpos[nX,19] != "1", .T.)
				Loop
			EndIf

			If lImpMR
				FKK->(DbGoto(aImpos[nX,21]))
				lOK := FKK->(!Eof())
			Else
				lOK := .T.	
			EndIf	

			If lOk
				cIdFK4 := ""
				If !lImpMR
					cCgc := Iif(Len(aImpos[nX]) > 22,aImpos[nX][23],cCgc)
					cCodRet := Iif(Len(aImpos[nX]) > 23,aImpos[nX][24],"")
				Else
					cCodRet := FKK->FKK_CODRET
				EndIf	
				If aImpos[nX][5] > 0//Houve retencao
					cIdFK4       := FINFKSID('FK4','FK4_IDFK4')
					aImpos[nX,6] := cIdFK4
				Endif

				If !oSubFK3:IsEmpty()
					oSubFK3:AddLine()
					oSubFK3:GoLine( oSubFK3:Length() )
				Endif

				//Grava Imposto calculado
				cIdFK3:= FINFKSID('FK3', 'FK3_IDFK3')
				oSubFK3:LoadValue("FK3_IDFK3" , cIdFK3 )
				oSubFK3:LoadValue("FK3_DATA"  , dDataBase )
				oSubFK3:LoadValue("FK3_ORIGEM", cOrigem )
				oSubFK3:LoadValue("FK3_IMPOS" , aImpos[nx,8] )
				oSubFK3:LoadValue("FK3_RECPAG", cRecPag)
				oSubFK3:LoadValue("FK3_MOEDA" , "01" )
				oSubFK3:LoadValue("FK3_VALOR" , aImpos[nX][3] )
				oSubFK3:LoadValue("FK3_NATURE", aImpos[nX][10] )
				oSubFK3:LoadValue("FK3_FILORI", cFilOrig )
				oSubFK3:LoadValue("FK3_BASIMP", aImpos[nX][2] )
				oSubFK3:LoadValue("FK3_IDORIG", cIdTPai )
				oSubFK3:LoadValue("FK3_TABORI", cAliasPai)
				oSubFK3:LoadValue("FK3_IDRET" , aImpos[nx,6] )
				oSubFK3:LoadValue("FK3_CLIFOR", cCliFor )
				oSubFK3:LoadValue("FK3_LOJA"  , cLoja )
				oSubFK3:LoadValue("FK3_CGC"   , cCgc )
				oSubFK3:LoadValue("FK3_RAICGC", Substr(cCgc,1,8) )
				oSubFK3:LoadValue("FK3_CODFKM", aImpos[nX,1] )
				If lFKCodRet
					oSubFK3:LoadValue("FK3_CODRET", cCodRet )
				EndIf

				If nMoeda > 1
					oSubFK3:LoadValue("FK3_VLMOE2", Round(xMoeda(aImpos[nX][3], 1, nMoeda, dDataBase, nCasDec, nTxMoeda), 2))
				Else
					oSubFK3:LoadValue("FK3_VLMOE2", aImpos[nX][3])
				EndIf

				//Grava Imposto Retido
				If aImpos[nX][5] > 0 //Houve retencao
					If !oSubFK4:IsEmpty()
						oSubFK4:AddLine()
						oSubFK4:GoLine( oSubFK4:Length() )
					Endif

					oSubFK4:LoadValue("FK4_IDFK4" , aImpos[nx,6])
					oSubFK4:LoadValue("FK4_DATA"  , dDataBase )
					oSubFK4:LoadValue("FK4_ORIGEM", cOrigem )
					oSubFK4:LoadValue("FK4_IMPOS" , aImpos[nx,8] )
					oSubFK4:LoadValue("FK4_RECPAG", cRecPag )
					oSubFK4:LoadValue("FK4_MOEDA" , "01" )
					oSubFK4:LoadValue("FK4_BASIMP", aImpos[nX,4] )
					oSubFK4:LoadValue("FK4_VALOR" , aImpos[nX,5] )
					oSubFK4:LoadValue("FK4_NATURE", aImpos[nX,10])
					oSubFK4:LoadValue("FK4_FILORI", cFilOrig )
					oSubFK4:LoadValue("FK4_CLIFOR", cCliFor )
					oSubFK4:LoadValue("FK4_LOJA"  , cLoja )
					oSubFK4:LoadValue("FK4_CGC"   , cCgc )
					oSubFK4:LoadValue("FK4_RAICGC", Substr(cCgc,1,8) )
					oSubFK4:LoadValue("FK4_CODFKM", aImpos[nX,1] )
					If lFKCodRet
						oSubFK4:LoadValue("FK4_CODRET", cCodRet )
					EndIf

					If nMoeda > 1
						oSubFK4:LoadValue("FK4_VLMOE2", Round(xMoeda(aImpos[nX,5], 1, nMoeda, dDataBase, nCasDec, nTxMoeda), 2))
					Else
						oSubFK4:LoadValue("FK4_VLMOE2", aImpos[nX,5])
					EndIf

					If !Empty(aImpos[nX,11]) .and. !Empty(aImpos[nX,12])
						cAliasImp := aImpos[nX,11]
						nRecImp   := aImpos[nX,12]
						(cAliasImp)->(DbGoTo(nRecImp))

						If cAliasImp == 'SE1'
							cChaveTit := xFilial("SE1", SE1->E1_FILORIG)+"|"+SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA
							cIdTImp   := FINGRVFK7('SE1', cChaveTit)
							cFilOrig  := SE1->E1_FILORIG
						ElseIf cAliasImp == 'SE2'
							cChaveTit := xFilial("SE2",SE2->E2_FILORIG)+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA
							cIdTImp   := FINGRVFK7('SE2', cChaveTit)
							cFilOrig  := SE2->E2_FILORIG
						EndIf

						If !oSubFK0:IsEmpty()
							oSubFK0:AddLine()
							oSubFK0:GoLine( oSubFK0:Length() )
						Endif

						oSubFK0:LoadValue("FK0_IDFK4" , aImpos[nx,6] )
						oSubFK0:LoadValue("FK0_CODFKM", aImpos[nX,1] )
						oSubFK0:LoadValue("FK0_IDDOC" , cIdTImp )
						oSubFK0:LoadValue("FK0_TABORI", cAliasPai )
						oSubFK0:LoadValue("FK0_IDPAI" , cIdTPai )
						oSubFK0:LoadValue("FK0_FILORI", cFilOrig )

						//Atualiza a FK3 pendente de retenção.
						For nY := 1 To Len(aImpos[nX,7])
							FK3->(DbGoto(aImpos[nX,7,nY]))
							RECLOCK("FK3")
							FK3->FK3_IDRET := aImpos[nX,6]
							FK3->(MsUnlock())
						Next nY
					Endif
				Endif
			Endif
		EndIf
	Next

	If oModel:VldData()
		oModel:CommitData()
	Else
		cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
		cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
		cLog += cValToChar(oModel:GetErrorMessage()[6])
		If !lRotAuto
			Help( ,,"M060VALID",,cLog, 1, 0 )
		Endif
		lRet := .F.
		DisarmTransaction()
	Endif

	oModel:DeActivate()
	oModel:DesTroy()
	oModel:= NIL

	If !lRet
		Break
	Endif
Endif

Return

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FxGrvImpB
Grava FK0 titulos de impostos, IR, PIS, COFINS e CSLL gerados na baixa

@Author	Mauricio Pequim Jr
@since	01/11/2017
/*/
//-----------------------------------------------------------------------------------------------------
Function FxGrvImpB(cAliasPai As Character, nRecTitPai As Numeric, aImpos As Array, cTabOri As Character )
Local cIdTImp As Character
Local cIdTPai As Character
Local nX As Numeric
Local cFilOrig As Character
Local cIdOrig As Character
Local cTitImp As Character
Local cTabPai As Character
Local cChave As Character
Local aArea As Array
Local cTitPai As Character
Local lSE2    As Logical
Local nFilOrig As Numeric
Local cFil As Character

DEFAULT cAliasPai := ''	//SE1 ou SE2
DEFAULT nRecTitPai := 0
DEFAULT aImpos  := {}	//Impostos calculados pelo motor
DEFAULT cTabOri := ''	//FK1 ou FK2 - Tabela Origem da Baixa

cIdTImp := ''
cIdTPai := ''
nX := 0
cFilOrig := ''
cIdOrig := ''
cTitImp := ""
cTabPai := ""
cChave := ""
cTitPai := ""
lSE2    := .T.
nFilOrig := 0
cFil     := ""

If !Empty(cAliasPai) .and. !Empty(cTabOri) .and. nRecTitPai > 0 .and. Len(aImpos) > 0
	(cAliasPai)->(DbGoTo(nRecTitPai))
	aArea := (cAliasPai)->(GetArea())

	If cAliasPai == 'SE1'
		cFilOrig  := SE1->E1_FILORIG
		cChaveTit := xFilial("SE1", SE1->E1_FILORIG)+"|"+SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA
		cIdTPai   := FINGRVFK7('SE1', cChaveTit)
		lSE2      := .F.
		cFil      := xFilial("SE1",cFilOrig)
		(cAliasPai)->(DbSetOrder(28))
	ElseIf cAliasPai == 'SE2'
		cFilOrig  := SE2->E2_FILORIG
		cChaveTit := xFilial("SE2",SE2->E2_FILORIG)+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA
		cIdTPai   := FINGRVFK7('SE2', cChaveTit)
		cFil      := xFilial("SE2",cFilOrig)
		(cAliasPai)->(DbSetOrder(17))
	EndIf

	nFilOrig  := (Len(cFilOrig) + 1)
	cTitPai   := cChaveTit
	//Grava FK3 E/OU FK4
	For nX := 1 to Len(aImpos)
		If aImpos[nX][9] != "2"
			Loop
		EndIf

		If aImpos[nX][5] > 0//Houve retencao
			cAliasImp := aImpos[nX,11]
			nRecImp   := aImpos[nX,12]

			FK4->(DbSetOrder(1))

			If !FK4->(MsSeek(xFilial("FK4", cFilOrig) + aImpos[nX,6]))
				Loop
			EndIf

			cIdOrig := FK4->FK4_IDORIG
			(cAliasImp)->(DbGoTo(nRecImp))

			If cAliasImp == 'SE1'
				cFilOrig  := SE1->E1_FILORIG
				cChaveTit := xFilial("SE1", cFilOrig)+"|"+SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA
				cIdTImp   := FINGRVFK7('SE1', cChaveTit)
			ElseIf cAliasImp == 'SE2'
				cFilOrig := SE2->E2_FILORIG
				cChaveTit := xFilial("SE2", cFilOrig)+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA
				cIdTImp := FINGRVFK7('SE2', cChaveTit)
			EndIf

			RecLock("FK0",.T.)
			FK0->FK0_FILIAL := xFilial("FK0",cFilOrig)
			FK0->FK0_IDFK4	:= aImpos[nX,6]
			FK0->FK0_CODFKM	:= aImpos[nX,1]
			FK0->FK0_IDDOC	:= cIdTImp
			FK0->FK0_TABORI	:= cTabOri
			FK0->FK0_IDPAI	:= cIdTPai
			FK0->FK0_FILORI := cFilOrig
			FK0->FK0_IDORIG := cIdOrig
			MsUnlock()

			//Excluir provisórios(SE1/SE2)
			If aImpos[nX,9] == "2"
				If nFilOrig > 0
					cTitPai  := SubStr(AllTrim(StrTran(cTitPai, "|", "")), nFilOrig)

					If lSE2
						cTitPai := PadR(cTitPai, Len((cAliasImp)->E2_TITPAI), "")
					Else
						cTitPai := PadR(cTitPai, Len((cAliasImp)->E1_TITPAI), "")
					EndIf

					nFilOrig := 0
				EndIf

				If (cAliasImp)->(MsSeek(cFil+cTitPai))
					While (cAliasImp)->(!Eof()) .And. Iif(lSE2, (cAliasImp)->E2_TITPAI, (cAliasImp)->E1_TITPAI) == cTitPai
						If lSE2
							If (cAliasImp)->E2_TIPO $ MVPROVIS .And. AllTrim(aImpos[nX][10]) == AllTrim((cAliasImp)->E2_NATUREZ)
								RecLock("SE2")
								(cAliasImp)->(dbDelete())
								(cAliasImp)->(MsUnlock())
							EndIf
						Else
							If (cAliasImp)->E1_TIPO $ MVPROVIS .And. AllTrim(aImpos[nX][10]) == AllTrim((cAliasImp)->E1_NATUREZ)
								RecLock("SE1")
								(cAliasImp)->(dbDelete())
								(cAliasImp)->(MsUnlock())
							EndIf
						EndIf
						(cAliasImp)->(DbSkip())
					EndDo
				EndIf
			EndIf
		Endif
	Next
Endif

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}FinDelEst

Deleção e estorno dos impostos calculados e retidos na alteracao
do titulo. (FK3/FK4)

@aparam	cAliasPai - Alias da tabela
@aparam	nRecTitPai - Recno no registro pai

@Return	nil
@author Sivaldo Oliveira
@since  11/12/2017
@version 12
/*/
//-------------------------------------------------------------------
Function FinDelEst(cAliasPai As Character, nRecTitPai As Numeric, lFatComp As Logical)
Local lRet As Logical
Local oModel As Object
Local oFKA As Object
Local oFK3 As Object
Local oFK4 As Object
Local oFK0 As Object
Local aArea As Array
Local AreaAtu As Array
Local cChaveTit As Character
Local cIdTitPai As Character
Local nLinha As Numeric
Local aFK3 As Array
Local aFK4 As Array
Local aAux As Array
Local aCampos As Array
Local nCampos As Numeric
Local nY As Numeric
Local nZ As Numeric
Local cTitImp As Character
Local aFK0 As Array
Local cFilFK7 As Character
Local cFKA As Character
Local cQry As Character
Local cFilOrig As Character
Local cTblTmp As Character

Default cAliasPai := ""
Default nRecTitPai := 0
Default lFatComp   := .F.

//Inicializa variáveis
cAliasPai := AllTrim(cAliasPai)
lRet := (cAliasPai $ "SE1|SE2" .And. !Empty(nRecTitPai))
aArea := {}
AreaAtu := {}
cChaveTit := ""
cIdTitPai := ""
nLinha := 0
aFK3 := {}
aFK4 := {}
aAux := {}
aCampos := {}
nCampos := 0
nY := 0
nZ := 0
cTitImp := ""
aFK0 := {}
cFilFK7 := ""
cFKA := ""
cQry := ""
cTblTmp := ""

If lRet
	AreaAtu := GetArea()
	aArea := (cAliasPai)->(GetArea())
	DbSelectArea(cAliasPai)
	(cAliasPai)->(DbGoto(nRecTitPai))

	If cAliasPai == "SE1"
		cChaveTit := xFilial("SE1",SE1->E1_FILORIG) +"|"+ SE1->E1_PREFIXO +"|"+ SE1->E1_NUM +"|"+ SE1->E1_PARCELA +"|"+ SE1->E1_TIPO +"|"+ SE1->E1_CLIENTE +"|"+ SE1->E1_LOJA
		cFilOrig := SE1->E1_FILORIG
	Else
		cChaveTit := xFilial("SE2",SE2->E2_FILORIG) +"|"+ SE2->E2_PREFIXO +"|"+ SE2->E2_NUM +"|"+ SE2->E2_PARCELA +"|"+ SE2->E2_TIPO +"|"+ SE2->E2_FORNECE +"|"+ SE2->E2_LOJA
		cFilOrig := SE2->E2_FILORIG
	EndIf

	cIdTitPai := FINGRVFK7(cAliasPai, cChaveTit)
	FKA->(DbSetOrder(3))

	If FKA->(MsSeek(xFilial("FKA") + cAliasPai + cIdTitPai))
		cFKA := (xFilial("FKA") + cAliasPai + cIdTitPai)
		oModel := FwLoadModel("FINM060")
		oModel:SetOperation(4)
		oModel:Activate()

		//Carrega o sub modelo FK3
		oFK3 := oModel:GetModel("FK3DETAIL")

		If !oFK3:IsEmpty()
			nLinha:= oFK3:Length()

			//Carrega os sub modelos
			oFKA := oModel:GetModel("FKADETAIL")
			oFK4 := oModel:GetModel("FK4DETAIL")

			//Exclui FK3
			For nY := 1 To nLinha
				oFK3:GoLine(nY)
				oFK3:DeleteLine()
			Next nY

			If !oFK4:IsEmpty()
				oFK0 := oModel:GetModel("FK0DETAIL")
				nLinha := oFK4:Length()

				//Exclui FK4
				For nY := 1 To nLinha
					oFK4:GoLine(nY)
					oFK4:DeleteLine()
				Next nY

				//Excluir FK0
				nLinha := oFK0:Length()
				For nY := 1 To nLinha
					oFK0:GoLine(nY)
					Aadd(aFK0, oFK0:GetValue("FK0_IDDOC"))
					oFK0:DeleteLine()
				Next nY

				//Exluir os impostos retidos SE1 e SE2
				nLinha := Len(aFK0)

				If nLinha > 0
					(cAliasPai)->(DbSetOrder(1))
					FK7->(dbSetOrder(1))
					cFilFK7 := xFilial("FK7")

					For nY := 1 To nLinha
						If FK7->(MsSeek(cFilFK7 + aFK0[nY]))
							If AllTrim(FK7->FK7_ALIAS) == cAliasPai
								cTitImp := RTrim(StrTran(FK7->FK7_CHAVE, "|", ""))

								If (cAliasPai)->(MsSeek(cTitImp))
									RecLock(cAliasPai)
									(cAliasPai)->(dbDelete())
									(cAliasPai)->(MsUnlock())
								EndIf
							EndIf

							//Excluir FK7
							RecLock("FK7")
							FK7->(dbDelete())
							FK7->(MsUnlock())
						EndIf
					Next nY
				EndIf
			EndIf
		EndIf

		If oModel:VldData()
			oModel:CommitData()
		Else
			cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[6])

			If cAliasPai == "SE1"
				lRotAuto := If(Type("lF040Auto") == "L", lF040Auto, .F.)
			Else
				lRotAuto := If(Type("lF050Auto") == "L", lF050Auto, .F.)
			EndIf

			If !lRotAuto
				Help(,,"M060VALID",,cLog, 1, 0 )
			Endif

			DisarmTransaction()
			lRet := .F.
		Endif

		oModel:DeActivate()
		oModel:Destroy()
		oModel := Nil
		oFKA := Nil
		oFK3 := Nil
		oFK4 := Nil
		oFK0 := Nil

		//Excluir FK7
		If lRet .And. FKA->(MsSeek(cFKA))
			RecLock("FKA")
			FKA->(dbDelete())
			FKA->(MsUnlock())
		EndIf
	EndIf

	//Exclui a tabela FKQ para os documentos de entrada e saídas
	If lRet .And. lFatComp .And. !Empty(cIdTitPai)
		FDelFKQ(cIdTitPai)
	EndIf

	RestArea(aArea)
	RestArea(AreaAtu)
EndIf

Return Nil

//---------------------------------------
/*/{Protheus.doc} FinBaseMR
Retorna a base de retenção/cálculo

@aparam
@Return nImpostos Valor das retencoes da baixa
@Author Sivaldo Oliveira
@since	03/01/2018
@version 12
/*/
//---------------------------------------
Function FinBaseMR(nVlrBase As Numeric, lIncAlt As Logical, cFil As Character, cPref As Character, cNum As Character, cParc As Character,;
											cTipo As Character, cForn As Character, cLoja As Character,_lPccMR As Logical, _lIrfMR  As Logical,;
											_lInsMR  As Logical,_lIssMR  As Logical, _lCidMR  As Logical, _lSesMR As Logical, nMoeda As Numeric,;
											nTxMoeda As Numeric, dData As Date, cField As Character, aImpos As Array, lCotepe As Logical) As Array
	Local lRet       As Logical
	Local cQry       As Character
	Local cTblTmp    As Character
	Local lPccBx     As Logical
	Local lIssBx     As Logical
	Local aArea      As Array
	Local aValImp    As Array
	Local lMVBP10925 As Logical
	Local nCasDec    As Numeric
	Local lAdianto   As Logical
	Local nValor     As Numeric
	Local nZ         As Numeric
	Local lSE2       As Logical
	Local cFKN       As Character
	Local cFKL       As Character
	Local nVlrImp    As Numeric
	Local lJaIss	 As Logical
	
	//Parâmetros da função
	Default nVlrBase := 0
	Default lIncAlt  := .F.
	Default cFil     := ""
	Default cPref    := ""
	Default cNum     := ""
	Default cParc    := ""
	Default cTipo    := ""
	Default cForn    := ""
	Default cLoja    := ""
	Default _lPccMR  := .F.
	Default _lIrfMR  := .F.
	Default _lInsMR  := .F.
	Default _lIssMR  := .F.
	Default _lCidMR  := .F.
	Default _lSesMR  := .F.
	Default nMoeda   := 1
	Default nTxMoeda := 0
	Default dData    := dDataBase
	Default cField   := ""
	Default aImpos   := {}
	Default lCotepe  := .F.

	//Inicializa as variáveis
	lRet     := .T.
	cQry     := ""
	cTblTmp  := ""
	lPccBx   := .F.
	lIssBx   := .F.
	aArea    := GetArea()
	nCasDec  := TamSx3("E2_TXMOEDA")[2]
	nValor   := 0
	nZ       := 0
	lSE2     := .F.
	aValImp  := {nVlrBase, 0, 0, 0}
	lAdianto := (cTipo $ MVPAGANT .and. "E2_NATUREZ" $ cField )
	cFKN := ""
	cFKL := ""
	nVlrImp := 0
	lJaIss	:= .F.
	
	//query para os impostos retidos na baixa e na emissão
	cQry := FinQryBas(cFil, cPref, cNum, cParc, cTipo, cForn, cLoja)
	
	If Empty(cQry)
		lRet := .F.
	EndIf
	
	If lRet
		lMVBP10925 := SuperGetMv("MV_BP10925",.T.,"1") == "1"
		cTblTmp    := MpSysOpenQuery(cQry)
		nMoeda     := If(ValType(nMoeda) == "C", Val(nMoeda), nMoeda)
		/*-------------------------------------------
		Estrutura da aBasMR
		[1] = base de retenção
		[2] = Imp retidos na emissão motor de retenção
		[3] = Imp retidos Bx.MR e antigo que recompoem base 
		-------------------------------------------*/
		While (cTblTmp)->(!Eof())
			If !Empty((cTblTmp)->FK4_CODFKM)
				nRecFKK := FinFKKVig((cTblTmp)->FK4_CODFKM, dData)				
				FKK->(DbGoto(nRecFKK))
				cFKN := (xFilial("FKN",(cTblTmp)->FK4_FILORI)+FKK->FKK_IDFKN)
				cFKL := xFilial("FKL",(cTblTmp)->FK4_FILORI)+FKK->FKK_IDFKL
				
				If FKK->FKK_VLNOTA == "1" .And. FKL->FKL_CARTMV == "1" .And. FKL->(MsSeek(cFKL))
					If FKK->FKK_FATGER == "1" //Retenção emissão motor de impostos
						If nMoeda > 1
							If FKN->(MsSeek(cFKN))
								If FKN->FKN_VLRDEC == "1"
									nVlrImp := Round(xMoeda((cTblTmp)->FK4_VALOR, 1, nMoeda, dData, nCasDec, 0, nTxMoeda), 2)
								Else
									nVlrImp := NoRound(xMoeda((cTblTmp)->FK4_VALOR, 1, nMoeda, dData, nCasDec, 0, nTxMoeda), 2)
								EndIf
							Else
								nVlrImp := Round(xMoeda((cTblTmp)->FK4_VALOR, 1, nMoeda, dData, nCasDec, 0, nTxMoeda), 2)
							EndIf
						Else
							nVlrImp := (cTblTmp)->FK4_VALOR
						EndIf
						
						aValImp[1] += nVlrImp
						aValImp[2] += nVlrImp
					Else //Retenção na baixa motor de impostos
						If !lIncAlt .And. lMVBP10925 .And. (cTblTmp)->FK3_TABORI == "FK2"
							If nMoeda > 1
								If FKN->FKN_VLRDEC == "1"
									nVlrImp := Round(xMoeda((cTblTmp)->FK4_VALOR, 1, nMoeda, dData, nCasDec, 0, nTxMoeda), 2)
								Else
									nVlrImp := NoRound(xMoeda((cTblTmp)->FK4_VALOR, 1, nMoeda, dData, nCasDec, 0, nTxMoeda), 2)
								EndIf
							Else
								nVlrImp := (cTblTmp)->FK4_VALOR
							EndIf
							
							aValImp[1] += nVlrImp
							aValImp[3] += nVlrImp
						EndIf
					EndIf
				EndIf
			ElseIf !lIncAlt
				//Retenção na baixa legado
				If (cTblTmp)->FK3_TABORI == "FK2"
					If lMVBP10925 .OR. lCotepe
						If nMoeda > 1
							nVlrImp := Round(xMoeda((cTblTmp)->FK4_VALOR, 1, nMoeda, dData, nCasDec, 0, nTxMoeda), 2)
						Else
							nVlrImp := (cTblTmp)->FK4_VALOR
						EndIf
						
						aValImp[1] += nVlrImp
						aValImp[3] += nVlrImp
						If Alltrim((cTblTmp)->FK4_IMPOS) == "ISS"
							lJaIss	:= .T.
						EndIf						
					EndIf
				EndIf
			EndIf
			
			(cTblTmp)->(DbSkip())
		EndDo
		
		//Validação dos Impostos antigos
		lPccBx := SuperGetMv("MV_BX10925",.T.,"2") == "1"
		SA2->(DBSETORDER(1))	// A2_FILIAL+A2_COD+A2_LOJA
		SA2->(MSSEEK(XFILIAL('SA2')+cForn+cLoja))
		lIrfBx := cPaisLoc == "BRA" .And. SA2->A2_CALCIRF == "2"
		lIssBx := Iif(FindFunction("IsIssBx"), IsIssBx("P"), SuperGetMv("MV_MRETISS",.F.,"1") == "2" ) .And. !SE2->E2_TIPO $ MVPAGANT
		
		If lIncAlt
			If nMoeda > 1
				//Recomponho a base com os impostos do Motor
				For nZ := 1 to Len(aImpos)
					If (aImpos[nZ,9] != "1") .Or. (aImpos[nZ,15] != "3") .Or. (aImpos[nZ,13] != "1") .Or. (aImpos[nZ,14] != "1")
						Loop
					EndIf
					
					Do Case
						Case aImpos[nZ,8] $ "PIS"
							aValImp[1] += Round(xMoeda(aImpos[nZ,5], 1, nMoeda, dData, (nCasDec + 1), nTxMoeda), 2)
							_lPccMR := .T.
						Case aImpos[nZ,8] $ "COF"
							aValImp[1] += Round(xMoeda(aImpos[nZ,5], 1, nMoeda, dData, (nCasDec + 1), nTxMoeda), 2)
							_lPccMR := .T.
						Case aImpos[nZ,8] $ "CSL"
							aValImp[1] += Round(xMoeda(aImpos[nZ,5], 1, nMoeda, dData, (nCasDec + 1), nTxMoeda), 2)
							_lPccMR := .T.
						Case aImpos[nZ,8] == "IRF"
							aValImp[1] += Round(xMoeda(aImpos[nZ,5], 1, nMoeda, dData, (nCasDec + 1), nTxMoeda), 2)
							_lIrfMR := .T.
						Case aImpos[nZ,8] == "INSS"
							aValImp[1] += Round(xMoeda(aImpos[nZ,5], 1, nMoeda, dData, (nCasDec + 1), nTxMoeda), 2)
							_lInsMR := .T.
						Case aImpos[nZ,8] == "ISS"
							aValImp[1] += Round(xMoeda(aImpos[nZ,5], 1, nMoeda, dData, (nCasDec + 1), nTxMoeda), 2)
							_lIssMR := .T.
						Case aImpos[nZ,8] == "CIDE"
							aValImp[1] += Round(xMoeda(aImpos[nZ,5], 1, nMoeda, dData, (nCasDec + 1), nTxMoeda), 2)
							_lCidMR := .T.
						Case aImpos[nZ,8] == "SEST"
							aValImp[1] += Round(xMoeda(aImpos[nZ,5], 1, nMoeda, dData, (nCasDec + 1), nTxMoeda), 2)
							_lSestMR := .T.
						OtherWise
							aValImp[1] += Round(xMoeda(aImpos[nZ,5], 1, nMoeda, dData, (nCasDec + 1), nTxMoeda), 2)
					EndCase
				Next Nz
				
				//Recomponho a base com os impostos Legados
				//PCC
				If !_lPccMR .And. (!lPccBx .or. lAdianto)
					nValor     := IF(INCLUI, M->E2_PIS, SE2->E2_PIS)
					aValImp[1] += Round(xMoeda(nValor, 1, nMoeda, dData, (nCasDec + 1), nTxMoeda), 2)

					nValor     := IF(INCLUI, M->E2_COFINS, SE2->E2_COFINS)
					aValImp[1] += Round(xMoeda(nValor, 1, nMoeda, dData, (nCasDec + 1), nTxMoeda), 2)
					nValor     := IF(INCLUI, M->E2_CSLL, SE2->E2_CSLL)
					aValImp[1] += Round(xMoeda(nValor, 1, nMoeda, dData, (nCasDec + 1), nTxMoeda), 2)
				EndIf
				//IRF
				If !_lIrfMR .And. (!lIrfBx .or. lAdianto)
					nValor     := IF(INCLUI, M->E2_IRRF, SE2->E2_IRRF)
					aValImp[1] += Round(xMoeda(nValor, 1, nMoeda, dData, (nCasDec + 1), nTxMoeda), 2)
				EndIf
				//ISS
				If !_lIssMR .And. (!lIssBx .or. lAdianto)
					nValor     := IF(INCLUI, M->E2_ISS, SE2->E2_ISS)
					aValImp[1] += Round(xMoeda(nValor, 1, nMoeda, dData, (nCasDec + 1), nTxMoeda), 2)
				EndIf
				//INSS
				If !_lInsMR
					nValor     := IF(INCLUI, M->E2_INSS, SE2->E2_INSS)
					aValImp[1] += Round(xMoeda(nValor, 1, nMoeda, dData, (nCasDec + 1), nTxMoeda), 2)
				EndIf
				//sest
				If !_lSesMR
					nValor     := IF(INCLUI, M->E2_SEST, SE2->E2_SEST)
					aValImp[1] += Round(xMoeda(nValor, 1, nMoeda, dData, (nCasDec + 1), nTxMoeda), 2)
				EndIf
			Else
				//Recomponho a base com os impostos do motor
				For nZ := 1 to Len(aImpos)
					If lAdianto
						lRet := (aImpos[nZ,9] != "2") .Or. (aImpos[nZ,19] == "3") .Or. (aImpos[nZ,13] != "1") .Or. (aImpos[nZ,14] != "1")
					Else
						lRet := (aImpos[nZ,9] != "1") .Or. (aImpos[nZ,15] != "3") .Or. (aImpos[nZ,13] != "1") .Or. (aImpos[nZ,14] != "1")
					EndIf
					
					If lRet
						Loop
					Endif
					
					Do Case
						Case aImpos[nZ,8] $ "PIS|COF|CSL"
							aValImp[1] += aImpos[nZ,5]
							_lPccMR := .T.
						Case aImpos[nZ,8] == "IRF"
							aValImp[1] += aImpos[nZ,5]
							_lIrfMR := .T.
						Case aImpos[nZ,8] == "INSS"
							aValImp[1] += aImpos[nZ,5]
							_lInsMR := .T.
						Case aImpos[nZ,8] == "ISS"
							aValImp[1] += aImpos[nZ,5]
							_lIssMR := .T.
						Case aImpos[nZ,8] == "CIDE"
							aValImp[1] += aImpos[nZ,5]
							_lCidMR := .T.
						Case aImpos[nZ,8] == "SEST"
							aValImp[1] += aImpos[nZ,5]
							_lSestMR := .T.
						OtherWise
							aValImp[1] += aImpos[nZ,5]
					EndCase
				Next Nz
				
				//Recomponho a base com os impostos Legados
				//PCC
				If !_lPccMR .And. (!lPccBx .or. lAdianto)
					aValImp[1] += M->(E2_PIS+E2_COFINS+E2_CSLL)
				EndIf
				//IRF
				If !_lIrfMR .And. (!lIrfBx .or. lAdianto)
					aValImp[1] += M->E2_IRRF
				EndIf
				//ISS
				If !_lIssMR .And. (!lIssBx .or. lAdianto)
					aValImp[1] += M->E2_ISS
					//Bitriburação de ISS
					aValImp[1] += M->E2_BTRISS
				EndIf
				//INSS
				If !_lInsMR
					aValImp[1] += M->E2_INSS
				EndIf
				//sest
				If !_lSesMR
					aValImp[1] += M->E2_SEST
				EndIf
			EndIf
		Else
			(cTblTmp)->(DbGotop())
			
			If (cTblTmp)->(Eof())
				(cTblTmp)->(dbCloseArea())
				cTblTmp := "SE2"
				lSE2 := .T.
			EndIf
			
			If nMoeda > 1
				//pcc
				If !_lPccMR .And. !lPccBx .And. (cTblTmp)->(E2_PIS+E2_COFINS+E2_CSLL) > 0
					aValImp[1] += Round(xMoeda((cTblTmp)->E2_PIS,    1, nMoeda, dData, nCasDec, 0, nTxMoeda), 2)
					aValImp[1] += Round(xMoeda((cTblTmp)->E2_COFINS, 1, nMoeda, dData, nCasDec, 0, nTxMoeda), 2)
					aValImp[1] += Round(xMoeda((cTblTmp)->E2_CSLL,   1, nMoeda, dData, nCasDec, 0, nTxMoeda), 2)
				EndIf
				
				//irf
				If !_lIrfMR .And. !lIrfBx .And. (cTblTmp)->E2_IRRF > 0
					aValImp[1] += Round(xMoeda((cTblTmp)->E2_IRRF, 1, nMoeda, dData, nCasDec, 0, nTxMoeda), 2)
				EndIf
				
				//Iss
				If !_lIssMR .And. !lIssBx .And. (cTblTmp)->E2_ISS > 0
					aValImp[1] += Round(xMoeda((cTblTmp)->E2_ISS, 1, nMoeda, dData, nCasDec, 0, nTxMoeda), 2)
				EndIf
				
				//inss
				If !_lInsMR .And. (cTblTmp)->E2_INSS > 0
					aValImp[1] += Round(xMoeda((cTblTmp)->E2_INSS, 1, nMoeda, dData, nCasDec, 0, nTxMoeda), 2)
				EndIf
				
				//sest
				If !_lSesMR .And. (cTblTmp)->E2_SEST > 0
					aValImp[1] += Round(xMoeda((cTblTmp)->E2_SEST, 1, nMoeda, dData, nCasDec, 0, nTxMoeda), 2)
				EndIf
			Else
				//pcc
				If !_lPccMR .And. !lPccBx .And. (cTblTmp)->(E2_PIS+E2_COFINS+E2_CSLL) > 0
					aValImp[1] += (cTblTmp)->(E2_PIS+E2_COFINS+E2_CSLL)
				EndIf
				
				//irf
				If !_lIrfMR .And. !lIrfBx .And. (cTblTmp)->E2_IRRF > 0
					aValImp[1] += (cTblTmp)->E2_IRRF
				EndIf
				
				//Iss
				If !_lIssMR .And. (  !lJaIss .And. (!lIssBx .Or. (lCotepe .And. cTblTmp == "SE2" ))).And. (cTblTmp)->E2_ISS > 0
					aValImp[1] += (cTblTmp)->E2_ISS
				EndIf
				
				//inss
				If !_lInsMR .And. (cTblTmp)->E2_INSS > 0
					aValImp[1] += (cTblTmp)->E2_INSS
				EndIf
				
				//sest
				If !_lSesMR .And. (cTblTmp)->E2_SEST > 0
					aValImp[1] += (cTblTmp)->E2_SEST
				EndIf
			EndIf
		EndIf
		
		//Fecha a tabela temporária
		If !lSE2
			(cTblTmp)->(dbCloseArea())
		Endif
	EndIf
	
	lJaIss	:= .F.
	RestArea(aArea)
Return aValImp

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FinQryBas
Retorna a QUERY para calculo da base de retenção/cálculo

@aparam
@Return nImpostos Valor das retencoes da baixa
@Author Sivaldo Oliveira
@since	03/01/2018
@version 12
/*/
//-----------------------------------------------------------------------------------------------------
Static Function FinQryBas(cFil As Character, cPref As Character, cNum As Character, cParc As Character, cTipo As Character, cForn As Character, cLoja As Character) As Character
	Local cQryE   As Character
	Local cQryB   As Character
	Local cRelTbl As Character
	Local cWhere  As Character
	Local cQryEst As Character
	Local nParam  As Numeric
	Local aParam  As Array
	Local nProx   As Numeric
	Local nY      As Numeric
	Local nX      As Numeric

	//Parâmetros da função
	Default cFil  := cFilant
	Default cPref := ""
	Default cNum  := ""
	Default cParc := ""
	Default cTipo := ""
	Default cForn := ""
	Default cLoja := ""

	//Inicializa as variáveis
	cQryE   := ""
	cQryB   := ""
	cRelTbl := ""
	cWhere  := ""
	cQryEst := ""
	nY      := 0
	nX      := 0
	nProx   := 0
	aParam  := {{"FK4", "FK7", "FKA", "FK3", "FK0", "SE2", cFil, cPref, cNum, cParc, cTipo, cForn, cLoja, cFil+'|'+cPref+'|'+cNum+'|'+cParc+'|'+cTipo+'|'+cForn+'|'+cLoja},;				
				{"FK4", "FK7", "FKA", "FK3", "FK0", "SE2", cFil, cPref, cNum, cParc, cTipo, cForn, cLoja, cFil+'|'+cPref+'|'+cNum+'|'+cParc+'|'+cTipo+'|'+cForn+'|'+cLoja},;
				{"FK4", "FK2", "FK3", "FK7", "FKA", "SE2", cFil, cPref, cNum, cParc, cTipo, cForn, cLoja, cFil+'|'+cPref+'|'+cNum+'|'+cParc+'|'+cTipo+'|'+cForn+'|'+cLoja},;
				{"FK4", "FK2", "FK3", "FK7", "FKA", "SE2", cFil, cPref, cNum, cParc, cTipo, cForn, cLoja, cFil+'|'+cPref+'|'+cNum+'|'+cParc+'|'+cTipo+'|'+cForn+'|'+cLoja}}	
	
	nParam  := (len(aParam))

	If __oPrepCP == Nil
		cQryE := "SELECT SE2.E2_PIS,SE2.E2_COFINS,SE2.E2_CSLL,SE2.E2_IRRF,SE2.E2_ISS,SE2.E2_INSS,SE2.E2_FABOV,SE2.E2_FACS,SE2.E2_SEST, FK4.FK4_VALOR,"
		cQryE += "FK4.FK4_BASIMP,FK4.FK4_IMPOS,FK4.FK4_DATA,FK4.FK4_CODFKM,FK4.FK4_FILORI,FK3.FK3_TABORI,FK3.FK3_VALOR,FK3.FK3_BASIMP "

		//União das consulta de retenções na emissão e baixa
		cQryB := "UNION ALL" + cQryE

		//Relacionamento das tabelas
		cRelTbl := "FROM ? FK4 "
		cRelTbl += "INNER JOIN ? FK7 ON (FK4.FK4_IDORIG = FK7.FK7_IDDOC) "
		cRelTbl += "INNER JOIN ? FKA ON (FK7.FK7_IDDOC = FKA.FKA_IDORIG AND FK7.FK7_ALIAS = FKA.FKA_TABORI) "
		cRelTbl += "INNER JOIN ? FK3 ON (FK4.FK4_FILIAL = FK3.FK3_FILIAL AND FK4.FK4_IDORIG = FK3.FK3_IDORIG ) "
		cRelTbl += "INNER JOIN ? FK0 ON (FK4.FK4_FILIAL = FK0.FK0_FILIAL AND FK4.FK4_IDORIG = FK0.FK0_IDORIG ) "
		cRelTbl += "INNER JOIN ? SE2 ON (FK4.FK4_FILORI = SE2.E2_FILORIG AND FK4.FK4_CLIFOR = SE2.E2_FORNECE AND FK4.FK4_LOJA = SE2.E2_LOJA) "

		//Filtro da consulta
		cWhere := "WHERE  SE2.E2_FILIAL = ? AND "
		cWhere += "SE2.E2_PREFIXO = ? AND "
		cWhere += "SE2.E2_NUM = ? AND "
		cWhere += "SE2.E2_PARCELA = ? AND "
		cWhere += "SE2.E2_TIPO = ? AND "
		cWhere += "SE2.E2_FORNECE = ? AND "
		cWhere += "SE2.E2_LOJA = ? AND "
		cWhere += "FK7.FK7_CHAVE = ? AND "
		cWhere += "FK4.D_E_L_E_T_ = ' ' AND FK3.D_E_L_E_T_ = ' ' AND "
		cWhere += "FKA.D_E_L_E_T_ = ' ' AND SE2.D_E_L_E_T_ = ' ' AND "
		cWhere += "FKA.FKA_TABORI = 'SE2' AND FK3.FK3_TABORI = 'SE2' "

		//Cria a consulta de estorno (Alterações)
		cQryEst := "AND FKA.FKA_IDPROC NOT IN (SELECT DISTINCT(FKA.FKA_IDPROC) " + cRelTbl + cWhere
		cQryEst += "AND FK3.FK3_RECPAG = 'R' AND FK4.FK4_RECPAG = 'R' AND "
		cQryEst += "FK3.FK3_STATUS = '2' AND FK4.FK4_STATUS = '2') "

		//Complemento do filtro de retenções na emissão
		cWhere += "AND FK3.FK3_RECPAG = 'P' AND FK4.FK4_RECPAG = 'P' AND "
		cWhere += "FK3.FK3_STATUS = '1' AND FK4.FK4_STATUS = '1' "

		//Query de emissão
		cQryE += cRelTbl + cWhere + cQryEst
		cRelTbl := ""
		cWhere := ""
		cQryEst := ""

		//Relacionamento das tabelas para consulta de retenções na baixa
		cRelTbl := "FROM ? FK4 "
		cRelTbl += "INNER JOIN ? FK2 ON (FK4.FK4_FILIAL = FK2.FK2_FILIAL AND FK4.FK4_IDORIG = FK2.FK2_IDFK2) "
		cRelTbl += "INNER JOIN ? FK3 ON (FK4.FK4_FILIAL = FK3.FK3_FILIAL AND FK4.FK4_IDFK4 = FK3.FK3_IDRET AND "
		cRelTbl += "FK4.FK4_IDORIG = FK3.FK3_IDORIG ) "
		cRelTbl += "INNER JOIN ? FK7 ON (FK7.FK7_IDDOC = FK2.FK2_IDDOC) "
		cRelTbl += "INNER JOIN ? FKA ON (FKA.FKA_IDORIG = FK2.FK2_IDFK2) "
		cRelTbl += "INNER JOIN ? SE2 ON (FK4.FK4_FILORI = SE2.E2_FILORIG AND FK4.FK4_CLIFOR = SE2.E2_FORNECE AND FK4.FK4_LOJA = SE2.E2_LOJA) "
		
		//Filtro da consulta
		cWhere := "WHERE  E2_FILIAL = ? AND "
		cWhere += "SE2.E2_PREFIXO = ? AND "
		cWhere += "SE2.E2_NUM = ? AND "
		cWhere += "SE2.E2_PARCELA = ? AND "
		cWhere += "SE2.E2_TIPO = ? AND "
		cWhere += "SE2.E2_FORNECE = ? AND "
		cWhere += "SE2.E2_LOJA = ? AND "
		cWhere += "FK7.FK7_CHAVE = ? AND "
		cWhere += "FK4.D_E_L_E_T_ = ' ' AND FK3.D_E_L_E_T_ = ' ' AND "
		cWhere += "FKA.D_E_L_E_T_ = ' ' AND SE2.D_E_L_E_T_ = ' ' AND "
		cWhere += "FKA.FKA_TABORI = 'FK2' AND FK3.FK3_TABORI = 'FK2' "

		//Cria a consulta de estorno (Baixas)
		cQryEst := "AND FKA.FKA_IDPROC NOT IN (SELECT DISTINCT(FKA.FKA_IDPROC) " + cRelTbl + cWhere
		cQryEst += "AND FK3.FK3_RECPAG = 'R' AND FK4.FK4_RECPAG = 'R' AND "
		cQryEst += "FK3.FK3_STATUS = '2' AND FK4.FK4_STATUS = '2')"

		//Complemento do filtro de retenções na baixa
		cWhere += "AND FK3.FK3_RECPAG = 'P' AND FK4.FK4_RECPAG = 'P' AND "
		cWhere += "FK3.FK3_STATUS = '1' AND FK4.FK4_STATUS = '1' "

		//Concatena a query
		cQryB += cRelTbl + cWhere + cQryEst
		cQryE += cQryB
		cQryE := ChangeQuery(cQryE)

		//Cria o objeto oPreparC
		__oPrepCP := FWPreparedStatement():New(cQryE)
	EndIf	
	
	For nY := 1 To nParam
		For nX := 1 To len(aParam[nY])
			nProx += 1
			
			If nX <= 6
				__oPrepCP:SetNumeric(nProx, RetSqlName(aParam[nY, nX]))
			Else
				__oPrepCP:SetString(nProx, aParam[nY, nX])
			EndIf
		Next nX		
	Next nY

	//Incluir os valores do parâmetros na query
	cQryE := __oPrepCP:GetFixQuery()
Return cQryE

//-----------------------------------------------------------
/*/{Protheus.doc} FINXVRET
Função para cálculo da retenção efetivada na emissão ou baixa

@author Mauricio Pequim Jr
@since 19/12/2017
@version P12.1.17
/*/
//-----------------------------------------------------------
Function FINXVRET(cCart AS Character, cIdOrig AS Character, lOnlyMotor As Logical) AS Numeric

Local nRetencao AS Numeric
Local cQuery	AS Character

DEFAULT cCart := ''
DEFAULT cIdOrig := ''
DEFAULT lOnlyMotor := .F.

nRetencao := 0
cQuery	:= ""

If !Empty(cCart) .and. !Empty(cIdOrig)

	If __oPreparC == nil
		cQuery 	:= "SELECT SUM(FK4_VALOR) VLRIMP FROM ? "
		cQuery 	+= " WHERE FK4_IDORIG = ? AND"
		cQuery 	+= " FK4_RECPAG = ? AND"

		If lOnlyMotor
			cQuery 	+= " FK4_CODFKM <> ' ' AND"
		EndIF

		cQuery 	+= " D_E_L_E_T_ = ' ' "

		cQuery 	:= ChangeQuery(cQuery)
		__oPreparC:=FWPreparedStatement():New(cQuery)
	Endif

	__oPreparC:SetNumeric(1, RetSqlName("FK4"))
	__oPreparC:SetString(2,cIdOrig)
	__oPreparC:SetString(3,cCart)

	cQuery := __oPreparC:GetFixQuery()

	nRetencao := ABS(MpSysExecScalar(cQuery,"VLRIMP"))

Endif

Return nRetencao

//-----------------------------------------------------------
/*/{Protheus.doc} FinRetBxMR
	Retorna valor dos impostos retidos na baixa, via motor de retenção.

	@cCart - Carteira
	@cIdOrig - Identificador de Origem da FK
	@lMotRet - Considera apenas motor de retenção
	@aTipoImp - Impostos a serem considerados

	@author Sivaldo Oliveira
	@since 19/01/2017
	@version P12.1.17
/*/
//-----------------------------------------------------------
Function FinRetBxMR(cCart AS Character, cIdOrig AS Character, lMotRet As Logical, cTipoImp As Character) AS Numeric
	
	Local nRetencao AS Numeric
	Local cQuery	AS Character

	DEFAULT cCart := ' '
	DEFAULT cIdOrig := ' '
	DEFAULT lMotRet := .T.
	DEFAULT cTipoImp := ' '

	nRetencao := 0
	cQuery	:= ""

	If !Empty(cCart) .and. !Empty(cIdOrig)

		cQuery := "SELECT SUM(FK4_VALOR) VLRIMP FROM "+ RetSqlName("FK4") +" "
		cQuery += " WHERE FK4_IDORIG = '"+ cIdOrig +"' AND"
		cQuery += " FK4_RECPAG = '"+ cCart +"' AND "
		
		If !Empty(cTipoImp)
			cQuery += " FK4_IMPOS = '"+ cTipoImp +"' AND "
		EndIf
		
		If lMotRet
			cQuery += " FK4_CODFKM <> ' ' AND "
		EndIf

		cQuery += " D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		nRetencao := ABS(MpSysExecScalar(cQuery,"VLRIMP"))
		
	Endif

Return nRetencao

//-----------------------------------------------------------
/*/{Protheus.doc} FRTDelObj
Destroy o objeto da query criada pela FINXVRET

@author Mauricio Pequim Jr
@since 13/01/2017
@version P12.1.7
/*/
//-----------------------------------------------------------
Function FRTDelObj(nObjeto As Numeric)

DEFAULT nObjeto := 1

If nObjeto == 1
	If __oPreparC != NIL
		__oPreparC:Destroy()
		__oPreparC := NIL
	Endif

	If __oPrepCP != NIL
		__oPrepCP:Destroy()
		__oPrepCP := NIL
	Endif
Endif

If nObjeto == 2 .and. __oPreparR != NIL
	__oPreparR:Destroy()
	__oPreparR := NIL
Endif

//Total de retenções no periodo para um determinado imposto
If nObjeto == 3 .and. __oPreparA != NIL
	__oPreparA:Destroy()
	__oPreparA := NIL
Endif

Return


//-----------------------------------------------------------
/*/{Protheus.doc} FRTCONPOS
Posiciona o registro SE1/SE2 e chama a consulta genérica de
retenções de um titulo

@author Mauricio Pequim Jr
@since 19/12/2017
@version P12.1.7
/*/
//-----------------------------------------------------------
Function FRTCONPOS (cAlias As Character, nRecno as Numeric)

Local aArea As Array
Local aAreaSE As Array

DEFAULT cAlias := ""
DEFAULT nRecno := 0

If !Empty(cAlias) .and. nRecno != 0

	aAreaSE:= (cAlias)->(GetArea())
	aArea := GetArea()

	(cAlias)->(DbGoto(nRecno))
	FINCRET(cAlias)

	(cAlias)->(RestArea(aAreaSE))
	RestArea(aArea)
Endif

Return


//-----------------------------------------------------------
/*/{Protheus.doc} FTemMotor
Verifica se o Motor de retenção está implantado
Dicionário e função principal

@author Mauricio Pequim Jr
@since 19/12/2017
@version P12.1.7
/*/
//-----------------------------------------------------------
Function FTemMotor()

//Motor de retenções
If __lMotorRet == Nil .and. Type('cFilAnt') != "U"

	__lMotorRet := AliasInDic('FKK') .and. AliasInDic('FK0').and. AliasInDic('F2B') .and. AliasInDic('F2E') .and. ;
					FindFunction("FINCRET") .and. FindFunction("FISA170") .and. FindFunction("FinCalImp")  .and. FindFunction("FINA024RFI")

Endif

Return __lMotorRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function FSE2ColImp
Retorna a relação de colunas utilizadas na tabela SE2 relacionadas a tributos
@author  norbertom
@since   27/12/2017
@version P12.1.17
/*/
//-------------------------------------------------------------------
Function FSE2ColImp() as Character
LOCAL cRet as Character

/** ISS */
cRet := "E2_BASEISS|E2_CODISS|E2_FORNISS|E2_FRETISS|E2_ISS|E2_MDRTISS|E2_PARCISS|E2_PRISS|E2_TRETISS|E2_VBASISS|E2_VENCISS|E2_VRETISS"
/** INSS */
cRet += "|E2_BASEINS|E2_CODINS|E2_INSS|E2_INSSRET|E2_PARCINS|E2_PRETINS|E2_PRINSS|E2_RETINS|E2_TITINS|E2_VRETINS"
/** IRRF */
cRet += "|E2_BASEIRF|E2_DTDIRF|E2_IRRF|E2_PARCIR|E2_PRETIRF|E2_VRETIRF"
/** PIS */
cRet += "|E2_BASEPIS|E2_CODRPIS|E2_PARCPIS|E2_PIS|E2_PRETPIS|E2_TITPIS|E2_VRETPIS"
/** COFINS */
cRet += "|E2_BASECOF|E2_CODRCOF|E2_COFINS|E2_PARCCOF|E2_PRETCOF|E2_TITCOF|E2_VRETCOF"
/** CSLL */
cRet += "|E2_BASECSL|E2_CODRCSL|E2_CSLL|E2_PARCSLL|E2_PRETCSL|E2_TITCSL|E2_VRETCSL"
/** SEST */
cRet += "|E2_PARCSES|E2_SEST"
/** CIDE */
cRet += "|E2_CIDE|E2_PARCCID"
/** OUTROS */
cRet += "|E2_AGLIMP|E2_FIMP|E2_PARIMP1|E2_PARIMP2|E2_PARIMP3|E2_PARIMP4|E2_PARIMP5|E2_FETHAB|E2_PARCFET|E2_FABOV|E2_FACS|E2_PARCFAB|E2_PARCFAC|E2_PARCFAM|E2_PARCFMP"

Return cRet

//-----------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FMRGETRET
Retorna o total de retenção do imposto na emissão título

@type function
@author PEQUIM

@since 28/1208/2017
@version 1.0
@return $numerico, $Valor de retenção realizada pelo título, caso houver.
@example
	nRetencao := F240GETRET("SE2")
/*/
//-----------------------------------------------------------------------------------------------------------------------
Function FMRGETRET(cCart As Character, cAliasRet As Character, lOnlyMotor As Logical)

Local nRetencao As Numeric
Local cChaveTit As Character
Local cChaveFK7 As Character

DEFAULT cCart := ""
DEFAULT cAliasRet := ""
DEFAULT lOnlyMotor := .F.

nRetencao := 0
cChaveTit := ''
cChaveFK7 := ''

If !Empty(cCart) .and. !Empty(cAliasRet)
	If cCart == 'R'
		cChaveTit := xFilial("SE1", (cAliasRet)->E1_FILORIG)	+ "|" +;
									(cAliasRet)->E1_PREFIXO		+ "|" +;
									(cAliasRet)->E1_NUM			+ "|" +;
									(cAliasRet)->E1_PARCELA		+ "|" +;
									(cAliasRet)->E1_TIPO		+ "|" +;
									(cAliasRet)->E1_CLIENTE		+ "|" +;
									(cAliasRet)->E1_LOJA
		cChaveFK7 := FINGRVFK7("SE1", cChaveTit)
	Else
		cChaveTit := xFilial(cAliasRet, (cAliasRet)->E2_FILORIG)	+ "|" +;
										(cAliasRet)->E2_PREFIXO		+ "|" +;
										(cAliasRet)->E2_NUM			+ "|" +;
										(cAliasRet)->E2_PARCELA		+ "|" +;
										(cAliasRet)->E2_TIPO		+ "|" +;
										(cAliasRet)->E2_FORNECE		+ "|" +;
										(cAliasRet)->E2_LOJA
		cChaveFK7 := FINGRVFK7("SE2", cChaveTit)
	Endif

	nRetencao := FINXVRET(cCart, cChaveFK7, lOnlyMotor)

EndIf

Return nRetencao

//-------------------------------------------------------------------
/*/{Protheus.doc} FinCumBor()
Filtro os movimentos de inclusão de pcc pendente de retenção, para compor
a base de cálculo para retenção por cumulatividade - BORDERO

@author  Mauricio Pequim Jr/Sivaldo Oliveira/Leonardo Castro
@since 16/10/2017
@version 12
/*/
//-------------------------------------------------------------------
Static Function FinCumBor(cCart As Character, cCliFor As Character, cLoja As Character, dDtRef As Date, cFils As Character, cFilOrig As Character, lFilComp As Logical, cCodFKK As Character, cChaveFK7 As Character)

Local lRet As Logical
Local cCampoQry As Character
Local cTabQry As Character
Local cWherQry As Character
Local cQry As Character
Local cTblTmp As Character
Local aAreaAt As Array
Local cCarteira As Character
Local cTabOri As Character
Local cTabEmi As Character
//------------------------------------//
//Parâmetros da função
Default cCart := ""
Default cCliFor := ""
Default cLoja := ""
Default dDtRef := dDataBase
Default cFils := ""
Default cFilOrig := ""
Default lFilComp := .F.
Default cCodFKK  := ""
Default cChaveFK7 := ""

//Inicializa as variáveis
lRet := .T.
aAreaAt := GetArea()
cTblTmp := ""
cCampoQry := ""
cTabQry := ""
cWherQry := ""
cQry := ""
cTabOri := "FK7"
cTabEmi := "SE2"

If cCart == "1"
	cCarteira := "P"
ElseIf cCart == "2"
	cCarteira := "R"
EndIf

If Empty(cCart) .Or. Empty(cCliFor+cLoja)
	lRet := .F.
Else
	cCliFor := FinCumCLF(cCart,cCliFor,cLoja,cFilOrig)
Endif

If lRet .And. !Empty(cCliFor)
	cTblTmp := GetNextAlias()

	//Retenções pendentes de Borderôs
	cQry := " SELECT "
	cCampoQry += " FK3.FK3_FILIAL, FK3.FK3_IDFK3, FK3.FK3_DATA, FK3.FK3_VALOR, FK3.FK3_MOEDA, FK3.FK3_NATURE, FK3.FK3_RECPAG, FK3.FK3_IDRET, "+;
					" FK3.FK3_IMPOS, FK3.FK3_FILORI, FK3.FK3_BASIMP, FK3.FK3_ORIGEM, FK3.FK3_VLMOE2, FK3.FK3_IDORIG, FK3.FK3_TABORI, "+;
					" FK3.FK3_STATUS, FK3.FK3_CODFKM, FK3.FK3_CLIFOR, FK3.FK3_CGC, FK3.FK3_RAICGC, FK3.R_E_C_N_O_ FK3RECNO "
	cTabQry += " FROM " + RetSqlName("FK3") + " FK3 "
	cWherQry += " WHERE "
	cWherQry += " FK3.FK3_TABORI = 'FK7' "
	cWherQry += " AND FK3.FK3_CODFKM = '" + cCodFKK + "' "
	cWherQry += " AND FK3.FK3_FILORI IN " + FMRTipoIN(cFils) + " "
	cWherQry += " AND FK3.FK3_DATA = '" + DToS(dDtRef) + "' "
	cWherQry += " AND FK3.FK3_ORIGEM IN ('FINA241','FINA590','FINA061') "
	cWherQry += " AND FK3.FK3_IDRET = ' ' "
	cWherQry += " AND FK3.D_E_L_E_T_ = ' ' " // Controle de Deletados

	//Clientes/Fornecedores a serem considerados na cumulatividade
	cWherQry += " AND " + cCliFor

	// Controle de Gerados
	cQry += cCampoQry + cTabQry + cWherQry + " AND FK3.FK3_RECPAG = '" + cCarteira + "' "

	cQry := ChangeQuery( cQry )

	If Select(cTblTmp) > 0
		(cTblTmp)->(dbCloseArea())
	Endif

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), cTblTmp, .F., .T.)

	If (cTblTmp)->(EOF())
		(cTblTmp)->(dbCloseArea())
		cTblTmp := ""
	EndIf
EndIf

RestArea(aAreaAt)

Return cTblTmp


//----------------------------------------------------------------------------------------------
/*/{Protheus.doc}FMRVOutImp
Verifica se a retenção atual reteve impostos de outros titulos e limpa o ID de retenção

@author Mauricio Pequim Jr

@since  10/01/2018
@version 12
/*/
//----------------------------------------------------------------------------------------------
Function FMRVOutImp(cTabOri As Character, cIdOrig As Character, cNumBord As Character)

Local aArea As Array
Local aAreaSE2 As Array
Local aIdsReten As Array
Local aTables As Array
Local cAliasFK3 As Character
Local cIdRet As Character
Local cChave As Character
Local cQuery As Character
Local cAliasTit As Character
Local cKeyTit As Character
Local lDeleted As Logical

DEFAULT cTabOri := ''
DEFAULT cIdOrig := ''
DEFAULT cNumBord := ''

aArea := GetArea()
aAreaSE2 := SE2->(GetArea())
cAliasFK3 := ''
aIdsReten := {}
aTables := {}
cIdRet := ''
cChave := ''
cQuery := ''
cAliasTit := ''
cKeyTit := ''
lDeleted := .F.

If cTabori == 'FK1'
	aTables := {'FK1','FK7'}
	cAliasTit := 'SE1'
ElseIf  cTabori == 'FK2'
	aTables := {'FK2','FK7'}
	cAliasTit := 'SE2'
Endif

//Encontro todas os IDs de retenções realizadas para um determinado título
FK3->(dbSetOrder(2))		//FK3_FILIAL, FK3_TABORI, FK3_IDORIG
If FK3->(MSSeek(xFilial('FK3') + cTabori + cIdOrig))
	cIdRet := FK3->FK3_IDRET
	cChave := FK3->(FK3_FILIAL+FK3_TABORI+FK3_IDORIG)
	While FK3->(!EOF()) .and. cChave == FK3->(FK3_FILIAL+FK3_TABORI+FK3_IDORIG)
		aadd(aIdsReten, FK3->FK3_IDRET )
		FK3->(dbSkip())
	EndDo
Endif

If __oPreparR == nil
	cQuery 	:= "SELECT R_E_C_N_O_ REGFK3 FROM ? "
	cQuery 	+= " WHERE FK3_IDORIG <> ? AND"
	cQuery 	+= " FK3_TABORI IN (?) AND"
	cQuery 	+= " FK3_IDRET IN (?) AND"
	cQuery 	+= " D_E_L_E_T_ = ' ' "

	cQuery 	:= ChangeQuery(cQuery)
	__oPreparR:=FWPreparedStatement():New(cQuery)
Endif

__oPreparR:SetNumeric(1, RetSqlName("FK3"))
__oPreparR:SetString(2,cIdOrig)
__oPreparR:SetIn(3,aTables)
__oPreparR:SetIn(4,aIdsReten)

cQuery := __oPreparR:GetFixQuery()

cAliasFK3 := mpsysopenquery(cQuery)

dbSelectArea(cAliasFK3)
If (cAliasFK3)->(!Eof())
	FK3->(dbGoto((cAliasFK3)->REGFK3))
	lDeleted := .F.

	//Se for um cancelamento de borderô CP, verifico se o titulo que teve retenção efativada nessa baixa pertence ao mesmo borderô
	//Em caso positivo, deleto a FK3 e
	If !Empty(cNumBord) .and. FK3->FK3_TABORI == 'FK7' .AND. Alltrim(FK3->FK3_ORIGEM) $ 'FINA241|FINA590S'
		FK7->(DBSetOrder(1))
		If FK7->(MsSeek(xFilial('FK7') + FK3->FK3_IDORIG ))
			cKeyTit := RTrim(StrTran(FK7->FK7_CHAVE,'|',))
			SE2->(dbSetOrder(1))
			If SE2->(MsSeek(cKeyTit))
				If Alltrim(SE2->E2_NUMBOR) == Alltrim(cNumBord)
					RecLock("FK3",.F.)
					dbDelete()
					MsUnlock()
					lDeleted := .T.
				EndIf
			Endif
		Endif
	Endif

	If !lDeleted
		RecLock("FK3",.F.)
		FK3->FK3_IDRET	:= ""
		MsUnlock()
	Endif

	(cAliasFK3)->(dbSkip())
Endif

If cTabori == 'FK2'
	RestArea(aAreaSE2)
Endif

RestArea(aArea)

(cAliasFK3)->(dbCloseArea())

Return

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc}FMRDelImp
Deleta os titulos de impostos (SE2) e o registro de retenção (FK0) - Motor retenção

@author Mauricio Pequim Jr

@since  10/01/2018
@version 12
/*/
//----------------------------------------------------------------------------------------------
Function FMRDelImp(cTabOri As Character, cIdOrig As Character, nOperacao As Numeric)

Local aAreaAnt As Array
Local oModel As Object
Local oSubFKA As Object
Local lRet As Logical

DEFAULT cTabOri := ""
DEFAULT cIdOrig := ""
DEFAULT nOperacao := 3

oModel := NIL
oSubFKA := NIL
lRet := .T.

//Motor de Retenção Exclusão de baixas
aAreaAnt := GetArea()
FKA->(dbSetOrder(3))

If !Empty(cTabori) .AND. !Empty(cIdOrig)

	If FKA->(msSeek(xFilial('FKA') + cTabOri + cIdOrig ))
		FinSetAPrc(cTabOri)

		oModel := FWLoadModel("FINM060")
		oModel:SetOperation(4)
		oModel:Activate()
		oModel:SetValue( "MASTER", "OPERACAO", nOperacao)
		oSubFKA := oModel:GetModel("FKADETAIL")

		If oSubFKA:SeekLine( { {"FKA_IDORIG", cIdOrig } } )
			If oModel:VldData()
				oModel:CommitData()
			Else
				lRet := .F.
				cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
				cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
				cLog += cValToChar(oModel:GetErrorMessage()[6])
				Help( ,,"M060VLDI1",,cLog, 1, 0 )
				DisarmTransaction()
			Endif

		Endif

		oModel:DeActivate()
		oModel:Destroy()
		oModel:= Nil
		FinSetAPrc()

		If !lRet
			Break
		Endif

		RestArea(aAreaAnt)
	EndIf
Endif

Return

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc}FMRFatGer
Verifica em que momento determinado imposto sera retido (fato gerador - motor de retencoes)
@return cRet - 0 caso nao haja config; 1 competencia, 2 caixa
@author Igor Sousa do Nascimento
@since  08/02/2018
@version 12
/*/
//----------------------------------------------------------------------------------------------
Function FMRFatGer(cCart As Character,cImposto As Character,cNatur As Character,cCliFor As Character,cLoja As Character,dVigen As Date) As Character

	Local aArea  As Array
	Local cTmp 	 As Character
	Local cQuery As Character
	Local cRet   As Character

	Default cCart 	 := ""
	Default cImposto := ""
	Default cNatur 	 := ""
	Default cCliFor  := ""
	Default cLoja 	 := ""
	Default dVigen 	 := dDataBase

	aArea	:= GetArea()
	cTmp	:= CriaTrab(,.F.)
	cQuery	:= ""
	cRet	:= "1"

	If cCart == "P"
		cCart := "1"
	ElseIf cCart == "R"
		cCart := "2"
	EndIf

	cQuery += "SELECT FKM.FKM_CODIGO, FKM.FKM_FATGER "
	cQuery += "FROM " + RetSqlName("FKM") + " FKM "
	cQuery += "WHERE "
	cQuery += 	 "FKM.FKM_FILIAL = '" + xFilial("FKM") + "' AND FKM.FKM_CART = '" + cCart + "' AND FKM.FKM_ATIVO = '1' AND "
	cQuery += 	 "FKM.FKM_VIGINI <= '" + DToS(dVigen) + "' AND FKM.FKM_VIGINI <= '" + DToS(dVigen) + "' AND "
	cQuery += 	 "FKM.FKM_CODIGO IN ( "
	cQuery += 		"SELECT FOI.FOI_CODIGO "
	cQuery += 		"FROM " + RetSqlName("FOI") + " FOI "
	cQuery += 			"INNER JOIN " + RetSqlName("FOK") + " FOK "
	cQuery += 			"ON FOK.FOK_FILIAL = FOI.FOI_FILIAL AND "
	cQuery += 				"FOK.FOK_CODIGO = FOI.FOI_CODIGO AND "
	cQuery += 				"FOK.D_E_L_E_T_ = ' ' "
	cQuery += 			"INNER JOIN " + RetSqlName("FOO") + " FOO "
	cQuery +=  			"ON FOO.FOO_FILIAL = FKM.FKM_FILIAL AND "
	cQuery += 				"FOO.FOO_IDRET = FKM.FKM_IDRET AND "
	cQuery += 				"FOO.FOO_CODIGO IN ('" + cImposto + "') AND "
	cQuery += 				"FOO.D_E_L_E_T_ = ' ' "
	cQuery += 			"WHERE FOI.FOI_FILIAL = FKM.FKM_FILIAL AND "
	cQuery += 				"FOI.FOI_NATURE = '" + cNatur + "' AND "
	cQuery += 				"FOI.FOI_CODIGO = FKM.FKM_CODIGO AND "
	cQuery += 				"FOK.FOK_CODIGO = FKM.FKM_CODIGO AND "
	cQuery += 				"FOI.D_E_L_E_T_ = ' ' ) AND "
	cQuery += 	 "FKM.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery(cQuery, cTmp)
	dbSelectArea(cTmp)

	If !(cTmp)->(EoF())
		If (cTmp)->FKM_FATGER == "2"
			cRet := "2"
		EndIf
	Else
		cRet := "0"
	EndIf

	(cTmp)->(dbCloseArea())
	RestArea(aArea)

Return cRet

//--------------------------------
/*/{Protheus.doc}FinImpBor
Retorna valor total do(s) imposto(s) retido(s) no borderô via motor de retenção.
@author Sivaldo Oliveira
@since 16/03/2017
@version P12.1.17
/*/
//--------------------------------
Function FinImpBor(cCart AS Character, cChaveFK7 As Character, cNumBor As Character, cTabOri As Character) As Numeric
Local nRetencao As Numeric
Local cQry As Character
Local cFrom As Character
Local cRelTbl As Character
Local lRet As Logical

Default cCart := ""
Default cChaveFK7 := ""
Default cNumBor := ""
Default cTabOri := ""

//Inicializa variáveis
nRetencao := 0
cQry := ""
cFrom := ""
cRelTbl := ""
cWhere := ""
lRet := .T.

If Empty(cCart) .Or. Empty(cChaveFK7) .Or. Empty(cNumBor) .Or. Empty(cTabOri)
	lRet := .F.
EndIf

If lRet
	If __oImpBor == Nil
		//Campos da consulta
		cQry := "SELECT SUM(FK4.FK4_VALOR) VLRIMP "
		//tabela principal, mas os relacionamentos envolvidos
		cFrom := "FROM ? FK4 "
		cRelTbl += "INNER JOIN ? FK2 "
		cRelTbl += "ON (FK4.FK4_FILORI = FK2.FK2_FILORI AND FK4.FK4_IDORIG = FK2.FK2_IDFK2) "
		cRelTbl += "INNER JOIN ? FK7 "
		cRelTbl += "ON (FK7.FK7_FILIAL = FK2.FK2_FILIAL AND FK7.FK7_IDDOC = FK2.FK2_IDDOC) "
		cRelTbl += "INNER JOIN ? FKA "
		cRelTbl += "ON (FKA.FKA_FILIAL = FK2.FK2_FILIAL AND FKA.FKA_IDORIG = FK2.FK2_IDFK2) "
		//Filtro da consulta
		cWhere :=  "WHERE FK2.FK2_MOTBX = 'IMR' AND FK2.FK2_RECPAG = ? AND FK7.FK7_CHAVE = ? AND "
		cWhere +=  "FK2.FK2_DOC = ? AND FKA.FKA_TABORI = ? AND FK4.D_E_L_E_T_ = ' ' AND "
		cWhere +=  "FK2.D_E_L_E_T_ = ' ' AND FKA.D_E_L_E_T_ = ' ' AND FK7.D_E_L_E_T_ = ' ' "
		//concatenção da consulta
		cQry += cFrom + cRelTbl + cWhere
		cQry := ChangeQuery(cQry)
		__oImpBor := FWPreparedStatement():New(cQry)
	EndIf

	__oImpBor:SetNumeric(1, RetSqlName("FK4"))
	__oImpBor:SetNumeric(2, RetSqlName("FK2"))
	__oImpBor:SetNumeric(3, RetSqlName("FK7"))
	__oImpBor:SetNumeric(4, RetSqlName("FKA"))
	__oImpBor:SetString(5, cCart)
	__oImpBor:SetString(6, cChaveFK7)
	__oImpBor:SetString(7, cNumBor)
	__oImpBor:SetString(8, cTabOri)

	cQry := __oImpBor:GetFixQuery()
	nRetencao := ABS(MpSysExecScalar(cQry,"VLRIMP"))
EndIf

Return nRetencao

/*/{Protheus.doc} FMRGetArr()
Função para retornar o array de impostos do motor, na mesma estrutura retornada pela função de cálculo (FINCalImp),
com base nas informações de impostos já gravadas para um título.

@type function
@param cCart, character, Indica se é contas a pagar ou receber ("1" = Pagar; "2" = Receber)
@param lDestroy, logical, destroi o modelo
@return array, Vetor contendo os dados dos impostos calculados pelo motor de retenções.

@author Pedro Alencar
@since 08/03/2018
@version 12
/*/
Function FMRGetArr( cCart As Char, lDestroy As Logical ) As Array
	Local aRet 		As Array
	Local oSubTit 	As Object
	Local oSubFK3 	As Object
	Local oSubFK4 	As Object
	Local nI 		As Numeric
	Local nLenGrdFK3 As Numeric
	Local cCodFKK 	As Char
	Local nBaseCalc As Numeric
	Local nValCalc 	As Numeric
	Local nBaseRet 	As Numeric
	Local nValRet 	As Numeric
	Local cIdRetFK3 As Char
	Local cTipoImp 	As Char
	Local cNatTit 	As Char
	Local aAreaFKK 	As Array
	Local cAliasMR 	As Char

	Default cCart 		:= "2"
	Default lDestroy	:= .T.

	aRet 		:= {}
	oSubTit 	:= Nil
	oSubFK3 	:= Nil
	oSubFK4 	:= Nil
	nI 			:= 0
	cCodFKK 	:= ""
	nBaseCalc 	:= 0
	nValCalc 	:= 0
	nBaseRet 	:= 0
	nValRet 	:= 0
	cIdRetFK3 	:= ""
	cTipoImp 	:= ""
	cNatTit 	:= ""
	aAreaFKK 	:= FKK->( GetArea() )
	cAliasMR 	:= Iif( cCart == "2", "SE1", "SE2" )

	//Inicia as variáveis estáticas da rotina FINCRET
	FCRetStat( cAliasMR )
	If ( __oModelMR == Nil )
		__oModelMR := FWLoadModel( "FINCRET" )
		__oModelMR:SetOperation( 1 ) //Alteração
	EndIf
	oModelMR := __oModelMR
	oModelMR:Activate()

	oSubTit := oModelMR:GetModel( "TITMASTER" )
	oSubFK3 := oModelMR:GetModel( "FK3EDETAIL" )
	oSubFK4 := oModelMR:GetModel( "FK4EDETAIL" )

	nLenGrdFK3 := oSubFK3:Length()

	FKK->( dbSetOrder( 3 ) ) //FKK_FILIAL+FKK_ATIVO+FKK_CODIGO+FKK_VERSAO

	For nI := 1 To nLenGrdFK3
		oSubFK3:GoLine( nI )

		cCodFKK 	:= oSubFK3:GetValue( "FK3_CODFKM" ) //Código FKK
		nBaseCalc 	:= oSubFK3:GetValue( "FK3_BASIMP" ) //Base de Calculo
		nValCalc 	:= oSubFK3:GetValue( "FK3_VALOR" ) //Valor de Cálculo
		cIdRetFK3 	:= oSubFK3:GetValue( "FK3_IDRET" ) //Id de Retenção
		cTipoImp 	:= oSubFK3:GetValue( "FK3_IMPOS" ) //Tipo do Imposto

		nBaseRet 	:= oSubFK4:GetValue( "FK4_BASIMP" ) //Base de Retenção
		nValRet 	:= oSubFK4:GetValue( "FK4_VALOR" ) //Valor de Retenção
		cNatTit 	:= oSubFK4:GetValue( "FK4_NATURE" ) //Valor de Retenção

		If FKK->( MsSeek ( FWxFilial("FKK") + "1" + cCodFKK ) )
			Aadd( aRet, { cCodFKK, nBaseCalc, nValCalc, nBaseRet, nValRet, cIdRetFK3, {}, AllTrim(cTipoImp),; 
							FKK->FKK_FATGER, cNatTit, "", 0, FKK->FKK_VLNOTA,,, FKK->FKK_PROVIS,; 
							FKK->FKK_VARCTB, FKK->FKK_IDRET, FKK->FKK_ADTO, .T., FKK->(RECNO()), 0, FKK->FKK_CODRET } )
		EndIf

	Next nI

	oModelMR:DeActivate()
	If lDestroy
		__oModelMR:Destroy()
		__oModelMR	:= Nil
		oModelMR:Destroy()
		oModelMR := Nil
	EndIf

	RestArea( aAreaFKK )
Return aRet

//---------------------------------------
/*/{Protheus.doc} FinRet1Bx
Verifica se a retenção ocorre na 1ª baixa ou ocorrerá em cada baixa
@return lRet .T. ocorreu na 1ª baixa, .F. ocorrerá a cada baixa

@author Sivaldo Oliveira
@since 23/03/2018
@version 12
/*/
//---------------------------------------
Static Function FinRet1Bx(cFil As Character, cIdTitPai As Character, cCodFKK As Character, cCart As Character) As Logical
	Local lRet    As Logical
	Local cQry    As Character
	Local cTblTmp As Character
	Local cTabOri As Character

	Default cFil      := cFilAnt
	Default cIdTitPai := ""
	Default cCodFKK   := ""
	Default cCart     := ""

	//Inicializa variáveis
	lRet    := .F.
	cQry    := ""
	cTblTmp := ""
	cTabOri := ""

	If Empty(cIdTitPai) .Or. Empty(cCodFKK) .Or. Empty(cCart)
		lRet := .T.
	EndIf

	If !lRet
		aArea := GetArea()

		If cCart $ "1|P"
			cTabOri := "FK2"
			cCart := "P"
		Else
			cTabOri := "FK1"
			cCart := "R"
		EndIf
		
		If __Ret1Bx == Nil
			cQry := "SELECT FK4_CODFKM FROM ? FK4 INNER JOIN ? FK0 "
			cQry += "ON (FK4.FK4_FILORI = FK0.FK0_FILORI AND FK4.FK4_IDORIG = FK0.FK0_IDORIG AND FK4.FK4_CODFKM = FK0.FK0_CODFKM) "
			cQry += "WHERE FK4.FK4_FILIAL = ? AND FK4.FK4_CODFKM = ? AND FK4.FK4_RECPAG = ? AND FK0.FK0_IDPAI = ? AND "
			cQry += "FK0.FK0_TABORI = ? AND FK4.FK4_STATUS = '1' AND FK4.D_E_L_E_T_ = ' ' AND FK0.D_E_L_E_T_ = ' ' "
			cQry := ChangeQuery(cQry)
			__Ret1Bx := FWPreparedStatement():New(cQry)
		EndIf
		
		__Ret1Bx:SetNumeric(1, RetSqlName("FK4"))
		__Ret1Bx:SetNumeric(2, RetSqlName("FK0"))
		__Ret1Bx:SetString(3, cFil)
		__Ret1Bx:SetString(4, cCodFKK)
		__Ret1Bx:SetString(5, cCart)
		__Ret1Bx:SetString(6, cIdTitPai)
		__Ret1Bx:SetString(7, cTabOri)
		
		cQry := __Ret1Bx:GetFixQuery()
		cTblTmp := MpSysOpenQuery(cQry)

		If (cTblTmp)->(!Eof())
			lRet := .T.
		EndIf
		(cTblTmp)->(DbCloseArea())
	EndIf
Return lRet

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc}FinTitImp
Verifica se existe um determinado imposto retido na emissão
@author Sivaldo Oliveira
@since 21/03/2017
@version P12.1.17
/*/
//-----------------------------------------------------------
Function FinTitImp(cTabOri As Character, cImposto As Character, cCart As Character, cChavImpFK7 As Character) As Logical
Local cQry As Character
Local cFrom As Character
Local cRelTbl As Character
Local lRet As Logical
Local cTblTmp As Character

//Inicializa variáveis
cQry := ""
cFrom := ""
cRelTbl := ""
cWhere := ""
lRet := .T.
cTblTmp := ""

If Empty(cTabOri) .Or. Empty(cImposto) .Or. Empty(cCart) .Or. Empty(cChavImpFK7)
	lRet := .F.
EndIf

If lRet
	cImposto := SubStr(AllTrim(cImposto), 1, TamSx3("FK4_IMPOS")[1])

	If __oTitImp == Nil
		//campos
		cQry := "SELECT FK4.FK4_IMPOS FK4_IMPOS "
		//tabela principal
		cFrom := "FROM ? FK4 "
		//tabelas relacionadas
		cRelTbl := "INNER JOIN ? FK0 "
		cRelTbl += "ON (FK4.FK4_FILORI = FK0.FK0_FILORI AND FK4.FK4_IDORIG = FK0.FK0_IDPAI AND FK4.FK4_CODFKM = FK0.FK0_CODFKM) "
		cRelTbl += "INNER JOIN ? FK7 "
		cRelTbl += "ON (FK7.FK7_FILIAL = FK0.FK0_FILIAL AND FK7.FK7_IDDOC = FK0.FK0_IDDOC) "
		//filtro da consulta
		cWhere := "WHERE FK7.FK7_ALIAS = ? AND FK0.FK0_TABORI = ? AND FK4.FK4_IMPOS = ? AND "
		cWhere += "FK4.FK4_RECPAG = ? AND FK7.FK7_CHAVE = ? AND FK4.D_E_L_E_T_ = ' ' AND "
		cWhere += "FK0.D_E_L_E_T_ = ' ' AND FK7.D_E_L_E_T_ = ' ' "
		//concatenação da query
		cQry += cFrom + cRelTbl + cWhere

		cQry := ChangeQuery(cQry)
		__oTitImp := FWPreparedStatement():New(cQry)
	EndIf

	__oTitImp:SetNumeric(1, RetSqlName("FK4"))
	__oTitImp:SetNumeric(2, RetSqlName("FK0"))
	__oTitImp:SetNumeric(3, RetSqlName("FK7"))
	__oTitImp:SetString(4, cTabOri)
	__oTitImp:SetString(5, cTabOri)
	__oTitImp:SetString(6, cImposto)
	__oTitImp:SetString(7, cCart)
	__oTitImp:SetString(8, cChavImpFK7)
	cQry := __oTitImp:GetFixQuery()
	cTblTmp := MpSysOpenQuery(cQry)
	
	If (cTblTmp)->(!Eof())
		lRet := .F.
	EndIf

	(cTblTmp)->(DbCloseArea())
EndIf

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc}FinExcImp
Exclusão de provisórios e impostos gerados no PA via motor de retenção(FK3|FK4|FK7|SE1|SE2)
gerados via Motor de retenção.

@author Sivaldo Oliveira
@since 29/03/2017
@version P12.1.17
/*/
//------------------------------------------------------------------
Function FinExcImp(aRetProv As Array)
Local nX As Numeric
Local nRetProv As Numeric
Local aSE1 As Array
Local aSE2 As Array

Default aRetProv := {}

//Inicializa variáveis
nX := 0
nRetProv := Len(aRetProv)

If nRetProv > 0
	/*-------------------------------------------
	Estrutura da aRetProv
	[1] = Chave FK3 | FK0_FILORI+FK0_TABORI+FK0_IDORIG
	[2] = Chave FK4 | FK0_FILORI+FK0_IDFK4
	[3] = Código FKM | FK0_CODFKM
	[4] = Chave FK7 | FK0_FILORI+FK0_IDDOC
	-------------------------------------------*/
	aSE1 := SE1->(GetArea())
	aSE2 := SE2->(GetArea())

	FK3->(dbSetOrder(2)) //FK3_FILIAL+FK3_TABORI+FK3_IDORIG+FK3_IMPOS
	FK4->(dbSetOrder(1)) //FK4_FILIAL+FK4_IDFK4
	SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE2->(dbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	FK7->(dbSetOrder(1)) //FK7_FILIAL+FK7_IDDOC

	For nX := 1 To nRetProv
		//Excluir provisórios e impostos gerados no PA(FK3)
		If FK3->(MsSeek(aRetProv[nX,1]))
			While FK3->(!EOF())
				If aRetProv[nX,3] == AllTrim(FK3->FK3_CODFKM)
					RecLock("FK3")
					FK3->(dbDelete())
					FK3->(MsUnlock())
					exit
				EndIf
				FK3->(DbSkip())
			EndDo
		EndIf

		//Excluir provisórios e impostos gerados no PA(FK4)
		If FK4->(MsSeek(aRetProv[nX,2]))
			While FK4->(!EOF())
				If aRetProv[nX,3] == AllTrim(FK4->FK4_CODFKM)
					RecLock("FK4")
					FK4->(dbDelete())
					FK4->(MsUnlock())
					exit
				EndIf
				FK4->(DbSkip())
			EndDo
		EndIf

		//Excluir provisórios e impostos gerados no PA(FK7 e SE1 ou SE2)
		If (FK7->(MsSeek(aRetProv[nX,4]))) .And. FK7->FK7_ALIAS $ "SE1|SE2"
			cTitImp := RTrim(StrTran(FK7->FK7_CHAVE, "|", ""))
			cTabPai := FK7->FK7_ALIAS

			If (cTabPai)->(MsSeek(cTitImp))
				RecLock(cTabPai)
				(cTabPai)->(dbDelete())
				(cTabPai)->(MsUnlock())
			EndIf

			RecLock("FK7")
			FK7->(dbDelete())
			FK7->(MsUnlock())
		EndIf
	Next nX

	RestArea(aSE1)
	RestArea(aSE2)
EndIf

Return Nil

//---------------------------------
/*/{Protheus.doc}FxBrowse
Criação e ativação do objeto de Browse

@author Sivaldo Oliveira
@since 10/09/2018
@version P12.1.17
/*/
//---------------------------------
Function FxBrowse(cTblBrowse As Character, nIndBrowse As Numeric, cTitBrowse As Character, aLegenda) As Object
	Local nY       As Numeric
	Local oBrowse  As Object

	//Parâmetros de funcção
	Default cTblBrowse := ""
	Default nIndBrowse := 0
	Default cTitBrowse := ""
	Default aLegenda   := {}

	cTblBrowse := AllTrim(cTblBrowse)

	//Inicializa variáveis.
	nY      := 0
	oBrowse := Nil

	If !Empty(cTblBrowse)
		DbSelectArea(cTblBrowse)

		If nIndBrowse > 0
			(cTblBrowse)->(DbSetOrder(nIndBrowse))
		EndIf

		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias(cTblBrowse)
		oBrowse:SetDescription(cTitBrowse)

		//Adiciona Legenda
		For nY := 1 To Len(aLegenda)
			oBrowse:AddLegend(aLegenda[nY, 1], aLegenda[nY, 2], aLegenda[nY, 3])
		Next nY

		oBrowse:Activate()
	EndIf

Return oBrowse

//---------------------------------
/*/{Protheus.doc}FxMenuDef
Cria menu padrão ou personalizado

@author Sivaldo Oliveira
@since 10/09/2018
@version P12.1.17
/*/
//---------------------------------
Function FxMenuDef(lMenuPad As Logical, aRotina As Array, aAcao As Array) As Array
	Local nY    As Numeric
	Local aMenu As Array
	Local nRot  As Numeric
	Local nPos  As Numeric
	Local cAcao As Character

	//Parâmetros da função
	Default aRotina  := {}
	Default lMenuPad := .T.
	Default aAcao    := {}

	//Inicializa variáveis
	nY    := 0
	aMenu := {}
	nRot  := Len(aRotina)
	nPos  := 0
	cAcao := ""

	If lMenuPad
		aMenu := FxMenu()
	EndIf

	//Addiciona itens ao menu padrao ou Cria menu personalizado
	For nY := 1 To nRot
		ADD OPTION aMenu TITLE aRotina[nY, 1] ACTION aRotina[nY, 2] OPERATION aRotina[nY, 3] ACCESS 0
	Next nY

	//Define as actions do menu
	For nY := 1 To Len(aAcao)
		cAcao := Upper(AllTrim(aAcao[nY, 1]))

		If !Empty(cAcao)
			If nPos := AsCan(aMenu, {|x| Upper(x[1]) == cAcao})
				aMenu[nPos, 2] := aAcao[nY, 2]
			EndIf
		EndIf
	Next nY

Return aMenu

//---------------------------------
/*/{Protheus.doc}FxMenu
Define as chamadas do menu padrão

@author Sivaldo Oliveira
@since 10/09/2018
@version P12.1.17
/*/
//---------------------------------
Function FxMenu() As Array
	Local aMenu As Array

	//Inicializa variáveis
	aMenu := {}

	ADD OPTION aMenu TITLE STR0002 ACTION "" OPERATION 2 ACCESS 0			//"Visualizar"
	ADD OPTION aMenu TITLE STR0003 ACTION "" OPERATION 3 ACCESS 0			//"Incluir"
	ADD OPTION aMenu TITLE STR0004 ACTION "" OPERATION OP_COPIA ACCESS 0	//"Alterar"   
	ADD OPTION aMenu TITLE STR0005 ACTION "" OPERATION 5 ACCESS 0			//"Excluir"   
Return aMenu

//---------------------------------
/*/{Protheus.doc}FxStruct

@author Sivaldo Oliveira
@since 10/09/2018
@version P12.1.17
/*/
//---------------------------------
Function FxStruct(nTipo , cAlias , bAvalCamp , lViewUsad , aDelField , aDicField )
	Local oObj  As Object
	Local nX    As Numeric
	Local nTamDCta As Numeric
	Local nTamDCC As Numeric
	Local nTamDItem As Numeric
	Local nTamDClVl As Numeric
	Local nTamDSED As Numeric

	//Parâmetros da função.
	Default nTipo 	  := 1
	Default cAlias 	  := ""
	Default bAvalCamp := Nil
	Default lViewUsad := .T.
	Default aDelField := {}
	Default aDicField := {}

	oObj		:= NIL
	nTamDCta	:= 0
	nTamDCC		:= 0
	nTamDItem	:= 0
	nTamDClVl	:= 0
	nTamDSED    := 0 
	nX			:= 0


	cAlias := AllTrim(cAlias)

	If !Empty(cAlias)
		cAlias := Upper(cAlias)
		oObj := FWFormStruct(nTipo, cAlias, bAvalCamp, lViewUsad)

		If nTipo == 1
			Do Case
				Case cAlias == "FKK"

					nTamDCta	:= TamSx3("CT1_DESC01")[1]
					nTamDCC		:= TamSx3("CTT_DESC01")[1]
					nTamDItem	:= TamSx3("CTD_DESC01")[1]
					nTamDClVl	:= TamSx3("CTH_DESC01")[1]

					//Campos Virtuais
					//---------------------------------------------------------------------------------------------------------
					//Campos Virtuais - Folder DADOS GERAIS
					//---------------------------------------------------------------------------------------------------------
					oObj:AddField(			;
					STR0006					, ;	// [01] Titulo do campo	//'Descrição Código Retenção'
					STR0006					, ;	// [02] ToolTip do campo //'Descrição Código Retenção'
					"FKK_DSCRET"			, ;	// [03] Id do Field
					"C"						, ;	// [04] Tipo do campo
					60						, ;	// [05] Tamanho do campo
					0						, ;	// [06] Decimal do campo
					{ || .T. }				, ;	// [07] Code-block de validação do campo
					{ || .T. }				, ;	// [08] Code-block de validação When do campo
											, ;	// [09] Lista de valores permitido do campo
					.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "F024FKKINI('FKK_DSCRET')") ,,,;// [11] Inicializador Padrão do campo
					.T.)							//[14] Virtual

					//---------------------------------------------------------------------------------------------------------
					//Campos Virtuais - Folder REGRAS GERAIS
					//---------------------------------------------------------------------------------------------------------
					oObj:AddField(			;
					STR0007					, ;	// [01] Titulo do campo	//'Descrição Regra Vencimento'
					STR0007					, ;	// [02] ToolTip do campo //'Descrição Regra Vencimento'
					"FKK_DSCFKP"			, ;	// [03] Id do Field
					"C"						, ;	// [04] Tipo do campo
					40						, ;	// [05] Tamanho do campo
					0						, ;	// [06] Decimal do campo
					{ || .T. }				, ;	// [07] Code-block de validação do campo
					{ || .T. }				, ;	// [08] Code-block de validação When do campo
											, ;	// [09] Lista de valores permitido do campo
					.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "F024FKKINI('FKK_DSCFKP')") ,,,;// [11] Inicializador Padrão do campo
					.T.)							//[14] Virtual

					oObj:AddField(			;
					STR0008				, ;	// [01] Titulo do campo	//'Descrição Regra Títulos'
					STR0008					, ;	// [02] ToolTip do campo 	//'Descrição Regra Títulos'
					"FKK_DSCFKL"			, ;	// [03] Id do Field
					"C"						, ;	// [04] Tipo do campo
					40						, ;	// [05] Tamanho do campo
					0						, ;	// [06] Decimal do campo
					{ || .T. }				, ;	// [07] Code-block de validação do campo
					{ || .T. }				, ;	// [08] Code-block de validação When do campo
											, ;	// [09] Lista de valores permitido do campo
					.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "F024FKKINI('FKK_DSCFKL')") ,,,;// [11] Inicializador Padrão do campo
					.T.)							//[14] Virtual

					oObj:AddField(			;
					STR0009					, ;	// [01] Titulo do campo	//'Descrição Regra Cálculo'
					STR0009					, ;	// [02] ToolTip do campo 	//'Descrição Regra Cálculo'
					"FKK_DSCFKN"			, ;	// [03] Id do Field
					"C"						, ;	// [04] Tipo do campo
					40						, ;	// [05] Tamanho do campo
					0						, ;	// [06] Decimal do campo
					{ || .T. }				, ;	// [07] Code-block de validação do campo
					{ || .T. }				, ;	// [08] Code-block de validação When do campo
											, ;	// [09] Lista de valores permitido do campo
					.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "F024FKKINI('FKK_DSCFKN')") ,,,;// [11] Inicializador Padrão do campo
					.T.)							//[14] Virtual

					oObj:AddField(			;
					STR0010					, ;	// [01] Titulo do campo	//'Descrição Regra Retenção'
					STR0010					, ;	// [02] ToolTip do campo 	//'Descrição Regra Retenção'
					"FKK_DSCFKO"			, ;	// [03] Id do Field
					"C"						, ;	// [04] Tipo do campo
					40						, ;	// [05] Tamanho do campo
					0						, ;	// [06] Decimal do campo
					{ || .T. }				, ;	// [07] Code-block de validação do campo
					{ || .T. }				, ;	// [08] Code-block de validação When do campo
											, ;	// [09] Lista de valores permitido do campo
					.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "F024FKKINI('FKK_DSCFKO')") ,,,;// [11] Inicializador Padrão do campo
					.T.)							//[14] Virtual

					oObj:AddField(			;
					STR0011					, ;	// [01] Titulo do campo	//'Descrição Regra Valores Acessórios'
					STR0011					, ;	// [02] ToolTip do campo 	//'Descrição Regra Valores Acessórios'
					"FKK_DSCFKU"			, ;	// [03] Id do Field
					"C"						, ;	// [04] Tipo do campo
					40						, ;	// [05] Tamanho do campo
					0						, ;	// [06] Decimal do campo
					{ || .T. }				, ;	// [07] Code-block de validação do campo
					{ || .T. }				, ;	// [08] Code-block de validação When do campo
											, ;	// [09] Lista de valores permitido do campo
					.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "F024FKKINI('FKK_DSCFKU')") ,,,;// [11] Inicializador Padrão do campo
					.T.)							//[14] Virtual


					//---------------------------------------------------------------------------------------------------------
					//Campos Virtuais - Folder Contabil
					//---------------------------------------------------------------------------------------------------------
					oObj:AddField(			;
					STR0012					, ;	// [01] Titulo do campo	//"Descrição Conta"
					STR0012					, ;	// [02] ToolTip do campo 	//"Descrição Conta"
					"FKK_CTADSC"			, ;	// [03] Id do Field
					"C"						, ;	// [04] Tipo do campo
					nTamDCta				, ;	// [05] Tamanho do campo
					0						, ;	// [06] Decimal do campo
					{ || .T. }				, ;	// [07] Code-block de validação do campo
					{ || .T. }				, ;	// [08] Code-block de validação When do campo
											, ;	// [09] Lista de valores permitido do campo
					.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "F024FKKINI('FKK_CTADSC')") ,,,;// [11] Inicializador Padrão do campo
					.T.)							//[14] Virtual

					oObj:AddField(			;
					STR0013					, ;	// [01] Titulo do campo	//"Descrição Centro Custo"
					STR0013					, ;	// [02] ToolTip do campo 	//"Descrição Centro Custo"
					"FKK_CUSDSC"			, ;	// [03] Id do Field
					"C"						, ;	// [04] Tipo do campo
					nTamDCC					, ;	// [05] Tamanho do campo
					0						, ;	// [06] Decimal do campo
					{ || .T. }				, ;	// [07] Code-block de validação do campo
					{ || .T. }				, ;	// [08] Code-block de validação When do campo
											, ;	// [09] Lista de valores permitido do campo
					.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "F024FKKINI('FKK_CUSDSC')") ,,,;// [11] Inicializador Padrão do campo
					.T.)							//[14] Virtual

					oObj:AddField(			;
					STR0014					, ;	// [01] Titulo do campo		//"Descrição Item"
					STR0014					, ;	// [02] ToolTip do campo 	//"Descrição Item"
					"FKK_ITEDSC"			, ;	// [03] Id do Field
					"C"						, ;	// [04] Tipo do campo
					nTamDItem				, ;	// [05] Tamanho do campo
					0						, ;	// [06] Decimal do campo
					{ || .T. }				, ;	// [07] Code-block de validação do campo
					{ || .T. }				, ;	// [08] Code-block de validação When do campo
											, ;	// [09] Lista de valores permitido do campo
					.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "F024FKKINI('FKK_ITEDSC')") ,,,;// [11] Inicializador Padrão do campo
					.T.)							//[14] Virtual

					oObj:AddField(			;
					STR0015					, ;	// [01] Titulo do campo		//"Descrição Classe Valor"
					STR0015					, ;	// [02] ToolTip do campo 	//"Descrição Classe Valor"
					"FKK_CLVLDC"			, ;	// [03] Id do Field
					"C"						, ;	// [04] Tipo do campo
					nTamDClVl				, ;	// [05] Tamanho do campo
					0						, ;	// [06] Decimal do campo
					{ || .T. }				, ;	// [07] Code-block de validação do campo
					{ || .T. }				, ;	// [08] Code-block de validação When do campo
											, ;	// [09] Lista de valores permitido do campo
					.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "F024FKKINI('FKK_ITEDSC')") ,,,;// [11] Inicializador Padrão do campo
					.T.)							//[14] Virtual


					//Gatilhos
					oObj:AddTrigger("FKK_CODRET", "FKK_DSCRET"	, { || .T.}, { || F024FKKINI('FKK_DSCRET') })
					oObj:AddTrigger("FKK_CODFKP", "FKK_DSCFKP"	, { || .T.}, { || F024FKKINI('FKK_DSCFKP') })
					oObj:AddTrigger("FKK_CODFKL", "FKK_DSCFKL"	, { || .T.}, { || F024FKKINI('FKK_DSCFKL') })
					oObj:AddTrigger("FKK_CODFKN", "FKK_DSCFKN"	, { || .T.}, { || F024FKKINI('FKK_DSCFKN') })
					oObj:AddTrigger("FKK_CODFKO", "FKK_DSCFKO"	, { || .T.}, { || F024FKKINI('FKK_DSCFKO') })
					oObj:AddTrigger("FKK_CODFKU", "FKK_DSCFKU"	, { || .T.}, { || F024FKKINI('FKK_DSCFKU') })
					oObj:AddTrigger("FKK_CONTA" , "FKK_CTADSC"	, { || .T.}, { || F024FKKINI('FKK_CTADSC') })
					oObj:AddTrigger("FKK_CUSTO" , "FKK_CUSDSC"	, { || .T.}, { || F024FKKINI('FKK_CUSDSC') })
					oObj:AddTrigger("FKK_ITEM"  , "FKK_ITEDSC"	, { || .T.}, { || F024FKKINI('FKK_ITEDSC') })
					oObj:AddTrigger("FKK_CLVL"  , "FKK_CLVLDC"	, { || .T.}, { || F024FKKINI('FKK_CLVLDC') })

					//Obrigat
					oObj:SetProperty("FKK_CODFKL"		, MODEL_FIELD_OBRIGAT, .T.)		//Regra de Título Obrigatória


				Case cAlias == "FOO"
					oObj:AddField(			;
					STR0016					, ;	// [01] Titulo do campo		//"Classificação do tributo"
					STR0016					, ;	// [02] ToolTip do campo 	//
					"FOO_DESCR"				, ;	// [03] Id do Field
					"C"						, ;	// [04] Tipo do campo
					60						, ;	// [05] Tamanho do campo
					0						, ;	// [06] Decimal do campo
					{ || .T. }				, ;	// [07] Code-block de validação do campo
					{ || .T. }				, ;	// [08] Code-block de validação When do campo
											, ;	// [09] Lista de valores permitido do campo
					.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
					FWBuildFeature( STRUCT_FEATURE_INIPAD, "F024FKKINI('FOO_DESCR')" ) ,,,;// [11] Inicializador Padrão do campo
					.T.)							//[14] Virtual


				Case cAlias == "FKL"

					nTamDSED	:= TamSx3("ED_DESCRIC")[1]

					oObj:AddField(	STR0017,;			//[01] Titulo do campo		//"Descrição do Participante"
								  	STR0017,;			//[02] ToolTip do campo
								  	"FKL_DSCPAR",;		//[03] Id do Field
								  	"C",;				//[04] Tipo do campo
									40,;				//[05] Tamanho do campo
									0,;					//[06] Decimal do campo
									{||.T.},;			//[07] Code-block de validação do campo
									{||.T.},;			//[08] Code-block de validação When do campo
									Nil,;				//[09] Lista de valores permitido do campo
									.F.,;				//[10] Indica se o campo tem preenchimento obrigatório
									FWBuildFeature( STRUCT_FEATURE_INIPAD, "F24TITINI('FKL_DSCPAR')" ),; //[11] Inicializador Padrão do campo
									Nil,;
									Nil,;
									.T.)									//[14] Virtual

					oObj:AddField(	STR0018,;								//[01] Titulo do campo		//"Descrição da Natureza"
								  	STR0018,;								//[02] ToolTip do campo
								  	"FKL_DSCNAT",;							//[03] Id do Field
								  	"C",;									//[04] Tipo do campo
									nTamDSED,;								//[05] Tamanho do campo
									0,;										//[06] Decimal do campo
									{||.T.},;								//[07] Code-block de validação do campo
									{||.T.},;								//[08] Code-block de validação When do campo
									Nil,;									//[09] Lista de valores permitido do campo
									.F.,;									//[10] Indica se o campo tem preenchimento obrigatório
									FWBuildFeature( STRUCT_FEATURE_INIPAD, "F24TITINI('FKL_DSCNAT')" ),; //[11] Inicializador Padrão do campo
									Nil,;
									Nil,;
									.T.)
					//Gatilho
					oObj:AddTrigger("FKL_PARTIC", "FKL_DSCPAR", {||.T.}, {||F24TITINI("FKL_DSCPAR")})
					oObj:AddTrigger("FKL_LOJA",   "FKL_DSCPAR", {||.T.}, {||F24TITINI("FKL_DSCPAR")})
					oObj:AddTrigger("FKL_NATUR",  "FKL_DSCNAT", {||.T.}, {||F24TITINI("FKL_DSCNAT")})

					oObj:AddTrigger("FKL_RTPART", "FKL_PARTIC", {||.T.}, {||F24TITINI()})
					oObj:AddTrigger("FKL_RTPART", "FKL_LOJA",   {||.T.}, {||F24TITINI()})
					oObj:AddTrigger("FKL_RTPART", "FKL_DSCPAR", {||.T.}, {||F24TITINI()})

					oObj:SetProperty("FKL_RTPART" , MODEL_FIELD_OBRIGAT, .T.)
					oObj:SetProperty("FKL_NATUR" , MODEL_FIELD_OBRIGAT, .T.)

				Case cAlias == "FKN"
					oObj:AddField(	STR0019,;								//[01] Titulo do campo		//"Desc. Tab. Progressiva"
								  	STR0019,;								//[02] ToolTip do campo
								  	"FKN_DSCTAB",;							//[03] Id do Field
								  	"C",;									//[04] Tipo do campo
									40,;									//[05] Tamanho do campo
									0,;										//[06] Decimal do campo
									{||.T.},;								//[07] Code-block de validação do campo
									{||.T.},;								//[08] Code-block de validação When do campo
									Nil,;									//[09] Lista de valores permitido do campo
									.F.,;									//[10] Indica se o campo tem preenchimento obrigatório
									FWBuildFeature( STRUCT_FEATURE_INIPAD, "F24CALINI('FKN_DSCTAB')" ),; //[11] Inicializador Padrão do campo
									Nil,;
									Nil,;
									.T.)									//[14] Virtual

					oObj:AddField(	STR0020,;								//[01] Titulo do campo		//"Desc. Regra de Dedução"
								  	STR0020,;								//[02] ToolTip do campo
								  	"FKN_DSCREG",;							//[03] Id do Field
								  	"C",;									//[04] Tipo do campo
									40,;									//[05] Tamanho do campo
									0,;										//[06] Decimal do campo
									{||.T.},;								//[07] Code-block de validação do campo
									{||.T.},;								//[08] Code-block de validação When do campo
									Nil,;									//[09] Lista de valores permitido do campo
									.F.,;									//[10] Indica se o campo tem preenchimento obrigatório
									FWBuildFeature( STRUCT_FEATURE_INIPAD, "F24CALINI('FKN_DSCREG')" ),; //[11] Inicializador Padrão do campo
									Nil,;
									Nil,;
									.T.)									//[14] Virtual

					//Gatilho
					oObj:AddTrigger("FKN_CODFOS", "FKN_DSCTAB", {||.T.}, {||F24CALINI("FKN_DSCTAB")})
					oObj:AddTrigger("FKN_CODFOV", "FKN_DSCREG", {||.T.}, {||F24CALINI("FKN_DSCREG")})

				Case cAlias == "FKP"		//VENCIMENTOS
					oObj:AddTrigger("FKP_TIPVCT", "FKP_DIAVCT"	, { || .T.}, { || 0 })
					oObj:AddTrigger("FKP_TIPVCT", "FKP_QTPERI"	, { || .T.}, { || 0 })

				Case cAlias == "FOV"
					oObj:AddField(	STR0021,;								//[01] Titulo do campo		//"Descrição da Regra Financeira"
								  	STR0021,;								//[02] ToolTip do campo
								  	"FOV_DSCRFR",;							//[03] Id do Field
								  	"C",;									//[04] Tipo do campo
									40,;									//[05] Tamanho do campo
									0,;										//[06] Decimal do campo
									{||.T.},;								//[07] Code-block de validação do campo
									{||.T.},;								//[08] Code-block de validação When do campo
									Nil,;									//[09] Lista de valores permitido do campo
									.F.,;									//[10] Indica se o campo tem preenchimento obrigatório
									FWBuildFeature( STRUCT_FEATURE_INIPAD, "F24DEDVIR()" ) ,,,;// [11] Inicializador Padrão do campo
									Nil,;
									Nil,;
									.T.)
					//Gatilho
					oObj:AddTrigger("FOV_CODIGO", "FOV_DSCRFR", {||.T.}, {||F24DEDINI()})

				Case cAlias == "FOT"
					oObj:AddField(	STR0021,;								//[01] Titulo do campo		//"Descrição da Regra Financeira"
								  	STR0021,;								//[02] ToolTip do campo
								  	"FOT_DSCRFR",;							//[03] Id do Field
								  	"C",;									//[04] Tipo do campo
									40,;									//[05] Tamanho do campo
									0,;										//[06] Decimal do campo
									{||.T.},;								//[07] Code-block de validação do campo
									{||.T.},;								//[08] Code-block de validação When do campo
									Nil,;									//[09] Lista de valores permitido do campo
									.F.,;									//[10] Indica se o campo tem preenchimento obrigatório
									FWBuildFeature( STRUCT_FEATURE_INIPAD, "F24CUMVIR()" ) ,,,;// [11] Inicializador Padrão do campo
									Nil,;
									Nil,;
									.T.)
					//Gatilho
					oObj:AddTrigger("FOT_CODIGO", "FOT_DSCRFR", {||.T.}, {||F24CUMINI()})
				Case cAlias == "FKO"
					oObj:AddField(	STR0022,;								//[01] Titulo do campo		//"Desc Regra Cumulatividade"
								  	STR0022,;								//[02] ToolTip do campo
								  	"FKO_DSCRCUM",;							//[03] Id do Field
								  	"C",;									//[04] Tipo do campo
									40,;									//[05] Tamanho do campo
									0,;										//[06] Decimal do campo
									{||.T.},;								//[07] Code-block de validação do campo
									{||.T.},;								//[08] Code-block de validação When do campo
									Nil,;									//[09] Lista de valores permitido do campo
									.F.,;									//[10] Indica se o campo tem preenchimento obrigatório
									FWBuildFeature( STRUCT_FEATURE_INIPAD, '" "' ),; //[11] Inicializador Padrão do campo
									Nil,;
									Nil,;
									.T.)
					//Gatilho
					oObj:AddTrigger("FKO_CODFKT", "FKO_DSCRCUM", {||.T.}, {||F24RETINI()})
			EndCase
		Else
			Do Case
				Case cAlias == "FKK"

					oObj:AddField("FKK_DSCRET" , "11", STR0023, STR0023	, {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/)	//'Descrição Código Retenção'
					oObj:AddField("FKK_DSCFKP" , "40", STR0024, STR0024 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"2"/*cFolder*/)	//'Descrição Regra Vencimento'
					oObj:AddField("FKK_DSCFKL" , "41", STR0025, STR0025 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"2"/*cFolder*/)	//'Descrição Regra Títulos'
					oObj:AddField("FKK_DSCFKN" , "42", STR0026, STR0026 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"2"/*cFolder*/)	//'Descrição Regra Cálculo'
					oObj:AddField("FKK_DSCFKO" , "43", STR0027, STR0027 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"2"/*cFolder*/)	//'Descrição Regra Retenção'
					oObj:AddField("FKK_DSCFKU" , "44", STR0028, STR0028 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"2"/*cFolder*/)	//'Descrição Regra Valores Acessórios'
					oObj:AddField("FKK_CTADSC" , "53", STR0012, STR0012 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"3"/*cFolder*/)	//"Descrição Conta"
					oObj:AddField("FKK_CUSDSC" , "54", STR0013, STR0013 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"3"/*cFolder*/)	//"Descrição Centro Custo"
					oObj:AddField("FKK_ITEDSC" , "55", STR0014, STR0014 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"3"/*cFolder*/)	//"Descrição Item"
					oObj:AddField("FKK_CLVLDC" , "56", STR0015, STR0015 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"3"/*cFolder*/)	//"Descrição Classe Valor"

				Case cAlias == "FOO"

					oObj:AddField("FOO_DESCR" , "30", STR0029, STR0029 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/)	//"Detalhamento do tributo"

				Case cAlias == "FKL"
					oObj:AddField("FKL_DSCPAR" , "10", STR0017, STR0017 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/)	//"Descrição do Participante"
					oObj:AddField("FKL_DSCNAT" , "12", STR0018, STR0018 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/)	//"Descrição da Natureza"

				Case cAlias == "FKN"
					oObj:AddField("FKN_DSCTAB" , "30", STR0019, STR0019 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/)	//"Desc. Tab. Progressiva"
					oObj:AddField("FKN_DSCREG" , "30", STR0020, STR0020 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/)	//"Desc. Regra de Dedução"
				Case cAlias == "FOV"
					oObj:AddField("FOV_DSCRFR" , "04", STR0021, STR0021 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/)	//"Descrição da Regra Financeira"
				Case cAlias == "FOT"
					oObj:AddField("FOT_DSCRFR" , "05", STR0021, STR0021 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/)	//"Descrição da Regra Financeira"
				Case cAlias == "FKO"
					oObj:AddField("FKO_DSCRCUM", "15", STR0022, STR0022 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,/*cFolder*/)	//"Desc Regra Cumulatividade"
			EndCase
		EndIf

		//Remove campos da estrutura criada para a view
		For nX := 1 To Len(aDelField)
			oObj:RemoveField(aDelField[nX])
		Next nX

		//Adiciona campos da estrutura criada para a view
		For nX := 1 To Len(aDicField)
			oObj:AddField(aDicField[nX])
		Next nX
	EndIf

Return oObj

//---------------------------------
/*/{Protheus.doc}FxModelDe
@author Sivaldo Oliveira
@since 10/09/2018
@version P12.1.17
/*/
//---------------------------------
Function FxModelDe(cAlias As Character, cIdMod As Character, bPreMod As CodeBlock, bPosMod As CodeBlock, bGrvMod As CodeBlock, bFecMod As CodeBlock, cDesMod As Character,;
									cIdSubMod As Character, cPaiSubMod As Character, bPreSubMod As CodeBlock, bPosSubMod As CodeBlock, bLoaSubMod As CodeBlock)
	Local lRet   As Logical
	Local oModel As Object

	//Parâmetros da função
	Default cAlias  := ""
	Default cIdMod  := ""
	Default bPreMod := Nil
	Default bPosMod := Nil
	Default bGrvMod := Nil
	Default bFecMod := Nil
	Default cDesMod := ""

	//Parâmetro do submodelo AddFields
	Default cIdSubMod  := ""
	Default cPaiSubMod := Nil
	Default bPreSubMod := Nil
	Default bPosSubMod := Nil
	Default bLoaSubMod := Nil

	//Inicializa variáveis
	lRet   := .T.
	oModel := Nil

	If Empty(cAlias) .Or. Empty(cIdMod) .Or. Empty(cIdSubMod)
		lRet := .F.
	EndIf

	If lRet
		oObj := FxStruct(1, cAlias)
		oModel := MPFormModel():New(cIdMod, bPreMod, bPosMod, bGrvMod, bFecMod)
		oModel:AddFields(cIdSubMod, cPaiSubMod, oObj, bPreSubMod, bPosSubMod, bLoaSubMod)
		oModel:SetDescription(cDesMod)
	EndIf

Return oModel

//---------------------------------
/*/{Protheus.doc}FinAltVer
Inativa uma versão do cadastro x
@author Sivaldo Oliveira
@since 10/09/2018
@version P12.1.17
/*/
//---------------------------------
Function FinAltVer(cAlias As Character, nRecno)
	Local aArea As Array

	Default cAlias := ""
	Default nRecno := 0

	If !Empty(cAlias) .And. nRecno > 0
		aArea := (cAlias)->(GetArea())
		(cAlias)->(DbGoto(nRecno))
		RecLock(cAlias)
		(cAlias)->&(cAlias+"_ATIVO") := "2"
		(cAlias)->(MsUnlock())
		RestArea(aArea)
	EndIf
Return

//---------------------------------
/*/{Protheus.doc}FinVersao
Gera uma versão p/ o cadastro x
@author Sivaldo Oliveira
@since 10/09/2018
@version P12.1.17
/*/
//---------------------------------
Function FinVersao(cAlias As Character, oModel As Object, lAltera As Logical, nIndicTbl As Numeric) As Character
	Local cCod  As Character
	Local cRet  As Character
	Local cChave As Character

	Default cAlias    := ""
	Default oModel    := Nil
	Default lAltera   := .F.
	Default nIndicTbl := 1

	//Inicializa variáveis
	cCod   := ""
	cRet   := "0001"
	cChave := ""

	cAlias := AllTrim(cAlias)

	If !Empty(cAlias) .And. oModel != Nil
		If lAltera
			cCod := (cAlias)->&(cAlias+"_CODIGO")
			cRet := (cAlias)->&(cAlias+"_VERSAO")
			(cAlias)->(DbSetOrder(nIndicTbl))
			cChave := xFilial(cAlias)+cCod

			While .T.
				cRet := Soma1(cRet,4)
				If !(cAlias)->(MsSeek(cChave+cRet))
					oModel:LoadValue((cAlias+"_VERSAO"), cRet)
					Exit
				EndIf
			EndDo
		Else
			oModel:LoadValue((cAlias+"_VERSAO"), cRet)
			oModel:LoadValue((cAlias+"_CODIGO"), " ")
			oModel:LoadValue((cAlias+"_DESCR"),  " ")
		EndIf
	EndIf
Return cRet

//---------------------------------------
/*/{Protheus.doc} FinVldExc()
Valida permissão de Exclusão/Alteração

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function FinVldExc(cTblPai As Character, cTblFilha As Character, cIdRet As Character, cCodigo As Character) As Logical
	Local lRet   As Logical
	Local cQuery As Character
	Local oPrep  As Object

	Default cTblPai   := ""
	Default cTblFilha := ""
	Default cIdRet    := ""
	Default cCodigo   := ""

	//Inicializa variáveis
	lRet   := !Empty(cTblPai) .And. !Empty(cTblFilha) .And. (!Empty(cIdRet) .Or. !Empty(cCodigo))
	cQuery := ""

	If lRet
		cTblPai   := AllTrim(cTblPai)
		cTblFilha := AllTrim(cTblFilha)

		cQuery := "SELECT " + cTblPai + "_CODIGO FROM " + RetSqlName(cTblPai) + " WHERE "
		cQuery += cTblPai + "_ID" + cTblFilha + " = ? AND "
		If cTblFilha == "FKV"
			cQuery += cTblPai + "_CODFOV = ? AND "
		ElseIf cTblFilha == "FKS"
			cQuery += cTblPai + "_CODFOS = ? AND "
		Else
			cQuery += cTblPai + "_COD" + cTblFilha + " = ? AND "
		EndIf
		cQuery += cTblPai + "_FILIAL = ? AND "
		cQuery += "D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		oPrep  := FWPreparedStatement():New(cQuery)

		oPrep:SetString(1, cIdRet)
		oPrep:SetString(2, cCodigo)
		oPrep:SetString(3, xFilial(cTblPai))

		cQuery := oPrep:GetFixQuery()
		lRet   := Empty(MpSysExecScalar(cQuery, cTblPai + "_CODIGO"))
	EndIf
Return lRet


//---------------------------------------
/*/{Protheus.doc} FGravaFKQ()
Gravação da tabela FKQ

@author Mauricio Pequim Jr
@since	05/10/2018
@version 12
/*/
//---------------------------------------
Function FGravaFKQ(aImpos As Array)
	Local nX As Numeric

	DEFAULT aImpos := {}

	nX := 0

	/*Estrutura da aImpos
	[1]  = Codigo do tipo de imposto (FKK_CODIGO) ***
	[2]  = Tipo do Imposto (FOO/F2E)
	[3]  = Id Retenção F2B
	[4]  = Regime (1 = Competência ou 2 = Baixa) (FKK)
	[5]  = Base de retenção do imposto
	[6]  = Valor a reter do imposto
	[7]  = Chave da FK7
	[8]  = Código URF
	[9]  = Percentual URF
	*/

	For nX := 1 to Len(aImpos)
		RecLock("FKQ", .T.)
		FKQ_FILIAL	:= xFilial("FKQ")
		FKQ_CODFKK	:= aImpos[nX,1]
		FKQ_CODF2E	:= aImpos[nX,2]
		FKQ_IDF2B	:= aImpos[nX,3]
		FKQ_FATGER	:= aImpos[nX,4]
		FKQ_VLBASE	:= aImpos[nX,5]
		FKQ_VLIMPO	:= aImpos[nX,6]
		FKQ_IDFK7	:= aImpos[nX,7]
		FKQ_CODURF	:= aImpos[nX,8]
		FKQ_PCTURF	:= aImpos[nX,9]
		MsUnLock()
	Next

Return Nil



//---------------------------------------
/*/{Protheus.doc} FDelFKQ()
Exclusão da FKQ

@author Mauricio Pequim Jr
@since	05/10/2018
@version 12
/*/
//---------------------------------------
Function FDelFKQ(cChaveFK7 As Character)

	Local aArea As Array

	DEFAULT cChaveFK7 := ""

	aArea := GetArea()

	DbSelectArea("FKQ")
	DBSetOrder(1)

	cChaveFKQ := xFilial("FKQ")+ cChaveFK7

	If MsSeek( cChaveFKQ )

		While FKQ->(!EOF()) .And. FKQ->(FKQ_FILIAL+FKQ_IDFK7) == cChaveFKQ
			RecLock("FKQ")
			FKQ->(dbDelete())
			FKQ->(MsUnLock())
			FKQ->(DbSkip())
		EndDo

	Endif

	RestArea(aArea)

Return



//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FinGrvImp
Gravação dos titulos de impostos - Emissão

@aparam	aRecolher - Array contendo as regras financeiras impostos a gravar
					aImpos[nX,1] = Código da Regra Financeira
					aImpos[nX,2] = Valor do título a ser gerado
					aImpos[nX,3] = Número do título a ser gerado
					aImpos[nX,4] = Recebe, como retorno, a chave FK7 do título gerado

@aparam	cOrigem - Origem do Movimento (FINA040, FINA050, FINA070, FINA080 etc.)
@aparam	dDataRef - Data referência para determinar a vigencia
@aparam	lAtuSalDup - Indica se haverá atualização de saldos de duplicatas para Cliente/Fornecedor
@aparam	lAtuSalNat - Indica se haverá atualização de saldos de naturezas


@Return	aRecolher - retorna array com a posição 4 de cada linha com a chave FK7 do titulo gerado

@author Mauricio Pequim Jr
@since  05/10/2018
@version 12.1.17
/*/
//------------------------------------------------------------------------------------------------
Function FGrvImpFi(aRecolher, cOrigem, dDataRef,lAtuSalDup,lAtuSalNat)

Local aArea	As Array
Local aAreaSE1 As Array
Local aAreaSE2 As Array
Local aAreaSA1 As Array
Local aAreaSA2 As Array
Local nRecFKK As Numeric
Local nTamaRec As Numeric
Local cCart As Character
Local cCartMov As Character
Local cTabPart As Character
Local cAliasImp As Character
Local cCodRet As Character
Local cPrefixo As Character
Local cNum As Character
Local cTipoImp As Character
Local cCodPart As Character
Local cLojPart As Character
Local cParcela As Character
Local cNomReduz As Character
Local dEmissao As Date
Local dEmis1 As Date
Local dVencImp As Date
Local cNatImp As Character
Local cTipoRet As Character
Local cLA As Character
Local cRegraFin As Character
Local cRegraVct As Character
Local cTipoMov As Character
Local nX As Numeric
Local cIdFKK As Character
Local cHistor As Character

DEFAULT aRecolher := {}
DEFAULT dDataRef := dDataBase
DEFAULT cOrigem := ""
DEFAULT lAtuSalDup := .T.
DEFAULT lAtuSalNat := .T.


aArea		:= GetArea()
aAreaSE1	:= SE1->( GetArea())
aAreaSE2	:= SE2->( GetArea())
aAreaSA1	:= SA1->( GetArea())
aAreaSA2	:= SA2->( GetArea())
nRecFKK		:= 0
cOrigem 	:= Upper(Alltrim(cOrigem))
nTamaRec	:= Len(aRecolher)
cCart 		:= ''
cCartMov	:= ''
cTabPart	:= ''
cAliasImp	:= ''
cCodRet		:= ''
cPrefixo	:= ''
cNum		:= ''
cTipoImp 	:= ''
cCodPart	:= ''
cLojPart	:= ''
cParcela	:= ''
cNomReduz	:= ''
dEmissao 	:= CTOD("//")
dEmis1		:= CTOD("//")
dVencImp	:= CTOD("//")
cNatImp		:= ''
cTipoRet	:= ''
cLA			:= ''
cRegraFin   := ''
cTipoMov	:= ""
nX			:= 0
cIdFKK		:= ''
lRet		:= .T.
cHistor		:= ""

//Efetua o processo apenas se o array de impostos a serem gravados possuir dados
If nTamaRec > 0

	For nX := 1 to nTamaRec
		//Codigo da regra financeira - FKK_CODIGO
		cRegraFin := aRecolher[nX,1]
		If Len(aRecolher[nX]) > 5
			cHistor	:= aRecolher[nX,6]
		Endif

		If !Empty(cRegraFin) .and. aRecolher[nX,2] > 0
			//Posiciona na regra Financeira Vigente
			nRecFKK := FinFKKVig(cRegraFin, dDataRef)
			lRet := .T.

			If nRecFKK > 0
				//Regra de Título
				cRegraTit := FKK->FKK_CODFKL
				FKL->(dbSetOrder(2))		//FKL_FILIAL+FKL_CODIGO
				If !FKL->(MsSeek(xfilial('FKL') + cRegraTit ) )
					lRet := .F.
				Endif

				//Regra de Vencimento
				If lRet
					cRegraVct := FKK->FKK_CODFKP
					FKP->(dbSetOrder(2))		//FKP_FILIAL+FKP_CODIGO
					If !FKP->(MsSeek(xfilial('FKP') + cRegraVct ) )
						lRet := .F.
					Endif
				Endif

				If lRet

					cCart 		:= FKK->FKK_CART
					cCartMov	:= FKL->FKL_CARTMV		//Se o titulo de imposto será gerado na SE1 oou SE2
					cTabPart	:= If(cCart == '1', 'SA2', 'SA1')
					cAliasImp	:= If(cCartMov == '1', 'SE2', 'SE1')
					cCodRet		:= FKK->FKK_CODRET		//Código de retenção do imposto
					cPrefixo	:= FKL->FKL_PREFIX		//Prefiso do titulo de imposto
					cNum		:= aRecolher[nX,3]		//Numero do titulo de imposto
					cTipoImp 	:= FKL->FKL_TIPO		//Tipo do título de imposto
					cCodPart	:= FKL->FKL_PARTIC		//Participante do titulo de imposto
					cLojPart	:= FKL->FKL_LOJA		//Loja  do titulo de imposto
					cParcela	:= FinPcImp(cAliasImp,cPrefixo,cNum,cTipoImp,cCodPart,cLojPart,cFilAnt)
					cNomReduz	:= Posicione(cTabPart,1,xfilial(cTabPart) + cCodPart + cLojPart ,If(cCart == '1','A2_NREDUZ','A1_NREDUZ'))
					dEmissao 	:= dDataBase
					dEmis1		:= dDataBase
					dVencImp	:= FMRCalcVc(dDataRef,FKP->FKP_DIAVCT , FKP->FKP_TIPVCT, FKP->FKP_DATVCT, FKP->FKP_PRDVCT,FKP->FKP_QTPERI,FKP->FKP_DTVLVC)
					cNatImp		:= FKL->FKL_NATUR		//Natureza do imposto
					cTipoRet	:= FOO->FOO_CODIGO		//Tipo do imposto - FOO
					cLA			:= "S"

					//Gravação do titulo de recolhimento
					DbSelectArea(cAliasImp)
					DbSetOrder(1)

					If !( (cAliasImp)->(Dbseek(xFilial(cAliasImp) + cPrefixo + cNum + cParcela + cTipoImp + cCodPart + cLojPart ) ) )
						If cAliasImp == 'SE1'

							RecLock("SE1",.T.)
							SE1->E1_FILIAL	:= xFilial("SE1")
							SE1->E1_PREFIXO := cPrefixo
							SE1->E1_NUM		:= cNum
							SE1->E1_PARCELA	:= cParcela
							SE1->E1_TIPO	:= cTipoImp
							SE1->E1_CLIENTE := cCodPart
							SE1->E1_LOJA	:= cLojPart
							SE1->E1_EMISSAO	:= dDataBase
							SE1->E1_EMIS1	:= dDataBase
							SE1->E1_VENCTO	:= dVencImp
							SE1->E1_VENCORI	:= dVencImp
							SE1->E1_VENCREA	:= dVencImp
							SE1->E1_VALOR	:= aRecolher[nX,2]
							SE1->E1_VLCRUZ	:= aRecolher[nX,2]
							SE1->E1_SALDO	:= aRecolher[nX,2]
							SE1->E1_SITUACA := "0"
							SE1->E1_NOMCLI	:= cNomReduz
							SE1->E1_MOEDA	:= 1
							SE1->E1_OCORREN	:= "04"
							SE1->E1_ORIGEM	:= cOrigem
							SE1->E1_NATUREZ	:= cNatImp
							SE1->E1_LA		:= cLA
							SE1->E1_FILORIG	:= cFilAnt
							SE1->E1_STATUS  := "A"
							SE1->E1_HIST	:= cHistor

							SE1->(MsUnlock())
							FKCOMMIT()

							If lAtuSalNat
								AtuSldNat(SE1->E1_NATUREZ, SE1->E1_VENCREA, SE1->E1_MOEDA, "2", "R", SE1->E1_VALOR, SE1->E1_VLCRUZ, "+")
							Endif

							If lAtuSalDup
								AtuSalDup("-",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,SE1->E1_TXMOEDA,SE1->E1_EMISSAO,,,.T.)
							Endif

							//Dados da tabela auxiliar com o código do título a receber
							cChaveTit := xFilial("SE1") + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM     + "|" + SE1->E1_PARCELA + "|" + ;
																SE1->E1_TIPO    + "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
							cChaveFK7 := FINGRVFK7("SE1", cChaveTit)
							aRecolher[nX,4]	:= 	cChaveFK7

						Else

							RecLock("SE2",.T.)
							SE2->E2_FILIAL  := xFilial("SE2")
							SE2->E2_PREFIXO := cPrefixo
							SE2->E2_NUM 	:= cNum
							SE2->E2_PARCELA := cParcela
							SE2->E2_TIPO	:= cTipoImp
							SE2->E2_FORNECE := cCodPart
							SE2->E2_LOJA	:= cLojPart
							SE2->E2_NOMFOR  := cNomReduz
							SE2->E2_VALOR	:= aRecolher[nX,2]
							SE2->E2_SALDO	:= aRecolher[nX,2]
							SE2->E2_VLCRUZ  := aRecolher[nX,2]
							SE2->E2_EMISSAO := dDataBase
							SE2->E2_EMIS1	:= dDataBase
							SE2->E2_VENCTO  := dVencImp
							SE2->E2_VENCORI := dVencImp
							SE2->E2_VENCREA := dVencImp
							SE2->E2_MOEDA	:= 1
							SE2->E2_ORIGEM  := cOrigem
							SE2->E2_NATUREZ := cNatImp
							SE2->E2_LA      := cLA
							SE2->E2_FILORIG := cFilAnt
							SE2->E2_HIST	:= cHistor

							SE2->(MsUnlock())
							FKCOMMIT()

							//Dados da tabela auxiliar com o código do título a pagar
							cChaveTit := xFilial("SE2") + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM     + "|" + SE2->E2_PARCELA + "|" + ;
																SE2->E2_TIPO    + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
							cChaveFK7 := FINGRVFK7("SE2", cChaveTit)
							aRecolher[nX,4]	:= 	cChaveFK7

							If lAtuSalNat
								AtuSldNat(SE2->E2_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, "2", "P", SE2->E2_VALOR, SE2->E2_VLCRUZ, "+")
							Endif

						EndIF
					Endif
				Else
					Loop
				EndIf
			Endif
		Else
			Loop
		Endif
	Next

Endif

//Destroi o objeto criado pela FinFKKVig()
FinFKKDes()

RestArea( aAreaSA1 )
RestArea( aAreaSA2 )
RestArea( aAreaSE1 )
RestArea( aAreaSE2 )
RestArea( aArea )

Return aRecolher


//-------------------------------------------------------------------
/*/{Protheus.doc} FinFKKVig()
Verifica qual regra financeira está ativa para uma deteminada data


@author  Mauricio Pequim Jr
@since 05/10/2018
@version 12
/*/
//-------------------------------------------------------------------
Function FinFKKVig(cRegraFin As Character, dDataRef As Date )
	Local aArea As Array
	Local cQry As Character
	Local nRecFKKVig As Numeric

	//Parâmetros da função
	DEFAULT cRegraFin	:= ""
	DEFAULT dDataRef	:= CTOD("//")

	//Inicializa variáveis.
	aArea      := GetArea()
	cQry       := ""
	nRecFKKVig := 0

	If __oPrepFKK == NIL
		cQry := "SELECT FKK.R_E_C_N_O_ FKKRECNO FROM " + RetSqlName('FKK') +" FKK "

		//Filtro da consulta
		cQry += "WHERE FKK.FKK_ATIVO = '1' "
		cQry += "AND FKK.FKK_FILIAL = ? "
		cQry += "AND FKK.FKK_CODIGO = ? "
		cQry += "AND FKK.FKK_VIGINI <= ? "
		cQry += "AND FKK.FKK_VIGFIM >= ? "
		cQry += "AND FKK.D_E_L_E_T_ = ' ' "

		cQry := ChangeQuery(cQry)
		__oPrepFKK := FWPreparedStatement():New(cQry)
	Endif

	__oPrepFKK:SetString(1, xFilial("FKK"))
	__oPrepFKK:SetString(2, cRegraFin)
	__oPrepFKK:SetString(3, DTOS(dDataRef))
	__oPrepFKK:SetString(4, DTOS(dDataRef))

	cQry := __oPrepFKK:GetFixQuery()
	nRecFKKVig := MpSysExecScalar(cQry,"FKKRECNO") //left incluido para corrigir problema em banco postgres - nao remover

	If nRecFKKVig > 0
		FKK->(dbGoto(nRecFKKVig))
	Endif

	RestArea(aArea)

Return nRecFKKVig


//-------------------------------------------------------------------
/*/{Protheus.doc} FinFKKDes()
Destroy o objeto da query criada pela FinFKKAtv

@author  Mauricio Pequim Jr
@since 05/10/2018
@version 12
/*/
//-------------------------------------------------------------------
Function FinFKKDes()

If __oPrepFKK != NIL
	__oPrepFKK:Destroy()
	__oPrepFKK := NIL
Endif

Return

//---------------------------------------
/*/{Protheus.doc} FinImpFis()
Retorna os valores de retenção cálculado pelo fiscal
para serem retidos no financeiro

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function FinImpFis(cChaveTit As Character, cFilOrig As Character, cAlias As Character, lRetBaixa As Logical, nBase As Numeric, dDtRef As Date, cCliFor As Character, cLoja As Character) As Array
	Local lRet     As Logical
	Local cQry     As Character
	Local cTblTmp  As Character
	Local cChavFK7 As Character
	Local aImpFis  As Array
	Local nBasRet  As Numeric
	Local nVlrImp  As Numeric
	Local nRecFKK  As Numeric
	Local nBaseOld As Numeric
	Local aImpRet  As Array
	Local aFatGer  As Array
	
	//Parâmetros da função
	Default cChaveTit := ""
	Default cFilOrig  := cFilAnt
	Default cAlias    := ""
	Default lRetBaixa := .T.
	Default nBase     := 0
	Default dDtRef    := dDataBase
	
	//Inicializa variáveis
	lRet     := .T.
	cQry     := ""
	cTblTmp  := ""
	cChavFK7 := FINBuscaFK7(cChaveTit, cAlias)
	aImpFis  := {}
	nBasRet  := 0
	nVlrImp  := 0	
	nRecFKK  := 0
	aImpRet  := {.F., 0, 0}
	aFatGer  := {"1", "2"}
	nBaseOld := nBase

	If Empty(cChavFK7) .Or. Empty(cAlias)
		lRet := .F.
	EndIf
	
	If lRet
		If lRetBaixa 
			aFatGer := {"2"}
		EndIf
		
		If __oImpFis == Nil
			cQry := "SELECT FKQ.FKQ_FILIAL,FKQ.FKQ_CODFKK,FKQ.FKQ_IDF2B,FKQ.FKQ_IDFK7,FKQ.FKQ_CODF2E,FKQ.FKQ_VLBASE,FKQ.FKQ_VLIMPO,FKQ.FKQ_FATGER,F2B.F2B_REGRA, "
			cQry += "FKQ.FKQ_CODURF, FKQ.FKQ_PCTURF"
			cQry += "FROM " + RetSqlName("FKQ") + " FKQ "
			cQry += "INNER JOIN " + RetSqlName("F2B") + " F2B "
			cQry += "ON (FKQ.FKQ_IDF2B = F2B.F2B_ID) "
			cQry += "WHERE FKQ.FKQ_FILIAL = ? "
			cQry += "AND F2B.F2B_FILIAL = ? "
			cQry += "AND FKQ.FKQ_IDFK7 = ? "
			cQry += "AND FKQ.FKQ_FATGER IN (?) "
			cQry += "AND FKQ.D_E_L_E_T_ = ' ' "
			cQry += "AND F2B.D_E_L_E_T_ = ' ' "
			cQry := ChangeQuery(cQry)
			__oImpFis := FWPreparedStatement():New(cQry)
		EndIf

		__oImpFis:SetString(1, xFilial("FKQ",cFilOrig))
		__oImpFis:SetString(2, xFilial("F2B",cFilOrig))
		__oImpFis:SetString(3, cChavFK7)
		__oImpFis:SetIn(4,aFatGer)
		cQry    := __oImpFis:GetFixQuery()
		cTblTmp := MpSysOpenQuery(cQry)
		(cTblTmp)->(DbGotop())

		While (cTblTmp)->(!Eof())
			nBasRet := (cTblTmp)->FKQ_VLBASE
			nVlrImp := (cTblTmp)->FKQ_VLIMPO
			nBase	:= nBaseOld
			
			If lRetBaixa .And. (cTblTmp)->FKQ_FATGER == "2"
				nBase := If(nBase > (cTblTmp)->FKQ_VLBASE, (cTblTmp)->FKQ_VLBASE, nBase)
				
				If nBase != (cTblTmp)->FKQ_VLBASE
					aImpRet := {.F., 0, 0}
					nRecFKK := FinFKKVig( (cTblTmp)->FKQ_CODFKK, dDtRef)
					FKK->(DbGoto(nRecFKK))
					
					FinRetFis(FKK->FKK_CART, (cTblTmp)->FKQ_CODF2E, (cTblTmp)->FKQ_CODFKK, cFilOrig, cCliFor, cLoja, FKK->FKK_IDFKO, aImpRet)
					
					If (!aImpRet[1] .Or. aImpRet[2] >= nVlrImp)  
						(cTblTmp)->(DbSkip())
						Loop	
					EndIf
					
					nBasRet := nBase
					nVlrImp := Round(nBasRet * (nVlrImp / (cTblTmp)->FKQ_VLBASE), 2)
					
					//Tratamento de base reduzida e Dif. do vlr provis vs a reter
					If (nVlrImp + aImpRet[2]) > (cTblTmp)->FKQ_VLIMPO 
						nVlrImp := (cTblTmp)->FKQ_VLIMPO - aImpRet[2]
						nBasRet := (cTblTmp)->FKQ_VLBASE - aImpRet[3] 	
					EndIf 
				EndIf
			EndIf
			
			Aadd(aImpFis, { (cTblTmp)->FKQ_CODFKK, nBasRet, nVlrImp, (cTblTmp)->FKQ_FILIAL, (cTblTmp)->FKQ_IDF2B, (cTblTmp)->FKQ_FATGER,;
							(cTblTmp)->FKQ_IDFK7, (cTblTmp)->FKQ_CODF2E, (cTblTmp)->F2B_REGRA,(cTblTmp)->FKQ_CODURF,(cTblTmp)->FKQ_PCTURF } )
			(cTblTmp)->(DbSkip())
		EndDo

		(cTblTmp)->(DbCloseArea())
		cTblTmp := ""
	EndIf
Return aImpFis

//---------------------------------------
/*/{Protheus.doc} FinPARCFKO()
Função que verifica se a retenção será gerada
integralmente na primeira parcela/baixa ou proporcionalizada

@version 12
/*/
//---------------------------------------
Function FinParcFKK(cCodFKK)
	Local lRet   As Logical
	Local nRecno As Numeric

	//Inicializa variáveis
	lRet   := .F.
   	nRecno := 0

    If !Empty(cCodFKK)
    	nRecno := FinFKKVig(cCodFKK, dDataBase)
    	FKK->(DbGoto(nRecno))
    	lRet :=  FKK->FKK_PARCTO == "1" //Indica que está configurado para reter na primeira parcela.
    EndIf

Return lRet


//---------------------------------------
/*/{Protheus.doc} FinValAces
Valores acessórios que podem ser considerados
na base de cálculo dos impostos

@author  Sivaldo Oliveira
@since 19/11/2018
@version 12
/*/
//---------------------------------------
Static Function FinValAces(cTbl As Character, nVlrBx As Numeric, dDtaBaixa As Date)
	Local lRet      As Logical
	Local nDiaAtras As Numeric
	Local dDtaUltBx As Date
	Local dDtaVenc  As Date
	Local aValAces  As Array 
	Local cCampo    As Character
	
	//Parâmetros da função
	Default cTbl      := ""
	Default nVlrBx    := 0
	Default dDtaBaixa := dDataBase  
	
	cTbl := AllTrim(cTbl)
	//Inicializa variáveis
	lRet      := !Empty(cTbl) .And. cTbl $ "SE1|SE2"
	nDiaAtras := 0
	dDtaUltBx := CTOD("  /  /    ")
	dDtaVenc  := dDtaUltBx
	aValAces  := {}
	
	If lRet
		If Type("nJuros") != "N"
			nJuros := 0
		EndIf
		
		If Type("nMulta") != "N"
			nMulta := 0
		EndIf
		
		If Type("nDescont") != "N"
			nDescont := 0
		EndIf		
		
		cCampo := ReadVar()
		
		If cTbl == "SE1"
			dDtaUltBx := SE1->E1_BAIXA
			
			If SE1->(E1_VALJUR+E1_PORCJUR) > 0
				nVlrBx   := If(Empty(nVlrBx), SE1->E1_SALDO, nVlrBx)
				dDtaVenc := DataValida(SE1->E1_VENCTO, .T.)
			EndIf
		Else
			dDtaUltBx := SE2->E2_BAIXA
			
			If SE2->(E2_VALJUR+E2_PORCJUR) > 0
				nVlrBx    := If(Empty(nVlrBx), SE2->E2_SALDO, nVlrBx)
				dDtaVenc  := DataValida(SE2->E2_VENCTO, .T.)
			EndIf
		EndIf
		
		If !Empty(dDtaVenc) .And. !Empty(dDtaUltBx)
			If dDtaVenc < dDtaUltBx
				dDtaVenc := dDtaUltBx
			EndIf 
		EndIf
		
		nDiaAtras := If(Empty(dDtaVenc), nDiaAtras, (dDtaBaixa - dDtaVenc))
		
		//Cálcula juros/taxa de permanência
		If cTbl == "SE1"
			If nDiaAtras > 0 .And. cCampo != "NJUROS"
				nJuros := (SE1->E1_VALJUR * nDiaAtras) + (nVlrBx * ((SE1->E1_PORCJUR * nDiaAtras) / 100))
			EndIf
			
			//Acréscimo
			If SE1->E1_SDACRES > 0
				Aadd(aValAces, {"ACRESC", SE1->E1_SDACRES})
			EndIf
			
			//Decréscimo
			If SE1->E1_SDDECRE > 0
				Aadd(aValAces, {"DECRES", SE1->E1_SDDECRE})
			EndIf
		Else
			If nDiaAtras > 0 .And. cCampo != "NJUROS" 
				nJuros := (SE2->E2_VALJUR * nDiaAtras) + (nVlrBx * ((SE2->E2_PORCJUR * nDiaAtras) / 100))
			EndIf
			
			//Acréscimo
			If SE2->E2_SDACRES > 0
				Aadd(aValAces, {"ACRESC", SE2->E2_SDACRES})
			EndIf
			
			//Decréscimo
			If SE2->E2_SDDECRE > 0
				Aadd(aValAces, {"DECRES", SE2->E2_SDDECRE})
			EndIf
		EndIf
		
		//Juros
		If nJuros > 0
			Aadd(aValAces, {"JUROS", nJuros})
		EndIf 
		
		//Multa
		If nMulta > 0
			Aadd(aValAces, {"MULTA", nMulta})
		EndIf
		
		//Desconto
		If nDescont > 0
			Aadd(aValAces, {"DESCON", nDescont})
		EndIf	
	EndIf
Return aValAces

//----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FxTotRet()
Retorna o total de retenção efetuada para um tributo num determinado Periodo

@aparam	cRegraFin - Código da Regra Financeira Tributo (FKK) (Obrigatório)
@aparam	cTributo - Código do Tributo (FOO)  (Obrigatório)
@aparam	cCart - Carteira (P - Pagar/ R - Receber  (Obrigatório)
@aparam	cFornece - Código do Tributo (FOO)  (Obrigatório)
@aparam	cLoja - Carteira (P - Pagar/ R - Receber  (Obrigatório)

@aparam	cPerCum - Tipo de periodo de cumulatividade (FKO_CUMULA)
					1 - Diário
					2 - Semanal
					3 - Decendial
					4 - Mensal

@aparam	dDtRef - Data referência para verificação do periodo das retenções (obrigatório se enviado cPerCum)

@aparam	dPerIni - Data inicial do periodo das retenções 
@aparam	dPerFim - Data final do periodo das retenções

@Return	nRetencao - valor total de retenção no periodo

@author  Mauricio Pequim Jr
@since 18/10/2018
@version 12
/*/
//----------------------------------------------------------------------------------------------------
Function FxTotRet(cRegraFin As Character, cTributo As Character, cCart As Character, cCliFor As Character,  cLoja As Character, ;
					cPerCum, dDtRef, dPerIni, dPerFim) As Numeric

	Local cQry As Character
	Local cCartInv As Character
	Local nRetencao As Numeric

	DEFAULT cRegraFin := ""
	DEFAULT cTributo := ""
	DEFAULT cCart := ""
	DEFAULT cCliFor := ""
	DEFAULT cLoja := ""
	DEFAULT dPerIni := CTOD("//")
	DEFAULT dPerFim := CTOD("//")

	cQry := ""
	cCartInv := If(cCart == 'P', 'R', 'P')
	nRetencao := 0

	If !Empty(cCart) .and. !Empty(cTributo)

		If !Empty(cPerCum)
			aDataCum	:= FDatasCum(cPerCum, dDtRef)
			dPerIni		:= aDataCum[1]
			dPerFim		:= aDataCum[2]
		Endif

		If __oPreparA == NIL
			cQry := " SELECT "

			// Campos FK4
			cQry += " SUM(FK4.FK4_VALOR) VLRRET "
			// Tabela
			cQry += " FROM " + RetSqlName("FK4") + " FK4 "
			cQry += " JOIN " + RetSqlName("FKA") + " FKA ON FK4.FK4_IDORIG = FKA.FKA_IDORIG "
			// Clausula
			cQry += " WHERE "
			cQry += 	" FK4.FK4_FILIAL = '" + xFilial("FK4") + "' "
			cQry += " AND FK4.FK4_IMPOS = ? "	// + cTributo + "' "
			cQry += " AND FK4.FK4_DATA >= ? "
			cQry += " AND FK4.FK4_DATA <= ? "
			cQry += " AND FK4.FK4_RECPAG = ? "
			cQry += " AND FK4.FK4_STATUS = '1' "
			cQry += " AND FK4.D_E_L_E_T_ = ' ' "

			// Controle de Estornados
			cQry += " AND FKA.FKA_IDPROC NOT IN ( SELECT FKA.FKA_IDPROC "
			cQry += " FROM " + RetSqlName("FK4") + " FK4 "
			cQry += " JOIN " + RetSqlName("FKA") + " FKA ON FK4.FK4_IDORIG = FKA.FKA_IDORIG "
			// Clausula
			cQry += " WHERE "
			cQry += 	" FK4.FK4_FILIAL = '" + xFilial("FK4") + "' "
			cQry += " AND FK4.FK4_IMPOS = ? "
			cQry += " AND FK4.FK4_DATA >= ? "
			cQry += " AND FK4.FK4_DATA <= ? "
			cQry += " AND FK4.FK4_RECPAG = ? "
			cQry += " AND FK4.FK4_STATUS = '2' "
			cQry += " AND FK4.D_E_L_E_T_ = ' ' "

			cQry := ChangeQuery( cQry )

			__oPreparA:=FWPreparedStatement():New(cQry)
		Endif

		__oPreparA:SetString(1,cTributo)
		__oPreparA:SetDate(2,dPerIni)
		__oPreparA:SetDate(3,dPerFim)
		__oPreparA:SetString(4,cCart)
		__oPreparA:SetString(5,cTributo)
		__oPreparA:SetDate(6,dPerIni)
		__oPreparA:SetDate(7,dPerFim)
		__oPreparA:SetString(8,cCartInv)

		cQry := __oPreparA:GetFixQuery()

		nRetencao := ABS(MpSysExecScalar(cQry,"VLRRET"))

	Endif

Return nRetencao



//-------------------------------------------------------------------
/*/{Protheus.doc} FDatasCum()
Retorna o intervalo de datas a ser considerado para o calculo do valor
já retido anteriomente

@aparam	cCart - Carteira (P - Pagar/ R - Receber
@aparam	cIdTit - Id de busca do título.
@Return	nVlrRet - valor total de retenção no periodo

@author  Mauricio Pequim Jr
@since 04/12/2018
@version 12
/*/
//-------------------------------------------------------------------

Function FDatasCum(cPerCum as Character,  dDtRef As Date) As Array

	Local aDatas	:= {}
	Local nDia		:= 0
	Local nTemp		:= 0
	Local dFirstDay	:= CTOD("//")
	Local dLastDay	:= CTOD("//")

	DEFAULT cPerCum := ""
	DEFAULT dDtRef	:= CTOD("//")

	If !Empty(cPerCum)
		If cPerCum == '1' //Diário
			AAdd(aDatas,{dDtRef,dDtRef})

		ElseIf cPerCum == '2' //Semanal
			nDia := Dow(dDtRef)			//Acho o dia da semana
			nTemp :=  (7 - nDiaSem)			//Acho quantos dias faltam para terminar a semana
			dLastDay := dDtRef + nTemp		//Ultimo dia da semana
			dFirstDay := dLastDay - 7		//Primeiro dia da semana
			AAdd(aDatas,{dFirstDay,dLastDay})

		ElseIf cPerCum == '3' //Decendial
			nDia := Day(dDtRef)
			nMes := Month(dDtRef)
			nAno := Year(dDtRef)

			If nDia <= 10		//Primeiro Decênio
				dFirstDay := FirstDay(dDtRef)	
				dLastDay := Ctod(cValToChar(10) + "/" + CValToChar(nMes) + "/" + CValToChar(nAno))

			ElseIf nDia >= 11 .and. nDia <= 20	//Segundo Decênio
				dFirstDay := Ctod(cValToChar(11) + "/" + CValToChar(nMes) + "/" + CValToChar(nAno))
				dLastDay := Ctod(cValToChar(20) + "/" + CValToChar(nMes) + "/" + CValToChar(nAno))

			ElseIf nDia >= 21					//Terceiro Decênio
				dFirstDay := Ctod(cValToChar(21) + "/" + CValToChar(nMes) + "/" + CValToChar(nAno))
				dLastDay := LastDay(dDtRef)	
			Endif

			AAdd(aDatas,{dFirstDay,dLastDay})

		ElseIf cPerCum == '4' //Mensal
			dFirstDay := FirstDay(dDtRef)	//Primeiro dia do mês
			dLastDay := LastDay(dDtRef)		//Ultimo dia do mês
			AAdd(aDatas,{dFirstDay,dLastDay})
		Endif
	Else
		AAdd(aDatas,{CTOD("//"),CTOD("//")})
	EndIf	

Return (aDatas)

//---------------------------------------
/*/{Protheus.doc} FinIrfRet
Verifica o valor de Ir tabela progressiva
retidos no período. 

@author  Sivaldo Oliveira
@since 04/12/2018
@version 12
/*/
//---------------------------------------
Static Function FinIrfRet(cCart As Character, cCliFor As Character, cLoja As Character, cTipImp As Character, cRegraFin As Character,;
											cFilOrig As Character, cIdFKO As Character, dDtRef As Date, nVlrRet, nBaseCalc, lBaixa)
	Local cQry    As Character
	Local cQryEst As Character
	Local cTmp    As Character
	Local cWhere  As Character
	
	Default cCart     := ""
	Default cCliFor   := ""
	Default cLoja     := ""
	Default cTipImp   := ""
	Default cRegraFin := ""
	Default cFilOrig   := cFilAnt 
	Default cIdFKO    := ""
	Default dDtRef    := dDataBase
	
	//Inicializa variáveis
	cQry    := ""
	cQryEst := ""
	cTmp    := ""
	cWhere  := ""
	
	//Soma os impostos retidos no período.
	If !Empty(cIdFKO) .And. FKO->(DbSeek(xFilial("FKO", cFilOrig) + cIdFKO)) .And. FKO->FKO_CUMULA $ "2|3"
		cCart    := If(cCart $ "1|P", "P", "R")
		cCartEst := If(cCart == "P",  "R", "P") 
		
		cWhere := FinWheRet(cCart, cCliFor, cLoja, cTipImp, cRegraFin, cFilOrig, dDtRef)
		
		If !Empty(cWhere)
			cQry    := "SELECT SUM(FK4.FK4_VALOR) AS FK4_VALOR, SUM(FK4.FK4_BASIMP) AS FK4_BASIMP "
			cRelTbl := "FROM " + RetSqlName("FK4") + " FK4 "
			cRelTbl += "INNER JOIN " + RetSqlName("FKA") + " FKA ON (FK4.FK4_IDORIG = FKA.FKA_IDORIG) WHERE " 
			
			If cCart == "P" 
				cWhere += "AND FKA_TABORI = '" + If(lBaixa, "FK2", "SE2") + "' "
			Else
				cWhere += "AND FKA_TABORI = '" + If(lBaixa, "FK1", "SE1") + "' "
			EndIf
			
			cQry    += cRelTbl + cWhere
			cQry    += "AND FK4.FK4_RECPAG = '" + cCart + "' AND FK4.FK4_STATUS = '1' "
			cQry    += "AND FKA.D_E_L_E_T_ = ' ' "
			cQry    += "AND FKA.FKA_IDPROC NOT IN ("  
			
			//Tratamento dos estornos
			cQryEst := "SELECT FKA_IDPROC " + cRelTbl + cWhere
			cQryEst += "AND FK4.FK4_RECPAG = '" + cCartEst + "' AND FK4.FK4_STATUS = '2' "
			cQryEst += "AND FKA.D_E_L_E_T_ = ' ')"
			
			cQry += cQryEst 
			cQry    := ChangeQuery(cQry)
			oObj    := FWPreparedStatement():New(cQry)
			cQry    := oObj:GetFixQuery()
			cTmp    := MpSysOpenQuery(cQry)
			
			If (cTmp)->(!Eof())
				nVlrRet := (cTmp)->FK4_VALOR  
				nBaseCalc += (cTmp)->FK4_BASIMP
			EndIf 
			
			(cTmp)->(DbCloseArea())
		EndIf
	EndIf
	
Return Nil

//---------------------------------------
/*/{Protheus.doc} FinWheRet
Monta um filtro sql com as condições do
cadastro de regra de retenção.

@author  Sivaldo Oliveira
@since 05/12/2018
@version 12
/*/
//---------------------------------------
Static Function FinWheRet(cCart As Character, cCliFor As Character, cLoja As Character, cTipImp As Character, cRegraFin As Character, cFilOrig, dDtRef) As Character
	Local cFils    As Character
	Local cWhere   As Character
	Local cSA1SA2  As Character
	Local cCGC     As Character 
	Local cRaizCGC As Character
	Local cPessoa  As Character 
	
	Default cCart     := ""
	Default cCliFor   := ""
	Default cLoja     := ""
	Default cTipImp   := ""
	Default cRegraFin := ""
	Default cFilOrig  := cFilAnt
	Default dDtRef    := dDataBase
	
	//Inicializa variáveis
	cFils    := ""
	cWhere   := ""
	cSA1SA2  := ""
	cCGC     := "" 
	cRaizCGC := ""
	cPessoa  := "" 	
	
	If !Empty(cTipImp) .And. !Empty(cRegraFin)
		cSA1SA2 := If(cCart $ "1|P", "SA2", "SA1")
		(cSA1SA2)->(DbSetOrder(1))
		
		If (cSA1SA2)->(DbSeek(xFilial(cSA1SA2, cFilOrig) + cCliFor + cLoja)) 
			//Filtro das filiais
			cFils := FinSelFil()			
			
			If Empty(cFils) 
				cWhere := "FK4.FK4_FILORI = '" + xFilial("FKO", cFilOrig) + "' "
			Else
				cWhere := "FK4.FK4_FILORI IN " + FinTipoIN(cFils) + " "
			EndIf
			
			If cCart $ "1|P"
				cCGC     := SA2->A2_CGC
				cRaizCGC := Substr(SA2->A2_CGC, 1, 8)
				cPessoa  := SA2->A2_TIPO
			Else
				cCGC     := SA1->A1_CGC
				cRaizCGC := Substr(SA1->A1_CGC, 1, 8)
				cPessoa  := SA1->A1_PESSOA			
			EndIf
			
			//Acumula Por:
			If FKO->FKO_MODCUM == "1" //Cod Cliente/Fornecedor + Loja Atual
				cWhere += "AND FK4.FK4_CLIFOR = '" + cCliFor + "' AND FK4.FK4_LOJA = '" + cLoja + "' "
			ElseIf FKO->FKO_MODCUM == "2"//Cód Cliente/Forcenedor
				cWhere += "AND FK4.FK4_CLIFOR = '" + cCliFor + "' "
			ElseIf (FKO->FKO_MODCUM == "3" .Or. cPessoa == "F") //Cnpj/Cpf
				cCliFor += "AND FK4.FK4_CGC = '" + cCGC + "' "
			Else//Raiz do CGC
				cCliFor += "AND FK4.FK4_RAICGC = '" + cRaizCGC + "' "
			EndIf
			
			//Perído da cumulatividade
			If FKO->FKO_PERCUM == "1" //Diária
				cWhere += " AND FK4.FK4_DATA = '" + DTOS(dDtRef) + "' "
			ElseIf FKO->FKO_PERCUM == "2" //Semanal		
			ElseIf FKO->FKO_PERCUM == "3" //Decendial
			Else //Mensal
				cWhere += " AND FK4.FK4_DATA BETWEEN '"+ DTOS(FirstDay(dDtRef)) +"' AND '"+ DTOS(LastDay( dDtRef)) +"' "
			EndIf
			
			//Tipo de cumulatividade
			If FKO->FKO_CUMUL == "1" //Tipo de imposto (FOO)
				cWhere += "AND FK4.FK4_IMPOS = '" + cTipImp + "' " 
			ElseIf FKO->FKO_CUMUL == "2" //Cod regra financeira (FKK)
				cWhere += "AND FK4.FK4_CODFKM = '" + cRegraFin + "' "	
			Else//Tipo de imposto + Cód da regra financeira
				cWhere += "AND FK4.FK4_IMPOS = '" + cTipImp + "' AND FK4.FK4_CODFKM = '" + cRegraFin + "' "  
			EndIf
			
			cWhere += "AND FK4.D_E_L_E_T_ = ' ' "
		EndIf
	EndIf
Return cWhere

//----------------------------
/*/{Protheus.doc} FinRetFis
Valor do Imposto retido baixa, cálculo do fiscal

@author Sivaldo Oliveira
@since 13/12/2018
@version P12.1.17
/*/
//----------------------------
Static Function FinRetFis(cCart As Character, cImpos As Character, cRegraFin As Character, cFilOrig As Character, cCliFor As Character,;
																			cLoja As Character, cIdFKO As Character, aImpRet As Array)
	Local lRet     As Logical
	Local cQry     As Character
	Local nVlrRet  As Numeric
	Local cWhere   As Character
	Local cSA1SA2  As Character 
	Local cCartEst As Character
	Local cTmp     As Character
	Local aFils    As Array
	
	Default cCart     := ""
	Default cImpos    := ""  
	Default cRegraFin := "" 
	Default cFilOrig  := cFilAnt
	Default cCliFor   := "" 
	Default cLoja     := ""
	Default cIdFKO    := ""
	Default aImpRet   := {.F., 0, 0}
	
	//Inicializa variáveis
	lRet    := .F.
	cQry    := ""
	nVlrRet := 0
	cWhere  := ""
	cSA1SA2 := ""
	cTmp    := ""
	aFils   := {}
	
	If !Empty(cCart) .And. !Empty(cImpos) .And. !Empty(cRegraFin)
		If cCart $ "1|P"
			cSA1SA2  := "SA2"
			cCart    := "P"
			cCartEst := "R"
		Else
			cSA1SA2  := "SA1"
			cCart    := "R"
			cCartEst := "P"		
		EndIf
		
		(cSA1SA2)->(DbSetOrder(1))
		lRet := (cSA1SA2)->(DbSeek(xFilial(cSA1SA2, cFilOrig) + cCliFor + cLoja))
		
		If lRet
			FKO->(DbSetOrder(1))
			If FKO->(DbSeek(xFilial("FKO", cFilOrig)+cIdFKO)) 
				FinSelFil(aFils)
			Else
				Aadd(aFils, cFilAnt) 
			EndIf
			
			If __oRetFis == Nil
				cQry := "SELECT ISNULL(SUM(FK4.FK4_VALOR), 0) AS FK4_VALOR, ISNULL(SUM(FK4.FK4_BASIMP), 0) AS FK4_BASIMP "
				cQry += "FROM ? FK4 "
				cQry += "INNER JOIN ? FK0 ON (FK4.FK4_IDORIG = FK0.FK0_IDORIG AND FK4.FK4_CODFKM = FK0.FK0_CODFKM) " 
				cQry += "INNER JOIN ? FKQ ON (FKQ.FKQ_CODFKK = FK0.FK0_CODFKM AND FKQ.FKQ_IDFK7 = FK0.FK0_IDPAI) "
				cQry += "INNER JOIN ? FKA ON (FKA.FKA_IDORIG = FK4.FK4_IDORIG) "
				cQry += "WHERE FK4.FK4_FILORI IN (?) "
				cQry += "AND FK4.FK4_IMPOS = ? " 
				cQry += "AND FK4.FK4_CODFKM = ? "
				cQry += "AND FK4.FK4_CLIFOR = ? "
				cQry += "AND FK4.FK4_LOJA = ? "
				cQry += "AND FK4.FK4_RECPAG = ? "
				cQry += "AND FK4.FK4_STATUS = '1'"
				cQry += "AND FKA.D_E_L_E_T_ = ' ' AND FK4.D_E_L_E_T_ = ' ' "
				cQry += "AND FK0.D_E_L_E_T_ = ' ' AND FKQ.D_E_L_E_T_ = ' ' "				
			
				cQry := ChangeQuery(cQry)
				__oRetFis := FWPreparedStatement():New(cQry)
			EndIf
			
			__oRetFis:SetNumeric(1, RetSqlName("FK4"))
			__oRetFis:SetNumeric(2, RetSqlName("FK0"))
			__oRetFis:SetNumeric(3, RetSqlName("FKQ"))
			__oRetFis:SetNumeric(4, RetSqlName("FKA"))			
			__oRetFis:SetIn(5, aFils)
			__oRetFis:SetString(6, cImpos)
			__oRetFis:SetString(7, cRegraFin)
			__oRetFis:SetString(8, cCliFor)
			__oRetFis:SetString(9, cLoja)
			__oRetFis:SetString(10, cCart)
			
			cQry := __oRetFis:GetFixQuery()
			cTmp := MpSysOpenQuery(cQry)
			
			While (cTmp)->(!Eof()) 
				aImpRet[2] += (cTmp)->FK4_VALOR
				aImpRet[3] += (cTmp)->FK4_BASIMP
				(cTmp)->(DbSkip())
			EndDo
			
			aImpRet[1] := lRet
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} FinTemCfg
	Função responsavel por verificar se o cliente/fornecedor, 
	possui amarração com configurador de tributos para processos massivos
	tem como principal objetivo a performance das rotinas de grandes processamentos
	(relatorios e as baixas automaticas) no intuito de evitar a chamadas das funções
	FinImpConf e FINCalImp, pois as mesmas são especificas para os impostos que serão retidos
	pelo configurador de tributos
	
	@type  Function
	@author Vitor Duca
	@since 27/10/2020
	@version 1.0
	@param cTable, Character, Tabela temporaria que recebera o UPDATE
	@param cUpdField, Character, Campo da tabela temporaria que ira receber o UPDATE
	@param cCarteira, Character, Carteira do titulo (Pagar = P, Receber = R)
	@param aFieldsTmp, Array, Array contendo os campos da temporaria que possuem a informação do fornecedor ou cliente e loja
	@return nError, Numeric, Codigo de erro na execução da função TcSqlExec()
	@example
	FinTemCfg(_oFINA1101:GetRealName(),"TEMMOTRET",cAliasSE1,"R"{E1_CLIENTE,E1_LOJA})
	@see 
/*/
Function FinTemCfg(cTable As Character,cUpdField As Character,cCarteira As Character,aFieldsTmp As Array) As Numeric
	Local nError   As Numeric
	Local cQry 	   As Character
	Local cNulo	   As Character
	Local cBDname  As Character
	Local cTblMot  As Character
	Local cFldCliFor As Character

	Default cTable	  := RetSqlName("SE1")
	DEFAULT cUpdField := ""
	DEFAULT cCarteira := "R"
	DEFAULT aFieldsTmp := {}

	nError    := 0
	cQry 	  := ""
	cNulo	  := ""
	cBDname   := Upper( TCGetDB() )
	cAliasTMP := IIF( cBDname $ "POSTGRES", "", cTable + "." )
	cTblMot   := "FOJ"
	cFldCliFor := "FOJ_CLIENT"

	Do CASE
		CASE cBDname $ "ORACLE|INFORMIX|DB2"
			cNulo := "NVL"
		CASE cBDname $ "POSTGRES|MYSQL"
			cNulo := "COALESCE"
		OTHERWISE
			cNulo := "ISNULL"
	End CASE
	
	If cCarteira == "P"
		cTblMot := "FOK"
		cFldCliFor := "FOK_FORNEC"
	Endif	

	cQry := " UPDATE " + cTable
	cQry += " SET "+ cAliasTMP + cUpdField + " = "
	cQry += cNulo + "((SELECT COUNT(*) "
	cQry += " FROM " + RetSqlName(cTblMot) + " " + cTblMot
	cQry += " WHERE " + cTable + "." + aFieldsTmp[1] + " = "+cTblMot+"."+cFldCliFor+" AND "
	cQry += cTable + "." + aFieldsTmp[2] + " = " + cTblMot + "." + cTblMot + "_LOJA AND "
	cQry += cTblMot+"."+"D_E_L_E_T_ = ' ' AND "
	cQry += cTable+ ".D_E_L_E_T_ = ' '),0) "
	
	nError := TcSQLExec(cQry)

Return nError
