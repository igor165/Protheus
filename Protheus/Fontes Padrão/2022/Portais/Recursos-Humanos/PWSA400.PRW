#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH" 
#INCLUDE "PWSA400.CH"

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍ³±±
±±³Data Fonte Sustentação³ ChangeSet ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ³±±  
±±³    11/06/2015        ³  307834   ³±± 
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍ±±
*/ 

/*******************************************************************
* Funcao: PWSA400
* Autor: Emerson Campos
* Data: 22/04/2014
* Solicitação de marcação de Ponto
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Uso       ³ RH/Portais                                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Analista        ³ Data       ³FNC:            ³  	Motivo da Alteracao                    ³±±
±±³Emerson Campos   |22/04/14    |M_RH003/310901  |Disponibilizado a nova opção de             ³±±
±±³                 |            |                |Solicitação Subsídio Acadêmico              ³±±
±±ºWillian U.       ³20/07/17    ³DRHPONTP-213    ³Melhoria no Ponto eletrônico de forma que   º±±
±±º                 ³            ³                ³seja possível bloquear o lançamento e       º±±
±±º                 ³            ³                ³manutenção de marcações para o fechamento   º±±
±±º                 ³            ³                ³mensal.                                     º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PWSA400()

	Local cHtml   	:= ""
	Local oParam  	:= Nil
	Local oWSAttendControl  := Nil
	Local cTela				:= "PWSA120A"
	
	HttpCTType("text/html; charset=ISO-8859-1")
	
	WEB EXTENDED INIT cHtml START "InSite"	              
		HttpSession->cTypeRequest 	:= "Z"			// Marcação de ponto via portal
		HttpGet->titulo           	:= STR0004 	//"Espelho de ponto"
		HttpSession->aStructure	   	:= {}
		HttpSession->cHierarquia	:= ""
		HttpSession->cDataIni		:= ""
		
		oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		WsChgURL(@oParam,"CFGDICTIONARY.APW")

		fGetInfRotina("W_PWSA400.APW")
		GetMat()								//Pega a Matricula e a filial do participante logado

	    oWSAttendControl := Iif(FindFunction("GetAuthWs"), GetAuthWs("WsRHAttendControl"), WsRHAttendControl():New())
	    WsChgURL(@oWSAttendControl, "RHAttendControl.APW")

	    // - --------------------------------------------------
	    // - Verifica se a DataBase vigente está dentro
	    // - do período liberado para manutenção de marcações.
	    // - --------------------------------------------------
	    If !(oWSAttendControl:GetPerBloq())
	    	HttpSession->_HTMLERRO := { STR0005, PorEncode(STR0013), "W_PWSA00C.APW" }// Atenção
			cTela	:= "PWSAMSG"
	    EndIf

		cHtml := ExecInPage(cTela)
	WEB EXTENDED END
Return cHtml  

/*******************************************************************
* Funcao: PWSA401
* Autor: Emerson Campos
* Data: 22/04/2014
* Solicitação de Controle de Ponto
********************************************************************/
Web Function PWSA401()

Local oWSAttendControl
Local cHtml   			:= ''
Local cTela				:= ''
Local nI					:= 1

Private nCurrentPage
Private nPageTotal	
Private aFilter			:= {}
Private aPeriods		:= {}
Private cPeriodView
Private cPerAponta
Private nTotMarc		:= 0
Private cIndice       	:= "1"

If ValType(HttpGet->nOperacao) == "U"
	HttpGet->nOperacao := "1"
	HttpGet->nIndice   := "1"
EndIf

If (HttpGet->nOperacao == "1")
	If(valtype(HttpGet->nIndice) != "U")
	   nIndice := val(HttpGet->nIndice)
	   HttpSession->nIndice := HttpGet->nIndice
	EndIf
ElseIf (HttpGet->nOperacao $ "3*4")
	If(valtype(HttpGet->nIndiceSolic) != "U")
	   nIndice := val(HttpGet->nIndiceSolic)
	   HttpSession->nIndice := HttpGet->nIndiceSolic 
	EndIf
