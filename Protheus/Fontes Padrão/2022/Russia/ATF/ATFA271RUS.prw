#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include 'ATFA271.ch'

#DEFINE SOURCEFATHER "ATFA271"

/*/{Protheus.doc} ATFA271RUS

Fixed Asset Group - Russia

@type function
 
@author Fabio Cazarini
@since 21/04/2017
@version P12.1.17
 
/*/
Function ATFA271RUS()
Local 	oBrowse := BrowseDef()
Private aEnableButtons AS ARRAY

aEnableButtons	:= {{.F.,Nil},;	// 1 - Copiar
					{.F.,Nil},;	// 2 - Recortar
					{.F.,Nil},;	// 3 - Colar
					{.F.,Nil},;	// 4 - Calculadora
					{.F.,Nil},;	// 5 - Spool
					{.F.,Nil},;	// 6 - Imprimir
					{.T.,Nil},;	// 7 - Confirmar
					{.T.,Nil},;	// 8 - Cancelar
					{.F.,Nil},;	// 9 - WalkTrhough
					{.F.,Nil},;	// 10 - Ambiente
					{.F.,Nil},;	// 11 - Mashup
					{.T.,Nil},;	// 12 - Help
					{.F.,Nil},;	// 13 - Formulário HTML
					{.F.,Nil}}	// 14 - ECM

oBrowse:Activate()
Return

Static Function BrowseDef()
Local oBrowse := FwLoadBrw(SOURCEFATHER) 
Return oBrowse

Static Function ModelDef()
Local oModel := FWLoadModel(SOURCEFATHER)
//Local oEvent := ATFA271EVRUS():New()
//oModel:InstallEvent("RUSSIA",,oEvent)	
Return oModel

Static Function ViewDef()
Local oView := FWLoadView(SOURCEFATHER)

oView:AddUserButton(STR0054, "", {|| AF271PRINT() })	//"Print"
oView:SetAfterViewActivate({|oModel| AF271HideF(oModel)})
Return oView

Static Function MenuDef()
Local aRotina := FWLoadMenuDef(SOURCEFATHER)	
Return aRotina

/*/{Protheus.doc} AF271HideF
Hide tab Fiscal
@author Alexandra Menyashina
@since  24/10/2018
@version 1.0
/*/
Function AF271HideF(oView)
Local oView   := FWViewActive()
oView:HideFolder('VIEW_SNG',3,1)  //tab Fiscal
oView:SelectFolder('VIEW_SNG',1,1)
return .T.

/*/{Protheus.doc} AF271UPTXD
Trigger which update FNG_TXDEP* and NG_TXDEPR* 
@author Alexandra Menyashina
@param  lHeader		LOGICAL
@since  31/10/2018
@version 1.0
/*/
Function AF271UPTXD(lHeader AS LOGICAL)
Local oModel		AS OBJECT
Local oView			AS OBJECT
Local oSubModel		AS OBJECT
Local cSubModel		AS CHARACTER
Local cNameTable	AS CHARACTER
Local cFldPeriod	AS CHARACTER
Local nNewPerDep	AS NUMERIC

oModel		:= FWModelActive()
oView		:= FWViewActive()
If lHeader
	cSubModel	:= "SNGMASTER"
	cNameTable	:= "SNG"
	cFldPeriod	:= "NG_PERDEP"
Else 
	cSubModel	:= "FNGDETAIL"
	cNameTable	:= "FNG"
	cFldPeriod	:= "FNG_PERDEP"
EndIf

oSubModel	:= oModel:GetModel(cSubModel)
nNewPerDep	:= oModel:GetModel(cSubModel):GetValue(cFldPeriod)
nRet := RU01TXDEPR(nNewPerDep, cNameTable)

If oView != Nil
	oView:Refresh()
EndIf

return nRet

/*/{Protheus.doc} RU01T03VIE

View function

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	Alexandra Menyashina
@since 		16/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function AF271RUVIE(oModel AS OBJECT, nOper AS NUMERIC)
Local lRet      AS LOGICAL
lRet    := .T.

If lRet .And. ValType("oModel") <> "O"
    oModel      := FWLoadModel("ATFA271")
    oModel:SetOperation(nOper)
    oModel:Activate()
EndIf

If lRet
    dbSelectArea("SNG")
    FWExecView(STR0001, "ATFA271", nOper, /* [ oDlg ] */, { || .T. } /* [ bCloseOnOK ] */, /* [ bOk ] */, /* [ nPercReducao ] */, aEnableButtons, Nil, Nil, Nil, oModel /* [ oModel ] */)	//"Fixed asset group"
EndIf

Return lRet


/*/{Protheus.doc} AF271PRINT

Print

@return		Nil
@author 	Alexandra Menyashina
@since 		19/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Function AF271PRINT()
Local oReport	AS OBJECT
Local cName		AS CHARACTER

cName	:= 'ATF271'
oReport := ReportDef(cName)
oReport:PrintDialog()

return Nil

/*/{Protheus.doc} ReportDef

Print report definition

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	Alexandra Menyashina
@since 		16/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function ReportDef(cName)
Local oReport	AS OBJECT
Local oSecSNG	AS OBJECT
Local oSecFNG	AS OBJECT
Local oStruSNG	AS OBJECT
Local oStruFNG	AS OBJECT
Local nX		AS NUMERIC

