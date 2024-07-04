#include 'protheus.ch'
#include 'parmtype.ch'

#DEFINE USERPASS "71a23c51-a247-4315-be23-400a4fbca6f3:1_zgX76ildIXBCHLYLLG7V9gBSx"

/**
Teste para a classe SmartCat
 */
User Function F0101101()

    Private oSCData := JsonObject():New()

    SetTestBlock()

    oSCData['object'] := SmartCat():New(Encode64(USERPASS), "https://smartcat.ai/api/integration/v1")

    Begin Sequence
        TConstructor()    // OK
        TLogin()          // OK
        TProjectList()    // OK
        TProjectID()      // OK
        TGetStats()       // OK
        TGetModel()       // OK
        TUpload()         // OK
        TDocumentExist()  // OK
        TGetDownloadID()  // OK
        TDownloadDoc()    // OK
        TUpdate()         // OK
        TGetTMList()      // OK
        TDownloadTM()     // OK
        TUpdateTM()       // OK
        TGetStatusCode()  // OK
        TGetLastError()   // OK
    End Sequence

    ResetBlock()

Return

Static Function TConstructor()

    Local oSmartCat := oSCData['object']

    AssertType(oSmartCat        , "O", "Invalid Object")
    AssertType(oSmartCat:aHeader, "A", "Ivalid Header")
    AssertType(oSmartCat:oRest  , "O", "Invalid Class")

    ConOut(FwTimeStamp(2) + " - " + PadR(ProcName(), 15) + " - OK")

Return

Static Function TLogin()

    Local oSmartCat    := oSCData['object']
    Local cLoginBase64 := Encode64(USERPASS)

    lOK := oSmartCat:SetLogin(cLoginBase64)

    Assert( oSmartCat:cLoginBase64, cLoginBase64, "Login Error")

    ConOut(FwTimeStamp(2) + " - " + PadR(ProcName(), 15) + " - OK")

Return


Static Function TProjectList()

    Local oSmartCat := oSCData['object']

    lOK   := oSmartCat:GetProjectList()
    Assert(lOK, .T., "GetProjectList Failed")

    oList := oSmartCat:GetObjResult()

    AssertType(oList, "A", "Invalid List")

    If Len(oList) >= 1
        AssertType(oList[1]:CREATIONDATE          , "C", "Invalid List")
        AssertType(oList[1]:DEADLINE              , "C", "Invalid List")
        AssertType(oList[1]:DESCRIPTION           , "C", "Invalid List")
        AssertType(oList[1]:DOCUMENTS             , "A", "Invalid List")
        AssertType(oList[1]:ID                    , "C", "Invalid List")
        AssertType(oList[1]:MODIFICATIONDATE      , "C", "Invalid List")
        AssertType(oList[1]:NAME                  , "C", "Invalid List")
        AssertType(oList[1]:SOURCELANGUAGE        , "C", "Invalid List")
        AssertType(oList[1]:STATUS                , "C", "Invalid List")
        AssertType(oList[1]:STATUSMODIFICATIONDATE, "C", "Invalid List")
        AssertType(oList[1]:TARGETLANGUAGES       , "A", "Invalid List")
        AssertType(oList[1]:WORKFLOWSTAGES        , "A", "Invalid List")
    EndIf

    ConOut(FwTimeStamp(2) + " - " + PadR(ProcName(), 15) + " - OK")

    oSCData['list'] := oList

Return

Static Function TProjectID()

    Local oSmartCat    := oSCData['object']
    Local cProjectId   := oSCData['list'][1]:ID

    oSmartCat:SetProjectID(cProjectId)

    Assert( oSmartCat:cProjectId, cProjectId, "ProjectID Error")

    ConOut(FwTimeStamp(2) + " - " + PadR(ProcName(), 15) + " - OK")

Return

Static Function TGetStats()

    Local oSmartCat := oSCData['object']

    lOk := oSmartCat:GetProjectStats()
    Assert(lOK, .T., "GetProjectStats Failed")

    oStats := oSmartCat:GetObjResult()

    AssertType(oStats            , "O", "Invalid Stats")
    AssertType(oStats:DOCUMENTIDS, "A", "Invalid Document List")

    If Len(oStats:DOCUMENTIDS) >= 1
        AssertType(oStats:DOCUMENTIDS[1], "N", "Invalid Document ID")
    EndIf

    ConOut(FwTimeStamp(2) + " - " + PadR(ProcName(), 15) + " - OK")

     oSCData['stats'] := oStats

Return

