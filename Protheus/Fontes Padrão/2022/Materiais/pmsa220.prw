#include "pmsa220.ch"
#include "Protheus.ch"
#include "pmsicons.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA220  ³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de gerenciamento da execucao do projeto.            ³±±
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
Function PMSA220()
PRIVATE cCadastro	:= STR0001 //"Gerenciamento da Execucao"
Private aCores	:= PmsAF8Color()
Private aRotina 	:= MenuDef()
PRIVATE lCallPrj 	:= .T.
Private aMemos	:= {}

Set Key VK_F12 To FAtiva()

If AMIIn(44) .And. !PMSBLKINT()
	mBrowse(6,1,22,75,"AF8",,,,,,aCores)
EndIf

Set Key VK_F12 To

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS220Leg³ Autor ³  Fabio Rogerio Pereira ³ Data ³ 19-03-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Exibicao de Legendas                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA220, SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS220Leg(cAlias,nReg,nOpcx)
Local aLegenda:= {}
Local i       := 0

If ExistBlock("PMA220LEG")
	aLegenda := ExecBlock("PMA220LEG", .T., .T., {aCores})
Else
	For i:= 1 To Len(aCores)
		Aadd(aLegenda,{aCores[i,2],aCores[i,3]})
	Next i

	aLegenda:= aSort(aLegenda,,,{|x,y| x[1] < y[1]})
EndIf

BrwLegenda(cCadastro,STR0080,aLegenda) //"Legenda"

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS220Dlg³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Atualizacao/Visualizacao das tarefas do projeto.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS220Dlg(cAlias,nReg,nOpcx)
Local l220Inclui	:= .F.
Local l220Visual	:= .F.
Local l220Altera	:= .F.
Local l220Exclui	:= .F.
Local oMenu
Local oTree
Local oDlg
Local cArquivo		:= CriaTrab(,.F.)
Local aConfig		:= {1, PMS_MIN_DATE, PMS_MAX_DATE, Space(TamSX3("AE8_RECURS")[1])}

// variaveis para posicionamento do popup menu
Local nScreVal1 := 775 
Local nScreVal2 := 23

PRIVATE _cProjCod := AF8->AF8_PROJET    //variaveis utilizadas no x3_relacao funcao pmsCpoInic()
PRIVATE cRevisa	:= AF8->AF8_REVISA    //variaveis utilizadas Tb no x3_relacao funcao pmsCpoInic()
PRIVATE _cTarefa  := ""                //variaveis utilizadas no x3_relacao funcao pmsCpoInic()

PRIVATE cCmpPLN
PRIVATE cArqPLN
PRIVATE cPLNVer		:= ''
PRIVATE cPLNDescri	:= ''
PRIVATE cPLNSenha	:= ''
PRIVATE lSenha		:= .F.
PRIVATE nFreeze		:= 0
PRIVATE nIndent		:= PMS_SHEET_INDENT

If cPaisLoc == 'RUS'
	//Set popup menu location using the screen resolution
	nScreVal1 := RU99XFUN15()[1] // GetRusPopupMenuPos
	nScreVal2 := RU99XFUN15()[2] // GetRusPopupMenuPos
EndIf

Pergunte("PMA200",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case aRotina[nOpcx][4] == 2 .and. nOpcx == 3
		l220Visual := .T.
	Case aRotina[nOpcx][4] == 3
		l220Inclui	:= .T.
	Case aRotina[nOpcx][4] == 2 .and. nOpcx == 2
		l220Altera	:= .T.
	Case aRotina[nOpcx][4] == 5
		l220Exclui	:= .T.
		l220Visual	:= .T.
EndCase

MENU oMenu3 POPUP
	MENUITEM STR0082 ACTION PmsDlgAF8Gnt(cRevisa,aConfig,@oDlg,@oTree,cArquivo) //"Grafico de Gantt..."
	MENUITEM STR0083 ACTION PmsDlgAF8Rec(cRevisa,@oTree,cArquivo) //"Grafico de Alocacao dos Recursos..."
EndMenu
MENU oMenu POPUP
	MENUITEM STR0008 Action PMS220CP(@oTree,l220Visual,cArquivo) //"Geren. Contrato de Parceria"
	MENUITEM STR0009 Action PMS220SC(@oTree,l220Visual,cArquivo) //"Geren. Solicitacao de Compras"
	MENUITEM STR0010 Action PMS220SA(@oTree,l220Visual,cArquivo) //"Geren. Solicitacao ao Almox."
	MENUITEM STR0011 Action PMS220OP(@oTree,l220Visual,cArquivo) //"Geren. Ordens de Producao"
	MENUITEM STR0012 Action PMS220EM(@oTree,l220Visual,cArquivo) //"Geren. Empenhos do Projeto"
ENDMENU

If GetVersao(.F.) == "P10"

	If mv_par01 == 1

		// modo arvore
		aMenu := {;
		         {TIP_PROJ_INFO     ,{||PmsPrjInf()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
		         {TIP_FILTRO        ,{||If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil)}, BMP_FILTRO, TOOL_FILTRO},;
		         {TIP_PROJ_CONSULTAS,{||oMenu3:Activate(75,45,oDlg) }, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},;
		         {TIP_PROJ_EXECUCAO ,{||A220CtrMenu(@oMenu,oTree,l220Visual,cArquivo),oMenu:Activate(105, 45,oDlg) }, BMP_PROJ_EXECUCAO, TOOL_PROJ_EXECUCAO}}
	Else

		// modo planilha
		aMenu := {;
		         {TIP_PROJ_INFO     ,{||PmsPrjInf()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
		         {TIP_COLUNAS       ,{||PMC200Cfg("",0,0),oDlg:End()}, BMP_COLUNAS, TOOL_COLUNAS},;
		         {TIP_FILTRO        ,{||If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil)}, BMP_FILTRO, TOOL_FILTRO},;
		         {TIP_PROJ_CONSULTAS,{||oMenu3:Activate(105,45,oDlg) }, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},;
		         {TIP_PROJ_EXECUCAO ,{||A220CtrMenu(@oMenu,oTree,l220Visual,cArquivo),oMenu:Activate(135, 45,oDlg) }, BMP_PROJ_EXECUCAO, TOOL_PROJ_EXECUCAO}}
	EndIf

Else
	//Acoes relacionadas

	If mv_par01 == 1

		// modo arvore
		aMenu := {;
		         {TIP_PROJ_INFO     ,{||PmsPrjInf()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
		         {TIP_FILTRO        ,{||If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil)}, BMP_FILTRO, TOOL_FILTRO},;
		         {TIP_PROJ_CONSULTAS,{||oMenu3:Activate(nScreVal1, nScreVal2,oDlg) }, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},;
		         {TIP_PROJ_EXECUCAO ,{||A220CtrMenu(@oMenu,oTree,l220Visual,cArquivo),oMenu:Activate(nScreVal1, nScreVal2, oDlg) }, BMP_PROJ_EXECUCAO, TOOL_PROJ_EXECUCAO}}
	Else

		// modo planilha
		aMenu := {;
		         {TIP_PROJ_INFO     ,{||PmsPrjInf()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
		         {TIP_COLUNAS       ,{||PMC200Cfg("",0,0),oDlg:End()}, BMP_COLUNAS, TOOL_COLUNAS},;
		         {TIP_FILTRO        ,{||If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil)}, BMP_FILTRO, TOOL_FILTRO},;
		         {TIP_PROJ_CONSULTAS,{||oMenu3:Activate(nScreVal1, nScreVal2, oDlg) }, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},;
		         {TIP_PROJ_EXECUCAO ,{||A220CtrMenu(@oMenu,oTree,l220Visual,cArquivo),oMenu:Activate(nScreVal1, nScreVal2, oDlg) }, BMP_PROJ_EXECUCAO, TOOL_PROJ_EXECUCAO}}
	EndIf

Endif

If mv_par01 == 2
	aCampos := {{"AF9_TAREFA","AFC_EDT",8,,,.F.,"",},{"AF9_DESCRI","AFC_DESCRI",55,,,.F.,"",150}}
	A200Opn(@aCampos,"\PROFILE\PMSA220","MV_PMSPLN5","MV_PMSPLN6")
	PmsPlanAF8(cCadastro,AF8->AF8_REVISA,aCampos,@cArquivo,,,,aMenu,@oDlg,,,aConfig,,nIndent)
Else
	PmsDlgAF8(cCadastro,@oMenu,AF8->AF8_REVISA,@oTree,,,,,aMenu,@oDlg,aConfig,@cArquivo)
EndIf


Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS220PM³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Visualizacao/Processamento do Planejamento de Mate³±±
±±³          ³riais utilizados no Projeto.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS220PM(cAlias,nRecNo,nOpc)
Local aArea			:= GetArea()
Local aSize			:= MsAdvSize(,.F.,430)
Local lAltButton 	:= ExistBlock("PMS220BTN")
Local aMenuNew    := {}
Local aResource	:= {{ BMP_AMARELO,STR0095},; //"Planejamento Previsto"
				   		 {"ENABLE",STR0096}} //"Planejamento Firme"

Private aRotPM		:= {{ STR0003, "PMS220AT" , 0 , 2},; //"Visualizar"
                      { STR0013, "PMS220AT" , 0 , 3},; //"Gerar"
                      { STR0101, "PMS220AT2", 0 , 3},; //"Gerar Multiplo"
                      { STR0121, "PMS220AT" , 0 , 6},; //"Estornar"
                      { STR0014, "PMS220AT" , 0 , 5, 1} } //"Excluir"

Private aGetCpos 	:= {{"AFK_PROJET",AF8->AF8_PROJET,.F. }}
Private aTELA[0][0],aGETS[0]

If lAltButton
	aMenuNew := ExecBlock("PMS220BTN",.F.,.F.,{aRotPM})
	If ValType(aMenuNew) == "A" .And. Len(aMenuNew) > 0
		aRotPM := aClone(aMenuNew)
	EndIf
EndIf

AFK->(dbSetOrder(2))
aAdd(aRotPM,{ STR0097,	"PMS220FR", 0 , 2}) //"Firma Planej."
MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0015+Alltrim(AF8->AF8_PROJET)+"]","AFK",,aRotPM,"If(AFK_TPPLAN=='1','X','')",; //" - Planejamentos -["
			'xFilial("AFK")+AF8->AF8_PROJET',;
			'xFilial("AFK")+AF8->AF8_PROJET',.F.,aResource,,{{STR0051,2},{STR0042,3}},xFilial("AFK")+AF8->AF8_PROJET) //"Codigo do Planejamento" //"Descricao"

RestArea(aArea)
Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS220SC³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Visualizacao das Solicitacoes de Compras vincula- ³±±
±±³          ³das ao Projeto.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS220SC(oTree,lVisual,cArquivo)
Local aArea		:= GetArea()
Local cAlias
Local nRecView
Local aSize		:= MsAdvSize(,.F.,430)
Local aRotina		:= {}
Local lHabVis 	:= .T.
Local lHabInc		:= .T.
Local lHabAlt		:= .T.
Local lHabExc		:= .T.
Local aUsrRotina	:= {}
Local lContinua	:= .T.

If ExistBlock("PMA220SC")
	If !ExecBlock("PMA220SC")
		lContinua := .F.
	EndIf
EndIf

If lContinua
	If oTree == Nil
		cAlias	:= (cArquivo)->ALIAS
		nRecView	:= (cArquivo)->RECNO
	Else
		cAlias	:= SubStr(oTree:GetCargo(),1,3)
		nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
	EndIf

	A220ValOp(cAlias,nRecView,"GERSC",@lHabVis,@lHabInc,@lHabAlt,@lHabExc)

	aRotina:= If(lVisual,{{ STR0003,"A220toSC", 0 , 2,,lHabVis}},{	{ STR0003,"A220toSC", 0 , 2,  ,lHabVis},; //"Visualizar"###"Visualizar"
															   		{ STR0016,"A220toSC", 0 , 3,  ,lHabInc},;	 //"Incluir"
																	{ STR0017,"A220toSC", 0 , 4,  ,lHabAlt},;	 //"Alterar"
																	{ STR0014,"A220toSC", 0 , 5, 1,lHabExc} }) //"Excluir"

	If ExistBlock("PMA220BT")
		// PONTO DE ENTRADA PARA INCLUIR NOVOS BOTOES
		// SEM ALTERAR OS BOTOES PADROES
		aUsrRotina := ExecBlock("PMA220BT", .F., .F.)

		If ValType(aUsrRotina) == "A"
			aEval(aUsrRotina, { |x| aAdd(aRotina, x)})
		EndIf
	ElseIf ExistBlock("PMA220AB")
		// PONTO DE ENTRADA PARA ALTERAR BOTOES PADROES.
		aUsrRotina := ExecBlock("PMA220AB", .F., .F.,{aRotina})

		If ValType(aUsrRotina) == "A"
			aRotina := aUsrRotina
		EndIf
	EndIf

	If cAlias == "AF9" .And. nRecView<>0
		AF9->(dbGoto(nRecView))
		_cTarefa := AF9->AF9_TAREFA   //variavel utilizada x3_relacao Funcao PmsCpoInic()
		AFG->(dbSetOrder(1))
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5] ,cCadastro+STR0018+AllTrim(AF9->AF9_PROJET)+"/"+AF9->AF9_TAREFA+"]","AFG",,aRotina,,; //" - SC -["
		'xFilial("AFG")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
		'xFilial("AFG")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
		.F.,,,{{STR0052,1},{STR0089,5}},xFilial("AFG")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA) //"Numero da SC + Item da SC" //"Codigo do Produto"
	ElseIf cAlias == "AF8" .And. nRecView<>0
		AF8->(dbGoto(nRecView))
		_cTarefa := Space(Len(AF9->AF9_TAREFA))   //variavel utilizada x3_relacao Funcao PmsCpoInic()
		AFG->(dbSetOrder(1))
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0018+AllTrim(AF8->AF8_PROJET)+"]","AFG",,aRotina,,; //" - SC -["
		'xFilial("AFG")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
		'xFilial("AFG")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
		.F.,,,{{STR0053,1},{STR0089,6}},xFilial("AFG")+AF8->AF8_PROJET+AF8->AF8_REVISA) //"Tarefa + Numero da SC + Item da SC" //"Codigo do Produto"
	EndIf
EndIf
RestArea(aArea)
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A220toSC³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Atualizacao das Solicitacoes de Compras vinculadas³±±
±±³          ³ao Projeto .                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A220toSC(cAlias,nReg,nOpcx)
Local aArea		:= GetArea()
Local cFilSC1 	:= ""
Local cFilOldSC1 	:= ""

PRIVATE Inclui
PRIVATE Altera

Do Case
	Case nOpcx == 1
		Inclui := .F.
		Altera := .F.

		cFilSC1 := PmsFilial("SC1","AFG")
		cFilOldSC1  := cFilAnt
		If cFilSC1 <> ""
			cFilAnt 	:= cFilSC1
		EndIf

		SC1->(dbSetOrder(1))
		If SC1->(dbSeek(xFilial("SC1")+AFG->AFG_NUMSC))
			MATA110(,,2)
		EndIf

		cFilAnt 		:= cFilOldSC1

	Case nOpcx == 2
		Inclui := .T.
		Altera := .F.
		MATA110(,,3)

	Case nOpcx == 3
		Inclui := .F.
		Altera := .T.

		cFilSC1 		:= PmsFilial("SC1","AFG")
		cFilOldSC1  := cFilAnt
		If cFilSC1 <> ""
			cFilAnt 	:= cFilSC1
		EndIf

		SC1->(dbSetOrder(1))
		If SC1->(dbSeek(xFilial("SC1")+AFG->AFG_NUMSC))
			MATA110(,,4)
		EndIf

		cFilAnt 		:= cFilOldSC1

	Case nOpcx == 4
		Inclui := .F.
		Altera := .F.

		cFilSC1 		:= PmsFilial("SC1","AFG")
		cFilOldSC1  := cFilAnt
		If cFilSC1 <> ""
			cFilAnt 	:= cFilSC1
		EndIf

		SC1->(dbSetOrder(1))
		If SC1->(dbSeek(xFilial("SC1")+AFG->AFG_NUMSC))
			MATA110(,,5)
		EndIf

		cFilAnt 		:= cFilOldSC1

EndCase

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS220SA³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Visualizacao das Solicitacoes ao Almox. vinculadas³±±
±±³          ³ap Projeto.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS220SA(oTree,lVisual,cArquivo)

Local aArea		:= GetArea()
Local cAlias
Local nRecView
Local aSize		:= MsAdvSize(,.F.,430)
Local aRotina		:= {}
Local lHabVis 	:= .T.
Local lHabInc		:= .T.
Local lHabAlt		:= .T.
Local lHabExc		:= .T.
Local lContinua	:= .T.

If ExistBlock("PMA220SA")
	If !ExecBlock("PMA220SA")
		lContinua := .F.
	EndIf
EndIf

If lContinua
	If oTree == Nil
		cAlias	:= (cArquivo)->ALIAS
		nRecView	:= (cArquivo)->RECNO
	Else
		cAlias	:= SubStr(oTree:GetCargo(),1,3)
		nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
	EndIf


	A220ValOp(cAlias,nRecView,"GERSA",@lHabVis,@lHabInc,@lHabAlt,@lHabExc)

	aRotina   := If(lVisual,{	{ STR0003,"A220ToSA", 0 , 2,,lHabVis}},{{ STR0003,"A220ToSA", 0 , 2,  ,lHabVis},; //"Visualizar"
																		 { STR0016,"A220ToSA", 0 , 3,  ,lHabInc},;	 //"Incluir"
																		 { STR0017,"A220ToSA", 0 , 4,  ,lHabAlt },;	 //"Alterar"
																		 { STR0014,"A220ToSA", 0 , 5, 1,lHabExc} } )//"Excluir"
	
	If ExistBlock("PMA220BSA")
		// PONTO DE ENTRADA PARA INCLUIR NOVOS BOTOES
		// SEM ALTERAR OS BOTOES PADROES
		aUsrRotina := ExecBlock("PMA220BSA", .F., .F.)

		If ValType(aUsrRotina) == "A"
			aEval(aUsrRotina, { |x| aAdd(aRotina, x)})
		EndIf
	EndIf

	If cAlias == "AF9" .And. nRecView<>0
		AF9->(dbGoto(nRecView))
		_cTarefa := AF9->AF9_TAREFA   //variavel utilizada x3_relacao Funcao PmsCpoInic()
		AFH->(dbSetOrder(1))
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5] ,cCadastro+STR0019+AllTrim(AF9->AF9_PROJET)+"/"+AF9->AF9_TAREFA+"]","AFH",,aRotina,,; //" - SA -["
		'xFilial("AFH")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
		'xFilial("AFH")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
		.F.,,,{{STR0054,1},{STR0089,4}},xFilial("AFH")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA) //"Numero da SA + Item da SA" //"Codigo do Produto"
	ElseIf cAlias == "AF8" .And. nRecView<>0
		AF8->(dbGoto(nRecView))
		_cTarefa := Space(Len(AF9->AF9_TAREFA))   //variavel utilizada x3_relacao Funcao PmsCpoInic()
		AFH->(dbSetOrder(1))
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0019+AllTrim(AF8->AF8_PROJET)+"]","AFH",,aRotina,,; //" - SA -["
		'xFilial("AFH")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
		'xFilial("AFH")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
		.F.,,,{{STR0055,1},{STR0089,5}},xFilial("AFH")+AF8->AF8_PROJET+AF8->AF8_REVISA) //"Tarefa + Numero da SA + Item da SA" //"Codigo do Produto"
	EndIf
