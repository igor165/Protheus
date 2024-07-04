#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH" 
#INCLUDE "PWSA520.CH"

/*******************************************************************
* Funcao: PWSA520
* Autor: Marcelo faria
* Data: 15/05/2014
* Gestão Publica - Avaliação de Saldo de Férias
* Função para selecionar o tipo do saldo (Ferias ou Licenca Premio)
********************************************************************/
Web Function PWSA520()
    Local cHtml     := ""

    WEB EXTENDED INIT cHtml START "InSite"
        HttpSession->cTypeRequest   := "O"       //Vida Funcional - Saldos de Ferias e Licenca Premio
        HttpGet->titulo               := STR0001  //Avaliação do Saldo de Ferias e Licenca Premio
        HttpSession->c520Solic       := "0"      //tipo da solicitacao - 1=Ferias / 2=Licenca Premio
		HttpSession->cIDMENU		:= "GFP"
        cHtml := ExecInPage("PWSA522")
    WEB EXTENDED END
Return cHtml  

/*******************************************************************
* Funcao: PWSA520
* Autor: Marcelo faria
* Data: 08/11/2013
* Gestão Publica - Avaliação de Saldo de Férias
********************************************************************/
Web Function PWSA520A()
	Local cHtml   	:= ""
	Local oParam  	:= Nil
	HttpCTType("text/html; charset=ISO-8859-1")
	WEB EXTENDED INIT cHtml START "InSite"	              
		HttpSession->cTypeRequest 	:= "O"       //Vida Funcional - Saldos de Ferias e Licenca Premio
		HttpGet->titulo				:= STR0001  //Avaliação do Saldo de Ferias e Licenca Premio
		HttpSession->aStructure		:= {}
		HttpSession->cHierarquia	:= ""
		HttpSession->cIDMENU		:= "GFP"	
        HttpSession->c520Solic       := HttpPost->op520Solic  //tipo da solicitacao - 1=Ferias / 2=Licenca Premio
		oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		WsChgURL(@oParam,"CFGDICTIONARY.APW")

		fGetInfRotina("W_PWSA520.APW")
		GetMat()                              //Pega a Matricula e a filial do participante logado

		cHtml := ExecInPage("PWSA120A")
	WEB EXTENDED END
Return cHtml  


/*******************************************************************
* Funcao: PWSA521
* Autor: Marcelo faria
* Data: 08/11/2013
* Gestão Publica - Consulta Avaliação de Saldo de Férias
********************************************************************/
Web Function PWSA521()
Local aFerProg := {}
Local aOpcao   := {}
Local aPlanned := {}
Local nI        := 1
Local cHtml    := ""
Local nIndice  := 0
Local nPos     := 0

Local oTemp := NIL
Local oObj 
Local oProg 
Local oRequest
Local oFerias
Local oWSFerProg
Local oBalanceVac
Local nReg

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

        oObj:cEmployeeFil  := HttpSession->aStructure[nIndice]:cEmployeeFilial
        oObj:cRegistration := HttpSession->aStructure[nIndice]:cRegistration
        oObj:cTypeOfSolic  := "O"
       If HttpSession->c520Solic == "1" //Ferias
          oObj:nTypeOfProg  := 3
       Else
          oObj:nTypeOfProg  := 2
       EndIf

       HttpSession->aPeriodos := {}
       If oObj:GetPerAbert()     
          oTemp := oObj:oWSGetPerAbertResult:oWSListOfPeriod:oWSPeriodVacationProg
       EndIf
      

       If len(oTemp) > 0
           HttpSession->nQtdeProg := 0

           //Busca Dados montagem da solicitacao
           oProg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFBalanceVacation"), WSRHVDFBalanceVacation():New())
           WsChgURL(@oProg,"RHVDFBALANCEVACATION.APW")

           For nPos := 1 to len(oTemp)
               oProg:cTypeSolic    := "O"            
               oProg:cEmployeeFil  := oObj:oWSGetPerAbertResult:oWSListOfPeriod:oWSPeriodVacationProg[nPos]:cEmployeeFilial
               oProg:cRegistration := oObj:oWSGetPerAbertResult:oWSListOfPeriod:oWSPeriodVacationProg[nPos]:cRegistration
               oProg:cPD            := oObj:oWSGetPerAbertResult:oWSListOfPeriod:oWSPeriodVacationProg[nPos]:cIDBase
               oProg:cInitialDate  := alltrim(str(Year(CTOD(oObj:oWSGetPerAbertResult:oWSListOfPeriod:oWSPeriodVacationProg[nPos]:cInitialDate))) + ;
                                         SUBSTR(oObj:oWSGetPerAbertResult:oWSListOfPeriod:oWSPeriodVacationProg[nPos]:cInitialDate, 4, 2) + ; 
                                         Left(oObj:oWSGetPerAbertResult:oWSListOfPeriod:oWSPeriodVacationProg[nPos]:cInitialDate, 2))

               aPlanned := {}
               If oProg:GetPerPlanned()
                  aPlanned := oProg:oWSGetPerPlannedResult:OWSITEMSOFPLAN
               EndIf
                  
               AAdd( HttpSession->aPeriodos, {oTemp[npos] , aPlanned } )
                   
           Next nPos
       EndIf

   ElseIf (HttpGet->nOperacao == "3") .Or. (HttpGet->nOperacao == "4")
		oRequest					       := HttpSession->oRequests[val(HttpGet->nIndiceSolic)]
		oBalanceVac   				       := WSClassNew("RHVDFBalanceVacation_TVDFBalanceVac")
        
        oBalanceVac:cInitialBaseDate   := PegaValores(oRequest,"RIA_DTINPA")
        oBalanceVac:cProgInitialDate   := PegaValores(oRequest,"RIA_DATINI")
        oBalanceVac:cProgFinalDate     := PegaValores(oRequest,"RIA_DATFIM")
        oBalanceVac:nProgDays           := PegaValores(oRequest,"RIA_NRDGOZ")
        oBalanceVac:nAllowDays          := PegaValores(oRequest,"RIA_NRDIND")
        oBalanceVac:cTypeDescSolic     := PegaValores(oRequest,"TMP_TIPO")
        oBalanceVac:cSubstBranch        := PegaValores(oRequest,"RIA_FILSUB")
        oBalanceVac:cSubstRegistration := PegaValores(oRequest,"RIA_MATSUB")
        oBalanceVac:cSubstName          := PegaValores(oRequest,"RIA_NMSUBS")
		
		HttpPost->VDFBalance         	   := oBalanceVac
   EndIf
   cHtml := ExecInPage( "PWSA521" )
	
