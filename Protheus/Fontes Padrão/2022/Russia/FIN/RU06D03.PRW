#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RU06D03.CH"


#define VIA_RU06D03		1
#define VIA_CRMA980		2

static oGridObj
static oModelGrid

/*{Protheus.doc} BrowseDef
@author Alexander Salov
@since 20/12/2017
@version 1.0
@return oBrowse, return oBrowse
@type function
@description CLI Bank Accounts for Russia
*/
Function RU06D03 (cClientCode, cClientName, cClientUnit)
Local oMBrowse as OBJECT

Private aRotina as ARRAY

default cClientCode:= ''
default cClientName:= ''
default cClientUnit:= ''

dbSelectArea("F4N")
dbSetOrder(1)	
	
oBrowse	:= Nil
aRotina	:= MenuDef()
oBrowse := BrowseDef()

If (!Empty(Alltrim(cClientName)))
	oBrowse:SetDescription(STR0001 + " - " + cClientCode + " - " + cClientName)
Endif

oBrowse:Activate()

Return


/*{Protheus.doc} BrowseDef
@author Alexander Salov
@since 20/12/2017
@version 1.0
@return oBrowse, return oBrowse
@type function
@description RU06D03 BrowseDef
*/
Static Function BrowseDef()

Local oBrowse as OBJECT

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("F4N")
oBrowse:SetDescription(STR0001)//"Clientes bank accounts"
oBrowse:SetMenuDef("RU06D03")

Return oBrowse


/*{Protheus.doc} MenuDef
@author Alexander Salov
@since 20/12/2017
@version 1.0
@return aRotina, return aRotina
@type function
@description RU06D03 MenuDef
*/
Static Function MenuDef()
Local aRotina as ARRAY
Local aPerm	as ARRAY
aRotina := {}


	aPerm := {.T.,.T.,.T.,.T.}

	ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw" OPERATION 1 ACCESS 0 // "Pesquisar"
	
	If aPerm[4]
		ADD OPTION aRotina TITLE  STR0003 ACTION "VIEWDEF.RU06D03" OPERATION 2	ACCESS 0 //"Visualizar"
	EndIf
	
	If aPerm[1]
		ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.RU06D03" OPERATION 3	ACCESS 0 //"Incluir"	
	EndIf
	
	If aPerm[2]
		ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.RU06D03" OPERATION 4 ACCESS 0 //"Alterar"
	EndIf
	
	If aPerm[3]
		ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.RU06D03" OPERATION 5 ACCESS 0 //"Excluir"
	EndIf
	
	ADD OPTION aRotina TITLE STR0007	ACTION "VIEWDEF.RU06D03" OPERATION 8 ACCESS 0	 //"Imprimir"
	ADD OPTION aRotina TITLE STR0008	ACTION "VIEWDEF.RU06D03" OPERATION 9 ACCESS 0	 //"Copiar"

Return aRotina




/*{Protheus.doc} ViewDef
@author Alexander Salov
@since 20/12/2017
@version 1.0
@return oView, return view
@type function
@description RU06D03 ViewDef localized 
*/
Static Function ViewDef()

Local oView		as object
Local oModel	as object	 
Local oStruct	as object
Local nViewMode := GetViewMode()

conout ("Start of RU06D03.ViewDef")

oModel	:= FWLoadModel("RU06D03") 	 
oView := FWFormView():New()

if (nViewMode == VIA_RU06D03)
	conout ("Use  RU06D03.ViewDef VIA_RU06D03")

	oStruct	:= FWFormStruct(2,"F4N",/*bAvalCampo*/,/*lViewUsado*/)

	oView:SetContinuousForm()
	oView:AddField("F4N", oStruct, "F4NMASTER")

	oView:SetModel(oModel)
	oView:CreateHorizontalBox("MAIN",100)
	oView:SetOwnerView("F4N", "MAIN")
endif

if (nViewMode == VIA_CRMA980)
	conout ("Use  RU06D03.ViewDef VIA_CRMA980")

	oView:SetModel(oModel)	

    oStruGrid	:= FWFormStruct(2, "F4N") 
	oView:AddGrid("VIEW_F4N", oStruGrid, "F4NDETAILS")
	oView:CreateHorizontalBox("GRID", 100)

	oView:SetOwnerView("VIEW_F4N", "GRID")

	oView:SetViewProperty("VIEW_F4N", "GRIDFILTER", {.T.})
	oView:SetViewProperty("VIEW_F4N", "GRIDSEEK", {.T.})

	oView:SetDescription(STR0001 + " - " + AllTrim(SA1->A1_COD) + " - " + AllTrim(SA1->A1_NOME))

	//AS: Registering this grid as static to make it refreshable from every moment
	oGridObj := oView:GetViewObj("F4NDETAILS")[3]

endif

conout ("End of RU06D03.ViewDef")

Return oView


/*{Protheus.doc} ViewDef
@author Alexander Salov
@since 20/12/2017
@version 1.0
@return oView, return view
@type function
@description RU06D03 ViewDef localized 
*/
Static Function GetViewMode()
Local nOper     AS NUMERIC