EndIf

RestArea(aArea)
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A220toSA³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Atualizacao das Solicitacoes ao Almox.  vinculadas³±±
±±³          ³ao Projeto .                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A220toSA(cAlias,nReg,nOpcx)
Local aArea			:= GetArea()
Local cFilSCP 		:= ""
Local cFilOldSCP	:= ""
Local l220Inclui	:= INCLUI
Local l220Altera	:= ALTERA

Do Case
	Case nOpcx == 1
	 	cFilSCP := PmsFilial("SCP","AFH")
		cFilOldSCP  := cFilAnt
		If cFilSCP <> ""
			cFilAnt 	:= cFilSCP
		EndIf

		SCP->(dbSetOrder(1))
		If SCP->(dbSeek(xFilial()+AFH->AFH_NUMSA))
			INCLUI	:= .F.
			ALTERA	:= .F.
			MATA105(,,2)
			INCLUI	:=	l220Inclui
			ALTERA	:= 	l220Altera
		EndIf

		cFilAnt	   := cFilOldSCP

	Case nOpcx == 2
		INCLUI	:= .T.
		ALTERA	:= .F.
		MATA105(,,3)
		INCLUI	:=	l220Inclui
		ALTERA	:= 	l220Altera
	Case nOpcx == 3
	 	cFilSCP 		:= PmsFilial("SCP","AFH")
		cFilOldSCP  := cFilAnt
		If cFilSCP <> ""
			cFilAnt 	:= cFilSCP
		EndIf

		SCP->(dbSetOrder(1))
		If SCP->(dbSeek(xFilial()+AFH->AFH_NUMSA))
			INCLUI	:= .F.
			ALTERA	:= .T.
			MATA105(,,4)
			INCLUI	:=	l220Inclui
			ALTERA	:= 	l220Altera
		EndIf

		cFilAnt	   := cFilOldSCP

	Case nOpcx == 4
		cFilSCP 		:= PmsFilial("SCP","AFH")
		cFilOldSCP  := cFilAnt
		If cFilSCP <> ""
			cFilAnt 	:= cFilSCP
		EndIf

		SCP->(dbSetOrder(1))
		If SCP->(dbSeek(xFilial()+AFH->AFH_NUMSA))
			INCLUI	:= .F.
			ALTERA	:= .F.
			MATA105(,,5)
			INCLUI	:=	l220Inclui
			ALTERA	:= 	l220Altera
		EndIf

		cFilAnt	   := cFilOldSCP

EndCase

RestArea(aArea)
Return

/*/{Protheus.doc} PMS220AT

Tela de atualizacao dos Planejamentos do Projeto

@param cAlias1, caracter, ${param_descr}
@param nRecno,numerico, ${param_descr}
@param nOpcx, numerico, ${param_descr}

@return ${return}, ${return_description}

@author Edson Maricate
@since 09-02-2001
@version 1.0
/*/
Function PMS220AT(cAlias1,nRecno,nOpcx)
Local aArea		:= GetArea()
Local aAreaAFG	:= AFG->(GetArea())
Local aAreaAFH	:= AFH->(GetArea())
Local aAreaAFM	:= AFM->(GetArea())
Local aAreaPl		:= GetArea()
Local aButtons
Local aGetEnch
Local aRecAFJ		:= {}
Local aRecSC1		:= {}
Local aRecSC2		:= {}
Local aRecSC7		:= {}
Local aRecSCP		:= {}
Local aRecAFA		:= {} //Array de recnos da AFA
Local aAtuAFJ		:= {} //Array de Empenhos que devem ser apenas atualizados
Local cCpo
Local cTexto		:= ""
Local cFilialAFK	:= xFilial("AFK")
Local cFilialAFG	:= xFilial("AFG")
Local cFilialAFA	:= xFilial("AFA")
Local lChkEmp		:= .F.
Local lChkOP		:= .F.
Local lChkSA		:= .F.
Local lChkSC		:= .F.
Local lContinua	:= .T.
Local lIntegraca	:= IF(GetMV("MV_EASY")=="S",.T.,.F.)
Local lOk			:= .F.
Local lPMA220GPL	:= ExistBlock("PMA220GPL")
Local lPMA220PL	:= ExistBlock("PMA220PL")
Local lPMSA410	:= ALLTRIM(FUNNAME()) == "PMSA410"
Local lPlanAFA	:= .F.
Local nLenMsg
Local nPosAFA		:= 0
Local nx
Local oDlg
Local oEnch
Local oMenu

Private aTELA[0][0],aGETS[0]
Private lATEstorn := .F.
Private lATExclui := .F.
Private lATInclui := .F.
Private lATVisual := .F.
Private lDeleta	:= .F.

If GetVersao(.F.) == "P10"
	aButtons	:= {{ "BMPINCLUIR",{||oMenu:Activate(190,45,oDlg)},STR0056}} //"Detalhes"
Else
	//Acoes relacionadas
	aButtons	:= {{ "BMPINCLUIR",{||oMenu:Activate(500,150,oDlg)},STR0056}} //"Detalhes"
EndIf

