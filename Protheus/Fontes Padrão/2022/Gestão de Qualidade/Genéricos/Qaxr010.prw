#INCLUDE "QAXR010.CH"
#INCLUDE "REPORT.CH"
#Include "PROTHEUS.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QAXR010  ³ Autor ³ Leandro S. Sabino     ³ Data ³ 08/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Questionarios				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs:      ³ (Versao Relatorio Personalizavel) 		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQDO	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function QAXR010()
Local oReport

If TRepInUse()
	Pergunte("QXR010",.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
	QAXR010R3() //Executa versão anterior do fonte              
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef()   ³ Autor ³ Leandro Sabino   ³ Data ³ 08/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montar a secao				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDef()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXR010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local oReport 
Local oSection1 
Local oSection2 
Local oSection3 

DEFINE REPORT oReport NAME "QAXR010" TITLE OemToAnsi(STR0001) PARAMETER "QXR010" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION OemToAnsi(STR0002)+OemToAnsi(STR0003) 
//"QUESTIONARIOS"##"Este programa ira imprimir Questionarios"##"de acordo com os parƒmetros definidos pelo usu rio."

DEFINE SECTION oSection1 OF oReport 	TITLE OemToAnsi(STR0016) TABLES "QAG" //Questao 
DEFINE SECTION oSection2 OF oSection1 	TITLE OemToAnsi(STR0017) TABLES "QAH" //Resposta
DEFINE SECTION oSection3 OF oSection2 	TITLE TITSX3("QAI_DESRES")[1] TABLES "QAI" //Descricao da Resposta

DEFINE CELL NAME "QAG_QUEST"    OF oSection1 ALIAS "QAG" 
DEFINE CELL NAME "QAG_RV"    	OF oSection1 ALIAS "QAG" 
DEFINE CELL NAME "QAG_TITULO"   OF oSection1 ALIAS "QAG" 
DEFINE CELL NAME "QAG_DOCTO"    OF oSection1 ALIAS "QAG"
DEFINE CELL NAME "QAG_RVDOC"    OF oSection1 ALIAS "QAG" 

DEFINE CELL NAME "QAH_SEQPER"   OF oSection2 ALIAS "QAH"
DEFINE CELL NAME "QAG_QUEST"    OF oSection2 ALIAS "QAG" 
DEFINE CELL NAME "cDESPER"    	OF oSection2 				TITLE TitSX3("QAH_DESPER")[1] SIZE 130 LINE BREAK

DEFINE CELL NAME "QAI_SEQRES"   OF oSection3 ALIAS "QAI"  
DEFINE CELL NAME "cDESRES"    	OF oSection3 				TITLE TitSX3("QAI_DESRES")[1] SIZE 140 LINE BREAK
DEFINE CELL NAME "QAI_PONTO"    OF oSection3 ALIAS "QAI"

Return oReport



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PrintReport   ³ Autor ³ Leandro Sabino   ³ Data ³ 26/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprimir os campos do relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrintReport(ExpO1)  	     	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXR010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintReport(oReport)               
Local oSection1   := oReport:Section(1)
Local oSection2   := oReport:Section(1):Section(1)
Local oSection3   := oReport:Section(1):Section(1):Section(1)
Local cFiltro 	  := " "
Local ctexto      := ""
Local nPonTot     := 0
Local nPonMin     := 0

MakeAdvplExpr("QXR010")
              
DbSelectarea("QAG")
DbSetOrder(1)
cFiltro:= 'QAG->QAG_FILIAL == "'+xFilial("QAG")+'" .And. '
cFiltro+= 'QAG->QAG_QUEST >= "'+mv_par01+'".And. QAG->QAG_QUEST <= "'+mv_par02+'" .And. '
cFiltro+= 'QAG->QAG_RV >= "'+mv_par03+'".And. QAG->QAG_RV <= "'+mv_par04+'" .And. '
cFiltro+= 'QAG->QAG_DOCTO >= "'+mv_par05+'".And. QAG->QAG_DOCTO <= "'+mv_par06+'" .And. '
cFiltro+= 'QAG->QAG_RVDOC >= "'+mv_par07+'".And. QAG->QAG_RVDOC <= "'+mv_par08+'" .And. '
cFiltro+= 'QAG->QAG_MAT >= "'+mv_par10+'".And. QAG->QAG_MAT <= "'+mv_par11+'"'

oSection1:SetFilter(cFiltro)

dbGoTop()

If !Empty(AllTrim(oSection2:GetAdvplExp("QAH")))
	cCondR4 += oSection2:GetAdvplExp("QAH")
EndIf

While !oReport:Cancel() .And. QAG->(!Eof())

	nPonMin:= QAG->QAG_PONTMI
	nPonTot:= 0
		
	If QAH->(DbSeek(QAG->QAG_FILIAL+QAG->QAG_QUEST+QAG->QAG_RV))//Perguntas
		oSection1:Init()
		oSection1:PrintLine()
	                                                         
		While QAH->(!Eof()) .And. QAH->QAH_FILIAL+QAH->QAH_QUEST+QAH->QAH_RV == QAG->QAG_FILIAL+QAG->QAG_QUEST+QAG->QAG_RV
	    
			oReport:SkipLine(2)	
			oReport:ThinLine()
			oSection2:Init()		       
			ctexto:= MSMM(QAH->QAH_DESPER,70)
			oSection2:Cell("cDESPER"):SetValue(ctexto)
			oSection2:PrintLine()
		
			If QAI->(DbSeek(QAH->QAH_FILIAL+QAH->QAH_QUEST+QAH->QAH_RV+QAH->QAH_SEQPER))//Respostas
				oSection3:Init()
				While QAI->(!Eof()) .And. QAI->QAI_FILIAL+QAI->QAI_QUEST+QAI->QAI_RV+QAI->QAI_SEQPER == QAH->QAH_FILIAL+QAH->QAH_QUEST+QAH->QAH_RV+QAH->QAH_SEQPER
					If mv_par09 == 2 .And. QAI->QAI_PONTO == 0       
						QAI->(DbSkip())  //se Ponto = 0 nao imprimo e pulo p/ o proximo
						Loop
					EndIf
					oSection3:Cell("cDESRES"):SetValue(QAI->QAI_DESRES)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Imprime a Pontuacao da Resposta Correta          	   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If mv_par09 == 2
                        nPonTot := nPonTot + QAI->QAI_PONTO	
                    EndIf
					oSection3:PrintLine()
					QAI->(DbSkip())
				EndDo
				oSection3:Finish()
			EndIf
			oSection2:Finish()	
			QAH->(DbSkip())		
		EndDo
	EndIf

	QAG->(DbSkip()) 
	oReport:FatLine()
	oReport:SkipLine(1)			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime a Pontuacao Total do Questionario     		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  mv_par09 == 2
		oReport:ThinLine()
		oReport:PrintText(OemToAnsi(STR0011)+ " " + Right(Str(nPonTot),8),oReport:Row(),025)//"Total de Pontos:" 
		oReport:SkipLine(1)	
		oReport:PrintText(OemToAnsi(STR0012) + Right(Str(nPonMin),8),oReport:Row(),025)//"Pontuacao Minima" 
		oReport:ThinLine()
	EndIf
	oSection1:Finish()	
	oSection1:SetPageBreak(.T.) 

EndDo

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QAXR010R3³ Autor ³ Eduardo de Souza      ³ Data ³ 06/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Questionarios                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXR010                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Eduardo Ju  ³21/11/02³ ---- ³Incluido a pergunta 9 para listar todas   ³±±
±±³            ³        ³      ³respostas ou somente as corretas.         ³±±
±±³Eduardo S.  ³25/11/02³ ---- ³Acerto para quebrar as palavras corretamen³±±
±±³            ³        ³      ³te na impressao do titulo e respostas.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QAXR010R3()

Local cTitulo:= OemToAnsi(STR0001) // "QUESTIONARIOS"
Local cDesc1 := OemToAnsi(STR0002) // "Este programa ira imprimir Questionarios"
Local cDesc2 := OemToAnsi(STR0003) // "de acordo com os parƒmetros definidos pelo usu rio."
Local cString:= "QAG"
Local wnrel  := "QAXR010"
Local Tamanho:= "P"

Private cPerg   := "QXR010"
Private aReturn := {STR0004,1,STR0005,1,2,1,"",1} // "Zebrado" ### "Administra‡ao"
Private nLastKey:= 0
Private INCLUI  := .F.	// Colocada para utilizar as funcoes

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                               ³
//³ mv_par01	// De Questionario                                     ³
//³ mv_par02	// Ate Questionario                                    ³
//³ mv_par03	// De Revisao                                          ³
//³ mv_par04	// Ate Revisao                                         ³
//³ mv_par05	// De Documento                                        ³
//³ mv_par06	// Ate Documento                                       ³
//³ mv_par07	// De Rev Documento                                    ³
//³ mv_par08	// Ate Rev Documento                                   ³
//³ mv_par09    // Imprime Respostas: 1-Todas 2-Apenas Corretas        ³  
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                      

Pergunte(cPerg,.F.)

wnrel := AllTrim(SetPrint(cString,wnrel,cPerg,ctitulo,cDesc1,cDesc2,"",.F.,,,Tamanho))

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| QAXR110Imp(@lEnd,ctitulo,wnRel,tamanho)},ctitulo)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QAXR110Imp³ Autor ³ Eduardo de Souza      ³ Data ³ 06/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Envia para funcao que faz a impressao do relatorio.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAXR110Imp(ExpL1,ExpC1,ExpC2,ExpC3)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXR110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QAXR110Imp(lEnd,ctitulo,wnRel,tamanho)

