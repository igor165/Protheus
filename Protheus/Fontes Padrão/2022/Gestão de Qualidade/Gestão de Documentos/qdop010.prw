#include "protheus.ch"
#include "msGraphi.ch"
#include "QDOP010.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QDOP010  � Autor � Rafael S. Bernardi    � Data �05/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Painel de Gestao - "Posicao dos Documentos"                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQDO                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QDOP010()

Local aRetPanel := {} //Array com os dados que ser�o exibidos no painel
Local nX

Private aDados  := {{},{},{}}

//Geracao dos Dados para o Grafico
QDOGerGra()

aAdd(aRetPanel,GRP_BAR)
aAdd(aRetPanel,{||})
For nX := 1 To Len(aDados)
	aAdd(aRetPanel,aDados[nX])
Next nX
aAdd(aRetPanel,STR0001)//"Qtd. Docs. X Status"

Return aRetPanel

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QDOGerGra � Autor � Rafael S. Bernardi    � Data �27/02/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera os dados do painel de gestao "Posicao dos Documentos"  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQDO                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QDOGerGra()
Local cAliasQry := GetNextAlias()

//Selecionando as tabelas para garantir
//que elas existam antes da execucao da query
dbSelectArea("QDH")

BeginSql Alias cAliasQry
	
	SELECT DISTINCT QDH.QDH_STATUS, COUNT(QDH.QDH_STATUS) NDOC FROM %table:QDH% QDH
	WHERE QDH.QDH_FILIAL = %xfilial:QDH% AND
		  QDH.QDH_STATUS <> 'L' AND
	      QDH.%NotDel%
	GROUP BY QDH.QDH_STATUS
	
EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		aAdd(aDados[1],SX5Desc("Q7",&(cAliasQry+"->QDH_STATUS")))
		aAdd(aDados[3],{&(cAliasQry+"->NDOC")})
		(cAliasQry)->(DbSkip())
	EndDo
EndIf

If Len(aDados[1]) > 0
	aDados[2] := aClone(aDados[1])
EndIf

(cAliasQry)->(DbCloseArea())

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �SX5Desc   � Autor � Rafael S. Bernardi    � Data �05/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna a descricao do status do documento                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 = Chave do SX5  									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQDO                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function SX5Desc(cTabela,cChave)
Local aArea := GetArea()
Local aSX5  := FWGetSX5(cTabela)
Local nX    := 0
Local cRet

For nX := 1 To Len(aSX5)
	If aSX5[nX][1] == xFilial("SX5") .And. AllTrim(aSX5[nX][3]) == AllTrim(cChave)
		cRet := aSX5[nX][4] 
	EndIf
Next nX

RestArea(aArea)

Return cRet