#INCLUDE "PROTHEUS.CH"    
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#include "TOTVS.CH"
#include "RU06D05.CH"
#Include "RWMAKE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D05
Payment Ordes (main) Routine 
@author natalia.khozyainova
@since 18/07/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D05()
Local oBrowse as Object
// Included because of the MSDOCUMENT routine, 
// the MVC does not need any private variables 
// but MSDOCUMENT needs aRrotina and cCadastro
Private cCadastro as Character 
Private aRotina as Array

aRotina		:= {}
cCadastro := STR0002 //Payment Order

oBrowse := BrowseDef()
oBrowse:Activate()
 
Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition.
@author natalia.khozyainova
@since 24/07/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
Local oBrowse 	as Object

oBrowse	:= FWmBrowse():New()
oBrowse:SetAlias("F49")
oBrowse:SetDescription(STR0001) // Payment Orders  
oBrowse:SetAttach(.T.)
oBrowse:AddLegend("F49_STATUS =='1'", "WHITE",  STR0003) // Created
oBrowse:AddLegend("F49_STATUS =='2'", "YELLOW", STR0004) // Sent to bank
oBrowse:AddLegend("F49_STATUS =='3'", "RED",    STR0005) // Rejected
oBrowse:AddLegend("F49_STATUS =='4'", "GREEN",  STR0006) //Paid

aRotina := Nil // needed for MSDOCUMENT
oBrowse:SetCacheView(.F.)// needed for MSDOCUMENT

Return (oBrowse) 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu definition.
@author natalia.khozyainova
@since 17/07/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()
Local aRotina as Array

aRotina := {}

ADD OPTION aRotina TITLE STR0007   ACTION "RU06D0510_Act(1)"    OPERATION 1 ACCESS 0   // View
ADD OPTION aRotina TITLE STR0008   ACTION "RU06D0510_Act(3,1)"  OPERATION 3 ACCESS 0   // Add from request
ADD OPTION aRotina TITLE STR0009   ACTION "RU06D0510_Act(3,2)"  OPERATION 3 ACCESS 0   // Add manually

ADD OPTION aRotina TITLE STR0010   ACTION "RU06D0510_Act(4)"    OPERATION 4 ACCESS 0   // Edit
ADD OPTION aRotina TITLE STR0011   ACTION "RU06D0510_Act(5)"    OPERATION 5 ACCESS 0   // Delete
ADD OPTION aRotina TITLE STR0012   ACTION "MSDOCUMENT"          OPERATION 4 ACCESS 0   // Knowledge (Upload Documents)
ADD OPTION aRotina TITLE STR0013   ACTION "RU06D0510_Act(9)"    OPERATION 9 ACCESS 0   // Copy
ADD OPTION aRotina TITLE STR0014   ACTION "RU06D0511_Legend"    OPERATION 7 ACCESS 0   // Legend
ADD OPTION aRotina TITLE STR0015   ACTION "RU06D0516_Status"    OPERATION 4 ACCESS 0   // Change Status

Return (aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition for the case when PO is created from list of PRs.
It contains 3 levels: F49 (PO), F4A (PRs), F4B (APs) 
@author natalia.khozyainova
@since 24/07/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()
Local oStrF49 	as Object
Local oStrF4A 	as Object
Local oStrF4B 	as Object
Local oModel    as Object
Local aF4ARel   as Array
Local aF4BRel   as Array
Local oStrAllBills as Object
Local nOper     as Numeric

Local oUpdF49Event 	:= RU06D05EventRUS():New()


aF4ARel:={}
aF4BRel:={}

oModel:= MPFormModel():New("RU06D05")
oModel:SetDescription(STR0002) // Payment Order 
nOper := oModel:GetOperation()
    
// Header structure - F49 Payment Order - Header
oStrF49 := FWFormStruct(1, "F49")
oStrF49:SetProperty("F49_PAYTYP", MODEL_FIELD_INIT, {|| RU06D0512_InitOrdType() }  ) 
oStrF49:SetProperty("F49_IDF49", MODEL_FIELD_INIT, {|| FWUUIDV4(.F.) }  )
oStrF49:AddTrigger("F49_SUPP","F49_UNIT"  ,,{ |oModel| RU06D0548_GatForn("F49_UNIT")  })
oStrF49:AddTrigger("F49_SUPP","F49_SUPNAM",,{ |oModel| RU06D0548_GatForn("F49_SUPNAM")})
oStrF49:AddTrigger("F49_SUPP","F49_KPPREC",,{ |oModel| RU06D0548_GatForn("F49_KPPREC")})
oStrF49:AddTrigger("F49_UNIT","F49_SUPNAM",,{ |oModel| RU06D0548_GatForn("F49_SUPNAM")})
oStrF49:AddTrigger("F49_UNIT","F49_KPPREC",,{ |oModel| RU06D0548_GatForn("F49_KPPREC")})

// Items structure - F4A Payment Requests
oStrF4A:= FWFormStruct(1, "F4A")
oStrF4A:AddField("FILREQ", "FILREQ", "F4A_FILREQ", "C", LEN(XFILIAL()), /*[ nDecimal ]*/,/*{|| }*/, /*[ bWhen ]*/ ,/* [ aValues ]*/,/* [ lObrigat ]*/,{|| Iif(nOper != 3,F49->F49_FILREQ,"") } /*[ bInit ]*/, .F./*, [ lNoUpd ], [ lVirtual ], [ cValid ]*/)

// Items grandson structure - F4B Payment Requests - Lines
oStrF4B:= FWFormStruct(1, "F4B")
oStrF4B:AddField("CheckBox", "CheckBox", "F4B_CHECK", "L", 1, /*[ nDecimal ]*/,/*{|| }*/, /*[ bWhen ]*/,/* [ aValues ]*/,/* [ lObrigat ]*/, /*[ bInit ]*/, .F./*, [ lNoUpd ], [ lVirtual ], [ cValid ]*/)
oStrF4B:SetProperty("F4B_CHECK"	,MODEL_FIELD_INIT,{|| F4B->F4B_RATUSR== "1"})

// Virtual structure to show list of bills from all requests
oStrAllBills := RU06D0525_DefVirtStr()

oModel:AddFields("RU06D05_MF49", NIL, oStrF49 )
oModel:GetModel("RU06D05_MF49"):SetDescription(STR0002) // Payment Order 
oModel:GetModel("RU06D05_MF49"):SetFldNoCopy({'F49_FILIAL','F49_IDF49','F49_STATUS','F49_PAYORD','F49_BNKORD','F49_DTPAYM', 'F49_FILREQ'})

oModel:AddGrid('RU06D05_MF4A','RU06D05_MF49',oStrF4A)
oModel:GetModel("RU06D05_MF4A"):SetDescription(STR0016) // Payment Requests included in PO
oModel:GetModel('RU06D05_MF4A'):SetOptional(.T.)
//Array to set the relation betwen the header and the request
aAdd(aF4ARel, {'F4A_FILIAL',    'xFilial( "F4A" )'} )
aAdd(aF4ARel, {'F4A_IDF49', 'F49_IDF49'})
oModel:SetRelation('RU06D05_MF4A', aF4ARel, F4A->(IndexKey(1))) 
oModel:GetModel("RU06D05_MF4A"):SetNoInsertLine(.T.)
oModel:GetModel("RU06D05_MF4A"):SetNoUpdateLine(.T.)
oModel:GetModel("RU06D05_MF4A"):SetFldNoCopy(RU06D0540_Array(oModel:GetModel("RU06D05_MF4A")))


oModel:AddGrid('RU06D05_MF4B','RU06D05_MF4A',oStrF4B)  
oModel:GetModel("RU06D05_MF4B"):SetDescription(STR0017) // APs in included in PO
oModel:GetModel('RU06D05_MF4B'):SetOptional(.T.)
//Array to set the relation betwen the request and the bills
aAdd(aF4BRel, {'F4B_FILIAL', 'xFilial( "F4B" )'} )
aAdd(aF4BRel, {'F4B_IDF4A', 'F4A_IDF4A'}) 
oModel:SetRelation('RU06D05_MF4B', aF4BRel, F4B->(IndexKey(1))) 
oModel:GetModel("RU06D05_MF4B"):SetNoInsertLine(.T.)
oModel:GetModel("RU06D05_MF4B"):SetNoDeleteLine(.T.)
oModel:GetModel("RU06D05_MF4B"):SetFldNoCopy(RU06D0540_Array(oModel:GetModel("RU06D05_MF4B")))


oModel:AddGrid("RU06D05_MVIRT", "RU06D05_MF49", oStrAllBills, /*bPreValid*/	, /*bPosValid*/	,,, {|oModel| RU06D0526_LoadBills(oModel)}/* bLoad*/ )
oModel:GetModel("RU06D05_MVIRT"):SetDescription(STR0018) // All bills to show only
oModel:GetModel("RU06D05_MVIRT"):SetOnlyView(.T.)
oModel:GetModel('RU06D05_MVIRT'):SetOptional(.T.)
oModel:GetModel("RU06D05_MVIRT"):SetFldNoCopy(RU06D0540_Array(oModel:GetModel("RU06D05_MVIRT")))

oModel:SetPrimaryKey({})
oModel:InstallEvent("Name",,oUpdF49Event)
Return (oModel)


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition for the case when PO is created from list of PRs.
It contains 3 levels: F49 (PO), F4A (PRs), F4B (APs) 
@author natalia.khozyainova
@since 24/07/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Local oModel    as Object
Local oView 	as Object
Local oStrF49 	as Object
Local oStrF4A 	as Object
Local oStrF4B 	as Object
Local cFilName  as Object
Local oStrAllBills as Object
Local cBoxName as Character
Local nOper     as Numeric

oModel := FWLoadModel("RU06D05")
cFilName:=RetTitle("F49_FILIAL")
cBoxName:=RetTitle("F4B_RATUSR")
nOper := oModel:GetOperation()

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetAfterViewActivate({|oView| RU06D0515_Brw(oView) })

// Header structure - F49 Payment Request - Header
oStrF49 := FWFormStruct(2, "F49")
oStrF49:RemoveField("F49_IDF49")
oStrF49:RemoveField("F49_VRSN")
oStrF49:RemoveField("F49_F5QUID")
oStrF49:AddField("F49_FILIAL", "01", cFilName, "VirtFilial", nil, "GET", "@!", {|| xFilial('F49')}, "     ", .F., "1","005" ,,0 ,"              " , .F., ,.F. ,0,.F.,"             " ) 
oView:AddField("RU06D05_VHEAD", oStrF49, "RU06D05_MF49")

// Items structure - F4A Payment Requests
oStrF4A := FWFormStruct(2, "F4A")
oStrF4A:RemoveField("F4A_IDF4A")
oStrF4A:RemoveField("F4A_IDF49")
oView:AddGrid("RU06D05_VLNS", oStrF4A, "RU06D05_MF4A" )
oView:SetViewProperty("RU06D05_VLNS", "GRIDDOUBLECLICK", {{|oFormula, cFieldName, nLineGrid, nLineModel | RU06D0524_PR2Click(oFormula, cFieldName, nLineGrid, nLineModel )}})

// Items structure - F4B Payment Requests - Lines
oStrF4B := FWFormStruct(2, "F4B")
oStrF4B:RemoveField("F4B_IDF4A")
oStrF4B:RemoveField("F4B_IDF49")
oStrF4B:RemoveField("F4B_RATUSR")
oStrF4B:RemoveField("F4B_UUID")
oStrF4B:AddField("F4B_CHECK", "01", cBoxName, "CheckBox", {}, "L", "", , "", .T., "","" , , , , .T., , , ) 
oView:AddGrid("RU06D05_VGLNS", oStrF4B, "RU06D05_MF4B" )
oView:SetViewProperty("RU06D05_VGLNS","OnlyView")
oView:SetViewProperty("RU06D05_VGLNS", "GRIDDOUBLECLICK", {{|oFormula, cFieldName, nLineGrid, nLineModel | RU06D0538_AP2Click(oFormula, cFieldName, nLineGrid, nLineModel )}})
oView:SetViewProperty("RU06D05_VGLNS", "GRIDSEEK", {.T.})

// Virtual grid for all bills to show only
oStrAllBills := RU06D0527_DefVirtViewStr()
oView:AddGrid("RU06D05_VVIRT", oStrAllBills, "RU06D05_MVIRT" )
oView:SetViewProperty("RU06D05_VVIRT","OnlyView")
oView:SetViewProperty("RU06D05_VVIRT", "GRIDDOUBLECLICK", {{|oFormula, cFieldName, nLineGrid, nLineModel | RU06D0538_AP2Click(oFormula, cFieldName, nLineGrid, nLineModel )}})

oView:CreateHorizontalBox('SUPERIOR', 100)
oView:CreateFolder('FOLDER1', 'SUPERIOR')
oView:AddSheet('FOLDER1', 'Sheet1', STR0061)	//General
oView:AddSheet('FOLDER1', 'Sheet2', STR0062)	//Requests 

oView:CreateHorizontalBox("F49POHEAD",60/*%*/,,,'FOLDER1','Sheet1')
oView:CreateHorizontalBox("F49POBILLS",40/*%*/,,,'FOLDER1','Sheet1')
oView:CreateHorizontalBox("F4AREQS",60/*%*/,,,'FOLDER1','Sheet2')
oView:CreateHorizontalBox("F4BBILLS",40/*%*/,,,'FOLDER1','Sheet2')

oView:SetOwnerView("RU06D05_VHEAD", "F49POHEAD")
oView:SetOwnerView("RU06D05_VVIRT", "F49POBILLS")
oView:SetOwnerView("RU06D05_VLNS", "F4AREQS")
oView:SetOwnerView('RU06D05_VGLNS','F4BBILLS')
oView:SetCloseOnOk({|| .T. })

oView:AddUserButton(STR0036, '', {|| RU06D0517_AddReqs()    },,,{MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE})   //Pick Up PRs
oView:AddUserButton(STR0037, '', {|| RU06D0532_RecalcTotls()},,,{MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE})   //Recalc Total Values

if nOper == 3
    oView:ShowUpdateMsg(.T.)    
    oView:ShowInsertMessage(.F.)
EndIf 

Return (oView)


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06D0510_Act
all actions, called from Main Menu
@author natalia.khozyainova
@since 24/07/2018
@version P12.1.21
@type function
/*/
Function RU06D0510_Act(nOperation as Numeric, nOrdrTyp as Numeric)
Local aArea     as Array
Local lRet      as Logical
Local cOper     as Character 
Local cReques   as Character
Local cStatus as Character

Default nOperation := MODEL_OPERATION_INSERT
Default nOrdrTyp:=2 // 1 == from request; 2= manualy created

lRet:=.T.
aArea:=GetArea()
cReques:=F49->F49_REQUES
cStatus:=F49->F49_STATUS


If (nOperation == MODEL_OPERATION_INSERT)
    If nOrdrTyp == 1
        cOper:= STR0008 // create from requests
        FWExecView(cOper,"RU06D05",nOperation,,{|| .T.})
    EndIf

    If nOrdrTyp == 2
        cOper:= STR0009 // create manually
//      FWExecView(cOper,"RU06D06",nOperation,,{|| .T.})
        MsgInfo('Not Developed yet')
    EndIf
EndIf

If nOperation == MODEL_OPERATION_DELETE
    If cReques =='1'
        If cStatus=='4' // Paid
            Help("",1,STR0001,,STR0086,1,0,,,,,,) // This PO is paid, it can not be deleted
        Else
            cOper:= STR0011 // Delete (from requests) 
            FWExecView(cOper,"RU06D05",nOperation,,{|| .T.})
        EndIf
    Else
        cOper:= STR0011 // Delete (manually)
        MsgInfo('Not Developed yet')
//      FWExecView(cOper,"RU06D06",nOperation,,{|| .T.})
    EndIf
EndIf

If nOperation == MODEL_OPERATION_UPDATE
    If cReques =="1"
        cOper:= STR0010 // Edit (from request)
        If cStatus=="2" .or. cStatus=="4"
            If MsgNoYes(STR0091, STR0092) // Edition is not available for this PO Open for View? -- Open for View
                FWExecView(STR0007,"RU06D05",MODEL_OPERATION_VIEW,,{|| .T.}) 
            EndIf
        Else
            FWExecView(cOper,"RU06D05",nOperation,,{|| .T.})
        EndIf
    Else
        cOper:= STR0010 // Edit (manually)
        MsgInfo('Not Developed yet')
//      FWExecView(cOper,"RU06D06",nOperation,,{|| .T.})
    EndIf

EndIf
    
If nOperation == MODEL_OPERATION_VIEW
    If cReques =='1'
        cOper:= STR0007 // View (from request)
        FWExecView(cOper,"RU06D05",nOperation,,{|| .T.})
    Else
        cOper:= STR0007 // View (manually) 
        MsgInfo('Not Developed yet')
//      FWExecView(cOper,"RU06D06",nOperation,,{|| .T.})
    EndIf
EndIf

If nOperation == 9 // Copy
    cOper:= STR0013 // Copy 
    FWExecView(cOper,"RU06D05",nOperation,,{|| .T.})
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0511_Legend
this function will show list of colours used for legend (status). See Browse:AddLegend()
@author natalia.khozyainova
@since 24/07/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0511_Legend()
Local aRet as Array
aRet:={}
aAdd(aRet,{ "BR_BRANCO"  , STR0003 }) // White == Created
aAdd(aRet,{ "BR_AMARELO" , STR0004}) // Yellow == Included in PO
aAdd(aRet,{ "BR_VERMELHO", STR0005 }) // Red == Rejected
aAdd(aRet,{ "BR_VERDE"   , STR0006 }) // Green == Payed

BrwLegenda(cCadastro,STR0014, aRet) // Legend 
Return (aRet)


/*/{Protheus.doc} RU06D0501_InitPayOrd
This function is to set initial value to Payment Order Number
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0501_InitPayOrd()
Local cNum as Character

cNum:=RU09D03NMB("PAYORD")
while Right(Alltrim(cNum),3)='000'
    cNum:=RU09D03NMB("PAYORD")
EndDo

Return (cNum)

Function RU06D0502_VldBnkOrd(cFldName)
Local lRet as Logical
Local lNoEndZeros as Logical
Local lNoLetters as Logical

Default cFldName:="F49_BNKORD"
lNoEndZeros := Right(Alltrim(FwFldGet(cFldName)), 3) != '000'
lNoLetters  := RU99XFUN08_IsInteger(FwFldGet(cFldName))

lRet:=(lNoEndZeros .and. lNoLetters)
if !lRet
    Help("",1,STR0063,,STR0064,1,0,,,,,,{STR0065}) // Bank Number is not allowed -- Can not end with 000 -- Change the number
EndIf

Return (lRet)

/*/
{Protheus.doc} RU06D0503_VldSupp()
Supplier code and unit validation
@author natalia.khozyainova
@since 31/07/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0503_VldSupp(nField)
// 1 = Supp, 2=Unit
Local lRet as Logical
Local aSaveArea as Array
Default nField := 1

aSaveArea := GetArea()
If nField == 1
    lRet:= ExistCpo("SA2",FwFldGet("F49_SUPP"))
Else
    lRet:= ExistCpo("SA2",FwFldGet("F49_SUPP")+FwFldGet("F49_UNIT"))
Endif
RestArea(aSaveArea)

Return (lRet)


/*/{Protheus.doc} RU06D0504_VldFil
is called from x3_valid of F49_BNKREC(1), F49_RECBIK(3),F49_RECACC(4)
@author eduardo.flima
@since 13/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0504_VldFil()
Local lRet as Logical
Local aFields as Array

aFields:={"F49_TYPCC","F49_BKRNAM","F49_ACRNAM","","F49_RECNAM"}
lRet:=RU06XFUN04_VldFIL(FwFldGet("F49_SUPP"), FwFldGet("F49_UNIT"), FwFldGet("F49_CURREN"), FwFldGet("F49_BNKREC"), FwFldGet("F49_RECBIK"), FwFldGet("F49_RECACC"), aFields)
Return (lRet)


/*/{Protheus.doc} RU06D0505_ShwFil
is called from x3_relacao: 
// nNum==1 -> F49_TYPCC ; nNum==2 -> F49_ACRNAM
@author natalia.khozyainova
@since 12/11/2018
@version 2.0
@project MA3 - Russia
/*/
Function RU06D0505_ShwFil(nNum)
Local cRet as Character 
cRet:=RU06XFUN02_ShwFIL(nNum, FwFldGet("F49_SUPP"), FwFldGet("F49_UNIT"), FwFldGet("F49_BNKREC"), FwFldGet("F49_RECBIK"), FwFldGet("F49_RECACC"))
Return cRet


/*/
{Protheus.doc} RU06D0506_VldCur()
Currency validation
@author natalia.khozyainova
@since 30/07/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0506_VldCur()
Local lRet      as Logical
Local oModel    as Object
Local oModelF4A as Object
Local nX        as Numeric
Local nSize     as Numeric
Local cCurrF47 as Character

lRet:=.F.
lRet:= ExistCpo("CTO",FwFldGet("F49_CURREN"))

oModel := FWModelActive()
oModelF4A := oModel:GetModel("RU06D05_MF4A")
nSize:=oModelF4A:Length()
cCurrF47:=""

For nX := 1 To nSize
    oModelF4A:GoLine(nX)
    if !(oModelF4A:IsDeleted()) .and. lRet
        cCurrF47:=POSICIONE("F47",1,oModelF4A:GetValue("F4A_FILREQ")+oModelF4A:GetValue("F4A_CODREQ"),"F47_CURREN")
        If (Alltrim(cCurrF47)!="" ) .AND. (cCurrF47 != FwFldGet("F49_CURREN"))
            lRet:=.F.
        Endif
    EndIf
Next nX

If (lRet)
    FwFldPut("F49_CURNAM",POSICIONE("CTO",1,xFilial("CTO")+FwFldGet("F49_CURREN"),"CTO_DESC"),,,,.T.)
    RU06D0528_PutFil() // fills in fields connected to FIL table: BNKREC, RECBIC, RECACC
    RU06D0537_PutSA6() // fills in fields connected to SA6 table: BNKPAY, PAYBIC, PAYACC
Else
    Help("",1,STR0051,,STR0050,1,0,,,,,,{STR0052}) // Currency mismatch between PO header and payment requests included-- Currency --Delete payment requests attached
EndIf

Return(lRet)

/*/
{Protheus.doc} RU06D0508_VldSa6()
Payer bank account etc
@author natalia.khozyainova
@since 30/07/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0508_VldSa6()
Local lRet as Logical
Local aArray as Array

aArray:={"F49_BKPNAM","F49_ACPNAM","F49_PAYNAM"}
lRet:=RU06XFUN05_VldSA6(FwFldGet("F49_CURREN"), FwFldGet("F49_BNKPAY"), FwFldGet("F49_PAYBIK"), FwFldGet("F49_PAYACC"), aArray)
Return (lRet)


/*/
{Protheus.doc} RU06D0509_ShwSa6()
Banc and account name of payer - virtual fields initializer 
nNum==1 -> F49_BKPNAM;  nNum==2 -> F49_ACPNAM
@author natalia.khozyainova
@since 17/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0509_ShwSa6(nNum)
Local cRet as Character 
cRet := RU06XFUN03_ShwSA6(nNum, FwFldGet("F49_BNKPAY"), FwFldGet("F49_PAYBIK"),  FwFldGet("F49_PAYACC"))
Return (cRet)


/*/{Protheus.doc} RU06D0537_PutSA6
Function Used to Automaticly Put the SA6 table data 
this function is called after currency validation
@author natalia.khozyainova
@since 23/08/2018
@version 1.0
@project MA3 - Russia
/*/

Static Function RU06D0537_PutSA6()
Local lRet as Logical
Local aSaveArea as Array
Local lOk as Logical 
Local nCurr as Numeric
Local cKey as Character

lOk := .F. 
aSaveArea := GetArea()

If RU06D0541_CheckSA6(xFilial("SA6"), FwFldGet("F49_BNKPAY"), FwFldGet("F49_PAYBIK"), FwFldGet("F49_PAYACC"), str(val(FwFldGet("F49_CURREN"))))
    cKey:=xFilial("SA6")
    dbSelectArea("SA6")
    SA6->(DbSetOrder(1))
    If (SA6->(DbSeek(cKey,.T.)))
        nCurr := Val(FwFldGet("F49_CURREN")) 
        While (SA6->(!EOF())) .and. (SA6->A6_FILIAL == cKey) .and. !lOk 
            If SA6->A6_MOEDA == nCurr
                FwFldPut("F49_BNKPAY",SA6->A6_COD,,,,.T.)
                FwFldPut("F49_PAYBIK",SA6->A6_AGENCIA,,,,.T.)
                FwFldPut("F49_PAYACC",SA6->A6_NUMCON,,,,.T.)
                FwFldPut("F49_BKPNAM",SA6->A6_NOME,,,,.T.)
                FwFldPut("F49_ACPNAM",SA6->A6_ACNAME,,,,.T.)
                FwFldPut("F49_PAYNAM",ALLTRIM(SA6->A6_NAMECOR),,,,.T.)
                lOk:=.T.
            EndIf
            SA6->(DbSkip())
        Enddo        
        If !lOk //Clear  the data 
            aFields:={"F49_BNKPAY","F49_PAYBIK","F49_PAYACC","F49_PAYNAM","F49_ACPNAM","F49_BKPNAM"}
            RU06XFUN01_CleanFlds(aFields) // Load "" (empty) value to each field from the array
        EndIf
    Else
        aFields:={"F49_BNKPAY","F49_PAYBIK","F49_PAYACC","F49_PAYNAM","F49_ACPNAM", "F49_BKPNAM"}
        RU06XFUN01_CleanFlds(aFields) // Load "" (empty) value to each field from the array
    EndIf
Endif     
RestArea(aSaveArea)
Return (lRet)


/*/{Protheus.doc} RU06D0541_CheckSA6
Function Used to check If we need to replace FIL table data 
@author Eduardo.Flima
@since 23/05/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0541_CheckSA6(cFll, cBnkCod, cBik, cAccnt, cCurr)
Local lRet as Logical
Local aSaveArea as Array
Local cQuery as Character

Default cFll:=XFILIAL("SA6")
Default cBnkCod:=FwFldGet("F49_BNKPAY")
Default cBik:=FwFldGet("F49_PAYBIK")
Default cAccnt:=FwFldGet("F49_PAYACC")
Default cCurr:=str(val(FwFldGet("F49_CURREN")))

cQuery := ""
aSaveArea := GetArea()

cQuery := "SELECT * FROM " + RetSQlName("SA6") + " SA6 " + chr(13) + chr(10)
cQuery += "WHERE A6_FILIAL = '" + cFll + "' " + chr(13) + chr(10)
cQuery += " AND A6_COD = '" + cBnkCod + "' " + chr(13) + chr(10)
cQuery += " AND A6_AGENCIA = '" + cBik + "' " + chr(13) + chr(10)
cQuery += " AND A6_NUMCON = '" + cAccnt + "' " + chr(13) + chr(10)
cQuery += " AND A6_MOEDA = " + cCurr + chr(13) + chr(10)
cQuery += " AND SA6.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery) 

If select("CHKSA6") > 0
    CHKFIL->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "CHKSA6", .T., .F.)
