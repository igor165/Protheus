#INCLUDE "FileIO.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "fwschedule.ch"
#INCLUDE "CTBXREL.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³EntidadeCTB³ Autor ³ Pilar S Albaladejo    ³ Data ³ 15.12.99 		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime a Entidade Contabil                                 			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³EntidadeCTB(cEntidade,nLinha,nColuna,nTam,lPosiciona,cMascara,         ³±±
±±³          ³cSeparador,cAlias,nOrder,lGraf,oPrint)CtbDtComp(nOpc,dData,cMoeda)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.   .                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Entidade               	                 		 ³±±
±±³          ³ ExpN1 = Numero da Linha                                   		     ³±±
±±³          ³ ExpN2 = Numero da Coluna                                  		     ³±±
±±³          ³ ExpN3 = Tamanho                                           		     ³±±
±±³          ³ ExpL1 = Se precisa procurar no arquivo de cadastro        		     ³±±
±±³          ³ ExpC2 = Codigo da Mascara                                 		     ³±±
±±³          ³ ExpC3 = separador                                         		     ³±±
±±³          ³ ExpC4 = Alias                                             		     ³±±
±±³          ³ ExpN4 = Ordem                                             		     ³±±
±±³          ³ ExpL2 = Se eh relatorio grafico										 ³±±
±±³          ³ ExpO1 = Objeto oPrint                                     		     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function EntidadeCTB(cEntidade,nLinha,nColuna,nTam,lPosiciona,cMascara,cSeparador,cAlias,nOrder,lGraf,oPrint,lSay,lNormal)

Local aSaveArea := GetArea()
Local aTamEntid
Local cEntEmp	:= ""

DEFAULT lSay := .T.
DEFAULT lNormal := .T.


/** TRATAMENTO DE PERFORMANCE PARA RODONAVES */
If Empty(cEntidade)
	If lSay 
		If lGraf
			oPrint:Say(nLinha,nColuna,"",oFont08 )
		Else
			@ nLinha, nColuna pSay " "
		Endif
		
		RestArea(aSaveArea)
		Return .T.
	Else
		RestArea(aSaveArea)
		Return ""	
	EndIf
EndIf		
/** */


If cAlias == "CT1"
	aTamEntid := TamSx3("CT1_CONTA")
	If lPosiciona
		dbSelectArea("CT1")
		dbSetOrder(nOrder)
		MsSeek(xFilial()+cEntidade)
	EndIf
ElseIf cAlias == "CTT"
	aTamEntid := TamSX3("CTT_CUSTO")
	If lPosiciona
		dbSelectArea("CTT")
		dbSetOrder(nOrder)
		MsSeek(xFilial()+cEntidade)
	EndIf
ElseIf cAlias == "CTD"
	aTamEntid := TamSX3("CTD_ITEM")
	If lPosiciona
		dbSelectArea("CT1")
		dbSetOrder(nOrder)
		MsSeek(xFilial()+cEntidade)
	EndIf
ElseIf cAlias == "CTH"
	aTamEntid := TamSX3("CTH_CLVL")
	If lPosiciona
		dbSelectArea("CTH")
		dbSetOrder(1)
		MsSeek(xFilial()+cEntidade)
	EndIf
EndIf

If lSay
	If lGraf
		cEntEmp := MascaraCTB(cEntidade,cMascara,nTam,cSeparador,cAlias)
		oPrint:Say(nLinha,nColuna,cEntEmp,oFont08 )
	Else
		@ nLinha, nColuna pSay MascaraCTB(cEntidade,cMascara,nTam,cSeparador,cAlias)
	Endif
Else
	RestArea(aSaveArea)
	Return( MascaraCTB(cEntidade,cMascara,nTam,cSeparador,cAlias,lNormal) )
EndIf

RestArea(aSaveArea)

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ValorCTB   ³ Autor ³ Pilar S Albaladejo    ³ Data ³ 15.12.99 		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime O Valor                                             			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ValorCtb(nSaldo,nLin,nCol,nTamanho,nDecimais,lSinal,cPicture,;         ³±±
±±³          ³						cTipo,cConta,lGraf,oPrint)					  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.   .                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor                            	                 		 ³±±
±±³          ³ ExpN2 = Numero da Linha                                   		     ³±±
±±³          ³ ExpN3 = Numero da Coluna                                  		     ³±±
±±³          ³ ExpN4 = Tamanho                                           		     ³±±
±±³          ³ ExpN5 = Numero de Decimais											 ³±±
±±³          ³ ExpL1 = Se devera ser impresso com sinal ou nao.          		     ³±±
±±³          ³ ExpC1 = Picture                                           		     ³±±
±±³          ³ ExpC2 = Tipo                                              		     ³±±
±±³          ³ ExpC3 = Conta                                             		     ³±±
±±³          ³ ExpL2 = Se eh grafico ou nao                              		     ³±±
±±³          ³ ExpO1 = Objeto oPrint                                     		     ³±±
±±³          ³ ExpC4 = Tipo do sinal utilizado                           		     ³±±
±±³          ³ ExpC5 = Identificar [USADO em modo gerencial]             		     ³±±
±±³          ³ ExpL3 = Imprime zero                                      		     ³±±
±±³          ³ ExpL4 = Se .F., ao inves de imprimir retornara o valor como caracter³±±
±±³          ³ ExpL5 = If .T. (debit or credit balance column) and Red Storn is      ³±±
±±³          ³         active, set cTipo value to empty (to show negative signal)    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ValorCtb(	nSaldo,nLin,nCol,nTamanho,nDecimais,lSinal,cPicture,;
					cTipo,cConta,lGraf,oPrint,cTipoSinal, cIdentifi,lPrintZero,lSay,lColDbCr,lCharSinal,lPlanilha)

Local aSaveArea	:= GetArea()
Local cImpSaldo := ""
Local cPicAux	:= ""
Local lDifZero	:= .T.
Local lInformada:= .T.
Local cCharSinal:= ""

Local lRedStorn	:= cPaisLoc == "RUS" .And. SuperGetMV("MV_REDSTOR",.F.,.F.) // CAZARINI - 20/06/2017 - Parameter to activate Red Storn

DEFAULT lPlanilha := .F.

lPrintZero := Iif(lPrintZero==Nil,.T.,lPrintZero)

// Nao imprime o valor 0,00
If !lPrintZero
	If (Int(nSaldo*100)/100) == 0
		lDifZero := .F.			// O saldo nao eh diferente de zero
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tipo D -> Default (D/C)												  ³
//³ Tipo S -> Imprime saldo com sinal									  ³
//³ Tipo P -> Imprime saldo entre parenteses (qdo. negativo)	  ³
//³ Tipo C -> So imprime "C" (o "D" nao e impresso)              ³
//³ Tipo N -> Imprime saldo com sinal (-) se o saldo for credor³
//³ Tipo R -> Default Red Storno: Imprime natureza da conta  (C/D) e saldo relativo a ela	     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT cTipoSinal := SuperGetMV("MV_TPVALOR")       // Assume valor default

DEFAULT lSay := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ lColDbCr .F. -> Consider account normal according with cTipo ³
//³ lColDbCr .T. -> Disconsider cTipo, setting cTipo to empty    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT lColDbCr	:= .F.
DEFAULT lCharSinal	:= .T.

cTipo 		:= Iif(cTipo == Nil, Space(1), cTipo)
nDecimais	:= Iif(nDecimais==Nil,SuperGetMV("MV_CENT"),nDecimais)

dbSelectArea("CT1")
dbSetOrder(1)

If lRedStorn
	cTipoSinal	:=	"R"
	If lColDbCr
		lSinal	:=	.T.
		cTipo := Space(1)
	Else
		If !Empty(cConta) .And. Empty(cTipo)
			If MsSeek(cFilial+cConta)
				cTipo := CT1->CT1_NORMAL
			Endif
		EndIf

		If Empty(cTipo)
			cTipo := "2"
		Endif
	Endif
Endif


If !Empty(cConta) .And. Empty(cTipo)
	If MsSeek(cFilial+cConta)
		cTipo := CT1->CT1_NORMAL
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna a picture. Caso nao exista espaco, retira os pontos  ³
//³ separadores de dezenas, centenas e milhares 					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cPicture)
	If cTipoSinal $ "D/C" .Or. (cPaisLoc == "RUS" .And. cTipoSinal == "R")
		cPicture := TmContab(Abs(nSaldo),nTamanho,nDecimais)
	Else
		cPicture := TmContab(nSaldo,nTamanho,nDecimais)
	EndIf
	lInformada  := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³* Alguns valores, apesar de  terem sinal devem ser impressos  ³
