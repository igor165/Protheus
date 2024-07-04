#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH" 
#INCLUDE "PWSA510.CH"

/*******************************************************************
* Funcao: PWSA510
* Autor: Marcelo faria
* Data: 20/08/2013
* Gestão Publica - Solicitacao de Alteração de Jornada
********************************************************************/
Web Function PWSA510()
	Local cHtml   	:= ""
	Local oParam  	:= Nil

	WEB EXTENDED INIT cHtml START "InSite"	              
		HttpSession->cTypeRequest 	:= "N"     // Vida Funcional - Alteracao de Jornada
		HttpGet->titulo             := STR0001	//"Alteracao de Jornada"
		HttpSession->aStructure	   	:= {}
		HttpSession->cHierarquia	:= ""
		HttpSession->cIDMENU		:= "GFP"	
		oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New()) 
		WsChgURL(@oParam,"CFGDICTIONARY.APW") 

		fGetInfRotina("W_PWSA510.APW")
		GetMat()                              //Pega a Matricula e a filial do participante logado

		cHtml := ExecInPage("PWSA120A")
	WEB EXTENDED END
Return cHtml  

/*******************************************************************
* Funcao: PWSA511
* Autor: Marcelo faria
* Data: 23/08/2013
* Gestão Publica - Consulta Solicitacao
********************************************************************/
Web Function PWSA511()
Local oRequest
Local oObj 
Local cHtml   	:= ""
Local nIndice 	:= 0

if(valtype(HttpGet->nIndice) != "U")
   nIndice := val(HttpGet->nIndice) 
endif

WEB EXTENDED INIT cHtml START "InSite"  

   	If (HttpGet->nOperacao == "1")  
       GetMat() 
   		HttpSession->DadosFunc := HttpSession->aStructure[nIndice]
   		
       oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFJOURNEY"), WSRHVDFJOURNEY():New()) 
       WsChgURL(@oObj,"RHVDFJourney.APW")

       oObj:cEMPLOYEEFIL      := HttpSession->aStructure[nIndice]:cEmployeeFilial
       oObj:cREGISTRATION     := HttpSession->aStructure[nIndice]:cRegistration
       HttpPost->JornadaAtual := "0"
       If oObj:GetJourney()
          HttpPost->JornadaAtual := alltrim(oObj:cGetJourneyResult)
       EndIf
   		
   	ElseIf (HttpGet->nOperacao == "3") .Or. (HttpGet->nOperacao == "4")
			
		oRequest					   := HttpSession->oRequests[val(HttpGet->nIndiceSolic)]
		oJourney       				:= WSClassNew("RHVDFJourney_TVDFJourney")
		
		oJourney:cJourney         	:= PegaValores(oRequest,"PF_JORNAPA")
		HttpPost->Jornada     		:= oJourney
	EndIf
   cHtml := ExecInPage( "PWSA511" )  
	
WEB EXTENDED END
Return cHtml

/*******************************************************************
* Funcao: PWSA512
* Autor: Marcelo faria
* Data: 23/08/2013
* Gestão Publica - Alteracao de Jornada - Gravacao
********************************************************************/
Web Function PWSA512()
Local cHtml   	:= ""
Local oWKF    
Local oOrg    
Local oOrg2    
Local cRetorno	:= ""
Local cWKFAPV   := "" 
Local nOperacao := HttpPost->nOperacao

