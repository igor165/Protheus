#include 'totvs.ch'
#include 'TECXFUNB.CH'
#INCLUDE "FWMVCDEF.CH"

Static lTecDelPln 	:= .F.
Static aDiasBenf	:= {}
Static cRetF3		:= ""
Static aHasPerg		:= {}
Static aAtendVer	:= {}
Static aExistAloc	:= {}
Static cRetXCCT 	:= ""

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecGetApnt

@description Retorna em forma de Array os materiais apontados

@param cCod, string, Código da TFH ou TFG
@param cTable, string, TFT ou TFS, dependendo da tabela a ser pesquisada
@param aColumns, array, colunas que devem ser incluidas no SELECT.

@return aRet, array, resultado da query

@author	Mateus Boiani
@since		03/12/2018
/*/
//------------------------------------------------------------------------------
Function TecGetApnt(cCod, cTable, aColumns)
Local nX
Local aArea := GetArea()
Local cSql := "SELECT "
Local aRet := {}
Local aAux := {}
Local cAliasAux := GetNextAlias()

Default aColumns := {cTable+"_CODIGO"}

For nX := 1 To LEN(aColumns)
	cSql += " " + cTable+"."+aColumns[nX] + " ,"
Next
cSql := LEFT(cSql, LEN(cSql)-1)
cSql += " FROM " + RetSqlName(cTable) + " " + cTable
cSql += " WHERE " + cTable+".D_E_L_E_T_ = ' ' AND " + cTable
cSql += "."+cTable+"_FILIAL = '" +xFilial(cTable) + "'"
cSql += " AND " + cTable+"."+cTable+"_COD"+IIF(LEFT(cTable,3)=="TFT","TFH","TFG") + " = '"
cSql += cCod + "'"

cSql := ChangeQuery(cSql)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasAux, .F., .T.)

While (cAliasAux)->(!Eof())
	For nX := 1 To LEN(aColumns)
		AADD(aAux , (&("('"+cAliasAux+"')->("+aColumns[nX]+")")))
	Next
	AADD( aRet, aAux)
	aAux := {}
	(cAliasAux)->(DbSkip())
End

(cAliasAux)->(DbCloseArea())

RestArea(aArea)

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecSumPrd

@description Função para Orçamento Agrupados. Soma o total de um determinado produto
agrupador dentro de uma TFL no orçamento

@param cCodTFJ, string, Código da TFJ
@param cCodTFL, string, Código da TFL
@param cCodProd, string, Código do produto que será somado

@return nRet, numeric, resultado da soma dos totalizadores

@author	Mateus Boiani
@since		03/12/2018
/*/
//------------------------------------------------------------------------------
Function TecSumPrd(cCodTFJ, cCodTFL ,cCodProd)
Local aArea := GetArea()
Local cAliasAux := GetNextAlias()
Local cSQL := ""
Local nRet := 0

DbSelectArea("TFJ")
DbSetOrder(1)

If MsSeek(xFilial("TFJ") + cCodTFJ)
	cSQL := " SELECT ( "
	If cCodProd == TFJ->TFJ_GRPRH
		cSQL += " SUM(TFL.TFL_TOTRH) +"
	EndIf
	If cCodProd == TFJ->TFJ_GRPMI
		cSQL += " SUM(TFL.TFL_TOTMI) +"
	EndIf
	If cCodProd == TFJ->TFJ_GRPMC
		cSQL += " SUM(TFL.TFL_TOTMC) +"
	EndIf
	If cCodProd == TFJ->TFJ_GRPLE
		cSQL += " SUM(TFL.TFL_TOTLE) +"
	EndIf
	cSQL := LEFT(cSQL, LEN(cSQL)-1)
	cSQL += " ) AS TOTAL "
	cSQL += " FROM " + RetSqlName("TFL") + " TFL "
	cSQL += " WHERE TFL.TFL_CODPAI = '" + cCodTFJ + "' AND "
	cSQL += " TFL.TFL_CODIGO = '" + cCodTFL + "' AND "
	cSQL += " TFL.D_E_L_E_T_ = ' ' AND TFL.TFL_FILIAL = '" + xFilial("TFJ") + "'"
	cSQL := ChangeQuery(cSQL)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasAux, .F., .T.)
	nRet := (cAliasAux)->(TOTAL)
	(cAliasAux)->(DbCloseArea())
EndIf

RestArea(aArea)

Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecSumInMdl

@description Função para Orçamento Agrupados. Soma o total de um determinado produto
agrupador dentro de uma TFL no orçamento. Similar a função TecSumPrd, porém somando
nos modelos ao invés de consultar o banco de dados

@param oModelTFL, obj, Modelo da TFL
@param oModelTFJ, obj, Modelo da TFJ
@param cCodProd, string, Código do produto que será somado

@return nRet, numeric, resultado da soma dos totalizadores

@author	Mateus Boiani
@since		03/12/2018
/*/
//------------------------------------------------------------------------------
Function TecSumInMdl(oModelTFL, oModelTFJ, cCodPrd)
Local nRet := 0

nRet += IIF(cCodPrd == oModelTFJ:GetValue("TFJ_GRPMI"),oModelTFL:GetValue("TFL_TOTMI"),0)
nRet += IIF(cCodPrd == oModelTFJ:GetValue("TFJ_GRPMC"),oModelTFL:GetValue("TFL_TOTMC"),0)
nRet += IIF(cCodPrd == oModelTFJ:GetValue("TFJ_GRPLE"),oModelTFL:GetValue("TFL_TOTLE"),0)
nRet += IIF(cCodPrd == oModelTFJ:GetValue("TFJ_GRPRH"),oModelTFL:GetValue("TFL_TOTRH"),0)

Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecMedPrd

@description Apartir de um código de produto, verifica na CNB se há medições,
somando o valor do campo CNB_QTDMED

@param cContra, string, código do contrato
@param cRev, string, revisão do contrato
@param cPlan, string, código da planilha (CNB_NUMERO)
@param cProd, string, código do produto
@param cItem, string, item do produto na CNB (opcional)

@return nRet, numeric, resultado da soma do campo CNB_QTDMED

@author	Mateus Boiani
@since		03/12/2018
/*/
//------------------------------------------------------------------------------
Function TecMedPrd(cContra, cRev, cPlan, cProd, cItem)
Local nRet := 0
Local cSql := ""
Local aArea := GetArea()
Local cAliasAux := GetNextAlias()

Default cItem := ""

cSql := " SELECT SUM(CNB.CNB_QTDMED) AS QTDMED FROM " + RetSqlName("CNB") + " CNB "
cSql += " WHERE  CNB.CNB_FILIAL = '" +  xFilial("CNB") + "' AND CNB.D_E_L_E_T_ = ' ' AND "
cSql += " CNB.CNB_CONTRA = '" + cContra + "' AND CNB.CNB_PRODUT = '" + cProd + "' AND "
cSql += " CNB.CNB_REVISA = '" + cRev + "' AND CNB.CNB_NUMERO = '" + cPlan + "'"
If !EMPTY(cItem)
	cSql += " AND CNB.CNB_ITEM = '" + cItem + "'"
EndIf
cSql := ChangeQuery(cSql)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasAux, .F., .T.)

If !(cAliasAux)->(EOF())
	nRet := (cAliasAux)->(QTDMED)
EndIf

(cAliasAux)->(DbCloseArea())

RestArea(aArea)
Return nRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} HasMunProd

Verifica se existe o dicionario de dados para controle de munição por produto
@author Matheus Lando Raimundo
@since 17/12/18

/*/
//--------------------------------------------------------------------------------------------------------------------
Function HasMunPrd()
Local lRet := .F.

lRet := AliasInDic('T49')

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} HasOrcSimp

Verifica se existe o dicionario de dados do Orçamento Simplificado
@author Mateus Boiani
@since 19/12/2018

/*/
//--------------------------------------------------------------------------------------------------------------------
Function HasOrcSimp()

Return (TFJ->(ColumnPos('TFJ_ORCSIM')) > 0)

//------------------------------------------------------------------------------
/*/{Protheus.doc} GSGetIns
Recupera os insumos utilizados no GS

@sample 	GSGetCtx(cTipo)
@param		cTipo	Tipo do insumo

@author	guilherme.pimentel
@since		15/05/2018

@Obs		Os tipos de material podem ser:
			MI - Material de implantação
			MC - Material de consumo
			RH - Recursos humanos
			LE - Locação de Equipamentos
			AR - Armamento

			Os tipos de insumo MI e MC utilizam o memso parâmetro
/*/
//------------------------------------------------------------------------------

Function GSGetIns(cTipo)
Local lRet := .T.

If cTipo $ 'MI|MC'
	lRet	:= SuperGetMv("MV_GSMIMC",,.T.)
Else
	lRet	:= SuperGetMv("MV_GS"+cTipo,,.T.)
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecNvl

@description Faz a mesma coisa que o ISNULL do SqlServer ou o NVL do Oracle,
Se o primeiro parâmetro for null, retorna o valor do segundo parâmetro, caso contrário,
retorna o valor do primeiro parâmetro

@author	Mateus Boiani
@since	16/01/2019
/*/
//------------------------------------------------------------------------------
Function TecNvl(uValue1, uValue2)
Local uRet

If ValType(uValue1) != "U"
	uRet := uValue1
Else
	uRet := uValue2
EndIf

Return uRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecActivt

@description Realiza o ACTIVATE de um modelo
(Essa função é amplamente utilizada na manipulação da Tabela de Precificação do TECA740F)

@author	Mateus Boiani
@since	21/01/2019
/*/
//------------------------------------------------------------------------------
Function TecActivt(oModel)

Return oModel:Activate()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TecDaysIn
@description Recebe dois períodos de datas e retorna quantos dias do período 1 existem no período 2
@param dDtIni, date, Inicio do período 1
@param dDtFim, date, Fim do período 1
@param dSelectD, date, Inicio do período 2
@param dSelectAt, date, Fim do período 2
@author  Mateus Boiani
@version P12
@since 	 28/06/2018
@return nRet, int, quantidade de dias
/*/
//--------------------------------------------------------------------------------------
Function TecDaysIn(dDtIni, dDtFim, dSelectD, dSelectAt)

Local nRet := 0
Local nAux := dDtFim - dDtIni
Local nX

For nX := 0 To nAux
	If dDtIni + nX >= dSelectD .AND. dDtIni + nX <= dSelectAt
		nRet++
	EndIf
Next

Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecHasPerg

@description Verifica se um determinado pergunte existe em um grupo de perguntas
@author	Mateus Boiani
@since	30/04/2019
/*/
//------------------------------------------------------------------------------
Function TecHasPerg(cX1_VAR01,cX1_GRUPO)
Local lRet := .F.
Local aArea
Local aAreaX1
Local nAux := 0

If !EMPTY(aHasPerg) .AND. (nAux := ASCAN(aHasPerg, {|a| a[1] == cX1_VAR01 .AND. a[2] == cX1_GRUPO})) != 0
	lRet := aHasPerg[nAux][3]
Else
	aArea := GetArea()
	aAreaX1 := SX1->(GetArea())

	DbSelectArea("SX1")
	SX1->(DbSetOrder(1))

	If SX1->(DbSeek(cX1_GRUPO))
		While Alltrim(SX1->X1_GRUPO) == Alltrim(cX1_GRUPO) .AND. !EOF()
			If UPPER(Alltrim(SX1->X1_VAR01)) == UPPER(Alltrim(cX1_VAR01))
				lRet := .T.
				Exit
			EndIf
			SX1->(DbSkip())
		End
	EndIf
	AADD(aHasPerg, {cX1_VAR01,cX1_GRUPO, lRet})
	RestArea(aAreaX1)
	RestArea(aArea)
EndIf
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecConfAlo

@description Exibe um log para apresentar se na demissão ou qualquer tipo de
afastamento se existe conflito com alocação.
@author	Augusto Albuquerque
@since	20/05/2019
/*/
//------------------------------------------------------------------------------
Function TecConfAlo( oModel, dDataDem1 )

Local cAliasTemp	:= GetNextAlias()
Local cAliasDT		:= GetNextAlias()
Local aArea			:= GetArea()
Local aPEConfa		:= {}
Local aAgenda		:= {}
Local cABBIdCFal	:= ""
Local cMatAtendente	:= ""
Local cNomeAtendete := ""
Local cCodTec		:= ""
Local cQuery		:= ""
local cSql			:= ""
Local cMsg			:= ""
Local cAusencia		:= ""
Local dDemissa		:= ""
Local dAusDataI		:= ""
Local dAusDataF		:= ""
Local dABBDataI		:= ""
Local dABBDataF		:= ""
Local lGPEA010		:= IsInCallStack("GPEA010")
Local lGPEA180		:= IsInCallStack("GPEA180")
Local lGPEM060		:= IsInCallStack("GPEM060")
Local lGPEM040		:= IsInCallStack("GPEM040")
Local lGPEA240		:= .F.
Local lGPEM030		:= .F.
Local lATPECONFA	:= ExistBlock('ATPECONFA')
Local lVer			:= .F.
Local nX
Local oMdlGPEM		:= Nil
Local lUseArea		:= .F.

Default oModel		:= Nil
Default dDataDem1 	:= CtoD("")

If ValType(oModel) == "O"
	lGPEA240		:= oModel:GetId() == "GPEA240"
	lGPEM030		:= oModel:GetId() == "GPEM030"
EndIf

If lGPEA240
	cAusencia	:= STR0001 // "ausência"
ElseIF lGPEA010
	cAusencia	:= STR0002 // "demissão"
	cMatAtendente	:= M->RA_MAT
	dDemissa	:= M->RA_DEMISSA
ElseIf lGPEA180
	cAusencia	:= STR0014 //transferência
	cMatAtendente	:= M->RA_MAT
	dDemissa	:= dDataBase
ElseIf lGPEM030 .OR. lGPEM060
	cAusencia	:= STR0015 //férias
	If lGPEM030
		cMatAtendente	:= oModel:GetValue("GPEM030_MSRH", "RH_MAT")
		dAusDataI 	:= oModel:GetValue("GPEM030_MSRH", "RH_DATAINI")
		dAusDataF	:= oModel:GetValue("GPEM030_MSRH", "RH_DATAFIM")
	Else
		cMatAtendente	:= SRH->RH_MAT
		dAusDataI	:= SRH->RH_DATAINI
		dAusDataF	:= SRH->RH_DATAFIM
	EndIf
ElseIf lGPEM040
	oMdlGPEM := FWModelActive()
	cAusencia	:= STR0002 // "demissão"
	cMatAtendente	:= oMdlGPEM:GetValue("GPEM040_MSRG", "RG_MAT")
	dDemissa	:= dDataDem1
EndIf


cMsg	+= STR0003 + cAusencia + STR0004 + CRLF + CRLF // "Verificamos que há integração do SIGAGPE com o SIGATEC. A lista abaixo representa o conflito no período de alocação do funcionário com a" ## "cadastrada. Segue(m) o(s) ponto(s) de conflito(s)."

If !lGPEA240
	cQuery 	:= "SELECT SRA.RA_NOME, AA1.AA1_CODTEC, ABB.ABB_DTINI, ABB.ABB_DTFIM, ABB.ABB_IDCFAL FROM " + RetSqlName("SRA") + " SRA "
	cQuery 	+= "INNER JOIN " + RetSqlName("AA1") + " AA1 "
	cQuery	+= "ON AA1.AA1_CDFUNC = SRA.RA_MAT AND "
	cQuery	+= "AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
	cQuery 	+= "INNER JOIN " + RetSqlName("ABB") + " ABB "
	cQuery	+= "ON AA1.AA1_CODTEC = ABB.ABB_CODTEC " + " AND "
	cQuery	+= "ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
	cQuery	+= "WHERE SRA.RA_MAT = '" + cMatAtendente + "'" + " AND "
	cQuery 	+= "SRA.RA_FILIAL = '" + xFilial("SRA") + "' "
	cQuery	+= "AND SRA.D_E_L_E_T_ = ' ' "
	cQuery	+= "AND AA1.D_E_L_E_T_ = ' ' "
	cQuery	+= "AND ABB.D_E_L_E_T_ = ' ' "

	cSql	:= "SELECT MIN(ABB.ABB_DTINI) DTMIN , MAX(ABB.ABB_DTFIM) DTMAX FROM " + RetSqlName("ABB") + " ABB "
	cSql	+= "INNER JOIN " + RetSqlName("AA1") + " AA1 "
	cSql	+= "ON AA1.AA1_CODTEC = ABB.ABB_CODTEC AND "
	cSql	+= "AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
	cSql	+= "INNER JOIN " + RetSqlName("SRA") + " SRA "
	cSql	+= "ON AA1.AA1_CDFUNC = SRA.RA_MAT AND "
	cSql	+= "SRA.RA_FILIAL = '" + xFilial("SRA") + "' "
	cSql	+= "WHERE SRA.RA_MAT = '" + cMatAtendente + "'" + " AND "
	cSql 	+= "ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
	cSql	+= "AND SRA.D_E_L_E_T_ = ' ' "
	cSql	+= "AND AA1.D_E_L_E_T_ = ' ' "
	cSql	+= "AND ABB.D_E_L_E_T_ = ' ' "
EndIf

If lGPEA240

	cMatAtendente 	:= oModel:GetValue("GPEA240_SRA", "RA_MAT")
	oModel	:=	oModel:GetModel("GPEA240_SR8")

	For nX := 1 To oModel:Length()

		oModel:GoLine(nX)

		If oModel:IsDeleted() .OR. !(oModel:IsInserted() .OR. oModel:IsUpdated())
			Loop
		EndIF

		dAusDataI	:= oModel:GetValue("R8_DATAINI")
		dAusDataF	:= oModel:GetValue("R8_DATAFIM")

		cQuery 	:= "SELECT SRA.RA_NOME, AA1.AA1_CODTEC, ABB.ABB_DTINI, ABB.ABB_DTFIM, ABB.ABB_IDCFAL FROM " + RetSqlName("SRA") + " SRA "
		cQuery 	+= "INNER JOIN " + RetSqlName("AA1") + " AA1 "
		cQuery	+= "ON AA1.AA1_CDFUNC = SRA.RA_MAT AND "
		cQuery	+= "AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
		cQuery 	+= "INNER JOIN " + RetSqlName("ABB") + " ABB "
		cQuery	+= "ON AA1.AA1_CODTEC = ABB.ABB_CODTEC " + " AND "
		cQuery	+= "ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
		cQuery	+= "WHERE SRA.RA_MAT = '" + cMatAtendente + "'" + " AND "
		cQuery	+= "SRA.RA_FILIAL = '" + xFilial("SRA") + "' "
		cQuery	+= "AND SRA.D_E_L_E_T_ = ' ' "
		cQuery	+= "AND AA1.D_E_L_E_T_ = ' ' "
		cQuery	+= "AND ABB.D_E_L_E_T_ = ' ' "
		cQuery	+= "AND (ABB.ABB_DTINI >= '" + DTos( dAusDataI ) + "' AND ABB.ABB_DTINI <= '" + Dtos( dAusDataF )+ "')"

		cQuery		:= ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cAliasTemp, .T., .T.)

		If !(cAliasTemp)->(EOF())

			cQuery 	:= "SELECT MIN(ABB.ABB_DTINI) DTMIN , MAX(ABB.ABB_DTFIM) DTMAX FROM " + RetSqlName("ABB") + " ABB "
			cQuery 	+= "INNER JOIN " + RetSqlName("AA1") + " AA1 "
			cQuery	+= "ON AA1.AA1_CODTEC = ABB.ABB_CODTEC AND "
			cQuery	+= "AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
			cQuery	+= "INNER JOIN " + RetSqlName("SRA") + " SRA "
			cQuery	+= "ON AA1.AA1_CDFUNC = SRA.RA_MAT AND "
			cQuery	+= "SRA.RA_FILIAL = '" + xFilial("SRA") + "' "
			cQuery	+= "WHERE SRA.RA_MAT = '" + cMatAtendente + "'" + " AND "
			cQuery	+= "ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
			cQuery	+= "AND SRA.D_E_L_E_T_ = ' ' "
			cQuery	+= "AND AA1.D_E_L_E_T_ = ' ' "
			cQuery	+= "AND ABB.D_E_L_E_T_ = ' ' "
			cQuery	+= "AND (ABB.ABB_DTINI >= '" + DTos( dAusDataI ) + "' AND ABB.ABB_DTINI <= '" + Dtos( dAusDataF )+ "')"

			cQuery		:= ChangeQuery(cQuery)
			DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cAliasDT, .T., .T.)

			If !(cAliasDT)->(EOF())
				dABBDataF 	:= Stod((cAliasDT)->(DTMAX))
				dABBDataI	:= Stod((cAliasDT)->(DTMIN))
				cABBIdCFal	:= LEFT((cAliasTemp)->(ABB_IDCFAL), TamSx3("CN9_NUMERO")[1])
				cNomeAtendete	:= (cAliasTemp)->(RA_NOME)
				cCodTec			:= (cAliasTemp)->(AA1_CODTEC)
				lVer := .T.
			EndIf
			(cAliasDT)->(DbCloseArea())
		EndIf
		(cAliasTemp)->(DbCloseArea())
	Next nX
ElseIf lGPEA010 .OR. lGPEA180 .OR. lGPEM040

	cQuery	+= "AND (ABB.ABB_DTINI >= '" + DTos( dDemissa ) + "' AND ABB.ABB_DTINI >= '" + Dtos( dDemissa )+ "')"

	cQuery		:= ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cAliasTemp, .T., .T.)
	lUseArea := .T.
	If !(cAliasTemp)->(EOF())
		cSql		+= "AND (ABB.ABB_DTINI >= '" + DTos( dDemissa ) + "' AND ABB.ABB_DTFIM >= '" + Dtos( dDemissa )+ "')"
		cSql		:= ChangeQuery(cSql)
		DbUseArea(.T., "TOPCONN",TcGenQry(,,cSql), cAliasDT, .T., .T.)

		If !(cAliasDT)->(EOF())
			dABBDataF 	:= Stod((cAliasDT)->(DTMAX))
			dABBDataI	:= Stod((cAliasDT)->(DTMIN))
			cABBIdCFal	:= LEFT((cAliasTemp)->(ABB_IDCFAL), TamSx3("CN9_NUMERO")[1])
			cNomeAtendete	:= (cAliasTemp)->(RA_NOME)
			cCodTec			:= (cAliasTemp)->(AA1_CODTEC)
			lVer	:= .T.
		EndIf
		(cAliasDT)->(DbCloseArea())
	EndIF
ElseIf lGPEM030 .OR. lGPEM060
	cQuery	+= "AND (ABB.ABB_DTINI >= '" + DTos( dAusDataI ) + "' AND ABB.ABB_DTINI <= '" + Dtos( dAusDataF )+ "')"
	cQuery		:= ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cAliasTemp, .T., .T.)
	lUseArea := .T.
	If !(cAliasTemp)->(EOF())
		cSql	+= "AND (ABB.ABB_DTINI >= '" + DTos( dAusDataI ) + "' AND ABB.ABB_DTINI <= '" + Dtos( dAusDataF )+ "')"
		cSql		:= ChangeQuery(cSql)
		DbUseArea(.T., "TOPCONN",TcGenQry(,,cSql), cAliasDT, .T., .T.)

		If !(cAliasDT)->(EOF())
			dABBDataF 	:= Stod((cAliasDT)->(DTMAX))
			dABBDataI	:= Stod((cAliasDT)->(DTMIN))
			cABBIdCFal	:= LEFT((cAliasTemp)->(ABB_IDCFAL), TamSx3("CN9_NUMERO")[1])
			cNomeAtendete	:= (cAliasTemp)->(RA_NOME)
			cCodTec			:= (cAliasTemp)->(AA1_CODTEC)			
			lVer	:= .T.
		EndIf
		(cAliasDT)->(DbCloseArea())
	EndIF
EndIf
If !lGPEA240 .AND. lUseArea
	(cAliasTemp)->(DbCloseArea())
EndIf

If lVer
	If lATPECONFA
		cAliasDT	:= GetNextAlias()
		cSql	:= " SELECT ABB.ABB_DTINI, ABB.ABB_DTFIM, ABB.ABB_HRINI, ABB.ABB_HRFIM, ABB.ABB_CODIGO, ABB.ABB_CHEGOU, ABB.ABB_LOCAL, "
		cSql	+= " ABB.ABB_IDCFAL, ABB.R_E_C_N_O_"  
		cSql	+= " FROM " + RetSqlName("ABB") + " ABB "
		cSql	+= " WHERE ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
		cSql	+= " AND ABB.ABB_CODTEC = '" + cCodTec + "' "
		If EMPTY(dDemissa)
			cSql	+= " AND (ABB.ABB_DTINI >= '" + DTos( dAusDataI ) + "' AND ABB.ABB_DTINI <= '" + Dtos( dAusDataF )+ "') "
		Else	
			cSql	+= " AND (ABB.ABB_DTINI >= '" + DTos( dDemissa ) + "' AND ABB.ABB_DTFIM >= '" + Dtos( dDemissa )+ "') "
		EndIf
		cSql	+= " AND ABB.D_E_L_E_T_ = ' ' "
	
		cSql	:= ChangeQuery(cSql)
		DbUseArea(.T., "TOPCONN",TcGenQry(,,cSql), cAliasDT, .T., .T.)
		
		While (cAliasDT)->(!EOF())
			AADD(aAgenda, { (cAliasDT)->(ABB_DTINI),;	// Data Inicio
							(cAliasDT)->(ABB_DTFIM),;	// Data Fim
							(cAliasDT)->(ABB_HRINI),;	// Hora Inicio
							(cAliasDT)->(ABB_HRFIM),;	// Hora Fim
							(cAliasDT)->(ABB_CODIGO),;	// Codigo da ABB
							(cAliasDT)->(ABB_CHEGOU),;	// ABB_CHEGOU
							(cAliasDT)->(ABB_LOCAL),;	// Local
							(cAliasDT)->(ABB_IDCFAL),;	// IDCFAL
							(cAliasDT)->(R_E_C_N_O_)})	// RECNO
			(cAliasDT)->(DbSkip())		
		EndDo
		(cAliasDT)->(DbCloseArea())
		AADD(aPEConfa, {cMatAtendente,; // Matricula
						cNomeAtendete,; // Nome do Atendente
						cCodTec,; // Codigo do Atendente
						cABBIdCFal,; // Numero do Contrato
						dAusDataI,; // Inicio das Ausencias
						dAusDataF,; // Fim das Ausencias
						dABBDataI,; // Inicio da Agenda
						dABBDataF,; // Fim da Agenda
						cAusencia,; // Motivo da Ausencia
						dDemissa}) // Data da demissão
		ExecBlock('ATPECONFA', .F. , .F. , {aPEConfa, aAgenda} )
	Else
		cMsg += STR0005 + cNomeAtendete +  CRLF // "Atendente/Funcionário:"
		cMsg += STR0006 + cMatAtendente + CRLF // "Matrícula: "
		cMsg += STR0007 + cCodTec + CRLF // "Codigo técnico: "
		cMsg += STR0008 + cABBIdCFal + CRLF + CRLF // "Contrato: "
		If EMPTY(dDemissa)
			cMsg += STR0009 + Dtoc(dAusDataI) + STR0011 + Dtoc(dAusDataF) + CRLF // "Tempo de ausência: " ## " até "
		Else
			cMsg += STR0013 + Dtoc(dDemissa) + CRLF  // "Data da demissão: "
		EndIf
		cMsg += STR0010 + DToc(dABBDataI) + STR0011 + DToc(dABBDataF) + CRLF + CRLF + CRLF// "Tempo de alocação: " ## " até "
		AtShowLog(cMsg,STR0012,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.) // "Atendente"
	EndIf
EndIf
	
cQuery	:= ""
cSql	:= ""
RestArea(aArea)
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecBRevCTR

@description Modifica a estrutura do CNTA300 durante a revisão do contrato
@author	Mateus Boiani
@since	01/07/2019
/*/
//------------------------------------------------------------------------------
Function TecBRevCTR(oModel,cTpRev,aCampos)

Cn300EspVld(oModel,cTpRev)
Cn300VdArr()
A300RevCtb(oModel)

//-- Parâmetro que permite revisão de caução
If SuperGetMV("MV_CNRVCAU",.F.,.F.)
	//-- Somente libera o percentual de caução caso a flag esteja como 1=SIM
	aAdd(aCampos,{'CN9MASTER',{'CN9_MINCAU'}})
	MtBCMod(oModel,aCampos,{||FwFldGet('CN9_FLGCAU') == '1'},'2')
	aCampos := {}
EndIf	
aAdd(aCampos,{'CN9MASTER',{'CN9_PROXRJ', 'CN9_DTASSI', 'CN9_ASSINA'}})
aAdd(aCampos,{'CNCDETAIL', {'CNC_CLIENT','CNC_LOJACL'}})
aAdd(aCampos,{'CNADETAIL',{'CNA_NUMERO','CNA_DTFIM', "CNA_CLIENT", "CNA_LOJACL"}})
aAdd(aCampos,{'CNBDETAIL',{'CNB_NUMERO','CNB_ITEM', 'CNB_TS','CNB_IDPED','CNB_CC','CNB_PRODSV'}})
aAdd(aCampos,{'CXIDETAIL',{'CXI_TIPO','CXI_CODCLI','CXI_LOJACL','CXI_NOMCLI','CXI_FILRES','CXI_DESFIL','CXI_PERRAT'}})
CNTA300BlMd(oModel:GetModel("CXIDETAIL"),.F.,.F.)
MtBCMod(oModel,aCampos,{||.T.},'2')

