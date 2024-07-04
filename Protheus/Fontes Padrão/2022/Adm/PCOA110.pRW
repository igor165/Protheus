#INCLUDE "PCOA110.ch"
#INCLUDE "PROTHEUS.CH"
#include "pcoicons.ch"

// INCLUIDO PARA TRADUÇÃO DE PORTUGAL



/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOA110  ³ AUTOR ³ Edson Maricate        ³ DATA ³ 26-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa de manutecao dos usuarios da Planilha Orcamentaria  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOA110                                                      ³±±
±±³_DESCRI_  ³ Programa de manutecao dos usuarios da planilha orcamentaria  ³±±
±±³_FUNC_    ³ Esta funcao podera ser utilizada com a sua chamada normal a  ³±±
±±³          ³ partir do Menu ou a partir de uma funcao pulando assim o     ³±±
±±³          ³ browse principal e executando a chamada direta da rotina     ³±±
±±³          ³ selecionada.                                                 ³±±
±±³          ³ Exemplo : PCOA110(2) - Executa a chamada da funcao de visua- ³±±
±±³          ³                        zacao da rotina.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³ ExpN1 : Chamada direta sem passar pela mBrowse               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA110(nCallOpcx,cRevisa)

PRIVATE cCadastro	:= STR0001 //"Controle de Usuarios da Planilha Orcamentaria"
PRIVATE aRotina := MenuDef()   

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	If nCallOpcx <> Nil
		PCO110DLG("AK1",AK1->(RecNo()),nCallOpcx,,,cRevisa)
	Else
		mBrowse(6,1,22,75,"AK1")
	EndIf
EndIF

Return 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCO110DLG³ Autor ³ Edson Maricate         ³ Data ³ 26-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de montagem da DIALOG de manutencao dos usuarios    ³±±
±±³          ³ da planilha orcamentaria                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCO110DLG(cAlias,nReg,nOpcx,cR1,cR2,cVers)

Local oDlg

Local cArquivo		:= CriaTrab(,.F.)
Local cFiltro		:= ".T."

Local lOk
Local l110Visual	:= .F.
Local l110Altera	:= .F.
Local lContinua		:= .T.

Local aButtons		:= {}
Local aUsrButons	:= {}
Local aMenu			:= {}

Local nX			:= 0

DEFAULT	cVers := AK1->AK1_VERSAO