EndIf

HttpCTType("text/html; charset=ISO-8859-1")

WEB EXTENDED INIT cHtml START "InSite"  
  	
	 //Pega filial e matricula do participante
    GetMat()   

	oWSAttendControl := Iif(FindFunction("GetAuthWs"), GetAuthWs("WsRHAttendControl"), WsRHAttendControl():New())
	WsChgURL(@oWSAttendControl, "RHAttendControl.APW")
    
   	If (HttpGet->nOperacao == "1") 
   		HttpSession->DadosFunc 				:= HttpSession->aStructure[nIndice]
		
		oWSAttendControl:cRegistration		:= HttpSession->DadosFunc:cRegistration  
		oWSAttendControl:cBranch	 		:= HttpSession->DadosFunc:cEmployeeFilial
		oWSAttendControl:cFilterField		:= HttpGet->FilterField
		oWSAttendControl:cFilterValue		:= HttpGet->FilterValue	
		oWSAttendControl:nCurrentPage		:= nCurrentPage
			
		If oWSAttendControl:GetPeriods()			
		   	aPeriods	:= oWSAttendControl:OWSGETPERIODSRESULT:OWSPERIODS:OWSTPERIODLIST		   			               
		Else
			HttpSession->_HTMLERRO := { STR0005, PWSGetWSError(), "W_PWSA400.APW" }// Atenção
			cTela	:= "PWSAMSG" 
		EndIf
			
		If oWSAttendControl:GetAttendControl()					
			aAnotations	:= oWSAttendControl:OWsGetAttendControlResult:oWsItens:OWstAttendControlList
			HttpSession->aAnotations := oWSAttendControl:OWsGetAttendControlResult:oWsItens:OWstAttendControlList	
			cPeriodView		:= oWSAttendControl:OWsGetAttendControlResult:cPeriodView
			nTotMarc		:= oWSAttendControl:OWsGetAttendControlResult:nTotMarc
			HttpSession->nTotMarc	:= nTotMarc 
			cPerAponta		:= oWSAttendControl:OWsGetAttendControlResult:cPeriodFielter
			cTela 			:= "PWSA401"	
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA400.APW" }
			cTela	:= "PWSAMSG" 
		EndIf
	ElseIf (HttpGet->nOperacao $ "3*4")

		oRequest := HttpSession->oRequests[nIndice]

		nOperacao 								:= HttpGet->nOperacao
		HttpSession->aLoadMarc					:= Array(5)		

		HttpSession->aLoadMarc[1]				:= PegaValores(oRequest,"P8_FILIAL")				//Filial
		HttpSession->aLoadMarc[2] 				:= PegaValores(oRequest,"P8_MAT")					//Matricula
		HttpSession->aLoadMarc[3]	           	:= PegaValores(oRequest,"P8_DATA") 					//Data da marcação
		HttpSession->aLoadMarc[4]		       	:= PegaValores(oRequest,"P8_HORA")					//Hora da Marcação
		HttpSession->aLoadMarc[5]        		:= PegaValores(oRequest,"P8_MOTIVRG")				//Justificativa
	
		cTela := "PWSA402"            
	EndIf
	
    cHtml := ExecInPage( cTela )  
		
WEB EXTENDED END
Return cHtml

/*******************************************************************
* Funcao: PWSA402
* Autor: Emerson Campos
* Data: 28/04/2014
* Manutenção de marcações do ponto
********************************************************************/
Web Function PWSA402()
Local cHtml := ""
Private cDtSolic
Private cRequestRec
Private cIndice       	:= "1"
Private nOperacao 		:= "1"

HttpSession->cConsPadrao:= "RFD"
	
	WEB EXTENDED INIT cHtml START "InSite"
		cDtSolic	:= HttpGet->cDateEvent
		cRequestRec	:= HttpGet->cNumRec
		If !Empty(cRequestRec)
			nOperacao := "2"
			aDadosAux := {HttpGet->cHourEvent,HttpGet->cObservation} 
		EndIf
		cHtml := ExecInPage( "PWSA402" )	
	WEB EXTENDED END