oModel:GetModel("CNCDETAIL"):SetNoInsertLine(.F.)
oModel:GetModel("CNCDETAIL"):SetNoUpdateLine(.F.)
oModel:GetModel("CNADETAIL"):SetNoUpdateLine(.F.)

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} TecBModFld

@description Modifica as propriedades dos campos do CNTA300 durante a revisão
@author	Mateus Boiani
@since	01/07/2019
/*/
//------------------------------------------------------------------------------
Function TecBModFld(oStruCNB,oStruCNC,oStruCN9, oStruCNA)

	Local oModel	 := FwModelActive()
	Local oModelCN9	 := Nil
	Local aAreaTFJ   := {}
	Local aAreaCN1   := {}
	Local cRecorren  := ""
	Local cMedAuto   := ""

	Default oStruCNA := nil
	// CNB
	oStruCNB:SetProperty('CNB_IDPED', 	MVC_VIEW_CANCHANGE,.T.)
	oStruCNB:SetProperty('CNB_CC', 		MVC_VIEW_CANCHANGE,.T.)
	oStruCNB:SetProperty('CNB_TS', 		MVC_VIEW_CANCHANGE,.T.)
	oStruCNB:SetProperty('CNB_PRODSV',  MVC_VIEW_CANCHANGE,.T.)
	oStruCNB:SetProperty("CNB_CLVL", 	MVC_VIEW_CANCHANGE,.T.)
	oStruCNB:SetProperty("CNB_ITEMCT",  MVC_VIEW_CANCHANGE,.T.)
	// CNC
	oStruCNC:SetProperty('*', 			MVC_VIEW_CANCHANGE,.T.)
	// CN9
	oStruCN9:SetProperty("CN9_TPCTO",	MVC_VIEW_CANCHANGE,.F.)
	oStruCN9:SetProperty("CN9_NUMERO",	MVC_VIEW_CANCHANGE,.F.)
	oStruCN9:SetProperty("CN9_DTINIC",	MVC_VIEW_CANCHANGE,.F.)
	oStruCN9:SetProperty("CN9_UNVIGE",	MVC_VIEW_CANCHANGE,.F.)
	oStruCN9:SetProperty("CN9_VIGE",	MVC_VIEW_CANCHANGE,.F.)
	oStruCN9:SetProperty("CN9_CONDPG",	MVC_VIEW_CANCHANGE,.F.)
	oStruCN9:SetProperty("CN9_INDICE",	MVC_VIEW_CANCHANGE,.T.)
	oStruCN9:SetProperty("CN9_FLGREJ",	MVC_VIEW_CANCHANGE,.T.)	
	oStruCN9:SetProperty("CN9_FLGCAU",	MVC_VIEW_CANCHANGE,.F.)
	oStruCN9:SetProperty("CN9_PROXRJ",	MVC_VIEW_CANCHANGE,.T.)
	oStruCN9:SetProperty("CN9_DTASSI",	MVC_VIEW_CANCHANGE,.T.)
	oStruCN9:SetProperty("CN9_ASSINA",	MVC_VIEW_CANCHANGE,.T.)

	If oStruCN9:HasField("CN9_TIPREV")
		oStruCN9:SetProperty("CN9_TIPREV",	MVC_VIEW_CANCHANGE,.F.)
	EndIf
	If VALTYPE(oModel) == 'O'  
		oModelCN9 := oModel:GetModel("CN9MASTER")
		If !IsInCallStack("AT870VICTR")
			dbSelectArea("TFJ")
			aAreaTFJ := TFJ->(GetArea())
			TFJ->(dbSetOrder(5))
			If TFJ->(DbSeek(XFilial("TFJ")+ oModelCN9:GetValue("CN9_NUMERO")+oModelCN9:GetValue("CN9_REVATU")))
				cRecorren := TFJ->TFJ_CNTREC
			EndIf
			RestArea(aAreaTFJ)
			
			dbSelectArea("CN1")
			aAreaCN1 := CN1->(GetArea())
			CN1->(dbSetOrder(1))
			If CN1->(DbSeek(XFilial("CN1")+ oModelCN9:GetValue("CN9_TPCTO")+oModelCN9:GetValue("CN9_ESPCTR")))
				cMedAuto := CN1->CN1_MEDAUT
			EndIf	
			RestArea(aAreaCN1)
		EndIf	
	EndIf
	If IsInCallStack("TECA870") .AND. VALTYPE(oStruCNA) == 'O'
		oStruCNA:SetProperty("CNA_CLIENT", MVC_VIEW_CANCHANGE,.T.)
		oStruCNA:SetProperty("CNA_LOJACL", MVC_VIEW_CANCHANGE,.T.)
		If cRecorren == "1" .AND. cMedAuto $ "1|2" 
			oStruCNA:SetProperty("CNA_PROMED", MVC_VIEW_CANCHANGE,.T.)
		EndIf
	ElseIf  IsInCallStack("TECA850") .AND. VALTYPE(oStruCNA) == 'O' .AND. cRecorren == "1" .AND. cMedAuto $ "1|2" 
		oStruCNA:SetProperty("CNA_PROMED", MVC_VIEW_CANCHANGE,.T.)
	EndIf
	
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} GSItEmpFil

@description Chamada ao cadastro de-para do EAI encapsulado para o SG
@author	fabiana.silva
@since 05/08/2019
@param	cCodEmp - Codigo da Empresa
@param cCodFil - Codigo da Filial
@param cMarca - Nome da Marca (Ex. RM)
@param lShowMsg - Exibe o Help da Mensagem
@param cMsg - Mensagem de Erro retornada
@return aEmps - Vetor contendo codigo da empresa e filial
/*/
//------------------------------------------------------------------------------
Function GSItEmpFil(cCodEmp, cCodFil, cMarca, lEnvia, lShowMsg, cMsg)
Local aEmps := {}

Default cCodEmp := cEmpAnt
Default cCodFil := cFilAnt
Default cMarca := IIF(SuperGetMV("MV_GSXINT",,"2") == "3", "RM", "")
Default lEnvia := .T.
Default lShowMsg := .T.
Default cMsg := ""

If !Empty(cMarca)
	aEmps := FWEAIEMPFIL( cCodEmp, cCodFil, cMarca, lEnvia)
	
	If Len(aEmps) = 0
		cMsg := STR0016 + cCodEmp+"/" +cCodFil + STR0017+ cMarca //"Não localizado o cadastro de-para da Empresa/Filial " ## "para a marca " 
	EndIf
Else
	cMsg := STR0018 //"Informar a Marca para qual sera realizada a conversão da Empresa/Filial"
	
EndIf

If lShowMsg .AND. !Empty(cMsg)
	Help(,, "GSItEmpFil",, cMsg,1, 0)
EndIf
Return aEmps


//------------------------------------------------------------------------------
/*/{Protheus.doc} GSItVeb

@description Chamada ao cadastro de-para do EAI encapsulado para o SG Verbas
@author	fabiana.silva
@since 05/08/2019
@param	cCodEmp - Codigo da Empresa
@param cCodFil - Codigo da Filial
@param cMarca - Nome da Marca (Ex. RM)
@param cCodEve - Codigo da Verba
@param lShowMsg - Exibe o Help da Mensagem
@param cMsg - Mensagem de Erro retornada
@return aEmps - Vetor contendo codigo da empresa e filial
/*/
//------------------------------------------------------------------------------
Function GSItVeb(cCodEmp, cCodFil, cMarca, cCodEve, lShowMsg, cMsg)
Local aArea := {}
Local aAreaSRV := {}
Local cValInt := ""
Local cValExt := ""

Default cCodEmp := cEmpAnt
Default cCodFil := cFilAnt
Default cMarca := IIF(SuperGetMV("MV_GSXINT",,"2") == "3", "RM", "")
Default cCodEve := ""
Default lShowMsg := .T.
Default cMsg := ""

If !Empty(cMarca) 
	aArea := GetArea()
	aAreaSRV := SRV->(GetArea())
	SRV := SRV->(DbSetOrder(1)) //RV_FILIAL + RV_COD
	If !Empty(cCodEve) .AND. SRV->(DbSeek(xFilial("SRV")+PadR(cCodEve, TamSX3("RV_COD")[1])))
		cValInt := GPEI040Snd( { cEmpAnt, xFilial("SRV"), SRV->RV_COD } )
		cValExt := CFGA070Ext( "RM", "SRV", "RV_COD", cValInt) 
		If Empty(cValExt)
			cMsg := STR0019 + cCodEve + STR0020 + cValInt + STR0021+ cMarca //"Não localizado o cadastro de-para do cadastro da Verba  " ## " da chave Interna " ## "para a marca "
		Else
			cValExt := Substr(cValExt, RAT("|", cValExt)+1)
		EndIf
	Else
		cMsg := STR0022 //"Codigo da Verba em branco ou não localizada"
	EndIf
	
	RestArea(aAreaSRV)
	
	RestArea(aArea)
Else
	cMsg := STR0023 //"Informar a Marca para qual sera realizada a conversão da Verba"
EndIf

If lShowMsg .AND. !Empty(cMsg)
	Help(,, "GSItVeb",, cMsg,1, 0)
EndIf
Return cValExt

//------------------------------------------------------------------------------
/*/{Protheus.doc} GSItCC

@description Chamada ao cadastro de-para do EAI encapsulado para o GS Centro de Custo
@author	fabiana.silva
@since 05/08/2019
@param	cCodEmp - Codigo da Empresa
@param cCodFil - Codigo da Filial
@param cMarca - Nome da Marca (Ex. RM)
@param cCodCC - Codigo do Centro de Custo
@param lShowMsg - Exibe o Help da Mensagem
@param cMsg - Mensagem de Erro retornada
@return aEmps - Vetor contendo codigo da empresa e filial
/*/
//---------------------------------------------------------------------------
Function GSItCC(cCodEmp, cCodFil, cMarca, cCodCC, lShowMsg, cMsg)
Local aRetCC := {}
Local cValExt := ""

Default cCodEmp := cEmpAnt
Default cCodFil := cFilAnt
Default cMarca := IIF(SuperGetMV("MV_GSXINT",,"2") == "3", "RM", "")
Default cCodCC := ""
Default lShowMsg := .T.
Default cMsg := ""

If !Empty(cMarca) 
//Busca codigo do centro de custo RM no de\para do EAI
	If !Empty(cCodCC)
         aRetCC := IntCusExt(, , cCodCC, )
         If aRetCC[1]
         	cValExt := CFGA070Ext(cMarca, "CTT", "CTT_CUSTO", aRetCC[2])
         	If Empty(cValExt)
         		cMsg := STR0024 + cCodCC + STR0020 +aRetCC[2] + STR0021+ cMarca //"Não localizado o cadastro de-para do cadastro do Centro de Custo  " ## " da chave Interna " ## "para a marca "  
         	Else
         		cValExt := Substr(cValExt, RAT("|", cValExt)+1)
         	EndIf
         Else
         	cMsg := aRetCC[02] //Mensagem de Erro da Rotina
         EndIf
         
     Else
		cMsg := STR0025 //"Codigo do Centro de Custo em Branco"
	EndIf

Else
	cMsg := STR0026 //"Informar a Marca para qual sera realizada a conversão do Centro de Custo"
	
EndIf

If lShowMsg .AND. !Empty(cMsg)
	Help(,, "GSItCC",, cMsg,1, 0)
EndIf
Return cValExt

//-----------------GSItRMWS------------------------------------------------------------
/*/{Protheus.doc} GSItEmpFil

@description Realiza o instanciamento do WebService RM
@author	fabiana.silva
@since 05/08/2019
@param cMarca - Nome da Marca (Ex. RM)
@param lShowMsg - Exibe o Help da Mensagem
@param cMsg - Mensagem de Erro retornada
@return oWS  -Objeto WebService
/*/
//------------------------------------------------------------------------------
Function GSItRMWS(cMarca, lShowMsg,cMsg, cFilMarca, cEmpMarca) //Intancia o objeto WebService, passando os dados de autenticação
Local oWS := NIL
Local cURL:= ""
Local cUser := ""
Local cPsWrd := ""
Local aEmpFil := {}

Default cMarca := IIF(SuperGetMV("MV_GSXINT",,"2") == "3", "RM", "")
Default lShowMsg := .T.
Default cMsg := ""
Default cFilMarca := ""
Default cEmpMarca := ""
If cMarca == "RM" 

	aEmpFil := GSItEmpFil(, ,  cMarca, .T., lShowMsg, @cMsg)

	If Len(aEmpFil) >= 2
		cURL := SuperGetMV("MV_GSURLIN", .F., "" ) 
		cUser := SuperGetMV("MV_GSUSRIN", .F., "" ) 
		cPsWrd := SuperGetMV("MV_GSPWDIN", .F., "" ) 
		
		cFilMarca := aEmpFil[02]
		cEmpMarca := aEmpFil[01]
		
		oWS := WSwsDataServer():New()
		If Right(cURL, 1) <> "/"
			cUrl += "/"
		EndIf
		oWS:_URL := cURL +"wsDataServer/IwsDataServer"
	
		oWS:_HEADOUT  :=  {"Authorization: Basic "+Encode64(cUser+":"+cPsWrd) }
		oWS:cContexto := "CODSISTEMA=P;CODCOLIGADA=" +AllTrim(aEmpFil[01])+";CODUSUARIO="+cUser
	EndIf
EndIf
Return oWS

//-----------------------------------------------------------------------------
/*/{Protheus.doc} TECItGSEn

@description Tratamento para posto encerrado
@author	fabiana.silva
@since 05/08/2019
@param cContra - Codigo do Contrato
@param cRevisa - Codigo da Revisão
@param cPlan - Codigo da Planilha
@param cItCNB - Codigo do item da CNB
@param lAuto - Indica se a chamada é automatica
@param cProdCTT - Codigo do produto

@return lEncerrado  -Indica se o posto está encerrado
/*/
//------------------------------------------------------------------------------
Function TECItGSEn(cContra, cRevisa, cPlan, cItCNB, lAuto,  cProdCTT, oModelCNE)

Local lEncerrado := .F.
Local cAlias 	:= ""
Local aCTT 		:= {}
Local lTabPRC 	:= .F.
Local aProduto 	:= {}
Local cProduto 	:= ""
Local aArea 	:= {}
Local lAchouIt 	:= .F.
Local lPostoEnce := SuperGetMV("MV_GSPOSTO",.f.,.f.)

Default cContra := ""
Default cRevisa := ""
Default cPlan := ""
Default cItCNB := ""
Default lAuto := IsInCallStack("CN260Exc") 
Default lPostoEnce := .F.
Default cProdCTT := ""


//Primeiramente verifica se o contrato é de GS

If !Empty(cContra) .AND. !Empty(cPlan) .AND. !Empty(cItCNB) .AND. !Empty(cProdCTT) .AND. lAuto .AND. lPostoEnce 
	aArea := GetArea()
	aCtt := GetAdvFVal("TFJ", {"TFJ_CODIGO", "TFJ_GRPRH", "TFJ_CODTAB"}, xFilial("TFJ")+cContra+cRevisa,5, {"", "", ""})
	
	If Len(aCtt) >= 3 .AND. !Empty(aCtt[01]) .AND. Empty(aCtt[02])  ////É Contrato do GS Desagrupado?
		aProduto := GetAdvFVal("SB5", {"B5_TPISERV", "B5_GSMI", "B5_GSMC", "B5_GSLE"}, xFilial("SB5")+cProdCTT,1, {"", "", "", ""})
	 	lTabPRC := !Empty(aCtt[03])
	 	If Len(aProduto) >= 4
	 		If aProduto[01] == "4"	
	 			cProduto := "RH"
	 		EndIf
	 		If aProduto[02] == "1"
	 			cProduto += "/MI"
	 		EndIf
		 	If aProduto[03] == "1"
	 			cProduto += "/MC"
	 		EndIf	
		 	If aProduto[04] == "1"
	 			cProduto += "/LE"
	 		EndIf
	 	EndIf
	 	
	 	cAlias := GetNextAlias()
	 	
	 	If "RH" $ cProduto		
		//Primeiramente localiza Item de RH
			//Achou é está encerrado
			//achou não esta ecerrado acabou
			BeginSql Alias cAlias
				SELECT TFF.TFF_ENCE AS ENCERRADO
				
				From %table:TFF% TFF
				INNER JOIN  %table:TFL% TFL	
				ON (TFL.TFL_CODIGO = TFF.TFF_CODPAI  AND	
					TFL.%notDel% AND  
					TFL.TFL_PLAN  = %exp:cPlan% AND
					TFL.TFL_CONREV =  %exp:cRevisa% AND
					TFL.TFL_CONTRT = %exp:cContra% AND 
					TFL.TFL_FILIAL  = %xfilial:TFL%  )
				INNER JOIN %table:TFJ% TFJ
					ON ( 					
				TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND
				TFJ.TFJ_STATUS = '1' AND
					TFJ.%notDel% AND
					TFJ.TFJ_FILIAL  = %xfilial:TFJ%   )
				WHERE 
					(TFF.TFF_ITCNB =  %exp:cItCNB% AND					
				TFF.%notDel% AND  
				TFF.TFF_CONTRT = %exp:cContra% AND 
				TFF.TFF_CONREV =  %exp:cRevisa% AND		
					TFF.TFF_FILIAL = %xfilial:TFF% ) 	
			EndSql
			lAchouIt := !(cAlias)->(Eof())
		EndIf
		
		If !lAchouIt .AND. "LE" $ cProduto
			//LOCALIZA LE
			If Select(cAlias) > 0
				(cAlias)->(DbCloseArea())
			EndIf
			BeginSql Alias cAlias
				SELECT TFI.TFI_ENCE AS ENCERRADO
				From %table:TFI% TFI
				INNER JOIN 	%table:TFL% TFL	 ON
				( 	TFL.TFL_CODIGO  = TFI.TFI_CODPAI AND
					TFL.%notDel% AND  
					TFL.TFL_PLAN  = %exp:cPlan% AND
					TFL.TFL_CONREV =  %exp:cRevisa% AND
					TFL.TFL_CONTRT = %exp:cContra% AND 
					TFL.TFL_FILIAL  = %xfilial:TFL%   )
				 INNER JOIN %table:TFJ% TFJ ON
					 (	TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND
				TFJ.TFJ_STATUS = '1' AND
					    TFJ.%notDel% AND 									    
					    TFJ.TFJ_FILIAL  = %xfilial:TFJ%  )					
				WHERE 
				(TFI.TFI_ITCNB =  %exp:cItCNB% AND
				TFI.%notDel% AND  
				TFI.TFI_CONREV =  %exp:cRevisa% AND		
				TFI.TFI_CONTRT = %exp:cContra% AND 	
				TFI.TFI_FILIAL = %xfilial:TFI% )   
			EndSql
			lAchouIt := !(cAlias)->(Eof())
		EndIf
		If !lAchouIt .AND. !lTabPRC .AND.  "MC" $ cProduto
			//LOCALIZA Mi/MC
			If Select(cAlias) > 0
				(cAlias)->(DbCloseArea())
			EndIf
			// Verifica se é Mi/MC  -  abaixo de rh
			BeginSql Alias cAlias
				SELECT TFF.TFF_ENCE AS ENCERRADO
				From 
				%table:TFH% TFH
				INNER JOIN %table:TFF% TFF ON
					( TFF.TFF_COD = TFH.TFH_CODPAI AND 	
				TFF.%notDel% AND  
				TFF.TFF_CONREV =  %exp:cRevisa% AND		
					TFF.TFF_CONTRT = %exp:cContra% AND 
					TFF.TFF_FILIAL = %xfilial:TFF% )				
				INNER JOIN %table:TFL% TFL ON
				(	TFL.TFL_CODIGO = TFF.TFF_CODPAI  AND
				TFL.%notDel% AND  
					TFL.TFL_PLAN  = %exp:cPlan% AND
				TFL.TFL_CONREV =  %exp:cRevisa% AND
					TFL.TFL_CONTRT = %exp:cContra% AND 
					TFL.TFL_FILIAL  = %xfilial:TFL%  )	
				INNER JOIN %table:TFJ% TFJ ON
				( TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND
					TFJ.TFJ_STATUS = '1' AND 
					TFJ.%notDel% AND 				
					TFJ.TFJ_FILIAL  = %xfilial:TFJ% )
				WHERE 
				(TFH.TFH_ITCNB =  %exp:cItCNB% AND
				TFH.%notDel% AND  
				TFH.TFH_CONREV =  %exp:cRevisa% AND	
				TFH.TFH_CONTRT = %exp:cContra% AND 
				TFH.TFH_FILIAL = %xfilial:TFH% ) 
			EndSql	
			lAchouIt := !(cAlias)->(Eof())			
		EndIf	
		If !lAchouIt .AND. !lTabPRC .AND.  "MI" $ cProduto
			If Select(cAlias) > 0
				(cAlias)->(DbCloseArea())
			EndIf
			BeginSql Alias cAlias
				SELECT TFF.TFF_ENCE AS ENCERRADO
				From 
				%table:TFG% TFG
				INNER JOIN %table:TFF% TFF ON
					( TFF.TFF_COD = TFG.TFG_CODPAI AND 	
				TFF.%notDel% AND  
				TFF.TFF_CONREV =  %exp:cRevisa% AND		
					TFF.TFF_CONTRT = %exp:cContra% AND 
					TFF.TFF_FILIAL = %xfilial:TFF% )				
				INNER JOIN %table:TFL% TFL ON
				(	TFL.TFL_CODIGO = TFF.TFF_CODPAI  AND
				TFL.%notDel% AND  
					TFL.TFL_PLAN  = %exp:cPlan% AND
				TFL.TFL_CONREV =  %exp:cRevisa% AND
					TFL.TFL_CONTRT = %exp:cContra% AND 
					TFL.TFL_FILIAL  = %xfilial:TFL%  )	
				INNER JOIN %table:TFJ% TFJ ON
				( TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND
					TFJ.TFJ_STATUS = '1' AND 
					TFJ.%notDel% AND 				
					TFJ.TFJ_FILIAL  = %xfilial:TFJ% )
				WHERE 
				(TFG.TFG_ITCNB =  %exp:cItCNB% AND
				TFG.%notDel% AND  
				TFG.TFG_CONREV =  %exp:cRevisa% AND	
				TFG.TFG_CONTRT = %exp:cContra% AND 
				TFG.TFG_FILIAL = %xfilial:TFG%  )
			EndSql	
			lAchouIt := !(cAlias)->(Eof())	
		EndIf		
		If lAchouIt
			lEncerrado := (cAlias)->ENCERRADO == "1"
		EndIf
		If Select(cAlias) > 0
			(cAlias)->(DbCloseArea())
		EndIf
	EndIf
	RestArea(aArea)
EndIf

If lEncerrado .AND. VALTYPE(oModelCNE) == 'O'
	oModelCNE:SetValue('CNE_QUANT', 0)
EndIf

Return lEncerrado

//-----------------------------------------------------------------------------
/*/{Protheus.doc} TecMdAtQry

@description Query para não apurar posto encerrado
@author	fabiana.silva
@since 05/08/2019
@param cQuery - Query

@return cQuery  -Retorna a query a ser utilizada
/*/
//------------------------------------------------------------------------------
Function TecMdAtQry(cQuery)
Local lPostoEnce := SuperGetMV("MV_GSPOSTO",.F.,.F.)
Local cTmp := ""
Local cWhere := ""
Local nPos := 0
Local cEnd := ""

If lPostoEnce 

	//Adição de filtro para não apurar local encerrado
	cWhere := " LEFT JOIN ( SELECT TFL_CONTRT, TFL_CONREV, TFL_PLAN, TFL_ENCE FROM " + RetSQLName("TFL") + " TFL, " +;
	 																			       RetSQLName("TFJ") + " TFJ "+;
	 					    " WHERE TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND TFJ.TFJ_STATUS = '1' AND TFJ.TFJ_FILIAL = '"+ xFilial("TFJ") + "' "+ ;
	 					     " AND TFL.D_E_L_E_T_ <> '*'  AND TFL.TFL_FILIAL = '"+ xFilial("TFL") + "' AND TFL.D_E_L_E_T_ <> '*' ) "+;
	           " TFL ON (  TFL_CONTRT = CNF_CONTRA AND TFL_CONREV = CNF_REVISA  AND TFL_PLAN = CNA_NUMERO  )  "
	
	//Localiza a ultima clausula da query
	nPos := RAt(" WHERE ", cQuery)
	
	cEnd := Substr(cQuery, nPos)
	//Adiciona o left join o filtro de local encerrado
	cEnd :=  cWhere + cEnd +  " AND (TFL_ENCE IS NULL OR TFL_ENCE  <> '1' ) "	
	
	cTmp := Left(cQuery, nPos-1)
	
	//Debug
	cTmp := cTmp + cEnd
	cQuery := cTmp

EndIf


Return cQuery

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecMedPlan

@description Verifica na CNA se há medições. Verificando se o Saldo é diferente
do valor total
@author	Augusto Albuquerque
@since	28/10/2019
/*/
//------------------------------------------------------------------------------
Function TecMedPlan( cContra, cRevisa, cLocal ) 
Local cAliasCNA	:= GetNextAlias()
Local lRet		:= .T.

BeginSql Alias cAliasCNA
	SELECT CNA.CNA_VLTOT, CNA.CNA_SALDO
	FROM %table:CNA% CNA
	INNER JOIN %Table:TFL% TFL
		ON TFL.TFL_FILIAL = %xFilial:TFL%
		AND TFL.TFL_CONTRT = CNA.CNA_CONTRA
		AND TFL.TFL_CONREV = CNA.CNA_REVISA
		AND TFL.TFL_LOCAL = %exp:cLocal%
	WHERE CNA.CNA_FILIAL = %xFilial:CNA%
		AND CNA.CNA_CONTRA = %exp:cContra%
		AND CNA.CNA_REVISA = %exp:cRevisa%
		AND CNA.CNA_NUMERO = TFL.TFL_PLAN
		AND CNA.%NotDel%
		AND TFL.%NotDel%
EndSql

If (cAliasCNA)->(!Eof()) .AND. (cAliasCNA)->CNA_VLTOT == (cAliasCNA)->CNA_SALDO
	lRet := .F.
EndIf

(cAliasCNA)->(DbCloseArea())
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecPreCNB

@description Faz as pre validações da CNB na efetivação
@author	Augusto Albuquerque
@since	31/10/2019
/*/
//------------------------------------------------------------------------------
Function TecPreCNB( cAction, oModel, oModelGrid )
Local cGsDsGcn	:= SuperGetMv("MV_GSDSGCN",,"2")
Local lRet		:= .T.
Local lOrcPrc	:= SuperGetMv("MV_ORCPRC",,.F.)

If (!lOrcPrc .AND. cGsDsGcn == "1") .AND. !IsInCallStack("At870ItDsAgr") 
	If cAction == "UNDELETE"
		lRet := .F.
		Help( "", 1, "TecPreCNB", , STR0027, 1, 0,,,,,,{STR0028}) // "Não é possivel realizar essa operação na efetivação." ## "Por favor, faça uma revisão."
	ElseIf cAction == "DELETE"
		lRet := .F.
		Help( "", 1, "TecPreCNB", , STR0029, 1, 0,,,,,,{STR0028}) // "Não é possivel excluir item na efetivação." ## "Por favor, faça uma revisão."
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecPreCNA

@description Faz as pre validações da CNA na efetivação
@author	Augusto Albuquerque
@since	31/10/2019
/*/
//------------------------------------------------------------------------------
Function TecPreCNA ( cAction, oModel, oModelGrid )
Local cGsDsGcn	:= SuperGetMv("MV_GSDSGCN",,"2")
Local lRet		:= .T.
Local lOrcPrc	:= SuperGetMv("MV_ORCPRC",,.F.)
Local lAllowDel := TecDelPln()
If (!lOrcPrc .AND. cGsDsGcn == "1" ) .AND. !IsInCallStack("At870ItDsAgr") 
	If cAction == "UNDELETE"
		lRet := .F.
		Help( "", 1, "TecPreCNA", , STR0027, 1, 0,,,,,,{STR0028}) // "Não é possivel realizar essa operação na efetivação." ## "Por favor, faça uma revisão."
	ElseIf cAction == "DELETE" .AND. !lAllowDel
		lRet := .F.
		Help( "", 1, "TecPreCNA", , STR0029, 1, 0,,,,,,{STR0028}) // "Não é possivel excluir item na efetivação." ## "Por favor, faça uma revisão."
	EndIf
EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} TecNumToHr

@description Converte um número em hora (STRING) no formato 99:99 
@author	Mateus Boiani
@since	26/11/2019
/*/
//------------------------------------------------------------------------------
Function TecNumToHr(nHora)
Local cRet := ""
Local cAux

If VALTYPE(nHora) == 'N'
	cAux := cValToChar(nHora)

	If AT(".",cAux) == 3
		cRet += LEFT(cAux,2) + ":"
	ElseIf AT(".",cAux) == 2 .OR. (AT(".",cAux) == 0 .AND. nHora < 10)
		cRet += "0" + LEFT(cAux,1) + ":"
	Else
		cRet += LEFT(cAux,2) + ":"
	EndIf

	If "." $ cAux
		If "." $ RIGHT(cAux,2)
			If SUBSTR(cAux,3,1) == "." .OR. LEN(cAux) == 3
				cRet += RIGHT(cAux,1) + "0"
			Else
				cRet += "0" + RIGHT(cAux,1)
			EndIf
		Else
			cRet += RIGHT(cAux,2)
		EndIf
	Else
		cRet += "00"
	EndIf
