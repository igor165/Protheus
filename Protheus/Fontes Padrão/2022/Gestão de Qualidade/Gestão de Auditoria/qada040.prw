#INCLUDE "QADA040.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QADA040  � Autor � Paulo Emidio de Barros� Data � 18/10/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de e-mails associados 							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQAD                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Paulo Emidio�18/12/00�------�Foram ajustados e complementados os STR's ���
���            �	    �      �e os arquivos CH's, para que os mesmos pos���
���            �	    �      �sam ser traduzidos.						  ���
���            �        �      �                                          ���
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef()

Local aRotina := { {STR0001, "AxPesqui"  , 0 , 1,,.F.},; //"Pesquisar"
		  	  {STR0002, "AxVisual"  , 0 , 2   },; //"Visualizar"
			  {STR0003, "QA40Inclui", 0 , 3   },; //"Incluir"
			  {STR0004, "QA40Altera", 0 , 4   },; //"Alterar"
			  {STR0005, "QA40Deleta", 0 , 5, 3} } //"Excluir"


Return aRotina

Function QADA040(nOpc)
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0006) //"e-mails associados"

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
mBrowse( 6, 1,22,75,"QU5")

Return(.T.)
       

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA40deleta� Autor � Paulo Emidio de Barros� Data �18/10/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � e-mails associados a Auditoria							  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QA40Deleta(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION QA40Deleta(cAlias,nReg,nOpc)
LOCAL nOpcA 
Local oDlg

Private aTELA[0][0],aGETS[0]

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������

While .T.
	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	nOpcA := 2
	dbSelectArea(cAlias)
	SoftLock(cAlias)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
	nOpcA := EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0009)) //"Quanto a exclus�o?"
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 2,oDlg:End()})
	
	dbSelectArea(cAlias)
	
	IF nOpcA == 1

		//��������������������������������������������������������������Ŀ
		//� Verifica se usuario esta vinculado a Auditoria				 �
		//����������������������������������������������������������������
		QUI->(dbSetOrder(2))
		QUI->(dbSeek(xFilial("QUI")+QU5->QU5_USERNA))
		If QUI->(!Eof()) .And. QUI->QUI_USERNA == QU5->QU5_USERNA
			Help("",1,"040MAIAUD") 
		Else
			Begin Transaction
			
			//��������������������������������������������������������������Ŀ
			//� Deleta o Registro											 �
			//����������������������������������������������������������������
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.,.T.)
			dbDelete()
				
			End Transaction
		
		EndIf
		
	Else
	
		MsUnLock()
		
	EndIf
	
	Exit    
	
EndDo

dbSelectArea(cAlias)

Return( NIL )


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA40Inclui� Autor � Paulo Emidio de Barros� Data �18/10/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � e-mails associados										  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QA40Inclui(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION QA40Inclui(cAlias,nReg,nOpc)
Local nOpcA := 0

Private aTELA[0][0],aGETS[0]

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������

While .T.
	
	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	nOpcA := 0
	
	Begin Transaction
		
		nOpcA := AxInclui( cAlias, nReg, nOpc,,,,"QA40TudoOk()")
		
	End Transaction
	
	Exit             
	
EndDo

dbSelectArea(cAlias)

Return(NIL)


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA40Altera� Autor � Paulo Emidio de Barros� Data �18/10/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � e-mails associados a Auditoria							  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Qa40Inclui(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION QA40Altera(cAlias,nReg,nOpc)
Local nOpcA :=0 

Private aTELA[0][0],aGETS[0]

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
While .T.
	
	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	nOpcA :=0
	
	Begin Transaction
		
		nOpcA:=AxAltera( cAlias, nReg, nOpc, , , , ,"AllWaysTrue()")

	End Transaction
	
	Exit

EndDo

dbSelectArea(cAlias)
Return(NIL)


/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA40TudoOk� Autor �Paulo Emidio de Barros � Data � 20/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza as consistencias antes da gravacao dos dados		  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QA40TudoOk()
Local lRet 

lRet := ExistChav("QU5",M->QU5_USERNA)

Return(lRet)