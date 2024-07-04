#INCLUDE "PROTHEUS.CH"

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA1153() ; Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCInitialLoadRequest             � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Classe que representa uma requisi��o de carga.                         ���
���             �                                                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCInitialLoadRequest From FWSerialize
	Data oResult
	Data oClient
	Data lDownload
	Data lImport
	Data lActInChildren	
	Data lKillOtherThreads
	Data aSelection				//cargas selecionadas para execucao (download ou importacao) - mesmo indice do array contido em oResult
	Data lUpdateAll 				//Determina se a atualizacao eh com selecao automatica de todas as incrementais necessarias pra deixar o ambiente atualizado
	Data lIsExpress				//Determina se o carregamento da carga sera em modo express (utilizado para abortar o protheus em casos de falha no carregamento)
	Data lLoadPSS					//Determina se carrega o sigapss - arquivo de senhas
	
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
��� Parametros: � oResult: Objeto LJCInitialLoadMakerResult com o resultado da gera��o   ���
���             � da carga.                                                              ���
���             � oClient: Cliente a ser requisitado.                                    ���
���             � lDownload: .T. para efetuar o download no cliente, .F. n�o.            ���
���             � lImport: .T. para efetuar importa��o no cliente, .F. n�o.              ���
���             � lActInChildren: .T. para replicar a��o para os filhos, .F. n�o.        ���
���             � lKillOtherThreads: .T. para se necess�rio derrubar os processos,       ���
���             � .F. n�o                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: �                                                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method New( oResult, oClient, lDownload, lImport, lActInChildren, lKillOtherThreads, aSelection, lUpdateAll, lIsExpress, lLoadPSS ) Class LJCInitialLoadRequest
	
	Default lUpdateAll 		:= .F.
	Default lIsExpress			:= .F.
	Default lImport 			:= .F.
	Default lDownload 		:= .F.
	Default lActInChildren 	:= .F.
	Default lKillOtherThreads 	:= .F.
	Default lLoadPSS			:= .F.
	Default aSelection 		:= {}
		
	Self:oResult			:= oResult
	Self:oClient			:= oClient
	Self:lDownload		:= lDownload
	Self:lImport			:= lImport
	Self:lActInChildren	:= lActInChildren
	Self:lKillOtherThreads	:= lKillOtherThreads
	Self:aSelection		:= aSelection
	Self:lUpdateAll		:= lUpdateAll
	Self:lLoadPSS			:= lLoadPSS
	
Return