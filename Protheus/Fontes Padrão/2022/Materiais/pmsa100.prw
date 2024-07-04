#include "PMSA100.CH"
#include "protheus.ch"
#include "TCBROWSE.CH"
#include "pmsicons.ch"

STATIC __lBlind		:= IsBlind()
Static lFWCodFil := FindFunction("FWCodFil")

// Melhoria de performance
#command PMS_TRUNCA <val1>, <val2>, <val3>, <val4>, <val5>, <Dec1>, <Dec2>, <Dec3>, <Dec4>, <Dec5>, <QtTsk>, <Trunca>, <Total> TO <var1>, <var2>, <var3>, <var4>, <var5>	;
																																												;
  => if <Total>																																							  		;
   ; 	if <Trunca>$"13"																																						;
   ; 		<var1>+=NoRound(<val1>,<Dec1>)																																		;
   ; 		<var2>+=NoRound(<val2>,<Dec2>)																																		;
   ; 		<var3>+=NoRound(<val3>,<Dec3>)																																		;
   ; 		<var4>+=NoRound(<val4>,<Dec4>)																																		;
   ; 		<var5>+=NoRound(<val5>,<Dec5>)																																		;
   ; 	else																																									;
   ; 		<var1>+=Round(<val1>,<Dec1>)																																		;
   ; 		<var2>+=Round(<val2>,<Dec2>)																																		;
   ; 		<var3>+=Round(<val3>,<Dec3>)																																		;
   ; 		<var4>+=Round(<val4>,<Dec4>)																																		;
   ; 		<var5>+=Round(<val5>,<Dec5>)																																		;
   ; 	endif																																									;
   ; elseif <Trunca>$"1"																																						;
   ; 	<var1>+=NoRound(<val1>*<QtTsk>,<Dec1>)																																	;
   ; 	<var2>+=NoRound(<val2>*<QtTsk>,<Dec2>)																																	;
   ; 	<var3>+=NoRound(<val3>*<QtTsk>,<Dec3>)																																	;
   ; 	<var4>+=NoRound(<val4>*<QtTsk>,<Dec4>)																																	;
   ; 	<var5>+=NoRound(<val5>*<QtTsk>,<Dec5>)																																	;
   ; elseif <Trunca>$"2"					   																																	;
   ; 	<var1>+=Round(<val1>*<QtTsk>,<Dec1>)																																	;
   ; 	<var2>+=Round(<val2>*<QtTsk>,<Dec2>)																																	;
   ; 	<var3>+=Round(<val3>*<QtTsk>,<Dec3>)																																	;
   ; 	<var4>+=Round(<val4>*<QtTsk>,<Dec4>)																																	;
   ; 	<var5>+=Round(<val5>*<QtTsk>,<Dec5>)																																	;
   ; elseif <Trunca>$"3"					 																																	;
   ; 	<var1>+=NoRound(NoRound(<val1>,<Dec1>)*<QtTsk>,<Dec1>)																													;
   ; 	<var2>+=NoRound(NoRound(<val2>,<Dec2>)*<QtTsk>,<Dec2>)																													;
   ; 	<var3>+=NoRound(NoRound(<val3>,<Dec3>)*<QtTsk>,<Dec3>)																													;
   ; 	<var4>+=NoRound(NoRound(<val4>,<Dec4>)*<QtTsk>,<Dec4>)																													;
   ; 	<var5>+=NoRound(NoRound(<val5>,<Dec5>)*<QtTsk>,<Dec5>)																													;
   ; else									  																																	;
   ; 	<var1>+=Round(Round(<val1>,<Dec1>)*<QtTsk>,<Dec1>)																														;
   ; 	<var2>+=Round(Round(<val2>,<Dec2>)*<QtTsk>,<Dec2>)																														;
   ; 	<var3>+=Round(Round(<val3>,<Dec3>)*<QtTsk>,<Dec3>)																														;
   ; 	<var4>+=Round(Round(<val4>,<Dec4>)*<QtTsk>,<Dec4>)																														;
   ; 	<var5>+=Round(Round(<val5>,<Dec5>)*<QtTsk>,<Dec5>)																														;
   ; endif


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA100  ³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de manutecao de orcamentos de projetos.             ³±±
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
Function PMSA100(nCallOpcx)

PRIVATE cCadastro	:= STR0001 //"Orcamentos"
PRIVATE aMemos  :={{"AF1_CODMEM","AF1_OBS"}}
PRIVATE aCores  := PmsAF1Color()
PRIVATE nDlgPln := PMS_VIEW_TREE

PRIVATE aHandCOT	:= {}
PRIVATE aRotina := MenuDef()


If  PMSBLKINT()
	Return Nil
EndIf

Set Key VK_F12 To FAtiva()

	Pergunte("PMA100",.F.)
	nDlgPln := mv_par01
	dbSelectArea("AF1")
	dbSetOrder(1)
	If nCallOpcx <> Nil
		PMS100Dlg("AF1",AF1->(Recno()),nCallOpcx)
	Else
		mBrowse(6,1,22,75,"AF1",,,,,,aCores)
	Endif


Set Key VK_F12 To 

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS100Leg³ Autor ³  Fabio Rogerio Pereira ³ Data ³ 18-03-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Exibicao de Legendas                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA100, SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS100Leg(cAlias,nReg,nOpcx)
Local aLegenda:= {}
Local i       := 0

For i:= 1 To Len(aCores)
	Aadd(aLegenda,{aCores[i,2],aCores[i,3]})
Next i
                             
BrwLegenda(cCadastro,STR0054 ,aLegenda) //"Legenda"

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS100Dlg³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao,Alteracao,Visualizacao e Exclusao       ³±±
±±³          ³ de Orcamentos.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA100, SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS100Dlg(cAlias,nReg,nOpcx)

Local oTree 
Local nz
Local lOk
Local oDlg
Local l100Inclui	:= .F.
Local l100Visual	:= .F.
Local l100Altera	:= .F.
Local l100Exclui	:= .F.
Local lContinua 	:= .T.
Local cArquivo		:= CriaTrab(,.F.)
Local lConfExcTe  := .T.
Local cSearch     := Space(TamSX3("AFC_DESCRI")[1])
Local lRefresh    := .T.
Local aAreaAF1
Local aMenuAt	   :=	{}
Local lChgCols	   :=	.F.  
Local lPMS100ORC  := ExistBlock("PMS100ORC")
Local cFilialAF1    := ""
Local cOrcamentoAF1 := ""
Local cDescricaoAF1 := ""
Local lFWGetVersao := .T.
Local aButtons		:= {}
Local aUsButtons	:= {}
Local lPM100BUT := ExistBlock("PM100BUT")

Local nScreVal1 := 775 // variaveis para posicionamento do popup menu
Local nScreVal2 := 23  // variaveis para posicionamento do popup menu
Local aScreens  := {}   // variaveis para posicionamento do popup menu
PRIVATE aBAtalhos	:=	{}
PRIVATE bBlocoAtalho:=	{}
Private lEmAtalho	:=	.F.
PRIVATE cCmpPLN
PRIVATE cArqPLN
PRIVATE cPLNVer := ''
PRIVATE cPLNDescri	:= ''
PRIVATE lSenha		:= .F.
PRIVATE cPLNSenha	:= ""                      
PRIVATE nFreeze		:= 0
PRIVATE nIndent		:= PMS_SHEET_INDENT

//Incluido variaveis para posicionamento do Popup Menu, pois na russia o mesmo deverá ficar posicioando abaixo do menu a direita
If cPaisLoc == 'RUS'
	//Valores para a Russia, posicionado a direita
	//Change popup menu localization, using the screen resolution to position on right
	aScreens := getScreenRes()
	nScreVal1 := aScreens[1]-245
	nScreVal2 := 53
EndIf

// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
Do Case
	Case aRotina[nOpcx][4] == 2
		l100Visual 	:= .T.
	Case aRotina[nOpcx][4] == 3
		Inclui		:= .T.
		l100Inclui	:= .T.
	Case aRotina[nOpcx][4] == 4
		Altera		:= .T.
		l100Altera	:= .T.
	Case aRotina[nOpcx][4] == 5
		lOk			:= .F.	
		l100Exclui	:= .T.
		l100Visual	:= .T.
EndCase

If l100Exclui

	// verifica o evento de Exclusao no Fase atual.
	If !PmsVldFase("AF1",AF1->AF1_ORCAME,"12")
		lContinua := .F.
	EndIf
EndIf

If l100Altera

	// verifica o evento de alteracao no Fase atual.
	If !PmsVldFase("AF1",AF1->AF1_ORCAME,"11")
		lContinua := .F.
	EndIf
	If lContinua .And. ExistBlock("PMS100A3")
		ExecBlock("PMS100A3",.F.,.F.)
	EndIf
EndIf

If lContinua

	// utiliza a funcao axInclui para incluir o Orcamento.
	If l100Inclui
		If ExistBlock("PMA100Inc")
			If ExecBlock("PMA100Inc")
				Return						
			EndIf
		EndIf
		
		If lPM100BUT
			If ValType( aUsButtons := ExecBlock( "PM100BUT", .F., .F. ) ) == "A"
				AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
			EndIf
		EndIf
		
		If lContinua := ! ( AxInclui(cAlias,nReg,nOpcx,,,,"PMS100OK()",,,aButtons) <> 1 )

			If ExistBlock("PMA100Prj")
				ExecBlock("PMA100Prj", .F., .F.)			
			EndIf
	
			// Cria um registro na lista de EDTs
			DbSelectArea("AF5")

			RecLock("AF5",.T.)
			AF5->AF5_FILIAL	:= xFilial("AF5")
			AF5->AF5_ORCAME	:= AF1->AF1_ORCAME
			AF5->AF5_EDT    := AF1->AF1_ORCAME
			AF5->AF5_DESCRI	:= AF1->AF1_DESCRI
			AF5->AF5_NIVEL	:= "001"
			AF5->AF5_UM		:= STR0023 //"UN"
			AF5->AF5_QUANT	:= 1
			AF5->AF5_VERSAO	:= AF1->AF1_VERSAO
			MsUnlock() 
			
			// cria os direitos de acesso para o usuario que criou o orçamento
			DbSelectArea("AJF")

			RecLock("AJF",.T.)
			AJF->AJF_FILIAL := xFilial("AJF")
			AJF->AJF_ORCAME := AF1->AF1_ORCAME
			AJF->AJF_EDT	:= AF5->AF5_EDT
			AJF->AJF_USER	:= __cUserID
			AJF->AJF_ESTRUT	:= "3"
			AJF->AJF_DOCUME	:= "4"
			AJF->AJF_PROJET	:= "2"
			AJF->AJF_VERSAO	:= AF1->AF1_VERSAO  
			MsUnlock()
	
			DbSelectArea("AF1")

		EndIf
	EndIf
    
	If lContinua
		If !l100Visual
			MENU oMenu2 POPUP
				If l100Inclui .Or. l100Altera
					MENUITEM STR0057 ACTION (Pms100AltCus(),RestArea(aAreaAF1),Eval(bRefresh)) //"Reajustar Custo"
					MENUITEM STR0081 ACTION (PMS100ReCalc(),RestArea(aAreaAF1),Eval(bRefresh)) //"Recalculo do Custo"
					MENUITEM STR0102 ACTION (RecodeOrc(@oTree, cArquivo), Eval(bRefresh)) //"Recodificar"
					MENUITEM STR0103 ACTION (Processa({|| PMS100Subs()}) , Eval(bRefresh)) //"Substituir"
				EndIf
			ENDMENU

			For nZ	:=	1	To Len(oMenu2:aItems)
				AAdd(aMenuAt,{ATA_FERRAMENTAS+"A"+STRZERO(nZ,2),1,oMenu2:aItems[nZ]:cCaption,oMenu2:aItems[nZ]:bAction,oMenu2,Nil})
			Next
		
			MENU oMenu POPUP
				MENUITEM STR0010 ACTION (PMS100to101(3,@oTree,"1",cArquivo,@lRefresh),If(lRefresh, (RestArea(aAreaAF1),Eval(bRefresh)), Nil)) //"Incluir EDT"
				MENUITEM STR0011 ACTION (PMS100to101(3,@oTree,"2",cArquivo,@lRefresh),If(lRefresh, (RestArea(aAreaAF1),Eval(bRefresh)), Nil)) //"Incluir Tarefa"
				MENUITEM STR0005 ACTION (PMS100to101(4,@oTree,,cArquivo,@lRefresh),If(lRefresh, (RestArea(aAreaAF1),Eval(bRefresh)), Nil)) //"Alterar"
				MENUITEM STR0003 ACTION PMS100to101(2,@oTree,,cArquivo) //"Visualizar"
				MENUITEM STR0008 ACTION (PMS100to101(5,@oTree,,cArquivo,@lRefresh),If(lRefresh, (RestArea(aAreaAF1),Eval(bRefresh)), Nil)) //"Excluir"
				MENUITEM STR0045 ACTION (PMS100Import(oTree,cArquivo,1),RestArea(aAreaAF1),Eval(bRefresh)) //"Copiar EDT/Tarefa de Orcamento"
				MENUITEM STR0071 ACTION (PMS100Import(oTree,cArquivo,2),RestArea(aAreaAF1),Eval(bRefresh)) //"Copiar EDT/Tarefa de Projeto"
				MENUITEM STR0020 ACTION (If(PMS101Cmp(AF8->(RecNo()),@oTree,cArquivo),(RestArea(aAreaAF1),Eval(bRefresh)),Nil)) //"Importar Composicao"
				MENUITEM STR0072 ACTION (PMS100ChangeEDT(@oTree,cArquivo),RestArea(aAreaAF1),Eval(bRefresh)) //"Trocar EDT Pai"
				MENUITEM STR0074 ACTION (If(PMS101Cmp2(AF8->(RecNo()),@oTree,cArquivo),(RestArea(aAreaAF1),Eval(bRefresh)),Nil))  //"Associar Composicao"

				If nDlgPln == PMS_VIEW_TREE
					MENUITEM STR0075 ACTION Procurar(oTree, @cSearch, cArquivo) //"Procurar..."
					MENUITEM STR0076 ACTION ProcurarP(oTree, @cSearch, cArquivo) //"Procurar proxima"
				EndIf
			ENDMENU
			
			For nZ	:=	1	To Len(oMenu:aItems)
				AAdd(aMenuAt,{ATA_PROJ_ESTRUTURA+"A"+STRZERO(nZ,2),1,oMenu:aItems[nZ]:cCaption,oMenu:aItems[nZ]:bAction,oMenu,Nil})
			Next
				
			If !lFWGetVersao .or. GetVersao(.F.) == "P10"

				If nDlgPln == PMS_VIEW_TREE
					// modo arvore
					aMenu := {;
					         {TIP_ORC_INFO,      {||PmsOrcInf()}, BMP_ORC_INFO, TOOL_ORC_INFO},;
					         {TIP_FERRAMENTAS,   {||A100CtrMenu(@oMenu,oTree,l100Visual,cArquivo, oMenu2, nDlgPln),oMenu2:Activate(35,45,oDlg)}, BMP_FERRAMENTAS, TOOL_FERRAMENTAS},;
					         {TIP_ORC_ESTRUTURA, {||A100CtrMenu(@oMenu,oTree,l100Visual,cArquivo, , nDlgPln),oMenu:Activate(75,45,oDlg) }, BMP_ORC_ESTRUTURA, TOOL_ORC_ESTRUTURA}} //"Estrutura"
				Else
					// modo planilha
					aMenu := {;
					         {TIP_ORC_INFO,      {||PmsOrcInf()}, BMP_ORC_INFO, TOOL_ORC_INFO},;
					         {TIP_COLUNAS,       {||Iif(lChgCols := PMC050Cfg("", 0, 0),oDlg:End(), Nil)}, BMP_COLUNAS, TOOL_COLUNAS},;
					         {TIP_FERRAMENTAS,   {||A100CtrMenu(@oMenu,oTree,l100Visual,cArquivo, oMenu2, nDlgPln),oMenu2:Activate(35,45,oDlg)}, BMP_FERRAMENTAS, TOOL_FERRAMENTAS},;
					         {TIP_ORC_ESTRUTURA, {||A100CtrMenu(@oMenu,oTree,l100Visual,cArquivo, , nDlgPln),oMenu:Activate(105,45,oDlg) }, BMP_ORC_ESTRUTURA, TOOL_ORC_ESTRUTURA}} //"Estrutura"
				EndIf

			Else
				//Acoes relacionadas
				If nDlgPln == PMS_VIEW_TREE
					// modo arvore
					aMenu := {;
							{TIP_ORC_INFO,      {||PmsOrcInf()}, BMP_ORC_INFO, TOOL_ORC_INFO},;
							{TIP_FERRAMENTAS,   {||A100CtrMenu(@oMenu,oTree,l100Visual,cArquivo, oMenu2, nDlgPln),oMenu2:Activate(nScreVal1,nScreVal2,oDlg)}, BMP_FERRAMENTAS, TOOL_FERRAMENTAS},;
							{TIP_ORC_ESTRUTURA, {||A100CtrMenu(@oMenu,oTree,l100Visual,cArquivo, , nDlgPln),oMenu:Activate(nScreVal1,nScreVal2,oDlg) }, BMP_ORC_ESTRUTURA, TOOL_ORC_ESTRUTURA}} //"Estrutura"
				Else
					// modo planilha
					aMenu := {;
							{TIP_ORC_INFO,      {||PmsOrcInf()}, BMP_ORC_INFO, TOOL_ORC_INFO},;
							{TIP_COLUNAS,       {||Iif(lChgCols := PMC050Cfg("", 0, 0),oDlg:End(), Nil)}, BMP_COLUNAS, TOOL_COLUNAS},;
							{TIP_FERRAMENTAS,   {||A100CtrMenu(@oMenu,oTree,l100Visual,cArquivo, oMenu2, nDlgPln),oMenu2:Activate(nScreVal1,nScreVal2,oDlg)}, BMP_FERRAMENTAS, TOOL_FERRAMENTAS},;
							{TIP_ORC_ESTRUTURA, {||A100CtrMenu(@oMenu,oTree,l100Visual,cArquivo, , nDlgPln),oMenu:Activate(nScreVal1,nScreVal2,oDlg) }, BMP_ORC_ESTRUTURA, TOOL_ORC_ESTRUTURA}} //"Estrutura"
				EndIf

			Endif	
		Else
			MENU oMenu POPUP
				MENUITEM STR0003 ACTION PMS100to101(2,@oTree,,cArquivo) //"Visualizar"

				If nDlgPln == PMS_VIEW_TREE
					MENUITEM STR0075 ACTION Procurar(oTree, @cSearch, cArquivo) //"Procurar..."
					MENUITEM STR0076 ACTION ProcurarP(oTree, @cSearch, cArquivo) //"Procurar proxima"
				EndIf
			ENDMENU

			For nZ	:=	1	To Len(oMenu:aItems)
				AAdd(aMenuAt,{ATA_PROJ_ESTRUTURA+"A"+STRZERO(nZ,2),1,oMenu:aItems[nZ]:cCaption,oMenu:aItems[nZ]:bAction,oMenu,Nil})
			Next

			If !lFWGetVersao .or. GetVersao(.F.) == "P10"
			
				If nDlgPln == PMS_VIEW_TREE
					// modo arvore
					aMenu := {;
					         {TIP_ORC_INFO,      {||PmsOrcInf()}, BMP_ORC_INFO, TOOL_ORC_INFO},;
					         {TIP_ORC_ESTRUTURA, {||A100CtrMenu(@oMenu,oTree,l100Visual,cArquivo,,nDlgPln),oMenu:Activate(75,45,oDlg) }, BMP_ORC_ESTRUTURA, TOOL_ORC_ESTRUTURA}}
				Else
					// modo planilha
					aMenu := {;
					         {TIP_ORC_INFO,      {||PmsOrcInf()}, BMP_ORC_INFO, TOOL_ORC_INFO},;
					         {TIP_COLUNAS,       {||Iif(lChgCols := PMC050Cfg("", 0, 0),oDlg:End(), Nil)}, BMP_COLUNAS, TOOL_COLUNAS},;
					         {TIP_ORC_ESTRUTURA, {||A100CtrMenu(@oMenu,oTree,l100Visual,cArquivo,,nDlgPln),oMenu:Activate(75,45,oDlg) }, BMP_ORC_ESTRUTURA, TOOL_ORC_ESTRUTURA}}
				EndIf
	        Else
				//Acoes relacionadas
				If nDlgPln == PMS_VIEW_TREE
					// modo arvore
					aMenu := {;
							{TIP_ORC_INFO,      {||PmsOrcInf()}, BMP_ORC_INFO, TOOL_ORC_INFO},;
							{TIP_ORC_ESTRUTURA, {||A100CtrMenu(@oMenu,oTree,l100Visual,cArquivo,,nDlgPln),oMenu:Activate(nScreVal1,nScreVal2,oDlg) }, BMP_ORC_ESTRUTURA, TOOL_ORC_ESTRUTURA}}
				Else
					// modo planilha
					aMenu := {;
							{TIP_ORC_INFO,      {||PmsOrcInf()}, BMP_ORC_INFO, TOOL_ORC_INFO},;
							{TIP_COLUNAS,       {||Iif(lChgCols := PMC050Cfg("", 0, 0),oDlg:End(), Nil)}, BMP_COLUNAS, TOOL_COLUNAS},;
							{TIP_ORC_ESTRUTURA, {||A100CtrMenu(@oMenu,oTree,l100Visual,cArquivo,,nDlgPln),oMenu:Activate(nScreVal1,nScreVal2,oDlg) }, BMP_ORC_ESTRUTURA, TOOL_ORC_ESTRUTURA}}
				EndIf
			Endif	        
		EndIf
		If l100Exclui		
			If ExistBlock("PMA100EX")
				lConfExcTe := ExecBlock("PMA100EX", .F., .F.)
			EndIf
		EndIf

		AAdd(aMenu, {STR0107,  {|| SetAtalho(aMenuAt,aMenu,.T.)}, "ATALHO", STR0108})  //"Atalhos"##"Atalhos"
	
		// le os atalhos desde o profile
		CarregaAtalhos(aMenu,aMenuAt,Iif(l100Visual,"V","A")	)
		
		// configura as teclas de atalho
	 	SetAtalho(aMenuAt,aMenu,.F.)


		aAreaAF1 := AF1->(GetArea())
		
		If lConfExcTe
			If nDlgPln == PMS_VIEW_SHEET
				aCampos := {{"AF2_TAREFA","AF5_EDT",8,,,.F.,"",},{"AF2_DESCRI","AF5_DESCRI",55,,,.F.,"",150}}
				// MV_PMSCPLN
				//				
				// 1 - a configuração da planilha é utilizada exclusivamente pelo usuário que criou
				// 2 - a configuração da planilha é utilizada por qualquer usuário (default)
				//
				
				If GetNewPar("MV_PMSCPLN", 2) == 1
					A100Opn(@aCampos, "\profile\pmsa100." + __cUserID)
				Else
					A100Opn(@aCampos)
				EndIf
				
				PmsPlanAF1(cCadastro,aCampos,@cArquivo,,,@lOk,aMenu,@oDlg,,nIndent)
			Else 
				PmsDlgAF1(cCadastro,@oMenu,@oTree,,{||A100CtrMenu(@oMenu,oTree,l100Visual,cArquivo,,nDlgPln)},@lOk,aMenu,@oDlg)
			EndIf
		Else
			lOk := .T.
		EndIf

		// grava os atalhos no profile.
		GravaAtalhos(aMenuAt,Iif(l100Visual,"V","A")	)

		If ExistBlock("PMA100Sa")
			ExecBlock("PMA100Sa", .F., .F., {nOpcx})		
		EndIf

		If lChgCols
			PMS100Dlg(cAlias, nReg, nOpcx)
		Else
			If l100Exclui .And. lOk
				If lPMS100ORC
					cFilialAF1    := xFilial("AF1") 				
					cOrcamentoAF1 := AF1->AF1_ORCAME
					cDescricaoAF1 := AF1->AF1_DESCRI
				EndIf
				Begin Transaction
					MaExclAF1(,AF1->(RECNO()))
				End Transaction
				If lPMS100ORC
					ExecBlock("PMS100ORC",.F.,.F.,{cFilialAF1,cOrcamentoAF1,cDescricaoAF1})
				EndIf	
			EndIf
			If l100Altera
				If ExistBlock("PMS100A4")
					ExecBlock("PMS100A4",.F.,.F.)
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

