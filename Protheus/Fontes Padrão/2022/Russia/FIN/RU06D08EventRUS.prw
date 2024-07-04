#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RU06D08.CH"

Class RU06D08EventRUS From FwModelEvent 
    Data oFormatValues
    Data cTypeExport
    Data cTypeImport
    Data cSectionHeader
    Data cSectionPO
    Data cExportCode
    Data cImportCode

	Method New() CONSTRUCTOR
    Method ModelPosVld()
    Method GridLinePreVld()
    Method FieldPreVld()
    Method GridLinePosVld()
    Method Activate()
    Method GetGenericTables()
    Method GetFormatValues()
    Method ValidFormatValues()

EndClass

Method New() Class RU06D08EventRUS
    Self:oFormatValues  := THashMap():New()
    Self:cTypeExport    := "1" // Format Type (F5N_FRMTYP Combo - box)
    Self:cTypeImport    := "2" // Format Type (F5N_FRMTYP Combo - box)
    Self:cSectionHeader := "1" // Section Type (F5V_SECTN Combo - box)
    Self:cSectionPO     := "3" // Section Type (F5V_SECTN Combo - box)
    Self:cExportCode    := "E" // Export code
    Self:cImportCode    := "I" // Import code
Return (Nil)

Method Activate(oModel, lCopy) Class RU06D08EventRUS
    
    Local nI        As Numeric
    Local nJ        As Numeric
    Local oModelHdr As Object
    Local oModelF5U As Object
    Local oModelF5V As Object
    Local oModelVrt As Object
    
    oModelHdr := oModel:GetModel("RU06D08_MHEAD")
    oModelF5U := oModel:GetModel("RU06D08_MSECTIONS")
    oModelF5V := oModel:GetModel("RU06D08_MTAGS") 
    oModelVrt := oModel:GetModel("RU06D08_MALLTAGS")
    Self:GetFormatValues()

    Do Case
        Case oModelHdr:GetOperation() == 3 //copy operation
            For nI := 1 To oModelF5U:Length()
                oModelF5U:GoLine(nI)
                oModelF5U:SetValue("F5U_FRMCOD", "")
            Next nI
            For nI := 1 To oModelF5U:Length()
                oModelF5U:GoLine(nI)
                For nJ :=1 To oModelF5V:Length()
                    oModelF5V:GoLine(nJ)
                    If oModelVrt:SeekLine({{"V_FRMCOD",oModelF5V:GetValue("F5V_FRMCOD")},;
                                           {"V_SECTN" ,oModelF5V:GetValue("F5V_SECTN" )},;
                                           {"V_TAGSEQ",oModelF5V:GetValue("F5V_TAGSEQ")}},.F.,.T.)
                        oModelVrt:LoadValue("V_TAGDES",oModelF5V:GetValue("F5V_TAGDES"))
                        oModelVrt:LoadValue("V_TAG"   ,oModelF5V:GetValue("F5V_TAG"   ))
                        oModelVrt:LoadValue("V_TAGTYP",oModelF5V:GetValue("F5V_TAGTYP"))
                        oModelVrt:LoadValue("V_VALUE" ,oModelF5V:GetValue("F5V_VALUE" ))
                    EndIf
                Next nJ
            Next nI
    EndCase

Return (Nil)

