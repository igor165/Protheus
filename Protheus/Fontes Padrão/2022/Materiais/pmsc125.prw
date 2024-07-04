#include "pmsc125.ch"
#include "protheus.ch"
#include "pmsicons.ch"

// indexadores
#define PROJETOS      1
#define TAREFAS       1
#define DATAS         1
#define TOT_DATAS     2

// quantidade empenhada
#define QTD_ALOCADA   1
#define QTD_EMPENHADA 3
#define DATA_NECES    2

#define COD_PROJ      3
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PMSC125  ³ Autor ³ Adriano Ueda          ³ Data ³ 26-09-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de consulta a Sintese de Produtos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC125()
Private cCadastro	:= STR0032 //"Sintese de Produtos do Projeto"
Private aRotina := MenuDef()
If AMIIn(44) .And. !PMSBLKINT()
	dbSelectArea("SB1")
	dbSetOrder(1)
	MarkBrow("SB1","B1_OK",,,,GetMark(,"SB1", "B1_OK"))
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PMSC125View³ Autor ³ Adriano Ueda         ³ Data ³ 26-09-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Monta uma tela de consulta com a sintese dos produtos.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSC125View(cAlias, nReg, nOpcx)
Local dIniGnt
Local aGantt := {}
Local nTsk
Local lRet		:= .T.

Private aConfig

While lRet
	lRet := AuxC125View(@aConfig, @dIniGnt, @aGantt, @nTsk)
End
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AuxC125View³ Autor ³ Adriano Ueda         ³ Data ³ 26-09-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Monta uma tela de consulta com a sintese dos produtos.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AuxC125View(aConfig, dIniGnt, aGantt, nTsk)
Local lRet := .F.

Local aArea		:= GetArea()
Local aAreaSB1 	:= SB1->(GetArea())
Local aAloc 	:= {}

Local nTop      := oMainWnd:nTop+35
Local nLeft     := oMainWnd:nLeft+10
Local nBottom   := oMainWnd:nBottom-12
Local nRight    := oMainWnd:nRight-10
Local lInverte	:= ThisInv()
Local cMarca	:= ThisMark()
Local nX		:= 0
Local lFWGetVersao := .T.
Local aButtons	:= {}

Local oFont
Local oDlg
Local oBtn
Local oBar
Local aGanttTemp

// parametros da consulta
If aConfig	== Nil
	aConfig := {6,.T.,.T.,dDataBase-20,dDataBase+20,"1","1"}
	ParamBox({	{3,STR0004,aConfig[1],{STR0005, STR0006, STR0007, STR0008, STR0009, STR0010},70,,.F.},;  //"Escala de Tempo"###"Diario"###"Semanal"###"Mensal"###"Mensal (Zoom 30%)"###"Bimestral"###"Melhor escala"
				{4,STR0011,aConfig[2],STR0012,40,,.F.},;  //"Exibir detalhes :"###"Codigo"
				{4,"",aConfig[3],STR0013,40,,.F.},;  //"Descricao"
				{1,STR0015,aConfig[4],"","","","",45,.T.},;  //"Data Inicial"
				{1,STR0016,aConfig[5],"","","","",45,.T.},;  //"Data Final"
				{2,STR0017,aConfig[6], {STR0033, STR0034, STR0035},90,,.T.},; //"Considerar"###"1=Alocacoes"###"2=Empenhos"###"3=Alocacoes/Empenhos"
				{2,STR0036,aConfig[7],{STR0037, STR0038},60,,.T.}},STR0021,aConfig) //"Quebrar por"###"1=Projeto"###"2=Tarefa"###"Parametros"
				//{3,"Considerar",aConfig[6],{"Todas as tarefas","Tarefas finalizadas","Tarefas a executar"},60,,.F.},;				
EndIf

RegToMemory("AFA",.T.)
RegToMemory("AFB",.T.)

aGantt	:= {}
aGanttTemp := {}

dbSelectArea("SB1") 
dbSetOrder(1)
dbSeek(xFilial("SB1"))

