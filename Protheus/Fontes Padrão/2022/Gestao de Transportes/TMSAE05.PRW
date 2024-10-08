#INCLUDE "TMSAE05.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAE05  � Autor � Eduardo de Souza      � Data � 07/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de LayOut - EDI                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE05                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATMS                                                    ���
�������������������������������������������������������������������������Ĵ��
���                  ATUALIZACOES - VIDE SOURCE SAFE                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE05()

Private cCadastro := STR0006 // "EDI - LayOuts"
Private aRotina   := MenuDef()

DbSelectArea("DE9")
DbSetOrder(1)
DbGoTop()

mBrowse(6,1,22,75,"DE9")

RetIndex("DE9")

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSE05Mnt � Autor � Eduardo de Souza      � Data � 07/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela Cadastro de Layout                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSE05Mnt(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Alias do arquivo                                   ���
���          � ExpN1 - Numero do registro                                 ���
���          � ExpN2 - Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE05                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function TMSE05Mnt(cAlias,nReg,nOpc)

Local oDlg
Local aSize    := {}
Local aInfo    := {}
Local aObjects := {}
Local aPosObj  := {}
Local cTipEnv  := ""
Local aAreaDEC := DEC->(GetArea())

Private aTELA[0][0]
Private aGETS[0]

DbSelectArea("DE9")
DbSetOrder(1)

RegToMemory("DE9",nOpc == 3)

//��������������������������������������������������������Ŀ
//�Armazena o Tipo de Envio, Utilzado na Gravacao.   	   �
//����������������������������������������������������������
cTipEnv  := M->DE9_TIPENV

//-- Dimensoes padroes
aSize   := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL

oEnch:= MsMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,3,,,,,,.T.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela),(TMSE05Grv(nOpc,cTipEnv),oDlg:End()),)},{|| oDlg:End()}) CENTERED

DeleteObject( oDlg  )
DeleteObject( oEnch )

RestArea( aAreaDEC )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSE05Grv � Autor � Eduardo de Souza      � Data � 07/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Layout                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSE05Grv(ExpN1,ExpC1)                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 - Numero da opcao selecionada                        ���
���          � ExpC1 - Tipo de Envio                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE05                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function TMSE05Grv(nOpc,cTipEnv)

Local ni
Local bCampo := { |nCpo| Field(nCpo) }

If nOpc <> 2 // Se nao for visualizacao

	If nOpc == 3 .Or. nOpc == 4 // Incluir ou Alterar

		Begin Transaction
			RecLock("DE9",nOpc==3)
			For nI := 1 TO FCount()			
				If FieldName(nI) == 'DE9_FILIAL'
					FieldPut(nI,xFilial("DE9"))
				Else
					FieldPut(nI,M->&(Eval(bCampo,nI)))
				EndIf
			Next nI
			MsUnLock()      

			//������������������������������������������������������������������
			//� Se Mudou o Tipo de Envio, Atualiza amarracao Cliente X Layout. �
			//������������������������������������������������������������������
			If !Empty(cTipEnv) .And. cTipEnv <> M->DE9_TIPENV
				DbSelectArea("DEC")
				DbSetOrder(3)
				If MSSeek(xFilial("DEC")+DE9->DE9_CODLAY)
					While DEC->(!Eof()) .And. DEC->DEC_FILIAL + DEC->DEC_CODLAY == xFilial("DEC")+DE9->DE9_CODLAY
						RecLock("DEC",.F.,.T.)
						DEC->DEC_TIPENV := M->DE9_TIPENV
						MsUnlock()
						DEC->(DbSkip())
					EndDo
				EndIf
			EndIf

		End Transaction
	
	ElseIf nOpc == 5 // Excluir

		//������������������������������������������������������������������Ŀ
		//�Verifica amarracao no configurador de Layout e Composicao do Reg. �
		//��������������������������������������������������������������������
		If TMSAE05Del()
			Begin Transaction
				RecLock("DE9",.F.,.T.)
				DE9->(DbDelete())
				MsUnLock()
				dbSkip()
			End Transaction
		EndIf
	EndIf
EndIf

Return

/*����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAE05Del � Autor � Eduardo de Souza    � Data � 07/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da Exclusao do Layout                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE05Del()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE05                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE05Del()

Local lRet     := .T.
Local aAreaDE0 := DE0->(GetArea())

//������������������������������������������������������
//�Verifica Amarracao Configurador de Layout.          �
//������������������������������������������������������
DbSelectArea("DE0")
DbSetOrder(1)
If MSSeek(xFilial("DE0")+DE9->DE9_CODLAY)
   	lRet := .F.
EndIf
	    
//������������������������������������������������������
//�Verifica Amarracao Cliente X Layout.                �
//������������������������������������������������������
DbSelectArea("DEC")
DbSetOrder(3)
If MSSeek(xFilial("DEC")+DE9->DE9_CODLAY)
   	lRet := .F.
EndIf

If !lRet
	Help(" ",1,"TMSAE0501") //"Registro utilizado no arquivo de configuracao de layout e/ou no arquivo de amarracao Cliente x Layout, nao podera ser excluido"
EndIf

RestArea( aAreaDE0 )

Return lRet

/*����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAE05TPE � Autor � Eduardo de Souza    � Data � 04/06/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza o Tipo de Envio                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAE05TPE()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSAE05                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSAE05TPE()

If M->DE9_TIPLAY == "2"
	M->DE9_TIPENV := "0"
EndIf

Return .T.


/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
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
     
Private aRotina	:=	{	{STR0001,"AxPesqui" ,0,1,0,.F.},; // "Pesquisar"
								{STR0002,"TMSE05Mnt",0,2,0,NIL},; // "Visualizar"
								{STR0003,"TMSE05Mnt",0,3,0,NIL},; // "Incluir"
								{STR0004,"TMSE05Mnt",0,4,0,NIL},; // "Alterar"
								{STR0005,"TMSE05Mnt",0,5,0,NIL}}  // "Excluir"


If ExistBlock("TME05MNU")
	ExecBlock("TME05MNU",.F.,.F.)
EndIf

Return(aRotina)