dbSelectArea("CHKSA6")
lRet := CHKSA6->(Eof())
CHKSA6->(DbCloseArea())
RestArea(aSaveArea)

Return (lRet)

/*/
{Protheus.doc} RU06D0507_VldPrePay()
validation for field F49_PREPAY
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0507_VldPrePay()
Local lRet as Logical
Local oModel as Object
Local oModelVirt as Object
Local nQtyAPs as Numeric

lRet:=Pertence("12")
oModel:=FwModelActive()
oModelVirt:=oModel:GetModel("RU06D05_MVIRT")
nQtyAPs:=0

if !(RU06D0544_EmptyModel(oModelVirt, "B_NUM")) .and. FwFldGet("F49_PREPAY")=='1' .and. lRet
    lRet:=.F.
    Help("",1,STR0066,,STR0067,1,0,,,,,,{STR0068}) //Prepayment parameter -- Order for repayment can not include APs -- Change to not prepayment to add any PRs with APs
EndIf

Return (lRet)

/*/
{Protheus.doc} RU06D0512_InitOrdType()
MsgDialog - small scrin to initialize type of order by user selection from combobox
@author natalia.khozyainova
@since 17/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0512_InitOrdType()
Local aArea     as Array
Local aPayTypes as Array
Local cPayType  as Char
Local oDlg      as Object 
Local oCbx      as Object
Local nOpca     as Numeric 

aArea := GetArea()
nOpca := 1
cPayType :=''

If !isBlind() .AND. !FwIsInCallStack('RU06T0290_GenPayOrd') // this if is for automated test or other auto mode
    aPayTypes:= {} 
    AADD(aPayTypes, STR0019) //1-payments to a supplier
    AADD(aPayTypes, STR0020) //2-return to a customer
    AADD(aPayTypes, STR0021) //3-payment to the budget 
    AADD(aPayTypes, STR0022) //4-payment to the employee 
    AADD(aPayTypes, STR0023) //5-payment to an accountable person 
    AADD(aPayTypes, STR0024) //6-transfer between bank accounts
    AADD(aPayTypes, STR0025) //7-other

    DEFINE MSDIALOG oDlg FROM  94,1 TO 273,293 TITLE RetTitle("F49_PAYTYP") PIXEL 
    @ 10,17 Say RetTitle("F49_PAYTYP") SIZE 150,7 OF oDlg PIXEL
    @ 27,07 TO 72, 140 OF oDlg  PIXEL
    @ 35, 10 COMBOBOX oCbx VAR cPayType ITEMS aPayTypes SIZE 120, 27 OF oDlg PIXEL
    DEFINE SBUTTON FROM 75,085 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, RUD604DOK(cPayType, @oDlg))
    DEFINE SBUTTON FROM 75,115 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, RUD604DCnc(@cPayType, @oDlg))
    ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)    
Else                                                       
    cPayType := '1'
Endif   
cPayType := LEFT(cPayType,1) 
RestArea(aArea)
Return (cPayType)


/*/
{Protheus.doc} RU06D0514_FillVirtFilial()
sets virtual field of filial value 
@author natalia.khozyainova
@since 17/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0514_FillVirtFilial(oModel)
Local oView as Object
Local nOperation as Numeric

oView	:= FWViewActive()
nOperation:=oModel:GetOperation()

if nOperation != 5
    oModel:GetModel("RU06D05_MF49"):LoadValue("F49_FILIAL",xFilial("F49"))
    oModel:GetModel("RU06D05_MF49"):LoadValue("F49_REQUES","1")
    oView:Refresh()  
EndIf

Return (nil)


/*/
{Protheus.doc} RU06D0514_FillVirtFilial()
function to be executed after view activate - it is needed to close Msdialog and to set some fields value
@author natalia.khozyainova
@since 17/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0515_Brw(oView)
Local lRet as Logical 
Local oModel as Object

lRet := !(FwFldGet("F49_PAYTYP") == '0' )
oModel:=oView:GetModel()

If !lRet
    oView:lModify := .F. 
    oView:BUTTONCANCELACTION()
Else
    RU06D0514_FillVirtFilial(oModel)
    if oModel:IsCopy()
        RU06D0536_POReason(0,'',.T.)
    EndIf
