#include "QIPA140.CH"
#include "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPA140  � Autor � Marcelo Pimentel      � Data � 06/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao de Classes de NC                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0002)	,"AxPesqui"  , 0 , 1,,.F.},; //"Pesquisar"
                     {OemToAnsi(STR0003)	,"AxVisual"  , 0 , 2},; //"Visualizar"
                     {OemToAnsi(STR0004)		,"QP140ICNC"  , 0 , 3},; //"Incluir"
                     {OemToAnsi(STR0005)		,"QP140ICNC"  , 0 , 4},; //"Alterar"
                     {OemToAnsi(STR0006)		,"QP140DCNC"  , 0 , 5, 3} } //"Excluir"
                     
Return aRotina

Function QIPA140()
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemToAnsi(STR0001)	//"Classes de Nao Conformidade"

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

dbSelectArea("QEE")

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QEE")

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QP140DCNC � Autor � Marcelo Pimentel      � Data � 06/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao Classes NC - Delecao                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QP140DCNC(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA140                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION QP140DCNC(cAlias,nReg,nOpc)
LOCAL nOpcA 
LOCAL cCod
LOCAL oDlg
LOCAL lAchou

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
		nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0009 )) //"Quanto � exclus�o?"
		nOpca := 1
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})

	dbSelectArea(cAlias)

	IF nOpcA == 2

		cCod := QEE->QEE_CLASSE

		//��������������������������������������������������������Ŀ
		//� Antes de deletar verif. se e' util. em cadastro de NCs �
		//����������������������������������������������������������
		dbSelectArea('SAG') 
		dbSetOrder(1)
		dbSeek(xFilial("SAG"))
		lAchou := .f.
		While AG_FILIAL == xFilial("SAG") .and. ! eof()
			if AG_CLASSE == cCod
				lAchou := .t.
				Exit
			endif
			dbSkip()
		Enddo
		if lAchou
			HELP(" ",1,"A160DCLNCS",,SAG->AG_NAOCON,3,1)
			dbSelectArea(cAlias)
			Exit
		EndIf

		Begin Transaction

			//��������������������������������������������������������������Ŀ
			//� Apos passar por todas as verificacoes , deleta o registro    �
			//����������������������������������������������������������������
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.,.T.)
			dbDelete()
			MsUnLock()
	
		End Transaction
	Else 
		MsUnLock()

   EndIf
	
   Exit
EndDo

dbSelectArea(cAlias)
Return .T.
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QP140ICNC � Autor �  Marcelo Pimentel     � Data � 06/11/97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao Classes NC - Inclusao/Alteracao       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QP140ICNC(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA140                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION QP140ICNC(cAlias,nReg,nOpc)
LOCAL nOpcA:=0

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
PRIVATE aTELA[0][0],aGETS[0]

While .T.

	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	nOpcA:=0

	Begin Transaction

		if nOpc == 3  // Inclusao
			nOpcA:=AxInclui( cAlias, nReg, nOpc)

		elseif nOpc == 4  // Alteracao
			nOpcA:=AxAltera( cAlias, nReg, nOpc)
		endif
	
	End Transaction

   Exit
EndDo
dbSelectArea(cAlias)
dbGoTop()
dbSetOrder(1)
dbGoto(nReg)
Return .T.