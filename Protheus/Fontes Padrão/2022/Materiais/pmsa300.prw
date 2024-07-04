#include "Pmsa300.ch"
#include "Protheus.ch"
#include "pmsicons.ch"
// AMARRACAO
// INCLUIDO PARA TRADUÇÃO DE PORTUGAL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA300  ³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de controle dos apontamentos do projeto.            ³±±
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
Function PMSA300()

PRIVATE cCadastro	:= STR0067 //"Gerenciamento de Apontamentos"
PRIVATE aRotina := MenuDef()
Private aCores:= PmsAF8Color()
Private lCallPrj := .T.

Set Key VK_F12 To fAtiva()

PMSX3Field("AFU_RECURS", "X3_VALID", 'ExistCpo("AE8")')

If AMIIn(44) .And. !PMSBLKINT()
	Pergunte("PMA200",.F.)
	mBrowse(6,1,22,75,"AF8",,,,,,aCores)
EndIf

Set Key VK_F12 To

Return
                                        
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS300Leg³ Autor ³  Fabio Rogerio Pereira ³ Data ³ 19-03-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Exibicao de Legendas                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA300, SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS300Leg(cAlias,nReg,nOpcx)
Local aLegenda:= {}
Local i       := 0

For i:= 1 To Len(aCores)
	Aadd(aLegenda,{aCores[i,2],aCores[i,3]})
Next i
                             
aLegenda:= aSort(aLegenda,,,{|x,y| x[1] < y[1]})

BrwLegenda(cCadastro,STR0054,aLegenda)//"Legenda"

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
Function PMS300Dlg(cAlias,nReg,nOpcx)

Local l300Inclui	:= .F.
Local l300Visual	:= .F.
Local l300Altera	:= .F.
Local l300Exclui	:= .F.
Local oMenu
Local oTree
Local oDlg
Local aConfig		:= {1,PMS_MIN_DATE,PMS_MAX_DATE, Space(TamSX3("AE8_RECURS")[1])}
Local lFWGetVersao	:= .T.

// variaveis para posicionamento do popup menu
Local nScreVal1 := 775 
Local nScreVal2 := 23

PRIVATE cArquivo  	:= CriaTrab(,.F.)
PRIVATE _cProjCod 	:= AF8->AF8_PROJET    //variaveis utilizadas no x3_relacao funcao pmsCpoInic()
PRIVATE cRevisa		:= AF8->AF8_REVISA    //variaveis utilizadas Tb no x3_relacao funcao pmsCpoInic()
PRIVATE _cTarefa  	:= ""                //variaveis utilizadas no x3_relacao funcao pmsCpoInic()
PRIVATE cCmpPLN
PRIVATE cArqPLN
PRIVATE cPLNVer		:= ''
PRIVATE cPLNDescri	:= ''
PRIVATE cPLNSenha	:= ''
PRIVATE lSenha		:= .F.
PRIVATE nIndent		:= PMS_SHEET_INDENT

If cPaisLoc == 'RUS'
	//Set popup menu location using the screen resolution
	nScreVal1 := RU99XFUN15()[1] // GetRusPopupMenuPos
	nScreVal2 := RU99XFUN15()[2] // GetRusPopupMenuPos
EndIf

If aRotina[nOpcx][4] == 4  //na versao 11 o lock é automatico ao pressionar altera na mbrowse - impede outros usuarios a realizar apt.
	AF8->(MsUnlock())      //razao desta instrução para liberar o registro referente ao projeto
EndIf

Pergunte("PMA200",.F.)
FATPDLogUser('PMS300DLG')
// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
Do Case
	Case aRotina[nOpcx][4] == 2 .and. nOpcx == 3 // Visualizar
		l300Visual := .T.
	Case aRotina[nOpcx][4] == 3
		l300Inclui	:= .T.
	Case aRotina[nOpcx][4] == 2 .and. nOpcx == 2 // Atualizar
		l300Altera	:= .T.
	Case aRotina[nOpcx][4] == 5
		l300Exclui	:= .T.
		l300Visual	:= .T.
EndCase

MENU oMenu2 POPUP
	MENUITEM STR0055 ACTION PmsPrjInf() //"Informacoes do Projeto..."
	If mv_par01 == 2
		MENUITEM STR0061 ACTION (PMC200Cfg("",0,0),oDlg:End()) //"Configurar Colunas"
	EndIf
	MENUITEM  STR0066 ACTION If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) //"Filtrar visualizacao"
ENDMENU
MENU oMenu3 POPUP
	MENUITEM STR0056 ACTION PmsDlgAF8Gnt(cRevisa,aConfig,@oDlg,@oTree,cArquivo) //"Grafico de Gantt..."
	MENUITEM STR0057 ACTION PmsDlgAF8Rec(cRevisa,@oTree,cArquivo) //"Grafico de Alocacao dos Recursos..."
EndMenu
MENU oMenu POPUP
	MENUITEM STR0008 Action PMS300RQ(@oTree,l300Visual,cArquivo) //"Requisicoes"
	
	If cPaisLoc == "BRA"
		MENUITEM STR0009 Action PMS300NF(@oTree,l300Visual,cArquivo) //"Nota Fiscal de Entrada"
	Else
		MENUITEM STR0086 Action PMS300NF(@oTree,l300Visual,cArquivo) //"Entrada de Materiais"
	EndIf
	
	MENUITEM STR0011 Action PMS300FID(@oTree,l300Visual,cArquivo) //"Despesas"
	MENUITEM STR0090 Action PMS300PRE(@oTree,l300Visual,cArquivo) //"Pre-Recursos"
	MENUITEM STR0091 Action PMS300APR(@oTree,l300Visual,cArquivo) //"Aprova Pre-Recursos"
	MENUITEM STR0048 Action PMS300REC(@oTree,l300Visual,cArquivo) //"Recursos"
	
	If cPaisLoc == "BRA"                                               
		MENUITEM STR0010 Action PMS300D2(@oTree,l300Visual,cArquivo) //"Notas Fiscais de Saida"
	Else
		MENUITEM STR0081 Action PMS300D2(@oTree,l300Visual,cArquivo) //"Notas Fiscais de Saida"	
	EndIf	
	
	MENUITEM STR0012 Action PMS300FIR(@oTree,l300Visual,cArquivo) //"Receitas"
	If PmsSE5()
		MENUITEM STR0052 Action PMS300MOV(@oTree,l300Visual,cArquivo)	 //"Movimento Bancario"
	EndIf
	
	MENUITEM STR0008+" Mod. II" Action PMS300RQMod2(@oTree,l300Visual,cArquivo) //"Requisicoes"

	MENUITEM STR0105 Action PMS300ADI(@oTree,l300Visual,cArquivo) //"Apontamento direto"

ENDMENU

