#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH" 
#INCLUDE "PWSA530.CH"

/*******************************************************************
* Funcao: PWSA530
* Autor: Marcelo faria
* Data: 07/02/2014
* Gestão Publica - Solicitacao de Programação de Férias
* Função para selecionar o tipo(Ferias ou Licenca Premio)
********************************************************************/
Web Function PWSA530()
	Local cHtml   	:= ""

	WEB EXTENDED INIT cHtml START "InSite"
		HttpSession->cTypeRequest 	:= "P"       //Vida Funcional - Programacao de Ferias e Licenca
		HttpGet->titulo               := STR0001  //Solicitacao de Ferias e Licenca Premio
       HttpSession->c530Solic       := "0"      //tipo da solicitacao - 1=Ferias / 2=Licenca Premio
		HttpSession->cIDMENU		:= "GFP"	
		cHtml := ExecInPage("PWSA532")
	WEB EXTENDED END
Return cHtml  

/*******************************************************************
* Funcao: PWSA530A
* Autor: Marcelo faria
* Data: 10/10/2013
* Gestão Publica - Solicitacao de Programação de Férias
* Função Principal
********************************************************************/
Web Function PWSA530A()
    Local cHtml     := ""
    Local oParam    := Nil

    WEB EXTENDED INIT cHtml START "InSite"                
        HttpSession->cTypeRequest   := "P"       //Vida Funcional - Programacao de Ferias e Licenca
        HttpGet->titulo               := STR0001  //Solicitacao de Ferias e Licenca Premio
        HttpSession->aStructure     := {}
        HttpSession->cHierarquia    := ""
        HttpSession->c530Solic      := HttpPost->op530Solic  //tipo da solicitacao - 1=Ferias / 2=Licenca Premio
        
        oParam  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
        WsChgURL(@oParam,"CFGDICTIONARY.APW")

        fGetInfRotina("W_PWSA530.APW")
        GetMat()                              //Pega a Matricula e a filial do participante logado

        cHtml := ExecInPage("PWSA120A")
    WEB EXTENDED END
Return cHtml  


/*******************************************************************
* Funcao: PWSA531
* Autor: Marcelo faria
* Data: 10/10/2013
* Gestão Publica - Consulta Solicitacao Programação de Férias
********************************************************************/
Web Function PWSA531()
Local cHtml    := ""
Local nIndice  := 0

