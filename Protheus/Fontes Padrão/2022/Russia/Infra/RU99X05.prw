#include "protheus.Ch"
#Include "FwMvcDef.ch"
#Include "tcbrowse.ch"
#include "RU99X05.ch"

#DEFINE DB_TYPE AllTrim(TCGetDB()) //DataBase Type



/*/{Protheus.doc} RU99X05
Screen for Execute Managerial Views
@type function
@author Alison Kaique
@since Apr|2019
/*/
Function RU99X05(cCodVis)
	Local cTitle      := STR0001 //Views Panel
	Local oDlg        := Nil
	Local ii          := 0
	Local cQuery 	as character
	Local aInfgrpu 	as array
	Local aInfgrpu2 as array
	Local nPosArray as numeric

	Local oSize := FwDefSize():New(.F.)
	Local oLayer := FWLayer():new()


	Private oArea     := Nil
	Private oGetData  := Nil
	Private oFWBrowse := Nil
	Private oBrowseTot := Nil //Total Object
	Private o1TCBrowse  := Nil //Double click Browser
	Private oTCBrwTot := Nil
	Private aFWBrowse := {}
	Private aBackGet  := {}
	Private cF6RPri   := ""
	Private aF6RQry   := {}
	Private aTabExec  := {}
	Private cAlisScre := "" //Alias fot the information at screen, doest matter if are principal or drilldrown screen
	Private cQueryScre:= '' //Query executed to bring data at main alias
	Private aMaxVal := {} //fields and max values
	Private cTabExec  := ""
	Private cTabTotals:= ""
	Private cGroupQuery := ""
	Private cGroupByAlias := ""

	Private oViewData  := Nil
	Private oDrillData  := Nil
	Private oViewTotal := Nil
	Private oPanel01   := Nil
	Private oViewTree  := Nil
	Private oTree      := Nil
	Private cViewCode  := ""

	Private aColFilter 	:= {}//Array with columns for default filter at browser
	Private cSelcField 	:= '' // Fields selected by user to be displayed

	default cCodVis 	:= '' 	//group of vision for excecution directly


	/*Check if user has permission for default group of show one screen for group selection*/
	cQuery := RUQUERYGR(cCodVis)
	//Check if alias is oppen
	If Select("TMPF6Q") > 0
		TMPF6Q->(dbCloseArea()) //Close alias
	EndIf
	PlsQuery(cQuery, "TMPF6Q")
	aInfgrpu := {}
	aInfgrpu2 := {}
	While TMPF6Q->(!EOF())
		nPosArray := aScan(aInfgrpu, {|x| Alltrim(Upper(x[1])) == Alltrim(Upper(TMPF6Q->F6Q_CODVIS))})
		If nPosArray == 0
			AAdd(aInfgrpu, {Alltrim(Upper(TMPF6Q->F6Q_CODVIS)), alltrim(TMPF6Q->F6Q_TITULO), {}})
			AAdd(aInfgrpu2, alltrim(TMPF6Q->F6Q_TITULO) )
		EndIf
		TMPF6Q->(dbSkip())
	EndDo

	//display dialog for selection
	If (Len(aInfgrpu) > 1)
		nChoice := 0
		nChoice := MDConPad(aInfgrpu2, STR0043, .T.) //select the vision
		//Make Query for Group By
		If (nChoice > 0)
			cCodVis := aInfgrpu[nChoice,1]
		Endif
	elseif (Len(aInfgrpu) == 1)
		cCodVis := aInfgrpu[1,1]
	else
		cCodVis := ''
	EndIf

DEFINE MSDIALOG oDlg  TITLE cTitle from oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL 
	//Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botão de fecharo
	oLayer:init(oDlg,.F.)

	//Create column for treee view
	oLayer:addCollumn("VIEWTREE",20,.F.)
		oLayer:addWindow('VIEWTREE','A_VIEWS',STR0002,100,.F.,.F.,{|| .t. },,{|| .T.})
		oViewTree := oLayer:getWinPanel("VIEWTREE",'A_VIEWS')

		oTree := XTree():New(000, 000, 000, 000, oViewTree)
		oTree:Align := CONTROL_ALIGN_ALLCLIENT
		RUMntTree(@oTree,cCodVis)


	//Create column for Data view
	oLayer:addCollumn("VIEWDATA",80,.F.)
		oLayer:addWindow('VIEWDATA','D_VIEWS',STR0005,100,.F.,.F.,{|| .t. },,{|| .T.})
		oViewData := oLayer:getWinPanel("VIEWDATA",'D_VIEWS')

	oLayer:getWinPanel('VIEWTREE','A_VIEWS')                             
ACTIVATE MSDIALOG oDlg CENTERED

	//Close all possible Browse
	If oFWBrowse <> Nil
		oFWBrowse:DeActivate()
		oFWBrowse := Nil
	EndIf

	If oBrowseTot <> Nil
		oBrowseTot:DeActivate()
		oBrowseTot := Nil
	EndIf

	If o1TCBrowse <> Nil
		o1TCBrowse:DeActivate()
		o1TCBrowse := Nil
	EndIf

	For ii := 1 To Len(aTabExec)
		cCurrAlias := aTabExec[ii, 01]
		If select(cCurrAlias) > 0
			(cCurrAlias)->(dbCloseArea())
			If (ValType(aTabExec[ii, 02]) == "O")
				aTabExec[ii, 02]:Delete()
			EndIf
		EndIf
	Next ii
Return

/*/{Protheus.doc} RU99X0502
Order registers according Index

@type function
@author Alison Kaique
@since Apr|2019

@param oTC    , object , TCBrowse Object
@param nColPos, numeric, Column Position
@param nType  , numeric, Order Type
/*/
Function RU99X0502(oTC, nColPos, nType)
	Local aIndexes  := {} //Array of Indexes
	Local aFieldInd := {} //Fields in Index
	Local aKey      := {} //Key to Group By
	Local nChoice   := 0 //Choisen Index
	Local nI        := 0 //Loop Control
	Local cOrderBy  := "" //Order By String
	Local cDesFl	as character
	Local aDesFl	as array


	Default oTC     := Nil
	Default nColPos := 0

	cDesFl := ''
	aDesFl := {}

	If (nColPos > 0)
		FWMsgRun( , {|| RUAuxOrder(oTC, nColPos) } ,, STR0024 ) //"Ordering... "
	Else
		//Load Indexes
		F6T->(DBSetOrder(01)) //F6T_FILIAL + F6T_CODQRY
		If (F6T->(DBSeek(FWxFilial("F6T") + cF6RPri)))
			While (!F6T->(EOF()) .AND. F6T->F6T_CODQRY == cF6RPri)
				AAdd(aIndexes , AllTrim(F6T->F6T_DESCRI))
				//Get descric by the fields header
				aDesFl := StrTokArr( AllTrim(F6T->F6T_KEY), '+' )
				For nI := 1 to len(aDesFl)
					If nI > 1
						cDesFl += '+'
					Endif
					cDesFl += GetSx3Cache(aDesFl[nI],"X3_TITULO")
				Next

				AAdd(aFieldInd, {F6T->F6T_ORDER, AllTrim(cDesFl), AllTrim(F6T->F6T_KEY)})
				F6T->(DbSkip())
			EndDo
		EndIf
		//Show Indexes
		If (Len(aIndexes) > 0)
			nChoice := MDConPad(aIndexes, IIf(nType == 01, STR0023, STR0029), .T.)

			//Manage Order By
			If (nChoice > 0)
				aKey := Separa(aFieldInd[nChoice, 03], "+")
				//Create String
				cOrderBy := "ORDER BY" + CRLF
				For nI := 01 To Len(aKey)
					cOrderBy += aKey[nI] + IIf(nType == 01, " ASC", " DESC") + IIf(nI == Len(aKey), "", ", ")
				Next nI
				//Show Browse
				RU99X0506(cViewCode, cOrderBy)
			EndIf
		EndIf
	EndIf
Return

/*/{Protheus.doc} RUAuxOrder
Auxiliary Function to Order registers according Index

@type function
@author Alison Kaique
@since Apr|2019
/*/
Static Function RUAuxOrder(oTC, nColPos)
	//Order by Index
	DBSelectArea(cTabExec)
	(cTabExec)->(DBSetOrder(nColPos))
	//Refresh Tabke
	TcRefresh(cTabExec)
	//Go Top
	oTC:GoTop()
	oTC:SetFocus()
Return


/*/{Protheus.doc} RUQUERYGR
Function create query with all visions that user can see
@type function
@author Rafael Goncalves da silva
@since Dec|2019
/*/
Static Function RUQUERYGR(cCodVis)
Local cQuery as character
Local cUsersGroup  as character

Default cCodVis := ''

cUsersGroup := FormatIn(ArrTokStr(UsrRetGrp(__cUserID), ","), ",") //User Group

//Load informations
cQuery := "" + CRLF
cQuery += " SELECT	F6Q_CODVIS, " + CRLF
cQuery += " 			F6Q_TITULO, " + CRLF
cQuery += " 			F6R_X1PERG, " + CRLF
//Verify DataBase Type
If(DB_TYPE == "POSTGRES")
	cQuery += " 			COALESCE(encode(F6Q_OBS,'escape'), ' ') AS F6Q_OBS, " + CRLF
	cQuery += " 			COALESCE(COALESCE(encode(F6R_QUERY,'escape'), ' '), ' ') AS F6R_QUERY, " + CRLF
Else
	cQuery += " 			ISNULL(CAST(F6Q_OBS AS VARCHAR(2047)), '') AS F6Q_OBS, " + CRLF
	cQuery += " 			ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), F6R_QUERY)),'') AS F6R_QUERY, " + CRLF
EndIf
cQuery += " 			F6R_CODQRY, " + CRLF
cQuery += " 			F6R_TITULO " + CRLF

cQuery += " FROM " + RetSqlName("F6Q") + " F6Q " + CRLF
cQuery += " INNER JOIN " + RetSqlName("F6P") + " F6P ON F6P_FILIAL = F6Q_FILIAL AND F6P_CODVIS = F6Q_CODVIS AND F6P.D_E_L_E_T_ = ' ' " + CRLF // join with sons
cQuery += " INNER JOIN " + RetSqlName("F6R") + " F6R  ON F6R_FILIAL = F6Q_FILIAL  AND F6P_CODQRY = F6R_CODQRY  AND F6R.D_E_L_E_T_ = ' ' " + CRLF
cQuery += " WHERE F6Q_FILIAL = '" + FWxFilial("F6Q") + "' " + CRLF
cQuery += " AND F6Q_ATIVO = 'A' " + CRLF

cQuery += "AND ( (SELECT COUNT(*) FROM " + RetSqlName("F6U") + " F6U" + CRLF
cQuery += " WHERE F6U_FILIAL = F6Q_FILIAL" + CRLF
cQuery += " AND F6U_CODVIS = F6Q_CODVIS" + CRLF
cQuery += " AND F6U_CODUSR = '" + __cUserID + "'" + CRLF
cQuery += " AND F6U_ATIVO = 'A'" + CRLF
cQuery += " AND F6U.D_E_L_E_T_ = ' ') > 0 OR" + CRLF
cQuery += " (SELECT COUNT(*) FROM " + RetSqlName("F6V") + " F6V" + CRLF
cQuery += " WHERE F6V_FILIAL = F6Q_FILIAL" + CRLF
cQuery += " AND F6V_CODVIS = F6Q_CODVIS" + CRLF
cQuery += " AND F6V_CODGRP IN " + cUsersGroup + CRLF
cQuery += " AND F6V_ATIVO = 'A'" + CRLF
cQuery += " AND F6V.D_E_L_E_T_ = ' ') > 0)" + CRLF
cQuery += " AND F6Q.D_E_L_E_T_ = ' ' " + CRLF

If !Empty(cCodVis) //Check if user can see this vision
	cQuery += " AND F6Q.F6Q_CODVIS = '"+cCodVis+"' " + CRLF
endif

cQuery := ChangeQuery(cQuery)

Return cQuery

/*/{Protheus.doc} RUMntTree
Make Tree with View informations

@type function
@author Alison Kaique
@since Apr|2019
@param oTree, object, Tree's Object
	cCodGrup, cod of vision that user would like to see, empty equal all vision
/*/
Static Function RUMntTree(oTree,cCodVis)
	Local cQuery	:= ""
	Local aTree		:= {}
	Local nPosArray	:= 0
	Local cTitNode	:= ""
	Local cImg16	:= ""
	Local cIdNode	:= ""
	Local cFuncCall	:= ""
	Local aChilds	:= {}
	Local cNameModu := "" //Module Name
	Local ii		:= 0
	Local jj		:= 0
	default cCodVis := ''

	cQuery := RUQUERYGR(cCodVis) //Look visions that user can access

	If Select("TMPF6Q") > 0
		TMPF6Q->(dbCloseArea())
	EndIf

	PlsQuery(cQuery, "TMPF6Q")

	While TMPF6Q->(!EOF())
		nPosArray := aScan(aTree, {|x| Alltrim(Upper(x[1])) == Alltrim(Upper(TMPF6Q->F6Q_TITULO))})

		If nPosArray == 0
			AAdd(aTree, {Alltrim(Upper(TMPF6Q->F6Q_TITULO)), alltrim(TMPF6Q->F6Q_TITULO), {}})
			nPosArray := Len(aTree)
		EndIf

		AAdd(aTree[nPosArray][3], {	TMPF6Q->F6Q_CODVIS,;
			TMPF6Q->F6Q_TITULO,;
			TMPF6Q->F6R_X1PERG,;
			TMPF6Q->F6Q_OBS,;
			TMPF6Q->F6R_CODQRY,;
			TMPF6Q->F6R_TITULO,;
			TMPF6Q->F6R_QUERY,;
			cNameModu})

		TMPF6Q->(dbSkip())
	EndDo

	//Add elements in Object xTree
	For ii := 1 To Len(aTree)
		cTitNode 	:= Capital(aTree[ii][2])
		cImg16		:= "FOLDER5"
		cIdNode	:= "ID_" + Alltrim(Upper(aTree[ii][1]))

		//Add Father(Modules)
		oTree:AddTree(cTitNode, "FOLDER5", "FOLDER6",cIdNode)

		aChilds := aTree[ii][3]

		For jj := 1 To Len(aChilds)
			//Add Childs(Views)
			cTitNode 	:= Capital(aChilds[jj][6]) //Title of query
			cImg16		:= "BR_CINZA.png" //"bmpcpo.png"
			cIdNode	:= cIdNode + StrZero(jj,3)
			cFuncCall	:= "{|| RU99X0506('" + Alltrim(aChilds[jj][5]) + "')}" //query code instead of vision
			oTree:AddTree(cTitNode, cImg16, cImg16, cIdNode,,, &(cFuncCall))
			oTree:EndTree()
		Next jj

		oTree:EndTree()
	Next ii
Return

/*/{Protheus.doc} RU99X0506
Data Browse

@type function
@author Alison Kaique
@since Apr|2019
@param cQryPar , character, View Code
@param cOrderBy, character, Fields to Order By
/*/
Function RU99X0506(cQryPar, cOrderBy, cSelcField, lAsk)
	Local cQuery    := ""
	Local cMsgHelp  := ""
	Local cGrpSX1   := ""
	Local aGrpSX1   := {}
	Local nPosOrder := 0
	Local lMsgYesNo := .T.

	Default cQryPar  := ""
	Default cOrderBy := ""
	Default cSelcField := "" //load information from profile
	Default lAsk := .T.

	cViewCode := cQryPar //update public variable with query cod selected, used for group and others sub functions

	aBackGet := {}
	aF6RQry  := {}
	aMaxVal := {}

	F6R->(DBSetOrder(1)) //F6R_FILIAL, F6R_CODVIS
	If F6R->(DBSeek(FWxFilial("F6R") + cQryPar))
		cF6RPri := F6R->F6R_CODQRY
		cGrpSX1 := F6R->F6R_X1PERG
		If(Empty(cSelcField)) //Check if has information at Profitle
			cSelcField := RU99X0505(.F.) //Update fields saved before
		Endif

		If !Empty(cGrpSX1)
			aGrpSX1 := RUSX1Trat(cGrpSX1)
			If aGrpSX1[1]
				aGrpSX1   := ACLONE(aGrpSX1[2])
				If !lAsk
					lMsgYesNo := MsgYesNo(STR0006 + Alltrim(Capital(F6R->F6R_TITULO)) + STR0007) //Confirms execution of View: [ # ], based on the parameters?
				EndIf
			Else
				lMsgYesNo := .F.
			EndIf //aGrpSX1
		Else
			aGrpSX1   := {}
			If !lAsk
				lMsgYesNo := MsgYesNo(STR0006 + Alltrim(Capital(F6R->F6R_TITULO)) + STR0008) //Confirms execution of View: [ # ] ?
			EndIf
		EndIf //cGrpSX1

		If lMsgYesNo
			cQuery    := F6R->F6R_QUERY

			//Implement Order By
			If !(Empty(cOrderBy))
				//Verify if already contais ORDER BY
				nPosOrder := RAt("ORDER BY", Upper(cQuery))
				If (nPosOrder > 0)
					//Remove Order By
					cQuery := Left(cQuery, nPosOrder - 01)
				EndIf
				//Add Order By
				cQuery += CRLF + cOrderBy
			EndIf
			FWMsgRun(, {||RU99X0511(cQuery,aGrpSX1)},STR0009, STR0010) //Loading Informations ... # - WAIT -
		EndIf
	Else
		cMsgHelp := CRLF + STR0011 //View not found to any query
		Help(" ", 1, "F6R_CODQRY", , cMsgHelp, 4, 15)
	EndIf

