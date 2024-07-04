#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"  
#INCLUDE "PWSA110.CH"
/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍ³±±
±±³Data Fonte Sustentação³ ChangeSet ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ³±±  
±±³    11/06/2015        ³  307834   ³±± 
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍ±±
*/ 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡…o ³ Web Functions responsaveis pela solicitacao de novos postos /³±±
±±³          ³ aumento de quadro e novas contratacoes / substituicoes.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ RH/Portais                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ FNC            ³  Motivo da Alteracao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Emerson Campos³07/03/14³M_RH001/196101  ³Ajustes para atender a P12      ³±±
±±³              ³        ³                ³                                ³±±
±±³Emerson Campos³22/04/14³M_RH003/310901  ³Ajustes para atender a P12      ³±±
±±³Emerson Campos|30/04/14|TPKFN9          |Replica alterações realizadas   ³±±
±±³              |        |                |pela manutenção até 25/03/14    ³±±
±±³              |        |                |chamado TPBAFB, changeset 215447³±±
±±³              |        |                |na P11.80                       ³±±
±±³              |        |                |                                ³±±
±±³              ³        ³                ³                                ³±±
±±³              ³        ³                ³                                ³±±
±±³Thiago Y.M.N  ³09/02/15³TRLGCC          ³Ajuste para impedir visualização³±±
±±³              ³        ³                ³de solicitações que não perten- ³±±
±±³              ³        ³                ³çam ao usuário logado no momento³±±
±±³Tiago Malta   ³24/08/15³PCREQ-4824      ³Ajuste no controle de alterações³±±
±±³			     ³		  ³	   		       ³ e consultas de dicionarios para³±±
±±³			     ³		  ³	   		       ³utilização na versão 12.        ³±±
±±³		         ³		  ³	               ³Changeset 307834 Data 11/06/2015³±±
±±³Matheus M.    ³01/02/16³TUGXBB          ³Realizado ajuste para utilizar a³±±
±±³			     ³		  ³	   		       ³matrícula do funcionário logado ³±±
±±³			     ³		  ³	   		       ³para utilizar no histórico de   ³±±
±±³			     ³		  ³	   		       ³solicitações, pois utilizava a  ³±±
±±³			     ³		  ³	   		       ³variável de sessão que era alte-³±±
±±³			     ³		  ³	   		       ³rada para o código da Rd0.		³±±
±±³Renan Borges  ³27/09/16³TVWVWI          ³Ajuste ao utilizar Visão por    ³±±
±±³              ³        ³                ³ Departamento e realizar a soli-³±±
±±³              ³        ³                ³tação para um membro da equipe, ³±±
±±³              ³        ³                ³seja carregado o aprovador cor- ³±± 
±±³              ³        ³                ³retamente, quando o responsável ³±± 
±±³              ³        ³                ³pelo departamento estiver em um ³±± 
±±³              ³        ³                ³departamento diferente ao do so-³±± 
±±³              ³        ³                ³licitante. Conceito utilizado   ³±± 
±±³              ³        ³                ³também para aumento de quadro e ³±± 
±±³              ³        ³                ³novas contratações.             ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*******************************************************************
* Funcao: PWSA110
* Autor: Flavio S. Correa
* Data: 26/11/09
* Lista de Departamentos - Aumento de Quadro
********************************************************************/
Web Function PWSA110()
	Local cHtml   	:= ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		HttpCTType("text/html; charset=ISO-8859-1")
		HttpGet->titulo           := STR0005 //"Novos Postos/Aumento de quadro"
		HttpSession->cTypeRequest := "3"
		HttpSession->cIDMENU	   := "GCH"
		cHtml := ExecInPage( "PWSA110" )	
	WEB EXTENDED END

Return cHtml

/***********************************************************************************************
* Funcao: PWSA110A
* Autor: Tatiane Matias
* Data: 25/11/10
* Lista de Departamentos - Novos Postos e Aumento de Quadro / Novas Contratações e Substituições
************************************************************************************************/
Web Function PWSA110A()
	Local oOrg
	Local cHtml   := ""

	Private nPageTotal
	Private nCurrentPage

	WEB EXTENDED INIT cHtml START "InSite"

	 	Default HttpGet->Page        := "1"
		Default HttpGet->FilterField := ""
		Default HttpGet->FilterValue := ""
	 	nCurrentPage:= Val(HttpGet->Page)

		oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
		WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
		                
		fGetInfRotina("W_PWSA110.APW")
		GetMat()							//Pega a Matricula e a filial do participante logado
	     
		oOrg:cVISION      	:= HttpSession->aInfRotina:cVisao
		oOrg:cPARTICIPANTID	:= HttpSession->cParticipantID 		
		oOrg:nPAGE		 	:= nCurrentPage
		oOrg:cFilterField   := HttpGet->FilterField
		oOrg:cFilterValue   := HttpGet->FilterValue		
			
		If oOrg:GetDepartment()
			HttpSession->Department := oOrg:oWSGETDEPARTMENTRESULT:oWSLISTOFDEPARTMENT:OWSDATADEPARTMENT
			nPageTotal 		         := oOrg:oWSGETDEPARTMENTRESULT:nPagesTotal
		Else
			HttpSession->Department := {}
			nPageTotal 		         := 1
		EndIf
			    
		HttpCTType("text/html; charset=ISO-8859-1")
		cHtml := ExecInPage( "PWSA110A" )	
	WEB EXTENDED END
Return cHtml