Local oObj 
Local oTab 
Local oRequest
 HttpCTType("text/html; charset=ISO-8859-1")
  If (HttpGet->nOperacao == "1")
      If(valtype(HttpGet->nIndice) != "U")
         nIndice := val(HttpGet->nIndice) 
      endif
  ElseIf (HttpGet->nOperacao $ "3*4")
      If(valtype(HttpGet->nIndiceSolic) != "U")
         nIndice := val(HttpGet->nIndiceSolic) 
      endif
  EndIf   


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
       oObj:cTypeOfSolic  := "P"
       If HttpSession->c530Solic == "1" //Ferias
          oObj:nTypeOfProg  := 3
       Else
          oObj:nTypeOfProg  := 2
       EndIf
       
       HttpSession->aPeriodos := {}
       HttpSession->aPeriodosBKP := {}
       If oObj:GetPerAbert()     
           HttpSession->aPeriodos := oObj:oWSGetPerAbertResult:oWSListOfPeriod:oWSPeriodVacationProg
       EndIf
      
      If len(HttpSession->aPeriodos) > 0   
       //Busca tabela padrao de programacao
       HttpSession->aTabS107  :=  {}
		HttpSession->aPeriodosBKP := Aclone(HttpSession->aPeriodos)
       oTab := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFVacation"), WSRHVDFVacation():New())
       WsChgURL(@oTab,"RHVDFVACATION.APW")  
       oTab:cRetTable := 'S107'

       If HttpSession->c530Solic == "1" //Ferias
           If (HttpSession->aStructure[nIndice]:cCatFunc == "0") .or. (HttpSession->aStructure[nIndice]:cCatFunc == "1")
               If HttpSession->aPeriodos[1]:cIdCode == "0072"  
                  oTab:cTypeProg := '2' //Ferias ordinarias de membro
               Else
                  oTab:cTypeProg := '4' //Ferias compensatorias de membro                    
               EndIf              
           Else
              oTab:cTypeProg := '3'     //Ferias regulamentares de servidor
           EndIf
       ElseIf HttpSession->c530Solic == "2" //Licenca Premio
           oTab:cTypeProg := '1'
       EndIf 
    
       If oTab:GetTable()
           HttpSession->aTabS107 := oTab:oWSGETTABLERESULT:oWSLISTOFS107
       EndIf

       //Busca tabela padrao de programacao
       HttpSession->nDiasSubst :=  9999
       If HttpSession->FuncSubst .and. Len(HttpSession->aPeriodos) > 0
           oTab:cIDBase := HttpSession->aPeriodos[1]:cIdBase
           If oTab:GetSubstituteDays()
              HttpSession->nDiasSubst := oTab:NGETSUBSTITUTEDAYSRESULT
           EndIf
       EndIf
      EndIf

   ElseIf (HttpGet->nOperacao == "3") .Or. (HttpGet->nOperacao == "4")

		oRequest					           := HttpSession->oRequests[val(HttpGet->nIndiceSolic)]
		oVacation    				           := WSClassNew("RHVDFVacation_TVDFVacation")
        
        oVacation:cDescription             := PegaValores(oRequest,"TMP_DESC")
        oVacation:cTable                    := PegaValores(oRequest,"TMP_TABELA")
        oVacation:cSequence                 := PegaValores(oRequest,"TMP_SEQ")
        oVacation:cProgramer                := PegaValores(oRequest,"TMP_TIPO")
        oVacation:cCode                      := PegaValores(oRequest,"TMP_COD")

        oVacation:cAllowanceID              := PegaValores(oRequest,"TMP_PD")
        oVacation:cInitialBaseDate         := PegaValores(oRequest,"TMP_DTBINI")
        oVacation:cFinalBaseDate           := PegaValores(oRequest,"TMP_DTBFIM")
        oVacation:cOpportuneDays           := PegaValores(oRequest,"TMP_DOPORT")
        oVacation:cBonusDays                := PegaValores(oRequest,"TMP_DABONO")

        oVacation:cDaysofFirstPeriod       := PegaValores(oRequest,"TMP_DPER1")
        oVacation:cDaysofSecondPeriod      := PegaValores(oRequest,"TMP_DPER2")
		
		oVacation:cFirstInitialDate        := PegaValores(oRequest,"TMP_DTINI1")
        oVacation:cFirstFinalDate          := PegaValores(oRequest,"TMP_DTFIM1")
        oVacation:cFirstSubsEmployeeFil   := PegaValores(oRequest,"TMP_FSUB1")
        oVacation:cFirstSubsRegistration  := PegaValores(oRequest,"TMP_MSUB1")
        oVacation:cFirstSubsName           := PegaValores(oRequest,"TMP_NSUB1")

        oVacation:cSecondInitialDate       := PegaValores(oRequest,"TMP_DTINI2")
        oVacation:cSecondFinalDate         := PegaValores(oRequest,"TMP_DTFIM2")
        oVacation:cSecondSubsEmployeeFil  := PegaValores(oRequest,"TMP_FSUB2")
        oVacation:cSecondSubsRegistration := PegaValores(oRequest,"TMP_MSUB2")
        oVacation:cSecondSubsName          := PegaValores(oRequest,"TMP_NSUB2")

        //Busca tabela
        oTab := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFVacation"), WSRHVDFVacation():New())
        WsChgURL(@oTab,"RHVDFVACATION.APW")
        oTab:cRetTable  := oVacation:cTable
        oTab:cTypeProg  := oVacation:cProgramer
        oTab:cCodeTable := oVacation:cCode

        If oTab:GetTable()
            If len(oTab:oWSGETTABLERESULT:oWSLISTOFS107:OWSTABS107) > 0
                HttpPost->VDFOpDesc := oTab:oWSGETTABLERESULT:oWSLISTOFS107:OWSTABS107[1]:COPTIONDESC
            Else
                HttpPost->VDFOpDesc := STR0005  //Sequencia nao localizada na tabela!
            EndIf    
        Else 
            HttpPost->VDFOpDesc     := STR0006  //Tabela nao localizada!
        EndIf
		
		HttpPost->VDFFerias   	   := oVacation
   EndIf
   cHtml := ExecInPage( "PWSA531" )
	
WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA532
* Autor: Marcelo faria
* Data: 30/10/2013
* Gestão Publica - Programação de Férias - Gravacao
********************************************************************/
Web Function PWSA532()
Local cHtml   	  := ""
Local oWKF    
Local oOrg    
Local oOrg2    
Local cRetorno  := ""
Local cWKFAPV   := "" 
Local nOperacao := HttpPost->nOperacao

WEB EXTENDED INIT cHtml START "InSite"
              
	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFVacation"), WSRHVDFVacation():New())
	WsChgURL(@oOrg,"RHVDFVACATION.APW")
    
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
	   oOrg:oWSREQUEST:cOBSERVATION    	    	:= FwCutOff(Alltrim(HttpPost->txtobs))

       //busca workflow do item de menu de acordo com o perfil montado do usuario
       cWKFAPV                                     := alltrim(fGetWorkflow("RHVDFVACATION"))
      
       oOrg:oWSREQUEST:cWFAprov                  := cWKFAPV                        //Gestao Publica - Workflow da solicitacao
       oOrg:oWSREQUEST:cWFStage                  := ""                              //Gestao Publica - Etapa do Workflow
       If cWKFAPV != ""
          oOrg:oWSREQUEST:cWFStage               := "001"                           //Gestao Publica - Etapa do Workflow

          //Recupera aprovador da primeira etapa do workflow para gestao publica
          oWKF := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFJOURNEY"), WSRHVDFJOURNEY():New())
          WsChgURL(@oWKF,"RHVDFJourney.APW")

          oWKF:cEMPLOYEEFIL                          := HttpPost->cFilFun
          oWKF:cREGISTRATION                         := HttpPost->cMatFun
          oWKF:cStarterBranch                        := HttpSession->aUser[2]
          oWKF:cStarterRegistration                 := HttpSession->aUser[3]
          oWKF:cWorkflow                              := cWKFAPV
          oWKF:cStage                                 := "001"
          oWKF:lCompensate                           := .F.
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


       //Carrega Objeto da solicitacao de programacao
       If HttpSession->c530Solic == "1" 
          oOrg:oWSVDFVACATIONREQUEST:cDescription             := STR0007  //Programacao de ferias
       Else
          oOrg:oWSVDFVACATIONREQUEST:cDescription             := STR0008  //Programacao de licenca premio
       EndIf

       oOrg:oWSVDFVACATIONREQUEST:cTable                       := 'S107'
       oOrg:oWSVDFVACATIONREQUEST:cProgramer                  := substr(HttpPost->opcaoS107,9,1)
       oOrg:oWSVDFVACATIONREQUEST:cCode                        := alltrim(substr(HttpPost->opcaoS107,10,2))
       oOrg:oWSVDFVACATIONREQUEST:cSequence                   := substr(HttpPost->opcaoS107,12,3)

       oOrg:oWSVDFVACATIONREQUEST:cDaysofFirstPeriod         := substr(HttpPost->opcaoS107,0,2)
       oOrg:oWSVDFVACATIONREQUEST:cDaysofSecondPeriod        := substr(HttpPost->opcaoS107,3,2)
       oOrg:oWSVDFVACATIONREQUEST:cBonusDays                  := substr(HttpPost->opcaoS107,5,2)
       oOrg:oWSVDFVACATIONREQUEST:cOpportuneDays              := substr(HttpPost->opcaoS107,7,2)
	If Valtype(HttpSession->aPeriodos) == "C"
		HttpSession->aPeriodos:= aClone(HttpSession->aPeriodosBKP)
	EndIf
       oOrg:oWSVDFVACATIONREQUEST:cAllowanceID                := HttpSession->aPeriodos[1]:cIDBase
       oOrg:oWSVDFVACATIONREQUEST:cInitialBaseDate           := HttpSession->aPeriodos[1]:cInitialDate
       oOrg:oWSVDFVACATIONREQUEST:cFinalBaseDate             := HttpSession->aPeriodos[1]:cFinalDate

       IF substr(HttpPost->opcaoS107,0,2) <> "00"  
          oOrg:oWSVDFVACATIONREQUEST:cFirstInitialDate        := HttpPost->txtDtIni01
          oOrg:oWSVDFVACATIONREQUEST:cFirstFinalDate          := HttpPost->txtDtFim01
          IF HttpPost->txtMatFil1 <> ""
             oOrg:oWSVDFVACATIONREQUEST:cFirstSubsEmployeeFil := HttpPost->txtMatFil1
          Else   
             oOrg:oWSVDFVACATIONREQUEST:cFirstSubsEmployeeFil := HttpSession->aUser[2]
          EndIf   
          oOrg:oWSVDFVACATIONREQUEST:cFirstSubsRegistration  := HttpPost->txtMatSubst1
          oOrg:oWSVDFVACATIONREQUEST:cFirstSubsName           := HttpPost->txtNomeSubst1
       Else 
          oOrg:oWSVDFVACATIONREQUEST:cFirstInitialDate        := ""
          oOrg:oWSVDFVACATIONREQUEST:cfirstFinalDate          := ""
          oOrg:oWSVDFVACATIONREQUEST:cFirstSubsEmployeeFil   := ""
          oOrg:oWSVDFVACATIONREQUEST:cFirstSubsRegistration  := ""
          oOrg:oWSVDFVACATIONREQUEST:cFirstSubsName           := ""
       EndIf
       
       IF substr(HttpPost->opcaoS107,3,2) <> "00"
          oOrg:oWSVDFVACATIONREQUEST:cSecondInitialDate        := HttpPost->txtDtIni02
          oOrg:oWSVDFVACATIONREQUEST:cSecondFinalDate          := HttpPost->txtDtFim02
          IF HttpPost->txtMatFil2 <> ""
             oOrg:oWSVDFVACATIONREQUEST:cSecondSubsEmployeeFil := HttpPost->txtMatFil2
          Else   
             oOrg:oWSVDFVACATIONREQUEST:cSecondSubsEmployeeFil := HttpSession->aUser[2]
          EndIf   
          oOrg:oWSVDFVACATIONREQUEST:cSecondSubsRegistration  := HttpPost->txtMatSubst2
          oOrg:oWSVDFVACATIONREQUEST:cSecondSubsName           := HttpPost->txtNomeSubst2
       Else
          oOrg:oWSVDFVACATIONREQUEST:cSecondInitialDate        := ""
          oOrg:oWSVDFVACATIONREQUEST:cSecondFinalDate          := ""
          oOrg:oWSVDFVACATIONREQUEST:cSecondSubsEmployeeFil   := ""
          oOrg:oWSVDFVACATIONREQUEST:cSecondSubsRegistration  := ""
          oOrg:oWSVDFVACATIONREQUEST:cSecondSubsName           := ""
       EndIf

	   If oOrg:ADDVDFVACATIONREQUEST()
		  cRetorno       := oOrg:cADDVDFVACATIONREQUESTRESULT
		  HttpGet->msg  := STR0002  //"operacao realizada com sucesso"
			
		  If(nOperacao == "4")
			  W_PWSA115()
	      Else 
		      W_PWSA530A()
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
* Funcao: PWSA533
* Autor: Marcelo Faria
* Data: 04/11/2013
* Gestão Publica - Programação de Férias - Aprovação
********************************************************************/
Web Function PWSA533()
Local cHtml    	:= ""
Local nIndice     := HttpSession->nIndiceSolic
Local nOperacao   := HttpSession->nOperacao
Local nNovaEtapa  := 0
Local lOk          := .T.
Local cErro        := ""
Local Cod          := HttpPost->txtcod
Local oObj    
Local oOrg    

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
	   	HttpGet->msg := STR0003 //"Aprovacao Gravada com sucesso"
	      	
	    If(nOperacao == "4")
		    W_PWSA115()
		Else 
	        W_PWSA530A()
	    EndIf
	Else
		HttpSession->_HTMLERRO := {STR0001, cErro, "W_PWSA00C.APW"}		//"Erro" 
		Return ExecInPage("PWSAMSG" )
	EndIf 
	
