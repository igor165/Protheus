#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA120.CH"

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍ³±±
±±³Data Fonte Sustentação³ ChangeSet ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ³±±  
±±³    07/05/2014        ³  225842   ³±± 
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍ±±
*/ 

/*******************************************************************
* Funcao: PWSA120
* Autor: Alex Adriano de Oliveira
* Data: 07/12/2009
* Solicitacao de acao salarial
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Uso       ³ RH/Portais                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Analista     ³ Data   ³FNC:            ³  	Motivo da Alteracao         ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Emerson Campos³07/03/14³M_RH001/196101  ³Ajustes para atender a P12      ³±±
±±³Emerson Campos³30/04/14³TPKFN9          ³Replica alterações realizadas   ³±±
±±³              ³        ³                ³pela manutenção até 25/03/14    ³±±
±±³              ³        ³                ³chamado TPBAFB, changeset 215437³±±
±±³              ³        ³                ³na P11.80                       ³±±
±±³              ³        ³                ³                                ³±±
±±³              ³        ³                ³                                ³±±
±±³Renan Borges  ³12/09/16³TVWVWI          ³Ajuste ao utilizar Visão por    ³±±
±±³              ³        ³                ³ Departamento e realizar a soli-³±±
±±³              ³        ³                ³tação para um membro da equipe, ³±±
±±³              ³        ³                ³seja carregado o aprovador cor- ³±± 
±±³              ³        ³                ³retamente, quando o responsável ³±± 
±±³              ³        ³                ³pelo departamento estiver em um ³±± 
±±³              ³        ³                ³departamento diferente ao do so-³±± 
±±³              ³        ³                ³licitante.                      ³±±
±±³Matheus M.    ³16/11/16³TVZLRB-MRH-1073 ³Ajuste para que ao aprovar uma  ³±±
±±³              ³        ³                ³solicitação, sejam exibidos as  ³±±
±±³              ³        ³                ³descrições de cargo e função.	³±±  
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Web Function PWSA120()
Local cHtml   	:= ""

	WEB EXTENDED INIT cHtml START "InSite"	              
		HttpSession->cTypeRequest := "7"		// Acao Salarial
		HttpGet->titulo           := STR0021 	//"Solicitacao de Acao Salarial"
		HttpSession->aStructure   := {}
		HttpSession->cHierarquia  := ""
		HttpSession->cIDMENU		:= "GCH"
		fGetInfRotina("W_PWSA120.APW")   		//Retorno HttpSession->aInfRotina
		GetMat()								//Pega a Matricula e a filial do participante logado

		cHtml := ExecInPage("PWSA120A")
	WEB EXTENDED END	
Return cHtml

/*******************************************************************
* Funcao: PWSA121
* Autor: Alex Adriano de Oliveira
* Data: 07/12/2009
* Solicitacao de acao salarial - interacao
********************************************************************/
Web Function PWSA121()

Local cHtml   	:= ""
Local nIndice 	:= 0
Local oAcao		:= Nil
Local oRequest	:= Nil
Local oOrg		:= Nil
Local nTamDesc	:= 4
Local nI		:= 0

if(valtype(HttpGet->nIndice) != "U")
   nIndice := val(HttpGet->nIndice) 
endif

HttpCTType("text/html; charset=ISO-8859-1")	 