AFK->(DbSetOrder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case aRotPM[nOpcx][4] == 2
		lATVisual := .T.
	Case aRotPM[nOpcx][4] == 3
		lATInclui	:= .T.
	Case aRotPM[nOpcx][4] == 5
		lATExclui	:= .T.
		lATVisual	:= .T.
		lDeleta		:= .T.
		cTexto := STR0107 + CRLF
	Case aRotPM[nOpcx][4] == 6
		lATEstorn	:= .T.
		lDeleta		:= .F.
EndCase

nLenMsg := Len(cTexto)

If (lATVisual .and. !lATExclui)
	lContinua	:= .T.
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o evento de alteracao no Fase atual.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !PmsVldFase("AF8",AF8->AF8_PROJET,"51")
		lContinua := .F.
	EndIf
EndIf

If lContinua

	// carrega as variaveis de memoria AFK
	If lATInclui
		RegToMemory("AFK",.T.) //carega com os valores inicializadores (X3_RELACAO)
		While AFK->(DbSeek(cFilialAFK+M->AFK_PLANEJ))
			M->AFK_PLANEJ := GetSXENum("AFK","AFK_PLANEJ")
		EndDo
	Else
		RegToMemory("AFK",.F.) //carrega com os valores de AFK
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe registros na tabela a serem consultados   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lATVisual

		If cFilialAFK # AFK->AFK_FILIAL .or. (AFK->(EOF()) .and. AFK->(BOF()))
			HELP(" ",1,"ARQVAZIO")
			lContinua := .F.
		EndIf

	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida a exclusao do planejamento.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//³ Se houve movimentacao na solicitacao de compra, ordem de     ³
	//³ produção, empenhos não permite excluir o planejamento.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lATExclui
		
		//Cria array com produtos da tarefa que pertencem ao planejamento 
		dbSelectArea("AFA")
		dbSetOrder(6)
		AFA->(dbSeek(cFilialAFA+AFK->AFK_PLANEJ))
		While AFA->(!Eof()) .And. cFilialAFK+AFK->AFK_PLANEJ==AFA->AFA_FILIAL+AFA->AFA_PLANEJ
			aAdd(aRecAFA,AFA->(RecNo()))
			AFA->(dbSkip())
		End
		
		//
		// Verifica atraves da associacao do projeto se foi atendido as solicitacoes de compra
		// pela quantidade em pedido de compra.
		//
		SC1->(dbSetOrder(1))
		dbSelectArea("AFG")
		dbSetOrder(3)
		dbSeek(xFilial()+AFK->AFK_PLANEJ)
		While !Eof() .And. xFilial()+AFK->AFK_PLANEJ==AFG->AFG_FILIAL+AFG->AFG_PLANEJ
			If SC1->(dbSeek(PmsFilial("SC1","AFG")+AFG->AFG_NUMSC+AFG->AFG_ITEMSC))
				If aScan(aRecSC1,SC1->(RecNo())) <= 0
					If SC1->C1_QUJE != 0
						cTexto += STR0057+SC1->C1_NUM+"/"+SC1->C1_ITEM + CRLF
						lContinua := .F.
					ElseIf (lIntegraca .and. "IMPORT" $ SC1->C1_COTACAO .AND. !Empty(SC1->C1_NUM_SI)) .OR. ( !Empty(SC1->C1_COTACAO) .and. !("IMPORT" $ SC1->C1_COTACAO) )
						cTexto += STR0057+SC1->C1_NUM+"/"+SC1->C1_ITEM + CRLF
						lContinua := .F.
					EndIf
					aAdd(aRecSC1,SC1->(RecNo()))
				EndIf
			EndIf
			dbSelectArea("AFG")
			dbSkip()
		End
		//
		// Verifica atraves da associacao do projeto se foi atendido as solicitacoes de armzazem
		// pela flag de pre-requisicao
		//
		SCP->(dbSetOrder(1))
		dbSelectArea('AFH')
		dbSetOrder(3)
		If MsSeek(xFilial("AFH")+AFK->AFK_PLANEJ)
			While !Eof().And.AFH->AFH_FILIAL+AFH->AFH_PLANEJ==xFilial("AFH")+AFK->AFK_PLANEJ
				cNumSA	:= AFH->AFH_NUMSA
				cItemSA	:= AFH->AFH_ITEMSA
				If SCP->(dbSeek(PmsFilial("SCP","AFH")+AFH->AFH_NUMSA+AFH->AFH_ITEMSA))
					If SCP->CP_PREREQU=="S"
						//Aviso(STR0035,STR0062+SCP->CP_NUM+"/"+SCP->CP_ITEM+STR0063,{STR0059},2,STR0060) //"Atencao"###"A Solicitacao ao Armazem Num. "###" ja foi baixada por pre-requisicao e nao podera ser excluida. O planejamento nao podera ser excluido neste momento."###"Fechar"###"Exclusao do planejamento"
						cTexto += STR0062+SCP->CP_NUM+"/"+SCP->CP_ITEM + CRLF
						lContinua := .F.
					EndIf
					aAdd(aRecSCP,SCP->(RecNo()))
				EndIf
				dbSelectArea("AFH")
				dbSkip()
			End
		EndIf

		//
		// Verifica atraves da associacao do projeto se foi atendido as ordens de producao
		// pela quantidade produzida.
		//
		SC2->(dbSetOrder(1))
		dbSelectArea('AFM')
		dbSetOrder(3)
		If MsSeek(xFilial()+AFK->AFK_PLANEJ)
			While !Eof().And.AFM->AFM_FILIAL+AFM->AFM_PLANEJ==xFilial("AFM")+AFK->AFK_PLANEJ
				dbSelectArea("SC2")
				If dbSeek(PmsFilial("SC2","AFM")+AFM->AFM_NUMOP+AFM->AFM_ITEMOP+AFM->AFM_SEQOP)
					If aScan(aRecSC2,SC2->(RecNo()))<=0
						If SC2->C2_QUJE != 0
							//Aviso(STR0035,STR0064+SC2->C2_NUM+"/"+SC2->C2_ITEM+STR0065,{STR0059},2,STR0060) //"Atencao"###"A Ordem de Producao Num. "###" ja foi produzida e nao podera ser excluida. O planejamento nao podera ser excluido neste momento."###"Fechar"###"Exclusao do planejamento"
							cTexto += STR0064+SC2->C2_NUM+"/"+SC2->C2_ITEM + CRLF
							lContinua := .F.
						EndIf
						aAdd(aRecSC2,SC2->(RecNo()))
					EndIf
				EndIf
				dbSelectArea("AFM")
				dbSkip()
			End
		EndIf

		//
		// Verifica atraves da associacao do projeto se foi atendido a autorização de entrega
		// pela quantidade solicitada na tarefa
		//
		SC7->(dbSetOrder(1))
		dbSelectArea('AFL')
		dbSetOrder(3)
		If MsSeek(xFilial("AFL")+AFK->AFK_PLANEJ)
			While !Eof() .And. AFL->(AFL_FILIAL+AFL_PLANEJ) == xFilial("AFL")+AFK->AFK_PLANEJ
				dbSelectArea("SC7")
				BeginSQL ALIAS "AUXSC7"
				SELECT SC7.R_E_C_N_O_ RECSC7 FROM %TABLE:SC7% SC7 LEFT JOIN %TABLE:AFL% AFL ON
						 SC7.C7_NUMSC = AFL.AFL_NUMCP AND SC7.C7_ITEMSC = AFL.AFL_ITEMCP
						 WHERE    SC7.C7_FILIAL = %EXP:xFilial("SC7")%
				   			AND AFL.AFL_FILIAL = %EXP:xFilial("AFL")%
								AND AFL.AFL_PLANEJ = %EXP:AFL->AFL_PLANEJ%
								AND AFL.AFL_NUMCP  = %EXP:AFL->AFL_NUMCP%
								AND AFL.AFL_ITEMCP = %EXP:AFL->AFL_ITEMCP%
								AND SC7.C7_TIPO = 2
						  		AND SC7.%NotDel%
						  		AND AFL.%NotDel%
		  		EndSQL

				SC7->(dbGoTo(("AUXSC7")->RECSC7))

				("AUXSC7")->(dbCloseArea())

				If aScan(aRecSC7,SC7->(RecNo())) <= 0
					If SC7->C7_QUJE != 0
						cTexto += STR0124+SC7->C7_NUMSC+"/"+SC7->C7_ITEMSC + CRLF
						lContinua := .F.
					EndIf
					aAdd(aRecSC7,SC7->(RecNo()))
				EndIf

				dbSelectArea("AFL")
				dbSkip()
			End
		EndIf

		// Verifica atraves dos empenhos do projeto, se foi utilizado através da quantidade atual
		//
		dbSelectArea('AFJ')
		dbSetOrder(4)
		If MsSeek(xFilial("AFJ")+AFK->AFK_PLANEJ)
			While !Eof().And.AFJ->AFJ_FILIAL+AFJ->AFJ_PLANEJ==xFilial("AFJ")+AFK->AFK_PLANEJ
				If AFJ->AFJ_QATU != 0
					//Aviso("Atencao","A sequencia de empenho "+AFJ->AFJ_TRT+" do produto "+AFJ->AFJ_COD+" da tarefa "+AFJ->AFJ_TAREFA+" já foi utilizadda. O Planejamento não podera ser excluido neste momento.",{STR0059},2,"Exclusao do planejamento")
					cTexto += STR0103+AFJ->AFJ_TRT+STR0104+AllTrim(AFJ->AFJ_COD)+STR0105+AllTrim(AFJ->AFJ_TAREFA) + CRLF
					lContinua := .F.
				EndIf
				aAdd(aRecAFJ,AFJ->(RecNo()))
				dbSKip()
			EndDo
		EndIf
	EndIf

	If lATEstorn
		
		//Cria array com produtos da tarefa que pertencem ao planejamento
		dbSelectArea("AFA")
		dbSetOrder(6)
		AFA->(dbSeek(cFilialAFA+AFK->AFK_PLANEJ))
		While AFA->(!Eof()) .And. cFilialAFK+AFK->AFK_PLANEJ==AFA->AFA_FILIAL+AFA->AFA_PLANEJ
			aAdd(aRecAFA,AFA->(RecNo()))
			AFA->(dbSkip())
		End
		//
		// Verifica atraves da associacao do projeto se foi atendido as solicitacoes de compra
		// pela quantidade em pedido de compra.
		//
		SC1->(dbSetOrder(1))
		AFA->(dbSetOrder(1))
		dbSelectArea("AFG")
		dbSetOrder(3)
		AFG->(dbSeek(xFilial()+AFK->AFK_PLANEJ))
		While !Eof() .And. xFilial()+AFK->AFK_PLANEJ==AFG->AFG_FILIAL+AFG->AFG_PLANEJ
			If SC1->(dbSeek(PmsFilial("SC1","AFG")+AFG->AFG_NUMSC+AFG->AFG_ITEMSC))
				If aScan(aRecSC1,SC1->(RecNo())) <= 0
					If SC1->C1_QUJE == 0 .Or. Empty(SC1->C1_COTACAO)
						lContinua := .T.
						aAdd(aRecSC1,SC1->(RecNo()))
					Else
						//Retira do array da AFA os planejamentos que não devem ser eliminados
						AFA->(dbSeek(cFilialAFA+AFG->AFG_PROJET+AFG->AFG_REVISA+AFG->AFG_TAREFA+AFG->AFG_AFAITE+AFG->AFG_COD))
						nPosAFA := aScan( aRecAFA, AFA->(RecNo()) )
			   	    	If  nPosAFA > 0
			   	    		aDel(aRecAFA,nPosAFA)
							aSize(aRecAFA,Len(aRecAFA)-1)
							lPlanAFA := .T.
						EndIf
						nPosAFA := 0
					EndIf
				EndIf
			EndIf
			dbSelectArea("AFG")
			dbSkip()
		End
		
		If lPlanAFA
			Help(NIL, NIL, STR0121, NIL, STR0126, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0127}) //"Estornar"##"Algumas Solicitações de Compras deste planejamento possuem vínculo com Pedidos de Compras."##"Os vínculos deste item não serão eliminados."
		EndIf

		//
		// Verifica atraves da associacao do projeto se foi atendido as solicitacoes de armzazem
		// pela flag de pre-requisicao
		//
		SCP->(dbSetOrder(1))
		dbSelectArea('AFH')
		dbSetOrder(3)
		If MsSeek(xFilial()+AFK->AFK_PLANEJ)
			While !Eof().And.AFH->AFH_FILIAL+AFH->AFH_PLANEJ==xFilial("AFH")+AFK->AFK_PLANEJ
				cNumSA	:= AFH->AFH_NUMSA
				cItemSA	:= AFH->AFH_ITEMSA
				If SCP->(dbSeek(PmsFilial("SCP","AFH")+AFH->AFH_NUMSA+AFH->AFH_ITEMSA))
					If SCP->CP_PREREQU != "S"
						lContinua := .T.
						aAdd(aRecSCP,SCP->(RecNo()))
					EndIf
				EndIf
				dbSelectArea("AFH")
				dbSkip()
			End
		EndIf

		//
		// Verifica atraves da associacao do projeto se foi atendido as ordens de producao
		// pela quantidade produzida.
		//
		SC2->(dbSetOrder(1))
		dbSelectArea('AFM')
		dbSetOrder(3)
		If MsSeek(xFilial()+AFK->AFK_PLANEJ)
			While !Eof().And.AFM->AFM_FILIAL+AFM->AFM_PLANEJ==xFilial("AFM")+AFK->AFK_PLANEJ
				dbSelectArea("SC2")
				If dbSeek(PmsFilial("SC2","AFM")+AFM->AFM_NUMOP+AFM->AFM_ITEMOP+AFM->AFM_SEQOP)
					If aScan(aRecSC2,SC2->(RecNo()))<=0
						If SC2->C2_QUJE == 0
							lContinua := .T.
							aAdd(aRecSC2,SC2->(RecNo()))
						EndIf
					EndIf
				EndIf
				dbSelectArea("AFM")
				dbSkip()
			End
		EndIf

		SC7->(dbSetOrder(1))
		dbSelectArea('AFL')
		dbSetOrder(3)
		If MsSeek(xFilial("AFL")+AFK->AFK_PLANEJ)
			While !Eof().And.AFL->(AFL_FILIAL+AFL_PLANEJ) == xFilial("AFL")+AFK->AFK_PLANEJ
				dbSelectArea("SC7")
				BeginSQL ALIAS "AUXSC7"
				SELECT SC7.R_E_C_N_O_ RECSC7 FROM %TABLE:SC7% AS SC7 LEFT JOIN %TABLE:AFL% AS AFL ON
						 SC7.C7_NUMSC = AFL.AFL_NUMCP AND SC7.C7_ITEMSC = AFL.AFL_ITEMCP
						 WHERE    SC7.C7_FILIAL = %EXP:xFilial("SC7")%
				   			AND AFL.AFL_FILIAL = %EXP:xFilial("AFL")%
								AND AFL.AFL_PLANEJ = %EXP:AFL->AFL_PLANEJ%
								AND AFL.AFL_NUMCP  = %EXP:AFL->AFL_NUMCP%
								AND AFL.AFL_ITEMCP = %EXP:AFL->AFL_ITEMCP%
						  		AND SC7.%NotDel%
						  		AND AFL.%NotDel%
		  		EndSQL

				SC7->(dbGoTo(("AUXSC7")->RECSC7))

				("AUXSC7")->(dbCloseArea())

				If aScan(aRecSC7,SC7->(RecNo()))<=0
					If SC7->C7_QUJE == 0
						lContinua := .T.
						aAdd(aRecSC7,SC7->(RecNo()))
					EndIf
				EndIf

				dbSelectArea("AFL")
				dbSkip()
			End
		EndIf

		//
		// Verifica atraves dos empenhos do projeto, se foi utilizado através da quantidade atual
		//
		dbSelectArea('AFJ')
		dbSetOrder(4)
		If MsSeek(xFilial()+AFK->AFK_PLANEJ)
			While !Eof().And.AFJ->AFJ_FILIAL+AFJ->AFJ_PLANEJ==xFilial("AFJ")+AFK->AFK_PLANEJ
				If (AFJ->AFJ_ROTGER $ '4,5' .Or. Empty(AFJ->AFJ_ROTGER)) .And. AFJ->AFJ_QATU == 0
					lContinua := .T.
					aAdd(aRecAFJ,AFJ->(RecNo()))
				EndIf
				dbSKip()
			EndDo
		EndIf
		If Len(aRecAFJ) > 0
			//Verifica se dentre os empenhos quais devem ser atualizados e não excluidos
			AFA->(dbSetOrder(1))
			dbSelectArea("AFG")
			dbSetOrder(3)
			AFG->(dbSeek(cFilialAFG+AFK->AFK_PLANEJ))
			While AFG->(!Eof()) .And. cFilialAFK+AFK->AFK_PLANEJ==AFG->AFG_FILIAL+AFG->AFG_PLANEJ
				If AFA->(dbSeek(PmsFilial("AFA","AFG")+AFG->AFG_PROJET+AFG->AFG_REVISA+AFG->AFG_TAREFA+AFG->AFG_AFAITE+AFG->AFG_COD))
					If aScan(aRecAFA,AFA->(RecNo())) == 0 .AND. AFG->AFG_QUANT < AFA->AFA_QUANT
						aAdd(aAtuAFJ,{AFA->AFA_PRODUT,AFA->AFA_QUANT-AFG->AFG_QUANT})
					EndIf
				EndIf
				AFG->(dbSkip())
			End
		EndIf
   EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento do array aGetCpos com os campos Inicializados do AFK    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lATInclui
		M->AFK_DATAI	:= AF8->AF8_START
		M->AFK_DATAF	:= AF8->AF8_FINISH
		If aGetCpos <> Nil
			aGetEnch	:= {}
			dbSelectArea("SX3")
			dbSetOrder(1)
			dbSeek("AFK")
			While !Eof() .and. SX3->X3_ARQUIVO == "AFK"
				IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
					nPosCpo	:= aScan(aGetCpos,{|x| x[1]==Alltrim(X3_CAMPO)})
					If nPosCpo > 0
						If aGetCpos[nPosCpo][3]
							aAdd(aGetEnch,AllTrim(X3_CAMPO))
						EndIf
					Else
						aAdd(aGetEnch,AllTrim(X3_CAMPO))
					EndIf
				EndIf
				dbSkip()
			End
			For nx := 1 to Len(aGetCpos)
				cCpo	:= "M->"+Trim(aGetCpos[nx][1])
				&cCpo	:= aGetCpos[nx][2]
			Next nx
		EndIf
	Else
		AFM->(dbSetOrder(3))
		lChkOP	:= AFM->(dbSeek(xFilial()+M->AFK_PLANEJ))
		AFG->(dbSetOrder(3))
		lChkSC	:= AFG->(dbSeek(xFilial()+M->AFK_PLANEJ))
		AFH->(dbSetOrder(3))
		lChkSA	:= AFH->(dbSeek(xFilial()+M->AFK_PLANEJ))
		AFJ->(dbSetOrder(4))
		lChkEmp	:= AFJ->(dbSeek(xFilial()+M->AFK_PLANEJ))
		MENU oMenu POPUP
		If lChkSC
			MENUITEM STR0066 Action PmsPl220SC(AFK->AFK_PLANEJ) //"Solicitacoes de Compras..."
		Else
			MENUITEM STR0066 Action PmsPl220SC(AFK->AFK_PLANEJ) DISABLED  //"Solicitacoes de Compras..."
		EndIf
		If lChkOP
			MENUITEM STR0068 Action PmsPl220OP(AFK->AFK_PLANEJ) //"Ordens de Producao..."
		Else
			MENUITEM STR0068 Action PmsPl220OP(AFK->AFK_PLANEJ) DISABLED //"Ordens de Producao..."
		EndIf
		If lChkEmp
			MENUITEM STR0027 Action PmsPl220EMP(AFK->AFK_PLANEJ)  //"Empenhos"
		Else
			MENUITEM STR0027 Action PmsPl220EMP(AFK->AFK_PLANEJ) DISABLED  //"Empenhos"
		EndIf
		ENDMENU
	EndIf

	If lContinua

		DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO TranslateBottom(.F.,28),80 of oMainWnd

		oEnch := MsMGet():New("AFK", AFK->(RecNo()),If(lATInclui,IIF(lPMSA410,3,4),2),,,,, {,,(oDlg:nClientHeight - 4)/2,},aGetEnch,3,,,,oDlg)
		oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(Obrigatorio(aGets,aTela),(lOk:=.T.,oDlg:End()),Nil)},{||oDlg:End()},,If(!lATInclui,aButtons,Nil))

	EndIf

	If lOk .And. (lATInclui .Or. lATExclui .Or. lATEstorn)

		If lPMA220PL
			aAreaPl	:= GetArea()
			If !ExecBlock("PMA220PL")
				RestArea(aAreaPl)
				RestArea(aAreaAFM)
				RestArea(aAreaAFG)
				RestArea(aAreaAFH)
				RestArea(aArea)
				Return
			EndIf
			RestArea(aAreaPl)
		EndIf

		Processa({||PMS220WrAT(IIF(lATExclui .Or. lATInclui,lATExclui,lATEstorn),aRecSC1,aRecSC2,aRecAFJ,lDeleta,aRecSC7,,,aRecAFA,aAtuAFJ)})

		If lPMA220GPL
			ExecBlock("PMA220GPL")
		EndIf

	Else
		RollBackSX8()

      If Len(cTexto) > nLenMsg
			__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)
			DEFINE FONT oFont NAME "Courier New" SIZE 7,15
			DEFINE MSDIALOG oDlg TITLE STR0108 From 3,0 to 400,417 PIXEL
			@ 5,5 Say STR0109 Size 100,15 Of oDlg Pixel
			@ 14,5 Say STR0110	Size 50,15 Of oDlg Pixel
			@ 23,5 GET oMemo  VAR cTexto MEMO SIZE 200,155 Read  OF oDlg PIXEL
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont:=oFont

			DEFINE SBUTTON  FROM 185,170 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga

			ACTIVATE MSDIALOG oDlg CENTER
		EndIf
	EndIf
