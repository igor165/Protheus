#include "pmsa130.ch"
#include "dbtree.ch"
#include "protheus.ch"
#include "pmsicons.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � PMSA130  � Autor � Edson Maricate        � Data � 02-08-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de gerenciamento de documentos do orcamento.        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �                                          ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PMSA130()


PRIVATE cCadastro	:= STR0001 //"Gerenciamento de Orcamentos do Projeto"
Private aCores:= PmsAF1Color()
Private aRotina := MenuDef()
Set Key VK_F12 To

If AMIIn(44) .And. !PMSBLKINT()
	dbSelectArea("AF1")
	dbSetOrder(1)
	mBrowse(6,1,22,75,"AF1",,,,,,aCores)
EndIf

Return
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PMS130Leg� Autor �  Fabio Rogerio Pereira � Data � 19-03-2002 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Exibicao de Legendas                             ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � PMSA130, SIGAPMS                                             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PMS130Leg(cAlias,nReg,nOpcx)
Local aLegenda := {}
Local i := 0

For i := 1 To Len(aCores)
	Aadd(aLegenda, {aCores[i,2], aCores[i,3]})
Next
                             
aLegenda := aSort(aLegenda, , , {|x,y| x[1] < y[1]})

BrwLegenda(cCadastro, STR0010, aLegenda) //"Legenda"

Return .T.

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PMS130Dlg� Autor � Wagner Mobile Costa    � Data � 02-08-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Programa de Atualizacao/Visualizacao dos documentos do Projeto���
���������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPMS                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PMS130Dlg(cAlias,nReg,nOpcx)

Local oDlg
Local l130Inclui	:= .F.
Local l130Visual	:= .F.
Local l130Altera	:= .F.
Local l130Exclui	:= .F.
Local aDelObj		:= {}
Local aMenu			:= {}
Local oTree
Local oMenu
Local lFWGetVersao := .T.

// variaveis para posicionamento do popup menu
Local nScreVal1 := 775 
Local nScreVal2 := 23

If cPaisLoc == 'RUS'
	//Set popup menu location using the screen resolution
	nScreVal1 := RU99XFUN15()[1] // GetRusPopupMenuPos
	nScreVal2 := RU99XFUN15()[2] // GetRusPopupMenuPos
EndIf

Do Case
	Case aRotina[nOpcx][4] == 2
		l130Visual := .T.
	Case aRotina[nOpcx][4] == 3
		l130Inclui	:= .T.
	Case aRotina[nOpcx][4] == 4
		l130Altera	:= .T.
	Case aRotina[nOpcx][4] == 5
		l130Exclui	:= .T.
		l130Visual	:= .T.
EndCase

MENU oMenu POPUP
	MENUITEM STR0007 Action PMS130DC(@oTree),PMSTreeOrc(@oTree,,"AF1,AF2,AF5,ACB") //"Atualizar Documentos"
	MENUITEM STR0008 Action PMS230View(@oTree,@aDelObj) //"Visualizar Documento"
	MENUITEM STR0009 Action PMS230View(@oTree,@aDelObj) //"Salvar Como"
	MENUITEM STR0002 Action PMSDocPesq(@oTree,AF1->AF1_ORCAME) //"Pesquisar"
ENDMENU
                                      
If !lFWGetVersao .or. GetVersao(.F.) == "P10"
	aMenu := {;
	         {TIP_ORC_INFO,   {||PmsOrcInf()}, BMP_ORC_INFO, TOOL_ORC_INFO},;
	         {TIP_DOCUMENTOS, {||A130CtrMenu(@oMenu,@oTree,l130Visual),oMenu:Activate(35,45,oDlg)}, BMP_DOCUMENTOS, TOOL_DOCUMENTOS}}
	Else
	//Acoes relacionadas
	aMenu := {;
	         {TIP_ORC_INFO,   {||PmsOrcInf()}, BMP_ORC_INFO, TOOL_ORC_INFO},;
	         {TIP_DOCUMENTOS, {||A130CtrMenu(@oMenu,@oTree,l130Visual),oMenu:Activate(nScreVal1,nScreVal2,oDlg)}, BMP_DOCUMENTOS, TOOL_DOCUMENTOS}}
Endif

PmsDlgAF1(cCadastro,@oMenu,@oTree,"AF1,AF2,AF5,ACB",{||A130CtrMenu(@oMenu,oTree,l130Visual)},,aMenu,@oDlg)

MsDocExclui(aDelObj,.F.)

Return 


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �PMS130DC� Autor � Edson Maricate          � Data � 02-08-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de visualizacao dos documentos do orcamento.           ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAPMS                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function PMS130DC(oTree)

Local cAlias	  := SubStr(oTree:GetCargo(),1,3)
Local nRecView	  := Val(SubStr(oTree:GetCargo(),4,12))
Private lExclDoc  := .T.

SaveInter()

If PmsVldFase("AF1",AF1->AF1_ORCAME,"41")
	If cAlias$"AF1/AF2/AF5"
		lExclDoc := PmsVldFase("AF1",AF1->AF1_ORCAME,"42",.F.)
		MsDocument(cAlias,nRecView,3,,,,lExclDoc)
	EndIf
Endif

If ExistBlock("PM130INC")
	ExecBlock("PM130INC", .F., .F., {})
EndIf

RestInter()

Return

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �A130CtrMenu� Autor � Edson Maricate       � Data � 09-02-2001 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao que controla as propriedades do Menu PopUp.            ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �PMSA130                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function A130CtrMenu(oMenu,oTree,lVisual)
Local cAlias	:= SubStr(oTree:GetCargo(),1,3)

If cAlias=="ACB"
	oMenu:aItems[1]:Disable()
	oMenu:aItems[2]:Enable()
	oMenu:aItems[3]:Enable()
ElseIf cAlias=="AF1"
	oMenu:aItems[1]:Disable()
	oMenu:aItems[2]:Disable()
	oMenu:aItems[3]:Disable()
ElseIf cAlias=="AF5"
	oMenu:aItems[2]:Disable()
	oMenu:aItems[3]:Disable()
	If !lVisual .And. PmsOrcUser(AF5->AF5_ORCAME,,AF5->AF5_EDT,AF5->AF5_EDTPAI,3,"DOCUME")
		oMenu:aItems[1]:Enable()
	Else
		oMenu:aItems[1]:Disable()
	EndIf
ElseIf cAlias=="AF2"
	oMenu:aItems[2]:Disable()
	oMenu:aItems[3]:Disable()
	If !lVisual .And. PmsOrcUser(AF2->AF2_ORCAME,AF2->AF2_TAREFA,,AF2->AF2_EDTPAI,3,"DOCUME")
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
	Local aRotina :={{STR0002, "AxPesqui",  0, 1, ,.F.}, ; //"Pesquisar"
	                 {STR0003, "PMS130Dlg", 0, 2}, ;       //"Visualizar"
	                 {STR0004, "PMS130Dlg", 0, 4}, ;       //"Atualizar"
	                 {STR0010, "PMS130Leg", 0, 4, ,.F.}}   //"Legenda"
Return aRotina
