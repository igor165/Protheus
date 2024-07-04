#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH" 
#INCLUDE "PWSA560.CH"

/*******************************************************************
* Funcao: PWSA560
* Autor: Marcelo faria
* Data: 20/01/2014
* Gestão Publica - Solicitacao de Certidão Funcional
********************************************************************/
Web Function PWSA560()
	Local cHtml   	:= ""
	Local oParam  	:= Nil
	HttpCTType("text/html; charset=ISO-8859-1")
	WEB EXTENDED INIT cHtml START "InSite"	              
		HttpSession->cTypeRequest 	:= "S"      // Vida Funcional - Certidao Funcional
		HttpGet->titulo               := STR0001 //"Certidao Funcional"
		HttpSession->aStructure	   	:= {}
		HttpSession->cHierarquia	    := ""
		HttpSession->cIDMENU		:= "GFP"	
		oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		WsChgURL(@oParam,"CFGDICTIONARY.APW") 

		fGetInfRotina("W_PWSA560.APW")
		GetMat()                                   //Pega a Matricula e a filial do participante logado

		cHtml := ExecInPage("PWSA120A")
	WEB EXTENDED END
Return cHtml  

/*******************************************************************
* Funcao: PWSA561
* Autor: Marcelo faria
* Data: 20/01/2014
* Gestão Publica - Consulta Solicitacao
********************************************************************/
Web Function PWSA561()
Local oRequest
Local cHtml   	:= ""
Local nIndice 	:= 0

if(valtype(HttpGet->nIndice) != "U")
   nIndice := val(HttpGet->nIndice) 
endif
HttpCTType("text/html; charset=ISO-8859-1")
WEB EXTENDED INIT cHtml START "InSite"  

   	If (HttpGet->nOperacao == "1")  
        GetMat() 

   		HttpSession->DadosFunc := HttpSession->aStructure[nIndice]
   	ElseIf (HttpGet->nOperacao == "3") .Or. (HttpGet->nOperacao == "4")
			
		oRequest      			   := HttpSession->oRequests[val(HttpGet->nIndiceSolic)]
		oCertificate             := WSClassNew("RHVDFCertificate_TVDFCertificate")
		
		oCertificate:cDoctoID   := PegaValores(oRequest,"TMP_DOCTO")
        oCertificate:cDoctoDesc := PegaValores(oRequest,"TMP_DESC")
        HttpPost->Certificate   := oCertificate
	EndIf
   cHtml := ExecInPage( "PWSA561" )  
	
WEB EXTENDED END

Return cHtml

