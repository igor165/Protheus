#INCLUDE "QADA010.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QADA010  � Autor � Paulo Emidio de Barros� Data � 18/10/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualizacao de Auditores         					      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQAD                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QADA010(aRotAuto, nOpc)

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
PRIVATE aRotina := { {STR0001,"AxPesqui"  ,  0 , 1   },;  // "Pesquisar"
				  	  {STR0002,"AxVisual"  ,  0 , 2   },;  // "Visualizar"
					  {STR0003,"QA10Inclui",  0 , 3   },;  // "Incluir"
					  {STR0004,"QA10Altera",  0 , 4   },;  // "Alterar"
					  {STR0005,"QA10Deleta", 0 , 5, 3} }   // "Excluir"

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0006)  //"Auditores"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QU1")

Return(.T.)
       

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA10deleta� Autor � Paulo Emidio de Barros� Data �18/10/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualizacao de Auditores									  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QA10Deleta(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QA10Deleta(cAlias,nReg,nOpc)
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
	nOpcA := 0
	dbSelectArea(cAlias)
	SoftLock(cAlias)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
	nOpcA := EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0009))  //"Quanto a exclus�o?"
	nOpca := 2
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 2,oDlg:End()})
	
	dbSelectArea(cAlias)
	
	IF nOpcA == 1
		//��������������������������������������������������������������Ŀ
		//� Verifica se existem auditorias asscoiadas ao Auditor		 �
		//����������������������������������������������������������������
		QUC->(dbSetOrder(4))
		If QUC->(dbSeek(xFilial("QUC")+QU1->QU1_CODAUD))
   			HELP(" ",1,"010ADITASS")
			dbSelectArea(cAlias)
			MsUnLock()
			Exit
		EndIf               
			
		//��������������������������������������������������������������Ŀ
		//� Verifica se existem alocacoes para o Auditor				 �
		//����������������������������������������������������������������
		QUA->(dbSetOrder(1))
		If QUA->(dbSeek(xFilial("QUA")+QU1->QU1_CODAUD))
			HELP(" ",1,"010ADIALOC")
			dbSelectArea(cAlias)
			MsUnLock()
			Exit
		EndIf              
	
		Begin Transaction
			
			//��������������������������������������������������������������Ŀ
			//� Deleta o Registro											 �
			//����������������������������������������������������������������
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.,.T.)
			dbDelete()
			
		End Transaction
		
	Else
	
		MsUnLock()
		
	EndIf
	
	Exit    
	
EndDo

dbSelectArea(cAlias)

Return( NIL )


/*     
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA10Inclui� Autor � Paulo Emidio de Barros� Data �18/10/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Auditores						  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QA10Inclui(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION QA10Inclui(cAlias,nReg,nOpc)
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
		
		nOpcA := AxInclui( cAlias, nReg, nOpc,,,,"QA10TudoOk()")
		
	End Transaction
	
	Exit             
	
EndDo

dbSelectArea(cAlias)

Return(NIL)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA10Altera� Autor � Paulo Emidio de Barros� Data �18/10/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualizacao de Auditores									  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Qa10Inclui(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION QA10Altera(cAlias,nReg,nOpc)
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
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA10TudoOk� Autor �Paulo Emidio de Barros � Data � 20/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza as consistencias antes da gravacao dos dados		  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QA10TudoOk()
Local lRet 

lRet := ExistChav("QU1",M->QU1_CODAUD)

Return(lRet)