#INCLUDE "HSPAHABI.ch"
#INCLUDE "protheus.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHABI  � Autor � MARCELO JOSE       � Data �  16/06/05   ���
�������������������������������������������������������������������������͹��
���Descricao � MOTIVO DE ENCERRAMENTO DA SOLICITACAO                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
���Altera��es� L.Gustavo Caloi 28/03/06 -> Padroniza��o da HS_MsgInf()    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HSPAHABI()

 Private cCadastro := STR0001 //"Cadastro de MOTIVO DE ENCERRAMENTO DA SOLICITACAO"

 Private aRotina := MenuDef()

 Private cDelFunc := "HS_EXCABI()" // Validacao para a exclusao. Pode-se utilizar ExecBlock

 Private cString := "GF2"

 dbSelectArea("GF2")
 dbSetOrder(1)

 dbSelectArea(cString)
 mBrowse( 6,1,22,75,cString)

Return(NIL)       

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_EXCABI � Autor � MARIO ARIZONO      � Data �  19/12/05   ���
�������������������������������������������������������������������������͹��
���Descricao � FUNCAO PARA VALIDACAO DA EXCLUSAO                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GESTAO HOSPITALAR                                          ���
�������������������������������������������������������������������������ͼ�� 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

FUNCTION HS_EXCABI()
 
 Local lRet := .T.
 
 DbselectArea("GAI")
 Dbsetorder(7)
 
 If DBSeek(xFilial("GAI")+GF2->GF2_CODENC)   //GAI_FILIAL+GAI_CODENC
  HS_MsgInf(STR0007, STR0008, STR0009)//"Motivo nao pode ser excluido, pois esta sendo usado na farmacia"###"Atencao"###"Va�ida�ao de exc�usao"
  lRet:= .F.
 Endif  
 
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
                     {STR0004, "AxInclui", 0, 3, 0, nil},; //"Incluir"
                     {STR0005, "AxAltera", 0, 4, 0, nil},; //"Alterar"
                     {STR0006, "AxDeleta", 0, 5, 0, nil}}  //"Excluir" 
Return(aRotina)