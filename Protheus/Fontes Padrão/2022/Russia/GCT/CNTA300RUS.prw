#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CNTA300.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} QIEA030RUS
Contract management master data (Russia)

@author Andrews Egas
@since 21/03/2016
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Function CNTA300RUS()
Local oBrowse as object

SetKey(VK_F12,{|| Pergunte("CNT100",.T.)})
Pergunte("CNT100",.F.)
oBrowse := BrowseDef()
oBrowse:Activate()
SetKey(VK_F12,Nil)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Andrews Egas
@since 21/03/2016
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse as object

oBrowse := FWLoadBrw("CNTA300")

Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu definition

@author Andrews Egas
@since 21/03/2016
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina :=  FWLoadMenuDef("CNTA300")

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model
@author 	Andrews Egas
@since 		21/03/2016
@version 	1.0
@project	MA3
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel as object

oModel 	:= FwLoadModel('CNTA300')


Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface
@author 	Andrews Egas
@since 		21/03/2016
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	as object
Local oView		as object

oView	:= FWLoadView("CNTA300")

SetKey(VK_F2,{|| TDFieldActv()})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CNTA300CNA_Filter
Function for filter in F5QCNA standard query.
@author 	Cherchik Konstantin
@since 		14/02/2019
@version 	P12.1.25
@type       function
@project    MA3
/*/
//-------------------------------------------------------------------

Function CNTA300CNA_Filter()
Local lRet := .F.

If FwFldGet("CN9_ESPCTR") == "1"    // 1 = Purchase / 2 = Sales  
    If !Empty(FwFldGet("CNA_FORNEC")) .AND. !Empty(FwFldGet("CNA_LJFORN"))
        If (FwFldGet("CNA_FORNEC") == F5Q->F5Q_A2COD .AND. FwFldGet("CNA_LJFORN") == F5Q->F5Q_A2LOJ)
            lRet := .T.
        EndIf
    EndIf
Else
    If !Empty(FwFldGet("CNA_CLIENT")) .AND. !Empty(FwFldGet("CNA_LOJACL"))
        If (FwFldGet("CNA_CLIENT") == F5Q->F5Q_A1COD .AND. FwFldGet("CNA_LOJACL") == F5Q->F5Q_A1LOJ)
            lRet := .T.
        EndIf
    EndIf 
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CNTA300SRC_Info()
Function for triggers in CNA_FORNEC, CNA_LJFORN, CNA_CLIENT, CNA_LOJACL fields.
@author 	Cherchik Konstantin
@since 		15/02/2019
@version 	P12.1.25
@type       function
@project    MA3
/*/
//-------------------------------------------------------------------

Function CNTA300SRC_Info()
Local oModel     as Object 
Local oView      as Object
Local oModelCN9  as Object
Local oModelCNA  as Object
Local oGridObj	 as Object
Local cLegContr  as Character
Local cContrCode as Character
Local cSupplier  as Character
Local cCustomer  as Character
Local cSuppLoja  as Character
Local cCustLoja  as Character
Local nX         as Numeric

oModel    := FwModelActive()
oView     := FwViewActive()