Endif 

Return (lRet)


/*/
{Protheus.doc} RU06D0516_Status()
This function is temporary - until we develop the real rules to update statuses after operations
@author natalia.khozyainova
@since 17/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0516_Status()
Local nRet as Numeric
Local aBtns as Array
Local aArea as Array
Local oModelPO as Object

nRet:=0
aBtns:={"2=Sent to Bank","3=Rejected","4=Paid","Cancel"}
nRet:=AVISO("Change Status","Select status",aBtns,3)

aArea := GetArea()	
 // update or create
If nRet>0 .and. nRet<4  
    if ALLTRIM(DTOS(F49->F49_DTACTP))!='' .or. nRet!=3 
        dbSelectArea("F49")
        F49->(DbSetOrder(1))
        If F49->(DbSeek(F49->F49_FILIAL+F49->F49_PAYORD+F49->F49_BNKORD+DTOS(F49->F49_DTPAYM)))
            oModelPO:= FwLoadModel("RU06D05")
            oModelPO:SetOperation(4)
            oModelPO:Activate()
            oModelPO:GetModel("RU06D05_MF49"):SetValue("F49_STATUS", alltrim(str(nRet+1)))
            oModelPO:VldData() 
            oModelPO:CommitData()
            oModelPO:DeActivate()
        EndIf

    Else
        Help("",1,STR0069,,STR0070,1,0,,,,,,{STR0071}) //Status update is not allowed -- Date of actual payment is not specified --  Specify date of actual payment
    EndIf
EndIf

RestArea(aArea)

Return NIL 



/*/
{Protheus.doc} RU06D0517_AddReqs()
Called from user button - Pick up Payment Requests
@author natalia.khozyainova
@since 17/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0517_AddReqs()
Local oModel as Object
Local lCurrCor as Logical

if !(Empty(FwFldGet("F49_SUPP"))) .and. (ExistCpo("SA2",FwFldGet("F49_SUPP") + FwFldGet("F49_UNIT")))
    oModel:= FWModelActive()
    cPerg := "RUD605"
    
    // Update initial Ranges in Group of Questions:
    If !Empty(FwFldGet("F49_CURREN"))
        SetMVValue(cPerg,"MV_PAR09",FwFldGet("F49_CURREN"))
    EndIf

    If !Empty(FwFldGet("F49_FILREQ"))
        SetMVValue(cPerg,"MV_PAR10",FwFldGet("F49_FILREQ"))
    Else
        SetMVValue(cPerg,"MV_PAR10",xFilial("F49"))
    EndIf

    If Empty(FwFldGet("F49_CNT"))
        SetMVValue(cPerg,"MV_PAR07",Replicate(" ",TamSX3("F49_CNT")[1]))
        SetMVValue(cPerg,"MV_PAR08",Replicate("Z",TamSX3("F49_CNT")[1]))
    Else
        SetMVValue(cPerg,"MV_PAR07",oModel:GetValue('RU06D05_MF49','F49_CNT'))
        SetMVValue(cPerg,"MV_PAR08",oModel:GetValue('RU06D05_MF49','F49_CNT'))
    Endif

    If Empty(FwFldGet("F49_CLASS"))
        SetMVValue(cPerg,"MV_PAR05",Replicate(" ",TamSX3("F49_CLASS")[1]))
        SetMVValue(cPerg,"MV_PAR06",Replicate("Z",TamSX3("F49_CLASS")[1]))
    Else
        SetMVValue(cPerg,"MV_PAR05",oModel:GetValue('RU06D05_MF49','F49_CLASS'))
        SetMVValue(cPerg,"MV_PAR06",oModel:GetValue('RU06D05_MF49','F49_CLASS'))
    Endif

    lRet:= Pergunte(cPerg,.T.,STR0040,.F.) // Group of questions

    lCurrCor := RU06D0547_CheckCurrency(MV_PAR09, oModel)
    If (!empty(oModel:GetValue("RU06D05_MF49","F49_FILREQ")) .and. oModel:GetValue("RU06D05_MF49","F49_FILREQ") != MV_PAR10) .or. oModel:GetValue("RU06D05_MF49","F49_CURREN") != MV_PAR09
        While lRet .and. ((!empty(oModel:GetValue("RU06D05_MF49","F49_FILREQ")) .and. oModel:GetValue("RU06D05_MF49","F49_FILREQ") != MV_PAR10 ) .or. !lCurrCor)
            If !empty(oModel:GetValue("RU06D05_MF49","F49_FILREQ")) .and. oModel:GetValue("RU06D05_MF49","F49_FILREQ") != MV_PAR10 
                Help("",1,STR0087,,STR0088,1,0,,,,,,{STR0089}) //It is not allowed to select two payment requests from different branches -- Branch --  Choose the same Branch    
            ElseIf !lCurrCor
                Help("",1,STR0094,,STR0095,1,0,,,,,,{STR0096}) //It is not allowed to select payment requests in different currency -- Uncorrect currency --  Either it should delete included payments requests or it should select in the payment order currency
            EndIf
            lRet:= Pergunte(cPerg,.T.,STR0040,.F.) // Group of questions
            lCurrCor := RU06D0547_CheckCurrency(MV_PAR09, oModel)
        Enddo        
    Endif
    If lRet
        RU06D0518_MBrowse() // MarkBrowse is here
    Endif

Else
    Help("",1,STR0041,,STR0042,1,0,,,,,,{STR0043}) //Supplier field is empty -- Supplier --  Specify code and unit of supp
EndIf

Return (Nil)

/*/
{Protheus.doc} RU06D0518_MBrowse()
Markbrowse to select PRs 
@author natalia.khozyainova
@since 17/08/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RU06D0518_MBrowse()
Local aSize     as Array
Local aStr      as Array // Structure to show
Local aColumns  as Array
Local nX        as Numeric 
Local cTitle    as Character

Private oMoreDlg    as Object
Private oBrowsePut  as Object
Private oTempTable  as Object
Private cTempTbl    as Character
Private cMark       as Character

aSize	:= MsAdvSize()
nX:=0
cTempTbl	:= CriaTrab(,.F.)
aStr	:= {}
aColumns 	:= {}
cTitle:=""

// Create temporary table
MsgRun(STR0026,STR0027,{|| RU06D0519_CreateTable()}) //"Please wait"//"Creating temporary table"

iF ((cTempTbl)->(Eof()))
    Help("",1,STR0044,,STR0036,1,0,,,,,,{STR0045}) // No requests found -- Pick Up PRs --Please, check parameters of the request 
Else
    aAdd( aStr, {"F47_FILIAL"	,RetTitle("F47_FILIAL") , PesqPict("F47","F47_FILIAL")})
    aAdd( aStr, {"F47_CODREQ"	,RetTitle("F47_CODREQ") , PesqPict("F47","F47_CODREQ")})
    aAdd( aStr, {"F47_DTPLAN"	,RetTitle("F47_DTPLAN") , PesqPict("F47","F47_DTPLAN")})
    aAdd( aStr, {"F47_PREPAY"	,RetTitle("F47_PREPAY") , PesqPict("F47","F47_PREPAY")})
    aAdd( aStr, {"F47_BNKCOD"	,RetTitle("F47_BNKCOD") , PesqPict("F47","F47_BNKCOD")})
    aAdd( aStr, {"F47_CNT"	    ,RetTitle("F47_CNT")    , PesqPict("F47","F47_CNT")})
    aAdd( aStr, {"F47_CLASS"	,RetTitle("F47_CLASS")  , PesqPict("F47","F47_CLASS")})
    aAdd( aStr, {"F47_CURREN"	,RetTitle("F47_CURREN") , PesqPict("F47","F47_CURREN")})
    aAdd( aStr, {"F47_VALUE"	,RetTitle("F47_VALUE")  , PesqPict("F47","F47_VALUE")})
    aAdd( aStr, {"F47_VRSN" 	,RetTitle("F47_REASON") , "@"})
    aAdd( aStr, {"F47_PAYORD"	,RetTitle("F47_PAYORD") , PesqPict("F47","F47_PAYORD")})
    aAdd( aStr, {"F49_DTPAYM"	,RetTitle("F49_DTPAYM") , PesqPict("F49","F49_DTPAYM")})

    For nX := 1 TO  11
        cTitle:=aStr[nX][1]
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||"+aStr[nX][1]+"}") )
        aColumns[Len(aColumns)]:SetTitle(aStr[nX][2]) 

        if cTitle!="F47_VRSN"
            aColumns[Len(aColumns)]:SetSize(TamSx3(cTitle)[1]) 
            aColumns[Len(aColumns)]:SetDecimal(TamSx3(cTitle)[2])
        Else
            aColumns[Len(aColumns)]:SetSize(40) 
            aColumns[Len(aColumns)]:SetDecimal(0)
        EndIf
        aColumns[Len(aColumns)]:SetPicture(aStr[nX][3]) 

    Next nX

    oMoreDlg := MsDialog():New( aSize[7], aSize[2], aSize[6], aSize[5], STR0046, , , , , CLR_BLACK, CLR_WHITE, , , .T., , , , .T.) // Payment Requests available

    //MarkBrowse
    oBrowsePut := FWMarkBrowse():New()
    oBrowsePut:SetFieldMark("F47_OK")
    oBrowsePut:SetOwner(oMoreDlg)
    oBrowsePut:SetAlias(cTempTbl)
    aRotina	 := RU06D0520_MBrowseMenu() //Reset global aRotina
    oBrowsePut:SetColumns(aColumns)
    oBrowsePut:bAllMark := {||RU06D0535_MarkAll(oBrowsePut, cTempTbl)}

    oBrowsePut:DisableReport()
    oBrowsePut:Activate()
    cMark := oBrowsePut:Mark()
 
    oMoreDlg:Activate(,,,.T.,,,)

    If !Empty (cTempTbl)
        dbSelectArea(cTempTbl)
        dbCloseArea()
        cTempTbl := ""
        dbSelectArea("F47")
        dbSetOrder(1)
    EndIf

    If oTempTable <> Nil
        oTempTable:Delete()
        oTempTable := Nil
    Endif
eNDIF 
aRotina	 := MenuDef() //Return aRotina
return (.T.)

/*/
{Protheus.doc} RU06D0519_CreateTable()
temporary table for markbrowse
@author natalia.khozyainova
@since 17/08/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RU06D0519_CreateTable()
Local aFields   as Array
Local aColNames as Array
local cQuery    as Character
Local cQueryIns as Character
local cQueryDel as Character
Local oModel    as Object
Local oModelF49 as Object
Local oModelF4A as Object
Local cSupp     as Character
Local cUnit     as Character
Local cCurr     as Character
Local cPrePay   as Character
Local cContract as Character
Local cTabName  as Character
Local nX        as Numeric
Local nStatus   as Numeric
Local cErrMsg   as Character
Local cVrsn     as Character
Local cDtPaym   as Character

oModel:=FWModelActive()
oModelF49:=oModel:GetModel("RU06D05_MF49")
oModelF4A:=oModel:GetModel("RU06D05_MF4A")
cSupp:=oModelF49:GetValue("F49_SUPP")
cUnit:=oModelF49:GetValue("F49_UNIT")
cCurr:=oModelF49:GetValue("F49_CURREN")
cPrePay:=oModelF49:GetValue("F49_PREPAY")
cContract:=oModelF49:GetValue("F49_CNT")
cVrsn := "'" + Space(TamSX3("F47_VRSN")[1]) + "'" 
cDtPaym := "'" + Space(TamSX3("F49_DTPAYM")[1]) + "'" 

aFields := {}
aadd(aFields, {"F47_OK", "C", 1, 0})
aColNames := {"F47_FILIAL", "F47_CODREQ", "F47_DTPLAN", "F47_PREPAY", "F47_BNKCOD", "F47_CNT", "F47_CLASS",;
"F47_VALUE",  "F47_VRSN", "F47_PAYORD", "F49_DTPAYM", "F47_IDF47", "F47_CURREN"}
RU99XFUN10_AppendFields(aFields, aColNames, 0)

oTempTable := FWTemporaryTable():New(cTempTbl)
oTemptable:SetFields(aFields)
oTempTable:AddIndex("Indice1", {"F47_DTPLAN","F47_FILIAL","F47_CODREQ"} )
oTempTable:Create()
cTabName := oTempTable:GetRealName()

// Selection part of insertion query
cQuery := " SELECT DISTINCT '0' AS F47_OK, F47_FILIAL, F47_CODREQ, F47_DTPLAN, F47_PREPAY, F47_BNKCOD, F47_CNT,"
cQuery += " F47_CLASS, F47_VALUE, " + cVrsn + " AS F47_VRSN, F47_PAYORD, " + cDtPaym + " AS F49_DTPAYM, F47_IDF47, F47_CURREN "
cQuery += " FROM " + RetSQLName("F47") + " F47 "
cQuery += " LEFT JOIN " + RetSQLName("F4A") + " F4A ON F4A_FILIAL=F47_FILIAL AND F4A_CODREQ=F47_CODREQ AND F4A.D_E_L_E_T_=' ' "
cQuery += " LEFT JOIN " + RetSQLName("F49") + " F49 ON F49_FILIAL=F4A_FILIAL AND F49_IDF49=F4A_IDF49 AND F49.D_E_L_E_T_=' ' "
cQuery += " LEFT JOIN " + RetSQLName("F5M") + " F5M ON F5M_KEY = F47_IDF47 AND F5M_KEYALI = 'F47' AND F5M.D_E_L_E_T_ = ' ' " // this is a connection to the list of payments F60
cQuery += " LEFT JOIN " + RetSQLName("F60") + " F60 ON F5M_IDDOC = F60_IDF60 AND F5M_ALIAS = 'F60'  AND F60.D_E_L_E_T_ = ' ' "// One entry in F60 matches several entries in F5M
cQuery += " WHERE (F49_IDF49 IS NULL OR F49_DTPAYM <= '" + DTOS(Date()-10) +"' ) "
cQuery += " AND F47.D_E_L_E_T_ =' ' "
cQuery += " AND F47_FILIAL ='" +  MV_PAR10  + "'"
cQuery += " AND F47_SUPP  = '" +  cSupp  + "'"
cQuery += " AND F47_UNIT  = '" +  cUnit  + "'"
cQuery += " AND F47_CURREN = '"+  MV_PAR09  + "'"
cQuery += " AND F47_CLASS BETWEEN '"+ MV_PAR05 +"' AND '" + MV_PAR06 + "'"
cQuery += " AND F47_CNT BETWEEN '"+ ALLTRIM(MV_PAR07) +"' AND '" + ALLTRIM(MV_PAR08) + "'"
cQuery += " AND F47_PAYTYP='1' "
//calculate the total list of payment valids, should be zero to allow add
cQuery += " AND ((( SELECT COUNT(F601.F60_FILIAL) FROM " + RetSQLName("F5M") + " F5M1 INNER JOIN " + RetSQLName("F60") 
cQuery += " F601 ON F5M1.F5M_IDDOC = F601.F60_IDF60 AND F5M1.F5M_ALIAS = 'F60' AND F601.D_E_L_E_T_ = ' ' WHERE F5M1.D_E_L_E_T_ =''	AND F601.F60_STATUS <> '4' AND F5M1.F5M_KEY = COALESCE(F5M.F5M_KEY, ' ')) <= 0 )"
cQuery += " OR COALESCE(F60.R_E_C_N_O_, -1) = -1 ) "  //This condition does not allow you to select an application for payment, which is included in the list of payments.

If SuperGetMv("MV_REQAPR",, 0)  == 1
    cQuery += " AND F47_STATUS IN ('4') "  //TODO Status '2' was remove ( if we keep it here, is possible add a PR that are already selected in other PO and this PO was not used at BS), this is confirme with Marina 27/07/2020 - 16:23 (Rafael, Eduardo and Marina)
