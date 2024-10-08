#include "PROTHEUS.CH" 
#include "MSGRAPHI.CH"
#include "QIEP040.CH"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � QIEP040  � Autor � Cicero Odilio Cruz    � Data � 13.03.07  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Painel de Gestao - N�mero de N�o-Conformidades x Fornecedor ���
��������������������������������������������������������������������������Ĵ��
���Parametros�                 											   ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQIE                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function QIEP040()

Local aRetPanel := {} //Array com os dados que ser�o exibidos no painel
Local aDados    := {} 
Local nCnt

Private aDados1   := {}
Private nTot 	  := 0
Private cAtu      := ''

dbSelectArea("QEE")  
dbSelectArea("SA2")
dbSelectArea("SB1")

/*
�������������������������������������������Ŀ
� Estrutura do Array aDados:         		�
� aDados[1] - Fornecedor					�	
� aDados[2] - Loja		          			�
� aDados[3] - Produto          				�
� aDados[4] - Data Entrada     				�
� aDados[5] - Lote	          				�
� aDados[6] - Classe da N�o-Conformidade	�
� aDados[7] - Numero de N�o-Conformidades	�
���������������������������������������������
*/
aDados := aClone(QIEGerQry())

// Dimens�o Classe de N�o-Conformidade
aDados := aSort(aDados,,,{|x,y|x[6]<y[6]})
Aeval(aDados,;
	{|x| Iif(cAtu <> x[6],;
		     Iif(Empty(AllTrim(cAtu)),;
			     {nTot+=x[7],cAtu:=x[6]},;
			     {Aadd(aDados1,{cAtu,nTot}),nTot:=0,nTot+=x[7],cAtu:=x[6]}),;
			 {nTot+=x[7],cAtu:=x[6]})})
If Len(aDados) >= 1
	Aadd(aDados1,{cAtu,nTot})
EndIf

If Len(aDados1) > 0
	aAdd(aRetPanel,{STR0001,{}}) // "Classe N�o-Conformidade"
	For nCnt := 1 To Len(aDados1)
		aAdd(aRetPanel[1][2],{Posicione("QEE",1,xFilial('QEE')+aDados1[nCnt][1],"QEE_DESCPO"),Transform(aDados1[nCnt][2],"@E 99999"),CLR_GREEN,Nil})	
	Next nCnt           
Else	
	aAdd(aRetPanel,{STR0001,{}}) // "Classe N�o-Conformidade"
	aAdd(aRetPanel[1][2],{STR0002,Transform("0","@E 99999"),CLR_GREEN,Nil}) //"Nao h� dados na dimens�o"  
EndIf

// Dimens�o por Produto
aDados1   := {}
nTot 	  := 0
cAtu      := ''
aDados := aSort(aDados,,,{|x,y|x[3]<y[3]})
Aeval(aDados,;
	{|x| Iif(cAtu <> x[3],;
		     Iif(Empty(AllTrim(cAtu)),;
			     {nTot+=x[7],cAtu:=x[3]},;
			     {Aadd(aDados1,{cAtu,nTot}),nTot:=0,nTot+=x[7],cAtu:=x[3]}),;
			 {nTot+=x[7],cAtu:=x[3]})})
If Len(aDados) >= 1
	Aadd(aDados1,{cAtu,nTot})
EndIf

If Len(aDados1) > 0
	aAdd(aRetPanel,{STR0003,{}}) // "Produto"
	For nCnt := 1 To Len(aDados1)
		aAdd(aRetPanel[2][2],{Posicione("SB1",1,xFilial('SB1')+aDados1[nCnt][1],"B1_DESC"),Transform(aDados1[nCnt][2],"@E 99999"),CLR_GREEN,Nil})	
	Next nCnt           
Else	
	aAdd(aRetPanel,{STR0003,{}}) // "Produto"
	aAdd(aRetPanel[2][2],{STR0002,Transform("0","@E 99999"),CLR_GREEN,Nil}) //"Nao h� dados na dimens�o"  
EndIf

// Dimens�o por Fornecedor
aDados1   := {}
nTot 	  := 0
cAtu      := ''
aDados := aSort(aDados,,,{|x,y|x[1]<y[1]})
Aeval(aDados,;
	{|x| Iif(cAtu <> x[1],;
		     Iif(Empty(AllTrim(cAtu)),;
			     {nTot+=x[7],cAtu:=x[1]},;
			     {Aadd(aDados1,{cAtu,nTot}),nTot:=0,nTot+=x[7],cAtu:=x[1]}),;
			 {nTot+=x[7],cAtu:=x[1]})})
