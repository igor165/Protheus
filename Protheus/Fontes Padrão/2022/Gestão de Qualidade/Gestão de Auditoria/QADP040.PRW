#include "protheus.ch"
#INCLUDE "QADP040.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QADP040  � Autor � Rafael S. Bernardi    � Data �20/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Painel de Gestao - Nao-Conformidades por Auditoria         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQAD                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QADP040()

Local aRetPanel := {} //Array com os dados que ser�o exibidos no painel
//Categorias das NCs
Local aCateg    := {STR0001,STR0002,STR0003}//"Baixa"###"Media"###"Alta"
//Gera NC?
Local aGerAC    := {STR0004,STR0005}//"Sim"###"Nao"
Local nX

Private aDados  := {}

Pergunte("QADP40",.F.)

//Geracao dos Dados NCs por Auditorias
QADGerNNC()
aAdd(aRetPanel,{STR0006,{}})//"Auditorias"
For nX := 1 To Len(aDados)
	aAdd(aRetPanel[1][2],{aDados[nX][1],Transform(aDados[nX][2],"@E 99999"),CLR_GREEN,Nil})
Next nX

//Geracao dos Dados Categoria das NCs
QADGerCat()
aAdd(aRetPanel,{STR0007,{}})//"Categorias"
For nX := 1 To Len(aDados)
	aAdd(aRetPanel[2][2],{aDados[nX][1]+" - "+IIF(aDados[nX][2] == -1 ,"",aCateg[Val(aDados[nX][1])]),;
	IIF(aDados[nX][2] = -1,"0",Transform(aDados[nX][2],"@E 99999")),CLR_GREEN,Nil})
Next nX

//Geracao dos Dados da Acoes Corretivas
QADGerACo()
aAdd(aRetPanel,{STR0008,{}})//"Acao Corretiva?"
For nX := 1 To Len(aDados)
	aAdd(aRetPanel[3][2],{aDados[nX][1]+" - "+IIF(aDados[nX][2] == -1,"",aGerAC[Val(aDados[nX][1])]),;
	IIF(aDados[nX][2] = -1,"0",Transform(aDados[nX][2],"@E 99999")),CLR_GREEN,Nil})
Next nX

Return aRetPanel

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QADGerNNC � Autor � Rafael S. Bernardi    � Data �20/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera os dados para o combo 1 do painel de gestao            ���
���          �Nao-Conformidades por Auditoria - Analise por Auditoria     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQAD                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QADGerNNC()
Local cAliasQry := GetNextAlias()

mv_par03 := DtoS(mv_par03)
mv_par04 := DtoS(mv_par04)

MakeSqlExpr("QADP40")

//Selecionando as tabelas para garantir
//que elas existam antes da execucao da query
dbSelectArea("QUB")
dbSelectArea("QUG")

BeginSql Alias cAliasQry
	
	SELECT QUG.QUG_NUMAUD, COUNT(QUG.QUG_NUMAUD) NNC FROM %table:QUG% QUG
	JOIN %table:QUB% QUB ON QUB.QUB_FILIAL = %xFilial:QUB% AND 
		QUB.QUB_NUMAUD = QUG.QUG_NUMAUD AND
		QUB.QUB_ENCREA BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% AND
		QUB.QUB_STATUS = '4' AND QUB.%NotDel%
	WHERE QUG.QUG_FILIAL = %xfilial:QUG% AND
	      QUG.QUG_NUMAUD BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
	      QUG.%NotDel%
	GROUP BY QUG.QUG_NUMAUD
	
EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aDados ,{&(cAliasQry+"->QUG_NUMAUD"),&(cAliasQry+"->NNC")})
		(cAliasQry)->(DbSkip())
	EndDo
Else
	aAdd(aDados,{STR0009,0})//"Nao ha dados para exibir"
EndIf

(cAliasQry)->(DbCloseArea())

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QADGerCat � Autor � Rafael S. Bernardi    � Data �20/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera os dados para o combo 1 do painel de gestao            ���
���          �Nao-Conformidades por Auditoria - Analise por Categoria     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQAD                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QADGerCat()
Local cAliasQry := GetNextAlias()

aDados := {}

MakeSqlExpr("QADP40")

BeginSql Alias cAliasQry
	
	SELECT QUG.QUG_CATEG, COUNT(QUG.QUG_CATEG) NNC FROM %table:QUG% QUG
	JOIN %table:QUB% QUB ON QUB.QUB_FILIAL = %xfilial:QUG% AND
		QUB.QUB_NUMAUD = QUG.QUG_NUMAUD AND
		QUB.QUB_ENCREA BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% AND
		QUB.QUB_STATUS = '4' AND QUB.%NotDel%
	WHERE QUG.QUG_FILIAL = %xfilial:QUG% AND
	      QUG.QUG_NUMAUD BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
	      QUG.%NotDel%
	GROUP BY QUG.QUG_CATEG
	
EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aDados ,{&(cAliasQry+"->QUG_CATEG"),&(cAliasQry+"->NNC")})
		(cAliasQry)->(DbSkip())
	EndDo
Else
	aAdd(aDados,{STR0009,-1,"0"})//"Nao ha dados para exibir"
EndIf

(cAliasQry)->(DbCloseArea())

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QADGerACo � Autor � Rafael S. Bernardi    � Data �20/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera os dados para o combo 3 do painel de gestao            ���
���          �Nao-Conformidades por Auditoria - Analise por: Acao         ���
���          �corretiva                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQAD                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QADGerACo()
Local cAliasQry := GetNextAlias()

aDados := {}

MakeSqlExpr("QADP40")

BeginSql Alias cAliasQry
	
	SELECT QUG.QUG_ACACOR, COUNT(QUG.QUG_ACACOR) NNC FROM %table:QUG% QUG
	JOIN %table:QUB% QUB ON QUB.QUB_FILIAL = %xfilial:QUG% AND
		QUB.QUB_NUMAUD = QUG.QUG_NUMAUD AND
		QUB.QUB_ENCREA BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% AND
		QUB.QUB_STATUS = '4' AND QUB.%NotDel%
	WHERE QUG.QUG_FILIAL = %xfilial:QUG% AND
	      QUG.QUG_NUMAUD BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
	      QUG.%NotDel%
	GROUP BY QUG.QUG_ACACOR
	
EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aDados ,{&(cAliasQry+"->QUG_ACACOR"),&(cAliasQry+"->NNC")})
		(cAliasQry)->(DbSkip())
	EndDo
Else
	aAdd(aDados,{STR0009,-1,"0"})//"Nao ha dados para exibir"
EndIf

(cAliasQry)->(DbCloseArea())

Return