/********************************************************************************************************
* Funcao: PWSA111
* Autor: Flavio S. Correa
* Data: 26/11/09
* Lista de Postos do departamento - Novos Postos e Aumento de Quadro / Novas Contratações e Substituições
*********************************************************************************************************/
Web Function PWSA111()
	Local cHtml   	:= ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		HttpCTType("text/html; charset=ISO-8859-1")
		cHtml := ExecInPage( "PWSA111" )	
	WEB EXTENDED END

Return cHtml

/**********************************************************************
* Funcao: PWSA111A
* Novos Postos e Aumento de Quadro / Novas Contratacoes e Substituicoes
***********************************************************************/
Web Function PWSA111A()
	Local cHtml   	:= ""
	Local oOrg      
	Local nIndiceDepto	:= Val(HttpGet->nIndiceDepto)

	Private nCurrentPage
	Private nPageTotal
	
	WEB EXTENDED INIT cHtml START "InSite"                     
	 	Default HttpSession->Postos  := {}
		Default HttpGet->FilterField := ""
		Default HttpGet->FilterValue := ""
	 	Default HttpGet->Page        := "1"
	 	
	 	nCurrentPage:= Val(HttpGet->Page)
	 		 	
		oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
		WsChgURL(@oOrg, "ORGSTRUCTURE.APW",,,HttpSession->Department[nIndiceDepto]:cDepartmentEmp)

		//LISTA DE POSTOS	                
		oOrg:cCompanyID		:= HttpSession->Department[nIndiceDepto]:cDepartmentEmp
		oOrg:cDepartmentID	:= HttpSession->Department[nIndiceDepto]:cDepartment
		oOrg:cFilterField   := HttpGet->FilterField
		oOrg:cFilterValue	:= HttpGet->FilterValue
		oOrg:nPage			:= nCurrentPage
		oOrg:cRequestType   := HttpSession->cTypeRequest // 3-Novos Postos e Aumento de Quadro / 5-Novas Contratações e Substituições
		oOrg:cEmployeeFil   := HttpSession->aUser[2]
		oOrg:cRegistration  := HttpSession->aUser[3]
		oOrg:cPostoVis  	:= HttpSession->Department[nIndiceDepto]:cPostoVis


		HttpSession->DadosFunc := WsClassNew('ORGSTRUCTURE_DATAEMPLOYEE')
		HttpSession->DadosFunc:CEMPLOYEEEMP := HttpSession->Department[nIndiceDepto]:cDepartmentEmp
		
		If oOrg:GetPostos()
			HttpSession->Postos := oOrg:oWSGETPOSTOSRESULT:oWSLISTOFPOSTS:oWSDATAPOSTOS
			nPageTotal	        := oOrg:oWSGETPOSTOSRESULT:nPagesTotal
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf
				
		HttpCTType("text/html; charset=ISO-8859-1")		
		cHtml := ExecInPage( "PWSA111A" )	
	WEB EXTENDED END
Return cHtml

