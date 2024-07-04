#include "protheus.ch"
#include "jura203g.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA203G
Rotina para calcular o fechamento da Emissao/Cancelamento da fatura
e geral

@Param   cTipoFat  Tipo de fatura: FT - Fatura
									MF - Minuta de Fatura
									MP - Minuta de Pre-Fatura
@Param   dDtProc   Data do processamento
@Param   cModulo   Tipo do Fechamento:
									FATEMI - Emissao
									FATCAN - Cancelamento
@Param   lCria     Varíavel lógica para forçar a criação de um novo período fechado ao fechar um anterior
@Param   lShowMsg  Se .T. exibe a mensagem de erro quando ocorrer


@Return  aRet       aRet[1] Data do Fechamento
					aRet[2] .T. se nao houver criticas na abertura do período
					aRet[3] Mensagem de erro
					aRet[4] Mensagem de Solução

@author Daniel Magalhaes
@since 30/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA203G( cTipoFat, dDtProc, cModulo, lCria, lShowMsg)
Local aRet       := {}
Local aArea      := GetArea()
Local lUsaFech   := GetMv( 'MV_JUTFECH',,.F. )
Local lFechAut   := GetMv( 'MV_JFECAUT',,.T. )   //Indica se deve realizar a abertura automática ou manual de período de Faturamento (.T./.F.)
Local cAnoMes    := ""
Local cAnoMesF   := ""
Local cQryCont   := ""
Local cAliCont   := Nil
Local cQryData   := ""
Local cAliData   := Nil
Local cQryPerFin := ""
Local cAliPerFin := Nil
Local cQryMaxD   := ""
Local cAliMaxD   := Nil 
Local dDtRet     := CtoD("")
Local dDtMax     := CtoD("")
Local cNvqCod    := ""
Local lRet       := .T.
Local IsPreFt    := IsInCallStack("JURA201") .Or. IsInCallStack("JA202REFAZ")
Local cSituac    := ""
Local cMsgMod    := ""
Local cMessage   := ""
Local cSolucao   := ""

Default lCria    := .F.
Default lShowMsg := .T.

If lUsaFech
	//Verifica/ Insere os registros de emissao e cancelamento
	
	Do Case
		Case AllTrim(cModulo) $ "FATEMI"
			cMsgMod := STR0002 //Emissão
		Case AllTrim(cModulo) $ "FATCAN"
			cMsgMod := STR0003 //Cancelamento
		OtherWise
			cMsgMod := cModulo
	EndCase
	
	cAnoMes := Left(DtoS(dDtProc),6)
		
	cQryCont :=  " Select NVQ.NVQ_MODULO, NVQ.NVQ_SITUAC "
	cQryCont += CRLF + " from "+ RetSqlName("NVQ") + " NVQ "
	cQryCont += CRLF + " where NVQ.NVQ_FILIAL = '" + xFilial("NVQ") + "'"
	cQryCont += CRLF +   " and NVQ.NVQ_ANOMES = '" + cAnoMes + "'"
	cQryCont += CRLF +   " and NVQ.NVQ_MODULO = '" + cModulo + "'"
	cQryCont += CRLF +   " and NVQ.D_E_L_E_T_ = ' '"
	cQryCont += CRLF + " Order by NVQ.NVQ_MODULO, NVQ.NVQ_SITUAC
		
	//Executa a query calculada
	cQryCont := ChangeQuery(cQryCont, .F.)
	DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)
		cAliCont := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryCont),cAliCont,.T.,.T.)
	
	If (cAliCont)->(Eof()) //Modulo não possui registro no ano mês, inclui um registro
		cSituac := Iif(lFechAut, "1", "2")
		cNvqCod := GETSXENUM("NVQ","NVQ_COD")

		RecLock("NVQ",.T.)
		NVQ->NVQ_FILIAL := xFilial("NVQ")
		NVQ->NVQ_COD    := cNvqCod
		NVQ->NVQ_ANOMES := cAnoMes
		NVQ->NVQ_MODULO := cModulo
		NVQ->NVQ_USER   := __cUserId
		NVQ->NVQ_DATA   := dDtProc
		NVQ->NVQ_SITUAC := cSituac
		NVQ->NVQ_OBS    := ""
		If NVQ->(ColumnPos("NVQ_RECALC")) > 0
			NVQ->NVQ_RECALC := "1"
		EndIf
		NVQ->(MsUnlock())
		NVQ->(DbCommit())
		
		If __lSX8
			ConfirmSX8()
		EndIf
		//Grava na fila de sincronização
		J170GRAVA("NVQ", xFilial("NVQ") + cNvqCod, "3")
	Else
		cSituac := (cAliCont)->NVQ_SITUAC
	EndIf

	(cAliCont)->( dbCloseArea() )
	
	If !lCria .And. !IsPreFt .And. cSituac != "1" //Não esta sendo criado para Rotina, não é pre-fatura e não esta aberto
		cMessage := I18N(STR0001, {cMsgMod, AllTrim(Transform(cAnoMes,'@R 9999-99'))}) // "O cadastro de fechamento não possue um período de #1 aberto para o ano-mês '#2'." //
		cSolucao := I18N(STR0004, {cModulo, AllTrim(Transform(cAnoMes,'@R 9999-99'))}) //"Verifique o período '#1' para o ano-mês '#2' no cadastro antes de utilizá-lo."
		lRet := .F.
		EndIf

