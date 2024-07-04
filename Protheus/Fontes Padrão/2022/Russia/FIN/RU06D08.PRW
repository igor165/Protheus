#INCLUDE "PROTHEUS.CH"    
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RU06D08.CH"

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06D08

Client-bank exchange format settings routine 

@param       
@return      Nil
@example     
@author      astepanov
@since       December/11/2018
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Function RU06D08()

    oBrowse := BrowseDef()
    oBrowse:Activate()

Return (Nil)

//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

List of actions for browse window

@param       Nil
@return      Array aRotina
@example     
@author      astepanov
@since       December/11/2018
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina As Array

    aRotina := {}

    ADD OPTION aRotina TITLE STR0002    ACTION "RU06D0810_Act(1)"   OPERATION 1 ACCESS 0   // View
    ADD OPTION aRotina TITLE STR0003    ACTION "RU06D0810_Act(3)"   OPERATION 3 ACCESS 0   // Insert
    ADD OPTION aRotina TITLE STR0004    ACTION "RU06D0810_Act(4)"   OPERATION 4 ACCESS 0   // Edit
    ADD OPTION aRotina TITLE STR0005    ACTION "RU06D0810_Act(5)"   OPERATION 5 ACCESS 0   // Delete
    ADD OPTION aRotina TITLE STR0006    ACTION "RU06D0810_Act(9)"   OPERATION 9 ACCESS 0   // Copy

Return (aRotina)

//-----------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef

Browse window definition

@param       Nil
@return      Object oBrowse
@example     
@author      astepanov
@since       December/11/2018
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Static Function BrowseDef()

    Local oBrowse As Object

    oBrowse	:= FWmBrowse():New()
    oBrowse:SetAlias("F5N")
    oBrowse:SetDescription(STR0001) //Client-bank exhange format settings
    oBrowse:SetMenuDef("RU06D08")

Return (oBrowse) 

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06D0810_Act

Function process actions called from main menu

@param       Numeric nOperation
@return      LOGICAL lRet
@example     
@author      astepanov
@since       December/11/2018
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Function RU06D0810_Act(nOperation As Numeric)

    Local aArea     As Array
    Local aEnButns  As Array 
    Local lRet      As Logical
    Local cStatus   As Character
    Local cPayord   As Character
    Local cOper     As Character 

    Default nOperation := 1

    lRet:=.T.

    aArea := GetArea()
    cOper := ""

    Do Case
        Case nOperation == 3
            cOper := STR0028 //Creation
        Case nOperation == 1
            cOper := STR0002 //Viewing
        Case nOperation == 4
            cOper := STR0029 //Editing
        Case nOperation == 9
            cOper := STR0006 //Copying
        Case nOperation == 5
            cOper := STR0005 //Deletion
    EndCase

    aEnButns := {}
    AADD(aEnButns, {.F.,Nil}) //1 - Copy 
    AADD(aEnButns, {.F.,Nil}) //2 - Cut 
    AADD(aEnButns, {.F.,Nil}) //3 - Paste 
    AADD(aEnButns, {.F.,Nil}) //4 - Calculator 
    AADD(aEnButns, {.F.,Nil}) //5 - Spool 
    AADD(aEnButns, {.F.,Nil}) //6 - Print 
    AADD(aEnButns, {.T.,Nil}) //7 - Confirm 
    AADD(aEnButns, {.T.,Nil}) //8 - Cancel 
    AADD(aEnButns, {.F.,Nil}) //9 - WalkTrhough 
    AADD(aEnButns, {.F.,Nil}) //10 - Environment 
    AADD(aEnButns, {.F.,Nil}) //11 - Mashup 
    AADD(aEnButns, {.F.,Nil}) //12 - Help 
    AADD(aEnButns, {.F.,Nil}) //13 - Form HTML 
    AADD(aEnButns, {.F.,Nil}) //14 - ECM 

    FWExecView(cOper/*cTitulo*/,;
            "RU06D08",;
            nOperation/*nOperation*/,;
            /*oDlg*/,;
            {|| .T.}/*bCloseOnOK*/,;
            /*bOk*/,;
            /*nPercReducao*/,;
            aEnButns,;
            /*bCancel*/,;
            /*cOperatId*/,;
            /*cToolBar*/,;
            /*oModelAct*/)

    RestArea(aArea)