/*******************************************************************
* Funcao: PWSA111B
* Lista das solicitacoes
********************************************************************/
Web Function PWSA111B()
	Local cHtml   	:= ""
	Local oRequest

	Private nCurrentPage
	Private nPageTotal
	Private aMostra := {}
	
	HttpCTType("text/html; charset=ISO-8859-1")	 

	WEB EXTENDED INIT cHtml START "InSite"
                        
	 	Default HttpSession->oRequests := {}
		Default HttpGet->FilterField   := ""
		Default HttpGet->FilterValue   := ""
		Default HttpGet->Page          := "1"	 	
	 	nCurrentPage := Val(HttpGet->Page)
		                 
		If HttpSession->cTypeRequest $ "3*5" 	//3-Novos Postos/Aumento de Posto; 5-Nova Contratacao/Substituicao
			aMostra        := {"RBT_DEPTO", "RBT_CODPOS"}
			HttpGet->cLink := "W_PWSA112.APW"
		ElseIf HttpSession->cTypeRequest == "A" //A-Treinamentos
			aMostra := {"RA3_MAT", "TMP_NOME"}
			HttpGet->cLink := "W_PWSA102.APW"
		ElseIf HttpSession->cTypeRequest == "B" //B-Ferias
			aMostra := {"R8_MAT", "TMP_NOME"}
			HttpGet->cLink := "W_PWSA102.APW"
		ElseIf HttpSession->cTypeRequest == "4" //4-Transferencia
			aMostra := {"RE_MATD", "TMP_NOME"}
			HttpGet->cLink := "W_PWSA102.APW"
		ElseIf HttpSession->cTypeRequest == "6" //6-Desligamento
			aMostra := {"RA_MAT", "RA_NOME"}
			HttpGet->cLink := "W_PWSA102.APW"
		ElseIf HttpSession->cTypeRequest == "7" //7-Acao Salarial
			aMostra := {"TMP_NOME", "RB7_TPALT"}
			HttpGet->cLink := "W_PWSA102.APW"
		ElseIf HttpSession->cTypeRequest == "8" //8-Justificativa de Horario
			aMostra := {"TMP_NOME", "RF0_CODABO"}
			HttpGet->cLink := "W_PWSA102.APW"

        ElseIf HttpSession->cTypeRequest == "N" //N-Gestao Publica - Alteracao de Jornada
            aMostra := {"PF_MAT", "TMP_NOME"}
            HttpGet->cLink := "W_PWSA102.APW"
        ElseIf HttpSession->cTypeRequest == "O" //P-Gestao Publica - Saldo de Ferias
            aMostra := {"RA_MAT", "TMP_NOME"}
            HttpGet->cLink := "W_PWSA102.APW"
        ElseIf HttpSession->cTypeRequest == "P" //O-Gestao Publica - Programacao de Ferias
            aMostra := {"RA_MAT", "TMP_NOME"}
            HttpGet->cLink := "W_PWSA102.APW"
        ElseIf HttpSession->cTypeRequest == "Q" //Q-Gestao Publica - Diarias
            aMostra := {"RA_MAT", "TMP_NOME"}
            HttpGet->cLink := "W_PWSA102.APW"
        ElseIf HttpSession->cTypeRequest == "R" //R-Gestao Publica - Licencas e Afastamentos
            aMostra := {"RA_MAT", "TMP_NOME"}
            HttpGet->cLink := "W_PWSA102.APW"
        ElseIf HttpSession->cTypeRequest == "S" //S-Gestao Publica - Certidao Funcional
            aMostra := {"RA_MAT", "TMP_NOME"}
            HttpGet->cLink := "W_PWSA102.APW"
        ElseIf HttpSession->cTypeRequest == "T" //T-Gestao Publica - Saldo de Dias de Folga
            aMostra := {"RA_MAT", "TMP_NOME"}
            HttpGet->cLink := "W_PWSA102.APW"
        ElseIf HttpSession->cTypeRequest == "V" //Solicitação de Subsídio Acadêmico
            aMostra := {"RI1_MAT", "TMP_NOME"}
            HttpGet->cLink := "W_PWSA102.APW"
        ElseIf HttpSession->cTypeRequest == "Z" //Manutenção do Ponto Eletronico
            aMostra := {"P8_MAT", "P8_DATA"}
            HttpGet->cLink := "W_PWSA102.APW"
        EndIf
		
		//MINHAS SOLICITACOES	
		oRequest := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
		WsChgURL(@oRequest,"RHREQUEST.APW")
	
		oRequest:cRequestType   	   := HttpSession->cTypeRequest //3-Novos Postos/Aumento de Posto; 5-Nova Contratacao/Substituicao; B-Ferias; 4-Transferencias
		oRequest:cParticipantID 	   := HttpSession->cParticipantID
		oRequest:nCurrentPage 		:= nCurrentPage
		oRequest:cFilterField     	:= HttpGet->FilterField
		oRequest:cFilterValue		:= HttpGet->FilterValue
		If ValType(HttpSession->cIDMENU)== "C" .And. !Empty(HttpSession->cIDMENU)
			oRequest:cIDMENU:= HttpSession->cIDMENU
		EndIf
		If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat)
			oRequest:cEnrolmentID	:= HttpSession->RHMat
		EndIf	
		
		If oRequest:GetRequest()
			HttpSession->oRequests	:= oRequest:oWSGETREQUESTRESULT:oWSLISTOFREQUEST:OWSTREQUEST
			nPageTotal 	  			:= oRequest:oWSGETREQUESTRESULT:nPagesTotal
		Else
			HttpSession->_HTMLERRO	:= { STR0001, PWSGetWSError(), "W_PWSA000.APW","top" }	//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf

		HttpCTType("text/html; charset=ISO-8859-1")
		cHtml := ExecInPage( "PWSA111B" )	
	WEB EXTENDED END

Return cHtml

/*******************************************************************
* Funcao: PWSA112
* Autor: Alex Adriano Oliveira
* Data: 30/11/09
* Cadastro de novas vagas
********************************************************************/
Web Function PWSA112()

Local cHtml    	   := ""
Local oOrg
Local oRequest
Local oPosto

WEB EXTENDED INIT cHtml START "InSite"
          
	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
	WsChgURL(@oOrg,"ORGSTRUCTURE.APW")

  	             
  	If !(Valtype(HttpGet->cTypeRequest) == "U")
		HttpSession->cTypeRequest := HttpGet->cTypeRequest
  	EndIf
  	
   	If (HttpGet->nOperacao == "1")  
		HttpPost->Posto := HttpSession->Postos[val(HttpGet->nIndicePosto)]

   	ElseIf (HttpGet->nOperacao == "3") .Or. (HttpGet->nOperacao == "4")

   		oRequest := HttpSession->oRequests[val(HttpGet->nIndiceSolic)]		
    	
		oPosto := WSClassNew("ORGSTRUCTURE_DATAPOSTOS")        

		If HttpSession->cTypeRequest == "3"
			fGetInfRotina("W_PWSA110.APW") 		//Retorno HttpSession->aInfRotina
			oPosto:cCodDepto    := PegaValores(oRequest,"RBT_DEPTO")
			oPosto:cDescrDepto  := PegaValores(oRequest,"TMP_DDEPTO")
			oPosto:cPosto		:= PegaValores(oRequest,"RBT_CODPOS") 
			oPosto:cStatus		:= ""
			oPosto:cCodCargo	:= PegaValores(oRequest,"RBT_CARGO")
			oPosto:cDescrCargo  := PegaValores(oRequest,"TMP_DCARGO")
			oPosto:cCodFuncao	:= PegaValores(oRequest,"RBT_FUNCAO") 
			oPosto:cDescrFuncao := PegaValores(oRequest,"TMP_DFUNCA")
			oPosto:cCC		   	:= PegaValores(oRequest,"RBT_CC")
			oPosto:cDescrCC     := PegaValores(oRequest,"TMP_DCC")
			oPosto:nSalario		:= val(PegaValores(oRequest,"RBT_REMUNE"))
			oPosto:cTipoContrato:= PegaValores(oRequest,"RBT_TPCONT") 
			oPosto:nQtd	   		:= PegaValores(oRequest,"RBT_QTDMOV")
			oPosto:cTipo		:= PegaValores(oRequest,"RBT_TPOSTO") 
			oPosto:cNovaContr   := PegaValores(oRequest,"TMP_NOVACO") 
	
			HttpPost->Posto := oPosto

		Else
			//LISTA DE POSTOS
			fGetInfRotina("W_PWSA150.APW") 		//Retorno HttpSession->aInfRotina	                
			oOrg:cDepartmentID	:= PegaValores(oRequest,"RBT_DEPTO")
			oOrg:cPostID		:= PegaValores(oRequest,"RBT_CODPOS")
	
			If oOrg:GetPostos()
				HttpPost->Posto := oOrg:oWSGETPOSTOSRESULT:oWSLISTOFPOSTS:oWSDATAPOSTOS[1]
			Else
				HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
				Return ExecInPage("PWSAMSG" )
			EndIf			   		
		EndIf
             
		HttpPost->aDados := {}
		aadd(HttpPost->aDados, {PegaValores(oRequest,"RBT_CODPOS"),; 
								PegaValores(oRequest,"TMP_TIPO"),;
								PegaValores(oRequest,"TMP_FILIAL"),;
					 			PegaValores(oRequest,"TMP_MAT") })
   	EndIf
   	HttpCTType("text/html; charset=ISO-8859-1")
   	cHtml := ExecInPage("PWSA112")