//³ sem sinal (lSinal). Ex: valores de colunas Debito e Credito  ³
//³* Se estiver com a opcao de lingua estrangeira (lEstrang) a   ³
//³ picture sera invertida para exibir valores: 999,999,999.99   ³
//³* O tipo de sinal "D" - default nao leva em consideracao a    ³
//³ a natureza da conta. Dessa forma valores negativos serao	  ³
//³ impressos sem sinal, e ao seu lado "D" (Devedor) e valores   ³
//³ positivos terao um "C" (Credito) impresso ao seu lado.       ³
//³* O tipo de Sinal "P" - Parenteses, imprimira valores de saldo³
//³  invertidos da condicao normal da conta entre parenteses.	  ³
//³* O tipo de Sinal "S" - Sinal, imprimira valores de saldo in- ³
//³  vertidos da condicao normal da conta com sinal - 			  ³
//³EXEMPLOS  -  EXEMPLOS  -  EXEMPLOS	-	EXEMPLOS  - EXEMPLOS   ³
//³Cond Normal 	Saldo 	Default      Sinal   Parenteses		  ³
//³	D			   -1000	   1000 D 		 1000		 1000			  	  ³
//³	D				 1000 	1000 C		-1000 	(1000)			  ³
//³	C				-1000 	1000 D		-1000 	(1000)			  ³
//³	C				 1000 	1000 C		 1000 	 1000 			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// So imprime valor se for diferente de zero!
If lDifZero
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Neste caso (Default), nao importa a natureza da conta! Saldos³
	//³ devedores serao impressos com "D" e credores com "C".        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Neste caso, nao importa a natureza da conta!!
	If cTipoSinal == "D" .Or. cTipoSinal == "C" .Or. cTipoSinal == "N"			// D(Default) ou C(so Credito)
		If !lInformada
			cPicture := "@E " + cPicture
		Endif
		If lSinal
			If lRedStorn
				If cTipo == "1"	// debit account
					nSaldo := nSaldo * (-1) // consider account normal
				Endif
			Endif
			If nSaldo < 0
				If lGraf
					If cTipoSinal == "D"
						cCharSinal := Iif(cPaisLoc<>"MEX","D","C")
					EndIf
				Else
					// No Tipo C -> so sao impressos os "C´s"
					If cTipoSinal == "D"
						cCharSinal := Iif(cPaisLoc<>"MEX","D","C")
					EndIf
				Endif
			ElseIf nSaldo > 0
				If lGraf
					If cIdentifi # Nil .And. cIdentifi $ "34"
						If cTipoSinal == "D"
							cCharSinal := Iif(cPaisLoc<>"MEX","C","A")
						EndIf
					Else
						cCharSinal := Iif(cPaisLoc<>"MEX","C","A")
					Endif
				Else
					cCharSinal := Iif(cPaisLoc<>"MEX","C","A")
				Endif
			EndIf
			cCharSinal := " "+cCharSinal
		EndIf

		//Se o parametro MV_TPVALOR == "N" => nao considera a condicao normal da conta.
		//So imprime sinal (-) se o saldo for credor.
		If cTipoSinal == "N"
			If lSinal
				cImpSaldo := Transform(nSaldo*(-1),cPicture)
				nSaldo	  := nSaldo*(-1)
			Else
				cImpSaldo := Transform(ABS(nSaldo),cPicture)
			EndIf
		Else
			cImpSaldo := Transform(Abs(nSaldo),cPicture)+cCharSinal
		EndIf

		If lGraf
			If cIdentifi # Nil .And. cIdentifi $ "34"
				If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
					oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
				Else
					oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
				EndIf
			Else
				oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
			Endif
		ElseIf lSay
			@ nLin, nCol pSay cImpSaldo
		Endif

	ElseIf cPaisLoc == "RUS" .And. cTipoSinal == "R"

		If lColDbCr .And. lRedStorn
			If cTipo == "1"	// debit account
				nSaldo := nSaldo * (-1) // consider account normal
			Endif
		Else
			If (nSaldo > 0 .and. cTipo=="2") .OR. (nSaldo<0 .and. cTipo=="1")
				nSaldo := ABS(nSaldo)* 1
			Else
				nSaldo := ABS(nSaldo)* -1
			Endif

			cCharSinal := iF(cTipo=='1','D','C')
		Endif
		cImpSaldo := Transform(nSaldo,cPicture)+Iif(lCharSinal,cCharSinal,"")

		If lGraf
			If cIdentifi # Nil .And. cIdentifi $ "34"
				If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
					oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
				Else
					oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
				EndIf
			Else
				oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
			Endif
		ElseIf lSay
			@ nLin, nCol pSay cImpSaldo
		Else
			Return cImpSaldo
		Endif


	Else
		//Utiliza conceito de conta estourada e a conta eh redutora.
		If Select("cArqTmp") > 0 .And. cArqTmp->(FieldPos("ESTOUR")) <> 0 .And.  cArqTmp->ESTOUR == "1"
			If cTipo == "1" 								// Conta Devedora
				If cTipoSinal == "S"              			// Sinal
					If !lSinal
						nSaldo := Abs(nSaldo)
					EndIf
					If !lInformada
						cPicture := "@E " + cPicture
					EndIf
					If lGraf
						cImpSaldo := Transform(nSaldo,cPicture)
						If cIdentifi # Nil .And. cIdentifi $ "34"
							If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
							Else
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
							EndIf
						Else
							oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
						Endif
					ElseIf lSay
						@ nLin, nCol PSAY nSaldo Picture cPicture
					Else
						cImpSaldo := Transform(nSaldo,cPicture)
					Endif
				ElseIf (cTipoSinal) == "P"              	// Parenteses
					If !lSinal
						nSaldo := Abs(nSaldo)
					EndIf

					If !lInformada
						If (Len(cPicture) + 2) > nTamanho
							cPicture := SubStr(cPicture,(Len(cPicture) + 3)-nTamanho,Len(cPicture))
						EndIf
						cPicture := "@E( " + cPicture

					ElseIf nSaldo < 0
						IF AT("@E", cPicture) > 0
							cPicAux  := SubStr(cPicture,AT(" ",cPicture),Len(cPicture))
							If (Len(cPicAux) + 2) > nTamanho
								cPicAux := SubStr(cPicAux,(Len(cPicture) + 3)-nTamanho,Len(cPicture))
							EndIf
							cPicture := "@E( " + cPicAux
						Else
							cPicture := "@E( " + cPicture
						EndIf

					EndIf

					If lGraf
						cImpSaldo := Transform(nSaldo,cPicture)
						If cIdentifi # Nil .And. cIdentifi $ "34"
							If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
							Else
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
							EndIf
						Else
							oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
						Endif
					ElseIf lSay
						@ nLin, nCol pSay nSaldo Picture cPicture
					Else
						cImpSaldo := Transform(nSaldo,cPicture)
					Endif
				EndIf
			Else
				If (cTipoSinal) == "S"                  	// Sinal
					If lSinal
						nSaldo := nSaldo * (-1)
					Else
						nSaldo := Abs(nSaldo)
					EndIf
					If !lInformada
						cPicture := "@E " + cPicture
					EndIf
					If lGraf
						cImpSaldo := Transform(nSaldo,cPicture)
						If cIdentifi # Nil .And. cIdentifi $ "34"
							If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
							Else
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
							EndIf
						Else
							oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
						Endif
					ElseIf lSay
						@ nLin, nCol PSAY nSaldo Picture cPicture
					Else
						cImpSaldo := Transform(nSaldo,cPicture)
					Endif
				ElseIf (cTipoSinal) == "P"              // Parenteses
					If lSinal
						nSaldo := nSaldo * (-1)
					Else
						nSaldo := Abs(nSaldo)
					EndIf

					If !lInformada
						If (Len(cPicture) + 2) > nTamanho
							cPicture := SubStr(cPicture,(Len(cPicture) + 3)-nTamanho,Len(cPicture))
						EndIf
						cPicture := "@E( " + cPicture

					ElseIf nSaldo < 0
						IF AT("@E", cPicture) > 0
							cPicAux  := SubStr(cPicture,AT(" ",cPicture),Len(cPicture))
							If (Len(cPicAux) + 2) > nTamanho
								cPicAux := SubStr(cPicAux,(Len(cPicture) + 3)-nTamanho,Len(cPicture))
							EndIf
							cPicture := "@E( " + cPicAux
						Else
							cPicture := "@E( " + cPicture
						EndIf

					EndIf


					If lGraf
						cImpSaldo := Transform(nSaldo,cPicture)			// Debito
						If cIdentifi # Nil .And. cIdentifi $ "34"
							If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
							Else
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
							EndIf
						Else
							oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
						Endif
					ElseIf lSay
						@ nLin, nCol pSay nSaldo Picture cPicture
					Else
						cImpSaldo := Transform(nSaldo,cPicture)
					Endif
				EndIf
			EndIf
		Else	//Se nao utiliza conceito de conta estourada
			If cTipo == "1" 								// Conta Devedora
				If cTipoSinal == "S"              			// Sinal
					If lSinal
						nSaldo := nSaldo * (-1)
					Else
						nSaldo := Abs(nSaldo)
					EndIf
					If !lInformada
						cPicture := "@E " + cPicture
					EndIf
					If lGraf
						cImpSaldo := Transform(nSaldo,cPicture)
						If cIdentifi # Nil .And. cIdentifi $ "34"
							If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
							Else
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
							EndIf
						Else
							oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
						Endif
					ElseIf lSay
						@ nLin, nCol PSAY nSaldo Picture cPicture
					Else
						cImpSaldo := Transform(nSaldo,cPicture)
						cImpSaldo := PADL(STRTRAN(cImpSaldo,' ',''),len(cImpSaldo))
					Endif
				ElseIf (cTipoSinal) == "P"              	// Parenteses
					If lSinal
						nSaldo := nSaldo * (-1) 		  		// a Picture so exibe parenteses para numeros negativos
					Else
						nSaldo := Abs(nSaldo)
					EndIf

					If !lInformada
						If (Len(cPicture) + 2) > nTamanho
							cPicture := SubStr(cPicture,(Len(cPicture) + 3)-nTamanho,Len(cPicture))
						EndIf
						cPicture := "@E( " + cPicture

					ElseIf nSaldo < 0
						IF AT("@E", cPicture) > 0
							cPicAux  := SubStr(cPicture,AT(" ",cPicture),Len(cPicture))
							If (Len(cPicAux) + 2) > nTamanho
								cPicAux := SubStr(cPicAux,(Len(cPicture) + 3)-nTamanho,Len(cPicture))
							EndIf
							cPicture := "@E( " + cPicAux
						Else
							cPicture := "@E( " + cPicture
						EndIf

					EndIf


					If lGraf
						cImpSaldo := Transform(nSaldo,cPicture)
						If cIdentifi # Nil .And. cIdentifi $ "34"
							If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
							Else
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
							EndIf
						Else
							oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
						Endif
					ElseIf lSay
						@ nLin, nCol pSay nSaldo Picture cPicture
					Else
						cImpSaldo := Transform(nSaldo,cPicture)
						cImpSaldo := PADL(STRTRAN(cImpSaldo,' ',''),len(cImpSaldo))
					Endif
				EndIf
			Else
				If (cTipoSinal) == "S"                  	// Sinal
					If !lSinal .And. cTipo == "2" 			// Conta Credora
						nSaldo := Abs(nSaldo)
					EndIf
					If !lInformada
						cPicture := "@E " + cPicture
					EndIf
					If lGraf
						cImpSaldo := Transform(nSaldo,cPicture)
						If cIdentifi # Nil .And. cIdentifi $ "34"
							If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
							Else
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
							EndIf
						Else
							oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
						Endif
					ElseIf lSay
						@ nLin, nCol PSAY nSaldo Picture cPicture
					Else
						cImpSaldo := Transform(nSaldo,cPicture)
					Endif
				ElseIf (cTipoSinal) == "P"              // Parenteses
					If !lSinal .And. cTipo == "2" 			// Conta Credora
						nSaldo := Abs(nSaldo)
					EndIf

					If !lInformada
						If (Len(cPicture) + 2) > nTamanho
							cPicture := SubStr(cPicture,(Len(cPicture) + 3)-nTamanho,Len(cPicture))
						EndIf
						cPicture := "@E( " + cPicture

					ElseIf nSaldo < 0
						IF AT("@E", cPicture) > 0
							cPicAux  := SubStr(cPicture,AT(" ",cPicture),Len(cPicture))
							If (Len(cPicAux) + 2) > nTamanho
								cPicAux := SubStr(cPicAux,(Len(cPicture) + 3)-nTamanho,Len(cPicture))
							EndIf
							cPicture := "@E( " + cPicAux
						Else
							cPicture := "@E( " + cPicture
						EndIf

					EndIf

					If lGraf
						cImpSaldo := Transform(nSaldo,cPicture)			// Debito
						If cIdentifi # Nil .And. cIdentifi $ "34"
							If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
							Else
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
							EndIf
						Else
							oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
						Endif
					ElseIf lSay
						@ nLin, nCol pSay nSaldo Picture cPicture
					Else
						cImpSaldo := Transform(nSaldo,cPicture)
					Endif
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MV_CTBPLAN - Define se o valor será retornado como número ou ³
//³ formatado como string pela variável cPicture, quando exportado para planilha. ³
//³ Somente retornará como número, caso além de estar configurado com N ³
//³ o valor a ser retornado tenha cTipoSinal $ "S|N" ou !lSinal ³
//³ ³
//³ S -> Retorna valor numérico formatado, incluindo pontos de milhar ³
//³ N -> Retorna valor numérico como número sem pontos de milhar ³
//³ ³
//³ Define o formato dos valores nos relatorios contabeis para planilha, tipo sinal S ou N ou sem sinal. ³
//³ S=String (mantem a picture),N=Numerico             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT cCtbPlanValor := SuperGetMV("MV_CTBPLAN",.F.,"N")       // Assume valor default

If lPlanilha .And. cCtbPlanValor == 'N' .And. (Upper(AllTrim(cTipoSinal)) $ "S|N" .Or. !lSinal)
	Return nSaldo
EndIf

If !lSay
	If Empty( cImpSaldo ) .And. lPrintZero
		cImpSaldo := Transform(nSaldo,cPicture)		
	EndIf
	Return cImpSaldo
EndIf

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DecimalCTB ³ Autor ³ Pilar S Albaladejo    ³ Data ³ 15.12.99 		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica o numero de decimais                               			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³DecimalCTB(aSetOfBook,cMoeda)										     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nDecimais                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array ref. aSetOfBook             	                 		 ³±±
±±³          ³ ExpC1 = Moeda                                             		     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function DecimalCTB(aSetOfBook,cMoeda)

Local aSaveArea := GetArea()
Local nDecimais := 0

//Se nao estiver usando configuracao de livros, considera o numero de casas decimais do cadastro
//de moedas
If Empty(aSetOfBook[1])
	dbSelectArea("CTO")
	dbSetOrder(1)
	If MsSeek(xFilial()+cMoeda) .And. nDecimais <> CTO->CTO_DECIM
		nDecimais := CTO->CTO_DECIM
	EndIf
Else
	//Se a picture nao estiver preenchida, considera o numero de casas decimais da configuracao de
	//livros. Se a picture estiver preenchida, ira considerar as casas decimais da picture.
	If Empty(aSetOfBook[4])
		nDecimais	:= aSetOfBook[3]
	EndIf
EndIf

RestArea(aSaveArea)

Return nDecimais

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbMoeda   ³ Autor ³ Pilar S Albaladejo    ³ Data ³ 15.12.99 		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica a moeda                                            			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbMoeda(cMoeda)   	             								     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array contendo os dados da moeda                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Moeda                             	                 		 ³±±
±±³          ³ ExpN1 = Fator de divisao                  	                 		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbMoeda(cMoeda, nDivisao)

Local aSaveArea := GetArea()
Local aCtbMoeda := {"","","","",0,""}
Local cString	:= ""
Local cFilialCTO

DEFAULT nDivisao := 1 // seta o default no numero de divisão

dbSelectArea( "CTO" )
dbSetOrder(1)