Method ModelPosVld(oModel, cModelID) Class RU06D08EventRUS
    
    Local lRet           As Logical
    Local lFlag          As Logical
    Local oModelHdr      As Object
    Local oModelF5U      As Object
    Local oModelF5V      As Object
    Local oModelMallTags As Object
    Local nI             As Numeric
    Local nJ             As Numeric
    Local nX             As Numeric
    Local cFormatValue   As Character
    Local cFormatType    As Character
    Local cProcName      As Character

    lRet      := .T.
    lFlag     := .T.
    cProcName := ProcName()
    
    oModelHdr      := oModel:GetModel("RU06D08_MHEAD")
    oModelF5U      := oModel:GetModel("RU06D08_MSECTIONS")
    oModelF5V      := oModel:GetModel("RU06D08_MTAGS")
    oModelMallTags := oModel:GetModel("RU06D08_MALLTAGS")
    cFormatType    := oModelHdr:GetValue("F5N_FRMTYP")

    For nI := 1 To oModelF5U:Length()
        oModelF5U:GoLine(nI)
        If oModelF5U:IsDeleted()
            For nJ := 1 To oModelF5V:Length()
                oModelF5V:GoLine(nJ)
                If ! oModelF5V:IsDeleted() //deleted section contains undeleted tags
                    Help("",1,STR0009,,STR0010,;
                        1,0,,,,,,{STR0011+" -> ",STR0012})
                    lRet := .F.
                    Exit
                EndIf
            Next nJ
        EndIf
    Next nI
    Do Case
        Case lRet .AND. (oModelHdr:GetOperation() != 4 .AND. oModelHdr:GetOperation() != 5); //duplicate F5N_FRMCOD
            .AND. !(RU06D08F3_SearchDuplicateFRMCOD(oModelHdr:GetValue("F5N_FRMCOD")))
            Help("",1,STR0013,,STR0014,;
                 1,0,,,,,,{STR0015})
            lRet := .F.
    EndCase
    For nX := 1 to oModelMallTags:Length()
        oModelMallTags:GoLine(nX)
        cFormatValue := SubStr(oModelMallTags:GetValue("V_VALUE"),1,1)
        If !EMPTY(AllTrim(cFormatValue)) .And. !(oModelMallTags:IsDeleted(nX)) .And. ((cFormatType == Self:cTypeExport .And.  cFormatValue != Self:cExportCode) .Or. (cFormatType == Self:cTypeImport .And. cFormatValue != Self:cImportCode))
            lFlag := .F. 
        EndIf
    Next nX 
    If !lFlag
        Help("",1,cProcName,,STR0032,1,0)
        lRet := .F.
    EndIf 

Return (lRet)


Method FieldPreVld(oSubModel, cModelId, cAction, cID, xNewValue) Class RU06D08EventRUS

    Local lRet            As Logical
    Local oModel          As Object
    Local oModelF5U       As Object
    Local oModelMallTags  As Object
    Local cValue          As Character
    Local cProcName       As Character
    Local nX              As Numeric

    lRet      := .T.
    cProcName := ProcName()

    oModel     := oSubModel:GetModel()
    oModelF5U  := oModel:GetModel("RU06D08_MSECTIONS") 

    Do Case
        Case cModelID == "RU06D08_MHEAD"     .AND. cAction == "SETVALUE" .AND. cID == "F5N_FRMCOD"
            If AllTrim(xNewValue) != "" .AND. !(RU06D08F2_CheckAlphaNumeric(RTrim(xNewValue)))
                Help("",1,STR0014,,STR0014,; //incorrect F5N_FRMCOD
                    1,0,,,,,,{STR0015,STR0016})
                lRet := .F.
            Else 
                RU06D08E5_SetValue(oModelF5U,"F5U_FRMCOD",AllTrim(xNewValue))
            EndIf
        Case cModelID == "RU06D08_MHEAD" .And. cAction == "SETVALUE" .And. cID == "F5N_FRMTYP"
            oModelMallTags := oModel:GetModel("RU06D08_MALLTAGS")
            For nX := 1 to oModelMallTags:Length()
                oModelMallTags:GoLine(nX)
                cValue := SubStr(oModelMallTags:GetValue("V_VALUE"),1,1)
                If !EMPTY(AllTrim(cValue)) .And. !(oModelMallTags:IsDeleted(nX)) .And. ((xNewValue == Self:cTypeExport .And.  cValue != Self:cExportCode) .Or. (xNewValue == Self:cTypeImport .And. cValue != Self:cImportCode))
                    lRet := .F. 
                EndIf
            Next nX 
            If !lRet
                Help("",1,cProcName,,STR0032,1,0)
            EndIf 
    EndCase
            
