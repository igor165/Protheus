#Include "LOJA070.CH"
#Include "PROTHEUS.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWADAPTEREAI.CH"

/*�����������������������������������������������������������������������������
���Programa  �IntegDef  �Autor  � Vendas Cliente       � Data �  25/01/17   ���
���������������������������������������������������������������������������͹��
���Descricao � Mensagem �nica												���
�����������������������������������������������������������������������������*/
Function LOJA070A()
//Funcao criada apenas para que o fonte seja interpretado no RPO 
Return(Nil)
/*�����������������������������������������������������������������������������
���Programa  �IntegDef  �Autor  � Vendas Cliente       � Data �  25/01/17   ���
���������������������������������������������������������������������������͹��
���Descricao � Mensagem �nica												���
�����������������������������������������������������������������������������*/
Static Function IntegDef( cXml, nTypeTrans, cTypeMessage )
Local aRet := {}
aRet:= LOJI070A(cXml, nTypeTrans, cTypeMessage)
Return aRet
