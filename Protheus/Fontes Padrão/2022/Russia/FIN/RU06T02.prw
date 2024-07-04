#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU06T02.CH"

#DEFINE PR_STATUS_CREATED "1"
#DEFINE PR_STATUS_APPROVED "2"
#DEFINE PR_STATUS_REJECTED "3"
#DEFINE PR_STATUS_CANCELLED "4"
#DEFINE PR_STATUS_IMPLEMENTED "5"
#DEFINE MODEL_OPERATION_COPY 9

/*{Protheus.doc} RU69T01RUS
@author Anna Fedorova
FI-CF-25-18
Russia R7
List of Payments. Table F60. */
//----------------------------------------------
Function RU06T02()
Local oBrowse   as Object
dbSelectArea("F60")
oBrowse :=  FWLoadBrw("RU06T02")
oBrowse:Activate()
Return

/*{Protheus.doc} BrowseDef
@author Anna Fedorova*/
//----------------------------------------------
Static Function BrowseDef()
Local oBrowse as OBJECT
Private aRotina as ARRAY

oBrowse := FWMBrowse():New()
oBrowse:SetDescription(STR0017)
oBrowse:SetMenuDef("RU06T02")

oBrowse:SetDoubleClick({||RU06T0219_Act(1)})
oBrowse:AddLegend('F60_STATUS == "' + PR_STATUS_CREATED + '"', "WHITE", STR0002)  // 1 - Created
oBrowse:AddLegend('F60_STATUS == "' + PR_STATUS_APPROVED + '"', "GREEN", STR0003)  // 2 - Approved
oBrowse:AddLegend('F60_STATUS == "' + PR_STATUS_REJECTED + '"', "RED",   STR0004)  // 3 - Rejected
oBrowse:AddLegend('F60_STATUS == "' + PR_STATUS_CANCELLED + '"', "YELLOW",STR0005)  // 4 - Cancelled
oBrowse:AddLegend('F60_STATUS == "' + PR_STATUS_IMPLEMENTED + '"', "BLUE",  STR0006)  // 5 - Implemented
oBrowse:SetAlias("F60")

Return oBrowse



/*{Protheus.doc} MenuDef
@author Anna Fedorova*/
//----------------------------------------------
Static Function MenuDef()
Local aRotina as Array

aRotina := {}
ADD OPTION aRotina TITLE STR0007     ACTION "RU06T0219_Act(1)"   OPERATION MODEL_OPERATION_VIEW ACCESS 0   // View
ADD OPTION aRotina TITLE STR0008     ACTION "RU06T0219_Act(3)"   OPERATION MODEL_OPERATION_INSERT ACCESS 0   // Add
ADD OPTION aRotina TITLE STR0009     ACTION "RU06T0219_Act(4)"   OPERATION MODEL_OPERATION_UPDATE ACCESS 0   // Edit
ADD OPTION aRotina TITLE STR0010     ACTION "RU06T0219_Act(5)"   OPERATION MODEL_OPERATION_DELETE ACCESS 0   // Delete
ADD OPTION aRotina TITLE STR0011     ACTION "RU06T0219_Act(9)"   OPERATION 10 ACCESS 0   // Copy
ADD OPTION aRotina TITLE STR0013     ACTION "RU06T0201_Legenda()"      OPERATION 7 ACCESS 0   // Legend
ADD OPTION aRotina TITLE STR0064     ACTION "RU06T0290_GenPayOrd()"      OPERATION MODEL_OPERATION_UPDATE ACCESS 0   // PayOrd generate
If  SuperGetMv("MV_REQAPR",, 0)  = 1 //If the user status allows you to change the status of the payment list, additional buttons are added.
    ADD OPTION aRotina Title STR0081   ACTION "RU06T0214_AVISO_Approve()"     OPERATION 7 ACCESS 0     //"Approve"
    ADD OPTION aRotina Title STR0082    ACTION "RU06T0215_AVISO_Reject()"    OPERATION 7 ACCESS 0      //"Reject"
    ADD OPTION aRotina Title STR0012    ACTION "RU06T0224_AVISO_Cancel()"    OPERATION 7 ACCESS 0      //"Cancel"
Endif
Return (aRotina)


/*{Protheus.doc} ViewDef
@author Anna Fedorova*/
//----------------------------------------------
Static Function ViewDef()

Local oModel  as object
Local oStruct  as object
Local oStrVirt  as object
Local oView  as object
Local oStrF5M as Object // Temporary table
Local nOperation as Object

oModel  := FWLoadModel("RU06T02")
oStruct := FWFormStruct(2,"F60",/*bAvalCampo*/,/*lViewUsado*/)
oStrVirt  := RU06T0202_DefVirtViewStr(.T.)
oView := FWFormView():New()
nOperation := oModel:GetOperation()

oView:SetDescription(STR0017)
oView:SetModel(oModel)
oView:AddField("F60", oStruct, "RU06T02_MHEAD")
oStruct:RemoveField("F60_IDF60")

oView:AddGrid( 	'RU06T02_MVIRT', oStrVirt, 'RU06T02_MVIRT')
//Double click, depending on the user's choice, opens requests For payment or payment orders
oView:SetViewProperty("RU06T02_MVIRT", "GRIDDOUBLECLICK", {{|oFormula, cFieldName, nLineGrid, nLineModel | RU06T0212_2Click(oFormula, cFieldName, nLineGrid, nLineModel )}})
oView:CreateHorizontalBox( 'SUPERIOR' , 40 )
oView:CreateHorizontalBox( 'INFERIOR' , 60 )

oView:SetOwnerView('RU06T02_MHEAD','SUPERIOR')
oView:SetOwnerView('RU06T02_MVIRT','INFERIOR')

oView:SetViewProperty("RU06T02_MVIRT", "GRIDFILTER", {.T.})
oView:SetViewProperty("RU06T02_MVIRT", "GRIDSEEK", {.T.})
Return oView



/*{Protheus.doc} ModelDef
@author Anna Fedorova
@since 04/22/2019*/
//----------------------------------------------
Static Function ModelDef()

Local oStruct as object
Local oStrVirt as object
Local oStruF60  as object
Local oModel    as object
Local oSaveF5M  as object

oStruF60    := FWFormStruct(1, "F60")
oModel      := MPFormModel():New("RU06T02")
oSaveF5M	:= RU06T02EventRUS():New()

oModel:SetDescription(STR0001)
oStruF60:SetProperty("F60_IDF60", MODEL_FIELD_INIT, {|| FWUUIDV4(.F.) }  )
oModel:AddFields("RU06T02_MHEAD", NIL, oStruF60)
oModel:GetModel("RU06T02_MHEAD"):SetDescription(STR0017) // Bank Statement head submodel
oModel:GetModel("RU06T02_MHEAD"):SetFldNoCopy({"F60_FILIAL","F60_IDF60","F60_DTLIS","F60_CODREC","F60_STATUS"})

// Items structure - F5M - Lines Real Hidden Grid
oStrF5M := FWFormStruct(1, "F5M")
oModel:AddGrid("RU06T02_MLNS", "RU06T02_MHEAD", oStrF5M)
oModel:GetModel("RU06T02_MLNS"):SetDescription("BSModel_LinesF5M")
oModel:GetModel('RU06T02_MLNS'):SetOptional(.T.)
oModel:SetRelation("RU06T02_MLNS", {{ "F5M_FILIAL", "xFilial('F5M')" }, { "F5M_IDDOC", "F60_IDF60", } }, F5M->( IndexKey( 1 ) ) )
oModel:GetModel("RU06T02_MLNS"):SetFldNoCopy(RU06D0540_Array(oModel:GetModel("RU06T02_MLNS")))

oStrVirt := RU06t0218_DefVirtStr()
oModel:AddGrid("RU06T02_MVIRT", "RU06T02_MHEAD", oStrVirt, /*bPreValid*/, /*bPosValid*/	,,, {|oModel|RU06T0211_VirtGridLoad(oModel)}/*bLoad*/ )

oModel:GetModel("RU06T02_MVIRT"):SetDescription("Virtual Grid")
oModel:GetModel('RU06T02_MVIRT'):SetOptional(.T.)
oModel:GetModel('RU06T02_MVIRT'):SetNoInsertLine(.T.)
oModel:GetModel("RU06T02_MVIRT"):SetFldNoCopy(RU06D0540_Array(oModel:GetModel("RU06T02_MVIRT")))

oModel:InstallEvent("RU06T02_Event"	,,oSaveF5M)

Return oModel


//========================================================================================================
//the functions below are used in the metadata
//--------------------------------------------------------------------------------------------------------
Function RU06T02001()
    // from RU06D04.prw
    // R609VldCur
    Local lRet      as Logical

    lRet:= ExistCpo("CTO",FwFldGet("F60_CURREN")) .and. RU06XFUN26_CheckCurrHeadLines()
    If lRet
        FwFldPut("F60_CURNAM",POSICIONE("CTO",1,xFilial("CTO")+FwFldGet("F60_CURREN"),"CTO_DESC"),,,,.T.)
    Else
        Help("",1,STR0048,,STR0049,1,0,,,,,,{STR0050})
    Endif
Return (lRet)

/*/
{Protheus.doc} RU06T02002()
Function called at valid of bank field, resposable to filled or clear bank information
functions located in x3_relacao
@author rafael.goncalves
@since fev|2020
@version 1.0
@project MA3 - Russia
/*/
Function RU06T02002()
Local lRet as Logical
Local aArray as Array
aArray:={"F60_BKPNAM","F60_ACPNAM","F60_PAYNAM", "F60_CURREN"}
lRet := .T.
If (Empty(FwFldGet("F60_BNKPAY")))
    RU06XFUN01_CleanFlds(aArray)
Else
    // bank account info validation
    lRet:=RU06XFUN05_VldSA6(FwFldGet("F60_CURREN"), FwFldGet("F60_BNKPAY"), FwFldGet("F60_PAYBIK"), FwFldGet("F60_PAYACC"), aArray)
Endif
Return (lRet)
//--------------------------------------------------------------------------------------------------------
//this function return the initial value For the account name and account name fields (F60_BNKNAM,F60_PAYNAM)
Function RU06T02003(nNum)
Local cRet as Character
cRet := RU06XFUN03_ShwSA6(nNum, FwFldGet("F60_BNKPAY"), FwFldGet("F60_PAYBIK"),  FwFldGet("F60_PAYACC"))
Return (cRet)
//--------------------------------------------------------------------------------------------------------
//this function return the initial value For the account name and account name fields (F60_BNKNAM,F60_PAYNAM)
// for browser
Function RU06T020B3(nNum)
Local cRet as Character
cRet := RU06XFUN03_ShwSA6(nNum, F60->F60_BNKPAY, F60->F60_PAYBIK,  F60->F60_PAYACC)
Return (cRet)
//--------------------------------------------------------------------------------------------------------
Function RU06T02004()
//This function is used in the standard query in pergunt RU06D09 as a filter For selecting payment requests
Local cStatus as character
Local lRet as logical

lRet := .F.
cStatus:=F47->F47_STATUS
If cStatus == PR_STATUS_CANCELLED
    lRet := .T.
Endif

Return lRet
//--------------------------------------------------------------------------------------------------------
Function RU06T02005()
//This function is used in the standard query in pergunt RU06D09 as a filter For selecting contracts
Return .T.
//--------------------------------------------------------------------------------------------------------