WEB EXTENDED END

Return cHtml 


/*******************************************************************
* Funcao: PWSA534
* Autor: Marcelo Faria
* Data: 04/11/2013
* Gestão Publica - Programação de Férias - Reprovação
********************************************************************/
Web Function PWSA534()
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
		        W_PWSA530A()
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


/*******************************************************************
* Funcao: PWSA535
* Autor: Marcelo Faria
* Data: 22/10/2013
* Gestão Publica - Programação de Férias - Valida Substituto
********************************************************************/
Web Function PWSA535()
Local oObj 
Local cHtml       := "*1"

    HttpCTType("text/html; charset=ISO-8859-1")
    
    WEB EXTENDED INIT cHtml 

         //Realiza avaliação do substituto
         oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFVacation"), WSRHVDFVacation():New())
         WsChgURL(@oObj,"RHVDFVACATION.APW")  

         If HttpGet->filial <> ""
            oObj:cVacEmployeeFil  := HttpGet->filial
         Else
            oObj:cVacEmployeeFil  := HttpSession->aUser[2]
         EndIf   
         oObj:cVacRegistration    := HttpGet->matricula
         oObj:cStartDate           := HttpGet->dtini
         oObj:cFinalDate           := HttpGet->dtfim
         If oObj:EvalSubstitute()
            cHTML := oObj:cEvalSubstituteResult
         EndIf

    WEB EXTENDED END
