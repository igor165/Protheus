#include 'protheus.ch'
#include 'parmtype.ch'

/**
Login: 71a23c51-a247-4315-be23-400a4fbca6f3
Password: 1_zgX76ildIXBCHLYLLG7V9gBSx

 */
Class SmartCat From LongNameClass

	Data cLoginBase64 As Character
	Data cProjectID   As Character
	Data aHeader      As Array
	Data oRest        As Object

	Method New() Constructor
	Method SetHeader()
	Method SetLogin()
	Method SetProjectID()
	Method SetContentType()

	Method GetProjectList()
	Method GetProjectStats()
	Method GetProjectModel()

	Method DocumentExists()
	Method GetDocumentID()
    Method GetDownloadID()
	Method DownloadDoc()
	
    Method UploadDoc()
	Method UpdateDoc()

	Method GetTMList()
    Method DownloadTM()
	Method UpdateTM()

    Method GetObjResult()
    Method GetTxtResult()
    Method GetLastError()
	Method GetStatusCode()

EndClass

Method New(cLoginBase64, cURLServer) Class SmartCat As Logical

    self:aHeader := {}
    self:oRest   := FWRest():New(cURLServer)

    self:SetLogin(cLoginBase64)

Return .T.

Method SetHeader(cHeader, cContent) Class SmartCat As Logical

    Local nPos As Numeric

    If (nPos := AScan(self:aHeader, {|cItem| cItem = cHeader })) > 0
        self:aHeader[nPos] := cHeader + cContent
    Else
        AAdd(self:aHeader, cHeader + cContent)
    EndIf

Return .T.

Method SetLogin(cLoginBase64) Class SmartCat As Logical

    If Empty(cLoginBase64)
        Return .F.
    EndIf

    self:cLoginBase64 := cLoginBase64
    self:SetHeader("Authorization: Basic ", cLoginBase64)

Return .T.

Method SetProjectID(cProjectID) Class SmartCat As Logical

    self:cProjectID := cProjectID

Return .T.

Method SetContentType(cContent) Class SmartCat As Logical

    If Empty(cContent)
        Return .F.
    EndIf

    self:SetHeader("Content-Type: ", cContent)

Return .T.

Method GetProjectList() Class SmartCat As Logical // /api/integration/v1/project/list

    self:oRest:SetPath("/project/list")

Return self:oRest:Get(self:aHeader)

Method GetProjectStats() Class SmartCat As Logical

    self:oRest:SetPath("/project/" + self:cProjectID + "/statistics")

Return self:oRest:Get(self:aHeader)

Method GetProjectModel() Class SmartCat As Logical// /api/integration/v1/project/list

    self:oRest:SetPath("/project/" + self:cProjectID)

Return self:oRest:Get(self:aHeader)

Method DocumentExists(cDocumentID) Class SmartCat As Logical

    Local oProjectModel As Object

    If !self:GetProjectModel(self:cProjectID)
        Return .F.
    EndIf

    oProjectModel := self:GetObjResult()

Return AScan(oProjectModel:Documents, {|oDocument| oDocument:Id == cDocumentID}) > 0

Method GetDocumentID(cDocumentName) Class SmartCat As Logical

    Local oProjectModel As Object
    Local cDocumentID := ""
    Local nDocument   := 0

    If !self:GetProjectModel(self:cProjectID)
        Return ""
    EndIf

    oProjectModel := self:GetObjResult()

    If (nDocument := AScan(oProjectModel:Documents, {|oDocument| oDocument:Name == cDocumentName})) > 0
        cDocumentID := oProjectModel:Documents[nDocument]:Id
    EndIf

Return cDocumentID


Method GetDownloadID(xDocID) Class SmartCat As Logical

    Local cDocumentId As Character

    If ValType(xDocID) == 'A'
        cDocumentId := FWAToS(xDocID, ',')
    Else
        cDocumentId := xDocID
    EndIf

    self:oRest:SetPath("/document/export?documentIds=" + cDocumentId)

Return self:oRest:Post(self:aHeader)

Method DownloadDoc(cTaskID) Class SmartCat As Logical

    self:oRest:SetPath("/document/export/" + cTaskID)

Return self:oRest:Get(self:aHeader)