Static Function TGetModel()

    Local oSmartCat := oSCData['object']

    lOk := oSmartCat:GetProjectModel()
    Assert(lOK, .T., "GetProjectModel Failed")

    oModel := oSmartCat:GetObjResult()

    AssertType(oModel            , "O", "Invalid Model")

    AssertType(oModel:CREATIONDATE          , "C", "Invalid Model")
    AssertType(oModel:DEADLINE              , "C", "Invalid Model")
    AssertType(oModel:DESCRIPTION           , "C", "Invalid Model")
    AssertType(oModel:DOCUMENTS             , "A", "Invalid Model")
    AssertType(oModel:ID                    , "C", "Invalid Model")
    AssertType(oModel:MODIFICATIONDATE      , "C", "Invalid Model")
    AssertType(oModel:NAME                  , "C", "Invalid Model")
    AssertType(oModel:SOURCELANGUAGE        , "C", "Invalid Model")
    AssertType(oModel:STATUS                , "C", "Invalid Model")
    AssertType(oModel:STATUSMODIFICATIONDATE, "C", "Invalid Model")
    AssertType(oModel:TARGETLANGUAGES       , "A", "Invalid Model")
    AssertType(oModel:WORKFLOWSTAGES        , "A", "Invalid Model")

    ConOut(FwTimeStamp(2) + " - " + PadR(ProcName(), 15) + " - OK")

    oSCData['model'] := oModel

Return

Static Function TUpload()

    Local oSmartCat := oSCData['object']

    cFilePath := "C:\temp\teste" + FwTimeStamp() + ".resx"

    MemoWrite(cFilePath, MemoRead( "C:\temp\teste.resx"))

    lOk := oSmartCat:UploadDoc(cFilePath)
    Assert(lOK, .T., "UploadDoc Failed")

    oDocument := oSmartCat:GetObjResult()

    AssertType(oDocument[1]:Id                         , "C", "Invalid Document")
    AssertType(oDocument[1]:Name                       , "C", "Invalid Document")
    AssertType(oDocument[1]:CreationDate               , "C", "Invalid Document")
    AssertType(oDocument[1]:Deadline                   , "C", "Invalid Document")
    AssertType(oDocument[1]:SourceLanguage             , "C", "Invalid Document")
    AssertType(oDocument[1]:DocumentDisassemblingStatus, "C", "Invalid Document")
    AssertType(oDocument[1]:TargetLanguage             , "C", "Invalid Document")
    AssertType(oDocument[1]:Status                     , "C", "Invalid Document")
    AssertType(oDocument[1]:WordsCount                 , "N", "Invalid Document")
    AssertType(oDocument[1]:StatusModificationDate     , "C", "Invalid Document")
    AssertType(oDocument[1]:PretranslateCompleted      , "L", "Invalid Document")
    AssertType(oDocument[1]:WorkflowStages             , "A", "Invalid Document")
    AssertType(oDocument[1]:ExternalId                 , "C", "Invalid Document")
    AssertType(oDocument[1]:PlaceholdersAreEnabled     , "L", "Invalid Document")


    ConOut(FwTimeStamp(2) + " - " + PadR(ProcName(), 15) + " - OK")

    oSCData['DocumentID'] := oDocument[1]:Id 

Return

Static Function TDocumentExist()

    Local oSmartCat := oSCData['object']

    cDocID := oSCData['DocumentID']

    lRet := oSmartCat:DocumentExists(cDocID)

    Assert(lRet, .T. , "Invalid Document")

    ConOut(FwTimeStamp(2) + " - " + PadR(ProcName(), 15) + " - OK")

Return

Static Function TGetDownloadID()

    Local oSmartCat := oSCData['object']

    oModel := oSCData['model']
    cDocID := oSCData['DocumentID']

    lOk := oSmartCat:GetDownloadID(cDocID)
    Assert(lOK, .T., "GetDownloadID Failed")

    oDownloadID := oSmartCat:GetObjResult()

    AssertType(oDownloadID            , "O", "Invalid DownloadID")
    AssertType(oDownloadID:ID         , "C", "Invalid DownloadID")
    AssertType(oDownloadID:DOCUMENTIDS, "A", "Invalid DownloadID")

    ConOut(FwTimeStamp(2) + " - " + PadR(ProcName(), 15) + " - OK")

    oSCData['downloadID'] := oDownloadID:ID
Return

Static Function TDownloadDoc()

    Local oSmartCat := oSCData['object']
    Local cDownloadID := oSCData['downloadID']

    lOk := oSmartCat:DownloadDoc(cDownloadID)
    Assert(lOK, .T., "DownloadDoc Failed")

    cFile := oSmartCat:GetTxtResult()

    AssertType(cFile         , "C", "Invalid DownloaFile")
    cFilePath := "C:\temp\teste" + FwTimeStamp() + "_download.resx"

    MemoWrite(cFilePath, cFile)

    ConOut(FwTimeStamp(2) + " - " + PadR(ProcName(), 15) + " - OK")

Return

