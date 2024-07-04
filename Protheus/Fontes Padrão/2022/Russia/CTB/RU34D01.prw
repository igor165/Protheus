#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU34D01.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} RU34D01
FI-AP-17-8 Products Accounting Groups (Russia)

@author Victor Guberniev
@since 26/03/2018
@version MA3 - Russia.
/*/

Function RU34D01()
Local oBrowse as object

oBrowse := BrowseDef()

oBrowse:SetAttach(.T.)
SetKey(VK_F12, {|a,b| AcessaPerg("RU34D01PRD",.T.)})

oBrowse:Activate()

Return Nil

/*/{Protheus.doc} BrowseDef
Browse definition

@author Victor Guberniev
@since 26/03/2018
@version MA3 - Russia
/*/
//-------------------------------------------------------------------

Static Function BrowseDef()
Local oBrowse as object
Local aColumns		:= {}
Local aStru			:= {} 
Local nX			:= 0
Local aFields		AS ARRAY

aStru	:= F46->(DBSTRUCT())
aFields	:= {}

For nX := 1 To Len(aStru)
	If	!aStru[nX][1] $ "F46_KEY;F46_CURRTP;F46_CNTRTP;F46_OWNER"
	    aAdd(aFields, aStru[nX][1])

	EndIf
Next nX

oBrowse := FwMBrowse():New()
oBrowse:SetAlias("F46") 
oBrowse:SetDescription(STR0001)// Products Accounting Groups
oBrowse:AddFilter(STR0001, "F46_OWNER=='PD'", , .T.)
oBrowse:aOnlyFields	:= aFields

Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu definition

@author Victor Guberniev
@since 26/03/2018
@version MA3 - Russia
/*/
//-------------------------------------------------------------------

Static Function MenuDef()
Local aRotina as array

aRotina := {}

ADD OPTION aRotina Title STR0002 	Action 'VIEWDEF.RU34D01'	OPERATION MODEL_OPERATION_VIEW ACCESS 0 //View
ADD OPTION aRotina Title STR0003	Action 'VIEWDEF.RU34D01'	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //Add
ADD OPTION aRotina Title STR0004 	Action 'RU34D01Copy()'      OPERATION 9 ACCESS 0 //Copy  
ADD OPTION aRotina Title STR0005    Action 'VIEWDEF.RU34D01'   	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //Change
ADD OPTION aRotina Title STR0006 	Action 'VIEWDEF.RU34D01'    OPERATION MODEL_OPERATION_DELETE ACCESS 0 //Delete  

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo de dados

@author Victor Guberniev
@since 26/03/2018
@version MA3 - Russia
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oStruF46 	as object                              
Local oModel 	as object
Local cFldView    as Character


cFldView := "F46_CURRTP;F46_CNTRTP"

oStruF46:= FWFormStruct( 1, "F46", {|X| !(AllTrim(x) $ cFldView)})                              
oModel 		:= MPFormModel():New("RU34D01", , , {|oModel| ModelRec(oModel)})

oModel:AddFields("F46MASTER",, oStruF46)
oModel:GetModel("F46MASTER"):SetDescription(STR0001) 

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao do interface

@author Victor Guberniev
@since 26/03/2018
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel	as object
Local oStruF46	as object
Local oView		as object  
Local cFldView    as Character

cFldView := "F46_KEY;F46_CURRTP;F46_CNTRTP;F46_OWNER"

oModel	:= FWLoadModel("RU34D01")
oStruF46	:= FWFormStruct(2,"F46", {|X| !(AllTrim(x) $ cFldView)})
oView		:= FWFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_F46",oStruF46,"F46MASTER")

Return oView


Static Function ModelRec(oModel as Object)
Local lRet as Logical
Local oModel as Object

lRet := .T.
oModel:= FWModelActive() 

nOperation := oModel:GetOperation()
lContinuous := .T.

If (nOperation == MODEL_OPERATION_INSERT)
  oModel:GetModel("F46MASTER"):SetValue("F46_KEY", FwUUIDV4())      
  oModel:GetModel("F46MASTER"):SetValue("F46_OWNER", "PD")       
Endif

FWFormCommit(oModel)

Return(lRet)

Function RU34D01Copy()
Local oModel 	as Object
Local cF46Key	as Character
Local cCurFil	as Character
Local nX 		as Numeric
Local aAreaSX2  as Array
Local aAreaF46  as Array
Local aSelFil	as Array

aSelFil	:= {}
cCurFil	:= cFilAnt

aSelFil := AdmGetFil(.F.,.T.,"F46")

cF46Key	:= F46->(F46_FILIAL+F46_KEY)

If !(empty(aSelFil))
	For nX := 1 to len(aSelFil)
		aAreaF46	:= F46->(GetArea())
    	dbSelectArea("F46")
    	dbSetOrder(1) 
		If F46->(dbSeek(cF46Key))
			oModel := FWLoadModel("RU34D01")
			oModel:SetOperation(MODEL_OPERATION_INSERT)
                  oModel:SetDescription(STR0001) 
			oModel:Activate(.T.) 
			cFilAnt := aSelFil[nX]
			FWExecView( STR0004 , "RU34D01", MODEL_OPERATION_INSERT, , {|| .T. },  , , , , , ,oModel)
			cFilAnt := cCurFil
			oModel:DeActivate()
		EndIf
	Next nX
	RestArea(aAreaF46)
EndIf

Return



// Russia_R5
