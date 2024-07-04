#include "protheus.ch"
#INCLUDE "QNCP040.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QNCP040  ³ Autor ³ Rafael S. Bernardi    ³ Data ³06/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Painel de Gestao - Nao-Conformidades por Instrumento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQNC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCP040()

Local aRetPanel := {} //Array com os dados que serão exibidos no painel
Local aAux      := {}
Local nX

Private cTIntstr := Space(TamSx3("QI2_INSTR")[1])
Private cTConRea := Space(TamSx3("QI2_CONREA")[1])
Private aDados  := {}

Pergunte("QNCP40",.F.)

QNCCarDad()

//Geracao dos Dados das FNC geradas no QNC
aAdd(aRetPanel,{STR0001,{}})//"QNC"
aAux := aClone(QNCGerFNC())
For nX := 1 To Len(aAux)
	aAdd(aRetPanel[1][2],aClone(aAux[nX]))
Next nX

aAux := {}

//Geracao dos Dados das FNC geradas no QMT
aAdd(aRetPanel,{STR0002,{}})//"QMT"
aAux := aClone(QNCGerQMT())
For nX := 1 To Len(aAux)
	aAdd(aRetPanel[2][2],aClone(aAux[nX]))
Next nX

aAux := {}

//Geracao dos Dados de todas as FNCs de Instrumentos
aAdd(aRetPanel,{STR0003,{}})//"Ambos"
aAux := aClone(QNCGerAll())
For nX := 1 To Len(aAux)
	aAdd(aRetPanel[3][2],aClone(aAux[nX]))
Next nX

Return aRetPanel

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QNCCarDad ³ Autor ³ Rafael S. Bernardi    ³ Data ³06/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Carrega array com os dados a serem utilizados pelo painel   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQNC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCCarDad()

Local cAliasQry := GetNextAlias()

//Selecionando as tabelas para garantir
//que elas existam antes da execucao da query
dbSelectArea("QI2")

If mv_par01 == 1

BeginSql Alias cAliasQry
	
	SELECT DISTINCT QI2.QI2_REVINS, QI2.QI2_INSTR, QI2.QI2_ORIGEM, COUNT(QI2_INSTR) NFNC FROM %table:QI2% QI2
	WHERE QI2.QI2_FILIAL = %xfilial:QI2% AND
	      QI2.QI2_INSTR <> %Exp:cTIntstr% AND
	      QI2.QI2_STATUS = '3' AND
	      QI2.QI2_CONREA = %Exp:cTConRea% AND
	      QI2.QI2_OBSOL = 'N' AND
	      (QI2.QI2_ORIGEM = 'QNC' OR QI2.QI2_ORIGEM = 'QMT') AND
	      QI2.%NotDel%
	GROUP BY QI2.QI2_INSTR, QI2.QI2_REVINS, QI2.QI2_ORIGEM
	
EndSql

ElseIf mv_par01 = 2

BeginSql Alias cAliasQry
	
	SELECT DISTINCT QI2.QI2_REVINS, QI2.QI2_INSTR, QI2.QI2_ORIGEM, COUNT(QI2_INSTR) NFNC FROM %table:QI2% QI2
	WHERE QI2.QI2_FILIAL = %xfilial:QI2% AND
	      QI2.QI2_INSTR <> %Exp:cTIntstr% AND
	      QI2.QI2_STATUS = '3' AND
	      QI2.QI2_CONREA <> %Exp:cTConRea% AND
	      QI2.QI2_OBSOL = 'N' AND
	      (QI2.QI2_ORIGEM = 'QNC' OR QI2.QI2_ORIGEM = 'QMT')
	GROUP BY QI2.QI2_INSTR, QI2.QI2_REVINS, QI2.QI2_ORIGEM
	
EndSql

Else

BeginSql Alias cAliasQry
	
	SELECT DISTINCT QI2.QI2_REVINS, QI2.QI2_INSTR, QI2.QI2_ORIGEM, COUNT(QI2_INSTR) NFNC FROM %table:QI2% QI2
	WHERE QI2.QI2_FILIAL = %xfilial:QI2% AND
	      QI2.QI2_INSTR <> %Exp:cTIntstr% AND
	      QI2.QI2_STATUS = '3' AND
	      QI2.QI2_OBSOL = 'N' AND
	      (QI2.QI2_ORIGEM = 'QNC' OR QI2.QI2_ORIGEM = 'QMT')
	GROUP BY QI2.QI2_INSTR, QI2.QI2_REVINS, QI2.QI2_ORIGEM
	
EndSql

EndIf

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aDados ,{AllTrim(&(cAliasQry+"->QI2_REVINS")),AllTrim(&(cAliasQry+"->QI2_INSTR")),;
					  AllTrim(&(cAliasQry+"->QI2_ORIGEM")),&(cAliasQry+"->NFNC")})
		(cAliasQry)->(DbSkip())
	EndDo
EndIf

aDados := aSort(aDados,,,{|x,y| x[4] > y[4]})

