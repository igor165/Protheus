#INCLUDE "protheus.ch"
#INCLUDE "ATFR404.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ ATFR404  º Autor ³ Cristina Barroso   º Data ³  04/09/09    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Mapa Fiscal modelo 32                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
        

Function ATFR404()
Local cPerg			:= "ATR404"
Local aArea			:= {}

Private cMoedATF	:= ""
Private cExerc		:= ""
Private oRelATF

//Parametros de perguntas para o  relatorio
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
	oRelATF	:= TMSPrinter():New(STR0001 + " - " + STR0002 + "32") //"MAPA"###"MODELO"
	oRelATF:SetLandscape()
	RptStatus({|lEnd| ImpRelATF(@lEnd)},STR0003) //"A imprimir Mapa..."
	oRelATF:Preview()
Endif
RestArea(aArea)
return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ImpRelATF º Autor ³ Cristina Barroso   º Data ³  04/09/09    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Impressao do relatorio                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
Local nDeprec		:= 0

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
Private nTotLimF    := 0  
Private nTotImpF    := 0

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
Private oBrR 		:= TBrush():New(,RGB(228,224,224),,)	

MsgRun(STR0004 + ".",,{|| cArqAtivos := GeraDados()}) //"Selecionando os dados para a impressão do mapa"
cPictM1    := PesqPict("SN4","N4_VLROC1")
cPictM3    := PesqPict("SN4","N4_VLROC" + cMoedATF)
cPictTx    := Replicate("9",TamSX3("N3_TXDEPR1")[1]-3) + ".99"   //PesqPict("SN3","N3_TXDEPR1")
cPictTxP   := "@E9 99999.99"
cCpoMoedaF := "N3_VORIG" + cMoedATF
nCCTotAquis	:= 0
nCCTotExAnt	:= 0
nCCTotAmEx:= 0
nCCTotAmAc:= 0 
nCCTotLimF:= 0
nCCTotNTri:= 0
nCCTotNAce:= 0
nCCTotImpF:= 0
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
			nValAquf    := 0
			nAnosUtil	:= 0
			nAmorExAnt	:= 0
			nTxExerc	:= 0
			nTxCorr     := 0 
			nLimFiscal  := 0
			nAmortEx	:= 0
			nAmortAcum	:= 0
			nTxPerdida	:= 0
			nValiaNTri	:= 0
			nAmortNAc	:= 0 
			nVlImp      := 0
			nVlImpF     := 0  
			nDeprec		:= 0 
			//
			cDescric	:= AllTrim((cArqAtivos)->N1_DESCRIC) + "  (" + Alltrim((cArqAtivos)->N3_CBASE) + ")"'
			cCodDecr	:= (cArqAtivos)->N1_GRUPO
			nAnosUtil	:= (cArqAtivos)->N1_PRZDEPR
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
					//Aquisição
					Case (cArqAtivos)->N4_TIPO == "01" .And. (cArqAtivos)->N4_OCORR $ "05/16/86" .And. (cArqAtivos)->N4_TIPOCNT == "1"
						nValAqu  += (cArqAtivos)->NVALMOEDAC    
						If (cArqAtivos)->N3_VMXDEPR > 0 .And. (cArqAtivos)->NVALMOEDAC > (cArqAtivos)->N3_VMXDEPR
							nValAquF += (cArqAtivos)->N3_VMXDEPR
						Else		
							nValAquF += (cArqAtivos)->NVALMOEDAC    
						Endif

					//Baixa
				//	Case (cArqAtivos)->N4_TIPO == "01" .And. (cArqAtivos)->N4_OCORR == "01" .And. (cArqAtivos)->N4_TIPOCNT == "1"
				//		nValAqu -= (cArqAtivos)->NVALMOEDAC
				
					//mais-valia nao tributada
					Case (cArqAtivos)->N4_TIPO == "33" .And. (cArqAtivos)->N4_OCORR == "05"  .And. (cArqAtivos)->N4_TIPOCNT == "1"
						nValiaNTri += (cArqAtivos)->NVALMOEDAC
			          
					// Imparidade nao fiscal
					Case (cArqAtivos)->N4_TIPO == "01" .And. (cArqAtivos)->N4_OCORR == "01"  .And. (cArqAtivos)->N4_MOTIVO == "15"
						If (cArqAtivos)->N4_DATA >= MV_PAR01 .And. (cArqAtivos)->N4_DATA <= MV_PAR02
							nVlImp += (cArqAtivos)->NVALMOEDAC
						Endif
						
					// Imparidade nao fiscal
					Case (cArqAtivos)->N4_TIPO == "12" .And. (cArqAtivos)->N4_OCORR == "05"  .And. (cArqAtivos)->N4_MOTIVO <> "14"
						If (cArqAtivos)->N4_DATA >= MV_PAR01 .And. (cArqAtivos)->N4_DATA <= MV_PAR02
							nVlImp += (cArqAtivos)->NVALMOEDAC
						Endif

					// Imparidade fiscal	
					Case (cArqAtivos)->N4_TIPO == "01" .And. (cArqAtivos)->N4_OCORR == "01"  .And. (cArqAtivos)->N4_MOTIVO == "14"
						If (cArqAtivos)->N4_DATA >= MV_PAR01 .And. (cArqAtivos)->N4_DATA <= MV_PAR02
							nVlImpF += (cArqAtivos)->NVALMOEDAC
						Endif
					
					//depreciacao
					Case (cArqAtivos)->N4_OCORR == "06" .And. (cArqAtivos)->N4_TIPOCNT == "4" .And. (cArqAtivos)->N4_TIPO == '01'
						If (cArqAtivos)->N4_DATA < MV_PAR01  
							If (cArqAtivos)->N3_VMXDEPR > 0
								nAmorExAnt += (cArqAtivos)->NVALMOEDAF
							Else
								nAmorExAnt += (cArqAtivos)->NVALMOEDAF
							Endif
						Else  
							nDeprec += 1
							If (cArqAtivos)->N3_VMXDEPR > 0
								nAmortEx += (cArqAtivos)->NVALMOEDAF
							Else
								nAmortEx += (cArqAtivos)->NVALMOEDAF 
							Endif
							
						Endif
					/*	If (cArqAtivos)->N3_VMXDEPR <> 0
							If (cArqAtivos)->N3_VORIG1 <> (cArqAtivos)->N3_VMXDEPR
								If (cArqAtivos)->N4_DATA >= MV_PAR01
									nAmortNAc +=  ((cArqAtivos)->(N3_VORIG1  - N3_VMXDEPR)) * (( nTxExerc/100) / 12 )  //Cristian - formula incorrecta Round((cArqAtivos)->NVALMOEDAF,nDecs1)
									lTemMaxDepr := .T.
								Endif
							Endif
						Endif   */

					//taxa perdida
					Case (cArqAtivos)->N4_OCORR == "21" .And. (cArqAtivos)->N4_TIPOCNT == "3"
						nTxPerdida += (cArqAtivos)->NVALMOEDAF

					//Baixa depreciação
					Case (cArqAtivos)->N4_OCORR == "01" .And. (cArqAtivos)->N4_TIPOCNT == "4"
						If (cArqAtivos)->N4_DATA < MV_PAR01
							nAmorExAnt -= (cArqAtivos)->NVALMOEDAC
						Else
							If (cArqAtivos)->N4_DATA > MV_PAR02 .And. (cArqAtivos)->N4_DATA <= MV_PAR02
								nAmortEx -= (cArqAtivos)->NVALMOEDAC
							EndIf
						Endif
				EndCase
				
				If lEnd
					lImprimir := .F.
					oRelATF:Say(nlin,1605,STR0005,oFont24N,650,,,2) //"CANCELADO PELO OPERADOR"
				Endif
				(cArqAtivos)->(DbSkip())
			Enddo
			nAmortAcum	:= nAmorExAnt + nAmortEx

			// calculo para as Mais Valias não tributadas quando nao existe valor máximo de depreciação
		  /*	If nValiaNTri <> 0  .And.!lTemMaxDepr
				//				nAmortNAc := nAmortEx - nAmortNAc
				nAmortNAc :=   Round(( nAmortEx / nValAqu ) *  nValiaNTri,nDecs1) //Round((cArqAtivos)->NVALMOEDAF,nDecs1)
			Endif   */   
			
			nAmortEx += nVlImp + nVlImpF

			If mv_par04 == 1 
				nLimFiscal := ( nValAquF * ( nTxExerc / 100) )
			ElseIf mv_par04 == 2
				nLimFiscal := ((nValAquF - nAmorExAnt) * nTxCorr)
			Endif			

			nAmortNAc := (nAmortEx - (nLimFiscal + nVlImpF))  
			
			If nAmortNAc < 0
				nAmortNAc := 0
			Endif
			
			//
			oRelATF :Say(nlin,120,transform(cCodDecr,PesqPict("SN1","N1_GRUPO")),oFont08)
			oRelATF :Say(nlin,270,cDescric,oFont08)
			oRelATF :Say(nlin,1065,cMesIniUt,oFont08)
			oRelATF :Say(nlin,1125,cAnoIniUt,oFont08)
			oRelATF :Say(nlin,1380,transform(nValAqu,cPictM1),oFont08,,,,1)   
			oRelATF :Say(nlin,1580,transform(nValAquF,cPictM1),oFont08,,,,1)   
			oRelATF :Say(nlin,1620,Transform(nAnosUtil,"999"),oFont08)
			oRelATF :Say(nlin,1850,transform(nAmortEx,cPictM1),oFont08,,,,1)
			oRelATF :Say(nlin,2050,transform(nAmorExAnt,cPictM1),oFont08,,,,1)
			oRelATF :Say(nlin,2180,transform(nTxExerc,cPictTx),oFont08,,,,1)

			If mv_par04 == 2
				oRelATF :Say(nlin,2310,transform(nTxCorr,cPictTx),oFont08,,,,1)
			Endif

			oRelATF :Say(nlin,2510,transform(nLimFiscal,cPictM1),oFont08,,,,1)
			oRelATF :Say(nlin,2710,transform(nVlImpF,cPictM1),oFont08,,,,1)
			oRelATF :Say(nlin,2790,transform(nTxPerdida,cPictTxP),oFont08,,,,1)
			oRelATF :Say(nlin,2990,transform(nAmortNAc,cPictM1),oFont08,,,,1)  
			oRelATF :Say(nlin,3190,transform(nAmortNAc,cPictM1),oFont08,,,,1)  
			nLin += 40
			//
			nTotValAqu	+= nValAqu
			nTotAmorAnt	+= nAmorExAnt
			nTotAmorEx	+= nAmortEx
			nTotAmorAcu	+= nAmortAcum
			nTotAmorNAc	+= nAmortNAc 
			nTotLimF    += nLimFiscal 
			nTotImpF    += nVlImpF
			//
			nCCTotAquis	+= nValAqu
			nCCTotExAnt	+= nAmorExAnt
			nCCTotAmEx	+= nAmortEx
			nCCTotAmAc	+= nAmortAcum
			nCCTotNTri	+= nValiaNTri
			nCCTotNAce	+= nAmortNAc  
			nCCtotLimF  += nLimFiscal
			nCCTotImpF  += nVlImpF
			
		enddo
		/* impressao do total por conta contabil */
		If !((cArqAtivos)->N3_CCONTAB == cCtaContab) .Or. ((cArqAtivos)->(Eof()))
			If lImprimir
				If nCCTotAquis > 0
					oRelATF:Say(nlin,950,STR0006 + " " + AllTrim(cCtaContab),oFont08n,,,,1) //"Totais da conta"
					oRelATF :Say(nlin,1380,transform(nCCTotAquis,cPictM1),oFont08n,,,,1)
					oRelATF :Say(nlin,1850,transform(nCCTotAmEx,cPictM1),oFont08n,,,,1)
					oRelATF :Say(nlin,2050,transform(nCCTotExAnt,cPictM1),oFont08n,,,,1)
					oRelATF :Say(nlin,2510,transform(nCCtotLimF,cPictM1),oFont08n,,,,1)
					oRelATF :Say(nlin,2710,transform(nCCTotImpF,cPictM1),oFont08n,,,,1)
