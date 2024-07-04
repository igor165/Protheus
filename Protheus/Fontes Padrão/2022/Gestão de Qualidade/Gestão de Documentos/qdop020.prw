#include "protheus.ch"
#include "msGraphi.ch"
#include "QDOP020.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QDOP020  � Autor � Rafael S. Bernardi    � Data �05/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Painel de Gestao - "Documentos Vencidos e a Vencer"        ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQDO                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QDOP020()

Local aRetPanel := {} //Array com os dados que ser�o exibidos no painel
Local nX

Private aDados  := {}

Pergunte("QDOP20",.F.)

//Geracao dos Dados para o Browse
QDOGerPan()

aAdd(aRetPanel,{||})
aAdd(aRetPanel,{STR0001,STR0002,STR0003,STR0004})//"Revis�o"###"Doc."###"Dt. Venc."###"Status"
aAdd(aRetPanel,aDados)
aAdd(aRetPanel,{"CENTER","LEFT","CENTER","CENTER"})

Return aRetPanel

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QDOGerPan � Autor � Rafael S. Bernardi    � Data �05/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera os dados do painel de gestao "Posicao dos Documentos"  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQDO                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QDOGerPan()
Local cAliasQry := GetNextAlias()
Local cStatus
Local nX

mv_par01 := DtoS(mv_par01)
mv_par02 := DtoS(mv_par02)

MakeSqlExpr("QDOP20")

//Selecionando as tabelas para garantir
//que elas existam antes da execucao da query
dbSelectArea("QDH")

BeginSql Alias cAliasQry
	
	SELECT QDH.QDH_RV, QDH.QDH_DOCTO, QDH.QDH_DTLIM FROM %table:QDH% QDH
	WHERE QDH.QDH_FILIAL = %xfilial:QDH% AND 
		  QDH.QDH_STATUS = 'L  ' AND QDH.QDH_DTLIM <> '        ' AND 
		  QDH.QDH_CANCEL <> 'S' AND 
	      QDH.QDH_DTLIM BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
	      QDH.QDH_OBSOL = 'N' AND
	      QDH.%notdel%
	ORDER BY QDH.QDH_DTLIM, QDH.QDH_DOCTO
	
EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		aAdd(aDados,{&(cAliasQry+"->QDH_RV"),&(cAliasQry+"->QDH_DOCTO"),StoD(&(cAliasQry+"->QDH_DTLIM"))})
		(cAliasQry)->(DbSkip())
	EndDo
	For nX := 1 To Len(aDados)
		cStatus := IIF(aDados[nX][3] < dDataBase,STR0005,STR0006)//"Vencido" | "� Vencer"
		aAdd(aDados[nX],cStatus)
	Next nX
Else
	aAdd(aDados,{"","","",""})
EndIf

(cAliasQry)->(DbCloseArea())

Return