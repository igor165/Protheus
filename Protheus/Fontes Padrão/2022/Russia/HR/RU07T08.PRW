#INCLUDE "Protheus.ch"
#INCLUDE "RU07T08.CH"
#INCLUDE "FWMVCDEF.CH"



/*/{Protheus.doc} RU07T08
Action of Business Trip Register File 

@author raquel.andrade
@since 05/07/2018
/*/
Function RU07T08()
Local   oBrowse     as Object

oBrowse := BrowseDef()

oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition.

@author raquel.andrade
@since 05/07/2018
/*/
Static Function BrowseDef()
Local aFields 	as Array
Local aIndex 	as Array
Local aSeek 	as Array
Local oBrwTMP 	as Object

oBrwTMP	:= FWmBrowse():New()
oBrwTMP:SetAlias( "SRA" )
oBrwTMP:SetDescription( STR0001  ) //"Action of Business Trip"  
oBrwTMP:DisableDetails() 
oBrwTMP:AddLegend( "RA_MSBLQL == '2'", "GREEN", STR0002 ) 	 // "Active"  
oBrwTMP:AddLegend( "RA_MSBLQL == '1'", "RED" ,  STR0003 ) 	// "Inactive"


Return oBrwTMP 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author raquel.andrade
@since 05/07/2018
/*/
Static Function MenuDef()
Local aRotina as Array

aRotina := {}

ADD OPTION aRotina Title STR0004 	Action 'PesqBrw'            OPERATION 1  ACCESS 0 DISABLE MENU  //"Seach"   
ADD OPTION aRotina Title STR0005 	Action 'VIEWDEF.RU07T08'    OPERATION 4  ACCESS 0 DISABLE MENU  //"Update"
ADD OPTION aRotina Title STR0006  	Action 'VIEWDEF.RU07T08'    OPERATION 2  ACCESS 0 DISABLE MENU  //"View"


Return aRotina 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author raquel.andrade
@since 05/07/2018
/*/
Static Function ModelDef()
Local oModel        as Object
Local oStrSRA       as Object
Local oStrF4D       as Object

oModel:= MPFormModel():New("RU07T08", /*bPreValid*/,/*bUpdBrw*/ , /* */, /*bCancel*/)
oModel:SetDescription( STR0001 ) //"Action of Business Trip" 
    
// Header structure - SRA Employees
oStrSRA := FWFormStruct(1,"SRA",{|CField| AllTrim(CField)+"|" $ "RA_FILIAL|RA_CODUNIC|RA_MAT|RA_NOME|RA_ADMISSA|RA_CIC|"})
oModel:AddFields("RU07T08_MSRA", NIL, oStrSRA )
oModel:GetModel("RU07T08_MSRA"):SetDescription( STR0007 ) //"Employees" 
oModel:GetModel("RU07T08_MSRA"):SetOnlyQuery(.T.)
oModel:GetModel("RU07T08_MSRA"):SetOnlyView(.T.)

// Items structure - F4D Action of Business Trip
oStrF4D :=  FWFormStruct(1,"F4D")
oStrF4D:AddTrigger( "F4D_DTEND","F4D_ABSDC", {|| .T. }, {|oModel| RU07T0802_AbsDays(oModel,1) } )
oStrF4D:AddTrigger( "F4D_DTEND","F4D_ABSDW", {|| .T. }, {|oModel| RU07T0802_AbsDays(oModel,2) } )

oModel:AddGrid('RU07T08_MF4D','RU07T08_MSRA',oStrF4D,{ |oModel,nLine,cAction| RU07T0801_VldDel( oModel, nLine, cAction) },,,,)
oModel:GetModel("RU07T08_MF4D"):SetDescription( STR0001 ) //"Action of Business Trip"  
oModel:GetModel("RU07T08_MF4D"):SetUniqueLine( { "F4D_DTSTAR" , "F4D_ABSCO" } )

