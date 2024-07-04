#INCLUDE "QIER080.CH"
#INCLUDE "PROTHEUS.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIER080  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 14.06.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lotes por Laudo                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIER080()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQIE                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Antonio     ³10/01/00³------³ Ajustar Lay-out para mudan‡as de tam.    ³±±
±±³            ³        ³------³  no c¢digo do fornecedor.                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qier080()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Par„metros para a fun‡„o SetPrint () ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel    :="QIER080"
Local cString  :="QEK"
Local cDesc1   := STR0001 // "Este relatorio apresenta a quantidade de Entradas e o total entregue"
Local cDesc2   := STR0002 // "em cada laudo, organizados por fornecedor."
Local cDesc3   :=""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Par„metros para a fun‡„o Cabec()  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cTitulo   := STR0003	//"Lotes por Laudo"
Private cNomeProg := "QIER080"
Private cTamanho  := "M"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vari veis utilizadas pela fun‡„o SetDefault () ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aReturn  := {STR0004, 1,STR0005,  2, 2, 1, "",1 }		//"Zebrado"###"Administracao"
Private nLastKey := 0  
Private cPerg    := "QER080"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                    ³
//³ mv_par01 // Do  Periodo ?             	                                ³
//³ mv_par02 // At‚ Periodo ?                                               ³
//³ mv_par03 // Do  Fornecedor ?                                            ³
//³ mv_par04 // At‚ Fornecedor ?                                            ³
//³ mv_par05 // Considera Entradas? 1=Normais 2=Beneficiamento 3=Devolucoes?³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,wnrel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho)

If nLastKey == 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	Return
Endif

RptStatus({|lEnd| A080Imp(@lEnd,wnRel,cString,cTitulo)},cTitulo)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A080Imp  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 14.05.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Lotes por Laudo                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080Imp(lEnd,wnRel,cString,cTitulo)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQIE                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Vera        ³19/04/99³------³ Inclusao da Loja do Fornecedor           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A080Imp(lEnd,wnRel,cString,cTitulo)

Local cNomArq	:= ""
Local cKey		:= ""
Local cCond		:= ""
Local cQtRej	:= ""
Local cFornec	:= ""
Local cLoja     := ''
Local cTipoNF   := ''
Local cQQTDREJ  := ""
Local cCbTxt	:= Space(10)
Local nCbCont	:= 0
Local nQTRej	:= 0
Local nTQtRej	:= 0
Local nC 		:= 0
Local nPPM		:= 0
Local nSoma		:= 0
Local nQLot		:= 0
Local nQTamLot	:= 0
Local nQTLot	:= 0
Local nQTTamLot := 0
Local lImp		:= .F.
Local aLaudo	:= {}
Local aEntreg	:= {}
Local aTamLote  := {}
Local aTEntreg  := {}
Local aTTamLot  := {}
Local cStrUsado := ""
Local nTamUsado := 0  
Local cSeek     := ""
Local cLaudo	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³aLaudo  :Armazena no Vetor com os Laudos pelo Arq. QEK    ³
//³aEntreg :Armazena no Vetor a quantidade de Entradas com   ³
//³         o determinado Laudo. Por fornecedor.             ³
//³aTamLote:Armazena no Vetor o Tamanho do Lote. Se o para-  ³
//³         metro MV_QQTDRES == 'S'. Ir  utilizar a quanti-  ³
//³         dade Rejeitada. Ex.:QEK_TAMLOT - QEL_QTREJ       ³
//³aTEntreg:Quantidade total de Entradas de todos os fornec. ³
//³aTTamLot:Quantidade total do Tamanho do Lote de todos os  ³
//³         Fornecedores,de acordo com o parametro MV_QQTDRES³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro para utilizar a quantidade rejeitada.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQQTDREJ := GetMV("MV_QQTDREJ")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
li       := 80
m_pag    := 1

