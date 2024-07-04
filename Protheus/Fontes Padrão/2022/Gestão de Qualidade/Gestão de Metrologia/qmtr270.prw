#Include "PROTHEUS.CH"
#Include "QMTR270.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMTR270   ºAutor  ³Aldo / Denis        º Data ³  05/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³      Relatorio para impressao de MSA 3 Edicao              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTR270/QMTR150                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMTR270(nTela,cPecaAuto)

Local nColunas 		:= 0
Local nCol     		:= 0
Local nCol1    		:= 0
Local nCol2   	 	:= 0
Local nPosRefe 		:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QM5_REFERE" })
Local nPosCodi 		:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QM5_CODIG" })
Local nPosMedi 		:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QM5_VLRREF" })
Local cCaracter		:= " "
Local nColInicial	:= 50
Local aAprovadores	:= {}
Local cCodUsr		:= " "
Local aKappa		:={}
Local nColuIni		:= 0
Local nMetade		:= 0
Local n2Metade		:= 0
Local nColun		:= 0
Local nColVer		:= 0
Local nColVer2		:= 0
Local nColun2		:= 0
Local nd			:= 0
Local nTotEf		:= 0
Local nTot2p		:= 0
Local nTot  		:= 0
Local nColFix		:= 0
Local nContad		:= 0
Local cContad		:= ""
Local nContO		:= 1
Local nConta		:= 1
Local nContO1		:= 1
Local nT			:= 1
Local CMENSG        := "" 
Private cNome		:= ""
Private nLinhas  	:= 0
Private nLinAux  	:= 0
Private nOperCiclo 	:= 0
Private nTamPecas  	:= 0
Private nAprovadores := 5
Private nCiclos      := 3
Private nTotColunas  := 0
Private nPaginas     := 1
Private lInicial     := .F.

Private oFont08, oFont10, oFont15, oFont10n, oFont20
Private oQPrint

Default nTela 		:= 0
Default	cPecaAuto	:= ""

If M->QM4_TPATR == "1"
	If Len(aCoUser) <= 0
		MessageDlg(STR0033,,3) //"Realize o calculo do estudo antes da impressao do relatorio"
		Return .f.
	Endif
Endif

dbSelectArea("QAA")
dbSetOrder(1)

oFont03	:= TFont():New("Courier New",04,07,,.T.,,,,.T.,.F.)
oFont06	:= TFont():New("Courier New",06,08,,.T.,,,,.T.,.F.)
oFont10	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
oFont10n:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)
oFont15	:= TFont():New("Courier New",15,15,,.T.,,,,.T.,.F.)
oFont20	:= TFont():New("Courier New",20,20,,.T.,,,,.T.,.F.)

nAprovadores := M->QM4_NENSR
nCiclos      := M->QM4_NCICLO
nOperCiclo   := nAprovadores*nCiclos	
nTamPecas    := M->QM4_NPECAS
nTotLinha    := (nTamPecas*35)+620   
nTotColunas  := ((nOperCiclo+1)*115)+120

nColInicial  := If((15-nOperCiclo)>1,((15-nOperCiclo)/2)+1,0)
nTotColunas += Int(nColInicial*115)

nColInicial := 50 + Int(nColInicial*115)

If nPosRefe > 0 .and. Alltrim(M->QM4_TPATR) == "1"
	nTotColunas += 115
Endif
If nPosMedi > 0 .and. Alltrim(M->QM4_TPATR) == "2"
	nTotColunas += 285
Endif

QMTR270Cabec()

//Inicio Tabela 
oQPrint:Box(600, nColInicial, nTotLinha+40, nTotColunas )
 
oQPrint:Say(600,nColInicial+2,OemToAnsi(STR0001),oFont10 ) //"Peca"

nCol := nColInicial+110 

For nColunas:=1 to nAprovadores
	For nContO:=1 to nCiclos
		oQPrint:Say(600,nCol-2,OemToAnsi(StrZero(nColunas,2,0)+"-"+StrZero(nContO,2,0)),oFont10 )
		oQPrint:Line(600,nCol-10,nTotLinha+40,nCol-10)
		nCol+=115
	Next
Next
oQPrint:Line(600,nCol-10,nTotLinha+40,nCol-10)
If nPosRefe > 0 .and. Alltrim(M->QM4_TPATR) == "1"
	oQPrint:Say(600,nCol,OemToAnsi(STR0002),oFont10 ) //"Ref"
	nCol+=115
	oQPrint:Line(600,nCol-10,nTotLinha+40,nCol-10)
Endif
If nPosMedi > 0 .and. Alltrim(M->QM4_TPATR) == "2"
	oQPrint:Say(600,nCol,OemToAnsi(STR0003),oFont10 )
	nCol+=285
	oQPrint:Line(600,nCol-10,nTotLinha+40,nCol-10)
Endif

oQPrint:Say(600,nCol,OemToAnsi(STR0004),oFont10 ) //"Cod."

nLinhas:=650
For nContO:=1 to nTamPecas
	oQPrint:Say(nLinhas+4,nColInicial+2,OemToAnsi(Strzero(nContO,2,0)),oFont10 )
	oQPrint:Line(nLinhas,nColInicial,nLinhas,nTotColunas)
	nCol2:=nColInicial+110
	For nCol1:=1 to nOperCiclo
		cCaracter := If(aCols[nContO,nCol1]="2"," NP  ","  P  ")
		oQPrint:Say(nLinhas+4,nCol2,OemToAnsi(PADC(cCaracter,5)),oFont10 )
		nCol2+=115
	Next
	If nPosRefe > 0 .and. Alltrim(M->QM4_TPATR) == "1"
		cCaracter := If(aCols[nContO,nPosRefe]="2"," NP  ","  P  ")
		oQPrint:Say(nLinhas+4,nCol2,OemToAnsi(PADC(cCaracter,5)),oFont10 )
		nCol2+=115
	Endif
	If nPosMedi > 0 .and. Alltrim(M->QM4_TPATR) == "2"
		oQPrint:Say(nLinhas+4,nCol2,OemToAnsi(PADC(aCols[nContO,nPosMedi],12)),oFont10 )
		nCol2+=285
	Endif
	If nPosCodi > 0
		cCaracter := If(aCols[nContO,nPosCodi]="1"," + ",If(aCols[nContO,nPosCodi]="2"," X "," - "))
		oQPrint:Say(nLinhas+4,nCol2,OemToAnsi(PADC(cCaracter,3)),oFont10 )
	Endif
	nLinhas+=35
