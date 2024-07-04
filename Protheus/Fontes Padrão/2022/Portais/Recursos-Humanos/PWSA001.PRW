#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA001PRW.CH"

#DEFINE cCodUser "MSALPHA"

/*************************************************************/
/* Pagina de abertura da avaliacao de desempenho			*/
/* Juliana Barros  29/09/2005								*/
/*************************************************************/
Web Function PWSA001()

Local cHtml 	:= ""
Local oParam	:= ""
Local oMsg		:= ""                        

Private cProj   := "1"//Exibe Avaliacao de Projetos?

WEB EXTENDED INIT cHtml  

oParam  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
oMsg 	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
WsChgURL(@oParam,"CFGDICTIONARY.APW") 
WsChgURL(@oMsg,"RHPERSONALDESENVPLAN.APW") 

HttpPost->cMsg := STR0001 	//Realizar   avalia&ccedil;&otilde;es de desempenho, para acompanhar e auxiliar a evolu&ccedil;&atilde;o da performance   dos participantes.

//RESGATA PARAMETRO CONTENDO CODIGO DA MENSAGEM
//SE EM QUALQUER SITUACAO MSG NAUM ESTIVER CADASTRADA OU ESTIVER EM BRANCO, VALE MSG DEFAULT
If oParam:GETPARAM( cCodUser, "MV_MSGAD" )
	If !Empty(oParam:cGETPARAMRESULT)  .AND. oParam:cGETPARAMRESULT != ".F."
		If oMsg:GETMESSAGE( cCodUser, oParam:cGETPARAMRESULT )
			If !Empty(oMsg:cGETMESSAGERESULT)
				HttpPost->cMsg := StrTran( oMsg:cGETMESSAGERESULT, Chr( 10 ), "<br>" )
			EndIf		
		EndIf
	EndIf
EndIf 

//Busca o parametro que indica se exibe o item Avaliacao de Projeto. 1=Exibe;2=Nao exibe
//Se o parametro nao existir, o padrao e exibir o item no Portal
If oParam:GETPARAM( cCodUser, "MV_APDPROJ" )
	If !Empty(oParam:cGETPARAMRESULT) 
		cProj := AllTrim( oParam:cGETPARAMRESULT )
	EndIf
EndIf
                      
cHtml += ExecInPage( "PWSA001" )

WEB EXTENDED END

Return cHtml


/*************************************************************/
/* Pagina de abertura do plano de metas						*/
/* Juliana Barros  29/09/2005								*/
/*************************************************************/
Web Function PWSA004()

Local cHtml		:= ""
Local oParam 	:= ""
Local oMsg		:= ""


WEB EXTENDED INIT cHtml START "InSite"
                 
oParam  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
oMsg 	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
WsChgURL(@oParam,"CFGDICTIONARY.APW") 
WsChgURL(@oMsg,"RHPERSONALDESENVPLAN.APW") 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SESSION PARA VERIFICAR QUAL O TIPO DE TELA QUE SERA MOSTRADA  |
//³ PDP=PLANO DE DESENVOLVIMENTO PESSOAL; PM=PLANO DE METAS		  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->cTipoPlano := "PM"
                             
HttpPost->cMsg := STR0002	//"Planejar e acompanhar metas estabelecidas, garantindo feedbacks regulares e consistentes aos participantes,  servindo de base para ações de reconhecimento de acordo com a política da organização"

//RESGATA PARAMETRO CONTENDO CODIGO DA MENSAGEM
//SE EM QUALQUER SITUACAO MSG NAUM ESTIVER CADASTRADA OU ESTIVER EM BRANCO, VALE MSG DEFAULT
If oParam:GETPARAM( cCodUser, "MV_MSGPM" )
	If !Empty(oParam:cGETPARAMRESULT) 
		If oMsg:GETMESSAGE( cCodUser, oParam:cGETPARAMRESULT )
			If !Empty(oMsg:cGETMESSAGERESULT)
				HttpPost->cMsg := StrTran( oMsg:cGETMESSAGERESULT, Chr( 10 ), "<br>" )
			EndIf		
		EndIf
	EndIf
EndIf   