FreeUsedCode(.T.)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS100to101³ Autor ³ Cristiano G.da Cunha ³ Data ³ 15.04.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de controle de chamada da PMSA101.( Incl/Excl/Alt/Vis. ³±±
±±³          ³de tarefas).                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA100,SIGAPMS                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS100to101(nOpc,oTree,cEDT,cArquivo,lRefresh)

Local aArea		:= GetArea()
//Local cLastItem	:= "00"
Local cOrcamento
Local cNivAtu
Local cTrfAtu
Local cNivelAF5

Local aGetCpos


If oTree!= Nil
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecAlias	:= Val(SubStr(oTree:GetCargo(),4,12))
Else 
	cAlias := (cArquivo)->ALIAS
	nRecAlias := (cArquivo)->RECNO
Endif

If nOpc == 3
	If cAlias == "AF2"
		Aviso(STR0060,STR0061,{STR0062},2) //"Opcao invalida."###"A tarefa e o ultimo elemento na estrutura do projeto. Novos niveis e tarefas so poderao ser adicionados a uma EDT."###"Ok"
		Return
	Elseif cAlias == "AF1"
		Aviso(STR0060,STR0114,{STR0062},2) //"Opcao invalida."###"O Orçamento é o primeiro elemento na estrutura. Novos niveis e tarefas so poderao ser adicionados a uma EDT." //"Ok"
		Return
	EndIf
EndIf

dbSelectArea(cAlias)
dbGoto(nRecAlias)
Do Case
	Case nOpc == 3
		If cEDT == "1"
			cNivelAF2 := If(cAlias=="AF5",AF5->AF5_NIVEL,"000")
			If cNivelAF2 <> "000"
				cOrcamento	:= AF5->AF5_ORCAME
				cNivAtu		:= AF5->AF5_NIVEL
				cTrfAtu		:= AF5->AF5_EDT
			EndIf
			aGetCpos := {	{"AF5_ORCAME",AF1->AF1_ORCAME,.F.},;
							{"AF5_EDTPAI",cTrfAtu,.F.}}
		   
			If GetNewPar("MV_PMSTCOD","1")=="2"
				aAdd(aGetCpos,{"AF5_EDT",PmsNumAF5(AF1->AF1_ORCAME,cNivelAF2,cTrfAtu,,.F.),.F.})
			EndIf
										
			nRecAF2	:= PMSA101(3,aGetCpos,cNivelAF2,@lRefresh)
			If nRecAF2 <> Nil .And. cArquivo == Nil
				PMSTreeOrc(@oTree)
			EndIf
		Else
			cNivelAF5 := If(cAlias=="AF5",AF5->AF5_NIVEL,"000")
			If cNivelAF5 <> "000"
				cOrcamento	:= AF5->AF5_ORCAME
				cNivAtu		:= AF5->AF5_NIVEL
				cTrfAtu		:= AF5->AF5_EDT
			EndIf

			aGetCpos := {	{"AF2_ORCAME",AF1->AF1_ORCAME,.F.},;
							{"AF2_EDTPAI",cTrfAtu,.F.}}

					aAdd(aGetCpos,{"AF2_BDI",AF1->AF1_BDIPAD,.T.})
			If GetNewPar("MV_PMSTCOD","1")=="2"
				aAdd(aGetCpos,{"AF2_TAREFA",PmsNumAF2(AF1->AF1_ORCAME,cNivelAF5,cTrfAtu,,.F.),.F.})
			EndIf

			nRecAF2	:= PMSA103(3,aGetCpos,cNivelAF5,@lRefresh)
		EndIf
	Case nOpc == 2 .And. cAlias == "AF5"
		PMSA101(2,,"000",@lRefresh)
	Case nOpc == 2 .And. cAlias == "AF2"
		PMSA103(2,,"000",@lRefresh)
	Case nOpc == 4 .And. cAlias == "AF5"
		PMSA101(4,,"000",@lRefresh)
	Case nOpc == 4 .And. cAlias == "AF2"
		PMSA103(4,,"000",@lRefresh)
	Case nOpc == 5 .And. cAlias == "AF5"
		PMSA101(5,,"000",@lRefresh)
	Case nOpc == 5 .And. cAlias == "AF2"
		PMSA103(5,,"000",@lRefresh)
EndCase

FreeUsedCode(.T.)

RestArea(aArea)
Return	
	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS100Alt³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de alteracao no cadastro do Orcamento.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA100,SIGAPMS                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS100Alt(cAlias,nReg,nOpcx)
Local nOpc
Local aCposAlt	:= {"AF1_FASE","AF1_TRUNCA","AF1_BDI","AF1_ENCARG","AF1_SALBAS"}
Local aOldVal	:= {}
Local lRecalc	:= .F.
Local nx		:= 0
Local aButtons 	:= {}
Local aUsButtons:= {}
Local lPM100BU2 := ExistBlock("PM100BU2")

If PmsOrcUser(AF1->AF1_ORCAME,,Padr(AF1->AF1_ORCAME,Len(AF5->AF5_EDT)),"  ",3,"ESTRUT")
	If ExistBlock("PMS100A1")
		ExecBlock("PMS100A1",.F.,.F.)
	EndIf
	
	If lPM100BU2
		If ValType(aUsButtons := ExecBlock("PM100BU2", .F., .F.)) == "A"
			aEval(aUsButtons, { |x| aAdd(aButtons, x)})
		EndIf
	EndIf
	
	For nx := 1 to Len(aCposAlt)
		If AF1->(FieldPos(aCposAlt[nx])) > 0
			aAdd(aOldVal,{aCposAlt[nx],AF1->(FieldGet(AF1->(FieldPos(aCposAlt[nx]))))})
		EndIf
	Next
	nOpc := AxAltera(cAlias,nReg,nOpcx,,,,,"PMS100OK()",,,aButtons)
	
	If nOpc == 1
	
		// verifica a existencia do ponto de entrada PMS100A2
		If ExistBlock("PMS100A2")
			ExecBlock("PMS100A2",.F.,.F.,{nOpc})
		EndIf
	
		For nX := 1 to Len(aCposAlt)
			If AF1->(FieldPos(aCposAlt[nX])) > 0 .AND. (nPos := aScan( aOldVal,{|xValor| xValor[1] == aCposAlt[nX]}))>0
				If aOldVal[nPos][2] <> AF1->(FieldGet(AF1->(FieldPos(aCposAlt[nX]))))
					lRecalc := (Aviso(STR0051,STR0084,{STR0085,STR0086},2)==1) //"Atencao!"###"Foram alteradas algumas configurações que podem influenciar diretamente no custo deste orçamento. Voce deseja recalcular o custo neste momento ?"###"Sim"###"Mais Tarde"
					Exit
				EndIf
			EndIf
		Next nX
		
		If (AF1->AF1_RECALC=="1") .Or. lRecalc
			PMS100ReCalc()
		EndIf
		
	EndIf
Else
	Aviso(STR0087,STR0088,{STR0053},2) //"Usuário sem permissão"###"Usuário sem permissão para alteração nos usuários do orçamento. Verifique as permissões do usuário na estrutura principal do orçamento."###"Fechar"
EndIf

	
	
Return nOpc
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS100Cli³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida o codigo do cliente digitado.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA100,SIGAPMS                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS100Cli()
Local lRet 

If Empty(M->AF1_LOJA)
	lRet := Vazio() .Or. ExistCpo("SA1",M->AF1_CLIENT)
Else
	lRet := Vazio() .Or. ExistCpo("SA1",M->AF1_CLIENT+M->AF1_LOJA)
EndIf


Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS100Ok³ Autor ³ Edson Maricate          ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao TudoOk do cadastro de Orcamentos.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA100,SIGAPMS                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS100Ok()

Local lRet	:= .T.

If !Empty(M->AF1_CLIENT) .And. Empty(M->AF1_LOJA)
	HELP("   ",1,"PMSA10001")
	lRet := .F.
EndIf

If Empty(M->AF1_CLIENT) .And. !Empty(M->AF1_LOJA)
	HELP("   ",1,"PMSA10002")
	lRet := .F.
EndIf

If !MayIUseCode("AF1" + xFilial("AF1") + M->AF1_ORCAME)
	lRet := .F.
EndIf

If ExistBlock("PMA100Alt")
	lRet := Execblock("PMA100Alt",.F.,.F.)
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A100CtrMenu³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que controla as propriedades do Menu PopUp.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA100                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A100CtrMenu(oMenu,oTree,lVisual,cArquivo,oMenu2,nDlgPln)
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

If !lVisual

	If oMenu2 <> Nil
		oMenu2:aItems[1]:Enable()
		oMenu2:aItems[2]:Enable()
		oMenu2:aItems[4]:Enable()
	EndIf

	Do Case 
		Case cAlias == "AF5" .And. AF5->AF5_NIVEL=="001"
			If PmsOrcUser(AF5->AF5_ORCAME,,AF5->AF5_EDT,AF5->AF5_EDTPAI,3,"ESTRUT")
				oMenu:aItems[1]:Enable()
				oMenu:aItems[2]:Enable()
				oMenu:aItems[3]:Enable()
				oMenu:aItems[4]:Enable()
				oMenu:aItems[5]:Disable()
				oMenu:aItems[6]:Enable()
				oMenu:aItems[7]:Enable()
				oMenu:aItems[8]:Enable()
				oMenu:aItems[10]:Disable()

				If oMenu2 <> Nil
					oMenu2:aItems[3]:Enable()
				EndIf				
			ElseIf PmsOrcUser(AF5->AF5_ORCAME,,AF5->AF5_EDT,AF5->AF5_EDTPAI,2,"ESTRUT")
				oMenu:aItems[1]:Disable()
				oMenu:aItems[2]:Disable()
				oMenu:aItems[3]:Enable()
				oMenu:aItems[4]:Enable()
				oMenu:aItems[5]:Disable()
				oMenu:aItems[6]:Disable()
				oMenu:aItems[7]:Disable()
				oMenu:aItems[8]:Disable()
				oMenu:aItems[10]:Disable()

				If oMenu2 <> Nil
					oMenu2:aItems[3]:Enable()
				EndIf								
			Else
				oMenu:aItems[1]:Disable()
				oMenu:aItems[2]:Disable()
				oMenu:aItems[3]:Disable()
				oMenu:aItems[4]:Enable()
				oMenu:aItems[5]:Disable()
				oMenu:aItems[6]:Disable()
				oMenu:aItems[7]:Disable()
				oMenu:aItems[8]:Disable()
				oMenu:aItems[10]:Disable()

				If oMenu2 <> Nil
					oMenu2:aItems[3]:Disable()
				EndIf								
			EndIf

		Case cAlias == "AF5" .And. AF5->AF5_NIVEL!="001"
			If PmsOrcUser(AF5->AF5_ORCAME,,AF5->AF5_EDT,AF5->AF5_EDTPAI,3,"ESTRUT")
				oMenu:aItems[1]:Enable()
				oMenu:aItems[2]:Enable()
				oMenu:aItems[3]:Enable()
				oMenu:aItems[4]:Enable()
				oMenu:aItems[5]:Enable()
				oMenu:aItems[6]:Enable()
				oMenu:aItems[7]:Enable()
				oMenu:aItems[8]:Enable()
				oMenu:aItems[10]:Disable()

				If oMenu2 <> Nil
					oMenu2:aItems[3]:Enable()
				EndIf								
			ElseIf PmsOrcUser(AF5->AF5_ORCAME,,AF5->AF5_EDT,AF5->AF5_EDTPAI,2,"ESTRUT")
				oMenu:aItems[1]:Disable()
				oMenu:aItems[2]:Disable()
				oMenu:aItems[3]:Enable()
				oMenu:aItems[4]:Enable()
				oMenu:aItems[5]:Disable()
				oMenu:aItems[6]:Disable()
				oMenu:aItems[7]:Disable()
				oMenu:aItems[8]:Disable()
				oMenu:aItems[10]:Disable()

				If oMenu2 <> Nil
					oMenu2:aItems[3]:Enable()
				EndIf								
			Else
				oMenu:aItems[1]:Disable()
				oMenu:aItems[2]:Disable()
				oMenu:aItems[3]:Disable()
				oMenu:aItems[4]:Enable()
				oMenu:aItems[5]:Disable()
				oMenu:aItems[6]:Disable()
				oMenu:aItems[7]:Disable()
				oMenu:aItems[8]:Disable()
				oMenu:aItems[10]:Disable()

				If oMenu2 <> Nil
					oMenu2:aItems[3]:Disable()
				EndIf								
			EndIf
			
		Case cAlias == "AF2" 
			If PmsOrcUser(AF2->AF2_ORCAME,AF2->AF2_TAREFA,,AF2->AF2_EDTPAI,3,"ESTRUT")
				oMenu:aItems[1]:Disable()
				oMenu:aItems[2]:Disable()
				oMenu:aItems[3]:Enable()
				oMenu:aItems[4]:Enable()
				oMenu:aItems[5]:Enable()
				oMenu:aItems[6]:Disable()
				oMenu:aItems[7]:Disable()
				oMenu:aItems[8]:Disable()
				oMenu:aItems[10]:Enable()

				If oMenu2 <> Nil
					oMenu2:aItems[3]:Enable()
				EndIf							
			ElseIf PmsOrcUser(AF2->AF2_ORCAME,AF2->AF2_TAREFA,,AF2->AF2_EDTPAI,3,"ESTRUT")
				oMenu:aItems[1]:Disable()
				oMenu:aItems[2]:Disable()
				oMenu:aItems[3]:Enable()
				oMenu:aItems[4]:Enable()
				oMenu:aItems[5]:Disable()
				oMenu:aItems[6]:Disable()
				oMenu:aItems[7]:Disable()
				oMenu:aItems[8]:Disable()
				oMenu:aItems[10]:Enable()

				If oMenu2 <> Nil
					oMenu2:aItems[3]:Enable()
				EndIf							
			Else
				oMenu:aItems[1]:Disable()
				oMenu:aItems[2]:Disable()
				oMenu:aItems[3]:Disable()
				oMenu:aItems[4]:Enable()
				oMenu:aItems[5]:Disable()
				oMenu:aItems[6]:Disable()
				oMenu:aItems[7]:Disable()
				oMenu:aItems[8]:Disable()
				oMenu:aItems[9]:Disable()
				oMenu:aItems[10]:Disable()

			EndIf
		Otherwise
			oMenu:aItems[1]:Disable()
			oMenu:aItems[2]:Disable()
			oMenu:aItems[3]:Disable()
			oMenu:aItems[4]:Disable()
			oMenu:aItems[5]:Disable()
			oMenu:aItems[6]:Disable()
			oMenu:aItems[7]:Disable()
			oMenu:aItems[8]:Disable()
			oMenu:aItems[10]:Disable()

			If oMenu2 <> Nil
				oMenu2:aItems[3]:Disable()
			EndIf							
	EndCase
	If oMenu2<>Nil
		If PmsOrcUser(AF2->AF2_ORCAME,AF2->AF2_TAREFA,,AF2->AF2_EDTPAI,3,"ESTRUT")
			oMenu2:aItems[4]:Enable()
		Else
			oMenu2:aItems[4]:Disable()
		EndIf
	EndIf
	
EndIf

RestArea(aArea)
Return


/*/
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
/*/
Static Function FAtiva()
Pergunte("PMA100",.T.)
nDlgPln := mv_par01

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS100Import³ Autor ³Fabio Rogerio Pereira³ Data ³ 09-01-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de copia de EDT/Tarefas de outro orcamento           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA100                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS100Import(oTree,cArquivo,nOrcPrj)
Local lRet     := .F.
Local aImport  := {}
Local aArea    := GetArea()
Local aAreaAF1 := AF1->(GetArea())
Local aAreaAF2 := AF2->(GetArea())
Local aAreaAF5 := AF5->(GetArea())
Local aPM100Cpy:= {}

Local aMarkPrj := {}
                  
If oTree != Nil
	cAlias:= SubStr(oTree:GetCargo(),1,3)
	nRecno:= Val(SubStr(oTree:GetCargo(),4,12))
Else
	cAlias := (cArquivo)->ALIAS
	nRecNo := (cArquivo)->RECNO
EndIf

// exibe uma tela de selecao dos orcamentos/projetos para importacao
If nOrcPrj == 1
	aImport := PmsSelTsk(STR0046,"AF1/AF5/AF2","AF5/AF2",STR0047,"AF1",,,.T.,,@aMarkPrj) //"Selecione a EDT/Tarefa"###"Selecao Invalida"
Else
	aImport := PmsSelTsk(STR0046,"AF8/AFC/AF9","AFC/AF9",STR0047,,,,.T.,,@aMarkPrj) //"Selecione a EDT/Tarefa"###"Selecao Invalida"
EndIf

If ExistBlock("PM100Cpy")
	
	aPM100Cpy :={	cAlias,;
					nRecno,;
					Iif(Len(aImport) > 0,aImport[1],Nil),;
					Iif(Len(aImport) > 0,aImport[2],Nil),;
					nOrcPrj,;
					aMarkPrj;
				}
	
	lRet := ExecBlock("PM100Cpy", .F., .F.,aPM100Cpy)

	If lRet
		RestArea(aArea)
		Return !lRet
	EndIf
EndIf

If (Len(aImport) > 0)
       Processa({|| lRet := PmsOrcCopy(cAlias,nRecno,aImport[1],aImport[2],nOrcPrj,aMarkPrj)}, STR0109)  //"Copiando estrutura..."
EndIf

If ExistBlock("PM100POC")
	ExecBlock("PM100POC", .F., .F.)
EndIf

RestArea(aAreaAF5)
RestArea(aAreaAF2)
RestArea(aAreaAF1)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms100ETarefa³ Autor ³Fabio Rogerio Pereira³ Data ³29.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializa o array com os itens a serem copiados.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pms100ETarefa(cOrcame,cChave,cCampo,nOrdem)
Local aArea		:= GetArea()
Local aStru     := {}
Local aAreaAF2	:= AF2->(GetArea())
Local aAreaAF3	:= AF3->(GetArea())
Local aAreaAF4	:= AF4->(GetArea())
Local aAreaAF7	:= AF7->(GetArea())
Local aTarefas	:= {}
Local nTarefa   := 0
Local nItem		:= 0

DEFAULT cOrcame:= AF2->AF2_ORCAME
DEFAULT cCampo := AF2->AF2_TAREFA
DEFAULT cCampo := "AF2->AF2_TAREFA"
DEFAULT nOrdem := 1

dbSelectArea("AF2")
dbSetOrder(nOrdem)
dbSeek(xFilial("AF2") + cOrcame + cChave,.T.)