Next

nLinhas+=50
// Imprime os codigo-nomes dos ensaiadores
For nContO:=1 to nOperCiclo
	cCodUsr := SubStr(aHeader[nContO][1],1,TamSX3("QM5_ENSR")[1])
	If aScan(aAprovadores,{|x| x[1] == cCodUsr}) == 0
		If QAA->(dbSeek(xFilial("QAA")+cCodUsr))
			aAdd(aAprovadores,{cCodUsr,OemToAnsi(QAA->QAA_MAT+"-"+QAA->QAA_NOME)})
		Endif
	Endif
Next

If Len(aAProvadores) > 0
	oQPrint:Box(nLinhas, 50, nLinhas+(Len(aAProvadores)*35), 2350 )
	For nContO:=1 to Len(aAprovadores)
		oQPrint:Say(nLinhas,55,OemToAnsi(StrZero(nContO,2,0)+" - "+aAProvadores[nContO,2]),oFont10 )
		nLinhas+=35
	Next
Endif

Foot()
// Impressao do cabecalho
QMTR270Cabec()

If Alltrim(M->QM4_TPATR) == "1"	
	For nConta:=1 to Len(aNew) // colocar numero de Cross Tab
		
		If (nLinhas+520) >=2900
			Foot()
			QMTR270Cabec()
		Endif
		
		oQPrint:Say(nLinhas,500,OemToAnsi(aNew[nConta,1]),oFont10n )
		nLinhas+=50 // 200
		//Box 01 * 02
		oQPrint:Box(nLinhas, 500, nLinhas+400, 1880 )
		
		//Linhas verticais
		oQPrint:Line(nLinhas, 1190,nLinhas+400, 1190) // linha 200 - Vertical
		oQPrint:Line(nLinhas,1650,nLinhas+400,1650) // linha 200 - Vertical
		oQPrint:Say(nLinhas,1339,OemToAnsi(SubStr(aNew[nConta,1],Len(SubStr(aNew[nConta,1],1,TamSx3("QM5_ENSR")[1]+4)),TamSx3("QM5_ENSR")[1])),oFont10n ) // Linha 200 - Referencia 02
		nLinhas+=50
		oQPrint:Line(nLinhas, 1420,nLinhas+350, 1420) // linha 250 - Vertical
		oQPrint:Line(nLinhas, 1190, nLinhas,1650)	// Linha 250 - Horizontal
		oQPrint:Say(nLinhas+10,1280 ,OemToAnsi(STR0005),oFont06 ) // Linha 250 - NP
		oQPrint:Say(nLinhas+10,1520,OemToAnsi("P"),oFont06 ) // Linha 250 - NP
		oQPrint:Say(nLinhas+10,1660,OemToAnsi(STR0006),oFont06 ) // Linha 250 - NP
		
		nLinhas+=50
		oQPrint:Line(nLinhas, 730,nLinhas+300, 730) // linha 300 - Vertical
		oQPrint:Line(nLinhas, 960,nLinhas+300, 960) // linha 300 - Vertical
		oQPrint:Line(nLinhas, 500,nLinhas,1880)	// Linha 300 - Horizontal
		
		oQPrint:Say(nLinhas+10,970 ,OemToAnsi(STR0007),oFont06 ) // Linha 310 - NP "Contados"
		oQPrint:Say(nLinhas+10,1280 ,TransForm(aNew[nConta,2],"@E 9999"),oFont06 ) // Linha 310 - NP
		oQPrint:Say(nLinhas+10,1520 ,TransForm(aNew[nConta,4],"@E 9999"),oFont06 ) // Linha 310 - NP
		oQPrint:Say(nLinhas+10,1660 ,TransForm(aNew[nConta,6,1],"@E 9999"),oFont06 ) // Linha 310 - NP
		
		nLinhas+=50
		oQPrint:Line(nLinhas, 960,nLinhas,1880)
		oQPrint:Say(nLinhas-10,900,OemToAnsi(STR0005),oFont10n )
		oQPrint:Say(nLinhas+40,527,OemToAnsi(SubStr(aNew[nConta,1],1,TamSx3("QM5_ENSR")[1])),oFont10n )
		
		oQPrint:Say(nLinhas+10,970 ,OemToAnsi(STR0008),oFont06 ) //"Esperados"
		oQPrint:Say(nLinhas+10,1280 ,TransForm(aNew[nConta,7,1],"@E 9999.99"),oFont06 )
		oQPrint:Say(nLinhas+10,1520 ,TransForm(aNew[nConta,7,2],"@E 9999.99"),oFont06 )
		oQPrint:Say(nLinhas+10,1660 ,TransForm(aNew[nConta,7,1]+aNew[nConta,7,2],"@E 9999.99"),oFont06 )
		
		nLinhas+=50
		oQPrint:Line(nLinhas, 730,nLinhas,1880)	// Linha 400 - Horizontal
		oQPrint:Say(nLinhas+10,970 ,OemToAnsi(STR0007),oFont06 ) // Linha 410 - NP
		oQPrint:Say(nLinhas+10,1280 ,TransForm(aNew[nConta,5],"@E 9999"),oFont06 )
		oQPrint:Say(nLinhas+10,1520 ,TransForm(aNew[nConta,3],"@E 9999"),oFont06 )
		oQPrint:Say(nLinhas+10,1660 ,TransForm(aNew[nConta,6,2],"@E 9999"),oFont06 )
		
		nLinhas+=50
		oQPrint:Line(nLinhas, 960,nLinhas,1880)	// Linha 450 - Horizontal
		oQPrint:Say(nLinhas-10,900,OemToAnsi("P"),oFont10n ) // Linha 440 - P
		oQPrint:Say(nLinhas+10,970 ,OemToAnsi(STR0008),oFont06 ) // Linha 460 - NP
		oQPrint:Say(nLinhas+10,1280 ,TransForm(aNew[nConta,7,3],"@E 9999.99"),oFont06 )
		oQPrint:Say(nLinhas+10,1520 ,TransForm(aNew[nConta,7,4],"@E 9999.99"),oFont06 )
		oQPrint:Say(nLinhas+10,1660 ,TransForm(aNew[nConta,7,3]+aNew[nConta,7,4],"@E 9999.99"),oFont06 )
		
		nLinhas+=50
		oQPrint:Line(nLinhas, 500,nLinhas,1880)	// Linha 500 - Horizontal
		oQPrint:Say(nLinhas+10,970 ,OemToAnsi(STR0007),oFont06 ) // Linha 410 - NP
		oQPrint:Say(nLinhas+10,1280 ,TransForm(aNew[nConta,6,3],"@E 9999"),oFont06 )
		oQPrint:Say(nLinhas+10,1520 ,TransForm(aNew[nConta,6,4],"@E 9999"),oFont06 )
		oQPrint:Say(nLinhas+10,1660 ,TransForm(aNew[nConta,6,5],"@E 9999"),oFont06 )
		
		oQPrint:Say(nLinhas+20,510 ,OemToAnsi(STR0006),oFont06 ) // Linha 540 - NP
		nLinhas+=50
		oQPrint:Say(nLinhas+10,970 ,OemToAnsi(STR0008),oFont06 ) // Linha 460 - NP
		oQPrint:Say(nLinhas+10,1280 ,TransForm(aNew[nConta,7,1]+aNew[nConta,7,3],"@E 9999.99"),oFont06 )
		oQPrint:Say(nLinhas+10,1520 ,TransForm(aNew[nConta,7,2]+aNew[nConta,7,4],"@E 9999.99"),oFont06 )
		oQPrint:Say(nLinhas+10,1660 ,TransForm(aNew[nConta,7,1]+aNew[nConta,7,2]+aNew[nConta,7,3]+aNew[nConta,7,4],"@E 9999.99"),oFont06 )
		
		oQPrint:Line(nLinhas, 730,nLinhas,1880)	// Linha 550 - Horizontal
		
		nLinhas+=100 // 200
		
	Next
	
	// Impressao Cross Tab entre Aprovadores e Referencia
	For nConta:=1 to Len(aRef) // colocar numero de Cross Tab
		
		If (nLinhas+520) >=2900
			Foot()
			QMTR270Cabec()
		Endif
		
		oQPrint:Say(nLinhas,500,OemToAnsi(aRef[nConta,1]),oFont10n )
		nLinhas+=50 // 200
		//Box 01 * 02
		oQPrint:Box(nLinhas, 500, nLinhas+400, 1880 )
		
		//Linhas verticais
		oQPrint:Line(nLinhas, 1190,nLinhas+400, 1190) // linha 200 - Vertical
		oQPrint:Line(nLinhas,1650,nLinhas+400,1650) // linha 200 - Vertical
		oQPrint:Say(nLinhas,1370,OemToAnsi(SubStr(aRef[nConta,1],Len(SubStr(aRef[nConta,1],1,TamSx3("QM5_ENSR")[1]+4)),TamSx3("QM5_ENSR")[1])),oFont10n ) // Linha 200 - Referencia 02
		nLinhas+=50
		oQPrint:Line(nLinhas, 1420,nLinhas+350, 1420) // linha 250 - Vertical
		oQPrint:Line(nLinhas, 1190, nLinhas,1650)	// Linha 250 - Horizontal
		oQPrint:Say(nLinhas+10,1280 ,OemToAnsi(STR0005),oFont06 ) // Linha 250 - NP
		oQPrint:Say(nLinhas+10,1520,OemToAnsi("P"),oFont06 ) // Linha 250 - NP
		oQPrint:Say(nLinhas+10,1660,OemToAnsi(STR0006),oFont06 ) // Linha 250 - NP
		
		nLinhas+=50
		oQPrint:Line(nLinhas, 730,nLinhas+300, 730) // linha 300 - Vertical
		oQPrint:Line(nLinhas, 960,nLinhas+300, 960) // linha 300 - Vertical
		oQPrint:Line(nLinhas, 500,nLinhas,1880)	// Linha 300 - Horizontal
		
		oQPrint:Say(nLinhas+10,970 ,OemToAnsi(STR0007),oFont06 ) // Linha 310 - NP
		oQPrint:Say(nLinhas+10,1280 ,TransForm(aRef[nConta,2],"@E 9999"),oFont06 ) // Linha 310 - NP
		oQPrint:Say(nLinhas+10,1520 ,TransForm(aRef[nConta,4],"@E 9999"),oFont06 ) // Linha 310 - NP
		oQPrint:Say(nLinhas+10,1660 ,TransForm(aRef[nConta,6,1],"@E 9999"),oFont06 ) // Linha 310 - NP
		
		nLinhas+=50
		oQPrint:Line(nLinhas, 960,nLinhas,1880)
		oQPrint:Say(nLinhas-10,900,OemToAnsi(STR0005),oFont10n )
		oQPrint:Say(nLinhas+40,527,OemToAnsi(SubStr(aRef[nConta,1],1,TamSx3("QM5_ENSR")[1])),oFont10n )
		
		oQPrint:Say(nLinhas+10,970 ,OemToAnsi(STR0008),oFont06 )
		oQPrint:Say(nLinhas+10,1280 ,TransForm(aRef[nConta,7,1],"@E 9999.99"),oFont06 )
		oQPrint:Say(nLinhas+10,1520 ,TransForm(aRef[nConta,7,2],"@E 9999.99"),oFont06 )
		oQPrint:Say(nLinhas+10,1660 ,TransForm(aRef[nConta,7,1]+aRef[nConta,7,2],"@E 9999.99"),oFont06 )
		
		nLinhas+=50
		oQPrint:Line(nLinhas, 730,nLinhas,1880)	// Linha 400 - Horizontal
		oQPrint:Say(nLinhas+10,970 ,OemToAnsi(STR0007),oFont06 ) // Linha 410 - NP
		oQPrint:Say(nLinhas+10,1280 ,TransForm(aRef[nConta,5],"@E 9999"),oFont06 )
		oQPrint:Say(nLinhas+10,1520 ,TransForm(aRef[nConta,3],"@E 9999"),oFont06 )
		oQPrint:Say(nLinhas+10,1660 ,TransForm(aRef[nConta,6,2],"@E 9999"),oFont06 )
		
		nLinhas+=50
		oQPrint:Line(nLinhas, 960,nLinhas,1880)	// Linha 450 - Horizontal
		oQPrint:Say(nLinhas-10,900,OemToAnsi("P"),oFont10n ) // Linha 440 - P
		oQPrint:Say(nLinhas+10,970 ,OemToAnsi(STR0008),oFont06 ) // Linha 460 - NP
		oQPrint:Say(nLinhas+10,1280 ,TransForm(aRef[nConta,7,3],"@E 9999.99"),oFont06 )
		oQPrint:Say(nLinhas+10,1520 ,TransForm(aRef[nConta,7,4],"@E 9999.99"),oFont06 )
		oQPrint:Say(nLinhas+10,1660 ,TransForm(aRef[nConta,7,3]+aRef[nConta,7,4],"@E 9999.99"),oFont06 )
		
		nLinhas+=50
		oQPrint:Line(nLinhas, 500,nLinhas,1880)	// Linha 500 - Horizontal
		oQPrint:Say(nLinhas+10,970 ,OemToAnsi(STR0007),oFont06 ) // Linha 410 - NP
		oQPrint:Say(nLinhas+10,1280 ,TransForm(aRef[nConta,6,3],"@E 9999"),oFont06 )
		oQPrint:Say(nLinhas+10,1520 ,TransForm(aRef[nConta,6,4],"@E 9999"),oFont06 )
		oQPrint:Say(nLinhas+10,1660 ,TransForm(aRef[nConta,6,5],"@E 9999"),oFont06 )
		
		oQPrint:Say(nLinhas+20,520 ,OemToAnsi(STR0006),oFont06 ) // Linha 540 - NP
		nLinhas+=50
		oQPrint:Say(nLinhas+10,970 ,OemToAnsi(STR0008),oFont06 ) // Linha 460 - NP
		oQPrint:Say(nLinhas+10,1280 ,TransForm(aRef[nConta,7,1]+aRef[nConta,7,3],"@E 9999.99"),oFont06 )
		oQPrint:Say(nLinhas+10,1520 ,TransForm(aRef[nConta,7,2]+aRef[nConta,7,4],"@E 9999.99"),oFont06 )
		oQPrint:Say(nLinhas+10,1660 ,TransForm(aRef[nConta,7,1]+aRef[nConta,7,2]+aRef[nConta,7,3]+aRef[nConta,7,4],"@E 9999.99"),oFont06 )
		
		oQPrint:Line(nLinhas, 730,nLinhas,1880)	// Linha 550 - Horizontal
		
		nLinhas+=100 // 200
		
	Next
	
	//Box Kappa
	If (nLinhas+350) >=2900
		Foot()
		QMTR270Cabec()
	Endif
	
	aKappaNew:={}
	
	For nContO:=1 to Len(aNew)
		aAdd(aKappaNew,{SubStr(aNew[nContO,1],1,TamSx3("QM5_ENSR")[1]),SubStr(aNew[nContO,1],Len(SubStr(aNew[nContO,1],1,TamSx3("QM5_ENSR")[1]+4)),TamSx3("QM5_ENSR")[1]),aNew[nContO,9,1]})
	Next    
	For nContO:=1 to Len(aRef)
		aAdd(aKappaNew,{SubStr(aRef[nContO,1],1,TamSx3("QM5_ENSR")[1]),SubStr(aRef[nContO,1],Len(SubStr(aRef[nContO,1],1,TamSx3("QM5_ENSR")[1]+4)),TamSx3("QM5_ENSR")[1]),aRef[nContO,9,1]})
	Next
	
	aKappa := {}
	aKappa1 := Array(nAprovadores+1,nAprovadores)
	
	For nContO:=1 to Len(aTabela)
		If aTabela[nContO,1]
			aAdd(aKappa,SubStr(aTabela[nContO,2],1,TamSx3("QM5_ENSR")[1]))
		Endif
	Next
	aAdd(aKappa,OemToAnsi(STR0009)) //"Ref   "
	
	For nContO:=1 to Len(aKappaNew)
		nPosL := aScan(aKappa,aKappaNew[nContO,1])
		nPosC := aScan(aKappa,aKappaNew[nContO,2])
		If aKappaNew[nContO,2] == STR0009
			aKappa1[nAprovadores+1,nPosL] := TransForm(aKappaNew[nContO,3],"@E 9999.99")
		Else
			aKappa1[nPosL,nPosC] := TransForm(aKappaNew[nContO,3],"@E 9999.99")
			aKappa1[nPosC,nPosL] := TransForm(aKappaNew[nContO,3],"@E 9999.99")
		Endif
	Next
	For nContO1:=1 to Len(aKappa1)-1
		aKappa1[nContO1,nContO1]:= "-------"
	Next
	
	nLinhas+=90
	
	oQPrint:Box(nLinhas, 500, nLinhas+((nAprovadores+2)*50),500+((nAprovadores+1)*230) ) // Linha +350 Coluna 1880
	oQPrint:Say(nLinhas+10,510,OemToAnsi(STR0010),oFont06 )
	nCol:=730
	For nT:=1 to nAprovadores
		oQPrint:Say(nLinhas+10,nCol+10,aKappa[nT],oFont06 )
		nCol+=230
	Next
	
	nCol:=730
	For nT:=1 to Len(aKappa1)-1
		oQPrint:Line(nLinhas,nCol,nLinhas+((nAprovadores+2)*50), nCol)
		nCol+=230
	Next
	nLinhas+=50
	oQPrint:Line(nLinhas, 500,nLinhas,500+((nAprovadores+1)*230))
	
	nCol:=730
	nContO1:=1
	For nContO:=1 to Len(aKappa1)
		nCol:=730
		For nContO1:=1 to Len(aKappa1[nContO])
			If aKappa1[nContO,nContO1] <> NIL
				oQPrint:Say(nLinhas+10,nCol+10,aKappa1[nContO,nContO1],oFont06 )
			Else
				oQPrint:Say(nLinhas+10,nCol+10,"-------",oFont06 )
			Endif
			nCol+=230
		Next
		oQPrint:Say(nLinhas+10,510,aKappa[nContO],oFont06 )
		oQPrint:Line(nLinhas, 500,nLinhas,500+((nAprovadores+1)*230))
		nLinhas+=50
	Next

	nLinhas+=15

	If Len(aKappa1)-1 > 2
		If SuperVal(aKappa1[Len(aKappa1),1]) > 0.75 .and. SuperVal(aKappa1[Len(aKappa1),2]) > 0.75 .and.  SuperVal(aKappa1[Len(aKappa1),3]) > 0.75
			oQPrint:Say(nLinhas+10,510,STR0034,oFont06) //"Os operadores tem uma boa concordancia entre si"
		Else
			If SuperVal(aKappa1[Len(aKappa1),1]) < 0.4 .or. SuperVal(aKappa1[Len(aKappa1),2]) < 0.4 .or. SuperVal(aKappa1[Len(aKappa1),3]) < 0.4
				oQPrint:Say(nLinhas+10,510,STR0035,oFont06)
			Else
				oQPrint:Say(nLinhas+10,510,STR0036,oFont06)
			Endif	
		Endif
    Else 
		If SuperVal(aKappa1[Len(aKappa1),1]) > 0.75 .and. SuperVal(aKappa1[Len(aKappa1),2]) > 0.75 
			oQPrint:Say(nLinhas+10,510,STR0034,oFont06) //"Os operadores tem uma boa concordancia entre si"
		Else
			If SuperVal(aKappa1[Len(aKappa1),1]) < 0.4 .or. SuperVal(aKappa1[Len(aKappa1),2]) < 0.4 
				oQPrint:Say(nLinhas+10,510,STR0035,oFont06)
			Else
				oQPrint:Say(nLinhas+10,510,STR0036,oFont06)
			Endif	
		Endif    
    Endif
		//Impressao da tabela dinamica
		nLinhas+=120            
		If (nLinhas+520) >=2900
			Foot()
			QMTR270Cabec()
		Endif
		nColuIni := 235
		oQPrint:Box(nLinhas, 210, nLinhas+360,nAprovadores*452) 
		oQPrint:Line(nLinhas,((nAprovadores*452)+210)/2,nLinhas+358,((nAprovadores*452)+210)/2) //Linha Vertical da Effectiveness nCol-(215*nAprovadores)
		nLinhas+=20                                    
		nMetade := (((nAprovadores*452)+210)/2)/2

		If nAprovadores > 2
			If nAprovadores == 3    
				n2Metade := 945
			ElseIf nAprovadores == 4
				n2Metade := 1285
			ElseIf nAprovadores == 5			
				n2Metade := 1630
			Endif	
		Else
			n2Metade := 567
		Endif
		oQPrint:Say(nLinhas,nMetade-10,"% "+STR0031,oFont06 )			
		oQPrint:Say(nLinhas,n2Metade,STR0032,oFont06 )//"% Pontos x Atributo"	
		nLinhas+=19
		oQPrint:Say(nLinhas+39,38,STR0031,oFont03 ) //"Ensaiadores"		
		nColun := 0
		nColun2:= 20
		nColVer:= 383
		nColVer2:=170
		For nd := 1 To nAprovadores
			If  nd <= (nAprovadores-1)
				oQPrint:Line(nLinhas+76,nColVer,nLinhas+260,nColVer)	
				oQPrint:Line(nLinhas+252,nColVer,nLinhas+320,nColVer)	
				nColVer += 228
			Endif 
			If nAprovadores > 3
				If nd == 3
					nColun += 35			
					nColun2 += 35 
				ElseIf nd == 4
					nColun -= 10			
					nColun2 -= 10 
				ElseIf nd == 5
					nColun += 20			
					nColun2 += 20 
				Endif
        	Endif
			nContad += 1
			cContad := "0"+Alltrim(Str(nContad))
			oQPrint:Say(nLinhas+39,nColuIni+nColun,cContad,oFont06 )//SubStr(aTabela[nd,2],1,TamSX3("QM5_ENSR")[1])		
			oQPrint:Say(nLinhas+39,((nAprovadores*452)+210)/2+nColun2,cContad,oFont06 )		
			nColun += 208			
			nColun2 += 208 
			If  nd <= (nAprovadores-1)
				oQPrint:Line(nLinhas+76,((nAprovadores*452)+210)/2+nColVer2,nLinhas+320,((nAprovadores*452)+210)/2+nColVer2) //Linha Vertical da Effectiveness
				nColVer2 += 228
			Endif 
		Next	
		nLinhas+=78
		nTotEf := 280                                             
		nTot2p := 80
		oQPrint:Say(nLinhas,38,STR0030,oFont03 )	//"Tot.Inspec."	
		
		For nd := 1 to nAprovadores
			If nAprovadores > 3
				If nAprovadores == 5
					If nd == 3
						nTotEf += 35
						nTot2p += 35				
					ElseIf nd == 4    
						nTotEf += 20
						nTot2p += 20				
					ElseIf nd == 5
						nTotEf += 5
						nTot2p += 5				
					Endif
				Else
					If nd == 3 
						nTotEf += 25
						nTot2p += 25				
					Endif	
				Endif
            Endif
			oQPrint:Say(nLinhas,nTotEf,Alltrim(Str(aCoUser[nd,2])),oFont06 )						
			oQPrint:Say(nLinhas,((nAprovadores*452)+210)/2+nTot2p,Alltrim(Str(aCoUser[nd,2])),oFont06 )						
			nTotEf += 200
			nTot2p += 200
		Next nd
		nTotEf := 280
		nTot2p := 80
		oQPrint:Line(nLinhas,210,nLinhas,nAprovadores*452) 
		nLinhas+=30                                        
		
		oQPrint:Say(nLinhas,38,STR0029,oFont03 ) //"Combinacao"		
		oQPrint:Line(nLinhas,210,nLinhas,nAprovadores*452) 

		For nd := 1 to nAprovadores
			If nAprovadores > 3
				If nAprovadores == 5
					If nd == 3
						nTotEf += 35
						nTot2p += 35				
					ElseIf nd == 4    
						nTotEf += 20
						nTot2p += 20				
					ElseIf nd == 5
						nTotEf += 5
						nTot2p += 5				
					Endif
				Else
					If nd == 3 
						nTotEf += 25
						nTot2p += 25				
					Endif	
				Endif
            Endif
			oQPrint:Say(nLinhas,nTotEf,Alltrim(Str(aCoUser[nd,3])),oFont06 )						    
			oQPrint:Say(nLinhas,((nAprovadores*452)+210)/2+nTot2p,Alltrim(Str(aCoUser[nd,3])),oFont06 )									
			nTotEf += 200                                
			nTot2p += 200
		Next nd
		nTotEf := 280
		nTot2p := 80
		nLinhas+=30
		oQPrint:Line(nLinhas,210,nLinhas,nAprovadores*452) 
		nLinhas+=30
		oQPrint:Line(nLinhas,((nAprovadores*452)+210)/2,nLinhas,nAprovadores*452) 
		nLinhas+=30
		oQPrint:Say(nLinhas,38,STR0028,oFont03 ) //"Diferenca"				
		oQPrint:Line(nLinhas,((nAprovadores*452)+210)/2,nLinhas,nAprovadores*452) 
		For nd := 1 To nAprovadores
			If nAprovadores > 3
				If nAprovadores == 5
					If nd == 3
						nTotEf += 35
						nTot2p += 35				
					ElseIf nd == 4    
						nTotEf += 20
						nTot2p += 20				
					ElseIf nd == 5
						nTotEf += 5
						nTot2p += 5				
					Endif
				Else
					If nd == 3 
						nTotEf += 25
						nTot2p += 25				
					Endif	
				Endif
            Endif
			oQPrint:Say(nLinhas,((nAprovadores*452)+210)/2+nTot2p,Alltrim(Str(aCoUser[nd,2]-aCoUser[nd,3])),oFont06 )									
			nTot2p += 200
		Next nd         
		nTotEf := 280		

		nLinhas+=30                       
		oQPrint:Say(nLinhas,38,"95% LSE",oFont03 )				
		oQPrint:Line(nLinhas,210,nLinhas,nAprovadores*452) 
		nLinhas+=30
		oQPrint:Say(nLinhas,38,STR0027,oFont03 ) //"Calculado"				
		oQPrint:Line(nLinhas,210,nLinhas,nAprovadores*452) 
		nTotEf := 275
		nTot2p := 69
 		For nd := 1 to nAprovadores
			If nAprovadores > 3
				If nAprovadores == 5
					If nd == 3
						nTotEf += 35
						nTot2p += 35				
					ElseIf nd == 4    
						nTotEf += 20
						nTot2p += 20				
					ElseIf nd == 5
						nTotEf += 5
						nTot2p += 5				
					Endif
				Else
					If nd == 3 
						nTotEf += 25
						nTot2p += 25				
					Endif	
				Endif
            Endif
            nContCal := (aCoUser[nd][3]*100)/aCoUser[nd][2]
            
		oQPrint:Say(nLinhas,nTotEf,Alltrim(STR(Round(nContCal,2)))+"%",oFont06 )									
		oQPrint:Say(nLinhas,((nAprovadores*452)+210)/2+nTot2p,Alltrim(STR(Round(nContCal,2)))+"%",oFont06 )						
		nTotEf += 200                                
		nTot2p += 200
	Next nd


	nTot2p := 80

	nTotEf := 280
	nLinhas+=30                                            
	oQPrint:Say(nLinhas,38,"95% LIE",oFont03 )				
	oQPrint:Line(nLinhas,210,nLinhas,nAprovadores*452) 
	nLinhas+=71                                            

	oQPrint:Box(nLinhas, 210, nLinhas+50,nAprovadores*452) 
	oQPrint:Line(nLinhas,((nAprovadores*452)+210)/2,nLinhas+120,((nAprovadores*452)+210)/2) //Linha Vertical da Effectiveness
	oQPrint:Say(nLinhas,nMetade-10,"% "+STR0023,oFont06 )				
	oQPrint:Say(nLinhas,n2Metade,STR0026,oFont06 ) //"% Efic x Refer."
	nLinhas+=47                                            
	nTotEf := nLinhas + 3
	oQPrint:Box(nLinhas,210,nLinhas+187,nAprovadores*452) 
	oQPrint:Line(nLinhas,((nAprovadores*452)+210)/2,nLinhas+187,((nAprovadores*452)+210)/2) //Linha Vertical da Effectiveness
	For nd := 1 To 4
		nLinhas+=36                                            		
		oQPrint:Line(nLinhas,210,nLinhas,nAprovadores*452) 		
	Next nd	

	//Valores da Eficacia e Eficacia x Referencia	
	oQPrint:Say(nTotEf,nMetade+70,Alltrim(Str(aCoUser[1,2])),oFont06 )				
	oQPrint:Say(nTotEf,n2Metade+100,Alltrim(Str(aCoUser[1,2])),oFont06 ) //1085	 (361*nAprovadores)						
	nTotEf+=35
	oQPrint:Say(nTotEf,nMetade+70,Alltrim(Str(aCoUser[1,5])),oFont06 )				
	oQPrint:Say(nTotEf,n2Metade+100,Alltrim(Str(aCoUser[1,5])),oFont06 ) 							 
	nTotEf+=70
	oQPrint:Say(nTotEf,nMetade+70,Alltrim(Str((aCoUser[1,5]/aCoUser[1,2])*100)+" %"),oFont06 )				
	oQPrint:Say(nTotEf,n2Metade+100,Alltrim(Str((aCoUser[1,5]/aCoUser[1,2])*100)+" %"),oFont06 ) 							 

		nLinhas+=120                                            
	If (nLinhas+520) >=2900
		Foot()
		QMTR270Cabec()
	Endif

		// Monta Effectivenness / Miss Rate / False Alarm
		oQPrint:Box(nLinhas+50, 500, nLinhas+50+((nAprovadores+2)*41),1420) 
		nTot := nLinhas+30
		nCol:=732
		For nd := 1 To nAprovadores
			If nd <= nAprovadores                         
				nLinhas+=48                                            
				oQPrint:Say(nLinhas+60,535,SubStr(aTabela[nd,2],1,TamSX3("QM5_ENSR")[1]),oFont06 )						
				oQPrint:Line(nLinhas+55,500,nLinhas+55,1420) 
			Endif 
		Next	

		For nd := 1 To 3
			oQPrint:Line(nTot+20,nCol,nTot+((nAprovadores+2.5)*41),nCol)
			nCol+=223
		Next nd      

		nCol:=776
		oQPrint:Say(nTot+20,nCol,STR0023,oFont06 )		//"Eficacia"					
		nCol := nCol + 213 
		oQPrint:Say(nTot+20,nCol,STR0024,oFont06 )		//"Prop.Erro"					
		nCol := nCol + 213 
		oQPrint:Say(nTot+20,nCol,STR0025,oFont06 )		//"Falso Alarm"					
		nColFix:=819
		nCol := nColFix

		//Resumo da Effectivenness		
		For nd := 1 To nAprovadores      
			oQPrint:Say(nTot+75,nColFix,Alltrim(Str(Round(aCoUser[nd,4],2))),oFont06 )									
			cMiss := Alltrim(Str(Round((aRef[nd][5]/aRef[nd][6][3])*100,2))) 
			oQPrint:Say(nTot+75,nColFix+240,cMiss,oFont06 )	//228					
			cFals := Alltrim(Str(Round((aRef[nd][4]/aRef[nd][6][4])*100,2)))
			oQPrint:Say(nTot+75,nColFix+480,cFals,oFont06 )	//445					
			nTot+=50
		Next nd
