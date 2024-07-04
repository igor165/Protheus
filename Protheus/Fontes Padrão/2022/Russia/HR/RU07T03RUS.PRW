#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#include 'RU07T03RUS.ch'
//------------------------------------------------------------------
/*/{Protheus.doc} RU07T03RUS()
Internal Movement / Change of working conditions

@author Flavio Lopes Rasta

@since 03/04/2018
/*/
//-------------------------------------------------------------------
Function RU07T03RUS()
Local   oBrowse as object
Local 	aParam
Local 	cFilt		as Character

aParam  := {}

If PERGUNTE ("GPEA010RUS", .T.)
	AAdd( aParam, UPPER( alltrim( MV_PAR01 ) ) )
	AAdd( aParam, UPPER( alltrim( MV_PAR02 ) ) )
	AAdd( aParam, UPPER( alltrim( MV_PAR03 ) ) )
	AAdd( aParam, DTOS( MV_PAR04 ) )
	AAdd( aParam, UPPER( alltrim( MV_PAR05 ) ) )
EndIf

cFilt := ActFiltRUS( aParam )

oBrowse := BrowseDef()                                                                                                                                                                                                   
oBrowse:SetFilterDefault(cFilt)       
oBrowse:Activate()

Return NIL

//------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef()
Browse Definiton for the routine

@author Flavio Lopes Rasta

@since 03/04/2018
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("SRA")
oBrowse:SetDescription(STR0001) // "Internal Movement / Change of working conditions"     
oBrowse:AddLegend( "RA_MSBLQL == '2'", "GREEN", STR0002) 	// "Active"
oBrowse:AddLegend( "RA_MSBLQL == '1'", "RED" , STR0003 ) 	// "Unactive"

Return oBrowse

//------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu for the routine

@author Flavio Lopes Rasta

@since 03/04/2018
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina as array

aRotina := {}

ADD OPTION aRotina TITLE STR0017  	ACTION 'RU07T03His()'	OPERATION 2 ACCESS 0 //"History"
ADD OPTION aRotina TITLE STR0018 	ACTION 'RU07T03Act()' 	OPERATION 4 ACCESS 0 //"Action"

Return aRotina

//------------------------------------------------------------------
/*/{Protheus.doc} RU07T03Act()
Menu Action, validations before opening

@author Flavio Lopes Rasta

@since 03/04/2018
/*/
//-------------------------------------------------------------------
Function RU07T03Act()
Local aAreaSR9      as array
Local lFoundDate    as Logical

aAreaSR9 := SR9->(GetArea())
lFoundDate := .F.

SR9->(DbSetOrder(2))
If SR9->(DbSeek(xFilial("SR9")+SRA->RA_MAT))
    While !SR9->(Eof()) .And. xFilial("SR9")+SRA->RA_MAT == SR9->(R9_FILIAL+R9_MAT) .And. !lFoundDate
        If dDataBase <= SR9->R9_DATA
            If AllTrim(SR9->R9_CAMPO) == "REASON"
                lFoundDate := .T.
            EndIf
        Endif
        SR9->(DbSkip())
    End 
Endif
RestArea( aAreaSR9 )

If lFoundDate
    Help('',1,'RU07T03CHANGES',,STR0006,4)//"Unavailable Option"#"There are already changes for the date!"
Else
	FWExecView(STR0001,"RU07T03",MODEL_OPERATION_UPDATE,,{|| .T.})//"Internal Movement / Change of working conditions"
EndIf

Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} RU07T03His()
Menu History, validations before opening

@author Flavio Lopes Rasta

@since 03/04/2018
/*/
//-------------------------------------------------------------------
Function RU07T03His()

FWExecView(STR0001,"RU07T03",MODEL_OPERATION_VIEW,,{|| .T.})//"Internal Movement / Change of working conditions"

Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Data Model definition

@return oModel
@author Flavio Lopes Rasta
@since 03/04/2018
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel    as Object
Local oStruSRA  as Object
Local oStruOPER as Object
Local oStruHIST as Object
Local oEventRUS as Object


oEventRUS := RU07T03EVRUS():New()

oStruSRA := FwFormStruct(1,'SRA',{|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RA_FILIAL|RA_MAT|RA_NOME|RA_ADMISSA|RA_CIC|RA_CODUNIC|"})

oModel := MPFormModel():New('RU07T03',/*bPreValid*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)
oModel:SetDescription(STR0001)//"Internal Movement / Change of working conditions"

oModel:AddFields('SRAMASTER',/*cOwner*/,oStruSRA,/*bPreValid*/,/*bPosValid*/,/*bLoad*/)

oStruOPER := DefStrMOper()
oStruHIST := DefStrMOper()

oModel:AddFields('TMPDETAIL','SRAMASTER',oStruOPER,/*bPreValid*/,/*bPosValid*/,{|oModel| LoadTMP(oModel)})
oModel:AddGrid('HISTDETAIL','SRAMASTER',oStruHIST,/*bPreValid*/,/*bPosValid*/,,,{|oModel| LoadHIST(oModel)})

oModel:GetModel('SRAMASTER'):SetDescription(STR0020) //"Employee"
oModel:GetModel('SRAMASTER'):SetOnlyQuery(.T.)
oModel:GetModel('TMPDETAIL'):SetDescription(STR0018) //"Action"

