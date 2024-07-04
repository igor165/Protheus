#include "PMSA230.ch"
#include "DBTREE.CH"
#include "protheus.ch"
#include "pmsicons.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA230  ³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de gerenciamento de documentos do projeto.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Fabio Rogerio ³04/01/02³XXXXXX³Implementado as permissoes para usuario   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSA230(nCallOpcx)


PRIVATE cCadastro	:= STR0001 //"Gerenciamento de Documentos do Projeto"
Private aRotina    := MenuDef()
Private aCores:= PmsAF8Color()

Set Key VK_F12 To

If AMIIn(44) .And. !PMSBLKINT()
	If nCallOpcx <> Nil
		PMS230Dlg("AF8",AF8->(RecNo()),nCallOpcx)
	Else
		mBrowse(6,1,22,75,"AF8",,,,,,aCores)
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS230Leg³ Autor ³  Fabio Rogerio Pereira ³ Data ³ 19-03-2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Exibicao de Legendas                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA230, SIGAPMS                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS230Leg(cAlias,nReg,nOpcx)
Local aLegenda:= {}
Local i       := 0

For i:= 1 To Len(aCores)
	Aadd(aLegenda,{aCores[i,2],aCores[i,3]})
Next i
                             
aLegenda:= aSort(aLegenda,,,{|x,y| x[1] < y[1]})

BrwLegenda(cCadastro,STR0010,aLegenda) //"Legenda"

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS230Dlg³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Programa de Atualizacao/Visualizacao dos documentos do Projeto³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS230Dlg(cAlias,nReg,nOpcx)

Local oMenu
Local oDlg
Local oTree
Local l230Inclui	:= .F.
Local l230Visual	:= .F.
Local l230Altera	:= .F.
Local l230Exclui	:= .F.
Local aDelObj		:= {}
Local aMenu			:= {}
Local cArquivo      := CriaTrab(,.F.)
Local lFWGetVersao := .T.
Local nScreVal1 := 775 // variaveis para posicionamento do popup menu
Local nScreVal2 := 23  // variaveis para posicionamento do popup menu

PRIVATE cRevisa 	:= AF8->AF8_REVISA

If cPaisLoc == 'RUS'
	//Set popup menu location using the screen resolution
	nScreVal1 := RU99XFUN15()[1] // GetRusPopupMenuPos
	nScreVal2 := RU99XFUN15()[2] // GetRusPopupMenuPos
EndIf

// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
Do Case
	Case aRotina[nOpcx][4] == 2
		l230Visual := .T.
	Case aRotina[nOpcx][4] == 3
		l230Inclui	:= .T.
	Case aRotina[nOpcx][4] == 4
		l230Altera	:= .T.
	Case aRotina[nOpcx][4] == 5
		l230Exclui	:= .T.
		l230Visual	:= .T.
EndCase

MENU oMenu POPUP
	MENUITEM STR0007 Action PMS230DC(@oTree,cArquivo),Eval(bRefresh) //"Atualizar Documentos"
	MENUITEM STR0012 Action PMS230View(@oTree,@aDelObj,cArquivo) //"Abrir Documento"
	MENUITEM STR0009 Action PMS230Save(@oTree,@aDelObj,cArquivo) //"Salvar Como"
ENDMENU

If !lFWGetVersao .or. GetVersao(.F.) == "P10"
	aMenu := {;
	         {TIP_PROJ_INFO,  {||PmsPrjInf()  }, BMP_PROJ_INFO, TOOL_PROJ_INFO},; 	
	         {TIP_PESQUISAR,  {||PMSDocPesq(@oTree, AF8->AF8_PROJET, AF8_REVISA,cArquivo)}, BMP_PESQUISAR, TOOL_PESQUISAR},;
	         {TIP_DOCUMENTOS, {||A230CtrMenu(@oMenu,@oTree,l230Visual,cArquivo),oMenu:Activate(105,45,oDlg) }, BMP_DOCUMENTOS, TOOL_DOCUMENTOS}}
Else
	// Acoes relacionadas
	aMenu := {;
	         {TIP_PROJ_INFO,  {||PmsPrjInf()  }, BMP_PROJ_INFO, TOOL_PROJ_INFO},; 	
	         {TIP_PESQUISAR,  {||PMSDocPesq(@oTree, AF8->AF8_PROJET, AF8_REVISA,cArquivo)}, BMP_PESQUISAR, TOOL_PESQUISAR},;
	         {TIP_DOCUMENTOS, {||A230CtrMenu(@oMenu,@oTree,l230Visual,cArquivo),oMenu:Activate(nScreVal1,nScreVal2,oDlg) }, BMP_DOCUMENTOS, TOOL_DOCUMENTOS}}
Endif
	
PmsDlgAF8(cCadastro,@oMenu,AF8->AF8_REVISA,@oTree,"AF8,AFC,AF9,ACB",,,,aMenu,@oDlg,,@cArquivo)
MsDocExclui(aDelObj,.F.)

Return 


Function PMS230DC(oTree,cArquivo)

Local cAlias	
Local nRecView	
Local aRotAnt  := {}
Local cPrgCall := Alltrim(FunName())