Else
	oQPrint:Box(600, 50, 2300, 1200 )  
	oQPrint:Say(610,520,STR0022,oFont06 )	//"Ref.Valor Codigo  Ref.Valor Codigo"
	aSort(aSomRef,,,{|x,y| x[1] > y[1]})	//Sorte da maior para menor
	nLinhas+=150
	nLinAux := nLinhas
	For nColunas:=1 to Len(aSomRef)
		If nColunas <= (Len(aSomRef)/2)
			oQPrint:Say(nLinhas+10,520,aSomRef[nColunas][1],oFont06 )	//Imprime valores
			If aSomRef[nColunas][2] == "1"
				oQPrint:Say(nLinhas+10,730,"+",oFont06 )	//Imprime sinais
			ElseIf aSomRef[nColunas][2] == "2"
				oQPrint:Say(nLinhas+10,730,"x",oFont06 )	//Imprime sinais
			ElseIf aSomRef[nColunas][2] == "3"
				oQPrint:Say(nLinhas+10,730,"-",oFont06 )	//Imprime sinais
			Endif  
			nLinhas+=50
		Else
			oQPrint:Say(nLinAux+10,900,aSomRef[nColunas][1],oFont06 )	//Imprime valores		
			If aSomRef[nColunas][2] == "1"
				oQPrint:Say(nLinAux+10,1110,"+",oFont06 )	//Imprime sinais
			ElseIf aSomRef[nColunas][2] == "2"
				oQPrint:Say(nLinAux+10,1110,"x",oFont06 )	//Imprime sinais
			ElseIf aSomRef[nColunas][2] == "3"
				oQPrint:Say(nLinAux+10,1110,"-",oFont06 )	//Imprime sinais
			Endif  
			nLinAux+=50	
		Endif 
	Next
	
	nLinAux := 610
	//Imprime o calculo de "d"
	oQPrint:Box(600, 1238, 2300, 1900 )

	oQPrint:Say(nLinAux+10,1400,STR0020,oFont06 )	//"Calculo da Media"                           
	nLinAux+=105

	oQPrint:Say(nLinAux+10,1380,STR0021,oFont06 ) //"d    =    Media(di)"	                           
	nLinAux+=50
	oQPrint:Say(nLinAux+10,1380,"di   =    (dLSE+dLIE)/2",oFont06 )	 	                         
	nLinAux+=50
	oQPrint:Say(nLinAux+10,1380,"dLSE =    ",oFont06 )	                 			
	oQPrint:Say(nLinAux+10,1500,Alltrim(Str(nRep1)),oFont06 )	                 			
	nLinAux+=50	
	oQPrint:Say(nLinAux+10,1380,"dLIE =    ",oFont06 )	                 			
	oQPrint:Say(nLinAux+10,1500,Alltrim(Str(nRep3)),oFont06 )	                 			
	nLinAux+=50	
	oQPrint:Say(nLinAux+10,1380,"d    =    ",oFont06 )	                 			
	oQPrint:Say(nLinAux+10,1500,Alltrim(Str(nReptot)),oFont06 )	                 			
	nLinAux+=50	
	dbSelectArea("QM4")
	oQPrint:Say(nLinAux+10,1380,STR0042,oFont06 )
	oQPrint:Say(nLinAux+10,1780,Alltrim(Str(nRepReR))+" %",oFont06 )	                 			
	nLinAux+=60	
	oQPrint:Say(2350,nColInicial,Alltrim(cMensg),oFont15 )	//nLinAux+10	                 			
	nLinAux+=50	
