#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWBROWSE.CH"
#INCLUDE 'CFG01RUS.CH'

STATIC __oEstrPai
STATIC __cKeyRelat			
STATIC __xValueInt

/*/{Protheus.doc} TDRelation
Standard function for calling the Time Dependency Fields View
@type function
@author andrews.egas
@since 30/03/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function TDRelation()
	
Local oBrowse as object

FWExecView(STR0007 ,'CFG01RUSA',	MODEL_OPERATION_UPDATE , /*oDlg*/ , { || .T. } )

Return NIL

/*/{Protheus.doc} TDMatch
Position on F40 and F41 to open Time dependency Fields
@type function
@author andrews.egas
@since 30/03/2017
@version 1.0
@return ${return}, ${return_description}
/*/
Function TDMatch(cField,cInfoKey)

dbSelectArea("F40")
dbSetOrder(2)
dbgoTop()
dbSelectArea("F41")
dbgoTop()
If F40->(DbSeek(xFilial("F40")+cField))
	__cKeyRelat := TDKey(cInfoKey)
	
	TDRelation() // Main process
EndIf

Return .T.

/*/{Protheus.doc} ModelDef
Model for Time Dependency Fields
@type Static function
@author andrews.egas
@since 30/03/2017
@version 1.0
/*/
Static Function ModelDef()
Local oStruF40 	:= FWFormStruct( 1, 'F40', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruF41 	:= FWFormStruct( 1, 'F41', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModelTD   	:= MPFormModel():New('CFG01RUSA',/*bPreValid*/,,,/*bCancel*/)

oModelTD:AddFields( 'F40MASTER', ,oStruF40)
oModelTD:AddGrid( 'F41DETAIL', 'F40MASTER', oStruF41, , {|| TDLinOk()} ,  , /*bPosVal*/,  )

oModelTD:SetPrimaryKey( { "F40_FILIAL", "F40_ALIAS", "F40_FIELD" } ) //define a chave primaria se nao foi definido no x2

oModelTD:SetRelation( 'F41DETAIL', { { 'F41_FILIAL', 'xFilial( "F41" )' }, { 'F41_ALIAS', 'F40_ALIAS' }, { 'F41_FIELD', 'F40_FIELD' }, { 'F41_RECORI', '(F40->F40_ALIAS)->(Recno())'  }, { 'F41_KEY', "'" + __cKeyRelat + "'" } }, F41->( IndexKey( 1 ) ) )

oModelTD:GetModel( 'F41DETAIL' ):SetUniqueLine( { 'F41_FROM' } )

oModelTD:GetModel( 'F40MASTER' ):SetOnlyView(.T.)
oModelTD:GetModel( 'F40MASTER' ):SetOnlyQuery(.T.)

oModelTD:SetDescription( 'TD Fields' )

oModelTD:GetModel( 'F40MASTER' ):SetDescription( 'Time Dependency' )
oModelTD:GetModel( 'F41DETAIL' ):SetDescription( 'TD Fields'  )


oModelTD:Getmodel("F40MASTER"):Activate()
oModelTD:Getmodel("F41DETAIL"):Activate()
oModelTD:SetPre({|oModelTD| CFG01Pre(oModelTD)})

Return oModelTD


/*/{Protheus.doc} ViewDef
ViewDef for time dependency Fields
@type Static function
@author andrews.egas
@since 30/03/2017
@version 1.0
/*/
Static Function ViewDef()

Local oStruF40 	:= FWFormStruct( 2, 'F40' )
Local oStruF41 	:= FWFormStruct( 2, 'F41' )
Local oModel	:= FWLoadModel("CFG01RUSA")
Local cCampoF3	as char
Local cCampoTit	as char
Local cCampoPic	as char
Local oView

oView := FWFormView():New()

oStruF40:RemoveField("F40_GRID")
oStruF40:RemoveField("F40_ACTIVE")
oStruF40:RemoveField("F40_KEY")
oStruF41:RemoveField("F41_FIELD")
oStruF41:RemoveField("F41_ALIAS")
oStruF41:RemoveField("F41_KEY")
oStruF41:RemoveField("F41_RECORI")


dbSelectArea("SX3")
dbSetOrder(2)
If dbSeek(F40->F40_FIELD)
		
	cType 		:= X3_TIPO
	cCampoF3 	:= X3_F3
	cCampoTit	:= X3TITULO()
	cCampoPic	:= X3_PICTURE
	
	Do Case
	 	Case (cType) == 'C'
	 		oStruF41:RemoveField("F41_INT")
			oStruF41:RemoveField("F41_DATE")
			If !Empty(cCampoF3) 
				oStruF41:SetProperty( "F41_CHAR", MVC_VIEW_LOOKUP,cCampoF3 )
			EndIf
			oStruF41:SetProperty( "F41_CHAR", MVC_VIEW_PICT,	cCampoPic )
			oStruF41:SetProperty( "F41_CHAR", MVC_VIEW_TITULO, cCampoTit)
			
	 	Case (cType) == 'N'
	 		oStruF41:RemoveField("F41_CHAR")
			oStruF41:RemoveField("F41_DATE")
			If !Empty(cCampoF3) 
				oStruF41:SetProperty( "F41_INT", MVC_VIEW_LOOKUP,cCampoF3 )
			EndIf
			oStruF41:SetProperty( "F41_INT", MVC_VIEW_PICT,	cCampoPic )
			oStruF41:SetProperty( "F41_INT", MVC_VIEW_TITULO, cCampoTit)
	 	Case (cType) == 'D'
	 		oStruF41:RemoveField("F41_INT")
			oStruF41:RemoveField("F41_CHAR")
			If !Empty(cCampoF3) 
				oStruF41:SetProperty( "F41_DATE", MVC_VIEW_LOOKUP,cCampoF3 )
			EndIf
			oStruF41:SetProperty( "F41_DATE", MVC_VIEW_TITULO, cCampoTit)
	EndCase
Endif

oView:SetModel( oModel )
oView:AddField( 'FIELD_F40', oStruF40, 'F40MASTER' )
oView:AddGrid( 'VIEW_F41', oStruF41, 'F41DETAIL' )

oView:CreateHorizontalBox( 'TELA1', 25 )
oView:CreateHorizontalBox( 'TELA2', 75 )

oView:SetOwnerView( 'FIELD_F40', 'TELA1' )
oView:SetOwnerView( 'VIEW_F41', 'TELA2' )

oView:EnableTitleView('FIELD_F40' , 'All Time Dependent Fields' )
oView:EnableTitleView('VIEW_F41' , 'Details and Values' )


Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CFG01Pre
Pre Valid to load value dates
@author 	Andrews Egas
@since 16/06/2017
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------
Function CFG01Pre(oModel)
Local lRet as Logical
Local oView as object
Local oDetail := oModel:GetModel('F41DETAIL')
lRet := .T.

If oDetail:Length() < 2 .And. oDetail:GetValue("F41_TO",1) <> CtoD("31/12/9999")

	oDetail:LoadValue("F41_FROM",CtoD("01/01/1900")) //current line with new TO
	oDetail:LoadValue("F41_TO",CtoD("31/12/9999")) //current line with new TO
	If ValType(M->&(AllTrim(F40->F40_FIELD))) == "C"
		oDetail:LoadValue("F41_CHAR",AllTrim(M->&(AllTrim(F40->F40_FIELD))))
	ElseIf ValType(M->&(AllTrim(F40->F40_FIELD))) == "D"
		oDetail:LoadValue("F41_DATE",AllTrim(M->&(AllTrim(F40->F40_FIELD))))
	ElseIf ValType(M->&(AllTrim(F40->F40_FIELD))) == "N"
		oDetail:LoadValue("F41_INT",AllTrim(M->&(AllTrim(F40->F40_FIELD))))
	EndIf

EndIf

Return lRet

/*/{Protheus.doc} TDDescri
Return description for Virtual Field F40_DESC
@type function
@author andrews.egas
@since 30/03/2017
@version 1.0
@return ${X3_DESCRI}
/*/
Function TDDescri()
Local cRet as char

dbSelectArea("SX3")
dbSetOrder(2)
If dbSeek(F40->F40_FIELD)
	cRet := X3Descric()
EndIf
Return cRet

/*/{Protheus.doc} TDFieldActv
First Funcion that must be called to use Time Dependency Fields
@type function
@author andrews.egas
@since 30/03/2017
@version 1.0
/*/
Function TDFieldActv(cInfoKey)
Local oView as object
Local aTest as Array
Local lRet as logical
Local aChk as Array
Local cFieldn as char
Local oModel as object
Local aSaveLines as array
Default cInfoKey 	:= ""

lRet := .F.
aChk := {,}
If FwViewActive() <> NIL
	oView := FwViewActive()
	aTest := oView:GetCurrentSelect() 
	//Toda essa gambiarra e devido a funcaoa cima nao retornar o valor correto no array 2
	aChk := TDCheck( aTest[2] , , .T. )
	lRet := aChk[1]
	oModel	:= FwModelActive()
	aSaveLines := FWSaveRows()
	If aChk[2]
		__oEstrPai := oModel:GetModel(aTest[1])
		if __oEstrPai == NIL
			__oEstrPai := oModel:GetModel(SUBSTR(aTest[2],1,3)+"DETAIL")
			if __oEstrPai == NIL
				__oEstrPai := oModel:GetModel("S" + SUBSTR(aTest[2],1,2)+"DETAIL")
				if __oEstrPai == NIL
					__oEstrPai := oModel:GetModel(SUBSTR(aTest[2],1,3)+"MASTER")
					if __oEstrPai == NIL
						__oEstrPai := oModel:GetModel("S" + SUBSTR(aTest[2],1,2)+"MASTER")
						if __oEstrPai == NIL
							//its just a security condition, never must happen
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		
		cFieldn := aTest[2]
	Else
		If !Empty(ReadVar())
			cFieldn := ReadVar()
			cFieldn := IIF("M->" $ cFieldn, Substr(cFieldn,4, Len(cFieldn)),cFieldn)
			aChk := TDCheck( aTest[2] , , .T. )
			lRet := aChk[1]
		EndIf
	EndIf
Else
	If !Empty(ReadVar())
		cFieldn := ReadVar()
		cFieldn := IIF("M->" $ cFieldn, Substr(cFieldn,4, Len(cFieldn)),cFieldn)
		aChk := TDCheck( cFieldn , , .T. )
		lRet := aChk[1]
		
	EndIf
EndIf

If lRet
	
	__xValueInt := &(ReadVar())
	TDMatch(cFieldn,cInfoKey)
	
	If oModel <> NIL
		FWRestRows(aSaveLines)
		FwModelActive(oModel) //Restore oModel
	EndIf
EndIf

Return

/*/{Protheus.doc} TDFieldActv
Check if the field is in F40 (Time Dependency Field)
@type function
@author andrews.egas
@since 30/03/2017
@version 1.0
@return ${Logical}, ${Return true if the cField is registered in F40}
@return ${Logical}, ${Return true if F40 is Grid}
/*/
Function TDCheck( cField , cAliasChk , lDeleta )

Local cQuery as character
Local aRet as array
Local aArea as array

Default cAliasChk := ''
Default lDeleta := .T.
aRet := {,}
If Empty(cAliasChk)
	cAliasChk := CriaTrab(,.F.)
Endif

aArea 		:= getArea()

cQuery := "SELECT F40_FIELD FROM " + RetSqlName("F40") + CRLF
cQuery += " WHERE F40_FILIAL = '"+xFilial("F40")+"'" + CRLF
cQuery += " AND F40_FIELD = '" + cField + "'" + CRLF
cQuery += " AND F40_ACTIVE = '1'" + CRLF
cQuery += " AND D_E_L_E_T_ = ' ' "

dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQuery ) , cAliasChk )