cFilialCTO := xFilial( "CTO" )

If nDivisao != Nil .And. nDivisao > 1
	If nDivisao == 100
		cString := STR0001			// "Centena"
	ElseIf nDivisao == 1000
		cString := STR0002 			// "Mil"
	ElseIf nDivisao == 1000000
		cString := STR0003			// "Milhares"
	EndIf
EndIf

If CTO->(MsSeek( cFilialCTO + cMoeda ))
	aCtbMoeda := {	CTO->CTO_MOEDA,CTO->CTO_DESC,CTO->CTO_SIMB,CTO->CTO_BLOQ,CTO->CTO_DECIM, cString	}
EndIf

aCtbMoeda[3] := AllTrim(aCtbMoeda[3]) + " " + cString


RestArea( aSaveArea )

Return aCtbMoeda

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbSetOf   ³ Autor ³ Pilar S Albaladejo    ³ Data ³ 15.12.99 		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna Array com o set of book                             			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbMoeda(cSetOfBook)	             								     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array contendo os dados do set Of book                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Set Of book             	                 		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbSetOf(cSetOfBook)

Local aSaveArea := GetArea()
Local aSetOfBook:= {"","",0,"","","","","",1,"","",""}

dbSelectArea("CTN")
cSetOfBook := Padr(cSetOfBook,Len(CTN->CTN_CODIGO))
dbSetOrder(1)
If MsSeek(xFilial()+cSetOfBook,.F.)
	// Codigo Set / Mascara Conta / Decimais / Picture Valores
	// Plano Gerencial / Mascara C Custo/ Mascara Item / Mascara CLVL
	aSetOfBook := {	CTN->CTN_CODIGO,CTN->CTN_MASC1,CTN->CTN_DECIM,CTN->CTN_PICTV,;
					CTN->CTN_PLAGER,CTN->CTN_MASC2,CTN->CTN_MASC3,CTN->CTN_MASC4,;
					1,AllTrim(CTN_DESC),CTN->CTN_PLREF,CTN->CTN_VERSAO}
EndIf

RestArea(aSaveArea)

Return aSetOfBook
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RetMasCTB  ³ Autor ³ Pilar S Albaladejo    ³ Data ³ 15.12.99 		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a mascara da entirdade                              			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³RetMasCTB(cCodigo,cSeparador)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cMascara                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Mascara                 	                 		 ³±±
±±³          ³ ExpC2 = Separador                         	                 		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function RetMasCTB(cCodigo,cSeparador)

Local aSaveArea := GetArea()
Local cMascara  := ""
Local cDigito

dbSelectArea("CTM")
dbSetOrder(1)
MsSeek(xFilial()+cCodigo)
While !Eof() .And. CTM->CTM_FILIAL == xFilial() .And.;
		CTM->CTM_CODIGO == cCodigo

	cDigito 	:= CTM->CTM_DIGITO
	cMascara 	+= Alltrim(cDigito)
	cSeparador	+= CTM->CTM_SEPARA
	dbSkip()

EndDo

RestArea(aSaveArea)

Return cMascara

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MascaraCTB ³ Autor ³ Pilar S Albaladejo    ³ Data ³ 15.12.99 		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a entidade com a mascara                            			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MascaraCTB(Codigo,cMascara,nTamanho,cSeparador)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cCodigo                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Entidade                	                 		 ³±±
±±³          ³ ExpC2 = Mascara                           	                 		 ³±±
±±³          ³ ExpN1 = Tamanho                           	                 		 ³±±
±±³          ³ ExpC3 = Separador                         	                 		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MascaraCTB(cCodigo,cMascara,nTamanho,cSeparador,cAlias,lNormal)

Local cCodLido := AllTrim ( cCodigo )
Local cCaracter:= ""
Local cPosicao	:= ""
Local cCodMasc	:= ""
Local nTamPos	:= 0
Local nTam		:= 0
Local nCont		:= 0
Local nNivel	:= 0
Local nPosicao := 0

DEFAULT lNormal := .T.

If !Empty(cMascara) .And. !Empty(cSeparador)
	nTamanho 	:= IIF( nTamanho == NIL,;
					 Len ( cCodigo ) + IIF(Len ( cMascara ) == 0, 0, Len ( cMascara )- 1), ;
					 nTamanho)

	cCodigo			:= AllTrim(cCodigo)
	If (Len(cSeparador)+Len(cCodigo)) > nTamanho
		nTam 			:= (Len(cSeparador)+Len(cCodigo)) - nTamanho
		cSeparador 	:= Substr(cSeparador,1,(Len(cSeparador)-nTam))
	EndIf

	For nNivel = 1 to Len ( cMascara ) Step 2
		nPosicao += Val ( Substr ( cMascara, nNivel, 2 ) ) + 1
		nCont++
		cCaracter := Substr(cSeparador,nCont,1)
		If ( nPosicao <= Len ( cCodigo ) )
			cCodigo := Stuff ( cCodigo, nPosicao, 0, cCaracter)
		End
	Next
Else
	// Manter compatibilidade com versao anterior do fonte.
	cCodigo		:= AllTrim ( cCodigo )
	If (cMascara == Nil .And. cAlias != Nil)
		If cAlias == "CT1"
			cMascara := GetMv("MV_MASCARA")
		ElseIf cAlias == "CTT"
			cMascara := GetMv("MV_MASCCUS")
		EndIf
	EndIf
	cMascara 	:= Iif(cMascara == NIL,GetMV("MV_MASCARA"),cMascara)
	cSeparador  := Iif(cSeparador == Nil .Or. Empty(cSeparador),Repl(".", Len(cMascara) - 1),cSeparador)
	nTamanho 	:= IIF( nTamanho == NIL,;
					 Len ( cCodigo ) + IIF(Len ( cMascara ) == 0, 0, Len ( cMascara )- 1), ;
					 nTamanho)

	If !Empty(cMascara) .And. !Empty(cCodigo) .And. lNormal	  //para cód. Reduzido, nao adc mascara
	    	    // For nNivel := IIF(cMascara >= "10",Len(cCodLido),1) to Len(cCodLido)
	    For nNivel := 1 to Len(cCodLido)
	    		cPosicao := Substr(cMascara,nNivel,1)

			If 65 <= ASC(cPosicao) .And. ASC(cPosicao) <= 90
			   nTamPos := ASC(cPosicao)-55
			ElseIf 97 <= ASC(cPosicao) .And. ASC(cPosicao) <= 122
			   nTamPos := ASC(cPosicao)-81
			Else
			   nTamPos := Val(cPosicao)
			EndIf

			cCodMasc += Left(cCodLido,nTamPos)
			cCodLido := Substr(cCodLido,nTamPos+1)
			If ! Empty(cCodLido)
				cCodMasc += Substr(cSeparador,nNivel,1)
			Endif
		Next
	    cCodigo := cCodMasc + cCodLido
	EndIf
EndIf

cCodigo := PadR ( cCodigo, nTamanho )

Return ( cCodigo )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³³CtCGCCabTR³ Autor ³ Cicero J. Silva      ³ Data ³ 16/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Monta Cabecalho do relatorio                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³CtCGCCabTR(Titulo,oReport)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³Arg1  = Indica se imprime item							   ³±±
±±³           ³Arg2  = Indica se imprime c.custo						   ³±±
±±³           ³Arg3  = Indica se imprime classe de valor				   ³±±
±±³           ³Arg4  = Conteudo da cabec1               				   ³±±
±±³           ³Arg5  = Conteudo da cabec2               				   ³±±
±±³           ³Arg6  = Data final do relatorio          				   ³±±
±±³           ³Arg7  = Titulo                           				   ³±±
±±³           ³Arg8  = Indica se imprime analitico      				   ³±±
±±³           ³Arg9  = Tipo                             				   ³±±
±±³           ³Arg10 = Tamanho                          				   ³±±
±±³           ³Arg11 = Retorna titulos                  				   ³±±
±±³           ³Arg12 = Objeto do oReport                   				   ³±±
±±³           ³Arg13 = Nome do programa                   				   ³±±
±±³           ³Os parametros da funcao original ³CtCGCCabec³ foram mantidos³±±
±±³           ³somente para a fins de compatibilidade.     				   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CtCGCCabTR(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,cTipo,Tamanho,aCab,oReport,lCtrlPage,lNewVars,nPagIni,nPagFim,nReinicia,nPag,nBloco,nBlCount,l1StQb,dDataIni)

Local cNmEmp
Local cChar			:= chr(160)  // caracter dummy para alinhamento do cabeçalho
Local lCTCABR4		:= ExistBlock("CTCABR4")
Local cCodigo       := Alltrim(SM0->M0_CGC)
Local nAno   	    := ""
Local lCtbr520      := FunName() == "CTBR520"
Local lCtbr047      := FunName() == "CTBR047"
Local lCtbr510      := FunName() == "CTBR510"
Local lCtbr700      := FunName() == "CTBR700"
Local cFormato      := ""
Local cDoc
Local cDomFis		:= ""
DEFAULT aCab 		:= {}
DEFAULT lCtrlPage	:= .F. // Controla a numeração de pagina
DEFAULT lNewVars	:= .F.
DEFAULT nPagIni		:= 1
DEFAULT nPagFim		:= 99999
DEFAULT nReinicia	:= 1
DEFAULT nPag		:= 1
DEFAULT nBloco		:= 1
DEFAULT nBlCount	:= 0
DEFAULT l1StQb		:= .F.
DEFAULT dDataIni    := cTod('01/01/04')

SX3->( DbSetOrder(2) )
SX3->( MsSeek( "A1_CGC" , .t.))

If SM0->(Eof())
	SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
Endif

RptFolha := GetNewPar( "MV_CTBPAG" , RptFolha )

Aadd( aCab, AllTrim( SM0->M0_NOMECOM ))
Aadd( aCab, AllTrim( titulo ) )

If cPaisLoc == "BRA"
	If Len(cCodigo)>11
		Aadd( aCab, Transform( Alltrim( SM0->M0_CGC ), alltrim("@R 99.999.999/9999-99")))
		cDoc := aCab[3]
	Else
		Aadd( aCab, Transform( Alltrim( SM0->M0_CGC ), alltrim("@R 999.999.999-99")))
		cDoc := aCab[3]
	EndIf
Else
	Aadd( aCab, Transform( Alltrim( SM0->M0_CGC ), alltrim( SX3->X3_PICTURE )))
	cDoc := aCab[3]
EndIf

If lCtrlPage
	nPag++

	// Renato F. Campos
	// faz o controle de numeração de pagina
	// as variaveis deverão ser declaradas no relatorio como private
	CtbQbPg( @lNewVars, @nPagIni, @nPagFim, @nReinicia, @nPag, @nBloco, @nBlCount, @l1StQb )

	oReport:SetPageNumber( nPag )
Endif

//Protecao para NomeProg nao declarada
If type( 'NomeProg' ) == 'U'
	NomeProg := FunName()
EndIf


//****************************************************
// Ponto de Entrada para Manipular o Nome da Empresa *
//  nos relatorios do CTB.                           *
//****************************************************
If !ExistBlock("CTBCABRAZ")
	cNmEmp	:= AllTrim( SM0->M0_NOMECOM )
Else
	cNmEmp	:= AllTrim( Execblock( "CTBCABRAZ" , .F.,.F. ) )
Endif

If cPaisLoc == 'COL'
	cDataExt := Transform(Day(dDataIni),'99') + " de " + MesExtenso(dDataIni) + " de " + Transform(Year(dDataIni),'9999');
    	        + " a " + Transform(Day(dDataFim),'99') + " de " + MesExtenso(dDataFim) + " de " + Transform(Year(dDataFim),'9999')

	aCabec := { 	"__LOGOEMP__";
	          , cChar + "         " +  cNmEmp                            + "         " + cChar;
              , cChar + "         " + Transform( Alltrim( SM0->M0_CGC ), alltrim( SX3->X3_PICTURE ))     + "         " + cChar;
	          , cChar + "         " +  AllTrim(titulo)     + "         " + cChar;
    	      , cChar + "         " + cDataExt             + "         " + cChar;
    	      , cChar + "         " + RptFolha + TRANSFORM(oReport:Page(),'999999') }


