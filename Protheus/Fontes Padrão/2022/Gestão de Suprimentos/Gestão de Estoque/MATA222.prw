#Include 'MATA222.CH'
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATA222  � Autor � Fernando Joly Siquini � Data � 25/11/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastramento de Saldos Iniciais para Rastreabilidade      ���
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
Function MATA222()

Local nPos         := 0
Local cFiltro      := ""
Private cDelFunc   := Nil
Private aAcho      := Array(SBJ->(fCount()))
Private aAlter     := {}

//��������������������������������������������������������������Ŀ
//� Preenche os Arrays aAlter e aAcho                            �
//����������������������������������������������������������������
dbSelectArea('SBJ')
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
Private cCadastro := OemToAnsi(STR0005) // 'Saldos Iniciais - Rastreabilidade'


//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Ponto de entrada para verificacao de filtros na Mbrowse      �
//����������������������������������������������������������������
If  ExistBlock("M222FILB") 
	cFiltro := ExecBlock("M222FILB",.F.,.F.)
	If Valtype(cFiltro) <> "C"
		cFiltro := ""		
	EndIf
EndIf

mBrowse( 6, 1,22,75,'SBJ',,,,,,,,,,,,,, IF(!Empty(cFiltro),cFiltro, NIL))

dbSelectArea('SBJ')

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
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
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
Private aRotina	:= { {STR0001,'AxPesqui', 0 , 1,0,.F.},; // 'Pesquisar'
							{STR0002,'AxVisual', 0 , 2,0,nil} } // 'Visualizar'
If ExistBlock ("MTA222MNU")							    
	ExecBlock ("MTA222MNU",.F.,.F.)
Endif 
//��������������������������������������������������������������Ŀ
//� P.E. utilizado p adicionar items ou Filtro no Menu da mBrowse�
//����������������������������������������������������������������
If ExistBlock("MT222FIL")
   aRotAdic := ExecBlock("MT222FIL",.f.,.f.)
   If ValType(aRotAdic) == "A"
	  AEval(aRotAdic,{|x| AAdd(aRotina,x)})
   EndIf
EndIf
return (aRotina)