Return


/*/{Protheus.doc} RU99X0511
Executing query with waiting
@type function
@author rafael Goncalves
@since Jan|2020
@param cSX1Par, character, Group of Questions
@return aReturn, array, Informations of Group of Questions
/*/
Function RU99X0511(cQuery,aGrpSX1)
Local cNewQuery as Character
Local aRetVis as Array
cNewQuery := RUNewQry(cQuery, aGrpSX1)
aRetVis   := RUViewData(cNewQuery)

If (Len(aRetVis[1]) > 0 .OR. Len(aRetVis[2]) > 0)
	RUNewGet(aRetVis[1], aRetVis[2], , cNewQuery)
EndIf

Return .f.


/*/{Protheus.doc} RUSX1Trat
Group of Questions management

@type function
@author Alison Kaique
@since Apr|2019
@param cSX1Par, character, Group of Questions
@return aReturn, array, Informations of Group of Questions
/*/
Function RUSX1Trat(cSX1Par,lQuestion,lFunction)
	Local aReturn := {}
	Local aArea   := GetArea()
	Local cVar01  := "" //Variable Control
	Local nVar01  := 0 //Variable Control
	Local aQuesVal := {} //Question description + value

	Default cSX1Par   := ""
	Default lQuestion := .T.
	Default lFunction := .T.

	SX1->(DBSetOrder(1)) //X1_GRUPO
	If SX1->(DBSeek(alltrim(cSX1Par)))
		If !lQuestion
			Pergunte(alltrim(cSX1Par), .F.)
			lProceed := .T.
		Else
			lProceed := Pergunte(alltrim(cSX1Par),.T.)
		EndIf

		If(lProceed)
			SX1->(DBSetOrder(1)) //X1_GRUPO
			SX1->(DBSeek(alltrim(cSX1Par)))
			While SX1->(!EOF()) .AND. Alltrim(SX1->X1_GRUPO) == Alltrim(cSX1Par)
				cVar01 := ""
				nVar01 ++
				If !(Type(Alltrim(SX1->X1_VAR01)) == "U")
					cVar01 := Alltrim(SX1->X1_VAR01)
					AAdd(aReturn, {cVar01, &(cVar01)})
					AAdd(aQuesVal, {X1Pergunt(), &(cVar01), SX1->X1_TIPO})
				ElseIf !(Type("MV_PAR" + StrZero(nVar01, 02)) == "U")
					cVar01 := "MV_PAR" + StrZero(nVar01, 02)
					AAdd(aReturn, {cVar01, &(cVar01)})
					AAdd(aQuesVal, {X1Pergunt(), &(cVar01), SX1->X1_TIPO})
				EndIf
				SX1->(dbSkip())
			EndDo
		EndIf
	Else
		//Check if questions is a function
		if FindFunction( cSX1Par ) .and. lFunction //Is a function, call.
			aRet := &(cSX1Par)
			If len(aRet)>0
				lProceed := aRet[1]
				aReturn := aRet[2]
			EndIf
		else
			cMsgHelp := STR0013 //There is no registered Group of Questions with this code
			Help(" ", 1, "F6R_X1PERG", , cMsgHelp, 4, 15)
		EndIf
	EndIf

	RestArea(aArea)
Return {lProceed, aReturn, aQuesVal}

/*/{Protheus.doc} RUNewQry
Query Handling

@type function
@author Alison Kaique
@since Apr|2019
@param cQuery  , character, String Query
@param aGrpSX1 , array    , Group of Questions
@param aGroupBy, array    , Fields to Group By when made double click
@param aHeadPar, array    , Header
@param cFilter , character, Filter String
@return cReturn, character,(Query com os dados
/*/
Function RUNewQry(cQuery, aGrpSX1, aGroupBy, aHeadPar, cFilter, aSubQuer)
	Local cReturn      := ""
	Local ii           := 0
	Local cContent     := ""
	Local cChangeField := ""
	Local cGroupQuery  := ""
	Local cFilterQuery := ""
	Local cGroupBy     := ""
	Local nPosWHERE    := 0
	Default cQuery   := ""
	Default aGrpSX1  := {}
	Default aGroupBy := {}
	Default aHeadPar := {}
	Default cFilter  := ""
	Default aSubQuer := {}

	cReturn := Alltrim(Upper(cQuery))
	cReturn := RUChgQry(cReturn)
	cQuery2 :=  cReturn

	oStatement := FWPreparedStatement():New() //inject parameters

	//read all MV_PAR that we have at query in order used at query
	nControl := 1
	aParamet := {} //array with all parameters
	cQuery2 := Substr(cQuery2,At("%EXP:MV",cQuery2)+1,Len(cQuery2))
	Do While At("EXP:MV",cQuery2)>0
		aAdd(aParamet, {nControl,  Substr(cQuery2,5,At("%",cQuery2)-5)})
		cQuery2 := Substr(cQuery2,At("%",cQuery2)+1,Len(cQuery2))
		cQuery2 := Substr(cQuery2,At("%EXP:MV",cQuery2)+1,Len(cQuery2))
		nControl++
	EndDo
	cQuery2 :=  cReturn

	//Change MV_PAR??? for ?
	For ii := 1 To Len(aGrpSX1)
		cChangeField := "%Exp:" + aGrpSX1[ii][1] + "%"
		cQuery2 := StrTran(cQuery2, UPPER(cChangeField), "?")
	Next ii
	oStatement:SetQuery(cQuery2) // query with parameters defined as ?

	For ii := 1 To Len(aParamet) //Insert parameters
		//Seek at aGrpSX1 what is the value
		nPos := aScan( aGrpSX1, {|x| x[1] == aParamet[ii,2] } )
		If nPos <> 0
			If ValType(aGrpSX1[nPos][2]) == "C"
				oStatement:SetString(ii,aGrpSX1[nPos][2]) //Caracter
			ElseIf ValType(aGrpSX1[nPos][2]) == "N"
				oStatement:setNumeric(ii,aGrpSX1[nPos][2]) //Numeric
			ElseIf ValType(aGrpSX1[nPos][2]) == "D"
				oStatement:setDate(ii,aGrpSX1[nPos][2]) //Date
			EndIf
		Endif
	Next ii
	//recover parameters injected
	cReturn := oStatement:GetFixQuery()


	//This part are used at subquery execution
	If len(aSubQuer) > 0
		For ii := 1 To Len(aSubQuer)
			If ValType(aSubQuer[ii][2]) == "C"
				cContent := "'"+aSubQuer[ii][2]+"'"
			ElseIf ValType(aSubQuer[ii][2]) == "N"
				cContent := Alltrim(Str(aSubQuer[ii][2]))
			ElseIf ValType(aSubQuer[ii][2]) == "D"
				cContent := "'"+DTOS(aSubQuer[ii][2])+"'"
			EndIf

			cChangeField := "%Exp:" + aSubQuer[ii][1] + "%"
			cReturn := StrTran(cReturn, UPPER(cChangeField), Alltrim(cContent))
		Next ii

		//remove all %Exp that we dont have replaced, we can create query with all fields but have only some at screen, it will remove the others fields
		//cQuery2 := cReturn
		cQuery2 := Substr(cReturn,At("%EXP:",cReturn),Len(cReturn))
		Do While At("%EXP:",cQuery2)>0
			//Field to be replaced
			cQuery2 := Substr(cQuery2,2,Len(cQuery2))
			cChangeField := '%'+Substr(cQuery2,1,At("%",cQuery2))
			cQuery2 := Substr(cQuery2,At("%",cQuery2)+1,Len(cQuery2)) //rest Of string

			cReturn := StrTran(cReturn, UPPER(cChangeField), "null")

			cQuery2 := Substr(cQuery2,At("%EXP:",cQuery2),Len(cQuery2))
			nControl++
		EndDo
		cQuery2 :=  cReturn
	Endif

	If (Len(aGroupBy) > 0)
		//Select
		cGroupQuery := "SELECT" + CRLF
		//Loop Group By Fields
		For ii := 01 To Len(aGroupBy)
			cGroupQuery += aGroupBy[ii] + IIf(ii == Len(aGroupBy), CRLF, ", ")
			cGroupBy += aGroupBy[ii] + IIf(ii == Len(aGroupBy), CRLF, ", ")
		Next ii
		//Other Fields
		For ii := 01 To Len(aHeadPar)
			//Verify if exists and Numeric Type
			If (AScan(aGroupBy, {|x| AllTrim(x) == AllTrim(aHeadPar[ii, 02])}) == 0 .AND. aHeadPar[ii, 08] == "N")
				cGroupQuery += ", " + "SUM(" + aHeadPar[ii, 02] + ") " + aHeadPar[ii, 02] + IIf(ii == Len(aHeadPar), CRLF, "")
			EndIf
		Next ii
		//Count Field
		cGroupQuery += ", COUNT(X." + aGroupBy[01] + ") COUNT" + CRLF
		//From
		cGroupQuery += "FROM" + CRLF
		cGroupQuery += "(" + CRLF
		//Query
		cGroupQuery += cReturn + CRLF
		cGroupQuery += ")X" + CRLF
		//Group By
		cGroupQuery += "GROUP BY" + CRLF + cGroupBy

		//Set New Query
		cReturn := cGroupQuery
	EndIf

	If !(Empty(cFilter))
		//Search for WHERE sentence
		nPosWHERE := RAt("WHERE", Upper(cReturn))

		//If contais WHERE sentence, compose according Filter
		If (nPosWHERE > 0)
			cFilterQuery := Left(cReturn, (nPosWHERE - 01)) + CRLF
			cFilterQuery += "WHERE" + CRLF
			cFilterQuery += cFilter + " AND " + CRLF
			cFilterQuery += SubStr(cReturn, (nPosWHERE + 05))

			cReturn := cFilterQuery
		Else //Else Create WHERE
		EndIf
	EndIf
Return cReturn

/*/{Protheus.doc} RUViewData
Return of aHeader e aCols according query.

@type function
@author Alison Kaique
@since Apr|2019
@param cQuery, character, String Query
@return aReturn, array, aHeader and aCols
/*/
Function RUViewData(cQuery)
	Local aReturn    := {}
	Local aStruQuery := {}
	Local aHeadRet   := {}
	Local aColsRet   := {}
	Local bOldError  := Nil //code-block Error
	Local _nI		:= 0
	Local cAlias 	:= GetNextAlias()

	Private cErrSQL  := ""
	Private cSQLOld  := cQuery

	Default cQuery   := ""
	If !Empty(cQuery)
		//Save ERP State
		SaveInter()
		//Query Transaction
		Begin Transaction
			//code-block error
			bOldError := ErrorBlock( {|x| VerifyError(x)} )
			//Query Sequence
			Begin Sequence
				If Select(cAlias) > 0
					(cAlias)->(dbCloseArea())
				EndIf

				//Save query log execution, used for debug
				//MEMOWRITE("\system\Query_Engine-" + Lower(AllTrim(F6R->F6R_CODQRY)) + ".log", cQuery)

				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
				//MPSysOpenQuery( changeQuery(cQuery), cAlias )  //Execute the query

				//Query Struct
				aStruQuery := (cAlias)->(dbStruct())

				//Loop data and get maximun values for numeric, necessary to create picture flexible - this could make routine slow
				///////  PERFORMANCE REDUCED WHEN USE   ///////
				//Set picture at subquery to avoid this point.
				For _nI := 1 to len(aStruQuery)
					If aStruQuery[_nI,2] == 'N' //Numeric sum the totals amount
						//Check if this field are at SX3, we will skip that
						If valtype(GetSx3Cache(PADR(aStruQuery[_nI,1], 10),"X3_TIPO")) == 'U' //means not foud at SX3
							F6S->(DBSetOrder(1)) //check if user predfined the masc, if not will be calculated
							F6S->(DBSeek(FWxFilial("F6S") + F6R->F6R_CODQRY + aStruQuery[_nI,1]))
							If (F6S->(found()) .and. Empty(F6S->F6S_MASCAR)) .or. F6S->(!found())
								//If found, set value as zero
								nPos := AScan(aMaxVal, {|x| AllTrim(x[01]) == aStruQuery[_nI,1]})
								If nPos <= 0
									aAdd(aMaxVal,{aStruQuery[_nI,1],0})
								Endif
							Endif
						Endif
					Endif
				Next
				DbSelectArea(cAlias)
				(cAlias)->(DbGoTop())
				While !(((cAlias))->(eof()))
					For _nI := 1 to len(aMaxVal)
						If AScan(aStruQuery, {|x| AllTrim(x[01]) == aMaxVal[_nI,1]}) > 0
							aMaxVal[_nI,2] += ((cAlias))->(&(aMaxVal[_nI,1]))
						Endif
					Next
					(((cAlias))->(dbSkip()))
				Enddo

				//Handling for aHeader
				aHeadRet := RUHeader(aStruQuery,)

				(cAlias)->(dbCloseArea())
			Recover
				//Restore ERP State
				RestInter()
				//Restore Transaction
				DisarmTransaction()
			End Sequence
			//Restore old error
			ErrorBlock( bOldError )
		End Transaction
		If !(Empty(cErrSQL))
			Aviso("RUViewData", STR0014 + CRLF + AllTrim(cErrSQL), {STR0015}, 03) //Problem with Query. Don't possible exibe the data # Close
		EndIf
	Else
		Aviso("RUViewData", STR0014, {STR0015}, 03) //Problem with Query. Don't possible exibe the data # Close
	EndIf

	AAdd(aReturn, aHeadRet)
	AAdd(aReturn, aColsRet)
Return aReturn

/*/{Protheus.doc} VerifyError
Returns Fatal Error in Process

@author Alison Kaique
@since Apr|2019
@version 1.0
/*/
Static Function VerifyError(e)
	Local lRet 		 := .F.
	Local cErrorText := ''

	If e:GenCode > 0
		cErrorText := STR0016 + e:Description + CRLF + CRLF //"DESCRIPTION: "
		cErrorText += STR0017 + CRLF //"ERRORSTACK: "
		cErrorText += e:ErrorStack

		//Adicionando Erro
		cErrSQL += STR0018 + CRLF + cSQLOld + CRLF + CRLF + cErrorText + CRLF //'SQL Query: '

		lRet := .T.

		Break
	EndIf
Return lRet

