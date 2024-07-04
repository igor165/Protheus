#INCLUDE "Protheus.ch"
#INCLUDE "RU07T09.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} RU07T09
Action of Name Change 

@author raquel.andrade
@since 05/07/2018
/*/
Function RU07T09()
Local oBrowse as Object

oBrowse := BrowseDef()

oBrowse:Activate()

Return Nil

//--------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition.

@author raquel.andrade
@since 05/07/2018
/*/
Static Function BrowseDef()
Local oBrowse 	as Object

oBrowse	:= FWmBrowse():New()
oBrowse:SetAlias( "SRA" )
oBrowse:SetDescription( STR0006 + " " + STR0001  ) //"Action of Name Change"   
oBrowse:DisableDetails() 

Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.

@author raquel.andrade
@since 22/05/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()
Local aRotina as Array

aRotina := {}

ADD OPTION aRotina Title STR0004 	Action 'PesqBrw'            OPERATION 1  ACCESS 0 DISABLE MENU //"Seach" 
ADD OPTION aRotina Title STR0005 	Action 'RU07T0902_Hst'     OPERATION 2  ACCESS 0 DISABLE MENU  //"History"
ADD OPTION aRotina Title STR0006  	Action 'RU07T0901_Act'     OPERATION 4  ACCESS 0 DISABLE MENU  //"Action"


Return aRotina 

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T0901_Act
Execute Action of Name Change.

@author raquel.andrade
@since 05/07/2018
/*/
Function RU07T0901_Act()
Local aAreaSR9      as Array
Local aRecFields    as Array
Local cKey         as Character
Local lFoundDate    as Logical

aAreaSR9    := SR9->(GetArea())
lFoundDate  := .F.

aRecFields := {	"RA_PRINOME",;
			    "RA_SECNOME",;
				"RA_PRISOBR",;
				"RA_NOME",;
				"RA_NSOCIAL"}

cKey := RU07T0914_GetSraKey(RD0->RD0_CODIGO)

If !Empty(cKey)
    SR9->(DbSetOrder(2))
    If SR9->(DbSeek(cKey))
        While !SR9->(Eof()) .And. cKey == SR9->(R9_FILIAL+R9_MAT) .And. !lFoundDate
            If dDataBase <= SR9->R9_DATA
                If (nPos:= aScan(aRecFields,{|x| x == AllTrim(SR9->R9_CAMPO)})) > 0
                    lFoundDate := .T.
                EndIf
            Endif
            SR9->(DbSkip())
        End 
    Endif

    If lFoundDate
        Help('',1,'RU07T09CHANGES',,STR0007,4) // "There are already changes for the date!"
    Else
        FWExecView(STR0001,"RU07T09",MODEL_OPERATION_UPDATE,,{|| .T.})//"Action of Name Change" 
    EndIf
Else    
    Help('',1,'RU07T09EMP',,STR0008,4) //"No relation with Per.Reg. Number! 
EndIf

RestArea( aAreaSR9 )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T0902_Hst
View History.

@author raquel.andrade
@since 05/07/2018
/*/
Function RU07T0902_Hst()

FWExecView(STR0001 + "/" + STR0005,"RU07T09",MODEL_OPERATION_VIEW,,{|| .T.})//"History"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.

