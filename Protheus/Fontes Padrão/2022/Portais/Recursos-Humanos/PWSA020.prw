#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE cCodUser "MSALPHA"

/*************************************************************      
* Autor...: Thiago dos Reis                   Data: 06/12/04 *
* Objetivo: Chama pagina principal para inclusao / consulta  *
*			/ verificacao de itens pendentes do plano        *
* Modificado: Juliana Barros				Data: 11/04/05	 *
* Motivo	: Inclusao de texto inicial do objetivo atraves  *
* 			  de parametro									 *
**************************************************************/
Web Function PWSA020()

Local cHtml	:= ""                                            
Local oObj	:= ""
            

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")


HttpSession->MyPlans := ""    
HttpSession->MyTeamPlans := ""
HttpSession->DescrParticipant := ""


	HttpSession->cUser := HttpSession->cParticipantID

	//retorna todos os Planos de Desenvolvimento Pessoal do participante
	If oObj:MYOBJECTIVES( cCodUser, HttpSession->cUser, "2" , "F")  //T=retorna todos - F=retorna somente os nao finalizados
		HttpSession->MyPlans := oObj:oWSMYOBJECTIVESRESULT:oWSOBJECTIVE
	Else
		conout( PWSGetWSError() )
	EndIf

	//retorna todos os Planos de Desenvolvimento Pessoal da equipe	
	If oObj:MYTEAMOBJECTIVES( cCodUser, HttpSession->cUser, "2", "2" ) //Cod Usuario, Cod Avaliador, Tipo de Objetivo(1=Plano,2=Meta), Tipo de Status(1=Avaliado,2=Avaliador)
		HttpSession->MyTeamPlans := oObj:oWSMYTEAMOBJECTIVESRESULT:oWSOBJECTIVE
	Else
		conout( PWSGetWSError() )
	EndIf
	

cHtml := ExecInPage( "PWSA020" )


WEB EXTENDED END

Return cHtml



/*******************************************************************/
/* Autor...: Thiago dos Reis       			        Data: 08/12/04 */  
/* Objetivo: Retorna os itens RDJ de um Topico RDW de um Plano RDV */
/*******************************************************************/
Web Function PWSA021()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")

HttpSession->ItemList 		:= ""
HttpSession->PercentList  	:= ""
HttpSession->RelevanceList	:= ""
HttpSession->CourseList		:= ""
If Empty(HttpSession->TypeCourseList)
	HttpSession->TypeCourseList	:= ""	
EndIf

If Empty(HttpGet->cTipoCurso)
	HttpGet->cTipoCurso := ""
EndiF


If !Empty(HttpSession->cUser) .and. !Empty(HttpGet->cCodPlano) .and. !Empty(HttpGet->cCodTopic) .and. !empty(HttpGet->cCodPeriod)
	If oObj:TOPICITENS( cCodUser, HttpGet->cCodPlano, HttpGet->cCodPeriod, HttpSession->cUser, HttpSession->EvaluatorId, HttpSession->PlanVersion, HttpGet->cCodTopic, HttpGet->cTipoCurso )
		HttpSession->ItemList 		:= oObj:oWSTOPICITENSRESULT:oWSITEMLIST:oWSITEM
		HttpSession->PercentList 	:= oObj:oWSTOPICITENSRESULT:oWSPERCENTLIST:oWSALTERNATIVE
		HttpSession->RelevanceList 	:= oObj:oWSTOPICITENSRESULT:oWSRELEVANCELIST:oWSALTERNATIVE
		//SE FOR TELA DE CAPACITACAO
		If HttpGet->nTipo == "2"   
			//GRAVA LISTA DE CURSOS
			If Empty(HttpGet->cTipoCurso) .And. len(oObj:oWSTOPICITENSRESULT:oWSCOURSELIST:oWSCOURSE) > 0
				HttpSession->CourseList 	:= oObj:oWSTOPICITENSRESULT:oWSCOURSELIST:oWSCOURSE
				HttpSession->TypeCourseList	:= oObj:oWSTOPICITENSRESULT:oWSTYPECOURSELIST:oWSCOURSE
				HttpGet->cTipoCurso := HttpSession->TypeCourseList[1]:cCourseId
			ElseIf Empty(HttpGet->cTipoCurso) //SE NAO FOR RETORNO DE CONSULTA POR TIPO DE CURSO, RETORNA TIPOS DE CURSO
				HttpSession->TypeCourseList	:= oObj:oWSTOPICITENSRESULT:oWSTYPECOURSELIST:oWSCOURSE
			Else                                                                               
				HttpSession->CourseList 	:= oObj:oWSTOPICITENSRESULT:oWSCOURSELIST:oWSCOURSE			
			EndIf
		EndIf
	Else
		HttpSession->_HTMLERRO := { "Erro", PWSGetWSError() , "W_PWSA020.APW" }
		Return ExecInPage("PWSAMSG")
	EndIf   