EndIF
Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecCheckIn()
Função para realizar a batida através do ClockIn

@param cCracha - Caracter - codigo do cracha do funcionario
@param cFilial - Caracter - codigo da filial do funcionario
@param dData - Data - Data da batida
@param nHoras - Numerico - Hora da batida

@author 	Luiz Gabriel
@since		04/12/2019
@version 	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecCheckIn(cCracha,cRAFilial,dData,nHora,cTurno,cMat, cTipo, cSeq, dDataApo)
Local cSeekTDV
Local aAreaSRA 	:= {}
Local aArea 	:= GetArea()
Local lTECA910	:= isInCallStack("TECA910") .OR. isInCallStack("At910MaJob") 
Local lMtFil 	:= TecMultFil()
Local cDataApo
Local cExpr		:= ""
Local lProcessa := .F.

//parametros para inclusão de log
Local lMV_GSLOG   := SuperGetMV('MV_GSLOG',,.F.)
Local oGsLog	  := GsLog():New(lMV_GSLOG)

Default cCracha := ""
Default cRAFilial := ""
Default cMat := ""
Default cTurno := ""
Default cTipo := ""
Default cSeq := ""
Default dDataApo := CTOD("")

If lMV_GSLOG .AND. !lTECA910
	oGsLog:addLog("TecCheckIn", "----------------------------------------------------------------------") 
	oGsLog:addLog("TecCheckIn", STR0097) //"Inicio Processamento... "
	oGsLog:addLog("TecCheckIn", "------------------") 
	oGsLog:addLog("TecCheckIn", STR0075 ) //"parametros recebidos"
	oGsLog:addLog("TecCheckIn", "------------------") 
	oGsLog:addLog("TecCheckIn", STR0076 + cCracha ) //"Cracha - cCracha "
	oGsLog:addLog("TecCheckIn", STR0077 + cRAFilial ) //"Filial SRA - cRAFilial "
	oGsLog:addLog("TecCheckIn", STR0078 + dToC(dData) ) //"Data da Batida - dData "
	oGsLog:addLog("TecCheckIn", STR0079 + cValtoChar(nHora) ) //"Hora da Batida - nHora "
	oGsLog:addLog("TecCheckIn", STR0080 + cTurno ) //"Turno - cTurno "
	oGsLog:addLog("TecCheckIn", STR0081 + cMat ) //"Matricula - cMat "
	oGsLog:addLog("TecCheckIn", STR0082 + cTipo ) //"Tipo da Batida - cTipo "
	oGsLog:addLog("TecCheckIn", STR0083 + cSeq ) //"Sequencia - cSeq "
	oGsLog:addLog("TecCheckIn", STR0084 + dToC(dDataApo) ) //"Data Apontamento - dDataApo "
	oGsLog:addLog("TecCheckIn", "------------------") 
EndIf 

If !lTECA910 .AND. !Empty(cRAFilial)
	aAreaSRA	:= SRA->(GetArea())
	
	If !Empty(cCracha)
		DbSelectArea("SRA")
		SRA->(DbSetOrder(9))
		If SRA->(MsSeek(cCracha+cRAFilial))
			cMat := SRA->RA_MAT
		EndIf
	EndIf
	
	DbSelectArea("AA1")
	AA1->(DbSetOrder(7))  // AA1_FILIAL + AA1_CDFUNC + AA1_FUNFIL
	lProcessa := AA1->(MsSeek(xFilial("AA1")+cMat+cRAFilial)) .AND. AA1->AA1_MPONTO == '1'
	
	If lProcessa
		If lMV_GSLOG
			oGsLog:addLog("TecCheckIn", "------------------") 
			oGsLog:addLog("TecCheckIn", STR0085 + cMat) //"Matricula recuperada"
			oGsLog:addLog("TecCheckIn", "------------------") 
		EndIf 

		If !EMPTY(cMat) .AND. !Empty(cTurno) .AND. !Empty(cTipo) .AND. !Empty(cSeq) .AND. !Empty(dDataApo)
			If lMtFil
				cExpr := FWJoinFilial("AA1" , "TDV" , "AA1", "TDV", .T.)
			Else
				cExpr := "TDV.TDV_FILIAL = '" + xFilial("TDV") + "'"
			EndIf
			cExpr += " AND ABB.ABB_ATIVO = '1' AND (ABB.ABB_CHEGOU <> 'S' OR ABB.ABB_SAIU <> 'S') AND ABB.ABB_ATENDE = '2'"
			cExpr := "%"+cExpr+"%"
			cDataApo := DTOS(dDataApo)
			cSeekTDV := GetNextAlias()
			BeginSQL Alias cSeekTDV
				SELECT TDV.TDV_CODABB,ABB.ABB_FILIAL
				FROM %Table:TDV% TDV
				INNER JOIN %Table:ABB% ABB ON 
					ABB.ABB_FILIAL = TDV.TDV_FILIAL AND
					ABB.ABB_CODIGO = TDV.TDV_CODABB AND 
					ABB.%NotDel%
				INNER JOIN %Table:AA1% AA1 ON
					AA1.AA1_CODTEC = ABB.ABB_CODTEC AND
					AA1.AA1_CDFUNC = %Exp:cMat% AND
					AA1.AA1_FUNFIL = %Exp:cRAFilial% AND
					AA1.AA1_FILIAL = %Exp:xFilial("AA1")% AND
					AA1.%NotDel%
				WHERE
					TDV.TDV_DTREF = %Exp:cDataApo% AND
					TDV.TDV_TURNO = %Exp:cTurno% AND
					TDV.TDV_SEQTRN = %Exp:cSeq% AND
					TDV.%NotDel% AND
					%exp:cExpr%
				ORDER BY 
					ABB_DTINI, 
					ABB_HRINI, 
					ABB_DTFIM, 
					ABB_HRFIM
			EndSql

			If lMV_GSLOG
				oGsLog:addLog("TecCheckIn", "------------------") 
				oGsLog:addLog("TecCheckIn", STR0090 ) //"Buscando Registro na TDV..."
				oGsLog:addLog("TecCheckIn", GetLastQuery()[2] )
				oGsLog:addLog("TecCheckIn", "------------------") 
			EndIf

			If !(cSeekTDV)->(Eof())

				If lMV_GSLOG
					oGsLog:addLog("TecCheckIn", "------------------") 
					oGsLog:addLog("TecCheckIn", STR0091 ) //"Processando Registro TDV.... "
					oGsLog:addLog("TecCheckIn", STR0094 + LEFT(cTipo,1) )
					oGsLog:addLog("TecCheckIn", STR0087 + (cSeekTDV)->TDV_CODABB ) //"Código da ABB "
					oGsLog:addLog("TecCheckIn", "------------------") 
				EndIf
				
					
				If lMV_GSLOG
					oGsLog:addLog("TecCheckIn", "------------------") 
					oGsLog:addLog("TecCheckIn", STR0092 + (cSeekTDV)->ABB_FILIAL ) //"Filial da ABB "
					oGsLog:addLog("TecCheckIn", STR0087 + (cSeekTDV)->TDV_CODABB ) //"Código da ABB "
					oGsLog:addLog("TecCheckIn", STR0088 + RIGHT(cTipo,1) ) //"Tipo da batida "
					oGsLog:addLog("TecCheckIn", "------------------") 
				EndIf

				TecAtuABB((cSeekTDV)->TDV_CODABB,IIF(RIGHT(cTipo,1) == 'E','1','2'),TxValToHor(nHora),dData,(cSeekTDV)->ABB_FILIAL,lMtFil,@oGsLog,lMV_GSLOG)
			EndIf
			(cSeekTDV)->(DbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaSRA)
EndIf

If lMV_GSLOG .AND. !lTECA910
	oGsLog:addLog("TecCheckIn", STR0096) //"Fim Processamento... "
	oGsLog:addLog("TecCheckIn", "----------------------------------------------------------------------")
	oGsLog:addLog("TecCheckIn", " ")
	oGsLog:addLog("TecCheckIn", " ")
	If lProcessa
		oGsLog:printLog("TecCheckIn")
	EndIf
EndIf

RestArea(aArea)
Return
	

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecAtuABB()
Função para atualizar as batidas da agenda do atendente
	
@param cCodigoABB - Caracter - codigo da agenda do atendente
@param cInOut - Caracter - codigo para informar se a batida é de entrada ou saida
@param cHora - Caracter - horario que será realizado a batida
@param dData - Data - Data para a batida
@param cFilABB - Caracter - Filial da ABB
@param lMtFil - Logico - Indica se utiliza Multi-Filial
@param oGsLog - Objeto - Objeto para inclusão de Log
@param lMV_GSLOG - Logico - Indica se a inclusão de log está ativa

@author 	Luiz Gabriel
@since		04/12/2019
@version 	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecAtuABB(cCodigoABB,cInOut,cHora,dData,cFilABB,lMtFil,oGsLog,lMV_GSLOG)
Local aArea			:= GetArea()
Local lRet 			:= .T.
Local lClockIN		:= 	TxExistCLO()
Local lDtInOut		:= ABB->(ColumnPos('ABB_DTCHIN')) > 0 .And. ABB->(ColumnPos('ABB_DTCHOU')) > 0
Local cFilialABB 	:= ""

dbSelectArea('ABB')

If !lMtFil
	cFilialABB := xFilial("ABB")
Else
	cFilialABB := cFilABB
EndIf

If lMV_GSLOG
	oGsLog:addLog("TecCheckIn", "------------------") 
	oGsLog:addLog("TecCheckIn", STR0098) //"Iniciando Processamento TecAtuABB.."
	oGsLog:addLog("TecCheckIn", "------------------") 
	oGsLog:addLog("TecCheckIn", STR0099 ) //"parametros recebidos TecAtuABB... "
	oGsLog:addLog("TecCheckIn", "------------------") 
	oGsLog:addLog("TecCheckIn", STR0100 + cCodigoABB ) //"Codigo da ABB - cCodigoABB "
	oGsLog:addLog("TecCheckIn", STR0101 + cInOut ) //"Tipo da Batida - cInOut "
	oGsLog:addLog("TecCheckIn", STR0102 + dToC(dData) ) //"Data da Batida - dData "
	oGsLog:addLog("TecCheckIn", STR0103 + cValtoChar(cHora) ) //"Hora da Batida - cHora "
	oGsLog:addLog("TecCheckIn", STR0104 + cFilABB ) //"Filial da ABB - cFilABB "
	oGsLog:addLog("TecCheckIn", STR0105 + cValtoChar(lMtFil) ) //"Multifilial - lMtFil "
	oGsLog:addLog("TecCheckIn", "------------------") 
EndIf 

If !Empty(cCodigoABB)
	dbSelectArea("ABB")
	ABB->(dbSetOrder(8))
	If ABB->(DbSeek(cFilialABB + cCodigoABB))
		If lMV_GSLOG
			oGsLog:addLog("TecCheckIn", "------------------") 
			oGsLog:addLog("TecCheckIn", STR0106 ) //""Registro da ABB encontrado..."
			oGsLog:addLog("TecCheckIn", "------------------") 
		EndIf

		RecLock("ABB",.F.)
					
		If cInOut == '1'
			If lMV_GSLOG
				oGsLog:addLog("TecCheckIn", "------------------") 
				oGsLog:addLog("TecCheckIn", STR0107 ) //"Atualizando registros de entrada.."
				oGsLog:addLog("TecCheckIn", "------------------") 
			EndIf
			ABB->ABB_CHEGOU := 'S'
			If lClockIN
				ABB->ABB_CLOIN := '1'
			EndIf
			If lDtInOut
				ABB->ABB_DTCHIN := dData
			EndIf
			ABB->ABB_HRCHIN := cHora			
			ABB->(MsUnlock())
					
		ElseIf cInOut == '2'
			If lMV_GSLOG
				oGsLog:addLog("TecCheckIn", "------------------") 
				oGsLog:addLog("TecCheckIn", STR0108 ) //"Atualizando registros de saida.."
				oGsLog:addLog("TecCheckIn", "------------------") 
			EndIf
			ABB->ABB_SAIU := 'S'
			ABB->ABB_ATENDE := '1'
			If lClockIN
				ABB->ABB_CLOOUT := '1'
			EndIf
			If lDtInOut
				ABB->ABB_DTCHOU := dData
			EndIf
			ABB->ABB_HRCOUT := cHora		
			ABB->(MsUnlock())	
		EndIf   
	Else
		If lMV_GSLOG
			oGsLog:addLog("TecCheckIn", "------------------") 
			oGsLog:addLog("TecCheckIn", STR0109 ) //"Registro da ABB não encontrado..."
			oGsLog:addLog("TecCheckIn", "------------------") 
		EndIf
		lRet := .F.	
	EndIf
Else
	lRet := .F.			
EndIf

If lMV_GSLOG
	oGsLog:addLog("TecCheckIn", "------------------") 
	oGsLog:addLog("TecCheckIn", STR0110) //"Finalizando Processamento TecAtuABB.."
	oGsLog:addLog("TecCheckIn", "------------------") 
EndIf

RestArea(aArea)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TxExistCLO()
Função para verificar se ps campos utilizados na integração estão criados no dicionario
	
@author 	Luiz Gabriel
@since		04/12/2019
@version 	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TxExistCLO()
Local lClockIN	:= 	.F.

DbSelectArea("ABB")
If  ABB->(ColumnPos('ABB_CLOIN')) > 0 .And. ABB->(ColumnPos('ABB_CLOOUT')) > 0
	lClockIN := .T.
EndIf

Return lClockIN	


//------------------------------------------------------------------------------
/*/{Protheus.doc} TecGrd2CSV

@description Função para Exportar o arquivo .CSV

@param cNomeArq 	- Nome do Arquivo
@param cId			- Id do Model
@param cIdView		- Id da view para verificar quais campos serão exportados
@param aNoCpos		- Array com os campos que serão ignorados na view na exportação
@param aIncCpo		- Array com os campos, ID da View e ID do model que serão incluidos na exportação
@param aLegenda		- Array com a regra de legenda caso a grid possua
@param aNoCpoU		- Array com os campos que serão ignorados na view na exportação do submodelo
@param aIncCpoS		- Array com os campos, ID da View e ID do model que serão incluidos na exportação do submodelo
@param aLegendaS	- Array com a regra de legenda caso a grid possua, para o submodelo

@author	diego.bezerra
@since	12/12/2019
/*/
//------------------------------------------------------------------------------
Function TecGrd2CSV(cNomeArq,cId,cIdView,aNoCpos,aIncCpo,aLegenda, cMdlID, cFldVld, cIdSub, cIdVwS, aNoCpoU, aIncCpoS, aLegendaS)
Local oMdAll	:= FwModelActive()
Local oView		:= FwViewActive()
Local oMdlId	:= Nil
Local lRet 		:= .F.
Local cPasta	:= ""
Local cNomArq	:= "" //Pega por referencia nome que foi gravado o arquivo
Local aCpoView	:= {} //Campos da view do model primário
Local aCpoVwS	:= {} //Campos da view do model secundário
Local oMdlSub	:= Nil

Default aNoCpos 	:= {} //Array com os campos a serem ignorados
Default aIncCpo		:= {} //Array com os campos e valores a serem adicionados
Default aLegenda 	:= {} //Array com as legendas
Default aLegendaS	:= {} //Array com as legendas do model secundário
Default cFldVld		:= ""

//Verifica se o Modelo a ser exportado está valido
If ValType(oMdAll) == "O" .AND. oMdAll:IsActive() .And. oMdAll:GetId() == cMdlID
	
	oMdlId	:= oMdAll:GetModel(cId)
	If ValType(oMdlId) == "O" .And. !oMdlId:IsEmpty()

		//Seleciona a pasta para gravação do arquivo .csv
		cPasta := TecSelPast()

		If !Empty(cPasta)
			If !Empty(cIdSub)
				oMdlSub := oMdAll:GetModel(cIdSub)
				aCpoVwS := oView:GetViewStruct(cIdVwS):aFields
			EndIf

			//Retorna os campos da View para a grid a ser exportada
			aCpoView := oView:GetViewStruct(cIdView):aFields

			//Imprime o .CSV
			FwMsgRun(Nil,{|| lRet := procCSV(cPasta,cNomeArq,oMdAll,oMdlId,oView,aNoCpos,aIncCpo,aCpoView,aLegenda, @cNomArq, cMdlID, cFldVld,oMdlSub, aNoCpoU, aIncCpoS, aCpoVwS, aLegendaS)}, Nil,  "Aguarde....") 
			
			//Sucesso na Impressão
			If lRet
				MsgAlert("Arquivo criado com sucesso na pasta! " + CRLF + cPasta + cNomArq) 
			EndIf
			
		EndIf
	EndIf
EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} procCSV

@description Função onde é feito a adição dos campos e valores a serem exportados

@param cPasta - Pasta onde o arquivo será salvo
@param cArquivo	- Prefixo final para o nome do arquivo
@param oMdAll	- Modelo da dados Geral
@param oMdlId	- Modelo de dados a ser exportado
@param oView	- View a ser exportada
@param aNoCpos	- Array com os campos a serem ignorados na exportação
@param aIncCpo	- Array com os campos a serem incluidos na exportação
@param aCpoView	- Array com os campos da view que serão exportados
@param aLegenda	- Array com a regra de legendas
@param cNomeArq - Prefixo inicial para o nome do arquivo
@param cMdlID	- Id do modelo a ser exportado
@param oMdlSub	- Sub-modelo a ser exportado
@param aNoCpos	- Array com os campos a serem ignorados na exportação para o sub-modelo
@param aIncCpo	- Array com os campos a serem incluidos na exportação para o sub-modelo
@param aCpoView	- Array com os campos da view que serão exportados para o sub-modelo
@param aLegenda	- Array com a regra de legendas do sub-modelo

@author	diego.bezerra
@since	12/12/2019
/*/
//------------------------------------------------------------------------------
Static Function procCSV(cPasta,cArquivo,oMdAll,oMdlId,oView,aNoCpos,aIncCpo,aCpoView,aLegenda, cNomArq, cMdlID, cFldVld, oMdlSub, aNoCpoU, aIncCpoS, aCpoVwS, aLegendaS)

Local lRet 		:= .F.
Local aCampos	:= {}
Local cCab		:= ""
Local cItens	:= ""
Local cCsv		:= ""
Local nHandle	:= 0
Local cCabSub	:= ""
Local aCamposS	:= {}

Default oMdlSub	:= Nil	//Model secundário
Default aNoCpoU	:= {}	//Campos ignorados do model secundário
Default aCpoVwS	:= {}	//Campos da view, do model secundário
Default aLegendaS := {}	//Legendas do model secundario

Default cFldVld	:= ""

cNomArq	:= DtoS(dDataBase) + '_' + StrTran(Time(), ':', '') + '_' + cArquivo

//Verifica quais campos serão impressos
aCampos	:= TecRtCpo(aNoCpos,aIncCpo,aCpoView,oView)
// Valida se a chamada possui model secundário para exportar
If Valtype(oMdlSub) == 'O'
	aCamposS := TecRtCpo(aNoCpoU,aIncCpo,aCpoVwS,oView)
	cCabSub	 := TecImpCab(aCamposS) 
EndIf
//Imprime o cabeçalho do CSV
cCab := TecImpCab(aCampos) // cabeçalho principal
//Imprime os itens do CSV
cItens	:= ImpIt(oMdAll,oMdlId,aCampos,aLegenda,cMdlID, cFldVld, cCabSub, oMdlSub,aLegendaS, aCamposS,cCab)
//Realiza a união do cabeçalho com os Itens
cCsv := cItens
//Cria o arquivo .CSV na pasta selecionada
nHandle := fCreate(cPasta+""+cNomArq+".CSV")

If nHandle > 0
	FWrite(nHandle, cCsv)
	FClose(nHandle)
	lRet := .T.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecRtCpo

@description Função onde é feito a adição dos campos a serem exportados

@param aNoCpos	- Array com os campos a serem ignorados na exportação
@param aIncCpo	- Array com os campos a serem incluidos na exportação
@param aCpoView	- Array com os campos da view que serão exportados
@param aLegenda	- Array com a regra de legenda
@param oView	- View a ser exportada

@author	diego.bezerra
@since	12/12/2019
/*/
//------------------------------------------------------------------------------
Static Function TecRtCpo(aNoCpos,aIncCpo,aCpoView,oView)
Local aCampos	:= {}
Local lCopy		:= .T.
Local nX		:= 0
Local nY		:= 0
Local lNoCpo	:= Len(aNoCpos) > 0  //Verifica se existem campos a serem retirados
Local lIncCpo	:= Len(aIncCpo) > 0  //Verifica se existem campos a serem incluidos
Local aCpoVw	:= {}				 //Array com os campos exibidos na view

//Verifica se tem campos a adicionar no array
If lIncCpo
	For nX	:= 1 To Len(aIncCpo)
		aCpoVw := oView:GetViewStruct(aIncCpo[nX,1]):aFields
		For nY := 1 to Len(aIncCpo[nX,3])
			nPos := aScan( aCpoVw,{ |a| a[ MVC_VIEW_IDFIELD ] == aIncCpo[nX,3,nY] })
			Aadd(aCampos,{aCpoVw[ nPos, MVC_VIEW_IDFIELD ],aCpoVw[ nPos, MVC_VIEW_TITULO ],aCpoVw[ nPos, 6 ],aIncCpo[nX,2]})
		Next nY
		//Limpa a Variavel
		aCpoVw := {}
	Next nX
EndIf

For nX	:= 1 To Len(aCpoView)
	If lNoCpo
		lCopy := aScan( aNoCpos, aCpoView[ nx, MVC_VIEW_IDFIELD ] ) == 0
	EndIf
	If lCopy
		Aadd(aCampos,{aCpoView[ nx, MVC_VIEW_IDFIELD ],aCpoView[ nx, MVC_VIEW_TITULO ],aCpoView[ nx, 6 ]})
	EndIf
Next nX

Return aCampos

//------------------------------------------------------------------------------
/*/{Protheus.doc} ImpIt

@description Função para imprimir os itens do .CSV

@param oMdAll	- Modelo da dados Geral
@param oMdlId	- Modelo de dados a ser exportada
@param aCampos	- Array com os campos a serem exportados
@param aLegenda - Array com a rega de legenda para exportação
@param cFldVld  - Campo utilizado como parâmetro para percorrer o modelo
@author	diego.bezerra
@since	12/12/2019
/*/
//------------------------------------------------------------------------------
Static Function ImpIt(oMdlAll,oMdlId,aCampos,aLegenda, cMdlID, cFldVld, cCabSub, oMdlSub,aLegendaS, aCamposS,cCab)
Local cRet		:= ""
Local nY		:= 0
Local nLen		:= oMdlId:Length()
Local nPosBkp	:= oMdlId:GetLine()
Local nLegen	:= 0
Local nLenSub	:= 0
Local lMdlSub 	:= !Empty(cCabSub) .AND. ValType(oMdlSub) == 'O'
Local nK		:= 0

Default cMdlID		:= ""
Default aLegenda	:= {}
Default aLegendS	:= {}
Default aCamposS	:= {}
Default cFldVld		:= ""
Default cCabSub		:= ""

nLegen := Len(aLegenda)
nLegenS := Len(aLegendaS)

If !lMdlSub
	cRet := cRet + cCab 
ENDIF

For nY := 1 To nLen
	oMdlId:GoLine(nY)
	
	If !Empty(cFldVld)
		If Empty(TecGVal(oMdlId:GetID(), cFldVld))
			Loop
		EndIf
	EndIf
	
	If oMdlId:IsDeleted()
		Loop
	EndIf

	If lMdlSub
		cRet := cRet + cCab 
	EndIf
		
	getVlCsv(@cRet, aCampos, oMdlId, oMdlAll, aLegenda, nLegen)
	
	If lMdlSub
		cRet := cRet + CRLF
	ENDIF

	If lMdlSub
		cRet := cRet + CRLF
		cRet := cRet + cCabSub
		nLenSub	:= oMdlSub:Length()
		For nK	:= 1 To nLenSub
			oMdlSub:GoLine(nK)
			getVlCsv(@cRet, aCamposS, oMdlSub, oMdlAll, aLegendaS, nLegenS)
			cRet := cRet + CRLF
		Next nK	
		cRet := cRet + CRLF
	EndIf

	If !lMdlSub
		cRet := cRet + CRLF
	EndIf
Next nY

//Volta para a linha atual
oMdlId:GoLine(nPosBkp)

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} getVlCsv

@description responsavel por gerar uma linha em formato csv

@param cRet		- String passada por referência, utilizada para retornar o conteúdo da linha
@param aCampos	- Array com os campos do modelo de dados
@param oMdlId	- Modelo de dados que será exportado
@param oMdlAll 	- Modelo de dados principal da rotina
@param aLegenda - Array com as caracteristicas das legendas

@author	diego.bezerra
@since	28/05/2020
/*/
//------------------------------------------------------------------------------
Static Function getVlCsv(cRet, aCampos, oMdlId, oMdlAll, aLegenda, nLegen)

Local nPosLeg 	:= 0
Local nPos		:= 0
Local nX		:= 0

For nX	:= 1 To Len(aCampos)
	If Len(aCampos[nX]) < 4			
		If aCampos[ nx, 3] == "D"
			cRet += DtoC(oMdlId:GetValue(aCampos[ nx, 1])) +";"
		ElseIf aCampos[ nx, 3] == "BT"
			If nLegen > 0
				nPosLeg := aScan(aLegenda, { |a| a[1] == aCampos[ nx, 1] })
				If nPosLeg > 0
					nPos := aScan(aLegenda[nPosleg][2], {|b| b[1] == oMdlId:GetValue(aCampos[ nx, 1]) })
					If nPos > 0
						cRet += aLegenda[nPosLeg][2][nPos][2] +";"
					Else
						cRet += oMdlId:GetValue(aCampos[ nx, 1]) +";"
					EndIf
				Else
					cRet += oMdlId:GetValue(aCampos[ nx, 1]) +";"
				EndIf
			Else
				cRet += oMdlId:GetValue(aCampos[ nx, 1]) +";"
			EndIf
		ElseIf aCampos[ nx, 3] == "N"
			cRet += cValToChar(oMdlId:GetValue(aCampos[ nx, 1])) +";"
		ElseIf aCampos[ nx, 3] != "CHECK"
			cRet += oMdlId:GetValue(aCampos[ nx, 1]) +";"
		EndIf
	Else
		If aCampos[ nx, 3] == "D"
			cRet += DtoC(oMdlAll:GetModel(aCampos[nx,4]):GetValue(aCampos[ nx, 1])) +";"
		ElseIf aCampos[ nx, 3] == "BT"
			If nLegen > 0
				npos := aScan( aLegenda,{ |a| a[1] == oMdlAll:GetModel(aCampos[nx,4]):GetValue(aCampos[ nx, 1]) })
				If nPos > 0
					cRet += aLegenda[nPos][2] + ";"
				Else
					cRet += oMdlId:GetValue(aCampos[nx, 1]) + ";"
				EndIf
			Else
				cRet += oMdlAll:GetModel(aCampos[nx,4]):GetValue(aCampos[ nx, 1]) +";"
			EndIf
		ElseIf aCampos[ nx, 3] == "N"
			cRet += cValToChar(oMdlId:GetValue(aCampos[ nx, 1])) +";"
		Else
			cRet += oMdlAll:GetModel(aCampos[nX,4]):GetValue(aCampos[ nx, 1]) +";"
		EndIf
	EndIf
Next nX

return .T.
//------------------------------------------------------------------------------
/*/{Protheus.doc} TecImpCab

@description Função para imprimir o cabeçalho do arquivo .CSV
@param aCampos - Campos que serão exportados para o CSV

@author	diego.bezerra
@since	12/12/2019
/*/
//------------------------------------------------------------------------------
Function TecImpCab(aCampos)
Local cRet		:= ""
Local nX		:= 0

For nX	:= 1 To Len(aCampos)
	cRet += aCampos[ nx, 2 ] +";"
Next nX

//Pula linha
cRet := cRet + CRLF

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecGVal

@description Executa um GetValue caso o FwFldGet não consiga retornar o valor do campo

@author	boiani
@since	06/07/2019
/*/
//------------------------------------------------------------------------------
Function TecGVal(cForm, cField)

Local xValue := FwFldGet(cField)
Local oModel := FwModelActive()
Local oSubModel

If EMPTY(xValue) .AND. VALTYPE(oModel) == "O"
	oSubModel := oModel:GetModel(cForm)
	If VALTYPE(oSubModel) == "O"
		xValue := oSubModel:GetValue(cField)
	EndIf
EndIf

Return xValue

//------------------------------------------------------------------------------
/*/{Protheus.doc} dateToStr

@description Recebe data no formato Data e retorna string em format dd/mm/yyyy
@param dDate, Data
@return cDate, string, data em formato dd/mm/yyyy
@author	diego.bezerra
@since	13/12/2019
/*/
//------------------------------------------------------------------------------
Function TecDToStr(dDate)

Local cDate := ""

Default dDate := ""
If ValType(dDate)=='D'
	cDate := iif(Len(cValToChar(DAY(dDate)))== 1,'0'+cValToChar(DAY(dDate)),cValToChar(DAY(dDate))) 
	cDate += '/' + iif(Len(cValToChar(MONTH(dDate)))== 1,'0'+cValToChar(MONTH(dDate)),cValToChar(MONTH(dDate))) 
	cDate += '/' + cValToChar(YEAR(dDate))
Else
	cDate := ' / / '
EndIf

Retur cDate

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecSelPast
Abre Tela para seleção do local de gravação do Arquivo CSV

