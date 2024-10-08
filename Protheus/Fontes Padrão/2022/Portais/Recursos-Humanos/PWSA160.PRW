#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH" 
#INCLUDE "PWSA160.CH"

/*
������������������������������������ͳ��
���Data Fonte Sustenta��o� ChangeSet ���
������������������������������������ĳ��  
���    22/10/2014        �  262884   ��� 
�������������������������������������ͱ�
*/ 

/*******************************************************************
* Funcao: PWSA160
* Autor: Alex Adriano de Oliveira
* Data: 28/12/2009
* Justificativa de horarios
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Uso       � RH/Portais                                                   ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Analista     � Data   �FNC:            �Motivo da Alteracao             ��� 
���������������������������������������������������������������������������Ĵ�� 
���Emerson Campos�07/03/14�M_RH001/196101  �Ajustes para atender a P12      ���
���              �        �                �                                ���
���Allyson M     |22/10/14|TQUQES          |Ajuste p/ validar o periodo de  ���
���              |        |                |apontamento pela filial do 	    ���
���              |        |                |funcionario. 	    			���
���Renan Borges  |25/04/16|TUZCRD          |Ajuste para ao realizar uma jus-���
���              |        |                |tificativa de pre-abono seja de-���
���              |        |                |monstrada a descri��o do motivo ���
���              |        |                |de abono corretamente quando ela���
���              |        |                |possuir caracteres especiais.   ���
���Matheus M.    |08/06/16|TVITKU          |Ajuste p/ n�o permitir solicitar���
���              |        |                |abonos para a mesma hora e data.���
���Renan Borges  �12/09/16�TVWVWI          �Ajuste ao utilizar Vis�o por    ���
���              �        �                � Departamento e realizar a soli-���
���              �        �                �ta��o para um membro da equipe, ���
���              �        �                �seja carregado o aprovador cor- ��� 
���              �        �                �retamente, quando o respons�vel ��� 
���              �        �                �pelo departamento estiver em um ��� 
���              �        �                �departamento diferente ao do so-��� 
���              �        �                �licitante.                      ��� 
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Web Function PWSA160()

	Local cHtml   	:= ""

	WEB EXTENDED INIT cHtml START "InSite"	              
		HttpSession->cTypeRequest 	:= "8"		// Justificativa de Horarios
		HttpGet->titulo           	:= STR0002 	//"Solicitacao de Transferencia"
		HttpSession->aStructure	   	:= {}
		HttpSession->cHierarquia	:= ""

		fGetInfRotina("W_PWSA160.APW")
		GetMat()								//Pega a Matricula e a filial do participante logado

		//cHtml := ExecInPage("PWSA160A")
		cHtml := ExecInPage("PWSA120A")
	WEB EXTENDED END
Return cHtml  

/*******************************************************************/
//* Funcao: PWSA161
//* Autor: Alex Adriano de Oliveira
//* Data: 28/12/2009
//* Justificativa de horarios
Web Function PWSA161()

Local cFilBusca	:= ""
Local lSPOComp	:= .T.
Local oOrg
Local oParam  	:= Nil
Local oRequest
Local cHtml   	:= ""
Local nIndice 	:= 0

HttpCTType("text/html; charset=ISO-8859-1")

if(valtype(HttpGet->nIndice) != "U")
   nIndice := val(HttpGet->nIndice) 
endif


