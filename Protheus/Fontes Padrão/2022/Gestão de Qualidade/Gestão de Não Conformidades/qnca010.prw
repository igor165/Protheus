#Include "PROTHEUS.CH"
#INCLUDE "QNCA010.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QNCA010  � Autor � Aldo Marini Junior    � Data � 22/12/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Tabelas de Causas/Efeitos/Origens/Tipo problema���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QNCA010()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function MenuDef()

Local aRotina := { { STR0001 ,"AxPesqui" , 0, 1,,.F.},;  //"Pesquisar"
					  { STR0002 ,"AxVisual" , 0, 2},;  //"Visualizar"
					  { STR0003 ,"Qn10Inclui" , 0, 3},;  //"Incluir"  
					  { STR0004 ,"AxAltera" , 0, 4},;  //"Alterar"  
					  { STR0005 ,"Qnc010Del", 0, 5} }  //"Excluir"

Return aRotina

Function QNCA010
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemToAnsi(STR0006)  //"Cadastro de Tabelas"

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
Private aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������

mBrowse( 6, 1,22,75,"QI0")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Qnc010Del� Autor � Aldo Marini Junior    � Data � 22/12/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de exclusao de Tabelas                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Qnc010del(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QNCA010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
FUNCTION Qn10Inclui(cAlias,nReg,nOpc)

Local nOpcA := 0

Private lWhenTp:=.T.
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
		
		nOpcA := AxInclui( cAlias, nReg, nOpc,,,,)
		
	End Transaction
	
	Exit             
	
EndDo

dbSelectArea(cAlias)

Return(NIL)
Function Qnc010Del(cAlias,nReg,nOpc)
Local nOpcA:=1
Local aAC := { STR0007 , STR0008 }  //"Abandona"###"Confirma"
Local lAchou    := .F.      
Local cTipo := ""
Local cCodigo := ""
Local lQNC010EXC := ExistBlock("QNC010EXC")

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private aTELA[0][0],aGETS[0]

dbSelectArea(cAlias)
dbSetOrder(1)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
nOpcA:=EnChoice( cAlias, nReg, nOpc, aAC,"AC",STR0009 )  //"Quanto � exclus�o?"
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})

If nOpcA == 2
	If lQNC010EXC 
		ExecBlock("QNC010EXC",.F.,.F.)
	EndIf
	//��������������������������������������������������������������Ŀ
	//� Envia mensagem sobre a verificacao nos arquivos              �
	//����������������������������������������������������������������
	If MsgYesNo(OemToAnsi(STR0010 + CHR(013) + ;  		//"Esta rotina verifica a exist�ncia de Lacamentos das"
						STR0011 + CHR(013) + ;  		//"Tabelas a serem excluidos nos diversos arquivos  do"
						STR0012 + CHR(013) + ;			//"m�dulo. A verifica��o pode ser demorada !!         "
						STR0013),OemToAnsi(STR0014)) 	//"Confirma a exclus�o ?                              "###"Aten��o"
			
		dbSelectArea("QI6") // Causas das Acoes
		dbGoTop()
		While !Eof()
			If QI0->QI0_TIPO ="1" .And. QI0->QI0_CODIGO == QI6->QI6_CAUSA
				lAchou := .T.
			Endif
			dbSkip()
		Enddo

		dbSelectArea("QI2") // Causas das Acoes
		dbGoTop()
		While !Eof()
			If (QI0->QI0_TIPO ="1" .And. QI0->QI0_CODIGO == QI2->QI2_CODCAU) .Or. ;
				(QI0->QI0_TIPO ="2" .And. QI0->QI0_CODIGO == QI2->QI2_CODEFE) .Or. ;
				(QI0->QI0_TIPO ="3" .And. QI0->QI0_CODIGO == QI2->QI2_CODORI) .Or. ;
				(QI0->QI0_TIPO ="4" .And. QI0->QI0_CODIGO == QI2->QI2_CODCAT)
				lAchou := .T.
			Endif
			dbSkip()
		Enddo

		//��������������������������������������������������������������Ŀ
		//� Se nao Achou pode Deletar                                    �
		//����������������������������������������������������������������
		Begin Transaction
			If lAchou == .F.
				dbSelectArea( cAlias )
				cTipo := QI0->QI0_TIPO
				cCodigo := QI0->QI0_CODIGO
				RecLock(cAlias,.F.,.T.)
				dbDelete()
				MsUnlock()
				dbSkip()
			Else
				MsgStop(OemToAnsi(STR0015 + CHR(013) +;  				//"O Lancamento a ser excluido est� presente nos"
								  STR0016 + CHR(013) +; 				//"Lancamentos das Causas das  Acoes, o registro"
								  STR0017),OemToAnsi(STR0018))  		//"nao sera excluido.                           "###"Aten��o"
			Endif
		End Transaction
		If Existblock("QNCA010DEL")	.AND. lAchou == .F.			
		   ExecBlock("QNCA010DEL",.F.,.F., {cTipo,cCodigo})
		EndIf
	EndIf
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QD050VLDIE   �Autor  �Sandra Ribeiro     Data �  14/10/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida��o do campo QI0_TIPO                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Controle De N�o Conformidades                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����
*/
Function Qn010VldTp() 

Local lret :=.T.
lWhenTp:=.F.

Return lret
