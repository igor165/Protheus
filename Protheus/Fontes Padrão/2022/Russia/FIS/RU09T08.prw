#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'
#include 'topconn.ch'
#include 'RU09XXX.ch'
#include 'RU09T08.ch'


/*/{Protheus.doc} RU09T08
VAT Restoration
@author Artem Kostin
@since 26/07/2018
@version P12.1.21
@type function
/*/
Function RU09T08()
Local lRet := .T.
Local oBrowse as Object
Public nValAnt as Numeric//this variable is used on CT5 table, to be possible knows the value before edit the register
Public aValAnt as Array//this variable is use to store all values on itens before edit the register
SetKey(VK_F12, {||AcessaPerg("RU09T06ACC",.T.)})
// Initalization of tables, if they do not exist.
DbSelectArea("F32")
F32->(dbSetOrder(1))
DbSelectArea("F34")
F34->(dbSetOrder(1))
DbSelectArea("F52")
F52->(dbSetOrder(1))
DbSelectArea("F53")
F53->(dbSetOrder(1))
DbSelectArea("F54")
F54->(dbSetOrder(1))

oBrowse := FWLoadBrw("RU09T08")
oBrowse:Activate()
Return(lRet)
// The end of Function RU09T08()



/*/{Protheus.doc} BrowseDef
Defines the browser for the VAT Restoration
@author Artem Kostin
@since 26/07/2018
@version P12.1.21
@type function
/*/
Static Function BrowseDef()
Local oBrowse as Object

Private aRotina as Array

aRotina := MenuDef()
oBrowse := FwMBrowse():New()

oBrowse:SetAlias("F52")
oBrowse:SetDescription(STR0001)
oBrowse:DisableDetails()
Return(oBrowse)



/*/{Protheus.doc} MenuDef
Defines the menu for the VAT Restoration
@author Artem Kostin
@since 26/07/2018
@version P12.1.21
@type function
/*/
Static Function MenuDef()
Local aButtons	:= {}
aButtons := {{STR0003, "FwExecView('" + STR0003 + "', 'RU09T08', " + STR(MODEL_OPERATION_VIEW) + ")", 0, 2, 0, Nil},;
            {STR0004, "FwExecView('" + STR0004 + "', 'RU09T08', " + STR(MODEL_OPERATION_INSERT) + ")", 0, 3, 0, Nil},;
            {STR0005, "FwExecView('" + STR0005 + "', 'RU09T08', " + STR(MODEL_OPERATION_UPDATE) + ")", 0, 4, 0, Nil},;
            {STR0006, "FwExecView('" + STR0006 + "', 'RU09T08', " + STR(MODEL_OPERATION_DELETE) + ")", 0, 5, 0, Nil},;
            {STR0021, "CTBC662", 0, 2, 0, Nil},; //"Track Posting"
            {STR0022,"RU09T08CTB_VATREST",0,7,0,Nil},;
            {STR0023,"RU09T08CTS_VATREST",0,7,0,Nil}}
Return aButtons
// The end of Function MenuDef()



/*/{Protheus.doc} ModelDef
Creates the model for the VAT Restoration
@author Artem Kostin
@since 26/07/2018
@version P12.1.21
@type function
/*/
Static Function ModelDef()
Local oModel as Object

Local oStructF52 as Object
Local oStructF53 as Object

Local oModelEvent as Object

oStructF52 := FWFormStruct(1, "F52")
oStructF53 := FWFormStruct(1, "F53")

oModel := MPFormModel():New("RU09T08", /* Pre-valid */, /* Pos-Valid */, /* Commit */)