Return (lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Model definition

@param       Nil
@return      Object oModel
@example     
@author      astepanov
@since       December/12/2018
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()

    Local oStructF5N   As Object
    Local oStructF5U   As Object
    Local oStructF5V   As Object
    Local oStructAll   As Object
    Local oModel       As Object
    Local oUpdF5VEvt   As Object

    oModel:= MPFormModel():New("RU06D08")
    oModel:SetDescription(STR0001) //ClientBankExchangeFormatSettings

    oStructF5N := FWFormStruct(1, "F5N")
    oStructF5U := FWFormStruct(1, "F5U")
    oStructF5V := FWFormStruct(1, "F5V")
    oStructAll := RU06D0802_DefVirtModelF5V()

    oStructF5N:GetTable()[3] := STR0027 //'Format settings'

    oModel:AddFields("RU06D08_MHEAD", Nil, oStructF5N)
    oModel:GetModel("RU06D08_MHEAD"):SetDescription(STR0024) //DataExchange format

    oModel:AddGrid("RU06D08_MSECTIONS", "RU06D08_MHEAD", oStructF5U)
    oModel:GetModel("RU06D08_MSECTIONS"):SetDescription(STR0008) //Sections
    oModel:GetModel("RU06D08_MSECTIONS"):SetUniqueLine({"F5U_FILIAL","F5U_FRMCOD","F5U_SECTN"},/*bCodeLineIsNotUnique*/)
    oModel:GetModel("RU06D08_MSECTIONS"):SetOptional(.T.)

    oModel:AddGrid("RU06D08_MTAGS", "RU06D08_MSECTIONS", oStructF5V,/*bPreValid*/,/*bPosValid*/,,,/* bLoad*/)
    oModel:GetModel("RU06D08_MTAGS"):SetDescription(STR0025) //Tag in file related to section
    oModel:GetModel("RU06D08_MTAGS"):SetUniqueLine({"F5V_FILIAL","F5V_FRMCOD","F5V_SECTN","F5V_TAGSEQ"},/*bCodeLineIsNotUnique*/)
    oModel:GetModel("RU06D08_MTAGS"):SetOptional(.T.)

    oModel:AddGrid("RU06D08_MALLTAGS","RU06D08_MHEAD", oStructAll,/*bPreValid*/,/*bPosValid*/,,,{|oModel| RU06D0803_LoadAllTags(oModel)}/* bLoad*/)
    oModel:GetModel("RU06D08_MALLTAGS"):SetDescription(STR0026) //All tags
    oModel:GetModel("RU06D08_MALLTAGS"):GetStruct():SetProperty("V_FRMCOD", MODEL_FIELD_INIT,{|| oModel:GetModel("RU06D08_MTAGS"):GetValue("F5V_FRMCOD")})
    oModel:GetModel("RU06D08_MALLTAGS"):GetStruct():SetProperty("V_SECTN" , MODEL_FIELD_INIT,{|| oModel:GetModel("RU06D08_MTAGS"):GetValue("F5V_SECTN") })
    oModel:GetModel("RU06D08_MALLTAGS"):GetStruct():SetProperty("V_TAGSEQ", MODEL_FIELD_INIT,{||  1 })
    oModel:GetModel("RU06D08_MALLTAGS"):GetStruct():SetProperty("V_TAGTYP", MODEL_FIELD_INIT,{|| "1"})
    oModel:GetModel("RU06D08_MALLTAGS"):SetNoDeleteLine(.T.)
    oModel:GetModel("RU06D08_MALLTAGS"):SetOptional(.T.)

    oModel:SetRelation("RU06D08_MSECTIONS", {{"F5U_FILIAL"   ,"xfilial('F5N')"},;
                                            {"F5U_FRMCOD"    ,"F5N_FRMCOD"    }},)
    oModel:SetRelation("RU06D08_MTAGS",     {{"F5V_FILIAL"   ,"xfilial('F5U')"},;
                                            {"F5V_FRMCOD"    ,"F5U_FRMCOD"    },;
                                            {"F5V_SECTN"     ,"F5U_SECTN"     }},)
    
    oUpdF5VEvt := RU06D08EventRUS():New()
    oModel:InstallEvent("RU06D08EventID",,oUpdF5VEvt)

Return (oModel)

//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

View definition

@param       Nil
@return      Object oView
@example     
@author      astepanov
@since       December/12/2018
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()

    Local oView      As Object
    Local oModel     As Object
    Local oStructF5N As Object
    Local oStructF5U As Object
    Local oStructF5V As Object
    Local oStructAll As Object //Object for creating virtual grid 
                               //F5V_FILAL=F5N_FILIAL and 
                               //F5V_FRMCOD=F5N_FRMCOD
    Local nScreenTop As Numeric
    Local nScreenBot As Numeric

    oModel     := FWLoadModel("RU06D08")
    oStructF5N := FWFormStruct(2, "F5N")
    oStructF5U := FWFormStruct(2, "F5U")
    oStructF5V := FWFormStruct(2, "F5V")
    oStructAll := RU06D0804_DefVirtViewF5V()

    oStructF5U:RemoveField("F5U_FRMCOD")
    oStructF5V:RemoveField("F5V_FRMCOD")
    oStructF5V:RemoveField("F5V_SECTN" )

    oView := FWFormView():New()

    oView:SetModel(oModel)

    oView:AddField("RU06D08_MHEAD",    oStructF5N, "RU06D08_MHEAD"    )

    oView:AddGrid("RU06D08_MSECTIONS", oStructF5U, "RU06D08_MSECTIONS")

    oView:AddGrid("RU06D08_MTAGS",     oStructF5V, "RU06D08_MTAGS"    )
    oView:AddIncrementField("RU06D08_MTAGS","F5V_TAGSEQ")

    oView:AddGrid("RU06D08_MALLTAGS",  oStructAll, "RU06D08_MALLTAGS" )
    oView:AddIncrementField("RU06D08_MALLTAGS","V_TAGSEQ")
    oView:SetViewProperty("RU06D08_MALLTAGS","OnlyView")

    oView:CreateVerticalBox('SUPERIOR', 100 /*%*/)
    oView:CreateFolder("RU06D08_FOLDER","SUPERIOR")

    nScreenTop := 25 /*%*/
    nScreenBot := 100 - nScreenTop /*%*/

    oView:AddSheet("RU06D08_FOLDER","RU06D08_SheetHeader",STR0007/*'Header'*/,/*bAction*/)
    oView:CreateHorizontalBox("BOXFORMHEADER",nScreenTop/*%*/,/*idHB*/,,"RU06D08_FOLDER","RU06D08_SheetHeader")
    oView:CreateHorizontalBox("BOXFORMALTAGS",nScreenBot/*%*/,/*idHB*/,,"RU06D08_FOLDER","RU06D08_SheetHeader")

    oView:AddSheet("RU06D08_FOLDER","RU06D08_SheetSection",STR0008/*'Sections'*/,/*bAction*/)
    oView:CreateHorizontalBox("BOXFORMSECTION",nScreenTop/*%*/,/*idHB*/,,"RU06D08_FOLDER","RU06D08_SheetSection")
    oView:CreateHorizontalBox("BOXFORMSECTAGS",nScreenBot/*%*/,/*idHB*/,,"RU06D08_FOLDER","RU06D08_SheetSection")

    oView:SetOwnerView("RU06D08_MHEAD",    "BOXFORMHEADER" )
    oView:SetOwnerView("RU06D08_MALLTAGS", "BOXFORMALTAGS" )
    oView:SetOwnerView("RU06D08_MSECTIONS","BOXFORMSECTION")
    oView:SetOwnerView("RU06D08_MTAGS",    "BOXFORMSECTAGS")

Return (oView)



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06D0802_DefVirtModelF5V

Creates virtual model structure

@param       
@return      Object oStr
@example     
@author      astepanov
@since       January/09/2019
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Function RU06D0802_DefVirtModelF5V()

    Local oStr   As Object
    Local aArea  As Array

    aArea := GetArea()
    oStr  := FWFormModelStruct():New()

    //Indexes
    oStr:AddIndex(1,;                                        //[01] - Idnex order
                "01",;                                       //[02] - ID
                "V_FILIAL + V_FRMCOD + V_SECTN + V_TAGSEQ",; //[03] - Key of Index
                "Virt_AllTags",;                             //[04] - Description of index
                "",;                                         //[05] - Lookup expression
                "",;                                         //[06] - Index nickname
                .T.)                                         //[07] - Index used on interface

    //Fields      Title,                 ToolTip,               ID,        Tipo,                               Tam,                                   Dec,                                     Valid,When,    Combo,Oblig,Init,Chave,Altera,Virtual
    oStr:AddField(RetTitle("F5V_FILIAL"),RetTitle("F5V_FILIAL"),"V_FILIAL",GetSX3Cache("F5V_FILIAL","X3_TIPO"),GetSX3Cache("F5V_FILIAL","X3_TAMANHO"),GetSX3Cache("F5V_FILIAL","X3_DECIMAL")  ,Nil ,{|| .F.}  ,{}  ,.F.  ,Nil ,Nil  ,Nil   ,.F.)
    oStr:AddField(RetTitle("F5V_FRMCOD"),RetTitle("F5V_FRMCOD"),"V_FRMCOD",GetSX3Cache("F5V_FRMCOD","X3_TIPO"),GetSX3Cache("F5V_FRMCOD","X3_TAMANHO"),GetSX3Cache("F5V_FRMCOD","X3_DECIMAL")  ,Nil ,{|| .F.}  ,{}  ,.F.  ,Nil ,Nil  ,Nil   ,.F.)
    oStr:AddField(RetTitle("F5V_SECTN") ,RetTitle("F5V_SECTN") ,"V_SECTN" ,GetSX3Cache("F5V_SECTN" ,"X3_TIPO"),GetSX3Cache("F5V_SECTN" ,"X3_TAMANHO"),GetSX3Cache("F5V_SECTN" ,"X3_DECIMAL")  ,Nil ,{|| .F.}  ,STRTOKARR(X3Cbox(RetTitle("F5U_SECTN")),";"),.F.,Nil,Nil,Nil,.F.)
    oStr:AddField(RetTitle("F5V_TAGSEQ"),RetTitle("F5V_TAGSEQ"),"V_TAGSEQ",GetSX3Cache("F5V_TAGSEQ","X3_TIPO"),GetSX3Cache("F5V_TAGSEQ","X3_TAMANHO"),GetSX3Cache("F5V_TAGSEQ","X3_DECIMAL")  ,Nil ,{|| .F.}  ,{}  ,.F.  ,Nil ,Nil  ,Nil   ,.F.)
    oStr:AddField(RetTitle("F5V_TAGDES"),RetTitle("F5V_TAGDES"),"V_TAGDES",GetSX3Cache("F5V_TAGDES","X3_TIPO"),GetSX3Cache("F5V_TAGDES","X3_TAMANHO"),GetSX3Cache("F5V_TAGDES","X3_DECIMAL")  ,Nil ,{|| .F.}  ,{}  ,.F.  ,Nil ,Nil  ,Nil   ,.F.)
    oStr:AddField(RetTitle("F5V_TAG")   ,RetTitle("F5V_TAG")   ,"V_TAG"   ,GetSX3Cache("F5V_TAG"   ,"X3_TIPO"),GetSX3Cache("F5V_TAG"   ,"X3_TAMANHO"),GetSX3Cache("F5V_TAG"   ,"X3_DECIMAL")  ,Nil ,{|| .F.}  ,{}  ,.F.  ,Nil ,Nil  ,Nil   ,.F.)
    oStr:AddField(RetTitle("F5V_TAGTYP"),RetTitle("F5V_TAGTYP"),"V_TAGTYP",GetSX3Cache("F5V_TAGTYP","X3_TIPO"),GetSX3Cache("F5V_TAGTYP","X3_TAMANHO"),GetSX3Cache("F5V_TAGTYP","X3_DECIMAL")  ,Nil ,{|| .F.}  ,STRTOKARR(X3Cbox(),";"),.F.,Nil,Nil,Nil,.F.)
    oStr:AddField(RetTitle("F5V_VALUE") ,RetTitle("F5V_VALUE") ,"V_VALUE" ,GetSX3Cache("F5V_VALUE" ,"X3_TIPO"),GetSX3Cache("F5V_VALUE" ,"X3_TAMANHO"),GetSX3Cache("F5V_VALUE" ,"X3_DECIMAL")  ,Nil ,{|| .F.}  ,{}  ,.F.  ,Nil ,Nil  ,Nil   ,.F.)
    oStr:AddField(RetTitle("F5V_VALDES") ,RetTitle("F5V_VALDES") ,"V_VALDES" ,GetSX3Cache("F5V_VALDES" ,"X3_TIPO"),GetSX3Cache("F5V_VALDES" ,"X3_TAMANHO"),GetSX3Cache("F5V_VALDES" ,"X3_DECIMAL")  ,Nil ,{|| .F.}  ,{}  ,.F.  ,Nil ,Nil  ,Nil   ,.F.)

    RestArea(aArea)

Return (oStr)

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06D0803_LoadAllTags

Load all tags from F5V table
F5V_FILAL=F5N_FILIAL and F5V_FRMCOD=F5N_FRMCOD

@param       Object oModel
@return      Array  aLines
@example     
@author      astepanov
@since       January/09/2019
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Function RU06D0803_LoadAllTags(oModel, lAppendLine)

        Local   aLines      As Array
        Local   cQuery      As Character
        Local   cTab        As Character
        Local   oModelF5N   As Object
        Local   aArea       As Array
        Default lAppendLine := .F.

        aArea     := GetArea()
        oModelF5N := oModel:GetModel("RU06D08_MHEAD")
        aLines	  := {}

        cQuery    := " SELECT * FROM " + RetSQLName("F5V")  + " F5V "
        cQuery    += " LEFT JOIN " + RetSQLName("F5N") +" F5N "
        cQuery    += " ON (F5V_FILIAL=F5N_FILIAL AND F5V_FRMCOD=F5N_FRMCOD) "
        cQuery    += " WHERE F5V_FILIAL ='" + xFilial("F5V") +"'"
        cQuery    += " AND F5V_FRMCOD ='" + FwFldGet("F5N_FRMCOD",,oModelF5N) +"'"
        cQuery    += " AND F5V.D_E_L_E_T_ =' ' AND F5N.D_E_L_E_T_ =' '"

        cQuery    := ChangeQuery(cQuery)
        cTab      := CriaTrab( ,.F.)
        TcQuery cQuery New Alias ((cTab))

        DbSelectArea((cTab))
        (cTab)->(DbGoTop())

        While (cTab)->(!EOF())
            AADD(aLines,;
                {0,{;
                    (cTab)->F5V_FILIAL,;
                    (cTab)->F5V_FRMCOD,;
                    (cTab)->F5V_SECTN,;
                    (cTab)->F5V_TAGSEQ,;
                    (cTab)->F5V_TAGDES,;
                    (cTab)->F5V_TAG,;
                    (cTab)->F5V_TAGTYP,;
                    (cTab)->F5V_VALUE,;
                    RU06D08007_ValDescr((cTab)->F5V_VALUE)}})
            (cTab)->(DBSkip())
        EndDo

        (cTab)->(DBCloseArea())
        RestArea(aArea)

Return (aLines)

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06D0804_DefVirtViewF5V

View structure for virtual grid - F5V table
F5V_FILAL=F5N_FILIAL and F5V_FRMCOD=F5N_FRMCOD

@param       
@return      Object oStruct
@example     
@author      astepanov
@since       January/09/2019
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Function RU06D0804_DefVirtViewF5V()

    Local oStruct  As Object
    Local aArea    As Array

    aArea       :=  GetArea()
    oStruct 	:= 	FWFormViewStruct():New()
    
    //                  ID      Order           Titulo       Descrip     Help Type    Pict                           bPictVar LookUp CanCh  Ider cGroup Combo MxC,IniBrw,lVirt
    oStruct:AddField("V_SECTN"	,"01",RetTitle("F5V_SECTN")	,X3Descric(),Nil ,"C"	,PesqPict("F5V","F5V_SECTN") 	,Nil ,''	,   .F.	  ,''	,''		,STRTOKARR(X3Cbox(RetTitle("F5U_SECTN")),";"),0,'',.F.) // Section type
    oStruct:AddField("V_TAGSEQ"	,"02",RetTitle("F5V_TAGSEQ"),X3Descric(),Nil ,"N"	,PesqPict("F5V","F5V_TAGSEQ")	,Nil ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.) // Order
    oStruct:AddField("V_TAGDES"	,"03",RetTitle("F5V_TAGDES"),X3Descric(),Nil ,"C"	,PesqPict("F5V","F5V_TAGDES")	,Nil ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.) // Tag description
    oStruct:AddField("V_TAG"	,"04",RetTitle("F5V_TAG")	,X3Descric(),Nil ,"C"	,PesqPict("F5V","F5V_TAG")	    ,Nil ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.) // Tag
    oStruct:AddField("V_TAGTYP"	,"05",RetTitle("F5V_TAGTYP"),X3Descric(),Nil ,"C"	,PesqPict("F5V","F5V_TAGTYP")	,Nil ,''	,   .F.	  ,''	,''		,STRTOKARR(X3Cbox(),";"),0,''  ,.F.) // Tag type
    oStruct:AddField("V_VALUE"	,"06",RetTitle("F5V_VALUE")	,X3Descric(),Nil ,"C"	,PesqPict("F5V","F5V_VALUE")    ,Nil ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.) // Value
    oStruct:AddField("V_VALDES"	,"07",RetTitle("F5V_VALDES"),X3Descric(),Nil ,"C"	,PesqPict("F5V","F5V_VALDES")    ,Nil ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.) // Value Description

    RestArea(aArea)

Return (oStruct)

/*/{Protheus.doc} RU06D08006_SQFilter()
Filter for Standard Query (SXB).
Offers values from Generic Tables (SX5), 
accodring to Exchange Type (F5N_FRMTYP) and Section Type (F5V_SECTN)
@author Konstantin Cherchik
@since 16/10/2019
@version P12.1.25
@type function
/*/
Function RU06D08006_SQFilter(cFormatType as Character, cSectionType as Character)

    Local cGenericTable  as Character
    Local cProcName      as Character
    Local cTypeExport    as Character
    Local cTypeImport    as Character
    Local cSectionHeader as Character
    Local cSectionPO     as Character

    cTypeExport    := "1" // Format Type (F5N_FRMTYP Combo - box)
    cTypeImport    := "2" // Format Type (F5N_FRMTYP Combo - box)
    cSectionHeader := "1" // Section Type (F5V_SECTN Combo - box)
    cSectionPO     := "3" // Section Type (F5V_SECTN Combo - box)
    cGenericTable  := ""
    cProcName      := ProcName()
    
    If !EMPTY(AllTrim(cFormatType)) .And. !EMPTY(AllTrim(cSectionType))
        Do Case
            Case cFormatType == cTypeExport .And. cSectionType == cSectionHeader
                cGenericTable := 'E0'
            Case cFormatType == cTypeExport .And. cSectionType == cSectionPO
                cGenericTable := 'E9'
            Case cFormatType == cTypeImport .And. cSectionType == cSectionHeader
                cGenericTable := 'IH'
            Case cFormatType == cTypeImport .And. cSectionType == cSectionPO
                cGenericTable := 'IP'
            Otherwise 
                cGenericTable := ''
        EndCase
    Else
        Help("",1,cProcName,,STR0031,1,0)
    EndIf
Return cGenericTable

/*/{Protheus.doc} RU06D08007_ValDescr()
Returns description of F5V_VALUE from SX5
@author Konstantin Cherchik
@since 16/10/2019
@version P12.1.25
@type function
/*/
Function RU06D08007_ValDescr(cFormatValue as Character)

    Local cRet          as Character
    Local cGenericTable as Character 

    cRet := ""

    If !EMPTY(Alltrim(cFormatValue))
        Do Case
            Case SubStr(cFormatValue,1,2) == "EH"
                cGenericTable := "E0"
            Case SubStr(cFormatValue,1,2) == "EP" 
                cGenericTable := "E9"
            Case SubStr(cFormatValue,1,2) == "IH"
                cGenericTable := "IH"
            Case SubStr(cFormatValue,1,2) == "IP"
                cGenericTable := "IP"
            Otherwise
                cGenericTable := ''
        EndCase

        If SX5->(dbSeek(xFilial("SX5") + cGenericTable + AllTrim(cFormatValue)))
    	    cRet := AllTrim(SX5->(X5DESCRI()))
        Endif
    EndIf

Return cRet