#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1165.CH"

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA1165() ; Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCInitialLoadSpecialTableFactory � Autor: Vendas CRM � Data: 16/10/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Classe que fabrica os objetos de uma tabela especial.                  ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCInitialLoadSpecialTableFactory
	Method New()
	Method GetExporterByName()
	Method GetImporterByName()
	Method GetXFilialByName()
	Method IsSpecial()
	Method GetConfiguratorByName()
EndClass

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � New                               � Autor: Vendas CRM � Data: 16/10/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Construtor.                                                            ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Self                                                                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method New() Class LJCInitialLoadSpecialTableFactory
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetExporterByName                 � Autor: Vendas CRM � Data: 16/10/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega o exportador de uma determinada tabela especial.                  ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cName: Nome da tabela especial                                         ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � oExporter: Objeto exportador da tabela especial.                       ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetExporterByName( cName ) Class LJCInitialLoadSpecialTableFactory	
	Local oLJMessageManager	:= GetLJCMessageManager()
	Local oExporter := Nil

	Do Case
		Case AllTrim(Upper(cName)) == "SBI"
			oExporter := LJCInitialLoadSBIExporter():New()
		Otherwise
			oLJMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadSpecialTableFactory", 1, STR0001 + " '" + cName + "'.") ) // "N�o existe exportador para a tabela especial"
	EndCase
Return oExporter

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetImporterByName                 � Autor: Vendas CRM � Data: 16/10/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega o importador de uma determinada tabela especial.                  ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cName: Nome da tabela especial                                         ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � oExporter: Objeto importador da tabela especial.                       ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetImporterByName( cName ) Class LJCInitialLoadSpecialTableFactory	
	Local oLJMessageManager	:= GetLJCMessageManager()
	Local oImporter := Nil

	Do Case
		Case AllTrim(Upper(cName)) == "SBI"
			oImporter := LJCInitialLoadSBIImporter():New()
		Otherwise
			oLJMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadSpecialTableFactory", 1, STR0003 + " '" + cName + "'.") ) // "N�o existe importador para a tabela especial"
	EndCase
Return oImporter

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetXFilialByName                  � Autor: Vendas CRM � Data: 16/10/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega a filial da tabela de uma determinada tabela especial.            ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cName: Nome da tabela especial                                         ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � cRet: Filial da tabela especial                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetXFilialByName( cName ) Class LJCInitialLoadSpecialTableFactory
	Local oLJMessageManager	:= GetLJCMessageManager()
	Local cRet := Nil

	Do Case
		Case AllTrim(Upper(cName)) == "SBI"
			cRet := xFilial( "SB0" )
		Otherwise
			oLJMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadSpecialTableFactory", 1, STR0003 + " '" + cName + "'.") ) // "N�o existe importador para a tabela especial"
	EndCase
Return cRet

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � IsSpecial                         � Autor: Vendas CRM � Data: 16/10/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Retorna se uma determinada tabela � especial.                          ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cName: Nome da tabela especial                                         ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � lRet: Se � uma tabela especial ou n�o.                                 ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method IsSpecial( cName ) Class LJCInitialLoadSpecialTableFactory	
	Local lRet	:= .F.
	
	Do Case
		Case AllTrim(Upper(cName)) == "SBI"
			lRet := .T.
	EndCase
Return lRet

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetConfiguratorByName             � Autor: Vendas CRM � Data: 16/10/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega o configurador de uma tabela especial.                            ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � cName: Nome da tabela especial                                         ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � oConfigurador: Objeto configurador da tabela especial.                 ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetConfiguratorByName( cName ) Class LJCInitialLoadSpecialTableFactory
	Local oLJMessageManager	:= GetLJCMessageManager()
	Local oConfigurator		:= Nil
	
	Do Case
		Case AllTrim(Upper(cName)) == "SBI"
			oConfigurator := LJCInitialLoadSpecialTableSBIConfigurator():New()
		Otherwise
			oLJMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadSpecialTableFactory", 1, STR0002 + " '" + cName + "'.") ) // "N�o existe configurador para a tabela especial"
	EndCase
Return oConfigurator