Return cHtml

/*******************************************************************
* Funcao: PWSA403
* Autor: Leandro Drumond
* Data: 20/02/2015
* Manutenção de marcações do ponto
********************************************************************/
Web Function PWSA403()
Local aAnotation
Local cHtml   	:= ""
Local oOrg    
Local cRetorno	:= ""
Local nTam
Local nX
Local nY
Local lAchou	:= .F.
Local lAtualiza	:= .T.

Private nOperacao 	:= HttpPost->nOperacao
Private nIndice 	:= HttpPost->nIndice

WEB EXTENDED INIT cHtml START "InSite"

	If nOperacao $ "1*2"
		aAnotations := HttpSession->aAnotations
		nTam		:= Len(aAnotations)
		For nY := 1 to nTam
			If aAnotations[nY]:cDateEvent == HttpPost->txtData
				For nX := 1 To Len(aAnotations[nY]:oWsMarks:oWsTMarkList)					
					If aAnotations[nY]:oWsMarks:oWsTMarkList[nX]:cMarksItens == HttpPost->txtHora
						lAchou := .T.
						Exit
					EndIf
				Next nX
				lAtualiza := aAnotations[nY]:cUpdate == "1"
			EndIf
			If lAchou .or. CtoD(aAnotations[nY]:cDateEvent) < CtoD(HttpPost->txtData)
				Exit
			EndIf
		Next nY
	EndIf 						

    If lAchou
    	nOperacao				:= "1"
		HttpGet->msg 			:= STR0010 //"Já existe uma solicitação para esta data e horário"
		HttpGet->nOperacao 		:= nOperacao
		HttpGet->nIndice 		:= nIndice
		HttpSession->nOperacao  := nOperacao
		HttpSession->nIndice	:= nIndice				
        W_PWSA102()
    ElseIf nOperacao == "1" .and. DtoS(CtoD(HttpPost->txtData)) > DtoS(Date()) 
		HttpGet->msg 			:= STR0012 //"Não é possível incluir marcação de períodos futuros."
		HttpGet->nOperacao 		:= nOperacao
		HttpGet->nIndice 		:= nIndice
		HttpSession->nOperacao  := nOperacao
		HttpSession->nIndice	:= nIndice				
        W_PWSA102()              
    ElseIf nOperacao $ "1*2" .and. !lAtualiza
   		nOperacao				:= "1"
		HttpGet->msg 			:= STR0011 //"O período para inclusão de marcações esta encerrado."
		HttpGet->nOperacao 		:= nOperacao
		HttpGet->nIndice 		:= nIndice
		HttpSession->nOperacao  := nOperacao
		HttpSession->nIndice	:= nIndice				
        W_PWSA102()
    Else
  		oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
		WsChgURL(@oOrg,"RHREQUEST.APW")
	    
	    oOrg2 := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
		WsChgURL(@oOrg2,"ORGSTRUCTURE.APW")
	     
		oOrg2:cParticipantID 	:= HttpSession->aStructure[val(HttpPost->nIndice)]:cParticipantID
		oOrg2:cTypeOrg       	:= ""
		oOrg2:cVision        	:= HttpSession->aInfRotina:cVisao
		oOrg2:cRegistration		:= HttpSession->aStructure[val(HttpPost->nIndice)]:cRegistration
		oOrg2:cEmployeeSolFil	:= HttpSession->aUser[2]
		oOrg2:cRegistSolic		:= HttpSession->aUser[3]		
	
		If oOrg2:GetStructure()	   
		    GetMat()  //Pega filial e matricula do participante
	
	  		HttpSession->DadosFunc 						:= HttpSession->aStructure[Val(nIndice)]
			
			oOrg:oWSREQUEST:cApproverBranch		   		:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
			oOrg:oWSREQUEST:cApproverRegistration  		:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
			oOrg:oWSREQUEST:nApproverLevel		   		:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
	   		oOrg:oWSREQUEST:cEmpresaAPR	 				:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupEmpresa
			oOrg:oWSREQUEST:cSTARTERREGISTRATION	 	:= HttpSession->aUser[3]	//Matricula do solicitante
			oOrg:oWSREQUEST:cStarterBranch				:= HttpSession->aUser[2] 	//Filial do solicitante
			oOrg:oWSREQUEST:cBRANCH 					:= HttpSession->DadosFunc:cEmployeeFilial 		//filial 
			oOrg:oWSREQUEST:cREGISTRATION 				:= HttpSession->DadosFunc:cRegistration 		//matricula 
			oOrg:oWSREQUEST:cVISION 					:= HttpSession->aInfRotina:cVisao
			oOrg:oWSREQUEST:cOBSERVATION    			:= Alltrim(HttpPost->txtJust)
			oOrg:oWSREQUEST:cEmpresa	 				:= GetEmpFun()
			oOrg:oWSREQUEST:cDepartAPR	 			:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cDepartAprovador
			
			oOrg:oWSAttendControlRequest:cBranch   		:= HttpSession->DadosFunc:cEmployeeFilial	//Filial do Funcionário
			oOrg:oWSAttendControlRequest:cRegistration  := HttpSession->DadosFunc:cRegistration		//Matricula do Funcionário
			oOrg:oWSAttendControlRequest:cName   		:= HttpSession->DadosFunc:cName				//Nome do funcionário
			oOrg:oWSAttendControlRequest:cDate 			:= HttpPost->txtData						//Data da Marcação
			oOrg:oWSAttendControlRequest:cHour 			:= HttpPost->txtHora						//Data da Marcação
			oOrg:oWSAttendControlRequest:cObservation	:= HttpPost->txtJust						//Data da Marcação
			oOrg:oWSAttendControlRequest:ccodeRequest	:= HttpPost->cRequestRec					//Codigo da requisicao (quando alteração)
			
			If nOperacao == "5" //Exclusão
				If oOrg:DelAttendControlRequest()
					HttpGet->msg := STR0006 // "operacao realizada com sucesso"
					
					HttpGet->nOperacao 		:= "1"
					HttpGet->nIndice 		:= nIndice
					HttpSession->nOperacao  := "1"
					HttpSession->nIndice	:= nIndice				
			        W_PWSA102()
			        
				Else
					HttpSession->nOperacao := "1"
					HttpSession->_HTMLERRO := { STR0006, PWSGetWSError(), "W_PWSA102.APW" }	//"Erro"
					Return ExecInPage("PWSAMSG" )
				EndIf
			Else
				If oOrg:AddAttendControlRequest()
					cRetorno := oOrg:cAddAttendControlRequestResult
					
					HttpGet->msg := STR0006 // "operacao realizada com sucesso"
					
					If(nOperacao == "4")
					    W_PWSA115()
					Else
						HttpGet->nOperacao 		:= "1"
						HttpGet->nIndice 		:= nIndice
						HttpSession->nOperacao  := "1"
						HttpSession->nIndice	:= nIndice				
				        W_PWSA102()
				    EndIf
				Else
					HttpSession->nOperacao := If(nOperacao == "4", nOperacao,"1")
					HttpSession->_HTMLERRO := { STR0006, PWSGetWSError(), "W_PWSA102.APW" }	//"Erro"
					Return ExecInPage("PWSAMSG" )
				EndIf
			EndIf
		Else
			HttpSession->nOperacao := If(nOperacao == "4", nOperacao,"1")
			HttpSession->_HTMLERRO := { STR0006, PWSGetWSError(), "W_PWSA102.APW" }	//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf
	EndIf