@author		Luiz Gabriel
@since		03/07/2019
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Function TecSelPast()
Local cPathDest		:= ""
Local cExtension	:= '*.CSV'
Local lContinua		:= .T.

cPathDest  := Alltrim(cGetFile(STR0030 + cExtension + '|' + cExtension +'|' , STR0031, 1, '', .T., GETF_LOCALHARD+GETF_RETDIRECTORY,.F.))	//"Arquivo"	# "Selecione a pasta para gravação"
If Empty(cPathDest)
	cPathDest := ""
Else
	lContinua := ChkPerGrv(cPathDest)
	If !lContinua
		Aviso(STR0032, STR0033, {STR0034}, 2)	//"Atenção"	# "Você não possuí permissão de gravação para pasta selecionada. Tente Selecionar outra pasta. # "Ok"
		cPathDest := ""
	EndIf
EndIf

Return cPathDest

//------------------------------------------------------------------------------
/*/{Protheus.doc} ChkPerGrv
Checa permissao de gravacao na pasta indicada para geracao
do CSV

@author		Luiz Gabriel
@since		03/07/2019
@version	P12.1.23
/*/
//------------------------------------------------------------------------------
Static Function ChkPerGrv(cPath)
Local cFileTmp := CriaTrab(NIL, .F.)
Local nHdlTmp  := 0
Local lRet     := .F.

cPath   := AllTrim(cPath)
nHdlTmp := MSFCreate(cPath + If(Right(cPath, 1) <> '\', '\', '') + cFileTmp + '.TMP', 0)
If nHdlTmp <= 0
	lRet := .F.
Else
	lRet := .T.
	FClose(nHdlTmp)
	FErase(cPath + If(Right(cPath, 1) <> '\', '\', '') + cFileTmp + '.TMP')
EndIf

Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecChngCNA

@description Trava as linhas na efetivação do contrato.
@author	Augusto Albuquerque
@since	29/01/2020
/*/
//------------------------------------------------------------------------------
Function TecChngCNA( oModel )
If AT870GetTr()
	oModel:GetModel("CNADETAIL"):SetNoDeleteLine(.T.)
	oModel:GetModel("CNADETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("CNADETAIL"):SetNoUpdateLine(.F.)
	oModel:GetModel("CNBDETAIL"):SetNoDeleteLine(.T.)
	oModel:GetModel("CNBDETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("CNCDETAIL"):SetNoDeleteLine(.T.)
	If IsInCallStack( "AT870APRRV" )
		oModel:GetModel("CNCDETAIL"):SetNoInsertLine(.T.)
	Else
		oModel:GetModel("CNCDETAIL"):SetNoInsertLine(.F.)
	EndIf
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecImpIt

@description Função para transformar csv em array
@author	Augusto Albuquerque
@since	07/02/2020
/*/
//------------------------------------------------------------------------------
Function TecImpIt( aDados, aCampos )
Local cRet := ""
Local nX
Local nY

For nX := 1 To Len( aDados ) 
	For nY := 1 To Len( aDados[nX] )
		If ValType(aDados[nX][nY]) == "D"
			cRet += DToC( aDados[nX][nY] ) + ";"
		ElseIF ValType(aDados[nX][nY]) == "N"
			cRet += cValToChar( aDados[nX][nY] ) + ";"
		ElseIf ValType(aDados[nX][nY]) == "C"
			cRet += aDados[nX][nY] + ";"
		Else
			Loop
		EndIf
	Next nY
	cRet := cRet + CRLF
Next nX

Return cRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} TecDelPln

@description Função de get/set para a variavel Static TecDelPln, que indica se
	o sistema permite ou não e exclusão de CNBs
@author	Mateus Boiani
@since	11/03/2020
/*/
//------------------------------------------------------------------------------
Function TecDelPln(lSetValue)
If Valtype(lSetValue) == 'L'
	lTecDelPln := lSetValue
EndIf
Return lTecDelPln

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TecAltX1
Atualiza a SX1 
Função utilizada na automação
@author Diego Bezerra
@param cPerg, string, nome do pergunte
@param cMvPar, string, parâmetro do pergunte que será alterado
@param xValue, qualquer, novo valor para o parâmetro do pergunte
@param cError, string, contém mensagem de erro da execução (passar valor via referência)
@since 30/03/2020
@return lRet, lógico, .T. = Sucesso - .F. = Falha
/*/
//-------------------------------------------------------------------------------------
Function TecAltX1(cPerg, cMvPar, xValue, cError)

Local lRet		 := .F.
Local cOrdem 	 := ""

Default cPerg 	 := ""
Default cMvPar	 := ""
Default xValue	 := ""
Default cError	 := ""

If !Empty(cPerg)
	If TecHasPerg(cMvPar,cPerg)
		lRet := .T.
		SX1->(DBSetOrder(1))
		SX1->(DBGoTop())
		SX1->(DBSeek(cPerg))

		While ALLTRIM(SX1->X1_GRUPO) == cPerg
			If ALLTRIM(SX1->X1_VAR01) == cMvPar
				cPerg := SX1->X1_GRUPO
				cOrdem := SX1->X1_ORDEM
				Exit
			EndIf
			SX1->(DbSkip())
		End

		If !Empty(cOrdem)
			If SX1->(DBSeek(cPerg + cOrdem))
				If ALLTRIM(SX1->X1_TIPO) == 'D'
					If ValType(xValue) == 'D' .AND. !Empty(xValue)
						xValue := TecDToStr(xValue)
					Else
						xValue := ""
						If !Empty(xValue)
							cError  := STR0035 //#"Tipo de dado inválido. Em parâmetros do tipo data, informe uma string no formato dd/mm/yyyy"
						Else
							cError  := STR0036 //#"O valor do parâmetro não foi informado."
						EndIf
					EndIf
				EndIf

				If ALLTRIM(SX1->X1_TIPO) == 'N'
					If ValType(xValue) == 'N'
						xValue := cValToChar(xValue)
					Else
						xValue := ""
						lRet := .F.
					EndIf
				EndIf

				RecLock("SX1", .F.)
					SX1->X1_CNT01 := xValue
				SX1->(MsUnLock())
			EndIf
		Else
			lRet := .F.
			cError := STR0037 //#"Valor inválido em SX1->X1_ORDEM"
		EndIf
	Else 
		lRet := .F.
		If !Empty(cMvPar) .AND. ValType(cMvPar) == "C"
			cErro := STR0038 + cMvPar +  STR0039 //#"Parâmetro "# " não encontrado." 
		Else
			cError := STR0040 //#"Parâmetro não informado."
		EndIf
	EndIf
Else
	lRet := .F.
	cError := STR0041 //#"Pergunte não informado."
EndIf
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecABBPRHR
@description Função que verifica se existe os campos TFF_QTDHRS e TFF_HRSSAL no dicionario.
@author Augusto Albuquerque
@since  03/04/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecABBPRHR()

Return TFF->( ColumnPos('TFF_QTDHRS') ) > 0 .AND. TFF->( ColumnPos('TFF_HRSSAL') ) > 0
//------------------------------------------------------------------------------
/*/{Protheus.doc} TecXMxTGYI()

Retorna o último item da TGY_ITEM de acordo com o CODTDX e ESCALA

@author boiani
@since 24/07/2019
/*/
//------------------------------------------------------------------------------
Function TecXMxTGYI(cEscala, cCodTDX, cCodTFF)
Local cRet := REPLICATE("0",TamSX3("TGY_ITEM")[1])
Local aArea := GetArea()
Local cQry := GetNextAlias()

BeginSQL Alias cQry
	SELECT MAX(TGY.TGY_ITEM) TGY_ITEM
	FROM %Table:TGY% TGY
	WHERE TGY.TGY_FILIAL = %xFilial:TGY%
		AND TGY.%NotDel%
		AND TGY.TGY_ESCALA = %Exp:cEscala%
		AND TGY.TGY_CODTDX = %Exp:cCodTDX%
		AND TGY.TGY_CODTFF = %Exp:cCodTFF%
EndSql
If (cQry)->(!EOF())
	cRet := (cQry)->(TGY_ITEM)
EndIf
(cQry)->(DbCloseArea())

RestArea(aArea)
Return Soma1(cRet)
//------------------------------------------------------------------------------
/*/{Protheus.doc} TecXMxTGZI()

Retorna o último item da TGY_ITEM de acordo com o CODTDX e ESCALA

@author boiani
@since 24/07/2019
/*/
//------------------------------------------------------------------------------
Function TecXMxTGZI(cEscala, cCodTDX, cCodTFF)
Local cRet := REPLICATE("0",TamSX3("TGZ_ITEM")[1])
Local aArea := GetArea()
Local cQry := GetNextAlias()

BeginSQL Alias cQry
	SELECT MAX(TGZ.TGZ_ITEM) TGZ_ITEM
	FROM %Table:TGZ% TGZ
	WHERE TGZ.TGZ_FILIAL = %xFilial:TGZ%
		AND TGZ.%NotDel%
		AND TGZ.TGZ_ESCALA = %Exp:cEscala%
		AND TGZ.TGZ_CODTDX = %Exp:cCodTDX%
		AND TGZ.TGZ_CODTFF = %Exp:cCodTFF%
EndSql
If (cQry)->(!EOF())
	cRet := (cQry)->(TGZ_ITEM)
EndIf
(cQry)->(DbCloseArea())

RestArea(aArea)
Return Soma1(cRet)
//------------------------------------------------------------------------------
/*/{Protheus.doc} TecXHasEdH()

Indica se o Editor de Horários está habilitado

@author boiani
@since 17/04/2020
/*/
//------------------------------------------------------------------------------
Function TecXHasEdH()

Return (SuperGetMV("MV_GSGEHOR",,.F.) .AND. (TGY->( ColumnPos('TGY_ENTRA1')) > 0 ))

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecCotrCli
@description Função que verifica a CNA na revisão e geração do contrato.
@author Augusto Albuquerque
@since  27/04/2020
/*/
//------------------------------------------------------------------------------
Function TecCotrCli(cLoja, cClient, oModel, cCampo, nLine)
Local lRet := .T.
Default cCampo := ""
Default nLine := 0

If Empty(cLoja)
	nLine := MTFindMVC(oModel:GetModel("CNCDETAIL"),{{"CNC_CLIENT",cClient}})
ElseIf cCampo == "CNA_LOJACL"
    nLine := MTFindMVC(oModel:GetModel("CNCDETAIL"),{{"CNC_CLIENT",cClient},{"CNC_LOJACL",cLoja}})
EndIf

lRet := nLine > 0

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECAAHReco
@description Função que verifica a criação do campo e da tabela no dicionario
para realizar o processo de recorrencia do FieldService
@author Augusto Albuquerque
@since  27/04/2020
/*/
//------------------------------------------------------------------------------
Function TECAAHReco()
Return AAH->( ColumnPos('AAH_NUMREC')) > 0 .AND. TableInDic("TXJ")


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecMultRat
@description Se esta com multifilial e os compartilhamento das tabelas correto para o requisito
@author Augusto Albuquerque
@since  11/06/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecMultRat()
Local cComAA1 := FwModeAccess("AA1",1) +  FwModeAccess("AA1",2) + FwModeAccess("AA1",3)
Local cComSRA := FwModeAccess("SRA",1) +  FwModeAccess("SRA",2) + FwModeAccess("SRA",3)
Local cComABS := FwModeAccess("ABS",1) +  FwModeAccess("ABS",2) + FwModeAccess("ABS",3)

Return SuperGetMV("MV_GSMSFIL",,.F.) .AND. (LEN(STRTRAN( cComAA1  , "E" )) > LEN(STRTRAN(  cComSRA  , "E" ))) .AND. LEN(STRTRAN(  cComABS  , "E" )) > 0
//------------------------------------------------------------------------------
/*/{Protheus.doc} TecVlPrPar
@description Verifica se a funcinalidade de Valor Provisório está ativa
@author Mateus Boiani
@since  11/06/2020
/*/
//------------------------------------------------------------------------------
Function TecVlPrPar()
Local lRet := TFH->(ColumnPos('TFH_VLPRPA')) > 0 .AND. TFG->(ColumnPos('TFG_VLPRPA')) > 0 .AND.;
					TFF->(ColumnPos('TFF_VLPRPA')) > 0 .AND. TFL->(ColumnPos('TFL_VLPRPA')) > 0
Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} TecxbPrRec
@description Função executada ao alterar o status do contrato para "Vigente"
no GCT, no momento em que os PRs são gerados para CTR recorrentes

@return O retorno será um numérico que modificará o valor do título PR

@author Mateus Boiani
@since  17/06/2020
/*/
//------------------------------------------------------------------------------
Function TecxbPrRec(nValor, nParcela, aParcelas, nRECCNA)
Local nRet := nValor
Local aArea := GetArea()
Local cSql := ""
Local cAliasAux := ""
Local cSpaceTFL := SPACE(TamSx3("TFL_CODSUB")[1])
Local aCrCobr := {}
Local nAux := 0
Local cCompet := STRZERO(MONTH(aParcelas[nParcela][2]),2) + "/" + cValToChar(YEAR(aParcelas[nParcela][2]))
Local nX

If TecBHasCrn()
	aCrCobr := TecBCrrTGT(nRECCNA, cCompet)
EndIf

If !EMPTY(aCrCobr) .AND. (nAux := ASCAN(aCrCobr, {|a| a[1] == cCompet})) > 0
	nRet := 0
	For nX := 1 To LEN(aCrCobr[nAux][2])
		nRet += aCrCobr[nAux][2][nX][1]
	Next nX
ElseIf TecVlPrPar() .AND. nParcela == 1
	cAliasAux := GetNextAlias()
	cSql := " SELECT TFL.TFL_VLPRPA FROM " + RetSqlName("TFL") + " TFL "
	cSql += " INNER JOIN " + RetSqlName("CNA") + " CNA ON "
	cSql += " CNA.CNA_NUMERO = TFL.TFL_PLAN AND "
	cSql += " CNA.CNA_CONTRA = TFL.TFL_CONTRT AND "
	cSql += " CNA.D_E_L_E_T_ = ' ' AND CNA.CNA_FILIAL = '" + xFilial("CNA") + "' "
	cSql += " INNER JOIN " + RetSqlName("TFJ") + " TFJ ON "
	cSql += " TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND "
	cSql += " TFJ.D_E_L_E_T_ = ' ' AND TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
	cSql += " WHERE "
	cSql += " TFL.D_E_L_E_T_ = ' ' AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
	cSql += " AND CNA.R_E_C_N_O_ = " + cValToChar(nRECCNA) + " AND "
	cSql += " TFJ.TFJ_CNTREC = '1' AND TFL.TFL_CODSUB = '" + cSpaceTFL + "' "
	cSql := ChangeQuery(cSql)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasAux, .F., .T.)

	If !(cAliasAux)->(EOF()) .AND. (cAliasAux)->TFL_VLPRPA > 0
		nRet := (cAliasAux)->TFL_VLPRPA
	EndIf
	(cAliasAux)->(dbCloseArea())
EndIf

RestArea(aArea)
Return nRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} TecMedPrRa
@description Função executada ao selecionar a competência na tela de medição (CNTA121)

@author Mateus Boiani
@since  17/06/2020
/*/
//------------------------------------------------------------------------------
Function TecMedPrRa(oMdlMed, cContra, cRevisa, cNumPla, cCodTFJ)
Local oModelCXN
Local nTFLVlPrPa := 0
Local cAliasTFL	:= GetNextAlias()
Local aAreaCNA
Local aArea
Local cCompet := ""
Local nRecCNA := 0
Local lAlterou := .F.
Local aCrCobr := {}
Local nX
Local nAux

If Posicione("TFJ",1,xFilial("TFJ")+cCodTFJ,"TFJ_CNTREC") == '1'
	If TecBHasCrn()
		aArea := GetArea()
		DbSelectArea("CNA")
		aAreaCNA := CNA->(GetArea())

		CNA->(DbSetOrder(1)) //CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO
		If CNA->(DbSeek(xFilial("CNA") + cContra + cRevisa + cNumPla))
			nRecCNA := CNA->(Recno())
							
			If isInCallStack("AT930GRV")
				cCompet :=  AT930GPAR4()
			Else				
				cCompet := oMdlMed:GetValue("CNDMASTER","CND_COMPET")
			EndIf

			aCrCobr := TecBCrrTGT(nRECCNA, cCompet)
			If !EMPTY(aCrCobr) .AND. (nAux := ASCAN(aCrCobr, {|a| a[1] == cCompet})) > 0
				For nX := 1 To LEN(aCrCobr[nAux][2])
					nTFLVlPrPa += aCrCobr[nAux][2][nX][1]
				Next nX
				If VALTYPE(oMdlMed) == 'O'
					oModelCXN := oMdlMed:GetModel('CXNDETAIL')
					oModelCXN:LoadValue("CXN_VLPREV", nTFLVlPrPa )
					oModelCXN:LoadValue("CXN_VLSALD", nTFLVlPrPa )
					lAlterou := .T.
				EndIf
			EndIf
		EndIf
		RestArea(aAreaCNA)
		RestArea(aArea)
	EndIf
	If TecVlPrPar() .AND. !lAlterou
		BeginSql Alias cAliasTFL
			SELECT TFL.TFL_VLPRPA
			FROM %table:TFL% TFL
			WHERE TFL.TFL_FILIAL = %xFilial:TFL%
				AND TFL.TFL_CONTRT = %exp:cContra%
				AND TFL.TFL_CONREV = %exp:cRevisa%
				AND TFL.TFL_PLAN = %exp:cNumPla%
				AND TFL.TFL_CODPAI = %exp:cCodTFJ%
				AND TFL.%NotDel%
		EndSql
		If !(cAliasTFL)->(EOF()) .AND. (cAliasTFL)->TFL_VLPRPA > 0
			nTFLVlPrPa := (cAliasTFL)->TFL_VLPRPA
		EndIf
		(cAliasTFL)->(DbCloseArea())
		If nTFLVlPrPa > 0 .AND. VALTYPE(oMdlMed) == 'O'
			oModelCXN := oMdlMed:GetModel('CXNDETAIL')
			oModelCXN:LoadValue("CXN_VLPREV", nTFLVlPrPa )
			oModelCXN:LoadValue("CXN_VLSALD", nTFLVlPrPa )
		EndIf
	EndIf
EndIf
Return nil
//------------------------------------------------------------------------------
/*/{Protheus.doc} TecBLoadMd
@description Função executada ao marcar a planilha na tela de medição (CNTA121)

@author Mateus Boiani
@since  17/06/2020
/*/
//------------------------------------------------------------------------------
Function TecBLoadMd(cContra, cRevisa, cPlan, cItCNB, oMdlMed, cCodTFJ, cFilCNB)
Local oModelCNE
Local cAliasTFL
Local aArea := GetArea()
Local cJoinMI := ""
Local cJoinMC := ""
Local cSql := ""
Local lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.)
Local lAgrupado := SuperGetMv("MV_GSDSGCN",,"2") == '2'
Local nValPrPa := 0
Local nValAgrup := 0
Local cWhereTFL	:= ""
Local lMI		:= .F.
Local lMC		:= .F.
Local lRH		:= .F.
Local cCNBProd 	:= ""
Local nAuxProd	:= 0
Local nAuxTFL 	:= 0
Local lAlterou := .F.
Local cCompet := ""
Local nRecCNA := 0
Local aCrCobr := {}
Local nAux
Local nAux2
Local cTpItem := ""
Local cCodItem := ""
Local nQtdVen := 0

Default cFilCNB := cFilAnt

DBSelectArea("TFJ")
TFJ->(DbSetOrder(1)) //TFJ_FILIAL+TFJ_CODIGO
If TFJ->(MsSeek(xFilial("TFJ", cFilCNB) + cCodTFJ)) .AND. TFJ->TFJ_CNTREC == "1"
	If TecBHasCrn() .AND. !lOrcPrc .AND. !lAgrupado
		nRecCNA := CNA->(Recno())
		If isInCallStack("AT930GRV")
			cCompet :=  AT930GPAR4()
		Else				
			cCompet := oMdlMed:GetValue("CNDMASTER","CND_COMPET")
		EndIf
		aCrCobr := TecBCrrTGT(nRECCNA, cCompet)
		If !EMPTY(aCrCobr) .AND. (nAux := ASCAN(aCrCobr, {|a| a[1] == cCompet})) > 0
			cSql += " SELECT TFF.TFF_COD, TFF.TFF_ITCNB, TFH.TFH_COD, TFH.TFH_ITCNB, TFG.TFG_COD, TFG.TFG_ITCNB, "
			cSql += " TFF.TFF_QTDVEN, TFH.TFH_QTDVEN, TFG.TFG_QTDVEN "
			cSql += " FROM " + RetSqlName("TFL") + " TFL INNER JOIN "
			cSql += RetSqlName("TFF") + " TFF ON TFF.TFF_CODPAI = TFL.TFL_CODIGO AND "
			cSql += " TFF.TFF_FILIAL = TFL.TFL_FILIAL AND TFF.D_E_L_E_T_ = ' ' "
			cSql += " LEFT JOIN " + RetSqlName("TFH") + " TFH ON TFH.TFH_CODPAI = TFF.TFF_COD AND "
			cSql += " TFH.TFH_FILIAL = TFF.TFF_FILIAL AND TFH.D_E_L_E_T_ = ' ' "
			cSql += " LEFT JOIN " + RetSqlName("TFG") + " TFG ON TFG.TFG_CODPAI = TFF.TFF_COD AND "
			cSql += " TFG.TFG_FILIAL = TFF.TFF_FILIAL AND TFG.D_E_L_E_T_ = ' ' "
			cSql += " WHERE "
			cSql += " TFL.D_E_L_E_T_ = ' ' AND "
			cSql += " TFL.TFL_PLAN = '" + cPlan + "' AND "
			cSql += " TFL.TFL_CONTRT = '" + cContra + "' AND "
			cSql += " TFL.TFL_CONREV = '" + cRevisa + "' AND "
			cSql += " TFL.TFL_CODPAI = '" + cCodTFJ + "' AND "
			cSql += " TFL.TFL_FILIAL = '" + xFilial("TFL", cFilCNB) + "' "
			cSql := ChangeQuery(cSql)
			cAliasTFL := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasTFL, .F., .T.)
			While !(cAliasTFL)->(EOF())
				If (cAliasTFL)->TFF_ITCNB == cItCNB
					cTpItem := "TFF"
					cCodItem := (cAliasTFL)->TFF_COD
					nQtdVen := (cAliasTFL)->TFF_QTDVEN
					Exit
				ElseIf (cAliasTFL)->TFH_ITCNB == cItCNB
					cTpItem := "TFH"
					cCodItem := (cAliasTFL)->TFH_COD
					nQtdVen := (cAliasTFL)->TFH_QTDVEN
					Exit
				ElseIf (cAliasTFL)->TFG_ITCNB == cItCNB
					cTpItem := "TFG"
					cCodItem := (cAliasTFL)->TFG_COD
					nQtdVen := (cAliasTFL)->TFG_QTDVEN
					Exit
				EndIf
				(cAliasTFL)->(DbSkip())
			End
			(cAliasTFL)->(DbCloseArea())
			If (nAux2 := ASCAN(aCrCobr[nAux][2], {|a| a[2] == cTpItem .AND. a[3] == cCodItem})) > 0
				oMdlMed:LoadValue('CNEDETAIL','CNE_VLUNIT',(aCrCobr[nAux][2][nAux2][1] / nQtdVen))
				lAlterou := .T.
			EndIf
		EndIf
		cSql := ""
	EndIf
	If VALTYPE(oMdlMed) == "O" .AND. TecVlPrPar() .AND. !lAlterou
		oModelCNE := oMdlMed:GetModel('CNEDETAIL')
		If lAgrupado
			cCNBProd := oMdlMed:GetValue('CNEDETAIL','CNE_PRODUT')
			lMI := cCNBProd == TFJ->TFJ_GRPMI
			lMC := cCNBProd == TFJ->TFJ_GRPMC
			lRH := cCNBProd == TFJ->TFJ_GRPRH

			cWhereTFL := ""
			cWhereTFL += " WHERE "
			cWhereTFL += " TFL.D_E_L_E_T_ = ' ' AND "
			cWhereTFL += " TFL.TFL_PLAN = '" + cPlan + "' AND "
			cWhereTFL += " TFL.TFL_CONTRT = '" + cContra + "' AND "
			cWhereTFL += " TFL.TFL_CONREV = '" + cRevisa + "' AND "
			cWhereTFL += " TFL.TFL_CODPAI = '" + cCodTFJ + "' AND "
			cWhereTFL += " TFL.TFL_FILIAL = '" + xFilial("TFL", cFilCNB) + "' "
			If lMI
				nAuxProd := 0
				nAuxTFL := 0
				cAliasTFL := GetNextAlias()
				cSql := ""
				cSql += " SELECT TFG.TFG_VLPRPA, TFG.TFG_QTDVEN, TFL.TFL_TOTMI "
				cSql += " FROM " + RetSqlName("TFL") + " TFL "
				If lOrcPrc
					cSql += " INNER JOIN " + RetSqlName("TFG") + " TFG ON "
					cSql += " TFG.TFG_CODPAI = TFL.TFL_CODIGO AND TFG.D_E_L_E_T_ = ' ' AND "
					cSql += " TFG.TFG_FILIAL = '" + xFilial("TFG", cFilCNB) +"' "
					cSql += " AND TFG.TFG_COBCTR = '1' "
				Else
					cSql += " INNER JOIN " + RetSqlName("TFF") + " TFF ON "
					cSql += " TFF.TFF_CODPAI = TFL.TFL_CODIGO AND "
					cSql += " TFF.TFF_FILIAL = '" + xFilial("TFF", cFilCNB) + "' AND "
					cSql += " TFF.D_E_L_E_T_ = ' ' "
					cSql += " INNER JOIN " + RetSqlName("TFG") + " TFG ON "
					cSql += " TFG.TFG_CODPAI = TFF.TFF_COD AND TFG.D_E_L_E_T_ = ' ' AND "
					cSql += " TFG.TFG_FILIAL = '" + xFilial("TFG", cFilCNB) +"' "
					cSql += " AND TFG.TFG_COBCTR = '1' "
				EndIf
				cSql += cWhereTFL
				cSql := ChangeQuery(cSql)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasTFL, .F., .T.)
				If !(cAliasTFL)->(EOF())
					nAuxTFL := (cAliasTFL)->TFL_TOTMI
					While !(cAliasTFL)->(EOF())
						If !EMPTY((cAliasTFL)->TFG_VLPRPA) .AND. (cAliasTFL)->TFG_VLPRPA > 0 .AND. (cAliasTFL)->TFG_VLPRPA <> (cAliasTFL)->TFL_TOTMI
							nValAgrup += (cAliasTFL)->TFG_VLPRPA / (cAliasTFL)->TFG_QTDVEN
						EndIf
						nAuxProd += (cAliasTFL)->TFG_VLPRPA
						(cAliasTFL)->(DbSkip())
					End
				EndIf
				If nAuxProd == nAuxTFL
					nValAgrup := 0
				EndIf
				(cAliasTFL)->(DbCloseArea())
			EndIf
			If lMC
				nAuxProd := 0
				nAuxTFL := 0
				cAliasTFL := GetNextAlias()
				cSQL := ""
				cSql += " SELECT TFH.TFH_VLPRPA, TFH.TFH_QTDVEN, TFL.TFL_TOTMC "
				cSql += " FROM " + RetSqlName("TFL") + " TFL "
				If lOrcPrc
					cSql += " INNER JOIN " + RetSqlName("TFH") + " TFH ON "
					cSql += " TFH.TFH_CODPAI = TFL.TFL_CODIGO AND TFH.D_E_L_E_T_ = ' ' AND "
					cSql += " TFH.TFH_FILIAL = '" + xFilial("TFH", cFilCNB) +"' "
					cSql += " AND TFH.TFH_COBCTR = '1' "
				Else
					cSql += " INNER JOIN " + RetSqlName("TFF") + " TFF ON "
					cSql += " TFF.TFF_CODPAI = TFL.TFL_CODIGO AND "
					cSql += " TFF.TFF_FILIAL = '" + xFilial("TFF", cFilCNB) + "' AND "
					cSql += " TFF.D_E_L_E_T_ = ' ' "
					cSql += " INNER JOIN " + RetSqlName("TFH") + " TFH ON "
					cSql += " TFH.TFH_CODPAI = TFF.TFF_COD AND TFH.D_E_L_E_T_ = ' ' AND "
					cSql += " TFH.TFH_FILIAL = '" + xFilial("TFH", cFilCNB) +"' "
					cSql += " AND TFH.TFH_COBCTR = '1' "
				EndIf
				cSql += cWhereTFL
				cSql := ChangeQuery(cSql)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasTFL, .F., .T.)
				If !(cAliasTFL)->(EOF())
					nAuxTFL := (cAliasTFL)->TFL_TOTMC
					While !(cAliasTFL)->(EOF())
						If !EMPTY((cAliasTFL)->TFH_VLPRPA) .AND. (cAliasTFL)->TFH_VLPRPA > 0 .AND. (cAliasTFL)->TFH_VLPRPA <> (cAliasTFL)->TFL_TOTMC
							nValAgrup += (cAliasTFL)->TFH_VLPRPA / (cAliasTFL)->TFH_QTDVEN
						EndIf
						nAuxProd += (cAliasTFL)->TFH_VLPRPA
						(cAliasTFL)->(DbSkip())
					End
				EndIf
				If nAuxProd == nAuxTFL
					nValAgrup := 0
				EndIf
				(cAliasTFL)->(DbCloseArea())
			EndIf
			If lRH
				nAuxProd := 0
				nAuxTFL := 0
				cAliasTFL := GetNextAlias()
				cSQL := ""
				cSql += " SELECT TFF.TFF_VLPRPA, TFF.TFF_QTDVEN, TFL.TFL_TOTRH "
				cSql += " FROM " + RetSqlName("TFL") + " TFL "
				cSql += " INNER JOIN " + RetSqlName("TFF") + " TFF ON "
				cSql += " TFF.TFF_CODPAI = TFL.TFL_CODIGO AND "
				cSql += " TFF.TFF_FILIAL = '" + xFilial("TFF", cFilCNB) + "' AND "
				cSql += " TFF.D_E_L_E_T_ = ' ' "
				cSql += " AND TFF.TFF_COBCTR = '1' "
				cSql += cWhereTFL
				cSql := ChangeQuery(cSql)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasTFL, .F., .T.)
				If !(cAliasTFL)->(EOF())
					nAuxTFL := (cAliasTFL)->TFL_TOTRH
					While !(cAliasTFL)->(EOF())
						If !EMPTY((cAliasTFL)->TFF_VLPRPA) .AND. (cAliasTFL)->TFF_VLPRPA > 0 .AND. (cAliasTFL)->TFF_VLPRPA <> (cAliasTFL)->TFL_TOTRH
							nValAgrup += (cAliasTFL)->TFF_VLPRPA / (cAliasTFL)->TFF_QTDVEN
						EndIf
						nAuxProd += (cAliasTFL)->TFF_VLPRPA
						(cAliasTFL)->(DbSkip())
					End
				EndIf
				If nAuxProd == nAuxTFL
					nValAgrup := 0
				EndIf
				(cAliasTFL)->(DbCloseArea())
			EndIf
			If nValAgrup > 0
				oMdlMed:LoadValue('CNEDETAIL','CNE_VLUNIT',nValAgrup)
			EndIF
		Else
			cAliasTFL := GetNextAlias()
			If lOrcPrc //Material x local
				cJoinMI := " LEFT JOIN " + RetSqlName("TFG") + " TFG ON "
				cJoinMI += " TFG.TFG_CODPAI = TFL.TFL_CODIGO AND TFG.D_E_L_E_T_ = ' ' AND "
				cJoinMI += " TFG.TFG_ITCNB = '" + cItCNB + "' AND "
				cJoinMI += " TFG.TFG_FILIAL = '" + xFilial("TFG", cFilCNB) +"' "

				cJoinMC := " LEFT JOIN " + RetSqlName("TFH") + " TFH ON "
				cJoinMC += " TFH.TFH_CODPAI = TFL.TFL_CODIGO AND TFH.D_E_L_E_T_ = ' ' AND "
				cJoinMC += " TFH.TFH_ITCNB = '" + cItCNB + "' AND "
				cJoinMC += " TFH.TFH_FILIAL = '" + xFilial("TFH", cFilCNB) +"' "
			Else //Material x Item de RH
				cJoinMI := " LEFT JOIN " + RetSqlName("TFG") + " TFG ON "
				cJoinMI += " TFG.TFG_CODPAI = TFF.TFF_COD AND TFG.D_E_L_E_T_ = ' ' AND "
				cJoinMI += " TFG.TFG_ITCNB = '" + cItCNB + "' AND "
				cJoinMI += " TFG.TFG_FILIAL = '" + xFilial("TFG", cFilCNB) +"' "

				cJoinMC := " LEFT JOIN " + RetSqlName("TFH") + " TFH ON "
				cJoinMC += " TFH.TFH_CODPAI = TFF.TFF_COD AND TFH.D_E_L_E_T_ = ' ' AND "
				cJoinMC += " TFH.TFH_ITCNB = '" + cItCNB + "' AND "
				cJoinMC += " TFH.TFH_FILIAL = '" + xFilial("TFH", cFilCNB) +"' "
			EndIF
			cSql += " SELECT TFF.TFF_VLPRPA, TFH.TFH_VLPRPA, TFG.TFG_VLPRPA, TFF.TFF_ITCNB, "
			cSql += " TFF.TFF_QTDVEN, TFH.TFH_QTDVEN, TFG.TFG_QTDVEN "
			cSql += " FROM " + RetSqlName("TFL") + " TFL "
			cSql += " LEFT JOIN " + RetSqlName("TFF") + " TFF ON "
			cSql += " TFF.TFF_CODPAI = TFL.TFL_CODIGO AND "
			cSql += " TFF.TFF_FILIAL = '" + xFilial("TFF", cFilCNB) + "' AND "
			If lOrcPrc
				cSql += " TFF.TFF_ITCNB = '" + cItCNB + "' AND "
			EndIf
			cSql += " TFF.D_E_L_E_T_ = ' ' "
			cSql += cJoinMI
			cSql += cJoinMC
			cSql += " WHERE "
			cSql += " TFL.D_E_L_E_T_ = ' ' AND "
			cSql += " TFL.TFL_PLAN = '" + cPlan + "' AND "
			cSql += " TFL.TFL_CONTRT = '" + cContra + "' AND "
			cSql += " TFL.TFL_CONREV = '" + cRevisa + "' AND "
			cSql += " TFL.TFL_CODPAI = '" + cCodTFJ + "' AND "
			cSql += " TFL.TFL_FILIAL = '" + xFilial("TFL", cFilCNB) + "' "
			cSql := ChangeQuery(cSql)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasTFL, .F., .T.)
			While !(cAliasTFL)->(EOF())
				If !EMPTY((cAliasTFL)->TFF_VLPRPA) .AND. (cAliasTFL)->TFF_VLPRPA > 0 .AND. (cAliasTFL)->TFF_ITCNB == cItCNB
					nValPrPa := (cAliasTFL)->TFF_VLPRPA / (cAliasTFL)->TFF_QTDVEN
				ElseIf !EMPTY((cAliasTFL)->TFH_VLPRPA) .AND. (cAliasTFL)->TFH_VLPRPA > 0
					nValPrPa := (cAliasTFL)->TFH_VLPRPA / (cAliasTFL)->TFH_QTDVEN
				ElseIf !EMPTY((cAliasTFL)->TFG_VLPRPA) .AND. (cAliasTFL)->TFG_VLPRPA > 0
					nValPrPa := (cAliasTFL)->TFG_VLPRPA / (cAliasTFL)->TFG_QTDVEN
				EndIf
				If nValPrPa > 0
					oMdlMed:LoadValue('CNEDETAIL','CNE_VLUNIT',nValPrPa)
				EndIF
				(cAliasTFL)->(DbSkip())
			End
			(cAliasTFL)->(DbCloseArea())
		EndIf
	EndIf