EndIf

RestArea(aAreaAFM)
RestArea(aAreaAFG)
RestArea(aAreaAFH)
RestArea(aArea)

Return( .T. )

/*/{Protheus.doc} PMS220AT2

Tela de atualizacao dos Planejamentos Multiplos do Projeto

@param cAlias1, caracter, ${param_descr}
@param nRecno, numerico, ${param_descr}
@param nOpcx, numerico, ${param_descr}

@return ${return}, ${return_description}

@author Daniel Sobreira
@since 14-10-2005
@version 1.0
/*/
Function PMS220AT2(cAlias,nRecno,nOpcx)
Local aArea     := GetArea()
Local aAreaAFG  := AFG->(GetArea())
Local aAreaAFH  := AFH->(GetArea())
Local aAreaAFM  := AFM->(GetArea())
Local aButtons
Local aGetEnch
Local aGetEnch2 := {}
Local aPlanej   := {}
Local aProjetos := {}
Local aRecAFJ   := {}
Local aRecSC1   := {}
Local aRecSC2   := {}
Local aRecSCP   := {}
Local cCpo
Local lATInclui := .T.
Local lContinua := .T.
Local lOk       := .F.
Local nAF8Recno := 0
Local nLoop     := 0
Local nTamaCol  := 0
Local nx
Local ny
Local oDlg
Local oMenu

Private aCols	:= {}
Private aHeader	:= {}
Private aTELA[0][0],aGETS[0]
Private oGetMt

Private aAlter	:= {"AFK_TRFDE",;
					"AFK_TRFATE",;
					"AFK_GRPDE",;
					"AFK_GRPATE",;
					"AFK_PRDDE",;
					"AFK_PRDATE",;
					"AFK_GRTDE",;
					"AFK_GRTATE"}//-- Array de Campos ALTERAVEIS
Private aYesFields	:= {"AFK_TRFDE",;
					"AFK_TRFATE",;
					"AFK_GRPDE",;
					"AFK_GRPATE",;
					"AFK_PRDDE",;
					"AFK_PRDATE",;
					"AFK_GRTDE",;
					"AFK_GRTATE",;
					"AFK_PROJET",;
					"AFK_DESCRI"}//-- Array de Campos ALTERAVEIS


aGetCpos := {	{"AFK_PROJET",AF8->AF8_PROJET,.T.},;
				{"AFK_DESCRI",AF8->AF8_DESCRI,.T.}}

If GetVersao(.F.) == "P10"
	aButtons  := {{ "BMPINCLUIR",{||oMenu:Activate(190,45,oDlg)},STR0056}} //"Detalhes"
Else
	//Acoes relacionadas
	aButtons  := {{ "BMPINCLUIR",{||oMenu:Activate(500,150,oDlg)},STR0056}} //"Detalhes"
EndIf

// Armazena a posicao atual do Projeto
nAF8Recno := AF8->(Recno())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento do array aGetCpos com os campos Inicializados do AFK    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lATInclui
	aProjetos := PMSelProj()
Else
	aProjetos:={{.F.,AF8->AF8_PROJET,Alltrim(AF8->AF8_DESCRI),0}}
EndIf

AF8->(DbGoTo(nAF8Recno))

If Len(aProjetos)>0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeaderAFK                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AFK")
	While !EOF() .And. (x3_arquivo == "AFK")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			If Alltrim(SX3->X3_CAMPO) $ "AFK_PROJET;AFK_DESCRI" .OR. aScan(aAlter,{|aX| aX == Alltrim(SX3->X3_CAMPO)}) > 0
				AADD(aHeader,{ 	TRIM(x3titulo()),;
									SX3->X3_CAMPO,;
									SX3->X3_PICTURE,;
									SX3->X3_TAMANHO,;
									SX3->X3_DECIMAL,;
									SX3->X3_VALID,;
									SX3->X3_USADO,;
									SX3->X3_TIPO,;
									SX3->X3_F3,;
									SX3->X3_CONTEXT})
			EndIf
		Endif
		dbSkip()
	End

	For nLoop:=1 to Len(aProjetos)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega as variaveis de memoria AFK                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RegToMemory("AFK",lATInclui)
		Aadd(aPlanej,M->AFK_PLANEJ)

		If lATInclui
			If AF8->(dbSeek(xfilial()+aProjetos[nLoop][2]))
				//Criar um acols para cada projeto
				MontaaCols()
				M->AFK_DATAI	:= AF8->AF8_START
				M->AFK_DATAF	:= AF8->AF8_FINISH
				If aGetCpos <> Nil
					aGetEnch	:= {}
					dbSelectArea("SX3")
					dbSetOrder(1)
					dbSeek("AFK")
					While !Eof() .and. SX3->X3_ARQUIVO == "AFK"
						IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
							nPosCpo	:= aScan(aGetCpos,{|x| x[1]==Alltrim(X3_CAMPO)})
							If nPosCpo > 0
								If aGetCpos[nPosCpo][3]
									aAdd(aGetEnch,AllTrim(X3_CAMPO))
								EndIf
							Else
								aAdd(aGetEnch,AllTrim(X3_CAMPO))
							EndIf
						EndIf
						dbSkip()
					End

					If nLoop==1
						For nx := 1 to Len(aGetEnch)
							If aScan(aAlter,{|aX| aX == aGetEnch[nx]}) <= 0
								If !(aGetEnch[nx]=="AFK_PROJET" .or. aGetEnch[nx]=="AFK_DESCRI" .or. aGetEnch[nx]=="AFK_PLANEJ")
									aAdd(aGetEnch2,aGetEnch[nx])
								EndIf
							EndIf
						Next nx
					EndIf

					For nx := 1 to Len(aGetCpos)
						cCpo	:= "M->"+Trim(aGetCpos[nx][1])
						&cCpo	:= aProjetos[nLoop][2]
					Next nx
				EndIf
			Else
				lOk:=.F.
				lContinua:=.F.
			EndIf
		EndIf
	Next nLoop

	AF8->(DbGoTo(nAF8Recno))

	If lContinua
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM 000, 000  TO 500, 700 COLORS 0, 16777215 PIXEL
		MsMGet():New("AFK",,3,,,,aGetEnch2,{035,003,100,350},aGetEnch2,3,,,,,,,.F.,,,.T.)
		oGetMt:=MSNewGetDados():New(110,003,250,350,GD_UPDATE,"PM220LINOK","PM220TUDOK",,aAlter,,,,,,,aHeader,aCols)
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(PM220TudOk(),(lOk:=.T.,oDlg:End()),Nil)},{||oDlg:End()},,If(!lATInclui,aButtons,Nil)) CENTERED
	EndIf

	If lOk .And. lATInclui
		nTamaCol := Len(oGetMt:aCols)
		For nX := 1 To nTamaCol
			M->AFK_PLANEJ := aPlanej[nTamaCol+1-nX]
			For nY := 1 to Len(aHeader)-1
				cCpo  := "M->"+Trim(aHeader[nY][2])
				&cCpo := oGetMt:aCols[nX][nY]
			Next nY
			PMS220WrAT(.F.,{},{},{},,,aCols,nX)
		Next nX
	Else
		For nLoop:=1 to Len(aProjetos)
			RollBackSX8()
		Next nLoop
	EndIf

	// Posiciona o registo da tabela AFK no projeto corrente
	nLoop := aScan( aProjetos,{|aX| aX[2] == AF8->AF8_PROJET })
	If nLoop > 0 .and. len(aProjetos[nLoop]) == 4
		If aProjetos[nLoop][4]>0
			AFK->(dbGoto( aProjetos[nLoop][4] ))
		EndIf
	EndIf
EndIf

// retorna ao registro original
AF8->(dbGoto(nAF8Recno))

RestArea(aAreaAFM)
RestArea(aAreaAFG)
RestArea(aAreaAFH)
RestArea(aArea)

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS220WrAT³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a gravacao do Planejamento da execucao do Projeto.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS220WrAT(lExclui,aRecSC1,aRecSC2,aRecAFJ,lDeleta,aRecSC7,aProjProd,nVez,aRecAFA,aAtuAFJ)
Local nx
Local nY		:= 0
Local nPosAFJ	:= 0
Local aLinha	:= {}
Local aCabSC	:= {}
Local aItensSC	:= {}
Local aArrayOP	:= {}
Local bCampo 	:= {|n| FieldName(n) }
Local aArea		:= GetArea()
Local lOk		:= .T.
Local aCabSC7   := {}
Local aLinSC7	:= {}
Local aItemSC7	:= {}
Local nLenAFA	:= 0

Default aRecAFA	:= {}
Default aAtuAFJ	:= {}

nLenAFA	:= Len(aRecAFA)

If !lExclui
	If !Empty(aProjProd) //Deve fazer o seek apenas no gerar multiplo
		dbSelectArea("AF8")
		dbSetOrder(1)
		MsSeek(xFilial("AF8")+aProjProd[nVez,1])
	EndIf
	If AF8ComAJT( AF8->AF8_PROJET )
		dbSelectArea("AF9")
		dbSetOrder(1)
		MsSeek(xFilial("AF9")+AF8->AF8_PROJET+AF8->AF8_REVISA+M->AFK_TRFDE,.T.)
		While lOk .And. !Eof() .And. xFilial("AF9")+AF8->AF8_PROJET+AF8->AF8_REVISA==;
							AF9->AF9_FILIAL+AF9_PROJET+AF9->AF9_REVISA .And. AF9->AF9_TAREFA <= M->AFK_TRFATE
			If !PMSChkNec(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA)
				lOk:=.F.
			EndIf
			dbSelectArea("AF9")
			dbSkip()
		EndDo
	EndIf
	If lOk
		Begin Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa a gravacao do arquivo AFK                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("AFK",.T.)
		For nx := 1 TO FCount()
			FieldPut(nx,M->&(EVAL(bCampo,nx)))
		Next nx
		AFK->AFK_FILIAL := xFilial("AFK")
		MsUnlock()
		IF __lSX8
			ConfirmSX8()
		Endif

		End Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa a atualizacao dos arquivos de SC/SA/OPs,Empenhos     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PMSPlExec("AF8",AF8->(RecNo()),M->AFK_PLANEJ)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a existencia de e-mails para o evento 025       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//MEnviaMail("025",{AllTrim(AF8->AF8_PROJET)+"-"+Alltrim(AF8->AF8_DESCRI),UsrRetName(RetCodUsr()),M->AFK_PLANEJ})
	EndIf