WEB EXTENDED END
Return cHtml


/*******************************************************************/
//* Funcao: PWSA404
//* Autor: Flavio Correa
//* Data: 14/08/15
//* Aprovacao de marcação ponto
Web Function PWSA404()

Local cHtml    	:= ""
Local nIndice   := HttpSession->nIndiceSolic
Local nOperacao := HttpSession->nOperacao
Local oObj    
Local oOrg    
Local lOk       := .T.
Local cErro     := ""
Local Cod     := HttpPost->txtcod

WEB EXTENDED INIT cHtml START "InSite"
	//busca filial e matricula do paritipante logado
	GetMat()

	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
   	WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
   	                  
	oOrg:cVision         := HttpSession->oRequests[val(nIndice)]:CVISION
	oOrg:cEmployeeFil    := HttpSession->oRequests[val(nIndice)]:CBRANCH
	oOrg:cRegistration   := HttpSession->oRequests[val(nIndice)]:CREGISTRATION
	oOrg:cEmployeeSolFil := HttpSession->aUser[2]
	oOrg:cRegistSolic	 := HttpSession->aUser[3]
	oOrg:cRequestType	 := HttpSession->cTypeRequest 

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
		
			oObj:oWsRequest                        := RHREQUEST_TREQUEST():New()
			oObj:oWsRequest:cBranch                := HttpSession->oRequests[val(nIndice)]:cBranch
			oObj:oWsRequest:cRegistration          := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
			oObj:oWsRequest:cCode                  := HttpSession->oRequests[val(nIndice)]:cCode
			oObj:oWsRequest:cObservation           := HttpPost->txtobs
			oObj:oWsRequest:cApproverBranch		   := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
			oObj:oWsRequest:cApproverRegistration  := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
			oObj:oWsRequest:nApproverLevel		   := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
			oObj:oWSREQUEST:cEmpresaAPR	 		   := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupEmpresa
				
			If oObj:ApproveRequest()
	    		lOk := .T.
	    	Else
	    		cErro := PWSGetWSError()
	    		lOk := .F.
	    	EndIf
		EndIf
	EndIf
		
	If lOk
	   	HttpGet->msg := STR0008 //"Aprovacao Gravada com sucesso"
	      	
	    If(nOperacao == "4")
		    W_PWSA115()
		Else 
	        W_PWSA160()
	    EndIf
	Else
		HttpSession->_HTMLERRO := {STR0007, cErro, "W_PWSA00C.APW"}		//"Erro" 
		Return ExecInPage("PWSAMSG" )
	EndIf	