/*/{Protheus.doc} RUHeader
Header for MsNewGetDados.

@type function
@author Alison Kaique
@since Apr|2019
@param aStruPar, array, Query Struct
@return aReturn, Header Array for MsNewGetDados
/*/
Static Function RUHeader(aStruPar, cCodQryPri)
	Local aReturn     := {}
	Local aAuxRet     := {}
	Local cSeekField  := ""
	Local cFieldTitle := ""
	Local cField      := ""
	Local cFieldClick := ""
	Local cPicture	  := ""
	Local lDefault    := .T.
	Local lFieldSeek  := .F.
	Local ii          := 0
	Local lDescr	 := .T.
	Local nPos := 0
	Local nPos2 := 0
	Local cFunc := ''
	Local _dec := 0
	Local aDecimals :=  {}


	Default aStruPar 	:= {}
	Default cCodQryPri	:= F6R->F6R_CODQRY

	aColFilter := {}//Array with columns for filter

	For ii := 1 To Len(aStruPar)
		lDescr := .T.
		cPicture	  := ""
		cFieldClick := AvKey(aStruPar[ii][1], "F6S_CPOQRY")
		cSeekField  := PADR(aStruPar[ii][1], 10)

		SX3->(DBSetOrder(2)) //X3_CAMPO
		lFieldSeek := SX3->(DBSeek(cSeekField))

		If !lFieldSeek
			F6S->(DBSetOrder(1)) //F6S_FILIAL, F6S_CPOQRY,Field
			If F6S->(DBSeek(FWxFilial("F6S") + cCodQryPri + cFieldClick))
				If !Empty(F6S->F6S_LABEL)
					cFieldTitle	:= alltrim(F6S->F6S_LABEL)
					cField		:= aStruPar[ii][1]
					lDescr := .F.
				EndIf
				If !Empty(F6S->F6S_MASCAR)
					cPicture    := alltrim(F6S->F6S_MASCAR)
					lDescr := .F.
				EndIf
				If Empty(cPicture) .and. len(aMaxVal) > 0
					_dec := 0
					//Get total amount and calculate mask
					nPos :=  AScan(aMaxVal, {|x| AllTrim(x[01]) == AllTrim( aStruPar[ii][1])})
					If nPos > 0 //found at total array
						//get information about decimals at query definition
						cFunc := alltrim(F6R->F6R_FUNCTI) +'()'
						aDecimals :=  &(cFunc)[8]
						nPos2 :=  AScan(aDecimals, {|x| AllTrim(x[01]) == AllTrim( aStruPar[ii][1])})
						If nPos2 > 0
							If len(aDecimals[nPos2]) > 5 //Has decimal defined
								_dec := aDecimals[nPos2,6]
							ElseIf at('.',cvaltochar(aMaxVal[nPos,2])) <= 0 //no decimal
								_dec := 0
							else
								_dec := len(;
									substring(;
										cvaltochar(aMaxVal[nPos,2]),;
										at('.',cvaltochar(aMaxVal[nPos,2]))+1,;
										len(cvaltochar(aMaxVal[nPos,2]));
									);
								)
							EndIf
						Endif
						cPicture := RU99X0512(aMaxVal[nPos,2],_dec) //get Picture
					EndIf
				Endif
			EndIf

			If lDefault
				/*/
				--------------------------------------------------
				Treatment for fields returned from the query
				that do not exist in the dictionary (SX3).
				--------------------------------------------------
				/*/
				If aStruPar[ii][2] == "C"
					cSeekField := "B1_COD"
				ElseIf aStruPar[ii][2] == "N"
					cSeekField := "F4C_VALUE "
				ElseIf aStruPar[ii][2] == "D"
					cSeekField := "C5_EMISSAO"
				EndIf

				SX3->(DBSetOrder(2)) //X3_CAMPO
				SX3->(DBSeek(cSeekField))
				If lDescr
					cFieldTitle	:= aStruPar[ii][1] //Row Number
					cField		:= aStruPar[ii][1]
					cPicture    := SX3->X3_PICTURE
				Endif
			EndIf //lDefault
		Else
			//Check if there are a new description for this field, somethimes even fields are at SX3 we could change the label
			F6S->(DBSetOrder(1)) //F6S_FILIAL, F6S_CPOQRY,Field
			If F6S->(DBSeek(FWxFilial("F6S") + cCodQryPri + cFieldClick))
				cFieldTitle	:= alltrim(F6S->F6S_LABEL)
			else
				cFieldTitle	:= X3Titulo()
			EndIf
			cField		:= SX3->X3_CAMPO
			cPicture    := SX3->X3_PICTURE

			//Array with columns used at filter, for temporary table we need to build this manually.
			aAdd(aColFilter, {cField, alltrim(cFieldTitle),GetSx3Cache(cField,"X3_TIPO") ,GetSx3Cache(cField,"X3_TAMANHO"),GetSx3Cache(cField,"X3_DECIMAL"),alltrim(cPicture) })
		EndIf //lFieldSeek

		aAuxRet := {}
		AAdd(aAuxRet, cFieldTitle)
		AAdd(aAuxRet, cField)
		AAdd(aAuxRet, cPicture)
		AAdd(aAuxRet, SX3->X3_TAMANHO)
		AAdd(aAuxRet, SX3->X3_DECIMAL)
		AAdd(aAuxRet, SX3->X3_VALID)
		AAdd(aAuxRet, SX3->X3_USADO)
		AAdd(aAuxRet, SX3->X3_TIPO)
		AAdd(aAuxRet, SX3->X3_F3)
		AAdd(aAuxRet, SX3->X3_CONTEXT)


		AAdd(aReturn, ACLONE(aAuxRet))
	Next ii
Return aReturn

/*/{Protheus.doc} RUNewGet
Data Load

@type function
@author Alison Kaique
@since Apr|2019
@param aHeadPar, array, Header of Parameters
@param aColsPar, array, Cols of Parameters
/*/
Static Function RUNewGet(aHeadPar, aColsPar, lDouble, cQueryExec)
	Local aStruct  := {}
	Default lDouble  := .T.

	//Query Struct
	If Select("TTAB") > 0
		TTAB->(dbCloseArea())
	EndIf

	PlsQuery(cQueryExec, "TTAB")

	aStruct :=  TTAB->(dbStruct())

	//Creation for Temporary Table
	cTabExec  := RuCreateTab(aStruct,cQueryExec)
	cAlisScre := cTabExec
	cQueryScre := cQueryExec //Save Query executed to this screen

	DBSelectArea(cTabExec)
	(cTabExec)->(DBGoTop())

	If oFWBrowse <> Nil
		//oFWBrowse:Destroy()
		oFWBrowse:DeActivate()
		oFWBrowse := Nil
	EndIf

	If oBrowseTot <> Nil
		//oBrowseTot:Destroy()
		oBrowseTot:DeActivate()
		oBrowseTot := Nil
	EndIf
	
	oViewData:FreeChildren()

	//RUFWMBrowse(@oViewData,@oFWBrowse,aHeadPar,cTabExec,RUHeader(aStruct), .T.)
	RU99X0507(@oViewData,@oFWBrowse,aHeadPar,cTabExec,RUHeader(aStruct), .T.)
Return

/*/{Protheus.doc} RUDblClick
Double Click Function

@type function
@author Alison Kaique
@since Apr|2019
/*/
Static Function RUDblClick(aGroupBy)
	Local aArea        := GetArea()
	Local aF6QArea     := F6Q->(GetArea())
	Local aF6RArea     := F6R->(GetArea())
	Local aF6SArea     := F6S->(GetArea())
	Local aTMPArea     := {}

	Local nLinClick    := oFWBrowse:At()
	Local nColClick    := oFWBrowse:ColPos()
	Local ii           := 0

	Local aHeadScreen  := {}
	Local aDataClick   := {}
	Local aGrpSX1      := {}
	Local aRetVis      := {}

	Local cFieldClick  := ""
	Local cCodQryPri   := F6R->F6R_CODQRY
	Local cNewCodQry   := ""
	Local cGrpSX1      := ""
	Local cQuery       := ""

	Local aRelations   := {} //Relations (SX9)
	Local cFileDomain  := "" //File Name of Domain Table
	Local cFileSysObj  := "" //Object from File
	Local cFileTitle   := "" //Title from File
	Local aRUSeek      := {} //Seek
	Local aChooseRel   := {} //Title of Relations to choose
	Local nPosRelation := 0 //Position of chosen Relation

	Local aStruct      := {}
	Local cCurrAlias   := ""
	Local cFilter      := ""
	Local cTitleGroup  := ""
	Local cIndField		:= ""
	Local aIndField		:= {}
	Local cFidlCh	as Character
	Local cFilBkp 	as Character
	Local cModoEmp 	as Character
	Local cModoUn 	as Character
	Local cModoFil 	as Character
	Local cNewFil 	as character
	Local cNewEmp 	as character
	Local aAreaM0  as Array
	Local oBackGetData := oGetData
	Local aSubQuery as Array // array with fields to subquery selection

	Default aGroupBy := {}

	//Check if there hiden columns, we cannot make drill drown if there any hidden columns
	If type("oFWBrowse:oconfig:adelcolumns") <> 'U' .and. len(oFWBrowse:oconfig:adelcolumns) > 0
		Aviso("RUDblClick",STR0052, {STR0015}, 3) //'This functionality are disable when we have hidden collumns at Browse configuration.'
		Return .t.
	Endif

	If type("oFWBrowse:oconfig:aordercolumns") <> 'U' .and. len(oFWBrowse:oconfig:aordercolumns) > 0 // there is changes
		//get original position for this collumn
		For ii:= 1 to len(oFWBrowse:oconfig:aordercolumns)
			If oFWBrowse:oconfig:aordercolumns[ii][1] == nColClick
				nColClick := oFWBrowse:oconfig:aordercolumns[ii][2]
				exit
			Endif
		Next
	Endif

	aAreaM0 := SM0->(GetArea())
	//If its called at doubleclik screen, change the object to get clicked column
	If (ValType(o1TCBrowse) == "O")
		nLinClick    := o1TCBrowse:At()
		nColClick    := o1TCBrowse:ColPos()
		//Check if user change the order at configuration
		If type("o1TCBrowse:oconfig:aordercolumns") <> 'U' .and. len(o1TCBrowse:oconfig:aordercolumns) > 0 // there is changes
			//get original position for this collumn
			For ii:= 1 to len(o1TCBrowse:oconfig:aordercolumns)
				If o1TCBrowse:oconfig:aordercolumns[ii][1] == nColClick
					nColClick := o1TCBrowse:oconfig:aordercolumns[ii][2]
					exit
				Endif
			Next
		Endif
	Endif

	If (Select(cTabExec) > 0)
		aTMPArea := (cTabExec)->(GetArea())
	EndIf

	If nLinClick > 0 //Line clik
		cCurrAlias  := cAlisScre // Alias at screen
		aStruct     := (cCurrAlias)->(dbStruct())
		aHeadScreen := RUHeader(aStruct, cCodQryPri)
		aAreaTmp    :=(cCurrAlias)->(GetArea())

		aDataClick := {}
		For ii := 1 To Len(aHeadScreen)
			cField := "" + cCurrAlias + "->" + Alltrim(aHeadScreen[ii][2])
			AAdd(aDataClick, &(cField))
		Next ii

		If nColClick > 0
			//Verifiy if a Group By register
			If (Len(aGroupBy) > 0 .AND. !(Empty(cGroupByAlias)))
				aStruct     := (cGroupByAlias)->(dbStruct())
				aHeadScreen := RUHeader(aStruct, cCodQryPri)
				cGrpSX1 := F6R->F6R_X1PERG
				cSelcField := ''

				//Manage Group of Queries
				If !Empty(cGrpSX1)
					aGrpSX1 := RUSX1Trat(cGrpSX1,.F.)
					aGrpSX1 := AClone(aGrpSX1[2])
				Else
					aGrpSX1 := {}
				EndIf

				//Filter
				For ii := 01 To Len(aGroupBy)
					//Seek Field
					nColClick := AScan(aHeadScreen, {|x| AllTrim(x[02]) == AllTrim(aGroupBy[ii])})
					If (nColClick > 0)
						cTitleGroup += AllTrim(aHeadScreen[nColClick, 01]) + IIf(ii == Len(aGroupBy), "", " + ")
						cFilter += IIf(!(Empty(cFilter)), " AND ", "") + AllTrim(aGroupBy[ii]) + " = "
						//Verify Type
						If (ValType((cGroupByAlias)->&(aGroupBy[ii])) == "N") //Numeric
							cFilter += cValToChar((cGroupByAlias)->&(aGroupBy[ii]))
						ElseIf (ValType((cGroupByAlias)->&(aGroupBy[ii])) == "D") //Date
							cFilter += "'" + DToS((cGroupByAlias)->&(aGroupBy[ii])) + "'"
						Else //Others
							cFilter += "'" + (cGroupByAlias)->&(aGroupBy[ii]) + "'"
						EndIf
					EndIf
				Next ii

				//Make New Query
				cQuery := RUNewQry(AllTrim(F6R->F6R_QUERY), aGrpSX1, , , cFilter)

				//Show Screen
				aRetVis   := RUViewData(cQuery)

				AAdd(aFWBrowse, {oFWBrowse, aF6RArea, aAreaTmp})
				MsgRun(STR0009, STR0010, {|| RUScreenDrill(aRetVis[1], aRetVis[2], .F., cQuery, STR0032 + " - " + cTitleGroup)}) //Loading informations... # - WAIT -
			Else
				cFieldClick := aHeadScreen[nColClick][2]

				//Get sources from function
				cFunc := alltrim(F6R->F6R_FUNCTI) +'()'
				aRelations :=  &(cFunc)[11]
				//If found source, check if the fields that we click are configurated
				For ii := 01 To Len(aRelations)
					//Seek in Domain SX2
					If (alltrim(aHeadScreen[nColClick][2]) $ aRelations[ii,1])
						nPosRelation := ii
						exit
					EndIf
				Next ii

				If len(aRelations) > 0 .and. nPosRelation > 0

					//Check if all necessaryes fields are on header(user can remove some fields that we need to seek)
					aIndField := StrTokArr( upper(aRelations[nPosRelation,2]), '+' ) //default optional fields
					cIndField := ''
					For ii := 01 To Len(aIndField) //Check fields are at header
						cFidlCh := alltrim(aIndField[ii])
						//If there are relate to xfilial, skip
						If AT('XFILIAL(',cFidlCh) > 0
							Loop
						Endif
						//For PADR, check field
						If AT('PADR(',cFidlCh) > 0
							cFidlCh := substring(cFidlCh,AT('PADR(',cFidlCh)+5,AT(',',cFidlCh)-6)
						EndiF
						//For PADR, check field
						If AT('DTOS(',cFidlCh) > 0
							cFidlCh := substring(cFidlCh,AT('DTOS(',cFidlCh)+5,AT(')',cFidlCh)-6)
						EndiF
						If AScan(aStruct, {|x| x[1]== cFidlCh }) <= 0 //dont found all mandatory header at index
							If ii > 1
								cIndField += ', '
							EndIf
							cIndField += alltrim(cFidlCh)
						Endif
					Next ii

					If !Empty(cIndField)
						Aviso("RUDblClick",STR0034 + cIndField, {STR0015}, 3) //'Fields Necessary for this execution are not selected, please select the fields for exibition: '
						F6S->(dbCloseArea())
						RestArea(aF6QArea)
						RestArea(aF6SArea)
						RestArea(aAreaTmp)
						RestArea(aArea)
						return .t.
					Endif

					DbSelectArea(aRelations[nPosRelation,3])
					DbSetOrder(aRelations[nPosRelation,4])
					If MsSeek(((cCurrAlias)->(&(aRelations[nPosRelation,2]))))
						//Load the variables
						For ii := 1 To Len(aRelations[nPosRelation,6])
							//Create variables necessaries
							//Check if variable doest exist
							If Type(aRelations[nPosRelation,6,ii,1]) == 'U' //Variable existe, dont craete
								&(aRelations[nPosRelation,6,ii,1]+':='+aRelations[nPosRelation,6,ii,2])
							Endif
						Next ii

						//Check if necessary change branch, to open correctly source documents
						cModoEmp	:= FWModeAccess(aRelations[nPosRelation,3],1) //Empresa
						cModoUn		:= FWModeAccess(aRelations[nPosRelation,3],2) //Unidade de Negocio
						cModoFil	:= FWModeAccess(aRelations[nPosRelation,3],3) //Filial
						//Se tabela for compartilhada, grava xFilial
						If ("E" $ (cModoEmp+cModoUn+cModoFil)) .and. aRelations[nPosRelation,7] <> nil
							cFilAnt := (cCurrAlias)->(&(aRelations[nPosRelation,7]))
							SM0->(DbGoTop())
							SM0->(DbSeek(cEmpAnt+cFilAnt))
						Endif

						//&(aRelations[nPosRelation,5]) //open source document
						FWMsgRun(, {|| &(aRelations[nPosRelation,5]) }, STR0037,STR0038)  //"Processing" #### "Waiting."

						//Restore actual values for branch
						RestArea(aAreaM0)
						cFilAnt := cNewFil

					Else
						MSgInfo(STR0039+ alltrim(F6R->F6R_FUNCTI))//'Source Document not found at Function: '
					Endif

				else // procura pelo sx9

					//Verify if Field contains Relations (SX9)
					aRelations := RUSX9Util(, AllTrim(cFieldClick))

					//Show Relations if exists
					If (Len(aRelations) > 0)
						//Choose Relation
						If (Len(aRelations) > 01)
							//Loop in Relations
							For ii := 01 To Len(aRelations)
								//Seek in Domain SX2
								If (SX2->(DBSeek(aRelations[ii, 01])))
									cFileTitle := Capital(AllTrim(X2Nome()))

									AAdd(aChooseRel, cFileTitle)
								EndIf
							Next ii
							//Choose
							nPosRelation := MDConPad(aChooseRel, STR0030, .T.)	//"Choose Relation"
						Else
							nPosRelation := 01
						EndIf

						//Open Relation
						If (nPosRelation > 0)
							//Seek in Domain SX2
							cFileDomain := FWSX2Util():GetFile(aRelations[nPosRelation, 01])
							If (SX2->(DBSeek(aRelations[nPosRelation, 01])))
								//Get Object
								cFileSysObj := AllTrim(SX2->X2_SYSOBJ)
								//Get Title
								cFileTitle := AllTrim(X2Nome())

								//Seek in Register of Domain
								aRUSeek := RUSeek(aRelations[nPosRelation, 01], aRelations[nPosRelation, 02], aRelations[nPosRelation, 03], aRelations[nPosRelation, 04], aRelations[nPosRelation, 05], cCurrAlias, aHeadScreen)
								If (aRUSeek[01])
									//Verify number of registers
									If (aRUSeek[03] == 01)
										//Show register
										RUShowReg(aRelations[nPosRelation, 01], cFileTitle, cFileSysObj, (aRUSeek[02])->NUMREC)
									Else
										//Show List of Registers
										aRetView := RUViewData(aRUSeek[04])
										If (Len(aRetView[1]) > 0 .OR. Len(aRetView[2]) > 0)
											AAdd(aFWBrowse, {oFWBrowse, aF6RArea, aTMPArea})
											MsgRun(STR0009, STR0010, {|| RUScreenDrill(aRetView[1], aRetView[2], .F., aRUSeek[04], STR0032, {aRelations[nPosRelation, 01], cFileTitle, cFileSysObj})}) //Loading informations... # - WAIT -
										EndIf
									EndIf
								Else
									Help(" ", 1, "RUDblClick", , STR0033, 4, 15) //No found registers from this relation
								EndIf
							EndIf
						EndIf
					ElseIf (ValType(o1TCBrowse) <> "O") //TODO avoid open drilldrow more than once, if we need should be change and test here
						F6S->(DBSetOrder(1)) //F6S_FILIAL, F6S_CODQRY
						If F6S->(DBSeek(FWxFilial("F6S") + cCodQryPri + cFieldClick))
							cQuery := F6S->F6S_QRYMEM
							aSubQuery := {}

							If !Empty(cQuery)
								cGrpSX1 := alltrim(F6R->F6R_X1PERG)
								cTitTela := alltrim(F6S->F6S_TITSUB)
								cSelcField := RU99X0505(.F.,"DRILL") //Update fields saved before

								//Manage Group of Queries
								If !Empty(cGrpSX1)
									aGrpSX1 := RUSX1Trat(cGrpSX1,.F.)
									aGrpSX1 := ACLONE(aGrpSX1[2])
								Else
									aGrpSX1 := {}
								EndIf

								//Manage Fields in Screen
								For ii := 1 To Len(aHeadScreen)
									cChangeField := Alltrim(aHeadScreen[ii][2])
									AAdd(aSubQuery, {UPPER(cChangeField), aDataClick[ii]})
									cTitTela := StrTran(cTitTela, Alltrim(aHeadScreen[ii][2]), Alltrim(cValToChar(aDataClick[ii])))
								Next ii

								cNewQuery := RUNewQry(cQuery, aGrpSX1, , , , aSubQuery)
								aRetVis   := RUViewData(cNewQuery)

								AAdd(aFWBrowse, {oFWBrowse, aF6RArea, aAreaTmp})
								MsgRun(STR0009, STR0010, {|| RUScreenDrill(aRetVis[1], aRetVis[2], .T., cNewQuery, cTitTela)}) //Loading informations... # - WAIT -
							EndIf //!Empty(cQuery)
						EndIf //F6S Seek
					EndIf //Relations (SX9)
				Endif // Relation at Function/manually when we dont have corrected at SX9
			EndIf //Group By
		EndIf //nColClick
	EndIf //nLinClick

	F6S->(dbCloseArea())
	RestArea(aF6QArea)
	RestArea(aF6SArea)
	RestArea(aAreaTmp)
	RestArea(aArea)
