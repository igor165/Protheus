#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA986.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MATA986   � Autor � Gustavo G. Rueda      � Data �13/12/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao cadastral da tabela CC8 - Cadastro do reflexo dos    ���
���          � ajustes na Apura��o de ICMS                                ���
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
Function MATA986
Local	lRet	:=	.T.

Private cCadastro   := STR0001	//"Cadastro do reflexo dos ajustes na Apura��o de ICMS"
Private aRotina  	:= MenuDef()

mBrowse( 6, 1,22,75,"CC8")

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
					{ oemtoansi("Incluir")		,"A986IncSYP"	, 0 , 3},;
					{ oemtoansi("Alterar")		,"A986AltSYP"	, 0 , 4},;
					{ oemtoansi("Excluir")		,"A986DelSYP"	, 0 , 5} }


If ExistBlock("MA986MNU")
	ExecBlock("MA986MNU",.F.,.F.)
EndIf

Return(aRotina)

Function A986IncSYP(cAlias,nReg,nOpc,aAcho,cFunc,aCpos)
	AxInclui(cAlias,nReg,nOpc,aAcho,cFunc,aCpos,/*cOkFunc*/,/*lF3*/,"M986SYP")
Return

Function A986AltSYP(cAlias,nReg,nOpc,aAcho,cFunc,aCpos)
	AxAltera(cAlias,nReg,nOpc,aAcho,cFunc,aCpos,/*cOkFunc*/,/*lF3*/,"M986SYP")
Return

Function A986DelSYP(cAlias,nReg,nOpc,aAcho,cFunc,aCpos)
	AxDeleta(cAlias,nReg,nOpc,aAcho,cFunc,aCpos,/*cOkFunc*/,/*lF3*/,"M986SYP")
Return

Function M986SYP
	MSMM(M->CC8_DESCR2,,,M->CC8_DESCD,1,,,"CC8","CC8_DESCR2")
Return .T.