Endif

Foot()
If nTela == 1
	oQPrint:Print()
Else
	oQPrint:Preview()  // Visualiza antes de imprimir
Endif

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMTR270   ºAutor  ³Aldo / Denis        º Data ³05/01/03     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta/Imprime cabecalho do relatorio MSA 3 Edicao           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTR270                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMTR270Cabec()
Local cText 		:= ""
Local cFileLogo		:= "LGRL"+SM0->M0_CODIGO+FWCodFil()+".BMP" // Empresa+Filial
Local cStartPath	:= GetSrvProfString("Startpath","")

If !lInicial
	If Alltrim(M->QM4_TPATR) == "1"
		cText := STR0011
	Else
		cText := STR0012
	Endif
	lInicial := .T.
	oQPrint:= TMSPrinter():New( cText )
	oQPrint:SetPortrait()
Else
	oQPrint:EndPage()
	oQPrint:StartPage() // Inicia uma nova pagina
Endif

If Alltrim(M->QM4_TPATR) == "1"
	oQPrint:Say(30,810,OemToAnsi(STR0011),oFont20 ) //"Estudo Tabulacao Cruzada"
Else
	oQPrint:Say(30,850,OemToAnsi(STR0012),oFont20 )
Endif	

oQPrint:Box(200,50,350,2350)
oQPrint:Line(250,50,250,2350)
oQPrint:Line(300,50,300,2350)
oQPrint:Line(400,50,400,2350)
oQPrint:Line(490,50,490,2350)

