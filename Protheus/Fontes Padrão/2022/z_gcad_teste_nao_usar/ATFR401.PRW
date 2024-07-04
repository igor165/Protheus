#INCLUDE "PROTHEUS.CH" 
#INCLUDE "COLORS.CH" 
#INCLUDE "ATFR401.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ ATFR401   º Autor ³ Cristina Barroso   º Data ³  10/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Mapa Fiscal modelo 31                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFR401() 
Local cPerg			:= "ATR401"

Private cMoedATF	:= ""
Private cExerc		:= ""
Private oRelATF

//Parametros de perguntas para o relatorio
//+-------------------------------------------------------------------------------------------------+
//| mv_par01 - DATA DE     ? 																		|
//| mv_par02 - DATA ATE    ? 																		|
//| mv_par03 - Natureza    ? corporeo / nao corporeo / financeiro                                   |
//+-------------------------------------------------------------------------------------------------+
CriaSx1(cPerg) 

If Pergunte(cPerg,.T.)                
	cExerc := StrZero(Year(MV_PAR02),4)
	cMoedATF := GetMV("MV_ATFMOED")
	oRelATF	:= TMSPrinter():New(STR0001 + " - " + STR0002 + "31") //"MAPA"###"MODELO"
	oRelATF:SetLandscape()
	RptStatus({|lEnd| ImpRelATF(@lEnd)},STR0003) //"A imprimir Mapa..."
	oRelATF:Preview()
Endif
Return()

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
Local cCtaContab	:= "" 
Local cDescric		:= "" 
Local cAnoAqu		:= ""
      
Local nVlMot14      := 0
Local nVlMot15      := 0  
Local nVlRealiz     := 0
Local nVlAqFis      := 0
Local nVlAqCtb      := 0
Local nVlReav       := 0
Local nVlReinv      := 0
Local nVlDepr       := 0
Local nVlDeprF      := 0

/* Totalizadores da conta contabil */
Local nCCTotReal	:= 0
Local nCCTotVCon	:= 0
Local nCCTotVFis	:= 0
/**/
Local nLin			:= 0
Local nTaxa			:= 0
Local nDecs1		:= MsDecimais(1)
Local lImprimir		:= .T. 

// colunas do relatorio
Local nValiaCon		:= 0
Local nValiaNTri	:= 0
Local nReIntFis		:= 0
Local nCoefDesv		:= 0
Local nValiaFis		:= 0  

Private oFont08		:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
Private oFont06		:= TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
Private oFont10		:= TFont():New("Arial",8.5,8.5,,.F.,,,,.T.,.F.)
Private oFont10n	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Private oFont08n	:= TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
Private oFont11		:= TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)
Private oFont12		:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Private oFont13		:= TFont():New("Arial",13,13,,.F.,,,,.T.,.F.)
Private oFont14		:= TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
Private oFont14a	:= TFont():New("Arial",18,14,,.F.,,,,.T.,.F.)
Private oFont12N	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
Private oFont16N	:= TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
Private oFont24N	:= TFont():New("Arial",24,24,,.T.,,,,.T.,.F.)

Private oBr  		:= TBrush():New(,CLR_BLACK,,)
Private oBrR 		:= TBrush():New(,RGB(228,224,224),,)		//mesma cor usada no bitmap SOMBRA250.bmp

// Totalizadores
Private nTotValRealiz	:= 0
Private nTotValCon   	:= 0
Private nTotValFis		:= 0
Private cPictM1			:= ""
Private cPictM3			:= ""
Private cPictCoef		:= ""
  
MsgRun(STR0004 + ".",,{|| cArqAtivos := GeraDados()}) //"Selecionando os dados para a impressão do mapa"

cPictM1   := PesqPict("SN4","N4_VLROC1")
cPictM3   := PesqPict("SN4","N4_VLROC" + cMoedATF)
cPictCoef := Replicate("9",TamSX3("IE_INDICE")[1]-3) + ".99"