(cAliasChk)->( dbGoTop() )

aRet[1] 	:= (cAliasChk)->( !EOF() )
if aRet[1]
 aRet[2] := .T.
EndIf
If lDeleta
	(cAliasChk)->( dbCloseArea() )
Endif

RestArea(aArea)

Return aRet


/*/{Protheus.doc} TDKey
Find the unique key of the main table
@type function
@author andrews.egas
@since 30/03/2017
@version 1.0
@return ${cReturn}, ${Key of the main table in F40_ALIAS}
@example
(examples)
@see (links_or_references)
/*/
Function TDKey(cInfoKey)
Local nLine as numeric
Local cF40Key as character
Local cReturn as character
Local aHeadFiel as array
Local nFields as numeric
Local lMVC		as logical
Local lGrid		as logical

lMVC := __oEstrPai <> NIL

cF40Key		:= F40->F40_KEY
lGrid		:= F40->F40_GRID == "1"
cReturn		:= cInfoKey
aHeadFiel 	:= STRTOKARR(cF40Key,'+')


If lGrid
	If lMVC
		nLine		:= __oEstrPai:getLine() 	
		For nFields:=1 to Len(aHeadFiel)
			cReturn += __oEstrPai:GetValue(aHeadFiel[nFields],nLine) //aCols[nLine][nPosField]
		Next
	Else
		nLine := n
		For nFields:=1 to Len(aHeadFiel)
			If aScan(aHeader,{|x| AllTrim(x[2])== aHeadFiel[nFields]}) > 0
				cReturn += aCols[nLine][aScan(aHeader,{|x| AllTrim(x[2])== aHeadFiel[nFields]})]
			EndIf
		Next
	EndIf
