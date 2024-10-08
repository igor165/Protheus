#INCLUDE "QMTA080.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QMTA080  � Autor � Wanderley Goncalves Jr� Data � 12/12/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Laboratorios Externos           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},; // "Pesquisar"
					{OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;      // "Visualizar"
					{OemToAnsi(STR0003),"AxInclui"  , 0 , 3},;      // "Incluir"
					{OemToAnsi(STR0004),"AxAltera"  , 0 , 4},;      // "Alterar"
					{OemToAnsi(STR0005),"A080DLab"  , 0 , 5,3},;      // "Excluir"
					{OemToAnsi(STR0010),"MsDocument" ,0 , 4}}       // "Conhecimento"

Return aRotina

Function QMTA080
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Private cEspecie // Para gravacao de textos
Private axtextos := {}	// Vetor que contem os textos

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0006)  //"Laboratorio Externo"

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
PRIVATE aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QMO")

Set Key VK_F12 To

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A080DLAB � Autor � Wanderley Goncalves Jr� Data � 12/12/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de exclusao de Laboratorios Externos              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A080DLAB(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTA080                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A080DLAB(cAlias,nReg,nOpc)
LOCAL nOpcA //,nCntDele := 0 ,cCod ,aAC := { OemToAnsi(STR0007),OemToAnsi(STR0008) }  //"Abandona"###"Confirma"
LOCAL oDlg
              
dbSelectArea("QM7")
dbSetOrder(1)
dbSeek(xFilial("QM7"))
While !Eof() 
	if QM7->QM7_LABOR = QMO->QMO_COD
		MSGALERT ("A exclus�o deste laboratorio n�o � permitida, o instrumento : "+QM7->QM7_INSTR+" esta vinculado � ele.",QMO->QMO_COD)		
		Return (nil)
	Endif
	dbskip()		
Enddo	
//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTELA[0][0],aGETS[0]

While .T.
	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	nOpcA:=0
	dbSelectArea(cAlias)
	RecLock(cAlias,.F.)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
	nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0009))  //"Quanto � exclus�o?"
	nOpca := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})
	
	dbSelectArea(cAlias)
	
	If nOpcA == 2
		RecLock(cAlias,.F.,.T.)
		dbDelete()
	EndIf
	
	MsUnLock()
	
	Exit
	
EndDo

dbSelectArea(cAlias)
Return(Nil)

