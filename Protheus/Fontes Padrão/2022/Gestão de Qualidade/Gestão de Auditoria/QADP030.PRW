#include "protheus.ch"
#include "msGraphi.ch"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QADP030  � Autor � Rafael S. Bernardi    � Data �19/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Painel de Gestao - Auditorias previstas                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void            											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQAD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QADP030()

Local   aRetPanel := {} //Array com os dados que serao exibidos no painel
Local   nX
Local   aDesCpo   := SX3Desc({"QUA_FILIAL","QUA_NUMAUD","QUA_ALOC","QUM_CCUSTO"})
Private aDados    := {}

Pergunte("QADP30",.F.)

//Geracao dos Dados para o Browse
QADAudPre()

aAdd(aRetPanel,{||})
aAdd(aRetPanel,{aDesCpo[1],aDesCpo[2],aDesCpo[3],aDesCpo[4]})//Filial###Auditoria###Alocacao###Departamento
aAdd(aRetPanel,aDados)
aAdd(aRetPanel,{"CENTER","LEFT","CENTER","CENTER"})

Return aRetPanel

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QADAudPre � Autor � Rafael S. Bernardi    � Data �19/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera os dados do painel de gestao Auditorias previstas      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQAD                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QADAudPre()
Local cAliasQry := GetNextAlias()

mv_par01 := DtoS(mv_par01)
mv_par02 := DtoS(mv_par02)

MakeSqlExpr("QADP30")

dbSelectArea("QUA")
dbSelectArea("QUM")

BeginSql Alias cAliasQry

SELECT QUA.QUA_FILIAL, QUA.QUA_NUMAUD, QUA.QUA_ALOC, QUM.QUM_CCUSTO FROM %table:QUA% QUA
JOIN %table:QUM% QUM ON QUM.QUM_NUMAUD = QUA.QUA_NUMAUD AND
	QUM.QUM_CCUSTO BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% AND
	QUM.QUM_FILIAL = QUA.QUA_FILIAL AND QUM.%NotDel%
WHERE QUA.QUA_FILIAL = %xFilial:QUA% AND
      QUA.QUA_STATUS = '1' AND
      QUA.QUA_ALOC BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
      QUA.%NotDel%
ORDER BY QUA.QUA_NUMAUD, QUM.QUM_CCUSTO

EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		aAdd(aDados,{&(cAliasQry+"->QUA_FILIAL"),&(cAliasQry+"->QUA_NUMAUD"),StoD(&(cAliasQry+"->QUA_ALOC")),&(cAliasQry+"->QUM_CCUSTO")})
		(cAliasQry)->(DbSkip())
	EndDo
Else
	aAdd(aDados,{"","","",""})
EndIf

(cAliasQry)->(DbCloseArea())

Return Nil