Else
	Begin Transaction

	If ExistBlock("PMA220WR")
		If !ExecBlock("PMA220WR")
			RestArea(aArea)
			Return
		EndIf
	EndIf
	For nx := 1 to len(aRecSC1)
		PMSIncProc(.T.,1)
		SC1->(dbGoto(aRecSC1[nx]))
		If SC1->(!Deleted())
			aCabSC := {}
			aadd(aCabSC ,{"C1_NUM",SC1->C1_NUM,Nil})
			aadd(aCabSC ,{"C1_SOLICIT",SC1->C1_SOLICIT,Nil})
			aadd(aCabSC ,{"C1_EMISSAO",SC1->C1_EMISSAO,Nil})
			aadd(aCabSC ,{"C1_TPOP",SC1->C1_TPOP,Nil})

			aItensSC := {}
			aLinha := {}
			aadd(aLinha ,{"LINPOS","C1_ITEM",SC1->C1_ITEM})
			aadd(aLinha ,{"AUTDELETA","S",Nil})
			aadd(aItensSC ,aLinha)

			IF AFK->AFK_TPPLAN == "1"
				MATA110(aCabSC ,aItensSC ,4)				
				A220EAFG( AFK->AFK_PLANEJ , SC1->C1_NUM , SC1->C1_ITEM )
			Else
				MATA110(aCabSC ,aItensSC ,5)
			Endif

		EndIf
	Next
	For nx := 1 to Len(aRecSC7)
		PMSIncProc(.T.,1)
		SC7->(dbGoto(aRecSC7[nx]))
		If !SC7->(Deleted())
			aCabSC7 := {}
			aadd(aCabSC7,{"C7_FILIAL" , SC7->C7_FILIAL	})
			aadd(aCabSC7,{"C7_NUM"    , SC7->C7_NUM		})
			aadd(aCabSC7,{"C7_SEQUEN" , SC7->C7_SEQUEN	})
			aadd(aCabSC7,{"INDEX"	  , 1})    // INDICE NECESSARIO PARA ROTINA AUTOMATICA DA MATA120 - MBROWSEAUTO() --> C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN

			aadd(aCabSC7,{"C7_NUMSC"  , SC7->C7_NUMSC		})
			aadd(aCabSC7,{"C7_EMISSAO", SC7->C7_EMISSAO	})
			aadd(aCabSC7,{"C7_ITEM",SC7->C7_ITEM,Nil		})
			aadd(aCabSC7,{"C7_PRODUTO",SC7->C7_PRODUTO,Nil})
			aadd(aCabSC7,{"C7_QUANT",SC7->C7_QUANT,Nil	})

			DbSelectArea("AFL")
			DbSetOrder(2)
			If AFL->(DbSeek(xFilial("AFL")+SC7->(C7_NUMSC+C7_ITEMSC)))
				PmsAvalAFL("AFL",3)
			EndIf

			MATA120(2,aCabSC7,aItemSC7,5)
		EndIf
	Next
	For nx := 1 to len(aRecAFJ)
		PMSIncProc(.T.,1)
		AFJ->(dbGoto(aRecAFJ[nx]))
		If AFJ->(!Deleted())
			nPosAFJ := aScan(aAtuAFJ, {|x| AllTrim(x[1]) == AllTrim(AFJ->AFJ_COD)})
			If nPosAFJ <> 0
				PmsAtuEmp(AFJ->AFJ_PROJET,AFJ->AFJ_TAREFA,AFJ->AFJ_COD,AFJ->AFJ_LOCAL,AFJ->AFJ_QEMP-aAtuAFJ[nPosAFJ][2],"-",.T.,AFJ->AFJ_QEMP2-ConvUm(aAtuAFJ[nPosAFJ][2],0,2),AFJ->AFJ_TRT)
			Else
				PmsAvalAFJ("AFJ",2)
				PmsAvalAFJ("AFJ",3)
			EndIf
		EndIf
	Next nx

	If !AF8ComAJT( AFK->AFK_PROJET ) 
		For nY := 1 to nLenAFA
			PMSIncProc(.T.,1)
			AFA->(dbGoto(aRecAFA[nY]))
			If AFA->(!Deleted())
				RecLock("AFA",.F.)
				AFA->AFA_PLANEJ := " "
				MsUnlock()
			EndIf
		Next nY
	Else
		DbSelectArea( "AEL" )
		AEL->( DbSetOrder( 3 ) ) // AEL_FILIAL+AEL_PLANEJ
		Do While AEL->( DbSeek( xFilial( "AEL" ) + AFK->AFK_PLANEJ ) )
			PMSIncProc( .T., 1 )
			RecLock( "AEL", .F. )
			AEL->AEL_PLANEJ := " "
			MsUnlock()
		EndDo
		DbSelectArea( "AEN" )
		AEN->( DbSetOrder( 2 ) ) // AEN_FILIAL+AEN_PLANEJ
		Do While AEN->( DbSeek( xFilial( "AEN" ) + AFK->AFK_PLANEJ ) )
			PMSIncProc( .T., 1 )
			RecLock( "AEN", .F. )
			AEN->AEN_PLANEJ := " "
			MsUnlock()
		EndDo
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a exclusao do arquivo AFK                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lDeleta
	RecLock("AFK",.F.,.T.)
	dbDelete()
	MsUnlock()
	EndIf
	End Transaction
EndIf

For nx := 1 to len(aRecSC2)
	PMSIncProc(.T.,1)
	SC2->(dbGoto(aRecSC2[nx]))
	If SC2->(!Deleted())
		aArrayOP := {	{"C2_NUM",SC2->C2_NUM,Nil},;
						{"C2_ITEM",SC2->C2_ITEM,Nil},;
						{"C2_SEQUEN",SC2->C2_SEQUEN,Nil}}
		MATA650(aArrayOP,5)
	EndIf
Next nx

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PmsPl220SC³ Autor ³ Edson Maricate        ³ Data ³23.11.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria uma tela de consulta das Solicitacoes do Planejamento   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Planejamento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Materiais                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PmsPl220SC(cPlanej)

Local oDlg
Local cNumSC
Local cItemSC
Local aArea		:= GetArea()
Local aAreaAFG	:= AFG->(GetArea())
Local aAreaAFK	:= AFK->(GetArea())
Local aAreaSC1	:= SC1->(GetArea())
Local aViewSC	:= {}


SC1->(dbSetOrder(1))
AFK->(dbSetOrder(1))
AFK->(dbSeek(xFilial()+cPlanej))

dbSelectArea('AFG')
dbSetOrder(3)
If MsSeek(xFilial()+cPlanej)
	While !Eof().And.AFG->AFG_FILIAL+AFG->AFG_PLANEJ==xFilial("AFG")+cPlanej
		cNumSC	:= AFG->AFG_NUMSC
		cItemSC	:= AFG->AFG_ITEMSC
		dbSelectArea("SC1")
		dbSeek(PmsFilial("SC1","AFG")+cNumSC+cItemSC)
		aAdd(aViewSC,{C1_NUM,C1_ITEM,C1_PRODUTO+"-"+C1_DESCRI,TransForm(C1_QUANT,PesqPict("SC1","C1_QUANT")),TransForm(C1_QUJE,PesqPict("SC1","C1_QUJE")),C1_DATPRF})
		dbSelectArea("AFG")
		While !Eof().And.AFG->AFG_FILIAL+AFG->AFG_PLANEJ+AFG->AFG_NUMSC+AFG->AFG_ITEMSC==xFilial("AFG")+cPlanej+cNumSC+cItemSC
			dbSkip()
		End
	End
	DEFINE MSDIALOG oDlg FROM 85,35 to 325,605 TITLE cCadastro Of oMainWnd PIXEL
		oListBox := TWBrowse():New( 30,1,284,85,,{STR0028,STR0029,STR0030,STR0031,STR0032,STR0033},,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)  //"Num.SC"###"Item SC"###"Produto"###"Quantidade"###"Qtde. Entregue"###"Necessidade"
		oListBox:SetArray(aViewSC)
		oListBox:bLine := { || aViewSC[oListBox:nAT]}
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,{{"BMPINCLUIR",{||MaViewSC(aViewSC[oListBox:nAT][1])},STR0056}} ) //"Detalhes"

Else
	Aviso(STR0035,STR0036,{STR0037},2) //"Atencao"###"Nao existem Solicitacoes de Compras geradas para este planejamento."###"Voltar"
EndIf

RestArea(aAreaAFG)
RestArea(aAreaAFK)
RestArea(aAreaSC1)
RestArea(aArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PmsPl220SA³ Autor ³ Edson Maricate        ³ Data ³23.11.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria uma tela de consulta das Solicitacoes do Planejamento   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Planejamento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Materiais                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PmsPl220SA(cPlanej)

Local oDlg
Local oBold
Local cNumSA
Local cItemSA
Local aArea		:= GetArea()
Local aAreaAFH	:= AFH->(GetArea())
Local aAreaAFK	:= AFK->(GetArea())
Local aAreaSCP	:= SCP->(GetArea())
Local aViewSA	:= {}


SCP->(dbSetOrder(1))
AFK->(dbSetOrder(1))
AFK->(dbSeek(xFilial()+cPlanej))

dbSelectArea('AFH')
dbSetOrder(3)
If MsSeek(xFilial()+cPlanej)
	While !Eof().And.AFH->AFH_FILIAL+AFH->AFH_PLANEJ==xFilial("AFH")+cPlanej
		cNumSA	:= AFH->AFH_NUMSA
		cItemSA	:= AFH->AFH_ITEMSA
		dbSelectArea("SCP")
		dbSeek(PmsFilial("SCP","AFH")+cNumSA+cItemSA)
		aAdd(aViewSA,{CP_NUM,CP_ITEM,CP_PRODUTO+"-"+CP_DESCRI,TransForm(CP_QUANT,PesqPict("SCP","CP_QUANT")),TransForm(CP_QUJE,PesqPict("SCP","CP_QUJE")),CP_DATPRF})
		dbSelectArea("AFH")
		While !Eof().And.AFH->AFH_FILIAL+AFH->AFH_PLANEJ+AFH->AFH_NUMSA+AFH->AFH_ITEMSA==xFilial("AFH")+cPlanej+cNumSA+cItemSA
			dbSkip()
		End
	End
	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
	DEFINE MSDIALOG oDlg FROM 0,0  TO 340,600 TITLE cCadastro Of oMainWnd PIXEL
		@ 13, 4 To 14,302 Label "" of oDlg PIXEL
		oListBox := TWBrowse():New( 20,2,298,130,,{STR0038,STR0039,STR0030,STR0031,STR0032,STR0033},,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Num.SA"###"Item SA"###"Produto"###"Quantidade"###"Qtde. Entregue"###"Necessidade"
		oListBox:SetArray(aViewSA)
		oListBox:bLine := { || aViewSA[oListBox:nAT]}
		@ 4  ,10   SAY Alltrim(cPlanej)+"-"+AFK->AFK_DESCRI Of oDlg PIXEL SIZE 245 ,9 FONT oBold
		@ 157 ,194  BUTTON STR0003 SIZE 45 ,10  FONT oDlg:oFont ACTION MaViewSA(aViewSA[oListBox:nAT][1]) OF oDlg PIXEL //"Visualizar"
		@ 157 ,244  BUTTON STR0034 SIZE 45 ,10  FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL //"Sair"
	ACTIVATE MSDIALOG oDlg CENTERED

Else
	Aviso(STR0035,STR0040,{STR0037},2) //"Atencao"###"Nao existem Solicitacoes ao Almoxarifado geradas para este planejamento."###"Voltar"
EndIf

RestArea(aAreaAFH)
RestArea(aAreaAFK)
RestArea(aAreaSCP)
RestArea(aArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PmsPl220EM³ Autor ³ Edson Maricate        ³ Data ³23.11.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria uma tela de consulta dos Empenhos do Planejamento.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Planejamento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Materiais                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function yPmsPl220EM(cPlanej)

Local oDlg
Local oBold
Local aArea		:= GetArea()
Local aAreaAFJ	:= AFJ->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local aViewEM	:= {}


SB1->(dbSetOrder(1))
AFK->(dbSetOrder(1))
AFK->(dbSeek(xFilial()+cPlanej))

dbSelectArea('AFJ')
dbSetOrder(4)
If MsSeek(xFilial()+cPlanej)
	While !Eof().And.AFJ->AFJ_FILIAL+AFJ->AFJ_PLANEJ==xFilial("AFJ")+cPlanej
		SB1->(dbSeek(xFilial()+AFJ->AFJ_COD))
		aAdd(aViewEM,{AFJ_COD,SB1->B1_DESC,AFJ_LOCAL,TransForm(AFJ_QEMP,PesqPict("AFJ","AFJ_QEMP")),TransForm(AFJ_QATU,PesqPict("AFJ","AFJ_QATU"))})
		dbSelectArea("AFJ")
		dbSkip()
	End
	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
	DEFINE MSDIALOG oDlg FROM 0,0  TO 340,600 TITLE cCadastro Of oMainWnd PIXEL
		@ 13, 4 To 14,302 Label "" of oDlg PIXEL
		oListBox := TWBrowse():New( 20,2,298,130,,{STR0041,STR0042,STR0043,STR0044,STR0090},,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Codigo"###"Descricao"###"Local"###"Qtde. Emp."###"Saldo" //"Qtde. Atual"
		oListBox:SetArray(aViewEM)
		oListBox:bLine := { || aViewEM[oListBox:nAT]}
		@ 4  ,10   SAY Alltrim(cPlanej)+"-"+AFK->AFK_DESCRI Of oDlg PIXEL SIZE 245 ,9 FONT oBold
		@ 157 ,244  BUTTON STR0034 SIZE 45 ,10  FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL //"Sair"
	ACTIVATE MSDIALOG oDlg CENTERED
Else
	Aviso(STR0035,STR0047,{STR0037},2) //"Atencao"###"Nao existem Empenhos gerados para este planejamento."###"Voltar"
EndIf

RestArea(aAreaAFJ)
RestArea(aAreaSB1)
RestArea(aArea)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS220CP³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Visualizacao dos Contratos de Parceria vinculados ³±±
±±³          ³ao Projeto.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS220CP(oTree,lVisual,cArquivo)
Local cAlias
Local nRecView
Local aArea		:= GetArea()
Local aSize		:= MsAdvSize(,.F.,430)
Local aRotina		:= {}
Local lHabVis 	:= .T.
Local lHabInc		:= .T.
Local lHabAlt		:= .T.
Local lHabExc		:= .T.
Local lContinua	:= .T.

If ExistBlock("PMA220CP")
	If !ExecBlock("PMA220CP")
		lContinua	:= .F.
	EndIf
EndIf

If lContinua
	If oTree == Nil
		cAlias	:= (cArquivo)->ALIAS
		nRecView	:= (cArquivo)->RECNO
	Else
		cAlias	:= SubStr(oTree:GetCargo(),1,3)
		nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
	EndIf

	A220ValOp(cAlias,nRecView,"GERCP",@lHabVis,@lHabInc,@lHabAlt,@lHabExc)

	aRotina   := If(lVisual,{{STR0003,"A220toCP", 0 , 2,,lHabVis}},	{{ STR0003,"A220toCP", 0 , 2,  ,lHabVis},; //"Visualizar"
																		 { STR0016,"A220toCP", 0 , 3,  ,lHabInc},;	 //"Incluir"
																		 { STR0017,"A220toCP", 0 , 4,  ,lHabAlt},;	 //"Alterar"
																		 { STR0014,"A220toCP", 0 , 5, 1,lHabExc} } )//"Excluir"

	If cAlias == "AF9" .And. nRecView<>0
		AF9->(dbGoto(nRecView))
		_cTarefa := AF9->AF9_TAREFA   //variavel utilizada x3_relacao Funcao PmsCpoInic()
		AFL->(dbSetOrder(1))
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5] ,cCadastro+STR0048+AllTrim(AF9->AF9_PROJET)+"/"+AF9->AF9_TAREFA+"]","AFL",,aRotina,,; //" - CP -["
		'xFilial("AFL")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
		'xFilial("AFL")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
		.F.,,,{{STR0069,1},{STR0089,5}},xFilial("AFL")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA) //"Numero do CP + Item do CP" //"Codigo do Produto"
	ElseIf cAlias == "AF8" .And. nRecView<>0
		AF8->(dbGoto(nRecView))
		_cTarefa := Space(Len(AF9->AF9_TAREFA))   //variavel utilizada x3_relacao Funcao PmsCpoInic()
		AFL->(dbSetOrder(1))
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0048+AllTrim(AF8->AF8_PROJET)+"]","AFL",,aRotina,,; //" - CP -["
		'xFilial("AFL")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
		'xFilial("AFL")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
		.F.,,,{{STR0070,1},{STR0089,6}},xFilial("AFL")+AF8->AF8_PROJET+AF8->AF8_REVISA) //"Tarefa + Numero do CP + Item do CP" //"Codigo do Produto"
	EndIf
EndIf
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A220toCP³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Atualizacao dos Contratos vinculados ao Projeto.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A220toCP(cAlias,nReg,nOpcx)
Local aArea	:= GetArea()
Local cFilSC3 		:= ""
Local cFilOldSC3 	:= ""

Do Case
	Case nOpcx == 1

	 	cFilSC3 	:= PmsFilial("SC3","AFL")
		cFilOldSC3  := cFilAnt
		If cFilSC3 <> ""
			cFilAnt 	:= cFilSC3
		EndIf

		SC3->(dbSetOrder(1))
		If SC3->(dbSeek(xFilial()+AFL->AFL_NUMCP))
			MATA125(,,2)
		EndIf

		cFilAnt		:=	cFilOldSC3

	Case nOpcx == 2
		MATA125(,,3)

	Case nOpcx == 3

	 	cFilSC3 	:= PmsFilial("SC3","AFL")
		cFilOldSC3  := cFilAnt
		If cFilSC3 <> ""
			cFilAnt 	:= cFilSC3
		EndIf

		SC3->(dbSetOrder(1))
		If SC3->(dbSeek(xFilial()+AFL->AFL_NUMCP))
			MATA125(,,4)
		EndIf

		cFilAnt		:=	cFilOldSC3

	Case nOpcx == 4

	 	cFilSC3 	:= PmsFilial("SC3","AFL")
		cFilOldSC3  := cFilAnt
		If cFilSC3 <> ""
			cFilAnt 	:= cFilSC3
		EndIf

		SC3->(dbSetOrder(1))
		If SC3->(dbSeek(xFilial()+AFL->AFL_NUMCP))
			MATA125(,,5)
		EndIf

		cFilAnt		:=	cFilOldSC3

EndCase

RestArea(aArea)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS220OP³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Visualizacao das Ordens de Producao vinculadas    ³±±
±±³          ³ao Projeto.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS220OP(oTree,lVisual,cArquivo)

Local aArea		:= GetArea()
Local cAlias
Local nRecView
Local aSize		:= MsAdvSize(,.F.,430)
Local aRotina		:= {}
Local lHabVis		:= .T.
Local lHabInc		:= .T.
Local lHabAlt		:= .T.
Local lHabExc		:= .T.
Local lContinua	:= .T.

If ExistBlock("PMA220OP")
	If !ExecBlock("PMA220OP")
		lContinua	:= .F.
	EndIf
EndIf

If lContinua
	If oTree == Nil
		cAlias	:= (cArquivo)->ALIAS
		nRecView	:= (cArquivo)->RECNO
	Else
		cAlias	:= SubStr(oTree:GetCargo(),1,3)
		nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
	EndIf

	A220ValOp(cAlias,nRecView,"GEROP",@lHabVis,@lHabInc,@lHabAlt,@lHabExc)

	aRotina   := If(lVisual,{{STR0003,"A220toOP", 0 , 2, ,lHabVis}}, {	{ STR0003,"A220toOP", 0 , 2,  ,lHabVis},; //"Visualizar"
																		{ STR0016,"A220toOP", 0 , 3,  ,lHabInc},;	 //"Incluir"
																		{ STR0017,"A220toOP", 0 , 4,  ,lHabAlt},;	 //"Alterar"
																		{ STR0014,"A220toOP", 0 , 5, 1,lHabExc} } )//"Excluir"


	If cAlias == "AF9" .And. nRecView<>0
		AF9->(dbGoto(nRecView))
		_cTarefa := AF9->AF9_TAREFA   //variavel utilizada x3_relacao Funcao PmsCpoInic()
		AFM->(dbSetOrder(1))
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5] ,cCadastro+STR0049+AllTrim(AF9->AF9_PROJET)+"/"+AF9->AF9_TAREFA+"]","AFM",,aRotina,,; //" - OP -["
		'xFilial("AFM")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
		'xFilial("AFM")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
		.F.,,,{{STR0071,1},{STR0089,5}},xFilial("AFM")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA) //"Numero da OP + Item da OP + Seq. OP" //"Codigo do Produto"
	ElseIf cAlias == "AF8" .And. nRecView<>0
		AF8->(dbGoto(nRecView))
		_cTarefa := Space(Len(AF9->AF9_TAREFA))   //variavel utilizada x3_relacao Funcao PmsCpoInic()
		AFM->(dbSetOrder(1))
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0049+AllTrim(AF8->AF8_PROJET)+"]","AFM",,aRotina,,; //" - OP -["
		'xFilial("AFM")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
		'xFilial("AFM")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
		.F.,,,{{STR0072,1},{STR0089,6}},xFilial("AFM")+AF8->AF8_PROJET+AF8->AF8_REVISA) //"Tarefa + Numero da OP + Item da OP + Seq. OP" //"Codigo do Produto"
	EndIf