/*******************************************************************
* Funcao: PWSA562
* Autor: Marcelo faria
* Data: 20/01/2014
* Gestão Publica - Certidao Funcional - Gravacao
********************************************************************/
Web Function PWSA562()
Local cHtml   	:= ""
Local oWKF    
Local oOrg    
Local oOrg2    
Local cRetorno	:= ""
Local cWKFAPV   := "" 
Local nOperacao := HttpPost->nOperacao
HttpCTType("text/html; charset=ISO-8859-1")
WEB EXTENDED INIT cHtml START "InSite"
              
	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFCERTIFICATE"), WSRHVDFCERTIFICATE():New())
	WsChgURL(@oOrg,"RHVDFCERTIFICATE.APW")
    
    oOrg2 := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
	WsChgURL(@oOrg2,"ORGSTRUCTURE.APW")
     
	oOrg2:cParticipantID 	:= HttpSession->cParticipantID
	oOrg2:cTypeOrg       	:= ""
	oOrg2:cVision        	:= "" //Gestao Publica nao usa o conceito de visao do SIGAORG
	If HttpSession->lR7 .Or. ( ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat) )
		oOrg2:cRegistration	:= HttpSession->RHMat
	EndIf	

   If oOrg2:GetStructure()
	   //Pega filial e matricula do participante
	   GetMat() 

        oOrg:oWSREQUEST:cStarterBranch          := HttpSession->aUser[2] //Filial do solicitante
		oOrg:oWSREQUEST:cSTARTERREGISTRATION 	:= HttpSession->aUser[3] //Matricula do solicitante
		oOrg:oWSREQUEST:cBRANCH 				    := HttpPost->cFilFun    
		oOrg:oWSREQUEST:cREGISTRATION 			:= HttpPost->cMatFun    
		oOrg:oWSREQUEST:cVISION 				    := ""                       //Gestao Publica nao usa o conceito de visao do SIGAORG
		oOrg:oWSREQUEST:cOBSERVATION    		:= Alltrim(HttpPost->txtobs)

       //busca workflow do item de menu de acordo com o perfil montado do usuario
       cWKFAPV                                     := alltrim(fGetWorkflow("RHVDFCERTIFICATE"))
      
       oOrg:oWSREQUEST:cWFAprov                  := cWKFAPV                  //Gestao Publica - Workflow da solicitacao
       oOrg:oWSREQUEST:cWFStage                  := ""                        //Gestao Publica - Etapa do Workflow
       If cWKFAPV != ""
          oOrg:oWSREQUEST:cWFStage               := "001"                     //Gestao Publica - Etapa do Workflow

          //Recupera aprovador da primeira etapa do workflow para gestao publica
          oWKF := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFJOURNEY"), WSRHVDFJOURNEY():New())
          WsChgURL(@oWKF,"RHVDFJourney.APW")

          oWKF:cEMPLOYEEFIL                           := HttpPost->cFilFun
          oWKF:cREGISTRATION                          := HttpPost->cMatFun
          oWKF:cStarterBranch                         := HttpSession->aUser[2]
          oWKF:cStarterRegistration                  := HttpSession->aUser[3]
          oWKF:cWorkflow                               := cWKFAPV
          oWKF:cStage                                  := "001"
          oWKF:lCompensate                            := .F.
          If oWKF:GetWorkflowStage()
             oOrg:oWSREQUEST:cApproverBranch        := oWKF:OWSGetWorkflowStageRESULT:cResponsibleFil
             oOrg:oWSREQUEST:cApproverRegistration := oWKF:OWSGetWorkflowStageRESULT:cResponsibleReg
             oOrg:oWSREQUEST:nApproverLevel         := val(oWKF:OWSGetWorkflowStageRESULT:cApproverLevel)
          Else  
            HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" } //"Erro"
            Return ExecInPage("PWSAMSG" )
          EndIf  
      Else  
          oOrg:oWSREQUEST:cApproverBranch           := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
          oOrg:oWSREQUEST:cApproverRegistration    := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
          oOrg:oWSREQUEST:nApproverLevel            := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
      EndIF

	   oOrg:oWSVDFCERTIFICATEREQUEST:cDoctoID     		:= HttpPost->chkDocto
       oOrg:oWSVDFCERTIFICATEREQUEST:cDoctoDesc       := ""
       If  HttpPost->chkDocto == "1"
           oOrg:oWSVDFCERTIFICATEREQUEST:cDoctoDesc   := STR0006 //Certidao Funcional
       EndIf
	
	   If oOrg:ADDVDFCERTIFICATEREQUEST()
		  cRetorno                                 := oOrg:cADDVDFCERTIFICATEREQUESTRESULT
		  HttpGet->msg                            := STR0003  //"operacao realizada com sucesso"
			
		  If(nOperacao == "4")
		     W_PWSA115()
		  Else 
		     W_PWSA560()
		  EndIf
	   Else
		  HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
		  Return ExecInPage("PWSAMSG" )
	   EndIf
	Else
		HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
		Return ExecInPage("PWSAMSG" )
	EndIf
WEB EXTENDED END

Return cHtml   


