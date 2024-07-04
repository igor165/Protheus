#INCLUDE "MDTA006.ch"
#Include "Protheus.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MDTA006  � Autor � Andre Perez Alvarez   � Data � 09.01.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cadastro de cidades (SZ1)                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � MDTA006(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function MDTA006()

lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. ) 
SetKey( VK_F9, { | | NGVersao( "MDTA006" , 1 ) } )

If !lSigaMdtps
	msgStop(STR0007)  //"Esse programa � de uso exclusivo de empresas prestadoras de servi�o."
	Return .T.
Endif

If !ChkFile("SZ1",.F.)
	msgStop(STR0008 + CHR(13)+CHR(10) +;  //"A tabela SZ1 (Cidades) n�o existe. Favor executar a rotina"
		    STR0009)  //"UPDMDTPS atrav�s do IDE, digitando U_UPDMDTPS na barra de execu��o."
	Return .T.
Endif

PRIVATE aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0006) //"Cidades"
PRIVATE aSMENU := {}, bNGGRAVA := {}

aCHKDEL := { {'SZ1->Z1_COD', "SA1", 9},;  //Cidade + Cliente + Loja
             {'SZ1->Z1_COD', "TOL", 4} }  //Cidade + Cliente + Loja

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
DbSelectArea("SZ1")
DbSetOrder(1)
mBrowse( 6, 1,22,75,"SZ1")

Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Rafael Diogo Richter  � Data �29/11/2006���
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
���          �		1 - Pesquisa e Posiciona em um Banco de Dados         ���
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

Local aRotina := { { STR0001, "AxPesqui" , 0 , 1},; 
                   { STR0002, "NGCAD01"  , 0 , 2},; 
                   { STR0003, "NGCAD01"  , 0 , 3},; 
                   { STR0004, "NGCAD01"  , 0 , 4},; 
                   { STR0005, "NGCAD01"  , 0 , 5, 3} } 

Return aRotina