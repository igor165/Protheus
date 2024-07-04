#include "protheus.ch"
#INCLUDE "QNCP010.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QNCP010  � Autor � Rafael S. Bernardi    � Data �27/02/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Painel de Gestao - Nao-Conformidades por Produto           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQNC                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QNCP010()

Local aRetPanel := {} //Array com os dados que ser�o exibidos no painel
Local nX

Private aDados  := {}

Pergunte("QNCP10",.F.)

//Geracao dos Dados das grandezas escalares
QNCGerEsc()
aAdd(aRetPanel,{STR0001,{}})//"An�lise por Produtos"
For nX := 1 To Len(aDados)
	aAdd(aRetPanel[1][2],{aDados[nX][1]+" - "+aDados[nX][2],Transform(aDados[nX][3],"@E 99999"),CLR_GREEN,Nil})
Next nX

//Geracao dos Dados das grandezas percetuais
QNCGerPer()
aAdd(aRetPanel,{STR0002,{}})//"An�lise por Pencentual"
For nX := 1 To Len(aDados)
	aAdd(aRetPanel[2][2],{aDados[nX][1]+" - "+aDados[nX][2],Transform(aDados[nX][3],"@E 999.99%"),CLR_GREEN,Nil})
Next nX

Return aRetPanel

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QNCGerEsc � Autor � Rafael S. Bernardi    � Data �27/02/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera os dados para o combo 1 do painel de gestao            ���
���          �Nao-Conformidades por Produto - Analise por Numeros         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQNC                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QNCGerEsc()
Local cAliasQry := GetNextAlias()

mv_par03 := DtoS(mv_par03)
mv_par04 := DtoS(mv_par04)

MakeSqlExpr("QNCP10")

//Selecionando as tabelas para garantir
//que elas existam antes da execucao da query
dbSelectArea("SB1")
dbSelectArea("QI2")

BeginSql Alias cAliasQry
	
	SELECT DISTINCT SB1.B1_COD, SB1.B1_DESC, COUNT(B1_COD) NFNC FROM %table:SB1% SB1
	JOIN %table:QI2% QI2 ON QI2.QI2_CODPRO = SB1.B1_COD AND
							QI2.QI2_ORIGEM = 'QNC' AND
							QI2.QI2_OCORRE BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% AND
							QI2.%NotDel%
	WHERE SB1.B1_FILIAL = QI2.QI2_FILIAL AND
	      SB1.B1_COD BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
	      SB1.%NotDel%
	GROUP BY SB1.B1_COD, SB1.B1_DESC
	
EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aDados ,{ AllTrim(&(cAliasQry+"->B1_COD")),AllTrim(&(cAliasQry+"->B1_DESC")),&(cAliasQry+"->NFNC")} )
		(cAliasQry)->(DbSkip())
	EndDo
Else
	aAdd(aDados,{STR0003,"",0})
EndIf

(cAliasQry)->(DbCloseArea())

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QNCGerPer � Autor � Rafael S. Bernardi    � Data �27/02/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera os dados para o combo 2 do painel de gestao            ���
���          �Nao-Conformidades por Produto - Analise por Percentual      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGAQNC                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QNCGerPer()
Local soma := 0
Local nX

If Len(aDados) != 0
	For nX := 1 To Len(aDados)
		soma += aDados[nX][3]
	Next nX
	
	For nX := 1 To Len (aDados)
		aDados[nX][3] := (aDados[nX][3] / soma)*100
	Next nX
EndIf

Return