WEB EXTENDED INIT cHtml START "InSite"
              
	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFJOURNEY"), WSRHVDFJOURNEY():New())
	WsChgURL(@oOrg,"RHVDFJourney.APW")
    
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
       oOrg:oWSREQUEST:cSTARTERREGISTRATION    := HttpSession->aUser[3] //Matricula do solicitante
		oOrg:oWSREQUEST:cBRANCH 				     := HttpPost->cFilFun     //Filial do participante
		oOrg:oWSREQUEST:cREGISTRATION 			 := HttpPost->cMatFun     //Matricula do participante
		oOrg:oWSREQUEST:cVISION 				    := ""                    //Gestao Publica nao usa o conceito de visao do SIGAORG
		oOrg:oWSREQUEST:cOBSERVATION    		 := Alltrim(HttpPost->txtobs)

      //busca workflow do item de menu de acordo com o perfil montado do usuario
      cWKFAPV                              := alltrim(fGetWorkflow("RHVDFJOURNEY"))
      
      oOrg:oWSREQUEST:cWFAprov             := cWKFAPV                        //Gestao Publica - Workflow da solicitacao
      oOrg:oWSREQUEST:cWFStage             := ""                            //Gestao Publica - Etapa do Workflow
      If cWKFAPV != ""
          oOrg:oWSREQUEST:cWFStage         := "001"                         //Gestao Publica - Etapa do Workflow

          //Recupera aprovador da primeira etapa do workflow para gestao publica
          oWKF := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFJOURNEY"), WSRHVDFJOURNEY():New())
          WsChgURL(@oWKF,"RHVDFJourney.APW")

          oWKF:cEMPLOYEEFIL                := HttpPost->cFilFun
          oWKF:cREGISTRATION               := HttpPost->cMatFun
          oWKF:cStarterBranch              := HttpSession->aUser[2]
          oWKF:cStarterRegistration        := HttpSession->aUser[3]
          oWKF:cWorkflow                   := cWKFAPV
          oWKF:cStage                      := "001"
          oWKF:lCompensate                 := .F.
          If oWKF:GetWorkflowStage()
             oOrg:oWSREQUEST:cApproverBranch        := oWKF:OWSGetWorkflowStageRESULT:cResponsibleFil
             oOrg:oWSREQUEST:cApproverRegistration  := oWKF:OWSGetWorkflowStageRESULT:cResponsibleReg
             oOrg:oWSREQUEST:nApproverLevel         := val(oWKF:OWSGetWorkflowStageRESULT:cApproverLevel)
          Else  
            HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" } //"Erro"
            Return ExecInPage("PWSAMSG" )
          EndIf  
      Else
          oOrg:oWSREQUEST:cApproverBranch       := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
          oOrg:oWSREQUEST:cApproverRegistration := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
          oOrg:oWSREQUEST:nApproverLevel        := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup

          oOrg:oWSREQUEST:cSTARTERREGISTRATION  := HttpSession->aUser[3]         //Filial do solicitante
          oOrg:oWSREQUEST:cStarterBranch        := HttpSession->aUser[2]         //Matricula do solicitante
          oOrg:oWSREQUEST:cBRANCH               := HttpPost->cFilFun             
          oOrg:oWSREQUEST:cREGISTRATION         := HttpPost->cMatFun             
          oOrg:oWSREQUEST:cVISION               := ""
      EndIF
		

		oOrg:oWSVDFJOURNEYREQUEST:cJourney		:= HttpPost->cbJornada
	
		If oOrg:ADDVDFJOURNEYREQUEST()
			cRetorno                        := oOrg:cADDVDFJOURNEYREQUESTRESULT
			HttpGet->msg                    := STR0003  //"operacao realizada com sucesso"
			
			If(nOperacao == "4")
			    W_PWSA115()
			Else 
		       W_PWSA510()
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
* Funcao: PWSA513
* Autor: Marcelo faria
* Data: 28/08/2013
* Gestão Publica - Alteracao de Jornada - Aprovação
********************************************************************/
Web Function PWSA513()
Local cHtml    	:= ""
Local nIndice   := HttpSession->nIndiceSolic
Local nOperacao := HttpSession->nOperacao
Local nNovaEtapa := 0
Local lOk       := .T.
Local cErro     := ""
Local Cod       := HttpPost->txtcod
Local oObj    
Local oOrg    

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
		
			oObj:oWsRequest                     := RHREQUEST_TREQUEST():New()
			oObj:oWsRequest:cBranch             := HttpSession->oRequests[val(nIndice)]:cBranch
			oObj:oWsRequest:cRegistration       := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
			oObj:oWsRequest:cCode               := HttpSession->oRequests[val(nIndice)]:cCode
			oObj:oWsRequest:cObservation        := HttpPost->txtobs

          //Avalia aprovadores  
          oObj:oWSREQUEST:cWFAprov             := HttpSession->oRequests[val(nIndice)]:cWFAprov //Gestao Publica - Workflow da solicitacao
          oObj:oWSREQUEST:cWFStage             := HttpSession->oRequests[val(nIndice)]:cWFStage //Gestao Publica - Etapa do Workflow

          If alltrim(oObj:oWSREQUEST:cWFAprov) != ""
             nNovaEtapa             := val(oObj:oWSREQUEST:cWFStage) + 1
             oObj:oWSREQUEST:cWFStage := STRZERO(nNovaEtapa, 3) //Gestao Publica - Nova Etapa do Workflow
    
              //Recupera aprovador da etapa do workflow para gestao publica
              oWKF := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFJOURNEY"), WSRHVDFJOURNEY():New())
              WsChgURL(@oWKF,"RHVDFJourney.APW")
    
              oWKF:cEMPLOYEEFIL               := HttpSession->oRequests[val(nIndice)]:cBranch
              oWKF:cREGISTRATION              := HttpSession->oRequests[val(nIndice)]:cRegistration
              oWKF:cWorkflow                   := oObj:oWSREQUEST:cWFAprov
              oWKF:cStage                       := oObj:oWSREQUEST:cWFStage
              oWKF:cStarterBranch              := HttpSession->oRequests[val(nIndice)]:cStarterBranch
              oWKF:cStarterRegistration       := HttpSession->oRequests[val(nIndice)]:cStarterRegistration
              oWKF:lCompensate                 := .F.
              If oWKF:GetWorkflowStage()
                 oObj:oWSREQUEST:cApproverBranch      := oWKF:OWSGetWorkflowStageRESULT:cResponsibleFil
                 oObj:oWSREQUEST:cApproverRegistration := oWKF:OWSGetWorkflowStageRESULT:cResponsibleReg
                 oObj:oWSREQUEST:nApproverLevel       := val(oWKF:OWSGetWorkflowStageRESULT:cApproverLevel)
              Else  
                HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" } //"Erro"
                Return ExecInPage("PWSAMSG" )
              EndIf  
          Else  
             oObj:oWsRequest:cApproverBranch        := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
             oObj:oWsRequest:cApproverRegistration  := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
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
	        W_PWSA510()
	    EndIf
	Else
		HttpSession->_HTMLERRO := {STR0003, cErro, "W_PWSA00C.APW"}		//"Erro" 
		Return ExecInPage("PWSAMSG" )
	EndIf 
	