EndIf
RestArea(aArea)
Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} TecBAtVlpr
@description Função executada ao encerrar a medição (CNTA121)

@author Mateus Boiani
@since  17/06/2020
/*/
//------------------------------------------------------------------------------
Function TecBAtVlpr(cFilCTR, cCodTFJ, cContra, cRevisa, nRecCNA)
Local cCodTFL := ""
Local cSql := ""
Local cAliasTFL	:= GetNextAlias()
Local lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.)
Local aArea := GetArea()
Local nRet := 0
Local nTotLocal := 0
Local lAgrupado := SuperGetMv("MV_GSDSGCN",,"2") == '2'
Local cCndNumMed	:= CND->CND_NUMMED
Local cNumPla		:= CNA->CNA_NUMERO			

Default cFilCTR := cFilAnt
If TecVlPrPar() .AND. POSICIONE("TFJ",1,xFilial("TFJ", cFilCTR)+cCodTFJ,"TFJ_CNTREC") == '1'
	cSql += " SELECT TFL.TFL_CODIGO "
	cSql += " FROM " + RetSqlName("TFL") + " TFL "
	cSql += " INNER JOIN " + RetSqlName("CNA") + " CNA ON "
	cSql += " CNA.CNA_NUMERO = TFL.TFL_PLAN AND "
	cSql += " CNA.CNA_CONTRA = TFL.TFL_CONTRT AND "
	cSql += " CNA.CNA_REVISA = TFL.TFL_CONREV AND "
	cSql += " CNA.CNA_FILIAL = '" + xFilial("CNA", cFilCTR) + "' "
	cSql += " WHERE "
	cSql += " TFL.D_E_L_E_T_ = ' ' AND "
	cSql += " TFL.TFL_CONTRT = '" + cContra + "' AND "
	cSql += " TFL.TFL_CONREV = '" + cRevisa + "' AND "
	cSql += " TFL.TFL_CODPAI = '" + cCodTFJ + "' AND "
	cSql += " TFL.TFL_FILIAL = '" + xFilial("TFL", cFilCTR) + "' AND "
	cSql += " CNA.R_E_C_N_O_ = " + cValToChar(nRecCNA)
	cSql := ChangeQuery(cSql)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasTFL, .F., .T.)
	cCodTFL := (cAliasTFL)->TFL_CODIGO
	(cAliasTFL)->(DbCloseArea())

	DBSelectArea("TFF")
	TFF->(DbSetOrder(3)) //TFF_FILIAL+TFF_CODPAI+TFF_ITEM
	TFF->(MsSeek(xFilial("TFF", cFilCTR) + cCodTFL))
	While !(TFF->(EOF())) .AND. TFF->TFF_FILIAL == xFilial("TFF", cFilCTR) .AND. TFF->TFF_CODPAI == cCodTFL
		If TFF->TFF_COBCTR != '2' 
			If TecAltVlpr(cContra,cRevisa,cCndNumMed,cNumPla,lAgrupado,TFF->TFF_ITCNB,TFF->TFF_PRODUT)
				nRet := At740PrxPa(/*cTipo*/, TFF->TFF_QTDVEN, TFF->TFF_PRCVEN, TFF->TFF_DESCON, TFF->TFF_TXLUCR, TFF->TFF_TXADM)
			Else
				nRet := TFF->TFF_VLPRPA
			EndIf
			RecLock("TFF", .F.)
				TFF->TFF_VLPRPA := nRet
			TFF->(MsUnlock())
			nTotLocal += nRet
		EndIf
		If !lOrcPrc
			DbSelectArea("TFH")
			TFH->(DbSetOrder(3)) //TFH_FILIAL+TFH_CODPAI+TFH_ITEM
			TFH->(MsSeek(xFilial("TFH", cFilCTR) + TFF->TFF_COD))
			While !(TFH->(EOF())) .AND. TFH->TFH_FILIAL == xFilial("TFH", cFilCTR) .AND. TFH->TFH_CODPAI == TFF->TFF_COD
				If TFH->TFH_COBCTR != '2'
					If TecAltVlpr(cContra,cRevisa,cCndNumMed,cNumPla,lAgrupado,TFH->TFH_ITCNB,TFH->TFH_PRODUT)
						nRet := At740PrxPa(/*cTipo*/, TFH->TFH_QTDVEN, TFH->TFH_PRCVEN, TFH->TFH_DESCON, TFH->TFH_TXLUCR, TFH->TFH_TXADM)
					Else
						nRet := TFH->TFH_VLPRPA
					EndIf
					RecLock("TFH", .F.)
						TFH->TFH_VLPRPA := nRet
					TFH->(MsUnlock())
					nTotLocal += nRet
				EndIf
				TFH->(DbSkip())
			End
			
			DbSelectArea("TFG")
			TFG->(DbSetOrder(3)) //TFG_FILIAL+TFG_CODPAI+TFG_ITEM
			TFG->(MsSeek(xFilial("TFG", cFilCTR) + TFF->TFF_COD))
			While !(TFG->(EOF())) .AND. TFG->TFG_FILIAL == xFilial("TFG", cFilCTR) .AND. TFG->TFG_CODPAI == TFF->TFF_COD
				If TFG->TFG_COBCTR != '2'
					If TecAltVlpr(cContra,cRevisa,cCndNumMed,cNumPla,lAgrupado,TFG->TFG_ITCNB,TFG->TFG_PRODUT)
						nRet := At740PrxPa(/*cTipo*/, TFG->TFG_QTDVEN, TFG->TFG_PRCVEN, TFG->TFG_DESCON, TFG->TFG_TXLUCR, TFG->TFG_TXADM)
					Else
						nRet := TFG->TFG_VLPRPA
					EndIf
					RecLock("TFG", .F.)
						TFG->TFG_VLPRPA := nRet
					TFG->(MsUnlock())
					nTotLocal += nRet					
				EndIf
				TFG->(DbSkip())
			End
		EndIf
		TFF->(DbSkip())
	End

	If lOrcPrc
		DbSelectArea("TFH")
		TFH->(DbSetOrder(3)) //TFH_FILIAL+TFH_CODPAI+TFH_ITEM
		TFH->(MsSeek(xFilial("TFH", cFilCTR) + cCodTFL))
		While !(TFH->(EOF())) .AND. TFH->TFH_FILIAL == xFilial("TFH", cFilCTR) .AND. TFH->TFH_CODPAI == cCodTFL
			If TFH->TFH_COBCTR != '2'
				If TecAltVlpr(cContra,cRevisa,cCndNumMed,cNumPla,lAgrupado,TFH->TFH_ITCNB,TFH->TFH_PRODUT)
					nRet := At740PrxPa(/*cTipo*/, TFH->TFH_QTDVEN, TFH->TFH_PRCVEN, TFH->TFH_DESCON, TFH->TFH_TXLUCR, TFH->TFH_TXADM)
				Else
					nRet := TFH->TFH_VLPRPA
				EndIf
				RecLock("TFH", .F.)
					TFH->TFH_VLPRPA := nRet
				TFH->(MsUnlock())
				nTotLocal += nRet
			EndIf
			TFH->(DbSkip())
		End
		
		DbSelectArea("TFG")
		TFG->(DbSetOrder(3)) //TFG_FILIAL+TFG_CODPAI+TFG_ITEM
		TFG->(MsSeek(xFilial("TFG", cFilCTR) + cCodTFL))
		While !(TFG->(EOF())) .AND. TFG->TFG_FILIAL == xFilial("TFG", cFilCTR) .AND. TFG->TFG_CODPAI == cCodTFL
			If TFG->TFG_COBCTR != '2'
				If TecAltVlpr(cContra,cRevisa,cCndNumMed,cNumPla,lAgrupado,TFG->TFG_ITCNB,TFG->TFG_PRODUT)
					nRet := At740PrxPa(/*cTipo*/, TFG->TFG_QTDVEN, TFG->TFG_PRCVEN, TFG->TFG_DESCON, TFG->TFG_TXLUCR, TFG->TFG_TXADM)
				Else
					nRet := TFG->TFG_VLPRPA
				EndIf
				RecLock("TFG", .F.)
					TFG->TFG_VLPRPA := nRet
				TFG->(MsUnlock())
				nTotLocal += nRet
			EndIf
			TFG->(DbSkip())
		End
	EndIf

	DbSelectArea("TFL")
	TFL->(DbSetOrder(1))
	If TFL->(MsSeek(xFilial("TFL",cFilCTR) + cCodTFL))
		RecLock("TFL", .F.)
			TFL->TFL_VLPRPA := nTotLocal
		TFL->(MsUnlock())
	EndIf
EndIf
RestArea(aArea)
Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecABRComp
@description Função que verifica se existe o campo da ABR no dic
@author Augusto Albuquerque
@since  06/07/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecABRComp()

Return ABR->( ColumnPos('ABR_COMPEN') ) > 0
//------------------------------------------------------------------------------
/*/{Protheus.doc} TecBRelABB
@description Retorna em formato de array as ABBs relacionadas de um determinado código
(pela Data de Referência)

@author Mateus Boiani
@since  13/07/2020
/*/
//------------------------------------------------------------------------------
Function TecBRelABB(cCodAbb)
Local aRet := {}
Local cAliasTDV2 := GetNextAlias()
Local cAliasTDV1 := GetNextAlias()
Local cDtRef := ""
Local cCodTec := ""
Local cFilABB := ""

BeginSql Alias cAliasTDV1
	SELECT TDV.TDV_DTREF, ABB.ABB_CODTEC, ABB.ABB_FILIAL
	FROM %table:TDV% TDV
	INNER JOIN %Table:ABB% ABB
		ON ABB.ABB_FILIAL = TDV.TDV_FILIAL
		AND ABB.ABB_CODIGO = TDV.TDV_CODABB
		AND ABB.%NotDel%
	WHERE TDV.TDV_FILIAL = %xFilial:TDV%
		AND TDV.%NotDel%
		AND ABB.ABB_CODIGO = %exp:cCodAbb%
EndSql

cDtRef := (cAliasTDV1)->TDV_DTREF
cCodTec := (cAliasTDV1)->ABB_CODTEC
cFilABB := (cAliasTDV1)->ABB_FILIAL

(cAliasTDV1)->(DbCloseArea())

BeginSql Alias cAliasTDV2
	SELECT TDV.TDV_CODABB
	FROM %table:TDV% TDV
	INNER JOIN %Table:ABB% ABB
		ON ABB.ABB_FILIAL = TDV.TDV_FILIAL
		AND ABB.ABB_CODIGO = TDV.TDV_CODABB
		AND ABB.%NotDel%
	WHERE ABB.ABB_FILIAL = %exp:cFilABB%
		AND TDV.%NotDel%
		AND TDV.TDV_DTREF = %exp:cDtRef%
		AND ABB.ABB_CODTEC = %exp:cCodTec% 
EndSql

While !(cAliasTDV2)->(EOF())
	AADD(aRet, (cAliasTDV2)->TDV_CODABB)
	(cAliasTDV2)->(DbSkip())
End
(cAliasTDV2)->(DbCloseArea())

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecCkStAt
@description Compara requisitos do atendente com requisitos do post
@param cCodAtd, string, código do atendente
@param cCodTFF, string, código do posto
@param cCodLocal, string, código do local de atendimento
@param cAtdFunc, string, código da função do posto
@param lTecxRh, lógico, verifica a integração do RH com o GS
@return cLogEsp, string, mensagem contendo as inconsistências entre atendente x post
@author Diego Bezerra
@since  16/07/2020
/*/
//------------------------------------------------------------------------------

Function TecCkStAt(cCodAtd, cCodTFF, cCodLocal, cAtdFunc, cLocFunc, lTecxRh, lDetail)

Local aLocEsp 	:= {}
Local aTecEsp 	:= {} 
Local cLogEsp	:= ""
Local nFound	:= 0
Local nX		:= 0
Local nY		:= 0
Local nCount 	:= 0
Local cCargFun	:= ""	// Cargo do funcionário
Local cDescCFun	:= ""	// Descrição do cargo do funcionário
Local cDescCLoc	:= ""	// Descrição do cargo do local
Local cCargLoc	:= ""	// Cargo do local de atendimento
Local cCodFun	:= ""	// Código do funcionário
Local cDtFunP	:= ""   // Descrição da função do posto	
Local cDtFunA	:= ""	// Descrição da função do atendente
Default lDetail	:= .F.	// .T. = Mensagem detalhada, .F. = Mensagem simplificada

aLocEsp	:= ckFilterATD(cCodAtd, cCodTFF, cCodLocal, lTecXRh)

cCodFun	:= POSICIONE("AA1",1,xFilial("AA1") + cCodAtd, "AA1_CDFUNC")
aTecEsp := TECHabTec(cCodAtd, cCodFun, lTecXRh)

If lTecXRh
	cCargFun := POSICIONE("SRA",1,xFilial("SRA") + cCodFun, "RA_CARGO")
	If lDetail .AND. !Empty(cCargFun) 
		cDescCFun := POSICIONE("SQ3",1, xFilial("SQ3") + cCargFun, "Q3_DESCSUM")
	EndIf
	cCargLoc := POSICIONE("TFF",1,xFilial("TFF") + cCodTFF,"TFF_CARGO")
	If lDetail .AND. !Empty(cCargLoc) 
		cDescCLoc := POSICIONE("SQ3",1, xFilial("SQ3") + cCargLoc, "Q3_DESCSUM")
	EndIf
	If ALLTRIM(cCargFun) <> ALLTRIM(cCargLoc)
		nCount++
		If lDetail
			cLogEsp += STR0061 + ALLTRIM(cCodAtd) +; //"- O cargo do atendente "
				Iif(!Empty(cCargFun), + STR0064 + ALLTRIM(cDescCFun), STR0062 ) +; //" é " #" está vazio"
				 STR0063 +; //" e o cargo do posto"
				Iif(!Empty(cCargLoc), STR0064 + ALLTRIM(cDescCLoc) + "; ", STR0062 + "; " ) + CRLF //" é " # " está vazio "
		Else
			cLogEsp += STR0060 //"cargo"
		EndIf
	EndIf
EndIf

If ALLTRIM(cAtdFunc) <> ALLTRIM(cLocFunc)
	nCount++
	If lDetail
		cDtFunP	:= POSICIONE("SRJ",1,xFilial("SRJ") + cLocFunc, "RJ_DESC")
		cDtFunA	:= POSICIONE("SRJ",1,xFilial("SRJ") + cAtdFunc, "RJ_DESC")
		cLogEsp += STR0065 + ALLTRIM(cCodAtd) +; //"- A função do atendente "
		 	Iif(!Empty(cAtdFunc), + STR0064 + ALLTRIM(cDtFunA), STR0062)+; // " é " # " está vazio"
			  STR0066 +;	// " e a função do posto "
			Iif(!Empty(cLocFunc), + STR0064 + ALLTRIM(cDtFunP) + "; ", + STR0062 + "; ") + CRLF // " é " # " está vazio"
	Else 
		If Empty(cLogEsp)
			cLogEsp += STR0059 //"funçao"
		Else
			cLogEsp += STR0058  //", funçao"
		EndIf
	EndIf
EndIf
For nX := 1 to Len(aLocEsp[1][2])
	nFound := 0
	For nY := 1 to Len(aTecEsp[1][2])
		If aLocEsp[1][2][nX][2] == aTecEsp[1][2][nY][2]
			nFound ++
		EndIf
	Next nY
	If nFound == 0
		nCount++
		If lDetail
			cLogEsp += STR0067 + CRLF // "- As características do atendente são incompatíveis com as necessárias para o posto;"
		Else
			If Empty(cLogEsp)
				cLogEsp += STR0057 // "características"
			Else
				cLogEsp += STR0056 //", características"
			EndIf
		EndIf
	EndIf
Next nX

For nX := 1 to Len(aLocEsp[2][2])
	nFound := 0
	For nY := 1 to Len(aTecEsp[2][2])
		If aLocEsp[2][2][nX][2] == aTecEsp[2][2][nY][2]
			nFound ++
		EndIf
	Next nY
	If nFound == 0
		nCount++
		If lDetail
			cLogEsp += STR0068 + CRLF // "- o atendente não possui as habilidades necessárias para o posto; "
		Else
			If Empty(cLogEsp)
				cLogEsp += STR0055 // "habilidades"
			Else
				cLogEsp += STR0054 //", habilidades"
			EndIf
		EndIf
	EndIf
Next nX

For nX := 1 to Len(aLocEsp[3][2])
	nFound := 0
	For nY := 1 to Len(aTecEsp[3][2])
		If aLocEsp[3][2][nX][2] == aTecEsp[3][2][nY][2]
			nFound ++
		EndIf
	Next nY
	If nFound == 0
		nCount++
		If lDetail
			cLogEsp += STR0069 + CRLF // "- O atendente não possui os cursos necessários para o posto; "
		Else
			If Empty(cLogEsp)
				cLogEsp += STR0053 // "cursos"
			Else
				cLogEsp += STR0052 // ", cursos"
			EndIf
		EndIf
	EndIf
Next nX

nFound := 0
For nY := 1 to Len(aTecEsp[4][2])
	If aLocEsp[4][2] == aTecEsp[4][2][nY][2]
		nFound ++
	EndIf
Next nY

If !Empty(aLocEsp[4][2]) .AND. nFound == 0
	nCount++
	If lDetail
		cLogEsp += STR0070 + CRLF  // "- A região de atendimento do atendente não contempla a região do posto "
	Else 
		If Empty(cLogEsp)
			cLogEsp += STR0051 //"região"
		Else
			cLogEsp += STR0050 //", região"
		EndIf
	EndIf
EndIf

If !Empty(cLogEsp ) 
	If lDetail
		cLogEsp := STR0071 + ALLTRIM(cCodAtd) + STR0072 + ALLTRIM(cCodTFF) + " :" + CRLF + cLogEsp + CRLF //"Inconsistências encontradas para o atendente " #" no posto "
	Else
		If nCount > 0
			cLogEsp := STR0047 + cLogEsp + STR0048 //"Inconsistências encontradas em: "#" do atendente"
		Else
			cLogEsp := STR0049 + cLogEsp + STR0048 //"Inconsistência encontra em  "#" do atendente"
		EndIf
	EndIf
EndIf

Return cLogEsp

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECHabTec
@description Obtem características, habilidades, cursos e região do atendente
@param cCodAtd, string, código do atendente
@param cCodTFF, string, código do posto
@param cCodLocal, string, código do local de atendimento
@param lTecXRh, lógico, integração do RH com GS
@return aRet, array, array com as características, habilidades, cursos e região do atendente
@author Diego Bezerra
@since  16/07/2020
/*/
//------------------------------------------------------------------------------
Static Function ckFilterATD(cCodAtd, cCodTFF, cCodLocal, lTecXRh)

Local cQry := ""
Local cAliasTDS := getNextAlias()
Local cAliasTDT := getNextAlias()
Local cAliasTGV := getNextAlias()
Local cAliasABS	:= getNextAlias()

Local aRet		:= { {"Caracteristicas", {}}, {"Habilidades",{}}, {"Cursos",{}}, {"Regiao",""} }

// Características

cQry = "SELECT TDS_CODTFF, TDS_CODTCZ, TCZ_DESC FROM " + retSqlName('TDS')+ " TDS "  
cQry += " INNER JOIN " + retSqlName('TCZ') + " TCZ ON TDS_CODTCZ = TCZ_COD "
cQry += " AND TCZ.TCZ_FILIAL = '" + xFilial('TCZ') + "'  AND TCZ.D_E_L_E_T_ = ' ' "
cQry += " WHERE TDS.TDS_FILIAL = '" + xFilial('TDS') + "' AND TDS.D_E_L_E_T_ = ' ' "
cQry += " AND TDS.TDS_CODTFF = '" + cCodTFF + "' "

cQry := ChangeQuery(cQry)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasTDS, .F., .T.)

// Habilidades
cQry = "SELECT  TDT_CODTFF, TDT_CODHAB, RBG_DESC FROM " + retSqlName("TDT") + " TDT "
cQry += " INNER JOIN " + retSqlName("RBG") + " RBG ON TDT_CODHAB = RBG_HABIL "
cQry += " AND RBG.RBG_FILIAL = '" + xFilial("RBG") + "' AND RBG.D_E_L_E_T_ = ' ' " 
cQry += " WHERE TDT.TDT_FILIAL = '" + xFilial("TDT") + "' AND TDT.D_E_L_E_T_ = ' ' " 
cQry += " AND TDT.TDT_CODTFF = '" + cCodTFF + "' "

cQry := ChangeQuery(cQry)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasTDT, .F., .T.)

// Cursos
cQry = "SELECT TGV_CODTFF, TGV_CURSO, RA1_DESC FROM " + retSqlName("TGV") + " TGV "
cQry += " INNER JOIN " + retSqlName("RA1") + " RA1 ON TGV_CURSO = RA1_CURSO "
cQry += " AND RA1.RA1_FILIAL = '" + xFilial("RA1") + "' AND RA1.D_E_L_E_T_ = ' ' "
cQry += " WHERE TGV.TGV_FILIAL = '" + xFilial("TGV") + "' AND TGV.D_E_L_E_T_ = ' '"
cQry += " AND TGV_CODTFF = '" + cCodTFF + "' "

cQry := ChangeQuery(cQry)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasTGV, .F., .T.)

cQry = "SELECT ABS_REGIAO FROM "+retSqlName("ABS") + " ABS WHERE ABS.ABS_FILIAL = '" + xFilial("ABS") + "' AND ABS.D_E_L_E_T_ = ' ' "
cQry += " AND ABS_LOCAL = '" + cCodLocal + "' "
cQry := ChangeQuery(cQry)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasABS, .F., .T.)


While (cAliasTDS)->(!Eof())
	aAdd(aRet[1][2],{ (cAliasTDS)->TDS_CODTFF, (cAliasTDS)->TDS_CODTCZ,(cAliasTDS)->TCZ_DESC })
	(cAliasTDS)->(dbSkip())
EndDo
(cAliasTDS)->(dbCloseArea())

While (cAliasTDT)->(!Eof())
	aAdd(aRet[2][2],{ (cAliasTDT)->TDT_CODTFF, (cAliasTDT)->TDT_CODHAB,(cAliasTDT)->RBG_DESC })
	(cAliasTDT)->(dbSkip())
EndDo
(cAliasTDT)->(dbCloseArea())

While (cAliasTGV)->(!Eof())
	aAdd(aRet[3][2],{ (cAliasTGV)->TGV_CODTFF, (cAliasTGV)->TGV_CURSO,(cAliasTGV)->RA1_DESC })
	(cAliasTGV)->(dbSkip())
EndDo
(cAliasTGV)->(dbCloseArea())

If (cAliasABS)->(!Eof())
	aRet[4][2] := (cAliasABS)->ABS_REGIAO