//					oRelATF :Say(nlin,3190,transform(nCCTotNAce,cPictM1),oFont08n,,,,1)
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFR31    ºAutor  ³Microsiga           ºFecha ³  06/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraDados()
Local cCpoMoedaF	:= ""
Local cQuery		:= ""
Local cArq			:= ""     
Local cTpDepr       := ""
                      

If mv_par04 == 1
 cTpDepr := "1"
Else
 cTpDepr := "5"
Endif
 
/*
Selecao dos ativos para o mapa*/
cCpoMoedaF := "N4_VLROC" + cMoedATF
cArq := GetNextAlias()
cQuery := "select N3_CCONTAB,N3_CBASE,N3_ITEM,N3_AQUISIC,N3_DTBAIXA,N3_TXDEPR1,N3_DINDEPR,N3_VORIG1,N3_VMXDEPR,N1_GRUPO," + CRLF
cQuery += "N1_DESCRIC,N1_PRZDEPR,N4_TIPO,N4_OCORR,N4_TIPOCNT,N4_DATA, N4_MOTIVO, sum(N4_VLROC1) NVALMOEDAC,SUM(" + cCpoMoedaF + ")  NVALMOEDAF" + CRLF

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
cQuery += " AND (SN1B.N1_TPDEPR = '' OR SN1B.N1_TPDEPR = '" + cTpDepr + "') " + CRLF

