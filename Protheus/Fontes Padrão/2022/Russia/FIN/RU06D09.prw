#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RU06D09.CH"

/*{Protheus.doc} RU69T01RUS
@author Konstantin Cherchik
@since 03/22/2019
@version P12.1.25
@return 
@type function
@description Client-bank export
*/
Function RU06D09()
Local oBrowse   as Object

dbSelectArea("F5X")
dbSetOrder(2)

oBrowse :=  FWLoadBrw("RU06D09")

oBrowse:Activate()

Return 

/*{Protheus.doc} BrowseDef
@author Konstantin Cherchik
@since 03/22/2019
@version P12.1.25
@return oBrowse
@type function
@description RU06D09 BrowseDef
*/
Static Function BrowseDef()
Local oBrowse as OBJECT
Private aRotina as ARRAY

aRotina	:= MenuDef()
oBrowse := FWMBrowse():New()
oBrowse:AddLegend("F5X_STATUS=='1'", "GREEN", STR0001)	// ADD STRING RESOURCE HERE
oBrowse:AddLegend("F5X_STATUS<>'1'", "RED", STR0002)	// ADD STRING RESOURCE HERE
oBrowse:SetAlias("F5X")
oBrowse:SetDescription(STR0003) 
oBrowse:SetMenuDef("RU06D09")

Return oBrowse

/*{Protheus.doc} MenuDef
@author Konstantin Cherchik
@since 03/22/2019
@version P12.1.25
@return aRotina
@type function
@description RU06D09 MenuDef
*/
Static Function MenuDef()
Local aRotina as ARRAY
aRotina := {} 

	aRotina := {{STR0004, "RU06D09006_Pergunte()", 0, 3, 0, Nil},;  //Export
                {STR0005, "RU06D09002_View()", 0, 2, 0, Nil},;	//View
				{STR0006, "RU06D09020_Edit()", 0, 4, 0, Nil},; 	//Edit
				{STR0007, "RU06D09027_FullCancel()", 0, 4, 0, Nil},; 	//Cancel
                {STR0008, "RU06D09028_ReCreation()", 0, 0, 0, Nil},; 	//Create file
                {STR0009, "RU06D09019_Legenda()", 0, 7, 0, Nil}} 	//Legenda

Return aRotina

/*{Protheus.doc} ViewDef
@author Konstantin Cherchik
@since 03/22/2019
@version P12.1.25
@return oView
@type function
@description RU06D09 ViewDef
*/
Static Function ViewDef()
Local oView		as object
Local oModel	as object	 
Local oStruHead	as object
Local oStruDet	as object

oModel	:= FWLoadModel("RU06D09") 	 

oStruHead	:= FWFormStruct(2,"F5X", {|x| ! AllTrim(x) $ "F5X_UUID"})
oStruDet    := FWFormStruct(2, "F5W", {|x| ! AllTrim(x) $ "F5W_UIDF5X|F5W_UIDF49"}) 

oView := FWFormView():New()

oView:SetModel(oModel)

If INCLUI
    oStruHead:AddField("MVC_CHKALL", PADR('', Len(SX3->X3_ORDEM), 'Z'), STR0010, STR0011, Nil, "Get", "",,,.T.)
EndIf
oStruDet:AddField("MVC_CHK", '01', STR0012, STR0013, Nil, "Get", "",,,.T.)

oStruHead:RemoveField("F5X_UUID")
oStruHead:RemoveField("F5X_INIDAT")
oStruHead:RemoveField("F5X_ENDDAT")
oStruDet:RemoveField("F5W_UIDF5X") 
oStruDet:RemoveField("F5W_UIDF49")
oStruDet:RemoveField("F5W_USERGI")
oStruDet:RemoveField("F5W_USERGA")

oView:AddField("HEAD_F5X", oStruHead, "F5XMASTER") 
oView:AddGrid("CHILD_F5W", oStruDet, "F5WDETAIL")

oView:SetViewProperty("CHILD_F5W", "GRIDDOUBLECLICK", {{|oModelGrid, cField, nLineGrid, nLineModel| RU06D09003_ViewPO(oModelGrid, cField, nLineGrid, nLineModel)}})

oView:CreateHorizontalBox("MAIN",30)
oView:CreateHorizontalBox("DETAIL",70)

oView:SetOwnerView("HEAD_F5X", "MAIN")
oView:SetOwnerView("CHILD_F5W", "DETAIL")

oView:SetAfterViewActivate({|oView| RU06D09024_Button(oView)})

Return oView

/*{Protheus.doc} ModelDef
@author Konstantin Cherchik
@since 03/22/2019
@version P12.1.25
@return oModel
@type function
@description construction of oModel 
*/
Static Function ModelDef()
Local oModel	as object	 
Local oStruHead	as object
Local oStruDet	as object
Local oModelEvent as object

oStruHead	:= FWFormStruct(1,"F5X")
oStruDet    := FWFormStruct(1,"F5W") 

oModel		:= MPFormModel():New("RU06D09", /* Pre-valid */, /* Pos-Valid */, /* Commit */)

If INCLUI
    oStruHead:AddField(STR0010, STR0011, "MVC_CHKALL", "L", 01, 00, {|oVldModel, cVldField, xVldNVal, xVldOVal| RU06D09005_MarkAll(oVldModel, cVldField, xVldNVal, xVldOVal) } /* bValid */, {|| .T. } /* bWhen */, /* aValues */, .F. /* lObrigat */, {|| .F. } /* bInit */, .F. /* lKey */, /* lNoUpd */, .F. /* lVirtual */)
EndIf
oStruDet:AddField(STR0012, STR0013, "MVC_CHK", "L", 01, 00, {|oVldModel, cVldField, xVldNVal, xVldOVal| RU06D09004_Mark(oVldModel, cVldField, xVldNVal, xVldOVal) } /* bValid */, {|| .T. } /* bWhen */, /* aValues */, .F. /* lObrigat */, {|| .F. } /* bInit */, .F. /* lKey */, /* lNoUpd */, .F. /* lVirtual */)


oModel:AddFields("F5XMASTER", /*cOwner*/, oStruHead)
oModel:AddGrid("F5WDETAIL", "F5XMASTER", oStruDet, /* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, /* bLoadGrid */)

oModel:GetModel("F5XMASTER"):SetDescription(STR0003) 
oModel:GetModel("F5WDETAIL"):SetDescription(STR0014) 
oModel:SetDescription(STR0003) 
oModel:SetRelation("F5WDETAIL", {{"F5W_FILIAL","XFILIAL('F5W')"},{"F5W_UIDF5X","F5X_UUID"}}, F5W->(IndexKey(1)))
oModelEvent 	:= RU06D09EventRUS():New()
oModel:InstallEvent("oModelEvent"	,/*cOwner*/,oModelEvent)

Return oModel
 
