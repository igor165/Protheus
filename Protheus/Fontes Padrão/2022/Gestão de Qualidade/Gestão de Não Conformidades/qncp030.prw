#include "protheus.ch"
#INCLUDE "QNCP030.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QNCP030  � Autor � Rafael S. Bernardi    � Data �02/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Painel de Gestao - Nao-Conformidades por Fornecedor        ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQNC                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QNCP030()

Local aRetPanel := {} //Array com os dados que ser�o exibidos no painel
Local nX

Private aDados  := {}

Pergunte("QNCP30",.F.)

//Geracao dos Dados por fornecedor
QNCGerFor()
aAdd(aRetPanel,{STR0001,{}})//"An�lise por Forncedor"
For nX := 1 To Len(aDados)
	aAdd(aRetPanel[1][2],{aDados[nX][1]+" - "+aDados[nX][2],Transform(aDados[nX][3],"@E 99999"),CLR_GREEN,Nil})
Next nX

//Geracao dos Dados por categoria
QNCGerCat()
aAdd(aRetPanel,{STR0002,{}})//"Analise por Categoria"
For nX := 1 To Len(aDados)
	aAdd(aRetPanel[2][2],{aDados[nX][1]+" - "+aDados[nX][2],Transform(aDados[nX][3],"@E 99999"),CLR_GREEN,Nil})
Next nX

//Geracao dos Dados por efeito
QNCGerEfe()
aAdd(aRetPanel,{STR0003,{}})//"An�lise por Efeito"
For nX := 1 To Len(aDados)
	aAdd(aRetPanel[3][2],{aDados[nX][1]+" - "+aDados[nX][2],Transform(aDados[nX][3],"@E 99999"),CLR_GREEN,Nil})
Next nX

//Geracao dos Dados por disposi��o
QNCGerDis()
aAdd(aRetPanel,{STR0004,{}})//"An�lise por Disposi��o"
For nX := 1 To Len(aDados)
	aAdd(aRetPanel[4][2],{aDados[nX][1]+" - "+aDados[nX][2],Transform(aDados[nX][3],"@E 99999"),CLR_GREEN,Nil})
Next nX

Return aRetPanel

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QNCGerFor � Autor � Rafael S. Bernardi    � Data �02/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera os dados para o combo 1 do painel de gestao            ���
���          �Nao-Conformidades por Fornecedor - Analise por Fornecedor   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQNC                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QNCGerFor()

Local cAliasQry := GetNextAlias()
Local cTForn    := Space(TamSX3("QI2_CODFOR")[1])

MakeSqlExpr("QNCP30")

//Selecionando as tabelas para garantir
//que elas existam antes da execucao da query
dbSelectArea("SA2")
dbSelectArea("QI2")

BeginSql Alias cAliasQry
	
	SELECT QI2.QI2_CODFOR, SA2.A2_NREDUZ, COUNT(QI2_CODFOR) NFNC FROM %table:QI2% QI2
	JOIN %table:SA2% SA2 ON SA2.A2_FILIAL = %xFilial:SA2% AND
							SA2.%NotDel% 
	WHERE QI2.QI2_FILIAL = %xFilial:QI2% AND
		  QI2.QI2_CODFOR = SA2.A2_COD AND
		  QI2.QI2_CODFOR <> %Exp:cTForn% AND
  	      QI2.QI2_STATUS = '3' AND
		  QI2.QI2_ORIGEM = 'QNC' AND
		  QI2.QI2_CODFOR BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
	      QI2.%NotDel%
	GROUP BY QI2.QI2_CODFOR, SA2.A2_NREDUZ
	
EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aDados ,{ AllTrim(&(cAliasQry+"->QI2_CODFOR")),AllTrim(&(cAliasQry+"->A2_NREDUZ")),&(cAliasQry+"->NFNC")} )
		(cAliasQry)->(DbSkip())
	EndDo
Else
	aAdd(aDados,{STR0005,"",0})//"N�o h� dados para exibi��o"
EndIf

(cAliasQry)->(DbCloseArea())

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QNCGerCat � Autor � Rafael S. Bernardi    � Data �02/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera os dados para o combo 2 do painel de gestao            ���
���          �Nao-Conformidades por Fornecedor - Analise por Categoria    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQNC                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QNCGerCat()

Local cAliasQry := GetNextAlias()
Local cTForn    := Space(TamSX3("QI2_CODCAT")[1])
aDados := {}

MakeSqlExpr("QNCP30")

