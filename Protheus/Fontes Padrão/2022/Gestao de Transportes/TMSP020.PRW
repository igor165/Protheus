#include "protheus.ch"
#include "tmsp020.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSP020  ³ Autor ³ Rodolfo K. Rosseto    ³ Data ³15.01.07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Painel de Gestao - Ocupacao de Frota - Peso da Mercadoria  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSP020()

Local aInfo      := {}
Local cAliasQry  := GetNextAlias()
Local nPesoTot   := 0
Local nCapacTot  := 0
Local nPerc      := 0
Local cMsg       := ""
Local cWhere     := ""
Local cPerg      := "TMSP020"

Pergunte(cPerg,.F.)

If Empty(mv_par01)
	mv_par01 := Dtoc(dDataBase) + '-' + Dtoc(dDataBase)
EndIf

MakeSqlExpr(cPerg)

cWhere := '%' +mv_par01+ '%'

//Query com os pesos dos documentos nas viagens
BeginSql Alias cAliasQry

	SELECT SUM(PESO) PESOTOT, CASE WHEN SUM(PESO) IS NULL THEN 0 ELSE SUM(PESO) END PESOTOT
		FROM (SELECT SUM(DT6_PESO) PESO

	FROM %table:DTQ% DTQ

	JOIN %table:DTR% DTR
		ON DTR_FILIAL = %xFilial:DTR%
		AND DTR_FILORI = DTQ_FILORI
		AND DTR_VIAGEM = DTQ_VIAGEM
		AND DTR.%NotDel%
		
	JOIN %table:DA3% DA3
		ON DA3_FILIAL = %xFilial:DA3%
		AND DA3_COD = DTR_CODVEI
		AND DA3_FROVEI = %Exp:StrZero(1,Len(DA3->DA3_FROVEI))% //--Somente veiculos proprios
		AND DA3.%NotDel%
		
	JOIN %table:DUT% DUT
		ON DUT_FILIAL = %xFilial:DUT%
		AND DUT_TIPVEI = DA3_TIPVEI
		AND DUT_CATVEI <> %Exp:StrZero(3,Len(DUT->DUT_CATVEI))% //--Nao pode ser do Tipo Carreta
		AND DUT.%NotDel%

	JOIN %table:DUD% DUD
		ON DUD_FILIAL = %xFilial:DUD%
		AND DUD_FILORI = DTQ_FILORI
		AND DUD_VIAGEM = DTQ_VIAGEM
		AND DUD.%NotDel%
		
	JOIN %table:DT6% DT6
		ON DT6_FILIAL = %xFilial:DT6%
		AND DT6_FILDOC = DUD_FILDOC
		AND DT6_DOC = DUD_DOC
		AND DT6_SERIE = DUD_SERIE
		AND DT6.%NotDel%
		
	WHERE DTQ_FILIAL = %xFilial:DTQ%
		AND %Exp:cWhere%
		AND DTQ.%NotDel%
	
	GROUP BY DTQ_FILORI,DTQ_VIAGEM )QRY1

EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	nPesoTot := (cAliasQry)->PESOTOT
EndIf
(cAliasQry)->(DbCloseArea())

//--Query para verificar a capacidade dos veiculos
//--Veiculos do tipo carreta nao sao considerados neste calculo
BeginSql Alias cAliasQry

	SELECT SUM(CAPACN) CAPACNTOT, CASE WHEN SUM(CAPACN) IS NULL THEN 0 ELSE SUM(CAPACN) END CAPACNTOT
		FROM (SELECT DA3_COD, DA3_CAPACN CAPACN
		FROM %table:DA3% DA3

	JOIN %table:DUT% DUT
		ON DUT_FILIAL = %xFilial:DUT%
		AND DUT_TIPVEI = DA3_TIPVEI
		AND DUT_CATVEI <> %Exp:StrZero(3,Len(DUT->DUT_CATVEI))% //--Nao pode ser do Tipo Carreta
		AND DUT.%NotDel%

	WHERE DA3_FILIAL = %xFilial:DA3%
		AND DA3_FROVEI = %Exp:StrZero(1,Len(DA3->DA3_FROVEI))% //--Somente veiculos proprios
		AND DA3.%NotDel%) QRY2

EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	nCapacTot := (cAliasQry)->CAPACNTOT
	nPerc := Round((nPesoTot * 100) / nCapacTot,0)
EndIf
(cAliasQry)->(DbCloseArea())

cMsg := "'"+STR0001 +"'+chr(13)+chr(10)+" //--"O calculo foi baseado na soma dos Pesos de todos os documentos transportados"
cMsg += "'"+STR0002 +"'+chr(13)+chr(10)+" //--"versus a capacidade nominal de todos os veiculos da transportadora."
cMsg += "'"+STR0003 +AllTrim(Str(nPesoTot)) +"'+chr(13)+chr(10)+" //--"Peso Total dos Documentos: "
cMsg += "'"+STR0004 +AllTrim(Str(nCapacTot)) +"'+chr(13)+chr(10)+" //--"Capacidade Nominal dos Veiculos: "
cMsg += "'"+STR0005 +"'+chr(13)+chr(10)+" //--"(Soma do Peso dos documentos * 100) / Capacidade Nominal dos Veiculos"
cMsg += "'"+STR0006+"'" //--"*Consideramos no calculo apenas veiculos proprios e tracionadores (Cavalo)"

aInfo := { "",AllTrim(Str(nPerc))+"%",STR0007,Iif(nPerc > 50,CLR_BLUE,CLR_RED),"{ || MsgInfo("+cMsg+") }",0,100,nPerc } //"% Mes"

Return aInfo