WEB EXTENDED END

Return cHtml 


/*******************************************************************
* Funcao: PWSA514
* Autor: Marcelo faria
* Data: 28/08/2013
* Gestão Publica - Alteracao de Jornada - Reprovação
********************************************************************/
Web Function PWSA514()
Local cHtml   	:= ""
Local oObj    
Local oOrg    
Local nIndice 	:= HttpSession->nIndiceSolic
Local nOperacao	:= HttpSession->nOperacao

WEB EXTENDED INIT cHtml START "InSite"
	//busca filial e matricula do paritipante logado
	GetMat()

	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
    WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
     	
    oOrg:cParticipantID 	:= HttpSession->cParticipantID
    oOrg:cVision				:= HttpSession->aInfRotina:cVisao                       	
    If HttpSession->lR7 .Or. ( ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat) )
        oOrg:cRegistration := HttpSession->RHMat
    EndIf   

    If oOrg:GetStructure()       
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WsRhRequest"), WsRhRequest():New())
		WsChgURL(@oObj, "RHREQUEST.APW")   

		oObj:oWsRequest	                  	:= RHREQUEST_TREQUEST():New()
		oObj:oWsRequest:cBranch             	:= HttpSession->oRequests[val(nIndice)]:cBranch
		oObj:oWsRequest:cRegistration        	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
		oObj:oWsRequest:cCode               	:= HttpSession->oRequests[val(nIndice)]:cCode
		oObj:oWsRequest:cObservation         	:= HttpPost->txtobs
		oObj:oWsRequest:cApproverBranch		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
		oObj:oWsRequest:cApproverRegistration 	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
		oObj:oWsRequest:nApproverLevel		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
				
		If oObj:ReproveRequest()
        	HttpGet->msg := STR0005 //"Reprovacao Gravada com sucesso"	    

		    If(nOperacao == "4")
			    W_PWSA115()
			Else 
		        W_PWSA510()
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


/*******************************************************************
* Funcao: fGetWorkflow
* Retorna o workflow correspondente para o item de menu
* referente ao perfil do usuario logado 
********************************************************************/
Function fGetWorkflow(cWebService)
Local nI       := 0
Local cWorkFlow := ""

    For nI := 1 To Len( httpSession->USR_INFO[1]:OWSUSERACCESSES:OWSLOGINACCESSESSTRUCT )
        If Alltrim(httpSession->USR_INFO[1]:OWSUSERACCESSES:OWSLOGINACCESSESSTRUCT[nI]:cWEBSRV) == cWebService
            cWorkflow := httpSession->USR_INFO[1]:OWSUSERACCESSES:OWSLOGINACCESSESSTRUCT[nI]:cWKFAPV
            exit
        Endif
    Next nI

Return cWorkflow

