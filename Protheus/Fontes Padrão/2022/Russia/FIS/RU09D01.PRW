#Include "Protheus.ch"
#Include "FwMVCDef.ch"
#Include "RU09D01.ch"

/*/{Protheus.doc} RU09D01
VAT Rates
@author felipe.morais
@since 02/06/2017
@version P12.1.16
@type function
/*/
Function RU09D01()
Local lRet as Logical
Local oBrowse as Object

Private aRotina as Array

PreLoad()

lRet := .T.
aRotina := MenuDef()

oBrowse := FwMBrowse():New()
oBrowse:SetAlias("F30")
oBrowse:SetDescription(STR0001)
oBrowse:Activate()
Return(lRet)

/*/{Protheus.doc} ModelDef
VAT Rates - Model
@author felipe.morais
@since 02/06/2017
@version P12.1.16
@type function
/*/
Static Function ModelDef()
Local oModel as Object
Local oStrF30 as Object

oStrF30 := FWFormStruct(1, "F30")
oModel := MPFormModel():New("RU09D01")

oModel:AddFields("F30MASTER", Nil, oStrF30)
oModel:SetPrimaryKey({"F30_FILIAL", "F30_CODE"})
Return(oModel)

/*/{Protheus.doc} ViewDef
VAT Rates - View
@author felipe.morais
@since 02/06/2017
@version P12.1.16
@type function
/*/
Static Function ViewDef()
Local oView as Object
Local oModel as Object
Local oStrF30 as Object

oModel := ModelDef()
oStrF30 := FWFormStruct(2, "F30")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("F30", oStrF30, "F30MASTER")
Return(oView)

/*/{Protheus.doc} MenuDef
VAT Rates - View
@author felipe.morais
@since 02/06/2017
@version P12.1.16
@type function
/*/
Static Function MenuDef()
Local aRet as Array

aRet := {{STR0002, "VIEWDEF.RU09D01", 0, 2, 0, Nil}}
Return(aRet)

/*/{Protheus.doc} PreLoad
VAT Rates - Load default records.
@author felipe.morais
@since 02/06/2017
@version P12.1.16
@type function
/*/
Static Function PreLoad()
Local lRet := .T.
Local aArea := GetArea()
Local aAreaF30 := F30->(GetArea())

Local lAdd as Logical
Local nItem as Numeric
Local cCode as Character
Local aF30Data := {}

DbSelectArea("F30")
F30->(DbSetOrder(1))

aAdd(aF30Data, {"18%",      "18",       "2"})
aAdd(aF30Data, {"10%",      "10",       "2"})
aAdd(aF30Data, {"18/118",   "18/118",   "2"})
aAdd(aF30Data, {"10/110",   "10/110",   "2"})
aAdd(aF30Data, {"0%",       "0",        "2"})
aAdd(aF30Data, {"No VAT",   "0",        "1"})
aAdd(aF30Data, {"20%",      "20",       "2"})
aAdd(aF30Data, {"20/120",   "20/120",   "2"})

For nItem := 1 to Len(aF30Data)
    cCode := StrZero(nItem, GetSX3Cache("F30_CODE", "X3_TAMANHO"))
    lAdd := ! F30->(DbSeek(xFilial("F30") + cCode))

    RecLock("F30", lAdd)
    F30->F30_FILIAL := xFilial("F30")
    F30->F30_CODE := cCode
    F30->F30_DESC := aF30Data[nItem][1]
    F30->F30_RATE := aF30Data[nItem][2]
    F30->F30_EXEMPT := aF30Data[nItem][3]
    F30->(MsUnlock())
Next nItem

RestArea(aAreaF30)
RestArea(aArea)
Return(lRet)