Elseif cPaisLoc == 'PER'

		If lCtbr520
			cFormato := " 3.18: "
		ElseIf lCtbr047
			cFormato := " 3.17: "
		ElseIf lCtbr510
			cFormato := " 3.20: "
		ElseIf lCtbr700
			cFormato := " 10.2: "
		EndIf

		If lCtbr520 .OR. lCtbr047 .Or. lCtbr510 .Or. lCtbr700
		// Se nao foi especificado a data inicial assumira o DEFAULT e nao deve imprimir o periodo.
			If dDataIni == CtoD( "01/01/04" )
				nAno := YEAR(dDataIni)
				aCabec := { 	"__LOGOEMP__";
		   		         , cChar + STR0004 + cFormato + STR0005 + " - " + AllTrim(titulo);  //"FORMATO"###"Livros de Estoques e Saldos"
		   		         , cChar + "Ejercicio: " + Alltrim(STR(nAno));
		           		 , cChar + "RUC: " + Transform( Alltrim( SM0->M0_CGC ), alltrim( SX3->X3_PICTURE ))  + "         " + cChar;
		           		 , cChar + STR0006 + ": " + AllTrim( SM0->M0_NOMECOM )}		//"Sobrenomes e nomes, denominação ou razão social:"
			Else
				nAno := YEAR(dDataIni)
		   		aCabec := { 	"__LOGOEMP__";
		   		         , cChar + STR0004 + cFormato + STR0005 + " - " + AllTrim(titulo); //"FORMATO"###"Livros de Estoques e Saldos"
		   		         , cChar + "Ejercicio: " + Alltrim(STR(nAno));
		           		 , cChar + " RUC:    " + Transform( Alltrim( SM0->M0_CGC ), alltrim( SX3->X3_PICTURE ))  + "         " + cChar;
		           		 , cChar + STR0006 + ": " + AllTrim( SM0->M0_NOMECOM )}		//		//"Sobrenomes e nomes, denominação ou razão social:"
			EndIf
		Else
			If dDataIni == CtoD( "01/01/04" )
		   		aCabec := { 	"__LOGOEMP__";
		           		 , cChar + " RUC	:    " + Transform( Alltrim( SM0->M0_CGC ), alltrim( SX3->X3_PICTURE ))  + "         " + cChar;
		           		 , cChar + "         " +  cNmEmp                                  + "         " + cChar;
		         		 , cChar + "         " +  AllTrim(titulo)                         + "         " + cChar;
		  	     		 , cChar + "         " + RptFolha + TRANSFORM(oReport:Page(),'999999') }
			Else
		   		aCabec := { 	"__LOGOEMP__";
		   		         , cChar + " Periodo " + DTOC(dDataIni) + " A " + DTOC(dDataFim) + "         " + cChar;
		           		 , cChar + " RUC:    " + Transform( Alltrim( SM0->M0_CGC ), alltrim( SX3->X3_PICTURE ))  + "         " + cChar;
		           		 , cChar + "         " +  cNmEmp                                  + "         " + cChar;
		         		 , cChar + "         " +  AllTrim(titulo)                         + "         " + cChar;
		  	     		 , cChar + "         " + RptFolha + TRANSFORM(oReport:Page(),'999999') }
			EndIf
		EndIf
Else
	if cPaisLoc == 'RUS'

	aCabec := {	"__LOGOEMP__";
		  , cChar + "         " + cNmEmp ;
		  + "         " + cChar + RptFolha+ TRANSFORM(oReport:Page(),'999999');
          , cChar + "                         ";
          + "         " + cChar + RptDtRef + " " + DTOC(dDataBase);
          , alltrim(STR0045) + " " + NomeProg + "/v." + cVersao ;
          + "         " + cChar + AllTrim(titulo) ;
          + "         " + cChar;
          , RptHora + " " + time() ;
          + "         " + cChar + RptEmiss + " " + Dtoc(MsDate());
          ,"" }
	ElseIf cPaisLoc == "ARG"
		cDomFis := Alltrim(SM0->M0_ENDENT) + " " + AllTrim(SM0->M0_CIDENT) + " " + AllTrim(SM0->M0_ESTENT)
		If !Empty(cDomFis)
			cDomFis := " - " + cDomFis
		EndIf
		aCabec := {	"__LOGOEMP__";
		  , cChar + "         " + cNmEmp;
		  + "         " + cChar + RptFolha+ TRANSFORM(oReport:Page(),'999999');
          , cChar + "         " + cDoc + cDomFis ;
          + "         " + cChar + RptDtRef + " " + DTOC(dDataBase);
          , "SIGA /" + NomeProg + "/v." + cVersao ;
          + "         " + cChar + AllTrim(titulo) ;
          + "         " + cChar;
          , RptHora + " " + time() ;
          + "         " + cChar + RptEmiss + " " + Dtoc(MsDate());
          ,"" }
	else
     aCabec := {	"__LOGOEMP__";
		  , cChar + "         " + cNmEmp ;
		  + "         " + cChar + RptFolha+ TRANSFORM(oReport:Page(),'999999');
          , cChar + "         " + cDoc;
          + "         " + cChar + RptDtRef + " " + DTOC(dDataBase);
          , "SIGA /" + NomeProg + "/v." + cVersao ;
          + "         " + cChar + AllTrim(titulo) ;
          + "         " + cChar;
          , RptHora + " " + time() ;
          + "         " + cChar + RptEmiss + " " + Dtoc(MsDate());
          ,"" }
	endif
Endif

//Ponto de Entrada para customizacao do cabecalho
If lCTCABR4
	aCabec := ExecBlock("CTCABR4",.F.,.F.)
Endif

Return aCabec

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CtCGCCabec³ Autor ³ Simone Mie Sato       ³ Data ³ 05/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Monta Cabecalho do relatorio                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³CtCGCCabec(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo ³±±
±±³           ³lAnalitico,cTipo,Tamanho)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ExpL1 = Indica se imprime item							   ³±±
±±³           ³ExpL2 = Indica se imprime c.custo						   ³±±
±±³           ³ExpL3 = Indica se imprime classe de valor				   ³±±
±±³           ³ExpC1 = Conteudo da cabec1               				   ³±±
±±³           ³ExpC2 = Conteudo da cabec2               				   ³±±
±±³           ³ExpD1 = Data final do relatorio          				   ³±±
±±³           ³ExpC3 = Titulo                           				   ³±±
±±³           ³ExpL4 = Indica se imprime analitico      				   ³±±
±±³           ³ExpC4 = Tipo                             				   ³±±
±±³           ³ExpN1 = Tamanho                          				   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtCGCCabec(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,cTipo,Tamanho,lCtrlPage,dDtEmis)
Local lCTCABR3	:= ExistBlock("CTCABR3")
Local cCodigo	:= Alltrim(SM0->M0_CGC)
Local cDoc 		:= ''
Local cVerAux 	:= IIf(Type("cVersao")=="C",cVersao,"")

DEFAULT Tamanho := "G"
DEFAULT lCtrlPage	:= .F. // Controla a numeração de pagina
DEFAULT dDtEmis	:= MsDate()

SX3->( DbSetOrder(2) )
SX3->( MsSeek( "A1_CGC" , .T. ))

If cTipo == '1'
	Tamanho := Iif(((lItem .Or. lCusto .Or. lCLVL) .And. lAnalitico),"G",Tamanho)
	nTam    := Iif(lItem .Or. lCusto .Or. lCLVL .or. Tamanho == "G", 218, 130)
ElseIf cTipo == '2'
	nTam    := Iif(Tamanho == 'G', 218, 130)
Endif

If cPaisLoc == "RUS"
	cDoc := Transform(Alltrim(SM0->M0_CGC),alltrim(SX3->X3_PICTURE))
Else
	If Len(cCodigo)>11
		cDoc := Transform( Alltrim( SM0->M0_CGC ), alltrim("@R 99.999.999/9999-99"))
	Else
		cDoc := Transform( Alltrim( SM0->M0_CGC ), alltrim("@R 999.999.999-99"))
	EndIf
EndIf

RptFolha := GetNewPar( "MV_CTBPAG" , RptFolha )

If SM0->( Eof() )
	SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
Endif

If lCtrlPage
//	m_pag := m_pag - 1 // volta a numeração de pagina, alterada pela rotina "CABEC()"

	// Renato F. Campos
	// faz o controle de numeração de pagina
	// as variaveis deverão ser declaradas no relatorio como private
	CtbQbPg( @lNewVars, @nPagIni, @nPagFim, @nReinicia, @m_pag, @nBloco, @nBlCount, @l1StQb )
Endif

If IsBlind()
	cVersao := ""
EndIf

aCabec := {	"__LOGOEMP__",;
			Left(Padc(AllTrim(SM0->M0_NOMECOM),nTam),nTam-Len(RptFolha+" "+ TRANSFORM(m_pag,'999999')+ "  "))+;
			RptFolha+" "+ TRANSFORM(m_pag,'999999')+ "  ",;
			Left(Padc (Alltrim(cDoc),nTam),nTam-Len(RptDtRef+" "+DTOC(dDataBase)))+RptDtRef+" "+DTOC(dDataBase),;
			Pad("SIGA /"+NomeProg+"/v."+cVersao + Padc(Trim(Titulo),nTam-(Len("SIGA /"+NomeProg+"/v."+cVersao))-If(__SetCentury(),19,17)),nTam),;
			RptHora+" "+time() + PadL(RptEmiss+ " " + Dtoc(dDtEmis),nTam-Len(RptHora+" "+time()))}

If IsBlind()
	cVersao := cVerAux
EndIf

//Ponto de Entrada para customizacao do cabecalho
If lCTCABR3
	aCabec := ExecBlock("CTCABR3",.F.,.F.)
Endif


If cTipo == '1' //Se for Razao
	Cabec(Titulo,Cabec1,cabec2,nomeprog,tamanho,Iif(lItem .Or. lCusto .Or. lCLVL .or. aReturn[4]==1,GetMv("MV_COMP"),;
			GetMv("MV_NORM")), aCabec )
