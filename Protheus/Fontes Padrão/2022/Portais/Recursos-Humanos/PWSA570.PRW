#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH" 
#INCLUDE "PWSA570.CH"


/*******************************************************************
* Funcao: PWSA570
* Autor: Marcelo faria
* Data: 11/16/2014
* Gestão Publica - Avaliação de Saldo de Dias de Folga
********************************************************************/
Web Function PWSA570()
    Local cHtml     := ""

    WEB EXTENDED INIT cHtml START "InSite"
        HttpSession->cTypeRequest   := "T"       //Vida Funcional - Saldo de Dias de Folga
        HttpGet->titulo               := STR0001  //Solicitação de Saldo de Dias de Folga
        HttpSession->c570Solic       := "0"      //tipo da solicitacao - 1=Programacao / 2=Cancelamento ou Retificacao
		HttpSession->cIDMENU		:= "GFP"	
        cHtml := ExecInPage("PWSA572")
    WEB EXTENDED END
Return cHtml  

/*******************************************************************
* Funcao: PWSA570A
* Autor: Marcelo faria
* Data: 12/11/2013
* Gestão Publica - Avaliação de Saldo de Dias de Folga
********************************************************************/
Web Function PWSA570A()
	Local cHtml   	:= ""
	Local oParam  	:= Nil
	HttpCTType("text/html; charset=ISO-8859-1")
	
	WEB EXTENDED INIT cHtml START "InSite"	              
		HttpSession->cTypeRequest 	 := "T"       //Vida Funcional - Saldo de Dias de Folga
		HttpGet->titulo              := STR0001  //Solicitação de Saldo de Dias de Folga
       HttpSession->c570Solic       := HttpPost->op570Solic  //tipo da solicitacao - 1=Programacao / 2=Cancelamento ou Retificacao
       HttpSession->nTotDias        := 0
       HttpSession->aDaysSolic      := {}
       HttpSession->aPeriodos       := {}
		HttpSession->aStructure	   	 := {}
		HttpSession->cHierarquia	     := ""
		
		oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		WsChgURL(@oParam,"CFGDICTIONARY.APW")

		fGetInfRotina("W_PWSA570.APW")
		GetMat()                              //Pega a Matricula e a filial do participante logado

		cHtml := ExecInPage("PWSA120A")
	WEB EXTENDED END
Return cHtml  


/*******************************************************************
* Funcao: PWSA571
* Autor: Marcelo faria
* Data: 12/11/2013
* Gestão Publica - Consulta Avaliação de Saldo de Dias de Folga
********************************************************************/
Web Function PWSA571()
Local nI             := 1
Local cHtml          := ""
Local nIndice        := 0
Local nPos           := 0
Local nReg           := 0
Local nQtdeDiasSolic := 0
Local nQtdeDiasCalc  := 0
Local aDaysSolic     := {}
Local aPlanned       := {}