RETURN cHtml

/*******************************************************************
* Funcao: PWSA536
* Autor: Marcelo Faria
* Data: 22/10/2013
* Gestão Publica - Avaliações Dinâmicas
********************************************************************/
Web Function PWSA536()
Local cHtml      := "*0"
Local cLicSubst := ""
Local oTab
Local data1
Local data2
   HttpCTType("text/html; charset=ISO-8859-1")
    WEB EXTENDED INIT cHtml 
		If Valtype(HttpSession->aPeriodos) == "C"
			HttpSession->aPeriodos:= aClone(HttpSession->aPeriodosBKP)
		EndIf
        IF HttpGet->tipoVal == '1'
            //Validacao de datas de periodo aquisito
            IF len(HttpSession->aPeriodos) > 0
               data1 := StoD('20' + SubStr(HttpSession->aPeriodos[1]:cFinalDate,7,2) + SubStr(HttpSession->aPeriodos[1]:cFinalDate,4,2) + SubStr(HttpSession->aPeriodos[1]:cFinalDate,1,2))
               data2 := StoD(SubStr(HttpGet->dtPer,7,4) + SubStr(HttpGet->dtPer,4,2) + SubStr(HttpGet->dtPer,1,2))

               If data1 >= data2
                  cHtml := "*1"
               EndIf
            EndIf
        EndIf     

        IF HttpGet->tipoVal == '2'
            If HttpSession->FuncSubst
               cHtml := '.T.'
            else
               cHtml := '.F.'
            EndIf               
        EndIf

        IF HttpGet->tipoVal == '3'
            cHtml := alltrim(str(HttpSession->nDiasSubst))
        EndIf

        IF HttpGet->tipoVal == '4'
            cHtml := alltrim(HttpSession->MatSolic)
        EndIf

        //*******************************************************************************************
        //Licencas e Afastamentos - Atualiza dados da licenca selecionada
        IF HttpGet->tipoVal == '5'
           If alltrim(HttpSession->aLicencas:OWSITEMSOFLICENCE:OWSDATALICENCE[val(HttpGet->indice)]:CSUBSTTYPE) == '1'
              HttpSession->lLicSubst := .T.
              cLicSubst := '.T.'
           Else 
              HttpSession->lLicSubst := .F.
              cLicSubst := '.F.'
           EndIf
              
           //Tipo do dia
            cHtml :=  alltrim(HttpSession->aLicencas:OWSITEMSOFLICENCE:OWSDATALICENCE[val(HttpGet->indice)]:CDAYSTYPE) +'*';
                      +alltrim(HttpSession->aLicencas:OWSITEMSOFLICENCE:OWSDATALICENCE[val(HttpGet->indice)]:CDAYSTYPEDESC) +'*';
                      +alltrim(str(HttpSession->aLicencas:OWSITEMSOFLICENCE:OWSDATALICENCE[val(HttpGet->indice)]:NABSENSEDAYS))+'*';
                      +alltrim(str(HttpSession->aLicencas:OWSITEMSOFLICENCE:OWSDATALICENCE[val(HttpGet->indice)]:NSUBSTDAYS)) +'*';
                      +alltrim(HttpSession->aLicencas:OWSITEMSOFLICENCE:OWSDATALICENCE[val(HttpGet->indice)]:CSUBSTTYPEDESC) +'*';
                      +alltrim(HttpSession->aLicencas:OWSITEMSOFLICENCE:OWSDATALICENCE[val(HttpGet->indice)]:CLICENCE)        +'*';
                      +cLicSubst+"*";
                      +alltrim(str(HttpSession->aLicencas:OWSITEMSOFLICENCE:OWSDATALICENCE[val(HttpGet->indice)]:NDiasAfast))
	
        EndIf
        //*******************************************************************************************


        //*******************************************************************************************
        //Saldo de Dias 
        IF HttpGet->tipoVal == '6' //Atualiza dias disponiveis da opção selecionada
            HttpSession->nTotDias := HttpSession->aDaysSolic[val(HttpGet->indice)][2]
        EndIf

        IF HttpGet->tipoVal == '7' //Valida Dias
            cHtml := ""

            If val(HttpGet->indice) > HttpSession->nTotDias
               cHtml := STR0009 +alltrim(str(HttpSession->nTotDias)) //"Esse valor nao pode ser superior a: "
            EndIf
        EndIf

        IF HttpGet->tipoVal == '8' //Busca dias substituto para a verba do período aquisito do dias de folga
            cHtml := ""

           //Busca tabela padrao de programacao
           HttpSession->nDiasSubst :=  9999

           If (HttpSession->FuncSubst .and. HttpSession->aPeriodos[val(HttpGet->indice)][1]:cIdBase != '')
               oTab := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFVacation"), WSRHVDFVacation():New())
               WsChgURL(@oTab,"RHVDFVACATION.APW")
    
               oTab:cIDBase := HttpSession->aPeriodos[val(HttpGet->indice)][1]:cIdBase
               If oTab:GetSubstituteDays()
                  HttpSession->nDiasSubst := oTab:NGETSUBSTITUTEDAYSRESULT
               EndIf
           EndIf

        EndIf
        //*******************************************************************************************


    WEB EXTENDED END