//This function is used in a validation of F60_DTPAYM.
//Every time when the user changes the planned payment date, the values in conventional units in the F47 table are recalculated.
Function RU06T02006()

Local oModel        as Object
Local oModelF60     as Object
Local oModelVirt    as Object
Local oModelPR      as object
Local nValue        as numeric
Local oView         as Object


oModel      := FwModelActive()
oModelF60   := oModel:GetModel("RU06T02_MHEAD")
oModelVirt  := oModel:GetModel("RU06T02_MVIRT")
oView        := FWViewActive()
F47->(dbSetOrder(1))

If F47->(DbSeek(oModelVirt:GetValue("B_FILIAL")+oModelVirt:GetValue("B_CODREQ")))
    //recalculate values in payment requests if they are in convencional units
    oModelPR:= FwLoadModel("RU06D04")
    oModelPR:SetOperation(MODEL_OPERATION_UPDATE)
    RU06D0401_RecalcCurrency(.T., @oModelPR, 1, oModelF60:GetValue("F60_DTPLA") )
    oModelPR:Activate()

    //download refreshed value in a virtual grid
    nValue := oModelPR:GetModel("RU06D04_MHEAD"):GetValue("F47_VALUE")
    oModelVirt:LoadValue("B_VALUE",nValue)
    oModelPR:DeActivate()

    If ValType(oView) == "O" .And. oView:IsActive()
        oView:Refresh()
    EndIf

Endif
Return .T.


/*{Protheus.doc} RU06T0201_Legenda
@author Anna Fedorova
@since 04/22/2019*/
//----------------------------------------------
Function RU06T0201_Legenda()
Local aRet as Array
aRet:={}

aAdd(aRet,{ "BR_BRANCO",    STR0002 })         // WHITE = 1 - Created
aAdd(aRet,{ "BR_VERDE",     STR0003 })         // GREEN = 2 - Approved
aAdd(aRet,{ "BR_VERMELHO",  STR0004 })         // RED   = 3 - Rejected
aAdd(aRet,{ "BR_AMARELO",   STR0005 })         // YELLOW= 4 - Cancelled
aAdd(aRet,{ "BR_AZUL",      STR0006 })         // BLUE  = 5 - Implemented
BrwLegenda(STR0017, ;// Description of Model and Browse
           STR0013, ;// Description of according Menu Action
           aRet)
Return (aRet)




/*View structure For
 grid - All Payment Requests
{Protheus.doc} RU06T0202_DefVirtViewStr
@author Anna Fedorova
@since 04/22/2019*/
Function RU06T0202_DefVirtViewStr(lBS as Logical)
Local oStruct 	as Object
Default lBS:=.F.


oStruct 	:= 	FWFormViewStruct():New()
//                  ID      Order           Titulo          Descrip                 Help Type    Pict                           bPictVar LookUp CanCh  Ider cGroup Combo MaxLenCombo IniBrw, lVirt PicVar
oStruct:AddField("B_FILIAL"	,"01"	,RetTitle("F47_FILIAL")	,RetTitle("F47_FILIAL")	,NIL ,"C"	,PesqPict("F47","F47_FILIAL" )	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.)
oStruct:AddField("B_PAYTYP"	,"02"	,RetTitle("F47_PAYTYP")	,RetTitle("F47_PAYTYP")	,NIL ,"C"	,PesqPict("F47","F47_PAYTYP" )	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.)
oStruct:AddField("B_CODREQ"	,"03"	,RetTitle("F47_CODREQ")	,RetTitle("F47_CODREQ")	,NIL ,"C"	,PesqPict("F47","F47_CODREQ") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.)
oStruct:AddField("B_DTREQ"	,"04"	,RetTitle("F47_DTREQ")	,RetTitle("F47_DTREQ")	,NIL ,"D"	,PesqPict("F47","F47_DTREQ") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.)
oStruct:AddField("B_DTPLAN"	,"05"	,RetTitle("F47_DTPLAN")	,RetTitle("F47_DTPLAN")	,NIL ,"D"	,PesqPict("F47","F47_DTPLAN") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.)
oStruct:AddField("B_SUPP"	,"06"	,RetTitle("F47_SUPP")	,RetTitle("F47_SUPP")	,NIL ,"C"	,PesqPict("F47","F47_SUPP") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.)
oStruct:AddField("B_UNIT"	,"07"	,RetTitle("F47_UNIT")	,RetTitle("F47_UNIT")	,NIL ,"C"	,PesqPict("F47","F47_UNIT") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.)
oStruct:AddField("B_SUPNAM"	,"08"	,RetTitle("F47_SUPNAM") ,RetTitle("F47_SUPNAM") ,NIL ,"C",  PesqPict("F47","F47_SUPNAM")	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.)
oStruct:AddField("B_CLASS"	,"09"	,RetTitle("F47_CLASS")	,RetTitle("F47_CLASS")	,NIL ,"C"	,PesqPict("F47","F47_CLASS") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.)
oStruct:AddField("B_PAYORD"	,"10"	,RetTitle("F47_PAYORD")	,RetTitle("F47_PAYORD")	,NIL ,"C"	,PesqPict("F47","F47_PAYORD") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.)
oStruct:AddField("B_DTPAYM"	,"11"	,RetTitle("F47_DTPAYM") ,RetTitle("F47_DTPAYM") ,NIL ,"D",  PesqPict("F47","F47_DTPAYM")    ,NIL ,''	,   .F.   ,''	,''		,{}	,0	,''		,.F.)
oStruct:AddField("B_VALUE"	,"12"	,RetTitle("F47_VALUE")	,RetTitle("F47_VALUE")	,NIL ,"N"	,PesqPict("F47","F47_VALUE") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.)
oStruct:AddField("B_REASON"	,"13"	,RetTitle("F47_REASON") ,RetTitle("F47_REASON") ,NIL ,"C",  PesqPict("F47","F47_REASON")	,NIL ,''	,   .T.	  ,''	,''		,{}	,0	,''		,.T.)
oStruct:AddField("B_VRSN"	,"14"	,RetTitle("F47_VRSN"  ) ,RetTitle("F47_VRSN"  ) ,NIL ,"C",  PesqPict("F47","F47_VRSN"  ) 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.)
oStruct:AddField("B_CNT"	,"15"	,RetTitle("F47_CNT")	,RetTitle("F47_CNT")	,NIL ,"C"	,PesqPict("F47","F47_CNT")		,NIL ,''	,   .F.   ,''	,''		,{}	,0	,''		,.F.)
oStruct:AddField("B_F5QDES"	,"16"	,RetTitle("F47_F5QDES") ,RetTitle("F47_F5QDES") ,NIL ,"C",  PesqPict("F47","F47_F5QDES")	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.)

Return (oStruct)




/*Called from user button - Pick up Payment Requests
{Protheus.doc} RU06T0203_AddReqs
@author Anna Fedorova
@since 04/22/2019*/
//there are some st.init. For pergunta
//----------------------------------------------
Function RU06T0203_AddReqs()
Local oModel as Object

oModel:= FWModelActive()
cPerg := "RU06D09"
    // Update initial Ranges in Group of Questions:
If !Empty(FwFldGet("F60_CURREN"))
    // in case when user has 'last values' from pergunta stored in system table
    SetMVValue(cPerg,"MV_PAR11",FwFldGet("F60_CURREN"))
    RU06T0208_UpdPerg(cPerg, "MV_PAR11", FwFldGet("F60_CURREN"))
Endif

If !Empty(FwFldGet("F60_FILIAL"))
    RU06T0208_UpdPerg(cPerg, "MV_PAR10", FwFldGet("F60_FILIAL"))
    // in case when user has 'last values' from pergunta stored in system table
    SetMVValue(cPerg,"MV_PAR10",FwFldGet("F60_FILIAL"))
    RU06T0208_UpdPerg(cPerg, "MV_PAR09", FwFldGet("F60_FILIAL"))
    // in case when user has 'last values' from pergunta stored in system table
    SetMVValue(cPerg,"MV_PAR09",FwFldGet("F60_FILIAL"))
Else
    RU06T0208_UpdPerg(cPerg, "MV_PAR10", xFilial("F60"))
    // in case when user has 'last values' from pergunta stored in system table
    SetMVValue(cPerg,"MV_PAR10",xFilial("F60"))
    RU06T0208_UpdPerg(cPerg, "MV_PAR09", xFilial("F60"))
    // in case when user has 'last values' from pergunta stored in system table
    SetMVValue(cPerg,"MV_PAR09",xFilial("F60"))
Endif

lRet:= Pergunte(cPerg,.T.,STR0019,.F.) // Group of questions
If lRet
    RU06T0204_MBrowse()
    RU06T0223_Write_values()
Endif
Return (Nil)




//Mbrowse use temporary table with data from f47 table
/* @author Anna Fedorova
@since 04/22/2019 */
//structure For mBrowse
//----------------------------------------------
Static Function RU06T0204_MBrowse()
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

nX:=0
cTempTbl	:= CriaTrab(,.F.)
aStr	:= {}
aColumns 	:= {}
aSize	:= MsAdvSize()
cTitle:=""

// Create temporary table
MsgRun(STR0020,STR0021,{|| RU06T0205_CreateTable()}) //"Please wait"//"Creating temporary table"

If ((cTempTbl)->(Eof()))
    Help("",1,STR0022,,STR0023,1,0,,,,,,{STR0024}) // No requests found -- Pick Up PRs --Please, check parameters of the request
