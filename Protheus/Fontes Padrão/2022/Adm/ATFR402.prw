#INCLUDE "protheus.ch"
#INCLUDE "ATFR402.ch"
 

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ ATFR402  ∫ Autor ≥ Cristina Barroso   ∫ Data ≥  04/09/09    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Desc.    ≥ Mapa Fiscal modelo 32.1                                     ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function ATFR402()
Local cPerg			:= "ATR402"
Local aArea			:= {}

Private cMoedATF	:= ""
Private cExerc		:= ""
Private oRelATF

//Parametros de perguntas para o relatorio
//+-------------------------------------------------------------------------------------------------+
//| mv_par01 - DATA DE     ? 																		|
//| mv_par02 - DATA ATE    ? 																		|
//| mv_par03 - Natureza    ? corporeo / nao corporeo / abatidos no periodo                          |
//+-------------------------------------------------------------------------------------------------+
aArea := GetArea()
CriaSx1(cPerg)

If Pergunte(cPerg,.T.)
	cExerc := StrZero(Year(MV_PAR02),4)
	cMoedATF := GetMV("MV_ATFMOED")
	oRelATF	:= TMSPrinter():New(STR0001 + " - " + STR0002 + "32.1") //"MAPA"###"MODELO"
	oRelATF:SetLandscape()
	RptStatus({|lEnd| ImpRelATF(@lEnd)},STR0003) //"A imprimir Mapa..."
	oRelATF:Preview()
Endif
RestArea(aArea)
return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ImpRelATF ∫ Autor ≥ Cristina Barroso   ∫ Data ≥  04/09/09    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Desc.    ≥ Impressao do relatorio                                      ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function ImpRelATF(lEnd)
Local cBase			:= ""
Local cItem			:= ""
Local cArqAtivos	:= ""
Local nLin			:= 0
Local nDecs1		:= MsDecimais(1)
Local lImprimir		:= .T.
Local cCpoMoedaF	:= ""
Local cCtaContab	:= ""
/* Totalizadores da conta contabil */
Local nCCTotAquis	:= 0
Local nCCTotExAnt	:= 0
Local nCCTotAmEx	:= 0
Local nCCTotAmAc	:= 0
Local nCCTotNTri	:= 0
Local nCCTotNAce	:= 0
/* colunas do mapa */
Local cCodDecr		:= ""
Local cDescric		:= ""
Local cAnoAqu		:= ""
Local cMesIniUt		:= ""
Local cAnoIniUt		:= ""
Local nValAqu		:= 0
Local nAnosUtil		:= 0
Local nAmorExAnt	:= 0
Local nTxExerc		:= 0
Local nAmortEx		:= 0
Local nAmortAcum	:= 0
Local nTxPerdida	:= 0
Local cAnoValNTri	:= ""
Local nValiaNTri	:= 0
Local nAmortNAc		:= 0
Local lTemMaxDepr   := .f.

Private cPictM1			:= ""
Private cPictM3			:= ""
Private cPictTx			:= ""
Private cPictTxP		:= ""

//Totalizadores
Private nTotValAqu	:= 0
Private nTotAmorAnt	:= 0
Private nTotAmorEx	:= 0
Private nTotAmorAcu	:= 0
Private nTotAmorNAc	:= 0

//Private oFont08		:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
Private oFont08		:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
Private oFont07		:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
//Private oFont10		:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Private oFont08n	:= TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
Private oFont10		:= TFont():New("Arial",8.5,8.5,,.F.,,,,.T.,.F.)
Private oFont10n	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Private oFont11		:= TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)
Private oFont12		:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Private oFont13		:= TFont():New("Arial",13,13,,.F.,,,,.T.,.F.)
Private oFont14		:= TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
Private oFont14a	:= TFont():New("Arial",18,14,,.F.,,,,.T.,.F.)
Private oFont12N	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
Private oFont14N	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
Private oFont24N	:= TFont():New("Arial",24,24,,.T.,,,,.T.,.F.)

Private oBrR := TBrush():New(,RGB(228,224,224),,)		//mesma cor usada no bitmap SOMBRA250.bmp