WEB EXTENDED INIT cHtml START "InSite"	 
    GetMat()//Pega filial e matricula do participante 

   	If (HttpGet->nOperacao == "1")  
   		HttpSession->DadosFunc := HttpSession->aStructure[val(HttpGet->nIndice)]
   	ElseIf (HttpGet->nOperacao == "3") .Or. (HttpGet->nOperacao == "4")
		oRequest := HttpSession->oRequests[val(HttpGet->nIndiceSolic)]
		
		oAcao    := WSClassNew("RHREQUEST_TSalaryChange")
		
		oAcao:cChangeType  		:= PegaValores(oRequest,"RB7_TPALT")
		oAcao:cNewRoleCode 		:= PegaValores(oRequest,"RB7_FUNCAO")
		oAcao:cNewPositionCode 	:= PegaValores(oRequest,"RB7_CARGO")
		oAcao:nPercentage  		:= PegaValores(oRequest,"RB7_PERCEN")
		oAcao:nNewSalary	 	:= PegaValores(oRequest,"RB7_SALARI")
		oAcao:cCategory  		:= PegaValores(oRequest,"RB7_CATEG")
		
		oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
		WsChgURL(@oOrg,"RHREQUEST.APW",,,GetEmpFun())
								
		oOrg:cRegistration 	:= HttpSession->oRequests[val(HttpGet->nIndiceSolic)]:cRegistration
		HttpPost->Acao  	:= oAcao
		
		For nI := 1 To nTamDesc
			If nI == 1
				oOrg:cValue := oAcao:cChangeType
				oOrg:cCpo	:= "X5_DESCRI"
				oOrg:cAlias	:= "41" 
				oOrg:lIsX5	:= .T.
				
				oOrg:GetDesc()
				HttpPost->cReasonA		:= oOrg:oWSGETDESCRESULT:cValue
			ElseIf nI == 2
				oOrg:cValue := oAcao:cCategory
				oOrg:cCpo	:= "X5_DESCRI"
				oOrg:cAlias	:= "28" 
				oOrg:lIsX5	:= .T.
				
				oOrg:GetDesc()
				HttpPost->cReasonCat		:= oOrg:oWSGETDESCRESULT:cValue
			ElseIf nI == 3
				oOrg:cValue := oAcao:cNewRoleCode
				oOrg:cCpo	:= "RJ_DESC"
				oOrg:cAlias	:= "SRJ" 
				oOrg:lIsX5	:= .F.
				
				oOrg:GetDesc()
				HttpPost->cReasonF		:= oOrg:oWSGETDESCRESULT:cValue
			Else
				oOrg:cValue := oAcao:cNewPositionCode
				oOrg:cCpo	:= "Q3_DESCSUM"
				oOrg:cAlias	:= "SQ3"
				oOrg:lIsX5	:= .F.
				
				oOrg:GetDesc()
				HttpPost->cReasonC		:= oOrg:oWSGETDESCRESULT:cValue
			EndIf
		Next nI
		
	EndIf

    cHtml := ExecInPage( "PWSA121" )
	
WEB EXTENDED END
Return cHtml
 
/*******************************************************************
* Funcao: PWSA122
* Autor: Alex Adriano de Oliveira
* Data: 08/12/2009
* Solicitacao de acao salarial - Gravacao
********************************************************************/
Web Function PWSA122()
Local oOrg    
Local cHtml   	:= ""
Local cErro     := ""
Local cRetorno	:= ""
Local cSalario  := ""
Local nOperacao := HttpPost->nOperacao