Return (lRet)

Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xNewValue, xCurrentValue)  Class RU06D08EventRUS

    Local lRet      As Logical
    Local oModel    As Object
    Local oModelF5N As Object
    Local oModelF5U As Object
    Local oModelF5V As Object
    Local oModelVrt As Object
    Local nChkTagSq As Numeric

    lRet   := .T.

    oModel    := oSubModel:GetModel()
    oModelF5N := oModel:GetModel("RU06D08_MHEAD")
    oModelF5U := oModel:GetModel("RU06D08_MSECTIONS")
    oModelF5V := oModel:GetModel("RU06D08_MTAGS") 
    oModelVrt := oModel:GetModel("RU06D08_MALLTAGS")

    Do Case
        /* RU06D08_MSECTIONS ACTIONS----------------------------------------------------------------*/
        Case cModelID == "RU06D08_MSECTIONS" .AND. cAction == "SETVALUE"    .AND. cID == "F5U_SECTN" ;
            .AND. xNewValue != xCurrentValue
            lRet := ! (RU06D08E3_CheckF5U_SECTN(oModelF5U,xNewValue)) 
            If !(lRet) //F5U_SECTN value already exist
                Help("",1,STR0017,,STR0018,;
                     1,0,,,,,,{STR0019})
            Else      //new F5U_SECTN value
                If xNewValue == "1" .OR. xNewValue == "2" // according to specification if F5U_SECTN
                    oModelF5U:SetValue("F5U_VALUE","")    // is equal '1' or '2' F5U_VALUE must be ''
                EndIf
                RU06D08E5_SetValue(oModelF5V,"F5V_SECTN" ,xNewValue)
            EndIf
        Case cModelID == "RU06D08_MSECTIONS" .AND. cAction == "SETVALUE"    .AND. cID == "F5U_FRMCOD";
            .AND. AllTrim(xNewValue) != AllTrim(xCurrentValue)
            RU06D08E5_SetValue(oModelF5V,"F5V_FRMCOD",AllTrim(xNewValue))
        Case cModelID == "RU06D08_MSECTIONS" .AND. cAction == "DELETE"
            RU06D08E6_DeltLine(oModelF5V)
        Case cModelID == "RU06D08_MSECTIONS" .AND. cAction == "UNDELETE"
            RU06D08E7_UndeLine(oModelF5V)
        Case cModelID == "RU06D08_MSECTIONS" .AND. cAction == "CANSETVALUE" .AND. cID == "F5U_VALUE" ;
            .AND. (oModelF5U:GetValue("F5U_SECTN") == "1" .OR. oModelF5U:GetValue("F5U_SECTN") == "2")
            lRet := .F.
        /*----------------------------------------------------------------RU06D08_MSECTIONS ACTIONS */
        /* RU06D08_MTAGS ACTIONS--------------------------------------------------------------------*/
        Case cModelID == "RU06D08_MTAGS"     .AND. cAction == "CANSETVALUE" .AND. oModelF5U:IsDeleted()
            lRet := .F.
        Case cModelID == "RU06D08_MTAGS"     .AND. cAction == "SETVALUE"
            Do Case
                Case cID == "F5V_TAGSEQ" .AND. xNewValue != xCurrentValue
                    nChkTagSq := RU06D08E4_CheckTagseqField(oModelF5V,xNewValue)
                    Do Case
                        Case nChkTagSq ==  0 // tagseq is ok
                            RU06D08E8_AddVrtVl(oModelF5V,oModelVrt,"TAGSEQ",xNewValue)
                        Case nChkTagSq == -1 // negative tagseq
                            Help("",1,STR0020,,STR0021,;
                                 1,0,,,,,,{STR0022})
                            lRet := .F.
                        Case nChkTagSq ==  1 // tagseq already exist
                            Help("",1,STR0020,,STR0023,;
                                 1,0,,,,,,{STR0022})
                            lRet := .F.
                    EndCase
                Case !(cID $ "F5V_TAGSEQ|F5V_VALUE") .AND. AllTrim(xNewValue) != AllTrim(xCurrentValue)
                    RU06D08E8_AddVrtVl(oModelF5V,oModelVrt,SubStr(cID,5),AllTrim(xNewValue))
                Case cID $ "F5V_VALUE" .AND. AllTrim(xNewValue) != AllTrim(xCurrentValue)
                    lRet := Self:ValidFormatValues(oModelF5N,oModelF5V,xNewValue)
                    If lRet
                        RU06D08E8_AddVrtVl(oModelF5V,oModelVrt,SubStr(cID,5),AllTrim(xNewValue))
                    EndIf
            EndCase
        Case cModelID == "RU06D08_MTAGS"     .AND. cAction == "DELETE"
            oModelVrt:SetNoDeleteLine(.F.)
            RU06D08E9_CheckVrt(.F.,oModelF5V,oModelVrt)
            oModelVrt:SetNoDeleteLine(.T.)
        Case cModelID == "RU06D08_MTAGS"     .AND. cAction == "UNDELETE"
            RU06D08E9_CheckVrt(.T.,oModelF5V,oModelVrt)
        /*--------------------------------------------------------------------RU06D08_MTAGS ACTIONS */
    EndCase