WEB EXTENDED END

Return cHtml 

/*******************************************************************
* Funcao: PegaValores
* Retorna o valor de um determinado campo, da solicitação selecionada
********************************************************************/
Function PegaValores(oRequest,cCampo)
Local nPos        := ""
Local cValor      := ""

nPos := ascan(oRequest:OWSITEMS:OWSTREQUESTITEM,{|x| x:CFIELDNAME == cCampo}) 
If nPos > 0
	cValor := oRequest:OWSITEMS:OWSTREQUESTITEM[nPos]:cNewValue
EndIf

Return cValor

/*******************************************************************
* Funcao: PWSA113
* Autor: Alex Adriano Oliveira
* Data: 02/12/09
* Cadastro de novos Postos - Gravacao
********************************************************************/
Web Function PWSA113()

Local cHtml   	   := ""
Local oOrg    
Local oOrg2
Local nIndiceDepto := HttpPost->nIndiceDepto
Local nIndicePosto := val(HttpPost->nIndicePosto)
Local cCodPosto    := ""                          
Local cTpContrato  := HttpPost->ddltpcontrato     
Local cTpPosto     := HttpPost->ddltpposto
Local cFilFun      := ""
Local cMat         := ""
Local aFunc        := {}
Local cTipo        := HttpPost->ddltpopera


