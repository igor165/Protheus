#INCLUDE "MNTA991.ch"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � MNTA991   � Autor �Vitor Emanuel Batista � Data �05/08/2009���
�������������������������������������������������������������������������Ĵ��
���Descricao �Cadastro de Tipos de Horas da M�o de Obra                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAMNT                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MNTA991()
//��������������������������������������������Ŀ
//�Guarda conteudo e declara variaveis padroes �
//����������������������������������������������
Local aNGBEGINPRM := NGBEGINPRM(,,{"TTJ"})

Private aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0001) //"Cadastro de Tipo de Horas da M�o de Obra"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
aCHKDEL := { {'TTJ->TTJ_TPHORA', "TTL", 2}}

dbSelectArea("TTJ")
dbSetOrder(1)
mBrowse( 6, 1,22,75,"TTJ")

//��������������������������������������������Ŀ
//�Retorna conteudo de variaveis padroes       �
//����������������������������������������������
NGRETURNPRM(aNGBEGINPRM)
Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor �Vitor Emanuel Batista  � Data �05/08/2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
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

	Local aRotina := {	{	STR0002	,	"AxPesqui"	,	0	,	1	},; //"Pesquisar" //"Pesquisar"
								{	STR0003,	"NGCAD01"	,	0	,	2	},; //"Visualizar" //"Visualizar"
								{	STR0004	,	"NGCAD01"	,	0	,	3	},; //"Incluir" //"Incluir"
								{	STR0005	,	"NGCAD01"	,	0	,	4	},; //"Alterar" //"Alterar"
								{	STR0006	,	"NGCAD01"	,	0	,	5,	3} } //"Excluir" //"Excluir"
Return(aRotina)