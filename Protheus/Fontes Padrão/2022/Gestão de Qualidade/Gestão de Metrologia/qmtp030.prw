#include "protheus.ch"
#include "QMTP030.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QMTP030  � Autor � Denis Martins         � Data �10/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Painel de Gestao - "Instrumentos Emprestados"              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQMT                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QMTP030()

Local aRetPanel := {} //Array com os dados que ser�o exibidos no painel
Local nX

Private aDados  := {}

Pergunte("QMP30",.F.)

//Geracao dos Dados para o Browse
QMTGerEmp()

aAdd(aRetPanel,{||})
aAdd(aRetPanel,{STR0001,STR0002,STR0003,STR0004}) //"Instrumento","Dt.Saida","Prev.Retorno","Resp.Saida"
aAdd(aRetPanel,aDados)
aAdd(aRetPanel,{"LEFT","LEFT","CENTER","LEFT"})

Return aRetPanel

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QMTGerVen � Autor � Denis Martins         � Data �10/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera os dados do painel de gestao "Ins. Calibracao a Vencer"���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQMT                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QMTGerEmp()
Local cAliasQry := GetNextAlias()
Local dDatPra := dDataBase

MakeSqlExpr("QMP30")

//Selecionando as tabelas para garantir
//que elas existam antes da execucao da query
dbSelectArea("QML")

BeginSql Alias cAliasQry
	
	SELECT QML_INSTR, QML_DTRET, QML_FREQ, QML_FILRET, QML_RESRET FROM %table:QML% QML
	WHERE QML.QML_FILIAL = %xfilial:QML% AND
	      QML.QML_INSTR BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND 
	      QML.QML_DTRET BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% AND 
	      QML.QML_OK = '  ' AND
		  QML.QML_HRCOL = '     ' AND
  	 	  QML.%notDel% 
	ORDER BY QML_INSTR
	
EndSql
               
dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())         
		dDatPra := (STOD((cAliasQry)->QML_DTRET) + (cAliasQry)->QML_FREQ)
		dbSelectArea("QAA")
		dbSetOrder(1)
		If dbSeek(&((cAliasQry+"->QML_FILRET"))+&((cAliasQry+"->QML_RESRET")))
			cCodNom := QAA->QAA_APELID
		Else
			cCodNom := ((cAliasQry)->QML_RESRET)
		EndIf
		aAdd(aDados,{(cAliasQry)->QML_INSTR,STOD((cAliasQry)->QML_DTRET),dDatPra,cCodNom})
		dbSelectArea(cAliasQry)
		(cAliasQry)->(DbSkip())
	EndDo
EndIf

(cAliasQry)->(DbCloseArea())

Return