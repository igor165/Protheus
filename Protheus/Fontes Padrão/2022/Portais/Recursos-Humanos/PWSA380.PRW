#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH" 
#INCLUDE "PWSA380.CH"
/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍ³±±
±±³Data Fonte Sustentação³ ChangeSet ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ³±±  
±±³    07/05/2014        ³  225850   ³±± 
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍ±±
*/

/*******************************************************************
* Funcao: PWSA380
* Autor: Emerson Campos
* Data: 22/04/2014
* Solicitação de Subsídio Acadêmico
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Uso       ³ RH/Portais                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Analista     ³ Data   ³FNC:            ³  	Motivo da Alteracao        ³±±
±±³Emerson Campos|22/04/14|M_RH003/310901  |Disponibilizado a nova opção de ³±±
±±³              |        |                |Solicitação Subsídio Acadêmico  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PWSA380()

	Local cHtml   	:= ""
	Local oParam  	:= Nil

	WEB EXTENDED INIT cHtml START "InSite"	              
		HttpSession->cTypeRequest 	:= "V"			// Subsídio Acadêmico
		HttpGet->titulo           	:= STR0004 	//"Solicitação de Subsídio Acadêmico"
		HttpSession->aStructure	   	:= {}
		HttpSession->cHierarquia	:= ""
		HttpSession->cDataIni		:= ""
		
		oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		WsChgURL(@oParam,"CFGDICTIONARY.APW")

		fGetInfRotina("W_PWSA380.APW")
		GetMat()								//Pega a Matricula e a filial do participante logado

		//cHtml := ExecInPage("PWSA380A")
		cHtml := ExecInPage("PWSA120A")
	WEB EXTENDED END
Return cHtml  

/*******************************************************************
* Funcao: PWSA381
* Autor: Emerson Campos
* Data: 22/04/2014
* Solicitação de Subsídio Acadêmico
********************************************************************/
Web Function PWSA381()

Local oWSAcadGrant
Local cHtml   		:= ''
Local cTela			:= ''
Local nIndice 		:= 0
Private cBenefitCode
Private oAcadGrant

If (HttpGet->nOperacao == "1")
	If(valtype(HttpGet->nIndice) != "U")
	   nIndice := val(HttpGet->nIndice) 
	EndIf
ElseIf (HttpGet->nOperacao $ "3*4")
	If(valtype(HttpGet->nIndiceSolic) != "U")
	   nIndice := val(HttpGet->nIndiceSolic) 
	EndIf
EndIf

