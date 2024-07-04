#include "protheus.ch"
#INCLUDE "QNCP020.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QNCP020  ³ Autor ³ Rafael S. Bernardi    ³ Data ³01/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Painel de Gestao - Status das Nao-Conformidades / Planos de³±±
±±³          ³ Acao                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQNC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCP020()

Local aRetPanel := {} //Array com os dados que serão exibidos no painel
Local aTipos    := {STR0006,STR0007,STR0008}//"Nao Conf.Potencial" | "Nao Conf.Existente" | "Melhoria"
Local aPriori   := {STR0009,STR0010,STR0011}//"Baixa" | "Media" | "Alta"
Local aStatus   := {STR0012,STR0013,STR0014,STR0015,STR0016}//"Registrada" | "Em Analise" | "Procede" | "Nao Procede" | "Cancelada"
Local nX

Private cTConRea := Space(TamSx3("QI2_CONREA")[1])
Private cTEncRea := Space(TamSx3("QI3_ENCREA")[1])

Private aDados  := {}

Pergunte("QNCP20",.F.)

//Geracao dos Dados dos Tipos de FNCs
QNCGerTNC()
aAdd(aRetPanel,{STR0001,{}})//"Tipo de FNCs"
For nX := 1 To Len(aDados)
	aAdd(aRetPanel[1][2],{aDados[nX][1]+IIF(aDados[nx][2] == -1,""," - "+aTipos[Val(aDados[nX][1])]),;
	IIF(aDados[nX][2] == -1,"0",Transform(aDados[nX][2],"@E 99999")),CLR_GREEN,Nil})
Next nX

//Geracao dos Dados das Prioridades de FNCs
QNCGerPRI()
aAdd(aRetPanel,{STR0002,{}})//"Prioridades de FNCs"
For nX := 1 To Len(aDados)
	aAdd(aRetPanel[2][2],{aDados[nX][1]+IIF(aDados[nX][2] == -1,""," - "+aPriori[Val(aDados[nX][1])]),;
	IIF(aDados[nX][2] == -1,"0",Transform(aDados[nX][2],"@E 99999")),CLR_GREEN,Nil})
Next nX

//Geracao dos Dados de Status de FNCs
QNCGerSTA()
aAdd(aRetPanel,{STR0003,{}})//"Status de FNCs"
For nX := 1 To Len(aDados)
	aAdd(aRetPanel[3][2],{aDados[nX][1]+IIF(aDados[nX][2] == -1,""," - "+aStatus[Val(aDados[nX][1])]),;
	IIF(aDados[nX][2] == -1,"0",Transform(aDados[nX][2],"@E 99999")),CLR_GREEN,Nil})
Next nX

//Geracao dos Dados de Status dos Planos de Acao
QNCGerPLA()
aAdd(aRetPanel,{STR0004,{}})//"Planos de Ação"
For nX := 1 To Len(aDados)
	aAdd(aRetPanel[4][2],{aDados[nX][1]+IIF(aDados[nX][2] == -1,""," - "+aStatus[Val(aDados[nX][1])]),;
	IIF(aDados[nX][2] == -1,"0",Transform(aDados[nX][2],"@E 99999")),CLR_GREEN,Nil})
Next nX

Return aRetPanel

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QNCGerTNC ³ Autor ³ Rafael S. Bernardi    ³ Data ³01/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera os dados para o combo 1 do painel de gestao            ³±±
±±³          ³Status Nao-Conformidades por Planos de Acao                 ³±±
±±³          ³Tipos de FNCs                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQNC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCGerTNC()
Local cAliasQry := GetNextAlias()

MakeSqlExpr("QNCP20")

//Selecionando as tabelas para garantir
//que elas existam antes da execucao da query
dbSelectArea("QI2")
dbSelectArea("QI3")