Else
	conout("PWSA021 - Faltando parâmetro de entrada na funcao.")	
EndIf
//varinfo("HttpSession->ItemList",HttpSession->ItemList)
If HttpGet->nTipo == "2"
	cHtml := ExecInPage("PWSA021A")
ElseIf HttpGet->nTipo == "3"
	cHtml := ExecInPage("PWSA021B")
Else
	cHtml := ExecInPage("PWSA021")
Endif

WEB EXTENDED END

Return cHtml

/***********************************************************************/
/* Autor...: Thiago dos Reis                        Data: 26/01/05     */
/* Objetivo: Monta a tela de inclusao de novos Planos para o usuário   */    
/***********************************************************************/
Web Function PWSA022()
Local cHtml   := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")         

HttpSession->ListPlan 	:= ""
HttpSession->ListPartic	:= ""
HttpSession->ListPeriod	:= ""


	If oObj:ShowAllPlans(cCodUser,"2") 
		HttpPost->ListPlan 	:= oObj:oWSSHOWALLPLANSRESULT:oWSOBJ
		If oObj:ShowAllParticipant(cCodUser, HttpSession->cParticipantId) 
			HttpPost->ListPartic	:= oObj:oWSSHOWALLPARTICIPANTRESULT:oWSUSER
			If oObj:ShowAllPeriod(cCodUser)
				HttpPost->ListPeriod	:= oObj:oWSSHOWALLPERIODRESULT:oWSPERIOD
				cHtml := ExecInPage("PWSA024")
			Else
				HttpSession->_HTMLERRO := { "Erro", PWSGetWSError() , "W_PWSA020.APW" }
				cHtml := ExecInPage("PWSAMSG")
			EndIf
		Else
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError() , "W_PWSA020.APW" }
			cHtml := ExecInPage("PWSAMSG")
		EndIf
	Else
		HttpSession->_HTMLERRO := { "Erro", PWSGetWSError() , "W_PWSA020.APW" }
		cHtml := ExecInPage("PWSAMSG")
	EndIf


WEB EXTENDED END

Return cHtml

/***********************************************************************/
/* Autor...: Thiago dos Reis                        Data: 26/01/05     */
/* Objetivo: Executa a Inclusao de novos Planos para o usuário         */    
/***********************************************************************/
Web Function PWSA022A()
Local cHtml   := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")         

If !Empty(HttpPost->cPlano) .and. !Empty(HttpPost->cPart) .and. !Empty(HttpPost->cPeriodo)
	If !oObj:InsertObjetive(cCodUser,HttpSession->cParticipantId,HttpPost->cPart,HttpPost->cPlano,HttpPost->cPeriodo)
		cHtml := "<script>alert('"+PWSGetWSError()+"');</script>"		
		cHtml += W_PWSA020()
	Else
		cHtml := W_PWSA020()
	EndIf
Else
	HttpSession->_HTMLERRO := { "Erro", "Dados enviados para Web Function Inválidos", "W_PWSA022A.APW" }
	cHtml := ExecInPage("PWSAMSG")
EndIf     

WEB EXTENDED END

