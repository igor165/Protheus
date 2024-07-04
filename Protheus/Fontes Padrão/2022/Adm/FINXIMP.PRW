#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FINXIMP.CH"

/* realocacao da finxfun */
STATIC aRaRtImp 	:= {}
Static dLastPcc  	:= CTOD("22/06/2015")
Static lIsIssBx 	:= FindFunction("IsIssBx")
Static __lPccBx  	:= NIL
Static __lIRPJBx  	:= NIL
Static __lIssBx		:= NIL
Static lPLSTITPF	:= findFunction("PLSTITPF")
Static _oFINXIMP1	:= NIL
Static __oObjPA		:= Nil
Static __oObjNF		:= Nil
Static cBDname		:= Upper( TCGetDB() )
Static __oQryCP		:= Nil
Static __oQryCR		:= Nil
Static __oQryIrpj	:= Nil
Static __oRetBor    := Nil
Static __nTamParc   := Nil
Static __nTamFor    := Nil
Static __nTamLoja   := Nil
Static __nTamNat	:= Nil
Static __oTemBXCanc	:= Nil	// Objeto para consultas escalares
Static __lFPIXAct   := FindFunction("PIXIsActiv")
// Motor de retenção 
Static __lTemMR 	:= (FindFunction("FTemMotor") .and. FTemMotor())
Static aTitCIrf 	:= {}
Static __lLocBRA	:= cPaisLoc == "BRA"
Static __oQryBxCR 	:= NIL
Static __oQryBdCR 	:= NIL
Static __oQryRACR 	:= NIL
Static __cVl460Nt	:= NIL
Static __lRpoR33	:= NIL
Static __oExretP	:= NIL
Static __oExretR	:= NIL
Static __oPenTxP	:= NIL
Static __oPenTxR	:= NIL

Static __oPccBxCR	:= NIL
Static __oPccBdCR	:= NIL
Static __oPccRaCR	:= NIL
Static __oPccBxCP	:= NIL
Static __oPccBdCP	:= NIL
Static __oPccPaCp	:= NIL
Static __oPccNewPa	:= NIL
Static __cImpPIS	:= NIL
Static __cImpCOF	:= NIL
Static __cImpCSL	:= NIL

//-- Controle do TRB para cálculo do IRRF
Static __oIRFIN 	:= Nil
Static __lRFiConf   := Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FCalcImp    ºAutor  ³Rodrigo Gimenes  	º Data ³10/11/2011º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo das Retenções de Impostos                      	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FCalcImp(cCarteira,cFatGer, cNatur, nValor, cPrefixo, nNum, cCodEmiss,cCodLoja,cTitPai,lGrava,nValBx,cSeqBx, aRetorno)

	Local aAreaSE1		:= {}
	Local aAreaSE2   	:= {}
	Local aAreaFRN   	:= FRN->(GetArea())
	Local aAreaFRM   	:= FRM->(GetArea())
	Local nValBase	 	:= 0
	Local nValCalc   	:= 0
	Local nValRet		:= 0
	Local nAliq      	:= 0
	Local nReduc		:= 0
	Local nFator		:= 0
	Local nValFator		:= 0
	Local nOperacao		:= 0
	Local cOrigem  		:= FunName()
	Local cTipo 		:= Substr(AllTrim(cCarteira),1,1)  //1 - Pagar, 2 - Receber, 3 - Ambos
	Local dVencto 		:= dDataBase
	Local aTemp 		:= {}
	Local nTotRetTx 	:= 0
	Local nRetTx 		:= 0
	Local nDifRetTx 	:= 0
	Local aRetTx 		:= {}
	Local cSiglaImp		:= ""
	Local nPosConcept   := 0
	Default nValBx 		:= 0
	Default cSeqBx		:= ""

	Default aRetorno := {}

	If cTipo == '3'
		cTipo := IIf(cOrigem $ "FINA050|FINA080","1","2")
	EndIf

	If cTipo == '1'
		aAreaSE2	:= SE2->(GetArea())
	Elseif cTipo == '2'
		aAreaSE1   	:= SE1->(GetArea())
	EndIf

	DbSelectArea("FRN")
	FRN->( DbSetOrder(2) )
	If 	FRN->( DbSeek( xFilial("FRN") + cNatur ) )
		While 	!FRN->( Eof() ) .And. FRN->(xFilial("FRN") + FRN_CODNAT) 	== 	xFilial("FRN") 	+ cNatur
			If 	FRN->FRN_MSBLQL	<>	'1'

				DbSelectArea("FRM")
				FRM->( DbSetOrder(2) )
				FRM->( dbSeek(xFilial("FRM") + FRN->FRN_IMPOST + FRN->FRN_SEQ ) )
				While 	!FRM->( Eof() ) .And. FRM->(xFilial("FRM") + FRM->FRM_COD + FRM->FRM_SEQ) 	== 	xFilial("FRM") 	+ FRN->FRN_IMPOST + FRN->FRN_SEQ
					If 	!FRM->FRM_APLICA $ "1|2"
						FRM->( DbSkip() )
						Loop
					EndIf

					//Zera todas as variáveis
					nValRet		:= 0
					nValCalc    := 0
					nValBase	:= 0
					nAliq		:= 0
					nReduc		:= 0
					nFator 		:= 0
					nValFator	:= 0
					nOperacao	:= 0
					If 	FRM->FRM_CARTEI	   	$ 	cCarteira .And. cFatGer == FRM->FRM_FATGER 	.And. FRM->FRM_INIVIG  	<= 	dDataBase 	.And. 	FRM->FRM_FIMVIG  	>= 	dDataBase    .And. ;
						FRM->FRM_MSBLQL		<>	'1' .And. FRM->FRM_BLOQ 	<> 	'1'   .And. (FRM->FRM_TPESSO    ==  "9"			.Or.	FRM->FRM_TPESSO  	==  FTipPessoa(cTipo,cCodEmiss+cCodLoja))
						//Desconta o valor dos impostos da nota, se houver
						If cTipo == "1"
							nValBase := FCalcBase(FRM->FRM_BSCALC,nValor,SE2->E2_FILIAL,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA) //Calcula a base do imposto descontando os impostos da nota, conforme parâmetrização
						Else
							nValBase := FCalcBase(FRM->FRM_BSCALC,nValor,SE1->E1_FILIAL,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA) //Calcula a base do imposto descontando os impostos da nota, conforme parâmetrização
						EndIf
						aTemp := FRetAliq(FRN->FRN_IMPOST, FRN->FRN_SEQ, cNatur, FRM->FRM_CARTEIRA, nValBase) // Retorna a aliquota,a redução e o fator, se houver
						If Len(aTemp) >= 5
							nAliq 			:= 	aTemp[1] //Aliquota
							nReduc 			:= 	aTemp[2] //Redução
							nFator 			:= 	aTemp[3] //Fator
							nValFator		:= 	aTemp[4] //Valor do piso do conceito
							nOperacao		:= 	aTemp[5] //Verifica se adiciona ou subtrai o valor do fator
						EndIf
						nValRet			:= 	FCalcRet(FRN->FRN_IMPOST, FRN->FRN_SEQ, FRM->FRM_CARTEIRA, cNatur, nValBase,nAliq,nReduc,nFator,nValFator,nOperacao) // Calcula o valor que deveria reter
						nValCalc 	 	:= 	nValRet // Calcula o valor da retenção efetiva
						If !Empty(nValBx) .And. nValor > nValBx
							If FRM->FRM_RGPARC == "1"  //Proporcionaliza
								nValCalc := FCalcRet(FRN->FRN_IMPOST, FRN->FRN_SEQ, FRM->FRM_CARTEIRA, cNatur, nValBx,nAliq,nReduc,nFator,nValFator,nOperacao) // Calcula o valor que deveria reter
							Else
								nTotRetTx := 0
								aRetTx :=	{}

								If cTipo == "1"
									aRetTx := FaRecImp(SE2->E2_FILIAL,cTipo,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_FORNECE, SE2->E2_LOJA,Iif (FRM->FRM_APLICA == "1", "I","R"),SE2->E2_NATUREZ,FRM->FRM_FATGER)
								Else
									aRetTx := FaRecImp(SE1->E1_FILIAL,cTipo,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_CLIENTE, SE1->E1_LOJA,Iif (FRM->FRM_APLICA == "1", "I","R"),SE1->E1_NATUREZ,FRM->FRM_FATGER)
								EndIf

								For nRetTx := 1 To Len(aRetTx)
									nTotRetTx +=  aRetTx[nRetTx][9]
								Next
								nDifRetTx := 0
								nDifRetTx := nValRet - nTotRetTx //Calcula o quanto preciso reter ainda
								nValCalc := nDifRetTx
								If nTotRetTx < nValRet
									If  nValRet > nValBx // Se o valor que deve ser retido for maior que o valor baixado, retém o quanto puder.
										If nDifRetTx >= nValBx
											nValCalc := nValBx - 0.01
										EndIf
									EndIf
								Else
									nValCalc := 0 //Se já reteve o valor integral do imposto, não deve ser gerado mais nenhum título
								EndIf
							EndIf
						EndIf

						// Cálculo do Valor do Imposto qdo regra de aplicação definida como Retenção ou Imposto
						If 	nValCalc > 0  .And. (!Empty(FRM->FRM_TPABT) .Or. !Empty(FRM->FRM_TPTIT))
							If 	cFatGer <> "9" .And. lGrava
								dVencto :=	FCalcVenc(IIf(cTipo == "1", SE2->E2_EMISSAO,SE1->E1_EMISSAO),FRM->FRM_VCDIA,FRM->FRM_VCTIPO,FRM->FRM_VCDUTI,FRM->FRM_VCCONT,FRM->FRM_VCFAT,FRM->FRM_VDTVLD)
								cSiglaImp := FaIncNat(Iif(cTipo =="1","2","1"), FRM->FRM_SIGLA)
								If cTipo == "1"
									nRecno := SE2->(Recno())
									/* Gerar Título de Abatimento de Retenção - SE2 */
									FaGrvImp(cTipo,SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, nValCalc, Iif (FRM->FRM_APLICA == "1", "I","R"), Iif (FRM->FRM_APLICA == "1", FRM->FRM_TPTIT,FRM->FRM_TPABT), cTitPai,dVencto,cOrigem,nRecno,cSiglaImp,cSeqBx,cFatGer)
								ElseIf cTipo == "2"
									nRecno := SE1->(Recno())
									FaGrvImp(cTipo,SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, nValCalc, Iif (FRM->FRM_APLICA == "1", "I","R"), Iif (FRM->FRM_APLICA == "1", FRM->FRM_TPTIT,FRM->FRM_TPABT),cTitPai,dVencto,cOrigem,nRecno,cSiglaImp,cSeqBx,cFatGer)
								EndIf
							EndIf
							// Array antigo
							/*
							aImpostos := {} //Limpa o array de detalhes
							AAdd(aImpostos,FRM->FRM_SIGLA)	//Sigla
							AAdd(aImpostos,nValBase) 	 	//Valor Base
							AAdd(aImpostos,nAliq) 	 		//Alíquota
							AAdd(aImpostos,nValCalc) 	 	//Imposto Calculado
							AAdd(aImpostos,nValRet) 	 	//Imposto a ser retido
							AAdd(aImpostos,FRM->FRM_APLICA) //Tipo
							AAdd(aRetorno,aImpostos) 		//Enche o Array com os dados de cada imposto para a natureza
							*/
							//
							// Usar a logica do Concep
							If Len(aRetorno) > 0
								nPosConcept := Ascan(aRetorno,{|x,y| x[7] == FRN->FRN_IMPOST})
							endif
							If nPosConcept == 0
								AADD(aRetorno,{FRN->FRN_CONCEP,"",nValBase,nAliq,nValCalc,"",FRN->FRN_IMPOST})
							Else
								aRetorno[1][3] += nValBase
								aRetorno[1][5] += nValCalc
							EndIf
						EndIf
					EndIf
					FRM->( DbSkip() )
				EndDo
			EndIf

			FRN->( DbSkip() )
		EndDo
	EndIf

	If cTipo == "1"
		RestArea(aAreaSE2)
	ElseIf cTipo == "2"
		RestArea(aAreaSE1)
	EndIf
	RestArea(aAreaFRM)
	RestArea(aAreaFRN)

Return(aRetorno)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FTipPessoa³ Autor ³ Rodrigo Gimenes       ³ Data ³ 11/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica o tipo de pessoa do cliente/fornecedor             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FTipPessoa(cTipo,cCodigo)                        			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico  - Localizações                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FTipPessoa(cTipo,cCodigo)

	Local aArea		:= GetArea() //Salva a área atual
	Local cRetorno  := ""

	If cTipo == "2"
		DbSelectarea("SA1")
		SA1->( dbSetOrder(1) )
		If SA1->( dbSeek(xFilial("SA1") + cCodigo ))
			cRetorno := SA1->A1_TIPO
		EndIf
	Elseif cTipo == "1"
		DbSelectarea("SA2")
		SA2->( dbSetOrder(1) )
		If SA2->( dbSeek(xFilial("SA2") + cCodigo ) )
			cRetorno := SA2->A2_TIPO
		EndIf
	EndIf

	RestArea(aArea)

Return(cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FCalcRet  ºAutor  ³	Rodrigo Gimenes  º Data ³  11/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula o valor do Imposto                             	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FCalcRet(cImposto, cSequencia, cCarteira, cNatur, nValor,nAliq,nReduc,nFator,nValFator, nOperacao)

	Local nValImp 	:= 0

	If nAliq > 0
		If nValFator > 0
			If nOperacao == 1
				nValImp := nFator + (( nValor - nValFator ) * (nAliq / 100) )
			Else
				nValImp := 	nFator - ((nValor - nValFator ) * (nAliq / 100) )
			EndIf
		Else
			nValImp := 	(nAliq 	* nValor )   / 100
		EndIf
	EndIf
	If nReduc > 0
		nValImp := nValImp - (nReduc * nValImp ) / 100
	EndIf

Return nValImp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FCalcBase ºAutor  ³	Rodrigo Gimenes  º Data ³  11/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula a base do Imposto                             	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FCalcBase(cBaseCalc,nValor,cFili,cPrefixo,cNumero,cParcela, cTipo, cCliFor, cLoja)

	Local aAreaSD1 	:= SD1->(GetArea())
	Local aAreaSF1 	:= SF1->(GetArea())
	Local aAreaSD2 	:= SD2->(GetArea())
	Local aAreaSF2 	:= SF2->(GetArea())
	Local aImpInf	:= {}
	Local nX	 	:= 0
	Local nDesconto := 0

	If cBaseCalc == "1" //Desconta os valores dos impostos já calculados na Nota

		//Valida se o título é proveniente de nota de entrada

		dbSelectArea("SF1")
		dbSetOrder(1)
		If SF1->(dbSeek(xFilial("SF1")+	cNumero+cPrefixo+cCliFor+cLoja))

			dbSelectArea("SD1")
			SD1->(DbSetOrder(1))

			If SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))

				While !SD1->(Eof()) .And. xFilial("SD1") == SD1->D1_FILIAL .And.;
					SF1->F1_DOC == SD1->D1_DOC .And. SF1->F1_SERIE == SD1->D1_SERIE .And.;
					SF1->F1_FORNECE == SD1->D1_FORNECE .And. SF1->F1_LOJA == SD1->D1_LOJA

					aImpInf := TesImpInf(SD1->D1_TES)

					For nX := 1 to Len (aImpInf)
						nDesconto += SD1->(FieldGet(FieldPos(aImpInf[nX][02])))
					Next nX

					SD1->(dbSkip())

				EndDo

			EndIf
		EndIf

		//Valida se o título é proveniente de nota de saída

		dbSelectArea("SF2")
		dbSetOrder(1)
		If SF2->(dbSeek(xFilial("SF2")+	cNumero+cPrefixo+cCliFor+cLoja))

			dbSelectArea("SD2")
			SD2->(DbSetOrder(1))

			If SD2->(DbSeek(xFilial("SD1")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))

				While !SD2->(Eof()) .And. xFilial("SD2") == SD2->D2_FILIAL .And.;
					SF2->F2_DOC == SD2->D2_DOC .And. SF2->F2_SERIE == SD2->D2_SERIE .And.;
					SF2->F2_CLIENTE == SD2->D2_CLIENTE .And. SF2->F2_LOJA == SD2->D2_LOJA

					aImpInf := TesImpInf(SD2->D2_TES)

					For nX := 1 to Len (aImpInf)
						nDesconto += SD1->(FieldGet(FieldPos(aImpInf[nX][02])))
					Next nX

					SD1->(dbSkip())

				EndDo

			EndIf
		EndIf

	EndIf

	nValor -= nDesconto

	RestArea(aAreaSD1)
	RestArea(aAreaSF1)
	RestArea(aAreaSD2)
	RestArea(aAreaSF2)

Return nValor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FRetAliq  ºAutor  ³	Rodrigo Gimenes  º Data ³  11/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a alíquota e a redução, se houver,do Imposto        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FRetAliq(cImposto,cSequencia,cNatur,cCarteira,nValor)

	Local aArea 	:= GetArea()
	Local aAreaFRN  := FRN->(GetArea())
	Local aAreaFRM  := FRM->(GetArea())
	Local nValAliq 	:= 0
	Local nValRedu	:= 0
	Local nFator	:= 0
	Local nValFator	:= 0
	Local nValPiso	:= 0
	Local nOperacao	:= 0
	Local aRet		:= {}

	DbSelectArea("FRN")
	FRN->( DbSetOrder(2) )
	If 	FRN->( DbSeek(xFilial("FRN") + cNatur + cImposto + cSequencia ) )
		DbSelectArea("FRM")
		FRM->( DbSetOrder(2) )
		If FRM->( dbSeek(xFilial("FRM") + FRN->FRN_IMPOST + FRN->FRN_SEQ + cCarteira ) )
			If	!Empty(FRN->FRN_CONCEP)
				DbSelectArea("CCR")
				CCR->( dbSetOrder(1) )
				If CCR->( dbSeek(xFilial("CCR")+AvKey(FRN->FRN_CONCEP,"CCR_CONCEP")) )
					While !CCR->(EOF()) .AND. CCR->CCR_CONCEP == FRN->FRN_CONCEP
						If CCR->CCR_VALOR > nValor
							If	CCR->CCR_ALIQ 	<> 	0
								nValAliq 	:=	CCR->CCR_ALIQ
								If cPaisLoc $ "AUS|COS"
									nFator 	 	:= CCR->CCR_FATOR
									nValFator	:= nValPiso
									nOperacao	:= CCR->CCR_OPERAC
								EndIf
							ElseIf FRM->FRM_ALIQ <> 0
								nValAliq := 	FRM->FRM_ALIQ
							EndIf
							If	CCR->CCR_REDUC 	<> 	0
								nValRedu := CCR->CCR_REDUC
							ElseIf FRN->FRN_REDUC <> 0
								nValRedu := FRN->FRN_REDUC
							EndIf
							Exit
						EndIf
						nValPiso := CCR->CCR_VALOR
						CCR->( DbSkip() )
					EndDo

				EndIf
			ElseIf  Empty(FRN->FRN_CONCEP)
				If 	FRM->FRM_ALIQ 		<> 	0
					nValAliq := 	FRM->FRM_ALIQ
				endif
				If FRN->FRN_REDUC <> 0
					nValRedu := FRN->FRN_REDUC
				EndIf
			EndIf
		EndIf
	EndIf

	//Popula o vetor com os valores
	aAdd(aRet,nValAliq)
	aAdd(aRet,nValRedu)
	aAdd(aRet,nFator)
	aAdd(aRet,nValFator)
	aAdd(aRet,nOperacao)


	RestArea(aAreaFRN)
	RestArea(aAreaFRM)
	RestArea(aArea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FCalcVenc ºAutor  ³	Rodrigo Gimenes  º Data ³  11/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula a data de vencimento do título de imposto        	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FCalcVenc(dVencto,nVcDia,cVcTipo,cVcDuti,cVcCont,nVcFat,cVdtvld)

	Local aArea 	:= GetArea()
	Local nDia 		:= 0  //Dia
	Local nMes		:= 0 //Mes
	Local nAno		:= 0 //Ano
	Local nDiaSem	:= 0 //Dia da semana
	Local dTemp 	:= dVencto
	Local nTemp 	:= 0
	Local nDiaCorr 	:= 0

	//Desmembro a data atual para poder calcular a data de vencimento
	nDia := Day(dVencto)
	nMes := Month(dVencto)
	nAno := Year(dVencto)
	nDiaSem := Dow(dVencto)

	If cVcCont == "1" //Contador = Semana
		If nVcFat > 0
			nTemp :=  0
			nTemp :=  (9 - nDiaSem) + ((nVcFat-1) * 7) //Calcula quantos dias faltam para iníciar a próxima, e depois adiciona o numero de dias referentes às semanas do contador
		EndIf
		dTemp := dVencto + nTemp
	Else //Contador == Mês
		nMes  :=  Month(dVencto) + nVcFat
		nTemp := 0
		//Se o mês for maior que doze, tenho de somar os anos.
		If nMes > 12
			nTemp :=  Int(nMes / 12) //Verifica se deve adicionar anos ao ano atual
			nMes  :=  nMes - (12 * nTemp)
		EndIf
		nAno  :=  Year(dVencto)  + nTemp
		dTemp := Ctod("01/" + CValToChar(nMes) + "/" + CValToChar(nAno))
	EndIf

	If cVcTipo == "1" //Vencimento com dia fixo
		nMes  :=  Month(dTemp)
		nAno  :=  Year(dTemp) //+Iif(Month(dTemp) == 12,1,0)
		dTemp := Ctod(cValToChar(nVcDia) + "/" + CValToChar(nMes) + "/" + CValToChar(nAno))

	Else //Vencimento com contagem de dias
		If cVcCont == "2"
			nVcDia --
		EndIf
		If cVcDuti == "1" //Verifica se utiliza dia útil
			For nDiaCorr := 1 To nVcDia
				dTemp := DataValida((dTemp + 1),.T.)
			Next
		Else
			dTemp := dTemp + nVcDia //Matém
			//Data válida
			If cVdtvld == "1" //Posterga
				dTemp := DataValida(dTemp,.T.)
			ElseIf cVdtvld == "2" //Adianta
				dTemp := DataValida(dTemp,.F.)
			EndIf
		EndIf
	EndIf

	//Se a data calculada for menor que a emissão\vencimento original, prevalece a última
	If dTemp < dVencto
		dTemp := dVencto
	EndIf

	dRet := dTemp

	RestArea(aArea)

Return dRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FaDelImp  ºAutor  ³	Rodrigo Gimenes  º Data ³  17/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta o registro de imposto                          	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FaDelImp(cFili,cPrefixo,cNumero,cParcela,cCliFor,cLoja,lAtuSldNat,cCarteira,cNat,cSeq,cFatGer)

	Local aArea		:= GetArea()
	Local aAreaSE1 	:= {}
	Local aAreaSE2 	:= {}
	Local cTipoTit	:= ""
	Local aImps		:= ""
	Local nImps		:= 0
	Default cSeq 	:= ""

	aImps := FaImpSeq(cCarteira,cNat,cFatGer)

	For nImps := 1 To Len(aImps)

		If cCarteira == "1"
			If FaAplica(cNat,aImps[nImps][1],aImps[nImps][2],cCarteira)  == "I" // Se for uma retenção(Aplicação Imposto), deve procurar títulos com o fornecedor padrão para abatimentos
				cCliFor := FaIncForn()
				cLoja 	:= "00"
			EndIf

			aAreaSE2 := SE2->(GetArea("SE2"))
			DbSelectArea("SE2")
			SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			SE2->(dbSeek(cFili+cPrefixo+cNumero))
			While !SE2->(Eof( )) .And. SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM) == cFili+cPrefixo+cNumero

				If Empty(cTipoTit) //Só faço a verificação de tipos de titulos gerados como imposto na primeira vez
					cTipoTit := FaTipoImp(cNat,cCarteira,cFatGer)
				EndIf

				If SE2->(E2_FORNECE+E2_LOJA) == (cCliFor+cLoja) .And. SE2->E2_TIPO $ cTipoTit  .And. SE2->E2_SALDO != 0 .And. Alltrim(SE2->E2_ORDPAGO) == AllTrim(cSeq)

					If lAtuSldNat
						AtuSldNat(cNat, SE2->E2_VENCREA, SE2->E2_MOEDA, "2", "P", SE2->E2_VALOR, SE2->E2_VLCRUZ, "-")
					Endif
					RecLock( "SE2" ,.F.,.T.)
					SE2->(dbDelete( ))
				EndIf
				SE2->(dbSkip())
			Enddo
			RestArea(aAreaSE2)
		ElseIf cCarteira == "2"
			aAreaSE1 := SE1->(GetArea("SE1"))
			DbSelectArea("SE1")
			SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			SE1->(dbSeek(cFili+cPrefixo+cNumero))
			While !SE1->(Eof( )) .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == cFili+cPrefixo+cNumero

				If Empty(cTipoTit) //Só faço a verificação de tipos de titulos gerados como imposto na primeira vez
					cTipoTit := FaTipoImp(cNat,cCarteira,cFatGer)
				EndIf

				If SE1->(E1_CLIENTE+E1_LOJA) == (cCliFor+cLoja) .And. SE1->E1_TIPO $ cTipoTit  .And. SE1->E1_SALDO != 0
					If lAtuSldNat
						AtuSldNat(cNat, SE1->E1_VENCREA, SE1->E1_MOEDA, "2", "R", SE1->E1_VALOR, SE1->E1_VLCRUZ, If(SE1->E1_TIPO$MVABATIM,"+","-"),,FunName(),"SE1",SE1->(Recno()))
					Endif
					RecLock( "SE1" ,.F.,.T.)
					SE1->(dbDelete( ))
				EndIf
				SE1->(dbSkip())
			Enddo
			RestArea(aAreaSE1)
		EndIf
	Next

	RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FaTipoImp ºAutor  ³	Rodrigo Gimenes  º Data ³  17/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna os tipos de documento utilizados para o imposto     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FaTipoImp(cCodNat,cCarteira,cFatGer)

	Local aArea		:= GetArea()
	Local cRet		:= ""

	DbSelectArea("FRN")
	FRN->( DbSetOrder(2)) // FRN_FILIAL+FRN_CODNAT+FRN_IMPOST+FRN_SEQ
	If FRN->( DbSeek(xFilial("FRN") + cCodNat ) )
		While !FRN->(Eof()) .And. (FRN->FRN_FILIAL + FRN->FRN_CODNAT) == xFilial("FRN") + cCodNat
			DbSelectArea("FRM")
			FRM->( DbSetOrder(2) ) //FRM_FILIAL+FRM_COD+FRM_SEQ+FRM_CARTEI
			If FRM->(dbSeek(xFilial("FRM") + FRN->FRN_IMPOST + FRN->FRN_SEQ))
				If FRM->FRM_CARTEI	$ (cCarteira+"|3") .And. FRM->FRM_FATGER == cFatGer
					cRet += Iif(Empty(FRM->FRM_TPABT),"",FRM->FRM_TPABT + "|") + Iif(Empty(FRM->FRM_TPTIT),"",FRM->FRM_TPTIT + "|")
				EndIf
			EndIf
			FRN->(DbSkip())
		EndDo
	Else
		DbSelectArea("FRM")
		FRM->( DbSetOrder(3) ) //FRM_FILIAL+FRM_SIGLA+FRM_CARTEI+FRM_MSBLQL
		FRN->( DbSeek(xFilial("FRM") + cCodNat + cCarteira ) )
		While !FRM->(Eof()) .And. FRM->(FRM_FILIAL + FRM_SIGLA) == (xFilial("FRN") + cCodNat)
			If FRM->FRM_CARTEI	$ (cCarteira+"|3") .And. FRM->FRM_FATGER == cFatGer
				cRet += Iif(Empty(FRM->FRM_TPABT),"",FRM->FRM_TPABT + "|") + Iif(Empty(FRM->FRM_TPTIT),"",FRM->FRM_TPTIT + "|")
			EndIf
			FRM->(DbSkip())
		EndDo
	EndIf

	If Len(cRet) > 0
		cRet := Substr(cRet,1,Len(cRet)-1)
	EndIf

	RestArea(aArea)

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FaIncForn ºAutor  ³	Rodrigo Gimenes  º Data ³  17/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna os tipos de documento utilizados para o imposto     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FaIncForn()

	Local aArea		:= GetArea()
	Local aAreaSA2	:= SA2->(GetArea())
	Local nTamCod	:= TamSx3("A2_COD")[1]
	Local cCodigo	:= Substr(SuperGetMv("MV_UNIAO",.F.) + Space(nTamCod),1,nTamCod)
	Local cEst		:= SuperGetMv("MV_ESTADO",.F.)
	//Para Austrália
	Local cNomeRed	:= "APO"
	Local cNome   	:= "AUTRALIAN TAX OFFICE"

	DbSelectarea("SA2")
	SA2->( dbSetOrder(1) ) //A2_FILIAL+A2_COD+A2_LOJA
	If !SA2->( dbSeek(xFilial("SA2") + cCodigo + "00") ) //Se não existir o fornecedor, cria
		Reclock("SA2",.T.)
		SA2->A2_FILIAL 	:= xFilial("SA2")
		SA2->A2_COD 	:= cCodigo
		SA2->A2_LOJA	:= "00"
		SA2->A2_NOME	:= cNome
		SA2->A2_NREDUZ 	:=  cNomeRed
		SA2->A2_BAIRRO 	:= "."
		SA2->A2_MUN 	:= "."
		SA2->A2_EST 	:= cEst
		SA2->A2_END 	:= "."
		SA2->A2_TIPO	:= "J"
		MsUnlock()
	Else
		cCodigo := SA2->A2_COD
	EndIf

	RestArea(aAreaSA2)
	RestArea(aArea)

Return(cCodigo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FaFatGer  ºAutor  ³Paulo Leme          º Data ³  25/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Identifica Fato Gerador da Retenção 1-Emissao ou 2-Baixa  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINXIMP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FaFatGer(cTipo,cNatur)

	Local aArea 	:= GetArea()
	Local cFatGer 	:= " "

	DbSelectArea("FRN")
	FRN->( DbSetOrder(2) )
	If 	FRN->( DbSeek( xFilial("FRN") + cNatur ) )
		While 	!FRN->( Eof() ) .And. FRN->(xFilial("FRN") + FRN_CODNAT) 	== 	xFilial('FRN') 	+ cNatur
			If 	FRN->FRN_MSBLQL	<>	'1'
				DbSelectArea("FRM")
				FRM->( DbSetOrder(2) )
				FRM->( dbSeek(xFilial("FRM") + FRN->FRN_IMPOST + FRN->FRN_SEQ ) )
				While 	!FRM->( Eof() ) .And. FRM->(xFilial("FRM") + FRM->FRM_COD + FRM->FRM_SEQ) 	== 	xFilial('FRM') 	+ FRN->FRN_IMPOST + FRN->FRN_SEQ
					If 	FRM->FRM_CARTEI	$ (cTipo+"|3")
						cFatGer	:= FRM->FRM_FATGER
						Exit
					EndIf
					FRM->( DbSkip() )
				EndDo
			EndIf
			If 	cFatGer	<> " "
				Exit
			EndIf
			FRN->( DbSkip() )
		EndDo
	EndIf

	RestArea(aArea)

Return cFatGer

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FaGrvImp  ºAutor  ³Rodrigo Gimenes     º Data ³  25/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Gera o título de retenção/Imposto                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINXIMP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FaGrvImp(cCarteira,cPrefixo, cNum, cParcela, cTipo, cCliFor, cLoja, nValCalc, cAplica, cTipoDoc, cTitPai,dVencto,cOrigem,nRecno,cNatur,cSeqBx,cFatGer)

	Local aArea 	:= GetArea()
	Local aAreaSE1	:= {}
	Local aAreaSE2  := {}

	If cCarteira ==  "1"
		If cAplica == "I"  .And. cFatGer == "1"
			aAreaSE2	:= SE2->(GetArea())
			dbSelectArea("SE2")
			SE2->(DbGoto(nRecno))
			RecLock("SE2",.F.)
			E2_VALOR    := SE2->E2_VALOR  - nValCalc
			E2_SALDO    := SE2->E2_SALDO  - nValCalc
			E2_VLCRUZ   := SE2->E2_VLCRUZ - nValCalc
			MsUnLock()
			RestArea(aAreaSE2)
		EndIf
		FGerTxCP(cPrefixo, cNum, cParcela, cTipo, cCliFor, cLoja, nValCalc, cAplica, cTipoDoc,cTitPai,dVencto,cOrigem,cNatur,cSeqBx)
	Else
		If cAplica == "I" .And. cFatGer == "1"
			aAreaSE1	:= SE1->(GetArea())
			dbSelectArea("SE1")
			SE2->(DbGoto(nRecno))
			RecLock("SE1",.F.)
			E1_VALOR    := SE1->E1_VALOR  - nValCalc
			E1_SALDO    := SE1->E1_SALDO  - nValCalc
			E1_VLCRUZ   := SE1->E1_VLCRUZ - nValCalc
			MsUnLock()
			RestArea(aAreaSE1)
		EndIf
		FGerTaxaCR(cPrefixo, cNum, cParcela, cTipo, cCliFor, cLoja, nValCalc, cAplica, cTipoDoc,dVencto,cOrigem,cNatur)
	EndIf

	RestArea(aArea)

Return ()

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FGerTaxaCP³ Autor ³ Rodrigo Gimenes       ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera  titulo de abatimento no Contas a Pagar - Austrália    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fGerAbatCP (cPrefixo, cTitulo, cParcela, cTipoDoc, nFornec, ³±±
±±³			 ³	nLoja,nValAbat, cTipoRet, cTpAbt, cTitPai,dVencto,cOrig)  ³±±
±±³ 		 ³                     		  								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico  - Austrália                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGerTxCP(cPrefixo, cTitulo, cParcela, cTipoDoc, cFornec, cLoja, nValAbat, cTipoRet, cTpAbt, cTitPai,dVencto,cOrig,cNatur,cSeqBx)
	LOCAL aArea			:= GetArea()
	LOCAL aAreaSE2 		:= {}
	LOCAL aAbatimento	:= {}
	LOCAL aDadosTit 	:= {}
	LOCAL lOk 			:= .T.
	LOCAL cSE2Filter 	:= " "
	Local cFornTx		:= Iif(cTipoRet == "I",FaIncForn(),cFornec)
	Local cLojaTx		:= Iif(cTipoRet == "I","00",cLoja)
	Local cParcTx		:= cParcela
	Local nTemp 		:= 0
	Default dVencto 	:= CTOD("//")
	Default cOrig 		:= "FINA050"
	Default cSeqBx		:= ""

	//Posicionar no Titulo original (SE2)
	SE2->(dbSetOrder(1))
	If !SE2->(dbSeek(xFilial("SE2")+cPrefixo+cTitulo+cParcela+cTipoDoc+cFornec+cLoja))
		Help(" ",1, STR0001     ,, STR0002      , 4,0)  //"Titulo " "Titulo não encontrado  "
		Return .F.
	EndIf

	//Evitar duplicates
	aAreaSE2   := SE2->(GetArea())
	If !Empty(SE2->(DbFilter()))
		cSE2Filter := SE2->(DbFilter())
		DbselectArea("SE2")
		Set Filter To
	EndIf

	//Verifica se já existe o título, e vai trocando a parcela
	SE2->(dbSetOrder(1))
	If SE2->(dbSeek(xFilial("SE2")+cPrefixo+cTitulo+cParcTx+cTpAbt+cFornTx+cLojaTx))
		While !SE2->(EOF()) .And. (cPrefixo+cTitulo+cParcTx+cTpAbt+cFornTx+cLojaTx	) == SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
			nTemp++
			cParcTx := cValToChar(nTemp)
			SE2->(DbSkip())
		EndDo
	EndIf
	If !Empty(cSE2Filter)
		DbselectArea("SE2")
		Set Filter To &cSE2Filter
	EndIf
	RestArea(aAreaSE2)

	//Verificar se valor do abatimento é maior ou igual que o titulo original
	If nValAbat > SE2->E2_VALOR
		Help(" ",1, STR0003     ,, STR0004      , 4,0)  // "Valor a Abater " "Valor a Abater maior que o valor do titulo  "
		Return .F.
	EndIf

	//Verificar se existe saldo no titulo original
	If (nValAbat > SE2->E2_SALDO .and. !Empty(SE2->E2_BAIXA)) .or.   SE2->E2_SALDO == 0
		Help(" ",1, STR0001     ,, STR0005       , 4,0)  //"Titulo ""Titulo Sem Saldo a Abater "
		Return .F.
	EndIf

	//Guarda dados do titulo principal
	aDadosTit := {SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_NATUREZ, SE2->E2_FORNECE,;
	SE2->E2_LOJA, SE2->E2_VALOR, SE2->E2_VENCTO, SE2->E2_HIST, SE2->E2_EMISSAO,  SE2->E2_MOEDA }

	If ( Alltrim(cTipoDoc) = "NF" .OR. "ND"$ Alltrim(cTipoDoc)).and. nValAbat > 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gerar Título de Abatimento de Retenção (por exemplo: TIPO="IV-","IR-",etc...)     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAbatimento := {}
		AADD(aAbatimento , {"E2_PREFIXO", 	aDadosTit[1]            							, NIL})
		AADD(aAbatimento , {"E2_NUM"    , 	aDadosTit[2]			    						, NIL})
		AADD(aAbatimento , {"E2_PARCELA",	cParcTx		            							, NIL})
		AADD(aAbatimento , {"E2_TIPO"   , 	cTpAbt   		   	 		  						, NIL})
		AADD(aAbatimento , {"E2_FORNECE", 	Iif(cTipoRet == "I",FaIncForn(), aDadosTit[6])		, NIL})
		AADD(aAbatimento , {"E2_LOJA"   , 	Iif(cTipoRet == "I","00",aDadosTit[7])				, NIL})
		AADD(aAbatimento , {"E2_VALOR"  , 	nValAbat             								, NIL})
		AADD(aAbatimento , {"E2_VLCRUZ" , 	nValAbat             								, NIL})
		AADD(aAbatimento , {"E2_NATUREZ", 	cNatur				 								, NIL})
		AADD(aAbatimento , {"E2_EMISSAO", 	aDadosTit[11]           							, NIL})
		AADD(aAbatimento , {"E2_VENCTO" , 	dVencto												, NIL})
		AADD(aAbatimento , {"E2_VENCREA", 	dVencto												, NIL})
		AADD(aAbatimento , {"E2_VENCORI", 	dVencto												, NIL})
		AADD(aAbatimento , {"E2_EMIS1"  , 	dDataBase               							, NIL})
		AADD(aAbatimento , {"E2_MOEDA"  , 	aDadosTit[12]       								, NIL})
		AADD(aAbatimento , {"E2_HIST"   , 	Iif(cTipoRet == "R",STR0006,STR0007)				, NIL}) //"Abatimento de Retenção " "Retenção de Taxas"
		AADD(aAbatimento , {"E2_ORIGEM" , 	cOrig 	            								, NIL})
		If !Empty(cSeqBx)
			AADD(aAbatimento , {"E2_ORDPAGO", 	cSeqBx 	            								, NIL})  //Para Baixas parciais, é importante a sequencia, para o caso de estorno.
		EndIf

		lMsErroAuto := .F.
		lMsHelpAuto := .T.

		MSExecAuto({|x, y| FINA050(x, y)}, aAbatimento, 3)
		If lMsErroAuto
			lOk := .F.
			MostraErro()
		EndIf
	EndIf

	//Recuperar as areas
	RestArea(aArea)

Return lOk
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FGerTaxaCR³ Autor ³ Rodrigo Gimenes       ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera  titulo de abatimento no Contas a Receber - Austrália  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FGerTaxaCR(cPrefixo, cTitulo, cParcela, cTipoDoc, cClient,  ³±±
±±³          ³cLoja, nValAbat, cTipoRet, cTpAbt,dVencto,cOrig) 			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico  - Austrália                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FGerTaxaCR(cPrefixo, cTitulo, cParcela, cTipoDoc, cClient, cLoja, nValAbat, cTipoRet, cTpAbt,dVencto,cOrig,cNatur)

	LOCAL aArea			:= GetArea()
	LOCAL aAreaSE1		:= SE1->(GetArea())
	LOCAL aAbatimento	:= {}
	LOCAL aDadosTit 	:= {}
	LOCAL lOk 			:= .T.
	Local cSE1Filter 	:= ""
	Local cParcTx		:= cParcela
	Local nTemp 		:= 0
	Default dVencto 	:= CTOD("//")
	Default cOrig 		:= "FINA040"

	//Posicionar no Titulo original (SE1)
	DbSelectArea("SE1")
	SE1->(dbSetOrder(1))
	If !SE1->(dbSeek(xFilial("SE1")+cPrefixo+cTitulo+cParcela+cTipoDoc+cClient+cLoja))
		Help(" ",1, STR0001     ,, STR0002      , 4,0)  //"Titulo " "Titulo não encontrado  "
		Return .F.
	EndIf

	//Verificar se valor do abatimento é maior ou igual que o titulo original
	If nValAbat > SE1->E1_VALOR
		Help(" ",1, STR0003     ,, STR0004      , 4,0)  // "Valor a Abater " "Valor a Abater maior que o valor do titulo  "
		Return .F.
	EndIf

	//Verificar se existe saldo no titulo original
	If (nValAbat > SE1->E1_SALDO .and. !Empty(SE1->E1_BAIXA)) .or.   SE1->E1_SALDO == 0
		Help(" ",1, STR0001     ,, STR0005       , 4,0)  //"Titulo ""Titulo Sem Saldo a Abater "
		Return .F.
	EndIf

	//Evitar duplicates
	aAreaSE1   := SE1->(GetArea())
	If !Empty(SE1->(DbFilter()))
		cSE1Filter := SE1->(DbFilter())
		DbselectArea("SE1")
		Set Filter To
	EndIf

	//Verifica se já existe o título, e vai trocando a parcela
	SE1->(dbSetOrder(1))
	If SE1->(dbSeek(xFilial("SE1")+cPrefixo+cTitulo+cParcTx+cTpAbt+cClient+cLoja))
		While !SE1->(EOF()) .And. (cPrefixo+cTitulo+cParcTx+cTpAbt+cClient+cClient	) == SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
			nTemp++
			cParcTx := cValToChar(nTemp)
			SE1->(DbSkip())
		EndDo
	EndIf
	If !Empty(cSE1Filter)
		DbselectArea("SE1")
		Set Filter To &cSE1Filter
	EndIf
	RestArea(aAreaSE1)

	//Guarda dados do titulo principal
	aDadosTit := {SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, SE1->E1_CLIENTE,;
	SE1->E1_LOJA, SE1->E1_VALOR, SE1->E1_VENCTO, SE1->E1_HIST, SE1->E1_EMISSAO,  SE1->E1_MOEDA }

	If (Alltrim(cTipoDoc) = "NF" .OR. "ND"$ Alltrim(cTipoDoc)).and. nValAbat > 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gerar Título de Abatimento de Retenção (TIPO="IV-" ou "IR-")                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAbatimento := {}
		AADD(aAbatimento , {"E1_PREFIXO", 		aDadosTit[1]            									, NIL})
		AADD(aAbatimento , {"E1_NUM"    , 	   	aDadosTit[2]			    								, NIL})
		AADD(aAbatimento , {"E1_PARCELA",		cParcTx		            									, NIL})
		AADD(aAbatimento , {"E1_TIPO"   , 		cTpAbt	         											, NIL})
		AADD(aAbatimento , {"E1_CLIENTE", 		aDadosTit[6]            									, NIL})
		AADD(aAbatimento , {"E1_LOJA"   , 		aDadosTit[7]            									, NIL})
		AADD(aAbatimento , {"E1_VALOR"  , 		nValAbat             										, NIL})
		AADD(aAbatimento , {"E1_VLCRUZ" , 		nValAbat             										, NIL})
		AADD(aAbatimento , {"E1_NATUREZ", 		cNatur					 									, NIL})
		AADD(aAbatimento , {"E1_EMISSAO", 		aDadosTit[11]           									, NIL})
		AADD(aAbatimento , {"E1_VENCTO" , 		dVencto														, NIL})
		AADD(aAbatimento , {"E1_VENCREA", 		dVencto														, NIL})
		AADD(aAbatimento , {"E1_VENCORI", 		dVencto														, NIL})
		AADD(aAbatimento , {"E1_EMIS1"  , 		dDataBase               									, NIL})
		AADD(aAbatimento , {"E1_MOEDA"  , 		aDadosTit[12]       										, NIL})
		AADD(aAbatimento , {"E1_HIST"   , 		Iif(cTipoRet == "I",STR0006,STR0007	)						, NIL}) //"Abatimento de Retenção " "Retenção de Taxas"
		AADD(aAbatimento , {"E1_ORIGEM" , 		cOrig	             										, NIL})

		lMsErroAuto := .F.
		lMsHelpAuto := .T.

		MSExecAuto({|x, y| FINA040(x, y)}, aAbatimento, 3)
		If lMsErroAuto
			lOk := .F.
			MostraErro()
		EndIf
	EndIf

	//Recuperar as areas
	RestArea(aAreaSE1)
	RestArea(aArea)

Return lOk

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ FaRecImp ³ Autor ³ Rodrigo Gimenes       ³ Data ³ 28/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica os impostos retidos de um título				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FaRecImp()      							                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor Irrf          								  ³±±
±±³			 ³ ExpN2 = Base Irrf                                          ³±±
±±³			 ³ ExpA1 = Dados dos titulos retidos nesta baixa              ³±±
±±³			 ³ ExpC1 = Sequencia da baixa                          		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³                                                            ³±±
±±³			 ³                                                   		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FaRecImp(cFili,cCarteira,cPrefixo, cNumero,cCliFor, cLoja,cTipoRet,cNat,cFatGer)

	Local aArea		:= GetArea()
	Local aAreaSE1 	:= {}
	Local aAreaSE2 	:= {}
	Local aRet		:= {}
	Local aImpRet	:= {}
	Local cFornTx	:= ""
	Local cLojaTx	:= ""
	Local aImps		:= ""
	Local nImps		:= 0
	Default cTipoRet := ""

	aImps := FaImpSeq(cCarteira,cNat,cFatGer)

	nVlImp := 0
	For nImps := 1 To Len(aImps)
		If cCarteira == "1"

			aAreaSE2 := SE2->(GetArea())
			If Empty(cTipoRet)
				cTipoRet := FaAplica(cNat,aImps[nImps][1],aImps[nImps][2],cCarteira)
			EndIf
			cFornTx	:= Iif(cTipoRet == "I",FaIncForn(),cCliFor)
			cLojaTx	:= Iif(cTipoRet == "I","00",cLoja)
			DbSelectArea("SE2")
			SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			SE2->(dbSeek(cFili+cPrefixo+cNumero))
			While !SE2->(Eof( )) .And. SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM)  == (cFili + cPrefixo + cNumero)
				If SE2->(E2_FORNECE+E2_LOJA) ==  (cFornTx + cLojaTx)
					aImpRet := {} 								//Limpa o array de detalhes
					AAdd(aImpRet,SE2->E2_FILIAL)				//Filial
					AAdd(aImpRet,SE2->E2_PREFIXO)				//Prefixo
					AAdd(aImpRet,SE2->E2_NUM)					//Número
					AAdd(aImpRet,SE2->E2_PARCELA)				//Parcela
					AAdd(aImpRet,SE2->E2_TIPO)					//Tipo
					AAdd(aImpRet,SE2->E2_FORNECE)				//Fornecedor
					AAdd(aImpRet,SE2->E2_LOJA) 					//Loja
					If SE2->E2_SALDO == 0
						AAdd(aImpRet,'1') // Baixado Totalmente	//Status
					ElseIf SE2->E2_SALDO < SE2->E2_VALOR		//Status
						AAdd(aImpRet,'3') 	//Baixado Parcialmente
					Else										//Status
						AAdd(aImpRet,'2') // Em aberto
					EndIf
					AAdd(aImpRet,SE2->E2_VALOR)				 		//Valor
					AAdd(aRet,aImpRet) 							//Enche o Array com os dados de cada imposto
				EndIf
				SE2->(dbSkip())
			Enddo
			RestArea(aAreaSE2)
		ElseIf cCarteira == "2"
			aAreaSE1 := SE1->(GetArea())
			DbSelectArea("SE1")
			SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_FORNECE+E1_LOJA
			SE1->(dbSeek(cFilial+cPrefixo+cNumero))
			While !SE1->(Eof( )) .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_CLIENTE+E1_LOJA) == cFili + cPrefixo + cNumero + cCliFor + cLoja
				aImpRet := {} 								//Limpa o array de detalhes
				AAdd(aImpRet,SE1->E1_FILIAL)				//Filial
				AAdd(aImpRet,SE1->E1_PREFIXO)				//Prefixo
				AAdd(aImpRet,SE1->E1_NUM)					//Número
				AAdd(aImpRet,SE1->E1_PARCELA)				//Parcela
				AAdd(aImpRet,SE1->E1_TIPO)					//Tipo
				AAdd(aImpRet,SE1->E1_CLIENTE)				//Cliente
				AAdd(aImpRet,SE1->E1_LOJA) 					//Loja
				AAdd(aImpRet,IIF(SE1->E1_SALDO ==0,1,2)) 	//Status
				AAdd(aImpRet,SE1->E1_VALOR)				 	//Valor
				AAdd(aRet,aImpRet) 							//Enche o Array com os dados de cada imposto
				SE1->(dbSkip())
			Enddo
			RestArea(aAreaSE1)
		EndIf
	Next

	RestArea(aArea)
Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FaAplica  ºAutor  ³Rodrigo Gimenes	 º Data ³  29/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Identifica se é imposto ou retenção                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINXIMP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FaAplica(cNatureza,cImposto,cSeq,cCarteira)

	Local aArea 	:= GetArea()
	Local cAplica 	:= " "

	DbSelectArea("FRN")
	FRN->( DbSetOrder(2) )
	If 	FRN->( DbSeek( xFilial("FRN") + cNatureza) )//FRN_FILIAL+FRN_CODNAT+FRN_SEQ+FRN_IMPOST+FRN_ITEM
		While 	!FRN->( Eof() ) .And. FRN->(xFilial("FRN") + FRN_CODNAT) 	== 	xFilial('FRN') 	+ cNatureza
			If 	FRN->FRN_MSBLQL	<>	'1' .And. (FRN_IMPOST+FRN_SEQ) ==  (cImposto + cSeq)
				DbSelectArea("FRM")
				FRM->( DbSetOrder(2) )
				FRM->( dbSeek(xFilial("FRM") + FRN->FRN_IMPOST + FRN->FRN_SEQ ) )
				While 	!FRM->( Eof() ) .And. FRM->(xFilial("FRM") + FRM->FRM_COD + FRM->FRM_SEQ) 	== 	xFilial('FRM') 	+ FRN->FRN_IMPOST + FRN->FRN_SEQ
					If 	FRM->FRM_CARTEI	$ (cCarteira+"|3")
						cAplica	:= IIF(ALLTRIM(FRM->FRM_APLICA) == "1","I","R")
						Exit
					EndIf
					FRM->( DbSkip() )
				EndDo
			EndIf
			If 	cAplica	<> " "
				Exit
			EndIf
			FRN->( DbSkip() )
		EndDo
	EndIf

	RestArea(aArea)

Return cAplica


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FaIncNat  ºAutor  ³	Rodrigo Gimenes  º Data ³  05/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclui ou retorna o código da natureza para o imposto       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FaIncNat(cCarteira,cImposto)

	Local aArea		:= GetArea()
	Local aAreaSED	:= SED->(GetArea())
	Local cCodigo	:= cImposto

	DbSelectarea("SED")
	SED->( dbSetOrder(1) ) //ED_FILIAL+ED_CODIGO
	If !SED->( dbSeek(xFilial("SED") + cCodigo) ) //Se não existir a natureza, cria
		Reclock("SED",.T.)
		SED->ED_FILIAL 	:= xFilial("SED")
		SED->ED_CODIGO 	:= cCodigo
		SED->ED_DESCRIC	:= cCodigo
		SED->ED_USO		:= cCarteira
		SED->ED_TIPO	:= "2"
		MsUnlock()
	Else
		cCodigo := SED->ED_CODIGO
	EndIf

	RestArea(aAreaSED)
	RestArea(aArea)

Return(cCodigo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FaImpSeq  ºAutor  ³	Rodrigo Gimenes  º Data ³  11/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a alíquota e a redução, se houver,do Imposto        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FaImpSeq(cCarteira,cNatur,cFatGer)

	Local aArea 	:= GetArea()
	Local aAreaFRN  := FRN->(GetArea())
	Local aAreaFRM  := FRM->(GetArea())
	Local aRet		:= {}

	DbSelectArea("FRN")
	FRN->( DbSetOrder(2) )
	FRN->( DbSeek(xFilial("FRN") + cNatur ) )
	While !FRN->(EOF()) .And. FRN->FRN_CODNAT == cNatur
		DbSelectArea("FRM")
		FRM->( DbSetOrder(2) )
		If FRM->( dbSeek(xFilial("FRM") + FRN->FRN_IMPOST + FRN->FRN_SEQ  ) )
			If cCarteira == FRM->FRM_CARTEI .And. cFatGer == FRM->FRM_FATGER
				AADD(aRet,{FRM->FRM_COD,FRN->FRN_SEQ})
			EndIf
		EndIf
		FRN->(DbSkip())
	EndDo

	RestArea(aAreaFRN)
	RestArea(aAreaFRM)
	RestArea(aArea)

Return aRet


/*
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

			Funcoes retiradas do arquivo FINXATU.PRX

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
*/

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINPROCITF

Funcao que avalia a gravacao do imposto ITF ( Peru ) .
Arquivo anterior: FINXATU.PRX

@Author	Wellingtonm A. Santos
@since	12/11/2009
/*/
//-----------------------------------------------------------------------------------------------------
Function FinProcITF( nRecnoSE5,nOpc,nBaseITF, lHeadPrv,aHdlPrv, aFlagCTB, cBuscaMod , aRecnoITF , cNumPRC)
	Local lRet       := .F.
	
	If cPaisLoc = "BRA"
		lRet := .T.
	Else
		If FindFunction("FINCALITF")
			lRet:=FINCALITF( nRecnoSE5,nOpc,nBaseITF, lHeadPrv,aHdlPrv, aFlagCTB, cBuscaMod , aRecnoITF , cNumPRC)
		Else
			MsgAlert(STR0053, STR0054) //"El fuente del calculo de TF esta desactualizado - FINXFUMI", "ITF Desactualizado"
		EndIf
	EndIf
Return(lRet)

/*
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

			Funcoes retiradas do arquivo FINXFUN.PRX

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
*/

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FCAIRBXCR

Calcular o IR na baixa para cliente PJ e empresas publicas ou mistas.
Arquivo anterior: FINXFUN.PRX

@Author	Pâmela Bernardo
@since	03/02/2012
@param nBaseTit - Normalmente passado nValRec - Valor Recebido pelas rotinas de baixa.

/*/
//-----------------------------------------------------------------------------------------------------
Function FCaIrBxCR(nBaseTit, nRecno, lRecalc, nTxMoeda, lAltValor, dRef , nParc, lPix)
	Local aAreaSED		:= SED->( GetArea() )
	Local aAreaSA1		:= SA1->( GetArea() )
	Local aAreaSE1		:= SE1->( GetArea() )
	Local nValor		:= 0
	// Controla IRPF na Baixa
	Local lIrPjBxCr		:= FIrPjBxCr(.T.)
	Local nBaseSED		:= 1
	Local nImpIRF		:= 0
	Local nAcmIRF		:= 0
	Local aDadosPar		:= Array(3)
	Local nTotImp		:= 0
	Local lJurMulDes	:= (SuperGetMv("MV_IMPBAIX",.t.,"2") == "1")
	Local lBxMnl		:= FwIsInCallStack("FINA070") .Or. FwIsInCallStack("FINA110") 
	Local lFina330		:= FwIsInCallStack("FINA330")
	Local lRndIrrf		:= SuperGetMV("MV_RNDIRRF",,.T.)
	Local n070Abat		:= 0
	Local lAplMinIR		:= SA1->A1_MINIRF == "2"
	Local lIrfRetAnt	:= .F.
	Local lACMIRCR		:= SuperGetMv("MV_ACMIRCR",.t.,"1") == "1"
	Local lMotBxMBco	:= (SuperGetMv("MV_MB10925",.t.,"2") == "1")	// 1 = Somente os motivos que geram movimento bancario, 2 = Considera todos os motivos de baixa.
	Local nValMin		:= 0
	Local cEdCodRet		:= ""
	Local nIrAnt		:= 0 
	Local lIsBxTotal	:= .F.	// Define se a baixa que está sendo realizada irá baixar totalmente o título
	Local cChaveTit		:=""
	Local nValIrBx		:=0
	Local nIRTotal		:=0
	Local nMV_ALIQIRF	:=SuperGetMV("MV_ALIQIRF",,3)

	DEFAULT nBaseTit	:= 0	// Passado nValRec pelas rotinas
	DEFAULT nRecno		:= SE1->( Recno() )
	DEFAULT lRecalc     := .F.
	DEFAULT nTxMoeda    := If(SE1->E1_MOEDA > 1, If(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA,RecMoeda(dBaixa,SE1->E1_MOEDA)),0)
	DEFAULT lAltValor	:= .F.
	DEFAULT dRef		:= dDataBase
	Default nParc		:= IIF(Type("nParciais") != "N", 0, nParciais)
	Default lPix        := .F.

	If FunName() == "FINA070"
		n070Abat := nTotAbLiq
	Endif
	If Type("lF070Auto")=="U"
		lF070Auto := .F.
	Endif

	If Type("dBaixa")=="U"
		dBaixa := dDataBase
	Endif

	If Type("cMotBx")=="U"
		cMotBx := ""
	EndIf

	//MV_MB10925 = 1, Não Gera movimento Bancario e IR na Baixa
	//Não deve reter imposto de IR
	if !Empty(cMotBx)
		if(lMotBxMBco .And. !MovBcoBx(cMotBx,.T.) .and. lIrPjBxCr .and. (cMotBx <> "CMP"))
			Return nValor
		EndIf
	EndIf

	SE1->(dbGoto(nRecno))

	dbSelectArea("SED")
	dbSetOrder(1)
	msSeek(xFilial("SED")+SE1->E1_NATUREZ)
	If lIrPjBxCr .AND. SED->ED_CALCIRF == "S"

		If SED->ED_BASEIRF > 0
			nBaseSED := SED->ED_BASEIRF / 100
		Endif

		cEdCodRet	:= SED->ED_CODRET 

		nTotImp := nBaseTit

		If lFina330
			nIRFBase :=  0
			If SE1->E1_VALOR == SE1->E1_SALDO
				nParc := 0
			EndIf
		Endif

		// Base do IMPOSTO
		If SE1->E1_BASEIRF > 0
	
			/*
				A intenção desse trecho é avaliar pelo valor passado:
				- Se o valor vai baixar Totalmente o título -> considerar E1_BASEIR - Parciais
				- Ou se o valor não vai baixar totalmente -> considerar o valor passado (nValRec) - Valor Recebido
			*/
			lIsBxTotal := IIf(lPix, .F., FxIsBxTotal(nBaseTit, nParc))
			
			If lIsBxTotal
				nBaseTit	:= SE1->E1_BASEIRF - nParc
				If nBaseTit < 0
					nBaseTit := 0
				EndIf
			Else
				nBaseTit	:= nBaseTit
			EndIf
		ElseIf SE1->E1_BASEIRF = 0
			nBaseTit := 0
		EndIf

		If lBxMnl
			If lJurMulDes
				nBaseTit:= nBaseTit-nDescont+nJuros+nMulta+nAcresc-nDecresc
			Endif
		Endif

		nBaseTit := nBaseTit  * nBaseSED

		If lFina330
			nIRFBase +=  nBaseTit
		EndiF

		If AllTrim(SE1->E1_ORIGEM) == "MATA460" .and. SA1->A1_ALIQIR > 0 .and. lIrPjBxCr
			If lRndIrrf
				nTotImp 	:= Round((nBaseTit * (SA1->A1_ALIQIR / 100)),2)
			Else
				nTotImp 	:= NoRound((nBaseTit * (SA1->A1_ALIQIR / 100)),2)
			EndIf
		Else
			If lRndIrrf
				nTotImp 	:= Round((nBaseTit * IIF(SED->ED_PERCIRF > 0, SED->ED_PERCIRF, nMV_ALIQIRF) / 100),2)
			Else
				nTotImp 	:= NoRound((nBaseTit * IIF(SED->ED_PERCIRF > 0, SED->ED_PERCIRF, nMV_ALIQIRF) / 100),2)
			EndIf
		EndIf

		nIrfBaseC	:= nBaseTit
		nIrfBaseR	:= nBaseTit
		nIrfCalc	:= nTotImp

		// Ver cumulatividade de IRPJ
		If lACMIRCR
			aDadosPar := SumDayIRPJ("R",SE1->E1_FILIAL,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_TIPO,dRef,SE1->E1_FILORIG, cEdCodRet)
			nAcmIRF += aDadosPar[1] // IRRF
			nIrAnt	:= aDadosPar[3]
		EndIf

		//Aplica valores já retidos e cumulatividade.
		nValor := nTotImp - nImpIRF + nAcmIRF

	EndIf

	If lRndIrrf //Trunco o valor de IRRF conforme o parâmetro MV_RNDIRRF (.F.) ou arredondo (.T.)
		nValor := Round(nValor,TamSX3("E1_IRRF")[2])
	Else
		nValor := NoRound(nValor,TamSX3("E1_IRRF")[2])
	EndIf

	If nIrAnt > 0
		nValMin := nValor + nIrAnt
	Else
		nValMin := nValor
	EndIf

	//Controle de retencao anterior no mesmo periodo
	lIrfRetAnt := IIF(nValMin > SuperGetMv("MV_VLRETIR",,10), .T., .F.)

	If lAplMinIR .and. !lIrfRetAnt .and. lIrPjBxCr
		nValor := 0
		aTitCIrf := {}
	Endif

	// Verifica valores ja retidos nas baixas anteriores
	If  lIrPjBxCr .And. nValor>0 .And. nParc>0
		cChaveTit	:= SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA
		nValIrBx	:= SumBxIRPJ(cChaveTit,cEdCodRet)

		If nValIrBx>0 // Houve retenções nas baixas parciais anteriores
			nIRTotal:= (nBaseTit+nParc) //Valor base original
			If lRndIrrf
				nIRTotal:= Round((nIRTotal * IIF(SED->ED_PERCIRF > 0, SED->ED_PERCIRF, nMV_ALIQIRF) / 100),2)
			Else
				nIRTotal:= NoRound((nIRTotal * IIF(SED->ED_PERCIRF > 0, SED->ED_PERCIRF, nMV_ALIQIRF) / 100),2)
			EndIf

			// Valor ja retido + valor que esta retendo ultrapassa o valor total de retenção
			If (nValIrBx + nValor) > nIRTotal				
				//Corrije valor para que nao ultrapasse o total da retenção
				nValor	:= IIf(nValIrBx<nIRTotal , nIRTotal-nValIrBx , 0)
				nIrfCalc:= IIf(nValIrBx<nIRTotal , nIRTotal-nValIrBx , 0)
			EndIf			
		EndIF
	ENDIF

	RestArea(aAreaSED)
	RestArea(aAreaSA1)
	RestArea(aAreaSE1)

Return (nValor)


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FCALCIRBX

Retorna o valor do Calculo do IRRF na baixa.
Arquivo anterior: FINXFUN.PRX

Parametros:
nBaseTit  = Base do IR a ser aplicada no calculo
cTipo     = Tipo do Fornecedor (J=Pessoa Juridica / F=Pessoa Fisica)
dBaixa    = Data da baixa
dDebito   = Data de disponibilizacao
lAltValor = Ativa controle de baixa parcial
nTxmoeda  = Taxa da moeda
cMotBx    = Motivo de baixa
aRatIRF   = Informações de rateio por CPF (IR tab. progressiva de aluguel)
lRegra    = Ativa o calculo considerando o complemento de imposto (Desativar para achar valor original)
lMin      = Determina se o valor calculado do IR sera zerado quando for menor que o minimo de retencao

@Author	Mauricio Pequim Jr.
@since	29/08/2011
/*/
//-----------------------------------------------------------------------------------------------------
Function FCalcIrBx( nBaseTit As Numeric, cTipo As Character, dBaixa As Date, dDebito As Date,;
					lAltValor As Logical, nTxmoeda As Numeric, cMotBx As Character, aRatIRF As Array,;
					lRegra As Logical, lMin As Logical) As Numeric
	Local aArea			As Array
	Local aAreaSA2		As Array
	Local aAreaSED  	As Array
	Local nTotTit		As Numeric
	Local nTotInss		As Numeric
	Local nValor		As Numeric
	Local nInsAux		As Numeric
	Local nRecOld		As Numeric
	Local lSumBsIns		As Logical
	
	// Carrega variavel de verificacao de consideracao de valor minimo de retencao de IR.
	Local lAplMinIR 	As Logical
	Local cVenctoPF 	As Character//1 = Emissao    2= Vencimento Real	3=Data Contabilizacao
	Local cVenctoPJ 	As Character//1 = Emissao    2= Vencimento Real	3=Data Contabilizacao
	Local lVencto	 	As Logical
	Local lCalcIr	 	As Logical

	//Controla o Pis Cofins e Csll na baixa
	Local lPCCBaixa 	As Logical

	// Controla IRPF na Baixa
	Local lIRPFBaixa 	As Logical
						
	Local lCalcIssBx 	As Logical
						
	Local lVretIrf		As Logical
	Local nTotRtIr		As Numeric
	Local nRecAtu		As Numeric
	Local nBaseDep		As Numeric
	Local cAglImPJ		As Character
	Local aFilial		As Array
	Local aCliFor		As Array
	Local cQuery		As Character
	Local nLoop			As Numeric
	Local nBaseSED		As Numeric
	Local cFornece		As Character
	Local cLoja			As Character
	Local cArqTMP		As Character
	Local bSA2Compart	As Codeblock
	Local bSE2Compart 	As Codeblock
	Local bSE5Compart	As Codeblock
	Local lGestao		As Logical
	Local aRecnoSE5		As Array
	Local aRecnoSE2		As Array
	Local nBaseIrrf		As Numeric
	Local nProp			As Numeric
	Local lBpParc		As Logical
	Local lPropComp		As Logical
	Local lDelTrbIR		As Logical
	Local aStru			As Array
	Local cSepNeg		As Character
	Local cSepProv		As Character
	Local cSepRec		As Character
	Local nX 			As Numeric
	Local dDataInic  	As Date
	Local dDataFina  	As Date
	Local cKeySE5		As Character
	Local cKeySE5Old	As Character
	Local lBxMnl		As Logical
	Local lInclPA       As Logical
	Local lDedINS		As Logical
	Local lOri241 		As Logical
	Local nTotInCar		As Numeric
	Local lBaseDif		As Logical
	Local lBaseCar		As Logical
	Local lFINXCALCIR 	As Logical
	Local lJurMulDes 	As Logical
	Local nTotCalcIr	As Numeric
	Local lRndIRF 		As Logical
	Local nIRRet		As Numeric
	Local cAcmIrrf		As Character
	Local nK			As Numeric
	Local lEmpPub		As Logical
	Local dDataAtu	 	As Date
	Local dBaixaIni	   	As Date
	Local dBaixaFim	   	As Date
	Local dDebtIni		As Date
	Local dDebtFim		As Date
	Local dDebtAtu 		As Date
	Local cVencPub		As Character
	Local nBaseCmp		As Numeric
	Local nPosic		As Numeric
	Local nAliqIrf		As Numeric
	Local nVlMinIr		As Numeric
	Local lBordBx		As Logical
	// Considera baixas que geram ou nao movimento bancario, Default = 2
	// 1 = Somente os motivos que geram movimento bancario, 2 = Considera todos os motivos de baixa.
	Local lMotBxMBco 	As Logical
	Local lTemDscDep 	As Logical
	Local nMultaDia		As Numeric
	Local nDescDia		As Numeric
	Local nJurosDia		As Numeric
	Local cCodRet 		As Character
	Local nVlMPub	    As Numeric
	Local nRecSE2		As Numeric
	Local cChvSE2		As Character

	// Complemento do Imposto
	Local nDedBase 		As Numeric
	Local nDedValor     As Numeric
	Local nPropBase		As Numeric
	Local nPropValor	As Numeric
	Local l986Imp       As Logical
	Local l986Base      As Logical
	Local nAuxJur		As Numeric
	Local nCasDec       As Numeric
	Local l050IncAlt    As Logical
	Local oRatIRF		As Object
	
	Local nBasPdtDia	As Numeric
	Local nBaseBxDia	As Numeric
	Local nBaseBxExt	As Numeric
	Local nAcresBx		As Numeric
	Local nDescresBx	As Numeric
	Local lAcumIr		As Logical
	Local lAcumComPE	As Logical
	Local lNoAcComPE	As Logical
	Local lAcumSemPE	As Logical
	Local lNoAcParam	As Logical


	aArea		:= GetArea()
	aAreaSA2	:= SA2->( GetArea() )
	aAreaSED  	:= {}
	nTotTit		:= 0
	nTotInss	:= 0
	nValor		:= 0
	nInsAux		:= 0
	nRecOld		:= 0
	lSumBsIns	:= .F.
	nAuxJur		:= 0
	nCasDec     := TamSx3("E2_TXMOEDA")[2]
	l050IncAlt	:= (FwIsInCallStack("FA050Inclu") .or. FwIsInCallStack("FA050Alter"))
	
	// Carrega variavel de verificacao de consideracao de valor minimo de retencao de IR.
	lAplMinIR 	:= .F.
	cVenctoPF 	:= SuperGetMv("MV_ACMIRPF",.T.,"3")  //1 = Emissao    2= Vencimento Real	3=Data Contabilizacao
	cVenctoPJ 	:= SuperGetMv("MV_ACMIRPJ",.T.,"3")  //1 = Emissao    2= Vencimento Real	3=Data Contabilizacao
	lVencto	 	:= .F.
	lCalcIr	 	:= .F.

	//Controla o Pis Cofins e Csll na baixa
	lPCCBaixa 	:= SuperGetMv("MV_BX10925",.T.,"2") == "1"

	// Controla IRPF na Baixa
	lIRPFBaixa 	:= cPaisLoc == "BRA" .And. SA2->A2_CALCIRF == "2"

	lCalcIssBx 	:= IIF(lIsIssBx, IsIssBx("P"), SuperGetMv("MV_MRETISS",.F.,"1") == "2" )

	lVretIrf	:= .T.
	nTotRtIr	:= 0
	nRecAtu		:= 0
	nBaseDep	:= GetMV("MV_TMSVDEP",,0)
	cAglImPJ	:= SuperGetMv("MV_AGLIMPJ",.T.,"1")
	aFilial		:= {}
	aCliFor		:= {}
	cQuery		:= ""
	nLoop		:= 0
	nBaseSED	:= 1
	cFornece	:= ""
	cLoja		:= ""
	cArqTMP		:= ""
	bSA2Compart	:= { || Empty(xFilial("SA2")) }
	bSE2Compart := { ||  Empty(FWFilial("SE2")) }
	bSE5Compart	:= { || Empty(xFilial("SE5")) }
	lGestao		:= TamSx3("E5_FILIAL")[1] > 2
	aRecnoSE5	:= {}
	aRecnoSE2	:= {}
	nBaseIrrf	:= 0
	nProp		:= 0
	lBpParc		:= .F.
	lPropComp	:= .F.
	lDelTrbIR	:= .T.
	aStru		:= SE2->(dbStruct())
	cSepNeg		:= If("|"$MV_CPNEG,"|",",")
	cSepProv	:= If("|"$MVPROVIS,"|",",")
	cSepRec		:= If("|"$MVPAGANT,"|",",")
	nX 			:= 0
	dDataInic  	:= FirstDay(dDatabase)
	dDataFina  	:= LastDay(dDatabase)
	cKeySE5		:= ""
	cKeySE5Old	:= ""
	lBxMnl		:= IsInCallStack("FINA080")
	lInclPA     := IsInCallStack("FINA050") .AND. M->E2_TIPO $ MVPAGANT
	lDedINS		:=(SuperGetMv("MV_INSIRF",.F.,"2") == "1" .And. cTipo != "J")
	lOri241 	:= FUNNAME()=="FINA241".and. cTipo == "F".and.lPCCBaixa .AND. (SE2->E2_SALDO+SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL)==SE2->E2_VALOR
	nTotInCar	:= 0
	lBaseDif	:= .T.
	lBaseCar	:= .T.
	lFINXCALCIR := Existblock("FINXCALCIR")
	lJurMulDes 	:= (SuperGetMv("MV_IMPBAIX",.t.,"2") == "1")
	nTotCalcIr	:= 0
	lRndIRF 	:= SuperGetMv("MV_RNDIRF",.T., .F.)
	nIRRet		:= 0
	cAcmIrrf	:= SuperGetMv("MV_ACMIRRF",.T.,"1")  //1 = Acumula    2= Não acumula  CONTAS A PAGAR
	nK			:= 0
	lEmpPub		:= IsEmpPub() .And.  lIRPFBaixa
	dDataAtu	:= dDataBase
	dBaixaIni	:= dDataBase
	dBaixaFim	:= dDataBase
	dDebtIni	:= dDataBase
	dDebtFim	:= dDataBase
	dDebtAtu 	:= dDataBase
	cVencPub	:= SuperGetMV("MV_VENPUB", .F., "M")
	nBaseCmp	:= 0
	nPosic		:= 0
	nAliqIrf	:= SuperGetMV("MV_ALIQIRF",,3)
	nVlMinIr	:= SuperGetMV("MV_VLRETIR",,10)
	lBordBx		:= FwIsInCallStack("F241Impost") .or. FwIsInCallStack("FA241Borde") .or. FwIsInCallStack("fA091Aut") .or. FwIsInCallStack("fA090Aut")
	// Considera baixas que geram ou nao movimento bancario, Default = 2
	// 1 = Somente os motivos que geram movimento bancario, 2 = Considera todos os motivos de baixa.
	lMotBxMBco 	:= (SuperGetMv("MV_MB10925",.t.,"2") == "1")
	lTemDscDep := .F.
	nMultaDia	:= 0
	nDescDia	:= 0
	nJurosDia	:= 0   
	cCodRet 	:= ""
	nVlMPub	    := SuperGetMv("MV_VLMPUB",.T.,10)
	nRecSE2		:= 0
	cChvSE2		:= ""

	// Complemento do Imposto
	nDedBase 	:= 0
	nDedValor   := 0
	nPropBase	:= 1
	nPropValor	:= 1
	l986Imp     := Fa986regra("SE2","IRF","2") <> 0
	l986Base    := Fa986regra("SE2","IRF","1") <> 0
	lAcumIr		:= ExistBlock("F050CALIR")

	DEFAULT nBaseTit	:= 0
	DEFAULT cTipo		:= "F" // Pessoa Fisica
	DEFAULT dBaixa		:= dDatabase
	DEFAULT dDebito		:= dDatabase
	DEFAULT lAltValor	:= .F.
	DEFAULT nTxmoeda	:= FVerTxMoed(dBaixa) 
	DEFAULT	cMotBx		:= ""
	DEFAULT aRatIRF		:= {} // Informações de Rateio p/ CPF - IR Progressivo
	DEFAULT lRegra      := .T. //Define se ao calcular o IR, se ira considerar as regras da rotina Complemento de Impostos
	DEFAULT lMin        := .T.

	If Type ("nJuros") == "U"
		nJuros := 0
	Endif
	If Type ("nMulta") == "U"
		nMulta := 0
	Endif

	If Type ("nDescont") == "U"
		nDescont := 0
	Endif

	If Type("nMoedaBco") == "U"
		nMoedaBco := 1
	EndIf

	If Type ("nDecresc") == "U"
		nDecresc := 0
	Endif

	If Type ("nAcresc") == "U"
		nAcresc := 0
	Endif


	nOldTxMoed     := If( Type("nOldTxMoed") != "N", nTxMoeda, nOldTxMoed )

	aDadosIr := Array(3)
	aFill(aDadosIr,0)

	//MV_MB10925 = 1, Não Gera movimento Bancario e IR na Baixa
	//Não deve reter imposto de IR
	if !Empty(cMotBx)
		if(lMotBxMBco .And. !MovBcoBx(cMotBx,.T.) .and. lIRPFBaixa .and. (cMotBx <> "CMP"))
			Return nValor
		EndIf
	EndIf

	If l050IncAlt
		cFornece	:= M->E2_FORNECE
		cLoja		:= M->E2_LOJA
		cCodRet		:= M->E2_CODRET
	Else
		cFornece	:= SE2->E2_FORNECE
		cLoja		:= SE2->E2_LOJA
		cCodRet		:= SE2->E2_CODRET
	EndIf

	If cAcmIrrf <> "1" .And. lEmpPub .And. lIRPFBaixa .and. nVlMPub > 0
		cAcmIrrf	:= "1"
	EndIf

	// Fornecedor Estrangeiro | SA2->A2_TIPO = X-Outros
	If cPaisLoc == "BRA" .And. cTipo == "X"
		cTipo		:= "J"
	EndIf

	If lEmpPub
		If SuperGetMV("MV_IN4815", .F., "S") == "S"
			dDataAtu := dBaixa
			For nK:=1 To 7
				If Dow(dDataAtu ) == 7
					Exit
				EndIf
				dDataAtu++
			Next nK
			dBaixaIni := dDataAtu-7
			dBaixaFim := dDataAtu

			dDebtAtu := dDebito
			For nK:=1 To 7
				If Dow(dDebtAtu ) == 7
					Exit
				EndIf
				dDebtAtu++
			Next nK
			dDebtIni := dDataAtu-7
			dDebtFim := dDebtAtu
		EndIf
		If lIRPFBaixa .And. lPCCBaixa
			If cVencPub == "D"
				dBaixaIni := dBaixaFim := dDebtIni := dDebtFim :=  dBaixa
			ElseIf cVencPub == "M"
				dBaixaIni := dDebtIni := FirstDay(dBaixa)
				dBaixaFim := dDebtFim := LastDay(dBaixa)
			EndIF
		EndIF
	EndIF

	//IRRF Progressivo para pessoas jurídicas, o cálculo deve ser executado igual ao cálculo de pessoa física
	If lIRPFBaixa .AND. ( cTipo == "F" .OR. (cTipo == "J" .And. Posicione( "SA2" , 1 , xFilial("SA2") + cFornece + cLoja , "A2_IRPROG" ) == "1") )
		cTipo   := "F"
		lDedINS := (SuperGetMv("MV_INSIRF",.F.,"2") == "1" .And. cTipo != "J")
		lOri241 := FUNNAME()=="FINA241".and. cTipo == "F".and.lPCCBaixa .AND. (SE2->E2_SALDO+SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL)==SE2->E2_VALOR
		oRatIRF := FCriaRatIR()	
	EndIf
	RestArea(aAreaSA2)
	//Se for Gestao utilizo outra funcao para verificar filial compartilhada
	If lGestao
		bSA2Compart := { ||  Empty(FWFilial("SA2")) }
		bSE2Compart := { ||  Empty(FWFilial("SE2")) }
		bSE5Compart := { ||  Empty(FWFilial("SE5")) }
	Endif
	//Baixas Parciais - O valor do título é informado como parametro para a função - Calculo de Base Reduzida PF
	If nBaseTit > 0
		lBpParc := .T.
	EndIf

	//Ponto de entrada para verificar se Acumula ou não os valores de IR no calculo
	//Alteracao efetuada para atender a Pinheiro Neto Advogados
	If lAcumIr
		lCalcIr := ExecBlock("F050CALIR",.F.,.F.)
	EndIf

	lAcumComPE := (lAcumIr .And. lCalcIr)
	lNoAcComPE := (lAcumIr .And. !lCalcIr)

	lAcumSemPE := (!lAcumIr .And. (cTipo == "F" .Or. (cTipo == "J" .And. cAcmIrrf == "1")))
	lNoAcParam := (!lAcumIr .And. (cTipo == "J" .And. cAcmIrrf == "2"))

	// Verifica se o fornecedor trata o valor minimo de retencao.
	// 1 - Não considera  2 - Considera o parâmetro MV_VLRETIR
	If SA2->A2_MINIRF == "2"
		lAplMinIR := .T.
	Endif

	nLastDay := Day(LastDay(dDataBase))
	nTamData := IIf(Len(DtoC(dDataBase)) == 10, 7, 5)
	dDataImp := dDataBase
	nRecSE2  := SE2->( Recno() ) // Recno do titulo Principal do calculo.

	If lAcumComPE .Or. lAcumSemPE
	
		//Verifico a combinacao de filiais (SM0) e lojas de fornecedores a serem considerados
		//na montagem da base do IRRF
		If cAglImPJ != "1"
			aRet := FLOJASIRRF("2")
			aFilial := aClone(aRet[1])
			aCliFor := aClone(aRet[2])
			cArqTMP := aRet[3]
		Endif

		cAliasQry := GetNextAlias()
		SE5->(dbCommit())
		SE2->(dbCommit())

		//------------------------------------------------------------------------------------------
		//Tratamento para baixas
		cQuery := "SELECT DISTINCT SE5.E5_FILIAL,SE5.E5_PREFIXO,SE5.E5_NUMERO,SE5.E5_PARCELA,SE5.E5_TIPO,SE5.E5_CLIFOR,SE5.E5_LOJA, "
		cQuery += "SE5.E5_DATA,SE5.E5_DTDISPO,SE5.E5_DTDIGIT,SE5.E5_NATUREZ, SE5.E5_SEQ, SE5.E5_MOTBX,SE5.E5_VLDESCO, SE5.E5_VLJUROS, SE5.E5_VLMULTA, "
		cQuery += "SE5.E5_VRETIRF, SE5.E5_PRETIRF, SE5.E5_BASEIRF, SE5.E5_TXMOEDA, SE5.R_E_C_N_O_ RECNOSE5, "
		cQuery += "SE5.E5_VLDECRE, SE5.E5_VLACRES,SE5.E5_IDORIG, SE5.E5_FILORIG, "
		cQuery += "SE2.E2_INSS, SE2.E2_IRRF, SE2.E2_BASEIRF, SE2.E2_ORIGEM, SE2.R_E_C_N_O_ RECNOSE2 "

		cQuery += "FROM " + RetSQLname("SE5") + " SE5, "
		cQuery +=           RetSQLname("SED") + " SED, "
		cQuery +=           RetSQLname("SE2") + " SE2  "
		cQuery += " WHERE "

		If lVretIrf
			//Se verifica base apenas na filial corrente e fornecedor corrente
			If cAglImPJ == "1" .or. (Eval(bSE5Compart)) //SE5 Compartilhado
				If Funname()<> "FINA091"  .OR. EMPTY(SE2->E2_FILIAL)
					cQuery += "SE5.E5_FILIAL = '"+ xFilial("SE5") + "' AND "
				Else
					cQuery += "SE5.E5_FILIAL = '"+ SE2->E2_FILIAL + "' AND "
				Endif

				If cAglImPJ == "1" 				//Verificar apenas fornecedor corrente
					cQuery += "SE5.E5_CLIFOR = '"+ SA2->A2_COD +"' AND "
					cQuery += "SE5.E5_LOJA = '"+ SA2->A2_LOJA +"' AND "
				Else									//Verificar determinados fornecedores (raiz do CNPJ)
					If !Empty(FWFilial("SA2")) //Se cadastro de Fornecedor EXCLUSIVO
						cQuery += " ('"+FWxFilial("SA2")+"'||E5_CLIFOR||E5_LOJA IN (SELECT FILIALX||CODIGO||LOJA FROM "+cArqTMP+")) AND "
					Else	//Se cadastro de Fornecedor Compartilhado
						cQuery += " (E5_CLIFOR||E5_LOJA IN (SELECT CODIGO||LOJA FROM " + cArqTMP + ")) AND "
					Endif
				Endif

			ElseIf Len(aFilial) > 0  //Mais de uma filial SM0

				If (Eval(bSA2Compart))  //Se cadastro de Clientes compartilhado
					cQuery += "SE5.E5_FILIAL IN ( "
					For nLoop := 1 to Len(aFilial)
						cQuery += "'"  + aFilial[nLoop] + "',"
					Next
					//Retiro a ultima virgula
					cQuery := Left( cQuery, Len( cQuery ) - 1 )
					cQuery += ") AND "

					If !Empty(FWFilial("SE5")) //Se cadastro de Fornecedor EXCLUSIVO
						cQuery += " (E5_FILIAL||E5_CLIFOR||E5_LOJA IN (SELECT '"+FWxFilial("SE5")+"'||CODIGO||LOJA FROM "+cArqTMP+")) AND "
					Else	//Se cadastro de Fornecedor Compartilhado
						cQuery += " (E5_CLIFOR||E5_LOJA IN (SELECT CODIGO||LOJA FROM " + cArqTMP + ")) AND "
					Endif
				Else							//Se cadastro de Clientes EXCLUSIVO
					If !Empty(FWFilial("SE5"))
						cQuery += " (E5_FILIAL||E5_CLIFOR||E5_LOJA IN (SELECT FILIALX||CODIGO||LOJA FROM "+cArqTMP+")) AND "
					Else
						cQuery += " ('"+FWxFilial("SA2")+"'||E5_CLIFOR||E5_LOJA IN (SELECT FILIALX||CODIGO||LOJA FROM "+cArqTMP+")) AND "
					Endif
				Endif
			Endif
		Else
			cQuery += "SE5.E5_FILIAL = '"+ xFilial("SE5") + "' AND "
			cQuery += "SE5.E5_CLIFOR = '"+ SA2->A2_COD +"' AND "
			cQuery += "SE5.E5_LOJA =   '"+ SA2->A2_LOJA +"' AND "
		Endif

		// Para Pessoa fisica totaliza os titulos emitidos no mes
		If cTipo == "F"

			If cVenctoPF == "1"
				cQuery += "SE5.E5_DATA  BETWEEN '" + Dtos(FirstDay(dBaixa)) + "' AND '" + Dtos(LastDay(dBaixa))+ "' AND "
			ElseIf cVenctoPF == "2"
				cQuery += "SE5.E5_DTDISPO  BETWEEN '" + Dtos(FirstDay(dDebito)) + "' AND '" + Dtos(LastDay(dDebito))+ "' AND "
				lVencto := .T.
			Else // cVenctoPF == "3"
				cQuery += "SE5.E5_DTDIGIT  BETWEEN '" + Dtos(FirstDay(dDataBase)) + "' AND '" + Dtos(LastDay(dDataBase))+ "' AND "
			Endif
		Else
			// Para Pessoa juridica totaliza os titulos emitidos no dia
			If lEmpPub
				If cVenctoPJ == "1"
					cQuery += "SE5.E5_DATA  BETWEEN '" + Dtos(dBaixaIni) + "' AND  '" + Dtos(dBaixaFim) + "' AND "
				ElseIf cVenctoPJ == "2"
					cQuery += "SE5.E5_DTDISPO BETWEEN '" + Dtos(dDebtIni) + "' AND  '" + Dtos(dDebtFim) + "' AND "
					lVencto := .T.
				Else // cVenctoPF == "3"
					cQuery += "SE5.E5_DTDIGIT  = '" + Dtos(dDataBase) + "' AND "
				Endif
			Else
				If cVenctoPJ == "1"
					cQuery += "SE5.E5_DATA  = '" + Dtos(dBaixa) + "' AND "
				ElseIf cVenctoPJ == "2"
					cQuery += "SE5.E5_DTDISPO  = '" + Dtos(dDebito) + "' AND "
					lVencto := .T.
				Else // cVenctoPF == "3"
					cQuery += "SE5.E5_DTDIGIT  = '" + Dtos(dDataBase) + "' AND "
				Endif
				cQuery += "SE2.E2_CODRET  = '" + cCodRet + "' AND "
				
			EndIf
			If cVenctoPJ == "1"
				cQuery += "SE5.E5_DATA  = '" + Dtos(dBaixa) + "' AND "
			ElseIf cVenctoPJ == "2"
				cQuery += "SE5.E5_DTDISPO  = '" + Dtos(dDebito) + "' AND "
				lVencto := .T.
			Else // cVenctoPF == "3"
				cQuery += "SE5.E5_DTDIGIT  = '" + Dtos(dDataBase) + "' AND "
			Endif
		Endif

		//Desconsidero baixas que nao tiveram calculo de IR.
		cQuery += "SE5.E5_BASEIRF > 0 AND "
		//Desconsidero baixas onde foi baixado somente o valor da Multa e Juros.
		cQuery += "SE5.E5_VALOR <> SE5.E5_VLMULTA AND "
		cQuery += "SE5.E5_VALOR <> SE5.E5_VLJUROS AND "

		//Desconsidero os cancelados
		cQuery += "SE5.E5_SITUACA NOT IN ( 'C' , 'E' , 'X' ) AND "
		cQuery += "SE5.E5_RECPAG = 'P' AND "
		cQuery += "SE5.E5_TIPODOC <> 'ES' AND "

		If FwIsInCallStack("fA340Comp")
			cQuery += "SE5.E5_TIPODOC NOT IN " + FormatIn(MVPAGANT,cSepRec)	+ " AND "
		EndIf

		//Titulos baixados por geracao de fatura/liquidacao e devolucao nao calculam IR
		cQuery += " SE5.E5_MOTBX NOT IN "
		If lEmpPub
			cQuery += " ('FAT', 'LIQ', 'DEV', 'IRF','IMR') AND "
		Else
			cQuery += " ('FAT', 'LIQ', 'DEV', 'PCC','IMR', 'DSD') AND "
		EndIf

		cQuery += "SE5.D_E_L_E_T_ = ' ' "

		//Desconsidera baixas estornadas
		cQuery += "AND NOT EXISTS ("
		cQuery += "SELECT A.E5_NUMERO "
		cQuery += "FROM "+RetSqlName("SE5")+" A "
		If Funname() <> "FINA091" .OR. EMPTY(SE2->E2_FILIAL)
			cQuery += "WHERE A.E5_FILIAL = '" + xFilial("SE5") + "' AND "
		Else
			cQuery += "WHERE A.E5_FILIAL = SE5.E5_FILIAL AND "
		Endif
		cQuery +=		"A.E5_NATUREZ=SE5.E5_NATUREZ AND "
		cQuery +=		"A.E5_PREFIXO=SE5.E5_PREFIXO AND "
		cQuery +=		"A.E5_NUMERO=SE5.E5_NUMERO AND "
		cQuery +=		"A.E5_PARCELA=SE5.E5_PARCELA AND "
		cQuery +=		"A.E5_TIPO=SE5.E5_TIPO AND "
		cQuery +=		"A.E5_CLIFOR=SE5.E5_CLIFOR AND "
		cQuery +=		"A.E5_LOJA=SE5.E5_LOJA AND "
		cQuery +=		"A.E5_SEQ=SE5.E5_SEQ AND "
		cQuery +=		"A.E5_TIPODOC = 'ES' AND "
		cQuery +=		"A.E5_RECPAG <> 'P' AND "
		//Descondidera estornos se houver
		cQuery +=		"NOT EXISTS (SELECT B.E5_NUMERO "
		cQuery +=		"FROM "+RetSqlName("SE5")+" B "
		If Funname() <> "FINA091" .OR. EMPTY(SE2->E2_FILIAL)
			cQuery += 			"WHERE B.E5_FILIAL = '" + xFilial("SE5") + "' AND "
		Else
			cQuery += 			"WHERE B.E5_FILIAL = A.E5_FILIAL AND "
		Endif
		cQuery += 			"B.E5_NATUREZ = A.E5_NATUREZ AND "
		cQuery += 			"B.E5_PREFIXO = A.E5_PREFIXO AND "
		cQuery += 			"B.E5_NUMERO = A.E5_NUMERO AND "
		cQuery += 			"B.E5_PARCELA = A.E5_PARCELA AND "
		cQuery += 	   		"B.E5_TIPO = A.E5_TIPO AND "
		cQuery += 	   		"B.E5_CLIFOR = A.E5_CLIFOR AND "
		cQuery += 	   		"B.E5_LOJA = A.E5_LOJA AND "
		cQuery += 	   		"B.E5_SEQ = A.E5_SEQ AND "
		cQuery += 	   		"B.E5_MOTBX IN ('IRF') AND "
		cQuery += 			"B.E5_RECPAG = 'R' AND "
		cQuery += 			"B.E5_TIPODOC = 'ES' AND "
		cQuery += 	   		"B.E5_SITUACA != 'C' AND "
		cQuery += 	   		"B.E5_SITUACA != 'E' AND "
		cQuery += 	   		"B.E5_SITUACA != 'X' AND "
		cQuery += 	   		"B.D_E_L_E_T_ = ' ') AND "
		cQuery +=		"A.D_E_L_E_T_ = ' ') AND "

		//Verifico a filial do SED
		If cAglImPJ == "1" .Or. Empty(xFilial("SED")) .Or. Len(aFilial) == 0
			cQuery += "SED.ED_FILIAL = '"+ xFilial("SED") + "' AND "
		Else
			cQuery += "SED.ED_FILIAL IN ( "
			For nLoop := 1 to Len(aFilial)
				cQuery += "'"  + aFilial[nLoop] + "',"
			Next
			//Retiro a ultima virgula
			cQuery := Left( cQuery, Len( cQuery ) - 1 )
			cQuery += ") AND "

		Endif

		cQuery += "SE5.E5_NATUREZ = SED.ED_CODIGO AND "
		cQuery += "SED.ED_CALCIRF = 'S' AND "
		cQuery += "SED.D_E_L_E_T_ = ' ' AND "
		//Obtenho o INSS no SE2
		cQuery +=	"SE2.E2_FILIAL = '"+ xFilial("SE2") +"' AND "		
		cQuery +=	"SE5.E5_PREFIXO=SE2.E2_PREFIXO AND "
		cQuery +=	"SE5.E5_NUMERO=SE2.E2_NUM AND "
		cQuery +=	"SE5.E5_PARCELA=SE2.E2_PARCELA AND "
		cQuery +=	"SE5.E5_TIPO=SE2.E2_TIPO AND "
		cQuery +=	"SE5.E5_TIPO<>'INA' AND "
		cQuery +=	"SE5.E5_CLIFOR=SE2.E2_FORNECE AND "
		cQuery +=	"SE5.E5_LOJA=SE2.E2_LOJA AND "
		IF cAcmIrrf ==	"1" .and. cTipo == "F" 
			cQuery +=	"SE2.E2_TIPO NOT IN " + FormatIn(MVPAGANT,"|") +" AND "
		ENDIF
		cQuery += 	"SE2.D_E_L_E_T_ = ' ' "

		If lFINXCALCIR
			cQuery += ExecBlock("FINXCALCIR", .F. , .F. , cQuery)
		Endif

		cQuery += "ORDER BY E5_FILIAL,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_TIPO,E5_CLIFOR,E5_LOJA,E5_SEQ "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBIRF", .F., .T.)
		if TRBIRF->(!Eof())
			For nX := 1 to Len(aStru)
				If aStru[nX,2] != 'C' .And. FieldPos(aStru[nX,1]) > 0 // Se existir o campo na Query
					TCSetField('TRBIRF', aStru[nX,1], aStru[nX,2],aStru[nX,3],aStru[nX,4])
				Endif
			Next
		endif
		cKeySE5		:= ""
		cKeySE5Old	:= ""
		nTotBaseBx	:= 0
		nBaseOutTit	:= 0
		nTotInss	:= 0
		nTotRtIr	:= 0
		nBaseBxDia	:= 0
		nBaseBxExt	:= 0	
		nBaseBxAnt	:= 0
		nBaseCpAnt	:= 0
		nInsAux		:= 0
		nMultaDia	:= 0 
		nDescDia	:= 0
		nJurosDia	:= 0 
		nRecOld		:= 0
		lTemDscDep	:= .F.
		lSumBsIns	:= .F.
		nBasPdtDia	:= 0	//Base pendente de retenção do titulo que está sendo baixado no mesmo dia (2 bx parciais do mesmo titulo no mesmo dia e a primeira não reteve)
		nAcresBx	:= 0
		nDescresBx	:= 0

		aAreaSED := SED->( GetArea() )
		dbSelectArea("TRBIRF")

		While !(TRBIRF->(Eof()))

			SED->( DbSeek(xFilial("SED")+TRBIRF->E5_NATUREZ) ) // Posicionamento da Natureza

			If TRBIRF->RECNOSE2 != nRecOld
				SE2->( DbGoTo( TRBIRF->RECNOSE2 ) ) // Busca pelo Título correspondente
				nRecOld := TRBIRF->RECNOSE2
				lSumBsIns := .F. // Re-inicia flag de controle
			EndIf

			If cTipo == "F" // Pessoa Física

				If Alltrim(UPPER(TRBIRF->E2_ORIGEM)) == "MATA100"
					lTemDscDep := .T.
				EndIF
				
				dbSelectArea("SED")
				dbSeek(XFILIAL("SED")+TRBIRF->E5_NATUREZ)
				//Somo o INSS para reducao da base de IR (se Pessoa Fisica)
				//Verifico se a base de INSS jah foi somada anteriormente
				If !lSumBsIns
					lSumBsIns := .T.
					If !lDedInS .and. SED-> ED_IRRFCAR == "S"
						nTotInCar += TRBIRF->E2_INSS
					Else
						nTotInss += TRBIRF->E2_INSS
					Endif
					nInsAux	+= IIF( Alltrim(TRBIRF->E2_ORIGEM) == "MATA100", TRBIRF->E2_INSS, 0 )
				Endif
			Else
				If cAcmIrrf == "1" //Acumular os valores do IRRF
					nDedBase := 0
					nDedValor := 0
					
					//Verifica se ha complemento de imposto que afeta o base/valor de calculo.
					If cPaisLoc=="BRA" .and. lRegra
						// Proporcionalização da base (Baixa Parcial).
						nPropBase := TRBIRF->(E5_BASEIRF/E2_BASEIRF)
						nPropValor := TRBIRF->(E5_VRETIRF/E2_IRRF)

						nDedBase  := NoRound( Fa986regra("SE2","IRF","1" ) * nPropBase, MsDecimais(1) )
						nDedValor := NoRound( Fa986regra("SE2","IRF","2" ) * nPropValor, MsDecimais(1) )
					Endif

					If !lRndIRF
						nTotCalcIr += NoRound(( (TRBIRF->E5_BASEIRF+nDedBase) * IIF(SED->ED_PERCIRF > 0, SED->ED_PERCIRF, nAliqIrf) / 100),2)
					Else
						nTotCalcIr += Round(( (TRBIRF->E5_BASEIRF+nDedBase) * IIF(SED->ED_PERCIRF > 0, SED->ED_PERCIRF, nAliqIrf) / 100),2)
					Endif

					nTotCalcIr += nDedValor
				Endif
			Endif

			//Obtenho a base do titulo Principal 
			If nRecSE2 == TRBIRF->RECNOSE2

				nBaseBxExt += xMoeda(TRBIRF->E5_BASEIRF,1,SE2->E2_MOEDA,SE2->E2_EMISSAO,3,,TRBIRF->E5_TXMOEDA) 
				nBaseBxDia	+= TRBIRF->E5_BASEIRF
				nMultaDia  += TRBIRF->E5_VLMULTA	
				nDescDia   += TRBIRF->E5_VLDESCO
				nJurosDia  += TRBIRF->E5_VLJUROS
				If !(TRBIRF->E5_TIPO $ MVPAGANT)
					nBasPdtDia += If (TRBIRF->E5_PRETIRF == '1', nBaseBxDia, 0)
				EndIf
			Else
				//Quando for Pessoa Fisica(cTipo) + Acumulatividade de IRRF(cAcmIrrf) 
				//Irá realizar o Acrecimo (E5_VLACRES) e Decrecimo (E5_VLDECRE)
				If cTipo == "F"										
					//E5_BASEIRF para pessoa física ja esta sendo gravado em REAL					
					nAcresBx	:=xMoeda(TRBIRF->E5_VLACRES,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,3,TRBIRF->E5_TXMOEDA,)
					nDescresBx	:=xMoeda(TRBIRF->E5_VLDECRE,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,3,TRBIRF->E5_TXMOEDA,)
					nBaseOutTit += (TRBIRF->E5_BASEIRF  + nAcresBx - nDescresBx)
				Else//Base de imposto com retencao (base utilizada do titulo em baixa)
					If !(TRBIRF->E5_TIPO $ MVPAGANT)
						nBaseOutTit += xMoeda(TRBIRF->E5_BASEIRF,1,SE2->E2_MOEDA,SE2->E2_EMISSAO,3,,TRBIRF->E5_TXMOEDA)
					EndIf
				Endif
			Endif

			//Se for baixa da geração de IR no borderô, zero a base do título para não ocorrer recalculo do imposto - IR já gerado
			If AllTrim(TRBIRF->E5_MOTBX) == "IRF"
				nBaseTit := 0
			Endif

			//Componho o valor dos impostos ja retidos anteriormente
			If lVRetIrf
				If TRBIRF->E5_PRETIRF $ "3|4|7" .OR. EMPTY(TRBIRF->E5_PRETIRF)
					//Total de IR retido
					nTotRtIr	+= TRBIRF->E5_VRETIRF
					aDadosIr[1] += TRBIRF->E5_VRETIRF
					
					If oRatIRF <> Nil .AND. !Empty(oRatIRF:aRatIRF)
						//Verifica o IR retido por CPF (Rateio de Ir Progressivo)
						oRatIRF:GetIRRetido(TRBIRF->E5_IDORIG,'FK2')
					EndIf

				ElseIf TRBIRF->E5_PRETIRF == "1"
					aadd(aRecnoSE5, TRBIRF->RECNOSE5)
				Endif
			Endif

			TRBIRF->(dbSkip())
		Enddo
		SED->(RestArea(aAreaSED))
		TRBIRF->(dbCloseArea())
		//fim tratamento das baixas
		//------------------------------------------------------------------------------------------

		//------------------------------------------------------------------------------------------
		//Tratamento para titulos em bordero
		cAliasQry := GetNextAlias()

		SE2->( dbCommit() )
		cQuery := "SELECT SE2.E2_FILIAL,SE2.E2_PREFIXO,SE2.E2_NUM,SE2.E2_PARCELA,SE2.E2_TIPO,SE2.E2_FORNECE,SE2.E2_LOJA, "
		cQuery += "SE2.E2_VENCTO,SE2.E2_VENCREA,SE2.E2_EMIS1,SE2.E2_NATUREZ, "
		cQuery += "SE2.E2_VRETIRF, SE2.E2_PRETIRF, SE2.E2_BASEIRF, SE2.R_E_C_N_O_ RECNOSE2, "
		cQuery += "SE2.E2_BASEIRF, SE2.E2_INSS, SE2.E2_ORIGEM "

		cQuery += "FROM " + RetSQLname("SE2") + " SE2, "
		cQuery +=           RetSQLname("SED") + " SED  "
		cQuery += " WHERE "

		If lVretIrf
			//Se verifica base apenas na filial corrente e fornecedor corrente
			If cAglImPJ == "1" .or. (Eval(bSE2Compart)) //SE2 Compartilhado
				cQuery += "SE2.E2_FILIAL = '"+ xFilial("SE2") + "' AND "

				If cAglImPJ == "1" 				//Verificar apenas fornecedor corrente
					cQuery += "SE2.E2_FORNECE = '"+ SA2->A2_COD +"' AND "
					cQuery += "SE2.E2_LOJA = '"+ SA2->A2_LOJA +"' AND "
				Else									//Verificar determinados fornecedores (raiz do CNPJ)
					If !Empty(FWFilial("SA2")) //Se cadastro de Fornecedor EXCLUSIVO
						cQuery += " ('"+FWxFilial("SA2")+"'||E2_FORNECE||E2_LOJA IN (SELECT FILIALX||CODIGO||LOJA FROM "+cArqTMP+")) AND "
					Else	//Se cadastro de Fornecedor Compartilhado
						cQuery += " (E2_FORNECE||E2_LOJA IN (SELECT CODIGO||LOJA FROM "+cArqTMP+")) AND "
					Endif
				Endif

			ElseIf Len(aFilial) > 0  //Mais de uma filial SM0

				If (Eval(bSE2Compart))  //Se cadastro de Clientes compartilhado
					cQuery += "SE2.E2_FILIAL IN ( "
					For nLoop := 1 to Len(aFilial)
						cQuery += "'"  + aFilial[nLoop] + "',"
					Next
					//Retiro a ultima virgula
					cQuery := Left( cQuery, Len( cQuery ) - 1 )
					cQuery += ") AND "

					If !Empty(FWFilial("SA2")) //Se cadastro de Fornecedor EXCLUSIVO
						cQuery += " ('"+FWxFilial("SA2")+"'||E2_FORNECE||E2_LOJA IN (SELECT FILIALX||CODIGO||LOJA FROM "+cArqTMP+")) AND "
					Else	//Se cadastro de Fornecedor Compartilhado
						cQuery += " (E2_FORNECE||E2_LOJA IN (SELECT CODIGO||LOJA FROM "+cArqTMP+")) AND "
					Endif
				Else		// Se contas a pagar Exclusivo
					If !Empty(FWFilial("SA2"))
						cQuery += " (E2_FILIAL||E2_FORNECE||E2_LOJA IN (SELECT FILIALX||CODIGO||LOJA FROM "+cArqTMP+")) AND "
					Else
						cQuery += " (E2_FILIAL||E2_FORNECE||E2_LOJA IN (SELECT '"+FWxFilial("SE2")+"'||CODIGO||LOJA FROM "+cArqTMP+")) AND "
					Endif
				EndIF
			Endif
		Else
			cQuery += "SE2.E2_FILIAL = '"+ xFilial("SE2") + "' AND "
			cQuery += "SE2.E2_FORNECE= '"+ SA2->A2_COD +"' AND "
			cQuery += "SE2.E2_LOJA =   '"+ SA2->A2_LOJA +"' AND "
		Endif

		// Para Pessoa fisica totaliza os titulos emitidos no mes
		If cTipo == "F"
			If cVenctoPF == "1"
				dDataInic := FirstDay(dBaixa)
				dDataFina := LastDay(dBaixa)
			ElseIf cVenctoPF == "2"
				dDataInic := FirstDay(dDebito)
				dDataFina := LastDay(dDebito)
			Else // cVenctoPF == "3"
				dDataInic := FirstDay(dDatabase)
				dDataFina := LastDay(dDatabase)
			Endif
		Elseif lEmpPub
			dDataInic := FirstDay(dDatabase)
			dDataFina := LastDay(dDatabase)
		Else
			// Para Pessoa juridica totaliza os titulos emitidos no dia
			If cVenctoPJ == "1"
				dDataInic := dBaixa
				dDataFina := dBaixa
			ElseIf cVenctoPJ == "2"
				dDataInic := dDebito
				dDataFina := dDebito
			Else // cVenctoPF == "3"
				dDataInic := dDatabase
				dDataFina := dDatabase
			Endif
			cQuery += "SE2.E2_CODRET  = '" + cCodRet + "' AND "
		Endif

		cQuery += " SE2.E2_NUMBOR <> '" + Space(TamSX3("E2_NUMBOR")[1]) + "' AND "
		If Type("cNumBor") <> "U" .And. FunName() $ "FINA080|FINA590"
			cQuery += " SE2.E2_NUMBOR <> '"+cNumBor+"' AND "
		EndIf
		cQuery += " ( (SE2.E2_DTBORDE >= '" + DTOS( dDataInic ) + "' AND SE2.E2_DTBORDE <= '"	+ DTOS( dDataFina ) + "') "
		cQuery += " OR (SE2.E2_BAIXA >= '" + DTOS( dDataInic ) + "' AND SE2.E2_BAIXA <= '"	+ DTOS( dDataFina ) + "') ) AND "
		cQuery += " SE2.E2_BASEIRF > 0 AND "
		cQuery += " SE2.E2_PRETIRF <> '6' AND "
		cQuery += " SE2.E2_DESDOBR <> 'S' AND "
		cQuery += " SE2.E2_TIPO NOT IN " + FormatIn(MVABATIM,"|") 		+ " AND "
		cQuery += " SE2.E2_TIPO NOT IN " + FormatIn(MV_CPNEG,cSepNeg)	+ " AND "
		cQuery += " SE2.E2_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv)	+ " AND "
		cQuery += " SE2.E2_TIPO NOT IN " + FormatIn(MVPAGANT,cSepRec)	+ " AND "
		cQuery += " SE2.D_E_L_E_T_ = ' ' "

		//Desconsidera baixas estornadas
		cQuery += "AND NOT EXISTS ("
		cQuery += "SELECT A.E5_NUMERO "
		cQuery += "FROM "+RetSqlName("SE5")+" A "
		cQuery += "WHERE A.E5_FILIAL='"+xFilial("SE5")+"' AND "
		cQuery +=		"A.E5_NATUREZ=SE2.E2_NATUREZ AND "
		cQuery +=		"A.E5_PREFIXO=SE2.E2_PREFIXO AND "
		cQuery +=		"A.E5_NUMERO=SE2.E2_NUM AND "
		cQuery +=		"A.E5_PARCELA=SE2.E2_PARCELA AND "
		cQuery +=		"A.E5_TIPO=SE2.E2_TIPO AND "
		cQuery +=		"A.E5_CLIFOR=SE2.E2_FORNECE AND "
		cQuery +=		"A.E5_LOJA=SE2.E2_LOJA AND "
		cQuery +=		"A.E5_MOTBX IN ('IRF'"+Iif(FunName() $ "FINA090|FINA091","",",'NOR','DEB'")+") AND "
		cQuery +=		"A.E5_RECPAG = 'P' AND "
		cQuery +=		"A.E5_SITUACA != 'C' AND "
		cQuery +=		"A.E5_SITUACA != 'E' AND "
		cQuery +=		"A.E5_SITUACA != 'X' AND "
		//Descondidera estornos se houver
		cQuery +=		"NOT EXISTS (SELECT B.E5_NUMERO "
		cQuery +=		"FROM "+RetSqlName("SE5")+" B "
		cQuery += 			"WHERE B.E5_FILIAL='"+xFilial("SE5")+"' AND "
		cQuery += 			"B.E5_NATUREZ = A.E5_NATUREZ AND "
		cQuery += 			"B.E5_PREFIXO = A.E5_PREFIXO AND "
		cQuery += 			"B.E5_NUMERO = A.E5_NUMERO AND "
		cQuery += 			"B.E5_PARCELA = A.E5_PARCELA AND "
		cQuery += 	   		"B.E5_TIPO = A.E5_TIPO AND "
		cQuery += 	   		"B.E5_CLIFOR = A.E5_CLIFOR AND "
		cQuery += 	   		"B.E5_LOJA = A.E5_LOJA AND "
		cQuery += 	   		"B.E5_SEQ = A.E5_SEQ AND "
		cQuery += 	   		"B.E5_MOTBX IN ('IRF'"+Iif(FunName() $ "FINA090|FINA091","",",'NOR','DEB'")+") AND "
		cQuery += 			"B.E5_RECPAG = 'R' AND "
		cQuery += 			"B.E5_TIPODOC = 'ES' AND "
		cQuery += 	   		"B.E5_SITUACA != 'C' AND "
		cQuery += 	   		"B.E5_SITUACA != 'E' AND "
		cQuery += 	   		"B.E5_SITUACA != 'X' AND "
		cQuery += 	   		"B.D_E_L_E_T_ = ' ') AND "
		cQuery +=		"A.D_E_L_E_T_ = ' ') AND "

		//Verifico a filial do SED
		If cAglImPJ == "1" .Or. Empty(xFilial("SED")) .Or. Len(aFilial) == 0
			cQuery += "SED.ED_FILIAL = '"+ xFilial("SED") + "' AND "
		Else
			cQuery += "SED.ED_FILIAL IN ( "
			For nLoop := 1 to Len(aFilial)
				cQuery += "'"  + aFilial[nLoop] + "',"
			Next
			//Retiro a ultima virgula
			cQuery := Left( cQuery, Len( cQuery ) - 1 )
			cQuery += ") AND "
		Endif

		cQuery += "SE2.E2_NATUREZ = SED.ED_CODIGO AND "
		cQuery += "SED.ED_CALCIRF = 'S' AND "
		cQuery += "SED.D_E_L_E_T_ = ' ' "

		cQuery += "ORDER BY E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBIRF2", .F., .T.)
		if TRBIRF2->(!Eof())
			For nX := 1 to Len(aStru)
				If aStru[nX,2] != 'C' .And. FieldPos(aStru[nX,1]) > 0 // Se existir o campo na Query
					TCSetField('TRBIRF2', aStru[nX,1], aStru[nX,2],aStru[nX,3],aStru[nX,4])
				Endif
			Next
		endif

		SE2->(dbGoTo(nRecSe2))
		dbSelectArea("TRBIRF2")
		cKeySE5	:= ""
		While !(TRBIRF2->(Eof()))
			
			cKeySE5 := TRBIRF2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
			//Obtenho a base do titulo atual
			If !( cKeySE5 == TRBIRF2->E2_FILIAL + SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) )

				//Base de imposto com retencao (base utilizada do titulo em baixa)
				nBaseOutTit += TRBIRF2->E2_BASEIRF
				dbSelectArea("SED")
				dbSeek(XFILIAL("SED")+TRBIRF2->E2_NATUREZ)

				//Somo o INSS para reducao da base de IR (se Pessoa Fisica)
				If cTipo == "F"
					If !lDedInS .and. SED-> ED_IRRFCAR== "S"
						nTotInCar += TRBIRF2->E2_INSS
					Else
						nTotInss += TRBIRF2->E2_INSS
					Endif
					nInsAux	+= IIF( Alltrim(TRBIRF2->E2_ORIGEM) == "MATA100", TRBIRF2->E2_INSS, 0 )
				Else					
					nDedBase := 0
					nDedValor := 0
					//Verifica se ha complemento de imposto que afeta o base/valor de calculo.
					If cPaisLoc=="BRA" .And. lRegra
						nDedBase  := Fa986regra("SE2","IRF","1" )
						nDedValor := Fa986regra("SE2","IRF","2" )
					EndIf
					If 	cAcmIrrf ==	"1" //Acumular os valores do IRRF						
						nTotCalcIr += NoRound(( (TRBIRF2->E2_BASEIRF+nDedBase) * IIF(SED->ED_PERCIRF > 0, SED->ED_PERCIRF, nAliqIrf) / 100),2)
						nTotCalcIr += nDedValor
					Endif				
				EndIF				
			Endif

			//Componho o valor dos impostos ja retidos anteriormente
			If lVRetIrf
				If TRBIRF2->E2_PRETIRF $ " /4"
					//Total de IR retido
					nTotRtIr	+= TRBIRF2->E2_VRETIRF
					aDadosIr[1] += TRBIRF2->E2_VRETIRF

				ElseIf TRBIRF2->E2_PRETIRF == "1" .and. ;
						!( cKeySE5 == TRBIRF2->E2_FILIAL + SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) )
					aadd(aRecnoSE2, TRBIRF2->RECNOSE2)
				Endif
			Endif
			If nTotRtIr > 0
				nIRRet := SE2->E2_IRRF
			Endif
			TRBIRF2->(dbSkip())
		Enddo
		SED->(RestArea(aAreaSED))
		TRBIRF2->(dbCloseArea())

		// fim verificacao titulos em bordero
		//------------------------------------------------------------------------------------------

		//------------------------------------------------------------------------------------------
		//Tratamento para pagamentos antecipados
		If 	cAcmIrrf ==	"1" //Acumular os valores do IRRF
			cAliasQry := GetNextAlias()

			SE2->( dbCommit() )
			cQuery := "SELECT SE2.E2_FILIAL,SE2.E2_PREFIXO,SE2.E2_NUM,SE2.E2_PARCELA,SE2.E2_TIPO,SE2.E2_FORNECE,SE2.E2_LOJA, "
			cQuery += "SE2.E2_VENCTO,SE2.E2_VENCREA,SE2.E2_EMIS1,SE2.E2_NATUREZ, "
			cQuery += "SE2.E2_VRETIRF, SE2.E2_PRETIRF, SE2.E2_BASEIRF, SE2.E2_SALDO, SE2.R_E_C_N_O_ RECNOSE2, "
			cQuery += "SE2.E2_BASEIRF, SE2.E2_INSS, SE2.E2_IRRF "

			cQuery += "FROM " + RetSQLname("SE2") + " SE2 "
			cQuery += " WHERE "

			If lVretIrf
				//Se verifica base apenas na filial corrente e fornecedor corrente
				If cAglImPJ == "1" .or. (Eval(bSE2Compart)) //SE2 Compartilhado
					cQuery += "SE2.E2_FILIAL = '"+ xFilial("SE2") + "' AND "

					If cAglImPJ == "1" 				//Verificar apenas fornecedor corrente
						cQuery += "SE2.E2_FORNECE = '"+ SA2->A2_COD +"' AND "
						cQuery += "SE2.E2_LOJA = '"+ SA2->A2_LOJA +"' AND "
					Else									//Verificar determinados fornecedores (raiz do CNPJ)
						If !Empty(FWFilial("SA2"))
							cQuery += " ('"+FWxFilial("SA2")+"'||E2_FORNECE||E2_LOJA IN (SELECT FILIALX||CODIGO||LOJA FROM " + cArqTMP + ")) AND "
						Else
							cQuery += " (E2_FORNECE||E2_LOJA IN (SELECT CODIGO||LOJA FROM " + cArqTMP + ")) AND "
						Endif
					Endif

				ElseIf Len(aFilial) > 0  //Mais de uma filial SM0

					If (Eval(bSE2Compart))  //Se contas a pagar compartilhado
						cQuery += "SE2.E2_FILIAL IN ( "
						For nLoop := 1 to Len(aFilial)
							cQuery += "'"  + aFilial[nLoop] + "',"
						Next
						//Retiro a ultima virgula
						cQuery := Left( cQuery, Len( cQuery ) - 1 )
						cQuery += ") AND "

						//Verificar determinados fornecedores (raiz do CNPJ)
						If !Empty(FWFilial("SA2")) //Se cadastro de Fornecedor EXCLUSIVO
							cQuery += " ('"+FWxFilial("SA2")+"'||E2_FORNECE||E2_LOJA IN (SELECT FILIALX||CODIGO||LOJA FROM "+cArqTMP+")) AND "
						Else	//Se cadastro de Fornecedor Compartilhado
							cQuery += " (E2_FORNECE||E2_LOJA IN (SELECT CODIGO||LOJA FROM "+cArqTMP+")) AND "
						Endif
					Else		// Se contas a pagar Exclusivo
						If !Empty(FWFilial("SA2"))
							cQuery += " (E2_FILIAL||E2_FORNECE||E2_LOJA IN (SELECT FILIALX||CODIGO||LOJA FROM "+cArqTMP+")) AND "
						Else
							cQuery += " (E2_FILIAL||E2_FORNECE||E2_LOJA IN (SELECT '"+FWxFilial("SE2")+"'||CODIGO||LOJA FROM "+cArqTMP+")) AND "
						Endif
					Endif
				Endif
			Else
				cQuery += "SE2.E2_FILIAL = '"+ xFilial("SE2") + "' AND "
				cQuery += "SE2.E2_FORNECE= '"+ SA2->A2_COD +"' AND "
				cQuery += "SE2.E2_LOJA =   '"+ SA2->A2_LOJA +"' AND "
			Endif

			// Para Pessoa fisica totaliza os titulos emitidos no mes
			If cTipo == "F"
				If cVenctoPF == "1"
					dDataInic := FirstDay(dBaixa)
					dDataFina := LastDay(dBaixa)
				ElseIf cVenctoPF == "2"
					dDataInic := FirstDay(dDebito)
					dDataFina := LastDay(dDebito)
				Else // cVenctoPF == "3"
					dDataInic := FirstDay(dDatabase)
					dDataFina := LastDay(dDatabase)
				Endif
			Endif

			cQuery += " E2_TIPO IN " + FormatIn(MVPAGANT,"|")

			If cTipo == "F"
				If cVenctoPF == "1"
					cQuery += " AND SE2.E2_EMISSAO  BETWEEN '" + Dtos(dDataInic) + "' AND '" + Dtos(dDataFina)+ "' "
				ElseIf cVenctoPF == "2"
					cQuery += " AND SE2.E2_VENCREA  BETWEEN '" + Dtos(dDataInic) + "' AND '" + Dtos(dDataFina)+ "' "
					lVencto := .T.
				Else // cVenctoPF == "3"
					cQuery += " AND SE2.E2_EMIS1  BETWEEN '" + Dtos(dDataInic) + "' AND '" + Dtos(dDataFina)+ "' "
				Endif
			Else
				If cVenctoPJ == "1"
					cQuery += " AND SE2.E2_EMISSAO = '" + Dtos(dBaixa)  + "' "
				ElseIf cVenctoPJ == "2"
					cQuery += " AND SE2.E2_VENCREA = '" + Dtos(dDebito) + "' "
					lVencto := .T.
				Else // cVenctoPJ == "3"
					cQuery += " AND SE2.E2_EMIS1 = '" + Dtos(dDataBase) + "' "
				Endif
				cQuery += "AND SE2.E2_CODRET  = '" + cCodRet + "' "
			EndIf

			If lAplMinIR .and. cTipo == "J" .and. SA2->A2_IRPROG == "2"
				cQuery += " AND SE2.E2_IRRF <= " + CValToChar( nVlMinIr )
			EndIf

			cQuery += " AND SE2.D_E_L_E_T_ = ' ' "

			cQuery += "ORDER BY E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA "

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBIRF3", .F., .T.)
			
			If TRBIRF3->(!Eof())
				For nX := 1 to Len(aStru)
					If aStru[nX,2] != 'C' .And. FieldPos(aStru[nX,1]) > 0 // Se existir o campo na Query
						TCSetField('TRBIRF3', aStru[nX,1], aStru[nX,2],aStru[nX,3],aStru[nX,4])
					Endif
				Next
			endif
			dbSelectArea("TRBIRF3")

			//Evitar duplicidade de titulo do tipo PA para cálculo do IRF considerando uma PA + NF na baixa, quando fornecedor é pessoa física.
			While !(TRBIRF3->(Eof())) 

				If TRBIRF3->E2_IRRF == 0 .and. SED->(DbSeek(XFILIAL("SED")+TRBIRF3->E2_NATUREZ)) .and. SED->ED_CALCIRF != 'S'
					TRBIRF3->(dbSkip())
					Loop
				EndIf

				cKeySE5 := TRBIRF3->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)

				nProp := 0 

				If cTipo == "F"
					nProp := 1
				Else
					dbSelectArea("SE5")
					SE5->(dbSetOrder(7))

					If SE5->(dbSeek(cKeySE5))
						While !SE5->(Eof()) .And.  SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == cKeySE5
							If SE5->E5_DOCUMEN == PadR(TRBIRF3->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA),TamSx3("E5_DOCUMEN")[1])
								nProp += SE5->E5_VALOR
							EndIf
							SE5->(dbSkip())
						EndDo
					EndIf

					If nProp > 0 
						nProp := nProp/TRBIRF3->E2_BASEIRF
					Else
						nProp := 1
					EndIf

					//Controle para retenção parcial com compensação.
					If nBaseTit > 0 .And. !lBxMnl .and. !lInclPA
						lPropComp := .T.
					EndIf

				EndIf

				nBaseOutTit += TRBIRF3->E2_BASEIRF
				nTotRtIr	+= TRBIRF3->E2_VRETIRF * nProp
				aDadosIr[1] += TRBIRF3->E2_VRETIRF * nProp
				
				If oRatIRF <> Nil .AND. !Empty(oRatIRF:aRatIRF)
					SE5->(dbSetOrder(7))
					If SE5->(dbSeek(cKeySE5))
						//Verifica o IR retido por CPF (Rateio de Ir Progressivo)
						oRatIRF:GetIRRetido(SE5->E5_IDORIG,'FK5')
					Endif					
				EndIf

				If 	cAcmIrrf ==	"1" //Acumular os valores do IRRF
					nTotCalcIr  += TRBIRF3->E2_VRETIRF * nProp
				Endif

				TRBIRF3->(dbSkip())
			Enddo

			TRBIRF3->(dbCloseArea())
			SED->(RestArea(aAreaSED))
		EndIf
		
		lBaseConv := .F.				
		SE2->( DbGoTo( nRecSE2 ) )
		
		//Encontro a base do titulo atual caso nao seja passada 
		If nBaseTit == 0 .and. STR(SE2->E2_SALDO,17,2) == STR(SE2->E2_VALOR,17,2)
			If SE2->E2_BASEIRF > 0
				If lBaseDif .and. cTipo <> "F" .and. SED->ED_BASEIRF > 0
					nBaseTit := SE2->E2_BASEIRF * SED->ED_BASEIRF/100
				Else
					nBaseTit := SE2->E2_BASEIRF
				Endif
			Else
				If 'NOTFAT' $ SE2->E2_FATURA
					nValOutImp := f080OutImp(SE2->E2_VALOR)
				Else
					nValOutImp := SE2->E2_INSS

					If !lCalcIssBx
						nValOutImp += SE2->E2_ISS
					EndIf
				Endif
				nBaseTit := SE2->E2_VALOR + nValOutImp
			Endif

			If SE2->E2_MOEDA > 1 
				lBaseConv := .T.				
				If Alltrim(SE2->E2_ORIGEM) == 'MATA100' .Or. cTipo == "F"
					nBaseTit := F080Base103(nBaseTit,nTxMoeda,nMoedaBco,nCasDec,,dBaixa)
				Else
					nBaseTit := Round(xMoeda(nBaseTit, SE2->E2_MOEDA, 1, dBaixa, nCasDec, nTxMoeda), 2)
				Endif
			Endif	

			//Ajusta base de calculo com valores acessorios
			If lJurMulDes
				nBaseTit += nMultaDia + nJurosDia - nDescDia		
			EndIf
		Else
			//Apuro base restante do titulo atualmente em baixa
			//Titulo ja possui baixas parciais mas podem nao estarem no periodo de apuracao
			nBaseBxAnt := 0
			nBaseCpAnt := 0
			aAreaAtu := GetArea()
			DBSELECTAREA("SE5")
			SE5->(DBSETORDER(7))

			If FunName() <> "FINA091" .OR. Empty(SE2->E2_FILIAL)
				If FwIsInCallStack("FA050INCLU") // Se vier pelo FINA050 o titulo pode não estar incluso.
					cChvSE2 := M->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
				Else
					cChvSE2 := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
				EndIf

				IF SE5->( MSSeek( xFilial("SE5") + cChvSE2 ) )
					cKeySE5 := SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_FORNECE+E5_LOJA)
					nPosic := LEN(SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA)) + 1

					While !(SE5->(EOF())) .AND. cKeySE5 == SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_FORNECE+E5_LOJA)
						//validar se a data dessa base nao e do mesmo dia da baixa atual pois as do mesmo dia foram selecionadas na query acima.
						If !FVeDatIr(cTipo,cVenctoPJ,cVenctoPF,dBaixa,dDebito)
							If SE5->E5_MOTBX == "CMP" // Compensação
								nRecAtu := SE5->(Recno())

								If SE5->(DbSeek(xFilial("SE5")+E5_DOCUMEN)) //Busco pela Inclusão do PA que fez parte da compensação
									nBaseCpAnt += xMoeda(SE5->E5_BASEIRF,1,SE2->E2_MOEDA,SE2->E2_EMISSAO,3,,SE5->E5_TXMOEDA)
								EndIf

								SE5->(DbGoTo(nRecAtu))
							Else
								nBaseBxAnt += xMoeda(SE5->E5_BASEIRF,1,SE2->E2_MOEDA,SE2->E2_EMISSAO,3,,SE5->E5_TXMOEDA)
							EndIf
						ElseIf AllTrim(SE5->E5_MOTBX) == "CMP" .And. AllTrim(SUBSTR(SE5->E5_DOCUMEN, nPosic, 3)) $ StrTran( AllTrim(MV_CPNEG), "DIC", "" ) .And. SE5->E5_BASEIRF == 0
							If SE5->E5_TIPODOC == "ES"
								nBaseCmp -= SE5->E5_VALOR
							Else
								nBaseCmp += SE5->E5_VALOR
							EndIf
						Endif

						SE5->(dbSkip())
					Enddo
				Endif
			Else
				IF SE5->(MSSeek(SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
					cKeySE5 := SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_FORNECE+E5_LOJA)
					nPosic := LEN(SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA)) + 1

					While !(SE5->(EOF())) .AND. cKeySE5 == SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_FORNECE+E5_LOJA)
						//validar se a data dessa base nao e do mesmo dia da baixa atual pois as do mesmo dia foram selecionadas na query acima.
						If !FVeDatIr(cTipo,cVenctoPJ,cVenctoPF,dBaixa,dDebito)
							nBaseBxAnt += xMoeda(SE5->E5_BASEIRF,1,SE2->E2_MOEDA,SE2->E2_EMISSAO,3,,SE5->E5_TXMOEDA)
						ElseIf AllTrim(SE5->E5_MOTBX) == "CMP" .And. AllTrim(SUBSTR(SE5->E5_DOCUMEN, nPosic, 3)) $ StrTran( AllTrim(MV_CPNEG), "DIC", "" ) .And. SE5->E5_BASEIRF == 0
							If SE5->E5_TIPODOC == "ES"
								nBaseCmp -= SE5->E5_VALOR
							Else
								nBaseCmp += SE5->E5_VALOR
							EndIf
						Endif

						SE5->(dbSkip())
					Enddo
				Endif
			Endif

			RestArea(aAreaAtu)

			//Base do titulo em baixa (base total - base ja utilizada)
			If nBaseTit == 0 
				If (nBaseBxAnt + nBaseCpAnt + nBaseBxExt) > 0
					If Alltrim(SE2->E2_ORIGEM) == 'MATA100' .Or. cTipo == "F"
						nBaseTit := SE2->E2_BASEIRF
						nBaseTit -= F080Base103((nBaseBxAnt + nBaseCpAnt + nBaseBxExt),nTxMoeda,nMoedaBco,nCasDec, .F.,dBaixa)
					Else
						nBaseTit := SE2->E2_BASEIRF - (nBaseBxAnt + nBaseCpAnt + nBaseBxExt)
						nBaseTit -= nBaseCmp
					Endif
				ElseIf nBaseCmp > 0 .And. Empty(SE2->E2_NUMBOR) .And. lIRPFBaixa
					nBaseTit := (SE2->E2_BASEIRF - nBaseCmp)
				Else
					nBaseTit := SE2->E2_BASEIRF 
				Endif

				If SE2->E2_MOEDA > 1 
					lBaseConv := .T.
					If Alltrim(SE2->E2_ORIGEM) == 'MATA100' .Or. cTipo == "F"
						nBaseTit := F080Base103(nBaseTit,nTxMoeda,nMoedaBco,nCasDec,,dBaixa)
					Else
						nBaseTit := Round(xMoeda(nBaseTit, SE2->E2_MOEDA, 1, dBaixa, nCasDec, nTxMoeda), 2)
					Endif
				Endif	

				//Ajusta base de calculo com valores acessorios
				If lJurMulDes
					nBaseTit += nMultaDia + nJurosDia - nDescDia		
				EndIf
			Endif

			//Verifico se utiliza base reduzida
			If lBaseDif .and. cTipo <> "F" .and. SED->ED_BASEIRF > 0
				nBaseTit := nBaseTit * SED->ED_BASEIRF/100
			Endif
			
		Endif

		/*Verifica se ha complemento de imposto que afeta o valor de retenção para 
		o fornecedor PF ou em chamadas da inclusao/alteracao do titulo */
		If cPaisLoc=="BRA" .and. lRegra
			If (cTipo == "F" .or. l050IncAlt)
				nDedBase  := Fa986regra("SE2","IRF","1" )
				nBaseTit := nBaseTit + nDedBase
				If nBaseTit < 0
					nBaseTit := 0
				EndIf
			Endif
		EndIf


		//Base de calculo do periodo
		//Base de baixas do titulo + Base da baixa Atual + Base de baixa de outros titulos
		If  cTipo == "J"
			nTotTit := nBaseTit

			If lBxMnl
				If lAltValor .and. !lJurMulDes
					nAuxJur:=(nDescont-nJuros-nMulta)
					nTotTit := nTotTit+nAuxJur+nTotAbat-nAcresc+nDecresc //juros está em reais
				Elseif lJurMulDes
					nTotTit := nTotTit-nTotAbat + Iif(lAltValor, 0, nAcresc + nJuros + nMulta - nDescont -nDecresc)
				Endif
			ElseIf lBordBx .and. lJurMulDes
				nTotTit := nTotTit+SE2->(E2_ACRESC-E2_DECRESC)
			EndIf
			
			nVCalIRF  := nIrfCalc := (nTotTit * Iif(SED->ED_PERCIRF > 0, SED->ED_PERCIRF, nAliqIrf) / 100)
			nBaseConv := nBCalIRF  := nTotTit
			
			If l050IncAlt
				nPercent   := (Iif(SED->ED_PERCIRF > 0, SED->ED_PERCIRF, nAliqIrf) / 100) 
				nTotCalcIr += (nBaseConv * nPercent)			
			ElseIf SE2->E2_IRRF > 0 .and. SE2->E2_BASEIRF > 0 .and. lRegra
				If (lEmpPub .Or. SE2->E2_MOEDA == 1)
					nTotCalcIr += (nBaseConv * (SE2->E2_IRRF / SE2->E2_BASEIRF))
				Else
					nTotCalcIr += (nBaseConv * (Iif(SED->ED_PERCIRF > 0, SED->ED_PERCIRF, nAliqIrf) / 100))
				Endif
			ElseIF lRegra .And. (l986Base .OR. l986Imp)
				nTotCalcIr += 0 //Caso E2_IRRF zerado e possua complemento de imposto (FKG), considera isencao/suspensao total do tributo			
			ElseIf SED->ED_PERCIRF > 0
				nTotCalcIr += (nBaseConv * (SED->ED_PERCIRF / 100))
			Else
				nTotCalcIr += (nBaseConv * (nAliqIrf / 100))
			EndIf
		Else
			If cAcmIrrf ==	"1" //Acumula os valores do IRRF			
				nTotTit := nBaseBxDia + nBaseTit + nBaseOutTit				
				If lJurMulDes
					nTotTit += nMultaDia + nJurosDia - nDescDia		
				EndIf
			Else
				nTotTit := nBaseTit
			EndIf
		Endif
		
		aDadosIr[2] := aClone(aRecnoSE5)
		aDadosIr[3] := aClone(aRecnoSE2)
		
		//Somo o INSS do titulo corrente para reducao da base de IR (se Pessoa Fisica)
		If (cTipo == "F" .and. SE2->E2_SALDO==SE2->E2_VALOR) .OR. lOri241 // indica baixa total
			If !lDedINS .and. SED-> ED_IRRFCAR== "S"
				nTotInCar  	+= SE2->E2_INSS
			Else
				nTotInss	+= SE2->E2_INSS
			Endif
			nInsAux	+= IIF( Alltrim(SE2->E2_ORIGEM) == "MATA100", SE2->E2_INSS, 0 )
		Endif

		//Com o controle de retenção de IRRF, nao necessito somar titulo a titulo
		//Apenas calcular o IRRF do titulo presente
		//nBaseIrrf > 0 -> Base pre definida pelo SIGAPLS
		nTotTit := nTotTit  - nTotInCar
		If lBaseDif .and. SED->ED_BASEIRF > 0 .And. lBpParc
			nBaseSED := SED->ED_BASEIRF/100
			nTotTit := nBaseBxDia + (nBaseTit * nBaseSED) + nBaseOutTit
			nBaseIrrf:= IIF(lDedINS, nTotTit - nTotInss , nTotTit)
		Elseif lBaseCar .and. SED->ED_BASEIRC > 0 .And. lBpParc
			nBaseSED := SED->ED_BASEIRC/100
			nTotTit := nBaseBxDia + (nBaseTit * nBaseSED) + nBaseOutTit
			nBaseIrrf:= IIF(lDedINS, nTotTit - nTotInss , nTotTit)
		Else
			nBaseIrrf := IIF(lDedINS, (nTotTit * nBaseSED) - nTotInss , (nTotTit * nBaseSED) )
		Endif
		
		//Reestruturacao SE5
		nIrfBaseC := nBaseTit * nBaseSED
		
		//Fecha arquivo temporario
		If cAglImPJ != "1" .and. lDelTrbIR .and. (UPPER(Alltrim(TCGetDb()))!="POSTGRES")
			If InTransact()
				StartJob( "DELTRBIR" , GetEnvServer() , .T. , SM0->M0_CODIGO, FWGETCODFILIAL ,.T.,ThreadID(),cArqTMP,TCGetDb())
			Else
				DELTRBIR(SM0->M0_CODIGO, FWGETCODFILIAL,.F.,0,cArqTMP,TCGetDb())
			Endif
		Endif		
		dbSelectArea("SE5")
	Else
		nTotTit := nBaseIrrf
		nTotInss  := SE2->E2_INSS
		nInsAux	+= IIF( Alltrim(SE2->E2_ORIGEM) == "MATA100", SE2->E2_INSS, 0 )

		If lBaseDif .and. SED->ED_BASEIRF > 0 .And. lBpParc
			nBaseSED := SED->ED_BASEIRF / 100
		Elseif lBaseCar .and. SED->ED_BASEIRC > 0 .And. lBpParc
			nBaseSED := SED->ED_BASEIRC/100
		Endif
		nBaseIrrf := IIF(lDedINS, (nTotTit * nBaseSED) - nTotInss , (nTotTit * nBaseSED) )

		//Reestruturacao SE5
		nIrfBaseC := nBaseIrrf
	EndIf

	// Tratamento para Base de IRRF com origem Doc.Entrada
	If cTipo == "F"

		// Refaco a base de IRRF com valor de INSS que ja foi descontado pelo Documento de Entrada(MATA103)
		If lDedINS
			nBaseIrrf += nInsAux
		EndIf

		//Abato os dependentes dos Fornecedores Pessoa Fisica
		//Verifica se o numero de Depentes é maior que Zero
		If SA2->A2_NUMDEP > 0
			If lTemDscDep .or. AllTrim(SE2->E2_ORIGEM) != "FINA050" .And. nTotTit < SE2->( E2_VALOR + E2_INSS + IIF(lPCCBaixa, 0, E2_PIS+E2_COFINS+E2_CSLL) )
				nBaseIrrf := nBaseIrrf
			Else
				nBaseIrrf -= (nBaseDep * SA2->A2_NUMDEP)
			EndIf
		Endif
	EndIf

	//Ponto de entrada para manipulacao da base de calculo.
	//Deve ser utilizado para tratamento de reducao da base por numero de dependentes
	//Retornar Base de Calculo
	IF ExistBlock("F50CIRFF")
		nBaseIrrf := ExecBlock("F50CIRFF",.f.,.f.,nBaseIrrf)
	Endif

	If cTipo == "F" .And. (!Empty(aRatIRF)  .OR. (oRatIRF <> Nil .AND. !Empty(oRatIRF:aRatIRF)) )

		If oRatIRF <> Nil .AND. !Empty(oRatIRF:aRatIRF)
			oRatIRF:SetBaseIR(nBaseIrrf)
			If oRatIRF:lBaixa
				oRatIRF:SetValAces(nJuros+nMulta+nAcresc-nDescont+nDecresc)
			Endif	
			nValor := oRatIRF:CalcRatIr(nBaseTit)
			FSetRatIR(oRatIRF)
			lIrfRetAnt := .T.	// Já tratado no componente por CPF, somente para não zerar mais abaixo
		EndIf

	Else
		//Calculo o IRRF devido no periodo (dia ou mes)
		If cTipo == "F"
			// Cálculo de IR Pessoa Física
			If lNoAcComPE
				nValor	:= Round(NoRound(fa050TabIR(IIf(INCLUI, M->E2_VALOR, SE2->E2_SALDO)),3),2)
			Else
				nValor	:= Round(NoRound(fa050TabIR(nBaseIrrf),3),2)
			EndIf

			nVCalIRF := nValor
			nBCalIRF := nBaseIrrf
		Else
			If lNoAcComPE .Or. lNoAcParam
				nVCalIRF := nTotCalcIr := (SE2->E2_SALDO * Iif(SED->ED_PERCIRF > 0, SED->ED_PERCIRF, nAliqIrf) / 100)
			Endif

			If lRndIRF
				nValor 	 := Round(nTotCalcIr, 2)
				nVCalIRF := Round(nVCalIRF, 2)
			Else
				nValor 	 := NoRound(nTotCalcIr, 2)
				nVCalIRF := NoRound(nVCalIRF, 2)
			Endif
		Endif

		//Diminuo do valor calculado, o IRRF já retido
		If lAcumComPE .Or. lAcumSemPE
			nValor -= Iif(lPropComp,0,nTotRtIr)
		Endif

		//Controle de retencao anterior no mesmo periodo
		lIrfRetAnt := IIF(nTotRtIr > nVlMinIr, .T., .F.)
	EndIf

	/*Verifica se ha complemento de imposto que afeta o valor de retenção para 
	o fornecedor PF ou em chamadas da inclusao/alteracao do titulo */
	If cPaisLoc=="BRA" .and. lRegra
		If cTipo == "F" .or. l050IncAlt
			nDedValor := Fa986regra("SE2","IRF","2" )
			nValor := nValor + nDedValor
		Endif
	EndIf
	
	//Variaveis para controle de retencao antes da verificacao de valor minimo de retencao (PRIVATE)
	nVlRetIrf := nValor
	nBaseIrpf := nBaseTit
	If cTipo == "F"
		nIrfCalc := nValor 
	EndIf
	
	If cTipo == "J"
		If lBxMnl
			If lAltValor .and. !lJurMulDes
				nBaseIrpf := nBaseIrpf+nDescont+nTotAbat-nJuros-nMulta-nAcresc+nDecresc
				nIrfBaseC := nIrfBaseC+nDescont+nTotAbat-nJuros-nMulta-nAcresc+nDecresc
			Elseif lJurMulDes
				nBaseIrpf := nBaseIrpf - nTotAbat + Iif(lAltValor, 0, nAcresc - nDecresc + nJuros + nMulta - nDescont)
				nIrfBaseC := nIrfBaseC - nTotAbat + Iif(lAltValor, 0, nAcresc - nDecresc + nJuros + nMulta - nDescont)
			Endif
		ElseIf lBordBx .and. lJurMulDes
			nBaseIrpf := nBaseIrpf+SE2->(E2_ACRESC-E2_DECRESC)
		EndIf
	Endif
	
	// Verifica se o fornecedor trata o valor minimo de retencao.- FINANCEIRO
	If (lAplMinIR .And. (nValor <= nVlMinIr .and. !lIrfRetAnt)) .OR. nValor < 0 
		nValor := 0
	Endif

	//Reestruturacao SE5
	nIrfBaseR := nBaseIrpf		//Base de retenção do título

	//Possui retenção de impostos de outros títulos
	If (nValor > 0 .And. lAcumComPE .Or. lAcumSemPE) .And. (Len(aDadosIr[2]) > 0 .Or. Len(aDadosIr[3]) > 0 )
		nIrfBaseR += nBaseOutTit + nBasPdtDia
	Endif

	aRetIrf := aClone(aDadosIr)

	If aRetIrf[1] == 0
		aRetIrf[1] := nValor
	EndIf

	If !EMPTY(__oTemBXCanc)
		__oTemBXCanc:Destroy()
		__oTemBXCanc := NIL
	EndIf

	Restarea(aAreaSA2)
	RestArea(aArea)

Return (nValor)


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FAFIL10925

Considera filiais para calculo do PCC (FINA080/FINA241).
Arquivo anterior: FINXFUN.PRX

@Author	Jose Gavetti
@since	11/04/2013
/*/
//-----------------------------------------------------------------------------------------------------
Function FAFIL10925()

	Local aFilial := {}
	Local aRegSM0 := SM0->(GetArea())
	Local cEmpAtu := SM0->M0_CODIGO

	dbselectArea ("SM0")
	DbSetOrder(1)

	While !Eof() .and. SM0->M0_CODIGO == cEmpAtu
		AADD(aFilial,SM0->M0_CODFIL)
		dbSkip()
	Enddo

	SM0->(RestArea(aRegSM0))

Return (aFilial)


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRIATRBIR

Criação do TRB para cálculo do IRRF (ligada a FLOJASIRRF).
Arquivo anterior: FINXFUN.PRX

Parametros
ExpC1 := Empresa SM0
ExpC2 := Filial SM0
ExpL1 := Define entrada em modo Job
ExpN1 := ID da Thread Atual
ExpA1 := Array dos campos do TRB
ExpA2 := Array Com Codigos para alimentar TRB
ExpC3 := Nome do Arquivo Temporario a ser criado

@Author	Mauricio Pequim Jr.
@since	21/10/2008
/*/
//-----------------------------------------------------------------------------------------------------
Function CRIATRBIR(cEmp,cFil,lRpc,nTread,aCampos,aCliFor,cArqTmp)
	Local nX := 0
	Local cTableName:=cArqTmp

	If lRpc
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,"FIN",,, {"SED"}, /*lShowFinal*/, /*lAbend*/, .T. /*lOpenSX*/, /*lConnect*/)
	Endif

	If lRpc //-- InTransact() - Não é possivel utilizar FWTemporaryTable, pois no retorno da nova thread a tabela será dropada
		MsCreate(cArqTmp,aCampos,"TOPCONN")
		Sleep(1000)

		dbUseArea(.T.,"TOPCONN",cArqTmp,cArqTmp,.F.,.F.)
		DbSelectArea(cArqTmp)
		IndRegua(cArqTmp,cArqTmp,"CODIGO+LOJA")

		For nX:= 1 To Len(aCliFor)
			TcSqlExec('INSERT INTO '+cTableName+" (FILIALX,CODIGO,LOJA,R_E_C_N_O_) VALUES ('"+aCliFor[nX,1]+"','"+aCliFor[nX,2]+"','"+aCliFor[nX,3]+"',"+Alltrim(Str(nX))+")")			
		Next
	Else
		__oIRFIN:=FWTemporaryTable():New(cArqTmp)  
		__oIRFIN:SetFields(aCampos) 
		__oIRFIN:AddIndex("1", {"CODIGO","LOJA"})
		__oIRFIN:Create() 

		// -- Tabela criada no banco possui outro nome 
		cTableName:=__oIRFIN:GetTableNameForQuery()
		cTableName:= StrTran(cTableName, "dbo.", "") 

		For nX:= 1 To Len(aCliFor)
			TcSqlExec('INSERT INTO '+cTableName+" (FILIALX,CODIGO,LOJA) VALUES ('"+aCliFor[nX,1]+"','"+aCliFor[nX,2]+"','"+aCliFor[nX,3]+"')")		
		Next
	EndIf

	DBCommit()

Return(cTableName)


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EXCTRBIR

Funcao de EXCLUSAO do arquivo do IRRF em transacao.
Arquivo original: FINXFIN.PRX

@Author	Mauricio Pequim Jr.
@since	21/10/2008
/*/
//-----------------------------------------------------------------------------------------------------
Function EXCTRBIR(cEmp,cFil,lRPC,nTread,cArqTmp) 

Local lOK as Logical
lOK:=.T.

If lRPC
	RpcSetType(3)
	RpcSetEnv(cEmp,cFil,,"FIN",,, {"SED"}, /*lShowFinal*/, /*lAbend*/, .T. /*lOpenSX*/, /*lConnect*/)
Else
	If Select(cArqTmp)>0
		(cArqTmp)->(dbCloseArea())
	Endif
Endif

If __oIRFIN <> Nil	
	lOK := __oIRFIN:Delete()
	__oIRFIN := Nil
Else
	lOK := TcDelFile(cArqTmp)
EndIF

IF !lOK
	ConOutR("Falha ao detelar "+ cArqTmp)
	ConOutR(TcSqlError())
Endif

Return

/*/{Protheus.doc} FIRPJBXCR
	Define se a retenção do IR do contas a receber será na baixa 
	quando o cliente for PJ empresas mistas ou publicas.

	@Param lVerMotor, Logical, Define a utilização do calculo pelo Motor de retenções.
	@Return lIrPjBxCr, Logical, Indica se o cálculo do irrf está configurado na baixa.

@Author	Pâmela Bernardo
@since	28/02/2012
/*/
Function FIrPjBxCr(lVerMotor As Logical)
	Local lIrPjBxCr  As Logical
	Local lCallStack As Logical
	Local lIrfMR     As Logical
	Local aAreaAtual As Array

	//Parâmetros de entrada da função.
	DEFAULT lVerMotor	:= .F.

	//Inicializa variáveis
	lIrPjBxCr  := .F.
	lCallStack := ((Funname() == "FINA440") .Or. FwIsInCallStack("FINA070") .Or. FwIsInCallStack("FINA330"))
	lIrfMR 	   := .F.
	aAreaAtual := {}
	
	If lCallStack
		dbSelectArea("SA1")
		SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
	EndIf

	If lVerMotor .and. __lTemMR
		If __lRFiConf == Nil
			aAreaAtual := GetArea()
			DbSelectArea("FKK")
			FKK->(DbGotop())
			
			If (__lRFiConf := !Empty(FKK->FKK_CODIGO))
				DbSelectArea("FOI")
				FOI->(DbGotop())
				
				If (__lRFiConf := !Empty(FOI->FOI_CODIGO))
					DbSelectArea("FOJ")
					FOJ->(DbGotop())				
					__lRFiConf := !Empty(FOJ->FOJ_CODIGO)
				EndIf
			EndIf
			
			RestArea(aAreaAtual)
			FwFreeArray(aAreaAtual)		
		EndIf		
		
		If __lRFiConf 
			F070VerImp("2", cFilAnt, SE1->E1_CLIENTE, SE1->E1_LOJA, Nil, .T., @lIrPjBxCr, Nil, Nil, @lIrfMR)
		Endif
	Endif

	If __lLocBRA .And. !lIrfMR
		lIrPjBxCr := (!SA1->A1_ENTID $ "00|02|10" .And. SA1->A1_IRBAX == "1" .And. SA1->A1_PESSOA == "J")
	EndIf
Return lIrPjBxCr


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FRARTIMP

Define se ha retenção dos Impostos PCC/IRPJ no RA .
Arquivo anterior: FINXFUN.PRX

@Author	Andre Lago
@since	02/08/2012
/*/
//-----------------------------------------------------------------------------------------------------
Function FRaRtImp()

	Local	lRet := .F.
	Local 	nPos := 0

	If ValType(aRaRtImp) == "A"
		nPos:= Ascan(aRaRtImp,{|x| x[2] == cEmpAnt+cfilant})
	Endif

	If nPos > 0
		lRet:= aRaRtImp[nPos][1]
	Else
		lRet:= 	(SuperGetMv("MV_RARTIMP",.T.,"2") == "1")	.And. ;
				(SuperGetMv("MV_BQ10925",.T.,"1") == "2")   .And. ;
				(SuperGetMv("MV_BR10925",.T.,"2") == "1")
		Aadd(aRaRtImp,{ lRet, cEmpAnt+cfilant})
	Endif

Return lRet


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINRTPRET

Efetua retorno dos valores E2_PRET.
Arquivo anterior: FINXFUN.PRX

@Author	Pâmela Bernardo
@since	18/06/2014
/*/
//-----------------------------------------------------------------------------------------------------
Function FinRtPret(cSeq)
	Local cPret:=""
	LOCAL cAlias := GetNextAlias()

	Local nSE5  		:= 0
	Local cQuery	  	:= ""
	Local aStruSE5	  	:= {}

	Default cSeq:= SE5->E5_SEQ

	cQuery := "SELECT SE5.E5_FILIAL, SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, "
	cQuery += "SE5.E5_TIPO, SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_SEQ,SE5.E5_MOTBX, "
	cQuery += "SE5.E5_VALOR, E5_VRETPIS, E5_VRETCOF, E5_VRETCSL, E5_VRETIRF, E5_PRETIRF, E5_PRETPIS, E5_PRETCOF, E5_PRETCSL"
	cQuery += "FROM "+RetSqlName("SE5") + " SE5"
	cQuery += "WHERE "
	cQuery += "SE5.E5_FILIAL = '"+xFilial("SE2")+"' AND "
	cQuery += "SE5.E5_PREFIXO ='" + SE2->E2_PREFIXO +"' AND "
	cQuery += "SE5.E5_NUMERO = '" + SE2->E2_NUM +"' AND "
	cQuery += "SE5.E5_PARCELA ='" + SE2->E2_PARCELA +"' AND "
	cQuery += "SE5.E5_TIPO = '" + SE2->E2_TIPO +"' AND "
	cQuery += "SE5.E5_CLIFOR = '" + SE2->E2_FORNECE +"' AND "
	cQuery += "SE5.E5_LOJA = '" + SE2->E2_LOJA +"' AND "
	cQuery += "SE5.E5_MOTBX NOT IN ('FAT','IRF','PCC','LIQ','STP','IMR') AND "
	cQuery += "SE5.E5_RECPAG = 'P' AND "
	cQuery += "SE5.E5_TIPODOC <>'ES' AND "
	cQuery += "SE5.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY "
	cQuery += "SE5.E5_FILIAL, SE5.E5_TIPODOC, SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, "
	cQuery += "SE5.E5_TIPO, SE5.E5_DATA, SE5.E5_SEQ"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cAlias),.T.,.T.)

	aStruSE5:= SE5->(dbStruct())

	For nSE5 := 1 To Len(aStruSE5)
		If aStruSE5[nSE5][2] <> "C" .and.  FieldPos(aStruSE5[nSE5][1]) > 0
			TcSetField((cAlias),aStruSE5[nSE5][1],aStruSE5[nSE5][2],aStruSE5[nSE5][3],aStruSE5[nSE5][4])
		EndIf
	Next nSE5

	While (cAlias)->(!EOF())

		//Verifica se tem baixa cancelada
		If TemBxCanc((cAlias)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ),.F.)
			(cAlias)->( dbskip())
			loop
		EndIf

		If (cAlias)->E5_SEQ <> CSeq
			If (cAlias)->E5_MOTBX =="CMP"
				cPret:="7"
			Else
				cPret:="3"
			Endif
			Exit
		Endif
		(cAlias)->(DbSkip())
	EndDo


Return cPret


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PABRTCOMP

Funcao que a partir do titulo principal verifica as compensacoes e retorna o valor referente a baixa de
imposto de um PA Bruto (FINA080/FINA241/FINA290/FINA374)
Arquivo anterior: FINXFUN.PRX

@Author	Marcel Borges
@since	16/11/2007
/*/
//-----------------------------------------------------------------------------------------------------
Function PABrtComp(lGrava,lCancela)
	LOCAL aArea      := GetArea()
	LOCAL cTipoDoc   := "CP"
	LOCAL nValor     := 0
	LOCAL aBaixas    := {}
	LOCAL cPrefixo   := SE2->E2_PREFIXO
	LOCAL cNum       := SE2->E2_NUM
	LOCAL cParcela   := SE2->E2_PARCELA
	LOCAL	cTipoTit   := SE2->E2_TIPO
	LOCAL nX
	LOCAL lPaBruto	  := GetNewPar("MV_PABRUTO","2") == "1"  //Indica se o PA tera o valor dos impostos descontados do seu valor

	LOCAL aStruSE5
	LOCAL cFornece   := SE2->E2_FORNECE
	LOCAL cLoja      := SE2->E2_LOJA
	LOCAL nSE5

	Default lGrava   := .F.
	Default lCancela := .F.

	If lPaBruto

		cQuery := "SELECT SE5.E5_FILIAL, SE5.E5_TIPODOC, SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, "
		cQuery += "SE5.E5_TIPO, SE5.E5_DATA, SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_SEQ, "
		cQuery += "SE5.E5_DOCUMEN, SE5.E5_SEQ, SE5.E5_VALOR, SE5.E5_PRETPIS, SE5.R_E_C_N_O_ E5_RECNO, "
		cQuery += "SE2.E2_VALOR "
		cQuery += ", SE5.E5_FORNADT, SE5.E5_LOJAADT, SE2.E2_FORNECE, SE2.E2_LOJA "
		cQuery += "FROM "+RetSqlName("SE5") + " SE5, "
		cQuery += RetSqlName("SE2") + " SE2 "
		cQuery += "WHERE "
		cQuery += "SE5.E5_FILIAL = '"+xFilial("SE5")+"' AND "
		cQuery += "SE2.E2_FILIAL = '"+xFilial("SE2")+"' AND "
		cQuery += "SE5.E5_PREFIXO = SE2.E2_PREFIXO AND "
		cQuery += "SE5.E5_NUMERO = SE2.E2_NUM AND "
		cQuery += "SE5.E5_PARCELA = SE2.E2_PARCELA AND "
		cQuery += "SE5.E5_TIPO = SE2.E2_TIPO AND "
		cQuery += "SE5.E5_CLIFOR = SE2.E2_FORNECE AND "
		cQuery += "SE5.E5_LOJA = SE2.E2_LOJA AND "
		cQuery += "SE5.E5_TIPODOC = '"+cTipoDoc+"' AND "
		cQuery += "SE5.E5_MOTBX = 'CMP' AND "
		cQuery += "SE5.E5_RECPAG = 'P' AND "
		cQuery += "SE5.E5_PREFIXO ='"+cPrefixo+"' AND "
		cQuery += "SE5.E5_NUMERO ='"+cNum+"' AND "
		cQuery += "SE5.E5_PARCELA ='"+cParcela+"' AND "
		cQuery += "SE5.E5_TIPO = '"+cTipoTit+"' AND "
		cQuery += "SE5.E5_CLIFOR = '"+cFornece+"' AND "
		cQuery += "SE5.E5_LOJA = '"+cLoja+"' AND "
		cQuery += "SE5.D_E_L_E_T_ = ' ' AND "
		cQuery += "SE2.D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY "
		cQuery += "SE5.E5_FILIAL, SE5.E5_TIPODOC, SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, "
		cQuery += "SE5.E5_TIPO, SE5.E5_DATA, SE5.E5_SEQ"

		cQuery := ChangeQuery(cQuery)

		// Já existe uma work TRB qdo a rotina trabalha de forma integrada com o SIGAEIC
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.T.)

		aStruSE5:= SE5->(dbStruct())

		For nSE5 := 1 To Len(aStruSE5)
			If aStruSE5[nSE5][2] <> "C" .and.  FieldPos(aStruSE5[nSE5][1]) > 0
				TcSetField("TRBTMP",aStruSE5[nSE5][1],aStruSE5[nSE5][2],aStruSE5[nSE5][3],aStruSE5[nSE5][4])
			EndIf
		Next nSE5

		While TRBTMP->(!EOF())
			// Verifica o fornecedor do Adto. apenas se estiver posicionado do
			// titulo de PA ao fazer a exclusao.
			If cTipoTit $ MVPAGANT .And.;
				TRBTMP->(E5_FORNADT+E5_LOJAADT)	!= SE2->(E2_FORNECE+E2_LOJA) .And.;
				TRBTMP->(E5_CLIFOR+E5_LOJA) 		!= SE2->(E2_FORNECE+E2_LOJA)
				DbSkip()
				Loop
			Endif

			//Verifica se a data base do sistema eh menor que a data de compensacao dos titulos
			If DTOS(dDataBase) < DTOS(TRBTMP->E5_DATA)
				dbSkip()
				Loop
			EndIf

			//Verifica se tem baixa cancelada
			If TemBxCanc(TRBTMP->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ),.T.)
				TRBTMP->( dbskip())
				loop
			EndIf

			//Verifica se e uma baixa de impostos de PA Bruto
			If TRBTMP->E5_PRETPIS == "5" .and. Empty(SE2->E2_TITADT) .and. !lCancela
				nValor += TRBTMP->E5_VALOR
				AADD(aBaixas, TRBTMP->E5_RECNO)
			Elseif TRBTMP->E5_PRETPIS == "6" .and. TRIM(SE2->E2_TITADT) == "1" .and. lCancela
				nValor := 0
				AADD(aBaixas, TRBTMP->E5_RECNO)
			EndIf

			TRBTMP->(DbSkip())
		EndDo

		dbSelectArea( "TRBTMP")
		dbCloseArea()

		If lGrava
			RecLock("SE2", .F. )
			SE2->E2_TITADT := "1"
			MsUnlock()
			For nX := 1 to Len(aBaixas) step 1
				SE5->(MsGoTo(aBaixas[nX]))
				RecLock("SE5", .F. )
				SE5->E5_PRETPIS := "6"
				SE5->E5_PRETCOF := "6"
				SE5->E5_PRETCSL := "6"
				MsUnlock()
			Next
		ElseIf lCancela
			RecLock("SE2", .F. )
			SE2->E2_TITADT := ""
			MsUnlock()
			For nX := 1 to Len(aBaixas) step 1
				SE5->(MsGoTo(aBaixas[nX]))
				RecLock("SE5", .F. )
				SE5->E5_PRETPIS := "5"
				SE5->E5_PRETCOF := "5"
				SE5->E5_PRETCSL := "5"
				MsUnlock()
			Next
		EndIf

	EndIf

	RestArea(aArea)

Return nValor


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FGRVSFQIR

Grava relacionamento de retenção de impostos (tabela SFQ) para IRRF.
Arquivo anterior: FINXFUN.PRX

@Author	Mauricio Pequim Jr.
@since	29/08/2011
/*/
//-----------------------------------------------------------------------------------------------------
Function FGrvSFQIR(nIrrf,nBaseIrrf,aDadosIr,cSequencia,cCamposIR,cIdFk4)
	Local nVlMinIr	:= GetMv("MV_VLRETIR",,0)
	Local nSavRec	:= 0
	Local cPrefOri  := SE2->E2_PREFIXO
	Local cNumOri   := SE2->E2_NUM
	Local cParcOri  := SE2->E2_PARCELA
	Local cTipoOri  := SE2->E2_TIPO
	Local cCfOri    := SE2->E2_FORNECE
	Local cLojaOri  := SE2->E2_LOJA
	Local aRecnos	:= {}
	Local nLoop		:= 0
	Local lAplVlMin := .F.
	Local lTitInBord := ( IsInCallStack("FINA241") .OR. IsInCallStack("FINA590") )
	Local aAreaSE2 	:= SE2->(GetArea())
	Local aAreaSA2	:= SA2->(GetArea())
	Local cTipo		:= "J"
	Local lTitInBx   := IsIncallStack("FINA080")
	Local lEmpPub	:= .F. 
	Local nVlMPub	:= SuperGetMv("MV_VLMPUB" ,.T.,10)
	Local lEmpGImp := .F.
	Local lAplMinP := .F.

	DEFAULT nIrrf := 0
	DEFAULT nBaseIrrf := 0
	DEFAULT aDadosIr := {0,{},{}}
	DEFAULT cSequencia := "00"
	DEFAULT cCamposIR := ""
	DEFAULT cIdFk4	:= ""

	If type("nPis") <> "N"
		nPis := SE2->E2_PIS
	EndIf

	If type("nCoFins") <> "N"
		nCoFins := SE2->E2_COFINS
	EndIf

	If type("nCsll") <> "N"
		nCsll := SE2->E2_CSLL
	EndIf

	If type("aDadosRet") <> "A"
		aDadosRet := Array(7)
		AFill( aDadosRet, 0 )
	Else
		Aeval(aDadosRet, {|x,y| Iif(x==NIL,aDadosRet[y]:=0,)})
	EndIf

	If type("nVlRetIrf") <> "N"
		nVlRetIrf := 0
	EndIf

	If type("aImpPub") <> "A"
		aImpPub	:= Array(3)
		AFill( aImpPub, 0)
	EndIf

	If type("nMulta") <> "N"
		nMulta := 0
	EndIf

	If type("nJuros") <> "N"
		nJuros := 0
	EndIf

	If type("nIrfCalc") <> "N"
		nIrfCalc := 0
	EndIf	

	//Garanto o posicionamento do SA2 para verificacoes
	SA2->(dbSetOrder(1))
	SA2->(MsSeek(xFilial("SA2")+cCfOri+cLojaOri))

	// Verifica se o fornecedor trata o valor minimo de retencao.
	// 1 - Não considera  2 - Considera o parâmetro MV_VLRETIR
	If SA2->A2_MINIRF == "2"
		lAplVlMin := .T.
	Endif

	lEmpPub	:= IsEmpPub()	.And. IIf(cPaisLoc == "BRA", SA2->A2_CALCIRF == "2", .F.)
	If SA2->A2_MINPUB == "2"
		lAplMinP := .T.
	EndIF

	lEmpGImp := !(lEmpPub  .And. (nPis+nCoFins+nCsll+nIrrf+aDadosRet[2]+aDadosRet[3]+aDadosRet[4]+aDadosRet[5] < nVlMPub .And.;
			!(aDadosRet[2]+aDadosRet[3]+aDadosRet[4]+aDadosRet[5] == 0 .And. aDadosRet[1] > 0)) )

	//Se vier do FINA241 terá o array aImpPub preenchido, caso venha zerado, já houve retenção, então não precisa ver o mínimo, pois ja atingiu.
	If lEmpPub .And. FwIsInCallStack("Fa241Borde") .AND. ((AllTrim(SE2->E2_PRETIRF) == "" .and. SE5->E5_PRETIRF == "4") .or. aDadosIR[1] + nIrrf	> nVlMPub)//nPis+nCoFins+nCsll+nIrrf+aImpPub[1]+aImpPub[2]+aImpPub[3]> nVlMPub)
		lEmpGImp	:= .T.
	EndIf
	If lEmpPub .And. !lAplMinP
		lEmpGImp	:= .T.
	EndIf

	cTipo := If( Empty(SA2->A2_TIPO),"J",SA2->A2_TIPO )
	If SA2->A2_TIPO == 'J' .AND. SA2->A2_IRPROG == '1' .and. !Empty(SA2->A2_CPFIRP)
		cTipo := "F"
	Endif

	//Verifico se atingiu o minimo para retencao ou se este nao se aplica
	If (aDadosIR[1] + nIrrf	> nVlMinIr .OR. !lAplVlMin) .And. lEmpGImp

		lRetParc := .T.

		//------------------------------------------------------------------
		// Exclui a Marca de "pendente recolhimento" dos demais registros
		//------------------------------------------------------------------
		If ValType(aDadosIR[2]) == "A"
			If Len(aDadosIR[2]) > 0
				aRecnos := aClone( aDadosIR[ 2 ] )
				FK3->(dbSetOrder(2))	//FK3_FILIAL+FK3_TABORI+FK3_IDORIG+FK3_IMPOS
				For nLoop := 1 to Len( aRecnos )

					SE5->( dbGoto( aRecnos[ nLoop ] ) )

					If !Empty(SE5->E5_IDORIG)
						If FK3->(MsSeek(xFiliaL('FK3') + SE5->(E5_TABORI+E5_IDORIG) + 'IRF'))
							RecLock("FK3")
							FK3_IDRET := cIdFk4
							MsUnlock()
						Endif
							
						If SE5->E5_PRETIRF == "1"
							RecLock("SE5")
							SE5->E5_PRETIRF := '2'
						Endif
					Endif

					dbSelectArea("SFQ")
					RecLock("SFQ",.T.)
					SFQ->FQ_FILIAL  := xFilial("SFQ")
					SFQ->FQ_ENTORI  := "SE5"
					SFQ->FQ_PREFORI := cPrefOri
					SFQ->FQ_NUMORI  := cNumOri
					SFQ->FQ_PARCORI := cParcOri
					SFQ->FQ_TIPOORI := cTipoOri
					SFQ->FQ_CFORI   := cCfOri
					SFQ->FQ_LOJAORI := cLojaOri
					SFQ->FQ_SEQORI  := cSequencia
					SFQ->FQ_TPIMP	:= "IRF"

					SFQ->FQ_ENTDES  := "SE5"
					SFQ->FQ_PREFDES := SE5->E5_PREFIXO
					SFQ->FQ_NUMDES  := SE5->E5_NUMERO
					SFQ->FQ_PARCDES := SE5->E5_PARCELA
					SFQ->FQ_TIPODES := SE5->E5_TIPO
					SFQ->FQ_CFDES   := SE5->E5_CLIFOR
					SFQ->FQ_LOJADES := SE5->E5_LOJA
					SFQ->FQ_SEQDES  := SE5->E5_SEQ
					SFQ->FQ_FILDES	:= SE5->E5_FILIAL

					MsUnlock()

					//Grava status de recolhimento do IRRF
					SE2->(dbSetOrder(2))
					If SE2->(MsSeek(xFilial("SE2")+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)))
						RecLock( "SE2", .F. )
						If SE2->E2_PRETIRF == "1"
							SE2->E2_PRETIRF := "2"
						Endif
						SE2->( MsUnlock() )
					Endif

				Next nLoop
			Endif
		EndIf

		// Exclui a Marca de "pendente recolhimento" dos demais registros
		If ValType(aDadosIR[3]) == "A"

			nSavRec := SE2->( Recno() )

			If Len(aDadosIR[3]) > 0
				aRecnos := aClone( aDadosIR[ 3 ] )

				For nLoop := 1 to Len( aRecnos )

					SE2->( dbGoto( aRecnos[ nLoop ] ) )

					RecLock( "SE2", .F. )

					If SE2->E2_PRETIRF == "1"
						SE2->E2_PRETIRF := "2"
					Endif

					SE2->( MsUnlock() )

					If nSavRec <> aRecnos[ nLoop ]
						dbSelectArea("SFQ")
						RecLock("SFQ",.T.)
						SFQ->FQ_FILIAL  := xFilial("SFQ")
						SFQ->FQ_ENTORI  := "SE2"
						SFQ->FQ_PREFORI := cPrefOri
						SFQ->FQ_NUMORI  := cNumOri
						SFQ->FQ_PARCORI := cParcOri
						SFQ->FQ_TIPOORI := cTipoOri
						SFQ->FQ_CFORI   := cCfOri
						SFQ->FQ_LOJAORI := cLojaOri
						SFQ->FQ_SEQORI  := cSequencia
						SFQ->FQ_TPIMP	:= "IRF"

						SFQ->FQ_ENTDES  := "SE2"
						SFQ->FQ_PREFDES := SE2->E2_PREFIXO
						SFQ->FQ_NUMDES  := SE2->E2_NUM
						SFQ->FQ_PARCDES := SE2->E2_PARCELA
						SFQ->FQ_TIPODES := SE2->E2_TIPO
						SFQ->FQ_CFDES   := SE2->E2_FORNECE
						SFQ->FQ_LOJADES := SE2->E2_LOJA
						SFQ->FQ_SEQDES  := cSequencia
						SFQ->FQ_FILDES	:= SE2->E2_FILIAL

						MsUnlock()
					Endif
				Next nLoop
			EndIf
		EndIf

		//---------- ATENCAO -------------------------------------------------------------------------------------
		//O campo E5_BASEIRF grava o valor de Base de IRRF utilizada ref. a base do titulo
		//e nao a base utilizada para calculo. Faz-se isso para que, em caso de cancelamento da
		//baixa que reteve o imposto de outra, possamos calcular corretamente o imposto
		//Exemplo:
		//Titulo de R$ 10.000
		//Baixa 1 no valor de R$ 500 - nao reteve o imposto
		//Base gravada = R$ 500 (base baixada)
		//Baixa 2 no valor de R$ 500 - reteve o imposto da baixa 1 e 2
		//Base gravada = R$ 500 (base baixada)
		//Baixa 3 no valor restante - reteve o imposto da baixa 3
		//Base gravada = R$ 9.000 (base baixada)
		//Caso se cancele a baixa 2, o saldo do titulo fica igual ao valor efetivamente baixado mais o IR retido.
		//Teremos o saldo do titulo igual R$ 515 (R$ 500 do titulo + R$ 15 do IR que havia sido retido).
		//Na rotina de calculo do IR, busco as bases utilizadas do titulo (9.500) e tiro da base efetiva
		//gravada no E2_BASEIRF. Com isso teremos
		//Baixa 4 no valor de R$ 500 - reteve o imposto da baixa 1 e 4
		//Base gravada = R$ 500
		cPRetIRF  := If(lTitInBord,"4"," ")
		cCamposIR := ",{'E5_VRETIRF' , "+CVALTOCHAR(nIrrf)+" }"
		cCamposIR += ",{'E5_PRETIRF' , '"+cPRetIRF+"'}"
		cCamposIR += ",{'E5_BASEIRF' , "+CVALTOCHAR(nBaseIrrf)+" }"

	Else
		//IRRF PENDENTE DE RETENCAO
		If cTipo == "F"
			lOk := (nBaseIrrf > 0 .and. !lTitInBord)
		Else
			lOk := ((nVlRetIrf > 0 .or. nIrfCalc > 0) .and. nIrrf == 0 .and. !lTitInBord)
		Endif

		If lOk .Or. !lEmpGImp

			//---------- ATENCAO -------------------------------------------------------------------------------------
			//O campo E5_BASEIRF grava o valor de Base de IRRF utilizada ref. a base do titulo
			//e nao a base utilizada para calculo. Faz-se isso para que, em caso de cancelamento da
			//baixa que reteve o imposto de outra, possamos calcular corretamente o imposto
			//Exemplo:
			//Titulo de R$ 10.000
			//Baixa 1 no valor de R$ 500 - nao reteve o imposto
			//Base gravada = R$ 500 (base baixada)
			//Baixa 2 no valor de R$ 500 - reteve o imposto da baixa 1 e 2
			//Base gravada = R$ 500 (base baixada)
			//Baixa 3 no valor restante - reteve o imposto da baixa 3
			//Base gravada = R$ 9.000 (base baixada)
			//Caso se cancele a baixa 2, o saldo do titulo fica igual ao valor efetivamente baixado mais o IR retido.
			//Teremos o saldo do titulo igual R$ 515 (R$ 500 do titulo + R$ 15 do IR que havia sido retido).
			//Na rotina de calculo do IR, busco as bases utilizadas do titulo (9.500) e tiro da base efetiva
			//gravada no E2_BASEIRF. Com isso teremos
			//Baixa 4 no valor de R$ 500 - reteve o imposto da baixa 1 e 4
			//Base gravada = R$ 500
			cCamposIR := ",{'E5_VRETIRF' , "+CVALTOCHAR(nVlRetIrf)+" }"
			cCamposIR += ",{'E5_PRETIRF' , '1'}"
			cCamposIR += ",{'E5_BASEIRF' , "+CVALTOCHAR(nBaseIrrf)+" }"

		EndIf
		lRetParc := .F.
	EndIf

	//Realiza a Gravação da tabela SE5 quando Forcedor não trata o valor minimo de retencao.
	// 1 Não considera  2 Considera o parâmetro MV_VLRETIR. Para Cancelamento da baixa.
	If (SA2->A2_MINIRF == "1" .and. nIrrf > 0 .and. nIrrf < nVlMinIr) .and. lTitInBx
		cCamposIR := ",{'E5_VRETIRF' , "+CVALTOCHAR(nIrrf)+" }"
		cCamposIR += ",{'E5_PRETIRF' , ' '}"
		cCamposIR += ",{'E5_BASEIRF' , "+CVALTOCHAR(nBaseIrrf)+" }"
	Endif

	SA2->(RestArea(aAreaSA2))
	SE2->(RestArea(aAreaSE2))


Return


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FGSFQIRCR

Gravar a SFQ para IR do contas a receber.
Arquivo anterior: FINXFUN.PRX

@Author	Pâmela Bernardo
@since	05/03/2012
/*/
//-----------------------------------------------------------------------------------------------------
Function FGSFQIRCR(nIrrf,nBaseIrrf,cSequencia,nDescont,nJuros,nMulta,cCamposIR)
	Local cCfOri    := SE5->E5_CLIFOR
	Local cLojaOri  := SE5->E5_LOJA
	Local aAreaSA1	:= SA1->(GetArea())
	Local aAreaSE1 	:= SE1->(GetArea())
	//Controla IRPJ na baixa
	Local lIrPjBxCr	:= FIrPjBxCr(.T.)
	Local lAlt 		:= .F.
	//Controla o Pis Cofins e Csll na baixa  (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default) )
	Local lPccBxCr 	:= FPccBxCr(.T.)
	Local lJurMulDes:= (SuperGetMv("MV_IMPBAIX",.t.,"2") == "1")
	Local aImpostos := {}
	Local nX 		:= 0
	Local cIdFK4 	:= ""
	Local cIdFK4IR	:= ""
	Local oSubFK1	:= NIL
	Local oSubFK3	:= NIL
	Local oSubFK4	:= NIL
	Local oSubFK5	:= NIL
	Local cIdFK1	:= ""
	Local cLog		:= ""
	Local lTiraIRRF := .T.
	Local nValorAlt := 0
	Local nTotIRRF	:= 0
	Local cQuery:= ""
	Local cAliasQry := ""
	Local lMvGlosa 		:= SuperGetMv("MV_GLOSA",.F.,.F.)

	DEFAULT nIrrf := 0
	DEFAULT nBaseIrrf := 0
	DEFAULT cSequencia := "00"
	DEFAULT nDescont:= 0
	DEFAULT nJuros:= 0
	DEFAULT nMulta:= 0
	Default cCamposIR := ''

	If FwIsInCallStack( "FINA070" )
		If Type("nOldIrrf") == "U"
			nOldIrrf := 0
		Endif
		lAlt := ( nIrrf <> nOldIrrf )
	EndIf

	If !FwIsInCallStack( "FINA330" )
		If !lAlt 
			//Se não houve alteração e se o saldo do título for diferente do valor, então é a última baixa parcial
			If lMvGlosa //Base de calculo com glosa é sempre o valor do titulo
				nBaseIrrf := SE1->E1_VALOR
			ElseIf SE1->E1_VALOR <> SE1->E1_SALDO 
				//Query para pegar o total de IRRF, referente as baixas parciais, para somar na variável nBaseIrrf e gravar a base correta
				cQuery := "SELECT SUM(E1_VALOR) TOTIRRF FROM " + RetSQLName("SE1")
				cQuery += " WHERE  E1_FILIAL = '" + FWxFilial("SE1") + "'"
				cQuery += " AND E1_CLIENTE = '" + SE1->E1_CLIENTE + "'"
				cQuery += " AND E1_LOJA = '" + SE1->E1_LOJA + "'"
				cQuery += " AND E1_PREFIXO = '" + SE1->E1_PREFIXO + "'"
				cQuery += " AND E1_NUM = '" + SE1->E1_NUM + "'"
				cQuery += " AND (E1_TIPO = 'IRF'"
				If lPccBxCr
					cQuery += " OR E1_TIPO = 'PIS'"
					cQuery += " OR E1_TIPO = 'COF'"
					cQuery += " OR E1_TIPO = 'CSL'"
				Endif
				cQuery += ") AND D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery( cQuery )

				cAliasQry := GetNextAlias()
				dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )
				If ( cAliasQry )->( !EOF() )
					nTotIRRF := ( cAliasQry )->TOTIRRF
				Endif
				( cAliasQry )->( DbCloseArea() )

				nBaseIrrf += (nTotIRRF + nDescont + nTotAbat - nJuros - nMulta )
			Else
				nBaseIrrf += ( nDescont - nJuros - nMulta )
			Endif

			If lPccBxCr .AND. FwIsInCallStack( "FINA110" )
				nBaseIrrf += ( nPis + nCofins + nCsll )
			Endif
			
		Else
			If lPccBxCr
				nBaseIrrf -=  (If(lIrPjBxCr, 0, nIrrf) + (nPis + nCofins + nCsll))
			Else
				nBaseIrrf -= nIrrf
			Endif
		EndIf
	Endif

	dbSelectArea("SED")
	dbSetOrder(1)
	DbSeek(xFilial("SED")+SE1->E1_NATUREZ)

	//Garanto o posicionamento do SA1 para verificacoes
	SA1->(dbSetOrder(1))
	SA1->(MsSeek(xFilial("SA1")+cCfOri+cLojaOri))

	If FwIsInCallStack("FINA110") .OR. FwIsInCallStack("FINA330") .OR. FwIsInCallStack("FINA200") .OR. (lIrPjBxCr .AND. lPccBxCr)
		lTiraIRRF := .F.
	Endif

	nIrfCalc  := If(Type("nIrfCalc") == "U"  ,nIrrf     ,nIrfCalc)
	nIrfBaseC := If(Type("nIrfBaseC") == "U" ,nBaseIrrf ,nIrfBaseC)
	nIrfBaseR := If(Type("nIrfBaseR") == "U" ,nBaseIrrf ,nIrfBaseR)

	If nIrfCalc > 0 .and. lIrPjBxCr .And. !(SE5->E5_TIPO $ MVRECANT +"|"+ MV_CRNEG)

		lRetParc := .T.

		dbSelectArea( "FK1" )
		FK1->( DbSetOrder( 1 ) )
		If FK1->( MsSeek( FWxFilial("FK1") + SE5->E5_IDORIG ) )
			cCamposIR := "{"
			cCamposIR += " {'E5_VRETIRF' ,  " + cValToChar(nIrrf) + " } "
			cCamposIR += ",{'E5_PRETIRF',' ' }"
			If lTiraIRRF
				nValorAlt := FK1->FK1_VALOR - nIrrf
				cCamposIR += ",{'E5_VALOR', " + cValToChar( nValorAlt ) + " } "
			Endif
			If lAlt .AND. !lJurMulDes
				cCamposIR += ",{'E5_BASEIRF', " + cValToChar(nIrfBaseR) + " } "
				aadd(aImpostos,{"IRF",nIrfCalc,&(SuperGetMV("MV_IRF")),"" , nIrrf   , nIrfBaseC, nIrfBaseR,""})
			Else
				cCamposIR += ",{'E5_BASEIRF',"   +cValToChar(nIrfBaseR) + "}"
				aadd(aImpostos,{"IRF",nIrfCalc,&(SuperGetMV("MV_IRF")),"" , nIrrf   , nIrfBaseC, nIrfBaseR,""})
			Endif
			cCamposIR+= "}"

			oModelMov := FWLoadModel("FINM010")
			oModelMov:SetOperation( 4 ) //Alteração
			oModelMov:Activate()
			oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação de SE5
			oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposIR ) //Informa os campos da SE5 que serão gravados indepentes de FK1

			oSubFK1 := oModelMov:GetModel("FK1DETAIL")
			oSubFK3 := oModelMov:GetModel("FK3DETAIL")
			oSubFK4 := oModelMov:GetModel("FK4DETAIL")
			oSubFK5 := oModelMov:GetModel("FK5DETAIL")
			oSubFKA := oModelMov:GetModel("FKADETAIL")

			If oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
				cIdFK1 := oSubFK1:GetValue("FK1_IDFK1")

				//Se já tem IR, não salva de novo
				If !FXBuscaIRF( oModelMov )
					//Grava FK3 E/OU FK4
					For nX := 1 to Len(aImpostos)
						//Gravar FK4 se os valores de PCC forem maiores que zero
						If aImpostos[nX][2] > 0

							cIdFK4 := ""
							If aImpostos[nX][5] > 0   //Houve retencao
								cIdFK4:= FINFKSID('FK4', 'FK4_IDFK4')
								aImpostos[nX,4] := cIdFK4

								//Guardo o IDFK4 do IRF para usar posteriormente
								If aImpostos[nX,1] == "IRF"
									cIdFK4IR := cIdFK4
								Endif
							Endif

							If !oSubFK3:IsEmpty()
								//Inclui a quantidade de linhas necessárias
								oSubFK3:AddLine()

								//Vai para linha criada
								oSubFK3:GoLine( oSubFK3:Length() )
							Endif

							//---------------------------------------------
							// Grava Imposto calculado
							//---------------------------------------------
							oSubFK3:SetValue( "FK3_IDFK3" , FINFKSID('FK3', 'FK3_IDFK3'))
							oSubFK3:SetValue( "FK3_DATA"  , dDataBase )
							oSubFK3:SetValue( "FK3_ORIGEM", FunName() )
							oSubFK3:SetValue( "FK3_IMPOS" , aImpostos[nX][1] )
							oSubFK3:SetValue( "FK3_RECPAG", "R" )
							oSubFK3:SetValue( "FK3_MOEDA" , "01" )
							oSubFK3:SetValue( "FK3_VALOR" , aImpostos[nX][2] )
							oSubFK3:SetValue( "FK3_NATURE", aImpostos[nX][3] )
							oSubFK3:SetValue( "FK3_FILORI", SE1->E1_FILORIG  )
							oSubFK3:SetValue( "FK3_BASIMP", aImpostos[nX][6] )
							oSubFK3:SetValue( "FK3_IDORIG", cIdFK1 )
							oSubFK3:SetValue( "FK3_TABORI", "FK1")
							oSubFK3:SetValue( "FK3_IDRET" , aImpostos[nx,4] )

							If __lTemMR
								oSubFK3:SetValue( "FK3_CODFKM", aImpostos[nX,8] )
								oSubFK3:SetValue( "FK3_CLIFOR", SA1->A1_COD )
								oSubFK3:SetValue( "FK3_LOJA"  , SA1->A1_LOJA )
								oSubFK3:SetValue( "FK3_CGC"   , SA1->A1_CGC )
								oSubFK3:SetValue( "FK3_RAICGC", Substr(SA1->A1_CGC, 1, 8) )
							Endif   

							//---------------------------------------------
							// Grava Imposto Retido
							//---------------------------------------------
							If aImpostos[nX][5] > 0   //Houve retencao
								If !oSubFK4:IsEmpty()
									//Inclui a quantidade de linhas necessárias
									oSubFK4:AddLine()

									//Vai para linha criada
									oSubFK4:GoLine( oSubFK4:Length() )
								Endif

								oSubFK4:SetValue( "FK4_IDFK4" , aImpostos[nx,4])
								oSubFK4:SetValue( "FK4_DATA"  , dDataBase )
								oSubFK4:SetValue( "FK4_ORIGEM", FunName() )
								oSubFK4:SetValue( "FK4_IMPOS" , aImpostos[nx,1] )
								oSubFK4:SetValue( "FK4_RECPAG", "R" )
								oSubFK4:SetValue( "FK4_MOEDA" , "01" )
								oSubFK4:SetValue( "FK4_VALOR" , aImpostos[nX,5] )
								oSubFK4:SetValue( "FK4_NATURE", aImpostos[nX,3])
								oSubFK4:SetValue( "FK4_FILORI", SE1->E1_FILORIG )
								oSubFK4:SetValue( "FK4_BASIMP", aImpostos[nX][7] )

								If __lTemMR 
									oSubFK4:SetValue( "FK4_CODFKM", aImpostos[nX,8] )
									oSubFK4:SetValue( "FK4_CLIFOR", SA1->A1_COD )
									oSubFK4:SetValue( "FK4_LOJA"  , SA1->A1_LOJA )
									oSubFK4:SetValue( "FK4_CGC"   , SA1->A1_CGC )
									oSubFK4:SetValue( "FK4_RAICGC", Substr(SA1->A1_CGC, 1, 8) )
								Endif

							Endif
						Endif
					Next nX
				Else //Se já tem IR, corrige a base do IR
					If !lAlt
						If oSubFK3:SeekLine( { {"FK3_IMPOS", "IRF" } } )
							oSubFK3:SetValue( "FK3_BASIMP", nIrfBaseC )
						Endif

						If oSubFK4:SeekLine( { {"FK4_IMPOS", "IRF" } } )
							oSubFK4:SetValue( "FK4_BASIMP", nIrfBaseR )
						Endif
					Endif

				Endif

				//Atualiza os valores da FK1 e FK5, removendo o valor do IR para a correta gravação
				If lTiraIRRF
					For nX := 1 To oSubFKA:Length()
						oSubFKA:GoLine(nX)
						If !oSubFK1:IsEmpty()
							oSubFK1:SetValue( "FK1_VALOR", nValorAlt )
						Endif
						If !oSubFK5:IsEmpty()
							oSubFK5:SetValue( "FK5_VALOR", nValorAlt )
						Endif
					Next nX
				Endif

				If oModelMov:VldData()
					oModelMov:CommitData()
					SE5->(dbGoto(oModelMov:GetValue( "MASTER", "E5_RECNO" )))
				Else
					cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
					cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
					cLog += cValToChar(oModelMov:GetErrorMessage()[6])
				Help( ,,"FXFIRCR01",,cLog, 1, 0 )
				Endif
				oModelMov:DeActivate()
				oModelMov:Destroy()
				oModelMov:= Nil

			Endif
		EndIF
	EndIf

	SA1->(RestArea(aAreaSA1))
	SE1->(RestArea(aAreaSE1))

Return


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FGRVIRREC

Gravar os titulos de IRF gerados na baixa do contas a receber .
Arquivo anterior: FINXFUN.PRX

@Author	Pâmela Bernardo
@since	29/02/2012
/*/
//-----------------------------------------------------------------------------------------------------
Function FGrvIrRec(nIrrf,nRegSe1,lInclusao,cSeq,cOrigem,nMoeda)

	//Controla IRPJ na baixa
	Local lIrPjBxCr		:= FIrPjBxCr(.T.)
	Local cPrefixo		:= ""
	Local cNum			:= ""
	Local cParcela		:= ""
	Local dEmissao		:= SE1->E1_EMISSAO
	Local dVencto	  	:= SE1->E1_VENCTO
	Local dVencRea		:= SE1->E1_VENCREA
	Local dEmis1	  	:= SE1->E1_EMIS1
	Local lTitPai 		:= .T.
	Local cTitPai 		:= ""
	Local aArea			:= GetArea()
	Local cFil  		:= cFilial
	Local aAreaSE1 		:= SE1->(GetArea())
	Local cCodIrrf 		:= ""
	Local cUniao		:= If(! EMPTY(GetMV("MV_UNIAO")),GetMV("MV_UNIAO"),'UNIAO')
	Local cLojaIrf		:= Padr( "00", Len( SE1->E1_LOJA ), "0" )
	Local cParcIRF		:= ""
	Local cCodAprov		:= If(SuperGetMV( "MV_FINCTAL", .T., "1" ) == "2",FA050Aprov(If(cPaisLoc=="BRA",1,nMoeda))," ")
	Local cNatur		:= ""
	Local cNatureza		:= ""

	DEFAULT cOrigem 	:= Space(8)
	DEFAULT nMoeda 		:= 1
	DEFAULT lInclusao   := .T.

	SE1->(dbGoto(nRegSe1))

	SA1->(dbSetOrder(1))
	SA1->(MsSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))
	cTitPai := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)

	dBaixa := Iif( Type("dBaixa") != "D", dDataBase, dBaixa )

	If cPaisLoc=="BRA".And. !( SE1->E1_TIPO $ MVABATIM+"/IRF")

		cFil		:= SE1->E1_FILIAL
		cPrefixo    := SE1->E1_PREFIXO
		cNum		:= SE1->E1_NUM
		cTipoE1	    := SE1->E1_TIPO
		cParcSe1	:= SE1->E1_PARCELA
		dEmissao	:= SE1->E1_EMISSAO
		dEmis1      := SE1->E1_EMIS1
		dVencto     := SE1->E1_VENCTO
		dVencRea	:= SE1->E1_VENCREA
		cLa		   	:= SE1->E1_LA
		cCLiente	:= SE1->E1_CLIENTE
		cLoja		:= SE1->E1_LOJA
		cNomCli	    := SE1->E1_NOMCLI
		cCodIrrf    := SE1->E1_CODIRRF
		cNatur		:= SE1->E1_NATUREZ

		//Se for tratado o imposto pela baixa
		If lIrPjBxCr .and. !lInclusao
			dEmissao	:= dBaixa
			dEmis1	    := dDataBase
			dVctoReal   := dBaixa
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera titulo de IRF                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nIrrf > 0
			If ( SED->ED_RECIRRF == "2" .OR. ( SA1->A1_RECIRRF == "2" .AND. SED->ED_RECIRRF $ "3| " ) )

				// Cria o Fornecedor, caso nao exista 		  
				DbSelectArea("SA2")
				SA2->(DbSetOrder(1))
				DbSeek(xFilial("SA2")+cUniao+Space(Len(A2_COD)-Len(cUniao))+cLojaIrf)
				If ( EOF() )
					Reclock("SA2",.T.)
					SA2->A2_FILIAL := cFilial
					SA2->A2_COD 	:= cUniao
					SA2->A2_LOJA	:= cLojaIrf
					SA2->A2_NOME	:= "UNIAO"
					SA2->A2_NREDUZ  := "UNIAO"
					SA2->A2_BAIRRO  := "."
					SA2->A2_MUN 	:= "."
					SA2->A2_EST 	:= SuperGetMv("MV_ESTADO")
					SA2->A2_End 	:= "."
					SA2->A2_TIPO	:= "J"
					MsUnlock()
				EndIf
				cParcIRF := ParcImposto(cPrefixo,cNum,MVTAXA)
				dNextDay := F050vImp("IRRF",dEmissao,dDataBase,dVencrea)
				dVencRea := dNextDay
				RecLock("SE2",.T.)
				SE2->E2_FILIAL	:= cFilial
				SE2->E2_PREFIXO	:= cPrefixo
				SE2->E2_NUM		:= cNum
				SE2->E2_PARCELA	:= cParcIRF
				SE2->E2_TIPO	:= MVTAXA
				SE2->E2_EMISSAO	:= dEmissao
				SE2->E2_VALOR	:= nIrrf
				SE2->E2_VENCREA	:= dVencrea
				SE2->E2_SALDO	:= nIrrf
				SE2->E2_VENCTO	:= dVencRea
				SE2->E2_VENCORI	:= dVencRea
				SE2->E2_MOEDA	:= If(cPaisLoc=="BRA",1,nMoeda)
				SE2->E2_EMIS1	:= dDataBase
				SE2->E2_FORNECE	:= cUniao
				SE2->E2_VLCRUZ	:= Round(nIrrf, MsDecimais(1) )
				SE2->E2_LOJA	:= SA2->A2_LOJA
				SE2->E2_NOMFOR	:= SA2->A2_NREDUZ
				SE2->E2_ORIGEM	:= Upper(cOrigem)
				cNatureza		:= &(GetMv("MV_IRF"))
				SE2->E2_NATUREZ	:= cNatureza
				SE2->E2_LA		:= cLA			// Herda do principal
				SE2->E2_CODAPRO	:= cCodAprov
				SE2->E2_FILORIG := If(Empty(SE1->E1_FILORIG),cFilAnt,SE1->E1_FILORIG)
				SE2->E2_TITPAI  := cTitpai

				If lIrPjBxCr
					SE2->E2_SEQBX   := cSeq
				EndIf
				
				If cPaisLoc == "BRA" .and. !Empty(SED->ED_CODRET)
					SE2->E2_DIRF	:= "1"
					SE2->E2_CODRET	:= SED->ED_CODRET
				EndIf
				
			ElseIf  ( SED->ED_RECIRRF == "1" .OR.( SA1->A1_RECIRRF == "1" .AND. SED->ED_RECIRRF $ "3| " ) )

				// Cria a natureza IRRF caso nao exista        
				DbSelectArea("SED")
				cNatureza := Alltrim(&(GetMv("MV_IRF")))
				If ( ! DbSeek( cFilial + cNatureza ) )
					RecLock("SED",.T.)
					SED->ED_FILIAL  := cFilial
					SED->ED_CODIGO  := cNatureza
					SED->ED_CALCIRF := "N"
					SED->ED_CALCISS := "N"
					SED->ED_CALCINS := "N"
					SED->ED_CALCCSL := "N"
					SED->ED_CALCCOF := "N"
					SED->ED_CALCPIS := "N"
					SED->ED_DESCRIC := "IRRF"
					SED->ED_TIPO	:= "2"

					MsUnlock()
					FKCOMMIT()
				EndIf

				cParcela := ParcImpRec(cPrefixo,cNum,"IRF")
				RecLock("SE1",.T.)
				SE1->E1_FILIAL  := cFil
				SE1->E1_PREFIXO := cPrefixo
				SE1->E1_NUM     := cNum
				SE1->E1_PARCELA := cParcela
				SE1->E1_TIPO    := "IRF"
				SE1->E1_EMISSAO := dEmissao
				SE1->E1_EMIS1   := dDataBase
				SE1->E1_VALOR   := nIrrf
				SE1->E1_VENCTO  := dVencRea
				SE1->E1_VENCREA := dVencRea
				SE1->E1_VENCORI := dVencRea
				SE1->E1_CLIENTE := cCliente
				SE1->E1_LOJA    := cLoja
				SE1->E1_NOMCLI  := cNomCli
				SE1->E1_MOEDA   := 1
				SE1->E1_VLCRUZ  := Round(NoRound(xMoeda(SE1->E1_VALOR,nMoeda,1,SE1->E1_EMISSAO,MsDecimais(1)+1),MsDecimais(1)+1),MsDecimais(1))
				SE1->E1_ORIGEM  := Upper(cOrigem)
				SE1->E1_NATUREZ := cNatureza
				SE1->E1_LA      := cLa
				SE1->E1_SALDO   := 0 // nIrrf
				SE1->E1_STATUS  := "B"
				SE1->E1_BAIXA   := dBaixa
				SE1->E1_CODIRRF := cCodIrrf// Cod.Ret.Irrf

				
				DbSelectArea("SED")
				SED->(DbSetOrder(1))
				If SED->(DbSeek(xFilial("SED")+cNatur))
					If !Empty(SED->ED_CODRET)
						SE1->E1_CODRET	:= SED->ED_CODRET
					EndIf
				EndIf

				If lIrPjBxCr
					SE1->E1_SEQBX   := cSeq
					SE1->E1_HIST	:= "Desconto - IRRF"
				Endif

				// Grava a filial de origem quando existir o campo no SE1            
				SE1->E1_FILORIG := cFil

				// Grava os dados do titulo de origem do imposto se existir o campo no SE1 
				If lTitPai
					SE1->E1_TITPAI := cTitPai
				EndIf

			EndIf
			MsUnlock()
			FKCOMMIT()
			
			if lPLSTITPF
				PLSTITPF('SE1',cTitPai)
			endIf

		EndIf
	EndIf

	RestArea(aArea)
	RestArea(aAreaSE1)

Return


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FVEDATIR

Tratamento de acumulatividade na baixa e no borderô (periodo de cumulatividade) (FINA080/FINA241/FINA590).
Arquivo anterior: FINXFUN.PRX

Parametros
ExpN1 = Tipo de Pessoa ("F" - Fisica ou "J" - Juridica)
ExpN2 = Opcao vencto PJ
ExpA1 = Opcao vencto PJ
ExpD1 = Data da baixa
ExpC1 = Data do debito

@Author	Mauricio Pequim Jr.
@since	29/08/2011
/*/
//-----------------------------------------------------------------------------------------------------
Function FVeDatIr( cTipo, cVenctoPJ, cVenctoPF, dBaixa, dDebito )

	Local lRet	:= .F.

	// Para Pessoa fisica totaliza os titulos emitidos no mes
	If cTipo == "F"
		If cVenctoPF == "1"
			lRet := DTOS(SE5->E5_DATA) >= DTOS(FirstDay(dBaixa)) .AND. DTOS(SE5->E5_DATA) <= DTOS(LastDay(dBaixa) )
		ElseIf cVenctoPF == "2"
			lRet := DTOS(SE5->E5_DTDISPO) >= DTOS(FirstDay(dDebito)) .AND. DTOS(SE5->E5_DTDISPO) <= DTOS(LastDay(dDebito) )
			lVencto := .T.
		Else // cVenctoPF == "3"
			lRet := DTOS(SE5->E5_DTDIGIT) >= DTOS(FirstDay(dDatabase)) .AND. DTOS(SE5->E5_DTDIGIT) <= DTOS(LastDay(dDatabase) )
		EndIf
	Else
		// Para Pessoa juridica totaliza os titulos emitidos no dia
		If cVenctoPJ == "1"
			lRet := DTOS(SE5->E5_DATA) == DTOS(dBaixa)
		ElseIf cVenctoPJ == "2"
			lRet := DTOS(SE5->E5_DTDISPO) == DTOS(dDebito)
		Else // cVenctoPF == "3"
			lRet := DTOS(SE5->E5_DTDIGIT) == DTOS(dDataBase)
		EndIf
	EndIf

	If !lRet .AND. Empty( __oTemBXCanc )
		__oTemBXCanc	:= FWPreparedStatement():New()	//	Objeto para consultas escalares
	EndIf

	//Caso a data nao seja do mesmo da baixa atual, verifico se a mesma nao foi cancelada ou estornada
	If !lRet .AND. ( SE5->E5_SITUACA == 'C' .OR. ;
		TemBxCanc( SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ), Nil, Nil, __oTemBXCanc ) )
		lRet := .T.
	EndIf

Return lRet

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FLOJASIRRF

Verificao das filiais de cliente/fornecedor a serem consideradas no calculo de IRRF (FINA040/FINA050).
Arquivo anterior: FINXFUN.PRX

Parametros
ExpC1 := Carteira (1=Receber,2=Pagar)

@Author	Mauricio Pequim Jr.
@since	05/11/2007
/*/
//-----------------------------------------------------------------------------------------------------

FUNCTION FLOJASIRRF(cCarteira)
	LOCAL aFilial		:= {}
	LOCAL aArea			:= GetArea()
	LOCAL aAreaSA1		:= SA1->(GetArea())
	LOCAL aAreaSA2		:= SA2->(GetArea())
	LOCAL cCnpj			:= ""
	LOCAL cCnpjIni		:= ""
	LOCAL cCnpjFin		:= ""
	LOCAL cAglImPJ		:= SuperGetMv("MV_AGLIMPJ",.T.,"1")
	LOCAL cFilAtu		:= cFilAnt
	LOCAL cEmpAtu		:= SM0->M0_CODIGO
	LOCAL aCliFor		:= {}
	LOCAL cArqTmp		:= Nil
	LOCAL nInc			:= 0
	LOCAL aSM0			:= AdmAbreSM0()
	Local bSA1Compart	:= { || Empty(xFilial("SA1")) }
	Local bSA2Compart	:= { || Empty(xFilial("SA2")) }
	Local lGestao		:= TamSx3("E5_FILIAL")[1] > 2
	Local nEmp 			:= 1 //Posicao do Codigo do Grupo de Empresas(M0_CODIGO) na aSM0
	Local ltipoF		:= .F. // tipo fisico pelo IR pessoa fisica e com CPF preenchido
	Local cCPFIR		:= ""
	Local CliExter		:= .F. // Identifica se cliente eh do tipo exportacao
	Local ForExter		:= .F. // Identifica se fornecedor eh do tipo exportacao
	LOCAL cQuery		:= ""
	LOCAL nLoop			:= 0
	Local lRatFkj		:= .F. 

	If Type("lF050Auto")=="U"
		lF050Auto:=.F.
	EndIf

	//Se for Gestao utilizo outra funcao para verificar filial compartilhada
	If lGestao
		bSA1Compart := { ||  Empty(FWFilial("SA1")) }
		bSA2Compart := { ||  Empty(FWFilial("SA2")) }
	Endif

	//Funcao para C.Receber
	If cCarteira == "1"
		//Empresas do Microsiga
		aFilial := {}

		If cAglImpJ == "3" //Raiz do CNPJ
			cCnpj := Substr(SM0->M0_CGC,1,8)
		Else   //CNPJ Completo
			cCnpj	:= SM0->M0_CGC
		Endif

		aArea := GetArea()

		For nInc := 1 To Len( aSM0 )
			If aSM0[nInc][nEmp] == cEmpAtu .or. !lGestao
				If cAglImpJ == "3" .and. Substr(aSM0[nInc][18],1,8) == cCnpj
					aAdd( Afilial, aSM0[nInc][2] )
				ElseIf cAglImpJ == "2" .and. aSM0[nInc][18] == cCnPj
					aAdd( Afilial, aSM0[nInc][2] )
				Endif
			EndIf
		Next

		//Empresas do Cliente
		dbselectArea ("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+M->E1_CLIENTE+M->E1_LOJA)

		If cAglImpJ == "3" //Raiz do CNPJ
			cCnpj		:= SA1->A1_CGC
			cCnpjIni := Substr(SA1->A1_CGC,1,8)
			cCnpjFin	:= Substr(SA1->A1_CGC,1,8)+ Replicate("z",Len(SA1->A1_CGC)-8)
		Else   //CNPJ Completo
			cCnpj		:= SA1->A1_CGC
			cCnpjIni	:= SA1->A1_CGC
			cCnpjFin	:= SA1->A1_CGC
		Endif

		// Verifica se eh cliente do tipo exportação
		If SA1->A1_TIPO = "X"
			CliExter := .T.
		EndIf

		cQuery := "SELECT A1_FILIAL, A1_COD, A1_LOJA FROM " + RetSQLname("SA1")
		cQuery += " WHERE "

		If Len(aFilial) > 1 .And. !(Eval(bSA1Compart)) //SA1 Compartilhado !Empty(xFilial("SA1"))  //Mais de uma filial SM0
			cQuery += "A1_FILIAL IN ( "
			For nLoop := 1 to Len(aFilial)
				cQuery += "'"   + aFilial[nLoop] + "',"
			Next
			//Retiro a ultima virgula
			cQuery := Left( cQuery, Len( cQuery ) - 1 )
			cQuery += ") AND "
		Else  //Apenas a Filial Atual ou SA1 compartilhado
			cQuery += "A1_FILIAL = '"+ xFilial("SA1") + "' AND "
		Endif

		// Se for cliente tipo exportação faz o filtro pelo codigo e loja
		If CliExter
			cQuery += "A1_COD = '"+ SA1->A1_COD +"' AND A1_LOJA = '"+ SA1->A1_LOJA +"' AND "
		Else
			cQuery += "A1_CGC BETWEEN '"+ cCnpjIni +"' AND '"+ cCnpjFin +"' AND "
		EndIf

		cQuery += "D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		// Já existe uma work TRB qdo a rotina trabalha de forma integrada com o SIGAEIC
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBTMP", .F., .T.)
		While TRBTMP->(!EOF())
			AADD(aCliFor, {TRBTMP->A1_FILIAL,TRBTMP->A1_COD,TRBTMP->A1_LOJA})
			TRBTMP->(dbSkip())
		Enddo
		TRBTMP->(dbCloseArea())
	Else
		//Funcao para C.Pagar
		//Empresas do Microsiga
		aFilial := {}
		If cAglImpJ == "3" //Raiz do CNPJ
			cCnpj := Substr(SM0->M0_CGC,1,8)
		Else   //CNPJ Completo
			cCnpj	:= SM0->M0_CGC
		Endif

		aArea := GetArea()

		For nInc := 1 To Len( aSM0 )
			If aSM0[nInc][nEmp] == cEmpAtu .or. !lGestao
				If cAglImpJ == "3" .and. Substr(aSM0[nInc][18],1,8) == cCnpj
					aAdd( Afilial, aSM0[nInc][2] )
				ElseIf cAglImpJ == "2" .and. aSM0[nInc][18] == cCnPj
					aAdd( Afilial, aSM0[nInc][2] )
				Endif
			EndIf
		Next

		//Empresas do Fornecedor
		//OBS.: A rotina de atualizacao de comissão já traz o fornecedor posicionado e nao usa alias de memoria para o SE2
		If FunName() != "MATA530"
			dbselectArea ("SA2")
			dbSetOrder(1)
			If FunName() == "FINA050" .Or. (FunName() == "FINA750" .And. IsInCallStack("FINA050")) .Or. nModulo == 43 .Or. lF050Auto
				dbSeek(xFilial("SA2")+M->(E2_FORNECE+E2_LOJA))
			Else
				dbSeek(xFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA))
			EndIf
		Endif

		If cAglImpJ == "3" .and. SA2->A2_TIPO <> "F" //Raiz do CNPJ
			cCnpj		:= SA2->A2_CGC
			cCnpjIni := Substr(SA2->A2_CGC,1,8)
			cCnpjFin	:= Substr(SA2->A2_CGC,1,8)+ Replicate("z",Len(SA2->A2_CGC)-8)
			ltipoF		:= SA2->A2_TIPO =="J" .AND. SA2->A2_IRPROG == '1' .AND. SA2->( FieldPos( "A2_CPFIRP" ) ) > 0
			If lTipoF
				FKJ->(DbSetOrder(1))
				lRatFkj 	:= FKJ->(MsSeek(xFilial("FKJ",SA2->A2_FILIAL)+SA2->(A2_COD+A2_LOJA)))
				cCPFIR		:= SA2->A2_CPFIRP
			Endif
		Else   //CNPJ Completo
			cCnpj		:= SA2->A2_CGC
			cCnpjIni	:= SA2->A2_CGC
			cCnpjFin	:= SA2->A2_CGC
			ltipoF		:= SA2->A2_TIPO =="J" .AND. SA2->A2_IRPROG == '1' .AND. SA2->( FieldPos( "A2_CPFIRP" ) ) > 0
			If lTipoF
				cCPFIR		:= SA2->A2_CPFIRP
			Endif
		Endif

		// Verifica se eh fornecedor do tipo exportação
		If SA2->A2_TIPO = "X"
			ForExter := .T.
		EndIf

		cQuery := "SELECT A2_FILIAL, A2_COD, A2_LOJA FROM " + RetSQLname("SA2")
		cQuery += " WHERE "

		If Len(aFilial) > 1 .And. !(Eval(bSA2Compart)) //SA2 Compartilhado !Empty(xFilial("SA2"))  //Mais de uma filial SA2
			cQuery += "A2_FILIAL IN ( "
			For nLoop := 1 to Len(aFilial)
				cQuery += "'"   + aFilial[nLoop] + "',"
			Next
			//Retiro a ultima virgula
			cQuery := Left( cQuery, Len( cQuery ) - 1 )
			cQuery += ") AND "
		Else  //Apenas a Filial Atual ou SA1 compartilhado
			cQuery += "A2_FILIAL = '"+ xFilial("SA2") + "' AND "
		Endif
		If lTipoF .and. !lRatFkj
			cQuery +=	"A2_CPFIRP = '"+cCPFIR+"' AND "
		Endif

		// Se for fornecedor tipo exportação faz o filtro pelo codigo e loja
		If ForExter
			cQuery += "A2_COD = '"+ SA2->A2_COD +"' AND A2_LOJA = '"+ SA2->A2_LOJA +"' AND "
		Else
			cQuery += "A2_CGC BETWEEN '"+ cCnpjIni +"' AND '"+ cCnpjFin +"' AND "
		EndIf

		cQuery += "D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBTMP", .F., .T.)
		While TRBTMP->(!EOF())
			AADD(aCliFor, {TRBTMP->A2_FILIAL,TRBTMP->A2_COD,TRBTMP->A2_LOJA})
			TRBTMP->(dbSkip())
		Enddo
		TRBTMP->(dbCloseArea())

	Endif
	cFilAnt := cFilAtu

	aCampos	:=	{}

	AADD(aCampos,{"FILIALX"	,"C",TamSX3("A1_FILIAL")[1]	,0})
	AADD(aCampos,{"CODIGO"	,"C",TamSX3("A1_COD")[1]		,0})
	AADD(aCampos,{"LOJA"		,"C",TamSX3("A1_LOJA")[1]		,0})
	cArqTmp := "TMPIRFIN_"+Alltrim(STR(Int(Seconds())))+Alltrim(str(ThreadId()))

	If InTransact()
		cArqTmp:=StartJob( "CRIATRBIR" , GetEnvServer() , .T. , SM0->M0_CODIGO, FWGETCODFILIAL,.T.,ThreadID(),aCampos,aCliFor,cArqTmp)
	Else
		cArqTmp:=CRIATRBIR(SM0->M0_CODIGO, FWGETCODFILIAL,.F.,0,aCampos,aCliFor,cArqTmp)
	EndIF

	RestArea(aArea)
	RestArea(aAreaSA1)
	RestArea(aAreaSA2)

Return ({aFilial,aCliFor,cArqTmp})


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FGERABATCP

Gera  titulo de abatimento no Contas a Pagar - Localizações
Arquivo anterior: FINXFUN.PRX


@Author	Paulo Leme
@since	15/07/2010
/*/
//-----------------------------------------------------------------------------------------------------
Function fGerAbatCP(cPrefixo, cTitulo, cParcela, cTipoDoc, nFornec, nLoja, nValAbat, cTipoRet, cTpAbt, cTitPai, cImposto, cNumOP, dDataVenc)
	LOCAL aArea	:= {}
	LOCAL aAreaSE2 := {}
	LOCAL aAbatimento:= {}
	LOCAL aDadosTit := {}
	LOCAL lOk := .T.
	Local cFornImp  := ""
	Local cLojImp 	:= ""
	Local cNatImp	:= ""
	LOCAL cSE2Filter := " "
	Local lFchEmi := (cPaisLoc$"EQU" .And. FunName()$"MATA101N" .And. IsInCallStack("FGrvCrt"))

	DEFAULT cImposto := ""
	DEFAULT cNumOP	 := ""
	DEFAULT dDataVenc := dDataBase

	//Função de uso exclusivo nas LOCALizações
	If (cPaisLoc == "BRA")
		Help(" ",1, STR0009     ,, STR0009     , 4,0)  //"Disponivel apenas para outros paises"
		Return .F.
	EndIf

	//Salvar Areas
	aArea:=GetArea()

	//Posicionar no Titulo original (SE2)
	SE2->(dbSetOrder(1))
	If !SE2->(dbSeek(xFilial("SE2")+AvKey(cPrefixo,"E2_PREFIXO")+AvKey(cTitulo,"E2_NUM")+AvKey(cParcela,"E2_PARCELA")+AvKey(cTipoDoc,"E2_TIPO")+AvKey(nFornec,"E2_FORNECE")+AvKey(nLoja,"E2_LOJA")))
		Help(" ",1, STR0001,, STR0002, 4,0)  //"Titulo "###"Titulo não encontrado"
		Return .F.
	EndIf
	//Evitar duplicates
	If cPaisLoc$"DOM|COS"
		aAreaSE2   := SE2->(GetArea())
		If !Empty(SE2->(DbFilter()))
			cSE2Filter := SE2->(DbFilter())
			DbselectArea("SE2")
			Set Filter To
		EndIf
		SE2->(dbSetOrder(1))
		If  SE2->(dbSeek(xFilial("SE2")+AvKey(cPrefixo,"E2_PREFIXO")+AvKey(cTitulo,"E2_NUM")+AvKey(cParcela,"E2_PARCELA")+AvKey(cTpAbt,"E2_TIPO")+AvKey(nFornec,"E2_FORNECE")+AvKey(nLoja,"E2_LOJA")))
			If !Empty(cSE2Filter)
				DbselectArea("SE2")
				Set Filter To &cSE2Filter
			EndIf
			RestArea(aAreaSE2)
			Return .F.
		EndIf
		If !Empty(cSE2Filter)
			DbselectArea("SE2")
			Set Filter To &cSE2Filter
		EndIf
		RestArea(aAreaSE2)
	Endif
	//Verificar se valor do abatimento é maior ou igual que o titulo original
	If nValAbat > SE2->E2_VALOR
		Help(" ",1, STR0003 ,, STR0004 , 4,0)				//"Valor a Abater "###"Valor a Abater maior que o valor do titulo"
		Return .F.
	EndIf

	//Verificar se existe saldo no titulo original
	If (nValAbat > SE2->E2_SALDO .and. !Empty(SE2->E2_BAIXA)) .or.   SE2->E2_SALDO == 0
		Help(" ",1, STR0003     ,, STR0005       , 4,0)  //"Valor a Abater "###"Titulo ""Titulo Sem Saldo a Abater "
		Return .F.
	EndIf

	//Guarda dados do titulo principal
	aDadosTit := {SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_NATUREZ, SE2->E2_FORNECE,;
	SE2->E2_LOJA, SE2->E2_VALOR, SE2->E2_VENCTO, SE2->E2_HIST, SE2->E2_EMISSAO,  SE2->E2_MOEDA }

	//Gera imposto a pagar - cadastro do Fornecedor e Natureza Padrao
	If cTipoRet == "I"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria o fornecedor, caso nao exista		   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA2")
		If !(dbSeek(xFilial("SA2")+GetMV("MV_UNIAO")))
			Reclock("SA2",.T.)
			Replace A2_FILIAL 	With xFilial("SA2")
			Replace A2_COD		With PadR(GetMV("MV_UNIAO"),TamSx3("A2_COD")[1])
			Replace A2_NOME		With GetMV("MV_UNIAO")
			Replace A2_NREDUZ 	With GetMV("MV_UNIAO")
			Replace A2_LOJA		With PadR("00",TamSx3("A2_LOJA")[1])
			Replace A2_MUN 		With "."
			Replace A2_EST 		With SuperGetMv("MV_ESTADO")
			Replace A2_BAIRRO 	With "."
			Replace A2_END 		With "."
			SA2->(MsUnlock())
		EndIF

		cFornImp := PadR(GetMV("MV_UNIAO"),TamSx3("A2_COD")[1])
		cLojImp  := PadR("00",TamSx3("A2_LOJA")[1])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria a natureza caso nao exista 	       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cImposto)
			dbSelectArea("SED")
			cNatImp := Alltrim(cImposto)
			cNatImp := cNatImp + Space(10-Len(cNatImp))
			If !(dbSeek(xFilial("SED")+cNatImp))
				RecLock("SED",.T.)
				Replace ED_FILIAL  	With xFilial("SED")
				Replace ED_CODIGO  	With cNatImp
				Replace ED_USO 		With "2"
				Replace ED_DESCRIC 	With cImposto
				Replace ED_TIPO		 With "2"
				SED->(MsUnlock())
			EndIf
		EndIf

		//Ajusta a data de vencimento, caso a mesma seja menor que a data base
		If dDataVenc < dDataBase
			dDataVenc := DataValida(dDataBase,.T.)
		EndIf

	EndIf

	If ( Alltrim(cTipoDoc) = "NF" .OR. "ND"$ Alltrim(cTipoDoc) .Or. (cPaisLoc $ "DOM|COS" .And. "PA"$ Alltrim(cTipoDoc)) ).and. nValAbat > 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gerar Título de Abatimento de Retenção (por exemplo: TIPO="IV-","IR-",etc...)     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		aAbatimento := {}
		AADD(aAbatimento , {"E2_PREFIXO", 	aDadosTit[1]            	   				   					, NIL})
		AADD(aAbatimento , {"E2_NUM"    , 	aDadosTit[2]			       				   					, NIL})
		AADD(aAbatimento , {"E2_PARCELA",	aDadosTit[3]            					   					, NIL})
		If 	cPaisLoc $ "DOM|COS"
			AADD(aAbatimento , {"E2_TIPO"   	, 	cTpAbt      	 					   					, NIL})
		EndIf
		If !(cPaisLoc	$ "DOM|COS")
			Do Case
			Case cTipoRet			==	 	"I"
				AADD(aAbatimento , {"E2_TIPO"   , 	MVIVABT	     	  										, NIL})
			Case cTipoRet  			==	   	"R"
				AADD(aAbatimento , {"E2_TIPO"   , 	MVIRABT	      	 										, NIL})
			EndCase
		EndIf

		If cPaisLoc $ "EQU/VEN" .And. cTipoRet == "I"
			AADD(aAbatimento , {"E2_FORNECE", 	aDadosTit[6]												, NIL})
			AADD(aAbatimento , {"E2_LOJA"   , 	aDadosTit[7]												, NIL})
		Else
			AADD(aAbatimento , {"E2_FORNECE", 	Iif(cTipoRet == "I",cFornImp,aDadosTit[6])					, NIL})
			AADD(aAbatimento , {"E2_LOJA"   , 	Iif(cTipoRet == "I",cLojImp,aDadosTit[7])					, NIL})
		EndIf

		AADD(aAbatimento , {"E2_MOEDA"  , 	aDadosTit[12]       		   									, NIL})
		AADD(aAbatimento , {"E2_VALOR"  , 	nValAbat             											, NIL})
		AADD(aAbatimento , {"E2_VLCRUZ" , 	nValAbat             											, NIL})
		AADD(aAbatimento , {"E2_NATUREZ", 	Iif(cTipoRet == "I" .and. !Empty(cImposto) ,cNatImp,aDadosTit[5])						, NIL})
		AADD(aAbatimento , {"E2_EMISSAO", 	Iif(cTipoRet == "I" .and. !lFchEmi,dDataBase,aDadosTit[11])	    , NIL})
		AADD(aAbatimento , {"E2_VENCTO" , 	Iif(cTipoRet == "I",dDataVenc,aDadosTit[09])           	  	, NIL})
		AADD(aAbatimento , {"E2_VENCREA", 	Iif(cTipoRet == "I",dDataVenc,DataValida(aDadosTit[09],.T.)) 	, NIL})
		AADD(aAbatimento , {"E2_VENCORI", 	Iif(cTipoRet == "I",dDataVenc,DataValida(aDadosTit[09],.T.)) 	, NIL})
		AADD(aAbatimento , {"E2_EMIS1"  , 	dDataBase								               	   		, NIL})
		AADD(aAbatimento , {"E2_HIST"	, 	STR0010					    									, NIL})		//"Taxa Retenção"
		AADD(aAbatimento , {"E2_ORIGEM" , 	FunName()					  									, NIL})
		If (cPaisLoc $ "DOM|COS")
			AADD(aAbatimento , {"E2_TITPAI",  cTitPai  					  				   					, NIL})
			AADD(aAbatimento , {"E2_ORDPAGO", cNumOP  					  				   					, NIL})
		EndIf
		lMsErroAuto := .F.
		lMsHelpAuto := .T.

		MSExecAuto({|x, y| FINA050(x, y)}, aAbatimento, 3)
		If lMsErroAuto
			lOk := .F.
			MostraErro()
		EndIf
		
		if lPLSTITPF
			PLSTITPF('SE2',cTitPai)
		endIf    

	EndIf

	//Recuperar as areas
	RestArea(aArea)

Return lOk


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FGERABATCR

Gera  titulo de abatimento no Contas a Pagar - Localizações
Arquivo anterior: FINXFUN.PRX


@Author	Paulo Leme
@since	15/07/2010
/*/
//-----------------------------------------------------------------------------------------------------
Function fGerAbatCR(cPrefixo, cTitulo, cParcela, cTipoDoc, nClient, nLoja, nValAbat, cTipoRet, cTpAbt)
	LOCAL aArea	:= {}
	LOCAL aAbatimento:= {}
	LOCAL aDadosTit := {}
	LOCAL lOk := .T.

	//Função de uso exclusivo nas LOCALizações
	If (cPaisLoc == "BRA")
		Help(" ",1, STR0009     ,, STR0009, 4,0)  //"Disponivel apenas para outros paises"
		Return .F.
	EndIf

	//Salvar Areas
	aArea:=GetArea()

	//Posicionar no Titulo original (SE1)
	SE1->(dbSetOrder(1))
	If !SE1->(dbSeek(xFilial("SE1")+AvKey(cPrefixo,"E1_PREFIXO")+AvKey(cTitulo,"E1_NUM")+AvKey(cParcela,"E1_PARCELA")+AvKey(cTipoDoc,"E1_TIPO")+AvKey(nClient,"E1_CLIENTE")+AvKey(nLoja,"E1_LOJA")))
		Help(" ",1, STR0001,, STR0002      , 4,0)  //"Titulo " "Titulo não encontrado  "
		Return .F.
	EndIf

	//Verificar se valor do abatimento é maior ou igual que o titulo original
	If nValAbat > SE1->E1_VALOR
		Help(" ",1, STR0003     ,, STR0004      , 4,0)  // "Valor a Abater " "Valor a Abater maior que o valor do titulo  "
		Return .F.
	EndIf

	//Verificar se existe saldo no titulo original
	If (nValAbat > SE1->E1_SALDO .and. !Empty(SE1->E1_BAIXA)) .or.   SE1->E1_SALDO == 0
		Help(" ",1, STR0003     ,, STR0005       , 4,0)  //"Titulo ""Titulo Sem Saldo a Abater "
		Return .F.
	EndIf

	//Guarda dados do titulo principal
	aDadosTit := {SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, SE1->E1_CLIENTE,;
	SE1->E1_LOJA, SE1->E1_VALOR, SE1->E1_VENCTO, SE1->E1_HIST, SE1->E1_EMISSAO,  SE1->E1_MOEDA }

	If (cPaisLoc == "COS" .Or. (Alltrim(cTipoDoc) = "NF" .OR. "ND"$ Alltrim(cTipoDoc)) ) .and. nValAbat > 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gerar Título de Abatimento de Retenção (TIPO="IV-" ou "IR-")                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		aAbatimento := {}
		AADD(aAbatimento , {"E1_PREFIXO", 		aDadosTit[1]            							, NIL})
		AADD(aAbatimento , {"E1_NUM"    , 	   	aDadosTit[2]			    						, NIL})
		AADD(aAbatimento , {"E1_PARCELA",		aDadosTit[3]            							, NIL})
		If cPaisLoc != "COS"
			Do Case
			Case cTipoRet	=		"I"
			AADD(aAbatimento , {"E1_TIPO"   , 	MVIVABT	         									, NIL})

			Case cTipoRet	=	   "R"

				AADD(aAbatimento , {"E1_TIPO"   , 	MVIRABT	         									, NIL})
			EndCase
		Else
			AADD(aAbatimento , {"E1_TIPO"   , 	cTpAbt	         									, NIL})
		EndIf
		AADD(aAbatimento , {"E1_CLIENTE", 		aDadosTit[6]            							, NIL})
		AADD(aAbatimento , {"E1_LOJA"   , 		aDadosTit[7]            							, NIL})
		If cPaisLoc == "EQU"  //PARA PAIS EQUADOR O IV- sempre gravara na moeda 1
			AADD(aAbatimento , {"E1_MOEDA"  , 		1       											, NIL})
		Else
			AADD(aAbatimento , {"E1_MOEDA"  , 		aDadosTit[12]       								, NIL})
		EndIf
		AADD(aAbatimento , {"E1_VALOR"  , 		nValAbat             								, NIL})
		AADD(aAbatimento , {"E1_VLCRUZ" , 		nValAbat             								, NIL})
		AADD(aAbatimento , {"E1_NATUREZ", 		aDadosTit[5]            							, NIL})
		AADD(aAbatimento , {"E1_EMISSAO", 		aDadosTit[11]           							, NIL})
		AADD(aAbatimento , {"E1_VENCTO" , 		aDadosTit[09]           							, NIL})
		AADD(aAbatimento , {"E1_VENCREA", 		DataValida(aDadosTit[09],.T.) 						, NIL})
		AADD(aAbatimento , {"E1_VENCORI", 		DataValida(aDadosTit[09],.T.) 						, NIL})
		AADD(aAbatimento , {"E1_EMIS1"  , 		dDataBase               							, NIL})
		AADD(aAbatimento , {"E1_HIST"   , 		"ABATIMIENTO DE RETENCION"  						, NIL})
		AADD(aAbatimento , {"E1_ORIGEM" , 		"FINA087A"             								, NIL})

		lMsErroAuto := .F.
		lMsHelpAuto := .T.

		MSExecAuto({|x, y| FINA040(x, y)}, aAbatimento, 3)
		If lMsErroAuto
			lOk := .F.
			MostraErro()
		ElseIf 	cPaisLoc $ "DOM|COS"
			RecLock("SE1", .F. )
			SE1->E1_TIPO := cTpAbt
			MsUnlock()
		EndIf
	EndIf

	//Recuperar as areas
	RestArea(aArea)

Return lOk


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FGERTAXACP

Gera  titulo de taxa no Contas a Pagar - Localizações.
Arquivo anterior: FINXFUN.PRX


@Author	Paulo Leme
@since	15/08/2011
/*/
//-----------------------------------------------------------------------------------------------------
Function fGerTaxaCP(cPrefOri, cNumTitOri, cParcOri, cTipoOri, cFornecOri, cLojaOri, nValTaxa, cOrdenPago, dVencto, cImposto, nMoedaRet, cFornImp, cLojaImp,cCodApro)
	Local aArea		:= {}
	Local aAreaSA2 	:= {}
	Local aAreaSE2 	:= {}
	Local aAreaSX5	:= {}
	Local cFilSX5		:= xFilial("SX5")
	Local cFiltroSE2	:= ""
	Local nRegSE2		:= 0
	Local aImposto	:= {}
	Local lOk 			:= .T.
	Local cTitPai		:= ""
	Local nTamCod		:= TamSx3("A2_COD")[1]

	Local cPrefImp	:= ""
	Local cNumImp		:= ""
	Local cNatImp		:= ""
	Local cTipoImp	:= ""
	Local cParcImp	:= ""

	Local cTipForn	:= ""

	DEFAULT nMoedaRet := 1
	DEFAULT cFornImp  := GETMV("MV_UNIAO",.T.,"FISCO")
	DEFAULT cLojaImp  := PadR( "00", TamSX3( "A2_LOJA" )[1], "0" )
	DEFAULT cCodApro  := ""

	cFornImp	:= Substr(cFornImp + Space(nTamCod),1,nTamCod)

	//Salvar Areas
	aArea:=GetArea()
	aAreaSE2:=SE2->(GetArea())
	aAreaSX5:=SX5->(GetArea())

	If cPaisLoc $ "ARG|COS"
		cPrefImp	:= cImposto
		cNumImp	:= cOrdenPago
	Else
		cPrefImp	:= cPrefOri
		cNumImp	:= cNumTitOri
		cTitPai	:= cPrefOri+cNumTitOri+cParcOri+cTipoOri+cFornecOri+cLojaOri
	EndIf

	If cPaisLoc == "ARG"
		DbSelectArea("SX5")
		aAreaSX5 := SX5->(GetArea())
		If SX5->(DbSeek( cFilSX5 + "05" + cImposto) )
			cTipoImp := AllTrim(SX5->X5_CHAVE)
		EndIf
	EndIf

	If !Empty(cTipoImp)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria o fornecedor, caso nao exista		   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//Valida o tipo de fornecedor padrao para cada fornecedor
		Do Case
			Case cPaisLoc == "ARG"
				cTipForn := "X" //Isento
			Case cPaisLoc == "COS"
				cTipForn := "3" //Cont. Comum
			Otherwise
				cTipForn := "J" //Juridico
		End Case

		dbSelectArea("SA2")
		aAreaSA2 := SA2->(GetArea())
		SA2->(DbSetOrder(1))  //A2_FILIAL+A2_COD+A2_LOJA
		If !SA2->(dbSeek(xFilial("SA2")+cFornImp+cLojaImp))
			SA2->(Reclock("SA2",.T.))
			Replace A2_FILIAL	With xFilial("SA2")
			Replace A2_COD    	With cFornImp
			Replace A2_NOME		With cFornImp
			Replace A2_NREDUZ 	With cFornImp
			Replace A2_LOJA		With cLojaImp
			Replace A2_MUN		With "."
			Replace A2_EST		With SuperGetMv("MV_ESTADO")
			Replace A2_BAIRRO		With "."
			Replace A2_END 		With "."
			Replace A2_TIPO		With cTipForn
			SA2->(MsUnLock())
		EndIf
		RestArea(aAreaSA2)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria a natureza caso nao exista 	       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cImposto)
			dbSelectArea("SED")
			cNatImp := Alltrim(cImposto)
			cNatImp := cNatImp + Space(10-Len(cNatImp))
			If !(dbSeek(xFilial("SED")+cNatImp))
				RecLock("SED",.T.)
				Replace ED_FILIAL  	With xFilial("SED")
				Replace ED_CODIGO  	With cNatImp
				Replace ED_USO 		With "2"
				Replace ED_DESCRIC 	With cImposto
				Replace ED_TIPO		With "2"
				SED->(MsUnlock())
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida o numero da próxima parcela 	       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nRegSE2 := SE2->(Recno())
		cFiltroSE2 := SE2->(DbFilter())
		SE2->(dbClearFilter())

		dbSelectArea("SE2")
		SE2->(dbSetOrder(6))
		SE2->(dbGoTop())
		If SE2->(dbSeek(xFilial("SE2")+PadR(cFornImp,TamSx3("E2_FORNECE")[1])+cLojaImp+cPrefImp+cNumImp))
			While !SE2->(Eof()) .And. SE2->(E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == PadR(cFornImp,TamSx3("E2_FORNECE")[1])+cLojaImp+cPrefImp+cNumImp
				If SE2->E2_TIPO == cTipoImp
					cParcImp := SE2->E2_PARCELA
				EndIf
				SE2->(dbSkip())
			EndDo
		EndIf

		If Empty(cParcImp)
			cParcImp := PadR("1",TamSx3("E2_PARCELA")[1],"0")
		Else
			cParcImp := Soma1(cParcImp)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gerar Título Taxa de Retenção (por exemplo: Prefixo="IV-","IR-",etc...)     	  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aImposto := {}
		AADD(aImposto , {"E2_PREFIXO", 	cPrefImp           				, NIL})
		AADD(aImposto , {"E2_NUM"    , 	cNumImp			    			, NIL})
		AADD(aImposto , {"E2_PARCELA",	cParcImp			      			, NIL})
		AADD(aImposto , {"E2_TIPO"   , 	cTipoImp		     	  		  	, NIL})
		AADD(aImposto , {"E2_FORNECE", 	cFornImp	            			, NIL})
		AADD(aImposto , {"E2_LOJA"   , 	cLojaImp	            			, NIL})
		AADD(aImposto , {"E2_VALOR"  , 	nValTaxa             			, NIL})
		AADD(aImposto , {"E2_VLCRUZ" , 	nValTaxa             			, NIL})
		AADD(aImposto , {"E2_NATUREZ", 	cNatImp		            		, NIL})
		AADD(aImposto , {"E2_EMISSAO", 	dDataBase               			, NIL})
		AADD(aImposto , {"E2_VENCTO" , 	dVencto           				, NIL})
		AADD(aImposto , {"E2_VENCREA", 	DataValida(dVencto,.T.) 			, NIL})
		AADD(aImposto , {"E2_VENCORI", 	DataValida(dVencto,.T.) 		   	, NIL})
		AADD(aImposto , {"E2_EMIS1"  , 	dDataBase               			, NIL})
		AADD(aImposto , {"E2_MOEDA"  , 	nMoedaRet      					, NIL})
		If !Empty(cTitPai)
			AADD(aImposto , {"E2_TITPAI"  , cTitPai      					, NIL})
		EndIf
		If !Empty(cOrdenPago)
			AADD(aImposto , {"E2_ORDPAGO", 	cOrdenPago		       		, NIL})
		EndIf
		AADD(aImposto , {"E2_HIST"   	, 	STR0010				, NIL})		//" Taxa Retenção"
		AADD(aImposto , {"E2_ORIGEM" 	, 	"FINA850"						, NIL})
		If !Empty(cCodApro)
			AADD(aImposto , {"E2_CODAPRO" , cCodApro		       		, NIL})
		EndIf

		lMsErroAuto := .F.
		lMsHelpAuto := .T.

		MSExecAuto({|x, y| FINA050(x, y)}, aImposto, 3)
		If lMsErroAuto
			lOk := .F.
			MostraErro()
		EndIf

		//Recupero Filtro do SE2
		dbSelectArea("SE2")
		Set Filter To &cFiltroSE2

		SE2->(dbGoTo(nRegSE2))

		//Recuperar as areas
		RestArea(aAreaSE2)
		RestArea(aArea)

		if lPLSTITPF
			PLSTITPF('SE2',cTitPai)
		endIf

	EndIf

	RestArea(aAreaSX5)

Return lOk


/*
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

			Funcoes retiradas do arquivo MATXATU.PRX

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
*/

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PARCIMPOSTO

Calcula a parcela de titulos de impostos, IR, PIS, COFINS e CSLL.
Arquivo anterior: MATXATU.PRX


@Author	Claudio D. de Souza
@since	11/12/2003
/*/
//-----------------------------------------------------------------------------------------------------
Function ParcImposto(cPrefixo,cNum,cTipoE2,lIRPFBaixa,cForLojISS,lIR)
	Local aArea	:= GetArea()
	Local aAreaSE2 := SE2->(GetArea())
	Local cParcela
	Local cAlias
	Local cChave := ""
	Local aTamParc := TamSx3("E2_PARCELA")
	Local lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"
	Local cSavFilter // Declarar variavel para evitar problemas quando existir filtro
	Local cUniao	   := If(! EMPTY(GetMV("MV_UNIAO")),GetMV("MV_UNIAO"),'UNIAO')

	Default lIRPFBaixa := .F.
	Default cForLojISS := Pad(GetMv("MV_MUNIC"),Len(SA2->A2_COD))+PadR( "00", Len( SE2->E2_LOJA ), "0" )
	Default lIR := .F.

	If Select("__SE2") == 0
		dbSelectArea("SE2")
		cSavFilter := dbFilter()
		dbClearFilter()
		cAlias := "SE2"
	Else
		cAlias := "__SE2"
	EndIf
	cParcela := STRZERO(1,aTamParc[1])
	While ( .T. )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ VerIfica se ja' ha' titulo de IMPOSTO com esta numera‡„o ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea(cAlias)
		DbSetOrder(1)
		If cTipoE2 == "ISS"
			cChave := xFilial("SE2")+cPrefixo+cNum+cParcela+"ISS"+cForLojISS
		ElseIf lIR
			cChave := xFilial("SE2")+cPrefixo+cNum+cParcela+Iif(cTipoE2 $ MVPAGANT+"#"+MV_CPNEG .And. (!lIRPFBaixa),MVTXA,MVTAXA)+PadR(cUniao,6)
		Else
			cChave := xFilial("SE2")+cPrefixo+cNum+cParcela+Iif(cTipoE2 $ MVPAGANT+"#"+MV_CPNEG .And. (! lPCCBaixa .And. !lIRPFBaixa),MVTXA,MVTAXA)+PadR(cUniao,6)
		Endif

		If DbSeek(cChave)
			cParcela := Soma1( cParcela,,.T.)
			Loop
		EndIf
		Exit
	Enddo

	If cAlias=="SE2" .And. !Empty( cSavFilter )
		dbSelectArea("SE2")
		DbSetFilter({||&(cSavFilter)},cSavFilter)
	EndIf

	RestArea(aArea)
	RestArea(aAreaSE2)
Return cParcela


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FGRVPCCREC

Efetua a gravacao dos titulos de impostos PIS, COFINS e CSLL (CR na Baixa). FINA040/FINA110/FINA330/FINXATU.
Arquivo anterior: MATXATU.PRX


@Author	MAuricio Pequim Jr.
@since	18/10/2014
/*/
//-----------------------------------------------------------------------------------------------------
Function FGrvPccRec(nPis,nCofins,nCsll,nRegSe1,lInclusao,lRtPICFCS,cSeq,cOrigem,nMoeda)

	//Controla o Pis Cofins e Csll na baixa (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default))
	Local lPccBxCr			:= FPccBxCr(.T.)
	Local cPrefixo	:= ""
	Local cNum		:= ""
	Local cParcela,dEmissao,dVencto,dVencRea,dEmis1
	Local cTitPai := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
	Local cFil	:= cFilial
	Local aArea	:= GetArea()
	Local aAreaSE1 := SE1->(GetArea())

	DEFAULT cOrigem 	:= Space(8)
	DEFAULT lRtPICFCS:= .T.
	DEFAULT nMoeda := 1
	DEFAULT lInclusao := .T.

	dBaixa := If(Type("dBaixa") != "D",dDataBase,dBaixa)

	SE1->(dbGoto(nRegSe1))

	SA1->(dbSetOrder(1))
	SA1->(MsSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))

	If cPaisLoc=="BRA".And. !( SE1->E1_TIPO $ MVABATIM+"/PIS#COF#CSL")
		cFil            := SE1->E1_FILIAL
		cPrefixo		:= SE1->E1_PREFIXO
		cNum			:= SE1->E1_NUM
		cTipoE1			:= SE1->E1_TIPO
		cParcSe1		:= SE1->E1_PARCELA
		dEmissao		:= SE1->E1_EMISSAO
		dEmis1			:= SE1->E1_EMIS1
		dVencto			:= SE1->E1_EMISSAO
		dVencRea		:= SE1->E1_EMISSAO
		cLa				:= SE1->E1_LA
		cCLiente		:= SE1->E1_CLIENTE
		cLoja			:= SE1->E1_LOJA
		cNomCli			:= SE1->E1_NOMCLI
		cFilOrig		:= SE1->E1_FILORIG
		//Se for tratado o imposto pela baixa
		If lPccBxCr .and. !lInclusao
			dEmissao  := dBaixa
			dEmis1	  := dDataBase
			dVctoReal := dBaixa
			dVencto	  := dBaixa
			dVencRea  := dBaixa
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera titulo de PIS                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPis > 0 .And. lRtPICFCS
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria a natureza PIS caso nao exista        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SED")
			cNatureza := Pad(SuperGetMV("MV_PISNAT"),10)
			If ( ! DbSeek( cFilial + cNatureza ) )
				RecLock("SED",.T.)
				SED->ED_FILIAL  := cFilial
				SED->ED_CODIGO  := cNatureza
				SED->ED_CALCIRF := "N"
				SED->ED_CALCISS := "N"
				SED->ED_CALCINS := "N"
				SED->ED_CALCCSL := "N"
				SED->ED_CALCCOF := "N"
				SED->ED_CALCPIS := "N"
				SED->ED_DESCRIC := "PIS"
				SED->ED_TIPO	:= "2"
				MsUnlock()
				FKCOMMIT()
			EndIf

			If lPccBxCr .and. dDataBase >= dLastPcc
				dVencRea := F050VImp("PIS",SE2->E2_EMISSAO,SE2->E2_EMIS1,dBaixa) // Calcula o vencimento do imposto
			EndIf

			cParcela := ParcImpRec(cPrefixo,cNum,"PIS")
			RecLock("SE1",.T.)
			SE1->E1_FILIAL  := cFil
			SE1->E1_PREFIXO := cPrefixo
			SE1->E1_NUM     := cNum
			SE1->E1_PARCELA := cParcela
			SE1->E1_TIPO    := "PIS"
			SE1->E1_EMISSAO := dEmissao
			SE1->E1_EMIS1   := dDataBase
			SE1->E1_VALOR   := nPis
			SE1->E1_VENCTO  := dVencRea
			SE1->E1_VENCREA := dVencRea
			SE1->E1_VENCORI := dVencRea
			SE1->E1_CLIENTE := cCliente
			SE1->E1_LOJA    := cLoja
			SE1->E1_NOMCLI  := cNomCli
			SE1->E1_MOEDA   := nMoeda
			SE1->E1_VLCRUZ  := Round(NoRound(xMoeda(SE1->E1_VALOR,nMoeda,1,SE1->E1_EMISSAO,MsDecimais(1)+1),MsDecimais(1)+1),MsDecimais(1))
			SE1->E1_ORIGEM  := Upper(cOrigem)
			SE1->E1_NATUREZ := cNatureza
			SE1->E1_LA      := cLa
			SE1->E1_SALDO   := 0 // nPis
			SE1->E1_STATUS  := "B"
			SE1->E1_BAIXA   := dBaixa

			If lPccBxCr
				SE1->E1_SEQBX  := cSeq
				SE1->E1_HIST	:= "Desconto - Pis"
			Endif

			SE1->E1_FILORIG := CriaVar("E1_FILORIG",.T.)
			SE1->E1_TITPAI := cTitPai
			SE1->E1_FILORIG := cFilOrig

			MsUnlock()
			FKCOMMIT()

			if lPLSTITPF
				PLSTITPF('SE1',cTitPai)
			endIf

			If ExistBlock("F040PIS")
				Execblock("F040PIS",.F.,.F.,nRegSe1)
			EndIf

		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera titulo de COFINS                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nCofins > 0 .And. lRtPICFCS
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria a natureza COFINS caso nao exista     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SED")
			cNatureza := Pad(SuperGetMV("MV_COFINS"),10)
			If ( ! DbSeek( cFilial + cNatureza ) )
				RecLock("SED",.T.)
				SED->ED_FILIAL  := xFilial()
				SED->ED_CODIGO  := cNatureza
				SED->ED_CALCIRF := "N"
				SED->ED_CALCISS := "N"
				SED->ED_CALCINS := "N"
				SED->ED_CALCCSL := "N"
				SED->ED_CALCCOF := "N"
				SED->ED_CALCPIS := "N"
				SED->ED_DESCRIC := "COFINS"
				SED->ED_TIPO	:= "2"
				MsUnlock()
				FKCOMMIT()
			EndIf

			cParcela := ParcImpRec(cPrefixo,cNum,"COF")
			RecLock("SE1",.T.)
			SE1->E1_FILIAL  := cFil
			SE1->E1_PREFIXO := cPrefixo
			SE1->E1_NUM     := cNum
			SE1->E1_PARCELA := cParcela
			SE1->E1_TIPO    := "COF"
			SE1->E1_EMISSAO := dEmissao
			SE1->E1_EMIS1   := dDataBase
			SE1->E1_VALOR   := nCofins
			SE1->E1_VENCTO  := dVencRea
			SE1->E1_VENCREA := dVencRea
			SE1->E1_VENCORI := dVencRea
			SE1->E1_CLIENTE := cCliente
			SE1->E1_LOJA    := cLoja
			SE1->E1_NOMCLI  := cNomCli
			SE1->E1_MOEDA   := nMoeda
			SE1->E1_VLCRUZ  := Round(NoRound(xMoeda(SE1->E1_VALOR,nMoeda,1,SE1->E1_EMISSAO,MsDecimais(1)+1),MsDecimais(1)+1),MsDecimais(1))
			SE1->E1_ORIGEM  := Upper(cOrigem)
			SE1->E1_NATUREZ := cNatureza
			SE1->E1_LA      := cLa
			SE1->E1_SALDO   := 0 // nCofins
			SE1->E1_STATUS  := "B"
			SE1->E1_BAIXA   := dBaixa

			If lPccBxCr
				SE1->E1_SEQBX  := cSeq
				SE1->E1_HIST	:= "Desconto - Cofins"
			Endif

			SE1->E1_FILORIG := CriaVar("E1_FILORIG",.T.)
			SE1->E1_TITPAI := cTitPai
			SE1->E1_FILORIG := cFilOrig

			MsUnlock()
			FKCOMMIT()

			if lPLSTITPF
				PLSTITPF('SE1',cTitPai)
			endIf

			If ExistBlock("F040COF")
				Execblock("F040COF",.F.,.F.,nRegSe1)
			EndIf

		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera titulo de CSLL                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nCsll > 0 .And. lRtPICFCS
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria a natureza CSLL caso nao exista       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SED")
			cNatureza  := Pad(SuperGetMV("MV_CSLL"),10)
			If ( ! DbSeek( cFilial + cNatureza ) )
				RecLock("SED",.T.)
				SED->ED_FILIAL  := cFilial
				SED->ED_CODIGO  := cNatureza
				SED->ED_CALCIRF := "N"
				SED->ED_CALCISS := "N"
				SED->ED_CALCINS := "N"
				SED->ED_CALCCSL := "N"
				SED->ED_CALCCOF := "N"
				SED->ED_CALCPIS := "N"
				SED->ED_DESCRIC := "CONTRIB.S/LUCRO LIQUIDO"
				SED->ED_TIPO	:= "2"
				MsUnlock()
				FKCOMMIT()
			EndIf

			cParcela := ParcImpRec(cPrefixo,cNum,"CSL")
			RecLock("SE1",.T.)
			SE1->E1_FILIAL  := cFil
			SE1->E1_PREFIXO := cPrefixo
			SE1->E1_NUM     := cNum
			SE1->E1_PARCELA := cParcela
			SE1->E1_TIPO    := "CSL"
			SE1->E1_EMISSAO := dEmissao
			SE1->E1_EMIS1   := dDataBase
			SE1->E1_VALOR   := nCsll
			SE1->E1_VENCTO  := dVencRea
			SE1->E1_VENCREA := dVencRea
			SE1->E1_VENCORI := dVencRea
			SE1->E1_CLIENTE := cCliente
			SE1->E1_LOJA    := cLoja
			SE1->E1_NOMCLI  := cNomCli
			SE1->E1_MOEDA   := nMoeda
			SE1->E1_VLCRUZ  := Round(NoRound(xMoeda(SE1->E1_VALOR,nMoeda,1,SE1->E1_EMISSAO,MsDecimais(1)+1),MsDecimais(1)+1),MsDecimais(1))
			SE1->E1_ORIGEM  := Upper(cOrigem)
			SE1->E1_NATUREZ := cNatureza
			SE1->E1_LA      := cLa
			SE1->E1_SALDO   := 0 // nCsll
			SE1->E1_STATUS  := "B"
			SE1->E1_BAIXA   := dBaixa

			If lPccBxCr
				SE1->E1_SEQBX  := cSeq
				SE1->E1_HIST	:= "Desconto - Csll"
			Endif

			SE1->E1_FILORIG := CriaVar("E1_FILORIG",.T.)
			SE1->E1_TITPAI := cTitPai
			SE1->E1_FILORIG := cFilOrig

			MsUnlock()
			FKCOMMIT()
			
			if lPLSTITPF
				PLSTITPF('SE1',cTitPai)
			endIf

			If ExistBlock("F040CSL")
				Execblock("F040CSL",.F.,.F.,nRegSe1)
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSE1)
	RestArea(aArea)

Return


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FGRVINSS

Efetua gravação do titulo de INSS (FINA050).
Arquivo anterior: MATXATU.PRX

Parametros
ExpC1 - Prefixo do título de INSS que será gravado
ExpC2 - Numero do título de INSS que será gravado
ExpC3 - Parcela do título de INSS que será gravado
ExpC4 - Loja do fornecedor de INSS que será gravado (MV_FORINSS)
ExpC5 - Rotina que originou a gravacao do título de INSS
ExpN6 - Moeda utilizada na gravação do título de INSS
ExpN7 - Recno da Natureza(SED) do tít original-gerador do imposto
ExpN8 - Recno do Titulo Original (SE2) - gerador do imposto
ExpD9 - Data de Emissao do título original - gerador do imposto
ExpDA - Emis1 do título original - gerador do imposto
ExpDB - Vencimento real do título original - gerador do imposto
ExpNC - Valor do INSS já calculado - na inclusao do tit original
ExpLE - Informa se há rateio
ExpAF - Array do Rateio por Natureza
ExpAG - Array do Rateio por Centro de Custo
ExpCH - E2_LA do título principal

@Author	Adrianne Furtado Andrade
@since	12/01/2009
/*/
//-----------------------------------------------------------------------------------------------------
Function FGrvINSS(cPrefixo,cNum,cParcela,cLojaImpos,cOrigem,nMoeda,nRegSED,nRegSE2,dEmissao,dEmis1,dVctoReal,nInss,;
						lRatImp,aRatSev,aRatSez,cGeraDirf,cCodRetIr,lSpbInUse,cModSpb,aRecImpos)
	Local aRecINSS 		:= {}
	Local aTamParc 		:= TamSx3("E2_PARCELA")
	Local cNatureza 	:= ""
	Local dVencRea
	Local cLa
	Local cTitPai		:= SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
	Local cCodAprov		:= SE2->E2_CODAPRO
	Local cFilOrig      := SE2->E2_FILORIG
	Local cTipo 		:= IIf(!Empty(SA2->A2_TIPO),SA2->A2_TIPO,"J")
	Local cTpTit		:= SE2->E2_TIPO
	Local aArea		:= GetArea()
	Local aAreaSE2	:= SE2->( GetArea() )
	Local aAreaSA2	:= SA2->( GetArea() )
	Local lCallMT103 := IsInCallStack("MATA103")
	Local cRETINS	:= ""
	Local cTipoFor	:= ""
	Local cCNPJRET	:= ""
	Local cSeqBx	:= ""
	Local nX			:=	1
	Local lAcmPJ 	:= SuperGetMv("MV_INSACPJ",.T.,"2") == "1"  //1 = Acumula    2= Não acumula
	Local lInssBx 	:=	SuperGetMv("MV_INSBXCP",.F.,"2") == "1"
	Local cFilterSE2 := SE2->(DbFilter())
	Local cCodINSS	:= SUBSTR(GetMv("MV_FORINSS"),1, TAMSX3("A2_COD")[1])
	Local nLimInss   := GetMv("MV_LIMINSS",.F.,0)
	Local nMinINS1 := SuperGetMv("MV_MININSS",.F.,0)
	Local nMinINS2 := SuperGetMv("MV_VLRETIN",.F.,0)
	Local lInsPub :=	SuperGetMv("MV_INSPUB",,.F.) .And. nMinINS1 == 0 .And.;
						nLimInss == 0 .And. nMinINS2 == 0 //Inss Baixa com empresa publica. Neste caso os valores do inss não tem valor minimo ou maximo de retencao.
	Local cLojForn := ""
	Local cNmReduz := ""
	Local cForPagto := ""

	Default lSpbInUse := .F.
	Default cModSpb   := ""
	Default aRecImpos := {}

	If (IsInCallStack("FINA050")) .And. lInssBx .And. !(SE2->E2_TIPO $ MVPAGANT)
		Return
	Endif

	If !(IsInCallStack("FINA050")) .And. lInssBx .And. cPaisLoc	==	"BRA" //Caso inss baixa está posicionado no registro da baixa que estah sendo realizada.
		cSeqBx	:=	SE5->E5_SEQ
	Endif

	SE2->(DbClearFilter())

	//Posiciona no SED, no SE2 e no SA2
	DbGoTo(nRegSe2)
	SED->(DBSeek(xFilial("SED")+SE2->E2_NATUREZ))
	SA2->(DbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
	If SA2->A2_TIPO == "J"
		cGeraDirf  := "2"
		cCodRetIr  := ""
	EndIf

	If !lInssBx
		VerInssCalc(SA2->A2_COD,SA2->A2_LOJA,SA2->A2_NREDUZ,dEmissao,dVctoReal,@aRecINSS)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria o Fornecedor, caso nao exista 		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SA2")
	If !(MsSeek(xFilial()+cCodINSS+Space(Len(A2_COD)-Len(cCodINSS))+cLojaImpos))
		Reclock("SA2",.T.)
		SA2->A2_FILIAL	:= xFilial("SA2")
		SA2->A2_COD		:= cCodINSS
		SA2->A2_LOJA	:= If(Alltrim(cLojaImpos)<>"",cLojaImpos,PadR("00",TamSX3("A2_LOJA")[1],"0"))
		SA2->A2_NOME	:= "Instituto Nacional de Previdencia Social"
		SA2->A2_NREDUZ	:= "INPS"
		SA2->A2_BAIRRO	:= "."
		SA2->A2_MUN		:= "."
		SA2->A2_EST		:= SuperGetMv("MV_ESTADO")
		SA2->A2_END		:= "."
		SA2->A2_TIPO	:= "J"
		MsUnlock()
		FKCOMMIT()
	EndIf

	cLojForn  := SA2->A2_LOJA
	cNmReduz  := SA2->A2_NREDUZ
	cForPagto := SA2->A2_FORMPAG

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria a natureza INSS caso nao exista		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNatureza	:= &(GetMv("MV_INSS"))
	cNatureza	:= cNatureza+Space(10-Len(cNatureza))
	DbSelectArea("SED")
	If !DbSeek(cFilial+cNatureza)
		RecLock("SED",.T.)
		SED->ED_FILIAL  := cFilial
		SED->ED_CODIGO  := cNatureza
		SED->ED_CALCIRF := "N"
		SED->ED_CALCISS := "N"
		SED->ED_CALCINS := "N"
		SED->ED_CALCCSL := "N"
		SED->ED_CALCCOF := "N"
		SED->ED_CALCPIS := "N"
		SED->ED_DESCRIC := "RETENCAO P/ SEGURIDADE SOCIAL"
		SED->ED_TIPO	:= "2"
		MsUnlock()
		FKCOMMIT()
	EndIf
	DbGoTo(nRegSED)

	cParcela := STRZERO(1,aTamParc[1])
	DbSelectArea("SE2")
	DbSetOrder(1)
	While .T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ VerIfica se ja' ha' titulo de INSS com esta numera‡„o ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (DbSeek(cFilial+cPrefixo+cNum+cParcela+If(SE2->E2_TIPO$MVPAGANT,"INA",MVINSS)+PadR(GetMv("MV_FORINSS"),6)))
			cParcela := Soma1( cParcela,,.t. )
			Loop
		EndIf
		Exit
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava a parcela do INSS no titulo pai fazendo ³
	//³ a amarracao titulo x titulo INSS			  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbGoTo( nRegSe2 )
	Reclock( "SE2" , .F. )
	SE2->E2_PARCINS := cParcela
	SE2->E2_PRETINS := " " // PRET = " " - Retido nele mesmo.
	SE2->(MsUnlock())
	cLa := SE2->E2_LA

	// Calcula o vencto do imposto
	dVencRea := F050VIMP("INSS",dEmissao,dEmis1,dVctoReal,,cTipo)

		//Retenção INSS
		SE2->(dbSetOrder(1))
		If SE2->(dbSeek(xFilial("SE2")+cTitPai))

			cRETINS := SE2->E2_RETINS

			cTipoFor 	:= ALLTRIM(Posicione( "SA2", 1, xFilial("SA2") +SE2->E2_FORNECE+SE2->E2_LOJA, "A2_TIPO"))

			If cTipoFor == "J"
				cCNPJRET := GetAdvFval("SA2","A2_CGC",xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA,1,"")
			Else
				cCNPJRET := If(cTipoFor == "J", GetAdvFval("SA2","A2_CGC",xFilial("SA2")+cForPai+cLojPAi,1,""), SM0->M0_CGC)
			EndIf

		EndIF
		DbGoTo( nRegSe2 )
	RecLock("SE2",.T.)
	SE2->E2_FILIAL  := xFilial()
	SE2->E2_PREFIXO := cPrefixo
	SE2->E2_NUM 	 := cNum
	SE2->E2_PARCELA := cParcela
	SE2->E2_TIPO	 := IF(cTpTit$MVPAGANT .AND. SED->ED_RINSSPA == "1" .And. !lInssBx ,"INA",MVINSS)
	SE2->E2_EMISSAO := dEmissao
	SE2->E2_VALOR	 := nInss
	SE2->E2_VENCREA := dVencrea
	SE2->E2_SALDO	 := nInss
	SE2->E2_VENCTO  := dVencRea
	SE2->E2_VENCORI := dVencRea
	SE2->E2_MOEDA	 := If(cPaisLoc=="BRA",1,nMoeda)
	SE2->E2_EMIS1	 := dDataBase
	SE2->E2_FORNECE := GetMv("MV_FORINSS")
	SE2->E2_VLCRUZ  := Round( SE2->E2_VALOR, MsDecimais(1) )
	SE2->E2_LOJA	 := cLojForn
	SE2->E2_NOMFOR  := cNmReduz
	SE2->E2_ORIGEM  := cOrigem
	SE2->E2_NATUREZ := cNatureza
	SE2->E2_LA      := cLA			// Herda do principal
	If cPaisLoc == "BRA"
		SE2->E2_DIRF    := cGeraDirf
		SE2->E2_CODRET  := cCodRetIr
	Endif

		SE2->E2_RETINS := cRETINS
		SE2->E2_CNPJRET := cCNPJRET
	If lSpbInUse
		Replace	SE2->E2_MODSPB with cModSpb
	Endif

	SE2->E2_FILORIG := cFilOrig //filial origem do titulo pai

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava os dados do titulo de origem do imposto se existir o campo no SE2 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SE2->E2_TITPAI := cTitPai
	SE2->E2_CODAPRO := cCodAprov
	SE2->E2_FORMPAG := cForPagto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o campo E2_MULTNAT = '1' para que seja possivel a        ³
	//³ visualizacao do roteio atraves da rotina FINA050 (FA050Rateio)    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRatImp .And. lCallMT103 .And. SuperGetMV("MV_MULNATP",.F.,.F.)
		SE2->E2_MULTNAT := "1"
	EndIf

	If !Empty(cSeqBx)
		SE2->E2_SEQBX	:=	cSeqBx
	Endif
	SE2->(MsUnlock())
	FKCOMMIT()

	if lPLSTITPF
		PLSTITPF('SE2',cTitPai)
	endIf

	AADD(aRecImpos,{"SE2",Recno()})

	If ExistBlock("F050INS")
		Execblock("F050INS",.F.,.F.,nRegSE2)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava lançamento do imposto INSS no SIGAPCO se a rotina foi chamada do contas a pagar ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ("FINA050" $ cOrigem .And. !lInssBx) .Or. ( ("FINA080" $ cOrigem) .And. lInssBx)
			PCODetLan("000002","07","FINA050")
	EndIf
	// Se rateia os impostos, grava o rateio multipla natureza/centro de custo
	If lRatImp
		// Grava SEV e SEZ dos impostos, baseado nos percentuais do rateio do titulo principal
		GrvSevSezImp(aRatSev,aRatSez,SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_VALOR)
	Else
		AtuSldNat(SE2->E2_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, "2", "P", SE2->E2_VALOR, SE2->E2_VLCRUZ, If(SE2->E2_TIPO $ MVABATIM,"-","+"))
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravacao do SFQ 						   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lInsPub //Para inss na baixa em empresa publica nao tem valores de acumulacao.
		If lInssBx .And. (FunName()<> "FINA050") .Or. (FunName() == "FINA050" .And. cTpTit$MVPAGANT)//Inss Baixa
			If Len(aRecnoINSS) > 0
				aRecINSS	:=	FGrvInsSe5(aRecnoINSS,nRegSE2,nInss,cTipo)
			Endif

			SE2->(Dbgoto(nRegSe2))
			SA2->(DbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))

			//Pessoa juridica com cumulatividade ou pessoa fisica.
			If (SA2->A2_TIPO == "J" .And. lAcmPJ) .Or. SA2->A2_TIPO	== "F"
				For nX:= 1 To Len(aBordINSS)//Titulos que possuem bordero e estao pendentes de retencao.
					Aadd(aRecINSS,aBordINSS[nX])
				Next
			Endif

			If Len(aRecINSS) > 0
				FGrvSFQ("SE5",nRegSE2,aRecINSS, "INS")
			Endif
		Else
			If lInssBx
				FGrvSFQ("SE5",nRegSE2,aRecINSS, "INS")
			Else
				FGrvSFQ("SE2",nRegSE2,aRecINSS, "INS")
			Endif
		Endif
	Endif
	DbSelectArea( "SE2" )

	Set Filter to &cFilterSE2

	DbGoTo( nRegSE2 )
	Reclock( "SE2" , .F. )
	If cPaisLoc=="BRA"
		SE2->E2_DIRF    := "2"	 // Desmarca titulo principal, pois apenas o titulo de  imposto vai para DIRF
		//Titulo de Pessoa Juridica com natureza para retem somente Inss.
		If  !Empty(SE2->E2_CODRET) .And. SA2->A2_TIPO="J" .And.;
				SED->ED_CALCIRF $ "N " .And. SED->ED_CALCISS $ "N " .And. ;
				SED->ED_CALCCSL $ "N " .And. SED->ED_CALCCOF $ "N " .And. SED->ED_CALCPIS $ "N "
			SE2->E2_DIRF	:=	"1"
		Endif
	Endif
	MsUnlock()

	RestArea( aAreaSA2 )
	RestArea( aAreaSE2 )
	RestArea( aArea )

Return


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FA050TABIR

Cálculo de IRRF aplicando a tabela progressiva (FINA050).
Arquivo anterior: MATXATU.PRX

@param nValTitulo = Valor do titulo na moeda do titulo

@Author	Wagner Xavier
@since	05/03/1993
/*/
//-----------------------------------------------------------------------------------------------------
Function Fa050TabIr( nValTitulo As Numeric, lCalcJur As Logical ) As Numeric
	Local nValor	 As Numeric
	Local nHdlIrf	 As Numeric
	Local nBytes	 As Numeric
	Local nTamArq	 As Numeric
	Local aTabela	 As Array
	Local lTabela	 As Logical
	Local nI		 As Numeric
	Local nLimInss   As Numeric
	Local lDedIns	 As Logical
	Local lComisVend As Logical
	Local lRound 	 As Logical
	Local lFINA050	 As Logical
	Local lJurMulDes As Logical
	Local lRet		 As Logical
	Local lExistErro As Logical
	Local lIncA050	 As Logical	// Define se é inclusão/alteração via FINA050 para pegar variável de memória M->

	nValor		:= 0
	nHdlIrf	 	:= 0
	nBytes		:= 0
	nTamArq	 	:= 0
	aTabela		:= {}
	lTabela	 	:= .f.
	nI		 	:= 0
	nLimInss	:= SuperGetMv("MV_LIMINSS",.F.,0)
	lDedIns	 	:= (SuperGetMv("MV_INSIRF",.F.,"2") == "1")
	lComisVend	:= FunName()=="MATA530"
	lRound 	 	:= GetNewPar( "MV_RNDIRF", .T. ) //Arredonda valor do imposto.
	lFINA050	:= FwIsInCallStacK("FINA050") .or. FwIsInCallStacK("Fin750050")
	lJurMulDes 	:= (SuperGetMv("MV_IMPBAIX",.t.,"2") == "1")
	lRet		:= .T.
	lExistErro 	:= .F.
	lIncA050	:= .F.		

	//Define se o calculo de valores acessorios sobre a base do imposto(MV_IMPBAIX)
	//ira ocorrer dentro da F050TabIr
	Default lCalcJur := .T.

	If lFINA050
		If Alltrim(M->E2_TIPO) $ MVPAGANT
			lRet := .F.
		Endif		
	Endif
	If lRet .AND. lFINA050 .AND. ( (Type("INCLUI") == "L" .AND. INCLUI) .OR. (Type("ALTERA") == "L" .AND. ALTERA) )
		lIncA050 := .T.
	EndIf
	If lRet
		If Type( "nJuros" ) == "U"
			nJuros := 0
		EndIf
		If Type( "nMulta" ) == "U"
			nMulta := 0
		EndIf
		If Type( "nDescont" ) == "U"
			nDescont := 0
		EndIf	
		If Type( "nMoedaBco" ) == "U"
			nMoedaBco := 1
		EndIf

		lExistErro := If(Type("lMsErroAuto") == "U", lExistErro, lMsErroAuto)

		If !FwIsInCallStack("FA241Borde")
			nJuros := IIF(nJuros==0,fa080Juros(nMoedaBco),nJuros)
		EndIf
		
		If lCalcJur
			If lJurMulDes 
				nValTitulo += nJuros + nMulta - nDescont + IIF(lIncA050, M->(E2_ACRESC - E2_DECRESC) , SE2->(E2_ACRESC - E2_DECRESC))
			Else
				nValTitulo += IIF(lIncA050, M->(E2_ACRESC - E2_DECRESC) , SE2->(E2_ACRESC - E2_DECRESC))
			Endif
		Endif		
		
	Endif

	If SED->ED_JURCAP == "1" .And. SA2->A2_TIPO =="F"
		nValor := (nValTitulo*(SED->ED_PERCIRF/100))
	Else
		nHdlIrf := FOPEN("SIGAADV.IRF",64)
		If nHdlIrf < 0
			Help(" ", 1, "TABIRRF")
			lMsErroAuto := lExistErro
			Return 0
		EndIf

		nTamArq:=FSEEK(nHdlIrf,0,2)
		FSEEK(nHdlIrf,0,0)			 // Volta para inicio do arquivo

		While nBytes<nTamArq
			xBuffer:=Space(40)
			FREAD(nHdlIrf,@xBuffer,40)
			AADD(aTabela,{Val(SubStr(xBuffer,1,15)),Val(SubStr(xBuffer,17,6)),Val(SubStr(xBuffer,24,15))})
			nBytes+=40
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Este If Len(atabela) == 5 foi colocado pois o txt gravado pelo  ³
			//³ windows dava uma dIferen‡a no registro do End of file, gerando  ³
			//³ uma linha a mais no arquivo TXT.										  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len( aTabela ) == 5
				Exit
			EndIf
		End

		nValor := 0

		For nI = 1 to Len(aTabela)
			If !lTabela
				If nValTitulo<=aTabela[nI][1] .or. nI = Len(aTabela)
					If lDedIns .And. lComisVend
						nValor:= nValTitulo-nLimInss
						nValor:= nValor * aTabela[nI][2]/100
						nValor:= nValor - aTabela[nI][3]
						nValor := NoRound(nValor, MsDecimais(2))
					Else
						If lRound
							nValor:= Round(nValTitulo * Iif(aTabela[nI][2] > 0, aTabela[nI][2], 0)/100,2)-aTabela[nI][3]
						Else
							nValor:= NoRound(nValTitulo * Iif(aTabela[nI][2] > 0, aTabela[nI][2], 0)/100)-aTabela[nI][3]
						Endif
					Endif
					lTabela:=.T.
				EndIf
			EndIf
		Next

		FCLOSE(nHdlIrf)

	ENDIF
	nValor := IIF(nValor<0,0,nValor)
Return(nValor)

//-------------------------------------------------------------------
/*/{Protheus.doc} ResetRaRtImp
Limpa variavel static.
@Author William Matos
@since	20/03/2015
/*/
//-------------------------------------------------------------------
Function ResetRaRtImp()
	aRaRtImp    := {}
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} newMinPcc
Cálculo do PCC(Pis, Cofins, Csll) de acordo com a Lei 13.137

@author Caique Ferreira
@since 01/07/2015
@version 1.0
@type function

@param dRef, date, Data de Referencia
@param nValorRef, numeric, Valor de Referencia
@param cNatur, characters, Código da Natureza
@param cCart, characters, Carteira P = Pagar, R = Receber
@param cCliFor, characters, Codigo do Cliente/Fornecedor + Loja
@param nIss, numeric, Valor do ISS
@param nIns, numeric, Valor do INSS
@param nIrf, numeric, Valor do IRRF
@param lMin, logical, Indica se vai validar o valor mínimo do PCC
@param lIgnrOrg, logical, Indica se ignora a origem do título
@param cMotBx, characters, Motivo de baixa
@param nTxMoeda, numeric, taxa de conversão da moeda no momento da baixa

@return aRetPCC, Vetor com os dados do PCC calculado 
@sample aRetPCC[1] - Retorna se foi recalculado.
		aRetPCC[2] - PIS calculado
		aRetPCC[3] - COFINS calculado
		aRetPCC[4] - CSLL calculado
/*/
//-------------------------------------------------------------------
Function newMinPcc(dRef, nValorRef, cNatur, cCart, cCliFor, nIss, nIns, nIrf, lMin, lIgnrOrg, cMotBx, lChkMin, nTxMoeda, nPisNFPc, nCofNFPc, nCslNfPc)

	Local aAmb		 := GetArea()
	Local aAmbCF	 := IIF(cCart == "P", SA2->(getArea("SA2")), SA1->(getArea("SA1")))
	Local aAmbSED 	 := SED->(getArea("SED"))
	Local aRetPCC 	 := Array(5)
	Local lContinua  := .T.
	Local nCsl		 := 0
	Local nPis		 := 0
	Local nCof		 := 0
	Local nVlrMin	 := 0
	Local lVerMin	 := .F.
	Local lRecPis	 := .F.
	Local lRecCof	 := .F.
	Local lRecCsl	 := .F.
	Local lEmpPublic := SuperGetMv("MV_ISPPUBL", .T., "2") == "1"
	Local lPCCBaixa	 := Iif( cCart == "P", SuperGetMv("MV_BX10925",.T.,"2") == "1", SuperGetMv("MV_BR10925",.T.,"2") == "1" )
	Local lBaixa	 := .F.	
	Local lEmissao   := .F.
	Local lFatCom    := .F.
	Local lVerCalc   := .F.
	Local aDadosPar  := {0,0,0,.F.,0,0,0}
	Local cRetCli    := ""
	Local cTipoPes   := ""
	Local aPercPCC   := Array(3)
	Local nPercPIS   := 0
	Local nPercCOF   := 0
	Local nPercCSL   := 0
	Local aOutImp    := {}
	Local lRoundPis  := .F.
	Local lRoundCof  := .F.
	Local lRoundCsl  := .F.
	Local lFatuComp  := .F.
	Local nParciais  := 0
	Local nBasePis   := 0
	Local nBaseCof   := 0
	Local nBaseCsl   := 0
	Local aDadosIRF  := {}
	Local aDadosPIS  := {}
	Local aDadosCOF  := {}
	Local aDadosCSL  := {}
	Local nValorRet  := 0	
	Local lTransf    := .F.
	Local lPisNat    := .F.
	Local lCofNat    := .F.
	Local lCslNat    := .F.
	Local nJuMuDe    := 0
	Local nBxParcial := 1
	Local nSE2Saldo  := 0
	Local lJurMulDes := .F.
	Local nJurMulDes := 0
	Local lMotBxMBco := .F.
	Local cOrigemTit := ""
	Local nRecTit    := ""
	Local nMoedaTit  := 0
	Local nTxMoedTit := 0
	Local lIncAlt	 := .F.
	Local lMata103   := FwIsInCallStacK("MATA103")
	Local lFina340	 := FwIsinCallStack("Fa340comp")
	Local nSaldoAux  := 0
	Local aCodRet	 := {}
	Local nMinPIS
	Local nMinCOF
	Local nMinCSL
	Local aTitCalc	 := {}
	Local lMVRETEMPU := SuperGetMv("MV_RETEMPU",.T.,.T.)   
	Local lCliPublic := .F.
	Local aPccCli    := {} 

	Default nValorRef := 0
	Default nIss	  := 0
	Default nIns	  := 0
	Default nIrf	  := 0
	Default dRef      := dDatabase	
	Default lMin	  := .T.
	Default lIgnrOrg  := .F.	
	Default cMotBx	  := ""
	Default lChkMin   := .F.
	Default nTxMoeda  := 0
	Default nPisNFPc  := 0
	Default nCofNFPc  := 0
	Default nCslNFPc  := 0

	aFill(aRetPCC, 0)
	aRetPCC[1] := .F.
	
	If FwIsInCallStacK("FINA080")
		lIgnrOrg  := .T.
	Endif

	//Não deve reter o PCC, se o parâmetro MV_MB10925 estiver configurado como "1" e o motivo de baixa não gerar movimento bancario
	If !Empty(cMotBx) .and. cMotBx != "CMP"
		lMotBxMBco := ( SuperGetMv("MV_MB10925", .T., "2") == "1" )				
		If ( lMotBxMBco .And. !MovBcoBx(cMotBx,.T.) .And. lPCCBaixa )
			aRetPCC[1] := .F.
			aRetPCC[2] := 0
			aRetPCC[3] := 0
			aRetPCC[4] := 0
			aRetPCC[5] := {}
			
			lContinua := .F.
		EndIf
	EndIf
	
	//Posiciona a natureza e verifica se deve utilizar somente os percentuais de PCC de naturezas e se os mesmos estão informados  
	If lContinua
		SED->( dbSetOrder(1) ) //ED_FILIAL+ED_CODIGO
		If SED->( msSeek( FWxFilial("SED") + cNatur ) )
			lPisNat := SuperGetMv("MV_TPALPIS", .T., "2") == "1" // 1 - Usa percentual de PIS somente da Natureza, 2 - Cadastro de produto ou de natureza ou MV_TXPIS
			lCofNat := SuperGetMv("MV_TPALCOF", .T., "2") == "1" // 1 - Usa percentual de COFINS somente da Natureza, 2 - Cadastro de produto ou de natureza ou MV_TXCOFIN
			lCslNat := SuperGetMv("MV_TPALCSL", .T., "2") == "1" // 1 - Usa percentual de CSL somente da Natureza, 2 - Cadastro de produto ou de natureza ou MV_TXCSLL
		
			If (lPisNat .And. SED->ED_PERCPIS == 0) .And. (lCofNat .And. SED->ED_PERCCOF == 0) .And. (lCslNat .And. SED->ED_PERCCSL == 0)
				lContinua := .F.
				aRetPCC[1] := .F.
			EndIf
		Else
			lContinua := .F.
		EndIf
	EndIf
	
	If lContinua .And. cPaisLoc == "BRA" .And. dRef >= cToD("22/06/2015") .And. (!lEmpPublic .Or. cCart == "R")
		If cCart == "P"
			//Verifica se o Protheus deve recolher o PCC (se o fornecedor não recolher)
			SA2->( dbSetOrder(1) ) //A2_FILIAL+A2_COD+A2_LOJA
			If SA2->( msSeek(xFilial("SA2") + cCliFor) )
				lRecPis := SA2->A2_RECPIS == "2"
				lRecCof := SA2->A2_RECCOFI == "2"
				lRecCsl := SA2->A2_RECCSLL == "2"
				cTipoPes := SA2->A2_TIPO
			EndIf
			
			//Verifica se aplica a validação de valor mínimo do PCC
			If FwIsInCallStack("FA050Inclu")
				lVerMin := M->E2_APLVLMN <> "2"
			Else
				lVerMin := SE2->E2_APLVLMN <> "2"
			EndIf
			
			If Type("aDadosImp") <> "U"
				AFill( aDadosImp, 0 )
			EndIf
			If Type("aDadosRet") <> "U"
				AFill( aDadosRet, 0 )
			EndIf
		Else
			SA1->( dbSetOrder(1) ) //A1_FILIAL+A1_COD+A1_LOJA
			If SA1->( msSeek(xFilial("SA1") + cCliFor) )
				lRecPis := SA1->A1_RECPIS $ "S|P" 	//Sim | Empresa Pública
				lRecCof := SA1->A1_RECCOFI $ "S|P"	//Sim | Empresa Pública
				lRecCsl := SA1->A1_RECCSLL $ "S|P"	//Sim | Empresa Pública
				cTipoPes := SA1->A1_PESSOA
				cRetCli := Iif( Empty(SA1->A1_ABATIMP), "1", SA1->A1_ABATIMP )
				lCliPublic := SA1->A1_RECPIS == "P" .Or. SA1->A1_RECCOFI == "P" .Or. SA1->A1_RECCSLL == "P"
			EndIf
			
			If FwIsInCallStack("FA040Inclu")
				lVerMin := M->E1_APLVLMN <> "2" //Diferente de Não
			Else
				lVerMin := SE1->E1_APLVLMN <> "2" //Diferente de Não
			EndIF
			
			If lVerMin
				If cRetCli == "2"
					lVerMin := .F.
				ElseIf cRetCli == "3"
					lRecPis := .F.
					lRecCof := .F.
					lRecCsl := .F.
				EndIf
			EndIf
		EndIf

		If !Empty(cTipoPes) .And. AllTrim(cTipoPes) <> "F"
			lTransf := FwIsInCallStack("FINA631")
			If lTransf .And. FwIsInCallStack("FINA080")
				SE2->( dbSetOrder(1) ) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
				lContinua := SE2->( msSeek( SE6->E6_FILORIG + SE6->E6_PREFIXO + SE6->E6_NUM + SE6->E6_PARCELA + SE6->E6_TIPO + cCliFor ) )
			EndIf
			
			If lContinua
				lEmissao := ( ( FwIsInCallStack("FA050Nat2") .OR. FwIsInCallStack("FA050Natur") ) .Or. (FwIsInCallStack("A103AtuSE2") .And. !lPCCBaixa) .Or. ;
		                    (FwIsInCallStack("FA040Natur") .And. (M->E1_TIPO $ MVRECANT .Or. !lPCCBaixa)) )
			
		        If FwIsInCallStack("FA280Baixa") .Or. FwIsInCallStack("A460Grava") .Or. FwIsInCallStack("A565Grava") .Or. FwIsInCallStack("fA290Aut")
		        	lVerMin	:= .F.
				EndIf
				
				If cCart == "P"
					cOrigemTit := Iif( lEmissao, M->E2_ORIGEM, SE2->E2_ORIGEM )
					nRecTit := SE2->( Recno() )
				Else
					cOrigemTit := Iif( lEmissao, M->E1_ORIGEM, SE1->E1_ORIGEM )
					nRecTit := SE1->( Recno() )
				Endif

				aPercPcc := GetPerPCC( cNatur, cOrigemTit, cCart, nRecTit, lPCCBaixa )
				
				If __oQryCP <> NIL
					__oQryCP:Destroy()
					__oQryCP := NIL
				Endif

				If __oQryCR <> NIL
					__oQryCR:Destroy()
					__oQryCR := NIL
				Endif

				If lRecPis .And. SED->ED_CALCPIS == "S"
					nPercPIS := aPercPCC[1]
				EndIf
				If lRecCof .And. SED->ED_CALCCOF == "S"
					nPercCOF := aPercPCC[2]
				EndIf
				If lRecCsl .And. SED->ED_CALCCSL == "S"
					nPercCSL := aPercPCC[3]
				EndIf
	
				If cCart == "P"
					lJurMulDes := SuperGetMv("MV_IMPBAIX", .T., "2") == "1"
					If lJurMulDes .And. lPCCBaixa
						nJurMulDes := SE2->(E2_SDACRES - E2_SDDECRE)
					EndIf
										
					lIncAlt := ( FwIsInCallStacK("FA050Alter") .Or. FwIsInCallStacK("FA050Inclu") )
										
					nBasePis := If (lIncAlt, M->E2_BASEPIS, SE2->E2_BASEPIS ) + nJurMulDes
					nBaseCof := If (lIncAlt, M->E2_BASECOF, SE2->E2_BASECOF ) + nJurMulDes
					nBaseCsl := If (lIncAlt, M->E2_BASECSL, SE2->E2_BASECSL ) + nJurMulDes
					
					nMoedaTit := If (lIncAlt, M->E2_MOEDA, SE2->E2_MOEDA )
					If nMoedaTit > 1
						nTxMoedTit := If (lIncAlt, M->E2_TXMOEDA, SE2->E2_TXMOEDA )
					
						If nTxMoedTit == 0
							nTxMoedTit := nTxMoeda
						EndIf
						
						If AllTrim(SE2->E2_ORIGEM) == "MATA100"	.OR. lMata103	//Base dos impostos vindos do Compras já estão na moeda corrente
							nBasePis := nValorRef
							nBaseCof := nValorRef
							nBaseCsl := nValorRef
						Else
							nBasePis := xMoeda( nBasePis, nMoedaTit, 1, dRef,, nTxMoedTit )
							nBaseCof := xMoeda( nBaseCof, nMoedaTit, 1, dRef,, nTxMoedTit )
							nBaseCsl := xMoeda( nBaseCsl, nMoedaTit, 1, dRef,, nTxMoedTit )
						Endif
					Endif
				Else
					If SE1->E1_MOEDA > 1 .And. FwIsInCallStacK("FINA070")
						nBasePis := xMoeda(nValorRef, SE1->E1_MOEDA, 1, dRef,, SE1->E1_TXMOEDA)
						nBaseCof := xMoeda(nValorRef, SE1->E1_MOEDA, 1, dRef,, SE1->E1_TXMOEDA)
						nBaseCsl := xMoeda(nValorRef, SE1->E1_MOEDA, 1, dRef,, SE1->E1_TXMOEDA)
					Else
						If lCliPublic .And. lMVRETEMPU .And. !lEmissao 
							aPccCli  := FinxCPcc(nValorRef)
							nBasePis := aPccCli[1]
							nBaseCof := aPccCli[2]
							nBaseCsl := aPccCli[3]
						Else 
							nBasePis := nValorRef
							nBaseCof := nValorRef
							nBaseCsl := nValorRef
						EndIf 
					Endif
				Endif
								
				If cCart == "P" .And. !lEmissao
					// Variável para calcular a proporcionalidade do PCC.
					nSE2Saldo := salRefPag(SE2->E2_FORNECE + SE2->E2_LOJA,,,,,,, .T.,nTxMoeda) + nJurMulDes
					If !lMata103 .OR. (lMata103 .AND. lFina340)	//Nova compensação automática
						nSaldoAux := nSE2Saldo
						If SE2->E2_MOEDA > 1 

							If Alltrim(SE2->E2_ORIGEM) == 'MATA100'
								nSaldoAux := xMoeda(nSaldoAux, SE2->E2_MOEDA, 1, dRef,, nTxMoeda)
							Else
								If SE2->E2_TXMOEDA > 0
									nSaldoAux := xMoeda(nSaldoAux, SE2->E2_MOEDA, 1, dRef,, SE2->E2_TXMOEDA)
								Else
									nSaldoAux := xMoeda(nSaldoAux, SE2->E2_MOEDA, 1, dRef,, nTxMoeda)
								EndIf 
							EndIF
						EndIf
						
						nBxParcial := nValorRef / nSaldoAux						
					Endif

					If nBxParcial == 0
						nBxParcial := 1
					Endif
	
					// Proporcionaliza a base do PCC.
					nBasePis *= nBxParcial
					nBaseCof *= nBxParcial
					nBaseCsl *= nBxParcial
	
					If lIgnrOrg
						lFatuComp := .F.
					Else
						lFatuComp := Alltrim(SE2->E2_ORIGEM) $ "MATA461|MATA460|MATA103|MATA100|FINA631" .Or. FwIsInCallStack("MAPVLNFS") .Or. FwIsInCallStack("MATA103")
					EndIf
					If lFatuComp
						If SE2->E2_BASEPIS > 0 .or. SE2->E2_BASECOF > 0 .or. SE2->E2_BASECSL > 0
							nJuMuDe := F080JuMuDe()
							If SE2->(E2_SDACRES - E2_SDDECRE) == 0
								nJuMuDe += nJurMulDes // somo os acrescimo e decrescimo, pois não está considerando no F080JumuDe
							EndIF
	
							// Se for baixa parcial.
							If nValorRef != nSE2Saldo
								aDadosIRF := retBxTit(cCart, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, "01", "IRF")
								aDadosPIS := retBxTit(cCart, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, "01", "PIS")
								aDadosCOF := retBxTit(cCart, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, "01", "COF")
								aDadosCSL := retBxTit(cCart, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, "01", "CSL")
								
								If SuperGetMv("MV_BP10925", .F., "1") == "2" //Verifica se considera o valor líquido do pagamento
									nValorRet := aDadosIRF[3] + aDadosPIS[4] + aDadosCOF[5] + aDadosCSL[6]
								Endif
	
								nParciais := aDadosPIS[1] + nValorRet
								If nValorRef + nParciais > SE2->E2_VALOR // se o valor baixado já atingiu o valor total
									nBasePis := (SE2->E2_BASEPIS + nJuMuDe) - nParciais
									If nBasePis <= 0
										nBasePis  := 0
										nPercPIS := 0
									EndIf
								EndIf
	
								nParciais := aDadosCOF[1] + nValorRet
								If nValorRef + nParciais > SE2->E2_VALOR // se o valor baixado já atingiu o valor total
									nBaseCof := (SE2->E2_BASECOF + nJuMuDe) - nParciais
									If nBaseCof <= 0
										nBaseCof  := 0
										nPercCOF := 0
									EndIf
								EndIf
	
								nParciais := aDadosCSL[1] + nValorRet
								If nValorRef + nParciais > SE2->E2_VALOR // se o valor baixado já atingiu o valor total
									nBaseCsl := (SE2->E2_BASECSL + nJuMuDe) - nParciais
									If nBaseCsl <= 0
										nBaseCsl  := 0
										nPercCSL := 0
									EndIf
								EndIf
								
								FwFreeArray(aDadosIRF)
								FwFreeArray(aDadosPIS)
								FwFreeArray(aDadosCOF)
								FwFreeArray(aDadosCSL)
							Endif
						EndIf
					EndIf
				EndIf
				
				If lTransf .And. AllTrim(SE2->E2_ORIGEM) $ "|MATA100|" //Regra de transferência
					nPis := Iif( nBasePis > 0 .And. cCart == "P", nBasePis, SE2->E2_BASEPIS ) * ( nPercPIS / 100 )
					nCof := Iif( nBaseCof > 0 .And. cCart == "P", nBaseCof, SE2->E2_BASECOF ) * ( nPercCOF / 100 )
					nCsl := Iif( nBaseCsl > 0 .And. cCart == "P", nBaseCsl, SE2->E2_BASECSL ) * ( nPercCSL / 100 )
				Else
					nPis := Iif( nBasePis > 0, nBasePis, nValorRef ) * ( nPercPIS / 100 )
					nCof := Iif( nBaseCof > 0, nBaseCof, nValorRef ) * ( nPercCOF / 100 )
					nCsl := Iif( nBaseCsl > 0, nBaseCsl, nValorRef ) * ( nPercCSL / 100 )
				EndIf
				
				// Trunca ou arredonda os valor conforme os parâmetros MV_RNDPIS, MV_RNDCOF e MV_RNDCSL.
				lRoundPis := SuperGetMV("MV_RNDPIS",,.F.)
				lRoundCof := SuperGetMV("MV_RNDCOF",,.F.)
				lRoundCsl := SuperGetMV("MV_RNDCSL",,.F.)			
				nPis := Iif( lRoundPis, Round(nPis, 2), NoRound(nPis, 2) )
				nCof := Iif( lRoundCof, Round(nCof, 2), NoRound(nCof, 2) )
				nCsl := Iif( lRoundCsl, Round(nCsl, 2), NoRound(nCsl, 2) )

				//Verificação de arredondamento entre os valores calculados na NFE e na NewMinPcc	
				If lMata103
					If nPisNFPc > 0
						nPis := IiF((nPis - nPisNFPc) <= 0.01, nPisNFPc, nPis )
					EndIf

					If nCofNFPc > 0
						nCof := IiF((nCof - nCofNFPc) <= 0.01, nCofNFPc, nCof )
					EndIf

					If nCslNFPc > 0
						nCsl := IiF((nCsl - nCslNFPc) <= 0.01, nCslNFPc, nCsl )
					EndIf
				Endif

				//Variaveis utilizadas na reestruturação da SE5
				nPisCalc  := nPis
				nCofCalc  := nCof
				nCslCalc  := nCsl
				nPisBaseC := nPisBaseR := Iif(nBasePis > 0, nBasePis, nValorRef)
				nCofBaseC := nCofBaseR := Iif(nBaseCof > 0, nBaseCof, nValorRef)
				nCslBaseC := nCslBaseR := Iif(nBaseCsl > 0, nBaseCsl, nValorRef)
				
				lBaixa := lPCCBaixa .And. ( FwIsInCallStack("fA080Tit") .Or. FwIsInCallStack("FA080Lot") .Or. FwIsInCallStack("fA090Aut") .Or. ;
						  FwIsInCallStack("fA091Aut") .Or. FwIsInCallStack("fA241Borde") .Or. FwIsInCallStack("fA070Tit") .Or. FwIsInCallStack("fA070Lot") .Or. ;
						  FwIsInCallStack("FA110Aut") .Or. FwIsInCallStack("fa061borde") .Or. FwIsInCallStack("fA330Comp") .Or. FwIsInCallStack("FinA590") .Or. ;
						  FwIsInCallStack("fA200Ger") .Or. FwIsInCallStack("fA390Tit") .Or. FwIsInCallStack("fA340Comp") .Or. FwIsInCallStack("FA450CMP")  .Or. ;
						  FwIsInCallStack("PIXGerImp") )
						  
				lFatCom  := FwIsInCallStack("MAPVLNFS") .OR. FwIsInCallStack("A103ATUSE2")
				lVerCalc := lPCCBaixa .And. (( FwIsInCallStack("FA050Nat2") .And. M->E2_TIPO <> MVPAGANT ) .Or. ;
				            (FwIsInCallStack("FA040Natur") .And. M->E1_TIPO <> MVRECANT  ) .Or. lFatCom )
				            
				// Ver recalculo de PCC com baixas parciais e mudança de aliquota.
				If !lTransf .And. !lVerCalc .And. lVerMin .And. (lBaixa .Or. lEmissao .Or. lFatCom)
					If cCart == "P"
						If lEmissao .And. !lFatCom
							aDadosPar := SumDay( cCart, FWxFilial("SE2"), M->E2_FORNECE, M->E2_LOJA, M->E2_TIPO, dRef, cFilAnt, @aTitCalc )
						Else
							aDadosPar := SumDay( cCart, SE2->E2_FILIAL, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_TIPO, dRef, SE2->E2_FILORIG , @aTitCalc )
						EndIf
					Else
						If lEmissao .And. !lFatCom
							aDadosPar := SumDay( cCart, FWxFilial("SE1"), M->E1_CLIENTE, M->E1_LOJA, M->E1_TIPO, dRef, cFilAnt , @aTitCalc )
						Else
							aDadosPar := SumDay( cCart, SE1->E1_FILIAL, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_TIPO, dRef, SE1->E1_FILORIG , @aTitCalc )
						EndIf
					EndIf
					
					nPis += aDadosPar[1]
					nCof += aDadosPar[2]
					nCsl += aDadosPar[3]
					lVerMin := aDadosPar[4]
				EndIf
				
				nVlrMin := SuperGetMv( "MV_VL13137", .T., 10 )
				If !lVerCalc .And. lVerMin .and. lMin
					aCodRet := getCodRet()
					
					If nCsl > 0 .AND. nCof > 0 .AND. nPis > 0 .Or. (lCliPublic .And. lMVRETEMPU .And. !lEmissao .And. (nCsl > 0 .OR. nCof > 0 .OR. nPis > 0)  ) 
					
						If (nCsl + nCof + nPis) <= nVlrMin .And. lMin
							nCsl := 0
							nCof := 0
							nPis := 0
							nPisBaseR := nCofBaseR := nCslBaseR := 0
						EndIf
			
						//Garanto que não vai tentar reter um valor maior que o saldo do título.
						If !lVerCalc .And. lVerMin .And. (lBaixa .Or. lEmissao .Or. lFatCom) .And. (nCsl + nCof + nPis) > nVlrMin
			
							aAdd( aOutImp, {"PIS", nPis} )
							aAdd( aOutImp, {"COF", nCof} )
							aAdd( aOutImp, {"CSL", nCsl} )
							aAdd( aOutImp, {"IRF", nIrf} )
							aAdd( aOutImp, {"INS", nIns} )
							aAdd( aOutImp, {"ISS", nIss} )
			
							aDadosPar := verVrAR(nValorRef, aOutImp)
							nPis := aDadosPar[1]
							nCof := aDadosPar[2]
							nCsl := aDadosPar[3]

							FwFreeArray(aOutImp)
						EndIf
					ElseIf cCart == "P" .And. lMin

						If (nCsl + nCof + nPis) <= nVlrMin .And. lMin
							nCsl := 0
							nCof := 0
							nPis := 0
							nPisBaseR := nCofBaseR := nCslBaseR := 0
						Else
							nMinPIS := SuperGetMv( "MV_VRETPIS", .T., 0 )
							nMinCOF := SuperGetMv( "MV_VRETCOF", .T., 0 )
							nMinCSL := SuperGetMv( "MV_VRETCSL", .T., 0 )

							If nPis + aDadosPar[5]<= nMinPIS 
								nPis := 0
								nPisBaseR := 0
							EndIf
							If nCof + aDadosPar[6]<= nMinCOF 
								nCof := 0
								nCofBaseR := 0
							EndIf
							If nCsl + aDadosPar[7]<= nMinCSL 
								nCsl := 0
								nCslBaseR := 0
							EndIf
						EndIf					
					EndIf
					
					FwFreeArray(aCodRet)
				Endif
				aRetPCC[1] := .T.

			EndIf
		EndIf
	EndIf
	
	aRetPCC[2] := nPis
	aRetPCC[3] := nCof
	aRetPCC[4] := nCsl
	aRetPCC[5] := aTitCalc //Título acumulados na retenção
	lChkMin := lVerMin
	
	RestArea(aAmbSED)
	RestArea(aAmbCF)
	RestArea(aAmb)
	
	FwFreeArray(aAmb)
	FwFreeArray(aAmbCF)
	FwFreeArray(aAmbSED)
	FwFreeArray(aDadosPar)
	FwFreeArray(aPercPCC)
Return aRetPCC

//-------------------------------------------------------------------
/*/{Protheus.doc}salRefPag
Verificar saldo do título pendente a ser baixado, considerando
impostos na emissão e baixa e sistema configurado como líquido e bruto.

@param cFornece - Código do fornecedor
@param nTxMoeda, numeric, taxa da moeda no momento da baixa
@param nMoedaBco, numeric, moeda do banco

@return nSalTit - Retorna o saldo do título pendente a calcular
os impostos proporcional a baixa.

@author Caique Ferreira
@since  01/07/2015
/*/
//-------------------------------------------------------------------
Function salRefPag(cFornece, _lPccMR, _lIrfMR, _lInsMR, _lIssMR, _lCidMR, _lSesMR, lTotal, nTxMoeda, nMoedaBco)
	Local lMVBP10925	:= SuperGetMv("MV_BP10925",.F., "1") == "2" // Default (Bruto)
	Local lCalcIssBx 	:= IIF(lIsIssBx, IsIssBx("P"), SuperGetMv("MV_MRETISS",.F.,"1") == "2" )
	Local lIRPFBaixa	:= .F.
	Local lInssBx		:= SuperGetMv("MV_INSBXCP",.F.,"2") == "1"
	Local lPCCBaixa		:= SuperGetMv("MV_BX10925",.T.,"2") == "1"
	Local lBtrISS		:= .F.
	Local nIssAux		:= 0
	Local aDadosBx		:= Array(8)
	Local nSalTit 		:= 0
	Local nPercMax		:= 0
	Local nPercAtu		:= 0
	Local nIrf			:= 0
	Local nCsl			:= 0
	Local nPis			:= 0
	Local nCof			:= 0
	Local nIns			:= 0
	Local nIss			:= 0
	Local lLiqFat		:= (!Empty(SE2->E2_FATURA) .Or. !Empty(SE2->E2_NUMLIQ))
	Local lFina241		:= FwIsInCallStack("F241Impost")
	Local nBasePCC		:= 0
	Local nVlrImp       := 0
	Local nCmpDicNdf	:= 0
	Local cChaveTit 	:= ""
	Local cChvTitFK7	:= ""
	Local nTxTitInc		:= 0 //taxa da moeda de inclusão do título
	Local nCentMd1   	:= MsDecimais(1)
	Local lMVAG10925    := SuperGetMV("MV_AG10925", .F., 2) == "1"
	
	Default _lPccMR 	:= .F.
	Default _lIrfMR 	:= .F.
	Default _lInsMR 	:= .F.
	Default _lIssMR 	:= .F.
	Default _lCidMR 	:= .F.
	Default _lSesMR 	:= .F.
	Default lTotal  	:= .F.
	Default nTxMoeda  	:= 0
	Default nMoedaBco	:= 1

	If cPaisLoc == "BRA"
		Afill(aDadosBx, 0)

		If SE2->E2_TXMOEDA == 0
			nTxTitInc := RecMoeda(SE2->E2_EMISSAO,SE2->E2_MOEDA)
		else
			nTxTitInc := SE2->E2_TXMOEDA
		EndIf

		DbSelectArea("SA2")
		SA2->(DbSetOrder(1))
		SA2->(DbSeek(xFilial("SA2")+cFornece))

		If SE2->(E2_SALDO = E2_VALOR .AND. (E2_BASEPIS + E2_BASECOF + E2_BASECSL) > 0 .and. (nBasePCC := GetBsPccPg()) = E2_SALDO)
			nSalTit := nBasePCC
		Else
			If !_lIrfMR
				lIRPFBaixa := SA2->A2_CALCIRF == "2" .And. Posicione("SED",1,xfilial("SED") + SE2->(E2_NATUREZ),"ED_CALCIRF") = "S" .And. !SE2->E2_TIPO $ MVPAGANT
			EndIf
			//Sistema como bruto pessoa fisica e Irrf na Baixa, base é diferenciada
			If !lMVBP10925 .And. lIRPFBaixa .And. SA2->A2_TIPO == 'F' .And. !lLiqFat
				If !_lIrfMR
					aDadosBx := retBxTit("P",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,"01","IRF",,nMoedaBco)
					nSalTit := SE2->E2_BASEIRF - aDadosBx[2]
				EndIf
			Else
				If lTotal
					If lLiqFat // Tratamento p/ Liquidação-Fatura
						nSalTit := GetBsPccPg()
					Else
						nSalTit := SE2->E2_VALOR
					Endif
				Else
					If lLiqFat // Tratamento p/ Liquidação-Fatura
						nSalTit := If(!_lPccMR, GetBsPccPg() - SE2->(E2_VALOR - E2_SALDO), nSalTit)
					Else
						nSalTit := SE2->E2_SALDO
					EndIf
										
					//Recompõe a base de imposto com os valores de compensação com DIC para calcular corretamente os valores de impostos
					cChaveTit := SE2->E2_FILIAL + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
					cChvTitFK7 := FINGRVFK7("SE2", cChaveTit)					
					nCmpDicNdf := TotCmpDic(cChvTitFK7)
					nSalTit += nCmpDicNdf

					//Sistema configurado como bruto
					If !lMVBP10925 .Or. (lFina241 .And. (lIRPFBaixa .Or. lCalcIssBx .Or. lInssBx ) )
						If lIRPFBaixa .And. !_lIrfMR
							aDadosBx := retBxTit("P",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,"01","IRF",,nMoedaBco)
							nIrf 	  := aDadosBx[3]
							nPercAtu := nIrf/SE2->E2_IRRF
							nPercMax := nPercAtu
						EndIf
						
						If !_lPccMR .And. lPCCBaixa
							aDadosBx := retBxTit("P",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,"01","PIS", Nil, nMoedaBco)
							
							If lMVAG10925
								If Len(aDadosBx) >= 4
									nPis := aDadosBx[4]
								EndIF
								
								If Len(aDadosBx := retBxTit("P",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,"01","COF", Nil, nMoedaBco)) >= 5
									nCof := aDadosBx[5]
								EndIf
								
								If Len(aDadosBx := retBxTit("P",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,"01","CSL", Nil, nMoedaBco)) >= 6
									nCsl := aDadosBx[6]
								EndIf
								
								nPercAtu := ((nPis+nCof+nCsl) / SE2->(E2_PIS+E2_COFINS+E2_CSLL))
								
								If nPercAtu > nPercMax
									nPercMax := nPercAtu
								EndIf							
							Else
								nPis := aDadosBx[4]
								nPercAtu := nPis/SE2->E2_PIS
									
								If nPercAtu > nPercMax
									nPercMax := nPercAtu
								EndIf
								
								aDadosBx := retBxTit("P",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,"01","COF",,nMoedaBco)
								nCof := aDadosBx[5]
								nPercAtu := nCof/SE2->E2_COFINS
									
								If nPercAtu > nPercMax
									nPercMax := nPercAtu
								EndIf
								
								aDadosBx := retBxTit("P",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,"01","CSL",,nMoedaBco)
								nCsl := aDadosBx[6]
								nPercAtu := nCsl/SE2->E2_CSLL
								
								If nPercAtu > nPercMax
									nPercMax := nPercAtu
								EndIf
							EndIF
						EndIF

						If !_lInsMR .And. lInssBx
							aDadosBx := retBxTit("P",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,"01","INS",,nMoedaBco)
							nIns := aDadosBx[7]
							nPercAtu := nIns/SE2->E2_INSS
							If nPercAtu > nPercMax
								nPercMax := nPercAtu
							EndIf
						EndIF

						If !_lIssMR .And. lCalcIssBx
							aDadosBx := retBxTit("P",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,"01","ISS",,nMoedaBco)
							nIss := aDadosBx[8]
							nPercAtu := nIss/SE2->E2_ISS
							If nPercAtu > nPercMax
								nPercMax := nPercAtu
							EndIf
						EndIF

						If !_lIrfMR .And. lIRPFBaixa .And. IIF(SA2->A2_MINIRF == "2", nIrf >= SuperGetMv("MV_VLRETIR",.t.,10) , .F.)
							If nPercMax <> (nIrf/SE2->E2_IRRF) .and. SE2->E2_IRRF > 0
								If SE2->E2_MOEDA == 1
									nSalTit += nPercMax * SE2->E2_IRRF
								else
									nSalTit += nPercMax * Round(xMoeda(SE2->E2_IRRF,nMoedaBco, SE2->E2_MOEDA, SE2->E2_EMISSAO,3,,nTxTitInc), nCentMd1)
								EndIf
							Else
								If SE2->E2_MOEDA == 1
									nSalTit += nIrf
								else
									nSalTit += Round(xMoeda(nIrf,nMoedaBco, SE2->E2_MOEDA, SE2->E2_EMISSAO,3,,nTxTitInc), nCentMd1)
								EndIf								
							EndIf				
						EndIf

						If !_lPccMR .And. lPCCBaixa .And.  (nPis+nCof+nCsl) > SuperGetMv("MV_VL13137", .T., 10 )
							If nPercMax <> ((nPis+nCof+nCsl)/SE2->(E2_PIS+E2_COFINS+E2_CSLL))
								If SE2->E2_MOEDA == 1
									nSalTit += nPercMax * (SE2->(E2_PIS+E2_COFINS+E2_CSLL))
								else
									nSalTit += nPercMax *Round(xMoeda((SE2->(E2_PIS+E2_COFINS+E2_CSLL)),nMoedaBco, SE2->E2_MOEDA, SE2->E2_EMISSAO,3,,nTxTitInc), nCentMd1)
								EndIf 
							Else
								If SE2->E2_MOEDA == 1
									nSalTit += (nPis+nCof+nCsl)
								else
									nSalTit += Round(xMoeda((nPis+nCof+nCsl),nMoedaBco, SE2->E2_MOEDA, SE2->E2_EMISSAO,3,,nTxTitInc), nCentMd1)
								EndIf 								
							EndIf
						EndIf

						If !_lIssMR .And. lCalcIssBx
							If nPercMax <> (nIss/SE2->E2_ISS) 
								If SE2->E2_MOEDA == 1
									nSalTit += nPercMax * SE2->E2_ISS
								else
									nSalTit += nPercMax * Round(xMoeda(SE2->E2_ISS,nMoedaBco, SE2->E2_MOEDA,SE2->E2_EMISSAO,3,,nTxTitInc), nCentMd1)
								EndIf
							Else
								If SE2->E2_MOEDA == 1
									nSalTit += nIss
								else
									nSalTit += Round(xMoeda(nIss,nMoedaBco, SE2->E2_MOEDA,SE2->E2_EMISSAO,3,,nTxTitInc), nCentMd1)
								EndIf								
							EndIf
						EndIF
					EndIf
				EndIf

				If !lLiqFat
					//Títulos com impostos na emissão   
					If !_lPccMR .And. !_lIrfMR .And. !_lIssMR .And. !_lInsMR
						nVlrImp := PropImpEm("SE2", lPCCBaixa, lIRPFBaixa, lCalcIssBx) //Retorna o valor sempre em moeda 1
						nSalTit += Round(xMoeda(nVlrImp,nMoedaBco, SE2->E2_MOEDA, SE2->E2_EMISSAO,3,,nTxTitInc), nCentMd1)
					EndIf
					
					If nVlrImp == 0
						nIssAux := 0
						
						If !_lIssMR .And. !lCalcIssBx .And. SE2->E2_ISS > 0
							lBtrISS := SE2->(ColumnPos("E2_BTRISS")) > 0 .And. SE2->(ColumnPos("E2_VRETBIS")) > 0 .And. SE2->(ColumnPos("E2_CODSERV")) > 0 .And.;
						   		   	   FindFunction("ISSCPOM") .And. FindFunction("BtrISSMun")
							nIssAux := Iif( lBtrISS, SE2->E2_ISS + SE2->E2_BTRISS, SE2->E2_ISS )
							nIssAux	:= Round(xMoeda(nIssAux, 1, SE2->E2_MOEDA, dDataBase,3,,nTxTitInc), 2)
						Else
							nIssAux := 0
						EndIf
						
						nSalTit += nIssAux 

						//Irrf Emissão Legado
						If !_lIrfMR .And. !lIRPFBaixa .And. SE2->E2_IRRF > 0
							nSalTit += Round(xMoeda(SE2->E2_IRRF, 1, SE2->E2_MOEDA, dDataBase,4,, nTxTitInc), 2)
						Endif
					
						//Inss Emissão Legado
						If !_lInsMR  .And. SE2->E2_INSS > 0
							nSalTit += Round(xMoeda(SE2->E2_INSS, 1, SE2->E2_MOEDA, dDataBase,4,, nTxTitInc), 2)
						Endif

						//PCC Emissão Legado
						If !_lPccMR .And. !lPCCBaixa .And. SE2->(E2_PIS+E2_COFINS+E2_CSLL) > 0
							nSalTit += Round(xMoeda(SE2->(E2_PIS+E2_COFINS+E2_CSLL), 1, SE2->E2_MOEDA, dDataBase,4,, nTxTitInc), 2)
						Endif

							
					EndIf
				EndIf
			EndIf
			nSalTit += FMRGETRET("P", "SE2", .T.)	//Busca as retenções da emissão geradas pelo configurador de impostos
		EndIf
	EndIf
	
	FwFreeArray(aDadosBx)
Return nSalTit

//------------------------------
/*/{Protheus.doc}PropImpEm
Retorna o valor proporcionazado dos impostos da emissão.
para recomposição de base (Baixa/Compensação)

@author Sivaldo Oliveira
@since  15/02/2019
@version 12
/*/
//------------------------------
Function PropImpEm(cSE2 As Character, lPCCBaixa As Logical, lIRPFBaixa As Logical, lCalcIssBx As Logical) As Numeric
	Local lRet      As Logical
	Local aSE2      As Array
	Local cQry      As Character 
	Local cTblTmp   As Character
	Local cDoc      As Character
	Local aDoc      As Array
	Local cE5_KEY   As Character
	Local cE5_MOVCX As Character
	Local nTamDoc   As Numeric
	Local nImpEm    As Numeric
	Local nVlrNF    As Numeric
	Local nPropoc   As Numeric
	Local nX		As Numeric
	Local nIssAux	As Numeric
	Local nRecnoAux As Numeric
	Local lPccPA	As Logical
	Local lIrfPA	As Logical
	Local lIssPA	As Logical
	Local lInsPA	As Logical
	Local lBtrISS	As Logical	

	Default cSE2       := "SE2"
	Default lPCCBaixa  := .F.
	Default lIRPFBaixa := .F.
	Default lCalcIssBx := .F.
	
	lRet := !Empty(cSE2) .And.;
			!(cSE2)->E2_TIPO $ MVPAGANT+"|"+MV_CPNEG+"|"+MVABATIM+"|INA|DIC" .And.;
			!SuperGetMv("MV_PABRUTO", .F., "2") $ "1| " .And.; 
			!FwIsInCallStack("NewMinPcc") .And.;
			((!lPCCBaixa .And. (cSE2)->(E2_PIS+E2_COFINS+E2_CSLL) > 0) .Or.;
			(!lIRPFBaixa .And. (cSE2)->E2_IRRF > 0) .Or.;
			(!lCalcIssBx .And. (cSE2)->E2_ISS > 0))
	
	//Inicializa variáveis
	nImpEm    := 0
	
	If lRet
		cQry      := ""
		cTblTmp   := ""
		cDoc      := PadR((cSE2)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA), TamSx3("E5_DOCUMEN")[1], " ")
		aDoc      := {}
		cE5_KEY   := Space(TamSx3("E5_KEY")[1]) 
		cE5_MOVCX := Space(TamSx3("E5_MOVCX")[1])
		nTamDoc   := TamSx3("E5_DOCUMEN")[1]		
		nVlrNF    := 0
		nPropoc   := 0
		
		If !lCalcIssBx
			lBtrISS := SE2->(ColumnPos("E2_BTRISS")) > 0 .And. SE2->(ColumnPos("E2_VRETBIS")) > 0 .And. SE2->(ColumnPos("E2_CODSERV")) > 0 .And.;
					   FindFunction("ISSCPOM") .And. FindFunction("BtrISSMun")
			nIssAux := Iif( lBtrISS, (cSE2)->(E2_ISS) + (cSE2)->(E2_BTRISS), (cSE2)->(E2_ISS) )
		Else
			nIssAux := 0
		EndIf
		
		nImpEm    += If( !lPCCBaixa,(cSE2)->(E2_PIS+E2_COFINS+E2_CSLL), 0)
		nImpEm    += If( !lIRPFBaixa, (cSE2)->E2_IRRF, 0)
		nImpEm    += nIssAux
		nImpEm    += (cSE2)->E2_INSS
		
		If __oObjPA == Nil
			// Query de Busca por Adiantamentos/Devoluções compensados com o Título.
			cQry := "SELECT SE5.E5_PREFIXO,SE5.E5_NUMERO,SE5.E5_PARCELA,SE5.E5_TIPO,SE5.E5_FORNECE,SE5.E5_LOJA,SE5.E5_FILIAL,SE5.E5_FILORIG,SE5.E5_DOCUMEN "
			cQry += "FROM " + RetSqlName("SE5") + " SE5 JOIN " + RetSqlName("SE2") + " SE2 "
			cQry += "ON (SE5.E5_FILORIG = SE2.E2_FILORIG AND SE5.E5_PREFIXO = SE2.E2_PREFIXO AND "
			cQry += "SE5.E5_NUMERO = SE2.E2_NUM AND "
			cQry += "SE5.E5_PARCELA = SE2.E2_PARCELA AND SE5.E5_TIPO = SE2.E2_TIPO AND "
			cQry += "SE5.E5_FORNECE = SE2.E2_FORNECE AND SE5.E5_LOJA = SE2.E2_LOJA) WHERE "
			cQry += "SE5.E5_DOCUMEN = ? AND "  
			cQry += "SE5.E5_RECPAG = 'P' AND SE5.E5_TIPODOC = 'BA' AND " 
			cQry += "SE5.E5_MOTBX = 'CMP' AND " 
			cQry += "SE5.E5_ORIGEM NOT IN ('MATA103 ', 'MATA103') AND " 
			cQry += "SE5.E5_KEY = '" + cE5_KEY + "' AND " 
			cQry += "SE5.E5_MOVCX = '" + cE5_MOVCX + "' AND " 
			cQry += "SE2.E2_SALDO = 0 AND SE5.D_E_L_E_T_ = ' ' AND " 
			cQry += "SE5.E5_SEQ NOT IN ("
			cQry += "SELECT EST.E5_SEQ FROM " + RetSqlName("SE5") + " EST WHERE " 
			cQry += "EST.E5_DOCUMEN = ? AND " 
			cQry += "EST.E5_RECPAG = 'R' AND " 
			cQry += "EST.E5_TIPODOC = 'ES' AND " 
			cQry += "EST.E5_ORIGEM NOT IN ('MATA103 ', 'MATA103') AND " 
			cQry += "EST.E5_KEY = ' " + cE5_KEY + "' AND " 
			cQry += "EST.E5_MOTBX = 'CMP' AND "
			cQry += "EST.E5_MOVCX = '" + cE5_MOVCX + "' AND EST.D_E_L_E_T_ = ' ') "
			cQry += "GROUP BY E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_FORNECE, E5_LOJA, E5_FILIAL, E5_FILORIG, E5_DOCUMEN "
			cQry := ChangeQuery(cQry)
			__oObjPA := FWPreparedStatement():New(cQry)
		EndIf
		
		__oObjPA:SetString(1, cDoc)
		__oObjPA:SetString(2, cDoc)
		cQry    := __oObjPA:GetFixQuery()
		cTblTmp := MpSysOpenQuery(cQry)
		(cTblTmp)->(DbGoTop())
		
		While (cTblTmp)->(!Eof()) .And. !Empty((cTblTmp)->E5_DOCUMEN)
			Aadd(aDoc, { PadR((cTblTmp)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_FORNECE+E5_LOJA), nTamDoc), (cTblTmp)->E5_FILORIG })
			(cTblTmp)->(DbSkip())
		EndDo
		
		(cTblTmp)->(DbCloseArea())
		cTblTmp := ""
		
		aSE2 := SE2->( GetArea() )
		SE2->( dbSetOrder( 1 ) ) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		nRecnoAux := SE2->( Recno() )

		For nX := 1 To Len(aDoc)

			//Verifica se o ADIANTAMENTO calcula impostos
			If SE2->( msSeek( FWxFilial("SE2", aDoc[nX][2]) + aDoc[nX][1] ) )
				If SE2->( E2_PIS + E2_COFINS + E2_CSLL + E2_IRRF + E2_ISS + E2_PRISS + E2_INSS + E2_PRINSS ) == 0
					Loop //Despreza adiantamentos que não possuem tratamento de IMPOSTOS
				EndIf
			Else
				Loop
			EndIf

			lPccPA := !lPCCBaixa .And. SE2->(E2_PIS + E2_COFINS + E2_CSLL) > 0
			lIrfPA := !lIRPFBaixa .And. SE2->E2_IRRF > 0
			lIssPA := !lCalcIssBx .And. SE2->(E2_ISS + E2_PRISS) > 0
			lInsPA :=  SE2->(E2_INSS + E2_PRINSS) > 0 

			SE2->( dbGoTo(nRecnoAux) )

			// Monta base da Nota Fiscal
			nVlrNF := (cSE2)->(E2_VALOR+E2_INSS) 
			
			If !lPCCBaixa
				nVlrNF += (cSE2)->(E2_PIS+E2_COFINS+E2_CSLL) 
			EndIf	
			
			If !lIRPFBaixa
				nVlrNF += (cSE2)->E2_IRRF
			EndIf
			
			If !lCalcIssBx
				nIssAux := Iif( lBtrISS, (cSE2)->E2_ISS + (cSE2)->E2_BTRISS, (cSE2)->(E2_ISS) )
				nVlrNF += nIssAux
			EndIf
			
			If __oObjNF == Nil
				// Query de busca p/ compensações com tratamento de IMPOSTOS.
				cQry := "SELECT ISNULL(SUM(SE5.E5_BASEIRF), 0) BASEIMP FROM " + RetSqlName("SE5") + " SE5 "
				cQry += "JOIN " + RetSqlName("SE2") + " SE2 ON ("
				cQry += "SE5.E5_FILORIG = SE2.E2_FILORIG AND SE5.E5_PREFIXO = SE2.E2_PREFIXO AND "
				cQry += "SE5.E5_NUMERO = SE2.E2_NUM AND "
				cQry += "SE5.E5_PARCELA = SE2.E2_PARCELA AND SE5.E5_TIPO = SE2.E2_TIPO AND "
				cQry += "SE5.E5_FORNECE = SE2.E2_FORNECE AND SE5.E5_LOJA = SE2.E2_LOJA) "
				cQry += "WHERE SE5.E5_DOCUMEN = ? AND "
				cQry += "SE2.E2_FILIAL = ? AND "
				cQry += "SE2.E2_NUM = ? AND "
				cQry += "SE2.E2_PARCELA = ? AND "
				cQry += "SE2.E2_TIPO = ? AND "
				cQry += "SE2.E2_FORNECE = ? AND "
				cQry += "SE2.E2_LOJA = ? "
				cQry += "AND SE5.E5_RECPAG = 'P' "
				cQry += "AND SE5.E5_TIPODOC = 'CP' AND SE5.E5_MOTBX = 'CMP' " 
				cQry += "AND SE5.E5_ORIGEM NOT IN ('MATA103 ', 'MATA103') "
				cQry += "AND SE5.E5_KEY = '" + cE5_KEY + "' "
				cQry += "AND SE5.E5_MOVCX = '" + cE5_MOVCX + "' "
				cQry += "AND (SE5.E5_VRETPIS > 0 OR SE5.E5_VRETCOF > 0 OR SE5.E5_VRETCSL > 0 OR SE5.E5_VRETIRF > 0 OR SE5.E5_VRETISS > 0) " 
				cQry += "AND SE5.D_E_L_E_T_ = ' ' "
				//Estorno
				cQry += "AND SE5.E5_SEQ NOT IN (SELECT EST.E5_SEQ FROM " + RetSqlName("SE5") + " EST "
				cQry += "WHERE EST.E5_DOCUMEN = ? "
				cQry += "AND EST.E5_RECPAG = 'R' AND EST.E5_TIPODOC = 'ES' "
				cQry += "AND EST.E5_ORIGEM NOT IN ('MATA103 ', 'MATA103') "
				cQry += "AND EST.E5_KEY = '" + cE5_KEY +"' "
				cQry += "AND EST.E5_MOTBX = 'CMP' "
				cQry += "AND EST.E5_MOVCX = '" + cE5_MOVCX + "' "
				cQry += "AND EST.D_E_L_E_T_ = ' ') "
				
				cQry := ChangeQuery(cQry)
				__oObjNF := FWPreparedStatement():New(cQry)	
			EndIf
			
			__oObjNF:SetString(1, aDoc[nX][1])
			__oObjNF:SetString(2, (cSE2)->E2_FILIAL)
			__oObjNF:SetString(3, (cSE2)->E2_NUM)
			__oObjNF:SetString(4, (cSE2)->E2_PARCELA)
			__oObjNF:SetString(5, (cSE2)->E2_TIPO)
			__oObjNF:SetString(6, (cSE2)->E2_FORNECE)
			__oObjNF:SetString(7, (cSE2)->E2_LOJA)
			__oObjNF:SetString(8, aDoc[nX][1])

			cQry    := __oObjNF:GetFixQuery()
			cTblTmp := MpSysOpenQuery(cQry)
			(cTblTmp)->(DbGoTop())
			
			While (cTblTmp)->(!Eof()) .And. (cTblTmp)->BASEIMP > 0
				nPropoc := ((cTblTmp)->BASEIMP/nVlrNF)
				
				// Aplica proporcionalização de impostos do Adiantamento compensado com a Nota Fiscal
				If nPropoc > 0
					If !lPCCBaixa .And. (cSE2)->(E2_PIS+E2_COFINS+E2_CSLL) > 0 .And. lPccPA
						nImpEm -= Round((nPropoc * (cSE2)->(E2_PIS+E2_COFINS+E2_CSLL)), 2) 
					EndIf
					
					If !lIRPFBaixa .And. (cSE2)->E2_IRRF > 0 .And. lIrfPA
						nImpEm -= Round((nPropoc * (cSE2)->E2_IRRF), 2)
					EndIf
					
					If !lCalcIssBx .And. lIssPa
						If (cSE2)->E2_ISS > 0
							nImpEm -= Round((nPropoc * (cSE2)->E2_ISS), 2)
						EndIf
						If lBtrISS .And. (cSE2)->E2_BTRISS > 0
							nImpEm -= Round((nPropoc * (cSE2)->E2_BTRISS), 2)
						EndIf
					EndIf

					If lInsPA
						nImpEm -= Round((nPropoc * (cSE2)->E2_INSS), 2)
					EndIf
				EndIf
				
				(cTblTmp)->(DbSkip())
			EndDo
		
			(cTblTmp)->(DbCloseArea())

		Next nX
		
		RestArea(aSE2)
		FwFreeArray(aSE2)
	EndIf

Return nImpEm


//-------------------------------------------------------------------
/*/{Protheus.doc}retBxTit
Verificar saldo do título pendente a ser baixado, considerando
impostos na emissão e baixa e sistema configurado como líquido e bruto.

@param cCart - Carteira P = Pagar, R = Receber
@param cPref - Prefixo do Título
@param cNum - Número do Título
@param cParc - Parcela do Título
@param cTipo - Tipo do Título
@param cCliFor - Cliente/Fornecedor do Título
@param cLoja - Loja do Cliente/Fornecedor
@param cMoeda - Moeda
@param cImp - Ex. IRF, PIS, COF, CSL, ISS, INSS, Caso não informa nada ele
@param dRef - Data de Referencia
@param nMoedaBco - Moeda do banco

@return aDadosBx - Com os dados Retidos
aDadosBx[1]  - Valor total líquido
aDadosBx[2]  - Valor total (E5_BASEIRF)
aDadosBx[3]  - Valor total retido (IRF)
aDadosBx[4]  - Valor total retido (PIS)
aDadosBx[5]  - Valor total retido (COF)
aDadosBx[6]  - Valor total retido (CSL)
aDadosBx[7]  - Valor total retido (INS)
aDadosBx[8]  - Valor total retido (ISS)
aDadosBx[9]  - Valor total juros
aDadosBx[10] - Valor total multa
aDadosBx[11] - Valor total desconto

@author Caique Ferreira
@since  01/07/2015
/*/
//-------------------------------------------------------------------
Function retBxTit(cCart,cPref,cNum,cParc,cTipo,cCliFor,cLoja,cMoeda,cImp,dRef,nMoedaBco)
	Local aArea := GetArea()
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""
	Local aDadosBx  := Array(11)

	Local nVlrTot		:= 0
	Local nBaseIrf	:= 0
	Local nIrf			:= 0
	Local nCsl			:= 0
	Local nPis			:= 0
	Local nCof			:= 0
	Local nIns			:= 0
	Local nIss			:= 0
	Local lInssBx		:= IIF(cCart == "P",SuperGetMv("MV_INSBXCP",.F.,"2") == "1",.F.)
	Local lFina340		:= FwIsinCallStack("Fa340comp")
	Local lCalcIssBx	:= IIF(cCart == "P",	IIF(lIsIssBx, IsIssBx("P"),SuperGetMV("MV_MRETISS",.T.,"1") == "2"),.F.)
	Local lLiquido		:= IIF(cCart == "P", SuperGetMv("MV_BP10925",.F., "1") == "2", SuperGetMv("MV_BQ10925",.F., "1") == "2" ) // Default (Bruto)
	Local lBorde		:= FwIsInCallStack("Fa061Borde") .Or. FwIsInCallStack("F241Impost")
	Local nVlrJur		:= 0
	Local nVlrMult		:= 0
	Local nVlrDesc		:= 0

	DEFAULT cCart	  	:= ""
	DEFAULT cPref   	:= ""
	DEFAULT cNum    	:= ""
	DEFAULT cParc   	:= ""
	DEFAULT cTipo   	:= ""
	DEFAULT cCliFor 	:= ""
	DEFAULT cLoja   	:= ""
	DEFAULT cMoeda  	:= "01"
	DEFAULT cImp	  	:= "IRF"
	DEFAULT dRef	  	:= CtoD("//")
	DEFAULT nMoedaBco	:= 1

	If cCart == "R" .OR. (SE2->E2_MOEDA == 1 .and. cCart = "P") 

		Afill(aDadosBx, 0)
		lRef := !Empty(dRef)

		cQuery += " SELECT SE5.E5_FILIAL,SE5.E5_PREFIXO,SE5.E5_NUMERO,SE5.E5_PARCELA, "
		cQuery += "   SE5.E5_TIPO,SE5.E5_CLIFOR,SE5.E5_LOJA, SUM(SE5.E5_VALOR) VLRTOT,"
		cQuery += " 	SUM(SE5.E5_BASEIRF) BASEIRF, SUM(SE5.E5_VLJUROS) VLRJUR, "
		cQuery += " 	SUM(SE5.E5_VLMULTA) VLRMULT, SUM(SE5.E5_VLDESCO) VLRDESC "

		If cImp == "IRF" .Or. lRef
			cQuery += "   ,SUM(SE5.E5_VRETIRF) VRETIRF "
		EndIf
		If cImp == "PIS" .Or. lRef
			cQuery += " 	,SUM(SE5.E5_VRETPIS) VRETPIS "
		EndIf
		If cImp == "COF" .Or. lRef
			cQuery += " 	,SUM(SE5.E5_VRETCOF) VRETCOF "
		EndIf
		If cImp == "CSL" .Or. lRef
			cQuery += " 	,SUM(SE5.E5_VRETCSL) VRETCSL "
		EndIf
		If (cImp == "INS" .Or. lRef) .And. lInssBx
			cQuery += " 	,SUM(SE5.E5_VRETINS) VRETINS "
		EndIf
		If cImp == "ISS" .Or. lRef
			cQuery += "   ,SUM(SE5.E5_VRETISS) VRETISS "
		EndIf

		cQuery += " FROM "+RetSQLName("SE5")+" SE5 "
		//Não considera deletados, estornados ou cancelados
		cQuery += " WHERE D_E_L_E_T_ = ' ' "
		cQuery += " 	AND SE5.E5_SITUACA NOT IN ('C', 'E', 'X') "
		cQuery += " 	AND SE5.E5_TIPODOC NOT IN ('ES', 'JR', 'DC') "
		If lFina340 .and. SE2->E2_TIPO == MVPAGANT
			cQuery += " 	AND SE5.E5_TIPODOC <> 'PA' "
		EndIf
		cQuery += " 	AND SE5.E5_RECPAG = '"+cCart+"' "

		//Não considera faturas, liquidações e devoluções
		cQuery += " 	AND SE5.E5_MOTBX NOT IN ('FAT','LIQ','DEV') "

		If lLiquido .And. lBorde .And. (lCalcIssBx .Or. lInssBx ) //Apenas Impostos Retidos no Bordero
			cQuery += " 	AND SE5.E5_MOTBX IN ('IRF','ISS','INS') "
			cQuery += " 	AND SE5.E5_DOCUMEN <> '"+SPACE(TamSx3("E5_DOCUMEN")[1])+"' "
		EndIf

		cQuery += " 	AND SE5.E5_FILIAL = '"+xFilial("SE5")+"' "
		cQuery += " 	AND SE5.E5_PREFIXO = '"+cPref+"' "
		cQuery += " 	AND SE5.E5_NUMERO = '"+cNum+"' "
		cQuery += " 	AND SE5.E5_PARCELA = '"+cParc+"' "
		cQuery += " 	AND SE5.E5_TIPO = '"+cTipo+"'  "
		cQuery += " 	AND SE5.E5_CLIFOR = '"+cCliFor+"' "
		cQuery += " 	AND SE5.E5_LOJA = '"+cLoja+"' "

		If lRef
			cQuery += " 	AND SE5.E5_DATA = '"+DtoS(dRef)+"'"
		EndIf

		cQuery += " 	AND (SE5.E5_MOEDA = '"+cMoeda+"' Or SE5.E5_MOEDA = ' ' ) "

		If cImp == "IRF"
			cQuery += "   AND SE5.E5_PRETIRF <> '1' "
		EndIf
		If cImp == "PIS"
			cQuery += "   AND SE5.E5_PRETPIS <> '1' "
		EndIf
		If cImp == "COF"
			cQuery += "   AND SE5.E5_PRETCOF <> '1' "
		EndIf
		If cImp == "CSL"
			cQuery += "   AND SE5.E5_PRETCSL <> '1' "
		EndIf
		If cImp == "INS" .And. lInssBx
			cQuery += "   AND SE5.E5_PRETINS <> '1' "
		EndIf

		cQuery += "AND NOT EXISTS ( "
		cQuery += "SELECT A.E5_NUMERO "
		cQuery += "FROM "+RetSqlName("SE5")+" A "
		cQuery += "WHERE A.E5_FILIAL IN ('"+xFilial("SE5")+"' "
		cQuery += ") AND "
		cQuery += "A.E5_PREFIXO=SE5.E5_PREFIXO AND "
		cQuery += "A.E5_NUMERO=SE5.E5_NUMERO AND "
		cQuery += "A.E5_PARCELA=SE5.E5_PARCELA AND "
		cQuery += "A.E5_TIPO=SE5.E5_TIPO AND "
		cQuery += "A.E5_CLIFOR=SE5.E5_CLIFOR AND "
		cQuery += "A.E5_LOJA=SE5.E5_LOJA AND "
		cQuery += "A.E5_SEQ=SE5.E5_SEQ AND "
		cQuery += "A.E5_TIPODOC='ES' AND "
		If cCart == "P"
			cQuery += "A.E5_RECPAG<>'P' AND "
		Else
			cQuery += "A.E5_RECPAG<>'R' AND "
		EndIF
		cQuery += "A.D_E_L_E_T_ = ' ')"

		cQuery += " GROUP BY SE5.E5_FILIAL,SE5.E5_PREFIXO,SE5.E5_NUMERO,SE5.E5_PARCELA,SE5.E5_TIPO,SE5.E5_CLIFOR,SE5.E5_LOJA "

		cQuery := ChangeQuery( cQuery )

		If Select(cAliasQry) > 0
			( cAliasQry )->( dbCloseArea() )
		Endif

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

		DbSelectArea(cAliasQry)
		If !Eof()
			TCSetField(cAliasQry, "VLRTOT" ,"N",16,2)
			TCSetField(cAliasQry, "BASEIRF" ,"N",16,2)

			If cImp == "IRF" .Or. lRef
				TCSetField(cAliasQry, "VRETIRF" ,"N",16,2)
			EndIf
			If cImp == "PIS" .Or. lRef
				TCSetField(cAliasQry, "VRETPIS" ,"N",16,2)
			EndIf
			If cImp == "COF" .Or. lRef
				TCSetField(cAliasQry, "VRETCOF" ,"N",16,2)
			EndIf
			If cImp == "CSL" .Or. lRef
				TCSetField(cAliasQry, "VRETCSL" ,"N",16,2)
			EndIf
			If (cImp == "INS" .Or. lRef) .And. lInssBx
				TCSetField(cAliasQry, "VRETINS" ,"N",16,2)
			EndIf
			If cImp == "ISS" .Or. lRef
				TCSetField(cAliasQry, "VRETISS" ,"N",16,2)
			EndIf

			nVlrTot  := (cAliasQry)->(VLRTOT)
			nBaseIrf := (cAliasQry)->(BASEIRF)
			nVlrJur  := (cAliasQry)->(VLRJUR)
			nVlrMult := (cAliasQry)->(VLRMULT)
			nVlrDesc := (cAliasQry)->(VLRDESC)
			If cImp == "IRF" .Or. lRef
				nIrf := (cAliasQry)->(VRETIRF)
			EndIf 
			If cImp == "PIS" .Or. lRef
				nPis := (cAliasQry)->(VRETPIS)
			EndIf
			If cImp == "COF" .Or. lRef
				nCof := (cAliasQry)->(VRETCOF)
			EndIf
			If cImp == "CSL" .Or. lRef
				nCsl := (cAliasQry)->(VRETCSL)
			EndIf
			If (cImp == "INS" .Or. lRef)  .And. lInssBx
				nIns := (cAliasQry)->(VRETINS)
			EndIf
			If cImp == "ISS" .Or. lRef
				nIss := (cAliasQry)->(VRETISS)
			EndIF
		Endif
		(cAliasQry)->(dbCloseArea())

		aDadosBx[1]  := nVlrTot
		aDadosBx[2]  := nBaseIrf
		aDadosBx[3]  := nIrf
		aDadosBx[4]  := nPis
		aDadosBx[5]  := nCof
		aDadosBx[6]  := nCsl
		aDadosBx[7]  := nIns
		aDadosBx[8]  := nIss
		aDadosBx[9]  := nVlrJur
		aDadosBx[10] := nVlrMult
		aDadosBx[11] := nVlrDesc

		RestArea(aArea)
	else
		//Função criada para títulos em moeda estrangeira e retenção de impostos, para compor valores considerando a 
		// taxa da moeda informada na baixa do título.
		aDadosBx:= RtBxTit2(cPref,cNum,cParc,cTipo,cCliFor,cLoja,cMoeda,cImp,dRef, nMoedaBco)
	EndIf
Return(aDadosBx)


//-------------------------------------------------------------------
/*/{Protheus.doc}RtBxTit2
Verificar saldo do título pendente a ser baixado, considerando
impostos na emissão e baixa e sistema configurado como líquido e bruto para títulos em moeda estrangeira.


@param cPref - Prefixo do Título
@param cNum - Número do Título
@param cParc - Parcela do Título
@param cTipo - Tipo do Título
@param cCliFor - Cliente/Fornecedor do Título
@param cLoja - Loja do Cliente/Fornecedor
@param cMoeda - Moeda
@param cImp - Ex. IRF, PIS, COF, CSL, ISS, INSS, Caso não informa nada ele
@param dRef - Data de Referencia
@param nMoedaBco - Moeda do banco

@return aDadosBx - Com os dados Retidos
aDadosBx[1]  - Valor total líquido
aDadosBx[2]  - Valor total (E5_BASEIRF)
aDadosBx[3]  - Valor total retido (IRF)
aDadosBx[4]  - Valor total retido (PIS)
aDadosBx[5]  - Valor total retido (COF)
aDadosBx[6]  - Valor total retido (CSL)
aDadosBx[7]  - Valor total retido (INS)
aDadosBx[8]  - Valor total retido (ISS)
aDadosBx[9]  - Valor total juros
aDadosBx[10] - Valor total multa
aDadosBx[11] - Valor total desconto

@author Pâmela Bernardo
@since  08/05/2020
/*/
//-------------------------------------------------------------------
Static Function RtBxTit2(cPref As Character,cNum As Character,cParc As Character,cTipo As Character,cCliFor As Character,cLoja As Character,cMoeda As Character,;
						cImp As Character,dRef As Date, nMoedaBco As Numeric) As Array
	Local aArea 		As Array
	Local cAliasQry 	As Character
	Local cQuery    	As Character
	Local aDadosBx  	As Array
	Local nVlrTot		As Numeric
	Local nBaseIrf		As Numeric
	Local nIrf			As Numeric
	Local nCsl			As Numeric
	Local nPis			As Numeric
	Local nCof			As Numeric
	Local nIns			As Numeric
	Local nIss			As Numeric
	Local lInssBx		As Logical
	Local lFina340		As Logical
	Local lCalcIssBx 	As Logical
	Local lLiquido		As Logical
	Local lBorde		As Logical
	Local nVlrJur		As Numeric
	Local nVlrMult		As Numeric
	Local nVlrDesc		As Numeric
	Local nTxTitInc		As Numeric
	Local nCentMd1  	As Numeric

	DEFAULT cPref   	:= ""
	DEFAULT cNum    	:= ""
	DEFAULT cParc   	:= ""
	DEFAULT cTipo   	:= ""
	DEFAULT cCliFor 	:= ""
	DEFAULT cLoja   	:= ""
	DEFAULT cMoeda  	:= "01"
	DEFAULT cImp	  	:= "IRF"
	DEFAULT dRef	  	:= CtoD("//")
	DEFAULT nMoedaBco	:= 1


	aArea 		:= GetArea()
	cAliasQry 	:= GetNextAlias()
	cQuery    	:= ""
	aDadosBx  	:= Array(11)
	nVlrTot		:= 0
	nBaseIrf	:= 0
	nIrf		:= 0
	nCsl		:= 0
	nPis		:= 0
	nCof		:= 0
	nIns		:= 0
	nIss		:= 0
	lInssBx		:= SuperGetMv("MV_INSBXCP",.F.,"2") == "1"
	lFina340	:= FwIsinCallStack("Fa340comp")
	lCalcIssBx	:= IIF(lIsIssBx, IsIssBx("P"),SuperGetMV("MV_MRETISS",.T.,"1") == "2")
	lLiquido	:= SuperGetMv("MV_BP10925",.F., "1") == "2"
	lBorde		:= FwIsInCallStack("F241Impost")
	nVlrJur		:= 0
	nVlrMult	:= 0
	nVlrDesc	:= 0
	nTxTitInc	:= 0
	nCentMd1   := MsDecimais(1)
	

	If SE2->E2_TXMOEDA == 0
		nTxTitInc := RecMoeda(SE2->E2_EMISSAO,SE2->E2_MOEDA)
	else
		nTxTitInc := SE2->E2_TXMOEDA
	EndIf
	Afill(aDadosBx, 0)
	lRef := !Empty(dRef)

	cQuery += " SELECT SE5.E5_FILIAL,SE5.E5_PREFIXO,SE5.E5_NUMERO,SE5.E5_PARCELA, "
	cQuery += "   SE5.E5_TIPO,SE5.E5_CLIFOR,SE5.E5_LOJA, "
	cQuery += "   SE5.E5_MOEDA, SE5.E5_TXMOEDA, SE5.E5_VALOR, SE5.E5_BASEIRF, "
	cQuery += "   SE5.E5_VLJUROS, SE5.E5_VLMULTA, SE5.E5_VLDESCO, "
	cQuery += "   SE5.E5_VRETPIS, SE5.E5_VRETCOF, SE5.E5_VRETCSL, "
	cQuery += "   SE5.E5_VRETIRF, SE5.E5_VRETISS, SE5.E5_VRETINS "

	cQuery += " FROM "+RetSQLName("SE5")+" SE5 "
	//Não considera deletados, estornados ou cancelados
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " 	AND SE5.E5_SITUACA NOT IN ('C', 'E', 'X') "
	cQuery += " 	AND SE5.E5_TIPODOC NOT IN ('ES', 'JR', 'DC') "
	If lFina340 .and. SE2->E2_TIPO == MVPAGANT
		cQuery += " 	AND SE5.E5_TIPODOC <> 'PA' "
	EndIf
	cQuery += " 	AND SE5.E5_RECPAG = 'P' "

	//Não considera faturas, liquidações e devoluções
	cQuery += " 	AND SE5.E5_MOTBX NOT IN ('FAT','LIQ','DEV') "

	If lLiquido .And. lBorde .And. (lCalcIssBx .Or. lInssBx ) //Apenas Impostos Retidos no Bordero
		cQuery += " 	AND SE5.E5_MOTBX IN ('IRF','ISS','INS') "
		cQuery += " 	AND SE5.E5_DOCUMEN <> '"+SPACE(TamSx3("E5_DOCUMEN")[1])+"' "
	EndIf

	cQuery += " 	AND SE5.E5_FILIAL = '"+xFilial("SE5")+"' "
	cQuery += " 	AND SE5.E5_PREFIXO = '"+cPref+"' "
	cQuery += " 	AND SE5.E5_NUMERO = '"+cNum+"' "
	cQuery += " 	AND SE5.E5_PARCELA = '"+cParc+"' "
	cQuery += " 	AND SE5.E5_TIPO = '"+cTipo+"'  "
	cQuery += " 	AND SE5.E5_CLIFOR = '"+cCliFor+"' "
	cQuery += " 	AND SE5.E5_LOJA = '"+cLoja+"' "
	cQuery += " 	AND SE5.E5_TIPODOC <> 'CM' "

	If lRef
		cQuery += " 	AND SE5.E5_DATA = '"+DtoS(dRef)+"'"
	EndIf

	cQuery += " 	AND (SE5.E5_MOEDA = '"+cMoeda+"' Or SE5.E5_MOEDA = ' ' ) "

	If cImp == "IRF"
		cQuery += "   AND SE5.E5_PRETIRF <> '1' "
	EndIf
	If cImp == "PIS"
		cQuery += "   AND SE5.E5_PRETPIS <> '1' "
	EndIf
	If cImp == "COF"
		cQuery += "   AND SE5.E5_PRETCOF <> '1' "
	EndIf
	If cImp == "CSL"
		cQuery += "   AND SE5.E5_PRETCSL <> '1' "
	EndIf
	If cImp == "INS" .And. lInssBx
		cQuery += "   AND SE5.E5_PRETINS <> '1' "
	EndIf

	cQuery += "AND NOT EXISTS ( "
	cQuery += "SELECT A.E5_NUMERO "
	cQuery += "FROM "+RetSqlName("SE5")+" A "
	cQuery += "WHERE A.E5_FILIAL IN ('"+xFilial("SE5")+"' "
	cQuery += ") AND "
	cQuery += "A.E5_PREFIXO=SE5.E5_PREFIXO AND "
	cQuery += "A.E5_NUMERO=SE5.E5_NUMERO AND "
	cQuery += "A.E5_PARCELA=SE5.E5_PARCELA AND "
	cQuery += "A.E5_TIPO=SE5.E5_TIPO AND "
	cQuery += "A.E5_CLIFOR=SE5.E5_CLIFOR AND "
	cQuery += "A.E5_LOJA=SE5.E5_LOJA AND "
	cQuery += "A.E5_SEQ=SE5.E5_SEQ AND "
	cQuery += "A.E5_TIPODOC='ES' AND "
	cQuery += "A.E5_RECPAG<>'P' AND "
	cQuery += "A.D_E_L_E_T_ = ' ')"

	cQuery := ChangeQuery( cQuery )

	If Select(cAliasQry) > 0
		( cAliasQry )->( dbCloseArea() )
	Endif

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

	DbSelectArea(cAliasQry)

	While (cAliasQry)->(!Eof())
		//todos os valores serão armazenados na moeda do título
		nVlrTot  += xMoeda((cAliasQry)->(E5_VALOR),nMoedaBco,SE2->E2_MOEDA,SE2->E2_EMISSAO,3,,(cAliasQry)->E5_TXMOEDA)
		nBaseIrf += xMoeda((cAliasQry)->(E5_BASEIRF),nMoedaBco,SE2->E2_MOEDA,SE2->E2_EMISSAO,3,,(cAliasQry)->E5_TXMOEDA)
		nVlrJur  += xMoeda((cAliasQry)->(E5_VLJUROS),nMoedaBco,SE2->E2_MOEDA,SE2->E2_EMISSAO,3,,(cAliasQry)->E5_TXMOEDA)
		nVlrMult += xMoeda((cAliasQry)->(E5_VLMULTA),nMoedaBco,SE2->E2_MOEDA,SE2->E2_EMISSAO,3,,(cAliasQry)->E5_TXMOEDA)
		nVlrDesc += xMoeda((cAliasQry)->(E5_VLDESCO),nMoedaBco,SE2->E2_MOEDA,SE2->E2_EMISSAO,3,,(cAliasQry)->E5_TXMOEDA)
		
		If cImp == "IRF" .Or. lRef
			nIrf += xMoeda((cAliasQry)->(E5_VRETIRF),nMoedaBco,SE2->E2_MOEDA,SE2->E2_EMISSAO,3,,(cAliasQry)->E5_TXMOEDA)
		EndIf 
		If cImp == "PIS" .Or. lRef
			nPis += xMoeda((cAliasQry)->(E5_VRETPIS),nMoedaBco,SE2->E2_MOEDA,SE2->E2_EMISSAO,3,,(cAliasQry)->E5_TXMOEDA)
		EndIf
		If cImp == "COF" .Or. lRef
			nCof += xMoeda((cAliasQry)->(E5_VRETCOF),nMoedaBco,SE2->E2_MOEDA,SE2->E2_EMISSAO,3,,(cAliasQry)->E5_TXMOEDA)
		EndIf
		If cImp == "CSL" .Or. lRef
			nCsl += xMoeda((cAliasQry)->(E5_VRETCSL),nMoedaBco,SE2->E2_MOEDA,SE2->E2_EMISSAO,3,,(cAliasQry)->E5_TXMOEDA)
		EndIf
		If (cImp == "INS" .Or. lRef)  .And. lInssBx
			nIns += xMoeda((cAliasQry)->(E5_VRETINS),nMoedaBco,SE2->E2_MOEDA,SE2->E2_EMISSAO,3,,(cAliasQry)->E5_TXMOEDA)
		EndIf
		If cImp == "ISS" .Or. lRef
			nIss += xMoeda((cAliasQry)->(E5_VRETISS),nMoedaBco,SE2->E2_MOEDA,SE2->E2_EMISSAO,3,,(cAliasQry)->E5_TXMOEDA)
		EndIF
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	//converte valores para reais com a taxa de inclusão do título

	aDadosBx[1]  := Round(xMoeda(nVlrTot,SE2->E2_MOEDA,nMoedaBco, SE2->E2_EMISSAO,3,nTxTitInc), nCentMd1)
	aDadosBx[2]  := Round(xMoeda(nBaseIrf,SE2->E2_MOEDA,nMoedaBco, SE2->E2_EMISSAO,3,nTxTitInc), nCentMd1)
	aDadosBx[3]  := Round(xMoeda(nIrf,SE2->E2_MOEDA,nMoedaBco, SE2->E2_EMISSAO,3,nTxTitInc), nCentMd1)
	aDadosBx[4]  := Round(xMoeda(nPis,SE2->E2_MOEDA,nMoedaBco, SE2->E2_EMISSAO,3,nTxTitInc), nCentMd1)
	aDadosBx[5]  := Round(xMoeda(nCof,SE2->E2_MOEDA,nMoedaBco, SE2->E2_EMISSAO,3,nTxTitInc), nCentMd1)
	aDadosBx[6]  := Round(xMoeda(nCsl,SE2->E2_MOEDA,nMoedaBco, SE2->E2_EMISSAO,3,nTxTitInc), nCentMd1)
	aDadosBx[7]  := Round(xMoeda(nIns,SE2->E2_MOEDA,nMoedaBco, SE2->E2_EMISSAO,3,nTxTitInc), nCentMd1)
	aDadosBx[8]  := Round(xMoeda(nIss,SE2->E2_MOEDA,nMoedaBco, SE2->E2_EMISSAO,3,nTxTitInc), nCentMd1)
	aDadosBx[9]  := Round(xMoeda(nVlrJur,SE2->E2_MOEDA,nMoedaBco, SE2->E2_EMISSAO,3,nTxTitInc), nCentMd1)
	aDadosBx[10] := Round(xMoeda(nVlrMult,SE2->E2_MOEDA,nMoedaBco, SE2->E2_EMISSAO,3,nTxTitInc), nCentMd1)
	aDadosBx[11] := Round(xMoeda(nVlrDesc,SE2->E2_MOEDA,nMoedaBco, SE2->E2_EMISSAO,3,nTxTitInc), nCentMd1)
	
	RestArea(aArea)
	
Return(aDadosBx)

//-------------------------------------------------------------------
/*/{Protheus.doc}SumDay
Verificar total baixado diário do PCC(Pis, Cofins, Csll) de acordo com a Lei 13.137

@param cCart, characters, Carteira ("P" = Pagar, "R" = Receber)
@param cFil, characters, Filial
@param cCodigo, characters, Código do Cliente/Fornecedor
@param cLoja, characters, Loja do Cliente/Fornecedor
@param cTipo, characters, Tipo do Cliente/Fornecedor
@param dRef, date, Data de Referência

@return aDados - Retorna o total pendente dos impostos baixados no dia.
@sample aDados[1] = Total diário do PIS
		aDados[2] = Total diário do COFINS
		aDados[3] = Total diário do CSLL
		aDados[4] = Indica se valida o valor mínimo (.T. ou .F.)

@author Caique Ferreira
@since 20/07/2015
@type function
/*/
//-------------------------------------------------------------------
Function SumDay(cCart As Character,cFil As Character,cCodigo As Character,cLoja As Character,cTipo As Character,dRef As Date, cFilOrig As Character, aTitCalc As Array) As Array

	Local aArSE2		As Array
	Local aArSE1		As Array
	Local aArSE5		As Array
	Local aArSA1		As Array
	Local aAreaAt		As Array
	Local aArea			As Array
	Local aCliFor 		As Array
	Local aDados		As Array
	Local aFil 			As Array
	Local cAliasQry 	As Array
	Local cChave		As Character
	Local aCodRet		As Array
	Local cDbMs			As Character
	Local cFiliais		As Character
	Local cFilE1		As Character
	Local cOrigem		As Character
	Local cSepNeg   	As Character
	Local cSerNeg		As Character
	Local cSepPag   	As Character
	Local cSepRec		As Character
	Local cSepProv  	As Character
	Local cQuery 		As Character
	Local lConsFil		As Logical
	Local lLojaAtu		As Logical
	Local lPCCBaixa		As Logical
	Local lCalcIssBx	As Logical
	Local lIRPFBaixa	As Logical
	Local lInssBx		As Logical
	Local lLiquido		As Logical
	Local lRecIssCR		As Logical
	Local lRet			As Logical
	Local nKco 			As Numeric
	Local nVret			As Numeric
	Local nPis			As Numeric
	Local nCof			As Numeric
	Local nCsl			As Numeric
	Local nValTit		As Numeric
	Local nVlAcess		As Numeric
	Local nBSEPis		As Numeric
	Local nBSECof		As Numeric
	Local nBSECsl		As Numeric
	Local nBasePis		As Numeric
	Local nBaseCof		As Numeric
	Local nBaseCsl		As Numeric
	Local nSaldo		As Numeric
	Local nImpRetEmi	As Numeric
	Local nTCalcPis		As Numeric
	Local nTCalcCof		As Numeric
	Local nTCalcCsl		As Numeric
	Local nTotRtPis		As Numeric
	Local nTotRtCof		As Numeric
	Local nTotRtCsl		As Numeric
	Local nVencto 		As Numeric
	Local lF241QRY3		As Logical
	Local lFINCMP1 		As Logical
	Local lF241QRY2		As Logical
	Local lF241CMP2 	As Logical
	Local lFINEXEC		As Logical
	Local lFinxOrd 		As Logical
	Local lRaRtImp 	 	As Logical
	Local lBQ10925		As Logical
	Local lFina241		As Logical
	Local lFina080		As Logical
	Local lFina061		As Logical
	Local lFina891		As Logical
	Local lFina330		As Logical
	Local lFatCom		As Logical
	Local lAltEmi    	As Logical
	Local lPenTxR    	As Logical
	Local nPercPIS		As Numeric
	Local nPercCOF		As Numeric
	Local nPercCSL		As Numeric
	Local aPercPcc  	As Array
	Local lJurMulDes 	As Logical
	// Considera baixas que geram ou nao movimento bancario.
	// 1 = Somente os motivos que geram movimento bancario
	// 2 = Considera todos os motivos de baixa.
	Local lMotBxMBco 	As Logical
	Local nAbat			As Numeric
	Local lResta1   	As Logical
	Local lRestaUM		As Logical
	Local nTamPrfTit 	As Numeric
	Local lRoundPis		As Logical
	Local lRoundCof		As Logical
	Local lRoundCsl		As Logical
	Local lCodRetPCC	As Logical
	Local lNRastDSD		As Logical
	Local nBPisCofCsl 	As Numeric
	Local nBxParcial  	As Numeric
	Local cE1Chv      	As Character
	Local nVlRetCtr	  	As Numeric
	Local nPisAux		As Numeric
	Local nCofAux       As Numeric
	Local nCslAux       As Numeric
	Local nTxTitInc		As Numeric
	Local nCentMd1  	As Numeric
	Local cChaveFK7		As Character
	Local cChaveTit		As Character
	Local cFilSA1		As Character
	Local nValRetBd		As Numeric
	Local lTitCalc		As Logical
	Local lAglPcc	    As Logical
	Local lOrig			As Logical
	Local lRpoR33		As Logical

	Default cFilOrig 	:= cFilAnt
	Default aTitCalc	:= {}
	
	If __cVl460Nt == Nil
		__cVl460Nt := SuperGetMv("MV_VL460NT",.F.,"1")
	EndIf

	aArSE2		:= SE2->(getArea())
	aArSE1		:= SE1->(getArea())
	aArSE5		:= SE5->(getArea())
	aArSA1		:= SA1->(getArea())
	aAreaAt		:= getArea()
	aArea		:= GetArea()
	aCliFor 	:= {}
	aDados		:= Array(7)
	aFil 		:= {}
	cAliasQry 	:= GetNextAlias()
	cChave		:= ""
	aCodRet		:= {}
	cDbMs		:= UPPER(TcGetDb())
	cFiliais	:= ""
	cFilE1		:= ""
	cOrigem		:= ""
	cSepNeg   	:= If("|"$MV_CPNEG,"|",",")
	cSerNeg		:= If("|"$MV_CRNEG,"|",",")
	cSepPag   	:= If("|"$MVPAGANT,"|",",")
	cSepRec		:= If("|"$MVRECANT,"|",",")
	cSepProv  	:= If("|"$MVPROVIS,"|",",")
	cQuery 		:= ""
	lConsFil	:= SuperGetMv("MV_CONSFIL",.F.,.F.)
	lLojaAtu	:= ( SuperGetMv( "MV_LJ10925",.F., "1" ) == "1" )
	lPCCBaixa	:= IIF(cCart == "P", SuperGetMv("MV_BX10925",.T.,"2") == "1", SuperGetMv("MV_BR10925",.T.,"2") == "1")
	lCalcIssBx	:= IIF(cCart == "P",	IIF(lIsIssBx, IsIssBx("P"),SuperGetMV("MV_MRETISS",.T.,"1") == "2"),.F.)
	lIRPFBaixa	:= IIF(cCart == "P", SA2->A2_CALCIRF == "2", FIrPjBxCr(.T.) )
	lInssBx		:= IIF(cCart == "P", SuperGetMv("MV_INSBXCP",.F.,"2") == "1",.F.)
	lLiquido	:= IIF(cCart == "P", SuperGetMv("MV_BP10925",.F., "1") == "2", SuperGetMv("MV_BQ10925",.F., "1") == "2" ) // Default (Bruto)
	lRecIssCR	:= .F.
	lRet		:= .F.
	nKco 		:= 0
	nVret		:= 0
	nPis		:= 0
	nCof		:= 0
	nCsl		:= 0
	nValTit		:= 0
	nVlAcess	:= 0
	nBSEPis		:= 0
	nBSECof		:= 0
	nBSECsl		:= 0
	nBasePis	:= 0
	nBaseCof	:= 0
	nBaseCsl	:= 0
	nSaldo		:= 0
	nImpRetEmi	:= 0
	nTCalcPis	:= 0
	nTCalcCof	:= 0
	nTCalcCsl	:= 0
	nTotRtPis	:= 0
	nTotRtCof	:= 0
	nTotRtCsl	:= 0
	nVencto 	:= IIF(cCart=="P",SuperGetMv("MV_VCPCCP",.T.,1) ,SuperGetMv("MV_VCPCCR",.T.,1))
	lF241QRY3	:= ExistBlock("F241QRY3")	//CP FINA241  	
	lFINCMP1 	:= ExistBlock("FINCMP1")	//CP FINA241	
	lF241QRY2	:= ExistBlock("F241QRY2")	//CP FINA241
	lF241CMP2 	:= ExistBlock("f241cmp2")	//CP FINA241/FINA080
	lFINEXEC	:= ExistBlock("FINEXEC")	//CR EMISSAO
	lFinxOrd 	:= ExistBlock("FINXORD")	//CP FINA241
	lRaRtImp 	:= FRaRtImp()
	lBQ10925	:= SuperGetMV("MV_BQ10925",,"2") == "1" .And. !lRaRtImp
	lFina241	:= FwIsInCallStack("F241Impost")
	lFina080	:= FwIsInCallStack("Fa080tit")
	lFina061	:= FwIsInCallStack("Fa061Borde")
	lFina891	:= FwIsInCallStack("PIXGerImp")
	lFina330	:= FwIsInCallStack("fA330Comp")
	lFatCom     := FwIsInCallStack("MAPVLNFS") .OR. FwIsInCallStack("A103ATUSE2")// COLOCAR FAT POR PEDIDO MATA410....
	lAltEmi    	:= FwIsInCallStack("FA040Alter") .or. FwIsInCallStack("FA050Alter")
	lPenTxR    	:= .F.
	nPercPIS	:= 0
	nPercCOF	:= 0
	nPercCSL	:= 0
	aPercPcc  	:= Array(3)
	lJurMulDes 	:= (SuperGetMv("MV_IMPBAIX",.t.,"2") == "1")
	// Considera baixas que geram ou nao movimento bancario.
	// 1 = Somente os motivos que geram movimento bancario
	// 2 = Considera todos os motivos de baixa.
	lMotBxMBco 	:= (SuperGetMv("MV_MB10925",.t.,"2") == "1")
	nAbat		:= 0
	lResta1   	:= ExistBlock("RESTAUM")
	lRestaUM	:= .T.
	nTamPrfTit 	:= LenCmpTitP( cCart , lPCCBaixa )
	lRoundPis	:= SuperGetMV("MV_RNDPIS",,.F.)
	lRoundCof	:= SuperGetMV("MV_RNDCOF",,.F.)
	lRoundCsl	:= SuperGetMV("MV_RNDCSL",,.F.)
	lCodRetPCC	:= !lPCCBaixa
	lNRastDSD	:= SuperGetMV("MV_NRASDSD",.T.,.F.)
	nBPisCofCsl := 0
	nBxParcial  := 0
	cE1Chv      := ""
	nVlRetCtr	:= 0
	aCliFor     := getCliFor(cCart, IIF(cCart=="P",SA2->A2_FILIAL,SA1->A1_FILIAL), cCodigo, cLoja, @aFil )
	nTxTitInc	:= 0
	nCentMd1    := MsDecimais(1)
	cChaveFK7   := ""
	cChaveTit 	:= ""
	nValRetBd	:= 0
	lTitCalc	:= .F.	//Verifica se o título foi incluido no array aTitCalc (pendentes de retenção)
	lAglPcc		:= (SuperGetMv("MV_AG10925",.T.,"2") == "1")
	lOrig		:= .F.

	If SE2->E2_TXMOEDA == 0
		nTxTitInc := RecMoeda(SE2->E2_EMISSAO,SE2->E2_MOEDA)
	else
		nTxTitInc := SE2->E2_TXMOEDA
	EndIf

	cChave := IIF(!lPCCBaixa,cTipo,"")+cCodigo+IIF(lLojaAtu,cLoja, "")

	//Verifico se já foi gerado o título de impostos para o cliente/fornecedor da filial corrente.
	If cCart == "P"
		aCodRet := getCodRet()
		nPis := getValorTx(cFil,cChave,MVTAXA,"PIS",aCodRet[1],dRef,cCart,nTamPrfTit,aFil)
		nCof := getValorTx(cFil,cChave,MVTAXA,"COF",aCodRet[2],dRef,cCart,nTamPrfTit,aFil)
		nCsl := getValorTx(cFil,cChave,MVTAXA,"CSL",aCodRet[3],dRef,cCart,nTamPrfTit,aFil)

		nPis += getValorTx(cFil,cChave,MVTXA ,"PIS",aCodRet[1],dRef,cCart,nTamPrfTit,aFil)
		nCof += getValorTx(cFil,cChave,MVTXA ,"COF",aCodRet[2],dRef,cCart,nTamPrfTit,aFil)
		nCsl += getValorTx(cFil,cChave,MVTXA ,"CSL",aCodRet[3],dRef,cCart,nTamPrfTit,aFil)
	Else
		nPis := getValorTx(cFil,cChave,"PIS"	,"PIS","",dRef,cCart,nTamPrfTit)
		nCof := getValorTx(cFil,cChave,"COF"	,"COF","",dRef,cCart,nTamPrfTit)
		nCsl := getValorTx(cFil,cChave,"CSL"	,"CSL","",dRef,cCart,nTamPrfTit)

		nPis += getValorTx(cFil,cChave,MVPIABT ,"PIS","",dRef,cCart,nTamPrfTit)
		nCof += getValorTx(cFil,cChave,MVCFABT ,"COF","",dRef,cCart,nTamPrfTit)
		nCsl += getValorTx(cFil,cChave,MVCSABT ,"CSL","",dRef,cCart,nTamPrfTit)
	EndIF	

	If ExistBlock("RESTAUM")
		lRestaUM := ExecBlock("RestaUM",.F.,.F.)
	Endif

	If lRestaUM
		lPenTxR := isPenTxR(cCart,dRef,cFilOrig)
	EndIF

	If lAltEmi .Or. !lPenTxR
		nPis := nCof := nCsl := 0
	Endif

	//Se sim, não aplico o cumulatividade, vejo apenas o saldo restante do título.
	If (nPis > 0 .AND. nCof > 0 .AND. nCsl > 0) .or. (lAglPcc .and. nPis > 0)
		aDados[1] := 0
		aDados[2] := 0
		aDados[3] := 0
		aDados[4] := .F.
		aDados[5] := 0
		aDados[6] := 0
		aDados[7] := 0		
		Return(aDados)
	EndIf

	//aFil - Contém as filiais que serão utilizadas com base para realizar o cálculo de mínimo.
	For nKco := 1 to Len(aFil)
		cFiliais += "'"+xFilial("SE5", aFil[nKco])+"'"
		cFilE1   += "'"+xFilial("SE1", aFil[nKco])+"'"
		If nKco < Len(aFil)
			cFiliais += ","
			cFilE1   += ","
		EndIf
	Next nKco

	//Neste caso específico, devido aos pontos de entrada existentes e que influenciam nas queries
	//A liberação da SumDayFK para a 12.1.33 será realizada de forma diferente
	lRpoR33 := FVerRpoR33(lF241QRY3, lFINCMP1, lF241QRY2, lF241CMP2, lFinxOrd)
	
	If lRpoR33 .AND. lPccBaixa 
		aDados := SumDayFK (cCart ,cFil ,cCodigo ,cLoja ,cTipo ,dRef , cFilOrig , aTitCalc, aFil, lPenTxR, lAltEmi, aCliFor )
	Else
		//----------------------------------------------------------------------------
		//Tratamento para PCC na Baixa - Contas a Pagar e Contas a Receber
		//----------------------------------------------------------------------------
		If lPCCBaixa
			cQuery := "	SELECT E5_FILIAL,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_TIPO,E5_CLIFOR,E5_LOJA,"
			cQuery += " E5_SEQ,E5_VALOR,E5_VRETPIS,E5_VRETCOF,E5_VRETCSL,E5_DATA,E5_VLJUROS,"
			cQuery += " E5_VLMULTA,E5_VLDESCO,E5_PRETPIS,E5_PRETCOF,E5_PRETCSL,E5_MOTBX,"
			cQuery += " E5_DOCUMEN,E5_FORNADT,E5_LOJAADT,E5_RECPAG,E5_FILORIG,E5_VLMULTA,  "
			cQuery += " E5_TABORI, E5_IDORIG,  "
			If cCart == "P"
				cQuery += " SE2.E2_FILIAL, SE2.E2_SALDO, SE2.E2_VALOR, SE2.E2_BASEPIS, SE2.E2_BASECOF, SE2.E2_BASECSL, SE2.E2_INSS, SE2.E2_IRRF, "
				cQuery += " SE2.E2_ISS, SE2.E2_NUMBOR, SE2.E2_FATURA, SE2.E2_NUMLIQ,SE2.E2_ORIGEM,SE2.E2_NATUREZ,SE2.E2_RETCNTR , SE2.R_E_C_N_O_ RECNOSE2, "
			Else
				cQuery += " SE1.E1_FILIAL, SE1.E1_SALDO, SE1.E1_VALOR, SE1.E1_BASEPIS, SE1.E1_BASECOF, SE1.E1_BASECSL, SE1.E1_INSS, SE1.E1_IRRF, "
				cQuery += " SE1.E1_ISS, SE1.E1_FATURA, SE1.E1_NUMLIQ,SE1.E1_ORIGEM,SE1.E1_NATUREZ, SE1.R_E_C_N_O_ RECNOSE1,  "
			EndIf

			cQuery += " SED.ED_CALCPIS , SED.ED_PERCPIS, SED.ED_CALCCOF , SED.ED_PERCCOF, SED.ED_CALCCSL , SED.ED_PERCCSL, "
			If lInssBx
				cQuery += " E5_PRETINS, E5_VRETINS, "
			EndIf
			
			cQuery += " E5_VRETISS, E5_PRETIRF, E5_VRETIRF, E5_BASEIRF, "

			If cCart == "P" .And. lFina241 .And. lFINCMP1
				cQuery	+=  ExecBlock("FINCMP1",.F.,.F.,{cQuery}) + " ,"
			Endif
			cQuery += " ( SELECT COUNT(*) ATG "
			cQuery += 		" FROM " + RetSqlName( "SE5" ) + " ANTERIOR "
			cQuery += 		" WHERE ANTERIOR.D_E_L_E_T_ = ' ' "
			cQuery += 			" AND ANTERIOR.E5_SITUACA NOT IN ( 'C' , 'E' , 'X' ) "
			cQuery += 			" AND ANTERIOR.E5_TIPODOC <> 'ES' "
			cQuery += 			" AND ANTERIOR.E5_DATA < SE5.E5_DATA "

			If cCart == "P"
				cQuery += 		" AND ANTERIOR.E5_DATA >= SE2.E2_EMISSAO "
			Else
				cQuery += 		" AND ANTERIOR.E5_DATA >= SE1.E1_EMISSAO "
			EndIf

			cQuery += 			" AND ANTERIOR.E5_FILIAL = SE5.E5_FILIAL "
			cQuery += 			" AND ANTERIOR.E5_PREFIXO = SE5.E5_PREFIXO "
			cQuery += 			" AND ANTERIOR.E5_NUMERO = SE5.E5_NUMERO "
			cQuery += 			" AND ANTERIOR.E5_PARCELA = SE5.E5_PARCELA "
			cQuery += 			" AND ANTERIOR.E5_TIPO = SE5.E5_TIPO "
			cQuery += 			" AND ANTERIOR.E5_CLIFOR = SE5.E5_CLIFOR "
			cQuery += 			" AND ANTERIOR.E5_LOJA = SE5.E5_LOJA "
			cQuery += 			" AND ANTERIOR.E5_RECPAG = SE5.E5_RECPAG "
			cQuery += 			" AND ANTERIOR.E5_SEQ < SE5.E5_SEQ "
			cQuery += 			" AND ANTERIOR.E5_TIPO NOT IN " + FormatIn(MVABATIM,"|")
			cQuery += 			" AND ANTERIOR.E5_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv)
			If cCart == "P"
				cQuery += 		" AND ANTERIOR.E5_TIPO NOT IN " + FormatIn(MV_CPNEG,cSepNeg)
				cQuery += 		" AND ANTERIOR.E5_RECPAG = 'P' "
			Else
				cQuery += 		" AND ANTERIOR.E5_TIPO NOT IN " + FormatIn(MV_CRNEG,cSerNeg)
				cQuery += 		" AND ANTERIOR.E5_RECPAG = 'R' "
			EndIF

			cQuery += 			" AND (ANTERIOR.E5_MOTBX NOT IN ('FAT','IRF','PCC','LIQ','STP','DSD','ISS','INS','IMR') "
			If cCart == "P"
				cQuery += 			" OR (ANTERIOR.E5_MOTBX='PCC' AND  ANTERIOR.E5_TIPO IN " + FormatIn(MVPAGANT,cSepPag) + " ) ) AND "
			Else
				cQuery += 			" OR (ANTERIOR.E5_MOTBX='PCC' AND  ANTERIOR.E5_TIPO IN " + FormatIn(MVRECANT,cSepRec) + " ) ) AND "
			EndIf
			cQuery += 			" NOT EXISTS ( "
			cQuery += 						" SELECT A.E5_NUMERO "
			cQuery += 						" FROM "+RetSqlName("SE5")+" A "
			cQuery +=						" WHERE A.E5_FILIAL = ANTERIOR.E5_FILIAL  AND"
			cQuery +=								" A.E5_PREFIXO	=	ANTERIOR.E5_PREFIXO AND "
			cQuery +=								" A.E5_NUMERO	=	ANTERIOR.E5_NUMERO AND "
			cQuery +=								" A.E5_PARCELA	=	ANTERIOR.E5_PARCELA AND "
			cQuery +=								" A.E5_TIPO		=	ANTERIOR.E5_TIPO AND "
			cQuery +=								" A.E5_CLIFOR	=	ANTERIOR.E5_CLIFOR AND "
			cQuery +=								" A.E5_LOJA		=	ANTERIOR.E5_LOJA AND "
			cQuery +=								" A.E5_SEQ		=	ANTERIOR.E5_SEQ AND "
			cQuery +=								" A.E5_TIPODOC='ES' AND "
			If cCart == "P"
				cQuery += 							" A.E5_RECPAG<>'P' AND "
			Else
				cQuery +=							" A.E5_RECPAG<>'R' AND "
			EndIf
			cQuery +=								" A.D_E_L_E_T_ = ' ')"

			cQuery += 		" ) ATG, "

			cQuery += 		" ( SELECT COUNT(*) LIQFAT "
			cQuery += 		  " FROM " + RetSqlName( "SE5" ) + " LIQFAT "
			cQuery += 		  " WHERE LIQFAT.D_E_L_E_T_ = ' ' "
			cQuery += 		  " AND LIQFAT.E5_SITUACA NOT IN ( 'C' , 'E' , 'X' ) "
			cQuery += 		  "	AND LIQFAT.E5_TIPODOC <> 'ES' "

			If cCart == "P"
				cQuery += 	  "	AND LIQFAT.E5_DATA >= SE2.E2_EMISSAO "
			Else
				cQuery += 	  "	AND LIQFAT.E5_DATA >= SE1.E1_EMISSAO "
			EndIf

			cQuery += 		  "	AND LIQFAT.E5_FILIAL = SE5.E5_FILIAL "
			cQuery += 		  "	AND LIQFAT.E5_PREFIXO = SE5.E5_PREFIXO "
			cQuery += 		  "	AND LIQFAT.E5_NUMERO = SE5.E5_NUMERO "
			cQuery += 		  "	AND LIQFAT.E5_PARCELA = SE5.E5_PARCELA "
			cQuery += 		  "	AND LIQFAT.E5_TIPO = SE5.E5_TIPO "
			cQuery += 		  "	AND LIQFAT.E5_CLIFOR = SE5.E5_CLIFOR "
			cQuery += 		  "	AND LIQFAT.E5_LOJA = SE5.E5_LOJA "
			cQuery += 		  "	AND LIQFAT.E5_RECPAG = SE5.E5_RECPAG "

			cQuery += 		  " AND	LIQFAT.E5_TIPO NOT IN " + FormatIn(MVABATIM,"|")
			cQuery += 		  " AND	LIQFAT.E5_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv)
			If cCart == "P"
				cQuery += "	AND LIQFAT.E5_RECPAG = 'P' "
			Else
				cQuery += "	AND LIQFAT.E5_RECPAG = 'R' "
			EndIf
			cQuery += 		  " AND LIQFAT.E5_MOTBX IN ('FAT','LIQ')  AND "

			cQuery += 		" NOT EXISTS ( "
			cQuery += 		" SELECT A.E5_NUMERO "
			cQuery += 			" FROM "+RetSqlName("SE5")+" A "
			cQuery += 			" WHERE   A.E5_FILIAL = LIQFAT.E5_FILIAL  AND"
			cQuery +=					" A.E5_PREFIXO	=	LIQFAT.E5_PREFIXO AND "
			cQuery +=					" A.E5_NUMERO	=	LIQFAT.E5_NUMERO AND "
			cQuery +=					" A.E5_PARCELA	=	LIQFAT.E5_PARCELA AND "
			cQuery +=					" A.E5_TIPO		=	LIQFAT.E5_TIPO AND "
			cQuery +=					" A.E5_CLIFOR	=	LIQFAT.E5_CLIFOR AND "
			cQuery +=					" A.E5_LOJA		=	LIQFAT.E5_LOJA AND "
			cQuery +=					" A.E5_SEQ		=	LIQFAT.E5_SEQ AND "
			cQuery +=					" A.E5_TIPODOC='ES' AND "
			If cCart == "P"
				cQuery += 				" A.E5_RECPAG<>'P' AND "
			Else
				cQuery +=				" A.E5_RECPAG<>'R' AND "
			EndIF
			cQuery +=					" A.D_E_L_E_T_ = ' ')"

			cQuery += 			" ) LIQFAT, "

			cQuery += "	SE5.R_E_C_N_O_ RECNOSE5 "
			cQuery += " FROM " + RetSqlName( "SE5" ) + " SE5 "

			If cCart == "P"
				cQuery += " INNER JOIN " + RetSqlName( "SE2" ) + " SE2 "
				cQuery += 	" ON SE2.E2_FILIAL = SE5.E5_FILIAL AND SE2.E2_PREFIXO = SE5.E5_PREFIXO AND SE2.E2_NUM = SE5.E5_NUMERO "
				cQuery += 	" AND SE2.E2_PARCELA = SE5.E5_PARCELA "
				cQuery += 	" AND SE2.E2_TIPO = SE5.E5_TIPO AND SE2.E2_FORNECE = SE5.E5_CLIFOR AND SE2.E2_LOJA = SE5.E5_LOJA AND "
				cQuery += 	" SE2.D_E_L_E_T_ = ' ' "
				If !Empty(SE2->E2_NUMBOR) .and. lFina241 .and. Type("cNumBor") == "C" .and. cNumBor <> SE2->E2_NUMBOR
					cQuery += " AND  E2_NUMBOR = '"+Space(TamSX3("E2_NUMBOR")[1])+"' "
				EndIf
			Else
				cQuery += " INNER JOIN " + RetSqlName( "SE1" ) + " SE1 "
				cQuery += 	" ON SE1.E1_FILORIG = SE5.E5_FILORIG AND SE1.E1_PREFIXO = SE5.E5_PREFIXO AND SE1.E1_NUM = SE5.E5_NUMERO "
				cQuery += 	" AND SE1.E1_PARCELA = SE5.E5_PARCELA "
				cQuery += 	" AND SE1.E1_TIPO = SE5.E5_TIPO AND SE1.E1_CLIENTE = SE5.E5_CLIFOR AND SE1.E1_LOJA = SE5.E5_LOJA "
				cQuery += 	" AND SE1.D_E_L_E_T_ = ' ' "
				If !IsInCallStack("fA070Tit") .and. !IsInCallStack("fA200Ger")
					cQuery += "    AND E1_NUMBOR = '"+Space(TamSX3("E1_NUMBOR")[1])+"' "
				EndIf
			EndIf

			cQuery += " INNER JOIN " + RetSqlName( "SED" ) + " SED ON "
			If !Empty(FWFilial("SE2")) .And. !Empty(FWFilial("SED"))
				If cCart == "P"
					cQuery += " SE2.E2_FILIAL = SED.ED_FILIAL AND "
				Else
					cQuery += " SE1.E1_FILIAL = SED.ED_FILIAL AND "
				EndIF
			Else
				cQuery += " SED.ED_FILIAL = '" + xFilial( "SED" , cFilOrig ) + "' AND "
			EndIf

			If cCart == "P"
				cQuery += " SE2.E2_NATUREZ = SED.ED_CODIGO AND "
			Else
				cQuery += " SE1.E1_NATUREZ = SED.ED_CODIGO AND "
			EndIF
			cQuery += "  (SED.ED_CALCPIS = 'S' OR SED.ED_CALCCOF = 'S' OR SED.ED_CALCCSL = 'S') AND SED.D_E_L_E_T_ = ' ' "
			If cCart == "R"
				cQuery += "	LEFT JOIN "+ RetSqlName( "SEA" ) + " SEA ON "

				If !Empty(FWFilial("SE1")) .And. !Empty(FWFilial("SEA"))
					cQuery += 	" SE1.E1_FILIAL = SEA.EA_FILIAL AND "
				EndIf
				cQuery += 		" SE1.E1_NUMBOR = SEA.EA_NUMBOR AND SE1.E1_PREFIXO = SEA.EA_PREFIXO "
				cQuery += 		" AND SE1.E1_NUM = SEA.EA_NUM "
				cQuery += 		" AND SE1.E1_CLIENTE = SEA.EA_FORNECE "
				cQuery += 		" AND SE1.E1_LOJA = SEA.EA_LOJA "
				cQuery += 		" AND SE1.E1_PARCELA = SEA.EA_PARCELA "
				cQuery += 		" AND SE1.E1_TIPO = SEA.EA_TIPO "
				cQuery += 		" AND SEA.EA_CART = 'R' AND SEA.D_E_L_E_T_ = ' ' "
			EndIf
			cQuery += " WHERE E5_FILIAL IN (" + cFiliais
			cQuery += ") AND "

			If Len(aCliFor) > 0
				//Verificar determinados fornecedores (raiz do CNPJ)
				cQuery += "( "
				For nKco := 1 to Len(aCliFor)
					cQuery += "(E5_CLIFOR ='"   + aCliFor[nKco,1]  + "' AND "
					cQuery += "E5_LOJA='"       + aCliFor[nKco,2]  + "') OR "
				Next nKco
				//Retiro o ultimo OR
				cQuery := Left( cQuery, Len( cQuery ) - 4 )
				cQuery += ") AND "
			Else  //Apenas o Fornecedor Atual
				cQuery += "E5_CLIFOR='"+ cCodigo+ "' AND "
				If lLojaAtu  //Considero apenas a loja atual
					cQuery += "E5_LOJA='"+cLoja+ "' AND "
				EndIf
			Endif

			cQuery += "	E5_DATA = '"	 + DToS( dRef )      + "' AND "
			cQuery += "	E5_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " AND "
			cQuery += "	E5_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "

			If lBQ10925 .or. lFina330
				cQuery += "	E5_TIPO NOT IN " + FormatIn(MVRECANT,cSepRec) + " AND "
			EndIf

			If lFina080
				cQuery += "	((E5_TIPO NOT IN " + FormatIn(MVPAGANT,cSepPag)  + ") OR "
				cQuery += "	(E5_TIPO IN " + FormatIn(MVPAGANT,cSepPag)  + " AND E5_VRETPIS + E5_VRETCOF + E5_VRETCSL = 0 ) ) AND "
			EndIf

			If !lJurMulDes //Desconsidero baixas onde foi baixado somente o valor da Multa e Juros.
				cQuery += "	E5_TIPODOC NOT IN ('MT') AND "
				cQuery += "	E5_TIPODOC NOT IN ('JR') AND "
				cQuery += "	E5_TIPODOC NOT IN ('DC') AND "
				cQuery += "	E5_VALOR <> SE5.E5_VLMULTA AND "
				cQuery += "	E5_VALOR <> SE5.E5_VLJUROS AND "
				cQuery += "	E5_VALOR <> SE5.E5_VLDESCO AND "
			Endif

			If cCart == "P"
				cQuery += "	E5_TIPO NOT IN " + FormatIn(MV_CPNEG,cSepNeg)  + " AND "
				cQuery += "	E5_RECPAG = 'P' AND "
			Else
				cQuery += "	E5_TIPO NOT IN " + FormatIn(MV_CRNEG,cSerNeg)  + " AND "
				cQuery += "	E5_RECPAG = 'R' AND "
			EndIf

			cQuery += 	  " (E5_MOTBX NOT IN ('FAT','IRF','PCC','LIQ','STP','DSD','ISS','INS','IMR') "

			If cCart == "P"
				cQuery += 		  "	OR (E5_MOTBX='PCC' AND  E5_TIPO IN " + FormatIn(MVPAGANT,cSepPag) + " ) ) AND "
			Else
				cQuery += 		  " OR (E5_MOTBX='PCC' AND  E5_TIPO IN " + FormatIn(MVRECANT,cSepRec) + " ) ) AND "
			EndIF

			cQuery += "	E5_SITUACA NOT IN ( 'C' , 'E' , 'X' ) AND "
			cQuery += "SE5.D_E_L_E_T_ = ' ' "
			cQuery += "AND NOT EXISTS ( "
			cQuery += "SELECT A.E5_NUMERO "
			cQuery += "FROM "+RetSqlName("SE5")+" A "
			cQuery += "WHERE A.E5_FILIAL IN ("+ cFiliais
			cQuery += ") AND "
			cQuery +=		"A.E5_PREFIXO=SE5.E5_PREFIXO AND "
			cQuery +=		"A.E5_NUMERO=SE5.E5_NUMERO AND "
			cQuery +=		"A.E5_PARCELA=SE5.E5_PARCELA AND "
			cQuery +=		"A.E5_TIPO=SE5.E5_TIPO AND "
			cQuery +=		"A.E5_CLIFOR=SE5.E5_CLIFOR AND "
			cQuery +=		"A.E5_LOJA=SE5.E5_LOJA AND "
			If cCart == "P"
				cQuery +=		"((A.E5_SEQ=SE5.E5_SEQ AND A.E5_TIPODOC='ES') OR "
				//Para desconsiderar a baixa de um PA, pois nao grava como estorno e sim como VL
				cQuery +=		"(A.E5_TIPO IN " + FormatIn(MVPAGANT,cSepPag) + " AND A.E5_TIPODOC='VL' )) AND "
				cQuery +=		"A.E5_RECPAG<>'P' AND "
			Else
				cQuery +=		"A.E5_SEQ=SE5.E5_SEQ AND "
				cQuery +=		"A.E5_TIPODOC='ES' AND "
				cQuery +=		"A.E5_RECPAG<>'R' AND "
			EndIF
			cQuery +=		"A.D_E_L_E_T_ = ' ')"

			If cCart == "P"
				cQuery +=	" AND ( CASE WHEN E5_MOTBX = 'CMP' AND E5_TIPO = '"+MVPAGANT+"' AND E5_VRETPIS+E5_VRETCOF+E5_VRETCSL >0 THEN  "
				cQuery +=					" (SELECT COUNT(*) REG "
				cQuery +=					" FROM "+RetSqlName("SE2")+" MES "
				cQuery +=					" WHERE MES.E2_FILIAL = SE5.E5_FILIAL AND MES.E2_PREFIXO = E5_PREFIXO "
				cQuery +=						" AND MES.E2_NUM=SE5.E5_NUMERO AND MES.E2_PARCELA=SE5.E5_PARCELA "
				cQuery +=						" AND MES.E2_TIPO=SE5.E5_TIPO AND MES.E2_FORNECE=SE5.E5_CLIFOR "
				cQuery +=						" AND MES.E2_LOJA=SE5.E5_LOJA AND MES.D_E_L_E_T_ = ' ' "
				cQuery +=						" AND MES.E2_TIPO = '"+MVPAGANT+"' "
				cQuery +=						" AND SUBSTRING(E5_DATA, 7, 2) = SUBSTRING(MES.E2_EMISSAO, 7, 2) "
				cQuery +=						" AND SUBSTRING(E5_DATA, 5, 2) = SUBSTRING(MES.E2_EMISSAO, 5, 2) "
				cQuery +=						" AND SUBSTRING(E5_DATA, 1, 4) = SUBSTRING(MES.E2_EMISSAO, 1, 4) "

				cQuery +=							" ) "
				cQuery +=					" WHEN E5_MOTBX = 'CMP' AND E5_TIPO <> '" + MVPAGANT + "' THEN "
				cQuery +=					" (SELECT COUNT(*) REG "
				cQuery +=					" FROM "+RetSqlName("SE2")+" MES "
				cQuery +=					" WHERE MES.E2_FILIAL = SE5.E5_FILIAL "
				cQuery +=					" AND MES.D_E_L_E_T_ = ' ' "
				cQuery +=					" AND ( (MES.E2_PREFIXO||MES.E2_NUM||MES.E2_PARCELA||MES.E2_TIPO||MES.E2_FORNECE||MES.E2_LOJA) = E5_DOCUMEN "
				cQuery +=					" AND MES.E2_TIPO = '"+MVPAGANT+"') "
				cQuery +=					" OR (MES.E2_PREFIXO = SE5.E5_PREFIXO AND MES.E2_NUM = SE5.E5_NUMERO AND MES.E2_PARCELA = SE5.E5_PARCELA "
				cQuery +=					" AND MES.E2_TIPO = SE5.E5_TIPO AND MES.E2_FORNECE = SE5.E5_FORNECE AND MES.E2_LOJA = SE5.E5_LOJA
				cQuery +=					" AND MES.E2_BASEPIS > 0 AND ((SE5.E5_VRETPIS + SE5.E5_VRETCOF + SE5.E5_VRETCSL) = 0) )
				cQuery +=					" AND SUBSTRING(E5_DATA, 7, 2) = SUBSTRING(MES.E2_EMISSAO, 7, 2) "
				cQuery +=					" AND SUBSTRING(E5_DATA, 5, 2) = SUBSTRING(MES.E2_EMISSAO, 5, 2) "
				cQuery +=					" AND SUBSTRING(E5_DATA, 1, 4) = SUBSTRING(MES.E2_EMISSAO, 1, 4) "

				cQuery +=							" ) "
				cQuery +=					" WHEN E5_MOTBX <> 'CMP' THEN 1 "
				cQuery +=	" END )  > 0 "
			EndIF
			If cCart == "P" .And. lF241QRY3 .and. (lFina241 .or. lFina080)
				cQuery	:= ExecBlock("F241QRY3",.F.,.F.,{cQuery})
			Endif
			cQuery += " ORDER BY RECNOSE5"
		Else
			//----------------------------------------------------------------------------
			//Tratamento para PCC na Emissão - Contas a Pagar e Contas a Receber
			//----------------------------------------------------------------------------
			If cCart=="P" //Contas a Pagar
				cQuery := "SELECT E2_VALOR,E2_PIS,E2_COFINS,E2_EMISSAO,E2_CSLL,E2_ISS,E2_INSS,E2_IRRF,E2_VRETPIS,E2_VRETCOF, "
				cQuery += "E2_BASEPIS, E2_BASECOF, E2_BASECSL, E2_ORIGEM, E2_MOEDA, E2_TXMOEDA, "
				cQuery += "SED.ED_CALCPIS , SED.ED_PERCPIS, SED.ED_CALCCOF , SED.ED_PERCCOF, SED.ED_CALCCSL , SED.ED_PERCCSL, "
				cQuery += "E2_APLVLMN,E2_VRETCSL,E2_PRETPIS,E2_PRETCOF,E2_PRETCSL,E2_VRETIRF,"
				cQuery += "E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE, E2_LOJA,E2_NATUREZ,SE2.R_E_C_N_O_ RECNOSE2 FROM "
				cQuery += RetSqlName( "SE2" ) + " SE2 "
				cQuery += " INNER JOIN " + RetSqlName( "SED" ) + " SED ON "

				If !Empty(FWFilial("SE2")) .And. !Empty(FWFilial("SED"))
					cQuery += " SE2.E2_FILIAL = SED.ED_FILIAL AND "
				Else
					cQuery += " SED.ED_FILIAL = '" + xFilial( "SED" , cFilOrig ) + "' AND "
				EndIf

				cQuery += 	" SE2.E2_NATUREZ = SED.ED_CODIGO AND "
				cQuery += 	" (SED.ED_CALCPIS = 'S' OR SED.ED_CALCCOF = 'S' OR SED.ED_CALCCSL = 'S') AND SED.D_E_L_E_T_ = ' ' "
				
                cQuery += " WHERE " + SetUpQry("E2_FILIAL") + " IN (" + cFiliais + ") AND "

				If Len(aCliFor) > 0
					//Verificar determinados fornecedores (raiz do CNPJ)
					cQuery += "( "
					For nKco := 1 to Len(aCliFor)
						cQuery += "(E2_FORNECE ='"   + aCliFor[nKco,1]  + "' AND "
						cQuery += "E2_LOJA='"       + aCliFor[nKco,2]  + "') OR "
					Next nKco

					cQuery := Left( cQuery, Len( cQuery ) - 4 )
					cQuery += ") AND "
				Else  //Apenas o Fornecedor Atual
					cQuery += "E2_FORNECE='"+ cCodigo+ "' AND "
					If lLojaAtu  //Considero apenas a loja atual
						cQuery += "E2_LOJA ='"+cLoja+ "' AND "
					EndIf
				Endif

				If nVencto == 2
					cQuery += "E2_VENCREA  = '" + DToS( dRef )      + "' AND "
				ElseIf nVencto == 1 .OR. EMPTY(nVencto)
					cQuery += "E2_EMISSAO = '" + DToS( dRef )      + "' AND "
				ElseIf nVencto == 3
					cQuery += "E2_EMIS1  = '" + DToS( dRef )      + "' AND "
				Endif

				If lFatCom //Não considera o título posicionado que está sendo gravado pelo compras/faturamento.
					cQuery += " NOT (E2_FILIAL = '"+SE2->E2_FILIAL+"' AND "
					cQuery += " E2_PREFIXO = '"+SE2->E2_PREFIXO+"' AND "
					cQuery += " E2_NUM = '"+SE2->E2_NUM+"' AND "
					cQuery += " E2_PARCELA = '"+SE2->E2_PARCELA+"' AND "
					cQuery += " E2_TIPO = '"+SE2->E2_TIPO+"' AND "
					cQuery += " E2_FORNECE = '"+SE2->E2_FORNECE+"' AND "
					cQuery += " E2_LOJA = '"+SE2->E2_LOJA+"') AND "
				EndIf

				cQuery += "E2_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " AND "
				cQuery += "E2_TIPO NOT IN " + FormatIn(MV_CPNEG,cSepNeg)  + " AND "
				cQuery += "E2_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "

				If FwIsInCallStack("FA050Nat2") .And. M->E2_TIPO $ MVPAGANT
					cQuery += " E2_TIPO = '"+MVPAGANT+"'   AND  "
				ElseIf SE2->E2_TIPO $ MVPAGANT
					cQuery += " E2_TIPO = '"+MVPAGANT+"'   AND  "
				EndIF

				cQuery += "(E2_FATURA = '"+Space(TamSX3("E2_FATURA")[1])+"' OR "
				cQuery += "E2_FATURA = 'NOTFAT') AND "
				cQuery += "	E2_APLVLMN <> '2' AND "

				// não considera titulo pai de desdobramento para imposto
				cQuery += "(E2_DESDOBR <> 'S' OR ( E2_DESDOBR = 'S' AND E2_STATUS <> 'D')) AND "
				cQuery += "SE2.D_E_L_E_T_ = ' ' "
			Else //Contas a Receber
				cQuery := "SELECT E1_VALOR,E1_PIS,E1_COFINS,E1_CSLL,E1_IRRF,E1_ISS, E1_INSS,E1_SABTPIS,E1_SABTCOF,E1_SABTCSL,E1_DESDOBR, "
				cQuery += "E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA,E1_NATUREZ,E1_FATURA,E1_VENCREA,E1_BAIXA,E1_MOEDA,E1_TXMOEDA,"
				cQuery += "SED.ED_CALCPIS , SED.ED_PERCPIS, SED.ED_CALCCOF , SED.ED_PERCCOF, SED.ED_CALCCSL , SED.ED_PERCCSL, E1_EMISSAO, "
				cQuery += 	"E1_SABTIRF ,  "
				cQuery += 	"E1_BASEPIS , E1_BASECOF, E1_BASECSL,E1_ORIGEM, "
				cQuery += "	SE1.R_E_C_N_O_ RECNOSE1 FROM "
				cQuery += RetSqlName( "SE1" ) + " SE1 "
				cQuery += " INNER JOIN " + RetSqlName( "SED" ) + " SED ON "

				If !Empty(FWFilial("SE1")) .And. !Empty(FWFilial("SED"))
					cQuery += " SE1.E1_FILIAL = SED.ED_FILIAL AND "
				ElseIf !Empty(cFilOrig)
					cQuery += " SED.ED_FILIAL = '" + xFilial( "SED" , cFilOrig ) + "' AND "
				Else
					cQuery += " SED.ED_FILIAL = '" + FWxFilial("SED") + "' AND "
				EndIf

				cQuery += "  SE1.E1_NATUREZ = SED.ED_CODIGO AND "
				cQuery += "  (SED.ED_CALCPIS = 'S' OR SED.ED_CALCCOF = 'S' OR SED.ED_CALCCSL = 'S') AND SED.D_E_L_E_T_ = ' ' "

				cQuery += "WHERE E1_FILIAL IN ("+ cFilE1

				cQuery += ") AND "

				If Len(aCliFor) > 0
					cQuery += "( "
					For nKco := 1 to Len(aCliFor)
						cQuery += "(E1_CLIENTE ='"   + aCliFor[nKco,1]  + "' AND "
						cQuery += "E1_LOJA='"       + aCliFor[nKco,2]  + "') OR "
					Next nKco

					cQuery := Left( cQuery, Len( cQuery ) - 4 )
					cQuery += ") AND "
				Else  //Apenas o Cliente Atual
					cQuery += "E1_CLIENTE='"+ cCodigo+ "' AND "
					If lLojaAtu  //Considero apenas a loja atual
						cQuery += "E1_LOJA ='"+cLoja+ "' AND "
					EndIf
				EndIf

				If nVencto == 2
					cQuery += "E1_VENCREA  = '" + DToS( dRef )      + "' AND "
				ElseIf nVencto == 1 .OR. EMPTY(nVencto)
					cQuery += "E1_EMISSAO = '" + DToS( dRef )      + "' AND "
				ElseIf nVencto == 3
					cQuery += "E1_EMIS1  = '" + DToS( dRef )      + "' AND "
				Endif

				If lFatCom //Não considera o título posicionado que está sendo gravado pelo compras/faturamento.
					cQuery += " NOT (E1_FILIAL = '"+SE1->E1_FILIAL+"' AND "
					cQuery += " E1_PREFIXO = '"+SE1->E1_PREFIXO+"' AND "
					cQuery += " E1_NUM = '"+SE1->E1_NUM+"' AND "
					cQuery += " E1_PARCELA = '"+SE1->E1_PARCELA+"' AND "
					cQuery += " E1_TIPO = '"+SE1->E1_TIPO+"' AND "
					cQuery += " E1_CLIENTE = '"+SE1->E1_CLIENTE+"' AND "
					cQuery += " E1_LOJA = '"+SE1->E1_LOJA+"') AND "
				EndIf

				cQuery += "E1_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " AND "
				cQuery += "E1_TIPO NOT IN " + FormatIn(MV_CRNEG,cSepNeg)  + " AND "
				cQuery += "E1_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "
				cQuery += "E1_TIPO <> '"+MVRECANT+"'   AND  "
				cQuery += "(E1_FATURA = '"+Space(TamSX3("E1_FATURA")[1])+"' OR "
				cQuery += "E1_FATURA = 'NOTFAT') AND "
				cQuery += "E1_APLVLMN <> '2' AND "

				If FwIsInCallStack("FA040Natur") .And. M->E1_TIPO $ MVRECANT
					cQuery += " E1_TIPO = '"+MVRECANT+"'   AND  "
				ElseIf SE1->E1_TIPO $ MVPAGANT
					cQuery += " E1_TIPO = '"+MVRECANT+"'   AND  "
				Else
					cQuery += " E1_TIPO <> '"+MVRECANT+"'   AND  "
				EndIF

				// não considera titulo pai de desdobramento para imposto
				cQuery += "(E1_DESDOBR <> '1' OR ( E1_DESDOBR = '1' AND E1_STATUS <> 'B')) AND "
				If !lCodRetPCC
					cQuery += " SE1.D_E_L_E_T_=' '"
				Else
					If FwIsInCallStack("FA040Inclu")
						If !Empty(M->E1_CODRET)
							cQuery += " E1_CODRET <> ' ' AND SE1.D_E_L_E_T_=' '"
						Else
							cQuery += " E1_CODRET = ' ' AND SE1.D_E_L_E_T_=' '"
						EndIf
					ElseIf lFatCom
						If SED->ED_PCCINDV == '1'
							cQuery += " E1_CODRET <> ' ' AND SE1.D_E_L_E_T_=' '"
						Else
							cQuery += " E1_CODRET = ' ' AND SE1.D_E_L_E_T_=' '"
						EndIf
					Else
						cQuery += " SE1.D_E_L_E_T_=' '"
					EndIf
				EndIf
				If lFatCom
					cQuery += " ORDER BY SE1.E1_FILIAL || SE1.E1_PREFIXO || SE1.E1_NUM || SE1.E1_TIPO || SE1.E1_CLIENTE || SE1.E1_LOJA "
				EndIf
			EndIf
		EndIf

		cQuery := ChangeQuery( cQuery )

		If Select(cAliasQry) > 0
			( cAliasQry )->( dbCloseArea() )
		Endif

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

		While !( cAliasQry )->( Eof())
			If lPCCBaixa .And. cCart == "P" .And. !lF241QRY3 .And. !Empty((cAliasQry)->E2_NUMBOR) .And. !Empty((cAliasQry)->E5_DOCUMEN)
				If FinRetBor((cAliasQry)->E5_FILIAL, (cAliasQry)->E5_PREFIXO, (cAliasQry)->E5_NUMERO, (cAliasQry)->E5_PARCELA, (cAliasQry)->E5_TIPO, ;
					(cAliasQry)->E5_CLIFOR, (cAliasQry)->E5_LOJA, (cAliasQry)->E5_DOCUMEN, dRef, (cAliasQry)->E5_FILORIG)
					(cAliasQry)->(DbSkip())
					Loop
				EndIf
			EndIf

			If lFatCom .AND. cCart == "R"
				If cE1Chv <> ( cAliasQry )->( E1_FILIAL + E1_PREFIXO + E1_NUM + E1_TIPO + E1_CLIENTE + E1_LOJA )
					cE1Chv := ( cAliasQry )->( E1_FILIAL + E1_PREFIXO + E1_NUM + E1_TIPO + E1_CLIENTE + E1_LOJA )
				Else
					(cAliasQry)->(DbSkip())
					Loop
				EndIf
			EndIf

			If lPCCBaixa .And. lMotBxMBco .and. ((cAliasQry)->E5_MOTBX <> "CMP")
				If !Fa080MovBc((cAliasQry)->E5_MOTBX)
					(cAliasQry)->(DbSkip())
					Loop
				Endif
			Endif

			If lPCCBaixa .And. lRaRtImp .and. (cAliasQry)->E5_MOTBX == "CMP" .AND. cCart == "R"
				(cAliasQry)->(DbSkip())
				Loop
			EndIf			

			//Desconsiderar titulo originador de desdobramento
			If !lPCCBaixa .and. !lNRastDSD
				If cCart=="R"
					dbSelectArea("FI7")
					FI7->(DbSetOrder(1))
					If dbSeek(xFilial("FI7")+(cAliasQry)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA))
						(cAliasQry)->(DbSkip())
						Loop
					Endif
				Else
					dbSelectArea("FI8")
					FI8->(DbSetOrder(1))
					If dbSeek(xFilial("FI8")+(cAliasQry)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))
						(cAliasQry)->(DbSkip())
						Loop
					Endif
				Endif
			Endif

			If lFINEXEC
				lRet := ExecBlock("FINEXEC",.F.,.F.,{cAliasQry})
				If lRet
					(cAliasQry)->(DbSkip())
					Loop
				Endif
			Endif

			If lAltEmi .and. cCart=="R" .and. ((cAliasQry)->RECNOSE1 == SE1->(Recno()))
				(cAliasQry)->(DbSkip())
				Loop
			ElseIf lAltEmi .and. cCart=="P" .and. ((cAliasQry)->RECNOSE2 == SE2->(Recno()))
				(cAliasQry)->(DbSkip())
				Loop
			Endif
			
			If cCart == "R"			
				SA1->( dbSetOrder(1) )
				If SA1->( dbSeek( xFilial("SA1") + Iif(lPCCBaixa, (cAliasQry)->(E5_CLIFOR+E5_LOJA), (cAliasQry)->(E1_CLIENTE+E1_LOJA)) ) )
					// Posiciona no cliente para verificar modo de retencao de ISS
					lRecIssCR := (SA1->A1_RECISS == "1" .And. GetNewPar("MV_DESCISS",.F.))
				EndIf
				RestArea(aArSA1)
				lOrig := __cVl460Nt == '3' .And. AllTrim( (cAliasQry)->E1_ORIGEM ) == 'FINA460'
			EndIf				

			nBSEPis	:= IIF(cCart=="P", (cAliasQry)->E2_BASEPIS, IIF( lOrig, (cAliasQry)->E1_BASEPIS, ;
						IIF(!Empty((cAliasQry)->E1_BASEPIS),(cAliasQry)->E1_BASEPIS, (cAliasQry)->E1_VALOR)) )
			nBSECof	:= IIF(cCart=="P", (cAliasQry)->E2_BASECOF, IIF( lOrig, (cAliasQry)->E1_BASECOF, ;
						IIF(!Empty((cAliasQry)->E1_BASECOF),(cAliasQry)->E1_BASECOF, (cAliasQry)->E1_VALOR)) )
			nBSECsl	:= IIF(cCart=="P", (cAliasQry)->E2_BASECSL, IIF( lOrig, (cAliasQry)->E1_BASECSL, ;
						IIF(!Empty((cAliasQry)->E1_BASECSL),(cAliasQry)->E1_BASECSL, (cAliasQry)->E1_VALOR)) )

			IF lPCCBaixa

				// Tratamento do parâmetro MV_MRETISS de acordo com a filial do registro posicionado pela query de cumulatividade.
				If lConsFil .And. cCart == "P"
					lCalcIssBx := SuperGetMV("MV_MRETISS",.T.,"1", (cAliasQry)->E2_FILIAL ) == "2"
				EndIf

				nImpRetEmi := 0
				nSaldo := IIF(cCart == "P",(cAliasQry)->E2_SALDO, (cAliasQry)->E1_SALDO )
				lLiqFat := IIF(cCart == "P",(!Empty((cAliasQry)->E2_FATURA) .Or. !Empty((cAliasQry)->E2_NUMLIQ)), (!Empty((cAliasQry)->E1_FATURA) .Or. !Empty((cAliasQry)->E1_NUMLIQ)) )

				nValTit := IIF(cCart=="P", (cAliasQry)->E2_VALOR, (cAliasQry)->E1_VALOR)
				If !lCalcIssBx 
					nImpRetEmi := IIF(cCart=="P", (cAliasQry)->E2_ISS, IIF(lRecIssCR, (cAliasQry)->E1_ISS, 0))
				EndIf
				If !lIrpfBaixa
					nImpRetEmi += IIF(cCart=="P", (cAliasQry)->E2_IRRF, (cAliasQry)->E1_IRRF)
				EndIf
				If !lInssBx
					nImpRetEmi += IIF(cCart=="P", (cAliasQry)->E2_INSS, (cAliasQry)->E1_INSS)
				EndIf

				IF cCart=="R"
					nValTit -= nImpRetEmi
				EndIf
				
				nVret := IIF(lPccBaixa .And. (cAliasQry)->E5_PRETPIS <> "1", (cAliasQry)->(E5_VRETPIS+E5_VRETCOF+E5_VRETCSL), 0)
				nVret += IIF(lCalcIssBx .And. (cCart == "P" .Or. lRecIssCR), (cAliasQry)->E5_VRETISS, 0)
				nVret += IIF(lIrpfBaixa .And. (cAliasQry)->E5_PRETIRF <> "1", (cAliasQry)->E5_VRETIRF, 0)
				nVret += IIF(lInssBx .And. (cAliasQry)->E5_PRETINS <> "1", (cAliasQry)->E5_VRETINS, 0)

				IF cCart=="R"
					If SE1->( dbSeek(xFilial("SE1") + ( cAliasQry )->E5_PREFIXO + ( cAliasQry )->E5_NUMERO + ( cAliasQry )->E5_PARCELA + "AB-" + ( cAliasQry )->E5_CLIFOR + ( cAliasQry )->E5_LOJA) )
						nAbat := SE1->E1_VALOR
					EndIf
					RestArea(aArSE1)
				EndIf
				//Baixas que não atingiu o mínimo, mesmo dia ou Baixa de Faturas com Impostos na Baixa que já foram retidos
				nBPisCofCsl := If(Empty(nBSEPis), If(Empty(nBSECof), nBSECsl, nBSECof), nBSEPis) //BASE TOTAL DO TÍTULO NA MOEDA DO TÍTULO

				If cCart == "P" .and. AllTrim((cAliasQry)->E2_ORIGEM) == "MATA100"
					nVlRetCtr := (cAliasQry)->E2_RETCNTR
				Else
					nVlRetCtr := 0
				EndIF
				nVlAcess := (cAliasQry)->(E5_VLJUROS+E5_VLMULTA-E5_VLDESCO)

				If nSaldo == 0 .And. (cAliasQry)->ATG == 0  .And. ( (!lLiqFat .And. (nBPisCofCsl == ((cAliasQry)->E5_VALOR+nImpRetEmi+nVlRetCtr+nVret-nVlAcess)) .Or. ;
					(cAliasQry)->E5_PRETPIS == "1" ) .Or. (lLiqFat .And. nValTit == (( cAliasQry )->E5_VALOR+nVret))  )
					nBasePis := nBSEPis
					nBaseCof := nBSECof
					nBaseCsl := nBSECsl
				//Baixas Parciais de títulos que geram Liquidações/Faturas
				ElseIf nSaldo == 0 .And. !lLiqFat  .And. ( cAliasQry )->LIQFAT > 0
					nBasePis := nBSEPis - ( cAliasQry )->E5_VALOR
					nBaseCof := nBSECof - ( cAliasQry )->E5_VALOR
					nBaseCsl := nBSECsl - ( cAliasQry )->E5_VALOR
				//Recomposição de saldo de rotinas que utilizaram as rotinas de baixas.
				ElseIf nSaldo == 0 .And. !lLiqFat .AND. IIF(cCart=="R",(( cAliasQry )->E1_VALOR == ( cAliasQry )->E1_BASEPIS), .T.)
					If cCart=="R" .and. nImpRetEmi > 0 .and. ( cAliasQry )->E1_VALOR == ( cAliasQry )->E5_VALOR + nAbat + nImpRetEmi // baixa total
						nBasePis := nBSEPis - (( cAliasQry )->E5_VALOR + nAbat + nImpRetEmi )
						nBaseCof := nBSECof - (( cAliasQry )->E5_VALOR + nAbat + nImpRetEmi )
						nBaseCsl := nBSECsl - (( cAliasQry )->E5_VALOR + nAbat + nImpRetEmi )
					ElseIf cCart=="R" .and. nImpRetEmi > 0 .and. ( cAliasQry )->E1_VALOR <> ( cAliasQry )->E5_VALOR + nAbat + nImpRetEmi // baixa parcial
						aBaixa := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /"+MV_CRNEG,( cAliasQry )->E5_PREFIXO, ( cAliasQry )->E5_NUMERO, ( cAliasQry )->E5_PARCELA, ( cAliasQry )->E5_TIPO,,,( cAliasQry )->E5_CLIFOR,( cAliasQry )->E5_LOJA,,,,)//procuro as baixas deste titulo
						//Exibe na tela de Cancelamento as baixas na ordem que foram feitas
						aSort(aBaixa,,,{|x,y| SubStr(x,Len(x)-1,Len(x)) < SubStr(y,Len(y)-1,Len(y))})
						If Len(aBaixa) > 1 //somente soma os impostos na emissao caso for a ultima baixa
							If (( cAliasQry )->E5_PREFIXO+" "+( cAliasQry )->E5_NUMERO+Iif(Len(( cAliasQry )->E5_NUMERO)==TamSX3("E5_NUMERO")[1],Space(TamSX3("E5_NUMERO")[1]),"")+" "+( cAliasQry )->E5_PARCELA+" "+( cAliasQry )->E5_TIPO+" "+( cAliasQry )->E5_CLIFOR+" "+( cAliasQry )->E5_LOJA+" "+DTOC(STOD(( cAliasQry )->E5_DATA))+" "+Transf(( cAliasQry )->E5_VALOR,"@E 9999,999,999.99")+"   "+( cAliasQry )->E5_SEQ)  == aBaixa[Len(aBaixa)]
								nBasePis := nBSEPis - (( cAliasQry )->E5_VALOR + nAbat + nImpRetEmi )
								nBaseCof := nBSECof - (( cAliasQry )->E5_VALOR + nAbat + nImpRetEmi )
								nBaseCsl := nBSECsl - (( cAliasQry )->E5_VALOR + nAbat + nImpRetEmi )
							Else
								nBasePis := nBSEPis - ( cAliasQry )->E5_VALOR
								nBaseCof := nBSECof - ( cAliasQry )->E5_VALOR
								nBaseCsl := nBSECsl - ( cAliasQry )->E5_VALOR
							EndIf
						EndIf
					Else
						nBasePis := nBSEPis - (( cAliasQry )->E5_VALOR + nAbat + nImpRetEmi )
						nBaseCof := nBSECof - (( cAliasQry )->E5_VALOR + nAbat + nImpRetEmi )
						nBaseCsl := nBSECsl - (( cAliasQry )->E5_VALOR + nAbat + nImpRetEmi )
					EndIf
				ElseIf nSaldo == 0 .And. cCart=="R" .and. ( cAliasQry )->E1_VALOR <> ( cAliasQry )->E1_BASEPIS
					nBasePis := nBSEPis
					nBaseCof := nBSECof
					nBaseCsl := nBSECsl
				Else
					
					nValor := ( cAliasQry )->E5_VALOR
					If nSaldo > 0
						nValor += IIF(lLiquido, nVret, 0)
					EndIf

					If cCart == "R"
						nBxParcial := (nValor / (nValTit + nImpRetEmi))
					Else
						If SE2->E2_MOEDA == 1
							nBxParcial := (nValor / (nValTit + nImpRetEmi)) 
						else
							nBxParcial := (nValor / (nValTit+xMoeda(nImpRetEmi,1,SE2->E2_MOEDA,SE2->E2_EMISSAO,3,,nTxTitInc))) 
						EndIf
					EndIf
					nBasePis := (nBSEPis * nBxParcial)
					nBaseCof := (nBSECof * nBxParcial)
					nBaseCsl := (nBSECsl * nBxParcial)
				EndIf
			Else
				nBasePis := nBSEPis
				nBaseCof := nBSECof
				nBaseCsl := nBSECsl
			EndIf

			If cCart == "P" .and. AllTrim((cAliasQry)->E2_ORIGEM) $ "MATA103|MATA100"
				nBasePis := Max(nBasePis,0)
				nBaseCof := Max(nBaseCof,0)
				nBaseCsl := Max(nBaseCsl,0)
			EndIf

			//Conversão monetaria das bases para moeda forte(MOEDA1) retirado trecho que trata o Contas a Pagar pois a base do titulo já está em moeda2
			If !lPccBaixa
				If cCart == "R" // Contas a Receber
					If (cAliasQry)->E1_MOEDA != 1
						nBasePis := xMoeda(nBSEPis,(cAliasQry)->E1_MOEDA,1,(cAliasQry)->E1_EMISSAO,3,(cAliasQry)->E1_TXMOEDA)
						nBaseCof := xMoeda(nBSECof,(cAliasQry)->E1_MOEDA,1,(cAliasQry)->E1_EMISSAO,3,(cAliasQry)->E1_TXMOEDA)
						nBaseCsl := xMoeda(nBSECsl,(cAliasQry)->E1_MOEDA,1,(cAliasQry)->E1_EMISSAO,3,(cAliasQry)->E1_TXMOEDA)
						If lRoundPis
							nBasePis := Round(nBasePis,MsDecimais(1))
						Else 
							nBasePis := NoRound(nBasePis,MsDecimais(1))
						Endif
						If lRoundCof
							nBaseCof := Round(nBaseCof,MsDecimais(1))
						Else 
							nBaseCof := NoRound(nBaseCof,MsDecimais(1))
						Endif
						If lRoundCsl
							nBaseCsl := Round(nBaseCsl,MsDecimais(1))
						Else 
							nBaseCsl := NoRound(nBaseCsl,MsDecimais(1))
						Endif
					EndIf
				Else
					If (cAliasQry)->E2_MOEDA != 1
						nBasePis := xMoeda(nBSEPis,(cAliasQry)->E2_MOEDA,1,(cAliasQry)->E2_EMISSAO,3,(cAliasQry)->E2_TXMOEDA)
						nBaseCof := xMoeda(nBSECof,(cAliasQry)->E2_MOEDA,1,(cAliasQry)->E2_EMISSAO,3,(cAliasQry)->E2_TXMOEDA)
						nBaseCsl := xMoeda(nBSECsl,(cAliasQry)->E2_MOEDA,1,(cAliasQry)->E2_EMISSAO,3,(cAliasQry)->E2_TXMOEDA)
						If lRoundPis
							nBasePis := Round(nBasePis,MsDecimais(1))
						Else 
							nBasePis := NoRound(nBasePis,MsDecimais(1))
						Endif
						If lRoundCof
							nBaseCof := Round(nBaseCof,MsDecimais(1))
						Else 
							nBaseCof := NoRound(nBaseCof,MsDecimais(1))
						Endif
						If lRoundCsl
							nBaseCsl := Round(nBaseCsl,MsDecimais(1))
						Else 
							nBaseCsl := NoRound(nBaseCsl,MsDecimais(1))
						Endif
					EndIf
				EndIf
			EndIf

			If cCart == "P"
				aPercPcc := GetPerPCC( (cAliasQry)->E2_NATUREZ, (cAliasQry)->E2_ORIGEM, cCart, (cAliasQry)->RECNOSE2, lPCCBaixa )
			Else
				aPercPcc := GetPerPCC( (cAliasQry)->E1_NATUREZ, (cAliasQry)->E1_ORIGEM, cCart, (cAliasQry)->RECNOSE1, lPCCBaixa )
			EndIf
			
			If (cAliasQry)->ED_CALCPIS == "S" .and. Iif(cCart == "P", SA2->A2_RECPIS == '2', SA1->A1_RECPIS $ 'S|P')
				nPisAux := ( nBasePis * aPercPcc[1] ) / 100
				nTCalcPis += nPisAux
			EndIf

			If (cAliasQry)->ED_CALCCOF == "S" .and. Iif(cCart == "P", SA2->A2_RECCOFI == '2', SA1->A1_RECCOFI $ 'S|P')
				nCofAux := ( nBaseCof * aPercPcc[2] ) / 100
				nTCalcCof += nCofAux
			EndIf

			If (cAliasQry)->ED_CALCCSL == "S" .and. Iif(cCart == "P", SA2->A2_RECCSLL == '2', SA1->A1_RECCSLL $ 'S|P')
				nCslAux := ( nBaseCsl * aPercPcc[3] ) / 100
				nTCalcCsl += nCslAux
			EndIf

			//Total Retido
			IF lPccBaixa
				If (cAliasQry)->E5_PRETPIS $ "3|4|5" .OR. ((cAliasQry)->E5_PRETPIS $ ' |7' .AND. (cAliasQry)->E5_VRETPIS > 0) 
					nTotRtPis		+= (cAliasQry)->E5_VRETPIS
				Else
					//Variaveis utilizadas na reestruturação da SE5
					nPisBaseR += nBasePis
					AADD(aTitCalc,{(cAliasQry)->E5_TABORI, (cAliasQry)->E5_IDORIG})

					//Atende a nova gravação de PA
					If (cAliasQry)->E5_TIPO $ MVPAGANT .AND. (cAliasQry)->E5_TABORI != "SE2"
						cChaveTit := xFilial("SE2", cFilOrig) + "|" + (cAliasQry)->E5_PREFIXO + "|" + (cAliasQry)->E5_NUMERO + "|" + (cAliasQry)->E5_PARCELA + "|" + (cAliasQry)->E5_TIPO + "|" + (cAliasQry)->E5_CLIFOR + "|" + (cAliasQry)->E5_LOJA
						cChaveFK7 := FINBuscaFK7(cChaveTit, "SE2")
						AADD(aTitCalc,{"SE2", cChaveFK7})
					Endif
				EndIf

				If (cAliasQry)->E5_PRETCOF $ "3|4|5" .OR. ((cAliasQry)->E5_PRETCOF $ ' |7' .AND. (cAliasQry)->E5_VRETCOF > 0) 
					nTotRtCof		+= (cAliasQry)->E5_VRETCOF
				Else
					//Variaveis utilizadas na reestruturação da SE5
					nCofBaseR += nBaseCof
				EndIf

				If (cAliasQry)->E5_PRETCSL $ "3|4|5" .OR. ((cAliasQry)->E5_PRETCSL $ ' |7' .AND. (cAliasQry)->E5_VRETCSL > 0)
					nTotRtCsl		+= (cAliasQry)->E5_VRETCSL
				Else
					//Variaveis utilizadas na reestruturação da SE5
					nCslBaseR += nBaseCsl
				Endif
			Else
				If cCart == "P"
					cOrigem := AllTrim((cAliasQry)->E2_ORIGEM)

					If (cAliasQry)->E2_PRETPIS <> '1' .AND. ( (cAliasQry)->E2_PRETPIS $ "3|4|7" .Or. (EMPTY((cAliasQry)->E2_PRETPIS) .And.  (cAliasQry)->E2_VRETPIS > 0) .Or. cOrigem == "MATA100" )
						nTotRtPis		+= IIF(cOrigem == "MATA100",(cAliasQry)->E2_PIS,(cAliasQry)->E2_VRETPIS)
					EndIf

					If (cAliasQry)->E2_PRETCSL <> '1' .AND. ( (cAliasQry)->E2_PRETCOF $ "3|4|7" .OR. (EMPTY((cAliasQry)->E2_PRETCOF) .And.  (cAliasQry)->E2_VRETCOF > 0) .Or. cOrigem == "MATA100" )
						nTotRtCof		+= IIF(cOrigem == "MATA100",(cAliasQry)->E2_COFINS,(cAliasQry)->E2_VRETCOF)
					EndIf

					If (cAliasQry)->E2_PRETCSL <> '1' .AND. ( (cAliasQry)->E2_PRETCSL $ "3|4|7" .OR. (EMPTY((cAliasQry)->E2_PRETCSL) .And.  (cAliasQry)->E2_VRETCSL > 0) .Or. cOrigem == "MATA100" )
						nTotRtCsl		+= IIF(cOrigem == "MATA100",(cAliasQry)->E2_CSLL,(cAliasQry)->E2_VRETCSL)
					EndIf
				Else
					If (cAliasQry)->E1_PIS > 0
						nTotRtPis		+= (cAliasQry)->E1_PIS
					EndIf
					If (cAliasQry)->E1_COFINS > 0
						nTotRtCof		+= (cAliasQry)->E1_COFINS
					EndIf
					If (cAliasQry)->E1_CSLL > 0
						nTotRtCsl		+= (cAliasQry)->E1_CSLL
					EndIf
				EndIf
			EndIf

			(cAliasQry)->(DbSkip())
		EndDo

		//---------------------------------------------------------------------------------------
		//Tratamento para PCC cumulatividade de títulos em borderô
		//---------------------------------------------------------------------------------------
		If lPCCBaixa
			If 	cCart == "P"
				cQuery := "	SELECT E2_VALOR,E2_PIS,E2_COFINS,E2_EMISSAO,E2_CSLL,E2_ISS,E2_INSS,E2_IRRF,E2_VRETPIS,E2_VRETCOF,E2_VRETCSL, "
				cQuery += 	" E2_PRETPIS,E2_PRETCOF,E2_PRETCSL,E2_NUMBOR,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,E2_MOEDA, "
				cQuery += 	" E2_ACRESC,E2_DECRESC,E2_FATURA,E2_SALDO,E2_VENCREA,E2_BASEPIS,E2_BASECOF, E2_BASECSL,E2_SEST,E2_DTBORDE,E2_APLVLMN,E2_ORIGEM,E2_NUMTIT,E2_FORNPAI, "
				cQuery += 	" SED.ED_CALCPIS, SED.ED_PERCPIS, SED.ED_CALCCOF, SED.ED_PERCCOF, SED.ED_CALCCSL, SED.ED_PERCCSL, SE2.E2_NUMLIQ, SE2.E2_NATUREZ, "
				If lF241CMP2 .And. (lFina241 .or. lFina080)
					cQuery	+= ExecBlock("F241CMP2",.F.,.F., {cQuery}) + ","
				EndIf
				cQuery += 	" SE2.R_E_C_N_O_ RECNO "

				cQuery += 	" FROM "+ RetSqlName( "SE2" ) + " SE2 "
				
				cQuery +=	" INNER JOIN "+ RetSqlName( "SED" ) + " SED ON "
				If !Empty(FWFilial("SE2")) .And. !Empty(FWFilial("SED"))
					cQuery += " SE2.E2_FILIAL = SED.ED_FILIAL AND "
				Else
					cQuery += " SED.ED_FILIAL = '" + xFilial( "SED" , cFilOrig ) + "' AND "
				EndIf
				cQuery +=     " SE2.E2_NATUREZ = SED.ED_CODIGO AND (SED.ED_CALCPIS = 'S' OR SED.ED_CALCCOF = 'S' OR SED.ED_CALCCSL = 'S') AND SED.D_E_L_E_T_ = ' ' "

				cQuery +=   " INNER JOIN " + RetSqlName( "SEA" ) + " SEA ON"
				cQuery +=     " SE2.E2_FILORIG = SEA.EA_FILORIG AND SE2.E2_NUMBOR = SEA.EA_NUMBOR AND SE2.E2_PREFIXO = SEA.EA_PREFIXO"
				cQuery += 	  " AND SE2.E2_NUM = SEA.EA_NUM AND SE2.E2_PARCELA = SEA.EA_PARCELA AND SE2.E2_TIPO = SEA.EA_TIPO"
				cQuery += 	  " AND SEA.EA_CART = 'P' AND SEA.D_E_L_E_T_ = ' ' "

                cQuery += " WHERE " + SetUpQry("E2_FILIAL") + " IN (" + cFiliais + ") AND "

				If Len(aCliFor) > 0
					//Verificar determinados fornecedores (raiz do CNPJ)
					cQuery += "( "
					For nKco := 1 to Len(aCliFor)
						cQuery += "(E2_FORNECE ='"   + aCliFor[nKco,1]  + "' AND "
						cQuery += "E2_LOJA='"       + aCliFor[nKco,2]  + "') OR "
					Next nKco

					cQuery := Left( cQuery, Len( cQuery ) - 4 )
					cQuery += ") AND "
				Else  //Apenas o Fornecedor Atual
					cQuery += "E2_FORNECE='"+ cCodigo+ "' AND "
					If lLojaAtu  //Considero apenas a loja atual
						cQuery += "E2_LOJA ='"+cLoja+ "' AND "
					EndIf
				EndIf

				If !lFina241 .And. !Empty(SE2->E2_NUMBOR) //Não considera o título posicionado que está sendo baixado pelo FINA080/090.
					cQuery += " NOT (E2_FILIAL = '"+SE2->E2_FILIAL+"' AND "
					cQuery += " E2_PREFIXO = '"+SE2->E2_PREFIXO+"' AND "
					cQuery += " E2_NUM = '"+SE2->E2_NUM+"' AND "
					cQuery += " E2_PARCELA = '"+SE2->E2_PARCELA+"' AND "
					cQuery += " E2_TIPO = '"+SE2->E2_TIPO+"' AND "
					cQuery += " E2_FORNECE = '"+SE2->E2_FORNECE+"' AND "
					cQuery += " E2_LOJA = '"+SE2->E2_LOJA+"') AND "
				EndIf

				cQuery += " E2_DTBORDE = '" + DToS( dRef )      + "' AND "
				cQuery += " E2_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " AND "
				cQuery += " E2_TIPO NOT IN " + FormatIn(MV_CPNEG,cSepNeg)  + " AND "
				cQuery += " E2_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "
				cQuery += " E2_TIPO NOT IN " + FormatIn(MVPAGANT,cSepPag)  + " AND "

				cQuery += " SEA.EA_ORIGEM = 'FINA241' AND "

				If lFina241
					If !lFinxOrd
						cQuery += " (SE2.R_E_C_N_O_ < "+alltrim(STR(SE2->(RECNO())))
					Else
						cQuery	+= " (" + ExecBlock("FinxOrd",.F.,.F., {cQuery})
					Endif
					cQuery += " OR SE2.E2_NUMBOR <> '" + SE2->E2_NUMBOR + "' ) AND "
				EndIf
				cQuery += " E2_APLVLMN <> '2' AND "
				cQuery += " SE2.D_E_L_E_T_ = ' ' "
			Else

				cQuery := " SELECT E1_VALOR, E1_PIS,E1_COFINS,E1_CSLL,E1_IRRF,E1_SABTPIS,E1_SABTCOF,E1_SABTCSL,E1_SALDO,E1_TIPOLIQ,"
				cQuery += "	E1_PREFIXO,E1_NUM, E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA,E1_NATUREZ,E1_MOEDA,E1_TXMOEDA,E1_VENCREA, "
				cQuery += " SED.ED_CALCPIS , SED.ED_PERCPIS, SED.ED_CALCCOF , SED.ED_PERCCOF, SED.ED_CALCCSL, SED.ED_PERCCSL, SE1.E1_NUMLIQ,"
				cQuery += " SE1.E1_FATURA, SE1.E1_NUMBOR,"
				cQuery += " SE1.E1_BASEPIS, E1_BASECOF, E1_BASECSL,E1_ORIGEM, SE1.R_E_C_N_O_ RECNO FROM "
				cQuery += RetSqlName( "SE1" ) + " SE1 "
				cQuery += " INNER JOIN " + RetSqlName( "SED" ) + " SED ON "

				If !Empty(FWFilial("SE1")) .And. !Empty(FWFilial("SED"))
					cQuery += " SE1.E1_FILIAL = SED.ED_FILIAL AND "
				Else
					cQuery += " SED.ED_FILIAL = '" + xFilial( "SED" , cFilOrig ) + "' AND "
				EndIf

				cQuery += "  SE1.E1_NATUREZ = SED.ED_CODIGO AND "
				cQuery += "  (SED.ED_CALCPIS = 'S' OR SED.ED_CALCCOF = 'S' OR SED.ED_CALCCSL = 'S') AND SED.D_E_L_E_T_ = ' ' "
				If lFina891
					cQuery += "  LEFT JOIN "+ RetSqlName( "SEA" ) + " SEA ON "
				Else
					cQuery += "  INNER JOIN "+ RetSqlName( "SEA" ) + " SEA ON "
				EndIf

				If !Empty(FWFilial("SE1")) .And. !Empty(FWFilial("SEA"))
					cQuery += " SE1.E1_FILIAL = SEA.EA_FILIAL AND "
				EndIf

				cQuery += " SE1.E1_NUMBOR = SEA.EA_NUMBOR AND SEA.EA_CART = 'R' AND SEA.D_E_L_E_T_ = ' ' "
				cQuery += " AND SE1.E1_PREFIXO = SEA.EA_PREFIXO "
				cQuery += " AND SE1.E1_NUM = SEA.EA_NUM "
				cQuery += " AND SE1.E1_PARCELA = SEA.EA_PARCELA "
				cQuery += " AND SE1.E1_TIPO = SEA.EA_TIPO "


				cQuery += 	" WHERE E1_FILIAL IN (" + cFilE1
				cQuery += 	" ) AND "

				If Len(aCliFor) > 0
					//Verificar determinados fornecedores (raiz do CNPJ)
					cQuery += "( "
					For nKco := 1 to Len(aCliFor)
						cQuery += "(E1_CLIENTE ='"   + aCliFor[nKco,1]  + "' AND "
						cQuery += "E1_LOJA='"       + aCliFor[nKco,2]  + "') OR "
					Next nKco

					cQuery := Left( cQuery, Len( cQuery ) - 4 )
					cQuery += ") AND "
				Else  //Apenas o Fornecedor Atual
					cQuery += "E1_CLIENTE='"+ cCodigo+ "' AND "
					If lLojaAtu  //Considero apenas a loja atual
						cQuery += "E1_LOJA ='"+cLoja+ "' AND "
					Endif
				EndIf

				If (!lFina061 .And. !Empty(SE1->E1_NUMBOR)) .or. !lFina891 //Não considera o título posicionado que está sendo baixado pelo FINA070/110.
					cQuery += " NOT (E1_FILIAL = '"+SE1->E1_FILIAL+"' AND "
					cQuery += " E1_PREFIXO = '"+SE1->E1_PREFIXO+"' AND "
					cQuery += " E1_NUM = '"+SE1->E1_NUM+"' AND "
					cQuery += " E1_PARCELA = '"+SE1->E1_PARCELA+"' AND "
					cQuery += " E1_TIPO = '"+SE1->E1_TIPO+"' AND "
					cQuery += " E1_CLIENTE = '"+SE1->E1_CLIENTE+"' AND "
					cQuery += " E1_LOJA = '"+SE1->E1_LOJA+"') AND "
				EndIf

				if SEA->( FieldPos("EA_ORIGEM") ) > 0 .and. !lFina891
					cQuery += " EA_ORIGEM = '" + PADR("FINA061",TamSX3("EA_ORIGEM")[1])  + "' AND "
				Endif
				If !lFina891
					cQuery += 	  " E1_DATABOR = '" + DToS( dRef )      + "' AND "
				Else
					cFilSA1 := AllTrim(xFilial("SA1",SE1->E1_FILIAL))
					cQuery += "E1_PREFIXO || E1_NUM || E1_PARCELA || E1_TIPO || E1_CLIENTE || E1_LOJA "
					cQuery += "IN ( "
					cQuery +=		"SELECT F71_PREFIX||F71_NUM||F71_PARCEL||F71_TIPO||F71_CODCLI||F71_LOJCLI "
					cQuery +=		"FROM " +RetSqlName("F71")+ " "
					cQuery +=		"WHERE F71_VLRPIX > 0 "
					cQuery +=			"AND F71_CODCLI = '" + SE1->E1_CLIENTE + "' "
					cQuery +=			"AND F71_LOJCLI = '" + SE1->E1_LOJA    + "' "
					cQuery +=			"AND F71_DTPSP  = '" + DToS( dRef )    + "' "
					cQuery +=			"AND F71_STATUS <> '7' "
					cQuery +=			"AND D_E_L_E_T_ = ' ' AND "
					If Len(cFilSA1) > 0
						If AllTrim(Upper(TcGetDB())) == "ORACLE"
							cQuery +=		"SUBSTR( "
						Else	// POSTGRES|MSSQL
							cQuery +=		"SUBSTRING( "
						EndIf
						cQuery +=			"F71_FILIAL,1," +cValToChar(Len(cFilSA1))
						cQuery +=			") = '" + cFilSA1 + "' "
						cQuery += ") AND "
					EndIf
				EndIf
				cQuery += " E1_TIPO NOT IN " + FormatIn(MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVENVBCOR,"/")
				If !lFina891
					cQuery += "	AND (E1_SALDO>0 OR E1_NUMBOR <> '"+Space(TamSX3("E1_NUMBOR")[1])+"')  "
					cQuery += " AND E1_PORTADO <> ' ' "
				Else
					cQuery += "	AND E1_SALDO>0 "
				EndIf

				If lFina061
					cQuery += "AND (SE1.R_E_C_N_O_ < "+alltrim(STR(SE1->(RECNO())))+" OR 	"
					cQuery += " SE1.E1_NUMBOR <> '"+SE1->E1_NUMBOR+"' )  "
				ElseIf lFina891
					cQuery += "AND SE1.R_E_C_N_O_ < "+alltrim(STR(SE1->(RECNO())))
				Endif

				cQuery += " AND E1_APLVLMN <> '2' AND "
				cQuery += " SE1.D_E_L_E_T_ = ' ' "

			EndIf

			If cCart == "P" .And. lF241QRY2 .And. (lFina241 .or. lFina080)
				cQuery	+= ExecBlock("F241QRY2",.F.,.F., {cQuery})
			EndIf

			cQuery := ChangeQuery( cQuery )

			If Select(cAliasQry) > 0
				( cAliasQry )->( dbCloseArea() )
			Endif

			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

			While !( cAliasQry )->( Eof())

				nSaldo := IIF(cCart == "P",(cAliasQry)->E2_SALDO, (cAliasQry)->E1_SALDO )
				lLiqFat := IIF(cCart == "P",(!Empty((cAliasQry)->E2_FATURA) .Or. !Empty((cAliasQry)->E2_NUMLIQ)), (!Empty((cAliasQry)->E1_FATURA) .Or. !Empty((cAliasQry)->E1_NUMLIQ)) )

				nBasePis := IIF(cCart=="P", (cAliasQry)->E2_BASEPIS, IIF(!Empty((cAliasQry)->E1_BASEPIS),(cAliasQry)->E1_BASEPIS, (cAliasQry)->E1_VALOR))
				nBaseCof := IIF(cCart=="P", (cAliasQry)->E2_BASECOF, IIF(!Empty((cAliasQry)->E1_BASECOF),(cAliasQry)->E1_BASECOF, (cAliasQry)->E1_VALOR))
				nBaseCsl := IIF(cCart=="P", (cAliasQry)->E2_BASECSL, IIF(!Empty((cAliasQry)->E1_BASECSL),(cAliasQry)->E1_BASECSL, (cAliasQry)->E1_VALOR))

				If cCart == "P"
					aPercPcc := GetPerPCC( (cAliasQry)->E2_NATUREZ, (cAliasQry)->E2_ORIGEM, cCart, (cAliasQry)->RECNO, lPCCBaixa )
				Else
					aPercPcc := GetPerPCC( (cAliasQry)->E1_NATUREZ, (cAliasQry)->E1_ORIGEM, cCart, (cAliasQry)->RECNO, lPCCBaixa )
				EndIf

				If (cAliasQry)->ED_CALCPIS == "S" .and. Iif(cCart == "P",SA2->A2_RECPIS == '2',SA1->A1_RECPIS $ 'S|P')
					nPisAux := ( nBasePis * aPercPcc[1] ) / 100
					nTCalcPis += nPisAux
				EndIf

				If (cAliasQry)->ED_CALCCOF == "S" .and. Iif(cCart == "P",SA2->A2_RECCOFI == '2',SA1->A1_RECCOFI $ 'S|P')
					nCofAux := ( nBaseCof * aPercPcc[2] ) / 100
					nTCalcCof += nCofAux
				EndIf

				If (cAliasQry)->ED_CALCCSL == "S" .and. Iif(cCart == "P",SA2->A2_RECCSLL == '2',SA1->A1_RECCSLL $ 'S|P')
					nCslAux := ( nBaseCsl * aPercPcc[3] ) / 100
					nTCalcCsl += nCslAux
				EndIf

				//Total Retido
				If cCart == "P"
					If (cAliasQry)->E2_PRETPIS $ "3|4|7" .Or. (EMPTY((cAliasQry)->E2_PRETPIS) .And.  (cAliasQry)->E2_VRETPIS > 0)
						nTotRtPis += (cAliasQry)->E2_VRETPIS
					Else
						//Variaveis utilizadas na reestruturação da SE5
						nPisBaseR += nBasePis

						cChaveTit := xFilial("SE2", cFilOrig) + "|" + (cAliasQry)->E2_PREFIXO + "|" + (cAliasQry)->E2_NUM + "|" + (cAliasQry)->E2_PARCELA + "|" + (cAliasQry)->E2_TIPO + "|" + (cAliasQry)->E2_FORNECE+ "|" + (cAliasQry)->E2_LOJA
						cChaveFK7 := FINBuscaFK7(cChaveTit, "SE2")

						AADD(aTitCalc,{"FK7", cChaveFK7})
					EndIf

					If (cAliasQry)->E2_PRETCOF $ "3|4|7" .OR. (EMPTY((cAliasQry)->E2_PRETCOF) .And.  (cAliasQry)->E2_VRETCOF > 0)
						nTotRtCof += (cAliasQry)->E2_VRETCOF
					Else
						//Variaveis utilizadas na reestruturação da SE5
						nCofBaseR += nBaseCof
					EndIf

					If (cAliasQry)->E2_PRETCSL $ "3|4|7" .OR. (EMPTY((cAliasQry)->E2_PRETCSL) .And.  (cAliasQry)->E2_VRETCSL > 0)
						nTotRtCsl += (cAliasQry)->E2_VRETCSL
					Else
						//Variaveis utilizadas na reestruturação da SE5
						nCslBaseR += nBaseCsl
					EndIf
				Else
					cChaveTit := xFilial("SE1", cFilOrig) + "|" + (cAliasQry)->E1_PREFIXO + "|" + (cAliasQry)->E1_NUM + "|" + (cAliasQry)->E1_PARCELA + "|" + (cAliasQry)->E1_TIPO + "|" + (cAliasQry)->E1_CLIENTE+ "|" + (cAliasQry)->E1_LOJA
					cChaveFK7 := FINBuscaFK7(cChaveTit, "SE1")
					lTitCalc := .F.

					// Verifica se houve retenção de PCC no titulo gerado pelo bordero para subtrair no valor a reter
					If (cAliasQry)->E1_PIS > 0
						nValRetBd := getValorTx(cFil,cChave,"PIS","PIS","",dRef,cCart,nTamPrfTit)
						nTotRtPis += nValRetBd
						If nValRetBd == 0 .and. FBrdPdRet("PIS", aTitCalc, cFilOrig, cChaveFK7, dRef, @lTitCalc )
							nPisBaseR += nBasePis
						Endif
					Else
						//Variaveis utilizadas na reestruturação da SE5
						nPisBaseR += nBasePis
						AADD(aTitCalc,{"FK7", cChaveFK7})
						lTitCalc := .T.
					EndIf

					If (cAliasQry)->E1_COFINS > 0
						nValRetBd := getValorTx(cFil,cChave,"COF","COF","",dRef,cCart,nTamPrfTit)
						nTotRtPis += nValRetBd
						If nValRetBd == 0 .and. FBrdPdRet("COF", aTitCalc, cFilOrig, cChaveFK7, dRef, @lTitCalc )
							nCofBaseR += nBaseCof
						Endif
					Else
						//Variaveis utilizadas na reestruturação da SE5
						nCofBaseR += nBaseCof
						If !lTitCalc
							AADD(aTitCalc,{"FK7", cChaveFK7})
							lTitCalc := .T.
						Endif
					EndIf

					If (cAliasQry)->E1_CSLL > 0
						nValRetBd := getValorTx(cFil,cChave,"CSL","CSL","",dRef,cCart,nTamPrfTit)
						nTotRtCsl += nValRetBd
						If nValRetBd == 0 .and. FBrdPdRet("CSL", aTitCalc, cFilOrig, cChaveFK7, dRef, @lTitCalc )
							nCslBaseR += nBaseCsl
						Endif
					Else
						//Variaveis utilizadas na reestruturação da SE5
						nCslBaseR += nBaseCsl
						If !lTitCalc
							AADD(aTitCalc,{"FK7", cChaveFK7})
							lTitCalc := .T.
						Endif
					EndIf
				EndIf

				(cAliasQry)->(DbSkip())
			EndDo
		EndIf

		If Select(cAliasQry) > 0
			( cAliasQry )->( dbCloseArea() )
		Endif

		//-------------------------------------------------------------------------------------------------------
		//Tratamento para PCC cumulatividade de Pagamento Antecipado MVPAGANT sem movimentação bancaria.
		//-------------------------------------------------------------------------------------------------------
		If cCart == "P" .And. lPCCBaixa
			cQuery := "SELECT E2_VALOR,E2_PIS,E2_COFINS,E2_EMISSAO,E2_CSLL,E2_ISS,E2_INSS,E2_IRRF,E2_VRETPIS,E2_VRETCOF, "
			cQuery += "E2_BASEPIS, E2_BASECOF, E2_BASECSL, E2_ORIGEM, "
			cQuery += "SED.ED_CALCPIS , SED.ED_PERCPIS, SED.ED_CALCCOF , SED.ED_PERCCOF, SED.ED_CALCCSL , SED.ED_PERCCSL, "
			cQuery += "E2_APLVLMN,E2_VRETCSL,E2_PRETPIS,E2_PRETCOF,E2_PRETCSL,E2_VRETIRF,"
			cQuery += "E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_NATUREZ,SE2.R_E_C_N_O_ RECNOSE2 FROM "
			cQuery += RetSqlName( "SE2" ) + " SE2 "
			cQuery += " INNER JOIN " + RetSqlName( "SED" ) + " SED ON "

			If !Empty(FWFilial("SE2")) .And. !Empty(FWFilial("SED"))
				cQuery += " SE2.E2_FILIAL = SED.ED_FILIAL AND "
			Else
				cQuery += " SED.ED_FILIAL = '" + xFilial( "SED" , cFilOrig ) + "' AND "
			EndIf

			cQuery += "  SE2.E2_NATUREZ = SED.ED_CODIGO AND "
			cQuery += "  (SED.ED_CALCPIS = 'S' OR SED.ED_CALCCOF = 'S' OR SED.ED_CALCCSL = 'S') AND SED.D_E_L_E_T_ = ' ' "

            cQuery += " WHERE " + SetUpQry("E2_FILIAL") + " IN (" + cFiliais + ") AND "

			cQuery += " E2_TIPO IN " + FormatIn(MVPAGANT,cSepPag) + " AND "
			cQuery += "	E2_APLVLMN <> '2' AND "

			If Len(aCliFor) > 0
				//Verificar determinados fornecedores (raiz do CNPJ)
				cQuery += "( "
				For nKco := 1 to Len(aCliFor)
					cQuery += "(E2_FORNECE ='"   + aCliFor[nKco,1]  + "' AND "
					cQuery += "E2_LOJA='"       + aCliFor[nKco,2]  + "') OR "
				Next nKco

				cQuery := Left( cQuery, Len( cQuery ) - 4 )
				cQuery += ") AND "
			Else  //Apenas o Fornecedor Atual
				cQuery += "E2_FORNECE='"+ cCodigo+ "' AND "
				If lLojaAtu  //Considero apenas a loja atual
					cQuery += "E2_LOJA ='"+cLoja+ "' AND "
				EndIf
			Endif

			If nVencto == 2
				cQuery += "E2_VENCREA  = '" + DToS( dRef )      + "' AND "
			ElseIf nVencto == 1 .OR. EMPTY(nVencto)
				cQuery += "E2_EMISSAO = '" + DToS( dRef )      + "' AND "
			ElseIf nVencto == 3
				cQuery += "E2_EMIS1  = '" + DToS( dRef )      + "' AND "
			Endif

			If lFatCom //Não considera o título posicionado que está sendo gravado pelo compras/faturamento.
				cQuery += " NOT (E2_FILIAL = '"+SE2->E2_FILIAL+"' AND "
				cQuery += " E2_PREFIXO = '"+SE2->E2_PREFIXO+"' AND "
				cQuery += " E2_NUM = '"+SE2->E2_NUM+"' AND "
				cQuery += " E2_PARCELA = '"+SE2->E2_PARCELA+"' AND "
				cQuery += " E2_TIPO = '"+SE2->E2_TIPO+"' AND "
				cQuery += " E2_FORNECE = '"+SE2->E2_FORNECE+"' AND "
				cQuery += " E2_LOJA = '"+SE2->E2_LOJA+"') AND "
			EndIf

			cQuery += " E2_DESDOBR <> 'S' AND "
			cQuery += " SE2.D_E_L_E_T_ = ' ' "

			// Filtra PA com Movimentação bancaria.
			cQuery += "AND NOT EXISTS ( "
			cQuery += "SELECT SE5.E5_NUMERO "
			cQuery += "FROM "+RetSqlName("SE5")+" SE5 "
			cQuery += "WHERE SE5.E5_FILIAL IN ("+ cFiliais
			cQuery += ") AND "
			cQuery +=		"SE5.E5_PREFIXO=SE2.E2_PREFIXO AND "
			cQuery +=		"SE5.E5_NUMERO=SE2.E2_NUM AND "
			cQuery +=		"SE5.E5_PARCELA=SE2.E2_PARCELA AND "
			cQuery +=		"SE5.E5_TIPO=SE2.E2_TIPO AND "
			cQuery +=		"SE5.E5_CLIFOR=SE2.E2_FORNECE AND "
			cQuery +=		"SE5.E5_LOJA=SE2.E2_LOJA AND "
			cQuery +=		"SE5.E5_TIPODOC<>'ES' AND "
			cQuery +=		"SE5.E5_RECPAG='P' AND "
			cQuery +=		"SE5.D_E_L_E_T_ = ' ')"

			cQuery := ChangeQuery( cQuery )

			If Select(cAliasQry) > 0
				( cAliasQry )->( dbCloseArea() )
			EndIf

			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

			While !( cAliasQry )->( Eof())

				If lFINEXEC
					lRet := ExecBlock("FINEXEC",.F.,.F.,{cAliasQry})
					If lRet
						(cAliasQry)->(DbSkip())
						Loop
					Endif
				EndIf

				nBasePis := (cAliasQry)->E2_BASEPIS
				nBaseCof := (cAliasQry)->E2_BASECOF
				nBaseCsl := (cAliasQry)->E2_BASECSL

				// Percentual
				aPercPcc := GetPerPCC( (cAliasQry)->E2_NATUREZ, (cAliasQry)->E2_ORIGEM, cCart, (cAliasQry)->RECNOSE2, lPCCBaixa )

				//Total Calculado
				If (cAliasQry)->ED_CALCPIS == "S" .and. SA2->A2_RECPIS == '2'
					nPisAux := ( nBasePis * aPercPcc[1] ) / 100
					nTCalcPis += nPisAux
				EndIf

				If (cAliasQry)->ED_CALCCOF == "S" .and. SA2->A2_RECCOFI == '2'
					nCofAux := ( nBaseCof * aPercPcc[2] ) / 100
					nTCalcCof += nCofAux
				EndIf

				If (cAliasQry)->ED_CALCCSL == "S" .and. SA2->A2_RECCSLL == '2'
					nCslAux := ( nBaseCsl * aPercPcc[3] ) / 100
					nTCalcCsl += nCslAux
				EndIf
				lTitCalc := .F.
				
				//Total Retido
				If (cAliasQry)->E2_PRETPIS $ "3|4|7" .Or. (EMPTY((cAliasQry)->E2_PRETPIS) .And.  (cAliasQry)->E2_VRETPIS > 0)
					nTotRtPis += (cAliasQry)->E2_VRETPIS
				Else
					//Variaveis utilizadas na reestruturação da SE5
					nPisBaseR += nBasePis
					If !lTitCalc
						cChaveTit := xFilial("SE2", cFilOrig) + "|" + (cAliasQry)->E2_PREFIXO + "|" + (cAliasQry)->E2_NUM + "|" + (cAliasQry)->E2_PARCELA + "|" + (cAliasQry)->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
						cChaveFK7 := FINBuscaFK7(cChaveTit, "SE2") 
						AADD(aTitCalc,{"SE2", cChaveFK7})
						lTitCalc := .T.
					EndIf
				EndIf
				If (cAliasQry)->E2_PRETCOF $ "3|4|7" .OR. (EMPTY((cAliasQry)->E2_PRETCOF) .And.  (cAliasQry)->E2_VRETCOF > 0)
					nTotRtCof += (cAliasQry)->E2_VRETCOF
				Else
					//Variaveis utilizadas na reestruturação da SE5
					nCofBaseR += nBaseCof
					If !lTitCalc
						cChaveTit := xFilial("SE2", cFilOrig) + "|" + (cAliasQry)->E2_PREFIXO + "|" + (cAliasQry)->E2_NUM + "|" + (cAliasQry)->E2_PARCELA + "|" + (cAliasQry)->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
						cChaveFK7 := FINBuscaFK7(cChaveTit, "SE2") 
						AADD(aTitCalc,{"SE2", cChaveFK7})
						lTitCalc := .T.
					Endif
				EndIf
				If (cAliasQry)->E2_PRETCSL $ "3|4|7" .OR. (EMPTY((cAliasQry)->E2_PRETCSL) .And.  (cAliasQry)->E2_VRETCSL > 0)
					nTotRtCsl += (cAliasQry)->E2_VRETCSL
				Else
					//Variaveis utilizadas na reestruturação da SE5
					nCslBaseR += nBaseCsl
					If !lTitCalc
						cChaveTit := xFilial("SE2", cFilOrig) + "|" + (cAliasQry)->E2_PREFIXO + "|" + (cAliasQry)->E2_NUM + "|" + (cAliasQry)->E2_PARCELA + "|" + (cAliasQry)->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
						cChaveFK7 := FINBuscaFK7(cChaveTit, "SE2") 
						AADD(aTitCalc,{"SE2", cChaveFK7})
						lTitCalc := .T.
					Endif
				EndIf

				(cAliasQry)->(DbSkip())
			EndDo

		EndIf

		If Select(cAliasQry) > 0
			( cAliasQry )->( dbCloseArea() )
		Endif

		nPisAux := nTCalcPis - nTotRtPis
		nPis := Iif( lRoundPis, Round(nPisAux,2), NoRound(nPisAux,2) )
		
		nCofAux := nTCalcCof - nTotRtCof
		nCof := Iif( lRoundCof, Round(nCofAux,2), NoRound(nCofAux,2) )
		
		nCslAux := nTCalcCsl - nTotRtCsl
		nCsl := Iif( lRoundCsl, Round(nCslAux,2), NoRound(nCslAux,2) )

		aDados[1] := nPis
		aDados[2] := nCof
		aDados[3] := nCsl

		/* Verifica Valor Minimo? 
			ALTERACAO - Não vejo o mínimo caso já tenha valores retidos anteriormente.
			BAIXA - não conseguiu reter tudo na baixa anterior.
		*/
		If ( !lAltEmi .Or. !lPenTxR ) .And. (nTotRtPis > 0 .and. nTotRtCof > 0 .and. nTotRtCsl > 0)
			aDados[4] := .F.
		Else
			aDados[4] := .T.
		EndIf

		//Armazena os valores já retidos (tratamento cumulatividade PCC Individual)
		aDados[5] := nTotRtPis
		aDados[6] := nTotRtCof
		aDados[7] := nTotRtCsl

		If __oQryCP <> NIL
			__oQryCP:Destroy()
			__oQryCP := NIL
		Endif

		If __oQryCR <> NIL
			__oQryCR:Destroy()
			__oQryCR := NIL
		Endif
		
		RestArea(aArSE2)
		RestArea(aArSE5)
		RestArea(aAreaAt)
		
		FwFreeArray(aArSA1)
		FwFreeArray(aArSE2)
		FwFreeArray(aArSE1)
		FwFreeArray(aArSE5)
		FwFreeArray(aAreaAt)
	EndIf
Return aDados


//-------------------------------------------------------------------
/*/{Protheus.doc}getCliFor
Verificar os clientes/fornecedores que serão considerados na cumulatividade

@param cCart - Carteira P = Pagar, R = Receber
@param cFil - Filial
@param cCodCF - Código do Cliente/Forn.
@param cLojaCF - Loja do Cliente/Forn.
@param aFil - Filial que será considerado na cumulatividades

@return aCliFor - Retorna os clientes/fornecedores que serão considerados na cumulatividade

@author Caique Ferreira
@since  20/07/2015
/*/
//-------------------------------------------------------------------

Function getCliFor(cCart,cFil, cCodCF, cLojaCF ,aFil)
	Local aAreaAt		:= getArea()
	Local aAreCF		:= IIF(cCart=="P", SA2->(getArea()), SA1->(getArea()))
	Local aCliFor		:= {}
	Local aFil13137	:= {}

	Local cAglutFil	:= SuperGetMV("MV_PCCAGFL",,"1")
	Local cAglutPCC	:= SuperGetMV("MV_PCCAGFR",,"1")
	Local cAglutCli	:= SuperGetMV("MV_PCCAGCL",,"1")
	Local cForTipo 	:= ""
	Local cCliPessoa	:= ""
	Local cCgc			:= ""
	Local cCGCSM0		:= ""
	Local cEmpAtu 	:= ""
	Local cFilBusca	:= ""

	Local lConsFil	:=   SuperGetMv("MV_CONSFIL",.F.,.F.)
	Local lMt103frt 	:= ExistBlock("MT103FRT")
	Local nKco			:= 0
	Local cFilBkcp := cFilAnt

	Default cCart		:= "P"

	Default cFil		:= {}
	Default cCodCF	:= ""
	Default cLojaCF	:= ""

	If cCart == "P"
		aFil13137 := {}
		aAreaSA2  := SA2->(GetArea())

		DbSelectArea("SA2")
		SA2->(DbSetOrder(1))
		SA2->(MsSeek(cFil+ cCodCF+ cLojaCF))

		aAreaSM0 := SM0->(GetArea())
		If !Empty(cCgc := SA2->A2_CGC)
			cForTipo := SA2->A2_TIPO
			SA2->(DbSetOrder(3))
			cEmpAtu  := SM0->M0_CODIGO
			cCGCSM0  := SM0->M0_CGC
			SM0->(DbSetOrder(1))
			SM0->(MsSeek(cEmpAnt))
		Else
			aFil13137 := { cFilant }
		EndIf

		//Se parametro "MV_PCCAGFR" existe com conteudo diferente de 1
		If cAglutFil == "2" .Or. cAglutFil == "3"
			Do While !SM0->(Eof()) .And. SM0->M0_CODIGO == cEmpAtu
				//Verifica se a filial tem o mesmo CGC/Raiz de CGC
				If (cAglutFil == "2" .And. cCGCSM0 == SM0->M0_CGC) .Or. (cAglutFil == "3" .And. Left(cCGCSM0,8) == Left(SM0->M0_CGC,8))
					//Verifica se na filial existe cliente de mesmo CGC/Raiz de CGC
					cFilBusca := FWGETCODFILIAL
					If (cAglutPCC != "2" .And. cAglutPCC != "3") .Or. (SA2->(MsSeek(xFilial("SA2",cFilBusca)+Left(cCgc,Iif(cForTipo != "F" .And. cAglutPCC == "3",8,14)))) .And. cForTipo == SA2->A2_TIPO)
						AAdd(aFil13137,cFilBusca)
					EndIf
				EndIf
				SM0->(DbSkip())
			EndDo

		//Verifico todas as filiais apenas quando SA2 compartilhado
		ElseIf lMt103frt
			aFil13137 := ExecBlock( "MT103FRT", .F., .F. )
		Else
			If !Empty (FwFilial("SE2")) .And. lConsFil
				aFil13137 := FAFIL10925()
			Else
				aFil13137 := { cFilAnt }
			Endif
		Endif

		If Len(aFil13137) == 0
			aFil13137 := { cFilBkcp }
		EndIf

		aFil := aClone(aFil13137)

		For nKco := 1 to Len(aFil13137)

			If !Empty(cCgc) .And. ( cAglutPCC == "2" .Or. cAglutPCC == "3" )
				aAreaSA2 := SA2->(GetArea())
				SA2->(DbSetOrder(3))
				SA2->(MsSeek(xFilial("SA2")+Left(cCgc,8)))
				aCliFor := {}
				Do While !SA2->(Eof()) .And. xFilial("SA2")+Left(cCgc,8) == SA2->A2_FILIAL+Left(SA2->A2_CGC,8)
					//Mesmo tipo de Fornecedor e Novo no vetor
					If cForTipo == SA2->A2_TIPO .And. AScan(aCliFor,{|x| x[1]+x[2] == SA2->(A2_COD+A2_LOJA) }) == 0
						//Nao pode ser pessoa fisica e aglutina por Raiz de CNPJ
						If cForTipo != "F" .And. cAglutPCC == "3" .And. Left(SA2->A2_CGC,8) == Left(cCgc,8)
							SA2->(AAdd(aCliFor,{A2_COD,A2_LOJA}))
						//Pessoa Fisica ou aglutina por CPF/CNPJ identico
						ElseIf ( cForTipo == "F" .Or. cAglutPCC == "2" ) .And. SA2->A2_CGC == cCgc
							SA2->(AAdd(aCliFor,{A2_COD,A2_LOJA}))
						EndIf
					EndIf
					SA2->(DbSkip())
				EndDo
				SA2->(RestArea(aAreaSA2))
			EndIf
		Next nKco
	Else
		aFil13137 := {}
		aAreaSA1  := SA1->(GetArea())

		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(MsSeek(cFil+ cCodCF+ cLojaCF))

		aAreaSM0 := SM0->(GetArea())
		If !Empty(cCgc := SA1->A1_CGC)
			cCliPessoa := SA1->A1_PESSOA
			SA1->(DbSetOrder(3))
			cEmpAtu  := SM0->M0_CODIGO
			cCGCSM0  := SM0->M0_CGC
			SM0->(DbSetOrder(1))
			SM0->(MsSeek(cEmpAnt))
		Else
			aFil13137 := { cFilant }
		EndIf

		If cAglutFil == "2" .Or. cAglutFil == "3"

			Do While !SM0->(Eof()) .And. SM0->M0_CODIGO == cEmpAtu
				//Verifica se a filial tem o mesmo CGC/Raiz de CGC
				If (cAglutFil == "2" .And. cCGCSM0 == SM0->M0_CGC) .Or. (cAglutFil == "3" .And. Left(cCGCSM0,8) == Left(SM0->M0_CGC,8))
					//Verifica se na filial existe fornecedor de mesmo CGC/Raiz de CGC
					cFilBusca := FWGETCODFILIAL
					If (cAglutCli != "2" .And. cAglutCli != "3") .Or. (SA1->(MsSeek(xFilial("SA1",cFilBusca)+Left(cCgc,Iif(cAglutCli == "3" .And. cCliPessoa == "J",8,14)))) .And. cCliPessoa == SA1->A1_PESSOA)
						AAdd(aFil13137,cFilBusca)
					EndIf
				EndIf
				SM0->(DbSkip())
			EndDo

		//Verifico todas as filiais apenas quando SA1 compartilhado
		ElseIf lMt103frt
			aFil13137 := ExecBlock( "MT103FRT", .F., .F. )
		Else
			aFil13137 := { cFilant }
		Endif

		If Len(aFil13137) == 0
			aFil13137 := { cFilBkcp }
		EndIf

		aFil := aClone(aFil13137)

		For nKco := 1 to Len(aFil13137)

			dbSelectArea("SE5")
			cFilAnt := aFil13137[nKco]

			If !Empty(cCgc) .And. ( cAglutCli == "2" .Or. cAglutCli == "3" )
				aAreaSA1 := SA1->(GetArea())
				SA1->(DbSetOrder(3))
				SA1->(MsSeek(xFilial("SA1")+Left(cCgc,8)))
				aCliFor := {}
				Do While !SA1->(Eof()) .And. xFilial("SA1")+Left(cCgc,8) == SA1->A1_FILIAL+Left(SA1->A1_CGC,8)
					//Garante o mesmo tipo de cliente e Novo no vetor
					If cCliPessoa == SA1->A1_PESSOA .And. AScan(aCliFor,{|x| x[1]+x[2] == SA1->(A1_COD+A1_LOJA) }) == 0
						//Raiz de CNPJ apenas para pessoa Juridica
						If cCliPessoa == "J" .And. cAglutCli == "3" .And. Left(SA1->A1_CGC,8) == Left(cCgc,8)
							SA1->(AAdd(aCliFor,{A1_COD,A1_LOJA}))
						//Para pessoa fisica ou CPF/CNPJ identico
						ElseIf (cCliPessoa == "F" .Or. cAglutCli == "2") .And. SA1->A1_CGC == cCgc
							SA1->(AAdd(aCliFor,{A1_COD,A1_LOJA}))
						EndIf
					EndIf
					SA1->(DbSkip())
				EndDo
				SA1->(RestArea(aAreaSA1))
			EndIf

		Next nKco

	EndIF

	cFilAnt := cFilBkcp
	RestArea(aAreaSM0)
	RestArea(aAreCF)
	RestArea(aAreaAt)

Return aCliFor


//-------------------------------------------------------------------
/*/{Protheus.doc}getValorTx
Verificar os valores dos títulos de impostos que já foram gerados

@param cFil - Filial
@param cCodLoja - Código do Cliente/Forn e Loja do Cliente/Forn.
@param cTipo - Tipo do título
@param cImp - Imposto gerado. Ex.: Pis, Cof, Csl
@param cCodRet - Código de Retenção.
@param dRef - Data de Referencia
@param cCart - Carteira P = Pagar, R = Receber
@param nTamPrfTit - Tamanho do prefixo do campo TITPAI
@param aFil - Array contendo as filiais do Grupo de Empresas.
@param lVdBor - Utilizado para verificar se há impostos já retirdos em borderô

@return aCliFor - Retorna os clientes/fornecedores que serão considerados na cumulatividade

@author Caique Ferreira
@since  20/07/2015
/*/
//-------------------------------------------------------------------

Function getValorTx(cFil,cCodLoja,cTipo,cImp,cCodRet,dRef,cCart,nTamPrfTit,aFil,lVdBor)
	Local aAreaAt		:= getArea()
	Local cAliasQry		:= GetNextAlias()
	Local cQuery		:= ""
	Local lF241QRY2		:= ExistBlock("F241QRY2")
	Local lFina241		:= FwIsInCallStack("F241Impost")
	Local lFina080		:= FwIsInCallStack("Fa080tit")
	Local nValor		:= 0
	Local cNatIRF		:= SuperGetMV("MV_IRF")
	Local lConsFil		:=   SuperGetMv("MV_CONSFIL",.F.,.F.)
	Local cFiliais		:= ""
	Local nKco			:= 0
	Local lPccBx		:= (SuperGetMv("MV_BR10925",.T.,"2") == "1")
	Local lFatCom    	:= FwIsInCallStack("MAPVLNFS") .OR. FwIsInCallStack("A103ATUSE2")// COLOCAR FAT POR PEDIDO MATA410....

	Default lVdBor		:= .T.
	Default cTipo		:= MVTAXA
	Default cImp		:= "PIS"
	Default cCodRet		:= ""
	Default cFil		:= xFilial("SE2")
	Default cCodLoja	:= ""
	Default aFil		:= {}

	// Tratamento para evitar encontrar TITPAI semalhantes, o número do título pode acabar ficando idêntico a concatenação de Forn/Cli mais loja
	Default nTamPrfTit := LenCmpTitP( cCart , Iif( cImp == "IRF" , IIf( cCart == "P" , SA2->A2_CALCIRF == "2" , FIrPjBxCr(.T.) ) , Iif( cCart == "P", SuperGetMv( "MV_BX10925" , .T. , "2" ) == "1" , SuperGetMv( "MV_BR10925" , .T. , "2" ) == "1" ) ) )

	cNatIRF := IIF('"' $ cNatIRF, &cNatIRF, cNatIRF)

	// Tratamento do parâmetro MV_CONSFIL para cumulatividade.
	If lConsFil .And. IsInCallStack("SumDay")
		If ValType(aFil) == "A" .And. !Empty(aFil)
			//aFil - Contém as filiais que serão utilizadas com base para realizar o cálculo de mínimo.
			For nKco := 1 to Len(aFil)
				cFiliais += "'"+xFilial("SE5", aFil[nKco])+"'"
				If nKco < Len(aFil)
					cFiliais += ","
				EndIf
			Next nKco
		Else
			cFiliais := "'" + cFil + "'"
		EndIf
	EndIf

	If cCart == "P" .or. (cCart == "R" .and. cTipo == MVTAXA)
		cQuery := " SELECT SUM(E2_VALOR) VALOR "
		cQuery += " FROM "+RetSQLName("SE2")+" SE2 "
		cQuery += " WHERE E2_TIPO = '"+cTipo+"'  "

		If cImp == "PIS"
			cQuery += " AND E2_NATUREZ = '"+SuperGetMV("MV_PISNAT")+"' "
		ElseIF cImp == "COF"
			cQuery += " AND E2_NATUREZ = '"+SuperGetMV("MV_COFINS")+"' "
		ElseIf cImp == "CSL"
			cQuery += " AND E2_NATUREZ = '"+SuperGetMV("MV_CSLL")+"' "
		ElseIf cImp == "IRF"
			cQuery += " AND E2_NATUREZ = '"+	cNatIRF		+"' "
		EndIf


		If !Empty(cCodRet)
			cQuery += " AND E2_CODRET = '"+cCodRet+"'"
		Else
			cQuery += " AND (E2_CODRET = '"+cCodRet+"' OR E2_CODRET ='5952') "
		EndIf

		If lConsFil .And. IsInCallStack("SumDay")
			cQuery += " AND E2_FILIAL IN (" + cFiliais + ")"
		Else
			cQuery += " AND E2_FILIAL = '"+cFil+"'  "
		EndIf

		If nTamPrfTit == 0
			cQuery += " AND E2_TITPAI LIKE '%"+cCodLoja+"%' "
		Else
			cQuery += " AND SUBSTRING( E2_TITPAI , " + cValToChar( nTamPrfTit ) + " , " + cValToChar( Len( cCodLoja ) ) + " ) = '" + cCodLoja + "'  "
		EndIf

		cQuery += " AND E2_EMISSAO = '" + DToS( dRef )   + "' " 

		If cCart == 'R'
			cQuery += " AND E2_ORIGEM IN ('FINA070', 'FINA040', 'FINA061', 'FINA460', 'FINA590', 'FINA110', 'MATA460') "
		else
			cQuery += " AND E2_ORIGEM NOT IN ('FINA070', 'FINA040', 'FINA061', 'FINA460', 'FINA590', 'FINA110', 'MATA460') "
		EndIf

		cQuery += " AND SE2.D_E_L_E_T_ = ' ' "
		If lF241QRY2 .And. (lFina241 .or. lFina080)
			cQuery	+= ExecBlock("F241QRY2",.F.,.F., {cQuery})
		Endif
	Else
		cQuery := " SELECT SUM(E1_VALOR) VALOR "
		cQuery += " FROM "+RetSQLName("SE1")+" SE1 "
		cQuery += " WHERE E1_TIPO = '"+cTipo+"'  "

		If cImp == "PIS"
			cQuery += " AND E1_NATUREZ = '"+SuperGetMV("MV_PISNAT")+"' "
		ElseIF cImp == "COF"
			cQuery += " AND E1_NATUREZ = '"+SuperGetMV("MV_COFINS")+"' "
		ElseIf cImp == "CSL"
			cQuery += " AND E1_NATUREZ = '"+SuperGetMV("MV_CSLL")+"' "
		ElseIf cImp == "IRF"
			cQuery += " AND E1_NATUREZ = '"+	cNatIRF		+"' "
		EndIf

		If lConsFil .And. IsInCallStack("SumDay")
			cQuery += " AND E1_FILIAL IN (" + cFiliais + ")"
		Else
			cQuery += " AND E1_FILIAL = '"+cFil+"' "
		EndIf

		If nTamPrfTit == 0
			cQuery += " AND E1_TITPAI LIKE '%"+cCodLoja+"%' "
		Else
			cQuery += " AND SUBSTRING( E1_TITPAI , " + cValToChar( nTamPrfTit ) + " , " + cValToChar( Len( cCodLoja ) ) + " ) = '" + cCodLoja + "'  "
		EndIf


		cQuery += " AND E1_EMIS1 = '" + DToS( dRef )      + "' "

		If lPccBx
			If cImp == "IRF"
				cQuery += " AND E1_CODRET = '" + cCodRet + "'"
			EndIf
			cQuery += " AND SE1.D_E_L_E_T_ = ' ' "
		Else
			If FwIsInCallStack("FA040Inclu")
				If !Empty(M->E1_CODRET)
					cQuery += " AND ( E1_CODRET <> ' ' AND E1_CODRET <> '5952' ) AND SE1.D_E_L_E_T_=' '"
				Else
					cQuery += " AND E1_CODRET = '" + cCodRet + "' AND SE1.D_E_L_E_T_=' '"
				EndIf
			ElseIf lFatCom
				If SED->ED_PCCINDV == '1'
					cQuery += " AND ( E1_CODRET <> ' ' AND E1_CODRET <> '5952' ) AND SE1.D_E_L_E_T_=' '"
				Else
					cQuery += " AND E1_CODRET = '" + cCodRet + "' AND SE1.D_E_L_E_T_=' '"
				EndIf
			Else
				If cImp == "IRF"
					cQuery += " AND E1_CODRET = '" + cCodRet + "'"
				EndIf
				cQuery += " AND SE1.D_E_L_E_T_ = ' ' "
			EndIf
		EndIf

	EndIf

	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

	DbSelectArea(cAliasQry)
	DbGoTop()

	While !Eof()
		TCSetField(cAliasQry, "VALOR" ,"N",16,2)
		nValor := (cAliasQry)->(VALOR)
		DbSkip()
	EndDo

	(cAliasQry)->(dbCloseArea())

	RestArea(aAreaAt)
Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc}getCodRet
Código de Retenção do PCC

@return aCliFor - Retorna o código de retenção de cada imposto.

@author Caique Ferreira
@since  20/07/2015
/*/
//-------------------------------------------------------------------
Function getCodRet()

	Local aCodRet		:= Array(3)
	Local cCodRetPis 	:= ""
	Local cCodRetCof 	:= ""
	Local cCodRetCsl 	:= ""
	Local lCodRtPCC 	:= !Empty( SE2->( FieldPos( "E2_CODRPIS" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_CODRCOF" ) ) ) .And. ;
					!Empty( SE2->( FieldPos( "E2_CODRCSL" ) ) )
	Local lEmpPublic	:= SuperGetMv("MV_ISPPUBL" ,.T.,"2") == "1"
	Local lEmissao   	:= FwIsInCallStack("FA050Nat2")

	// Caso o PCC seja Gerado na Emissão do titulo.
	// Deve referenciar os campos de Memoria, pois os campos da tabela SE2 não foram gravados.
	If lEmissao
		//Caso não tenha retenção de 1 dos 3 impostos (PIS ou COF ou CSL)
		//Atribuit o codigo de retenção padrão.
		If	((M->E2_PIS <= 0) .Or. (M->E2_COFINS <= 0) .Or. (M->E2_CSLL <= 0 )) .and. (M->(E2_PIS+E2_COFINS+E2_CSLL) > 0 )
			cCodRetPis := If (lCodRtPCC .and. !Empty(M->E2_CODRPIS),M->E2_CODRPIS,"5979")
			cCodRetCof := If (lCodRtPCC .and. !Empty(M->E2_CODRCOF),M->E2_CODRCOF,"5960")
			cCodRetCsl := If (lCodRtPCC .and. !Empty(M->E2_CODRCSL),M->E2_CODRCSL,"5987")
		Else
			// Se os 3 impostos juntos for maior que a media de retencao, o codigo sera o mesmo para os tres.
			If M->(E2_PIS+E2_COFINS+E2_CSLL) >= ((SuperGetMV("MV_VRETPIS")+SuperGetMV("MV_VRETCOF")+SuperGetMV("MV_VRETCSL")) / 3)
				cCodRetPis := If (lCodRtPCC .and. lEmpPublic .And. !Empty(M->E2_CODRPIS),M->E2_CODRPIS,"5952")
				cCodRetCof := If (lCodRtPCC .and. lEmpPublic .And. !Empty(M->E2_CODRCOF),M->E2_CODRCOF,"5952")
				cCodRetCsl := If (lCodRtPCC .and. lEmpPublic .And. !Empty(M->E2_CODRCSL),M->E2_CODRCSL,"5952")
			Endif
		EndIf
	Else
		//Caso não tenha retenção de 1 dos 3 impostos (PIS ou COF ou CSL)
		//Atribuir o codigo de retenção padrão.
		If	((SE2->E2_PIS <= 0) .Or. (SE2->E2_COFINS <= 0) .Or. (SE2->E2_CSLL <= 0 )) .and. (SE2->(E2_PIS + E2_COFINS + E2_CSLL) > 0)
			cCodRetPis := If (lCodRtPCC .and. !Empty(SE2->E2_CODRPIS),SE2->E2_CODRPIS,"5979")
			cCodRetCof := If (lCodRtPCC .and. !Empty(SE2->E2_CODRCOF),SE2->E2_CODRCOF,"5960")
			cCodRetCsl := If (lCodRtPCC .and. !Empty(SE2->E2_CODRCSL),SE2->E2_CODRCSL,"5987")
		Else
			// Se os 3 impostos juntos for maior que a media de retencao, o codigo sera o mesmo para os tres.
			If SE2->(E2_PIS+E2_COFINS+E2_CSLL) >= ((SuperGetMV("MV_VRETPIS")+SuperGetMV("MV_VRETCOF")+SuperGetMV("MV_VRETCSL")) / 3)
				cCodRetPis := If (lCodRtPCC .and. lEmpPublic .And. !Empty(SE2->E2_CODRPIS),SE2->E2_CODRPIS,"5952")
				cCodRetCof := If (lCodRtPCC .and. lEmpPublic .And. !Empty(SE2->E2_CODRCOF),SE2->E2_CODRCOF,"5952")
				cCodRetCsl := If (lCodRtPCC .and. lEmpPublic .And. !Empty(SE2->E2_CODRCSL),SE2->E2_CODRCSL,"5952")
			Endif
		Endif
	Endif

	If lEmpPublic .And. ExistBlock("FINCDRET")
		cCodRetPis := cCodRetCof := cCodRetCsl := SE2->E2_CODRET
	EndIf

	aCodRet[1]:= cCodRetPis
	aCodRet[2]:= cCodRetCof
	aCodRet[3]:= cCodRetCsl

Return aCodRet


// função de calculo sld de retenção
Function RECSLD(dRef, nValor,cNatur,cCart,cCodigo,cLoja,cTipo,lRecPis,lRecCof,lRecCsl)

	Local nCslC			:= 0
	Local nPisC			:= 0
	Local nCofC			:= 0
	Local nCslR			:= 0
	Local nPisR			:= 0
	Local nCofR			:= 0
	Local nBsRet		:= 0
	Local cFil			:= xFilial("SE2")
	Local cChave		:= ""
	Local aCodRet		:= {}
	Local lLojaAtu		:= ( GetNewPar( "MV_LJ10925", "1" ) == "1" )
	Local lPCCBaixa		:= IIF(cCart == "P", SuperGetMv("MV_BX10925",.T.,"2") == "1", SuperGetMv("MV_BR10925",.T.,"2") == "1")
	Local aDadSld		:= Array(3)
	Local nRetTot		:= 0
	Local nTamPrfTit	:= 0

	If !FwIsInCallStack("f241IMPOST") .Or. !FwIsInCallStack("fa061borde")

		aCodRet    := getCodRet()
		nTamPrfTit := LenCmpTitP( cCart , lPCCBaixa )
		If cCart == "P"
			cChave := IIF(!lPCCBaixa,cTipo,"")+cCodigo+IIF(lLojaAtu,cLoja, "")
			nPisR := getValorTx(cFil,cChave,MVTAXA,"PIS",aCodRet[1],dRef,cCart,nTamPrfTit)
			nCofR := getValorTx(cFil,cChave,MVTAXA,"COF",aCodRet[2],dRef,cCart,nTamPrfTit)
			nCslR := getValorTx(cFil,cChave,MVTAXA,"CSL",aCodRet[3],dRef,cCart,nTamPrfTit)

			nPisR += getValorTx(cFil,cChave,MVTXA ,"PIS",aCodRet[1],dRef,cCart,nTamPrfTit)
			nCofR += getValorTx(cFil,cChave,MVTXA ,"COF",aCodRet[2],dRef,cCart,nTamPrfTit)
			nCslR += getValorTx(cFil,cChave,MVTXA ,"CSL",aCodRet[3],dRef,cCart,nTamPrfTit)
		Else
			cChave := IIF(!lPCCBaixa,cTipo,"")+cCodigo+IIF(lLojaAtu,cLoja, "")
			nPisR := getValorTx(cFil,cChave,"PIS"	,"PIS","",dRef,cCart,nTamPrfTit)
			nCofR := getValorTx(cFil,cChave,"COF"	,"COF","",dRef,cCart,nTamPrfTit)
			nCslR := getValorTx(cFil,cChave,"CSL"	,"CSL","",dRef,cCart,nTamPrfTit)

			nPisR += getValorTx(cFil,cChave,MVPIABT ,"PIS","",dRef,cCart,nTamPrfTit)
			nCofR += getValorTx(cFil,cChave,MVCFABT ,"COF","",dRef,cCart,nTamPrfTit)
			nCslR += getValorTx(cFil,cChave,MVCSABT ,"CSL","",dRef,cCart,nTamPrfTit)
		Endif
		nRetTot := (nPisR + nCofR + nCslR)
		nBsRet	:= getVLRet(cFil,cNatur,cCodigo,cLoja,dRef,cCart,SE2->E2_NUMBOR)

		If lRecCsl .And. SED->ED_CALCCSL == "S" .And. SED->ED_PERCCSL > 0
			nCslC := Round((nBsRet * (SED->ED_PERCCSL / 100)),2)
		EndIf
		If lRecCof .And. SED->ED_CALCCOF == "S" .And. SED->ED_PERCCOF > 0
			nCofC := Round((nBsRet * (SED->ED_PERCCOF / 100)),2)
		EndIf
		If lRecPis .And. SED->ED_CALCPIS == "S" .And. SED->ED_PERCPIS > 0
			nPisC := Round((nBsRet * (SED->ED_PERCPIS / 100)),2)
		EndIf

		aDadSld[1]	:= nPisR - nPisC
		aDadSld[2]	:= nCofR - nCofC
		aDadSld[3]	:= nCslR - nCslC
		If aDadSld[1] < 0
			aDadSld[1]	:=	0
		Endif
		If aDadSld[2] < 0
			aDadSld[2]	:=	0
		Endif
		If aDadSld[3] < 0
			aDadSld[3]	:=	0
		Endif
	Else
		aDadSld[1]	:= 0
		aDadSld[2]	:= 0
		aDadSld[3]	:= 0

	Endif

Return aDadSld


// Rotina que tras o titulos com valores a reter no dia
Function getVLRet(cFil,cNaturez,cClifor,cLoja,dRef,cCart,cNUMBOR)

	Local cQuery		:= ""
	Local nValor		:= 0
	Local cAliasQry		:= GetNextAlias()
	Local aArea   		:= GetArea()
	Local aAreaSE2   	:= SE2->(GetArea())
	Local aAreaSE1   	:= SE1->(GetArea())
	Local lLiquido		:= IIF(cCart== "P", SuperGetMv("MV_BP10925",.F., "1") == "2", SuperGetMv("MV_BQ10925",.F., "1") == "2" ) // Default (Bruto)
	Local lFina340		:= FwIsInCallStack("Fa340Comp")

	Default cFil		:= xFilial("SE2")
	Default cNUMBOR		:= ' '
	If cCart == "P"
		cQuery := " SELECT R_E_C_N_O_ RECNO "
		cQuery += " FROM "+RetSQLName("SE2")+" SE2 "
		cQuery += " WHERE E2_FILIAL = '"+cFil+"'  "
		cQuery += " AND E2_FORNECE = '"+cClifor+"' "
		cQuery += " AND E2_LOJA = '"+cLOJA+"' "
		cQuery += " AND E2_BAIXA = '"+dToS(dRef)+"' "
		cQuery += " AND (E2_NUMBOR = ' ' "
		If ! Empty(cNUMBOR)
			cQuery += " OR E2_NUMBOR = '"+cNUMBOR+"') "
		Else
			cQuery += " ) "
		Endif
		cQuery += " AND SE2.D_E_L_E_T_ = ' ' "
		cQuery += " UNION "
		cQuery += " SELECT R_E_C_N_O_ RECNO "
		cQuery += " FROM "+RetSQLName("SE2")+" SE2 "
		cQuery += " WHERE E2_FILIAL = '"+cFil+"'  "
		cQuery += " AND E2_FORNECE = '"+cClifor+"' "
		cQuery += " AND E2_LOJA = '"+cLOJA+"' "
		cQuery += " AND E2_DTBORDE = '"+dToS(dRef)+"' "
		cQuery += " AND E2_NUMBOR <> ' ' "
		If ! Empty(cNUMBOR)
			cQuery += " AND E2_NUMBOR <> '"+cNUMBOR+"' "
		Endif
		cQuery += " AND SE2.D_E_L_E_T_ = ' ' "
	Else
		cQuery := " SELECT R_E_C_N_O_ RECNO "
		cQuery += " FROM "+RetSQLName("SE1")+" SE1 "
		cQuery += " WHERE E1_FILIAL = '"+cFil+"'  "
		cQuery += " AND E1_CLIENTE = '"+cClifor+"' "
		cQuery += " AND E1_LOJA = '"+cLOJA+"' "
		cQuery += " AND E1_BAIXA = '"+dToS(dRef)+"' "
		cQuery += " AND SE1.D_E_L_E_T_ = ' ' "

	Endif

	cQuery := ChangeQuery( cQuery )

	If Select(cAliasQry) > 0
		( cAliasQry )->( dbCloseArea() )
	Endif

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

	DbSelectArea(cAliasQry)
	DbGoTop()

	While ( cAliasQry )->(!Eof())
		If cCart == "P"
			SE2->(DbGoto(( cAliasQry )->RECNO))
			aDadosBx := retBxTit(cCart,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,"01","",dRef)
			If Empty(aDadosBx[1]).and. !lFina340
				nValor += If(SE2->E2_BASEPIS > 0,SE2->E2_BASEPIS,If(SE2->E2_BASECOF > 0,SE2->E2_BASECOF,SE2->E2_BASECSL))
			Else
				If ! Empty(SE2->E2_NUMBOR)
					nValor += aDadosBx[1] +SE2->E2_SALDO
				Else
					If lFina340 .and. SE2->E2_TIPO <> MVPAGANT .and. !Empty(aDadosBx[1])
						nValor += aDadosBx[1]
					ElseIf !lFina340
						nValor += aDadosBx[1]
					EndIf
				Endif
			Endif
		Else
			SE1->(DbGoto(( cAliasQry )->RECNO))
			aDadosBx := retBxTit(cCart,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,"01","",dRef)
			nValor += aDadosBx[1]
		Endif
		nValor += IIF(lLiquido,aDadosBx[3]+aDadosBx[4]+aDadosBx[5]+aDadosBx[6]+aDadosBx[7]+aDadosBx[7], 0)

		( cAliasQry )->(DbSkip())
	EndDo

	If Select(cAliasQry) > 0
		(cAliasQry)->(dbCloseArea())
	Endif
	RestArea(aArea)
	If cCart == "P"
		RestArea(aAreaSE2)
	Else
		RestArea(aAreaSE1)
	Endif
Return nValor


//-------------------------------------------------------------------
/*/{Protheus.doc}SLDRMSG
Valida o cancelamento do titulo se ele compoe o saldo da retenção de PCC

@param dRef - Data de Referencia
@param nValor  - Valor do cancelamento do título
@param cNatur - Natureza do título
@param cCart - Carteira P = Pagar, R = Receber
@param cCodigo - Código do Cliente/Forn
@param cLoja - Código da Loja do Cliente/Forn.
@param cTipo - Tipo do título
@param nMoedaBco - Moeda do banco listado na baixa

@return lRet - Retorna se o titulo compoe o saldo da retenção para mostrar mensagem para o usuario

@author Fernando Amorim (Cafu)
@since  24/07/2015
/*/
//-------------------------------------------------------------------
Function SLDRMSG(dRef, nValor,cNatur,cCart,cCodigo,cLoja,cTipo, nMoedaBco)

	Local nCslPer		:= 0
	Local nPisPer		:= 0
	Local nCofPer		:= 0
	Local nCslR			:= 0
	Local nPisR			:= 0
	Local nCofR			:= 0
	Local nPerTot		:= 0
	Local nRetTot		:= 0
	Local nRegra3		:= 0
	Local cFil			:= xFilial("SE2")
	Local cChave		:= ""
	Local aCodRet		:= {}
	Local lLojaAtu		:= ( GetNewPar( "MV_LJ10925", "1" ) == "1" )
	Local lPCCBaixa		:= IIF(cCart == "P", SuperGetMv("MV_BX10925",.T.,"2") == "1", SuperGetMv("MV_BR10925",.T.,"2") == "1")
	Local lRecPis		:= .F.
	Local lRecCof		:= .F.
	Local lRecCsl		:= .F.
	Local lRet			:= .F.
	Local lTemRet		:= .F.
	Local lVerMin		:= .F.
	Local nTamPrfTit	:= 0
	Local aArea 		:= {}

	Default cTipo := ""
	Default nMoedaBco := 1

	If !cTipo $ MV_CPNEG
		aArea := GetArea()
		SED->( dbSetOrder(1) )
		SED->( dbSeek(xFilial("SED") + cNatur) )

		If  cCart == "P"
			DbSelectArea("SA2")
			SA2->(DbSetOrder(1))
			SA2->(DbSeek(xFilial("SA2")+cCodigo+cLoja))
			lRecPis := SA2->A2_RECPIS == "2" //Não
			lRecCof := SA2->A2_RECCOFI == "2" //Não
			lRecCsl := SA2->A2_RECCSLL == "2" //Não
			lVerMin := SE2->E2_APLVLMN <> "2" //Diferente de Não
		Else
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial("SA1")+cCodigo+cLoja))
			lRecPis := SA1->A1_RECPIS $ "S|P" 	//Sim | Empresa Pública
			lRecCof := SA1->A1_RECCOFI $ "S|P" 	//Sim | Empresa Pública
			lRecCsl := SA1->A1_RECCSLL $ "S|P" 	//Sim | Empresa Pública
			lVerMin := SE1->E1_APLVLMN <> "2" //Diferente de Não
		Endif

		If 	lVerMin
			aCodRet    := getCodRet()
			nTamPrfTit := LenCmpTitP( cCart , lPCCBaixa )

			If cCart == "P"
				cChave := IIF(!lPCCBaixa,cTipo,"")+cCodigo+IIF(lLojaAtu,cLoja, "")
				nPisR := getValorTx(cFil,cChave,MVTAXA,"PIS",aCodRet[1],dRef,cCart,nTamPrfTit)
				nCofR := getValorTx(cFil,cChave,MVTAXA,"COF",aCodRet[2],dRef,cCart,nTamPrfTit)
				nCslR := getValorTx(cFil,cChave,MVTAXA,"CSL",aCodRet[3],dRef,cCart,nTamPrfTit)

				nPisR += getValorTx(cFil,cChave,MVTXA ,"PIS",aCodRet[1],dRef,cCart,nTamPrfTit)
				nCofR += getValorTx(cFil,cChave,MVTXA ,"COF",aCodRet[2],dRef,cCart,nTamPrfTit)
				nCslR += getValorTx(cFil,cChave,MVTXA ,"CSL",aCodRet[3],dRef,cCart,nTamPrfTit)
			Else
				cChave := IIF(!lPCCBaixa,cTipo,"")+cCodigo+IIF(lLojaAtu,cLoja, "")
				nPisR := getValorTx(cFil,cChave,"PIS"	,"PIS","",dRef,cCart,nTamPrfTit)
				nCofR := getValorTx(cFil,cChave,"COF"	,"COF","",dRef,cCart,nTamPrfTit)
				nCslR := getValorTx(cFil,cChave,"CSL"	,"CSL","",dRef,cCart,nTamPrfTit)

				nPisR += getValorTx(cFil,cChave,MVPIABT ,"PIS","",dRef,cCart,nTamPrfTit)
				nCofR += getValorTx(cFil,cChave,MVCFABT ,"COF","",dRef,cCart,nTamPrfTit)
				nCslR += getValorTx(cFil,cChave,MVCSABT ,"CSL","",dRef,cCart,nTamPrfTit)
			Endif

			nRetTot := (nPisR + nCofR + nCslR)

			If lRecCsl .And. SED->ED_CALCCSL == "S" .And. SED->ED_PERCCSL > 0
				nCslPer := SED->ED_PERCCSL
			EndIf

			If lRecCof .And. SED->ED_CALCCOF == "S" .And. SED->ED_PERCCOF > 0
				nCofPer := SED->ED_PERCCOF
			EndIf

			If lRecPis .And. SED->ED_CALCPIS == "S" .And. SED->ED_PERCPIS > 0
				nPisPer := SED->ED_PERCPIS
			EndIf

			nPerTot	:=(nCslPer+nCofPer+nPisPer)

			If nRetTot > 0 .and. nPerTot > 0
				nRegra3	:= (nRetTot * 100) / nPerTot
				nRegra3 := (nRegra3 - nValor)
				nRegra3 := (nRegra3 * nPerTot) / 100

				If cCart == "P"
					// Verifica se tem retenção no titulo posicionado
					If lPCCBaixa
						lTemRet:= ExretE5("P",SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,nMoedaBco,dRef, SE2->E2_FILORIG)
					Else
						lTemRet:= (SE2->E2_VRETPIS+SE2->E2_VRETCOF+SE2->E2_VRETCSL) > 0
					Endif
				Else
					// Verifica se tem retenção no titulo posicionado
					If lPCCBaixa
						lTemRet:= ExretE5("R",SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_MOEDA,dRef, SE1->E1_FILORIG)
					Else
						lTemRet:= (SE1->E1_PIS+SE1->E1_COFINS+SE1->E1_CSLL) > 0
					Endif
				Endif

				If !lTemRet
					lRet:= .T.
				Endif
			Endif
		Endif
		RestArea(aArea)
	EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc}ExretE5
Verificar se existe retenção de PCC no movimento vigente da SE5

@param cCart - Carteira P = Pagar, R = Receber
@param cPref - Prefixo do título
@param cNum  - numero do título
@param cParc - Parcela do título
@param cTipo - Tipo do título
@param cCliFor - Código do Cliente/Forn
@param cLoja - Código da Loja do Cliente/Forn.
@param cMoeda - Moeda do título
@param dRef - Data de Referencia

@return lRet - Retorna se existe retenção no titulo

@author Fernando Amorim (Cafu)
@since  24/07/2015
/*/
//-------------------------------------------------------------------

Function ExretE5(cCart,cPref,cNum,cParc,cTipo,cCliFor,cLoja,cMoeda,dRef,cFilOrig)

	Local cAliasQry 	:= GetNextAlias()
	Local cQuery    	:= ""
	Local lRet			:= .F.
	Local cAliasTit		:= ""
	Local cChaveFK7		:= ""

	DEFAULT cCart	  	:= ""
	DEFAULT cPref   	:= ""
	DEFAULT cNum    	:= ""
	DEFAULT cParc   	:= ""
	DEFAULT cTipo   	:= ""
	DEFAULT cCliFor 	:= ""
	DEFAULT cLoja   	:= ""
	DEFAULT cMoeda  	:= "01"
	DEFAULT dRef	  	:= CtoD("//")
	DEFAULT cFilOrig   	:= ""

	If valtype(cMoeda) == 'N'
		cMoeda	:= StrZero(cMoeda,2)
	EndIf

	If __lRpoR33 == NIL
		__lRpoR33 := GetRpoRelease() >= "12.1.033"
	EndIF

	If __lRpoR33

		cAliasTit := If (cCart == 'P', 'SE2','SE1')
		cChaveFK7 := xFilial(cAliasTit, cFilOrig) + "|" + cPref + "|" + cNum + "|" + cParc + "|" + cTipo + "|" + cCliFor + "|" + cLoja
		cChaveFK7 := FINBuscaFK7(cChaveFK7,cAliasTit)

		If cCart == 'P'
			If __oExretP == NIL
				cQuery := "SELECT FK2_FILIAL FKFILIAL, FK2_IDFK2 IDBAIXA FROM "+ RetSqlName("FK2") +" FK2 "
				cQuery += " INNER JOIN " + RetSqlName("FK4") + " FK4 "
				cQuery += 		"ON FK4.FK4_FILIAL = FK2_FILIAL "
				cQuery += 		"AND FK4.FK4_IDORIG = FK2_IDFK2 "
				cQuery += 		"AND FK4_IMPOS IN ('PIS','COF','CSL') "
				cQuery += 		"AND FK4_STATUS = '1' "
				cQuery += 		"AND FK4.D_E_L_E_T_ = ' ' "
				cQuery += "WHERE FK2_IDDOC = ? "
				cQuery += 		"AND FK2_RECPAG = 'P' "
				cQuery += 		"AND FK2_DATA = ? "
				//Não considera faturas, liquidações e devoluções
				cQuery += 		"AND FK2_MOTBX NOT IN ('FAT','LIQ','DEV') "
				cQuery += 		"AND FK2.D_E_L_E_T_ = ' ' "
				cQuery += 		"AND NOT EXISTS( "
				cQuery += 			"SELECT FK2EST.FK2_IDDOC FROM " + RetSqlName("FK2") +" FK2EST "
				cQuery += 			"WHERE FK2EST.FK2_IDDOC = ? "
				cQuery +=		 		"AND FK2EST.FK2_SEQ = FK2.FK2_SEQ "
				cQuery += 				"AND FK2EST.FK2_TPDOC = 'ES' "
				cQuery += 				"AND FK2EST.D_E_L_E_T_ = ' ') "

				cQuery 	:= ChangeQuery(cQuery)
				__oExretP:=FWPreparedStatement():New(cQuery)
			Endif

			__oExretP:SetString(1,cChaveFK7)
			__oExretP:SetString(2,DTOS(dRef))
			__oExretP:SetString(3,cChaveFK7)

			cQuery := __oExretP:GetFixQuery()

		Else
			If __oExretR == NIL
				cQuery := "SELECT FK1_FILIAL FKFILIAL, FK1_IDFK1 IDBAIXA FROM "+ RetSqlName("FK1") +" FK1 "
				cQuery += " INNER JOIN " + RetSqlName("FK4") + " FK4 "
				cQuery += 		"ON FK4.FK4_FILIAL = FK1_FILIAL "
				cQuery += 		"AND FK4.FK4_IDORIG = FK1_IDFK1 "
				cQuery += 		"AND FK4_IMPOS IN ('PIS','COF','CSL') "
				cQuery += 		"AND FK4_STATUS = '1' "
				cQuery += 		"AND FK4.D_E_L_E_T_ = ' ' "
				cQuery += "WHERE FK1_IDDOC = ? "
				cQuery += 		"AND FK1_RECPAG = 'R' "
				cQuery += 		"AND FK1_DATA = ? "
				//Não considera faturas, liquidações e devoluções
				cQuery += 		"AND FK1_MOTBX NOT IN ('FAT','LIQ','DEV') "
				cQuery += 		"AND FK1.D_E_L_E_T_ = ' ' "
				cQuery += 		"AND NOT EXISTS( "
				cQuery += 			"SELECT FK1EST.FK1_IDDOC FROM " + RetSqlName("FK1") +" FK1EST "
				cQuery += 			"WHERE FK1EST.FK1_IDDOC = ? "
				cQuery +=		 		"AND FK1EST.FK1_SEQ = FK1.FK1_SEQ "
				cQuery += 				"AND FK1EST.FK1_TPDOC = 'ES' "
				cQuery += 				"AND FK1EST.D_E_L_E_T_ = ' ') "

				cQuery 	:= ChangeQuery(cQuery)
				__oExretR:=FWPreparedStatement():New(cQuery)
			Endif

			__oExretR:SetString(1,cChaveFK7)
			__oExretR:SetString(2,DTOS(dRef))
			__oExretR:SetString(3,cChaveFK7)

			cQuery := __oExretR:GetFixQuery()

		Endif

		cAliasQry := mpsysopenquery(cQuery)

	Else
		cQuery := " SELECT SE5.E5_VRETPIS,SE5.E5_VRETCOF,SE5.E5_VRETCSL"
		cQuery += " FROM "+RetSQLName("SE5")+" SE5 "
		//Não considera deletados, estornados ou cancelados
		cQuery += " WHERE D_E_L_E_T_ = ' ' "
		cQuery += " 	AND SE5.E5_SITUACA NOT IN ( 'C' , 'E' , 'X' ) "
		cQuery += " 	AND SE5.E5_TIPODOC <> 'ES' "
		cQuery += " 	AND SE5.E5_RECPAG = '"+cCart+"' "
		//Não considera faturas, liquidações e devoluções
		cQuery += " 	AND SE5.E5_MOTBX NOT IN ('FAT','LIQ','DEV') "
		cQuery += " 	AND SE5.E5_FILIAL = '"+xFilial("SE5")+"' "
		cQuery += " 	AND SE5.E5_PREFIXO = '"+cPref+"' "
		cQuery += " 	AND SE5.E5_NUMERO = '"+cNum+"' "
		cQuery += " 	AND SE5.E5_PARCELA = '"+cParc+"' "
		cQuery += " 	AND SE5.E5_TIPO = '"+cTipo+"'  "
		cQuery += " 	AND SE5.E5_CLIFOR = '"+cCliFor+"' "
		cQuery += " 	AND SE5.E5_LOJA = '"+cLoja+"' "
		cQuery += " 	AND SE5.E5_DATA = '"+DtoS(dRef)+"'"
		cQuery += " 	AND (SE5.E5_MOEDA = '"+cMoeda+"' Or SE5.E5_MOEDA = ' ' ) "
		cQuery += " 	AND (SE5.E5_VRETPIS+SE5.E5_VRETCOF+SE5.E5_VRETCSL) > 0 "
		cQuery += " 	AND NOT EXISTS ( "
		cQuery += "SELECT A.E5_NUMERO "
		cQuery += "FROM "+RetSqlName("SE5")+" A "
		cQuery += "WHERE A.E5_FILIAL = '"+xFilial("SE5")+"' AND "
		cQuery +=  "A.E5_PREFIXO=SE5.E5_PREFIXO AND "
		cQuery +=  "A.E5_NUMERO=SE5.E5_NUMERO AND "
		cQuery +=  "A.E5_PARCELA=SE5.E5_PARCELA AND "
		cQuery +=  "A.E5_TIPO=SE5.E5_TIPO AND "
		cQuery +=  "A.E5_CLIFOR=SE5.E5_CLIFOR AND "
		cQuery +=  "A.E5_LOJA=SE5.E5_LOJA AND "
		cQuery +=  "A.E5_SEQ=SE5.E5_SEQ AND "
		cQuery +=  "A.E5_TIPODOC='ES' AND "
		If cCart == "P"
			cQuery +=  "A.E5_RECPAG<>'P' AND "
		Else
			cQuery +=  "A.E5_RECPAG<>'R' AND "
		EndIF
		cQuery +=  "A.D_E_L_E_T_ = ' ')"

		cQuery := ChangeQuery( cQuery )

		If Select(cAliasQry) > 0
			( cAliasQry )->( dbCloseArea() )
		Endif

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )
	Endif

	If ( cAliasQry )->(!Eof())
		lRet	:= .T.
	Endif

	If Select(cAliasQry) > 0
		( cAliasQry )->( dbCloseArea() )
	Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc}GetPerPCC
Verificar o percentual de cada imposto do PCC

@author Fernando Amorim (Cafu)
@since 29/07/2015
@type function

@param cNatur, characters, Código da natureza financeira
@param cOriTit, characters, Origem do título
@param cCart, characters, Carteira do título ("P" = Pagar, "R" = Receber)
@param nRecno, numeric, Recno do título
@param lPCCBaixa, logical, Indica se o PCC é na baixa

@return aRet - Vetor com os percentuais do PIS, COFINS e CSLL
@sample aRet[1] = Percentual do PIS
		aRet[2] = Percentual do COFINS
		aRet[3] = Percentual do CSLL
/*/
//-------------------------------------------------------------------
Static Function GetPerPCC(cNatur, cOriTit, cCart, nRecno, lPCCBaixa)

	Local nCalcPis	  := 0
	Local nCalcCof	  := 0
	Local nCalcCsl	  := 0
	Local aDadCalc	  := Array(6)
	Local aRet		  := Array(3)
	Local nBasePis	  := 0
	Local nBaseCof	  := 0
	Local nBaseCsl	  := 0
	Local aArea   	  := GetArea()
	Local aAreaSE2    := {}
	Local aAreaSE1    := {}
	Local aAreaSED    := {}
	Local lFatCom	  := .F.
	Local lProp		  := Iif( cCart == "P", FwIsInCallStack("SALREFPAG"), .F. )
	Local lPISDaNat   := .F.
	Local lCOFDaNat   := .F.
	Local lCSLDaNat   := .F.
	
	Default cNatur	  := ""
	Default cOriTit	  := ""
	DeFault cCart	  := ""
	Default nRecno	  := 0
	Default lPCCBaixa := .F.
	
	lFatCom	:= ( AllTrim( cOriTit ) $ "MATA461|MATA460|MATA103|MATA100|FINA631" .Or. FwIsInCallStack("MAPVLNFS") .Or. FwIsInCallStack("A103ATUSE2"))  .And. !FwIsInCallStack("FINA290")
	If ( lFatCom .And. Alltrim(cOriTit) != "FINA040" ) .Or. lProp //Origem do Titulo do Faturamento ou Compras
		If cCart == "P"
			aAreaSE2 := SE2->( GetArea() )
			SE2->( dbGoto(nRecno) )
			If (SE2->E2_PIS + SE2->E2_COFINS + SE2->E2_CSLL) > 0 .And. lPccBaixa
				nCalcPis := SE2->E2_PIS
				nCalcCof := SE2->E2_COFINS
				nCalcCsl := SE2->E2_CSLL
				nBasePis := SE2->E2_BASEPIS
				nBaseCof := SE2->E2_BASECOF
				nBaseCsl := SE2->E2_BASECSL
			ElseIf !lPccBaixa
				aDadCalc := GetCalcNt(cCart, SE2->E2_FILORIG, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_FORNECE, SE2->E2_LOJA)
				nCalcPis := aDadCalc[1]
				nCalcCof := aDadCalc[2]
				nCalcCsl := aDadCalc[3]
				nBasePis := aDadCalc[4]
				nBaseCof := aDadCalc[5]
				nBaseCsl := aDadCalc[6]
			Endif
			RestArea(aAreaSE2)
			FwFreeArray(aAreaSE2)
		Elseif cCart == "R"
			aAreaSE1 := SE1->( GetArea() )
			SE1->( dbGoto(nRecno) )
			If (SE1->E1_PIS+SE1->E1_COFINS+SE1->E1_CSLL) > 0 .And. lPccBaixa
				nCalcPis := SE1->E1_PIS
				nCalcCof := SE1->E1_COFINS
				nCalcCsl := SE1->E1_CSLL
				nBasePis := SE1->E1_BASEPIS
				nBaseCof := SE1->E1_BASECOF
				nBaseCsl := SE1->E1_BASECSL
			Else
				aDadCalc := GetCalcNt(cCart, SE1->E1_FILORIG, SE1->E1_SERIE, SE1->E1_NUM, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_PEDIDO)
				nCalcPis := aDadCalc[1]
				nCalcCof := aDadCalc[2]
				nCalcCsl := aDadCalc[3]
				nBasePis := aDadCalc[4]
				nBaseCof := aDadCalc[5]
				nBaseCsl := aDadCalc[6]
			Endif
			RestArea(aAreaSE1)
			FwFreeArray(aAreaSE1)
		Endif
	Endif
	FwFreeArray(aDadCalc)

	AFill( aRet, 0 )
	
	If ( lFatCom .And. Alltrim(cOriTit) != "FINA040" ) .Or. lProp //Origem do Titulo do Faturamento ou Compras
		If ValType(nCalcPis) == "N"
			aRet[1]	:= ( ( nCalcPis / nBasePis ) * 100 )
		Else
			lPISDaNat := .T.
		Endif

		If ValType(nCalcCof) == "N"
			aRet[2] := ( ( nCalcCof / nBaseCof ) * 100 )
		Else
			lCOFDaNat := .T.
		Endif

		If ValType(nCalcCsl) == "N"
			aRet[3]	:= ( ( nCalcCsl / nBaseCsl ) * 100 )
		Else
			lCSLDaNat := .T.
		Endif
	Else
		lPISDaNat := .T.
		lCOFDaNat := .T.
		lCSLDaNat := .T.
	Endif
	
	If lPISDaNat .Or. lCOFDaNat .Or. lCSLDaNat		
		aAreaSED := SED->( GetArea() )
		
		SED->( dbSetOrder(1) ) //ED_FILIAL+ED_CODIGO
		If SED->( msSeek( xFilial("SED") + cNatur ) )
			If lPISDaNat
				aRet[1]	:= SED->ED_PERCPIS
			EndIf
			If lCOFDaNat
				aRet[2]	:= SED->ED_PERCCOF
			EndIf
			If lCSLDaNat
				aRet[3]	:= SED->ED_PERCCSL
			EndIf
		EndIf
		
		RestArea(aAreaSED)
		FwFreeArray(aAreaSED)	
	EndIf
	
	RestArea(aArea)
	FwFreeArray(aArea)
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc}GetCalcNt
Pega o valor calculado de PIS, COFINS e CSLL nos itens da nota

@author Fernando Amorim (Cafu)
@since  31/07/2015

@param cCart, characters, Carteira ("P" = Pagar; "R" = Receber)
@param cFiltit, characters, Filial do título
@param cPrefixo, characters, Prefixo do título
@param cNumTit, characters, Número do título
@param cCliFor, characters, Cliente/Fornecedor do título
@param cLoja, characters, Loja do Cliente/Fornecedor
@param cPedido, characters, Número do pedido

@return aRet - Vetor com o valor calculado de cada imposto (PIS, COFINS e CSLL)
@sample aRet[1] = Total do PIS; 
		aRet[2] = Total do COFINS; 
		aRet[3] = Total do CSLL;
        aRet[4] = Base de cálculo do PIS; 
        aRet[5] = Base de cálculo do COFINS;
        aRet[6] = Base de cálculo do CSLL.
/*/
//-------------------------------------------------------------------
Static Function GetCalcNt(cCart, cFiltit, cPrefixo, cNumTit, cCliFor, cLoja, cPedido)

	Local cAliasQry  := GetNextAlias()
	Local aRet		 := Array(6)
	Local cQuery	 := ""
	Local aAreaSF1   := {}
	Local aAreaSF2   := {}
	Local aAreaSD2   := {}
	Local cItmPV	 := ""
	Local cSerie	 := ""
	Local cDoc		 := ""

	AFILL(aRet,0)

	Default cPedido  := ""

	If Empty( cFiltit )
		cFiltit := cFilAnt
	EndIf

	If cCart =='P'
		If __oQryCP == Nil
			cQuery := " SELECT SUM(D1_VALPIS) TOTPIS,"
			cQuery += " SUM(D1_VALCOF) TOTCOF, "
			cQuery += " SUM(D1_VALCSL) TOTCSL, "
			cQuery += " F1_SERIE "
			cQuery += " FROM " + RetSQLName("SD1") + " SD1 "
			cQuery += " INNER JOIN " + RetSQLName("SF1") + " SF1 "
			cQuery += " ON SF1.F1_FILIAL = SD1.D1_FILIAL "
			cQuery += " AND SF1.F1_DOC = SD1.D1_DOC "
			cQuery += " AND SF1.F1_SERIE = SD1.D1_SERIE "
			cQuery += " AND SF1.F1_FORNECE = SD1.D1_FORNECE "
			cQuery += " AND SF1.F1_LOJA = SD1.D1_LOJA "
			cQuery += " AND SF1.F1_FORMUL = SD1.D1_FORMUL "
			cQuery += " AND SD1.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE SF1.D_E_L_E_T_ = ' ' "
			cQuery += " AND SF1.F1_FILIAL = ? "
			cQuery += " AND SF1.F1_PREFIXO = ? "
			cQuery += " AND SF1.F1_DUPL = ? "
			cQuery += " AND SF1.F1_FORNECE = ? "
			cQuery += " AND SF1.F1_LOJA = ? "
			cQuery += " GROUP BY F1_SERIE "
	
			cQuery := ChangeQuery(cQuery)
			__oQryCP := FWPreparedStatement():New(cQuery)
		EndIf
		__oQryCP:SetString( 1, xFilial("SF1",cFiltit) )
		__oQryCP:SetString( 2, cPrefixo )
		__oQryCP:SetString( 3, cNumTit )
		__oQryCP:SetString( 4, cCliFor )
		__oQryCP:SetString( 5, cLoja )
				
		cQuery := __oQryCP:GetFixQuery()
	Else
		cSerie := cPrefixo
		cDoc := cNumTit
		// busca corretamente o numero e serie da nota pelo pedido pois pode haver NF
		// com mais de um pedido e as informacoes do doc e serie da nota pode ser alterado na gravacao da SE1
		If !Empty(cPedido)
			aAreaSD2 := SD2->( GetArea() )

			cItmPV := Posicione("SD2", 3, xFilial("SD2") + cNumTit + cPrefixo + cCliFor + cLoja, "D2_ITEMPV") //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM						
			If Empty( Alltrim(cItmPV) )
				cItmPV := Posicione("SD2", 8, xFilial("SD2") + cPedido, "D2_ITEMPV")
			Endif
			SD2->( dbSetOrder(8) ) //D2_FILIAL+D2_PEDIDO+D2_ITEMPV
			If SD2->( dbSeek(xFilial("SD2",cFiltit) + cPedido + cItmPV) ) .And. cPedido <> SD2->D2_PEDIDO
				cSerie := SD2->D2_SERIE
				cDoc := SD2->D2_DOC
			EndIf
			
			RestArea(aAreaSD2)
			FwFreeArray(aAreaSD2)
		EndIf

		If __oQryCR == Nil
			cQuery := " SELECT SUM(D2_VALPIS) TOTPIS, "
			cQuery += " SUM(D2_VALCOF) TOTCOF, "
			cQuery += " SUM(D2_VALCSL) TOTCSL, "
			cQuery += " F2_SERIE "
			cQuery += " FROM " + RetSQLName("SD2") + " SD2 "
			cQuery += " INNER JOIN " + RetSQLName("SF2") + " SF2 "
			cQuery += " ON SF2.F2_FILIAL = SD2.D2_FILIAL "
			cQuery += " AND SF2.F2_DOC = SD2.D2_DOC "
			cQuery += " AND SF2.F2_SERIE = SD2.D2_SERIE "
			cQuery += " AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
			cQuery += " AND SF2.F2_LOJA = SD2.D2_LOJA "
			cQuery += " AND SF2.F2_FORMUL = SD2.D2_FORMUL "
			cQuery += " AND SD2.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE SF2.D_E_L_E_T_ = ' ' "
			cQuery += " AND SF2.F2_FILIAL = ? "
			cQuery += " AND SF2.F2_SERIE = ? "
			cQuery += " AND SF2.F2_DOC = ? "
			cQuery += " AND SF2.F2_CLIENTE = ? "
			cQuery += " AND SF2.F2_LOJA = ? "
			cQuery += " GROUP BY F2_SERIE "
			
			cQuery := ChangeQuery(cQuery)
			__oQryCR := FWPreparedStatement():New(cQuery)
		EndIf
		__oQryCR:SetString( 1, xFilial("SF2",cFiltit) )
		__oQryCR:SetString( 2, cSerie )
		__oQryCR:SetString( 3, cDoc )
		__oQryCR:SetString( 4, cCliFor )
		__oQryCR:SetString( 5, cLoja )
				
		cQuery := __oQryCR:GetFixQuery()
	Endif

	If Select(cAliasQry) > 0
		( cAliasQry )->( dbCloseArea() )
	Endif

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

	If ( cAliasQry )->( !Eof() )
		aRet[1]	:= (cAliasQry)->TOTPIS
		aRet[2]	:= (cAliasQry)->TOTCOF
		aRet[3]	:= (cAliasQry)->TOTCSL
		If cCart =='P'
			aAreaSF1 := SF1->( GetArea() )
			
			SF1->( dbSetOrder(1) ) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
			If SF1->( dbSeek( xFilial("SF1",cFiltit) + cNumTit + (cAliasQry)->F1_SERIE + cCliFor + cLoja ) )
				aRet[4]	:= SF1->F1_BASPIS
				aRet[5]	:= SF1->F1_BASCOFI
				aRet[6]	:= SF1->F1_BASCSLL
			EndIf
			
			RestArea(aAreaSF1)
			FwFreeArray(aAreaSF1)
		Else
			aAreaSF2 := SF2->( GetArea() )
			
			SF2->( dbSetOrder(1) ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			If SF2->( dbSeek( xFilial("SF2",cFiltit) + cNumTit + (cAliasQry)->F2_SERIE + cCliFor + cLoja ) )
				aRet[4]	:= SF2->F2_BASPIS
				aRet[5]	:= SF2->F2_BASCOFI
				aRet[6]	:= SF2->F2_BASCSLL
			EndIf
			
			RestArea(aAreaSF2)
			FwFreeArray(aAreaSF2)
		Endif
	Endif

	If Select(cAliasQry) > 0
		( cAliasQry )->( dbCloseArea() )
	Endif

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc}verVrAR
Proporcionaliza para verificar se não irá reter mais que o saldo do título

@param nValor, numeric, Valor de Referencia para o cálculo do PCC
@param aOutImp, array, Vetor de Impostos
@param lTemMR, logical, Indica se tem motor de retenção no ambiente
@param lImpMR, logical, Indica se tem outros impostos no motor 
@return aPCC, Retorna o vetor com o valor proporcionalizado de cada imposto do PCC

@author Caique Ferreira
@since 08/08/2015
@type function
/*/
//-------------------------------------------------------------------
Function verVrAR(nValor, aOutImp, lTemMR, lImpMR)

	Local aPCC 		:= Array(4)
	Local nX		:= 0
	Local nValImp	:= 0
	Local nPis		:= 0
	Local nCof		:= 0
	Local nCsl		:= 0
	Local nIrf		:= 0
	Local nIss		:= 0
	Local nIns		:= 0
	Local nOut 		:= 0
	Local nAux		:= 0
	Local nProp		:= 0
	Local lRestaUM	:= .T.
	Local lRoundPis := .F.
	Local lRoundCof := .F.
	Local lRoundCsl := .F.
	Local nPisAux	:= 0
	Local nCofAux	:= 0
	Local nCslAux	:= 0
	Local nDifAux	:= 0

	Default aOutImp := {}
	Default nValor 	:= 0
	Default lTemMR	:= .F.
	Default lImpMR 	:= .F.

	Afill(aPCC, 0 )	

	If Len(aOutImp) > 0		
		If ExistBlock("RESTAUM")
			lRestaUM := ExecBlock("RestaUM",.F.,.F.)
		Endif
		
		For nX := 1 to Len(aOutImp)
			nValImp += aOutImp[nX,2]
			
			If aOutImp[nX,1] == "PIS"
				nPis := aOutImp[nX,2]
			ElseIF aOutImp[nX,1] == "COF"
				nCof := aOutImp[nX,2]
			ElseIF aOutImp[nX,1] == "CSL"
				nCsl := aOutImp[nX,2]
			ElseIF aOutImp[nX,1] == "IRF"
				nIrf := aOutImp[nX,2]
			ElseIF aOutImp[nX,1] == "ISS"
				nIss := aOutImp[nX,2]
			ElseIF aOutImp[nX,1] == "INS"
				nIns := aOutImp[nX,2]
			ElseIf aOutImp[nX,1] == "OUT"
				nOut := aOutImp[nX,2]
			EndIf
		Next nX
		
		If nValImp >= nValor
			nAux := nValor - (nIrf + nIss + nIns + nOut)
			
			If nAux - Iif(lRestaUM, 0.01, 0) < nValImp
				lRoundPis := SuperGetMV("MV_RNDPIS",,.F.)
				lRoundCof := SuperGetMV("MV_RNDCOF",,.F.)
				lRoundCsl := SuperGetMV("MV_RNDCSL",,.F.)
				
				nProp := nAux / (nPis + nCsl + nCof + nOut)
				
				nPisAux := nProp * nPis
				nPis := Iif( lRoundPis, Round(nPisAux,2), NoRound(nPisAux,2) )
				nCofAux := nProp * nCof
				nCof := Iif( lRoundCof, Round(nCofAux,2), NoRound(nCofAux,2) )
				nCslAux := nProp * nCsl
				nCsl := Iif( lRoundCsl, Round(nCslAux,2), NoRound(nCslAux,2) )
				nOut := Round( (nProp * nOut), 2 )
				
				nValImp := (nIrf + nIss + nIns + nPis + nCof + nCsl + nOut)
				
				If nValor - nValImp > 0.01
					nDifAux := ( nValor - ( nValImp + Iif( lRestaUM, 0.01, 0 ) ) )
	
					If nPis <> 0
						nPis += nDifAux
					ElseIf nCof <> 0
						nCof += nDifAux
					ElseIf nCsl <> 0
						nCsl += nDifAux
					ElseIf lTemMR .and. lImpMR // Proporcionaliza valor do imposto Motor de Retenção.
						nOut += nDifAux
					Endif
				EndIf
			EndIf
	
			If nAux == nValImp .And. lRestaUM
				If nPis > 0
					nPis -= 0.01
				ElseIf nCof > 0
					nCof -= 0.01
				Else
					nCsl -= 0.01
				EndIf
			EndIf
	
		EndIf

	EndIf
	aPCC[1] := nPis
	aPCC[2] := nCof
	aPCC[3] := nCsl
	aPCC[4] := nOut

Return( aPCC )

//-------------------------------------------------------------------
/*/{Protheus.doc}isPenTxR(cCart,dRef)
Proporcionaliza para verificar senão irá reter mais que o saldo do título

@param cCart - Carteira
@param dRef - Data de referencia

@return lRet - .F. quando há valor pendente de retenção

@author Caique Ferreira
@since  09/08/2015
/*/
//-------------------------------------------------------------------
Function isPenTxR(cCart,dRef,cFilOrig)

	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""
	Local lRet		:= .T.
	Local lPCCBaixa	:= IIF(cCart == "P", SuperGetMv("MV_BX10925",.T.,"2") == "1", SuperGetMv("MV_BR10925",.T.,"2") == "1")
	Local lEmissao	:= FwIsInCallStack("FA040Alter") .or. FwIsInCallStack("FA050Alter")
	Local cSepNeg   := If("|"$MV_CPNEG,"|",",")
	Local cSerNeg	:= If("|"$MV_CRNEG,"|",",")
	Local cSepPag   := If("|"$MVPAGANT,"|",",")
	Local cSepRec	:= If("|"$MVRECANT,"|",",")
	Local cSepProv  := If("|"$MVPROVIS,"|",",")
	Local lLojaAtu	:= ( SuperGetMv( "MV_LJ10925",.F., "1" ) == "1" )
	Local cCliFor 	:= ""
	Local cLoja   	:= ""
	Local cMoeda  	:= "01"
	Local lFina241	:= FwIsInCallStack("F241Impost")
	Local lFina061	:= FwIsInCallStack("Fa061Borde")
	Local cTipNotIn	:= ""

	DEFAULT cCart	  	:= "P"
	DEFAULT dRef	  	:= CtoD("//")
	DEFAULT cFilOrig	:= cFilAnt

	If cCart == "P"
		If lEmissao
			cCliFor 	:= M->E2_FORNECE
			cLoja   	:= M->E2_LOJA
		Else
			cCliFor 	:= SE2->E2_FORNECE
			cLoja   	:= SE2->E2_LOJA
		EndIf
	Else
		If lEmissao
			cCliFor 	:= M->E1_CLIENTE
			cLoja   	:= M->E1_LOJA
		Else
			cCliFor 	:= SE1->E1_CLIENTE
			cLoja   	:= SE1->E1_LOJA
		EndIf
	EndIf

	If __lRpoR33 == NIL
		__lRpoR33 := GetRpoRelease() >= "12.1.033"
	Endif

	If lPccBaixa
		If __lRpoR33
			If cCart == 'P'
				If __oPenTxP == NIL
					cTipNotIn := MVABATIM + "|" + MVPROVIS + "|" + MV_CPNEG
					cTipNotIn := F050TipoIN(cTipNotIn, .T.)

					cQuery := "SELECT FK2_FILIAL, FK2_IDFK2, FK2_IDDOC FROM "+ RetSqlName("FK2") +" FK2 "
					cQuery += " INNER JOIN " + RetSqlName("FK7") + " FK7 "
					cQuery += 		"ON FK7.FK7_FILIAL = ? "	//01 Filial
					cQuery += 		"AND FK7.FK7_IDDOC = FK2_IDDOC "
					cQuery += 		"AND FK7.FK7_TIPO NOT IN " + cTipNotIn + " "
					cQuery += 		"AND FK7.FK7_CLIFOR = ? "	//02 cCliFor

					If lLojaAtu
						cQuery += 	" AND FK7.FK7_LOJA =  ? "	//03 cLoja
					EndIf

					cQuery += " INNER JOIN " + RetSqlName("FK4") + " FK4 "
					cQuery += 		"ON FK4.FK4_FILIAL = FK2_FILIAL "
					cQuery += 		"AND FK4.FK4_IDORIG = FK2_IDFK2 "
					cQuery += 		"AND FK4_IMPOS IN ('PIS','COF','CSL') "
					cQuery += 		"AND FK4_STATUS = '1' "
					cQuery += 		"AND FK4.D_E_L_E_T_ = ' ' "
					cQuery += "WHERE FK2_FILIAL = ? "			//04 FILIAL
					cQuery += 		"AND FK2_MOEDA = ? "		//05 cMoeda
					cQuery += 		"AND FK2_RECPAG = 'P' "
					cQuery += 		"AND FK2_DATA = ? "			//06 dRef

					//Não considera faturas, liquidações e devoluções
					cQuery += 		"AND (FK2_MOTBX NOT IN ('FAT','IRF','PCC','LIQ','STP','DSD','ISS','INS','IMR') "
					cQuery += 			"	OR (FK2.FK2_MOTBX = 'PCC' AND  FK7.FK7_TIPO IN " + FormatIn(MVPAGANT,cSepPag) + " ) ) "
					cQuery += 		"AND FK2.FK2_VALOR = 0.01 "					
					cQuery += 		"AND FK2.D_E_L_E_T_ = ' ' "
					cQuery += 		"AND NOT EXISTS( "
					cQuery += 			"SELECT FK2EST.FK2_IDDOC FROM " + RetSqlName("FK2") +" FK2EST "
					cQuery += 			"WHERE FK2EST.FK2_FILIAL = FK2.FK2_FILIAL "
					cQuery += 				"AND FK2EST.FK2_IDDOC = FK2.FK2_IDDOC "
					cQuery +=		 		"AND FK2EST.FK2_SEQ = FK2.FK2_SEQ "
					cQuery += 				"AND FK2EST.FK2_TPDOC = 'ES' "
					cQuery += 				"AND FK2EST.D_E_L_E_T_ = ' ') "

					cQuery 	:= ChangeQuery(cQuery)
					__oPenTxP:=FWPreparedStatement():New(cQuery)
				Endif

				If lLojaAtu
					__oPenTxP:SetString(1,xFilial("FK7", cFilOrig))
					__oPenTxP:SetString(2,cCliFor)
					__oPenTxP:SetString(3,cLoja)
					__oPenTxP:SetString(4,xFilial("FK2", cFilOrig))
					__oPenTxP:SetString(5,cMoeda)
					__oPenTxP:SetString(6,DTOS(dRef))
				Else
					__oPenTxP:SetString(1,xFilial("FK7", cFilOrig))
					__oPenTxP:SetString(2,cCliFor)
					__oPenTxP:SetString(3,xFilial("FK2", cFilOrig))
					__oPenTxP:SetString(4,cMoeda)
					__oPenTxP:SetString(5,DTOS(dRef))
				Endif
				cQuery := __oPenTxP:GetFixQuery()
			Else
				If __oPenTxR == NIL
					cTipNotIn := MVABATIM + "|" + MVPROVIS + "|" + MV_CRNEG
					cTipNotIn := F050TipoIN(cTipNotIn, .T.)

					cQuery := "SELECT FK1_FILIAL, FK1_IDFK1, FK1_IDDOC FROM "+ RetSqlName("FK1") +" FK1 "
					cQuery += " INNER JOIN " + RetSqlName("FK7") + " FK7 "
					cQuery += 		"ON FK7.FK7_FILIAL = ? "	//01 Filial
					cQuery += 		"AND FK7.FK7_IDDOC = FK1_IDDOC "
					cQuery += 		"AND FK7.FK7_TIPO NOT IN " + cTipNotIn + " "
					cQuery += 		"AND FK7.FK7_CLIFOR = ? "	//02 cCliFor

					If lLojaAtu
						cQuery += 	" AND FK7.FK7_LOJA =  ? "	//03 cLoja
					EndIf

					cQuery += " INNER JOIN " + RetSqlName("FK4") + " FK4 "
					cQuery += 		"ON FK4.FK4_FILIAL = FK1_FILIAL "
					cQuery += 		"AND FK4.FK4_IDORIG = FK1_IDFK1 "
					cQuery += 		"AND FK4_IMPOS IN ('PIS','COF','CSL') "
					cQuery += 		"AND FK4_STATUS = '1' "
					cQuery += 		"AND FK4.D_E_L_E_T_ = ' ' "
					cQuery += "WHERE FK1_FILIAL = ? "			//04 FILIAL
					cQuery += 		"AND FK1_MOEDA = ? "		//05 cMoeda
					cQuery += 		"AND FK1_RECPAG = 'R' "
					cQuery += 		"AND FK1_DATA = ? "			//06 dRef

					//Não considera faturas, liquidações e devoluções
					cQuery += 		"AND (FK1_MOTBX NOT IN ('FAT','IRF','PCC','LIQ','STP','DSD','ISS','INS','IMR') "
					cQuery += 			"	OR (FK1.FK1_MOTBX = 'PCC' AND  FK7.FK7_TIPO IN " + FormatIn(MVRECANT,cSepRec) + " ) ) "
					cQuery += 		"AND FK1.FK1_VALOR = 0.01 "					
					cQuery += 		"AND FK1.D_E_L_E_T_ = ' ' "
					cQuery += 		"AND NOT EXISTS( "
					cQuery += 			"SELECT FK1EST.FK1_IDDOC FROM " + RetSqlName("FK1") +" FK1EST "
					cQuery += 			"WHERE FK1EST.FK1_FILIAL = FK1.FK1_FILIAL "
					cQuery += 				"AND FK1EST.FK1_IDDOC = FK1.FK1_IDDOC "
					cQuery +=		 		"AND FK1EST.FK1_SEQ = FK1.FK1_SEQ "
					cQuery += 				"AND FK1EST.FK1_TPDOC = 'ES' "
					cQuery += 				"AND FK1EST.D_E_L_E_T_ = ' ') "

					cQuery 	:= ChangeQuery(cQuery)
					__oPenTxR:=FWPreparedStatement():New(cQuery)
				Endif

				If lLojaAtu
					__oPenTxR:SetString(1,xFilial("FK7", cFilOrig))
					__oPenTxR:SetString(2,cCliFor)
					__oPenTxR:SetString(3,cLoja)
					__oPenTxR:SetString(4,xFilial("FK2", cFilOrig))
					__oPenTxR:SetString(5,cMoeda)
					__oPenTxR:SetString(6,DTOS(dRef))
				Else
					__oPenTxR:SetString(1,xFilial("FK7", cFilOrig))
					__oPenTxR:SetString(2,cCliFor)
					__oPenTxR:SetString(3,xFilial("FK2", cFilOrig))
					__oPenTxR:SetString(4,cMoeda)
					__oPenTxR:SetString(5,DTOS(dRef))
				Endif

				cQuery := __oPenTxR:GetFixQuery()
			Endif

			cAliasQry := mpsysopenquery(cQuery)
			If ( cAliasQry )->(!Eof())
				lRet := .F.
			EndIf

			If Select(cAliasQry) > 0
				( cAliasQry )->( dbCloseArea() )
			Endif
		Else

			cQuery := " SELECT SE5.R_E_C_N_O_ NRECNO "

			cQuery += " FROM "+RetSQLName("SE5")+" SE5 "
			//Não considera deletados, estornados ou cancelados
			cQuery += " WHERE SE5.D_E_L_E_T_ = ' ' "
			cQuery += 		"AND SE5.E5_SITUACA NOT IN ( 'C' , 'E' , 'X' ) "
			cQuery += 		"AND SE5.E5_TIPODOC <> 'ES' "

			//Não considera faturas, liquidações e devoluções
			cQuery += " AND SE5.E5_VALOR = 0.01 "

			cQuery += " AND	SE5.E5_TIPO NOT IN " + FormatIn(MVABATIM,"|")
			cQuery += "	AND	SE5.E5_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv)
			If cCart == "P"
				cQuery += "	AND SE5.E5_TIPO NOT IN " + FormatIn(MV_CPNEG,cSepNeg)
				cQuery += "	AND SE5.E5_RECPAG = 'P' "
			Else
				cQuery += "	AND SE5.E5_TIPO NOT IN " + FormatIn(MV_CRNEG,cSerNeg)
				cQuery += "	AND SE5.E5_RECPAG = 'R' "
			EndIf
			cQuery += "	AND (SE5.E5_MOTBX NOT IN ('FAT','IRF','PCC','LIQ','STP','DSD','ISS','INS','IMR') "
			If cCart == "P"
				cQuery += "	OR (SE5.E5_MOTBX='PCC' AND  SE5.E5_TIPO IN " + FormatIn(MVPAGANT,cSepPag) + " ) ) AND "
			Else
				cQuery += "	OR (SE5.E5_MOTBX='PCC' AND  SE5.E5_TIPO IN " + FormatIn(MVRECANT,cSepRec) + " ) ) AND "
			EndIf

			cQuery += 		" SE5.E5_FILIAL = '"+xFilial("SE5")+"' "
			cQuery += 		" AND SE5.E5_CLIFOR = '"+cCliFor+"' "
			If lLojaAtu
				cQuery += 	" AND SE5.E5_LOJA = '"+cLoja+"' "
			EndIf
			cQuery += 		" AND SE5.E5_DATA = '"+ DtoS(dRef) +"'"
			cQuery += 		" AND (SE5.E5_MOEDA = '"+ cMoeda +"' Or SE5.E5_MOEDA = ' ' ) "
			cQuery += 		" AND (SE5.E5_VRETPIS+SE5.E5_VRETCOF+SE5.E5_VRETCSL) > 0 "
			cQuery += 		" AND NOT EXISTS ( "
			cQuery += 			" SELECT A.E5_NUMERO "
			cQuery += 			" FROM "+RetSqlName("SE5")+" A "
			cQuery += 			" WHERE A.E5_FILIAL = '"+xFilial("SE5")+"' AND "
			cQuery += 				" A.E5_PREFIXO=SE5.E5_PREFIXO AND "
			cQuery += 				" A.E5_NUMERO=SE5.E5_NUMERO AND "
			cQuery += 				" A.E5_PARCELA=SE5.E5_PARCELA AND "
			cQuery += 				" A.E5_TIPO=SE5.E5_TIPO AND "
			cQuery += 				" A.E5_CLIFOR=SE5.E5_CLIFOR AND "
			cQuery += 				" A.E5_LOJA=SE5.E5_LOJA AND "
			cQuery += 				" A.E5_SEQ=SE5.E5_SEQ AND "
			cQuery += 				" A.E5_TIPODOC='ES' AND "

			If cCart == "P"
				cQuery +=  "A.E5_RECPAG <> 'P' AND "
			Else
				cQuery +=  "A.E5_RECPAG <> 'R' AND "
			EndIF
			cQuery +=  "A.D_E_L_E_T_ = ' ')"

			cQuery := ChangeQuery( cQuery )

			If Select(cAliasQry) > 0
				( cAliasQry )->( dbCloseArea() )
			Endif

			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

			If ( cAliasQry )->(!Eof())
				lRet := .F.
			EndIf

			If Select(cAliasQry) > 0
				( cAliasQry )->( dbCloseArea() )
			Endif
		Endif
	EndIf

	If lRet .And. lPccBaixa
		If cCart == "P"
			cQuery := " SELECT SE2.R_E_C_N_O_ NRECNO "
			cQuery += " FROM "+ RetSqlName( "SE2" ) + " SE2 "
			
			cQuery += " INNER JOIN "+ RetSqlName( "SED" ) + " SED ON "
			If !Empty(FWFilial("SE2")) .And. !Empty(FWFilial("SED"))
				cQuery += " SE2.E2_FILIAL = SED.ED_FILIAL AND "
			Else
				cQuery += " SED.ED_FILIAL = '" + xFilial( "SED" , cFilOrig ) + "' AND "
			EndIf
			cQuery +=     " SE2.E2_NATUREZ = SED.ED_CODIGO AND (SED.ED_CALCPIS = 'S' OR SED.ED_CALCCOF = 'S' OR SED.ED_CALCCSL = 'S') AND SED.D_E_L_E_T_ = ' ' "

			cQuery += " INNER JOIN " + RetSqlName( "SEA" ) + " SEA ON"
			cQuery +=     " SE2.E2_FILORIG = SEA.EA_FILORIG AND SE2.E2_NUMBOR = SEA.EA_NUMBOR AND SE2.E2_PREFIXO = SEA.EA_PREFIXO"
			cQuery += 	  " AND SE2.E2_NUM = SEA.EA_NUM AND SE2.E2_PARCELA = SEA.EA_PARCELA AND SE2.E2_TIPO = SEA.EA_TIPO"
			cQuery += 	  " AND SEA.EA_CART = 'P' AND SEA.D_E_L_E_T_ = ' ' "
			
			cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' "

			cQuery += " AND E2_FORNECE='" + cCliFor + "' AND "
			If lLojaAtu  //Considero apenas a loja atual
				cQuery += "E2_LOJA ='"+cLoja+ "' AND "
			EndIf

			cQuery += " E2_SALDO = 0.01 AND "
			cQuery += " E2_DTBORDE = '" + DToS( dRef )      + "' AND "
			cQuery += " E2_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " AND "
			cQuery += " E2_TIPO NOT IN " + FormatIn(MV_CPNEG,cSepNeg)  + " AND "
			cQuery += " E2_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "
			cQuery += " E2_TIPO NOT IN " + FormatIn(MVPAGANT,cSepPag)  + " AND "

			cQuery += " SEA.EA_ORIGEM = 'FINA241' AND "

			If lFina241
				cQuery += " (SE2.R_E_C_N_O_ < "+alltrim(STR(SE2->(RECNO())))+" OR 	"
				cQuery += " SE2.E2_NUMBOR <> '"+SE2->E2_NUMBOR+"' ) AND "
			Endif
			cQuery += " E2_APLVLMN <> '2' AND "
			cQuery += " SE2.D_E_L_E_T_ = ' ' "
		Else
			cQuery := " SELECT SE1.R_E_C_N_O_ NRECNO "
			cQuery += 	" FROM "+ RetSqlName( "SE1" ) + " SE1 "
			cQuery += 	" INNER JOIN "+ RetSqlName( "SED" ) + " SED ON "

			If !Empty(FWFilial("SE1")) .And. !Empty(FWFilial("SED"))
				cQuery += " SE1.E1_FILIAL = SED.ED_FILIAL AND "
			Else
				cQuery += " SED.ED_FILIAL = '" + xFilial( "SED" , cFilOrig ) + "' AND "
			EndIf

			cQuery += " SE1.E1_NATUREZ = SED.ED_CODIGO AND (SED.ED_CALCPIS = 'S' OR SED.ED_CALCCOF = 'S' OR SED.ED_CALCCSL = 'S') AND SED.D_E_L_E_T_ = ' ' "
			cQuery += " AND E1_FILIAL = '"+xFilial("SE1")+"' "

			cQuery += " AND E1_CLIENTE ='"+ cCliFor+ "' AND "
			If lLojaAtu  //Considero apenas a loja atual
				cQuery += "E1_LOJA ='"+cLoja+ "' AND "
			EndIf

			cQuery += " E1_SALDO = 0.01 AND "

			cQuery += " E1_DATABOR = '" + DToS( dRef ) + "' AND "
			cQuery += " E1_TIPO NOT IN " + FormatIn(MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVENVBCOR,"/")
			cQuery += " AND (E1_NUMBOR <> '"+Space(TamSX3("E1_NUMBOR")[1])+"')  "
			cQuery += " AND E1_PORTADO <> ' ' "

			If lFina061
				cQuery += "AND (SE1.R_E_C_N_O_ < "+alltrim(STR(SE1->(RECNO())))+" OR 	"
				cQuery += " SE1.E1_NUMBOR <> '"+SE1->E1_NUMBOR+"' )  "
			Endif

			cQuery += " AND E1_APLVLMN <> '2' AND "
			cQuery += " SE1.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery := ChangeQuery( cQuery )

		If Select(cAliasQry) > 0
			( cAliasQry )->( dbCloseArea() )
		Endif

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

		DbSelectArea(cAliasQry)
		DbGoTop()

		If ( cAliasQry )->(!Eof())
			lRet := .F.
		EndIf

		If Select(cAliasQry) > 0
			( cAliasQry )->( dbCloseArea() )
		Endif
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}FGERPCCBOR(nRecSE2)
Identifica a geração de TX's de PCC via borderô de impostos(FINA241).

@param cCart - Carteira P = Pagar, R = Receber
@param nRecno - Recno do título

@return lRet - .T. quando houve geração de TX's de PCC via FINA241.

@author Leonardo Castro
@since  17/08/2015
/*/
//-------------------------------------------------------------------
FUNCTION FGERPCCBOR( cCart, nRecno )

	LOCAL lRet		:= .F.
	LOCAL aAmb		:= getArea()
	LOCAL aAmbSED 	:= {}
	LOCAL aAmbCF	:= {}
	LOCAL aAmbPR	:= {}
	LOCAL lRecPis	:= .F.
	LOCAL lRecCof	:= .F.
	LOCAL lRecCsl	:= .F.
	LOCAL cChave	:= ""
	LOCAL cCliFor	:= ""
	LOCAL cNatur	:= ""
	LOCAL cParcela	:= ""
	Local aImpPix   := {}
	//Controla o Pis Cofins e Csll na baixa
	LOCAL lPCCBaixa		:= IIF(cCart == "P", SuperGetMv("MV_BX10925",.T.,"2") == "1", SuperGetMv("MV_BR10925",.T.,"2") == "1")
	Local lPix          := if(__lFPIXAct,PIXIsActiv(),.F.)

	DEFAULT nRecno := IIF(cCart == "P", SE2->(Recno()), SE1->(Recno()) )

	If cCart == "P"
		SE2->(DbGoTo(nRecno))
	Else
		SE1->(DbGoTo(nRecno))
	EndIf

	cCliFor	:= IIF(cCart == "P", SE2->E2_FORNECE, SE1->E1_CLIENTE)
	cLoja	 := IIF(cCart == "P", SE2->E2_LOJA, SE1->E1_LOJA)
	cNatur	:= IIF(cCart == "P", SE2->E2_NATUREZ, SE1->E1_NATUREZ)

	If lPCCBaixa .And. (IIF(cCart == "P",!Empty(SE2->E2_NUMBOR),!Empty(SE1->E1_NUMBOR)) .OR. lPix)

		DbSelectArea("SED")
		aAmbSED := getArea()
		SED->(DbSetOrder(1))
		SED->(DbSeek(xFilial("SED")+cNatur))

		If cCart == "P"
			DbSelectArea("SA2")
			aAmbCF	:= getArea()
			SA2->(DbSetOrder(1))
			SA2->(DbSeek(xFilial("SA2")+cCliFor+cLoja))
			lRecPis := SA2->A2_RECPIS == "2" //Não
			lRecCof := SA2->A2_RECCOFI == "2" //Não
			lRecCsl := SA2->A2_RECCSLL == "2" //Não

			If lRecPis .And. SED->ED_CALCPIS == "S"
				cChave := SE2->(E2_PREFIXO+E2_NUM+E2_PARCPIS)+MVTAXA
			ElseIf lRecCof .And. SED->ED_CALCCOF == "S"
				cChave := SE2->(E2_PREFIXO+E2_NUM+E2_PARCCOF)+MVTAXA
			ElseIf lRecCsl .And. SED->ED_CALCCSL == "S"
				cChave := SE2->(E2_PREFIXO+E2_NUM+E2_PARCSLL)+MVTAXA
			EndIf

			If SA2->(dbSeek(xFilial("SA2")+GetMV("MV_UNIAO")))
				cChave += SA2->(A2_COD+A2_LOJA)
			Endif

			DbSelectArea("SE2")
			aAmbPR := getArea()
			SE2->(DbSetOrder(1))
			If SE2->(dbSeek(xFilial("SE2")+cChave))
				lRet := .T.
			Endif
		Else
			// Valida a geração dos impostos pelo PIX
			If lPix
				aImpPix := RetImpBxCR()
				IF Len(aImpPix) > 0
					lRet := .T.
				EndIf
			EndIf

			If !lRet

				DbSelectArea("SA1")
				aAmbCF	:= getArea()
				SA1->(DbSetOrder(1))
				SA1->(DbSeek(xFilial("SA1")+cCliFor+cLoja))
				lRecPis := SA1->A1_RECPIS $ "S|P" 	//Sim | Empresa Pública
				lRecCof := SA1->A1_RECCOFI $ "S|P" 	//Sim | Empresa Pública
				lRecCsl := SA1->A1_RECCSLL $ "S|P" 	//Sim | Empresa Pública

				cParcela := Soma1(SE1->E1_PARCELA,Len(SE1->E1_PARCELA))

				If lRecPis .And. SED->ED_CALCPIS == "S"
					cChave := SE1->(E1_PREFIXO+E1_NUM+cParcela)+"PIS"
				ElseIf lRecCof .And. SED->ED_CALCCOF == "S"
					cChave := SE1->(E1_PREFIXO+E1_NUM+cParcela)+"COF"
				ElseIf lRecCsl .And. SED->ED_CALCCSL == "S"
					cChave := SE1->(E1_PREFIXO+E1_NUM+cParcela)+"CSL"
				EndIf

				If SA1->(dbSeek(xFilial("SA1")+cCliFor+cLoja))
					cChave += SA1->(A1_COD+A1_LOJA)
				Endif

				DbSelectArea("SE1")
				aAmbPR := getArea()
				SE1->(DbSetOrder(1))
				If SE1->(dbSeek(xFilial("SE1")+cChave))
					lRet := .T.
				Endif

				RestArea(aAmbPR)
				RestArea(aAmbCF)

			Endif
		Endif

		RestArea(aAmbSED)

	EndIf

	RestArea(aAmb)

RETURN lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}GetBsPccPg()
Verifica a base do título, sendo compras
verifica base a base antes de utilizar a base do IRF

@return nValor - Valor da base de cálculo do título

@author Daniel Mendes
@since  20/08/2015
/*/
//-------------------------------------------------------------------
Function GetBsPccPg()
	Local nValor := 0

	If cPaisLoc == "BRA"
		If AllTrim( SE2->E2_ORIGEM ) $ "|MATA103|MATA100|"
			Do Case
				Case !Empty( SE2->E2_BASEPIS )
					nValor := SE2->E2_BASEPIS
				Case !Empty( SE2->E2_BASECOF )
					nValor := SE2->E2_BASECOF
				Case !Empty( SE2->E2_BASECSL )
					nValor := SE2->E2_BASECSL
				OtherWise
					nValor := SE2->E2_BASEIRF
			EndCase
		Else
			nValor := IIF( !Empty( SE2->E2_BASEPIS ) , SE2->E2_BASEPIS , SE2->E2_BASEIRF )
		EndIf
	EndIf

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} ISSFiscal
Consulta ISS - Constroi uma querie que gera uma tabela temporaria e Retorna o Alias desta tabela.

@author norbertom
@since 31/07/2015
@version 1.0
@param dInicial, date, Data Inicial
@param dFinal, date, Data Final
@return cAliasTMP, O alias para a tabela/consulta criada
@example
	ISSFiscal(dInicial,dFinal)
/*/
//-------------------------------------------------------------------
Function ISSFiscal(dInicial,dFinal,cForCli,cLoja,cCodMun,cCarteira)
	Local cAliasTMP	:= GetNextAlias()
	Local cAliasAux	:= ""
	Local cTpAbtm		:= StrTran(MVABATIM,"|","','")
	Local aArea		:= GetArea()
	Local nI			:= 0
	Local lValid		:= .F.
	Local cCliLojISS	:= ""
	Local cForLojISS	:= ""
	Local lChkForCli	:= .F.
	Local lChkMunic		:= .F.
	Local cSubstSQL		:= ""
	Local lGestao		:= FWSizeFilial() > 2	// Indica se usa Gestao Corporativa
	Local cSA1Empre		:= FWModeAccess("SA1",1)
	Local cSA1UnNeg		:= FWModeAccess("SA1",2)
	Local cSA1Fil		:= FWModeAccess("SA1",3)
	Local cQryFilSA1	:= ""
	Local cSA2Empre		:= FWModeAccess("SA2",1)
	Local cSA2UnNeg		:= FWModeAccess("SA2",2)
	Local cSA2Fil		:= FWModeAccess("SA2",3)
	Local cQryFilSA2	:= ""
	Local cLayOutSA2	:= ""
	Local cQuery		:= ""
	Local cChavePai		:= ''
	Local lBPVLBruto	:= SuperGetMv("MV_BP10925",.T.,"1") == "1"	// considerando os impostos (1=Vl Bruto/2=Vl Liquido)
	Local nTamFornLj	:= TamSX3("E2_FORNECE")[1] + TamSX3("E2_LOJA")[1]

	Default dInicial	:= dDataBase
	Default dFinal		:= dDataBase
	Default cForCli		:= ""
	Default cLoja		:= ""
	Default cCodMun		:= ""
	Default cCarteira	:= 'A'	//(P)agar - (R)receber - (A)mbas

	cCliLojISS := PADR(cForCli,TamSX3("E1_CLIENTE")[1]) + PADR(cLoja,TamSX3("E1_LOJA")[1])
	cForLojISS := PADR(cForCli,TamSX3("E2_FORNECE")[1]) + PADR(cLoja,TamSX3("E2_LOJA")[1])

	lChkForCli	:= !Empty(cForCli + cLoja)
	lChkMunic	:= !Empty(cCodMun)

	If lGestao
		If cBDname $ "ORACLE|DB2|POSTGRES|INFORMIX" 
			cSubstSQL := " SUBSTR"
		Else
			cSubstSQL := " SUBSTRING"
		EndIf

		If cSA2Empre == "E" .And. cSA2UnNeg == "E" .And. cSA2Fil == "E"
			cQryFilSA2	:=  " AND SA2.A2_FILIAL = SE2.E2_FILORIG "
		ElseIf cSA2Empre == "E" .And. cSA2UnNeg == "E" .And. cSA2Fil == "C"
			cLayOutSA2 := LTRIM( STR( LEN( FWSM0Layout(,1) + FWSM0Layout(,2) ) ) )
			cQryFilSA2	:=  " AND SA2.A2_FILIAL = "+cSubstSQL+"(SE2.E2_FILORIG,1," + cLayOutSA2 + ") " 
		ElseIf cSA2Empre == "E" .And. cSA2UnNeg == "C" .And. cSA2Fil == "C"
			cLayOutSA2 := LTRIM( STR( LEN( FWSM0Layout(,1) ) ) )
			cQryFilSA2	:=  " AND SA2.A2_FILIAL = "+cSubstSQL+"(SE2.E2_FILORIG,1," + cLayOutSA2 + ") " 
		Endif
		
		If cSA1Empre == "E" .AND. cSA1UnNeg == "E" .And. cSA1Fil == "E"
			cQryFilSA1	:=  " AND SA1.A1_FILIAL = SE1.E1_FILORIG "
		ElseIf cSA1Empre == "E" .AND. cSA1UnNeg == "E" .And. cSA1Fil == "C"
			cLayOutSA1 := LTRIM( STR( LEN( FWSM0Layout(,1) + FWSM0Layout(,2) ) ) )
			cQryFilSA1	:=  " AND SA1.A1_FILIAL = "+cSubstSQL+"(SE1.E1_FILORIG,1," + cLayOutSA1 + ") " 
		ElseIf cSA1Empre == "E" .AND. cSA1UnNeg == "C" .And. cSA1Fil == "C"
			cLayOutSA1 := LTRIM( STR( LEN( FWSM0Layout(,1) ) ) )
			cQryFilSA1	:=  " AND SA1.A1_FILIAL = "+cSubstSQL+"(SE1.E1_FILORIG,1," + cLayOutSA1 + ") " 
		Endif
	Else
		If !EMPTY(xFilial('SA2'))
			cQryFilSA2	:=  " AND SA2.A2_FILIAL = SE2.E2_FILORIG "
		EndIf
		If !EMPTY(xFilial('SA1'))
			cQryFilSA1	:=  " AND SA1.A1_FILIAL = SE1.E1_FILORIG "
		EndIf
	EndIf

	If UPPER(cCarteira) $ "P;A"
		cQuery :=   "SELECT "
		cQuery += 	"SE2.E2_FILIAL FILIAL, "
		cQuery += 	"SE2.E2_PREFIXO PREFIXO, "
		cQuery += 	"SE2.E2_NUM NUMERO, "
		cQuery += 	"SE2.E2_PARCELA PARCORIG, "
		cQuery += 	"SE2.E2_FORNECE CLIFOR, "
		cQuery += 	"SE2.E2_LOJA LOJA, "
		cQuery += 	"SE2.E2_ORIGEM ORIGEM, "
		cQuery += 	"SE2.E2_TIPO TIPO, "
		cQuery += 	"SE2.E2_CODISS CODISS, "
		cQuery += 	"SE2.E2_NUMPRO NUMPRO, "
		cQuery += 	"SE2.E2_INDPRO INDPRO, "
		cQuery += 	"SE2.E2_ISS ISS, "
		cQuery += 	"COUNT(SE2.E2_PARCELA) PARCELA, "
		cQuery += 	"'P' TIPOPR, "
		cQuery += 	"MIN(SA2.R_E_C_N_O_) IDCLIFOR, "
		cQuery += 	"SUM(SE5.E5_VALOR) VALOR, "
		cQuery += 	"(	SELECT MAX(SE5.E5_DATA) DATAMOV "
		cQuery += 			" FROM " + RetSQLName('SE5') + " SE5 "
		cQuery += 			" WHERE "
		cQuery += 			    "SE5.E5_FILIAL  = SE2.E2_FILIAL "
		cQuery += 			"AND SE5.E5_CLIFOR  = SE2.E2_FORNECE "
		cQuery += 			"AND SE5.E5_LOJA    = SE2.E2_LOJA "
		cQuery += 			"AND SE5.E5_PREFIXO = SE2.E2_PREFIXO "
		cQuery += 			"AND SE5.E5_NUMERO  = SE2.E2_NUM "
		cQuery += 			"AND SE5.E5_TIPODOC NOT IN ('E2','EI') "
		cQuery += 			"AND SE5.E5_MOTBX   NOT IN ('DSD','ISS') "
		cQuery += 			"AND SE5.E5_RECPAG  = 'P' "
		cQuery += 			"AND SE5.E5_DATA BETWEEN '" + DTOS(dInicial) + "' AND '" + DTOS(dFinal) + "' "
		cQuery += 			"AND SE5.E5_SITUACA NOT IN('X','C') "
		cQuery += 			"AND SE5.E5_DTCANBX = '' "
		cQuery += 			"AND SE5.D_E_L_E_T_ = '' "
		cQuery += 			"GROUP BY SE5.E5_FILIAL, SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_PREFIXO, SE5.E5_NUMERO "
		cQuery += 		") DATAPARC, "
		cQuery += 	"MIN(SE2.E2_BASEISS) BASEISS, "
		cQuery +=	"0 VALORISS, "
		cQuery += 	"0 ALIQUOTA "
		cQuery +=   "FROM "
		cQuery +=   RetSQLName('SE2') + " SE2 "
		cQuery +=   "INNER JOIN " + RetSQLName('SA2') +  " SA2 ON "
		cQuery += 		"SA2.A2_COD = SE2.E2_FORNECE "
		cQuery += 	"AND SA2.A2_LOJA = SE2.E2_LOJA "
		cQuery += 	cQryFilSA2
		cQuery += 	"AND SA2.D_E_L_E_T_ = '' "
		cQuery +=   "INNER JOIN " + RetSQLName('SE5') + " SE5 ON "
		cQuery += 	    "SE5.E5_FILIAL  = SE2.E2_FILIAL "
		cQuery += 	"AND SE5.E5_PREFIXO = SE2.E2_PREFIXO "
		cQuery += 	"AND SE5.E5_NUMERO  = SE2.E2_NUM "
		cQuery += 	"AND SE5.E5_PARCELA  = SE2.E2_PARCELA "
		cQuery += 	"AND SE5.E5_CLIFOR  = SE2.E2_FORNECE "
		cQuery += 	"AND SE5.E5_LOJA    = SE2.E2_LOJA "
		cQuery += 	"AND E5_DATA BETWEEN '" + DTOS(dInicial) + "' AND '" + DTOS(dFinal) + "' "
		cQuery += 	"AND SE5.E5_TIPODOC NOT IN ('E2','EI') "
		cQuery += 	"AND SE5.E5_MOTBX   NOT IN ('DSD','ISS') "
		cQuery += 	"AND SE5.E5_RECPAG  = 'P' "
		cQuery += 	"AND SE5.E5_SITUACA NOT IN('X','C') "
		cQuery += 	"AND SE5.E5_DTCANBX = '' "
		cQuery += 	"AND SE5.D_E_L_E_T_ = '' "
		cQuery +=   "WHERE "
		cQuery += 	    "SE2.E2_FILORIG = '" + cFilAnt + "' "
		cQuery += 	"AND SE2.E2_TIPO NOT IN ('" + cTpAbtm + "') "
		cQuery += 	"AND SE2.E2_ISS > 0 "
		cQuery += 	"AND SE2.D_E_L_E_T_ = '' "
		cQuery +=   "GROUP BY "
		cQuery += 	"SE2.E2_FILIAL, "
		cQuery += 	"SE2.E2_PREFIXO, "
		cQuery += 	"SE2.E2_NUM, "
		cQuery +=   "SE2.E2_PARCELA, "
		cQuery += 	"SE2.E2_FORNECE, "
		cQuery += 	"SE2.E2_LOJA, "
		cQuery += 	"SE2.E2_ORIGEM, "
		cQuery += 	"SE2.E2_TIPO, "
		cQuery += 	"SE2.E2_CODISS, "
		cQuery += 	"SE2.E2_NUMPRO, "
		cQuery += 	"SE2.E2_INDPRO, "
		cQuery += 	"SE2.E2_ISS "
		If cCarteira == 'A'
			cQuery += ' UNION '
		EndIf
	EndIf

	If UPPER(cCarteira) $ "R;A"
		cQuery += "SELECT "
		cQuery += "SE1.E1_FILIAL FILIAL, "
		cQuery += "SE1.E1_PREFIXO PREFIXO, "
		cQuery += "SE1.E1_NUM NUMERO, "
		cQuery += "SE1.E1_PARCELA PARCORIG, "
		cQuery += "SE1.E1_CLIENTE CLIFOR, "
		cQuery += "SE1.E1_LOJA LOJA, "
		cQuery += "SE1.E1_ORIGEM ORIGEM, "
		cQuery += "SE1.E1_TIPO TIPO, "
		cQuery += "SE1.E1_CODISS CODISS, "
		cQuery += "SE1.E1_NUMPRO NUMPRO, "
		cQuery += "SE1.E1_INDPRO INDPRO, "
		cQuery += "SE1.E1_ISS ISS, "
		cQuery += "COUNT(SE1.E1_PARCELA) PARCELA, "
		cQuery += "'R' TIPOPR, "
		cQuery += "MIN(SA1.R_E_C_N_O_) IDCLIFOR, "
		cQuery += "SUM(SE5.E5_VALOR) VALOR, "
		cQuery += "(	SELECT MAX(SE5.E5_DATA) DATAMOV "
		cQuery += 		"FROM " + RetSQLName('SE5') + " SE5 "
		cQuery += 		"WHERE "
		cQuery += 			"SE5.E5_FILIAL  = SE1.E1_FILIAL "
		cQuery += 		"AND SE5.E5_CLIFOR  = SE1.E1_CLIENTE "
		cQuery += 		"AND SE5.E5_PREFIXO = SE1.E1_PREFIXO "
		cQuery += 		"AND SE5.E5_NUMERO  = SE1.E1_NUM "
		cQuery += 		"AND SE5.E5_TIPODOC NOT IN ('E2','EI') "
		cQuery += 		"AND SE5.E5_MOTBX   <> 'DSD' "
		cQuery += 		"AND SE5.E5_RECPAG  = 'R' "
		cQuery += 		"AND SE5.E5_DATA BETWEEN '" + DTOS(dInicial) + "' AND '" + DTOS(dFinal) + "' "
		cQuery += 		"AND SE5.E5_SITUACA NOT IN('X','C') "
		cQuery +=		"AND SE5.E5_DTCANBX = '' "
		cQuery += 		"AND SE5.D_E_L_E_T_ = '' "
		cQuery += 		"GROUP BY SE5.E5_FILIAL, SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_PREFIXO, SE5.E5_NUMERO "
		cQuery += 	") DATAPARC, "
		cQuery += "SUM(SE1.E1_BASEISS) BASEISS, "
		cQuery += "0 VALORISS, "
		cQuery += "0 ALIQUOTA "
		cQuery += "FROM "
		cQuery += 	RetSQLName('SE1') + " SE1 "
		cQuery += 	"INNER JOIN " + RetSQLName('SA1') + " SA1 ON "
		cQuery += 			"SA1.A1_COD = SE1.E1_CLIENTE "
		cQuery += 		"AND SA1.A1_LOJA = SE1.E1_LOJA "
		cQuery += 		cQryFilSA1
		cQuery += 		"AND SA1.D_E_L_E_T_ = '' "
		cQuery += 	"INNER JOIN " + RetSQLName('SE5') + " SE5 ON "
		cQuery += 			"SE5.E5_FILIAL  = SE1.E1_FILIAL "
		cQuery += 		"AND SE5.E5_CLIFOR  = SE1.E1_CLIENTE "
		cQuery += 		"AND SE5.E5_LOJA    = SE1.E1_LOJA "
		cQuery += 		"AND SE5.E5_PREFIXO = SE1.E1_PREFIXO "
		cQuery += 		"AND SE5.E5_NUMERO  = SE1.E1_NUM "
		cQuery += 		"AND SE5.E5_PARCELA = SE1.E1_PARCELA "
		cQuery += 		"AND E5_DATA BETWEEN '" + DTOS(dInicial) + "' AND '" + DTOS(dFinal) + "' "
		cQuery += 		"AND SE5.E5_TIPODOC NOT IN ('E2','EI') "
		cQuery += 		"AND SE5.E5_MOTBX   <> 'DSD' "
		cQuery += 		"AND SE5.E5_RECPAG  = 'R' "
		cQuery += 		"AND SE5.E5_SITUACA NOT IN('X','C') "
		cQuery += 		"AND SE5.E5_DTCANBX = '' "
		cQuery += 		"AND SE5.D_E_L_E_T_ = '' "
		cQuery += "WHERE "
		cQuery += 		"SE1.E1_FILORIG = '" + cFilAnt + "' "
		cQuery += 	"AND SE1.E1_TIPO NOT IN ('" + cTpAbtm + "') "
		cQuery += 	"AND SE1.E1_SITUACA <> ' ' "
		cQuery += 	"AND SE1.E1_ISS > 0 "
		cQuery += 	"AND SE1.D_E_L_E_T_ = '' "
		cQuery +=   "GROUP BY "
		cQuery += 	"SE1.E1_FILIAL, "
		cQuery += 	"SE1.E1_PREFIXO, "
		cQuery += 	"SE1.E1_NUM, "
		cQuery +=   "SE1.E1_PARCELA, "
		cQuery += 	"SE1.E1_CLIENTE, "
		cQuery += 	"SE1.E1_LOJA, "
		cQuery += 	"SE1.E1_ORIGEM, "
		cQuery += 	"SE1.E1_TIPO, "
		cQuery += 	"SE1.E1_CODISS, "
		cQuery += 	"SE1.E1_NUMPRO, "
		cQuery += 	"SE1.E1_INDPRO, "
		cQuery += 	"SE1.E1_ISS "
	ENDIF

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.F.,.T.)
	TcSetField(cAliasTMP,'DATAPARC','D',TamSX3("E5_DATA")[1],TamSX3("E5_DATA")[2])

	dbSelectArea('SE1')	// Tabela de Contas a Receber
	dbSelectArea('SE2')	// Tabela de Contas a Pagar

	// Cria um arquivo temporario
	cAliasAux := NewTRB()

	While !(cAliasTMP)->(Eof())
		SE1->(dbSetOrder(28))	// E1_FILIAL+E1_TITPAI
		SE2->(dbSetOrder(17))	// E2_FILIAL+E2_TITPAI

		// Verifica a existencia dos respectivos registros dos tipos 'TX ;ISS;IS-' nas tabelas [...]
		cChave := (cAliasTMP)->(FILIAL + PREFIXO + NUMERO + PARCORIG)

		// [...] Contas a Receber
		If SE1->(msSeek(cChave))
			While !SE1->(Eof()) .and. cChave $ SE1->(E1_FILIAL + E1_TITPAI)
				If (lValid := (SE1->E1_TIPO $ 'IS-') .and. If(lChkForCli,SE1->E1_CLIENTE + SE1->E1_LOJA == cCliLojISS,.T.))
					cChavePai := XFILIAL('SE1',SE1->E1_FILORIG) + RTRIM(SE1->E1_TITPAI)
					Exit
				EndIf
				SE1->(dbSkip())
			EndDo
		EndIf

		// [...] Contas a Pagar
		If !lValid .and. SE2->(msSeek(cChave))
			While !SE2->(Eof()) .and. cChave $ SE2->(E2_FILIAL + E2_TITPAI) 
				If (SE2->E2_TIPO $ 'TX ;ISS') .And. ALLTRIM(RIGHT(ALLTRIM(SE2->E2_TITPAI), nTamFornLj)) <> ALLTRIM((cAliasTMP)->(CLIFOR+LOJA))
					SE2->(dbSkip())
					Loop
				EndIf
				If (lValid := (SE2->E2_TIPO $ 'TX ;ISS') .and. If(lChkForCli,SE2->E2_FORNECE + SE2->E2_LOJA == cForLojISS,.T.))
					cChavePai := XFILIAL('SE2',SE2->E2_FILORIG) + RTRIM(SE2->E2_TITPAI)
					Exit
				EndIf
				SE2->(dbSkip())
			EndDo
		EndIf

		// [...] Aliquotas ISS - verif. municipio
		If lValid .And. lChkMunic .And. !Empty((cAliasTMP)->CODISS)
			If FIM->(dbSeek(xFilial('FIM')+(cAliasTMP)->CODISS))
				lValid := cCodMun == FIM->FIM_CODMUN
			EndIf
		EndIf

		If lValid
			SE1->(dbSetOrder(1))	// E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			SE2->(dbSetOrder(1))	// E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

			// Adiciona um novo registro
			RecLock(cAliasAux,.T.)

			For nI := 1 to (cAliasTMP)->(FCount())
				(cAliasAux)->(FieldPut((cAliasAux)->(FieldPos((cAliasTMP)->(FieldName(nI)))),(cAliasTMP)->(FieldGet(nI))))
			Next

			If (cAliasAux)->BASEISS > 0
				If !EMPTY(cChavePai) .AND. (SE1->(MSSEEK(cChavePai)) .OR. SE2->(MSSEEK(cChavePai)))
					(cAliasAux)->ALIQUOTA := (SE2->E2_ISS / SE2->E2_BASEISS)
					aBaseImp := FinBaseMR(,,(cAliasAux)->FILIAL,(cAliasAux)->PREFIXO,(cAliasAux)->NUMERO,SE2->E2_PARCELA,(cAliasAux)->TIPO,(cAliasAux)->CLIFOR,(cAliasAux)->LOJA,,,,,,,,,,,,.T.)

					If ((cAliasAux)->DATAPARC >= SE2->E2_BAIXA) .AND. (SE2->E2_SALDO == 0)
						(cAliasAux)->VALOR += aBaseImp[1] * If((cAliasAux)->VALOR > SE2->E2_BASEISS,(cAliasAux)->PARCELA,1)
					ElseIf !lBPVLBruto
						(cAliasAux)->VALOR += aBaseImp[3]
					EndIf 

					(cAliasAux)->VALORISS := ((cAliasAux)->VALOR * (cAliasAux)->ALIQUOTA)
				Else
					(cAliasAux)->ALIQUOTA := (SE2->E2_VALOR / SE2->E2_BASEISS)
				EndIf
			EndIf

			MsUnLock()
			lValid := .F.
			cChavePai := ''
		EndIf

		(cAliasTMP)->(dbSkip())
	EndDo

	// Restaura Ambiente
	(cAliasTMP)->(dbCloseArea())
	RestArea(aArea)

Return cAliasAux

//----------------------------------------------------------------------------
/*/{Protheus.doc} NewTRB
	Cria uma tabela temporária vazia no banco de dados
@author norbertom
@since 04/08/2015
@version 1.0
@return cRet, Alias da tabela criada
@example
(examples)
@see (links_or_references)
/*/
//----------------------------------------------------------------------------
Static Function NewTRB()
	Local cRet		:= GetNextAlias()
	Local aStruAux	:= {}

	DbSelectArea("SE2")

	// Cria Estrutura para tabela temporaria
	// Devera Conter a mesma estrutura da tabela cAliasTMP
	AAdd(aStruAux,{'FILIAL'  ,'C',TAMSX3('E2_FILIAL' )[1],TAMSX3('E2_FILIAL' )[2]})
	AAdd(aStruAux,{'PREFIXO' ,'C',TAMSX3('E2_PREFIXO')[1],TAMSX3('E2_PREFIXO')[2]})
	AAdd(aStruAux,{'NUMERO'  ,'C',TAMSX3('E2_NUM'    )[1],TAMSX3('E2_NUM'    )[2]})
	AAdd(aStruAux,{'CLIFOR'  ,'C',TAMSX3('E2_FORNECE')[1],TAMSX3('E2_FORNECE')[2]})
	AAdd(aStruAux,{'LOJA'    ,'C',TAMSX3('E2_LOJA'   )[1],TAMSX3('E2_LOJA'   )[2]})
	AAdd(aStruAux,{'ORIGEM'  ,'C',TAMSX3('E2_ORIGEM' )[1],TAMSX3('E2_ORIGEM' )[2]})
	AAdd(aStruAux,{'PARCELA' ,'N',3                      ,0                      })
	AAdd(aStruAux,{'TIPO'    ,'C',TAMSX3('E2_TIPO'   )[1],TAMSX3('E2_TIPO'   )[2]})
	AAdd(aStruAux,{'TIPOPR'  ,'C',1                      ,0                      })
	AAdd(aStruAux,{'IDCLIFOR','N',9                      ,0                      })
	AAdd(aStruAux,{'VALOR'   ,'N',TAMSX3('E2_VALOR'  )[1],TAMSX3('E2_VALOR'  )[2]})
	AAdd(aStruAux,{'DATAPARC','D',TAMSX3('E5_DATA'   )[1],TAMSX3('E5_DATA'  )[2]})
	AAdd(aStruAux,{'BASEISS' ,'N',TAMSX3('E2_BASEISS')[1],TAMSX3('E2_BASEISS')[2]})
	AAdd(aStruAux,{'VALORISS','N',TAMSX3('E2_ISS'    )[1],TAMSX3('E2_ISS'    )[2]})
	AAdd(aStruAux,{'ALIQUOTA','N',TAMSX3('E2_ISS'    )[1],TAMSX3('E2_ISS'    )[2]})
	AAdd(aStruAux,{'NUMPRO'  ,'C',TAMSX3('E2_NUMPRO' )[1],0                      })
	AAdd(aStruAux,{'INDPRO'  ,'C',TAMSX3('E2_INDPRO' )[1],0                      })
	AAdd(aStruAux,{'ISS'     ,'N',TAMSX3('E2_ISS'    )[1],TAMSX3('E2_ISS'    )[2]})


	//Deleta a tabela temporária no banco, caso já exista
	If(_oFINXIMP1 <> NIL)
		_oFINXIMP1:Delete()
		_oFINXIMP1 := NIL
	EndIf

	//Cria tabela temporária no banco de dados
	_oFINXIMP1 := FwTemporaryTable():New(cRet)
	_oFINXIMP1:SetFields(aStruAux)
	_oFINXIMP1:AddIndex("1", {aStruAux[1][1],aStruAux[2][1],aStruAux[3][1]})
	_oFINXIMP1:Create()

	dbSetOrder(0) //ordem natural de inserção

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc}VLDBOR(cNumBor,cCart)

Valida se já foram gerados todos impostos pelo FINA241

@param cNumBor - Numero do Bordero
@param cCart - Carteira P = Pagar, R = Receber


@return lRet

@author Fernando Amorim(Cafu)
@since  01/09/2015
/*/
//-------------------------------------------------------------------
Function VLDBOR(cNumBor,cCart,cFilOrig)

	Local 	lRet	:= .F.

	Default cNumBor	:= ''
	Default cCart	:= ''
	Default cFilOrig := cFilant

	If cCart == "P"
		If EMPTY(SE2->E2_NUMBOR)
			lRet := .T.
		Else
			SEA->(DbSetOrder(4))
			If SEA->(DbSeek(cFilOrig+cNumBor+alltrim(cCart)))
				if SEA->( FieldPos("EA_ORIGEM") ) > 0
					If SEA->EA_ORIGEM <> "FINA241"
						lRet := .T.
					Endif
				Else
					lRet := .F.
				Endif
			Endif
		Endif
	Else
		If EMPTY(SE1->E1_NUMBOR)
			lRet := .T.
		Else
			SEA->(DbSetOrder(4))
			If SEA->(DbSeek(cFilOrig+cNumBor+alltrim(cCart)))
				if SEA->( FieldPos("EA_ORIGEM") ) > 0
					If SEA->EA_ORIGEM <> "FINA061"
						lRet := .T.
					Endif
				Else
					lRet := .F.
				Endif
			Endif
		Endif

	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}GetOutImp((cCart,nIss,nInss,nIrrf)

@param cCart - Carteira P = Pagar, R = Receber
@return aValImp
@author Jose.Gavetti
@since  18/09/2015
/*/
//-------------------------------------------------------------------
Function GetOutImp(cCart,nIss,nInss,nIrrf)
	Local aValImp 	:= Array(3)
	Local lCalcIssBx	:= IIF(cCart == "P",	IIF(lIsIssBx, IsIssBx("P"),SuperGetMV("MV_MRETISS",.T.,"1") == "2"),.F.)
	Local lIRPFBaixa	:= IIF(cCart == "P", SA2->A2_CALCIRF == "2", FIrPjBxCr(.T.) )
	Local lInssBx		:= IIF(cCart == "P", SuperGetMv("MV_INSBXCP",.F.,"2") == "1",.F.)

	If cCart == "P"
		aValImp[1] := IIF(lCalcIssBx,nIss,SE2->E2_ISS)
		aValImp[2] := IIF(lInssBx,nInss,SE2->E2_INSS)
		aValImp[3] := IIF(lIRPFBaixa,nIrrf,SE2->E2_IRRF)
	Else
		aValImp[1] := IIF(lCalcIssBx,nIss,SE1->E1_ISS)
		aValImp[2] := IIF(lInssBx,nInss,SE1->E1_INSS)
		aValImp[3] := IIF(lIRPFBaixa,nIrrf,SE1->E1_IRRF)
	Endif

Return aValImp

//-------------------------------------------------------------------
/*/{Protheus.doc} FCaInssBxCP

@param nBaseTit 	- Base de calculo
@param lIRPFBaixa	- Informa se o IRF é na Baixa
@param lCalcIssBx	- Informa se o ISS é na Baixa
@param lPCCBaixa	- Informa se o PCC é na Baixa
@return aValImp
@author Jose.Gavetti
@since  18/09/2015
/*/
//-------------------------------------------------------------------
Function FCaInssBxCP(nBaseTit,lIRPFBaixa,lCalcIssBx,lPCCBaixa)

Local nInss := 0

If FindFunction ("FCaInsBxCP")
	nInss := FCaInsBxCP(nBaseTit,lIRPFBaixa,lCalcIssBx,lPCCBaixa)
Else
	Alert(STR0052)  //'Por favor, solicite ao administrador do sistema que seja atualizado o fonte FINXOLD.PRX'
Endif	

Return nInss


//-------------------------------------------------------------------
/*/{Protheus.doc} FCaInsPJBx

@param nBaseIns 	- Base de calculo
@param nCalcInss	- Valor calculado do INSS
@param nINSSTot		- INSS acumulado no periodo

@return nValInss	- Valor do INSS

@author  Andrea Verissimo Santiago
@since  04/04/2004
/*/
//-------------------------------------------------------------------
Function FCaInsPJBx(nBaseIns,nCalcInss,nINSSTot)

Local nValInss := 0	//valor inss calculado com base do parametro.

If FindFunction ("FCaInPJBx")
	nValInss := FCaInPJBx(nBaseIns,@nCalcInss,@nINSSTot)
Else
	Alert(STR0052)  //'Por favor, solicite ao administrador do sistema que seja atualizado o fonte FINXOLD.PRX'
Endif	

Return nValInss


//-------------------------------------------------------------------
/*/{Protheus.doc} FCaInsPFBx

Cálculo de INSS na Baixa - PF

@param nBaseIns 	- Base de calculo
@param lZeraInss	- Apos gerar o INSS pela primeira mesmo com 
						valor minimo calculado deve ser gerado.
@param nCalcInss	- Valor calculado do INSS
@param nINSSTot		- INSS acumulado no periodo

@return nValInss	- Valor do INSS

@author  Andrea Verissimo Santiago
@since  04/04/2004
/*/
//-------------------------------------------------------------------
Function FCaInsPFBx(nBaseIns,lZeraInss,nCalcInss,nINSSTot)

Local nValInss := 0	//valor inss calculado com base do parametro.

If FindFunction ("FCaInPFBx")
	nValInss := FCaInPFBx(nBaseIns,@lZeraInss,@nCalcInss,@nINSSTot)
Else
	Alert(STR0052)  //'Por favor, solicite ao administrador do sistema que seja atualizado o fonte FINXOLD.PRX'
Endif	

Return nValInss


//---------------------------------------------------------------------------------
/*/{Protheus.doc} InssCaPFBx

Verifica o valor CALCULADO de inss de um fornecedor num determinado periodo.

@param nBaseIns 	- Base de calculo
@param lZeraInss	- Apos gerar o INSS pela primeira mesmo com 
						valor minimo calculado deve ser gerado.
@param nCalcInss	- Valor calculado do INSS
@param nINSSTot		- INSS acumulado no periodo

@return nValInss	- Valor do INSS

@author  Andrea Verissimo Santiago
@since  04/04/2004
/*/
//---------------------------------------------------------------------------------
Function InssCaPFBx(nBaseIns,lZeraInss,nCalcInss,nINSSTot)

Local nValor := 0

If FindFunction ("InsCaPFBx")
	nValor := InsCaPFBx(nBaseIns,@lZeraInss,@nCalcInss,@nINSSTot)
Else
	Alert(STR0052)  //'Por favor, solicite ao administrador do sistema que seja atualizado o fonte FINXOLD.PRX'
Endif	

Return nValor


//---------------------------------------------------------------------------------
/*/{Protheus.doc} InssCaPJBx

Verifica o valor CALCULADO de inss de um fornecedor num determinado periodo 
que retenha o imposto na baixa.

@param cFornece - Código do Fornecedor
@param cLoja	- Loja do Fornecedor
@param cNomeFor	- Nome do Fornecedor
@param dEmissao	- Data de emissão
@param dVencRea	- Data de vencimento real
@param nInsRest	- Valor restante de inss

@return nValor	- Valor do INSS

@author  Andrea Verissimo Santiago
@since  04/04/2004
/*/
//---------------------------------------------------------------------------------
Function InssCaPJBx(cFornece,cLoja,cNomeFor,dEmissao,dVencRea,nInsRest)

Local nValor := 0

If FindFunction ("InsCaPJBx")
	nValor := InsCaPJBx(cFornece,cLoja,cNomeFor,dEmissao,dVencRea,@nInsRest)
Else
	Alert(STR0052)  //'Por favor, solicite ao administrador do sistema que seja atualizado o fonte FINXOLD.PRX'
Endif	

Return nValor




//---------------------------------------------------------------------------------
/*/{Protheus.doc} FGrvInsSe5

Grava o relacionamento dos impostos da tabela SE5 na SFQ 

@author  Andrea Verissimo Santiago
@since  04/04/2004
/*/
//---------------------------------------------------------------------------------
Function FGrvInsSe5(aListTit,nRegOri,nInss,cTipo)

Local aTitSe2 :=	{}

If FindFunction ("FGrvInSe5")
	aTitSe2 := FGrvInSe5(aListTit,nRegOri,nInss,cTipo)
Else
	Alert(STR0052)  //'Por favor, solicite ao administrador do sistema que seja atualizado o fonte FINXOLD.PRX'
Endif	

Return aTitSe2


//---------------------------------------------------------------------------------
/*/{Protheus.doc} InssAcmBx

Verifica o valor RETIDO de inss de um fornecedor num determinado periodo quando 
imposto retido na baixa.

@param cFornece - Código do Fornecedor
@param cLoja	- Loja do Fornecedor
@param cNomeFor	- Nome do Fornecedor
@param dEmissao	- Data de emissão
@param dVencRea	- Data de vencimento real

@return nValor	- Valor do INSS acumulado no periodo

@author  Andrea Verissimo Santiago
@since  04/04/2004
/*/
//---------------------------------------------------------------------------------
Function InssAcmBx(cFornece,cLoja,cNomeFor,dEmissao,dVencRea)

Local nValor := 0

If FindFunction ("InsAcmBx")
	nValor := InsAcmBx(cFornece,cLoja,cNomeFor,dEmissao,dVencRea)
Else
	Alert(STR0052)  //'Por favor, solicite ao administrador do sistema que seja atualizado o fonte FINXOLD.PRX'
Endif	

Return nValor



//-------------------------------------------------------------------
/*/{Protheus.doc} FpropCR
Proporcionaliza os valores dos impostos conforme passado nos parâmetros.

@author TOTVS S/A
@since  07/04/15
/*/
//-------------------------------------------------------------------
Function FpropCR(nE1Val, nVlPis, nVlCof, nVlCsl, nVlIr, nVlIns, nVlIs, nVlRec) //MYT
	Local aArea		:= GetArea()
	Local lPropBx  := SuperGetMv("MV_PROPBX",.F.,"2") == "1"
	Local lPccBxCr		:= If (FindFunction("FPccBxCr"),FPccBxCr(.T.),.F.) //Controla o Pis Cofins e Csll na baixa (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default))
	Local lIrPjBxCr	:= If (FindFunction("FIrPjBxCr"),FIrPjBxCr(.T.),.F.) //Controla IRPJ na baixa
	Local nImpPis	:= 0
	Local nImpCof	:= 0
	Local nImpCsl	:= 0
	Local nImpIrf	:= 0
	Local nImpIns	:= 0
	Local nImpIss	:= 0
	Local aImp		:= {}

	Default nE1Val	:= SE1->E1_VALOR
	Default nVlPis	:= 0
	Default nVlCof	:= 0
	Default nVlCsl	:= 0
	Default nVlIr	:= 0
	Default nVlIns	:= 0
	Default nVlIs	:= 0
	Default nVlRec	:= 0

	If lPropBx
		If !lPccBxCr .and. nVlPis > 0
			nImpPis	:= (nVlPis * nVlRec / nE1Val)
		ElseIf lPccBxCr
			nImpPis	:= 0
		EndIf
		If !lPccBxCr .and. nVlCof > 0
			nImpCof	:= (nVlCof * nVlRec / nE1Val)
		ElseIf lPccBxCr
			nImpCof	:= 0
		EndIf
		If !lPccBxCr .and. nVlCsl > 0
			nImpCsl	:= (nVlCsl * nVlRec / nE1Val)
		ElseIf lPccBxCr
			nImpCsl	:= 0
		EndIf
		If !lIrPjBxCr .and. nVlIr > 0
			nImpIrf	:= (nVlIr * nVlRec / nE1Val)
		ElseIf lIrPjBxCr
			nImpIrf	:= 0
		EndIf
		If nVlIns > 0
			nImpIns	:= (nVlIns * nVlRec / nE1Val)
		Else
			nImpIns	:= 0
		EndIf
		If nVlIs > 0
			nImpIss	:= (nVlIs * nVlRec / nE1Val)
		Else
			nImpIss	:= 0
		EndIf
	EndIf

	Aadd(aImp,{ nImpPis, nImpCof, nImpCsl, nImpIrf, nImpIns, nImpIss})

	RestArea(aArea)

Return(aImp)

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//± Funcao	   	  	: VerTpDoc
//± Autor         : Totvs
//± Data          : 18/03/2015
//± Uso           : Rotina para verificação e classificação
//±						do tipo de documento
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Function VerTpDoc(cTpDoc)

	Local cDescDoc := ""
	Local aTpDoc		:= {}
	Local nPos			:= 0

	aTpDoc := {{'AP', STR0011},; 		// 'Aplicação'
			{'BA', STR0012},; 			// 'Baixa de titulo'
			{'BD', STR0013},; 			// 'Transferência por borderô descontado'
			{'BL', STR0014},; 			// 'Baixa por Lote'
			{'C2', STR0015},; 			// 'Correção Monetária de titulo em carteira descontada'
			{'CA', STR0016},; 			// 'Cancelamento de Cheque Avulso'
			{'CB', STR0017},; 			// 'Cancelamento de Transferência por borderô descontado'
			{'CD', STR0018},; 			// 'Cheque pré datado via Movimento Bancário Manual'
			{'CH', STR0019},; 			// 'Cheque'
			{'CM', STR0020},; 			// 'Correção Monetária'
			{'CP', STR0021},; 			// 'Compensação CR ou CP'
			{'CX', STR0020},; 			// 'Correção Monetária'
			{'D2', STR0022},; 			// 'Desconto em título em carteira descontada'
			{'DB', STR0023},; 			// 'Despesas bancárias'
			{'DC', STR0024},; 			// 'Desconto'
			{'E2', STR0025},; 			// 'Estorno de movimento de desconto (Cobrança Descontada)'
			{'EC', STR0026},; 			// 'Estorno de cheque'
			{'EP', STR0027},; 			// 'Empréstimo'
			{'ES', STR0028},; 			// 'Estorno de Baixa'
			{'IS', STR0029},; 			// 'Imposto Substitutivo (Localizações)'
			{'I2', STR0030},; 			// 'IOF cobrado em transferência de títulos para cobrança descontada'
			{'J2', STR0031},; 			// 'Juros de titulo em carteira descontada'
			{'JR', STR0032},; 			// 'Juros'
			{'LJ', STR0033},; 			// 'Movimento do SigaLoja'
			{'M2', STR0034},; 			// 'Multa de titulo em carteira descontada'
			{'MT', STR0035},; 			// 'Multa'
			{'OC', STR0036},; 			// 'Outros Créditos'
			{'OD', STR0037},; 			// 'Outras Despesas'
			{'OG', STR0038},; 			// 'Outras Ganancias (Localizações)'
			{'PA', STR0039},; 			// 'Inclusão PA'
			{'PE', STR0040},; 			// 'Pagamento Empréstimo'
			{'R$', STR0041},; 			// 'Dinheiro'
			{'RA', STR0042},; 			// 'Inclusão RA'
			{'RF', STR0043},; 			// 'Resgate de Aplicações'
			{'SG', STR0044},; 			// 'Entrada de Dinheiro no Caixa (Loja)'
			{'TC', STR0045},; 			// 'Troco'
			{'TE', STR0046},; 			// 'Estorno de transferência (Movimento Bancário Manual)'
			{'TL', STR0047},; 			// 'Tolerância de Recebimento'
			{'TR', STR0048},; 			// 'Transferência para carteira descontada'
			{'V2', STR0049},; 			// 'Baixa de titulo em carteira descontada'
			{'VL', STR0050},; 			// 'Baixa de titulo'
			{'VM', STR0051}} 			// 'Variação Monetária'

	For nPos := 1 to len(aTpDoc)
		If aScan(aTpDoc[nPos],cTpDoc) > 0
			cDescDoc 	:= aTpDoc[nPos,2]
			Exit
		EndIf
	Next

Return cDescDoc

//-------------------------------------------------------------------
/*/{Protheus.doc}SumDayIRPJ
Verificar total baixado diário do IRPJ(Imposto de renda pessao jurídica).

@param cCart - Carteira P = Pagar, R = Receber
@param cFil - Filial
@param cCodigo - Código do Cliente/Forn.
@param cLoja - Loja do Cliente/Forn.
@param cTipo - Tipo do Cliente/Forn.
@param dRef - Data de Referência

@return aDados - Retorna o total pendente de IRRF baixado no dia.
aDados[1] ->Irrf
aDados[2] ->lVermin - Verifica valor minimo de retenção.

@author Leonardo Castro
@since  23/02/2016
/*/
//-------------------------------------------------------------------
Function SumDayIRPJ(cCart,cFil,cCodigo,cLoja,cTipo,dRef,cFilOrig,cEdCodRet)

	Local aArSE2 As Array
	Local aArSE1 As Array
	Local aArSE5 As Array
	Local aAreaAt As Array
	Local aArea As Array
	Local aCliFor As Array
	Local aDados As Array
	Local aFil As Array
	Local cAliasQry As Character
	Local cChave As Character
	Local aCodRet As Array
	Local cFiliais As Character
	Local cSerNeg As Character
	Local cSepRec As Character
	Local cSepProv As Character
	Local cQuery As Character
	Local cFilSA1 As Character
	Local lLojaAtu As Logical
	Local lPCCBaixa As Logical
	Local lCalcIssBx As Logical
	Local lIRPJBaixa As Logical
	Local lLiquido As Logical
	Local nKco As Numeric
	Local nVret As Numeric
	Local nIrrf As Numeric
	Local nValTit As Numeric
	Local nBSEIrf As Numeric
	Local nBaseIrf As Numeric
	Local nSaldo As Numeric
	Local nImpRetEmi As Numeric
	Local nTCalcIrf As Numeric
	Local nTotRtIrf As Numeric
	Local nTBCalIrf As Numeric
	Local nTBRetIrf As Numeric
	Local lFina061 As Logical
	Local lFina891 As Logical
	Local lFina330 As Logical
	Local nPercIRF As Numeric
	Local lJurMulDes As Logical
	Local lMotBxMBco As Logical
	Local nAbat As Numeric
	Local lRaRtImp As Logical
	Local lBQ10925 As Logical
	Local nTamPrfTit As Numeric
	Local nI As Numeric
	Local cChaveTit As Character
	Local cChaveFK7 As Character
	Local lInssBx As Logical

	Default cFilOrig	:= cFilAnt
	Default cEdCodRet	:= ""

	If __lRpoR33 == NIL
		__lRpoR33 := GetRpoRelease() >= "12.1.033"
	Endif

	If __lRpoR33
		aDados := SumDayFKIR(cCart,cFil,cCodigo,cLoja,cTipo,dRef,cFilOrig,cEdCodRet)
	Else
		aArSE2		:= SE2->(getArea())
		aArSE1		:= SE1->(getArea())
		aArSE5		:= SE5->(getArea())
		aAreaAt		:= getArea()
		aArea		:= GetArea()
		aCliFor 	:= {}
		aDados		:= Array(4)
		aFil		:= {cFilAnt}
		cAliasQry 	:= GetNextAlias()
		cChave		:= ""
		aCodRet		:= {}
		cFiliais	:= ""
		cSerNeg		:= If("|"$MV_CRNEG,"|",",")
		cSepRec		:= If("|"$MVRECANT,"|",",")
		cSepProv  	:= If("|"$MVPROVIS,"|",",")
		cQuery 		:= ""
		cFilSA1		:= ""
		lLojaAtu	:= ( SuperGetMv( "MV_LJ10925",.F., "1" ) == "1" )
		lPCCBaixa	:= IIF(cCart == "P", SuperGetMv("MV_BX10925",.T.,"2") == "1", SuperGetMv("MV_BR10925",.T.,"2") == "1")
		lCalcIssBx	:= IIF(cCart == "P",IsIssBx("P"),.F.)
		lIRPJBaixa	:= IIF(cCart == "P", SA2->A2_CALCIRF == "2", FIrPjBxCr(.T.) )
		lLiquido	:= IIF(cCart == "P", SuperGetMv("MV_BP10925",.F., "1") == "2", SuperGetMv("MV_BQ10925",.F., "1") == "2" ) // Default (Bruto)
		nKco 		:= 0
		nVret		:= 0
		nIrrf		:= 0
		nValTit		:= 0
		nBSEIrf		:= 0
		nBaseIrf	:= 0
		nSaldo		:= 0
		nImpRetEmi	:= 0
		nTCalcIrf	:= 0
		nTotRtIrf	:= 0
		nTBCalIrf	:= 0	//Base de cálculo
		nTBRetIrf	:= 0	//Base de retenção
		lFina061	:= FwIsInCallStack("Fa061Borde")
		lFina891	:= FwIsInCallStack("PIXGerImp")
		lFina330	:= FwIsInCallStack("fA330Comp")
		nPercIRF	:= 0
		lJurMulDes	:= (SuperGetMv("MV_IMPBAIX",.t.,"2") == "1")
		// Considera baixas que geram ou nao movimento bancario.
		// 1 = Somente os motivos que geram movimento bancario
		// 2 = Considera todos os motivos de baixa.
		lMotBxMBco	:= (SuperGetMv("MV_MB10925",.t.,"2") == "1")
		nAbat		:= 0
		lRaRtImp	:= FRaRtImp()
		lBQ10925	:= SuperGetMV("MV_BQ10925",,"2") == "1" .And. !lRaRtImp
		nTamPrfTit	:= LenCmpTitP( cCart , lIRPJBaixa )
		nI			:= 0
		cChaveTit 	:= ""
		cChaveFK7	:= ""
		lInssBx		:= SuperGetMv("MV_INSBXCP",.F.,"2") == "1"

		aTitCIrf	:= {}

		//aCliFor := getCliFor(cCart, IIF(cCart=="P",SA2->A2_FILIAL,SA1->A1_FILIAL), cCodigo, cLoja,aFil )

		cChave := Iif(!lIRPJBaixa,cTipo,"") + cCodigo + Iif(lLojaAtu,cLoja,"")

		//Verifico se já foi gerado o título de imposto para o cliente/fornecedor da filial corrente.
		If cCart == "P"
			aCodRet := getCodRet()
			nIrrf := getValorTx(cFil,cChave,MVTAXA,"IRF",aCodRet[1],dRef,cCart,nTamPrfTit)
			nIrrf += getValorTx(cFil,cChave,MVTXA ,"IRF",aCodRet[1],dRef,cCart,nTamPrfTit)
		Else
			nIrrf := getValorTx(cFil,cChave,"IRF"	,"IRF",cEdCodRet,dRef,cCart,nTamPrfTit)
			nIrrf += getValorTx(cFil,cChave,MVIRABT ,"IRF",cEdCodRet,dRef,cCart,nTamPrfTit)
			nIrrf += getValorTx(cFil,cChave,MVTAXA ,"IRF",cEdCodRet,dRef,cCart,nTamPrfTit)
		EndIf

		aDados[2] := .T.

		If !lIRPJBaixa
			nIrrf := 0
		EndIf

		//Se sim, não aplico o cumulatividade, vejo apenas o saldo restante do título.
		If nIrrf > 0
			aDados[1]	:= 0
			aDados[2]	:= .F.
			aDados[3]	:= nIrrf 
			Return(aDados)
		EndIf

		//aFil - Contém as filiais que serão utilizadas com base para realizar o cálculo de mínimo.
		For nKco := 1 to Len(aFil)
			cFiliais += xFilial("SE5", aFil[nKco])
			If nKco < Len(aFil)
				cFiliais += ","
			EndIf
		Next nKco

		//Tratamento para IRRF na Baixa - Contas a Receber
		If lIRPJBaixa
			If __oQryIrpj == Nil .Or. Len(aCliFor) > 0
				cQuery := "	SELECT E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_TIPO,E5_CLIFOR,E5_LOJA,"
				cQuery += 		"E5_SEQ,E5_VALOR,E5_VRETIRF,E5_DATA,E5_VLJUROS,"
				cQuery += 		"E5_VLMULTA,E5_VLDESCO,E5_PRETIRF,E5_MOTBX,"
				cQuery += 		"E5_DOCUMEN,E5_FORNADT,E5_LOJAADT,E5_RECPAG,E5_FILORIG,E5_VLMULTA, E5_TABORI, E5_IDORIG, E5_BASEIRF,  "
		
				cQuery += 		"SE1.E1_SALDO, SE1.E1_VALOR, SE1.E1_BASEIRF, SE1.E1_INSS, SE1.E1_PIS, SE1.E1_COFINS, SE1.E1_CSLL, "
				cQuery += 		"SE1.E1_ISS, SE1.E1_FATURA, SE1.E1_NUMLIQ,SE1.E1_ORIGEM,SE1.E1_NATUREZ, SE1.R_E_C_N_O_ RECNOSE1,  "
		
				cQuery += 		"SED.ED_CALCIRF , SED.ED_PERCIRF, SED.ED_CODRET, "
				If lInssBx
					cQuery += 		"E5_PRETINS, E5_VRETINS, "
				EndIf
				cQuery += 		"E5_VRETISS, E5_PRETPIS, E5_PRETCOF, E5_PRETCSL, E5_VRETPIS, E5_VRETCOF, E5_VRETCSL, "
		
				cQuery += 		"( SELECT COUNT(*) ATG "
				cQuery += 			"FROM " + RetSqlName( "SE5" ) + " ANTERIOR "
				cQuery += 			"WHERE ANTERIOR.D_E_L_E_T_ = ' ' "
				cQuery += 				" AND ANTERIOR.E5_SITUACA NOT IN ( 'C' , 'E' , 'X' ) "
				cQuery += 				" AND ANTERIOR.E5_TIPODOC <> 'ES' "
				cQuery += 				" AND ANTERIOR.E5_DATA < SE5.E5_DATA "
		
				cQuery += 				" AND ANTERIOR.E5_DATA >= SE1.E1_EMISSAO "
		
				cQuery += 				" AND ANTERIOR.E5_FILORIG = SE5.E5_FILORIG "
				cQuery += 				" AND ANTERIOR.E5_PREFIXO = SE5.E5_PREFIXO "
				cQuery += 				" AND ANTERIOR.E5_NUMERO = SE5.E5_NUMERO "
				cQuery += 				" AND ANTERIOR.E5_PARCELA = SE5.E5_PARCELA "
				cQuery += 				" AND ANTERIOR.E5_TIPO = SE5.E5_TIPO "
				cQuery += 				" AND ANTERIOR.E5_CLIFOR = SE5.E5_CLIFOR "
				cQuery += 				" AND ANTERIOR.E5_LOJA = SE5.E5_LOJA "
				cQuery += 				" AND ANTERIOR.E5_RECPAG = SE5.E5_RECPAG "
				cQuery += 				" AND ANTERIOR.E5_SEQ < SE5.E5_SEQ "
				cQuery += 				" AND ANTERIOR.E5_TIPO NOT IN " + FormatIn(MVABATIM,"|")
				cQuery += 				" AND ANTERIOR.E5_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv)
				cQuery += 				" AND ANTERIOR.E5_TIPO NOT IN " + FormatIn(MV_CRNEG,cSerNeg)
				cQuery += 				" AND ANTERIOR.E5_RECPAG = 'R' "
		
				cQuery += 		 	" AND (ANTERIOR.E5_MOTBX NOT IN ('FAT','IRF','PCC','LIQ','STP','DSD','ISS','INS','IMR') "
				cQuery += 			" OR (ANTERIOR.E5_MOTBX='IRF' AND  ANTERIOR.E5_TIPO IN " + FormatIn(MVRECANT,cSepRec) + " ) ) AND "
				cQuery += 		" NOT EXISTS ( "
				cQuery += 					" SELECT A.E5_NUMERO "
				cQuery += 					" FROM "+RetSqlName("SE5")+" A "
				cQuery += 					" WHERE A.E5_FILIAL = ANTERIOR.E5_FILIAL  AND"
				cQuery += 						" A.E5_PREFIXO	=	ANTERIOR.E5_PREFIXO AND "
				cQuery += 						" A.E5_NUMERO	=	ANTERIOR.E5_NUMERO AND "
				cQuery += 						" A.E5_PARCELA	=	ANTERIOR.E5_PARCELA AND "
				cQuery += 						" A.E5_TIPO		=	ANTERIOR.E5_TIPO AND "
				cQuery += 						" A.E5_CLIFOR	=	ANTERIOR.E5_CLIFOR AND "
				cQuery += 						" A.E5_LOJA		=	ANTERIOR.E5_LOJA AND "
				cQuery += 						" A.E5_SEQ		=	ANTERIOR.E5_SEQ AND "
				cQuery += 						" A.E5_TIPODOC='ES' AND "
				cQuery += 						" A.E5_RECPAG = 'P' AND "
				cQuery +=						" A.D_E_L_E_T_ = ' ')"
		
				cQuery += 			") ATG, "
		
				cQuery += 		" ( SELECT COUNT(*) LIQFAT "
				cQuery += 			" FROM " + RetSqlName( "SE5" ) + " LIQFAT "
				cQuery += 			" WHERE LIQFAT.D_E_L_E_T_ = ' ' "
				cQuery += 				" AND LIQFAT.E5_SITUACA NOT IN ( 'C' , 'E' , 'X' ) "
				cQuery += 				" AND LIQFAT.E5_TIPODOC <> 'ES' "
		
				cQuery += 				" AND LIQFAT.E5_DATA >= SE1.E1_EMISSAO "
		
				cQuery += 				" AND LIQFAT.E5_FILIAL = SE5.E5_FILIAL "
				cQuery += 				" AND LIQFAT.E5_PREFIXO = SE5.E5_PREFIXO "
				cQuery += 				" AND LIQFAT.E5_NUMERO = SE5.E5_NUMERO "
				cQuery += 				" AND LIQFAT.E5_PARCELA = SE5.E5_PARCELA "
				cQuery += 				" AND LIQFAT.E5_TIPO = SE5.E5_TIPO "
				cQuery += 				" AND LIQFAT.E5_CLIFOR = SE5.E5_CLIFOR "
				cQuery += 				" AND LIQFAT.E5_LOJA = SE5.E5_LOJA "
				cQuery += 				" AND LIQFAT.E5_RECPAG = SE5.E5_RECPAG "
		
				cQuery += 				" AND LIQFAT.E5_TIPO NOT IN " + FormatIn(MVABATIM,"|")
				cQuery += 				" AND LIQFAT.E5_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv)
				cQuery += 			" AND LIQFAT.E5_RECPAG = 'R' "
				cQuery += 			" AND LIQFAT.E5_MOTBX IN ('FAT','LIQ')  AND "
		
				cQuery += 		" NOT EXISTS ( "
				cQuery += 					" SELECT A.E5_NUMERO "
				cQuery += 					" FROM "+RetSqlName("SE5")+" A "
				cQuery += 					" WHERE A.E5_FILIAL = LIQFAT.E5_FILIAL  AND"
				cQuery +=							" A.E5_PREFIXO = LIQFAT.E5_PREFIXO AND "
				cQuery +=							" A.E5_NUMERO = LIQFAT.E5_NUMERO AND "
				cQuery +=							" A.E5_PARCELA = LIQFAT.E5_PARCELA AND "
				cQuery +=							" A.E5_TIPO =	LIQFAT.E5_TIPO AND "
				cQuery +=							" A.E5_CLIFOR	= LIQFAT.E5_CLIFOR AND "
				cQuery +=							" A.E5_LOJA =	LIQFAT.E5_LOJA AND "
				cQuery +=							" A.E5_SEQ = LIQFAT.E5_SEQ AND "
				cQuery +=							" A.E5_TIPODOC ='ES' AND "
				cQuery +=							" A.E5_RECPAG ='P' AND "
				cQuery +=					" A.D_E_L_E_T_ = ' ')"
		
				cQuery += 			" ) LIQFAT, "
		
				cQuery += "	SE5.R_E_C_N_O_ RECNOSE5 "
				cQuery += " FROM " + RetSqlName( "SE5" ) + " SE5 "
		
				cQuery += " INNER JOIN " + RetSqlName( "SE1" ) + " SE1 "
				cQuery += 	 	" ON SE1.E1_FILORIG = SE5.E5_FILORIG AND SE1.E1_PREFIXO = SE5.E5_PREFIXO AND SE1.E1_NUM = SE5.E5_NUMERO "
				cQuery += 		" AND SE1.E1_PARCELA = SE5.E5_PARCELA "
				cQuery +=		" AND SE1.E1_TIPO = SE5.E5_TIPO AND SE1.E1_CLIENTE = SE5.E5_CLIFOR AND SE1.E1_LOJA = SE5.E5_LOJA "
				cQuery +=		" AND SE1.D_E_L_E_T_ = ' ' "
				If !IsInCallStack("fA070Tit") .and. !IsInCallStack("fA200Ger")
					cQuery +=     "AND E1_NUMBOR = '"+Space(TamSX3("E1_NUMBOR")[1])+"' "
				EndIf
		
				cQuery += " INNER JOIN " + RetSqlName( "SED" ) + " SED ON "
				If !Empty(FWFilial("SE1")) .And. !Empty(FWFilial("SED"))
					cQuery += " SE1.E1_FILIAL = SED.ED_FILIAL AND "
				Else
					cQuery += " SED.ED_FILIAL = ? AND "
				Endif
		
				cQuery += " SE1.E1_NATUREZ = SED.ED_CODIGO AND "
		
				cQuery += " SED.ED_CALCIRF = 'S' AND SED.D_E_L_E_T_ = ' ' "
		
				cQuery += "	LEFT JOIN "+ RetSqlName( "SEA" ) + " SEA ON "
		
				If !Empty(FWFilial("SE1")) .And. !Empty(FWFilial("SEA"))
					cQuery += " SE1.E1_FILIAL = SEA.EA_FILIAL AND "
				EndIf
				cQuery += 			" SE1.E1_NUMBOR = SEA.EA_NUMBOR AND SE1.E1_PREFIXO = SEA.EA_PREFIXO "
				cQuery += 			" AND SE1.E1_NUM = SEA.EA_NUM "
				cQuery += 			" AND SE1.E1_CLIENTE = SEA.EA_FORNECE "
				cQuery += 			" AND SE1.E1_LOJA = SEA.EA_LOJA "
				cQuery += 			" AND SE1.E1_PARCELA = SEA.EA_PARCELA "
				cQuery += 			" AND SE1.E1_TIPO = SEA.EA_TIPO "
				cQuery += 			" AND SEA.EA_CART = 'R' AND SEA.D_E_L_E_T_ = ' ' "
		
				cQuery += " WHERE E5_FILIAL IN (?) AND "
		
				If Len(aCliFor) > 0
					//Verificar determinados clientes (raiz do CNPJ)
					cQuery += "( "
					For nKco := 1 to Len(aCliFor)
						cQuery += "(E5_CLIFOR ='"   + aCliFor[nKco,1]  + "' AND "
						cQuery += "E5_LOJA='"       + aCliFor[nKco,2]  + "') OR "
					Next nKco
					//Retiro o ultimo OR
					cQuery := Left( cQuery, Len( cQuery ) - 4 )
					cQuery += ") AND "
				Else  //Apenas o cliente Atual
					cQuery += "E5_CLIFOR= ? AND "
					If lLojaAtu  //Considero apenas a loja atual
						cQuery += "E5_LOJA= ? AND "
					EndIf
				EndIf
		
				cQuery += "	E5_DATA = ? AND "
				cQuery += "	E5_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " AND "
				cQuery += "	E5_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "
		
				If lBQ10925 .or. lFina330
					cQuery += "	E5_TIPO NOT IN " + FormatIn(MVRECANT,cSepRec) + " AND "
				EndIf
		
				If !lJurMulDes //Desconsidero baixas onde foi baixado somente o valor da Multa e Juros.
					cQuery += "	E5_TIPODOC NOT IN ('MT') AND "
					cQuery += "	E5_TIPODOC NOT IN ('JR') AND "
					cQuery += "	(E5_VALOR <> SE5.E5_VLMULTA OR SE5.E5_VLMULTA = 0) AND "
					cQuery += "	(E5_VALOR <> SE5.E5_VLJUROS OR SE5.E5_VLJUROS = 0) AND "
				EndIf
		
				cQuery += "	E5_TIPO NOT IN " + FormatIn(MV_CRNEG,cSerNeg)  + " AND "
				cQuery += "	E5_RECPAG = 'R' AND "
		
				cQuery += 		" (E5_MOTBX NOT IN ('FAT','IRF','PCC','LIQ','STP','DSD','ISS','INS','IMR') "
		
				cQuery += 			" OR (E5_MOTBX='IRF' AND  E5_TIPO IN " + FormatIn(MVRECANT,cSepRec) + " ) ) AND "
		
				cQuery += "	E5_SITUACA NOT IN ( 'C' , 'E' , 'X' ) AND "
				cQuery += "SE5.D_E_L_E_T_ = ' ' "
				cQuery += "AND NOT EXISTS ( "
				cQuery += "SELECT A.E5_NUMERO "
				cQuery += "FROM "+RetSqlName("SE5")+" A "
				cQuery += "WHERE A.E5_FILIAL IN (?) AND "
				cQuery +=		"A.E5_PREFIXO=SE5.E5_PREFIXO AND "
				cQuery +=		"A.E5_NUMERO=SE5.E5_NUMERO AND "
				cQuery +=		"A.E5_PARCELA=SE5.E5_PARCELA AND "
				cQuery +=		"A.E5_TIPO=SE5.E5_TIPO AND "
				cQuery +=		"A.E5_CLIFOR=SE5.E5_CLIFOR AND "
				cQuery +=		"A.E5_LOJA=SE5.E5_LOJA AND "
				cQuery +=		"A.E5_SEQ=SE5.E5_SEQ AND "
				cQuery +=		"A.E5_TIPODOC='ES' AND "
				cQuery +=		"A.E5_RECPAG<>'R' AND "
				cQuery +=		"A.D_E_L_E_T_ = ' ')"
		
				cQuery += " ORDER BY RECNOSE5"
		
				cQuery := ChangeQuery( cQuery )
				
				__oQryIrpj := FWPreparedStatement():New(cQuery)
			EndIf
		
			nI := 1
			If !Empty(FWFilial("SE1")) .And. !Empty(FWFilial("SED"))
				__oQryIrpj:SetIn(nI,StrTokArr( cFiliais, "," ))
			Else
				__oQryIrpj:SetString(nI,xFilial( "SED" , cFilOrig ))
				nI++
				__oQryIrpj:SetIn(nI,StrTokArr( cFiliais, "," ))
			Endif
			nI++
			If !(Len(aCliFor) > 0)
				__oQryIrpj:SetString(nI,cCodigo)
				nI ++
				If lLojaAtu
					__oQryIrpj:SetString(nI,cLoja)
					nI ++
				EndIf
			EndIf
			__oQryIrpj:SetString(nI,DToS( dRef ))
			nI ++
			__oQryIrpj:SetIn(nI,StrTokArr( cFiliais, "," ))
			
			cQuery := __oQryIrpj:GetFixQuery()
		
		EndIf

		If Select(cAliasQry) > 0
			( cAliasQry )->( dbCloseArea() )
		EndIf

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

		While !( cAliasQry )->( Eof())

			If lIRPJBaixa .And. lMotBxMBco .and. ((cAliasQry)->E5_MOTBX <> "CMP")
				If !Fa080MovBc((cAliasQry)->E5_MOTBX)
					(cAliasQry)->(DbSkip())
					Loop
				Endif
			Endif

			If lIRPJBaixa .And. lRaRtImp .and. (cAliasQry)->E5_MOTBX == "CMP" .AND. cCart == "R"
				(cAliasQry)->(DbSkip())
				Loop
			EndIf			

			nBSEIrf	:= IIF(!Empty((cAliasQry)->E1_BASEIRF),(cAliasQry)->E1_BASEIRF, (cAliasQry)->E1_VALOR)

			IF lIRPJBaixa
				nImpRetEmi    := 0
				nSaldo 		:= (cAliasQry)->E1_SALDO
				lLiqFat		:= (!Empty((cAliasQry)->E1_FATURA) .Or. !Empty((cAliasQry)->E1_NUMLIQ))
				nValTit 		:= (cAliasQry)->E1_VALOR
				If !lCalcIssBx
					nImpRetEmi := (cAliasQry)->E1_ISS
				EndIf
				If !lPCCBaixa
					nImpRetEmi += (cAliasQry)->(E1_PIS+E1_COFINS+E1_CSLL)
				EndIf
				nImpRetEmi += (cAliasQry)->E1_INSS

				IF cCart=="R"
					nValTit -= nImpRetEmi
				EndIf

				nVret := IIF(lPccBaixa .And. (cAliasQry)->E5_PRETPIS <> "1", (cAliasQry)->(E5_VRETPIS+E5_VRETCOF+E5_VRETCSL), 0)
				nVret += IIF(lCalcIssBx , (cAliasQry)->E5_VRETISS, 0)
				nVret += IIF(lIRPJBaixa .And. (cAliasQry)->E5_PRETIRF <> "1", (cAliasQry)->E5_VRETIRF, 0)

				aArea	:= GetArea()
				If SE1->(dbSeek(xFilial("SE1")+( cAliasQry )->E5_PREFIXO + ( cAliasQry )->E5_NUMERO + ( cAliasQry )->E5_PARCELA+"AB-"+( cAliasQry )->E5_CLIFOR + ( cAliasQry )->E5_LOJA))
					nAbat	:= SE1->E1_VALOR
				EndIf
				RestArea(aArea)

				//Baixa que não atingiu o mínimo, mesmo dia ou Baixa de Faturas com Impostos na Baixa que já foram retidos
				If nSaldo == 0 .And. (cAliasQry)->ATG == 0  .And. ( (!lLiqFat .And. (nBSEIrf == (( cAliasQry )->E5_VALOR+nImpRetEmi+nVret) ) .Or. ;
					(cAliasQry)->E5_PRETIRF == "1" ) .Or. 	(lLiqFat .And. nValTit == (( cAliasQry )->E5_VALOR+nVret))  )
					nBaseIrf := nBSEIrf
					AADD(aTitCIrf,{(cAliasQry)->E5_TABORI, (cAliasQry)->E5_IDORIG})

				//Baixas Parciais de títulos que geram Liquidações/Faturas
				ElseIf nSaldo == 0 .And. !lLiqFat  .And. ( cAliasQry )->LIQFAT > 0
					nBaseIrf := nBSEIrf - ( cAliasQry )->E5_VALOR

				//Recomposição de saldo de rotinas que utilizaram as rotinas de baixas.
				ElseIf nSaldo == 0 .And. !lLiqFat .AND. IIF(cCart=="R",(( cAliasQry )->E1_VALOR == ( cAliasQry )->E1_BASEIRF), .T.)
					If cCart=="R" .and. nImpRetEmi > 0 .and. ( cAliasQry )->E1_VALOR == ( cAliasQry )->E5_VALOR + nAbat + nImpRetEmi // baixa total
						nBaseIrf := nBSEIrf - (( cAliasQry )->E5_VALOR + nAbat + nImpRetEmi )
					ElseIf cCart=="R" .and. nImpRetEmi > 0 .and. ( cAliasQry )->E1_VALOR <> ( cAliasQry )->E5_VALOR + nAbat + nImpRetEmi // baixa parcial
						aBaixa := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /"+MV_CRNEG,( cAliasQry )->E5_PREFIXO, ( cAliasQry )->E5_NUMERO, ( cAliasQry )->E5_PARCELA, ( cAliasQry )->E5_TIPO,,,( cAliasQry )->E5_CLIFOR,( cAliasQry )->E5_LOJA,,,,)//procuro as baixas deste titulo
						//Exibe na tela de Cancelamento as baixas na ordem que foram feitas
						aSort(aBaixa,,,{|x,y| SubStr(x,Len(x)-1,Len(x)) < SubStr(y,Len(y)-1,Len(y))})
						If Len(aBaixa) > 1 //somente soma os impostos na emissao caso for a ultima baixa
							If (( cAliasQry )->E5_PREFIXO+" "+( cAliasQry )->E5_NUMERO+Iif(Len(( cAliasQry )->E5_NUMERO)==TamSX3("E5_NUMERO")[1],Space(TamSX3("E5_NUMERO")[1]),"")+" "+( cAliasQry )->E5_PARCELA+" "+( cAliasQry )->E5_TIPO+" "+( cAliasQry )->E5_CLIFOR+" "+( cAliasQry )->E5_LOJA+" "+DTOC(STOD(( cAliasQry )->E5_DATA))+" "+Transf(( cAliasQry )->E5_VALOR,"@E 9999,999,999.99")+"   "+( cAliasQry )->E5_SEQ)  == aBaixa[Len(aBaixa)]
								nBaseIrf := nBSEIrf - (( cAliasQry )->E5_VALOR + nAbat + nImpRetEmi )
							Else
								If nBSEIrf <> (cAliasQry)->E5_VALOR .And. Empty( (cAliasQry)->E5_PRETIRF ) .And. Empty( (cAliasQry)->E5_VRETIRF ) .And. (cAliasQry)->E5_VALOR < nBSEIrf
									nBaseIrf := ( cAliasQry )->E5_VALOR
								Else
									nBaseIrf := nBSEIrf - ( cAliasQry )->E5_VALOR
								EndIf
							EndIf
						EndIf
					Else
						nBaseIrf := nBSEIrf - (( cAliasQry )->E5_VALOR + nAbat + nImpRetEmi )
					EndIf
				ElseIf nSaldo == 0 .And. cCart == "R" .and. ( cAliasQry )->E1_VALOR <> ( cAliasQry )->E1_BASEIRF
					nBaseIrf := nBSEIrf
				Else
					nValor := ( cAliasQry )->E5_VALOR
					If nSaldo > 0
						nValor += IIF(lLiquido, nVret, 0)
					EndIf
					nBaseIrf := nValor
					//Caso seja uma baixa parcial e o imposto esteja pendente de retenção
					If (cAliasQry)->E5_PRETIRF == "1"
						AADD(aTitCIrf,{(cAliasQry)->E5_TABORI, (cAliasQry)->E5_IDORIG})
					Endif
				EndIf
			Else
				nBaseIrf := nBSEIrf
			EndIf

			// Percentual IRRF
			nPercIRF := GetPerIRF((cAliasQry)->E1_NATUREZ,(cAliasQry)->E1_ORIGEM,cCart,(cAliasQry)->RECNOSE1)

			//Total Calculado
			If !((FwIsInCallStack("A460Grava") .and. FwIsInCallStack("FA040Natur") ) .and. ;
						SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA == (cAliasQry)->E1_PREFIXO+(cAliasQry)->E1_NUM+(cAliasQry)->E1_PARCELA+(cAliasQry)->E1_TIPO+(cAliasQry)->E1_CLIENTE+(cAliasQry)->E1_LOJA )
				If (cAliasQry)->ED_CALCIRF == "S" .and.  cEdCodRet == (cAliasQry)->ED_CODRET
					nTCalcIrf += Round((nBaseIrf * nPercIRF / 100),2)
					nTBCalIrf += nBaseIrf
				EndIf
			EndIf

			//Total Retido
			IF lIRPJBaixa
				If (cAliasQry)->E5_PRETIRF $ "3|4|5" .Or. ((cAliasQry)->E5_PRETIRF $ " |7" .And.  (cAliasQry)->E5_VRETIRF > 0)
					If cEdCodRet == (cAliasQry)->ED_CODRET
						nTotRtIrf += (cAliasQry)->E5_VRETIRF
						nTBRetIrf += (cAliasQry)->E5_BASEIRF
					EndIf
				EndIf
			EndIf

			(cAliasQry)->(DbSkip())
		EndDo

		// Tratamento de retenção de IRRF via borderô de impostos.
		If lIRPJBaixa

			cQuery := "SELECT E1_VALOR, E1_PIS,E1_COFINS,E1_CSLL,E1_IRRF,E1_SABTPIS,E1_SABTCOF,E1_SABTCSL,E1_SALDO,E1_TIPOLIQ,"
			cQuery += " E1_PREFIXO,E1_NUM, E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA,E1_NATUREZ,E1_MOEDA,E1_TXMOEDA,E1_VENCREA,"
			cQuery += " SED.ED_CALCIRF, SED.ED_PERCIRF, SED.ED_CODRET, SE1.E1_NUMLIQ,SE1.E1_FATURA,"
			cQuery += " E1_BASEIRF, E1_ORIGEM, E1_FILORIG, "
			cQuery += "	SE1.R_E_C_N_O_ RECNO FROM "
			cQuery += RetSqlName( "SE1" ) + " SE1 "
			cQuery += " INNER JOIN " + RetSqlName( "SED" ) + " SED ON "

			If !Empty(FWFilial("SE1")) .And. !Empty(FWFilial("SED"))
				cQuery += " SE1.E1_FILIAL = SED.ED_FILIAL AND "
			Else
				cQuery += " SED.ED_FILIAL = '" + xFilial( "SED" , cFilOrig ) + "' AND "
			EndIf

			cQuery += "  SE1.E1_NATUREZ = SED.ED_CODIGO AND "
			cQuery += "  SED.ED_CALCIRF = 'S' AND SED.D_E_L_E_T_ = ' ' "

			If lFina891
				cQuery += "  LEFT JOIN "+ RetSqlName( "SEA" ) + " SEA ON "
			Else
				cQuery += "  INNER JOIN "+ RetSqlName( "SEA" ) + " SEA ON "
			EndIf

			If !Empty(FWFilial("SE1")) .And. !Empty(FWFilial("SEA"))
				cQuery += " SE1.E1_FILIAL = SEA.EA_FILIAL AND "
			EndIf

			cQuery += "   SE1.E1_NUMBOR = SEA.EA_NUMBOR AND SEA.EA_CART = 'R' AND SEA.D_E_L_E_T_ = ' ' "
			
			cQuery += " AND SE1.E1_PREFIXO = SEA.EA_PREFIXO AND SE1.E1_NUM = SEA.EA_NUM AND SE1.E1_PARCELA = SEA.EA_PARCELA"

			cQuery += "		WHERE E1_FILIAL IN " + FormatIn(cFiliais,",") + " AND "

			//Apenas o Fornecedor Atual
			cQuery += "E1_CLIENTE='"+ cCodigo+ "' AND "
			If lLojaAtu  //Considero apenas a loja atual
				cQuery += "E1_LOJA ='"+cLoja+ "' AND "
			EndIf

			If (!lFina061 .And. !Empty(SE1->E1_NUMBOR)) .Or. !lFina891  //Não considera o título posicionado que está sendo baixado pelo FINA070/110.
				cQuery += " NOT (E1_FILIAL = '"+SE1->E1_FILIAL+"' AND "
				cQuery += " E1_PREFIXO = '"+SE1->E1_PREFIXO+"' AND "
				cQuery += " E1_NUM = '"+SE1->E1_NUM+"' AND "
				cQuery += " E1_PARCELA = '"+SE1->E1_PARCELA+"' AND "
				cQuery += " E1_TIPO = '"+SE1->E1_TIPO+"' AND "
				cQuery += " E1_CLIENTE = '"+SE1->E1_CLIENTE+"' AND "
				cQuery += " E1_LOJA = '"+SE1->E1_LOJA+"') AND "
			EndIf

			If SEA->( FieldPos("EA_ORIGEM") ) > 0 .and. !lFina891
				cQuery += " EA_ORIGEM = '" + PADR("FINA061",TamSX3("EA_ORIGEM")[1])  + "' AND "
			Endif
			If !lFina891
				cQuery += " E1_DATABOR = '" + DToS( dRef ) + "' AND "
			Else
				cFilSA1 := AllTrim(xFilial("SA1",SE1->E1_FILIAL))
				cQuery += "E1_PREFIXO || E1_NUM || E1_PARCELA || E1_TIPO || E1_CLIENTE || E1_LOJA "
				cQuery += "IN ( "
				cQuery +=		"SELECT F71_PREFIX||F71_NUM||F71_PARCEL||F71_TIPO||F71_CODCLI||F71_LOJCLI "
				cQuery +=		"FROM " +RetSqlName("F71")+ " "
				cQuery +=		"WHERE F71_VLRPIX > 0 "
				cQuery +=			"AND F71_CODCLI = '" + SE1->E1_CLIENTE + "' "
				cQuery +=			"AND F71_LOJCLI = '" + SE1->E1_LOJA    + "' "
				cQuery +=			"AND F71_DTPSP  = '" + DToS( dRef )    + "' "
				cQuery +=			"AND F71_STATUS <> '7' "
				cQuery +=			"AND D_E_L_E_T_ = ' ' AND "
				If Len(cFilSA1) > 0
					If AllTrim(Upper(TcGetDB())) == "ORACLE"
						cQuery +=		"SUBSTR( "
					Else	// POSTGRES|MSSQL 
						cQuery +=		"SUBSTRING( "
					EndIf
					cQuery +=			"F71_FILIAL,1," +cValToChar(Len(cFilSA1))
					cQuery +=			") = '" + cFilSA1 + "' "
					cQuery += ") AND "
				EndIf
			EndIf
			cQuery += " E1_TIPO NOT IN " + FormatIn(MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVENVBCOR,"/")
			If !lFina891
				cQuery += "	AND (E1_SALDO>0 OR E1_NUMBOR <> '"+Space(TamSX3("E1_NUMBOR")[1])+"')  "
				cQuery += " AND E1_PORTADO <> ' '"
			Else
				cQuery += "	AND E1_SALDO>0 "
			EndIf

			If lFina061 .or. lFina891
				cQuery += "  AND SE1.R_E_C_N_O_ < "+alltrim(STR(SE1->(RECNO())))+" 	"
			Endif

			cQuery += " AND "
			cQuery += " SE1.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery( cQuery )

			If Select(cAliasQry) > 0
				( cAliasQry )->( dbCloseArea() )
			Endif

			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

			While !( cAliasQry )->( Eof())

				If cEdCodRet == (cAliasQry)->ED_CODRET
					nSaldo 		:= (cAliasQry)->E1_SALDO
					
					nBaseIrf := IIF(!Empty((cAliasQry)->E1_BASEIRF),(cAliasQry)->E1_BASEIRF, (cAliasQry)->E1_VALOR)

					nPercIRF := GetPerIRF((cAliasQry)->E1_NATUREZ,(cAliasQry)->E1_ORIGEM,cCart,(cAliasQry)->RECNO)

					If (cAliasQry)->ED_CALCIRF == "S"
						nTCalcIrf += Round((nBaseIrf * nPercIRF / 100),2)
						nTBCalIrf += nBaseIrf

						cChaveTit := xFilial("SE1", (cAliasQry)->E1_FILORIG) + "|" + (cAliasQry)->E1_PREFIXO + "|" + (cAliasQry)->E1_NUM + "|" + (cAliasQry)->E1_PARCELA + "|" + (cAliasQry)->E1_TIPO + "|" + (cAliasQry)->E1_CLIENTE+ "|" + (cAliasQry)->E1_LOJA
						cChaveFK7 := FINGRVFK7("SE1", cChaveTit)

						If FBrdPdRet("IRF", /*aTitCalc*/, (cAliasQry)->E1_FILORIG, cChaveFK7, dRef, /*lTitCalc*/ )
							AADD(aTitCIrf,{"FK7", cChaveFK7 })
						Endif

					Endif
				EndIf

				(cAliasQry)->(DbSkip())
			EndDo
		EndIf

		If Select(cAliasQry) > 0
			( cAliasQry )->( dbCloseArea() )
		EndIf

		nIrfBaseR += Round(nTBCalIrf - nTBRetIrf,2)
		nIrrf := Round(nTCalcIrf - nTotRtIrf,2)

		aDados[1] := nIrrf
		aDados[3] := nTotRtIrf

		SE2->(RestArea(aArSE2))
		SE1->(RestArea(aArSE1))
		SE5->(RestArea(aArSE5))
		RestArea(aAreaAt)
	Endif

Return aDados



//-------------------------------------------------------------------
/*/{Protheus.doc}SumDayFKIR
Verificar total baixado diário do IRPJ(Imposto de renda pessao jurídica).

@param cCart - Carteira P = Pagar, R = Receber
@param cFil - Filial
@param cCodigo - Código do Cliente/Forn.
@param cLoja - Loja do Cliente/Forn.
@param cTipo - Tipo do Cliente/Forn.
@param dRef - Data de Referência

@return aDados - Retorna o total pendente de IRRF baixado no dia.
aDados[1] ->Irrf
aDados[2] ->lVermin - Verifica valor minimo de retenção.

@author Mauricio Pequim Jr
@since  23/02/2016
/*/
//-------------------------------------------------------------------
Function SumDayFKIR(cCart,cFil,cCodigo,cLoja,cTipo,dRef,cFilOrig,cEdCodRet)

	Local aAreaAt As Array
	Local aDados As Array
	Local cAliasQry As Character
	Local cChave As Character
	Local aCodRet As Array
	Local cQuery As Character
	Local cFilSA1 As Character
	Local lLojaAtu As Logical
	Local lIRPJBaixa As Logical
	Local lLiquido As Logical
	Local nIrrf As Numeric
	Local nBaseIrf As Numeric
	Local nSaldo As Numeric
	Local nTCalcIrf As Numeric
	Local nTotRtIrf As Numeric
	Local nTBCalIrf As Numeric
	Local nTBRetIrf As Numeric
	Local lFina061 As Logical
	Local lFina891 As Logical
	Local lFina330 As Logical
	Local nPercIRF As Numeric
	Local lRaRtImp As Logical
	Local lBQ10925 As Logical
	Local nTamPrfTit As Numeric
	Local nI As Numeric
	Local cChaveTit As Character
	Local cChaveFK7 As Character
	Local lContinua As Logical
	
	Default cFilOrig	:= cFilAnt
	Default cEdCodRet	:= ""

	aAreaAt		:= getArea()
	aCliFor 	:= {}
	aDados		:= Array(4)
	cAliasQry 	:= GetNextAlias()
	cChave		:= ""
	aCodRet		:= {}
	cQuery 		:= ""
	cFilSA1		:= ""
	lLojaAtu	:= ( SuperGetMv("MV_LJ10925",.F., "1") == "1" )
	lIRPJBaixa	:= FIrPjBxCr(.T.)
	lLiquido	:= ( SuperGetMv("MV_BQ10925",.F., "1") == "2" ) // Default (Bruto)
	nIrrf		:= 0
	nBaseIrf	:= 0
	nSaldo		:= 0
	nTCalcIrf	:= 0	//Valores calculados
	nTotRtIrf	:= 0	//Valores retidos
	nTBCalIrf	:= 0	//Base de cálculo
	nTBRetIrf	:= 0	//Base de retenção
	lFina061	:= FwIsInCallStack("Fa061Borde")
	lFina891	:= FwIsInCallStack("PIXGerImp")
	lFina330	:= FwIsInCallStack("fA330Comp")
	nPercIRF	:= 0
	lRaRtImp	:= FRaRtImp()
	lBQ10925	:= SuperGetMV("MV_BQ10925",,"2") == "1" .And. !lRaRtImp
	nTamPrfTit	:= LenCmpTitP( cCart , lIRPJBaixa )
	nI			:= 0
	cChaveTit 	:= ""
	cChaveFK7	:= ""
	aTitCIrf	:= {}
	lContinua	:= .T.

	cChave := Iif(!lIRPJBaixa,cTipo,"") + cCodigo + Iif(lLojaAtu,cLoja,"")

	//Verifico se já foi gerado o título de imposto para o cliente/fornecedor da filial corrente.
	nIrrf := getValorTx(cFil,cChave,"IRF"	,"IRF",cEdCodRet,dRef,cCart,nTamPrfTit)
	nIrrf += getValorTx(cFil,cChave,MVIRABT ,"IRF",cEdCodRet,dRef,cCart,nTamPrfTit)
	nIrrf += getValorTx(cFil,cChave,MVTAXA ,"IRF",cEdCodRet,dRef,cCart,nTamPrfTit)

	aDados[2] := .T.

	If !lIRPJBaixa
		nIrrf := 0
	Endif

	//Se sim, não aplico o cumulatividade, vejo apenas o saldo restante do título.
	If nIrrf > 0
		aDados[1]	:= 0
		aDados[2]	:= .F.
		aDados[3]	:= nIrrf 
		lContinua	:= .F.
	EndIf

	//--------------------------------------------------------------
	//Tratamento para IRRF na Baixa - Contas a Receber
	//--------------------------------------------------------------	
	If lContinua .and. lIRPJBaixa
		If __oQryBxCR == Nil .and. cCart == 'R'

			cQuery := "SELECT FK3.FK3_VALOR, FK3.FK3_BASIMP, FK3.FK3_IMPOS, FK3.FK3_DATA, FK3.FK3_MOEDA, "
			cQuery += 		" FK3.FK3_CODFKM, FK3.FK3_IDRET, FK3.FK3_FILORI, FK3.R_E_C_N_O_ FK3RECNO, "
			cQuery += 		" FK3.FK3_TABORI, FK3.FK3_IDORIG "			
			cQuery += "FROM " + RetSqlName( "FKA" ) + " FKA "
			cQuery += "INNER JOIN " + RetSqlName( "FK1" ) + " FK1 ON (FKA.FKA_IDORIG = FK1.FK1_IDFK1 "
			cQuery += 			"AND FKA.FKA_TABORI = 'FK1'	"
			cQuery += 			"AND FKA.FKA_FILIAL = FK1.FK1_FILIAL) "
			cQuery += "INNER JOIN " + RetSqlName( "FK3" ) + " FK3 ON (FK1.FK1_IDFK1 = FK3.FK3_IDORIG "
			cQuery += 			"AND FK1.FK1_FILIAL = FK3.FK3_FILIAL) "
			cQuery += "WHERE FK3.FK3_FILORI = ? "
			cQuery += "AND FK3.FK3_DATA = ? "
			cQuery += "AND FK3.FK3_IMPOS = 'IRF' "
			cQuery += "AND FK3.FK3_TABORI = 'FK1' "
			cQuery += "AND FK3.FK3_CLIFOR = ? "
			If lLojaAtu
				cQuery += "AND FK3.FK3_LOJA = ?	"	
			Endif
			cQuery += "AND FKA.D_E_L_E_T_ = ' '	"
			cQuery += "AND FK3.D_E_L_E_T_ = ' ' "
			cQuery += "AND FK3.FK3_STATUS = '1' "
			cQuery += "AND FKA.FKA_IDPROC NOT IN "
			cQuery +=	"( SELECT DISTINCT FKA.FKA_IDPROC "
			cQuery +=		"FROM " + RetSqlName( "FKA" ) + " FKA "
			cQuery +=		"INNER JOIN " + RetSqlName( "FK1" ) + " FK1 ON (FKA.FKA_IDORIG = FK1.FK1_IDFK1 "
			cQuery +=				"AND FKA.FKA_TABORI = 'FK1' "
			cQuery +=				"AND FKA.FKA_FILIAL = FK1.FK1_FILIAL) "
			cQuery +=		"INNER JOIN " + RetSqlName( "FK3" ) + " FK3 ON (FK1.FK1_IDFK1 = FK3.FK3_IDORIG "
			cQuery +=				"AND FK1.FK1_FILIAL = FK3.FK3_FILIAL) "
			cQuery +=		"WHERE FK3.FK3_FILORI = ? "
			cQuery +=				"AND FK3.FK3_DATA = ? "
			cQuery +=				"AND FK3.FK3_IMPOS = 'IRF' "
			cQuery +=				"AND FK3.FK3_TABORI = 'FK1' "
			cQuery +=				"AND FK3.FK3_CLIFOR = ? "
			If lLojaAtu
				cQuery += 			"AND FK3.FK3_LOJA = ? "
			Endif
			cQuery +=				"AND FKA.D_E_L_E_T_ = ' ' "
			cQuery +=				"AND FK3.D_E_L_E_T_ = ' ' "
			cQuery +=				"AND FK3.FK3_STATUS = '2') "

			cQuery := ChangeQuery( cQuery )
			__oQryBxCR := FWPreparedStatement():New(cQuery)
		Endif
	
		nI := 1
		__oQryBxCR:SetString(nI, cFilOrig )		//FK3_FILORIG
		nI++
		__oQryBxCR:SetString(nI,DToS( dRef ))	//FK3_DATA
		nI++
		__oQryBxCR:SetString(nI,cCodigo)		//FK3_CLIFOR
		nI ++
		If lLojaAtu
			__oQryBxCR:SetString(nI,cLoja)		//FK3_LOJA (OPCIONAL)
			nI ++
		EndIf

		__oQryBxCR:SetString(nI, cFilOrig )		//FK3_FILORIG
		nI++
		__oQryBxCR:SetString(nI,DToS( dRef ))	//FK3_DATA
		nI++
		__oQryBxCR:SetString(nI,cCodigo)		//FK3_CLIFOR
		nI ++
		If lLojaAtu
			__oQryBxCR:SetString(nI,cLoja)		//FK3_LOJA (OPCIONAL)
			nI ++
		Endif
		
		cQuery := __oQryBxCR:GetFixQuery()

		cAliasQry := mpsysopenquery(cQuery)

		While !( cAliasQry )->( Eof())

			nTBCalIrf += ( cAliasQry )->FK3_BASIMP		//Base Calculada
			nTCalcIrf += ( cAliasQry )->FK3_VALOR		//Valor Calculado

			If Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
				//Registros pendentes de retenção que terão seu imposto retido na baixa atual
				AADD(aTitCIrf,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
			Else
				nTBRetIrf += ( cAliasQry )->FK3_BASIMP
				nTotRtIrf += ( cAliasQry )->FK3_VALOR
			Endif

			(cAliasQry)->(DbSkip())
		EndDo

		If Select(cAliasQry) > 0
			( cAliasQry )->( dbCloseArea() )
		Endif

		cChaveTit := xFilial("SE1", SE1->E1_FILORIG) + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" + SE1->E1_CLIENTE+ "|" + SE1->E1_LOJA
		cChaveFK7 := FINGRVFK7("SE1", cChaveTit)

		//--------------------------------------------------------------
		// Tratamento de retenção de IRRF via borderô de impostos.
		//--------------------------------------------------------------
		If __oQryBdCR == Nil .and. cCart == 'R'

			cQuery := "SELECT FK3.FK3_FILIAL, FK3.FK3_IDFK3, FK3.FK3_DATA, FK3.FK3_VALOR, FK3.FK3_MOEDA, FK3.FK3_NATURE, FK3.FK3_RECPAG, FK3.FK3_IDRET, "
			cQuery += "FK3.FK3_IMPOS, FK3.FK3_FILORI, FK3.FK3_BASIMP, FK3.FK3_ORIGEM, FK3.FK3_VLMOE2, FK3.FK3_IDORIG, FK3.FK3_TABORI, "
			cQuery += "FK3.FK3_STATUS, FK3.FK3_CODFKM, FK3.FK3_CLIFOR, FK3.FK3_CGC, FK3.FK3_RAICGC, FK3.R_E_C_N_O_ FK3RECNO "
			cQuery += "FROM " + RetSqlName( "FK3" ) + " FK3 "
			cQuery += "WHERE FK3.FK3_FILORI = ? "
			cQuery += "AND FK3.FK3_DATA = ? "
			cQuery += "AND FK3.FK3_IMPOS = 'IRF' "
			cQuery += "AND FK3.FK3_TABORI = 'FK7' "
			cQuery += "AND FK3.FK3_IDORIG <> ? "
			cQuery += "AND FK3.FK3_CLIFOR = ? "
			cQuery += "AND FK3.FK3_CODRET = ? "
			If lLojaAtu
				cQuery += "AND FK3.FK3_LOJA = ?	"	
			Endif
			cQuery += "AND FK3.FK3_IDRET = ' ' "
			cQuery += "AND FK3.FK3_STATUS = '1' "
			cQuery += "AND FK3.FK3_RECPAG = 'R' "			
			cQuery += "AND FK3.FK3_ORIGEM IN ('FINA590','FINA061','FINA890') "
			cQuery += "AND FK3.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery( cQuery )
			__oQryBdCR := FWPreparedStatement():New(cQuery)
		EndIf
	
		nI := 1
		__oQryBdCR:SetString(nI, cFilOrig )		//FK3_FILORIG
		nI++
		__oQryBdCR:SetString(nI,DToS( dRef ))	//FK3_DATA
		nI++
		__oQryBdCR:SetString(nI,cChaveFK7)		//FK3_TABORIG
		nI ++
		__oQryBdCR:SetString(nI,cCodigo)		//FK3_CLIFOR
		nI ++
		__oQryBdCR:SetString(nI,cEdCodRet)		//FK3_CODRET
		nI ++

		If lLojaAtu
			__oQryBdCR:SetString(nI,cLoja)		//FK3_LOJA (OPCIONAL)
			nI ++
		EndIf
		
		cQuery := __oQryBdCR:GetFixQuery()
	
		cAliasQry := mpsysopenquery(cQuery)

		While !( cAliasQry )->( Eof())

			nTBCalIrf += ( cAliasQry )->FK3_BASIMP		//Base Calculada
			nTCalcIrf += ( cAliasQry )->FK3_VALOR		//Valor Calculado

			//Registros pendentes de retenção que terão seu imposto retido na baixa atual
			AADD(aTitCIrf,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})

			(cAliasQry)->(DbSkip())
		EndDo

		If Select(cAliasQry) > 0
			( cAliasQry )->( dbCloseArea() )
		Endif


		//--------------------------------------------------------------
		// Tratamento de retenção na inclusão de RA
		//--------------------------------------------------------------
		If lRaRtImp
			If __oQryRACR == Nil .and. cCart == 'R'

				cQuery := "SELECT FK3.FK3_VALOR, FK3.FK3_BASIMP, FK3.FK3_IMPOS, FK3.FK3_DATA, FK3.FK3_MOEDA, "
				cQuery += 		" FK3.FK3_CODFKM, FK3.FK3_IDRET, FK3.FK3_FILORI, FK3.R_E_C_N_O_ FK3RECNO, "
				cQuery += 		" FK3.FK3_TABORI, FK3.FK3_IDORIG "			
				cQuery += "FROM " + RetSqlName( "FKA" ) + " FKA "
				cQuery += "INNER JOIN " + RetSqlName( "FK5" ) + " FK5 ON (FKA.FKA_IDORIG = FK5.FK5_IDMOV "
				cQuery += 			"AND FKA.FKA_TABORI = 'FK5'	"
				cQuery += 			"AND FKA.FKA_FILIAL = FK5.FK5_FILIAL) "
				cQuery += "INNER JOIN " + RetSqlName( "FK3" ) + " FK3 ON (FK5.FK5_IDMOV = FK3.FK3_IDORIG "
				cQuery += 			"AND FK5.FK5_FILIAL = FK3.FK3_FILIAL) "
				cQuery += "WHERE FK3.FK3_FILORI = ? "
				cQuery += "AND FK3.FK3_DATA = ? "
				cQuery += "AND FK3.FK3_IMPOS = 'IRF' "
				cQuery += "AND FK3.FK3_TABORI = 'FK5' "
				cQuery += "AND FK3.FK3_CLIFOR = ? "
				If lLojaAtu
					cQuery += "AND FK3.FK3_LOJA = ?	"	
				EndIf
				cQuery += "AND FKA.D_E_L_E_T_ = ' '	"
				cQuery += "AND FK3.D_E_L_E_T_ = ' ' "
				cQuery += "AND FK3.FK3_STATUS = '1' "
				cQuery += "AND FKA.FKA_IDPROC NOT IN "
				cQuery +=	"( SELECT DISTINCT FKA.FKA_IDPROC "
				cQuery +=		"FROM " + RetSqlName( "FKA" ) + " FKA "
				cQuery +=		"INNER JOIN " + RetSqlName( "FK5" ) + " FK1 ON (FKA.FKA_IDORIG = FK5.FK5_IDMOV "
				cQuery +=				"AND FKA.FKA_TABORI = 'FK5' "
				cQuery +=				"AND FKA.FKA_FILIAL = FK5.FK5_FILIAL) "
				cQuery +=		"INNER JOIN " + RetSqlName( "FK3" ) + " FK3 ON (FK5.FK5_IDMOV = FK3.FK3_IDORIG "
				cQuery +=				"AND FK5.FK5_FILIAL = FK3.FK3_FILIAL) "
				cQuery +=		"WHERE FK3.FK3_FILORI = ? "
				cQuery +=				"AND FK3.FK3_DATA = ? "
				cQuery +=				"AND FK3.FK3_IMPOS = 'IRF' "
				cQuery +=				"AND FK3.FK3_TABORI = 'FK1' "
				cQuery +=				"AND FK3.FK3_CLIFOR = ? "
				If lLojaAtu
					cQuery += 			"AND FK3.FK3_LOJA = ? "
				Endif
				cQuery +=				"AND FKA.D_E_L_E_T_ = ' ' "
				cQuery +=				"AND FK3.D_E_L_E_T_ = ' ' "
				cQuery +=				"AND FK3.FK3_STATUS = '2') "

				cQuery := ChangeQuery( cQuery )
				__oQryRACR := FWPreparedStatement():New(cQuery)
			EndIf
		
			nI := 1
			__oQryRACR:SetString(nI, cFilOrig )		//FK3_FILORIG
			nI++
			__oQryRACR:SetString(nI,DToS( dRef ))	//FK3_DATA
			nI++
			__oQryRACR:SetString(nI,cCodigo)		//FK3_CLIFOR
			nI ++
			If lLojaAtu
				__oQryRACR:SetString(nI,cLoja)		//FK3_LOJA (OPCIONAL)
				nI ++
			EndIF

			__oQryRACR:SetString(nI, cFilOrig )		//FK3_FILORIG
			nI++
			__oQryRACR:SetString(nI,DToS( dRef ))	//FK3_DATA
			nI++
			__oQryRACR:SetString(nI,cCodigo)		//FK3_CLIFOR
			nI ++
			If lLojaAtu
				__oQryRACR:SetString(nI,cLoja)		//FK3_LOJA (OPCIONAL)
				nI ++
			EndIF
			
			cQuery := __oQryRACR:GetFixQuery()

			cAliasQry := mpsysopenquery(cQuery)

			While !( cAliasQry )->( Eof())

				nTBCalIrf += ( cAliasQry )->FK3_BASIMP		//Base Calculada
				nTCalcIrf += ( cAliasQry )->FK3_VALOR		//Valor Calculado

				If Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
					//Registros pendentes de retenção que terão seu imposto retido na baixa atual
					AADD(aTitCIrf,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
				Else
					nTBRetIrf += ( cAliasQry )->FK3_BASIMP
					nTotRtIrf += ( cAliasQry )->FK3_VALOR
				Endif

				(cAliasQry)->(DbSkip())
			EndDo

			If Select(cAliasQry) > 0
				( cAliasQry )->( dbCloseArea() )
			Endif
		Endif

		nIrfBaseR += Round(nTBCalIrf - nTBRetIrf,2)
		nIrrf := Round(nTCalcIrf - nTotRtIrf,2)

		aDados[1] := nIrrf
		aDados[3] := nTotRtIrf

		RestArea(aAreaAt)
	Endif

Return aDados


//-------------------------------------------------------------------
/*/{Protheus.doc}GetPerIRF
Verifica o percentual de cálculo do IRRF

@param cNatur - Codigo da Natureza
@param cOriTit - Origem do título
@param cCart - Carteira P = Pagar, R = Receber
@param nRecno - Recno do registro posicionado
@param lReadSED - Valida percentual da NATUREZA(SED)

@return nRet - Retorna o Percentual do Imposto

@author Leonardo Castro
@since  23/02/2016
/*/
//-------------------------------------------------------------------
Function GetPerIRF(cNatur,cOriTit,cCart,nRecno,lReadSED)

	Local nCalcIrf	 := 0
	Local nRet		 := 0
	Local nBaseIrf	 := 0
	Local aArea   	 := GetArea()
	Local aAreaSA1   := SA1->(GetArea())
	Local aAreaSA2   := SA2->(GetArea())
	Local aAreaSE2   := SE2->(GetArea())
	Local aAreaSE1   := SE1->(GetArea())
	Local aAreaSED   := SED->(GetArea())
	Local lIRPJBaixa := IIF(cCart == "P", SA2->A2_CALCIRF == "2", FIrPjBxCr(.T.) )
	Local lFatCom	 := AllTrim( cOriTit ) $ "MATA461|MATA460|MATA103|MATA100|FINA631" .Or. FwIsInCallStack("MAPVLNFS") .Or. FwIsInCallStack("MATA103")

	Default cOriTit	 := " "
	DeFault cCart	 := " "
	Default lReadSED := .F.

	// Tratamento especifico para a geração do Registro de Fatura (FINA290)
	// Devera pegar os indices da natureza
	If lReadSED
		lFatCom := .F.
	EndIf

	DbSelectArea("SED")
	SED->(DbSetOrder(1))
	SED->(DbSeek(xFilial("SED")+cNatur))

	If lFatCom	// Origem do Titulo do Faturamento ou Compras
		If cCart == "P"
			SE2->(DbGoto(nRecno))
			If SE2->E2_IRRF > 0 .And. lIRPJBaixa
				nCalcIrf	:= SE2->E2_IRRF
				nBaseIrf	:= SE2->E2_BASEIRF
			Endif
		Elseif cCart == "R"
			SE1->(DbGoto(nRecno))
			If SE1->E1_IRRF > 0 .And. lIRPJBaixa
				nCalcIrf	:= SE1->E1_IRRF
				nBaseIrf	:= SE1->E1_BASEIRF
			Endif
		Endif
	Endif

	If lFatCom	// Origem do Titulo do Faturamento ou Compras
		If ValType(nCalcIrf) == "N"
			nRet	:= ((nCalcIrf / nBaseIrf)*100)
		Endif
	Else
		If SED->ED_PERCIRF > 0
			nRet	:= SED->ED_PERCIRF
		Endif
	Endif

	RestArea(aArea)
	RestArea(aAreaSED)
	If cCart == "P"
		RestArea(aAreaSE2)
		RestArea(aAreaSA2)
	Else
		RestArea(aAreaSE1)
		RestArea(aAreaSA1)
	Endif

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc}LenCmpTitP
Retorna o tamanho do inicío do campo TITPAI,
sem contar com fornecedor/cliente e loja

@param cCart - Carteira da movimentação, pagar ou receber
@param lCnsdrTipo - Considera o tipo no tamanho

@return nTamanho - Tamanho do início do campo

@author Daniel Mendes
@since  12/04/2016
/*/
	//-------------------------------------------------------------------
Static Function LenCmpTitP( cCart , lCnsdrTipo )
	Local nTamanho   := 0
	Local cPrfxAlias := ""

	cPrfxAlias := Iif( cCart == "P" , "E2_" , "E1_" )
	nTamanho   := TamSX3( cPrfxAlias + "PREFIXO" )[ 1 ] + TamSX3( cPrfxAlias + "NUM" )[ 1 ] + TamSX3( cPrfxAlias + "PARCELA" )[ 1 ] + Iif( lCnsdrTipo , TamSX3( cPrfxAlias + "TIPO" )[ 1 ] , 0 )
	nTamanho   += 1//Soma um para pegar o próximo caractere

Return nTamanho

//-------------------------------------------------------------------
/*/{Protheus.doc}FGetINSS
Retorna um Array com os Titulos do Inss do Periodo
informado nos Parametros

@param cFilTit - Filial dos Titulos a Processar
@param cMesTit - Mes dos Titulos a Processar
@param cAnoTit - Ano dos Titulos a Processar

@return aRetorno - Array com os Titulos do INSS do Periodo

@author Guilherme Santos
@since  17/12/2017
/*/
//-------------------------------------------------------------------
Function FGetINSS(cFilTit, cMesTit, cAnoTit)
	Local aArea			:= GetArea()
	Local aRetorno 		:= {}
	Local cTabQry		:= GetNextAlias()
	Local cQuery		:= ""
	Local cQryFil		:= ""
	Local cOrder		:= ""
	Local dDataIni		:= CtoD("")
	Local dDataFin		:= CtoD("")

	Default cFilTit	:= cFilAnt
	Default cMesTit	:= AllTrim(Str(Month(dDatabase)))
	Default cAnoTit	:= AllTrim(Str(Year(dDatabase)))

	cQryFil += " SE1.E1_FILIAL = '"+ FWxFilial("SE1", cFilTit) + "' AND "
	cQryFil += " SA1.A1_FILIAL = '"+ FWxFilial("SA1", cFilTit) + "' AND "
	cQryFil := "%" + cQryFil + "%"

	cQuery += " ORDER BY E1_FILORIG,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO"
	cOrder	:= "%" + cOrder + "%"

	dDataIni := CtoD("01" + "/" + cMesTit + "/" + cAnoTit)
	dDataFin := LastDay(dDataIni, 0)

	If Select(cTabQry) > 0
		(cTabQry)->(DbCloseArea())
	EndIf

	BeginSql Alias cTabQry
		Column E1_EMISSAO as Date

		SELECT E1_FILORIG,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO,E1_VALOR,E1_INSS,E1_SALDO,E1_CCUSTO,A1_PESSOA,A1_TIPO
		FROM %table:SE1% SE1, %table:SA1% SA1
		WHERE
		%exp:cQryFil%
		SE1.E1_CLIENTE = SA1.A1_COD AND
		SE1.E1_LOJA	 = SA1.A1_LOJA AND
		SE1.E1_INSS > 0 AND
		SE1.E1_EMISSAO between %exp:dDataIni% AND %exp:dDataFin% AND
		SE1.E1_EMISSAO <= %exp:dDataBase% AND
		SE1.%NotDel% AND
		SA1.%NotDel%
		%exp:cOrder%
	EndSQL

	While !(cTabQry)->(Eof())
		Aadd(aRetorno, {	(cTabQry)->E1_FILORIG,;		//01 - Filial
							(cTabQry)->E1_PREFIXO,;		//02 - Prefixo
							(cTabQry)->E1_NUM,;			//03 - Numero
							(cTabQry)->E1_PARCELA,;		//04 - Parcela
							(cTabQry)->E1_TIPO,;		//05 - Tipo
							(cTabQry)->E1_EMISSAO,;		//06 - Emissao
							(cTabQry)->E1_VALOR,;		//07 - Valor
							(cTabQry)->E1_INSS,;		//08 - Valor INSS
							(cTabQry)->E1_SALDO,;		//09 - Saldo
							(cTabQry)->E1_CCUSTO,;		//10 - Centro Custo
							(cTabQry)->A1_PESSOA,;		//11 - Pessoa
							(cTabQry)->A1_TIPO})		//12 - Tipo

		(cTabQry)->(DbSkip())
	End

	If Select(cTabQry) > 0
		(cTabQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return aRetorno


/*/{Protheus.doc} IsBxTotal
	Define se a baixa a ser realizada no momento irá baixar totalmente o título ou se sobrará saldo (parcial)
	@type  Static Function
	@author rafael.rondon
	@since 22/05/2019
	@version 12.1.23
	@param nValAnalisar				, Numeric		, Valor passado para avaliação (nValRec em alguns casos)
	@param nParc					, Numeric		, Valor de baixas parciais realizadas anteriormente
	@return lIsBxTotal				, Logic			, Esta baixa é Total? Vai baixar completamente o título?
	@example
	(examples)
	@see (links_or_references)
/*/
Function FxIsBxTotal( nValAnalisar , nParc, nTotImpMR )

	Local lIsBxTotal		:= .F.
	Local lPccBxCr 			:= FPccBxCr(.T.)
	Local lIrPjBxCr			:= FIrPjBxCr(.T.)
	Local lIssBx			:= GetNewPar("MV_MRETISS","1") == "2"  //Retencao do ISS pela emissao (1) ou baixa (2)
	Local lISSDescont		:= SuperGetMV("MV_TPABISS",,"1") == "1"  // Se parametro igual a 1 indica se sera efetuado um desconto na duplicata quando o cliente recolhe ISS se igual a 2 sera gerado um titulo de abatimento. 
	Local l070110			:= FwIsInCallStack("FINA070") .OR. FwIsInCallStack("FINA110") 
	Local nAux				:= 0		// Valor auxiliar para chegar no Saldo real do título (simula nValRec)
	Local nSubAbati			:= 0		// Valores de abatimentos

	Default nValAnalisar	:= 0
	Default nParc			:= 0
	Default nTotImpMR		:= 0

	If SE1->E1_VALOR <> SE1->E1_SALDO		// Houve baixa parcial anterior
		If nParc == 0	// Não foi passado os valores de baixas anteriores
			nParc := SE1->E1_VALOR - SE1->E1_SALDO
		EndIf
	EndIf

	nAux := SE1->E1_VALOR - nParc

	// Abatimentos
	If Type("nTotAbat") == "N"
		nSubAbati := nTotAbat
	Else
		nSubAbati := SumAbatRec( SE1->E1_PREFIXO , SE1->E1_NUM , SE1->E1_PARCELA , SE1->E1_MOEDA , "",,,,,,,, SE1->E1_FILORIG )
	EndIf
	nAux -= nSubAbati

	If l070110 // Com as variaveis na tela
		nAux -= ( nDescont + nDecresc )
		nAux += ( nJuros + nMulta + nAcresc )
	EndIf

	// PCC
	If lPccBxCr
		nAux -= ( SE1->E1_PIS + SE1->E1_COFINS + SE1->E1_CSLL )
	EndIf

	// IR
	If lIrPjBxCr
		nAux -= ( SE1->E1_IRRF )
	EndIf

	// ISS
	If lIssBx
		If !(AllTrim(SE1->E1_ORIGEM) == "MATA460" .AND. lISSDescont)  // Gera título onde E1_VALOR tem ISS descontado, nesse caso não subtrair o ISS, pois o E1_VALOR já está subtraído o ISS
			nAux -= ( SE1->E1_ISS )
		EndIf
	EndIf

	nAux -= nTotImpMR

	/*
		Se o valor passado for menor do que o valor auxiliar(Valor auxiliar)
	*/
	If nValAnalisar < nAux
		lIsBxTotal := .F.
	Else
		lIsBxTotal := .T.
	EndIf

Return lIsBxTotal

//------------------------------
/*/{Protheus.doc}FinRetBor
Valida se houve retenção no borderô
em data anterior a baixa do título

@param cFilBord, characters, Filial do borderô
@param cPrefixo, characters, Prefixo do título 
@param cNumero, characters, Número do título
@param cParcela, characters, Parcela do título
@param cTipo, characters, Tipo do título
@param cForn, characters, Fornecedor do título
@param cLoja, characters, Loja do fornecedor
@param cBordero, characters, Número do borderô
@param dDtRef, date, Data da baixa
@return lRet, Valor lógico indicando se houve retenção no borderô

@author Sivaldo Oliveira
@since  12/06/2018
@version 12
@type function
/*/
//------------------------------
Static Function FinRetBor(cFilBord, cPrefixo, cNumero, cParcela, cTipo, cForn, cLoja, cBordero, dDtRef, cFilOrig)
	
	Local cTblTmp := ""
	Local lRet    := .T.
	Local cQuery  := ""
	Local cChaveFK7 := ""
	
	Default cFilBord := cFilAnt
	Default cPrefixo := " "
	Default cNumero  := " "
	Default cParcela := " "
	Default cTipo    := ""
	Default cForn    := " "
	Default cLoja    := ""
	Default cBordero := ""
	Default dDtRef   := dDatabase
	Default cFilOrig := ""
	
	If Empty(cNumero) .Or. Empty(cTipo) .Or. Empty(cForn) .Or. Empty(cLoja) .Or. Empty(cBordero)
		lRet := .F.
	EndIf
	
	If lRet

		If __lRpoR33 == NIL
			__lRpoR33 := GetRpoRelease() >= "12.1.033"
		EndIf

		If __lRpoR33

			cChaveFK7 := xFilial("SE2", cFilOrig) + "|" + cPrefixo + "|" + cNumero + "|" + cParcela + "|" + cTipo + "|" + cForn + "|" + cLoja
			cChaveFK7 := FINBuscaFK7(cChaveFK7,"SE2")

			If __oRetBor == NIL
				cQuery := "SELECT FK2_FILIAL FKFILIAL, FK2_IDFK2 IDBAIXA FROM "+ RetSqlName("FK2") +" FK2 "
				cQuery += " INNER JOIN " + RetSqlName("FK4") + " FK4 "
				cQuery += 		"ON FK4.FK4_FILIAL = FK2_FILIAL "
				cQuery += 		"AND FK4.FK4_IDORIG = FK2_IDFK2 "
				cQuery += 		"AND FK4_IMPOS IN ('PIS','COF','CSL') "
				cQuery += 		"AND FK4_STATUS = '1' "
				cQuery += 		"AND FK4.D_E_L_E_T_ = ' ' "
				cQuery += "WHERE FK2_IDDOC = ? "
				cQuery += 		"AND FK2_DOC = ? "
				cQuery += 		"AND FK2_DATA < ? "
				cQuery += 		"AND FK2_RECPAG = 'P' "				
				cQuery += 		"AND FK2_MOTBX = 'PCC' "
				cQuery += 		"AND FK2.D_E_L_E_T_ = ' ' "
				cQuery += 		"AND NOT EXISTS( "
				cQuery += 			"SELECT FK2EST.FK2_IDDOC FROM " + RetSqlName("FK2") +" FK2EST "
				cQuery += 			"WHERE FK2EST.FK2_IDDOC = ? "
				cQuery +=		 		"AND FK2EST.FK2_SEQ = FK2.FK2_SEQ "
				cQuery += 				"AND FK2EST.FK2_TPDOC = 'ES' "
				cQuery += 				"AND FK2EST.D_E_L_E_T_ = ' ') "

				cQuery 	:= ChangeQuery(cQuery)
				__oRetBor:=FWPreparedStatement():New(cQuery)
			Endif

			__oRetBor:SetString(1,cChaveFK7)
			__oRetBor:SetString(2,cBordero)
			__oRetBor:SetString(3,DTOS(dDtRef))
			__oRetBor:SetString(4,cChaveFK7)

			cQuery  := __oRetBor:GetFixQuery()
			cTblTmp := MpSysOpenQuery(cQuery)
			lRet := (cTblTmp)->(!Eof()) 
		Else

			If __oRetBor == Nil
				cQuery := "SELECT SE5.E5_VRETPIS, SE5.E5_VRETCOF, SE5.E5_VRETCSL FROM "
				cQuery += RetSqlName("SE5") + " SE5 INNER JOIN " + RetSqlName("SE2") + " SE2 "
				cQuery += "ON (SE5.E5_FILORIG = SE2.E2_FILORIG AND SE5.E5_PREFIXO = SE2.E2_PREFIXO AND "
				cQuery += "SE5.E5_NUMERO = SE2.E2_NUM AND SE5.E5_PARCELA = SE2.E2_PARCELA AND "
				cQuery += "SE5.E5_TIPO = SE2.E2_TIPO AND SE5.E5_CLIFOR = SE2.E2_FORNECE AND "
				cQuery += "SE5.E5_LOJA = SE2.E2_LOJA) "
				cQuery += "WHERE SE5.E5_FILIAL = ? AND "
				cQuery += "SE5.E5_PREFIXO = ? AND SE5.E5_NUMERO = ? AND "
				cQuery += "SE5.E5_PARCELA = ? AND SE5.E5_TIPO = ? AND "		
				cQuery += "SE5.E5_CLIFOR = ? AND SE5.E5_LOJA = ? AND "
				cQuery += "SE5.E5_DOCUMEN = ? AND SE5.E5_DATA < ? AND "
				cQuery += "(SE5.E5_VRETPIS + SE5.E5_VRETCOF + SE5.E5_VRETCSL > 0) AND "
				cQuery += "SE5.E5_MOTBX = 'PCC' AND SE5.D_E_L_E_T_ = ' ' AND SE2.D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				__oRetBor := FWPreparedStatement():New(cQuery)
			EndIf
			
			__oRetBor:SetString(1, cFilBord)
			__oRetBor:SetString(2, cPrefixo)
			__oRetBor:SetString(3, cNumero)
			__oRetBor:SetString(4, cParcela)
			__oRetBor:SetString(5, cTipo)
			__oRetBor:SetString(6, cForn)
			__oRetBor:SetString(7, cLoja)
			__oRetBor:SetString(8, cBordero)
			__oRetBor:SetString(9, DTOS(dDtRef))
			
			cQuery  := __oRetBor:GetFixQuery()
			cTblTmp := MpSysOpenQuery(cQuery)
			lRet := (cTblTmp)->(!Eof()) .And. (cTblTmp)->(E5_VRETPIS+E5_VRETCOF+E5_VRETCSL) > 0

		Endif		
		(cTblTmp)->(dbCloseArea())
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}FCalcISS
Efetua o cálculo de ISS de Título Financeiro

@param cCart - Carteira P = Pagar, R = Receber
@param dDataRef - Data de Referencia
@param nBaseCalc - Base de Cálculo - Em moeda CORRENTE
@param nPercIss - Percentual/Alíquota
@param cCliFor - Cliente/Fornecedor 
@param cLoja - Loja do Cliente/Fornecedor
@param lVerMin - Verifica o Valor Mínimo
@param cCodMIss - Código de Multiplos Vinculos de ISS
@param cFilOrig - Filial de Origem

@return aRetorno - Vetor com os valores de ISS
			[1] Valores
				[1] - Cálculado
				[2] - Acumulado
				[3] - Retenção
			[2] Bases
				[1] - Cálculo
				[2] - Acumulado
				[3]	- Retenção

@author Leonardo Castro
@since  17/07/2019
/*/
//-------------------------------------------------------------------
Function FCalcISS(cCart As Character, dDataRef As Date, nBaseCalc As Numeric, nPercIss As Numeric, cCliFor As Character, cLoja As Character, lVerMin As Logical, cCodMIss As Character, cFilOrig As Character)

	Local aRet As Array
	Local aArea As Array
	Local aAreaFIM as Array
	Local aAreaCF as Array
	Local cAliasTIT As Character
	Local cAliasCF As Character
	Local nValorCalc As Numeric
	Local nValorAcm As Numeric
	Local nValorRet As Numeric
	Local nBaseAcm As Numeric
	Local nBaseRet As Numeric
	Local nVRetMin As Numeric
	Local nBaseMin As Numeric
	Local nVRetAnt As Numeric
	Local nBRetAnt As Numeric
	Local cFMinISS As Character
	Local lRndIss As Logical
	Local lRetBISS As Logical
	Local lF050PISS As Logical
	Local nAliqISS as Numeric

	DEFAULT cCart		:= "P"
	DEFAULT dDataRef	:= dDataBase
	DEFAULT nBaseCalc	:= 0
	DEFAULT cCliFor		:= ""
	DEFAULT cLoja		:= ""
	DEFAULT lVerMin		:= .T. 
	DEFAULT cCodMIss	:= ""
	DEFAULT nPercIss	:= 0
	DEFAULT cFilOrig	:= cFilAnt

	// Inicializa VARIAVEIS
	cAliasTIT	:= IF( cCart == "P", "SE2", "SE1" )
	cAliasCF	:= IF( cCart == "P", "SA2", "SA1" )
	aRet		:= Array(0)
	aArea		:= GetArea()
	aAreaFIM	:= FIM->(GetArea())
	aAreaCF		:= (cAliasCF)->(GetArea())
	nValorCalc  := 0 // Valor Cálculado
	nValorAcm	:= 0 // Valor Acumulado
	nValorRet	:= 0 // Valor de Retenção
	nBaseAcm	:= 0 // Base Acumulada
	nBaseRet	:= 0 // Base de Retenção
	nVRetAnt	:= 0 // Valor Retido Anteriormente
	nBRetAnt	:= 0 // Base Retido Anteriormente
	nAliqISS    := 0 // Valor da Aliquota do ISS retornado do TMS

	// Posicionamento TABELAS
	(cAliasCF)->( DbSetOrder(1) )
	(cAliasCF)->( DbSeek(xFilial(cAliasCF,cFilOrig) + cCliFor + cLoja) )

	// Montagem Alíquota
	lF050PISS	:= ExistBlock("F050PISS") // Ponto de Entrada para controle da Alíquota de ISS

	If lF050PISS .and. cCart <> "R"
		nPercIss := ExecBlock("F050PISS",.F.,.F.)
	Else
		If Empty(nPercIss)
			// Obtem a aliquota de ISS da tabela FIM - Multiplos Vinculos de ISS
			If cPaisLoc == "BRA" .And. !Empty( cCodMIss )
				FIM->( DbSetOrder( 1 ) ) // FIM_FILIAL, FIM_CODISS
				If FIM->( DbSeek( xFilial( "FIM" ) + cCodMIss ) )
					nPercIss := FIM->FIM_ALQISS
				EndIf
			Else
				nPercIss := SuperGetMv("MV_ALIQISS", .F., 5)
			EndIf
		EndIf
	EndIf

	If cCart == "R" .And. IntTms() .And. nModulo == 43 .And. Empty( cCodMIss )  //TMS
		//-- Verifica se foi informada a aliquota do ISS para regiao
		nAliqISS := Posicione("DUY",1,xFilial("DUY")+SA1->A1_CDRDES,"DUY_ALQISS")
		If nAliqISS > 0
			nPercIss := nAliqISS
		EndIf
	EndIf	

	// Montegem de Base - Cumulatividade (anteriores)
	FBaseISS(cAliasTIT, dDataRef, cCliFor, cLoja, @nVRetAnt, @nBRetAnt, @nValorAcm, @nBaseAcm)

	// Aplicação do Cálculo - para o titulo corrente
	nValorCalc := ( nBaseCalc * nPercIss ) / 100
	
	lRndIss		:= SuperGetMv("MV_RNDISS",.F.,.F.) // Controle Arredondamento de ISS

	If lRndIss
		nValorCalc := Round( nValorCalc, 2)
	Else
		nValorCalc := NoRound( nValorCalc, 2)
	Endif

	nValorRet := nValorCalc + If(nValorAcm > 0, nValorAcm, 0)
	nBaseRet := nBaseCalc + If(nBaseAcm > 0, nBaseAcm, 0)

	// Tratamento de Valor Mínimo
	If lVerMin

		cFMinISS	:= SuperGetMv("MV_FMINISS",.F.,"1")	// Define se a retenção mínima do ISS deverá ser sobre o Valor ou pela Base de Cálculo. ( 1=Valor; 2=Base )
		lRetBISS	:= SuperGetMv("MV_RETBISS",.F.,.F.)	.And. (cFMinISS == "2") //Retencao Minima de ISS pela Base de Calculo - Municipio de SBC - Sao Paulo
		
		If lRetBISS .And. nBRetAnt == 0
			
			nBaseMin	:= SuperGetMv("MV_VBASISS",.F.,0) // Define a base de cálculo mínima para retenção de ISS

			If nBaseRet <= nBaseMin
				nValorRet := 0
				nBaseRet := 0
			EndIf
		ElseIf cFMinISS == "1" .And. nVRetAnt == 0
			
			nVRetMin	:= SuperGetMv("MV_VRETISS",.F.,0) // Valor mínimo para dispensa de retenção de ISS     

			If nValorRet <= nVRetMin
				nValorRet := 0
				nBaseRet := 0
			EndIf
		EndIf
	EndIf

	// Retorno dos Valores
	aAdd( aRet, { nValorCalc, nValorAcm, nValorRet } )
	aAdd( aRet, { nBaseCalc, nBaseAcm, nBaseRet } )

	// RESTAURA WORKAREA
	RestArea(aAreaCF)
	RestArea(aAreaFIM)
	RestArea(aArea)
	FwFreeArray(aAreaCF)
	FwFreeArray(aAreaFIM)
	FwFreeArray(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc}FBaseISS
Efetua a montagem de Base de ISS sobre Títulos Financeiro
com Cumulatividade de Valores não retidos anteriormente

@param cAlias - SE2 = Pagar, SE1 = Receber
@param dDataRef - Data de Referencia
@param cCliFor - Cliente/Fornecedor
@param cLoja - Loja do Cliente/Fornecedor
@param nVRetIss - Valor Retido de ISS
@param nBRetIss - Base Retida de ISS
@param nVAcmIss - Valor Acumulado de ISS
@param nBAcmIss - Base Acumulado de ISS

@return NIL

@author Leonardo Castro
@since  17/07/2019
/*/
//-------------------------------------------------------------------
Function FBaseISS(cAlias As Character, dDataRef As Date, cCliFor As Character, cLoja As Character, nVRetIss As Numeric, nBRetIss As Numeric, nVAcmIss As Numeric, nBAcmISS As Numeric)

	Local aArea		 As Array
	Local nRecno	 As Numeric
	Local dDataIni	 As Date
	Local dDataFim	 As Date
	Local cAliasSE1	 As Character
	Local cAliasSE2	 As Character
	Local cCmpData	 As Character
	Local cQuery     As Character
	Local cSepNeg    As Character
	Local cSepProv   As Character
	Local cCpoISS	 As Character
	Local lRetISSEmi As Logical
	Local lBtrISS    As Logical

	DEFAULT cAlias		:= ""
	DEFAULT dDataRef	:= dDataBase
	DEFAULT cCliFor		:= ""
	DEFAULT cLoja		:= ""
	DEFAULT nVRetIss	:= 0
	DEFAULT nBRetIss	:= 0
	DEFAULT nVAcmIss  	:= 0
	DEFAULT nBAcmISS   	:= 0

	lBtrISS  := .F.

	If GetNewPar("MV_MODRISS","1") $ "2|3"		//2-Mensal    3-Por Base

		// Inicialização de Variaveis
		aArea		:= GetArea()
		nRecno		:= (cAlias)->(Recno())
		dDataIni	:= FirstDay(dDataRef)
		dDataFim	:= LastDay(dDataRef)
		cAliasSE1	:= "SE1"
		cAliasSE2	:= "SE2"
		cCmpData	:= ""
		cQuery		:= ""
		cSepNeg		:= If("|" $ If(cAlias == "SE1", MV_CRNEG, MV_CPNEG),"|",",")
		cSepProv	:= If("|"$MVPROVIS,"|",",")
		cCpoISS		:= "E2_ISS, E2_PRISS ,E2_VRETISS"
		lRetISSEmi  := SuperGetMv("MV_RISSEMI",.F.,.F.) // Verifica se a retencao minima de ISS por base de calculo devera ser calculada pela emissao e nao vencimento - Municipio de Itabira - MG
		lBtrISS		:= SE2->(ColumnPos("E2_BTRISS")) > 0 .And. SE2->(ColumnPos("E2_VRETBIS")) > 0 .And. SE2->(ColumnPos("E2_CODSERV")) > 0 .And.;
					   FindFunction("ISSCPOM") .And. FindFunction("BtrISSMun")

		// Montagem de Base Títulos a Receber
		If cAlias == "SE1"
			SE1->(dbCommit())
			cAliasSE1 := GetNextAlias()

			cQuery := "SELECT E1_ISS, E1_VRETISS, E1_BASEISS, E1_VENCREA, E1_CLIENTE, E1_LOJA, E1_TIPO, SE1.R_E_C_N_O_ SE1RECNO FROM "
			cQuery += RetSqlName( "SE1" ) + " SE1 "
			cQuery += "WHERE "
			cQuery += "E1_FILIAL='"    + xFilial("SE1")		+ "' AND "
			cQuery += "E1_CLIENTE='"   + cCliFor			+ "' AND "
			cQuery += "E1_LOJA='"      + cLoja				+ "' AND "
			cQuery += "E1_VENCREA>= '" + DToS( dDataIni )	+ "' AND "
			cQuery += "E1_VENCREA<= '" + DToS( dDataFim )	+ "' AND "
			cQuery += "E1_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " AND "
			cQuery += "E1_TIPO NOT IN " + FormatIn(MV_CRNEG,cSepNeg)  + " AND "
			cQuery += "E1_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "
			cQuery += "D_E_L_E_T_=' '"

			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSE1, .F., .T. )
			TcSetField(cAliasSE1,"E1_ISS","N",TamSX3("E1_ISS")[1],TamSX3("E1_ISS")[2])
			TcSetField(cAliasSE1,"E1_VRETISS","N",TamSX3("E1_VRETISS")[1],TamSX3("E1_VRETISS")[2])
			TcSetField(cAliasSE1,"E1_VENCREA","D",TamSX3("E1_VENCREA")[1],TamSX3("E1_VENCREA")[2])

			(cAliasSE1)->(DbGoTop ())

			While !(cAliasSE1)->(Eof()) .And. DToS ((cAliasSE1)->E1_VENCREA)<=DToS (dDataFim)
				If (cAliasSE1)->E1_CLIENTE==cCliFor .And. (cAliasSE1)->E1_LOJA==cLoja .And.;
					!((cAliasSE1)->E1_TIPO$MVABATIM+"/"+MV_CRNEG+"/"+MVPROVIS)
					
					//Desconsidera o título que está sendo incluido
					If (cAliasSE1)->SE1RECNO == nRecno
						(cAliasSE1)->(DbSkip())
						Loop
					EndIf

					nVRetIss  += (cAliasSE1)->E1_ISS
					nVAcmIss += (cAliasSE1)->E1_VRETISS
				EndIf

				(cAliasSE1)->(dbSkip())
			EndDo

			(cAliasSE1)->(dbCloseArea())

		// Montagem de Base Títulos a Pagar
		ElseIf cAlias == "SE2"
			SE2->(dbCommit())
			cAliasSE2 := GetNextAlias()

			If lBtrISS
				cCpoISS	  += ", E2_BTRISS, E2_VRETBIS"
			EndIf

			cQuery := "SELECT "+ cCpoISS + ", E2_BASEISS, E2_VBASISS, E2_MDRTISS, E2_VENCREA, E2_FORNECE, E2_LOJA, E2_TIPO, E2_EMISSAO, E2_MOEDA, E2_TXMOEDA, SE2.R_E_C_N_O_ SE2RECNO FROM "
			cQuery += RetSqlName( "SE2" ) + " SE2 "
			cQuery += "WHERE "
			cQuery += "E2_FILIAL='"    + xFilial("SE2")		+ "' AND "
			cQuery += "E2_FORNECE='"   + cCliFor			+ "' AND "
			cQuery += "E2_LOJA='"      + cLoja				+ "' AND "
			If !lRetISSEmi
				// Calcula o total de servicos pelo vencimento do titulo
				cQuery += "E2_VENCREA>= '" + DToS( dDataIni )	+ "' AND "
				cQuery += "E2_VENCREA<= '" + DToS( dDataFim )	+ "' AND "
			Else
				// Calcula o total de servicos pela emissao
				cQuery += "E2_EMISSAO>= '" + DToS( dDataIni )	+ "' AND "
				cQuery += "E2_EMISSAO<= '" + DToS( dDataFim )	+ "' AND "
			Endif
			cQuery += "E2_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " AND "
			cQuery += "E2_TIPO NOT IN " + FormatIn(MV_CPNEG,cSepNeg)  + " AND "
			cQuery += "E2_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "
			cQuery += "D_E_L_E_T_=' '"

			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSE2, .F., .T. )
			TcSetField(cAliasSE2,"E2_ISS","N",TamSX3("E2_ISS")[1],TamSX3("E2_ISS")[2])
			TcSetField(cAliasSE2,"E2_PRISS","N",TamSX3("E2_ISS")[1],TamSX3("E2_ISS")[2])
			TcSetField(cAliasSE2,"E2_VRETISS","N",TamSX3("E2_VRETISS")[1],TamSX3("E2_VRETISS")[2])
			If lBtrISS
				TcSetField(cAliasSE2,"E2_BTRISS","N",TamSX3("E2_BTRISS")[1],TamSX3("E2_BTRISS")[2])
				TcSetField(cAliasSE2,"E2_VRETBIS","N",TamSX3("E2_VRETBIS")[1],TamSX3("E2_VRETBIS")[2])
			EndIf
			TcSetField(cAliasSE2,"E2_VBASISS","N",TamSX3("E2_VBASISS")[1],TamSX3("E2_VBASISS")[2])
			TcSetField(cAliasSE2,"E2_VENCREA","D",TamSX3("E2_VENCREA")[1],TamSX3("E2_VENCREA")[2])
			TcSetField(cAliasSE2,"E2_EMISSAO","D",TamSX3("E2_EMISSAO")[1],TamSX3("E2_EMISSAO")[2])
			(cAliasSE2)->(DbGoTop ())

			// Verica se o processamento sera efetuado pelo vencimento ou pela emissao do titulo
			If !lRetISSEmi
				cCmpData := "E2_VENCREA"
			Else
				cCmpData := "E2_EMISSAO"
			Endif

			While !(cAliasSE2)->(Eof()) .And. DToS ((cAliasSE2)->&(cCmpData))<=DToS (dDataFim)
				If (cAliasSE2)->E2_FORNECE==cCliFor .And. (cAliasSE2)->E2_LOJA==cLoja .And.;
					!((cAliasSE2)->E2_TIPO$MVABATIM+"/"+MV_CPNEG+"/"+MVPROVIS)

					//Desconsidera o título que está sendo incluido
					If (cAliasSE2)->SE2RECNO == nRecno
						(cAliasSE2)->(DbSkip())
						Loop
					EndIf

					nVRetIss += (cAliasSE2)->( E2_ISS + E2_PRISS )
					nVAcmIss += (cAliasSE2)->( E2_VRETISS - ( E2_ISS + E2_PRISS ) )

					// Converto as Bases para MOEDA CORRENTE
					nBRetIss += Round(xMoeda((cAliasSE2)->E2_VBASISS, (cAliasSE2)->E2_MOEDA, 1, (cAliasSE2)->E2_EMISSAO, MsDecimais(1)+1, (cAliasSE2)->E2_TXMOEDA), MsDecimais(1))
					nBAcmIss += Round(xMoeda((cAliasSE2)->( E2_BASEISS - E2_VBASISS ), (cAliasSE2)->E2_MOEDA, 1, (cAliasSE2)->E2_EMISSAO, MsDecimais(1)+1, (cAliasSE2)->E2_TXMOEDA), MsDecimais(1))
					
					If lBtrISS
						nVRetIss += (cAliasSE2)->E2_BTRISS
						nVAcmIss += (cAliasSE2)->E2_VRETBIS
					EndIf
				EndIf

				(cAliasSE2)->(dbSkip())
			EndDo

			(cAliasSE2)->(dbCloseArea())

		EndIf

		/*
			Tratamento para Base de retenção na BAIXA
		*/

		RestArea(aArea)
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FCalcCIDE
Efetua o cálculo de CIDE de Títulos Financeiros

	@param nBaseCalc - Base de Cálculo - Em moeda CORRENTE
	@param cNaturez - Natureza de Cálculo
	@param cFornece - Codigo do Fornecedor 
	@param cLoja - Loja do Fornecedor
	@param cFilOrig - Filial de Origem

	@return nValCIDE - Valor Calculado

	@author Leonardo Castro
	@since  26/11/2019
/*/
//-------------------------------------------------------------------
Function FCalcCIDE( nBaseCalc As Numeric, cNaturez As Character, cFornece As Character, cLoja As Character, cFilOrig As Character ) As Numeric
	
	Local nValCIDE As Numeric
	Local aAreaSED As Array
	Local aAreaSA2 As Array
	
	Default nBaseCalc := 0
	Default cNaturez := ""
	Default cFornece := ""
	Default cLoja := ""
	Default cFilOrig := cFilAnt

	aAreaSED := SED->( GetArea() )
	aAreaSA2 := SA2->( GetArea() )
	nValCIDE := 0

	// Busca Natureza de Cálculo
	SED->( DbSetOrder(1) )
	SED->( MsSeek( xFilial("SED", cFilOrig) + cNaturez ) )

	// Busca Fornecedor de Cálculo
	SA2->( DbSetOrder(1) )
	SA2->( MsSeek( xFilial("SA2", cFilOrig) + cFornece + cLoja ) )

	// Validação de Natureza(Calcula) e Fornecedor(Recolhe)
	If SED->ED_CALCCID == 'S' .And. SA2->A2_RECCIDE == "1"
		
		// Proporção de Base de Calculo
		If !Empty(SED->ED_BASECID)
			nBaseCalc := Round((nBaseCalc * (SED->ED_BASECID/100)),2)
		EndIf
		
		// Aplicação da Alíquota
		nValCIDE := Round((nBaseCalc * (SED->ED_PERCCID/100)),2)

	Endif

	RestArea(aAreaSA2)
	RestArea(aAreaSED)

Return nValCide

//-------------------------------------------------------------------
/*/{Protheus.doc} FGrvCIDE
Efetua a gravação/retenção do CIDE de Títulos Financeiros

	@param nValCide - Valor do CIDE em moeda CORRENTE
	@param dEmissao - Data de Emissao
	@param dVencRea - Data de Vencimento
	@param nRecPai  - RECNO do Título Pai
	@param cSeqBx   - Sequencia de Baixa
	@param cOrigem  - Rotina de Origem

	@return nRecTit - RECNO do título gerado

	@author Leonardo Castro
	@since  26/11/2019
/*/
//-------------------------------------------------------------------
Function FGrvCIDE(nValCIDE As Numeric, dEmissao As Date, dVencRea As Date, nRecPai As Numeric, cSeqBx As Character, cOrigem As Character) As Numeric
	
	Local aAreaSA2 As Array
	Local aAreaSED As Array
	Local aAreaSE2 As Array
	Local cForCIDE As Character
	Local cLojaImpos As Character
	Local cPrefixo As Character
	Local cNum As Character
	Local cParcela As Character
	Local cNaturez As Character
	Local cCodRet As Character
	Local nMoeda As Numeric
	Local cFilOrig As Character
	Local cTitPai As Character
	Local cFilDeb As Character
	Local cMultNat As Character
	Local cCodAprv As Character
	Local nRecTit As Numeric
	
	Default nValCIDE := 0
	Default dEmissao := dDataBase
	Default dVencRea := dDataBase
	Default nRecPai  := 0
	Default cSeqBx   := ""
	Default cOrigem  := FunName()

	nRecTit := 0

	__nTamParc := If( ValType(__nTamParc) != "N", TamSX3("E2_PARCELA")[1], __nTamParc )
	__nTamFor  := If( ValType(__nTamFor) != "N", TamSX3("A2_COD")[1], __nTamFor )
	__nTamLoja := If( ValType(__nTamLoja) != "N", TamSX3("A2_LOJA")[1], __nTamLoja )
	__nTamNat  := If( ValType(__nTamNat) != "N", TamSX3("ED_CODIGO")[1], __nTamNat )

	// Somente realiza gravação do CIDE caso informnado Título Pai
	If nValCIDE > 0 .And. nRecPai > 0

		aAreaSA2 := SA2->( GetArea() )
		aAreaSED := SED->( GetArea() )
		aAreaSE2 := SE2->( GetArea() )

		// Posiciona no Título PAI
		SE2->( DbGoTo(nRecPai) )
		
		cPrefixo := SE2->E2_PREFIXO
		cNum     := SE2->E2_NUM
		cParcela := STRZERO(1, __nTamParc)
		cCodRet	 := SE2->E2_CODRET
		nMoeda   := If(cPaisLoc == "BRA", 1, SE2->E2_MOEDA)
		cFilDeb  := SE2->E2_FILDEB
		cTitPai  := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
		cFilOrig := SE2->E2_FILORIG
		cMultNat := SE2->E2_MULTNAT
		cCodAprv := SE2->E2_CODAPRO

		// Cria o Fornecedor, caso nao exista
		cForCIDE := SuperGetMv("MV_FORCIDE",.T.,"CIDE")
		If ( Empty(cForCIDE), cForCIDE :=  "CIDE", Nil )

		cForCIDE := PadR( cForCIDE, __nTamFor )
		cLojaImpos := PadR( "00", __nTamLoja, "0" )
		
		SA2->( DbSetOrder(1) )
		If SA2->( !DbSeek(xFilial("SA2", cFilOrig) + cForCIDE + cLojaImpos) )
			Reclock("SA2",.T.)
				SA2->A2_FILIAL  := cFilial
				SA2->A2_COD 	:= cForCIDE
				SA2->A2_LOJA	:= cLojaImpos
				SA2->A2_NOME	:= "CIDE"
				SA2->A2_NREDUZ  := "CIDE"
				SA2->A2_BAIRRO  := "."
				SA2->A2_MUN 	:= "."
				SA2->A2_EST 	:= SuperGetMv("MV_ESTADO",.T.,"")
				SA2->A2_End 	:= "."
				SA2->A2_TIPO	:= "J"
			SA2->( MsUnlock() )
			FKCOMMIT()
		EndIf

		cNaturez := SuperGetMv("MV_CIDE",.T.,"CIDE")
		If ( Empty(cNaturez), cNaturez := "CIDE", Nil )
		
		cNaturez := PadR( cNaturez, __nTamNat )

		// Cria a natureza CIDE caso nao exista
		SED->( DbSetOrder(1) )
		If SED->( !DbSeek(cFilial+cNaturez) )
			RecLock("SED",.T.)
				SED->ED_FILIAL  := cFilial
				SED->ED_CODIGO  := cNaturez
				SED->ED_CALCIRF := "N"
				SED->ED_CALCISS := "N"
				SED->ED_CALCINS := "N"
				SED->ED_CALCCSL := "N"
				SED->ED_CALCCOF := "N"
				SED->ED_CALCPIS := "N"
				SED->ED_DESCRIC := "CIDE"
				SED->ED_TIPO	:= "2"
			SED->( MsUnlock() )
			Iif(FindFunction("JurCompSED"), JurCompSED(SED->(Recno())), Nil) //Integração SIGAPFS - Complemento da Natureza
			FKCOMMIT()
		EndIf

		SE2->( DbSetOrder(1) )
		While .T.
			// VerIfica se ja ha titulo de CIDE com esta numeração
			If SE2->( DbSeek(cFilial+cPrefixo+cNum+cParcela+"CID"+cForCIDE) )
				cParcela := Soma1( cParcela,,.t. )
				Loop
			EndIf
			Exit
		EndDo

		RecLock("SE2",.T.)
			SE2->E2_FILIAL   := xFilial("SE2", cFilOrig)
			SE2->E2_PREFIXO  := cPrefixo
			SE2->E2_NUM 	 := cNum
			SE2->E2_PARCELA  := cParcela
			SE2->E2_TIPO	 := "CID"
			SE2->E2_NATUREZ  := cNaturez
			SE2->E2_EMISSAO  := dEmissao
			SE2->E2_VALOR	 := nValCIDE
			SE2->E2_VENCREA  := dVencRea
			SE2->E2_SALDO	 := nValCIDE
			SE2->E2_VENCTO   := dVencRea
			SE2->E2_VENCORI  := dVencRea
			SE2->E2_MOEDA	 := nMoeda
			SE2->E2_EMIS1	 := dDataBase
			SE2->E2_FORNECE  := cForCIDE
			SE2->E2_VLCRUZ   := Round( SE2->E2_VALOR, MsDecimais(1) )
			SE2->E2_LOJA	 := SA2->A2_LOJA
			SE2->E2_NOMFOR   := SA2->A2_NREDUZ
			SE2->E2_ORIGEM   := cOrigem
			SE2->E2_LA       := "S"
			SE2->E2_FORMPAG  := SA2->A2_FORMPAG

			SE2->E2_TITPAI := cTitPai

			If !Empty(cFilDeb)
				SE2->E2_FILDEB := cFilDeb
			EndIf
			
			SE2->E2_SEQBX   := cSeqBx
			SE2->E2_FILORIG := cFilOrig
			SE2->E2_MULTNAT := cMultNat
			SE2->E2_CODAPRO := cCodAprv
			SE2->E2_FORMPAG := SA2->A2_FORMPAG
		SE2->( MsUnlock() )
		FKCOMMIT()

		nRecTit := SE2->( Recno() ) // Recno do Título de CIDE

		// Grava parcela do CIDE na parcela do pai (EMISSÃO)
		If cPaisLoc == "BRA" .And. Empty(cSeqBx)
			SE2->( DbGoTo( nRecPai ) )
			Reclock( "SE2" , .F. )
				SE2->E2_PARCCID := cParcela
			SE2->( MsUnlock() )
		EndIf

		RestArea(aAreaSE2)
		RestArea(aAreaSED)
		RestArea(aAreaSA2)

	EndIf

Return nRecTit

//-------------------------------------------------------------------
/*/{Protheus.doc} FDelCIDE
Efetua a gravação/retenção do CIDE de Títulos Financeiros

	@param nRecPai - Recno do Titulo Pai
	@param cParc - Parcela do CIDE
	@param cSeqBx - Sequencia de Baixa

	@return Nil 

	@author Leonardo Castro
	@since  26/11/2019
/*/
//-------------------------------------------------------------------
Function FDelCIDE( nRecPai As Numeric, cParc As Character, cSeqBx As Character)
	
	Local aAreaSE2 As Array
	Local cNatCIDE As Character
	Local cTitPai As Character
	Local cFilOrig As Character

	Default nRecPai := SE2->(Recno())
	Default cParc := ""
	Default cSeqBx := ""

	If nRecPai > 0

		aAreaSE2 := SE2->( GetArea() )
		cNatCIDE  := SuperGetMv("MV_CIDE",.T.,"CIDE")
		If Empty(cNatCIDE)
			cNatCIDE := "CIDE"
		EndIf

		// Posiciona no Título Pai
		SE2->( DbGoTo(nRecPai) )
		
		// Inicializa Variaveis 
		cTitPai  := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
		cFilOrig  := SE2->E2_FILORIG
		__nTamNat := If( ValType(__nTamNat) != "N", TamSX3("ED_CODIGO")[1], __nTamNat )
		cNatCIDE  := PadR( cNatCIDE, __nTamNat )

		// Deleta todos registros de CIDE
		
		SE2->( dbSetOrder(17) ) // E2_FILIAL + E2_TITPAI
		SE2->( dbSeek(xFilial("SE2",cFilOrig)+cTitPai) )

		While SE2->( !Eof() .And. E2_FILIAL+ALLTRIM(E2_TITPAI) == cFilial+ALLTRIM(cTitPai) )
			
			IF SE2->E2_NATUREZ == cNatCIDE .And. SE2->E2_SALDO != 0
				If ( !Empty(cSeqBx) .And. SE2->E2_SEQBX == cSeqBx ) .Or. ( !Empty(cParc) .And. SE2->E2_PARCELA == cParc )
					RecLock("SE2",.F.,.T.)
					SE2->( dbDelete() )
					SE2->( msUnLock() )
					Exit
				EndIf
			EndIf

			SE2->( DbSkip() )
		EndDo

		RestArea(aAreaSE2)
	EndIf

Return Nil

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FStruIRF

	Monta estrutura de Rateio IR Progressivo p/ CPF
	
	@param aStruRAT - Array com estrutura do RATEIO - FKJ

	Estrutura da aStruRAT
		[1]  = Codigo do Fornecedor
		[2]  = Loja do Fornecedor
		[3]  = CPF do Fornecedor
		[4]  = Percentual de Rateio
		[5]  = Base do Imposto
		[6]  = Imposto Calculado
		[7]  = Imposto Retido
		[8]  = Nome do Fornecedor
		[9]  = Base do imposto quando o MV_AGLIMPJ != 1 

	@Author	Leonardo Castro
	@since	11/12/2019
/*/
//-----------------------------------------------------------------------------------------------------
Function FStruIRF( cFilOrig As Character, cFornece As Character, cLoja As Character, aStruRAT As Array )

	Local aArea			As Array
	Local aAreaSA2		As Array
	Local aAreaFKJ		As Array

	DEFAULT cFilOrig	:= cFilAnt
	DEFAULT cFornece	:= ""
	DEFAULT cLoja		:= ""
	DEFAULT aStruRAT	:= Array(0)

	//Inicialização das variaveis
	aArea		:= GetArea()
	aAreaSA2	:= SA2->( GetArea() )
	aAreaFKJ	:= {}
	
	// Busca Fornecedor do Título
	SA2->( DbSetOrder(1) )
	If !Empty(cFornece+cLoja) .And. SA2->( DbSeek(xFilial("SA2",cFilOrig) + cFornece + cLoja) ) 
		
		// Verifica se o fornecedor trata o rateio IR Progressivo p/ CPF
		If SA2->A2_IRPROG == '1' .And. !Empty(SA2->A2_CPFIRP)

			aAreaFKJ := FKJ->( GetArea() )

			// Procura Rateios p/ CPF - TABELA FKJ
			FKJ->( DbSetOrder(1) ) // FKJ_FILIAL, FKJ_COD, FKJ_LOJA, FKJ_CPF
			If FKJ->( DbSeek( xFilial("FKJ", cFilOrig)  + cFornece + cLoja ) )

				While FKJ->(!Eof()) .And. FKJ->(FKJ_FILIAL+FKJ_COD+FKJ_LOJA) ==  xFilial("FKJ", cFilOrig) + cFornece + cLoja  
					aAdd(aStruRAT, { FKJ->FKJ_COD, FKJ->FKJ_LOJA, FKJ->FKJ_CPF, FKJ->FKJ_PERCEN, 0, 0, 0, FKJ->FKJ_NOME, 0 }) 
					FKJ->( DbSkip() )
				EndDo nX

			Else
				
				aAdd(aStruRAT, { SA2->A2_COD, SA2->A2_LOJA, SA2->A2_CGC, 100, 0, 0, 0, SA2->A2_NOME, 0 })

			EndIf

			RestArea(aAreaFKJ)
			FwFreeArray(aAreaFKJ)
		EndIf

	EndIf

	Restarea(aAreaSA2)
	RestArea(aArea)
	FwFreeArray(aAreaSA2)
	FwFreeArray(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FGetImpRet
	Retorna conteúdo de determinado campo da tabela FK4 Impostos Retidos
	
	@param cIDOrig - Identificador de Origem FK's
	@param cField  - Campo de retorno do conteúdo
	@param aFilter - Array de filtro da cláusula WHERE

	@Return xRet, Conteudo do campo que foi filtrado pela query

	@author  Leonardo Castro
	@since   15/12/2019
	@version 12
/*/
//-------------------------------------------------------------------
Function FGetImpRet(cIDOrig As Character, cField As Character, aFilter As Array)
	
	Local xRet
	Local cQuery		As Character
	Local nPos			As Numeric
	Local nX 			As Numeric
	Local aStruFK4		As Array

	DEFAULT cIDOrig := ""
	DEFAULT cField	:= "FK4_VALOR"
	DEFAULT aFilter	:= { {"FK4_IMPOS", "IRF"} }

	If !Empty(cField)

		// Estrutura da tabela FK4
		aStruFK4 := FK4->(dbStruct())

		nPos := aScan(aStruFK4,{|x|X[1] $ cField})

		If nPos > 0
			cQuery := " SELECT "+cField+" FIELD FROM " + RetSQLName("FK4")
			cQuery += " WHERE FK4_IDORIG = '" + cIDOrig + "'"

			For nX := 1 To Len(aFilter)
				cQuery += " AND " + aFilter[nX][1] + " = '" + aFilter[nX][2] + "'"
			Next nX

			cQuery += " AND FK4_STATUS = '1' "
			cQuery += " AND D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery( cQuery )
			xRet   := MpSysExecScalar(cQuery,"FIELD")

			If Empty(xRet)
				xRet := CriaVar(aStruFK4[nPos][1])
			Endif	

		EndIf
	EndIf

	FwFreeArray(aStruFK4)

Return xRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} RetIrProg
Função para verificar o Ir progressivo retido por CPF

@Param cXfilial, Filial dos movimentos
@Param cIdorig, Chave de relacionamento SE5/FK's 
@Param aRatIrf, Matriz que contem as informações sobre o rateio do IR
@author  Vitor Duca
@since   30/12/2019
@version 12
/*/
//-------------------------------------------------------------------
Function RetIrProg(cXfilial As Character, cIDOrig As Character, aRatIRF As Array, cTable As Character)
	Local nPos 		As Numeric
	Local aArea		As Array
	Local aAreaFK3	As Array
	Local aAreaFK4	As Array 
	Local cAglImPJ  As Character
	
	Default cTable := "FK2" 

	nPos 		:= 0
	aArea		:= GetArea()
	aAreaFK3	:= FK3->(GetArea())
	aAreaFK4	:= FK4->(GetArea())
	cAglImPJ	:= SuperGetMv("MV_AGLIMPJ",.T.,"1")

	FK4->(DbSetOrder(1))
	FK3->(DbSetOrder(2))

	If FK3->(DbSeek(xFiliaL("FK3",cXfilial)+cTable+cIDOrig+"IRF"))
		While FK3->(!EOF()) .and. FK3->FK3_IDORIG == cIDOrig
			If FK4->(DbSeek(xFilial("FK4",cXfilial)+FK3->FK3_IDRET))
				nPos := Ascan(aRatIRF,{ |x| AllTrim(x[3]) == AllTrim(FK4->FK4_CGC) } )
				If nPos > 0
					aRatIRF[nPos][7] += FK4->FK4_VALOR
					If cAglImPJ != '1' 
						If Len(aRatIRF[nPos]) == 9
							aRatIRF[nPos][9] := Iif(FK4->FK4_BASIMP > aRatIRF[nPos][9], FK4->FK4_BASIMP, aRatIRF[nPos][9])
						Endif	
					Endif	
				EndIf	
			Endif
			FK3->(DbSkip())
		EndDo		
	Endif

	RestArea(aAreaFK3)
	RestArea(aAreaFK4)
	RestArea(aArea)
	
Return	

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} TotCmpDic
Função para retornar o valor total de DICs compensados com o título informado.
Utilizado para recompor o valor de base para retenção de impostos, visto que esses
tipos de compensações não devem descontar da base de imposto.

@param cIdTitFK7, char, Id do título (FK7) a serem verificadas as compensações
@return nRet, Valor total de DIC compensados com o título informado

@author pedro.alencar
@since 05/03/2020
@version 1.0
@type Function
/*/
//---------------------------------------------------------------------------------------
Function TotCmpDic( cIdTitFK7 As Char ) As Numeric
	Local nRet As Numeric
	Local cQuery As Char
	Local cAliasFK2 As Char
	Default cIdTitFK7 := ""

	nRet := 0
	cAliasFK2 := GetNextAlias()
	
	cQuery := "SELECT ISNULL( SUM(FK2_VALOR), 0 ) TOTDICNDF "
	cQuery += "FROM " + RetSqlName("FK2") + " FK2 "
	cQuery += "INNER JOIN " + RetSqlName("SE2") + " SE2 "
	cQuery +=  "ON E2_FILORIG = FK2_FILORI "
	cQuery +=  "AND E2_PREFIXO || E2_NUM || E2_PARCELA || E2_TIPO || E2_FORNECE || E2_LOJA = FK2_DOC "
	cQuery +=  "AND FK2_IDDOC = '" + cIdTitFK7 + "' "
	cQuery +=  "AND SE2.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE "
	cQuery +=  "E2_TIPO = 'DIC' "
	cQuery +=  "AND FK2_TPDOC = 'CP' "
	cQuery +=  "AND FK2.D_E_L_E_T_ = ' ' "
	cQuery +=  "AND NOT EXISTS ( "
	cQuery +=   "SELECT FK2EST.FK2_IDDOC "
	cQuery +=   "FROM " + RetSqlName("FK2") + " FK2EST "
	cQuery +=   "WHERE FK2EST.FK2_FILIAL = FK2.FK2_FILIAL "
	cQuery +=   "AND FK2EST.FK2_IDDOC = FK2.FK2_IDDOC "
	cQuery +=   "AND FK2EST.FK2_SEQ = FK2.FK2_SEQ "
	cQuery +=   "AND FK2EST.FK2_TPDOC = 'ES' "
	cQuery +=   "AND FK2EST.D_E_L_E_T_ = ' ') "
	
	cQuery := ChangeQuery( cQuery )
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasFK2, .T., .T. )
	
	If ( cAliasFK2 )->( ! EOF() )
		nRet := ( cAliasFK2 )->( TOTDICNDF )
	Endif
	
	( cAliasFK2 )->( dbCloseArea() )
Return nRet


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FVerTxMoed
Função para retornar a taxa da moeda no cálculo do IRRF na baixa

@param dData, date, Data de referência para a contação da moeda
@return nRet, Taxa da moeda 

@author pedro.alencar
@since 05/03/2020
@version 1.0
@type Function
/*/
//---------------------------------------------------------------------------------------
Function FVerTxMoed(dData)

	Local nTaxMoeda := 0 

	DEFAULT dData := dDataBase

	If SE2->E2_MOEDA > 1	
		If FindFunction("F080TxMoed")
			nTaxMoeda := F080TxMoed(dData)
		Else	
			nTaxMoeda := If(SE2->E2_TXMOEDA > 0, SE2->E2_TXMOEDA, RecMoeda(dBaixa,SE2->E2_MOEDA) )
		Endif
	Endif

Return nTaxMoeda


/*/{Protheus.doc} FinDelImp
	Deleta os impostos do titulo 
	@type  Function
	@author Vitor Duca
	@since 13/04/2020
	@version 1.0
	@param aRecnos, Array, Matriz contendo os recnos dos titulos que serão deletados
	@return return, return_type, return_description
	@example
	(examples)
	@see Dicionario de funções
/*/
Function FinDelImp(aRecnos as Array)
	Local lIntPFS  As Logical
	Local aArea As Array
	Local aAreaSE2 As Array	
	Local nX As Numeric
	
	Default aRecnos := {}

	lIntPFS	 := SuperGetMv("MV_JURXFIN",.T.,.F.)
	aArea	 := GetArea()
	aAreaSE2 := SE2->(GetArea())
	nX 		 := 0 

	For nX := 1 to len(aRecnos)
		SE2->(DbGoto(aRecnos[nX]))						
		PCODetLan("000002","06","FINA050",.T.)	// Apaga o lancamento gerado no PCO
		
		If lIntPFS .and. FindFunction("JDelTitCP") 
			JDelTitCP(SE2->(Recno())) // Integração SIGAPFS x SIGAFIN remove os desdobramentos quando o titulo for deletado       
		EndIf 	
		FINDELFKs(xFilial("SE2")+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA,"SE2")
		Reclock("SE2",.F.,.T.)
		dbDelete()
		msUnLock()
	Next nX

	RestArea(aAreaSE2)
	RestArea(aArea)
Return 

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} F080Base103
Função para retornar base do IRRF para títulos vindos do MATA103

@author PEQUIM
@since 01/09/2020
@version 1.0
@type Function
/*/
//---------------------------------------------------------------------------------------
Function F080Base103(nBaseTit,nTxMoeda,nMoedaBco,nCasDec,lConvNewTx,dBaixa)
	Local nTxTitInc := 0

	DEFAULT nBaseTit	:= SE2->E2_BASEIRF
	DEFAULT nMoedaBco	:= 1
	DEFAULT nCasDec		:= TamSx3("E2_TXMOEDA")[2]
	DEFAULT nTxMoeda	:= 0	
	DEFAULT lConvNewTx	:= .T.
	DEFAULT dBaixa		:= dDataBase

	If SE2->E2_TXMOEDA == 0
		nTxTitInc := RecMoeda(SE2->E2_EMISSAO,SE2->E2_MOEDA)
	Else
		nTxTitInc := SE2->E2_TXMOEDA
	Endif
	
	If nTxMoeda == 0
		nTxMoeda := nTxTitInc
	Endif

	If lConvNewTx
		nBaseTit := Round(xMoeda(nBaseTit, 1, SE2->E2_MOEDA, dBaixa, nCasDec,,nTxTitInc), 2)
		nBaseTit := Round(xMoeda(nBaseTit, SE2->E2_MOEDA, nMoedaBco, dBaixa, nCasDec,nTxMoeda), 2)  
	Else
		nBaseTit := Round(xMoeda(nBaseTit, SE2->E2_MOEDA, nMoedaBco, dBaixa, nCasDec,nTxTitInc), 2)  
	Endif
	

Return nBaseTit

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FGetSFQIr
Função para retornar array contendo as baixas de outros títulos, cujo IRRF estava
pendente de retenção e está sendo retido na baixa atual

@author PEQUIM
@since 01/10/2020
@version 1.0
@type Function
/*/
//---------------------------------------------------------------------------------------
Function FGetSFQIr()
Return aTitCIrf

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} FZerSFQIr
Função para limpar o array aTitCIrf

@author PEQUIM
@since 01/10/2020
@version 1.0
@type Function
/*/
//---------------------------------------------------------------------------------------
Function FZerSFQIr()
	FwFreeArray(aTitCIrf)
	aTitCIrf := {}
Return	

//-------------------------------------------------------------------
/*/{Protheus.doc} fa050CalcRet
Calculo das Retenções de Impostos

@author Paulo Leme
@since  02/04/11
/*/
//-------------------------------------------------------------------
Function fa050CalcRet(cCarteira, cFatoGerador, cNatur, nValor, cPrefixo, nNum, cFornec,lGrava,cNumOP)

    //Republica Dominicana
    Local aAreaSE2   := SE2->(GetArea())
    Local aAreaFRN   := FRN->(GetArea())
    Local aAreaFRM   := FRM->(GetArea())
    Local cNroCert  := " "
    Local cFornece	:= " "
    Local cLoja		:= " "
    Local cChaveSfe	:= " "
    Local cNumNfSfe	:= " "
    Local nValBase	:= 0
    Local nValCalc   := 0
    Local nAliq     := 0
    Local cTitPai 	:= SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
    Local cOrigem  	:= FunName()
    Local cTptPai   := SE2->E2_TIPO
    Local aImposto	:= {}
    Local aAux 		:= {}
    Local nRegSE2	:= 0
    Local cTipTit	:= ""
    Local lCalcImp	:= .T.
    Local cFilterSE2:= ""
    Local cFornImp	:= ""
    Local cLojImp	:= ""
    Local dDtVenc	:= dDataBase
    Private aCerts	:= {}

    DEFAULT lGrava  := .F.
    DEFAULT cNumOP  := ""

    nValBase	:=	nValor
    //Geração das Retenções de Impostos
    DbSelectArea("FRN")
    FRN->( DbSetOrder(2) )
    If 	FRN->( DbSeek( xFilial("FRN") + cNatur ) )
        While 	!FRN->( Eof() ) .And. FRN->(xFilial("FRN") + FRN_CODNAT) 	== 	xFilial('FRN') 	+ cNatur
            If 	FRN->FRN_MSBLQL	<>	'1'
                DbSelectArea("FRM")
                FRM->( DbSetOrder(2) )
                FRM->( dbSeek(xFilial("FRM") + FRN->FRN_IMPOST + FRN->FRN_SEQ ) )
                While 	!FRM->( Eof() ) .And. FRM->(xFilial("FRM") + FRM->FRM_COD + FRM->FRM_SEQ) 	== 	xFilial('FRM') 	+ FRN->FRN_IMPOST + FRN->FRN_SEQ
                    If 	!FRM->FRM_APLICA $ "1|2"
                        FRM->( DbSkip() )
                        Loop
                    EndIf
                    SA2->( dbSetOrder(1) )
                    SA2->( dbSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA ) )
                    //1-Contas a Pagar ou 3-Ambos. Dentro da vigencia e não bloqueado
                    nValCalc     :=  0
                    If 	FRM->FRM_CARTEI	   	$ 	cCarteira 	.And. 	;
                    FRM->FRM_INIVIG    	<= 	dDataBase 	.And. 	FRM->FRM_FIMVIG  	>= 	dDataBase    .And. ;
                    FRM->FRM_MSBLQL		<>	'1' 	    .And.	;
                    FRM->FRM_BLOQ 		<> 	'1'         .And. 	;
                    (FRM->FRM_TPESSO    ==  "9"			.Or.	FRM->FRM_TPESSO  	==  SA2->A2_TIPO)
                        nValCalc     :=  0
                        nValCalc 	:= 	fa050CalcImp(FRN->FRN_IMPOST, FRN->FRN_SEQ, FRM->FRM_CARTEIRA, cNatur, nValor)

                        aAux := {FRM->FRM_SIGLA,nValCalc,FRM->FRM_APLICA}

                    EndIf
                    // Cálculo do Valor do Imposto qdo regra de aplicação definida como Retenção ou Imposto
                    If 	nValCalc > 0  .And. (!Empty(FRM->FRM_TPABT) .Or. !Empty(FRM->FRM_TPTIT))
                        If 	FRM->FRM_FATGER  ==	"1" .And. !(cOrigem $ "FINA085A|FINA850") .And. cFatoGerador <> "9"
                            If FRM->FRM_APLICA == "1"
                                RecLock("SE2",.F.)
                                E2_VALOR    := SE2->E2_VALOR  - nValCalc
                                E2_SALDO    := SE2->E2_SALDO  - nValCalc
                                E2_VLCRUZ   := SE2->E2_VLCRUZ - nValCalc
                                MsUnLock()
                            EndIf
                            /* Gerar Título de Abatimento de Retenção - SE2 */
                            /* fGerAbatCP(cPrefixo, cTitulo, cParcela, cTipoDoc, nFornec, nLoja, nValAbat, cTipoRet, cTpAbt, cTitPai)  */
                            fGerAbatCP(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, nValCalc, Iif (FRM->FRM_APLICA == "1", "I","R"), Iif (FRM->FRM_APLICA == "1", FRM->FRM_TPTIT,FRM->FRM_TPABT), cTitPai)
                        EndIf
                        If 	cOrigem $ "FINA085A|FINA850"

                            //Valida se existe imposto gerado - retido 100% na 1a. oportunidade - Baixas Parciais
                            nRegSE2 	:= SE2->(Recno())
                            cFilterSE2	:= SE2->(dbFilter())

                            dbSelectArea("SE2")
                            SE2->(dbClearFilter())
                            SE2->(dbSetOrder(1))
                            If FRM->FRM_APLICA == "1"
                                cTipTit := FRM->FRM_TPTIT
                                cFornImp := PadR(GetMV("MV_UNIAO"),TamSx3("A2_COD")[1])
                                cLojImp  := PadR("00",TamSx3("A2_LOJA")[1])
                            ElseIf FRM->FRM_APLICA == "2"
                                cTipTit := FRM->FRM_TPABT
                                cFornImp := SE2->E2_FORNECE
                                cLojImp  := SE2->E2_LOJA
                            EndIf

                            If SE2->(dbSeek(xFilial("SE2")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+cTipTit+cFornImp+cLojImp))
                                lCalcImp := .F.
                            Else
                                aAdd(aImposto, aAux)
                            EndIf

                            SE2->(dbGoTo(nRegSE2))
                            If !Empty(cFilterSE2)
                                SE2->(dbSetFilter({|| &cFilterSE2},cFilterSE2))
                            EndIf

                            If 	FRM->FRM_FATGER  ==	"2" .And. cFatoGerador <> "9" .And. lCalcImp
                                If FRM->FRM_APLICA == "1" .And. !lGrava
                                    RecLock("SE2",.F.)
                                    E2_VALOR    := SE2->E2_VALOR  - nValCalc
                                    E2_SALDO    := SE2->E2_SALDO  - nValCalc
                                    E2_VLCRUZ   := SE2->E2_VLCRUZ - nValCalc
                                    MsUnLock()
                                EndIf
                                /* Gerar Título de Abatimento de Retenção - SE2 */
                                /* fGerAbatCP(cPrefixo, cTitulo, cParcela, cTipoDoc, nFornec, nLoja, nValAbat, cTipoRet, cTpAbt, cTitPai)  */
                                If lGrava
                                    dDtVenc := FCalcVenc(SE2->E2_EMISSAO,FRM->FRM_VCDIA,FRM->FRM_VCTIPO,FRM->FRM_VCDUTI,FRM->FRM_VCCONT,FRM->FRM_VCFAT,FRM->FRM_VDTVLD)
                                    fGerAbatCP(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, nValCalc, Iif (FRM->FRM_APLICA == "1", "I","R"), Iif (FRM->FRM_APLICA == "1", FRM->FRM_TPTIT,FRM->FRM_TPABT), cTitPai, FRM->FRM_SIGLA,cNumOP,dDtVenc)
                                EndIf
                            EndIf
                        EndIf
                        If 	(FRM->FRM_FATGER  ==	"1" .And. cFatoGerador  ==	"1") .Or. (FRM->FRM_FATGER  ==	"2" .And. lGrava .And. lCalcImp)
                            /* Grava a Retencao - SFE */
                            If Empty(cNroCert)
                                If FRM->FRM_APLICA == "1"
                                    cNroCert	:=	GetCert(FRM->FRM_TPTIT+"   ",cFornece+cLoja+FRM->FRM_TPTIT+"   ")
                                Else
                                    cNroCert	:=	GetCert(FRM->FRM_TPABT+"   ",cFornece+cLoja+FRM->FRM_TPABT+"   ")
                                EndIf
                            EndIf
                            If  FRN->FRN_CONCEP == CCR->CCR_CONCEP .And. CCR->CCR_ALIQ	  <>   0
                                nAliq := CCR->CCR_ALIQ
                            Else
                                nAliq := FRM->FRM_ALIQ
                            EndIf
                            If ValType(nNum) == 'N'
                                cNumNfSfe := STR(nNum, TamSX3("FE_NFISCAL")[1])
                            Else
                                cNumNfSfe := Substr(nNum + Space(TamSX3("FE_NFISCAL")[1]),1,TamSX3("FE_NFISCAL")[1])
                            EndIf
                            cChaveSfe := xFilial("SFE") + SE2->E2_FORNECE + SE2->E2_LOJA + cNumNfSfe + cPrefixo + Iif ( FRM->FRM_APLICA == "1", "I","R") + FRN->FRN_CONCEP //FE_FILIAL+FE_FORNECE+FE_LOJA+FE_NFISCAL+FE_SERIE+FE_TIPO+FE_CONCEPT
                            If 	!FA50SfeExi(cChaveSfe,Iif (FRM->FRM_APLICA == "1", FRM->FRM_TPTIT,FRM->FRM_TPABT)) // Verifica se já existe o registro do imposto. Se não existir, inclui
                                RecLock("SFE",.T.)
                                FE_FILIAL	:=	xFilial("SFE")
                                FE_NROCERT	:=	cNroCert
                                FE_EMISSAO  :=	dDataBase
                                FE_FORNECE  :=	SE2->E2_FORNECE
                                FE_LOJA     :=	SE2->E2_LOJA
                                FE_TIPO     :=	Iif ( FRM->FRM_APLICA == "1", "I","R")
                                FE_PORCRET	:=	Iif ( CCR->CCR_REDUC  >   0 , 100 - CCR->CCR_REDUC ,  100 -	FRN->FRN_REDUC)
                                FE_ALIQ     :=	nAliq
                                FE_VALBASE  :=  nValBase
                                If FRM->FRM_APLICA == "1"
                                    FE_VALIMP	:=	nValCalc
                                Else
                                    FE_RETENC	:=	nValCalc
                                EndIf
                                FE_CONCEPT  :=  FRN->FRN_CONCEP
                                FE_ITEM     :=  1
                                FE_NFISCAL  :=  nNum
                                FE_SERIE    :=  cPrefixo
                                FE_ORDPAGO  :=  Iif( ValType("cOrdPago") <> "U", cOrdPago, SE2->E2_ORDPAGO)
                                FE_BANCO    :=	SE2->E2_BCOCHQ
                                FE_AGENCIA  :=	SE2->E2_AGECHQ
                                FE_NUMCOM   := 	SE2->E2_CTACHQ
                                FE_TPTIMP   :=  Iif (FRM->FRM_APLICA == "1", FRM->FRM_TPTIT,FRM->FRM_TPABT)
                                FE_TPTPAI   :=  cTptPai
                                FE_SIGLA    :=  FRM->FRM_SIGLA
                                MsUnLock()
                            EndIf
                        EndIf
                    EndIf
                    FRM->( DbSkip() )
                EndDo
            EndIf
            RestArea(aAreaSE2)
            FRN->( DbSkip() )
        EndDo

        If Type("aRetencao") == "A"
            aAdd( aRetencao, {SE2->E2_FILIAL,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,aImposto} )
        EndIf

    EndIf
    RestArea(aAreaFRM)
    RestArea(aAreaFRN)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fa050CalcImp
Calculo do Imposto

@author Calculo do Imposto
@since  02/04/11
/*/
//-------------------------------------------------------------------
Function fa050CalcImp(cImposto, cSequencia, cCarteira, cNatur, nValor)

    Local aAreaFRN  := FRN->(GetArea())
    Local aAreaFRM  := FRM->(GetArea())
    Local nValImp 	:= 0

    FRN->( DbSetOrder(2) )
    If 	FRN->( DbSeek(xFilial("FRN") + cNatur + cImposto + cSequencia ) )
        FRM->( DbSetOrder(2) )
        If FRM->( dbSeek(xFilial("FRM") + FRN->FRN_IMPOST + FRN->FRN_SEQ + cCarteira ) )
            // Cálculo do Valor do Imposto qdo regra de aplicação definida como Retenção
            If 	FRM->FRM_CARTEI	$ 	"1|3"
                If	!Empty(FRN->FRN_CONCEP)
                    CCR->( dbSetOrder(1) )
                    If CCR->( dbSeek(xFilial("CCR")+AvKey(FRN->FRN_CONCEP,"CCR_CONCEP")) ) .And. CCR->CCR_ALIQ 	<> 	0
                        nValImp 		:= 	(CCR->CCR_ALIQ 	* nValor )   / 100
                        If	CCR->CCR_REDUC 	<> 	0
                            nValImp 		:= 	nValImp - (CCR->CCR_REDUC * nValImp ) / 100
                        EndIf
                    ElseIf FRM->FRM_ALIQ <> 0
                        nValImp 		:= 	(FRM->FRM_ALIQ 	* nValor ) 	/ 100
                        If FRN->FRN_REDUC <> 0
                            nValImp 		:= 	nValImp - (FRN->FRN_REDUC * nValImp ) / 100
                        EndIf
                    EndIf
                EndIf
                If  Empty(FRN->FRN_CONCEP)
                    If 	FRM->FRM_ALIQ 		<> 	0
                        nValImp 			:= 	(FRM->FRM_ALIQ 	* nValor) 	/ 100
                    EndIf
                    If 	FRN->FRN_REDUC 		<> 	0
                        nValImp 			:= 	nValImp - (FRN->FRN_REDUC * nValImp ) / 100
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
    RestArea(aAreaFRN)
    RestArea(aAreaFRM)

Return nValImp

//-------------------------------------------------------------------
/*/{Protheus.doc} fa050DelRet
Deleção do Calculo das Retenções de Impostos de Um Titulo

@author Paulo Leme
@since  02/03/11
/*/
//-------------------------------------------------------------------
Function fa050DelRet()
    //Republica Dominicana
    Local aAreaSE2   := SE2->(GetArea())
    Local cSE2Fil    :=	xFilial("SE2")
    Local cFornec    :=	SE2->E2_FORNECE
    Local cLoja      := SE2->E2_LOJA
    Local cPrefixo   := SE2->E2_PREFIXO
    Local cNum       := SE2->E2_NUM

    //Excluir registros na Tabela de Contas a Pagar dos Titulos de Retenções de Impostos
    SE2->(dbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
    If SE2->(dbSeek(cSE2Fil+cFornec+cLoja+cPrefixo+cNum))
        While !Eof( ) .And. SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM == ;
        cSE2Fil+cFornec+cLoja+cPrefixo+cNum
            If SE2->E2_TIPO $ MVABATIM

                FINDELFKs(xFilial("SE2")+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA,"SE2")
                RecLock("SE2",.F.)
                dbDelete()
                MsUnLock()
            EndIf
            SE2->(dbSkip())
        EndDo
    EndIf
    //Excluir registros na Tabela de Contas a Pagar dos Titulos de Retenções de Impostos
    SFE->(dbSetOrder(4)) //FE_FILIAL+FE_FORNECE+FE_LOJA+FE_NFISCAL+FE_SERIE+FE_TIPO
    If SFE->(dbSeek(cSE2Fil+cFornec+cLoja+cNum+cPrefixo))
        While !Eof( ) .And. SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NUM+SFE->FE_PREFIXO == ;
        cSE2Fil+cFornec+cLoja+cNum+cPrefixo
            RecLock("SFE",.F.)
            dbDelete()
            MsUnLock()
            SFE->(dbSkip())
        EndDo
    EndIf
    RestArea(aAreaSE2)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} FBrdPdRet
Verifica pendência de impostos quando titulo em borderô

@author Pequim
@since  17/11/2020
/*/
//-------------------------------------------------------------------
Function FBrdPdRet(cImposto, aTitCalc, cFilOrig, cChaveFK7, dRef, lTitCalc )

	Local lRet := .F.

	Default cImposto	:= ""
	Default aTitCalc	:= {}
	Default cFilOrig	:= ""
	Default cChaveFK7	:= ""
	Default dRef		:= dDataBase		
	Default lTitCalc	:= .F.

	FK3->(dbSetOrder(2))	//FK3_FILIAL, FK3_TABORI, FK3_IDORIG, FK3_IMPOS, R_E_C_N_O_, D_E_L_E_T_
	If FK3->(MsSeek(xFilial("FK3", cFilOrig)+ "FK7"+ cChaveFK7 + cImposto))
		If Empty(FK3->FK3_IDRET) .and. FK3->FK3_DATA == dRef	//Não teve retenção na mesma data.
			lRet := .T.
			If !lTitCalc
				AADD(aTitCalc,{"FK7", cChaveFK7})
				lTitCalc := .T.
			Endif
		Endif
	Endif
Return lRet


//------------------------------------------------------------------------
/*/{Protheus.doc} RetImpBxCR
Retorna quais impostos deverao ser gerados na retencao pela baixa
A funcao deve ser chamada com a SE1 posicionada

@param cFiltro = String com filtro de impostos a serem verificados
@author Igor Nascimento
@since 10/11/2020
@version P12.1.27
/*/
//------------------------------------------------------------------------
Function RetImpBxCR(cFiltro As Character) As Array

	Local aArea			As Array
	Local aAreaSE1		As Array
	Local aImp			As Array
	Local cFilAbat		As Character
	Local cPrefixo		As Character
	Local cNumero		As Character
	Local cParcela		As Character
	Local cTipo			As Character
	Local cCliLj		As Character
	Local nTotIrAbt		As Numeric
	Local nTotCsAbt		As Numeric
	Local nTotPisAbt	As Numeric
	Local nTotCofAbt	As Numeric
	Local nTotISS		As Numeric

	Default cFiltro := MVIRABT+"/"+MVINABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVISABT+"/"+MVFUABT

	If __lPccBx == NIL
		__lPccBx  := FPccBxCr()
		__lIRPJBx := FIrPjBxCr(.T.)
		__lIssBx   := IsIssBx("R")
	EndIf

	aArea 		:= GetArea()
	aAreaSE1	:= SE1->(GetArea())
	aImp  		:= {}	// Estrutura: [1] = "Imposto" (variaveis globais de abatimento)
	cFilAbat	:= SE1->E1_FILIAL
	cPrefixo	:= SE1->E1_PREFIXO
	cNumero		:= SE1->E1_NUM
	cParcela	:= SE1->E1_PARCELA
	cTipo		:= SE1->E1_TIPO
	cCliLj		:= SE1->(E1_CLIENTE+E1_LOJA)
	Store 0 To nTotIrAbt, nTotCsAbt, nTotPisAbt, nTotCofAbt, nTotISS

	If !Empty(SE1->E1_NUMBOR)
		IF VLDBOR(SE1->E1_NUMBOR,"R",SE1->E1_FILORIG)
			Aadd(aImp,{MVIRABT})
			Aadd(aImp,{MVPIABT})
			Aadd(aImp,{MVISABT})
		EndIf
	Else
		If SE1->(E1_IRRF+E1_PIS+E1_COFINS+E1_CSLL+E1_ISS+E1_INSS) > 0
			SE1->(dbSetOrder(OrdTitpai()))
			If	SE1->(dbSeek(cFilAbat+cPrefixo+cNumero+cParcela+cTipo+cCliLj))
				While SE1->(!Eof()) .and. !Empty(SE1->E1_TITPAI) .and.;
					  SE1->(E1_FILIAL+E1_TITPAI) == cFilAbat+Padr(cPrefixo+cNumero+cParcela+cTipo+cCliLj,Len(SE1->E1_TITPAI))
					If !Empty(SE1->E1_TITPAI) .and. SE1->E1_TITPAI != Padr(cPrefixo+cNumero+cParcela+cTipo+cCliLj,Len(SE1->E1_TITPAI))
						SE1->(dbSkip())
						Loop
					EndIf
					If !Empty(cCliLj) .and. SE1->(E1_CLIENTE+E1_LOJA) == cCliLj
						If SE1->E1_TIPO $ cFiltro
							//IRRF
							If __lIRPJBx .and. SE1->E1_TIPO $ MVIRABT
								nTotIrAbt += SE1->E1_VLCRUZ
								SE1->(dbSkip())
								Loop
							Endif
							//PCC
							If __lPccBx
								//CSLL
								If SE1->E1_TIPO $ MVCSABT
									nTotCsAbt += SE1->E1_VLCRUZ
									SE1->(dbSkip())
									Loop
								Endif
								//PIS
								If SE1->E1_TIPO $ MVPIABT
									nTotPisAbt += SE1->E1_VLCRUZ
									SE1->(dbSkip())
									Loop
								Endif
								//COFINS
								If SE1->E1_TIPO $ MVCFABT
									nTotCofAbt += SE1->E1_VLCRUZ
									SE1->(dbSkip())
									Loop
								Endif
							EndIf
							//ISS
							If __lIssBx .and. SE1->E1_TIPO $ MVISABT 
								nTotISS += SE1->E1_VLCRUZ
								SE1->(dbSkip())
								Loop
							EndIf
						EndIf
					ElseIf Empty(cCliLj)
						Exit
					Endif
					SE1->(dbSkip())
				Enddo
			EndIf
			//IRRF
			If nTotIrAbt == 0 .and. __lIRPJBx
				Aadd(aImp,{MVIRABT})
			ElseIf nTotIrAbt > 0 .and. nTotIrAbt < SE1->E1_IRRF		// Se houve retencao parcial
				Aadd(aImp,{MVIRABT})
			EndIf
			//PCC - Usa o tipo de abatimento do PIS
			If nTotPisAbt+nTotCofAbt+nTotCsAbt == 0 .and. __lPccBx
				Aadd(aImp,{MVPIABT})
			ElseIf nTotPisAbt+nTotCofAbt+nTotCsAbt > 0 .and. nTotPisAbt+nTotCofAbt+nTotCsAbt < SE1->(E1_PIS+E1_COFINS+E1_CSLL)	// Retencao parcial
				Aadd(aImp,{MVPIABT})
			EndIf
			//ISS
			If nTotISS == 0 .and. __lIssBx
				Aadd(aImp,{MVISABT})
			ElseIf nTotISS > 0 .and. nTotISS < SE1->E1_ISS			// Se houve retencao parcial
				Aadd(aImp,{MVISABT})
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
	RestArea(aAreaSE1)

Return aImp

//------------------------------------------------------------------------
/*/{Protheus.doc} RetImpBxCR
Retorna a soma de todos os impostos retidos na baixa do titulo
A funcao deve ser chamada com a SE1 posicionada

@author Igor Nascimento
@since 10/11/2020
@version P12.1.27
/*/
//------------------------------------------------------------------------
Function TotImpBxCR() As Numeric

	Local aAreaSE1		As Array
	Local cChave		As Array
	Local nImpRet		As Numeric

	aAreaSE1 := SE1->(GetArea())
	cChave	 := SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_CLIENTE+E1_LOJA)
	nImpRet	 := 0

	SE1->(dbSetOrder(OrdTitPai()))
	If SE1->(dbSeek(SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))
		While SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_CLIENTE+E1_LOJA) == cChave
			If SE1->E1_TIPO $ "PIS|COF|CSL|IRF|ISS"
				nImpRet	+= SE1->E1_VALOR
			EndIf
			SE1->(dbSkip())
		EndDo
	EndIf

	RestArea(aAreaSE1)

Return nImpRet

//------------------------------------------------------------------------
/*/{Protheus.doc} FinxCPcc
Essa função vai retornar o valor dos valores dos impostos de pIS, Cofins e Csll.
Para clientes Publicos vai proporcionalizar a base pois o Csll pode ter base 
diferenciada do Pis e Cofins.

@author Rene Julian
@since 10/02/2021
@version P12.1.27
/*/
//------------------------------------------------------------------------
Static Function FinxCPcc(nValorRef As Numeric ) As Array
	Local aValPcc  As Array
	Local nValRef  As Numeric 
	Local nValPis  As Numeric
	Local nValCof  As Numeric
	Local nValCsl  As Numeric
	Local nValTit  As Numeric
	Local nValPor  As Numeric 
	Local lMVGlosa As Logical
	
	Default nValorRef := 0
	
	//Inicializa variáveis
	aValPcc  := {0,0,0}
	nValRef  := IIf(Type("nValRec") == "U" , 0 , nValRec )
	nValPis  := 0
	nValCof  := 0
	nValCsl  := 0
	nValTit  := 0
	nValPor  := 0
	lMVGlosa := SuperGetMv("MV_GLOSA", .F., .F.)
	
	If FwIsInCallStack("FINA070") 		
		aValPcc := {}	
		
		If nValRef == SE1->E1_BASECSL
			AAdd(aValPcc , SE1->E1_BASEPIS )
			AAdd(aValPcc , SE1->E1_BASECOF )
			AAdd(aValPcc , SE1->E1_BASECSL )
		Else
			nValTit := SE1->E1_VALOR 
			nValPor := Iif(lMVGlosa, 1, (nValRef / nValTit))
			nValPis := SE1->E1_BASEPIS * nValPor
			nValCof := SE1->E1_BASECOF * nValPor
			nValCsl := SE1->E1_BASECSL * nValPor
						
			AAdd(aValPcc , nValPis )
			AAdd(aValPcc , nValCof )
			AAdd(aValPcc , nValCsl )  
		EndIf
	Else 
		AAdd(aValPcc, IIf(lMVGlosa, SE1->E1_BASEPIS, nValorRef))
		AAdd(aValPcc, IIf(lMVGlosa, SE1->E1_BASECOF, nValorRef))
		AAdd(aValPcc, IIf(lMVGlosa, SE1->E1_BASECSL, nValorRef))
	EndIf
Return aValPcc



//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FObjClean

Limpa o objeto da temporarytable

@Author	Mauricio Pequim Jr
@since	23/02/2021
/*/
//-----------------------------------------------------------------------------------------------------
Function FObjClean()

If __oQryIrpj <> Nil
	__oQryIrpj:Destroy()
	__oQryIrpj := Nil
Endif
If __oQryBxCR <> Nil
	__oQryBxCR:Destroy()
	__oQryBxCR := Nil
Endif
If __oQryBdCR <> Nil
	__oQryBdCR:Destroy()
	__oQryBdCR := Nil
Endif
If __oQryRACR <> Nil
	__oQryRACR:Destroy()
	__oQryRACR := Nil
Endif

Return

/*/{Protheus.doc} FCriaRatIR
	Define a função que sera chamada para criação do objeto de
	calculo do rateio do IR
	@type  Function
	@author user
	@since 02/07/2021
	@version 1.0
	@return bFunction, CodeBlock , Executa a função de acordo com a pilha de chamada
	@see (links_or_references)
/*/
Function FCriaRatIR()
	Local bFunction As Codeblock

	bFunction := {|| NIL }	

	Do CASE
		CASE FwIsInCallStack("FINA080") .and. FindFunction('f080CRatIR')
			bFunction := { || f080CRatIR() }
		CASE FwIsInCallStack("FINA050") .and. FindFunction('f050CRatIR')	
			bFunction := {|| f050CRatIR() }	
		CASE FwIsInCallStack("FINA090") .and. FindFunction('F090CRatIR')	
			bFunction := {|| F090CRatIR() }	
		CASE FwIsInCallStack("FINA091") .and. FindFunction('F091CRatIR')	
			bFunction := {|| F091CRatIR() }			
		CASE FwIsInCallStack("FINA241") .and. FindFunction('F241CRatIR')	
			bFunction := {|| F241CRatIR() }	
		CASE FwIsInCallStack("FINA340") .and. FindFunction('F340CRatIR')	
			bFunction := {|| F340CRatIR() }	
		CASE FwIsInCallStack("FINA590") .and. FindFunction('F241CRatIR')	
			bFunction := {|| F241CRatIR() }	
	ENDCASE	

Return Eval(bFunction)

/*/{Protheus.doc} FSetRatIR
	Define a função que sera chamada para alteração do objeto de
	calculo do rateio do IR
	@type  Function
	@author user
	@since 02/07/2021
	@version 1.0
	@return bFunction, CodeBlock , Executa a função de acordo com a pilha de chamada
	@see (links_or_references)
/*/
Function FSetRatIR(oRatIrf)
	Local bFunction As Codeblock

	bFunction := {|| NIL }	

	Do CASE
		CASE FwIsInCallStack("FINA080") .and. FindFunction('f080SRatIR')
			bFunction := { || f080SRatIR(oRatIrf) }
		CASE FwIsInCallStack("FINA050") .and. FindFunction('f050SRatIR')	
			bFunction := {|| f050SRatIR(oRatIrf) }
		CASE FwIsInCallStack("FINA090") .and. FindFunction('F090SRatIR')	
			bFunction := {|| F090SRatIR(oRatIrf) }	
		CASE FwIsInCallStack("FINA091") .and. FindFunction('F091SRatIR')	
			bFunction := {|| F091SRatIR(oRatIrf) }	
		CASE FwIsInCallStack("FINA241") .and. FindFunction('F241SRatIR')	
			bFunction := {|| F241SRatIR(oRatIrf) }	
		CASE FwIsInCallStack("FINA340") .and. FindFunction('F340SRatIR')	
			bFunction := {|| F340SRatIR(oRatIrf) }	
		CASE FwIsInCallStack("FINA590") .and. FindFunction('F241SRatIR')	
			bFunction := {|| F241SRatIR(oRatIrf) }	
	ENDCASE	

	Eval(bFunction)

Return 

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SumDayFK

Verificar total baixado diário do PCC(Pis, Cofins, Csll) de acordo com a Lei 13.137

@param cCart, character, Carteira ("P" = Pagar, "R" = Receber)
@param cFil, character, Filial
@param cCodigo, character, Código do Cliente/Fornecedor
@param cLoja, character, Loja do Cliente/Fornecedor
@param cTipo, character, Tipo do Cliente/Fornecedor
@param dRef, date, Data de Referência
@param cFilOrig, character , Filial de origem do título
@param aTitCalc, array, Informações dos títulos cujos impostos serão retidos nesse movimento (cumulatividade)
@param cFiliais, character, Filiais a serem consideradas para o processo (SE5)
@param cFilE1, character, Filiais a serem consideradas para o processo (SE1/SE2)
@param lPenTxR, logical, Possui baixa com pendência de retenção 
@param lAltEmi, logical, Se a SumDay foi chamada da alteraçao/emissao
@param aCliFor, array, Clientes/Fornecedores a serem considerados no processo

@return aDados - Retorna o total pendente dos impostos baixados no dia.
@sample aDados[1] = Total diário do PIS
		aDados[2] = Total diário do COFINS
		aDados[3] = Total diário do CSLL
		aDados[4] = Indica se valida o valor mínimo (.T. ou .F.)


@Author	Mauricio Pequim Jr
@since	23/02/2021
/*/
//-----------------------------------------------------------------------------------------------------

Function SumDayFK (cCart As Character,cFil As Character,cCodigo As Character,cLoja As Character,cTipo As Character,dRef As Date, cFilOrig As Character, aTitCalc As Array, ;
					 aFil As Array, lPenTxR As Logical, lAltEmi As Logical, aCliFor As Array) As Array

	Local aAreaAt		As Array
	Local aDados		As Array
	Local cAliasQry 	As Array
	Local cOrigem		As Character
	Local cQuery 		As Character
	Local cChaveFK7		As Character
	Local cChaveTit		As Character
	Local nValRetBd		As Numeric
	Local nTBCalPis 	As Numeric
	Local nTCalcPis 	As Numeric
	Local nTBRetPis 	As Numeric
	Local nTotRtPis 	As Numeric
	Local nPisAux		As Numeric
	Local nTBCalCof 	As Numeric
	Local nTCalcCof 	As Numeric
	Local nTBRetCof 	As Numeric
	Local nTotRtCof 	As Numeric
	Local nCofAux		As Numeric
	Local nTBCalCsl 	As Numeric
	Local nTCalcCsl 	As Numeric
	Local nTBRetCsl 	As Numeric
	Local nTotRtCsl 	As Numeric
	Local nCslAux		As Numeric	
	Local nPis			As Numeric
	Local nCof			As Numeric
	Local nCsl			As Numeric
	Local nValTit		As Numeric
	Local nVlAcess		As Numeric
	Local nSaldo		As Numeric
	Local nImpRetEmi	As Numeric
	Local nVencto 		As Numeric
	Local nTamImp		As Numeric
	Local nLenaCliF		As Numeric
	Local nKco			As Numeric
	Local lLojaAtu		As Logical
	Local lRet			As Logical
	Local lRaRtImp 	 	As Logical
	Local lFina241		As Logical
	Local lFina080		As Logical
	Local lFina061		As Logical
	Local lFina891		As Logical
	Local lFina330		As Logical
	Local lFatCom		As Logical
	Local lJurMulDes 	As Logical
	Local lRoundPis		As Logical
	Local lRoundCof		As Logical
	Local lRoundCsl		As Logical
	Local lTitCalc		As Logical
	Local cIdTrbFk3		As Character

	Default cFilOrig 	:= cFilAnt
	Default aTitCalc	:= {}
	Default lPenTxR    	:= .F.
	Default aFil 		:= {}
	Default aCliFor		:= {}
	Default cFiliais	:= ""
	Default cFilE1		:= ""
	
	aAreaAt		:= getArea()
	aDados		:= Array(7)
	cAliasQry 	:= GetNextAlias()
	cOrigem		:= ""
	cQuery 		:= ""
	lLojaAtu	:= ( SuperGetMv( "MV_LJ10925",.F., "1" ) == "1" )
	lRet		:= .F.
	nPis		:= 0
	nCof		:= 0
	nCsl		:= 0
	nValTit		:= 0
	nVlAcess	:= 0
	nSaldo		:= 0
	nImpRetEmi	:= 0
	nVencto 	:= IIF(cCart=="P",SuperGetMv("MV_VCPCCP",.T.,1) ,SuperGetMv("MV_VCPCCR",.T.,1))
	lRaRtImp 	:= FRaRtImp()
	lFina241	:= FwIsInCallStack("F241Impost")
	lFina080	:= FwIsInCallStack("Fa080tit")
	lFina061	:= FwIsInCallStack("Fa061Borde")
	lFina891	:= FwIsInCallStack("PIXGerImp")
	lFina330	:= FwIsInCallStack("fA330Comp")
	lFatCom     := FwIsInCallStack("MAPVLNFS") .OR. FwIsInCallStack("A103ATUSE2")// COLOCAR FAT POR PEDIDO MATA410....
	lFina061	:= FwIsInCallStack("Fa061Borde")
	lFina891	:= FwIsInCallStack("PIXGerImp")
	lFina330	:= FwIsInCallStack("fA330Comp")
	lRaRtImp	:= FRaRtImp()

	lJurMulDes 	:= (SuperGetMv("MV_IMPBAIX",.t.,"2") == "1")
	lRoundPis	:= SuperGetMV("MV_RNDPIS",,.F.)
	lRoundCof	:= SuperGetMV("MV_RNDCOF",,.F.)
	lRoundCsl	:= SuperGetMV("MV_RNDCSL",,.F.)
	lLojaAtu	:= ( SuperGetMv("MV_LJ10925",.F., "1") == "1" )
	cChaveFK7   := ""
	cChaveTit 	:= ""
	nValRetBd	:= 0
	lTitCalc	:= .F.	//Verifica se o título foi incluido no array aTitCalc (pendentes de retenção)
	aAreaAt		:= getArea()
	aDados		:= Array(7)
	cAliasQry 	:= GetNextAlias()
	cQuery 		:= ""
	nI			:= 0
	cChaveTit 	:= ""
	cChaveFK7	:= ""
	nLenaCliF	:= Len(aCliFor)
	nKco		:= 0

	nTBCalPis	:= 0		//Base Calculada
	nTCalcPis 	:= 0		//Valor Calculado
	nTBRetPis 	:= 0		//Base Retidos
	nTotRtPis 	:= 0		//Valor Retido
	nPisAux		:= 0

	nTBCalCof 	:= 0		//Base Calculada
	nTCalcCof 	:= 0		//Valor Calculado
	nTBRetCof 	:= 0		//Base Retidos
	nTotRtCof	:= 0		//Valor Retido
	nCofAux		:= 0

	nTBCalCsl 	:= 0		//Base Calculada
	nTCalcCsl 	:= 0		//Valor Calculado
	nTBRetCsl 	:= 0		//Base Retidos
	nTotRtCsl 	:= 0		//Valor Retido
	nCslAux		:= 0

	IF __cImpPIS == NIL
		nTamImp := TamSx3("FK3_IMPOS")[1]
		__cImpPIS := PADR( "PIS", nTamImp )
		__cImpCOF := PADR( "COF", nTamImp )
		__cImpCSL := PADR( "CSL", nTamImp )
	Endif

	If cCart == 'R'
		//--------------------------------------------------------------
		//Tratamento para PCC na Baixa - Contas a Receber
		//--------------------------------------------------------------	
		If __oPccBxCR == Nil .Or. nLenaCliF > 0
			cQuery := "SELECT FK1.FK1_FILIAL, FK1.FK1_IDFK1 , FK1.FK1_SEQ, FK1.FK1_IDDOC, " 
			cQuery += 		" FK3.FK3_VALOR , FK3.FK3_BASIMP, FK3.FK3_IMPOS, FK3.FK3_DATA, FK3.FK3_MOEDA, "
			cQuery += 		" FK3.FK3_CODFKM, FK3.FK3_IDRET , FK3.FK3_FILORI, FK3.R_E_C_N_O_ FK3RECNO, "
			cQuery += 		" FK3.FK3_TABORI, FK3.FK3_IDORIG, FK3.FK3_RECPAG, "
			cQuery += 		" FK4.FK4_VALOR , FK4.FK4_BASIMP, FK4.FK4_IMPOS, FK4.FK4_DATA, FK4.FK4_MOEDA, "
			cQuery += 		" FK4.FK4_CODFKM, FK4.FK4_IDFK4 , FK4.FK4_FILORI, FK4.R_E_C_N_O_ FK4RECNO, "
			cQuery += 		" FK4.FK4_RECPAG, FK4.FK4_IDORIG "
			cQuery += "FROM " + RetSqlName( "FK1" ) + " FK1 "

			cQuery += "INNER JOIN " + RetSqlName("FK3") + " FK3 "
			cQuery += 		"ON FK3.FK3_FILIAL = FK1.FK1_FILIAL "
			cQuery += 		"AND FK3.FK3_IDORIG = FK1.FK1_IDFK1 "
			cQuery += 		"AND FK3_IMPOS IN ('PIS','COF','CSL') "
			cQuery += 		"AND FK3.FK3_TABORI = 'FK1' "
			If nLenaCliF > 0
				//Verificar determinados fornecedores (raiz do CNPJ)
				cQuery += "AND ( "
				For nKco := 1 to nLenaCliF
					cQuery += "(FK3.FK3_CLIFOR ='" + aCliFor[nKco,1]  + "' AND "
					cQuery += "FK3.FK3_LOJA ='"    + aCliFor[nKco,2]
					
					If nKco < nLenaCliF
						cQuery +=  + "') OR "
					else
						 cQuery +=  + "') "
					Endif

				Next nKco
				cQuery += ") "
			Else  //Apenas o fornecedor Atual
				cQuery += 		"AND FK3.FK3_CLIFOR = ? "		//01
				If lLojaAtu
					cQuery += 	"AND FK3.FK3_LOJA = ?	"		//02
				Endif
			Endif
			cQuery += 		"AND FK3.FK3_RECPAG = 'R' "
			cQuery += 		"AND FK3_STATUS = '1' "
			cQuery += 		"AND FK3.D_E_L_E_T_ = ' ' "

			cQuery += " LEFT JOIN " + RetSqlName("FK4") + " FK4 "
			cQuery += 		"ON FK4.FK4_FILIAL = FK3.FK3_FILIAL "
			cQuery += 		"AND FK4.FK4_IDORIG = FK3.FK3_IDORIG "
			cQuery += 		"AND FK4.FK4_IMPOS = FK3.FK3_IMPOS "

			If nLenaCliF > 0
				//Verificar determinados fornecedores (raiz do CNPJ)
				cQuery += "AND ( "
				For nKco := 1 to nLenaCliF
					cQuery += "(FK4.FK4_CLIFOR ='" + aCliFor[nKco,1]  + "' AND "
					cQuery += "FK4.FK4_LOJA ='"    + aCliFor[nKco,2]
					
					If nKco < nLenaCliF
						cQuery +=  + "') OR "
					else
						 cQuery +=  + "') "
					Endif

				Next nKco
				cQuery += ") "
			Else  //Apenas o fornecedor Atual
				cQuery += 		"AND FK4.FK4_CLIFOR = ? "		//01
				If lLojaAtu
					cQuery += 	"AND FK4.FK4_LOJA = ?	"		//02
				Endif
			Endif

			cQuery += 		"AND FK4.FK4_RECPAG = 'R' "
			cQuery += 		"AND FK4.FK4_STATUS = '1' "
			cQuery += 		"AND FK4.D_E_L_E_T_ = ' ' "

			cQuery += "WHERE FK1.FK1_FILORI IN (?) "	//05
			cQuery += 		"AND FK1_RECPAG = 'R' "
			cQuery += 		"AND FK1_DATA = ? "			//06
			cQuery += 		"AND FK1.D_E_L_E_T_ = ' ' "
			cQuery += 		"AND NOT EXISTS( "
			cQuery += 			"SELECT FK1EST.FK1_IDDOC FROM " + RetSqlName("FK1") +" FK1EST "
			cQuery += 			"WHERE FK1EST.FK1_FILORI = FK1.FK1_FILORI "
			cQuery +=		 		"AND FK1EST.FK1_IDDOC = FK1.FK1_IDDOC "
			cQuery +=		 		"AND FK1EST.FK1_SEQ = FK1.FK1_SEQ "
			cQuery += 				"AND FK1EST.FK1_TPDOC = 'ES' "
			cQuery += 				"AND FK1EST.D_E_L_E_T_ = ' ') "

			cQuery := ChangeQuery( cQuery )
			__oPccBxCR := FWPreparedStatement():New(cQuery)

		Endif		
		nI := 1
		If nLenaCliF == 0
			__oPccBxCR:SetString(nI,cCodigo)		//FK3_CLIFOR
			nI ++
			If lLojaAtu
				__oPccBxCR:SetString(nI,cLoja)		//FK3_LOJA (OPCIONAL)
				nI ++
			EndIf
			__oPccBxCR:SetString(nI,cCodigo)		//FK3_CLIFOR
			nI ++
			If lLojaAtu
				__oPccBxCR:SetString(nI,cLoja)		//FK3_LOJA (OPCIONAL)
				nI ++
			Endif
		Endif
		__oPccBxCR:SetIn(nI, aFil )				//FK3_FILORIG
		nI++
		__oPccBxCR:SetString(nI,DToS( dRef ))	//FK3_DATA

		cQuery := __oPccBxCR:GetFixQuery()

		cAliasQry := mpsysopenquery(cQuery)

		cIdTrbFk3 := ""

		While !( cAliasQry )->( Eof())

			If cIdTrbFk3 != ( cAliasQry )->FK3_IDORIG
				cIdTrbFk3 := ( cAliasQry )->FK3_IDORIG
				lTitCalc  := .F.
			Endif

			If ( cAliasQry )->FK3_IMPOS == __cImpPIS
				nTBCalPis += ( cAliasQry )->FK3_BASIMP		//Base Calculada
				nTCalcPis += ( cAliasQry )->FK3_VALOR		//Valor Calculado

				If !lTitCalc .and. Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
					//Registros pendentes de retenção que terão seu imposto retido na baixa atual
					AADD(aTitCalc,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
					lTitCalc := .T.
				Else
					nTBRetPis += ( cAliasQry )->FK4_BASIMP
					nTotRtPis += ( cAliasQry )->FK4_VALOR
				Endif

			ElseIf ( cAliasQry )->FK3_IMPOS == __cImpCOF
				nTBCalCof += ( cAliasQry )->FK3_BASIMP		//Base Calculada
				nTCalcCof += ( cAliasQry )->FK3_VALOR		//Valor Calculado

				If !lTitCalc .AND. Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
					//Registros pendentes de retenção que terão seu imposto retido na baixa atual
					AADD(aTitCalc,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
					lTitCalc := .T.
				ElseIf !Empty( ( cAliasQry )->FK3_IDRET )		//Se houve retenção
					nTBRetCof += ( cAliasQry )->FK4_BASIMP
					nTotRtCof += ( cAliasQry )->FK4_VALOR
				Endif

			ElseIf ( cAliasQry )->FK3_IMPOS == __cImpCSL
				nTBCalCsl += ( cAliasQry )->FK3_BASIMP		//Base Calculada
				nTCalcCsl += ( cAliasQry )->FK3_VALOR		//Valor Calculado

				If !lTitCalc .AND. Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
					//Registros pendentes de retenção que terão seu imposto retido na baixa atual
					AADD(aTitCalc,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
					lTitCalc := .T.
				ElseIf !Empty( ( cAliasQry )->FK3_IDRET )		//Se houve retenção
					nTBRetCsl += ( cAliasQry )->FK4_BASIMP
					nTotRtCsl += ( cAliasQry )->FK4_VALOR
				Endif

			Endif

			(cAliasQry)->(DbSkip())
		EndDo

		If Select(cAliasQry) > 0
			( cAliasQry )->( dbCloseArea() )
		Endif

		//--------------------------------------------------------------
		// Tratamento de retenção de PCC via borderô de impostos.
		//--------------------------------------------------------------
		cChaveTit := xFilial("SE1", SE1->E1_FILORIG) + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" + SE1->E1_CLIENTE+ "|" + SE1->E1_LOJA
		cChaveFK7 := FINGRVFK7("SE1", cChaveTit)

		If __oPccBdCR == Nil .Or. nLenaCliF > 0

			cQuery := "SELECT FK3.FK3_FILIAL, FK3.FK3_IDFK3, FK3.FK3_DATA, FK3.FK3_VALOR, FK3.FK3_MOEDA, FK3.FK3_NATURE, FK3.FK3_RECPAG, FK3.FK3_IDRET, "
			cQuery += "FK3.FK3_IMPOS, FK3.FK3_FILORI, FK3.FK3_BASIMP, FK3.FK3_ORIGEM, FK3.FK3_VLMOE2, FK3.FK3_IDORIG, FK3.FK3_TABORI, "
			cQuery += "FK3.FK3_STATUS, FK3.FK3_CODFKM, FK3.FK3_CLIFOR, FK3.FK3_CGC, FK3.FK3_RAICGC, FK3.R_E_C_N_O_ FK3RECNO "
			cQuery += "FROM " + RetSqlName( "FK3" ) + " FK3 "
			cQuery += "WHERE FK3.FK3_FILORI IN (?) "
			cQuery += "AND FK3.FK3_DATA = ? "
			cQuery += "AND FK3.FK3_IMPOS IN ('PIS','COF','CSL') "
			cQuery += "AND FK3.FK3_TABORI = 'FK7' "
			cQuery += "AND FK3.FK3_IDORIG <> ? "
			If nLenaCliF > 0
				//Verificar determinados fornecedores (raiz do CNPJ)
				cQuery += "AND ( "
				For nKco := 1 to nLenaCliF
					cQuery += "(FK3.FK3_CLIFOR ='" + aCliFor[nKco,1]  + "' AND "
					cQuery += "FK3.FK3_LOJA ='"    + aCliFor[nKco,2]
					
					If nKco < nLenaCliF
						cQuery +=  + "') OR "
					else
						 cQuery +=  + "') "
					Endif

				Next nKco
				cQuery += ") "
			Else  //Apenas o fornecedor Atual
				cQuery += 		"AND FK3.FK3_CLIFOR = ? "		//01
				If lLojaAtu
					cQuery += 	"AND FK3.FK3_LOJA = ?	"		//02
				Endif
			Endif
			cQuery += "AND FK3.FK3_IDRET = ' ' "
			cQuery += "AND FK3.FK3_STATUS = '1' "
			cQuery += "AND FK3.FK3_RECPAG = 'R' "			
			cQuery += "AND FK3.FK3_ORIGEM IN ('FINA590','FINA061','FINA890') "
			cQuery += "AND FK3.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery( cQuery )
			__oPccBdCR := FWPreparedStatement():New(cQuery)
		EndIf
	
		nI := 1
		__oPccBdCR:SetIn(nI, aFil )		//FK3_FILORIG
		nI++
		__oPccBdCR:SetString(nI,DToS( dRef ))	//FK3_DATA
		nI++
		__oPccBdCR:SetString(nI,cChaveFK7)		//CHAVE DO TITULO EM PROCESSAMENTO
		nI++
		If nLenaCliF == 0
			__oPccBdCR:SetString(nI,cCodigo)		//FK3_CLIFOR
			nI ++
			If lLojaAtu
				__oPccBdCR:SetString(nI,cLoja)		//FK3_LOJA (OPCIONAL)
				nI ++
			EndIf
		EndIf

		cQuery := __oPccBdCR:GetFixQuery()
		cAliasQry := mpsysopenquery(cQuery)

		cIdTrbFk3 := ""

		While !( cAliasQry )->( Eof())

			If cIdTrbFk3 != ( cAliasQry )->FK3_IDORIG
				cIdTrbFk3 := ( cAliasQry )->FK3_IDORIG
				lTitCalc  := .F.
			Endif

			If ( cAliasQry )->FK3_IMPOS == __cImpPIS
				nTBCalPis += ( cAliasQry )->FK3_BASIMP		//Base Calculada
				nTCalcPis += ( cAliasQry )->FK3_VALOR		//Valor Calculado
				//Registros pendentes de retenção que terão seu imposto retido na baixa atual
				AADD(aTitCalc,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})

			ElseIf ( cAliasQry )->FK3_IMPOS == __cImpCOF
				nTBCalCof += ( cAliasQry )->FK3_BASIMP		//Base Calculada
				nTCalcCof += ( cAliasQry )->FK3_VALOR		//Valor Calculado

			ElseIf ( cAliasQry )->FK3_IMPOS == __cImpCSL
				nTBCalCsl += ( cAliasQry )->FK3_BASIMP		//Base Calculada
				nTCalcCsl += ( cAliasQry )->FK3_VALOR		//Valor Calculado
			Endif

			(cAliasQry)->(DbSkip())
		EndDo

		If Select(cAliasQry) > 0
			( cAliasQry )->( dbCloseArea() )
		Endif

		//--------------------------------------------------------------
		// Tratamento de retenção na inclusão de RA
		//--------------------------------------------------------------
		If lRaRtImp
			If __oPccRaCR == Nil .Or. nLenaCliF > 0
				cQuery := "SELECT FK3.FK3_VALOR, FK3.FK3_BASIMP, FK3.FK3_IMPOS, FK3.FK3_DATA, FK3.FK3_MOEDA, "
				cQuery += 		" FK3.FK3_CODFKM, FK3.FK3_IDRET, FK3.FK3_FILORI, FK3.R_E_C_N_O_ FK3RECNO, "
				cQuery += 		" FK3.FK3_TABORI, FK3.FK3_IDORIG "			
				cQuery += "FROM " + RetSqlName( "FKA" ) + " FKA "
				cQuery += "INNER JOIN " + RetSqlName( "FK5" ) + " FK5 ON (FKA.FKA_IDORIG = FK5.FK5_IDMOV "
				cQuery += 			"AND FKA.FKA_TABORI = 'FK5'	"
				cQuery += 			"AND FKA.FKA_FILIAL = FK5.FK5_FILIAL) "
				cQuery += "INNER JOIN " + RetSqlName( "FK3" ) + " FK3 ON (FK5.FK5_IDMOV = FK3.FK3_IDORIG "
				cQuery += 			"AND FK5.FK5_FILIAL = FK3.FK3_FILIAL) "
				cQuery += "WHERE FK3.FK3_FILORI IN (?) "
				cQuery += "AND FK3.FK3_DATA = ? "
				cQuery += "AND FK3.FK3_IMPOS IN ('PIS','COF','CSL') "
				cQuery += "AND FK3.FK3_TABORI = 'FK5' "
				If nLenaCliF > 0
					//Verificar determinados fornecedores (raiz do CNPJ)
					cQuery += "AND ( "
					For nKco := 1 to nLenaCliF
						cQuery += "(FK3.FK3_CLIFOR ='" + aCliFor[nKco,1]  + "' AND "
						cQuery += "FK3.FK3_LOJA ='"    + aCliFor[nKco,2]
						
						If nKco < nLenaCliF
							cQuery +=  + "') OR "
						else
							cQuery +=  + "') "
						Endif

					Next nKco
					cQuery += ") "
				Else  //Apenas o fornecedor Atual
					cQuery += 		"AND FK3.FK3_CLIFOR = ? "		//01
					If lLojaAtu
						cQuery += 	"AND FK3.FK3_LOJA = ?	"		//02
					Endif
				EndIf
				cQuery += "AND FKA.D_E_L_E_T_ = ' '	"
				cQuery += "AND FK3.D_E_L_E_T_ = ' ' "
				cQuery += "AND FK3.FK3_STATUS = '1' "
				cQuery += "AND FKA.FKA_IDPROC NOT IN "
				cQuery +=	"( SELECT DISTINCT FKA.FKA_IDPROC "
				cQuery +=		"FROM " + RetSqlName( "FKA" ) + " FKA "
				cQuery +=		"INNER JOIN " + RetSqlName( "FK5" ) + " FK5 ON (FKA.FKA_IDORIG = FK5.FK5_IDMOV "
				cQuery +=				"AND FKA.FKA_TABORI = 'FK5' "
				cQuery +=				"AND FKA.FKA_FILIAL = FK5.FK5_FILIAL) "
				cQuery +=		"INNER JOIN " + RetSqlName( "FK3" ) + " FK3 ON (FK5.FK5_IDMOV = FK3.FK3_IDORIG "
				cQuery +=				"AND FK5.FK5_FILIAL = FK3.FK3_FILIAL) "
				cQuery +=		"WHERE FK3.FK3_FILORI  IN (?) "
				cQuery +=				"AND FK3.FK3_DATA = ? "
				cQuery += 				"AND FK3.FK3_IMPOS IN ('PIS','COF','CSL') "
				cQuery +=				"AND FK3.FK3_TABORI = 'FK5' "
				If nLenaCliF > 0
					//Verificar determinados fornecedores (raiz do CNPJ)
					cQuery += "AND ( "
					For nKco := 1 to nLenaCliF
						cQuery += "(FK3.FK3_CLIFOR ='" + aCliFor[nKco,1]  + "' AND "
						cQuery += "FK3.FK3_LOJA ='"    + aCliFor[nKco,2]
						
						If nKco < nLenaCliF
							cQuery +=  + "') OR "
						else
							cQuery +=  + "') "
						Endif

					Next nKco
					cQuery += ") "
				Else  //Apenas o fornecedor Atual
					cQuery += 		"AND FK3.FK3_CLIFOR = ? "		//01
					If lLojaAtu
						cQuery += 	"AND FK3.FK3_LOJA = ?	"		//02
					Endif
				Endif
				cQuery +=				"AND FKA.D_E_L_E_T_ = ' ' "
				cQuery +=				"AND FK3.D_E_L_E_T_ = ' ' "
				cQuery +=				"AND FK3.FK3_STATUS = '2') "

				cQuery := ChangeQuery( cQuery )
				__oPccRaCR := FWPreparedStatement():New(cQuery)
			EndIf
		
			nI := 1
			__oPccRaCR:SetIn(nI, aFil )		//FK3_FILORIG
			nI++
			__oPccRaCR:SetString(nI,DToS( dRef ))	//FK3_DATA
			nI++
			If nLenaCliF == 0
				__oPccRaCR:SetString(nI,cCodigo)		//FK3_CLIFOR
				nI ++
				If lLojaAtu
					__oPccRaCR:SetString(nI,cLoja)		//FK3_LOJA (OPCIONAL)
					nI ++
				EndIf
			EndIF
			__oPccRaCR:SetIn(nI, aFil )		//FK3_FILORIG
			nI++
			__oPccRaCR:SetString(nI,DToS( dRef ))	//FK3_DATA
			nI++
			If nLenaCliF == 0
				__oPccRaCR:SetString(nI,cCodigo)		//FK3_CLIFOR
				nI ++
				If lLojaAtu
					__oPccRaCR:SetString(nI,cLoja)		//FK3_LOJA (OPCIONAL)
					nI ++
				EndIf
			EndIF
			
			cQuery := __oPccRaCR:GetFixQuery()
			cAliasQry := mpsysopenquery(cQuery)

			cIdTrbFk3 := ""

			While !( cAliasQry )->( Eof())

				If cIdTrbFk3 != ( cAliasQry )->FK3_IDORIG
					cIdTrbFk3 := ( cAliasQry )->FK3_IDORIG
					lTitCalc  := .F.
				Endif

				If ( cAliasQry )->FK3_IMPOS == __cImpPIS
					nTBCalPis += ( cAliasQry )->FK3_BASIMP		//Base Calculada
					nTCalcPis += ( cAliasQry )->FK3_VALOR		//Valor Calculado

					If !lTitCalc .AND. Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
						//Registros pendentes de retenção que terão seu imposto retido na baixa atual
						AADD(aTitCalc,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
						lTitCalc := .T.
					Else
						nTBRetPis += ( cAliasQry )->FK3_BASIMP
						nTotRtPis += ( cAliasQry )->FK3_VALOR
					Endif

				ElseIf ( cAliasQry )->FK3_IMPOS == __cImpCOF
					nTBCalCof += ( cAliasQry )->FK3_BASIMP		//Base Calculada
					nTCalcCof += ( cAliasQry )->FK3_VALOR		//Valor Calculado

					If !lTitCalc .AND. Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
						//Registros pendentes de retenção que terão seu imposto retido na baixa atual
						AADD(aTitCalc,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
						lTitCalc := .T.
					ElseIf !Empty( ( cAliasQry )->FK3_IDRET )		//Se houve retenção
						nTBRetCof += ( cAliasQry )->FK4_BASIMP
						nTotRtCof += ( cAliasQry )->FK4_VALOR
					Endif

				ElseIf ( cAliasQry )->FK3_IMPOS == __cImpCSL
					nTBCalCsl += ( cAliasQry )->FK3_BASIMP		//Base Calculada
					nTCalcCsl += ( cAliasQry )->FK3_VALOR		//Valor Calculado

					If !lTitCalc .AND. Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
						//Registros pendentes de retenção que terão seu imposto retido na baixa atual
						AADD(aTitCalc,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
						lTitCalc := .T.
					ElseIf !Empty( ( cAliasQry )->FK3_IDRET )		//Se houve retenção
						nTBRetCsl += ( cAliasQry )->FK4_BASIMP
						nTotRtCsl += ( cAliasQry )->FK4_VALOR
					Endif

				Endif

				(cAliasQry)->(DbSkip())
			EndDo

			If Select(cAliasQry) > 0
				( cAliasQry )->( dbCloseArea() )
			Endif
		Endif
	Else
		//--------------------------------------------------------------
		//Tratamento para PCC na Baixa - Contas a Pagar
		//--------------------------------------------------------------	
		If __oPccBxCP == Nil  .Or. nLenaCliF > 0
			cQuery := "SELECT FK2.FK2_FILIAL, FK2.FK2_IDFK2 , FK2.FK2_SEQ, FK2.FK2_IDDOC, " 
			cQuery += 		" FK3.FK3_VALOR , FK3.FK3_BASIMP, FK3.FK3_IMPOS, FK3.FK3_DATA, FK3.FK3_MOEDA, "
			cQuery += 		" FK3.FK3_CODFKM, FK3.FK3_IDRET , FK3.FK3_FILORI, FK3.R_E_C_N_O_ FK3RECNO, "
			cQuery += 		" FK3.FK3_TABORI, FK3.FK3_IDORIG, FK3.FK3_RECPAG, "
			cQuery += 		" FK4.FK4_VALOR , FK4.FK4_BASIMP, FK4.FK4_IMPOS, FK4.FK4_DATA, FK4.FK4_MOEDA, "
			cQuery += 		" FK4.FK4_CODFKM, FK4.FK4_IDFK4 , FK4.FK4_FILORI, FK4.R_E_C_N_O_ FK4RECNO, "
			cQuery += 		" FK4.FK4_RECPAG, FK4.FK4_IDORIG "
			cQuery += "FROM " + RetSqlName( "FK2" ) + " FK2 "

			cQuery += "INNER JOIN " + RetSqlName("FK3") + " FK3 "
			cQuery += 		"ON FK3.FK3_FILIAL = FK2.FK2_FILIAL "
			cQuery += 		"AND FK3.FK3_IDORIG = FK2.FK2_IDFK2 "
			cQuery += 		"AND FK3_IMPOS IN ('PIS','COF','CSL') "
			cQuery += 		"AND FK3.FK3_TABORI = 'FK2' "

			If nLenaCliF > 0
				//Verificar determinados fornecedores (raiz do CNPJ)
				cQuery += "AND ( "
				For nKco := 1 to nLenaCliF
					cQuery += "(FK3.FK3_CLIFOR ='" + aCliFor[nKco,1]  + "' AND "
					cQuery += "FK3.FK3_LOJA ='"    + aCliFor[nKco,2]
					
					If nKco < nLenaCliF
						cQuery +=  + "') OR "
					else
						 cQuery +=  + "') "
					Endif

				Next nKco
				cQuery += ") "
			Else  //Apenas o fornecedor Atual
				cQuery += 		"AND FK3.FK3_CLIFOR = ? "		//01
				If lLojaAtu
					cQuery += 	"AND FK3.FK3_LOJA = ?	"		//02
				Endif
			EndIf

			cQuery += 		"AND FK3.FK3_RECPAG = 'P' "
			cQuery += 		"AND FK3_STATUS = '1' "
			cQuery += 		"AND FK3.D_E_L_E_T_ = ' ' "

			cQuery += " LEFT JOIN " + RetSqlName("FK4") + " FK4 "
			cQuery += 		"ON FK4.FK4_FILIAL = FK3.FK3_FILIAL "
			cQuery += 		"AND FK4.FK4_IDORIG = FK3.FK3_IDORIG "
			cQuery += 		"AND FK4.FK4_IMPOS = FK3.FK3_IMPOS "
			If nLenaCliF > 0
				//Verificar determinados fornecedores (raiz do CNPJ)
				cQuery += "AND ( "
				For nKco := 1 to nLenaCliF
					cQuery += "(FK4.FK4_CLIFOR ='" + aCliFor[nKco,1]  + "' AND "
					cQuery += "FK4.FK4_LOJA ='"    + aCliFor[nKco,2]
					
					If nKco < nLenaCliF
						cQuery +=  + "') OR "
					else
						 cQuery +=  + "') "
					Endif

				Next nKco
				cQuery += ") "
			Else  //Apenas o fornecedor Atual
				cQuery += 		"AND FK4.FK4_CLIFOR = ? "		//01
				If lLojaAtu
					cQuery += 	"AND FK4.FK4_LOJA = ?	"		//02
				Endif
			EndIf
			cQuery += 		"AND FK4.FK4_RECPAG = 'P' "
			cQuery += 		"AND FK4.FK4_STATUS = '1' "
			cQuery += 		"AND FK4.D_E_L_E_T_ = ' ' "

			cQuery += "WHERE FK2.FK2_FILORI IN (?) "	//05
			cQuery += 		"AND FK2_RECPAG = 'P' "
			cQuery += 		"AND FK2_DATA = ? "			//06
			cQuery += 		"AND FK2.D_E_L_E_T_ = ' ' "
			cQuery += 		"AND NOT EXISTS( "
			cQuery += 			"SELECT FK2EST.FK2_IDDOC FROM " + RetSqlName("FK2") +" FK2EST "
			cQuery += 			"WHERE FK2EST.FK2_FILORI = FK2.FK2_FILORI "
			cQuery +=		 		"AND FK2EST.FK2_IDDOC = FK2.FK2_IDDOC "
			cQuery +=		 		"AND FK2EST.FK2_SEQ = FK2.FK2_SEQ "
			cQuery += 				"AND FK2EST.FK2_TPDOC = 'ES' "
			cQuery += 				"AND FK2EST.D_E_L_E_T_ = ' ') "

			cQuery := ChangeQuery( cQuery )
			__oPccBxCP := FWPreparedStatement():New(cQuery)

		Endif		
		nI := 1
		If nLenaCliF == 0
			__oPccBxCP:SetString(nI,cCodigo)		//FK3_CLIFOR
			nI ++
			If lLojaAtu
				__oPccBxCP:SetString(nI,cLoja)		//FK3_LOJA (OPCIONAL)
				nI ++
			EndIf
			__oPccBxCP:SetString(nI,cCodigo)		//FK3_CLIFOR
			nI ++
			If lLojaAtu
				__oPccBxCP:SetString(nI,cLoja)		//FK3_LOJA (OPCIONAL)
				nI ++
			Endif
		Endif
		__oPccBxCP:SetIn(nI, aFil )		//FK3_FILORIG
		nI++
		__oPccBxCP:SetString(nI,DToS( dRef ))	//FK3_DATA

		cQuery := __oPccBxCP:GetFixQuery()

		cAliasQry := mpsysopenquery(cQuery)

		cIdTrbFk3 := ""

		While !( cAliasQry )->( Eof())

			If cIdTrbFk3 != ( cAliasQry )->FK3_IDORIG
				cIdTrbFk3 := ( cAliasQry )->FK3_IDORIG
				lTitCalc  := .F.
			Endif

			If ( cAliasQry )->FK3_IMPOS == __cImpPIS
				nTBCalPis += ( cAliasQry )->FK3_BASIMP		//Base Calculada
				nTCalcPis += ( cAliasQry )->FK3_VALOR		//Valor Calculado

				If !lTitCalc .and. Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
					//Registros pendentes de retenção que terão seu imposto retido na baixa atual
					AADD(aTitCalc,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
					lTitCalc := .T.
				Else
					nTBRetPis += ( cAliasQry )->FK4_BASIMP
					nTotRtPis += ( cAliasQry )->FK4_VALOR
				Endif

			ElseIf ( cAliasQry )->FK3_IMPOS == __cImpCOF
				nTBCalCof += ( cAliasQry )->FK3_BASIMP		//Base Calculada
				nTCalcCof += ( cAliasQry )->FK3_VALOR		//Valor Calculado

				If !lTitCalc .AND. Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
					//Registros pendentes de retenção que terão seu imposto retido na baixa atual
					AADD(aTitCalc,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
					lTitCalc := .T.
				ElseIf !Empty( ( cAliasQry )->FK3_IDRET )		//Se houve retenção
					nTBRetCof += ( cAliasQry )->FK4_BASIMP
					nTotRtCof += ( cAliasQry )->FK4_VALOR
				Endif

			ElseIf ( cAliasQry )->FK3_IMPOS == __cImpCSL
				nTBCalCsl += ( cAliasQry )->FK3_BASIMP		//Base Calculada
				nTCalcCsl += ( cAliasQry )->FK3_VALOR		//Valor Calculado

				If !lTitCalc .AND. Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
					//Registros pendentes de retenção que terão seu imposto retido na baixa atual
					AADD(aTitCalc,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
					lTitCalc := .T.
				ElseIf !Empty( ( cAliasQry )->FK3_IDRET )		//Se houve retenção
					nTBRetCsl += ( cAliasQry )->FK4_BASIMP
					nTotRtCsl += ( cAliasQry )->FK4_VALOR
				Endif

			Endif

			(cAliasQry)->(DbSkip())
		EndDo

		If Select(cAliasQry) > 0
			( cAliasQry )->( dbCloseArea() )
		Endif

		//--------------------------------------------------------------
		// Tratamento de retenção de PCC via borderô de impostos.
		//--------------------------------------------------------------
		cChaveTit := xFilial("SE2", SE2->E2_FILORIG) + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
		cChaveFK7 := FINGRVFK7("SE2", cChaveTit)

		If __oPccBdCP == Nil .Or. nLenaCliF > 0

			cQuery := "SELECT FK3.FK3_FILIAL, FK3.FK3_IDFK3, FK3.FK3_DATA, FK3.FK3_VALOR, FK3.FK3_MOEDA, FK3.FK3_NATURE, FK3.FK3_RECPAG, FK3.FK3_IDRET, "
			cQuery += "FK3.FK3_IMPOS, FK3.FK3_FILORI, FK3.FK3_BASIMP, FK3.FK3_ORIGEM, FK3.FK3_VLMOE2, FK3.FK3_IDORIG, FK3.FK3_TABORI, "
			cQuery += "FK3.FK3_STATUS, FK3.FK3_CODFKM, FK3.FK3_CLIFOR, FK3.FK3_CGC, FK3.FK3_RAICGC, FK3.R_E_C_N_O_ FK3RECNO "
			cQuery += "FROM " + RetSqlName( "FK3" ) + " FK3 "
			cQuery += "WHERE FK3.FK3_FILORI IN (?) "
			cQuery += "AND FK3.FK3_DATA = ? "
			cQuery += "AND FK3.FK3_IMPOS IN ('PIS','COF','CSL') "
			cQuery += "AND FK3.FK3_TABORI = 'FK7' "
			cQuery += "AND FK3.FK3_IDORIG <> ? "
			If nLenaCliF > 0
				//Verificar determinados fornecedores (raiz do CNPJ)
				cQuery += "AND ( "
				For nKco := 1 to nLenaCliF
					cQuery += "(FK3.FK3_CLIFOR ='" + aCliFor[nKco,1]  + "' AND "
					cQuery += "FK3.FK3_LOJA ='"    + aCliFor[nKco,2]
					
					If nKco < nLenaCliF
						cQuery +=  + "') OR "
					else
						 cQuery +=  + "') "
					Endif

				Next nKco
				cQuery += ") "
			Else  //Apenas o fornecedor Atual
				cQuery += 		"AND FK3.FK3_CLIFOR = ? "		//01
				If lLojaAtu
					cQuery += 	"AND FK3.FK3_LOJA = ?	"		//02
				Endif
			EndIf
			cQuery += "AND FK3.FK3_IDRET = ' ' "
			cQuery += "AND FK3.FK3_STATUS = '1' "
			cQuery += "AND FK3.FK3_RECPAG = 'P' "			
			cQuery += "AND FK3.FK3_ORIGEM IN ('FINA590','FINA241') "
			cQuery += "AND FK3.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery( cQuery )
			__oPccBdCP := FWPreparedStatement():New(cQuery)
		EndIf
	
		nI := 1
		__oPccBdCP:SetIn(nI, aFil )		//FK3_FILORIG
		nI++
		__oPccBdCP:SetString(nI,DToS( dRef ))	//FK3_DATA
		nI++
		__oPccBdCP:SetString(nI,cChaveFK7)		//CHAVE DO TITULO EM PROCESSAMENTO
		nI++
		If nLenaCliF == 0
			__oPccBdCP:SetString(nI,cCodigo)		//FK3_CLIFOR
			nI ++
			If lLojaAtu
				__oPccBdCP:SetString(nI,cLoja)		//FK3_LOJA (OPCIONAL)
			EndIf
		Endif

		cQuery := __oPccBdCP:GetFixQuery()
		cAliasQry := mpsysopenquery(cQuery)

		cIdTrbFk3 := ""

		While !( cAliasQry )->( Eof())

			If cIdTrbFk3 != ( cAliasQry )->FK3_IDORIG
				cIdTrbFk3 := ( cAliasQry )->FK3_IDORIG
				lTitCalc  := .F.
			Endif

			If ( cAliasQry )->FK3_IMPOS == __cImpPIS
				nTBCalPis += ( cAliasQry )->FK3_BASIMP		//Base Calculada
				nTCalcPis += ( cAliasQry )->FK3_VALOR		//Valor Calculado

				If !lTitCalc .and. Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
					//Registros pendentes de retenção que terão seu imposto retido na baixa atual
					AADD(aTitCalc,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
				Endif

			ElseIf ( cAliasQry )->FK3_IMPOS == __cImpCOF
				nTBCalCof += ( cAliasQry )->FK3_BASIMP		//Base Calculada
				nTCalcCof += ( cAliasQry )->FK3_VALOR		//Valor Calculado

				If !lTitCalc .and. Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
					//Registros pendentes de retenção que terão seu imposto retido na baixa atual
					AADD(aTitCalc,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
				Endif

			ElseIf ( cAliasQry )->FK3_IMPOS == __cImpCSL
				nTBCalCsl += ( cAliasQry )->FK3_BASIMP		//Base Calculada
				nTCalcCsl += ( cAliasQry )->FK3_VALOR		//Valor Calculado

				If !lTitCalc .and. Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
					//Registros pendentes de retenção que terão seu imposto retido na baixa atual
					AADD(aTitCalc,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
				Endif

			Endif

			(cAliasQry)->(DbSkip())
		EndDo

		If Select(cAliasQry) > 0
			( cAliasQry )->( dbCloseArea() )
		Endif

		//--------------------------------------------------------------
		// Tratamento de retenção na inclusão de PA - Gravaçao Antiga
		//--------------------------------------------------------------
		If __oPccPaCP == Nil .Or. nLenaCliF > 0
			cQuery := "SELECT FK3.FK3_VALOR, FK3.FK3_BASIMP, FK3.FK3_IMPOS, FK3.FK3_DATA, FK3.FK3_MOEDA, "
			cQuery += 		" FK3.FK3_CODFKM, FK3.FK3_IDRET, FK3.FK3_FILORI, FK3.R_E_C_N_O_ FK3RECNO, "
			cQuery += 		" FK3.FK3_TABORI, FK3.FK3_IDORIG "			
			cQuery += "FROM " + RetSqlName( "FKA" ) + " FKA "
			cQuery += "INNER JOIN " + RetSqlName( "FK5" ) + " FK5 ON (FKA.FKA_IDORIG = FK5.FK5_IDMOV "
			cQuery += 			"AND FKA.FKA_TABORI = 'FK5'	"
			cQuery += 			"AND FKA.FKA_FILIAL = FK5.FK5_FILIAL) "
			cQuery += "INNER JOIN " + RetSqlName( "FK3" ) + " FK3 ON (FK5.FK5_IDMOV = FK3.FK3_IDORIG "
			cQuery += 			"AND FK5.FK5_FILIAL = FK3.FK3_FILIAL) "
			cQuery += "WHERE FK3.FK3_FILORI IN (?) "
			cQuery += "AND FK3.FK3_DATA = ? "
			cQuery += "AND FK3.FK3_IMPOS IN ('PIS','COF','CSL') "
			cQuery += "AND FK3.FK3_TABORI = 'FK5' "

			If nLenaCliF > 0
				//Verificar determinados fornecedores (raiz do CNPJ)
				cQuery += "AND ( "
				For nKco := 1 to nLenaCliF
					cQuery += "(FK3.FK3_CLIFOR ='" + aCliFor[nKco,1]  + "' AND "
					cQuery += "FK3.FK3_LOJA ='"    + aCliFor[nKco,2]
					
					If nKco < nLenaCliF
						cQuery +=  + "') OR "
					else
						 cQuery +=  + "') "
					Endif

				Next nKco
				cQuery += ") "
			Else  //Apenas o fornecedor Atual
				cQuery += 		"AND FK3.FK3_CLIFOR = ? "		//01
				If lLojaAtu
					cQuery += 	"AND FK3.FK3_LOJA = ?	"		//02
				Endif
			EndIf

			cQuery += "AND FKA.D_E_L_E_T_ = ' '	"
			cQuery += "AND FK3.D_E_L_E_T_ = ' ' "
			cQuery += "AND FK3.FK3_STATUS = '1' "
			cQuery += "AND FKA.FKA_IDPROC NOT IN "
			cQuery +=	"( SELECT DISTINCT FKA.FKA_IDPROC "
			cQuery +=		"FROM " + RetSqlName( "FKA" ) + " FKA "
			cQuery +=		"INNER JOIN " + RetSqlName( "FK5" ) + " FK5 ON (FKA.FKA_IDORIG = FK5.FK5_IDMOV "
			cQuery +=				"AND FKA.FKA_TABORI = 'FK5' "
			cQuery +=				"AND FKA.FKA_FILIAL = FK5.FK5_FILIAL) "
			cQuery +=		"INNER JOIN " + RetSqlName( "FK3" ) + " FK3 ON (FK5.FK5_IDMOV = FK3.FK3_IDORIG "
			cQuery +=				"AND FK5.FK5_FILIAL = FK3.FK3_FILIAL) "
			cQuery +=		"WHERE FK3.FK3_FILORI  IN (?) "
			cQuery +=				"AND FK3.FK3_DATA = ? "
			cQuery += 				"AND FK3.FK3_IMPOS IN ('PIS','COF','CSL') "
			cQuery +=				"AND FK3.FK3_TABORI = 'FK5' "
			If nLenaCliF > 0
				//Verificar determinados fornecedores (raiz do CNPJ)
				cQuery += "AND ( "
				For nKco := 1 to nLenaCliF
					cQuery += "(FK3.FK3_CLIFOR ='" + aCliFor[nKco,1]  + "' AND "
					cQuery += "FK3.FK3_LOJA ='"    + aCliFor[nKco,2]
					
					If nKco < nLenaCliF
						cQuery +=  + "') OR "
					else
						 cQuery +=  + "') "
					Endif

				Next nKco
				cQuery += ") "
			Else  //Apenas o fornecedor Atual
				cQuery += 		"AND FK3.FK3_CLIFOR = ? "		//01
				If lLojaAtu
					cQuery += 	"AND FK3.FK3_LOJA = ?	"		//02
				Endif
			EndIf
			cQuery +=				"AND FKA.D_E_L_E_T_ = ' ' "
			cQuery +=				"AND FK3.D_E_L_E_T_ = ' ' "
			cQuery +=				"AND FK3.FK3_STATUS = '2') "

			cQuery := ChangeQuery( cQuery )
			__oPccPaCP := FWPreparedStatement():New(cQuery)
		EndIf

		nI := 1
		__oPccPaCP:SetIn(nI, aFil )		//FK3_FILORIG
		nI++
		__oPccPaCP:SetString(nI,DToS( dRef ))	//FK3_DATA
		nI++

		If nLenaCliF == 0
			__oPccPaCP:SetString(nI,cCodigo)		//FK3_CLIFOR
			nI ++
			If lLojaAtu
				__oPccPaCP:SetString(nI,cLoja)		//FK3_LOJA (OPCIONAL)
				nI ++
			EndIF
		Endif

		__oPccPaCP:SetIn(nI, aFil )		//FK3_FILORIG
		nI++
		__oPccPaCP:SetString(nI,DToS( dRef ))	//FK3_DATA
		nI++

		If nLenaCliF == 0
			__oPccPaCP:SetString(nI,cCodigo)		//FK3_CLIFOR
			nI ++
			If lLojaAtu
				__oPccPaCP:SetString(nI,cLoja)		//FK3_LOJA (OPCIONAL)
				nI ++
			EndIF
		Endif
		
		cQuery := __oPccPaCP:GetFixQuery()
		cAliasQry := mpsysopenquery(cQuery)

		cIdTrbFk3 := ""

		While !( cAliasQry )->( Eof())

			If cIdTrbFk3 != ( cAliasQry )->FK3_IDORIG
				cIdTrbFk3 := ( cAliasQry )->FK3_IDORIG
				lTitCalc  := .F.
			Endif

			If ( cAliasQry )->FK3_IMPOS == __cImpPIS
				nTBCalPis += ( cAliasQry )->FK3_BASIMP		//Base Calculada
				nTCalcPis += ( cAliasQry )->FK3_VALOR		//Valor Calculado

				If !lTitCalc .AND. Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
					//Registros pendentes de retenção que terão seu imposto retido na baixa atual
					AADD(aTitCalc,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
					lTitCalc := .T.
				Else
					nTBRetPis += ( cAliasQry )->FK3_BASIMP
					nTotRtPis += ( cAliasQry )->FK3_VALOR
				Endif

			ElseIf ( cAliasQry )->FK3_IMPOS == __cImpCOF
				nTBCalCof += ( cAliasQry )->FK3_BASIMP		//Base Calculada
				nTCalcCof += ( cAliasQry )->FK3_VALOR		//Valor Calculado

				If !lTitCalc .AND. Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
					//Registros pendentes de retenção que terão seu imposto retido na baixa atual
					AADD(aTitCalc,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
					lTitCalc := .T.
				ElseIf !Empty( ( cAliasQry )->FK3_IDRET )		//Se houve retenção
					nTBRetCof += ( cAliasQry )->FK4_BASIMP
					nTotRtCof += ( cAliasQry )->FK4_VALOR
				Endif

			ElseIf ( cAliasQry )->FK3_IMPOS == __cImpCSL
				nTBCalCsl += ( cAliasQry )->FK3_BASIMP		//Base Calculada
				nTCalcCsl += ( cAliasQry )->FK3_VALOR		//Valor Calculado

				If !lTitCalc .AND. Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
					//Registros pendentes de retenção que terão seu imposto retido na baixa atual
					AADD(aTitCalc,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
					lTitCalc := .T.
				ElseIf !Empty( ( cAliasQry )->FK3_IDRET )		//Se houve retenção
					nTBRetCsl += ( cAliasQry )->FK4_BASIMP
					nTotRtCsl += ( cAliasQry )->FK4_VALOR
				Endif

			Endif

			(cAliasQry)->(DbSkip())
		EndDo

		If Select(cAliasQry) > 0
			( cAliasQry )->( dbCloseArea() )
		Endif

		//--------------------------------------------------------------
		// Tratamento de retenção na inclusão de PA - Gravaçao Nova
		//--------------------------------------------------------------
		If __oPccNewPa == Nil .Or. nLenaCliF > 0
			cQuery := "SELECT FK3.FK3_VALOR, FK3.FK3_BASIMP, FK3.FK3_IMPOS, FK3.FK3_DATA, FK3.FK3_MOEDA, "
			cQuery += 		" FK3.FK3_CODFKM, FK3.FK3_IDRET, FK3.FK3_FILORI, FK3.R_E_C_N_O_ FK3RECNO, "
			cQuery += 		" FK3.FK3_TABORI, FK3.FK3_IDORIG "			
			cQuery += "FROM " + RetSqlName( "FK7" ) + " FK7 "
			cQuery += "INNER JOIN " + RetSqlName( "FK3" ) + " FK3 ON (FK7.FK7_IDDOC = FK3.FK3_IDORIG "
			cQuery += 			"AND FK7.FK7_FILIAL = FK3.FK3_FILIAL) "
			cQuery += "WHERE FK3.FK3_FILORI IN (?) "
			cQuery += "AND FK3.FK3_DATA = ? "
			cQuery += "AND FK3.FK3_IMPOS IN ('PIS','COF','CSL') "
			cQuery += "AND FK3.FK3_TABORI = 'SE2' "

			If nLenaCliF > 0
				//Verificar determinados fornecedores (raiz do CNPJ)
				cQuery += "AND ( "
				For nKco := 1 to nLenaCliF
					cQuery += "(FK3.FK3_CLIFOR ='" + aCliFor[nKco,1]  + "' AND "
					cQuery += "FK3.FK3_LOJA ='"    + aCliFor[nKco,2]
					
					If nKco < nLenaCliF
						cQuery +=  + "') OR "
					else
						 cQuery +=  + "') "
					Endif

				Next nKco
				cQuery += ") "
			Else  //Apenas o fornecedor Atual
				cQuery += 		"AND FK3.FK3_CLIFOR = ? "		//01
				If lLojaAtu
					cQuery += 	"AND FK3.FK3_LOJA = ?	"		//02
				Endif
			EndIf

			cQuery += "AND FK3.D_E_L_E_T_ = ' ' "
			cQuery += "AND FK3.FK3_STATUS = '1' "
			cQuery += "AND FK7.FK7_IDDOC NOT IN "
			cQuery +=	"( SELECT DISTINCT FK7.FK7_IDDOC "
			cQuery +=		"FROM " + RetSqlName( "FK7" ) + " FK7 "
			cQuery +=		"INNER JOIN " + RetSqlName( "FK3" ) + " FK3 ON (FK7.FK7_IDDOC = FK3.FK3_IDORIG "
			cQuery +=				"AND FK7.FK7_FILIAL = FK3.FK3_FILIAL) "
			cQuery +=		"WHERE FK3.FK3_FILORI  IN (?) "
			cQuery +=				"AND FK3.FK3_DATA = ? "
			cQuery += 				"AND FK3.FK3_IMPOS IN ('PIS','COF','CSL') "
			cQuery +=				"AND FK3.FK3_TABORI = 'SE2' "
			If nLenaCliF > 0
				//Verificar determinados fornecedores (raiz do CNPJ)
				cQuery += "AND ( "
				For nKco := 1 to nLenaCliF
					cQuery += "(FK3.FK3_CLIFOR ='" + aCliFor[nKco,1]  + "' AND "
					cQuery += "FK3.FK3_LOJA ='"    + aCliFor[nKco,2]
					
					If nKco < nLenaCliF
						cQuery +=  + "') OR "
					else
						 cQuery +=  + "') "
					Endif

				Next nKco
				cQuery += ") "
			Else  //Apenas o fornecedor Atual
				cQuery += 		"AND FK3.FK3_CLIFOR = ? "		//01
				If lLojaAtu
					cQuery += 	"AND FK3.FK3_LOJA = ?	"		//02
				Endif
			EndIf
			cQuery += "AND FK3.D_E_L_E_T_ = ' ' "
			cQuery += "AND FK3.FK3_STATUS = '2') "

			cQuery := ChangeQuery( cQuery )
			__oPccNewPa := FWPreparedStatement():New(cQuery)
		EndIf

		nI := 1
		__oPccNewPa:SetIn(nI, aFil )		//FK3_FILORIG
		nI++
		__oPccNewPa:SetString(nI,DToS( dRef ))	//FK3_DATA
		nI++

		If nLenaCliF == 0
			__oPccNewPa:SetString(nI,cCodigo)		//FK3_CLIFOR
			nI ++
			If lLojaAtu
				__oPccNewPa:SetString(nI,cLoja)		//FK3_LOJA (OPCIONAL)
				nI ++
			EndIF
		Endif

		__oPccNewPa:SetIn(nI, aFil )		//FK3_FILORIG
		nI++
		__oPccNewPa:SetString(nI,DToS( dRef ))	//FK3_DATA
		nI++

		If nLenaCliF == 0
			__oPccNewPa:SetString(nI,cCodigo)		//FK3_CLIFOR
			nI ++
			If lLojaAtu
				__oPccNewPa:SetString(nI,cLoja)		//FK3_LOJA (OPCIONAL)
				nI ++
			EndIF
		Endif
		
		cQuery := __oPccNewPa:GetFixQuery()
		cAliasQry := mpsysopenquery(cQuery)

		cIdTrbFk3 := ""

		While !( cAliasQry )->( Eof())

			If cIdTrbFk3 != ( cAliasQry )->FK3_IDORIG
				cIdTrbFk3 := ( cAliasQry )->FK3_IDORIG
				lTitCalc  := .F.
			Endif

			If ( cAliasQry )->FK3_IMPOS == __cImpPIS
				nTBCalPis += ( cAliasQry )->FK3_BASIMP		//Base Calculada
				nTCalcPis += ( cAliasQry )->FK3_VALOR		//Valor Calculado

				If !lTitCalc .AND. Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
					//Registros pendentes de retenção que terão seu imposto retido na baixa atual
					AADD(aTitCalc,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
					lTitCalc := .T.
				Else
					nTBRetPis += ( cAliasQry )->FK3_BASIMP
					nTotRtPis += ( cAliasQry )->FK3_VALOR
				Endif

			ElseIf ( cAliasQry )->FK3_IMPOS == __cImpCOF
				nTBCalCof += ( cAliasQry )->FK3_BASIMP		//Base Calculada
				nTCalcCof += ( cAliasQry )->FK3_VALOR		//Valor Calculado

				If !lTitCalc .AND. Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
					//Registros pendentes de retenção que terão seu imposto retido na baixa atual
					AADD(aTitCalc,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
					lTitCalc := .T.
				ElseIf !Empty( ( cAliasQry )->FK3_IDRET )		//Se houve retenção
					nTBRetCof += ( cAliasQry )->FK4_BASIMP
					nTotRtCof += ( cAliasQry )->FK4_VALOR
				Endif

			ElseIf ( cAliasQry )->FK3_IMPOS == __cImpCSL
				nTBCalCsl += ( cAliasQry )->FK3_BASIMP		//Base Calculada
				nTCalcCsl += ( cAliasQry )->FK3_VALOR		//Valor Calculado

				If !lTitCalc .AND. Empty( ( cAliasQry )->FK3_IDRET )		//Se não houve retenção
					//Registros pendentes de retenção que terão seu imposto retido na baixa atual
					AADD(aTitCalc,{(cAliasQry)->FK3_TABORI, (cAliasQry)->FK3_IDORIG})
					lTitCalc := .T.
				ElseIf !Empty( ( cAliasQry )->FK3_IDRET )		//Se houve retenção
					nTBRetCsl += ( cAliasQry )->FK4_BASIMP
					nTotRtCsl += ( cAliasQry )->FK4_VALOR
				Endif

			Endif

			(cAliasQry)->(DbSkip())
		EndDo

		If Select(cAliasQry) > 0
			( cAliasQry )->( dbCloseArea() )
		Endif
	Endif

	nPisBaseR += Round(nTBCalPis - nTBRetPis,2)
	nPisAux := nTCalcPis - nTotRtPis
	nPis := Iif( lRoundPis, Round(nPisAux,2), NoRound(nPisAux,2) )

	nCofBaseR += Round(nTBCalCof - nTBRetCof,2)
	nCofAux := nTCalcCof - nTotRtCof
	nCof := Iif( lRoundCof, Round(nCofAux,2), NoRound(nCofAux,2) )

	nCslBaseR += Round(nTBCalCsl - nTBRetCsl,2)
	nCslAux := nTCalcCsl - nTotRtCsl
	nCsl := Iif( lRoundCof, Round(nCslAux,2), NoRound(nCslAux,2) )

	aDados[1] := nPis
	aDados[2] := nCof
	aDados[3] := nCsl

	/* Verifica Valor Minimo? 
		ALTERACAO - Não vejo o mínimo caso já tenha valores retidos anteriormente.
		BAIXA - não conseguiu reter tudo na baixa anterior.
	*/
	If ( !lAltEmi .Or. !lPenTxR ) .And. (nTotRtPis > 0 .and. nTotRtCof > 0 .and. nTotRtCsl > 0)
		aDados[4] := .F.
	Else
		aDados[4] := .T.
	EndIf

	//Armazena os valores já retidos (tratamento cumulatividade PCC Individual)
	aDados[5] := nTotRtPis
	aDados[6] := nTotRtCof
	aDados[7] := nTotRtCsl

	RestArea(aAreaAt)

Return aDados


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FVerRpoR33

Verificar uso da release 12.1.33 e posteriores

@param lF241QRY3, logical, ponto de entrada F241QRY3 existe
@param lFINCMP1 , logical, ponto de entrada lFINCMP1 existe
@param lF241QRY2, logical, ponto de entrada lF241QRY2 existe
@param lF241CMP2, logical, ponto de entrada F241QRY3 existe
@param lFinxOrd , logical, ponto de entrada lFinxOrd existe

@return lRet - Informa se uso da release 12.1.33 e posteriores permite o uso da SumDayFK

@Author	Mauricio Pequim Jr
@since	23/08/2021
/*/
//-----------------------------------------------------------------------------------------------------
Static Function FVerRpoR33(lF241QRY3 AS Logical, lFINCMP1 AS Logical, lF241QRY2 AS Logical, lF241CMP2 AS Logical, lFinxOrd AS Logical)  AS Logical

Local lRet 		As Logical
Local cRpoRel	As Character 

lRet 	:= .F.
cRpoRel := GetRpoRelease()

If cRpoRel >= "12.1.033"
	If ( cRpoRel == "12.1.033" .and. !lF241QRY3 .and. !lFINCMP1 .and. !lF241QRY2 .and. !lF241CMP2 .and. !lFinxOrd ) .or. (cRpoRel > "12.1.033")
		lRet := .T.
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}SumBxIRPJ
Verificar total de IRPJ gerado em baixas parciais anteriores

@param cChave - Chave do titulo

@return nValBx - Valor ja retido de IR para o titulo

@author Fabio Zanchim
@since  01/12/2021
/*/
//-------------------------------------------------------------------
Function SumBxIRPJ(cChave As Character,cCodRet As Character) As Numeric

Local nValBx	As Numeric
Local aArea		As Array
Local cAliasQry	As Character
Local cQuery	As Character
Local cNatIRF	As Character

nValBx		:= 0
aArea		:= GetArea() 
cAliasQry	:= GetNextAlias()
cQuery		:= ""
cNatIRF		:= SuperGetMV("MV_IRF")

cNatIRF := IIF('"' $ cNatIRF, &cNatIRF, cNatIRF)

cQuery := " SELECT SUM(E1_VALOR) VALOR "
cQuery += " From "+RetSQLName("SE1")+" SE1 "
cQuery += " Where E1_FILIAL='"+xFilial('SE1')+"'"
cQuery += " And E1_TIPO = 'IRF'"
cQuery += " And E1_NATUREZ = '"+cNatIRF+"' "
cQuery += " And E1_TITPAI LIKE '%"+cChave+"%' " 
cQuery += " And E1_CODRET = '"+cCodRet+"'"
cQuery += " And SE1.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery( cQuery )

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

DbSelectArea(cAliasQry)
DbGoTop()
If !Eof()
	TCSetField(cAliasQry, "VALOR" ,"N",16,2)
	nValBx := (cAliasQry)->(VALOR)
EndIF
(cAliasQry)->(dbCloseArea())

RestArea(aArea)

Return(nValBx)

//-------------------------------------------------------------------
/*/{Protheus.doc}SetUpQry
Auxiliar na construção de cláusulas de Consultas SQL

@param cKey - Identificador do trecho da query - Character
@return cRet - Character

@author Norberto M de Melo
@since  17/08/2022
/*/
//-------------------------------------------------------------------
STATIC FUNCTION SetUpQry(cKey AS CHARACTER) AS CHARACTER
    LOCAL cRet AS CHARACTER
    LOCAL cSubstSQL AS CHARACTER
    DEFAULT cKey := "E2_FILIAL"

    IF cBDname $ "ORACLE|DB2|POSTGRES|INFORMIX" 
        cSubstSQL := " SUBSTR"
    ELSE
        cSubstSQL := " SUBSTRING"
    ENDIF

    IF cKey == "E2_FILIAL"
        IF LEN(TRIM(FWFILIAL("SE2"))) <> LEN(TRIM(FWFILIAL("SE5")))
            cRet := cSubstSQL+"(SE2.E2_FILIAL,01," + STRZERO(AT("F",ALLTRIM(FWSM0Layout(cEmpAnt)))-1,2) + ")"
            IF LEN(TRIM(FWFILIAL("SE2"))) < LEN(TRIM(FWFILIAL("SE5")))
                cRet := "SE2.E2_FILORIG"
            ENDIF
        ELSE
            cRet := "SE2.E2_FILIAL"
        ENDIF
    ENDIF

RETURN cRet
