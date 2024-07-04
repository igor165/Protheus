#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH" 
#INCLUDE "PWSA550.CH"

/*******************************************************************
* Funcao: PWSA550
* Autor: Marcelo faria
* Data: 13/12/2013
* Gestão Publica - Solicitacao de Licencas e Afastamentos
********************************************************************/
Web Function PWSA550()
	Local cHtml   	:= ""
	Local oParam  	:= Nil
	HttpCTType("text/html; charset=ISO-8859-1")
	
	WEB EXTENDED INIT cHtml START "InSite"	              
		HttpSession->cTypeRequest 	:= "R"       //Vida Funcional - Licencas e Afastamentos
		HttpGet->titulo               := STR0001  //Solicitacao de Licencas e Afastamentos
		HttpSession->aStructure	   	:= {}
		HttpSession->cHierarquia	    := ""
        HttpSession->lLicSubst       := .F.
		HttpSession->cIDMENU		:= "GFP"			
		oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		WsChgURL(@oParam,"CFGDICTIONARY.APW")

		fGetInfRotina("W_PWSA550.APW")
		GetMat()                              //Pega a Matricula e a filial do participante logado

       //Busca licencas(RCM) para o portal
       HttpSession->aLicencas  :=  {}
       oLic := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFLicence"), WSRHVDFLicence():New())
       WsChgURL(@oLic,"RHVDFLICENCE.APW")

       oLic:cPortalLicence := '1'
       If oLic:GetLicences()
           HttpSession->aLicencas := oLic:oWSGETLICENCESRESULT
       EndIf
       //varinfo('aLicences-> ', HttpSession->aLicencas)


		cHtml := ExecInPage("PWSA120A")
	WEB EXTENDED END
Return cHtml  


/*******************************************************************
* Funcao: PWSA551
* Autor: Marcelo faria
* Data: 23/01/2014
* Gestão Publica - Consulta Solicitacao de Licencas e Afastamentos
********************************************************************/
Web Function PWSA551()
Local cHtml    := ""
Local nIndice  := 0
Local oObj 
Local oRequest

  If (HttpGet->nOperacao == "1")
      If(valtype(HttpGet->nIndice) != "U")
         nIndice := val(HttpGet->nIndice) 
      endif
  ElseIf (HttpGet->nOperacao $ "3*4")
      If(valtype(HttpGet->nIndiceSolic) != "U")
         nIndice := val(HttpGet->nIndiceSolic) 
      endif
  EndIf   

HttpCTType("text/html; charset=ISO-8859-1")
WEB EXTENDED INIT cHtml START "InSite"  

   //Pega filial e matricula do participante
   GetMat() 
 	   
   //Busca Dados montagem da solicitacao
   oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVacation"), WSRHVacation():New())
   WsChgURL(@oObj,"RHVACATION.APW")

   If (HttpGet->nOperacao == "1")
       //Busca Dados montagem da solicitacao
   	   HttpSession->DadosFunc  := HttpSession->aStructure[nIndice]
       HttpSession->MatSolic   := alltrim(HttpSession->aStructure[nIndice]:cRegistration)

   ElseIf (HttpGet->nOperacao == "3") .Or. (HttpGet->nOperacao == "4")
		oRequest					     := HttpSession->oRequests[val(HttpGet->nIndiceSolic)]
		oLicence    				     := WSClassNew("RHVDFLicence_TVDFLicence")
        
        oLicence:cLicence              := PegaValores(oRequest,"RCM_TIPO")
        oLicence:cLicenceDesc         := PegaValores(oRequest,"RCM_DESCRI")
        oLicence:cDaysType             := PegaValores(oRequest,"RCM_TIPODI")
        oLicence:cDaysTypeDesc        := PegaValores(oRequest,"TMP_TPDESC")
        oLicence:cDaysRequest         := PegaValores(oRequest,"TMP_DIAREQ")
		oLicence:cInitialDate         := PegaValores(oRequest,"TMP_DTINI")
        oLicence:cFinalDate           := PegaValores(oRequest,"TMP_DTFIM")
        oLicence:cSubsEmployeeFil    := PegaValores(oRequest,"TMP_FSUBST")
        oLicence:cSubsRegistration   := PegaValores(oRequest,"TMP_MSUBST")
        oLicence:cSubsName            := PegaValores(oRequest,"TMP_NSUBST")
		
		HttpPost->VDFLicence	       := oLicence
        //varinfo("VDFLicence-> ",HttpPost->VDFLicence)

   EndIf
   cHtml := ExecInPage( "PWSA551" )
	
WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA552
* Autor: Marcelo faria
* Data: 28/01/2014
* Gestão Publica - Licencas e Afastamentos - Gravacao
********************************************************************/
Web Function PWSA552()
Local cHtml   	  := ""
Local oWKF    
Local oLic    
Local oOrg2    
Local cRetorno  := ""
Local cWKFAPV   := "" 
Local nOperacao := HttpPost->nOperacao

HttpCTType("text/html; charset=ISO-8859-1")
WEB EXTENDED INIT cHtml START "InSite"
 	              
	oLic := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFLICENCE"), WSRHVDFLICENCE():New())
	WsChgURL(@oLic,"RHVDFLICENCE.APW")
    
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

	   //Carrega Objeto Request
       oLic:oWSREQUEST:cStarterBranch           := HttpSession->aUser[2] //Filial do solicitante
	   oLic:oWSREQUEST:cSTARTERREGISTRATION 	:= HttpSession->aUser[3] //matricula do solicitante
	   oLic:oWSREQUEST:cBRANCH 				    := HttpPost->cFilFun    
	   oLic:oWSREQUEST:cREGISTRATION 			:= HttpPost->cMatFun    
	   oLic:oWSREQUEST:cVISION 				    := ""                       //Gestao Publica nao usa o conceito de visao do SIGAORG
	   oLic:oWSREQUEST:cOBSERVATION    	    	:= Alltrim(HttpPost->txtobs)

       //busca workflow do item de menu de acordo com o perfil montado do usuario
       cWKFAPV                                     := alltrim(fGetWorkflow("RHVDFLICENCE"))
      
       oLic:oWSREQUEST:cWFAprov                  := cWKFAPV                  //Gestao Publica - Workflow da solicitacao
       oLic:oWSREQUEST:cWFStage                  := ""                        //Gestao Publica - Etapa do Workflow
       If cWKFAPV != ""
          oLic:oWSREQUEST:cWFStage               := "001"                     //Gestao Publica - Etapa do Workflow

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
             oLic:oWSREQUEST:cApproverBranch        := oWKF:OWSGetWorkflowStageRESULT:cResponsibleFil
             oLic:oWSREQUEST:cApproverRegistration := oWKF:OWSGetWorkflowStageRESULT:cResponsibleReg
             oLic:oWSREQUEST:nApproverLevel         := val(oWKF:OWSGetWorkflowStageRESULT:cApproverLevel)
          Else  
            HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" } //"Erro"
            Return ExecInPage("PWSAMSG" )
          EndIf  
       Else  
          oLic:oWSREQUEST:cApproverBranch          := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
          oLic:oWSREQUEST:cApproverRegistration   := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
          oLic:oWSREQUEST:nApproverLevel           := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
       EndIF


       //Carrega Objeto da licenca
       oLic:oWSVDFLICENCEREQUEST:cLicence               := HttpPost->txtLicence
       oLic:oWSVDFLICENCEREQUEST:cLicenceDesc           := HttpSession->aLicencas:OWSITEMSOFLICENCE:OWSDATALICENCE[val(HttpPost->opLicenca)]:CDESCRIPTION
       oLic:oWSVDFLICENCEREQUEST:cDaysRequest           := HttpPost->txtDias01
       oLic:oWSVDFLICENCEREQUEST:cDaysType              := HttpPost->txtDiasCont
       oLic:oWSVDFLICENCEREQUEST:cDaysTypeDesc          := HttpPost->txtDiasCDesc
       oLic:oWSVDFLICENCEREQUEST:cInitialDate           := HttpPost->txtDtIni01
      
       If Alltrim(HttpPost->txtDtFim01) == "calculada..."
       		oLic:oWSVDFLICENCEREQUEST:cFinalDate             := "  /  /  "
       Else
       		oLic:oWSVDFLICENCEREQUEST:cFinalDate             := HttpPost->txtDtFim01
       EndIf
       
       If Empty(HttpPost->txtMatSubst1)
           oLic:oWSVDFLICENCEREQUEST:cSubsEmployeeFil   := ""
           oLic:oWSVDFLICENCEREQUEST:cSubsRegistration  := ""
           oLic:oWSVDFLICENCEREQUEST:cSubsName           := ""
       Else
           oLic:oWSVDFLICENCEREQUEST:cSubsEmployeeFil   := HttpPost->txtMatFil1
           oLic:oWSVDFLICENCEREQUEST:cSubsRegistration  := HttpPost->txtMatSubst1
           oLic:oWSVDFLICENCEREQUEST:cSubsName           := HttpPost->txtNomeSubst1
       EndIf    

	   If oLic:ADDVDFLICENCEREQUEST()
		  cRetorno       := oLic:cADDVDFLICENCEREQUESTRESULT
		  HttpGet->msg  := STR0002  //"operacao realizada com sucesso"
			
		  If(nOperacao == "4")
			  W_PWSA115()
	      Else 
		      W_PWSA550()
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
* Funcao: PWSA553
* Autor: Marcelo Faria
* Data: 30/01/2014
* Gestão Publica - Licencas e Afastamentos - Aprovação
********************************************************************/
Web Function PWSA553()
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
   	                  
	oOrg:cParticipantID	   := HttpSession->cParticipantID
	oOrg:cVision             := HttpSession->oRequests[1]:CVISION 
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
			oObj:oWsRequest:cBranch            := HttpSession->oRequests[val(nIndice)]:cBranch
			oObj:oWsRequest:cRegistration     := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
			oObj:oWsRequest:cCode              := HttpSession->oRequests[val(nIndice)]:cCode
			oObj:oWsRequest:cObservation      := HttpPost->txtobs

            //Avalia aprovadores  
            oObj:oWSREQUEST:cWFAprov          := HttpSession->oRequests[val(nIndice)]:cWFAprov //Gestao Publica - Workflow da solicitacao
            oObj:oWSREQUEST:cWFStage          := HttpSession->oRequests[val(nIndice)]:cWFStage //Gestao Publica - Etapa do Workflow

            If alltrim(oObj:oWSREQUEST:cWFAprov) != ""
                nNovaEtapa                 := val(oObj:oWSREQUEST:cWFStage) + 1
                oObj:oWSREQUEST:cWFStage := STRZERO(nNovaEtapa, 3) //Gestao Publica - Nova Etapa do Workflow
    
                //Recupera aprovador da etapa do workflow para gestao publica
                oWKF := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFJOURNEY"), WSRHVDFJOURNEY():New())
                WsChgURL(@oWKF,"RHVDFJourney.APW")
    
                oWKF:cEMPLOYEEFIL                := HttpSession->oRequests[val(nIndice)]:cBranch
                oWKF:cREGISTRATION               := HttpSession->oRequests[val(nIndice)]:cRegistration
                oWKF:cWorkflow                   := oObj:oWSREQUEST:cWFAprov
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
	   	HttpGet->msg := STR0003 //"Aprovacao Gravada com sucesso"
	      	
	    If(nOperacao == "4")
		    W_PWSA115()
		Else 
	        W_PWSA550()
	    EndIf
	Else
		HttpSession->_HTMLERRO := {STR0001, cErro, "W_PWSA00C.APW"}		//"Erro" 
		Return ExecInPage("PWSAMSG" )
	EndIf 
	
WEB EXTENDED END

Return cHtml 


/*******************************************************************
* Funcao: PWSA554
* Autor: Marcelo Faria
* Data: 30/01/2014
* Gestão Publica - Licencas e Afastamentos - Reprovação
********************************************************************/
Web Function PWSA554()
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
     	
    oOrg:cParticipantID 	    := HttpSession->cParticipantID
    oOrg:cVision				:= HttpSession->aInfRotina:cVisao                       	
    If HttpSession->lR7 .Or. ( ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat) )
        oOrg:cRegistration    := HttpSession->RHMat
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
        	HttpGet->msg := STR0004 //"Reprovacao Gravada com sucesso"	    

		    If(nOperacao == "4")
			    W_PWSA115()
			Else 
		        W_PWSA550()
		    EndIf
		    
		Else
			HttpSession->_HTMLERRO := {STR0001, PWSGetWSError(), "W_PWSA00C.APW"}		//"Erro" 
			Return ExecInPage("PWSAMSG" )
		EndIf 
	Else
		HttpSession->_HTMLERRO := {STR0001, PWSGetWSError(), "W_PWSA00C.APW"}		//"Erro" 
		Return ExecInPage("PWSAMSG" )
	EndIf 			

WEB EXTENDED END

Return cHtml 

