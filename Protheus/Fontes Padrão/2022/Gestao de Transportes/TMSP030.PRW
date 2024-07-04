#include "protheus.ch"
#include "tmsp030.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSP030  ³ Autor ³ Rodolfo K. Rosseto    ³ Data ³17.01.07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Painel de Gestao - Utilizadao da Frota em Horas            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSP030()

Local aInfo       := {}
Local cAliasQry   := GetNextAlias()
Local nTotVei     := 0
Local dDataIni    := Ctod("  /  /  ")
Local dDataFim    := Ctod("  /  /  ")
Local cHoraIni    := ""
Local cHoraFim    := ""
Local dAuxIni     := Ctod("  /  /  ")
Local dAuxFim     := Ctod("  /  /  ")
Local cAuxIni     := ""
Local cAuxFim     := ""
Local aOcup       := {}
Local aHorasDia   := {}
Local dPerIni     := dDataBase
Local dPerFim     := dDataBase
Local cData       := ""
Local nPos        := 0
Local nI          := 0
Local nHrsOcup    := 0
Local nHrsTotais  := 0
Local nOcupTempo  := 0
Local cMsg        := ""
Local cPerg       := "TMSP030"

//--Total de Veiculos Disponiveis
BeginSql Alias cAliasQry

	SELECT COUNT(DA3_COD) NTOTVEI
		FROM %table:DA3% DA3
	
	JOIN %table:DUT% DUT
		ON DUT_FILIAL = %xFilial:DUT%
		AND DUT_TIPVEI = DA3_TIPVEI
		AND DUT_CATVEI <> %Exp:StrZero(3,Len(DUT->DUT_CATVEI))% //--Nao pode ser do Tipo Carreta
		AND DUT.%NotDel%
	
	WHERE DA3_FILIAL = %xFilial:DA3%
		AND DA3_FROVEI = %Exp:StrZero(1,Len(DA3->DA3_FROVEI))% //--Somente veiculos proprios
		AND DA3.%NotDel%
	
EndSql
dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	nTotVei := (cAliasQry)->NTOTVEI
EndIf
(cAliasQry)->(DbCloseArea())

Pergunte(cPerg,.F.)

If !Empty(mv_par01)
	dPerIni := mv_par01
EndIf
If !Empty(mv_par02)
	dPerFim := mv_par02
EndIf

//--Indicador de utilizacao em tempo, da frota
BeginSql Alias cAliasQry

	Column DTQ_DATFEC as Date
	Column DTQ_DATENC as Date

	SELECT DTQ_VIAGEM, DTQ_DATFEC, DTQ_HORFEC, DTQ_DATENC, DTQ_HORENC, DTR_CODVEI
	
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

	WHERE DTQ_FILIAL = %xFilial:DTQ%
		AND DTQ_DATFEC BETWEEN %Exp:dPerIni% AND %Exp:dPerFim%
		AND DTQ.%NotDel%

EndSql

dbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !(cAliasQry)->(Eof())
		dDataIni := (cAliasQry)->DTQ_DATFEC //--Inicio do Uso do Veiculo
		dDataFim := (cAliasQry)->DTQ_DATENC //--Fim do Uso do Veiculo
		cHoraIni := Transform((cAliasQry)->DTQ_HORFEC,"@R 99:99") //--Hora Inicio de Uso do Veiculo
		cHoraFim := Transform((cAliasQry)->DTQ_HORENC,"@R 99:99") //--Hora Fim de Uso do Veiculo

		If (cAliasQry)->DTQ_DATFEC < dPerIni
			dDataIni := dPerIni
			cHoraIni := "00:00"
		EndIf

		If (cAliasQry)->DTQ_DATENC > dPerFim
			dDataFim := dPerFim
			cHoraFim := "24:00"
		EndIf

		If dDataIni == dDataFim //Se a viagem inicia e finaliza na mesma data
			TMSGrvHora(dDataIni,dDataFim,cHoraIni,cHoraFim,@aOcup,(cAliasQry)->DTR_CODVEI)
		Else //Se o inicio e fim da viagem ocorre em dias diferentes
			dAuxIni := dDataIni
			dAuxFim := dDataIni
			cAuxIni := cHoraIni
			cAuxFim := "24:00"

			While dAuxFim <= dDataFim
				TMSGrvHora(dAuxIni,dAuxFim,cAuxIni,cAuxFim,@aOcup,(cAliasQry)->DTR_CODVEI)
				
				dAuxIni++
				dAuxFim++
				If dAuxFim == dDataFim
					cAuxIni := "00:00"
					cAuxFim := cHoraFim
				Else
					cAuxIni := "00:00"
					cAuxFim := "24:00"
				EndIf
			EndDo
			
		EndIf		
		dbSelectArea(cAliasQry)
		(cAliasQry)->(DbSkip())
	EndDo