Local cCabec1 := " "
Local cCabec2 := " "
Local cbtxt   := SPACE(10)
Local nTipo	  := GetMV("MV_COMP")
Local cbcont  := 0
Local cIndex1 := CriaTrab(Nil,.F.)
Local cFiltro := " "
Local aResp   := " "
Local aTit    := " "
Local cQuest  := " "
Local cRv     := " "
Local nLinha  := 0
Local nI      := 0
Local nPonMin := 0
Local nPonTot := 0
Local nCount    :=0
Local cAcentos  := "€ú‡úŽúú…ú†úƒú úúˆú‚ú¡ú“ú”ú¢ú™ú£ú"
Local cAcSubst  := "C,c,A~A'a`a~a^a'E'e^e'i'o^o~o'O~U'"
Local cImpTxt   :=""
Local cImpLinha :=""
Local lFirst    := .T.

Private nLin    := 0

DbSelectarea("QAG")//Questionarios
DbSetOrder(1)

cFiltro:= 'QAG->QAG_FILIAL == "'+xFilial("QAG")+'" .And. '
cFiltro+= 'QAG->QAG_QUEST >= "'+mv_par01+'".And. QAG->QAG_QUEST <= "'+mv_par02+'" .And. '
cFiltro+= 'QAG->QAG_RV >= "'+mv_par03+'".And. QAG->QAG_RV <= "'+mv_par04+'" .And. '
cFiltro+= 'QAG->QAG_DOCTO >= "'+mv_par05+'".And. QAG->QAG_DOCTO <= "'+mv_par06+'" .And. '
cFiltro+= 'QAG->QAG_RVDOC >= "'+mv_par07+'".And. QAG->QAG_RVDOC <= "'+mv_par08+'" .And. '
cFiltro+= 'QAG->QAG_MAT >= "'+mv_par10+'".And. QAG->QAG_MAT <= "'+mv_par11+'"'