oQPrint:Line(350,2350,490,2350)
oQPrint:Line(350,50,490,50)

oQPrint:Line(200,1500,350,1500)
oQPrint:Line(200,2000,350,2000)

If nModulo == 47 //PPAP
	oQPrint:SayBitmap(05,0005, cFileLogo,328,82)		// Tem que estar abaixo do RootPath
	oQPrint:SayBitmap(05,2100, cStartPath+"\Logo.bmp",237,58)

	oQPrint:Say(210,60,OemToAnsi(STR0001)+":",oFont10)	 //Peca
	oQPrint:Say(210,200,+AllTrim(M->QM4_PECA1)+"-"+M->QM4_REV+" "+M->QM4_CARAC,oFont10n)	 //Peca
	oQPrint:Say(310,60,OemToAnsi(STR0013),oFont10)	
	If !Empty(M->QM4_INSTRP)
		oQPrint:Say(310,340,M->QM4_INSTRP+"-"+M->QM4_REVINP,oFont10n)		//Instrumento
	Else
	Endif
	oQPrint:Say(260,60,OemToAnsi(STR0014),oFont10)	//Familia

	QM2->(DbSetOrder(1))
	If QM2->(DbSeek(xFilial("QM2")+M->QM4_INSTRP+Inverte(M->QM4_REVINP)))
		oQPrint:Say(260,250,QM2->QM2_TIPO,oFont10n)	// Familia
	Endif
