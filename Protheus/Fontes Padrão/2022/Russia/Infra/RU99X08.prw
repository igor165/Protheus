#include "Totvs.Ch"
#include "TopConn.Ch"
#include "RU99X08.CH"

/*/{Protheus.doc} RUVISV01
Routine responsible to validate field F6Q_X1PERG.

@type function
@author Alison Kaique
@since Apr|2019
@return lReturn, logical, Validated Process ?
/*/
Function RUVISV01()
	Local aArea   := GetArea()
	Local lReturn := .F.
	Local cX1Perg := M->F6Q_X1PERG

	If !Empty(cX1Perg)
		SX1->(DBSetOrder(1)) //X1_GRUPO
		lReturn := SX1->(DBSeek( cX1Perg ))
	Else
		lReturn := .T.
	EndIf

	RestArea(aArea)
Return lReturn

/*/{Protheus.doc} RUVISV02
Routine responsible to validate field F6Q_MODULO.

@type function
@author Alison Kaique
@since Apr|2019
@return lReturn, logical, Validated Process ?
/*/
Function RUVISV02()
	Local aArea       := GetArea()
	Local lReturn     := .F.
	Local cModuleCode := Alltrim(M->F6Q_MODULO)

	If !Empty(cModuleCode)
		SX5->(DBSetOrder(1)) //X5_FILIAL, X5_TABELA, X5_CHAVE
		lReturn := SX5->(DBSeek( FWxFilial("SX5") + PADR("IA",2) + PADR(cModuleCode, 06) ))
	Else
		lReturn := .T.
	EndIf

	RestArea(aArea)
Return lReturn

/*/{Protheus.doc} RUVISV03
Routine responsible to validate field F6R_CODVIS.

@type function
@author Alison Kaique
@since Apr|2019
@return lReturn, logical, Validated Process ?
/*/
Function RUVISV03()
	Local aArea     := GetArea()
	Local lReturn   := .F.
	Local cCodVis   := Alltrim(M->F6R_CODVIS)
	Local cCodQry   := Alltrim(M->F6R_CODQRY)
	Local cMsgHelp  := ""
	Local cPath     := "\panelquery\"
	Local cFileName := "RUVISV03-01" + DTOS(dDataBase) + StrTran(Time(),":","")

	//Verify if View exists
	F6Q->(DBSetOrder(1)) //F6Q_FILIAL, F6Q_CODVIS
	lReturn := F6Q->(DBSeek( FWxFilial("F6Q") + cCodVis ))

	If lReturn
		If !Empty(cCodVis)
			//Verify number of registers in the View and Queries
			cQuery := ""
			cQuery += " SELECT COUNT(*) AS TOTREG "
			cQuery += " FROM " + RetSqlName("F6R")
			cQuery += " WHERE F6R_FILIAL = '" + FWxFilial("F6R") + "' "
			cQuery += " AND F6R_CODVIS = '" + cCodVis + "' "
			cQuery += " AND F6R_CODQRY <> '" + cCodQry + "' "

			If Select("TEMPF6R") > 0
				TEMPF6R->(dbCloseArea())
			EndIf

			PlsQuery(cQuery, "TEMPF6R")

			cPath := "\panelquery\"
			cFileName := "RUVISV03-01" + DTOS(dDataBase) + StrTran(Time(),":","")
			makedir(cPath)
			MemoWrite( cPath + cFileName + ".sql" , cQuery )

			nTotReg := TEMPF6R->TOTREG

			TEMPF6R->(dbCloseArea())

			If nTotReg > 0
				lReturn := .F.
				cMsgHelp := STR0001 + cCodVis + CRLF + STR0002 + Alltrim(F6R->F6R_CODVIS) + " - " + Alltrim(F6R->F6R_TITULO) //View: # already registered for Query:
				Help(" ",1,"F6R_CODVIS",,cMsgHelp,4,15)
			Else
				lReturn := .T.
			EndIf

		Else
			lReturn := .T.
		EndIf
	Else
		cMsgHelp := STR0001 + cCodVis + CRLF + STR0003 //View: # Not Found!
		Help(" ",1,"F6R_CODVIS",,cMsgHelp,4,15)
	EndIf

	RestArea(aArea)
Return lReturn

/*/{Protheus.doc} RUVISV04
Routine responsible to validate field F6S_QRYCPO.

@type function
@author Alison Kaique
@since Apr|2019
@return lReturn, logical, Validated Process ?
/*/
Function RUVISV04()
	Local aArea		:= GetArea()
	Local lReturn	:= .F.
	Local cCodQry 	:= ""

	cCodQry := &(Alltrim(ReadVar()))

Return Iif(!Empty(cCodQry), ExistCpo("F6R",cCodQry), .T.)

