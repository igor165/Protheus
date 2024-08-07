#INCLUDE "HSPAHA87.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA87  � Autor � Jose Orfeu         � Data �  06/12/2003 ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE PORTE ANESTESICOS                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHA87()
 Private cTab      := "PA"
 Private cAlias    := "SX5"
 Private cCadastro := STR0001 //"Porte Anestesicos"
 Private nOpc      := 0                                                  
 Private cFiltro   := ""
 Private aRotina   := MenuDef()

 DbSelectArea(cAlias)
 DbSetOrder(1)      
 mBrowse(06, 01, 22, 75, "SX5",,,,,,,,,,,,,, "X5_TABELA = '"+cTab+"'")
 
Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � HSPAHA871� Autor �  Jose Orfeu           � Data �06/12/2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de Inclusao/Alteracao/Visualizacao                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSAHA871(nOpc)
 cSayCpo1 := STR0007 //"Porte Anestesico"
 cSayCpo2 := STR0008 //"Descricao"

 HS_TelSx5('HS_Exc87()',, nOpc)
Return

                                                                                                     
// Funcao de Exclusao
Function HS_Exc87()                         
 Local lRet := .T.
 DbSelectArea("GA7")
 DbSetOrder(4)
 If DbSeek(xFilial("GA7") + M->X5_CHAVE)
  HS_MsgInf(STR0010, STR0012, STR0013) //"Existe este Porte Anestesico no Cabecalho de Procedimentos (GA7). Impossivel Exclui-lo!"###"Atencao"###"Exclus�o n�o Permitida"
  lRet := .F.
 Endif

 DbSelectArea("GA3")
 DbSetOrder(2)
 If DbSeek(xFilial("GA3") + M->X5_CHAVE)
  HS_MsgInf(STR0011, STR0012, STR0013) //"Existe este Porte Anestesico na amarra��o Tabela de Procedimento e Porte Anestesico (GA3). Impossivel Exclui-lo!"###"Atencao"###"Exclus�o n�o Permitida"
  lRet := .F.
 Endif      
 
 DbSelectArea(cAlias)
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
                     {OemToAnsi(STR0003), 'HSAHA871(2)', 0, 2, 0, nil},; //"Visualizar"
                     {OemToAnsi(STR0004), 'HSAHA871(3)', 0, 3, 0, nil},; //"Incluir"
                     {OemToAnsi(STR0005), 'HSAHA871(4)', 0, 4, 2, nil},; //"Alterar"
                     {OemToAnsi(STR0006), 'HSAHA871(5)', 0, 5, 1, nil}}  //"Excluir"
Return(aRotina)