Else
	If lMVC 	
		For nFields:=1 to Len(aHeadFiel)
			cReturn += __oEstrPai:GetValue(aHeadFiel[nFields],nLine) //aCols[nLine][nPosField]
		Next
	Else
		For nFields:=1 to Len(aHeadFiel)
			If !"_FILIAL" $ aHeadFiel[nFields]
				cReturn += M->&(aHeadFiel[nFields])
			Else
				cReturn += xFilial(F40->F40_ALIAS)
			EndIf
		Next
	EndIf
EndIf	

Return cReturn

/*/{Protheus.doc} TDGetValue
Function to use when you need take the current value by time dependency field
@type function
@author andrews.egas
@since 30/03/2017
@version 1.0
@return ${xRet}, ${Value of main field}

@param ${cField}, ${Value of main field}
		${dDate}, ${Current Date}
		${nRecn}, ${Table father s recno}
		${lPosic}, ${.T. if is positioned in table father}
/*/
Function TDGetValue(cField, dDate, nRecn, lPosic)

Local cQuery 	as character
Local xRet
Local aArea 	as array
Local cF40Key 	as char
Local aHeadFiel as array
Local nFields 	as numeric
Local cF40Alias	as char
Local cAliasChk := ''

Default dDate := dDatabase
Default nRecn := 0
Default lPosic := .T.