WEB EXTENDED INIT cHtml START "InSite"  
  	
	 //Pega filial e matricula do participante
    GetMat()   

	oWSAcadGrant := Iif(FindFunction("GetAuthWs"), GetAuthWs("WsRHAcademicGrant"), WsRHAcademicGrant():New())

  	If (HttpGet->nOperacao == "1") 
   		HttpSession->DadosFunc 		:= HttpSession->aStructure[nIndice]
		WsChgURL(@oWSAcadGrant, "RHACADEMICGRANT.APW",,,GetEmpFun())
	Endif
	
    
   	If (HttpGet->nOperacao == "1") 
 		oWSAcadGrant:cEmployeeFil	:= HttpSession->DadosFunc:cEmployeeFilial
	
		If oWSAcadGrant:GetListAcademicGrant()		
			oAcadGrant						:= oWSAcadGrant:oWSGetListAcademicGrantResult
			HttpSession->ListAcadGrantt	:= oWSAcadGrant:oWSGetListAcademicGrantResult:oWsItens:OWSACADEMICGRANTFIELDS
			cTela := "PWSA381"            
		Else
			HttpSession->_HTMLERRO := { STR0017, PWSGetWSError(), "W_PWSA380.APW" } // Atenção
			cTela	:= "PWSAMSG" 
		EndIf
	ElseIf (HttpGet->nOperacao $ "3*4")
		oRequest := HttpSession->oRequests[nIndice]
		
		oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
		WsChgURL(@oOrg,"ORGSTRUCTURE.APW",,,oRequest:cEmpresa)                             
        oOrg:cEmployeeFil   := PegaValores(oRequest,"RI1_FILIAL")
        oOrg:cRegistration  := PegaValores(oRequest,"RI1_MAT")
 		oOrg:cVision	    := HttpSession->aInfRotina:cVisao
    
		If oOrg:GetStructure()
			HttpSession->DadosFunc 	:= aClone(oOrg:oWSGetStructureResult:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE)[1]
		Endif
		WsChgURL(@oWSAcadGrant, "RHACADEMICGRANT.APW",,,GetEmpFun())
				
		oWSAcadGrant:cEmployeeFil	:= oRequest:cBranch
	
		If oWSAcadGrant:GetListAcademicGrant()		
			oAcadGrant			:= oWSAcadGrant:oWSGetListAcademicGrantResult
			
			//oAcadGrant:cBranch  					:= PegaValores(oRequest,"RI1_FILIAL")				//Filial
			//oAcadGrant:cRegistration 			:= PegaValores(oRequest,"RI1_MAT")						//Matricula
			cBenefitCode         				:= SubStr(PegaValores(oRequest,"RI1_TABELA"),1,2)	//Código do beneficio
			oAcadGrant:cCurseName           	:= PegaValores(oRequest,"TMP_NMCURS") 					//Nome do Curso
			oAcadGrant:cInstituteName       	:= PegaValores(oRequest,"TMP_NMINST") 					//Nome da instituição
			oAcadGrant:cContact          		:= PegaValores(oRequest,"TMP_CONTAT") 					//Contato na intituição
			oAcadGrant:cPhone 					:= PegaValores(oRequest,"TMP_TELEFO") 					//Telefone do contato
			oAcadGrant:cStartDate				:= PegaValores(oRequest,"RI1_DINIPG") 					//Data de inicio do curso
			oAcadGrant:cEndDate					:= PegaValores(oRequest,"RI1_DFIMPG") 					//Data do fim do curso
			oAcadGrant:cMonthlyPayment			:= PegaValores(oRequest,"TMP_VLRMEN") 					//Valor da mensalidade
			oAcadGrant:cInstallmentAmount		:= PegaValores(oRequest,"TMP_QTDEPA") 					//Qtde. total de parcelas
		
			cTela := "PWSA381"            
		Else
			HttpSession->_HTMLERRO := { STR0017, PWSGetWSError(), "W_PWSA380.APW" } // Atenção
			cTela	:= "PWSAMSG" 
		EndIf
	EndIf
	
    cHtml := ExecInPage( cTela )  
		
WEB EXTENDED END
Return cHtml

/*******************************************************************
* Funcao: PWSA382
* Autor: Emerson Campos
* Data: 28/04/2014
* Solicitação de Subsídio Acadêmico
********************************************************************/
Web Function PWSA382()
Local cHtml   	:= ""
Local oOrg    
Local cRetorno	:= "" 
Local nOperacao := HttpSession->nOperacao
Local m