While !Eof() .And. B1_FILIAL == xFilial("SB1")
	aAloc := {}
	aGanttTemp := {}
	
	If (SB1->B1_OK == cMarca .And. !lInverte) .Or. (SB1->B1_OK <> cMarca .And. lInverte)	
		If aConfig[6] == "3" .Or. aConfig[6] == "1"
			// recuperar a alocacao do produto (AFA)
			PrdAlocAFA(@aAloc, SB1->B1_COD, aConfig[4], "00:00", aConfig[5], "24:00", aConfig[6])
		EndIf

		If aConfig[6] == "3" .Or. aConfig[6] == "2"		
			// recuperar a alocacao do produto (AFJ)
			PrdAlocAFJ(@aAloc, SB1->B1_COD, aConfig[4], "00:00", aConfig[5], "24:00", aConfig[6])
		EndIf

		// montar o Gantt para o produto
		MntGanttProd(SB1->B1_COD, @aGantt, aAloc, aConfig[6], aConfig[7])		
		
		// insere um separador
		aAdd(aGantt, {{"", ""}, {}, CLR_HBLUE,})		
	EndIf
	dbSelectArea("SB1") 
	dbSkip()
End

If Empty(aGantt)
	Aviso(STR0023,STR0039,{STR0025},2)  //"Atencao!"###"Nao existem projetos alocados para este produto nesta data selecionada. Verifique o recurso e o periodo selecionado."###"Fechar"
Else
	DEFINE FONT oFont NAME "Arial" SIZE 0, -10
	DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight
	oDlg:lMaximized := .T.	

	If !lFWGetVersao .or. GetVersao(.F.) == "P10"

		DEFINE BUTTONBAR oBar SIZE 25,35 3D TOP OF oDlg
	
		@ 1000,38 BUTTON "OK" SIZE 35,12 ACTION {|| Nil} OF oDlg PIXEL

		// opcoes
		oBtn := TBtnBmp():NewBar(BMP_OPCOES, BMP_OPCOES, , , TIP_OPCOES, {|| If(PmsCfgProd(@oDlg,aConfig,@dIniGnt,aGantt),(oDlg:End(),lRet := .T.),Nil) },.T.,oBar,,, TIP_OPCOES)
		oBtn:cTitle := TOOL_OPCOES

		// retroceder calendario
		oBtn := TBtnBmp():NewBar(BMP_RETROCEDER_CAL, BMP_RETROCEDER_CAL,,, TIP_RETROCEDER_CAL, {|| (PmsPrvGnt(cVersao,@oDlg,aConfig,@dIniGnt,aGantt,@nTsk),oDlg:End(),lRet := .T.) },.T.,oBar,,, TIP_RETROCEDER_CAL)
		oBtn:cTitle := TOOL_RETROCEDER_CAL

		// avancar calendario
		oBtn := TBtnBmp():NewBar(BMP_AVANCAR_CAL, BMP_AVANCAR_CAL,,, TIP_AVANCAR_CAL, {|| (PmsNxtGnt(cVersao,@oDlg,aConfig,@dIniGnt,aGantt,@nTsk),oDlg:End(),lRet := .T.) },.T.,oBar,,, TIP_AVANCAR_CAL)
		oBtn:cTitle := TOOL_AVANCAR_CAL

		// imprimir		
		oBtn := TBtnBmp():NewBar(BMP_IMPRIMIR, BMP_IMPRIMIR,,, TIP_IMPRIMIR, {|| PmsImpGantt( cCadastro ,aGantt ,aConfig ,dIniGnt , ,{{STR0012,30},{STR0031,105}} )}, .T.,oBar,,, TOOL_IMPRIMIR)
		oBtn:cTitle := TOOL_IMPRIMIR

		// sair		
		oBtn := TBtnBmp():NewBar(BMP_SAIR, BMP_SAIR,,, TIP_SAIR, {|| oDlg:End() },.T.,oBar,,, TOOL_SAIR)
		oBtn:cTitle := TOOL_SAIR

	Else	
		AADD(aButtons, {BMP_OPCOES			, {|| If(PmsCfgProd(@oDlg,aConfig,@dIniGnt,aGantt),(oDlg:End(),lRet := .T.),Nil) }		,TIP_OPCOES })
		AADD(aButtons, {BMP_RETROCEDER_CAL	, {|| (PmsPrvGnt(cVersao,@oDlg,aConfig,@dIniGnt,aGantt,@nTsk),oDlg:End(),lRet := .T.) }	,TIP_RETROCEDER_CAL})
		AADD(aButtons, {BMP_AVANCAR_CAL		, {|| (PmsNxtGnt(cVersao,@oDlg,aConfig,@dIniGnt,aGantt,@nTsk),oDlg:End(),lRet := .T.) }	,TIP_AVANCAR_CAL })
		AADD(aButtons, {BMP_IMPRIMIR		, {|| PmsImpGantt( cCadastro ,aGantt ,aConfig ,dIniGnt , ,{{STR0012,30},{STR0031,105}} )}	,TOOL_IMPRIMIR})
		EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,aButtons,,,,,.F.,.F.)
	Endif
	
	PmsGantt(aGantt,aConfig,@dIniGnt,,oDlg,{14,1,(nBottom/2)-40,(nRight/2)-4},{{STR0012,55},{STR0031,105}},@nTsk)  //"Codigo"###"Nome"

	ACTIVATE MSDIALOG oDlg