Else        
    cQuery += " AND F47_STATUS IN ('1') "  //TODO Status '2' was remove ( if we keep it here, is possible add a PR that are already selected in other PO and this PO was not used at BS), this is confirme with Marina 27/07/2020 - 16:23 (Rafael, Eduardo and Marina)
EndIf

If cPrePay  == "1"
    cQuery += " AND F47_PREPAY = '1' "
EndIf

cQueryIns := RU99XFUN12_MakeInsertionQueryPart(aFields, cTabName)
cQueryIns += ChangeQuery(cQuery)

cErrMsg := ""
nStatus := TCSqlExec(cQueryIns)
If nStatus < 0
    cErrMsg := TCSQLError()
EndIf

For nX := 1 To oModelF4A:Length()
    oModelF4A:GoLine(nX)
    cQueryDel  := " DELETE FROM " + oTempTable:GetRealName()
    cQueryDel  += " WHERE F47_FILIAL ='" +xFilial("SE2")  + "'"
    cQueryDel  += " AND F47_CODREQ ='" + oModelF4A:GetValue("F4A_CODREQ")  + "'" 
    nStatus := TCSqlExec(cQueryDel)
    If nStatus < 0
        cErrMsg := TCSQLError()
        Exit
    EndIf
Next nX

DbSelectArea(cTempTbl) 
DbGotop()
While (cTempTbl)->(!EOF())  
    (cTempTbl)->F47_VRSN := Posicione("F47",1,xFilial("F47")+(cTempTbl)->F47_CODREQ,"F47_REASON")
    if alltrim((cTempTbl)->F47_PAYORD)!=''
        (cTempTbl)->F49_DTPAYM := RU06D0413_ShwDtPaym((cTempTbl)->F47_PAYORD, (cTempTbl)->F47_CODREQ)
	EndIf
    (cTempTbl)->(DBSkip())
Enddo
DbGotop()
Return (NIL)


/*/
{Protheus.doc} RU06D0520_MBrowseMenu()
Menu for MarkBrowse
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RU06D0520_MBrowseMenu()
Local aRet as Array
aRet := {{STR0028,  "RU06D0521_WriteToModel()",  0, 4, 0, Nil},; //Add
		{STR0029,   "RU06D0522_MBrwCancel()",  0, 1, 0, Nil},; //Cancel
        {STR0030,   "RU06D0523_ShowPR()", 0, 1, 0, Nil}}  //Request Details
Return (aRet)


/*/
{Protheus.doc} RU06D0521_WriteToModel()
called after button Add in Markbrowse - writes PRs and APs to the model
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0521_WriteToModel()
Local aArea         as Array
Local aAreaTmpTbl   as Array
Local oModelH       as Object
Local oModelF4A     as Object
Local oModelF4B     as Object
Local oModelVirt as Object
Local cQuery    as Character
Local cQueryLns as Character
Local cTab      as Character
Local cTabLns   as Character
Local oView     as Object
Local oGridFake as Object
Local oGridF4A as Object
Local oGridF4B as Object
Local nItemF    as Numeric
Local nItemF2    as Numeric
Local cF47ID    as Character
Local oModelPR as Object
Local oModelPO as Object
Local dDateToRecalc as Date
Local nRecalcCurr as Numeric
Local lNPrepay as Logical
Local cKeyF5M As Character

aArea       := GetArea()
oModel      := FwModelActive()		
oModelH     := oModel:GetModel("RU06D05_MF49")
oModelF4A   := oModel:GetModel("RU06D05_MF4A")
oModelF4B   := oModel:GetModel("RU06D05_MF4B")
oModelVirt  := oModel:GetModel("RU06D05_MVIRT")
cF47ID      :=''
lNPrepay    :=.F.
nItemF:=1

aAreaTmpTbl := (cTempTbl)->(GetArea())
DBSetOrder(1)
DBGoTop()

While (cTempTbl)->(!EOF()) .and. !lNPrepay
    lNPrepay:= ((cTempTbl)->F47_OK == cMark) .and. (cTempTbl)->F47_PREPAY =="2"
    (cTempTbl)->(DBSkip())
Enddo
(cTempTbl)->(DbGoTop())
If !isBlind() .and.  oModelH:GetValue("F49_CURREN")=='01' .and. oModelH:GetValue("F49_PREPAY")!='1'.and. lNPrepay .and. RU06D0546_CheckConUni(oTempTable)
    nRecalcCurr:=AVISO(STR0082,STR0083,; // Currency recalculation - Please, be awared: this recalculation will update rates in PR as well. Which date use to recalculate currency? 
    {STR0084,STR0085,"Cancel"},3)
Else
    nRecalcCurr:=3
EndIf

if isBlind()
    nRecalcCurr:=1
EndIf
dDateToRecalc := if( nRecalcCurr == 1 , oModelH:GetValue("F49_DTPAYM"), NIL)

While !((cTempTbl)->(Eof()))
	If ((cTempTbl)->F47_OK == cMark)
        
        oModelF4A:SetNoUpdateLine(.F.)
        If !EMPTY(oModelF4A:GetValue("F4A_DTREQ",oModelF4A:Length())) .or. oModelF4A:IsDeleted()// create new line if the last one is not empty
            oModelF4A:SetNoInsertLine(.F.)
            nItemF := oModelF4A:AddLine()
            oModelF4A:SetNoInsertLine(.T.)            
        Endif
        oModelF4A:GoLine(oModelF4A:Length()) // put cursor on new line

        if oModelH:GetValue("F49_CURREN")=='01'
            if nRecalcCurr==1 .or. nRecalcCurr==2
                oModelPO:=oModel
                dbSelectArea("F47")
                F47->(DbSetOrder(1))
                If F47->(DbSeek((cTempTbl)->F47_FILIAL+(cTempTbl)->F47_CODREQ))
                    oModelPR:= FwLoadModel("RU06D04")
                    oModelPR:SetOperation(4)
                    RU06D0401_RecalcCurrency(.T., @oModelPR, 1, dDateToRecalc )
                    oModel:=oModelPO
                EndIf
            EndIf
        EndIf

		cQuery := "SELECT * FROM " + RetSQLName("F47")
		cQuery += " WHERE F47_FILIAL ='" + (cTempTbl)->F47_FILIAL +"'"
		cQuery += " AND F47_IDF47 ='" + (cTempTbl)->F47_IDF47 +"'"
		cQuery += " AND D_E_L_E_T_ =' '"
		
        cQuery := ChangeQuery(cQuery)
	    cTab := CriaTrab( , .F.)
        TcQuery cQuery New Alias ((cTab))

		DbSelectArea((cTab))
		(cTab)->(DbGoTop())

        If Empty(oModelH:GetValue("F49_FILREQ"))
            F47->(DbSetOrder(1))
            If F47->(DbSeek((cTempTbl)->F47_FILIAL+(cTempTbl)->F47_CODREQ))        
                oModelH:LoadValue("F49_FILREQ",(cTempTbl)->F47_FILIAL)
            Endif               
        Endif 

		oModelF4A:LoadValue("F4A_FILIAL", xFilial ("F4A")) 
        oModelF4A:LoadValue("F4A_IDF4A", (cTab)->F47_IDF47 )
		oModelF4A:LoadValue("F4A_IDF49", oModelH:GetValue("F49_IDF49"))	
		oModelF4A:LoadValue("F4A_CODREQ", (cTab)->F47_CODREQ )	
		oModelF4A:LoadValue("F4A_DTREQ", STOD((cTab)->F47_DTREQ))
		oModelF4A:LoadValue("F4A_PREPAY",(cTab)->F47_PREPAY )
		oModelF4A:LoadValue("F4A_BNKCOD", (cTab)->F47_BNKCOD)	
        oModelF4A:LoadValue("F4A_CNT", (cTab)->F47_CNT)
        oModelF4A:LoadValue("F4A_CLASS", (cTab)->F47_CLASS)
        oModelF4A:LoadValue("F4A_VALUE", (cTab)->F47_VALUE)
        oModelF4A:LoadValue("F4A_VATCOD", (cTab)->F47_VATCOD)
        oModelF4A:LoadValue("F4A_VATRAT", (cTab)->F47_VATRAT)
        oModelF4A:LoadValue("F4A_VATAMT", (cTab)->F47_VATAMT)
        oModelF4A:LoadValue("F4A_REASON", LEFT(alltrim(Posicione("F47",1,(cTab)->F47_FILIAL+(cTab)->F47_CODREQ,"F47_REASON")),210))
        oModelF4A:LoadValue("F4A_FILREQ", (cTab)->F47_FILIAL)
        
        cF47ID:=(cTab)->F47_IDF47

        cQueryLns := "SELECT * FROM " + RetSQLName("F48") + " F48 "
        cQueryLns += " LEFT JOIN "+ RetSQLName("SE2") + " SE2 "
        cQueryLns += " ON (SE2.E2_FILIAL=F48.F48_FLORIG AND SE2.E2_PREFIXO=F48.F48_PREFIX AND SE2.E2_NUM=F48.F48_NUM  "
        cQueryLns += " AND SE2.E2_PARCELA=F48.F48_PARCEL AND SE2.E2_TIPO=F48.F48_TYPE)  "
        cQueryLns += " WHERE F48_FILIAL ='" + MV_PAR10 +"'"
		cQueryLns += " AND F48_IDF48 ='" + cF47ID +"'"
		cQueryLns += " AND F48.D_E_L_E_T_ =' ' AND SE2.D_E_L_E_T_ =' '"
		
        cQueryLns := ChangeQuery(cQueryLns)
	    cTabLns := CriaTrab( , .F.)
        TcQuery cQueryLns New Alias ((cTabLns))
        
        DbSelectArea((cTabLns))
		(cTabLns)->(DbGoTop())
        while !((cTabLns)->(Eof()))
            If !EMPTY(oModelF4B:GetValue("F4B_NUM",oModelF4B:Length())) .or. oModelF4B:IsDeleted() // create new line if the last one is not empty
                oModelF4B:SetNoInsertLine(.F.)
                nItemF2 := oModelF4B:AddLine()
                oModelF4B:SetNoInsertLine(.T.)            
            Endif
            oModelF4B:GoLine(oModelF4B:Length()) // put cursor on new line

            oModelF4B:LoadValue("F4B_FILIAL", xFilial ("F4B")) 
            oModelF4B:LoadValue("F4B_UUID", FWUUIDV4()) 
            oModelF4B:LoadValue("F4B_IDF4A", (cTabLns)->F48_IDF48)
            oModelF4B:LoadValue("F4B_IDF49", oModelH:GetValue("F49_IDF49"))	
            oModelF4B:LoadValue("F4B_PREFIX", (cTabLns)->F48_PREFIX )	
            oModelF4B:LoadValue("F4B_NUM", (cTabLns)->F48_NUM )	
            oModelF4B:LoadValue("F4B_PARCEL",(cTabLns)->F48_PARCEL )
            oModelF4B:LoadValue("F4B_TYPE", (cTabLns)->F48_TYPE)	
            oModelF4B:LoadValue("F4B_CLASS", (cTabLns)->E2_NATUREZ)
            oModelF4B:LoadValue("F4B_EMISS", STOD((cTabLns)->E2_EMISSAO))
            oModelF4B:LoadValue("F4B_REALMT", STOD((cTabLns)->E2_VENCREA))
            oModelF4B:LoadValue("F4B_VALPAY", (cTabLns)->F48_VALREQ)
            oModelF4B:LoadValue("F4B_VALUE", (cTabLns)->E2_VALOR)
            oModelF4B:LoadValue("F4B_CURREN", (cTabLns)->E2_MOEDA)
            oModelF4B:LoadValue("F4B_CONUNI", (cTabLns)->F48_CONUNI)
            oModelF4B:LoadValue("F4B_VLCRUZ", (cTabLns)->E2_VLCRUZ)
                        
            cKeyF5M:=xFilial("SE2")+"|"+(cTabLns)->F48_PREFIX+"|"+;
            (cTabLns)->F48_NUM+"|"+(cTabLns)->F48_PARCEL+"|"+(cTabLns)->F48_TYPE+"|"+;
            (cTab)->F47_SUPP+"|"+(cTab)->F47_UNIT    
            oModelF4B:LoadValue("F4B_OPBAL", RU06XFUN06_GetOpenBalance(cKeyF5M) +;
            Posicione("F5M",1,xFilial("F5M")+"F48"+(cTabLns)->F48_UUID+cKeyF5M,"F5M_VALPAY"))
              
            oModelF4B:LoadValue("F4B_BSIMP1", (cTabLns)->E2_BASIMP1)
            oModelF4B:LoadValue("F4B_ALIMP1", (cTabLns)->E2_ALQIMP1)
            oModelF4B:LoadValue("F4B_VLIMP1", (cTabLns)->F48_VLIMP1)
            oModelF4B:LoadValue("F4B_MDCNTR", (cTabLns)->E2_MDCONTR)
            oModelF4B:LoadValue("F4B_FLORIG", (cTabLns)->F48_FLORIG)

            oModelF4B:LoadValue("F4B_RATUSR", (cTabLns)->F48_RATUSR)
            oModelF4B:LoadValue("F4B_EXGRAT", (cTabLns)->F48_EXGRAT)
            oModelF4B:LoadValue("F4B_CHECK", if((cTabLns)->F48_RATUSR == '1',.T.,.F.))
            oModelF4B:LoadValue("F4B_VALCNV", (cTabLns)->F48_VALCNV)
            oModelF4B:LoadValue("F4B_BSVATC", (cTabLns)->F48_BSVATC)
            oModelF4B:LoadValue("F4B_VLVATC", (cTabLns)->F48_VLVATC)

            (cTabLns)->(DbSkip())
            
        Enddo

        If Empty(oModelH:GetValue("F49_PREPAY")) .or. nItemF==1
            oModelH:SetValue("F49_PREPAY",(cTab)->F47_PREPAY)
        Elseif oModelH:GetValue("F49_PREPAY")=='1' .and. (cTab)->F47_PREPAY=='2'
            oModelH:SetValue("F49_PREPAY",(cTab)->F47_PREPAY)
        EndIf

        If Empty(oModelH:GetValue("F49_CLASS")) 
            oModelH:SetValue("F49_CLASS",(cTab)->F47_CLASS)
        EndIf

        If Empty(oModelH:GetValue("F49_VATRAT"))
            oModelH:SetValue("F49_VATRAT",(cTab)->F47_VATRAT)
        EndIf

        If Empty(oModelH:GetValue("F49_CNT"))
            oModelH:SetValue("F49_CNT",(cTab)->F47_CNT)
        EndIf

        If Empty(oModelH:GetValue("F49_F5QUID"))
            oModelH:SetValue("F49_F5QUID",(cTab)->F47_F5QUID)
        EndIf

        If Empty(oModelH:GetValue("F49_BNKREC"))
            oModelH:SetValue("F49_BNKREC",(cTab)->F47_BNKCOD)
        EndIf

        If Empty(oModelH:GetValue("F49_RECBIK"))
            oModelH:SetValue("F49_RECBIK",(cTab)->F47_BIK)
        EndIf

        If Empty(oModelH:GetValue("F49_RECACC"))
            oModelH:SetValue("F49_RECACC",(cTab)->F47_ACCNT)
        EndIf

        If Empty(oModelH:GetValue("F49_CTPRE"))
            oModelH:SetValue("F49_CTPRE",(cTab)->F47_CTPRE)
        EndIf

        If Empty(oModelH:GetValue("F49_CTPOS"))
            oModelH:SetValue("F49_CTPOS",(cTab)->F47_CTPOS)
        EndIf

        If Empty(oModelH:GetValue("F49_CCPRE"))
            oModelH:SetValue("F49_CCPRE",(cTab)->F47_CCPRE)
        EndIf

        If Empty(oModelH:GetValue("F49_CCPOS"))
            oModelH:SetValue("F49_CCPOS",(cTab)->F47_CCPOS)
        EndIf

        If Empty(oModelH:GetValue("F49_ITPRE"))
            oModelH:SetValue("F49_ITPRE",(cTab)->F47_ITPRE)
        EndIf

        If Empty(oModelH:GetValue("F49_ITPOS"))
            oModelH:SetValue("F49_ITPOS",(cTab)->F47_ITPOS)
        EndIf

         If Empty(oModelH:GetValue("F49_CLPRE"))
            oModelH:SetValue("F49_CLPRE",(cTab)->F47_CLPRE)
        EndIf

        If Empty(oModelH:GetValue("F49_CLPOS"))
            oModelH:SetValue("F49_CLPOS",(cTab)->F47_CLPOS)
        EndIf

        If nItemF==1 .or. Empty(oModelH:GetValue("F49_KPPREC"))
            oModelH:SetValue("F49_KPPREC",(cTab)->F47_KPPREC)
        EndIf

        If oModelH:GetValue("F49_CURREN") <> (cTab)->F47_CURREN
            oModelH:SetValue("F49_CURREN",(cTab)->F47_CURREN)
        EndIf

        RU06D0542_SortF4A(oModelF4A)
	EndIf
	(cTempTbl)->(DbSkip())
