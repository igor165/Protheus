#INCLUDE "MATA070RUS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} MATA070RUS
Banks master data (Russia)

@author Flavio Lopes
@since 20/03/2017
@version MA3 - Russia
/*/
Function MATA070RUS()
Local oBrowse as object
Private lAltera	:= .F.
PRIVATE cCadastro :=OemtoAnsi(STR0001 )  //"Atualizacao de Bancos" // Bank's update

oBrowse := BrowseDef()
oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Flavio Lopes
@since 20/03/2017
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse as object

oBrowse := FWLoadBrw("MATA070")

Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu definition

@author Flavio Lopes
@since 20/03/2017
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina :=  FWLoadMenuDef("MATA070")
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de dados
@author 	Flavio Lopes
@since 		20/03/2017
@version 	1.0
@project	MA3
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel as object
Local oMT070RUS	as object

oMT070RUS	:= MT070RUS():New()

oModel 	:= FwLoadModel('MATA070')

oModel:InstallEvent("MT070RUS", , oMT070RUS)


Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author 	Flavio Lopes
@since 		20/03/2017
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	as object
Local oView		as object

oView	:= FWLoadView("MATA070")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} A070LenCon
Validadtion of the Llength of A6_NUMCON 
@author 	Flavio Lopes
@since 		28/03/2017
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------

Function A070LenCon()
Local lRet as logic
Local oModel as object
Local oModelSA6 as object
Local nFldLen	as numeric

lRet 		:= .T.
oModel		:= FwModelActive()
oModelSA6	:= oModel:GetModel('MATA070_SA6')
nFldLen		:= Len(AllTrim(oModelSA6:GetValue("A6_NUMCON")))

If oModelSA6:GetValue("A6_FOREIGN") != '1' .and. !IsBlind() .and. nFldLen != 20
		MsgInfo(STR0002,)//This field shall be filled with exactely 20 chareacters 		
		lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A070ForVld
Validadtion of foreign banks 
@author 	Flavio Lopes
@since 		28/03/2017
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------
Function A070ForVld()
Local lObrigat as logic
Local oModel as object
Local oModelSA6 as object

oModel		:= FwModelActive()
oModelSA6	:= oModel:GetModel('MATA070_SA6')

If oModelSA6:GetValue('A6_FOREIGN') == '1'
	lObrigat	:= .T.
	oModelSA6:LoadValue("A6_MUN"		,"")
	oModelSA6:LoadValue("A6_NOME"		,"")
	oModelSA6:LoadValue("A6_SWIFT"		,"")
	oModelSA6:LoadValue("A6_CORRACC"	,"")
	oModelSA6:LoadValue("A6_AGENCIA"	,"")
	oModelSA6:SetValue("A6_BLOCKED"	,"2")
EndIf



Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} A070VldBIK
Validadtion for BIK
@author 	Flavio Lopes
@since 		28/03/2017
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------
Function A070VldBIK()
Local oModel as object
Local oModelSA6 as object
Local lRet as logic

lRet := .T.
oModel		:= FwModelActive()
oModelSA6	:= oModel:GetModel('MATA070_SA6')

	F45->(DbSetOrder(1))
	If F45->(DbSeek(xFilial("F45")+oModelSA6:GetValue("A6_AGENCIA")))
		If F45->F45_STATUS == "2"
			oModelSA6:LoadValue("A6_FOREIGN" 	,F45->F45_FOREIG)
			oModelSA6:LoadValue("A6_MUN"		,F45->F45_CITY)
			oModelSA6:LoadValue("A6_NOME"		,F45->F45_NAME)
			oModelSA6:LoadValue("A6_SWIFT"		,F45->F45_SWIFT)
			oModelSA6:LoadValue("A6_CORRACC"	,F45->F45_CORRAC)
			oModelSA6:SetValue("A6_BLOCKED"		,"2")
		Else
			Help(" ",1,"MATA070RUS003")//This Russian Bank is set as not working. 
			lRet := .F.
		Endif
	Endif


Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} A070IntPay()
Standard init for Payable accounts. 
@author 	Flavio Lopes
@since 		28/03/2017
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------

Function A070IntPay(nNum)
// nNum == NIL - called from sx3_relacao on E2_PORTADO; == 1 means called from trigger on E2_MOEDA or E2_CONUNI
Local cRet as character
Local nMoeda as Numeric
Local cConUni as character

Default nNum:=0
cRet:= ""
SA6->(DbSetOrder(4))
nMoeda:=IF(nNum==0, SE2->E2_MOEDA,M->E2_MOEDA)
cConUni:=IF(nNum==0, SE2->E2_CONUNI,M->E2_CONUNI)

If SA6->(DbSeek(xFilial("SA6")+"1"))
	if SA6->A6_MOEDA==nMoeda .or. (cConUni=='1' .and. SA6->A6_MOEDA==1)
		cRet := SA6->A6_COD
	EndIf
Endif

Return cRet

//merge branch 12.1.19
// Russia_R5