EndIf
(cAliasABS)->(dbCloseArea())

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} getPosCar
@description Obtem características, habilidades, cursos e região do atendente
@param cCodTec, string, código do atendente
@param cMatFunc, string, matrícula do funcionário
@param lTecXRh, lógico, integração do RH com GS
@return aRet, array, array com as características, habilidades, cursos e regiões do posto
@author Diego Bezerra
@since  16/07/2020
/*/
//------------------------------------------------------------------------------
Static Function TECHabTec(cCodTec, cMatFunc, lTecXRh)

Local cQry 		:= ""
Local cAliasTDU	:= getNextAlias()	// Características do atendente
Local cAliasHAB	:= getNextAlias()	// Habilidades do funcionário
Local cAliasRA4	:= getNextAlias()	// Cursos do funcionario
Local cAliasABU := getNextAlias()	// Regiões de atendimento do atendente

Local aRet		:= { {"Caracteristicas", {}}, {"Habilidades",{}}, {"Cursos",{}}, {"Regioes",{}} }

// Características
cQry = "SELECT TDU_CODTEC, TDU_COD, TCZ_DESC FROM " + retSqlName("TDU") + " TDU "
cQry += " INNER JOIN " + retSqlName("TCZ") + " TCZ ON TDU_COD = TCZ_COD "
cQry += " AND TCZ.TCZ_FILIAL = '" + xFilial("TCZ") + "' AND TCZ.D_E_L_E_T_ = ' '"
cQry += " WHERE TDU.TDU_FILIAL = '" + xFilial("TDU") + "' AND TDU.D_E_L_E_T_ = ' '"
cQry += " AND TDU.TDU_CODTEC = '" + cCodTec + "' "
cQry := ChangeQuery(cQry)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasTDU, .F., .T.)

// Habilidades
If lTecXRh
	cQry = "SELECT RBI_MAT, RBI_HABIL, RBG_DESC FROM " + retSqlName("RBI") + " RBI "
	cQry += " INNER JOIN " + retSqlName("RBG") + " RBG ON RBI_HABIL = RBG_HABIL "
	cQry += " AND RBG.RBG_FILIAL = '" + xFilial("RBG") + "' AND RBG.D_E_L_E_T_ = ' ' "
	cQry += " WHERE RBI.RBI_FILIAL = '" + xFilial("RBI") + "' AND RBI.D_E_L_E_T_ = ' ' "
	cQry += " AND RBI_MAT = '" + cMatFunc + "' "
	cQry := ChangeQuery(cQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasHAB, .F., .T.)
Else
	cQry = "SELECT AA2_CODTEC, AA2_HABIL, AA2_DESCRI FROM " + retSqlName("AA2") + " AA2 "
	cQry += " WHERE AA2.AA2_FILIAL = '" + xFilial("AA2") + "' AND AA2.D_E_L_E_T_ = ' '"
	cQry := ChangeQuery(cQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasHAB, .F., .T.)
EndIf

// Cursos
cQry = "SELECT RA4_MAT, RA4_CURSO, RA1_DESC FROM " + retSqlName("RA4") + " RA4 "
cQry += " INNER JOIN " + retSqlName("RA1") + " RA1 ON RA4_CURSO = RA1_CURSO "
cQry += " AND RA1.RA1_FILIAL = '" + xFilial("RA1") + "' AND RA1.D_E_L_E_T_ = ' '"
cQry += " WHERE RA4.RA4_FILIAL = '" + xFilial("RA4") + "' AND RA4.D_E_L_E_T_ = ' '"
cQry += " AND RA4_MAT = '" + cMatFunc + "' "
cQry := ChangeQuery(cQry)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasRA4, .F., .T.)

// Regiões
cQry = "SELECT ABU_CODTEC, ABU_REGIAO FROM " + retSqlName("ABU") + " ABU WHERE ABU.ABU_FILIAL = '" + xFilial("ABU") + "' AND ABU.D_E_L_E_T_ = ' ' " 
cQry += " AND ABU.ABU_CODTEC = '" + cCodTec + "' "
cQry := ChangeQuery(cQry)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasABU, .F., .T.)

While (cAliasTDU)->(!Eof())
	aAdd(aRet[1][2],{ (cAliasTDU)->TDU_CODTEC, (cAliasTDU)->TDU_COD,(cAliasTDU)->TCZ_DESC })
	(cAliasTDU)->(dbSkip())
EndDo
(cAliasTDU)->(dbCloseArea())

While (cAliasHAB)->(!Eof())
	If lTecXRh
		aAdd(aRet[2][2],{ (cAliasHAB)->RBI_MAT, (cAliasHAB)->RBI_HABIL,(cAliasHAB)->RBG_DESC })
	Else
		aAdd(aRet[2][2],{ (cAliasHAB)->AA2_CODTEC, (cAliasHAB)->AA2_HABIL,(cAliasHAB)->AA2_DESCRI  })
	EndIF
	(cAliasHAB)->(dbSkip())
EndDo
(cAliasHAB)->(dbCloseArea())

While (cAliasRA4)->(!Eof())
	aAdd(aRet[3][2],{ (cAliasRA4)->RA4_MAT, (cAliasRA4)->RA4_CURSO,(cAliasRA4)->RA1_DESC })
	(cAliasRA4)->(dbSkip())
EndDo
(cAliasRA4)->(dbCloseArea())

While (cAliasABU)->(!Eof())
	aAdd(aRet[4][2],{ (cAliasABU)->ABU_CODTEC, (cAliasABU)->ABU_REGIAO })
	(cAliasABU)->(dbSkip())
EndDo
(cAliasABU)->(dbCloseArea())

Return aRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} TecBOrdMrk

@description Verifica a TDV para inserir os dados da SP8 

(só é executado caso o sistema localize a alteração de Turno entre os dias)

@author	Mateus Boiani
@since	01/07/2019
/*/
//------------------------------------------------------------------------------
Function TecBOrdMrk(aMarcacoes, nMar, aOrd, nTab, cMarc, aTabCalend, nPosCalend, cFilSRA, cMat)
Local aArea 	:= GetArea()
Local cOrdem 	:= aOrd[ nTab , 1 ]
Local dDataApo 	:= aOrd[ nTab , 7 ]
Local cTurno 	:= aOrd[ nTab , 2 ]
Local cSeq 		:= aOrd[ nTab , 6 ]
Local lTECA910 	:= isInCallStack("TECA910") .OR. isInCallStack("At910MaJob")
Local aDados	:= {}
Local npos		:= 0
Local nX		:= 0
Local lEntrada	:= .F.

If !EMPTY(cFilSRA) .AND. !EMPTY(cMat) .AND. lTECA910
	lEntrada := (nMar % 2 == 1)
	
	aDados := TecGetaDad()

	If lEntrada
		npos := AScan( aDados, { |a| a[1] == cFilSRA .AND. a[2] == cMat ;
						.AND. (a[3] == aMarcacoes[nMar][1]  ) ;
						.AND. (a[5] == TxValToHor(aMarcacoes[nMar][2])  )})
	Else
		npos := AScan( aDados, { |a| a[1] == cFilSRA .AND. a[2] == cMat ;
						.AND. ( a[4] == aMarcacoes[nMar][1] ) ;
						.AND. (a[6] == TxValToHor(aMarcacoes[nMar][2]) )})
	EndIf
	If npos == 0
		If Empty(aAtendVer) .Or. ASCAN(aAtendVer, { |a| a[1] == cFilSRA .AND. a[2] == cMat }) == 0
			AADD( aAtendVer, { cFilSRA, cMat })
			DbSelectArea("AA1")
			AA1->(DbSetOrder(7)) // AA1_FILIAL, AA1_CDFUNC, AA1_FUNFIL
			If AA1->(DbSeek(xFilial("AA1") + cMat + cFilSRA))
				aDados := At910QryDa( AA1->AA1_CODTEC )
				For nX := 1 To LEN(aDados)
					If VALTYPE(aDados[nX][3]) == 'C'
						aDados[nX][3] := StoD(aDados[nX][3])
					EndIf
					If VALTYPE(aDados[nX][4]) == 'C'
						aDados[nX][4] := StoD(aDados[nX][4])
					Endif
				Next nX
				If lEntrada
					npos := AScan( aDados, { |a| a[1] == cFilSRA .AND. a[2] == cMat ;
									.AND. (a[3] == aMarcacoes[nMar][1]  ) ;
									.AND. (a[5] == TxValToHor(aMarcacoes[nMar][2])  )})
				Else
					npos := AScan( aDados, { |a| a[1] == cFilSRA .AND. a[2] == cMat ;
									.AND. ( a[4] == aMarcacoes[nMar][1] ) ;
									.AND. (a[6] == TxValToHor(aMarcacoes[nMar][2]) )})
				EndIf
			EndIf
		EndIf
	EndIf
	If npos > 0
		cTurno := aDados[npos][7]
		cSeq := aDados[npos][8]
		dDataApo := SToD(aDados[npos][9])
	EndIf
	If aScan(aTabCalend,{ |x| x[48] == dDataApo }) > 0
		cOrdem := aTabCalend[aScan(aTabCalend,{ |x| x[48] == dDataApo })][2]
	EndIf
EndIf

IF !( aMarcacoes[ nMar , 13 ] ) //AMARC_L_ORIGEM
	aMarcacoes[ nMar , 03 ]	:= cOrdem //AMARC_ORDEM
	aMarcacoes[ nMar , 25 ] := dDataApo //AMARC_DATAAPO
	aMarcacoes[ nMar , 06 ] := cTurno //AMARC_TURNO
	aMarcacoes[ nMar , 16 ] := cSeq	 //AMARC_SEQ
EndIF

aMarcacoes[ nMar , 14 ]	:= cMarc //AMARC_DTHR2STR

RestArea(aArea)
Return nil
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecBTCUAlC
@description Função que verifica se existe o campo TCU_ALOCEF no dicionario.
@author Mateus Boiani
@since  27/08/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecBTCUAlC()
Local lRet := .F.
Local aArea := GetArea()

DbSelectArea("TCU")
lRet := TCU->( ColumnPos('TCU_ALOCEF') ) > 0

RestArea(aArea)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecEntCtb
@description Função que verifica se existe os campos ABS_CONTA, ABS_ITEM, ABS_CLVL, TFS_CONTA, TFS_ITEM, TFS_CLVL, TFT_CONTA, TFT_ITEM, TFT_CLVL no dicionario.
@author Kaique Schiller
@since  09/09/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecEntCtb(cTbl)
Local lRet := .F.
Local aArea := GetArea()

If cTbl == "ABS"
	DbSelectArea("ABS")
	lRet := ABS->(ColumnPos('ABS_CONTA')) > 0 .And. ABS->(ColumnPos('ABS_ITEM')) > 0 .And. ABS->(ColumnPos('ABS_CLVL')) > 0
Elseif cTbl == "TFS"
	DbSelectArea("TFS")
	lRet := TFS->(ColumnPos('TFS_CONTA')) > 0 .And. TFS->(ColumnPos('TFS_ITEM')) > 0 .And. TFS->(ColumnPos('TFS_CLVL')) > 0
Elseif cTbl == "TFT"
	DbSelectArea("TFT")
	lRet := TFT->(ColumnPos('TFT_CONTA')) > 0 .And. TFT->(ColumnPos('TFT_ITEM')) > 0 .And. TFT->(ColumnPos('TFT_CLVL')) > 0
Endif

RestArea(aArea)
Return lRet
//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecBVldBnf
@description Função executada pelo fonte GPEXCBEN durante o cálculo de benefícios
@author Mateus Boiani
@since  15/10/2020
/*/
//--------------------------------------------------------------------------------
Function TecBVldBnf(aDia,cFunFil,cCdFunc)
Local lRet := aDia[4]
Local lExec := SuperGetMV("MV_GSBENAG",,.F.) .AND. !EMPTY(cFunFil) .AND.;
				!EMPTY(cCdFunc) .AND. VALTYPE(aDia) == 'A' .AND. VALTYPE(aDia[1]) == 'D'
Local aArea

If lExec 
	If ASCAN(aDiasBenf, { |x| x[1] == cFunFil .AND. x[2] == cCdFunc .AND. x[3] == aDia[1] .AND. !x[4] }) == 0
		aArea := GetArea()
		DbSelectArea("AA1")
		AA1->(DbSetOrder(7)) // AA1_FILIAL, AA1_CDFUNC, AA1_FUNFIL
		If AA1->(DbSeek(xFilial("AA1") + cCdFunc + cFunFil))
			lRet := TecADiaExs(aDia[1],cFunFil,cCdFunc)
		EndIf
		RestArea(aArea)
	Else
		lRet := .F.
	EndIf
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecSeqAgen
@description Função que verifica se existe agenda vinculada ao turno e seq preste a ser deletada na chamada do fonte
de GPE(PONA080)
@author Augusto Albuquerque
@since  15/10/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecSeqAgen( cTurno, cSeq, aLog, lDelOk, cUseAlias )
Local cQuery	:= ""
Local cSql		:= ""
Local cAliasTDV	:= GetNextAlias()
Local cAliasTDX := GetNextAlias()

cQuery := ""
cQuery += " SELECT 1 "
cQuery += " FROM " + RetSqlName("TDV") + " TDV "
cQuery += " WHERE TDV.TDV_FILIAL = '" + xFilial("TDV") + "' "
cQuery += " AND TDV.TDV_TURNO = '" + cTurno + "' "
cQuery += " AND TDV.TDV_SEQTRN = '" + cSeq + "' "
cQuery += " AND TDV.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN",TcGenQry(,,cQuery), cAliasTDV, .T., .T.)

cSql := ""
cSql += " SELECT 1 "
cSql += " FROM " + RetSqlName("TDX") + " TDX "
cSql += " WHERE TDX.TDX_FILIAL = '" + xFilial("TDX") + "' "
cSql += " AND TDX.TDX_TURNO = '" + cTurno + "' "
cSql += " AND TDX.TDX_SEQTUR = '" + cSeq + "' "
cSql += " AND TDX.D_E_L_E_T_ = ' ' "

cSql := ChangeQuery(cSql)
DbUseArea(.T., "TOPCONN",TcGenQry(,,cSql), cAliasTDX, .T., .T.)

If !(cAliasTDV)->(EOF()) .OR. !(cAliasTDX)->(EOF())
	cUseAlias := "TDV/ABB/TDX"
	lDelOk := .F.
	aAdd( aLog , "" )
	aAdd( aLog , "" )
	aAdd( aLog , STR0073 + cTurno + "/" + cSeq + STR0074 ) //"A Sequência " ( Filial/Turno/Seq ) "###" " não pode ser excluída. Já existe agenda gerada para esse turno e sequência e/ou pertence a alguma escala."
EndIf

(cAliasTDV)->(DbCloseArea())
(cAliasTDX)->(DbCloseArea())

Return Nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecBAtuDia
@description Adiciona no array static os dias de agendas que foram enviados para beneficios.
@author Augusto Albuquerque
@since  30/10/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecBAtuDia( cFilAte, cMat, dDataRef, lVal)
AADD( aDiasBenf, { cFilAte, cMat, dDataRef, lVal })
Return Nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecMedAgil
@description Função que verifica se existe os campos TFV_MEDAGI e TFV_AGRUP no dicionario.
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecMedAgil()
Return TFV->( ColumnPos('TFV_MEDAGI') ) > 0 .AND. TFV->( ColumnPos('TFV_AGRUP') ) > 0

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecTituDes
@description Função que retorna o titulo ou descrição do campo, de acordo com a SX3.
@author Augusto Albuquerque
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecTituDes( cCampo, lTitulo )
Local cRet	:= ""

Default lTitulo := .T.

If lTitulo
	cRet := AllTrim(FWX3Titulo(cCampo))
Else
	cRet := AllTrim(FWSX3Util():GetDescription( cCampo ))
EndIf

Return cRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecMdtGS
@description Verifica se existe Integração entre SIGAMDT e SIGATEC
@author Mário Augusto Cavenaghi - EthosX
@since  07/12/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecMdtGS()
	Local lMdtGS := SuperGetMv("MV_NG2GS", .F., .F.)	//	Parâmetro de integração entre o SIGAMDT x SIGATEC 

	lMdtGS := lMdtGS .And. TFF->(ColumnPos("TFF_RISCO")) > 0
	lMdtGS := lMdtGS .And. TN5->(ColumnPos("TN5_LOCAL")) > 0
	lMdtGS := lMdtGS .And. TN5->(ColumnPos("TN5_POSTO")) > 0

Return(lMdtGS)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecAltVlpr
@description Função que verifica se o item da TFF foi medido, para alterar valor da proxima parcela
@author Luiz Gabriel
@since  29/12/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function TecAltVlpr(cContra,cRevisa,cCndNumMed,cNumPla,lAgrupado,cItCNB,cProdut)
Local lRet 			:= .T.
Local cAliasCNE		:= GetNextAlias()

If !lAgrupado
	BeginSql Alias cAliasCNE
		SELECT CNE.CNE_VLTOT
		FROM %table:CNE% CNE
		WHERE CNE.CNE_FILIAL = %xFilial:CNE%
			AND CNE.CNE_CONTRA = %exp:cContra%
			AND CNE.CNE_REVISA = %exp:cRevisa%
			AND CNE.CNE_NUMMED = %exp:cCndNumMed%
			AND CNE.CNE_NUMERO = %exp:cNumPla%
			AND CNE.CNE_PRODUT = %exp:cProdut%
			AND CNE.CNE_ITEM = %exp:cItCNB%
			AND CNE.%NotDel%
	EndSql

	If !(cAliasCNE)->(EOF()) .AND. (cAliasCNE)->CNE_VLTOT == 0
		lRet := .F.	
	EndIf
	(cAliasCNE)->(dbCloseArea())
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecMtFlArm
@description Verificar se o multifilial esta ligado e os compartilhamento das tabelas correto para o requisito
@author Kaique Schiller
@since  25/11/2020
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecMtFlArm()
Local cComTE0 := FwModeAccess("TE0",1) +  FwModeAccess("TE0",2) + FwModeAccess("TE0",3)
Local cComTE1 := FwModeAccess("TE1",1) +  FwModeAccess("TE1",2) + FwModeAccess("TE1",3)
Local cComTE2 := FwModeAccess("TE2",1) +  FwModeAccess("TE2",2) + FwModeAccess("TE2",3)
Local cComT49 := FwModeAccess("TE1",1) +  FwModeAccess("TE1",2) + FwModeAccess("TE1",3)
Local cComTFP := FwModeAccess("TFP",1) +  FwModeAccess("TFP",2) + FwModeAccess("TFP",3)

Return SuperGetMV("MV_GSARMFL",,.F.) .AND. cComTE0 == "CCC" .AND.;
										   cComTE1 == "CCC" .AND.;
 										   cComTE2 == "CCC" .AND.;
										   cComT49 == "CCC" .AND.;
										   cComTFP == "CCC"

//-------------------------------------------------------------------
/*/{Protheus.doc} TecFlArma

@description Monta a consulta padrão (F3) específica para armamento multi-filial
@author	Kaique Schiller
@since	28/12/2020
/*/
//-------------------------------------------------------------------
Function TecFlArma()
Local aSeek := {}
Local aIndex := {}
Local cQry
Local cAls := GetNextAlias()
Local nSuperior
Local nEsquerda
Local nInferior
Local nDireita
Local oDlgEscTela
Local oBrowse
Local lRet := .F.
Local oModel := FwModelActive()
Local cFilBkp := cFilAnt
Local cFilLoc := ""
Local cTblLoc := "TER"
Local cTitulo := STR0111 //"Local Interno"

If oModel:GetId() == "TECA710"
	cFilLoc := oModel:GetValue("TE0MASTER","TE0_FILLOC")
Elseif oModel:GetId() == "TECA720"
	cFilLoc := oModel:GetValue("TE1MASTER","TE1_FILLOC")
Elseif oModel:GetId() == "TECA730"
	cFilLoc := oModel:GetValue("T49DETAIL","T49_FILLOC")
Elseif oModel:GetId() == "TECA750"
	If oModel:GetValue("TE4MASTER","TE4_OCPOST") == "S"
		cTblLoc := "ABS"
		cFilLoc := oModel:GetValue("TE4MASTER","TE4_FILLOC")
		cTitulo := STR0112 //"Local de Atendimento"
	Else
		cFilLoc := oModel:GetValue("TE4MASTER","TE4_FILINT")
	Endif
Endif

If cFilAnt <> cFilLoc
	cFilBkp := cFilAnt
	cFilAnt := cFilLoc
Endif

If cTblLoc == "TER"
	Aadd( aSeek, { STR0113, {{"","C",TamSX3("TER_FILIAL")[1],0,STR0113,,}} } ) //"Filial" # "Filial"
	Aadd( aSeek, { STR0114, {{"","C",TamSX3("TER_CODIGO")[1],0,STR0114,,}} } ) //"Cód. Local" # "Cód. Local"
	Aadd( aSeek, { STR0115, {{"","C",TamSX3("TER_DESCRI")[1],0,STR0115,,}} } )	//"Descrição" # "Descrição"

	Aadd( aIndex, "TER_FILIAL" )
	Aadd( aIndex, "TER_CODIGO" )
	Aadd( aIndex, "TER_DESCRI")  // adicionado para não ter problema de não encontrar o último índice, em caso de adicionar mais deixe a filial por último

	cQry := " SELECT TER_FILIAL, TER_CODIGO, TER_DESCRI "
	cQry += " FROM " + RetSqlName("TER") + " TER "
	cQry += " WHERE TER.TER_FILIAL = '" +  xFilial('TER') + "' AND "
	cQry += " TER.D_E_L_E_T_ = ' ' "
Else
	Aadd( aSeek, { STR0113, {{"","C",TamSX3("ABS_FILIAL")[1],0,STR0113,,}} } ) //"Filial" # "Filial"
	Aadd( aSeek, { STR0114, {{"","C",TamSX3("ABS_LOCAL")[1],0,STR0114,,}} } ) //"Cód. Local" # "Cód. Local"
	Aadd( aSeek, { STR0115, {{"","C",TamSX3("ABS_DESCRI")[1],0,STR0115,,}} } )	//"Descrição" # "Descrição"

	Aadd( aIndex, "ABS_FILIAL" )
	Aadd( aIndex, "ABS_LOCAL" )
	Aadd( aIndex, "ABS_DESCRI")  // adicionado para não ter problema de não encontrar o último índice, em caso de adicionar mais deixe a filial por último

	cQry := " SELECT ABS_FILIAL, ABS_LOCAL, ABS_DESCRI "
	cQry += " FROM " + RetSqlName("ABS") + " ABS "
	cQry += " WHERE ABS.ABS_FILIAL = '" +  xFilial('ABS') + "' AND "
	cQry += " ABS.D_E_L_E_T_ = ' ' "
Endif

nSuperior := 0
nEsquerda := 0

If !isBlind()
	nInferior := GetScreenRes()[2] * 0.6
	nDireita  := GetScreenRes()[1] * 0.65

	DEFINE MSDIALOG oDlgEscTela TITLE cTitulo FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL //"Local Interno"

	oBrowse := FWFormBrowse():New()
	oBrowse:SetOwner(oDlgEscTela)
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetAlias(cAls)
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetQuery(cQry)
	oBrowse:SetSeek(,aSeek)
	oBrowse:SetDescription(cTitulo) //"Local Interno"
	oBrowse:SetMenuDef("")
	oBrowse:DisableDetails()

	If cTblLoc == "TER"
		oBrowse:SetDoubleClick({ || cRetF3 := (oBrowse:Alias())->TER_CODIGO, lRet := .T. ,oDlgEscTela:End()})
		oBrowse:AddButton( OemTOAnsi(STR0116), {|| cRetF3  := (oBrowse:Alias())->TER_CODIGO, lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"
	Else
		oBrowse:SetDoubleClick({ || cRetF3 := (oBrowse:Alias())->ABS_LOCAL, lRet := .T. ,oDlgEscTela:End()})
		oBrowse:AddButton( OemTOAnsi(STR0116), {|| cRetF3  := (oBrowse:Alias())->ABS_LOCAL, lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"
	Endif

	oBrowse:AddButton( OemTOAnsi(STR0117),  {|| cRetF3  := "", oDlgEscTela:End() } ,, 2 )	//"Cancelar"	
	oBrowse:DisableDetails()

	If cTblLoc == "TER"
		ADD COLUMN oColumn DATA { ||  TER_FILIAL  	} TITLE STR0113 SIZE TamSX3("TER_FILIAL")[1] OF oBrowse //"Filial"
		ADD COLUMN oColumn DATA { ||  TER_CODIGO  	} TITLE STR0114 SIZE TamSX3("TER_CODIGO")[1] OF oBrowse //"Cód. Local" 
		ADD COLUMN oColumn DATA { ||  TER_DESCRI  	} TITLE STR0115 SIZE TamSX3("TER_DESCRI")[1] OF oBrowse //"Descrição do Local"
	Else
		ADD COLUMN oColumn DATA { ||  ABS_FILIAL  	} TITLE STR0113 SIZE TamSX3("ABS_FILIAL")[1] OF oBrowse //"Filial"
		ADD COLUMN oColumn DATA { ||  ABS_LOCAL  	} TITLE STR0115 SIZE TamSX3("ABS_LOCAL")[1] OF oBrowse //"Cód. Local" 
		ADD COLUMN oColumn DATA { ||  ABS_DESCRI  	} TITLE STR0115 SIZE TamSX3("ABS_DESCRI")[1] OF oBrowse //"Descrição do Local"
	Endif	

	oBrowse:Activate()

	ACTIVATE MSDIALOG oDlgEscTela CENTERED
EndIf
If cFilAnt <> cFilBkp
	cFilAnt := cFilBkp
Endif

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} At710RF3

@description Variavel Static utilizada no F3 do Código do local interno de armamento multi-filial
@author	Kaique Schiller
@since	28/12/2020
/*/
//-------------------------------------------------------------------
Function TecArmFlF3()

Return cRetF3


/*--------------------------------------------------------------------------------------------------------------------
{Protheus.doc} TecSx5Desc
Obtem a descrição da espécie de armamento na tabela genériga sx5
@author   Diego Bezerra
@since    02/03/2021
@version  P12.1.27
----------------------------------------------------------------------------------------------------------------------*/
Function TecSx5Desc(cTable,cChave)
Return ALLTRIM(POSICIONE("SX5",1,XFILIAL("SX5")+cTable+cChave,"X5_DESCRI"))

/*--------------------------------------------------------------------------------------------------------------------
{Protheus.doc} TecSx3Combo
Retorna o conteudo do Combo Box conforme o idioma 
@author   Matheus.Gonçalves
@since    10/03/2021
@version  P12.1.27
----------------------------------------------------------------------------------------------------------------------*/
Function TecSx3Combo(cCampo)
Local cRet	:= ""

SX3->(DbSetOrder(2))

If SX3->(DBSeek(cCampo))
	cRet := X3CBox()
EndIf

Return cRet
//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecBMetrics

@description Envio de métricas telemetria
@author Mateus Boiani
@since  20/05/2021
/*/
//--------------------------------------------------------------------------------
Function TecBMetrics()
Local cORCPRC := IIF( SuperGetMv("MV_ORCPRC",,.F.) , "MV_ORCPRC_true" , "MV_ORCPRC_false" )
Local cGSDSGCN := IIF(  SuperGetMv("MV_GSDSGCN",,"2") == '1' , "MV_GSDSGCN_true" , "MV_GSDSGCN_false" )
Local cGSPNMTA := IIF( SuperGetMv("MV_GSPNMTA",,.F.) , "MV_GSPNMTA_true" , "MV_GSPNMTA_false" )
If !EMPTY(GetApoInfo("FWCUSTOMMETRICS.TLPP"))
	FwCustomMetrics():setSumMetric(cORCPRC, "configuracao-por-conteudo-parametro", 1)
	FwCustomMetrics():setSumMetric(cGSDSGCN, "configuracao-por-conteudo-parametro", 1)
	FwCustomMetrics():setSumMetric(cGSPNMTA, "configuracao-por-conteudo-parametro", 1)
	FwCustomMetrics():setSumMetric(cORCPRC, "gestao-de-servicos-protheus_configuracao-por-conteudo-parametro_count", 1)
	FwCustomMetrics():setSumMetric(cGSDSGCN, "gestao-de-servicos-protheus_configuracao-por-conteudo-parametro_count", 1)
	FwCustomMetrics():setSumMetric(cGSPNMTA, "gestao-de-servicos-protheus_configuracao-por-conteudo-parametro_count", 1)
EndIf
Return .T.
//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecBCtrLE

@description Retorna se um contrato é de L.E.
@author Mateus Boiani
@since  10/06/2021
/*/
//--------------------------------------------------------------------------------
Function TecBCtrLE(cFilCNB,cContra,cRevisa)
Local lRet := .F.
Local aArea := GetArea()
Local cAliasTFI	:= GetNextAlias()

BeginSql Alias cAliasTFI
	SELECT 1 REC
	FROM %table:TFI% TFI
	WHERE TFI.TFI_FILIAL = %exp:cFilCNB%
		AND TFI.TFI_CONTRT = %exp:cContra%
		AND TFI.TFI_CONREV = %exp:cRevisa%
		AND TFI.%NotDel%
EndSql

lRet := (cAliasTFI)->(!Eof())