Return cHtml


/***********************************************************************/
/* Autor...: Thiago dos Reis                        Data: 07/12/04     */
/* Objetivo: Retorna os topicos de um PDP para o avaliado              */    
/***********************************************************************/
Web Function PWSA023()

Local cHtml := ""
Local oObj
Local ni := 0    

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")         

HttpSession->ObjectiveTopics := {}

If !Empty(HttpSession->cUser) .and. !Empty(HttpGet->cCodPlano) .and. !Empty(HttpGet->cCodPeriod) .and. (!Empty(HttpGet->cCodAvaliador) .or. !Empty(HttpGet->cParticipant))
	//atribuicao de Sessoes para o usuário logado
	If Empty(HttpGet->cCodAvaliador) .and. !Empty(HttpGet->cParticipant) 		//indica que e Meu Time
		HttpSession->EvaluatorId 	:= HttpSession->cParticipantID		  		//o Avaliador sera quem esta logado
		HttpSession->cUser 			:= HttpGet->cParticipant			  		//o Avaliado sera eviado por Get
		HttpSession->cAuthor		:= "2"								  		//o Autor sera o Avaliador=2
	ElseIf !Empty(HttpGet->cCodAvaliador) .and. Empty(HttpGet->cParticipant) 	//indica que e Meus Planos
		HttpSession->EvaluatorId 	:= HttpGet->cCodAvaliador					//o Avaliador sera enviado por Get
		HttpSession->cUser 			:= HttpSession->cParticipantID				//o Avaliado sera quem esta logado
		HttpSession->cAuthor		:= "1"										//o Autor sera o Avaliado=1
	Else
		HttpSession->_HTMLERRO := { "Erro", "Erro inesperado favor contactar o suporte", "W_PWSA020.APW" }
		Return ExecInPage("PWSAMSG")
	Endif

	If oObj:ObjectiveTopics(cCodUser, HttpGet->cCodPlano, HttpGet->cCodPeriod, HttpSession->cUser, HttpSession->EvaluatorId)
		HttpSession->DescrObjective		:= oObj:oWSOBJECTIVETOPICSRESULT:cDESCROBJECTIVIES
		HttpSession->PermissonStatus	:= oObj:oWSOBJECTIVETOPICSRESULT:cSTATUS
		Httpsession->PeriodDescr		:= oObj:oWSOBJECTIVETOPICSRESULT:cPERIODDESCR
		HttpSession->PeriodDtIni		:= oObj:oWSOBJECTIVETOPICSRESULT:dPERIODDTINI
		HttpSession->PeriodDtFin		:= oObj:oWSOBJECTIVETOPICSRESULT:dPERIODDTFIN		
		HttpSession->ParticipantName  	:= oObj:oWSOBJECTIVETOPICSRESULT:cNAMEAVALIADO
		HttpSession->EvaluatorName		:= oObj:oWSOBJECTIVETOPICSRESULT:cNAMEAVALIADOR		
		HttpSession->DescrParticipant	:= oObj:oWSOBJECTIVETOPICSRESULT:cDESCRPARTICIPANT
		HttpSession->PlanVersion		:= oObj:oWSOBJECTIVETOPICSRESULT:cPlanVersion
		HttpSession->PermissionFinal	:= oObj:oWSOBJECTIVETOPICSRESULT:lPERMISSIONFINAL
		HttpSession->PlanRevision		:= oObj:oWSOBJECTIVETOPICSRESULT:oWSPLANREVISION:cSTRING
	
		for nI := 1 to len(oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS)
			aadd(HttpSession->ObjectiveTopics, {oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cDESCRITEM, oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cITEMID, oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cPANID, oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cTIPOITEM, oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cTPCURSO, oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cPANSTATUS })	
		next                      
	Else
		conout( PWSGetWSError() )
	EndIf

	cHtml := H_PWSA023()
Else
	HttpSession->_HTMLERRO := { "Erro", "Dados Inválidos", "W_PWSA020.APW" }
	Return ExecInPage("PWSAMSG")
