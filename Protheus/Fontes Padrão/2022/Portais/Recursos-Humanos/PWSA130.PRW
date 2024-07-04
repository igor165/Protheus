#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#include "PWSA130.CH"

/*******************************************************************
* Funcao: PWSA130
* Autor: Alex Adriano de Oliveira
* Data: 07/12/2009
* Solicitacao de Desligamento
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Uso       ³ RH/Portais                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Analista     ³ Data   ³FNC:            ³  	Motivo da Alteracao         ³±±
±±³Marcelo Faria |16/02/11|00000023761/2010|Padronizacao do serviço de soli-³±±
±±³              |        |Chamado:        |citacao de desligamento, como   ³±±
±±³              |        |SCYFGD          |outros serviços de solicitacao  ³±±
±±³              |        |                |disponibilizados no Portal.     ³±±
±±³Allyson M     |25/03/14|TPBAFB          |-Ajusta na busca do superior do ³±±
±±³              |        |                |funcionario p/ aprovacao do     ³±±
±±³              |        |                |desligamento.                   ³±±
±±³Renan Borges  ³14/07/15³TSRISM          ³Ajuste para apenas carregar a pa³±±
±±³              ³        ³                ³gina se não houver erro na carga³±±
±±³              ³        ³                ³da estrutura organizacional.    ³±±
±±³Esther V.     |10/12/15|PCDEF-87126     |Ajuste para exibir descricao do ³±±
±±³              |        |                |tipo de desligamento selecionado³±±
±±³Renan Borges  ³25/04/16³TUZCRD          ³Ajuste para cadastrar configura-³±±
±±³              ³        ³                ³ções de ambiente corretamente pa³±±
±±³              ³        ³                ³ra ser possível a transferência ³±±
±±³              ³        ³                ³de um artefato para o servidor, ³±±
±±³              ³        ³                ³permitindo sua visualização no  ³±±
±±³              ³        ³                ³Portal.                         ³±±
±±³Renan Borges  ³12/09/16³TVWVWI          ³Ajuste ao utilizar Visão por    ³±±
±±³              ³        ³                ³ Departamento e realizar a soli-³±±
±±³              ³        ³                ³tação para um membro da equipe, ³±±
±±³              ³        ³                ³seja carregado o aprovador cor- ³±± 
±±³              ³        ³                ³retamente, quando o responsável ³±± 
±±³              ³        ³                ³pelo departamento estiver em um ³±± 
±±³              ³        ³                ³departamento diferente ao do so-³±± 
±±³              ³        ³                ³licitante.                      ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Web Function PWSA130()
	
	Local cHtml   	:= ""
	
	WEB EXTENDED INIT cHtml START "InSite"
	HttpSession->cTypeRequest := "6"		// Demissao - Desligamento
	HttpGet->titulo           := STR0002 	//"Solicitacao de Desligamento"
	HttpSession->aStructure   := {}
	HttpSession->cHierarquia  := ""
	
	fGetInfRotina("W_PWSA130.APW")
	GetMat()								//Pega a Matricula e a filial do participante logado
	
	//cHtml := ExecInPage("PWSA130A")
	cHtml := ExecInPage("PWSA120A")
	WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA131
* Autor: Alex Adriano de Oliveira
* Data: 07/12/2009
* Solicitacao de desligamento - interacao
********************************************************************/
Web Function PWSA131()
	
	Local cHtml   	:= ""
	Local cKey 		:= ""
	Local nIndice 	:= 0
	Local oDeslig
	Local oRequest
	Local oObj
	
	if(valtype(HttpGet->nIndice) != "U")
		nIndice := val(HttpGet->nIndice)
	endif
	
	WEB EXTENDED INIT cHtml START "InSite"
	If Empty( HttpSession->_HTMLERRO )
		// Seleciona Tipo de consulta padrao para tipo de desligamento	
		DO CASE		
			CASE cPaisLoc == "BRA"	
				HttpSession->cConsPadrao := "S43BRP" 	  //Brasil
			CASE cPaisLoc == "ARG"
				HttpSession->cConsPadrao := "S12ARG" //Argentina
			CASE cPaisLoc == "MEX"
				HttpSession->cConsPadrao := "X61MEX" //Mexico
			CASE cPaisLoc == "ANG"
				HttpSession->cConsPadrao := "S15ANG" //Angola
			CASE cPaisLoc == "HAI"
				HttpSession->cConsPadrao := "S02HAI" //Haiti
			CASE cPaisLoc == "PER"
				HttpSession->cConsPadrao := "S25PER" //Peru
			CASE cPaisLoc == "COL"
				HttpSession->cConsPadrao := "S24COL" //Colombia
			OTHERWISE
				HttpSession->cConsPadrao := "X61"    // Outros paises
		ENDCASE	
		
		//Pega filial e matricula do participante
		GetMat()
		
		If (HttpGet->nOperacao == "1")
			HttpSession->DadosFunc := HttpSession->aStructure[val(HttpGet->nIndice)]
		ElseIf (HttpGet->nOperacao == "3") .Or. (HttpGet->nOperacao == "4")
			oRequest := HttpSession->oRequests[val(HttpGet->nIndiceSolic)]
			oDeslig  := WSClassNew("RHREQUEST_TTermination")
			
			oDeslig:cType    	:= PegaValores(oRequest,"RX_COD")
			HttpPost->cDType	:= PegaValores(oRequest,"RX_TXT")
			//Carrega descricao do Tipo de Rescisao
			If HttpPost->cDType = ""
					oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHRequest"), WSRHRequest():New())
					WsChgURL(@oObj,"RHREQUEST.APW" ,,,GetEmpFun())
					cKey := "S043"
					cKey += PegaValores(oRequest,"RX_COD")
					
					oObj:cTableSearch   := "RCC"
					oObj:cTableIndex    := "1"
					oObj:cKeyField      := cKey
					oObj:cFieldResponse := "SubStr(RCC->RCC_CONTEU,1,30)"
					
					If oObj:GetDescription()
						HttpPost->cDType := oObj:cGetDescriptionResult
					EndIf
			EndIf
			oDeslig:cNewHire 	:= PegaValores(oRequest,"TMP_NOVAC")
			HttpPost->Deslig    := oDeslig
		EndIf
		
		cHtml := ExecInPage( "PWSA131" )
	EndIf
	WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA132