WEB EXTENDED INIT cHtml START "InSite"   
	If nIndicePosto > 0 
		cCodPosto    := HttpSession->Postos[nIndicePosto]:cPosto
		cTpContrato  := HttpPost->htipocontrato
		cTpPosto     := HttpPost->htipoposto
	EndIf
	
	oOrg2 := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
	WsChgURL(@oOrg2,"ORGSTRUCTURE.APW")
                          
	oOrg2:cParticipantID     := HttpSession->cParticipantID
	oOrg2:cTypeOrg		    := ""
	oOrg2:cVision			    := HttpSession->aInfRotina:cVisao
	If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat)
			oOrg2:cRegistration := HttpSession->RHMat
	EndIf
	oOrg2:cRequestType		:= HttpSession->cTypeRequest
		
	If oOrg2:GetStructure()
		oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
		WsChgURL(@oOrg,"RHREQUEST.APW",,,GetEmpFun())

		oOrg:oWSREQUEST:cBRANCH                    	:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeFilial
		oOrg:oWSREQUEST:cREGISTRATION               := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
		oOrg:oWSREQUEST:cStarterBranch              := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeFilial
		oOrg:oWSREQUEST:cStarterRegistration        := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
		oOrg:oWSREQUEST:cVISION                    	:= HttpSession->aInfRotina:cVisao
		oOrg:oWSREQUEST:cOBSERVATION                := HttpPost->txtobs
		oOrg:oWSREQUEST:cApproverBranch             := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
		oOrg:oWSREQUEST:cApproverRegistration       := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
		oOrg:oWSREQUEST:nApproverLevel              := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
		oOrg:oWSREQUEST:cEmpresaAPR	 		  		:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupEmpresa
		oOrg:oWSREQUEST:cEmpresa	 				:= GetEmpFun()
		oOrg:oWSREQUEST:cDepartAPR	 				:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cDepartAprovador
										
		//Solicitação de Novos Postos e Aumento de Quadro
		If HttpSession->cTypeRequest == "3" 
			oOrg:oWSPOSTREQUEST:cBRANCH            	:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeFilial
			oOrg:oWSPOSTREQUEST:cDEPARTMENTCODE    	:= HttpSession->Department[val(nIndiceDepto)]:cDepartment
			oOrg:oWSPOSTREQUEST:cCOSTCENTERCODE    	:= HttpPost->txtcc
			oOrg:oWSPOSTREQUEST:cROLECODE          	:= HttpPost->txtfuncao
			oOrg:oWSPOSTREQUEST:cPOSITIONCODE      	:= HttpPost->txtcargo
			oOrg:oWSPOSTREQUEST:nSALARY           	:= val(strTran(strTran(HttpPost->txtsalario, ".",""),",",".")) 
			oOrg:oWSPOSTREQUEST:cPOSTTYPE          	:= cTpPosto
			oOrg:oWSPOSTREQUEST:cCONTRACTTYPE      	:= cTpContrato
			oOrg:oWSPOSTREQUEST:nQUANTITY          	:= val(HttpPost->txtqtd)
			oOrg:oWSPOSTREQUEST:cREQUESTTYPE       	:= Iif(Empty(cCodPosto),"1","2")  //"1" quando for solicitação de novo posto ou "2" quando for solicitação de aumento de quadro.
			oOrg:oWSPOSTREQUEST:cJUSTIFICATIONCODE 	:= Iif(Empty(cCodPosto),"01","02")  //"01" quando for solicitação de novo posto ou "02" quando for solicitação de aumento de quadro
			oOrg:oWSPOSTREQUEST:cPOSTCODE          	:= Iif(Empty(cCodPosto),STR0017,cCodPosto)
			oOrg:oWSPOSTREQUEST:cPROCESSCODE       	:= ""
			oOrg:oWSPOSTREQUEST:cNewContract       	:= HttpPost->ddlNovaContr
		
			If oOrg:AddPostRequest()
				HttpGet->nIndiceDepto := nIndiceDepto
				HttpGet->msg          := STR0002 // "Operacao realizada com sucesso"
			
				W_PWSA110()
			Else
				HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
				Return ExecInPage("PWSAMSG" )
			EndIf        
													
		//Solicitação de Novas Contratações e Substituições
		ElseIf HttpSession->cTypeRequest == "5"
			If(cTipo == "2") 
				aFunc    := separa(HttpPost->ddlfunc,"/")
				cFilfun  := aFunc[1]
				cMat     := aFunc[2]
			Else
				cFilfun  := oOrg:oWSREQUEST:cBRANCH
				cMat     := oOrg:oWSREQUEST:cREGISTRATION  	   	
			EndIf           
									
			oOrg:oWSNEWCONTRACTREQUEST:cDepartmentCode          := HttpSession->Department[val(nIndiceDepto)]:cDepartment
			oOrg:oWSNEWCONTRACTREQUEST:cPOST                   	:= cCodPosto //Codigo do posto
			oOrg:oWSNEWCONTRACTREQUEST:cREPLACEDBRANCH			:= cFilfun	 //Filial do funcionario substituido
			oOrg:oWSNEWCONTRACTREQUEST:cREPLACEDREGISTRATION	:= cMat		 //Matricula do funcionario substituido
			oOrg:oWSNEWCONTRACTREQUEST:cTYPE					:= cTipo	 //Tipo: 1=Nova contracao;2=Substituicao
	
			If oOrg:ADDNEWCONTRACTREQUEST()
				HttpGet->nIndiceDepto := nIndiceDepto
				HttpGet->msg          := STR0002 // "Operacao realizada com sucesso"

				W_PWSA150()
			Else
				HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
				Return ExecInPage("PWSAMSG" )
			EndIf	
		EndIf		
	Else
		HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
		Return ExecInPage("PWSAMSG" )
	EndIf

WEB EXTENDED END

Return cHtml   

/*******************************************************************
* Funcao: PWSA114
* Autor: Alex Adriano	
* Data: 02/12/2009
* Lista Historico da solicitacao
********************************************************************/
Web Function PWSA114()
	Local cHtml   	:= ""
	Local oRequest
	Local nCodSolic	:= HttpGet->CodSolic
	Local aRequests := {}
	Local aReq2 	:= {}
	Private aHistory
	//H = igual 'vagas externas' e nao possui login
	
	If HttpSession->cTypeRequest == 'H' 
		WEB EXTENDED INIT cHtml
			//HISTORICO	
			oRequest := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
			WsChgURL(@oRequest,"RHREQUEST.APW")
			
			oRequest:cREQUESTID     := nCodSolic
			oRequest:cPARTICIPANTID := ""
			If oRequest:GETREQUESTHISTORY()
				aHistory := oRequest:oWSGETREQUESTHISTORYRESULT
			Else
				HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
				Return ExecInPage("PWSAMSG" )
			EndIf			
			HttpCTType("text/html; charset=ISO-8859-1")
			cHtml := ExecInPage( "PWSA114" )
		
		WEB EXTENDED END
	Else
		WEB EXTENDED INIT cHtml START "InSite"
			//HISTORICO	
			oRequest := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
			WsChgURL(@oRequest,"RHREQUEST.APW",,,httpGet->cEmpReq)
		
			oRequest:cBRANCH        := HttpSession->aUser[2]
			oRequest:cREQUESTID     := nCodSolic
		   If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat)
				oRequest:cPARTICIPANTID	:= HttpSession->RHMat
			Else
				oRequest:cPARTICIPANTID 	:= HttpSession->aUser[3]
			endIF
		   
		   	If oRequest:GETREQUESTHISTORY()
				aHistory := oRequest:oWSGETREQUESTHISTORYRESULT
			Else
				HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
				Return ExecInPage("PWSAMSG" )
			EndIf
			
			cHtml := ExecInPage( "PWSA114" )
		
		WEB EXTENDED END
	EndIf
	
Return cHtml	
		   