/*
Descricao do conteudo das colunas do mapa fiscal modelo 32.1
------------------------------------------------------------------------------------------------------------------------------
01	codigo						|N1_GRUPO
------------------------------------------------------------------------------------------------------------------------------
02	descricao					|N1_DESCRIC
------------------------------------------------------------------------------------------------------------------------------
03	ano aquisicao				|ano da data no campo N3_AQUISIC do registro tipo 01
------------------------------------------------------------------------------------------------------------------------------
04	mes inicio utilizacao		|mes da data no campo N3_DINDEPR do registro tipo 01
------------------------------------------------------------------------------------------------------------------------------
05	ano inicio utilizacao		|ano da data no campo N3_DINDEPR do registro tipo 01
------------------------------------------------------------------------------------------------------------------------------
06	valor aquisicao				|N3_VORIG1 do registro tipo 01
------------------------------------------------------------------------------------------------------------------------------
07	anos de utilizacao			|N1_PRZDEPR / 12
------------------------------------------------------------------------------------------------------------------------------
08	amortizacao	anterior		|N3_VRDBAL1 do registro tipo 01
------------------------------------------------------------------------------------------------------------------------------
09	taxas amortizacao			|N3_TXDEPR1 do registro de tipo 01
------------------------------------------------------------------------------------------------------------------------------
10	valores amortizacao	   		|N3_VRDACM1 do registro do tipo 01
------------------------------------------------------------------------------------------------------------------------------
11	amortizacao acumulada		|calculado conforme indicado no layout - coluna 11 = coluna 08 + coluna 10
------------------------------------------------------------------------------------------------------------------------------
12	taxa perdida				|N3_TXPERDA do registro tipo 01
------------------------------------------------------------------------------------------------------------------------------
13	ano valia nao tributada		|Campo N3_MVALANO
------------------------------------------------------------------------------------------------------------------------------
14	valor valia nao tributada	|Tipo 33 Reinvestimento ou , caso n„o exista, o valor do Campo N3_MVALNTR
------------------------------------------------------------------------------------------------------------------------------
15	amortizacao nao aceites		|Valor valia n„o tributada * Taxa da depreciaÁ„o
------------------------------------------------------------------------------------------------------------------------------
*/
MsgRun(STR0004 + ".",,{|| cArqAtivos := GeraDados()}) //"Selecionando os dados para a impress„o do mapa"
cPictM1    := PesqPict("SN4","N4_VLROC1")
cPictM3    := PesqPict("SN4","N4_VLROC" + cMoedATF)
cPictTx    := Replicate("9",TamSX3("N3_TXDEPR1")[1]-3) + ".99"   //PesqPict("SN3","N3_TXDEPR1")
cPictTxP   := "@E9 99999.99"
cCpoMoedaF := "N3_VORIG" + cMoedATF
nCCTotAquis	:= 0
nCCTotExAnt	:= 0
nCCTotAmEx:= 0
nCCTotAmAc:= 0
nCCTotNTri:= 0
nCCTotNAce:= 0
DbSelectArea(cArqAtivos)
(cArqAtivos)->(DbGoTop())
While lImprimir .And. !((cArqAtivos)->(Eof()))
	ImpCabec()
	nlin := 860
	While lImprimir .And. !((cArqAtivos)->(Eof())) .And. (nlin< 2240)
		cCtaContab := (cArqAtivos)->N3_CCONTAB
		While lImprimir .And. !((cArqAtivos)->(Eof())) .And. ((cArqAtivos)->N3_CCONTAB == cCtaContab) .And. (nlin < 2240)
			lTemMaxDepr := .f.
			nValAqu		:= 0
			nAnosUtil	:= 0
			nAmorExAnt	:= 0
			nTxExerc	:= 0
			nAmortEx	:= 0
			nAmortAcum	:= 0
			nTxPerdida	:= 0
			nValiaNTri	:= 0
			nAmortNAc	:= 0
			//
			cDescric	:= AllTrim((cArqAtivos)->N1_DESCRIC) + "  (" + Alltrim((cArqAtivos)->N3_CBASE) + ")"'
			cCodDecr	:= (cArqAtivos)->N1_GRUPO
			nAnosUtil	:= (cArqAtivos)->N1_PRZDEPR / 12
			cBase		:= (cArqAtivos)->N3_CBASE
			cItem		:= (cArqAtivos)->N3_ITEM
			
			If  SN3->(FieldPos("N3_MVALANO")) > 0
				cAnoValNTri	:= cValToChar((cArqAtivos)->N3_MVALANO)
			EndIf
			
			cAnoAqu		:= StrZero(Year((cArqAtivos)->N3_AQUISIC),4)
			cMesIniUt	:= StrZero(Month((cArqAtivos)->N3_DINDEPR),2)
			cAnoIniUt	:= StrZero(Year((cArqAtivos)->N3_DINDEPR),4)
			nTxExerc	:= Min((cArqAtivos)->N3_TXDEPR1,100)
			While lImprimir .And. !((cArqAtivos)->(Eof())) .And. ((cArqAtivos)->N3_CBASE == cBase) .And. ((cArqAtivos)->N3_CCONTAB == cCtaContab) .And. ((cArqAtivos)->N3_ITEM == cItem)
				Do Case
					//AquisiÁ„o
					Case (cArqAtivos)->N4_TIPO == "01" .And. (cArqAtivos)->N4_OCORR $ "05/16" .And. (cArqAtivos)->N4_TIPOCNT == "1"
						nValAqu += (cArqAtivos)->NVALMOEDAC
						//Baixa
					Case (cArqAtivos)->N4_TIPO == "01" .And. (cArqAtivos)->N4_OCORR == "01" .And. (cArqAtivos)->N4_TIPOCNT == "1"
						nValAqu -= (cArqAtivos)->NVALMOEDAC
						//mais-valia nao tributada
					Case (cArqAtivos)->N4_TIPO == "33" .And. (cArqAtivos)->N4_OCORR == "05"  .And. (cArqAtivos)->N4_TIPOCNT == "1"
						nValiaNTri += (cArqAtivos)->NVALMOEDAC
						//depreciacao
					Case (cArqAtivos)->N4_OCORR == "06" .And. (cArqAtivos)->N4_TIPOCNT == "4" .And. (cArqAtivos)->N4_TIPO == '01'
						If (cArqAtivos)->N4_DATA < MV_PAR01
							nAmorExAnt += (cArqAtivos)->NVALMOEDAC
						Else
							nAmortEx += (cArqAtivos)->NVALMOEDAC
						Endif
						If (cArqAtivos)->N3_VMXDEPR <> 0
							If (cArqAtivos)->N3_VORIG1 <> (cArqAtivos)->N3_VMXDEPR
								If (cArqAtivos)->N4_DATA >= MV_PAR01
									nAmortNAc +=  ((cArqAtivos)->(N3_VORIG1  - N3_VMXDEPR)) * (( nTxExerc/100) / 12 )  //Cristian - formula incorrecta Round((cArqAtivos)->NVALMOEDAF,nDecs1)
									lTemMaxDepr := .T.
								Endif
							Endif
						Endif
						//taxa perdida
					Case (cArqAtivos)->N4_OCORR == "21" .And. (cArqAtivos)->N4_TIPOCNT == "3"
						nTxPerdida += (cArqAtivos)->NVALMOEDAF
						//Baixa depreciaÁ„o
					Case (cArqAtivos)->N4_OCORR == "01" .And. (cArqAtivos)->N4_TIPOCNT == "4"
						If (cArqAtivos)->N4_DATA < MV_PAR01
							nAmorExAnt -= (cArqAtivos)->NVALMOEDAC
						Else
							If (cArqAtivos)->N4_DATA > MV_PAR02 .And. (cArqAtivos)->N4_DATA <= MV_PAR02
								nAmortEx -= (cArqAtivos)->NVALMOEDAC
							EndIf
						Endif
						/*
						If (cArqAtivos)->N3_VMXDEPR <> 0
						If (cArqAtivos)->N3_VORIG1 <> (cArqAtivos)->N3_VMXDEPR
						If (cArqAtivos)->N4_DATA >= MV_PAR01
						nAmortNAc -= Round((cArqAtivos)->NVALMOEDAF,nDecs1)
						Endif
						Endif
						Endif
						*/
				EndCase
				If lEnd
					lImprimir := .F.
					oRelATF:Say(nlin,1605,STR0005,oFont24N,650,,,2) //"CANCELADO PELO OPERADOR"
				Endif
				(cArqAtivos)->(DbSkip())
			Enddo