oModel:GetModel('HISTDETAIL'):SetDescription(STR0019)//"Actions"
oModel:GetModel('HISTDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('HISTDETAIL'):SetNoDeleteLine(.T.)

oModel:SetPrimaryKey({"RA_FILIAL","RA_MAT"})
oModel:InstallEvent("RU07T03EVRUS", /*cOwner*/, oEventRUS)

Return oModel

//------------------------------------------------------------------
/*/{Protheus.doc} BlockLine()
Set rules to block the fields in a line

@return .T.
@author Flavio Lopes Rasta
@since 03/04/2018
/*/
//-------------------------------------------------------------------
Static Function BlockLine(oModel as Object)
If !ALTERA
    If oModel:GetLine() <> oModel:Length()
        Return .F.
    Endif 
Endif
Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Visualization definition

@return oView
@author Flavio Lopes Rasta
@since 03/04/2018
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView     as Object
Local oModel    as Object
Local oStruSRA  as Object
Local oStruOPER as Object
Local oStruHIST as Object

oModel      := FWLoadModel('RU07T03')
oStruSRA    := FwFormStruct(2,'SRA',{|cCampo| "|" + AllTrim(cCampo) + "|" $ "|RA_MAT|RA_NOME|RA_ADMISSA|RA_CIC|RA_CODUNIC|"})
oStruSRA:SetNoFolder()

oStruOPER := DefStrVOper()
oStruHIST := DefStrVOper()

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_SRA',oStruSRA,'SRAMASTER')
oView:SetViewProperty("VIEW_SRA","ONLYVIEW")

If ALTERA
    oView:AddField('VIEW_TMP',oStruOPER,'TMPDETAIL')
    oStruOPER:RemoveField("SEQUENCE")
Else
    oView:AddGrid('VIEW_HIST',oStruHIST,'HISTDETAIL')
    oView:AddIncrementField( "VIEW_HIST", "SEQUENCE" )
Endif

oView:CreateHorizontalBox('UPPER',30)
oView:CreateHorizontalBox('LOWER',70)

oView:SetOwnerView('VIEW_SRA','UPPER')
oView:EnableTitleView('VIEW_SRA',STR0020) //"Employee"

If ALTERA
    oView:SetOwnerView('VIEW_TMP','LOWER')
    oView:EnableTitleView('VIEW_TMP',STR0018) //"Action"
Else
    oView:SetOwnerView('VIEW_HIST','LOWER')
    oView:EnableTitleView('VIEW_HIST',STR0019) //"Actions"
Endif

oView:AddUserButton("Print Order",'CLIPS', {|oView| RU07T03Prt(oView) }) //"Print Order"

oView:SetDescription(STR0001)//"Internal Movement / Change of working conditions"

Return oView

//------------------------------------------------------------------
/*/{Protheus.doc} DefStrMOper()

@return oStru
@author Flavio Lopes Rasta
@since 03/04/2018
/*/
//-------------------------------------------------------------------
Static Function DefStrMOper()
Local oStru     as Object

oStru       := 	FWFormModelStruct():New()

oStru:AddTable("   ", , "Employee Action")
oStru:AddIndex(1,"01","BRANCH+REGISTR","Registration","","", .T. )

//				Titulo 		    		    ,ToolTip		    		    ,Id do Field	,Tipo	,Tamanho		            ,Decimal                ,Valid	,When	,Combo	,Obrigatorio	,Init	,Chave	,Altera	,Virtual
oStru:AddField(GetSx3Info("RA_FILIAL")[1]	, GetSx3Info("RA_FILIAL")[2]    ,'BRANCH' 	    ,'C'	,TAMSX3("RA_FILIAL")[1]		,0		                ,Nil	,Nil    ,{}		,.F.		    ,Nil	,NIL	,NIL	,.F.)   
oStru:AddField(GetSx3Info("RA_MAT")[1]	    , GetSx3Info("RA_MAT")[2]		,'REGISTR' 		,'C'	,TAMSX3("RA_MAT")[1]		,0		                ,Nil	,Nil	,{}		,.F.	    	,Nil	,NIL	,NIL	,.F.)  
oStru:AddField(GetSx3Info("RCC_SEQUEN")[1]  , GetSx3Info("RCC_SEQUEN")[2]	,'SEQUENCE' 	,'C'	,4                  		,0		                ,Nil	,Nil	,{}		,.F.	    	,Nil	,NIL	,NIL	,.F.)
oStru:AddField(GetSx3Info("R7_DATA")[1]	    , GetSx3Info("R7_DATA")[2]	    ,'DATE' 		,'D'	,TAMSX3("R7_DATA")[1]		,0		                ,Nil	,{||.F.}	,{}		,.F.	    	,{|| dDataBase}	,NIL	,NIL	,.F.)
oStru:AddField(GetSx3Info("PF_REASC")[1]	, GetSx3Info("PF_REASC")[2]     ,'REASON' 		,'C'	,02                 		,0		                ,{|a,b,c| Vazio() .or. ValidRCC('S028',c, 1, 2) }	    ,{|a| BlockLine(a)}	,{}		,.T.	    	,Nil	,NIL	,NIL	,.F.)
oStru:AddField(GetSx3Info("PF_REASD")[1]	, GetSx3Info("PF_REASD")[2]     ,'READESC'		,'C'	,80                     	,0		                ,Nil	,{|a| BlockLine(a)}	,{}		,.F.	    	,Nil	,NIL	,NIL	,.F.)
oStru:AddField(GetSx3Info("RA_TABELA")[1]	, GetSx3Info("RA_TABELA")[2]	,'SALTABLE'		,'C'	,TAMSX3("RA_TABELA")[1] 	,0		                ,{|a,b,c| Vazio() .or. EXISTCPO("RB6",c) }	,{|a| BlockLine(a)}	,{}		,.F.	    	,Nil	,NIL	,NIL	,.F.)
oStru:AddField(GetSx3Info("RA_TABNIVE")[1]	, GetSx3Info("RA_TABNIVE")[2]	,'TABLEVEL'		,'C'	,TAMSX3("RA_TABNIVE")[1]	,0		                ,{|a,b,c| Vazio() .or. EXISTCPO("RB6",FwFldGet("SALTABLE")+c) }	,{|a| BlockLine(a)}	,{}		,.F.	    	,Nil	,NIL	,NIL	,.F.)
oStru:AddField(GetSx3Info("RA_TABFAIX")[1]	, GetSx3Info("RA_TABFAIX")[2]   ,'TABRANGE'		,'C'	,TAMSX3("RA_TABFAIX")[1]	,0		                ,{|a,b,c| Vazio() .or. EXISTCPO("RB6",FwFldGet("SALTABLE")+FwFldGet("TABLEVEL")+c) }	,{|a| BlockLine(a)}	,{}		,.F.	    	,Nil	,NIL	,NIL	,.F.)
oStru:AddField(GetSx3Info("RA_SALARIO")[1]	, GetSx3Info("RA_SALARIO")[2]   ,'AMOUNT'		,'N'	,TAMSX3("RA_SALARIO")[1]  	,TAMSX3("RA_SALARIO")[2],{|a,b,c| Vazio() .or. (Positivo() .And. fVldSal(c))}	,{|a| BlockLine(a)}		,{}		,.F.	    	,NIL	,NIL	,NIL	,.F.)
oStru:AddField(GetSx3Info("RA_CATFUNC")[1]	, GetSx3Info("RA_CATFUNC")[2]   ,'FUNCCAT'		,'C'	,TAMSX3("RA_CATFUNC")[1]	,0		                ,{|a,b,c| Vazio() .or. EXISTCPO("SX5","28"+c) }	,{|a| BlockLine(a)}	,{}		,.F.	    	,Nil	,NIL	,NIL	,.F.)
oStru:AddField(GetSx3Info("RA_TIPOPGT")[1]	, GetSx3Info("RA_TIPOPGT")[2]   ,'PAYTYPE'		,'C'	,TAMSX3("RA_TIPOPGT")[1]	,0		                ,{|a,b,c| Vazio() .or. EXISTCPO("SX5","40"+c) }	,{|a| BlockLine(a)}	,{}		,.F.	    	,Nil	,NIL	,NIL	,.F.)
oStru:AddField(GetSx3Info("RA_TNOTRAB")[1]	, GetSx3Info("RA_TNOTRAB")[2]   ,'WORKSHIFT'	,'C'	,TAMSX3("RA_TNOTRAB")[1]	,0		                ,{|a,b,c| Vazio() .or. EXISTCPO("SR6",c) }	,{|a| BlockLine(a)}	,{}		,.F.	    	,Nil	,NIL	,NIL	,.F.)
oStru:AddField(GetSx3Info("RA_SEQTURN")[1]	, GetSx3Info("RA_SEQTURN")[2]   ,'WORKTMSCHD'	,'C'	,TAMSX3("RA_SEQTURN")[1]	,0		                ,{|a,b,c| Vazio() .or. WkStSeqVld(c)}	,{|a| BlockLine(a)}	,{}		,.F.	    	,Nil	,NIL	,NIL	,.F.)
oStru:AddField(GetSx3Info("RA_DEPTO")[1]	, GetSx3Info("RA_DEPTO")[2]     ,'DEPARTMENT'	,'C'	,TAMSX3("RA_DEPTO")[1]  	,0		                ,{|a,b,c| Vazio() .or. OrgVldxDepto(c)}	,{|a| BlockLine(a)}	,{}		,.F.	    	,Nil	,NIL	,NIL	,.F.)
oStru:AddField(GetSx3Info("RA_POSTO")[1]	, GetSx3Info("RA_POSTO")[2]     ,'STATION'		,'C'	,TAMSX3("RA_POSTO")[1]		,0		                ,{|a,b,c| Vazio() .or. ConsPosto(c,FwFldGet("DEPARTMENT")) }	,{|a| BlockLine(a)}	,{}		,.F.	    	,Nil	,NIL	,NIL	,.F.)
oStru:AddField(GetSx3Info("RJ_DESC")[1]	    , GetSx3Info("RJ_DESC")[2]     ,'DESC'		    ,'C'	,TAMSX3("RJ_DESC")[1]       ,0		                ,Nil	,{|a| BlockLine(a)}	,{}		,.F.	    	,Nil	,NIL	,NIL	,.F.)
oStru:AddField(GetSx3Info("RA_CARGO")[1]	, GetSx3Info("RA_CARGO")[2]     ,'POSITION'		,'C'	,TAMSX3("RA_CARGO")[1]  	,0		                ,Nil	,{|a| BlockLine(a)}	,{}		,.F.	    	,Nil	,NIL	,NIL	,.F.)
oStru:AddField(GetSx3Info("RA_CODFUNC")[1]  , GetSx3Info("RA_CODFUNC")[2]   ,'ROLE'			,'C'	,TAMSX3("RA_CODFUNC")[1]	,0		                ,Nil	,{|a| BlockLine(a)}	,{}		,.F.	    	,Nil	,NIL	,NIL	,.F.)


oStru:AddTrigger( 'REASON','READESC', {|| .T. }, {|oModel| TrigReason(oModel) } )

oStru:AddTrigger( 'DEPARTMENT'  ,'POSITION'   , {|| .T. }, {|oModel| TrigPosRol(oModel)[1]  } )
oStru:AddTrigger( 'STATION'     ,'POSITION'   , {|| .T. }, {|oModel| TrigPosRol(oModel)[1]  } )
oStru:AddTrigger( 'DEPARTMENT'  ,'ROLE'       , {|| .T. }, {|oModel| TrigPosRol(oModel)[2]  } )
oStru:AddTrigger( 'STATION'     ,'ROLE'       , {|| .T. }, {|oModel| TrigPosRol(oModel)[2]  } )



Return oStru

//------------------------------------------------------------------
/*/{Protheus.doc} DefStrVDoc()

@return oStru
@author Flavio Lopes Rasta
@since 03/04/2018
/*/
//-------------------------------------------------------------------
Static Function DefStrVOper()
Local oStru	as Object

oStru 	:= 	FWFormViewStruct():New()

oStru:AddField('SEQUENCE' 	,'03'   ,GetSx3Info("RCC_SEQUEN")[1]  	,GetSx3Info("RCC_SEQUEN")[2]	,NIL ,'C'	,""		            ,Nil	,Nil        ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)
oStru:AddField('DATE' 	    ,'04'   ,GetSx3Info("R7_DATA")[1]	    ,GetSx3Info("R7_DATA")[2]	    ,NIL ,'D'	,""		            ,Nil	,Nil        ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)
oStru:AddField('REASON' 	,'05'   ,GetSx3Info("PF_REASC")[1]		,GetSx3Info("PF_REASC")[2]     	,NIL ,'C'	,""		            ,Nil	,'S28RU'       ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)
oStru:AddField('READESC'	,'06'   ,GetSx3Info("PF_REASD")[1]		,GetSx3Info("PF_REASD")[2]     	,NIL ,'C'	,""		            ,Nil	,Nil        ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)
oStru:AddField('SALTABLE'	,'07'   ,GetSx3Info("RA_TABELA")[1]		,GetSx3Info("RA_TABELA")[2]	  	,NIL ,'C'	,""		            ,Nil	,'RB601'    ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)
oStru:AddField('TABLEVEL'	,'08'   ,GetSx3Info("RA_TABNIVE")[1]	,GetSx3Info("RA_TABNIVE")[2]	,NIL ,'C'	,""		            ,Nil	,Nil        ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)
oStru:AddField('TABRANGE'	,'09'   ,GetSx3Info("RA_TABFAIX")[1]	,GetSx3Info("RA_TABFAIX")[2]   	,NIL ,'C'	,""		            ,Nil	,Nil        ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)
oStru:AddField('AMOUNT'		,'10'   ,GetSx3Info("RA_SALARIO")[1]	,GetSx3Info("RA_SALARIO")[2]   	,NIL ,'N'	,PesqPict("SR3","R3_VALOR") ,Nil	,Nil        ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)
oStru:AddField('FUNCCAT'	,'11'   ,GetSx3Info("RA_CATFUNC")[1]	,GetSx3Info("RA_CATFUNC")[2]   	,NIL ,'C'	,""		            ,Nil	,'28'       ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)
oStru:AddField('PAYTYPE'	,'12'   ,GetSx3Info("RA_TIPOPGT")[1]	,GetSx3Info("RA_TIPOPGT")[2]   	,NIL ,'C'	,""		            ,Nil	,'40'       ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)
oStru:AddField('WORKSHIFT'	,'13'   ,GetSx3Info("RA_TNOTRAB")[1]	,GetSx3Info("RA_TNOTRAB")[2]   	,NIL ,'C'	,""		            ,Nil	,'SR6'      ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)
oStru:AddField('WORKTMSCHD'	,'14'   ,GetSx3Info("RA_SEQTURN")[1]	,GetSx3Info("RA_SEQTURN")[2]   	,NIL ,'C'	,""		            ,Nil	,'XPJ'      ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)
oStru:AddField('DEPARTMENT'	,'15'   ,GetSx3Info("RA_DEPTO")[1]		,GetSx3Info("RA_DEPTO")[2]     	,NIL ,'C'	,""		            ,Nil	,'RD4RUS'   ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)
oStru:AddField('STATION'	,'18'   ,GetSx3Info("RA_POSTO")[1]		,GetSx3Info("RA_POSTO")[2]     	,NIL ,'C'	,""		            ,Nil	,'RCLRUS'   ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)
oStru:AddField('DESC'	    ,'19'   ,GetSx3Info("RJ_DESC")[1]		,GetSx3Info("RJ_DESC")[2]     	,NIL ,'C'	,""		            ,Nil	,Nil        ,.T.	   	,Nil	    ,NIL	    ,NIL	    ,Nil            ,Nil    ,.T.,Nil,Nil)

oStru:SetProperty('READESC'     ,MVC_VIEW_CANCHANGE, .F.)
oStru:SetProperty('DESC'        ,MVC_VIEW_CANCHANGE, .F.)

Return oStru 

//------------------------------------------------------------------
/*/{Protheus.doc} LoadTMP()

@return aLoad
@author Flavio Lopes Rasta
@since 03/04/2018
/*/
//-------------------------------------------------------------------
Static Function LoadTMP(oModel as Object)
Local aLoad         as Array
Local aLoadAux      as Array
Local aLines         as Array
Local aRelFields    as Array
Local nX            as Numeric
Local nY            as Numeric
Local nPos          as Numeric
Local cLastReason   as Character
Local cLastDpto     as Character
Local cLastPosto    as Character

aLoad       := {}
aLoadAux    := {}
aLines      := {}
cLastReason := ""
cLastDpto   := ""
cLastPosto  := ""


aRelFields:={   {"REASON","REASON",Space(2)},;
                {"READESC","READESC",Space(TAMSX3("R7_DESCTIP")[1])},;
                {"SALTABLE","RA_TABELA",Space(TAMSX3("RA_TABELA")[1])},;
				{"TABLEVEL","RA_TABFAIX",Space(TAMSX3("RA_TABFAIX")[1])},;
                {"TABRANGE","RA_TABNIVE",Space(TAMSX3("RA_TABNIVE")[1])},;
				{"AMOUNT","RA_SALARIO","0"},;
				{"FUNCCAT","RA_CATFUNC",Space(TAMSX3("R7_CATFUNC")[1])},;
				{"PAYTYPE","RA_TIPOPGT",Space(TAMSX3("R7_TIPOPGT")[1])},;
				{"WORKSHIFT","RA_TNOTRAB",Space(TAMSX3("RA_TNOTRAB")[1])},;
				{"WORKTMSCHD","RA_SEQTURN",Space(TAMSX3("RA_SEQTURN")[1])},;
				{"DEPARTMENT","RA_DEPTO",Space(TAMSX3("RA_DEPTO")[1])},;
				{"STATION","RA_POSTO",Space(TAMSX3("RA_POSTO")[1])},;
                {"DESC","DESC",Space(TAMSX3("RJ_DESC")[1])},;
                {"POSITION","RA_CARGO",Space(TAMSX3("RA_CARGO")[1])},;
				{"ROLE","RA_CODFUNC",Space(TAMSX3("RA_CODFUNC")[1])}}



aAdd(aLines,{dDataBase,aRelFields})


aAdd(aLoadAux,xFilial("SRA"))
aAdd(aLoadAux,SRA->RA_MAT)
aAdd(aLoadAux,StrZero(1,4))
aAdd(aLoadAux,aLines[1][1])
For nY := 1 To Len(aLines[1][2])
    If aLines[1][2][nY][2] == "REASON"
        cLastReason := aLines[1][2][nY][3]
        aAdd(aLoadAux,aLines[1][2][nY][3])
    ElseIf aLines[1][2][nY][2] == "READESC"
        aAdd(aLoadAux,fDescRCC("S028",cLastReason,1,2,3,80))
    ElseIf aLines[1][2][nY][2] == "RA_SALARIO"
        aAdd(aLoadAux,Val(aLines[1][2][nY][3]))
    ElseIf aLines[1][2][nY][2] == "RA_DEPTO"
        cLastDpto   := aLines[1][2][nY][3]
        aAdd(aLoadAux,aLines[1][2][nY][3])
    ElseIf aLines[1][2][nY][2] == "RA_POSTO"
        cLastPosto  := aLines[1][2][nY][3]
        aAdd(aLoadAux,aLines[1][2][nY][3])
    ElseIf aLines[1][2][nY][2] == "DESC"
        aAdd(aLoadAux,TrigDesc(cLastDpto, cLastPosto)) //Trocar pela fun��o do gatilho
    Else
        aAdd(aLoadAux,aLines[1][2][nY][3])
    Endif    
Next nY

aAdd(aLoad,aLoadAux)
aAdd(aLoad,0)

Return aLoad

//------------------------------------------------------------------
/*/{Protheus.doc} LoadHIST()

@return aLoad
@author Flavio Lopes Rasta
@since 03/04/2018
/*/
//-------------------------------------------------------------------
Static Function LoadHIST(oModel as Object)
Local aLoad         as Array
Local aLoadAux      as Array
Local aLines         as Array
Local oStruOPER     as Object
Local aRelFields    as Array
Local nX            as Numeric
Local nY            as Numeric
Local aAreaSR9      as Array
Local dCurrData     as Date
Local aTMPData      as Array
Local nPos          as Numeric
Local cLastReason   as Character
Local lFound1       as Logical
Local cLastDpto     as Character
Local cLastPosto    as Character

aLoad       := {}
aLoadAux    := {}
aLines      := {}
dCurrData   := Ctod("//")
aTMPData    := {}
cLastReason := ""
lFound1     := .F.
cLastDpto   := ""
cLastPosto  := ""

aAreaSR9 := SR9->(GetArea())

aRelFields:={   {"REASON","REASON",Space(2)},;
                {"READESC","READESC",Space(TAMSX3("R7_DESCTIP")[1])},;
                {"SALTABLE","RA_TABELA",Space(TAMSX3("RA_TABELA")[1])},;
				{"TABLEVEL","RA_TABFAIX",Space(TAMSX3("RA_TABFAIX")[1])},;
                {"TABRANGE","RA_TABNIVE",Space(TAMSX3("RA_TABNIVE")[1])},;
				{"AMOUNT","RA_SALARIO","0"},;
				{"FUNCCAT","RA_CATFUNC",Space(TAMSX3("R7_CATFUNC")[1])},;
				{"PAYTYPE","RA_TIPOPGT",Space(TAMSX3("R7_TIPOPGT")[1])},;
				{"WORKSHIFT","RA_TNOTRAB",Space(TAMSX3("RA_TNOTRAB")[1])},;
				{"WORKTMSCHD","RA_SEQTURN",Space(TAMSX3("RA_SEQTURN")[1])},;
				{"DEPARTMENT","RA_DEPTO",Space(TAMSX3("RA_DEPTO")[1])},;
				{"STATION","RA_POSTO",Space(TAMSX3("RA_POSTO")[1])},;
                {"DESC","DESC",Space(TAMSX3("RJ_DESC")[1])},;
                {"POSITION","RA_CARGO",Space(TAMSX3("RA_CARGO")[1])},;
				{"ROLE","RA_CODFUNC",Space(TAMSX3("RA_CODFUNC")[1])}}

SR9->(DbSetOrder(2))
If SR9->(DbSeek(xFilial("SR9")+SRA->RA_MAT))
    While !SR9->(Eof()) .And. DToS(SR9->R9_DATA) <= DToS(SRA->RA_ADMISSA)
        SR9->(DbSkip())
    EndDo
    dCurrDate := SR9->R9_DATA
    aTMPData:= aClone(aRelFields)
    While !SR9->(Eof()) .And. xFilial("SR9")+SRA->RA_MAT == SR9->(R9_FILIAL+R9_MAT)
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

            If (nPos:= aScan(aTMPData,{|x| x[2] == SR9->R9_CAMPO}))
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
    aAdd(aLoadAux,xFilial("SRA"))
    aAdd(aLoadAux,SRA->RA_MAT)
    aAdd(aLoadAux,StrZero(nX,4))
    aAdd(aLoadAux,aLines[nX][1])
    For nY := 1 To Len(aLines[nX][2])
        If aLines[nX][2][nY][2] == "REASON"
            cLastReason := aLines[nX][2][nY][3]
            aAdd(aLoadAux,aLines[nX][2][nY][3])
        ElseIf aLines[nX][2][nY][2] == "READESC"
            aAdd(aLoadAux,fDescRCC("S028",cLastReason,1,2,3,80))
        ElseIf aLines[nX][2][nY][2] == "RA_SALARIO"
            aAdd(aLoadAux,Val(aLines[nX][2][nY][3]))
        ElseIf aLines[nX][2][nY][2] == "RA_DEPTO"
            cLastDpto   := aLines[nX][2][nY][3]
            aAdd(aLoadAux,aLines[nX][2][nY][3])
        ElseIf aLines[nX][2][nY][2] == "RA_POSTO"
            cLastPosto  := aLines[nX][2][nY][3]
            aAdd(aLoadAux,aLines[nX][2][nY][3])
        ElseIf aLines[nX][2][nY][2] == "DESC"
            aAdd(aLoadAux,TrigDesc(cLastDpto, cLastPosto)) //Trocar pela fun��o do gatilho
        Else
            aAdd(aLoadAux,aLines[nX][2][nY][3])
        Endif    
    Next nY
    
    aAdd(aLoad,{0,aLoadAux})
    aLoadAux := {}
Next nX



RestArea( aAreaSR9 )

Return aLoad

/*
{Protheus.doc} OrgVldxDepto()
Validacao do Get Departamento.	
@author Rogerio Ribeiro
@since 18/12/07
*/
Static Function OrgVldxDepto(cDeptoCode as Character)
Local aArea    as Array
Local aAreaRD4 as Array
Local aAreaRDK as Array
Local lRet     as Logical

aAreaRD4 := RD4->( GetArea() )
aAreaRDK := RDK->( GetArea() )
lRet     := .T.

If lRet .And. !Empty(cDeptoCode)
    dbSelectArea("RD4")
    RD4->( dbSetOrder(RetOrdem("RD4", "RD4_FILIAL+RD4_EMPIDE+RD4_FILIDE+RD4_CODIDE")) )  
    RD4->( dbGoTop() )

    dbSelectArea("RDK")
    RDK->( dbSetOrder(RetOrdem("RDK","RDK_FILIAL+RDK_CODIGO+RDK_HIERAR+RDK_TIPO")) )

    If lRet := ( RD4->( dbSeek(xFilial("RD4") + FwCodEmp("SRA") + xFilial("RDK") + cDeptoCode) ) )
        lRet := .F.
        
        While RD4->( !Eof() ) .And. (RD4->(RD4_FILIAL+RD4_EMPIDE+RD4_FILIDE+RD4_CODIDE) == xFilial("RD4") + FwCodEmp("SRA") + xFilial("SQB") + cDeptoCode)
            RDK->( dbGoTop() )
            If RDK->( dbSeek(xFilial("RDK") + RD4->RD4_CODIGO + "11") )
                lRet := .T.
                Exit
            EndIf				   
            RD4->( dbSkip() )
        EndDo
    EndIf                    
EndIf

If Empty(cDeptoCode)
    lRet := .F.
Else
    lRet := ExistCpo("SQB", cDeptoCode, 1)
EndIf

If !lRet .or. Empty(cDeptoCode)
    Help('',1,'RU07T03INVDEP',,STR0007+CRLF+STR0008,4)// "Atention"#"The informed department is not valid!"    
EndIf

RestArea( aAreaRDK )
RestArea( aAreaRD4 )

Return lRet 

/*
{Protheus.doc} fVldSal()
Validation of field Amount (RA_SALARY).
Responsible to check if amount is in accordance
with selected Salary Table/Level.
@author raquel.andrade
@since 15/12/2017
@version V12.1.17
*/
Static Function fVldSal(nSalary as Numeric)
Local aArea  as Array
Local oModel as Object
Local oModelTMP as Object

Local cTable as Character
Local cLevel as Character
Local cRange as Character
Local lRet   as Logical

lRet     := .T.
aAreaRB6 := RB6->(GetArea())

oModel := FwModelActive()
oModelTMP := oModel:GetModel("TMPDETAIL")
cTable := oModelTMP:GetValue("SALTABLE")
cLevel := oModelTMP:GetValue("TABLEVEL")
cRange := oModelTMP:GetValue("TABRANGE")


If Empty(cTable) .Or. Empty(cLevel) .Or. Empty(cRange)
    Help('',1,'RU07T03AMNTFI',,STR0009,1)// "Please select Table Salary, Level and Range before filling Amount."
    lRet := .F.
Else
    dbSelectArea("RB6")
    RB6->(dbSetOrder(1))
    If dbSeek(xFilial("RB6")+cTable+cLevel+cRange)
        If nSalary > RB6->RB6_VALOR
            Help('',1,'RU07T03AMNTHI',,STR0010,1)// "Amount is higher than range selected!"
            lRet := .F.
        EndIf
    EndIf
EndIf

RestArea(aAreaRB6)
	
Return lRet

/*
{Protheus.doc} Gpea010SeqVld()
Valida a Sequencia de Turno preenchida.  	
@author Marinaldo de Jesus
@since 17/10/01
*/
Static Function WkStSeqVld(cWkShSc as Character)

Local aArea     as Array
Local oModel    as Object
Local oModelTMP as Object
Local lRet      as Logical
Local lUseSPJ   as Logical
Local cFil      as Character
Local cAliasTab as Character

lRet	:= .T.
lUseSPJ := SuperGetMv("MV_USESPJ",NIL,"0")  == "1"

aArea       := GetArea()
oModel      := FwModelActive()
oModelTMP   := oModel:GetModel("TMPDETAIL")

cWorkShift  := oModelTMP:GetValue('WORKSHIFT')

If lUseSPJ
    cAliasTab := "SPJ"  // Virtual
Else
    cAliasTab := "RF2"  // Fisica - Fase4
EndIf  

cFil := xFilial( cAliasTab , xFilial("SRA") )

If !Empty( cWkShSc ) 
    If !(cAliasTab)->( MsSeek( cFil + cWorkShift + cWkShSc) )
        Help('',1,'RU07T03WTSNOREG',,STR0011,1) // "WTS Swquence is not registered for the Work Shift"
        lRet := .F.
    Endif
EndIf

RestArea(aArea)

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} TrigReason()