WEB EXTENDED INIT cHtml START "InSite"   
	
	HttpSession->cDataIni	:= ""
    GetMat()//Pega filial e matricula do participante 

    nIndice :=  val(HttpGet->nIndice)
   	If (HttpGet->nOperacao == "1")  
   		HttpSession->DadosFunc := HttpSession->aStructure[nIndice]

		oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		WsChgURL(@oParam,"CFGDICTIONARY.APW") 
		
		If oParam:GetAccessMode( "SPO" ) 
			lSPOComp := oParam:lGetAccessModeResult
		Endif		
		
		//Caso a tabela de periodo de apontamento seja compartilhado, nao passa filial para busca,
		//caso contrario, passa a filial do funcionario que sera incluido a solicitacao.
		If lSPOComp
			cFilBusca := ""
		Else
			cFilBusca := HttpSession->DadosFunc:cEmployeeFilial
		EndIf
		
		If oParam:GETPARAM( "MSALPHA", "MV_PONMES", cFilBusca ) 
			// Verifica se existe o parametro
			If oParam:cGETPARAMRESULT <> ".F."
				HttpSession->cDataIni := SubStr(oParam:cGETPARAMRESULT,7,2) + "/" + SubStr(oParam:cGETPARAMRESULT,5,2) + "/" + SubStr(oParam:cGETPARAMRESULT,1,4)
			Endif
		Endif
   	ElseIf (HttpGet->nOperacao == "3") .Or. (HttpGet->nOperacao == "4")
       	oRequest					:= HttpSession->oRequests[val(HttpGet->nIndiceSolic)]
		
       	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
		WsChgURL(@oOrg,"ORGSTRUCTURE.APW",,,oRequest:cEmpresa)                             
		oOrg:cEmployeeFil   := PegaValores(oRequest,"RF0_FILIAL")
		oOrg:cRegistration  := PegaValores(oRequest,"RF0_MAT")
		oOrg:cVision	    := HttpSession->aInfRotina:cVisao

	   	If oOrg:GetStructure()
			HttpSession->DadosFunc 	:= aClone(oOrg:oWSGetStructureResult:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE)[1]
		Endif
		oJustificativa				:= WSClassNew("RHREQUEST_TScheduleJustification")
		
		oJustificativa:dInitialDate := PegaValores(oRequest,"RF0_DTPREI")
		oJustificativa:dFinalDate	:= PegaValores(oRequest,"RF0_DTPREF")
		oJustificativa:nInitialTime	:= PegaValores(oRequest,"RF0_HORINI")
		oJustificativa:nFinalTime	:= PegaValores(oRequest,"RF0_HORFIM")
		oJustificativa:cReason		:= PegaValores(oRequest,"RF0_CODABO")
		HttpPost->cDescReason		:= PegaValores(oRequest,"TMP_ABOND")
		HttpPost->Justificativa		:= oJustificativa
	EndIf
    cHtml := ExecInPage( "PWSA161" )  
	
WEB EXTENDED END
Return cHtml