/* duplicada informacao			
			If SN3->(FieldPos("N3_MVALNTR")) > 0 .And. nValiaNTri <= 0
				nValiaNTri := (cArqAtivos)->N3_MVALNTR
			EndIf
*/			
			nAmortAcum	:= nAmorExAnt + nAmortEx

/*			
			If nAmortNAc <> 0
				nAmortNAc	:= nAmortEx - nAmortNAc
			Endif
			nAmortNAc	+= Round(nValiaNTri * nTxExerc / 100,nDecs1)
*/			
			// calculo para as Mais Valias n„o tributadas quando nao existe valor m·ximo de depreciaÁ„o
			If nValiaNTri <> 0  .And.!lTemMaxDepr
				//				nAmortNAc := nAmortEx - nAmortNAc
				nAmortNAc :=   Round(( nAmortEx / nValAqu ) *  nValiaNTri,nDecs1) //Round((cArqAtivos)->NVALMOEDAF,nDecs1)
			Endif
			
			//
			oRelATF :Say(nlin,120,transform(cCodDecr,PesqPict("SN1","N1_GRUPO")),oFont08)
			oRelATF :Say(nlin,270,cDescric,oFont08)
			oRelATF :Say(nlin,1055,cAnoAqu,oFont08)
			oRelATF :Say(nlin,1150,cMesIniUt,oFont08)
			oRelATF :Say(nlin,1210,cAnoIniUt,oFont08)
			oRelATF :Say(nlin,1530,transform(nValAqu,cPictM1),oFont08,,,,1)
			oRelATF :Say(nlin,1550,Transform(nAnosUtil,"999"),oFont08)
			oRelATF :Say(nlin,1830,transform(nAmorExAnt,cPictM1),oFont08,,,,1)
			oRelATF :Say(nlin,1960,transform(nTxExerc,cPictTx),oFont08,,,,1)
			oRelATF :Say(nlin,2210,transform(nAmortEx,cPictM1),oFont08,,,,1)
			oRelATF :Say(nlin,2460,transform(nAmortAcum,cPictM1),oFont08,,,,1)
			oRelATF :Say(nlin,2590,transform(nTxPerdida,cPictTxP),oFont08,,,,1)
			oRelATF :Say(nlin,2615,If(nValiaNTri<>0,cAnoValNTri,"  "),oFont08)
			oRelATF :Say(nlin,2940,transform(nValiaNTri,cPictM1),oFont08,,,,1)
			oRelATF :Say(nlin,3190,transform(nAmortNAc,cPictM1),oFont08,,,,1)
			nLin += 40
			//
			nTotValAqu	+= nValAqu
			nTotAmorAnt	+= nAmorExAnt
			nTotAmorEx	+= nAmortEx
			nTotAmorAcu	+= nAmortAcum
			nTotAmorNAc	+= nAmortNAc
			//
			nCCTotAquis		+= nValAqu
			nCCTotExAnt		+= nAmorExAnt
			nCCTotAmEx	+= nAmortEx
			nCCTotAmAc	+= nAmortAcum
			nCCTotNTri	+= nValiaNTri
			nCCTotNAce	+= nAmortNAc
		enddo
		/* impressao do total por conta contabil */
		If !((cArqAtivos)->N3_CCONTAB == cCtaContab) .Or. ((cArqAtivos)->(Eof()))
			If lImprimir
				If nCCTotAquis > 0
					oRelATF:Say(nlin,1030,STR0006 + " " + AllTrim(cCtaContab),oFont08n,,,,1) //"Totais da conta"
					oRelATF :Say(nlin,1530,transform(nCCTotAquis,cPictM1),oFont08n,,,,1)
					oRelATF :Say(nlin,1830,transform(nCCTotExAnt,cPictM1),oFont08n,,,,1)
					oRelATF :Say(nlin,2210,transform(nCCTotAmEx,cPictM1),oFont08n,,,,1)
					oRelATF :Say(nlin,2460,transform(nCCTotAmAc,cPictM1),oFont08n,,,,1)
					oRelATF :Say(nlin,2940,transform(nCCTotNTri,cPictM1),oFont08n,,,,1)
					oRelATF :Say(nlin,3190,transform(nCCTotNAce,cPictM1),oFont08n,,,,1)
					nCCTotAquis		:= 0
					nCCTotExAnt		:= 0
					nCCTotAmEx	:= 0
					nCCTotAmAc	:= 0
					nCCTotNTri	:= 0
					nCCTotNAce	:= 0
					nLin += 80
				Endif
			Endif
		Endif
	Enddo
	ImpRodape()
