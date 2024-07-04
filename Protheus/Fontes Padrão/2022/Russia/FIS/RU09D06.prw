#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RU09D06.CH" 

static oGridObj
static oModelGrid

/*{Protheus.doc} BrowseDef
@author Konstantin Cherchik
@since 02/04/2018
@version P12.1.17
@return oBrowse
@type function
@description Smart TIO
*/
Function RU09D06 ()
Local oBrowse as OBJECT
Local lTest as Logical
Private aRotina as ARRAY

dbSelectArea("F50")
dbSetOrder(1)	
	
aRotina	:= MenuDef()
oBrowse := BrowseDef()

oBrowse:Activate()

Return

/*{Protheus.doc} BrowseDef
@author Konstantin Cherchik
@since 02/04/2018
@version P12.1.17
@return oBrowse
@type function
@description RU09D06 BrowseDef
*/
Static Function BrowseDef()

Local oBrowse as OBJECT

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("F50")
oBrowse:SetDescription(STR0001)
oBrowse:SetMenuDef("RU09D06")

Return oBrowse

/*{Protheus.doc} MenuDef
@author Konstantin Cherchik
@since 02/04/2018
@version P12.1.17
@return aRotina
@type function
@description RU09D06 MenuDef
*/
Static Function MenuDef()
Local aRotina as ARRAY
aRotina := {} 

	aRotina := {{STR0002, "VIEWDEF.RU09D06", 0, 2, 0, Nil},;	//View
				{STR0003, "VIEWDEF.RU09D06", 0, 3, 0, Nil},;	//Add
				{STR0004, "VIEWDEF.RU09D06", 0, 4, 0, Nil},;	//Edit
				{STR0005, "VIEWDEF.RU09D06", 0, 5, 0, Nil},;	//Delete
				{STR0006, "RU09Copy()", 0, 9, 0, Nil}}		//Copy

Return aRotina

/*{Protheus.doc} ViewDef
@author Konstantin Cherchik
@since 02/04/2018
@version P12.1.17
@return oView
@type function
@description RU09D06 ViewDef localized 
*/
Static Function ViewDef()
Local oView		as object
Local oModel	as object	 
Local aStruct	as Array
Local cFldF51 	as Character
Local aArea 	as Array
Local aAreaSX3  as Array

cFldF51 := "F50_CODE"

oModel	:= FWLoadModel("RU09D06") 	 
oView := FWFormView():New()

aStruct	:= FWFormStruct(2,"F50")
oStruGrid := FWFormStruct(2, "F51", {|x| !(AllTrim(x) $ cFldF51)}) 

aStruct:RemoveField("F50_KEY")
oStruGrid:RemoveField("F51_KEY")
oStruGrid:RemoveField("F51_KEYLIN")

oView:SetModel(oModel)

oView:AddField("F50", aStruct, "F50MAIN") 
oView:AddGrid("F51", oStruGrid, "F51DETAILS")

oView:CreateHorizontalBox("MAIN",30)
oView:CreateHorizontalBox("DETAILS",70)

oView:SetOwnerView("F50", "MAIN")
oView:SetOwnerView("F51", "DETAILS")

oView:SetViewProperty("F51", "GRIDFILTER", {.T.})
oView:SetViewProperty("F51", "GRIDSEEK", {.T.})

Return oView

/*{Protheus.doc} ModelDef
@author Konstantin Cherchik
@since 02/04/2018
@version P12.1.17
@return oModel
@type function
@description construction of oModel 
*/
Static Function ModelDef()
Local oModel    as object 
local aRelat 	as ARRAY
Local aStruct	as Array
Local oStructF51 as object
Local oModelEvent as object
Local aArea as Array
Local aAreaSX3 as Array

aStruct	:= FWFormStruct(1,"F50",/*bAvalCampo*/,/*lViewUsado*/)
oModel := MPFormModel():New("RU09D06",/*bPreValid*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)

oModel:AddFields("F50MAIN",/*cOwner*/,aStruct,/*bPreValid*/,/*bPosValid*/,/*bCarga*/)
oModel:SetDescription(STR0001)
oModel:GetModel('F50MAIN' ):SetPrimaryKey( {"F50_FILIAL","F50_KEY"} )