Enddo

oModelF4A:SetNoUpdateLine(.T.)
RU06D0543_VrtModel(oModel)
RU06D0531_TOTLS(.T.)
RU06D0536_POReason()
RU06D0545_PutSuppAcc()

oView	:= FWViewActive()
oGridFake:= oView:GetViewObj("RU06D05_VVIRT")[3]
oGridF4A:= oView:GetViewObj("RU06D05_VLNS")[3]
oGridF4B:= oView:GetViewObj("RU06D05_VGLNS")[3]

oGridF4A:Refresh( .T. /* lEvalChanges */, .T. /* lGoTop */)
oGridFake:Refresh( .T. /* lEvalChanges */, .T. /* lGoTop */)
oGridF4B:Refresh( .T. /* lEvalChanges */, .T. /* lGoTop */)

oMoreDlg:End()
RestArea(aArea)

Return (Nil)


/*/
{Protheus.doc} RU06D0522_MBrwCancel()
Close markbrowse dialog when cancel
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0522_MBrwCancel()
oMoreDlg:End()
return .F.

/*/
{Protheus.doc} RU06D0523_ShowPR()
Link from markbrowse to AP
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0523_ShowPR()
Local aArea as Array
Local aAreaF49 as Array
Local cKey as Character

aArea := (cTempTbl)->(GetArea())	
cKey:=(cTempTbl)->F47_FILIAL+(cTempTbl)->F47_CODREQ
RestArea(aArea)

dbSelectArea("F47")
F47->(DbSetOrder(1))
If F47->(DbSeek(cKey))
    FWExecView("View Request details","RU06D04",MODEL_OPERATION_VIEW,,{|| .T.})
EndIf
DbCloseArea()
return Nil