Enddo
DbSelectArea(cArqAtivos)
DbCloseArea()
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ATFR31    ∫Autor  ≥Microsiga           ∫Fecha ≥  06/08/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function GeraDados()
Local cCpoMoedaF	:= ""
Local cQuery		:= ""
Local cArq			:= ""

/*
Selecao dos ativos para o mapa*/
cCpoMoedaF := "N4_VLROC" + cMoedATF
cArq := GetNextAlias()
cQuery := "select N3_CCONTAB,N3_CBASE,N3_ITEM,N3_AQUISIC,N3_DTBAIXA,N3_TXDEPR1,N3_DINDEPR,N3_VORIG1,N3_VMXDEPR,N1_GRUPO,N1_DESCRIC,N1_PRZDEPR,N4_TIPO,N4_OCORR,N4_TIPOCNT,N4_DATA,sum(N4_VLROC1) NVALMOEDAC,SUM(" + cCpoMoedaF + ")  NVALMOEDAF" + CRLF

If SN3->(FieldPos("N3_MVALNTR")) > 0 .And. SN3->(FieldPos("N3_MVALANO")) > 0
	cQuery += " ,N3_MVALNTR,N3_MVALANO "
EndIf

cQuery += " from " + RetSqlName("SN1") + " SN1B," + RetSqlName("SN3") + " SN3B, " + RetSqlName("SN4") + " SN4"+ CRLF
cQuery += " where SN1B.D_E_L_E_T_=''"+ CRLF
cQuery += " and SN3B.D_E_L_E_T_=''"+ CRLF
cQuery += " and SN4.D_E_L_E_T_=''"+ CRLF
cQuery += " and SN1B.N1_FILIAL = '" + xFilial("SN1") + "'"+ CRLF
cQuery += " and SN3B.N3_FILIAL = '" + xFilial("SN3") + "'"+ CRLF
cQuery += " and SN4.N4_FILIAL = '" + xFilial("SN4") + "'"+ CRLF
cQuery += " and SN3B.N3_CBASE = SN1B.N1_CBASE"+ CRLF
cQuery += " and SN3B.N3_ITEM  = SN1B.N1_ITEM"+ CRLF
cQuery += " AND SN3B.N3_TIPREAV = ''"+ CRLF
cQuery += " and SN4.N4_ITEM  = SN3B.N3_ITEM"+ CRLF
cQuery += " and SN4.N4_CBASE  = SN3B.N3_CBASE"+ CRLF
/* nao permitir itens com reavaliacoes */
cQuery += " AND NOT EXISTS( SELECT 1 FROM "+ RetSqlName("SN3") +" SN3R "+ CRLF
cQuery += " WHERE SN3R.N3_FILIAL = SN1B.N1_FILIAL "+ CRLF
cQuery += " AND SN3R.N3_CBASE = SN1B.N1_CBASE "+ CRLF
cQuery += " AND SN3R.N3_ITEM = SN1B.N1_ITEM "+ CRLF
cQuery += " AND SN3R.N3_TIPO IN ('02','05')"	+ CRLF
cQuery += " AND SN3R.D_E_L_E_T_ = '') "+ CRLF

//----------
/**/
If MV_PAR03 == 1		//corporeo
	cQuery += " and SN1B.N1_NATBEM = 'C'"+ CRLF
ElseIf MV_PAR03 == 2	//incorporeo
	cQuery += " and SN1B.N1_NATBEM = 'I'"+ CRLF