Local oProg 
Local oObj 
Local oTab 
Local oTemp
Local oRequest
Local oFerias
Local oWSFerProg

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
       oObj:nTypeOfProg   := 1 //Dias de Folga-> Registros da SRF com verbas sem ID

       HttpSession->aPeriodos := {}
       If oObj:GetPerAbert()     
           HttpSession->nQtdeProg := 0
           oTemp := oObj:oWSGetPerAbertResult:oWSListOfPeriod:oWSPeriodVacationProg

           //Verifica as programações de solicitações RH3/RH4
           oProg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFBalanceVacation"), WSRHVDFBalanceVacation():New())
           WsChgURL(@oProg,"RHVDFBALANCEVACATION.APW")
           
           For nReg := 1 to Len(oTemp)
               oProg:cEmployeeFil  := oTemp[nReg]:cEmployeeFilial
               oProg:cRegistration := oTemp[nReg]:cRegistration
               oProg:cPD           := oTemp[nReg]:cIDBase
               oProg:cTypeSolic    := "T"
               oProg:cStatusSolic  := "145"
               oProg:cInitialDate  := oTemp[nReg]:cInitialDate
               oProg:cFinalDate    := oTemp[nReg]:cFinalDate

               aPlanned       := {}
               nQtdeDiasSolic := 0
               nQtdeDiasCalc  := 0
                
               If oProg:GetSolicPlanned()
                  aPlanned := oProg:oWSGetSolicPlannedResult:OWSITEMSOFSOLIC

                   If len(aPlanned:OWSDATASOLIC) > 0
                       For nPos := 1 to Len(aPlanned:OWSDATASOLIC)
                           nQtdeDiasSolic += aPlanned:OWSDATASOLIC[nPos]:nSolicDays
                       Next nPos
                   EndIf
               EndIf

               //Calcula dias disponíveis para o período aquisito
               nQtdeDiasCalc := (oTemp[nReg]:nDays - oTemp[nReg]:nScheduleDays - nQtdeDiasSolic) + oTemp[nReg]:nResidualDays
               Aadd(aDaysSolic,{nQtdeDiasSolic, nQtdeDiasCalc})
           Next nReg
           HttpSession->aDaysSolic := aDaysSolic


           For nPos := 1 to len(oTemp)
               aPlanned := {}

               //Caso Retificacao ou Cancelamento, busca programacoes realizadas
               If HttpSession->c570Solic == "2"
                   oProg:cTypeSolic    := "O" 
                   oProg:cEmployeeFil  := oObj:oWSGetPerAbertResult:oWSListOfPeriod:oWSPeriodVacationProg[nPos]:cEmployeeFilial
                   oProg:cRegistration := oObj:oWSGetPerAbertResult:oWSListOfPeriod:oWSPeriodVacationProg[nPos]:cRegistration
                   oProg:cPD           := oObj:oWSGetPerAbertResult:oWSListOfPeriod:oWSPeriodVacationProg[nPos]:cIDBase
                   oProg:cInitialDate  := alltrim(str(Year(CTOD(oObj:oWSGetPerAbertResult:oWSListOfPeriod:oWSPeriodVacationProg[nPos]:cInitialDate))) + ;
                                          SUBSTR(oObj:oWSGetPerAbertResult:oWSListOfPeriod:oWSPeriodVacationProg[nPos]:cInitialDate, 4, 2) + ; 
                                          Left(oObj:oWSGetPerAbertResult:oWSListOfPeriod:oWSPeriodVacationProg[nPos]:cInitialDate, 2))
 						
                   If oProg:GetPerPlanned()
                      aPlanned := oProg:oWSGetPerPlannedResult:OWSITEMSOFPLAN
                   EndIf
               EndIf
               
               If HttpSession->FuncSubst
					oTab := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFVacation"), WSRHVDFVacation():New())
	   				WsChgURL(@oTab,"RHVDFVACATION.APW")
	   			
	   				oTab:cIDBase := oTemp[npos]:cIdBase
	       		If oTab:GetSubstituteDays()
	          			oTemp[npos]:cMinDaysSubst := oTab:NGETSUBSTITUTEDAYSRESULT
	       		EndIf
	   			EndIf
                      
               AAdd( HttpSession->aPeriodos, {oTemp[npos] , aPlanned } )
           Next nPos
       EndIf
       
   ElseIf (HttpGet->nOperacao == "3") .Or. (HttpGet->nOperacao == "4")
		 oRequest					           := HttpSession->oRequests[val(HttpGet->nIndiceSolic)]
		 oVacation   				           := WSClassNew("RHVDFVacation_TVDFVacation")
        
        oVacation:cTypeDescSolic          := PegaValores(oRequest,"TMP_DESC")

        oVacation:cDaysofFirstPeriod      := PegaValores(oRequest,"TMP_DPER1")
        oVacation:cBonusDays              := PegaValores(oRequest,"TMP_DABONO")

        oVacation:cFirstInitialDate       := PegaValores(oRequest,"TMP_DTINI1")
        oVacation:cFirstFinalDate         := PegaValores(oRequest,"TMP_DTFIM1")
        oVacation:cFirstSubsEmployeeFil   := PegaValores(oRequest,"TMP_FSUB1")
        oVacation:cFirstSubsRegistration  := PegaValores(oRequest,"TMP_MSUB1")
        oVacation:cFirstSubsName          := PegaValores(oRequest,"TMP_NSUB1")
    	 oVacation:cDescription				:= PegaValores(oRequest,"TMP_PDDESC")
    	 
    	 oVacation:cInitialBaseDate			:= PegaValores(oRequest,"TMP_DTBINI")
    	 oVacation:cFinalBaseDate			:= PegaValores(oRequest,"TMP_DTBFIM")
    	 
		HttpPost->VDFDaysOff       	      := oVacation
   EndIf

   cHtml := ExecInPage( "PWSA571" )
	
WEB EXTENDED END

Return cHtml


