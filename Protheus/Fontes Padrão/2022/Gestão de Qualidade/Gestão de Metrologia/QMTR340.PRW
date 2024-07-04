#INCLUDE "QMTR340.CH"
#INCLUDE "FIVEWIN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QMTR340  ³ Autor ³ Denis Martins         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Impressao dos graficos MSA 3 Edicao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMTR340(lBrow,nChart)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Chamada da mBrowse                                 ³±±
±±³          ³ ExpN1 = Imprime Tipo de Grafico                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQMT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Denis Martins³        ³      ³ Inclusao dos dados na moldura          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QMTR340(lBrow,nChart,cInstrt,cRevvt,cDQM2cr,lBiCaudal)

Local oPrint
Local lPergunte := .F.

Default nChart := 1
Default lBrow 	:= .F.
Default cInstrt := QM2->QM2_INSTR
Default cRevvt 	:= QM2->QM2_REVINS
Default cDQM2cr := QM2->QM2_DESCR
Default lBiCaudal := .F.

Private cArqDeTe  := "" 
Private cArqDeL1  := ""
Private cArqDeLn  := ""
Private cArqDeL2  := ""
Private cArqDeLt  := ""
Private cArqDeLr  := ""
Private cArqDeCt  := ""
Private cArqDeBi  := ""
Private cDir	  := GetMv("MV_QDIRGRA")

// Verifica se o diretorio do grafico e um  diretorio Local
If !QA_VerQDir(cDir) 
	Return
EndIf

oPrint	:= TMSPrinter():New(STR0002) //"MSA 3Ed."

If nChart == 3
	oPrint:SetLandScape()
Else
	oPrint:SetPortrait()
Endif	

MsgRun(OemToAnsi(STR0001),"",{|| CursorWait(), Q340MtRel(oPrint,nChart,cInstrt,cRevvt,cDQM2cr,lBiCaudal) ,CursorArrow()}) //"Gerando Impressao, Aguarde..."

oPrint:EndPage() 		// Finaliza a pagina

oPrint:Preview()  		// Visualiza antes de imprimir

//Deleta os arquivos temporarios .BMP

If File(cDir+cArqDeTe)
	FErase (cDir+cArqDeTe) 			
Endif

If File(cDir+cArqDeTe)
	FErase (cDir+cArqDeTe) 			
Endif

If File(cDir+cArqDeL1)
	FErase (cDir+cArqDeL1) 			
Endif

If File(cDir+cArqDeLn)
	FErase (cDir+cArqDeLn) 			
Endif

If File(cDir+cArqDeL2)
	FErase (cDir+cArqDeL2) 			
Endif

If File(cDir+cArqDeCt)
	FErase (cDir+cArqDeCt) 			
Endif

If File(cDir+cArqDeLr)
	FErase (cDir+cArqDeLr) 			
Endif
If File(cDir+cArqDeBi)
	FErase (cDir+cArqDeBi) 			
Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Q340MtRel³ Autor ³ Denis Martins         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³MSA 3 EDICAO                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q340MtRel(ExpO1,ExpN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpN1 = Flag para impressao do grafico                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTR340                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Q340MtRel(oPrint, nChart, cInstrt, cRevvt, cDQM2cr,lBiCaudal)

Local i 	:= 1
Local lin 	:= 0

Private oFont16, oFont08, oFont10, oFont12b


oPrint:StartPage() 		// Inicia uma nova pagina

oFont16	:= TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)
oFont08	:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
oFont10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont12b:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)

Q340CALHO(oPrint,i,nChart, cInstrt, cRevvt, cDQM2cr) 			// Funcao que monta o cabecalho

lin := Q340Dtail(oPrint,i,nChart,cInstrt, cRevvt, cDQM2cr,lBiCaudal)	// Funcao que monta os detalhes