Else
    aAdd( aStr, {"F47_FILIAL"	,RetTitle("F47_FILIAL") , PesqPict("F47","F47_FILIAL")})
    aAdd( aStr, {"F47_CODREQ"	,RetTitle("F47_CODREQ") , PesqPict("F47","F47_CODREQ")})
    aAdd( aStr, {"F47_DTREQ"	,RetTitle("F47_DTREQ")  , PesqPict("F47","F47_DTREQ")})
    aAdd( aStr, {"F47_DTPLAN"	,RetTitle("F47_DTPLAN") , PesqPict("F47","F47_DTPLAN")})
    aAdd( aStr, {"F47_PREPAY"	,RetTitle("F47_PREPAY") , PesqPict("F47","F47_PREPAY")})
    aAdd( aStr, {"F47_BNKCOD"	,RetTitle("F47_BNKCOD") , PesqPict("F47","F47_BNKCOD")})
    aAdd( aStr, {"F47_CNT"	    ,RetTitle("F47_CNT")    , PesqPict("F47","F47_CNT")})
    aAdd( aStr, {"F47_CLASS"	,RetTitle("F47_CLASS")  , PesqPict("F47","F47_CLASS")})
    aAdd( aStr, {"F47_CURREN"	,RetTitle("F47_CURREN") , PesqPict("F47","F47_CURREN")})
    aAdd( aStr, {"F47_VALUE"	,RetTitle("F47_VALUE")  , PesqPict("F47","F47_VALUE")})
    aAdd( aStr, {"F47_PAYORD"	,RetTitle("F47_PAYORD") , PesqPict("F47","F47_PAYORD")})
	aAdd( aStr, {"F47_PAYTYP"	,RetTitle("F47_PAYTYP") , PesqPict("F47","F47_PAYTYP")})
    aAdd( aStr, {"F47_DTPAYM"	,RetTitle("F47_DTPAYM") , PesqPict("F47","F47_DTPAYM")})

    For nX := 1 TO  11
        cTitle:=aStr[nX][1]
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||"+aStr[nX][1]+"}") )
        aColumns[Len(aColumns)]:SetTitle(aStr[nX][2])

        If cTitle!="F47_VRSN"
            aColumns[Len(aColumns)]:SetSize(TamSx3(cTitle)[1])
            aColumns[Len(aColumns)]:SetDecimal(TamSx3(cTitle)[2])
        Else
            aColumns[Len(aColumns)]:SetSize(40)
            aColumns[Len(aColumns)]:SetDecimal(0)
        Endif
        aColumns[Len(aColumns)]:SetPicture(aStr[nX][3])
        aColumns[Len(aColumns)]:SetAlign( If(TamSx3(cTitle)[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//set aligny

    Next nX

    oMoreDlg := MsDialog():New( aSize[7], aSize[2], aSize[6], aSize[5],STR0025, , , , , CLR_BLACK, CLR_WHITE, , , .T., , , , .T.) // Payment Requests available
    //MarkBrowse
    oBrowsePut := FWMarkBrowse():New()
    oBrowsePut:SetFieldMark("F47_OK")
    oBrowsePut:SetOwner(oMoreDlg)
    oBrowsePut:SetAlias(cTempTbl)
    aRotina	 := RU06T0206_MBROWSEMENU() //Reset global aRotina
    oBrowsePut:SetColumns(aColumns)
    oBrowsePut:bAllMark := {||MarkAll(oBrowsePut, cTempTbl)}
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
    Endif

    If oTempTable <> Nil
        oTempTable:Delete()
        oTempTable := Nil
    Endif
Endif
aRotina	 := MenuDef() //Return aRotina
return (.T.)



/*/{Protheus.doc} RU06T0205_CreateTable
Create temporary table For markbrowse or selected information for copy
@author Anna.Fedorova
@since N/A - Refactored 17/02/2020 - Rafael Goncalves
@version 1.0
@project MA3 - Russia
/*/
Static Function RU06T0205_CreateTable(lCopy as Logical, aFilF47 as Array)
Local aFields   as Array
Local cQuery    as Character
Local cQuery1   as Character
Local oModel    as Object
Local oModelF5M as Object
Local nX        as Numeric
Local cMvpar01  as character
Local cMvpar02  as character
Local cFilters  as Character

Default lCopy := .F.
Default aFilF47 := {}

/* Object creation*/
oTempTable := FWTemporaryTable():New(cTempTbl)
oModel:=FWModelActive()

If !lCopy
    cMvpar01 := DTOS(MV_PAR01)
    cMvpar02 := DTOS(MV_PAR02)
Endif
oModelF5M:=oModel:GetModel("RU06T02_MLNS")

// TMP Table fields - structure
aFields := {}
aadd(aFields,{"F47_OK"		, "C", 1,   00})
aadd(aFields,{"F47_FILIAL"	, "C", TamSX3("F47_FILIAL")[1]  ,00 })
aadd(aFields,{"F47_CODREQ"	, "C", TamSX3("F47_CODREQ")[1]  ,00 })
aadd(aFields,{"F47_DTPLAN"	, "D", TamSX3("F47_DTPLAN")[1]  ,00 })
aadd(aFields,{"F47_PREPAY"	, "C", TamSX3("F47_PREPAY")[1]  ,00 })
aadd(aFields,{"F47_BNKCOD"	, "C", TamSX3("F47_BNKCOD")[1]  ,00 })
aadd(aFields,{"F47_CNT"	    , "C", TamSX3("F47_CNT")[1]     ,00 })
aadd(aFields,{"F47_CLASS"	, "C", TamSX3("F47_CLASS")[1]   ,00 })
aadd(aFields,{"F47_VALUE"	, "N", TamSX3("F47_VALUE")[1]   ,TamSX3("F47_VALUE")[2]})
aadd(aFields,{"F47_PAYORD"	, "C", TamSX3("F47_PAYORD")[1]  ,00 })
aadd(aFields,{"F47_IDF47"	, "C", TamSX3("F47_IDF47")[1]   ,00 })
aadd(aFields,{"F47_CURREN"  , "C", TamSX3("F47_CURREN")[1]  ,00 })
aadd(aFields,{"F47_DTREQ"	, "D", TamSX3("F47_DTREQ")[1]   ,00 })
aadd(aFields,{"F47_SUPP"    , "C", TamSX3("F47_SUPP")[1]    ,00 })
aadd(aFields,{"F47_UNIT"    , "C", TamSX3("F47_UNIT")[1]    ,00 })
aadd(aFields,{"F47_PAYTYP"  , "C", TamSX3("F47_PAYTYP")[1]  ,00 })
aadd(aFields,{"F47_DTPAYM"	, "D", TamSX3("F47_DTPAYM")[1]  ,00 })

oTemptable:SetFields(aFields)
oTempTable:AddIndex("Indice1", {"F47_DTPLAN","F47_FILIAL","F47_CODREQ"} )
oTempTable:Create()

cQuery := "INSERT INTO " + oTempTable:GetRealName()
cQuery += " (F47_OK, F47_FILIAL, F47_CODREQ, F47_DTPLAN, F47_PREPAY, F47_BNKCOD, F47_CNT, F47_CLASS, F47_VALUE, F47_PAYORD, F47_IDF47, F47_CURREN )"
cQuery += " SELECT '0' AS F47_OK, F47_FILIAL, F47_CODREQ, F47_DTPLAN, F47_PREPAY, F47_BNKCOD, F47_CNT, F47_CLASS, F47_VALUE, F47_PAYORD, F47_IDF47, F47_CURREN "
cQuery += " FROM " + RetSQLName("F47") + " F47 "
cQuery += " WHERE F47.D_E_L_E_T_ =' ' AND F47_PAYTYP='1' AND F47_PAYORD = ' '"
//Check status of Payment Request, when the PR are used at Payment order the status is change
If  SuperGetMv("MV_REQAPR",, 0)  = 1 //If the user status allows you to change the status of the payment request
    cQuery += " AND F47.F47_STATUS ='4' " //check is status is approved
else
    cQuery += " AND F47.F47_STATUS ='1' " //check is status is create
Endif

If !lCopy // not copyed
    cQuery += " AND F47_DTPLAN >= '"+ cMvpar01 + "' AND F47_DTPLAN <= '"+ cMvpar02 + "'"
    cQuery += " AND F47_CLASS BETWEEN '"+ MV_PAR05 +"' AND '" + MV_PAR06 + "'"                             //class of request
    cQuery += " AND F47_CNT BETWEEN '"+ ALLTRIM(MV_PAR07) +"' AND '" + ALLTRIM(MV_PAR08) + "'"             //contract
    cQuery += " AND F47_CURREN = '"+  MV_PAR11  + "'"
    cQuery += " AND F47_FILIAL BETWEEN '"+ ALLTRIM(MV_PAR09) +"' AND '" + ALLTRIM(MV_PAR10) + "'"
    //Check if thisd Payment request are not used in other list of payments
    cQuery += " AND F47_IDF47 NOT IN ( "
        cQuery += " SELECT F5M_KEY FROM " + RetSQLName("F5M") + " F5M "
        cQuery += "inner join " + RetSQLName("F60") + " F60 on F60.F60_IDF60 = F5M.F5M_IDDOC and F60.D_E_L_E_T_ ='' "
        cQuery += "where F5M_ALIAS = 'F60' " //only list of payments requisitions
        cQuery += "and F5M.D_E_L_E_T_ = ' ' "
        cQuery += "and F60.F60_STATUS in ('1','2','3') AND F5M.D_E_L_E_T_ = '')"
Else //Copy
    cFilters := "( "
    For nX:=1 to len(aFilF47)
        cFilters += Iif(nX>1,",","")+"'"+aFilF47[nX]+"'"
    Next
    cFilters +=")"
    cQuery += " AND F47_IDF47 in "+ cFilters
EndIf
nStatus := TCSqlExec(cQuery)

//Deleting requests For payments that are already included in the list from the temporary table
For nX:=1 to oModelF5M:Length()
    oModelF5M:GoLine(nX)
    cQuery1:= "DELETE FROM " + oTempTable:GetRealName()
    cQuery1+= " WHERE F47_FILIAL ='" +xFilial("F60")  + "'"
    cQuery1+= " AND F47_IDF47 ='" + oModelF5M:GetValue("F5M_KEY")  + "'"
    nStatus := TCSqlExec(cQuery1)
Next nX

DbSelectArea(cTempTbl)
DbGotop()

Return .T.



/* @author Anna Fedorova
RU06T0206_MBROWSEMENU()
@since 04/22/2019 */
//----------------------------------------------
Static Function RU06T0206_MBROWSEMENU()
Local aRet as Array

aRet := {{STR0008,  "RU06T0207_WriteToModel()",  0, 4, 0, Nil},; //Add //	{"CheckWriteFromMbrowse",   "RU06T0210_WriteFromMBr()",  0, 4, 0, Nil},;
		{STR0012,   "RU06D0522_MBrwCancel()",  0, 1, 0, Nil},; //Cancel
        {STR0026,   "RU06D0523_ShowPR()", 0, 1, 0, Nil}}  //Request Details

Return (aRet)


/*/{Protheus.doc} RU06T0207_WriteToModel
This function is reponsable to  writes PRs to the model
@author Anna Fedorova
@since 04/22/2019
@version 1.0
@project MA3 - Russia
/*/
Function RU06T0207_WriteToModel(lCopy)
Local oModelL       as object
Local oModelH       as object
Local oModel        as object
Local oModelVirt    as object
Local oView         as object
Local nItemF        as Numeric
Local cQuery        as Character
Local cTab          as Character
Local cF47Sup       as character
Local dNewDate      as Date
Local nX            as Numeric

Default lCopy := .F.

cF47Sup := ""
aArea   := GetArea()
oModel  := FwModelActive()
oModelH := oModel:GetModel("RU06T02_MHEAD")
omodelL := oModel:GetModel("RU06T02_MLNS")
oModelVirt := oModel:GetModel("RU06T02_MVIRT")

If type('cMark') == 'U' //When is called different than markborwse
    cMark := ''
Endif

DbSelectArea(cTempTbl)
DbGotop()
while !((cTempTbl)->(Eof()))
	If ((cTempTbl)->F47_OK == cMark) .or. lCopy

		cQuery := "SELECT * FROM " + RetSQLName("F47") + " F47 "
		cQuery += "     LEFT JOIN " + RetSQLName("SA2") + " SA2 ON F47.F47_SUPP = SA2.A2_COD AND SA2.D_E_L_E_T_ = ' ' AND A2_FILIAL ='" +xFilial("SA2")  + "'"
        cQuery += "     LEFT JOIN " + RetSQLName("F5Q") + " F5Q ON F47.F47_CNT = F5Q.F5Q_CODE AND F5Q.D_E_L_E_T_ = ' ' AND F5Q_FILIAL ='" +xFilial("F5Q")  + "'"
        cQuery += "     LEFT JOIN " + RetSQLName("F4A") + " F4A ON F47.F47_FILIAL = F4A.F4A_FILIAL AND F47.F47_CODREQ = F4A.F4A_CODREQ AND F4A.D_E_L_E_T_ = ' '"
        cQuery += "     LEFT JOIN " + RetSQLName("F49") + " F49 ON F4A.F4A_FILIAL = F49.F49_FILIAL  AND F4A.F4A_IDF49 = F49.F49_IDF49  AND F49.D_E_L_E_T_ = ' '"
        cQuery += " WHERE F47.F47_FILIAL ='" + (cTempTbl)->F47_FILIAL +"'"
		cQuery += " AND F47.F47_CODREQ ='" + (cTempTbl)->F47_CODREQ +"'"
		cQuery += " AND F47.D_E_L_E_T_ =' ' AND F47.F47_PAYTYP='1' "

        cQuery := ChangeQuery(cQuery)
	    cTab := CriaTrab( , .F.)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.T.,.T.)

	    DbSelectArea((cTab))
	    (cTab)->(DbGoTop())

        If !oModelL:IsEmpty()
            omodelL:SetNoInsertLine(.F.)
            nItemF := omodelL:AddLine()
            omodelL:SetNoInsertLine(.T.)
        Endif

        omodelL:GoLine(omodelL:Length())
        omodelL:LoadValue("F5M_FILIAL", (cTempTbl)->F47_FILIAL)
        omodelL:LoadValue("F5M_IDDOC ", oModelH:GetValue("F60_IDF60"))
        omodelL:LoadValue("F5M_ALIAS", "F60")
        omodelL:LoadValue("F5M_KEY", (cTempTbl)->F47_IDF47)
        omodelL:LoadValue("F5M_CTRBAL", "1")
        omodelL:LoadValue("F5M_EXGRAT", 0 )
        omodelL:LoadValue("F5M_BSVATC", 0)
        omodelL:LoadValue("F5M_VLVATC", 0)
        omodelL:LoadValue("F5M_KEYALI", "F47")
        nItemF := oModelVirt:Length()

        If !oModelVirt:IsEmpty()
            oModelVirt:SetNoInsertLine(.F.)
            nItemF := oModelVirt:AddLine()
            oModelVirt:SetNoInsertLine(.T.)
        Endif

        oModelVirt:GoLine(nItemF)
        oModelVirt:LoadValue("B_FILIAL"	,(cTab)->F47_FILIAL )
        oModelVirt:setValue("B_PAYTYP"	,(cTab)->F47_PAYTYP )
		oModelVirt:LoadValue("B_CODREQ"	,(cTab)->F47_CODREQ )
		oModelVirt:LoadValue("B_DTREQ"	,STOD((cTab)->F47_DTREQ) )
		oModelVirt:LoadValue("B_DTPLAN"	,STOD((cTab)->F47_DTPLAN) )
		oModelVirt:LoadValue("B_SUPP"	,(cTab)->F47_SUPP )
		oModelVirt:LoadValue("B_UNIT"	,(cTab)->F47_UNIT )
		oModelVirt:LoadValue("B_CNT"	,(cTab)->F47_CNT )
		oModelVirt:LoadValue("B_CLASS"	,(cTab)->F47_CLASS )
		oModelVirt:LoadValue("B_PAYORD"	,(cTab)->F47_PAYORD )
		oModelVirt:LoadValue("B_VALUE"	,(cTab)->F47_VALUE )
		oModelVirt:LoadValue("B_IDF47"	,(cTab)->F47_IDF47 )
        oModelVirt:LoadValue("B_CURREN"	,(cTab)->F47_CURREN )
		oModelVirt:LoadValue("B_DTPAYM",STOD((cTab)->F49_DTPAYM) )

        If !Empty((cTab)->A2_NOME)
		    oModelVirt:LoadValue("B_SUPNAM",(cTab)->A2_NOME )
        Endif
        If !Empty((cTab)->F5Q_DESCR)
		    oModelVirt:LoadValue("B_F5QDES",(cTab)->F5Q_DESCR )
        Endif

	    oModelVirt:LoadValue("B_DTPAYM",STOD((cTab)->F49_DTPAYM) )
        oModelVirt:LoadValue("B_REASON", LEFT(alltrim(Posicione("F47",1,(cTab)->F47_FILIAL+(cTab)->F47_CODREQ,"F47_REASON")),210))
        oModelVirt:LoadValue("B_VRSN", LEFT(alltrim(Posicione("F47",1,(cTab)->F47_FILIAL+(cTab)->F47_CODREQ,"F47_REASON")),80))

	Endif
	(cTempTbl)->(DbSkip())

Enddo

omodelL:GoLine(1)
oModelVirt:GoLine(1)

If !lCopy //Not copy(comes from markbrowse)
    dNewDate := oModelH:GetValue('F60_DTPLA')
    For nX := 1 To oModelVirt:Length()
        oModelVirt:GoLine(nX)
        If F47->(DbSeek(oModelVirt:GetValue('B_FILIAL')+oModelVirt:GetValue('B_CODREQ'))) .AND. dNewDate != Nil
            oModelPR := FwLoadModel("RU06D04")
            oModelPR:SetOperation(4)
            RU06D0401_RecalcCurrency(.T., @oModelPR, 1, dNewDate )

            oModelPR:Activate()
            nValue := oModelPR:GetModel("RU06D04_MHEAD"):GetValue("F47_VALUE")
            oModelVirt:SetValue("B_VALUE",nValue)
            oModelVirt:LoadValue("B_DTPLAN", dNewDate)
            oModelPR:DeActivate()
        EndIf
    Next nX

    oView	:= FWViewActive()
    oMoreDlg:End()
Endif

omodelL:GoLine(1)
oModelVirt:GoLine(1)

RestArea(aArea)
Return ()





/* function to update initial values in Group of Questions - Pick Up APs
@author Anna Fedorova
called after button Add in Markbrowse - writes PRs and APs to the model
RU06T0208_UpdPerg()
@since 04/22/2019 */
//----------------------------------------------
Static Function RU06T0208_UpdPerg(cPergName, cParName, xValue)
Local aArea     as Array
Local nPosPar   as Numeric
Local nLine     as Numeric
Local aPerg     as Array
Default xValue := ''

aArea := GetArea()
nPosPar := 14
nLine := 0
aPerg := {}

DBSELECTAREA("SX1")
DBSETORDER(1)
If DBSEEK(PADR(cPergName,Len(SX1->X1_GRUPO)) +RIGHT(cParName,2) )
    RECLOCK("SX1",.F.)
    If SX1->X1_GSC == 'C' // Combo
        If ValType(xValue) == 'C' //Char
            SX1->X1_PRESEL:= val(xValue)
        Else
            SX1->X1_PRESEL:= val(xValue)
        Endif
    Else
        If ValType(xValue) == 'C' //Char
            SX1->X1_CNT01:= xValue
        ElseIf ValType(xValue) == 'D' //Date
            SX1->X1_CNT01:= dToS(xvalue)
        ElseIf ValType(xValue) == 'N' .Or. ValType(xValue) == 'L' //Number or Logic
            SX1->X1_CNT01:= cValToChar(xvalue)
        Endif
    Endif
    DBCOMMIT()
    MSUNLOCK()
Endif

RestArea(aArea)
Return (NIL)


/*/{Protheus.doc} RU06T0211_VirtGridLoad
function to load values to virtual grid
@author Anna Fedorova
@since 04/22/2019
@version 1.0
@project MA3 - Russia
/*/
Function RU06T0211_VirtGridLoad(oModel)
Local aLines    as Array
Local cQuery    as Character
Local oModelF60 as Object
Local cCodReq as character

oModelF60:=oModel:GetModel():GetModel("RU06T02_MHEAD")
cCodReq := Alltrim(oModelF60:GetValue("F60_CODREQ"))

aLines:={}
cQuery := " SELECT F60_IDF60, F47_IDF47, F47_FILIAL, F47_PAYTYP, F47_CODREQ,F47_DTREQ, F47_DTPLAN, F47_SUPP, F47_UNIT, F47_CNT, F47_CLASS, F47_VALUE, F47_PAYORD, F47_IDF47, F47_CURREN ,F47_DTREQ,F49_DTPAYM, F5Q_DESCR,A2_NOME FROM " + RetSQLName("F60") + " F60 "
cQuery += "     INNER JOIN " + RetSQLName("F5M") + " F5M ON F60.F60_IDF60 = F5M.F5M_IDDOC AND F5M.F5M_ALIAS = 'F60' AND F5M.F5M_FILIAL =  F60.F60_FILIAL  AND F5M.D_E_L_E_T_ = ' ' "
cQuery += "     LEFT JOIN " + RetSQLName("F47") + " F47 ON F5M.F5M_KEY = F47.F47_IDF47 AND F5M.F5M_KEYALI= 'F47' AND F47.D_E_L_E_T_ = ' ' AND F47.F47_PAYTYP='1' "
cQuery += "     LEFT JOIN " + RetSQLName("SA2") + " SA2  ON F47.F47_SUPP = SA2.A2_COD AND SA2.D_E_L_E_T_ = ' ' "
cQuery += "     LEFT JOIN " + RetSQLName("F5Q") + " F5Q  ON F47.F47_CNT = F5Q.F5Q_CODE AND F5Q.D_E_L_E_T_ = ' ' "
cQuery += "     LEFT JOIN " + RetSQLName("F4A") + " F4A  ON F4A.D_E_L_E_T_ = ' ' AND F47.F47_CODREQ = F4A.F4A_CODREQ " //remove filial
cQuery += "     LEFT JOIN " + RetSQLName("F49") + " F49 ON F4A.F4A_FILIAL = F49.F49_FILIAL AND F49.D_E_L_E_T_ = ' ' AND F4A.F4A_IDF49 = F49.F49_IDF49 "
cQuery += " WHERE F60.F60_CODREQ ='" + cCodReq+ "'"
cQuery += " AND F60.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)

If SELECT("TMPLOAD") > 0
	TMPLOAD->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "TMPLOAD", .T., .F.)
dbSelectArea("TMPLOAD")
dbGoTop()


While !(TMPLOAD->(Eof()))
    cCodReq := TMPLOAD->F47_CODREQ

	AADD(aLines,{0,{(TMPLOAD->F47_FILIAL), ;
	(TMPLOAD->F47_PAYTYP), ;
	(TMPLOAD->F47_CODREQ), ;
	STOD((TMPLOAD->F47_DTREQ)), ;
	STOD((TMPLOAD->F47_DTPLAN)), ;
	(TMPLOAD->F47_SUPP)  , ;
	(TMPLOAD->F47_UNIT)  , ;
	(TMPLOAD->F47_CNT)   , ;
	(TMPLOAD->F47_CLASS) , ;
	TMPLOAD->F47_VALUE , ;
	(TMPLOAD->F47_PAYORD), ;
	(TMPLOAD->F47_IDF47), ;
	(TMPLOAD->F47_CURREN) ,;
	STOD((TMPLOAD->F49_DTPAYM)),;
	(TMPLOAD->A2_NOME),;
	(TMPLOAD->F5Q_DESCR),;
    LEFT(alltrim(Posicione("F47",1,TMPLOAD->F47_FILIAL+TMPLOAD->F47_CODREQ,"F47_REASON")),210),;
	LEFT(alltrim(Posicione("F47",1,TMPLOAD->F47_FILIAL+TMPLOAD->F47_CODREQ,"F47_REASON")),80)}})

    TMPLOAD->(DBSkip())
Enddo
TMPLOAD->(DbCloseArea())
Return (aLines)






/* @author Anna Fedorova
@since 04/22/2019 */
//----------------------------------------------
Function RU06T0212_2Click(omodelL as Object, cFieldName as character , nLineGrid as numeric, nLineModel as numeric)
Local nRet as Numeric
Local aBtns as Array
Local oModel as object

oModel:=FwModelActive()
omodelL:=oModel:GetModel("RU06T02_MVIRT")

If cFieldName != "B_REASON"
    If !Empty(omodelL:GetValue("B_PAYORD"))
        nRet:=0
        aBtns:={STR0028,STR0027, STR0012}// "Payment Request","Payment Order", "Cancel"
        nRet:=AVISO(STR0029,STR0030,aBtns,2) //"What information would you like to see?","--Additional Description--"

        If nRet == 1
            FWMsgRun(, {||  RU06T0216_Payment_requests() },STR0020 , )//Add this to user see that we are processing
        Endif
        If  nRet == 2
            FWMsgRun(, {||  RU06T0217_Payment_orders() },STR0020 , )//Add this to user see that we are processing
        Endif
    Else
        FWMsgRun(, {||  RU06T0216_Payment_requests() },STR0020 , ) //Add this to user see that we are processing
    EndIf
Endif

Return .T.


/* @author Anna Fedorova
@since 04/22/2019 */
//----------------------------------------------
function RU06T0213_Cancel()
return .T.


/* @author Anna Fedorova
@since 04/22/2019 */
//----------------------------------------------
function RU06T0214_AVISO_Approve()

Local oModel as Object
Local oModelH as Object
Local cStatus as character
Local lRet as logical

lRet :=.T.
If Empty(F60->F60_BNKPAY)
      Help("",1,STR0031,,STR0093,1,0,,,,,,/*{'str - solution'}*/)
      lRet := .F.
EndIf

If lRet
    oModel:=FWLoadModel("RU06T02")
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate()
    oModelH:=oModel:GetModel("RU06T02_MHEAD")
    cStatus:=oModelH:GetValue('F60_STATUS')
    If cStatus == PR_STATUS_CREATED .OR. cStatus == PR_STATUS_REJECTED
        lRet:= IIf(isblind(),.T.,MsgNoYes(STR0014/*"Approve"*/+"  "+Alltrim(oModelH:GetValue("F60_CODREQ"))+'?',STR0081)) // Approve?
        If lRet
            FwFldPut('F60_STATUS','2',,,,.T.)
            If oModel:VldData()
                oModel:CommitData()
            Else
                Help("",1,STR0033,,STR0034,1,0,,,,,,{STR0033}) // Not Validated
            Endif
        Endif
    ElseIf cStatus == PR_STATUS_CANCELLED
        Help("",1,STR0031,,STR0084,1,0,,,,,,/*{'str - solution'}*/) // Approve request - already approved
    Else
        Help("",1,STR0031,,STR0032,1,0,,,,,,/*{'str - solution'}*/) // Approve request - already approved
    Endif
    oModel:DeActivate()
EndIf

Return lRet

/* @author Anna Fedorova
@since 04/22/2019 */
//----------------------------------------------
function RU06T0215_AVISO_Reject()
Local oModelH as object
Local cStatus as character
Local oModel as object
Local lRet as logical

oModel:=FWLoadModel("RU06T02")
oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate()
oModelH:=oModel:GetModel("RU06T02_MHEAD")
cStatus:=oModelH:GetValue('F60_STATUS')
lRet :=.F.

If cStatus == PR_STATUS_REJECTED
    Help("",1,STR0083,,STR0036,1,0,,,,,,/*{'str - solution'}*/)
ElseIf cStatus == PR_STATUS_CANCELLED
    Help("",1,STR0083,,STR0086,1,0,,,,,,/*{'str - solution'}*/)
Else
    lRet:= IIf(isblind(),.T., MsgNoYes(STR0015+"  "+Alltrim(oModelH:GetValue("F60_CODREQ"))+'?',STR0082) )
    If lRet
        FwFldPut('F60_STATUS','3',,,,.T.)
        If oModel:VldData()
            oModel:CommitData()
        Else
            Help("",1,STR0033,,STR0034,1,0,,,,,,{STR0033}) // Not Validated
        Endif
    Endif
Endif
oModel:DeActivate()

Return lRet



/*/
{Protheus.doc} RU06T0216_Payment_requests()
Function responsible to open Payment request in vizualization mode
functions located in x3_relacao
@author Anna Fedorova
@since 04/22/2019
@version 1.0
@project MA3 - Russia
/*/
function RU06T0216_Payment_requests()
Local aArea		as array
Local aAreaF47	as array
Local oModel    as Object
Local cModel    as Character
Local oModelL   as Object
Local cFilBkp   as Character

cFilBkp := cFilAnt
aArea   := GetArea()
aAreaF47:= Eval({||DbSelectArea("F47"),F47->(GetArea())})
oModel  := FwModelActive()
cModel  := oModel:GetID()
If cModel=="RU06T02"
    oModelL :=oModel:GetModel("RU06T02_MVIRT")
    cFilAnt := oModelL:GetValue("B_FILIAL")
    F47->(DbSetOrder(1))
    If MsSeek(oModelL:GetValue("B_FILIAL") + oModelL:GetValue("B_CODREQ") + DTOS(oModelL:GetValue("B_DTREQ")))
        FWExecView("","RU06D04",MODEL_OPERATION_VIEW,,{|| .T.})
    Endif
    RestArea(aAreaF47)
    RestArea(aArea)
Endif
cFilAnt := cFilBkp
Return .T.




//------------------------------------------------------------------------------
// the function should be changed after changing table F47.
//Now it contains information about the order number, but this is not enough,
// because numbers can match For dIfferent years
//RU06D0411_ShowPO()
//------------------------------------------------------------------------------
/* @author Anna Fedorova
@since 04/22/2019 */
//----------------------------------------------
function RU06T0217_Payment_orders()
Local aArea		as array
Local aAreaF47	as array
Local oModel    as Object
Local cModel    as Character
Local oModelH   as Object
Local omodelL   as Object
Local lRet      as Logical
Local cQuery    as character
Local cidF49    as character

cidF49 := " "
aArea := GetArea()
aAreaF47 := Eval({||DbSelectArea("F47"),F47->(GetArea())})
lRet:=.T.
oModel:=FwModelActive()
cModel:=oModel:GetID()

If cModel=="RU06T02"
    omodelL:=oModel:GetModel("RU06T02_MVIRT")
    oModelH:=oModel:GetModel("RU06T02_MHEAD")

    cQuery := " SELECT * FROM " + RetSQLName("F47") + " F47 "
    cQuery += " Inner JOIN  " + RetSQLName("F4A") + " F4A "
    cQuery += " ON F47.F47_CODREQ = F4A.F4A_CODREQ "
    cQuery += " AND F4A.D_E_L_E_T_ = '' "
    cQuery += " Inner JOIN  " + RetSQLName("F49") + " F49 "
    cQuery += " ON F4A.F4A_IDF49 = F49.F49_IDF49 "
    cQuery += " AND F49.D_E_L_E_T_ = '' "
    cQuery += " WHERE F47.D_E_L_E_T_ = '' "
    cQuery += " AND F47.F47_IDF47 = '" +omodelL:GetValue("B_IDF47") + "' "
    cQuery := ChangeQuery(cQuery)
    If SELECT("TMPLOAD") > 0
        TMPLOAD->(DbCloseArea())
    Endif
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "TMPLOAD", .T., .F.)
    dbSelectArea("TMPLOAD")

    If !(TMPLOAD->(eof()))
        DbSelectArea('F49')
        F49->(DbSetOrder(2))
        cidF49 := TMPLOAD->F49_IDF49

        If DbSeek(TMPLOAD->F49_FILIAL+cidF49)
            FWExecView("","RU06D05",MODEL_OPERATION_VIEW,,{|| .T.})
            lRet:=.F.
        Endif
    EndIf

    RestArea(aAreaF47)
    RestArea(aArea)
    TMPLOAD->(DbCloseArea())
