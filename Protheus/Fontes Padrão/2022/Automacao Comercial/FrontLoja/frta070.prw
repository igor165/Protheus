#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FRTA070	�Autor  � TOTVS	 	         � Data �  02/02/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Monitoramento do PDV                                       ���
�������������������������������������������������������������������������͹��
���Uso       � Front Loja ( Retaguarda )     							  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
   
Function FRTA070()

Local cAlias := "MDI"

Private aRotina   := {}
Private cCadastro := "Monitorar situa��es dos PDVs"

aAdd( aRotina, {"Pesquisar" ,"AxPesqui",0,1} )
aAdd( aRotina, {"Visualizar","AxVisual",0,2} )
aAdd( aRotina, {"Incluir"   ,'AxInclui',0,3} )
aAdd( aRotina, {"Alterar"   ,'AxAltera',0,4} )
aAdd( aRotina, {"Excluir"   ,'AxDeleta',0,5} )

DbSelectArea(cAlias)
DbSetOrder(1)
mBrowse(,,,,cAlias)
 
Return(Nil)

