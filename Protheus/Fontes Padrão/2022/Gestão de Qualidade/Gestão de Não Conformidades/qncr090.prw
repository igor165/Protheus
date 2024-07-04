#Include "PROTHEUS.CH"
#INCLUDE "QNCR090.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNCR090  ³ Autor ³ Aldo Marini Junior    ³ Data ³ 12.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lista de Verificacao por Produto                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCR090(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function QNCR090()
Private nLastKey  := 0
Private cPerg     := "QNR090"
Private Titulo    := OemToAnsi(STR0001)		//"LISTA DE VERIFICACAO POR PRODUTO"
Private nLig      := 0
Private nPag      := 0
Private nView     := 1
Private lPagPrint := .T.
Private cFilialDe
Private cFilialAte
Private cProdDe
Private cProdAte
Private dDataIni
Private dDataFim
Private nLista
Private nSalta
Private nOrdLista

INCLUI := .F.	// Utilizado devido algumas funcoes de retorno de descricao/nome
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        //  Filial De                                ³
//³ mv_par02        //  Filial Ate                               ³
//³ mv_par03        //  Produto De                               ³
//³ mv_par04        //  Produto Ate                              ³
//³ mv_par05        //  Data Inicial                             ³
//³ mv_par06        //  Data Final                               ³
//³ mv_par07        //  Visualiza antes  1-Sim/2-Nao             |
//³ mv_par08        //  Impressao por    1-Data/2-Produto        |
//³ mv_par09        //  Ordem Totais     1-Normal/2-Maior/3-Menor|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !pergunte("QNR090",.T.)
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFilialDe := mv_par01
cFilialAte:= mv_par02
cProdDe   := mv_par03
cProdAte  := mv_par04
dDataIni  := mv_par05
dDataFim  := mv_par06
nView     := mv_par07
nLista    := mv_par08	
nOrdLista := mv_par09

RptStatus({|lEnd| QNCR090Imp(@lEnd)},Titulo)

dbSelectArea( "QI2" )
dbSetOrder( 1 )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCR090Imp³ Autor ³ Aldo Marini Junior    ³ Data ³ 08.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime a Lista de Verificacao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³QNCR090Imp(lEnd,wnRel,cString)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd        - A‡Æo do Codelock                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCR090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QNCR090Imp(lEnd)

Local cArqNtx2
Local cIndCond2
Local cFor2
Local aCategorias := {}

Private cCodProd
Private oFont08, oFont10, oFont15, oFont10n, oFont21, oFont12
Private oQPrint
Private lFirst   := .T.
Private lInicial := .F.

Private cFileLogo  := ""
Private cNomFilial := ""

oFont06 := TFont():New("Courier New",06,08,,.T.,,,,.T.,.F.)
oFont10	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)

oFont12	:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)
oFont15	:= TFont():New("Courier New",15,15,,.T.,,,,.T.,.F.)
oFont21 := TFont():New("Courier New",21,21,,.T.,,,,.T.,.T.)

// 5o. Bold
// 9o. Italico
//10o. Underline

dbSelectArea( "QI2" )
If nLista == 1 // Por Data
	cIndCond2:= "QI2->QI2_FILIAL+QI2->QI2_CODCAT"
Else	// por Produto
	cIndCond2:= "QI2->QI2_FILIAL+QI2->QI2_CODPRO+QI2->QI2_CODCAT"
Endif

cFor2:= 'QI2->QI2_FILIAL >= "'+cFilialDe+'" .And. QI2->QI2_FILIAL <= "'+cFilialAte+'" .And. '
cFor2+= 'QI2->QI2_CODPRO >= "'+cProdDe+'" .And. QI2->QI2_CODPRO <= "'+cProdAte+'" .And. '
cFor2+= 'DTOS(QI2->QI2_OCORRE) >= "'+DTOS(dDataIni)+'" .And. DTOS(QI2->QI2_OCORRE) <= "'+DTOS(dDataFim)+'"'