RETURN cHtml


/*******************************************************************
* Funcao: PWSA537
* Autor: Marcelo Faria
* Data: 26/05/2014
* Gestão Publica - Programação de Férias - Valida indenizacao
********************************************************************/
Web Function PWSA537()
Local cHtml := ""
Local oProg 
    
    WEB EXTENDED INIT cHtml
	If Valtype(HttpSession->aPeriodos) == "C"
		HttpSession->aPeriodos:= aClone(HttpSession->aPeriodosBKP)
	EndIf
        //Valida Indenização
        oProg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFBalanceVacation"), WSRHVDFBalanceVacation():New())
        WsChgURL(@oProg,"RHVDFBALANCEVACATION.APW")

        oProg:cEmployeeFil  := HttpSession->DadosFunc:CEMPLOYEEFILIAL
        oProg:cRegistration := HttpSession->DadosFunc:CREGISTRATION
        oProg:cPD            := HttpSession->aPeriodos[1]:cIDBASE
        oProg:cDaysAllow    := HttpGet->DiasIndeniz 
        oProg:cInitialDate  := HttpGet->DataInicio
        oProg:cTypeSolic    := "P" 

        If oProg:CheckAllow()
           cHtml := oProg:cCHECKALLOWRESULT
        EndIf
    
    WEB EXTENDED END
RETURN cHtml