Return (lRet)

Method GridLinePosVld(oSubModel, cModelID, nLine)  Class RU06D08EventRUS

    Local lRet      As Logical
    Local oModel    As Object
    Local oModelHdr As Object
    Local oModelF5U As Object
    Local oModelF5V As Object
    Local cString   As Character
    Local cAllTrS   As Character
    Local aFldF5U   As Array
    Local aFldF5V   As Array
    Local nI        As Numeric

    lRet      := .T.
    aFldF5U   := {"F5U_TGBGN" ,"F5U_TGEND","F5U_VALUE"}
    aFldF5V   := {"F5V_TAGDES","F5V_TAG"  ,"F5V_VALUE"}

    oModel    := oSubModel:GetModel()
    oModelHdr := oModel:GetModel("RU06D08_MHEAD")
    oModelF5U := oModel:GetModel("RU06D08_MSECTIONS")
    oModelF5V := oModel:GetModel("RU06D08_MTAGS") 

    Do Case
        Case cModelID == "RU06D08_MSECTIONS" .AND. !oModelF5U:IsDeleted()
            oModelF5U:SetValue("F5U_FRMCOD",oModelHdr:GetValue("F5N_FRMCOD"))
            For nI := 1 To Len(aFldF5U)
                cString := oModelF5U:GetValue(aFldF5U[nI])
                cAllTrS := AllTrim(cString)
                If cAllTrS != "" .AND. SubStr(cString,1,1) == " "
                    oModelF5U:SetValue(aFldF5U[nI], cAllTrS)
                EndIf
            Next nI
        
        Case cModelID == "RU06D08_MTAGS"     .AND. !oModelF5V:IsDeleted()
            oModelF5V:SetValue("F5V_FRMCOD",oModelHdr:GetValue("F5N_FRMCOD"))
            oModelF5V:SetValue("F5V_SECTN" ,oModelF5U:GetValue("F5U_SECTN" ))
            For nI := 1 To Len(aFldF5V)
                cString := oModelF5V:GetValue(aFldF5V[nI])
                cAllTrS := AllTrim(cString)
                If cAllTrS != "" .AND. SubStr(cString,1,1) == " "
                    oModelF5V:SetValue(aFldF5V[nI], cAllTrS)
                EndIf
            Next nI
    EndCase

Return (lRet)