EndIf     


WEB EXTENDED END

Return cHtml

/***********************************************************************/
/* Autor...: Thiago dos Reis             			Data: 22/12/04     */
/* Objetivo: Libera o plano para o outro usuário					   */
/***********************************************************************/
Web Function PWSA024()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")  

If oObj:SetStatus( cCodUser, HttpGet->cCodPlano, HttpGet->cCodPeriod, HttpSession->cUser, HttpSession->EvaluatorId, HttpSession->PlanVersion, HttpPost->Status)
	cHtml := "<script>alert('Plano liberado com sucesso!');</script>"
Else
	cHtml := "<script>alert('Erro! Plano não foi liberado.');</script>"
EndIf
conout( PWSGetWSError() )
cHtml += W_PWSA020()

WEB EXTENDED END

Return cHtml       

/*************************************************************/
/* Autor...: Thiago dos Reis       			  Data: 14/12/04 */
/* Objetivo: Inclui / Altera item do objetivo do participante*/       
/*************************************************************/
Web Function PWSA025()

Local cHtml := ""
Local oObj	:= nil

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")

//DATA INICIAL NAO PODE SER MAIOR QUE A DATA FINAL
If val(DToS(CToD(HttpPost->dDataInicial))) > val(DToS(CToD(HttpPost->dDataFinal)))
	HttpPost->cScript := "<script>alert('Data Inicial não pode ser maior que data Final.');" +;
						"</script>"
	//GRAVA VARIAVEIS NECESSARIAS PARA A PARA A FUNCAO 41()
	HttpGet->cCodPlano := HttpPost->cCodPlano                    
	HttpGet->cCodTopic := HttpPost->cCodTopic 
	HttpGet->cCodPeriod := HttpPost->cCodPeriod
	HttpGet->nTipo 		:= HttpPost->nTipo
	
	Return W_PWSA021()
EndIf                 

oObj:oWSLISTOFITEMPROP := RHPERSONALDESENVPLAN_ITEMPROPRETIES():New()

oObj:oWSLISTOFITEMPROP:cChange				:= HttpPost->cAlterar   // .T. = altera / .F. = inclui
oObj:oWSLISTOFITEMPROP:cObjectiveId			:= HttpPost->cCodPlano
oObj:oWSLISTOFITEMPROP:cEvaluatedId			:= HttpSession->cUser
oObj:oWSLISTOFITEMPROP:cEVALUATORID 		:= HttpSession->EvaluatorId
oObj:oWSLISTOFITEMPROP:cStatus      		:= HttpPost->cStatus
oObj:oWSLISTOFITEMPROP:cPeriod      		:= HttpPost->cCodPeriod
oObj:oWSLISTOFITEMPROP:dInitialDate 		:= ctod(HttpPost->dDataInicial)
oObj:oWSLISTOFITEMPROP:dFinalDate   		:= ctod(HttpPost->dDataFinal)
oObj:oWSLISTOFITEMPROP:cRelevance   		:= HttpSession->RelevanceList[1]:CESCALEID
oObj:oWSLISTOFITEMPROP:cRelevanceItem		:= HttpPost->cbRelevancia
oObj:oWSLISTOFITEMPROP:cAchieveScale 		:= HttpSession->PercentList[1]:CESCALEID
oObj:oWSLISTOFITEMPROP:cAchieveScaleItem 	:= HttpPost->cbAtingido
oObj:oWSLISTOFITEMPROP:cItem 				:= HttpPost->cItem
oObj:oWSLISTOFITEMPROP:cSubPlanID 			:= HttpPost->cCodTopic
oObj:oWSLISTOFITEMPROP:cAuthor				:= HttpSession->cAuthor
oObj:oWSLISTOFITEMPROP:cItemPlanVersion	    := HttpSession->PlanVersion

If !Empty(HttpGet->dDatItm)
	oObj:oWSLISTOFITEMPROP:dItemDate := ctod(HttpGet->dDatItm)
Else
	oObj:oWSLISTOFITEMPROP:dItemDate := date()
