#include "pmsa410.ch"
#include "protheus.ch"
#include "pmsicons.ch"

#IFDEF TOP
Static lDefTop := .T.
#else
Static lDefTop := .F.
#endIf

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA410  ³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de manutecao de projetos .                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA410                                                      ³±±
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
Function PMSA410()
Local aUsRotina
Local cFiltBrw		:= ""
Local bFiltraBrw
Local aIndexAF8 	:= {}
PRIVATE cCadastro	:= STR0001 //"Gerenciamento de Projetos"

Private aRotina := MenuDef()
PRIVATE aMemos  := {{"AF8_CODMEM","AF8_OBS"}}
PRIVATE aCores  := PmsAF8Color()
PRIVATE nDlgPln := PMS_VIEW_TREE
Private lCallPrj := .T.

Set Key VK_F12 To FAtiva()

If AMIIn(44) .And. !PMSBLKINT()

	Pergunte("PMA200",.F.)
	nDlgPln := mv_par01

	If ExistBlock( "PM410FIL" )
		cFiltBrw := ExecBlock("PM410FIL",.F.,.F.)
		If ( ValType(cFiltBrw) == "C" ) .And. !Empty(cFiltBrw)
			bFiltraBrw := {|| FilBrowse("AF8",@aIndexAF8,@cFiltBrw) }
			Eval(bFiltraBrw)
		EndIf
	EndIf

	//If nCallOpcx <> Nil
		//PMS200Dlg("AF8",AF8->(RecNo()),nCallOpcx,,,cRevisa)
	//Else
		mBrowse(6,1,22,75,"AF8",,,,,,aCores)
	//EndIf
	If ( Len(aIndexAF8)>0 )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza o uso da funcao FilBrowse e retorna os indices padroes.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		EndFilBrw("AF8",aIndexAF8)
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS410Dlg³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao,Alteracao,Visualizacao e Exclusao       ³±±
±±³          ³ de Projetos.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS410Dlg(cAlias,nReg,nOpcx,cR1,cR2,cVers)
Local l410Inclui   := .F.
Local l410Visual   := .F.
Local l410Altera   := .F.
Local l410Exclui   := .F.
Local lContinua	   := .T.
Local lDelPrj      := .T.
Local lChgCols	   := .F.
Local lOk
Local oDlg
Local aConfig	   := {1, PMS_MIN_DATE, PMS_MAX_DATE,Space(TamSX3("AE8_RECURS")[1])}
Local cSearch      := Space(TamSX3("AFC_DESCRI")[1])
Local bContext	   := Nil
Local oMenu
Local oMenu2
Local oMenu21
Local oMenu3
Local oMenu4
Local oMenu5
Local oMenu6
Local oMenu7
Local nX,nZ
Local nY
Local aMenuAt	   := {}
Local aDelObj	   := {}
Local lFWGetVersao := .T.
Local lCalcTrib    := .F.

Local nScreVal1 := 775 // variaveis para posicionamento do popup menu
Local nScreVal2 := 23  // variaveis para posicionamento do popup menu
Local nScreVal3 := 810  // variaveis para posicionamento do popup menu
Local nScreVal4 := 603  // variaveis para posicionamento do popup menu
Local nScreVal5 := 45	// variaveis para posicionamento do popup menu
Local aScreens := {}   // variaveis para posicionamento do popup menu
DEFAULT	cVers := AF8->AF8_REVISA

Private oTree
Private cArquivo	:= CriaTrab(,.F.)
PRIVATE cRevisa		:= cVers
PRIVATE cCmpPLN
PRIVATE cArqPLN
PRIVATE cPLNVer		:= ''
PRIVATE cPLNDescri	:= ''
PRIVATE cPLNSenha	:= ''
PRIVATE lSenha		:= .F.
PRIVATE aBAtalhos	:=	{}
PRIVATE bBlocoAtalho:=	{}
Private lEmAtalho	:=	.F.
Private nFreeze		:= 0
PRIVATE nIndent		:= PMS_SHEET_INDENT

PRIVATE _cProjCod := AF8->AF8_PROJET    //variaveis utilizadas no x3_relacao funcao pmsCpoInic()
PRIVATE _cTarefa  := ""                //variaveis utilizadas no x3_relacao funcao pmsCpoInic()

Private oTempTbAN9	:= Nil

//Incluido variaveis para posicionamento do Popup Menu, pois na russia o mesmo deverá ficar posicioando abaixo do menu a direita
If cPaisLoc == 'RUS'
	//Valores para a Russia, posicionado a direita
	//Change popup menu localization, using the screen resolution to position on right
	aScreens := getScreenRes()
	nScreVal1 := aScreens[1]-215
	nScreVal2 := 53
	nScreVal3 := nScreVal1  // variaveis para posicionamento do popup menu
	nScreVal4 := nScreVal2  // variaveis para posicionamento do popup menu
	nScreVal5 := nScreVal2 // variaveis para posicionamento do popup menu
EndIf

If aRotina[nOpcx][4] == 4  //na versao 11 o lock é automatico ao pressionar altera na mbrowse - impede outros usuarios a realizar apt.
	AF8->(MsUnlock())      //razao desta instrução para liberar o registro referente ao 
EndIf

Pergunte("PMA200",.F.)

Do Case
	Case (aRotina[nOpcx][4] == 2)
		l410Visual := .T.
	Case (aRotina[nOpcx][4] == 3) .Or. (aRotina[nOpcx,4] == 6)
		l410Inclui	:= .T.
	Case (aRotina[nOpcx][4] == 4)
		l410Altera	:= .T.
	Case (aRotina[nOpcx][4] == 5)
		lOk			:= .F.
		l410Exclui	:= .T.
		l410Visual	:= .T.
EndCase

If l410Exclui
	If !PmsVldFase("AF8",AF8->AF8_PROJET,"12")
		lContinua := .F.
	EndIf
EndIf

If l410Altera
	// verifica se o projeto nao esta reservado
	If AF8->AF8_PRJREV=="1" .And. AF8->AF8_STATUS<>"2" .And. GetNewPar("MV_PMSRBLQ","N")=="S"
		Aviso(STR0012,STR0013,{STR0014},2) //"Gerenciamento de Revisoes"###"Este projeto nao se encontra em revisao. Para realizar uma alteracao no projeto, deve-se primeiro Iniciar uma revisao no projeto atraves do Gerenciamento de Revisoes."###"Fechar"
		lContinua := .F.
	EndIf

	// verifica o evento de alteracao no Fase atual
	If !PmsVldFase("AF8",AF8->AF8_PROJET,"11")
		lContinua := .F.
	EndIf
EndIf                                                                                   


If l410Exclui
	cCadastro := STR0001 + STR0162 // - Excluir
Elseif l410Altera
	cCadastro := STR0001 + STR0163 // - Alterar
Elseif l410Visual
	cCadastro := STR0001 + STR0164 // - Visualizar
Else
	cCadastro := STR0001 + STR0165 // - Incluir
Endif
//***************************
// Integração com o SIGAPCO *
//***************************
PcoIniLan("000350")

