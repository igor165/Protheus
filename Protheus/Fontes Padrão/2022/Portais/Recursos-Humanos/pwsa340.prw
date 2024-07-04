#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

Web Function PWSA340()
	Local cHtml := ""
	Local oWSArtifact
	Local nI
	Local nTam
	Local aTemp 	:= {}
	Local aItens	:= {}
	
	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"	
		fGetInfRotina("W_PWSA340.APW")
		GetMat()					
		oWSArtifact  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHArtifact"), WSRHArtifact():New())    
		WsChgURL(@oWSArtifact, "RHARTIFACT.APW")
		                     
		oWSArtifact:cRegistration	:= HttpSession->aUser[3] //Filial
		oWSArtifact:cBranch	 		:= HttpSession->aUser[2] //Matricula
	
		If oWSArtifact:BrowseArtifact()
			aArtifactList	:= oWSArtifact:oWSBrowseArtifactResult:oWSItens:oWStArtifactList
			nTam := Len(aArtifactList)
			For nI := 1 To nTam
			   	If !Empty(aArtifactList[nI]:cAlias) .AND. !Empty(aArtifactList[nI]:cCodeCriter)
					
					oWSArtifact:cAlias		:= aArtifactList[nI]:cAlias 
					oWSArtifact:cCodeCriter	:= aArtifactList[nI]:cCodeCriter
					
					If oWSArtifact:GetCriterArtifact()
						If  !oWSArtifact:lGetCriterArtifactResult 
							aadd(aTemp,aArtifactList[nI]:cCode)
						Else
							If aScan(aItens,{|x| x:cCode == aArtifactList[nI]:cCode}) <= 0 .Or. Empty(aItens)
								aadd(aItens,aArtifactList[nI])
							EndIf
						EndIf
					EndIf 
				Else
					aadd(aItens,aArtifactList[nI])
				EndIf
			Next nI

			aArtifactList := aClone(aItens)
			For nI := 1 To Len(aTemp)
				While (nPos := aScan(aArtifactList,{|x| x:cCode == aTemp[nI]})) > 0
					aDel(aArtifactList, nPos)
					aSize(aArtifactList, Len(aArtifactList)-1)
				EndDo
						
			Next nI
			
			If oWSArtifact:GetConfigArtifact()
				aConfigList := oWSArtifact:OWSGetConfigArtifactResult:OWSItens:OWStConfigArtifactList
			Else
				HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA000.APW" }
				Return ExecInPage("PWSAMSG" )
			EndIf
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA000.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf

		cHtml := ExecInPage("PWSA340")
	WEB EXTENDED END

Return cHtml