DbSelectArea("SN4")
SN4->(dbSetOrder(4)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_OCORR+N4_DATA

DbSelectArea(cArqAtivos)
(cArqAtivos)->(DbGoTop()) 

While lImprimir .And. !((cArqAtivos)->(Eof()))
	ImpCabec()
	nlin := 760
	While lImprimir .And. !((cArqAtivos)->(Eof())) .And. (nlin < 2240)
		cCtaContab := (cArqAtivos)->N3_CCONTAB
		While lImprimir .And. !((cArqAtivos)->(Eof())) .And. ((cArqAtivos)->N3_CCONTAB == cCtaContab) .And. (nlin < 2240)
			cBase 	   := (cArqAtivos)->N3_CBASE
			cItem	   := (cArqAtivos)->N3_ITEM
			cDescric   := AllTrim((cArqAtivos)->N1_DESCRIC) + "  (" + Alltrim((cArqAtivos)->N3_CBASE) + ")"'
			nTaxa	   := Min((cArqAtivos)->N3_TXDEPR1,100)

			nCoefDesv  := 0
			nVlRealiz  := 0  
			nVlAqFis   := 0
			nVlAqCtb   := 0  
			nVlDepr	   := 0	 
			nVlDeprF   := 0
			nVlReav    := 0 
			nVlReinv   := 0
			nVlMot14   := 0
			nVlMot15   := 0
			nValiaCon  := 0
			nValiaNTri := 0
			nValiaFis  := 0
			cAnoAqu	   := ""
			cSinalFis  := ""
			cSinalCon  := ""

			If SIE->(DbSeek(xFilial("SIE") + StrZero(Year((cArqAtivos)->N3_AQUISIC),4)))
				nCoefDesv := SIE->IE_INDICE
			Endif
			
			While lImprimir .And. !((cArqAtivos)->(Eof())) .And. ((cArqAtivos)->N3_CBASE == cBase) .And. ((cArqAtivos)->N3_CCONTAB == cCtaContab) .And. ((cArqAtivos)->N3_ITEM == cItem)

				nVlRealiz     := (cArqAtivos)->VLREALIZ 
				nVlAqCtb      := (cArqAtivos)->VLMOEDAC  
				nVlReav       := (cArqAtivos)->VLREAV - (cArqAtivos)->VLREAVN 
				nVlReinv      := (cArqAtivos)->VLREINV  
				nVlDepr       := (cArqAtivos)->VLDEPR  
				nVlMot14      := (cArqAtivos)->VLIMPARFIS  
				nVlMot15      := (cArqAtivos)->VLIMPAR   
				nVlDeprF      := (cArqAtivos)->VLDEPRFIS
                cAnoAqu       := StrZero(Year((cArqAtivos)->N3_AQUISIC),4) 
                
       			nTotValRealiz   += (cArqAtivos)->VLREALIZ 

				If (cArqAtivos)->N3_VMXDEPR > 0
					nVlAqFis := (cArqAtivos)->N3_VMXDEPR
				Else  
					nVlAqFis := (cArqAtivos)->VLMOEDAC  
				Endif
	
				If lEnd
					lImprimir := .F.
					oRelATF:Say(nlin,1605,STR0005,oFont24N,650,,,2) //"CANCELADO PELO OPERADOR"
				Endif
				(cArqAtivos)->(DbSkip())
			Enddo 
			
			If SN3->(FieldPos("N3_MVALNTR")) > 0 .And. nValiaNTri <= 0 
				nValiaNTri := (cArqAtivos)->N3_MVALNTR	
			EndIf   
			       
			nVlDepr    		+= nVlMot14 + nVlMot15
			nVlDeprF 		+= nVlMot14 
			nValiaCon       := nVlRealiz  - (nVlAqCtb - nVlDepr)
			nValiaFis       := (nVlRealiz - ((nVlAqFis - nValiaNTri - nVlDeprF) * nCoefDesv))
     		nVlDeprF		+= Round(nValiaNTri * nTaxa / 100,nDecs1)

			nTotValCon   	+= nValiaCon
			nTotValFis	    += nValiaFis  
			
			/**/
			nCCTotReal		+= nVlRealiz
			nCCTotVCon 		+= nValiaCon
			nCCTotVFis		+= nValiaFis 
			
			/**/
			oRelATF:Say(nlin,120,cDescric,oFont08) // Coluna 01
			oRelATF:Say(nlin,1180,transform(nVlRealiz,cPictM1),oFont08,,,,1) // coluna 02
			oRelATF:Say(nlin,1400,transform(nVlAqFis,cPictM1),oFont08,,,,1) //coluna 03
			oRelATF:Say(nlin,1440,cAnoAqu,oFont08) // coluna 04   
			oRelATF:Say(nlin,1730,transform(nVlAqCtb,cPictM1),oFont08,,,,1) // coluna 05   
		  	oRelATF:Say(nlin,1960,transform(nVlDepr,cPictM1),oFont08,,,,1) // coluna 06
			oRelATF:Say(nlin,1990,If(nValiaCon > 0 ,"+","-"),oFont08) // coluna 07
			oRelATF:Say(nlin,2250,transform(Abs(nValiaCon),cPictM1),oFont08,,,,1) // coluna 08
			oRelATF:Say(nlin,2480,transform(nValiaNTri,cPictM1),oFont08,,,,1) // coluna 09

		 	oRelATF:Say(nlin,2710,transform(nVlDeprF,cPictM1),oFont08,,,,1) // coluna 10
			oRelATF:Say(nlin,2900,transform(nCoefDesv,cPictCoef),oFont08,,,,1) // coluna 11
			oRelATF:Say(nlin,2930,If(nValiaFis > 0 ,"+","-"),oFont08) // coluna 12
			oRelATF:Say(nlin,3190,transform(Abs(nValiaFis),cPictM1),oFont08,,,,1) // coluna 13
			nlin+= 40                       
		Enddo
		/* impressao do total por conta contabil */
		If !((cArqAtivos)->N3_CCONTAB == cCtaContab) .Or. ((cArqAtivos)->(Eof()))
			If lImprimir
				If nCCTotReal > 0
					oRelATF:Say(nlin,0950,STR0006 + " " + AllTrim(cCtaContab),oFont08n,,,,1) //"Totais da conta"
					oRelATF:Say(nlin,1180,transform(nCCTotReal,cPictM1),oFont08n,,,,1)
					oRelATF:Say(nlin,1990,If(nCCTotVCon > 0 ,"+","-"),oFont08n)
					oRelATF:Say(nlin,2250,transform(Abs(nCCTotVCon),cPictM1),oFont08n,,,,1)
					oRelATF:Say(nlin,2930,If(nCCTotVFis > 0 ,"+","-"),oFont08n)
					oRelATF:Say(nlin,3190,transform(Abs(nCCTotVFis),cPictM1),oFont08n,,,,1)
					nCCTotReal	  := 0
					nCCTotVCon  := 0
					nCCTotVFis  := 0
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

cCpoMoedaF := "N4_VLROC" + cMoedATF
cArq := GetNextAlias()  

cQuery := "SELECT N3_CCONTAB,N3_CBASE,N3_ITEM,N3_AQUISIC,N3_BAIXA,N3_DTBAIXA,N3_TXDEPR1,

If SN3->(FieldPos("N3_MVALNTR")) > 0 
	cQuery += "N3_MVALNTR," + CRLF
Endif
	
cQuery += "N3_VMXDEPR, N1_DESCRIC, N4_TIPO," + CRLF

cQuery += "(SELECT SUM(SN4SUB.N4_VENDA) FROM " + RetSqlName("SN4") + " SN4SUB WHERE SN4SUB.N4_CBASE = SN3.N3_CBASE AND" + CRLF
cQuery += " SN4SUB.N4_ITEM = SN3.N3_ITEM AND SN4SUB.D_E_L_E_T_=' ' AND SN4SUB.N4_MOTIVO = '01' AND SN4SUB.N4_OCORR = '01'" + CRLF
cQuery += " AND SN4SUB.N4_TIPOCNT = '1') VLREALIZ," + CRLF

cQuery += "(SELECT SUM(SN4SUB.N4_VLROC1) FROM " + RetSqlName("SN4") + " SN4SUB WHERE SN4SUB.N4_CBASE = SN3.N3_CBASE AND SN4SUB.N4_ITEM = SN3.N3_ITEM AND" + CRLF
cQuery += " SN4SUB.D_E_L_E_T_= ' ' AND SN4SUB.N4_TIPO = '01' AND SN4SUB.N4_OCORR IN  ('05','86')) VLMOEDAC," + CRLF  

cQuery += "(SELECT SUM(SN4SUB.N4_VLROC1) FROM " + RetSqlName("SN4") + " SN4SUB WHERE SN4SUB.N4_CBASE = SN3.N3_CBASE AND SN4SUB.N4_ITEM = SN3.N3_ITEM AND" + CRLF
cQuery += " SN4SUB.D_E_L_E_T_= ' ' AND SN4SUB.N4_TIPO = '02' AND SN4SUB.N4_TIPOCNT = '1') VLREAV," + CRLF   

cQuery += "(SELECT SUM(SN4SUB.N4_VLROC1) FROM " + RetSqlName("SN4") + " SN4SUB WHERE SN4SUB.N4_CBASE = SN3.N3_CBASE AND SN4SUB.N4_ITEM = SN3.N3_ITEM AND" + CRLF
cQuery += " SN4SUB.D_E_L_E_T_= ' ' AND SN4SUB.N4_TIPO = '05' AND SN4SUB.N4_TIPOCNT = '1') VLREAVN," + CRLF   

cQuery += "(SELECT SUM(SN4SUB.N4_VLROC1) FROM " + RetSqlName("SN4") + " SN4SUB WHERE SN4SUB.N4_CBASE = SN3.N3_CBASE AND SN4SUB.N4_ITEM = SN3.N3_ITEM AND" + CRLF
cQuery += " SN4SUB.D_E_L_E_T_= ' ' AND SN4SUB.N4_TIPO = '33' AND SN4SUB.N4_OCORR IN ('05','86') AND SN4SUB.N4_TIPOCNT = '1') VLREINV," + CRLF   

cQuery += "(SELECT SUM(N4_VLROC1) FROM " + RetSqlName("SN4") + " SN4SUB WHERE SN4SUB.D_E_L_E_T_= ' ' AND SN4SUB.N4_MOTIVO = '14' AND" + CRLF
cQuery += " SN4SUB.N4_TIPO = '01' AND SN4SUB.N4_OCORR = '01' AND SN4SUB.N4_CBASE = SN3.N3_CBASE AND SN4SUB.N4_ITEM = SN3.N3_ITEM) VLIMPARFIS," + CRLF

cQuery += "(SELECT SUM(N4_VLROC1) FROM " + RetSqlName("SN4") + " SN4SUB WHERE SN4SUB.D_E_L_E_T_= ' ' AND SN4SUB.N4_MOTIVO = '15' AND" + CRLF 
cQuery += " SN4SUB.N4_TIPO = '01' AND SN4SUB.N4_OCORR = '01' AND SN4SUB.N4_CBASE = SN3.N3_CBASE AND SN4SUB.N4_ITEM = SN3.N3_ITEM) VLIMPAR," + CRLF

cQuery += "(SELECT SUM(N4_VLROC1) FROM " + RetSqlName("SN4") + " SN4SUB WHERE SN4SUB.D_E_L_E_T_= ' ' AND SN4SUB.N4_TIPOCNT = '3' AND" + CRLF 
cQuery += " SN4SUB.N4_TIPO IN ('01','02') AND SN4SUB.N4_OCORR = '06' AND SN4SUB.N4_CBASE = SN3.N3_CBASE AND" + CRLF 
cQuery += " SN4SUB.N4_ITEM = SN3.N3_ITEM)  VLDEPR," + CRLF   

cQuery += "(SELECT SUM(" + cCpoMoedaF + ") FROM " + RetSqlName("SN4") + " SN4SUB WHERE SN4SUB.D_E_L_E_T_= ' ' AND SN4SUB.N4_TIPOCNT = '3' AND" + CRLF 
cQuery += " SN4SUB.N4_TIPO = '01' AND SN4SUB.N4_OCORR = '06' AND SN4SUB.N4_CBASE = SN3.N3_CBASE AND" + CRLF 
cQuery += " SN4SUB.N4_ITEM = SN3.N3_ITEM)  VLDEPRFIS" + CRLF

cQuery += " FROM " + RetSqlName("SN3") + " SN3," + RetSqlName("SN1") + " SN1," + RetSqlName("SN4") +  " SN4"+ CRLF
  
cQuery += " WHERE SN4.D_E_L_E_T_='' AND SN1.D_E_L_E_T_='' AND SN3.D_E_L_E_T_=''"+ CRLF
cQuery += " AND SN1.N1_FILIAL = '" + xFilial("SN1") + "'"+ CRLF
cQuery += " AND SN4.N4_FILIAL = '" + xFilial("SN4") + "'"+ CRLF
cQuery += " AND SN3.N3_FILIAL = '" + xFilial("SN3") + "'"+ CRLF
cQuery += " AND SN1.N1_CBASE = SN3.N3_CBASE"+ CRLF
cQuery += " AND SN1.N1_ITEM = SN3.N3_ITEM"+ CRLF
cQuery += " AND SN4.N4_CBASE = SN3.N3_CBASE"+ CRLF
cQuery += " AND SN4.N4_ITEM = SN3.N3_ITEM"+ CRLF 
cQuery += " AND SN4.N4_MOTIVO = '01'"+ CRLF 

cQuery += " AND SN3.N3_TIPO = '01'"+ CRLF
cQuery += " AND SN3.N3_BAIXA = '1'"+ CRLF
cQuery += " AND SN3.N3_DTBAIXA >= '" + Dtos(MV_PAR01) + "'"+ CRLF
cQuery += " AND SN3.N3_DTBAIXA <= '" + Dtos(MV_PAR02) + "'"   + CRLF
If MV_PAR03 == 1		//corporeo
	cQuery += " AND SN1.N1_NATBEM = 'C'"+ CRLF
ElseIf MV_PAR03 == 2	//incorporeo
	cQuery += " AND SN1.N1_NATBEM = 'I'"+ CRLF
ElseIf MV_PAR03 == 3	//propriedade de investimento
	cQuery += " AND SN1.N1_NATBEM = 'R'"+ CRLF   
ElseIf MV_PAR03 == 4	//activos biologicos nao consumiveis
	cQuery += " AND SN1.N1_NATBEM = 'B'"+ CRLF   
ElseIf MV_PAR03 == 5	//partes de capital
	cQuery += " AND SN1.N1_NATBEM = 'P'"+ CRLF   
	
Endif   

cQuery += "GROUP BY N3_CCONTAB,N3_CBASE,N3_ITEM,N3_AQUISIC,N3_BAIXA,N3_DTBAIXA,N3_TXDEPR1,"

If SN3->(FieldPos("N3_MVALNTR")) > 0 
	cQuery += "N3_MVALNTR," + CRLF
Endif

cQuery += "N3_VMXDEPR, N1_DESCRIC,N4_TIPO " + CRLF
cQuery += "ORDER BY N3_CCONTAB,N3_CBASE,N3_ITEM"

cQuery := ChangeQuery(cQuery) 

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArq,.T.,.T.)
TCSetField(cArq,"N3_AQUISIC","D")
TCSetField(cArq,"N3_DTBAIXA","D") 
TcSetField(cArq,"VLREALIZ","N",TamSX3("N4_VLROC1")[1],TamSX3("N4_VLROC1")[2])    
TcSetField(cArq,"VLMOEDAC","N",TamSX3("N4_VLROC1")[1],TamSX3("N4_VLROC1")[2])    
TcSetField(cArq,"VLIMPARFIS","N",TamSX3("N4_VLROC1")[1],TamSX3("N4_VLROC1")[2])   
TcSetField(cArq,"VLIMPAR","N",TamSX3("N4_VLROC1")[1],TamSX3("N4_VLROC1")[2])  
TcSetField(cArq,"VLDEPR","N",TamSX3("N4_VLROC1")[1],TamSX3("N4_VLROC1")[2])  
TcSetField(cArq,"VLDEPRFIS","N",TamSX3("N4_VLROC1")[1],TamSX3("N4_VLROC1")[2])   
TcSetField(cArq,"VLREAV","N",TamSX3("N4_VLROC1")[1],TamSX3("N4_VLROC1")[2])   
TcSetField(cArq,"VLREAVN","N",TamSX3("N4_VLROC1")[1],TamSX3("N4_VLROC1")[2])   
TcSetField(cArq,"VLREINV","N",TamSX3("N4_VLROC1")[1],TamSX3("N4_VLROC1")[2])   
TcSetField(cArq,"N3_VMXDEPR","N",TamSX3("N3_VMXDEPR")[1],TamSX3("N3_VMXDEPR")[2])   

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

