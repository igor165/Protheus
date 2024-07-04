#INCLUDE "MNTA370.ch"
#INCLUDE "PROTHEUS.CH"   

#DEFINE _nVERSAO 1 //Versao do fonte
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MNTA370  � Autor � Felipe Nathan Welter  � Data � 17/08/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de indicador de uso de objeto de manutencao       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAMNT                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTA370()

//��������������������������������������������Ŀ
//�Guarda conteudo e declara variaveis padroes �
//����������������������������������������������
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

Private aRotina := MenuDef()
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0001) //"Indicador de Uso de Objeto de Manutencao"
Private aCHKDEL := {}, aRELAC := {}
Private bNGGRAVA := {|| MNTA370OK()}

If AllTrim(GetNewPar("MV_NGINTER","N")) != "M"
	ShowHelpDlg(STR0002, {STR0003+; //"ATENCAO"###"A rotina de indicadores de uso s� pode ser executada se o ambiente estiver"
									STR0004,""},2,; //" configurado para trabalhar com integra��o via mensagem �nica."
								  {STR0005,""},2) //"Habilite o par�metero MV_NGINTER para trabalhar com a integra��o."
	Return .F.
EndIf

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("TUT")
dbSetOrder(1)
mBrowse( 6, 1,22,75,"TUT")

//��������������������������������������������Ŀ
//�Retorna conteudo de variaveis padroes       �
//����������������������������������������������
NGRETURNPRM(aNGBEGINPRM)

Return .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNTA370VLD� Autor � Felipe Nathan Welter  � Data � 17/08/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacoes da rotina MNTA370                                ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MNTA370                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTA370VLD(cField)
	
	Local lRet := .T.
	Local xCont
	
	Default cField := ReadVar()
	xCont := &(cField)
	
	If "TUT_CODBEM" $ cField
		lRet := MNTA370VLD("TUT_TPCONT")
		lRet := MNTA370VLD("TUT_CLSPRE")
		
	ElseIf "TUT_TPCONT" $ cField
		dbSelectArea("ST9")
		dbSetOrder(01)
		If dbSeek(xFilial("ST9")+M->TUT_CODBEM)
			If xCont == '1'
				If ST9->T9_TEMCONT == "N"
					ShowHelpDlg(STR0002,{STR0006,""},2,; //"ATENCAO"###"Bem nao possui contador 1"
										  {STR0007,""},2) //"Selecione outro bem/contador"
					lRet := .F.
				EndIf
			ElseIf xCont == '2'
				dbSelectArea("TPE")
				dbSetOrder(01)
				If !dbSeek(xFilial("TPE")+ST9->T9_CODBEM)
					ShowHelpDlg(STR0002,{STR0008,""},2,; //"ATENCAO"###"Bem nao possui contador 2"
										  {STR0007,""},2) //"Selecione outro bem/contador"
					lRet := .F.
				EndIf
			EndIf
		EndIf
		
		dbSelectArea("TUT")
		dbSetOrder(01)
		If dbSeek(xFilial("TUT")+M->TUT_CODBEM+M->TUT_TPCONT)
			ShowHelpDlg(STR0002,{STR0009+xCont+STR0010,""},2,; //"ATENCAO"###"J� existe indicador para o contador "###" deste bem"
								  {STR0007,""},2) //"Selecione outro bem/contador"
			lRet := .F.
		EndIf
		
	ElseIf "TUT_CLSPRE" $ cField
		M->TUT_VALOR  := 0
		M->TUT_CUSTHO := 0
		M->TUT_CODPRO := Space(TAMSX3("TUT_CODPRO")[1])
		M->TUT_LOCAL  := Space(TAMSX3("TUT_LOCAL")[1])
		M->TUT_CUSTD  := 0
		M->TUT_CUSTM  := 0
		
		dbSelectArea("ST9")
		dbSetOrder(01)
		If dbSeek(xFilial("ST9")+M->TUT_CODBEM)
			
			If xCont == '2'
				M->TUT_CUSTHO := ST9->T9_CUSTOHO
			EndIf
			
		EndIf
		
	ElseIf "TUT_CODPRO" $ cField
		dbSelectArea("SB1")
		dbSetOrder(01)
		If dbSeek(xFilial("SB1")+M->TUT_CODPRO)
			M->TUT_LOCAL := SB1->B1_LOCPAD
		EndIf
		lRet := MNTA370VLD("TUT_LOCAL")
		
	ElseIf "TUT_LOCAL" $ cField
		
		If M->TUT_CLSPRE == '3'
			dbSelectArea("SB1")
			dbSetOrder(01)
			If dbSeek(xFilial("SB1")+M->TUT_CODPRO)
				M->TUT_CUSTD := SB1->B1_CUSTD
			EndIf
		ElseIf M->TUT_CLSPRE == '4'
			dbSelectArea("SB2")
			dbSetOrder(01)
			If dbSeek(xFilial("SB2")+M->TUT_CODPRO+M->TUT_LOCAL)
				M->TUT_CUSTM := SB2->B2_CM1
			EndIf
		EndIf
		
	EndIf
	
Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MNTA370OK� Autor � Felipe Nathan Welter  � Data � 21/08/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes da rotina MNTA370                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MNTA370                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTA370OK()
	Local lRet := .T.
	
	If Empty(M->TUT_CODPRO) .Or. Empty(M->TUT_LOCAL)
		ShowHelpDlg(STR0002,{STR0011,""},2,; //"ATENCAO"###"Necess�rio informar produto e local para associar ao indicador de custo."
							  {STR0012,""},2) //"Preencha os campos solicitados."
		lRet := .F.
	EndIf
	
Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MNTA370CAD� Autor � Felipe Nathan Welter  � Data � 24/08/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Tela de cadastro da rotina                                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MNTA370                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTA370CAD(cAlias,nRec,nOp)
	
	RegToMemory("TUT",(nOp==3))
	//carrega gatilhos de preco
	MNTA370VLD("TUT_CODPRO")
	//chama rotina de cadastro
	NGCAD01(cAlias,nRec,nOp)
	
Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Felipe Nathan Welter  � Data � 17/08/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
Local aRotina := {{ STR0013, "AxPesqui" , 0 , 1},; //"Pesquisar"
                    { STR0014, "MNTA370CAD" , 0 , 2},; //"Visualizar"
                    { STR0015, "MNTA370CAD" , 0 , 3},; //"Incluir"
                    { STR0016, "MNTA370CAD" , 0 , 4},; //"Alterar"
                    { STR0017, "MNTA370CAD" , 0 , 5, 3} } //"Excluir"

Return(aRotina)