If !lFWGetVersao .or. GetVersao(.F.) == "P10"

	If mv_par01 == PMS_VIEW_SHEET
	
		// modo planilha
		aMenu := {;
		         {TIP_PROJ_INFO,      {||PmsPrjInf()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
		         {TIP_COLUNAS,        {||PMC200Cfg("",0,0), oDlg:End()}, BMP_COLUNAS, TOOL_COLUNAS},;
		         {TIP_FILTRO,         {|| If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) }, BMP_FILTRO, TOOL_FILTRO},;
		         {TIP_PROJ_CONSULTAS, {||oMenu3:Activate(75,45,oDlg)}, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},;
		         {TIP_PROJ_APONT,     {||A300CtrMenu(@oMenu,oTree,cArquivo),oMenu:Activate(150,45,oDlg)}, BMP_PROJ_APONT, TOOL_PROJ_APONT }}  //"&Apontm."
	
	Else
	
		// modo arvore
		aMenu := {;
		         {TIP_PROJ_INFO,      {||PmsPrjInf()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
		         {TIP_FILTRO,         {|| If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) }, BMP_FILTRO, TOOL_FILTRO},;
		         {TIP_PROJ_CONSULTAS, {||oMenu3:Activate(75,45,oDlg)}, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},;
		         {TIP_PROJ_APONT,     {||A300CtrMenu(@oMenu,oTree,cArquivo),oMenu:Activate(150,45,oDlg)}, BMP_PROJ_APONT, TOOL_PROJ_APONT }}  //"&Apontm."
	EndIf

Else
	//Acoes relacionadas

	If mv_par01 == PMS_VIEW_SHEET
	
		// modo planilha
		aMenu := {;
		         {TIP_PROJ_INFO,      {||PmsPrjInf()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
		         {TIP_COLUNAS,        {||PMC200Cfg("",0,0), oDlg:End()}, BMP_COLUNAS, TOOL_COLUNAS},;
		         {TIP_FILTRO,         {|| If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) }, BMP_FILTRO, TOOL_FILTRO},;
		         {TIP_PROJ_CONSULTAS, {||oMenu3:Activate(nScreVal1,nScreVal2,oDlg)}, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},;
		         {TIP_PROJ_APONT,     {||A300CtrMenu(@oMenu,oTree,cArquivo),oMenu:Activate(nScreVal1,nScreVal2,oDlg)}, BMP_PROJ_APONT, TOOL_PROJ_APONT }}  //"&Apontm."
	
	Else
	
		// modo arvore
		aMenu := {;
		         {TIP_PROJ_INFO,      {||PmsPrjInf()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
		         {TIP_FILTRO,         {|| If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) }, BMP_FILTRO, TOOL_FILTRO},;
		         {TIP_PROJ_CONSULTAS, {||oMenu3:Activate(nScreVal1,nScreVal2,oDlg)}, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},;
		         {TIP_PROJ_APONT,     {||A300CtrMenu(@oMenu,oTree,cArquivo),oMenu:Activate(nScreVal1,nScreVal2,oDlg)}, BMP_PROJ_APONT, TOOL_PROJ_APONT }}  //"&Apontm."
	EndIf
Endif

If ExistBlock("PMA300BTN")
	aButtons := ExecBlock("PMA300BTN",.F.,.F.)
	If ValType(aButtons) == "A"
		aEval(aButtons ,{|x| iIf(ValType(x[1]) == "C".and.ValType(x[2]) == "B".AND.ValType(x[3]) == "C".AND.ValType(x[4]) == "C";
		                    ,aAdd(aMenu ,x);
		                    ,.T.)})
	EndIf
EndIf
	
If mv_par01 == PMS_VIEW_SHEET
	aCampos := {{"AF9_TAREFA","AFC_EDT",8,,,.F.,"",},{"AF9_DESCRI","AFC_DESCRI",55,,,.F.,"",150}}
	A200Opn(@aCampos,"\PROFILE\PMSA300","MV_PMSPLN7","MV_PMSPLN8")
	PmsPlanAF8(cCadastro,cRevisa,aCampos,@cArquivo,,,,aMenu,@oDlg,,,aConfig,,nIndent)
Else 
	PmsDlgAF8(cCadastro,,cRevisa,@oTree,,,,,aMenu,@oDlg,aConfig,@cArquivo)
EndIf


Return 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS300RQ³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Visualizacao das Requisicoes vinculadas ao projeto³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS300RQ(oTree,lVisual,cArquivo)
Local cAlias
Local nRecView
Local aSize		:= MsAdvSize(,.F.,430)
Local aRotina   := {}         
Local lHabVis 	:= .T.
Local lHabInc	:= .T.
Local lHabAlt	:= .T.

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf


A300ValOp(cAlias,nRecView,"REQUIS",@lHabVis,@lHabInc,@lHabAlt)

aRotina 	:= If(lVisual,{{ STR0003,"A300toRQ", 0 , 2,,lHabVis}},	{	{ STR0003,"A300toRQ", 0 , 2,  ,lHabVis},; //"Visualizar"
																		{ STR0014,"A300toRQ", 0 , 3,  ,lHabInc},;	 //"Incluir"
																		{ STR0015,"A300toRQ", 0 , 5, 1,lHabAlt} } )//"Estornar"



If cAlias == "AF9" .And. nRecView<>0
	AF9->(dbGoto(nRecView))
	_cTarefa := AF9->AF9_TAREFA   //variavel utilizada x3_relacao Funcao PmsCpoInic()
	AFI->(dbSetOrder(1))
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0016+AllTrim(AF9->AF9_PROJET)+"/"+AF9->AF9_TAREFA+"]","AFI",,aRotina,,; //" - MOV. -["
	'xFilial("AFI")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
	'xFilial("AFI")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
	.F.,,,{{STR0032,1},{STR0069,4}},xFilial("AFI")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA) //"Codigo do Produto + Armazem + Data de Emissao + Num. Sequencial" //"Data de Emissao + Codigo do Produto + Armazem"
ElseIf cAlias == "AF8" .And. nRecView<>0
	AF8->(dbGoto(nRecView))
	_cTarefa := Space(Len(AF9->AF9_TAREFA))   //variavel utilizada x3_relacao Funcao PmsCpoInic()
	AFI->(dbSetOrder(1))
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0016+AllTrim(AF8->AF8_PROJET)+"]","AFI",,aRotina,,; //" - MOV. -["
	'xFilial("AFI")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
	'xFilial("AFI")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
	.F.,,,{{STR0033,1},{STR0070,3},{STR0069,5}},xFilial("AFI")+AF8->AF8_PROJET+AF8->AF8_REVISA) //"Tarefa + Codigo do Produto + Armazem + Data de Emissao + Num. Sequencial" //"Codigo do Produto + Armazem"###"Data de Emissao + Codigo do Produto + Armazem"
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A300toRQ³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Atualizacao das Requisicoes vinculadas ao Projeto.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A300toRQ(cAlias,nReg,nOpcx)
Local aArea			:= GetArea()
Local cFilSD3 		:= ""
Local cFilOldSD3 	:= ""
Local lIncluir := .F.
Local lAlterar := .F.

Do Case
	// Visualizar
	Case nOpcx == 1
		
		cFilSD3 	:= PmsFilial("SD3","AFI")
		cFilOldSD3  := cFilAnt
		If cFilSD3 <> ""
			cFilAnt 	:= cFilSD3
		EndIf
	
		SD3->(dbSetOrder(7))
		If SD3->(dbSeek(xFilial()+AFI->AFI_COD+AFI->AFI_LOCAL+DTOS(AFI->AFI_EMISSA)+AFI->AFI_NUMSEQ))
			lIncluir := INCLUI
			lAlterar := ALTERA
			
			INCLUI := .F.
			ALTERA := .F.
			
			MATA240(,2)
			
			INCLUI := lIncluir
			ALTERA := lAlterar
		
		EndIf
		
		cFilAnt	:= cFilOldSD3  
	
	// Incluir
	Case nOpcx == 2
		If PmsVldFase("AF8",AF8->AF8_PROJET,"81")
			lIncluir := INCLUI
			lAlterar := ALTERA
	
			INCLUI := .T.
			ALTERA := .F.

			MATA240(,3)
			
			INCLUI := lIncluir
			ALTERA := lAlterar

		Endif	
	
	// estornar
	Case nOpcx == 3

		cFilSD3 	:= PmsFilial("SD3","AFI")
		cFilOldSD3  := cFilAnt
		If cFilSD3 <> ""
			cFilAnt 	:= cFilSD3
		EndIf

		SD3->(dbSetOrder(7))
		If SD3->(dbSeek(xFilial()+AFI->AFI_COD+AFI->AFI_LOCAL+DTOS(AFI->AFI_EMISSA)+AFI->AFI_NUMSEQ))
			lIncluir := INCLUI
			lAlterar := ALTERA
			
			INCLUI := .F.
			ALTERA := .F.
			
			MATA240(,5)
			
			INCLUI := lIncluir
			ALTERA := lAlterar
		
		EndIf
		
		cFilAnt		:= cFilOldSD3  
	
EndCase

RestArea(aArea)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A300Aptm³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Atualizacao dos apontamentos de requisicoes .     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA300                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A300Aptm(cAlias,nReg,nOpcx)
Local cMarca	:= GetMark()
Local lInverte	:= .F.
Local oDlg
Local oBold
Local oGetDados
Local oMark
Local aMarca		:= {}
Local aCpos			:= {}
Local aTitles		:= {STR0017,STR0018} //'Projetos'###'Movimentos'
Local nRecView		:= Val(SubStr(oTree:GetCargo(),4,12))
Local ny := 0
Local ni := 0

PRIVATE aHeader		:= {}
PRIVATE aCols		:= {}

AF9->(dbGoto(nRecView))

// montagem do aHeader do AFH
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("AFI")
While !EOF() .And. (x3_arquivo == "AFI")
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
		AADD(aHeader,{ TRIM(x3titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal, x3_valid,;
			x3_usado, x3_tipo, x3_arquivo,x3_context } )
	Endif
	dbSkip()
End

// faz a montagem de uma linha em branco no aCols
aadd(aCols,Array(Len(aHeader)+1))
For ny := 1 to Len(aHeader)
	Do Case
		Case Trim(aHeader[ny][2]) == "AFI_ITEM"
			aCols[1][ny] 	:= "01"
		Case Trim(aHeader[ny][2]) == "AFI_PROJET"
			aCols[1][ny] 	:= AF9->AF9_PROJET
		Case Trim(aHeader[ny][2]) == "AFI_REVISA"
			aCols[1][ny] 	:= AF9->AF9_REVISA
		Case Trim(aHeader[ny][2]) == "AFI_TAREFA"
			aCols[1][ny] 	:= AF9->AF9_TAREFA
		Case Trim(aHeader[ny][2]) == "AFI_PERC"
			aCols[1][ny] 	:= 100
		OtherWise
			aCols[1][ny] := CriaVar(aHeader[ny][2])
	EndCase
	aCols[1][Len(aHeader)+1] := .F.
Next ny

// monta o Header com os titulos do MsSelect
aADD(aCpos,{"D3_OK",""," ",""})
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SD3")
While !Eof() .And. X3_ARQUIVO = "SD3"
	If X3_BROWSE=="S" .And. X3_CONTEXT != "V"
		AADD(aCpos,{X3_CAMPO,"",AllTrim(X3Titulo()),X3_PICTURE})
	EndIf
	dbSkip()
End

DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
DEFINE MSDIALOG oDlg TITLE cCadastro From 30,15 To 375,625 OF oMainWnd PIXEL

oFolder := TFolder():New(1,1,aTitles,{},oDlg,,,, .T., .F.,305,172,)
For ni := 1 to Len(oFolder:aDialogs)
	DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[ni]
Next

@ 14,05 TO 16,320 Label "" Of oFolder:aDialogs[1] PIXEL 
@ 6,05 Say STR0019 Of oFolder:aDialogs[1] PIXEL FONT oBold //"Indices de Rateio das Movimentacoes"
oGetDados := MSGetDados():New(19,05,130,300,3,'PMSAFILOK','PMSAFITOK','+AFI_ITEM',.T.,,,,100,'PMSAFIFOK',,,,oFolder:aDialogs[1])

@140,175 BUTTON oButton1 PROMPT STR0020 SIZE 35, 10 OF oFolder:aDialogs[1] PIXEL ; //'&Incluir' //"Parametros"
		ACTION {|| Nil }

@140,210 BUTTON oButton2 PROMPT STR0021 SIZE 35, 10 OF oFolder:aDialogs[1] PIXEL ; //'&Incluir' //"Cancelar"
		ACTION {|| oDlg:End() }

@140,245 BUTTON oButton2 PROMPT STR0022 SIZE 35, 10 OF oFolder:aDialogs[1] PIXEL ; //'&Incluir' //"Confirmar"
		ACTION {|| If(oGetDados:TudoOk(),(A300GrvRQ(aMarca),oDlg:End()),Nil) }

oMark := MsSelect():New("SD3","D3_OK",,aCpos,@lInverte,@cMarca,{ 2,2,158,303},,,oFolder:aDialogs[2])
oMark:bMark := {|| A300AddMark(cMarca,@aMarca)}


ACTIVATE MSDIALOG oDlg



Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A300RtAp³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Atualizacao dos apontamentos de requisicoes .     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA300                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A300GrvRQ(aMarca)
Local nx
Local ny
Local nz

Begin Transaction

For nx := 1 to Len(aMarca)
	If aMarca[nx] > 0
		dbSelectArea("SD3")
		dbGoto(aMarca[nx])
		For ny := 1 to Len(aCols)
			If !aCols[ny][Len(aCols[ny])]
				dbSelectArea("AFI")
				RecLock("AFI",.T.)

				// atualiza os dados contidos na GetDados
				For nz := 1 to Len(aHeader)
					If aHeader[nz][10] # "V"
						AFI->(FieldPut(FieldPos(Trim(aHeader[nz][2])),aCols[ny][nz]))
					Endif
				Next nz
				AFI->AFI_FILIAL := xFilial("AFI")
				AFI->AFI_NUMSEQ := SD3->D3_NUMSEQ
				AFI->AFI_COD    := SD3->D3_COD
				AFI->AFI_LOCAL  := SD3->D3_LOCAL
				AFI->AFI_EMISSA := SD3->D3_EMISSAO
				MsUnlock()
			EndIf
		Next ny	
	EndIf
Next nx

End Transaction

Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a300AddMark³ Autor ³ Edson Maricate       ³ Data ³ 01.02.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Adiciona o Recno() do registro no controle de marcas da     ³±±
±±³          ³MarkBrowse.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA300                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A300AddMark(cMarca,aMarca)

If SD3->D3_OK != cMarca
	If aScan(aMarca,RecNo())> 0
		aMarca[aScan(aMarca,RecNo())] := 0
	EndIf
Else
	AADD(aMarca,Recno())
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS300NF³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Visualizacao das NFs vinculadas ao projeto.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS300NF(oTree,lVisual,cArquivo)

Local cAlias	
Local nRecView	
Local aSize		:= MsAdvSize(,.F.,430)
Local aRotina   := {}         
Local lHabVis 	:= .T.
Local lHabInc	:= .T.
Local lHabExc	:= .T.

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

A300ValOp(cAlias,nRecView,"NFE",@lHabVis,@lHabInc,,@lHabExc)

If cPaisLoc == "BRA"
	aRotina 	:= If(lVisual,;
	                  {{ STR0003,"A300toNF('AFN', AFN->(Recno()), 1, 0)", 0 , 2, , lHabVis}},;
	                  {{ STR0003,"A300toNF('AFN', AFN->(Recno()), 1, 0)", 0 , 2, , lHabVis} ,; //"Visualizar"
                       { STR0024,"A300toNF('AFN', AFN->(Recno()), 2, 0)", 0 , 3,  ,lHabInc},;  //"Incluir NF"
	                   { STR0025,"A300toNF('AFN', AFN->(Recno()), 3, 0)", 0 , 5, 1,lHabExc}})  //"Excluir NF"
Else
	aRotina 	:= If(lVisual,;
	                 {{ STR0003,"A300toNF('AFN', AFN->(Recno()), 1, 0)", 0 , 2, ,lHabVis}},;
	                 {{ STR0003,"A300toNF('AFN', AFN->(Recno()), 1, 0)", 0 , 2, ,lHabVis},; //"Visualizar"
	                  { STR0082, "A300toNF('AFN', AFN->(Recno()), 2, 1)", 0 , 3,  ,lHabInc},;   //"Incluir NF"
	                  { STR0083, "A300toNF('AFN', AFN->(Recno()), 2, 2)", 0 , 3,  ,lHabInc},;
	                  { STR0084, "A300toNF('AFN', AFN->(Recno()), 2, 3)", 0 , 3,  ,lHabInc},;
	                  { STR0087, "A300toNF('AFN', AFN->(Recno()), 2, 4)", 0 , 3,  ,lHabInc},;	                  
	                  { STR0025,"A300toNF('AFN', AFN->(Recno()), 3, 0)", 0 , 5, 1,lHabExc} } ) //"Excluir NF"
EndIf



If cAlias == "AF9" .And. nRecView<>0
	AF9->(dbGoto(nRecView))
	_cTarefa := AF9->AF9_TAREFA   //variavel utilizada x3_relacao Funcao PmsCpoInic()
	AFN->(dbSetOrder(1))
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0026+AllTrim(AF9->AF9_PROJET)+"/"+AF9->AF9_TAREFA+"]","AFN",,aRotina,,; //" - NFE -["
	'xFilial("AFN")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
	'xFilial("AFN")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
	.F.,,,{{STR0034,1},{STR0035,3}},xFilial("AFN")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA,,,.F.) //"Numero da NF + Serie + Cod. Fornecedor + Loja + Item"###"Cod. Produto"
ElseIf cAlias == "AF8" .And. nRecView<>0
	AF8->(dbGoto(nRecView))
	_cTarefa := Space(Len(AF9->AF9_TAREFA))   //variavel utilizada x3_relacao Funcao PmsCpoInic()
	AFN->(dbSetOrder(1))
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0026+AllTrim(AF8->AF8_PROJET)+"]","AFN",,aRotina,,; //" - NFE -["
	'xFilial("AFN")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
	'xFilial("AFN")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
	.F.,,,{{STR0036,1},{STR0037,3},{STR0071,5},{STR0034,6}},xFilial("AFN")+AF8->AF8_PROJET+AF8->AF8_REVISA,,,.F.) //"Cod. Tarefa + Numero da NF + Serie + Cod. Fornecedor + Loja + Item"###"Cod. Tarefa + Cod. Produto" //"Codigo do Produto"
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A300AptmNF³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Atualizacao dos apontamentos de NF de Entrada     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA300                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A300AptmNF(cAlias,nReg,nOpcx)
Local cMarca	:= GetMark()
Local lInverte	:= .F.
Local oDlg
Local oBold
Local oGetDados
Local oMark
Local aMarca		:= {}
Local aCpos			:= {}
Local aTitles		:= {STR0017,STR0027} //'Projetos'###'Notas Fiscais ( Entrada )'
Local nRecView		:= Val(SubStr(oTree:GetCargo(),4,12))
Local ny := 0
Local ni := 0

PRIVATE aHeader		:= {}
PRIVATE aCols		:= {}

AF9->(dbGoto(nRecView))

// montagem do aHeader do AFN
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("AFN")
While !EOF() .And. (x3_arquivo == "AFN")
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
		AADD(aHeader,{ TRIM(x3titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal, x3_valid,;
			x3_usado, x3_tipo, x3_arquivo,x3_context } )
	Endif
	dbSkip()
End

// faz a montagem de uma linha em branco no aCols
aadd(aCols,Array(Len(aHeader)+1))
For ny := 1 to Len(aHeader)
	Do Case
		Case Trim(aHeader[ny][2]) == "AFN_ITEM"
			aCols[1][ny] 	:= "01"
		Case Trim(aHeader[ny][2]) == "AFN_PROJET"
			aCols[1][ny] 	:= AF9->AF9_PROJET
		Case Trim(aHeader[ny][2]) == "AFN_REVISA"
			aCols[1][ny] 	:= AF9->AF9_REVISA
		Case Trim(aHeader[ny][2]) == "AFN_TAREFA"
			aCols[1][ny] 	:= AF9->AF9_TAREFA
		Case Trim(aHeader[ny][2]) == "AFN_QUANT"
			aCols[1][ny] 	:= 100
		OtherWise
			aCols[1][ny] := CriaVar(aHeader[ny][2])
	EndCase
	aCols[1][Len(aHeader)+1] := .F.
Next ny

// monta o Header com os titulos do MsSelect
aADD(aCpos,{"D3_OK",""," ",""})
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SD3")
While !Eof() .And. X3_ARQUIVO = "SD3"
	If X3_BROWSE=="S" .And. X3_CONTEXT != "V"
		AADD(aCpos,{X3_CAMPO,"",AllTrim(X3Titulo()),X3_PICTURE})
	EndIf
	dbSkip()
End

DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
DEFINE MSDIALOG oDlg TITLE cCadastro From 30,15 To 375,625 OF oMainWnd PIXEL

oFolder := TFolder():New(1,1,aTitles,{},oDlg,,,, .T., .F.,305,172,)
For ni := 1 to Len(oFolder:aDialogs)
	DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[ni]
Next

@ 14,05 TO 16,320 Label "" Of oFolder:aDialogs[1] PIXEL 
@ 6,05 Say STR0019 Of oFolder:aDialogs[1] PIXEL FONT oBold //"Indices de Rateio das Movimentacoes"
oGetDados := MSGetDados():New(19,05,130,300,3,'PMSAFILOK','PMSAFITOK','+AFI_ITEM',.T.,,,,100,'PMSAFIFOK',,,,oFolder:aDialogs[1])

@140,175 BUTTON oButton1 PROMPT STR0020 SIZE 35, 10 OF oFolder:aDialogs[1] PIXEL ; //'&Incluir' //"Parametros"
		ACTION {|| Nil }

@140,210 BUTTON oButton2 PROMPT STR0021 SIZE 35, 10 OF oFolder:aDialogs[1] PIXEL ; //'&Incluir' //"Cancelar"
		ACTION {|| oDlg:End() }

@140,245 BUTTON oButton2 PROMPT STR0022 SIZE 35, 10 OF oFolder:aDialogs[1] PIXEL ; //'&Incluir' //"Confirmar"
		ACTION {|| If(oGetDados:TudoOk(),(A300GrvRQ(aMarca),oDlg:End()),Nil) }

oMark := MsSelect():New("SD3","D3_OK",,aCpos,@lInverte,@cMarca,{ 2,2,158,303},,,oFolder:aDialogs[2])
oMark:bMark := {|| A300AddMark(cMarca,@aMarca)}


ACTIVATE MSDIALOG oDlg



Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A300toNF³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Atualizacao das NF de Entrada do projeto.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A300toNF(cAlias,nReg,nOpcx,nLocTpNF)
Local aArea			:= GetArea()
Local cFilSF1 		:= ""
Local cFilOldSF1 	:= ""
Local aMemosBkp	:= {}

Do Case
	Case nOpcx == 1
        
		// VISUALIZAR

		cFilSF1 		:= PmsFilial("SF1","AFN")
		cFilOldSF1  := cFilAnt
		If cFilSF1 <> ""
			cFilAnt 	:= cFilSF1
		EndIf
		
		SF1->(dbSetOrder(1))
		If SF1->(dbSeek(xFilial()+AFN->AFN_DOC+AFN->AFN_SERIE+AFN->AFN_FORNECE+AFN->AFN_LOJA+AFN->AFN_TIPONF))
		
			If cPaisLoc == "BRA"
				MATA103(,,2)
	   		Else
				LOCXNF(Val(SF1->F1_TIPODOC), , , , , , 2)
			EndIf
		EndIf
   			
		cFilAnt := cFilOldSF1			
		
	Case nOpcx == 2
	
		// INCLUSÃO
		If PmsVldFase("AF8",AF8->AF8_PROJET,"83")
			If cPaisLoc == "BRA"
				If Type('aMemos') =="U"
					PRIVATE aMemos  :={{"AF1_CODMEM","AF1_OBS"}}
				EndIf

				aMemosBkp:= aClone(aMemos)
				aMemos:= Nil	
				
				MATA103(,,3)
				aMemos:= aClone(aMemosBkp)
			Else
				Do Case
					Case nLocTpNF == 1 //NFE
						Mata101n(,,,,3)
						
					Case nLocTpNF == 2 //NCC
						Mata465n(,,,,3,4)
					
					Case nLocTpNF == 3 //NAP
						Mata466n(,,,,3,9)

					Case nLocTpNF == 4
						Mata102n(,,,,3, 60)  //REMITO
						
				EndCase					
			EndIf
		Endif	

	Case nOpcx == 3
	
		// EXCLUSÃO
		cFilSF1 		:= PmsFilial("SF1","AFN")
		cFilOldSF1  := cFilAnt
		If cFilSF1 <> ""
			cFilAnt 	:= cFilSF1
		EndIf

		SF1->(dbSetOrder(1))
		If SF1->(dbSeek(xFilial()+AFN->AFN_DOC+AFN->AFN_SERIE+AFN->AFN_FORNECE+AFN->AFN_LOJA+AFN->AFN_TIPONF))

			If cPaisLoc == "BRA"
				MATA103(,,5)
	   		Else
				LOCXNF(Val(SF1->F1_TIPODOC), , , , , , 5)
			EndIf
		EndIf
		
		cFilAnt 		:= cFilOldSF1
EndCase

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS300FID³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Visualizacao das Despesas Financeiras do Projeto  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS300FID(oTree,lVisual,cArquivo)

Local cAlias	
Local nRecView	
Local aSize		:= MsAdvSize(,.F.,430)
Local aRotina   := {}         
Local lHabVis 	:= .T.
Local lHabInc	:= .T.
Local lHabExc	:= .T.

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

A300ValOp(cAlias,nRecView,"DESP",@lHabVis,@lHabInc,,@lHabExc)

aRotina 	:= If(lVisual,{	{ STR0003,"A300toFI", 0 , 2,,lHabVis}} , {	{ STR0003,"A300toFI", 0 , 2,  ,lHabVis},; //"Visualizar"
																		{ STR0014,"A300toFI", 0 , 3,  ,lHabInc},;	 //"Incluir"
																		{ STR0028,"A300toFI", 0 , 5, 1,lHabExc} } )//"Excluir"


If cAlias == "AF9" .And. nRecView<>0
	AF9->(dbGoto(nRecView))
	_cTarefa := AF9->AF9_TAREFA   //variavel utilizada x3_relacao Funcao PmsCpoInic()
	AFR->(dbSetOrder(1))
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0029+AllTrim(AF9->AF9_PROJET)+"/"+AF9->AF9_TAREFA+"]","AFR",,aRotina,,; //" - Despesas -["
	'xFilial("AFR")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
	'xFilial("AFR")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
	.F.,,,{{STR0038,1}},xFilial("AFR")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA) //"Prefixo + Num. Doc. + Parcela + Tipo + Cod. Fornecedor + Loja"
ElseIf cAlias == "AF8" .And. nRecView<>0
	AF8->(dbGoto(nRecView))
	_cTarefa := Space(Len(AF9->AF9_TAREFA))   //variavel utilizada x3_relacao Funcao PmsCpoInic()
	AFR->(dbSetOrder(1))
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0029+AllTrim(AF8->AF8_PROJET)+"]","AFR",,aRotina,,; //" - Despesas -["
	'xFilial("AFR")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
	'xFilial("AFR")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
	.F.,,,{{STR0039,1},{STR0038,4}},xFilial("AFR")+AF8->AF8_PROJET+AF8->AF8_REVISA) //"Tarefa + Prefixo + Num. Doc. + Parcela + Tipo + Cod. Fornecedor + Loja"
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A300toFI³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Atualizacao da Despesas do Projeto                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A300toFI(cAlias,nReg,nOpcx)
Local aArea			:= GetArea()
Local cFilOldSE2	:= ''
Local cFilSE2		:= ''