oStructF53:AddField("RestoBsBkp", "Restored Base Backup", "F53_RBSBKP", "N", 16, 2, {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., "")
oStructF53:AddField("RestoVlBkp", "Restored Value Backup", "F53_RVLBKP", "N", 16, 2, {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., "")
oStructF53:AddField("NewVATCodBkp", "New VAT Code Backup", "F53_NVTCDB", "C", 5, 0, {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., "")

oModel:AddFields("F52MASTER", /*cOwner*/, oStructF52)
oModel:AddGrid("F53DETAIL", "F52MASTER", oStructF53)
oModel:GetModel('F52MASTER'):SetDescription(STR0001)
oModel:GetModel('F53DETAIL'):SetDescription(STR0002)

oModel:SetRelation("F53DETAIL", {{"F53_FILIAL", "xFilial('F53')"}, {"F53_RESKEY", "F52_RESKEY"}}, F53->(IndexKey(1)))

oModel:GetModel("F53DETAIL"):SetOptional(.T.)

oModelEvent 	:= RU09T08EventRUS():New()
oModel:InstallEvent("oModelEvent", /*cOwner*/, oModelEvent)

Return(oModel)
// The end of Function ModelDef()



/*/{Protheus.doc} ViewDef
Creates the view for the VAT Restoration
@author Artem Kostin
@since 26/07/2018
@version P12.1.21
@type function
/*/
Static Function ViewDef()
Local oModel := FwLoadModel("RU09T08")

Local oView as Object
Local oStructF52 := FWFormStruct(2, "F52")
Local oStructF53 := FWFormStruct(2, "F53")
Local oStructTotal := FWFormStruct(2, "F52", {|x| (x == "F52_TOTAL ")})

Local oModelEvent as Object

Local aCmpF52 as Array
Local aCmpF53 as Array

Local nI as Numeric

// Defines which fields we don't need to show on the screen.
aCmpF52 := {"F52_RESKEY", "F52_TOTAL"}
For nI := 1 to len(aCmpF52)
    oStructF52:RemoveField(aCmpF52[nI])
Next nI
If (INCLUI)
    oStructF52:RemoveField("F52_CODE")
EndIf

// Defines which fields we don't need to show on the screen.
aCmpF53 := {"F53_RESKEY", "F53_KEY", "F53_ITEM", "F53_AVLBBS", "F53_AVLBVL"}
For nI := 1 to len(aCmpF53)
    oStructF53:RemoveField(aCmpF53[nI])
Next nI

oView := FWFormView():New()
oView:setModel(oModel)
oView:AddField("F52_M", oStructF52, "F52MASTER")
oView:AddGrid("F53_D", oStructF53, "F53DETAIL")
oView:AddField("F52_T", oStructTotal, "F52MASTER")

oView:SetViewProperty("F53_D", "GRIDDOUBLECLICK", {{|oModelGrid, cField, nLineGrid, nLineModel| RU09T08PIn(oModelGrid, cField, nLineGrid, nLineModel)}})

oView:CreateHorizontalBox("HEADERBOX", 25)
oView:CreateHorizontalBox("ITEMBOX", 65)
oView:CreateHorizontalBox("TOTALBOX", 10)

oView:setOwnerView("F52_M", "HEADERBOX")
oView:setOwnerView("F53_D", "ITEMBOX")
oView:setOwnerView("F52_T", "TOTALBOX")

// If Write-Off is opened and not automatic and operation is Insertion or Update.
If (INCLUI .or. ALTERA)
    oModelEvent 	:= RU09T08EventRUS():New()
    oView:AddUserButton(STR0946, "", {|| oModelEvent:FiltVATInvoices(oModel)})
EndIf

oView:AddUserButton(STR0907, '', {|| RU09T08PIn()})

oView:setDescription(STR0001)
oView:setCloseOnOk({|| .T.})
Return(oView)
// The end of Function ViewDef()



/*{Protheus.doc} RU09T08PIn
@author Artem Kostin
@since 30/07/2018
@version P12.1.21
@param None
@return lRet as Logical
@type function
@description open View of checked Inflow VAT Invoice
*/
Function RU09T08PIn(oModelGrid, cField, nLineGrid, nLineModel)
Local lRet := .T.
// Working areas
Local aArea as Array
Local aAreaF37 as Array
Local aAreaF38 as Array

// Keys for dbSeek()
Local cKeyF37 as Character

Default cField := "ZZZZZZZZZZ"
Default nLineGrid := 0
Default nLineModel := 0

aArea := GetArea()
aAreaF37 := F37->(GetArea())
aAreaF38 := F38->(GetArea())

DbSelectArea("F37")
F37->(DbSetOrder(3))

cKeyF37 := AllTrim(FWFldGet("F53_KEY"))

If (! (cField $ "F53_DOC   |F53_NTGCOD|F53_NVTCOD|F53_RESTRT|F53_RESTBS|F53_RESTVL"));
.and. !Empty(FWFldGet("F53_KEY")) .and. (F37->(DbSeek(xFilial('F37') + cKeyF37)))
    lRet := .F.
	FwExecView(STR0009, "RU09T03", MODEL_OPERATION_VIEW, /* oDlg */, {|| .T.})
EndIf

RestArea(aAreaF38)
RestArea(aAreaF37)
RestArea(aArea)
Return(lRet)

Function RU09T08CTL_View()
Local oModel as Object

oModel:= FwLoadModel("RU09T08")
oModel:SetOperation(MODEL_OPERATION_VIEW)
oModel:Activate()

FwExecView(STR0902, "RU09T08", MODEL_OPERATION_VIEW,/* oDlg */, /*{|| .T.}*/,/* ok */,/*nPercReducation*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel)
Return

Function RU09T08CTB_VATREST()
Local oModel as Object
Local lEnt as Logical
lEnt:=.T.
oModel:= FwLoadModel("RU09T08")
oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate()
Begin Transaction
If Empty(F52->F52_DTLA)
    ctbVATrest(oModel,lEnt)
EndIf
End Transaction
Return

Function RU09T08CTS_VATREST()
Local oModel as Object
Local lEnt as Logical
lEnt:=.F.
oModel:= FwLoadModel("RU09T08")
oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate()
Begin Transaction

If !Empty(F52->F52_DTLA)
    ctbVATrest(oModel,lEnt)
EndIf
End Transaction
Return

/*/{Protheus.doc} ctbVATpurb
Function thats posts accounting entries.
@author Sergeeva Daria
@since 13/02/2020
@version P12.1.16
@param oModel, object, Needs to receive the actual model.
@param lInc, logical, Needs to inform it is an inclusion or not.
@type function
/*/

Static Function ctbVATrest(oModel as Object, lInc as Logical)
Local lRet as Logical
Local oModelF52 as Object
Local oModelF53 as Object
Local nHdlPrv as Numeric
Local cLoteFis as Character
Local cOrigem as Character
Local cArquivo as Character
Local nTotal as Numeric
Local lCommit as Logical
Local cPadrao as Character
Local lMostra as Logical
Local lAglutina as Logical
Local cPerg as Character
// Used areas
Local aArea as Array
Local aAreaF37 as Array
Local aAreaF38 as Array
Local aAreaSF1 as Array
Local aAreaSA2 as Array
lRet := .T.
oModelF52 := oModel:GetModel("F52MASTER")
oModelF53 := oModel:GetModel("F53DETAIL")
nTotal := 0
aArea := GetArea()
aAreaF37 := F37->(GetArea())
aAreaF38 := F38->(GetArea())
aAreaSF1 := SF1->(GetArea())
aAreaSA2 := SA2->(GetArea())
cPerg := "RU09T08ACC"

Pergunte(cPerg, .F.)
lMostra := (mv_par01 == 1)
lAglutina := (mv_par02 == 1)

nHdlPrv := 0
cLoteFis := LoteCont("FIS")
cOrigem := "RU09T08ACC"
cArquivo := " "
lCommit := .F.
// If it is an inclusion, must be used the Standard Entry 6AE to the header.
// If it is a deletion, must be used the Standard Entry 6AF to the header.
cPadrao := Iif(lInc, "6AI", "6AJ")
If VerPadrao(cPadrao) // Accounting beginning
    nHdlPrv := HeadProva(cLoteFis, cOrigem, SubStr(cUserName, 1, 6), @cArquivo)
	If lInc
        oModelF52:SetValue("F52_DTLA",dDataBase)    
        FWFormCommit(oModel)    
    Else
        oModelF52:SetValue("F52_DTLA",stod(""))
		FWFormCommit(oModel)    
    EndIf
EndIf

//Seek oon F3C
DbSelectArea("F53")
F53->(DbSetOrder(1))
If(F53->(DbSeek(xFilial("F53")+oModelF52:GetValue("F52_RESKEY"))))
    //While KEY on F3C is equal to key
    While (F53->(!Eof())) .And. (xFilial("F53")+oModelF52:GetValue("F52_RESKEY"))==F53->(F53_FILIAL+F53_RESKEY)
        DbSelectArea("F37")
        F37->(DbSetOrder(7))
        If(F37->(DbSeek(xFilial("F37")+oModelF53:GetValue("F53_DOC"))))
            DbSelectArea("SF1")
            SF1->(DbSetOrder(1))
            If (F37->F37_TYPE == "2") .and. !(SF1->(DbSeek(xFilial("SF1") + SubStr(F37->F37_INVDOC, 1, TamSX3("F1_DOC")[1]) + SubStr(F37->F37_INVSER, 1, TamSX3("F1_SERIE")[1]))))
                lRet := .F.
            EndIf
            
            If lRet
                DbSelectArea("SA2")
                SA2->(DbSetOrder(1))
                If !SA2->(DbSeek(xFilial("SA2") + F37->F37_FORNEC + F37->F37_BRANCH))
                    lRet:= .F.
                EndIf
            EndIf
        Else
            Help("",1,"RU09T08_ctbVATrest_F37",,/*STR0023*/,1,0) // "VAT Sales Invoice Header of this record was not found. Cannot delete this record."
            lRet:= .F.
        EndIf
        If lRet
            nValAnt := 0
            nPosnAt := aScan(aValAnt,{|x| x[1] == F53->(Recno()) })
            If nPosnAt > 0
                nValAnt := aValAnt[nPosnAt,2]
            EndIf
            If (nHdlPrv > 0)
                nTotal += DetProva(nHdlPrv, cPadrao, cOrigem, cLoteFis, /*nLinha*/, /*lExecuta*/,/*cCriterio*/, /*lRateio*/, ;
                xFilial("F52") + F52->F52_RESKEY /*cChaveBusca */, /*aCT5*/,;
            /*lPosiciona*/, /*@aFlagCTB*/, {'F52',F52->(Recno())} /*aTabRecOri*/, /*aDadosProva*/)  
            EndIf
        EndIf    
        F53->(DbSkip())
    EndDo
EndIf    
If (nTotal > 0)
    cA100Incl(cArquivo, nHdlPrv, 3, cLoteFis, lMostra, lAglutina)
EndIf
RodaProva(nHdlPrv, nTotal)

RestArea(aArea)
RestArea(aAreaF37)
RestArea(aAreaF38)
RestArea(aAreaSF1)
RestArea(aAreaSA2)

Return(lRet)