nOper   := 0
If IsInCallStack("CRMA980RUS") .or. IsInCallStack("MATA467N")
    nOper   := VIA_CRMA980
Else
    nOper   := VIA_RU06D03
EndIf
Return nOper


/*{Protheus.doc} GridViewRefresh
@author Alexander Salov
@since 20/12/2017
@version 1.0
@return null
@type function
@description Refreshing grid-table view with latest data in main model
*/
Static function GridViewRefresh ()
	oGridObj:Refresh( .T. /* lEvalChanges */, .T. /* lGoTop */)
return .T.


/*{Protheus.doc} ModelDef
@author Alexander Salov
@since 20/12/2017
@version 1.0
@return oModel of bank accounts entry, batch of bank accounts entries for client
@type function
@description Can return 3 types of oModel: 1) One F4NMASTER record. 2) One SA1MASTER record and batch of F4NDETAILS. 3) One F4NMASTER from batch of F4NDETAILS of second model
*/
Static Function ModelDef()
Local oModel    as object 
Local oDoppelganger    as object
Local oVictim    as object
local aRelat 	as ARRAY
Local oStruct	as object
Local oStructSA1 as object
Local oStructFN4 as object
Local cToShow	as character
Local oFakeModelEvent 	:= RU06D03EventRUS():New()

Local nModelMode := GetViewMode()

//AS: IN case we working with some abstract bank account
if (nModelMode == VIA_RU06D03) 
	
	oStruct	:= FWFormStruct(1,"F4N",/*bAvalCampo*/,/*lViewUsado*/)
	oModel := MPFormModel():New("RU06D03",/*bPreValid*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)
	oModel:AddFields("F4NMASTER",/*cOwner*/,oStruct,/*bPreValid*/,/*bPosValid*/,/*bCarga*/)

	oModel:SetDescription(STR0001)//"Clientes"
endif

//AS: In case we working with bank account related to some client
if (nModelMode == VIA_CRMA980) 



	oHeader	:= FWFormModelStruct():New() //Fake one

	oHeader:AddTable('F4N',,'F4N') //Sopme of them are alias
	oHeader:AddField("HEADER","","FAKEFIELD","C",1,0,/*bValid*/,/*When*/,/*aValues*/,.F.,{||'"1"'},/*Key*/,.F.,.T.,)

	oModel := MPFormModel():New("RU06D03",/*bPreValid*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)
	oModel:AddFields("F4NMASTER",/*cOwner*/,oHeader,/*bPreValid*/,/*bPosValid*/,/*bCarga*/)
	oModel:GetModel('F4NMASTER' ):SetPrimaryKey( {} )


	oStructFN4	:= FWFormStruct(1,"F4N")

	oModel:AddGrid("F4NDETAILS", "F4NMASTER", oStructFN4, /* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, /* bLoadGrid */)
	aRelat := {}

	aAdd(aRelat, {"F4N_FILIAL", "XFILIAL('F4N')"})
	aAdd(aRelat, {"F4N_CLIENT", "SA1->A1_COD"})
	aAdd(aRelat, {"F4N_LOJA", "SA1->A1_LOJA"})

	oModel:SetRelation("F4NDETAILS", aRelat, F4N->(IndexKey(2)))


	oModel:SetOnlyQuery('F4NMASTER',.T.)

	oModel:GetModel("F4NDETAILS"):SetDescription(STR0001 + " - " + AllTrim(SA1->A1_COD) + " - " + AllTrim(SA1->A1_NOME)) 
	
	oModelGrid := oModel:GetModel("F4NDETAILS")
	oModel:SetDescription(STR0001 + " - " + AllTrim(SA1->A1_COD) + " - " + AllTrim(SA1->A1_NOME))
	oModel:InstallEvent("FakeModel"	,/*cOwner*/,oFakeModelEvent)

endif
	
Return oModel

/*{Protheus.doc} RU06D03ACC
@author Alexander Salov
@since 29/01/2018
@version 1.0
@return bool
@type function
@description RU06D03 validates length of Account number for RUS bank
*/
function RU06D03AVL (cAccount)
local lRet as logical 
local cForeign as character

lRet = .T.

cForeign := Posicione("F45",1,xFilial("F45")+FWFldGet("F4N_BIK"),"F45_FOREIG")
cAccount := alltrim (cAccount)

if (alltrim(cForeign)!="1")
	if (len(cAccount) != 20)
		lRet = .F.
	endif
endif

return lRet


/*{Protheus.doc} RU06D03CUR
@author Alexander Salov
@since 10/02/2018
@version 1.0
@return bool
@type function
@description RU06D03CMA validates if main account already exists
*/
function RU06D03CMA()
local lRet as logical 
Local nX as NUMERIC
Local nTotal := 0

lRet = .T.

For nX := 1 To oModelGrid:Length()
	IF oModelgrid:GETVALUE('F4N_TYPE',Nx) == "1"
        nTotal++
    Endif
Next nX

if (nTotal>1)
	lRet = .F.
Endif

return lRet
// Russia_R5