oRelATF :STARTPAGE()

//oRelATF :SayBitmap(510,960, "\syssod\col31_1.bmp", 71,190) //
//oRelATF :SayBitmap(640,1730, "\syssod\col31_2.bmp", 60,90) //   
//oRelATF :SayBitmap(640,2900, "\syssod\col31_2.bmp", 60,90) //  

oRelATF :Box(120,100,500,2710)
oRelATF :Say(140,0900,STR0007,oFont16N,2100,,,2)   //"MAPA DAS MAIS-VALIAS E MENOS-VALIAS FISCAIS "
oRelATF :Say(280,120,SM0->M0_NOMECOM,oFont12)  
oRelATF :Say(280,1240,STR0008,oFont10)   //"Exercício de "
oRelATF :Say(270,1470,transform(cExerc,"@R 9 9 9 9"),oFont13)
oRelATF :Say(420,0840,STR0009,oFont10)   //"Número de identificação fiscal"
oRelATF :Say(410,1330,transform(SM0->M0_CGC,PesqPict("SA1","A1_CGC")),oFont13)  
oRelATF :line(120,1690,500,1690)   
oRelATF :Say(140,2150,STR0010,oFont12,550,,,2)   //"NATUREZA DOS BENS"
oRelATF :line(200,1690,200,2710)   
oRelATF :Say(240,1710,STR0044,oFont08)  //"ACTIVOS FIXO TANGIVEL"
oRelATF :Say(330,1710,STR0045,oFont08) //"ACTIVOS INTANGIVEIS"
oRelATF :Say(420,1710,STR0046,oFont08) //"PROPRIEDADES DE INVESTIMENTO"
oRelATF :Say(240,2220,STR0047,oFont08)  //"ACTIVOS BIOLOGICOS NAO CONSUMIVEIS"
oRelATF :Say(330,2220,STR0048,oFont08) //"PARTES DE CAPITAL"
oRelATF :Box(240,2150,270,2180) 
oRelATF :Box(330,2150,360,2180) 
oRelATF :Box(420,2150,450,2180) 
oRelATF :Box(240,2660,270,2690) 
oRelATF :Box(330,2660,360,2690) 