Do Case
	Case nOpcx == 1
		cFilSE2 		:= PmsFilial("SE2","AFR")
		cFilOldSE2 	:= cFilAnt
		If cFilSE2 <> ""
			cFilAnt 	:= cFilSE2
		EndIf
		
		SE2->(dbSetOrder(1))
		If SE2->(dbSeek(xFilial()+AFR->AFR_PREFIXO+AFR->AFR_NUM+AFR->AFR_PARCELA+AFR->AFR_TIPO+AFR->AFR_FORNEC+AFR->AFR_LOJA))
			FINA050(,,2)
		EndIf
		
		cFilAnt 		:= cFilOldSE2
		
	Case nOpcx == 2
		If PmsVldFase("AF8",AF8->AF8_PROJET,"82")
			FINA050(,,3)
		Endif	
		
	Case nOpcx == 3
		cFilSE2 		:= PmsFilial("SE2","AFR")
		cFilOldSE2 	:= cFilAnt
		If cFilSE2 <> ""
			cFilAnt 	:= cFilSE2
		EndIf
		
		SE2->(dbSetOrder(1))
		If SE2->(dbSeek(xFilial()+AFR->AFR_PREFIXO+AFR->AFR_NUM+AFR->AFR_PARCELA+AFR->AFR_TIPO+AFR->AFR_FORNEC+AFR->AFR_LOJA))
			FINA050(,,5)
		EndIf
		
		cFilAnt := cFilOldSE2
		
EndCase

RestArea(aArea)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS300D2³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Visualizacao das NF Saidas   vinculadas ao projeto³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS300D2(oTree,lVisual,cArquivo)

Local cAlias	
Local nRecView	
Local aSize		:= MsAdvSize(,.F.,430)
Local aRotina   := {}         
Local lHabVis 	:= .T.

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

A300ValOp(cAlias,nRecView,"NFS",@lHabVis,,,)

aRotina:= {{ STR0003,"A300toD2", 0 , 2,,lHabVis}} //"Visualizar"

If cAlias == "AF9" .And. nRecView<>0
	AF9->(dbGoto(nRecView))
	_cTarefa := AF9->AF9_TAREFA   //variavel utilizada x3_relacao Funcao PmsCpoInic()
	AFS->(dbSetOrder(1))
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0030+AllTrim(AF9->AF9_PROJET)+"/"+AF9->AF9_TAREFA+"]","AFS",,aRotina,,; //" - NF.Saida -["
	'xFilial("AFS")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
	'xFilial("AFS")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
	.F.,,,{{STR0040,1}},xFilial("AFS")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA) //"Cod. Produto + Armazem + Emissao + Num. Sequencial"
ElseIf cAlias == "AF8" .And. nRecView<>0
	AF8->(dbGoto(nRecView))
	_cTarefa := Space(Len(AF9->AF9_TAREFA))   //variavel utilizada x3_relacao Funcao PmsCpoInic()
	AFS->(dbSetOrder(1))
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0030+AllTrim(AF8->AF8_PROJET)+"]","AFS",,aRotina,,; //" - NF.Saida -["
	'xFilial("AFS")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
	'xFilial("AFS")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
	.F.,,,{{STR0041,1}},xFilial("AFS")+AF8->AF8_PROJET+AF8->AF8_REVISA) //"Tarefa + Cod. Produto + Armazem + Emissao + Num. Sequencial"
ElseIf cAlias=="AFC" .And. nRecView<>0 
	AFC->(dbGoto(nRecView))
	AFS->(dbSetOrder(3))
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0030+AllTrim(AFC->AFC_PROJET)+"/"+AFC->AFC_EDT+"]","AFS",,aRotina,,; //" - NF.Saida -["
	'xFilial("AFS")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT',;
	'xFilial("AFS")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT',;
	.F.,,,{{STR0040,1}},xFilial("AFS")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT) //"Cod. Produto + Armazem + Emissao + Num. Sequencial"
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A300toD2³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de chamada da rotina de visualizacao/exclusao da NFS.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A300toD2(cAlias,nReg,nOpcx)
Local aArea	:= GetArea()
Local aAreaSD2 := SD2->(GetArea())
Local cFilOldSF2	:= ''
Local cFilSF2	:= ''