Endif
If MV_PAR03 == 3
	cQuery += " and SN3B.N3_TIPO='01' and SN3B.N3_BAIXA = '1'"+ CRLF
	cQuery += " and SN3B.N3_DTBAIXA >= '" + Dtos(MV_PAR01) + "'"+ CRLF
	cQuery += " and SN3B.N3_DTBAIXA <= '" + Dtos(MV_PAR02) + "'"+ CRLF
	cQuery += " and SN3B.N3_IDBAIXA <>  '3'"+ CRLF // BAIXA POR TRANSFERENCIA
	
Else
	cQuery += " and ("+ CRLF
	cQuery += " (SN3B.N3_TIPO='01' and SN3B.N3_BAIXA = '0')"+ CRLF
	cQuery += " or"+ CRLF
	cQuery += " (SN3B.N3_TIPO='01' and SN3B.N3_BAIXA = '1' and SN3B.N3_DTBAIXA > '" + Dtos(MV_PAR02) + "')"+ CRLF
	cQuery += ")"+ CRLF
Endif
cQuery += " and SN4.N4_DATA <= '" + Dtos(MV_PAR02) + "'"+ CRLF
cQuery += " group by SN3B.N3_CCONTAB,SN3B.N3_CBASE,SN3B.N3_ITEM,SN4.N4_TIPO,SN4.N4_OCORR,SN4.N4_TIPOCNT,SN4.N4_DATA,SN3B.N3_AQUISIC,SN3B.N3_AQUISIC,SN3B.N3_TXDEPR1,SN3B.N3_DINDEPR,SN3B.N3_DTBAIXA,SN1B.N1_DESCRIC,SN1B.N1_PRZDEPR,SN1B.N1_GRUPO,N3_VORIG1,N3_VMXDEPR"+ CRLF

If SN3->(FieldPos("N3_MVALNTR")) > 0 .And. SN3->(FieldPos("N3_MVALANO")) > 0
	cQuery += " ,N3_MVALNTR,N3_MVALANO "+ CRLF
EndIf

cQuery += " order by SN3B.N3_CCONTAB,SN3B.N3_CBASE,SN3B.N3_ITEM"+ CRLF
cQuery := ChangeQuery(cQuery)

MemoWrite( 'ATFR402.SQL', cQuery )
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArq,.T.,.T.)
TCSetField(cArq,"N3_DINDEPR","D")
TCSetField(cArq,"N3_AQUISIC","D")
TCSetField(cArq,"N3_DTBAIXA","D")
TCSetField(cArq,"N4_DATA","D")
(cArq)->(DbGoTop())
Return(cArq)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ImpCabec  ∫ Autor ≥ Cristina Barroso   ∫ Data ≥  04/09/09    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Desc.    ≥ Impressao do cabecalho                                      ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function ImpCabec()
Local aPalavras	:= {}

oRelATF :STARTPAGE()

//oRelATF :SayBitmap(510,100, "\systemsod\col321_1.bmp", 171,339) //
//oRelATF :SayBitmap(560,1020, "\systemsod\col321_2.bmp", 127.5,213) //  85,142
//oRelATF :SayBitmap(570,1530, "\systemsod\col321_3.bmp", 71,190) //
//oRelATF :SayBitmap(560,2480, "\systemsod\col321_4.bmp", 106.5,285) //  71,190
oRelATF :Say(080,100,"(" + "Artigos 121∫ do CIRC e 129∫ do CIRS - Portaria n∫ 359/2000, de 20/06" + ")",oFont08)
oRelATF :Box(120,100,500,1040)
oRelATF :Say(180,120,SM0->M0_NOMECOM,oFont10)
oRelATF :Say(340,650,STR0024,oFont10)		//"ExercÌcio de"
oRelATF :Say(330,880,transform(cExerc,"@R 9 9 9 9"),oFont13)
oRelATF :Box(415,115,475,530)
oRelATF :Say(425,120,STR0007,oFont08)		//"PERIODO DE TRIBUTA«√O"
oRelATF :Say(430,560,"de",oFont10)
oRelATF :Say(430,820,"a",oFont10)
oRelATF :Say(425,620,dtoc(MV_PAR01),oFont12)
oRelATF :Say(425,865,dtoc(MV_PAR02),oFont12)

aPalavras := ATFBrkStr(STR0031,21,2)	//"MAPA DE REINTEGRA«’ES E AMORTIZA«’ES"
oRelATF :Say(120,1400,aPalavras[1],oFont14N,650,,,2)
oRelATF :Say(200,1400,aPalavras[2],oFont14N,650,,,2)
aPalavras := ATFBrkStr(STR0032,23,2)	//"ELEMENTOS DO ACTIVO N√O REAVALIADOS"
oRelATF :Say(300,1400,aPalavras[1],oFont12,650,,,2)
oRelATF :Say(350,1400,aPalavras[2],oFont12,650,,,2)
oRelATF :Say(390,1400,"(" + STR0008 + ")",oFont10,650,,,2)		//"incluindo os adquiridos em estado de uso"
Do Case
	Case MV_PAR03 == 1		//corporeo
		oRelATF :Say(460,1400,STR0009,oFont12,650,,,2)  		//"Imobilizado CorpÛreo"
	Case MV_PAR03 == 2		//incorporeo
		oRelATF :Say(460,1400,STR0010,oFont12,650,,,2)  		//"Imobilizado IncorpÛreo"
	Case MV_PAR03 == 3		//Abatidos
		oRelATF :Say(460,1400,STR0011,oFont12,650,,,2)  		//"Elementos abatidos no exercÌcio"