//Pinta o box correspondente ao tipo de ativo do map
If MV_PAR03 == 1		//corporeo
	oRelATF :FillRect({240,2150,270,2180},oBr)
ElseIf MV_PAR03 == 2	//incorporeo
	oRelATF :FillRect({330,2150,360,2180},oBr)
ElseIf MV_PAR03 == 3	//propriedade de investimento
	oRelATF :FillRect({420,2150,450,2180},oBr)
ElseIf MV_PAR03 == 4	//activos biologicos nao consumiveis
	oRelATF :FillRect({240,2660,270,2690},oBr)
ElseIf MV_PAR03 == 5	//partes de capital
	oRelATF :FillRect({330,2660,360,2690},oBr)
	
Endif   
oRelATF :Box(120,2750,500,3200) 
//oRelATF :SayBitmap(180,2800, "\syssod\IRC.bmp",375,139) // Tem que estar abaixo do RootPath 
oRelATF :Say(420,2800,STR0002,oFont10)		//"MODELO"
oRelATF :Say(390,3000,"31",oFont24N)

/*
Quadro e linhas internas
 */
oRelATF :Box(520,100,2300,3200) 
oRelATF :line(740,100,740,3200)	//horiz 
/**/
oRelATF :line(740,960,2300,960)     //1
oRelATF :line(740,1190,2300,1190)  	//2
oRelATF :line(740,1420,2300,1420)   //3 
oRelATF :line(740,1510,2300,1510)   //4 
oRelATF :line(740,1740,2300,1740)   //5 
oRelATF :line(740,1970,2300,1970)   //6 
oRelATF :line(740,2030,2300,2030)   //7 
oRelATF :line(740,2260,2300,2260)   //8 
oRelATF :line(740,2490,2300,2490)   //9 
oRelATF :line(740,2720,2300,2720)   //10 
oRelATF :line(740,2910,2300,2910)   //11  
oRelATF :line(740,2970,2300,2970)   //12  