/*******************************************************************
* Funcao: PWSA115
* Autor: Flavio S. Correa
* Data: 03/12/2009
* Acompanhamento de solicitacoes
********************************************************************/
Web Function PWSA115() 
	Local cHtml:= ""
	
	OpenSm0()
	If Type("HttpSession->chkPendente1") == "U"
		HttpSession->chkPendente1   := "true"
	    HttpSession->chkAprovada1   := "true"
	    HttpSession->chkReprovada1  := "true"
	    HttpSession->chkPendente2   := "true"
	    HttpSession->chkAprovada2   := "true"
	    HttpSession->chkReprovada2  := "true"
    EndIf
	HttpSession->aSM0 := FWLoadSM0()
	HttpSession->cIDMENU	  := ""	 
	If ( fIsCorpManage() )
		HttpSession->lGestaoCorp := .T.			
	Else
		HttpSession->lGestaoCorp := .F.			
	EndIf

	WEB EXTENDED INIT cHtml START "InSite" 
		fGetInfRotina("W_PWSA115.APW") //Retorno HttpSession->aInfRotina		
		GetMat()
	
		HttpCTType("text/html; charset=ISO-8859-1")
		cHtml := ExecInPage( "PWSA115" )
	WEB EXTENDED END
	
Return cHtml 

/*******************************************************************
* Funcao: PWSA115A
* Acompanhamento de solicitacoes
********************************************************************/
Web Function PWSA115A() 
	Local cHtml       := ""
	Local oRequest
	Local cErro       := ""
	Local nI          := 1
	Local nPos        := 0
	Local cEnrolmentID	:= ""
	Local cChave		:= ""

	Private nCurrentPage
	Private nPageTotal	   := 1
	Private aRequests	   := {}
	Private aAprovRequests := {}	

	HttpCTType("text/html; charset=ISO-8859-1")	 
	
	WEB EXTENDED INIT cHtml START "InSite" 
		Begin Sequence				
			Default HttpSession->oRequests := {}
			Default HttpGet->FilterField   := ""
			Default HttpGet->FilterValue   := ""
			Default HttpGet->Page           := "1"

            Default HttpGet->OrdemValue    := "crescente"
            
            If ValType( &("HttpSession->chkPendente"+HttpGet->MyRequest) ) != "U" .And. ValType( HttpGet->chkPendente  ) == "U"
            	HttpGet->chkPendente   := &("HttpSession->chkPendente"+HttpGet->MyRequest)
            ElseIf ValType(&("HttpSession->chkPendente"+HttpGet->MyRequest)) == "U" 
            	HttpGet->chkPendente   := "true"
            EndiF
	 	    
	 	    If ValType(&("HttpSession->chkAprovada"+HttpGet->MyRequest) ) != "U" .And. ValType( HttpGet->chkAprovada  ) == "U"
            	HttpGet->chkAprovada   := &("HttpSession->chkAprovada"+HttpGet->MyRequest)
            ElseIf ValType( &("HttpSession->chkAprovada"+HttpGet->MyRequest) ) == "U" 
            	HttpGet->chkAprovada   := "true"
            EndiF
            
            If ValType( &("HttpSession->chkReprovada"+HttpGet->MyRequest) ) != "U" .And. ValType( HttpGet->chkReprovada  ) == "U"
            	HttpGet->chkReprovada   := &("HttpSession->chkReprovada"+HttpGet->MyRequest)
            ElseIf ValType(&("HttpSession->chkReprovada"+HttpGet->MyRequest) ) == "U" 
            	HttpGet->chkReprovada   := "true"
            EndiF
	 	    
	 	    &("HttpSession->chkPendente"+HttpGet->MyRequest)   := HttpGet->chkPendente
            &("HttpSession->chkAprovada"+HttpGet->MyRequest)   := HttpGet->chkAprovada
            &("HttpSession->chkReprovada"+HttpGet->MyRequest)  := HttpGet->chkReprovada
	 	
		 	nCurrentPage:= Val(HttpGet->Page)
		
			if HttpGet->MyRequest = "3"
				if ExistBlock("PontoRH")
					aRetorno := ExecBlock("PontoRH",.F.,.F.,{"2", HttpSession->cParticipantID})
				
					If aRetorno[1]
						aRequests := aRetorno[2]
					Else
						cErro := aRetorno[2]
						Break
					EndIf
				endif
			Else	
				oRequest := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
				WsChgURL(@oRequest,"RHREQUEST.APW")
				
				If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat) 
					cEnrolmentID	:= HttpSession->RHMat
				EndIf	
				
				oRequest:cRequestType	:= ""
				oRequest:cParticipantID	:= HttpSession->cParticipantID
				oRequest:nMyRequest		:= val(HttpGet->MyRequest)

				oRequest:nCurrentPage 	:= nCurrentPage
				oRequest:cFilterField    := HttpGet->FilterField
				oRequest:cFilterValue	:= HttpGet->FilterValue
				oRequest:cOrdem           := HttpGet->OrdemValue
                If HttpGet->chKPendente == "true"
                   oRequest:lPendentes  := .T.
                Else
                   oRequest:lPendentes  := .F.
                EndIf   
                If HttpGet->chKAprovada == "true"
                   oRequest:lAprovadas  := .T.
                Else
                   oRequest:lAprovadas  := .F.
                EndIf   
                If HttpGet->chKReprovada == "true"
                   oRequest:lReprovadas := .T.
                Else
                   oRequest:lReprovadas := .F.
                EndIf   

				oRequest:cEnrolmentID	:= cEnrolmentID
				If !Empty(HttpSession->cChave)
					oRequest:cChaveFunc		:= HttpSession->cChave
				EndIf	

				If oRequest:GetRequest()
					aRequests  := oRequest:oWSGETREQUESTRESULT:oWSLISTOFREQUEST:OWSTREQUEST
					nPageTotal := oRequest:oWSGETREQUESTRESULT:nPagesTotal
				Else
					cErro := PWSGetWSError()	
					Break
				EndIf
			EndIf
			
			For nI := 1 To Len(aRequests)
				If (nPos := AScan(HttpSession->oRequests, {|oReq| oReq:cCode == aRequests[nI]:cCode})) == 0
					Aadd(HttpSession->oRequests, aRequests[nI])
				Else
					HttpSession->oRequests[nPos]:CAPPROVERBRANCH        := aRequests[nI]:CAPPROVERBRANCH
					HttpSession->oRequests[nPos]:CAPPROVERREGISTRATION  := aRequests[nI]:CAPPROVERREGISTRATION
					HttpSession->oRequests[nPos]:NAPPROVERLEVEL         := aRequests[nI]:NAPPROVERLEVEL
					HttpSession->oRequests[nPos]:OWSSTATUS:CCODE        := aRequests[nI]:OWSSTATUS:CCODE
					HttpSession->oRequests[nPos]:OWSSTATUS:CDESCRIPTION := aRequests[nI]:OWSSTATUS:CDESCRIPTION
				EndIf

				If aRequests[nI]:cApproverRegistration == HttpSession->aUser[3] .AND.;
				   aRequests[nI]:cApproverBranch 	   == HttpSession->aUser[2]
					Aadd(aAprovRequests, aRequests[nI]:cCode)	   
				EndIf
			Next			

		End Sequence
		
		If Empty(cErro)
			HttpCTType("text/html; charset=ISO-8859-1")
			cHtml := ExecInPage( "PWSA115A" )
		Else
			HttpSession->_HTMLERRO := { STR0001, cErro, "W_PWSA000.APW","top" }         //"Erro"
			cHtml:= ExecInPage("PWSAMSG" )
		EndIf  
	
	WEB EXTENDED END