@description Function to trigger the description of the reason code
@return lRet
@author Flavio Lopes Rasta
@since 03/04/2018
/*/
//-------------------------------------------------------------------
Static Function TrigReason(oModelTMP as Object)
Local cRet as Character

cRet := ""

cRet := fDescRCC("S028",oModelTMP:GetValue("REASON"),1,2,3,80)

Return cRet

//------------------------------------------------------------------
/*/{Protheus.doc} ConsPosto()

@description Function to validate the station
@return lRet
@author Flavio Lopes Rasta
@since 03/04/2018
/*/
//-------------------------------------------------------------------
Static Function ConsPosto(cStation as Character,cDepto as Character) 
Local lRet      as Logical
Local aAreaRCL  as Logical
Local oModel    as Object

lRet        := .T.
aAreaRCL    := RCL->(GetArea())

RCL->(DbSetOrder(1))
If !RCL->(dbSeek(xFilial("RCL")+cDepto+cStation))
    Help('',1,'RU07T03STNOREG',,STR0012,1) // "Informed Station in not valid or nor registered"
    lRet:= .F.
Else
    If  RCL->RCL_STATUS == "3"  .Or.  RCL->RCL_STATUS ==  "4" 
        Help('',1,'RU07T03STFRCL',,STR0013,1)// "Station has 'Frozen' or 'Cancelled' status."
        lRet := .F.
    Endif
    If lRet
        If RCL->RCL_OPOSTO + 1  > RCL->RCL_NPOSTO 
            Help('',1,'RU07T03MAXSTAT',,STR0014,1) //"It exceeded the maximum quantity of individuals allowed fot the Station."
            lRet:=.F.
        Endif
    Endif     
EndIf 
    
RestArea( aAreaRCL ) 

Return lRet 

//------------------------------------------------------------------
/*/{Protheus.doc} RU07T03Prt