Method GetGenericTables(aGenericTables) Class RU06D08EventRUS

    Local cQuery as Character
    Local nX     as Numeric
    Local nFirst as Numeric

    nfirst := 1

    cQuery := " SELECT * FROM " + RetSQLName("SX5")
    cQuery += " WHERE X5_FILIAL = '" + xFilial("SX5") +"'"
    cQuery += " AND X5_TABELA IN ('"
        For nX := 1 to Len(aGenericTables)
            If (nFirst == 1)
                nFirst := 0
            Else
                cQuery += "' , '"
            EndIf
            cQuery += aGenericTables[nX]
        Next nX
    cQuery += "') AND D_E_L_E_T_ = ' ' "

Return cQuery

Method GetFormatValues() Class RU06D08EventRUS

    Local aGenericTables as Array
    Local cTable        as Character
    Local lRet          as Logical

    lRet          := .T.
    aGenericTables := {"E0","E9","IH","IP"} /* Export Header, Export PO, Import Header, Import PO */
    cTable        := RU01GETALS(Self:GetGenericTables(aGenericTables))

    While ((cTable)->(!EOF()))
        lRet := lRet .And. HMSet(Self:oFormatValues,AllTrim((cTable)->X5_CHAVE),AllTrim((cTable)->X5_TABELA))
        (cTable)->(DbSkip())
    EndDo

Return lRet

Method ValidFormatValues(oModelF5N,oModelF5V,cValue) Class RU06D08EventRUS

    Local lRet as Logical
    Local aRet as Array
    Local cFormatType as Character
    Local cSectionType as Character
    Local cProcName as Character

    lRet := .T.
    aRet := {}
    cProcName := ProcName()
    cFormatType := oModelF5N:GetValue("F5N_FRMTYP")
    cSectionType := oModelF5V:GetValue("F5V_SECTN")

    If ValType(cValue) == "C" .And. !EMPTY(AllTrim(cValue))
        lRet := HMGet(Self:oFormatValues,AllTrim(cValue),@aRet)
        If lRet
            Do Case
               Case aRet == "E0"
                    If cFormatType != Self:cTypeExport .Or. cSectionType != Self:cSectionHeader
                        Help("",1,cProcName,,STR0033,1,0)
                        lRet := .F.
                    EndIf
                Case aRet == "E9"
                    If cFormatType != Self:cTypeExport .Or. cSectionType != Self:cSectionPO
                        Help("",1,cProcName,,STR0034,1,0)
                        lRet := .F.
                    EndIf
                Case aRet == "IH"
                    If cFormatType != Self:cTypeImport .Or. cSectionType != Self:cSectionHeader
                        Help("",1,cProcName,,STR0035,1,0)
                        lRet := .F.
                    EndIf
                Case aRet == "IP"
                    If cFormatType != Self:cTypeImport .Or. cSectionType != Self:cSectionPO
                        Help("",1,cProcName,,STR0036,1,0)
                        lRet := .F.
                    EndIf
            EndCase
        Else
            Help("",1,cProcName,,STR0037,1,0)
        EndIf
    EndIf

Return lRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06D08E3_CheckF5U_SECTN

It seeks F5U_SECTN field value (xNewValue) duplication
It returns .T. - if it found duplicate
           .F. - if there is no duplicates

@param       Object    oModelF5U
             Variant   xNewValue
@return      Logical   lRet
@example     
@author      astepanov
@since       January/23/2019
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Function RU06D08E3_CheckF5U_SECTN(oModelF5U,xNewValue)

    Local lFnd As Logical

    lFnd := oModelF5U:SeekLine({{"F5U_SECTN",xNewValue}},.T.,.F.)

Return (lFnd)

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06D08E4_CheckTagseqField

    nRet =  0 // Checked!
    nRet = -1 // New value is negative number or 0
    nRet =  1 // New value already exist

@param       Object    oModelF5V
             Variant   xNewValue