Do Case
	Case nOpcx == 1
		cFilSF2 := PmsFilial("SF2","AFS")
		cFilOldSF2 := cFilAnt
		If cFilSF2 <> ""
			cFilAnt := cFilSF2
		EndIf
		
		SD2->(dbSetOrder(3))

		If SF2->(dbSeek(xFilial()+AFS->AFS_DOC+AFS->AFS_SERIE));
		   .And. SD2->(dbSeek(xFilial()+AFS->AFS_DOC+AFS->AFS_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		   
		   	If cPaisLoc == "BRA"
				A920NFSAI(cAlias,nReg,0)
			Else
				LOCXNF(Val(SF2->F2_TIPODOC), , , , , , 2)
			EndIf				
		Endif
		
		cFilAnt := cFilOldSF2
		
EndCase

RestArea(aAreaSD2) 
RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS300FIR³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Visualizacao das Receitas Financeiras do Projeto  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS300FIR(oTree,lVisual,cArquivo)

Local cAlias	
Local nRecView	
Local aSize		:= MsAdvSize(,.F.,430)
Local aRotina   := {}         
Local lHabVis 	:= .T.
Local lHabInc	:= .T.
Local lHabExc	:= .T.

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

A300ValOp(cAlias,nRecView,"RECEI",@lHabVis,@lHabInc,,@lHabExc)

aRotina:= If(lVisual,{	{ STR0003,"A300toFIR", 0 , 2,,lHabVis}} , {{ STR0003,"A300toFIR", 0 , 2,  ,lHabVis},; //"Visualizar"
								   									{ STR0014,"A300toFIR", 0 , 3,  ,lHabInc},;	 //"Incluir"
																	{ STR0028,"A300toFIR", 0 , 5, 1,lHabExc} } )//"Excluir"


If cAlias == "AF9" .And. nRecView<>0
	AF9->(dbGoto(nRecView))
	_cTarefa := AF9->AF9_TAREFA   //variavel utilizada x3_relacao Funcao PmsCpoInic()
	AFT->(dbSetOrder(1))
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0031+AllTrim(AF9->AF9_PROJET)+"/"+AF9->AF9_TAREFA+"]","AFT",,aRotina,,; //" - Receitas -["
	'xFilial("AFT")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
	'xFilial("AFT")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
	.F.,,,{{STR0042,1}},xFilial("AFT")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA) //"Prefixo + Num. Doc. + Parcela + Tipo + Cod. Cliente + Loja"
ElseIf cAlias == "AF8" .And. nRecView<>0
	AF8->(dbGoto(nRecView))
	_cTarefa := Space(Len(AF9->AF9_TAREFA))   //variavel utilizada x3_relacao Funcao PmsCpoInic()
	AFT->(dbSetOrder(1))
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0031+AllTrim(AF8->AF8_PROJET)+"]","AFT",,aRotina,,; //" - Receitas -["
	'xFilial("AFT")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
	'xFilial("AFT")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
	.F.,,,{{STR0043,1},{STR0042,7}},xFilial("AFT")+AF8->AF8_PROJET+AF8->AF8_REVISA) //"Tarefa + Prefixo + Num. Doc. + Parcela + Tipo + Cod. Cliente + Loja"
ElseIf cAlias == "AFC" .And. nRecView<>0
		AFC->(dbGoto(nRecView))
		AFT->(dbSetOrder(4))
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0031+AllTrim(AFC->AFC_PROJET)+"/"+AFC->AFC_EDT+"]","AFT",,aRotina,,; //" - Receitas -["
		'xFilial("AFT")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT',;
		'xFilial("AFT")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT',;
		.F.,,,{{STR0042,1}},xFilial("AFT")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT) //"Prefixo + Num. Doc. + Parcela + Tipo + Cod. Cliente + Loja"
EndIf


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A300toFIR³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Atualizacao das Receitas do Projeto               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A300toFIR(cAlias,nReg,nOpcx)
Local aArea			:= GetArea()
Local cFilOldSE1	:= ''
Local cFilSE1		:= ''


Do Case
	Case nOpcx == 1
		cFilSE1 		:= PmsFilial("SE1","AFT")
		cFilOldSE1 	:= cFilAnt
		If cFilSE1 <> ""
			cFilAnt := cFilSE1
		EndIf	
	
		SE1->(dbSetOrder(1))
		If SE1->(dbSeek(xFilial()+AFT->AFT_PREFIXO+AFT->AFT_NUM+AFT->AFT_PARCELA+AFT->AFT_TIPO+AFT->AFT_CLIENT+AFT->AFT_LOJA))
			FINA040(,2)
		EndIf
		
		cFilAnt 	:= cFilOldSE1

		
	Case nOpcx == 2
		If PmsVldFase("AF8",AF8->AF8_PROJET,"85")
			FINA040(,3)
		Endif	
		
	Case nOpcx == 3
		cFilSE1 		:= PmsFilial("SE1","AFT")
		cFilOldSE1 	:= cFilAnt
		If cFilSE1 <> ""
			cFilAnt := cFilSE1
		EndIf	
	
		SE1->(dbSetOrder(1))
		If SE1->(dbSeek(xFilial()+AFT->AFT_PREFIXO+AFT->AFT_NUM+AFT->AFT_PARCELA+AFT->AFT_TIPO+AFT->AFT_CLIENT+AFT->AFT_LOJA))
			FINA040(,5)
		EndIf
		
		cFilAnt 	:= cFilOldSE1

EndCase

RestArea(aArea)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A300CtrMenu³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que controla as propriedades do Menu PopUp.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA300                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A300CtrMenu(oMenu,oTree,cArquivo)
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

		// verifica a permissao para as Requisicoes
		If PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT))," ",2,"REQUIS",AF8->AF8_REVISA)
			oMenu:aItems[1]:Enable()
		Else
			oMenu:aItems[1]:Disable()
		EndIf

		// verifica a permissao para a Nota Fiscal de Entrada
		If PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT))," ",2,"NFE",AF8->AF8_REVISA)
			oMenu:aItems[2]:Enable()
		Else
			oMenu:aItems[2]:Disable()
		EndIf

		// verifica a permissao para as Despesas
		If PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT))," ",2,"DESP",AF8->AF8_REVISA)
			oMenu:aItems[3]:Enable()
		Else
			oMenu:aItems[3]:Disable()
		EndIf

		// verifica a permissao para Apont.Recursos
		If PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT))," ",2,"RECURS",AF8->AF8_REVISA)
			oMenu:aItems[4]:Enable()
		Else
			oMenu:aItems[4]:Disable()
		EndIf
	    
		// verifica a permissao para NFS
		If PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT))," ",2,"NFS",AF8->AF8_REVISA)
			oMenu:aItems[5]:Enable()
		Else
			oMenu:aItems[5]:Disable()
		EndIf

		// verifica a permissao para Receitas
		If PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT))," ",2,"RECEI",AF8->AF8_REVISA)
			oMenu:aItems[6]:Enable()
		Else
			oMenu:aItems[6]:Disable()
		EndIf


		If PmsSE5()

			// verifica a permissao para Movimento Bancario
			If PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT))," ",2,"MOVBAN",AF8->AF8_REVISA)
				oMenu:aItems[7]:Enable()
			Else
				oMenu:aItems[7]:Disable()
			EndIf
		EndIf

	Case cAlias=="AF9"

		// verifica a permissao para as Requisicoes
		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,2,"REQUIS",AF9->AF9_REVISA)
			oMenu:aItems[1]:Enable()
			If Len(oMenu:aItems)>9
				oMenu:aItems[10]:Enable()
			EndIF
		Else
			oMenu:aItems[1]:Disable()
			If Len(oMenu:aItems)>9
				oMenu:aItems[10]:Disable()
			EndIF

		EndIf

		// verifica a permissao para a Nota Fiscal de Entrada
		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,2,"NFE",AF9->AF9_REVISA)
			oMenu:aItems[2]:Enable()
		Else
			oMenu:aItems[2]:Disable()
		EndIf

		// verifica a permissao para as Despesas
		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,2,"DESP",AF9->AF9_REVISA)
			oMenu:aItems[3]:Enable()
		Else
			oMenu:aItems[3]:Disable()
		EndIf

		// verifica a permissao para Pre.Recursos
		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,2,"PREREC",AF9->AF9_REVISA)
			oMenu:aItems[4]:Enable()
		Else
			oMenu:aItems[4]:Disable()
		EndIf
				
		// verifica a permissao para Apont.Recursos
		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,2,"APRPRE",AF9->AF9_REVISA)
			oMenu:aItems[5]:Enable()
		Else
			oMenu:aItems[5]:Disable()
		EndIf

		// verifica a permissao para Apont.Recursos
		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,2,"RECURS",AF9->AF9_REVISA)
			oMenu:aItems[6]:Enable()
		Else
			oMenu:aItems[6]:Disable()
		EndIf	    
		// verifica a permissao para NFS
		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,2,"NFS",AF9->AF9_REVISA)
			oMenu:aItems[7]:Enable()
		Else
			oMenu:aItems[7]:Disable()
		EndIf

		// verifica a permissao para Receitas
		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,2,"RECEI",AF9->AF9_REVISA)
			oMenu:aItems[8]:Enable()
		Else
			oMenu:aItems[8]:Disable()
		EndIf

		If PmsSE5()

			// verifica a permissao para Movimento Bancario
			If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,2,"MOVBAN",AF9->AF9_REVISA)
				oMenu:aItems[9]:Enable()
			Else
				oMenu:aItems[9]:Disable()
			EndIf
		EndIf

	Case cAlias$"AFC" 
		oMenu:aItems[1]:Disable()
		oMenu:aItems[2]:Disable()
		oMenu:aItems[3]:Disable()
		oMenu:aItems[4]:Disable()

		// verifica a permissao para NFS
		If PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,2,"NFS",AFC->AFC_REVISA)
			oMenu:aItems[5]:Enable()
		Else
			oMenu:aItems[5]:Disable()
		EndIf

		// verifica a permissao para Receitas
		If PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,2,"RECEI",AFC->AFC_REVISA)
			oMenu:aItems[6]:Enable()
		Else
			oMenu:aItems[6]:Disable()
		EndIf

		If PmsSE5()

			// verifica a permissao para Movimento Bancario
			If PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,2,"MOVBAN",AFC->AFC_REVISA)
				oMenu:aItems[7]:Enable()
			Else
				oMenu:aItems[7]:Disable()
			EndIf
		EndIf

	OtherWise
		oMenu:aItems[1]:Disable()
		oMenu:aItems[2]:Disable()
		oMenu:aItems[3]:Disable()
		oMenu:aItems[4]:Disable()
		oMenu:aItems[5]:Disable()
		oMenu:aItems[6]:Disable()
		If PmsSE5()
			oMenu:aItems[7]:Disable()
		EndIf
EndCase


RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS300REC³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Browse de Visualizacao/Inclusao/Alteracao dos apontamentos    ³±±
±±³          ³de recursos.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS300REC(oTree,lVisual,cArquivo)

Local cAlias	
Local nRecView	
Local aSize		:= MsAdvSize(,.F.,430)
Local lHabVis 	:= .T.
Local lHabInc	:= .T.
Local lHabAlt	:= .T.
Local lHabExc	:= .T.
PRIVATE aGetCpo
PRIVATE aRotina	

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

A300ValOp(cAlias,nRecView,"RECURS",@lHabVis,@lHabInc,@lHabAlt,@lHabExc)

aRotina	:= If(lVisual,{{ STR0003,"A300toREC", 0 , 2,,lHabVis}},{{ STR0003,"A300toREC", 0 , 2,  ,lHabVis},;  //"Visualizar"###"Visualizar"
																  { STR0014,"A300toREC", 0 , 3,  ,lHabInc},; //"Incluir"
																  { STR0075,"A300toREC", 0 , 3,  ,lHabInc},; //"Incl.Periodo"
																  { STR0092,"A300toREC", 0 , 3,  ,lHabInc},; //"Excl.Periodo"
																  { STR0076,"A300toREC", 0 , 3,  ,lHabInc},; //"Iniciar Uso"
																  { STR0077,"A300toREC", 0 , 4,  ,lHabAlt},; //"Final. Uso"
																  { STR0044,"A300toREC", 0 , 4,  ,lHabAlt},;//"Alterar"
													   		  { STR0028,"A300toREC", 0 , 5, 5,lHabExc} } ) //"Excluir"