@description Print order
@author Flavio Lopes Rasta
@since 23/04/2018
/*/
//-------------------------------------------------------------------
Function RU07T03Prt(oView as Object)

Local oWord     as Object
Local cFileOpen as Character 
Local cFileSave as Character 
Local oModel	as Object
Local oModelTMP	as Object
Local cSeq 	    as Character
Local cCodUnic  as Character

oWord       := Nil
oModel	    := oView:GetModel()
oModelTMP	:= oModel:GetModel("TMPDETAIL")
cSeq 	    := oModelTMP:GetValue('SEQUENCE')
cCodUnic    := SRA->RA_CODUNIC

If Pergunte("SAVEORD01",.T.)
    cFileOpen := AllTrim(MV_PAR01)
    cFileSave := AllTrim(MV_PAR02) + "IM-CWC-Order" +"_"+ cCodUnic + "_" + cSeq + ".docx"
    If cFileOpen!="" .AND. !RAT(".DOC", UPPER(cFileOpen)) 
        MsgInfo(STR0015,STR0016) //"Incorrect file extension" # "Print Order"
    Else
        oWord := OLE_CreateLink()
        If File(cFileOpen)
            OLE_OpenFile(oWord, cFileOpen)
        Else
            OLE_NewFile(oWord)
        EndIf
        OLE_SaveAsFile( oWord, cFileSave,,,.F. )
    ENDIF
EndIf

Return .T.


//------------------------------------------------------------------
/*/{Protheus.doc} fReasDesc

