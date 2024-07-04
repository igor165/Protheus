#INCLUDE  "QDOR020.CH"
#INCLUDE  "Protheus.CH"
#INCLUDE  "Report.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QDOR020   ºAutor  ³Leandro Sabino      º Data ³  13/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio Lista de Treinamentos por Treinando              º±±
±±º          ³ (Versao Relatorio Personalizavel)                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                            
Function QDOR020()
Local oReport

If TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                                ³
	//³ mv_par01	// De  Treinando                                        ³
	//³ mv_par02	// Ate Treinando                                        ³
	//³ mv_par03	// Treinamentos   1- Todos 2- Realizados 3- Pendentes   ³
	//³ mv_par04	// Treinando Real 1- Todos 2- Participou 3- N Participou³
	//³ mv_par05	// De  Filial Treinando                                 ³
	//³ mv_par06	// Ate Filial Treinando                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("QDR020",.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
	QDOR020R3()	// Executa versão anterior do fonte
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef()   ³ Autor ³ Leandro Sabino   ³ Data ³ 13/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montar a secao				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDef()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOR020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local cTitulo:= OemToAnsi(STR0001) //"LISTA DE TREINAMENTOS POR TREINANDO"
Local cDesc1 := OemToAnsi(STR0002) //"Este programa ir  imprimir uma rela‡„o de treinamentos por"
Local cDesc2 := OemToAnsi(STR0003)	//"treinando, relacionando os treinamentos que foram realizados"
Local cDesc3 := OemToAnsi(STR0004) //"de acordo com os parƒmetros definidos pelo usu rio."
Local wnrel  := "QDOR020"
Local cPerg  := "QDR020"
Local oSection0,oSection1 

DEFINE REPORT oReport NAME wnrel TITLE cTitulo PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1+cDesc2+cDesc3)
oReport:SetLandscape(.T.)

DEFINE SECTION oSection0 OF oReport TABLES "QD8","QDA","QDH" TITLE OemToAnsi(STR0025)

DEFINE SECTION oSection1 OF oSection0 TABLES "QD8","QDA","QDH" TITLE OemToAnsi(STR0024)
DEFINE CELL NAME "QD8_NUMERO" OF oSection1 ALIAS "QD8"
DEFINE CELL NAME "QD8_ANO"    OF oSection1 ALIAS "QD8"
DEFINE CELL NAME "QDA_DOCTO"  OF oSection1 ALIAS "QDA" 
DEFINE CELL NAME "QDA_RV" 	  OF oSection1 ALIAS "QDA"
DEFINE CELL NAME "QDH_TITULO" OF oSection1 ALIAS "QDH" AUTO SIZE 
DEFINE CELL NAME "QD8_SELECA" OF oSection1 ALIAS "QD8" TITLE OemToAnsi(STR0021)  SIZE 03 BLOCK {|| IIf(QD8->QD8_SELECA == "S",OemToAnsi(STR0017),OemToAnsi(STR0018))}
DEFINE CELL NAME "QDA_DTFEC"  OF oSection1 ALIAS "QDA" TITLE OemToAnsi(STR0022) 
DEFINE CELL NAME "QDA_HORAI"  OF oSection1 ALIAS "QDA" TITLE OemToAnsi(STR0026) 
DEFINE CELL NAME "QDA_HORAF"  OF oSection1 ALIAS "QDA" TITLE OemToAnsi(STR0027) 
DEFINE CELL NAME "TOT_HORAS"  OF oSection1 ALIAS "QDA" TITLE OemToAnsi(STR0028) 
DEFINE CELL NAME "QD8_HISTOR" OF oSection1 ALIAS "QD8" TITLE OemToAnsi(STR0023) 
	
Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PrintReport   ³ Autor ³ Leandro Sabino   ³ Data ³ 13/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprimir os campos do relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrintReport(ExpO1)  	     	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOR020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                  
Static Function PrintReport(oReport)      
Local oSection0 := oReport:Section(1)
Local oSection1 := oReport:Section(1):Section(1)
Local cFiltro   := " "
Local cIndex1   := CriaTrab(Nil,.F.)
Local cFilCarg  := xFilial("QAC")
Local cFilDep   := xFilial("QAD")
Local cCampos1  := " "
Local cCompara1 := " "
Local lFirst	:= .T.
Local cCargo

