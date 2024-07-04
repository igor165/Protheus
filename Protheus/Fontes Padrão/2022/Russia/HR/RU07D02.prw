#INCLUDE "Protheus.ch"
#INCLUDE "RU07D02.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
#Include "MSOle.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07D02
Employees Awards Register File 

@author Anastasiya Kulagina
@since 12/01/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07D02()
Local oBrowse as Object
	
oBrowse := BrowseDef()
	
oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition.

@author Anastasiya Kulagina
@since 12/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
Local oBrowse 	as Object

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( "SRA" )

oBrowse:SetDescription(STR0001) // Employees Awards
oBrowse:DisableDetails() 
	
Return ( oBrowse ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author Anastasiya Kulagina
@since 12/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()
Local oModel		as Object
Local oStructRD0 	as Object
Local oStructF4I 	as Object
Local cRaCodunic 	As Char
Local cRd0Codigo 	As Char

cRaCodunic := SRA->RA_CODUNIC

cRd0Codigo := Posicione("RD0", 1, xFilial("RD0") + cRaCodunic, "RD0->RD0_CODIGO")

If cRd0Codigo != cRaCodunic
	Help(Nil, Nil, "ERROR", Nil, STR0010, 1, 0)
EndIf	 
		
oModel:= MPFormModel():New("RU07D02", /*bPreValid*/,/* bTudoOK*/, /* bCommit*/, /*bCancel*/)
oModel:SetDescription( STR0001 ) //"Employees Awards" 
	    
// Header structure - RD0 Persons
oStructRD0 := FWFormStruct(1, "RD0", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RD0_FILIAL|RD0_CODIGO|RD0_NOME|RD0_DTADMI|RD0_CIC|RD0_DTNASC|"})

oModel:AddFields("RU07D02_MRD0", NIL, oStructRD0 )
oModel:GetModel("RU07D02_MRD0"):SetDescription( STR0001 ) //"Employees Awards" 
oModel:GetModel("RU07D02_MRD0"):SetOnlyQuery(.T.)
oModel:GetModel("RU07D02_MRD0"):SetOnlyView(.T.)
	
// Items structure - F4I Employees Awards
oStructF4I := FWFormStruct(1, "F4I")
oModel:AddGrid("RU07D02_MF4I", "RU07D02_MRD0", oStructF4I,, /*bLinOk*/  )
oModel:GetModel("RU07D02_MF4I"):SetUniqueLine( { 'F4I_SEQ', 'F4I_GRPAWD', 'F4I_DGRAWD', 'F4I_DSUBAW', 'F4I_TPAWRD', 'F4I_STAWRD', 'F4I_TXAWRD' } )
oModel:SetPrimaryKey({ 'F4I_FILIAL','F4I_CODE','F4I_SEQ','F4I_GRPAWD'})
oModel:GetModel("RU07D02_MF4I"):SetDescription( STR0001 ) //"Employees Awards" 
oModel:GetModel("RU07D02_MF4I"):SetOptional( .T. )
oModel:SetRelation( "RU07D02_MF4I", { { "F4I_FILIAL", 'RD0_FILIAL' }, { "F4I_CODE", 'RD0_CODIGO' }}, F4I->( IndexKey( 1 ) ) )
oModel:SetVldActivate( { |oModel|  RD02VldIni( oModel,oModel:GetOperation()) } )  

Return ( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author Anastasiya Kulagina
@since 12/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Local oView 		as Object
Local oModel 		as Object
Local oStructRD0 	as Object
Local oStructF4I 	as Object
	
oModel := FWLoadModel("RU07D02")
	
oView := FWFormView():New()

oView:SetModel(oModel)

	
// Header structure - RD0 Persons 
oStructRD0 := FWFormStruct(2, "RD0", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RD0_CODIGO|RD0_NOME|RD0_DTADMI|RD0_CIC|RD0_DTNASC|"})
oStructRD0:SetNoFolder()
oView:AddField("RU07D02_VRD0", oStructRD0, "RU07D02_MRD0" )
oView:SetViewProperty("RU07D02_VRD0","OnlyView")
	
// Items structure - F4I Employees Awards
oStructF4I := FWFormStruct(2, "F4I")
oStructF4I:RemoveField( "F4I_CODE" )
oView:AddGrid("RU07D02_VF4I", oStructF4I, "RU07D02_MF4I" )
oView:AddIncrementField( "RU07D02_VF4I", "F4I_SEQ" )
	
oView:CreateHorizontalBox("RD0_HEAD", 15)
oView:CreateHorizontalBox("F4I_ITEM", 85)
	
oView:SetOwnerView( "RU07D02_VRD0", "RD0_HEAD" )
oView:SetOwnerView( "RU07D02_VF4I", "F4I_ITEM" )
oView:SetCloseOnOk( { || .T. } )

oView:AddUserButton(STR0016, "RU07D02", {|oView|RU07D02Prt(oView)})

Return ( oView )


//-------------------------------------------------------------------
/*/{Protheus.doc} RD02VldIni
Check if there is record for Employees Awards.

@author Anastasiya Kulagina
@since 12/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RD02VldIni(oModel as Object, nOperacao as Numeric)
Local lRet 	as Logical

lRet := .T.
	
If nOperacao == MODEL_OPERATION_DELETE 
	If RD02Null()
		Help(,,'HELP',, STR0008 ,1,0 ) //"There is no record of Employees Awards for this employee."
		lRet := .F.
	Endif
EndIf
	
Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} RD02Null
Check if there is record for Employees Awards.

@author Anastasiya Kulagina
@since 12/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RD02Null()
Local aAreaF4I as Array
Local lRet	as Logical
	
lRet	:= .T.
	
aAreaF4I := F4I->(GetArea())
	
F4I->( DbSetOrder( 1 ) )
If F4I->(DbSeek( xFilial("RD0") + RD0->RD0_CODIGO ))
	lRet := .F.
EndIf
	
RestArea( aAreaF4I )

Return ( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author Anastasiya Kulagina
@since 12/01/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()
Local aRotina as Array

aRotina := {}

ADD OPTION aRotina TITLE STR0005 	ACTION 'VIEWDEF.RU07D02'	OPERATION 2 ACCESS 0 //"View" 
ADD OPTION aRotina TITLE STR0006 	ACTION 'VIEWDEF.RU07D02' 	OPERATION 4 ACCESS 0 //"Update"
ADD OPTION aRotina TITLE STR0007 	ACTION 'VIEWDEF.RU07D02' 	OPERATION 5 ACCESS 0 //"Delete" 
ADD OPTION aRotina TITLE STR0010 	ACTION 'fRD0Legend()' 	    OPERATION 10 ACCESS 0 //"Legend"

Return aRotina
//-------------------------------------------------------------------
/*
{Protheus.doc}  RU07D02Prt()
Function for print the order
@author anastasiya.kulagina
@since 26/03/2018
@version V12.1.21
*/
Function RU07D02Prt(oView as Object)
Local oWord as Object
Local cFileOpen as Character 
Local cFileSave as Character 
Local oModel	:= oView:GetModel()
Local oModelR	:= oModel:GetModel("RU07D02_MRD0")
Local oModelF	:= oModel:GetModel("RU07D02_MF4I")
Local Seq 	:= oModelF:GetValue('F4I_SEQ')
Local CODE 	:= oModelR:GetValue('CODE')

if pergunte("SAVEORD01",.T.)
	cFileOpen := alltrim(MV_PAR01)
	cFileSave := alltrim(MV_PAR02) + STR0018 +"_"+ CODE + "_" + Seq + ".Docx" //name of files "AwardOrder_%CODE%_%SEQ%
	If cFileOpen!="" .AND. !RAT(".DOC", UPPER(cFileOpen)) 
		MsgInfo(STR0017,STR0016)			//error message "The file of the incorrect type is selected."
	Else
		oWord := OLE_CreateLink()
		If File(cFileOpen)
		OLE_OpenFile(oWord, cFileOpen)
		Else
		OLE_NewFile(oWord)
		EndIf
		OLE_SaveAsFile( oWord, cFileSave,,,.F. )
	ENDIF
endif	

RETURN (.T.)
//Checked and merged by AS for Russia_R4 * *
// Russia_R5