EndIf

oObj:oWSLISTOFITEMPROP:cObservation := httpPost->cMeta

If !Empty(HttpPost->cbCurso)
	oObj:oWSLISTOFITEMPROP:cCourseId 		:= HttpPost->cbCurso
EndIf
If !Empty(HttpPost->valor) .and. !Empty(HttpPost->duracao)
	oObj:oWSLISTOFITEMPROP:cCourseValue		:= strTran(HttpPost->valor,".","")
	oObj:oWSLISTOFITEMPROP:nCourseDuration	:= val(AllTrim(strTran(HttpPost->duracao,":",".")))
EndIf

If oObj:INSERTUPDATEITEM( cCodUser, oObj:oWSLISTOFITEMPROP )
	//VERSAO PODE SER DIFERENTE POR CAUSA DA TROCA DE 1.0 PARA 1.01 NA ALTERACAO POR EXEMPLO
	HttpSession->PlanVersion := oObj:cINSERTUPDATEITEMRESULT            
	
	HttpGet->cCodPlano	:= HttpPost->cCodPlano
	HttpGet->cCodTopic 	:= HttpPost->cCodTopic
	HttpGet->cCodPeriod	:= HttpPost->cCodPeriod
	HttpGet->nTipo		:= HttpPost->nTipo
	HttpGet->cAct		:= HttpPost->cAct
  	cHtml :=  W_PWSA021()
Else
	Return PWSHTMLALERT( "", "Plano de Desenvolvimento Pessoal", "Erro na gravação!", "W_PWSA021.APW" )
EndIf

WEB EXTENDED END

Return cHtml

/*************************************************************/
/* Autor...: Thiago dos Reis     			  Data: 18/01/05 */
/* Objetivo: Aprovar Objetivo e apagar versoes intermediárias*/
/*************************************************************/
Web Function PWSA026()
Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")

//UserCode,ObjID,PeriodID,ParticipantId,EvaluatorId,PlanVersion
If oObj:AproveObjetive( cCodUser, HttpGet->cCodPlano, HttpGet->cCodPeriod, HttpSession->cUser, HttpSession->EvaluatorId, HttpSession->PlanVersion, HttpGet->cAct )
	cHtml := "<script>alert('Plano "
	If HttpGet->cAct == "3"
		cHtml += "Finalizado"
	Else
		cHtml += "Aprovado"	
	EndIf
	cHtml += " com sucesso!');</script>"
Else
	conout( PWSGetWSError() )
	cHtml := "<script>alert('Erro! Plano não foi "
	If HttpGet->cAct == "3"
		cHtml += "finalizado"
	Else
		cHtml += "aprovado"	
	EndIf
	cHtml += ".');</script>"
EndIf
cHtml += W_PWSA020()
		
WEB EXTENDED END
Return cHtml

/*************************************************************/
/* Autor...: Thiago dos Reis       			  Data: 20/12/04 */
/* Objetivo: Exclui item do objetivo do participante         */
/*************************************************************/
Web Function PWSA027()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")
oObj:oWSLISTOFITEMPROP := RHPERSONALDESENVPLAN_ITEMPROPRETIES():New()

oObj:oWSLISTOFITEMPROP:cObjectiveId			:= HttpGet->cCodPlano
oObj:oWSLISTOFITEMPROP:cPeriod      		:= HttpGet->cCodPeriod
oObj:oWSLISTOFITEMPROP:cEvaluatedId			:= HttpSession->cUser
oObj:oWSLISTOFITEMPROP:cEvaluatorId 		:= HttpSession->EvaluatorId
oObj:oWSLISTOFITEMPROP:cITEM 				:= HttpGet->cItem
oObj:oWSLISTOFITEMPROP:cSubPlanID 			:= HttpGet->cCodTopic
oObj:oWSLISTOFITEMPROP:cStatus      		:= HttpGet->cStatus
oObj:oWSLISTOFITEMPROP:cItemPlanVersion		:= HttpSession->PlanVersion