If ValType(oModel) == "O" .And. oModel:GetId() == "CNTA300" .And. ValType(oView) == "O"
    oModelCN9 := oModel:GetModel("CN9MASTER") 
    oModelCNA := oModel:GetModel("CNADETAIL") 
    oGridObj  := oView:GetViewObj("CNADETAIL")[3]	// Registering this grid as static to make it refreshable from every moment
    cLegContr := AllTrim(oModelCN9:GetValue("CN9_F5QCOD"))

    If oModelCN9:GetValue("CN9_ESPCTR") == "1"
        cSupplier := AllTrim(oModelCNA:GetValue("CNA_FORNEC"))
        cSuppLoja := AllTrim(oModelCNA:GetValue("CNA_LJFORN"))
        If !EMPTY(cLegContr) .And. cSupplier == AllTrim(Posicione("F5Q",2,xFilial("F5Q")+cLegContr,"F5Q_A2COD")) .And. cSuppLoja == AllTrim(Posicione("F5Q",2,xFilial("F5Q")+cLegContr,"F5Q_A2LOJ"))
            cContrCode := cLegContr
        EndIf 
    ElseIf oModelCN9:GetValue("CN9_ESPCTR") == "2"
        cCustomer := AllTrim(oModelCNA:GetValue("CNA_CLIENT"))
        cCustLoja := AllTrim(oModelCNA:GetValue("CNA_LOJACL"))
        If !EMPTY(cLegContr) .And. cCustomer == AllTrim(Posicione("F5Q",2,xFilial("F5Q")+cLegContr,"F5Q_A1COD")) .And. cCustLoja == AllTrim(Posicione("F5Q",2,xFilial("F5Q")+cLegContr,"F5Q_A1LOJ"))
            cContrCode := cLegContr 
        EndIf
    EndIf

    For nX := 1 to oModelCNA:Length()
        oModelCNA:GoLine(nX)
        If oModelCN9:GetValue("CN9_ESPCTR") == "1"
            If AllTrim(oModelCNA:GetValue("CNA_FORNEC")) == cSupplier .And. AllTrim(oModelCNA:GetValue("CNA_LJFORN")) == cSuppLoja .And. !EMPTY(AllTrim(oModelCNA:GetValue("CNA_F5QCOD")))
                cContrCode := AllTrim(oModelCNA:GetValue("CNA_F5QCOD"))
            EndIf
        ElseIf oModelCN9:GetValue("CN9_ESPCTR") == "2"
            If AllTrim(oModelCNA:GetValue("CNA_CLIENT")) == cCustomer .And. AllTrim(oModelCNA:GetValue("CNA_LOJACL")) == cCustLoja .And. !EMPTY(AllTrim(oModelCNA:GetValue("CNA_F5QCOD")))
                cContrCode := AllTrim(oModelCNA:GetValue("CNA_F5QCOD"))
            EndIf
        EndIf
    Next nX

EndIf

Return cContrCode

//-------------------------------------------------------------------
/*/{Protheus.doc} CNTA300REP_Info()
Function for trigger in CN9_F5QCOD.
@author 	Cherchik Konstantin
@since 		15/02/2019
@version 	P12.1.25
@type       function
@project    MA3
/*/
//-------------------------------------------------------------------

Function CNTA300REP_Info()
Local oModel    as Object 
Local oView     as Object
Local oModelCN9 as Object
Local oModelCNA as Object
Local oGridObj	as Object
Local cLegContr as Character
Local cSupplier as Character
Local cCustomer as Character
Local cSuppLoja as Character
Local cCustLoja as Character
Local nX        as Numeric
 
oModel    := FwModelActive()
oView     := FwViewActive()

If ValType(oModel) == "O" .And. oModel:GetId() == "CNTA300"

    oModelCN9 := oModel:GetModel("CN9MASTER")
    oModelCNA := oModel:GetModel("CNADETAIL") 
    oGridObj := oView:GetViewObj("CNADETAIL")[3]	// Registering this grid as static to make it refreshable from every moment
    cLegContr := AllTrim(oModelCN9:GetValue("CN9_F5QCOD"))

    For nX := 1 to oModelCNA:Length()
        oModelCNA:GoLine(nX)
        If oModelCN9:GetValue("CN9_ESPCTR") == "1"
            cSupplier := AllTrim(Posicione("F5Q",2,xFilial("F5Q")+cLegContr,"F5Q_A2COD"))
            cSuppLoja := AllTrim(Posicione("F5Q",2,xFilial("F5Q")+cLegContr,"F5Q_A2LOJ"))
            If AllTrim(oModelCNA:GetValue("CNA_FORNEC")) == cSupplier .And. AllTrim(oModelCNA:GetValue("CNA_LJFORN")) == cSuppLoja
                oModelCNA:SetValue("CNA_F5QCOD",cLegContr)
            EndIf
        ElseIf oModelCN9:GetValue("CN9_ESPCTR") == "2"
            cCustomer := AllTrim(Posicione("F5Q",2,xFilial("F5Q")+cLegContr,"F5Q_A1COD"))
            cCustLoja := AllTrim(Posicione("F5Q",2,xFilial("F5Q")+cLegContr,"F5Q_A1LOJ"))
            If AllTrim(oModelCNA:GetValue("CNA_CLIENT")) == cCustomer .And. AllTrim(oModelCNA:GetValue("CNA_LOJACL")) == cCustLoja
                oModelCNA:SetValue("CNA_F5QCOD",cLegContr)
            EndIf
        EndIf
    Next nX

    oGridObj:Refresh( .T. /* lEvalChanges */, .T. /* lGoTop */)