Static Function TUpdate()

    Local oSmartCat := oSCData['object']

    cDocID     := oSCData['DocumentID']

    lOK := oSmartCat:UpdateDoc(cDocID, "C:\temp\teste2.resx")

    Assert(lOK, .T., "UpdateDoc Failed")

    oDocument := oSmartCat:GetObjResult()

    AssertType(oDocument[1]:Id                         , "C", "Invalid Document")
    AssertType(oDocument[1]:Name                       , "C", "Invalid Document")
    AssertType(oDocument[1]:CreationDate               , "C", "Invalid Document")
    AssertType(oDocument[1]:Deadline                   , "C", "Invalid Document")
    AssertType(oDocument[1]:SourceLanguage             , "C", "Invalid Document")
    AssertType(oDocument[1]:DocumentDisassemblingStatus, "C", "Invalid Document")
    AssertType(oDocument[1]:TargetLanguage             , "C", "Invalid Document")
    AssertType(oDocument[1]:Status                     , "C", "Invalid Document")
    AssertType(oDocument[1]:WordsCount                 , "N", "Invalid Document")
    AssertType(oDocument[1]:StatusModificationDate     , "C", "Invalid Document")
    AssertType(oDocument[1]:PretranslateCompleted      , "L", "Invalid Document")
    AssertType(oDocument[1]:WorkflowStages             , "A", "Invalid Document")
    AssertType(oDocument[1]:ExternalId                 , "C", "Invalid Document")
    AssertType(oDocument[1]:PlaceholdersAreEnabled     , "L", "Invalid Document")

    ConOut(FwTimeStamp(2) + " - " + PadR(ProcName(), 15) + " - OK")

Return

Static Function TGetTMList()
    
    Local oSmartCat := oSCData['object']
    
    lOK := oSmartCat:GetTMList()
    
    Assert(lOK, .T., "GetTMList Failed")

    oTMList := oSmartCat:GetObjResult()

    AssertType(oTMList[1]:ACCOUNTID             , "C", "Invalid Translation Memory")
    AssertType(oTMList[1]:CREATEDDATE           , "C", "Invalid Translation Memory")
    AssertType(oTMList[1]:ID                    , "C", "Invalid Translation Memory")
    AssertType(oTMList[1]:ISAUTOMATICALLYCREATED, "L", "Invalid Translation Memory")
    AssertType(oTMList[1]:NAME                  , "C", "Invalid Translation Memory")
    AssertType(oTMList[1]:SOURCELANGUAGE        , "C", "Invalid Translation Memory")
    AssertType(oTMList[1]:TARGETLANGUAGES       , "A", "Invalid Translation Memory")
    AssertType(oTMList[1]:UNITCOUNTBYLANGUAGEID , "O", "Invalid Translation Memory")

    oSCData['TMID'] := oTMList[1]:ID
    
    ConOut(FwTimeStamp(2) + " - " + PadR(ProcName(), 15) + " - OK")

Return

Static Function TDownloadTM()
    
    Local oSmartCat := oSCData['object']
    
    cTMID := oSCData['TMID']

    lOK := oSmartCat:DownloadTM(cTMID)
    
    Assert(lOK, .T., "DownloadTM Failed")

    cFile := oSmartCat:GetTxtResult()

    AssertType(cFile         , "C", "Invalid DownloadTM File")
    cFilePath := "C:\temp\teste" + FwTimeStamp() + "_tm.tmx"
    
    MemoWrite(cFilePath, cFile)

    ConOut(FwTimeStamp(2) + " - " + PadR(ProcName(), 15) + " - OK")

Return

Static Function TUpdateTM()

    Local oSmartCat := oSCData['object']

    cTMID     := oSCData['TMID']

    lOK := oSmartCat:UpdateTM(cTMID, "C:\temp\newfile.tmx")

    Assert(lOK, .T., "UpdateTM Failed")

    ConOut(FwTimeStamp(2) + " - " + PadR(ProcName(), 15) + " - OK")

Return

Static Function TGetLastError()

    Local oSmartCat := oSCData['object']

    cError := oSmartCat:GetLastError()

    AssertType(cError, "C", "Invalid Error")

    ConOut(FwTimeStamp(2) + " - " + PadR(ProcName(), 15) + " - OK")

Return

Static Function TGetStatusCode()

    Local oSmartCat := oSCData['object']

    cStatusCode := oSmartCat:GetStatusCode()

    AssertType(cStatusCode, "C", "Invalid Status Code")

    ConOut(FwTimeStamp(2) + " - " + PadR(ProcName(), 15) + " - OK")

Return


/**
Funções para a suite de testes
 */

Static Function SetTestBlock()

    Local bError := {|oError| CatchError(oError)}

    Static bErrorBkp := {||}

    bErrorBkp := ErrorBlock()

    ErrorBlock(bError)

Return

Static Function ResetBlock()

    ErrorBlock(bErrorBkp)

    bErrorBkp := Nil

Return

Static Function CatchError(oError)

    ConOut(FwTimeStamp(2) + " - " + ProcName(2) + " - Error: " + oError:description)
    Break //__Quit()

Return


Static Function Assert(provided, expected, cMessage, nActivation)

    Default nActivation := 1

    If provided != expected
        ConOut(FwTimeStamp(2) + " - " + ProcName(nActivation) + " - Error: " + cMessage)
        Break
    Endif

Return

Static Function AssertType(provided, expected, cMessage)

    cMessage += ". Provided: '" + ValType(provided) + "' Expected: '" + expected + "'"

Return Assert(ValType(provided), expected, cMessage, 2)
// Russia_R5