/* nao permitir itens com reavaliacoes */
cQuery += " AND NOT EXISTS( SELECT 1 FROM "+ RetSqlName("SN3") +" SN3R "+ CRLF
cQuery += " WHERE SN3R.N3_FILIAL = SN1B.N1_FILIAL "+ CRLF
cQuery += " AND SN3R.N3_CBASE = SN1B.N1_CBASE "+ CRLF
cQuery += " AND SN3R.N3_ITEM = SN1B.N1_ITEM "+ CRLF
cQuery += " AND SN3R.N3_TIPO IN ('02','05')"	+ CRLF
cQuery += " AND SN3R.D_E_L_E_T_ = '') "+ CRLF  

/* nao permitir itens baixados por desmembramento */
cQuery += " AND NOT EXISTS( SELECT 1 FROM "+ RetSqlName("SN4") +" SN4R "+ CRLF
cQuery += " WHERE SN4R.N4_FILIAL = SN1B.N1_FILIAL "+ CRLF
cQuery += " AND SN4R.N4_CBASE = SN1B.N1_CBASE "+ CRLF
cQuery += " AND SN4R.N4_ITEM = SN1B.N1_ITEM "+ CRLF
cQuery += " AND SN4R.N4_MOTIVO = '80' "	+ CRLF
cQuery += " AND SN4R.D_E_L_E_T_ = '') "+ CRLF  