EndIf

Return cLegContr

/*{Protheus.doc} CNTA300EventRUS
@type 		class
@author Konstantin Cherchik 
@since 25/02/2019
@version P12.1.25
@description Class to handle business procces of CNTA300RUS
*/

Class CNTA300EventRUS From FwModelEvent 
		
	Method New() CONSTRUCTOR
    Method GridLinePosVld()
				
EndClass

Method New() Class CNTA300EventRUS
Return Nil

/*{Protheus.doc} CNTA300EventRUS
@type 		method
@author Konstantin Cherchik 
@since 25/02/2019
@version P12.1.25
@description Grid line pos validation in Spreadsheets
*/
Method GridLinePosVld(oSubModel, cSubModelID) Class CNTA300EventRUS
Local lRet as Logical

lRet := .T.

If lRet .And. (cSubModelID == "CNADETAIL") .And. !Empty(oSubModel:GetValue("CNA_F5QUID"))
    If M->CN9_MOEDA != Posicione('F5Q', 1, xFilial('F5Q') + oSubModel:GetValue("CNA_F5QUID"), 'F5Q_MOEDA')
        lRet := .F.
        Help("",1,"CNTA300",,STR0291,1,0)
    ElseIf M->CN9_CONUNI != Posicione('F5Q', 1, xFilial('F5Q') + oSubModel:GetValue("CNA_F5QUID"), 'F5Q_CONUNI')
        lRet := .F.
        Help("",1,"CNTA300",,STR0292,1,0)
    ElseIf AllTrim(oSubModel:GetValue("CNA_FORNEC")) != AllTrim(Posicione('F5Q', 1, xFilial('F5Q') + oSubModel:GetValue("CNA_F5QUID"), 'F5Q_A2COD'))
        lRet := .F.
        Help("",1,"CNTA300",,STR0293,1,0)
    ElseIf AllTrim(oSubModel:GetValue("CNA_LJFORN")) != AllTrim(Posicione('F5Q', 1, xFilial('F5Q') + oSubModel:GetValue("CNA_F5QUID"), 'F5Q_A2LOJ'))
        lRet := .F.
        Help("",1,"CNTA300",,STR0294,1,0)
    ElseIf AllTrim(oSubModel:GetValue("CNA_CLIENT")) != AllTrim(Posicione('F5Q', 1, xFilial('F5Q') + oSubModel:GetValue("CNA_F5QUID"), 'F5Q_A1COD'))
        lRet := .F.
        Help("",1,"CNTA300",,STR0295,1,0)
    ElseIf AllTrim(oSubModel:GetValue("CNA_LOJACL")) != AllTrim(Posicione('F5Q', 1, xFilial('F5Q') + oSubModel:GetValue("CNA_F5QUID"), 'F5Q_A1LOJ'))
        lRet := .F. 
        Help("",1,"CNTA300",,STR0296,1,0)
    EndIf
EndIf

Return lRet