oStructF51	:= FWFormStruct(1,"F51") 

oModel:AddGrid("F51DETAILS", "F50MAIN", oStructF51, /* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, /* bLoadGrid */)
aRelat := {}

aAdd(aRelat, {"F51_FILIAL", "XFILIAL('F51')"})
aAdd(aRelat, {"F51_KEY", "F50_KEY"})

oModel:SetRelation("F51DETAILS", aRelat, F51->(IndexKey(1)))


oModelEvent 	:= RU09D06EventRUS():New()
oModel:InstallEvent("oModelEvent"	,/*cOwner*/,oModelEvent)
 
Return oModel 


/*/{Protheus.doc} RU09Copy
The function for copying Smart TIO codes between filials
@author Konstantin Cherchik
@since 05/08/2018
@version P12.1.20
@type function
/*/ 

Function RU09Copy()
Local oModel 	as Object
Local cF50Key	as Character
Local cCurFil	as Character
Local cCode     as Character
Local nX 		as Numeric
Local aAreaSX2  as Array
Local aAreaF50  as Array
Local aSelFil	as Array

aSelFil	:= {}
cCurFil	:= cFilAnt

aSelFil := AdmGetFil(.F.,.T.,"F50")

cF50Key	:= F50->(F50_FILIAL+F50_KEY)

If !(empty(aSelFil))
	For nX := 1 to len(aSelFil)
		aAreaF50	:= F50->(GetArea())
    	dbSelectArea("F50")
    	dbSetOrder(1) 
		If F50->(dbSeek(cF50Key))
			oModel := FWLoadModel("RU09D06")
			oModel:SetOperation(MODEL_OPERATION_INSERT)
			oModel:Activate(.T.) 
			cFilAnt := aSelFil[nX] 

			cCode   := &(GetSX3Cache("F50_CODE", "X3_RELACAO"))
            If Empty(cCode)
                cCode   := Space(GetSX3Cache("F50_CODE", "X3_TAMANHO"))
            EndIf
            oModel:GetModel("F50MAIN"):LoadValue("F50_CODE", cCode)

			aAreaSX2	:= SX2->(GetArea())
    		dbSelectArea("SX2")
			If SX2->(dbSeek("F30"))
				If SX2->X2_MODO == "E"
					oModel:GetModel("F50MAIN"):LoadValue("F50_TI",Space(TamSX3("F50_TI")[1]))
					oModel:GetModel("F50MAIN"):LoadValue("F50_TO",Space(TamSX3("F50_TO")[1]))
				EndIf
			EndIf
			If SX2->(dbSeek("F31"))
				If SX2->X2_MODO == "E"
					oModel:GetModel("F50MAIN"):LoadValue("F50_VCI",Space(TamSX3("F50_VCI")[1]))
					oModel:GetModel("F50MAIN"):LoadValue("F50_VCO",Space(TamSX3("F50_VCO")[1]))
				EndIf
			EndIf
			RestArea(aAreaSX2)

			dbSelectArea("F50")
			dbSetOrder(2)
			If ! IsBlind() .And. F50->(dbSeek(xFilial("F50") + oModel:GetModel("F50MAIN"):GetValue("F50_CODE")))
				MsgInfo(" " + STR0007 + xFilial("F50") + STR0008 + oModel:GetModel("F50MAIN"):GetValue("F50_CODE") + " ")
			EndIf
			
			FWExecView( "Copy" , "RU09D06", MODEL_OPERATION_INSERT, /*oDlg*/, {|| .T. },  , /*nPercReducao*/, , /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,oModel)
			cFilAnt := cCurFil
			oModel:DeActivate()
		EndIf
	Next nX
	RestArea(aAreaF50)
EndIf

Return

// Russia_R5