/*/{Protheus.doc} RUSX9Util
Routine responsible to return the relation of Parent with Child

@type function
@author Alison Kaique
@since Apr|2019
@param cParentField, character, Parent Field in Relation
@param cChildField , character, Child Field in Relation
@return aRelation  , array    , List of Relations
/*/
Function RUSX9Util(cParentField, cChildField)
	Local aRelation := {} //List of Relations
	Local cWhere    := "" //Clause Where
	Local cAlias    := GetNextAlias() //Query Alias
	Local cTabDB    := "% SX9" + cEmpAnt + "0 %" //Remove and use %table:SX9%
	Local lOK       := .T. //Procede ?
	Local nAtField  := 0 //Position of Field
	Local cSubStr   := "" //SubString

	Default cParentField := ""
	Default cChildField  := ""

	//Verify Type of Search
	Do Case
		Case !Empty(cParentField) .AND. !Empty(cChildField) //Using Both information
			cWhere := "% X9_EXPDOM LIKE '%" + Alltrim(cParentField) + "%' AND X9_EXPCDOM LIKE '%" + Alltrim(cChildField) + "%' AND %"
		Case !Empty(cParentField) .AND. Empty(cChildField) //Using Parent information
			cWhere := "% X9_EXPDOM LIKE '%" + Alltrim(cParentField) + "%' AND %"
		Case Empty(cParentField) .AND. !Empty(cChildField) //Using Child information
			cWhere := "% X9_EXPCDOM LIKE '%" + Alltrim(cChildField) + "%' AND %"
		OtherWise
	EndCase

	//Close Alias
	If (Select(cAlias) > 0)
		(cAlias)->(dbCloseArea())
	EndIf

	//Query
	BeginSQL Alias cAlias
		SELECT
			X9_DOM, X9_CDOM, X9_EXPDOM, X9_EXPCDOM, X9_CONDSQL
		FROM
			%exp:cTabDB% SX9
		WHERE
			%exp:cWhere%
			SX9.%notDel%
	EndSQL

	//Open Alias
	(cAlias)->(DBGoTop())
	While !(cAlias)->(EOF())
		lOK := .T.
		//Verify if field contains in Parent or Child
		Do Case
			Case !Empty(cParentField) .AND. !Empty(cChildField) //Using Both information
				nAtField := At(Alltrim(cParentField), Alltrim((cAlias)->X9_EXPDOM))
				cSubStr := SubStr(Alltrim((cAlias)->X9_EXPDOM), nAtField - 01, 01)
				If (nAtField > 01 .AND. !(cSubStr == "+"))
					lOK := .F.
				EndIf

				cSubStr := SubStr(Alltrim((cAlias)->X9_EXPDOM), nAtField + Len(cChildField), 01)
				If (lOK .AND. nAtField > 0 .AND. !(cSubStr == "+" .OR. Empty(cSubStr)))
					lOK := .F.
				EndIf

				nAtField := At(Alltrim(cChildField), Alltrim((cAlias)->X9_EXPCDOM))
				cSubStr := SubStr(Alltrim((cAlias)->X9_EXPCDOM), nAtField - 01, 01)
				If (lOK .AND. nAtField > 01 .AND. !(cSubStr == "+"))
					lOK := .F.
				EndIf

				cSubStr := SubStr(Alltrim((cAlias)->X9_EXPCDOM), nAtField + Len(cChildField), 01)
				If (lOK .AND. nAtField > 0 .AND. !(cSubStr == "+" .OR. Empty(cSubStr)))
					lOK := .F.
				EndIf

			Case !Empty(cParentField) .AND. Empty(cChildField) //Using Parent information
				nAtField := At(Alltrim(cParentField), Alltrim((cAlias)->X9_EXPDOM))
				cSubStr := SubStr(Alltrim((cAlias)->X9_EXPDOM), nAtField - 01, 01)
				If (nAtField > 01 .AND. !(cSubStr == "+"))
					lOK := .F.
				EndIf

				cSubStr := SubStr(Alltrim((cAlias)->X9_EXPDOM), nAtField + Len(cChildField), 01)
				If (lOK .AND. nAtField > 0 .AND. !(cSubStr == "+" .OR. Empty(cSubStr)))
					lOK := .F.
				EndIf
			Case Empty(cParentField) .AND. !Empty(cChildField) //Using Child information
				nAtField := At(Alltrim(cChildField), Alltrim((cAlias)->X9_EXPCDOM))
				cSubStr := SubStr(Alltrim((cAlias)->X9_EXPCDOM), nAtField - 01, 01)
				If (lOK .AND. nAtField > 01 .AND. !(cSubStr == "+"))
					lOK := .F.
				EndIf

				cSubStr := SubStr(Alltrim((cAlias)->X9_EXPCDOM), nAtField + Len(cChildField), 01)
				If (lOK .AND. nAtField > 0 .AND. !(cSubStr == "+" .OR. Empty(cSubStr)))
					lOK := .F.
				EndIf
			OtherWise
		EndCase
		//Add in Array
		If (lOK)
			AAdd(aRelation,;
							{;
								(cAlias)->X9_DOM    ,; //[01] - Patern Alias
								(cAlias)->X9_CDOM   ,; //[02] - Child Alias
								(cAlias)->X9_EXPDOM ,; //[03] - Patern Field
								(cAlias)->X9_EXPCDOM,; //[04] - Child Field
								(cAlias)->X9_CONDSQL ; //[05] - SQL Condition
							};
				)
		EndIf
		(cAlias)->(DBSkip())
	EndDo

	//Close Alias
	If (Select(cAlias) > 0)
		(cAlias)->(dbCloseArea())
	EndIf

Return aRelation