/*******************************************************************/
//* Funcao: PWSA162
//* Autor: Alex Adriano de Oliveira
//* Data: 30/12/2009
//* Justificativa de horarios - Gravacao
Web Function PWSA162()
Local cHtml   	:= ""
Local oOrg    
Local cRetorno	:= "" 
Local nOperacao := HttpPost->nOperacao
Private aScheduleAux := {}
Private aRequestAux  := {}

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
		oOrg:oWSREQUEST:cApproverBranch		   	:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
		oOrg:oWSREQUEST:cApproverRegistration  	:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
		oOrg:oWSREQUEST:nApproverLevel		   	:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
	    oOrg:oWSREQUEST:cEmpresaAPR	 			:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupEmpresa
		oOrg:oWSREQUEST:cDepartAPR	 			:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cDepartAprovador
		
	    GetMat()//Pega filial e matricula do participante 
	
		oOrg:oWSREQUEST:cSTARTERREGISTRATION 	:= HttpSession->aUser[3] //Filial do solicitante
		oOrg:oWSREQUEST:cStarterBranch			:= HttpSession->aUser[2] //matricula do solicitante
		oOrg:oWSREQUEST:cBRANCH 				:= HttpPost->cFilFun //filial do sortudo
		oOrg:oWSREQUEST:cREGISTRATION 			:= HttpPost->cMatFun //matricula do sortudo
		oOrg:oWSREQUEST:cVISION 				:= HttpSession->aInfRotina:cVisao
		oOrg:oWSREQUEST:cOBSERVATION    		:= Alltrim(HttpPost->txtobs)
		oOrg:oWSREQUEST:cEmpresa	 			:= GetEmpFun()
		
		oOrg:oWSSCHEDULEJUSTIFICATIONREQUEST:dINITIALDATE 		:= CTod(HttpPost->txtdataini)
		oOrg:oWSSCHEDULEJUSTIFICATIONREQUEST:dFINALDATE   		:= CTod(HttpPost->txtdatafim)
	
		if (HttpPost->txthorarioi != "")
			oOrg:oWSSCHEDULEJUSTIFICATIONREQUEST:nINITIALTIME 	:= TimeToFloat(HttpPost->txthorarioi)
		else
			oOrg:oWSSCHEDULEJUSTIFICATIONREQUEST:nINITIALTIME 	:= 0	
	    Endif
		if (HttpPost->txthorariof != "")    
			oOrg:oWSSCHEDULEJUSTIFICATIONREQUEST:nFINALTIME	  	:= TimeToFloat(HttpPost->txthorariof)	
		else
			oOrg:oWSSCHEDULEJUSTIFICATIONREQUEST:nFINALTIME 	:= 0	
	    Endif
	
		oOrg:oWSSCHEDULEJUSTIFICATIONREQUEST:cREASON	  		:= HttpPost->txtmotivo
	
		// - Efetua a c�pia dos Arrays contendo as propriedades 
		// - necess�rias para a requisi��o - ADDSCHEDULEJUSTIFICATIONREQUEST
		aScheduleAux := oOrg:oWSSCHEDULEJUSTIFICATIONREQUEST
		aRequestAux  := oOrg:oWSREQUEST
		
		If oOrg:GETJUSTIFICATION()
			// - Copiando os valores dos Arrays auxiliares 
			// - Para garantir que os dados n�o sejam passados com o conte�do NIL.
			oOrg:oWSSCHEDULEJUSTIFICATIONREQUEST := aScheduleAux 
			oOrg:oWSREQUEST := aRequestAux
			
			If oOrg:ADDSCHEDULEJUSTIFICATIONREQUEST()
				cRetorno := oOrg:cADDSCHEDULEJUSTIFICATIONREQUESTRESULT
				HttpGet->msg :=  STR0003  //"operacao realizada com sucesso"
			
				If(nOperacao == "4")
			    	W_PWSA115()
				Else 
		        	W_PWSA160()
		    	EndIf
			Else
				HttpSession->_HTMLERRO := { STR0002, PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
				Return ExecInPage("PWSAMSG" )
			EndIf
		Else
			HttpSession->_HTMLERRO := { PorEncode(STR0008), PorEncode(STR0009), "W_PWSA160.APW" }	
			Return ExecInPage("PWSAMSG" )
		EndIf
	Else
		HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
		Return ExecInPage("PWSAMSG" )
	EndIf
WEB EXTENDED END

Return cHtml   

/*******************************************************************/
//* Funcao: PWSA163
//* Autor: Alex Adriano Oliveira
//* Data: 30/12/09
//* Aprovacao de justificativa de horarios
Web Function PWSA163()

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
	oOrg:cKeyVision		 := Alltrim(HttpSession->DadosFunc:cKeyVision)

	If (lOk:= oOrg:GetStructure())
		If HttpPost->lPontoRH == ".T."
			aRetorno := ExecBlock("PontoRH",.F.,.F.,{"3", HttpSession->oRequests[1]:CBRANCH, Cod, HttpPost->txtvisao,nil,nil,HttpPost->txtobs,oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeFilial,oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration})
			If !aRetorno[1]
				lOk   := .F.
				cErro := aRetorno[2]
			EndIf
		Else
		    oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
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
	   	HttpGet->msg := STR0004 //"Aprovacao Gravada com sucesso"
	      	
	    If(nOperacao == "4")
		    W_PWSA115()
		Else 
	        W_PWSA160()
	    EndIf
	Else
		HttpSession->_HTMLERRO := {STR0003, cErro, "W_PWSA00C.APW"}		//"Erro" 
		Return ExecInPage("PWSAMSG" )
	EndIf	
WEB EXTENDED END

Return cHtml 

/*******************************************************************/
//* Funcao: PWSA164
//* Autor: Alex Adriano Oliveira
//* Data: 30/12/09
//* Reprovacao de justificativa de horario
Web Function PWSA164()

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
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
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
        	HttpGet->msg := STR0005 //"Reprovacao Gravada com sucesso"	    

		    If(nOperacao == "4")
			    W_PWSA115()
			Else 
		        W_PWSA160()
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