Else                                                               
	oQPrint:Say(210,60,OemToAnsi(STR0013),oFont10)	//Instrumento 
	oQPrint:Say(260,60,OemToAnsi(STR0014),oFont10)	//Familia
	oQPrint:Say(310,60,OemToAnsi(STR0001)+":",oFont10)	//Peca
	oQPrint:Say(210,340,M->QM4_INSTR+"-"+M->QM4_REVINS,oFont10n )		//Instrumento
	oQPrint:Say(260,250,QM2->QM2_TIPO,oFont10n)	// Familia

	If !Empty(M->QM4_PECA)
		oQPrint:Say(310,200,M->QM4_PECA,oFont10n ) //Peca
	Endif
Endif

oQPrint:Say(210,1505,OemToAnsi(STR0015),oFont10) 	//"No.Pecas: "
oQPrint:Say(210,1705,Str(nTamPecas,2),oFont10n) 	//"No.Pecas: "
oQPrint:Say(260,1505,OemToAnsi(STR0016),oFont10) 	//"Aprovadores: "
oQPrint:Say(260,1750,Str(nAprovadores,2),oFont10n) //"Aprovadores: "
oQPrint:Say(310,1505,OemToAnsi(STR0017),oFont10) 	//"Ciclos: "
oQPrint:Say(310,1705,Str(nCiclos,2),oFont10n) 		//"Ciclos: "

