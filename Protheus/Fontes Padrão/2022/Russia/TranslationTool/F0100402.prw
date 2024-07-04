#INCLUDE "PROTHEUS.CH"

User Function F0100402()
    Local cUserPass     := GetNewPar("FS_ABBYPSW", "71a23c51-a247-4315-be23-400a4fbca6f3:1_zgX76ildIXBCHLYLLG7V9gBSx")
    Local cSmartURL     := GetNewPar("FS_ABBYURL", "https://smartcat.ai/api/integration/v1")
    Local cPath         := CurDir() + GetNewPar("FS_DOCINP","input") + "/"

    UploadDoc("SX1", cUserPass, cSmartURL, cPath)
    UploadDoc("SX2", cUserPass, cSmartURL, cPath)
    UploadDoc("SX3", cUserPass, cSmartURL, cPath)
    UploadDoc("SX5", cUserPass, cSmartURL, cPath)
    UploadDoc("SX6", cUserPass, cSmartURL, cPath)
    UploadDoc("SXA", cUserPass, cSmartURL, cPath)
    UploadDoc("SXB", cUserPass, cSmartURL, cPath)
    UploadDoc("SXG", cUserPass, cSmartURL, cPath)
    UploadDoc("help", cUserPass, cSmartURL, cPath)
    UploadDoc("menu", cUserPass, cSmartURL, cPath)
    UploadDoc("source", cUserPass, cSmartURL, cPath)                
                        
Return


Static Function UploadDoc(cOrigin, cUserPass, cSmartURL, cPath)
    Local oSmartCat     := SmartCat():New(Encode64(cUserPass), cSmartURL)
    Local aConfig       := StrTokArr(GetNewPar("FS_SMACAT" + OriginDoc(cOrigin), "3fbb443d-33e3-48cb-92f0-b99ea4f139e1|en|ru"), "|")
    Local cProjectID    := aConfig[1]
    Local nFile         := 0
    Local aFiles        := {}
    Local cDocumentName := ""
    Local cDocumentID   := ""
    Local cFilePath     := ""

    oSmartCat:SetProjectID(cProjectId)

    ADir(cPath + cOrigin + "*.resx", aFiles)

    For nFile := 1 to Len(aFiles)

        cFilePath := cPath + aFiles[nFile]
        
        SplitPath( cFilePath, , , @cDocumentName)
    
        cDocumentID := oSmartCat:GetDocumentID(cDocumentName)

        If Empty(cDocumentID)
            lOK := oSmartCat:UploadDoc(cFilePath)
        Else 
            lOK := oSmartCat:UpdateDoc(cDocumentID, cFilePath)
        EndIf

        If lOK
            UpdZA1Status(cFilePath)
            MoveDoc(cFilePath)
        EndIf
        
    Next

Return


Static Function OriginDoc(cOrigin)
	Local cRet := ""

	Do case
		case cOrigin == "SX1"
			cRet := "1"
		case cOrigin == "SX2"
			cRet := "2"
		case cOrigin == "SX3"
			cRet := "3"
		case cOrigin == "SX5"
			cRet := "5"
		case cOrigin == "SX6"
			cRet := "6"
		case cOrigin == "SXA"
			cRet := "A"
		case cOrigin == "SXB"								
			cRet := "B"
		case cOrigin == "SXG"
			cRet := "G"
		case cOrigin == "help"
			cRet := "H"
		case cOrigin == "menu"
			cRet := "M"
		case cOrigin == "source"								
			cRet := "S"
	Endcase	
	
Return cRet


Static Function MoveDoc(cFilePath)

    Local cPathTo := CurDir() + GetNewPar("FS_DOCSENT","sent") + "/"
    Local cFile   := ""
    Local cExt    := ""

    SplitPath(cFilePath, , , @cFile, @cExt)

    FRename(cFilePath, cPathTo + cFile + cExt)

Return 


Static Function UpdZA1Status(cFilePath)

    Local nNodeCount := 0
    Local nNode      := 0
    Local nZA1Rec    := 0
    Local oXML       := TXMLManager():New()
    
    oXML:ParseFile(cFilePath)

    oXML:DOMChildNode()

    nNodeCount := oXML:DOMSiblingCount()
    
    For nNode := 1 to nNodeCount
        
        If oXML:cName == "data"
            cName := oXML:DomGetAtt("name")

            nZA1Rec := U_GetZA1Rec(cName)
            If !Empty(nZA1Rec)
                ZA1->(DbGoTo(nZA1Rec))
                RecLock("ZA1", .F.)
                ZA1->ZA1_STATUS := "2"
                ZA1->ZA1_HIST   := u_ZA1Hist("Translate Document Sent to ABBY.")
                ZA1->(MsUnlock())
            EndIf
        EndIf
        oXML:DOMNextNode()

    Next

Return 
// Russia_R5