If lContinua
	PmsAvalCal()
	//Verifica se considera calculo de impostos dos produtos ou recursos das tarefas
	lCalcTrib := IIf(AF8->AF8_PAR006 == '1' , .T., .F.)

	//Chamada da funcao que determina a exibicao dos campos totalizadores de Impostos das EDTs/Tarefas
	PMSExibeCpoImp(lCalcTrib)

	If !l410Visual

		// Ferramentas
		MENU oMenu2 POPUP
			If l410Inclui .Or. l410Altera
				MENUITEM STR0018 ACTION ClearAtalho() ,If(PMS200Rev(),PmsRpr(oTree,cRevisa,cArquivo),Nil) ,RestoreAtalho() //"Reprogramar datas previstas... "
				MENUITEM STR0137 ACTION ClearAtalho() ,PmsRprSim(oTree,cRevisa,cArquivo) ,RestoreAtalho() //"Simular reprogramacao..."
				MENUITEM STR0019 ACTION ClearAtalho() ,If(PMS200Rev(),(Pms200AltCus(oTree,,lCalcTrib),Eval(bRefresh)),Nil) ,RestoreAtalho()  //"Reajustar Custo Previsto... "
				MENUITEM STR0101 ACTION ClearAtalho() ,(PMS200ReCalc(,lCalcTrib),Eval(bReCalc)) ,RestoreAtalho()  //"Recalculo do custo"
				MENUITEM STR0098 ACTION ClearAtalho() ,If(PMS200Rev(),(PmsDlgRedistRec( AF8->AF8_PROJET ,cRevisa ),Eval(bRefresh)),Nil) ,RestoreAtalho()  //"Redistribuição de Recursos"
				MENUITEM STR0124 ACTION ClearAtalho() ,Processa({|| Pms200REdt(oTree,cArquivo)} ) ,RestoreAtalho() //"Atualizar acumulados de datas e progresso"
				MENUITEM STR0125 ACTION ClearAtalho() ,Processa({|| Pms200AGrp(oTree,cArquivo) }) ,RestoreAtalho()  //"Alterar Grupo de Tarefas"
				MENUITEM STR0123 ACTION ClearAtalho() ,If(PMS200Rev(),(iIf(RecodeProj(@oTree, cArquivo),Eval(bRefresh),.T.)),Nil) ,RestoreAtalho()  //
				MENUITEM STR0136 ACTION ClearAtalho() ,If(PmsVldFase("AF8", AF8->AF8_PROJET, "28"), ;
					                       (Processa({|| PMS200Subs()}), Eval(bRefresh)), Nil) ,RestoreAtalho() // "Substituir"
				MENUITEM STR0159 ACTION ClearAtalho() ,If( PmsVldFase("AF8", AF8->AF8_PROJET, "28") , ;
					                                      (Processa({|| PMS200SbLt()}), Eval(bRefresh)), Nil),RestoreAtalho() // "Substituicao em lote de recursos"

				If AF8ComAJT( AF8->AF8_PROJET )
					MENUITEM STR0156 //"Composicoes Auxiliares"
					MENU oMenu21 POPUP
						MENUITEM STR0157 ACTION ClearAtalho() ,If(PMS200Rev(),PA204Dialog( AF8->AF8_PROJET, cRevisa, bReCalc ),Nil) ,RestoreAtalho()  //"Insumos do Projeto"
						MENUITEM STR0158 ACTION ClearAtalho() ,If(PMS200Rev(),PA205Dlg2( AF8->AF8_PROJET, cRevisa, bReCalc ),Nil) ,RestoreAtalho()  //"Composicoes Auxiliares do Projeto"
					ENDMENU
				EndIf
			EndIf
		ENDMENU
		For nZ	:=	1	To Len(oMenu2:aItems)
			AAdd(aMenuAt,{ATA_FERRAMENTAS+"A"+STRZERO(nZ,2),1,oMenu2:aItems[nZ]:cCaption,oMenu2:aItems[nZ]:bAction,oMenu2,Nil})
		Next

		// Consultas
		MENU oMenu3 POPUP
			MENUITEM STR0020 ACTION ClearAtalho() ,PmsDlgAF8Gnt(cRevisa,aConfig,@oDlg,@oTree,cArquivo) ,RestoreAtalho()  //"Grafico de Gantt"
			MENUITEM STR0126 ACTION ClearAtalho() ,PmsDlgAF8Rec(cRevisa,@oTree,cArquivo) ,RestoreAtalho()
			MENUITEM STR0127 ACTION ClearAtalho() ,Pms200View(STR0021+STR0104,{|| PMSC110(AF8->AF8_PROJET,cRevisa,,,@oTree,cArquivo) }) ,RestoreAtalho() //"Alocacao dos Recursos do projeto por Periodo"
			MENUITEM STR0121 ACTION ClearAtalho() ,Pms200View(STR0121,{|| PMSC112(AF8->AF8_PROJET,cRevisa,@oTree,cArquivo) }) ,RestoreAtalho() //"Alocacao dos recursos do projeto por Equipe/Periodo"
			MENUITEM STR0128 ACTION ClearAtalho() ,PmsDlgAF8Eqp(cRevisa,@oTree,cArquivo) ,RestoreAtalho()  //"Alocacao das Equipes do projeto"
			MENUITEM STR0129 ACTION ClearAtalho() ,Pms200View(STR0097+STR0104,{||PMSC115(AF8->AF8_PROJET,cRevisa,@oTree,cArquivo) }) ,RestoreAtalho() //"Alocacao das Equipes do projeto por Periodo"
			MENUITEM STR0130 ACTION ClearAtalho() ,Processa({|| PmsRedeRel(oTree,cArquivo)}) ,RestoreAtalho()  //"Redes de relacionamentos"
			MENUITEM STR0131 ACTION ClearAtalho() ,(oProcess := MsNewProcess():New({|| PmsCfgPFI(,oTree,,cArquivo) } ,"Gerando progresso Financeiro" ) ,oProcess:Activate()) ,RestoreAtalho()  //"Progresso Financeiro Previsto x Realizado"
			MENUITEM STR0132 ACTION ClearAtalho() ,Processa({||PmsCfgPFS(,oTree,,cArquivo)}) ,RestoreAtalho()  //"Progresso Fisico Previsto x Realizado"
			MENUITEM STR0133 ACTION ClearAtalho() ,PMSC100AEX(oTree,cArquivo) ,RestoreAtalho()  //"Analise da Execução ( Analise do Valor Agregado )"
			MENUITEM STR0134 ACTION ClearAtalho() ,Processa({||PMSCfgEV(,oTree,,cArquivo)}) ,RestoreAtalho() //"Progresso da Analise do Valor Agregado"
			MENUITEM STR0135 ACTION ClearAtalho() ,Processa({||PMC100Flx(oTree,cArquivo)}) ,RestoreAtalho()  //"Fluxo de Caixa do projeto"
			MENUITEM STR0138 ACTION ClearAtalho() ,MsAguarde({|| PmsAponRec(oTree,cArquivo)}) ,RestoreAtalho()  //'Apontamento de recursos'
			If lCalcTrib
				MENUITEM STR0161 ACTION ClearAtalho() ,PmsDlgAN9Vis(),RestoreAtalho()  //"Tributos do Projeto"
	   		EndIf
		EndMenu
		For nZ	:=	1	To Len(oMenu3:aItems)
			AAdd(aMenuAt,{ATA_PROJ_CONSULTAS+"A"+STRZERO(nZ,2),1,oMenu3:aItems[nZ]:cCaption,oMenu3:aItems[nZ]:bAction,oMenu3,Nil})
		Next

		// Estrutura
		MENU oMenu POPUP
			MENUITEM STR0022 ACTION ClearAtalho() ,If(PMS200Rev(),(iIf(PMS200to201(3,@oTree,"1",cArquivo) ,Eval(bRefresh) ,.T.)),Nil) ,RestoreAtalho() // //PMSTreeEDT(@oTree,cRevisa) //"Incluir EDT"
			MENUITEM STR0023 ACTION ClearAtalho() ,If(PMS200Rev(),(iIf(PMS200to201(3,@oTree,"2",cArquivo) ,Eval(bRefresh) ,.T.)),Nil) ,RestoreAtalho()//"Incluir Tarefa"
			MENUITEM STR0024 ACTION ClearAtalho() ,If(PMS200Rev(),(iIf(PMS200to201(4,@oTree,,cArquivo)    ,Eval(bRefresh) ,.T.)),Nil) ,RestoreAtalho()//"Alterar"
			MENUITEM STR0003 ACTION ClearAtalho() ,PMS200to201(2,@oTree,,cArquivo) ,RestoreAtalho()//"Visualizar"
			MENUITEM STR0008 ACTION ClearAtalho() ,If(PMS200Rev(),(iIf(PMS200to201(5,@oTree,,cArquivo) ,Eval(bRefresh) ,.T.)),Nil) ,RestoreAtalho()   //"Excluir"
			MENUITEM STR0140 ACTION ClearAtalho() ,If(PMS200Rev(),(If(PMS200Import(oTree,cArquivo,1,lCalcTrib), Eval(bRefresh), .T.)), Nil)  ,RestoreAtalho()   //"Copiar EDT/Tarefa de Orcamento"
			MENUITEM STR0025 ACTION ClearAtalho() ,If(PMS200Rev(),(If(PMS200Import(oTree,cArquivo,2,lCalcTrib), Eval(bRefresh), Nil)), Nil)  ,RestoreAtalho()   //"Copiar EDT/Tarefa do Projeto"
			MENUITEM STR0026 ACTION ClearAtalho() ,If(PMS200Rev(),(If(PMS200Cmp(AF8->(RecNo()),@oTree,cArquivo),Eval(bRefresh),Nil)),Nil) ,RestoreAtalho()//"Importar Composicao"
			MENUITEM STR0027 ACTION ClearAtalho() ,If(PMS200Rev(),(PMS200ChangeEDT(@oTree,cArquivo,lCalcTrib),Eval(bRefresh)),Nil) ,RestoreAtalho()//"Importar Composicao" //"Trocar EDT Pai"
			MENUITEM STR0106 ACTION ClearAtalho() ,If(PMS200Rev(),(If(PMS200Cmp2(AF8->(RecNo()),@oTree,cArquivo,),Eval(bRefresh),Nil)),Nil) ,RestoreAtalho()//"Associar Composicao"

			If nDlgPln == PMS_VIEW_TREE
				MENUITEM STR0099 ACTION ClearAtalho() ,Procurar(oTree, @cSearch, cArquivo) ,RestoreAtalho() //"Procurar"
				MENUITEM STR0100 ACTION ClearAtalho() ,ProcurarP(oTree, @cSearch, cArquivo) ,RestoreAtalho() //"Procurar proxima"
			EndIf
		ENDMENU
		For nZ	:=	1	To Len(oMenu:aItems)
			AAdd(aMenuAt,{ATA_PROJ_ESTRUTURA+"A"+STRZERO(nZ,2),1,oMenu:aItems[nZ]:cCaption,oMenu:aItems[nZ]:bAction,oMenu,Nil})
		Next

		// Documentos
		MENU oMenu4 POPUP
			MENUITEM STR0028 Action ClearAtalho() ,PMS230DC(@oTree,cArquivo),Eval(bRefresh) ,RestoreAtalho() //"Atualizar Documentos"
			MENUITEM STR0029 Action ClearAtalho() ,PMS230View(@oTree,@aDelObj,cArquivo) ,RestoreAtalho() //"Abrir Documento"
			MENUITEM STR0030 Action ClearAtalho() ,PMS230Save(@oTree,@aDelObj,cArquivo) ,RestoreAtalho() //"Salvar Como"
			MENUITEM STR0002 Action ClearAtalho() ,PMSDocPesq(@oTree, AF8->AF8_PROJET, AF8->AF8_REVISA) ,RestoreAtalho() //"Pesquisar"
		ENDMENU
		For nZ	:=	1	To Len(oMenu4:aItems)
			AAdd(aMenuAt,{ATA_DOCUMENTOS+"A"+STRZERO(nZ,2),1,oMenu4:aItems[nZ]:cCaption,oMenu4:aItems[nZ]:bAction,oMenu4,Nil})
		Next

		// Gerenciamento de Execucao
		MENU oMenu5 POPUP
			MENUITEM STR0031 Action ClearAtalho() ,PMS220CP(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Geren. Contrato de Parceria"
			MENUITEM STR0032 Action ClearAtalho() ,PMS220SC(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Geren. Solicitacao de Compras"
			MENUITEM STR0033 Action ClearAtalho() ,PMS220SA(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Geren. Solicitacao ao Almox."
			MENUITEM STR0034 Action ClearAtalho() ,PMS220OP(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Geren. Ordens de Producao"
			MENUITEM STR0035 Action ClearAtalho() ,PMS220EM(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Geren. Empenhos do Projeto"
		ENDMENU
		For nZ	:=	1	To Len(oMenu5:aItems)
			AAdd(aMenuAt,{ATA_PROJ_EXECUCAO+"A"+STRZERO(nZ,2),1,oMenu5:aItems[nZ]:cCaption,oMenu5:aItems[nZ]:bAction,oMenu5,Nil})
		Next

		// Progresso Fisico
		MENU oMenu6 POPUP
			MENUITEM STR0036 Action ClearAtalho() ,A310ViewBrw(@oTree,l410Visual,cArquivo),Eval(bRefresh) ,RestoreAtalho() //"Confirmacoes"
		ENDMENU
		For nZ	:=	1	To Len(oMenu6:aItems)
			AAdd(aMenuAt,{ATA_PROJ_PROG_FIS+"A"+STRZERO(nZ,2),1,oMenu6:aItems[nZ]:cCaption,oMenu6:aItems[nZ]:bAction,oMenu6,Nil})
		Next

		// Apontamentos
		MENU oMenu7 POPUP
			MENUITEM STR0037 Action ClearAtalho() ,PMS300RQ(@oTree,l410Visual,cArquivo) ,RestoreAtalho()//"Requisicoes"
			MENUITEM STR0038 Action ClearAtalho() ,PMS300NF(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Nota Fiscal de Entrada"
			MENUITEM STR0039 Action ClearAtalho() ,PMS300FID(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Despesas"
			MENUITEM STR0141 Action ClearAtalho() ,PMS300PRE(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Pre-Recursos"
			MENUITEM STR0142 Action ClearAtalho() ,PMS300APR(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Aprova Pre-Recursos"
			MENUITEM STR0040 Action ClearAtalho() ,PMS300REC(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Recursos"
			MENUITEM STR0041 Action ClearAtalho() ,PMS300D2(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Notas Fiscais de Saida"
			MENUITEM STR0042 Action ClearAtalho() ,PMS300FIR(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Receitas"
			If PmsSE5()
				MENUITEM STR0043 Action ClearAtalho() ,PMS300MOV(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Movimento Bancario"
			EndIf

			MENUITEM STR0167 Action ClearAtalho() ,PMS300ADI(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Apontamento direto"

		ENDMENU
		For nZ	:=	1	To Len(oMenu7:aItems)
			AAdd(aMenuAt,{ATA_PROJ_APONT+"A"+STRZERO(nZ,2),1,oMenu7:aItems[nZ]:cCaption,oMenu7:aItems[nZ]:bAction,oMenu7,Nil})
		Next
		/*aMenu := { 	{STR0086,{||oMenu2:Activate(5,100,oDlg) }},; //"&Ferramentas"
					{STR0087,{||oMenu3:Activate(75,100,oDlg) }},; //"&Consultas"
					{STR0088,{||A200CtrMenu(@oMenu,oTree,l410Visual,cArquivo,oMenu2,nDlgPln),oMenu:Activate(150,100,oDlg) }}} //"&Estrutura"*/

		// alteracao, inclusao

		If !lFWGetVersao .or. (GetVersao(.F.) == "P10")

			If nDlgPln == PMS_VIEW_SHEET
				// modo planilha
				aMenu := {;
				         {TIP_PROJ_INFO,      {||ClearAtalho() ,PmsPrjInf() ,RestoreAtalho()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
				         {TIP_COLUNAS,        {||ClearAtalho() ,Iif(lChgCols := PMC200Cfg("",0,0),oDlg:End(),Nil) ,RestoreAtalho()}, BMP_COLUNAS, TOOL_COLUNAS},;
				         {TIP_FERRAMENTAS,    {||A200CtrMenu(@oMenu,oTree,l410Visual,cArquivo,oMenu2,nDlgPln),oMenu2:Activate(105, 45,oDlg) }, BMP_FERRAMENTAS, TOOL_FERRAMENTAS},; //"&Ferramentas"
				         {TIP_FILTRO,         {||ClearAtalho() ,If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) ,RestoreAtalho()}, BMP_FILTRO, TOOL_FILTRO},;
				         {TIP_PROJ_CONSULTAS, {||oMenu3:Activate(170, 45,oDlg)}, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},; //"&Consultas"
				         {TIP_PROJ_ESTRUTURA, {||A200CtrMenu(@oMenu,oTree,l410Visual,cArquivo,oMenu2,nDlgPln),oMenu:Activate(215, 45,oDlg) }, BMP_PROJ_ESTRUTURA, TOOL_PROJ_ESTRUTURA},; //"&Estrutura"
				         {TIP_DOCUMENTOS,     {||A230CtrMenu(@oMenu4,@oTree,l410Visual,cArquivo),oMenu4:Activate(175, 45,oDlg) }, BMP_DOCUMENTOS, TOOL_DOCUMENTOS},; //"&Documentos"
				         {TIP_PROJ_EXECUCAO,  {||A200CtrMenu(@oMenu,oTree,l410Visual,cArquivo,oMenu2,nDlgPln),oMenu5:Activate(260, 45,oDlg)}, BMP_PROJ_EXECUCAO, TOOL_PROJ_EXECUCAO},; //"E&xecucao"
				         {TIP_PROJ_PROG_FIS,  {||A310CtrMenu(@oMenu6,oTree,l410Visual,cArquivo),oMenu6:Activate(305, 45,oDlg)}, BMP_PROJ_PROG_FIS, TOOL_PROJ_PROG_FIS},; //"Prg.Fisico"
				         {TIP_PROJ_APONT,     {||A300CtrMenu(@oMenu7,oTree,cArquivo),oMenu7:Activate(350, 45,oDlg)}, BMP_PROJ_APONT, TOOL_PROJ_APONT}} //"Ap&ontamentos"

			Else
				// modo arvore
				aMenu := {;
				         {TIP_PROJ_INFO,     	{||ClearAtalho() ,PmsPrjInf() ,RestoreAtalho()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
				         {TIP_FERRAMENTAS,   	{||A200CtrMenu(@oMenu,oTree,l410Visual,cArquivo,oMenu2,nDlgPln),oMenu2:Activate(105, 45,oDlg) }, BMP_FERRAMENTAS, TOOL_FERRAMENTAS},; //"&Ferramentas"
				         {TIP_FILTRO,        	{||ClearAtalho() ,If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) ,RestoreAtalho()}, BMP_FILTRO, TOOL_FILTRO},;
				         {TIP_PROJ_CONSULTAS,	{||oMenu3:Activate(85, 45,oDlg) }, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},; //"&Consultas"
				         {TIP_PROJ_ESTRUTURA,	{||A200CtrMenu(@oMenu,oTree,l410Visual,cArquivo,oMenu2,nDlgPln),oMenu:Activate(130, 45,oDlg) }, BMP_PROJ_ESTRUTURA, TOOL_PROJ_ESTRUTURA},; //"&Estrutura"
				         {TIP_DOCUMENTOS,    	{||A230CtrMenu(@oMenu4,@oTree,l410Visual,cArquivo),oMenu4:Activate(175, 45,oDlg) }, BMP_DOCUMENTOS, TOOL_DOCUMENTOS},; //"&Documentos"
				         {TIP_PROJ_EXECUCAO, 	{||A220CtrMenu(@oMenu5,oTree,l410Visual, cArquivo),oMenu5:Activate(220, 45,oDlg) }, BMP_PROJ_EXECUCAO, TOOL_PROJ_EXECUCAO},; //"E&xecucao"
				         {TIP_PROJ_PROG_FIS, 	{||A310CtrMenu(@oMenu6,oTree,l410Visual, cArquivo),oMenu6:Activate(265, 45,oDlg) }, BMP_PROJ_PROG_FIS, TOOL_PROJ_PROG_FIS},; //"Prg.Fisico"
				         {TIP_PROJ_APONT,    	{||A300CtrMenu(@oMenu7,oTree,cArquivo),oMenu7:Activate(310, 45,oDlg)}, BMP_PROJ_APONT, TOOL_PROJ_APONT}} //"Ap&ontamentos"

			EndIf

	    Else
			//Acoes relacionadas
			If nDlgPln == PMS_VIEW_SHEET
				// modo planilha
				aMenu := {;
						{TIP_PROJ_INFO,      {||ClearAtalho() ,PmsPrjInf() ,RestoreAtalho()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
						{TIP_COLUNAS,        {||ClearAtalho() ,Iif(lChgCols := PMC200Cfg("",0,0),oDlg:End(),Nil) ,RestoreAtalho()}, BMP_COLUNAS, TOOL_COLUNAS},;
						{TIP_FERRAMENTAS,    {||A200CtrMenu(@oMenu,oTree,l410Visual,cArquivo,oMenu2,nDlgPln),oMenu2:Activate(nScreVal1, nScreVal2,oDlg) }, BMP_FERRAMENTAS, TOOL_FERRAMENTAS},; //"&Ferramentas"
						{TIP_FILTRO,         {||ClearAtalho() ,If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) ,RestoreAtalho()}, BMP_FILTRO, TOOL_FILTRO},;
						{TIP_PROJ_CONSULTAS, {||oMenu3:Activate(nScreVal1, nScreVal2,oDlg)}, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},; //"&Consultas"
						{TIP_PROJ_ESTRUTURA, {||A200CtrMenu(@oMenu,oTree,l410Visual,cArquivo,oMenu2,nDlgPln),oMenu:Activate(nScreVal1, nScreVal2,oDlg) }, BMP_PROJ_ESTRUTURA, TOOL_PROJ_ESTRUTURA},; //"&Estrutura"
						{TIP_DOCUMENTOS,     {||A230CtrMenu(@oMenu4,@oTree,l410Visual,cArquivo),oMenu4:Activate(nScreVal1, nScreVal2,oDlg) }, BMP_DOCUMENTOS, TOOL_DOCUMENTOS},; //"&Documentos"
						{TIP_PROJ_EXECUCAO,  {||A200CtrMenu(@oMenu,oTree,l410Visual,cArquivo,oMenu2,nDlgPln),oMenu5:Activate(nScreVal1, nScreVal2,oDlg)}, BMP_PROJ_EXECUCAO, TOOL_PROJ_EXECUCAO},; //"E&xecucao"
						{TIP_PROJ_PROG_FIS,  {||A310CtrMenu(@oMenu6,oTree,l410Visual,cArquivo),oMenu6:Activate(nScreVal3, nScreVal4,oDlg)}, BMP_PROJ_PROG_FIS, TOOL_PROJ_PROG_FIS},; //"Prg.Fisico"
						{TIP_PROJ_APONT,     {||A300CtrMenu(@oMenu7,oTree,cArquivo),oMenu7:Activate(nScreVal1, nScreVal2,oDlg)}, BMP_PROJ_APONT, TOOL_PROJ_APONT}} //"Ap&ontamentos"

			Else
				// modo arvore
				aMenu := {;
						{TIP_PROJ_INFO,     	{||ClearAtalho() ,PmsPrjInf() ,RestoreAtalho()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
						{TIP_FERRAMENTAS,   	{||A200CtrMenu(@oMenu,oTree,l410Visual,cArquivo,oMenu2,nDlgPln),oMenu2:Activate(nScreVal1, nScreVal2,oDlg) }, BMP_FERRAMENTAS, TOOL_FERRAMENTAS},; //"&Ferramentas"
						{TIP_FILTRO,        	{||ClearAtalho() ,If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) ,RestoreAtalho()}, BMP_FILTRO, TOOL_FILTRO},;
						{TIP_PROJ_CONSULTAS,	{||oMenu3:Activate(nScreVal1, nScreVal2,oDlg) }, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},; //"&Consultas"
						{TIP_PROJ_ESTRUTURA,	{||A200CtrMenu(@oMenu,oTree,l410Visual,cArquivo,oMenu2,nDlgPln),oMenu:Activate(nScreVal1, nScreVal2,oDlg) }, BMP_PROJ_ESTRUTURA, TOOL_PROJ_ESTRUTURA},; //"&Estrutura"
						{TIP_DOCUMENTOS,    	{||A230CtrMenu(@oMenu4,@oTree,l410Visual,cArquivo),oMenu4:Activate(nScreVal1, nScreVal2,oDlg) }, BMP_DOCUMENTOS, TOOL_DOCUMENTOS},; //"&Documentos"
						{TIP_PROJ_EXECUCAO, 	{||A220CtrMenu(@oMenu5,oTree,l410Visual, cArquivo),oMenu5:Activate(nScreVal1, nScreVal2,oDlg) }, BMP_PROJ_EXECUCAO, TOOL_PROJ_EXECUCAO},; //"E&xecucao"
						{TIP_PROJ_PROG_FIS, 	{||A310CtrMenu(@oMenu6,oTree,l410Visual, cArquivo),oMenu6:Activate(nScreVal1, nScreVal2,oDlg) }, BMP_PROJ_PROG_FIS, TOOL_PROJ_PROG_FIS},; //"Prg.Fisico"
						{TIP_PROJ_APONT,    	{||A300CtrMenu(@oMenu7,oTree,cArquivo),oMenu7:Activate(nScreVal1, nScreVal2,oDlg)}, BMP_PROJ_APONT, TOOL_PROJ_APONT}} //"Ap&ontamentos"
			EndIf
		Endif

	Else

		MENU oMenu3 POPUP
			MENUITEM STR0138 ACTION ClearAtalho() ,MsAguarde({|| PmsAponRec(oTree,cArquivo)}) ,RestoreAtalho() //'Apontamento de recursos'
			MENUITEM STR0020 ACTION ClearAtalho() ,PmsDlgAF8Gnt(cRevisa,aConfig,@oDlg,@oTree,cArquivo) ,RestoreAtalho() //"Grafico de gantt..."
			MENUITEM STR0021 ACTION ClearAtalho() ,PmsDlgAF8Rec(cRevisa,@oTree,cArquivo) ,RestoreAtalho() //"Alocacao dos recursos do projeto..."
			MENUITEM STR0021+STR0104 ACTION ClearAtalho() ,Pms200View(STR0021+STR0104,{|| PMSC110(AF8->AF8_PROJET,cRevisa,,,@oTree,cArquivo) }) ,RestoreAtalho() //"Alocacao dos recursos por periodo..."
			MENUITEM STR0121 ACTION ClearAtalho() ,Pms200View(STR0121,{|| PMSC112(AF8->AF8_PROJET,cRevisa,@oTree,cArquivo) }) ,RestoreAtalho()  //"Alocacao dos recursos do projeto por equipe por periodo..."###"Alocacao dos recursos do projeto por equipe por periodo..."
			MENUITEM STR0097 ACTION ClearAtalho() ,PmsDlgAF8Eqp(cRevisa,@oTree,cArquivo) ,RestoreAtalho()  //"Alocacao de equipes do projeto..."
			MENUITEM STR0097+STR0104 ACTION ClearAtalho() ,Pms200View(STR0097+STR0104,{||PMSC115(AF8->AF8_PROJET,cRevisa,@oTree,cArquivo) }) ,RestoreAtalho() //"Alocacao de equipes por periodo..."
			MENUITEM STR0130 ACTION ClearAtalho() ,Processa({|| PmsRedeRel(oTree,cArquivo)}) ,RestoreAtalho() //"Redes de relacionamentos"
			If lCalcTrib
				MENUITEM STR0161 ACTION ClearAtalho() ,PmsDlgAN9Vis(),RestoreAtalho()  //"Tributos do Projeto"
	   		EndIf
		EndMenu
		For nZ	:=	1	To Len(oMenu3:aItems)
			AAdd(aMenuAt,{ATA_PROJ_CONSULTAS+"V"+STRZERO(nZ,2),1,oMenu3:aItems[nZ]:cCaption,oMenu3:aItems[nZ]:bAction,oMenu3,Nil})
		Next

		MENU oMenu POPUP
			MENUITEM STR0003 ACTION ClearAtalho() ,PMS200to201(2,@oTree,,cArquivo) ,RestoreAtalho() //"Visualizar"
			If nDlgPln == PMS_VIEW_TREE
				MENUITEM STR0099 ACTION ClearAtalho() ,Procurar(oTree, @cSearch, cArquivo) ,RestoreAtalho() //"Procurar..."
				MENUITEM STR0100 ACTION ClearAtalho() ,ProcurarP(oTree, @cSearch, cArquivo) ,RestoreAtalho() //"Procurar proxima"
			EndIf
		ENDMENU
		//Items exclusivos da visualizacao
		For nZ	:=	1	To Len(oMenu:aItems)
			AAdd(aMenuAt,{ATA_PROJ_ESTRUTURA+"V"+STRZERO(nZ,2),1,oMenu:aItems[nZ]:cCaption,oMenu:aItems[nZ]:bAction,oMenu,Nil})
		Next

		MENU oMenu4 POPUP
			MENUITEM STR0028 Action ClearAtalho() ,PMS230DC(@oTree,cArquivo),Eval(bRefresh) ,RestoreAtalho() //"Atualizar Documentos"
			MENUITEM STR0029 Action ClearAtalho() ,PMS230View(@oTree,@aDelObj,cArquivo) ,RestoreAtalho() //"Abrir Documento"
			MENUITEM STR0030 Action ClearAtalho() ,((SubStr(oTree:GetCargo(),1,3))->(dbGoto(Val(SubStr(oTree:GetCargo(),4,12)))),Ft340SavAs()) ,RestoreAtalho() //"Salvar Como"
			MENUITEM STR0002 Action ClearAtalho() ,PMSDocPesq(@oTree, AF8->AF8_PROJET, AF8->AF8_REVISA) ,RestoreAtalho() //"Pesquisar"
		ENDMENU
		For nZ	:=	1	To Len(oMenu4:aItems)
			AAdd(aMenuAt,{ATA_DOCUMENTOS+"V"+STRZERO(nZ,2),1,oMenu4:aItems[nZ]:cCaption,oMenu4:aItems[nZ]:bAction,oMenu4,Nil})
		Next

		MENU oMenu5 POPUP
			MENUITEM STR0031 Action ClearAtalho() ,PMS220CP(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Geren. Contrato de Parceria"
			MENUITEM STR0032 Action ClearAtalho() ,PMS220SC(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Geren. Solicitacao de Compras"
			MENUITEM STR0033 Action ClearAtalho() ,PMS220SA(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Geren. Solicitacao ao Almox."
			MENUITEM STR0034 Action ClearAtalho() ,PMS220OP(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Geren. Ordens de Producao"
			MENUITEM STR0035 Action ClearAtalho() ,PMS220EM(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Geren. Empenhos do Projeto"
		ENDMENU
		For nZ	:=	1	To Len(oMenu5:aItems)
			AAdd(aMenuAt,{ATA_PROJ_EXECUCAO+"V"+STRZERO(nZ,2),1,oMenu5:aItems[nZ]:cCaption,oMenu5:aItems[nZ]:bAction,oMenu5,Nil})
		Next

		MENU oMenu6 POPUP
			MENUITEM STR0036 Action ClearAtalho() ,A310ViewBrw(@oTree,l410Visual,cArquivo),Eval(bRefresh) ,RestoreAtalho() //"Confirmacoes"
		ENDMENU

		For nZ	:=	1	To Len(oMenu6:aItems)
			AAdd(aMenuAt,{ATA_PROJ_PROG_FIS+"V"+STRZERO(nZ,2),1,oMenu6:aItems[nZ]:cCaption,oMenu6:aItems[nZ]:bAction,oMenu6,Nil})
		Next

		MENU oMenu7 POPUP
			MENUITEM STR0037 Action ClearAtalho() ,PMS300RQ(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Requisicoes"
			MENUITEM STR0038 Action ClearAtalho() ,PMS300NF(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Nota Fiscal de Entrada"
			MENUITEM STR0039 Action ClearAtalho() ,PMS300FID(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Despesas"
			MENUITEM STR0141 Action ClearAtalho() ,PMS300PRE(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Pre-Recursos"
			MENUITEM STR0142 Action ClearAtalho() ,PMS300APR(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Aprova Pre-Recursos"
			MENUITEM STR0040 Action ClearAtalho() ,PMS300REC(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Recursos"
			MENUITEM STR0041 Action ClearAtalho() ,PMS300D2(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Notas Fiscais de Saida"
			MENUITEM STR0042 Action ClearAtalho() ,PMS300FIR(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Receitas"
			If PmsSE5()
				MENUITEM STR0043 Action ClearAtalho() ,PMS300MOV(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Movimento Bancario"
			EndIf

			MENUITEM STR0167 Action ClearAtalho() ,PMS300ADI(@oTree,l410Visual,cArquivo) ,RestoreAtalho() //"Apontamento direto"

		ENDMENU
		For nZ	:=	1	To Len(oMenu7:aItems)
			AAdd(aMenuAt,{ATA_PROJ_APONT+"V"+STRZERO(nZ,2),1,oMenu7:aItems[nZ]:cCaption,oMenu7:aItems[nZ]:bAction,oMenu7,Nil})
		Next
		// visualizacao

		If !lFWGetVersao .or. (GetVersao(.F.) == "P10")

			If nDlgPln == PMS_VIEW_SHEET
				// modo planilha
				aMenu := {;
				         {TIP_PROJ_INFO,      {||ClearAtalho() ,PmsPrjInf() ,RestoreAtalho()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
				         {TIP_COLUNAS,        {||ClearAtalho() ,Iif(lChgCols := PMC200Cfg("",0,0),oDlg:End(),Nil) ,RestoreAtalho()}, BMP_COLUNAS, TOOL_COLUNAS},;
				         {TIP_FILTRO,         {||ClearAtalho() ,If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) ,RestoreAtalho()}, BMP_FILTRO, TOOL_FILTRO},;
				         {TIP_PROJ_CONSULTAS, {||oMenu3:Activate(125, 45,oDlg)}, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},; //"&Consultas"
				         {TIP_PROJ_ESTRUTURA, {||A200CtrMenu(@oMenu,oTree,l410Visual,cArquivo,oMenu2,nDlgPln),oMenu:Activate(170, 45,oDlg) }, BMP_PROJ_ESTRUTURA, TOOL_PROJ_ESTRUTURA},; //"&Estrutura"
				         {TIP_PROJ_EXECUCAO,  {||A220CtrMenu(@oMenu5,oTree,l410Visual,cArquivo),oMenu5:Activate(215, 45,oDlg) }, BMP_PROJ_EXECUCAO, TOOL_PROJ_EXECUCAO},; //"E&xecucao"
				         {TIP_PROJ_PROG_FIS,  {||A310CtrMenu(@oMenu6,oTree,l410Visual,cArquivo),oMenu6:Activate(260, 45,oDlg) }, BMP_PROJ_PROG_FIS, TOOL_PROJ_PROG_FIS},; //"Prg.Fisico"
				         {TIP_PROJ_APONT,     {||A300CtrMenu(@oMenu7,oTree,cArquivo),oMenu7:Activate(305, 45,oDlg)}, BMP_PROJ_APONT, TOOL_PROJ_APONT}} //"Ap&ontamentos"
			Else
				// modo arvore
				aMenu := {;
				         {TIP_PROJ_INFO,       {||ClearAtalho() ,PmsPrjInf() ,RestoreAtalho()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
				         {TIP_FILTRO,          {||ClearAtalho() ,If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) ,RestoreAtalho()}, BMP_FILTRO, TOOL_FILTRO},;
				         {TIP_PROJ_CONSULTAS,  {||oMenu3:Activate(90, 45,oDlg) }, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},; //"&Consultas"
				         {TIP_PROJ_ESTRUTURA,  {||A200CtrMenu(@oMenu,oTree,l410Visual,cArquivo,oMenu2,nDlgPln),oMenu:Activate(125, 45,oDlg) }, BMP_PROJ_ESTRUTURA, TOOL_PROJ_ESTRUTURA},; //"&Estrutura"
				         {TIP_DOCUMENTOS,      {||A230CtrMenu(@oMenu4,@oTree,l410Visual,cArquivo),oMenu4:Activate(170, 45,oDlg) }, BMP_DOCUMENTOS, TOOL_DOCUMENTOS},; //"&Documentos"
				         {TIP_PROJ_EXECUCAO,   {||A220CtrMenu(@oMenu5,oTree,l410Visual,cArquivo),oMenu5:Activate(210, 45,oDlg) }, BMP_PROJ_EXECUCAO, TOOL_PROJ_EXECUCAO},; //"E&xecucao"
				         {TIP_PROJ_PROG_FIS,   {||A310CtrMenu(@oMenu6,oTree,l410Visual,cArquivo),oMenu6:Activate(255, 45,oDlg) }, BMP_PROJ_PROG_FIS, TOOL_PROJ_PROG_FIS},; //"Prg.Fisico"
				         {TIP_PROJ_APONT,      {||A300CtrMenu(@oMenu7,oTree,cArquivo),oMenu7:Activate(300, 45,oDlg)}, BMP_PROJ_APONT, TOOL_PROJ_APONT }} //"Ap&ontamentos"
			EndIf

	    Else
			//Acoes relacionada
			If nDlgPln == PMS_VIEW_SHEET
				// modo planilha
				aMenu := {;
						{TIP_PROJ_INFO,      {||ClearAtalho() ,PmsPrjInf() ,RestoreAtalho()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
						{TIP_COLUNAS,        {||ClearAtalho() ,Iif(lChgCols := PMC200Cfg("",0,0),oDlg:End(),Nil) ,RestoreAtalho()}, BMP_COLUNAS, TOOL_COLUNAS},;
						{TIP_FILTRO,         {||ClearAtalho() ,If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) ,RestoreAtalho()}, BMP_FILTRO, TOOL_FILTRO},;
						{TIP_PROJ_CONSULTAS, {||oMenu3:Activate(nScreVal1, nScreVal2,oDlg)}, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},; //"&Consultas"
						{TIP_PROJ_ESTRUTURA, {||A200CtrMenu(@oMenu,oTree,l410Visual,cArquivo,oMenu2,nDlgPln),oMenu:Activate(nScreVal1, nScreVal2,oDlg) }, BMP_PROJ_ESTRUTURA, TOOL_PROJ_ESTRUTURA},; //"&Estrutura"
						{TIP_PROJ_EXECUCAO,  {||A220CtrMenu(@oMenu5,oTree,l410Visual,cArquivo),oMenu5:Activate(nScreVal1, nScreVal2,oDlg) }, BMP_PROJ_EXECUCAO, TOOL_PROJ_EXECUCAO},; //"E&xecucao"
						{TIP_PROJ_PROG_FIS,  {||A310CtrMenu(@oMenu6,oTree,l410Visual,cArquivo),oMenu6:Activate(nScreVal1, nScreVal2,oDlg) }, BMP_PROJ_PROG_FIS, TOOL_PROJ_PROG_FIS},; //"Prg.Fisico"
						{TIP_PROJ_APONT,     {||A300CtrMenu(@oMenu7,oTree,cArquivo),oMenu7:Activate(nScreVal1, nScreVal2,oDlg)}, BMP_PROJ_APONT, TOOL_PROJ_APONT}} //"Ap&ontamentos"
			Else
				// modo arvore
				aMenu := {;
						{TIP_PROJ_INFO,       {||ClearAtalho() ,PmsPrjInf() ,RestoreAtalho()}, BMP_PROJ_INFO, TOOL_PROJ_INFO},;
						{TIP_FILTRO,          {||ClearAtalho() ,If(PmsCfgDlg(aConfig),Eval(bRefresh),Nil) ,RestoreAtalho()}, BMP_FILTRO, TOOL_FILTRO},;
						{TIP_PROJ_CONSULTAS,  {||oMenu3:Activate(nScreVal1, nScreVal5,oDlg) }, BMP_PROJ_CONSULTAS, TOOL_PROJ_CONSULTAS},; //"&Consultas"
						{TIP_PROJ_ESTRUTURA,  {||A200CtrMenu(@oMenu,oTree,l410Visual,cArquivo,oMenu2,nDlgPln),oMenu:Activate(nScreVal1, nScreVal2,oDlg) }, BMP_PROJ_ESTRUTURA, TOOL_PROJ_ESTRUTURA},; //"&Estrutura"
						{TIP_DOCUMENTOS,      {||A230CtrMenu(@oMenu4,@oTree,l410Visual,cArquivo),oMenu4:Activate(nScreVal1, nScreVal2,oDlg) }, BMP_DOCUMENTOS, TOOL_DOCUMENTOS},; //"&Documentos"
						{TIP_PROJ_EXECUCAO,   {||A220CtrMenu(@oMenu5,oTree,l410Visual,cArquivo),oMenu5:Activate(nScreVal1, nScreVal2,oDlg) }, BMP_PROJ_EXECUCAO, TOOL_PROJ_EXECUCAO},; //"E&xecucao"
						{TIP_PROJ_PROG_FIS,   {||A310CtrMenu(@oMenu6,oTree,l410Visual,cArquivo),oMenu6:Activate(nScreVal1, nScreVal2,oDlg) }, BMP_PROJ_PROG_FIS, TOOL_PROJ_PROG_FIS},; //"Prg.Fisico"
						{TIP_PROJ_APONT,      {||A300CtrMenu(@oMenu7,oTree,cArquivo),oMenu7:Activate(nScreVal1, nScreVal2,oDlg)}, BMP_PROJ_APONT, TOOL_PROJ_APONT }} //"Ap&ontamentos"
			EndIf
	    Endif
	EndIf

	If ExistBlock("PMA410MENU")   // ponto de entrada concebido originalmente para
		ExecBlock("PMA410MENU",.F.,.F.,{oTree,cArquivo,oDlg}) // manipular array aMenu - Alt.Estrutura PMSA410
	EndIf

	If ExistTemplate("PMA410MENU")   // ponto de entrada concebido originalmente para
		ExecTemplate("PMA410MENU",.F.,.F.,{oTree,cArquivo}) // manipular array aMenu - Alt.Estrutura PMSA410
	EndIf

	AAdd(aMenu, {STR0107,  {||ClearAtalho() ,SetAtalho(aMenuAt,aMenu,.T.) ,RestoreAtalho()}, "ATALHO", STR0107}) //"Atalhos"###"Atalhos"
	
	// le os atalhos desde o profile
	CarregaAtalhos(aMenu,aMenuAt,Iif(l410Visual,"V","A"))

	// configura as teclas de atalho
 	SetAtalho(aMenuAt,aMenu,.F.)

	If nDlgPln == PMS_VIEW_SHEET
		aCampos := {{"AF9_TAREFA","AFC_EDT",8,,,.F.,"",},{"AF9_DESCRI","AFC_DESCRI",55,,,.F.,"",150}}

		//
		// MV_PMSCPLN
		//
		// 1 - a configuração da planilha é utilizada exclusivamente pelo usuário que criou
		// 2 - a configuração da planilha é utilizada por qualquer usuário (default)
		//

		If GetNewPar("MV_PMSCPLN", 2) == 1
			A200Opn(@aCampos, "\profile\pmsa410." + __cUserID)
		Else
			A200Opn(@aCampos)
		EndIf

		PmsPlanAF8(cCadastro,cRevisa,aCampos,@cArquivo,,nFreeze,@lOk,aMenu,@oDlg,,,aConfig,,nIndent)
	Else
		If !lFWGetVersao .or. (GetVersao(.F.) == "P10" )
			bContext	:=	{|o,x,y| A200CtrMenu(@oMenu,oTree,l410Visual,cArquivo,oMenu2,nDlgPln),oMenu:Activate(x,y-50,oDlg) }
		Else
			bContext	:=	{|o,x,y| A200CtrMenu(@oMenu,oTree,l410Visual,cArquivo,oMenu2,nDlgPln),oMenu:Activate(nScreVal1,nScreVal2,oDlg) }
		Endif
		PmsDlgAF8(cCadastro,@oMenu,cRevisa,@oTree,"AF8,AFC,AF9,AFD,ACB",{|| A200CtrMenu(@oMenu,oTree,l410Visual,cArquivo,oMenu2,nDlgPln)},@lOk,,aMenu,@oDlg,aConfig,@cArquivo,,bContext)

	EndIf

	// grava os atalhos no profile
	GravaAtalhos(aMenuAt,Iif(l410Visual,"V","A"))

	If lChgCols
		PMS410Dlg(cAlias,nReg,nOpcx,cR1,cR2,cVers)
	Else

		If l410Exclui .And. lOk

			// verifica a existencia do ponto de entrada PMA200DEL
			If ExistBlock("PMA200DEL")
				lDelPrj:= ExecBlock("PMA200DEL",.F.,.F.,)
			EndIf

			// verifica se o conteudo do retorno é logico pois o retorno
			// foi implementado apos ser implementado o ponto de entrada
			If (ValType(lDelPrj) <> "L") .Or. lDelPrj
				Begin Transaction
					MaDelAF8(,AF8->(RecNo()))
				End Transaction
			EndIf
		EndIf
		MsDocExclui(aDelObj,.F.)
	EndIf
EndIf

If( valtype(oTempTbAN9) == "O")
	oTempTbAN9:Delete()
	freeObj(oTempTbAN9)
	oTempTbAN9 := nil
EndIf

//***************************
// Integração com o SIGAPCO *
//***************************
PcoFinLan("000350")

// destroi os objetos - Blindagem para garantir a destruicao dos objetos criados
PMSFreeObj(oMenu)
PMSFreeObj(oMenu2)
PMSFreeObj(oMenu3)
PMSFreeObj(oMenu4)
PMSFreeObj(oMenu5)
PMSFreeObj(oMenu6)
PMSFreeObj(oMenu7)
PMSFreeObj(oDlg)
PMSFreeObj(oTree)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS200ImpCo³ Autor ³Fabio Rogerio Pereira ³ Data ³ 15-03-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que importa a composicao no Projeto.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMS200ImpCMP                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PMS200ImpCom(nRecAF8,cNivelAtu,cCompos,nQuant,cTarefa,cEDTPAI,lCriaAF9,cItemAFA,cItemAFB)
Local aArea		:= GetArea()
Local aAreaAE1	:= AE1->(GetArea())
Local aAreaAE2	:= AE2->(GetArea())
Local aAreaAF9	:= AF9->(GetArea())
Local aAreaAE3	:= AE3->(GetArea())
Local aAreaAE4	:= AE4->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local aAuxHor   := {}
Local cNivelTrf	:= cNivelAtu
Local nRetAF9	:= 0
Local nAuxAF9   := 0
Local aCustoAF9

DEFAULT lCriaAF9 := .T.
DEFAULT cItemAFA := StrZero(0, TamSX3("AFA_ITEM")[1])
DEFAULT cItemAFB := StrZero(0, TamSX3("AFB_ITEM")[1])

dbSelectArea("AE1")
dbSetOrder(1)
If dbSeek(xFilial()+cCompos)
	If lCriaAF9
		cNivelTrf := Soma1(cNivelTrf,Len(cNivelTrf))
		RecLock("AF9",.T.)
		AF9->AF9_FILIAL := xFilial("AF2")
		AF9->AF9_PROJET := AF8->AF8_PROJET
		AF9->AF9_REVISA	:= AF8->AF8_REVISA
		AF9->AF9_CALEND := AF8->AF8_CALEND
		AF9->AF9_NIVEL	:= cNivelTrf
		AF9->AF9_TAREFA := PmsNumAF9(AF8->AF8_PROJET,AF8->AF8_REVISA,cNivelAtu,cEDTPAI)
		AF9->AF9_DESCRI	:= AE1->AE1_DESCRI
		AF9->AF9_UM		:= AE1->AE1_UM
		AF9->AF9_QUANT	:= nQuant
		AF9->AF9_TPMEDI	:= "4"
		AF9->AF9_EDTPAI := cEDTPAI

		aAuxHor	:= PMSDTaskF(AF8->AF8_START,AF9->AF9_HORAI,AF9->AF9_CALEND,AF9->AF9_HDURAC,AF9->AF9_PROJET,Nil)
		AF9->AF9_START := aAuxHor[1]
		AF9->AF9_HORAI := aAuxHor[2]
		AF9->AF9_FINISH:= aAuxHor[3]
		AF9->AF9_HORAF := aAuxHor[4]
		AF9->AF9_COMPOS := cCompos

		MsUnlock()

		nRetAF9	:= RecNo()

		PmsAvalTrf("AF9",1)
	EndIf

	dbSelectArea("AE2")
	dbSetOrder(1)
	dbSeek(xFilial()+cCompos)
	While !Eof() .And. xFilial()+cCompos == AE2->AE2_FILIAL+AE2->AE2_COMPOS
		cItemAFA := Soma1(cItemAFA)
		SB1->(dbSeek(xFilial()+AE2->AE2_PRODUT))
		RecLock("AFA",.T.)
		AFA->AFA_FILIAL := xFilial("AFA")
		AFA->AFA_PROJET := AF9->AF9_PROJET
		AFA->AFA_REVISA	:= AF9->AF9_REVISA
		AFA->AFA_TAREFA := AF9->AF9_TAREFA
		AFA->AFA_ITEM	:= cItemAFA
		AFA->AFA_PRODUT := AE2->AE2_PRODUT
		AFA->AFA_QUANT	:= PmsAFAQuant(AFA->AFA_PROJET,AFA->AFA_REVISA,AFA->AFA_TAREFA,AFA->AFA_PRODUT,nQuant,AE2->AE2_QUANT,AF9->AF9_HDURAC,.T.)
		AFA->AFA_MOEDA	:= Val(RetFldProd(SB1->B1_COD,"B1_MCUSTD"))
		AFA->AFA_CUSTD	:= RetFldProd(SB1->B1_COD,"B1_CUSTD")
		AFA->AFA_ACUMUL	:= "3"
		AFA->AFA_DATPRF := AF9->AF9_START
		AFA->AFA_COMPOS := cCompos

		MsUnlock()
		dbSelectArea("AE2")
		dbSkip()
	End

	dbSelectArea("AE3")
	dbSetOrder(1)
	dbSeek(xFilial()+cCompos)
	While !Eof() .And. xFilial()+cCompos == AE3->AE3_FILIAL+AE3->AE3_COMPOS
		cItemAFB := Soma1(cItemAFB)
		RecLock("AFB",.T.)
		AFB->AFB_FILIAL := xFilial("AF4")
		AFB->AFB_PROJET := AF9->AF9_PROJET
		AFB->AFB_REVISA	:= AF9->AF9_REVISA
		AFB->AFB_ITEM	:= cItemAFB
		AFB->AFB_TAREFA := AF9->AF9_TAREFA
		AFB->AFB_DESCRI	:= AE3->AE3_DESCRI
		AFB->AFB_MOEDA	:= AE3->AE3_MOEDA
		AFB->AFB_VALOR	:= PmsAFBValor(nQuant,AE3->AE3_VALOR,.T.)
		AFB->AFB_TIPOD	:= AE3->AE3_TIPOD
		AFB->AFB_DATPRF := AF9->AF9_START
		AFB->AFB_ACUMUL := "3" //Rateado
		AFB->AFB_COMPOS := cCompos

		MsUnlock()
    	dbSelectArea("AE3")
		dbSkip()
	End

	// grava o custo da tarefa
	aCustoAF9:= PMSAF9CusTrf(,AF8->AF8_PROJET,AF8->AF8_REVISA,AF9->AF9_TAREFA)
	RecLock("AF9",.F.)
	AF9->AF9_CUSTO := aCustoAF9[1]
	AF9->AF9_CUSTO2:= aCustoAF9[2]
	AF9->AF9_CUSTO3:= aCustoAF9[3]
	AF9->AF9_CUSTO4:= aCustoAF9[4]
	AF9->AF9_CUSTO5:= aCustoAF9[5]
	MsUnLock()

	// verifica a existencia do ponto de entrada PMA200IMP
	If ExistBlock("PMA200IMP")
		ExecBlock("PMA200IMP",.F.,.F.,{cCompos})
	EndIf

	// verifica a existencia do ponto de entrada PMA200IMP no Template
	If ExistTemplate("PMA200IMP")
		ExecTemplate("PMA200IMP",.F.,.F.,{cCompos})
	EndIf

	dbSelectArea("AE4")
	dbSetOrder(1)
	dbSeek(xFilial()+cCompos)
	While !Eof() .And. xFilial()+cCompos == AE4->AE4_FILIAL+AE4->AE4_COMPOS
		nAuxAF9 := PMS200ImpCom(nRecAF8,cNivelTrf,AE4->AE4_SUBCOM,AE4->AE4_QUANT*nQuant,PmsNumAFC(AFC->AFC_PROJET,AFC->AFC_REVISA,cNivelAtu,cEDTPAI),cEDTPAI,.F.,@cItemAFA,@cItemAFB)
		dbSelectArea("AE4")
		dbSkip()
	End
EndIf

RestArea(aAreaAF9)
RestArea(aAreaAE1)
RestArea(aAreaAE2)
RestArea(aAreaAE3)
RestArea(aAreaAE4)
RestArea(aAreaSB1)
RestArea(aArea)

Return nRetAF9


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
nDlgPln := mv_par01
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS410Rev³ Autor ³ Edson Maricate         ³ Data ³ 04-12-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa controle do gerenciamento de revisoes do projeto.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS410Rev(cAlias,nReg,nOpcx)

Local oMenu
Local aArea	:= GetArea()
Local lFWGetVersao := .T.
Local nScreVal1 := 775 // variaveis para posicionamento do popup menu
Local nScreVal2 := 23  // variaveis para posicionamento do popup menu
Local aScreens := {}   // variaveis para posicionamento do popup menu
If cPaisLoc == 'RUS'
	//Valores para a Russia, posicionado a direita
	//Change popup menu localization, using the screen resolution to position on right
	aScreens := getScreenRes()
	nScreVal1 := RU99XFUN15()[1] // GetRusPopupMenuPos
	nScreVal2 := RU99XFUN15()[2] // GetRusPopupMenuPos
EndIf

SaveInter()

MENU oMenu POPUP
	MENUITEM STR0087 ACTION (oMenu:End(),PMSA210(2)) //"Historico"
	MENUITEM STR0088 ACTION PMSA210(3) //"Iniciar Revisao"
	MENUITEM STR0089 ACTION PMSA210(4) //"Finalizar Revisao"
	MENUITEM STR0090 ACTION PMSA210(5) //"Comparar"
	MENUITEM STR0091 ACTION PMSA210(6) //"Usuario Revisao"
ENDMENU

If !lFWGetVersao .or. (GetVersao(.F.) == "P10" )
	If SetMDIChild()
		oMenu:Activate(660,540,oMainWnd)
	Else
		oMenu:Activate(82,140,oMainWnd)
	EndIf

Else
	//Acoes relacionadas
	If SetMDIChild()
		oMenu:Activate(nScreVal1,nScreVal2,oMainWnd)
	Else
		oMenu:Activate(nScreVal1,nScreVal2,oMainWnd)
	EndIf
Endif

RestInter()
RestArea(aArea)
dbSelectArea("AF8")
aCores  := PmsAF8Color()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS410Int³ Autor ³ Adriano Ueda           ³ Data ³ 16-12-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de integracao com o Microsoft Project.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS410Int(cAlias,nReg,nOpcx)

Local oMenu
Local aArea	:= GetArea()
Local lFWGetVersao := .T.
Local nScreVal1 := 790 // variaveis para posicionamento do popup menu
Local nScreVal2 := 770  // variaveis para posicionamento do popup menu
Local aScreens := {}   // variaveis para posicionamento do popup menu
//Incluido variaveis para posicionamento do Popup Menu, pois na russia o mesmo deverá ficar posicioando abaixo do menu a direita
If cPaisLoc == 'RUS'
	//Valores para a Russia, posicionado a direita
	//Change popup menu localization, using the screen resolution to position on right
	aScreens := getScreenRes()
	nScreVal1 := aScreens[1]-215
	nScreVal2 := 53
EndIf

SaveInter()

// Microsoft Project - pmsc010
// Importacao .csv - pmsa001
// Exportacao .csv - pmsa002

MENU oMenu POPUP
	MENUITEM STR0092 ACTION (oMenu:End(),PMC010Export(cAlias, nReg, nOpcx)) //"Exportar"
	MENUITEM STR0093 ACTION PMC010Sinc(cAlias, nReg, nOpcx) //"Sincronizar"
	MENUITEM STR0094 ACTION PMSA001() //"Importacao .csv"
	MENUITEM STR0095 ACTION PMSA002() //"Exportacao .csv"
	If HasTemplate("CCT") .and. ExistTemplate("CCTA005")
		MENUITEM STR0154 ACTION ExecTemplate("CCTA005",.F.,.F.,{2}) //"Imp. Comp. Un. .csv"
		MENUITEM STR0155 ACTION ExecTemplate("CCTA005",.F.,.F.,{1}) //"Exp. Comp. Un. .csv"
	EndIf
ENDMENU

If !lFWGetVersao .or. (GetVersao(.F.) == "P10" )

	If SetMDIChild()
		oMenu:Activate(835,565,oMainWnd)
	Else
		oMenu:Activate(82,190,oMainWnd)
	EndIf

Else
	//Acoes relacionadas
	If SetMDIChild()
		oMenu:Activate(nScreVal1,nScreVal2,oMainWnd)
	Else
		oMenu:Activate(nScreVal1,nScreVal2,oMainWnd)
	EndIf
Endif

RestInter()
RestArea(aArea)
dbSelectArea("AF8")
aCores  := PmsAF8Color()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SetAtalhosºAutor  ³Bruno Sobieski      ºFecha ³  05-31-05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para configurar os atalhos de usuario para a rotina  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA410                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SetAtalho(aMenuAt,aMenu,lTela)
Local oDlg
LOcal aObjects	:=	{}
Local aSize    	:= MsAdvSize(.T.)
Local aDados	:=	{}
Local nX:= 1
Local nY:= 1

aSort(aMenuAt,,,{|x,y| x[1] < y[1]})

For nX:=1 To Len(aMenuAt)
	AAdd(aDados,{Space(3*aMenuAt[nX][2])+aMenuAt[nX][3],If(aMenuAt[nX][6]==Nil.Or.Empty(aMenuAt[nX][6]),"CTRL+ ",aMenuAt[nX][6]),aMenuAt[nX][3],aMenuAt[nX][4]})
Next

If lTela .And. !Empty(aDados)

	DEFINE FONT oFnt  NAME "Arial" SIZE 08,14 BOLD

	aAdd( aObjects, { 100, 100, .T., .T., .T. } )

	aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 }
	aPosObj:= MsObjSize( aInfo, aObjects, .T.,.F. )
	
	DEFINE MSDIALOG oDlg TITLE STR0108 FROM 0,0 TO 550,760 OF oMainWnd PIXEL  //"Configuracao de atalhos do usuario"
               
	@ aPosObj[1,1] + 24,04 To 38,318 Pixel Of  oDlg LABEL ""
	@ aPosObj[1,1] + 04,08 SAY OemToAnsi(STR0109+; //"Fa‡a duplo click na op‡ao desejada para configurar a tecla de atalho."
								STR0110) SIZE 300,16 COLOR CLR_BLUE FONT oFnt Of oDlg PIXEL  //" Esta configura‡ao de atalhos e exclusiva para cada usu rio do sistema e para as rotinas de visulizacao e modificacao."
								//39,4,14,200											//180,35
	oBrowse := TWBrowse():New( aPosObj[1,1]+19,4, aPosObj[1,1]+ 340,200,,{STR0111,"Acesso Directo"},{ aPosObj[1,1]+160,35},oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,, ) //"Opcao"###"Atalhos"
	oBrowse:nFreeze	:=	1
	oBrowse:SetArray(aDados)
	oBrowse:bLine	:=	{|| {aDados[oBrowse:nAt][1],aDados[oBrowse:nAt][2]}}
	oBrowse:bLDblClick	:=	{|| EditAtalho(aDados,oBrowse) }
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End() },{||oDlg:End()} ) CENTERED
Endif

// limpar os atalhos das teclas CONTROL
ClearAtalho()
aBAtalhos	:=	{}

// setar os atalhos das teclas CONTROL
For nX := 1 To Len(aDados)
	If !Empty(Substr(aDados[nX][2],6,1))
		AAdd(aBAtalhos,{Asc(Substr(aDados[nX][2],6,1))-64 ,aDados[nX][4]})
		bBlocoAtalho	:=	&("{|| IIf(lEmAtalho,Nil,(lEmAtalho:=.T.,Eval(aBAtalhos["+Str(Len(aBAtalhos))+",02]),lEmAtalho:=.F.))}")
		SetKey(aBAtalhos[Len(aBAtalhos) ,01] ,bBlocoAtalho)
		nPosM		:=	Ascan(aMenuAt,{|X| X[3] == aDados[nX][3]})
		aMenuAt[nPosM][6]	:=	aDados[nX][2]
	Else
		nPosM		:=	Ascan(aMenuAt,{|X| X[3] == aDados[nX][3]})
		aMenuAt[nPosM][6]	:=	""
	Endif
Next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EditAtalhoºAutor  ³Bruno Sobieski      ºFecha ³  05-31-05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para editara a celula de configuracao dos atalhos.   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA410                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EditAtalho(aDados,oBrowse)
Local lSair	:=	.F.
Local nX			:= 0
Private nLastKey :=0
cValAnt	:=	aDados[oBrowse:nAt][2]
cPicture	:=	"@!"
While !lSair
	lValid	:=	lEditCell(aDados,oBrowse,cPicture,2)
	If lValid
		If (SubStr(aDados[oBrowse:nAt][2],1,5) != 'CTRL+')
			aDados[oBrowse:nAt][2] := SubStr('CTRL+' + aDados[oBrowse:nAt][2],1,6)
		EndIf
		If Substr(aDados[oBrowse:nAt][2],6,1) == "O" .Or. Substr(aDados[oBrowse:nAt][2],6,1) == "X" .Or.;
			Substr(aDados[oBrowse:nAt][2],6,1) == "C" .Or. Substr(aDados[oBrowse:nAt][2],6,1) == "V"
			Aviso(STR0113,OemToAnsi(STR0114),{STR0115}) //"Nao permitido"###"Este atalho ‚ reservado pelo sistema."###"Ok"
			aDados[oBrowse:nAt][2]	:=	Space(6)
		//VErificar se existe algum outro menu para este atalho
		ElseIf Substr(aDados[oBrowse:nAt][2],6,1)<> " " .And. !IsAlpha(Substr(aDados[oBrowse:nAt][2],6,1))
			Aviso(STR0113,OemToAnsi(STR0116),{STR0115}) //"Nao permitido"###"Somente letras sao permitidas."###"Ok"
			aDados[oBrowse:nAt][2]	:=	Space(6)
		ElseIf cValAnt	<>	aDados[oBrowse:nAt][2] .And. !Empty(aDados[oBrowse:nAt][2])
			lSair	:=	.T.
			For nX := 1 To Len(aDados)
				If nX <> oBrowse:nAt	.And. aDados[oBrowse:nAt][2] == aDados[nX][2]
					If Aviso(STR0117,STR0118+ aDados[oBrowse:nAt][1]+"'."+CRLF+STR0119,{STR0120,STR0112},2) == 1 //"Confirmacao"###"Este atalho ja esta definido para a funcao '"###"Deseja reconfigurar?."###"Sim"###"Nao"
						aDados[nX][2]	:=	"CTRL+ "
						lSair	:=	.T.
						Exit
					Else
						lSair	:=	.F.
						aDados[oBrowse:nAt][2] := cValAnt
						Exit
					Endif
				Endif
			Next
		ElseIf cValAnt ==	aDados[oBrowse:nAt][2]
			lSair	:=	.T.
		Endif
	ElseIf cValAnt ==	aDados[oBrowse:nAt][2]
		lSair	:=	.T.
	ElseIf Empty(Substr(aDados[oBrowse:nAt][2],6,1))
		aDados[oBrowse:nAt][2]	:=	"CTRL+ "
		lSair	:=	.T.
	Endif
Enddo
oBrowse:Refresh()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GravaAtalhºAutor  ³Bruno Sobieski      ºFecha ³  05-31-05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para gravar os atalhos configurados no perfil de cadaº±±
±±º          ³ usuario.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA410                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GravaAtalhos(aMenuAt,cChave)
Local nX
Local cList	:=	""
psworder(1)
PswSeek(__cUSerID)
aRet      := PswRet(1)
cUsrName := aRet[1][2]

For nX	:=	1	To Len(aMenuAt)
	If aMenuAt[nX][6] <> Nil .And. !Empty(aMenuAt[nX][6])
		cList += aMenuAt[nX][1]+"|"+aMenuAt[nX][6]+"|"+CRLF // string do conteudo do aMenuAt a ser gravado no memo do Profile.usr
	Endif
Next
If FindProfDef( cUsrName, FunName(),"MENUBAR"+cChave, "PMSTREE" )
	WriteProfDef(cUsrName, FunName(), "MENUBAR"+cChave, "PMSTREE" , cUsrName, FunName(), "MENUBAR"+cChave, "PMSTREE" , cList )
Else
	WriteNewProf( cUsrName, FunName(), "MENUBAR"+cChave, "PMSTREE" , cList )
Endif

// limpar os atalhos das teclas CONTROL
ClearAtalho()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LeAtalhos ºAutor  ³Bruno Sobieski      ºFecha ³  05-31-05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para LER os atalhos gravados no perfil de cada       º±±
±±º          ³ usuario.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA410                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function LeAtalhos(aMenuAt,cChave)
Local cMemoProf:=""
Local cElem1	:=	""
Local cElem2	:=	""
Local nPos		:=	0
Local nTamMemo	:=	0
Local nX	:=	0
psworder(1)
PswSeek(__cUSerID)
aRet      := PswRet(1)
cUsrName := aRet[1][2]

//Carrega profile do usuario (Atalhos)
If FindProfDef( cUsrName, FunName(), "MENUBAR"+cChave, "PMSTREE" )
	cMemoProf := RetProfDef(cUsrName,FunName() ,"MENUBAR"+cChave, "PMSTREE" )
	nTamMemo  := MLCount(cMemoProf,20)
	For nX := 1 To nTamMemo
		nPos := At ("|",MemoLine(cMemoProf,20,nX))
		If nPos > 0
			cElem1 := Left(MemoLine(cMemoProf,20,nX),nPos-1 )
			cElem2 := Substr(MemoLine(cMemoProf,20,nX),nPos+1,6 )
			nPosM	:=	Ascan(aMenuAt,{|x| x[1] == cElem1 })
			If nPosM > 0
				aMenuAt[nPosM][6]		:=	cElem2
			Endif
		Endif
	Next nX
Endif
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CarregaAtaºAutor  ³Bruno Sobieski      ºFecha ³  05-31-05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para definir os codigos dos atalhos de cada rotina   º±±
±±º          ³ dos menues.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA410                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CarregaAtalhos(aMenu,aMenuAt,cChave)
Local nX	:=	1
Local cOpc
For nX := 1 To Len(aMenu)
	cOpc := ""
	Do Case
		Case aMenu[nX][1]	==	TIP_PROJ_INFO
			cOpc	:=		ATA_PROJINFO
		Case aMenu[nX][1]	==	TIP_COLUNAS
			cOpc	:=		ATA_COLUNAS
		Case aMenu[nX][1]	==	TIP_FERRAMENTAS
			cOpc	:=		ATA_FERRAMENTAS
		Case aMenu[nX][1]	==	TIP_FILTRO
			cOpc	:=		ATA_FILTRO
		Case aMenu[nX][1]	==	TIP_PROJ_CONSULTAS
			cOpc	:=		ATA_PROJ_CONSULTAS
		Case aMenu[nX][1]	==	TIP_PROJ_ESTRUTURA
			cOpc	:=		ATA_PROJ_ESTRUTURA
		Case aMenu[nX][1]	==	TIP_PROJ_EXECUCAO
			cOpc	:=		ATA_PROJ_EXECUCAO
		Case aMenu[nX][1]	==	TIP_PROJ_PROG_FIS
			cOpc	:=		ATA_PROJ_PROG_FIS
		Case aMenu[nX][1]	==	TIP_PROJ_APONT
			cOpc	:=		ATA_PROJ_APONT
		Case aMenu[nX][1]	==	TIP_ORC_ESTRUTURA
			cOpc	:=		ATA_PROJ_ESTRUTURA
		Case aMenu[nX][1]	==	TIP_DOCUMENTOS
			cOpc	:=		ATA_DOCUMENTOS

	EndCase
	If !Empty(cOpc)
		AAdd(aMenuAt,{cOpc+cChave+"00",0,aMenu[nX][1],aMenu[nX][2],Nil,Nil})
	EndIf
Next

//A opção Atalhos sempre deve estar disponível
AAdd(aMenuAt,{"9900."+cChave+"00",0,STR0107,{||SetAtalho(aMenuAt,aMenu,.T.)},Nil,Nil})

LeAtalhos(aMenuAt,cChave)
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ClearAtalhºAutor  ³Reynaldo Miyashita  ºFecha ³  2008-02-11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA410                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ClearAtalho() 
Local nX :=  0
	// limpar os atalhos das teclas CONTROL
	For nX	:=	1 To 27
		If nX <> K_CTRL_O .And. nX <> K_CTRL_X .And. nX <> K_CTRL_C .And. nX <> K_CTRL_V .And. nX <> K_CTRL_Q   //Tirar O=15, X=24, C=3, V=22 e Q=17
			SetKey(nX,Nil)
		Endif
	Next nX 
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RestoreAtaºAutor  ³Reynaldo Miyashita  ºFecha ³  2008-02-11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PMSA410                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RestoreAtalho()
Local nX := 0
Local bBlocoAtalho

	// setar os atalhos das teclas CONTROL
	For nX := 1 To Len(aBAtalhos)
		bBlocoAtalho	:=	&("{|| IIf(lEmAtalho,Nil,(lEmAtalho:=.T.,Eval(aBAtalhos["+Str(nX)+",02]),lEmAtalho:=.F.))}")
		SetKey(aBAtalhos[nX,01],bBlocoAtalho)
	Next nX

Return .T.

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
Local aRotina

aRev		:= {  	{ STR0087 ,"PMSA210(2)"  , 0, 3 },; //"Carregamento"
					{ STR0088 ,"PMSA210(3)"  , 0, 4 },; //"unifica"
					{ STR0089 ,"PMSA210(4)"  , 0, 4 },; //"Associar Veiculo"
					{ STR0090 ,"PMSA210(5)"  , 0, 4 },; //"Associar Veiculo"
					{ STR0091 ,"PMSA210(6)"  , 0, 4 }} //"Bloqueio"

aSubBut 	:= {  	{ STR0007, "PMS200User", 0 , 6 },; //"Usuarios"
					{ STR0160, "PMS410Evt" , 0 , 3 },; //"Eventos"
					{ STR0010, "PMS220PM"  , 0 , 3 },; //"Planejamentos"
					{ STR0096, "PMS410Int" , 0 , 2 },; //"Integracao"
					{ STR0105, "PMS230Dlg" , 0 , 4 }}  //"Documentos"


aRotina := {	{ STR0002, "AxPesqui"  , 0 , 1,,.F.},; //"Pesquisar"
							{ STR0003, "PMS410Dlg" , 0 , 2},; //"Visualizar"
							{ STR0004, "PMS200Dlg" , 0 , 3},;	 //"Incluir"
							{ STR0005, "PMS200Alt" , 0 , 4},; //"Alt.Cadastro"
							{ STR0139, "PMS200Fase", 0 , 4},;//"Alt.Fase"
							{ STR0006, "PMS410Dlg" , 0 , 4},; //"Alt.Estrutura"
							{ STR0008, "PMS200Dlg" , 0 , 5},; //"Excluir"
							{ STR0009, aRev        , 0 , 2},; //"Revisoes"
							{ STR0122 , aSubBut    , 0 , 2}} //"Ferramentas"

// Opção sera disponibilizada somente se for versão 11.80 ou superior, banco de dados com DBACESS e existir a funcao
If lDefTop
	aAdd(aRotina,{ STR0166 , "PMSAltPrj"    , 0 , 6})
EndIf
aAdd(aRotina,{ STR0011 , "PMS200Leg"    , 0 , 6} ) //"Legenda"

If ExistBlock( "PM410ROT" )
	If ValType( aUsRotina := ExecBlock( "PM410ROT", .F., .F. ) ) == "A"
		AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
	EndIf
EndIf

Return(aRotina)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS410Evt ³ Autor ³ Totvs                      ³ Data ³ 13/07/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para tratar os eventos de notificacao do projeto.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS410Evt( cAlias, nReg, nOpcx )
Local lRet		:= .T.

lRet := PMS206Evt( cAlias, nReg, nOpcx )

Return lRet