BeginSql Alias cAliasQry
	
	SELECT QI2.QI2_CODCAT, COUNT(QI2_CODCAT) NFNC FROM %table:QI2% QI2
	JOIN %table:SA2% SA2 ON SA2.A2_FILIAL = %xFilial:SA2% AND
							SA2.%NotDel%
	WHERE QI2.QI2_FILIAL = %xFilial:QI2% AND
		  QI2.QI2_CODFOR = SA2.A2_COD AND
  	      QI2.QI2_STATUS = '3' AND
		  QI2.QI2_CODFOR BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
		  QI2.QI2_CODCAT <> %Exp:cTForn% AND
  		  QI2.QI2_ORIGEM = 'QNC' AND
	      QI2.%NotDel%
	GROUP BY QI2.QI2_CODCAT
	
EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aDados ,{ AllTrim(&(cAliasQry+"->QI2_CODCAT")),;
		Alltrim(FQNCNTAB("4",&(cAliasQry+"->QI2_CODCAT"))),;
		&(cAliasQry+"->NFNC")} )
		(cAliasQry)->(DbSkip())
	EndDo
Else
	aAdd(aDados,{STR0005,"",0})//"N�o h� dados para exibi��o"
EndIf

(cAliasQry)->(DbCloseArea())

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QNCGerEfe � Autor � Rafael S. Bernardi    � Data �02/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera os dados para o combo 3 do painel de gestao            ���
���          �Nao-Conformidades por Fornecedor - Analise por Efeito       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQNC                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QNCGerEfe()

Local cAliasQry := GetNextAlias()
Local cTForn    := Space(TamSX3("QI2_CODEFE")[1])
aDados := {}

MakeSqlExpr("QNCP30")

BeginSql Alias cAliasQry
	
	SELECT QI2.QI2_CODEFE, COUNT(QI2.QI2_CODEFE) NFNC FROM %table:QI2% QI2
	JOIN %table:SA2% SA2 ON SA2.A2_FILIAL = %xFilial:SA2% AND
					     	SA2.%NotDel%
	WHERE QI2.QI2_FILIAL = %xFilial:QI2% AND
		  QI2.QI2_CODFOR = SA2.A2_COD AND
  	      QI2.QI2_STATUS = '3' AND
		  QI2.QI2_CODFOR BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
		  QI2.QI2_CODEFE <> %Exp:cTForn% AND
  		  QI2.QI2_ORIGEM = 'QNC' AND
	      QI2.%NotDel%
	GROUP BY QI2.QI2_CODEFE
	
EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aDados ,{ AllTrim(&(cAliasQry+"->QI2_CODEFE")),;
		Alltrim(FQNCNTAB("2",&(cAliasQry+"->QI2_CODEFE"))),;
		&(cAliasQry+"->NFNC")} )
		(cAliasQry)->(DbSkip())
	EndDo
Else
	aAdd(aDados,{STR0005,"",0})//"N�o h� dados para exibi��o"
EndIf

(cAliasQry)->(DbCloseArea())

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QNCGerDis � Autor � Rafael S. Bernardi    � Data �02/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera os dados para o combo 4 do painel de gestao            ���
���          �Nao-Conformidades por Fornecedor - Analise por Disposicao   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQNC                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QNCGerDis()

Local cAliasQry := GetNextAlias()
Local cTForn    := Space(TamSX3("QI2_CODDIS")[1])
aDados := {}

MakeSqlExpr("QNCP30")

BeginSql Alias cAliasQry
	
	SELECT QI2.QI2_CODDIS, COUNT(QI2_CODDIS) NFNC FROM %table:QI2% QI2
	JOIN %table:SA2% SA2 ON SA2.A2_FILIAL = %xFilial:SA2% AND
							SA2.%NotDel%
	WHERE QI2.QI2_FILIAL = %xFilial:QI2% AND
		  QI2.QI2_CODFOR = SA2.A2_COD AND
  	      QI2.QI2_STATUS = '3' AND
		  QI2.QI2_CODFOR BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
		  QI2.QI2_CODDIS <> %Exp:cTForn% AND
  		  QI2.QI2_ORIGEM = 'QNC' AND
	      QI2.%NotDel%
	GROUP BY QI2.QI2_CODDIS
	
EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aDados ,{ AllTrim(&(cAliasQry+"->QI2_CODDIS")),;
		Alltrim(FQNCCHKDIS(&(cAliasQry+"->QI2_CODDIS"))),;
		&(cAliasQry+"->NFNC")} )
		(cAliasQry)->(DbSkip())
	EndDo
Else
	aAdd(aDados,{STR0005,"",0})//"N�o h� dados para exibi��o"
EndIf

(cAliasQry)->(DbCloseArea())

Return