FATPDLogUser("PMS300REC")	
If PmsChkAFU(.T.)
	If cAlias == "AF9" .And. nRecView<>0
		AF9->(dbGoto(nRecView))
		_cTarefa := AF9->AF9_TAREFA   //variavel utilizada x3_relacao Funcao PmsCpoInic()
		AFU->(dbSetOrder(1))
		aGetCpo := {	{"AFU_PROJET",AF9->AF9_PROJET,.F.},;
						{"AFU_REVISA",AF9->AF9_REVISA,.F.},;
						{"AFU_TAREFA",AF9->AF9_TAREFA,.F.} }
	
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0045+AllTrim(AF9->AF9_PROJET)+"/"+AF9->AF9_TAREFA+"]","AFU",,aRotina,,;  //" - Recursos -["
		'xFilial("AFU")+"1"+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
		'xFilial("AFU")+"1"+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
		.F.,,,{{STR0046,1},{STR0072,5}},xFilial("AFU")+"1"+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA) //"Codigo do Recurso + Data" //"Data + Codigo do Recurso"
	ElseIf cAlias == "AF8" .And. nRecView<>0
		AF8->(dbGoto(nRecView))
		_cTarefa := Space(Len(AF9->AF9_TAREFA))   //variavel utilizada x3_relacao Funcao PmsCpoInic()
		AFU->(dbSetOrder(1))
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0045+AllTrim(AF8->AF8_PROJET)+"]","AFU",,aRotina,,; //" - Recursos -["
		'xFilial("AFU")+"1"+AF8->AF8_PROJET+AF8->AF8_REVISA',;
		'xFilial("AFU")+"1"+AF8->AF8_PROJET+AF8->AF8_REVISA',;
		.F.,,,{{STR0047,1},{STR0046,4},{STR0072,6}},xFilial("AFU")+"1"+AF8->AF8_PROJET+AF8->AF8_REVISA) //"Tarefa + Codigo do Recurso + Data" //"Data + Codigo do Recurso"
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A300toREC³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Visualizacao/Inclusao/Alteracao dos apontamentos  ³±±
±±³          ³de recursos.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A300toREC(cAlias,nReg,nOpcx)

Do Case
	Case nOpcx == 1
		PMSA320(,2)
	Case nOpcx == 2
		PMSA320(,3,aGetCpo)
	Case nOpcx == 3
		PMSA320(,4,aGetCpo)
	Case nOpcx == 4
		PMSA320(,5,aGetCpo)			
	Case nOpcx == 5
		PMSA320(,6,aGetCpo)
	Case nOpcx == 6
		PMSA320(,7,aGetCpo)
	Case nOpcx == 7
		PMSA320(,8)
	Case nOpcx == 8
		PMSA320(,9)
EndCase

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS300ADI³ Autor ³ Edson Maricate         ³ Data ³ 02-06-2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Browse de Visualizacao/Inclusao/Alteracao dos apontamentos    ³±±
±±³          ³diretos.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS300ADI(oTree,lVisual,cArquivo)

Local cAlias	
Local nRecView	
Local aSize		:= MsAdvSize(,.F.,430)
Local lHabVis 	:= .T.
Local lHabInc	:= .T.
Local lHabAlt	:= .T.
Local lHabExc	:= .T.
PRIVATE aGetCpo
PRIVATE aRotina	

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

	aRotina	:= If(lVisual,{{ STR0003,"A300toADI", 0 , 2,,lHabVis}},{{ STR0003,"A300toADI", 0 , 2,  ,lHabVis},;//"Visualizar"###"Visualizar"
																	  			{ STR0014,"A300toADI", 0 , 3,  ,lHabInc},;//"Incluir"
																	 			{ STR0044,"A300toADI", 0 , 4,  ,lHabAlt},;//"Alterar"
														   		  				{ STR0028,"A300toADI", 0 , 5, 5,lHabExc}})//"Excluir"
	
If PmsChkAJC(.T.)
	If cAlias == "AF9" .And. nRecView<>0
		AF9->(dbGoto(nRecView))
		_cTarefa := AF9->AF9_TAREFA   //variavel utilizada x3_relacao Funcao PmsCpoInic()
		AJC->(dbSetOrder(1))
		aGetCpo := {	{"AJC_PROJET",AF9->AF9_PROJET,.F.},;
						{"AJC_REVISA",AF9->AF9_REVISA,.F.},;
						{"AJC_TAREFA",AF9->AF9_TAREFA,.F.} }
	
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0106+AllTrim(AF9->AF9_PROJET)+"/"+AF9->AF9_TAREFA+"]","AJC",,aRotina,,;  //" - Apontamento Direto -["
		'xFilial("AJC")+"1"+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
		'xFilial("AJC")+"1"+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
		.F.,,,{{STR0046,1},{STR0072,5}},xFilial("AJC")+"1"+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA) //"Codigo do Recurso + Data" //"Data + Codigo do Recurso"
	ElseIf cAlias == "AF8" .And. nRecView<>0
		AF8->(dbGoto(nRecView))
		_cTarefa := Space(Len(AF9->AF9_TAREFA))   //variavel utilizada x3_relacao Funcao PmsCpoInic()
		AJC->(dbSetOrder(1))
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0106+AllTrim(AF8->AF8_PROJET)+"]","AJC",,aRotina,,; //" - Apontamento Direto -["
		'xFilial("AJC")+"1"+AF8->AF8_PROJET+AF8->AF8_REVISA',;
		'xFilial("AJC")+"1"+AF8->AF8_PROJET+AF8->AF8_REVISA',;
		.F.,,,{{STR0047,1},{STR0046,4},{STR0072,6}},xFilial("AJC")+"1"+AF8->AF8_PROJET+AF8->AF8_REVISA) //"Tarefa + Codigo do Recurso + Data" //"Data + Codigo do Recurso"
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A300toADI³ Autor ³ Edson Maricate         ³ Data ³ 02-06-2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Visualizacao/Inclusao/Alteracao dos apontamentos  ³±±
±±³          ³diretos.                                                  	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A300toADI(cAlias,nReg,nOpcx)

Do Case
	Case nOpcx == 1
		PMSA510(,2)
	Case nOpcx == 2
		PMSA510(,3,aGetCpo)
	Case nOpcx == 3
		PMSA510(,4,aGetCpo)
	Case nOpcx == 4
		PMSA510(,5,aGetCpo)			
EndCase

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A300toRECI³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de gravacao dos dados complementares dos apontamentos³±±
±±³          ³de recursos.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A300toRECI()

Local aArea		:= GetArea()
Local aAreaSB1	:= {}
Local aArraySD3	:= {}
Local cLocPad	:= ""
Local nValor    := 0

dbSelectArea("AE8")
dbSetOrder(1)
dbSeek(xFilial()+AFU->AFU_RECURS)
If !Empty(AE8->AE8_TMPAD) .And. !Empty(AE8->AE8_PRODUT)

	aAreaSB1 := SB1->(GetArea())
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+AE8->AE8_PRODUT))
	
	cLocPad	:= PMSReadValue("AF8", 1, xFilial("AF8") + AFU->AFU_PROJET, "AF8_LOCPAD", "")
	If Empty(cLocPad) 
		cLocPad	:= RetFldProd(SB1->B1_COD,"B1_LOCPAD")
	EndIf
	
	// verifica se o tipo de movimentação é valorizado ou não				
	// F5_VAL
	If PMSReadValue("SF5", 1, xFilial("SF5") + AE8->AE8_TMPAD, "F5_VAL", "N") == "S"

		If AE8->AE8_CUSFIX > 0
			nValor := AE8->AE8_CUSFIX
		Else
			nValor := RetFldProd(SB1->B1_COD,"B1_CUSTD")
		EndIf
	EndIf

	aArraySD3 	:= {	{"D3_TM"      ,AE8->AE8_TMPAD  ,Nil},;
						{"D3_COD"     ,AE8->AE8_PRODUT ,Nil},;
			          	{"D3_LOCAL"   ,cLocPad         ,Nil}, ;
						{"D3_QUANT"   ,AFU->AFU_HQUANT ,Nil},;
						{"D3_EMISSAO" ,AFU->AFU_DATA   ,Nil},;
						{"D3_CUSTO1"  ,NoRound(AFU->AFU_HQUANT*nValor),Nil},;
						{"D3_PROJPMS" ,AFU->AFU_PROJET ,Nil},;
						{"D3_TASKPMS" ,AFU->AFU_TAREFA ,Nil}}
	MATA240(aArraySD3)
	RestArea(aAreaSB1)
EndIf


RestArea(aArea)
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS300HRI³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da hora inicial informada no apontamento do recurso.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS300HRI(cHora)
Local aArea		  := GetArea()
Local aAreaAE8	  := AE8->(GetArea())
Local aAreaAFU	  := AFU->(GetArea())
Local cHoraF      := ""
Local cRecurso    := ""
Local lRet		  := .T.
Local nInterv     := 60 / GetMV("MV_PRECISA")
Local x           := 0
Local nX          := 0
Local dData
Local nPos_RECURS := 0
Local nPos_DATA   := 0
Local nPos_HORAI  := 0
Local nPos_HORAF  := 0

If l320
	cRecurso := M->AFU_RECURS
	dData	 := M->AFU_DATA
	cHoraF	 := M->AFU_HORAF
Else
	nPos_RECURS := aScan(aHeader,{|x|AllTrim(x[2])=="AFU_RECURS"})
	nPos_DATA   := aScan(aHeader,{|x|AllTrim(x[2])=="AFU_DATA"})
	nPos_HORAI  := aScan(aHeader,{|x|AllTrim(x[2])=="AFU_HORAI"})
	nPos_HORAF  := aScan(aHeader,{|x|AllTrim(x[2])=="AFU_HORAF"})
	cRecurso	:= aCols[n ,nPos_RECURS]
	dData		:= aCols[n ,nPos_DATA]
	cHoraF		:= aCols[n ,nPos_HORAF]
EndIf

cHora := AjustaHr(cHora, GetMV("MV_PRECISA"))
cHoraF := AjustaHr(cHoraF, GetMV("MV_PRECISA"))

//
// Conforme ISO 8601, o formato de hora de um dia deve ser efetuado da seguinte forma:
//
// Primeira hora do dia é 00:00 
// Ultima hora do dia é 23:59
//
// Sempre que se estiver se referindo a 1 dia.
//
//If cHora == "24:00"
//	cHora := "23:59"
//EndIf

M->AFU_HORAI := cHora