/*/{Protheus.doc} RU06D09001_Moeda
Returns CTO_SIMB from CTO
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09001_Moeda()
Local cMoedaDesc as Character
Local nMoeda     as Numeric
Local aSaveArea  as Array
Local aAreaSA6   as Array

aSaveArea := GetArea() 
aAreaSA6 := SA6->(GetArea())
cMoedaDesc  := " "
dbSelectArea("SA6")
SA6->(dbSetOrder(1))

If !EMPTY(AllTrim(F5X->F5X_BNKCOD)) 
    If SA6->(dbSeek(xFilial("SA6")+F5X->F5X_BNKCOD+F5X->F5X_BIK+F5X->F5X_ACCNT))
        nMoeda := A6_MOEDA
        cMoedaDesc := Posicione("CTO",1,xFilial("CTO")+StrZero(nMoeda,2),"CTO_SIMB")
    EndIf
ElseIf !EMPTY(AllTrim(MV_PAR01))
    If SA6->(dbSeek(xFilial("SA6")+MV_PAR01+MV_PAR02+MV_PAR03))
        nMoeda := A6_MOEDA
        cMoedaDesc := Posicione("CTO",1,xFilial("CTO")+StrZero(nMoeda,2),"CTO_SIMB")
    EndIf
EndIf

RestArea(aAreaSA6)  
RestArea(aSaveArea) 

Return cMoedaDesc

/*/{Protheus.doc} RU06D09002_View
View for journal
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09002_View()
Local lRet   as Logical
Local cTable as Character
Local oModelDetail as Object
Local oModel as Object

oModel := FwLoadModel("RU06D09")
oModel:SetOperation(MODEL_OPERATION_VIEW)
oModel:Activate() 
oModelDetail := oModel:GetModel("F5WDETAIL")

cTable := RU06D09021_F49TemTable(oModelDetail)
RU06D09009_FillGrid(oModel,cTable)

oModelDetail:GoLine(1)