EndCase
oRelATF :Box(120,1770,500,2710)
oRelATF :Say(180,1800,STR0012,oFont10)  						//"N˙mero de identificaÁ„o fiscal"
oRelATF :Say(180,2340,transform(SM0->M0_CGC,PesqPict("SA1","A1_CGC")),oFont13)
oRelATF :Say(260,1800,STR0013 + ": " + Lower(AllTrim(SM0->M0_DSCCNA)),oFont10)		//"Actividade principal"
oRelATF :Say(420,2280,STR0014 + " ",oFont10)			//"CÛdigo CAE"
oRelATF :Say(415,2500,SM0->M0_CNAE,oFont13)

oRelATF :Box(120,2750,500,3200)
//oRelATF :SayBitmap(180,2800, "\systemsod\IRC.bmp",375,139) // Tem que estar abaixo do RootPath
oRelATF :Say(420,2800,STR0002,oFont10)		//"MODELO"
oRelATF :Say(390,3000,"32.1",oFont24N)

/*
Cabecalho das colunas */
oRelATF :Box(520,100,2300,3200)
oRelATF :line(840,100,840,3200)	//horiz

oRelATF :line(840,260,2300,260)     //1
oRelATF :line(840,1040,2300,1040)   //2
oRelATF :line(840,1135,2300,1135)   //3
oRelATF :line(840,1195,2300,1195)   //4
oRelATF :line(840,1290,2300,1290)   //5
oRelATF :line(840,1540,2300,1540)   //6
oRelATF :line(840,1590,2300,1590)   //7
oRelATF :line(840,1840,2300,1840)   //8
oRelATF :line(840,1970,2300,1970)   //9
oRelATF :line(840,2220,2300,2220)   //10
oRelATF :line(840,2470,2300,2470)   //11
oRelATF :line(840,2600,2300,2600)   //12
oRelATF :line(840,2700,2300,2700)   //13
oRelATF :line(840,2950,2300,2950)   //14

oRelATF :line(520,260,840,260)
aPalavras := ATFBrkStr(STR0033,11,5)		//"CÛdigo conforme Decr.Regul. Nr. 2/90 de 12/01"
oRelATF :Say(570,170,aPalavras[1],oFont08,80,,,2)
oRelATF :Say(610,170,aPalavras[2],oFont08,80,,,2)
oRelATF :Say(650,170,aPalavras[3],oFont08,80,,,2)
oRelATF :Say(690,170,aPalavras[4],oFont08,80,,,2)
oRelATF :Say(730,170,aPalavras[5],oFont08,80,,,2)

oRelATF :Say(680,460,STR0015,oFont08)					//"DescriÁ„o do activo imobilizado"
oRelATF :line(520,1040,840,1040)

oRelATF :Say(530,1140,STR0026,oFont08)  			//"Data"
oRelATF :Say(650,1080,STR0025,oFont08,150,,,2)		//"Aquis."
oRelATF :line(580,1040,580,1290)
aPalavras := ATFBrkStr(STR0034,10,2)		//"InÌcio de utilizaÁ„o"
oRelATF :Say(610,1220,aPalavras[1],oFont08,150,,,2)
oRelATF :Say(650,1220,aPalavras[2],oFont08,150,,,2)
oRelATF :line(740,1040,740,1290)

oRelATF :Say(780,1050,STR0022,oFont08)		//"Ano"
oRelATF :line(580,1135,840,1135)
oRelATF :Say(780,1140,STR0023,oFont08)		//"MÍs"
oRelATF :line(740,1195,840,1195)
oRelATF :Say(780,1210,STR0022,oFont08)		//"Ano"
oRelATF :line(520,1290,840,1290)

oRelATF :Say(570,1415,STR0016,oFont08,250,,,2)		//"Activo imobilizado"
aPalavras := ATFBrkStr("(" + STR0035 + ")",17,5)	//"valores de aquisiÁ„o ou outro valor contabilistico na falta daqueles"
oRelATF :Say(610,1415,aPalavras[1],oFont08,250,,,2)
oRelATF :Say(650,1415,aPalavras[2],oFont08,250,,,2)
oRelATF :Say(690,1415,aPalavras[3],oFont08,250,,,2)
oRelATF :Say(730,1415,aPalavras[4],oFont08,250,,,2)
oRelATF :Say(770,1415,aPalavras[5],oFont08,250,,,2)
oRelATF :line(520,1540,840,1540)

aPalavras := ATFBrkStr(STR0036,5,2)		//"Ano Util."
oRelATF :Say(650,1562,aPalavras[1],oFont08,250,,,2)
oRelATF :Say(690,1562,aPalavras[2],oFont08,250,,,2)
oRelATF :line(520,1590,840,1590)

