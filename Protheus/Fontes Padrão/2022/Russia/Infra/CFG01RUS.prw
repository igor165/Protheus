#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'CFG01RUS.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Register Time Dependency Fields
@author Andrews.Egas
@since  02/03/2017
@version 12
/*/
//-------------------------------------------------------------------
Function CFG01RUS()

Local oBrowse as object
Private aRotina := MenuDef()

PreLoad()
oBrowse := FWmBrowse():New()
oBrowse:SetAlias('F40')
oBrowse:SetDescription( STR0001 )
oBrowse:SetMenuDef( 'CFG01RUS' )
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
ManuDef Time Dependency Fields
@author Andrews.Egas
@since  02/03/2017
@version 12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	:= { 	{	STR0003,"PesqBrw"			, 0 , 1, 0, NIL},;	//"search"
						{ STR0002,	"VIEWDEF.CFG01RUS"	, 0 , 2, 0, NIL},;  	//"view"
						{ STR0004   ,'VIEWDEF.CFG01RUS'	, 0 , 3, 0, NIL},;	//"add"
						{ STR0005   ,"VIEWDEF.CFG01RUS"	, 0 , 4, 0, NIL},;	//"update"
						{ STR0006   ,"VIEWDEF.CFG01RUS"	, 0 , 5, 0, NIL}}	//"delete"	


Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}ModelDef
ModelDef Time Dependency Fields
@author Andrews.Egas
@since  02/03/2017
@version 12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruF40 := FWFormStruct( 1, 'F40', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

oStruF40:RemoveField("F40_DESC")
oModel := MPFormModel():New( 'CFG01RUS', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
oModel:AddFields( 'F40MASTER', /*cOwner*/, oStruF40 )

oModel:SetPrimaryKey( { "F40_FILIAL", "F40_ALIAS", "F40_FIELD" } )

oModel:SetDescription( 'TP Main Object' )
oModel:GetModel( 'F40MASTER' ):SetDescription( 'Time Dependency' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc}ViewDef
ViewDef Time Dependency Fields
@author Andrews.Egas
@since  02/03/2017
@version 12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oStruF40 := FWFormStruct( 2, 'F40' )
Local oModel   := FWLoadModel( 'CFG01RUS' )
Local oView


oStruF40:RemoveField("F40_DESC")
oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_F40', oStruF40, 'F40MASTER' )
oView:CreateHorizontalBox( 'TELA', 50 )
oView:SetOwnerView( 'VIEW_F40', 'TELA' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc}CFG01IndexKey
CFG01IndexKey Function to load main index
This function needs to be here, we can't change to trigger, It's safer here
@author Andrews.Egas
@since  02/03/2017
@version 12
/*/
//-------------------------------------------------------------------
Function CFG01IndexKey()

Local cKey as charater
Local cTab as charater
Local lRet as logical
lRet := .T.
cTab := M->F40_ALIAS


DbSelectArea("SX3")
SX3->(dbSetOrder(1))
If !Empty(cTab)
	If SX3->(dbSeek(cTab))
		DbSelectArea(cTab)
		If FieldPos(M->F40_FIELD) > 0 
			cKey := (cTab)->(IndexKey(1))
			M->F40_KEY := cKey
		Else
			lRet := .F.
			MsgAlert("Field does not exist")
		EndIf
	Else
		lRet := .F.
	EndIf
EndIf 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}CFG01IndexKey
Function to pre Load F40
@author Alexander Salov
@since  02/03/2017
@version 12
/*/
//-------------------------------------------------------------------
Static Function PreLoad()
Local aAreaF40 := F40->(GetArea()) //attach table and set iterator position 

F40->(DbSetOrder(1))
If !F40->(dbSeek(xFilial("F40")))

	Reclock("F40",.T.)//lock to modify, take a line from F30 and fetch it once....
	F40->F40_FILIAL = xFilial("F40")   
	F40->F40_ALIAS := AllTrim("SA1")
	F40->F40_FIELD := AllTrim("A1_NOME")
	F40->F40_GRID := AllTrim("2")
	F40->F40_KEY := AllTrim("A1_FILIAL+A1_COD+A1_LOJA")
	F40->F40_ACTIVE := AllTrim("1")
	MsUnlock() // unlock and iterate
	
	Reclock("F40",.T.)  //fetch second line...
	F40->F40_FILIAL = xFilial("F40")   
	F40->F40_ALIAS := AllTrim("SA1")
	F40->F40_FIELD := AllTrim("A1_INSCGAN")
	F40->F40_GRID := AllTrim("2")
	F40->F40_KEY := AllTrim("A1_FILIAL+A1_COD+A1_LOJA")
	F40->F40_ACTIVE := AllTrim("1")
	//add A1_INSCGAN
	MsUnlock() 
	
	Reclock("F40",.T.)
	F40->F40_FILIAL = xFilial("F40")   
	F40->F40_ALIAS := AllTrim("SA1")
	F40->F40_FIELD := AllTrim("A1_NREDUZ")
	F40->F40_GRID := AllTrim("2")
	F40->F40_KEY := AllTrim("A1_FILIAL+A1_COD+A1_LOJA")
	F40->F40_ACTIVE := AllTrim("1")
	//add A1_NREDUZ
	MsUnlock()
	
	Reclock("F40",.T.)
	F40->F40_FILIAL = xFilial("F40")   
	F40->F40_ALIAS := AllTrim("SA2")
	F40->F40_FIELD := AllTrim("A2_NREDUZ")
	F40->F40_GRID := AllTrim("2")
	F40->F40_KEY := AllTrim("A2_FILIAL+A2_COD+A2_LOJA")
	F40->F40_ACTIVE := AllTrim("1")
	MsUnlock()
	
	Reclock("F40",.T.)
	F40->F40_FILIAL = xFilial("F40")   
	F40->F40_ALIAS := AllTrim("SA2")
	F40->F40_FIELD := AllTrim("A2_KPP")
	F40->F40_GRID := AllTrim("2")
	F40->F40_KEY := AllTrim("A2_FILIAL+A2_COD+A2_LOJA")
	F40->F40_ACTIVE := AllTrim("1")
	MsUnlock()  
	
	Reclock("F40",.T.)
	F40->F40_FILIAL = xFilial("F40")   
	F40->F40_ALIAS := AllTrim("SA2")
	F40->F40_FIELD := AllTrim("A2_NOME")
	F40->F40_GRID := AllTrim("2")
	F40->F40_KEY := AllTrim("A2_FILIAL+A2_COD+A2_LOJA")
	F40->F40_ACTIVE := AllTrim("1")
	MsUnlock()   

EndIf
      
RestArea( aAreaF40 ) //detach table
      
Return .t.

//merge branch 12.1.19
// Russia_R5