IndRegua("QAG",cIndex1,QAG->(IndexKey()),,cFiltro,OemToAnsi(STR0006)) // "Selecionando Registros.."

li   := 80
m_Pag:= 1

//         1         2         3         4         5         6         7         8         9        10        11        12        13
//123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//QUEST            REV TITULO
//DOCUMENTO        REV DOCTO

cCabec1:= OemToAnsi(STR0007) // "QUEST            REV TITULO"
cCabec2:= OemToAnsi(STR0009) // "DOCUMENTO        REV"
QAG->(DbSeek(xFilial("QAG")))
SetRegua(QAG->(RecCount())) // Total de Elementos da Regua

While QAG->(!Eof())
	nPonMin:= QAG->QAG_PONTMI
	nPonTot:= 0
	If lEnd
		Li++
		@ PROW()+1,001 PSAY OemToAnsi(STR0008) // "CANCELADO PELO OPERADOR"
		Exit
	EndIf
	If Li > 60 .Or. QAG->QAG_QUEST+QAG->QAG_RV <> cQuest+cRv
		Cabec(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
	EndIf
	@ Li,000 PSay QAG->QAG_QUEST
	@ Li,017 PSay QAG->QAG_RV

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime Titulo do Questionario. 	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTit:= QA_QPLINHA(QAG->QAG_TITULO,59) // Verifica e Quebra a palavra no final da linha
	For nI:= 1 To Len(aTit)
		@ Li,021 PSay aTit[nI]
		Li++
	Next nI
	
	@ Li,000 PSay QAG->QAG_DOCTO
	@ Li,017 PSay QAG->QAG_RVDOC
	Li++
	@ Li,000 PSay __PrtFatLine()
	Li+=2
	nLin:= Li
	If QAH->(DbSeek(QAG->QAG_FILIAL+QAG->QAG_QUEST+QAG->QAG_RV))//Perguntas
		While QAH->(!Eof()) .And. QAH->QAH_FILIAL+QAH->QAH_QUEST+QAH->QAH_RV == QAG->QAG_FILIAL+QAG->QAG_QUEST+QAG->QAG_RV
			If lEnd
				Li++
				@ PROW()+1,001 PSAY OemToAnsi(STR0008) // "CANCELADO PELO OPERADOR"
				Exit
			EndIf
			
			ctexto:= MSMM(QAH->QAH_DESPER,70)
			nLinha:= MlCount(cTexto,70)
			nLin+= nLinha
			
			If nLin > 60
				Cabec(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
				@ Li,000 PSay QAG->QAG_QUEST
				@ Li,017 PSay QAG->QAG_RV

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Imprime Titulo do Questionario. 	   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aTit:= QA_QPLINHA(QAG->QAG_TITULO,59) // Verifica e Quebra a palavra no final da linha
				For nI:= 1 To Len(aTit)
					@ Li,021 PSay aTit[nI]
					Li++
				Next nI

				@ Li,000 PSay QAG->QAG_DOCTO
				@ Li,017 PSay QAG->QAG_RVDOC
				Li++
				@ Li,000 PSay __PrtFatLine()
				Li+=2
				nLin:= nLinha + Li
			EndIf
			@ Li,000 PSay AllTrim(QAH->QAH_SEQPER) + " - "
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Imprime o texto da pergunta 							   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nI:= 1 To nLinha
				aLinha := MEMOLINE(cTexto,70,nI)
				cImpTxt   := ""
				cImpLinha := ""
				
				For nCount := 1 To Len(aLinha)
					cImpTxt := Substr(aLinha,nCount,1)
					
					If AT(cImpTxt,cAcentos)>0
						cImpTxt:=Substr(cAcSubst,AT(cImpTxt,cAcentos),1)
					EndIf
					
					cImpLinha := cImpLinha+cImpTxt
				Next nCount
				
				@li,006 PSAY cImpLinha
				li++
			Next nI
			
			Li++
			nLin++
			If QAI->(DbSeek(QAH->QAH_FILIAL+QAH->QAH_QUEST+QAH->QAH_RV+QAH->QAH_SEQPER))//Respostas
				While QAI->(!Eof()) .And. QAI->QAI_FILIAL+QAI->QAI_QUEST+QAI->QAI_RV+QAI->QAI_SEQPER == QAH->QAH_FILIAL+QAH->QAH_QUEST+QAH->QAH_RV+QAH->QAH_SEQPER
					If lEnd
						Li++
						@ PROW()+1,001 PSAY OemToAnsi(STR0008) // "CANCELADO PELO OPERADOR"
						Exit
					EndIf

					QAXR010Cab(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)

					If mv_par09 == 2 .And. QAI->QAI_PONTO == 0
						QAI->(DbSkip())  //se Ponto = 0 nao imprimo e pulo p/ o proximo
						Loop
					EndIf
					
					@ Li,010 PSay AllTrim(QAI->QAI_SEQRES)+" ) "

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Imprime as Respostas do Questionario. ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aResp:= QA_QPLINHA(QAI->QAI_DESRES,40) // Verifica e Quebra a palavra no final da linha
					For nI:= 1 To Len(aResp)
						QAXR010Cab(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
						@ Li,017 PSay aResp[nI]  
						If lFirst
							@ Li,060 PSay (AllTrim(TitSX3("QAI_PONTO")[1]) +": "+Transf(QAI->QAI_PONTO,"@r 999.99"))
							lFirst := .F.
						Endif
						Li++
						nLin++						
					Next nI				    
				    
			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Imprime a Pontuacao da Resposta Correta      		   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					If mv_par09 == 2
						Li++
						nLin++
						nPonTot:= nPonTot + QAI->QAI_PONTO
						@ Li,150 PSay OemToAnsi(STR0010)+" "+Transf(QAI->QAI_PONTO,"@r 999.99")//"Pontos:"						
						Li++
						nLin++
					EndIf
					
					QAI->(DbSkip())
					lFirst := .T.
				EndDo
			EndIf
			Li++
			nLin++
			QAH->(DbSkip())
		EndDo
		Li++
	EndIf
	cQuest:= QAG->QAG_QUEST
	cRv   := QAG->QAG_RV
	QAG->(DbSkip())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime a Pontuacao Total do Questionario     		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  mv_par09 == 2
		@ Li,000 PSay OemToAnsi(STR0011)+ " " + Right(Str(nPonTot),8)//"Total de Pontos:"
		Li++
		@ Li,000 PSay OemToAnsi(STR0012) + Right(Str(nPonMin),8)//"Pontuacao Minima"
		Li++
	EndIf
EndDo


If Li != 80
	Roda(cbcont,cbtxt,tamanho)
EndIf

RetIndex("QAG")
Set Filter to

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indice de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIndex1 += OrdBagExt()
Delete File &(cIndex1)

Set Device To Screen

If aReturn[5] = 1
	Set Printer TO
	DbCommitAll()
	Ourspool(wnrel)
Endif
MS_FLUSH()

Return .T.
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QAXR010Cab³ Autor ³ Leandro               ³ Data ³ 20/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Imprime o cabecalho do Questionario                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QAXR010Cab							                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QAXR010Cab                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QAXR010Cab(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
Local nI := 0

If nLin > 60
	Cabec(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
	@ Li,000 PSay QAG->QAG_QUEST
	@ Li,017 PSay QAG->QAG_RV
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime Titulo do Questionario. 	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTit:= QA_QPLINHA(QAG->QAG_TITULO,59) // Verifica e Quebra a palavra no final da linha
	For nI:= 1 To Len(aTit)
		@ Li,021 PSay aTit[nI]
		Li++
	Next nI

	@ Li,000 PSay QAG->QAG_DOCTO
	@ Li,017 PSay QAG->QAG_RVDOC
	Li++
	@ Li,000 PSay __PrtFatLine()
	Li+=2
	nLin:= Li
EndIf

Return()
