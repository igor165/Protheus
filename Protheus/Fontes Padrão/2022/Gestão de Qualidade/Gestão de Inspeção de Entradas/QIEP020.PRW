#include "PROTHEUS.CH" 
#include "MSGRAPHI.CH"
#include "QIEP020.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QIEP020  ³ Autor ³ Cicero Odilio Cruz    ³ Data ³ 05.03.07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Painel de Gestao - Resultados por Fornecedor X Produto      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQIE                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIEP020()

Local aInfo     := {}
Local nCnt      := 0
Local nMax      := 0
Local aRetPanel := {}

DbSelectArea("SB1")
DbSelectArea("SA2")

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Estrutura do Array aInfo:         ³
³ aInfo[1][1] - Situacao da Entrada ³
³ aInfo[1][2] - Quantidade          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
aInfo := aClone(QIEGerQry()) //Funcao para alimentar o array

If Len(aInfo[1]) > 0
	aAdd(aRetPanel,{STR0001,{}}) // "Status"
	If Len(aInfo[1]) > 0
		nMax :=  Iif(Len(aInfo[1])> 5,5,Len(aInfo[1]))

		For nCnt := 1 To nMax
			aAdd(aRetPanel[1][2],{aInfo[1][nCnt][1],Transform(aInfo[1][nCnt][2],"@E 99999"),CLR_GREEN,Nil})	
		Next nCnt
	EndIf
Else	
	aAdd(aRetPanel,{STR0001,{}}) // "Status"
	aAdd(aRetPanel[1][2],{STR0002,Transform("0","@E 99999"),CLR_GREEN,Nil}) //"Nao há dados na dimensão"
EndIf

If Len(aInfo[2]) > 0
	aAdd(aRetPanel,{STR0003,{}}) // "Pendentes"
	If Len(aInfo[2]) > 0
		nMax :=  Iif(Len(aInfo[2])> 5,5,Len(aInfo[2]))

		For nCnt := 1 To nMax
			aAdd(aRetPanel[2][2],{aInfo[2][nCnt][1],Transform(aInfo[2][nCnt][2],"@E 99999"),CLR_GREEN,Nil})	//"Fornecedor: "
		Next nCnt
	EndIf
Else	
	aAdd(aRetPanel,{STR0003,{}}) // "Pendentes"
	aAdd(aRetPanel[2][2],{STR0002,Transform("0","@E 99999"),CLR_GREEN,Nil}) //"Nao há dados na dimensão"
EndIf
	
Return aRetPanel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QIEGerQry ³ Autor ³ Cicero Odilio Cruz    ³ Data ³06.03.07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera a Query que sera exibida pelo Painel de Gestao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQIE                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QIEGerQry()

Local aStatus := {	STR0004,;  		//"Pendente(s)"
			  		STR0005,;		//"Laudo(s) Aprovado(s)"
					STR0006,;		//"Liberado(s) Condicional(is)"
					STR0007,;		//"Laudo(s) Reprovado(s)"
					STR0008,;		//"Liberado(s) Urgente"
					STR0009,;		//"Movimentacao de Estoque"
					STR0010,;		//"Laudo Geral "
					STR0011}		//"Laudo Laboratorio "
Local aInf 		:= {{},{}}
Local aInfAux   := {}
Local cAliasQry1:= GetNextAlias()
Local cAliasQry2:= GetNextAlias()
Local cPerg     := "QEP020"
Local cWhere    := ""
Local cWhereAux := ""
Local nTamanho1 := GetSx3Cache("QEK_FORNEC","X3_TAMANHO")
Local nTamanho2 := GetSx3Cache("QEK_PRODUT","X3_TAMANHO")

Pergunte(cPerg,.F.)   

cWhere    :='% '
If !Empty(AllTrim(MV_PAR01)) .AND. Iif(At(";",MV_PAR01)>0,.T.,Iif(At("-",MV_PAR01)>0,.T.,.F.))
	cWhereAux := QA_Range(MV_PAR01, "QEK_FORNEC", "QEK")
	cWhere    += " ("+ cWhereAux + ") AND "