/*/
{Protheus.doc} RU06D0524_PR2Click()
Doubleclick on payment request - link to RU06D04
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RU06D0524_PR2Click(oFormula, cFieldName, nLineGrid, nLineModel)
Local aArea		:= GetArea()
Local aAreaF47	:= Eval({||DbSelectArea("F47"),F47->(GetArea())})
Local oModel as Object
Local oModelF49 as Object
Local oModelF4A as Object
Local lRet as Logical

Default oFormula:=NIL
Default cFieldName:=""
Default nLineGrid:=0
Default nLineModel:=0

lRet:=.T.
oModel:=FwModelActive()
oModelF49:=oModel:GetModel("RU06D05_MF49")
oModelF4A:=oModel:GetModel("RU06D05_MF4A")
IF !(oModelF4A:CanSetValue(cFieldName))
    F47->(DbSetOrder(1))
    If DbSeek(oModelF4A:GetValue("F4A_FILREQ")+oModelF4A:GetValue("F4A_CODREQ"))
        FWExecView("View Request details","RU06D04",MODEL_OPERATION_VIEW,,{|| .T.})
        lRet:=.F.
    EndIf
    RestArea(aAreaF47)
    RestArea(aArea)
EndIf

Return (lRet)



/*/
{Protheus.doc} RU06D0538_AP2Click()
Doubleclick on AP - link to FINA050
@author natalia.khozyainova, Nikitenko Artem
@since 24/08/2018, 02.09.2020
@version 1.1
@project MA3 - Russia
/*/
Static Function RU06D0538_AP2Click(oFormula, cFieldName, nLineGrid, nLineModel )
Local aArea		:= GetArea()
Local aAreaSE2	:= Eval({||DbSelectArea("SE2"),SE2->(GetArea())})
Local oModel as Object
Local oModelF49 as Object
Local oModelF4B as Object
Local cKey as Character
Local lRet as Logical

Default oFormula:=NIL
Default cFieldName:=""
Default nLineGrid:=0
Default nLineModel:=0

lRet:=.T.
oModel:=FwModelActive()
oModelF49:=oModel:GetModel("RU06D05_MF49")
oModelF4B:=oModel:GetModel(oFormula:GetModel():GetID())
cId = iif(oFormula:GetModel():GetID() == 'RU06D05_MVIRT', 'B_', 'F4B')
cKey:= xFilial("SE2")+oModelF4B:GetValue(cId +"PREFIX")+oModelF4B:GetValue(cId +"NUM")+oModelF4B:GetValue(cId +"PARCEL")+;
oModelF4B:GetValue(cId +"TYPE")+oModelF49:GetValue("F49_SUPP")+oModelF49:GetValue("F49_UNIT")

IF !(oModelF4B:CanSetValue(cFieldName))
    SE2->(DbSetOrder(1))
        If DbSeek(cKey)
            dbSelectArea("SA2")
            dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
            cCadastro := STR0100
            AxVisual('SE2',SE2->(RecNo()),2,,4,SA2->A2_NOME,"FA050MCPOS",fa050BAR('SE2->E2_PROJPMS == "1"')   )
            lRet:=.F.
        EndIf
    RestArea(aAreaSE2)
    RestArea(aArea)
EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0525_DefVirtStr
Virtual structure for gridd of All Bills
@author eduardo.flima
@since 17/04/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0525_DefVirtStr(lBS as Logical)
Local oStruct   as Object
Local aArea     as Array
Local cWhen     as Character
Default lBS:=.F.
If lBS
    cWhen:= "lBS .and. FwFldGet('B_CONUNI') == '1' "
Else
    cWhen:=".F."
EndIf
aArea	:=GetArea()
oStruct :=FWFormModelStruct():New()

// Table 
oStruct:AddTable("", , "Bills")

// Indexes 
oStruct:AddIndex(   1, ;     // [01] Index Order
		"01", ;     // [02] ID
		"B_BRANCH + B_CODREQ + B_PREFIX + B_NUM + B_PARCEL + B_TYPE", ; 	// [03] Key of Index
		"Virt_Bills"	, ; 	// [04] Description of Index
		""			, ;    	// [05] Lookup Expression 
		""			, ;    	// [06] Index Nickname
		.T. )				// [07] Index used on interface


// Fields
//               Titulo,                       ToolTip,          Field ID,   Tipo,                                          Tam,                                          Dec,                           Valid   ,When,   Combo,Obrigat,Init, Chave, Altera,   Virtual

oStruct:AddField("B_BRANCH"             ,"B_BRANCH"             ,"B_BRANCH" ,GetSX3Cache("F4B_FILIAL", "X3_TIPO"), GetSX3Cache("F4B_FILIAL", "X3_TAMANHO")   ,GetSX3Cache("F4B_FILIAL", "X3_DECIMAL")  ,Nil ,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Branch
oStruct:AddField(RetTitle("F4B_RATUSR") ,RetTitle("F4B_RATUSR") ,"B_CHECK"  ,"L"                                 , 1                                         ,0                                        ,Nil	,{|| &(cWhen)}  ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Currency Rate is Manual
oStruct:AddField(RetTitle("F4A_CODREQ") ,RetTitle("F4A_CODREQ") ,"B_CODREQ" ,GetSX3Cache("F4A_CODREQ", "X3_TIPO"), GetSX3Cache("F4A_CODREQ", "X3_TAMANHO")   ,GetSX3Cache("F4A_CODREQ", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Request Code
oStruct:AddField(RetTitle("F4B_PREFIX") ,RetTitle("F4B_PREFIX") ,"B_PREFIX" ,GetSX3Cache("F4B_PREFIX", "X3_TIPO"), GetSX3Cache("F4B_PREFIX", "X3_TAMANHO")   ,GetSX3Cache("F4B_PREFIX", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Prefix
oStruct:AddField(RetTitle("F4B_NUM")    ,RetTitle("F4B_NUM")    ,"B_NUM"    ,GetSX3Cache("F4B_NUM", "X3_TIPO"),    GetSX3Cache("F4B_NUM", "X3_TAMANHO")      ,GetSX3Cache("F4B_NUM", "X3_DECIMAL")     ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Number
oStruct:AddField(RetTitle("F4B_PARCEL") ,RetTitle("F4B_PARCEL") ,"B_PARCEL" ,GetSX3Cache("F4B_PARCEL", "X3_TIPO"), GetSX3Cache("F4B_PARCEL", "X3_TAMANHO")   ,GetSX3Cache("F4B_PARCEL", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Parcel
oStruct:AddField(RetTitle("F4B_TYPE")   ,RetTitle("F4B_TYPE")   ,"B_TYPE"   ,GetSX3Cache("F4B_TYPE", "X3_TIPO"),   GetSX3Cache("F4B_TYPE", "X3_TAMANHO")     ,GetSX3Cache("F4B_TYPE", "X3_DECIMAL")    ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Type
oStruct:AddField(RetTitle("F4B_CLASS")  ,RetTitle("F4B_CLASS")  ,"B_CLASS"  ,GetSX3Cache("F4B_CLASS", "X3_TIPO"),  GetSX3Cache("F4B_CLASS", "X3_TAMANHO")    ,GetSX3Cache("F4B_CLASS", "X3_DECIMAL")   ,Nil	,{|| .F.}       ,{} ,.F.    ,NIL     ,NIL    ,NIL    ,.F.)   // Class
oStruct:AddField(RetTitle("F4B_EMISS")  ,RetTitle("F4B_EMISS")  ,"B_EMISS"  ,GetSX3Cache("F4B_EMISS", "X3_TIPO"),  GetSX3Cache("F4B_EMISS", "X3_TAMANHO")    ,GetSX3Cache("F4B_EMISS", "X3_DECIMAL")   ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Emissao Date
oStruct:AddField(RetTitle("F4B_REALMT") ,RetTitle("F4B_REALMT") ,"B_REALMT" ,GetSX3Cache("F4B_REALMT", "X3_TIPO"), GetSX3Cache("F4B_REALMT", "X3_TAMANHO")   ,GetSX3Cache("F4B_REALMT", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Real maturity date
oStruct:AddField(RetTitle("F4B_VALPAY") ,RetTitle("F4B_VALPAY") ,"B_VALPAY" ,GetSX3Cache("F4B_VALPAY", "X3_TIPO"), GetSX3Cache("F4B_VALPAY", "X3_TAMANHO")   ,GetSX3Cache("F4B_VALPAY", "X3_DECIMAL")  ,Nil	,{|| lBS}  ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Value to pay
oStruct:AddField(RetTitle("F4B_EXGRAT") ,RetTitle("F4B_EXGRAT") ,"B_EXGRAT" ,GetSX3Cache("F4B_EXGRAT", "X3_TIPO"), GetSX3Cache("F4B_EXGRAT", "X3_TAMANHO")   ,GetSX3Cache("F4B_EXGRAT", "X3_DECIMAL")  ,Nil	,{|| &(cWhen)}  ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Exchange Rate
oStruct:AddField(RetTitle("F4B_VALCNV") ,RetTitle("F4B_VALCNV") ,"B_VALCNV" ,GetSX3Cache("F4B_VALCNV", "X3_TIPO"), GetSX3Cache("F4B_VALCNV", "X3_TAMANHO")   ,GetSX3Cache("F4B_VALCNV", "X3_DECIMAL")  ,Nil	,{|| &(cWhen)}  ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Exchange Rate
oStruct:AddField(RetTitle("F4B_BSVATC") ,RetTitle("F4B_BSVATC") ,"B_BSVATC" ,GetSX3Cache("F4B_BSVATC", "X3_TIPO"), GetSX3Cache("F4B_BSVATC", "X3_TAMANHO")   ,GetSX3Cache("F4B_BSVATC", "X3_DECIMAL")  ,Nil	,{|| &(cWhen)}  ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Exchange Rate
oStruct:AddField(RetTitle("F4B_VLVATC") ,RetTitle("F4B_VLVATC") ,"B_VLVATC" ,GetSX3Cache("F4B_VLVATC", "X3_TIPO"), GetSX3Cache("F4B_VLVATC", "X3_TAMANHO")   ,GetSX3Cache("F4B_VLVATC", "X3_DECIMAL")  ,Nil	,{|| &(cWhen)}  ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Exchange Rate
oStruct:AddField(RetTitle("F4B_VALUE")  ,RetTitle("F4B_VALUE")  ,"B_VALUE"  ,GetSX3Cache("F4B_VALUE", "X3_TIPO"),  GetSX3Cache("F4B_VALUE", "X3_TAMANHO")    ,GetSX3Cache("F4B_VALUE", "X3_DECIMAL")   ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Value from bill
oStruct:AddField(RetTitle("F4B_CURREN") ,RetTitle("F4B_CURREN") ,"B_CURREN" ,GetSX3Cache("F4B_CURREN", "X3_TIPO"), GetSX3Cache("F4B_CURREN", "X3_TAMANHO")   ,GetSX3Cache("F4B_CURREN", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Currency 
oStruct:AddField(RetTitle("F4B_CONUNI") ,RetTitle("F4B_CONUNI") ,"B_CONUNI" ,GetSX3Cache("F4B_CONUNI", "X3_TIPO"), GetSX3Cache("F4B_CONUNI", "X3_TAMANHO")   ,GetSX3Cache("F4B_CONUNI", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Conventional units 
oStruct:AddField(RetTitle("F4B_VLCRUZ") ,RetTitle("F4B_VLCRUZ") ,"B_VLCRUZ" ,GetSX3Cache("F4B_VLCRUZ", "X3_TIPO"), GetSX3Cache("F4B_VLCRUZ", "X3_TAMANHO")   ,GetSX3Cache("F4B_VLCRUZ", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Value in local currency
oStruct:AddField(RetTitle("F4B_OPBAL")  ,RetTitle("F4B_OPBAL")  ,"B_OPBAL"  ,GetSX3Cache("F4B_OPBAL", "X3_TIPO"),  GetSX3Cache("F4B_OPBAL", "X3_TAMANHO")    ,GetSX3Cache("F4B_OPBAL", "X3_DECIMAL")   ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Open balance 
oStruct:AddField(RetTitle("F4B_BSIMP1") ,RetTitle("F4B_BSIMP1") ,"B_BSIMP1" ,GetSX3Cache("F4B_BSIMP1", "X3_TIPO"), GetSX3Cache("F4B_BSIMP1", "X3_TAMANHO")   ,GetSX3Cache("F4B_BSIMP1", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // VAT Base
oStruct:AddField(RetTitle("F4B_ALIMP1") ,RetTitle("F4B_ALIMP1") ,"B_ALIMP1" ,GetSX3Cache("F4B_ALIMP1", "X3_TIPO"), GetSX3Cache("F4B_ALIMP1", "X3_TAMANHO")   ,GetSX3Cache("F4B_ALIMP1", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // VAT Rate
oStruct:AddField(RetTitle("F4B_VLIMP1") ,RetTitle("F4B_VLIMP1") ,"B_VLIMP1" ,GetSX3Cache("F4B_VLIMP1", "X3_TIPO"), GetSX3Cache("F4B_VLIMP1", "X3_TAMANHO")   ,GetSX3Cache("F4B_VLIMP1", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // VAT Value
oStruct:AddField(RetTitle("F4B_MDCNTR") ,RetTitle("F4B_MDCNTR") ,"B_MDCNTR" ,GetSX3Cache("F4B_MDCNTR", "X3_TIPO"), GetSX3Cache("F4B_MDCNTR", "X3_TAMANHO")   ,GetSX3Cache("F4B_MDCNTR", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Contract number from bill
oStruct:AddField(RetTitle("F4B_FLORIG") ,RetTitle("F4B_FLORIG") ,"B_FLORIG" ,GetSX3Cache("F4B_FLORIG", "X3_TIPO"), GetSX3Cache("F4B_FLORIG", "X3_TAMANHO")   ,GetSX3Cache("F4B_FLORIG", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Filial of Request
oStruct:AddField(RetTitle("F4B_IDF4A")  ,RetTitle("F4B_IDF4A")  ,"B_IDF4A"  ,GetSX3Cache("F4B_IDF4A", "X3_TIPO"),  GetSX3Cache("F4B_IDF4A", "X3_TAMANHO")    ,GetSX3Cache("F4B_IDF4A", "X3_DECIMAL")   ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Filial of Request
oStruct:AddField(RetTitle("F4B_RATUSR") ,RetTitle("F4B_RATUSR") ,"B_RATUSR" ,GetSX3Cache("F4B_RATUSR", "X3_TIPO"), GetSX3Cache("F4B_RATUSR", "X3_TAMANHO")   ,GetSX3Cache("F4B_RATUSR", "X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // If Currency Rate is Manual

RestArea(aArea)

Return (oStruct)

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0526_LoadBills
Load function for virtual grid - All Bills
@author eduardo.flima
@since 17/04/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RU06D0526_LoadBills(oModel)
Local aLines as Array
Local cQuery as Character
Local cTab as Character
Local oModelF4B as Object
Local nOpBal as Numeric

oModelF4B:=oModel:GetModel("RU06D05_MF4B")

aLines		:={}
cQuery := "SELECT * FROM " + RetSQLName("F4B")  + " F4B "
cQuery += " LEFT JOIN " + RetSQLName("SE2") +" SE2 "
cQuery += " ON (F4B_FLORIG=E2_FILIAL AND F4B_PREFIX=E2_PREFIXO AND F4B_NUM=E2_NUM AND F4B_PARCEL=E2_PARCELA AND F4B_TYPE=E2_TIPO) "
cQuery += " LEFT JOIN " + RetSQLName("F4A") +" F4A "
cQuery += " ON (F4A_FILIAL=F4B_FILIAL AND F4A_IDF4A=F4B_IDF4A )"
cQuery += " WHERE F4B_IDF49 ='" + FwFldGet("F49_IDF49") +"'"
cQuery += " AND E2_FORNECE='" + FwFldGet("F49_SUPP") +"'"
cQuery += " AND E2_LOJA='" + FwFldGet("F49_UNIT") +"'"
cQuery += " AND F4B.D_E_L_E_T_ =' ' AND SE2.D_E_L_E_T_ =' ' AND F4A.D_E_L_E_T_=' '"

cQuery := ChangeQuery(cQuery)
cTab := CriaTrab( , .F.)
TcQuery cQuery New Alias ((cTab))

While (cTab)->(!EOF())  .and. ((cTab)->(F4B_FILIAL+F4B_IDF49) == (xFilial("F4B")+FwFldGet("F49_IDF49")))
    nOpBal:=ROUND((cTab)->E2_SALDO,2)
	AADD(aLines,{0,{xFILIAL("F4B"), if((cTab)->F4B_RATUSR=='1',.T.,.F.), (cTab)->F4A_CODREQ, (cTab)->F4B_PREFIX, (cTab)->F4B_NUM , (cTab)->F4B_PARCEL , (cTab)->F4B_TYPE , (cTab)->E2_NATUREZ ,;
    STOD((cTab)->E2_EMISSAO) , STOD((cTab)->E2_VENCREA) , ROUND((cTab)->F4B_VALPAY,2) , ROUND((cTab)->F4B_EXGRAT,4) , ROUND((cTab)->F4B_VALCNV,2) , ROUND((cTab)->F4B_BSVATC,2) ,;
    ROUND((cTab)->F4B_VLVATC,2) , nOpBal , (cTab)->E2_MOEDA, (cTab)->F4B_CONUNI , ROUND((cTab)->E2_VLCRUZ,2), ROUND((cTab)->E2_SALDO,2), 0 , ROUND((cTab)->E2_ALQIMP1,2) ,;
    ROUND((cTab)->F4B_VLIMP1,2) , '' , (cTab)->F4B_FLORIG , (cTab)->F4A_IDF4A ,(cTab)->F4B_RATUSR }})
	(cTab)->(DBSkip())
Enddo

Return (aLines)


//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0527_DefVirtViewStr
View structure for virtual grid - All Bills
@author eduardo.flima
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0527_DefVirtViewStr(lBS as Logical)
Local aArea 	as Array
Local oStruct 	as Object
Default lBS:=.F.

aArea		:= 	GetArea()
oStruct 	:= 	FWFormViewStruct():New()
//                  ID      Order           Titulo          Descrip                 Help Type    Pict                           bPictVar LookUp CanCh  Ider cGroup Combo MaxLenCombo IniBrw, lVirt PicVar
oStruct:AddField("B_CHECK"	,"01"	,RetTitle("F4B_RATUSR")	,RetTitle("F4B_RATUSR")	,NIL ,"L"	,""                         	,NIL ,''	,   lBS	  ,''	,''		,{}	,0	,''		,.F.) // Request Code
oStruct:AddField("B_CODREQ"	,"02"	,RetTitle("F4A_CODREQ")	,RetTitle("F4A_CODREQ")	,NIL ,"C"	,PesqPict("F4A","F4A_CODREQ")	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.) // Request Code
oStruct:AddField("B_PREFIX"	,"03"	,RetTitle("F4B_PREFIX")	,RetTitle("F4B_PREFIX")	,NIL ,"C"	,PesqPict("F4B","F4B_PREFIX")	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.) // AP Prefic
oStruct:AddField("B_NUM"	,"04"	,RetTitle("F4B_NUM")	,RetTitle("F4B_NUM")	,NIL ,"C"	,PesqPict("F4B","F4B_NUM")	    ,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.) // AP Number
oStruct:AddField("B_PARCEL"	,"05"	,RetTitle("F4B_PARCEL")	,RetTitle("F4B_PARCEL")	,NIL ,"C"	,PesqPict("F4B","F4B_PARCEL")	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.) // AP parcel
oStruct:AddField("B_TYPE"	,"06"	,RetTitle("F4B_TYPE")	,RetTitle("F4B_TYPE")	,NIL ,"C"	,PesqPict("F4B","F4B_TYPE")	    ,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.) // AP Type
oStruct:AddField("B_CLASS"	,"07"	,RetTitle("F4B_CLASS")	,RetTitle("F4B_CLASS")	,NIL ,"C"	,PesqPict("F4B","F4B_CLASS")	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // AP Class
oStruct:AddField("B_EMISS"	,"08"	,RetTitle("F4B_EMISS")	,RetTitle("F4B_EMISS")	,NIL ,"D"	,PesqPict("F4B","F4B_EMISS" )	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // Emission date
oStruct:AddField("B_REALMT"	,"09"	,RetTitle("F4B_REALMT")	,RetTitle("F4B_REALMT")	,NIL ,"D"	,PesqPict("F4B","F4B_REALMT" )	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // Plan date
oStruct:AddField("B_VALPAY"	,"10"	,RetTitle("F4B_VALPAY")	,RetTitle("F4B_VALPAY")	,NIL ,"N"	,PesqPict("F4B","F4B_VALPAY") 	,NIL ,''	,   lBS	  ,''	,''		,{}	,0	,''		,.F.) // Value to pay
oStruct:AddField("B_EXGRAT"	,"11"	,RetTitle("F4B_EXGRAT")	,RetTitle("F4B_EXGRAT")	,NIL ,"N"	,PesqPict("F4B","F4B_EXGRAT") 	,NIL ,''	,   lBS	  ,''	,''		,{}	,0	,''		,.F.) // Value to pay
oStruct:AddField("B_VALCNV"	,"12"	,RetTitle("F4B_VALCNV")	,RetTitle("F4B_VALCNV")	,NIL ,"N"	,PesqPict("F4B","F4B_VALCNV") 	,NIL ,''	,   lBS	  ,''	,''		,{}	,0	,''		,.F.) // Value to pay
oStruct:AddField("B_BSVATC"	,"13"	,RetTitle("F4B_BSVATC")	,RetTitle("F4B_BSVATC")	,NIL ,"N"	,PesqPict("F4B","F4B_BSVATC") 	,NIL ,''	,   lBS	  ,''	,''		,{}	,0	,''		,.F.) // Value to pay
oStruct:AddField("B_VLVATC"	,"14"	,RetTitle("F4B_VLVATC")	,RetTitle("F4B_VLVATC")	,NIL ,"N"	,PesqPict("F4B","F4B_VLVATC") 	,NIL ,''	,   lBS	  ,''	,''		,{}	,0	,''		,.F.) // Value to pay
oStruct:AddField("B_VALUE"	,"15"	,RetTitle("F4B_VALUE")  ,RetTitle("F4B_VALUE")	,NIL ,"N"	,PesqPict("SE2","E2_SALDO") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // Bill value
oStruct:AddField("B_CURREN"	,"16"	,RetTitle("F4B_CURREN")	,RetTitle("F4B_CURREN")	,NIL ,"C"	,PesqPict("SE2","E2_MOEDA") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // AP Currency
oStruct:AddField("B_CONUNI"	,"17"	,RetTitle("F4B_CONUNI")	,RetTitle("F4B_CONUNI")	,NIL ,"C"	,PesqPict("F4B","F4B_CONUNI")	,NIL ,''	,   .F.	  ,''	,''		,{'1=Yes','2=No'}		,0	,''		,.F.) // Conv Units
oStruct:AddField("B_VLCRUZ"	,"18"	,RetTitle("F4B_VLCRUZ")	,RetTitle("F4B_VLCRUZ")	,NIL ,"N"	,PesqPict("SE2","E2_VLCRUZ")	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // Value in local currency
oStruct:AddField("B_OPBAL"	,"19"	,RetTitle("F4B_OPBAL")	,RetTitle("F4B_OPBAL")	,NIL ,"N"	,PesqPict("SE2","E2_SALDO") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // Open balance
oStruct:AddField("B_BSIMP1"	,"20"	,RetTitle("F4B_BSIMP1")	,RetTitle("F4B_BSIMP1")	,NIL ,"N"	,PesqPict("SE2","E2_SALDO") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // VAT Base
oStruct:AddField("B_ALIMP1"	,"21"	,RetTitle("F4B_ALIMP1")	,RetTitle("F4B_ALIMP1")	,NIL ,"N"	,PesqPict("SE2","E2_ALQIMP1") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // VAT Rate
oStruct:AddField("B_VLIMP1"	,"22"	,RetTitle("F4B_VLIMP1")	,RetTitle("F4B_VLIMP1")	,NIL ,"N"	,PesqPict("F4B","F4B_VLIMP1") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.) // VAT Amount
oStruct:AddField("B_MDCNTR"	,"23"	,RetTitle("F4B_MDCNTR")	,RetTitle("F4B_MDCNTR")	,NIL ,"C"	,PesqPict("SE2","E2_MDCONTR") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // Contract number
oStruct:AddField("B_FLORIG"	,"24"	,RetTitle("F4B_FLORIG")	,RetTitle("F4B_FLORIG")	,NIL ,"C"	,PesqPict("F4B","F4B_FLORIG") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.) // Filial of origin


Return (oStruct)


/*/{Protheus.doc} R604PutFil
Function Used to Automaticly Put the FIL table data 
this function is called after supplier validation + after currency validation
@author Eduardo.Flima
@since 23/05/2018
@version 1.0
@project MA3 - Russia
/*/

Static Function RU06D0528_PutFil()
Local lRet as Logical
Local aSaveArea as Array
Local lOk as Logical 
Local nCurr as Numeric
Local cKey as Character
Local cSupp as Character
Local cUnit as Character
Local oModel as Character

lOk := .F. 
aSaveArea := GetArea()
cSupp:=FwFldGet("F49_SUPP")
cUnit:=FwFldGet("F49_UNIT")
oModel:=FwModelActive()

if FwFldGet("F49_PREPAY")='1' .or. RU06D0544_EmptyModel(oModel:GetModel("RU06D05_MF4A"),"F4A_CODREQ")

    If R604ChkFil(xFilial("FIL"), cSupp, cUnit, FwFldGet("F49_BNKREC"), FwFldGet("F49_RECBIK"), FwFldGet("F49_RECACC"), str(val(FwFldGet("F49_CURREN"))))
        cKey:=xFilial("FIL")+cSupp+cUnit
        dbSelectArea("FIL")
        FIL->(DbSetOrder(1))
        If (FIL->(DbSeek(cKey,.T.)))
            nCurr := Val(FwFldGet("F49_CURREN")) 
            While (FIL->(!EOF())) .and. (FIL->FIL_FILIAL+FIL->FIL_FORNEC+FIL->FIL_LOJA == xFilial("FIL") +cSupp+cUnit) .and. !lOk 
                If FIL->FIL_MOEDA == nCurr
                    FwFldPut("F49_BNKREC",FIL->FIL_BANCO,,,,.T.)
                    FwFldPut("F49_RECBIK",FIL->FIL_AGENCI,,,,.T.)
                    FwFldPut("F49_RECACC",FIL->FIL_CONTA,,,,.F.)
                    FwFldPut("F49_TYPCC",FIL->FIL_TIPO,,,,.T.)
                    FwFldPut("F49_ACRNAM",FIL->FIL_ACNAME,,,,.F.)
                    FwFldPut("F49_RECNAM",LEFT(ALLTRIM(FIL->FIL_NMECOR),100),,,,.T.)
                    lOk:=.T.
                EndIf
                FIL->(DbSkip())
            Enddo        
            If !lOk //Clear  the data 
                aFields:={"F49_BNKREC","F49_RECBIK","F49_RECACC","F49_TYPCC","F49_BKRNAM","F49_ACRNAM","F49_RECNAM"}
                RU06XFUN01_CleanFlds(aFields) // Load "" (empty) value to each field from the array
            EndIf
        Else
            aFields:={"F49_BNKREC","F49_RECBIK","F49_RECACC","F49_TYPCC","F49_BKRNAM","F49_ACRNAM","F49_RECNAM"}
            RU06XFUN01_CleanFlds(aFields) // Load "" (empty) value to each field from the array
        EndIf
    Endif  
Else
    RU06D0545_PutSuppAcc()
EndIf
RestArea(aSaveArea)
Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0529_VldVat
Validations for F49_VALUE, _VATCOD, _VATRAT, _VATAMT
@author natalia.khozyainova
@param nNum: // 1 = F49_VALUE, 2=F49_VATCOD , 3=F49_VATRAT, 4=F49_VATAMNT
@since 18/12/2018
@version 2.0
@project MA3 - Russia
/*/
Function RU06D0529_VldVat(nNum as Numeric)
Local lRet as Logical
lRet:=RU06XFUN17_VldVATFields(nNum, "F49", "RU06D05_MF4B")
Return lRet


