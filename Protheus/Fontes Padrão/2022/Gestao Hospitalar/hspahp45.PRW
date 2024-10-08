#INCLUDE "hspahp45.ch"
#INCLUDE "protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �hspahp45  � Autor � Alessandro Freire  � Data �  06/05/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Manutencao de remessa                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HSPAHP45()

Local cFilP45

Private cCadastro := STR0001 //"Manuten��o de Remessa"

Private aRotina := MenuDef()

//���������������������������������������������������������������������Ŀ
//� Monta array com os campos para o Browse                             �
//�����������������������������������������������������������������������

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock


If ! Pergunte("HSPP45",.T.)
	Return(nil)
EndIf

/* 01 Convenio */
/* 02 Emissao Inicial */
/* 03 Emissao Final */

If Empty( mv_par01 )
	Aviso( STR0006, STR0007, { "Ok" }, 2 )  //"Aten��o"###"Conv�nio n�o pode ficar vazio"
	Return(nil)
EndIf

If Empty( mv_par03 )
	Aviso( STR0006, STR0008, { "Ok" }, 2 )  //"Aten��o"###"Data Final n�o pode ficar vazia"
	Return(nil)
EndIf

cFilP45 := "EXISTS( SELECT GCZ_SERIE, GCZ_NRFATU "
cFilP45 +=         "  FROM "+RetSqlName("GCZ")+" GCZ "
cFilP45 +=         " WHERE GCZ.D_E_L_E_T_ <> '*' AND "
cFilP45 +=         "       GCZ_FILIAL = '"+xFilial("GCZ")+"' AND "
cFilP45 +=         "       GCZ_SERIE = E1_PREFIXO AND "
cFilP45 +=         "       GCZ_NRFATU = E1_NUM ) "

dbSelectArea("SE1")
dbSetOrder(1)
mBrowse( 6,1,22,75,"SE1",,,,,,,,,,,,,, cFilP45)

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_P45Alt �Autor  �Alessandro Freire   � Data �  06/05/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Altera lotes ja faturados                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_P45Man(nOpcx)

Local aArea := GetArea()

dbSelectArea("GAT")
dbSetOrder(4)
If ! dbSeek(xFilial("GAT") + SE1->E1_PREFIXO + SE1->E1_NUM )
	MsgInfo(STR0009, STR0010) //"Este t�tulo n�o est� atrelado a nenhum lote."###"Erro de Integridade."
Else
	HS_P18Man(nOpcx)	
EndIf

RestArea( aArea )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Tiago Bandeira        � Data � 10/06/07 ���
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
Local aRotina :=	{{STR0002,"AxPesqui"    , 0, 1, 0, nil},; //"Pesquisar "
                     {STR0003,"HS_P45Man(2)", 0, 2, 0, nil},; //"Visualizar"
                     {STR0004,"HS_P45Man(4)", 0, 4, 0, nil},; //"Alterar   "
                     {STR0005,"HS_P45Man(5)", 0, 5, 0, nil},; //"Excluir   " 
                     {STR0011,"HSPAHRDX()"  , 0, 2, 0, nil}}  //"Protocolo"
Return(aRotina)