EndIf


RestArea(aAreaSB1)
RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MntGanttPr³ Autor ³ Adriano Ueda          ³ Data ³ 24-09-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta um array de Gantt a partir da alocacao de um produto    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MntGanttProd(cProduto, aGantt, aAloc, cEmpenhos, cExibirTrf)
	Local cDescProd := Posicione("SB1", 1, xFilial("SB1")+cProduto, "B1_DESC")

	// data e hora inicial
	Local dIni
	Local cHIni
	
	// data e hora final
	Local dFim
	Local cHFim

	// array auxiliar	
	Local aGanttAux  := {}
	Local aLinhaDesc := {}

	// indexadores	
	Local nData    := 0
	Local nProjeto := 0
	Local nTarefa  := 0
	
	// string contendo codeblock
	// do evento Click no Gantt
	Local cView := ""

	// inclui o codigo e a descricao do produto corrente	
	aAdd(aGantt, {{cProduto, cDescProd}, {}, CLR_BLUE,})
  
	For nProjeto := 1 To Len(aAloc)
		//////////////////////////////////		
		// Gantt do projeto  
		//////////////////////////////////
	
		// inicializa arrays auxiliares
		aGanttAux  := {}
		aLinhaDesc := {}

		// quebrar por projeto?		
	 	For nData := 1 To Len(aAloc[nProjeto][TOT_DATAS])
			// pega a data de inicio e a data final de alocacao
			dIni	:= aAloc[nProjeto][TOT_DATAS][nData][DATA_NECES]
			cHIni	:= "00:00"
			dFim	:= aAloc[nProjeto][TOT_DATAS][nData][DATA_NECES] + 1
			cHFim	:= "00:00"

			cView	:= "PmsDispBox({	{'"+ STR0040 + "','"+cDescProd+"'},"+; //"Produto"
								"	{'"+ STR0051 + "','"+ AllTrim(Str(aAloc[nProjeto][TOT_DATAS][nData][QTD_ALOCADA])) +"'},"+; //"Qtd. Tot. aloc."
								"	{'"+ STR0052 +"','"+ AllTrim(Str(aAloc[nProjeto][TOT_DATAS][nData][QTD_EMPENHADA])) +"'},"+;								 //"Qtd. Tot. empen."
								"	{'"+ STR0043 +"','"+DToC(aAloc[nProjeto][TOT_DATAS][nData][DATA_NECES])+"'},"+; //"Data neces."
								"	{'"+ STR0044 +"','"+aAloc[nProjeto][3]+"'},"+; //"Cod. Projeto"
								"	{'"+ STR0045 +"','"+aAloc[nProjeto][4]+"'}"+; //"Desc. Projeto"
								"	},2,'"+ STR0046 +"',{40,120},,1)" //"Detalhes do produto alocado e empenhado"

			If cEmpenhos == "1"
				aAdd(aGanttAux, {dIni, cHIni, dFim, cHFim, Str(aAloc[nProjeto][TOT_DATAS][nData][QTD_ALOCADA]), RGB(92, 92, 92), cView, 2, CLR_BLACK})
			EndIf
			
			If cEmpenhos == "2"
				aAdd(aGanttAux, {dIni, cHIni, dFim, cHFim, Str(aAloc[nProjeto][TOT_DATAS][nData][QTD_EMPENHADA]), RGB(92, 92, 92), cView, 2, CLR_BLACK})
			EndIf

			If cEmpenhos == "3"
				aAdd(aGanttAux, {dIni, cHIni, dFim, cHFim, Str(aAloc[nProjeto][TOT_DATAS][nData][QTD_ALOCADA]+aAloc[nProjeto][TOT_DATAS][nData][QTD_EMPENHADA]), RGB(92, 92, 92), cView, 2, CLR_BLACK})
			EndIf
		Next                                         

		// adiciona a descricao do projeto
		aAdd(aLinhaDesc, Space(4) + aAloc[nProjeto][3] + " - " + aAloc[nProjeto][4])
		aAdd(aLinhaDesc, "")
		
		// adiciona o projeto ao Gantt
		aAdd(aGantt, {aLinhaDesc, aGanttAux, CLR_BLUE,})

		// quebrar por tarefa?
		If cExibirTrf == "2"
			For nTarefa := 1 To Len(aAloc[nProjeto][TAREFAS])
				//////////////////////////////////		
				// Gantt do produto alocado
				//////////////////////////////////
					
				// adiciona a linha das tarefas alocadas
				If cEmpenhos == "3" .Or. cEmpenhos == "1"
				
					// reinicializa arrays auxiliares
					aGanttAux := {}
					aLinhaDesc := {}
				
					For nData := 1 To Len(aAloc[nProjeto][TAREFAS][nTarefa][DATAS])
						// pega a data de inicio e a data final de alocacao
						dIni	:= aAloc[nProjeto][TAREFAS][nTarefa][DATAS][nData][DATA_NECES]
						cHIni	:= "00:00"
						dFim	:= aAloc[nProjeto][TAREFAS][nTarefa][DATAS][nData][DATA_NECES]+1
						cHFim	:= "00:00"

						cView	:= "PmsDispBox({	{'" + STR0040 + "','"+cDescProd+"'},"+; //"Produto"
											"	{'" + STR0041 + "','"+ AllTrim(Str(aAloc[nProjeto][TAREFAS][nTarefa][DATAS][nData][QTD_ALOCADA])) +"'},"+; //"Qtd. alocada"
											"	{'" + STR0043 + "','"+DToC(aAloc[nProjeto][TOT_DATAS][nData][DATA_NECES])+"'},"+; //"Data neces."
											"	{'" + STR0044 + "','"+aAloc[nProjeto][COD_PROJ]+"'},"+; //"Cod. Projeto"
											"	{'" + STR0045 + "','"+aAloc[nProjeto][4]+"'},"+; //"Desc. Projeto"
											"	{'" + STR0047 + "','"+ AllTrim(aAloc[nProjeto][TAREFAS][nTarefa][2]) + "'},"+; //"Cod. Tarefa"
											"	{'" + STR0048 + "','"+ AllTrim(aAloc[nProjeto][TAREFAS][nTarefa][3]) + "'}"+; //"Desc. Tarefa"
											"	},2,'" + STR0049 + "',{40,120},,1)" //"Detalhes do produto alocado"
						
						aAdd(aGanttAux,;
							{dIni,;
							cHIni,;
							dFim,;
							cHFim,;
							AllTrim(Str(aAloc[nProjeto][TAREFAS][nTarefa][DATAS][nData][QTD_ALOCADA])),;
							CLR_BLUE,;
							cView,;
							2,;
							CLR_BLACK})
					Next
	        
					// adiciona a descricao da tarefa
					aAdd(aLinhaDesc, Space(8) + aAloc[nProjeto][TAREFAS][nTarefa][2] + " - " + aAloc[nProjeto][TAREFAS][nTarefa][3])
					aAdd(aLinhaDesc, "")
				  
					// adiciona a tarefa ao Gantt
					aAdd(aGantt, {aLinhaDesc, aGanttAux, CLR_BLUE,})
				EndIf

				//////////////////////////////////		
				// Gantt do produto empenhado
				//////////////////////////////////

				// adiciona a linha das tarefas empenhadas
				If cEmpenhos == "3" .Or. cEmpenhos == "2"
				
					// reinicializa arrays auxiliares				
					aGanttAux := {}
					aLinhaDesc := {}
				
					For nData := 1 To Len(aAloc[nProjeto][TAREFAS][nTarefa][DATAS])
						// pega a data de inicio e a data final de alocacao
						dIni	:= aAloc[nProjeto][TAREFAS][nTarefa][DATAS][nData][DATA_NECES]
						cHIni	:= "00:00"
						dFim	:= aAloc[nProjeto][TAREFAS][nTarefa][DATAS][nData][DATA_NECES]+1
						cHFim	:= "00:00"

						cView	:= "PmsDispBox({	{'" + STR0040 + "','"+cDescProd+"'},"+; //"Produto"
											"	{'" + STR0042 + "','"+ AllTrim(Str(aAloc[nProjeto][TAREFAS][nTarefa][DATAS][nData][QTD_EMPENHADA])) +"'},"+;								 //"Qtd. empen."
											"	{'" + STR0043 + "','"+DToC(aAloc[nProjeto][TOT_DATAS][nData][DATA_NECES])+"'},"+; //"Data neces."
											"	{'" + STR0044 + "','"+aAloc[nProjeto][3]+"'},"+; //"Cod. Projeto"
											"	{'" + STR0045 + "','"+aAloc[nProjeto][4]+"'},"+; //"Desc. Projeto"
											"	{'" + STR0047 + "','"+ AllTrim(aAloc[nProjeto][TAREFAS][nTarefa][2]) + "'},"+; //"Cod. Tarefa"
											"	{'" + STR0048 + "','"+ AllTrim(aAloc[nProjeto][TAREFAS][nTarefa][3]) + "'}"+; //"Desc. Tarefa"
											"	},2,'" + STR0050 + "',{40,120},,1)" //"Detalhes do produto empenhado"
						
						aAdd(aGanttAux,;
							{dIni,;
							cHIni,;
							dFim,;
							cHFim,;
							AllTrim(Str(aAloc[nProjeto][TAREFAS][nTarefa][DATAS][nData][QTD_EMPENHADA])),;
							CLR_GREEN,;
							cView,;
							2,;
							CLR_BLACK})
					Next
	     	  
					// adiciona a descricao da tarefa
					aAdd(aLinhaDesc, "")
					aAdd(aLinhaDesc, "")
				  
					// adiciona a tarefa ao Gantt
					aAdd(aGantt, {aLinhaDesc, aGanttAux, CLR_GREEN,})
				EndIf
			Next	
		EndIf
	Next
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrdAlocAFA³ Autor ³ Adriano Ueda          ³ Data ³ 24-09-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Recupera a alocacao de um produto a partir do AFA             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±                     .
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PrdAlocAFA(aRet, cProduto, dIni, cHIni, dFim, cHFim, nFilter)
Local aArea		:= GetArea()
Local aAreaAFA	:= AFA->(GetArea())