oStruSNG := FWFormStruct( 2, 'SNG' )
oStruFNG := FWFormStruct( 2, 'FNG' )

oReport := TReport():New(cName/*cReport*/,STR0001/*cTitle*/,cName,{|oReport| ReportPrint(oReport)},"PRINT", .F./*<lLandscape>*/ , /*<uTotalText>*/ , .F./*<lTotalInLine>*/ , /*<cPageTText>*/ , .F./*<lPageTInLine>*/ , .F./*<lTPageBreak>*/ , /*<nColSpace>*/ )

oReport:lParamPage	:= .F.	//Don't print patameter page
//Header info
oSecSNG := TRSection():New(oReport,"",{'SNG'} , , .F., .T.)
For nX := 1 To Len(oStruSNG:aFields)
	If ! oStruSNG:aFields[nX, MVC_VIEW_VIRTUAL]
		TRCell():New(oSecSNG,oStruSNG:aFields[nX][MVC_VIEW_IDFIELD] /*IdField*/,"SNG", AllTrim(oStruSNG:aFields[nX][MVC_VIEW_TITULO]),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
	EndIf
Next nX
//Detail info
oSecFNG := TRSection():New(oReport,"",{'FNG'} , , .F., .T.)
For nX := 1 To Len(oStruFNG:aFields)
	If ! oStruFNG:aFields[nX, MVC_VIEW_VIRTUAL]
		TRCell():New(oSecFNG,oStruFNG:aFields[nX][MVC_VIEW_IDFIELD] /*IdField*/,"FNG", alltrim(oStruFNG:aFields[nX][MVC_VIEW_TITULO]),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
	EndIf
Next nX
	
Return oReport

/*/{Protheus.doc} ReportPrint

Print prepare data

@param		OBJECT oModel
@return		LOGICAL lRet
@author 	Alexandra Menyashina
@since 		16/11/2018
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
STATIC Function ReportPrint(oReport)
Local oSecSNG 		AS OBJECT
Local oSecFNG		AS OBJECT
Local oStruSNG		AS OBJECT
Local oStrufNG		AS OBJECT
Local cAliasQry		AS CHARACTER
Local cQuery		AS CHARACTER
Local cGrupo		AS CHARACTER
local lRet			AS LOGICAL
Local nX			AS NUMERIC
Local xValor

oStruSNG := FWFormStruct( 2, 'SNG' )
oStruFNG := FWFormStruct( 2, 'FNG' )

oSecSNG		:= oReport:Section(1)
oSecFNG		:= oReport:Section(2)
cAliasQry	:= GetNextAlias()
cQuery		:= ""
lRet		:= .T.

If oReport:Cancel()
	Return .T.
EndIf

cGrupo:= SNG->NG_GRUPO
oSecSNG:Init()
oReport:IncMeter()

dbSelectArea('SNG')
SNG->(DBSeek( xFilial('SNG') + cGrupo))

For nX := 1 To Len(oStruSNG:aFields)
	If ! oStruSNG:aFields[nX, MVC_VIEW_VIRTUAL]
		If GetSx3Cache(oStruSNG:aFields[nX, MVC_VIEW_IDFIELD],'X3_TIPO') == 'D'
			xValor := SNG->&(oStruSNG:aFields[nX, MVC_VIEW_IDFIELD])
			xValor := StrTran(DTOC(xValor), "/", ".")
			oSecSNG:Cell(oStruSNG:aFields[nX, MVC_VIEW_IDFIELD]):SetValue(xValor)
		Else
			oSecSNG:Cell(oStruSNG:aFields[nX, MVC_VIEW_IDFIELD]):SetValue(SNG->&(oStruSNG:aFields[nX, MVC_VIEW_IDFIELD]))
		EndIf
	EndIf
Next nX		
oSecSNG:Printline()

oSecFNG:init()

cQuery	:= " SELECT  FNG.R_E_C_N_O_ FNGRECNO "

For nX := 1 To Len(oStruFNG:aFields)
	If ! oStruFNG:aFields[nX, MVC_VIEW_VIRTUAL]
		cQuery  += "," + oStruFNG:aFields[nX, MVC_VIEW_IDFIELD]
	EndIf
Next nX

cQuery	+= " FROM "+RetSqlName("FNG")+" FNG "
cQuery	+= " WHERE FNG.D_E_L_E_T_ = ' '"
cQuery	+= " AND FNG_FILIAL = '" + xFilial("FNG") + "'"
cQuery	+= " AND FNG_GRUPO = '" + cGrupo + "'"

cQuery:=ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

Dbselectarea(cAliasQry)
dbgotop()

While (cAliasQry)->(!EOF())
	For nX := 1 To Len(oStruFNG:aFields)
		If ! oStruFNG:aFields[nX, MVC_VIEW_VIRTUAL]
			oSecFNG:Cell(oStruFNG:aFields[nX][MVC_VIEW_IDFIELD]):SetValue((cAliasQry)-> &(oStruFNG:aFields[nX, MVC_VIEW_IDFIELD]))
		EndIf
	Next nX
	oSecFNG:Printline()
	(cAliasQry)->(dbSkip())
EndDo
oSecFNG:Finish()
//Separator
oReport:ThinLine()
oSecSNG:Finish()
Return(NIL)