WEB EXTENDED INIT cHtml START "InSite"
              
	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WsRhRequest"), WsRhRequest():New())
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
	
		oOrg:oWSREQUEST:cApproverBranch		   		:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
		oOrg:oWSREQUEST:cApproverRegistration  		:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
		oOrg:oWSREQUEST:nApproverLevel		   		:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
	    oOrg:oWSREQUEST:cEmpresaAPR	 				:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupEmpresa
		oOrg:oWSREQUEST:cSTARTERREGISTRATION	 	:= HttpSession->aUser[3]		//Matricula do solicitante
		oOrg:oWSREQUEST:cStarterBranch				:= HttpSession->aUser[2] 	//Filial do solicitante
		oOrg:oWSREQUEST:cBRANCH 					:= HttpPost->cFilFun 		//filial 
		oOrg:oWSREQUEST:cREGISTRATION 				:= HttpPost->cMatFun 		//matricula 
		oOrg:oWSREQUEST:cVISION 					:= HttpSession->aInfRotina:cVisao
		oOrg:oWSREQUEST:cOBSERVATION    			:= Alltrim(HttpPost->txtObs)
		oOrg:oWSREQUEST:cEmpresa	 				:= GetEmpFun()
		oOrg:oWSREQUEST:cDepartAPR	 				:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cDepartAprovador
		
	
		oOrg:oWSAcademicGrantRequest:cBranch   				:= HttpPost->cFilFun					//Filial do Funcionário
		oOrg:oWSAcademicGrantRequest:cRegistration   			:= HttpPost->cMatFun					//Matricula do Funcionário
		oOrg:oWSAcademicGrantRequest:cName   					:= HttpPost->cNome					//Nome do funcionário
		oOrg:oWSAcademicGrantRequest:cBenefitCode   			:= HttpPost->cBenefitCode			//Código do beneficio (RIS_CODE - Char - 2)
		For m := 1 To Len(HttpSession->ListAcadGrantt)
			If HttpSession->ListAcadGrantt[m]:cBenefitCode == HttpPost->cBenefitCode 
				oOrg:oWSAcademicGrantRequest:cDescBenefitCode	:= HttpSession->ListAcadGrantt[m]:cBenefitName
				Exit
			EndIf
		Next m		
		oOrg:oWSAcademicGrantRequest:cCurseName           	:= HttpPost->cCurseName				//Nome do Curso
		oOrg:oWSAcademicGrantRequest:cInstituteName			:= HttpPost->cInstituteName			//Nome da instituição
		oOrg:oWSAcademicGrantRequest:cContact					:= HttpPost->cContact				//Contato na intituição	
		oOrg:oWSAcademicGrantRequest:cPhone					:= HttpPost->cPhone					//Telefone do contato
		oOrg:oWSAcademicGrantRequest:cStartDate				:= HttpPost->cStartDate				//Data de inicio do curso
		oOrg:oWSAcademicGrantRequest:cEndDate					:= HttpPost->cEndDate				//Data do fim do curso
		oOrg:oWSAcademicGrantRequest:cMonthlyPayment			:= HttpPost->cMonthlyPayment		//Valor da mensalidade
		oOrg:oWSAcademicGrantRequest:cInstallmentAmount		:= HttpPost->cInstallmentAmount		//Qtde. total de parcelas
		oOrg:oWSAcademicGrantRequest:cOBSERVATION				:= Alltrim(HttpPost->txtObs)		//Observação
		
	
		If oOrg:AddAcademicGrantRequest()
			cRetorno := oOrg:cAddAcademicGrantRequestResult
			HttpGet->msg := STR0005 // "operacao realizada com sucesso"
			
			If(nOperacao == "4")
			    W_PWSA115()
			Else 
		        W_PWSA380()
		    EndIf
		Else
			HttpSession->_HTMLERRO := { STR0006, PWSGetWSError(), "W_PWSA380.APW" }	//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf
	Else
		HttpSession->_HTMLERRO := { STR0006, PWSGetWSError(), "W_PWSA380.APW" }	//"Erro"
		Return ExecInPage("PWSAMSG" )
	EndIf	

WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA163
* Autor: Emerson Campos
* Data: 06/05/2014
* Aprovacao de subsídio acadêmico
********************************************************************/
Web Function PWSA383()

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
	oOrg:cEmployeeSolFil	:= HttpSession->aUser[2]
	oOrg:cRegistSolic		:= HttpSession->aUser[3]
	oOrg:cRequestType		:= HttpSession->cTypeRequest 

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
	   	HttpGet->msg := STR0022 //"Aprovacao Gravada com sucesso"
	      	
	    If(nOperacao == "4")
		    W_PWSA115()
		Else 
	        W_PWSA160()
	    EndIf
	Else
		HttpSession->_HTMLERRO := {STR0006, cErro, "W_PWSA00C.APW"}		//"Erro" 
		Return ExecInPage("PWSAMSG" )
	EndIf 
	
WEB EXTENDED END

Return cHtml 



/*******************************************************************
* Funcao: PWSA163
* Autor: Emerson Campos
* Data: 06/05/2014
* Reprovacao de subsídio acadêmico
********************************************************************/
Web Function PWSA384()

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
     	
    oOrg:cParticipantID 		:= HttpSession->cParticipantID
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
		oObj:oWsRequest:cApproverRegistration   := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
		oObj:oWsRequest:nApproverLevel		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
		oObj:oWSREQUEST:cEmpresaAPR	 		    := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupEmpresa
				
		If oObj:ReproveRequest()
        	HttpGet->msg := STR0023 //"Reprovacao Gravada com sucesso"	    

		    If(nOperacao == "4")
			    W_PWSA115()
			Else 
		        W_PWSA160()
		    EndIf 
		    
		Else
			HttpSession->_HTMLERRO := {STR0006, PWSGetWSError(), "W_PWSA00C.APW"}		//"Erro" 
			Return ExecInPage("PWSAMSG" )
		EndIf 
	Else
		HttpSession->_HTMLERRO := {STR0006, PWSGetWSError(), "W_PWSA00C.APW"}		//"Erro" 
		Return ExecInPage("PWSAMSG" )
	EndIf 			

WEB EXTENDED END

Return cHtml 