WEB EXTENDED INIT cHtml START "InSite"
	             
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
	    GetMat()    //Pega filial e matricula do participante 
	
		oOrg:oWSREQUEST:cApproverBranch		   	:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
		oOrg:oWSREQUEST:cApproverRegistration  	:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
		oOrg:oWSREQUEST:nApproverLevel		   	:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
		oOrg:oWSREQUEST:cEmpresaAPR	 			:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupEmpresa
		
		oOrg:oWSREQUEST:cSTARTERREGISTRATION 	:= HttpSession->aUser[3] //Filial do solicitante
		oOrg:oWSREQUEST:cStarterBranch			:= HttpSession->aUser[2] //matricula do solicitante
		oOrg:oWSREQUEST:cBRANCH 				:= HttpPost->cFilFun 	 //filial do Transferido
		oOrg:oWSREQUEST:cREGISTRATION 			:= HttpPost->cMatFun 	 //matricula do Transferido
		oOrg:oWSREQUEST:cVISION 				:= HttpSession->aInfRotina:cVisao
		oOrg:oWSREQUEST:cOBSERVATION    		:= Alltrim(HttpPost->txtobs)
		oOrg:oWSREQUEST:cEmpresa	 			:= GetEmpFun()
		
		oOrg:oWSSALARYCHANGEREQUEST:cBRANCH				:= HttpPost->cFilFun
		oOrg:oWSSALARYCHANGEREQUEST:cREGISTRATION   	:= HttpPost->cMatFun
		oOrg:oWSSALARYCHANGEREQUEST:cNAME           	:= HttpSession->DadosFunc:cName
	
		oOrg:oWSSALARYCHANGEREQUEST:cChangeType			:= HttpPost->txtalteracao						//Tipo da alteração
		oOrg:oWSSALARYCHANGEREQUEST:cNewRoleCode		:= HttpPost->txtfuncao							//Nova Função
		oOrg:oWSSALARYCHANGEREQUEST:cNewPositionCode	:= HttpPost->txtcargo				  			//Novo Cargo:
		oOrg:oWSSALARYCHANGEREQUEST:nPercentage			:= VAL(StrTran(HttpPost->txtpctaumento,",",".")) //Percentual de Aumento:
		
		cSalario                                        := StrTran(HttpPost->txtsalario,".","")
		cSalario                                        := StrTran(cSalario,",",".")
		oOrg:oWSSALARYCHANGEREQUEST:nNewSalary			:= VAL(cSalario)								//Novo Salário:
	
		oOrg:oWSSALARYCHANGEREQUEST:cCategory			:= HttpPost->txtcatg							//Categoria:
		
		If oOrg:ADDSALARYCHANGEREQUEST()
			cRetorno := oOrg:cADDSALARYCHANGEREQUESTRESULT
			HttpGet->msg := "Operacao realizada com sucesso"
			
			If(nOperacao == "4")
			    W_PWSA115()
			Else 
		        W_PWSA120()
		    EndIf
		Else
			HttpSession->_HTMLERRO := {"Erro", cErro, "W_PWSA000.APW" }	//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf
	Else
		HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
		Return ExecInPage("PWSAMSG" )
	EndIf	

WEB EXTENDED END
Return cHtml   

/*******************************************************************
* Funcao: PWSA123
* Autor: Alex Adriano Oliveira
* Data: 08/12/09
* Aprovacao de acao salarial
********************************************************************/
Web Function PWSA123()
Local cHtml   	:= ""
Local nIndice   	:= HttpSession->nIndiceSolic
Local nOperacao 	:= HttpSession->nOperacao
Local oObj    
Local oOrg    
Local lOk       	:= .T.
Local cErro     	:= ""
Local Cod     	:= HttpPost->txtcod