While !Eof() .And. (AF2->AF2_FILIAL == xFilial("AF2")) .And. (AF2->AF2_ORCAME == cOrcame) .And. (&(cCampo) == cChave)

	// inicializa o array da tarefa
	aStru := AF2->(dbStruct())
  	aAdd(aTarefas,{AF2->AF2_TAREFA,Array(Len(aStru)),{},{},{},{}})
  
  	nTarefa:= Len(aTarefas)


	// armazena os dados da tarefa
	dbSelectArea("AF2")
	AEval(aStru,{|cValue,nX|aTarefas[nTarefa,2,nX]:= {aStru[nX,1],FieldGet(FieldPos(aStru[nX,1]))}})

	// pesquisa todos os produtos da tarefa
	dbSelectArea("AF3")
	dbSetOrder(1)
	dbSeek(xFilial("AF3") + AF2->AF2_ORCAME + AF2->AF2_TAREFA)
	aStru := AF3->(dbStruct())

	While !Eof() .And. (AF3->AF3_FILIAL+AF3->AF3_ORCAME+AF3->AF3_TAREFA == ;
						xFilial("AF3")+AF2->AF2_ORCAME+AF2->AF2_TAREFA)

		aAdd(aTarefas[nTarefa,3],Array(Len(aStru)))
		nItem:= Len(aTarefas[nTarefa,3])
		
		AEval(aStru,{|cValue,nX|aTarefas[nTarefa,3,nItem,nX]:= {aStru[nX,1],FieldGet(FieldPos(aStru[nX,1]))}})

		dbSelectArea("AF3")
		dbSkip()
	End
	
	// pesquisa todas as despesas da tarefa
	dbSelectArea("AF4")
	dbSetOrder(1)
	dbSeek(xFilial("AF4") + AF2->AF2_ORCAME + AF2->AF2_TAREFA)
	aStru := AF4->(dbStruct())

	While !Eof() .And. (AF4->AF4_FILIAL+AF4->AF4_ORCAME+AF4->AF4_TAREFA == ;
						xFilial("AF4")+AF2->AF2_ORCAME+AF2->AF2_TAREFA)

		aAdd(aTarefas[nTarefa,4],Array(Len(aStru)))
		nItem:= Len(aTarefas[nTarefa,4])
		
		AEval(aStru,{|cValue,nX|aTarefas[nTarefa,4,nItem,nX]:= {aStru[nX,1],FieldGet(FieldPos(aStru[nX,1]))}})
		dbSelectArea("AF4")
		dbSkip()
	End

	// pesquisa todas os relacionamentos da tarefa
	dbSelectArea("AF7")
	dbSetOrder(1)
	dbSeek(xFilial("AF7") + AF2->AF2_ORCAME + AF2->AF2_TAREFA)
	aStru := AF7->(dbStruct())

	While !Eof() .And. (AF7->AF7_FILIAL+AF7->AF7_ORCAME+AF7->AF7_TAREFA == ;
						xFilial("AF7")+AF2->AF2_ORCAME+AF2->AF2_TAREFA)

		aAdd(aTarefas[nTarefa,5],Array(Len(aStru)))
		nItem:= Len(aTarefas[nTarefa,5])
		
		AEval(aStru,{|cValue,nX|aTarefas[nTarefa,5,nItem,nX]:= {aStru[nX,1],FieldGet(FieldPos(aStru[nX,1]))}})
		
		dbSelectArea("AF7")
		dbSkip()
	End

	// pesquisa todos os documentos da tarefa
	dbSelectArea("AC9")
	dbSetOrder(2)
	dbSeek(xFilial("AC9") + "AF2" + AF2->AF2_FILIAL + AF2->AF2_ORCAME + AF2->AF2_TAREFA)

	aStru := AC9->(dbStruct())

	While !Eof() .And. (AllTrim(AC9->AC9_FILIAL + AC9->AC9_ENTIDA + AC9->AC9_FILENT + AC9->AC9_CODENT) == ;
						 AllTrim(xFilial("AC9") + "AF2" + xFilial("AF2") + AF2->AF2_ORCAME+AF2->AF2_TAREFA))

		aAdd(aTarefas[nTarefa,6],Array(Len(aStru)))
		nItem:= Len(aTarefas[nTarefa,6])
		
		AEval(aStru,{|cValue,nX|aTarefas[nTarefa,6,nItem,nX]:= {aStru[nX,1],FieldGet(FieldPos(aStru[nX,1]))}})
		
		dbSelectArea("AC9")
		dbSkip()
	End

	dbSelectArea("AF2")
	dbSkip()
End

RestArea(aAreaAF2)
RestArea(aAreaAF3)
RestArea(aAreaAF4)
RestArea(aAreaAF7)
RestArea(aArea)

Return(aTarefas)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms100EEDT   ³ Autor ³Fabio Rogerio Pereira³ Data ³30.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inicializa o array com os itens a serem copiados.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA100                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pms100EEDT(cChave,aEDT)
Local aArea		:= GetArea()
Local aStru     := {}
Local aAreaAF2	:= AF2->(GetArea())
Local aAreaAF5	:= AF5->(GetArea())
Local nEDT      := 0
Local nItem     := 0

dbSelectArea("AF5")
dbSetOrder(1)
If MsSeek(xFilial("AF5") + cChave,.T.)

	aStru := AF5->(dbStruct())
	aAdd(aEDT,{AF5->AF5_EDT,Array(Len(aStru)),{},{}})
	nEDT:= Len(aEDT)

	// armazena os dados da edt
	dbSelectArea("AF5")
	AEval(aStru,{|cValue,nX|aEDT[nEDT,2,nX]:= {aStru[nX,1],FieldGet(FieldPos(aStru[nX,1]))}})

	// pesquisa todos os documentos da tarefa
	dbSelectArea("AC9")
	dbSetOrder(2)
	dbSeek(xFilial("AC9") + "AF5" + AF5->AF5_FILIAL + AF5->AF5_ORCAME + AF5->AF5_EDT)

	aStru := AC9->(dbStruct())

	While !Eof() .And. (AllTrim(AC9->AC9_FILIAL + AC9->AC9_ENTIDA + AC9->AC9_FILENT + AC9->AC9_CODENT) == ;
						AllTrim(xFilial("AC9") + "AF5" + xFilial("AF5") + AF5->AF5_ORCAME+AF5->AF5_EDT))

		aAdd(aEDT[nEDT,3],Array(Len(aStru)))
		nItem:= Len(aEDT[nEDT,3])
		
		AEval(aStru,{|cValue,nX|aEDT[nEDT,3,nItem,nX]:= {aStru[nX,1],FieldGet(FieldPos(aStru[nX,1]))}})
		
		dbSelectArea("AC9")
		dbSkip()
	End

	// pesquisa todas as tarefas da edt
	dbSelectArea("AF2")
	dbSetOrder(2)
	If MsSeek(xFilial("AF2") + AF5->AF5_ORCAME + AF5->AF5_EDT)
		aEDT[nEDT,4]:= Pms100ETarefa(AF2->AF2_ORCAME,AF2->AF2_EDTPAI,"AF2->AF2_EDTPAI",2)
	EndIf
EndIf

dbSelectArea("AF5")
dbSetOrder(2)
If MsSeek(xFilial("AF5")+cChave)
	While !Eof() .And. (xFilial("AF5")+cChave == AF5->AF5_FILIAL+AF5->AF5_ORCAME+AF5->AF5_EDTPAI) .And. !Empty(AF5_EDTPAI)
		Pms100EEDT(AF5->AF5_ORCAME+AF5->AF5_EDT,@aEDT)
		dbSelectArea("AF5")
		dbSkip()
	End
EndIf

RestArea(aAreaAF2)
RestArea(aAreaAF5)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms100AltCus³ Autor ³Fabio Rogerio Pereira ³ Data ³ 26-12-2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que altera os custos do orcamento.			            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pms100AltCus()
Local lRet		:= .F.
Local aParam1   := {}
Local aParam2   := {}
Local aTipos    := {STR0063,STR0025,STR0064,STR0027} //"Atualizar do Cadastro"###"Aplicar Percentual"###"Atualizar Custos Por Projeto (Manual)"###"Atualizar Custos Por Tarefa (Manual)"
Local aCalculo  := {STR0028,STR0029} //"Acrescimo"###"Descrescimo"
Local cFiltroB1 := ""
Local cFiltroAF3:= ""

// ponto de entrada utilizado para customizar
// o cálculo de custo
If ExistBlock("PMS100AC")
	Return ExecBlock("PMS100AC", .F., .F.)
EndIf

If ExistTemplate("PMS100AC")
	ExecTemplate("PMS100AC",.F.,.F.)
Else

	// verifica o evento de alteracao no Fase atual
	If !PmsVldFase("AF1",AF1->AF1_ORCAME,"11") .Or. !ParamBox( {	{3,STR0030,1,aTipos,130,"",.F.},;       //"Tipo de Reajuste"
																	{1,STR0065,CriaVar("B1_COD",.F.),"@!","","SB1","",80,.F.},;  //"Produto De"
																	{1,STR0066,Replicate("Z",TamSX3("B1_COD")[1]),"@!","","SB1","",80,.F.},;  //"Produto Ate"
																	{1,STR0067,CriaVar("B1_TIPO",.F.),"@!","","02","",10,.F.},;  //"Tipo Produto"
																	{1,STR0068,CriaVar("B1_GRUPO",.F.),"@!","","SBM","",40,.F.},;  //"Grupo De"
																	{1,STR0069,Replicate("Z",TamSX3("B1_GRUPO")[1]),"@!","","SBM","",40,.F.}},STR0031,@aParam1)  //"Grupo Ate"###"Parametros"

		Return(.F.)
	EndIf

	// filtra o arquivo de produtos para pesquisa otimizada
	cFiltroB1 := 	"B1_COD   >= '" + aParam1[2] + "' .And. B1_COD   <= '" + aParam1[3] + "' .And. " +;
					"B1_GRUPO >= '" + aParam1[5] + "' .And. B1_GRUPO <= '" + aParam1[6] + "'"

	
	If !Empty(aParam1[4])
		cFiltroB1+= " .And. B1_TIPO == '" + aParam1[4] + "'"
	EndIf

	// filtra os produtos do orcamento/projeto para pesquisa otimizada
	cFiltroAF3:= "AF3_FILIAL == '" + xFilial("AF3") + "' .And. " +;
			   "AF3_ORCAME == '" + AF1->AF1_ORCAME + "' .And. "+;
				 "AF3_PRODUT >= '" + aParam1[2] + "' .And. AF3_PRODUT <= '" + aParam1[3] + "'"
	

	Do Case
		Case (aParam1[1] == 1)
			Processa({||lRet:= Pms100ACCad(cFiltroAF3,cFiltroB1)},STR0032) //"Atualizando custos. Aguarde..."
		
		Case (aParam1[1] == 2)

			If ParamBox( { {3,STR0033,1,aCalculo ,100,"",.T.},;  //"Tipo de Calculo"
	 				       {1,STR0034,0,"9999.99","Mv_Par02 > 0","","",100,.T.}},STR0031,@aParam2)  //"Percentual Reajuste""Parametros"
	    	
				Processa({||lRet:= Pms100APerc(cFiltroAF3,cFiltroB1,aParam2)},STR0032) //"Atualizando custos. Aguarde..."
			EndIf
		
		
		Case (aParam1[1] == 3) .Or. (aParam1[1] == 4)
			lRet:= Pms100AManual(cFiltroAF3,cFiltroB1,aParam1)
		
	EndCase

	If lRet

		// atualiza os custos das tarefas e das edts
		PMS100ReCalc()
	EndIf
EndIf


Return(.F.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms100ACCad     ³ Autor ³Fabio Rogerio Pereira ³ Data ³ 26-12-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que altera os custos do orcamento c/cadastro de prod/recurs.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pms100ACCad(cFiltroAF3,cFiltroB1)
Local nCusto   := 0          
Local cDesc    := ""
Local cAliasQry:= ""


cAliasQry := "AF3"

// filtra o arquivo de produtos para pesquisa otimizada
DbSelectArea("SB1")
DbSetOrder(1)
DbClearFilter()

If !Empty(cFiltroB1)
	DbSetFilter({||&(cFiltroB1)},cFiltroB1)
EndIf

// filtra os produtos do orcamento/projeto para pesquisa otimizada
DbSelectArea(cAliasQry)
DbSetOrder(1)
MsSeek(xFilial("AF3") + AF1->AF1_ORCAME)

While !Eof() .And. &(cFiltroAF3)
	If AF3->(AF3->AF3_RECALC != "2")
		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek(xFilial("SB1")+(cAliasQry)->AF3_PRODUT)
			nCusto:= RetFldProd(SB1->B1_COD,"B1_CUSTD") 
		cDesc := AllTrim(SB1->B1_DESC)
					
		If (nCusto > 0)
				RecLock("AF3",.F.)			
				Replace AF3->AF3_CUSTD With nCusto
				MsUnlock()
			EndIf
		EndIf
	EndIf			        
	IncProc(STR0035 + cDesc) //"Atualizando "
			
	dbSelectArea(cAliasQry)
	dbSkip()
End
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbClearFilter()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms100APerc     ³ Autor ³Fabio Rogerio Pereira ³ Data ³ 26-12-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que altera os custos do orcamento aplicando percentual.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pms100APerc(cFiltroAF3,cFiltroB1,aParam)        
Local nCusto  := 0                                
Local cDesc   := ""
Local cAliasQry:= ""

//#IFDEF TOP
//	cAliasQry := CriaTrab( ,.F.) 
		
//	cQuery := 	"SELECT * FROM "  + RetSqlName( "AF3" ) + " WHERE D_E_L_E_T_=' ' "
	
//	If !Empty(cFiltroAF3)
//		cQuery+= " AND " + cFiltroAF3
//	EndIf
                            
//	If !Empty(cFiltroB1)
//		cQuery+= " AND AF3_PRODUT IN (SELECT B1_COD FROM " + RetSqlName( "SB1" ) + " WHERE D_E_L_E_T_= ' ' AND " + cFiltroB1 + ")"
//    EndIf
    
//	cQuery += " ORDER BY 1"
//	cQuery := PMSChangeQuery( cQuery ) 
	
//	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. ) 
		
//#ELSE
	cAliasQry := "AF3"

	// filtra o arquivo de produtos para pesquisa otimizada
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbClearFilter()
	
	If !Empty(cFiltroB1)
		DbSetFilter({||&(cFiltroB1)},cFiltroB1)
	EndIf
	
	// filtra os produtos do orcamento para pesquisa otimizada
	DbSelectArea("AF3")
	DbSetOrder(1)
	MsSeek(xFilial("AF3") + AF1->AF1_ORCAME)
//#ENDIF

While !Eof() .And. &(cFiltroAF3)
	cDesc := AllTrim(Posicione("SB1",1,xFilial("SB1") + (cAliasQry)->AF3_PRODUT,"B1_DESC"))
	If AF3->(AF3->AF3_RECALC != "2")
		If aParam[1] == 1
			nCusto:= (cAliasQry)->AF3_CUSTD + (((cAliasQry)->AF3_CUSTD * aParam[2]) / 100)
		Else	
			nCusto:= (cAliasQry)->AF3_CUSTD - (((cAliasQry)->AF3_CUSTD * aParam[2]) / 100)
		EndIf
	
		If (nCusto > 0)
			//#IFDEF TOP
			//	DbSelectArea("AF3")
			//	DbSetOrder(1)
			//	MsSeek(xFilial("AF3") + AF1->AF1_ORCAME + (cAliasQry)->AF3_TAREFA + (cAliasQry)->AF3_ITEM) //FILIAL+ORCAMENTO/PROJETO+TAREFA+ITEM
			//#ENDIF

			RecLock("AF3",.F.)
			Replace AF3->AF3_CUSTD With nCusto
			MsUnlock()
		EndIf         
	EndIf
		
	IncProc(STR0035 + cDesc)  //"Atualizando "
	dbSelectArea(cAliasQry)
	dbSkip()
End

//#IFNDEF TOP
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbClearFilter()




//#ENDIF                   
	
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms100AManual   ³ Autor ³Fabio Rogerio Pereira ³ Data ³ 26-12-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que altera os custos do projeto manualmente.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMS100AManual(cFiltroAF3,cFiltroB1,aParam)
Local lRet     := .F.
Local oProdutos
Local oDlg
Local aProdutos:= {}
Local aObjects := {}
Local aPosObj  := {}
Local aSize    := MsAdvSize(.T.)
Local nPos     := 0 
Local cDesc    := ""
Local cTarefa  := ""
Local cPict    := PesqPict("AF3","AF3_CUSTD")
Local cAliasQry:= ""

Local nQuantAF3:= 0

//#IFDEF TOP
//	cAliasQry := CriaTrab( ,.F.) 
		
//	cQuery := 	"SELECT * FROM "  + RetSqlName( "AF3" ) + " WHERE D_E_L_E_T_=' ' "
	
//	If !Empty(cFiltroAF3)
//		cQuery+= " AND " + cFiltroAF3
//	EndIf
                            
//	If !Empty(cFiltroB1)
//		cQuery+= " AND AF3_PRODUT IN (SELECT B1_COD FROM " + RetSqlName( "SB1" ) + " WHERE D_E_L_E_T_= ' ' AND " + cFiltroB1 + ")"
//    EndIf
    
//	cQuery += " ORDER BY 1"
//	cQuery := PMSChangeQuery( cQuery ) 
	
//	DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. ) 
//	DbGoTop()	
//#ELSE
	cAliasQry := "AF3"

	// filtra o arquivo de produtos para pesquisa otimizada
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbClearFilter()
	
	If !Empty(cFiltroB1)
		DbSetFilter({||&(cFiltroB1)},cFiltroB1)
	EndIf
	
	// filtra os produtos do orcamento para pesquisa otimizada
	DbSelectArea("AF3")
	DbSetOrder(1)
	MsSeek(xFilial("AF3") + AF1->AF1_ORCAME)

//#ENDIF

While !Eof() .And. &(cFiltroAF3)
	cDesc    := AllTrim(Posicione("SB1",1,xFilial("SB1") + (cAliasQry)->AF3_PRODUT,"B1_DESC"))
	cTarefa  := Posicione("AF2",1,xFilial("AF2") + AF1->AF1_ORCAME + (cAliasQry)->AF3_TAREFA,"AF2_DESCRI")
	nQuantAF2:= Posicione("AF2",1,xFilial("AF2") + AF1->AF1_ORCAME + (cAliasQry)->AF3_TAREFA,"AF2_QUANT")
	nQuantAF3:= PmsAF3Quant(AF1->AF1_ORCAME,(cAliasQry)->AF3_TAREFA,(cAliasQry)->AF3_PRODUT,nQuantAF2,(cAliasQry)->AF3_QUANT,,,(cAliasQry)->AF3_RECURS)
	
	If aParam[1] == 3 //Orcamento
		nPos:= aScan(aProdutos,{|x| x[1] == (cAliasQry)->AF3_PRODUT})
		If (nPos > 0)
			aProdutos[nPos][5]+= nQuantAF3
		Else
			Aadd(aProdutos,{(cAliasQry)->AF3_PRODUT,cDesc,"","",nQuantAF3,(cAliasQry)->AF3_CUSTD})
		EndIf
			
	ElseIf aParam[1] == 4	//Tarefa

		nPos:= aScan(aProdutos,{|x| x[1]+x[3] == (cAliasQry)->AF3_PRODUT + (cAliasQry)->AF3_TAREFA})
		If (nPos > 0)
			aProdutos[nPos][5]+= nQuantAF3
		Else
			Aadd(aProdutos,{(cAliasQry)->AF3_PRODUT,cDesc,(cAliasQry)->AF3_TAREFA,cTarefa,nQuantAF3,(cAliasQry)->AF3_CUSTD})
		EndIf
	EndIf
			
	dbSelectArea(cAliasQry)
	dbSkip()
End

If (Len(aProdutos) == 0)
	Aadd(aProdutos,{"","","","",0,0})
EndIf

aAdd( aObjects, { 100, 100, .T., .T., .T. } )  

aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 } 
aPosObj:= MsObjSize( aInfo, aObjects, .T.,.F. )  

DEFINE MSDIALOG oDlg TITLE STR0036 FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL //"Atualizacao de Custo"

	@ aPosObj[1,1] , aPosObj[1,2] LISTBOX oProdutos FIELDS	COLSIZES 50,120,50,120,80,80 HEADER STR0037,STR0038,STR0039,STR0038,STR0040,STR0041 SIZE aPosObj[1,3] , aPosObj[1,4] DESIGN  OF oDlg PIXEL  ////"Produto","Descricao","Tarefa","Descricao","Quantidade","Custo Unitario"
	oProdutos:SetArray(aProdutos)
	oProdutos:bLine     := { || {aProdutos[oProdutos:nAT,1],aProdutos[oProdutos:nAT,2],aProdutos[oProdutos:nAT,3],aProdutos[oProdutos:nAT,4],Transform(aProdutos[oProdutos:nAT,5],cPict),Transform(aProdutos[oProdutos:nAT,6],cPict)}}
	oProdutos:blDblClick:= { || Pms100ChgCusto(@aProdutos,oProdutos,oDlg)}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| lRet:= .T. , Processa({||Pms100GrvCusto(cFiltroAF3,aProdutos,aParam)},STR0032),oDlg:End() },{||oDlg:End()}) //"Atualizando custos. Aguarde..."

//#IFNDEF TOP
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbClearFilter()

//#ENDIF                   

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms100ChgCusto  ³ Autor ³Fabio Rogerio Pereira ³ Data ³ 26-12-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que altera os custos do projeto manualmente.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                        	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pms100ChgCusto(aArray,oObj)        
Local oDlg
Local oGet
Local oGet1
Local nCusto:= 0

