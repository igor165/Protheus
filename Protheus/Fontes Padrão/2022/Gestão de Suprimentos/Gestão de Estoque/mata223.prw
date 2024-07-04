#Include 'MATA223.CH'
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATA223  � Autor � Fernando Joly Siquini � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastramento de Saldos Iniciais para Localiza��o          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS � MOTIVO DA ALTERACAO                    ���
�������������������������������������������������������������������������Ĵ��
���              �        �      �                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function MATA223()

Local nPos         := 0
Local cFiltro      := ""

Private cDelFunc   := Nil
Private aAcho      := Array(SBK->(fCount()))
Private aAlter     := {}

//��������������������������������������������������������������Ŀ
//� Preenche os Arrays aAlter e aAcho                            �
//����������������������������������������������������������������
dbSelectArea('SBK')
aFields(aAcho)
If (nPos:=aScan(aAcho,{|x| 'BJ_FILIAL' $ Upper(x)})) > 0
	aDel(aAcho, nPos); aSize(aAcho, Len(aAcho)-1)
EndIf		  
aAlter := aClone(aAcho)

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 -Pesquisa e Posiciona em um Banco de Dados              �
//�    2 -Simplesmente Mostra os Campos                          �
//�    3 -Inclui registros no Bancos de Dados                    �
//�    4 -Altera o registro corrente                             �
//�    5 -Estorna registro selecionado gerando uma contra-partida�
//����������������������������������������������������������������
Private aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemToAnsi(STR0005) // 'Saldos Iniciais - Localica��o'

//��������������������������������������������������������������Ŀ
//� Ponto de entrada para verificacao de filtros na Mbrowse      �
//����������������������������������������������������������������
If  ExistBlock("M223FILB") 
	cFiltro := ExecBlock("M223FILB",.F.,.F.)
	If Valtype(cFiltro) <> "C"
		cFiltro := ""		
	EndIf
EndIf
//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,'SBK',,,,,,,,,,,,,, IF(!Empty(cFiltro),cFiltro, NIL))

dbSelectArea('SBK')

Return Nil


/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Fabio Alves Silva     � Data �03/10/2006���
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
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     		  ���
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
Local aRotAdic     := {}     
Private aRotina	:={ {STR0001,'AxPesqui', 0 , 1,0,.F.},; // 'Pesquisar'
							{STR0002,'AxVisual', 0 , 2,0,nil}} // 'Visualizar'
If ExistBlock ("MTA223MNU")
	ExecBlock ("MTA223MNU",.F.,.F.)
Endif 

//��������������������������������������������������������������Ŀ
//� P.E. utilizado p adicionar items ou Filtro no Menu da mBrowse�
//����������������������������������������������������������������
If ExistBlock("MT223FIL")
   aRotAdic := ExecBlock("MT223FIL",.f.,.f.)
   If ValType(aRotAdic) == "A"
	  AEval(aRotAdic,{|x| AAdd(aRotina,x)})
   EndIf
EndIf							
return (aRotina)