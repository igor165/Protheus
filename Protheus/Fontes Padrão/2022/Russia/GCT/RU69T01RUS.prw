#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RU69T01RUS.CH"

/*{Protheus.doc} RU69T01RUS
@author Konstantin Cherchik
@since 10/31/2018
@version P12.1.23
@return 
@type function
@description Legal Contract
*/
Function RU69T01RUS()
Local oBrowse as OBJECT

dbSelectArea("F5Q")
dbSetOrder(1)	
	
oBrowse := FWLoadBrw("RU69T01RUS")
 
oBrowse:Activate()

Return

/*{Protheus.doc} BrowseDef
@author Konstantin Cherchik
@since 10/31/2018
@version P12.1.23
@return oBrowse
@type function
@description RU09D06 BrowseDef
*/
Static Function BrowseDef()
Local oBrowse as OBJECT
Private aRotina as ARRAY

aRotina	:= MenuDef()
oBrowse := FWMBrowse():New()
oBrowse:AddLegend("F5Q_STATUS=='1'", "GREEN", "Open")	// ADD STRING RESOURCE HERE
oBrowse:AddLegend("F5Q_STATUS<>'1'", "RED", "Closed")	// ADD STRING RESOURCE HERE
oBrowse:SetAlias("F5Q")
oBrowse:SetDescription(STR0001)
oBrowse:SetMenuDef("RU69T01RUS")

Return oBrowse

/*{Protheus.doc} MenuDef
@author Konstantin Cherchik
@since 10/31/2018
@version P12.1.23
@return aRotina
@type function
@description RU69T01RUS MenuDef
*/
Static Function MenuDef()
Local aRotina as ARRAY
aRotina := {} 

	aRotina := {{STR0002, "VIEWDEF.RU69T01RUS", 0, 2, 0, Nil},;	//View
				{STR0003, "VIEWDEF.RU69T01RUS", 0, 3, 0, Nil},;  	//Add
				{STR0004, "VIEWDEF.RU69T01RUS", 0, 4, 0, Nil},; 	//Edit
				{STR0005, "VIEWDEF.RU69T01RUS", 0, 5, 0, Nil},; 	//Delete 
				{STR0024, "RU69T01Copy()", 0, 9, 0, Nil}} 		//Copy

Return aRotina

/*{Protheus.doc} ViewDef
@author Konstantin Cherchik
@since 10/31/2018
@version P12.1.23
@return oView
@type function
@description RU69T01RUS ViewDef
*/
Static Function ViewDef()
Local oView		as object
Local oModel	as object	 
Local oStruHead	as object
Local oStruDet	as object

oModel	:= FWLoadModel("RU69T01RUS") 	 

oStruHead	:= FWFormStruct(2,"F5Q", {|x| ! AllTrim(x) $ "F5Q_UID"})
oStruDet    := FWFormStruct(2, "F5R", {|x| ! AllTrim(x) $ "F5R_REV|F5R_CODE|F5R_UID|F5R_UIDF5Q"}) 

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField("HEAD_F5Q", oStruHead, "F5QMASTER") 
oView:AddField("CHILD_F5R", oStruDet, "F5RDETAIL")

oView:CreateHorizontalBox("MAIN",50)
oView:CreateHorizontalBox("DETAIL",50)

oView:SetOwnerView("HEAD_F5Q", "MAIN")
oView:SetOwnerView("CHILD_F5R", "DETAIL")

//oView:AddUserButton(STR0006, '', {|oViewLc, oButton| LoadTimeSpanManagement(oViewLc, oButton)}) 

Return oView

Static Function LoadTimeSpanManagement(oViewLc as Object, oButton as Object)
Local nOper			as Numeric
Local oModel		as Object

oModel		:= oViewLc:GetModel()
nOper		:= oModel:GetOperation()

If nOper <> MODEL_OPERATION_UPDATE .And. nOper <> MODEL_OPERATION_VIEW
	Help("",1,"RU69T01TIMESPANOP",,STR0013,1,0)
ElseIf ! Empty(RU69T0201_GetChild("F5Q", "F5R", F5Q->F5Q_UID, dDataBase, .F.))
	RU69T02RUS(nOper)
EndIf

Return Nil

/*{Protheus.doc} ModelDef
@author Konstantin Cherchik
@since 10/31/2018
@version P12.1.23
@return oModel
@type function
@description construction of oModel 
*/
Static Function ModelDef()
Local oModel	as object	 
Local oStruHead	as object
Local oStruDet	as object
Local oModelEvent as object

oStruHead	:= FWFormStruct(1,"F5Q")
oStruDet    := FWFormStruct(1,"F5R") 

oModel		:= MPFormModel():New("RU69T01RUS", /* Pre-valid */, /* Pos-Valid */, /* Commit */)
oModel:AddFields("F5QMASTER", /*cOwner*/, oStruHead)
oModel:AddFields("F5RDETAIL", "F5QMASTER", oStruDet, /* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, /* bLoadGrid */)