DEFINE MSDIALOG oDlg TITLE STR0036 FROM 001,001 TO 150, 250 OF oMainWnd PIXEL //"Atualizacao de Custo"
    @002,002 TO 50,125 LABEL STR0042 OF oDlg PIXEL //"Custos"

	@010,005 SAY STR0043 PIXEL SIZE 50,8 OF oDlg  //"Custo Atual"
	@010,055 MSGET oGet1 VAR aArray[oObj:nAT][6] PICTURE PesqPict("AF3","AF3_CUSTD") PIXEL SIZE 60,8 OF oDlg WHEN .F.
	oGet1:cSX1Hlp := "PMSA1003"

	@025,005 SAY STR0044 PIXEL SIZE 50,8 OF oDlg //"Custo Novo"
	@025,055 MSGET oGet VAR nCusto PICTURE PesqPict("AF3","AF3_CUSTD") PIXEL SIZE 60,8 OF oDlg
	oGet:cSX1Hlp := "PMSA1004"

	DEFINE SBUTTON FROM 55, 60   TYPE 1 ENABLE OF oDlg ACTION (aArray[oObj:nAT][6]:= nCusto,oDlg:End())
	DEFINE SBUTTON FROM 55, 90   TYPE 2 ENABLE OF oDlg ACTION (oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms100GrvCusto  ³ Autor ³Fabio Rogerio Pereira ³ Data ³ 26-12-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que grava os custos do projeto manualmente.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMS100GrvCusto(cFiltroAF3,aProdutos,aParam)
Local nView:= 0

// grava o custo dos produtos orcamento
For nView:= 1 To Len(aProdutos)
	If (aParam[1] == 3)    //Orcamento
		dbSelectArea("AF3")
		dbSetOrder(2)
		If MsSeek(xFilial("AF3") + AF1->AF1_ORCAME,.T.)
			While !Eof() .And. &(cFiltroAF3)
				If (AF3->AF3_PRODUT == aProdutos[nView][1])
					RecLock("AF3",.F.)
					Replace AF3->AF3_CUSTD With aProdutos[nView][6]
					MsUnLock()
				EndIf
						
				dbSkip()
			End
		EndIf  
	ElseIf (aParam[1] == 4) //Tarefa
		dbSelectArea("AF3")
		dbSetOrder(1)
		If MsSeek(xFilial("AF3") + AF1->AF1_ORCAME + aProdutos[nView][3])
			While !Eof() .And. (xFilial("AF3") + AF1->AF1_ORCAME + aProdutos[nView][3] == AF3->AF3_FILIAL + AF3->AF3_ORCAME + AF3->AF3_TAREFA)
				If (aProdutos[nView][1] == AF3->AF3_PRODUT)
					RecLock("AF3",.F.)
					Replace AF3->AF3_CUSTD With aProdutos[nView][6]
					MsUnLock()
				EndIf
			
				dbSkip()
			End
		EndIf  
	EndIf	
	
	IncProc(STR0035 + aProdutos[nView][2]) //"Atualizando "
Next

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms100AEDT      ³ Autor ³Fabio Rogerio Pereira ³ Data ³ 26-12-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que atualiza os custos totais das Tarefas/EDT.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS100AEDT()  
Local aArea:= GetArea()

If (AF1->(Empty(AF1->AF1_AUTCUS) .OR. AF1->AF1_AUTCUS=="1"))
	Processa({||Pms100AuxEDT()},STR0032) //"Atualizando Custos da EDT. Aguarde..."
EndIf

RestArea(aArea)

Return( .T. )

Static Function PmsA100Fix(cSQL, cDB)
Local c,s,a,i,pc,cc,t,j,lc

cDB:=AllTrim(Upper(cDB))

if cDB=="INFORMIX"
	
	cSQL:=StrTran(cSQL,"LTRIM ( ","TRIM ( ")
	cSQL:=StrTran(cSQL,"VALUES (","")
	cSQL:=StrTran(cSQL,";);",";")
	cSQL:=StrTran(cSQL,"numeric","decimal(28,12)")
	
	s:=''
	a:=cSQL
	i:=AT("ROUND", a)
	do while i>0
		pc:=1
		cc:=0
		s:=s+left(a,i-1)
		t:=""
		j:=i+7
		lc:=-1
		do while j<len(a) .and. pc>0
			j:=j+1
			c:=substr(a,j,1)
			do case
				case c=')'
					pc--
				case c='('
					pc++
				case c=',' .and. pc==1
					cc++
					lc:=j
			endcase
		enddo
		if pc>0
			a:=substr(a,i)
			i:=0
		else
			if cc=2
				a:="TRUNC ( "+substr(a, i+8, lc-i-8)+")"+substr(a,j+1)
			else
				s:=s+"ROUND ( "
				a:=substr(a,i+8)
			endif
			i:=AT("ROUND", a)
		endif
	enddo
	cSQL:=s+a
	
elseif cDB=="ORACLE"
	
	cSQL:=StrTran(cSQL,"= ''","is null")
	cSQL:=StrTran(cSQL,"<> ''","is not null")
	cSQL:=StrTran(cSQL,"numeric","decimal(28,12)")
	
	s:=''
	a:=cSQL
	i:=AT("ROUND", a)
	do while i>0
		pc:=1
		cc:=0
		s:=s+left(a,i-1)
		t:=""
		j:=i+7
		lc:=-1
		do while j<len(a) .and. pc>0
			j:=j+1
			c:=substr(a,j,1)
			do case
				case c=')'
					pc--
				case c='('
					pc++
				case c=',' .and. pc==1
					cc++
					lc:=j
			endcase
		enddo
		if pc>0
			a:=substr(a,i)
			i:=0
		else
			if cc=2
				a:="TRUNC ( "+substr(a, i+7, lc-i-7)+")"+substr(a,j+1)
			else
				s:=s+"ROUND ( "
				a:=substr(a,i+7)
			endif
			i:=AT("ROUND", a)
		endif
	enddo
	cSQL:=s+a
	
elseif cDB=="DB2"
	
	cSQL:=StrTran(cSQL,"set vfim_CUR  = 0 ;","set fim_CUR = 0;")
	cSQL:=StrTran(cSQL,"vTX1 DECIMAL( 28 , 12 ) ;","vTx1 DOUBLE;")
	cSQL:=StrTran(cSQL,"vTX2 DECIMAL( 28 , 12 ) ;","vTx2 DOUBLE;")
	cSQL:=StrTran(cSQL,"vTX3 DECIMAL( 28 , 12 ) ;","vTx3 DOUBLE;")
	cSQL:=StrTran(cSQL,"vTX4 DECIMAL( 28 , 12 ) ;","vTx4 DOUBLE;")
	cSQL:=StrTran(cSQL,"vTX5 DECIMAL( 28 , 12 ) ;","vTx5 DOUBLE;")
	cSQL:=StrTran(cSQL,"set vfim_CUR  = 0 ;","set fim_CUR  = 0 ;")
	
	s:=''
	a:=cSQL
	i:=AT("ROUND", a)
	do while i>0
		pc:=1
		cc:=0
		s:=s+left(a,i-1)
		t:=""
		j:=i+7
		lc:=-1
		do while j<len(a) .and. pc>0
			j:=j+1
			c:=substr(a,j,1)
			do case
				case c=')'
					pc--
				case c='('
					pc++
				case c=',' .and. pc==1
					cc++
					lc:=j
			endcase
		enddo
		if pc>0
			a:=substr(a,i)
			i:=0
		else
			if cc=2
				a:="TRUNC ( "+substr(a, i+8, lc-i-8)+")"+substr(a,j+1)
			else
				s:=s+"ROUND ( "
				a:=substr(a,i+8)
			endif
			i:=AT("ROUND", a)
		endif
	enddo
	cSQL:=s+a
	
elseif cDB=="SYBASE"
	
	cSQL:=StrTran(cSQL,"numeric","decimal(28,12)")
	
elseif cDB=="MSSQL"
	
	cSQL:=StrTran(cSQL,"numeric","decimal(28,12)")
	
else
	
	cSQL:=StrTran(cSQL,"numeric","decimal(28,12)")
	
endif

Return cSQL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms100Exec      ³ Autor ³ Marcelo Akama        ³ Data ³ 09-12-2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza os custos totais das Tarefas/EDT com SQL                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pms100Exec(cFil, cOrcamento, cPmsCust, cDtBase, aDec, nAtuTarefa, nAtuEDT, cTmp1, cTmp2, cProc)
Local cSQL   := ''
Local cRet   := 1
Local lRet   :=.t.
Local aResult:={}

Local cAF1:=RetSQLName("AF1")
Local cAF3:=RetSQLName("AF3")
Local cAF2:=RetSQLName("AF2")
Local cAF4:=RetSQLName("AF4")
Local cSM2:=RetSQLName("SM2")
Local cAF5:=RetSQLName("AF5")

if !TCSPExist( cProc )
    
	cSQL:=cSQL+"create procedure "+cProc+" (@IN_ATUAF2 int, @IN_ATUAF5 int, @OUT_RET int output) as"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"declare @DTCONV	char(8)			-- Data da conversão"+CRLF
	cSQL:=cSQL+"declare @TRUNC	char(1)			-- Tipo arredondamento/truncamento"+CRLF
	cSQL:=cSQL+"declare @BDIPAD	decimal(28,12)	-- BDI padrão do projeto"+CRLF
	cSQL:=cSQL+"declare @NIVEL	varchar(250)	-- Nivel"+CRLF
	cSQL:=cSQL+"declare @I		int"+CRLF
	cSQL:=cSQL+"declare @J		int"+CRLF
	cSQL:=cSQL+"declare @K		int"+CRLF
	cSQL:=cSQL+"declare @DTAUX	char(8)			-- Data"+CRLF
	cSQL:=cSQL+"declare @DT1	char(8)			-- Data 1"+CRLF
	cSQL:=cSQL+"declare @DT2	char(8)			-- Data 2"+CRLF
	cSQL:=cSQL+"declare @MOEDA	int				-- Moeda"+CRLF
	cSQL:=cSQL+"declare @TX1	decimal(28,12)	-- TX1"+CRLF
	cSQL:=cSQL+"declare @TX2	decimal(28,12)	-- TX2"+CRLF
	cSQL:=cSQL+"declare @TX3	decimal(28,12)	-- TX3"+CRLF
	cSQL:=cSQL+"declare @TX4	decimal(28,12)	-- TX4"+CRLF
	cSQL:=cSQL+"declare @TX5	decimal(28,12)	-- TX5"+CRLF
	cSQL:=cSQL+"declare @VL1	decimal(28,12)	-- Valor 1"+CRLF
	cSQL:=cSQL+"declare @VL2	decimal(28,12)	-- Valor 2"+CRLF
	cSQL:=cSQL+"declare @VL3	decimal(28,12)	-- Valor 3"+CRLF
	cSQL:=cSQL+"declare @VL4	decimal(28,12)	-- Valor 4"+CRLF
	cSQL:=cSQL+"declare @VL5	decimal(28,12)	-- Valor 5"+CRLF
	cSQL:=cSQL+"declare @BDI	decimal(28,12)	-- BDI"+CRLF
	cSQL:=cSQL+"declare @EDT	varchar(250)	-- EDT"+CRLF
	cSQL:=cSQL+"declare @EDTPAI	varchar(250)	-- EDTPai"+CRLF
	cSQL:=cSQL+"declare @TASK	varchar(250)	-- Tarefa"+CRLF
	cSQL:=cSQL+"declare @DT		datetime"+CRLF
	
	If cPaisLoc == "BOL"  
		cSQL:=cSQL+"declare @IT  	decimal(28,12)	-- IT" +CRLF	
		cSQL:=cSQL+"declare @VALIT	decimal(28,12)	-- VALIT"+CRLF	
		cSQL:=cSQL+"declare @UTIL	decimal(28,12)	-- UTIL" +CRLF	
		cSQL:=cSQL+"declare @VALUTI	decimal(28,12)	-- VALUTI"+CRLF	
	EndIf	
	
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"declare @fim_CUR	int			-- Indica fim do cursor no DB2"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"select @OUT_RET=0"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"select @DTCONV=ltrim(AF1_DTCONV), @TRUNC=ltrim(AF1_TRUNCA), @BDIPAD=AF1_BDIPAD"+CRLF
	cSQL:=cSQL+"from "+cAF1+""+CRLF
	cSQL:=cSQL+"where AF1_FILIAL='"+cFil+"' and AF1_ORCAME='"+cOrcamento+"' and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"if @TRUNC='' select @TRUNC='1'"+CRLF
	cSQL:=cSQL+"if ltrim(@DTCONV)='' select @DTCONV='"+cDtBase+"'"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"begin transaction"+CRLF
	cSQL:=cSQL+"	"+CRLF
	cSQL:=cSQL+"	if @IN_ATUAF2<>0"+CRLF
	cSQL:=cSQL+"		begin"+CRLF
	cSQL:=cSQL+"	"+CRLF
	cSQL:=cSQL+"			-- Recursos"+CRLF
	cSQL:=cSQL+"			insert into "+cTmp1+" (TAREFA,VALOR,QUANT,VALOR1,VALOR2,VALOR3,VALOR4,VALOR5,MOEDA,DTCONV,TX1,TX2,TX3,TX4,TX5)"+CRLF
	cSQL:=cSQL+"			select"+CRLF
	cSQL:=cSQL+"				AF3_TAREFA as TAREFA,"+CRLF
	cSQL:=cSQL+"				AF3_QUANT*AF3_CUSTD as VALOR,"+CRLF
	cSQL:=cSQL+"				AF2_QUANT as QUANT,"+CRLF
	cSQL:=cSQL+"				0 as VALOR1,"+CRLF
	cSQL:=cSQL+"				0 as VALOR2,"+CRLF
	cSQL:=cSQL+"				0 as VALOR3,"+CRLF
	cSQL:=cSQL+"				0 as VALOR4,"+CRLF
	cSQL:=cSQL+"				0 as VALOR5,"+CRLF
	cSQL:=cSQL+"				AF3_MOEDA as MOEDA,"+CRLF
	cSQL:=cSQL+"				'' as DTCONV,"+CRLF
	cSQL:=cSQL+"				1.0 as TX1, AF2_TXMO2 as TX2, AF2_TXMO3 as TX3, AF2_TXMO4 as TX4, AF2_TXMO5 as TX5"+CRLF
	cSQL:=cSQL+"			from "+cAF3+" a, "+cAF2+" b"+CRLF
	cSQL:=cSQL+"			where AF3_FILIAL='"+cFil+"' and AF3_ORCAME='"+cOrcamento+"'  and a.D_E_L_E_T_<>'*' and b.D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+"			and AF3_FILIAL=AF2_FILIAL and AF3_ORCAME=AF2_ORCAME and AF3_TAREFA=AF2_TAREFA"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			-- Despesas"+CRLF
	cSQL:=cSQL+"			insert into "+cTmp1+" (TAREFA,VALOR,QUANT,VALOR1,VALOR2,VALOR3,VALOR4,VALOR5,MOEDA,DTCONV,TX1,TX2,TX3,TX4,TX5)"+CRLF
	cSQL:=cSQL+"			select"+CRLF
	cSQL:=cSQL+"				AF4_TAREFA as TAREFA,"+CRLF
	cSQL:=cSQL+"				AF4_VALOR as VALOR,"+CRLF
	cSQL:=cSQL+"				AF2_QUANT as QUANT,"+CRLF
	cSQL:=cSQL+"				0 as VALOR1,"+CRLF
	cSQL:=cSQL+"				0 as VALOR2,"+CRLF
	cSQL:=cSQL+"				0 as VALOR3,"+CRLF
	cSQL:=cSQL+"				0 as VALOR4,"+CRLF
	cSQL:=cSQL+"				0 as VALOR5,"+CRLF
	cSQL:=cSQL+"				AF4_MOEDA as MOEDA,"+CRLF
	cSQL:=cSQL+"				'' as DTCONV,"+CRLF
	cSQL:=cSQL+"				1.0 as TX1, AF2_TXMO2 as TX2, AF2_TXMO3 as TX3, AF2_TXMO4 as TX4, AF2_TXMO5 as TX5"+CRLF
	cSQL:=cSQL+"			from "+cAF4+" a, "+cAF2+" b"+CRLF
	cSQL:=cSQL+"			where AF4_FILIAL='"+cFil+"' and AF4_ORCAME='"+cOrcamento+"' and a.D_E_L_E_T_<>'*' and b.D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+"			and AF4_FILIAL=AF2_FILIAL and AF4_ORCAME=AF2_ORCAME and AF4_TAREFA=AF2_TAREFA"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set DTCONV=@DTCONV"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			-- Atualiza a taxa de conversão das moedas quando não informado"+CRLF
	cSQL:=cSQL+"			declare cur cursor for select DTCONV from "+cTmp1+" where TX2=0 or TX3=0 or TX4=0 or TX5=0 group by DTCONV"+CRLF
	cSQL:=cSQL+"			open cur"+CRLF
	cSQL:=cSQL+"			fetch next from cur into @DTAUX"+CRLF
	cSQL:=cSQL+"			while @@FETCH_STATUS = 0"+CRLF
	cSQL:=cSQL+"				begin"+CRLF
	cSQL:=cSQL+"					select @TX2=0, @TX3=0, @TX4=0, @TX5=0"+CRLF
	cSQL:=cSQL+"					select @TX2=M2_MOEDA2, @TX3=M2_MOEDA3, @TX4=M2_MOEDA4, @TX5=M2_MOEDA5 from "+cSM2+" where D_E_L_E_T_<>'*' and M2_DATA=@DTAUX"+CRLF
	cSQL:=cSQL+"					if @TX2=0 select @TX2=1"+CRLF
	cSQL:=cSQL+"					if @TX3=0 select @TX3=1"+CRLF
	cSQL:=cSQL+"					if @TX4=0 select @TX4=1"+CRLF
	cSQL:=cSQL+"					if @TX5=0 select @TX5=1"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set TX2=@TX2 where DTCONV=@DTAUX and TX2=0"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set TX3=@TX3 where DTCONV=@DTAUX and TX3=0"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set TX4=@TX4 where DTCONV=@DTAUX and TX4=0"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set TX5=@TX5 where DTCONV=@DTAUX and TX5=0"+CRLF
	cSQL:=cSQL+"					select @fim_CUR=0"+CRLF
	cSQL:=cSQL+"					fetch next from cur into @DTAUX"+CRLF
	cSQL:=cSQL+"				end"+CRLF
	cSQL:=cSQL+"			close cur"+CRLF
	cSQL:=cSQL+"			deallocate cur"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			-- Atualiza os valores"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR1=VALOR    , VALOR2=VALOR/TX2    , VALOR3=VALOR/TX3    , VALOR4=VALOR/TX4    , VALOR5=VALOR/TX5     where MOEDA=1"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR1=VALOR*TX2, VALOR2=VALOR        , VALOR3=VALOR*TX2/TX3, VALOR4=VALOR*TX2/TX4, VALOR5=VALOR*TX2/TX5 where MOEDA=2"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR1=VALOR*TX3, VALOR2=VALOR*TX3/TX2, VALOR3=VALOR        , VALOR4=VALOR*TX3/TX4, VALOR5=VALOR*TX3/TX5 where MOEDA=3"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR1=VALOR*TX4, VALOR2=VALOR*TX4/TX2, VALOR3=VALOR*TX4/TX3, VALOR4=VALOR        , VALOR5=VALOR*TX4/TX5 where MOEDA=4"+CRLF
	cSQL:=cSQL+"			update "+cTmp1+" set VALOR1=VALOR*TX5, VALOR2=VALOR*TX5/TX2, VALOR3=VALOR*TX5/TX3, VALOR4=VALOR*TX5/TX4, VALOR5=VALOR         where MOEDA=5"+CRLF
	cSQL:=cSQL+"			"+CRLF
	cSQL:=cSQL+"			-- Arredonta/Trunca"+CRLF
	cSQL:=cSQL+"			if '"+cPmsCust+"'='1'	-- Custo total"+CRLF
	cSQL:=cSQL+"				if @TRUNC='1' or @TRUNC='3' -- Trunca"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set"+CRLF
	cSQL:=cSQL+"						VALOR1=round(VALOR1,"+ltrim(str(aDec[1]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR2=round(VALOR2,"+ltrim(str(aDec[2]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR3=round(VALOR3,"+ltrim(str(aDec[3]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR4=round(VALOR4,"+ltrim(str(aDec[4]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR5=round(VALOR5,"+ltrim(str(aDec[5]))+",1)"+CRLF
	cSQL:=cSQL+"				else -- Arredonda"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set"+CRLF
	cSQL:=cSQL+"						VALOR1=round(VALOR1,"+ltrim(str(aDec[1]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR2=round(VALOR2,"+ltrim(str(aDec[2]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR3=round(VALOR3,"+ltrim(str(aDec[3]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR4=round(VALOR4,"+ltrim(str(aDec[4]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR5=round(VALOR5,"+ltrim(str(aDec[5]))+")"+CRLF
	cSQL:=cSQL+"			else	-- Custo unitário"+CRLF
	cSQL:=cSQL+"				if @TRUNC='1' -- Trunca unitário do item"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set"+CRLF
	cSQL:=cSQL+"						VALOR1=round(VALOR1*QUANT,"+ltrim(str(aDec[1]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR2=round(VALOR2*QUANT,"+ltrim(str(aDec[2]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR3=round(VALOR3*QUANT,"+ltrim(str(aDec[3]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR4=round(VALOR4*QUANT,"+ltrim(str(aDec[4]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR5=round(VALOR5*QUANT,"+ltrim(str(aDec[5]))+",1)"+CRLF
	cSQL:=cSQL+"				else if @TRUNC='2'	-- Arredonda unitário do item"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set"+CRLF
	cSQL:=cSQL+"						VALOR1=round(VALOR1*QUANT,"+ltrim(str(aDec[1]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR2=round(VALOR2*QUANT,"+ltrim(str(aDec[2]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR3=round(VALOR3*QUANT,"+ltrim(str(aDec[3]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR4=round(VALOR4*QUANT,"+ltrim(str(aDec[4]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR5=round(VALOR5*QUANT,"+ltrim(str(aDec[5]))+")"+CRLF
	cSQL:=cSQL+"				else if @TRUNC='3'	-- Trunca unitário da tarefa"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set"+CRLF
	cSQL:=cSQL+"						VALOR1=round(round(VALOR1,"+ltrim(str(aDec[1]))+",1)*QUANT,"+ltrim(str(aDec[1]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR2=round(round(VALOR2,"+ltrim(str(aDec[2]))+",1)*QUANT,"+ltrim(str(aDec[2]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR3=round(round(VALOR3,"+ltrim(str(aDec[3]))+",1)*QUANT,"+ltrim(str(aDec[3]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR4=round(round(VALOR4,"+ltrim(str(aDec[4]))+",1)*QUANT,"+ltrim(str(aDec[4]))+",1),"+CRLF
	cSQL:=cSQL+"						VALOR5=round(round(VALOR5,"+ltrim(str(aDec[5]))+",1)*QUANT,"+ltrim(str(aDec[5]))+",1)"+CRLF
	cSQL:=cSQL+"				else	-- Arredonda unitário da tarefa"+CRLF
	cSQL:=cSQL+"					update "+cTmp1+" set"+CRLF
	cSQL:=cSQL+"						VALOR1=round(round(VALOR1,"+ltrim(str(aDec[1]))+")*QUANT,"+ltrim(str(aDec[1]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR2=round(round(VALOR2,"+ltrim(str(aDec[2]))+")*QUANT,"+ltrim(str(aDec[2]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR3=round(round(VALOR3,"+ltrim(str(aDec[3]))+")*QUANT,"+ltrim(str(aDec[3]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR4=round(round(VALOR4,"+ltrim(str(aDec[4]))+")*QUANT,"+ltrim(str(aDec[4]))+"),"+CRLF
	cSQL:=cSQL+"						VALOR5=round(round(VALOR5,"+ltrim(str(aDec[5]))+")*QUANT,"+ltrim(str(aDec[5]))+")"+CRLF
	cSQL:=cSQL+"			"+CRLF
	cSQL:=cSQL+"			-- Pega valor de BDI"+CRLF
	If cPaisLoc == "BOL"
		cSQL := cSQL+"			insert into "+cTmp2+" (TAREFA2,EDTPAI,BDI,FLAG,UTIBDI,IT,VALIT,UTIL,VALUTI)"+CRLF
	Else
		cSQL := cSQL+"			insert into "+cTmp2+" (TAREFA2,EDTPAI,BDI,FLAG,UTIBDI)"+CRLF	
	EndIf
	cSQL:=cSQL+"			select"+CRLF
	cSQL:=cSQL+"				AF2_TAREFA as TAREFA2,"+CRLF
	cSQL:=cSQL+"				AF2_EDTPAI as EDTPAI,"+CRLF
	cSQL:=cSQL+"				AF2_BDI as BDI,"+CRLF
	cSQL:=cSQL+"				0 as FLAG,"+CRLF
	cSQL:=cSQL+"				AF2_UTIBDI as UTIBDI"+CRLF

	If cPaisLoc == "BOL" //__lAF2ValUti .And. __lAF2ValUti    
		cSQL:=cSQL+"				,AF2_IT as IT"+CRLF	
		cSQL:=cSQL+"				,AF2_VALIT as VALIT"+CRLF	
		cSQL:=cSQL+"				,AF2_UTIL as UTIL"+CRLF	
		cSQL:=cSQL+"				,AF2_VALUTI as VALUTI"+CRLF	
	EndIf		

	cSQL:=cSQL+"			from "+cAF2+""+CRLF
	cSQL:=cSQL+"			where AF2_FILIAL='"+cFil+"' and AF2_ORCAME='"+cOrcamento+"' and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+""+CRLF                                    

	If cPaisLoc == "BOL"
		cSQL:=cSQL+"			update "+cTmp2+" set FLAG=1 where BDI<>0 or UTIBDI='2' or IT <> 0  or VALIT <> 0 or UTIL <> 0 or VALUTI <> 0 -- atualiza flag"+CRLF
	Else
		cSQL:=cSQL+"			update "+cTmp2+" set FLAG=1 where BDI<>0 or UTIBDI='2'  -- atualiza flag"+CRLF	
	EndIf

	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			-- Se não tiver BDI cadastrado, pega das EDT's pais, se ainda não tiver, pega BDI padrão do orçamento"+CRLF
	cSQL:=cSQL+"			declare cur_bdi cursor for select EDTPAI from "+cTmp2+" where FLAG=0 group by EDTPAI"+CRLF
	cSQL:=cSQL+"			open cur_bdi"+CRLF
	cSQL:=cSQL+"			fetch next from cur_bdi into @EDT"+CRLF
	cSQL:=cSQL+"			while @@FETCH_STATUS = 0"+CRLF
	cSQL:=cSQL+"				begin"+CRLF

	If cPaisLoc == "BOL"
		cSQL:=cSQL+"					select @BDI=AF5_BDITAR, @EDTPAI=AF5_EDTPAI, @VALIT=AF5_VALIT, @VALUTI=AF5_VALUTI from "+cAF5+" where AF5_EDT=@EDT and AF5_FILIAL='"+cFil+"' and AF5_ORCAME='"+cOrcamento+"' and D_E_L_E_T_<>'*'"+CRLF	
	Else
		cSQL:=cSQL+"					select @BDI=AF5_BDITAR, @EDTPAI=AF5_EDTPAI from "+cAF5+" where AF5_EDT=@EDT and AF5_FILIAL='"+cFil+"' and AF5_ORCAME='"+cOrcamento+"' and D_E_L_E_T_<>'*'"+CRLF	
	EndIf

	cSQL:=cSQL+"--					while exists(select FLAG from "+cTmp2+" where FLAG=0 and EDTPAI=@EDT and ltrim(EDTPAI)<>'')"+CRLF
	cSQL:=cSQL+"					select @I=count(*) from "+cTmp2+" where FLAG=0 and EDTPAI=@EDT and ltrim(EDTPAI)<>''"+CRLF
	cSQL:=cSQL+"					while @I>0"+CRLF
	cSQL:=cSQL+"						begin"+CRLF

	If cPaisLoc == "BOL"
		cSQL:=cSQL+"							update "+cTmp2+" set BDI=@BDI, EDTPAI=@EDTPAI, IT=@IT, VALIT=@VALIT,UTIL=@UTIL, VALUTI=@VALUTI where FLAG=0 and EDTPAI=@EDT"+CRLF
	Else	
		cSQL:=cSQL+"							update "+cTmp2+" set BDI=@BDI, EDTPAI=@EDTPAI where FLAG=0 and EDTPAI=@EDT"+CRLF
	EndIf

	cSQL:=cSQL+"							update "+cTmp2+" set FLAG=1 where FLAG=0 and BDI<>0"+CRLF
	cSQL:=cSQL+"							update "+cTmp2+" set BDI=@BDIPAD, FLAG=1 where FLAG=0 and ltrim(EDTPAI)=''"+CRLF
	cSQL:=cSQL+"							select @EDT=@EDTPAI"+CRLF

	If cPaisLoc == "BOL"
		cSQL:=cSQL+"							select @BDI=AF5_BDITAR, @EDTPAI=AF5_EDTPAI, @VALIT=AF5_VALIT, @VALUTI=AF5_VALUTI from "+cAF5+" where AF5_EDT=@EDT and AF5_FILIAL='"+cFil+"' and AF5_ORCAME='"+cOrcamento+"' and D_E_L_E_T_<>'*'"+CRLF
	Else
		cSQL:=cSQL+"							select @BDI=AF5_BDITAR, @EDTPAI=AF5_EDTPAI from "+cAF5+" where AF5_EDT=@EDT and AF5_FILIAL='"+cFil+"' and AF5_ORCAME='"+cOrcamento+"' and D_E_L_E_T_<>'*'"+CRLF
	EndIf

	cSQL:=cSQL+"							select @I=count(*) from "+cTmp2+" where FLAG=0 and EDTPAI=@EDT and ltrim(EDTPAI)<>''"+CRLF
	cSQL:=cSQL+"						end"+CRLF
	cSQL:=cSQL+"					select @fim_CUR=0"+CRLF
	cSQL:=cSQL+"					fetch next from cur_bdi into @EDT"+CRLF
	cSQL:=cSQL+"				end"+CRLF
	cSQL:=cSQL+"			close cur_bdi"+CRLF
	cSQL:=cSQL+"			deallocate cur_bdi"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			-- Atualiza o custo das tarefas"+CRLF
	cSQL:=cSQL+"			declare cur_tsk cursor for"+CRLF
	cSQL:=cSQL+"				select AF2_TAREFA from "+cAF2+""+CRLF
	cSQL:=cSQL+"				where AF2_FILIAL='"+cFil+"' and AF2_ORCAME='"+cOrcamento+"' and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+"				group by AF2_TAREFA"+CRLF
	cSQL:=cSQL+"			open cur_tsk"+CRLF
	cSQL:=cSQL+"			fetch next from cur_tsk into @TASK"+CRLF
	cSQL:=cSQL+"			while @@FETCH_STATUS = 0"+CRLF
	cSQL:=cSQL+"				begin"+CRLF
	cSQL:=cSQL+"					select @TX1=0, @TX2=0, @TX3=0, @TX4=0, @TX5=0, @BDI=0"+CRLF
	cSQL:=cSQL+"					select @TX1=sum(VALOR1), @TX2=sum(VALOR2), @TX3=sum(VALOR3), @TX4=sum(VALOR4), @TX5=sum(VALOR5) from "+cTmp1+" where TAREFA=@TASK group by TAREFA"+CRLF
	
	If cPaisLoc == "BOL"
		cSQL:=cSQL+"					select @BDI=BDI, @IT=IT, @VALIT=VALUTI, @UTIL=UTIL, @VALIT=VALUTI  from "+cTmp2+" where TAREFA2=@TASK"+CRLF
	Else
		cSQL:=cSQL+"					select @BDI=BDI from "+cTmp2+" where TAREFA2=@TASK"+CRLF
	EndIf
	
	cSQL:=cSQL+"					select @TX1=isnull(@TX1,0), @TX2=isnull(@TX2,0), @TX3=isnull(@TX3,0), @TX4=isnull(@TX4,0), @TX5=isnull(@TX5,0), @BDI=isnull(@BDI,0)"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"					update "+cAF2+" set"+CRLF
	cSQL:=cSQL+"						AF2_CUSTO =isnull(@TX1,0),"+CRLF
	cSQL:=cSQL+"						AF2_CUSTO2=isnull(@TX2,0),"+CRLF
	cSQL:=cSQL+"						AF2_CUSTO3=isnull(@TX3,0),"+CRLF
	cSQL:=cSQL+"						AF2_CUSTO4=isnull(@TX4,0),"+CRLF
	cSQL:=cSQL+"						AF2_CUSTO5=isnull(@TX5,0),"+CRLF
	cSQL:=cSQL+"						AF2_VALBDI=round((isnull(@TX1,0)*isnull(@BDI,0)/100)+0.0000001 ,"+ltrim(str(aDec[1]))+"),"+CRLF
	
	If cPaisLoc == "BOL"      
		cSQL:=cSQL+"						AF2_VALIT =round((isnull(@TX1,0)*isnull(@IT,0)/100)+0.0000001 ,"+ltrim(str(aDec[1]))+"),"+CRLF
		cSQL:=cSQL+"						AF2_VALUTI=round((isnull(@TX1,0)*isnull(@UTIL,0)/100)+0.0000001 ,"+ltrim(str(aDec[1]))+"),"+CRLF
		cSQL:=cSQL+"						AF2_TOTAL =round((isnull(@TX1,0)*(1+(isnull(@BDI,0)/100)))+0.0000001 ,"+ltrim(str(aDec[1]))+")+@VALIT"+CRLF
	Else
		cSQL:=cSQL+"						AF2_TOTAL =round((isnull(@TX1,0)*(1+(isnull(@BDI,0)/100)))+0.0000001 ,"+ltrim(str(aDec[1]))+")"+CRLF
	EndIf
	
	cSQL:=cSQL+"					where AF2_FILIAL='"+cFil+"' and AF2_ORCAME='"+cOrcamento+"' and AF2_TAREFA=@TASK and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"					select @fim_CUR=0"+CRLF
	cSQL:=cSQL+"					fetch next from cur_tsk into @TASK"+CRLF
	cSQL:=cSQL+"				end"+CRLF
	cSQL:=cSQL+"			close cur_tsk"+CRLF
	cSQL:=cSQL+"			deallocate cur_tsk"+CRLF
	cSQL:=cSQL+"			"+CRLF
	cSQL:=cSQL+"		end"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"	if @IN_ATUAF5<>0"+CRLF
	cSQL:=cSQL+"		begin"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			-- zera custo das EDT's"+CRLF
	
	If cPaisLoc == "BOL"
		cSQL:=cSQL+"			update "+cAF5+" set AF5_CUSTO=0, AF5_CUSTO2=0, AF5_CUSTO3=0, AF5_CUSTO4=0, AF5_CUSTO5=0, AF5_VALBDI=0, AF5_TOTAL=0, AF5_VALIT=0, AF5_VALUTI=0"+CRLF	
	Else
		cSQL:=cSQL+"			update "+cAF5+" set AF5_CUSTO=0, AF5_CUSTO2=0, AF5_CUSTO3=0, AF5_CUSTO4=0, AF5_CUSTO5=0, AF5_VALBDI=0, AF5_TOTAL=0"+CRLF
	EndIf
	
	cSQL:=cSQL+"			where AF5_FILIAL='"+cFil+"' and AF5_ORCAME='"+cOrcamento+"' and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"			declare cur_lvl cursor for"+CRLF
	cSQL:=cSQL+"				select AF5_NIVEL from "+cAF5+""+CRLF
	cSQL:=cSQL+"				where AF5_FILIAL='"+cFil+"' and AF5_ORCAME='"+cOrcamento+"' and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+"				group by AF5_NIVEL"+CRLF
	cSQL:=cSQL+"				order by AF5_NIVEL DESC"+CRLF
	cSQL:=cSQL+"			open cur_lvl"+CRLF
	cSQL:=cSQL+"			fetch next from cur_lvl into @NIVEL"+CRLF
	cSQL:=cSQL+"			while @@FETCH_STATUS = 0"+CRLF
	cSQL:=cSQL+"				begin"+CRLF
	cSQL:=cSQL+"					declare cur_elv cursor for"+CRLF
	cSQL:=cSQL+"						select AF5_EDT from "+cAF5+""+CRLF
	cSQL:=cSQL+"						where AF5_FILIAL='"+cFil+"' and AF5_ORCAME='"+cOrcamento+"' and AF5_NIVEL=@NIVEL and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+"						group by AF5_EDT"+CRLF
	cSQL:=cSQL+"					open cur_elv"+CRLF
	cSQL:=cSQL+"					fetch next from cur_elv into @EDT"+CRLF
	cSQL:=cSQL+"					while @@FETCH_STATUS = 0"+CRLF
	cSQL:=cSQL+"						begin"+CRLF
	cSQL:=cSQL+"							select @TX1=0, @TX2=0, @TX3=0, @TX4=0, @TX5=0, @VL1=0, @VL2=0, @VL3=0, @VL4=0, @VL5=0, @BDI=0, @BDIPAD=0"+CRLF
	
	If cPaisLoc == "BOL"
		cSQL:=cSQL+"							select @TX1=sum(AF2_CUSTO), @TX2=sum(AF2_CUSTO2), @TX3=sum(AF2_CUSTO3), @TX4=sum(AF2_CUSTO4), @TX5=sum(AF2_CUSTO5), @BDI=sum(AF2_VALBDI),@IT=sum(AF2_IT),@VALIT=sum(AF2_VALIT),@VALUTI=sum(AF2_VALUTI)"+CRLF	
	Else
		cSQL:=cSQL+"							select @TX1=sum(AF2_CUSTO), @TX2=sum(AF2_CUSTO2), @TX3=sum(AF2_CUSTO3), @TX4=sum(AF2_CUSTO4), @TX5=sum(AF2_CUSTO5), @BDI=sum(AF2_VALBDI)"+CRLF
	EndIf		
	
	cSQL:=cSQL+"								from "+cAF2+" where AF2_FILIAL='"+cFil+"' and AF2_ORCAME='"+cOrcamento+"' and AF2_EDTPAI=@EDT and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+"							select @VL1=sum(AF5_CUSTO), @VL2=sum(AF5_CUSTO2), @VL3=sum(AF5_CUSTO3), @VL4=sum(AF5_CUSTO4), @VL5=sum(AF5_CUSTO5), @BDIPAD=sum(AF5_VALBDI)"+CRLF
	cSQL:=cSQL+"								from "+cAF5+" where AF5_FILIAL='"+cFil+"' and AF5_ORCAME='"+cOrcamento+"' and AF5_EDTPAI=@EDT and D_E_L_E_T_<>'*'"+CRLF
	
	If cPaisLoc == "BOL"
		cSQL:=cSQL+"							select @TX1=isnull(@TX1,0), @TX2=isnull(@TX2,0), @TX3=isnull(@TX3,0), @TX4=isnull(@TX4,0), @TX5=isnull(@TX5,0), @BDI=isnull(@BDI,0), @IT=isnull(@IT,0), @VALIT=isnull(@VALIT,0), @UTIL=isnull(@UTIL,0), @VALUTI=isnull(@VALUTI,0)"+CRLF
	Else
		cSQL:=cSQL+"							select @TX1=isnull(@TX1,0), @TX2=isnull(@TX2,0), @TX3=isnull(@TX3,0), @TX4=isnull(@TX4,0), @TX5=isnull(@TX5,0), @BDI=isnull(@BDI,0)"+CRLF
	EndIf		
	
	cSQL:=cSQL+"							select @VL1=isnull(@VL1,0), @VL2=isnull(@VL2,0), @VL3=isnull(@VL3,0), @VL4=isnull(@VL4,0), @VL5=isnull(@VL5,0), @BDIPAD=isnull(@BDIPAD,0)"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"							update "+cAF5+" set"+CRLF
	cSQL:=cSQL+"								AF5_CUSTO =isnull(@TX1,0)+isnull(@VL1,0),"+CRLF
	cSQL:=cSQL+"								AF5_CUSTO2=isnull(@TX2,0)+isnull(@VL2,0),"+CRLF
	cSQL:=cSQL+"								AF5_CUSTO3=isnull(@TX3,0)+isnull(@VL3,0),"+CRLF
	cSQL:=cSQL+"								AF5_CUSTO4=isnull(@TX4,0)+isnull(@VL4,0),"+CRLF
	cSQL:=cSQL+"								AF5_CUSTO5=isnull(@TX5,0)+isnull(@VL5,0),"+CRLF
	cSQL:=cSQL+"								AF5_VALBDI=isnull(@BDI,0)+isnull(@BDIPAD,0),"+CRLF
	
	If cPaisLoc == "BOL"
		cSQL:=cSQL+"								AF5_VALIT=isnull(@VALIT,0),"+CRLF
		cSQL:=cSQL+"								AF5_VALUTI=isnull(@UTIL,0),"+CRLF
		cSQL:=cSQL+"								AF5_TOTAL =isnull(@TX1,0)+isnull(@BDI,0)+isnull(@VL1,0)+isnull(@BDIPAD,0)+isnull(@VALIT,0)+isnull(@VALUTI,0)"+CRLF
	Else
		cSQL:=cSQL+"								AF5_TOTAL =isnull(@TX1,0)+isnull(@BDI,0)+isnull(@VL1,0)+isnull(@BDIPAD,0)"+CRLF
	EndIf		
	
	cSQL:=cSQL+"							where AF5_FILIAL='"+cFil+"' and AF5_ORCAME='"+cOrcamento+"' and AF5_EDT=@EDT and D_E_L_E_T_<>'*'"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"							select @fim_CUR=0"+CRLF
	cSQL:=cSQL+"							fetch next from cur_elv into @EDT"+CRLF
	cSQL:=cSQL+"						end"+CRLF
	cSQL:=cSQL+"					close cur_elv"+CRLF
	cSQL:=cSQL+"					deallocate cur_elv"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"					select @fim_CUR=0"+CRLF
	cSQL:=cSQL+"					fetch next from cur_lvl into @NIVEL"+CRLF
	cSQL:=cSQL+"				end"+CRLF
	cSQL:=cSQL+"			close cur_lvl"+CRLF
	cSQL:=cSQL+"			deallocate cur_lvl"+CRLF
	cSQL:=cSQL+"		end"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"commit"+CRLF
	cSQL:=cSQL+""+CRLF
	cSQL:=cSQL+"select @OUT_RET=1"+CRLF
	
	cSQL:=MsParse(cSQL,Alltrim(TcGetDB()))
	
	if cSQL=''
		if !__lBlind
 			MsgAlert(STR0110+" "+cProc+": "+MsParseError())  //'Erro criando a Stored Procedure:'
		endif
	else
	
		cSQL:=PmsA100Fix(cSQL, Alltrim(TcGetDB()))
		
		cRet:=TcSqlExec(cSQL)
		if cRet <> 0
			if !__lBlind
	 			MsgAlert(STR0110+" "+cProc+": "+TCSqlError())  //'Erro criando a Stored Procedure:'
			endif
			lRet := .f.	
		endif
	endif
else
	cRet:=0
endif

if cRet=0
	aResult := TCSPExec( cProc, nAtuTarefa, nAtuEDT )
	if empty(aResult)
		if !__lBlind
			MsgAlert(STR0111+" "+cProc+": "+TCSqlError())  //'Erro executando a Stored Procedure'
		endif
		lRet := .f.
	elseif aResult[1] != 1
		if !__lBlind
			MsgAlert(STR0112+": "+TCSqlError())   //'Erro atualizando custos
		endif
		lRet := .f.
	endif
endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms100AuxEDT    ³ Autor ³Fabio Rogerio Pereira ³ Data ³ 26-12-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que atualiza os custos totais das Tarefas/EDT.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMS100AuxEDT()
Local aAreaAF2		:= {}
Local aCustoAF2		:= {}
Local aVal			:= {}
Local cOrcamento	:= AF1->AF1_ORCAME
Local nRecAF2		:= 0                                                                            
Local lSQL		:= Upper(TcSrvType()) != "AS/400" .and. Upper(TcSrvType()) != "ISERIES" .and. ! ("POSTGRES" $ Upper(TCGetDB()))
Local lBlock	:= ExistBlock("PMAF2CST")
Local cTrunca	:= "1"
Local cPmsCust	:= SuperGetMv("MV_PMSCUST",.F.,"1")
Local lTotal	:= cPmsCust=="1"
Local nRec		:= 0
Local dDtConv	:= iif(empty(AF1->AF1_DTCONV), dDataBase, AF1->AF1_DTCONV)
Local aTX2M		:= {0,0,0,0,0}
Local aStruct	:= {}
Local cArqTrab  := ""
Local cPaiOld
Local nCusto
Local nMoeda
Local nQuantTrf
Local n1,n2,n3,n4,n5,n6,n7,n8
Local cTmp1		:=CriaTrab(nil,.F.)
Local cTmp2		:=CriaTrab(nil,.F.)
Local cProc		:='PMS100_'+CriaTrab(nil,.F.)
Local aFields:={}
Local aDecCst	:= {0,0,0,0,0}
Local _oPMS100Au

aDecCst[1]:=TamSX3("AF2_CUSTO")[2]
aDecCst[2]:=TamSX3("AF2_CUSTO2")[2]
aDecCst[3]:=TamSX3("AF2_CUSTO3")[2]
aDecCst[4]:=TamSX3("AF2_CUSTO4")[2]
aDecCst[5]:=TamSX3("AF2_CUSTO5")[2]

If ExistTemplate("PMAAF2CTrf") // Se existir template

	dbSelectArea("AF2")
	dbSetOrder(1)
	If MsSeek(xFilial("AF2") + cOrcamento)
		PmsNewProc("ORC",cOrcamento)

		While !Eof() .And. (xFilial("AF2") + cOrcamento == AF2->AF2_FILIAL + AF2->AF2_ORCAME)
			ExecTemplate("PMAAF2CTrf",.F.,.F.,{AF2->AF2_ORCAME,AF2->AF2_TAREFA})
		
			If lBlock
				nRecAF2 := AF2->( Recno() )
				ExecBlock("PMAF2CST", .F., .F.)
				AF2->( dbgoto( nRecAF2 ) )
			EndIf
		
			// atualiza o custo das edts pais
    		aAreaAF2:= AF2->(GetArea())
			PmsAvalAF2("AF2")
			RestArea(aAreaAF2)

			dbSkip()
			PmsIncProc(.T.,,"ORC")
		End
	EndIf
else // recálculo novo

	cTrunca:=AF1->AF1_TRUNCA		
	ASIZE(aCustoAF2,5)
	ASIZE(aVal,5)

	// Calcula custo das tarefas
	if lSQL // Se for diferente de AS/400, recalcula com SQL
		
		// Criacao das tabelas temporárias
		
		if Alltrim(Upper(TcGetDb()))=="INFORMIX"
			TCSqlExec('CREATE TABLE '+cTmp1+' ( TAREFA    char('+ltrim(str(TamSX3("AF2_TAREFA")[1]))+'), VALOR decimal(28,12), QUANT decimal(28,12), VALOR1 decimal(28,12), VALOR2 decimal(28,12), VALOR3 decimal(28,12), VALOR4 decimal(28,12), VALOR5 decimal(28,12), MOEDA decimal(28,12), DTCONV    char(8), TX1 decimal(28,12), TX2 decimal(28,12), TX3 decimal(28,12), TX4 decimal(28,12), TX5 decimal(28,12) )' )
		elseif Alltrim(Upper(TcGetDb()))=="DB2"
			TCSqlExec('CREATE TABLE '+cTmp1+' ( TAREFA varchar('+ltrim(str(TamSX3("AF2_TAREFA")[1]))+'), VALOR decimal (28,12), QUANT decimal(28,12), VALOR1 decimal(28,12), VALOR2 decimal(28,12), VALOR3 decimal(28,12), VALOR4 decimal(28,12), VALOR5 decimal(28,12), MOEDA decimal(28,12), DTCONV varchar(8), TX1 double, TX2 double, TX3 double, TX4 double, TX5 double )' )
		else
			TCSqlExec('CREATE TABLE '+cTmp1+' ( TAREFA varchar('+ltrim(str(TamSX3("AF2_TAREFA")[1]))+'), VALOR numeric(28,12), QUANT numeric(28,12), VALOR1 numeric(28,12), VALOR2 numeric(28,12), VALOR3 numeric(28,12), VALOR4 numeric(28,12), VALOR5 numeric(28,12), MOEDA numeric(28,12), DTCONV varchar(8), TX1 numeric(28,12), TX2 numeric(28,12), TX3 numeric(28,12), TX4 numeric(28,12), TX5 numeric(28,12) )' )
		endif

		if Alltrim(Upper(TcGetDb()))=="INFORMIX"
  			If cPaisLoc == "BOL"
				TCSqlExec('CREATE TABLE '+cTmp2+' ( TAREFA2    char('+ltrim(str(TamSX3("AF2_TAREFA")[1]))+'), EDTPAI    char('+ltrim(str(TamSX3("AF2_EDTPAI")[1]))+'), BDI decimal(28,12), FLAG integer, UTIBDI    char('+ltrim(str(TamSX3("AF2_UTIBDI")[1]))+'), IT decimal(28,12), VALIT decimal(28,12), UTIL decimal(28,12), VALUTI decimal(28,12))' )
			Else
				TCSqlExec('CREATE TABLE '+cTmp2+' ( TAREFA2    char('+ltrim(str(TamSX3("AF2_TAREFA")[1]))+'), EDTPAI    char('+ltrim(str(TamSX3("AF2_EDTPAI")[1]))+'), BDI decimal(28,12), FLAG integer, UTIBDI    char('+ltrim(str(TamSX3("AF2_UTIBDI")[1]))+') )' )			
			EndIf
		else
			If cPaisLoc == "BOL"
				TCSqlExec('CREATE TABLE '+cTmp2+' ( TAREFA2 varchar('+ltrim(str(TamSX3("AF2_TAREFA")[1]))+'), EDTPAI varchar('+ltrim(str(TamSX3("AF2_EDTPAI")[1]))+'), BDI numeric(28,12), FLAG integer, UTIBDI varchar('+ltrim(str(TamSX3("AF2_UTIBDI")[1]))+'),IT decimal(28,12), VALIT numeric(28,12), UTIL decimal(28,12),VALUTI numeric(28,12))' )
			Else
				TCSqlExec('CREATE TABLE '+cTmp2+' ( TAREFA2 varchar('+ltrim(str(TamSX3("AF2_TAREFA")[1]))+'), EDTPAI varchar('+ltrim(str(TamSX3("AF2_EDTPAI")[1]))+'), BDI numeric(28,12), FLAG integer, UTIBDI varchar('+ltrim(str(TamSX3("AF2_UTIBDI")[1]))+') )' )			
			EndIf
		endif
		
		if !lBlock // Se não tiver ponto de entrada, calcula também as EDT's
			Pms100Exec(AF2->(xFilial()), cOrcamento, cPmsCust, DTOS(dDataBase), aDecCst, 1, 1, cTmp1, cTmp2, cProc)
		else
			// Atualiza tarefas
			Pms100Exec(AF2->(xFilial()), cOrcamento, cPmsCust, DTOS(dDataBase), aDecCst, 1, 0, cTmp1, cTmp2, cProc)

			AF2->(MsSeek(xFilial()+cOrcamento,.T.))
 			do while AF2->AF2_ORCAME=cOrcamento .and. !AF2->(Eof())
				// ponto de entrada para que o cliente customizar o calculo do custo da tarefa
				nRecAF2 := AF2->( Recno() )
				ExecBlock("PMSXCust") // calcula o custo   
				AF2->( dbgoto( nRecAF2 ) )
				
				AF2->(DbSkip())
			enddo
			
			// Atualiza EDT's
			Pms100Exec(AF2->(xFilial()), cOrcamento, cPmsCust, DTOS(dDataBase), aDecCst, 0, 1, cTmp1, cTmp2, cProc)
		endif
		
		MsErase(cTmp1,,"TOPCONN")
		MsErase(cTmp2,,"TOPCONN")
		
		if TcSqlExec('DROP PROCEDURE '+cProc)<>0
			if !__lBlind
				MsgAlert(STR0113+" "+cProc+": "+TCSqlError())   //'Erro excluindo procedure'
			endif
		endif
		
	else
		nProcRegua:=0

		dbSelectArea("AF2")
		dbSetOrder(1)
		dbSeek(xFilial()+cOrcamento)
		nRec:=AF2->(RecNo())
		While !Eof() .And. xFilial()+cOrcamento == AF2_FILIAL+AF2_ORCAME
			nProcRegua++ 
			dbSkip()
		End
		nProcRegua--
		
		dbSelectArea("AF5")
		dbSetOrder(1)
		dbSeek(xFilial()+cOrcamento)
		nRec:=AF5->(RecNo())
		While !Eof() .And. xFilial()+cOrcamento == AF5_FILIAL+AF5_ORCAME
			nProcRegua++ 
			dbSkip()
		End
		nProcRegua--

		ProcRegua(nProcRegua)
	
		AAdd( aStruct, { "TRB_NIVEL", "C", Len( AF5->AF5_NIVEL ), 0 } )
		AAdd( aStruct, { "TRB_EDT"  , "C", Len( AF5->AF5_EDT ), 0 } )
		AAdd( aStruct, { "TRB_RECNO", "N", 10, 0 } )
	
		If _oPMS100Au <> Nil
			_oPMS100Au:Delete()
			_oPMS100Au := Nil
		Endif
				
		_oPMS100Au := FWTemporaryTable():New( "TRAB" )  
		_oPMS100Au:SetFields(aStruct) 
		_oPMS100Au:AddIndex("1", {"TRB_NIVEL","TRB_EDT"})
		
		//------------------
		//Criação da tabela temporaria
		//------------------
		_oPMS100Au:Create()  

		TRAB->(DbSetOrder(1))
	
		AF5->(dbSetOrder(3))
		AF5->(MsSeek(xFilial()+cOrcamento,.T.))
		do while AF5->AF5_FILIAL=xFilial("AF5") .and. AF5->AF5_ORCAME=cOrcamento .and. !AF5->(Eof())
			TRAB->(RecLock("TRAB",.T.))
			TRAB->TRB_NIVEL:= AF5->AF5_NIVEL
			TRAB->TRB_EDT  := AF5->AF5_EDT
			TRAB->TRB_RECNO:= AF5->(Recno())
			TRAB->(MsUnLock())
			AF5->(DbSkip())
		enddo
		
		AF2->(dbSetOrder(1))
		AF3->(dbSetOrder(1))
		AF4->(dbSetOrder(1))
		
		AF2->(MsSeek(xFilial("AF2")+cOrcamento,.T.))
		AF3->(MsSeek(xFilial("AF3")+AF2->AF2_ORCAME+AF2->AF2_TAREFA,.T.))
		AF4->(MsSeek(xFilial("AF4")+AF2->AF2_ORCAME+AF2->AF2_TAREFA,.T.))
		do while AF2->AF2_FILIAL=xFilial("AF2") .and. AF2->AF2_ORCAME=cOrcamento .and. !AF2->(Eof())
			aTX2M[1]:=1
			aTX2M[2]:=AF2->AF2_TXMO2
			aTX2M[3]:=AF2->AF2_TXMO3
			aTX2M[4]:=AF2->AF2_TXMO4
			aTX2M[5]:=AF2->AF2_TXMO5
			
			nQuantTrf:=AF2->AF2_QUANT
			
			aCustoAF2[1]:=0; aCustoAF2[2]:=0; aCustoAF2[3]:=0; aCustoAF2[4]:=0; aCustoAF2[5]:=0
			
            // Pula tarefas que não existem
			do while AF3->AF3_ORCAME=AF2->AF2_ORCAME .and. AF3->AF3_TAREFA<AF2->AF2_TAREFA .and. !AF3->(Eof())
				AF3->(DbSkip())
			enddo
			// Recursos
			do while AF3->AF3_ORCAME=AF2->AF2_ORCAME .and. AF3->AF3_TAREFA=AF2->AF2_TAREFA .and. !AF3->(Eof())
				nCusto:=AF3->AF3_CUSTD*AF3->AF3_QUANT
				nMoeda:=AF3->AF3_MOEDA
				
				aVal[1] := if(aTX2M[1]==0, xMoeda(nCusto,nMoeda,1,dDtConv,aDecCst[1]), xMoeda(nCusto,nMoeda,1,,aDecCst[1],aTX2M[nMoeda],aTX2M[1]))
				aVal[2] := if(aTX2M[2]==0, xMoeda(nCusto,nMoeda,2,dDtConv,aDecCst[2]), xMoeda(nCusto,nMoeda,2,,aDecCst[2],aTX2M[nMoeda],aTX2M[2]))
				aVal[3] := if(aTX2M[3]==0, xMoeda(nCusto,nMoeda,3,dDtConv,aDecCst[3]), xMoeda(nCusto,nMoeda,3,,aDecCst[3],aTX2M[nMoeda],aTX2M[3]))
				aVal[4] := if(aTX2M[4]==0, xMoeda(nCusto,nMoeda,4,dDtConv,aDecCst[4]), xMoeda(nCusto,nMoeda,4,,aDecCst[4],aTX2M[nMoeda],aTX2M[4]))
				aVal[5] := if(aTX2M[5]==0, xMoeda(nCusto,nMoeda,5,dDtConv,aDecCst[5]), xMoeda(nCusto,nMoeda,5,,aDecCst[5],aTX2M[nMoeda],aTX2M[5]))
				
				PMS_TRUNCA aVal[1], aVal[2], aVal[3], aVal[4], aVal[5], aDecCst[1], aDecCst[2], aDecCst[3], aDecCst[4], aDecCst[5], nQuantTrf, cTrunca, lTotal TO aCustoAF2[1], aCustoAF2[2], aCustoAF2[3], aCustoAF2[4], aCustoAF2[5]
				
				AF3->(DbSkip())
			enddo
            // Pula tarefas que não existem
			do while AF4->AF4_ORCAME=AF2->AF2_ORCAME .and. AF4->AF4_TAREFA<AF2->AF2_TAREFA .and. !AF4->(Eof())
				AF4->(DbSkip())
			enddo
			// Tarefas
			do while AF4->AF4_ORCAME=AF2->AF2_ORCAME .and. AF4->AF4_TAREFA=AF2->AF2_TAREFA .and. !AF4->(Eof())
				nCusto:=AF4->AF4_VALOR
				nMoeda:=AF4->AF4_MOEDA
				
				aVal[1] := if(aTX2M[1]==0, xMoeda(nCusto,nMoeda,1,dDtConv,aDecCst[1]), xMoeda(nCusto,nMoeda,1,,aDecCst[1],aTX2M[nMoeda],aTX2M[1]))
				aVal[2] := if(aTX2M[2]==0, xMoeda(nCusto,nMoeda,2,dDtConv,aDecCst[2]), xMoeda(nCusto,nMoeda,2,,aDecCst[2],aTX2M[nMoeda],aTX2M[2]))
				aVal[3] := if(aTX2M[3]==0, xMoeda(nCusto,nMoeda,3,dDtConv,aDecCst[3]), xMoeda(nCusto,nMoeda,3,,aDecCst[3],aTX2M[nMoeda],aTX2M[3]))
				aVal[4] := if(aTX2M[4]==0, xMoeda(nCusto,nMoeda,4,dDtConv,aDecCst[4]), xMoeda(nCusto,nMoeda,4,,aDecCst[4],aTX2M[nMoeda],aTX2M[4]))
				aVal[5] := if(aTX2M[5]==0, xMoeda(nCusto,nMoeda,5,dDtConv,aDecCst[5]), xMoeda(nCusto,nMoeda,5,,aDecCst[5],aTX2M[nMoeda],aTX2M[5]))
				
				PMS_TRUNCA aVal[1], aVal[2], aVal[3], aVal[4], aVal[5], aDecCst[1], aDecCst[2], aDecCst[3], aDecCst[4], aDecCst[5], nQuantTrf, cTrunca, lTotal TO aCustoAF2[1], aCustoAF2[2], aCustoAF2[3], aCustoAF2[4], aCustoAF2[5]
				
				AF4->(DbSkip())
			enddo

			AF2->(RecLock("AF2",.F.))
			AF2->AF2_CUSTO := aCustoAF2[1]
			AF2->AF2_CUSTO2:= aCustoAF2[2]
			AF2->AF2_CUSTO3:= aCustoAF2[3]
			AF2->AF2_CUSTO4:= aCustoAF2[4]
			AF2->AF2_CUSTO5:= aCustoAF2[5]	

			If AF2->(FieldPos("AF2_VALIT")) > 0 .And. AF2->(FieldPos("AF2_VALUTI")) > 0
				AF2->AF2_VALIT  := (aCustoAF2[1]*AF2->AF2_IT)/100
				AF2->AF2_VALUTI := (aCustoAF2[1]*AF2->AF2_UTIL)/100      
			EndIf
			
			AF2->AF2_VALBDI:= aCustoAF2[1]*iif(AF2->AF2_BDI<>0,AF2->AF2_BDI,PmsGetBDIPad('AF5',AF2->AF2_ORCAME,,AF2->AF2_EDTPAI, AF2->AF2_UTIBDI ))/100
			AF2->AF2_TOTAL := aCustoAF2[1]+AF2->AF2_VALBDI+IIf(cPaisLoc == "BOL",AF2->AF2_VALIT,0)+IIf(cPaisLoc == "BOL",AF2->AF2_VALUTI,0)
			AF2->(MsUnLock())

			// ponto de entrada para que o cliente possa customizar o calculo do custo da tarefa
			if lBlock
				nRecAF2 := AF2->( Recno() )
				ExecBlock("PMAF2CST") // calcula o custo   
				AF2->( dbgoto( nRecAF2 ) )
			endif
			
			AF2->(DbSkip())
			
			IncProc()
		enddo
		
		AF5->(DbSetOrder(2))
		AF2->(DbSetOrder(2))
		TRAB->(DbGoTop())
		do while !TRAB->(Eof())
			n1:=n2:=n3:=n4:=n5:=n6:=n7:=n8:=0
			
			if AF5->(MsSeek(xFilial("AF5") + cOrcamento + TRAB->TRB_EDT))
				do while !AF5->(Eof()) .And. (xFilial("AF5") + cOrcamento + TRAB->TRB_EDT == AF5->AF5_FILIAL + AF5->AF5_ORCAME + AF5->AF5_EDTPAI)
					n1 += AF5->AF5_CUSTO
					n2 += AF5->AF5_CUSTO2
					n3 += AF5->AF5_CUSTO3
					n4 += AF5->AF5_CUSTO4
					n5 += AF5->AF5_CUSTO5
					n6 += AF5->AF5_VALBDI
					AF5->(DbSkip())
				enddo
			endif
			
			if AF2->(MsSeek(xFilial("AF2") + cOrcamento + TRAB->TRB_EDT))
				do while !AF2->(Eof()) .And. (xFilial("AF2") + cOrcamento + TRAB->TRB_EDT == AF2->AF2_FILIAL + AF2->AF2_ORCAME + AF2->AF2_EDTPAI)
					n1 += AF2->AF2_CUSTO
					n2 += AF2->AF2_CUSTO2
					n3 += AF2->AF2_CUSTO3
					n4 += AF2->AF2_CUSTO4
					n5 += AF2->AF2_CUSTO5
					n6 += AF2->AF2_VALBDI
					
					If cPaisLoc == "BOL"
						n7 += AF2->AF2_VALTI
					EndIf
					
					If cPaisLoc == "BOL"
						n8 += AF2->AF2_VALUTI
					EndIf					
					
					AF2->(DbSkip())
				enddo
			endif
			
			AF5->(DbGoto(TRAB->TRB_RECNO))
			RecLock("AF5",.F.)
			AF5->AF5_CUSTO	:= n1
			AF5->AF5_CUSTO2	:= n2
			AF5->AF5_CUSTO3	:= n3
			AF5->AF5_CUSTO4	:= n4
			AF5->AF5_CUSTO5	:= n5
			AF5->AF5_VALBDI	:= n6
			
			If cPaisLoc == "BOL"
				AF5->AF5_VALIT := n7			
			EndIf  
			
			If cPaisLoc == "BOL"
				AF5->AF5_VALUTI:= n8			
			EndIf
			
			AF5->AF5_TOTAL := n1+n6+n7+n8
			AF5->(MsUnlock())
			
			TRAB->(DbSkip())

			IncProc()
		enddo
		
		TRAB->(DbCloseArea())

		If _oPMS100Au <> Nil
			_oPMS100Au:Delete()
			_oPMS100Au := Nil
		Endif
		
	endif
endif
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS100ChangeEDT  ³ Autor ³ Fabio Rogerio Pereira  ³ Data ³ 17/10/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Realiza a troca da EDTPai da EDT/Tarefa selecionada.			        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                         			            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMS100ChangeEDT(oTree,cArquivo)
Local cAlias  := ""
Local cNivel  := ""
Local cEDTPai := ""
Local cEDTAnt := ""
Local nRecno  := 0
Local aEDT    := {}
Local aArea   := GetArea()
Local lRet    := .F.
Local cOldCode := ""

Local cEDTOrig := ""
Local cEDTDest := ""
Local cOrcamento := ""

// verifica o alias e recno do item selecionado
If oTree != Nil
	cAlias:= SubStr(oTree:GetCargo(),1,3)
	nRecno:= Val(SubStr(oTree:GetCargo(),4,12))
Else
	cAlias := (cArquivo)->ALIAS
	nRecNo := (cArquivo)->RECNO
EndIf

// somente permite a alteracao da EDT Pai de EDT's e Tarefas
If !(cAlias $ "AF2/AF5")
	Return(.F.)
EndIf

// valida o nivel e a data de inicializacao real da EDT/Tarefa selecionada.
// nao permite a troca da EDT principal e tambem de itens que ja foram
// iniciados.
dbSelectArea(cAlias)
dbGoTo(nRecNo)
If &(cAlias + "->"+cAlias+"_NIVEL") == "001"
	Return(.F.)
EndIf

If cAlias == "AF5"
	cOrcamento := AF5->AF5_ORCAME
	cEDTOrig   := AF5->AF5_EDT
Else
	cOrcamento := AF2->AF2_ORCAME
	cEDTOrig   := AF2->AF2_EDTPAI
EndIf	

// exibe uma tela de selecao dos projetos para importacao
aEDT := 	PmsSelTsk(STR0073,"AF1/AF5/AF2","AF5",STR0047,"AF1",AF1->AF1_ORCAME,.F.,.F.) //"Selecione a nova EDT" //"Selecao Invalida"

If (Len(aEDT) > 0)
	lRet:= .T.
    
	AF5->(dbGoTo(aEDT[2]))
	cEDTPai:= AF5->AF5_EDT
	cNivel := StrZero(Val(AF5->AF5_NIVEL) + 1, TamSX3("AF5_NIVEL")[1])

	Do Case
		Case cAlias == "AF2"
			dbSelectArea("AF2")
			dbGoTo(nRecNo)
			RecLock("AF2",.F.)
			
			cEDTAnt:= AF2->AF2_EDTPAI
			If GetMV("MV_PMSTCOD") == "2"		
				cOldCode := AF2->AF2_TAREFA			
				AF2->AF2_TAREFA := PMSNumAF2(AF2->AF2_ORCAME,;
				                             PMSGetNivOrc(AF2->AF2_ORCAME,cEDTPai),;
				                             cEDTPai)
			EndIf			
			Replace AF2->AF2_EDTPAI With cEDTPai
			Replace AF2->AF2_NIVEL  With cNivel
			MsUnLock() 
			
			If GetMV("MV_PMSTCOD") == "2"			
				AF2AtuCode(AF2->AF2_FILIAL, AF2->AF2_ORCAME, cOldCode, AF2->AF2_TAREFA)
			EndIf
						
			// executa o recalculo do custo das tarefas e edt
			PmsAF2CusEDT(AF2->AF2_ORCAME,cEDTAnt)
			
			// executa o recalculo do custo das tarefas e edt
			PmsAF2CusEDT(AF5->AF5_ORCAME,AF5->AF5_EDT)
			
		Case cAlias == "AF5"
			// Verifica se a operação de troca de EDT
			// não causa uma referência circular
			If !PMSAF5CheckRef(cOrcamento, cEDTOrig, cEDTPai)
				dbSelectArea("AF5")
				dbGoTo(nRecNo)
				RecLock("AF5",.F.)
				cEDTAnt:= AF5->AF5_EDT
	
				// altera o codigo da EDT se o modo de codigo for automatico
				If GetMV("MV_PMSTCOD") == "2"
					cOldCode := AF5->AF5_EDT			
					AF5->AF5_EDT := PMSNumAF5(AF5->AF5_ORCAME,;
					                          PMSGetNivOrc(AF5->AF5_ORCAME, cEDTPai),;
					                          cEDTPai)
				EndIf
				Replace AF5->AF5_EDTPAI With cEDTPai
				Replace AF5->AF5_NIVEL  With cNivel
				MsUnLock()
				
				// recodificar as tarefas se o modo de codigo for automatico
				If GetMV("MV_PMSTCOD") == "2"			
					PMSAF5Cod(AF5->AF5_ORCAME, AF5->AF5_EDT, cEDTAnt)
				EndIf     
				
				If GetMV("MV_PMSTCOD") == "2"			
					AF5RecRelTables(AF5->AF5_FILIAL, AF5->AF5_ORCAME, cOldCode, AF5->AF5_EDT)
				EndIf
				
				// recalcular os niveis abaixo dela
				PMSAF5Nivel(AF5->AF5_ORCAME, cEdtAnt, AF5->AF5_NIVEL)

				// executa o recalculo do custo das tarefas e edt
				PmsAF2CusEDT(AF5->AF5_ORCAME,AF5->AF5_EDT)
			Else
				Aviso(STR0082,;
				      STR0083,;
				      { "Ok" }, 2)  //"Troca nao efetuada"##"Esta operacao de troca de EDT pai nao pode ser realizada pois causa uma referencia circular."
			
				lRet := .F.
			EndIf
	EndCase
	
EndIf

RestArea(aArea)
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A100Opn ³ Autor ³ Adriano Ueda           ³ Data ³ 04-05-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Abre o arquivo de configuracoes, se nao encontrar cria o arq. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A100Opn(aCampos,cArquivo,cMV1,cMV2)
Local cCampos
Local aCampos2	:= {}
Local aFile     := {}
Local nTamFilial:= IIf( lFWCodFil, FWGETTAMFILIAL, 2 )
Local aAuxCampos:= aClone(aCampos)

DEFAULT cArquivo := "\PROFILE\PMSA100"
DEFAULT cMV1 := "MV_PMSPLNA"
DEFAULT cMV2 := "MV_PMSPLNB"

If !File(cArquivo + PMS_SHEET_EXT)
		
	cCampos := Alltrim(GetMv(cMV1))
	cCampos += Alltrim(GetMv(cMV2))
	cCmpPln	:= cCampos	
	While !Empty(AllTrim(cCampos))
		If AT("#",cCampos) > 0
			cAux := Substr(cCampos,1,AT("#",cCampos)-1)
			aAdd(aCampos,{"AF2"+cAux,"AF5"+cAux,,,,.F.,"",})
			aAdd(aCampos2,{,Substr(cAux,2,Len(cAux)-1)})
		    cCampos := Substr(cCampos,AT("#",cCampos)+1,Len(cCampos)-AT("#",cCampos))
		 Else
		 	cCampos := ''
		 EndIf
	End
	GravaOrc(aCampos2, {}, cArquivo, 1)	
	cArqPLN	:= AllTrim(cArquivo + PMS_SHEET_EXT)	

Else

	If ReadSheetFile(AllTrim(cArquivo + PMS_SHEET_EXT), aFile)

		// {versao, campos, senha, descricao, freeze, indent}
		cPLNVer    := aFile[1]
		cArqPLN    := AllTrim(cArquivo + PMS_SHEET_EXT)
		cCmpPLN    := aFile[2]
		cPLNSenha  := aFile[3]
		cPLNDescri := aFile[4]
		nFreeze    := aFile[5]
		nIndent    := aFile[6]
		lSenha := !Empty(aFile[3])		

		If lSenha
			cCmpPLN    := Embaralha(cCmpPLN, 0)
			cPLNDescri := Embaralha(cPLNDescri, 0)
		EndIf

		C050ChkPln(@aCampos)
	Else
		Aviso(STR0077, STR0078,{"Ok"},2) //"Falha na Abertura."###"Erro na abertura do arquivo. Verifique a existencia do arquivo selecionado."
	EndIf
	If AllTrim(cPLNVer) != "001" .And. AllTrim(cPLNVer) != "002"
		Aviso(STR0079, STR0080 + STR0115,{"Ok"},2 )  //"Falha no Arquivo."###"Estrutura do arquivo incompativel.""###"Será gerado novo arquivo com estrutura em sua configuração básica."
		aCampos := aAuxCampos
		Ferase(AllTrim(cArquivo + PMS_SHEET_EXT))
		A100Opn(@aCampos,cArquivo)
	EndIf
EndIf        

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS100ReC³ Autor ³ Reynaldo Miyashita     ³ Data ³ 06.12.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Refaz todo calculo o custo do orcamento.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS100ReCalc()

	If AF1->AF1_RECALC != "1"
		RecLock("AF1",.F.)
			AF1->AF1_RECALC := "1"
		MsUnlock()
	EndIf
		
	If AF1->AF1_RECALC=="1"

		// verifica a existencia do ponto de entrada PMS100A2 do Template - Recalculo dos encargos
		If ExistTemplate("PMS100A2")
			ExecTemplate("PMS100A2",.F.,.F.)
		EndIf
	
		If HasTemplate("CCT") .And. ;
		   GetMv("MV_PMSCUST") == "2" .And. ;
		   GetNewPar("MV_CCTUNIT", "1")	== "2" //.And. ;
		   //GetNewPar("MV_CCTBDIU", "1") == "2"

			MsgRun(STR0105, STR0106, ;
			       {|| T_CctNwBuCost(AF1->AF1_ORCAME) })
			       
			//"Recalculando o orçamento..."
			//"Aguarde"
		Else
	
			// atualiza os custos das tarefas e das edts
			Processa({||Pms100AuxEDT()},STR0032) //"Atualizando Custos da EDT. Aguarde..."
		EndIf

			RecLock("AF1",.F.)
				AF1->AF1_RECALC := "2"
			MsUnlock()
	
	EndIf
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSAF5Che³ Autor ³ Adriano Ueda           ³ Data ³ 20/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se é a partir da EDT destino é possível             ³±±
±±³          ³ chegar a EDT de origem, ou seja, ela percorre a              ³±±
±±³          ³ a árvore na ordem inversa, até chegar na EDT                 ³±±
±±³          ³ principal ou encontrar a EDT origem.                         ³±±
±±³          ³                                                              ³±±
±±³          ³ Assume que a EDT origem e a EDT destino pertencem ao mesmo   ³±±
±±³          ³ orçamento.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrcamento - código do orçamento no qual será checada        ³±±
±±³          ³ a referência.                                                ³±±
±±³          ³                                                              ³±±
±±³          ³ cEDTOrigem - a EDT a ser verificada (como a árvore é         ³±±
±±³          ³ percorrida do nó folha até o raiz, este é o possível ponto   ³±±
±±³          ³ de término).                                                 ³±±
±±³          ³                                                              ³±±
±±³          ³ cEDTDestino - a EDT inicial, onde começará a ser verificada  ³±±
±±³          ³ a árvore. Como a função é recursiva, poderá ser igual ao     ³±±
±±³          ³ código do orçamento.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ - Retorna .T. se a EDT origem é igual a EDT destino ou a EDT ³±±
±±³          ³ destino não for encontrada na base de dados.                 ³±±
±±³          ³ - Retorna .F. se a EDT destino não foi encontrada percorrendo³±±
±±³          ³ a árvore na ordem inversa ou, ainda, se a EDT destino for    ³±±
±±³          ³ igual ao código do orçamento.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSAF5CheckRef(cOrcamento, cEDTOrig, cEDTDest)
Local aArea    := GetArea()
Local aAreaAF5 := AF5->(GetArea())
Local cEDTProx := ""
Local lRet     := .T.   

	// a EDT origem e EDT destino não podem
	// ser a mesma
	If cEDTOrig  == cEDTDest
		lRet := .T.	
	Else
		// se a EDT destino for igual o orçamento
		// a EDT origem não foi encontrada
		If AllTrim(cEDTDest) == AllTrim(cOrcamento)
			lRet := .F.
		Else
			AF5->(dbSetOrder(1)) 	// AF5_FILIAL + AF5_ORCAME + AF5_EDT
			If AF5->(MsSeek(xFilial("AF5") + cOrcamento + cEDTDest))
				cEDTProx := AF5->AF5_EDTPAI
				lRet := PMSAF5CheckRef(cOrcamento, cEDTOrig, cEDTProx) 	
			EndIf
		
		EndIf
	EndIf
	RestArea(aAreaAF5)
	RestArea(aArea)
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pms100Usr ³ Autor ³Edson Maricate              ³ Data ³ 26-12-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de configuracao dos usuarios do Projeto.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pms100Usr(cAlias,nReg,nOpcx)
Local oDlg
Local oMenu
Local oTree
Local cArquivo
Local lFWGetVersao := .T.

Local nScreVal1 := 775 // variaveis para posicionamento do popup menu
Local nScreVal2 := 23  // variaveis para posicionamento do popup menu
Local aScreens := {}   // variaveis para posicionamento do popup menu
//Incluido variaveis para posicionamento do Popup Menu, pois na russia o mesmo deverá ficar posicioando abaixo do menu a direita
If cPaisLoc == 'RUS'
	//Valores para a Russia, posicionado a direita
	//Change popup menu localization, using the screen resolution to position on right
	aScreens := getScreenRes()
	nScreVal1 := aScreens[1]-245
	nScreVal2 := 53
EndIf
	If PmsOrcUser(AF1->AF1_ORCAME,,Padr(AF1->AF1_ORCAME,Len(AF5->AF5_EDT)),"  ",3,"ESTRUT")
		
		MENU oMenu POPUP
			MENUITEM STR0089 ACTION (PmsUsrDlg(@oTree,nOpcx,1,cArquivo),Eval(bRefresh))  //"Incluir Usuario"
			MENUITEM STR0090 ACTION PmsUsrDlg(@oTree,nOpcx,2,cArquivo) //"Alterar Propriedades"
			MENUITEM STR0091 ACTION (PmsUsrDlg(@oTree,nOpcx,3,cArquivo),Eval(bRefresh))  //"Excluir Usuario"
		ENDMENU
		
		If !lFWGetVersao .or. GetVersao(.F.) == "P10"
			aMenu := {;
			         {TIP_ORC_INFO,      {||PmsOrcInf()}, BMP_ORC_INFO, TOOL_ORC_INFO},;
			         {TIP_PROJ_USUARIOS, {||Pms100UMenu(@oMenu,@oTree,nOpcx,cArquivo),oMenu:Activate(100,45,oDlg) }, BMP_PROJ_USUARIOS, TOOL_PROJ_USUARIOS}}
		Else			
			//Acoes relacionadas
			aMenu := {;
					{TIP_ORC_INFO,      {||PmsOrcInf()}, BMP_ORC_INFO, TOOL_ORC_INFO},;
					{TIP_PROJ_USUARIOS, {||Pms100UMenu(@oMenu,@oTree,nOpcx,cArquivo),oMenu:Activate(nScreVal1,nScreVal2,oDlg) }, BMP_PROJ_USUARIOS, TOOL_PROJ_USUARIOS}}
		Endif
		PmsDlgAF1(cCadastro,@oMenu,@oTree,"AF5/AF2/USR",{||Pms100UMenu(@oMenu,@oTree,nOpcx,cArquivo)},,aMenu,@oDlg)
	Else
		Aviso(STR0087,STR0088,{STR0053},2) //"Usuário sem permissão"###"Usuário sem permissão para alteração nos usuários do orçamento. Verifique as permissões do usuário na estrutura principal do orçamento."###"Fechar"
	EndIf
	                              
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PmsUsrCtrMenu³ Autor ³Edson Maricate       ³ Data ³ 29-12-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que controla as propriedades do Menu PopUp.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pms100UMenu(oMenu,oTree,nOpcx)
Local aArea		:= GetArea()
Local cAlias	:= SubStr(oTree:GetCargo(),1,3)
Local nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))

dbSelectArea(cAlias)
dbGoto(nRecView)


// se for visualizacao desabilita as opcoes.³
If (aRotina[nOpcx,4] == 2)
	oMenu:aItems[1]:Disable()
	oMenu:aItems[2]:Disable()
	oMenu:aItems[3]:Disable()
Else
	Do Case 
		Case cAlias == "AF1"
			oMenu:aItems[1]:Disable()
			oMenu:aItems[2]:Disable()
			oMenu:aItems[3]:Disable()
		Case cAlias == "AF5"
			oMenu:aItems[1]:Enable()
			oMenu:aItems[2]:Disable()
			oMenu:aItems[3]:Disable()
		Case cAlias == "AF2"
			oMenu:aItems[1]:Enable()
			oMenu:aItems[2]:Disable()
			oMenu:aItems[3]:Disable()
		OtherWise
			oMenu:aItems[1]:Disable()
			oMenu:aItems[2]:Enable()
			oMenu:aItems[3]:Enable()
	EndCase
EndIf
	
RestArea(aArea)
Return             

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSUsrDlg   ³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Inclusao,Alteracao,Visualizacao e Exclusao        ³±±
±±³          ³dos Usuarios do Projeto                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMSUsrDlg(oTree,nOpcx,nMenuItem)

Local aArea		:= GetArea()
Local cAlias	:= SubStr(oTree:GetCargo(),1,3)
Local nReg		:= Val(SubStr(oTree:GetCargo(),4,12))
Local oDlg
Local oEnchoice
Local nRecAJF
Local nOpc2		:= 2
Local lInclui	:= .F.
Local lVisual	:= .F.
Local lAltera	:= .F.
Local lExclui	:= .F.
Local lContinua	:= .T.
Local lOk		:= .F.

// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
Do Case

	// Inclusao
	Case nMenuItem == 1
		lInclui	:= .T.
		Inclui	:= .T.
		Altera	:= .F.
		nOpc2		:= 3

	// Alteracao
	Case nMenuItem == 2
		lAltera	:= .T.
		Altera	:= .T.
		Inclui  := .F.
		nOpc2		:= 4

	// Exclusao
	Case nMenuItem == 3
		lExclui	:= .T.
		lVisual	:= .T.
		nOpc2		:= 5
EndCase

dbSelectArea(cAlias)
dbGoto(nReg)
If cAlias=="AF5"
	cAlias := "AJF"
EndIf
If cAlias=="AF2"
	cAlias := "AJG"
EndIf
RegToMemory(cAlias,lInclui)

If !lInclui
	If !SoftLock(cAlias)
		lContinua := .F.
	Else
		nRecAJF := (cAlias)->(RecNo())
	Endif
EndIf

If lContinua
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 8,0 TO 29,78 OF oMainWnd
		oEnchoice := MsMGet():New(cAlias,nReg,nOpc2,,,,,{16,1,158,307},,3,,,,oDlg,,,)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(Obrigatorio(oEnchoice:aGets,oEnchoice:aTela),(lOk:=.T.,oDlg:End()),Nil)},{|| oDlg:End()}) CENTERED
EndIf

Begin Transaction
	If (lInclui.Or.lAltera.Or.lExclui).And. lOk
		If lContinua
			PMSUsrGrv(cAlias,lExclui,nRecAJF)
		EndIf
	EndIf
End Transaction

RestArea(aArea)
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSUsrGrv   ³ Autor ³ Edson Maricate      ³ Data ³ 29-12-2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de gravacao dos usuarios do Projeto                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMSUsrGrv(cAlias,lDeleta,nRecAJF)
Local nx
Local bCampo 	:= {|n| FieldName(n) }
Local aArea		:= GetArea()

If !lDeleta
	If nRecAJF <> Nil
		(cAlias)->(dbGoto(nRecAJF))
		RecLock(cAlias,.F.)
	Else
		RecLock(cAlias,.T.)
	EndIf
	For nx := 1 TO FCount()
		FieldPut(nx,M->&(EVAL(bCampo,nx)))
	Next nx
	FieldPut(FieldPos(cAlias+"_FILIAL"),xFilial(cAlias))
	dbCommit()
	MsUnlock()
Else
	(cAlias)->(dbGoto(nRecAJF))
	RecLock(cAlias,.F.,.T.)
	dbDelete()
	MsUnlock()
EndIf

RestArea(aArea)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RecodeOrc      ³ Autor ³Adriano Ueda          ³ Data ³ 26/01/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que gera um novo codigo para EDT/TAREFA do orçamento.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RecodeOrc(oTree, cArquivo)
	Local lReturn  := .F.
	Local lContinua:= .T.
	Local cAlias   := ""
	Local nRecno   := 0
	Local lOk      := .F.     
	Local lEdtPai  := .F.
	Local cNivel   := ""
	Local cGetPict := ""

	Local cOldCode := ""
	Local cNewCode := ""

	Local cOrcame := ""
	Local cEDT     := ""
		
	Local oDlg     := Nil
	Local oGet     := Nil
	Local oNewCode := ""

	If oTree != Nil
		cAlias := SubStr(oTree:GetCargo(), 1, 3)
		nRecno := Val(SubStr(oTree:GetCargo(), 4, 12))
	Else
		cAlias := (cArquivo)->ALIAS
		nRecNo := (cArquivo)->RECNO
	EndIf

	Do Case
		Case cAlias == "AF5"
			dbSelectArea("AF5")
			dbGoTo(nRecNo)

			cOldCode := AF5->AF5_EDT
			cNewCode := Space(TamSX3("AF5_EDT")[1])
			
			cNivelAF5 := If(cAlias == "AF5", AF5->AF5_NIVEL, "000")
			
			cGetPict := ""//X3Picture("AF5_EDT")
			
			cOrcame := AF5->AF5_ORCAME
			
			// se for a EDT Principal do Orçamento
			If Padr(AF5->AF5_ORCAME, TamSX3("AF5_EDT")[1]) == AF5->AF5_EDT .And.;
			   Empty(AF5->AF5_EDTPAI) .And.;
				 AF5->AF5_NIVEL == StrZero(1, TamSX3("AF5_NIVEL")[1])
				lEdtPai := .T.
			EndIf
			
		Case cAlias == "AF2"
			dbSelectArea("AF2")
			dbGoTo(nRecNo)
			
			cOldCode := AF2->AF2_TAREFA
			cNewCode := Space(TamSX3("AF2_TAREFA")[1])
			
			cGetPict := "" //X3Picture("AF2_TAREFA")
			
			cOrcame := AF2->AF2_ORCAME
	
		Otherwise
			lContinua := .F.
			
	EndCase

	If lContinua

		If GetMV("MV_PMSTCOD") == "1" .AND. !lEdtPai
			Define MsDialog oDlg Title STR0093 From 0, 0 To 125, 300;
			  Of oMainWnd Pixel //"Recodificar Tarefa/EDT"
		
				// codigo atual
				@ 010, 005 Say STR0094 Of oDlg Pixel //"Codigo atual:"
				@ 009, 045 MSGet cOldCode Of oDlg Size 100, 08 Pixel ReadOnly
				
				// novo codigo
				@ 022, 005 Say STR0095 Of oDlg Pixel //"Novo codigo:"
				
				If cAlias == "AF2"
					@ 021, 045 MSGet oNewCode Var cNewCode;
					           Valid !ExistOrcTrf(cOrcame, cNewCode) Of oDlg;
					           Picture cGetPict Size 100, 08 Pixel
				Else
					@ 021, 045 MSGet oNewCode Var cNewCode;
					           Valid !ExistOrcEDT(cOrcame, cNewCode) Of oDlg;
					           Picture cGetPict Size 100, 08 Pixel
				EndIf
		
				// OK
				@ 038, 065 Button "OK" Size 35 ,11 FONT oDlg:oFont;
				           Action (lOk := .T., oDlg:End()) Of oDlg Pixel;
				           When !Empty(cNewCode)
		
				// Cancelar
				@ 038, 110 Button STR0096 Size 35 ,11 FONT oDlg:oFont;
				           Action (lOk := .F., oDlg:End()) Of oDlg Pixel //"Cancelar"
			Activate MsDialog oDlg On Init oNewCode:SetFocus() Centered
		Else
			lOk := .T.
		EndIf

		// cursor ampulheta
		CursorWait()
		
		If lOk
		
			lReturn  := .T.
			
			If cAlias == "AF2"
	
				dbSelectArea("AF2")
				dbGoTo(nRecNo)

				// gera o codigo automatico
				If GetMV("MV_PMSTCOD") == "2"
					cNewCode := PMSNumAF2(AF2->AF2_ORCAME,;
			                          PMSGetNivOrc(AF2->AF2_ORCAME, AF2->AF2_EDTPAI),;
					                      AF2->AF2_EDTPAI,;
					                      AF2->AF2_TAREFA,;
					                      .F.)
				EndIf		
	
				Begin Transaction			
					Reclock(cAlias, .F.)
						AF2->AF2_TAREFA := cNewCode
					MsUnlock()
	
					// libera os codigo reservados
					FreeUsedCode(.T.)
				
					// atualiza a tarefa das outras tabelas relacionadas
					AF2RecRelTables(AF2->AF2_FILIAL, AF2->AF2_ORCAME, cOldCode, cNewCode)
				End Transaction  
				
			Else
			
				dbSelectArea("AF5")
				dbGoTo(nRecNo)
				
				// se for EDT Principal, deve recodificar as EDT/tarefas filhas
				If lEdtPai
					Begin Transaction
						
						// atualiza a TAREFA/EDT filhas da EDT
						AF5ReCode(cGetPict, Padr(cOrcame, TamSX3("AF5_EDT")[1]), cOrcame, cNivelAF5)
					End Transaction
				Else
					
					// gera o codigo automatico
					If GetMV("MV_PMSTCOD") == "2"
						cNewCode := PMSNumAF5(AF5->AF5_ORCAME,;
						                      PMSGetNivOrc(AF5->AF5_ORCAME, AF5->AF5_EDTPAI),;
						                      AF5->AF5_EDTPAI,;
						                      AF5->AF5_EDT,;
						                      .F.)
					EndIf
				
					Begin Transaction
						
						Reclock("AF5", .F.)
							AF5->AF5_EDT := cNewCode
						MsUnlock()
						
						// libera o codigo reservado
						FreeUsedCode(.T.)
						
						cNewCode := AF5->AF5_EDT
						
						// atualiza a EDT PAI das tarefas-filhas
						AF5AtuTrf(AF5->AF5_FILIAL, AF5->AF5_ORCAME, cOldCode, cNewCode)
							
						// atualiza a EDT PAI das EDT Filhas e a EDT das outras tabelas relacionadas
						AF5RecRelTables(AF5->AF5_FILIAL, AF5->AF5_ORCAME, cOldCode, cNewCode)
						
						// atualiza a TAREFA/EDT filhas da EDT
						AF5ReCode(cGetPict, cNewCode, cOrcame, cNivelAF5)
						
					End Transaction
				EndIf
			EndIf
		EndIf
		
		// cursor seta
		CursorArrow()
		
	EndIf
Return lReturn

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AF5ReCode       ³ Autor ³Reynaldo Miyashita    ³ Data ³ 16/01/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que gera um novos codigos para EDT/TAREFA filhas referentes ³±±
±±³          ³ ao codigo da EDT informado do Orçamento.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF5ReCode(cGetPict, cNewCode, cOrcame, cNivelAF5)
Local nLoop   := 0
Local aFilhos := {}
Local aParam  := {}
Local aConfig := {}
Local cCodigo := ""
Local cEDTPai := ""
    
	// obtem todas EDT filhas
	dbSelectArea("AF5")
	dbSetOrder(2)
	dbSeek(xFilial("AF5") + cOrcame + cNewCode)
	While AF5->(!Eof()) .And. ;
	      AF5->(AF5_FILIAL + AF5_ORCAME + AF5_EDTPAI) ==;
				xFilial("AF5") + cOrcame + cNewCode
	      
		aAdd(aFilhos ,{ "AF5" ;
					   ,iIf(Empty(AF5->AF5_ORDEM), "000", AF5->AF5_ORDEM);
					   ,AF5->AF5_EDT ;
					   ,AF5->(recno()) } )
		dbSkip()
	End
	
	// obtem todas tarefas filhas
	dbSelectArea("AF2")
	dbSetOrder(2)
	dbSeek(xFilial("AF2") + cOrcame + cNewCode)
	While AF2->(!Eof()) .AND. ;
		AF2->(AF2_FILIAL + AF2_ORCAME + AF2_EDTPAI)==;
		xFilial("AF2")+ cOrcame + cNewCode
		aAdd(aFilhos ,{"AF2",;
		               If(Empty(AF2->AF2_ORDEM), "000", AF2->AF2_ORDEM),;
		               AF2->AF2_TAREFA,;
		               AF2->(recno())})
		dbSkip()
	End
	
	// ordena por nivel e codigo EDT/Tarefa
	aSort(aFilhos,,, {|x, y| x[2]+x[3] < y[2]+y[3] })
	
	cCodigo := cNewCode
	For nLoop := 1 To len(aFilhos)
		If aFilhos[nLoop][1] == "AF5"
				
			dbSelectArea("AF5")
			dbGoto(aFilhos[nLoop][4])
			
			cEDTPai := AF5->AF5_EDTPAI
			
			// se for a EDT Principal do Orçamento
			If padr(AF5->AF5_ORCAME,TamSX3("AF5_EDT")[1]) == cCodigo
				cCodigo := ""
				cEdtPai := ""
			EndIf
		
			If GetMV("MV_PMSTCOD") == "1"
				aParam  :=  {;
				             {1, STR0097, cOrcame, "@!",,"", ".F.", 55 ,.F.},; //"Orçamento"
				             {1, STR0098, AF5->AF5_EDT, "@!",,"", ".F.", 55 ,.F.},; //"Cod. Anterior:"
				             {1, STR0099, Space(TamSX3("AF5_EDT")[1]), "@!" ,'ExistChav("AF5", "' + cOrcame + '"+ mv_par03 ) .And.FreeForUse("AF5","'+ cOrcame + '" + mv_par03)',"","", 55 ,.T.}; //"Novo Codigo:"
				            }
				aConfig := {}
				
				If ParamBox(aParam, STR0100, aConfig,,,.F.,90,15,,ProcName(0)+"AF5",.F.) //"Renomear codigo da EDT"
					cCodigo := aConfig[3]
				Else
					Exit
				EndIf
				
			EndIf
			
			If GetMV("MV_PMSTCOD") == "2"
				cCodigo := PMSNumAF5(AF5->AF5_ORCAME,;
				                     PMSGetNivOrc(AF5->AF5_ORCAME, AF5->AF5_EDTPAI),;
				                     cEdtPai,;
				                     cCodigo,;
					                   .F.)
			EndIf
			
			Reclock("AF5", .F.)
				AF5->AF5_EDT := cCodigo
			MsUnlock()
			
			// libera o codigo reservado
			FreeUsedCode(.T.)
		 	
			cCodigo := AF5->AF5_EDT
			
			// atualiza a EDT PAI das tarefas-filhas
			AF5AtuTrf(AF5->AF5_FILIAL, AF5->AF5_ORCAME, aFilhos[nLoop][3], cCodigo)
				
			// atualiza a EDT PAI das EDT Filhas e a EDT das outras tabelas relacionadas
			AF5RecRelTables(AF5->AF5_FILIAL, AF5->AF5_ORCAME, aFilhos[nLoop][3], cCodigo)
			
			// atualiza a TAREFA/EDT filhas da EDT
			AF5ReCode(cGetPict, cCodigo, cOrcame, cNivelAF5)
				
		EndIf
		
		If aFilhos[nLoop][1] == "AF2"
			dbSelectArea("AF2")
			dbGoto(aFilhos[nLoop][4])
			
			cEDTPai := AF2->AF2_EDTPAI
			
			// se for a EDT Principal do orçamento
			If padr(AF2->AF2_ORCAME,TamSX3("AF2_TAREFA")[1]) == cCodigo
				cCodigo := ""
				cEdtPai := ""
			EndIf
		
			If GetMV("MV_PMSTCOD") == "1"
				aParam  :=  {;                                                                                                                                                                                        
				             {1, STR0097, cOrcame, "@!",,"", ".F.", 55 ,.F.},; // "Orçamento:"             
							 {1, STR0098, AF2->AF2_TAREFA, "@!",,"", ".F.", 55 ,.F.},; // "Cod. Anterior:"
							 {1, STR0099, Space(TamSX3("AF2_TAREFA")[1]), "@!" ,'ExistChav("AF2", "' + cOrcame + '"+ mv_par03 ) .And.FreeForUse("AF2","'+ cOrcame + '" + mv_par03)',"","", 55 ,.T.}; // "Novo Codigo:" 
							}
				aConfig := {}
				
				If ParamBox(aParam, STR0101, aConfig,,,.F.,90,15,,ProcName(0)+"AF2",.F.) // "Renomear codigo da Tarefa"
					cCodigo := aConfig[3]
				Else
					Exit
				EndIf
			EndIf
			
			If GetMV("MV_PMSTCOD") == "2"
				cCodigo := PMSNumAF2(AF2->AF2_ORCAME,;
				                     PMSGetNivOrc(AF2->AF2_ORCAME, AF2->AF2_EDTPAI),;
				                     cEDTPai,;
				                     cCodigo,;
				                     .F.)
			EndIf
			Reclock("AF2", .F.)
				AF2->AF2_TAREFA := cCodigo
			MsUnlock()
						
			// libera o codigo reservado
			FreeUsedCode(.T.)
        	
			// atualiza a TAREFA das outras tabelas relacionadas
			AF2RecRelTables(AF2->AF2_FILIAL, AF2->AF2_ORCAME, aFilhos[nLoop][3], cCodigo)
		EndIf

	Next nLoop
		
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ExistOrcE ³ Autor ³ Adriano Ueda         ³ Data ³ 26/01/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para verificar a existencia de determinada tarefa.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrcame  : codigo do orçamento                               ³±±
±±³          ³ cTarefa  : codigo da tarefa                                  ³±±
±±³          ³ lMensagem: indica se exibira o help de ja gravado            ³±±
±±³          ³            (default: .T.)                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ExistOrcEDT(cOrcame, cEDT, lMensagem)
	Local aAreaAF5 := AF5->(GetArea())
	Default lMensagem := .T.
	
	dbSelectArea("AF5")
	AF5->(dbSetOrder(1))
	
	If AF5->(Msseek(xFilial("AF5") + cOrcame + cEDT))
		If lMensagem
			Help(" ", 1, "JAGRAVADO")
		EndIf
		
		lRet := .T.
	Else
		If !(FreeForUse("AF5", cOrcame + cEDT))
			MsgAlert(STR0104) //"Código Reservado!"
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf

	RestArea(aAreaAF5)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AF5AtuTrf ³ Autor ³ Adriano Ueda         ³ Data ³ 26/01/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para verificar a existencia de determinada tarefa.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrcame  : codigo do orçamento                               ³±±
±±³          ³ cTarefa  : codigo da tarefa                                  ³±±
±±³          ³ lMensagem: indica se exibira o help de ja gravado            ³±±
±±³          ³            (default: .T.)                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF5AtuTrf(cFil, cOrcame, cEDT, cNewEDT)
	Local aParam, aCamposUsr
	Local aCampos := {}
	
	aAdd(aCampos,   {"AF2", "AF2_EDTPAI", "AF2_FILIAL", "AF2_ORCAME", "AF2_EDTPAI", cFil, cOrcame, cEDT, , cNewEDT})
	// AF2_FILIAL+AF2_ORCAME+AF2_EDTPAI+AF2_ORDEM
	
	//Ponto de Entrada para manipulacao do array aCampos
	//passado aCampos e aParam contendo os parametros recebidos pela funcao
	aParam := { cFil, cOrcame, cEDT, cNewEDT}

	If ExistBlock("PM100AF5")
		aCamposUsr := ExecBlock("PM100AF5", .F., .F., {aCampos, aParam})	
		AEval( aCamposUsr, { |x| AAdd( aCampos, x ) } )
	EndIf

	PMSAltera(aCampos)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PMS100SubsºAutor  ³Reynaldo Miyashita  º Data ³  10.03.2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que substitui um produto/recurso por outro informadoº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA100                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMS100Subs()
Local aArea    := GetArea()
Local aAreaSB1 := {}
Local aParam   := {}
Local lUpdate  := .F.
Local aRetCus  := {}

	aParam := PMSSubRec()
	
	If ! Empty(aParam)
	
		// Substituir o produto 
		If aParam[1]
			dbSelectArea("SB1")
			dbSetOrder(1)
			MSSeek(xFilial("SB1")+aParam[3])
		EndIf
		
		// Substituir o recurso
		If aParam[4]
			dbSelectArea("AE8")
			dbSetOrder(1)
			MSSeek(xFilial("AE8")+aParam[6])
		EndIf
		
		ProcRegua( AF2->(LastRec()) )
		
		//
		// busca tarefa a tarefa
		//
		dbSelectArea("AF2")
		dbSetOrder(1)
		MSSeek(xFilial("AF2")+AF1->AF1_ORCAME)
		While AF2->(!Eof()) .AND. (AF2->(AF2_FILIAL+AF2_ORCAME)==xFilial("AF2")+AF1->AF1_ORCAME)

			IncProc()
		
			//
			// busca os produtos e/ou recursos 
			//
			dbSelectArea("AF3")
			dbSetOrder(1)
			MSSeek(xFilial("AF2")+AF2->AF2_ORCAME+AF2->AF2_TAREFA)
			While AF3->(!Eof()) .AND. (AF3->AF3_FILIAL+AF3->AF3_ORCAME+AF3->AF3_TAREFA==xFilial("AF3")+AF2->AF2_ORCAME+AF2->AF2_TAREFA)
	
				// substitui o produto
				If aParam[1] .and. (AF3->(FieldPos("AF3_RECURS")) == 0 .OR. AF3->(FieldPos("AF3_RECURS")) > 0 .And. Empty(AF3->AF3_RECURS))
					If aParam[2] == AF3->AF3_PRODUT 
						RecLock("AF3",.F.)
							AF3->AF3_PRODUT := SB1->B1_COD
							AF3->AF3_MOEDA	:= Val(RetFldProd(SB1->B1_COD,"B1_MCUSTD"))
							AF3->AF3_CUSTD	:= RetFldProd(SB1->B1_COD,"B1_CUSTD")
				
							If ExistTemplate("CCT100_0")
								ExecTemplate("CCT100_0",.F.,.F.)
							EndIf
							
						MsUnlock()
						
						lUpdate := .T.
					EndIf
				EndIf

				// substitui o recurso
				If aParam[4] .And. !Empty(AF3->AF3_RECURS)
					If aParam[5] == AF3->AF3_RECURS
						RecLock("AF3",.F.)
							AF3->AF3_RECURS	:= AE8->AE8_RECURS
							AF3->AF3_PRODUT := AE8->AE8_PRODUT
							AF3->AF3_CUSTD  := AE8->AE8_VALOR
							
							If Empty(AF3->AF3_PRODUT)
								AF3->AF3_MOEDA := 1
							Else
								aAreaSB1 := SB1->(GetArea())
								dbSelectArea("SB1")
								dbSetOrder(1)
								If MSSeek(xFilial("SB1")+AF3->AF3_PRODUT)
									AF3->AF3_MOEDA := Val(RetFldProd(SB1->B1_COD,"B1_MCUSTD"))
									If AF3->AF3_CUSTD == 0
										AF3->AF3_CUSTD := RetFldProd(SB1->B1_COD,"B1_CUSTD")
									EndIf
								Else
									AF3->AF3_MOEDA := 1
									AF3->AF3_CUSTD := 0
								EndIf
								RestArea(aAreaSB1)
							EndIf
				
							If ExistTemplate("CCT100_0")
								ExecTemplate("CCT100_0",.F.,.F.)
							EndIf
							
						MsUnlock()
						
						lUpdate := .T.
						
					EndIf
				EndIf
				
				dbSelectArea("AF3")
				dbSkip()
			EndDo
			
			If lUpdate
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava o custo da tarefa.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistTemplate("PMAAF2CTrf")
					ExecTemplate("PMAAF2CTrf",.F.,.F.,{AF2->AF2_ORCAME,AF2->AF2_TAREFA})
				Else
					aRetCus	:= PmsAF2CusTrf(0,AF2->AF2_ORCAME, AF2->AF2_TAREFA)
					RecLock("AF2",.F.)
					Replace AF2->AF2_CUSTO  With aRetCus[1]
					Replace AF2->AF2_CUSTO2 With aRetCus[2]
					Replace AF2->AF2_CUSTO3 With aRetCus[3]
					Replace AF2->AF2_CUSTO4 With aRetCus[4]
					Replace AF2->AF2_CUSTO5 With aRetCus[5]
				    AF2->AF2_VALBDI:= aRetCus[1]*IF(AF2->AF2_BDI<>0,AF2->AF2_BDI,PmsGetBDIPad('AF5',AF2->AF2_ORCAME,,AF2->AF2_EDTPAI, If(AF2->(FieldPos('AF2_UTIBDI')) > 0, AF2->AF2_UTIBDI, "1") ))/100
					AF2->AF2_TOTAL := aRetCus[1]+AF2->AF2_VALBDI
					MsUnlock()  
				 EndIf
			    
				PmsAvalAF2("AF2")
				lUpdate := .F.
			EndIf
			
			dbSelectArea("AF2")
			dbSkip()
		End
		
	EndIf

	RestArea(aArea)

Return( .T. )
                
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
Local aRotina 	:= {}
Local aUsRotina	:=	{}

aRotina 	:= {	{ STR0002,"AxPesqui"  , 0 , 1,,.F.},; 	//"Pesquisar"
							{ STR0003,"PMS100Dlg" , 0 , 2},; 	//"Visualizar"
							{ STR0004,"PMS100Dlg" , 0 , 3},; 	//"Incluir"
							{ STR0018,"PMS100Alt" , 0 , 4},; //"Alt.Cadastro"
							{ STR0019,"PMS100Dlg" , 0 , 4},; //"Alt.Estrutura"
							{ STR0008,"PMS100Dlg" , 0 , 5},;
							{ STR0092,"Pms100Usr" , 0 , 5},;
							{ STR0054,"PMS100Leg" , 0 , 2, ,.F.}}      //"Legenda"

If AMIIn(44)
	// adiciona botoes do usuario na EnchoiceBar
	If ExistBlock( "PM100ROT" )
		If ValType( aUsRotina := ExecBlock( "PM100ROT", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf

Return(aRotina)
