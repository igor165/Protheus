#INCLUDE "mdta580.ch"
#Include "Protheus.ch"

#DEFINE _nVERSAO 1 //Versao do fonte
/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � MDTA580      � Autor � Jackson Machado       � Data � 19/05/11 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o �  Programa de Cadastro de Fun��es da Brigada                    ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � MDTA580()                                                      ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�                                                                ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   � Booleano                                                       ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � SIGAMDT - Medicina e Seguranca do Trabalho                     ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/ 
Function MDTA580()

//��������������������������������������������Ŀ
//�Guarda conteudo e declara variaveis padroes �
//����������������������������������������������
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

If !NGCADICBASE("TKS_CODCJN","A","TKS",.F.)
	If !NGINCOMPDIC("UPDMDT38","TDGQ95")
		Return .F.
	Endif
Endif

If NGCADICBASE("TKU_ATVSYP","A","TKU",.F.)
	PRIVATE aMemos := {{"TKU_ATVSYP","TKU_ATIVID"}}
EndIf

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0001)   //"Fun��es da Brigada"
PRIVATE aCHKDEL := {}, bNGGRAVA   
PRIVATE aRotina := MenuDef()
//��������������������������������������������������������������Ŀ
//�aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-�
//�s�o do registro.                                              �
//�                                                              �
//�1 - Chave de pesquisa                                         �
//�2 - Alias de pesquisa                                         �
//�3 - Ordem de pesquisa                                         �
//����������������������������������������������������������������
aCHKDEL :=	{ {"TKU->TKU_CODIGO" , "TKM", 7} }

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
DbSelectArea("TKU")
DbSetOrder(1)
mBrowse( 6, 1,22,75,"TKU")

//��������������������������������������������Ŀ
//�Retorna conteudo de variaveis padroes       �
//����������������������������������������������
NGRETURNPRM(aNGBEGINPRM)
Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Jackson Machado       � Data � 19/05/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Utilizacao de Menu Funcional.                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaMDT                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
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
�������������������������������������������������������������������������Ĵ�� 
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

aRotina :=	{ { STR0002  , "AxPesqui", 0 , 1},;  //"Pesquisar" //"Pesquisar"
				  { STR0003 , "NGCAD01" , 0 , 2},;  //"Visualizar" //"Visualizar"
              { STR0004    , "NGCAD01" , 0 , 3},;  //"Incluir" //"Incluir"
              { STR0005    , "NGCAD01" , 0 , 4},;  //"Alterar" //"Alterar"
              { STR0006    , "NGCAD01" , 0 , 5, 3} }  //"Excluir" //"Excluir"

Return aRotina  