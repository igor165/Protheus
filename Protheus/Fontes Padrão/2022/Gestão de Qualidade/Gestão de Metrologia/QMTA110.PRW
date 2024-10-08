#INCLUDE "QMTA110.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QMTA110  � Autor � Wanderley Goncalves Jr� Data � 10/12/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Tabela de Status de Instrumento ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},;  // "Pesquisar" 
                     {OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;  // "Visualizar"
                     {OemToAnsi(STR0003),"A110ISta"  , 0 , 3},;  // "Incluir"   
                     {OemToAnsi(STR0004),"A110ASta"  , 0 , 4},;  // "Alterar"   
                     {OemToAnsi(STR0005),"A110DSta"  , 0 , 5, 3} }  // "Excluir"

Return aRotina

Function QMTA110
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private  cCadastro := OemtoAnsi(STR0006)  //"Status de Instrumento"

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
Private  aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Inclui os Status padroes - A(Ativo), I(Inativo) e 0(Malha)   �
//����������������������������������������������������������������

A110IPSta()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QMP")

Set Key VK_F12 To	

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A110DSta � Autor � Wanderley Goncalves   � Data � 10/12/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Tabela de Status - Delecao      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A110DSta(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTA110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A110DSta(cAlias,nReg,nOpc)

Local  nOpcA //,nCntDele := 0 ,cCod ,aAC := { OemToAnsi(STR0007),OemToAnsi(STR0008) }  //"Abandona"###"Confirma" 
Local  oDlg  
Local  nCont := 0
Private  bCampo := { |nField| FieldName(nField) }

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private  aTELA[0][0],aGETS[0]

FOR nCont := 1 TO FCount()
	M->&(EVAL(bCampo,nCont)) := FieldGet(nCont)
NEXT 	nCont

//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
nOpcA:=0

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
	nOpcA:=EnChoice( cAlias	, nReg, nOpc,,"AC","Quanto a Exclusao?")
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 2,oDlg:End()})

dbSelectArea(cAlias)

IF nOpcA == 1

   	If QMP->QMP_STATUS $ "AI0"
		HELP(" ",1,"A110STATUS")       	// N�o permite exclusao se status for Ativo ou Inativo ou Malha
		dbSelectArea(cAlias)
		Return .F.
	EndIf

	Begin Transaction

	//��������������������������������������������������������������Ŀ
	//� Apos passar por todas as verificacoes , deleta o registro    �
	//����������������������������������������������������������������
	dbSelectArea(cAlias)
	RecLock(cAlias,.F.,.T.)
	dbDelete()

	End Transaction
EndIf

dbSelectArea(cAlias)

Return(Nil)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A110ISta � Autor � Wanderley Goncalves   � Data � 10/12/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Tabela de Status - Inclusao     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A110ISta(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTA110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A110ISta(cAlias,nReg,nOpc)
Local  nOpcA:=0
Local  oDlg
Local  nCntFor	:= 1
Local nCont		:= 0

Private  bCampo := { |nField| FieldName(nField) }
Private  aTELA[0][0],aGETS[0]

dbSelectArea(cAlias)
If nOpc == 3
	FOR nCont := 1 TO FCount()
		DbSelectArea("QMP")
		cCampo := EVAL(bCampo,nCont)
		M->&(cCampo) := FieldGet(nCont)
		If ValType(M->&(cCampo)) = "C"
			M->&(cCampo) := SPACE(LEN(M->&(cCampo)))
		ElseIf ValType(M->&(cCampo)) = "N"
			M->&(cCampo) := 0
		ElseIf ValType(M->&(cCampo)) = "D"
			M->&(cCampo) := CtoD("  /  /  ")
		ElseIf ValType(M->&(cCampo)) = "L"
			M->&(cCampo) := .F.
		EndIf
	Next nCont
EndIF

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
nOpcA:=0

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd

nOpcA:=EnChoice( cAlias, nReg, nOpc )

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| if(Obrigatorio(aGets,aTela) ,(nOpca := 1,oDlg:End()),.f.)},{|| nOpca := 2,oDlg:End()})

If nOpca == 1
	Begin Transaction
		RecLock(cAlias,.t.)
		For nCntFor:= 1 To FCount()
			If FieldName(nCntFor) <> 'QMP_FILIAL'
				FieldPut(nCntFor,M->&(EVAL(bCampo,nCntFor)))
			Endif
		Next nCntFor
		QMP->QMP_FILIAL := xFilial("QMP")
		MsUnLock()
	End Transaction
Endif
dbSelectArea(cAlias)
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A110ASta � Autor � Vera Lucia S. Simoes  � Data � 11.11.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de tabela de Status - Alteracao    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A110ASta(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTA110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A110ASta(cAlias,nReg,nOpc)
Local  nOpcA	:=0                                   
Local  nCont	:= 1
Local  nCntFor	:= 1

Private  bCampo := { |nField| FieldName(nField) }
//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private  aTELA[0][0],aGETS[0]

FOR nCont := 1 TO FCount()
	M->&(EVAL(bCampo,nCont)) := FieldGet(nCont)
NEXT nCont

//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
nOpcA:=0

If QMP->QMP_STATUS $ "AI0"
	HELP(" ",1,"A110STATUS") 	// N�o permite altera��o se status for Ativo, Inativo ou Malha
Else
	
	nOpcA:=0
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
	
	nOpcA:=EnChoice( cAlias, nReg, nOpc )
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| if(Obrigatorio(aGets,aTela) ,(nOpca := 1,oDlg:End()),.f.)},{|| nOpca := 2,oDlg:End()})
	
	If nOpca == 1
		Begin Transaction
		RecLock(cAlias,.F.)
		For nCntFor:= 1 To FCount()
			FieldPut(nCntFor,M->&(EVAL(bCampo,nCntFor)))
		Next nCntFor
		MsUnLock()
		End Transaction
	Endif
	
EndIf

dbSelectArea(cAlias)
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A110IPSta� Autora� Iuri Seto             � Data � 08/05/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inclus�o dos Status padr�o.			                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A110IPSta()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 							                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTA110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A110IPSta()
Local  cAlias
Local  aPadrao
Local  nLoop  

aPadrao := {{"A",OemtoAnsi(STR0010)                   ,"S"},; //"Ativo"
			{"I",OemtoAnsi(STR0011)                   ,"N"},; //"Inativo"
			{"0",OemtoAnsi(STR0012)                   ,"N"}} //"Malha"
cAlias := "QMP"
                   
Begin Transaction
	dbSelectArea(cAlias)
	dbSetOrder(1)
	For nLoop := 1 TO Len(aPadrao) 
		If !dbSeek(xFilial("QMP") + aPadrao[nLoop,1])
			RecLock( cAlias, .T. )
			QMP->QMP_FILIAL := xFilial("QMP")
			QMP->QMP_STATUS := aPadrao[nLoop,1]
			QMP->QMP_DESCR	:= aPadrao[nLoop,2]
			QMP->QMP_ATUAL	:= aPadrao[nLoop,3]
			MsUnlock()
		EndIf
	Next nLoop
End Transaction

Return