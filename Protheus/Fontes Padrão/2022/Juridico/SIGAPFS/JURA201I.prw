#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA201I
Retorna a data máxima para emissão da fatura desta pré, baseado na configuracao
dos campos de 'Dia Maximo para Emissao da Fatura' (Campos NT0_DIAEMI e NUH_DIAEMI)

@Param cJCont      Char  Cod da Juncao
@Param cContr      Char  Cod do Contrato
@Param cFtAdc      Char  Cod da Fat. Adicional
@Param dDataProc   Date  Data do processamento (Default Date())

@Return dDataRet Date
Data da emissao da fatura
Obs.: Caso os campos acima nao estiverem configurados, o retorno
sera em branco (Empty)

@author Daniel Magalhaes
@since 26/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA201I(cCodPre, cJCont, cContr, cFtAdc, dDataProc)
Local cAliasQry   := GetNextAlias()
Local cQuery      := ""
Local cMonthTmp   := ""
Local cMonthNex   := ""
Local cDataRet    := ""
Local dDataRet    := CtoD("")
Local nMaxDia     := 0
Local nDiaTmp     := 0
Local nDiaNex     := 0
Local nMonth      := 0
Local nMonthNex   := 0

Default dDataProc := Date()

If !Empty(cJCont)
	cQuery := " select "
	cQuery +=     " min(case when NW2.NW2_DIAEMI = 0 then NUH.NUH_DIAEMI "
	cQuery +=         " else NW2.NW2_DIAEMI end) DIAEMI "
	cQuery += " from " + RetSqlName("NX8") + " NX8 "
	cQuery +=     " inner join " + RetSqlName("NUH") + " NUH "
	cQuery +=         " on( NUH.NUH_FILIAL = '" + xFilial("NUH") + "' "
	cQuery +=             " and NUH.NUH_COD = NX8.NX8_CCLIEN"
	cQuery +=             " and NUH.NUH_LOJA = NX8.NX8_CLOJA"
	cQuery +=             " and NUH.D_E_L_E_T_ = ' ' ) "
	cQuery +=     " inner join " + RetSqlName("NW3") + " NW3 "
	cQuery +=          " on( NW3.NW3_FILIAL = '" + xFilial("NW3") + "' "
	cQuery +=              " and NW3.NW3_CCONTR = NX8.NX8_CCONTR "
	cQuery +=              " and NW3.D_E_L_E_T_ = ' ') "
	cQuery +=     " inner join " + RetSqlName("NW2") + " NW2 "
	cQuery +=          " on( NW2.NW2_FILIAL =  '" + xFilial("NW2") + "' "
	cQuery +=              " and NW2.NW2_COD = NW3.NW3_CJCONT "
	cQuery +=              " and NW2.D_E_L_E_T_ = ' ') "
Else
	cQuery := " select "
	cQuery +=     " min(case"
	cQuery +=         " when NT0.NT0_DIAEMI = 0 then NUH.NUH_DIAEMI"
	cQuery +=         " else NT0.NT0_DIAEMI"
	cQuery +=     " end) DIAEMI"
	cQuery += " from " + RetSqlName("NX8") + " NX8 "
	cQuery +=     " inner join " + RetSqlName("NUH") + " NUH "
	cQuery +=         " on( NUH.NUH_FILIAL = '" + xFilial("NUH") + "' "
	cQuery +=             " and NUH.NUH_COD = NX8.NX8_CCLIEN "
	cQuery +=             " and NUH.NUH_LOJA = NX8.NX8_CLOJA "
	cQuery +=             " and NUH.D_E_L_E_T_ = ' ' ) "
	cQuery +=     " inner join " + RetSqlName("NT0") + " NT0 "
	cQuery +=         " on( NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
	cQuery +=             " and NT0.NT0_COD = NX8.NX8_CCONTR "
	cQuery +=             " and NT0.D_E_L_E_T_ = ' ' ) "
EndIf

cQuery +=      " where "
cQuery +=             " NX8.NX8_FILIAL = '" + xFilial("NX8") + "' "
cQuery +=             " and NX8.NX8_CPREFT = '" + cCodPre + "' "

If !Empty(cJCont)
	cQuery +=         " and NX8.NX8_CJCONT = '" + cJCont + "' and NX8.NX8_FATADC = '2' "