Local aData    := {}
Local aTarefa  := {}
Local aProjeto := {}

Local nData := 0

dbSelectArea("AFA")
dbSetOrder(7)
dbSeek(xFilial()+cProduto)
While !Eof() .And. AFA->AFA_FILIAL+AFA->AFA_PRODUT == xFilial()+cProduto
	// se o data de necessidade do produto
	// estiver entre o intervalo
	If AFA->AFA_DATPRF < dIni .Or. AFA->AFA_DATPRF > dFim
		AFA->(dbSkip())
		Loop
	EndIf		

	aData    := {}
	aTarefa  := {}
	aProjeto := {}

	If AFA->AFA_REVISA == PmsAF8Ver(AFA->AFA_PROJET)

		// dados da alocacao
		aAdd(aData, AFA->AFA_QUANT)   // quantidade alocada
		aAdd(aData, AFA->AFA_DATPRF)  // data de alocacao/empenho
		aAdd(aData, 0)                // quantidade empenhada
		
		// dados da tarefa
		aAdd(aTarefa, {aData})
		aAdd(aTarefa, AFA->AFA_TAREFA)
		aAdd(aTarefa, Posicione("AF9", 1, xFilial("AFA")+AFA->AFA_PROJET+AFA->AFA_REVISA+AFA->AFA_TAREFA,"AF9_DESCRI")) 
   
		// dados do projeto
		aAdd(aProjeto, {aTarefa})
		aAdd(aProjeto, {})
		aAdd(aProjeto, AFA->AFA_PROJET)
		aAdd(aProjeto, Posicione("AF8", 1, xFilial("AF8")+AFA->AFA_PROJET,"AF8_DESCRI"))		
		aAdd(aProjeto, AFA->AFA_QUANT)
    
    // pesquisa se produto esta em algum projeto
		nProjeto := aScan(aRet, {|x| x[3]==AFA->AFA_PROJET})

		// produto esta em algum projeto?
		If nProjeto == 0
			// adicionar o projeto
			aAdd(aRet, aClone(aProjeto))
			nProjeto := Len(aRet)
		Else
			// pesquisa em qual tarefa o produto esta alocado
			nTarefa := aScan(aRet[nProjeto][TAREFAS], {|x| x[2]==AFA->AFA_TAREFA})
			
			// produto esta alocado em alguma tarefa
			If nTarefa == 0
				// adicionar a tarefa
				aAdd(aRet[nProjeto][TAREFAS], aClone(aTarefa))
			Else
				// adicionar a data de necessidade a tarefa
			  nData := aScan(aRet[nProjeto][TAREFAS][nTarefa][DATAS], {|x| x[2]==AFA->AFA_DATPRF})
			  
			  If nData == 0
					// adicionar a data de necessidade a tarefa
				  aAdd(aRet[nProjeto][TAREFAS][nTarefa][DATAS], aClone(aData))
				Else
					// soma a quantidade do produto nesta data
					aRet[nProjeto][TAREFAS][nTarefa][DATAS][nData][QTD_ALOCADA] += aData[QTD_ALOCADA]
				EndIf
			EndIf
		EndIf
		
		// caso o produto ja esteja alocado em alguma outra tarefa
		// neste mesmo projeto, somar a quantidade alocada
		nData := aScan(aRet[nProjeto][TOT_DATAS], {|x| x[2]==AFA->AFA_DATPRF})

		// nesta data ja o produto ja esta alocado em alguma tarefa?		
		If nData==0
			// adicionar nova data de necessidade
			aAdd(aRet[nProjeto][TOT_DATAS], aClone(aData))
		Else
			// adicionar a quantidade a data de necessidade
			// totalizando a quantidade necessario para o projeto
			// na data de necessidade
			aRet[nProjeto][2][nData][QTD_ALOCADA] += aData[QTD_ALOCADA]
		EndIf
	EndIf
	dbSelectArea("AFA")
	dbSkip()
