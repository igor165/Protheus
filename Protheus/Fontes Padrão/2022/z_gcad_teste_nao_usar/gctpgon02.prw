#INCLUDE "GCTPgOn02.ch"
#INCLUDE "protheus.ch"
#INCLUDE "msgraphi.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GCTPgOn02� Autor � Marcos V. Ferreira    � Data � 14/03/07 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta array para Painel de Gestao On-line Tipo 1           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �GCTPgOn02()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Array = {{cText1,cValor,nColorValor,bClick},...}           ���
���          � cTexto1     = Texto da Coluna                       		  ���
���          � cValor      = Valor a ser exibido (string)          		  ���
���          � nColorValor = Cor do valor no formato RGB (opcional)       ���
���          � bClick      = Funcao executada no click do valor (opcional)���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAGCT                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function  GCTPgOn02()

Local aRet       := {}
Local cEncerrar  := GetNextAlias()	
Local dDataFim   := dDataBase
Local dDataFim30 := dDataBase+30

//������������������������������������������������������������������������Ŀ
//� Contratos a encerrar nos proximos 30 dias                              �
//��������������������������������������������������������������������������
BeginSql Alias cEncerrar

	SELECT COUNT(*) ENCERRAR
	
	FROM %table:CN9% CN9
	
	WHERE CN9.CN9_FILIAL = %xFilial:CN9% AND 
		  CN9_SITUAC IN ('02','03','04','05','06') AND 
		  CN9_DTFIM >= %Exp:dDataFim%   AND
		  CN9_DTFIM <= %Exp:dDataFim30% AND
   		  CN9.%NotDel%

EndSql

// Preenche array do Painel de Gestao Tipo 1
Aadd( aRet, { STR0001, StrZero((cEncerrar)->ENCERRAR,10),CLR_HBLUE, /*{ || bClick }*/ } )
(cEncerrar)->(DbCloseArea())

Return aRet