ElseIf cTipo == '2' //Se for Balancete
	cabec(Titulo,Cabec1,cabec2,nomeprog,tamanho,Iif(aReturn[4]==1,GetMv("MV_COMP"),;
		GetMv( "MV_NORM" )), aCabec )
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CtbCbcDem³ Autor ³ Wagner Mobile Costa   ³ Data ³ 14.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cabecalho Padrao para relatorios de demonstrativo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbCbcDem(ExpO1,ExpN1,ExpC1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpC1 = Cabecalho Especifico                               ³±±
±±³          ³ ExpL1 = Portrait ou LandScape                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbCbcDem(oPrint,titulo,lLandScape, nTamLin, nLeftMarg)

Local aEmpresa 			:= { "", "" }
Local nFont14			:= 28, nFont10 := 20
Local cCGCTxt 			:= ""
Local cEmiss			:= OemToAnsi(STR0008) + DtoC( dDataBase)  //"Emissao: "
Local cStartPath		:= GetSrvProfString("Startpath","")
Local cNameFile			:= ""
Local cPicture			:= ""

DEFAULT lLandScape 		:= .T.
DEFAULT Titulo    		:= ""
DEFAULT nTamLin			:= 3120
DEFAULT nLeftMarg 		:= 150

If Type("m_pag") !="N"
	m_pag := 1
EndIf

If ! lLandScape
	nTamLin := 2350
Endif

RptFolha := GetNewPar( "MV_CTBPAG" , RptFolha )

SX3->(DbSetOrder(2))
SX3->(MsSeek("A1_CGC",.t.))
cCGCTxt := X3Titulo()

If cModulo <> "RSP" .And. cModulo <> "CSA"
	If SM0->M0_TPINSC == 3 .And. cPaisLoc == "BRA"
		cPicture := "@R 999.999.999-99"
	Else
		cPicture := alltrim(SX3->X3_PICTURE)
	EndIf

	aEmpresa[1] := AllTrim(SM0->M0_NOMECOM)
	aEmpresa[2] := Trim(cCGCTxt)+" "  +  Transform(Alltrim(SM0->M0_CGC),cPicture)
Else
	aEmpresa[1] := ""
	aEmpresa[2] := ""
EndIf

cStartPath := AjuBarPath(cStartPath)
cNameFile  := cStartPath+"lgrl"+cEmpAnt+cFilAnt+".bmp"
If !File(cNameFile)
	cNameFile := cStartPath+"lgrl"+cEmpAnt+".bmp"
Endif
oPrint:StartPage() 		// Inicia uma nova pagina
oPrint:Box(075,nLeftMarg,250,nTamLin )
oPrint:SayBitmap(078,nLeftMarg+50,cNameFile,316,78) // Tem que estar abaixo do RootPath
If Len(aEmpresa[1]) < 50  //mudar fonte conforme tamanho da string ref empresa
	oPrint:Say(085,(nTamLin - (Len(aEmpresa[1]) * nFont14)) / 2 ,aEmpresa[1],oCouNew14 )
else
	oPrint:Say(085,(nTamLin - (Len(aEmpresa[1]) * nFont10)) / 2 ,aEmpresa[1],oCouNew10 )
endif

oPrint:Say(145,(nTamLin - (Len(aEmpresa[2]) * nFont10)) / 2,aEmpresa[2],oCouNew10 )

If (FunName() == "CTBR560" .OR. FunName() == "CTBR570")  .And. Len(titulo) > 50
	oPrint:Say(185,(nTamLin - (Len(Titulo) * nFont10)) / 2,titulo,oCouNew10 )
Else
	oPrint:Say(185,(nTamLin - (Len(Titulo) * nFont14)) / 2,titulo,oCouNew14 )
EndIf

oPrint:Say(085,(nTamLin - (14 * nFont10))-60,RptFolha + TRANSFORM(m_pag,'999999'),oCouNew10 )
oPrint:Say(145,(nTamLin - (Len(cEmiss) * nFont10))-60, cEmiss,oCouNew10 )
m_pag++

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbGrapPrint³ Autor ³ Wagner Mobile Costa ³ Data ³ 08-11-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de impressao de grafico usando TMsPrinter              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGACTB                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbGrafPrint(oGraphic,cProcesso,aTexto,aTabela, lLandScape, aPosCol, aPosGrh)
Local cRaizServer := If(issrvunix(), "/", "\")

DEFAULT lLandScape := .T.


Private cBmpName

Processa({ || 	Ctr500Cfg(cProcesso, "CtbEnvPrint", cProcesso, .T., oGraphic, aTexto, aTabela, aPosCol, aPosGrh),;
				STR0009 }) //"Montando a impressao do grafico. Aguarde ..."

If oGraphic # Nil .and. cBmpName # Nil .And. File(cRaizServer + cBmpName)
	Ferase(cRaizServer + cBmpName)
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbEnvPrint ³ Autor ³ Wagner Mobile Costa ³ Data ³ 08-11-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta a impressao do Objeto TMsPrinter                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGACTB                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbEnvPrint(oPrint,i,titulo,cProcesso,lLandScape,oGraphic,aTexto,aTabela,;
					 aPosCol,aPosGrh)

Local nx, x
Local lBmp 			:= !( oGraphic == NIL )

Local lin 			:= 2811
Local lFirstPage	:= .T.
Local nTraco		:= 0
Local nMaxLin		:= If(lLandScape, 3120 - 1, 2350 - 1)
Local cRaizServer := If(issrvunix(), "/", "\")

DEFAULT aPosCol	:= { 360, 1300, 2100 }
DEFAULT aPosGrh	:= { 360, 2100, 1700 }
DEFAULT aTexto  := {}
Default aTabela := {}

ProcRegua(Len(aTabela))

If lBmp
	cBmpName := CriaTrab(,.F.)+".BMP"

	oGraphic:SaveToBMP( cBmpName, cRaizServer )
//	IncProc()
Endif

For nx := 2 to Len(aTabela)

//	IncProc()

	If lin > 2810
		If !lFirstPage
			oPrint:Line( ntraco,150,ntraco,nMaxLin )   	// horizontal
		EndIf
		i++
		oPrint:EndPage() 	 				// Finaliza a pagina
		CtbCbcDem(oPrint,titulo,lLandScape)	// Funcao que monta o cabecalho de Demonstrativos
		Lin := 250

		If Len(aTabela) > 1
			oPrint:Line( lin,150,lin+50, 150 )   		// vertical
			For x := 1 to Len(aTexto)
				oPrint:Say(Lin,aPosCol[1],aTexto[x],oCouNew08N)
				If x > 1
					lin +=47
				Endif
			Next

			oPrint:Line( lin, nMaxLin,lin+50,nMaxLin)		// Separador vertical
			oPrint:Line( lin + 35, 150,lin+35,nMaxLin)	// Separador Horizontal
			lin +=47

			oPrint:Line( lin,150,lin+50, 150 )   		// vertical
			For x := 1 to Len(aTabela[1])
				oPrint:Say(Lin,aPosCol[x],aTabela[1,x],oCouNew08N)
			Next

			oPrint:Line( lin, nMaxLin,lin+50,nMaxLin)		// Separador vertical
			oPrint:Line( lin + 35, 150,lin+35,nMaxLin)	// Separador Horizontal
			lin +=47
		EndIf

		lFirstPage := .F.
	End

	oPrint:Line( lin,150,lin+50, 150 )   		// vertical

	For x := 1 to Len(aTabela[nx])
		oPrint:Say(Lin,aPosCol[x],aTabela[nx,x],oFont08)
	Next

	oPrint:Line( lin, nMaxLin,lin+50,nMaxLin)		// Separador vertical

	lin +=47

	nTraco := lin + 1
Next

If (lin + aPosGrh[3] + 77) > 2810
	If !lFirstPage
		oPrint:Line( ntraco,150,ntraco,nMaxLin )   	// horizontal
	EndIf
	i++
	oPrint:EndPage() 	 				// Finaliza a pagina
	CtbCbcDem(oPrint,titulo,lLandScape)	// Funcao que monta o cabecalho de Demonstrativos
	Lin := 250
Endif

oPrint:SayBitmap(lin+60,aPosGrh[1], cRaizServer + cBmpName, aPosGrh[2], aPosGrh[3])
oPrint:Line(lin,150,lin + aPosGrh[3] + 77,150)
oPrint:Line(lin,nMaxLin,lin + aPosGrh[3] + 77, nMaxLin)   	// Vertical

lin += (aPosGrh[3] + 77)

oPrint:Line(lin,150,lin,nMaxLin)   	// Horizontal

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbDescMoeda³ Autor ³ Wagner Mobile Costa  ³ Data ³ 28.04.2002		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a descricao do campo retornado esta em branco     		³±±
±±³          ³ E em caso afirmativo retorna a descricao da primeira moeda 			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbDescMoeda(cCpoDescricao)                                   	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb                                                   			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Campo para retorno da descricao (Macro-Substituicao)    		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function CtbDescMoeda(cCpoDescricao)

Local cDescricao := If( Empty((cDescricao := &(cCpoDescricao))), ;
							&(Subs(cCpoDescricao, 1, Len(cCpoDescricao) - 2) + "01"), ;
							cDescricao )
Return( cDescricao )


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CtbVlrMoed ³ Autora³ Simone Mie Sato     ³ Data ³ 22.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Recupera o valor em outras moedas.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbVlrMoed()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nValor                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dData	  = Data do Lancamento                            ³±±
±±³          ³ cLote	  = Lote           	                              ³±±
±±³          ³ cSublote   = SubLote                                       ³±±
±±³          ³ cDoc       = Documento                                     ³±±
±±³          ³ cLinha     = Numero da Linha                               ³±±
±±³          ³ cTpSald    = Tipo do Saldo                                 ³±±
±±³          ³ cMoeda     = Moeda                                         ³±±
±±³          ³ cEmpOri    = Empresa Origem                                ³±±
±±³          ³ cFilOri    = Filial Origem                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbVlrMoed(dData,cLote,cSubLote,cDoc,cLinha,cTpSald,cMoeda,cEmpOri,cFilOri)

Local aSaveArea	:= GetArea()
Local nValor	:= 0

dbSelectArea("CT2")
dbSetOrder(1)
If MsSeek(xFilial()+dtos(dData)+cLote+cSubLote+cDoc+cLinha+cTpSald+cEmpOri+cFilOri+cMoeda)
	nValor	:= CT2->CT2_VALOR
EndIf

RestArea(aSaveArea)
Return(nValor)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtbSinalMov³ Autor ³ Wagner Mobile Costa  ³ Data ³ 18.10.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna se deve demonstrar o sinal de acordo com MV_TPVALOR³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbSinalMov()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cConta = Conta                                             ³±±
±±³          ³ cDigito = Digito Verificador                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbSinalMov

Return SuperGetMv("MV_TPVALOR") $ "C/D"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o	  ³ ImpQuadro³ Autor ³ Lucimara Soares	     ³ Data ³ 29/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Impressao dos Quadros finais do balancete                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ ImpQuadro()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	      ³ SIGACTB 																															³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ImpQuadro(Tamanho,lDigVer,dData,cMoeda,aQuadro,cDescMoeda,nomeprog,dDataLP,cPicture,nDecimais,lPrintZero,cTpSald,oReport)

Local cData 	:=	StrZero(Month(dData),2) +"/" + Str(Year(dData),4)
Local nTotMov	:=	0
Local nResult	:=	0
Local nPtmCorr := 0
Local	nPtmLiq  := 0
Local nReceita := 0
Local nDespesa := 0
Local nVal1		:= 0
Local nVal2		:= 0
Local lReport  := IIF(oReport == NIL,.F.,.T.)

#DEFINE RCOL_01		30
#DEFINE RCOL_02		800
#DEFINE RCOL_03		1600
#DEFINE RCOL_TIT		300
#DEFINE RCOL_SBTIT		100

If !lReport

	Cabec1 := OemToAnsi(STR0010) // "QUADROS DEMONSTRATIVOS"
	Cabec2 := " "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quadro 1: Totais do Ativo / Passivo.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, 15 )
	CtCGCCabec(,,,Cabec1,Cabec2,dData,Titulo,,"2",Tamanho)

	li++

	@li,00 PSAY "+" + Repl( "-", 100 ) + "+"
	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++
	@li,00 PSAY "|" + PadC( OemToAnsi(STR0011) , 100, " " ) + "|" // "TOTAIS DO ATIVO / PASSIVO"
	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++
	@li,00 PSAY "+" + Repl( "-", 100 ) + "|"
	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++

	DbSelectArea("CT1")
	dbSeek( cFilial + aQuadro[1] ) // Totalizadora do Ativo - mv _par08
	@li,00 PSAY "|"
	If lDigVer
		@li,02 PSAY Mascara(Alltrim(aQuadro[1])+CT1->CT1_DC)
	Else
		@li,02 PSAY Mascara(CT1->CT1_CONTA)
	EndIf

	@li,035 PSAY OemToAnsi(STR0012) // "Total do Ativo"

	dbSelectArea("cArqTmp")
	dbSetOrder(1)
	If dbSeek(aQuadro[1])
		nTotMov	:= SALDOATU
		ValorCTB(nTotMov,li,80,17,nDecimais,.T.,cPicture,"1", , , , , ,lPrintZero)
	EndIf
	@li,101 PSAY "|"

	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++

	DbSelectArea("CT1")
	dbSeek( cFilial + aQuadro[2]) // Totalizadora do Passivo - mv_par09
	@li,00 PSAY "|"
	If lDigVer
		@li,02 PSAY Mascara(Alltrim(CT1->CT1_CONTA)+CT1->CT1_DC)
	Else
		@li,02 PSAY Mascara(CT1->CT1_CONTA)
	EndIf

	@li,35 PSAY OemToAnsi(STR0013) // "Total do Passivo"
	dbSelectArea("cArqTmp")
	dbSetOrder(1)
	If dbSeek(aQuadro[2])
		nTotMov	:= SALDOATU
		ValorCTB(nTotMov,li,80,17,nDecimais,.T.,cPicture,"2", , , , , ,lPrintZero)
	EndIf
	@li,101 PSAY "|"

	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++
	@li,00 PSAY "+" + Repl( "-", 100 ) + "+"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quadro 2: Demonstracao de resultados                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	li += 4

	@li,00 PSAY "+" + Repl( "-", 100 ) + "+"
	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++
	@li,00 PSAY "|" + PadC( OemToAnsi(STR0014) , 100, " " ) + "|" // "DEMONSTRATIVO DE RESULTADOS - MENSAL"
	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++
	@li,00 PSAY "+" + Repl( "-", 100 ) + "|"
	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++

	DbSelectArea("CT1")
	dbSeek( cFilial + aQuadro[3] ) // Resultado a debito

	@li,00 PSAY "|"
	If lDigVer
		@li,02 PSAY Mascara(Alltrim(CT1->CT1_CONTA)+CT1->CT1_DC)
	Else
		@li,02 PSAY Mascara(CT1->CT1_CONTA)
	EndIf
	@li,35 PSAY OemToAnsi(STR0015) + " " + OemToAnsi(STR0016) // "CONTAS DE RESULTADO - "##"DEVEDORA
	DbSelectArea("cArqTmp")
	DbSetOrder(1)
	If DbSeek(aQuadro[3])
		nTotMov	:= MOVIMENTO
		nVal1 	:= SALDOATU
		ValorCTB(nTotMov,li,80,17,nDecimais,.T.,cPicture,"1", , , , , ,lPrintZero)
	Endif
	nResult := nTotMov

	@li,101 PSAY "|"

	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++

	DbSelectArea("CT1")
	dbSeek( cFilial + aQuadro[4] ) // Resultado a credito

	@li,00 PSAY "|"
	If lDigVer
		@li,02 PSAY Mascara(Alltrim(CT1->CT1_CONTA)+CT1->CT1_DC)
	Else
		@li,02 PSAY Mascara(CT1->CT1_CONTA)
	EndIf
	@li,35 PSAY OemToAnsi(STR0015) + " "  + OemToAnsi(STR0017) // "CONTAS DE RESULTADO - "##CREDORA
	DbSelectArea("cArqTmp")
	DbSetOrder(1)
	If DbSeek(aQuadro[4])
		nTotMov	:= MOVIMENTO
		nVal2	:= SALDOATU
		ValorCTB(nTotMov,li,80,17,nDecimais,.T.,cPicture,"2", , , , , ,lPrintZero)
	Else
		nTotMov	:= 0
	Endif
	nResult	+= nTotMov

	DbSelectArea("CT1")
	@li,101 PSAY "|"

	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++

	@li,00 PSAY "|"
	@li,02 PSAY OemToAnsi(STR0018) + " " + cData // "RESULTADO DO MES "

	ValorCTB(nResult,li,80,17,nDecimais,.T.,cPicture,"1", , , , , ,lPrintZero)
	@li,101 PSAY "|"

	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++

	@li,00 PSAY "|"
	@li,02 PSAY OemToAnsi(STR0019)+ " " + cData  // "RESULTADO ACUMULADO ATE "
	nTotMov	:= nVal1+nVal2
	ValorCTB(nTotMov,li,80,17,nDecimais,.T.,cPicture,"1", , , , , ,lPrintZero)
	@li,101 PSAY "|"

	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++
	@li,00 PSAY "+" + Repl( "-", 100 ) + "+"


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quadro 3: Demonstracao de Patrimonio Liquido destacado       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	Cabec( Titulo, Cabec1, Cabec2, NomeProg, Tamanho, 15 )
	CtCGCCabec(,,,Cabec1,Cabec2,dData,Titulo,,"2",Tamanho)

	@li,00 PSAY "+" + Repl( "-", 100 ) + "+"
	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++
	@li,00 PSAY "|" + ;
			 PadC( OemToAnsi(STR0020), 100, " " ) + "|" // "DEMONSTRACAO DO PATRIMONIO LIQUIDO DESTACADO"

	li++
	@li,00 PSAY "|" + PadC( OemToAnsi(STR0021) + " " + cData, 100, " " ) + "|" // "PARA O MES "

	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++
	@li,00 PSAY "+" + Repl( "-", 100 ) + "|"
	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura a conta de patrimonio Liquido.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSeek( cFilial + aQuadro[5] )

	@ li,00 PSAY OemToAnsi(STR0022) // "| PATRIMONIO LIQUIDO"
	DbSelectArea("cArqTmp")
	DbSetOrder(1)
	If DbSeek(aQuadro[5])
		nPtmLiq := SALDOATU
		ValorCTB(nPtmLiq,li,80,17,nDecimais,.T.,cPicture,"2", , , , , ,lPrintZero)
	Endif
	DbSelectArea("CT1")
	@ li,101 PSAY "|"

	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura a conta de receita.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSeek( cFilial + aQuadro[6] )

	@li,00 PSAY OemToAnsi(STR0023) // "| TOTAL DA RECEITA"
	DbSelectArea("cArqTmp")
	DbSetOrder(1)
	If DbSeek(aQuadro[6])
	   nReceita := SALDOATU
		ValorCTB(nReceita,li,80,17,nDecimais,.T.,cPicture,"2", , , , , ,lPrintZero)
	Endif
	DbSelectArea("CT1")
	@li,101 PSAY "|"

	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura a conta de despesa.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSeek( cFilial + aQuadro[7] )

	@li,00 PSAY OemToAnsi(STR0024) // "| TOTAL DA DESPESA"
	DbselectArea("cArqTmp")
	DbSetOrder(1)
	If DbSeek(aQuadro[7])
		nDespesa := SALDOATU
		ValorCTB(nDespesa,li,80,17,nDecimais,.T.,cPicture,"1", , , , , ,lPrintZero)
	Endif
	DbSelectArea("CT1")
	@li,101 PSAY "|"

	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o patrimonio liquido corrigido.                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPtmCorr := nPtmLiq + nReceita + nDespesa
	@li,00 PSAY OemToAnsi(STR0025+ " ")+cData // "| PATRIMONIO LIQUIDO CORRIGIDO " + cData
	ValorCTB(nPtmCorr,li,80,17,nDecimais,.T.,cPicture,"2", , , , , ,lPrintZero)
	@li,101 PSAY "|"

	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula Lancamento de Correcao		                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLctoCorr := nReceita + nDespesa
	@li,00 PSAY OemToAnsi(STR0026) // "| LANCAMENTO DE CORRECAO"
	ValorCTB(nLctoCorr,li,80,17,nDecimais,.T.,cPicture,"2", , , , , ,lPrintZero)
	@li,101 PSAY "|"

	li++
	@li,00 PSAY "|" + Repl( " ", 100 ) + "|"
	li++
	@li,00 PSAY "|" + Repl( "-", 100 ) + "|"
	li++

Else
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao dos quadros para relatorios relese 4.                                           ³
//³                                                                                                    ³
//³Deve-se passar o objeto oReport para utilizar esta função.                                          ³
//³                                                                                                    ³
//³Não esquecer de desabilitar a impressão do Header da Section principal antes de imprimir os quadros.³
//³                                                                                                    ³
//³Exemplo da chamada da função que esta no fonte CTBR060():                                           ³
//³                                                                                                    ³
//³If mv_par25 ==1                                                                                     ³
//³     oReport:Section(1):SetHeaderSection(.F.)                                                       ³
//³     ImpQuadro(,,,,,,oReport:ClassName(),,,,,,oReport)                                              ³
//³EndIf	                                                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oReport:EndPage(.T.) // Quebra direto

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quadro 1: Totais do Ativo / Passivo.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SkipLine()

	oReport:PrintText(OemToAnsi(STR0010),,RCOL_TIT) 	// "QUADROS DEMONSTRATIVOS"

	oReport:SkipLine()
	oReport:ThinLine()
	oReport:SkipLine()

	oReport:PrintText(OemToAnsi(STR0011),,RCOL_SBTIT)// "TOTAIS DO ATIVO / PASSIVO"

	oReport:SkipLine()
	oReport:ThinLine()
	oReport:SkipLine()

	DbSelectArea("CT1")
	dbSeek( cFilial + aQuadro[1] ) // Totalizadora do Ativo - mv _par08

	oReport:PrintText(IIF(lDigVer,Mascara(Alltrim(aQuadro[1])+CT1->CT1_DC),Mascara(CT1->CT1_CONTA)),oReport:Row(),RCOL_01)

	oReport:PrintText(OemToAnsi(STR0012),oReport:Row(),RCOL_02) 	// "Total do Ativo"

	dbSelectArea("cArqTmp")
	dbSetOrder(1)
	If dbSeek(aQuadro[1])
		nTotMov	:= cArqTmp->SALDOATU
		oReport:PrintText(ValorCTB(nTotMov,,,17,2,.T.,cPicture,"1",,,,,,Iif(mv_par19==1,.T.,.F.),.F.),oReport:Row(),RCOL_03)
	EndIf

	oReport:SkipLine()
	oReport:SkipLine()

	DbSelectArea("CT1")
	dbSeek( cFilial + aQuadro[2]) // Totalizadora do Passivo - mv_par09
	oReport:PrintText(IIF (lDigVer,Mascara(Alltrim(CT1->CT1_CONTA)+CT1->CT1_DC),Mascara(CT1->CT1_CONTA)),oReport:Row(),RCOL_01)

	oReport:PrintText(OemToAnsi(STR0013),oReport:Row(),RCOL_02 )// "Total do Passivo"

	dbSelectArea("cArqTmp")
	dbSetOrder(1)
	If dbSeek(aQuadro[2])
		nTotMov	:= cArqTmp->SALDOATU
		oReport:PrintText(ValorCTB(nTotMov,,,17,2,.T.,cPicture,"2",,,,,,Iif(mv_par19==1,.T.,.F.),.F.),oReport:Row(),RCOL_03)
	EndIf

	oReport:SkipLine()
	oReport:SkipLine()

	oReport:ThinLine()

	oReport:SkipLine()
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:SkipLine()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quadro 2: Demonstracao de resultados                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oReport:SkipLine()
	oReport:ThinLine()
	oReport:SkipLine()

	oReport:PrintText(OemToAnsi(STR0014),,RCOL_SBTIT)// "DEMONSTRATIVO DE RESULTADOS - MENSAL"

	oReport:SkipLine()
	oReport:ThinLine()
	oReport:SkipLine()

	DbSelectArea("CT1")
	dbSeek( cFilial + aQuadro[3] ) // Resultado a debito

	oReport:PrintText(IIF(lDigVer,Mascara(Alltrim(CT1->CT1_CONTA)+CT1->CT1_DC),Mascara(CT1->CT1_CONTA)),oReport:Row(),RCOL_01 )

	oReport:PrintText(OemToAnsi(STR0015) + " " + OemToAnsi(STR0016),oReport:Row(),RCOL_02  ) // "CONTAS DE RESULTADO - "

	DbSelectArea("cArqTmp")
	DbSetOrder(1)
	If DbSeek(aQuadro[3])
		nTotMov	:= cArqTmp->MOVIMENTO
		nVal1 	:= cArqTmp->SALDOATU
		oReport:PrintText(ValorCTB(nTotMov,,,17,2,.T.,cPicture,"1",,,,,,Iif(mv_par19==1,.T.,.F.),.F.),oReport:Row(),RCOL_03)
	Endif
	nResult := nTotMov

	oReport:SkipLine()
	oReport:SkipLine()

	DbSelectArea("CT1")
	dbSeek( cFilial + aQuadro[4] ) // Resultado a credito

	oReport:PrintText(IIF(lDigVer,Mascara(Alltrim(CT1->CT1_CONTA)+CT1->CT1_DC),Mascara(CT1->CT1_CONTA)),oReport:Row(), 30 )

	oReport:PrintText(OemToAnsi(STR0015) + " " + OemToAnsi(STR0017),oReport:Row(),RCOL_02  ) // "CONTAS DE RESULTADO - "

	DbSelectArea("cArqTmp")
	DbSetOrder(1)
	If DbSeek(aQuadro[4])
		nTotMov	:= cArqTmp->MOVIMENTO
		nVal2	:= cArqTmp->SALDOATU
		oReport:PrintText(ValorCTB(nTotMov,,,17,2,.T.,cPicture,"2",,,,,,Iif(mv_par19==1,.T.,.F.),.F.),oReport:Row(),RCOL_03)
	Else
		nTotMov	:= 0
	Endif
	nResult	+= nTotMov

	oReport:SkipLine()
	oReport:SkipLine()

	DbSelectArea("CT1")

	oReport:PrintText(OemToAnsi(STR0018) + " " + cData,oReport:Row(),RCOL_01) // "RESULTADO DO MES "

	oReport:PrintText(ValorCTB(nResult,,,17,2,.T.,cPicture,"1",,,,,,Iif(mv_par19==1,.T.,.F.),.F.),oReport:Row(),RCOL_03)

	oReport:SkipLine()
	oReport:SkipLine()

	oReport:PrintText(OemToAnsi(STR0019) + " " + cData,oReport:Row(),RCOL_01) // "RESULTADO ACUMULADO ATE "

	nTotMov	:= nVal1+nVal2
	oReport:PrintText(ValorCTB(nTotMov,,,17,2,.T.,cPicture,"1",,,,,,Iif(mv_par19==1,.T.,.F.),.F.),oReport:Row(),RCOL_03)

	oReport:SkipLine()
	oReport:SkipLine()

	oReport:ThinLine()

	oReport:SkipLine()
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:SkipLine()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quadro 3: Demonstracao de Patrimonio Liquido destacado       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oReport:SkipLine()
	oReport:ThinLine()
	oReport:SkipLine()

	oReport:PrintText(OemToAnsi(STR0020),,RCOL_SBTIT)// "DEMONSTRACAO DO PATRIMONIO LIQUIDO DESTACADO"
	oReport:PrintText(OemToAnsi(STR0021) + " " + cData,,RCOL_SBTIT)// "PARA O MES "

	oReport:SkipLine()
	oReport:ThinLine()
	oReport:SkipLine()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura a conta de patrimonio Liquido.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSeek( cFilial + aQuadro[5] )

	oReport:PrintText(OemToAnsi(SUBS(STR0022,3)),oReport:Row(),RCOL_01)// "| PATRIMONIO LIQUIDO"

	DbSelectArea("cArqTmp")
	DbSetOrder(1)
	If DbSeek(aQuadro[5])
		nPtmLiq := cArqTmp->SALDOATU
		oReport:PrintText(ValorCTB(nPtmLiq,,,17,2,.T.,cPicture,"2",,,,,,Iif(mv_par19==1,.T.,.F.),.F.),oReport:Row(),RCOL_03)
	Endif
	DbSelectArea("CT1")

	oReport:SkipLine()
	oReport:SkipLine()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura a conta de receita.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSeek( cFilial + aQuadro[6] )

	oReport:PrintText(OemToAnsi(SUBS(STR0023,3)),oReport:Row(),RCOL_01)// "| TOTAL DA RECEITA"

	DbSelectArea("cArqTmp")
	DbSetOrder(1)
	If DbSeek(aQuadro[6])
		nReceita := cArqTmp->SALDOATU
		oReport:PrintText(ValorCTB(nReceita,,,17,2,.T.,cPicture,"2",,,,,,Iif(mv_par19==1,.T.,.F.),.F.),oReport:Row(),RCOL_03)
	Endif
	DbSelectArea("CT1")

	oReport:SkipLine()
	oReport:SkipLine()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura a conta de despesa.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSeek( cFilial + aQuadro[7] )

	oReport:PrintText(OemToAnsi(SUBS(STR0024,3)),oReport:Row(),RCOL_01)// "| TOTAL DA DESPESA"

	DbselectArea("cArqTmp")
	DbSetOrder(1)
	If DbSeek(aQuadro[7])
		nDespesa := cArqTmp->SALDOATU
		oReport:PrintText(ValorCTB(nDespesa,,,17,2,.T.,cPicture,"1",,,,,,Iif(mv_par19==1,.T.,.F.),.F.),oReport:Row(),RCOL_03)
	Endif
	DbSelectArea("CT1")

	oReport:SkipLine()
	oReport:SkipLine()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o patrimonio liquido corrigido.                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPtmCorr := nPtmLiq + nReceita + nDespesa

	oReport:PrintText(OemToAnsi(SUBS(STR0025+ " ",3))+cData,oReport:Row(),RCOL_01)// "| PATRIMONIO LIQUIDO CORRIGIDO " + cData

	oReport:PrintText(ValorCTB(nPtmCorr,,,17,2,.T.,cPicture,"2",,,,,,Iif(mv_par19==1,.T.,.F.),.F.),oReport:Row(),RCOL_03)

	oReport:SkipLine()
	oReport:SkipLine()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula Lancamento de Correcao		                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLctoCorr := nReceita + nDespesa

	oReport:PrintText(OemToAnsi(SUBS(STR0026,3)),oReport:Row(),RCOL_01)// "| LANCAMENTO DE CORRECAO"

	oReport:PrintText(ValorCTB(nLctoCorr,,,17,2,.T.,cPicture,"2",,,,,,Iif(mv_par19==1,.T.,.F.),.F.),oReport:Row(),RCOL_03)

	oReport:SkipLine()
	oReport:ThinLine()
	oReport:SkipLine()

EndIf

Return

/* Modo de construcao do quadro 3 - conforme analise SBPS
1 - Patrimonio liquido
6.0.0.00.00.2

2 - Receita
7.0.0.00.00.9

3 - Despesa
8.0.0.00.00.6

4 - Patrimonio Liquido corrigido ate a data
1 + 2 + 3

6 - Lancamento de correcao
1 + ( 2 + 3 )
*/


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbCarTxt   ³ Autor ³ Lucimara Soares      ³ Data ³ 02.12.2002			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega o arquivo TXT. Caso o arquivo não exista, a função o cria.	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbCarTxt(aMatriz)                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb                                               	    			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aGrava	   = Matriz utilizada para gravar o arquivo Txt 	         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

FUNCTION CtbCarTxt(aGrava)

Local aSaveArea	:= GetArea()
Local nBytes := 0
Local nTamArq
Local xBuffer
Local nLinha := 0

//Caso a matriz esteja nula, eu leio o CTBQUAD.INI
If aGrava == Nil 

	IF !file("CTBQUADR.INI")
		nHdlQuad := MSFCreate("CTBQUADR.INI",0)
		IF nHdlQuad == -1
			HELP(" ",1,"CTB_ERROR")
			Final("Erro F_"+str(ferror(),2)+" em CTBQUADR.INI")
		Endif
		Fclose(nHdlQuad)
	EndIf

	nHdlQuad := FOPEN("CTBQuadr.INI",70)

	If nHdlQuad <0
		HELP(" ",1,"CTB_ERROR")
		Final("CTBQUADR.INI")
	EndIf

	nTamArq:=FSEEK(nHdlQuad,0,2)		// VerIfica tamanho do arquivo
	FSEEK(nHdlQuad,0,0)					// Volta para inicio do arquivo

	While nBytes<nTamArq
		xBuffer:=Space(72)
		FREAD(nHdlQuad,@xBuffer,72)
		nLinha++
		If nLinha <= Len(aQuadro)
			aQuadro[nLinha]:= Left(Alltrim(xBuffer), Len(CriaVar("CT1_CONTA")))
		Endif
		nBytes+=72
//		Dbskip()
	EndDo
Else
	nHdlQuad := MSFCreate("CTBQUADR.INI",0)
	IF nHdlQuad == -1
		HELP(" ",1,"CTB_ERROR")
		Final("Erro F_"+str(ferror(),2)+" em CTBQUADR.INI")
	Endif

	For nLinha:=1 To Len(aGrava)
		fWrite(nHdlQuad,Left(aGrava[nLinha] + Space(70), 70) +chr(13)+chr(10))
	Next

EndIf

fClose(nHdlQuad)
RestArea(aSaveArea)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbOpQuad   ³ Autor ³ Lucimara Soares      ³ Data ³ 06.12.2002			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a tela com as perguntas referentes aos quadros contabeis.  		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbOpQuad(lDigita)                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb                                                   				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lDigita	   = Define se alguma digitação foi feita.    			    	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbOpQuad(lDigita)


Local nOpca 	:= 1

Local cPerg1	:= STR0027 + "?"	//Conta Tot. Ativo
Local cPerg2	:= STR0028 + "?"  //Conta Tot. Passivo
Local cPerg3	:= STR0029 + "?"  //Conta Tot. Resultado a Débito
Local cPerg4	:= STR0030 + "?"  //Conta Tot. Resultado a Crédito
Local cPerg5	:= STR0031 + "?"  //Conta Tot. Patrimônio Líquido
Local cPerg6	:= STR0032 + "?"  //Conta Tot. das Receitas
Local cPerg7	:= STR0033 + "?"  //Conta Tot. das Despesas
Local cPerg8	:= STR0034 + "?"  //Conta Tot. PL Corrigido

Local cF3 := "CT1"

If !lDigita
	Return
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0035) FROM 33,25 TO 300,410 PIXEL  //"Config. Parametros"
	@ 001,005 TO 130, 185 OF oDlg PIXEL
	@ 004,008 	SAY cPerg1 SIZE 90, 7 OF oDlg PIXEL
	@ 004,096 	MSGET aQuadro[1]Pict "@!";
					F3 cF3 	SIZE 50,10 OF oDlg PIXEL ;

	@ 019,008 	SAY cPerg2 SIZE 90, 7 OF oDlg PIXEL
	@ 019,096 	MSGET aQuadro[2]Pict "@!";
					F3 cF3 SIZE 50,10 OF oDlg PIXEL

	@ 034,008 	SAY cPerg3 SIZE 90, 7 OF oDlg PIXEL
	@ 034,096 	MSGET aQuadro[3]Pict "@!";
					F3 cF3 SIZE 50,10 OF oDlg PIXEL

	@ 049,008 	SAY cPerg4 SIZE 90, 7 OF oDlg PIXEL
	@ 049,096 	MSGET aQuadro[4]Pict "@!";
					F3 cF3 SIZE 50,10 OF oDlg PIXEL

	@ 064,008 	SAY cPerg5 SIZE 90, 7 OF oDlg PIXEL
	@ 064,096 	MSGET aQuadro[5]Pict "@!";
					F3 cF3 SIZE 50,10 OF oDlg PIXEL

	@ 079,008 	SAY cPerg6 SIZE 90, 7 OF oDlg PIXEL
	@ 079,096 	MSGET aQuadro[6]Pict "@!";
					F3 cF3 SIZE 50,10 OF oDlg PIXEL

	@ 094,008 	SAY cPerg7 SIZE 90, 7 OF oDlg PIXEL
	@ 094,096 	MSGET aQuadro[7]Pict "@!";
					F3 cF3 SIZE 50,10 OF oDlg PIXEL

	@ 109,008 	SAY cPerg8 SIZE 90, 7 OF oDlg PIXEL
	@ 109,096 	MSGET aQuadro[8] Pict "@!";
					F3 cF3 SIZE 50,10 OF oDlg PIXEL


	DEFINE SBUTTON FROM 05, 156 TYPE 1 ACTION (nOpca := 1,oDlg:End())ENABLE OF oDlg

	DEFINE SBUTTON FROM 18, 156 TYPE 2 ACTION (nOpca:=0,oDlg:End()) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)	// Zero nOpca caso
                                                               //	para saida com ESC