EndIf
	

//Se utiliza o Fechamento, retorna a data (Emissao ou cancelamento)
If lRet .And. lUsaFech .And. AllTrim(cTipoFat) == "FT" .And. !IsPreFt

	cQryData :=       "select coalesce(min(NVQ.NVQ_ANOMES),'" + Space(6) + "') as MIN_ANOMES"
	cQryData += CRLF + " from " + RetSqlName("NVQ") + " NVQ "
	cQryData += CRLF + " where NVQ.NVQ_FILIAL = '" + xFilial("NVQ") + "'"
	cQryData += CRLF +   " and NVQ.NVQ_MODULO = '" + cModulo + "'"
	cQryData += CRLF +   " and NVQ.NVQ_ANOMES < '" + cAnoMes + "'"
	cQryData += CRLF +   " and NVQ.NVQ_SITUAC = '1'"
	cQryData += CRLF +   " and NVQ.D_E_L_E_T_ = ' '"
	
	//Executa a query calculada
	cQryData := ChangeQuery(cQryData, .F.)
	DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)
	cAliData := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryData),cAliData,.T.,.T.)

	If !(cAliData)->(Eof())
		cAnoMesF := (cAliData)->MIN_ANOMES
	EndIf
	(cAliData)->( dbCloseArea() )
	
	If !Empty(cAnoMesF)
		Do Case
			Case Month(StoD(cAnoMesF+"01")) == 2

				If Mod(Val(Substr(cAnoMes,1,4)),4) == 0				
					dDtRet := StoD(cAnoMesF+"29")
				Else
					dDtRet := StoD(cAnoMesF+"28")
				Endif 
			
			Case StrZero(Month(StoD(cAnoMesF+"01")),2) $ "04,06,09,11"
				dDtRet := StoD(cAnoMesF+"30")
			Otherwise
				dDtRet := StoD(cAnoMesF+"31")
		EndCase
	Else
		dDtRet := dDtProc
	EndIf
ElseIf lRet
	dDtRet := dDtProc
EndIf


If lRet .And. lUsaFech .And. AllTrim(cTipoFat) == "FT" .And. AllTrim(cModulo) $ "FATEMI,FATCAN" .And. !IsPreFt

	cQryMaxD :=        " select coalesce(max(NXA." + IIf(AllTrim(cModulo) == "FATEMI","NXA_DTEMI","NXA_DTCANC") + "),'" + Space(8) + "') as MAX_DATA"
	cQryMaxD += CRLF + " from " + RetSqlName("NXA") + " NXA "
	cQryMaxD += CRLF + " where NXA.NXA_FILIAL = '" + xFilial("NXA") + "'"
	cQryMaxD += CRLF +   " and NXA.NXA_TIPO = 'FT'"
	cQryMaxD += CRLF +   " and NXA.D_E_L_E_T_ = ' '"
	
	//Executa a query calculada
	cQryMaxD := ChangeQuery(cQryMaxD, .F.)
	DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)
	cAliMaxD := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryMaxD),cAliMaxD,.T.,.T.)
	
	TcSetField( cAliMaxD, "MAX_DATA" , "D", 8, 0 )

	If !(cAliMaxD)->(Eof())
		dDtMax := (cAliMaxD)->MAX_DATA
	EndIf
	(cAliMaxD)->( dbCloseArea() )
	
	If !Empty(dDtMax) .And. dDtMax > dDtRet
		dDtRet := dDtProc
	EndIf