EndIf
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A220toOP³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Atualizacao dao OPs vinculadas ao Projeto.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A220toOP(cAlias,nReg,nOpcx)
Local aArea		:= GetArea()
Local cFilSC2 	:= ""
Local cFilOldSC2 	:= ""
Local aAuxHead	:= {}

PRIVATE Inclui
PRIVATE Altera

Do Case
	Case nOpcx == 1
		Inclui := .F.
		Altera := .F.

 		cFilSC2 		:= PmsFilial("SC2","AFM")
		cFilOldSC2  := cFilAnt
		If cFilSC2 <> ""
			cFilAnt 	:= cFilSC2
		EndIf

		SC2->(dbSetOrder(1))
		If SC2->(dbSeek(xFilial()+AFM->AFM_NUMOP+AFM->AFM_ITEMOP+AFM->AFM_SEQOP))
			MATA650(,2)
		EndIf

		cFilAnt		:=	cFilOldSC2

	Case nOpcx == 2
		Inclui := .T.
		Altera := .F.
		aAuxHead	:= aHeader
		aHeader := {}
		MATA650(,3)
		aHeader := aAuxHead

	Case nOpcx == 3
		Inclui := .F.
		Altera := .T.

 		cFilSC2 		:= PmsFilial("SC2","AFM")
		cFilOldSC2  := cFilAnt
		If cFilSC2 <> ""
			cFilAnt 	:= cFilSC2
		EndIf

		SC2->(dbSetOrder(1))
		If SC2->(dbSeek(xFilial()+AFM->AFM_NUMOP+AFM->AFM_ITEMOP+AFM->AFM_SEQOP))
			MATA650(,4)
		EndIf

		cFilAnt		:=	cFilOldSC2

	Case nOpcx == 4
		Inclui := .F.
		Altera := .F.

 		cFilSC2 		:= PmsFilial("SC2","AFM")
		cFilOldSC2  := cFilAnt
		If cFilSC2 <> ""
			cFilAnt 	:= cFilSC2
		EndIf

		SC2->(dbSetOrder(1))
		If SC2->(dbSeek(xFilial()+AFM->AFM_NUMOP+AFM->AFM_ITEMOP+AFM->AFM_SEQOP))
			MATA650(,5)
		EndIf

		cFilAnt		:=	cFilOldSC2

EndCase

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS220EM³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Visualizacao das Ordens de Producao vinculadas    ³±±
±±³          ³ao Projeto.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS220EM(oTree,lVisual,cArquivo)

Local aArea		:= GetArea()
Local cAlias
Local nRecView
Local aSize		:= MsAdvSize(,.F.,430)
Local lHabVis 	:= .T.
Local lHabInc		:= .T.
Local lHabAlt		:= .T.
Local lHabExc		:= .T.
Local lContinua	:= .T.

PRIVATE aRotina   := {}

If ExistBlock("PMA220EM")
	If !ExecBlock("PMA220EM")
		lContinua	:= .F.
	EndIf
EndIf

If lContinua
	If oTree == Nil
		cAlias	:= (cArquivo)->ALIAS
		nRecView	:= (cArquivo)->RECNO
	Else
		cAlias	:= SubStr(oTree:GetCargo(),1,3)
		nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
	EndIf

	A220ValOp(cAlias,nRecView,"GEREMP",@lHabVis,@lHabInc,@lHabAlt,@lHabExc)

	aRotina := If(lVisual,{{ STR0003,"AxVisual", 0 , 2, ,lHabVis}}, {	{ STR0003,"A220AtuEmp", 0 , 2,  ,lHabVis},; //"Visualizar"
																				{ STR0016,"A220AtuEmp", 0 , 3,  ,lHabInc},;	 //"Incluir"
																				{ STR0017,"A220AtuEmp", 0 , 4,  ,lHabAlt},;	 //"Alterar"
																				{ STR0014,"A220AtuEmp", 0 , 5, 1,lHabExc} }  )//"Excluir"


	If cAlias == "AF9" .And. nRecView<>0
		AF9->(dbGoto(nRecView))
		_cTarefa := AF9->AF9_TAREFA   //variavel utilizada x3_relacao Funcao PmsCpoInic()
		AFJ->(dbSetOrder(1))
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5] ,cCadastro+STR0050+AllTrim(AF9->AF9_PROJET)+"/"+AF9->AF9_TAREFA+"]","AFJ",,aRotina,,; //" - Empenhos -["
		'xFilial("AFJ")+AF9->AF9_PROJET+AF9->AF9_TAREFA',;
		'xFilial("AFJ")+AF9->AF9_PROJET+AF9->AF9_TAREFA',;
		.F.,,,{{STR0073,1}},xFilial("AFJ")+AF9->AF9_PROJET+AF9->AF9_TAREFA) //"Codigo do Produto + Armazem"
	ElseIf cAlias == "AF8" .And. nRecView<>0
		AF8->(dbGoto(nRecView))
		_cTarefa := Space(Len(AF9->AF9_TAREFA))   //variavel utilizada x3_relacao Funcao PmsCpoInic()
		AFJ->(dbSetOrder(1))
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0050+AllTrim(AF8->AF8_PROJET)+"]","AFJ",,aRotina,,; //" - Empenhos -["
		'xFilial("AFJ")+AF8->AF8_PROJET',;
		'xFilial("AFJ")+AF8->AF8_PROJET',;
		.F.,,,{{STR0074,1},{STR0073,5}},xFilial("AFJ")+AF8->AF8_PROJET) //"Tarefa + Codigo do Produto + Armazem"
	EndIf
EndIf
RestArea(aArea)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A220AtuEmp³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de inclusao/Alteracao/Visualizacao/Exclusao de       ³±±
±±³          ³Empenhos do Projeto.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA220                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A220AtuEmp(cAlias,nRecNo,nOpcx)

Local aButtons 	:= {}
Local aGetCpo
Local l220Altera	:= .F.
Local l220Exclui	:= .F.
Local l220Inclui	:= .F.
Local l220Visual	:= .F.
Local lContinua	:= .T.
Local lGravaOk	:= .F.
Local lRet			:= .F.
Local nRecAFJ
Local oDlg
Local oEnch

PRIVATE aTELA[0][0],aGETS[0]
PRIVATE 	cSavScrVT,;
			cSavScrVP,;
			cSavScrHT,;
			cSavScrHP,;
			CurLen,;
			nPosAtu:=0,;
			nPosAnt:=9999,;
			nColAnt:=9999

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case aRotina[nOpcx][4] == 2 // visualizar
		l220Visual := .T.
	Case aRotina[nOpcx][4] == 3 // incluir
		l220Inclui	:= .T.
		aGetCpo		:= {"AFJ_PROJET","AFJ_QEMP","AFJ_LOCAL","AFJ_TAREFA","AFJ_COD","AFJ_QEMP2","AFJ_DATA"}
	Case aRotina[nOpcx][4] == 4 // alterar
		l220Altera	:= .T.
		aGetCpo		:= {"AFJ_QEMP","AFJ_QEMP2"}
	Case aRotina[nOpcx][4] == 5 // excluir
		l220Exclui	:= .T.
		l220Visual	:= .T.
EndCase

dbSelectArea("AFJ")
RegToMemory("AFJ",l220Inclui)
//Inicializa Tarefa na inclusão
If l220Inclui
	M->AFJ_TAREFA := AF9->AF9_TAREFA
EndIf

If l220Inclui
	M->AFJ_ROTGER := "5" // define o empenho como manual
	If !Empty(M->AFJ_TAREFA)
		Pms220Trf() // gera a sequencia de empenho
	EndIf
EndIf

If !l220Inclui
	If !SoftLock("AFJ")
		lContinua := .F.
	Else
		nRecAFJ := AFJ->(RecNo())
	Endif
EndIf

If lContinua .AND. (l220Altera .OR. l220Exclui)

	// se for um planejamento, não altera ou exclui
	If !Empty(AFJ->AFJ_PLANEJ) .And. l220Exclui
		Aviso(STR0035,STR0102,{STR0034},2) // "Atencao" ## "Esta opção não pode ser acessada quando um empenho foi gerado através de um planejamento" ## "Sair"
		lContinua := .F.
	ElseIf !Empty(AFJ->AFJ_PLANEJ)
		aGetCpo := {}
	EndIf

	// se houve movimentacao no empenho.
	If lContinua .AND. AFJ->AFJ_QATU > 0 .And. l220Exclui
		Aviso(STR0035,STR0111,{STR0100},2) //"Atencao" ## "OK"
		lContinua := .F.
	ElseIf AFJ->AFJ_QATU > 0
		aGetCpo := {}
	EndIf

	// permite alterar a data de necessidade e/ou local armazem somente para
	// empenhos manuais, isto é, empenhos gerados do estoque
	If l220Altera .AND. M->AFJ_ROTGER == "5"
		aAdd(aGetCpo ,"AFJ_DATA")
		aAdd(aGetCpo ,"AFJ_LOCAL")
    EndIf

    If !l220Exclui
		aAdd(aButtons,{'ESTOMOVI',{|| A220Zera(nRecAFJ) },STR0114,STR0115}) //###"Zerar Empenho" //"Zerar empenho selecionado"
    EndIf
