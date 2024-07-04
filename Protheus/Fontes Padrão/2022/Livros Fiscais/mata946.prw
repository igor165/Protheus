#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA946.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MATA946   � Autor � Cleber S. A. Santos   � Data �29/06/2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao cadastral da tabela CCK - Cadastro do reflexo dos    ���
���          � ajustes na Apura��o de IPI                                 ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MATA946
Local	lRet	:=	.T.

Private cCadastro   := STR0001	//"Cadastro do reflexo dos ajustes na Apura��o de IPI"
Private aRotina  	:= MenuDef()

mBrowse( 6, 1,22,75,"CCK")

Return lRet                                                                                    


/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { 	{ oemtoansi("Pesquisar")	,"AxPesqui"		, 0 , 1},;
					{ oemtoansi("Visualizar")	,"AxVisual"		, 0 , 2},;
					{ oemtoansi("Alterar")		,"A946AltSYP"	, 0 , 4}}

If ExistBlock("MA946MNU")
	ExecBlock("MA946MNU",.F.,.F.)
EndIf

Return(aRotina)

Function A946AltSYP(cAlias,nReg,nOpc,aAcho,cFunc,aCpos)
	AxAltera(cAlias,nReg,nOpc,aAcho,cFunc,aCpos,/*cOkFunc*/,/*lF3*/,"M946SYP")
Return

Function M946SYP
	MSMM(M->CCK_DESCR2,,,M->CCK_DESCD,1,,,"CCK","CCK_DESCR2")
Return .T.