/* Cabecalho do detalhe */
aPalavras := ATFBrkStr(STR0031,33,1)					//"Descricao dos elementos do activo"
oRelATF :Say(540,410,aPalavras[1],oFont08,820,,,2) 
oRelATF :line(520,960,740,960)  

aPalavras := ATFBrkStr(STR0032,10,2)					//"Valor de Realizacao"
oRelATF :Say(540,1075,aPalavras[1],oFont08,230,,,2)
oRelATF :Say(580,1075,aPalavras[2],oFont08,230,,,2)
oRelATF :line(520,1190,740,1190)

aPalavras := ATFBrkStr(STR0033,15,3)						//"Valor de Aquisição para efeitos fiscais"
oRelATF :Say(540,1305,aPalavras[1],oFont08,230,,,2)  
oRelATF :Say(580,1305,aPalavras[2],oFont08,230,,,2)
oRelATF :Say(620,1305,aPalavras[3],oFont08,230,,,2)

oRelATF :line(520,1420,740,1420)

aPalavras := ATFBrkStr(STR0034,6,2)						//"Ano Aquis."
oRelATF :Say(540,1460,aPalavras[1],oFont08,130,,,2)
oRelATF :Say(580,1460,aPalavras[2],oFont08,130,,,2)
oRelATF :line(520,1510,740,1510)  