If !oObj:DELETEITEM( cCodUser, oObj:oWSLISTOFITEMPROP )  
	conout( PWSGetWSError() )
EndIf

cHtml :=  W_PWSA021()	

WEB EXTENDED END

Return cHtml

/*************************************************************/
/* Autor...: Thiago dos Reis         		  Data: 20/12/04 */
/* Objetivo: Pop Up para selecionar o avaliador              */
/*************************************************************/
Web Function PWSA028()
Local cHtml := ""
Local cNome := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")
		
if empty(HttpPost->cNome)
	cNome := "" 
else
	cNome := HttpPost->cNome
endif

If oObj:brwEvaluator( cCodUser, cNome )
	httpPost->aAvaliadores 	:= 	oObj:oWSBRWEVALUATORRESULT:OWSEVALUATORS  
	cHtml := H_PWSAPDPopAval()
Else
	HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA020.APW" }
 	Return ExecInPage("PWSAMSG" )
EndIf
		
WEB EXTENDED END

Return cHtml

/*************************************************************/
/* Autor...: Thiago dos Reis         		  Data: 20/12/04 */
/* Objetivo: Alterar o avaliador     				         */
/*************************************************************/
Web Function PWSA029()
Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")

If oObj:setEvaluator( cCodUser, HttpSession->cUser, HttpGet->cAvaliador, HttpSession->EvaluatorId, HttpGet->cCodPlano, HttpGet->cCodPeriod )
	HttpSession->EvaluatorName	:= HttpGet->cNomeAvaliador
	HttpSession->EvaluatorId	:= HttpGet->cAvaliador

	HttpGet->cCodAvaliador := HttpGet->cAvaliador
	cHtml := "<script>alert('Avaliador alterado com sucesso!');</script>"
	cHtml += W_PWSA023()
Else
	HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA020.APW" }
	Return ExecInPage("PWSAMSG" )
EndIf
		
WEB EXTENDED END
Return cHtml

/*************************************************************/
/* Autor...: Thiago dos Reis     			  Data: 21/12/04 */
/* Objetivo: Alterar a descricao do papel do participante    */
/* em um determinado objetivo       				         */
/*************************************************************/
Web Function PWSA02A()
Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")

If oObj:SETUSEROBJPAPER( cCodUser, HttpGet->cCodPlano, HttpGet->cCodPeriod, HttpSession->EvaluatorId, HttpSession->cUser, HttpPost->cDescr )
	If HttpSession->cAuthor == "1" //AVALIADO
		HttpGet->cCodAvaliador	:= HttpSession->EvaluatorId
	ElseIf HttpSession->cAuthor == "2" //AVALIADOR
		HttpGet->cParticipant	:= HttpSession->cUser
	EndIf
	cHtml := "<script>alert('Descrição gravada com sucesso!');</script>"
	cHtml += W_PWSA023()
Else
	HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA020.APW" }
	Return ExecInPage("PWSAMSG")
EndIf
		
WEB EXTENDED END
Return cHtml

/*************************************************************/
/* Autor...: Thiago dos Reis     			  Data: 11/01/05 */
/* Objetivo: Aprova ou Reprova um item 						 */
/* em um determinado objetivo       				         */
/*************************************************************/
Web Function PWSA02B()
Local cHtml := "" 
Local nz := 0
Local lResult := .F.

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")

For nz := 1 to Len(HttpPost->aPost) //o comando HttpPost->aPost retorna um array de todos os inputs postados
	If Substr( HttpPost->aPost[nz], 1, 3 ) == "CHK"
		If !oObj:ApproveFailItem( cCodUser, HttpPost->cCodPlano, HttpPost->cCodPeriod, HttpSession->cUser, HttpSession->EvaluatorId, HttpSession->PlanVersion, HttpPost->cCodTopic, &("HttpPost->"+HttpPost->aPost[nz]), HttpSession->cAuthor, HttpPost->cStatus )
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA02B.APW" }
			Return ExecInPage("PWSAMSG")
		EndIf
	EndIf