MakeAdvplExpr(oReport:uParam)

DbSelectArea("QDA")
DbSetOrder(1)

DbSelectArea("QDH")
DbSetOrder(1)

DbSelectarea("QD8")
DbSetOrder(1)
	
cFiltro:= 'QD8->QD8_FILIAL == "'+xFilial("QD8")+'" .And. '
cFiltro+= 'QD8->QD8_FILMAT >= "'+mv_par05+'" .And. QD8->QD8_FILMAT <= "'+mv_par06+'" .And. '
cFiltro+= 'QD8->QD8_MAT >= "'+mv_par01+'" .And. QD8->QD8_MAT <= "'+mv_par02+'"'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtro para treinamentos (Considera so baixados ou nao)          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par03 == 2
	cFiltro+= ' .And. QD8->QD8_BAIXA == "S"'
ElseIf mv_par03 == 3
	cFiltro+= ' .And. QD8->QD8_BAIXA <> "S"'
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtro para treinandos (Considera so participantes ou nao)       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par03 != 3
	If mv_par04 == 2
		cFiltro+= ' .And. QD8->QD8_SELECA == "S"'	
	ElseIf mv_par04 == 3
		cFiltro+= ' .And. QD8->QD8_SELECA == "N"'	
	EndIf
EndIf

oSection1:SetFilter(cFiltro,"QD8->QD8_FILIAL+QD8->QD8_FILMAT+QD8->QD8_MAT+QD8->QD8_DEPTO+QD8->QD8_CARGO+QD8->QD8_ANO+QD8->QD8_NUMERO")
				            