If mv_par01 == 1

	BeginSql Alias cAliasQry
		
		SELECT DISTINCT QI2.QI2_TPFIC, COUNT(QI2_TPFIC) NFNC FROM %table:QI2% QI2
		WHERE QI2.QI2_CONREA = %Exp:cTConRea% AND
		      QI2.QI2_STATUS = '3' AND
			  QI2.QI2_FILIAL = %xfilial:QI2% AND
			  QI2.%NotDel%
		GROUP BY QI2.QI2_TPFIC
		
	EndSql

ElseIf mv_par01 == 2

	BeginSql Alias cAliasQry
		
		SELECT DISTINCT QI2.QI2_TPFIC, COUNT(QI2_TPFIC) NFNC FROM %table:QI2% QI2
		WHERE QI2.QI2_CONREA <> %Exp:cTConRea% AND
        QI2.QI2_STATUS = '3' AND
		QI2.QI2_FILIAL = %xfilial:QI2% AND
		QI2.%NotDel%
		GROUP BY QI2.QI2_TPFIC
		
	EndSql

Else

	BeginSql Alias cAliasQry
		
		SELECT DISTINCT QI2.QI2_TPFIC, COUNT(QI2_TPFIC) NFNC FROM %table:QI2% QI2
		WHERE QI2.QI2_FILIAL = %xfilial:QI2% AND
		      QI2.QI2_STATUS = '3' AND
		      QI2.%NotDel%
		GROUP BY QI2.QI2_TPFIC
		
	EndSql

EndIF

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aDados ,{ AllTrim(&(cAliasQry+"->QI2_TPFIC")),&(cAliasQry+"->NFNC")} )
		(cAliasQry)->(DbSkip())
	EndDo
Else
	aAdd(aDados,{STR0005,-1,0}) //"Não há dados para exibição"
EndIf

(cAliasQry)->(DbCloseArea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QNCGerPRI ³ Autor ³ Rafael S. Bernardi    ³ Data ³01/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera os dados para o combo 2 do painel de gestao            ³±±
±±³          ³Status Nao-Conformidades por Planos de Acao                 ³±±
±±³          ³Prioridades das  FNCs                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQNC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCGerPRI()
Local cAliasQry := GetNextAlias()

aDados := {}

MakeSqlExpr("QNCP20")

If mv_par01 == 1

	BeginSql Alias cAliasQry
		
	SELECT DISTINCT QI2.QI2_PRIORI, COUNT(QI2_PRIORI) NFNC FROM %table:QI2% QI2
	WHERE QI2.QI2_CONREA = %Exp:cTConRea% AND
			  QI2.QI2_FILIAL = %xfilial:QI2% AND
			  QI2.%NotDel%
	GROUP BY QI2.QI2_PRIORI
		
	EndSql

ElseIf mv_par01 == 2

	BeginSql Alias cAliasQry
		
	SELECT DISTINCT QI2.QI2_PRIORI, COUNT(QI2_PRIORI) NFNC FROM %table:QI2% QI2
	WHERE QI2.QI2_CONREA <> %Exp:cTConRea% AND
		QI2_FILIAL = %xfilial:QI2% AND
		QI2.%NotDel%
	GROUP BY QI2.QI2_PRIORI
		
	EndSql

Else

	BeginSql Alias cAliasQry
		
	SELECT DISTINCT QI2.QI2_PRIORI, COUNT(QI2_PRIORI) NFNC FROM %table:QI2% QI2
	WHERE QI2.QI2_FILIAL = %xfilial:QI2% AND
	      QI2.%NotDel%
	GROUP BY QI2.QI2_PRIORI
		
	EndSql

EndIF

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aDados ,{ AllTrim(&(cAliasQry+"->QI2_PRIORI")),&(cAliasQry+"->NFNC")} )
		(cAliasQry)->(DbSkip())
	EndDo
Else
	aAdd(aDados,{STR0005,-1,0}) //"Não há dados para exibição"
EndIf