oQPrint:Say(210,2005,OemToAnsi(STR0018),oFont10) 		//"Data: "
oQPrint:Say(210,2120,dtoc(Date()),oFont10n) 			//"Data: "
oQPrint:Say(260,2005,OemToAnsi(STR0019),oFont10)		//"Pagina: "
oQPrint:Say(260,2205,StrZero(nPaginas,3,0),oFont10n)	//"Pagina: "

oQPrint:Say(360,0060,STR0037,oFont10)
oQPrint:Say(360,0380,M->QM4_REAPOR,oFont10n)	//"Realizado por: "

oQPrint:Say(410,0060,STR0038,oFont10)
oQPrint:Say(410,0360,SubStr(M->QM4_OBS,1,90),oFont10n) //"Observações: "
oQPrint:Say(440,0360,SubStr(M->QM4_OBS,91,60),oFont10n) //"Observações: "

nPaginas	:= nPaginas + 1
nLinhas 	:= 580

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Foot     ³ Autor ³ Adalberto Mendes Neto ³ Data ³ 17/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rodape do relatorio                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Foot                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTR270                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Foot()

Local cNome 	:= ""
Local cCodMat 	:= 0

nLinhas := 3000
oQPrint:Line(nLinhas, 0050, nLinhas, 2350 )  			// Horizontal
oQPrint:Line(nLinhas, 0050, nLinhas+110, 0050 )   		// vertical - Inicio
oQPrint:Line(nLinhas, 1500, nLinhas+110, 1500 )   		// vertical - Responsavel
oQPrint:Line(nLinhas, 2100, nLinhas+110, 2100 )   		// vertical - Data
oQPrint:Line(nLinhas, 2350, nLinhas+110, 2350 )   		// vertical - Final
oQPrint:Line(nLinhas+110, 0050, nLinhas+110, 2350 )	// Horizontal


cCodMat := QM4->QM4_RESP
DbSelectArea("QAA")
DbSetOrder(1)   

If DbSeek(xFilial("QAA")+cCodMat)
	cNome := QAA->QAA_NOME
Endif

oQPrint:Say(nLinhas,0050,STR0040,oFont10 ) //"Disposicao"
oQPrint:Say(nLinhas,1510,STR0041,oFont10 ) //"Responsavel"
oQPrint:Say(nLinhas,2110,STR0018,oFont10 ) //"Data"
oQPrint:Say(nLinhas+60,1540,cNome,oFont10n )
oQPrint:Say(nLinhas+60,2120,DTOC(QM4->QM4_DATA),oFont10n )
oQPrint:Say(nLinhas+30,0060,SubStr(QM4->QM4_DISPOS,1,60),oFont10n )
nLinhas+=30
oQPrint:Say(nLinhas+30,0060,SubStr(QM4->QM4_DISPOS,61,20),oFont10n )

Return
