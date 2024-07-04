#include "PROTHEUS.CH" 
#include "MSGRAPHI.CH"
#include "QIEP010.CH"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEP010  � Autor � Cicero Odilio Cruz    � Data � 05.03.07  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Painel de Gestao - Indice de Qualidade Fornecedor X Produto ���
��������������������������������������������������������������������������Ĵ��
���Parametros�                 											   ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQIE                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function QIEP010()

Local aInfo     := {}
Local aInfAux   := {}
Local nCnt      := 0
Local nMax      := 0
Local cMsg      := ""
Local aRetPanel := {}

DbSelectArea("SB1")
DbSelectArea("SA2")

aInfAux := aClone(QIEGerQry()) //Funcao para alimentar o array

/*
����������������������������������������������������������Ŀ
� Estrutura do Array aInfAux :                             �
� aInfAux[1] - Ano				                           �
� aInfAux[2] - Mes              				           �
� aInfAux[3] - Produto                     				   �
� aInfAux[4] - Fornecedor	                               �
� aInfAux[5] - Valor IQF		                           �
������������������������������������������������������������
*/
If Len(aInfAux) > 0
	aAdd(aRetPanel,{STR0001,{}}) // "5 Maiores"
	If Len(aInfAux) > 0
		nMax :=  Iif(Len(aInfAux)> 5,5,Len(aInfAux))
		aSort(aInfAux,,,{|x,y| x[5] > y[5] }) //--Ordena pelo peso - aInfAux[3]
		
		For nCnt := 1 To nMax
			aAdd(aRetPanel[1][2],{Posicione('SB1',1,xFilial('SB1')+aInfAux[nCnt,3],'B1_DESC'),Transform(aInfAux[nCnt,5],"@E 999.99"),CLR_GREEN,STR0002+Posicione('SA2',1,xFilial('SA2')+aInfAux[nCnt,4],'A2_NOME')})	//"Fornecedor: "
		Next nCnt
	EndIf
	
	aAdd(aRetPanel,{STR0003,{}}) //"5 Menores"
	If Len(aInfAux) > 0
		nMax :=  Iif(Len(aInfAux)> 5,5,Len(aInfAux))
		aSort(aInfAux,,,{|x,y| x[5] < y[5] }) 
		
		For nCnt := 1 To nMax
			aAdd(aRetPanel[2][2],{Posicione('SB1',1,xFilial('SB1')+aInfAux[nCnt,3],'B1_DESC'),Transform(aInfAux[nCnt,5],"@E 999.99"),CLR_RED,Nil})
		Next nCnt
	
	EndIf
Else	
	aAdd(aRetPanel,{STR0001,{}}) // "5 Maiores"
	aAdd(aRetPanel[1][2],{STR0004,Transform("0","@E 999.99"),CLR_GREEN,Nil}) //"Nao h� dados para dimens�o"
	aAdd(aRetPanel,{STR0003,{}}) //"5 Menores"
	aAdd(aRetPanel[2][2],{STR0004,Transform("0","@E 999.99"),CLR_RED,Nil}) //"Nao h� dados para dimens�o"
EndIf
	
Return aRetPanel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QIEGerQry � Autor � Cicero Odilio Cruz    � Data �06.03.07  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera a Query que sera exibida pelo Painel de Gestao        ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQIE                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function QIEGerQry()

Local cAliasQry := GetNextAlias()
Local aInfAux   := {}
Local cWhere    :=  ""
Local nTamanho  := GetSx3Cache("QEV_FORNEC","X3_TAMANHO")

Pergunte("QEP010",.F.)   

cWhere    :='% '
cWhere    += "QEV.QEV_ANO = '"+ mv_par01 +"' AND QEV.QEV_MES = '"+ mv_par02 +"' AND "
If !Empty(AllTrim(mv_par03)) .AND. Iif(At(";",mv_par03)>0,.T.,Iif(At("-",mv_par03)>0,.T.,.F.))
	MV_PAR03 := QA_Range(MV_PAR03, "QEV_FORNEC", "QEV")
	cWhere    += " "+ mv_par03 + " AND "
ElseIf !Empty(AllTrim(mv_par03)) //se comporta sem range
	cWhere    += " QEV_FORNEC = '"+ PadL(AllTrim(mv_par03),nTamanho) + "' AND "
EndIf	
cWhere    +=' %'

//Selecionando as tabelas para garantir
//que elas existam antes da execucao da query
dbSelectArea("QEV")

BeginSql Alias cAliasQry

	SELECT QEV_ANO, QEV_MES, QEV_PRODUT, QEV_FORNEC, QEV_IQF
	
	FROM %table:QEV% QEV
	
 	WHERE 
		QEV.QEV_FILIAL = %xFilial:QEV% AND 
	 	(QEV.QEV_LOTENT>0 OR QEV.QEV_LOTDEM>0 OR QEV.QEV_LOTINS>0 OR 	
	 	QEV.QEV_LOTSKP>0 OR QEV.QEV_QTDREJ>0 OR QEV.QEV_QTDINS>0 OR 
	 	QEV.QEV_QTDSKP>0) AND
		%Exp:cWhere%
	 	QEV.%notDel% 

	ORDER BY QEV_FILIAL,QEV_ANO,QEV_MES,QEV_FORNEC,QEV_PRODUT

EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aInfAux ,{ (cAliasQry)->QEV_ANO,(cAliasQry)->QEV_MES,(cAliasQry)->QEV_PRODUTO,(cAliasQry)->QEV_FORNEC,(cAliasQry)->QEV_IQF } )
		(cAliasQry)->(DbSkip())
	EndDo
EndIf
(cAliasQry)->(DbCloseArea())

Return aInfAux 