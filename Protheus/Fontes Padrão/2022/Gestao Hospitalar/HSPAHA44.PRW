#INCLUDE "HSPAHA44.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA44  � Autor � Manoel Filho       � Data �  08/02/02   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE LOCAIS DE INFECCAO                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��  
���Altera��es� L.Gustavo Caloi 28/03/06 -> Padroniza��o da HS_MsgInf()    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHA44()

 Private cTab      := "LI"
 Private cAlias    := "SX5"
 Private cCadastro := STR0001 //"Locais de Infeccao"
 Private nOpc      := 0
 Private aRotina   := MenuDef()

 dbSelectArea(cAlias)
 dbSetOrder(1)
 mBrowse(06, 01, 22, 75, "SX5",,,,,,,,,,,,,, "X5_TABELA = '"+cTab+"'")

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � HSPAHA441� Autor �  Manoel Filho         � Data � 08/02/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de Inclusao/Alteracao/Visualizacao                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSAHA441(nOpc)

 cSayCpo1 := STR0007 //"Codigo"
 cSayCpo2 := STR0008 //"Local"

 HS_TelSx5('HS_Exc44()',,nOpc)

Return

// Funcao de Exclusao
Function HS_Exc44()
Local cAliasOld := Alias() 
Local lRet := .T.

 DbSelectArea("GEJ")
 DbSetOrder(5) //GEJ/5
 If DbSeek(xFilial("GEJ") + M->X5_CHAVE)
  HS_MsgInf(STR0010, STR0011, STR0012) //"Existe esta Topografia na Notificacao do CCIH. Impossivel Exclui-lo!"###"Atencao"####"Inclus�o/Altera��o/Visualiza��o"
  lRet := .F.
 Endif

 DbSelectArea(cAliasOld)          
	If lRet
 	nOpca := 1
  oDlg:End()          
 EndIf          

Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Tiago Bandeira        � Data � 06/06/07 ���
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
Local aRotina :=	{{OemToAnsi(STR0002), "axPesqui"   , 0, 1, 0, nil},; //"Pesquisar"
                     {OemToAnsi(STR0003), 'HSAHA441(2)', 0, 2, 0, nil},; //"Visualizar"
                     {OemToAnsi(STR0004), 'HSAHA441(3)', 0, 3, 0, nil},; //"Incluir"
                     {OemToAnsi(STR0005), 'HSAHA441(4)', 0, 4, 2, nil},; //"Alterar"
                     {OemToAnsi(STR0006), 'HSAHA441(5)', 0, 5, 1, nil}}  //"Excluir"
Return(aRotina)