* Autor: Alex Adriano de Oliveira
* Data: 08/12/2009
* Solicitacao de desligamento - Gravacao
********************************************************************/
Web Function PWSA132()
	Local cHtml   	:= ""
	Local oOrg
	Local cRetorno	:= ""
	Local nOperacao := HttpPost->nOperacao
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHRequest"), WSRHRequest():New())
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
		//Pega filial e matricula do participante
		GetMat()
		
		oOrg:oWSREQUEST:cApproverBranch		   	:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
		oOrg:oWSREQUEST:cApproverRegistration  	:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
		oOrg:oWSREQUEST:nApproverLevel		   	:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
	    oOrg:oWSREQUEST:cEmpresaAPR	 			:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupEmpresa
		
		oOrg:oWSREQUEST:cSTARTERREGISTRATION 	:= HttpSession->aUser[3] //Filial do solicitante
		oOrg:oWSREQUEST:cStarterBranch			:= HttpSession->aUser[2] //matricula do solicitante
		oOrg:oWSREQUEST:cBRANCH 				:= HttpPost->cFilFun 	 //filial do participante
		oOrg:oWSREQUEST:cREGISTRATION 			:= HttpPost->cMatFun 	 //matricula do participante
		oOrg:oWSREQUEST:cEmpresa	 			:= GetEmpFun()			 //matricula do participante
		oOrg:oWSREQUEST:cVISION 				:= HttpSession->aInfRotina:cVisao
		oOrg:oWSREQUEST:cOBSERVATION    		:= Alltrim(HttpPost->txtobs)
		oOrg:oWSREQUEST:cEmpresa	 			:= GetEmpFun()
		oOrg:oWSREQUEST:cDepartAPR	 			:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cDepartAprovador
		
		oOrg:oWSTERMINATIONREQUEST:cNEWHIRE		:= HttpPost->ddlgera 	 //gera nova?
		oOrg:oWSTERMINATIONREQUEST:cTYPE		:= HttpPost->txttipo	 //tipo
		
		If oOrg:ADDTERMINATIONREQUEST()
			cRetorno := oOrg:cADDTERMINATIONREQUESTRESULT
			HttpGet->msg := STR0003 //"Operacao realizada com sucesso"
			
			If(nOperacao == "4")
				W_PWSA115()
			Else
				W_PWSA130()
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


/****************************************************************************
* Funcao: PWSA135
* Autor: Marcelo M Faria
* Data: 24/02/11
* Solicitacao de Desligamento - Busca descricao do tipo de desligamento
* As consultas padroes referentes ao tipo, nao foram alteradas para incluir
* o retorno da descricao, pois poderia afetar o resultado de telas no remote
*****************************************************************************/
Web Function PWSA135()
	Local cHtml := ""
	Local cKey	:= ""
	
	WEB EXTENDED INIT cHtml
	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHRequest"), WSRHRequest():New())
	If !Empty(httpSession->cEmpTrans) .And. HttpSession->cTypeRequest == "4"
		WsChgURL(@oObj, "RHREQUEST.APW",,,httpSession->cEmpTrans)
	Else
		WsChgURL(@oObj, "RHREQUEST.APW",,,GetEmpFun())
	EndIf
	cKey := HttpGet->cTip
	cKey += HttpGet->cChav
	
	oObj:cTableSearch   := HttpGet->cTab
	oObj:cTableIndex    := HttpGet->cInd
	oObj:cKeyField      := cKey
	oObj:cFieldResponse := HttpGet->cRet
	
	If oObj:GetDescription()
		cHtml := Encodeutf8(oObj:cGetDescriptionResult)
	EndIf
	
	If HttpGet->cRet == "SM0->M0_NOME"  .And. HttpSession->cTypeRequest == "4"
		httpSession->cEmpTrans := cKey
	EndIf
	
	WEB EXTENDED END
RETURN cHtml