(cAliasQry)->(DbCloseArea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QNCGerFNC ³ Autor ³ Rafael S. Bernardi    ³ Data ³06/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera os dados para o combo 1 do painel de gestao            ³±±
±±³          ³Nao-Conformidades por Instrumentos - Geradas a partir do QNC³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQNC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCGerFNC()
Local aRet := {}
Local nx

For nX := 1 To Len(aDados)
	If aDados[nX][3] == "QNC"
		aAdd(aRet,{aDados[nX][1]+" - "+aDados[nX][2],Transform(aDados[nx][4],"@E 999999"),CLR_GREEN,Nil})
	EndIf
	If Len(aRet) == 5
		Exit
	EndIf
Next nX

If Len(aRet) == 0
	aRet := {{STR0004,Transform(0,"@E 999999"),CLR_GREEN,Nil}}//"Não há dados para exibição"
EndIf

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QNCGerQMT ³ Autor ³ Rafael S. Bernardi    ³ Data ³06/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera os dados para o combo 2 do painel de gestao            ³±±
±±³          ³Nao-Conformidades por Instrumentos - Geradas a partir do QMT³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQNC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCGerQMT()
Local aRet := {}
Local nx

For nX := 1 To Len(aDados)
	If aDados[nX][3] == "QMT"
		aAdd(aRet,{aDados[nX][1]+" - "+aDados[nX][2],Transform(aDados[nx][4],"@E 999999"),CLR_GREEN,Nil})
	EndIf
	If Len(aRet) == 5
		Exit
	EndIf
Next nX

If Len(aRet) == 0
	aRet := {{STR0004,Transform(0,"@E 999999"),CLR_GREEN,Nil}}//"Não há dados para exibição"
EndIf

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QNCGerAll ³ Autor ³ Rafael S. Bernardi    ³ Data ³06/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera os dados para o combo 2 do painel de gestao            ³±±
±±³          ³Nao-Conformidades por Instrumentos - Ambos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQNC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCGerAll()
Local aRet := {}
Local nx
Local cAliasQry := GetNextAlias()

aDados := {}

If mv_par01 == 1

BeginSql Alias cAliasQry
	
	SELECT DISTINCT QI2.QI2_REVINS, QI2.QI2_INSTR, COUNT(QI2_INSTR) NFNC FROM %table:QI2% QI2
	WHERE QI2.QI2_FILIAL = %xfilial:QI2% AND
	      QI2.QI2_INSTR <> %Exp:cTIntstr% AND
	      QI2.QI2_STATUS = '3' AND
	      QI2.QI2_CONREA = %Exp:cTConRea% AND
	      QI2.QI2_OBSOL = 'N' AND
	      (QI2.QI2_ORIGEM = 'QNC' OR QI2.QI2_ORIGEM = 'QMT')
	GROUP BY QI2.QI2_INSTR, QI2.QI2_REVINS
	
EndSql

ElseIf mv_par01 = 2

BeginSql Alias cAliasQry
	
	SELECT DISTINCT QI2.QI2_REVINS, QI2.QI2_INSTR, COUNT(QI2_INSTR) NFNC FROM %table:QI2% QI2
	WHERE QI2.QI2_FILIAL = %xfilial:QI2% AND
	      QI2.QI2_INSTR <> %Exp:cTIntstr% AND
	      QI2.QI2_STATUS = '3' AND
	      QI2.QI2_CONREA <> %Exp:cTConRea% AND
	      QI2.QI2_OBSOL = 'N' AND
	      (QI2.QI2_ORIGEM = 'QNC' OR QI2.QI2_ORIGEM = 'QMT')
	GROUP BY QI2.QI2_INSTR, QI2.QI2_REVINS
	
EndSql

Else

BeginSql Alias cAliasQry
	
	SELECT DISTINCT QI2.QI2_REVINS, QI2.QI2_INSTR, COUNT(QI2_INSTR) NFNC FROM %table:QI2% QI2
	WHERE QI2.QI2_FILIAL = %xfilial:QI2% AND
	      QI2.QI2_INSTR <> %Exp:cTIntstr% AND
	      QI2.QI2_STATUS = '3' AND
	      QI2.QI2_OBSOL = 'N' AND
	      (QI2.QI2_ORIGEM = 'QNC' OR QI2.QI2_ORIGEM = 'QMT')
	GROUP BY QI2.QI2_INSTR, QI2.QI2_REVINS
	
EndSql

EndIf

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		Aadd(aDados ,{AllTrim(&(cAliasQry+"->QI2_REVINS")),AllTrim(&(cAliasQry+"->QI2_INSTR")),;
					  &(cAliasQry+"->NFNC")})
		(cAliasQry)->(DbSkip())
	EndDo
EndIf

aDados := aSort(aDados,,,{|x,y| x[3] > y[3]})

For nX := 1 To Len(aDados)
	aAdd(aRet,{aDados[nX][1]+" - "+aDados[nX][2],Transform(aDados[nx][3],"@E 999999"),CLR_GREEN,Nil})
	If Len(aRet) == 5
		Exit
	EndIf
Next nX

If Len(aRet) == 0
	aRet := {{STR0004,Transform(0,"@E 999999"),CLR_GREEN,Nil}}//"Não há dados para exibição"
EndIf

(cAliasQry)->(DbCloseArea())

Return aRet