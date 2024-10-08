#INCLUDE "HSPAHAA4.ch"
#include "protheus.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAA4  � Autor � Jos� Orfeu         � Data �  07/12/2004 ���
�������������������������������������������������������������������������͹��
���Descricao � Clinica                                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
FUNCTION HSPAHAA4()
 Private cCadastro := STR0001 //"Cadastro de clinicas"
 Private aRotina := MenuDef()

 DbSelectArea("GCW")
 DbSetOrder(1)

 mBrowse( 6,1,22,75, "GCW")
Return(Nil)

Function HS_VEAA4()
 Local lRet := .T., cAliasOld := Alias()
 
 DbSelectArea("GCY")
 DbSetOrder(4)
 
 If !(lRet := !DBSeek(xFilial("GCY") + GCW->GCW_CODCLI))
  Help(" ", 1, "HAA4RELGCY",, STR0007, 1) //"Registro encontrado no atendimento e n�o pode ser excluido"
 EndIf  
  
 DbSelectArea(cAliasOld)
Return( lRet )

Function HS_AA4(cAlias, nReg, nOpc)
 Local nOpcA := 0
 
 Private cDelFunc := "HS_VEAA4()"

 If nOpc == 3
  nOpcA := axInclui("GCW",, nOpc,,,, /*Fun��o para validar  a inclusao*/) 
 ElseIf nOpc == 5
  nOpcA := axDeleta("GCW", nReg, nOpc)
 EndIf                            
Return(nOpcA)

Function HS_VldAA4()
 Local lRet := .T.
 
 If ReadVar() == "M->GCW_TITISS" .AND. !EMPTY(M->GCW_TITISS)
  If !(lRet := HS_SeekRet("G05", "M->GCW_TITISS", 1, .F., "GCW_DTITIS", "G05_DESCRI"))
   HS_MsgInf(STR0008, STR0009, STR0010)  //"Tipo de Interna��o n�o cadastrado."###"Aten��o"###"Valida��o dos Campos"
  EndIf

 EndIf

Return(lRet)


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
Local aRotina :=	{{STR0002, "AxPesqui", 0, 1, 0, nil},; //"Pesquisar"
                     {STR0003, "AxVisual", 0, 2, 0, nil},; //"Visualizar"
                     {STR0004, "HS_AA4"  , 0, 3, 0, nil},; //"Incluir"
                     {STR0005, "axAltera", 0, 4, 0, nil},; //"Alterar"
                     {STR0006, "HS_AA4"  , 0, 5, 0, nil}}  //"Excluir" 
Return(aRotina)