Return

/*/{Protheus.doc} RU99X0501
TReport Print

@type function
@author Alison Kaique
@since Apr|2019
/*/
Function RU99X0501()
	Local cAliasGen := cAlisScre//cAliasPri
	Local aStruct   := {}
	Local aTMPData  := {}

	Private oReport   := Nil
	Private oSection0 := Nil

	//Verify if area exists
	If (!(Empty(cAliasGen)) .AND. Select(cAliasGen) > 0)
		aStruct   := (cAliasGen)->(dbStruct())
		aTMPData  := (cAliasGen)->(GetArea())

		oReport := RUCRIAWZD(cAliasGen,aStruct)
		oReport:PrintDialog()

		RestArea(aTMPData)
	EndIf
Return

/*/{Protheus.doc} RUCRIAWZD
Wizard for Report Print

@type function
@author Alison Kaique
@since Apr|2019
@param cAliasGen, caracter, General Alias
@param aStruQuery, array, Struct Query
@return oReport, object, TReport's object
/*/
Static Function RUCRIAWZD(cAliasGen, aStruQuery)
	Local cRelName  := "RU99X0501"
	Local cTitle    := Capital(Alltrim(F6R->F6R_TITULO))
	Local ii        := 0
	Local cFieldImp := ""
	Local aHeadPar 	:= RUHeader(aStruQuery)
	Local cTrCell   := ""

	//Creation of TReport Object
	oReport := TReport():New(cRelName, cTitle, , {|oReport| RURelData(aHeadPar, cAliasGen)}, cTitle)
	oReport:SetPortrait()

	//Section STATUS
	oSection0 := TRSection():New(oReport, , {}, {})
	oSection0:SetTotalInLine(.F.)

	//oSection0:SetLineStyle()

	For ii := 1 To Len(aHeadPar)
		cFieldImp := "FLD" + StrZero(ii,6)
		cTrCell := "TRCell():New(oSection0,'" + aHeadPar[ii][2] + "',,'" + aHeadPar[ii][1] + "','" + aHeadPar[ii][3] + "'," + Alltrim(Str(aHeadPar[ii][4])) + ",,{|| " + cFieldImp + "})"
		&(cTrCell)
	Next ii
Return oReport

/*/{Protheus.doc} RURelData
Auxiliary Function for Report Print

@type function
@author Alison Kaique
@since Apr|2019
@param aHeadPar, array, Header
@param cAliasGen, caracter, General Alias
/*/
Static Function RURelData(aHeadPar, cAliasGen)
	Local kk         := 1
	Local cFieldCont := ""
	Local cDataField := ""
	Local cData      := ""

	oReport:SetMeter(0)

	(cAliasGen)->(DBGoTop())
	While(cAliasGen)->(!EOF())
		oReport:IncMeter()

		For kk := 1 To Len(aHeadPar)
			If oReport:Cancel()
				oReport:SkipLine()
				oReport:PrintText(STR0019) //"*** Cancel by Operator ***"
				Exit
			EndIf

			cFieldCont    := "FLD" + StrZero(kk,6)
			cDataField    := cAliasGen + "->" + aHeadPar[kk][2]
			cData         := &(cDataField)
			&(cFieldCont) := cData
		Next kk

		oSection0:Init()
		oSection0:PrintLine()

		(cAliasGen)->(dbSkip())
	EndDo

	oSection0:Finish()

	(cAliasGen)->(DBGoTop())
Return