//----------
/**/
If MV_PAR03 == 1		//corporeo
	cQuery += " and SN1B.N1_NATBEM = 'C'"+ CRLF
ElseIf MV_PAR03 == 2	//incorporeo
	cQuery += " and SN1B.N1_NATBEM = 'I'"+ CRLF   
ElseIf MV_PAR03 == 3	//Propriedade de Investimento
	cQuery += " and SN1B.N1_NATBEM = 'R'"+ CRLF   
Endif

/*If MV_PAR03 == 3
	cQuery += " and SN3B.N3_TIPO='01' and SN3B.N3_BAIXA = '1'"+ CRLF
	cQuery += " and SN3B.N3_DTBAIXA >= '" + Dtos(MV_PAR01) + "'"+ CRLF
	cQuery += " and SN3B.N3_DTBAIXA <= '" + Dtos(MV_PAR02) + "'"+ CRLF
	cQuery += " and SN3B.N3_IDBAIXA <>  '3'"+ CRLF // BAIXA POR TRANSFERENCIA
Else  */ 

cQuery += " and ("+ CRLF
cQuery += " (SN3B.N3_TIPO='01' and SN3B.N3_BAIXA = '0')"+ CRLF
cQuery += " or"+ CRLF
cQuery += " (SN3B.N3_TIPO='01' and SN3B.N3_BAIXA = '1' and SN3B.N3_DTBAIXA > '" + Dtos(MV_PAR02) + "')"+ CRLF
cQuery += ")"+ CRLF   

/*Endif*/    

cQuery += " and SN4.N4_DATA <= '" + Dtos(MV_PAR02) + "'"/* AND SN1B.N1_CBASE = '000150'"*/+ CRLF
cQuery += " group by SN3B.N3_CCONTAB,SN3B.N3_CBASE,SN3B.N3_ITEM,SN4.N4_TIPO,SN4.N4_OCORR,SN4.N4_TIPOCNT,SN4.N4_DATA, SN4.N4_MOTIVO, "
cQuery += " SN3B.N3_AQUISIC,SN3B.N3_AQUISIC,SN3B.N3_TXDEPR1,SN3B.N3_DINDEPR,SN3B.N3_DTBAIXA,SN1B.N1_DESCRIC,SN1B.N1_PRZDEPR,SN1B.N1_GRUPO,N3_VORIG1,N3_VMXDEPR"+ CRLF

If SN3->(FieldPos("N3_MVALNTR")) > 0 .And. SN3->(FieldPos("N3_MVALANO")) > 0
	cQuery += " ,N3_MVALNTR,N3_MVALANO "+ CRLF
EndIf

cQuery += " order by SN3B.N3_CCONTAB,SN3B.N3_CBASE,SN3B.N3_ITEM"+ CRLF
cQuery := ChangeQuery(cQuery)

