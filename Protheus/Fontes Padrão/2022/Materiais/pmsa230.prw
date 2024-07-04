#include "PMSA230.ch"
#include "DBTREE.CH"
#include "protheus.ch"
#include "pmsicons.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � PMSA230  � Autor � Edson Maricate        � Data � 09-02-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de gerenciamento de documentos do projeto.          ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
���Fabio Rogerio �04/01/02�XXXXXX�Implementado as permissoes para usuario   ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
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
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PMS230Leg� Autor �  Fabio Rogerio Pereira � Data � 19-03-2002 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Exibicao de Legendas                             ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � PMSA230, SIGAPMS                                             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
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
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PMS230Dlg� Autor � Edson Maricate         � Data � 09-02-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Programa de Atualizacao/Visualizacao dos documentos do Projeto���
���������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPMS                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
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
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �A230CtrMenu� Autor � Edson Maricate       � Data � 09-02-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao que controla as propriedades do Menu PopUp.            ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �PMSA230                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
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
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PMS230View� Autor � Edson Maricate        � Data � 09-02-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de visualizacao de documentos.                         ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �PMSA230                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
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
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PMS230Save� Autor � Edson Maricate        � Data � 09-02-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de salvar o documento                                  ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �PMSA230                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
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
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �30/11/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,"AxPesqui"  , 0 , 1,,.F.},;//"Pesquisar"
								{ STR0003,"PMS230Dlg", 0 , 2},; //"Visualizar"
								{ STR0004,"PMS230Dlg", 0 , 4},; //"Atualizar"
								{ STR0010,"PMS230Leg", 0 , 4, ,.F.} } //"Legenda" 
Return(aRotina)								