(cAliasTFI)->(DbCloseArea())
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecVerRePl
@description Verifica a criações dos campos para utilizar a ravisão planejada
@author	augusto.albuquerque
@since	25/06/2021
/*/
//-------------------------------------------------------------------------------------------------------------------
Function TecVerRePl()
lRet := TFL->( ColumnPos('TFL_MODPLA') ) > 0 .AND. TFL->( ColumnPos('TFL_CODREL') ) > 0 .AND. TFF->( ColumnPos('TFF_MODPLA') ) > 0 .AND. TFF->( ColumnPos('TFF_CODREL') ) > 0;
		.AND. TFG->( ColumnPos('TFG_MODPLA') ) > 0 .AND. TFG->( ColumnPos('TFG_CODREL') ) > 0 .AND. TFH->( ColumnPos('TFH_MODPLA') ) > 0 .AND. TFH->( ColumnPos('TFH_CODREL') ) > 0;
		.AND. TFJ->( ColumnPos('TFJ_DTPLRV') ) > 0 .AND. TFJ->( ColumnPos('TFJ_CODREL') ) > 0 .AND. TFU->( ColumnPos('TFU_MODPLA') ) > 0 .AND. TFU->( ColumnPos('TFU_CODREL') ) > 0

Return lRet
//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecBHasCrn

@description Retorna se a base de dados possui a tabela de Cronograma de Cobranças
@author Mateus Boiani
@since  20/07/2021
/*/
//--------------------------------------------------------------------------------
Function TecBHasCrn()

Return AliasInDic('TGT')
//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecBCrrTGT

@description Retorna em um array as informações de Competência / Valor / Item,
				já agregando os itens sem TGT

@return aRet[x]
			[x][1] = Competência (MM/YYYY)
			[x][2]
				[x][2][1] = Valor (TGT_VALOR ou valor do item)
				[x][2][2] = TFF / TFH / TFG
				[x][2][3] = Chave única (TFF_COD / TFH_COD / TFG_COD)

@author Mateus Boiani
@since  20/07/2021
/*/
//--------------------------------------------------------------------------------
Function TecBCrrTGT(nRECCNA, cCompet)
Local cSpaceTFL := SPACE(TamSx3("TFL_CODSUB")[1])
Local cAliasAux := GetNextAlias()
Local cSql := ""
Local nAux := 0
Local aRet := {}
Local aJaProc := {}
Local nX
Local lExcedente := TecBHasExc()

Default cCompet := ""

cSql := " SELECT TGT.TGT_VALOR, TGT.TGT_COMPET, TGT.TGT_TPITEM, TGT.TGT_CDITEM "
cSql += " FROM " + RetSqlName("TFL") + " TFL "
cSql += " INNER JOIN " + RetSqlName("CNA") + " CNA ON "
cSql += " CNA.CNA_NUMERO = TFL.TFL_PLAN AND "
cSql += " CNA.CNA_CONTRA = TFL.TFL_CONTRT AND "
cSql += " CNA.D_E_L_E_T_ = ' ' AND CNA.CNA_FILIAL = '" + xFilial("CNA") + "' "
cSql += " INNER JOIN " + RetSqlName("TFJ") + " TFJ ON "
cSql += " TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND "
cSql += " TFJ.D_E_L_E_T_ = ' ' AND TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
cSql += " INNER JOIN " + RetSqlName("TFF") + " TFF ON "
cSql += " TFF.TFF_CODPAI = TFL.TFL_CODIGO AND "
cSql += " TFF.TFF_FILIAL = TFL.TFL_FILIAL AND "
cSql += " TFF.D_E_L_E_T_ = ' ' "
cSql += " LEFT JOIN " + RetSqlName("TFH") + " TFH ON "
cSql += " TFH.TFH_CODPAI = TFF.TFF_COD AND "
cSql += " TFH.TFH_FILIAL = TFF.TFF_FILIAL AND "
cSql += " TFF.D_E_L_E_T_ = ' ' "
cSql += " LEFT JOIN " + RetSqlName("TFG") + " TFG ON "
cSql += " TFG.TFG_CODPAI = TFF.TFF_COD AND "
cSql += " TFG.TFG_FILIAL = TFF.TFF_FILIAL AND "
cSql += " TFF.D_E_L_E_T_ = ' ' "
cSql += " LEFT JOIN " + RetSqlName("TGT") + " TGT ON "
cSql += " ( "
cSql += " (TGT.TGT_TPITEM = 'TFF' AND TGT.TGT_CDITEM = TFF.TFF_COD) OR "
cSql += " (TGT.TGT_TPITEM = 'TFH' AND TGT.TGT_CDITEM = TFH.TFH_COD) OR "
cSql += " (TGT.TGT_TPITEM = 'TFG' AND TGT.TGT_CDITEM = TFG.TFG_COD) "
cSql += " ) AND "
cSql += " TGT.TGT_FILIAL = TFL.TFL_FILIAL AND "
cSql += " TGT.D_E_L_E_T_ = ' ' "
If !EMPTY(cCompet)
	cSql += " AND TGT.TGT_COMPET = '" + cCompet + "' "
EndIf
If lExcedente
	cSql += " AND TGT.TGT_EXCEDT != '1' "
EndIf
cSql += " WHERE "
cSql += " TFL.D_E_L_E_T_ = ' ' AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
cSql += " AND CNA.R_E_C_N_O_ = " + cValToChar(nRECCNA) + " AND "
cSql += " TFJ.TFJ_CNTREC = '1' AND TFL.TFL_CODSUB = '" + cSpaceTFL + "' "
cSql := ChangeQuery(cSql)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasAux, .F., .T.)
While !(cAliasAux)->(EOF())
	If !EMPTY(Alltrim(STRTRAN((cAliasAux)->TGT_COMPET,"/")))
		IF (nAux := ASCAN(aRet, {|a| a[1] == (cAliasAux)->TGT_COMPET})) == 0
			AADD(aRet , {(cAliasAux)->TGT_COMPET,;
							{{(cAliasAux)->TGT_VALOR,;
							(cAliasAux)->TGT_TPITEM,;
							(cAliasAux)->TGT_CDITEM}}})
		Else
			AADD( aRet[nAux][2], {(cAliasAux)->TGT_VALOR,;
							(cAliasAux)->TGT_TPITEM,;
							(cAliasAux)->TGT_CDITEM} )
		EndIf
	EndIf
	(cAliasAux)->(DbSkip())
End
(cAliasAux)->(dbCloseArea())

If !EMPTY(aRet)
	cSql := " SELECT TFF.TFF_COD, TFH.TFH_COD, TFG.TFG_COD, "
	cSql += " TFF.TFF_QTDVEN, TFF.TFF_PRCVEN, TFF.TFF_DESCON, TFF.TFF_TXLUCR, TFF.TFF_TXADM, "
	cSql += " TFG.TFG_QTDVEN, TFG.TFG_PRCVEN, TFG.TFG_DESCON, TFG.TFG_TXLUCR, TFG.TFG_TXADM, "
	cSql += " TFH.TFH_QTDVEN, TFH.TFH_PRCVEN, TFH.TFH_DESCON, TFH.TFH_TXLUCR, TFH.TFH_TXADM "
	cSql += " FROM " + RetSqlName("TFL") + " TFL "
	cSql += " INNER JOIN " + RetSqlName("CNA") + " CNA ON "
	cSql += " CNA.CNA_NUMERO = TFL.TFL_PLAN AND "
	cSql += " CNA.CNA_CONTRA = TFL.TFL_CONTRT AND "
	cSql += " CNA.D_E_L_E_T_ = ' ' AND CNA.CNA_FILIAL = '" + xFilial("CNA") + "' "
	cSql += " INNER JOIN " + RetSqlName("TFJ") + " TFJ ON "
	cSql += " TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND "
	cSql += " TFJ.D_E_L_E_T_ = ' ' AND TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
	cSql += " INNER JOIN " + RetSqlName("TFF") + " TFF ON "
	cSql += " TFF.TFF_CODPAI = TFL.TFL_CODIGO AND "
	cSql += " TFF.TFF_FILIAL = TFL.TFL_FILIAL AND "
	cSql += " TFF.D_E_L_E_T_ = ' ' "
	cSql += " LEFT JOIN " + RetSqlName("TFH") + " TFH ON "
	cSql += " TFH.TFH_CODPAI = TFF.TFF_COD AND "
	cSql += " TFH.TFH_FILIAL = TFF.TFF_FILIAL AND "
	cSql += " TFF.D_E_L_E_T_ = ' ' "
	cSql += " LEFT JOIN " + RetSqlName("TFG") + " TFG ON "
	cSql += " TFG.TFG_CODPAI = TFF.TFF_COD AND "
	cSql += " TFG.TFG_FILIAL = TFF.TFF_FILIAL AND "
	cSql += " TFF.D_E_L_E_T_ = ' ' "
	cSql += " WHERE "
	cSql += " TFL.D_E_L_E_T_ = ' ' AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
	cSql += " AND CNA.R_E_C_N_O_ = " + cValToChar(nRECCNA) + " AND "
	cSql += " TFJ.TFJ_CNTREC = '1' AND TFL.TFL_CODSUB = '" + cSpaceTFL + "' "
	cSql := ChangeQuery(cSql)
	cAliasAux := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasAux, .F., .T.)

	While !(cAliasAux)->(EOF())
		If !EMPTY((cAliasAux)->TFF_COD) .AND. (EMPTY(aJaProc) .OR. ASCAN(aJaProc, {|a| a[1] == 'TFF' .AND. a[2] == (cAliasAux)->TFF_COD}) == 0)
			AADD(aJaProc, {"TFF", (cAliasAux)->TFF_COD})
			For nX := 1 To LEN(aRet)
				If ASCAN(aRet[nX][2], {|a| a[2] == 'TFF' .AND. a[3] == (cAliasAux)->TFF_COD}) == 0
					AADD( aRet[nX][2] ,;
					{At740PrxPa(/*cTipo*/,;
					(cAliasAux)->TFF_QTDVEN,;
					(cAliasAux)->TFF_PRCVEN,;
					(cAliasAux)->TFF_DESCON,;
					(cAliasAux)->TFF_TXLUCR,;
					(cAliasAux)->TFF_TXADM),;
					"TFF",;
					(cAliasAux)->TFF_COD}) 
				EndIf
			Next nX
		EndIf
		If !EMPTY((cAliasAux)->TFH_COD) .AND. (EMPTY(aJaProc) .OR. ASCAN(aJaProc, {|a| a[1] == 'TFH' .AND. a[2] == (cAliasAux)->TFH_COD}) == 0)
			AADD(aJaProc, {"TFH", (cAliasAux)->TFH_COD})
			For nX := 1 To LEN(aRet)
				If ASCAN(aRet[nX][2], {|a| a[2] == 'TFH' .AND. a[3] == (cAliasAux)->TFH_COD}) == 0
					AADD( aRet[nX][2] ,;
					{At740PrxPa(/*cTipo*/,;
					(cAliasAux)->TFH_QTDVEN,;
					(cAliasAux)->TFH_PRCVEN,;
					(cAliasAux)->TFH_DESCON,;
					(cAliasAux)->TFH_TXLUCR,;
					(cAliasAux)->TFH_TXADM),;
					"TFH",;
					(cAliasAux)->TFH_COD}) 
				EndIf
			Next nX
		EndIf
		If !EMPTY((cAliasAux)->TFG_COD) .AND. (EMPTY(aJaProc) .OR. ASCAN(aJaProc, {|a| a[1] == 'TFG' .AND. a[2] == (cAliasAux)->TFG_COD}) == 0)
			AADD(aJaProc, {"TFG", (cAliasAux)->TFG_COD})
			For nX := 1 To LEN(aRet)
				If ASCAN(aRet[nX][2], {|a| a[2] == 'TFG' .AND. a[3] == (cAliasAux)->TFG_COD}) == 0
					AADD( aRet[nX][2] ,;
					{At740PrxPa(/*cTipo*/,;
					(cAliasAux)->TFG_QTDVEN,;
					(cAliasAux)->TFG_PRCVEN,;
					(cAliasAux)->TFG_DESCON,;
					(cAliasAux)->TFG_TXLUCR,;
					(cAliasAux)->TFG_TXADM),;
					"TFG",;
					(cAliasAux)->TFG_COD}) 
				EndIf
			Next nX
		EndIf
		(cAliasAux)->(DbSkip())
	End
	(cAliasAux)->(dbCloseArea())
EndIf
Return aRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} aT730PosTFP

@description Posiciona no registro da TFP para atualização do Saldo
@author Luiz Gabriel
@since  29/07/2021
/*/
//--------------------------------------------------------------------------------
Function aT730PosTFP(cFilTFP,cEntida,cCodLoc,cProdut,cFilLoc)
Local lRet 		:= .F.
Local cAliasTFP	:= GetNextAlias()
Local cQuery 	:= ""

cQuery += " SELECT TFP.R_E_C_N_O_ REC "
cQuery += " FROM " + RetSqlName("TFP") + " TFP "
cQuery += " WHERE TFP.TFP_FILIAL = '" + cFilTFP + "' "
cQuery += " AND TFP.TFP_ENTIDA = '" + cEntida + "' "
cQuery += " AND TFP.TFP_CODINT = '" + cCodLoc + "' "
cQuery += " AND TFP.TFP_PRODUT = '" + cProdut + "' "
If !Empty(cFilLoc)
	cQuery += " AND TFP.TFP_FILLOC = '" + cFilLoc + "' "
EndIf	
cQuery += " AND TFP.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTFP, .F., .T.)

If !((cAliasTFP)->(EOF()))
	lRet := .T.
	TFP->(DbGoTo((cAliasTFP)->REC))
EndIF
(cAliasTFP)->(dbCloseArea())

Return lRet
//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecBDt2Cmp

@description Converte uma Data em uma competência (DATA ---> STR)
@author Mateus Boiani
@since  25/08/2021
/*/
//--------------------------------------------------------------------------------
Function TecBDt2Cmp(dData)
Return (STRZERO(MONTH(dData),2)+"/"+cValToChar(YEAR(dData)))
//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecHasTGT

@description Verifica se uma TGT existe e retorna por referência o seu valor
@author Mateus Boiani
@since  25/08/2021
/*/
//--------------------------------------------------------------------------------
Function TecHasTGT(cTpItem,cCodItem,cCompet,cCodTFJ,nVal)
Local aArea := GetArea()
Local lRet := .F.
Local cSql := ""
Local cAliasAux := GetNextAlias()
Local lExcedente := TecBHasExc()

cSql += " SELECT TGT.TGT_VALOR FROM " + RetSqlName("TGT") + " TGT "
cSql += " WHERE TGT.D_E_L_E_T_ = ' ' AND "
cSql += " TGT.TGT_TPITEM = '"+cTpItem+"' AND "
cSql += " TGT.TGT_CDITEM = '"+cCodItem+"' AND "
cSql += " TGT.TGT_COMPET = '"+cCompet+"' AND "
cSql += " TGT.TGT_CODTFJ = '"+ cCodTFJ + "' "
If lExcedente
	cSql += " AND TGT.TGT_EXCEDT != '1' "
EndIf
cSql := ChangeQuery(cSql)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasAux, .F., .T.)

If !(cAliasAux)->(EOF())
	lRet := .T.
	nVal := (cAliasAux)->TGT_VALOR
EndIf
(cAliasAux)->(DbCloseArea())

RestArea(aArea)
Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECBLimp
@description Função para limpar o array aAtendVer
@author Augusto Albuquerque
@since  28/09/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECBLimp()
aAtendVer := {}
Return
//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecBHasExc

@description Retorna se a base de dados possui o campo TGT_EXCEDT
@author Mateus Boiani
@since  08/10/2021
/*/
//--------------------------------------------------------------------------------
Function TecBHasExc()

Return TecBHasCrn() .AND. (TGT->(ColumnPos('TGT_EXCEDT')) > 0)
//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecBHasTpA

@description Retorna se a base de dados possui o campo TFV_TIPO
@author Mateus Boiani
@since  11/10/2021
/*/
//--------------------------------------------------------------------------------
Function TecBHasTpA()

Return (TFV->(ColumnPos('TFV_TIPO')) > 0)
//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecBHasBrT

@description Retorna se a base de dados possui o campo ABR_CODTFV
@author Natacha Romeiro
@since  22/10/2021
/*/
//--------------------------------------------------------------------------------
Function TecBHasBrT()

Return (ABR->(ColumnPos('ABR_CODTFV')) > 0)

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecBHasBrT

@description Retorna se é de automação TIR
@author Augusto Albuquerque
@since  05/11/2021
/*/
//--------------------------------------------------------------------------------
Function TecBisTir()

Return __cUserId == "000000" .AND. cEmpAnt  == "T1" .AND. cfilant == "D MG 01 " .AND. GetRpoRelease() == "12.1.033"

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecExecNPS

@description verifica se o ambiente esta preparado para abria a tela em po-ui de NPS
@author Augusto Albuquerque
@since  15/12/2021
/*/
//--------------------------------------------------------------------------------
Function TecExecNPS()
Local oGsNps    := Nil

If (!EMPTY(GetApoInfo("tecnps.app")) .AND. (GetBuild() >= "7.00.170117A-20190628")  .AND.  ( SuperGetMv("MV_GSNPS",,.T.) .AND.;
	(FindFunction("CanUseWebUI") .AND. CanUseWebUI()) .AND.;
	( FindFunction("TecNPS") .AND. !EMPTY(GetApoInfo("TECNPS.prw")) .AND. !EMPTY(GetApoInfo("TecGsNPS.prw")) ) ))

	oGsNps := GsNps():New()

	/*
	Caso for realizar algum teste no envio de NPS por favor comentar a linha: oGsNps:setProductName("PrestServTerc") e descomentar a linha oGsNps:setProductName("Tercerização")
	*/
	
	//oGsNps:setProductName("Tercerização") // Utilizado para teste
	oGsNps:setProductName("PrestServTerc") //Envio do cliente

	If ((cEmpAnt  == "T1" .AND. cfilant == "D MG 01 ") .OR. cEmpAnt $ "99|98|97") .OR. oGsNps:canSendAnswer()
		DEFINE MSDIALOG oDlg FROM 0,0 TO 33, 120 TITLE "NPS" Style 128
					
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( TecNPS( oDlg ) )
	EndIf
EndIf

Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TECTelMets

@description Função para envio de telemetria
@author Augusto Albuquerque
@since  15/12/2021
/*/
//--------------------------------------------------------------------------------
Function TECTelMets( cSubRotine, cIdMetric, nValue, dDateSend, nLapTime, cRotina )
Default cSubRotine	:= ""
Default cIdMetric	:= ""
Default nValue		:= 1
Default dDateSend	:= Nil
Default nLapTime	:= Nil
Default cRotina		:= Nil

If !EMPTY(GetApoInfo("FWCUSTOMMETRICS.TLPP")) .AND. (!Empty(cSubRotine) .AND. !Empty(cIdMetric))
	FwCustomMetrics():setSumMetric(cSubRotine, cIdMetric, nValue, dDateSend, nLapTime, cRotina)
EndIf
Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TECAAWHiPV

@description Função que verifica se tem a tabela AAW
@author Augusto Albuquerque
@since  13/01/2022
/*/
//--------------------------------------------------------------------------------
Function TECAAWHiPV()
Return TableInDic("AAW")

//------------------------------------------------------------------------------
/*/{Protheus.doc} At160HstBs

@description Verifica se possui os campos da base operacional configurado
@author	Kaique Schiller
@since	24/12/2021
/*/
//------------------------------------------------------------------------------
Function TecBaseOp()
Local aArea	:= GetArea()
Local lRet 	:= .F.

If TableInDic("AA0")
	DbSelectArea("AA0")
	If AA0->( ColumnPos('AA0_CODIGO') ) > 0 .And.;
		AA0->( ColumnPos('AA0_DESCRI') ) > 0 .And.;
		 AA0->( ColumnPos('AA0_LOCPAD') ) > 0 .And.;
		  AA0->( ColumnPos('AA0_CCUSTO') ) > 0 .And.;
		   AA0->( ColumnPos('AA0_ITEM') ) > 0 .And.;
		    AA0->( ColumnPos('AA0_CLVL') ) > 0
		lRet := .T.
	Endif
Endif

RestArea( aArea )
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecConfCCT

@description Verifica se possui os campos da CCT e se parametro está configurado
@author	Luiz Gabriel
@since	28/06/2022
/*/
//------------------------------------------------------------------------------
Function TecConfCCT()
Local aArea	:= GetArea()
Local lRet 	:= .F.

If TableInDic("REI") .And. TableInDic("SWY") .And. TableInDic("RI4") 
	If SuperGetMV("MV_TECXRH",,".F.")
		DbSelectArea("SP8")
		If SP8->( ColumnPos('P8_FILCCT') ) > 0 .And.;
			SP8->( ColumnPos('P8_CODCCT') ) > 0
			lRet := .T.
		Endif
	EndIf 
Endif

RestArea( aArea )
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecAprovOp

@description Verifica se possui os campos e o parametro para aprovação operacional
@author	Luiz Gabriel
@since	09/02/2022
/*/
//------------------------------------------------------------------------------
Function TecAprovOp()
Local lParamAprov	:= SuperGetMv("MV_GSAPROV",,"2") == "1"
Local lRet 			:= .F.
	
DbSelectArea("TFJ")
If TFJ->( ColumnPos('TFJ_APRVOP') ) > 0 .And.;
	TFJ->( ColumnPos('TFJ_USAPRO') ) > 0 .And.;
	TFJ->( ColumnPos('TFJ_DTAPRO') ) > 0 .And. lParamAprov
	lRet := .T.
Endif

Return lRet

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} At850Trava
    Verifica se o contrato pode ser alterado
    @type  Function
    @author Luiz Gabriel
    @since 09/02/2022
    @version 12
    @return lRet, Logico, Verifica se pode ser alterado
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function TecAprTrav(cFilTFJ,cCodTFJ)
   Local lCampos    := TecAprovOp()
   Local aAreaTFJ	:= TFJ->(GetArea())
   Local lRet       := .T.

   If lCampos .And. !Empty(cCodTFJ) .And. TFJ->(MSSeek(cFilTFJ+cCodTFJ) )
        If TFJ->TFJ_APRVOP == "2"
			Help(NIL,NIL,"TecAprTrav",NIL,STR0118,1,0,NIL,NIL,NIL,NIL,NIL,{STR0119}) //"Contrato pendente de aprovação operacional"##"Realize a aprovação operacional do contrato"
            lRet := .F.
        EndIf 
   EndIf  

   RestArea(aAreaTFJ)

Return lRet

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} TecGsMdZer
    Verifica se existe alocação no período do posto para medição automática ficar com o valor zerado
    @author Kaique Schiller
    @since 30/03/2022
    @return lRetZero, Logico, Verifica ser pode ser zerado
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function TecGsMdZer(cContra, cRevisa, cPlan, cItCNB, lAuto, cCompet, laMedZero, lLimpArray )
Local lRetZero	:= .F.
Local dDtIni 	:= sTod("")
Local dDtFim 	:= sTod("")
Local cAliasAux := ""
Local nPosZer	:= 0
Local cWhere	:= ""
Default cContra := ""
Default cRevisa := ""
Default cPlan := ""
Default cItCNB := ""
Default lAuto := IsInCallStack("CN260Exc")
Default cCompet := ""
Default laMedZero := .F.
Default lLimpArray := .F.

If !laMedZero
	If !Empty(cContra) .And. lAuto .And. !Empty(cCompet)
		If !Empty(cPlan)
			cWhere := " AND TFL.TFL_PLAN = '"+cPlan+"' "
		Endif
		cWhere := "%"+cWhere+"%"
		dDtIni := cTod("01/"+cCompet)
		dDtFim := LastDate(cTod("01/"+cCompet))
		cAliasAux := GetNextAlias()
		BeginSql Alias cAliasAux
			COLUMN TDV_DTREF AS DATE
			SELECT TFL_PLAN, TFF_ITCNB
			FROM %table:TFF% TFF
			INNER JOIN %table:TFL% TFL ON TFL.TFL_CODIGO = TFF.TFF_CODPAI
				AND	TFL.%notDel% 
				AND TFL.TFL_FILIAL  = %xfilial:TFL%
			INNER JOIN %table:TFJ% TFJ ON TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
				AND TFJ.%notDel%
				AND TFJ.TFJ_FILIAL  = %xfilial:TFJ%
			INNER JOIN %table:ABQ% ABQ ON ABQ.ABQ_FILIAL = %xFilial:ABQ%
				AND ABQ.ABQ_CODTFF = TFF.TFF_COD
			INNER JOIN %table:ABB% ABB ON ABB.ABB_FILIAL = %xFilial:ABB%
				AND ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM
			INNER JOIN  %table:TDV% TDV ON TDV.TDV_FILIAL = %xFilial:TDV%
				AND TDV.TDV_CODABB = ABB.ABB_CODIGO
			WHERE TFF.%notDel%
				%exp:cWhere%
				AND TFF.TFF_CONTRT = %exp:cContra%
				AND TFF.TFF_CONREV = %exp:cRevisa%
				AND TFF.TFF_FILIAL = %xfilial:TFF%
				AND TFJ.TFJ_STATUS = '1'
				AND ABB.ABB_ATIVO = '1'
				AND TDV.TDV_DTREF BETWEEN %Exp:dDtIni% AND %Exp:dDtFim%
			GROUP BY TFL_PLAN, TFF_ITCNB
		EndSql

		//Não existe alocação para o contrato no período da competência.
		If (cAliasAux)->(Eof())
			lRetZero := .T.
		Endif

		If aScan( aExistAloc, { |a| a[1] == cContra .AND. a[2] == cRevisa ;
													.AND. a[3] == cCompet .AND. a[4] == cPlan }) == 0
			//Adiciona o contrato e a revisão
			aAdd(aExistAloc,{cContra,cRevisa,cCompet,cPlan,{}})
			While !(cAliasAux)->(Eof())
				//Adiciona os itens que existe alocação no período
				aAdd(aExistAloc[Len(aExistAloc)][5],{(cAliasAux)->TFL_PLAN,(cAliasAux)->TFF_ITCNB})
				(cAliasAux)->(DbSkip())
			EnDdo
		Endif
		(cAliasAux)->(DbCloseArea())
	Endif
Else
	nPosZer := aScan( aExistAloc, { |a| a[1] == cContra .AND. a[2] == cRevisa ;
										  			    .AND. a[3] == cCompet ;
														.AND. (Empty(a[4]) .OR. a[4] == cPlan) })
	If nPosZer > 0
		//Se o posto não tem alocação no período, realiza a medição zerada
		If aScan( aExistAloc[nPosZer,5], { |a| a[1] == cPlan .AND. a[2] == cItCNB }) == 0
			lRetZero := .T.
		Endif
	Endif
Endif

If lLimpArray
	aExistAloc := {}
Endif

Return lRetZero

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} TecGsMvZer
    Verifica se existe os parâmetros para realizar a medição zerada.
    @author Kaique Schiller
    @since 30/03/2022
    @return Logico, Verifica se existe o parâmetro MV_GSMDZER
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function TecGsMvZer()
Return  SuperGetMv("MV_GSMDZER",,"2") == "1" .And. !(SuperGetMv("MV_GSDSGCN",,"2") == "2") .And. !(SuperGetMv("MV_ORCPRC",,.F.))

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} TecGsUnif
    Verifica se existe a tabela de uniformes para o orçamento
    @author Kaique Schiller
    @since 07/06/2022
    @return Logico, Verifica se existe a tabela de uniformes TXP
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function TecGsUnif()
Local lRet := .F.

If !(SuperGetMv("MV_ORCPRC",,.F.))
	If TableInDic("TXP")
		lRet := .T.
	Endif
Endif

Return lRet

/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} TecGsArma
    Verifica se existe a tabela de armamentos para o orçamento
    @author Kaique Schiller
    @since 22/06/2022
    @return Logico, Verifica se existe a tabela de uniformes TXQ
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function TecGsArma()
Local lRet := .F.

If !(SuperGetMv("MV_ORCPRC",,.F.))
	If TableInDic("TXQ")
		lRet := .T.
	Endif
Endif

Return lRet
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
{Protheus.doc} TecGsPrecf
    Verifica se existe as tabelas de precificação
    @author Kaique Schiller
    @since 22/06/2022
    @return Logico, Verifica se existe a tabela de precificação TXR, TXS, TXT, TXU, TXV e TXW
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function TecGsPrecf()
Local lRet := .F.

If !(SuperGetMv("MV_ORCPRC",,.F.))
	If TableInDic("TXR") .And. TableInDic("TXS") .And.;
	   TableInDic("TXT") .And. TableInDic("TXU") .And.; 
	   TableInDic("TXV") .And. TableInDic("TXW")
		lRet := .T.
	Endif
Endif

Return lRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecConsF3

