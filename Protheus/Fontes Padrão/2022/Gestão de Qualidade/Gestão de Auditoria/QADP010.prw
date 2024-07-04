#include "protheus.ch"
#include "msGraphi.ch"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QADP010  � Autor � Rafael S. Bernardi    � Data �19/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Painel de Gestao - Auditorias em andamento                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void            											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQAD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QADP010()

Local aRetPanel := {} //Array com os dados que serao exibidos no painel
Local nX
Local aDesCpo   := SX3Desc({"QUB_FILIAL","QUB_NUMAUD"})
Private aDados  := {}

//Geracao dos Dados para o Browse
QADGerAud()

aAdd(aRetPanel,{||})
aAdd(aRetPanel,{aDesCpo[1],aDesCpo[2]})//Filial###Auditoria
aAdd(aRetPanel,aDados)
aAdd(aRetPanel,{"CENTER","LEFT"})

Return aRetPanel

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QIPGerAud � Autor � Rafael S. Bernardi    � Data �19/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera os dados do painel de gestao Auditorias em aberto      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQAD                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QADGerAud()
Local cAliasQry := GetNextAlias()
Local nX
dbSelectArea("QUB")
BeginSql Alias cAliasQry

SELECT QUB.QUB_FILIAL, QUB.QUB_NUMAUD FROM %table:QUB% QUB
WHERE QUB.QUB_FILIAL = %xfilial:QUB% AND
      QUB.QUB_STATUS <> '4' AND
      QUB.%NotDel%
ORDER BY QUB.QUB_NUMAUD

EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		aAdd(aDados,{&(cAliasQry+"->QUB_FILIAL"),&(cAliasQry+"->QUB_NUMAUD")})
		(cAliasQry)->(DbSkip())
	EndDo
Else
	aAdd(aDados,{"",""})
EndIf

(cAliasQry)->(DbCloseArea())

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �SX3Desc   � Autor � Rafael S. Bernardi    � Data �17/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Devolve array com a descricao dos campos no SX3             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = Array com nomes dos campos que se quer a descricao ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQIP                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function SX3Desc(aParam)
Local aRet  := {}
Local aArea := GetArea()
Local nOrdem := SX3->(IndexOrd())
Local nX

dbSelectArea("SX3")
dbSetOrder(2)

For nX := 1 to Len(aParam)
	dbSeek(aParam[nX])
	aAdd(aRet, X3Descric())
Next nX

SX3->(dbSetOrder(nOrdem))
RestArea(aArea)
Return aRet