MemoWrite( 'ATFR404.SQL', cQuery )
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArq,.T.,.T.)
TCSetField(cArq,"N3_DINDEPR","D")
TCSetField(cArq,"N3_AQUISIC","D")
TCSetField(cArq,"N3_DTBAIXA","D")
TCSetField(cArq,"N4_DATA","D")
(cArq)->(DbGoTop())
Return(cArq)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ImpCabec  º Autor ³ Cristina Barroso   º Data ³  04/09/09    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Impressao do cabecalho                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpCabec()
Local aPalavras	:= {}   
Private oBr  := TBrush():New(,CLR_BLACK,,)


oRelATF :STARTPAGE()

//oRelATF :SayBitmap(510,100, "\systemsod\col321_1.bmp", 171,339) //
//oRelATF :SayBitmap(560,1020, "\systemsod\col321_2.bmp", 127.5,213) //  85,142
//oRelATF :SayBitmap(570,1530, "\systemsod\col321_3.bmp", 71,190) //
//oRelATF :SayBitmap(560,2480, "\systemsod\col321_4.bmp", 106.5,285) //  71,190

oRelATF :Box(120,100,500,1040)
oRelATF :Say(180,120,SM0->M0_NOMECOM,oFont10) 

oRelATF :Say(240,120,STR0012 + "  " + transform(SM0->M0_CGC,PesqPict("SA1","A1_CGC")),oFont10) 	//"Numero de identificacao fiscal"

oRelATF :Say(300,120,STR0007 + "  " + transform(cExerc,"@R 9 9 9 9"),oFont10)		//"Periodo de tributacao

oRelATF :Box(120,1050,200,2740)   
oRelATF :Line(210,1895,500,1895)  

oRelATF :Say(140,1900,STR0031,oFont14N,650,,,2)//"MAPA DE DEPRECIACOES E AMORTIZACOES
oRelATF :Box(210,1050,500,2740)

oRelATF :Line(270,1050,270,1895)
oRelATF :Line(270,1895,270,2740)   

oRelATF :Say(220,1300,STR0045,oFont10N,650,,,2) //Natureza dos activos
oRelATF :Say(300,1200,STR0046,oFont08) // activos fixos tangives
oRelATF :Say(360,1200,STR0047,oFont08) // activos intangiveis
oRelATF :Say(420,1200,STR0048) 			// propriedades de investimento
oRelATF :Box(300,1660,330,1690) 
oRelATF :Box(360,1660,390,1690) 
oRelATF :Box(420,1660,450,1690)  

oRelATF :Say(220,2095,STR0049,oFont10N,650,,,2) //Metodo utilizado
oRelATF :Say(300,2045,STR0050,oFont08) // quotas constantes
oRelATF :Say(360,2045,STR0051,oFont08) // quotas decrescentes
oRelATF :Say(420,2045,STR0052) 			// Outro
oRelATF :Box(300,2505,330,2535) 
oRelATF :Box(360,2505,390,2535) 
oRelATF :Box(420,2505,450,2535)  

Do Case
	Case MV_PAR03 == 1		//corporeo    
		oRelATF :FillRect({300,1660,330,1690},oBr)  		//"Imobilizado Corpóreo"
	Case MV_PAR03 == 2		//incorporeo
		oRelATF :FillRect({360,1660,390,1690},oBr)  		//"Imobilizado Incorpóreo"
	Case MV_PAR03 == 3		//Propriedades de Investimento
		oRelATF :FillRect({420,1660,450,1690},oBr)  		//"Propriedade de Investimento"
EndCase

Do Case
	Case MV_PAR04 == 1		//corporeo    
		oRelATF :FillRect({300,2505,330,2535},oBr)  		//"Quotas Constantes
	Case MV_PAR04 == 2		//incorporeo
		oRelATF :FillRect({360,2505,390,2535},oBr)  		//"Quotas Decrescentes
	Case MV_PAR04 == 3		//Abatidos
		oRelATF :FillRect({420,2505,450,2535},oBr)  		//"Outros
EndCase 

oRelATF :Box(120,2750,500,3200)
//oRelATF :SayBitmap(180,2800, "\systemsod\IRC.bmp",375,139) // Tem que estar abaixo do RootPath
oRelATF :Say(420,2800,STR0002,oFont10)		//"MODELO"
oRelATF :Say(390,3000,"32",oFont24N)

/*
Cabecalho das colunas */
oRelATF :Box(520,100,2300,3200)
oRelATF :line(840,100,840,3200)	//horiz