//Verifica se deve ser liberada a funcionalidade de 'Inclusão Nova'
HttpSession->cIncluir	:= "1"	
If oParam:GETPARAM( cCodUser, "MV_APDINCN" )    
	HttpSession->cIncluir	:= oParam:cGETPARAMRESULT
	If !(oParam:cGETPARAMRESULT $ '1*2*3*')
		HttpSession->cIncluir	:= "1"	
	EndIf 
EndIf

//Verifica se Disponibiliza o bloco 'Meus Pares' nas páginas 'Pendências Atuais' e 'Consulta Histórico' nos Planos de Metas e Desenvolvimento? (1-Sim, 2-Não)", 
HttpSession->cAPDCPAR   := '1'	
IF oParam:GETPARAM( cCodUser, "MV_APDCPAR" )
	HttpSession->cAPDCPAR := oParam:cGETPARAMRESULT	
	If !(oParam:cGETPARAMRESULT $ '1*2*')
		HttpSession->cAPDCPAR   := '1'	
	EndIf 
ENDIF

//PARAMETRO QUE VERIFICA SE APROVACAO DE VERSAO PODE FUNCIONAR OU NAO
//SE RETORNO DO PARAMETRO = 1 NAO EXISTIRAO APROVACOES DE VERSAO
//CASO CONTRARIO, CONTROLE DE VERSAO EXISTIRA NORMALMENTE
HttpSession->cAprvPm := ''
If oParam:GETPARAM( cCodUser, "MV_APRVPM" )
	HttpSession->cAprvPm := AllTrim(oParam:cGETPARAMRESULT)
	If !(oParam:cGETPARAMRESULT == '1')
		HttpSession->cAprvPm   := ''	
	EndIf 
EndIf  

HttpSession->cApdIncB   := '1'	
If oParam:GETPARAM( cCodUser, "MV_APDINCB" )
	HttpSession->cApdIncB := AllTrim(oParam:cGETPARAMRESULT)
	If !(oParam:cGETPARAMRESULT $ '1*2*3*')
		HttpSession->cApdIncB   := '1'	
	EndIf 
EndIf

cHtml += ExecInPage( "PWSA004" )

WEB EXTENDED END

Return cHtml

