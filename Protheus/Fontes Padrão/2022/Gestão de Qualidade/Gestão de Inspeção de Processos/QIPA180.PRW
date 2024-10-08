#INCLUDE "QIPA180.CH"
#include "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPA180  � Autor � Vera Lucia S. Simoes  � Data � 17/04/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao de Fatores do IQP                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},;  // "Pesquisar" 
                     {OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;  // "Visualizar"
                     {OemToAnsi(STR0003),"A180IFat"  , 0 , 3},;  // "Incluir"   
                     {OemToAnsi(STR0004),"A180IFat"  , 0 , 4},;  // "Alterar"   
                     {OemToAnsi(STR0005),"A180DFat"  , 0 , 5, 3} }  // "Excluir"

Return aRotina

Function QIPA180()
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro

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

dbSelectArea("QPD")
cCadastro := OemtoAnsi(STR0006)  // "Fatores do I.Q.P."
//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"QPD")
Return .T.
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A180DFat � Autor � Vera Lucia S. Simoes  � Data � 17/04/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao Fatores do IQP - Delecao              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A180DFat(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA180                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A180DFat(cAlias,nReg,nOpc)
LOCAL nOpcA ,cCod 
LOCAL oDlg, lAchou
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
	IF nOpcA == 2
		cCod := QPD->QPD_CODFAT
 		//������������������������������������������������������������Ŀ
		//� Antes de deletar verif. se e' util. em Laudos das Entregas �
		//��������������������������������������������������������������
		dbSelectArea('QPL')
		dbSeek(xFilial("QPL"))
		lAchou := .f.
		While QPL_FILIAL == xFilial("QPL") .and. ! eof()
			if QPL_LAUDO == cCod
				lAchou := .t.
				Exit
			endif
			dbSkip()
		Enddo
 		//������������������������������������������������������������Ŀ
		//� Fator IQP nao pode ser excluido por ser utilizado no laudo �
		//� da entrega                                                 �
		//��������������������������������������������������������������
		if lAchou
			HELP(" ",1,"A180DFILAU",,QPL->QPL_OP+'-'+;
				QPL->QPL_PRODUT+'-'+dtoc(QPL->QPL_DTENTR)+;
				'-'+QPL->QPL_LOTE,3,1)
			dbSelectArea(cAlias)
			Exit
		EndIf
		//��������������������������������������������������������������Ŀ
		//� Fator IQP nao pode ser excluido por                          �
		//� ser utilizado no relatorio Indice Qualidade                  �
		//����������������������������������������������������������������
		if lAchou
			HELP(" ",1,"A160DFIREL",,QPW->QPW_ANO+' - '+;
			QPW->QPW_MES,4,1)
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
		End Transaction
	Else 
		MsUnLock()
   EndIf
   Exit
EndDo
dbSelectArea(cAlias)
return
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A180IFat � Autor � Vera Lucia S. Simoes  � Data � 17/04/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa Atualizacao Fatores IQP - Inclusao/Alteracao      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A180IFat(ExpC1,ExpN1,ExpN2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA180                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION A180IFat(cAlias,nReg,nOpc)
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
return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A180VlFa � Autor � Vera Lucia S. Simoes  � Data � 02/02/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo Fator                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA180 - E' chamada no X3_VALID do cpo. QPD_FATOR  - SX3  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A180VlFa()
Local lRetu := .T.
Local cVar := M->QPD_FATOR
//�����������������������������������������������������Ŀ
//� Verifica se o valor digitado e' um numero valido    �
//�������������������������������������������������������
If ! Positivo(val(cVar))
	lRetu := .f.
EndIf
//�����������������������������������������������������Ŀ
//� Verifica se o valor digitado e' um numero valido    �
//�������������������������������������������������������
If lRetu
	If ! QA_VerNum(@cVar)
		HELP(" ",1,"QA_NUMINV")
		lRetu := .f.
	EndIf
	M->QPD_FATOR := cVar   // atualizacao p/ enchoice
EndIf
Return(lRetu)