oRelATF :Say(530,1830,STR0017,oFont08)  					//"ReintegraÁıes e amortizaÁıes"
oRelATF :line(590,1590,590,2470)
aPalavras := ATFBrkStr(STR0037,13,2)						//"De exercÌcios anteriores"
oRelATF :Say(710,1715,aPalavras[1],oFont08,250,,,2)
oRelATF :Say(750,1715,aPalavras[2],oFont08,250,,,2)
oRelATF :line(590,1840,840,1840)
oRelATF :Say(620,2040,STR0029,oFont08,380,,,2) 				//"Do exercÌcio"
oRelATF :line(715,1840,715,2220)
oRelATF :Say(780,1850,STR0020,oFont08)  					//"Taxas"
oRelATF :line(715,1970,840,1970)
oRelATF :Say(780,2095,STR0021,oFont08,250,,,2) 				//"Valores"
oRelATF :line(590,2220,840,2220)

oRelATF :Say(710,2345,STR0018,oFont08,250,,,2)			 	//"Acumuladas"
oRelATF :line(520,2470,840,2470)

aPalavras := ATFBrkStr(STR0038,7,3)							//"Taxa perdida acumul."
oRelATF :Say(650,2528,aPalavras[1],oFont08,250,,,2)
oRelATF :Say(690,2528,aPalavras[2],oFont08,250,,,2)
oRelATF :Say(730,2528,aPalavras[3],oFont08,250,,,2)
oRelATF :line(520,2600,840,2600)

aPalavras := ATFBrkStr(STR0039,14,2)						//"Mais - Valias n„o tributadas"
oRelATF :Say(570,2775,aPalavras[1],oFont08,250,,,2)
oRelATF :Say(610,2775,apalavras[2],oFont08,250,,,2)
oRelATF :line(715,2600,715,2950)
oRelATF :Say(780,2620,STR0022,oFont08) 						//"Ano"
oRelATF :line(715,2700,840,2700)
oRelATF :Say(780,2825,STR0019,oFont08,250,,,2)  			//"Montante"
oRelATF :line(520,2950,840,2950)

aPalavras := ATFBrkStr(STR0040,15,3)						//"ReintegraÁıes e amortizaÁıes n„o aceites"
oRelATF :Say(650,3075,aPalavras[1],oFont08,250,,,2)
oRelATF :Say(690,3075,aPalavras[2],oFont08,250,,,2)
oRelATF :Say(730,3075,aPalavras[3],oFont08,250,,,2)
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫ Programa ≥ImpRodape ∫ Autor ≥ Cristina Barroso   ∫ Data ≥  04/09/09    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫ Desc.    ≥ Impressao do rodape                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function ImpRodape()
//oRelATF :SayBitmap(2320,1290, "\systemsod\SOMBRA250.bmp", 250,70) //
//oRelATF :SayBitmap(2320,1590, "\systemsod\SOMBRA250.bmp", 250,70) //
//oRelATF :SayBitmap(2320,1970, "\systemsod\SOMBRA250.bmp", 250,70) //
//oRelATF :SayBitmap(2320,2220, "\systemsod\SOMBRA250.bmp", 250,70) //
//oRelATF :SayBitmap(2320,2950, "\systemsod\SOMBRA250.bmp", 250,70) //
oRelATF :FillRect({2320,1290,2390,1540},oBrR)
oRelATF :FillRect({2320,1590,2390,1840},oBrR)
oRelATF :FillRect({2320,1970,2390,2220},oBrR)
oRelATF :FillRect({2320,2220,2390,2470},oBrR)
oRelATF :FillRect({2320,2950,2390,3200},oBrR)

oRelATF :Box(2320,100,2390,3200)
oRelATF :line(2320,1290,2390,1290)
oRelATF :line(2320,1540,2390,1540)
oRelATF :line(2320,1590,2390,1590)
oRelATF :line(2320,1840,2390,1840)
oRelATF :line(2320,1970,2390,1970)
oRelATF :line(2320,2220,2390,2220)
oRelATF :line(2320,2470,2390,2470)
oRelATF :line(2320,2950,2390,2950)

oRelATF :Say(2330,750,STR0027,oFont10)  		//"Total geral ou a transportar"
oRelATF :Say(2400,1600,STR0028,oFont10N,,,,2)  	//"Documento emitido por computador"

oRelATF :Say(2330,1530,transform(nTotValAqu,cPictM1),oFont10,,,,1)
oRelATF :Say(2330,1830,transform(nTotAmorAnt,cPictM1),oFont10,,,,1)
oRelATF :Say(2330,2210,transform(nTotAmorEx,cPictM1),oFont10,,,,1)
oRelATF :Say(2330,2460,transform(nTotAmorAcu,cPictM1),oFont10,,,,1)
oRelATF :Say(2330,3190,transform(nTotAmorNAc,cPictM1),oFont10,,,,1)

oRelATF :endPAGE()
return()