next

HttpGet->cCodPlano	:= HttpPost->cCodPlano
HttpGet->cCodTopic 	:= HttpPost->cCodTopic
HttpGet->cCodPeriod	:= HttpPost->cCodPeriod
HttpGet->nTipo		:= HttpPost->nTipo
HttpGet->cAct		:= HttpPost->cAct
cHtml :=  W_PWSA021()	

		
WEB EXTENDED END
Return cHtml

/*************************************************************/
/* Autor...: Thiago dos Reis     			  Data: 11/01/05 */
/* Objetivo: Lista todas as versoes do historico 			 */
/*************************************************************/
Web Function PWSA02C()
Local cHtml 	:= ""
Local cVersao 	:= ""
Local cAval 	:= ""
Local cPart		:= ""
Local cPlan 	:= ""
Local cPeri 	:= "" 
Local cType		:= ""
Local oObj		:= ""
Local oObj1		:= ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
oObj1 := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")
WsChgURL(@oObj1,"RHPERSONALDESENVPLAN.APW")

HttpSession->HistVersion	:= {}
HttpSession->HistTopicItens	:= {} 
HttpSession->HistMyPlans	:= {}
HttpSession->HistMyEquipPlans	:= {}
		
If !Empty(HttpGet->cCodPlano)
	cPlan := HttpGet->cCodPlano
EndIf
If !Empty(HttpGet->cCodPeriod)
	cPeri := HttpGet->cCodPeriod
EndIf
If !Empty(HttpGet->cCodVersao)
	cVersao := HttpGet->cCodVersao
EndIf
If !Empty(HttpGet->cTipo)
	cType := HttpGet->cTipo
EndIf

If Empty(HttpGet->cParticipant) .and. !Empty(HttpGet->cCodAvaliador) //Meus Planos Correntes
	cAval := HttpGet->cCodAvaliador
	cPart := HttpSession->cParticipantId
ElseIf Empty(HttpGet->cCodAvaliador) .and. !Empty(HttpGet->cParticipant) //Planos Correntes da Minha equipe 
	cAval := HttpSession->cParticipantId
	cPart := HttpGet->cParticipant
EndIf


If !Empty(cType)
	//CONSULTA MEU PLANO
	If oObj:ShowHistory( cCodUser, cType, cPlan, cPeri, HttpSession->cParticipantId, cAval, cVersao ) //UserCode,TypeId,ObjID,PeriodID,ParticipantId,EvaluatorId,PlanVersion
		HttpSession->HistMyPlans	:= oObj:oWSSHOWHISTORYRESULT:oWSLISTOFOBJECTIVE:oWSOBJECTIVE
	EndIf
	
	//CONSULTA PLANO DE MINHA EQUIPE
	If oObj1:ShowHistory( cCodUser, cType, cPlan, cPeri, cPart, HttpSession->cParticipantId, cVersao ) //UserCode,TypeId,ObjID,PeriodID,ParticipantId,EvaluatorId,PlanVersion	
		HttpSession->HistMyEquipPlans	:= oObj1:oWSSHOWHISTORYRESULT:oWSLISTOFOBJECTIVE:oWSOBJECTIVE
	EndIf                                                                           
	cHtml := H_PWSA020PopHist()	
Else
	If oObj:ShowHistory( cCodUser, cType, cPlan, cPeri, cPart, cAval, cVersao ) //UserCode,TypeId,ObjID,PeriodID,ParticipantId,EvaluatorId,PlanVersion
		HttpSession->HistVersion	:= oObj:oWSSHOWHISTORYRESULT:oWSHISTVERSION:nFLOAT
		HttpSession->HistTopicItens	:= oObj:oWSSHOWHISTORYRESULT:oWSHISTSUBPLANS:oWSSUBPLANS
		cHtml := ExecInPage("PWSA02PopHist")
	Else
		HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "javascript:window.close();" }
		cHtml := ExecInPage("PWSAMSG")
	EndIf
EndIf


WEB EXTENDED END

Return cHtml