If !Empty(cRecurso) .And. !Empty(dData)
	dbSelectArea("AE8")
	dbSetOrder(1)
	MsSeek(xFilial('AE8')+cRecurso)

	If AE8->AE8_UMAX <= 100 
		If !l320 
			For nX := 1 to Len(aCols)
				If !(nX == n ) .AND. !aCols[nX][Len(aHeader)+1] ;
					.AND. cRecurso == aCols[nX][nPos_RECURS]  .AND. dData == aCols[nX][nPos_DATA]
					If (;
				       	(Substr(cHora,1,2) + Substr(cHora,4,2) >= Substr(aCols[nX][nPos_HORAI],1,2) + Substr(aCols[nX][nPos_HORAI],4,2) .And.;
				       	Substr(cHora,1,2) + Substr(cHora,4,2) < Substr(aCols[nX][nPos_HORAF],1,2) + Substr(aCols[nX][nPos_HORAF],4,2));
				       	.Or. ;
				       	(Substr(cHora,1,2)  + Substr(cHora,4,2)  < Substr(aCols[nX][nPos_HORAI],1,2) + Substr(aCols[nX][nPos_HORAI],4,2) .And.;
				       	Substr(cHoraF,1,2) + Substr(cHoraF,4,2) > Substr(aCols[nX][nPos_HORAI],1,2) + Substr(aCols[nX][nPos_HORAI],4,2));
				       )
						Aviso(STR0062,STR0063,{STR0022},2) //"Atencao!"###"Ja existem apontamentos gravados para este recurso neste periodo. Verifique a hora informada" //"Ok"
						lRet := .F.
						Exit
					EndIf
				EndIf
			Next nX
		EndIf

		If lRet
			dbSelectArea("AFU")
			dbSetOrder(3)
			dbSeek(xFilial("AFU") + "1" + cRecurso + DTOS(dData))
			While !Eof() .And. lRet .And. xFilial("AFU") + "1" + cRecurso + DTOS(dData) ==;
									AFU->AFU_FILIAL + AFU->AFU_CTRRVS + AFU->AFU_RECURS + DTOS(AFU->AFU_DATA)
				If nRecAlt != RecNo() .And. ;
				        (;
				        (Substr(cHora,1,2) + Substr(cHora,4,2) >= Substr(AFU->AFU_HORAI,1,2) + Substr(AFU->AFU_HORAI,4,2) .And.;
				         Substr(cHora,1,2) + Substr(cHora,4,2) < Substr(AFU->AFU_HORAF,1,2) + Substr(AFU->AFU_HORAF,4,2));
				        .Or. ;
				        (Substr(cHora,1,2)  + Substr(cHora,4,2)  < Substr(AFU->AFU_HORAI,1,2) + Substr(AFU->AFU_HORAI,4,2) .And.;
				         Substr(cHoraF,1,2) + Substr(cHoraF,4,2) > Substr(AFU->AFU_HORAI,1,2) + Substr(AFU->AFU_HORAI,4,2));
				        )
					If !FWIsInCallStack("Pms320Per")
						Aviso(STR0062,STR0063,{STR0022},2) //"Atencao!"###"Ja existem apontamentos gravados para este recurso neste periodo. Verifique a hora informada" //"Ok"
					EndIf
					lRet := .F.
					Exit
				EndIf
				dbSkip()
			EndDo
		EndIf
	EndIf
	If lRet .And. !Empty(cHoraF)
		If l320
			M->AFU_HQUANT := PmsHrsItvl(M->AFU_DATA,cHora,M->AFU_DATA,M->AFU_HORAF,AE8->AE8_CALEND,M->AFU_PROJET,cRecurso,,.T.)
			Pms320Cust(M->AFU_HQUANT)
		Else
			aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFU_HQUANT"})] := PmsHrsItvl(dData,cHora,dData,cHoraF,AE8->AE8_CALEND,aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFU_PROJET"})],cRecurso,,.T.)
			Pms320Cust(aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFU_HQUANT"})])
		EndIf
	EndIf
EndIf

RestArea(aAreaAFU)
RestArea(aAreaAE8)
RestArea(aArea)
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS300HRF³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da hora final informada no apontamento do recurso.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS300HRF(cHora)

Local aArea		:= GetArea()
Local aAreaAE8	:= AE8->(GetArea())
Local aAreaAFU	:= AFU->(GetArea())
Local aAreaAJK	:= AJK->(GetArea())
Local cHoraI    := ""
Local cRecurso  := ""
Local nInterv   := 60 / GetMV("MV_PRECISA")
Local x         := 0
Local nX        := 0
Local lRet	    := .T.
Local dData
Local nPos_RECURS := 0
Local nPos_DATA   := 0
Local nPos_HORAI  := 0
Local nPos_HORAF  := 0
Local cMsgAux

If l320
	cRecurso := M->AFU_RECURS
	dData	 := M->AFU_DATA
	cHoraI	 := Iif(Len(M->AFU_HORAI) == 4,Substr(M->AFU_HORAI,1,3)+"0"+Substr(M->AFU_HORAI,4,5),M->AFU_HORAI)
Else
	nPos_RECURS := aScan(aHeader,{|x|AllTrim(x[2])=="AFU_RECURS"})
	nPos_DATA   := aScan(aHeader,{|x|AllTrim(x[2])=="AFU_DATA"})
	nPos_HORAI  := aScan(aHeader,{|x|AllTrim(x[2])=="AFU_HORAI"})
	nPos_HORAF  := aScan(aHeader,{|x|AllTrim(x[2])=="AFU_HORAF"})
	cRecurso	:= aCols[n ,nPos_RECURS]
	dData		:= aCols[n ,nPos_DATA]
	cHoraI		:= aCols[n ,nPos_HORAI]
EndIf

cHora := AjustaHr(cHora, GetMV("MV_PRECISA"))
cHoraI := AjustaHr(cHoraI, GetMV("MV_PRECISA"))

//
// Conforme ISO 8601, o formato de hora de um dia deve ser efetuado da seguinte forma:
//
// Primeira hora do dia é 00:00 
// Ultima hora do dia é 23:59
//
// Sempre que se estiver se referindo a 1 dia.
//
//If cHora == "24:00"
//	cHora := "23:59"
//EndIf

M->AFU_HORAF := cHora

If !Empty(cRecurso) .And. !Empty(dData)

	dbSelectArea("AE8")
	dbSetOrder(1)
	MsSeek(xFilial('AE8')+cRecurso)
	
	If AE8->AE8_UMAX <= 100 
	
		If !l320
			For nX := 1 to Len(aCols)
				If !(nX == n ) .AND. !aCols[nX][Len(aHeader)+1] ;
				.AND. cRecurso == aCols[nX][nPos_RECURS] .AND. dData == aCols[nX][nPos_DATA]
					If (;
				        (Substr(cHora,1,2) + Substr(cHora,4,2) > Substr(aCols[nX][nPos_HORAI],1,2) + Substr(aCols[nX][nPos_HORAI],4,2)   .And.;
				         Substr(cHora,1,2) + Substr(cHora,4,2) < Substr(aCols[nX][nPos_HORAF],1,2) + Substr(aCols[nX][nPos_HORAF],4,2));
				         .Or.;
				        (Substr(cHora,1,2)  + Substr(cHora,4,2)  >= Substr(aCols[nX][nPos_HORAF],1,2) + Substr(aCols[nX][nPos_HORAF],4,2) .And.;
				         Substr(cHoraI,1,2) + Substr(cHoraI,4,2) < Substr(aCols[nX][nPos_HORAF],1,2) + Substr(aCols[nX][nPos_HORAF],4,2));
				        )
						Aviso(STR0062,STR0063,{STR0022},2) //"Atencao!"###"Ja existem apontamentos gravados para este recurso neste periodo. Verifique a hora informada" //"Ok"
						lRet := .F.
						Exit
					EndIf
				EndIf
			Next nX
			
		EndIf
	    
		If lRet
			dbSelectArea("AFU")
			dbSetOrder(3)
			dbSeek(xFilial("AFU")+"1"+cRecurso+DTOS(dData))
			While !Eof() .And. lRet .And. xFilial("AFU")+"1"+cRecurso+DTOS(dData)==;
								AFU->AFU_FILIAL+AFU->AFU_CTRRVS+AFU->AFU_RECURS+DTOS(AFU->AFU_DATA)
				If nRecAlt != RecNo() .And. ;
				             (;
				             (Substr(cHora,1,2) + Substr(cHora,4,2) > Substr(AFU->AFU_HORAI,1,2) + Substr(AFU->AFU_HORAI,4,2)   .And.;
				              Substr(cHora,1,2) + Substr(cHora,4,2) < Substr(AFU->AFU_HORAF,1,2) + Substr(AFU->AFU_HORAF,4,2));
				              .Or.;
				             (Substr(cHora,1,2)  + Substr(cHora,4,2)  >= Substr(AFU->AFU_HORAF,1,2) + Substr(AFU->AFU_HORAF,4,2) .And.;
				              Substr(cHoraI,1,2) + Substr(cHoraI,4,2) < Substr(AFU->AFU_HORAF,1,2) + Substr(AFU->AFU_HORAF,4,2));
				             )
					lRet := .F.
					cMsgAux := STR0093+" "+STR0095+" "+Alltrim(cRecurso)+", "+STR0096+" "+DTOC(dData)+", "+STR0097+" "+cHoraI+", "+STR0098+" "+cHora+CRLF //"Tentativa de apontamento:"#"Recurso"#"Data"#"Hora Ini"#"Hora Fim"
					cMsgAux += STR0094+" "+STR0095+" "+Alltrim(AFU->AFU_RECURS)+", "+STR0096+" "+DTOC(AFU->AFU_DATA)+", "+STR0097+" "+AFU->AFU_HORAI+", "+STR0098+" "+AFU->AFU_HORAF+", "+STR0099+" "+AFU->AFU_FILIAL+", "+STR0100+" "+AFU->AFU_PROJET+", "+STR0101+" "+AFU->AFU_REVISA+", "+STR0102+" "+AFU->AFU_TAREFA+CRLF //"Apontamento registrado:"#"Recurso"#"Data"#"Hora Ini"#"Hora Fim"#"Filial"#"Projeto"#"Revisao"#"Tarefa"
					If !FWIsInCallStack("Pms320Per")
						Aviso(STR0062,STR0063+CRLF+cMsgAux,{STR0022},2) //"Atencao!"###"Ja existem apontamentos gravados para este recurso neste periodo. Verifique a hora informada" //"Ok"
					EndIf
					Exit
				EndIf
				dbskip()
			EndDo
		EndIf
	EndIf
	
	If lRet .And. !Empty(cHoraI)
		If SubStr(cHora,1,2)+Substr(cHora,4,2) < Substr(cHoraI,1,2)+Substr(cHoraI,4,2)
			Aviso(STR0064,STR0065,{STR0022},2) //"Atencao"###"A hora final nao podera ser menor que a hora inicial. Verifique a hora digitada" //'Ok'
			lRet := .F.
		EndIf
	EndIf
	If lRet .And. !Empty(cHoraI)
		AE8->(dbSetOrder(1))
		AE8->(dbSeek(xFilial()+cRecurso))
		If l320
			M->AFU_HQUANT := PmsHrsItvl(M->AFU_DATA,M->AFU_HORAI,M->AFU_DATA,cHora,AE8->AE8_CALEND,M->AFU_PROJET,cRecurso,,.T.)
			Pms320Cust(M->AFU_HQUANT)
		Else
			aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFU_HQUANT"})] := PmsHrsItvl(dData,cHoraI,dData,cHora,AE8->AE8_CALEND,aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFU_PROJET"})],cRecurso,,.T.)
			Pms320Cust(aCols[n][aScan(aHeader,{|x|Alltrim(x[2])=="AFU_HQUANT"})])			
		EndIf
	EndIf
	
EndIf

RestArea(aAreaAJK)
RestArea(aAreaAFU)
RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS300HQT³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao quantidade de horas informada no apontamento.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS300HQT(nQuant)
Local lRet		:= .T.
Local cHoraI
Local cHoraF
Local cHoraD

If l320
	cHoraI	:= M->AFU_HORAI
	cHoraF	:= M->AFU_HORAF
Else
	cHoraI	:= aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="AFU_HORAI"})]
	cHoraF	:= aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="AFU_HORAF"})]
EndIf

If l320
	AE8->(dbSetOrder(RetOrder("AE8","AE8_FILIAL+ AE8_RECURS+ AE8_DESCRI")))
	AE8->(dbSeek(xFilial()+M->AFU_RECURS))
	cHoraD := PmsHrsItvl(M->AFU_DATA,M->AFU_HORAI,M->AFU_DATA,M->AFU_HORAF,AE8->AE8_CALEND,M->AFU_PROJET,M->AFU_RECURS,,.T.)
Else
	cHoraD	:= (Val(SubStr(cHoraF,1,2))-Val(SubStr(cHoraI,1,2))+(Val(SubStr(cHoraF,4,2))/60)-(Val(SubStr(cHoraI,4,2))/60))
EndIF

If nQuant > (Val(SubStr(cHoraF,1,2))-Val(SubStr(cHoraI,1,2))+(Val(SubStr(cHoraF,4,2))/60)-(Val(SubStr(cHoraI,4,2))/60)) .Or. nQuant > 24
	lRet := .F.
ElseIf	nQuant < cHoraD
	IF MSGYESNO(STR0103 + " " + STR0104) //A quantidade de horas informada é menor que a quantidade de horas apontada. Deseja Gravar o apontamento?
		Pms320Cust(nQuant)
	Else
		lRet := .F.
	EndIf	
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS300PRJ³ Autor ³ Reynaldo Miyashita     ³ Data ³ 22-08-2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao do codigo do projeto informado no apontamento.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS300PRJ(cProjet)
Local aArea  := GetArea()
Local lRet   := .T.

	dbSelectArea("AF8")
	dbSetOrder(1)
	If dbSeek(xFilial("AF8")+cProjet)
		
		// se a fase do projeto permite apontamento de recursos
		If (!Visual .OR. Exclui) .and. !PmsVldFase("AF8", cProjet, "86")
			lRet   := .F.
		EndIf
		
	Else 
		Help(" " ,1 ,"REGNOIS")
	EndIf

	RestArea(aArea)
	
Return( lRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A300ValOp  ³ Autor ³Fabio Rogerio Pereira ³ Data ³ 07-01-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que verifica as permissoes do usuario.		            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA300                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A300ValOp(cAlias,nRecView,cCampo,lHabVis,lHabInc,lHabAlt,lHabExc)
Local aArea		:= GetArea()

dbSelectArea(cAlias)
dbGoto(nRecView)

Do Case 
	Case cAlias == "AF8"

		// verifica a permissao para o Projeto
		If PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)),"  ",4,cCampo,AF8->AF8_REVISA)//Controle Total
			lHabVis:= .T.
			lHabInc:= .T.
			lHabAlt:= .T.
			lHabExc:= .T.
		ElseIf PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)),"  ",3,cCampo,AF8->AF8_REVISA)//Alterar
			lHabVis:= .T.
			lHabAlt:= .T.
			lHabInc:= .F.
			lHabExc:= .F.
		ElseIf PmsChkUser(AF8->AF8_PROJET,,Padr(AF8->AF8_PROJET,Len(AFC->AFC_EDT)),"  ",2,cCampo,AF8->AF8_REVISA)//Visualizar
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

	Case cAlias == "AF9"
      
		// verifica a permissao para a Tarefa
		If PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,IIF(cCampo=="APRPRE",2,4),cCampo,AF9->AF9_REVISA)//Controle Total
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

	Case cAlias == "AFC" 

		// verifica a permissao para a EDT
		If PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,4,cCampo,AFC->AFC_REVISA)//Controle Total
			lHabVis:= .T.
			lHabInc:= .T.
			lHabAlt:= .T.
			lHabExc:= .T.
		ElseIf PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,3,cCampo,AFC->AFC_REVISA)//Alterar
			lHabVis:= .T.
			lHabAlt:= .T.
			lHabInc:= .F.
			lHabExc:= .F.
		ElseIf PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,2,cCampo,AFC->AFC_REVISA)//Visualizar
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


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS300Mov³ Autor³Fabio Rogerio Pereira    ³ Data ³ 31-01-2002   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Visualizacao dos Mov.Bancarios vinculadas ao projeto³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS300MOV(oTree,lVisual,cArquivo)