@description Consulta Especifica
@param  cCpoF3, String, Campo da consulta F3
@return lRet, boolean, retorno da consulta
@author Flavio Vicco
@since  04/07/2022
/*/
//--------------------------------------------------------------------------------
Function TecConsF3(cCpoF3)

Local nSuperior   := 0
Local nEsquerda   := 0
Local nInferior   := 0
Local nDireita    := 0
Local cTitle      := ""
Local cAlias      := ""
Local cField      := ""
Local cQry        := ""
Local cFilCont    := ""
Local cContrat    := ""
Local cRetF3_1    := ""
Local cRetF3_2    := ""
Local cProfID     := "" //Indica o ID do browse para recuperar as informações do usuario
Local cTipo       := ""
Local aIndex      := {}
Local aSeek       := {}
Local aColumns    := {}
Local aCampos     := {}
Local oView       := FwViewActive()
Local lTECA894    := oView:IsActive() .And. oView:GetModel():GetId()=="TECA894"
Local lRet        := .T.
Local oBrowse     := Nil
Local oDlgEscTela := Nil
Local lAutomato   := IsBlind()
Local bConfirma   := '{|| cRetF3 := (oBrowse:Alias())->&cField, lRet := .T., oDlgEscTela:End() }'
Local bCancelar   := '{|| lRet := .F., oDlgEscTela:End() }'
Local cPosto 	  := ""
Local cRetF3_3    := ""

Default cCpoF3    := ReadVar()

cTipo := Replace(cCpoF3,"M->","") // Retira prefixo

// Gestao de Uniformes: Tratamento dos campos Filial/Contrato/Posto de trabalho
If lTECA894
	cFilCont := FwFldGet("TXD_FILTFF")
	If cTipo $ "TXD_POSTO"
		cContrat := FwFldGet("TXD_CONTRT")
		cPosto   := FwFldGet("TXD_POSTO")  
	ElseIf cTipo $ "TXD_CODPRO"
		cContrat := FwFldGet("TXD_CONTRT")
		cPosto   := FwFldGet("TXD_POSTO")
	EndIf
	cQry := TecGetQry(cTipo, cFilCont, cContrat, cPosto)
EndIf

If cTipo $ "TXD_CONTRT"

	cTitle := STR0120 //"Contratos"
	cAlias := cTipo
	cField := "CN9_NUMERO"

	// Necessario para criação de um ID para cada browse
	cProfID := "C" + Left( cTipo,3)

	bConfirma := '{|| cRetF3 := (oBrowse:Alias())->&cField, cRetF3_1 :=(oBrowse:Alias())->CN9_FILIAL, lRet := .T., oDlgEscTela:End() }'
	bcancelar := '{|| cRetF3 := "", cRetF3_1 := "", cRetF3_2 := "", lRet := .F., oDlgEscTela:End() }'

	aCampos := { "CN9_FILIAL", "CN9_NUMERO", "CN9_REVISA", "TFJ_CODENT", "TFJ_LOJA", "A1_NOME", "CN9_DTINIC", "CN9_DTFIM" }

	Aadd( aSeek, { STR0123, {{"","C",TamSX3("CN9_NUMERO")[1],0,STR0123,,"CN9_NUMERO"}} } ) //"Número do Contrato"
	Aadd( aSeek, { STR0124, {{"","C",TamSX3("CN9_REVISA")[1],0,STR0124,,"CN9_REVISA"}} } ) //"Revisão"
	Aadd( aSeek, { STR0125, {{"","C",TamSX3("TFJ_CODENT")[1],0,STR0125,,"TFJ_CODENT"}} } ) //"Cliente"
	Aadd( aSeek, { STR0126, {{"","C",TamSX3("TFJ_LOJA"  )[1],0,STR0126,,"TFJ_LOJA"  }} } ) //"Loja"
	Aadd( aSeek, { STR0127, {{"","C",TamSX3("A1_NOME"   )[1],0,STR0127,,"A1_NOME"   }} } ) //"Nome"
	
	Aadd( aIndex, "CN9_NUMERO" )
	Aadd( aIndex, "CN9_REVISA" )
	Aadd( aIndex, "TFJ_CODENT" )
	Aadd( aIndex, "TFJ_LOJA" )
	Aadd( aIndex, "A1_NOME" )
	Aadd( aIndex, "CN9_FILIAL") // adicionado para não ter problema de não encontrar o último índice, em caso de adicionar mais deixe a filial por último

ElseIf cTipo $ "TXD_POSTO"

	cTitle := STR0121 //"Posto de Trabalho"
	cAlias := cTipo
	cField := "TFF_COD"

	// Necessario para criação de um ID para cada browse
	cProfID := "P" + Left( cTipo,3)

	bConfirma := '{|| cRetF3 := (oBrowse:Alias())->&cField, cRetF3_1 :=(oBrowse:Alias())->TFF_FILIAL, cRetF3_2 :=(oBrowse:Alias())->TFF_CONTRT, lRet := .T., oDlgEscTela:End() }'
	bcancelar := '{|| cRetF3 := "", cRetF3_1 := "", cRetF3_2 := "", lRet := .F., oDlgEscTela:End() }'

	aCampos := { "TFF_FILIAL", "TFF_CONTRT","TFF_CONREV", "TFF_COD"}

ElseIf  cTipo $ "TXD_CODPRO"

	cTitle := STR0122 //"Uniformes"
	cAlias := cTipo
	cField := "B1_COD"

	// Necessario para criação de um ID para cada browse
	cProfID := "U" + Left( cTipo,3)

	bConfirma := '{|| cRetF3 := (oBrowse:Alias())->&cField, cRetF3_1 :=(oBrowse:Alias())->TFF_FILIAL, cRetF3_2 :=(oBrowse:Alias())->TFF_CONTRT, cRetF3_3 :=(oBrowse:Alias())->TFF_COD, lRet := .T., oDlgEscTela:End() }'
	bcancelar := '{|| cRetF3 := "", cRetF3_1 := "", cRetF3_2 := "", lRet := .F., oDlgEscTela:End() }'

	aCampos := { "TFF_FILIAL","TXP_CODUNI", "B1_DESC", "TFF_CONTRT", "TFF_CONREV", "TFF_COD" }

	Aadd( aSeek, { STR0130, {{"","C",TamSX3("B1_COD")[1] ,0,STR0130 ,,"B1_COD" }}}) //"Código"
	Aadd( aSeek, { STR0131, {{"","C",TamSX3("B1_DESC")[1],0,STR0131 ,,"B1_DESC"}}}) //"Descrição"

	Aadd( aIndex, "B1_COD"   )
	Aadd( aIndex, "B1_DESC"  )
	Aadd( aIndex, "B1_FILIAL") // adicionado para não ter problema de não encontrar o último índice, em caso de adicionar mais deixe a filial por último

EndIf

If !lAutomato .And. !EMPTY(cQry)

	lRet      := .F.
	nSuperior := 0
	nEsquerda := 0
	nInferior := GetScreenRes()[2] * 0.6
	nDireita  := GetScreenRes()[1] * 0.65

	DEFINE MSDIALOG oDlgEscTela TITLE OemToAnsi(cTitle) FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL
	
	oBrowse:=FWFormBrowse():New()
	oBrowse:SetOwner(oDlgEscTela)
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetAlias(cAlias)
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetQuery(cQry)
	oBrowse:SetSeek(,aSeek)
	oBrowse:SetDescription(cTitle)
	oBrowse:SetMenuDef("")
	oBrowse:DisableDetails()
	oBrowse:SetProfileID(cProfID)
	TECSetFlt(aSeek, @oBrowse)
	aColumns := TecColsF3(aCampos, @oBrowse)
	oBrowse:SetColumns(aColumns)
	oBrowse:SetDoubleClick(&bConfirma)
	oBrowse:AddButton( OemToAnsi(STR0116), &bConfirma ,, 2 ) //"Confirmar"
	oBrowse:AddButton( OemToAnsi(STR0117), &bCancelar ,, 2 ) //"Cancelar"
	oBrowse:Activate()

	ACTIVATE MSDIALOG oDlgEscTela CENTERED

	If lRet
		// Gestao de Uniformes: Tratamento para preencher campos Filial/Contrato/Posto de trabalho
		If lTECA894
			If cTipo $ "TXD_CONTRT|TXD_POSTO|TXD_CODPRO" .And. EMPTY(cFilCont)
				FWFldPut("TXD_FILTFF",cRetF3_1)
				oView:Refresh()
			EndIf
			If EMPTY(cContrat)
				FWFldPut("TXD_CONTRT",cRetF3_2)
				oView:Refresh()
			EndIf
			If EMPTY(cPosto)
				FWFldPut("TXD_POSTO",cRetF3_3)
				oView:Refresh()
			EndIf
		EndIf
	EndIf
EndIf

Return(lRet)

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TECRetF3

@description Retorno da Consulta Especifica
@author Flavio Vicco
@since  04/07/2022
/*/
//--------------------------------------------------------------------------------
Function TECRetF3()

Return(cRetF3)

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TECSetFlt

@description Cria os filtros nas consultas padrões
@param  aSeek, Array, Campos de esquisas
@param oBrowse, Objeto, Browse pesquisa
@author Flavio Vicco
@since  04/07/2022
/*/
//--------------------------------------------------------------------------------
Static Function TECSetFlt(aSeek, oBrowse)

Local aFilter := {}
Local nC      := 0

For nC := 1 to Len(aSeek)
	If Len(aSeek[nC]) >= 2 .and. Len(aSeek[nC, 02]) == 1 .AND.  Len(aSeek[nC, 02, 01]) >= 7 .and. !Empty(aSeek[nC, 02, 01 ,07])
		If aScan(aFilter, {|f| f[1] == aSeek[nC, 02, 01, 07]}) == 0
			aAdd(aFilter, {aSeek[nC, 02, 01, 07], aSeek[nC, 02,01, 05], aSeek[nC, 02,01, 02], aSeek[nC, 02,01, 03], aSeek[nC, 02,01, 04], IIF(Empty(aSeek[nC, 02,01, 06]), "", aSeek[nC, 02, 01, 06])})
		EndIf
	EndIf
Next nC 

If Len(aFilter) > 0
	oBrowse:SetTemporary(.T.)
	oBrowse:SetDBFFilter(.T.)
	oBrowse:SetFilterDefault("") 
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetFieldFilter(aFilter)
EndIf

Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecColsF3

@description Tratamento dos campos que serão exibidos na tela
@param aFields, Array, Campos da consulta
@param oBrowse, Objeto, Browse pesquisa
@return aColumns, Array, Colunas da tela de consulta
@author Flavio Vicco
@since  04/07/2022
/*/
//--------------------------------------------------------------------------------
Static Function TecColsF3(aFields, oBrowse)

Local aColumns := {}
Local aFwTam   := {}
Local cField   := ""
Local nLinha   := 0
Local nZ       := 0

For nZ := 1 To Len(aFields)
	cField := aFields[nZ]
	aFwTam := FWTamSX3(cField)
	AAdd(aColumns,FWBrwColumn():New())
	nLinha := Len(aColumns)
   	aColumns[nLinha]:SetType(aFwTam[3])
   	aColumns[nLinha]:SetTitle(TecTituDes(cField,.T.))
	aColumns[nLinha]:SetSize(aFwTam[1])
	aColumns[nLinha]:SetDecimal(aFwTam[2])
	aColumns[nLinha]:SetPicture("@!")
	If aFwTam[3] == "D"
		aColumns[nLinha]:SetData(&("{|| sTod(" + cField + ")}"))
	Else
		aColumns[nLinha]:SetData(&("{||" + cField + "}"))
	EndIf
Next nZ

Return(aColumns)

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TecGetQry

@description Consultas SQL usada na Consulta de Contratos
@param cTipo, String, Campos da consulta
@param cFilCont, String, Filial selecionado
@param cContrat, String, Contrato selecionado
@return cQry, String, Consulta SQL
@author Flavio Vicco
@since  04/07/2022
/*/
//--------------------------------------------------------------------------------
Function TecGetQry(cTipo,cFilCont,cContrat,cPosto,cCodProd,cCodTec)

Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
Local aTpUnif     := StrTokArr(SuperGetMV('MV_TPUNIF',,'UN;'),';') // TIPOS DE PRODUTO CORRESPONDENTE AOS UNIFORMES
Local cSpcCTR     := Space(FwTamSx3("CN9_NUMERO")[1])
Local cTpProd     := ""
Local cQry        := ""
Local nZ          := 0
Local cRevisao    := ""

Default cTipo    := ""
Default cFilCont := ""
Default cContrat := ""
Default cPosto   := ""
Default cCodProd := ""
Default cCodTec  := ""

If cTipo $ "TXD_CONTRT"

	cQry := " SELECT DISTINCT CN9_FILIAL, CN9.CN9_NUMERO, CN9.CN9_REVISA, TFJ.TFJ_CODENT, TFJ.TFJ_LOJA, SA1.A1_NOME, CN9.CN9_DTINIC, CN9.CN9_DTFIM "
	cQry += " FROM " + RetSqlName("CN9") + " CN9 "
	// Orcamentos
	cQry += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
	cQry += " ON TFJ.D_E_L_E_T_ = ' ' "
	If !Empty(cFilCont)
		cQry += " AND TFJ.TFJ_FILIAL = '" + xFilial("TFJ",cFilCont) + "' "
	Else
		cQry += " AND "+FWJoinFilial("TFJ", "CN9", "TFJ", "CN9", .T.)
	Endif
	cQry += " AND TFJ.TFJ_CONTRT = CN9.CN9_NUMERO "
	cQry += " AND TFJ.TFJ_CONREV = CN9.CN9_REVISA "
	cQry += " AND TFJ.TFJ_STATUS = '1' " // 1-Ativo
	// Clientes
	cQry += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
	cQry += " ON SA1.D_E_L_E_T_ = ' ' "
	If !Empty(cFilCont) .And. !lMV_MultFil
		cQry += " AND SA1.A1_FILIAL = '" + xFilial("SA1",cFilCont) + "' "
	Else
		cQry += " AND "+FWJoinFilial("SA1", "TFJ", "SA1", "TFJ", .T.)
	Endif
	cQry += " AND SA1.A1_COD  = TFJ.TFJ_CODENT "
	cQry += " AND SA1.A1_LOJA = TFJ.TFJ_LOJA "
	// Filtrar Filial do Contrato
	cQry += " WHERE "
	If !Empty(cFilCont) .And. !lMV_MultFil
		cQry += " CN9.CN9_FILIAL = '" + xFilial("CN9",cFilCont) + "' AND "
	EndIf
	If !Empty(cContrat)
		cRevisao := Posicione("CN9",7,xFilial("CN9")+cContrat+"05","CN9_REVISA")
		cQry += " CN9.CN9_NUMERO = '" + cContrat + "' AND "
		cQry += " CN9.CN9_REVISA = '" + cRevisao + "' AND "
	EndIf
	cQry += " CN9.D_E_L_E_T_ = ' ' "
	// Buscar somente Contratos com Uniformes.
	cQry += " AND EXISTS "
	cQry += " (SELECT 1 FROM " + RetSqlName("TXP") + " TXP "
	cQry += " INNER JOIN " + RetSqlName("TFF") + " TFF ON "
	If !Empty(cFilCont) .And. !lMV_MultFil
		cQry += " TFF_FILIAL='" + xFilial("TFF",cFilCont) + "' AND "
	Else
		cQry += FWJoinFilial("TFF", "TXP", "TFF", "TXP", .T.) + " AND "
	EndIf
	cQry += " TFF.TFF_COD=TXP.TXP_CODTFF AND TFF.TFF_CONTRT=CN9.CN9_NUMERO AND TFF.TFF_CONREV=CN9.CN9_REVISA AND TFF.D_E_L_E_T_ = ' ' "
	cQry += " WHERE TXP.D_E_L_E_T_ = ' ' "
	If !Empty(cFilCont) .And. !lMV_MultFil
		cQry += " AND TXP.TXP_FILIAL='" + xFilial("TXP",cFilCont) + "' "
	Else
		cQry += " AND "+FWJoinFilial("TXP", "CN9", "TXP", "CN9", .T.)
	EndIf
	cQry += " ) "
	// Ordernar Orcamentos
	cQry += " ORDER BY CN9.CN9_FILIAL, CN9.CN9_NUMERO"

ElseIf cTipo $ "TXD_POSTO"

	cQry := "  SELECT  DISTINCT TFF.TFF_FILIAL, TFF.TFF_CONTRT, TFF.TFF_CONREV,TFF.TFF_COD "
	cQry +=  " FROM "+RetSqlname("TFF")+" TFF "
	cQry +=  " INNER JOIN "+RetSqlname("TXP")+" TXP ON TXP_CODTFF = TFF_COD
	cQry +=  " WHERE TFF.D_E_L_E_T_ = '' " 
	If !Empty(cContrat)
		cRevisao := Posicione("CN9",7,xFilial("CN9")+cContrat+"05","CN9_REVISA")
		cQry += " AND TFF.TFF_CONTRT = '" + cContrat + "' "
		cQry += " AND TFF.TFF_CONREV = '" + cRevisao + "' "
	Endif	 
	cQry +=  " AND TXP.D_E_L_E_T_ = '' AND TFF.D_E_L_E_T_ = '' "
	cQry +=  " AND TFF_CONTRT <> '' "
	cQry +=  " AND TFF_FILIAL = '"+xFilial("TFF")+"'
	If !Empty(cFilCont) .And. !lMV_MultFil
		cQry += " AND TXP.TXP_FILIAL='" + xFilial("TXP",cFilCont) + "' "
	Else
		cQry += " AND "+FWJoinFilial("TXP", "TFF", "TXP", "TFF", .T.)
	EndIf
	If !EMPTY(cPosto)
		cQry += " AND TFF.TFF_COD = '" + cPosto + "'"
	EndIf
	cQry +=  " ORDER BY TFF.TFF_COD"	

ElseIf  cTipo $ "TXD_CODPRO"

	// Concatena os tipos de uniformes para adicionar na query
	If Len(aTpUnif) == 1
		cTpProd := "In('" + aTpUnif[1] + "')
	Else
		For nZ := 1 to Len(aTpUnif)
			//Monta o Range com os tipos de uniforme
			If nZ == Len(aTpUnif)
				cTpProd += ",'" + aTpUnif[nZ] + "')
			ElseIf !Empty(cTpProd)
				cTpProd += ",'" + aTpUnif[nZ] + "'
			Else
				cTpProd := "In('" + aTpUnif[nZ] + "'
			EndIf
		Next nY
	EndIf

	cQry := " SELECT TFF.TFF_FILIAL, TFF.TFF_CONTRT, TFF.TFF_CONREV, TFF.TFF_QTDVEN, TFF.TFF_COD, TFF.TFF_PRODUT, TXP.TXP_CODUNI, SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_DESC "
	cQry += " FROM " + RetSqlName("SB1") + " SB1"
	// Gestao de Uniforme
	cQry += " INNER JOIN " + RetSqlName("TXP") + " TXP "
	cQry += " ON TXP.D_E_L_E_T_=' ' "
	If !EMPTY(cFilCont) .And. !lMV_MultFil
		cQry += " AND TXP.TXP_FILIAL='" + xFilial("TXP",cFilCont) + "' "
	Else
		cQry += " AND "+FWJoinFilial("TXP", "SB1", "TXP", "SB1", .T.)
	EndIf
	cQry += " AND TXP.TXP_CODUNI=SB1.B1_COD "
	// Recursos Humanos
	cQry += " INNER JOIN " + RetSqlName("TFF") + " TFF "
	cQry += " ON TFF.D_E_L_E_T_=' ' "
	If !EMPTY(cFilCont) .And. !lMV_MultFil
		cQry += " AND TFF.TFF_FILIAL='" + xFilial("TFF",cFilCont) + "' "
	Else
		cQry += " AND "+FWJoinFilial("TFF", "TXP", "TFF", "TXP", .T.)
	EndIf
	cQry += " AND TFF.TFF_COD=TXP.TXP_CODTFF "
	If !EMPTY(cContrat)
		cRevisao := Posicione("CN9",7,xFilial("CN9")+cContrat+"05","CN9_REVISA")
		cQry += " AND TFF.TFF_CONTRT = '" + cContrat + "' "
		cQry += " AND TFF.TFF_CONREV = '" + cRevisao + "' "
	Else
		cQry += " AND TFF.TFF_CONTRT<>'" + cSpcCTR + "'"
	EndIf
	If !EMPTY(cPosto)
		cQry += " AND TFF.TFF_COD ='" + cPosto + "'"
	EndIf
	// Filtrar Filial dos Uniformes
	cQry += " WHERE SB1.D_E_L_E_T_ = ' ' "
	If !EMPTY(cFilCont) .And. !lMV_MultFil
		cQry += "AND SB1.B1_FILIAL = '" + xFilial('SB1',cFilCont) + "' "
	EndIf
	cQry += " AND SB1.B1_TIPO " + cTpProd
	If !Empty(cCodProd)
		cQry += " AND SB1.B1_COD = '" + cCodProd + "' "
	EndIf
	// Necessário utilizar FieldPos, pois o campo de bloqueio de registro é opcional para o cliente.
	If SB1->(ColumnPos('B1_MSBLQL')) > 0
		cQry += " AND SB1.B1_MSBLQL <> '1'"
	EndIf
	// Ordernar Orcamentos/Produtos
	cQry += " ORDER BY TFF.TFF_FILIAL, TFF.TFF_CONTRT, SB1.B1_COD"

ElseIf cTipo $ "TXD_QTDE"

	cQry := " SELECT TXP.TXP_CODIGO, TXP.TXP_QTDVEN AS TOTAL_QTDVEN, "
	cQry += " COALESCE((SELECT SUM(TXD.TXD_QTDE-TXD.TXD_DEVOL) "
	cQry += " FROM " + RetSqlName("TXD") + " TXD " 
	cQry += " WHERE TXD.D_E_L_E_T_=' ' "
	If !Empty(cFilCont) .And. !lMV_MultFil
		cQry += " AND TXD.TXD_FILIAL = '" + cFilCont + "'"
	Else
		cQry += " AND "+FWJoinFilial("TXD", "TXP", "TXD", "TXP", .T.)
	EndIf
	cQry += " AND TXD.TXD_CODTXP=TXP_CODIGO AND TXD.TXD_CODTEC<>'"+cCodTec+"'),0) AS TOTENT
	cQry += " FROM " + RetSqlName("TXP") + " TXP "
	cQry += " INNER JOIN " + RetSqlName("TFF") + " TFF ON TFF.D_E_L_E_T_ = ' ' "
	If !EMPTY(cFilCont) .And. !lMV_MultFil
		cQry += "AND TFF.TFF_FILIAL = '" + xFilial('TFF',cFilCont) + "' "
	Else
		cQry += " AND "+FWJoinFilial("TFF", "TXP", "TFF", "TXP", .T.)
	EndIf
	If !EMPTY(cPosto)
		cQry += " AND TFF.TFF_COD ='" + cPosto + "'"
	EndIf
	cRevisao := Posicione("CN9",7,xFilial("CN9")+cContrat+"05","CN9_REVISA")
	cQry += " AND TFF.TFF_COD = TXP.TXP_CODTFF "
	cQry += " AND TFF.TFF_CONTRT = '" + cContrat + "' "
	cQry += " AND TFF.TFF_CONREV = '" + cRevisao + "' "

	cQry += " WHERE TXP.D_E_L_E_T_ = ' ' "
	If !EMPTY(cFilCont) .And. !lMV_MultFil
		cQry += " AND TXP.TXP_FILIAL = '" + xFilial('TXP',cFilCont) + "' "
	EndIf
	cQry += " AND TXP_CODUNI = '" + cCodProd + "' "

EndIf

cQry := ChangeQuery(cQry)

Return cQry

//--------------------------------------------------------------------------------
/*/{Protheus.doc} BaseCCTF3

@description Retorno da Consulta Especifica
@author Vitor kwon
@since  12/08/2022
/*/
//--------------------------------------------------------------------------------


Function BaseCCTF3(cBaseOP,cFuncao) 

Local lOK         := .T.
Local cTitle      := STR0133
Local nSuperior   := 0
Local nEsquerda   := 0
Local nInferior   := 0
Local nDireita    := 0
Local aIndex	  := {}
Local aSeek 	  := {}
Local cAls		  := "TECCCT"
Local cQueFunc    := GetNextAlias()
Local aArea		  := GetArea()

Static cBaseOP     := ""
Static cFuncao     := ""

If Empty(cBaseOP)
	cBaseOP := FwFldGet("TXR_CODAA0")
Endif

Aadd( aSeek, { STR0135,{{"","C",TamSX3("REI_CODCCT")[1]  ,0, STR0135,,}}})	
Aadd( aSeek, { STR0136,{{"","C",TamSX3("WY_DESC")[1]     ,0, STR0136,,}}}) 
Aadd( aSeek, { STR0137,{{"","C",TamSX3("RJ_FUNCAO")[1]   ,0, STR0137,,}}}) 
Aadd( aSeek, { STR0138,{{"","C",TamSX3("RJ_DESC")[1]     ,0, STR0138,,}}}) 

Aadd( aIndex, "RJ_FUNCAO" )
Aadd( aIndex, "RJ_DESC")
Aadd( aIndex, "REI_CODCCT" )
Aadd( aIndex, "WY_DESC")
Aadd( aIndex, "RJ_FILIAL")  

	cQry := " SELECT SRJ.RJ_FILIAL, SRJ.RJ_FUNCAO, SRJ.RJ_DESC, REI.REI_CODCCT, SWY.WY_DESC, SWY.WY_CODIGO  "
	cQry += " FROM " + RetSqlName("SWY") + " SWY"
	cQry += " INNER  JOIN " + RetSqlName("RI4") + " RI4 ON RI4.RI4_CODCCT = WY_CODIGO AND RI4.RI4_FILIAL = '"+xFilial("RI4")+"'"
	cQry += " INNER  JOIN  "+ RetSqlName("SRJ") + " SRJ ON RI4.RI4_CODSRJ = RJ_FUNCAO AND SRJ.RJ_FILIAL  = '"+xFilial("SRJ")+"'"
	cQry += " INNER  JOIN  "+ RetSqlName("REI") + " REI ON REI.REI_CODCCT = WY_CODIGO AND REI.REI_FILIAL = '"+xFilial("REI")+"'"
	cQry += " WHERE SWY.D_E_L_E_T_  = '' AND SWY.WY_FILIAL = '"+xFilial("SWY")+"' "
	cQry += " AND RI4.D_E_L_E_T_  = ''  "
	cQry += " AND SRJ.D_E_L_E_T_  = ''  "
	cQry += " AND REI.D_E_L_E_T_  = ''  "
	cQry += " AND REI.REI_CODAA0  = '" +cBaseOP+ "' "

If IsInCallStack("AT984VLDF")
	cQry += " AND SRJ.RJ_FUNCAO  = '" +cFuncao+ "' "

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cQueFunc, .T., .F. )

	If (cQueFunc)->(Eof())
		lOK := .F.	
	Endif

	(cQueFunc)->(DbCloseArea())

Endif

cQry += " ORDER BY SWY.WY_CODIGO"

	nSuperior := 0
	nEsquerda := 0
	nInferior := GetScreenRes()[2] * 0.6
	nDireita  := GetScreenRes()[1] * 0.65

If !IsInCallStack("AT984VLDF")

	DEFINE MSDIALOG oDlgEscTela TITLE OemToAnsi(cTitle) FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL

		oBrowse := FWFormBrowse():New()
		oBrowse:SetOwner(oDlgEscTela)
		oBrowse:SetDataQuery(.T.)
		oBrowse:SetAlias(cAls)
		oBrowse:SetQueryIndex(aIndex)
		oBrowse:SetQuery(cQry)
		oBrowse:SetSeek(,aSeek)
		oBrowse:SetDescription(STR0133)  
		oBrowse:SetMenuDef("")
		TECSetFlt(aSeek, @oBrowse)
		oBrowse:DisableDetails()
		oBrowse:SetUseFilter(.T.)
		oBrowse:SetProfileID(cAls)
		oBrowse:SetDoubleClick({ || cRetXCCT := (oBrowse:Alias())->RJ_FUNCAO, lRet := .T. ,oDlgEscTela:End()})
		oBrowse:AddButton( OemTOAnsi((STR0140), ), {|| cRetXCCT := (oBrowse:Alias())->RJ_FUNCAO, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
		oBrowse:AddButton( OemTOAnsi((STR0141), ), {|| cRetXCCT := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
		oBrowse:DisableDetails()

		ADD COLUMN oColumn DATA { ||  RJ_FUNCAO  } TITLE STR0139  SIZE TamSX3("RJ_FUNCAO")[1]  OF oBrowse 
		ADD COLUMN oColumn DATA { ||  RJ_DESC    } TITLE STR0138  SIZE TamSX3("RJ_DESC")[1]    OF oBrowse 
		ADD COLUMN oColumn DATA { ||  REI_CODCCT } TITLE STR0135  SIZE TamSX3("REI_CODCCT")[1] OF oBrowse 
		ADD COLUMN oColumn DATA { ||  WY_DESC }    TITLE STR0136  SIZE TamSX3("WY_DESC")[1] OF oBrowse 

		oBrowse:Activate()

	ACTIVATE MSDIALOG oDlgEscTela CENTERED

Endif	

RestArea(aArea)

Return lOK

//-------------------------------------------------------------------
/*/{Protheus.doc} TECBasF3()
Retorno da consulta especifica

@author Vitor kwon
@since  01/02/2021
/*/
//------------------------------------------------------------------
Function TECBasF3()

Return cRetXCCT

//--------------------------------------------------------------------------------
/*/{Protheus.doc} ContactAGB

@description Retorna o primeiro número de contato do Grid AGB(contatos) com padrão = sim
@author Jack Junior
@since  05/09/2022
/*/
//--------------------------------------------------------------------------------

Function ContactAGB(cCod)
Local cAliasAGB	:= GetNextAlias()
Local cContact	:= ""
Local cPadrao	:= "1"

BeginSql alias cAliasAGB
    SELECT
        AGB.AGB_TELEFO
    FROM
        %table:AGB% AGB
    WHERE
        AGB.AGB_FILIAL= %xfilial:AGB% AND
        AGB.AGB_CODENT= %exp:cCod% AND
		AGB.AGB_PADRAO= %exp:cPadrao% AND
        AGB.%notDel% ORDER BY AGB.AGB_CODIGO
EndSql

If (cAliasAGB)->(!Eof())
	cContact := (cAliasAGB)->AGB_TELEFO
EndIf

(cAliasAGB)->(DbCloseArea())

Return cContact


                                                                                                                                                                                                                        