While QD8->(!Eof())

	cCompara1:= xFilial("QD8") + QD8->QD8_FILMAT+ QD8->QD8_MAT
	cCampos1 := "QD8->QD8_FILIAL+QD8->QD8_FILMAT+QD8->QD8_MAT"
	cDoc1    := " "
	cDoc2    := " "
	If FWModeAccess("QAC") == "E" //!Empty(cFilCarg)      
		cFilCarg:= QD8->QD8_FILMAT
	EndIf
	If FWModeAccess("QAD") == "E" //!Empty(cFilDep)
		cFilDep:= QD8->QD8_FILMAT
	EndIf

	If !Empty(AllTrim(oReport:Section(1):GetAdvplExp("QD8")))
		If !QD8->(&(oReport:Section(1):GetAdvplExp("QD8")))
			QD8->(dbSkip())
			Loop
		Endif
	EndIf

	oSection0:Init()
	
	oReport:SkipLine(1) 
	oReport:ThinLine()
	oReport:PrintText(Upper(OemToAnsi(STR0011))+QA_NUSR(QD8->QD8_FILMAT,QD8->QD8_MAT,.T.),oReport:Row(),025)//"Usu rio: "
	oReport:SkipLine(1)	
	oReport:PrintText(Upper(OemToAnsi(STR0012))+QA_NDEPT(QD8->QD8_DEPTO,.T.,cFilDep),oReport:Row(),025)//"Departamento: " 
	oReport:SkipLine(1)	
	cCargo := Posicione("QAA",1,QD8->QD8_FILMAT+QD8->QD8_MAT,"QAA_CODFUN")
	oReport:PrintText(Upper(OemToAnsi(STR0013))+QA_NFUNC(cCargo,.T.,cFilCarg),oReport:Row(),025)//"Funcao: "
	oReport:SkipLine(1)	
	oReport:PrintText(Upper(OemToAnsi(STR0014))+If(QD8->QD8_BAIXA == "S",OemToAnsi(STR0015),OemToAnsi(STR0016)),oReport:Row(),025)//"Documento: ### // Realizado ### // Pendente "
	oReport:SkipLine(1)	
	oReport:ThinLine()

	oSection0:Finish()
		
	oSection1:Init()

	lFirst	:= .T.
	

	While QD8->(!Eof()) .And. cCompara1 == &(cCampos1)

		If QDA->(DbSeek(QD8->QD8_FILIAL+QD8->QD8_ANO+QD8->QD8_NUMERO))
			If !Empty(AllTrim(oReport:Section(1):GetAdvplExp("QDA")))
				If !QDA->(&(oReport:Section(1):GetAdvplExp("QDA")))
					QD8->(dbSkip())
					Loop
				Endif
			EndIf

			oSection1:Cell("QDA_DOCTO"):SetValue(AllTrim(QDA->QDA_DOCTO))							
			oSection1:Cell("QDA_RV"):SetValue(QDA->QDA_RV)								

			If QDH->(DbSeek(QDA->QDA_FILIAL+QDA->QDA_DOCTO+QDA->QDA_RV))
				If !Empty(AllTrim(oReport:Section(1):GetAdvplExp("QDH")))
					If !QDH->(&(oReport:Section(1):GetAdvplExp("QDH")))
						QD8->(dbSkip())
						Loop
					Endif
				EndIf

				oSection1:Cell("QDH_TITULO"):SetValue(QDH->QDH_TITULO)							
			EndIf
			oSection1:Cell("QDA_DTFEC"):SetValue(QDA->QDA_DTFEC)
			oSection1:Cell("QDA_HORAI"):SetValue(QDA->QDA_HORAI)    			
			oSection1:Cell("QDA_HORAF"):SetValue(QDA->QDA_HORAF)    
			cElapsed :=  SubStr(ELAPTIME(substr(qda->qda_horai,1,2)+ ":" + substr(qda->qda_horai,3,2)+":00",substr(qda->qda_horaf,1,2)+ ":" + substr(qda->qda_horaf,3,2)+":00"),1,5)
			oSection1:Cell("TOT_HORAS"):SetValue(cElapsed)
		Endif
		If lFirst
			oSection0:PrintLine()
			lFirst := .F.
		Endif
		oSection1:PrintLine()
		QD8->(DbSkip())
	EndDo


	oSection1:Finish()
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve as ordens originais do arquivo                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetIndex("QD8")
Set Filter to

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indice de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIndex1 += OrdBagExt()
Delete File &(cIndex1)
	
Return NIL


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QDOR020  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 09/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio Lista de Treinamentos por Treinando              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOR020                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Eduardo S.  ³26/03/02³ META ³ Otimizacao e Melhoria.                   ³±±
±±³Eduardo S   |13/12/02³ ---- ³ Incluido a pergunta 05 e 06 permitindo   ³±±
±±³            ³        ³      ³ filtrar por filial de departamento.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDOR020R3()

Local cTitulo:= OemToAnsi(STR0001) //"LISTA DE TREINAMENTOS POR TREINANDO"
Local cDesc1 := OemToAnsi(STR0002) //"Este programa ir  imprimir uma rela‡„o de treinamentos por"
Local cDesc2 := OemToAnsi(STR0003)	//"treinando, relacionando os treinamentos que foram realizados"
Local cDesc3 := OemToAnsi(STR0004) //"de acordo com os parƒmetros definidos pelo usu rio."
Local cString:= "QD8" 
Local wnrel  := "QDOR020"
Local Tamanho:= "G"

Private cPerg   := "QDR020"
Private aReturn := {STR0005,1,STR0006, 1, 2, 1, "",1} //"Zebrado"###"Administra‡„o"
Private nLastKey:= 0
Private INCLUI  := .F.	// Colocada para utilizar as funcoes

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                ³
//³ mv_par01	// De  Treinando                                        ³
//³ mv_par02	// Ate Treinando                                        ³
//³ mv_par03	// Treinamentos   1- Todos 2- Realizados 3- Pendentes   ³
//³ mv_par04	// Treinando Real 1- Todos 2- Participou 3- N Participou³
//³ mv_par05	// De  Filial Treinando                                 ³
//³ mv_par06	// Ate Filial Treinando                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

