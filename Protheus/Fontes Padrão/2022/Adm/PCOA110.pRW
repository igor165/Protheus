#INCLUDE "PCOA110.ch"
#INCLUDE "PROTHEUS.CH"
#include "pcoicons.ch"

// INCLUIDO PARA TRADU敲O DE PORTUGAL



/*/
_F_U_N_C_苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲UNCAO    � PCOA110  � AUTOR � Edson Maricate        � DATA � 26-12-2003 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰ESCRICAO � Programa de manutecao dos usuarios da Planilha Orcamentaria  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� USO      � SIGAPCO                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡DOCUMEN_ � PCOA110                                                      潮�
北砡DESCRI_  � Programa de manutecao dos usuarios da planilha orcamentaria  潮�
北砡FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal a  潮�
北�          � partir do Menu ou a partir de uma funcao pulando assim o     潮�
北�          � browse principal e executando a chamada direta da rotina     潮�
北�          � selecionada.                                                 潮�
北�          � Exemplo : PCOA110(2) - Executa a chamada da funcao de visua- 潮�
北�          �                        zacao da rotina.                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲un噮o    砅CO110DLG� Autor � Edson Maricate         � Data � 26-12-2003 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噮o � Programa de montagem da DIALOG de manutencao dos usuarios    潮�
北�          � da planilha orcamentaria                                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � SIGAPCO                                                      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
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

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� ExecBlock para inclusao de botoes customizados       �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If ExistBlock("PCOA1102")
	//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios na     �
	//P_E� tela da usuarios da planilha orcamentaria                              �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as rotinas a serem adicionados na planilha �
	//P_E�              [1] : Titulo                                              �
	//P_E�              [2] : Codeblock contendo a funcao do usuario              �
	//P_E�              [3] : Resource utilizado no bitmap                        �
	//P_E�              [4] : Tooltip do bitmap                                   �
	//P_E�              Exemplo :                                                 �
	//P_E�              User Function PCOA1102                                    �
	//P_E�              Return {{"Titulo", {|| U_Botao() }, "BPMSDOC","Titulo" }} �
	//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲un噮o    砅co110Dlg� Autor � Edson Maricate         � Data � 26-12-2003 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噮o 砅rograma de Inclusao,Alteracao,Visualizacao e Exclusao        潮�
北�          砫os Usuarios da Planilha Orcamentaria                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Generico                                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
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
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲un噮o    砅co110Grv� Autor � Edson Maricate         � Data � 26-12-2003 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噮o 砅rograma de gravacao dos usuarios da planilha orcamentaria    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      矴enerico                                                      潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪哪目北
北矲un噮o    砅co110CtrMenu� Autor 矱dson Maricate       � Data � 05-01-2004 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪拇北
北矰escri噮o 矲uncao que controla as propriedades do Menu PopUp.             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北� Uso      砈IGAPCO                                                        潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function Pco110CtrMenu(oMenu,cArquivo,nOpcx)
Local aArea		:= GetArea()
Local cAlias	:= (cArquivo)->ALIAS
Local nRecView	:= (cArquivo)->RECNO

dbSelectArea(cAlias)
dbGoto(nRecView)


//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//砈e for visualizacao desabilita as opcoes.�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
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
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矼enuDef   � Autor � Ana Paula N. Silva     � Data �10/12/06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Utilizacao de menu Funcional                               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矨rray com opcoes da rotina.                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砅arametros do array a Rotina:                               潮�
北�          �1. Nome a aparecer no cabecalho                             潮�
北�          �2. Nome da Rotina associada                                 潮�
北�          �3. Reservado                                                潮�
北�          �4. Tipo de Transa噭o a ser efetuada:                        潮�
北�          �		1 - Pesquisa e Posiciona em um Banco de Dados     潮�
北�          �    2 - Simplesmente Mostra os Campos                       潮�
北�          �    3 - Inclui registros no Bancos de Dados                 潮�
北�          �    4 - Altera o registro corrente                          潮�
北�          �    5 - Remove o registro corrente do Banco de Dados        潮�
北�          �5. Nivel de acesso                                          潮�
北�          �6. Habilita Menu Funcional                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,	"AxPesqui"  , 0 , 1, ,.F.},;   //"Pesquisar"
							{ STR0003, 	"PCO110DLG" , 0 , 2},;    //"Visualizar"
							{ STR0004, 	"PCO110DLG" , 0 , 4}} //"Alterar"
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Adiciona botoes do usuario no Browse                                   �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If ExistBlock( "PCOA1101" )
		//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de controle de usuarios da planilha orcamentaria        �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA1101                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		If ValType( aUsRotina := ExecBlock( "PCOA1101", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)
