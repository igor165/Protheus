#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU01D02.CH"

/*/{Protheus.doc} RU01D02
(long_description)
@type function
@author Felipe Morais
@since 13/01/2017
@version 1.0
@return ${return}, ${return_description}
@see (links_or_references)
/*/

Function RU01D02()
Local lRet as Logical
Local oBrowse as Object

Private aRotina as Array

lRet := .T.

aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("FM1")
oBrowse:SetDescription(STR0001) //"Depreciation Groups"
oBrowse:SetAttach(.T.)
oBrowse:Activate()
Return(lRet)

/*/{Protheus.doc} MenuDef
(long_description)
@type function
@author Felipe Morais
@since 13/01/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function MenuDef()
Local aRet as Array

aRet := {{STR0002, "VIEWDEF.RU01D02", 0, 2, 0, Nil},;
		{STR0003, "VIEWDEF.RU01D02", 0, 3, 0, Nil},;
		{STR0004, "VIEWDEF.RU01D02", 0, 4, 0, Nil},;
		{STR0005, "VIEWDEF.RU01D02", 0, 5, 0, Nil}}
Return(aRet)

/*/{Protheus.doc} ModelDef
(long_description)
@type function
@author Felipe Morais
@since 13/01/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function ModelDef()
Local oModel as Object
Local oStrFM1 as Object

oStrFM1 := FWFormStruct(1, "FM1")
oModel := MPFormModel():New("RU01D02", , {|oMdl| RU01D02A(oMdl)}, , )

oModel:AddFields("FM1MASTER", Nil, oStrFM1)
oModel:SetPrimaryKey({"FM1_FILIAL", "FM1_CODE"})
Return(oModel)

/*/{Protheus.doc} ViewDef
(long_description)
@type function
@author Felipe Morais
@since 13/01/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function ViewDef()
Local oView as Object
Local oModel as Object
Local oStrFM1 as Object

oModel := ModelDef()
oStrFM1 := FWFormStruct(2, "FM1")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("FM1", oStrFM1, "FM1MASTER")
Return(oView)

/*/{Protheus.doc} RU01D02A
(long_description)
@type function
@author Felipe Morais
@since 13/01/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Function RU01D02A(oModel as Object)
Local nOperation as Numeric
Local lRet as Logical
Local nI as Numeric
Local aArea as Object
Local aAreaSZC as Object

nOperation := oModel:GetOperation()
lRet := .T.
nI := 0
aArea := GetArea()
aAreaSZC := FM2->(GetArea())

If (nOperation == MODEL_OPERATION_DELETE)
	DbSelectArea("FM2")
	FM2->(DbSetOrder(1))
	If (FM2->(DbSeek(xFilial("FM2") + FM1->FM1_CODE)))
		lRet := .F.
	Endif
Endif

RestArea(aAreaSZC)
RestArea(aArea)
Return(lRet)

//merge branch 12.1.19
// Russia_R5