@description Return the  description of reason

@author Flavio Lopes Rasta
@since 23/04/2018
/*/
//-------------------------------------------------------------------
Function fReasDesc(cReason as Character)
Local cRet as Character

cRet := ""

If cReason == "00"
    cRet := "INITIAL DATA"
Else
    cRet := fDescRCC("S028",cReason,1,2,3,80)
Endif

Return cRet

//------------------------------------------------------------------
/*/{Protheus.doc} fReasDesc

@description Validation for the reason code

@author Flavio Lopes Rasta
@since 23/04/2018
/*/
//-------------------------------------------------------------------

Function fReasVld(cReason as Character)
Local lRet as Logical

lRet := .F.

If cReason == "00"
    lRet := .T.
Else
    lRet := ValidRCC('S028',cReason, 1, 2)
Endif 

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} GetSx3Info()

@description Validation for the reason code

@parameters cField  Field Id in SX3 table

@return aInfo
        aInfo[1] X3Titulo - Título do campo
        aInfo[2] X3Descric - Descrição do campo contido no dicionário
        aInfo[3] X3Picture - Máscara do campo
        aInfo[4] X3CBox - Campo combo
        aInfo[5] X3Uso - Avaliação de campo em uso

@author Flavio Lopes Rasta
@since 24/04/2018
/*/
//-------------------------------------------------------------------