WEB EXTENDED INIT cHtml START "InSite"	
	GetMat()//busca filial e matricula do paritipante logado
   
	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
   	WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
   	oOrg:cParticipantID   := HttpSession->cParticipantID
	oOrg:cVision          := HttpSession->oRequests[val(nIndice)]:CVISION 
	oOrg:cEmployeeFil     := HttpSession->oRequests[val(nIndice)]:CBRANCH
	oOrg:cRegistration    := HttpSession->oRequests[val(nIndice)]:CREGISTRATION
	oOrg:cEmployeeSolFil  := HttpSession->aUser[2]
	oOrg:cRegistSolic	  := HttpSession->aUser[3]
	oOrg:cRequestType	  := HttpSession->cTypeRequest

	If (lOk:= oOrg:GetStructure())
		If HttpPost->lPontoRH == ".T."
			aRetorno := ExecBlock("PontoRH",.F.,.F.,{"3", HttpSession->oRequests[1]:CBRANCH, Cod, HttpPost->txtvisao,nil,nil,HttpPost->txtobs,HttpSession->aUser[2],HttpSession->aUser[3]})
			If !aRetorno[1]
				lOk   := .F.
				cErro := aRetorno[2]
			EndIf
		Else
	        oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
			WsChgURL(@oObj, "RHREQUEST.APW")   
			
			oObj:oWsRequest	             			:= RHREQUEST_TREQUEST():New()
			oObj:oWsRequest:cBranch      			:= HttpSession->oRequests[val(nIndice)]:cBranch
			oObj:oWsRequest:cRegistration			:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
			oObj:oWsRequest:cCode        			:= HttpSession->oRequests[val(nIndice)]:cCode
			oObj:oWsRequest:cObservation 			:= Alltrim(HttpPost->txtobs)
			oObj:oWsRequest:cApproverBranch		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
			oObj:oWsRequest:cApproverRegistration  	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
			oObj:oWsRequest:nApproverLevel		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
			oObj:oWSREQUEST:cEmpresaAPR	 		    := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupEmpresa
			oObj:oWSREQUEST:cDepartAPR	 			:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cDepartAprovador
					
			If oObj:ApproveRequest()
		   		lOk := .T.
		 	Else
		    	cErro := PWSGetWSError()
		    	lOk := .F.
		  	EndIf
		EndIf    
	EndIf    
	If lOk
    	HttpGet->nIndice := nIndice
       	HttpGet->msg := "Aprovacao Gravada com sucesso"

        If(nOperacao == "4")
		    W_PWSA115()
		Else 
	        W_PWSA120()
	    EndIf
	Else
		HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA00C.APW"}		//"Erro" 
		Return ExecInPage("PWSAMSG" )
	EndIf 

WEB EXTENDED END

Return cHtml 

/*******************************************************************
* Funcao: PWSA124
* Autor: Alex Adriano Oliveira
* Data: 08/12/09
* Reprovacao de acao salarial
********************************************************************/
Web Function PWSA124()

Local cHtml   	:= ""
Local oObj    
Local oOrg    
Local nIndice   	:= HttpSession->nIndiceSolic
Local nOperacao 	:= HttpSession->nOperacao

WEB EXTENDED INIT cHtml START "InSite"

        oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
		WsChgURL(@oObj, "RHREQUEST.APW")   
		
		oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
	    WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
	     	
	    oOrg:cParticipantID 	:= HttpSession->cParticipantID
	    oOrg:cVision			:= HttpSession->aInfRotina:cVisao                       	
	    If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat)
	        oOrg:cRegistration := HttpSession->RHMat
	    EndIf   
		
		GetMat() //busca filial e matricula do paritipante logado
        
		If oOrg:GetStructure()  
			oObj:oWsRequest	             			:= RHREQUEST_TREQUEST():New()
			oObj:oWsRequest:cBranch      			:= HttpSession->oRequests[val(nIndice)]:cBranch
			oObj:oWsRequest:cRegistration			:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
			oObj:oWsRequest:cCode        			:= HttpSession->oRequests[val(nIndice)]:cCode
			oObj:oWsRequest:cObservation 			:= Alltrim(HttpPost->txtobs)
			oObj:oWsRequest:cApproverBranch		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
			oObj:oWsRequest:cApproverRegistration  	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
			oObj:oWsRequest:nApproverLevel		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
			oObj:oWSREQUEST:cEmpresaAPR	 		    := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupEmpresa
					
			If oObj:ReproveRequest()
			    	HttpGet->nIndice := nIndice
		        	HttpGet->msg := "Reprovacao Gravada com sucesso"
		    
			    If(nOperacao == "4")
				    W_PWSA115()
				Else 
			        W_PWSA120()
			    EndIf
			Else
				HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA00C.APW"}		//"Erro" 
				Return ExecInPage("PWSAMSG" )
			EndIf 
		Else
			HttpSession->_HTMLERRO := {STR0003, PWSGetWSError(), "W_PWSA00C.APW"}		//"Erro" 
			Return ExecInPage("PWSAMSG" )
		EndIf 			

WEB EXTENDED END

Return cHtml 