/*******************************************************************
* Funcao: PWSA563
* Autor: Marcelo faria
* Data: 20/01/2014
* Gestão Publica - Certidao Funcional - Aprovação
********************************************************************/
Web Function PWSA563()
Local cHtml    	:= ""
Local nIndice     := HttpSession->nIndiceSolic
Local nOperacao   := HttpSession->nOperacao
Local nNovaEtapa  := 0
Local lOk          := .T.
Local cErro        := ""
Local Cod          := HttpPost->txtcod
Local oObj    
Local oOrg    
HttpCTType("text/html; charset=ISO-8859-1")
WEB EXTENDED INIT cHtml START "InSite"
	//busca filial e matricula do paritipante logado
	GetMat()

	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
   	WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
   	                  
	oOrg:cParticipantID	  := HttpSession->cParticipantID
	oOrg:cVision          := HttpSession->oRequests[1]:CVISION 
   	If HttpSession->lR7 .Or. ( ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat) )
    	oOrg:cRegistration  := HttpSession->RHMat
	EndIf   

	If (lOk:= oOrg:GetStructure())
		If HttpPost->lPontoRH == ".T."
			aRetorno := ExecBlock("PontoRH",.F.,.F.,{"3", HttpSession->oRequests[1]:CBRANCH, Cod, HttpPost->txtvisao,nil,nil,HttpPost->txtobs,oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeFilial,oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration})
			If !aRetorno[1]
				lOk   := .F.
				cErro := aRetorno[2]
			EndIf
		Else
		    oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WsRhRequest"), WsRhRequest():New())
			WsChgURL(@oObj, "RHREQUEST.APW")   
		
			oObj:oWsRequest                      := RHREQUEST_TREQUEST():New()
			oObj:oWsRequest:cBranch             := HttpSession->oRequests[val(nIndice)]:cBranch
			oObj:oWsRequest:cRegistration      := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
			oObj:oWsRequest:cCode               := HttpSession->oRequests[val(nIndice)]:cCode
			oObj:oWsRequest:cObservation       := HttpPost->txtobs

           //Avalia aprovadores  
           oObj:oWSREQUEST:cWFAprov             := HttpSession->oRequests[val(nIndice)]:cWFAprov //Gestao Publica - Workflow da solicitacao
           oObj:oWSREQUEST:cWFStage             := HttpSession->oRequests[val(nIndice)]:cWFStage //Gestao Publica - Etapa do Workflow

           If oObj:oWSREQUEST:cWFAprov != ""
               nNovaEtapa                         := val(oObj:oWSREQUEST:cWFStage) + 1
               oObj:oWSREQUEST:cWFStage         := STRZERO(nNovaEtapa, 3) //Gestao Publica - Nova Etapa do Workflow
    
                //Recupera aprovador da etapa do workflow para gestao publica
                oWKF := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFJOURNEY"), WSRHVDFJOURNEY():New())
                WsChgURL(@oWKF,"RHVDFJourney.APW")
    
                oWKF:cEMPLOYEEFIL                := HttpSession->oRequests[val(nIndice)]:cBranch
                oWKF:cREGISTRATION               := HttpSession->oRequests[val(nIndice)]:cRegistration
                oWKF:cWorkflow                    := oObj:oWSREQUEST:cWFAprov
                oWKF:cStage                       := oObj:oWSREQUEST:cWFStage
                oWKF:cStarterBranch              := HttpSession->oRequests[val(nIndice)]:cStarterBranch
                oWKF:cStarterRegistration       := HttpSession->oRequests[val(nIndice)]:cStarterRegistration
                oWKF:lCompensate                 := .F.
                If oWKF:GetWorkflowStage()
                   oObj:oWSREQUEST:cApproverBranch        := oWKF:OWSGetWorkflowStageRESULT:cResponsibleFil
                   oObj:oWSREQUEST:cApproverRegistration := oWKF:OWSGetWorkflowStageRESULT:cResponsibleReg
                   oObj:oWSREQUEST:nApproverLevel         := val(oWKF:OWSGetWorkflowStageRESULT:cApproverLevel)
                Else  
                  HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" } //"Erro"
                  Return ExecInPage("PWSAMSG" )
                EndIf  
           Else  
              oObj:oWsRequest:cApproverBranch        := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
              oObj:oWsRequest:cApproverRegistration := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
              oObj:oWsRequest:nApproverLevel         := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
           EndIF

					
           If oObj:ApproveRequest()
	    		lOk := .T.
	       Else
	    		cErro := PWSGetWSError()
	    		lOk := .F.
	       EndIf
		EndIf
	EndIf
		
	If lOk
	   	HttpGet->msg := STR0004 //"Aprovacao Gravada com sucesso"
	      	
	    If(nOperacao == "4")
		    W_PWSA115()
		Else 
	        W_PWSA560()
	    EndIf
	Else
		HttpSession->_HTMLERRO := {STR0003, cErro, "W_PWSA00C.APW"}		//"Erro" 
		Return ExecInPage("PWSAMSG" )
	EndIf 
	
WEB EXTENDED END


Return cHtml 


/*************************************************
* Funcao: PWSA564
* Autor: Marcelo faria
* Data: 20/01/2014
* Gestão Publica - Certidao Funcional - Reprovação
**************************************************/
Web Function PWSA564()
Local cHtml   	:= ""
Local oObj    
Local oOrg    
Local nIndice 	:= HttpSession->nIndiceSolic
Local nOperacao	:= HttpSession->nOperacao

HttpCTType("text/html; charset=ISO-8859-1")
WEB EXTENDED INIT cHtml START "InSite"
	//busca filial e matricula do paritipante logado
	GetMat()

	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
    WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
     	
    oOrg:cParticipantID 	:= HttpSession->cParticipantID
    oOrg:cVision			:= HttpSession->aInfRotina:cVisao                       	
    If HttpSession->lR7 .Or. ( ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat) )
        oOrg:cRegistration := HttpSession->RHMat
    EndIf   

    If oOrg:GetStructure()       
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WsRhRequest"), WsRhRequest():New())
		WsChgURL(@oObj, "RHREQUEST.APW")   

		oObj:oWsRequest	                  	    := RHREQUEST_TREQUEST():New()
		oObj:oWsRequest:cBranch             	    := HttpSession->oRequests[val(nIndice)]:cBranch
		oObj:oWsRequest:cRegistration        	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
		oObj:oWsRequest:cCode               	    := HttpSession->oRequests[val(nIndice)]:cCode
		oObj:oWsRequest:cObservation         	:= HttpPost->txtobs
		oObj:oWsRequest:cApproverBranch		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
		oObj:oWsRequest:cApproverRegistration 	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
		oObj:oWsRequest:nApproverLevel		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
				
		If oObj:ReproveRequest()
        	HttpGet->msg := STR0005 //"Reprovacao Gravada com sucesso"	    

		    If(nOperacao == "4")
			    W_PWSA115()
			Else 
		        W_PWSA560()
		    EndIf 
		    
		Else
			HttpSession->_HTMLERRO := {STR0003, PWSGetWSError(), "W_PWSA00C.APW"}		//"Erro" 
			Return ExecInPage("PWSAMSG" )
		EndIf 
	Else
		HttpSession->_HTMLERRO := {STR0003, PWSGetWSError(), "W_PWSA00C.APW"}		//"Erro" 
		Return ExecInPage("PWSAMSG" )
	EndIf 			

WEB EXTENDED END

Return cHtml 