PRIVATE cRevisa		:= cVers
PRIVATE aRotina := {	{ "", "" , 0 , 1},;   
						{ "", "" , 0 , 2},;   
						{ "", "" , 0 , 3},;	 
						{ "", "" , 0 , 4, 2},;
						{ "", "" , 0 , 5, 1}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case (aRotina[nOpcx][4] == 2)
		l110Visual := .T.
	Case (aRotina[nOpcx][4] == 3)
		lOk			:= .F.	
		l110Inclui	:= .T.
	Case (aRotina[nOpcx][4] == 4)
		l110Altera	:= .T.
	Case (aRotina[nOpcx][4] == 5)
		l110Exclui	:= .T.
		l110Visual	:= .T.
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ExecBlock para inclusao de botoes customizados       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PCOA1102")
	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios na     ³
	//P_E³ tela da usuarios da planilha orcamentaria                              ³
	//P_E³ Parametros : Nenhum                                                    ³
	//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na planilha ³
	//P_E³              [1] : Titulo                                              ³
	//P_E³              [2] : Codeblock contendo a funcao do usuario              ³
	//P_E³              [3] : Resource utilizado no bitmap                        ³
	//P_E³              [4] : Tooltip do bitmap                                   ³
	//P_E³              Exemplo :                                                 ³
	//P_E³              User Function PCOA1102                                    ³
	//P_E³              Return {{"Titulo", {|| U_Botao() }, "BPMSDOC","Titulo" }} ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aUsrButons := ExecBlock("PCOA1102",.F.,.F.)
	For nx := 1 to Len(aUsrButons)
		aAdd(aMenu,{aUsrButons[nx,1],aUsrButons[nx,2],aUsrButons[nx,3],aUsrButons[nx,4]})
	Next
EndIf

If lContinua
	MENU oMenu POPUP
		MENUITEM STR0006 ACTION (Pco110Usr(cArquivo,3,cRevisa,1),Eval(bRefresh,cFiltro)) //"Incluir Usuario"
		MENUITEM STR0009 ACTION (Pco110Usr(cArquivo,4,cRevisa,2),Eval(bBrwChange)) //"Alterar Propriedades"
		MENUITEM STR0007 ACTION (Pco110Usr(cArquivo,5,cRevisa,3),Eval(bRefresh,cFiltro)) //"Excluir Usuario"
	ENDMENU
	aMenu := {	{TIP_FILTRO,		{|| PcoAK1Fil(@cFiltro),If(!Empty(cFiltro),Eval(bRefresh,cFiltro),NIL)}, BMP_FILTRO, TOOL_FILTRO},; 
				{TIP_PESQUISAR,		{|| PcoAK1Pesq(cArquivo), Eval(bBrwChange) }, BMP_PESQUISAR, TOOL_PESQUISAR},;
				{TIP_ORC_USUARIOS,	{|| Pco110CtrMenu(@oMenu,cArquivo,nOpcx),oMenu:Activate(100,45,oDlg)}, BMP_ORC_USUARIOS, TOOL_ORC_USUARIOS} }
	PCOAK1PLAN(STR0008,,cArquivo,,aMenu,@oDlg,,.T.,,@cFiltro) //"Planilha Orcamentaria"
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco110Dlg³ Autor ³ Edson Maricate         ³ Data ³ 26-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Inclusao,Alteracao,Visualizacao e Exclusao        ³±±
±±³          ³dos Usuarios da Planilha Orcamentaria                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco110Usr(cArquivo,nOpcx,cRevisa)

Local aArea		:= GetArea()
Local cAlias	:= (cArquivo)->ALIAS
Local nReg		:= (cArquivo)->RECNO
Local oDlg
Local oEnchoice
Local nRecAKG
Local lInclui	:= .F.
Local lVisual	:= .F.
Local lAltera	:= .F.
Local lExclui	:= .F.
Local lContinua	:= .T.   

Local lOk		:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case

	//Visualizacao
	Case (aRotina[nOpcx,4] == 2)
		lVisual := .T.

	//Inclusao
	Case ((aRotina[nOpcx,4] == 3) .Or. (aRotina[nOpcx,4] == 6)) 
		lInclui	:= .T.
		Inclui	:= .T.
		Altera	:= .F.

	//Alteracao
	Case (aRotina[nOpcx,4] == 4) 
		lAltera	:= .T.
		Altera	:= .T.
		Inclui  := .F.

	//Exclusao
	Case (aRotina[nOpcx,4] == 5) 
		lExclui	:= .T.
		lVisual	:= .T.
EndCase

If lContinua
 	If ! PcoChkUser(AK1->AK1_CODIGO,AK3->AK3_CO,AK3->AK3_PAI,If(lInclui.Or.lExclui, 4, 3),"CNTUSU",cRevisa)
		Aviso(STR0010, STR0011, {"Ok"})//"Atencao"###"Usuario sem direito a controle de usuarios da planilha orcamentaria."
		lContinua := .F.
	EndIf
EndIf

If lContinua
	dbSelectArea(cAlias)
	dbGoto(nReg)
	cAlias := "AKG"
	RegToMemory(cAlias,lInclui)
	
	If Alltrim(__cUserID) != "000000" .And. Alltrim(M->AKG_USER) == Alltrim(__cUserID)
		Aviso(STR0010, IIf(cPaisLoc$"RUS",STR0012,"Direitos deste usuario somente podera ser alterado pelo superior."), {"Ok"})//"Atencao"###
		lContinua := .F.
	EndIf

	If lContinua .And. !lInclui
		If !SoftLock(cAlias)
			lContinua := .F.
		Else
			nRecAKG := (cAlias)->(RecNo())
		Endif
	EndIf
EndIf

If lContinua
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 8,0 TO 29,78 OF oMainWnd
		oEnchoice := MsMGet():New(cAlias,nReg,nOpcx,,,,,{16,1,158,307},,3,,,,oDlg,,,)
		oEnchoice:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(Obrigatorio(oEnchoice:aGets,oEnchoice:aTela) .And. If(Str(nOpcx,1)$"34",A110TdOk(),.T.),(lOk:=.T.,oDlg:End()),Nil)},{|| oDlg:End()}) CENTERED

	Begin Transaction
		If (lInclui.Or.lAltera.Or.lExclui).And. lOk
			Pco110Grv(cAlias,lExclui,nRecAKG,cRevisa)
		EndIf
	End Transaction

EndIf

RestArea(aArea)
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco110Grv³ Autor ³ Edson Maricate         ³ Data ³ 26-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de gravacao dos usuarios da planilha orcamentaria    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco110Grv(cAlias,lDeleta,nRecAKG,cRevisa)

Local bCampo 	:= {|n| FieldName(n) }
Local aArea		:= GetArea()
Local nX		:= 0

If !lDeleta
	If nRecAKG <> Nil
		(cAlias)->(dbGoto(nRecAKG))
		RecLock(cAlias,.F.)
	Else
		RecLock(cAlias,.T.)
	EndIf
	For nx := 1 TO FCount()
		FieldPut(nx,M->&(EVAL(bCampo,nx)))
	Next nx
	FieldPut(FieldPos(cAlias+"_FILIAL"),xFilial(cAlias))
	//FieldPut(FieldPos(cAlias+"_REVISA"),cRevisa)
	dbCommit()                                          
	MsUnlock()
Else
	(cAlias)->(dbGoto(nRecAKG))
	RecLock(cAlias,.F.,.T.)
	dbDelete()
	MsUnlock()
EndIf

RestArea(aArea)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco110CtrMenu³ Autor ³Edson Maricate       ³ Data ³ 05-01-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que controla as propriedades do Menu PopUp.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco110CtrMenu(oMenu,cArquivo,nOpcx)
Local aArea		:= GetArea()
Local cAlias	:= (cArquivo)->ALIAS
Local nRecView	:= (cArquivo)->RECNO