/*/{Protheus.doc} RU06D0530_RetF47
Virtual fields of F4A initializer
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0530_RetF47(nField,cTable)
Local cRet      as Character
Local aSaveArea as Array
Local cKey      as Char

Default cTable:='F47'
Default nField  := 1
aSaveArea   := GetArea()
If cTable=='F47'
    cKey := F49->F49_FILREQ+((F4A->F4A_CODREQ))
EndIf

If nField == 1 .and. ValType(cKey)='C' // F4A_PREPAY
        cRet := Posicione("F47",1,cKey,"F47_PREPAY")
    ElseIf nField == 2 .and. ValType(cKey)='C' // F4A_BNKCOD
        cRet := Posicione("F47",1,cKey,"F47_BNKCOD")
    ElseIf nField == 3 .and. ValType(cKey)='C' // F4A_CNT
        cRet := Posicione("F47",1,cKey,"F47_CNT")
    ElseIf nField == 4 .and. ValType(cKey)='C' // F4A_CLASS
        cRet := Posicione("F47",1,cKey,"F47_CLASS")
    ElseIf nField == 5 .and. ValType(cKey)='C' // F4A_VALUE
        cRet := Posicione("F47",1,cKey,"F47_VALUE")
    ElseIf nField == 6 .and. ValType(cKey)='C' // F4A_VATCOD
        cRet := Posicione("F47",1,cKey,"F47_VATCOD")
    ElseIf nField == 7 .and. ValType(cKey)='C' // F4A_VATRAT
        cRet := Posicione("F47",1,cKey,"F47_VATRAT")
    ElseIf nField == 8 .and. ValType(cKey)='C' // F4A_VATAMT
        cRet := Posicione("F47",1,cKey,"F47_VATAMT")
    ElseIf nField == 9 .and. ValType(cKey)='C' // F4A_REASON
        cRet := Posicione("F47",1,cKey,"F47_REASON")
    Endif 
RestArea(aSaveArea)

Return (cRet)

/*/{Protheus.doc} RU06D0531_TOTLS
Calculates total value and total vat amount from lines
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0531_TOTLS(lForce as Logical,nLine as Numeric, cAction as Character)
Local nVal as Numeric
Local nVat as Numeric
Local oModel as Object
Local oModelF49 as Object
Local oModelF4A as Object
Local oView as Object
Local oViewHead as Object
Local nX as Numeric

Default lForce:=.F.
Default nLine:=0
Default cAction:=''

oModel:=FWModelActive()
oModelF49:=oModel:GetModel("RU06D05_MF49")
oModelF4A:=oModel:GetModel("RU06D05_MF4A")
    
oView := FwViewActive()
If lForce
    nVal:=0
    nVat:=0    
        
    for nX:=1 to oModelF4A:Length()
        if !(nX==nLine .and. cAction='DELETE')
            oModelF4A:GoLine(nX)
            if !(oModelF4A:IsDeleted()) .or. (nX==nLine .and. cAction='UNDELETE')
                If !Empty("F4A_VALUE") 
                    nVal+=oModelF4A:GetValue("F4A_VALUE")
                EndIf
                If !Empty("F4A_VATAMT")
                    nVat+=oModelF4A:GetValue("F4A_VATAMT")
                EndIf
            Endif
        EndIf 
    Next nX
        
    oModelF49:SetValue("F49_VALUE",nVal)
    oModelF49:SetValue("F49_VATAMT",nVat)
EndIf

If !Empty(oView) 
    oViewHead := oView:GetViewObj("RU06D05_VHEAD")[3]
    If !Empty(oViewHead)
        oViewHead:Refresh(.T.,.F.)
    EndIf
EndIf

if nLine>0
    oModelF4A:GoLine(nLine)
EndIf

Return (NIL)


/*/{Protheus.doc} RU06D0532_RecalcTotls
Recalc totals menu button
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RU06D0532_RecalcTotls()
If FwFldGet("F49_PREPAY")!="1"
    If MsgNoYes(STR0032,STR0031) // Totals will be recalculated. Continue? -- Recalculate
        RU06D0531_TOTLS(.T.)
        RU06D0536_POReason()

        lUserValue:=.F.
    EndIf
Else
    Help("",1,STR0033,,STR0034,1,0,,,,,,{STR0035})// Totals Recalculation -- can not recalculate prepayment -- change prepayment parameter
EndIf
Return (NIL)

/*/{Protheus.doc} RU06D0543_VrtModel
to add lines to the vitual grid of All Bills at the moment of Picking p PRs
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0543_VrtModel(oModel)
Local oModelF4B as Object
Local oModelVirt as Object
Local oModelF4A as Object

Local nQ as Numeric
Local nX as Numeric
Local nY as Numeric
Local lExitCycle as Logical

Local cKey1 as Character
Local cKey2 as Character

lExitCycle:=.F.

if ValType(oModel)=='O'
    oModelF4B:=oModel:GetModel("RU06D05_MF4B")
    oModelF4A:=oModel:GetModel("RU06D05_MF4A")
    oModelVirt:=oModel:GetModel("RU06D05_MVIRT")
EndIf

for nQ:=1 to  oModelF4A:Length()
    oModelF4A:GoLine(nQ)

    if !(oModelF4A:IsDeleted())
        for nX:=1 to oModelF4B:Length()
            oModelF4B:GoLine(nX)
            cKey1:= alltrim(oModelF4B:GetValue("F4B_FILIAL")) + alltrim(oModelF4B:GetValue("F4B_IDF4A")) + alltrim(oModelF4B:GetValue("F4B_PREFIX")) + ;
            alltrim(oModelF4B:GetValue("F4B_NUM")) +  alltrim(oModelF4B:GetValue("F4B_PARCEL")) +  alltrim(oModelF4B:GetValue("F4B_TYPE"))
            lExitCycle:=.F.

            for nY:=1 to oModelVirt:Length()
                If !lExitCycle
                    oModelVirt:GoLine(nY)
                    cKey2:= alltrim(xFilial("F4B")) + alltrim(oModelVirt:GetValue("B_IDF4A")) +  alltrim(oModelVirt:GetValue("B_PREFIX")) + ;
                    alltrim(oModelVirt:GetValue("B_NUM")) +  alltrim(oModelVirt:GetValue("B_PARCEL")) +  alltrim(oModelVirt:GetValue("B_TYPE"))

                    if (cKey1==cKey2)
                        lExitCycle:=.T.
                    EndIf    
                EndIf
            Next nY

            if !lExitCycle
                
                if !(Empty(oModelVirt:GetValue("B_NUM"))) .or. oModelVirt:IsDeleted()
                    oModelVirt:SetNoInsertLine(.F.)
                    oModelVirt:AddLine()
                    oModelVirt:SetNoInsertLine(.T.)
                Endif

                oModelVirt:GoLine(oModelVirt:Length())

                oModelVirt:LoadValue("B_BRANCH",    xFilial ("F4B")) 
                oModelVirt:LoadValue("B_CHECK",     if(oModelF4B:GetValue("F4B_RATUSR")=='1' ,.T.,.F.)) 

                if POSICIONE("F47",1,oModel:GetModel("RU06D05_MF49"):GetValue("F49_FILREQ")+oModelF4A:GetValue("F4A_CODREQ"),"F47_PREPAY")!="1"
                    oModelVirt:LoadValue("B_CODREQ",    oModelF4A:GetValue("F4A_CODREQ"))	
                EndIf
                oModelVirt:LoadValue("B_PREFIX",    oModelF4B:GetValue("F4B_PREFIX"))	
                oModelVirt:LoadValue("B_NUM",       oModelF4B:GetValue("F4B_NUM"))
                oModelVirt:LoadValue("B_PARCEL",    oModelF4B:GetValue("F4B_PARCEL") )
                oModelVirt:LoadValue("B_TYPE",      oModelF4B:GetValue("F4B_TYPE") )	 
                oModelVirt:LoadValue("B_CLASS",     oModelF4B:GetValue("F4B_CLASS") )	 
                oModelVirt:LoadValue("B_EMISS",     oModelF4B:GetValue("F4B_EMISS") )	 
                oModelVirt:LoadValue("B_REALMT",    oModelF4B:GetValue("F4B_REALMT") )	 
                oModelVirt:LoadValue("B_VALPAY",    oModelF4B:GetValue("F4B_VALPAY") )	

                oModelVirt:LoadValue("B_EXGRAT",    oModelF4B:GetValue("F4B_EXGRAT") )	
                oModelVirt:LoadValue("B_VALCNV",    oModelF4B:GetValue("F4B_VALCNV") )	
                oModelVirt:LoadValue("B_BSVATC",    oModelF4B:GetValue("F4B_BSVATC") )	
                oModelVirt:LoadValue("B_VLVATC",    oModelF4B:GetValue("F4B_VLVATC") )	

                oModelVirt:LoadValue("B_VALUE",     oModelF4B:GetValue("F4B_VALUE") )	 
                oModelVirt:LoadValue("B_CURREN",    oModelF4B:GetValue("F4B_CURREN") )	 
                oModelVirt:LoadValue("B_CONUNI",    oModelF4B:GetValue("F4B_CONUNI") )	 
                oModelVirt:LoadValue("B_VLCRUZ",    oModelF4B:GetValue("F4B_VLCRUZ") )	 
                oModelVirt:LoadValue("B_OPBAL",     oModelF4B:GetValue("F4B_OPBAL") )	 
                oModelVirt:LoadValue("B_BSIMP1",    oModelF4B:GetValue("F4B_BSIMP1") )	 
                oModelVirt:LoadValue("B_ALIMP1",    oModelF4B:GetValue("F4B_ALIMP1") )	 
                oModelVirt:LoadValue("B_VLIMP1",    oModelF4B:GetValue("F4B_VLIMP1") )	 
                oModelVirt:LoadValue("B_MDCNTR",    oModelF4B:GetValue("F4B_MDCNTR") )	 
                oModelVirt:LoadValue("B_FLORIG",    oModelF4B:GetValue("F4B_FLORIG") )	 
                oModelVirt:LoadValue("B_IDF4A",     oModelF4A:GetValue("F4A_IDF4A"))	
            Endif
        Next nX
    EndIf
Next nQ 

Return (nil)

/*/{Protheus.doc} RU06D0540_Array
make an aray of fields that should not be copied in Copy operation
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0540_Array(oModel)
Local oStr as Object
Local aRet as Array
Local nX as Numeric

oStr:=oModel:GetStruct()
aRet:={}

for nX:=1 to oStr:FieldsLength()
    aAdd(aRet, oStr:GetFields()[nX][03])
next nX

Return (aRet)




/*/{Protheus.doc} RU06D0535_MarkAll
Mark all records
@param		oBrowsePut - Object
			cTempTbl - Alias markbrowse
@author eduardo.flima
@since 20/08/2018
@version P12.1.20
@type function
@project	MA3
/*/
Static Function RU06D0535_MarkAll(oBrowsePut as Object, cTempTbl as Char)
Local nRecOri 	as Numeric
nRecOri	:= (cTempTbl)->( RecNo() )

dbSelectArea(cTempTbl)
(cTempTbl)->( DbGoTop() )
Do while !(cTempTbl)->( Eof() )
	RecLock(cTempTbl, .F.)
	If !Empty((cTempTbl)->F47_OK)
		(cTempTbl)->F47_OK := ''
	Else
		(cTempTbl)->F47_OK := cMark
	EndIf
	MsUnlock()

	(cTempTbl)->( DbSkip() )
Enddo

(cTempTbl)->( DbGoTo(nRecOri) )
oBrowsePut:oBrowse:Refresh(.T.)
Return .T.



/*/{Protheus.doc} RU06D0536_POReason
writes reason of payment
cAction Parameter is used because this function we call at the moment of deletion/undeletion line
@author natalia.khozyainova
@since 20/08/2018
@version P12.1.20
@type function
@project	MA3
/*/
Function RU06D0536_POReason(nLine,cAction,lCopy)
Local cRet as Character
Local oModel as Object
Local oModelF49 as Object
Local oModelF4A as Object
Local oModelF4B as Object
Local aFields   as Array
Local cTmpTab as Character
Local oTmpTab as Object
Local nX as Numeric
Local nY as Numeric
Local nQtyPRs as Numeric
Local cCont as Character
Local cText as Character
Local cTextLn as Character
Local nOn as Numeric
Local nVatRt as Numeric
Local nVatAmnt as Numeric
Local aAreaTmp as Array
Local lDbSeek as Logical
Local aSaveArea as Array
Local nTheLine as Numeric
Local oView as Object
Local oViewHead as Object

Default nLine:=0
Default cAction:=''
Default lCopy:=.F.

aSaveArea:=GetArea()
oModel:=FwModelActive()
oModelF49:=oModel:GetModel("RU06D05_MF49")
oModelF4A:=oModel:GetModel("RU06D05_MF4A")
oModelF4B:=oModel:GetModel("RU06D05_MF4B")

nVatRt:=oModelF49:GetValue("F49_VATRAT")
nVatAmnt:=oModelF49:GetValue("F49_VATAMT")

nTheLine:=0
nQtyPRs:=0
cRet:=''

// calc qty of lines and if there is only 1 line its number will be saved in nTheLine
For nX := 1 To oModelF4A:Length()
    oModelF4A:GoLine(nX)
    if ( !(oModelF4A:IsDeleted()) .or. cAction=='UNDELETE') .and. !Empty("F4A_CODREQ")
            if !(cAction='DELETE' .and. nX==nLine)
            nQtyPRs++
            nTheLine:=oModelF4A:GetLine()
        EndIf
    EndIf
Next nX

if lCopy
    nQtyPRs:=0
EndIf
oModelF4A:GoLine(1)

if nQtyPRs==1 // if there is only 1 line, copy Reason of Payment
    cRet:=ALLTRIM(FwFldGet("F4A_REASON",nTheLine)) 

Elseif nQtyPRs>0
    cRet:=''

    If oTmpTab <> Nil // temporary table to make listing of bills w/o duplication
        oTmpTab:Delete()
        oTmpTab := Nil
    Endif
    cTmpTab	:= CriaTrab(,.F.)
    oTmpTab := FWTemporaryTable():New(cTmpTab)

    aFields := {}
    aadd(aFields,{"TMP_CNT"		, "C", GetSX3Cache("F4A_CNT", "X3_TAMANHO"),  GetSX3Cache("F4A_CNT", "X3_DECIMAL")})		
    aadd(aFields,{"TMP_BILL"	, "C", 50,  00})
    aadd(aFields,{"TMP_QTY"	    , "N", 2 ,  00})

    oTmpTab:SetFields(aFields)
    oTmpTab:AddIndex("Indice1", {"TMP_CNT","TMP_BILL"} )
    oTmpTab:Create()

    For nX := 1 To oModelF4A:Length() // check every PR in model
        oModelF4A:GoLine(nX)
        if ( !(oModelF4A:IsDeleted()) .or. cAction=='UNDELETE') .and. !Empty("F4A_CODREQ")
            if !(cAction='DELETE' .and. nX==nLine)
                For nY:=1 to oModelF4B:Length() // check every AP of every PR in model
                    oModelF4B:GoLine(nY)
                    aAreaTmp := (cTmpTab)->(GetArea())
                    (cTmpTab)->(dbSetOrder(1))
                    lDbSeek := (cTmpTab)->(DbSeek(oModelF4A:GetValue("F4A_CNT")+ALLTRIM(oModelF4B:GetValue("F4B_PREFIX"))+'/'+ALLTRIM(oModelF4B:GetValue("F4B_NUM"))+;
                    STR0059+ALLTRIM(DTOC(oModelF4B:GetValue("F4B_EMISS")) ))) // add a bill to the tmp table, if it is not there yet 
                    RecLock(cTmpTab,!(lDbSeek)) 
                    (cTmpTab)->TMP_CNT:= oModelF4A:GetValue("F4A_CNT") 
                    if ALLTRIM(oModelF4B:GetValue("F4B_NUM"))==''   
                        (cTmpTab)->TMP_BILL:=''
                    Else    
                        (cTmpTab)->TMP_BILL	:= ALLTRIM(oModelF4B:GetValue("F4B_PREFIX"))+'/'+ ALLTRIM(oModelF4B:GetValue("F4B_NUM"))+STR0059+ALLTRIM(DTOC(oModelF4B:GetValue("F4B_EMISS"))) // ' from '
                    EndIf
                    (cTmpTab)->TMP_QTY	:= (cTmpTab)->TMP_QTY+1   
                    (cTmpTab)->(MsUnLock())
                next nY
            EndIf
        EndIf
    Next nX

    (cTmpTab)->(DBGoTop()) // now in cTmpTab we have a list of bills, each one described as a sentence like 'AA/BBB from 11.05/.2018'
    (cTmpTab)->(dbSetOrder(1))

    cCont:='nothing' // this means that no contract numbers were described in reason of payment so far
    cText:=''
    cTextLn:=''
    nOn:=0

    // this ccle takes avery line of Tmp Table and makes a text from it
    while !(cTmpTab)->(EOF()) 
        if alltrim((cTmpTab)->TMP_CNT)+alltrim((cTmpTab)->TMP_BILL)!='' // if there is bill number or contract number
            If alltrim(cCont)!=alltrim((cTmpTab)->TMP_CNT) 
                if cCont!='nothing'
                    cText:=alltrim(cText)+';'+CRLF + if(alltrim(cTextLn)!='',alltrim(cTextLn),'')// if there are some contracts in the Reason, we start from the new line
                    nOn:=0
                    cTextLn:=''
                Else    
                    cText:=STR0055 //'Payment ' - here we start if this contract is first to be described in Reason
                    nOn:=0
                    cTextLn:=''
                EndIf
                if alltrim((cTmpTab)->TMP_CNT)!=''  
                    cTextLn:=STR0056 + ((cTmpTab)->TMP_CNT) // 'from contract '
                EndIf
                if alltrim((cTmpTab)->TMP_BILL)!=''
                    cTextLn:=alltrim(cTextLn)+STR0058 + ((cTmpTab)->TMP_BILL) //' from bill ' 
                    nOn++
                EndIf
            Else 
                cTextLn:=alltrim(cTextLn)+', '+alltrim((cTmpTab)->TMP_BILL)
                nOn++
                if nOn==2
                    cTextLn:=StrTran(cTextLn, alltrim(STR0058), alltrim(STR0057)) // replace 'from bill' with 'from bills'
                EndIf
            EndIf
            if cCont!='nothing'
                cText:=alltrim(cText)+if(alltrim(cTextLn)!='',' '+alltrim(cTextLn),'') 
                nOn:=0
                cTextLn:=''
            Endif    
            cCont:=(cTmpTab)->TMP_CNT
        EndIf
        DBSkip()
    Enddo

    cRet:=cText
    if !(nVatRt=0 .and. nVatAmnt=0) // if there is some information about total VAT of PR, make a new line
        cRet:=alltrim(cRet)+'.'+CRLF 
    EndIf
EndIf

If nQtyPRs!=1 .and. !(nVatRt=0 .and. nVatAmnt=0) // add information about VAT

    If nVatRt!=0 // describe VAT rate
        cRet+=STR0060+alltrim(STR(ROUND(nVatRt,2)))+'%' // like 'Including VAT 13% '
    EndIf

    If nVatAmnt!=0 // describe VAT amount
        cRet+=' - '+alltrim(STR(ROUND(nVatAmnt,2),15,2)) // like ' - 300.00 '
    EndIf

EndIf

oModelF49:LoadValue("F49_REASON",cRet)
RestArea(aSaveArea)

If Empty(oView) 
    oView:=FwViewActive()
EndIf
If !Empty(oView) 
    oViewHead := oView:GetViewObj("RU06D05_VHEAD")[3]
    If !Empty(oViewHead)
        oViewHead:Refresh(.T.,.F.)
    EndIf
EndIf

if nLine>0
    oModelF4A:GoLine(nLine)
EndIf
Return (NIL)

/*/{Protheus.doc} RU06D0539_OkToUnDelete
checks if line can be undeleted
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0539_OkToUnDelete(nLine)
Local lRet as Logical
Local lFilReq as Logical
Local lCurrErr as Logical
Local lSuppErr as Logical
Local lPrePayErr as Logical
Local cCurrF4A as Character
Local cSuppF4A as Character
Local nQtyAPs as Numeric
Local nQtyActAPs as Numeric
Local oModel as Object
Local aArea  as Array
lRet:=.T.
lCurrErr:=.F.
lFilReq:=.F.
aArea:=GetArea()