///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | criaSX1.prw  		 | AUTOR | Microsiga	| DATA | 18/01/2004 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Funcao - CriaSX1()                                              |//
//|           | Fonte utilizado no curso oficina de programacao.                |//
//|           | Funcao que cria o grupo de perguntas se necessario              |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////
Static Function CriaSx1( cPergunta )
Local nI		:= 0
Local nJ		:= 0
Local lSX1		:= .F.
Local aSaveArea	:= GetArea()
Local aPergs	:= {}
Local aEstrut	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}
Local aHelpPor	:= {}

//				X1_GRUPO   X1_ORDEM   X1_PERGUNT X1_PERSPA X1_PERENG  X1_VARIAVL X1_TIPO    X1_TAMANHO X1_DECIMAL X1_PRESEL
//				X1_GSC     X1_VALID   X1_VAR01   X1_DEF01  X1_DEFSPA1 X1_DEFENG1 X1_CNT01   X1_VAR02   X1_DEF02
//				X1_DEFSPA2 X1_DEFENG2 X1_CNT02   X1_VAR03  X1_DEF03   X1_DEFSPA3 X1_DEFENG3 X1_CNT03   X1_VAR04   X1_DEF04
// 				X1_DEFSPA4 X1_DEFENG4 X1_CNT04   X1_VAR05  X1_DEF05   X1_DEFSPA5 X1_DEFENG5 X1_CNT05   X1_F3      X1_GRPSXG X1_PYME

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL" ,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2",;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4",;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME"}

Aadd(aPergs,{cPergunta,"01","Data de  ?" , "Data de ?" , "Data de  ?" ,"mv_ch1","D",08,0,1,"C","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
Aadd(aPergs,{cPergunta,"02","Data ate  ?" , "Data ate ?" , "Data ate  ?" ,"mv_ch2","D",08,0,1,"C","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
Aadd(aPergs,{cPergunta,"03","Natureza  ?" , "Natureza ?" , "Natureza  ?" ,"mv_ch3","N",1,0,1,"C","","mv_par03","Imob. CorpÛreo","Imob. CorpÛreo","Imob. CorpÛreo","","","Imob.IncorpÛreo","Imob.IncorpÛreo","Imob.IncorpÛreo","","","Abatidos no exercÌcio","Abatidos no exercÌcio","Abatidos no exercÌcio","","","","","","","","","","","","","","S"})
ProcRegua(Len(aPergs))
dbSelectArea("SX1")
dbSetOrder(1)
IF ! dbSeek(cPergunta)
	For nI:= 1 To Len(aPergs)
		If !Empty(aPergs[nI][1])
			If !dbSeek(aPergs[nI,1]+aPergs[nI,2])
				lSX1 := .T.
				RecLock("SX1",.T.)
				For nJ:=1 To Len(aPergs[nI])
					If !Empty(FieldName(FieldPos(aEstrut[nJ])))
						FieldPut(FieldPos(aEstrut[nJ]),aPergs[nI,nJ])
					EndIf
				Next nJ
				MsUnLock()
				dbCommit()
				IncProc(STR0030 + "...")		//"Atualizando Perguntas de Relatorios"
			EndIf
		EndIf
	Next nI
Endif
/*
Inclusao do "help" */
AADD(aHelpPor,"Informe a data inicial do intervalo de")
AADD(aHelpPor,"datas para que se obtenha o resultado")
AADD(aHelpPor,"desejado no relatÛrio.")
Aadd(aHelpSpa,"Digite la fecha inicial del intervalo")
Aadd(aHelpSpa,"de fechas para que se obtenga el")
Aadd(aHelpSpa,"resultado deseado en el informe.")
Aadd(aHelpEng,"Enter the initial date of the dates")
Aadd(aHelpEng,"interval in order to obtain the desired")
Aadd(aHelpEng,"result in the bank statement.")
PutSX1Help("P." + cPergunta + "01.",aHelpPor,aHelpEng,aHelpSpa,.T.)
AHelpPor := {}
AHelpEng := {}
AHelpSpa := {}
/*..*/
AADD(aHelpPor,"Informe a data final do intervalo de")
AADD(aHelpPor,"datas para que se obtenha o resultado")
AADD(aHelpPor,"desejado no relatÛrio.")
Aadd(aHelpSpa,"Digite la fecha final del intervalo")
Aadd(aHelpSpa,"de fechas para que se obtenga el")
Aadd(aHelpSpa,"resultado deseado en el informe.")
Aadd(aHelpEng,"Enter the final date of the dates")
Aadd(aHelpEng,"interval in order to obtain the desired")
Aadd(aHelpEng,"result in the bank statement.")
PutSX1Help("P." + cPergunta + "02.",aHelpPor,aHelpEng,aHelpSpa,.T.)
AHelpPor := {}
AHelpEng := {}
AHelpSpa := {}
/*..*/
AADD(aHelpPor,"Informe grupo de ativos desejado para")
AADD(aHelpPor,"este relatÛrio.")
Aadd(aHelpSpa,"Indique el grupo de activos deseado")
Aadd(aHelpSpa,"para este informe.")
Aadd(aHelpEng,"Enter the group for this report.")
PutSX1Help("P." + cPergunta + "03.",aHelpPor,aHelpEng,aHelpSpa,.T.)
AHelpPor := {}
AHelpEng := {}
AHelpSpa := {}
RestArea(aSaveArea)
Return()