(cAliasQry)->(DbCloseArea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QNCGerSTA ³ Autor ³ Rafael S. Bernardi    ³ Data ³01/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera os dados para o combo 3 do painel de gestao            ³±±
±±³          ³Status Nao-Conformidades por Planos de Acao                 ³±±
±±³          ³Status das FNCs                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQNC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCGerSTA()
Local cAliasQry := GetNextAlias()

aDados := {}

MakeSqlExpr("QNCP20")

If mv_par01 == 1

	BeginSql Alias cAliasQry
		
	SELECT DISTINCT QI2.QI2_STATUS, COUNT(QI2_STATUS) NFNC FROM %table:QI2% QI2
	WHERE QI2.QI2_CONREA = %Exp:cTConRea% AND
			  QI2.QI2_FILIAL = %xfilial:QI2% AND
			  QI2.%NotDel%
	GROUP BY QI2.QI2_STATUS
		
	EndSql

ElseIf mv_par01 == 2

	BeginSql Alias cAliasQry
		
	SELECT DISTINCT QI2.QI2_STATUS, COUNT(QI2_STATUS) NFNC FROM %table:QI2% QI2
	WHERE QI2.QI2_CONREA <> %Exp:cTConRea% AND
		QI2.QI2_FILIAL = %xfilial:QI2% AND
		QI2.%NotDel%
	GROUP BY QI2.QI2_STATUS
		
	EndSql

Else

	BeginSql Alias cAliasQry
		
	SELECT DISTINCT QI2.QI2_STATUS, COUNT(QI2_STATUS) NFNC FROM %table:QI2% QI2
	WHERE QI2.QI2_FILIAL = %xfilial:QI2% AND
	      QI2.%NotDel%
	GROUP BY QI2.QI2_STATUS
		
	EndSql

EndIF

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aDados ,{ AllTrim(&(cAliasQry+"->QI2_STATUS")),&(cAliasQry+"->NFNC")} )
		(cAliasQry)->(DbSkip())
	EndDo
Else
	aAdd(aDados,{STR0005,-1,0}) //"Não há dados para exibição"
EndIf

(cAliasQry)->(DbCloseArea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QNCGerPLA ³ Autor ³ Rafael S. Bernardi    ³ Data ³02/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera os dados para o combo 4 do painel de gestao            ³±±
±±³          ³Status Nao-Conformidades por Planos de Acao                 ³±±
±±³          ³Status dos Planos de Acao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQNC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCGerPLA()
Local cAliasQry := GetNextAlias()

aDados := {}

MakeSqlExpr("QNCP20")

If mv_par01 == 1

	BeginSql Alias cAliasQry
		
	SELECT DISTINCT QI3.QI3_STATUS, COUNT(QI3_STATUS) NFNC FROM %table:QI3% QI3
	WHERE QI3.QI3_ENCREA = %Exp:cTEncRea% AND
		  QI3.QI3_FILIAL = %xfilial:QI3% AND
		  QI3.%NotDel%
	GROUP BY QI3.QI3_STATUS
		
	EndSql

ElseIf mv_par01 == 2

	BeginSql Alias cAliasQry
		
	SELECT DISTINCT QI3.QI3_STATUS, COUNT(QI3_STATUS) NFNC FROM %table:QI3% QI3
	WHERE QI3.QI3_ENCREA <> %Exp:cTEncRea% AND
		  QI3.QI3_FILIAL = %xfilial:QI3% AND
		  QI3.%NotDel%
	GROUP BY QI3.QI3_STATUS
		
	EndSql

Else

	BeginSql Alias cAliasQry
		
	SELECT DISTINCT QI3.QI3_STATUS, COUNT(QI3_STATUS) NFNC FROM %table:QI3% QI3
	WHERE QI3.QI3_FILIAL = %xfilial:QI3% AND
		  QI3.%NotDel%
	GROUP BY QI3.QI3_STATUS
		
	EndSql

EndIF

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aDados ,{ AllTrim(&(cAliasQry+"->QI3_STATUS")),&(cAliasQry+"->NFNC")} )
		(cAliasQry)->(DbSkip())
	EndDo
Else
	aAdd(aDados,{STR0005,-1,0}) //"Não há dados para exibição"
EndIf

(cAliasQry)->(DbCloseArea())

Return