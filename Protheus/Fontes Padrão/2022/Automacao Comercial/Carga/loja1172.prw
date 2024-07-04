#INCLUDE "PROTHEUS.CH"

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA1172() ; Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCInitialLoadGroupConfig         � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Classe com os grupos de cargas                                         ���
���             �                                                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCInitialLoadGroupConfig From FWSerialize
	Data oTransferFiles
	Data oTransferTables
	Data oDateTime
	Data cDriver
	Data cExtension
	Data cOrder
	Data cEntireIncremental	
	Data cCode
	Data cName
	Data cDescription
	Data cCodeTemplate

	Method New()	

EndClass

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � New                               � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Construtor.                                                            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oTransferFiles: Objeto do tipo LJCInitiaLoadTransferFiles.             ���
���             � oTransferTables: Objeto do tipo LJCInitialLoadTransferTables.          ���
���             � oDateTime: Objeto TMKDateTime com a data e hora da gera��o.            ���
���             � cDriver: Driver utilizado na gera��o dos arquivos.                     ���
���             � cExtension: Extens�o dos arquivos gerados.                             ���
���             � cOrder: ordem                                                          ���
���             � cEntireIncremental:1 = inteira / 2 = incremental                       ���
���             � cCode: codigo do grupo de carga                                        ���
���             � cName: nome do grupo de carga                                          ���
���             � cDescription: descricao do grupo de carga.                             ���
���             � cCodeTemplate: codigo do grupo de carga pai                             ���
����������������������������������������������������������������������������������������͹��
���    Retorno: �                                                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method New( oTransferFiles, oTransferTables, oDateTime, cDriver, cExtension , cOrder, cEntireIncremental, cCode, cName, cDescription, cCodeTemplate) Class LJCInitialLoadGroupConfig
	Self:oTransferFiles		:= oTransferFiles
	Self:oTransferTables		:= oTransferTables
	Self:oDateTime			:= oDateTime
	Self:cDriver				:= cDriver
	Self:cExtension			:= cExtension
	Self:cOrder				:= cOrder
	Self:cEntireIncremental	:= cEntireIncremental
	Self:cCode				:= cCode
	Self:cName				:= cName
	Self:cDescription			:= cDescription
	Self:cCodeTemplate			:= cCodeTemplate
	

Return







