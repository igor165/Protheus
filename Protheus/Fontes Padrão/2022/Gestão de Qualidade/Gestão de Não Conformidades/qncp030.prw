#include "protheus.ch"
#INCLUDE "QNCP030.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QNCP030  ³ Autor ³ Rafael S. Bernardi    ³ Data ³02/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Painel de Gestao - Nao-Conformidades por Fornecedor        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQNC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCP030()

Local aRetPanel := {} //Array com os dados que serão exibidos no painel
Local nX

Private aDados  := {}

Pergunte("QNCP30",.F.)

//Geracao dos Dados por fornecedor
QNCGerFor()
aAdd(aRetPanel,{STR0001,{}})//"Análise por Forncedor"
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
aAdd(aRetPanel,{STR0003,{}})//"Análise por Efeito"
For nX := 1 To Len(aDados)
	aAdd(aRetPanel[3][2],{aDados[nX][1]+" - "+aDados[nX][2],Transform(aDados[nX][3],"@E 99999"),CLR_GREEN,Nil})
Next nX

//Geracao dos Dados por disposição
QNCGerDis()
aAdd(aRetPanel,{STR0004,{}})//"Análise por Disposição"
For nX := 1 To Len(aDados)
	aAdd(aRetPanel[4][2],{aDados[nX][1]+" - "+aDados[nX][2],Transform(aDados[nX][3],"@E 99999"),CLR_GREEN,Nil})
Next nX

Return aRetPanel

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QNCGerFor ³ Autor ³ Rafael S. Bernardi    ³ Data ³02/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera os dados para o combo 1 do painel de gestao            ³±±
±±³          ³Nao-Conformidades por Fornecedor - Analise por Fornecedor   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQNC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
	aAdd(aDados,{STR0005,"",0})//"Não há dados para exibição"
EndIf

(cAliasQry)->(DbCloseArea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QNCGerCat ³ Autor ³ Rafael S. Bernardi    ³ Data ³02/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera os dados para o combo 2 do painel de gestao            ³±±
±±³          ³Nao-Conformidades por Fornecedor - Analise por Categoria    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQNC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
	aAdd(aDados,{STR0005,"",0})//"Não há dados para exibição"
EndIf

(cAliasQry)->(DbCloseArea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QNCGerEfe ³ Autor ³ Rafael S. Bernardi    ³ Data ³02/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera os dados para o combo 3 do painel de gestao            ³±±
±±³          ³Nao-Conformidades por Fornecedor - Analise por Efeito       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQNC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
	aAdd(aDados,{STR0005,"",0})//"Não há dados para exibição"
EndIf

(cAliasQry)->(DbCloseArea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QNCGerDis ³ Autor ³ Rafael S. Bernardi    ³ Data ³02/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera os dados para o combo 4 do painel de gestao            ³±±
±±³          ³Nao-Conformidades por Fornecedor - Analise por Disposicao   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAQNC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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
	aAdd(aDados,{STR0005,"",0})//"Não há dados para exibição"
EndIf

(cAliasQry)->(DbCloseArea())

Return