@author raquel.andrade
@since 05/07/2018
/*/
Static Function ModelDef()
    Local oStrEmpRD0 	as Object
    Local oStrDocTMP 	as Object
    Local oModel		as Object
    Local oStrOPER      as Object
    Local oStrHIST      as Object
    Local oEventRUS     as Object
    Local cRaCodunic 	As Char
    Local cRd0Codigo 	As Char

    cRaCodunic := SRA->RA_CODUNIC

    cRd0Codigo := Posicione("RD0", 1, xFilial("RD0") + cRaCodunic, "RD0->RD0_CODIGO")

    If cRd0Codigo != cRaCodunic
        Help(Nil, Nil, "ERROR", Nil, STR0010, 1, 0)
    EndIf

    oEventRUS := RU07T09EVRUS():New()

    oModel:= MPFormModel():New("RU07T09", /*bPreValid*/,/* bTudoOK*/, /* */, /*bCancel*/)
    oModel:SetDescription( STR0006 ) //"Action of Name Change"
        
    // Header structure - RD0 Persons
    oStrEmpRD0 := FWFormStruct(1, "RD0", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RD0_FILIAL|RD0_CODIGO|RD0_NOME|RD0_DTADMI|RD0_CIC|RD0_DTNASC|"})
    oModel:AddFields("RU07T09_MRD0", NIL, oStrEmpRD0 )
    oModel:GetModel("RU07T09_MRD0"):SetDescription( STR0009 ) //"Employees" 
    oModel:GetModel("RU07T09_MRD0"):SetOnlyQuery(.T.)
    oModel:GetModel("RU07T09_MRD0"):SetOnlyView(.T.)

    // Items structure - Action of Name Change (temporary file)
    // Action
    oStrOPER := RU07T0903_DefMStr()
    oModel:AddFields('RU07T09_MOPER','RU07T09_MRD0',oStrOPER,/*bPreValid*/,/*bPosValid*/,{|oModel| RU07T0905_LoadOper(oModel)})
    oModel:GetModel("RU07T09_MOPER"):SetDescription( STR0006 ) //"Action"  

    // History
    oStrHIST := RU07T0903_DefMStr()
    oModel:AddGrid('RU07T09_MHIST','RU07T09_MRD0',oStrHIST,/*bPreValid*/,/*bPosValid*/,,,{|oModel| RU07T0906_LoadHist(oModel)})
    oModel:GetModel("RU07T09_MHIST"):SetDescription( STR0005 ) // "History" 
    oModel:GetModel("RU07T09_MHIST"):SetNoInsertLine(.T.)
    oModel:GetModel("RU07T09_MHIST"):SetNoDeleteLine(.T.)

    oModel:SetPrimaryKey({"RD0_FILIAL","RD0_CODIGO"})
    oModel:SetActivate({|oModel| RU07T0912_InitFName(oModel) })
    oModel:InstallEvent("RU07T09EVRUS", /*cOwner*/, oEventRUS)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.

@author raquel.andrade
@since 05/07/2018
/*/
Static Function ViewDef()
    Local oView 	as Object
    Local oModel 	as Object
    Local oStrOPER 	as Object
    Local oStrHIST 	as Object

    oModel := FWLoadModel("RU07T09")

    oView := FWFormView():New()
    oView:SetModel(oModel)

    // Header structure - RD0 Persons
    oStrEmpRD0 := FWFormStruct(2, "RD0", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RD0_CODIGO|RD0_NOME|RD0_DTADMI|RD0_CIC|RD0_DTNASC|"})
    oStrEmpRD0:SetNoFolder()
    oView:AddField("RU07T09_VRD0", oStrEmpRD0, "RU07T09_MRD0" )
    oView:SetViewProperty("RU07T09_VRD0","OnlyView")

    //Items structure - Action of Name Change (temporary file)
    If ALTERA
        oStrOPER := RU07T0904_DefVStr()
        oStrOPER:RemoveField( "SEQUENCE" )
        oView:AddField("RU07T09_VSRA", oStrOPER, "RU07T09_MOPER" )  
    Else
        oStrHIST := RU07T0904_DefVStr()
        oView:AddGrid("RU07T09_VSRA", oStrHIST, "RU07T09_MHIST" )
        oView:AddIncrementField( "RU07T09_VSRA", "SEQUENCE" )
    EndIf

    oView:CreateHorizontalBox("TOP", 30)
    oView:CreateHorizontalBox("BOTTOM", 70)

    oView:SetOwnerView( "RU07T09_VRD0", "TOP" )
    oView:EnableTitleView("RU07T09_VRD0", STR0009) // "Employee"

    If ALTERA
        oView:SetOwnerView("RU07T09_VSRA",'BOTTOM')
        oView:EnableTitleView("RU07T09_VSRA",STR0006) // "Action"
    Else
        oView:SetOwnerView("RU07T09_VSRA",'BOTTOM')
        oView:EnableTitleView("RU07T09_VSRA",STR0010) // "Actions" 
        oView:addUserButton(STR0012 , "RU07T09", { |oView| RU07T0913_Prt(oView) } ) 	//"Print Order" 
    Endif

    oView:SetCloseOnOk( { || .T. } )

Return ( oView )

//------------------------------------------------------------------
/*/{Protheus.doc} RU07T0903_DefMStr
Create ModelDef Structure for ModelDef for Temporary Table.

@author raquel.andrade
@since 05/07/2018
/*/
Static Function RU07T0903_DefMStr()
    Local oStru     as Object
    Local aTrigger  as Array


    aTrigger    := {}
    oStru       := 	FWFormModelStruct():New()

    oStru:AddTable("   ", , "Name Change Operations")
    oStru:AddIndex(1,"01","BRANCH+PERREGIS","Registration","","", .T. )

    //				Titulo 		    		    ,ToolTip		    		    ,Id do Field	,Tipo	,Tamanho		            ,Decimal                ,Valid	,When	,Combo	,Obrigatorio	,Init	,Chave	,Altera	,Virtual
    oStru:AddField(GetSx3Info("RA_FILIAL")[1]	, GetSx3Info("RA_FILIAL")[2]    ,'BRANCH' 	    ,'C'	,TAMSX3("RA_FILIAL")[1]		,0		                ,Nil	,Nil    ,{}		,.F.		    ,Nil	,NIL	,NIL	,.F.)   
    oStru:AddField(GetSx3Info("RA_CODUNIC")[1]  , GetSx3Info("RA_CODUNIC")[2]	,'PERREGIS'		,'C'	,TAMSX3("RA_CODUNIC")[1]	,0		                ,Nil	,Nil	,{}		,.F.	    	,Nil	,NIL	,NIL	,.F.)  
    oStru:AddField(GetSx3Info("RCC_SEQUEN")[1]  , GetSx3Info("RCC_SEQUEN")[2]	,'SEQUENCE' 	,'C'	,4                  		,0		                ,Nil	,Nil	,{}		,.F.	    	,Nil	,NIL	,NIL	,.F.)
    oStru:AddField(GetSx3Info("R7_DATA")[1]	    , GetSx3Info("R7_DATA")[2]	    ,'DATE' 		,'D'	,TAMSX3("R7_DATA")[1]		,0		                ,Nil	,{||.F.}	,{}		,.F.	    	,{|| dDataBase}	,NIL	,NIL	,.F.)
    oStru:AddField(GetSx3Info("RA_PRINOME")[1]  	, GetSx3Info("RA_PRINOME")[2]		,'NAME'		    ,'C'	,TAMSX3("RA_PRINOME")[1]		,0		                ,Nil	,Nil	,{}		,.F.	    	,NIL	,NIL	,NIL	,.F.)  
    oStru:AddField(GetSx3Info("RA_SECNOME")[1]	, GetSx3Info("RA_SECNOME")[2]	,'MDNAME' 	    ,'C'	,TAMSX3("RA_SECNOME")[1]	,0		                ,Nil	,Nil	,{}		,.F.	    	,NIL    ,NIL	,NIL	,.F.)  
    oStru:AddField(GetSx3Info("RA_PRISOBR")[1]  , GetSx3Info("RA_PRISOBR")[2]	,'SURNAME' 	    ,'C'	,TAMSX3("RA_PRISOBR")[1]     ,0		                ,Nil	,Nil	,{}		,.F.	    	,NIL	,NIL	,NIL	,.F.)
    oStru:AddField(GetSx3Info("RA_NOME")[1]  , GetSx3Info("RA_NOME")[2]	,'FULLNME' 	    ,'C'	,TAMSX3("RA_NOME")[1]    ,0		                ,Nil	,Nil	,{}		,.F.	    	,NIL	,NIL	,NIL	,.F.)
    oStru:AddField(GetSx3Info("RA_NSOCIAL")[1]  , GetSx3Info("RA_NSOCIAL")[2]	,'SIGNME' 	    ,'C'	,TAMSX3("RA_NSOCIAL")[1]    ,0		                ,Nil	,Nil	,{}		,.F.	    	,NIL	,NIL	,NIL	,.F.)

    oStru:AddTrigger( 'NAME','SIGNME'   , {|| .T. }, {|oModel| RU07T0907_SignName(oModel) } )
    oStru:AddTrigger( 'MDNAME','SIGNME' , {|| .T. }, {|oModel| RU07T0907_SignName(oModel) } )
    oStru:AddTrigger( 'SURNAME','SIGNME', {|| .T. }, {|oModel| RU07T0907_SignName(oModel) } )

    oStru:AddTrigger( 'NAME','FULLNME'      , {|| .T. }, {|oModel| RU07T0908_FullName(oModel) } )
    oStru:AddTrigger( 'MDNAME','FULLNME'    , {|| .T. }, {|oModel| RU07T0908_FullName(oModel) } )
    oStru:AddTrigger( 'SURNAME','FULLNME'   , {|| .T. }, {|oModel| RU07T0908_FullName(oModel) } )

Return oStru

//------------------------------------------------------------------
/*/{Protheus.doc} RU07T0904_DefVStr
Create View Structure for ModelDef for Temporary Table.

@author raquel.andrade
@since 05/07/2018
/*/
Static Function RU07T0904_DefVStr()
    Local oStru	as Object

    oStru 	:= 	FWFormViewStruct():New()

    oStru:AddField('SEQUENCE' 	,'03'   ,GetSx3Info("RCC_SEQUEN")[1]	,GetSx3Info("RCC_SEQUEN")[2]	,NIL ,'C'	,""		            ,Nil	,Nil        ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)
    oStru:AddField('DATE' 	    ,'04'   ,GetSx3Info("R7_DATA")[1]	    ,GetSx3Info("R7_DATA")[2]	    ,NIL ,'D'	,""		            ,Nil	,Nil        ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)
    oStru:AddField('NAME' 	    ,'05'   ,GetSx3Info("RA_PRINOME")[1]		,GetSx3Info("RA_PRINOME")[2]     	,NIL ,'C'	,"@!"		        ,Nil	,Nil        ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil   ,.T.,Nil,Nil)
    oStru:AddField('MDNAME'	    ,'06'   ,GetSx3Info("RA_SECNOME")[1]	,GetSx3Info("RA_SECNOME")[2]    ,NIL ,'C'	,"@!"		        ,Nil	,Nil        ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)
    oStru:AddField('SURNAME'	,'07'   ,GetSx3Info("RA_PRISOBR")[1]	,GetSx3Info("RA_PRISOBR")[2]	,NIL ,'C'	,"@!"		        ,Nil	,Nil        ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)
    oStru:AddField('FULLNME'	,'08'   ,GetSx3Info("RA_NOME")[1]	,GetSx3Info("RA_NOME")[2]	,NIL ,'C'	,"@!"		        ,Nil	,Nil        ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)
    oStru:AddField('SIGNME'	    ,'09'   ,GetSx3Info("RA_NSOCIAL")[1]	,GetSx3Info("RA_NSOCIAL")[2]   	,NIL ,'C'	,"@!"		        ,Nil	,Nil        ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)

    oStru:SetProperty('FULLNME'     ,MVC_VIEW_CANCHANGE, .F.)
    oStru:SetProperty('SIGNME'     ,MVC_VIEW_CANCHANGE, .F.)

Return oStru

//------------------------------------------------------------------
/*/{Protheus.doc} RU07T0905_LoadOper
Return aLoad with data for Action.

@author raquel.andrade
@since 05/07/2018
/*/
Static Function RU07T0905_LoadOper(oModel as Object)
    Local aLoad         as Array
    Local aLoadAux      as Array
    Local aLines        as Array
    Local aRelFields    as Array
    Local nY            as Numeric

    aLoad       := {}
    aLoadAux    := {}
    aLines      := {}
    cLastReason := ""
    cLastDpto   := ""
    cLastPosto  := ""


    aRelFields:={   {"NAME","NAME",Space(TAMSX3("RA_PRINOME")[1])},;
                    {"MDNAME","MDNAME",Space(TAMSX3("RA_SECNOME")[1])},;
                    {"SURNAME","SURNAME",Space(TAMSX3("RA_PRISOBR")[1])},;
                    {"FULLNME","FULLNME",Space(TAMSX3("RA_NOME")[1])},;
                    {"SIGNME","SIGNME",Space(TAMSX3("RA_NSOCIAL")[1])}}

    aAdd(aLines,{dDataBase,aRelFields})
    aAdd(aLoadAux,RD0->RD0_FILIAL)
    aAdd(aLoadAux,RD0->RD0_CODIGO)
    aAdd(aLoadAux,StrZero(1,4))
    aAdd(aLoadAux,aLines[1][1])
    For nY := 1 To Len(aLines[1][2])
        aAdd(aLoadAux,aLines[1][2][nY][3])   
    Next nY

    aAdd(aLoad,aLoadAux)
    aAdd(aLoad,0)

Return aLoad

//------------------------------------------------------------------
/*/{Protheus.doc} RU07T0906_LoadHist
Return aLoad with data for History.

@author raquel.andrade
@since 05/07/2018
/*/
Static Function RU07T0906_LoadHist(oModel as Object)
Local aLoad         as Array
Local aLoadAux      as Array
Local aLines        as Array
Local aRelFields    as Array
Local cKey         as Character
Local nX            as Numeric
Local nY            as Numeric
Local lFound1       as Logical

aLoad       := {}
aLoadAux    := {}
aLines      := {}
lFound1     := .F.

oModelRD0	:= oModel:GetModel("RU07T09_MRD0")
 
aRelFields:={   {"NAME","RA_PRINOME",Space(TAMSX3("RA_PRINOME")[1])},;
                {"MDNAME","RA_SECNOME",Space(TAMSX3("RA_SECNOME")[1])},;
                {"SURNAME","RA_PRISOBR",Space(TAMSX3("RA_PRISOBR")[1])},;
                {"FULLNME","RA_NOME",Space(TAMSX3("RA_NOME")[1])},;
				{"SIGNME","RA_NSOCIAL",Space(TAMSX3("RA_NSOCIAL")[1])}}           
                
cKey := RU07T0914_GetSraKey(RD0->RD0_CODIGO)

If !Empty(cKey)
    SR9->(DbSetOrder(2)) // R9_FILIAL+R9_MAT+DTOS(R9_DATA)+R9_CAMPO
    If SR9->(DbSeek(cKey))
        While !SR9->(Eof()) .And. DToS(SR9->R9_DATA) < DToS(RD0->RD0_DTNASC)
            SR9->(DbSkip())
        EndDo
        dCurrDate := SR9->R9_DATA
        aTMPData:= aClone(aRelFields)
        While !SR9->(Eof()) .And. cKey == SR9->(R9_FILIAL+R9_MAT)
            If dCurrDate == SR9->R9_DATA
                If (nPos:= aScan(aTMPData,{|x| x[2] == AllTrim(SR9->R9_CAMPO)}))
                    lFound1 := .T.
                    aTMPData[nPos][3] := AllTrim(SR9->R9_DESC)
                Endif
            Else
                If lFound1
                    aAdd(aLines,{dCurrDate,aTMPData})
                Endif
                
                aTMPData    := {}
                dCurrDate   := SR9->R9_DATA
                aTMPData    := aClone(aRelFields)
                lFound1 := .F.

                If (nPos:= aScan(aTMPData,{|x| x[2] == AllTrim(SR9->R9_CAMPO)}))
                    lFound1 := .T.
                    aTMPData[nPos][3] := AllTrim(SR9->R9_DESC)
                Endif
            Endif
            SR9->(DbSkip())
        End
        If lFound1
            aAdd(aLines,{dCurrDate,aTMPData})
        Endif
    Endif

    If oModel:GetOperation() == MODEL_OPERATION_UPDATE
        aAdd(aLines,{dDataBase,aRelFields})
    Endif

    For nX:=1 To Len(aLines)
        aAdd(aLoadAux,RD0->RD0_FILIAL)
        aAdd(aLoadAux,RD0->RD0_CODIGO)
        aAdd(aLoadAux,StrZero(nX,4))
        aAdd(aLoadAux,aLines[nX][1])
        For nY := 1 To Len(aLines[nX][2])
            aAdd(aLoadAux,aLines[nX][2][nY][3])  
        Next nY
        
        aAdd(aLoad,{0,aLoadAux})
        aLoadAux := {}
    Next nX
EndIf

Return aLoad

//------------------------------------------------------------------
/*/{Protheus.doc} RU07T0907_SignName
Return Signature content in accordance with employee's full name.

@author raquel.andrade
@since 05/07/2018
/*/
Static Function RU07T0907_SignName(oModel as Object)
Local cKey          as Char
Local cEmpName      as Character
Local cEmpMdNme     as Character
Local cEmpSurNme	as Character
Local cSignNme      as Character

cKey   := RU07T0914_GetSraKey(RD0->RD0_CODIGO)
aNames  := RU07T0910_GetNames(cKey) // last relation in RDZ file, the one used on RD0
cEmpName	:= ""
cEmpMdNme := ""
cEmpSurNme:= ""

// Name
If Empty(oModel:GetValue("NAME"))
    cEmpName    := AllTrim(aNames[1])
Else
    cEmpName    := AllTrim(oModel:GetValue("NAME"))
EndIf

// Middle Name
If Empty(oModel:GetValue("MDNAME"))
    cEmpMdNme    := AllTrim(aNames[2])
Else
    cEmpMdNme    := AllTrim(oModel:GetValue("MDNAME"))
EndIf

// SurName
If Empty(oModel:GetValue("SURNAME"))
    cEmpSurNme    := AllTrim(aNames[3])
Else
    cEmpSurNme    := AllTrim(oModel:GetValue("SURNAME"))
EndIf

If Empty(cEmpMdNme)
    cSignNme    := cEmpSurNme + " " + Substr(cEmpName,1,1)
Else
    cSignNme    := cEmpSurNme + " " + Substr(cEmpName,1,1)+". " + Substr(cEmpMdNme,1,1)+"."
EndIf

Return cSignNme

//------------------------------------------------------------------
/*/{Protheus.doc} RU07T0908_FullName
Return Full Name content in accordance with employee's name and middle name.

@author raquel.andrade
@since 05/07/2018
/*/
Static Function RU07T0908_FullName(oModel as Object)
Local cFullNme  as Character

If Empty(oModel:GetValue("MDNAME"))
    cFullNme   := AllTrim(oModel:GetValue("SURNAME")) + ' ' + AllTrim(oModel:GetValue("NAME"))
Else
    cFullNme    := AllTrim(oModel:GetValue("SURNAME")) + " " + AllTrim(oModel:GetValue("NAME")) + " " + AllTrim(oModel:GetValue("MDNAME"))
EndIf

Return cFullNme


//-------------------------------------------------------------------
/*
{Protheus.doc}  RU07T0910_GetNames()
Function to get Name/Middle Name/Surname of last relation
with entity SRA.

@author raquel.andrade
@since 05/07/2018
*/
Function RU07T0910_GetNames(cKey)
    Local aArea As Array
    Local aAreaSRA As Array
    Local aNames as Array

    aNames  := {}

    aArea := GetArea()
    aAreaSRA := SRA->(GetArea())

    dbSelectArea("SRA")
    SRA->(DbSetOrder(1)) // RA_FILIAL + RA_MAT
    If SRA->(DbSeek(cKey))
        aAdd(aNames,SRA->RA_PRINOME) // Name
        aAdd(aNames,SRA->RA_SECNOME) // Middle Name
        aAdd(aNames,SRA->RA_PRISOBR) // Surname
        aAdd(aNames,SRA->RA_NOME) // Full Name
        aAdd(aNames,SRA->RA_NSOCIAL) // Signature Name
    Else   
        aAdd(aNames,"")
        aAdd(aNames,"")
        aAdd(aNames,"")
        aAdd(aNames,"")
        aAdd(aNames,"")
    EndIf

    RestArea(aAreaSRA)
    RestArea(aArea)

Return ( aNames )

//------------------------------------------------------------------
/*/{Protheus.doc} RU07T0912_InitFName()
Standard Initializer for all fields.

@author Marina Dubovaya
@type Class
@since 07/11/2018
/*/
Function RU07T0912_InitFName(oModel as Object)
    Local aKeys as Array
    Local cDescription  as Character
    Local  oModelTMP    as Object
    Local cKey As Char

    cKey := RU07T0914_GetSraKey(RD0->RD0_CODIGO)

    If !Empty(cKey)
        aNames  := RU07T0910_GetNames(cKey)
        If Len(aNames) > 0
            oModel:LoadValue("RU07T09_MOPER","NAME",AllTrim(aNames[1]))
            oModel:LoadValue("RU07T09_MOPER","MDNAME",AllTrim(aNames[2]))
            oModel:LoadValue("RU07T09_MOPER","SURNAME",AllTrim(aNames[3]))
            oModel:LoadValue("RU07T09_MOPER","FULLNME",AllTrim(aNames[4]))
            oModel:LoadValue("RU07T09_MOPER","SIGNME",AllTrim(aNames[5]))
        EndIf
    EndIf

Return cDescription

//-------------------------------------------------------------------
/*
{Protheus.doc}  RU07T0913_Prt
Function for print the order

@author raquel.andrade
@since 05/07/2018
*/
Static Function RU07T0913_Prt(oView as Object)
    Local cFileOpen as Character 
    Local cFileSave as Character 
    Local cFileName as Character
    Local cTitle    as Character
    Local cSeq 		as Character 
    Local cCode		as Character 
    Local oWord 	as Object
    Local oModel	as Object
    Local oMdlHIST	as Object

    oModel	:= oView:GetModel()
    oMdlHIST	:= oModel:GetModel("RU07T09_MHIST")
    cCode 	:= oModel:GetModel("RU07T09_MRD0"):GetValue('CODE')
    cSeq 	:= oMdlHIST:GetValue('SEQUENCE')

        cTitle      := OemToAnsi(STR0012)      // "Print Order" 
        cFileName   := OemToAnsi(STR0013)     // "CNOrder"

    If Pergunte("SAVEORD01",.T.)
        cFileOpen := alltrim(MV_PAR01)
        cFileSave := alltrim(MV_PAR02) + cFileName +"_"+ cCode + "_" + cSeq + ".Docx" // CNOrder_Per.Reg.Number_Sequence
        If cFileOpen!="" .AND. !RAT(".DOC", UPPER(cFileOpen)) 
            MsgInfo(STR0014,cTitle) //"File selected has incorrect type."
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


//-------------------------------------------------------------------
/*
{Protheus.doc}  RU07T0914_GetSraKey
Function for retrieving first index key (RA_FILIAL + RA_MAT) 

@author Dmitry Tereschenko
@since 05/07/2018
*/
Function RU07T0914_GetSraKey(cCodunic)
    Local cKey As Char
    Local cKey23 As Char
    Local cRegMat As Char
    Local aArea As Array
    Local aAreaSRA As Array

    aArea := GetArea()
    aAreaSRA := SRA->(GetArea())

    cKey23 := cCodunic + xFilial("SRA")

    dbSelectArea("SRA")
    SRA->(DbSetOrder(23)) // RA_CODUNIC+RA_FILIAL

    If SRA->(DbSeek(cKey23))
        cKey := xFilial("SRA") + SRA->RA_MAT
    EndIf

    RestArea(aAreaSRA)
    RestArea(aArea)

Return cKey