wnrel :=AllTrim(SetPrint(cString,wnrel,cPerg,ctitulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho))

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| QDOR020Imp(@lEnd,ctitulo,wnRel,tamanho)},ctitulo)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDOR020Imp³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 09/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia para funcao que faz a impressao do relatorio.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOR020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QDOR020Imp(lEnd,ctitulo,wnRel,tamanho)

Local cCabec1  := " "
Local cCabec2  := " "
Local cbtxt    := SPACE(10)
Local nTipo		:= GetMV("MV_COMP")
Local cbcont   := 0
Local cCampos1 := " "
Local cCompara1:= " "
Local cDoc1    := " "
Local cDoc2    := " "
Local cIndex1  := CriaTrab(Nil,.F.)
Local cFiltro  := " "
Local cKey     := " "
Local cFilCarg := xFilial("QAC")
Local cFilDep  := xFilial("QAD")
Local cCargo   := " "

DbSelectArea("QDA")
DbSetOrder(1)

DbSelectArea("QDH")
DbSetOrder(1)

DbSelectarea("QD8")
DbSetOrder(1)

cFiltro:= 'QD8->QD8_FILIAL == "'+xFilial("QD8")+'" .And. '
cFiltro+= 'QD8->QD8_FILMAT >= "'+mv_par05+'" .And. QD8->QD8_FILMAT <= "'+mv_par06+'" .And. '
cFiltro+= 'QD8->QD8_MAT >= "'+mv_par01+'" .And. QD8->QD8_MAT <= "'+mv_par02+'"'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtro para treinamentos (Considera so baixados ou nao)          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par03 == 2
	cFiltro+= ' .And. QD8->QD8_BAIXA == "S"'
ElseIf mv_par03 == 3
	cFiltro+= ' .And. QD8->QD8_BAIXA <> "S"'
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtro para treinandos (Considera so participantes ou nao)       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par03 != 3
	If mv_par04 == 2
		cFiltro+= ' .And. QD8->QD8_SELECA == "S"'	
	ElseIf mv_par04 == 3
		cFiltro+= ' .And. QD8->QD8_SELECA == "N"'	
	EndIf
EndIf

cKey:= 'QD8->QD8_FILIAL+QD8->QD8_FILMAT+QD8->QD8_MAT+QD8->QD8_DEPTO+QD8->QD8_CARGO+QD8->QD8_ANO+QD8->QD8_NUMERO'
IndRegua("QD8",cIndex1,cKey,,cFiltro,OemToAnsi(STR0007)) //"Selecionando Registros.."

//         1         2         3         4         5         6         7         8         9        10        11        12        13
//123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//NUMERO/ANO DOCUMENTO/REVISAO  TITULO                                                  PARTICIPANTE  DATA       JUSTIFICATIVA
//                                                                                                    REALIZACAO              
cCabec1:= OemToAnsi(STR0008) //"NUMERO/ANO DOCUMENTO/REVISAO  TITULO                                                  PARTICIPANTE  DATA       JUSTIFICATIVA"
cCabec2:= OemToAnsi(STR0009)	//"                                                                                                    REALIZACAO              "

Li       := 80
m_pag    := 1

QD8->(DbSeek(xFilial("QD8")))
SetRegua(RecCount()) // Total de Elementos da Regua