oModel:SetRelation("RU07T08_MF4D",{{"F4D_FILIAL",'xFilial("F4D",SRA->RA_FILIAL)'},{"F4D_CODE","RA_CODUNIC"},{"F4D_MAT","RA_MAT"}},F4D->(IndexKey()))

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author raquel.andrade
@since 05/07/2018
/*/
Static Function ViewDef()
Local oView 	    as Object
Local oModel 	    as Object
Local oStrSRA      as Object
Local oStrF4D      as Object

oModel := FWLoadModel("RU07T08")

oView := FWFormView():New()
oView:SetModel(oModel)

// Header structure - SRA Employees
oStrSRA := FWFormStruct(2,"SRA",{|CField| AllTrim(CField)+"|" $ "RA_CODUNIC|RA_MAT|RA_NOME|RA_ADMISSA|RA_CIC|"})
oStrSRA:SetNoFolder()
oView:AddField("RU07T08_VSRA", oStrSRA, "RU07T08_MSRA" )
oView:SetViewProperty("RU07T08_VSRA","OnlyView")

// Items structure - Action of Business Trip
oStrF4D := FWFormStruct(2,"F4D")
oStrF4D:RemoveField( "F4D_MAT" )
oStrF4D:RemoveField( "F4D_CODE" )
oView:AddGrid("RU07T08_VF4D", oStrF4D, "RU07T08_MF4D" )
oView:AddIncrementField( "RU07T08_VF4D", "F4D_SEQ" )

oView:CreateHorizontalBox("TOP", 30)
oView:CreateHorizontalBox("BOTTOM", 70)

oView:SetOwnerView( "RU07T08_VSRA", "TOP" )
oView:EnableTitleView("RU07T08_VSRA",STR0008) // "Employee" 

oView:SetOwnerView("RU07T08_VF4D",'BOTTOM')
oView:EnableTitleView("RU07T08_VF4D",STR0009) // "Action(s)"

oView:addUserButton(STR0010 , "RU07T08", { |oView| RU07T0803_Prt( oView, 1 ) } ) 	//"Print Order"  
oView:addUserButton(STR0011 , "RU07T08", { |oView| RU07T0803_Prt( oView, 2 ) } ) 	//"Print Official Assignment" 
oView:addUserButton(STR0012 , "RU07T08", { |oView| RU07T0803_Prt( oView, 3 ) } ) 	//"Print Travel Certificate" 

oView:SetCloseOnOk( { || .T. } )

Return ( oView )

//-------------------------------------------------------------------
/*{Protheus.doc} RU07T0801_VldDel
Validate Deleting of records.

@author raquel.andrade
@since 05/07/2018
*/
Function RU07T0801_VldDel( oModelGrid as Object,nLine as Numeric, cAction as Character )
Local lRet       as Logical

lRet       := .T.
 
If cAction == 'DELETE' 
    dbSelectArea("F4D")
    F4D->(DbSetOrder(1))
   // If F4D->(DbSeek( xFilial("F4D",SRA->RA_FILIAL) + SRA->RA_CODUNIC + SRA->RA_MAT  + DtoS(oModelGrid:GetValue("F4D_DTSTAR")) )) 
   If F4D->(DbSeek( xFilial("F4D",SRA->RA_FILIAL) + SRA->RA_CODUNIC + SRA->RA_MAT + DtoS(oModelGrid:GetValue("F4D_DTSTAR")) )) 
        lRet := .F.  
        Help('',1,'RU07T08VLDEL',,STR0013,4) //"RU07T08VLDEL" ## "Is not allowed to delete old records."  
    EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T0802_AbsDays
nType = 1 => Generate Absence Calendar Days in field F4D_ABSDC
nType = 2 => Generate Absence Working Days in field F4D_ABSDW

@author raquel.andrade
@since 05/07/2018
/*/
Function RU07T0802_AbsDays( oModelGrid as Object, nType as Numeric )
Local dDtStart      as Date
Local dDtEnd        as Date
Local nAbsDays      as Numeric

dDtStart    := oModelGrid:GetValue("F4D_DTSTAR") // Date of Start of Business Trip
dDtEnd      := oModelGrid:GetValue("F4D_DTEND") // Date of Start of Business Trip
nAbsDays    := 0


If !Empty(dDtStart) .And. !Empty(dDtEnd)
    If nType == 1   // Absence Calendar Days
        nAbsDays := dDtEnd - dDtStart + 1
    Else            // Absence Working Days
        nAbsDays    := GPEA40001(1, dDtStart, dDtEnd)
    EndIf
EndIf

Return nAbsDays

//-------------------------------------------------------------------
/*
{Protheus.doc}  RU07T0803_Prt
Function for print the order/official assignment/travel certificate.

@author raquel.andrade
@since 05/07/2018
*/
Static Function RU07T0803_Prt(oView as Object, nType as numeric)
Local cFileOpen as Character 
Local cFileSave as Character 
Local cFileName as Character
Local cTitle    as Character
Local cSeq 		as Character 
Local cCode		as Character 
Local oWord 	as Object
Local oModel	as Object
Local oMdlF4D	as Object