WEB EXTENDED END

Return cHtml


/*******************************************************************
* Funcao: PWSA522
* Autor: Marcelo faria
* Data: 09/12/2013
* Gestão Publica - Cancelamento Program. de Dias de Férias - Gravacao
********************************************************************/
Web Function PWSA522()
Local cHtml   	:= ""
Local cRetorno  := ""
Local cWKFAPV   := "" 
Local nReg      := 0
Local nRegPlan  := 0
Local nOperacao := HttpPost->nOperacao
Local oWKF
Local oOrg
Local oOrg2

HttpCTType("text/html; charset=ISO-8859-1")
WEB EXTENDED INIT cHtml START "InSite"
              
	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFBALANCEVACATION"), WSRHVDFBALANCEVACATION():New())
	WsChgURL(@oOrg,"RHVDFBALANCEVACATION.APW")
    
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
       oOrg:oWSREQUEST:cStarterBranch           := HttpSession->aUser[2] //Filial do solicitante
	   oOrg:oWSREQUEST:cSTARTERREGISTRATION 	:= HttpSession->aUser[3] //matricula do solicitante
	   oOrg:oWSREQUEST:cBRANCH 				    := HttpPost->cFilFun    
	   oOrg:oWSREQUEST:cREGISTRATION 			:= HttpPost->cMatFun    
	   oOrg:oWSREQUEST:cVISION 				    := ""                               //Gestao Publica nao usa o conceito de visao do SIGAORG
	   oOrg:oWSREQUEST:cOBSERVATION    	    	:= Alltrim(HttpPost->txtobs)

       //busca workflow do item de menu de acordo com o perfil montado do usuario
       cWKFAPV                                     := alltrim(fGetWorkflow("RHVDFVACATION"))
      
       oOrg:oWSREQUEST:cWFAprov                  := cWKFAPV                        //Gestao Publica - Workflow da solicitacao
       oOrg:oWSREQUEST:cWFStage                  := ""                              //Gestao Publica - Etapa do Workflow
       If cWKFAPV != ""
          oOrg:oWSREQUEST:cWFStage               := "001"                           //Gestao Publica - Etapa do Workflow

          //Recupera aprovador da primeira etapa do workflow para gestao publica

          oWKF := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFJOURNEY"), WSRHVDFJOURNEY():New())
          WsChgURL(@oWKF,"RHVDFJOURNEY.APW")

          oWKF:cEMPLOYEEFIL                       := HttpPost->cFilFun
          oWKF:cREGISTRATION                      := HttpPost->cMatFun
          oWKF:cStarterBranch                     := HttpSession->aUser[2]
          oWKF:cStarterRegistration              := HttpSession->aUser[3]
          oWKF:cWorkflow                           := cWKFAPV
          oWKF:cStage                              := "001"
          oWKF:lCompensate                        := .F.
          If oWKF:GetWorkflowStage()
             oOrg:oWSREQUEST:cApproverBranch        := oWKF:OWSGetWorkflowStageRESULT:cResponsibleFil
             oOrg:oWSREQUEST:cApproverRegistration := oWKF:OWSGetWorkflowStageRESULT:cResponsibleReg
             oOrg:oWSREQUEST:nApproverLevel         := val(oWKF:OWSGetWorkflowStageRESULT:cApproverLevel)
          Else  
            HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" } //"Erro"
            Return ExecInPage("PWSAMSG" )
          EndIf  
       Else  
          oOrg:oWSREQUEST:cApproverBranch          := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
          oOrg:oWSREQUEST:cApproverRegistration   := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
          oOrg:oWSREQUEST:nApproverLevel           := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
       EndIF


       
      For nReg := 1 to Len(HttpSession->aPeriodos) 
           For nRegPlan := 1 to Len(HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN)

                //Seleciona opcao escolhida no portal
                If alltrim(str(HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:nRegID)) == alltrim(HttpPost->opProg)
                   //Carrega Objeto da solicitacao do cancelamento da programacao
                   oOrg:oWSVDFBalanceVacRequest:cEmployeeFil      := HttpSession->aPeriodos[nReg][1]:cEmployeeFilial
                   oOrg:oWSVDFBalanceVacRequest:cRegistration     := HttpSession->aPeriodos[nReg][1]:cRegistration
                   oOrg:oWSVDFBalanceVacRequest:cSequence          := HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cSequence
                   oOrg:oWSVDFBalanceVacRequest:cPayrollCode       := HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cIDBase
                   
                   oOrg:oWSVDFBalanceVacRequest:cInitialBaseDate   := HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cBaseDate
                   oOrg:oWSVDFBalanceVacRequest:cProgInitialDate   := HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cInitialDateProg
                   oOrg:oWSVDFBalanceVacRequest:cProgFinalDate     := HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cFinalDateProg
                   
                   oOrg:oWSVDFBalanceVacRequest:nProgDays           := HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:nProgDays
                   oOrg:oWSVDFBalanceVacRequest:nAllowDays          := HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:nAllowDays
                   oOrg:oWSVDFBalanceVacRequest:nRegID               := HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:nRegID
                
                   oOrg:oWSVDFBalanceVacRequest:cSubstBranch        := HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cSubstBranch
                   oOrg:oWSVDFBalanceVacRequest:cSubstRegistration := HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cSubstRegistration
                   oOrg:oWSVDFBalanceVacRequest:cSubstName          := HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cSubstname

                   If HttpSession->c520Solic == "1" //Ferias
                       If empty(HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cIDPublication)
                           oOrg:oWSVDFBalanceVacRequest:cTypeDescSolic := STR0007 +' ' +STR0009 //"CANCELAMENTO FERIAS"                   
                       Else
                           oOrg:oWSVDFBalanceVacRequest:cTypeDescSolic := STR0008 +' ' +STR0009 //"RETIFICAÇÃO FERIAS"
                       EndIf
                   Else
                       If empty(HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cIDPublication)
                           oOrg:oWSVDFBalanceVacRequest:cTypeDescSolic := STR0007 +' ' +STR0010 //"CANCELAMENTO LICENCA PREMIO"                   
                       Else
                           oOrg:oWSVDFBalanceVacRequest:cTypeDescSolic := STR0008 +' ' +STR0010 //"RETIFICAÇÃO LICENCA PREMIO"
                       EndIf
                   EndIf
                   
                   oOrg:oWSVDFBalanceVacRequest:cIDPublication      := HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cIDPublication
                   oOrg:oWSVDFBalanceVacRequest:cRI6Key              := HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cRI6Key
                EndIf

           Next nRegPlan
       Next nReg

	   If oOrg:ADDVDFBALANCEVACREQUEST()
		  cRetorno       := oOrg:cADDVDFBALANCEVACREQUESTRESULT
		  HttpGet->msg  := STR0002  //"operacao realizada com sucesso"
			
		  If(nOperacao == "4")
			  W_PWSA115()
	      Else 
		      W_PWSA520A()
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
* Funcao: PWSA523
* Autor: Marcelo Faria
* Data: 08/11/2013
* Gestão Publica - Avaliação de Saldo de Férias - Aprovação
********************************************************************/
Web Function PWSA523()
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
    
                oWKF:cEMPLOYEEFIL               := HttpSession->oRequests[val(nIndice)]:cBranch
                oWKF:cREGISTRATION              := HttpSession->oRequests[val(nIndice)]:cRegistration
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
	        W_PWSA520A()
	    EndIf
	Else
		HttpSession->_HTMLERRO := {STR0001, cErro, "W_PWSA00C.APW"}		//"Erro" 
		Return ExecInPage("PWSAMSG" )
	EndIf 
	
WEB EXTENDED END

Return cHtml 


/*******************************************************************
* Funcao: PWSA524
* Autor: Marcelo Faria
* Data: 10/12/2013
* Gestão Publica - Avaliação de Saldo de Férias - Reprovação
********************************************************************/
Web Function PWSA524()
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
		        W_PWSA520A()
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