Cabec1	:=STR0006+Dtoc(mv_par01) + STR0007+ Dtoc(mv_par02)		//"Periodo : "###" a "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena no Array os Laudos.                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QED")
dbSetOrder(1)
dbSeek(xFilial("QED"))
Do While !Eof() .And. xFilial("QED") == QED_FILIAL
	Aadd(aLaudo,QED_CODFAT)
	Aadd(aEntreg,0)
	Aadd(aTamLote,0)
	Aadd(aTEntreg,0)
	Aadd(aTTamLot,0)
	If QED_CATEG == "3"
		cQtRej := QED->QED_CODFAT 		//Vari vel com o £ltimo fator.
	EndIf
	dbSkip()
EndDo

dbSelectArea("QEK")
cKey := IndexKey()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Tipo de Entrada a ser considerada				   	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCond := 'QEK_FILIAL == "'+xFilial("QEK")+'"'
If mv_par05 == 1
	cCond += '.And. ('+'QEK->QEK_TIPONF == "N" .Or.'+'QEK->QEK_TIPONF == " "'+')'
ElseIf mv_par05 == 2
	cCond += '.And. QEK->QEK_TIPONF == "B"'
ElseIf mv_par05 == 3                
	cCond += '.And. QEK->QEK_TIPONF == "D"'
EndIf
cCond += '.And. Dtos(QEK_DTENTR) >= "'+Dtos(mv_par01)+'" .And. Dtos(QEK_DTENTR) <= "'+Dtos(mv_par02)+'"'
cCond += '.And. QEK_FORNEC >= "'+mv_par03+'".And. QEK_FORNEC <= "'+mv_par04+'"'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o indice de trabalho                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq:=CriaTrab(NIL,.F.)
IndRegua("QEK",cNomArq,cKey,,cCond,STR0008)		//"Selecionando Registros..."
nIndex := RetIndex("QEK")
dbSetOrder(nIndex+1)
dbGoTop()

If BOF() .And. EOF()
	Set Device to Screen
	HELP(" ",1,"RECNO")
	dbSelectArea("QEK")
	Set Filter To
	RetIndex("QEK")
	dbSetOrder(1)
	If File(cNomArq+OrdBagExt())
		Ferase(cNomArq+OrdBagExt())
	EndIf
	Return .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lay-out com fornecedor tamanho 6.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//0123456789012345678901234567890123456789012345678901234567890123456789
//          1         2         3         4         5         6
//      ---------------------------------------------------------------------
//      | XXXXXX - XXXXXXXXXXXXXXXXXXXX       | Nr.Entradas | Qtde Entregue |
//      |-------------------------------------------------------------------|
//      | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX - X  |      999999 |        999999 |
//      |                                     |             |               |
//      |                                     |             |               |
//      ---------------------------------------------------------------------

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lay-out com fornecedor tamanho 20.                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//0123456789012345678901234567890123456789012345678901234567890123456789
//          1         2         3         4         5         6
//      ---------------------------------------------------------------------
//      | 012345678901234567890-0123456789012 | Nr.Entradas | Qtde Entregue |
//      | 4567890                             |             |               |
//      |-------------------------------------------------------------------|
//      | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX - X  |      999999 |        999999 |
//      |                                     |             |               |
//      |                                     |             |               |
//      ---------------------------------------------------------------------

SetRegua(RecCount())

