#INCLUDE "HSPAHABE.ch"
#include "protheus.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHABE  � Autor � MARCELO JOSE       � Data �29/12/2005   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE LISTAS                                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ�� 
���Altera��es� L.Gustavo Caloi 28/03/06 -> Padroniza��o da HS_MsgInf()    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHABE()

Private cCadastro := STR0001 //"Listas"
Private nOpc      := 0
Private aRotina := MenuDef()

dbSelectArea("GFN")
dbSetOrder(1)
mBrowse(06, 01, 22, 75, "GFN")
Return( Nil )    
/************************************* Invoca as funcoes para validacao de inclusao / exclusao  ******************/
Function HS_ABE(cAlias, nReg, nOpc)
 Local nOpcA := 0
 Private cDelFunc := "HS_VEABE()"
 If nOpc == 3
  nOpcA := axInclui("GFN",, 3,,,, "HS_VIABE()") 
 ElseIf nOpc == 5
  nOpcA := axDeleta("GFN", nReg, nOpc)
 EndIf                            
Return(nOpcA) 
/*************************************  validacao de inclusao  ****************************************************/
Function HS_VIABE()
 Local lRet := .T.

 If DBSeek(xFilial("GFN") + M->GFN_CODIGO)
  HS_MsgInf(STR0009, STR0010, STR0012) //"LISTA JA EXISTE"###"Atencao"####"Valida��o de inclus�o"
  lRet := .F.
 EndIf
Return( lRet )  
/**************************************   validacao de exclusao   **********************************************/
Function HS_VEABE()
 Local lRet := .T., cAliasOld := Alias()
 
 dbSelectArea("GFO")
 dbSetOrder(2)
 
 If DBSeek(xFilial("GFO") + GFN->GFN_CODIGO  )
  HS_MsgInf(STR0007, STR0010, STR0013) //"Ja existe relacionamento para este registro ok... Nao podera exclui-lo."###"Atencao"###"Valida��o de exclus�o"
  lRet := .F.
 EndIf  
  
 DbSelectArea(cAliasOld)
Return( lRet )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Tiago Bandeira        � Data � 11/07/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Gera arquivo TXT para exportacao                      �
//�    4 - Recebe arquivo TXT                                    �
//����������������������������������������������������������������
Local aRotina :=	{{STR0002, "axPesqui", 0, 1, 0, nil},; //"Pesquisar"
                     {STR0003, "AxVisual", 0, 2, 0, nil},; //"Visualizar"
                     {STR0004, "HS_ABE"  , 0, 3, 0, nil},; //"Incluir"
                     {STR0005, "axAltera", 0, 4, 2, nil},; //"Alterar"
                     {STR0006, "HS_ABE"  , 0, 5, 1, nil}}  //"Excluir" 
Return(aRotina)