If nOpcA = 1
	CtbCarTxt(aQuadro)
Endif


Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbTxtGer   ³ Autor ³ Lucimara Soares      ³ Data ³ 26.03.2003		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega o arquivo TXT com os valores do filtro por Plano Gerencial	³±±
±±³			 ³Caso o arquivo não exista, a função o cria.							³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbTxtGer(aMatriz)                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb                                               	    		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aGrava	   = Matriz utilizada para gravar o arquivo Txt 	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

FUNCTION CtbTxtGer(aGrava)

Local nBytes := 0
Local nTamArq
Local xBuffer
Local nLinha := 0


//Caso a matriz esteja nula, eu leio o CTBGEREN.INI
If aGrava == Nil

	IF !file("CTBGEREN.INI")
		nHdlGer := MSFCreate("CTBGEREN.INI",0)
		IF nHdlGer == -1
			HELP(" ",1,"CTB_ERROR")
			Final("Erro F_"+str(ferror(),2)+" em CTBGEREN.INI")
		Endif
		Fclose(nHdlGer)
	EndIf

	nHdlGer := FOPEN("CTBGEREN.INI",64)

	If nHdlGer <0
		HELP(" ",1,"CTB_ERROR")
		Final("CTBGEREN.INI")
	EndIf

	nTamArq:=FSEEK(nHdlGer,0,2)		// VerIfica tamanho do arquivo
	FSEEK(nHdlGer,0,0)					// Volta para inicio do arquivo

	While nBytes<nTamArq
		xBuffer:=Space(72)
		FREAD(nHdlGer,@xBuffer,72)
		nLinha++
		If nLinha <= Len(aGeren)
			aGeren[nLinha]:= PadR(xBuffer,Len(CriaVar("CT1_CONTA")) )
		Endif
		nBytes+=70
		If cPaisLoc == "RUS"
			FT_FSkip()
		EndIf
	EndDo