End

RestArea(aAreaAFA)
RestArea(aArea)
Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrdAlocAFJ³ Autor ³ Adriano Ueda          ³ Data ³ 24-09-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Recupera a alocacao de um produto a partir do AFJ (empenhos)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PrdAlocAFJ(aRet, cProduto, dIni, cHIni, dFim, cHFim, nFilter)
Local aArea		:= GetArea()
Local aAreaAFJ	:= AFJ->(GetArea())

Local aData    := {}
Local aTarefa  := {}
Local aProjeto := {}

Local nData := 0

dbSelectArea("AFJ")
dbSetOrder(2)
dbSeek(xFilial()+cProduto)
While !Eof() .And. AFJ->AFJ_FILIAL+AFJ->AFJ_COD == xFilial()+cProduto
	//Se houver estorno de empenho (empenho zerado) no projeto
	//nao sera processado o calculo, seguindo para o proximo registro
		If AFJ->AFJ_EMPEST > 0 .Or. AFJ->AFJ_EMPEST2 > 0	
			AFJ->(dbSkip())
			Loop
		EndIf				

	// se o data de necessidade do produto
	// estiver entre o intervalo
	If AFJ->AFJ_DATA < dIni .Or. AFJ->AFJ_DATA > dFim
		AFJ->(dbSkip())
		Loop
	EndIf		

	aData    := {}
	aTarefa  := {}
	aProjeto := {}

	// dados da alocacao
	aAdd(aData, 0)
	aAdd(aData, AFJ->AFJ_DATA)
	aAdd(aData, AFJ->AFJ_QEMP)
	
	// dados da tarefa
	aAdd(aTarefa, {aData})
	aAdd(aTarefa, AFJ->AFJ_TAREFA)
	aAdd(aTarefa, Posicione("AF9", 1, xFilial("AFJ")+AFJ->AFJ_PROJET+PmsAF8Ver(AFJ->AFJ_PROJET)+AFJ->AFJ_TAREFA,"AF9_DESCRI")) 
   
	// dados do projeto
	aAdd(aProjeto, {aTarefa})
	aAdd(aProjeto, {})
	aAdd(aProjeto, AFJ->AFJ_PROJET)
	aAdd(aProjeto, Posicione("AF8", 1, xFilial("AF8")+AFJ->AFJ_PROJET,"AF8_DESCRI"))		
	aAdd(aProjeto, AFJ->AFJ_QEMP)
    
	// pesquisa se produto esta em algum projeto
	nProjeto := aScan(aRet, {|x| x[3]==AFJ->AFJ_PROJET})

	// produto esta em algum projeto?
	If nProjeto == 0
		// adicionar o projeto
		aAdd(aRet, aClone(aProjeto))
		nProjeto := Len(aRet)
	Else
		// pesquisa em qual tarefa o produto esta alocado
		nTarefa := aScan(aRet[nProjeto][TAREFAS], {|x| x[2]==AFJ->AFJ_TAREFA})
			
		// produto esta alocado em alguma tarefa
		If nTarefa == 0
			// adicionar a tarefa
			aAdd(aRet[nProjeto][TAREFAS], aClone(aTarefa))
		Else
			// adicionar a data de necessidade a tarefa
		  nData := aScan(aRet[nProjeto][TAREFAS][nTarefa][DATAS], {|x| x[2]==AFA->AFA_DATPRF})
		  
		  // produto ja esta alocado nesta data
		  If nData == 0
				// adicionar a data de necessidade a tarefa
			  aAdd(aRet[nProjeto][TAREFAS][nTarefa][DATAS], aClone(aData))
			Else
				// soma a quantidade do produto nesta data
				aRet[nProjeto][TAREFAS][nTarefa][DATAS][nData][QTD_EMPENHADA] += aData[QTD_EMPENHADA]
			EndIf
		EndIf
	EndIf
		
	// caso o produto ja esteja alocado em alguma outra tarefa
	// neste mesmo projeto, somar a quantidade alocada
	nData := aScan(aRet[nProjeto][2], {|x| x[2]==AFJ_DATA})

	// nesta data ja o produto ja esta alocado em alguma tarefa?		
	If nData==0
		// adicionar nova data de necessidade
		aAdd(aRet[nProjeto][TOT_DATAS], aClone(aData))
	Else
		// adicionar a quantidade a data de necessidade
		// totalizando a quantidade necessario para o projeto
		// na data de necessidade
		aRet[nProjeto][TOT_DATAS][nData][QTD_EMPENHADA] += aData[QTD_EMPENHADA]
	EndIf
	dbSelectArea("AFJ")
	dbSkip()