oRelATF :line(840,260,2300,260)    //1
oRelATF :line(840,1050,2300,1050)  //2
oRelATF :line(840,1110,2300,1110)  //3
oRelATF :line(840,1190,2300,1190)  //4
oRelATF :line(840,1390,2300,1390)  //5  
oRelATF :line(840,1590,2300,1590)  //6  
oRelATF :line(840,1660,2300,1660)  //7 
oRelATF :line(840,1860,2300,1860)  //8 
oRelATF :line(840,2060,2300,2060)  //9
oRelATF :line(840,2190,2300,2190)  //10
oRelATF :line(840,2320,2300,2320)  //11
oRelATF :line(840,2520,2300,2520)  //12
oRelATF :line(840,2720,2300,2720)  //13
oRelATF :line(840,2800,2300,2800)  //14
oRelATF :line(840,3000,2300,3000)  //15

oRelATF :line(520,260,840,260)
aPalavras := ATFBrkStr(STR0033,11,5)		//codigo de acordo com a tabela anexa ao DR n. 25/2009
oRelATF :Say(570,175,aPalavras[1],oFont08,80,,,2)
oRelATF :Say(610,175,aPalavras[2],oFont08,80,,,2)
oRelATF :Say(650,175,aPalavras[3],oFont08,80,,,2)
oRelATF :Say(690,175,aPalavras[4],oFont08,80,,,2)
oRelATF :Say(730,175,aPalavras[5],oFont08,80,,,2)

oRelATF :Say(680,460,STR0015,oFont08)					//Descricao dos elementos do activo
oRelATF :line(520,1050,840,1050)

oRelATF :Say(530,1090,STR0026,oFont08)  			//"Data"
oRelATF :line(580,1050,580,1190)

aPalavras := ATFBrkStr(STR0034,10,2)		//"Inicio de utilizacao"
oRelATF :Say(610,1120,aPalavras[1],oFont08,150,,,2)
oRelATF :Say(650,1120,aPalavras[2],oFont08,150,,,2)
oRelATF :line(740,1050,740,1190)

oRelATF :Say(780,1060,STR0023,oFont08)		//"Mes"
oRelATF :line(740,1110,840,1110)
oRelATF :Say(780,1125,STR0022,oFont08)		//"Ano"
oRelATF :line(520,1190,840,1190)  

oRelATF :Say(530,1390,STR0041,oFont08)  			//"Activos"
oRelATF :line(580,1190,580,1660)   

aPalavras := ATFBrkStr(STR0035,14,3)	//valor contabilistico registado
oRelATF :Say(630,1290,aPalavras[1],oFont08,250,,,2)
oRelATF :Say(670,1290,aPalavras[2],oFont08,250,,,2)
oRelATF :Say(710,1290,aPalavras[3],oFont08,250,,,2)
oRelATF :line(580,1390,840,1390)

//NOVA COLUNA
aPalavras := ATFBrkStr(STR0042,14,5)	//valores de aquisição ou producao para efeitos fiscais
oRelATF :Say(630,1490,aPalavras[1],oFont08,250,,,2)
oRelATF :Say(670,1490,aPalavras[2],oFont08,250,,,2)
oRelATF :Say(710,1490,aPalavras[3],oFont08,250,,,2)
oRelATF :Say(750,1490,aPalavras[4],oFont08,250,,,2)
oRelATF :Say(790,1490,aPalavras[5],oFont08,250,,,2)

oRelATF :line(580,1590,840,1590)

aPalavras := ATFBrkStr(STR0036,5,2)		//"Ano Util."
oRelATF :Say(650,1620,aPalavras[1],oFont08,250,,,2)
oRelATF :Say(690,1620,aPalavras[2],oFont08,250,,,2)
oRelATF :line(520,1660,840,1660)

//NOVA COLUNA
aPalavras := ATFBrkStr(STR0037,14,6)		//"Depreciacoes / amortizacoes e perdas por imparidade contabilizadas no periodo
oRelATF :Say(590,1760,aPalavras[1],oFont08,250,,,2)
oRelATF :Say(630,1760,aPalavras[2],oFont08,250,,,2)
oRelATF :Say(670,1760,aPalavras[3],oFont08,250,,,2)
oRelATF :Say(710,1760,aPalavras[4],oFont08,250,,,2)
oRelATF :Say(750,1760,aPalavras[5],oFont08,250,,,2)
oRelATF :Say(790,1760,aPalavras[6],oFont08,250,,,2)
oRelATF :line(520,1860,840,1860)

oRelATF :Say(530,2200,STR0017,oFont08)  					//Gastos Fiscais
oRelATF :line(580,1860,580,2720)

