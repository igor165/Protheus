#include "protheus.ch"
#include "msGraphi.ch"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QADP020  � Autor � Rafael S. Bernardi    � Data �19/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Painel de Gestao - Auditorias realizadas                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void            											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQAD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QADP020()

Local   aRetPanel := {} //Array com os dados que serao exibidos no painel
Local   nX
Local   aDesCpo   := SX3Desc({"QUB_FILIAL","QUB_NUMAUD"})
Private aDados    := {}

Pergunte("QADP20",.F.)

//Geracao dos Dados para o Browse
QADAudRea()

aAdd(aRetPanel,{||})
aAdd(aRetPanel,{aDesCpo[1],aDesCpo[2]})//Filial###Auditoria
aAdd(aRetPanel,aDados)
aAdd(aRetPanel,{"CENTER","LEFT"})

Return aRetPanel

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QADAudRea � Autor � Rafael S. Bernardi    � Data �19/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera os dados do painel de gestao Auditorias realizadas     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQAD                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QADAudRea()
Local cAliasQry := GetNextAlias()

mv_par01 := DtoS(mv_par01)
mv_par02 := DtoS(mv_par02)

dbSelectArea("QUB")
dbSelectArea("QUH")

MakeSqlExpr("QADP20")

BeginSql Alias cAliasQry

SELECT QUB.QUB_FILIAL, QUB.QUB_NUMAUD FROM %table:QUB% QUB
JOIN %table:QUH% QUH ON QUH.QUH_NUMAUD = QUB.QUB_NUMAUD AND
	QUH.QUH_CCUSTO BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% AND
	QUH.QUH_FILIAL = %xfilial:QUH% AND QUH.%NotDel%
WHERE QUB.QUB_FILIAL = %xfilial:QUB% AND
      QUB.QUB_STATUS = '4' AND
      QUB.QUB_ENCREA BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
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