F47->(DbSetOrder(1))

If Empty(FwFldGet("F49_FILREQ"))
    lFilReq:=.T.
ElseIf  (!F47->(DbSeek(FwFldGet("F49_FILREQ")+FwFldGet("F4A_CODREQ",nLine))))
	Help("",1,STR0053,,STR0088,1,0,,,,,,{STR0090}) //'Not allowed to undelete line-- Branch - A payment Order can not have payment request from different branches
	lRet:=.F. 
Endif 


cCurrF4A:=POSICIONE("F47",1,FwFldGet("F4A_FILREQ",nLine)+FwFldGet("F4A_CODREQ",nLine),"F47_CURREN")
If cCurrF4A!= FwFldGet("F49_CURREN") .and. alltrim(cCurrF4A)!=''
	lCurrErr:=.T.
EndIf
If lCurrErr
	lRet:=.F.
	Help("",1,STR0053,,STR0050,1,0,,,,,,{STR0054}) //'Not allowed to undelete line-- Currency - Currency of payment order should be same as currency of each request included
EndIf

lSuppErr:=.F.
cSuppF4A:=POSICIONE("F47",1,FwFldGet("F4A_FILREQ",nLine)+FwFldGet("F4A_CODREQ",nLine),"F47_SUPP")+POSICIONE("F47",1,FwFldGet("F4A_FILREQ",nLine)+FwFldGet("F4A_CODREQ",nLine),"F47_UNIT")
If cSuppF4A!= FwFldGet("F49_SUPP")+FwFldGet("F49_UNIT") .and. alltrim(cSuppF4A)!=''
	lSuppErr:=.T.
EndIf
If lSuppErr
	lRet:=.F.
	Help("",1,STR0053,,STR0072,1,0,,,,,,{STR0073}) //'Not allowed to undelete line -- Error in supplier code -- Supplier code of PO must match supplier code of each PR attached
EndIf

lPrePayErr:=.F.
oModel:=FwModelActive()
nQtyAPs := oModel:GetModel("RU06D05_MF4B"):Length()
nQtyActAPs:= oModel:GetModel("RU06D05_MF4B"):Length(.T.)
if nQtyAPs>0 .and. FwFldGet("F49_PREPAY")=='1' .and. nQtyActAPs == 0
    lPrePayErr:=.T.
EndIf
If lPrePayErr
	lRet:=.F.
	Help("",1,STR0053,,STR0074,1,0,,,,,,{STR0075}) //'Not allowed to undelete line -- Currency - Currency of payment order should be same as currency of each request included
EndIf

If lRet .and. lFilReq
   FwFldPut("F49_FILREQ", FwFldGet("F4A_FILREQ",nLine),,,,.T.)
Endif
RestArea(aArea)
Return (lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0542_SortF4A
Internal Function to order the F4A grid in the moment that we add the accounts payables
@type function
@author eduardo.FLima
@since 11/07/2018
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function RU06D0542_SortF4A(oGrid,nDest)
Local lRet as Logical
Local cFrom as Char
Local cTo as Char
Local nOrig as Numeric

Default nDest :=  1 

lRet := .F.    

cFrom := oGrid:GetValue('F4A_FILIAL') + oGrid:GetValue('F4A_CODREQ')  
nOrig := oGrid:GetLine()
oGrid:GoLine(nDest)
cTo  := oGrid:GetValue('F4A_FILIAL') + oGrid:GetValue('F4A_CODREQ')

While cFrom !=   cTo    
    If cFrom < cTo 
        oGrid:LineShift( nOrig, nDest)
        lRet := .T.
        oGrid:GoLine(nOrig)
        RU06D0542_SortF4A(oGrid,nDest)
        cFrom := oGrid:GetValue('F4A_FILIAL') + oGrid:GetValue('F4A_CODREQ')  
    Else 
        nDest := nDest + 1 
        oGrid:GoLine(nDest)
        cTo  := oGrid:GetValue('F4A_FILIAL') + oGrid:GetValue('F4A_CODREQ') 
    Endif
Enddo 

Return (lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0544_EmptyModel
Checks if the model is empty
i.e. there are no active lines (active = not deleted and control field has some value) 
@type function
@author natalia.khozyainova
@since 17/09/2018
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function RU06D0544_EmptyModel(oSubModel as Object, cFieldName as Character, nLine as Numeric)
Local lRet      as Logical
Local nX        as Numeric
Local nQtyLns   as Numeric

Default cFieldName:=""
Default nLine:=0
lRet:=.F.
nQtyLns:=0


If ValType(oSubModel)=='O'
    For nX := 1 To oSubModel:Length()
        oSubModel:GoLine(nX)
        if !(oSubModel:IsDeleted() )
            if Valtype(cFieldName)=='C' .and. oSubModel:GetStruct():HasField(cFieldName) .and. !Empty(oSubModel:GetValue(cFieldName))
                nQtyLns++
            ElseIf Valtype(cFieldName)!='C' .or. !oSubModel:GetStruct():HasField(cFieldName)
                nQtyLns++
            EndIf
        EndIf
    Next nX
EndIf

If nQtyLns==0
    lRet:=.T.
EndIf

if nLine>0
    oSubModel:GoLine(nLine)
EndIf

Return (lRet)


Static Function RU06D0545_PutSuppAcc()
Local oModel as Object 
Local oModelF49 as Object 
Local oModelF4A as Object 
Local nPos as Numeric
Local nX as Numeric
Local nLine1 as Numeric

oModel:=FwModelActive()
If ValType(oModel)=='O'

    oModelF49:=oModel:GetModel("RU06D05_MF49")
    oModelF4A:=oModel:GetModel("RU06D05_MF4A")
    nPos:=oModelF4A:GetLine()
    nLine1:=0
    nX:=1
    while nX<=oModelF4A:Length() .and. nLine1==0
        oModelF4A:GoLine(nX)
        if !(oModelF4A:IsDeleted()) .and. !Empty(oModelF4A:GetValue("F4A_CODREQ")) 
            nLine1:=nX
        Endif
        nX++
    EndDo

    if nLine1>0
        oModelF49:LoadValue("F49_BNKREC",POSICIONE("F47",1,oModelF49:GetValue("F49_FILREQ")+oModelF4A:GetValue("F4A_CODREQ",nLine1),"F47_BNKCOD"))
        oModelF49:LoadValue("F49_RECBIK",POSICIONE("F47",1,oModelF49:GetValue("F49_FILREQ")+oModelF4A:GetValue("F4A_CODREQ",nLine1),"F47_BIK"))
        oModelF49:LoadValue("F49_RECACC",POSICIONE("F47",1,oModelF49:GetValue("F49_FILREQ")+oModelF4A:GetValue("F4A_CODREQ",nLine1),"F47_ACCNT"))
        oModelF49:LoadValue("F49_RECNAM",POSICIONE("F47",1,oModelF49:GetValue("F49_FILREQ")+oModelF4A:GetValue("F4A_CODREQ",nLine1),"F47_RECNAM"))
    EndIf

    if nPos>0
        oModelF4A:GoLine(nPos)
    Endif
EndIf


Return (NIL)

Static Function RU06D0546_CheckConUni(oTempTable)
    Local lRet       As Logical
    Local cQuery     As Character
    Local cTab       As Character
    Local aArea      As Array

    lRet := .F.
    aArea := GetArea()
    
    cQuery := " SELECT COUNT (*) AS CNT FROM " + oTempTable:GetRealName()
    cQuery += " INNER JOIN " + RetSQLName("F48") + " AS F48 "
    cQuery += " ON F48.F48_FILIAL=F47_FILIAL AND F48.F48_IDF48 = F47_IDF47 "
    cQuery += " WHERE F48.D_E_L_E_T_ = ' ' "
    cQuery += " AND F48.F48_CONUNI = '1' "
    cQuery += " AND F47_CURREN = '01' "
    cQuery += " AND F47_OK = '" + cMark + "' "

    cQuery    := ChangeQuery(cQuery)
    cTab := MPSysOpenQuery(cQuery)
    
    DbSelectArea(cTab)
    If (cTab)->(CNT) > 0 // there is exist F48_CONUNI field equals '1'
        lRet := .T.
    EndIf
    (cTab)->(DBCloseArea())
    RestArea(aArea)

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0547_CheckCurrency
Checks currency for add new lines
@type function
@param  cCurrPerg   Currency from pergunte
        oModel      Model of program
@author alexandra.velmozhmaya
@since 19/02/2019
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function RU06D0547_CheckCurrency(cCurrPerg, oModel)
Local lRet       As Logical
Local nX         As Numeric
Local oModelHead As Object
Local oModelDet  As Object

oModelHead := oModel:GetModel("RU06D05_MF49")
oModelDet := oModel:GetModel("RU06D05_MF4B")
lRet := .T.

If !Empty(oModelHead:GetValue("F49_CNT")) .and. oModelHead:GetValue("F49_CURREN") <> cCurrPerg
    lRet := .F.
EndIf

If lRet .and. (oModelDet:Length() >= 1 .and. !Empty(oModelDet:GetValue("F4B_CURREN", 1)) )
    For nX := 1 to oModelDet:Length()
        oModelDet:GoLine(nX)
        If (oModelDet:GetValue("F4B_CURREN") <> Val(cCurrPerg)) .and. !(oModelDet:GetValue("F4B_CONUNI") == "1" .and. cCurrPerg == "01")
            lRet := .F.
            Exit
        EndIf
    Next nX
EndIf

Return (lRet)

/*/{Protheus.doc} RU06D0548_GatForn
This function assigned to the triggers
for F49_SUPP and F49_UNIT fields. When we input
F49_SUPP or F49_UNIT fields we fill information about
supplier like supplier name, KPP and bank info.
@author astepanov
@since 18 August 2020
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0548_GatForn(cField)
    Local  cRet As Character
    Local  aArea     As Array
    Local  aAreaSA2  As Array
    Local  aAreaFIL  As Array
    aArea    := GetArea()
    aAreaSA2 := SA2->(GetArea())
    cRet     := ""
    If     cField == "F49_UNIT"
        cRet := Posicione("SA2",1,xFilial("SA2")+FwFldGet("F49_SUPP"),"A2_LOJA")
    ElseIf cField == "F49_SUPNAM"
        cRet := Posicione("SA2",1,xFilial("SA2")+FwFldGet("F49_SUPP")+FwFldGet("F49_UNIT"),"A2_NOME")
    ElseIf cField == "F49_KPPREC"
        cRet := Posicione("SA2",1,xFilial("SA2")+FwFldGet("F49_SUPP")+FwFldGet("F49_UNIT"),"A2_KPP")
        aAreaFIL := FIL->(GetArea())
        //fill bank account data from FIL table
        RU06D0528_PutFil()
        RestArea(aAreaFIL)
    EndIf
    cRet := PADR(cRet,GetSX3Cache(cField,"X3_TAMANHO"," "))
    RestArea(aAreaSA2)
    RestArea(aArea)
Return cRet
