#Include "Protheus.ch"
#Include "FISA017.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FISA017A  � Autor � Marcos Kato       � Data �  23/07/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Tabela de Concepto					  ���
�������������������������������������������������������������������������͹��
���Uso       � Localizacoes                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FISA017()

Local   alArea    := GetArea()
Private cCadastro := STR0006
Private aRotina  := MenuDef()

CriaCCR()


mBrowse( 6, 1, 22, 75,"CCR",,,,,,)

RestArea(alArea)
Return Nil 

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

aRotina := { 	{ STR0001,	"AxPesqui"  , 0 , 1,0 ,.F.	},;	//"Pesquisar"
				{ STR0002,	"AxVisual"  , 0 , 2,0 ,NIL	},;	//"Visualizar"
				{ STR0003,  "AxInclui"  , 0 , 3,0 ,NIL	},;	//"Incluir"
				{ STR0004,  "AxAltera"  , 0 , 4,15,NIL	},;	//"Alterar"
				{ STR0005,  "AxDeleta"  , 0 , 5,16,NIL	}} //"Excluir"



Return(aRotina)