EndIf

If lContinua
	DEFINE MSDIALOG oDlg TITLE STR0075 FROM 8,0 TO 40,150 OF oMainWnd //"Gerenciamento de Empenhos"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula dimensões                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize := FwDefSize():New(.T.,,,oDlg)
	oSize:AddObject( "CABECALHO",  100, 100, .T., .T. ) // Totalmente dimensionavel
	
	oSize:lProp 	:= .T. // Proporcional             
	oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

	oSize:Process() 	   // Dispara os calculos
	
	nLinIni:= oSize:GetDimension("CABECALHO","LININI")
	nColIni:= oSize:GetDimension("CABECALHO","COLINI")
	nLinEnd:= oSize:GetDimension("CABECALHO","LINEND")
	nColEnd:= oSize:GetDimension("CABECALHO","COLEND")
	
	oEnch := MsMGet():New(cAlias,nRecNo,nOpcx,,,,, {nLinIni,nColIni,nLinEnd,nColEnd},aGetCpo,3,,,,oDlg)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg ;
	                                           ,{||iIf(a220VldEm(l220Inclui, l220Visual, l220Altera, l220Exclui, aGets, aTela),(lGravaOk:=.T.,oDlg:End()),NIL)};
	                                           ,{||oDlg:End()},,aButtons) CENTERED

EndIf

If (l220Inclui .Or. l220Altera .Or. l220Exclui ).And. lGravaOk
	Begin Transaction
		PMS220Grava(l220Exclui,nRecAFJ)
	End Transaction
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Destrava Todos os Registros                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsUnLockAll()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a220VldEm³ Autor ³ Reynaldo Miyashita     ³ Data ³ 13-08-2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina para validar na dialog de gerenciamento de empenhos do ³±±
±±³          ³Projeto.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA220                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function a220VldEm(l220Inclui, l220Visual, l220Altera, l220Exclui, aGets, aTela)
Local lRet := .T.
Local lRetBlock // variavel que vai conter o retorno

	// se não for exclusão, valida os campos da dialog
	If !l220Exclui
		lRet := Obrigatorio(aGets,aTela)
	EndIf

	If ExistBlock("PMAEmpVld")
		lRetBlock := ExecBlock("PMAEmpVld", .F., .F. ,{l220Inclui, l220Visual, l220Altera, l220Exclui})
		If ValType(lRet)=="L"
			lRet := lRetBlock
		EndIf
	EndIf

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS220Grava³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Gravacao dos Empenhos do Projeto.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS220Grava(lDeleta,nRecAFJ)

Local bCampo 	:= {|n| FieldName(n) }
Local aArea		:= GetArea()
Local nx := 0

If !lDeleta
	If nRecAFJ <> Nil
		AFJ->(dbGoto(nRecAFJ))
		PmsAvalAFJ("AFJ",2)
		RecLock("AFJ",.F.)
	Else
		RecLock("AFJ",.T.)
	EndIf
	For nx := 1 TO FCount()
		FieldPut(nx,M->&(EVAL(bCampo,nx)))
	Next nx
	AFJ->AFJ_FILIAL	:= xFilial("AFJ")
	MsUnlock()
	PmsAvalAFJ("AFJ",1)
Else
	AFJ->(dbGoto(nRecAFJ))
	PmsAvalAFJ("AFJ",2)
	PmsAvalAFJ("AFJ",3)
EndIf

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms220Prj³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao do codigo do Projeto igitado.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA220                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms220Prj()
Local aArea	:= GetArea()

M->AFJ_TAREFA := SPACE(LEN(AFJ->AFJ_TAREFA))
lRet := ExistCpo("AF8")

RestArea(aArea)
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms220Trf³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao do codigo da tarefa digitado.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA220                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms220Trf()
Local aArea	:= GetArea()

dbSelectArea("AF8")
dbSetOrder(1)
dbSeek(xFilial("AF8")+M->AFJ_PROJET)
lRet := ExistCpo("AF9",AF8->AF8_PROJET+AF8->AF8_REVISA+M->AFJ_TAREFA,1)

If lRet
	M->AFJ_TRT	:= PmsPrxEmp(AF8->AF8_PROJET,,M->AFJ_TAREFA)
EndIf

RestArea(aArea)
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PmsPl220OP³ Autor ³ Edson Maricate        ³ Data ³23.11.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria uma tela de consulta das Ordens de Producao do Planej.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Planejamento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Materiais                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PmsPl220OP(cPlanej)

Local oDlg

Local cNumOP
Local aArea		:= GetArea()
Local aAreaSC2	:= SC2->(GetArea())
Local aAreaAFM	:= AFM->(GetArea())
Local aAreaAFK	:= AFK->(GetArea())
Local aViewOP	:= {}


SC2->(dbSetOrder(1))
AFK->(dbSetOrder(1))
AFK->(dbSeek(xFilial()+cPlanej))

dbSelectArea('AFM')
dbSetOrder(3)
If MsSeek(xFilial()+cPlanej)
	While !Eof().And.AFM->AFM_FILIAL+AFM->AFM_PLANEJ==xFilial("AFM")+cPlanej
		cNumOP	:= AFM->AFM_NUMOP+AFM->AFM_ITEMOP+AFM->AFM_SEQOP
		dbSelectArea("SC2")
		dbSeek(PmsFilial("SC2","AFM")+cNumOP)
		aAdd(aViewOP,{C2_NUM+C2_ITEM+C2_SEQUEN,C2_PRODUTO,TransForm(C2_QUANT,PesqPict("SC2","C2_QUANT")),TransForm(C2_QUJE,PesqPict("SC2","C2_QUJE")),C2_DATPRF, PmsFilial("SC2","AFM")})
		dbSelectArea("AFM")
		While !Eof().And.AFM->AFM_FILIAL+AFM->AFM_PLANEJ+AFM->AFM_NUMOP+AFM->AFM_ITEMOP+AFM->AFM_SEQOP==xFilial("AFM")+cPlanej+cNumOP
			dbSkip()
		End
	End
	DEFINE MSDIALOG oDlg FROM 85,35 to 325,605 TITLE cCadastro Of oMainWnd PIXEL
		oListBox := TWBrowse():New( 16,1,284,105,,{STR0076,STR0077,STR0031,STR0078,STR0033,"Filial Origem"},,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)  //"OP"###"Cod. Produto"###"Quantidade"###"Qtd.Entregue"###"Necessidade"
		oListBox:SetArray(aViewOP)
		oListBox:bLine := { || aViewOP[oListBox:nAT]}
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,{{"BMPINCLUIR",{||MaViewOP(aViewOP[oListBox:nAT][1],aViewOP[oListBox:nAT][6])},STR0056}} ) //"Detalhes"
Else
	Aviso(STR0035,STR0079,{STR0059},2) //"Atencao"###"Nao foram geradas Ordens de Producao neste planejamento."###"Fechar"
EndIf

RestArea(aAreaSC2)
RestArea(aAreaAFM)
RestArea(aAreaAFK)
RestArea(aArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PmsPl220Emp³ Autor ³ Edson Maricate       ³ Data ³23.09.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria uma tela de consulta dos Empenhos do Planejamento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do Planejamento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Materiais                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PmsPl220Emp(cPlanej)
Local oDlg
Local aArea		:= GetArea()
Local aAreaAFJ	:= AFJ->(GetArea())
Local aViewEmp	:= {}
Local aRecEmp	:= {}

dbSelectArea('AFJ')
dbSetOrder(4)
If MsSeek(xFilial()+cPlanej)
	While !Eof().And.AFJ->AFJ_FILIAL+AFJ->AFJ_PLANEJ==xFilial("AFJ")+cPlanej
		aAdd(aViewEmp,{AFJ_COD,AFJ_LOCAL,TransForm(AFJ_QEMP,PesqPict("AFJ","AFJ_QEMP")),TransForm(AFJ_QATU,PesqPict("AFJ","AFJ_QATU")),AFJ_DATA})
		aAdd(aRecEmp,AFJ->(RecNo()))
		dbSkip()
	End
	DEFINE MSDIALOG oDlg FROM 85,35 to 325,605 TITLE cCadastro Of oMainWnd PIXEL
		oListBox := TWBrowse():New( 30,1,284,85,,{STR0030,STR0091,STR0092,STR0093,STR0094},,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Produto"###"Armazem"###"Qtd.Empenhada"###"Qtd.Atual"###"Dt.Necessidade"
		oListBox:SetArray(aViewEmp)
		oListBox:bLine := { || aViewEmp[oListBox:nAT]}
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,{{"BMPINCLUIR",{|| MaViewEmp(aRecEmp[oListBox:nAT])},STR0056}} ) //"Detalhes"
Else
	Aviso(STR0035,STR0079,{STR0059},2) //"Atencao"###"Nao foram geradas Ordens de Producao neste planejamento."###"Fechar"
EndIf

RestArea(aAreaAFJ)
RestArea(aArea)
Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A220CtrMenu³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que controla as propriedades do Menu PopUp.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA220                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A220CtrMenu(oMenu,oTree,lVisual,cArquivo)
Local aArea		:= GetArea()
Local cAlias
Local nRecView

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf


dbSelectArea(cAlias)
dbGoto(nRecView)

Do Case
	Case cAlias=="AF8"
		If PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT))," ",2,"GERCP",AF8->AF8_REVISA)
			oMenu:aItems[1]:Enable()
        Else
			oMenu:aItems[1]:Disable()
		EndIf

		If PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT))," ",2,"GERSC",AF8->AF8_REVISA)
			oMenu:aItems[2]:Enable()
		Else
			oMenu:aItems[2]:Disable()
		EndIf
		If PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT))," ",2,"GERSA",AF8->AF8_REVISA)
			oMenu:aItems[3]:Enable()
		Else
			oMenu:aItems[3]:Disable()
		EndIf
		If PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT))," ",2,"GEROP",AF8->AF8_REVISA)
			oMenu:aItems[4]:Enable()
		Else
			oMenu:aItems[4]:Disable()
		EndIf
		If PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT))," ",2,"GEREMP",AF8->AF8_REVISA)
			oMenu:aItems[5]:Enable()
		Else
			oMenu:aItems[5]:Disable()
		EndIf
	Case cAlias=="AF9"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a permissao para o Contrato de Parcerias.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,2,"GERCP",AF9->AF9_REVISA)//Visualizar
			oMenu:aItems[1]:Enable()
		Else
			oMenu:aItems[1]:Disable()
		EndIf


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a permissao para a Solicitacao de Compras.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,2,"GERSC",AF9->AF9_REVISA)//Visualizar
			oMenu:aItems[2]:Enable()
		Else
			oMenu:aItems[2]:Disable()
		EndIf


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a permissao para a Solicitacao ao Almoxarifado.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,2,"GERSA",AF9->AF9_REVISA)//Visualizar
			oMenu:aItems[3]:Enable()
		Else
			oMenu:aItems[3]:Disable()
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a permissao para aOrdem de Producao.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,2,"GEROP",AF9->AF9_REVISA)//Visualizar
			oMenu:aItems[4]:Enable()
		Else
			oMenu:aItems[4]:Disable()
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica a permissao para o Empenho.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,2,"GEREMP",AF9->AF9_REVISA)//Visualizar
			oMenu:aItems[5]:Enable()
		Else
			oMenu:aItems[5]:Disable()
		EndIf

	OtherWise
		oMenu:aItems[1]:Disable()
		oMenu:aItems[2]:Disable()
		oMenu:aItems[3]:Disable()
		oMenu:aItems[4]:Disable()
		oMenu:aItems[5]:Disable()
EndCase


RestArea(aArea)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A220ValOp  ³ Autor ³Fabio Rogerio Pereira ³ Data ³ 07-01-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que verifica as permissoes do usuario.		            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA220                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A220ValOp(cAlias,nRecView,cCampo,lHabVis,lHabInc,lHabAlt,lHabExc)
Local aArea		:= GetArea()

dbSelectArea(cAlias)
dbGoto(nRecView)

Do Case
	Case cAlias=="AF8"
		If PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT))," ",4,cCampo,AF8->AF8_REVISA) //Controle Total
			lHabVis:= .T.
			lHabInc:= .T.
			lHabAlt:= .T.
			lHabExc:= .T.
		ElseIf PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT))," ",3,cCampo,AF8->AF8_REVISA) //Alterar
			lHabVis:= .T.
			lHabInc:= .F.
			lHabAlt:= .T.
			lHabExc:= .F.
		ElseIf PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT))," ",2,cCampo,AF8->AF8_REVISA) //Visualizar
			lHabVis:= .T.
			lHabInc:= .F.
			lHabAlt:= .F.
			lHabExc:= .F.
		Else
			lHabVis:= .F.
			lHabInc:= .F.
			lHabAlt:= .F.
			lHabExc:= .F.
		EndIf

	Case cAlias=="AF9"

		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,4,cCampo,AF9->AF9_REVISA)//Controle Total
			lHabVis:= .T.
			lHabInc:= .T.
			lHabAlt:= .T.
			lHabExc:= .T.
		ElseIf PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,3,cCampo,AF9->AF9_REVISA)//Alterar
			lHabVis:= .T.
			lHabAlt:= .T.
			lHabInc:= .F.
			lHabExc:= .F.
		ElseIf PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,2,cCampo,AF9->AF9_REVISA)//Visualizar
			lHabVis:= .T.
			lHabAlt:= .F.
			lHabInc:= .F.
			lHabExc:= .F.
		Else
			lHabVis:= .F.
			lHabAlt:= .F.
			lHabInc:= .F.
			lHabExc:= .F.
		EndIf

	OtherWise
		lHabVis:= .F.
		lHabAlt:= .F.
		lHabInc:= .F.
		lHabExc:= .F.
EndCase

RestArea(aArea)
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FAtiva   ³ Autor ³ Edson Maricate        ³ Data ³ 18.10.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a&pergunte                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA200                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FAtiva()
	Pergunte("PMA200",.T.)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMS220FR ³ Autor ³ Edson Maricate        ³ Data ³ 23.12.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de firmar o planejamento do projeto                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA220                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS220FR(cAlias,nReg,nOpcx)
Local aRecSC1	:= {}
Local aRecSC2	:= {}
Local lContinua := .T.
Local cSeq		:= ""

// Verifica se o projeto permite gerar planejamento
If !PmsVldFase("AF8",AFK->AFK_PROJET,"51")
	lContinua := .F.