Return cHtml 


/*******************************************************************
* Funcao: PWSA116
* Autor: Alex Adriano Oliveira
* Data: 08/12/09
* Aprovacao de solicitacoes
********************************************************************/
Web Function PWSA116()
Local oOrg    
Local oObj    
Local nIndiceSolic := HttpPost->nIndiceSolic
Local nOperacao	   := HttpPost->nOperacao
Local lOk          := .T.
Local cErro        := ""
Local cHtml   	   := ""

WEB EXTENDED INIT cHtml START "InSite"	
	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
   	WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
   
   	If HttpSession->cTypeRequest == "6"//Solicitacao de desligamento
		nIndiceSolic := HttpSession->nIndiceSolic
		nOperacao    := HttpSession->nOperacao
	EndIf   
   	                  
	oOrg:cVision         := HttpSession->oRequests[val(nIndiceSolic)]:CVISION
	oOrg:cEmployeeFil    := HttpSession->oRequests[val(nIndiceSolic)]:CBRANCH
	oOrg:cRegistration   := HttpSession->oRequests[val(nIndiceSolic)]:CREGISTRATION
	oOrg:cEmployeeSolFil := HttpSession->aUser[2]
	oOrg:cRegistSolic	 := HttpSession->aUser[3]
	oOrg:cRequestType	 := HttpSession->cTypeRequest
	If HttpSession->cTypeRequest $ "3|5"
		oOrg:cDepartmentId := HttpPost->cCodDepto
	EndIf

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
			oObj:oWsRequest:cBranch                := HttpSession->oRequests[val(nIndiceSolic)]:cBranch
			oObj:oWsRequest:cRegistration          := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
			oObj:oWsRequest:cCode                  := HttpSession->oRequests[val(nIndiceSolic)]:cCode
			oObj:oWsRequest:cObservation           := AllTrim(HttpPost->txtobs)
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
       	HttpGet->msg := STR0003 //"Aprovacao Gravada com sucesso"
       	
        If(nOperacao == "4")
		    W_PWSA115()
		Else
			If HttpSession->cTypeRequest == "3" 
		        W_PWSA110()
		 	ElseIf HttpSession->cTypeRequest == "5" 
		        W_PWSA150()
		 	ElseIf HttpSession->cTypeRequest == "6" 
		        W_PWSA130()
		 	ElseIf HttpSession->cTypeRequest == "B" 
		        W_PWSA100a()
		 	EndIf
	    EndIf
	Else
		HttpSession->_HTMLERRO := {STR0001, cErro, "W_PWSA00C.APW"}		//"Erro" 
		Return ExecInPage("PWSAMSG" )
	EndIf 
	
WEB EXTENDED END

Return cHtml 

