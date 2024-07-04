#include "protheus.ch"
#include "msGraphi.ch"
#include "QMTP010.CH"

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
Function QMTP010()

Local aRetPanel := {} //Array com os dados que ser�o exibidos no painel
Local nX

Private aDados  := {}
DBSELECTAREA("QM2")
DBSELECTAREA("QM6")
Pergunte("QMP10",.F.)

//Geracao dos Dados para o Browse
QMTGerPan()

aAdd(aRetPanel,{||})
aAdd(aRetPanel,{STR0001,STR0002,STR0003}) //"Instrumento","Revisao","Validade da Afericao"
aAdd(aRetPanel,aDados)
aAdd(aRetPanel,{"LEFT","LEFT","CENTER"})

Return aRetPanel

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QMTGerPan � Autor � Denis Martins         � Data �07/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera os dados do painel de gestao "Ins. Calibracao Vencida" ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQMT                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QMTGerPan()
Local cAliasQry := GetNextAlias()
Local cStatus
Local nX
Local cDataQM2 := DTOS(dDatabase+1000)
Local cmv_par01 := DtoS(mv_par01)
Local cmv_par02 := DtoS(mv_par02)

MakeSqlExpr("QMP10")

//Selecionando as tabelas para garantir
//que elas existam antes da execucao da query
dbSelectArea("QM2")

BeginSql Alias cAliasQry
	
	SELECT DISTINCT QM2_INSTR, QM2_REVINV, QM2_REVINS, QM2_VALDAF FROM %table:QM2% QM2
	WHERE QM2.QM2_FILIAL = %xfilial:QM2% AND
	      QM2.QM2_VALDAF BETWEEN %Exp:cmv_par01% AND %Exp:cmv_par02% AND 
   	      QM2.QM2_FLAG = '1'  
	ORDER BY QM2_INSTR, QM2_REVINV
	
EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())         
		//Busca na QM6 para ver se nao existe calibracao...	
		dbSelectArea("QM6")
		dbSetOrder(4)
		If dbSeek(xFilial("QM6")+&((cAliasQry+"->QM2_INSTR"))+&((cAliasQry+"->QM2_REVINV")))
			If DTOS(QM6->QM6_DATA) < (cAliasQry)->QM2_VALDAF
				aAdd(aDados,{(cAliasQry)->QM2_INSTR,(cAliasQry)->QM2_REVINS,StoD((cAliasQry)->QM2_VALDAF)})
			Endif	
		Else
			If (cAliasQry)->QM2_VALDAF <= DtoS(dDataBase)
				aAdd(aDados,{(cAliasQry)->QM2_INSTR,(cAliasQry)->QM2_REVINS,StoD((cAliasQry)->QM2_VALDAF)})		
			Endif	
		Endif	
		(cAliasQry)->(DbSkip())
	EndDo
EndIf
      
(cAliasQry)->(DbCloseArea())

Return