lin := 150

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Q340CALHO ³ Autor ³ Denis Martins         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cabecalho do relatorio                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q340CALHO(ExpO1,ExpN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpN1 = Contador de paginas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPR170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Q340CALHO(oPrint,i,nChart,cInstrt,cRevvt,cDQM2cr)

Local cTiMsa:= ""

If nChart == 1
	cTiMsa := OemToAnsi(STR0006) //"TENDENCIA"
ElseIf nChart == 2
	cTiMsa := OemToAnsi(STR0007) //"LINEARIDADE"
ElseIf nChart == 3
	cTiMsa := OemToAnsi(STR0008) //"ESTABILIDADE"
Endif

If nChart <> 3
	oPrint:Say(075,900,OemToAnsi(STR0003)+cTiMsa,oFont16 ) //"GRAFICO"
	
	//Box Cabecalho
	oPrint:Box( 150, 30, 290, 2350 )
	oPrint:Line( 150, 640, 289, 640 )   	// vertical - revisao.. 	 
	oPrint:Line( 150, 930, 289, 930 )   	// vertical - descricao..	
	// Descricao do Cabecalho
	// 1a Linha
	oPrint:Say(160,0040,OemToAnsi(STR0004),oFont08 ) //"Instrumento"
	oPrint:Say(202,0040,Alltrim(cInstrt),oFont08 )
	
	oPrint:Say(160,650,OemToAnsi(STR0005),oFont08 ) //"Revisao"
	oPrint:Say(202,650,Alltrim(cRevvt),oFont08 )

	oPrint:Say(160,940,OemToAnsi(STR0016),oFont08 ) //"Descricao"
	oPrint:Say(202,940,Alltrim(cDQM2cr),oFont08 )

Else
	oPrint:Say(075,1010,OemToAnsi(STR0003)+cTiMsa+"/"+OemToAnsi(STR0006),oFont16 ) //"GRAFICO" "/TENDENCIA"
	oPrint:Box( 150, 30, 290, 3065 )
	oPrint:Line( 150, 720, 289, 720 )   	// vertical    
	oPrint:Line( 150, 1020, 289, 1020 )   	// vertical    	
	oPrint:Say(160,0040,OemToAnsi(STR0004),oFont08 ) //"Instrumento"
	oPrint:Say(202,0040,Alltrim(cInstrt),oFont08 )
	
	oPrint:Say(160,730,OemToAnsi(STR0005),oFont08 ) //"Revisao"
	oPrint:Say(202,730,Alltrim(cRevvt),oFont08 )			

	oPrint:Say(160,1030,OemToAnsi(STR0016),oFont08 ) //"Descricao"
	oPrint:Say(202,1030,Alltrim(cDQM2cr),oFont08 )

Endif

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Q340Dtail³ Autor ³ Denis Martins         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Detalhes do relatorio de MSA                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q340Dtail(ExpO1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpN1 = Contador de paginas                                ³±±
±±³          ³ ExpN2 = Flag para impressao do grafico                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTR340                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Q340Dtail(oPrint,i,nChart,cInstrt,cRevvt,cDQM2cr,lBiCaudal)
Local lin		:= 580
Local cArqOrTe  := ""
Local cArqOrL1  := ""
Local cArqOrLn  := ""
Local cArqOrL2  := ""
Local cArqOrLt  := ""
Local cArqOrLr  := ""
Default lBiCaudal := .F.

If nChart == 1
	If Right(cDir,1) <> "\"
		cDir += "\"
	Endif
	If File(cDir+"TENDE.BMP")            
		cArqOrTe := "TENDE.BMP"
		cArqDeTe := CriaTrab(, .F.) + ".BMP"
		fRename(cDir+cArqOrTe,cDir+cArqDeTe)
		oPrint:SayBitmap(350,30,cDir+cArqDeTe,2320,1150) //cDir+"TENDE.BMP"
	Endif
	oPrint:Say(1542,1099,OemToAnsi(STR0009),oFont16 ) //"RESULTADOS"
	
	lin := 1635
	If !lBiCaudal
		If File(cDir+"LEG1.BMP")
			cArqOrL1 := "LEG1.BMP"
			cArqDeL1 := CriaTrab(, .F.) + ".BMP"
			fRename(cDir+cArqOrL1,cDir+cArqDeL1)
			oPrint:SayBitmap(lin,854,cDir+cArqDeL1,870,1528)
		Endif  
	Else	
		If File(cDir+"LEGD.BMP")
			cArqOrL1 := "LEGD.BMP"
			cArqDeBi := CriaTrab(, .F.) + ".BMP"
			fRename(cDir+cArqOrL1,cDir+cArqDeBi)
			oPrint:SayBitmap(lin,854,cDir+cArqDeBi,870,1528)
		Endif	
	Endif	
Elseif nChart == 2
	If Right(cDir,1) <> "\"
		cDir += "\"
	Endif
	If File(cDir+"LINEA.BMP")
		cArqOrLn := "LINEA.BMP"
		cArqDeLn := CriaTrab(, .F.) + ".BMP"
		fRename(cDir+cArqOrLn,cDir+cArqDeLn)
		oPrint:SayBitmap(600,30,cDir+cArqDeLn,2320,1150)
	Endif

	oPrint:Say(1895,800,OemToAnsi(STR0014),oFont16 ) //"ANALISE NUMERICA - RESULTADOS"

	lin := 2100

	If File(cDir+"LEG2.BMP")
		cArqOrL2 := "LEG2.BMP"
		cArqDeL2 := CriaTrab(, .F.) + ".BMP"
		fRename(cDir+cArqOrL2,cDir+cArqDeL2)
		oPrint:SayBitmap(lin,405,cDir+cArqDeL2,1535,870)
	Endif
Elseif nChart == 3
	If Right(cDir,1) <> "\"
		cDir += "\"
	Endif
	If File(cDir+"CARTA.BMP")
		cArqOrLt := "CARTA.BMP"
		cArqDeLt := CriaTrab(, .F.) + ".BMP"
		fRename(cDir+cArqOrLt,cDir+cArqDeLt)
		oPrint:SayBitmap(297,30,cDir+cArqDeLt,3050,1000)
	Endif

	If File(cDir+"CARTA2.BMP")
		cArqOrLr := "CARTA2.BMP"
		cArqDeLr := CriaTrab(, .F.) + ".BMP"
		fRename(cDir+cArqOrLr,cDir+cArqDeLr)
		oPrint:SayBitmap(1352,30,cDir+"CARTA2.BMP",3050,1000)
	Endif

	oPrint:EndPage() 		// Finaliza a pagina
	oPrint:StartPage() 		// Inicia uma nova pagina		

	oPrint:Say(075,1010,OemToAnsi(STR0003)+OemToAnsi(STR0008)+"/"+OemToAnsi(STR0006),oFont16 ) //"GRAFICO"

	oPrint:Box( 150, 30, 290, 3065 )
	oPrint:Line( 150, 720, 289, 720 )   	// vertical    
	oPrint:Line( 150, 1020, 289, 1020 )   	// vertical    	
	oPrint:Say(160,0040,OemToAnsi(STR0004),oFont08 ) //"Instrumento"
	oPrint:Say(202,0040,Alltrim(cInstrt),oFont08 )
	
	oPrint:Say(160,730,OemToAnsi(STR0005),oFont08 ) //"Revisao"
	oPrint:Say(202,730,Alltrim(cRevvt),oFont08 )			

	oPrint:Say(160,1030,OemToAnsi(STR0016),oFont08 ) //"Descricao"
	oPrint:Say(202,1030,Alltrim(cDQM2cr),oFont08 )

	lin := 320
	oPrint:Say( lin,1320,Alltrim(OemToAnsi(STR0015)),oFont16 )	//"L E G E N D A"	

	If File(cDir+"LEG1.BMP")
		cArqOrL1 := "LEG1.BMP"
		cArqDeL1 := CriaTrab(, .F.) + ".BMP"
		fRename(cDir+cArqOrL1,cDir+cArqDeL1)
		oPrint:SayBitmap(lin+200,1090,cDir+cArqDeL1,870,1528)
	Endif
Endif

Return lin