// clona aRotina da Pmsa200
If cPrgCall == "PMSA410" .And.  aRotina != NIL
	aRotAnt  := aClone(aRotina)
	aRotina 	:= {	{ "", "AxPesqui"  , 0 , 1},; //"Pesquisar"
						{ "", "PMS200Dlg" , 0 , 2},; //"Visualizar"
						{ "", "PMS200Dlg" , 0 , 3},; //"Incluir"
						{ "", "PMS200Alt" , 0 , 4},; //"Alt.Cadastro"
						{ "", "PMS200Dlg" , 0 , 4},; //"Alt.Estrutura"
						{ "", "PMS200User", 0 , 6},; //"Usuarios"
						{ "", "PMS200Dlg" , 0 , 5},; //"Excluir"
						{ "", "PMS200Leg" , 0 , 6}}  //"Legenda"
EndIf	


If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

SaveInter()

If PmsVldFase("AF8",AF8->AF8_PROJET,"61")
	If cAlias$"AF8/AF9/AFC"
		MsDocument(cAlias,nRecView,3)

 		If ExistBlock("PMA230ID")
			ExecBlock("PMA230ID", .F., .F.)
		EndIf		
	EndIf
Endif

// restaura aRotina
If cPrgCall == "PMSA410" .And. aRotAnt != NIL
	aRotina := aClone(aRotAnt)
EndIf

RestInter()

If ExistBlock("PM230DOC")
	Execblock("PM230DOC",.F.,.F.,{AF9->AF9_PROJET,AF9->AF9_TAREFA})
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A230CtrMenu³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que controla as propriedades do Menu PopUp.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA230                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A230CtrMenu(oMenu,oTree,lVisual,cArquivo)
Local cAlias	
Local nRecView	

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

If cAlias=="ACB"
	oMenu:aItems[1]:Disable()
	oMenu:aItems[2]:Enable()
	oMenu:aItems[3]:Enable()
ElseIf cAlias=="AF8"
	oMenu:aItems[1]:Disable()
	oMenu:aItems[2]:Disable()
	oMenu:aItems[3]:Disable()
ElseIf cAlias=="AFC"
	oMenu:aItems[2]:Disable()
	oMenu:aItems[3]:Disable()
	If !lVisual .And. PmsChkUser(AFC->AFC_PROJET,,AFC->AFC_EDT,AFC->AFC_EDTPAI,3,"DOCUME",AFC->AFC_REVISA)
		oMenu:aItems[1]:Enable()
	Else
		oMenu:aItems[1]:Disable()
	EndIf
ElseIf cAlias=="AF9"
	oMenu:aItems[2]:Disable()
	oMenu:aItems[3]:Disable()
	If !lVisual .And. PmsChkUser(AF9->AF9_PROJET,AF9->AF9_TAREFA,,AF9->AF9_EDTPAI,3,"DOCUME",AF9->AF9_REVISA)
		oMenu:aItems[1]:Enable()
	Else
		oMenu:aItems[1]:Disable()
	EndIf
Else
	oMenu:aItems[1]:Disable()
	oMenu:aItems[2]:Disable()
	oMenu:aItems[3]:Disable()
EndIf


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS230View³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de visualizacao de documentos.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA230                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS230View(oTree,aDelObj,cArquivo)

Local aArea		:= GetArea()
Local cAlias	
Local nRecView	
Local lRet      := .T.

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

If ExistBlock("PMA230VD")
	lRet := ExecBlock("PMA230VD", .F., .F., {cAlias, nRecView})
EndIf

If lRet .And. FUNNAME() == "PMSA230"
	lRet := PmsVldFase("AF8",AF8->AF8_PROJET,"62")
Endif

If lRet .and. cAlias == "ACB"
	ACB->(dbGoto(nRecView))
	MsDocView(ACB->ACB_OBJETO,@aDelObj)
EndIf


RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS230Save³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de salvar o documento                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA230                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS230Save(oTree,aDelObj,cArquivo)

Local aArea		:= GetArea()
Local cAlias	
Local nRecView	
Local lRet      := .T.

If oTree == Nil
	cAlias	:= (cArquivo)->ALIAS
	nRecView	:= (cArquivo)->RECNO
Else
	cAlias	:= SubStr(oTree:GetCargo(),1,3)
	nRecView	:= Val(SubStr(oTree:GetCargo(),4,12))
EndIf

If ExistBlock("PMA230SD")
	lRet := ExecBlock("PMA230SD", .F., .F., {cAlias, nRecView})
EndIf

If lRet .And. FUNNAME() == "PMSA230"
	lRet := PmsVldFase("AF8",AF8->AF8_PROJET,"62")
Endif

If lRet .and. cAlias == "ACB"
	ACB->(dbGoto(nRecView))
	Ft340SavAs()
EndIf


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
Local aRotina 	:= {	{ STR0002,"AxPesqui"  , 0 , 1,,.F.},;//"Pesquisar"
								{ STR0003,"PMS230Dlg", 0 , 2},; //"Visualizar"
								{ STR0004,"PMS230Dlg", 0 , 4},; //"Atualizar"
								{ STR0010,"PMS230Leg", 0 , 4, ,.F.} } //"Legenda" 
Return(aRotina)								