EndIf

If lContinua .AND. AFK->AFK_TPPLAN == "1"
	Aviso(STR0098, STR0099, {STR0100}) //"Planejamento firme"##"Este procedimento somente se aplica aos planejamentos previstos."##OK
	lContinua := .F.
EndIf

If lContinua .AND. axVisual(cAlias,nReg,2) == 1
	Begin Transaction
		SC1->(dbSetOrder(1))
		dbSelectArea("AFG")
		dbSetOrder(3)
		dbSeek(xFilial()+AFK->AFK_PLANEJ)
		While !Eof() .And. xFilial()+AFK->AFK_PLANEJ==AFG->AFG_FILIAL+AFG->AFG_PLANEJ
			If SC1->(dbSeek(PmsFilial("SC1","AFG")+AFG->AFG_NUMSC+AFG->AFG_ITEMSC))
				If aScan(aRecSC1,SC1->(RecNo())) <= 0
					A652Do()
				EndIf
			EndIf
			dbSelectArea("AFG")
			dbSkip()
		End

		SC2->(dbSetOrder(1))
		dbSelectArea('AFM')
		dbSetOrder(3)
		If MsSeek(xFilial()+AFK->AFK_PLANEJ)
			While !Eof().And.AFM->AFM_FILIAL+AFM->AFM_PLANEJ==xFilial("AFM")+AFK->AFK_PLANEJ
				dbSelectArea("SC2")
				If dbSeek(PmsFilial("SC2","AFM")+AFM->AFM_NUMOP+AFM->AFM_ITEMOP)
					cChave:= PmsFilial("SC2","AFM")+AFM->AFM_NUMOP+AFM->AFM_ITEMOP
					While SC2->(!EOF()) .AND. cChave==PmsFilial("SC2","AFM")+AFM->AFM_NUMOP+AFM->AFM_ITEMOP
						If aScan(aRecSC2,SC2->(RecNo()))<=0 .and. (cSeq == SC2->C2_SEQPAI .or. empty(cSeq))
							A651Do()
							aAdd(aRecSC2,SC2->(RecNo()))
						EndIf
						If Empty(cSeq)
							cSeq := AFM->AFM_SEQOP
						Endif
						SC2->(dbSkip())
					EndDo
				EndIf
				dbSelectArea("AFM")
				dbSkip()
			End
		EndIf
		dbSelectArea('AFJ')
		dbSetOrder(4)
		If MsSeek(xFilial()+AFK->AFK_PLANEJ)
			While !Eof().And.AFJ->AFJ_FILIAL+AFJ->AFJ_PLANEJ==xFilial("AFJ")+AFK->AFK_PLANEJ
				RecLock("AFJ",.F.)
				AFJ->AFJ_QEMP += AFJ->AFJ_QEMPPR
				AFJ->AFJ_QEMP2+= AFJ->AFJ_QEMPP2
				AFJ->AFJ_QEMPPR := 0
				AFJ->AFJ_QEMPP2 := 0
				MsUnlock()
				PmsAvalAFJ("AFJ",4)
				dbSKip()
			End
		EndIf
		RecLock("AFK")
		AFK->AFK_TPPLAN := "1"
		MsUnlock()
	End Transaction
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSelProj ³ Autor ³ Daniel Sobreira       ³ Data ³ 06.09.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta tela para selecao dos projetos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA220                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMSelProj()
Local aArea		:= GetArea()
Local nOpca
Local oDlg
Local oDlg1
Local oTables
Local cProjeto  := ""
Local aTables	:= {}
Local aTables2  := {}
Local oOk 	    := LoadBitmap( GetResources(), BMP_CHECKBOX )
Local oNo       := LoadBitmap( GetResources(), BMP_UNCHECKBOX )
Local nFaz      := 0
Local lRet      := .F.

	cProjeto:=AF8->AF8_PROJET
	dbSelectArea("AF8")
	AF8->(dbSetOrder(1))
	AF8->(dbGotop())
	AF8->(dbSeek(xFilial()))
	While !AF8->(EOF()) .and. AF8->AF8_FILIAL==xFilial()
		If PmsVldFase("AF8",AF8->AF8_PROJET,"51",.F.)
			AADD(aTables,{.F.,AF8->AF8_PROJET,Alltrim(AF8->AF8_DESCRI)})
		EndIf
		AF8->(dbskip())
	End

	If len(aTables) > 0
		nPosProj	:= aScan(aTables,{|x| x[2]==cProjeto})
		If nPosProj > 0
			aTables[nPosProj][1] := .T.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Mostra a tela de Projetos - WINDOWS						     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOpcA := 0
		DEFINE MSDIALOG oDlg1 TITLE OemToAnsi("Projetos")	From 9,0 To 28,80 OF oMainWnd
		oDlg1:lMaximized := .F.
		@ 1.0 , 01	To 2.35,37 OF oDlg1
		@ 1.6 , 12	SAY OemToAnsi("Selecione os Projetos a Gerar Planejamento") FONT oDlg1:oFont

		@ 42,07 LISTBOX oTables FIELDS HEADER " ","Projeto","Descricao";  //"Projeto"##"Descricao"
		FIELDSIZES 14, 50 SIZE 300, 90 PIXEL OF oDlg
		oTables:SetArray(aTables)
		oTables:bLine := {|| {Iif(aTables[oTables:nAt,1],oOK,oNo),aTables[oTables:nAt,2],aTables[oTables:nAt,3]} }
		oTables:bLDblClick := { |nRowPix, nColPix, nKeyFlags| If(oTables:nColPos==1,(aTables[oTables:nAt,1] := !aTables[oTables:nAt,1],oTables:aArray[oTables:nAt,1],Eval(oTables:bLine)),Nil)}
		oTables:lhScroll := .F.

		ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| nOpca := 1,oDlg1:End()},{|| nOpca := 2,oDlg1:End()}) CENTERED

		If nOpcA == 1

			// monta array somente com os selecionados
			For nFaz:=1 to Len(aTables)
				If aTables[nFaz][1]
					aAdd(aTables2,{aTables[nFaz][1],aTables[nFaz][2],aTables[nFaz][3],0})
				EndIf
			Next nFaz
		EndIf
	EndIf

RestArea(aArea)

Return(aTables2)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PM220LinOk³ Autor ³ Daniel Sobreira       ³ Data ³ 13.10.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica os campos obrigatorios do SX3.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA220                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PM220LinOk()
Local lRet:=.T.

lRet := MaCheckCols(oGetMt:aHeader,oGetMt:aCols,oGetMt:oBrowse:nAT)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PM220LinOk³ Autor ³ Daniel Sobreira       ³ Data ³ 13.10.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Teste do GetDados                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA220                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PM220TUDOK()
Local nSavN	:= oGetMt:oBrowse:nAT
Local lRet	:= .T.
Local nx

For nx := 1 to Len(oGetMt:aCols)
	n	:= nx
	oGetMt:oBrowse:nAT:=n
	If !(oGetMt:aCols[n][Len(oGetMt:aHeader)+1])
		If !PM220LinOK()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next
n	:= nSavN
oGetMt:oBrowse:nAT:=n

Return lRet

/*/{Protheus.doc} MenuDef
Utilizacao de menu Funcional

@return ${return}, ${return_description}

@author Ana Paula N. Silva
@since 30/11/06
@version 1.0
@obs
Parametros do array a Rotina:
	1. Nome a aparecer no cabecalho
	2. Nome da Rotina associada
	3. Reservado
	4. Tipo de Transa‡„o a ser efetuada:
		1 - Pesquisa e Posiciona em um Banco de Dados
		2 - Simplesmente Mostra os Campos
		3 - Inclui registros no Bancos de Dados
		4 - Altera o registro corrente
		5 - Remove o registro corrente do Banco de Dados
	5. Nivel de acesso
	6. Habilita Menu Funcional

/*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,"AxPesqui" , 0 , 1,,.F.},; //"Pesquisar"
							{ STR0004,"PMS220Dlg", 0 , 2},;	 //"Atualizar"
							{ STR0003,"PMS220Dlg", 0 , 2},; //"Visualizar"
							{ STR0005,"PMS220PM" , 0 , 3},; //"Planejamentos"
							{ STR0080, "PMS220Leg", 0 , 2,,.F.}} //"Legenda"
Return(aRotina)

Static Function MontaaCols()
Local ny := 0
Local nLenAcols := 0

	aadd(aCols, Array(Len(aHeader) + 1))
	nLenAcols := Len(aCols)

	For ny := 1 to Len(aHeader)
		If aHeader[ny][2]=="AFK_PROJET"
			aCols[nLenAcols][ny]:= AF8->AF8_PROJET
		ElseIf aHeader[ny][2]=="AFK_DESCRI"
			aCols[nLenAcols][ny]:= AF8->AF8_DESCRI
		ElseIf aHeader[ny][2] =="AFK_REC_WT"
			aCols[nLenAcols][ny] := AF8->(Recno())
		ElseIf aHeader[ny][2] == "AFK_ALI_WT"
			aCols[nLenAcols][ny] := "AF8"
		Else
			aCols[nLenAcols][ny] := CriaVar(aHeader[ny][2])
		EndIf
	Next ny
	aCols[nLenAcols][Len(aHeader)+1] := .F.
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSA220ZERAºAutor  ³Pedro Pereira Lima  º Data ³  10/11/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                             º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A220Zera(nRecAFJ)
Local aBotao	:= {STR0112,STR0113}

	If M->AFJ_EMPEST == 0 .And. M->AFJ_EMPES2 == 0
		If Aviso(STR0114,STR0116+CRLF+STR0117,aBotao,2) == 1
			M->AFJ_EMPEST := M->AFJ_QEMP  - M->AFJ_QATU
			M->AFJ_EMPES2 := M->AFJ_QEMP2 - M->AFJ_QATU2
		EndIf
	Else
		If Aviso(STR0118,STR0119+CRLF+STR0120,aBotao,2) == 1
			M->AFJ_EMPEST := 0
			M->AFJ_EMPES2 := 0
		EndIf
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMSVldSA  ºAutor  ³ Pedro Pereira Lima º Data ³  16/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a alteração da solicitação ao armazem x o registro  º±±
±±º          ³ de amarração com o projeto (SCP x AFH)                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA105                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSVldSa(cNumSA,aColsSA,aHeaderSA,nNSA)
Local aArea 	:= GetArea()
Local aAreaSCP := SCP->(GetArea())
Local aAreaAFH := AFH->(GetArea())
Local nA		:= 0
Local nTotAFH	:=	0
Local nPosAFH	:=	0               
Local nPosQtde:=	0               
Local nBtnAFH := 0
Local nPItem	:= aScan(aHeaderSA,{|x| AllTrim(x[2])=="CP_ITEM"})
Local nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="CP_QUANT"})
Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="CP_PRODUTO"})
Local lRet		:= .T.

If (Len(aRatAFH)=0 .Or. (nPosAFH:=Ascan(aRatAFH,{|x|x[1]==aColsSA[nNSA][nPItem]})) == 0) 
	PmsDlgSA(6,cA105Num,.F.) //Carrega os valores que serao utilizados para a validacao
EndIf
If Len(aRatAFH) > 0
	nPosAFH  := Ascan(aRatAFH,{|x|x[1]==aColsSA[nNSA][nPItem]})
	nPosQtde := Ascan(aHdrAFH,{|x|Alltrim(x[2])=="AFH_QUANT"})
	nTotAFH	:= 0
	If (nPosAFH > 0) .And. (nPosQtde > 0)
		For nA := 1 To Len(aRatAFH[nPosAFH][2])
			If !aRatAFH[nPosAFH][2][nA][LEN(aRatAFH[nPosAFH][2][nA])]
				nTotAFH	+= aRatAFH[nPosAFH][2][nA][nPosQtde]
			EndIf
		Next nA
		If nTotAFH > aColsSA[nNSA][nPQuant]
			Help("   ",1,"PMSQTSA")
			lRet := .F.
		EndIf
		If AFH->(dbSeek(xFilial("AFH")+cNumSA+aColsSA[nNSA][nPItem])) .And. AFH->AFH_COD <> aColsSA[nNSA][nPProduto]
			nBtnAFH:=Aviso(STR0035,STR0125,{STR0112,STR0113})	//"Atenção"#"O produto alterado possui associação com tarefa(s) de projeto(s). Confirma a exclusão da associação?"#"Sim"#"Nao"
			If nBtnAFH==1
				For nA := 1 To Len(aRatAFH[nPosAFH][2])
					aRatAFH[nPosAFH][2][nA][LEN(aRatAFH[nPosAFH][2][nA])] := .T.
				Next nA
			Endif
		Endif
	EndIf
EndIf


RestArea(aAreaAFH)
RestArea(aAreaSCP)
RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PmsVldData()

Validação da data inicio/fim do gerenciamento de execução

@sample 	PmsVldData() 
@return	ExpL	Verdadeiro / Falso
@since		18/04/2016       
@version	P12   
/*/
//------------------------------------------------------------------------------
Function PmsVldData()

Local lRet 	:= .T.
Local cVar		:= ReadVar()

If "AFK_DATAF" $cVar
	If !Empty(M->AFK_DATAI) .And. M->AFK_DATAI > M->AFK_DATAF
		Help( " ", 1, "DATAMENOR" )
		lRet := .F.
	EndIf
ElseIf "AFK_DATAI" $cVar
	If !Empty(M->AFK_DATAF) .And. M->AFK_DATAF < M->AFK_DATAI
		Help( " ", 1, "DATAMAIOR" )
		lRet := .F.
	EndIf
EndIf	
Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} A220EAFG()
Excluir vinculo da Solicitacao de compra com o projeto.

@sample 	A220EAFG( cPlanej , cNumSC , cItemSC )
@param		cPlanej	  , Char, Codigo do Planejamento
@param		cNumSC    , Char, Numero da Solicitação de Compra
@param		cItemSC   , Char, Item Solicitação de compra
@author 	Squad CRM
@since 		13/07/2018
@version 	12.1.17
@return 	Nulo
/*/
//-------------------------------------------------------------------

Static Function A220EAFG( cPlanej , cNumSC , cItemSC )

	Local aArea		:= GetArea()
	Local aAreaAFG	:= AFG->(GetArea())
	
	AFG->(DbSetOrder(3))
	AFG->(DbGoTop())
	
	If AFG->(DbSeek(xFilial("AFG") + cPlanej + cNumSC + cItemSC ))
		Reclock("AFG",.F.)
		AFG->(DbDelete())
		MsUnlock()	
	Endif

	RestArea(aAreaAFG)
	RestArea(aArea)

Return Nil