Local cAlias	
Local nRecView	
Local aIndexSE5 := {}
Local aSize		:= MsAdvSize(,.F.,430)
Local aRotina   := {}         
Local lHabVis 	:= .T.
Local lHabInc	:= .T.
Local lHabAlt	:= .T.

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

A300ValOp(cAlias,nRecView,"MOVBAN",@lHabVis,@lHabInc,@lHabAlt)

aRotina:= {{ STR0003,"A300toMOV", 0 , 2,,lHabVis}} //"Visualizar"

If PmsChkAJE(.F.)
	If cAlias == "AF9" .And. nRecView<>0
		AF9->(dbGoto(nRecView))
		_cTarefa := AF9->AF9_TAREFA   //variavel utilizada x3_relacao Funcao PmsCpoInic()
		AJE->(dbSetOrder(1))
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0052+AllTrim(AF9->AF9_PROJET)+"/"+AF9->AF9_TAREFA+"]","AJE",,aRotina,,; 
		'xFilial("AJE")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
		'xFilial("AJE")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
		.F.,,,{{STR0078,1}},xFilial("AJE")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA) //"Data do Movimento"
	ElseIf cAlias == "AF8" .And. nRecView<>0
		AF8->(dbGoto(nRecView))
		_cTarefa := Space(Len(AF9->AF9_TAREFA))   //variavel utilizada x3_relacao Funcao PmsCpoInic()
		AJE->(dbSetOrder(1))
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0052+AllTrim(AF8->AF8_PROJET)+"]","AJE",,aRotina,,; 
		'xFilial("AJE")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
		'xFilial("AJE")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
		.F.,,,{{STR0079,1}},xFilial("AJE")+AF8->AF8_PROJET+AF8->AF8_REVISA) //"Cod Tarefa + Data do Movimento"
	ElseIf cAlias=="AFC" .And. nRecView<>0 
		AFC->(dbGoto(nRecView))
		AJE->(dbSetOrder(2))
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0052+AllTrim(AFC->AFC_PROJET)+"/"+AFC->AFC_EDT+"]","AJE",,aRotina,,; 
		'xFilial("AJE")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT',;
		'xFilial("AJE")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT',;
		.F.,,,{{STR0078,1}},xFilial("AJE")+AFC->AFC_PROJET+AFC->AFC_REVISA+AFC->AFC_EDT) //"Data do Movimento"
	EndIf
Else
	If cAlias == "AF9" .And. nRecView<>0
		AF9->(dbGoto(nRecView))
		_cTarefa := AF9->AF9_TAREFA   //variavel utilizada x3_relacao Funcao PmsCpoInic()

		aIndexSE5 := PMS300Fil('SE5->E5_FILIAL == "' + xFilial("SE5") + '" .And. SE5->E5_PROJPMS == "' + AF9->AF9_PROJET + '" .And. SE5->E5_TASKPMS == "' + AF9->AF9_TAREFA + '"')
	
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0016+AllTrim(AF9->AF9_PROJET)+"/"+AF9->AF9_TAREFA+"]","SE5",,aRotina,,; 
					"","",.F.,,,{{"Data do Movimento + Banco + Agencia + Conta",1}},xFilial("SE5")+AF9->AF9_PROJET+SPACE(LEN(AFC->AFC_EDT))+AF9->AF9_TAREFA)  
	
	ElseIf cAlias == "AF8" .And. nRecView<>0
		AF8->(dbGoto(nRecView))
		_cTarefa := Space(Len(AF9->AF9_TAREFA))   //variavel utilizada x3_relacao Funcao PmsCpoInic()

		aIndexSE5 := PMS300Fil('SE5->E5_FILIAL == "' + xFilial("SE5") + '" .And. SE5->E5_PROJPMS == "' + AF8->AF8_PROJET + '"')
	
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0016+AllTrim(AF8->AF8_PROJET)+"]","SE5",,aRotina,,; 
					"",	"",.F.,,,{{"EDT + Tarefa + Data do Movimento + Banco + Agencia + Conta",1}},xFilial("SE5")+AF8->AF8_PROJET)  
	
	ElseIf cAlias == "AFC" .And. nRecView<>0
		AFC->(dbGoto(nRecView))
	
		aIndexSE5 := PMS300Fil('SE5->E5_FILIAL == "' + xFilial("SE5") + '" .And. SE5->E5_PROJPMS == "' + AFC->AFC_PROJET + '" .And. SE5->E5_EDTPMS == "' + AFC->AFC_EDT + '"')
	
		MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0016+AllTrim(AFC->AFC_PROJET)+"/"+AFC->AFC_EDT+"]","SE5",,aRotina,,; 
					"",	"",.F.,,,{{"Data do Movimento + Banco + Agencia + Conta",1}},xFilial("SE5")+AFC->AFC_PROJET+AFC->AFC_EDT+SPACE(LEN(AF9->AF9_TAREFA)))  

	EndIf
	
	EndFilBrw("SE5",aIndexSE5)
Endif


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A300toMOV³ Autor³Fabio Rogerio Pereira    ³ Data ³ 31-01-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Atualizacao dos Mov.Bancarios do Projeto.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A300toMOV(cAlias,nReg,nOpcx)
Local aArea	:= GetArea()
Local cFilSE5, cFilOld
PRIVATE bPMSDlgMB	:= {||PmsDlgMB(2,M->E5_PROJPMS,M->E5_HISTOR,M->E5_RECPAG)}
PRIVATE aRatAJE		:= {}

If PmsChkAJE(.F.)
	cFilSE5		:= PmsFilial("SE5","AJE")
	cFilOld		:= cFilAnt
	If cFilSE5 <> ""
		cFilAnt 	:= cFilSE5
	EndIf

	aButtons := {{'PROJETPMS',{|| Eval(bPmsDlgMB) }, STR0085}}  //"Gerenciamento de Projetos"
	dbSelectArea("SE5")
	dbSetOrder(9)
	If dbSeek(xFilial()+AJE->AJE_ID)
		AxVisual("SE5",SE5->(RecNo()),2,,,,,aButtons)
	EndIf
	cFilAnt 		:= cFilOld
Else
	AxVisual(cAlias,nReg,2)
EndIf

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PMS300Fil³ Autor ³Fabio Rogerio Pereira  ³ Data ³ 31/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta filtro da rotina de Movimento Bancario               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PMS300Fil()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PMS300Fil(cFiltroSE5)
Local aIndexSE5	:= {}
Local bFiltraBrw

bFiltraBrw := {|| FilBrowse("SE5",@aIndexSE5,@cFiltroSE5) }
Eval(bFiltraBrw)

Return(aIndexSE5)
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS300RQMod2 ³ Autor ³ Edson Maricate     ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Visualizacao das Requisicoes vinculadas ao projeto³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS300RQMod2(oTree,lVisual,cArquivo)
Local cAlias
Local nRecView
Local aSize		:= MsAdvSize(,.F.,430)
Local aRotina   := {}         
Local lHabVis 	:= .T.
Local lHabInc	:= .T.
Local lHabAlt	:= .T.

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

A300ValOp(cAlias,nRecView,"REQUIS",@lHabVis,@lHabInc,@lHabAlt)

aRotina 	:= If(lVisual,{{ STR0003,"A300toRQMod2", 0 , 2,,lHabVis}},	{	{ STR0003,"A300toRQMod2", 0 , 2,  ,lHabVis},; //"Visualizar"
																			{ STR0014,"A300toRQMod2", 0 , 3,  ,lHabInc},;	 //"Incluir"
																			{ STR0015,"A300toRQMod2", 0 , 6, 1,lHabAlt} } )//"Estornar"

If cAlias == "AF9" .And. nRecView<>0
	AF9->(dbGoto(nRecView))
	_cTarefa := AF9->AF9_TAREFA  //variavel utilizado x3_relacao funcao PmsCpoInic()
	AFI->(dbSetOrder(1))
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0016+AllTrim(AF9->AF9_PROJET)+"/"+AF9->AF9_TAREFA+"]","AFI",,aRotina,,; //" - MOV. -["
	'xFilial("AFI")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
	'xFilial("AFI")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
	.F.,,,{{STR0032,1},{STR0069,4}},xFilial("AFI")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA) //"Codigo do Produto + Armazem + Data de Emissao + Num. Sequencial" //"Data de Emissao + Codigo do Produto + Armazem"
ElseIf cAlias == "AF8" .And. nRecView<>0
	AF8->(dbGoto(nRecView))
	_cTarefa := SPACE(LEN(AF9->AF9_TAREFA)) //variavel utilizado x3_relacao funcao PmsCpoInic()
	AFI->(dbSetOrder(1))
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0016+AllTrim(AF8->AF8_PROJET)+"]","AFI",,aRotina,,; //" - MOV. -["
	'xFilial("AFI")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
	'xFilial("AFI")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
	.F.,,,{{STR0033,1},{STR0070,3},{STR0069,5}},xFilial("AFI")+AF8->AF8_PROJET+AF8->AF8_REVISA) //"Tarefa + Codigo do Produto + Armazem + Data de Emissao + Num. Sequencial" //"Codigo do Produto + Armazem"###"Data de Emissao + Codigo do Produto + Armazem"
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A300toRQMod2³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Atualizacao das Requisicoes vinculadas ao Projeto.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A300toRQMod2(cAlias,nReg,nOpcx)
Local aArea	:= GetArea()
Local cFilSD3 		:= ""
Local cFilOldSD3 	:= ""

Do Case
	Case nOpcx == 1
		cFilSD3 		:= PmsFilial("SD3","AFI")
	   cFilOldSD3  := cFilAnt
		If cFilSD3 <> ""
			cFilAnt 	:= cFilSD3
		EndIf

		SD3->(dbSetOrder(7))
		If SD3->(dbSeek(xFilial()+AFI->AFI_COD+AFI->AFI_LOCAL+DTOS(AFI->AFI_EMISSA)+AFI->AFI_NUMSEQ))
			MATA241(,,2)
		EndIf
		
		cFilAnt		:= cFilOldSD3

	Case nOpcx == 2
		If PmsVldFase("AF8",AF8->AF8_PROJET,"81")
			MATA241(,,3)
		Endif	
		
	Case nOpcx == 3
		cFilSD3 		:= PmsFilial("SD3","AFI")
	   cFilOldSD3  := cFilAnt
		If cFilSD3 <> ""
			cFilAnt 	:= cFilSD3
		EndIf

		SD3->(dbSetOrder(7))
		If SD3->(dbSeek(xFilial()+AFI->AFI_COD+AFI->AFI_LOCAL+DTOS(AFI->AFI_EMISSA)+AFI->AFI_NUMSEQ))
			MATA241(,,6)
		EndIf

		cFilAnt		:= cFilOldSD3

EndCase

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³30/11/06 ³±±
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
	Local aRotina := {{STR0002, "AxPesqui", 0, 1, , .F.},; //"Pesquisar"
	                  {STR0004, "PMS300Dlg", 0, 2},;	 //"Atualizar"
	                  {STR0003, "PMS300Dlg", 0, 2},; //"Visualizar"
	                  {STR0054, "PMS300Leg", 0, 2, , .F.}} //"Legenda"
Return aRotina

//
// verifica se existe um remito associado ao item
// e se o remito tem associação com o PMS

Function PmsRemAmar(cAlias)

Local cValRemito  := ""
Local cValItemRem := ""

Local lReturn := .F.

Local nPosRemito  := AScan(aHeader, {|x| Upper(Alltrim(x[2])) == "D1_REMITO"})
Local nPosItemRem := AScan(aHeader, {|x| Upper(Alltrim(x[2])) == "D1_ITEMREM"})
Local aArea    := GetArea()	
Local aAreaSD1 := SD1->(GetArea())
Local aAreaAFN := AFN->(GetArea())

Local aAreaSD2 := SD2->(GetArea())
Local aAreaAFS := AFS->(GetArea()) 