WEB EXTENDED END

Return cHtml 

/*******************************************************************/
//* Funcao: PWSA405
//* Autor: Flavio Correa
//* Data: 14/08/15
//* Reprovacao de marcação ponto
Web Function PWSA405()

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
    If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat)
        oOrg:cRegistration := HttpSession->RHMat
    EndIf   

    If oOrg:GetStructure()       
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WsRhRequest"), WsRhRequest():New())
		WsChgURL(@oObj, "RHREQUEST.APW")   

		oObj:oWsRequest	                    	:= RHREQUEST_TREQUEST():New()
		oObj:oWsRequest:cBranch              	:= HttpSession->oRequests[val(nIndice)]:cBranch
		oObj:oWsRequest:cRegistration         	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
		oObj:oWsRequest:cCode               	:= HttpSession->oRequests[val(nIndice)]:cCode
		oObj:oWsRequest:cObservation          	:= HttpPost->txtobs
		oObj:oWsRequest:cApproverBranch		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
		oObj:oWsRequest:cApproverRegistration  	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
		oObj:oWsRequest:nApproverLevel		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
		oObj:oWSREQUEST:cEmpresaAPR	 		    := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupEmpresa
				
		If oObj:ReproveRequest()
        	HttpGet->msg := STR0009 //"Reprovacao Gravada com sucesso"	    

		    If(nOperacao == "4")
			    W_PWSA115()
			Else 
		        W_PWSA160()
		    EndIf		    
		Else
			HttpSession->_HTMLERRO := {STR0007, PWSGetWSError(), "W_PWSA00C.APW"}		//"Erro" 
			Return ExecInPage("PWSAMSG" )
		EndIf 
	Else
		HttpSession->_HTMLERRO := {STR0007, PWSGetWSError(), "W_PWSA00C.APW"}		//"Erro" 
		Return ExecInPage("PWSAMSG" )
	EndIf 			

WEB EXTENDED END

Return cHtml