While QD8->(!Eof())
	cCompara1:= xFilial("QD8")+QD8_FILMAT+QD8_MAT
	cCampos1 := "QD8_FILIAL+QD8_FILMAT+QD8_MAT"
	cDoc1    := " "
	cDoc2    := " "
	If FWModeAccess("QAC") == "E" //!Empty(cFilCarg)
		cFilCarg:= QD8->QD8_FILMAT
	EndIf
	If FWModeAccess("QAD") == "E" //!Empty(cFilDep)
		cFilDep:= QD8->QD8_FILMAT
	EndIf
	If lEnd
		Li++
		@ PROW()+1,001 PSAY OemToAnsi(STR0010) // "CANCELADO PELO OPERADOR"
		Exit
	EndIf
	If Li > 58
		Cabec(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
	EndIf

   @ Li,000 PSay Upper(OemToAnsi(STR0011))+QA_NUSR(QD8->QD8_FILMAT,QD8->QD8_MAT,.T.) //"Usu rio: "
	Li++
	@ Li,000 PSay Upper(OemToAnsi(STR0012))+QA_NDEPT(QD8->QD8_DEPTO,.T.,cFilDep) //"Departamento: "
	Li++
	cCargo := Posicione("QAA",1,QD8->QD8_FILMAT+QD8->QD8_MAT,"QAA_CODFUN")
	@ Li,000 PSay Upper(OemToAnsi(STR0013))+QA_NFUNC(cCargo,.T.,cFilCarg) //"Funcao: "
	Li+=2
	@ Li,000 PSay Upper(OemToAnsi(STR0014))+If(QD8->QD8_BAIXA == "S",OemToAnsi(STR0015),OemToAnsi(STR0016)) //"Documento: ### // Realizado ### // Pendente "
	Li++
	@ Li,000 Psay __PrtFatLine()
	Li++
	While QD8->(!Eof()) .And. cCompara1 == &(cCampos1)
		IncRegua()
		If lEnd
			Li++
			@ PROW()+1,001 PSAY OemToAnsi(STR0010) //"CANCELADO PELO OPERADOR"
			Exit
		EndIf
		If Li > 58
			Cabec(cTitulo,cCabec1,cCabec2,wnrel,Tamanho,nTipo)
		EndIf
		@ Li,000 PSay AllTrim(QD8_NUMERO)+"/"+QD8_ANO
		If QDA->(DbSeek(QD8->QD8_FILIAL+QD8->QD8_ANO+QD8->QD8_NUMERO))
			@ Li,010 PSay AllTrim(QDA->QDA_DOCTO)+"/"+QDA->QDA_RV
			If QDH->(DbSeek(QDA->QDA_FILIAL+QDA->QDA_DOCTO+QDA->QDA_RV))
				cDoc1:= Substr(Alltrim(QDH->QDH_TITULO),1,59)
				cDoc2:= Substr(Alltrim(QDH->QDH_TITULO),60)
			EndIf
			If !Empty(cDoc1)
				@ Li,041 PSay cDoc1
			EndIf
			If !Empty(cDoc2)		
				Li++	
				@ Li,041 PSay cDoc2
			EndIf
		    @ Li,103 PSay If(QD8->QD8_SELECA == "S",OemToAnsi(STR0017),OemToAnsi(STR0018))
			@ Li,110 PSay QDA->QDA_DTFEC 
			@ Li,123 PSay SubStr(QDA->QDA_HORAI,1,2)+":"+SubStr(QDA->QDA_HORAI,3,2)
			@ Li,133 PSay SubStr(QDA->QDA_HORAF,1,2)+":"+SubStr(QDA->QDA_HORAF,3,2)
			cElapsed :=  SubStr(ELAPTIME(substr(qda->qda_horai,1,2)+ ":" + substr(qda->qda_horai,3,2)+":00",substr(qda->qda_horaf,1,2)+ ":" + substr(qda->qda_horaf,3,2)+":00"),1,5)
			@ Li,142 PSay cElapsed    			
			
		EndIf
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Imprime o Historico de Justificativa Caso exista³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      @ Li,PCOL()+5 PSay QD8->QD8_HISTOR
		Li++
		QD8->(DbSkip())
	EndDo
	@ Li,000 Psay __PrtThinLine()
	Li+=2
EndDo

If Li <> 80
	Roda(cbcont,cbtxt,tamanho)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve as ordens originais do arquivo                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetIndex("QD8")
Set Filter to

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indice de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIndex1 += OrdBagExt()
Delete File &(cIndex1)

Set Device To Screen

If aReturn[5] = 1
	Set Printer TO 
	dbCommitAll()
	ourspool(wnrel)
Endif
MS_FLUSH()

Return (.T.)