aPalavras := ATFBrkStr(STR0038,14,5)						//Depreciacoes e amortizacoes aceites em periodos anteriores
oRelATF :Say(630,1965,aPalavras[1],oFont08,250,,,2)
oRelATF :Say(670,1965,aPalavras[2],oFont08,250,,,2)
oRelATF :Say(710,1965,aPalavras[3],oFont08,250,,,2)
oRelATF :Say(750,1965,aPalavras[4],oFont08,250,,,2)
oRelATF :Say(790,1965,aPalavras[5],oFont08,250,,,2)
oRelATF :line(580,2060,840,2060)  

oRelATF :Say(620,2300,STR0039,oFont08,380,,,2) 				//Depreciacoes e amortizacoes
oRelATF :line(715,2060,715,2520)

oRelATF :Say(780,2080,STR0020,oFont08)  					//"Taxas"
oRelATF :line(715,2190,840,2190)

aPalavras := ATFBrkStr(STR0021,10,3)						//"Taxas corrigidas %"
oRelATF :Say(730,2250,aPalavras[1],oFont08,250,,,2)
oRelATF :Say(770,2250,aPalavras[2],oFont08,250,,,2)
oRelATF :Say(810,2250,aPalavras[3],oFont08,250,,,2)
oRelATF :line(715,2320,840,2320)

aPalavras := ATFBrkStr(STR0043,15,2)			//Limite fiscal do periodo		
oRelATF :Say(750,2420,aPalavras[1],oFont08,250,,,2)
oRelATF :Say(790,2420,aPalavras[2],oFont08,250,,,2)
oRelATF :line(580,2520,840,2520)

aPalavras := ATFBrkStr(STR0018,14,5)							//Perdas por imparidade aceites no periodo
oRelATF :Say(630,2620,aPalavras[1],oFont08,250,,,2)
oRelATF :Say(670,2620,aPalavras[2],oFont08,250,,,2)
oRelATF :Say(710,2620,aPalavras[3],oFont08,250,,,2)
oRelATF :Say(750,2620,aPalavras[4],oFont08,250,,,2)
oRelATF :Say(790,2620,aPalavras[5],oFont08,250,,,2)

oRelATF :line(520,2720,840,2720)

aPalavras := ATFBrkStr(STR0040,7,3)							//Taxa Perdidas acumul.
oRelATF :Say(630,2760,aPalavras[1],oFont08,250,,,2)
oRelATF :Say(670,2760,aPalavras[2],oFont08,250,,,2)
oRelATF :Say(710,2760,aPalavras[3],oFont08,250,,,2)
oRelATF :line(520,2800,840,2800)    

aPalavras := ATFBrkStr(STR0019,18,6)							//Depreciacoes / amortizacoes e perdas por imparidade nao aceites como gastos
oRelATF :Say(590,2900,aPalavras[1],oFont08,250,,,2)
oRelATF :Say(630,2900,aPalavras[2],oFont08,250,,,2)
oRelATF :Say(670,2900,aPalavras[3],oFont08,250,,,2)
oRelATF :Say(710,2900,aPalavras[4],oFont08,250,,,2)
oRelATF :Say(750,2900,aPalavras[5],oFont08,250,,,2)
oRelATF :Say(790,2900,aPalavras[6],oFont08,250,,,2)
oRelATF :line(520,3000,840,3000)    

aPalavras := ATFBrkStr(STR0044,15,6)						//Depreciacoes / amortizacoes e perdas por imparidade recuperadas no periodo
oRelATF :Say(590,3100,aPalavras[1],oFont08,250,,,2)
oRelATF :Say(630,3100,aPalavras[2],oFont08,250,,,2)
oRelATF :Say(670,3100,aPalavras[3],oFont08,250,,,2)
oRelATF :Say(710,3100,aPalavras[4],oFont08,250,,,2)
oRelATF :Say(750,3100,aPalavras[5],oFont08,250,,,2)
oRelATF :Say(790,3100,aPalavras[6],oFont08,250,,,2)
oRelATF :line(520,3000,840,3000)    

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ImpRodape º Autor ³ Cristina Barroso   º Data ³  04/09/09    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Impressao do rodape                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpRodape()
//oRelATF :SayBitmap(2320,1290, "\systemsod\SOMBRA250.bmp", 250,70) //
//oRelATF :SayBitmap(2320,1590, "\systemsod\SOMBRA250.bmp", 250,70) //
//oRelATF :SayBitmap(2320,1970, "\systemsod\SOMBRA250.bmp", 250,70) //
//oRelATF :SayBitmap(2320,2220, "\systemsod\SOMBRA250.bmp", 250,70) //
//oRelATF :SayBitmap(2320,2950, "\systemsod\SOMBRA250.bmp", 250,70) //
oRelATF :FillRect({2320,1190,2390,1390},oBrR)
oRelATF :FillRect({2320,1660,2390,1860},oBrR)
oRelATF :FillRect({2320,1860,2390,2060},oBrR)
oRelATF :FillRect({2320,2320,2390,2520},oBrR)
oRelATF :FillRect({2320,2520,2390,2720},oBrR)