FwExecView(STR0005, "RU06D09", MODEL_OPERATION_VIEW,/* oDlg */, {|| .T.},/* ok */,/*nPercReducation*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel)
                    
Return lRet

/*/{Protheus.doc} RU06D09003_ViewPO
View for Payment Orders
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09003_ViewPO(oModelGrid as Object, cField as Character, nLineGrid as Numeric, nLineModel as Numeric)
Local lRet       as Logical
Local oModelPO   as Object
Local nOperation as Numeric
Local aSaveArea  as Array
Local aAreaF49   as Array

lRet       := .T.
nOperation := oModelGrid:GetModel("F5WDETAIL"):GetOperation()
aSaveArea := GetArea() 
aAreaF49 := F49->(GetArea())

If  cField != "MVC_CHK"
    dbSelectArea("F49")
    F49->(dbSetOrder(2))
    If F49->(dbSeek(xFilial("F49")+oModelGrid:GetModel("F5WDETAIL"):GetValue("F5W_UIDF49")))
        oModelPO := FwLoadModel("RU06D05")
        oModelPO:SetOperation(MODEL_OPERATION_VIEW)
        oModelPO:Activate() 
        FwExecView(STR0015, "RU06D05", MODEL_OPERATION_VIEW,/* oDlg */, {|| .T.},/* ok */,/*nPercReducation*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModelPO)
    EndIf
EndIF

RestArea(aAreaF49)  
RestArea(aSaveArea) 

Return lRet 

/*/{Protheus.doc} RU06D09004_Mark
Validation for PO selecting
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09004_Mark(oVldModel as Object, cVldField as Character, xVldNVal, xVldOVal)
Local oModel        as Object
Local oModelMaster  as Object
Local oModelDetail  as Object
Local oView         as Object
Local nLineFlag     as Numeric
Local lRet          as Logical
Local lValid        as Logical

lRet         := .T.
nValueSum    := 0
oModel       := oVldModel:GetModel()
oModelMaster := oModel:GetModel("F5XMASTER")
oModelDetail := oModel:GetModel("F5WDETAIL")
nLineFlag    := oModelDetail:GetLine()
oView        := FWViewActive()

If !EMPTY(oModelMaster) .And. !EMPTY(oModelDetail)
    If xVldNVal
        lValid := RU06D09025_POValid(oModelDetail)
        If lValid
            oModelDetail:SetLine(nLineFlag)
            oModelMaster:SetValue("F5X_VALUE",(oModelMaster:GetValue("F5X_VALUE")+oModelDetail:GetValue("F5W_VALUE")))
            oModelDetail:SetValue("F5W_STATUS","1")
        Else
            oModelDetail:SetValue("MVC_CHK",.F.)
            Help("",1,STR0016,,STR0017 + oModelDetail:GetValue("F5W_PAYORD") + STR0018,1,0)
        EndIf
    Else
        oModelDetail:SetLine(nLineFlag)
        oModelMaster:SetValue("F5X_VALUE",(oModelMaster:GetValue("F5X_VALUE")-oModelDetail:GetValue("F5W_VALUE")))
        oModelDetail:SetValue("F5W_STATUS","2")
    EndIf
EndIf

If ValType(oView) == "O" .And. oView:IsActive()
    oView:Refresh() 
EndIf

Return lRet

/*/{Protheus.doc} RU06D09005_MarkAll
Selecting of all POs in grid, only for INCLUI
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09005_MarkAll(oVldModel as Object, cVldField as Character, xVldNVal, xVldOVal)
Local oModel        as Object
Local oModelMaster  as Object
Local oModelDetail  as Object
Local oView         as Object
Local nValueSum     as Numeric
Local nX            as Numeric
Local lRet          as Logical

lRet         := .T.
nValueSum    := 0
oModel       := oVldModel:GetModel()
oModelMaster := oModel:GetModel("F5XMASTER")
oModelDetail := oModel:GetModel("F5WDETAIL")
oView        := FWViewActive()

If !EMPTY(oModelMaster) .And. !EMPTY(oModelDetail)
    For nX := 1 to oModelDetail:Length()
        oModelDetail:GoLine(nX)
        If xVldNVal
            oModelDetail:LoadValue("MVC_CHK",.T.)
            nValueSum += oModelDetail:GetValue("F5W_VALUE")
        Else
            oModelDetail:LoadValue("MVC_CHK",.F.)
        EndIf
    Next nX

    If xVldNVal
        lRet := oModelMaster:SetValue("F5X_VALUE",nValueSum)
    Else
        lRet := oModelMaster:SetValue("F5X_VALUE",0)
    EndIf
    oModelDetail:SetLine(1)
EndIf

If ValType(oView) == "O" .And. oView:IsActive()
    oView:Refresh() 
EndIf 

Return lRet

/*/{Protheus.doc} RU06D09006_Pergunte
Beginning of export. Accroding to values in Pergunte need to find suitable POs
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09006_Pergunte()
Local lRet        as Logical
Local lValid      as Logical
Local cPerg       as Character
Local cFormatCode as Character
Local cQuery      as Character
Local cTable      as Character
Local oModel      as Object
Local aSaveArea   as Array
Local aAreaSA6    as Array
Local aAreaF5N    as Array

lRet   := .F.   // Flag to re-open Pergunte, if values will be not valid
lValid := .T.   // Flag to check, are necessary fields are not empty?
cPerg  := "RUD609"
aSaveArea := GetArea() 
aAreaSA6 := SA6->(GetArea())
aAreaF5N := F5N->(GetArea())

lRet:= Pergunte(cPerg,.T.,STR0003,.F.)

/* Pergunte should not be closed, until user will not press Cancel or Formec code for export (F5N) will not be found */
While lRet 
    lValid := .T. // Redefine after last iteration
    lValid := lValid .And. !EMPTY(MV_PAR01) 
    lValid := lValid .And. !EMPTY(MV_PAR02) 
    lValid := lValid .And. !EMPTY(MV_PAR03)
    If lValid 
        dbSelectArea("SA6")
        SA6->(dbSetOrder(1))
        If SA6->(dbSeek(xFilial("SA6")+MV_PAR01+MV_PAR02+MV_PAR03))
            cFormatCode := SA6->A6_FRMCDE
            dbSelectArea("F5N")
            F5N->(dbSetOrder(1))
            If F5N->(dbSeek(xFilial("F5N")+cFormatCode)) .And. F5N_FRMTYP == "1"
                cQuery := RU06D09008_PayOrdQuery(MV_PAR01,MV_PAR02,MV_PAR03,DTOS(MV_PAR04),DTOS(MV_PAR05),MV_PAR06)
                cTable := RU01GETALS(cQuery)
                If (cTable)->(!EoF())
                    oModel := FwLoadModel("RU06D09")
                    oModel:SetOperation(MODEL_OPERATION_INSERT)
                    oModel:Activate()
                    RU06D09007_Export(oModel,cTable,MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR06)
                    RU06XFUN31_RelacaoRerun(oModel)
                    oModel:GetModel("F5WDETAIL"):SetNoInsertLine(.T.)
                    FwExecView(STR0004, "RU06D09", MODEL_OPERATION_INSERT,/* oDlg */, {|| .T.},/* ok */,/*nPercReducation*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel)
                    lRet := .F.
                Else
                    Help("",1,STR0019,,STR0020,1,0)
                    lRet:= Pergunte(cPerg,.T.,STR0003,.F.)
                EndIf
            Else
                Help("",1,STR0021,,STR0022,1,0)
                lRet := .F.
            EndIf
        Else
            Help("",1,STR0023,,STR0024,1,0)
            lRet:= Pergunte(cPerg,.T.,STR0003,.F.)
        EndIf
    Else
        Help("",1,STR0025,,STR0026,1,0)
        lRet:= Pergunte(cPerg,.T.,STR0003,.F.)
    EndIf
EndDo

If !EMPTY(cTable)
    (cTable)->(dbCloseArea())
EndIf

RestArea(aAreaF5N)  
RestArea(aAreaSA6)  
RestArea(aSaveArea) 

Return lRet

/*/{Protheus.doc} RU06D09007_Export
View for Export (Inclui)
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09007_Export(oModel as Object, cTable as Character, cBnkPay as Character, cPayBik as Character, cPayAcc as Character, cPayTyp as Character)
Local lRet           as Logical
Local oModelMaster   as Object
Local nCount    as Numeric

lRet := .T.
nCount := 0

oModelMaster := oModel:GetModel("F5XMASTER")

oModelMaster:SetValue("F5X_BNKCOD", cBnkPay)
oModelMaster:SetValue("F5X_BIK", cPayBik)
oModelMaster:SetValue("F5X_ACCNT", cPayAcc)
oModelMaster:SetValue("F5X_COMENT", STR0003)
oModelMaster:SetValue("F5X_INIDAT",MV_PAR04)
oModelMaster:SetValue("F5X_ENDDAT",MV_PAR05)

lRet := RU06D09009_FillGrid(oModel,cTable)

Return lRet

/*/{Protheus.doc} RU06D09008_PayOrdQuery
Query to get suitable POs
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09008_PayOrdQuery(cBnkPay as Character, cPayBik as Character, cPayAcc as Character, cDtPaymFrom as Character, cDtPaymTo as Character, cPayTyp as Character)
Local cQuery  as Character
Local cStatus as Character

Default cBnkPay     := Space(TamSX3("F49_BNKPAY")[1]) 
Default cPayBik     := Space(TamSX3("F49_PAYBIK")[1])
Default cPayAcc     := Space(TamSX3("F49_PAYACC")[1])
Default cDtPaymFrom := Space(TamSX3("F49_DTPAYM")[1])
Default cDtPaymTo   := Space(TamSX3("F49_DTPAYM")[1])
cStatus := '1'  //Payment Status

cQuery := " SELECT * FROM " + RetSQLName("F49") 
cQuery += " WHERE F49_FILIAL = '" + xFilial("F49") + "' "
cQuery += " AND F49_BNKPAY = '" + cBnkPay + "' "
cQuery += " AND F49_PAYBIK = '" + cPayBik + "' "
cQuery += " AND F49_PAYACC = '" + cPayAcc + "' "
cQuery += " AND F49_STATUS = '" + cStatus + "' "
If !EMPTY(AllTrim(cPayTyp))
    cQuery += " AND F49_PAYTYP = '" + cPayTyp + "' "
EndIf
cQuery += " AND F49_DTPAYM BETWEEN '" + cDtPaymFrom + "' AND '" + cDtPaymTo + "' "
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY F49_IDF49 "

Return cQuery

/*/{Protheus.doc} RU06D09009_FillGrid
Filling of Details grid
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09009_FillGrid(oModel as Object, cTable as Character)
Local lRet         as Logical
Local lAddLine     as Logical
Local oModelDetail as Object
Local oModelMaster as Object
Local nOperation   as Numeric
Local nX           as Numeric


lRet     := .T.
lAddLine := .T.
nX       := 1

oModelMaster := oModel:GetModel("F5XMASTER")
oModelDetail := oModel:GetModel("F5WDETAIL")
lAddLine := !EMPTY(AllTrim(oModelDetail:GetValue("F5W_DTPAYM")))
nOperation := oModel:GetModel("F5WDETAIL"):GetOperation()

If oModelDetail:GetLine() != 1  //For synchronization of records
    oModelDetail:GetLine(nX)
EndIf

dbSelectArea((cTable))
(cTable)->(DbGoTop())

While ((cTable)->(!EoF()))
    If INCLUI
        If lAddLine
            oModelDetail:AddLine()
        Else
            lAddLine := .T.
        EndIf
    Else
        oModelDetail:GoLine(nX)
        nX += 1
    EndIf

    If nOperation == MODEL_OPERATION_INSERT
        lRet := lRet .And. oModelDetail:SetValue("F5W_UIDF5X",oModelMaster:GetValue("F5X_UUID")) 
        lRet := lRet .And. oModelDetail:SetValue("F5W_UIDF49",(cTable)->F49_IDF49)
    EndIf
    lRet := lRet .And. oModelDetail:LoadValue("F5W_PAYTYP",(cTable)->F49_PAYTYP)
    Do Case
        Case oModelDetail:GetValue("F5W_PAYTYP") == '1'
            lRet := lRet .And. oModelDetail:LoadValue("F5W_ACCTYP",'1')
            lRet := lRet .And. oModelDetail:LoadValue("F5W_RECCOD",(cTable)->F49_SUPP)
            lRet := lRet .And. oModelDetail:LoadValue("F5W_REUNIT",(cTable)->F49_UNIT)
            lRet := lRet .And. oModelDetail:LoadValue("F5W_RECNAM",(cTable)->F49_RECNAM)
        Case oModelDetail:GetValue("F5W_PAYTYP") == '2'
            lRet := lRet .And. oModelDetail:LoadValue("F5W_ACCTYP",'2')
            lRet := lRet .And. oModelDetail:LoadValue("F5W_RECCOD",'')
            lRet := lRet .And. oModelDetail:LoadValue("F5W_RCUNIT",'')
            lRet := lRet .And. oModelDetail:LoadValue("F5W_RECNAM",'')
        Case oModelDetail:GetValue("F5W_PAYTYP") == '3'
            lRet := lRet .And. oModelDetail:LoadValue("F5W_ACCTYP",'')
            lRet := lRet .And. oModelDetail:LoadValue("F5W_RECCOD",'')
            lRet := lRet .And. oModelDetail:LoadValue("F5W_REUNIT",'')
            lRet := lRet .And. oModelDetail:LoadValue("F5W_RECNAM",'')
        Case oModelDetail:GetValue("F5W_PAYTYP") == '4'
            lRet := lRet .And. oModelDetail:LoadValue("F5W_ACCTYP",'3')
            lRet := lRet .And. oModelDetail:LoadValue("F5W_RECCOD",'')
            lRet := lRet .And. oModelDetail:LoadValue("F5W_REUNIT",'')
            lRet := lRet .And. oModelDetail:LoadValue("F5W_RECNAM",'')
        Case oModelDetail:GetValue("F5W_PAYTYP") == '5'
            lRet := lRet .And. oModelDetail:LoadValue("F5W_ACCTYP",'')
            lRet := lRet .And. oModelDetail:LoadValue("F5W_RECCOD",'')
            lRet := lRet .And. oModelDetail:LoadValue("F5W_REUNIT",'')
            lRet := lRet .And. oModelDetail:LoadValue("F5W_RECNAM",'')
        Case oModelDetail:GetValue("F5W_PAYTYP") == '6'
            lRet := lRet .And. oModelDetail:LoadValue("F5W_ACCTYP",'')
            lRet := lRet .And. oModelDetail:LoadValue("F5W_RECCOD",'')
            lRet := lRet .And. oModelDetail:LoadValue("F5W_REUNIT",'')
            lRet := lRet .And. oModelDetail:LoadValue("F5W_RECNAM",'')
        Case oModelDetail:GetValue("F5W_PAYTYP") == '7'
            lRet := lRet .And. oModelDetail:LoadValue("F5W_ACCTYP",'')
            lRet := lRet .And. oModelDetail:LoadValue("F5W_RECCOD",'')
            lRet := lRet .And. oModelDetail:LoadValue("F5W_REUNIT",'')
            lRet := lRet .And. oModelDetail:LoadValue("F5W_RECNAM",'')
    EndCase
    lRet := lRet .And. oModelDetail:LoadValue("F5W_PAYORD",(cTable)->F49_PAYORD)
    lRet := lRet .And. oModelDetail:LoadValue("F5W_DTPAYM",STOD((cTable)->F49_DTPAYM))
    lRet := lRet .And. oModelDetail:LoadValue("F5W_VALUE",(cTable)->F49_VALUE)
    If nOperation == MODEL_OPERATION_INSERT
        lRet := lRet .And. oModelDetail:LoadValue("F5W_STATUS",'1')
        lRet := lRet .And. oModelDetail:SetValue("MVC_CHK",.T.)
    Else
        If oModelDetail:GetValue("F5W_STATUS") == "1"
            lRet := lRet .And. oModelDetail:LoadValue("MVC_CHK",.T.) // It's important to set MVC_CHK only after F5W_VALUE, because validation calculating total value
        Else
            lRet := lRet .And. oModelDetail:LoadValue("MVC_CHK",.F.)
        EndIf
    EndIf
    (cTable)->(DbSkip())

EndDo

Return lRet

/*/{Protheus.doc} RU06D09010_Fopen
Creating of *.txt file
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09010_Fopen(oModel as Object)
Local lRet          as Logical
Local oModelMaster  as Object
Local cPathe        as Character
Local cBnkPay       as Character
Local cPayBik       as Character
Local cPayAcc       as Character
Local cTxtName      as Character
Local cExpNum       as Character
Local cFormatCode   as Character
Local cLine         as Character
Local nHandle       as Numeric
Local nTest         as Numeric
Local aSaveArea     as Array
Local aAreaSA6      as Array

Default cExpNum     := Space(TamSX3("F5X_EXPNUM")[1]) 
Default cTxtName    := Space(TamSX3("A6_TXTNUM")[1])

lRet := .T.

If oModel:GetID() == "RU06D09"
    oModelMaster := oModel:GetModel("F5XMASTER")
    cBnkPay      := oModelMaster:GetValue("F5X_BNKCOD")
    cPayBik      := oModelMaster:GetValue("F5X_BIK")
    cPayAcc      := oModelMaster:GetValue("F5X_ACCNT")
    cExpNum      := AllTrim(oModelMaster:GetValue("F5X_EXPNUM"))
    aSaveArea := GetArea() 
    aAreaSA6 := SA6->(GetArea())

    dbSelectArea("SA6")
    SA6->(dbSetOrder(1)) 
    If SA6->(dbSeek(xFilial("SA6")+cBnkPay+cPayBik+cPayAcc))
        cPathe      := AllTrim(SA6->A6_PATHE)
        cTxtName    := AllTrim(SA6->A6_TXTNUM)
        cFormatCode := AllTrim(SA6->A6_FRMCDE)
    Else
        Help("",1,STR0023,,STR0024,1,0)
    EndIf

    If !EMPTY(cPathe)
        cPathe := cPathe + '\' + cTxtName + ' ' + cExpNum + '.txt'
        nHandle := fOpen(cPathe,FO_READWRITE)

        If nHandle != -1
            nTest := fClose(nHandle)
            nTest := fErase(cPathe)
        EndIf

        nHandle := fCreate(cPathe)

        If nHandle == -1 
            If IsBlind()
                Help("",1,STR0027,,STR0028+cPathe+STR0029,1,0)
            Else
                MsgStop(STR0028+cPathe+STR0029,STR0027)
            EndIf
        Else
            Processa({|| cLine := RU06D09013_Fstruct(oModel, cFormatCode)},STR0044)
            RU06D09012_Fwrite(nHandle,cLine)
            If !IsBlind()
                MsgInfo(STR0028 + cTxtName + ' ' + cExpNum + STR0040,STR0039)
            EndIf
        EndIf
    Else
        Help("",1,STR0031,,STR0032,1,0)
    EndIf

    RestArea(aAreaSA6)  
    RestArea(aSaveArea) 
EndIf

Return lRet

/*/{Protheus.doc} RU06D09011_DateFormat
Formating the Date 
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09011_DateFormat(cDate as Character, cFormatCode as Character)
Local cDateCode   as Character
Local cItem       as Character
Local cDefSepar   as Character
Local cDay        as Character
Local cMonth      as Character
Local cFullYear   as Character 
Local cShortYear  as Character
Local aSaveArea   as Array
Local aAreaF5N    as Array

cDefSepar := ""
aSaveArea := GetArea() 
aAreaF5N  := F5N->(GetArea())
dbSelectArea("F5N")
F5N->(dbSetOrder(1))
If F5N->(dbSeek(xFilial("F5N")+cFormatCode)) .And. F5N_FRMTYP == "1"
    cDefSepar  := AllTrim(F5N->F5N_DTSEPR)
EndIf

If Len(cDate) == 10
    cDay       := SubStr(cDate,1,2)
    cMonth     := SubStr(cDate,4,2)
    cFullYear  := SubStr(cDate,7,4)
    cShortYear := SubStr(cDate,9,2)
Else
    cDay       := SubStr(cDate,7,2)
    cMonth     := SubStr(cDate,5,2)
    cFullYear  := SubStr(cDate,1,4)
    cShortYear := SubStr(cDate,3,2)
EndIf

dbSelectArea("F5N")
F5N->(dbSetOrder(1))
If F5N->(dbSeek(xFilial("F5N")+cFormatCode)) .And. F5N_FRMTYP == "1"
    cDateCode := F5N->F5N_DTFRMT
EndIf

If !EMPTY(AllTrim(cDateCode))
    cItem := RU06XFUN32_GetFromCbox("F5N_DTFRMT",cDateCode)
EndIf 

If !EMPTY(AllTrim(cDate))
    Do Case
        Case "DD.MM.YYYY" $ cItem
            cDate := cDay + cDefSepar + cMonth + cDefSepar + cFullYear
        Case "DD.MM.YY" $ cItem
            cDate := cDay + cDefSepar + cMonth + cDefSepar + cShortYear
        Case "YYYY.MM.DD" $ cItem
            cDate := cFullYear + cDefSepar + cMonth + cDefSepar + cDay
        Case "YY.MM.DD" $ cItem
            cDate := cShortYear + cDefSepar + cMonth + cDefSepar + cDay
        Case "MM.DD.YYYY" $ cItem
            cDate := cMonth + cDefSepar + cDay + cDefSepar + cFullYear
        Case "MM.DD.YY" $ cItem
            cDate := cMonth + cDefSepar + cDay + cDefSepar + cShortYear
    EndCase
EndIf

RestArea(aAreaF5N)  
RestArea(aSaveArea) 

Return cDate

/*/{Protheus.doc} RU06D09012_Fwrite
Writing into the *.txt file
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09012_Fwrite(nHandle as Numeric, cLine as Character)

fWrite(nHandle,cLine)
fClose(nHandle)

Return Nil

/*/{Protheus.doc} RU06D09013_Fstruct
Building the structure of *.txt file
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09013_Fstruct(oModel as Object, cFormatCode as Character)
Local cLine            as Character
Local cTabSections     as Character
Local cTabTags         as Character
Local cTabSecHead      as Character
Local cTabSecPayOrd    as Character
Local cTabTagHead      as Character
Local cTabTagPayOrd    as Character
Local cSectionHead     as Character
Local cSectionPO       as Character
Local cOrderBy         as Character
Local oModelMaster     as Object
Local oModelDetail     as Object
Local oModelPO         as Object
Local oModelF49        as Object
Local nX               as Numeric
Local nProcess         as Numeric
Local aSaveArea        as Array
Local aAreaF49         as Array
Local aAreaF5N         as Array
Local lRet             as Logical

cSectionHead := '1'          //Header section
cSectionPO   := '3'          //Payment Order
cTabSections := 'F5U'        //Bank Client Format Sections
cTabTags     := 'F5V'        //Bank Client Format Tags
cOrderBy     := 'F5V_TAGSEQ' //Order by row number

lRet         := .F.

oModelMaster := oModel:GetModel("F5XMASTER")
oModelDetail := oModel:GetModel("F5WDETAIL")

cTabSecHead   := RU01GETALS(RU06D09014_FAlias(cTabSections,cFormatCode,cSectionHead))
cTabSecPayOrd := RU01GETALS(RU06D09014_FAlias(cTabSections,cFormatCode,cSectionPO))
cTabTagHead   := RU01GETALS(RU06D09014_FAlias(cTabTags,cFormatCode,cSectionHead,cOrderBy))
cTabTagPayOrd := RU01GETALS(RU06D09014_FAlias(cTabTags,cFormatCode,cSectionPO,cOrderBy))

cLine := (cTabSecHead)->&((cTabSections)+"_TGBGN") + CRLF
nProcess := oModelDetail:Length()

aSaveArea := GetArea() 
aAreaF49 := F49->(GetArea())
dbSelectArea("F49")
F49->(dbSetOrder(2))
If F49->(dbSeek(xFilial("F49")+oModelDetail:GetValue("F5W_UIDF49")))
    oModelPO := FwLoadModel("RU06D05")
    oModelPO:SetOperation(MODEL_OPERATION_VIEW)
    oModelPO:Activate() 
    oModelF49 :=  oModelPO:GetModel("RU06D05_MF49")
EndIf

aAreaF5N := F5N->(GetArea())
dbSelectArea("F5N")
F5N->(dbSetOrder(1))
If F5N->(dbSeek(xFilial("F5N")+cFormatCode))
    lRet := .T.
EndIf

While ((cTabTagHead)->(!EoF()))
    cLine += AllTrim((cTabTagHead)->&((cTabTags)+"_TAG")) + "=" + RU06D09015_FParser(AllTrim((cTabTagHead)->&((cTabTags)+"_VALUE")),oModelMaster,oModelDetail,cFormatCode,(cTabTagHead)->&((cTabTags)+"_TAGTYP"),oModelF49) +CRLF
    (cTabTagHead)->(DbSkip())
EndDo

If oModelPO:IsActive()
    oModelPO:DeActivate()
EndIf

ProcRegua(nProcess)

For nX := 1 to oModelDetail:Length()
    IncProc(STR0045)
    oModelDetail:GoLine(nX)
    If !(oModelDetail:IsDeleted()) .And. oModelDetail:GetValue("MVC_CHK")
        cLine += AllTrim((cTabSecPayOrd)->&((cTabSections)+"_TGBGN")) + "=" + AllTrim((cTabSecPayOrd)->&((cTabSections)+"_VALUE")) +CRLF
        (cTabTagPayOrd)->(dbGoTop())
        If F49->(dbSeek(xFilial("F49")+oModelDetail:GetValue("F5W_UIDF49")))
            oModelPO := FwLoadModel("RU06D05")
            oModelPO:SetOperation(MODEL_OPERATION_VIEW)
            oModelPO:Activate() 
            oModelF49 :=  oModelPO:GetModel("RU06D05_MF49")
            RecLock("F49",.F.)
                F49->F49_STATUS := "2"  //Sent to the bank
            MsUnlock()
        EndIf
        While ((cTabTagPayOrd)->(!EoF()))
            cLine += AllTrim((cTabTagPayOrd)->&((cTabTags)+"_TAG")) + "=" + RU06D09015_FParser(AllTrim((cTabTagPayOrd)->&((cTabTags)+"_VALUE")),oModelMaster,oModelDetail,cFormatCode,(cTabTagPayOrd)->&((cTabTags)+"_TAGTYP"),oModelF49) +CRLF
            (cTabTagPayOrd)->(DbSkip())
        EndDo
        cLine += AllTrim((cTabSecPayOrd)->&((cTabSections)+"_TGEND")) + CRLF
    EndIf
Next nX

cLine += AllTrim((cTabSecHead)->&((cTabSections)+"_TGEND")) + CRLF

(cTabSecHead)->(dbCloseArea())
(cTabSecPayOrd)->(dbCloseArea())
(cTabTagHead)->(dbCloseArea())
(cTabTagPayOrd)->(dbCloseArea()) 

RestArea(aAreaF5N)
RestArea(aAreaF49)  
RestArea(aSaveArea) 

Return cLine
 
/*/{Protheus.doc} RU06D09014_FAlias
Temporary table for Format code
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09014_FAlias(cTable as Character, cFormatCode as Character, cSection as Character, cOrderBy as Character)

Local cQuery        as Character

Default cOrderBy = ""

cQuery := " SELECT * FROM " + RetSQLName(cTable)
cQuery += " WHERE " + cTable + "_FILIAL= '" + xFilial(cTable) + "' "  
cQuery += " AND " + cTable + "_FRMCOD = '" + cFormatCode + "' "
cQuery += " AND " + cTable + "_SECTN = '" + cSection + "' "
cQuery += " AND D_E_L_E_T_ = ' ' "
If !EMPTY(AllTrim(cOrderBy))
    cQuery += " ORDER BY " + cOrderBy + " ASC"
EndIf

Return cQuery

/*/{Protheus.doc} RU06D09015_FParser
Executing values from F5V, for file structure.
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09015_FParser(cSupposition as Character, oModelMaster as Object, oModelDetail as Object, cFormatCode as Character, cFldType as Character, oModelF49 as Object)
Local cValue    as Character
Local aSaveArea as Array
Local aAreaF45  as Array
Local aAreaSA2  as Array
Local aAreaF49  as Array

Default cValue := ""

Do Case
    Case cSupposition == "EH-01"    // Encoding
        cValue := F5N->F5N_CODING
    Case cSupposition == "EH-02"    // Creation date
        cValue := DTOC(dDataBase) 
    Case cSupposition == "EH-03"    // Creation time
        cValue := Time() 
    Case cSupposition == "EH-04" .And. !EMPTY(oModelMaster:GetValue("F5X_INIDAT"))     // Initial date
        cValue := DTOC(oModelMaster:GetValue("F5X_INIDAT")) 
    Case cSupposition == "EH-05" .And. !EMPTY(oModelMaster:GetValue("F5X_ENDDAT"))    // End date
        cValue := DTOC(oModelMaster:GetValue("F5X_ENDDAT")) 
    Case cSupposition == "EH-06" .And. !EMPTY(oModelMaster)    // Bank account
        cValue := oModelMaster:GetValue("F5X_ACCNT")
    Case cSupposition == "EH-07"    // Program-receiver
        cValue := F5N->F5N_PROREC
    Case cSupposition == "EH-08"    // Program-sender
        cValue := F5N->F5N_PROSEN
    Case cSupposition == "EH-09"    // Format version
        cValue := F5N->F5N_FORVER
    Case cSupposition == "EP-01" .And. !EMPTY(oModelF49)    // Document num
        cValue := oModelF49:GetValue("F49_PAYORD")
    Case cSupposition == "EP-02" .And. !EMPTY(oModelF49)    // Document date
        cValue := oModelF49:GetValue("F49_DTPAYM")
    Case cSupposition == "EP-03" .And. !EMPTY(oModelF49)    // Payment amount
        cValue := oModelF49:GetValue("F49_VALUE")
    Case cSupposition == "EP-04" .And. !EMPTY(oModelF49)    // Payer accont
        cValue := oModelF49:GetValue("F49_PAYACC")
    Case cSupposition == "EP-05"    // INN and Name of payer
        cValue := STR0042 + AllTrim(FwComAltInf({"CO_INN"})[1][2]) + " " + oModelF49:GetValue("F49_PAYNAM")
    Case cSupposition == "EP-06"    // Payer INN
        cValue := AllTrim(FwComAltInf({"CO_INN"})[1][2])
    Case cSupposition == "EP-07" .And. !EMPTY(oModelF49)    // Payer KPP
        cValue := oModelF49:GetValue("F49_KPPPAY")
    Case cSupposition == "EP-08" .And. !EMPTY(oModelF49)    // Payer name
        cValue := oModelF49:GetValue("F49_PAYNAM")
    Case cSupposition == "EP-09" .And. !EMPTY(oModelF49)    // Payer bank
        cValue := oModelF49:GetValue("F49_BKPNAM")
    Case cSupposition == "EP-10" .And. !EMPTY(oModelMaster)    // City of payer bank
        aSaveArea := GetArea()
        aAreaF45  := F45->(GetArea())
        dbSelectArea("F45")
        F45->(dbSetOrder(1))
        If F45->(dbSeek(xFilial("F45")+oModelMaster:GetValue("F5X_BIK")))
            cValue := F45->F45_CITY
        EndIf
        RestArea(aAreaF45)
        RestArea(aSaveArea)
    Case cSupposition == "EP-11"    // BIK of payer bank
        cValue := F49_PAYBIK
    Case cSupposition == "EP-12" .And. !EMPTY(oModelMaster)    // Coraccount of payer bank
        aSaveArea := GetArea()
        aAreaF45  := F45->(GetArea())
        dbSelectArea("F45")
        F45->(dbSetOrder(1))
        If F45->(dbSeek(xFilial("F45")+oModelMaster:GetValue("F5X_BIK")))
            cValue := F45->F45_CORRAC
        EndIf
        RestArea(aAreaF45)
        RestArea(aSaveArea)
    Case cSupposition == "EP-13"    // Receiver name
        cValue := oModelF49:GetValue("F49_RECNAM")
    Case cSupposition == "EP-14" .And. !EMPTY(oModelF49)    // Receiver INN
        aSaveArea := GetArea()
        aAreaSA2  := SA2->(GetArea())
        dbSelectArea("SA2")
        SA2->(dbSetOrder(1))
        If SA2->(dbSeek(xFilial("SA2")+oModelF49:GetValue("F49_SUPP")+oModelF49:GetValue("F49_UNIT")))
            cValue := SA2->A2_CODZON
        EndIf
        RestArea(aAreaSA2)
        RestArea(aSaveArea)
    Case cSupposition == "EP-15" .And. !EMPTY(oModelF49)    // Receiver KPP
        cValue := oModelF49:GetValue("F49_KPPREC")
    Case cSupposition == "EP-16" .And. !EMPTY(oModelF49)    // Receiver account
        cValue := oModelF49:GetValue("F49_RECACC")
    Case cSupposition == "EP-17" .And. !EMPTY(oModelF49)    // Receiver bank
        cValue := oModelF49:GetValue("F49_BKRNAM")
    Case cSupposition == "EP-18" .And. !EMPTY(oModelF49)    // City of receiver bank
        aSaveArea := GetArea()
        aAreaF45  := F45->(GetArea())
        dbSelectArea("F45")
        F45->(dbSetOrder(1))
        If F45->(dbSeek(xFilial("F45")+oModelF49:GetValue("F49_RECBIK")))
            cValue := F45->F45_CITY
        EndIf
        RestArea(aAreaF45)
        RestArea(aSaveArea)
    Case cSupposition == "EP-19" .And. !EMPTY(oModelF49)    // BIK of receiver bank
        cValue := oModelF49:GetValue("F49_RECBIK")
    Case cSupposition == "EP-20" .And. !EMPTY(oModelF49)    // Coraccount of receiver bank
        aSaveArea := GetArea()
        aAreaF45  := F45->(GetArea())
        dbSelectArea("F45")
        F45->(dbSetOrder(1))
        If F45->(dbSeek(xFilial("F45")+oModelF49:GetValue("F49_RECBIK")))
            cValue := F45->F45_CORRAC
        EndIf
        RestArea(aAreaF45)
        RestArea(aSaveArea)
    Case cSupposition == "EP-21"    // Payment type
        cValue := STR0043
    Case cSupposition == "EP-22"    // Operation type
        cValue := '01'
    Case cSupposition == "EP-23" .And. !EMPTY(oModelF49)    // Priority
        cValue := oModelF49:GetValue("F49_PRIORI")
    Case cSupposition == "EP-24" .And. !EMPTY(oModelF49)    // Reason of payment
        aSaveArea := GetArea()
        aAreaF49  := F49->(GetArea())
        dbSelectArea("F49")
        F49->(dbSetOrder(2))
        /* In case when we need to get value from memo field, 
        we should get it from table directly, not from model. */
        If F49->(dbSeek(xFilial("F49")+oModelF49:GetValue("F49_IDF49")))
            cValue := F49->F49_REASON
            cValue := StrTran(cValue,CHR(10)) // Value of Memo fields has a specific symbols at the end, that we need to erase.
            cValue := StrTran(cValue,CHR(13)) 
        EndIf
        RestArea(aAreaF49)
        RestArea(aSaveArea)
    Otherwise
        cValue := ""
EndCase

cValue := RU06D09016_ValType(cValue, cFldType, cFormatCode)

Return cValue

/*/{Protheus.doc} RU06D09016_ValType
Variable type definition
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09016_ValType(xValue, cFldType as Character, cFormatCode as Character)
Local cString   as Character

Do Case
    Case cFldType == "3"
        If ValType(xValue) == "N"
            cString := RU06D09017_Separator(xValue, cFormatCode)
        ElseIf ValType(xValue) == "C"
            cString := RU06D09017_Separator(Val(xValue), cFormatCode)
        Else
            cString := ""
        EndIf
    Case cFldType == "2" 
        If ValType(xValue) == "D"
            cString := AllTrim(DTOC(xValue))
            cString := RU06D09011_DateFormat(cString, cFormatCode)
        ElseIf ValType(xValue) == "C"
            cString := xValue
            cString := RU06D09011_DateFormat(cString, cFormatCode)
        Else
            cString := ""
        EndIf
    Case ValType(xValue) == "C"
        cString := AllTrim(xValue)
    Otherwise
        cString := ""
EndCase

Return cString

/*/{Protheus.doc} RU06D09017_Separator
Putting separator for numbers from F5V for *.txt structure
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09017_Separator(xValue, cFormatCode as Character)
Local cSeparator as Character
Local cString    as Character
Local aSaveArea  as Array
Local aAreaF5N   as Array

cString := ""

aSaveArea := GetArea() 
aAreaF5N  := F5N->(GetArea())
dbSelectArea("F5N")
F5N->(dbSetOrder(1))
If F5N->(dbSeek(xFilial("F5N")+cFormatCode)) .And. F5N_FRMTYP == "1"
    cSeparator := AllTrim(F5N->F5N_NMSEPR)
EndIf

If !EMPTY(xValue)
    cString := AllTrim(Transform(xValue, "@E 9,999,999,999,999.99")) 
    If !EMPTY(cSeparator)
        cString := StrTran(cString,",",cSeparator)
        cString := StrTran(cString," ",)
    EndIf
EndIf

RestArea(aAreaF5N)  
RestArea(aSaveArea) 

Return cString

/*/{Protheus.doc} RU06D09018_DelGridLine
Deleting of grid lines that was unselected by user, before transaction
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09018_DelGridLine(oModel as Object)
Local oModelDetail as Object
Local nX           as Numeric
Local lRet         as Logical

lRet         := .T.
oModelDetail := oModel:GetModel("F5WDETAIL")

For nX := 1 to oModelDetail:Length()
    oModelDetail:GoLine(nX)
    If !(oModelDetail:GetValue("MVC_CHK"))
        oModelDetail:DeleteLine()
    EndIf
Next nX

oModelDetail:GoLine(1)

Return lRet

/*/{Protheus.doc} RU06D09019_Legenda
Legend of journal
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09019_Legenda()
Local aRet as Array 

aRet := {}

aAdd(aRet,{ "BR_VERMELHO", STR0002 }) // Red = Canceled
aAdd(aRet,{ "BR_VERDE", STR0001 })     // Green = Created

BrwLegenda(STR0003,STR0009, aRet)

Return aRet

/*/{Protheus.doc} RU06D09020_Edit
Editing of Client-bank export journal
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09020_Edit()
Local lRet   as Logical
Local cTable as Character
Local oModelDetail as Object
Local oModel as Object

lRet := .T.
oModel := FwLoadModel("RU06D09")
oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate() 
oModelDetail := oModel:GetModel("F5WDETAIL")

If oModelDetail:Length() != 0
    cTable := RU06D09021_F49TemTable(oModelDetail)
    RU06D09009_FillGrid(oModel,cTable)
    oModelDetail:GoLine(1) //After "For" we should turn back position for the first line
    FwExecView(STR0033, "RU06D09", MODEL_OPERATION_UPDATE,/* oDlg */, {|| .T.},/* ok */,/*nPercReducation*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel)
Else
    Help("",1,STR0002,,STR0041,1,0)
EndIf
       
Return lRet

/*/{Protheus.doc} RU06D09021_F49TemTable
Building of temporary F49 table with POs inside, for F5WDETAIL
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09021_F49TemTable(oModelDetail as Object)
Local cQuery as Character
Local cWhereIn as Character
Local cTable as Character
Local nX as Numeric

cWhereIn := " ("
    For nX := 1 to oModelDetail:Length()
        oModelDetail:GoLine(nX)
        cWhereIn += " '" + oModelDetail:GetValue("F5W_UIDF49") + "' "
        If nX < oModelDetail:Length()
            cWhereIn += ","
        EndIf
    Next nX
cWhereIn += ") "

cQuery := " SELECT * FROM " + RetSQLName("F49")
cQuery += " WHERE F49_FILIAL = '" + xFilial("F49") + "' "
cQuery += " AND F49_IDF49 IN " + cWhereIn
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY F49_IDF49 "

cTable := RU01GETALS(cQuery)

oModelDetail:GoLine(1) //After "For" we should turn back position for the first line

Return cTable

/*/{Protheus.doc} RU06D09022_EditGridLines
InTTS, processing after Edit, changing data in tables
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09022_EditGridLines(oModel as Object)
Local lRet          as Logical
Local oModelDetail  as Object
Local nX            as Numeric
Local aSaveArea     as Array
Local aAreaF49      as Array

lRet         := .T.
oModelDetail := oModel:GetModel("F5WDETAIL")
aSaveArea := GetArea() 
aAreaF49 := F49->(GetArea())

For nX := 1 to oModelDetail:Length()
    oModelDetail:GoLine(nX)
    If !(oModelDetail:GetValue("MVC_CHK"))
        dbSelectArea("F49")
        F49->(dbSetOrder(2))
        If F49->(dbSeek(xFilial("F49")+oModelDetail:GetValue("F5W_UIDF49")))
            RecLock("F49",.F.)
                F49->F49_STATUS := "1"  //Created
            MsUnlock()
        EndIf
    Else
        dbSelectArea("F49")
        F49->(dbSetOrder(2))
        If F49->(dbSeek(xFilial("F49")+oModelDetail:GetValue("F5W_UIDF49"))) .And. F49->F49_STATUS != "2"
            RecLock("F49",.F.)
                F49->F49_STATUS := "2"  //Sent to Bank
            MsUnlock()  
        EndIf
    EndIf
Next nX

oModelDetail:GoLine(1)

RestArea(aAreaF49)  
RestArea(aSaveArea) 

Return lRet

/*/{Protheus.doc} RU06D09023_CancelUncancel
Function for custom buttons Cancel/Uncancel line, only for Edit mode.
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09023_CancelUncancel(oModel as Object, lMark as Logical)
Local lRet          as Logical
Local oModelDetail  as Object
Local aSaveArea     as Array
Local aAreaF49      as Array

lRet := .T.
oModelDetail := oModel:GetModel("F5WDETAIL")

aSaveArea := GetArea() 
aAreaF49 := F49->(GetArea())
dbSelectArea("F49")
dbSetOrder(2)
If F49->(dbSeek(xFilial("F49")+oModelDetail:GetValue("F5W_UIDF49")))
    If lMark .And. !(oModelDetail:GetValue("MVC_CHK"))
        oModelDetail:SetValue("MVC_CHK",.T.)
    ElseIf !lMark .And. oModelDetail:GetValue("MVC_CHK")
        oModelDetail:SetValue("MVC_CHK",.F.)
    EndIf
EndIf
RestArea(aAreaF49)  
RestArea(aSaveArea) 

Return lRet

/*/{Protheus.doc} RU06D09024_Button
Creating of custom buttons fot Edit mode.
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09024_Button(oView as Object)
Local oModel as Object

oModel := oView:GetModel()

If oModel:GetID() == "RU06D09" .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE
    oView:AddUserButton(STR0034, '', {|| RU06D09023_CancelUncancel(oModel,.F.)})
    oView:AddUserButton(STR0035, '', {|| RU06D09023_CancelUncancel(oModel,.T.)})
EndIf

Return oView 

/*/{Protheus.doc} RU06D09025_POValid
Validating of orders. Can they be canceled or not?
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09025_POValid(oModelDetail as Object)
Local lRet as Logical
Local cQuery as Character
Local cTableF4C as Character
Local cTableF5W as Character

cQuery := " SELECT * FROM " + RetSQLName("F4C")
cQuery += " WHERE F4C_FILIAL = '" + xFilial("F4C") + "' "
cQuery += " AND F4C_IDF49 = '" + oModelDetail:GetValue("F5W_UIDF49") + "' "
cQuery += " AND D_E_L_E_T_ = ' ' "

cTableF4C := RU01GETALS(cQuery)

cQuery := " SELECT * FROM " + RetSQLName("F5W")
cQuery += " WHERE F5W_FILIAL = '" + xFilial("F5W") + "' "
cQuery += " AND F5W_UIDF49 = '" + oModelDetail:GetValue("F5W_UIDF49") + "' "
cQuery += " AND F5W_STATUS = '1' "
cQuery += " AND F5W_UIDF5X != '" + oModelDetail:GetValue("F5W_UIDF5X") + "' "
cQuery += " AND D_E_L_E_T_ = ' ' "

cTableF5W := RU01GETALS(cQuery)

If ((cTableF4C)->(!EoF())) .Or. ((cTableF5W)->(!EoF()))
    lRet := .F.
Else
    lRet := .T.
EndIf

Return lRet

/*/{Protheus.doc} RU06D09026_POControl
BeforeTTS. Changing of status after Editing.
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09026_POControl(oModel as Object)
Local lRet         as Logical
Local lValid       as Logical
Local oModelDetail as Object
Local nX           as Numeric

lRet         := .T.
oModelDetail := oModel:GetModel("F5WDETAIL")

For nX := 1 to oModelDetail:Length()
    oModelDetail:GoLine(nX)
    If oModelDetail:GetValue("MVC_CHK")
        lValid := RU06D09025_POValid(oModelDetail)
        If !lValid
            oModelDetail:SetValue("MVC_CHK",.F.)
            oModelDetail:SetValue("F5W_STATUS","2")
            Help("",1,STR0016,,STR0017 + oModelDetail:GetValue("F5W_PAYORD") + STR0018,1,0)
        EndIf
    EndIf
Next nX

Return lRet

/*/{Protheus.doc} RU06D09027_FullCancel
Function of full cancelation of export journal.
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09027_FullCancel()
Local lRet as Logical
Local lChoice as Logical
Local cTable as Character
Local oModelDetail as Object
Local oModel as Object
Local aFields as Array
Local nX as Numeric

lRet   := .T.

If !IsBlind()
    lChoice := MsgYesNo(STR0036,STR0027)
Else
    lChoice := .T.
EndIf

If lChoice
    oModel := FwLoadModel("RU06D09")
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate() 
    oModelDetail := oModel:GetModel("F5WDETAIL")

    If oModelDetail:Length() != 0
        cTable := RU06D09021_F49TemTable(oModelDetail)
        RU06D09009_FillGrid(oModel,cTable)

        For nX := 1 to oModelDetail:Length()
            oModelDetail:GoLine(nX)
            If oModelDetail:GetValue("MVC_CHK")
                oModelDetail:SetValue("MVC_CHK",.F.)
            EndIf
        Next nX

        oModel:GetModel("F5XMASTER"):SetValue("F5X_STATUS","2")

        aFields := oModelDetail:GetStruct():GetFields()

        For nX := 1 to Len(aFields)
            oModelDetail:GetStruct():SetProperty(aFields[nX][MODEL_FIELD_IDFIELD],MODEL_FIELD_WHEN,{||.F.})
        Next nX

        oModelDetail:GoLine(1) //After "For" we should turn back position for the first line
    EndIf

    FwExecView(STR0007, "RU06D09", MODEL_OPERATION_UPDATE,/* oDlg */, {|| .T.},/* ok */,/*nPercReducation*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel)
EndIf

Return lRet

/*/{Protheus.doc} RU06D09028_ReCreation
Function to recreate the *.txt file
@author Konstantin Cherchik
@since 04/10/2019
@version P12.1.25
@type function
/*/
Function RU06D09028_ReCreation()
Local lRet as Logical
Local lChoice as Logical
Local cTable as Character
Local oModelDetail as Object 
Local oModel as Object

lRet := .T.
lChoice := .T.
oModel := FwLoadModel("RU06D09")
oModel:Activate() 

If oModel:GetModel("F5XMASTER"):GetValue("F5X_STATUS") != "2"
    If !IsBlind()
        lChoice := MsgYesNo(STR0038,STR0027)
    EndIf
    If lChoice
        oModelDetail := oModel:GetModel("F5WDETAIL")
        cTable := RU06D09021_F49TemTable(oModelDetail)
        RU06D09009_FillGrid(oModel,cTable)
        oModelDetail:GoLine(1)
        RU06D09010_Fopen(oModel)
    EndIf
Else
    Help("",1,STR0008,,STR0037,1,0)
EndIf

Return lRet 