cArqNtx2  := CriaTrab(NIL,.F.)
IndRegua("QI2",cArqNtx2,cIndCond2,,cFor2,STR0005)		//"Selecionando Registros..."
DbGoTop()

cFileLogo  := "LGRL"+SM0->M0_CODIGO
cNomFilial := AllTrim(QA_CHKFIL(QI2->QI2_FILIAL,,.T.))

If (FWModeAccess("QI2") == "C")
	cFileLogo += FWCodFil()+".BMP"
Else
	cFileLogo += QI2->QI2_FILIAL+".BMP"
Endif

If !File( cFileLogo )
	cFileLogo := "LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Regua de Processamento                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(QI2->(RecCount()))

While !Eof()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Movimenta Regua de Processamento                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IncRegua()

	If lEnd
		@Prow()+1,0 PSAY cCancel
		Exit
	Endif

	If !Empty(QI2->QI2_CODCAT)
		If nLista == 1	// Por Data
			If (nPos := aScan(aCategorias,{|x| x[1] == QI2->QI2_CODCAT })) == 0
				aAdd(aCategorias,{QI2->QI2_CODCAT,{0,0,0,0,0,0,0,0,0,0,0,0,0},0})
				aCategorias[Len(aCategorias),2,Month(QI2->QI2_OCORRE)] := aCategorias[Len(aCategorias),2,Month(QI2->QI2_OCORRE)] + 1
				aCategorias[Len(aCategorias),3] := aCategorias[Len(aCategorias),3] + 1
			Else
				aCategorias[nPos,2,Month(QI2->QI2_OCORRE)] := aCategorias[nPos,2,Month(QI2->QI2_OCORRE)] + 1
				aCategorias[nPos,3] := aCategorias[nPos,3] + 1
			Endif
		Else
			cCodProd := QI2->QI2_CODPRO
			aCategorias := {}
			While !Eof() .And. QI2->QI2_CODPRO == cCodProd
				If (nPos := aScan(aCategorias,{|x| x[1] == QI2->QI2_CODCAT })) == 0
					aAdd(aCategorias,{QI2->QI2_CODCAT,{0,0,0,0,0,0,0,0,0,0,0,0,0},0})
					aCategorias[Len(aCategorias),2,Month(QI2->QI2_OCORRE)] := aCategorias[Len(aCategorias),2,Month(QI2->QI2_OCORRE)] + 1
					aCategorias[Len(aCategorias),3] := aCategorias[Len(aCategorias),3] + 1
				Else
					aCategorias[nPos,2,Month(QI2->QI2_OCORRE)] := aCategorias[nPos,2,Month(QI2->QI2_OCORRE)] + 1
					aCategorias[nPos,3] := aCategorias[nPos,3] + 1
				Endif
				dbSkip()
			Enddo
			If Len(aCategorias) > 0
				If nOrdLista == 2	// Maior
					aCategorias := aSort(aCategorias,,,{|x,y| x[3] > y[3]})
				ElseIf nOrdLista == 3 // Menor
					aCategorias := aSort(aCategorias,,,{|x,y| x[3] < y[3]})
				Endif
				QNCR090DIA(aCategorias)
			Endif
		Endif
	Endif
	dbSelectArea("QI2")
	dbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime a Lista Por Data de acordo com o intervalo selecionado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nLista == 1	// Por Data
	If nOrdLista == 2	// Maior
		aCategorias := aSort(aCategorias,,,{|x,y| x[3] > y[3]})
	ElseIf nOrdLista == 3 // Menor
		aCategorias := aSort(aCategorias,,,{|x,y| x[3] < y[3]})
	Endif
	QNCR090DIA(aCategorias)
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Termino do relatorio                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QI2")
Set Filter to
RetIndex()
dbSetOrder(1)
If oQPrint <> NIL
	If nView == 1
		oQPrint:Preview()  // Visualiza antes de imprimir
	Else
	   oQPrint:Print() // Imprime direto na impressora default Protheus
	Endif
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCR090DIA³ Autor ³ Aldo Marini Junior    ³ Data ³ 08.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o grafico                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³QNCR090DIA(aCategorias)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1-Array contendo as linhas a serem impressas           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCR090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCR090DIA(aCategorias)
Local nA      := 0