@return      Numeric   nRet
@example     
@author      astepanov
@since       January/23/2019
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Function RU06D08E4_CheckTagseqField(oModelF5V,xNewValue)
    
    Local nRet As Numeric
    nRet  := 0

    Do Case
        Case  xNewValue <= 0
                nRet := -1
        Case  xNewValue >  0
            If oModelF5V:SeekLine({{"F5V_TAGSEQ",xNewValue}},.T.,.F.)
                nRet :=  1
            EndIf
    EndCase

Return (nRet)

Function RU06D08E5_SetValue(oModel,cID,xNewValue)

    Local lRet As Logical
    Local nI   As Numeric
    lRet  := .T.

    For nI := 1 To oModel:Length()
        oModel:GoLine(nI)
        oModel:SetValue(cID,xNewValue) 
    Next

Return (lRet)

Function RU06D08E6_DeltLine(oModel)

    Local lRet As Logical
    Local nI   As Numeric
    lRet  := .T.

    For nI := 1 To oModel:Length()
        oModel:GoLine(nI)
        oModel:DeleteLine()
    Next  

Return (lRet)

Function RU06D08E7_UndeLine(oModel)

    Local lRet As Logical
    Local nI   As Numeric
    lRet  := .T.

    For nI := 1 To oModel:Length()
        oModel:GoLine(nI)
        oModel:UnDeleteLine()
    Next  