Method UploadDoc(cFilePath) Class SmartCat As Logical

    Local cFileContent As Character
    Local cPostParams  As Character
    Local cFileName    As Character
    Local cFileExt     As Character

    self:SetContentType("multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW")

    If !File(cFilePath)
        Return .F.
    EndIf

    cFileContent := MemoRead(cFilePath)
    SplitPath(cFilePath,,,@cFileName,@cFileExt)

    cPostParams := '------WebKitFormBoundary7MA4YWxkTrZu0gW' + CRLF
    cPostParams += 'Content-Disposition: form-data; name="documentModel"; filename="' + cFileName + cFileExt+ '"' + CRLF
    cPostParams += 'Content-Type: application/octetstream' + CRLF
    cPostParams += CRLF + cFileContent + CRLF
    cPostParams += '------WebKitFormBoundary7MA4YWxkTrZu0gW--' + CRLF

    self:oRest:SetPath("/project/document?projectId=" + self:cProjectID)
    self:oRest:SetPostParams(cPostParams)

Return self:oRest:Post(self:aHeader)

Method UpdateDoc(cDocumentId, cFilePath) Class SmartCat As Logical

    Local cFileContent As Character
    Local cPostParams  As Character
    Local cFileName    As Character
    Local cFileExt     As Character

    self:SetContentType("multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW")

    If !File(cFilePath)
        Return .F.
    EndIf

    cFileContent := MemoRead(cFilePath)
    SplitPath(cFilePath,,,@cFileName,@cFileExt)

    cPostParams := '------WebKitFormBoundary7MA4YWxkTrZu0gW' + CRLF
    cPostParams += 'Content-Disposition: form-data; name="updateDocumentModel"; filename="' + cFileName + cFileExt + '"' + CRLF
    cPostParams += 'Content-Type: application/octetstream' + CRLF
    cPostParams += CRLF + cFileContent + CRLF
    cPostParams += '------WebKitFormBoundary7MA4YWxkTrZu0gW--' +CRLF

    self:oRest:SetPath("/document/update?documentId=" + cDocumentId)

Return self:oRest:PUT(self:aHeader, cPostParams)

Method GetTMList(cLastProcessed, cBatchSize) Class SmartCat As Logical

    Default cLastProcessed := ""
    Default cBatchSize     := "50"

    self:oRest:SetPath("/translationmemory/?lastProcessedID=" + cLastProcessed + "&batchSize=" + cBatchSize)

Return self:oRest:Get(self:aHeader)

Method DownloadTM(cTMId) Class SmartCat As Logical

    self:oRest:SetPath("/translationmemory/" + cTMId + "/file")

Return self:oRest:Get(self:aHeader)

Method UpdateTM(cTMId, cFilePath) Class SmartCat As Logical

    Local cFileContent As Character
    Local cPostParams  As Character
    Local cFileName    As Character
    Local cFileExt     As Character

    self:SetContentType("multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW")

    If !File(cFilePath)
        Return .F.
    EndIf

    cFileContent := MemoRead(cFilePath)
    SplitPath(cFilePath,,,@cFileName,@cFileExt)

    cPostParams := '------WebKitFormBoundary7MA4YWxkTrZu0gW' + CRLF
    cPostParams += 'Content-Disposition: form-data; name="translationMemory"; filename="' + cFileName + cFileExt + '"' + CRLF
    cPostParams += 'Content-Type: application/octetstream' + CRLF
    cPostParams += CRLF + cFileContent + CRLF
    cPostParams += '------WebKitFormBoundary7MA4YWxkTrZu0gW--' +CRLF

    self:oRest:SetPath("/translationmemory/" + cTMId + "?replaceAllContent=true")
    self:oRest:setPostParams(cPostParams)
    self:oRest:Post(self:aHeader)

Return self:GetStatusCode() == "204" // paleativo. Post retornando falso para http status code 204 - No Content

Method GetObjResult() Class SmartCat As Object

    Local oObjResult  As Object
    Local cJSONResult As Character

    cJSONResult := self:oRest:GetResult()
    If !Empty(cJSONResult)
        FWJsonDeserialize(cJSONResult, @oObjResult)
    EndIf

Return oObjResult

Method GetTxtResult() Class SmartCat As Character

Return self:oRest:GetResult()

Method GetLastError() Class SmartCat As Character

Return self:oRest:GetLastError()

Method GetStatusCode() Class SmartCat As Character

Return self:oRest:oResponseH:GetStatusCode()
// Russia_R5