If nRecn == 0 //o key nao precisa ser passado se a tabela estiver posicionada no registro
	dbSelectArea("F40")
	dbSetOrder(2)
	If F40->(DbSeek(xFilial("F40")+cField))
		cF40Alias	:= F40->F40_ALIAS
		nRecn := (cF40Alias)->(Recno()) //Save the table s Recno 
	EndIf
EndIf
cAliasChk := CriaTrab(,.F.)

aArea := getArea()

cQuery := "SELECT F41_CHAR, F41_INT, F41_DATE FROM " + RetSqlName("F41") + CRLF
cQuery += " WHERE F41_FILIAL = '"+xFilial("F41")+"'" + CRLF
cQuery += " AND F41_FIELD = '" + cField + "'" + CRLF
cQuery += " AND F41_RECORI = " + AllTrim(Str(nRecn))  + CRLF
cQuery += " AND '" + DtoS(dDate) + "' >= F41_FROM " + CRLF
cQuery += " AND '" + DtoS(dDate) + "' <= F41_TO " + CRLF
cQuery += " AND D_E_L_E_T_ = ' ' "

dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQuery ) , cAliasChk )

(cAliasChk)->( dbGoTop() )

If (cAliasChk)->( !EOF() )
	If ! Empty((cAliasChk)->F41_CHAR)
		xRet := (cAliasChk)->F41_CHAR
	ElseIf ! Empty((cAliasChk)->F41_INT)
		xRet := (cAliasChk)->F41_INT
	ElseIf ! Empty((cAliasChk)->F41_DATE)
		xRet := (cAliasChk)->F41_DATE
	Else
		If lPosic
			xRet := (F40->F40_ALIAS)->&(cField)
		Else
			xRet := ""
		EndIf
	EndIf 
