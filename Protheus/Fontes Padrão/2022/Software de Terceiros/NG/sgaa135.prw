#INCLUDE "SGAA135.CH" 
#INCLUDE "PROTHEUS.CH"               

#DEFINE _nVERSAO 1 //Versao do fonte
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � SGAA135  � Autor �Vitor Emanuel Batista  � Data �11/11/2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Classe de Residuos                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGASGA                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function SGAA135()
//��������������������������������������������Ŀ
//�Guarda conteudo e declara variaveis padroes �
//����������������������������������������������
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO,"SGAA135",{"TCS"})

Private cCadastro := STR0007 //"Cadastro de Classe de Res�duos"
Private aRotina   := MenuDef()

mBrowse( 6, 1, 22, 75, "TCS")

//��������������������������������������������Ŀ
//�Retorna conteudo de variaveis padroes       �
//����������������������������������������������
NGRETURNPRM(aNGBEGINPRM)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Vitor Emanuel Batista � Data �11/11/2009���
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
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados            ���
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

Local aRotina := {{STR0001,"PesqBrw" , 0, 1},; //"Pesquisar"
                  {STR0002,"NGCAD01" , 0, 2},; //"Visualizar"
                  {STR0003,"NGCAD01" , 0, 3},; //"Incluir"
                  {STR0004,"NGCAD01" , 0, 4,0},; //"Alterar"
                  {STR0005,"NGCAD01" , 0, 5,3}} //"Excluir"

Return aRotina