Else
	nHdlGer := MSFCreate("CTBGEREN.INI",0)
	IF nHdlGer == -1
		HELP(" ",1,"CTB_ERROR")
		Final("Erro F_"+str(ferror(),2)+" em CTBGEREN.INI")
	Endif

	For nLinha:=1 To Len(aGrava)
		fWrite(nHdlGer,Left(aGrava[nLinha] + Space(70), 70) +chr(13)+chr(10))
	Next

EndIf

fClose(nHdlGer)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbOpGeren  ³ Autor ³ Lucimara Soares      ³ Data ³ 26.03.2003		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a tela com as perguntas referentes ao filtro por Pl. Gerencial ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbOpGeren(lDigita)                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaCtb                                                   			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lDigita	   = Define se alguma digitação foi feita.    			   	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbOpGeren(lDigita)


Local nOpca 	:= 1

Local cPerg1	:= STR0036 + "?"  //Da Conta
Local cPerg2	:= STR0037 + "?"  //Ate a Conta
Local cPerg3	:= STR0038 + "?"  //Do Centro de Custo
Local cPerg4	:= STR0039 + "?"  //Ate o Centro de Custo
Local cPerg5	:= STR0040 + "?"  //Do Item
Local cPerg6	:= STR0041 + "?"  //Ate o Item
Local cPerg7	:= STR0042 + "?"  //Da Classe de Valor
Local cPerg8	:= STR0043 + "?"  //Ate a Classe de Valor