While !Eof() .And. xFilial("QEK") == QEK_FILIAL

	aFill(aEntreg,0)
	aFill(aTamLote,0)
	
	nQLot		:= 0
	nQTamLot	:= 0
	nQTRej   	:= 0
	nSoma		:= 0
		
	// Calcula por Fornecedor (geral) e nao por Fornecedor/Loja Fornec.
	cFornec := QEK_FORNEC
	cLoja   := QEK_LOJFOR
	cTipoNF := QEK_TIPONF
	While !Eof() .And. cFornec == QEK_FORNEC
		IncRegua()
		nQLot++
		nQTamLot+=SuperVal(QEK_TAMLOT)

		nQTLot++
		nQTTamLot+=SuperVal(QEK_TAMLOT)         
		
		
		QEL->(dbSetOrder(3))
		cSeek := QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF+QEK->QEK_TIPONF+DTOS(QEK->QEK_DTENTR)+QEK->QEK_LOTE
		
		If QEL->(dbSeek(xFilial("QEL")+cSeek+Space(TamSX3("QEL_LABOR")[1])))
			If !Empty(QEL->QEL_LAUDO)
				nPos:= AsCan(aLaudo,QEL->QEL_LAUDO)
				aEntreg[nPos]++
				aTEntreg[nPos]++
				nQtRej+=SuperVal(QEL->QEL_QTREJ)
				nTQtRej+=SuperVal(QEL->QEL_QTREJ)

				If cQQTDREJ == "S"	//Parametro da quantidade rejeitada.
					If !Empty(QEL->QEL_QTREJ)
						aTamLote[nPos]+=SuperVal(QEK_TAMLOT) - SuperVal(QEL->QEL_QTREJ)
						aTTamLot[nPos]+=SuperVal(QEK_TAMLOT) - SuperVal(QEL->QEL_QTREJ)
						
						nP := aScan(aLaudo,cQtRej)
						aTamLote[nP]+= SuperVal(QEL->QEL_QTREJ)
						aTTamLot[nP]+= SuperVal(QEL->QEL_QTREJ)
					Else
						aTamLote[nPos]+=SuperVal(QEK_TAMLOT)
						aTTamLot[nPos]+=SuperVal(QEK_TAMLOT)
					EndIf
				Else
					aTamLote[nPos]+=SuperVal(QEK_TAMLOT)
					aTTamLot[nPos]+=SuperVal(QEK_TAMLOT)
				EndIf
			EndIf
		EndIf
		lImp:=.T.
		dbSkip()
	EndDo
	
	If lImp
		If Li > 52
			Cabec(cTitulo,Cabec1,"",cNomeProg,cTamanho)
		EndIf
		@Li,06 PSAY Replicate("-",68)
		Li++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Realiza a pesquisa do Cliente e/ou Fornecedor				³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cStrUsado := AllTrim(cFornec)
		
		If cTipoNF $ "D/B"
			SA1->(dbSetOrder(1))
			If SA1->(dbSeek(xFilial("SA1")+cFornec+cLoja))
				cStrUsado := cStrUsado + "-" + cLoja + " " + AllTrim(SA1->A1_NREDUZ)
			EndIf                       
		Else
			SA2->(dbSetOrder(1))
			If SA2->(dbSeek(xFilial("SA2")+cFornec+cLoja))
				cStrUsado := cStrUsado + "-" + cLoja + " " + AllTrim(SA2->A2_NREDUZ)
			EndIf                       
		EndIf                
		
		nTamUsado := Len(cStrUsado)

		@Li,06 PSAY "| "
		@Li,08 PSAY Subs(cStrUsado,1,35)
		@Li,44 PSAY STR0009		//"| Nr.Entradas |  Qt Entregue |"
		Li++
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o tamanho usado for menor do que o nome reduzido            ³
		//³ entao utiliza mais uma linha para imprimir o restante do nome. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		If nTamUsado > 35 
			@Li,06 PSAY "| "
			@Li,08 PSAY Subs(cStrUsado,35+1,35)
			@Li,44 PSAY "|             |              |"
			Li++
		EndIf

		@Li,06 PSAY "|"+Replicate("-",66)+"|"
		Li++
		@Li,06 PSAY "|"+STR0010	//"Entradas"
		@Li,44 PSAY "| "
		@Li,46 PSAY nQLot
		@Li,58 PSAY "| "
		@Li,60 PSAY nQTamLot
		@Li,73 PSAY "|"
		Li++
		For nC:= 1 To Len(aLaudo)
			QED->(dbSetOrder(1))
			QED->(dbSeek(xFilial("QED")+aLaudo[nC]))
			cLaudo := QaxIdioma("QED->QED_DESCPO","QED->QED_DESCIN","QED->QED_DESCES")
			@Li,06 PSAY "|" + cLaudo + " - " + QED->QED_CODFAT
			@Li,44 PSAY "| " 
			@Li,46 PSAY aEntreg[nC]
			@Li,58 PSAY "| "
			@Li,60 PSAY aTamLote[nC]
			@Li,73 PSAY "|"
			Li++
		Next nC
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ C lculo do PPM do Fornecedor                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nC := 1 To Len(aLaudo)
			nSoma+= aTamLote[nC]
		Next nC

		@Li,06 PSAY STR0011		//"|Quantidade Rejeitada"
		@Li,44 PSAY "|"
		@Li,58 PSAY "| "
		@Li,60 PSAY nQtRej
		@Li,73 PSAY "|"
		Li++
		
		nPPM := (nQtRej / nSoma) * 1000000

		@Li,06 PSAY STR0012	//"|PPM"
		@Li,44 PSAY "|"
		@Li,58 PSAY "| "+Str(nPPM,10,2)
		@Li,73 PSAY "|"
		Li++
		@Li,06 PSAY Replicate("-",68)
		Li+=2
	EndIf
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ImpressÆo Geral                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lImp
	If Li > 52
		Cabec(cTitulo,Cabec1,"",cNomeProg,cTamanho)
	EndIf
	@Li,06 PSAY Replicate("-",68)
	Li++
	@Li,06 PSAY STR0013		//"| Total"
	@Li,44 PSAY STR0009		//"| Nr.Entradas |  Qt Entregue |"
	Li++
	@Li,06 PSAY "|"+Replicate("-",66)+"|"
	Li++
	@Li,06 PSAY "|"+STR0010		//"Entradas"
	@Li,44 PSAY "| "
	@Li,46 PSAY nQTLot
	@Li,58 PSAY "| "
	@Li,60 PSAY nQTTamLot
	@Li,73 PSAY "|"
	Li++
	For nC:= 1 To Len(aLaudo)
		QED->(dbSetOrder(1))
		QED->(dbSeek(xFilial("QED")+aLaudo[nC]))
		cLaudo := QaxIdioma("QED->QED_DESCPO","QED->QED_DESCIN","QED->QED_DESCES")
		@Li,06 PSAY "|" + cLaudo + " - " + QED->QED_CODFAT
		@Li,44 PSAY "| "
		@Li,46 PSAY aTEntreg[nC]
		@Li,58 PSAY "| "
		@Li,60 PSAY aTTamLot[nC]
		@Li,73 PSAY "|"
		Li++
	Next nC

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ C lculo do PPM do Fornecedor                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nSoma:=0
	For nC := 1 To Len(aLaudo)
		nSoma+= aTTamLot[nC]
	Next nC

	If cQQTDREJ == "N"	//Parametro da quantidade rejeitada.
		@Li,06 PSAY STR0011	//"|Quantidade Rejeitada"
		@Li,44 PSAY "|"
		@Li,58 PSAY "| "
		@Li,60 PSAY nTQtRej
		@Li,73 PSAY "|"
		Li++
	EndIf

	nPPM := (nTQtRej / nSoma) * 1000000
	@Li,06 PSAY STR0012		//"|PPM"
	@Li,44 PSAY "|"
	@Li,58 PSAY "| "+ Str(nPPM,10,2)
	@Li,73 PSAY "|"
	Li++
	@Li,06 PSAY Replicate("-",68)
EndIf

If Li != 80
	roda(nCbCont,cCbTxt)
EnDif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("QEK")
Set Filter To
RetIndex("QEK")
dbSetOrder(1)
If File(cNomArq+OrdBagExt())
	Ferase(cNomArq+OrdBagExt())
EndIf

Set device to Screen

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
EndIf

MS_FLUSH()

Return .T.