/*************************************************************/
/* Pagina de abertura do plano de metas						*/
/* Juliana Barros  29/09/2005								*/
/*************************************************************/
Web Function PWSA006()
	Local cHtml := ""
	Local oObj,oObjItem,oParam	:= ""
	Local nI,nX 	:= 0
	
	WEB EXTENDED INIT cHtml START "InSite"
	
	oParam  	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
	oObj 		:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
	oObjItem	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())//Tratativa para o retorno dos itens das metas dos pares
	
	
	WsChgURL(@oParam,"CFGDICTIONARY.APW")
	WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")
	WsChgURL(@oObjItem,"RHPERSONALDESENVPLAN.APW")
	
	HttpSession->ObjectiveTopics := {}
	
	If Empty(HttpGet->cTipoCurso)
		HttpGet->cTipoCurso := ""
	EndiF
	
	//Determinar se disponibiliza as colunas '% Ating.' e 'Resultado Acumulado' nas consultas de Metas de Pares ? (1-Sim, 2-Não)
	HttpSession->cAPDRES2 := '2' //2-Nao
	IF oParam:GETPARAM( cCodUser, "MV_APDRES2" ) 
		HttpSession->cAPDRES2 := oParam:cGETPARAMRESULT	
		If !(oParam:cGETPARAMRESULT $ '1*2*')
			HttpSession->cAPDRES2	:= '2'	
		EndIf 
	ENDIF

	//Se nao tiver avaliador cadastrado, envia para pagina de cadastro
	If Empty(HttpGet->cCodAvaliador) .And. Empty(HttpGet->cParticipant)
		cHtml := ExecInPage( "PWSA040A" )
	Else
		If !Empty(HttpSession->cUser) .and. !Empty(HttpGet->cCodPlano) .and. !Empty(HttpGet->cCodPeriod) .and. (!Empty(HttpGet->cCodAvaliador) .Or. !Empty(HttpGet->cParticipant))
			//atribuicao de Sessoes para o usuário logado
			If Empty(HttpGet->cCodAvaliador) .and. !Empty(HttpGet->cParticipant) 		//indica que e Meu Time
				HttpSession->EvaluatorId 	:= HttpGet->ObjectiveAvaliaterID	  		//o Avaliador recebido por parametro
				HttpSession->cUser 			:= HttpGet->cParticipant			  		//o Avaliado sera eviado por Get
				HttpSession->cAuthor		:= "2"								  		//o Autor sera o Avaliador=2
			ElseIf !Empty(HttpGet->cCodAvaliador) .and. Empty(HttpGet->cParticipant) 	//indica que e Meus Planos
				HttpSession->EvaluatorId 	:= HttpGet->cCodAvaliador					//o Avaliador sera enviado por Get
				HttpSession->cUser 			:= HttpSession->cParticipantID				//o Avaliado sera quem esta logado
				HttpSession->cAuthor		:= "1"										//o Autor sera o Avaliado=1
			Else
				HttpSession->_HTMLERRO := { STR0003, STR0004, "W_PWSA040.APW" } //"Erro"###"Erro inesperado favor contactar o suporte"
				Return ExecInPage("PWSAMSG")
			Endif
			
			If oObj:ObjectiveTopics(cCodUser, HttpGet->cCodPlano, HttpGet->cCodPeriod, HttpSession->cUser, HttpSession->EvaluatorId)
				HttpSession->DescrObjective		:= oObj:oWSOBJECTIVETOPICSRESULT:cDESCROBJECTIVIES
				HttpSession->PermissonStatus	:= oObj:oWSOBJECTIVETOPICSRESULT:cSTATUS
				HttpSession->ParticipantName  	:= oObj:oWSOBJECTIVETOPICSRESULT:cNAMEAVALIADO
				HttpSession->EvaluatorName		:= oObj:oWSOBJECTIVETOPICSRESULT:cNAMEAVALIADOR
				HttpSession->DescrParticipant	:= oObj:oWSOBJECTIVETOPICSRESULT:cDESCRPARTICIPANT
				HttpSession->PlanVersion		:= oObj:oWSOBJECTIVETOPICSRESULT:cPlanVersion
				HttpSession->PermissionFinal	:= oObj:oWSOBJECTIVETOPICSRESULT:lPERMISSIONFINAL
				HttpSession->PlanRevision		:= oObj:oWSOBJECTIVETOPICSRESULT:oWSPLANREVISION:cSTRING
				HttpSession->LeaderName			:= oObj:oWSOBJECTIVETOPICSRESULT:cPartLeader
				HttpSession->Area				:= oObj:oWSOBJECTIVETOPICSRESULT:cAREA
				HttpSession->HierarqLevel		:= oObj:oWSOBJECTIVETOPICSRESULT:CHIERARQLEVEL
				
				HttpPost->UltAprovacao			:= oObj:oWSOBJECTIVETOPICSRESULT:dLASTAPPROVE
				HttpPost->UltAlteracao			:= oObj:oWSOBJECTIVETOPICSRESULT:dLASTUPDATE
				
				for nI := 1 to len(oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS)
					HttpSession->ItemList := {}
					aadd(HttpSession->ObjectiveTopics,{ oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cDESCRITEM, oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cITEMID, oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cPANID, oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cTIPOITEM, oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cTPCURSO, oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cPANSTATUS })
					nX:= len(HttpSession->ObjectiveTopics)
					If oObjItem:TOPICITENS( cCodUser, oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cPANID,HttpGet->cCodPeriod,HttpSession->cUser,HttpSession->EvaluatorId,HttpSession->PlanVersion,	oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cITEMID,HttpGet->cTipoCurso )
						HttpSession->ItemList 		:= oObjItem:oWSTOPICITENSRESULT:oWSITEMLIST:oWSITEM
					EndIf
					aAdd(HttpSession->ObjectiveTopics[nX],HttpSession->ItemList)
				next
			Else
				conout( PWSGetWSError() )
			EndIf
			
			cHtml := ExecInPage("PWSA006")
		Else
			HttpSession->_HTMLERRO := { STR0003, STR0005, "W_PWSA040.APW" } //"Erro"###"Dados Inválidos"
			Return ExecInPage("PWSAMSG")
		EndIf
	EndIf
	
	WEB EXTENDED END
	
Return cHtml