If Len(aDados) >= 1
	Aadd(aDados1,{cAtu,nTot})
EndIf

If Len(aDados1) > 0
	aAdd(aRetPanel,{STR0004,{}}) // "Fornecedor"
	For nCnt := 1 To Len(aDados1)
		aAdd(aRetPanel[3][2],{Posicione("SA2",1,xFilial('SA2')+aDados1[nCnt][1],"A2_NOME"),Transform(aDados1[nCnt][2],"@E 99999"),CLR_GREEN,Nil})	
	Next nCnt           
Else	
	aAdd(aRetPanel,{STR0004,{}}) // "Fornecedor"
	aAdd(aRetPanel[3][2],{STR0002,Transform("0","@E 99999"),CLR_GREEN,Nil}) //"Nao h� dados na dimens�o"  
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
Local cStatus   := ""
Local cPerg 	:= "QEP040"
Local cWhere    := ""
Local aDados 	:= {}
 
Pergunte(cPerg,.F.)   

cWhere    :='% '

If !Empty(AllTrim(MV_PAR01)) .AND. Iif(At(";",MV_PAR01)>0,.T.,Iif(At("-",MV_PAR01)>0,.T.,.F.))
	cWhereAux := QA_Range(MV_PAR01, "QEK_FORNEC", "QEK")
	cWhere    += " ("+ cWhereAux + ") AND "
ElseIf !Empty(AllTrim(MV_PAR01)) //se comporta sem range
	cWhere    += " QEK_FORNEC = '"+ PadL(AllTrim(MV_PAR01),GetSx3Cache("QEK_FORNEC","X3_TAMANHO")) + "' AND "
EndIf   

cWhere    +=' %'

//Selecionando as tabelas para garantir
//que elas existam antes da execucao da query
dbSelectArea("QEK")
dbSelectArea("QEU")
dbSelectArea("QER")

BeginSql Alias cAliasQry
	
	SELECT 	QEK.QEK_FORNEC, QEK.QEK_LOJFOR, QEK.QEK_PRODUT,
			QEK.QEK_DTENTR, QEK.QEK_LOTE  ,	QEU.QEU_CLASSE,
			SUM(QEU_NUMNC) NONNC					
	FROM    %table:QEK% QEK, %table:QER% QER, %table:QEU% QEU
	WHERE 	QEK.QEK_FILIAL = %xFilial:QEK%  AND
			QER.QER_FILIAL = %xFilial:QER%  AND
			QEU.QEU_FILIAL = %xFilial:QEU%  AND
			QEU.QEU_CODMED = QER.QER_CHAVE  AND 
			QER.QER_PRODUT = QEK.QEK_PRODUT	AND 
			QER.QER_REVI   = QEK.QEK_REVI	AND 
			QER.QER_FORNEC = QEK.QEK_FORNEC	AND 
			QER.QER_LOJFOR = QEK.QEK_LOJFOR	AND 
			QER.QER_LOTE   = QEK.QEK_LOTE	AND 
			%Exp:cWhere%
			QEK.QEK_DTENTR BETWEEN %exp:Dtos(mv_par02)% and %exp:Dtos(mv_par03)% AND		
			QEK.%notDel% AND 
			QER.%notDel% AND 
			QEU.%notDel%
	GROUP BY QEK.QEK_FORNEC, QEK.QEK_LOJFOR, QEK.QEK_PRODUT,QEK.QEK_DTENTR, QEK.QEK_LOTE, QEU.QEU_CLASSE

EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		aAdd(aDados,{&(cAliasQry+"->QEK_FORNEC"),&(cAliasQry+"->QEK_LOJFOR"),&(cAliasQry+"->QEK_PRODUT"),&(cAliasQry+"->QEK_DTENTR"),&(cAliasQry+"->QEK_LOTE"),&(cAliasQry+"->QEU_CLASSE"),&(cAliasQry+"->NONNC")})
		(cAliasQry)->(DbSkip())
	EndDo
EndIf

(cAliasQry)->(DbCloseArea())

Return aDados