aPalavras := ATFBrkStr(STR0035,15,4)					//"Valor de Aquisicao para efeitos contabilisticos"
oRelATF :Say(540,1625,aPalavras[1],oFont08,230,,,2)  
oRelATF :Say(580,1625,apalavras[2],oFont08,230,,,2)
oRelATF :Say(620,1625,aPalavras[3],oFont08,230,,,2)
oRelATF :Say(660,1625,aPalavras[4],oFont08,230,,,2)
oRelATF :line(520,1740,740,1740) 

aPalavras := ATFBrkStr(STR0036,15,5)					//"Depreciacoes / amortizacoes e perdas por imparidade registadas"
oRelATF :Say(540,1855,aPalavras[1],oFont08,230,,,2)  
oRelATF :Say(580,1855,aPalavras[2],oFont08,230,,,2)
oRelATF :Say(620,1855,aPalavras[3],oFont08,230,,,2) 
oRelATF :Say(660,1855,aPalavras[4],oFont08,230,,,2) 
oRelATF :Say(700,1855,aPalavras[5],oFont08,230,,,2) 

oRelATF :line(520,1970,740,1970) 

aPalavras := ATFBrkStr(STR0037,25,2)					//"mais-valia ou menos-valia contabilística"
oRelATF :Say(540,2105,aPalavras[1],oFont08,290,,,2)  
oRelATF :Say(580,2105,aPalavras[2],oFont08,290,,,2)
oRelATF :line(640,1970,640,2260)
oRelATF :line(640,2030,740,2030) 
oRelATF :Say(660,2000,STR0038,oFont08,230,,,2)			//"SIN."
oRelATF :Say(660,2145,STR0039,oFont08,230,,,2)			//"VALOR"
oRelATF :line(520,2260,740,2260) 
//oRelATF :line(520,2490,740,2490)