Static Function GetSx3Info(cField as Character)

Local aAreaSX3  as Array
Local aInfo     as Array
Local nX        as Numeric

aAreaSX3    := SX3->(GetArea())
aInfo       := {}

If SX3->(DbSeek(cField))
    aAdd(aInfo,X3Titulo(cField))
    aAdd(aInfo,X3Descric(cField))
    aAdd(aInfo,X3Picture(cField))
    aAdd(aInfo,X3CBox(cField))
    aAdd(aInfo,X3Uso(cField))
Else
    For nX :=1 To 5
        aAdd(aInfo,"")
    Next nX
Endif

RestArea( aAreaSX3 )

Return aInfo

//------------------------------------------------------------------
/*/{Protheus.doc} TrigDesc

@description Trigger for the field DESC

@author Flavio Lopes Rasta
@since 27/04/2018
/*/
//-------------------------------------------------------------------
Static Function TrigDesc(cDepart as Character, cStation as Character,oModelTMP as Object)
Local cDesc     as Character 
Local aAreaRCL  as Array

Default cDepart     := ""
Default cStation    := ""

aAreaRCL := RCL->(GetArea())

cDesc       := ""

If oModelTMP <> Nil 
    cDepart     := oModelTMP:GetValue("DEPARTMENT")
    cStation    := oModelTMP:GetValue("STATION")