Local nCaM    := 1
Local nCas    := 1
Local nCa     := 1
Local nTotGeral := 0
Local nLinG
Local nColG

Private nTotLGr := 550+(Min((1+Len(aCategorias)),17)*100)	// Total por pagina
Private nLinlGr := Len(aCategorias)-nTotLGr					// Total restante para outras paginas

If Len(aCategorias) == 0
	Return Nil
Endif

QNCR090CAB(aCategorias)

nLinG:=575	// Pulo 100
For nCa := 1 to Len(aCategorias)
	nColG:=1020	// Pulo 150
	oQPrint:Say(nLinG,70,OemToAnsi(aCategorias[nCa,1]+"-"+Left(FQNCNTAB("4",aCategorias[nCa,1]),30)) ,oFont10)
	oQPrint:Line( nLinG-20, 50, nLinG-20, 3000 )
	For nCaM := 1 to 12
		oQPrint:Say(nLinG, nColG,OemToAnsi(TransForm(aCategorias[nCa,2,nCaM],"@e 9999")) ,oFont12)
		nColG+=150
	Next
	nTotGeral+=aCategorias[nCa,3]
	oQPrint:Say(nLinG, nColG,OemToAnsi(TransForm(aCategorias[nCa,3],"@e 99999")) ,oFont12)
	nLinG+=100
	nA := nA + 1
	If nA == 16 .And. Len(aCategorias)-nCa > 0
		oQPrint:Line( nLinG-20, 50, nLing-20, 3000 )
		oQPrint:Say(nLinG-5, 65,OemToAnsi(STR0008) ,oFont15)	// "SUBTOTAL"
		nColG:=1000	// Pulo 150
		For nCaM := 1 to 12
			nTotCol:=0
			For nCas := 1 to nCa
				nTotCol+= aCategorias[nCas,2,nCaM]
			Next
			oQPrint:Say(nLinG-5, nColG, OemToAnsi(TransForm(nTotCol,"@e 99999")) ,oFont12)
			nColG+=150
		Next
		oQPrint:Say(nLinG-5, 2830, OemToAnsi(TransForm(nTotGeral,"@e 99999")) ,oFont12)

		nPag++
		oQPrint:Say(nLinG+100, 2850, OemToAnsi(STR0009+TransForm(nPag,"@e 999")),oFont12)
		
		oQPrint:EndPage()	// Finaliza Pagina
		
		nA := 0
		nLinG:=575	// Pulo 100
		nTotLGr := 550+(Min((1+Len(aCategorias)-nCa),17)*100)	// Total por pagina
		QNCR090CAB(aCategorias)
	Endif
Next
oQPrint:Line( nLinG-20, 50, nLing-20, 3000 )

oQPrint:Say(nLinG-5, 70,OemToAnsi(STR0006) ,oFont15)	// "TOTAL"
nColG:=995	// Pulo 150
For nCaM := 1 to 12
	nTotCol:=0
	For nCa := 1 to Len(aCategorias)
		nTotCol+= aCategorias[nCa,2,nCaM]
	Next
	oQPrint:Say(nLinG-5, nColG, OemToAnsi(TransForm(nTotCol,"@e 99999")) ,oFont12)
	nColG+=150
Next
oQPrint:Say(nLinG-5, 2830, OemToAnsi(TransForm(nTotGeral,"@e 99999")) ,oFont12)

nPag++
oQPrint:Say(nLinG+100, 2850, OemToAnsi(STR0009+TransForm(nPag,"@e 999")),oFont12)

oQPrint:EndPage()	// Finaliza Pagina
		
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCR090CAB³ Autor ³ Aldo Marini Junior    ³ Data ³ 18.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o cabecalho da lista de verificacao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³QNCR090CAB(aCategorias)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1-Array contendo as categorias (codigo e totais)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCR090                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCR090CAB(aCategorias)
Local nColEmp := 1500-((Len(cNomFilial)/2)*30) // Tamanho de fonte 15

