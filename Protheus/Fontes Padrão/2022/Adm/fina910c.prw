#Include "Protheus.ch"

/*�����������������������������������������������������������������������Ŀ��
���Programa  �FINA910C  � Autor � Rafael Rosa da Silva  � Data �05/08/2009���
�������������������������������������������������������������������������Ĵ��
���Locacao   � CSA              �Contato � 								  ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Listagem de Registros da tabela Conciliacao SITEF (FIF)	  ���
�������������������������������������������������������������������������Ĵ��
���Analista Resp.�  Data  � Bops � Manutencao Efetuada                    ���
�������������������������������������������������������������������������Ĵ*/
Function FINA910C()

Local cReport	:= "FINA910"			// Nome do Programa
Local lInd		:= .T.					// Retorna Indice SIX
Local cAlias	:= "FIF"
Local cTitulo	:= "Listagem de Conciliacao do SITEF"
Local cDescRel	:= "Listagem dos registros da tabela Conciliacao de registros do SITEF"

If TRepInUse()
	MPReport(cReport,cAlias,cTitulo,cDescRel,,lInd)
Else
    MsgInfo("Relatorio disponivel somente para a versao com TREPORT")
EndIf

Return

