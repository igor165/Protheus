#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU01D03.CH"

/*/{Protheus.doc} RU01D03
(long_description)
@type function
@author Felipe Morais
@since 13/01/2017
@version 1.0
@return ${return}, ${return_description}
@see (links_or_references)
/*/

Function RU01D03()
Local lRet as Logical
Local oBrowse as Object

Private aRotina as Array

lRet := .T.

aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("FM2")
oBrowse:SetDescription(STR0001) //"Dep. Grp. x OKOF Codes"
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

aRet := {{STR0003, "VIEWDEF.RU01D03", 0, 2, 0, Nil},;
		{STR0004, "VIEWDEF.RU01D03", 0, 3, 0, Nil},;
		{STR0005, "VIEWDEF.RU01D03", 0, 4, 0, Nil},;
		{STR0006, "VIEWDEF.RU01D03", 0, 5, 0, Nil}}
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
Local oStrSZ1 as Object
Local oStrSZ2 as Object

oStrSZ1 := FWFormStruct(1, "FM2", {|x| AllTrim(x) $ "FM2_GROUP|FM2_GRPNAM"})
oStrSZ2 := FWFormStruct(1, "FM2", {|x| AllTrim(x) $ "FM2_OKOF|FM2_OKOFNM"})
oModel := MPFormModel():New("RU01D03", , {|oMdl| RU01D03B(oMdl)}, , )

oModel:AddFields("FM2MASTER", Nil, oStrSZ1)
oModel:AddGrid("FM2DETAIL", "FM2MASTER", oStrSZ2)
oModel:SetRelation("FM2DETAIL", {{'FM2_FILIAL', 'xFilial("FM2")'}, {'FM2_GROUP', 'FM2_GROUP'}}, FM2->(IndexKey(1)))
oModel:SetPrimaryKey({"FM2_FILIAL", "FM2_GROUP", "FM2_OKOF"})
oModel:GetModel("FM2DETAIL"):SetUniqueLine({"FM2_OKOF"})
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
Local oStrSZ1 as Object
Local oStrSZ2 as Object

oModel := FwLoadModel("RU01D03")
oStrSZ1 := FWFormStruct(2, "FM2", {|x| AllTrim(x) $ "FM2_GROUP|FM2_GRPNAM"})
oStrSZ2 := FWFormStruct(2, "FM2", {|x| AllTrim(x) $ "FM2_OKOF|FM2_OKOFNM"})

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("FM2_M", oStrSZ1, "FM2MASTER")
oView:AddGrid("FM2_D", oStrSZ2, "FM2DETAIL")

oView:CreateHorizontalBox("HEADERBOX", 25)
oView:CreateHorizontalBox("ITEMBOX", 75)

oView:SetOwnerView("FM2_M", "HEADERBOX")
oView:SetOwnerView("FM2_D", "ITEMBOX")
Return(oView)

/*/{Protheus.doc} RU01D03A
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

Function RU01D03A()
Local cRet as Character
Local oModel as Object
Local oDetail as Object

oModel := FwModelActive()
oDetail := oModel:GetModel("FM2DETAIL")

cRet := ""

If !((INCLUI) .Or. (ALTERA))
	cRet := POSICIONE("FM0", 1, XFILIAL("FM0") + FM2->FM2_OKOF, "FM0_NAME")
Elseif (ALTERA)
	If (Empty(oDetail:Length()))
		cRet := POSICIONE("FM0", 1, XFILIAL("FM0") + FM2->FM2_OKOF, "FM0_NAME")
	Endif
Endif

Return(cRet)

/*/{Protheus.doc} RU01D03B
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

Function RU01D03B(oModel as Object)
Local nOperation as Numeric
Local lRet as Logical
Local nI as Numeric
Local oModelDet as Object
Local aArea as Object
Local aAreaSZC as Object
Local cErro as Character
Local cGrupo as Character
Local cOKOF as Character

nOperation := oModel:GetOperation()
lRet := .T.
nI := 0
aArea := GetArea()
aAreaSZC := FM2->(GetArea())
cErro := ""

If (nOperation == MODEL_OPERATION_INSERT)
	oModelDet := oModel:GetModel("FM2DETAIL")
	
	For nI := 1 to oModelDet:Length()
		DbSelectArea("FM2")
		FM2->(DbSetOrder(1))
		
		If (FM2->(DbSeek(xFilial("FM2") + oModel:GetModel("FM2MASTER"):GetValue("FM2_GROUP") + oModel:GetModel("FM2DETAIL"):GetValue("FM2_OKOF", nI))))
			cGrupo := AllTrim(oModel:GetModel("FM2MASTER"):GetValue("FM2_GROUP"))
			cOKOF := AllTrim(oModel:GetModel("FM2DETAIL"):GetValue("FM2_OKOF", nI))
			
			cErro += I18N(STR0002, {cGrupo, cOKOF}) + CRLF
		Endif
	Next nI
	
	If !(Empty(cErro))
		Aviso("Error", cErro, {"Ok"}, 3)
		lRet := .F.
	Endif 
Endif

RestArea(aAreaSZC)
RestArea(aArea)
Return(lRet)

//merge branch 12.1.19
// Russia_R5