EndIf

//Última validação para certificar que a data passada possui período em aberto
If lRet .And. lUsaFech .And. AllTrim(cTipoFat) == "FT" .And. AllTrim(cModulo) $ "FATEMI,FATCAN" .And. !IsPreFt

	cQryPerFin := "Select count(NVQ.R_E_C_N_O_) as VQUANT"
	cQryPerFin += CRLF + " from " + RetSqlName("NVQ") + " NVQ "
	cQryPerFin += CRLF + " where NVQ.NVQ_FILIAL = '" + xFilial("NVQ") + "'"
	cQryPerFin += CRLF +   " and NVQ.NVQ_MODULO = '" + cModulo + "'"
	cQryPerFin += CRLF +   " and NVQ.NVQ_SITUAC = '1'"
	cQryPerFin += CRLF +   " and NVQ.NVQ_ANOMES = '" + AnoMes(dDtRet) + "'"
	cQryPerFin += CRLF +   " and NVQ.D_E_L_E_T_ = ' '"
		
	//Executa a query calculada
	cQryPerFin := ChangeQuery(cQryPerFin, .F.)
	DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)
	cAliPerFin := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryPerFin),cAliPerFin,.T.,.T.)

	If (cAliPerFin)->VQUANT == 0 
		cMessage := I18N(STR0001, {cMsgMod, AllTrim(Transform(cAnoMes,'@R 9999-99'))}) // "Não existe período de #1 aberto para o ano-mês '#2'." //
		cSolucao := I18N(STR0004, {cModulo, AllTrim(Transform(cAnoMes,'@R 9999-99'))}) //"Verifique o período '#1' para o ano-mês '#2' no cadastro antes de utilizá-lo."
		lRet := .F.
		dDtRet := CtoD("")
	EndIf
	
	(cAliPerFin)->( dbCloseArea() )
	
EndIf

If !lRet .And. lShowMsg
	JurMsgErro(cMessage, ,cSolucao)
EndIf

// Tratamento para emissão com data retroativa via automação.
If !lUsaFech .And. FindFunction("GetParAuto") .And. cModulo == "FATEMI"
	aRetAuto := GetParAuto("JURLIQTESTCASE")
	If !Empty(aRetAuto)
		dDtRet := aRetAuto[1][1]
	EndIf
EndIf

RestArea(aARea)

aRet := {dDtRet, lRet, cMessage, cSolucao}

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J203GTest
Funcao de usuario para teste da rotina JURA203G

@Return Nil

@Param Nil

@author Daniel Magalhaes
@since 30/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J203GTest(dData, lCria)
Local cMsg := ""
Local dRet01 := CtoD("")
Local dRet02 := CtoD("")

Default lCria := .T.
Default dData := Date()

dRet01 := JURA203G( 'FT', dData, 'FATEMI', lCria )[1]
dRet02 := JURA203G( 'FT', dData, 'FATCAN', lCria )[1]

cMsg := "Teste da rotina JURA203G" + CRLF + CRLF

cMsg += "JURA203G( 'FT', "+ DtoC(dData)+", 'FATEMI', "+ AllToChar(lCria) +") == '" + DtoC(dRet01) + "'" + CRLF
cMsg += "JURA203G( 'FT', "+ DtoC(dData)+", 'FATCAN', "+ AllToChar(lCria) +") == '" + DtoC(dRet02) + "'" + CRLF

MsgInfo(cMsg)

Return