#include "protheus.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHL02  � Autor � Rogerio Tabosa     � Data �  03/06/09   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE METODOS CLINICOS DE ANALISE LABORATORIAL  	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HSPAHL02()
Private cAlias := "GPB"
DbSelectArea(cAlias)
DbSetOrder(1)
AxCadastro(cAlias, "Cadastro de M�todos", /*"Fs_ExcB1()"*/ ) //"Cadastro de microorganismos"
Return(nil)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_EXCB1  �Autor  �Alessandro Freire   � Data �  27/04/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida a Exclusao do microorganismo.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*Function Fs_ExcB1()
Local lRet  := .T.
Local aArea := GetArea()

DbSelectArea("GEP")
DbSetOrder(3)
If DbSeek(xFilial("GEP")+GDH->GDH_CODVIR)  //GEP_FILIAL+GEP_CODMIC
 HS_MsgInf(STR0004,STR0003,STR0001) //"Exclusao nao permitida pois Microorganismo encontra-se na notificacao"###"Atencao""Cadastro de microorganismos"
 lRet := .F.
Endif       

RestArea(aArea)
Return(lRet) */