/*******************************************************************
* Funcao: PWSA572
* Autor: Marcelo faria
* Data: 20/11/2013
* Gestão Publica - Avaliação de Saldo de Dias de Folga - Gravacao
********************************************************************/
Web Function PWSA572()
Local cHtml   	  := ""
Local nReg       := 0
Local nRegPlan  := 0
Local cRetorno  := ""
Local cWKFAPV   := "" 
Local nOperacao := HttpPost->nOperacao
Local oWKF    
Local oOrg    
Local oOrg2    
HttpCTType("text/html; charset=ISO-8859-1")
WEB EXTENDED INIT cHtml START "InSite"
              
	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFDAYSOFF"), WSRHVDFDAYSOFF():New())
	WsChgURL(@oOrg,"RHVDFDAYSOFF.APW")
    
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
       oOrg:oWSREQUEST:cStarterBranch            := HttpSession->aUser[2] //Filial do solicitante
       oOrg:oWSREQUEST:cSTARTERREGISTRATION      := HttpSession->aUser[3] //Matricula do solicitante
	   oOrg:oWSREQUEST:cBRANCH 				       := HttpPost->cFilFun    
	   oOrg:oWSREQUEST:cREGISTRATION 			    := HttpPost->cMatFun    
	   oOrg:oWSREQUEST:cVISION 				       := ""                    //Gestao Publica nao usa o conceito de visao do SIGAORG
	   oOrg:oWSREQUEST:cOBSERVATION    	    	:= Alltrim(HttpPost->txtobs)

       //busca workflow do item de menu de acordo com o perfil montado do usuario
       cWKFAPV                                   := alltrim(fGetWorkflow("RHVDFDAYSOFF"))
      
       oOrg:oWSREQUEST:cWFAprov                  := cWKFAPV                        //Gestao Publica - Workflow da solicitacao
       oOrg:oWSREQUEST:cWFStage                  := ""                             //Gestao Publica - Etapa do Workflow
       If cWKFAPV != ""  
          oOrg:oWSREQUEST:cWFStage               := "001"                          //Gestao Publica - Etapa do Workflow

          //Recupera aprovador da primeira etapa do workflow para gestao publica
          oWKF := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFJOURNEY"), WSRHVDFJOURNEY():New())
          WsChgURL(@oWKF,"RHVDFJourney.APW")

          oWKF:cEMPLOYEEFIL                      := HttpPost->cFilFun
          oWKF:cREGISTRATION                     := HttpPost->cMatFun
          oWKF:cWorkflow                         := cWKFAPV
          oWKF:cStage                            := "001"

          oWKF:cStarterBranch                    := HttpSession->aUser[2]
          oWKF:cStarterRegistration              := HttpSession->aUser[3]

          IF alltrim(HttpPost->tipoOpSolic) == "Programado"
             oWKF:lCompensate                    := .F.
          Else
             oWKF:lCompensate                    := .T.
          EndIf           

          If oWKF:GetWorkflowStage()
             oOrg:oWSREQUEST:cApproverBranch        := oWKF:OWSGetWorkflowStageRESULT:cResponsibleFil
             oOrg:oWSREQUEST:cApproverRegistration  := oWKF:OWSGetWorkflowStageRESULT:cResponsibleReg
             oOrg:oWSREQUEST:nApproverLevel         := val(oWKF:OWSGetWorkflowStageRESULT:cApproverLevel)

             IF alltrim(HttpPost->tipoOpSolic) == "Indenizado"
                oOrg:oWSREQUEST:cWFStage            := oWKF:OWSGetWorkflowStageRESULT:cStage
                oOrg:oWSREQUEST:nApproverLevel      := val(oWKF:OWSGetWorkflowStageRESULT:cApproverLevel)
             EndIf
          Else  
            HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" } //"Erro"
            Return ExecInPage("PWSAMSG" )
          EndIf  
       Else  
          oOrg:oWSREQUEST:cApproverBranch          := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
          oOrg:oWSREQUEST:cApproverRegistration    := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
          oOrg:oWSREQUEST:nApproverLevel           := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
       EndIF


       //Programacao ou Indenizacao do Saldo de Dias de Folga
       If HttpSession->c570Solic == "1"
           //Carrega Objetos da solicitacao
           oOrg:oWSVDFVACATIONREQUEST:cAllowanceID                := HttpSession->aPeriodos[val(HttpPost->opProg)][1]:cIDBase
           oOrg:oWSVDFVACATIONREQUEST:cInitialBaseDate            := HttpSession->aPeriodos[val(HttpPost->opProg)][1]:cInitialDate
           oOrg:oWSVDFVACATIONREQUEST:cFinalBaseDate              := HttpSession->aPeriodos[val(HttpPost->opProg)][1]:cFinalDate
           oOrg:oWSVDFVACATIONREQUEST:cTypeDescSolic              := ""
           oOrg:oWSVDFVACATIONREQUEST:cIDPublication              := ""
           oOrg:oWSVDFVACATIONREQUEST:cRI6Key                     := ""
           oOrg:oWSVDFVACATIONREQUEST:nRegID                      := 0
    
           IF alltrim(HttpPost->tipoOpSolic) == "Programado"  
              oOrg:oWSVDFVACATIONREQUEST:cCode                    := "1"
              oOrg:oWSVDFVACATIONREQUEST:cTypeDescSolic           := STR0007 +' ' +STR0009 //"PROGRAMACAO DIAS DE FOLGA"
              oOrg:oWSVDFVACATIONREQUEST:cDaysofFirstPeriod       := HttpPost->txtDias01
    
              oOrg:oWSVDFVACATIONREQUEST:cFirstInitialDate        := HttpPost->txtDtIni01
              oOrg:oWSVDFVACATIONREQUEST:cFirstFinalDate          := HttpPost->txtDtFim01
              IF HttpPost->txtMatFil1 <> ""
                 oOrg:oWSVDFVACATIONREQUEST:cFirstSubsEmployeeFil := HttpPost->txtMatFil1
              Else   
                 oOrg:oWSVDFVACATIONREQUEST:cFirstSubsEmployeeFil := HttpSession->aUser[2]
              EndIf   
              oOrg:oWSVDFVACATIONREQUEST:cFirstSubsRegistration   := HttpPost->txtMatSubst1
              oOrg:oWSVDFVACATIONREQUEST:cFirstSubsName           := HttpPost->txtNomeSubst1
           Else 
              //Dias indenizados
              oOrg:oWSVDFVACATIONREQUEST:cCode                    := "2"
              oOrg:oWSVDFVACATIONREQUEST:cTypeDescSolic           := STR0008 +' ' +STR0009 //"INDENIZACAO DIAS DE FOLGA"
              oOrg:oWSVDFVACATIONREQUEST:cBonusDays               := alltrim(str(HttpSession->aDaysSolic[val(HttpPost->opProg)][2]))

              oOrg:oWSVDFVACATIONREQUEST:cDaysofFirstPeriod       := ""
              oOrg:oWSVDFVACATIONREQUEST:cFirstInitialDate        := "01" +"/" +HttpPost->txtMes +"/" +HttpPost->txtAno
              oOrg:oWSVDFVACATIONREQUEST:cFirstFinalDate          := "01" +"/" +HttpPost->txtMes +"/" +HttpPost->txtAno
              oOrg:oWSVDFVACATIONREQUEST:cFirstSubsEmployeeFil    := ""
              oOrg:oWSVDFVACATIONREQUEST:cFirstSubsRegistration   := ""
              oOrg:oWSVDFVACATIONREQUEST:cFirstSubsName           := ""
           EndIf
    
           oOrg:oWSVDFVACATIONREQUEST:cTable                      := ""
           oOrg:oWSVDFVACATIONREQUEST:cSequence                   := ""
           oOrg:oWSVDFVACATIONREQUEST:cProgramer                  := ""
           
           oOrg:oWSVDFVACATIONREQUEST:cDaysofSecondPeriod         := ""
           oOrg:oWSVDFVACATIONREQUEST:cSecondInitialDate          := ""
           oOrg:oWSVDFVACATIONREQUEST:cSecondFinalDate            := ""
           oOrg:oWSVDFVACATIONREQUEST:cSecondSubsEmployeeFil      := ""
           oOrg:oWSVDFVACATIONREQUEST:cSecondSubsRegistration     := ""
           oOrg:oWSVDFVACATIONREQUEST:cSecondSubsName             := ""
       Else  
          //Retificacao ou cancelamento de programacao de Dias de Folga
           oOrg:oWSVDFVACATIONREQUEST:cTable                      := ""
           oOrg:oWSVDFVACATIONREQUEST:cSequence                   := ""
           oOrg:oWSVDFVACATIONREQUEST:cProgramer                  := ""

           oOrg:oWSVDFVACATIONREQUEST:cFirstInitialDate           := ""
           oOrg:oWSVDFVACATIONREQUEST:cFirstFinalDate             := ""
           oOrg:oWSVDFVACATIONREQUEST:cFirstSubsEmployeeFil       := ""
           oOrg:oWSVDFVACATIONREQUEST:cFirstSubsRegistration      := ""
           oOrg:oWSVDFVACATIONREQUEST:cFirstSubsName              := ""
           
           oOrg:oWSVDFVACATIONREQUEST:cDaysofSecondPeriod         := ""
           oOrg:oWSVDFVACATIONREQUEST:cSecondInitialDate          := ""
           oOrg:oWSVDFVACATIONREQUEST:cSecondFinalDate            := ""
           oOrg:oWSVDFVACATIONREQUEST:cSecondSubsEmployeeFil      := ""
           oOrg:oWSVDFVACATIONREQUEST:cSecondSubsRegistration     := ""
           oOrg:oWSVDFVACATIONREQUEST:cSecondSubsName             := ""

           For nReg := 1 to Len(HttpSession->aPeriodos) 
               For nRegPlan := 1 to Len(HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN)
    
                    //Seleciona opcao escolhida no portal
                    If alltrim(str(HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:nRegID)) == alltrim(HttpPost->opProg)

                       //Carrega Objeto da solicitacao do cancelamento ou retificacao dos dias de folga
                       oOrg:oWSVDFVACATIONREQUEST:cAllowanceID         := HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cIDBase

                       oOrg:oWSVDFVACATIONREQUEST:cInitialBaseDate    := Substr(HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cBaseDate,7,2) +"/" ;
                                                                               +Substr(HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cBaseDate,5,2) +"/" ;
                                                                               +Substr(HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cBaseDate,3,2)                                                                                
                       oOrg:oWSVDFVACATIONREQUEST:cFinalBaseDate      := ""

                       oOrg:oWSVDFVACATIONREQUEST:cFirstInitialDate   := Substr(HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cInitialDateProg,7,2) +"/" ; 
                                                                               +Substr(HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cInitialDateProg,5,2) +"/" ;
                                                                               +Substr(HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cInitialDateProg,1,4)
                       oOrg:oWSVDFVACATIONREQUEST:cFirstFinalDate     := Substr(HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cFinalDateProg,7,2) +"/" ; 
                                                                               +Substr(HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cFinalDateProg,5,2) +"/" ;
                                                                               +Substr(HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cFinalDateProg,1,4)

                       oOrg:oWSVDFVACATIONREQUEST:cDaysofFirstPeriod    := alltrim(str(HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:nProgDays))
                       oOrg:oWSVDFVACATIONREQUEST:cBonusDays            := alltrim(str(HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:nAllowDays))
    
                       If empty(HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cIDPublication)
                           oOrg:oWSVDFVACATIONREQUEST:cCode             := "3"
                           oOrg:oWSVDFVACATIONREQUEST:cTypeDescSolic    := STR0010 +' ' +STR0009 //"CANCELAMENTO DIAS DE FOLGA"                   
                       Else
                           oOrg:oWSVDFVACATIONREQUEST:cCode             := "4"
                           oOrg:oWSVDFVACATIONREQUEST:cTypeDescSolic    := STR0011 +' ' +STR0009 //"RETIFICAÇÃO DIAS DE FOLGA"
                       EndIf
                       
                       oOrg:oWSVDFVACATIONREQUEST:cIDPublication        := HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cIDPublication
                       oOrg:oWSVDFVACATIONREQUEST:cRI6Key               := HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:cRI6Key
                       oOrg:oWSVDFVACATIONREQUEST:nRegID                := HttpSession->aPeriodos[nReg][2]:OWSDATAPLAN[nRegPlan]:nRegID
                    EndIf
    
               Next nRegPlan
           Next nReg

       EndIf

	  If oOrg:ADDVDFDAYSOFFREQUEST()
		  cRetorno       := oOrg:cAddVDFDaysOffRequestRESULT
		  HttpGet->msg  := STR0002  //"operacao realizada com sucesso"
			
		  If(nOperacao == "4")
			  W_PWSA115()
	      Else 
		      W_PWSA570A()
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
* Funcao: PWSA573
* Autor: Marcelo Faria
* Data: 12/11/2013
* Gestão Publica - Avaliação de Saldo de Férias - Aprovação
********************************************************************/
Web Function PWSA573()
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
	        W_PWSA570A()
	    EndIf
	Else
		HttpSession->_HTMLERRO := {STR0001, cErro, "W_PWSA00C.APW"}		//"Erro" 
		Return ExecInPage("PWSAMSG" )
	EndIf 
	
WEB EXTENDED END

Return cHtml 


/*******************************************************************
* Funcao: PWSA574
* Autor: Marcelo Faria
* Data: 12/11/2013
* Gestão Publica - Avaliação de Saldo de Dias de Folga - Reprovação
********************************************************************/
Web Function PWSA574()
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
		        W_PWSA570A()
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