EndIf
(cAliasQry)->(DbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ordena por Data+Veiculo                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSort(aOcup,,,{|x,y| x[1] < y[1]})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria array com maior hora trabalhada por dia                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len(aOcup)
	cData := Substr(aOcup[nI,1],1,8)
	nPos  := aScan(aHorasDia,{|x| x[1] == cData })
	If nPos == 0
		Aadd(aHorasDia,{cData,aOcup[nI,2],aOcup[nI,2] * nTotVei})
	Else
		If aOcup[nI,2] > aHorasDia[nPos,2]
			aHorasDia[nPos,3] := (aOcup[nI,2] * nTotVei) // Maior numero de horas trabalhadas no dia
		EndIf
		aHorasDia[nPos,2] += aOcup[nI,2] // Somatoria das horas trabalhadas de todos os veiculos no dia
	EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula % de ocupacao                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to Len(aHorasDia)
	nHrsOcup   += aHorasDia[nI,2]
	nHrsTotais += aHorasDia[nI,3]
Next
nOcupTempo := Round( ((nHrsOcup * 100) / nHrsTotais),0)

cMsg := "'"+STR0001 +"'+chr(13)+chr(10)+" //--"O calculo utilizado foi baseado em Horas/Dia que o veiculo foi utilizado em"
cMsg += "'"+STR0002 +"'+chr(13)+chr(10)+" //--"viagens versus o numero total de veiculos da transportadora."
cMsg += "'"+STR0003 + AllTrim(Str(Round(nHrsOcup,0))) +"'+chr(13)+chr(10)+" //--"Tempo de Ocupacao do Veiculo: "
cMsg += "'"+STR0004 + AllTrim(Str(Round(nHrsTotais,0))) +"'+chr(13)+chr(10)+" //--"Tempo de Ocupacao Total: "
cMsg += "'"+STR0005 +"'+chr(13)+chr(10)+" //--"(Tmp. de Ocupacao do Veiculo * 100) / Tmp. de Ocupacao Total"
cMsg += "'"+STR0006+"'" //--"*Consideramos no calculo apenas veiculos proprios e tracionadores (Cavalo)"

aInfo := { "",AllTrim(Str(nOcupTempo))+"%",STR0007,Iif(nOcupTempo > 50,CLR_BLUE,CLR_RED),"{ || MsgInfo("+cMsg+") }",0,100,nOcupTempo } //"% Mes"

Return aInfo

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSGrvHora³ Autor ³ Marco Bianchi         ³ Data ³ 17/01/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava numero de horas por dia+veiculo.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSGrvHora()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1: Data Inicial                                          ³±±
±±³          ³ ExpD2: Data Final                                            ³±±
±±³          ³ ExpC3: Hora Inicial                                          ³±±
±±³          ³ ExpC4: Hora Final                                            ³±±
±±³          ³ ExpA5: Array com horas por dia+veiculo                       ³±±
±±³          ³ ExpC6: Codigo do Veiculo                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSGrvHora(dDataIni,dDataFim,cHoraIni,cHoraFim,aOcup,cVeiculo)

Local nPos   := 0
Local nHoras := 0

nHoras := SubtHoras(dDataIni,cHoraIni,dDataFim,cHoraFim)
nPos := aScan(aOcup,{|x| x[1] == Dtos(dDataIni)+cVeiculo })

If nPos == 0	
	Aadd(aOcup,{ Dtos(dDataIni)+cVeiculo,nHoras})
Else
	aOcup[nPos][2] += nHoras
EndIf

Return