If !lInicial
	lInicial := .T.
	oQPrint:= TMSPrinter():New( Titulo )
	oQPrint:SetLandscape()
Endif

oQPrint:StartPage() // Inicia uma nova pagina
oQPrint:SayBitmap(30,30, cFileLogo,474,117)

oQPrint:Say(030,nColEmp,cNomFilial,oFont15 )

oQPrint:Say(140,1100,OemToAnsi(STR0001),oFont21 )	// "LISTA DE VERIFICACAO"

If nLista == 2
	oQPrint:Box(300,  50, nTotLGr , 3000 ) // 2150
	oQPrint:Box(300,2350,398,3000)
	oQPrint:Say(305,  70, OemToAnsi(STR0002) ,oFont06)	// "PRODUTO"
	oQPrint:Say(345,  70, AllTrim(cCodProd)+"-"+AllTrim(FQNCDESPRO(cCodProd)),oFont12 )
	oQPrint:Say(305,2390,OemToAnsi(STR0007),oFont06)	// "PERIODO"	
	oQPrint:Say(345,2390,OemToAnsi(STRTRAN(DTOC(dDataIni)," ","_")+" - "+STRTRAN(DTOC(dDataFim)," ","_")),oFont12 )
Else
	oQPrint:Say(300,1200,OemToAnsi(STR0007+": "+STRTRAN(DTOC(dDataIni)," ","_")+" - "+STRTRAN(DTOC(dDataFim)," ","_")),oFont12 )
	oQPrint:Box(395,50 , nTotLGr , 3000 )	// 2150
Endif

oQPrint:Line(395,  50, 395, 3000 )
oQPrint:Say(450, 370,OemToAnsi(STR0003) ,oFont15)	// "Categoria"

oQPrint:Say(395, 1830,OemToAnsi(STR0004) ,oFont15)	// "M E S E S"
oQPrint:Line(455,  1000, 455, 2800 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cabecalho das Colunas do relatorio                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oQPrint:Say(475, 1040,OemToAnsi("01") ,oFont15)
oQPrint:Say(475, 1190,OemToAnsi("02") ,oFont15)
oQPrint:Say(475, 1340,OemToAnsi("03") ,oFont15)
oQPrint:Say(475, 1490,OemToAnsi("04") ,oFont15)
oQPrint:Say(475, 1640,OemToAnsi("05") ,oFont15)
oQPrint:Say(475, 1790,OemToAnsi("06") ,oFont15)
oQPrint:Say(475, 1940,OemToAnsi("07") ,oFont15)
oQPrint:Say(475, 2090,OemToAnsi("08") ,oFont15)
oQPrint:Say(475, 2240,OemToAnsi("09") ,oFont15)
oQPrint:Say(475, 2390,OemToAnsi("10") ,oFont15)
oQPrint:Say(475, 2540,OemToAnsi("11") ,oFont15)
oQPrint:Say(475, 2690,OemToAnsi("12") ,oFont15)
oQPrint:Say(450, 2820,OemToAnsi(STR0006) ,oFont15)	// "TOTAL"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Colunas do relatorio                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oQPrint:Line(395,  1000, nTotLGr, 1000 )
oQPrint:Line(455,  1150, nTotLGr, 1150 )
oQPrint:Line(455,  1300, nTotLGr, 1300 )
oQPrint:Line(455,  1450, nTotLGr, 1450 )
oQPrint:Line(455,  1600, nTotLGr, 1600 )
oQPrint:Line(455,  1750, nTotLGr, 1750 )
oQPrint:Line(455,  1900, nTotLGr, 1900 )
oQPrint:Line(455,  2050, nTotLGr, 2050 )
oQPrint:Line(455,  2200, nTotLGr, 2200 )
oQPrint:Line(455,  2350, nTotLGr, 2350 )
oQPrint:Line(455,  2500, nTotLGr, 2500 )
oQPrint:Line(455,  2650, nTotLGr, 2650 )
oQPrint:Line(395,  2800, nTotLGr, 2800 )

Return Nil