aPalavras := ATFBrkStr(STR0040,11,3)					//"Mais-valia nao tributada" 
oRelATF :Say(540,2375,aPalavras[1],oFont08,230,,,2)  
oRelATF :Say(580,2375,aPalavras[2],oFont08,230,,,2)
oRelATF :Say(620,2375,aPalavras[3],oFont08,230,,,2)
oRelATF :line(520,2490,740,2490) 

aPalavras := ATFBrkStr(STR0041,18,5)					//"Depreciacoes / amortizacoes e perdas por imparidade aceites fiscalmente"
oRelATF :Say(540,2605,aPalavras[1],oFont08,230,,,2)  
oRelATF :Say(580,2605,aPalavras[2],oFont08,230,,,2)
oRelATF :Say(620,2605,aPalavras[3],oFont08,230,,,2) 
oRelATF :Say(660,2605,aPalavras[4],oFont08,230,,,2)
oRelATF :Say(700,2605,aPalavras[5],oFont08,230,,,2)

oRelATF :line(520,2720,740,2720)

aPalavras := ATFBrkStr(STR0042,11,4)					//"Coeficiente de desvalorização da moeda"
oRelATF :Say(540,2815,aPalavras[1],oFont08,230,,,2)  
oRelATF :Say(580,2815,aPalavras[2],oFont08,230,,,2)
oRelATF :Say(620,2815,aPalavras[3],oFont08,230,,,2)   
oRelATF :Say(660,2815,aPalavras[4],oFont08,230,,,2)   
oRelATF :line(520,2910,740,2910) 