dbSelectArea(cAlias)
dbGoto(nRecView)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se for visualizacao desabilita as opcoes.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (aRotina[nOpcx,4] == 2)
	oMenu:aItems[1]:Disable()
	oMenu:aItems[2]:Disable()
	oMenu:aItems[3]:Disable()
Else
	Do Case 
		Case cAlias == "AK1"
			oMenu:aItems[1]:Disable()
			oMenu:aItems[2]:Disable()
			oMenu:aItems[3]:Disable()
		Case cAlias == "AK3"
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

Static Function A110TdOk()
Local lRet := .F.
Local aRet := {1,1,1,1,1,1,1,1}  // 8 elementos
Local nSoma := 0 
Local aDirSup := {}
Local aArea := GetArea()
Local aAreaAKG := AKG->(GetArea())
Local nDirUsr, nDirSup, lRetUsr, nX, nCheck

dbSelectArea("AKG")
dbSetOrder(1)
If Alltrim(__cUserID)=="000000"
	lRet := .T.
Else
	If dbSeek(xFilial("AKG")+M->AKG_ORCAME+M->AKG_CO+__cUserID)
		// 8 tipos de acesso
		aAdd(aDirSup, { "ESTRUT", AKG->AKG_ESTRUT})
		aAdd(aDirSup, { "CNTUSU", AKG->AKG_CNTUSU})
		aAdd(aDirSup, { "ITENS" , AKG->AKG_ITENS})
		aAdd(aDirSup, { "REVISA", AKG->AKG_REVISA})
		aAdd(aDirSup, { "CCUSTO", AKG->AKG_CCUSTO})
		aAdd(aDirSup, { "ITMCTB", AKG->AKG_ITMCTB})
		aAdd(aDirSup, { "CLAVLR", AKG->AKG_CLAVLR})
		aAdd(aDirSup, { "ENTIDA", AKG->AKG_ENTIDA})
	Else
		//8 tipos de acesso
		aAdd(aDirSup, { "ESTRUT", "0"})
		aAdd(aDirSup, { "CNTUSU", "0"})
		aAdd(aDirSup, { "ITENS" , "0"})
		aAdd(aDirSup, { "REVISA", "0"})
		aAdd(aDirSup, { "CCUSTO", "0"})
		aAdd(aDirSup, { "ITMCTB", "0"})
		aAdd(aDirSup, { "CLAVLR", "0"})
		aAdd(aDirSup, { "ENTIDA", "0"})
		//executa pcochkusr para cada elemento da matriz no Usuario Superior
		// que esta concedendo direito 
		//para verificar o direito de acesso do usuario (na inclusao ou alteracao)
	
		//AK3 deve estar posicionado pois AK3_PAI eh necessario para PcoChkUser()
		For nX := 1 TO Len(aDirSup)
		
			nCheck := Val(&("M->AKG_"+aDirSup[nX,1]))
			nDirUsr  := 0
			lRetUsr := PcoChkUser(M->AKG_ORCAME,M->AKG_CO,AK3->AK3_PAI,nCheck,aDirSup[nX,1],cRevisa,@nDirUsr )
	
			If lRetUsr .And. nDirUsr > 0 //se o usuario superior tem acesso 
				aDirSup[nX,2] := Str(nDirUsr,1)
			EndIf
		Next
		
	EndIf
	
	//Compara o direito do usuario superior com o atual (na inclusao ou alteracao)
	For nX := 1 TO Len(aDirSup)
		nDirUsr := Val(&("M->AKG_"+aDirSup[nX,1]))
		nDirSup := Val(aDirSup[nX,2])
	
		If nDirUsr > nDirSup
			aRet[nX] := 0
		EndIf	
	
	Next
	
	aEval(aRet, {|x|nSoma += x})
	
	lRet := (nSoma == 8) //8 tipos de acessos
	
	If !lRet
		Aviso(STR0010, IIf(cPaisLoc$"RUS",STR0013,"Os acessos concedidos ao usuario nao pode ser superior ao presente usuario."),{"ok"})
	EndIf
EndIf
RestArea(aAreaAKG)
RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³10/12/06 ³±±
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
Local aRotina 	:= {	{ STR0002,	"AxPesqui"  , 0 , 1, ,.F.},;   //"Pesquisar"
							{ STR0003, 	"PCO110DLG" , 0 , 2},;    //"Visualizar"
							{ STR0004, 	"PCO110DLG" , 0 , 4}} //"Alterar"
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona botoes do usuario no Browse                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PCOA1101" )
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ³
		//P_E³ browse da tela de controle de usuarios da planilha orcamentaria        ³
		//P_E³ Parametros : Nenhum                                                    ³
		//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
		//P_E³               Ex. :  User Function PCOA1101                            ³
		//P_E³                      Return {{"Titulo", {|| U_Teste() } }}             ³
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType( aUsRotina := ExecBlock( "PCOA1101", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)