Return (lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06D08E8_AddVrtVl

It seeks line in oModelVrt. If it found - data will 
be changed to xNewValue. If it not - will be added new line

@param       Object      oModelF5V
             Object      oModelVrt
             Character   cFldPostfix (exmpl: "VALUE", "TAG")
             Variant     xNewValue
@return      Logical lRet
@example     
@author      astepanov
@since       January/23/2019
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Function RU06D08E8_AddVrtVl(oModelF5V,oModelVrt,cFldPostfix,xNewValue)

    Local lRet As Logical
    Local lFnd As Logical
    Local nLen As Numeric

    lRet := .T.

    lFnd := oModelVrt:SeekLine({{"V_FRMCOD",oModelF5V:GetValue("F5V_FRMCOD")},;
                                {"V_SECTN" ,oModelF5V:GetValue("F5V_SECTN" )},;
                                {"V_TAGSEQ",oModelF5V:GetValue("F5V_TAGSEQ")}},.F.,.T.)
    If lFnd
        oModelVrt:LoadValue("V_"+cFldPostfix,xNewValue)
    Else
        nLen := oModelVrt:Length()
        If nLen < oModelVrt:AddLine()
            oModelVrt:LoadValue("V_FRMCOD",oModelF5V:GetValue("F5V_FRMCOD"))
            oModelVrt:LoadValue("V_SECTN" ,oModelF5V:GetValue("F5V_SECTN" ))
            oModelVrt:LoadValue("V_TAGSEQ",oModelF5V:GetValue("F5V_TAGSEQ"))
            oModelVrt:LoadValue("V_"+cFldPostfix,xNewValue)   
        Else
            lRet := .F.
        EndIf
    EndIf

Return (lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06D08E9_CheckVrt

Function receievs oModelF5V and oModelVrt. It bypass oModelF5V
lines and check oModelVrt lines. If it found deleted line in oMmodelF5V
and related line in oModelVrt is undeleted, it deletes line in oModelVrt
and vice versa

@param       Logical lDelUndel .T. - Undelete deleted lines
                               .F. - Delete undeleted lines
             Object  oModelF5V
             Object  oModelVrt
@return      Logical lRet
@example     
@author      astepanov
@since       January/23/2019
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Function RU06D08E9_CheckVrt(lDelUndel,oModelF5V,oModelVrt)

    Local lRet As Logical
    Local lFnd As Logical

    lRet := .T.

    lFnd := oModelVrt:SeekLine({{"V_FRMCOD",oModelF5V:GetValue("F5V_FRMCOD")},;
                                {"V_SECTN" ,oModelF5V:GetValue("F5V_SECTN" )},;
                                {"V_TAGSEQ",oModelF5V:GetValue("F5V_TAGSEQ")}},.T.,.T.)
    
    Do Case
        Case lDelUndel  .AND. lFnd
            oModelVrt:UndeleteLine()
        Case !lDelUndel .AND. lFnd
            oModelVrt:DeleteLine()
    EndCase
 
Return (lRet)

/*/{Protheus.doc} RU06D08E11_FormatValues
Query to select values from SX5 (Generic tables)
@author Konstantin Cherchik
@since 10/01/2019
@version P12.1.25
@type function
/*/
Function RU06D08E11_FormatValues()
Local cQuery            as Character
Local cImportHeader     as Character
Local cImportDetails    as Character
Local cExportHeader     as Character
Local cExportDetails    as Character

cImportHeader   := "IH" //Tabela in SX5, Values for Import Header
cImportDetails  := "IP" //Tabela in SX5, Values for Import Details
cExportHeader   := "E0" //Tabela in SX5, Values for Export Header
cExportDetails  := "E9" //Tabela in SX5, Values for Export Details

cQuery := " SELECT * FROM " + RetSQLName("SX5")
cQuery += " WHERE X5_FILIAL = '" + xFilial("SX5") +"'"
cQuery += " AND X5_TABELA IN ("
cQuery += "'" + cImportHeader + "',"
cQuery += "'" + cImportDetails + "',"
cQuery += "'" + cExportHeader + "',"
cQuery += "'" + cExportDetails + "'"
cQuery += ") AND D_E_L_E_T_ = ' ' "

Return cQuery

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06D08F2_CheckAlphaNumeric

This function recieves the string and checks for
alphabetical symbols a-z, A-Z and numbers 0-9. If other symbol exist
it returns False, otherwise it returns True. Also it returns False if
entered string cString is empty. So it could be used when we want to
prevent any symbols in the string except latin letters and numbers.

@param       CHARACTER cString
@return      Logical   lRet
@example     
@author      astepanov
@since       December/25/2018
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Function RU06D08F2_CheckAlphaNumeric(cString)

    Local lRet As Logical
    Local nI   As Numeric
    Local cCh  As Character

    lRet  :=  .T.

    If Len(cString) > 0
        For nI := 1 To Len(cString)
            cCh := SubStr(cString,nI,1)
            If ! (isAlpha(cCh) .OR. isDigit(cCh))
                lRet := .F.
                Exit
            EndIf
        Next nI
    Else
        lRet := .F.
    Endif

Return (lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06D08F3_SearchDuplicateFRMCOD

Function recieves future F5N_FRMCOD field value and seeks
duplicate in F5N table. It returns .T. if there is no duplicates, .F. - if
it found duplicate

@param       Variant xNewValue
@return      Logical lRet
@example     
@author      astepanov
@since       January/23/2019
@version     1.0
@project     MA3
@see         None
/*/
//-----------------------------------------------------------------------
Function RU06D08F3_SearchDuplicateFRMCOD(xNewValue)

    Local lRet    As Logical 
    Local cQuery  As Character
    Local cTab    As Character
    Local aArea   As Array

    lRet  := .T.
    aArea := GetArea()

    cQuery    := " SELECT * FROM " + RetSQLName("F5N")  + " F5N "
    cQuery    += " WHERE F5N_FILIAL ='" + xFilial("F5N") +"'"
    cQuery    += " AND F5N_FRMCOD ='" + xNewValue +"'"
    cQuery    += " AND F5N.D_E_L_E_T_ =' '"

    cQuery    := ChangeQuery(cQuery)
    cTab      := CriaTrab( ,.F.)
    TcQuery cQuery New Alias ((cTab))

    DbSelectArea((cTab))
    If (cTab)->(!EOF()) //non-empty request result
        lRet := .F.
    EndIf
    (cTab)->(DBCloseArea())
    RestArea(aArea)

Return (lRet)