oModel:GetModel("F5QMASTER"):SetDescription(STR0007) 
oModel:GetModel("F5RDETAIL"):SetDescription(STR0008) 
oModel:SetDescription(STR0009) 
oModel:SetRelation("F5RDETAIL", {{"F5R_FILIAL","XFILIAL('F5R')"},{"F5R_UIDF5Q","F5Q_UID"}}, F5R->(IndexKey(3)))
oModelEvent 	:= RU69T01EventRUS():New()
oModel:InstallEvent("oModelEvent"	,/*cOwner*/,oModelEvent)

Return oModel

/*{Protheus.doc} ModelDef
@author Konstantin Cherchik
@since 11/16/2018
@version P12.1.23
@return oModel
@type function
@description Copying contracts between branches 
*/
Function RU69T01Copy()
Local oModel 	as Object
Local aSelFil	as Array
Local aAreaSX2  as Array
Local aAreaF5Q  as Array
Local cCurFil	as Character
Local cF5QKey	as Character
Local cCode     as Character
Local nX 		as Numeric

aSelFil	:= {}
cCurFil	:= cFilAnt

aSelFil := AdmGetFil(.F.,.T.,"F5Q") //TODO: Need control, If table is Shared? Then just put in aSelFil one empty branch value " ". So, function will create 1 copy with empty branch.
  
cF5QKey	:= F5Q->(F5Q_FILIAL+F5Q_CODE)

If !(empty(aSelFil))
	For nX := 1 to len(aSelFil)
		aAreaF5Q	:= F5Q->(GetArea())
		dbSelectArea("F5Q")
    	dbSetOrder(2) 
		If F5Q->(dbSeek(cF5QKey))
			oModel := FWLoadModel("RU69T01RUS")
			oModel:SetOperation(1)
			oModel:Activate(.T.) 
			cFilAnt := aSelFil[nX]
			cCode   := &(GetSX3Cache("F5Q_CODE", "X3_RELACAO"))

            If Empty(cCode)
                cCode   := Space(GetSX3Cache("F5Q_CODE", "X3_TAMANHO"))
            EndIf
			
            oModel:GetModel("F5QMASTER"):LoadValue("F5Q_CODE", cCode)

			/* Due to the fact that to load the inherited data into the model, to copy the contract,
			we used the VIEW operation, we must generate new UID for F5Q & F5R. */
			oModel:GetModel("F5QMASTER"):LoadValue("F5Q_UID", RU01UUIDV4()) 
			oModel:GetModel("F5RDETAIL"):LoadValue("F5R_UID", RU01UUIDV4()) 

			aAreaSX2	:= SX2->(GetArea())
    		dbSelectArea("SX2")
			If SX2->(dbSeek("SA1"))
				If SX2->X2_MODO == "E"
					oModel:GetModel("F5QMASTER"):LoadValue("F5Q_A1COD",Space(TamSX3("F5Q_A1COD")[1]))
				EndIf
			EndIf
			If SX2->(dbSeek("SA2"))
				If SX2->X2_MODO == "E"
					oModel:GetModel("F5QMASTER"):LoadValue("F5Q_A2COD",Space(TamSX3("F5Q_A2COD")[1]))
				EndIf
			EndIf
			If SX2->(dbSeek("F30"))
				If SX2->X2_MODO == "E"
					oModel:GetModel("F5RDETAIL"):LoadValue("F5R_VATCOD",Space(TamSX3("F5R_VATCOD")[1]))
				EndIf
			EndIf
			If SX2->(dbSeek("SED"))
				If SX2->X2_MODO == "E"
					oModel:GetModel("F5RDETAIL"):LoadValue("F5R_NATURE",Space(TamSX3("F5R_NATURE")[1]))
				EndIf
			EndIf
			If SX2->(dbSeek("SE4"))
				If SX2->X2_MODO == "E"
					oModel:GetModel("F5RDETAIL"):LoadValue("F5R_COND",Space(TamSX3("F5R_COND")[1]))
				EndIf
			EndIf
			If SX2->(dbSeek("CTO"))
				If SX2->X2_MODO == "E"
					oModel:GetModel("F5QMASTER"):LoadValue("F5Q_MOEDA",Space(TamSX3("F5Q_MOEDA")[1]))
				EndIf
			EndIf
			RestArea(aAreaSX2)

			dbSelectArea("F5Q")
			dbSetOrder(2)
			If ! IsBlind() .And. F5Q->(dbSeek(xFilial("F5Q") + oModel:GetModel("F5QMASTER"):GetValue("F5Q_CODE")))
				MsgInfo(" " + STR0020 + xFilial("F50") + STR0021 + oModel:GetModel("F5QMASTER"):GetValue("F5Q_CODE") + " ")
			EndIf
			
			FWExecView( STR0024 , "RU69T01RUS", MODEL_OPERATION_INSERT, /*oDlg*/, {|| .T. },  , /*nPercReducao*/, , /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,oModel)
			cFilAnt := cCurFil
			oModel:DeActivate()
		EndIf
	Next nX
	RestArea(aAreaF5Q)
EndIf

Return

/*{Protheus.doc} ModelDef
@author Konstantin Cherchik
@since 11/16/2018
@version P12.1.23
@return oModel
@type function
@description Copying contracts between branches 
*/
Function RU69T01Descr(cExtNumber as Char, dExtDate as Date)
Local cLegDescr As Char

cLegDescr := STR0022 + AllTrim(cExtNumber)+STR0023+DTOC(dExtDate)

Return cLegDescr