oModel	:= oView:GetModel()
oMdlF4D	:= oModel:GetModel("RU07T08_MF4D")
cCode 	:= oModel:GetModel("RU07T08_MSRA"):GetValue('RA_CODUNIC')
cSeq 	:= oMdlF4D:GetValue('F4D_SEQ')

If nType == 1 // Order
    cTitle      := OemToAnsi(STR0010)      // "Print Order" 
    cFileName   := OemToAnsi(STR0014)     // "BTOrder"
Elseif nType == 2 // Official Assignment
    cTitle      := OemToAnsi(STR0011)      // "Print Official Assignment"
    cFileName   := OemToAnsi(STR0015)     // "BTOffAssign"
Else // Travel Certificate
    cTitle      := OemToAnsi(STR0012)      // "Print Travel Certificate"
    cFileName   := OemToAnsi(STR0016)      // "BTTravelCt"
EndIF

If Pergunte("SAVEORD01",.T.)
	cFileOpen := alltrim(MV_PAR01)
	cFileSave := alltrim(MV_PAR02) + cFileName +"_"+ cCode + "_" + cSeq + ".Docx" // VACOrder_Per.Reg.Number_Sequence
	If cFileOpen!="" .AND. !RAT(".DOC", UPPER(cFileOpen)) 
		MsgInfo(STR0017,cTitle) //"File selected has incorrect type."
	Else
		oWord := OLE_CreateLink()
		If File(cFileOpen)
			OLE_OpenFile(oWord, cFileOpen)
		Else
			OLE_NewFile(oWord)
		EndIf
		OLE_SaveAsFile( oWord, cFileSave,,,.F. )
	EndIf
EndIf
	
Return (.T.)




/*------------------------------------------------------------------
{Protheus.doc}  RU07T0804_BlockLine()
Set rules to block the fields in a line
Use  in SX3 for fields F4D_ACBCO,F4D_DTSTAR,F4D_DTEND,F4D_CITY,F4D_COMP, F4D_OBJEC,F4D_CC
@author Marina Dubovaya
@since 07/10/2018

-------------------------------------------------------------------*/
Function  RU07T0804()
Local oModelGrid as Object
Local oModel as Object

oModel	:= FWModelActive()
oModelGrid:= oModel:GetModel("RU07T08_MF4D")

Return ( oModelGrid:IsInserted(oModelGrid:GetLine()) )

//-------------------------------------------------------------------
/*{Protheus.doc} RU07T0805_VldDate
Validate date begin, date end of business trip.
Use in SX3 for fields F4D_DTSTAR, F4D_DTEND
@author Marina Dubovaya
@since 07/11/2018
*/
Function RU07T0805()
local lRet 			as logic
local dDateStarCur 	as Date
local nX 			as numeric
local nSum 			as numeric
local nLen 			as numeric
Local oModelGrid as Object
Local oModel as Object

lRet := .T.
nSum := 1
oModel	:= FWModelActive()
oModelGrid:= oModel:GetModel("RU07T08_MF4D")
nLen := oModelGrid:GetLine()
dDateStarCur:= oModelGrid:GetValue("F4D_DTSTAR")
dDateEndCur:= oModelGrid:GetValue("F4D_DTEND")

If  !Empty(dDateStarCur) .And. !Empty(dDateEndCur)

	lRet := .F.

	If dDateStarCur <= dDateEndCur
	    If nLen > 1
	        // Check date 
	        For nX:=1 To (nLen-1)
	            If  (oModelGrid:GetValue("F4D_DTSTAR", nx) > dDateStarCur .And. oModelGrid:GetValue("F4D_DTSTAR", nx) > dDateEndCur) .or. ; 
	            (oModelGrid:GetValue("F4D_DTEND", nx) < dDateStarCur .And. oModelGrid:GetValue("F4D_DTEND",nx) < dDateEndCur) 
	                nSum := nSum+1
	            endIf
	        Next nX
			
			If nSum == nLen
	            lRet := .T.
	        else    
	           Help("",1,"RU07T0805_VldDate",,STR0022,1,0,,,,,,{STR0023}) //The specified period is already used. // Specify the correct start and end dates for the business trip. 
	        EndIf
		else     
	    	lRet := .T.          
		EndIf   
	else
		Help("",1,"RU07T0805_VldDate",,STR0024,1,0,,,,,,{STR0023}) // The end date is earlier than the start date of the business trip//Specify the correct start and end dates for the business trip.
	EndIf      
EndIf

Return lRet