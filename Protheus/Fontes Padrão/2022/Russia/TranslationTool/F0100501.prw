#INCLUDE "PROTHEUS.CH"

User Function F0100501()
    Local cUserPass  := GetNewPar("FS_ABBYPSW", "71a23c51-a247-4315-be23-400a4fbca6f3:1_zgX76ildIXBCHLYLLG7V9gBSx")
    Local cSmartURL  := GetNewPar("FS_ABBYURL", "https://smartcat.ai/api/integration/v1")

    DownloaDoc("SX1", cUserPass, cSmartURL)
    DownloaDoc("SX2", cUserPass, cSmartURL)
    DownloaDoc("SX3", cUserPass, cSmartURL)
    DownloaDoc("SX5", cUserPass, cSmartURL)
    DownloaDoc("SX6", cUserPass, cSmartURL)
    DownloaDoc("SXA", cUserPass, cSmartURL)
    DownloaDoc("SXB", cUserPass, cSmartURL)
    DownloaDoc("SXG", cUserPass, cSmartURL)
    DownloaDoc("help", cUserPass, cSmartURL)
    DownloaDoc("menu", cUserPass, cSmartURL)
    DownloaDoc("source", cUserPass, cSmartURL)                

Return

Static Function DownloaDoc(cOrigin, cUserPass, cSmartURL)
    Local oSmartCat  := SmartCat():New(Encode64(cUserPass), cSmartURL)
    Local aConfig    := StrTokArr(GetNewPar("FS_SMACAT" + OriginDoc(cOrigin), "3fbb443d-33e3-48cb-92f0-b99ea4f139e1|en|ru"), "|")
    Local cProjectID := aConfig[1]
    Local nFile      := 0

    oSmartCat:SetProjectID(cProjectId)

    If !oSmartCat:GetProjectModel()
        Return
    EndIf

    oModel := oSmartCat:GetObjResult()
    aDocuments := oModel:Documents

    For nFile := 1 to Len(aDocuments)
        If aDocuments[nFile]:Status == "completed"
            If oSmartCat:GetDownloadID(aDocuments[nFile]:ID)
                oDownloadID := oSmartCat:GetObjResult()
                If oSmartCat:DownloadDoc(oDownloadID:ID)
                    cFilePath := WriteDoc(aDocuments[nFile]:Name, oSmartCat:GetTxtResult())
                    UpdateZA1(cFilePath)
                EndIf
            EndIf
        EndIf
    Next

Return

Static Function WriteDoc(cFileName, cBuffer)

    Local cPathTrans := CurDir() + GetNewPar("FS_DOCTRANS","translated") 

    MemoWrite(cPathTrans + "/" + cFileName + "_TRANSLATED.resx", cBuffer)

Return cPathTrans + "/" + cFileName  + "_TRANSLATED.resx"

Static Function UpdateZA1(cFilePath)

    Local cTranslation := ""
    Local nNodeCount   := 0
    Local nNode        := 0
    Local nZA1Rec      := 0
    Local oXML         := TXMLManager():New()

    oXML:ParseFile(cFilePath)

    oXML:DOMChildNode()

    nNodeCount := oXML:DOMSiblingCount()
    
    For nNode := 1 to nNodeCount
        
        If oXML:cName == "data"
           cName := oXML:DomGetAtt("name")

           cTranslation := oXML:XPathGetNodeValue(oXML:cPath + "/value", .F.)
           cTranslation := strIConv(cTranslation, "UTF-8", "cp1251") 
            
           nZA1Rec      := U_GetZA1Rec(cName)

           If !Empty(nZA1Rec)
               ZA1->(DbGoTo(nZA1Rec))
               RecLock("ZA1", .F.)
               ZA1->ZA1_NEWTEX := cTranslation
               ZA1->ZA1_STATUS := "4"
               ZA1->ZA1_HIST   := u_ZA1Hist("Translation Received from ABBY")
               ZA1->(MsUnlock())
           EndIf
        EndIf
        oXML:DOMNextNode()

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
// Russia_R5
