#INCLUDE "HSPAHA45.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA45  � Autor � Manoel Filho       � Data �  08/02/02   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE PROCEDIMENTOS PARA O CCIH                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHA45()

 Private cTab      := "PR"
 Private cAlias    := "SX5"
 Private cCadastro := STR0001 //"Procedimentos para CCIH"
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
���Fun��o    � HSPAHA451� Autor �  Manoel Filho         �      � 08/02/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de Inclusao/Alteracao/Visualizacao                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSAHA451(nOpc)

 cSayCpo1 := STR0007 //"Codigo"
 cSayCpo2 := STR0008 //"Procedimento"

 HS_TelSx5('HS_Exc45()',,nOpc, 3)


Return

// Funcao de Exclusao
Function HS_Exc45()
Local lRet := .T.
Local cAliasOld := Alias()

DbSelectArea("GEI")
DbSetOrder(3)
If DbSeek(xFilial("GEI")+M->X5_CHAVE)  //GEI_FILIAL+GEI_COPRO
 HS_MsgInf(STR0010, STR0011, STR0001) //"Exclusao nao permitida pois Procedimento encontra-se na notificacao"###"Atencao"###"Procedimentos para CCIH"
 lRet := .F.
Endif       

DbSelectArea(cAliasOld)
If lRet    
 nOpca := 1
 oDlg:End()          
Endif
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
                     {OemToAnsi(STR0003), 'HSAHA451(2)', 0, 2, 0, nil},; //"Visualizar"
                     {OemToAnsi(STR0004), 'HSAHA451(3)', 0, 3, 0, nil},; //"Incluir"
                     {OemToAnsi(STR0005), 'HSAHA451(4)', 0, 4, 2, nil},; //"Alterar"
                     {OemToAnsi(STR0006), 'HSAHA451(5)', 0, 5, 1, nil}}  //"Excluir"
Return(aRotina)