#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//#INCLUDE "RU07T11.CH"

/*/

{Protheus.doc} RU07T11
    HR Referencies File

    @author Fedorova Anna
    @since 30/09/2019
    @version 1.0
    @project MA3 - Russia
Function RU07T11()
    Local oBrowse As Object

    DBselectarea("F6H")
    oBrowse := BrowseDef()
    oBrowse:Activate()

Return

{Protheus.doc} ModelDef
    Model definition

    @author Fedorova Anna
    @since 30/09/2019
    @version 1.0
    @project DMA3 - Russia

Static Function ModelDef()
    Local oModel As Object
    Local oStruF6H := FWFormStruct(1, "F6H")

    oModel := MPFormModel():New("RU07T11")
    oModel:AddFields("F6HMASTER",, oStruF6H)

Return oModel


{Protheus.doc} ViewDef
    View definition

    @author Fedorova Anna
    @since 30/09/2019
    @version 1.0
    @project DMA3 - Russia

Static Function ViewDef()
    Local oStruct As Object
    Local oView As Object

    oView := FWFormView():New()
    oStruct	:= FWFormStruct(2, "F6H")

    oView:SetContinuousForm()
    oView:AddField("F6H", oStruct, "F6HMASTER")
    oView:SetModel(FWLoadModel("RU07T11"))

Return oView


{Protheus.doc} MenuDef
    Menu definition

    @author Fedorova Anna
    @since 30/09/2019
    @version 1.0
    @project DMA3 - Russia

Static Function MenuDef()

    Private aRotina := {} // Private because it can be called by gpeaa010 or another routine

    aAdd(aRotina, {STR0HR002, "VIEWDEF.RU07T11", 0, 2, 0, NIL}) // View
    aAdd(aRotina, {STR0HR003, "VIEWDEF.RU07T11", 0, 3, 0, NIL}) // Add
    aAdd(aRotina, {STR0HR004, "VIEWDEF.RU07T11", 0, 4, 0, NIL}) // Edit
    aAdd(aRotina, {STR0HR005, "VIEWDEF.RU07T11", 0, 5, 0, NIL}) // Delete

Return aRotina


{Protheus.doc} BrowseDef
    Browse definition

    @author Fedorova Anna
    @since 30/09/2019
    @version 1.0
    @project DMA3 - Russia

Static Function BrowseDef()
    Local oBrowse As Object

    oBrowse := FWMBrowse():New()

    oBrowse:SetAlias("F6H")
    oBrowse:SetDescription(STR0HR001)
    oBrowse:SetMenuDef("RU07T11")

Return oBrowse

/*
{Protheus.doc} RU07T11SXB
    Function Standart Queries

    @author Prokhorenko Igor
    @since 30/01/2020
    @version 1.0
    @project DMA3 - Russia
*/
Function RU07T11SXB(cFilter)
    Local oParent As Object
    Local aSize As Array
    Local oBrowse := Nil

    Private aRotina As Array
    
    aSize :=  {}
    aSize := aSize(aSize,4)

    aSize[1] := 0
    aSize[2] := 0
    aSize[3] := 600
    aSize[4] := 800

    oBrowse := FWMBrowse():New()

    oBrowse:SetAlias('SX3')
    oParent := MsDialog():New(aSize[1], aSize[2], aSize[3], aSize[4], 'SX3', , , , , , , , ,.T. , ,  )

    oBrowse:SetOwner(oParent)

    oBrowse:SetFilterDefault('SX3->X3_ARQUIVO=="' + cFilter + '"')

    SX3->(DbSetOrder(1))

    blDblClick := {|| VAR_IXB:=SX3->X3_CAMPO, oParent:End()}

    oBrowse:SetMenuDef( '' ) 

    aFields := {}

    AAdd(aFields,{'X3_ARQUIVO',{ || SX3->X3_ARQUIVO } ,'C',"@!","0",3 ,'',.F.,{|| .T.},.F.,blDblClick,,{|| .T.},.F.,.F.,{} })
    AAdd(aFields,{'X3_CAMPO'  ,{ || SX3->X3_CAMPO   } ,'C',"@!","0",10,'',.F.,{|| .T.},.F.,blDblClick,,{|| .T.},.F.,.F.,{} })

    oBrowse:SetColumns(aFields)

    oBrowse:SetDBFFilter( .T. )
    oBrowse:Activate()
    oParent:Activate(,,,.T.,,,)

Return .T.
/*/