oRelATF :Box(2320,100,2390,3200)
oRelATF :line(2320,1190,2390,1190)
oRelATF :line(2320,1390,2390,1390)
oRelATF :line(2320,1590,2390,1590)
oRelATF :line(2320,1660,2390,1660)
oRelATF :line(2320,1860,2390,1860) 
oRelATF :line(2320,2060,2390,2060)
oRelATF :line(2320,2190,2390,2190)
oRelATF :line(2320,2320,2390,2320)
oRelATF :line(2320,2520,2390,2520)
oRelATF :line(2320,2720,2390,2720)
oRelATF :line(2320,2800,2390,2800)
oRelATF :line(2320,3000,2390,3000)

oRelATF :Say(2330,750,STR0027,oFont10)  		//"Total geral ou a transportar"
oRelATF :Say(2400,1600,STR0028,oFont10N,,,,2) 	//"Documento emitido por computador"

oRelATF :Say(2330,1380,transform(nTotValAqu,cPictM1),oFont10,,,,1)
oRelATF :Say(2330,1850,transform(nTotAmorEx,cPictM1),oFont10,,,,1)
oRelATF :Say(2330,2050,transform(nTotAmorAnt,cPictM1),oFont10,,,,1)
oRelATF :Say(2330,2510,transform(nTotLimF,cPictM1),oFont10,,,,1)
oRelATF :Say(2330,2710,transform(nTotImpF,cPictM1),oFont10,,,,1)

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
Local nX        := 0
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
Aadd(aPergs,{cPergunta,"03","Natureza  ?" , "Natureza ?" , "Natureza  ?" ,"mv_ch3","N",1,0,1,"C","","mv_par03","Imob. Corpóreo","Imob. Corpóreo","Imob. Corpóreo","","","Imob.Incorpóreo","Imob.Incorpóreo","Imob.Incorpóreo","","","Prop. Invest.","Prop. Invest.","Prop. Invest.","","","","","","","","","","","","","","S"})
Aadd(aPergs,{cPergunta,"04","Método Utiliz. ?" , "Método Utiliz. ?" , "Método Utiliz. ?" ,"mv_ch4","N",1,0,1,"C","","mv_par04","Quotas Constantes","Quotas Constantes","Quotas Constantes","","","Quotas Decrescentes","Quotas Descrescentes","Quotas Decrescentes","","","","","","","","","","","","","","","","","","","S"})

ProcRegua(Len(aPergs))
dbSelectArea("SX1")
dbSetOrder(1)  

If SX1->(DbSeek(Padr( cPergunta,Len(SX1->X1_GRUPO))+ "03"))
	If SX1->X1_DEF03 == "Abatidos no exe"     
   		RecLock( "SX1", .F.)
		dbDelete()
		dbCommit()
	Endif  
Endif     

For nI:= 1 To Len(aPergs)

	If !dbSeek( padr( "ATR404" , Len( X1_GRUPO ) , ' ' ) + "0" + AllTrim(Str(nI))) 

		RecLock("SX1",.T.)

		For nx := 1 To Len(aPergs[nI])
			If !Empty(FieldName(FieldPos(aEstrut[nX])))
			FieldPut(FieldPos(aEstrut[nX]),aPergs[nI,nX])
		EndIf
	
		Next nX
		MsUnLock()
		dbCommit()
		IncProc(STR0030 + "...")		//"Atualizando Perguntas de Relatorios"

	Endif

Next nI

/*
Inclusao do "help" */
AADD(aHelpPor,"Informe a data inicial do intervalo de")
AADD(aHelpPor,"datas para que se obtenha o resultado")
AADD(aHelpPor,"desejado no relatório.")
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
AADD(aHelpPor,"desejado no relatório.")
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
AADD(aHelpPor,"este relatório.")
Aadd(aHelpSpa,"Indique el grupo de activos deseado")
Aadd(aHelpSpa,"para este informe.")
Aadd(aHelpEng,"Enter the group for this report.")
PutSX1Help("P." + cPergunta + "03.",aHelpPor,aHelpEng,aHelpSpa,.T.)
AHelpPor := {}
AHelpEng := {}
AHelpSpa := {}
RestArea(aSaveArea)
Return()