ElseIf !Empty(AllTrim(MV_PAR01)) //se comporta sem range
	cWhere    += " QEK_FORNEC = '"+ PadL(AllTrim(MV_PAR01),nTamanho1) + "' AND "
EndIf
If !Empty(AllTrim(MV_PAR02)) .AND. Iif(At(";",MV_PAR02)>0,.T.,Iif(At("-",MV_PAR02)>0,.T.,.F.))
	cWhereAux := QA_Range(MV_PAR02, "QEK_PRODUT", "QEK")
	cWhere    += " ("+ cWhereAux + ") AND "
ElseIf !Empty(AllTrim(MV_PAR02)) //se comporta sem range
	cWhere    += " QEK_PRODUT = '"+ PadL(AllTrim(MV_PAR02),nTamanho2) + "' AND "
EndIf
cWhere    += " QEK_DTENTR BETWEEN '"+ DtoS(MV_PAR03) +"' AND '"+ DtoS(MV_PAR04) +"' AND "	
cWhere    +=' %'

cGroup := "% QEK.QEK_SITENT %"

//Selecionando as tabelas para garantir
//que elas existam antes da execucao da query
dbSelectArea("QEK")

BeginSql Alias cAliasQry1

	
	SELECT QEK.QEK_SITENT SITENT, COUNT(QEK.QEK_FORNEC) TOTAL 
	
	FROM %table:QEK% QEK
	
	WHERE 
	      QEK.QEK_FILIAL = %xFilial:QEK% AND 
	      (QEK.QEK_SITENT = '2' OR QEK.QEK_SITENT = '3' OR QEK.QEK_SITENT = '4' OR QEK.QEK_SITENT = '5' ) AND 
	      %Exp:cWhere%
	      QEK.%notDel% 
	
	GROUP BY %Exp:cGroup% 
	
	UNION
	
	SELECT '1' SITENT, COUNT(*) TOTAL 
	
	FROM %table:QEK% QEK
	
	WHERE 
	      QEK.QEK_FILIAL = %xFilial:QEK% AND 
	      (QEK.QEK_SITENT = '1' OR QEK.QEK_SITENT = '6' OR QEK.QEK_SITENT = '7' OR QEK.QEK_SITENT = '8' ) AND 
	      %Exp:cWhere%
	      QEK.%notDel%  

EndSql

dbSelectArea(cAliasQry1)
If !(cAliasQry1)->(Eof())
	While !(cAliasQry1)->(Eof())
		Aadd(aInfAux ,{ aStatus[Val((cAliasQry1)->SITENT)], (cAliasQry1)->TOTAL } )
		(cAliasQry1)->(DbSkip())
	EndDo
EndIf
(cAliasQry1)->(DbCloseArea())

aInf[1] := aClone(aInfAux)


BeginSql Alias cAliasQry2

	SELECT QEK.QEK_SITENT SITENT, COUNT(QEK.QEK_FORNEC) TOTAL 
	
	FROM %table:QEK% QEK
	
	WHERE 
	      QEK.QEK_FILIAL = %xFilial:QEK% AND 
	      (QEK.QEK_SITENT = '1' OR QEK.QEK_SITENT = '7' OR QEK.QEK_SITENT = '6' OR QEK.QEK_SITENT = '8' ) AND 
	      %Exp:cWhere%
	      QEK.%notDel% 
	
	GROUP BY %Exp:cGroup% 

EndSql

aInfAux := {}
dbSelectArea(cAliasQry2)
If !(cAliasQry2)->(Eof())
	While !(cAliasQry2)->(Eof())
		Aadd(aInfAux ,{ Iif(Val((cAliasQry2)->SITENT)=1,STR0012,aStatus[Val((cAliasQry2)->SITENT)]), (cAliasQry2)->TOTAL } ) //"Sem Medicoes Cadastradas"
		(cAliasQry2)->(DbSkip())
	EndDo
EndIf
(cAliasQry2)->(DbCloseArea())

aInf[2] := aClone(aInfAux)

Return aInf