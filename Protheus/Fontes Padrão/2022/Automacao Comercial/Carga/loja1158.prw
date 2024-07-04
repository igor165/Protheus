#INCLUDE "PROTHEUS.CH"


/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Fun��o: � LOJA1158                          � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Inicia o monitor da venda assistida off-line.                          ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum                                                                 ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Function LOJA1158()
	Local oMonitor := LJCMonitor():New()
	Local aApo := GetApoInfo("fwserialize.prw")
	
	LjGrvLog( "Carga","ID_INICIO")
		
	//bloqueio para avisar se a fwserialize estiver desatualizada.
	//eh fundamental a fwserialize acima de 28/09/2012 para evitar problema no consumo de memoria
	If aApo[4] >= CtoD("28/09/2012")	
		oMonitor:Show()
	Else
		Aviso( "Aten��o", "A data do fonte FWSERIALIZE.PRW deve ser superior ou igual a 28/09/2012. Atualize a lib para poder prosseguir", {"OK"} ) //atusx "Aten��o" "Este ambiente n�o possui cargas geradas a serem exclu�das" "OK"
	EndIf
	
	LjGrvLog( "Carga","ID_FIM")
	
Return