Else
	If lPosic
		xRet := (F40->F40_ALIAS)->&(cField)
	Else
		xRet := ""
	EndIf
EndIf

(cAliasChk)->( dbCloseArea() )

RestArea(aArea)

Return xRet

/*/{Protheus.doc} TDInitDT
Initial value of the Dates
@type function
@author andrews.egas
@since 30/03/2017
@version 1.0
/*/
Function TDInitDT()
Local dRet as char
Local nLine as numeric
Local oView as Object

oView := FwViewActive()

nLine := oView:GetModel("F41DETAIL"):GetLine()
If 'F41_FROM' $ ReadVar()
	dRet := dDataBase
	//If nLine >= 1
		//dRet := oView:GetModel("F41DETAIL"):GetValue("F41_TO",nLine) + 1
	//EndIf 
Else
	//dRet := CtoD("31/12/9999")
EndIf

Return dRet

/*/{Protheus.doc} TDLinOk
Validation to line
@type function
@author andrews.egas
@since 30/03/2017
@version 1.0
/*/
Function TDLinOk()
Local nLin as numeric
Local oModel 	:= FwModelActive()
Local oView	:= FwViewActive()
Local oDetail := oModel:GetModel('F41DETAIL')
Local lRet		as logical
Local lComplet 	as logical
Local nCurLine as number
lComplet := .F.
lRet := .T.

If Empty(oDetail:GetValue("F41_CHAR")) .And. Empty(oDetail:GetValue("F41_DATE")) .And. Empty(oDetail:GetValue("F41_INT")) .Or. Empty(oDetail:GetValue("F41_FROM"))
	Help(" ",1,"TDFGAPDT")
	lRet := .F.
EndIf

If lRet
	//Grud Validation
	While !lComplet
		lComplet := .T.
		For nLin := 1 to oDetail:Length()
			If !oDetail:IsDeleted(nLin) .And. nLin <> oDetail:Length() 
				If oDetail:GetValue("F41_FROM",nLin) > oDetail:GetValue("F41_FROM",nLin + 1)
					oDetail:LineShift( nLin, nLin + 1 )
					lComplet := .F.
				EndIf
			EndIf
		Next
	EndDo
	
	nCurLine := oDetail:GetLine()
	For nLin := 1 to oDetail:Length()
		oDetail:GoLine(nLin) //change different line
		If nLin == oDetail:Length()
			oDetail:LoadValue("F41_TO",CtoD("31/12/9999"))
		Else
			oDetail:LoadValue("F41_TO",oDetail:GetValue("F41_FROM",nLin + 1)-1)
		EndIf
	Next
	oDetail:GoLine(nCurLine)
	oView:Refresh()
EndIf



Return lRet


/*/{Protheus.doc} TDInitDT
Initial value of the Dates
this function can NOT work when sx3 is not in database
@type function
@author andrews.egas
@since 12/05/2017
@version 1.0
@param ${cTable}, ${Table to update}
		${lBrowse}, ${Just browse field}
		${lRecnoP}, ${Just Table father s recno positioned}
/*/
Function CFGUpdateTDF(cTable,lBrowse,lRecnoP)
Local aArea := GetArea()
Local cAliasUpd	as char 
Local cQuery		as char
Local cAliasF40	as char

Default lBrowse 	:= .F. // if false it will update all fields, if TRUE will update just browse field
Default cTable		:= ""
Default lRecnoP	:= .F. // If .T. update will be just in recno positioned

cAliasF40 := CriaTrab(,.F.)
cQuery := "SELECT  F40_ALIAS, F40_FIELD FROM " + RetSqlName("F40") + " AS F40 " + CRLF
cQuery += " WHERE F40.F40_FILIAL = '"+xFilial("F40")+"'" + CRLF
If !Empty(cTable)
	cQuery += " AND F40.F40_ALIAS = '" + AllTrim(cTable) +"'" + CRLF
	If lBrowse
		cQuery += " AND F40.F40_FIELD = (" + CRLF
		cQuery += " SELECT X3_CAMPO FROM  SX3" + cEmpAnt + "0" + CRLF
		cQuery += " WHERE X3_ARQUIVO = '" + AllTrim(cTable) + "'" +  CRLF
		cQuery += " AND X3_CAMPO = F40.F40_FIELD AND X3_BROWSE = 'S' "
		cQuery += " AND D_E_L_E_T_ = ' ')"
 	EndIf