/*/{Protheus.doc} RU99X0504
Export for Excel

@type function
@author Alison Kaique
@since Apr|2019
/*/
Function RU99X0504()
	Local cAliasGen := cAlisScre//cAliasPri //Alias of View
	Local aStruct   := {} //Struct
	Local aTMPData  := {} //Temporary Data Status
	Local aData     := {} //Data provided by Alias
	Local cPath     := AllTrim(GetTempPath())//"\ManagerialViews\" //Path to Export
	Local cFile     := '' //File Name
	Local cLibVer   := '' //Remote Type according Lib
	Local oExcel    := Nil //Object Excel
	Local oExcelApp := Nil //Object Excel App
	Local cFolder   := cViewCode //Folder Name
	Local cTabTitle := "" //Table Title
	Local nI        := 0 //Loop Control
	Local aLine     := {} //Line Control
	Local aGrpSX1 	:= '' //Question

	//Verify if area exists
	If (!(Empty(cAliasGen)) .AND. Select(cAliasGen) > 0)
		If (MsgYesNo(STR0027)) //"Do you want Export to Excel the View ?"
			aStruct   := RUHeader((cAliasGen)->(dbStruct()))
			aTMPData  := (cAliasGen)->(GetArea())

			//Verify if Excel was installed
			If !ApOleClient("MSExcel")
				MsgStop(STR0028, "RU99X0504") //"Excel isn't installed"
			Else
				//Get View Description
				F6R->(DBSetOrder(1)) //F6Q_FILIAL, F6Q_CODVIS
				If F6R->(DBSeek(FWxFilial("F6R") + cViewCode))
					oExcel := FWMSExcel():New() //Object Excel
					cFile  := AllTrim(cViewCode) + "_" + DToS(dDataBase) + ".xml" //File Name

					//Create Directory
					MakeDir(cPath)

					cTabTitle := AllTrim(Capital(F6R->F6R_TITULO)) //View Title

					//Folder Creation
					oExcel:AddworkSheet(cFolder)
					//Table Creation
					oExcel:AddTable(cFolder, cTabTitle)

					//Columns Creation
					For nI := 01 To Len(aStruct)
						//Verify Type
						If (aStruct[nI, 08] == "N") //Numeric
							oExcel:AddColumn(cFolder, cTabTitle, AllTrim(aStruct[nI, 01]), 03, 02, .T.)
						ElseIf (aStruct[nI, 08] == "D") //Date
							oExcel:AddColumn(cFolder, cTabTitle, AllTrim(aStruct[nI, 01]), 01, 04, .F.)
						Else //Others
							oExcel:AddColumn(cFolder, cTabTitle, AllTrim(aStruct[nI, 01]), 02, 01, .F.)
						EndIf
					Next nI

					//Exporting
					(cAliasGen)->(DBGoTop())
					While !(cAliasGen)->(EOF())
						aLine := {}
						For nI := 01 To Len(aStruct)
							//Verify Type
							If (aStruct[nI, 08] == "N") //Numeric
								AAdd(aLine, (cAliasGen)->&(aStruct[nI, 02]))
							ElseIf (aStruct[nI, 08] == "D") //Date
								AAdd(aLine, DToC((cAliasGen)->&(aStruct[nI, 02])))
							Else //Others
								AAdd(aLine, (cAliasGen)->&(aStruct[nI, 02]))
							EndIf
						Next nI
						//Add Line
						oExcel:AddRow(cFolder, cTabTitle, aLine)
						(cAliasGen)->(DBSkip())
					EndDo
					(cAliasGen)->(DBGoTop())


					//Add parameters
					If !Empty(F6R->F6R_X1PERG)
						aGrpSX1 := RUSX1Trat(F6R->F6R_X1PERG,.F.)
						aGrpSX1 := aGrpSX1[3]
						If len(aGrpSX1) > 0 //Add Parameter folder
							//Table Creation

							oExcel:AddworkSheet(STR0049)
							oExcel:AddTable(STR0049, STR0049)
							//Columns Creation
							oExcel:AddColumn(STR0049, STR0049, STR0050, 01, 01, .F.)
							oExcel:AddColumn(STR0049, STR0049, STR0051, 01, 01, .F.)
							//Add Lines
							For nI := 01 To Len(aGrpSX1)
								//Verify Type
								If (aGrpSX1[nI, 03] == "N") //Numeric
									oExcel:AddRow(STR0049, STR0049,{aGrpSX1[nI,01],cVAltochar(aGrpSX1[nI,02])})
								ElseIf (aGrpSX1[nI, 03] == "D") //Date
									oExcel:AddRow(STR0049, STR0049,{aGrpSX1[nI,01],dtoc(aGrpSX1[nI,02])})
								Else //Others
									oExcel:AddRow(STR0049, STR0049,{aGrpSX1[nI,01],(aGrpSX1[nI,02])})
								EndIf
							Next nI


						EndIf
					EndIf

					//Generating Excel
					If !(Empty(oExcel:aWorkSheet))
						oExcel:Activate()
						oExcel:GetXMLFile(cFile)

						//Get Lib Version
						GetRemoteType(@cLibVer)

						//Verify O.S.
						If ("WIN" $ AllTrim(cLibVer))
							//Including "\" at end if necessary
							If !(Right(cPath, 01) == "\")
								cPath += "\"
							EndIf
						Else
							//Including "/" at end if necessary
							If !(Right(cPath, 01) == "/")
								cPath += "/"
							EndIf
						EndIf

						CpyS2T("\SYSTEM\" + cFile, cPath)
						oExcelApp := MsExcel():New()
						oExcelApp:WorkBooks:Open(cPath + cFile) //Open spreadsheet
						oExcelApp:SetVisible(.T.)
					EndIf

				Else
					Help(" ", 1, "F6Q_CODVIS", , STR0012, 4, 15) //There is no registered View with this code
				EndIf
			EndIf

			RestArea(aTMPData) //Restore Alias Status
		EndIf
	EndIf
Return

/*/{Protheus.doc} RUChgQry
Make the replace of embedded <table:>, GROUP e <xfilial:>, for respective RetSqlName and FWxFilial.

@type function
@author Alison Kaique
@since Apr|2019
@param cQuery, character, String SQL
@return cReturn, character, Modified String SQL
/*/
Static Function RUChgQry(cQuery)
	Local cSepTable  := "%TABLE:"
	Local cSepFilial := "%XFILIAL:"
	Local cSepField  := "%FIELD:" //fields selected bu user
	Local aQrySep    := Separa(cQuery, cSepTable)
	Local cNewFil    := ""
	Local cNewTab    := ""
	Local cTabQry    := ""
	Local ii         := 1
	Local cReturn    := ""

	Local cModoEmp := ""
	Local cModoUn	 := ""
	Local cModoFil := ""

	//RetSQLName
	For ii := 1 To Len(aQrySep)
		cPercent := SubStr(aQrySep[ii],4,1)
		If cPercent == "%"
			cTabQry := SubStr(aQrySep[ii],1,3)
			cNewTab := RetSqlName(cTabQry)
			cReturn += cNewTab + Space(1)
			cReturn += SubStr(aQrySep[ii],5,Len(aQrySep[ii])) + Space(1)
		Else
			cReturn += aQrySep[ii] + Space(1)
		EndIf
	Next ii

	//FWxFilial
	aQrySep := {}
	aQrySep := Separa(cReturn,cSepFilial)
	cReturn := ""
	For ii := 1 To Len(aQrySep)
		cPercent := SubStr(aQrySep[ii],4,1)
		If cPercent == "%"
			cTabQry := SubStr(aQrySep[ii],1,3)
			cNewFil := "'" + FWxFilial(cTabQry) + "'"
			cReturn += Alltrim(cNewFil) + Space(1)
			cReturn += Alltrim(SubStr(aQrySep[ii],5,Len(aQrySep[ii]))) + Space(1)
		ElseIf cPercent == ":" //Consultilng filial based at the master field
			cTabQry := SubStr(aQrySep[ii],1,3)
			cTabCom := SubStr(aQrySep[ii],5,at('%',aQrySep[ii])-5)
			//Get Filial information
			cModoEmp	:= FWModeAccess(cTabQry,1) //Empresa
			cModoUn		:= FWModeAccess(cTabQry,2) //Unidade de Negocio
			cModoFil	:= FWModeAccess(cTabQry,3) //Filial
			//Se tabela for compartilhada, grava xFilial
			If !("E" $ (cModoEmp+cModoUn+cModoFil))
				cNewFil := "'" + FWxFilial(cTabQry) + "'"
				cReturn += Alltrim(cNewFil) + Space(1)
			Else // algum nivel exclusivo, chegar e gravar correto
				cNewFil := ''
				If cModoEmp $ 'E'
					cNewFil := 'SUBSTRING('+cTabCom+',1,'+cvaltochar(Len(FWSM0LayOut(,1)))+')'
				//Else
				//	cNewFil += "'"+space(FWSM0LayOut(,1))+"'"
				Endif
				If cModoUn $ 'E'
					cNewFil := 'SUBSTRING('+cTabCom+',1,'+cvaltochar(Len(FWSM0LayOut(,1))+Len(FWSM0LayOut(,2)))+')'
				Endif
				If cModoUn $ 'E'
					cNewFil := 'SUBSTRING('+cTabCom+',1,'+cvaltochar(Len(FWSM0LayOut(,1))+Len(FWSM0LayOut(,2))+Len(FWSM0LayOut(,3)))+')'
				Endif
				//replace query
				cReturn += Alltrim(cNewFil) + Space(1)
				aQrySep[ii] := SubStr(aQrySep[ii],2,Len(aQrySep[ii]))
			Endif
			cReturn += Alltrim(SubStr(aQrySep[ii],at('%',aQrySep[ii])+1,Len(aQrySep[ii]))) + Space(1)
		Else
			cReturn += Alltrim(aQrySep[ii]) + Space(1)
		EndIf
	Next ii

	//If User select fields change query
	//Check if i have Group tag
	If AT('%FIELD:',cReturn) > 0
		aQrySep := {}
		aQrySep := Separa(cReturn,cSepField)
		If len(aQrySep) > 0  //if we have group condition, we insert the fields here
			cReturn := ""
			For ii := 1 To Len(aQrySep)
				//look the % that close the group to remove default and insert new fields
				If At(':FIELD%',aQrySep[ii]) > 0 .and. !empty(cSelcField)
					cReturn += cSelcField + Space(1) + SubStr(aQrySep[ii],At(':FIELD%',aQrySep[ii])+7,len(aQrySep[ii])) + Space(1)
				ElseIf  At(':FIELD%',aQrySep[ii]) > 0 //keep default fields
					cReturn += substring(aQrySep[ii],1,At(":FIELD%", aQrySep[ii])-1) + ' ' + SubStr(aQrySep[ii],At(':FIELD%',aQrySep[ii])+7,len(aQrySep[ii])) + Space(1)
				Else
					cReturn += Alltrim(aQrySep[ii]) + Space(1)
				Endif
			Next ii
		elseIf !empty(cSelcField)
			cReturn := "select " + cSelcField + ' From ( '+ cReturn + ' ) as TEMP2 ' //should never be called...
		endif
	Endif
Return cReturn

/*/
{Protheus.doc} RUIntoQuery
Function for include data in Temporary Table

@type function
@author Alison Kaique
@since Apr|2019

@param cQuery, character, String Query
@param aStruPar, array, Parameters Group of Questions
@return	aReturn[1] - Query for Include
		aReturn[2] - Order By
/*/
Function RUIntoQuery(cQuery, aStruPar, cTabExec)
	Local cInsertInto := ""
	Local cReturn     := ""
	Local ii          := 01
	Local aSepQuery   := {}

	cInsertInto := " INSERT INTO " + cTabExec + "("
	For ii := 1 To Len(aStruPar)
		cInsertInto += aStruPar[ii][1] + ","
	Next ii
	cInsertInto := SubStr(cInsertInto,1,Len(cInsertInto)-1)
	cInsertInto += ")"

	aSepQuery := Separa(cQuery, "FROM")

	If Len(aSepQuery) > 0
		cSelect := aSepQuery[1] + Space(1)
		cSelect += "FROM" + Space(1)
		For ii := 2 To Len(aSepQuery)
			cSelect += Alltrim(aSepQuery[ii]) + Space(1)
			If Len(aSepQuery) <> ii
				cSelect += "FROM" + Space(1)
			EndIf
		Next ii

		cReturn := cInsertInto
		cReturn += CRLF + "(" + cSelect + ")"
	Else
		Aviso("RUIntoQuery", STR0014 + CRLF + cQuery, {STR0015}, 3) //"Problem with Query. Don't possible exibe the data" # "Close"
	EndIf

Return {cReturn}

/*/{Protheus.doc} RUExecFunc
Call of Function linked by View

@type function
@author Alison Kaique
@since Apr|2019
/*/
Static Function RUExecFunc()
	Local aParExec     := {}
	Local cFuncExec    := Alltrim(Upper(F6Q->F6Q_FUNCAO))
	Local cTitFuncExec := Alltrim(Capital(F6Q->F6Q_TITFUN))
	Local cCurrAlias   := cAlisScre
	Local aStruAlias   := {}
	Local aTMPArea     := {}
	Local aStruExec    := {}

	If !Empty(cCurrAlias)
		aStruAlias := (cCurrAlias)->(dbStruct())
		aTMPArea   := (cCurrAlias)->(GetArea())
		aStruExec  := RUHeader(aStruAlias)

		AAdd(aParExec, cCurrAlias)
		AAdd(aParExec, aStruExec)

		If !Empty(cFuncExec)
			cMsgYesNo := ""
			cMsgYesNo += STR0020 + Alltrim(cTitFuncExec) + " ( " + cFuncExec + ") ] ?" + CRLF //"Do you want execute the function: [ "
			If ApMsgYesNo(cMsgYesNo)
				If (ExistBlock(cFuncExec))
					ExecBlock(cFuncExec, .F., .F., {aParExec})
				Else
					MsgStop(STR0021, "RUExecFunc") //"Function Not Found"
				EndIf
			EndIf
		EndIf

		RestArea(aTMPArea)
	EndIf
Return

/*/{Protheus.doc} RuCreateTab
Creation of Temporary Table and Object Instance

@type function
@author Alison Kaique
@since Apr|2019
@param aStruct, array, Table Struct
@param cQueryExec, character, String Query
@param lTotals, logical, Totals?
@return cTabExec, character, Alias for Temporary Table
/*/
Static Function RuCreateTab(aStruct, cQueryExec, lTotals)
	Local cTabExec   := ""
	Local cTabDB     := ""
	Local oTempTable := Nil //Temporary Table Object

	Default lTotals  := .F.

	//Instance of Temporary Table
	oTempTable := FWTemporaryTable():New()
	//Set Fields
	oTempTable:SetFields(aStruct)
	//Create
	oTempTable:Create()

	//RealName in DataBase
	cTabDB   := oTempTable:GetRealName()
	//Alias
	If (lTotals)
		cTabTotals := oTempTable:GetAlias()

		//Array of Temporary Tables
		AAdd(aTabExec, {cTabTotals, oTempTable})
	Else
		cTabExec := oTempTable:GetAlias()

		//Array of Temporary Tables
		AAdd(aTabExec, {cTabExec, oTempTable})

		//Add data in Table
		aQuery := RUIntoQuery(cQueryExec,aStruct, cTabDB)
		cQuery := aQuery[1]
		nError := TcSqlExec(cQuery)

		(cTabExec)->(DBGoTop())

		//Refresh Table
		TcRefresh(cTabExec)
	EndIf

Return IIf(lTotals, cTabTotals, cTabExec)

/*/{Protheus.doc} RUScreenDrill
DrillDown Screen for Linked Query

@type function
@author Alison Kaique
@since Apr|2019

@param aHeadPar, array    , Header
@param aColsPar, array    , Columns
@param lDouble , logic    , Is DoubleClick ?
@param cQuery  , character, String Query
@param cTitPar , character, Screen Title
@param aParams , array    , Params to Show Register
@param aGroupBy, array    , Group By Fields
/*/
Static Function RUScreenDrill(aHeadPar, aColsPar, lDouble, cQuery, cTitPar, aParams, aGroupBy)
	Local aScreenSize := GetScreenRes()
	Local oAreaDrill  := Nil
	Local oDrill      := Nil
	Local nWStage     := aScreenSize[1] - 120 //(aScreenSize[1]/80)
	Local nHStage     := aScreenSize[2] - 300 //(aScreenSize[2]/80)
	Local oDialog     := Nil
	Local aStruct     := {}
	Local cTemTabA		as character
	Local cTemQuery		as character //Query before double click
	Local lActv 		:= .F.
	Default aParams  	:= {}
	Default aGroupBy 	:= {}
	Default lDouble 	:= .F.
	//Close Area if selected
	If Select("TTAB") > 0
		TTAB->(dbCloseArea())
	EndIf

	PlsQuery(cQuery, "TTAB")
	aStruct :=  TTAB->(dbStruct())

	//Create Temporary Table
	cTemTabA := cAlisScre
	cTemQuery := cQueryScre
	cTabExec := RuCreateTab(aStruct, cQuery)
	cAlisScre := cTabExec
	cQueryScre:= cQuery

	//Fill Group By Alias
	If (Len(aGroupBy) > 0)
		cGroupByAlias := cTabExec
	EndIf

	DBSelectArea(cTabExec)
	(cTabExec)->(DBGoTop())

	//Is are the first dril drow, create object
	If (ValType(oDrillData) <> "O")
		lActv := .T.
		oAreaDrill := FWArea():New(000, 000, nWStage, nHStage,oDialog, 1, cTitPar)
		oAreaDrill	:CreateBorder(3)
		oAreaDrill:AddSideBar(100, 1, "DRILLDATA")
		oDrill := oAreaDrill:GetSideBar("DRILLDATA")
		oAreaDrill:AddWindow(100, CtbGetHeight(100), "D_DATA", cTitPar, 1, 1, oDrill)
		oAreaDrill:AddPanel(100, 100, "D_DATA",CONTROL_ALIGN_ALLCLIENT)
		oDrillData := oAreaDrill:GetPanel("D_DATA")
	Endif
	If o1TCBrowse <> Nil
		o1TCBrowse:DeActivate()
	EndIf
	RUFWMBrowse(@oDrillData,@o1TCBrowse,aHeadPar,cTabExec,RUHeader(aStruct), lDouble, aParams, aGroupBy,.T.)
	If lActv .and. (ValType(oAreaDrill) == "O")
		If o1TCBrowse <> Nil
			o1TCBrowse:DeActivate()
		EndIf
		oAreaDrill:ActDialog()
		o1TCBrowse := Nil
		cAlisScre := cTemTabA //restore to the main alias
		cQueryScre := cTemQuery //restore to the main query
	Else

	Endif
Return

/*/{Protheus.doc} RUTCBrowse
Creation of TCBrowse

@type function
@author Alison Kaique
@since Apr|2019
@param oObjPanel, object, Panel
@param oTCBrow, object, TCBrowse
@param aHeadPar, array, Header
@param cTabExec, character, Table Alias
@param aStruct, array, Field Struct
@param lDouble, logic, Consider Double Click :
/*/
Static Function RUTCBrowse(oObjPanel, oTCBrow, aHeadPar, cTabExec, aStruct, lDouble, aParams)
	Local oPanel01 := Nil
	Local bField   := Nil
	Local ii       := 0

	Local nX       := 0
	Local aColunaBloco	as array

	Default lDouble   := .T.
	Default aParams   := {}

	nLinAtBrw := 0

	oPanel01 := TPanel():New(0,0,,oObjPanel,,.T.,.T.,NIL,NIL,100,10,.F.,.T.)
	oPanel01:Align := CONTROL_ALIGN_ALLCLIENT

	//Criao e instncia do browse de blocos
	oTCBRow := FWFormBrowse():New()
	oTCBRow:SetDetails(.F.)
	oTCBRow:SetOwner(oPanel01)
	oTCBRow:SetDataTable(.T.)
	oTCBRow:SetTemporary(.T.)
	oTCBRow:SetAlias(cTabExec)
	oTCBRow:DisableReport()
	//oTCBRow:SetVScroll(.F.)

	nCol := 1
	aColunaBloco := {}
	For nX := 1 to Len(aHeadPar)
			bField := &(" {|| "+cTabExec+"->" + aHeadPar[nX][2] + "}")
			cPictCpo := IIF(aHeadPar[nX][8]=="N",aHeadPar[nX][3],Nil)
			AAdd(aColunaBloco,FWBrwColumn():New())
			aColunaBloco[nCol]:SetData(bField)
			aColunaBloco[nCol]:SetTitle(aHeadPar[nX][1])
			aColunaBloco[nCol]:SetPicture(cPictCpo)
			aColunaBloco[nCol]:SetType(aHeadPar[nX][8])
			aColunaBloco[nCol]:SetSize(aHeadPar[nX,4])
			aColunaBloco[nCol]:SetDecimal(aHeadPar[nX,5])
			//aColunaBloco[nCol]:SetReadVar(aStrBloco[nX,1])
			nCol++
	Next nX
	oTCBRow:SetColumns(aColunaBloco)
	oTCBRow:Activate()

Return

/*/{Protheus.doc} RUFWMBrowse
Creation of FWMBrowse

@type function
@author Alison Kaique
@since Apr|2019
@param oObjPanel, object, Panel
@param oFWBrow, object, FWMBrowse
@param aHeadPar, array, Header
@param cTabExec, character, Table Alias
@param aStruct, array, Field Struct
@param lDouble, logic, Consider Double Click :
@param aParams , array    , Params to Show Register
@param aGroupBy, array    , Group By Fields
@param lDrillDown, logic    , called from drilldown
/*/
Static Function RUFWMBrowse(oObjPanel, oFWBrow, aHeadPar, cTabExec, aStruct, lDouble, aParams, aGroupBy, lDrillDown)
	Local oPanel01   := Nil
	Local aFields    := {}
	Local nI         := 0
	Local blDblClick := Nil
	Local bField     := Nil
	Local oFwProfile := Nil
	Local cDescri_ 	as Character
	Local nLinClick as Numeric
	Local nColClick as Numeric
	Local aHeadScreen as Array
	Local cPicDef	as Character
	Local cProfID	as Character

	Default lDouble   := .T.
	Default aParams   := {}
	Default aGroupBy  := {}
	Default lDrillDown := .F.

	nLinAtBrw := 0
	cDescri_ := ' '

	If len(aGroupBy) <= 0
		cDescri_ := &(alltrim(F6R->F6R_FUNCTI)+'()')[5]//alltrim(F6R->F6R_TITULO)
	EndIf

	//Profile id to keep save informations
	cProfID := cvaltochar(val(AllTrim(F6R->F6R_CODQRY)))
	If lDrillDown .and. len(aGroupBy) <= 0//If are drilldown, show field name cliqued and value
		cProfID := "D"+cvaltochar(val(AllTrim(F6R->F6R_CODQRY)))
		nLinClick    := oFWBrowse:At() //Tela anterior
		nColClick    := oFWBrowse:ColPos()
		//Check if user change the order at configuration
		If type("oFWBrowse:oconfig:aordercolumns") <> 'U' .and. len(oFWBrowse:oconfig:aordercolumns) > 0 // there is changes
			//get original position for this collumn
			For nI:= 1 to len(oFWBrowse:oconfig:aordercolumns)
				If oFWBrowse:oconfig:aordercolumns[nI][1] == nColClick
					nColClick := oFWBrowse:oconfig:aordercolumns[nI][2]
					exit
				Endif
			Next			
		Endif
		aHeadScreen := RUHeader((aFWBrowse[len(aFWBrowse),3,1])->(dbStruct()))
		cDescri_ += ' - '+STR0046+': ' + aHeadScreen[nColClick,1] + ', ' + STR0047+ ': '+ Alltrim(transform( (aFWBrowse[len(aFWBrowse),3,1])->&(aHeadScreen[nColClick,2]) , aHeadScreen[nColClick,3]))
	Endif

	//Create Panel
	oPanel01 := TPanel():New(0,0,,oObjPanel,,.T.,.T.,NIL,NIL,100,10,.F.,.T.)
	oPanel01:Align := CONTROL_ALIGN_ALLCLIENT

	//Create profit statement to be possible clear user profile information
	/*oFwProfile	:= FWPROFILE():New()
	oFwProfile:SetUser(RetCodUsr())
	oFwProfile:SetProgram('RU99X05')
	oFwProfile:SetTask('PROTHEUS')
	oFwProfile:SetType('BROWSESCGN')
	oFwProfile:Activate()
	oFwProfile:SetProfile({}) //salva profile vazio
	oFwProfile:Save()
    oFwProfile:DeActivate()
*/

	//Create FWMBrowse
	oFWBrow := FWMBrowse():New()
	oFWBrow:SetAlias(cTabExec) //Temporary Table Alias
	oFWBrow:SetTemporary(.T.) //Using Temporary Table
	oFWBrow:OptionReport(.F.) //Disable Report Print
	oFWBrow:lOptionReport := .F. //Disable Report Print
	oFWBrow:CleanExFilter() //Clean extended filters
	oFWBrow:CleanFilter() //Clean filters
	//oFWBrow:CleanProfile() //Clean profile informations
	oFWBrow:SetProfileID(cProfID) //set the id of profitle
	oFWBrow:SetDescription( cDescri_ )
	oFWBrow:DisableDetails()
	oFWBrow:SetMenuDef( "RU99X05" ) //create menudef
	If (ValType(o1TCBrowse) == "O")
		o1TCBrowse:SetMenuDef( "RU99X05" ) //create menudef
	Endif

	// Filtro
	oFWBrow:SetUseFilter(.T.)//Using Filter
	oFWBrow:SetUseCaseFilter(.T.)
	oFWBrow:SetFieldFilter(aColFilter)
	oFWBrow:SetDBFFilter(.T.)

	//Check if i have collums called RESUL = this colums should be a legend (true = green, false = red), and add filter for filters
	For nI := 01 To Len(aStruct)
		//Fields for legend
		If aStruct[nI, 01] == 'RESULT'
			//Add this field as legnda
			oFWBrow:AddLegend( "alltrim(RESULT) == '.T.'", "GREEN"	, STR0035) //'ok'
			oFWBrow:AddLegend( "alltrim(RESULT) == '.F.'", "RED"	, STR0036) //'Shoud be Checked'
		Endif
	Next


	//Double Click
	If lDouble
		blDblClick := {|| RUDblClick()}
	ElseIf (Len(aParams) > 0)
		blDblClick := {|| RUShowReg(aParams[01], aParams[02], aParams[03], , cTabExec)}
	ElseIf (Len(aGroupBy) > 0)
		blDblClick := {|| RUDblClick(aGroupBy)}
	Else
		blDblClick := {|| AllwaysTrue()}
	EndIf



	//Set Fields
	For nI := 01 To Len(aStruct)
		//Skip field used for legend
		If aStruct[nI, 01] == 'RESULT'
			Loop
		Endif

		aFields := {}
		bField := &(" {|| " + cTabExec + "->" + aStruct[nI][02] + "}")
		//cBoxFields, get description
		//Check if fields are cbox
		If !Empty(GetSx3Cache(aStruct[nI][02],"X3_CBOXENG"))
			bField := &(" {||  RU99X05A2_GetFromCbox('"+aStruct[nI][02]+"',"+cTabExec+"->"+aStruct[nI][02]+")}")
		Endif

		//Get picture for the field, sometimes we can set it manually at subquery routine, here should be used
		cPicDef := aStruct[nI, 03]
		F6S->(DBSetOrder(1)) //F6S_FILIAL, F6S_CPOQRY,Field
		If F6S->(MsSeek(FWxFilial("F6S") + F6R->F6R_CODQRY + aStruct[nI][02]))
			If !Empty(F6S->F6S_MASCAR)
				cPicDef    := alltrim(F6S->F6S_MASCAR)
			EndIf
		EndIf

		AAdd(aFields,;
						{;
							aStruct[nI, 01],; //[01] - Field Description
							bField         ,; //[02] - Data Load Code-Block
							aStruct[nI, 08],; //[03] - Field Type
							cPicDef,; //[04] - Field Picture
							IIf(aStruct[nI, 08] == "N", 02, 01),; //[05] - Align (0=Center, 1=Left or 2=Right)
							aStruct[nI, 04],; //[06] - Field Size
							aStruct[nI, 05],; //[07] - Field Decimals
							.F.            ,; //[08] - Enable Edit?
							{|| .T.}       ,; //[09] - Column Validation Code-Block
							.F.			   ,; //[10] - Show Images?
							blDblClick     ,; //[11] - Double Click Code Block
							               ,; //[12] - Edit Variable
							{|| .T.}	   ,; //[13] - Header Click Code Block
							.F.            ,; //[14] - Deleted? Opcional/optional will be hide on the browse, user can unhide
							.F.            ,; //[15] - Show in Details
							{}              ; //[16] - Enabled Load Data?
						};
			)

		oFWBrow:SetColumns(aFields)
	Next nI


	//Activate
	oFWBrow:Activate(oPanel01)

Return


/*/{Protheus.doc} RUSetColor
Set Background Color

@param cTabExec, character, Table Alias
@param nColor, numeric, Background Color
@param nLines, numeric, Count of Lines
@return nSetColor, numeric, Background Color
/*/
Static Function RUSetColor(nColor)
	Local nSetColor   := 0

	Default nColor  := 536870911

	nSetColor := nColor

Return nSetColor

/*/{Protheus.doc} RUCTbTotal
Create Totals

@param cTabExec, character, Table Alias
@param aStruct, array, Field Struct
/*/
Static Function RUCTbTotal(cTabExec, aStruct)
	Local aArea 	:= GetArea()
	Local aAreaTMP 	:= (cTabExec)->(GetArea())
	Local aFieldNum	:= {}
	Local cField	:= ""
	Local nI		:= 0
	Local cFilterEx	:= ""
	Local aStru2	as Array
	Local aStru3	as Array
	Local aFiedTo 	as Array //fields that should be at total

	//Get array with fields that must by at total
	aFiedTo :=  &((alltrim(F6R->F6R_FUNCTI) +'()'))[13]
	aStru3 := RUHeader(aStruct)
	aStru2 := {} //New structure only with total - need check with marina
	For nI := 01 To Len(aStru3)
		If aStru3[nI, 8] == 'N' .and. AScan(aFiedTo, {|x|alltrim(x[1])==alltrim(aStru3[nI, 2])}) > 0
			aAdd(aStru2,{aStru3[nI,2],aStru3[nI,8],aStru3[nI,4],aStru3[nI,5]})
		EndIf
	Next nI

	cFilterEx := ''
	aFilters := oFWBrowse:FwFilter():GetFilter() // Load standard filter applied at main browser
	For nI := 01 To Len(aFilters)
		If (nI > 1)
			cFilterEx += ' .and. '
		endif
		cFilterEx += aFilters[nI,2]
	Next nI
	IIf(Empty(cFilterEx),cFilterEx := '.T.',.T.)

	(cTabExec)->(DBGoTop())
	While(cTabExec)->(!Eof())
		//Check filter
		If &cFilterEx
			For nI := 01 To Len(aStru2)
				If aStru2[nI, 2] == 'N'
					cField := aStru2[nI, 1]
					nPos := AScan(aFieldNum, {|x| x[1]==cField})
					If nPos > 0
						aFieldNum[nPos, 2] += &((cTabExec)+"->"+aStru2[nI, 1]+"")
					Else
						AAdd(aFieldNum,{aStru2[nI, 1],&((cTabExec)+"->"+aStru2[nI, 1]+"")})
					EndIf
				EndIf
			Next nI
		Endif
		(cTabExec)->(DbSkip())
	EndDo

	If Len(aFieldNum) > 0
		//Create Temporary Table
		cTabTotals := RuCreateTab(aStru2, , .T.)
		//Add register
		If (RecLock(cTabTotals, .T.))
			For nI := 01 To Len(aStru2)
				If aStru2[nI, 2] == 'N'
					cField := aStru2[nI, 01]
					nPos := AScan(aFieldNum, {|x| x[1] == cField})
					If nPos > 0
						(cTabTotals)->&(aStru2[nI, 01]) := aFieldNum[nPos, 02]
					Else
						(cTabTotals)->&(aStru2[nI, 01]) := 0
					EndIf
				ElseIf aStru2[nI, 2] == 'D'
					(cTabTotals)->&(aStru2[nI, 01]) := CToD('//')
				Else
					(cTabTotals)->&(aStru2[nI, 01]) := ''
				EndIf
			Next nI
			(cTabTotals)->(MsUnlock())
		EndIf

		If oTCBrwTot <> Nil
			oTCBrwTot:DeActivate()
			oTCBrwTot := Nil
		EndIf

		//TCBrowse for Totals
		//RUTCBrowse(@oViewTotal, @oTCBrwTot, RUHeader(aStru2), cTabTotals, aStru2, .F.)
	EndIf

	(cTabExec)->(RestArea(aAreaTMP))
	RestArea(aArea)
Return

/*/{Protheus.doc} RUSeek
Seek in register according Domain

@type function
@author Alison Kaique
@since Apr|2019
@param cDomain     , character, Domain Table
@param cCDomain    , character, CDomain Table
@param cParentField, character, Parent Field
@param cChildField , character, Child Field
@param cCondSQL    , character, SQL Condition
@param cCurrAlias  , character, Currently Alias
@param aHeader     , array    , Struct Header
@return lReturn    , logical  , Process Control
/*/
Static Function RUSeek(cDomain, cCDomain, cParentField, cChildField, cCondSQL, cCurrAlias, aHeader)
	Local lReturn   := .T. //Process Control
	Local cQuery    := "" //String Query
	Local aStruct   := (cDomain)->(DBStruct()) //Struct
	Local cBranch   := "" //Branch Field
	Local nI        := 0 //Loop Control
	Local nFields   := 0 //Fields in Query
	Local nMaxFld   := 10 //Max Fields in Query
	Local aParent   := Separa(AllTrim(cParentField), "+") //Parent Fields
	Local aChild    := Separa(AllTrim(cChildField), "+") //Child Fields
	Local aStrTMP   := {} //Struct for Temporary Table
	Local aHeadSX   := {} //New Header
	Local cAliasTMP := "" //Alias for Temporary Table
	Local nCount    := 0 //Count of Registers
	Local aIndexKey := Separa(AllTrim((cCDomain)->(IndexKey(01))), "+") //Key from index 01
	Local cContent  := Nil //Content for WHERE

	Private cAliasSeek := cCurrAlias

	//String Query
	cQuery += "SELECT" + CRLF
	//Fields
	For nI := 01 To Len(aStruct)
		If ("_FILIAL" $ aStruct[nI, 01])
			cBranch := AllTrim(aStruct[nI, 01])
		Else
			//Browse Fields
			If (SX3->(DBSeek(aStruct[nI, 01])))
				If (SX3->X3_BROWSE == "S")
					nFields ++
					cQuery += AllTrim(aStruct[nI, 01]) + IIf(nFields == nMaxFld .OR. nI == Len(aStruct), "", ", ")
					AAdd(aStrTMP, AClone(aStruct[nI]))
				EndIf
			EndIf
		EndIf
		If (nFields == nMaxFld)
			Exit
		EndIf
	Next nI
	//Recno
	cQuery += IIf(Len(aStrTMP) > 0, ", ", " ") + cDomain + ".R_E_C_N_O_ NUMREC" + CRLF
	AAdd(aStrTMP, {"NUMREC", "N", 30, 0})
	//Table
	cQuery += "FROM " + RetSQLName(cDomain) + " " + cDomain + CRLF
	//Inner Join and SQL Condition
	If (Len(aIndexKey) > 0 .AND. !(Empty(cCondSQL)))
		cQuery += "INNER JOIN " + RetSQLName(cCDomain) + " " + cCDomain + " ON" + CRLF
		//Fields
		For nI := 01 To Len(aIndexKey)
			//Verify Content
			If (AScan(aHeader, {|x| AllTrim(x[02]) == AllTrim(aIndexKey[nI])}) > 0)
				//Verify Type
				If (ValType((cCurrAlias)->&(aIndexKey[nI])) == "N") //Numeric
					cQuery += aIndexKey[nI] + " = " + cValToChar((cCurrAlias)->&(aIndexKey[nI])) + " AND" + CRLF
				ElseIf (ValType((cCurrAlias)->&(aIndexKey[nI])) == "D") //Date
					cQuery += aIndexKey[nI] + " = '" + DToS((cCurrAlias)->&(aIndexKey[nI])) + "' AND" + CRLF
				Else //Others
					cQuery += aIndexKey[nI] + " = '" + (cCurrAlias)->&(aIndexKey[nI]) + "' AND" + CRLF
				EndIf
			EndIf
		Next nI
		//SQL Condition
		cQuery += StrTran(AllTrim(cCondSQL), "#", cCDomain + ".") + " AND" + CRLF
		//Delete
		cQuery += cCDomain + ".D_E_L_E_T_ = ' '" + CRLF
	EndIf
	//Where
	cQuery += "WHERE" + CRLF
	//Branch
	If !(Empty(cBranch))
		cQuery += cBranch + " = '" + FWxFilial(cDomain) + "' AND" + CRLF
	EndIf
	//Fields
	If (Len(aParent) == Len(aChild))
		For nI := 01 To Len(aParent)
			//Verify Content
			If (AScan(aHeader, {|x| AllTrim(x[02]) == AllTrim(aChild[nI])}) > 0)
				cContent := (cCurrAlias)->&(aChild[nI])
			Else
				cContent := &(aChild[nI])
			EndIf
			//Verify Type
			If (ValType(cContent) == "N") //Numeric
				cQuery += aParent[nI] + " = " + cValToChar(cContent) + " AND" + CRLF
			ElseIf (ValType(cContent) == "D") //Date
				cQuery += aParent[nI] + " = '" + DToS(cContent) + "' AND" + CRLF
			Else //Others
				cQuery += aParent[nI] + " = '" + cContent + "' AND" + CRLF
			EndIf
		Next nI
	EndIf
	//Delete
	cQuery += cDomain + ".D_E_L_E_T_ = ' '" + CRLF

	//Create new Header
	aHeadSX := RUHeader(aStrTMP)

	//Create Temporary Table
	cAliasTMP := RuCreateTab(aStrTMP, cQuery)

	//Count
	If !(cAliasTMP)->(EOF())
		(cAliasTMP)->(DBGoTop())
		Count To nCount
		(cAliasTMP)->(DBGoTop())
	Else
		lReturn := .F.
	EndIf

Return {lReturn, cAliasTMP, nCount, cQuery}

/*/{Protheus.doc} RUShowReg
Show register according Domain

@type function
@author Alison Kaique
@since Apr|2019
@param cDomain    , character, Domain Table
@param cTitle     , character, Domain Title
@param cFileSysObj, character, Object Routine
@param nRecno     , numeric  , Number of Register (R_E_C_N_O_)
/*/
Static Function RUShowReg(cDomain, cTitle, cFileSysObj, nRecno, cTabExec)
	Local oModelDomain := Nil //MVC Model from File
	Local nRet         := 0 //Ret for View
	Local lProceed     := .T. //Proceed ?

	Default nRecno   := 0
	Default cTabExec := ""

	Private cCadastro  := ""

	If (nRecno == 0)
		If (Select(cTabExec) > 0)
			nRecno := (cTabExec)->NUMREC
		Else
			lProceed := .F.
		EndIf
	EndIf

	If (lProceed)
		//Seek according Recno
		(cDomain)->(DBGoTop())
		(cDomain)->(DBGoTo(nRecno))
		If ((cDomain)->(Recno()) == nRecno)
			//Get MVC Model
			If !(Empty(cFileSysObj))
				oModelDomain := FWLoadModel(cFileSysObj)
			EndIf

			//Verify is exists MVC Model
			//or open View in AxVisual()
			If (ValType(oModelDomain) == "O")
				nRet := FWExecView( cTitle , cFileSysObj, MODEL_OPERATION_VIEW, /*oDlg*/, /*bCloseOnOk*/ , /*bOk*/ , /*nRedutionPerc*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/)
			Else
				cCadastro := cTitle
				nRet := AxVisual( cDomain, nRecno, MODEL_OPERATION_VIEW, /*aAcho*/, /*nColMens*/, /*cMensagem*/, /*cFunc*/, /*aButtons*/, /*lMaximized*/)
			EndIf
		EndIf
	EndIf
Return

/*/{Protheus.doc} RU99X0503
Group By Registers according Indexes

@type function
@author Alison Kaique
@since Apr|2019
/*/
Function RU99X0503()
	Local nChoice   := 0 //Chosen Index
	Local aIndexes  := {} //Indexes for Query
	Local aFieldInd := {} //Fields in Index
	Local aKey      := {} //Key to Group By
	Local cF6RPri   := "" //Query Code
	Local cGrpSX1   := "" //Group of Questions
	Local aGrpSX1   := {} //Group of Questions
	Local cQuery    := "" //String Query
	Local cNewQuery := "" //New String Query
	Local cMsgHelp  := "" //Message Help
	Local aRetView  := {} //View Informations
	Local aF6RArea  := F6R->(GetArea()) //F6R Area
	Local aTMPArea  := {} //Temporary Area

	//Save Temporary Area
	If (Select(cTabExec) > 0) .and. !empty(cTabExec)
		aTMPArea := (cTabExec)->(GetArea())
	EndIf

	//Load Indexes
	F6R->(DBSetOrder(1)) //F6R_FILIAL, F6R_CODVIS
	If F6R->(DBSeek(FWxFilial("F6R") + cViewCode))
		cF6RPri := F6R->F6R_CODQRY
		cGrpSX1 := F6R->F6R_X1PERG
		cQuery  := F6R->F6R_QUERY
		cSelcField := ''

		F6T->(DBSetOrder(1)) //F6T_FILIAL + F6T_CODQRY
		If (F6T->(DBSeek(FWxFilial("F6T") + cF6RPri)))
			While (!F6T->(EOF()) .AND. F6T->F6T_CODQRY == cF6RPri)
				AAdd(aIndexes, AllTrim(F6T->F6T_DESCRI))
				AAdd(aFieldInd, {F6T->F6T_ORDER, AllTrim(F6T->F6T_DESCRI), AllTrim(F6T->F6T_KEY)})
				F6T->(DbSkip())
			EndDo
		EndIf
	Else
		cMsgHelp := CRLF + STR0011 //View not bound to any query
		Help(" ", 1, "F6R_CODVIS", , cMsgHelp, 4, 15)
	EndIf //F6R Seek

	//Show Indexes
	If (Len(aIndexes) > 0)
		nChoice := MDConPad(aIndexes, STR0031, .T.) //Group By
	EndIf

	//Make Query for Group By
	If (nChoice > 0)
		//Manage Group of Questions
		If !Empty(cGrpSX1)
			aGrpSX1 := RUSX1Trat(cGrpSX1)
			If aGrpSX1[1]
				aGrpSX1   := AClone(aGrpSX1[2])
			EndIf //aGrpSX1
		EndIf //cGrpSX1
		//Manage Key to Group By
		aKey := Separa(aFieldInd[nChoice, 03], "+")

		cNewQuery := RUNewQry(cQuery, aGrpSX1)
		aRetView  := RUViewData(cNewQuery)
		If (Len(aRetView[1]) > 0 .OR. Len(aRetView[2]) > 0)
			cNewQuery := RUNewQry(cQuery, aGrpSX1, aKey, aRetView[01])

			cGroupQuery := cNewQuery

			//Show Group By Information
			aRetView := RUViewData(cNewQuery)
			If (Len(aRetView[1]) > 0 .OR. Len(aRetView[2]) > 0)
				AAdd(aFWBrowse, {oFWBrowse, aF6RArea, aTMPArea})
				MsgRun(STR0009, STR0010, {|| RUScreenDrill(aRetView[1], aRetView[2], .F., cNewQuery, STR0031 + " - " + aIndexes[nChoice], , aKey)}) //Loading informations... # - WAIT -
			EndIf
		EndIf
	EndIf
Return


/*/{Protheus.doc} RU99X0505
Selection of fields to be displayed, based on F6R optional fields and profile information
@type function
@author Rafael Goncalves da Silva
@since Dec|2019
/*/
Function RU99X0505(lDisplaySc,cScreen)
Local oDlg 		as object
Local oSay1 	as object
Local oSay2 	as object
Local oFont 	as object
Local aButtons 	as array
Local nList1 	as numeric
Local nList2 	as numeric
Local nOpc 		as numeric
Local nButtPos 	as numeric
Local _nI 		as numeric
Local aAvailble as array
Local aAvailble2  	as array
Local aSelected 	as array
Local aSelected2 	as array //selected default
Local aTemp 	as array
Local cTitle 	as character
Local aNotSx3  	as array
Local oFwProfile  	as object
Local aLoad 	as array //saved view at profile
Local aLoad2 	as array //saved view at profile
Local cType 	as Character
Local oList1 	as object //Possibles fields
Local oList2 	as object //Selected fields in ordem

Default lDisplaySc 	:= .T.
Default cScreen 	:= "MAIN"

cType := 'SCREEN' + cScreen

nButtPos	:=0
nOpc 		:= 2
aButtons	:= {}
cSelcField  := ''
aSelected	:= {}
aSelected2	:= {}
aAvailble	:= {}
aAvailble2	:= {}
aNotSx3		:= {}
aTemp		:= {}

//load possible fields
If cScreen <> 'MAIN'
	aAvailble2 := StrTokArr( F6R->F6R_OPTION, ',' ) //default optional fields
Endif
aSelected2 := StrTokArr( &(alltrim(F6R->F6R_FUNCTI)+'()')[12], ',' ) //default selected fields, only in sx3, fields not at sx3 are mandatory and will be keeped withou user selected

//Load profile statement to be possible keep user profile information if necessary the table is MP_SYSTEM_PROFILE
oFwProfile	:= FWPROFILE():New()
oFwProfile:SetUser(RetCodUsr())
oFwProfile:SetProgram(alltrim(F6R->F6R_FUNCTI))
oFwProfile:SetTask('SALVEFLD')
oFwProfile:SetType(cType)
oFwProfile:Activate()
aLoad := oFwProfile:Load()

//add at aSelected fields saved before
If Len(aLoad) > 0
	cSelcField := aLoad[1] //Update the global variable with the fields
	aSelected := StrTokArr(aLoad[1],',')
	aTemp := aclone(aSelected)
	aSelected := {}
	for _nI := 1 to len(aTemp)
		SX3->(DBSetOrder(2)) //X3_CAMPO
		SX3->(DBSeek(aTemp[_nI]))
		cTitle := X3Titulo()//GetSx3Cache(alltrim(aTemp[_nI]),'X3_TITULO')
		If valtype(cTitle) == 'C'
			aAdd(aSelected,alltrim(aTemp[_nI])+' - '+alltrim(cTitle))
		Else
			aAdd(aNotSx3,aTemp[_nI])
		Endif
	next
EndIf

//get derder for the fields default
aTemp := aclone(aAvailble2)
aAvailble := {}
for _nI := 1 to len(aTemp)
	SX3->(DBSetOrder(2)) //X3_CAMPO
	SX3->(DBSeek(aTemp[_nI]))
	cTitle := X3Titulo()
	//cTitle := GetSx3Cache(alltrim(aTemp[_nI]),'X3_TITULO')
	//Check if this field must be insert at Selected
	If Len(aLoad) > 0 //exist information load from profile, add extra fields at available
		If !(alltrim(aTemp[_nI]) $ aLoad[1])
			If valtype(cTitle) == 'C'
				aAdd(aAvailble,alltrim(aTemp[_nI])+' - '+alltrim(cTitle))
			Else
				aAdd(aNotSx3,aTemp[_nI])
			Endif
		Endif
	else
		If valtype(cTitle) == 'C'
			aAdd(aAvailble,alltrim(aTemp[_nI])+' - '+alltrim(cTitle))
		Else
			aAdd(aNotSx3,aTemp[_nI])
		Endif
	EndIf
next

//get header for the fields configurated at routine (default)
aTemp := aclone(aSelected2)
for _nI := 1 to len(aTemp)
	SX3->(DBSetOrder(2)) //X3_CAMPO
	SX3->(DBSeek(aTemp[_nI]))
	cTitle := X3Titulo()
	//cTitle := GetSx3Cache(alltrim(aTemp[_nI]),'X3_TITULO')
	//Check if this field must be insert at Available
	If Len(aLoad) > 0 //exist information load from profile, add extra fields at available
		If !(alltrim(aTemp[_nI]) $ aLoad[1])
			If valtype(cTitle) == 'C'
				aAdd(aAvailble,alltrim(aTemp[_nI])+' - '+alltrim(cTitle))
			Else
				aAdd(aNotSx3,aTemp[_nI])
			Endif
		Endif
	else
		If valtype(cTitle) == 'C'
			aAdd(aSelected,alltrim(aTemp[_nI])+' - '+alltrim(cTitle))
		Else
			aAdd(aNotSx3,aTemp[_nI])
		Endif
	EndIf
next

oFwProfile:Destroy()
oFwProfile:= Nil

If lDisplaySc
	DEFINE DIALOG oDlg TITLE STR0040 FROM 180,180 TO 650,750 PIXEL // "Fields to be show"

		oFont := TFont():New('Courier new',,-18,.T.)
		oSay1:= TSay():New(40,10,{||STR0041},oDlg,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)//available fields
		oSay2:= TSay():New(40,160,{||STR0042},oDlg,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)//selected fields

		nList1 := 1
		nList2 := 1

		oList1 := TListBox():New(050,007,{|u|If(Pcount()>0,nList1:=u,nList1)},aAvailble,120,150,,oDlg,,,,.T.,,{ || RU99X05A3(1,nList1,@oList1,@oList2,@aAvailble,@aSelected) } )
		oList2 := TListBox():New(050,157,{|u|If(Pcount()>0,nList2:=u,nList2)},aSelected,120,150,,oDlg,,,,.T.,,{ || RU99X05A3(2,nList2,@oList1,@oList2,@aAvailble,@aSelected) } )
		//buttonsZ
		nButtPos:=55
		TButton():New( nButtPos, 132, '//\\', oDlg, { || RU99X05A3(4,nList2,@oList1,@oList2,@aAvailble,@aSelected) }, 20, 10,,,.F.,.T.,.F.,,.F.,,,.F.)
		nButtPos+=15
		TButton():New( nButtPos, 132, '/\', oDlg, { || RU99X05A3(13,nList2,@oList1,@oList2,@aAvailble,@aSelected) }, 20, 10,,,.F.,.T.,.F.,,.F.,,,.F.)
		nButtPos+=15
		TButton():New( nButtPos, 132, '\/', oDlg, { || RU99X05A3(14,nList2,@oList1,@oList2,@aAvailble,@aSelected) }, 20, 10,,,.F.,.T.,.F.,,.F.,,,.F.)
		nButtPos+=15
		TButton():New( nButtPos, 132, '\\//', oDlg, { || RU99X05A3(3,nList2,@oList1,@oList2,@aAvailble,@aSelected) }, 20, 10,,,.F.,.T.,.F.,,.F.,,,.F.)
		nButtPos+=15
		TButton():New( nButtPos, 132, '<=', oDlg, { || RU99X05A3(22,,		@oList1,@oList2,@aAvailble,@aSelected) }, 20, 10,,,.F.,.T.,.F.,,.F.,,,.F.)
		nButtPos+=15
		TButton():New( nButtPos, 132, '<-', oDlg, { || RU99X05A3(2,nList2,	@oList1,@oList2,@aAvailble,@aSelected) }, 20, 10,,,.F.,.T.,.F.,,.F.,,,.F.)
		nButtPos+=15
		TButton():New( nButtPos, 132, '->', oDlg, { || RU99X05A3(1,nList1,	@oList1,@oList2,@aAvailble,@aSelected) }, 20, 10,,,.F.,.T.,.F.,,.F.,,,.F.)
		nButtPos+=15
		TButton():New( nButtPos, 132, '=>', oDlg, { || RU99X05A3(11,,		@oList1,@oList2,@aAvailble,@aSelected) }, 20, 10,,,.F.,.T.,.F.,,.F.,,,.F.)

	ACTIVATE DIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| oDlg:end(), nOpc:=1 },{|| oDlg:end()},,aButtons,,,.F.,.F.,.F.,.T.,.F.)

	If nOpc == 1
		//Crate variable with group information
		cSelcField := ''
		for _nI := 1 to len(aSelected)
			If _nI > 1
				cSelcField += ','
			Endif
			cSelcField += substring(aSelected[_nI],1,AT(' ',aSelected[_nI])-1)
		next

		//save profile statement to be possible keep user profile information
		oFwProfile	:= FWPROFILE():New()
		oFwProfile:SetUser(RetCodUsr())
		oFwProfile:SetProgram(alltrim(F6R->F6R_FUNCTI))
		oFwProfile:SetTask('SALVEFLD')
		oFwProfile:SetType(cType)
		oFwProfile:SetProfile({cSelcField})
		oFwProfile:Save()
		oFwProfile:Destroy()
		oFwProfile:= Nil

		//Close and reload the FWMBrowse
		If (ValType(o1TCBrowse) <> "O") //means are at main Screen

			RU99X0506(F6R->F6R_CODQRY,,cSelcField)

		ElseIf (ValType(o1TCBrowse) == "O")  //called from second screen

			If o1TCBrowse <> Nil //Encerra o browse do drill drowl
				o1TCBrowse:DeActivate()
				o1TCBrowse := Nil
			EndIf
			//Restore main alias(before actual screen) to be possible reopen the dialog
			cAlisScre := aFWBrowse[len(aFWBrowse),3,1]

			//Open Again
			FWMsgRun( , {|| RUDblClick() } ,STR0037,STR0038 )

		Endif
		cSelcField := ''
	Endif
Endif
return cSelcField



/*/{Protheus.doc} RU99X05A3
this function changing number of fields between 2 windows. similar to FAUPDFields
@type function
@author Rafael Goncalves
@since jan|2020
@version P12.1.25
/*/
STATIC Function RU99X05A3( nOption as numeric , nLine as numeric , oList1 as object , oList2 as object, aAvailble,aSelected )
Local nCount as numeric
Local cTempA1 as character
local aTempA1 as array

aTempA1:={}
cTempA1:=''

If nOption == 1
	If Len(aAvailble)>0 //->
		oList2:Add( aAvailble[nLine] )
		If (nLine == 1 ) .and. Len(aAvailble)>1
			oList1:select((nLine+1))
		Else
			oList1:select((nLine-1))
		EndIf
		oList1:Del( nLine )
	Endif
Elseif nOption == 2 //<-
	If Len(aSelected)>1
		oList1:Add( aSelected[nLine] )
		If (nLine == 1 ) .and. Len(aSelected)>1
			oList2:select((nLine+1))
		Else
			oList2:select((nLine-1))
		EndIf
		oList2:Del( nLine )
	Else
		MsgInfo(STR0048)//'At least one field must be selected'
	Endif
Elseif nOption==11
	For nCount:=1 to Len(aAvailble)
		oList2:Add( aAvailble[1] )
		oList1:Del( 1 )
	Next
Elseif nOption==22
	For nCount:=1 to Len(aSelected)-1
		oList1:Add( aSelected[1] )
		oList2:Del( 1 )
	Next
Elseif nOption==13 //   /\
	If nLine!=1 .and. nLine!=0 //  /\ nLine!=0 - for variant when user choised second window and pressed on /\
		cTempA1:= oList2:AITEMS[nLine]  // x:=3
		oList2:Modify((oList2:AITEMS[nLine-1]), nLine) //3:=2
		oList2:select((nLine))
		oList2:Modify(cTempA1, nLine-1)	//
		oList2:select((nLine-1)) //fix for correct plase
	Endif
Elseif nOption==14
	If nLine!=Len(aSelected) .and. nLine!=0 //  \/ nLine!=0 - for variant when user choise 2window and press on \/
		cTempA1 := oList2:AITEMS[nLine] //(5)
		oList2:Modify((oList2:AITEMS[nLine+1]), nLine) //5 := (6)
		oList2:select(nLine) //without this line chosed_line will be not correct.
		oList2:Modify(cTempA1, nLine+1) //6 := (5)
		oList2:select(nLine+1) //without this line chosed_line will be not correct.
	Endif
Elseif nOption==3 // 	\\//

	For nCount:=1 to len(aSelected)
		AADD(aTempA1,oList2:AITEMS[nCount]) //backup all
	Next nCount

	oList2:Modify((oList2:AITEMS[nLine]), len(oList2:AITEMS)) //end := 3
	oList2:select(nLine)
	for nCount:=nLine to len(aSelected)

		If nCount!=len(oList2:AITEMS)
			oList2:Modify(aTempA1[nCount+1], nCount) //3:=4
			oList2:select(nLine)
		Endif
	Next nCount

Elseif nOption==4 // 	 //\\

	For nCount:=1 to len(aSelected)
		AADD(aTempA1,oList2:AITEMS[nCount]) //backup all
	Next nCount

	oList2:Modify((oList2:AITEMS[nLine]), 1) //1 := 3
	oList2:select(nLine)
	for nCount:=2 to len(aSelected)
		If nCount!=nLine+1
			oList2:Modify(aTempA1[nCount-1], nCount) //2:=1
			oList2:select(nLine)
		Else
			nCount:=len(aSelected)
		Endif
	Next nCount

Endif
oList1:refresh()
oList2:refresh()
Return




/*/{Protheus.doc} RU99X05A2_GetFromCbox()
Function to get value from cbox.

cField - Field's ID from SX3, which Combo-box you need.
cValue - Value, that user was selected from Combo-box.

@type function
@author Rafael Goncalves
@since jan|2020
@version P12.1.25 +
/*/
Function RU99X05A2_GetFromCbox(cField as Character, cValue as Character)
Local cString     as Character
Local cContainer  as Character
Local nStrStart   as Numeric
Local nStrtEnd    as Numeric
Local nShift      as Numeric

Default cField := " "
Default cValue 	:= " "

cContainer 	:= ''
cString		:= ''

If !EMPTY(AllTrim(cField))
    cContainer := GetSx3Cache(cField,"X3_CBOXENG")
EndIf

If !EMPTY(AllTrim(cContainer)) .And. !EMPTY(AllTrim(cValue)) .And. cValue $ cContainer
    nShift := AT("=",cContainer)
	nStrStart := AT(cValue,cContainer)+nShift
    nStrtEnd := AT(";",cContainer,nStrStart)
    cString := SubStr(cContainer,nStrStart,nStrtEnd-nStrStart)
EndIf

Return cString




/** {Protheus.doc} MenuDef
menudef

@param: 	Nil .
@return:	aRotina - Array com os itens do menu
@author: 	Rafael Goncalves
@since: 	Jan|2020
@Uso: 		P12.1.25
*/
Static Function MenuDef()
Local aRetM as array
Local aRotina as array
aRotina := {}

If (Type("o1TCBrowse") <> "O") //means are at main Screen
	aAdd( aRotina, { STR0044   , "RU99X0505()"	, 0, 2, 0, Nil } ) //"Change Fields"
		aRetM		:= {}
		aAdd( aRetM, { STR0023   , "RU99X0502(, , 01)"	, 0, 2, 0, Nil } ) //"Order"
		aAdd( aRetM, { STR0029   , "RU99X0502(, , 02)"	, 0, 2, 0, Nil } ) //"Order"
	aAdd( aRotina, { STR0045     , aRetM	, 0, 8, 0, Nil } ) //"Order"
	aAdd( aRotina, { STR0031   , "RU99X0503()"	, 0, 2, 0, Nil } ) //"Group"
	aAdd( aRotina, { STR0049   , "RU99X0506(F6R->F6R_CODQRY)"	, 0, 3, 0, Nil } ) //"Parameters"

else
	aAdd( aRotina, { STR0044   , "RU99X0505(,'DRILL')"	, 0, 2, 0, Nil } ) //"Change Fields"
Endif

//aAdd( aRotina, { STR0003   , "RU99X0501()"	, 0, 8, 0, Nil } ) //"Imprimir"
aAdd( aRotina, { STR0026   , "RU99X0504()"	, 0, 2, 0, Nil } ) //"Excel"

Return( aRotina )


/*/{Protheus.doc} RU99X0507
Creation of FWMBrowse with totals, based at RU06D07

@type function
@author Rafael Goncalves
@since Jan|2020
@param oObjPanel, object, Panel
@param oFWBrow, object, FWMBrowse
@param aHeadPar, array, Header
@param cTabExec, character, Table Alias
@param aStruct, array, Field Struct
@param lDouble, logic, Consider Double Click :
@param aParams , array    , Params to Show Register
@param aGroupBy, array    , Group By Fields
@param lDrillDown, logic    , called from drilldown
/*/
Static Function RU99X0507(oObjPanel, oFWBrow, aHeadPar, cTabExec, aStruct, lDouble, aParams, aGroupBy, lDrillDown)
	Local oPanel01   := Nil
	Local aFields    := {}
	Local nI         := 0
	Local blDblClick := Nil
	Local bField     := Nil
	Local oFwProfile := Nil
	Local cDescri_ 	as Character
	Local nLinClick as Numeric
	Local nColClick as Numeric
	Local aHeadScreen as Array
	Local cPicDef	as Character
	Local aTotal	as array
	Local cProfID	as Character

	Default lDouble   := .T.
	Default aParams   := {}
	Default aGroupBy  := {}
	Default lDrillDown := .F.

	nLinAtBrw := 0
	cDescri_ := ' '

	aTotal := &((alltrim(F6R->F6R_FUNCTI) +'()'))[13] //Fields for totals, if are zero, not display the total at footer

	If len(aGroupBy) <= 0
		cDescri_ := &(alltrim(F6R->F6R_FUNCTI)+'()')[5]//alltrim(F6R->F6R_TITULO)
	EndIf

	//Profile id to keep save informations
	cProfID := cvaltochar(val(AllTrim(F6R->F6R_CODQRY)))

	If lDrillDown .and. len(aGroupBy) <= 0//If are drilldown, show field name cliqued and value
		cProfID :='D'+cvaltochar(val(AllTrim(F6R->F6R_CODQRY))) //new id for drill down routine
		nLinClick    := oFWBrowse:At()
		nColClick    := oFWBrowse:ColPos()
		aHeadScreen := RUHeader((aFWBrowse[len(aFWBrowse),3,1])->(dbStruct()))
		cDescri_ += ' - '+STR0046+': ' + aHeadScreen[nColClick,1] + ', ' + STR0047+ ': '+ Alltrim(transform( (aFWBrowse[len(aFWBrowse),3,1])->&(aHeadScreen[nColClick,2]) , aHeadScreen[nColClick,3]))
	Endif

	//Double Click function
	If lDouble
		blDblClick := {|| RUDblClick()}
	ElseIf (Len(aParams) > 0)
		blDblClick := {|| RUShowReg(aParams[01], aParams[02], aParams[03], , cTabExec)}
	ElseIf (Len(aGroupBy) > 0)
		blDblClick := {|| RUDblClick(aGroupBy)}
	Else
		blDblClick := {|| AllwaysTrue()}
	EndIf


	//Create Panel
	oPanel01 := TPanel():New(0,0,,oObjPanel,,.T.,.T.,NIL,NIL,100,10,.F.,.T.)
	oPanel01:Align := CONTROL_ALIGN_ALLCLIENT

	//Create profit statement to be possible clear user profile information
	/*oFwProfile	:= FWPROFILE():New()
	oFwProfile:SetUser(RetCodUsr())
	oFwProfile:SetProgram('RU99X05')
	oFwProfile:SetTask('PROTHEUS')
	oFwProfile:SetType('BROWSESCGN')
	oFwProfile:Activate()
	oFwProfile:SetProfile({}) //salva profile vazio
	oFwProfile:Save()
    oFwProfile:DeActivate()*/

	// Create container where panels will be situated
	oWin        := FWFormContainer():New(oPanel01) //TODORFL declare variable
	If len(aTotal) > 0 // there is total
		cIdBrowse   := oWin:CreateHorizontalBox( 88 ) // Space that we reserve to the Browse
		cIdTotal    := oWin:CreateHorizontalBox( 12 ) // Space that we reserve to the Totals
	Else
		cIdBrowse   := oWin:CreateHorizontalBox( 100 ) // Space that we reserve to the Browse
	EndIf

	oWin:Activate(oPanel01, .F.)

	// Create panels where browses will be created
	oPanelUp    := oWin:GeTPanel(cIdBrowse) //Panel where we will create the Browse //TODORFL create varaibles
	If len(aTotal) > 0
		oPanelDn    := oWin:GeTPanel(cIdTotal) //Panel where we will create the Total
	EndIf

	//Create FWMBrowse for items
	oFWBrow := FWMBrowse():New()
	oFWBrow:SetAlias(cTabExec) //Temporary Table Alias
	oFWBrow:SetTemporary(.T.) //Using Temporary Table
	oFWBrow:OptionReport(.F.) //Disable Report Print
	oFWBrow:lOptionReport := .F. //Disable Report Print
	oFWBrow:CleanExFilter() //Clean extended filters
	oFWBrow:CleanFilter() //Clean filters
	//oFWBrow:CleanProfile() //Clean profile informations
	oFWBrow:SetProfileID(cProfID) //set the id of profitle
	oFWBrow:SetDescription(cDescri_ )
	oFWBrow:DisableDetails()
	oFWBrow:ForceQuitButton()
	oFWBrow:SetCacheView (.F.)
	oFWBrow:SetMenuDef( "RU99X05" ) // movido botes para menu
	//If (ValType(o1TCBrowse) == "O")
		//o1TCBrowse:SetMenuDef( "RU99X05" ) // movido botes para menu
	//Endif

	// Filtro
	oFWBrow:SetUseFilter(.T.)//Using Filter
	oFWBrow:SetUseCaseFilter(.T.)
	oFWBrow:SetFieldFilter(aColFilter)
	oFWBrow:SetDBFFilter(.T.)

	//Check if i have collums called RESUL = this colums should be a legend (true = green, false = red), and add filter for filters
	For nI := 01 To Len(aStruct)
		//Fields for legend
		If aStruct[nI, 01] == 'RESULT'
			//Add this field as legnda
			oFWBrow:AddLegend( "alltrim(RESULT) == '.T.'", "GREEN"	, STR0035) //'ok'
			oFWBrow:AddLegend( "alltrim(RESULT) == '.F.'", "RED"	, STR0036) //'Shoud be Checked'
		Endif
	Next

	//Set Fields
	For nI := 01 To Len(aStruct)
		//Skip field used for legend
		If aStruct[nI, 01] == 'RESULT'
			Loop
		Endif

		aFields := {}
		bField := &(" {|| " + cTabExec + "->" + aStruct[nI][02] + "}")
		//cBoxFields, get description
		If !Empty(GetSx3Cache(aStruct[nI][02],"X3_CBOXENG"))
			bField := &(" {||  RU99X05A2_GetFromCbox('"+aStruct[nI][02]+"',"+cTabExec+"->"+aStruct[nI][02]+")}")
		Endif

		//Get picture for the field, sometimes we can set it manually at subquery routine, here should be used
		cPicDef := aStruct[nI, 03]
		F6S->(DBSetOrder(1)) //F6S_FILIAL, F6S_CPOQRY,Field
		If F6S->(MsSeek(FWxFilial("F6S") + F6R->F6R_CODQRY + aStruct[nI][02]))
			If !Empty(F6S->F6S_MASCAR)
				cPicDef    := alltrim(F6S->F6S_MASCAR)
			EndIf
		EndIf

		AAdd(aFields,	{;
							aStruct[nI, 01],; //[01] - Field Description
							bField         ,; //[02] - Data Load Code-Block
							aStruct[nI, 08],; //[03] - Field Type
							cPicDef,; //[04] - Field Picture
							IIf(aStruct[nI, 08] == "N", 02, 01),; //[05] - Align (0=Center, 1=Left or 2=Right)
							aStruct[nI, 04],; //[06] - Field Size
							aStruct[nI, 05],; //[07] - Field Decimals
							.F.            ,; //[08] - Enable Edit?
							{|| .T.}       ,; //[09] - Column Validation Code-Block
							.F.			   ,; //[10] - Show Images?
							blDblClick     ,; //[11] - Double Click Code Block
							               ,; //[12] - Edit Variable
							{|| .T.}	   ,; //[13] - Header Click Code Block
							.F.            ,; //[14] - Deleted? Opcional/optional will be hide on the browse, user can unhide
							.F.            ,; //[15] - Show in Details
							{}              ; //[16] - Enabled Load Data?
						};
			)

		oFWBrow:SetColumns(aFields)
	Next nI
	//Activate
	oFWBrow:SetOwner(oPanelUp)
	oFWBrow:Activate()


	//Total Browse at the footer if we have total at query
	IF len(aTotal) > 0
		oBrowseTot:=FWFormBrowse():New()
		oBrowseTot:SetDetails(.F.)
		oBrowseTot:SetDataQuery()
		oBrowseTot:SetAlias(CriaTrab(,.F.))
		FWMsgRun( , {|| oBrowseTot:SetQuery( RU99X0508_QueryTotal(oFWBrow) ) } ,, STR0010 ) //"Wait"


		oBrowseTot:SetColumns( RU99X0509_TotalFields() )
		oBrowseTot:SetOwner(oPanelDn)
		oBrowseTot:DisableReport()
		oBrowseTot:SetVScroll(.F.)
		oBrowseTot:Activate()

		//Filter component
		oFWFilter := FWFilter():New(oFWBrow) // Standard filter of Browse
		oFWBrow:oFWFilter:SetValidExecute({|| RU99X0510_RUSReFilter(oFWBrow) }) // Method used to recalculate the value of the total when we apply the filters to the browse
		//oFWBrow:oFWFilter:DisableSave(.T.) //Disable salve filters
		oFWBrow:SetAfterExec({||oBrowseTot:SetQuery(RU99X0508_QueryTotal(oFWBrow)),oBrowseTot:Refresh()})    //Refresh Total during update of Basic Browse
		oFWBrow:Refresh()
		oBrowseTot:Refresh()
	EndIf
Return .t.


/*/{Protheus.doc} RU99X0508_QueryTotal
This function returns Query for Total
@author Rafael Goncalves
@since jan|2020
@version 1.0
@project MA3 - Russia
/*/
Function RU99X0508_QueryTotal(oBrowseUp)
Local cQuery as Character
Local cSQLFd as Character
Local aStru3	as Array //Structure of the fields for total
Local aStruct	as Array //Structure for fields at total browse
Local aFiedTo 	as Array //List of fields that must be displayed at totals
Local cTab		as Character
Local nI		as Numeric //for control
Local aFilters	as Array //Filter apply at main query
Local cFilterSQL	as Character //filter in SQL

cSQLFd := ''
aFiedTo :=  &((alltrim(F6R->F6R_FUNCTI) +'()'))[13]	// Get array with fields that must by at total
aStruct     := (cAlisScre)->(dbStruct())			// Get Structure of mais alias at screen
aStru3 := RUHeader(aStruct)							//Load labels and fields structures
For nI := 01 To Len(aStru3)
	If aStru3[nI, 8] == 'N' .and. AScan(aFiedTo, {|x|alltrim(x[1])==alltrim(aStru3[nI, 2])}) > 0
		If !Empty(cSQLFd)
			cSQLFd += ' , '
		Endif
		cSQLFd += ' COALESCE(SUM('+alltrim(aStru3[nI][02])+'),0) as _'+alltrim(aStru3[nI][02])+' '
	EndIf
Next nI

If ValType(oBrowseUp)=="O"
	aFilters := oBrowseUp:FwFilter():GetFilter() // Load standard filter
	cFilterSQL := ''
	For nI:=1 to Len(aFilters) // convert standard filters expressions to SQL format
		If !Empty(aFilters[nI][3])
			If Empty(cFilterSQL)
				cFilterSQL:=aFilters[nI][3]
			Else
				cFilterSQL:= cFilterSQL+" AND "+aFilters[nI][3]
			EndIf
		EndIf
	Next nI
Endif

If !Empty(cFilterSQL)
	cFilterSQL := ' where '+cFilterSQL
Endif

cQuery 	:= "SELECT " +cSQLFd+ " FROM ( "+cQueryScre+" ) as TMPTOTAL "+cFilterSQL
cQuery 	:= ChangeQuery(cQuery)
cTab 	:= GetNextAlias()
//dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cTab, .F., .T. )
//Dbselectarea(cTab)
//dbgotop()

Return cQuery


/*/{Protheus.doc} RU99X0509_TotalFields
This function returns Field structure of Total browse based at query selected at screen
@author rafael Goncalves
@since Jan|2020
@version 1.0
@project MA3 - Russia
/*/
Function RU99X0509_TotalFields()
Local aFiedTo 	as Array //List of fields that must be displayed at totals
Local aStru3	as Array //Structure of the fields for total
Local aStru1	as Array //Structure for fields at total browse
Local nI		as Numeric //for control
Local aFields	as Array //field for browse
Local cSQLFd	as Character //fields to calculate the totals

aFields := {}
cSQLFd 	:= ''

//Get array with fields that must by at total
aFiedTo :=  &((alltrim(F6R->F6R_FUNCTI) +'()'))[13]
aStru1  := (cAlisScre)->(dbStruct())
aStru3 	:= RUHeader(aStru1)

//Create list fields from the browse
For nI := 01 To Len(aStru3)
	If aStru3[nI, 8] == 'N' .and. AScan(aFiedTo, {|x|alltrim(x[1])==alltrim(aStru3[nI, 2])}) > 0

		If !Empty(cSQLFd)
			cSQLFd += ' , '
		Endif
		cSQLFd += ' COALESCE(SUM('+alltrim(aStru3[nI][02])+'),0) as _'+alltrim(aStru3[nI][02])+' '


		bField := &(" {|| " + oBrowseTot:cAlias + "->_" + aStru3[nI][02] + "}")

		//Get picture for the field, sometimes we can set it manually at subquery routine, here should be used
		cPicDef := alltrim(aStru3[nI, 03])
		F6S->(DBSetOrder(1)) //F6S_FILIAL, F6S_CPOQRY,Field
		If F6S->(MsSeek(FWxFilial("F6S") + F6R->F6R_CODQRY + aStru3[nI][02]))
			If !Empty(F6S->F6S_MASCAR)
				cPicDef    := alltrim(F6S->F6S_MASCAR)
			EndIf
		EndIf

		AAdd(aFields,	{;
							aStru3[nI, 01]	,; //[01] - Field Description
							bField         	,; //[02] - Data Load Code-Block //TODORFL
							aStru3[nI, 08]	,; //[03] - Field Type
							cPicDef			,; //[04] - Field Picture
							02				,; //[05] - Align (0=Center, 1=Left or 2=Right)
							aStru3[nI, 04]	,; //[06] - Field Size
							aStru3[nI, 05]	,; //[07] - Field Decimals
							.F.            	,; //[08] - Enable Edit?
							{|| .T.}       	,; //[09] - Column Validation Code-Block
							.F.			   	,; //[10] - Show Images?
							{|| .T.}     		,; //[11] - Double Click Code Block
											,; //[12] - Edit Variable
							{|| .T.}	   	,; //[13] - Header Click Code Block
							.F.            	,; //[14] - Deleted? Opcional/optional will be hide on the browse, user can unhide
							.F.            	,; //[15] - Show in Details
							{}              ;  //[16] - Enabled Load Data?
						};
			)
	Endif
Next nI
Return aFields


//-------------------------------------------------------------------
/*/{Protheus.doc} RU99X0510_RUSReFilter
This function will Recalculate the totals of the lines showed in the Grid when we change the Filter
@author Rafael Goncalves
@since jan|2020
@version 1.0
@project MA3 - Russia
/*/
Static Function RU99X0510_RUSReFilter(oBro)
If ValType(oBrowseTot)=="O"
    oBrowseTot:SetQuery(RU99X0508_QueryTotal(oBro))
    oBrowseTot:Refresh()
EndIf
Return (.T.)




//-------------------------------------------------------------------
/*/{Protheus.doc} RU99X0512
This function will define the mask/picture according to the value, for numerical
@author Rafael Goncalves
@since jan|2020
@version 1.0
@project MA3 - Russia
/*/
Static Function RU99X0512(nValue, nDec)
Local	cPic		:=	""
Local	cRetPic		:=	"@E "
Local	nInicio		:=	0

Default nDec := 0

cPic :=  "999,999,999,999,999,999,999,999"+ Iif(nDec>0, ("."+Replicate ("9", nDec)),"")

nLen := Ceiling(len(cvaltochar(nValue))+ Iif(nDec>0,nDec+1,0) + If(nValue>=1000, ((len(cvaltochar(nValue))-nDec) / 3),0))

//
nInicio	:=	Len(cPic)-nLen
nInicio++
//
While (nInicio<=Len(cPic))
	If !(nInicio==Len (cPic)-nLen .And. SubStr(cPic, nInicio, 1)$".,")
		cRetPic	+= SubStr(cPic, nInicio, 1)
	EndIf
	//
	nInicio++
End
//

Return (cRetPic)