Endif

return .T.



/* @author Anna Fedorova
@since 04/22/2019 */
//this is virtual structure
//----------------------------------------------
Function RU06T0218_DefVirtStr()
Local oStruct   as Object
Local aArea     as Array
aArea	:=GetArea()
oStruct :=FWFormModelStruct():New()
// Table
oStruct:AddTable("", , "Payments")
// Indexes
oStruct:AddIndex(   1, ;     // [01] Index Order
		"01", ;     // [02] ID
		"B_FILIAL + B_CODREQ ", ; 	// [03] Key of Index
		"Virt_Payments"	, ; 	// [04] Description of Index
		""			, ;    	// [05] Lookup Expression
		""			, ;    	// [06] Index Nickname
		.T. )				// [07] Index used on interface

oStruct:AddField(RetTitle("F47_FILIAL")			,RetTitle("F47_FILIAL")			,"B_FILIAL" 	,GetSX3Cache("F47_FILIAL",		 "X3_TIPO"), GetSX3Cache("F47_FILIAL",		 "X3_TAMANHO")   ,GetSX3Cache("F47_FILIAL",	"X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)    //  Payment Type
oStruct:AddField(RetTitle("F47_PAYTYP")			,RetTitle("F47_PAYTYP")			,"B_PAYTYP" 	,GetSX3Cache("F47_PAYTYP",		 "X3_TIPO"), GetSX3Cache("F47_PAYTYP",		 "X3_TAMANHO")   ,GetSX3Cache("F47_PAYTYP",	"X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)    //  Payment Type
oStruct:AddField(RetTitle("F47_CODREQ")			,RetTitle("F47_CODREQ")			,"B_CODREQ" 	,GetSX3Cache("F47_CODREQ",		 "X3_TIPO"), GetSX3Cache("F47_CODREQ",		 "X3_TAMANHO")   ,GetSX3Cache("F47_CODREQ",	"X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)    //  Request Num
oStruct:AddField(RetTitle("F47_DTREQ")			,RetTitle("F47_DTREQ")			,"B_DTREQ" 	    ,GetSX3Cache("F47_DTREQ",		 "X3_TIPO"), GetSX3Cache("F47_DTREQ",		 "X3_TAMANHO")   ,GetSX3Cache("F47_DTREQ",	"X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)    //  Request Date
oStruct:AddField(RetTitle("F47_DTPLAN")			,RetTitle("F47_DTPLAN")			,"B_DTPLAN" 	,GetSX3Cache("F47_DTPLAN",		 "X3_TIPO"), GetSX3Cache("F47_DTPLAN",		 "X3_TAMANHO")   ,GetSX3Cache("F47_DTPLAN",	"X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)    //  Planned Date
oStruct:AddField(RetTitle("F47_SUPP")			,RetTitle("F47_SUPP")			,"B_SUPP" 		,GetSX3Cache("F47_SUPP",		 "X3_TIPO"), GetSX3Cache("F47_SUPP",		 "X3_TAMANHO")   ,GetSX3Cache("F47_SUPP",	"X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)    //  Supplier
oStruct:AddField(RetTitle("F47_UNIT")			,RetTitle("F47_UNIT")			,"B_UNIT" 		,GetSX3Cache("F47_UNIT",		 "X3_TIPO"), GetSX3Cache("F47_UNIT",		 "X3_TAMANHO")   ,GetSX3Cache("F47_UNIT",	"X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)    //  Unit of supplier
oStruct:AddField(RetTitle("F47_CNT")			,RetTitle("F47_CNT")			,"B_CNT" 		,GetSX3Cache("F47_CNT",			 "X3_TIPO"), GetSX3Cache("F47_CNT",			 "X3_TAMANHO")   ,GetSX3Cache("F47_CNT",	    "X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)    //  Contract Nr.
oStruct:AddField(RetTitle("F47_CLASS")			,RetTitle("F47_CLASS")			,"B_CLASS" 		,GetSX3Cache("F47_CLASS",		 "X3_TIPO"), GetSX3Cache("F47_CLASS",		 "X3_TAMANHO")   ,GetSX3Cache("F47_CLASS",	"X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)    //  Class
oStruct:AddField(RetTitle("F47_VALUE")			,RetTitle("F47_VALUE")			,"B_VALUE" 		,GetSX3Cache("F47_VALUE",		 "X3_TIPO"), GetSX3Cache("F47_VALUE",		 "X3_TAMANHO")   ,GetSX3Cache("F47_VALUE",	"X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)    //  Value
oStruct:AddField(RetTitle("F47_PAYORD")			,RetTitle("F47_PAYORD")			,"B_PAYORD" 	,GetSX3Cache("F47_PAYORD",		 "X3_TIPO"), GetSX3Cache("F47_PAYORD",		 "X3_TAMANHO")   ,GetSX3Cache("F47_PAYORD",	"X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)    //  Paymt. Order
oStruct:AddField(RetTitle("F47_IDF47")			,RetTitle("F47_IDF47")			,"B_IDF47" 		,GetSX3Cache("F47_IDF47",		 "X3_TIPO"), GetSX3Cache("F47_IDF47",		 "X3_TAMANHO")   ,GetSX3Cache("F47_IDF47",	"X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)    //  Reason Pymt
oStruct:AddField(RetTitle("F47_CURREN")			,RetTitle("F47_CURREN")			,"B_CURREN" 	,GetSX3Cache("F47_CURREN",		 "X3_TIPO"), GetSX3Cache("F47_CURREN",		 "X3_TAMANHO")   ,GetSX3Cache("F47_CURREN",	"X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)    //  Reason Pymt
oStruct:AddField(RetTitle("F47_DTPAYM")		    ,RetTitle("F47_DTPAYM")		    ,"B_DTPAYM" 	,GetSX3Cache("F47_DTPAYM",		 "X3_TIPO"), GetSX3Cache("F47_DTPAYM",		 "X3_TAMANHO")   ,GetSX3Cache("F47_DTPAYM",	"X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)    //  Class
oStruct:AddField(RetTitle("F47_SUPNAM")		    ,RetTitle("F47_SUPNAM")		    ,"B_SUPNAM" 	,GetSX3Cache("F47_SUPNAM",		 "X3_TIPO"), GetSX3Cache("F47_SUPNAM",		 "X3_TAMANHO")   ,GetSX3Cache("F47_SUPNAM",	"X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)    //  Value
oStruct:AddField(RetTitle("F47_F5QDES")		    ,RetTitle("F47_F5QDES")		    ,"B_F5QDES" 	,GetSX3Cache("F47_F5QDES",		 "X3_TIPO"), GetSX3Cache("F47_F5QDES",		 "X3_TAMANHO")   ,GetSX3Cache("F47_F5QDES",	"X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)    //  Reason Pymt
oStruct:AddField(RetTitle("F47_REASON")		    ,RetTitle("F47_REASON")		    ,"B_REASON" 	,GetSX3Cache("F47_REASON",		 "X3_TIPO"), GetSX3Cache("F47_REASON",		 "X3_TAMANHO")   ,GetSX3Cache("F47_REASON",	"X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)    //  Reason Pymt
oStruct:AddField(RetTitle("F47_VRSN")		    ,RetTitle("F47_VRSN")		    ,"B_VRSN"  		,GetSX3Cache("F47_VRSN",		 "X3_TIPO"), 80/*GetSX3Cache("F47_VRSN",         "X3_TAMANHO")*/   ,GetSX3Cache("F47_VRSN",	"X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)    //  Paymt. Order

RestArea(aArea)

Return (oStruct)



/* @author Anna Fedorova
@since 04/22/2019 */
//----------------------------------------------
Function RU06T0229_VldVat(nNum as Numeric)
return .T.




/* @author Anna Fedorova
@since 04/22/2019 */
//this function recalculate monetary values
//It returns an array with total value, balance and initial balance
//----------------------------------------------
Function RU06T0220_Write_values(lCopy as Logical)
Local oModel as object
Local nIniBAl as numeric
Local omodelL as object
Local oModelH as object
Local oModelVirt as object
Local nTotal as Numeric
Local nBalan as Numeric
Local nx as Numeric
Local aRet as array
Local aArea as Array
Default lCopy := .F.
aArea := GetArea()
aRet := {0, 0, 0}
oModel := FWModelActive()
If (ValType(oModel) == "O" .and. oModel:GetID() == "RU06T02")
    oModelH := oModel:GetModel("RU06T02_MHEAD")
    omodelL := oModel:GetModel("RU06T02_MLNS")
    oModelVirt := oModel:GetModel("RU06T02_MVIRT")
    nx:= 0
    nTotal  := 0
    nBalan  := 0
    nIniBAl := 0

    If !(oModelVirt:IsEmpty())
        For nX:=1 to oModelVirt:Length()
            If !oModelVirt:IsDeleted (nX)
                nTotal+= oModelVirt:GetValue("B_VALUE",nX)
            Endif
        Next

        nTotal := xMoeda(nTotal,VAL(oModelVirt:GetValue("B_CURREN")),VAL(oModelH:GetValue("F60_CURREN")),oModelH:GetValue("F60_DTPLA"),2)
        nIniBAl := xMoeda(oModelH:GetValue("F60_INIBAL"),VAL(oModelVirt:GetValue("B_CURREN")),VAL(oModelH:GetValue("F60_CURREN")),oModelH:GetValue("F60_DTPLA"),2)
        nBalan := nIniBAl - nTotal
        aRet := {nTotal, nBalan, nIniBAl}
    Else
        //Get Balance from the bank table
        DbSelectArea('SA6')
        DbSetOrder(1)
        If !Empty(FWFldGet("F60_BNKPAY")) .and. !lCopy
            If DbSeek(xFilial("SA6")+FWFldGet("F60_BNKPAY")+FWFldGet("F60_PAYBIK")+FWFldGet("F60_PAYACC"))
                nIniBAl := SA6->A6_SALATU
            EndIf
        ElseIf lCopy
            If DbSeek(xFilial("SA6")+F60->F60_BNKPAY+F60->F60_PAYBIK+F60->F60_PAYACC)
                nIniBAl := SA6->A6_SALATU
            EndIf
        EndIf
        nBalan := nIniBAl - nTotal
        aRet := {nTotal, nBalan, nIniBAl}
    Endif
EndIf
RestArea(aArea)
return aRet


/* @author Anna Fedorova
@since 04/22/2019 */
//----------------------------------------------
Function RU06T0219_Act(nOperation as Numeric)
Local lRet          as Logical
Local cStatus       as Character
Local cOper         as Character
Local cCodReq       as Character
Local aBtns         as Array
Local nAvisoRet     as Numeric
Local aNoCopyLns    as Array
Local nX            as Numeric
Local nArrayLen     as Numeric
Local oModel        as Object

aNoCopyLns := {}
nX := 1
lRet:=.T.
cOper := STR0001
cStatus:=F60->F60_STATUS
cCodReq:=F60->F60_CODREQ

If (nOperation == MODEL_OPERATION_INSERT)
    F60->(dbGoBottom())
    F60->(dbSkip())
    cOper:= ""
Endif

If nOperation == MODEL_OPERATION_DELETE
    cOper:= ""
    If (SuperGetMv("MV_REQAPR") == 1 .and. cStatus==PR_STATUS_APPROVED)
        Help("",1,STR0041,,STR0044,1,0,,,,,,{STR0045})
        lRet := .F.
    Endif
    If (SuperGetMv("MV_REQAPR") == 1 .and. cStatus==PR_STATUS_IMPLEMENTED)
        Help("",1,STR0042,,STR0044,1,0,,,,,,{STR0045})
        lRet := .F.
    Endif
Endif

If nOperation == MODEL_OPERATION_UPDATE
    Do Case
        Case cStatus == PR_STATUS_CANCELLED
            Help("",1,STR0052,,STR0053,1,0,,,,,,{STR0085})
            nOperation:=MODEL_OPERATION_VIEW
            cOper := STR0058
            lRet := .F. //avoid display screen
        Case cStatus == PR_STATUS_APPROVED
            Help("",1,STR0052,,STR0054,1,0,,,,,,)
            nOperation:=MODEL_OPERATION_VIEW
            cOper := STR0058
            lRet := .F.//avoid display screen
        Case cStatus == PR_STATUS_IMPLEMENTED
            Help("",1,STR0052,,STR0055,1,0,,,,,,)
            nOperation:=MODEL_OPERATION_VIEW
            cOper := STR0058
            lRet := .F.//avoid display screen
        Otherwise
            cOper:= STR0057
    EndCase
Endif

If nOperation == MODEL_OPERATION_COPY .AND. !isBlind()
    IF cStatus != PR_STATUS_CANCELLED
        Help("",1,STR0059,,STR0060,1,0,,,,,,)
        nOperation:=MODEL_OPERATION_VIEW
        cOper:= STR0058
        lRet := .F.//avoid display screen
    Else
        FWMsgRun(, {||  RU06T0293_Copy(cCodReq) }, STR0020, )//Add this to user see that we are processing
        lRet := .F.
    Endif
Endif

If lRet .AND. !isBlind()
	FWExecView(cOper,"RU06T02",nOperation,,{|| .T.})
Endif

Return lRet



//The function is used in this source code. Recalculates balance amounts
Function RU06T0223_Write_values(nCurrentLine As Number, cAction As Char)
Local oModel as object
Local oModelH as object
Local oModelVirt as object
Local nBalan as Numeric
Local nx as Numeric
Local lRet as logical
Local nTotal as numeric

Default nCurrentLine := 0
Default cAction := ""

lRet := .T.

oModel := FwModelActive()

oModelH := oModel:GetModel("RU06T02_MHEAD")
oModelVirt := oModel:GetModel("RU06T02_MVIRT")

nTotal := 0
nx := 0
nBalan := 0

For nX:=1 to oModelVirt:Length()
    If cAction == "DELETE" .And. nX == nCurrentLine
        Loop
    EndIf
    If !oModelVirt:IsDeleted(nX) .Or. (cAction == "UNDELETE" .And. nX == nCurrentLine)
        nTotal += oModelVirt:GetValue("B_VALUE", nX)
    EndIf
Next

nBalan :=  xMoeda(oModelH:GetValue("F60_INIBAL"),VAL(oModelVirt:GetValue("B_CURREN")),VAL(oModelH:GetValue("F60_CURREN")),oModelH:GetValue("F60_DTPLA"),2)-xMoeda(nTotal,VAL(oModelVirt:GetValue("B_CURREN")),VAL(oModelH:GetValue("F60_CURREN")),oModelH:GetValue("F60_DTPLA"),2)
oModelH:SetValue("F60_BALANC",nBalan)
oModelH:SetValue("F60_VALUE",xMoeda(nTotal,VAL(oModelVirt:GetValue("B_CURREN")),VAL(oModelH:GetValue("F60_CURREN")),oModelH:GetValue("F60_DTPLA"),2))
oModelH:SetValue("F60_INIBAL",xMoeda(oModelH:GetValue("F60_INIBAL"),VAL(oModelVirt:GetValue("B_CURREN")),VAL(oModelH:GetValue("F60_CURREN")),oModelH:GetValue("F60_DTPLA"),2))


Return lRet


//Function to cancel the payment register
Function RU06T0224_AVISO_Cancel()
Local lRet as logical
Local oModelH as object
Local cStatus as character
Local oModel as object

oModel:=FWLoadModel("RU06T02")
oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate()
oModelH:=oModel:GetModel("RU06T02_MHEAD")
cStatus:=oModelH:GetValue('F60_STATUS')
lRet :=.F.

If cStatus != PR_STATUS_CANCELLED .And. cStatus != PR_STATUS_IMPLEMENTED
    lRet:= IIf(isblind(),.T.,MsgNoYes(STR0035+"  "+Alltrim(oModelH:GetValue("F60_CODREQ"))+'?',STR0012)) // Reject?
    If lRet
        FwFldPut('F60_STATUS','4',,,,.T.)
        If oModel:VldData()
            oModel:CommitData()
        Else
            Help("",1,STR0033,,STR0034,1,0,,,,,,{STR0033}) // Not Validated
            lRet :=.F.
        Endif
    Endif
ElseIf cStatus == PR_STATUS_IMPLEMENTED
    Help("",1,STR0035,,STR0042,1,0,,,,,,/*{'str - solution'}*/)
    lRet :=.F.
Else
    Help("",1,STR0035,,STR0036,1,0,,,,,,/*{'str - solution'}*/) // Reject request - already approved
    lRet :=.F.
Endif
oModel:DeActivate()

Return lRet



/*/{Protheus.doc} RU06T0225_CheckifCopy
The function is called before copy, and checks if payment requests are included in another payment register or used at payment order
@author rafael.goncalves
@since 17.02.2019
@version 1.0
@project MA3 - Russia
/*/
function RU06T0225_CheckifCopy(cF60code AS Character) as Array
Local aF47Ids       as Array
Local cQuery        as Character
Local cQueryK       as Character
aF47Ids := {}

//Get itens at the selected List of Payments and check in this item are not used at Payment Order
cQuery := " SELECT F47.F47_IDF47 FROM " + RetSQLName("F60") + " F60 "
cQuery += " INNER JOIN " + RetSQLName("F5M") + " F5M "
cQuery += "     ON F60.F60_IDF60 = F5M.F5M_IDDOC AND F5M.F5M_ALIAS = 'F60' AND F5M.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSQLName("F47") + " F47 "
cQuery += "     ON F5M.F5M_KEY = F47.F47_IDF47 AND F5M.F5M_KEYALI= 'F47' AND F47.D_E_L_E_T_ = ' ' "
cQuery += "     AND F47.F47_PAYTYP ='1' " //Only Payment Request with F47_PAYTYP = 1;
cQuery += "     AND F47.F47_PAYORD =' ' " //The payment Request isn’t in Payment Order (F47_PAYORD == ' ');
//Check status of Payment Request, when the PR are used at Payment order the status is change
If  SuperGetMv("MV_REQAPR",, 0)  = 1 //If the user status allows you to change the status of the payment request
    cQuery += " AND F47.F47_STATUS ='4' " //check is status is approved
else
    cQuery += " AND F47.F47_STATUS ='1' " //check is status is create
Endif
cQuery += " WHERE  "
cQuery += "     F60.D_E_L_E_T_ = '' "
cQuery += "     AND F60.F60_CODREQ = '" +cF60code + "' "
cQuery += "     AND F60.F60_FILIAL = '"+ xFilial("F60") +"'"
cQuery := ChangeQuery(cQuery)

If SELECT("TMPLOAD") > 0
    TMPLOAD->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "TMPLOAD", .T., .F.)
dbSelectArea("TMPLOAD")

//If  SuperGetMv("MV_REQAPR",, 0)  = 1 //1==4 , 1<>0
While !(TMPLOAD->(Eof()))

    //Check if this item, was used in one valid list of payment (F60_STATUS in 1 or 2 or 3);
    cQueryK := ''
    cQueryK += "select F5M_ALIAS from " + RetSQLName("F5M") + " F5M "
    cQueryK += "inner join " + RetSQLName("F60") + " F60 on F60.F60_IDF60 = F5M.F5M_IDDOC and F60.D_E_L_E_T_ ='' "
    cQueryK += "where F5M_KEY = '" + TMPLOAD->F47_IDF47 + "' " //Id of F47(PR)
    cQueryK += "and F5M_ALIAS = 'F60' " //only list of payments requisitions
    cQueryK += "and F5M.D_E_L_E_T_ = ' ' "
    cQueryK += "and F60.F60_CODREQ <> '" +cF60code + "' " //List of payments diferent that selected to copy
    cQueryK += "and F60.F60_STATUS in ('1','2','3') "
    cQueryK := ChangeQuery(cQueryK)
    If SELECT("TMPLOAD2") > 0
        TMPLOAD2->(DbCloseArea())
    Endif
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryK), "TMPLOAD2", .T., .F.)
    dbSelectArea("TMPLOAD2")
    If (TMPLOAD2->(Eof())) //Not found, could be copyed
        aAdd(aF47Ids, TMPLOAD->F47_IDF47)
    EndIf
    TMPLOAD2->(DbCloseArea())

    dbSelectArea("TMPLOAD")
    TMPLOAD->(DBSkip())
EndDo

TMPLOAD->(DbCloseArea())
DbSelectArea('F47')

Return aF47Ids

/*/{Protheus.doc} RU06T02
mark all. steal from RU09T02
FI-CF-25-19
@author alexander.kharchenko
@since 06.11.2019
@version 1.0
@project MA3 - Russia
/*/

static function MarkAll(oBrowsePut as Object, cTempTbl as Character)
Local nRecOri 	as Numeric

nRecOri	:= (cTempTbl)->(RecNo())

dbSelectArea(cTempTbl)
(cTempTbl)->(DbGoTop())
Do While !(cTempTbl)->(Eof())
	RecLock(cTempTbl, .F.)
	If !Empty((cTempTbl)->F47_OK)
		(cTempTbl)->F47_OK := ''
	Else
		(cTempTbl)->F47_OK := cMark
	EndIf
	MsUnlock()

	(cTempTbl)->(DbSkip())
EndDo

(cTempTbl)->(DbGoTo(nRecOri))

oBrowsePut:oBrowse:Refresh(.T.)

Return .T.

/*/{Protheus.doc} RU06T02
Generation of Payment orders from a list of payments
FI-CF-25-19
@author alexander.kharchenko
@since 17.07.2019
@version 1.0
@project MA3 - Russia
/*/
Function RU06T0290_GenPayOrd()

Local oModel    as object
Local lRet      as logical
Local cStatus   as character
Local aButtons  as array

aButtons := {   {.F.,Nil    },;
                {.F.,Nil    },;
                {.F.,Nil    },;
                {.F.,Nil    },;
                {.F.,Nil    },;
                {.F.,Nil    },;
                {.T.,STR0074},;
                {.T.,       },;
                {.F.,Nil    },;
                {.F.,Nil    },;
                {.F.,Nil    },;
                {.F.,Nil    },;
                {.F.,Nil    },;
                {.F.,Nil    }}

lRet := .T.
cStatus := F60->F60_STATUS

Do case
    case cStatus == '1' .and. SuperGetMv("MV_REQAPR",, 0)  = 1  //status create and tiver aprovação ativada
        Help("",1,STR0065,,STR0066,1,0,,,,,,{STR0067})
        lRet := .F.
    case cStatus == '3'
        Help("",1,STR0065,,STR0068,1,0,,,,,,{STR0069})
        lRet := .F.
    case cStatus == '4'
        Help("",1,STR0065,,STR0070,1,0,,,,,,{STR0071})
        lRet := .F.
    case cStatus == '5'
        Help("",1,STR0065,,STR0072,1,0,,,,,,{STR0073})
        lRet := .F.
Endcase

//Check if bank was filled, they are mandatory at this step
If Empty(F60->F60_BNKPAY)
      Help("",1,STR0065,,STR0093,1,0,,,,,,/*{'str - solution'}*/)
      lRet := .F.
EndIf

If lRet == .T.
    oModel := FWLoadModel('RU06T02')
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate()
    FWExecView(STR0001,"RU06T02",MODEL_OPERATION_UPDATE,,{|| RU06T0291_RunPayCheck(oModel)},,,aButtons)
    oModel:DeActivate()
Endif

return lRet


/*/{Protheus.doc} RU06T02
Validation list
FI-CF-25-19
@author alexander.kharchenko
@since 24.07.2019
@version 1.0
@project MA3 - Russia
/*/
Function RU06T0291_RunPayCheck(oModel as object)
Local nGridLength as Numeric
Local cSubModName as Character
Local oView  as Object

lResult := .t.
cSubModName := 'RU06T02_MLNS'
nGridLength := oModel:GetModel(cSubModName):length()
oView   := FWViewActive()
oView:lModify := .T.
oView:oModel:lModify := .T.
oView:SetViewAction('BUTTONOK',{|| IIF(MSGYESNO(STR0075 + ' ' + ALLTRIM(str(nGridLength)) + ' ' + STR0076, STR0065), Processa({|| RU06T0292_RunPayOrd(oModel)}, STR0065, STR0077,.F.), oView:SetUpdateMessage('',STR0080)) })
oView:SetUpdateMessage('',STR0078 + ' ' + ALLTRIM(str(nGridLength)) + ' ' + STR0079)
return .T.



/*/{Protheus.doc} RU06T0292_RunPayOrd
Generation of Payment orders
@author alexander.kharchenko
@edit rafael.goncalves
@version 2.0 -
@project MA3 - Russia
/*/
Function RU06T0292_RunPayOrd(oModel as Object)

Local oModelSrs as Object
Local oModelDst as Object
Local nI        as Numeric
Local nLenI     as Numeric
Local nJ        as Numeric
Local nLenJ     as Numeric
Local lRet      as Logical
Local nRecF47   as Numeric

lRet := .T.
DbSelectArea('F47')
F47->(DbSetOrder(6))

nLenI := oModel:GetModel('RU06T02_MLNS'):length()
ProcRegua(nLenI)
Begin Transaction
    For nI:= 1 to nLenI //Each item at List of payment will be one payment order
        IncProc(STR0065 + ' ' + ALLTRIM(str(nI)) + '/' + ALLTRIM(str(nLenI)) + ' ' + STR0077)
        processMessage() //Update message at screen
        oModel:GetModel('RU06T02_MLNS'):GoLine(nI) //Position at Payment request line
        //Get Recno using ID, we cannot use F5m becouse we can have several lines in diferente branchs
        nRecF47:= RU06T0294_GetRecnoByID('F47','F47_IDF47',oModel:GetModel('RU06T02_MLNS'):GetValue('F5M_KEY'))
        If (nRecF47>0) .and. lRet
            //Position at F47 by ID
            F47->(DbGoTo(nRecF47))

            oModelSrs := FWLoadModel('RU06D04') //Load model from Payment request
            oModelSrs:SetOperation(MODEL_OPERATION_UPDATE)
            oModelSrs:Activate()

            oModelDst := FWLoadModel('RU06D05')
            oModelDst:SetOperation(MODEL_OPERATION_INSERT)
            oModelDst:Activate()

            //Create header for Payment order
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_PAYTYP" ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_PAYTYP'))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_DTPAYM" ,oModel:GetModel('RU06T02_MHEAD'):GetValue('F60_DTPLA'    )) //Change for planed date
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_SUPP"   ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_SUPP'  ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_UNIT"   ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_UNIT'  ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_CNT"    ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_CNT'   ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_CURREN" ,oModel:GetModel('RU06T02_MHEAD'):GetValue('F60_CURREN'   ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_PREPAY" ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_PREPAY'))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_CLASS"  ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_CLASS' ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_REASON" ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_REASON'))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_KPPREC" ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_KPPREC'))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_BNKREC" ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_BNKCOD'))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_RECBIK" ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_BIK'   ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_RECACC" ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_ACCNT' ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_KPPPAY" ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_KPPPAY'))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_BNKPAY" ,oModel:GetModel('RU06T02_MHEAD'):GetValue('F60_BNKPAY'   ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_PAYBIK" ,oModel:GetModel('RU06T02_MHEAD'):GetValue('F60_PAYBIK'   ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_PAYACC" ,oModel:GetModel('RU06T02_MHEAD'):GetValue('F60_PAYACC'   ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_PAYNAM" ,oModel:GetModel('RU06T02_MHEAD'):GetValue('F60_PAYNAM'   ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_VALUE"  ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_VALUE' ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_VATCOD" ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_VATCOD'))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_VATRAT" ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_VATRAT'))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_VATAMT" ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_VATAMT'))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_CTPRE"  ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_CTPRE' ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_CTPOS"  ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_CTPOS' ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_CCPRE"  ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_CCPRE' ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_CCPOS"  ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_CCPOS' ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_ITPRE"  ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_ITPRE' ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_ITPOS"  ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_ITPOS' ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_CLPRE"  ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_CLPRE' ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_CLPOS"  ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_CLPOS' ))
            oModelDst:GetModel("RU06D05_MF49"):LoadValue("F49_FILREQ" ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_FILIAL'))

            oModelDst:GetModel("RU06D05_MF4A"):SetNoUpdateLine(.F.)
            oModelDst:GetModel("RU06D05_MF4A"):LoadValue("F4A_IDF4A"  ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_IDF47' ))
            oModelDst:GetModel("RU06D05_MF4A"):LoadValue("F4A_IDF49"  ,oModelDst:GetModel('RU06D05_MF49' ):GetValue('F49_IDF49' ))
            oModelDst:GetModel("RU06D05_MF4A"):LoadValue("F4A_FILREQ" ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_FILIAL'))
            oModelDst:GetModel("RU06D05_MF4A"):LoadValue("F4A_CODREQ" ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_CODREQ'))
            oModelDst:GetModel("RU06D05_MF4A"):LoadValue("F4A_DTREQ"  ,oModelSrs:GetModel('RU06D04_MHEAD'):GetValue('F47_DTREQ' ))
            oModelDst:GetModel("RU06D05_MF4A"):SetNoUpdateLine(.T.)

            If !oModelSrs:GetModel('RU06D04_MLNS'):isempty()
                oModelDst:GetModel("RU06D05_MF4B"):SetNoInsertLine(.F.)
                nLenJ := oModelSrs:GetModel('RU06D04_MLNS'):length()
                For nJ := 1 to nLenJ - 1
                    oModelDst:GetModel("RU06D05_MF4B"):AddLine()
                Next nJ
                oModelDst:GetModel("RU06D05_MF4B"):SetNoInsertLine(.T.)

                oModelDst:GetModel("RU06D05_MF4B"):SetNoUpdateLine(.F.)
                For nJ := 1 to nLenJ
                    oModelDst:GetModel("RU06D05_MF4B"):GoLine(nJ)
                    oModelSrs:GetModel("RU06D04_MLNS"):GoLine(nJ)
                    oModelDst:GetModel("RU06D05_MF4B"):LoadValue("F4B_IDF4A"  ,oModelSrs:GetModel('RU06D04_MLNS'):GetValue('F48_IDF48' ))
                    oModelDst:GetModel("RU06D05_MF4B"):LoadValue("F4B_IDF49"  ,oModelDst:GetModel('RU06D05_MF49'):GetValue('F49_IDF49' ))
                    oModelDst:GetModel("RU06D05_MF4B"):LoadValue("F4B_PREFIX" ,oModelSrs:GetModel('RU06D04_MLNS'):GetValue('F48_PREFIX'))
                    oModelDst:GetModel("RU06D05_MF4B"):LoadValue("F4B_NUM"    ,oModelSrs:GetModel('RU06D04_MLNS'):GetValue('F48_NUM'   ))
                    oModelDst:GetModel("RU06D05_MF4B"):LoadValue("F4B_PARCEL" ,oModelSrs:GetModel('RU06D04_MLNS'):GetValue('F48_PARCEL'))
                    oModelDst:GetModel("RU06D05_MF4B"):LoadValue("F4B_TYPE"   ,oModelSrs:GetModel('RU06D04_MLNS'):GetValue('F48_TYPE'  ))
                    oModelDst:GetModel("RU06D05_MF4B"):LoadValue("F4B_VALPAY" ,oModelSrs:GetModel('RU06D04_MLNS'):GetValue('F48_VALREQ'))
                    oModelDst:GetModel("RU06D05_MF4B"):LoadValue("F4B_CONUNI" ,oModelSrs:GetModel('RU06D04_MLNS'):GetValue('F48_CONUNI'))
                    oModelDst:GetModel("RU06D05_MF4B"):LoadValue("F4B_VLIMP1" ,oModelSrs:GetModel('RU06D04_MLNS'):GetValue('F48_VLIMP1'))
                    oModelDst:GetModel("RU06D05_MF4B"):LoadValue("F4B_FLORIG" ,oModelSrs:GetModel('RU06D04_MLNS'):GetValue('F48_FLORIG'))
                    oModelDst:GetModel("RU06D05_MF4B"):LoadValue("F4B_EXGRAT" ,oModelSrs:GetModel('RU06D04_MLNS'):GetValue('F48_EXGRAT'))
                    oModelDst:GetModel("RU06D05_MF4B"):LoadValue("F4B_VALCNV" ,oModelSrs:GetModel('RU06D04_MLNS'):GetValue('F48_VALCNV'))
                    oModelDst:GetModel("RU06D05_MF4B"):LoadValue("F4B_BSVATC" ,oModelSrs:GetModel('RU06D04_MLNS'):GetValue('F48_BSVATC'))
                    oModelDst:GetModel("RU06D05_MF4B"):LoadValue("F4B_VLVATC" ,oModelSrs:GetModel('RU06D04_MLNS'):GetValue('F48_VLVATC'))
                    oModelDst:GetModel("RU06D05_MF4B"):LoadValue("F4B_RATUSR" ,oModelSrs:GetModel('RU06D04_MLNS'):GetValue('F48_RATUSR'))
                    oModelDst:GetModel("RU06D05_MF4B"):LoadValue("F4B_UUID" ,FWUUIDV4())
                Next nJ
                oModelDst:GetModel("RU06D05_MF4B"):SetNoUpdateLine(.T.)
            Endif

            If oModelDst:VldData()
                oModelDst:CommitData()

                oModelSrs:GetModel('RU06D04_MHEAD'):LoadValue("F47_STATUS","2")
                If oModelSrs:VldData()
                    oModelSrs:CommitData()

                    //Change status of List of Payments
                    oModel:GetModel('RU06T02_MHEAD'):LoadValue("F60_STATUS","5")
                    If oModel:VldData()
                        oModel:CommitData()
                    Else
                        lRet := .F.
                    EndIf
                Else
                    lRet := .F.
                EndIf
            Else
                lRet := .F.
                /*aLog := oModelDst:GetErrorMessage()
                For nX := 1 to Len(aLog)]
                    If !Empty(aLog[nX])
                        cLog += Alltrim(aLog[nX]) + CRLF
                    EndIf
                Next nX
                lMsErroAuto := .T.
                AutoGRLog(cLog)
                lRet := .F.*/
            EndIf
            oModelDst:DeActivate()
            oModelSrs:DeActivate()
        EndIf
    Next nI

    If !lRet
        DisarmTransaction()
        Break
    EndIf
End Transaction

return .T.

/*/{Protheus.doc} RU06T0293_Copy
Copy List of payments
@author Rafael Goncalves
@since 18.02.2020
@version 1.0
@project MA3 - Russia
/*/
Function RU06T0293_Copy(cCodReq as Character)
Local aCopyLns      as Array
Local oModel        as Object
Local nIniBal       as Numeric
Private cTempTbl    as Character //Temporary table alias(F47 Itens)
Private oTempTable  as Object

cTempTbl	:= CriaTrab(,.F.)

//Get lines that can be copy
/*
    Only Payment Request with F47_PAYTYP = 1;
    If the parameter MV_REQAPR = 1, only Approved Payment Request (F47_STATUS =='4') otherwise we must show Requests with the status created (F47_STATUS =='1');
    The Payment Request isn’t in other valid List of payment(F60_STATUS in 1 or 2 or 3);
    The payment Request isn’t in Payment Order (F47_PAYORD<>' ');
*/
aCopyLns  := RU06T0225_CheckifCopy(cCodReq) //return lines (F47 ID) that i can copy, using rules above

//Inser values at Model
oModel := FwLoadModel('RU06T02')
oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate(.T.)
//Copy Headers
oModel:GetModel("RU06T02_MHEAD"):SetValue("F60_DTPLA"   ,F60->F60_DTPLA )
oModel:GetModel("RU06T02_MHEAD"):LoadValue("F60_CURREN" ,F60->F60_CURREN  )
oModel:GetModel("RU06T02_MHEAD"):SetValue("F60_BNKPAY"  ,F60->F60_BNKPAY)
oModel:GetModel("RU06T02_MHEAD"):SetValue("F60_OBS"     ,F60->F60_OBS   )
nIniBal := RU06T0220_Write_values(.T.)[3]
oModel:GetModel("RU06T02_MHEAD"):SetValue("F60_INIBAL"  ,nIniBal) //Initial balance

//Load items
RU06T0205_CreateTable(.T., aCopyLns) //Add items at Temporary table
RU06T0207_WriteToModel(.T.)//White itens from temporary table at model

//Totals recalculation
RU06T0223_Write_values()

FWExecView(STR0051,"RU06T02",MODEL_OPERATION_INSERT,,{|| .T.},,,,,,,oModel) //Copy
oModel:DeActivate()

Return .T.


/*/{Protheus.doc} RU06T0293_Copy
Copy List of payments
@author Rafael Goncalves
@since 18.02.2020
@version 1.0
@project MA3 - Russia
/*/
Static Function RU06T0294_GetRecnoByID(cTable as Character,cIdField as Character,cID as Character)
Local nRecn as Numeric
Local cQuery as Character

Default cTable := ''
Default cID := ''
Default cIdField := ''
nRecn := 0
//Check if this item, was used in one valid list of payment (F60_STATUS in 1 or 2 or 3);
cQuery := ''
cQuery += "select R_E_C_N_O_ as Recn from " + RetSQLName(cTable)
cQuery += " where "+ cIdField +" = '" + cID + "' "
cQuery += " and D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
If SELECT("TMPLOADZ") > 0
    TMPLOADZ->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "TMPLOADZ", .T., .F.)
dbSelectArea("TMPLOADZ")
If (TMPLOADZ->(!Eof())) //Not found, could be copyed
    nRecn := TMPLOADZ->Recn
EndIf
TMPLOADZ->(DbCloseArea())


Return nRecn