EndIf
cQuery += " AND D_E_L_E_T_ = ' ' "
	
dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQuery ) , cAliasF40 )
(cAliasF40)->( dbGoTop() )
	

While (cAliasF40)->(!EOF())	
	//query to find distinct recno to update father s table
	cAliasUpd := CriaTrab(,.F.)
	cQuery := "SELECT DISTINCT F41_RECORI " + CRLF
	cQuery += " FROM " + RetSqlName("F41") + CRLF
	cQuery += " WHERE F41_FILIAL = '"+xFilial("F41")+"'" + CRLF
	cQuery += " AND F41_FIELD = '" + AllTrim((cAliasF40)->(F40_FIELD)) + "'" + CRLF
	If lRecnoP
		cQuery	+= " AND F41_RECORI = " + ((cAliasF40)->F40_ALIAS)->(Recno()) + CRLF
	EndIf
	cQuery += " AND D_E_L_E_T_ = ' ' "
	
	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQuery ) , cAliasUpd )
	(cAliasUpd)->( dbGoTop() )
		
	While (cAliasUpd)->(!EOF())
		//execution to take value of Father s table with recno positioned in cAliasUpd
		If !Empty(TDGetValue((cAliasF40)->(F40_FIELD), /*dDate*/, (cAliasUpd)->(F41_RECORI), .F.))
			
			dbSelectArea((cAliasF40)->(F40_ALIAS))
			((cAliasF40)->(F40_ALIAS))->(DbSetOrder(0))
		
			((cAliasF40)->(F40_ALIAS))->(dbGoTo((cAliasUpd)->(F41_RECORI)))
			
			//check if the field needs correction of value
			If ((cAliasF40)->(F40_ALIAS))->(!EOF()) .And. ;
				AllTrim(((cAliasF40)->(F40_ALIAS))->&((cAliasF40)->(F40_FIELD))) != ;
				AllTrim(TDGetValue((cAliasF40)->(F40_FIELD), /*dDate*/, (cAliasUpd)->(F41_RECORI), .F.))
				RecLock((cAliasF40)->(F40_ALIAS),.F.)
					//update father s table with Time dependency field s value
					((cAliasF40)->(F40_ALIAS))->&((cAliasF40)->(F40_FIELD))	:= TDGetValue((cAliasF40)->(F40_FIELD), /*dDate*/, (cAliasUpd)->(F41_RECORI), .F.)
				
				((cAliasF40)->(F40_ALIAS))->(MsUnLock())
			EndIf

		EndIf
		(cAliasUpd)->(dbskip())
	EndDo
		
(cAliasUpd)->( dbCloseArea())

(cAliasF40)->(dbskip())
EndDo
(cAliasF40)->( dbCloseArea())

RestArea(aArea)
Return


/*/{Protheus.doc} TDAjustDt
Ajust Dates From and TO
@type function
@author andrews.egas
@since 15/06/2017
@version 1.0
/*/
Function TDAjustDt()
Local nLin 		as numeric
Local dDateF 		as date
Local lRet 		as logical
Local oModel 	:= FwModelActive()
Local oDetail := oModel:GetModel('F41DETAIL')	
//Lines must to be filled sequentially	
dDateF := M->F41_FROM
lRet := .T.

If oDetail:GetLine() <> 1
	For nLin := 1 to oDetail:Length()
		If nLin <> oDetail:GetLine() .And. !oDetail:IsDeleted(nLin)
			If (oDetail:GetValue("F41_FROM",nLin) == dDateF)
				Help(" ",1,"TDFGAPDT") //already exist this date
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next
Else
	oDetail:LoadValue("F41_FROM",CtoD("01/01/1900"))
EndIf	
	
Return lRet
//merge branch 12.1.19

// Russia_R5