/*******************************************************************
* Funcao: PWSA117
* Autor: Alex Adriano Oliveira
* Data: 08/12/09
* Reprovacao de solicitacoes
********************************************************************/
Web Function PWSA117()
	Local cHtml   	   := ""
	Local oOrg    
	Local oObj    
	Local nIndiceSolic := HttpPost->nIndiceSolic
	Local nOperacao	   := HttpPost->nOperacao

	WEB EXTENDED INIT cHtml START "InSite"		
    GetMat()

	 oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
    WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
     	
    oOrg:cParticipantID 	:= HttpSession->cParticipantID
    oOrg:cVision				:= HttpSession->aInfRotina:cVisao                       	
    If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat)
        oOrg:cRegistration := HttpSession->RHMat
    EndIf 
      
	If HttpSession->cTypeRequest == "6"//Solicitacao de desligamento
		nIndiceSolic := HttpSession->nIndiceSolic
		nOperacao    := HttpSession->nOperacao
	EndIf
		
    If oOrg:GetStructure()       
			oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
						
			WsChgURL(@oObj, "RHREQUEST.APW")   

			oObj:oWsRequest	                    	:= RHREQUEST_TREQUEST():New()
			oObj:oWsRequest:cBranch              	:= HttpSession->oRequests[val(nIndiceSolic)]:cBranch
			oObj:oWsRequest:cRegistration         	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
			oObj:oWsRequest:cCode               	:= HttpSession->oRequests[val(nIndiceSolic)]:cCode
			oObj:oWsRequest:cObservation          	:= AllTrim(HttpPost->txtobs)
			oObj:oWsRequest:cApproverBranch		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
			oObj:oWsRequest:cApproverRegistration  	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
			oObj:oWsRequest:nApproverLevel		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
			oObj:oWSREQUEST:cEmpresaAPR	 		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupEmpresa
					
			If oObj:ReproveRequest()
	        	HttpGet->msg := STR0004 //"Reprovacao Gravada com sucesso"	    

			  If(nOperacao == "4")
				    W_PWSA115()
				Else    
					If HttpSession->cTypeRequest == "3" 
				        W_PWSA110()
				 	ElseIf HttpSession->cTypeRequest == "5" 
				        W_PWSA150()
		 			ElseIf HttpSession->cTypeRequest == "6" 
				        W_PWSA130()
		      ElseIf HttpSession->cTypeRequest == "B" 
				        W_PWSA100a()
				 	EndIf
			  Endif    
			    
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
  
Function GetMat()
	Local oObj
	Local oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())

	If HttpSession->cParticipantID == NIL
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
		WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")
		
		If !Empty( HttpSession->Login )
			If oObj:GETPARTICIPANT( "", HttpSession->Login, HttpSession->cAcessoPP )
				HttpSession->cParticipantID		:= oObj:oWSGETPARTICIPANTRESULT:CPARTICIPANTID
				HttpSession->cParticipantName	:= AllTrim(oObj:oWSGETPARTICIPANTRESULT:CPARTICIPANTNAME)
				HttpSession->Participant		:= oObj:oWSGETPARTICIPANTRESULT				
			EndIf
		EndIf	
	EndIf
	If Valtype(HttpSession->aUser) == "U"
		WsChgURL(@oOrg, "ORGSTRUCTURE.APW")
		oOrg:cParticipantID	 := HttpSession->cParticipantID
		oOrg:cVision		 := HttpSession->aInfRotina:cVisao
		If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat)
			oOrg:cRegistration	:= HttpSession->RHMat
			oOrg:cEmployeeFil    := HttpSession->RhFilMat
		EndIf
		If ValType(HttpSession->Login) != "U" .And. !Empty(HttpSession->Login)
			oOrg:cParticipantID	:= HttpSession->Login
		EndIf
	
		If oOrg:GetEmployee()
			If len(oOrg:oWSGetEmployeeResult:oWSLISTOFEMPLOYEE:oWSDataEmployee) > 0
				HttpSession->aUser := {	HttpSession->cParticipantID,;
										oOrg:oWSGetEmployeeResult:oWSLISTOFEMPLOYEE:oWSDataEmployee[1]:cEmployeeFilial,;
										oOrg:oWSGetEmployeeResult:oWSLISTOFEMPLOYEE:oWSDataEmployee[1]:cRegistration,;    
										oOrg:oWSGetEmployeeResult:oWSLISTOFEMPLOYEE:oWSDataEmployee[1]:cEmployeeEmp}
			Else
				HttpSession->aUser := {HttpSession->cParticipantID, "", "",""}
			Endif												
		Else
			HttpSession->aUser := {HttpSession->cParticipantID, "", "",""}  
		Endif
	EndIf
Return .T.

Function GetMatTransf()
    Local oWSFunc := WSRHEmployeeTransf():New()
    HttpSession->aUserTransf := {}

    WsChgURL(@oWSFunc, "RHEmployeeTransf.APW")
    oWSFunc:cCompany				  := HttpSession->RHAmbEmp //Empresa
    oWSFunc:cEmployeeFil		  := HttpSession->aUser[2] //Filial
    oWSFunc:cRegistration	     := HttpSession->aUser[3] //matricula
    oWSFunc:cTypeTransf			  := "3"	               //tipo da transferencia (Apenas filial na mesma empresa)
    If oWSFunc:GetEmployeeTransf()
       HttpSession->aUserTransf  := oWSFunc:oWSGetEmployeeTransfResult
    EndIf

Return .T.

/*******************************************************************
* Funcao: PWSA118
* Autor: Flavio Correa
* Data: 05/02/15
* Checagem funcao/cargo/salario
********************************************************************/
Web Function PWSA118()
	Local cHtml   	   := ""
	Local oOrg	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
	
	WEB EXTENDED INIT cHtml START "InSite"		

	WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
	If oOrg:GetCargo(HttpSession->aUser[2],httpGet->filtro)		
    	cHtml := "<CARGO><CODIGO>"+oOrg:oWSGETCARGORESULT:cCargoId+"</CODIGO><SALARIO>"+Alltrim(transform(oOrg:oWSGETCARGORESULT:nSalario,"@E 9,999,999,999.99"))+"</SALARIO><CC>"+oOrg:oWSGETCARGORESULT:cCENTROCUSTOID+"</CC><DESCRICC>"+oOrg:oWSGETCARGORESULT:cCENTROCUSTO+"</DESCRICC><DESCRICARGO>"+oOrg:oWSGETCARGORESULT:cCARGODESCR+"</DESCRICARGO></CARGO>"
    Else
    	cHtml := GetWscerror(3)
    EndIf 			
    
	WEB EXTENDED END
	
Return cHtml 