End

RestArea(aAreaAFJ)
RestArea(aArea)
Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSCfgProd³ Autor ³ Adriano Ueda          ³ Data ³ 29-09-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exibe a caixa de configuracao do grafico de Gantt             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PMSCfgProd()
	// parametros da consulta
	Return ParamBox({	{3, STR0004, aConfig[1],{STR0005, STR0006, STR0007, STR0008, STR0009, STR0010},70,,.F.},;  //"Escala de Tempo"###"Diario"###"Semanal"###"Mensal"###"Mensal (Zoom 30%)"###"Bimestral"###"Melhor escala"
				{4, STR0011, aConfig[2],STR0012,40,,.F.},;  //"Exibir detalhes :"###"Codigo"
				{4, "",aConfig[3], STR0013,40,,.F.},;  //"Descricao"
				{1, STR0015, aConfig[4],"","","","",45,.T.},;  //"Data Inicial"
				{1, STR0016, aConfig[5],"","","","",45,.T.},;  //"Data Final"
				{2, STR0017, aConfig[6], {STR0033, STR0034, STR0035},90,,.T.},; //"Considerar"###"1=Alocacoes"###"2=Empenhos"###"3=Alocacoes/Empenhos"
				{2, STR0036, aConfig[7],{STR0037, STR0038},60,,.T.}},STR0021,aConfig) //"Quebrar por"###"1=Projeto"###"2=Tarefa"###"Parametros"
				//{3,"Considerar",aConfig[6],{"Todas as tarefas","Tarefas finalizadas","Tarefas a executar"},60,,.F.},;
Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³01/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002, "AxPesqui"  , 0 , 1},;  //"Pesquisar"
							{ STR0003, "PMSC125View", 0 , 2 }} //"Consultar"
Return(aRotina)