Local cF3Conta	:= "CT1"
Local cF3Custo	:= "CTT"
Local cF3Item	:= "CTD"
Local cF3CLVL	:= "CTH"

If !lDigita
	Return
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0035) FROM 33,25 TO 300,410 PIXEL  //"Config. Parametros"
	@ 001,005 TO 130, 190 OF oDlg PIXEL
	@ 004,008 	SAY cPerg1 SIZE 90, 7 OF oDlg PIXEL
	@ 004,096 	MSGET aGeren[1] Pict "@!";
					F3 cF3Conta 	SIZE 50,10 OF oDlg PIXEL ;

	@ 019,008 	SAY cPerg2 SIZE 90, 7 OF oDlg PIXEL
	@ 019,096 	MSGET aGeren[2] Pict "@!";
					F3 cF3Conta SIZE 50,10 OF oDlg PIXEL

	@ 034,008 	SAY cPerg3 SIZE 90, 7 OF oDlg PIXEL
	@ 034,096 	MSGET aGeren[3] Pict "@!";
					F3 cF3Custo SIZE 50,10 OF oDlg PIXEL

	@ 049,008 	SAY cPerg4 SIZE 90, 7 OF oDlg PIXEL
	@ 049,096 	MSGET aGeren[4] Pict "@!";
					F3 cF3Custo SIZE 50,10 OF oDlg PIXEL

	@ 064,008 	SAY cPerg5 SIZE 90, 7 OF oDlg PIXEL
	@ 064,096 	MSGET aGeren[5] Pict "@!";
					F3 cF3Item SIZE 50,10 OF oDlg PIXEL

	@ 079,008 	SAY cPerg6 SIZE 90, 7 OF oDlg PIXEL
	@ 079,096 	MSGET aGeren[6] Pict "@!";
					F3 cF3Item SIZE 50,10 OF oDlg PIXEL

	@ 094,008 	SAY cPerg7 SIZE 90, 7 OF oDlg PIXEL
	@ 094,096 	MSGET aGeren[7] Pict "@!";
					F3 cF3CLVL SIZE 50,10 OF oDlg PIXEL

	@ 109,008 	SAY cPerg8 SIZE 90, 7 OF oDlg PIXEL
	@ 109,096 	MSGET aGeren[8] Pict "@!";
					F3 cF3CLVL SIZE 50,10 OF oDlg PIXEL


	DEFINE SBUTTON FROM 05, 156 TYPE 1 ACTION (nOpca := 1,oDlg:End())ENABLE OF oDlg

	DEFINE SBUTTON FROM 18, 156 TYPE 2 ACTION (nOpca:=0,oDlg:End()) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)	// Zero nOpca caso
                                                               //	para saida com ESC

If nOpcA = 1
	CtbTxtGer(aGeren)
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbQbPg   ºAutor  ³Marcos S. Lobo      º Data ³  12/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controla a quebra de pagina dos relatorios SIGACTB          º±±
±±º          ³quando possuem os parametros de PAG.INICAL-FINAL-REINICIAR  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro1³ lNewVars  = (.T.=Inicializa variaveis/.F.=Trata Quebra)    º±±
±±º         2³ nPagIni 	 = Pagina Inicial do relatorio.               	  º±±
±±º         3³ nPagFim 	 = Pagina Final do relatorio               	 	  º±±
±±º         4³ nReinicia = Pagina ao Reiniciar do relatorio               º±±
±±º         5³ m_pag 	 = Numero da pagina usada na Cabec()              º±±
±±º         6³ nBloco    = Bloco de paginas (intervalo de quebra)		  º±±
±±º         7³ nBlCount  = Contador de páginas (zerado na qebra de bloco) º±±
±±º         8³ l1StQb    = Indica se irá efetuar uma unica quebra         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbQbPg(lNewVars,nPagIni,nPagFim,nReinicia,m_pag,nBloco,nBlCount,l1StQb)

Local lEmissUnica := If( GetNewPar( "MV_CTBQBPG" , "M" ) == "M" , .T. , .F. ) /// U=Quebra unica (.F.) ; M=Multiplas quebras (.T.)

///As variáveis nPagIni,nPagFim,nReinicia,m_pag,nBloco,nBlCount devem ser declaradas na rotina chamadora
///e na chamada desta função como @<parametro> para obter o retorno após as alterações de conteúdo desta função.
DEFAULT lNewVars := .F.

If lEmissUnica
	If lNewVars					/// INICIALIZA AS VARIAVEIS
		nBloco		:= ( nPagFim + 1 ) - nPagIni 				/// (PAG. FIM + 1) - PAG. INICIAL - BLOCO DE PAG. PARA IMPRESSAO
		m_pag		:= nPagIni
	Else						/// NAO INICIALIZA - TRATA A QUEBRA DE PAGINA

 	nBlCount++

 	If nBlCount > nBloco 							/// SE A QUANTIDADE DE PAGINAS IMPRESSAO FOR IGUAL AO BLOCO DEFINIDO

		If nReinicia > nPagFim						/// SE A PAG. DE REINICIO FOR MAIOR QUE A PAGINA FINAL (ATUAL)
			nUltPg	  := m_pag						/// GUARDA A ULTIMA PAG. IMPRESSA
			m_pag 	  := nReinicia					/// REINICIA A NUMERACAO DE PAG. (m_pag atual ainda não foi)
			nPagFim   := nReinicia+nBloco 			/// DEFINE O NOVO NUMERO DA PAGINA FIM
			nReinicia := nPagFim+(nReinicia-nUltPg)	/// DEFINE A PROX. PAG. AO REINICIAR PELA DIFERENCA COM  FINAL
		Else										/// SE A PAG. DE REINICIO FOR MENOR OU IGUAL A PAGINA FINAL
			m_pag := nReinicia						/// SO REINICIA A NUMERACAO DE PAG.
		Endif

		nBlCount := 1
	EndIf

Endif
ELSE
	IF lNewVars
		m_pag := nPagIni
	Endif

  	If m_pag > nPagFim .and. l1stQb
		m_pag := nReinicia
		l1StQb := .F.
	Endif

ENDIF

lNewVars := .F.

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CabRelPer  ³ Autor ³TOTVS                 ³ Data ³ 16/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Monta Cabecalho do relatorio - Livro Diario                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³CabRelPer(Titulo,oReport)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³Arg1  = Indica se imprime item							   ³±±
±±³           ³Arg2  = Indica se imprime c.custo						   ³±±
±±³           ³Arg3  = Indica se imprime classe de valor				   ³±±
±±³           ³Arg4  = Conteudo da cabec1               				   ³±±
±±³           ³Arg5  = Conteudo da cabec2               				   ³±±
±±³           ³Arg6  = Data final do relatorio          				   ³±±
±±³           ³Arg7  = Titulo                           				   ³±±
±±³           ³Arg8  = Indica se imprime analitico      				   ³±±
±±³           ³Arg9  = Tipo                             				   ³±±
±±³           ³Arg10 = Tamanho                          				   ³±±
±±³           ³Arg11 = Retorna titulos                  				   ³±±
±±³           ³Arg12 = Objeto do oReport                   				   ³±±
±±³           ³Arg13 = Nome do programa                   				   ³±±
±±³           ³Os parametros da funcao original ³CtCGCCabec³ foram mantidos³±±
±±³           ³somente para a fins de compatibilidade.     				   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CabRelPer(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,cTipo,Tamanho,aCab,oReport,lCtrlPage,lNewVars,nPagIni,nPagFim,nReinicia,nPag,nBloco,nBlCount,l1StQb,dDataIni,cNomeRel)

Local cNmEmp
Local cChar			:= chr(160)  // caracter dummy para alinhamento do cabeçalho

DEFAULT aCab 		:= {}
DEFAULT lCtrlPage	:= .F. // Controla a numeração de pagina
DEFAULT lNewVars	:= .F.
DEFAULT nPagIni		:= 1
DEFAULT nPagFim		:= 99999
DEFAULT nReinicia	:= 1
DEFAULT nPag		:= 1
DEFAULT nBloco		:= 1
DEFAULT nBlCount	:= 0
DEFAULT l1StQb		:= .F.
DEFAULT dDataIni    := cTod('01/01/04')
DEFAULT cNomeRel:=""

SX3->( DbSetOrder(2) )
SX3->( MsSeek( "A1_CGC" , .t.))

If SM0->(Eof())
	SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
Endif

RptFolha := GetNewPar( "MV_CTBPAG" , RptFolha )

Aadd( aCab, AllTrim( SM0->M0_NOMECOM ))
Aadd( aCab, AllTrim( titulo ) )
Aadd( aCab, Transform( Alltrim( SM0->M0_CGC ), alltrim( SX3->X3_PICTURE )))

If lCtrlPage
	nPag++

	// Renato F. Campos
	// faz o controle de numeração de pagina
	// as variaveis deverão ser declaradas no relatorio como private
	CtbQbPg( @lNewVars, @nPagIni, @nPagFim, @nReinicia, @nPag, @nBloco, @nBlCount, @l1StQb )

	oReport:SetPageNumber( nPag )
Endif

//Protecao para NomeProg nao declarada
If type( 'NomeProg' ) == 'U'
	NomeProg := FunName()
EndIf


cNmEmp	:= AllTrim( SM0->M0_NOMECOM )


aCabec := { 	"__LOGOEMP__"," ";
	        , cNomeRel + cChar;
	 	, " PERIODO   " +  DTOC(dDataIni) + " A " + DTOC(dDataFim) + "         " ;
		, " RUC:" +Alltrim( SM0->M0_CGC );
	        , "APELLIDOS Y NOMBRES, DENOMINACIÓN O RAZÓN SOCIAL: " +  cNmEmp  + "         " ;
           , cChar + "         " + RptFolha + TRANSFORM(oReport:Page(),'999999') }
Return aCabec

//-------------------------------------------------------------------
/*/{Protheus.doc} RedStorTt

Function to calculate the total according to TipoConta and NORMAL

Example: RedStorTt(cArqTmp->SALDODEB,cArqTmp->SALDOCRD,cArqTmp->TIPOCONTA,cArqTmp->NORMAL,"D")

@param		nValDeb = Debit value
			nValCred = Credit value
			cTipoConta = Ledger account Class. It can be:
				1 = Summarized (Total of Values)
				2 = Detailed (Receive Values from Entry)
			cNormal = Ledger Account Normal Condition. It can be:
				1 = Debit Account
				2 = Credit Account
			cDtorTt = Type
				D = Detail of the report
				T = Total of the report
@return		Calculated value
@type 		Function
@author 	Fabio Cazarini
@since 		20/06/2017
@version 	P12/MA3
/*/
//-------------------------------------------------------------------
FUNCTION RedStorTt(nValDeb as Numeric, nValCred as Numeric, cTipoConta as Char, cNormal as Char, cDtorTt as Char)
Local nRet as Numeric

Default nValDeb		:= 0
Default nValCred	:= 0
Default cTipoConta 	:= "2"
Default cNormal 	:= "1"
Default cDtorTt 	:= "T"

nRet := 0

If cTipoConta <> "1"
	If cNormal == "2" .and. cDtorTt == "D"
		nRet := nValCred - nValDeb
	Else
		nRet := nValDeb - nValCred
	Endif
Endif

Return nRet

