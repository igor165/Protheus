#INCLUDE "SGAC060.ch"
#Include "protheus.ch"
#DEFINE _nVERSAO 1 //Versao do fonte
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SGAC060   �Autor  �Roger Rodrigues     � Data �  18/01/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Consulta de Objetivos e Metas                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SIGASGA                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SGAC060()
//�����������������������������������������������������������������������Ŀ
//� Armazena variaveis p/ devolucao (NGRIGHTCLICK)                        �
//�������������������������������������������������������������������������
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
//Variavel de Semaforo
Local aCores :={{"NGSEMAFARO('TBH->TBH_SITUAC = "+'"1"'+"')" , "BR_AZUL" },;
				 {"NGSEMAFARO('TBH->TBH_SITUAC = "+'"2"'+"')" , "BR_AMARELO"},;
				 {"NGSEMAFARO('TBH->TBH_SITUAC = "+'"3"'+"')" , "BR_VERDE"},;
 				 {"NGSEMAFARO('TBH->TBH_SITUAC = "+'"4"'+"')" , "BR_VERMELHO"}}

Private cCadastro := STR0001 //"Consulta de Objetivos e Metas"
Private aRotina := MenuDef()
Private lTpMeta := NGCADICBASE('TAA_TPMETA','D','TAA',.F.)//Var�avel que consiste se existe o campo TPMETA

dbSelectArea("TBH")
DbSetOrder(1)
mBrowse( 6, 1,22,75,"TBH",,,,,,aCores)

//�����������������������������������������������������������������������Ŀ
//� Devolve variaveis armazenadas (NGRIGHTCLICK) 					 	  �
//�������������������������������������������������������������������������
NGRETURNPRM(aNGBEGINPRM)

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Roger Rodrigues       � Data �18/01/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Utilizacao de Menu Funcional.                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaSGA                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �    1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina :=	{ { STR0002	,	"AxPesqui"	, 0 , 1},; //"Pesquisar"
					  { STR0003	,	"Sg300Cad"	, 0 , 2},; //"Visualizar"
					  { STR0004		,	"Sg310Met"	, 0 , 2},; //"Metas"
					  { STR0005		,	"SGC60IMP"	, 0 , 2},; //"Imprimir"
					  { STR0006		,	"SGC60LEG"	, 0 , 3}} //"Legenda"

Return aRotina
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   �SGC60LEG  � Autor �Roger Rodrigues        � Data � 18/01/10 ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o�Cria uma janela contendo a legenda da mBrowse               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SGAC060		                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function SGC60LEG()
BrwLegenda(cCadastro,STR0006,{{"BR_AZUL" 		,OemToAnsi(STR0007)},; //"Legenda"###"Em An�lise"
                              	  {"BR_AMARELO"	,OemToAnsi(STR0008)},; //"Aberto"
                                  {"BR_VERDE"		,OemToAnsi(STR0009)},; //"Fechado"
                              	  {"BR_VERMELHO"	,OemToAnsi(STR0010)}}) //"Cancelado"
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SGC60IMP  �Autor  �Roger Rodrigues     � Data �  22/01/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Imprime Objetivo selecionado                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAC060                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SGC60IMP()
Local oRadOp,oDLGObj
Private nModeloImp := 1
Private lRet  := .f.
//Monta tela perguntando tipo de impress�o
DEFINE MSDIALOG oDLGObj FROM  0,0 TO 150,320 TITLE STR0011 PIXEL //"Selecione o Modo de Impress�o"

@ 10,10 TO 55,150 LABEL STR0012 of oDLGObj Pixel //"Modo de Impress�o"
@ 20,14 RADIO oRadOp VAR nModeloImp ITEMS STR0013,STR0014 SIZE 70,15 PIXEL OF oDLGObj //"Tela"###"Impressora"

DEFINE SBUTTON FROM 59,90  TYPE 1 ENABLE OF oDLGObj ACTION EVAL({|| lRET := .T.,oDLGObj:END()})
DEFINE SBUTTON FROM 59,120 TYPE 2 ENABLE OF oDLGObj ACTION oDLGObj:END()

ACTIVATE MSDIALOG oDLGObj CENTERED

If lRet
	//Chama impress�o de relat�rio
	SGAR140(nModeloImp)
Endif
Return .T.