Else
	If !Empty(cFtAdc)
		cQuery +=     " and NX8.NX8_CFTADC = '" + cFtAdc + "' and NX8.NX8_FATADC = '1' "
	Else
		If !Empty(cContr)
			cQuery += " and NX8.NX8_CCONTR = '" + cContr + "' and NX8.NX8_FATADC = '2' "
		EndIf
	EndIf
EndIf

cQuery += " and NX8.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery, .F.)
DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasQry, .T., .T.)

(cAliasQry)->( dbGoTop() )
If !(cAliasQry)->(Eof())
	nMaxDia := (cAliasQry)->DIAEMI
EndIf

(cAliasQry)->( dbCloseArea() )

If nMaxDia > 0
	nDiaTmp   := nMaxDia
	nDiaNex   := nMaxDia

	nMonth    := Month(dDataProc)
	nMonthNex := IIf( nMonth == 12, 1, nMonth + 1 )

	cMonthTmp := StrZero(nMonth, 2)
	cMonthNex := StrZero(nMonthNex, 2)

	If nMaxDia > 28
		Do Case
			//Meses com 30 dias
			Case cMonthTmp $ "04,06,09,11"
				nDiaTmp := IIf(nDiaTmp > 30, 30, nDiaTmp)

			//Mes de Fevereiro
			Case cMonthTmp == "02"
				If Mod(Year(dDataProc), 4) == 0
					nDiaNex := 29
				Else
					nDiaNex := 28
				EndIf 

			//Meses com 31 dias
			Otherwise
				nDiaTmp := IIf(nDiaTmp > 31, 31, nDiaTmp)
		EndCase

		Do Case
			//Meses com 30 dias
			Case cMonthNex $ "04,06,09,11"
				nDiaNex := IIf(nDiaNex > 30, 30, nDiaNex)

			//Mes de Fevereiro
			Case cMonthNex == "02"
				If Mod(Year(dDataProc), 4) == 0
					nDiaNex := 29
				Else
					nDiaNex := 28
				EndIf

			//Meses com 31 dias
			Otherwise
				nDiaNex := IIf(nDiaNex > 31, 31, nDiaNex)
		EndCase
	EndIf

	//Se faturado apos a data maxima
	If nDiaTmp < Day(dDataProc)
		cDataRet := StrZero( Year(dDataProc) + IIf(nMonthNex == 1, 1, 0), 4 ) //Ano
		cDataRet += cMonthNex                                                 //Mes
		cDataRet += StrZero(nDiaNex, 2)                                       //Dia

	Else
		cDataRet := StrZero( Year(dDataProc), 4 ) //Ano
		cDataRet += cMonthTmp                     //Mes
		cDataRet += StrZero(nDiaTmp, 2)           //Dia

	EndIf

	dDataRet := StoD(cDataRet)
EndIf

Return dDataRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201ITest
Funcao de usuario para teste da rotina JURA201I.

@author Daniel Magalhaes
@since 27/07/2011
@version 1.0
/*/
//-------------------------------------------------------------------
User Function J201ITest()
Local cMsg      := ""
Local cDTipo    := ""
Local cTipo     := "1"
Local cJCont    := "0132"
Local cContr    := ""
Local cFtAdc    := ""
Local dDataProc := Date()
Local dRet      := JURA201I( "1", "0132", "", "", Date() )

Do Case
	Case cTipo == "1"
		cDTipo := "Junção"
	Case cTipo == "2"
		cDTipo := "Contrato"
	Case cTipo == "3"
		cDTipo := "Fat. Adicional"
EndCase

cMsg := "Teste rotina JURA201I" + CRLF + CRLF
cMsg += "Parâmetros:" + CRLF
cMsg += "  cTipo: " + cTipo + " - " + cDTipo + CRLF
cMsg += "  cJCont: " + cJCont + CRLF
cMsg += "  cContr: " + cContr + CRLF
cMsg += "  cFtAdc: " + cFtAdc + CRLF
cMsg += "  dDataProc: " + DtoC(dDataProc) + CRLF + CRLF
cMsg += "Retorno:" + CRLF
cMsg += "  dRet: " + DtoC(dRet)

MsgInfo(cMsg)

Return