Endif

If !Empty(cDepart) .And. !Empty(cStation) 
    RCL->(DbSetOrder(1))
    If RCL->(DbSeek(xFilial("RCL")+cDepart+cStation))
        cDesc := OemToAnsi(fDesc("SRJ",RCL->RCL_FUNCAO,"RJ_DESC"))       
    Endif
EndIf

RestArea(aAreaRCL)

Return cDesc

//------------------------------------------------------------------
/*/{Protheus.doc} TrigPosRol

@description Trigger for the fields POSITION/ROLE

@author Flavio Lopes Rasta
@since 27/04/2018
/*/
//-------------------------------------------------------------------
Static Function TrigPosRol(oModelTMP as Object)
Local aPosRol   as Array
Local cDepart   as Character
Local cStation  as Character
Local aAreaRCL  as Array

aAreaRCL := RCL->(GetArea())
aPosRol     := {"",""}
cDepart     := oModelTMP:GetValue("DEPARTMENT")
cStation    := oModelTMP:GetValue("STATION")

If !Empty(cDepart) .And. !Empty(cStation) 
    RCL->(DbSetOrder(1))
    If RCL->(DbSeek(xFilial("RCL")+cDepart+cStation))
    	aPosRol[1] := RCL->RCL_CARGO
        aPosRol[2] := RCL->RCL_FUNCAO
    Endif
EndIf

RestArea(aAreaRCL)

Return aPosRol