aPalavras := ATFBrkStr(STR0043,18,2)					//"Mais-valia ou menos-valia fiscal"
oRelATF :Say(540,3055,aPalavras[1],oFont08,290,,,2)  
oRelATF :Say(580,3055,aPalavras[2],oFont08,290,,,2)
oRelATF :line(640,2910,640,3200)
oRelATF :line(640,2970,740,2970) 
oRelATF :Say(660,2940,STR0038,oFont08,230,,,2)			//"SIN."
oRelATF :Say(660,3085,STR0039,oFont08,230,,,2)			//"VALOR"
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
oRelATF :FillRect({2320,960,2390,1190},oBrR)
oRelATF :FillRect({2320,2030,2390,2260},oBrR)
oRelATF :FillRect({2320,2970,2390,3200},oBrR)

oRelATF :Box(2320,100,2390,3200) 
oRelATF :line(2320,960,2390,960)
oRelATF :line(2320,1190,2390,1190)
oRelATF :line(2320,1970,2390,1970)
oRelATF :line(2320,2030,2390,2030)
oRelATF :line(2320,2260,2390,2260)
oRelATF :line(2320,2910,2390,2910)
oRelATF :line(2320,2970,2390,2970)

oRelATF :Say(2330,250,STR0014,oFont10)  		//"Total geral ou a transportar"
oRelATF :Say(2400,1400,STR0015,oFont10N)  		//"Documento emitido por computador"

oRelATF :Say(2330,1180,transform(nTotValRealiz,cPictM1),oFont10,,,,1)
oRelATF :Say(2330,1990,If(nTotValCon >=0,"+","-"),oFont08,,,,1)  
oRelATF :Say(2330,2250,transform(Abs(nTotValCon),cPictM1),oFont10,,,,1)
oRelATF :Say(2330,2930,If(nTotValFis >=0,"+","-"),oFont08,,,,1)
oRelATF :Say(2330,3190,transform(Abs(nTotValFis),cPictM1),oFont10,,,,1)

oRelATF :endPAGE() 
return

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
Aadd(aPergs,{cPergunta,"03","Natureza  ?" , "Natureza ?" , "Natureza  ?" ,"mv_ch3","N",1,0,1,"C","","mv_par03","Imob. Corpóreo","Imob. Corpóreo","Imod. Corpóreo","","","Imob. Incorpóreo","Imob. Incorpóreo","Imob. Incorpóreo","","","Prop. Invest.","Prop. Invest.","Prop. Invest.","","","Biológicos n/c","Biológicos n/c","Biológicos n/c","","","Partes de Cap.","Partes de Cap.","Partes de Cap.","","","","S"})	
ProcRegua(Len(aPergs))
dbSelectArea("SX1")
dbSetOrder(1)  

If SX1->(DbSeek(Padr( cPergunta,Len(SX1->X1_GRUPO))+ "03"))
	If Alltrim(SX1->X1_DEF05) == ""     
   		RecLock( "SX1", .F.)
		dbDelete()
		dbCommit()
	Endif  
Endif    

For nI:= 1 To Len(aPergs)
	If !Empty(aPergs[nI][1])
		If ! SX1->(DbSeek(Padr( aPergs[nI,1],Len(SX1->X1_GRUPO))+ aPergs[nI,2])) 
			lSX1 := .T.
			RecLock("SX1",.T.)
			For nJ:=1 To Len(aPergs[nI])
				If !Empty(FieldName(FieldPos(aEstrut[nJ])))
					FieldPut(FieldPos(aEstrut[nJ]),aPergs[nI,nJ])
				EndIf
			Next nJ
			dbCommit()
			MsUnLock()
			IncProc(STR0016 + "...")
		EndIf
	EndIf
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