If cAlias == "SF1"             

	If nPosRemito > 0 .And. nPosItemRem > 0

		cValRemito  := aCols[n][nPosRemito]
		cValItemRem := aCols[n][nPosItemRem]

		// procura o Remito
		dbSelectArea("SD1")
		SD1->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		
		If !empty(cValRemito) .and. SD1->(MsSeek(xFilial("SD1") + cValRemito)) //+ cValItemRem))

			// verifica se o Remito está associado ao PMS
			dbSelectArea("AFN")
			AFN->(dbSetOrder(2)) // AFN_FILIAL + AFN_DOC + AFN_SERIE + AFN_FORNEC
			
			If AFN->(MsSeek(xFilial("AFN") + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE))

				lReturn := .T.
			
			EndIf
		EndIf
	EndIf
	RestArea(aAreaAFN)	
	RestArea(aAreaSD1)
	RestArea(aArea)
Else
	nPosRemito  := AScan(aHeader, {|x| Upper(Alltrim(x[2])) == "D2_REMITO"})
	nPosItemRem := AScan(aHeader, {|x| Upper(Alltrim(x[2])) == "D2_ITEMREM"})	
	
	If nPosRemito > 0 .And. nPosItemRem > 0

		cValRemito  := aCols[n][nPosRemito]
		cValItemRem := aCols[n][nPosItemRem]

		// procura o Remito
		dbSelectArea("SD2")
		SD2->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		
		If !empty(cValRemito) .and. SD2->(MsSeek(xFilial("SD2") + cValRemito)) //+ cValItemRem))

			// verifica se o Remito está associado ao PMS
			dbSelectArea("AFS")             
			AFS->(dbSetOrder(2)) // AFS_FILIAL+AFS_COD+AFS_LOCAL+DTOS(AFS_EMISSA)+AFS_NUMSEQ+AFS_PROJET+AFS_REVISA+AFS_TAREFA
		  
		  	If AFS->(MsSeek(xFilial("AFS") + SD2->D2_COD + SD2->D2_LOCAL + DTOS(SD2->D2_EMISSAO) +SD2->D2_NUMSEQ )) 		

				lReturn := .T.
			
			EndIf
		EndIf
	EndIf

	RestArea(aAreaAFS)	
	RestArea(aAreaSD2)
	RestArea(aArea)
EndIf

Return lReturn

Function PmsVldNf()
     
Local cAlias 

	If aCfgNF[4] == "SF1"
        cAlias := "SF1"
		If PmsRemAmar(cAlias)

			Aviso(STR0088, STR0089, {"OK"})
			
			Return Nil
		EndIf
		
		PmsDlgNF(aRotina[__nOpcx][4], ;
		         &("M->"+cP3+"DOC"), ;
		         &("M->"+cP3+"SERIE"), ;
		         &("M->"+cP3+IIf(cP3=="F1_","FORNECE","CLIENTE")), ;
		         &("M->"+cP3+"LOJA"),;
		         aCfgNF[10],;
		         &("M->"+SerieNfId(cP3,3,cP3+"SERIE")))
	
	ElseIf aCfgNF[4] == "SF2"  
		cAlias := "SF2"
		If PmsRemAmar(cAlias) .and. aRotina[__nOpcx][4] <> 2
		   
			Aviso(STR0088, STR0089, {"OK"})
			
			Return Nil
		EndIf

		PmsDlgNFS(aRotina[__nOpcx][4], ;
                 &("M->"+cP3+"DOC"), ;
                 &("M->"+cP3+"SERIE"), ;
                 &("M->"+cP3+IIf(cP3=="F2_","CLIENTE","FORNECE")), ;
                 &("M->"+cP3+"LOJA"),;
		          aCfgNF[10],;
		          &("M->"+SerieNfId(cP3,3,cP3+"SERIE")))
	EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS300APR³ Autor ³ Reynaldo Miyashita     ³ Data ³ 09-12-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Browse de aprovacao/rejeicao dos pre apontamentos de recursos.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS300APR(oTree,lVisual,cArquivo)

Local cAlias	
Local nRecView	
Local aSize		:= MsAdvSize(,.F.,430)
Local lHabVis 	:= .T.
Local lHabInc	:= .T.
Local lHabExc	:= .T.

PRIVATE aGetCpo
PRIVATE aRotina	

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

A300ValOp(cAlias,nRecView,"APRPRE",@lHabVis,@lHabInc,,@lHabExc)

aRotina 	:= If(lVisual,{{ "Visualizar","A300toAPR", 0 , 1,  ,lHabVis}},	{	{ "Visualizar","A300toAPR", 0 , 1,  ,lHabVis},;
																			{ "Aprovação","A300toAPR", 0 , 2,  ,lHabInc},;
																			{ "Rejeição","A300toAPR", 0 , 3, 1,lHabExc},;
																			{ "Estornar Aprov.","A300toAPR", 0, 4,  ,lHabInc} })

If cAlias == "AF9" .And. nRecView<>0
	AF9->(dbGoto(nRecView))
	_cTarefa := AF9->AF9_TAREFA   //variavel utilizada x3_relacao Funcao PmsCpoInic()
	AJK->(dbSetOrder(1))
	aGetCpo := {	{"AJK_PROJET",AF9->AF9_PROJET,.F.},;
					{"AJK_REVISA",AF9->AF9_REVISA,.F.},;
					{"AJK_TAREFA",AF9->AF9_TAREFA,.F.} }
	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+" - Aprovação Pré Apontamento -["+AllTrim(AF9->AF9_PROJET)+"/"+AF9->AF9_TAREFA+"]","AJK",,aRotina,,; //" - Aprovação Pré Apontamento -["
	'xFilial("AJK")+"1"+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
	'xFilial("AJK")+"1"+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
	.F.,,,{{"Projeto + Versão + Tarefa + Recurso + Data",1}},xFilial("AJK")+"1"+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
	
ElseIf cAlias == "AF8" .And. nRecView<>0
//	AF8->(dbGoto(nRecView))
//	_cTarefa := Space(Len(AF9->AF9_TAREFA))   //variavel utilizada x3_relacao Funcao PmsCpoInic()
//	AFR->(dbSetOrder(1))
//	MaWndBrowse(aSize[7],0,aSize[6],aSize[5],cCadastro+STR0029+AllTrim(AF8->AF8_PROJET)+"]","AFR",,aRotina,,; //" - Despesas -["
//	'xFilial("AFR")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
//	'xFilial("AFR")+AF8->AF8_PROJET+AF8->AF8_REVISA',;
//	.F.,,,{{STR0039,1},{STR0038,4}},xFilial("AFR")+AF8->AF8_PROJET+AF8->AF8_REVISA) //"Tarefa + Prefixo + Num. Doc. + Parcela + Tipo + Cod. Fornecedor + Loja"
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A300toAPR³ Autor ³ Reynaldo Miyashita     ³ Data ³ 06-12-2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Aprovacao dos pre apontamentos do projeto        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A300toAPR(cAlias,nReg,nOpcx)

//	If PmsChkUser(AF9->AF9_PROJET, AF9->AF9_TAREFA, NIL, "", 2, "APRPRE", AF9->AF9_REVISA, NIL, .F.)

Do Case
	Case nOpcx == 1 // Consulta
		PMSA710(,2,aGetCpo)
		
	Case nOpcx == 2 // Aprovar
		PMSA710(,3,aGetCpo)
		
	Case nOpcx == 3 // Rejeitar
		PMSA710(,4,aGetCpo)
	
	Case nOpcx == 4 // Estornar Aprov.
		PMSA710(,7,aGetCpo)
EndCase

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS300PRE³ Autor ³ Guilherme Santos       ³ Data ³  07/11/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Browse de Visualizacao/Inclusao/Alteracao dos pre-apontamentos³±±
±±³          ³de recursos.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS300PRE(oTree, lVisual, cArquivo)

Local aSize		:= MsAdvSize(NIL, .F., 430)
Local aString	:= {}
Local cAlias	:= ""
Local cString	:= ""
Local lHabVis 	:= .T.
Local lHabInc	:= .T.
Local lHabAlt	:= .T.
Local lHabExc	:= .T.
Local nRecView	:= 0

PRIVATE aGetCpo
PRIVATE aRotina	

If oTree == Nil
	cAlias		:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias		:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

A300ValOp(	cAlias,		nRecView,	"RECURS",	@lHabVis,;
			@lHabInc,	@lHabAlt,	@lHabExc)

aRotina	:= If(lVisual,	{{ STR0003, "A300toPRE", 0, 2, NIL,	lHabVis}},; //"Visualizar"
						 {{ STR0003, "A300toPRE", 0, 2, NIL, lHabVis},; //"Visualizar"
						  { STR0014, "A300toPRE", 0, 3, NIL, lHabInc},; //"Incluir"
						  { STR0044, "A300toPRE", 0, 4, NIL, lHabAlt},; //"Alterar"
						  { STR0028, "A300toPRE", 0, 5, 5,	lHabExc}}) //"Excluir"

If PmsChkAJK(.T.)
	If cAlias == "AF9" .And. nRecView <> 0
		AF9->(dbGoto(nRecView))
		_cTarefa := AF9->AF9_TAREFA   //variavel utilizada x3_relacao Funcao PmsCpoInic()
		AJK->(dbSetOrder(1))

		aGetCpo := {	{"AJK_PROJET",	AF9->AF9_PROJET,	.F.},;
						{"AJK_REVISA",	AF9->AF9_REVISA,	.F.},;
						{"AJK_TAREFA",	AF9->AF9_TAREFA,	.F.} }
	
		cString := cCadastro + STR0024 + AllTrim(AF9->AF9_PROJET) + "/" + AF9->AF9_TAREFA + "]" //" - Pre-Recursos -["
		aString	:= {{STR0025, 1}, {STR0026, 5}} //"Codigo do Recurso + Data"###"Data + Codigo do Recurso"

		MaWndBrowse	(	aSize[7],;
						0,;
						aSize[6],;
						aSize[5],;
						cString,;
						"AJK",;
						NIL,;
						aRotina,;
						NIL,;
						'xFilial("AJK")+"1"+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
						'xFilial("AJK")+"1"+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA',;
						.F.,;
						NIL,;
						NIL,;
						aString,;
						xFilial("AJK") + "1" + AF9->AF9_PROJET + AF9->AF9_REVISA + AF9->AF9_TAREFA)

	ElseIf cAlias == "AF8" .AND. nRecView <> 0

		AF8->(dbGoto(nRecView))
		_cTarefa := Space(Len(AF9->AF9_TAREFA))   //variavel utilizada x3_relacao Funcao PmsCpoInic()
		AJK->(dbSetOrder(1))

		cString := cCadastro + " - Pre-Recursos - [" + AllTrim(AF8->AF8_PROJET) + "]" //" - Pre-Recursos -["
        aString	:=	{{STR0047, 1}, {STR0046, 4}, {STR0072, 6}} //"Tarefa + Codigo do Recurso + Data"###"Codigo do Recurso + Data"###"Data + Codigo do Recurso"

		MaWndBrowse	(	aSize[7],;
						0,;
						aSize[6],;
						aSize[5],;
						cString,;
						"AJK",;
						NIL,;
						aRotina,;
						NIL,;
						'xFilial("AJK")+"1"+AF8->AF8_PROJET+AF8->AF8_REVISA',;
						'xFilial("AJK")+"1"+AF8->AF8_PROJET+AF8->AF8_REVISA',;
						.F.,;
						NIL,;
						NIL,;
						aString,;
						xFilial("AJK") + "1" + AF8->AF8_PROJET + AF8->AF8_REVISA)
						
	EndIf

EndIf

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A300toPRE³ Autor ³ Guilherme Santos       ³ Data ³  07/11/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Visualizacao/Inclusao/Alteracao dos pre-apontamen-³±±
±±³          ³tos de recursos.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A300toPRE(cAlias, nReg, nOpcx)

Do Case
	Case nOpcx == 1
		PMSA700(NIL, 2)
	Case nOpcx == 2			//Visualizar
		PMSA700(NIL, 3, aGetCpo)
	Case nOpcx == 3			//Incluir
		PMSA700(NIL, 4, aGetCpo)
	Case nOpcx == 4			//Alterar
		PMSA700(NIL, 5, aGetCpo)
	Case nOpcx == 5			//Excluir
		PMSA700(NIL, 6, aGetCpo)
EndCase

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AjustaHr³ Autor ³ Marcelo Akama           ³ Data ³ 21/06/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Ajusta a hora de acordo com o parametro MV_PRECISA            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA300                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaHr(cHora, nPrecisa)
Local nH := val(Substr(cHora,1,3))
Local nM := val(Substr(cHora,4,2))
Local nI := 60/nPrecisa
Local cS := Substr(cHora,3,1)
Local cRet := cHora

nM += NoRound(nI/2,0)
If nM>59
	nH++
	nM-=60
EndIf
nM -= nM%nI

If strzero(nH,2)+cS+strzero(nM,2) == "24:00"
	cRet := "23:59"
Else
	cRet := strzero(nH,2)+cS+strzero(nM,2)
EndIf

Return cRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  

