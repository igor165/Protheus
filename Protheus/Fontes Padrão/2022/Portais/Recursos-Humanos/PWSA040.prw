#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA040PRW.CH"


#DEFINE cCodUser "MSALPHA"


/*************************************************************
* Autor...: Thiago dos Reis                   Data: 06/12/04 *
* Objetivo: Chama pagina principal para inclusao / consulta  *
*			/ verificacao de itens pendentes do plano        *
* Modificado: Juliana Barros				Data: 11/04/05	 *
* Motivo	: Inclusao de texto inicial do objetivo atraves  *
* 			  de parametro									 *
* Este fonte e valido para plano de desenvolvimento e metas  *
**************************************************************/
Web Function PWSA040()

Local cHtml		:= ""
Local oParam	:= ""
Local oMsg		:= ""
Local nTPerPag	:= 5
WEB EXTENDED INIT cHtml START "InSite"

oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():NEW())
oMsg	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
WsChgURL(@oParam,"CFGDICTIONARY.APW")
WsChgURL(@oMsg,"RHPERSONALDESENVPLAN.APW")

HttpPost->cMsg := STR0001+" "  	//" Entender e endere&ccedil;ar os pontos levantados durante as avalia&ccedil;&otilde;es de performance do ano anterior,
HttpPost->cMsg += STR0002+" " 	// garantir auto-conhecimento, desenvolvimento e aprimoramento profissional e pessoal constantes e
HttpPost->cMsg += STR0003  		// formalizar e acompanhar o planejamento individual."

HttpSession->cUser := HttpSession->cParticipantID

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SESSION PARA VERIFICAR QUAL O TIPO DE TELA QUE SERA MOSTRADA  |
//³ PDP=PLANO DE DESENVOLVIMENTO PESSOAL; PM=PLANO DE METAS		  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->cTipoPlano := "PDP"

//RESGATA PARAMETRO CONTENDO CODIGO DA MENSAGEM
//SE EM QUALQUER SITUACAO MSG NAUM ESTIVER CADASTRADA OU ESTIVER EM BRANCO, VALE MSG DEFAULT
If oParam:GETPARAM( cCodUser, "MV_MSGPDP" )
	If !Empty(oParam:cGETPARAMRESULT)
		If oMsg:GETMESSAGE( cCodUser, oParam:cGETPARAMRESULT )
			If !Empty(oMsg:cGETMESSAGERESULT)
				HttpPost->cMsg := StrTran( oMsg:cGETMESSAGERESULT, Chr( 10 ), "<br>" )
			EndIf
		EndIf
	EndIf
EndIf

//Verifica se deve ser liberada a funcionalidade de 'Inclusão Nova'
HttpSession->cIncluir	:= '1'
If oParam:GETPARAM( cCodUser, "MV_APDINCN" )    
	HttpSession->cIncluir	:= oParam:cGETPARAMRESULT
	If !(oParam:cGETPARAMRESULT $ '1*2*3')
		HttpSession->cIncluir	:= "1"	
	EndIf 
EndIf

//Verifica se Disponibiliza o bloco 'Meus Pares' nas páginas 'Pendências Atuais' e 'Consulta Histórico' nos Planos de Metas e Desenvolvimento? (1-Sim, 2-Não)", 
HttpSession->cAPDCPAR	:= "2"	
IF oParam:GETPARAM( cCodUser, "MV_APDCPAR" )
	HttpSession->cAPDCPAR := oParam:cGETPARAMRESULT	
	If !(oParam:cGETPARAMRESULT $ '1*2*3')
		HttpSession->cAPDCPAR	:= "2"	//2-Nao
	EndIf 
ENDIF

//PARAMETRO QUE VERIFICA SE APROVACAO DE VERSAO PODE FUNCIONAR OU NAO
//SE RETORNO DO PARAMETRO = 1 NAO EXISTIRAO APROVACOES DE VERSAO
//CASO CONTRARIO, CONTROLE DE VERSAO EXISTIRA NORMALMENTE
If oParam:GETPARAM( cCodUser, "MV_APRVPDP" )
	HttpSession->cAprvPdp := AllTrim(oParam:cGETPARAMRESULT)
EndIf

HttpSession->cApdIncB := '1'
If oParam:GETPARAM( cCodUser, "MV_APDINCB" )
	HttpSession->cApdIncB := AllTrim(oParam:cGETPARAMRESULT)
	If !(oParam:cGETPARAMRESULT $ '1*2*3*')
		HttpSession->cApdIncB   := '1'	
	EndIf 
EndIf

cHtml := ExecInPage( "PWSA040" )

WEB EXTENDED END

Return cHtml


/*************************************************************
* Autor...: Juliana Barros                   Data: 07/04/05  *
* Objetivo: Retorna os tipos de objetivos cadastrados        *
*************************************************************/
Web Function PWSA040A()

Local cHtml := ""
Local cTipo	:= ""
Local oObj
Local oParam   
Local nTPerPag:= 5
Private	cParBloq := "" 
  
WEB EXTENDED INIT cHtml START "InSite"

DEFAULT HttpGet->nOpcCMB	:= "0"

//Default Pagina
HttpSession->nOpcCMB			:= IIF(HttpSession->nOpcCMB!= 0 .And. Val(HttpGet->nOpcCMB)==0,HttpSession->nOpcCMB,Val(HttpGet->nOpcCMB)) 

	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
	WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")
	
	oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():NEW())
	WsChgURL(@oParam,"CFGDICTIONARY.APW")
	
	HttpSession->MyPlans 			:= {}
	HttpSession->DescrParticipant 	:= ""  
	
	//Tratativa para incorporar busca por periodo nos Objetivos
	If Valtype(HttpSession->aPeriodos)=="A" .And. Len(HttpSession->aPeriodos)>0 .And. HttpSession->nOpcCMB > 0 
		oObj:dPeriodDtIni:= HttpSession->aPeriodos[HttpSession->nOpcCMB]:DPERIODDTINI
		oObj:dPeriodDtFin:= HttpSession->aPeriodos[HttpSession->nOpcCMB]:DPERIODDTFIN
		oObj:CPeriodID		:= HttpSession->aPeriodos[HttpSession->nOpcCMB]:cPeriodID
		HttpSession->PerCabec:= "Período: " + HttpSession->aPeriodos[HttpSession->nOpcCMB]:CPERIODID +' - '+ HttpSession->aPeriodos[HttpSession->nOpcCMB]:CPERIODDESCR + " ( " + Dtos(HttpSession->aPeriodos[HttpSession->nOpcCMB]:DPERIODDTINI)+ " - " + DtoS(HttpSession->aPeriodos[HttpSession->nOpcCMB]:DPERIODDTFIN)+" )"
	EndIf
	
	IF oParam:GETPARAM( cCodUser, "MV_APDBLOQ" )   
		cParBloq:= oParam:cGETPARAMRESULT
		If(oParam:cGETPARAMRESULT <> "1" .and. oParam:cGETPARAMRESULT <> "2")
			cParBloq:="2"	
		EndIf
	ENDIF
	
	//Determinar se disponibiliza a coluna 'Resultado Acumulado' nas páginas 'Pendências Atuais' e 'Consulta Histórico' nos Planos de Metas e Desenvolvimento? (1-Sim, 2-Não)"
	HttpSession->cAPDRES1 := '2' //2-Nao
	IF oParam:GETPARAM( cCodUser, "MV_APDRES1" ) 
		HttpSession->cAPDRES1 := oParam:cGETPARAMRESULT	
		If !(oParam:cGETPARAMRESULT $ '1*2*')
			HttpSession->cAPDRES1	:= '2'	
		EndIf 
	ENDIF
		//Determinar se disponibiliza a coluna 'Resultado Acumulado' nas páginas 'Pendências Atuais' e 'Consulta Histórico' nos Planos de Metas e Desenvolvimento? (1-Sim, 2-Não)"
	HttpSession->cAPDRES2 := '2' //2-Nao
	IF oParam:GETPARAM( cCodUser, "MV_APDRES2" ) 
		HttpSession->cAPDRES2 := oParam:cGETPARAMRESULT	
		If !(oParam:cGETPARAMRESULT $ '1*2*')
			HttpSession->cAPDRES2	:= '2'	
		EndIf 
	ENDIF
	If !Empty( HttpSession->cParticipantID )
	
		HttpSession->cUser := HttpSession->cParticipantID
	
		If !Empty(HttpGet->cTipo)
			If HttpGet->cTipo == "1"
				HttpSession->cTipoPlano := "PDP"
			Else
				HttpSession->cTipoPlano := "PM"
			EndIF
		EndIf
	
		If HttpSession->cTipoPlano == "PDP"
			cTipo := "1"	//PLANO DE DESENVOLVIMENTO PESSOAL
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ SESSION PARA VERIFICAR QUAL O TIPO DE TELA QUE SERA MOSTRADA  |
			//³ PDP=PLANO DE DESENVOLVIMENTO PESSOAL; PM=PLANO DE METAS		  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->cTipoPlano := "PDP"
	
			//PARAMETRO QUE VERIFICA SE APROVACAO DE VERSAO PODE FUNCIONAR OU NAO
			//SE RETORNO DO PARAMETRO = 1 NAO EXISTIRAO APROVACOES DE VERSAO
			//CASO CONTRARIO, CONTROLE DE VERSAO EXISTIRA NORMALMENTE
			If oParam:GETPARAM( cCodUser, "MV_APRVPDP" )
				HttpSession->cAprvPdp := AllTrim(oParam:cGETPARAMRESULT)
			Else
				HttpSession->cAprvPdp := ""
			EndIf
	
		Else
			cTipo := "2"	//PLANO DE METAS
	
			//PARAMETRO QUE VERIFICA SE APROVACAO DE VERSAO PODE FUNCIONAR OU NAO
			//SE RETORNO DO PARAMETRO = 1 NAO EXISTIRAO APROVACOES DE VERSAO
			//CASO CONTRARIO, CONTROLE DE VERSAO EXISTIRA NORMALMENTE
			If oParam:GETPARAM( cCodUser, "MV_APRVPM" )
				HttpSession->cAprvPm := AllTrim(oParam:cGETPARAMRESULT)
			Else
				HttpSession->cAprvPm := ""
			EndIf
	
		EndIf
	
		//retorna todos os Planos de Desenvolvimento Pessoal do participante
		If oObj:MYOBJECTIVES( cCodUser, HttpSession->cUser, cTipo , "F")  //T=retorna todos - F=retorna somente os nao finalizados
			HttpSession->MyPlans := oObj:oWSMYOBJECTIVESRESULT:oWSOBJECTIVE
		Else
			conout( PWSGetWSError() )
		EndIf

	EndIf

cHtml := ExecInPage( "PWSA045" )

WEB EXTENDED END

Return cHtml

/*******************************************************************/
/* Autor...: Thiago dos Reis       			        Data: 08/12/04 */
/* Objetivo: Retorna os itens RDJ de um Topico RDW de um Plano RDV */
/*******************************************************************/
Web Function PWSA041()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")

DEFAULT HttpGet->nLimMetas		:= "0"
DEFAULT HttpGet->nLimPesos		:= "0"
DEFAULT HttpGet->nPosLMP		:= "0"
HttpSession->ItemList 		:= {}
HttpSession->PercentList  	:= ""
HttpSession->RelevanceList	:= ""
HttpSession->CourseList		:= ""
if Val(HttpGet->nPosLMP)>0
	HttpSession->nLimPesos		:= HttpSession->ObjObjectTopics[Val(HttpGet->nPosLMP)]:nLimitpes
	HttpSession->nLimMetas		:= HttpSession->ObjObjectTopics[Val(HttpGet->nPosLMP)]:nLimitMt
else
	HttpSession->nLimMetas		:= Val(HttpGet->nLimMetas)
	HttpSession->nLimPesos		:= Val(HttpGet->nLimPesos)
EndIf

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
		//SE FOR TELA DE CAPACITACAO OU CERTIFICACAO
		If HttpGet->nTipo == "2" .Or. HttpGet->nTipo == "4"
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

		ElseIf HttpGet->nTipo == "5"
			HttpSession->CourseList 	:= oObj:oWSTOPICITENSRESULT:oWSCOURSELIST:oWSCOURSE
		EndIf
	Else
		HttpSession->_HTMLERRO := { STR0004, PWSGetWSError() , "W_PWSA040.APW" } //"Erro
		Return ExecInPage("PWSAMSG")
	EndIf
Else
	conout("PWSA041 - Faltando parâmetro de entrada na funcao.")
EndIf

If HttpGet->nTipo == "2"
	cHtml := ExecInPage("PWSA041A")
ElseIf HttpGet->nTipo == "3"
	cHtml := ExecInPage("PWSA041B")
ElseIf HttpGet->nTipo == "4"
	cHtml := ExecInPage("PWSA041C")
ElseIf HttpGet->nTipo == "5"
	cHtml := ExecInPage("PWSA041D")
Else
	cHtml := ExecInPage("PWSA041")
Endif

WEB EXTENDED END

Return cHtml

/***********************************************************************/
/* Autor...: Thiago dos Reis                        Data: 26/01/05     */
/* Alterado...: Juliana Barros Mariano              Ult Alt.: 05/06/05 */
/* Objetivo: Monta a tela de inclusao de novos Planos para o usuário   */
/***********************************************************************/
Web Function PWSA042()
Local 	cHtml	:= ""
Local 	cTipo	:= ""
Local 	cTipper	:= ""
Local 	oObj
Local 	oParam   
Private cParBloq:= "" 



WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")
oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():NEW())
WsChgURL(@oParam,"CFGDICTIONARY.APW")

HttpSession->ListPlan 	:= ""
HttpSession->ListPartic	:= ""
HttpSession->ListPeriod	:= ""

HttpSession->cCusto		:= If (!Empty(Httppost->cCusto), Httppost->cCusto,"")    

IF oParam:GETPARAM( cCodUser, "MV_APDBLOQ" )     
	cParBloq:= oParam:cGETPARAMRESULT
	If(oParam:cGETPARAMRESULT <> "1" .and. oParam:cGETPARAMRESULT <> "2")
		cParBloq:="2"	
	EndIf
ENDIF  
                                     
HttpSession->cUser := HttpSession->cParticipantID

If !Empty(HttpGet->cTipo)
	If HttpGet->cTipo == "1"
		HttpSession->cTipoPlano := "PDP"
	Else
		HttpSession->cTipoPlano := "PM"
	EndIF
EndIf

If HttpSession->cTipoPlano == "PDP"
	cTipo 	:= "1"	//PLANO DE DESENVOLVIMENTO PESSOAL  
	cTipper	:= "2"  //TIPO DO PERIODO PLANO DE DESENVOLVIMENTO PESSOAL  
Else
	cTipo	:= "2"	//PLANO DE METAS                                    
	cTipper	:= "3"  //TIPO DO PERIODO PLANO DE METAS  

	//PARAMETRO QUE VERIFICA SE APROVACAO DE VERSAO PODE FUNCIONAR OU NAO
	//SE RETORNO DO PARAMETRO = 1 NAO EXISTIRAO APROVACOES DE VERSAO
	//CASO CONTRARIO, CONTROLE DE VERSAO EXISTIRA NORMALMENTE
	If oParam:GETPARAM( cCodUser, "MV_APRVPM" )
		HttpSession->cAprvPm := AllTrim(oParam:cGETPARAMRESULT)
	Else
		HttpSession->cAprvPm := ""
	EndIf
EndIf

//PARAMETRO PARA IDENTIFICAR SE O PLANO PODERA SER INCLUIDO
// PELO AVALIADOR OU AVALIADO.
If oParam:GETPARAM( cCodUser, "MV_APDCPDP" )
	HttpSession->cIncPlan := AllTrim( oParam:cGETPARAMRESULT )
EndIf 

If !Empty(HttpSession->cUser)   
		If oObj:ShowAllPlans( cCodUser, cTipo )
			HttpSession->ListPlan 	:= oObj:oWSSHOWALLPLANSRESULT:oWSOBJ
				If oObj:ShowAllPeriod(cCodUser, cTipper)
					HttpSession->ListPeriod	:= oObj:oWSSHOWALLPERIODRESULT:oWSPERIOD
					cHtml := ExecInPage("PWSA044")
				Else
					HttpSession->_HTMLERRO := { STR0004, PWSGetWSError() , If(cTipo == '1', "W_PWSA040.APW", "W_PWSA004.APW") }
					cHtml := ExecInPage("PWSAMSG")
				EndIf
		Else
			HttpSession->_HTMLERRO := { STR0004, PWSGetWSError() , If(cTipo == '1', "W_PWSA040.APW", "W_PWSA004.APW") }
			cHtml := ExecInPage("PWSAMSG")
		EndIf
Else
	HttpSession->_HTMLERRO := { STR0004, STR0005, If(cTipo == '1', "W_PWSA040.APW", "W_PWSA004.APW") } //"Dados enviados para Web Function Inválidos"
	cHtml := ExecInPage("PWSAMSG")
EndIf

WEB EXTENDED END

Return cHtml


/***********************************************************************/
/* Autor...: Thiago dos Reis                        Data: 26/01/05     */
/* Objetivo: Executa a Inclusao de novos Planos para o usuário         */
/***********************************************************************/
Web Function PWSA042A()
Local cHtml   := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")

If !Empty(HttpSession->cUser) .and. !Empty(HttpPost->Plan) .and. !Empty(HttpPost->Part) .and. !Empty(HttpPost->Period)
	If !oObj:InsertObjetive(cCodUser, HttpSession->cUser, HttpPost->Part, HttpPost->Plan, HttpPost->Period)
		cHtml := "<script>alert('"+PWSGetWSError()+"');</script>"
	EndIf

	If HttpSession->cTipoPlano == "PDP" //PLANO DE DESENV PESSOAL
		cHtml += W_PWSA040()
	Else	//PLANO DE METAS
		cHtml += W_PWSA004()
	EndIf
Else
	HttpSession->_HTMLERRO := { STR0004, STR0005, "W_PWSA042A.APW" } //"Dados enviados para Web Function Inválidos"
	Return ExecInPage("PWSAMSG")
EndIf

WEB EXTENDED END

Return cHtml


/***********************************************************************/
/* Autor...: Thiago dos Reis                        Data: 07/12/04     */
/* Alterado: Juliana Barros                         Data: 03/10/05     */
/* Objetivo: Retorna os topicos de um PDP para o avaliado              */
/***********************************************************************/
Web Function PWSA043()	
	Local cHtml := ""
	Local oObj,oParam 	:= ""
	Local cTipo	:= ""
	Local cAprvPDP,cApdbPDM,cAprvpm:= ""
	Local ni 	:= 0
	
	WEB EXTENDED INIT cHtml START "InSite"
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
		WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")
		oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():NEW())
		WsChgURL(@oParam,"CFGDICTIONARY.APW")
		
		HttpSession->lManut		:= .F.
		HttpSession->lResult	:= .F.
		HttpSession->lAltera	:= .F.
		HttpSession->lCancela	:= .F.

		
		HttpSession->ObjectiveTopics := {}
		HttpSession->ObjObjectTopics := {}


		// Busca informações para visualização de botões
	 	cAprvPDP:= ""
		If oParam:GETPARAM( cCodUser, "MV_APRVPDP" )
			cAprvPDP := oParam:cGETPARAMRESULT	
			If oParam:cGETPARAMRESULT <> '1'
			 	cAprvPDP:= ""
			 EndIf
		EndIf 

		// Busca informações para visualização de botões
		cAprvpm:= ""
		If oParam:GETPARAM( cCodUser, "MV_APRVPM" )
			cAprvpm := oParam:cGETPARAMRESULT	
			If oParam:cGETPARAMRESULT <> '1'
			 	cAprvpm:= ""
			 EndIf
		EndIf 
		
		// "Define a utilização dos botões de ações nos Planos de Metas e Desenv. quando não utilizar o controle de versionamento? 
		// Opções: '1-Alterar/Excluir' ou '2-Cancelar'
		cApdbPDM:= "1"
		If oParam:GETPARAM( cCodUser, "MV_APDBPDM" )
			cApdbPDM := oParam:cGETPARAMRESULT	
			If !(oParam:cGETPARAMRESULT $ '1*2*')
			 	cAprvPDP:= "1"
			 EndIf
		EndIf 

		//Se nao tiver avaliador cadastrado, envia para pagina de cadastro
		If Empty(HttpGet->cCodAvaliador) .And. Empty(HttpGet->cParticipant)
			cHtml := ExecInPage( "PWSA040A" )
		Else
			If !Empty(HttpSession->cUser) .and. !Empty(HttpGet->cCodPlano) .and. !Empty(HttpGet->cCodPeriod) .and. (!Empty(HttpGet->cCodAvaliador) .Or. !Empty(HttpGet->cParticipant))
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
					HttpSession->_HTMLERRO := { STR0004, STR0006, "W_PWSA040.APW" } //"Erro inesperado favor contactar o suporte"
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
					HttpSession->LeaderName			:= oObj:oWSOBJECTIVETOPICSRESULT:cPartLeader
					HttpSession->Area				:= oObj:oWSOBJECTIVETOPICSRESULT:cAREA
					HttpSession->HierarqLevel		:= oObj:oWSOBJECTIVETOPICSRESULT:CHIERARQLEVEL
					HttpSession->ItenPerPend		:= oObj:oWSOBJECTIVETOPICSRESULT:lItenPerPend
					HttpPost->UltAprovacao			:= oObj:oWSOBJECTIVETOPICSRESULT:dLASTAPPROVE
					HttpPost->UltAlteracao			:= oObj:oWSOBJECTIVETOPICSRESULT:dLASTUPDATE
					cTipo							:= oObj:oWSOBJECTIVETOPICSRESULT:cPerTipo
												
					//Tratativa com base nos dados dos campos de data.
					If ( Empty(oObj:oWSOBJECTIVETOPICSRESULT:dPerIncIni) .And.  Empty(oObj:oWSOBJECTIVETOPICSRESULT:dPerIncFim) ) .Or.;
						(oObj:oWSOBJECTIVETOPICSRESULT:dPerIncIni <= date() .And. oObj:oWSOBJECTIVETOPICSRESULT:dPerIncFim >= date() )
						HttpSession->lManut:= .T.					
					EndIf
				
					If ( Empty(oObj:oWSOBJECTIVETOPICSRESULT:dPerMntResIni) .And.  Empty(oObj:oWSOBJECTIVETOPICSRESULT:dPerMntResFim) ) .Or.;
						(oObj:oWSOBJECTIVETOPICSRESULT:dPerMntResIni <= date() .And. oObj:oWSOBJECTIVETOPICSRESULT:dPerMntResFim >= date() ) 
						HttpSession->lResult:= .T.					
					EndIf
				
					//Tratativa junto ao parâmetros e o tipo do periodo
					if (cTipo == '2' .And. cAprvPDP <> '1') .Or. ;
						(cTipo == '3' .And. cAprvpm <> '1') .Or. ;
						(cApdbPDM <> '2')
						If HttpSession->lManut
							HttpSession->lAltera	:= .T.
						EndIf
					ElseIf cApdbPDM <> '1' .And. HttpSession->lManut
						HttpSession->lCancela:= .T.
					EndIf
					
					//Pagina PWSA043 receberá os dados desta session agora para a listagem de objetivos\metas
					HttpSession->ObjObjectTopics:= oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS
					
					//Compatibilidade para que não haja impacto em outras rotinas 
					for nI := 1 to len(oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS)
						aadd(HttpSession->ObjectiveTopics, {oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cDESCRITEM, oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cITEMID, oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cPANID, oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cTIPOITEM, oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cTPCURSO, oObj:oWSOBJECTIVETOPICSRESULT:oWSSUBPLAN:oWSSUBPLANS[nI]:cPANSTATUS })
					next
				Else
					conout( PWSGetWSError() )
				EndIf
		
				cHtml := ExecInPage("PWSA043")
			Else
				HttpSession->_HTMLERRO := { STR0004, STR0007, "W_PWSA040.APW" } //"Dados Inválidos"
				Return ExecInPage("PWSAMSG")
			EndIf
		EndIf

	WEB EXTENDED END
Return cHtml



/*************************************************************/
/* Autor...: Juliana Barros          		  Data: 03/10/05 */
/* Objetivo: Incluir o avaliador     				         */
/*************************************************************/
Web Function PWSA043A()

Local cHtml := ""
Local oObj	:= ""
Local oObj2	:= ""

WEB EXTENDED INIT cHtml START "InSite"

	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():NEW())
	WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")

	oObj2 := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
	WsChgURL(@oObj2,"RHPERSONALDESENVPLAN.APW")

	If !Empty(HttpSession->cParticipantId) .and. !Empty(HttpGet->cCodPlano) .and. !Empty(HttpPost->cAvaliador) .and. !Empty(HttpGet->cCodPeriod)
		If !oObj2:ChkObjetive(cCodUser, HttpSession->cParticipantId, HttpPost->cAvaliador, HttpGet->cCodPlano, HttpGet->cCodPeriod)
			cHtml := "<script>alert('"+PWSGetWSError()+"');</script>"
			cHtml += W_PWSA040A()
		Else
			If oObj:setEvaluator( cCodUser, HttpSession->cParticipantId, HttpPost->cAvaliador, , HttpGet->cCodPlano, HttpGet->cCodPeriod )
				HttpGet->cCodAvaliador := HttpPost->cAvaliador
				cHtml += W_PWSA043()
			Else
				HttpSession->_HTMLERRO := { STR0004, PWSGetWSError(), "W_PWSA040A.APW" }
				Return ExecInPage("PWSAMSG" )
			EndIf		
		EndIf
    Else
		HttpSession->_HTMLERRO := { STR0004, PWSGetWSError(), "W_PWSA040A.APW" }
		Return ExecInPage("PWSAMSG" )
	EndIf


WEB EXTENDED END

Return cHtml



/***********************************************************************/
/* Autor...: Thiago dos Reis             			Data: 22/12/04     */
/* Objetivo: Libera o plano para o outro usuário					   */
/***********************************************************************/
Web Function PWSA044()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")

If oObj:SetStatus( cCodUser, HttpGet->cCodPlano, HttpGet->cCodPeriod, HttpSession->cUser, HttpSession->EvaluatorId, HttpSession->PlanVersion, HttpPost->Status)
	cHtml := "<script>alert('" + STR0008 + "!');</script>" //Plano liberado com sucesso
Else
	cHtml := "<script>alert('" + STR0009 + "');</script>" //Erro! Plano não foi liberado.
EndIf
conout( PWSGetWSError() )
cHtml += W_PWSA040A()

WEB EXTENDED END

Return cHtml

/*************************************************************/
/* Autor...: Thiago dos Reis       			  Data: 14/12/04 */
/* Objetivo: Inclui / Altera item do objetivo do participante*/
/*************************************************************/
Web Function PWSA045()

Local cHtml := ""
Local oObj	:= nil

WEB EXTENDED INIT cHtml START "InSite"

Default HttpPost->cbAtingido := ""
Default HttpPost->cbRelevancia := ""
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")
HttpSession->nLimMetas		:= Val(HttpGet->nLimMetas)
HttpSession->nLimPesos		:= Val(HttpGet->nLimPesos)

//DATA INICIAL NAO PODE SER MAIOR QUE A DATA FINAL
If val(DToS(CToD(HttpPost->dDataInicial))) > val(DToS(CToD(HttpPost->dDataFinal)))
	HttpPost->cScript := "<script>alert('" + STR0010 + ".');" +;
						"</script>"      //Data Inicial não pode ser maior que data Final

	//GRAVA VARIAVEIS NECESSARIAS PARA A PARA A FUNCAO 41()
	HttpGet->cCodPlano := HttpPost->cCodPlano
	HttpGet->cCodTopic := HttpPost->cCodTopic
	HttpGet->cCodPeriod := HttpPost->cCodPeriod
	HttpGet->nTipo 		:= HttpPost->nTipo

	Return W_PWSA041()
EndIf

oObj:oWSLISTOFITEMPROP := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHPERSONALDESENVPLAN_ITEMPROPRETIES"), RHPERSONALDESENVPLAN_ITEMPROPRETIES():NEW())

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
//Realiza a troca do caracter aspas simples para acento agudo
oObj:oWSLISTOFITEMPROP:cObservation := strTran(HttpPost->cMeta,chr(39),chr(180))
//Realiza a troca do comando para espaco de Advpl para o comando em Html
oObj:oWSLISTOFITEMPROP:cObservation := StrTran(HttpPost->cMeta, chr(13) + chr(10), '<br>')
oObj:oWSLISTOFITEMPROP:cItemPlanVersion	    := HttpSession->PlanVersion

//Realiza a troca do caracter aspas simples para acento agudo
if !Empty(HttpPost->cObsAval)
	oObj:oWSLISTOFITEMPROP:cVALIDATOROBS := strTran(HttpPost->cObsAval,chr(39),chr(180))
	//Realiza a troca do comando para espaco de Advpl para o comando em Html
	oObj:oWSLISTOFITEMPROP:cVALIDATOROBS := StrTran(HttpPost->cObsAval, chr(13) + chr(10), '<br>')
EndIF
If !Empty(HttpPost->cbCurso)
	oObj:oWSLISTOFITEMPROP:cTypeCourseId 	:= HttpPost->cbTpCurso
	oObj:oWSLISTOFITEMPROP:cCourseId 		:= HttpPost->cbCurso
EndIf
If !Empty(HttpPost->valor)
	oObj:oWSLISTOFITEMPROP:cCourseValue		:= strTran(HttpPost->valor,".","")
EndIf
If !Empty(HttpPost->duracao)
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
  	cHtml :=  W_PWSA041()
Else
	Return PWSHTMLALERT( "", IIf( HttpSession->cTipoPlano == "PDP", STR0011, STR0012 ), STR0013, "W_PWSA041.APW" ) //"Erro na gravação!"
EndIf

WEB EXTENDED END

Return cHtml

/*************************************************************
* Autor...: Eduardo Ferreira                   Data: 14/06/16  *
* Objetivo: Retorna a equipe do usuário logado		        *
*************************************************************/
Web Function PWSA045A()
	
	Local cHtml := ""
	Local cTipo	:= ""
	Local oObj
	Local oParam
	Local nTPerPag:= 5
	Private	cParBloq := ""
	HttpCTType("text/html; charset=ISO-8859-1")
	WEB EXTENDED INIT cHtml START "InSite"
	
	DEFAULT HttpGet->Page		:= "1"
	DEFAULT HttpGet->PageTotal	:= "1"
	DEFAULT HttpGet->Pos		:= "1"
	DEFAULT HttpGet->Pag		:= "0"
	DEFAULT HttpGet->FilterField:= ""
	DEFAULT HttpGet->FilterValue:= ""
	DEFAULT HttpGet->Destination:= ""
	
	//Default Pagina
	HttpSession->nPageTotal			:= Val(HttpGet->PageTotal)
	HttpSession->nCurrentPage		:= Val(HttpGet->Page)
	HttpSession->nPag				:= Val(HttpGet->Pag)
	HttpSession->cFilterField		:= HttpGet->FilterField
	HttpSession->cFilterValue		:= HttpGet->FilterValue
	HttpSession->cDestination 		:= HttpGet->Destination
	
	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
	WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")
	oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():NEW())
	WsChgURL(@oParam,"CFGDICTIONARY.APW")
	
	HttpSession->MyTeamPlans 		:= {}
	HttpSession->MyAllTeamPlans		:= {}
	HttpSession->DescrParticipant 	:= ""
	
	//Tratativa para incorporar busca por periodo nos Objetivos
	If Valtype(HttpSession->aPeriodos)=="A" .And. Len(HttpSession->aPeriodos)>0 .And. HttpSession->nOpcCMB > 0
		oObj:dPeriodDtIni:= HttpSession->aPeriodos[HttpSession->nOpcCMB]:DPERIODDTINI
		oObj:dPeriodDtFin:= HttpSession->aPeriodos[HttpSession->nOpcCMB]:DPERIODDTFIN
		oObj:CPeriodID		:= HttpSession->aPeriodos[HttpSession->nOpcCMB]:cPeriodID
	EndIf
	
	IF oParam:GETPARAM( cCodUser, "MV_APDBLOQ" )
		cParBloq:= oParam:cGETPARAMRESULT
		If(oParam:cGETPARAMRESULT <> "1" .and. oParam:cGETPARAMRESULT <> "2")
			cParBloq:="2"
		EndIf
	ENDIF

	//Determinar se disponibiliza a coluna 'Resultado Acumulado' nas páginas 'Pendências Atuais' e 'Consulta Histórico' nos Planos de Metas e Desenvolvimento? (1-Sim, 2-Não)"
	HttpSession->cAPDRES1 := '2' //2-Nao
	IF oParam:GETPARAM( cCodUser, "MV_APDRES1" ) 
		HttpSession->cAPDRES1 := oParam:cGETPARAMRESULT	
		If !(oParam:cGETPARAMRESULT $ '1*2*')
			HttpSession->cAPDRES1	:= '2'	
		EndIf 
	ENDIF
			//Determinar se disponibiliza a coluna 'Resultado Acumulado' nas páginas 'Pendências Atuais' e 'Consulta Histórico' nos Planos de Metas e Desenvolvimento? (1-Sim, 2-Não)"
	HttpSession->cAPDRES2 := '2' //2-Nao
	IF oParam:GETPARAM( cCodUser, "MV_APDRES2" ) 
		HttpSession->cAPDRES2 := oParam:cGETPARAMRESULT	
		If !(oParam:cGETPARAMRESULT $ '1*2*')
			HttpSession->cAPDRES2	:= '2'	
		EndIf 
	ENDIF
	If !Empty( HttpSession->cParticipantID )
		
		HttpSession->cUser := HttpSession->cParticipantID
		
		If !Empty(HttpGet->cTipo)
			If HttpGet->cTipo == "1"
				HttpSession->cTipoPlano := "PDP"
			Else
				HttpSession->cTipoPlano := "PM"
			EndIF
		EndIf
		
		If HttpSession->cTipoPlano == "PDP"
			cTipo := "1"	//PLANO DE DESENVOLVIMENTO PESSOAL
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ SESSION PARA VERIFICAR QUAL O TIPO DE TELA QUE SERA MOSTRADA  |
			//³ PDP=PLANO DE DESENVOLVIMENTO PESSOAL; PM=PLANO DE METAS		  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->cTipoPlano := "PDP"
			
			//PARAMETRO QUE VERIFICA SE APROVACAO DE VERSAO PODE FUNCIONAR OU NAO
			//SE RETORNO DO PARAMETRO = 1 NAO EXISTIRAO APROVACOES DE VERSAO
			//CASO CONTRARIO, CONTROLE DE VERSAO EXISTIRA NORMALMENTE
			If oParam:GETPARAM( cCodUser, "MV_APRVPDP" )
				HttpSession->cAprvPdp := AllTrim(oParam:cGETPARAMRESULT)
			Else
				HttpSession->cAprvPdp := ""
			EndIf
			
		Else
			cTipo := "2"	//PLANO DE METAS
			
			//PARAMETRO QUE VERIFICA SE APROVACAO DE VERSAO PODE FUNCIONAR OU NAO
			//SE RETORNO DO PARAMETRO = 1 NAO EXISTIRAO APROVACOES DE VERSAO
			//CASO CONTRARIO, CONTROLE DE VERSAO EXISTIRA NORMALMENTE
			If oParam:GETPARAM( cCodUser, "MV_APRVPM" )
				HttpSession->cAprvPm := AllTrim(oParam:cGETPARAMRESULT)
			Else
				HttpSession->cAprvPm := ""
			EndIf
			
		EndIf
		
		oObj:cFilterField:= HttpSession->cFilterField
		oObj:cFilterValue:= HttpSession->cFilterValue
		//retorna todos os Planos de Desenvolvimento Pessoal da equipe
		If oObj:MYTEAMOBJECTIVES( cCodUser, HttpSession->cUser, cTipo, "2" ) //Cod Usuario, Cod Avaliador, Tipo de Objetivo(1=Plano,2=Meta), Tipo de Status(1=Avaliado,2=Avaliador)
			HttpSession->MyAllTeamPlans := oObj:oWSMYTEAMOBJECTIVESRESULT:oWSOBJECTIVE
		Else
			conout( PWSGetWSError() )
		EndIf
	EndIf
	
	if Len(HttpSession->MyAllTeamPlans) > 0 
		HttpSession->MyTeamPlans:= PWSA0PAG(HttpSession->MyAllTeamPlans,HttpSession->nCurrentPage,nTPerPag)
	EndIf
	
	cHtml := ExecInPage( "PWSA045A" )
	WEB EXTENDED END
	
Return cHtml

/*************************************************************
* Autor...: Eduardo Ferreira                   Data: 14/06/16  *
* Objetivo: Retorna os pares do usuário				        *
*************************************************************/
Web Function PWSA045B()
	
	Local cHtml := ""
	Local cTipo	:= ""
	Local oObj
	Local oParam
	Local nTPerPag:= 5
	Private	cParBloq := ""
	HttpCTType("text/html; charset=ISO-8859-1")
	WEB EXTENDED INIT cHtml START "InSite"
	
	DEFAULT HttpGet->Page		:= "1"
	DEFAULT HttpGet->PageTotal	:= "1"
	DEFAULT HttpGet->Pos		:= "1"
	DEFAULT HttpGet->Pag		:= "0"
	DEFAULT HttpGet->FilterField:= ""
	DEFAULT HttpGet->FilterValue:= ""
	DEFAULT HttpGet->Destination:= ""
	
	//Default Pagina
	HttpSession->nPageTotal			:= Val(HttpGet->PageTotal)
	HttpSession->nCurrentPage		:= Val(HttpGet->Page)
	HttpSession->nPag				:= Val(HttpGet->Pag)
	HttpSession->cFilterField		:= HttpGet->FilterField
	HttpSession->cFilterValue		:= HttpGet->FilterValue
	HttpSession->cDestination 		:= HttpGet->Destination
	
	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
	WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")
	oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():NEW())
	WsChgURL(@oParam,"CFGDICTIONARY.APW")
	
	HttpSession->MyPairsPlans 		:= {}
	HttpSession->MyAllPairsPlans		:= {}
	HttpSession->DescrParticipant 	:= ""
	
	//Tratativa para incorporar busca por periodo nos Objetivos
	If Valtype(HttpSession->aPeriodos)=="A" .And. Len(HttpSession->aPeriodos)>0 .And. HttpSession->nOpcCMB > 0
		oObj:dPeriodDtIni	:= HttpSession->aPeriodos[HttpSession->nOpcCMB]:DPERIODDTINI
		oObj:dPeriodDtFin	:= HttpSession->aPeriodos[HttpSession->nOpcCMB]:DPERIODDTFIN
		oObj:CPeriodID		:= HttpSession->aPeriodos[HttpSession->nOpcCMB]:cPeriodID 
	EndIf
	
	IF oParam:GETPARAM( cCodUser, "MV_APDBLOQ" )
		cParBloq:= oParam:cGETPARAMRESULT
		If(oParam:cGETPARAMRESULT <> "1" .and. oParam:cGETPARAMRESULT <> "2")
			cParBloq:="2"
		EndIf
	ENDIF
	 
	//Determinar se disponibiliza a coluna 'Resultado Acumulado' nas páginas 'Pendências Atuais' e 'Consulta Histórico' nos Planos de Metas e Desenvolvimento? (1-Sim, 2-Não)"
	HttpSession->cAPDRES1 := '2' //2-Nao
	IF oParam:GETPARAM( cCodUser, "MV_APDRES1" ) 
		HttpSession->cAPDRES1 := oParam:cGETPARAMRESULT	
		If !(oParam:cGETPARAMRESULT $ '1*2*')
			HttpSession->cAPDRES1	:= '2'	
		EndIf 
	ENDIF
		//Determinar se disponibiliza a coluna 'Resultado Acumulado' nas páginas 'Pendências Atuais' e 'Consulta Histórico' nos Planos de Metas e Desenvolvimento? (1-Sim, 2-Não)"
	HttpSession->cAPDRES2 := '2' //2-Nao
	IF oParam:GETPARAM( cCodUser, "MV_APDRES2" ) 
		HttpSession->cAPDRES2 := oParam:cGETPARAMRESULT	
		If !(oParam:cGETPARAMRESULT $ '1*2*')
			HttpSession->cAPDRES2	:= '2'	
		EndIf 
	ENDIF
	If !Empty( HttpSession->cParticipantID )
		
		HttpSession->cUser := HttpSession->cParticipantID
		
		If !Empty(HttpGet->cTipo)
			If HttpGet->cTipo == "1"
				HttpSession->cTipoPlano := "PDP"
			Else
				HttpSession->cTipoPlano := "PM"
			EndIF
		EndIf
		
		If HttpSession->cTipoPlano == "PDP"
			cTipo := "1"	//PLANO DE DESENVOLVIMENTO PESSOAL
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ SESSION PARA VERIFICAR QUAL O TIPO DE TELA QUE SERA MOSTRADA  |
			//³ PDP=PLANO DE DESENVOLVIMENTO PESSOAL; PM=PLANO DE METAS		  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->cTipoPlano := "PDP"
			
			//PARAMETRO QUE VERIFICA SE APROVACAO DE VERSAO PODE FUNCIONAR OU NAO
			//SE RETORNO DO PARAMETRO = 1 NAO EXISTIRAO APROVACOES DE VERSAO
			//CASO CONTRARIO, CONTROLE DE VERSAO EXISTIRA NORMALMENTE
			If oParam:GETPARAM( cCodUser, "MV_APRVPDP" )
				HttpSession->cAprvPdp := AllTrim(oParam:cGETPARAMRESULT)
			Else
				HttpSession->cAprvPdp := ""
			EndIf
			
		Else
			cTipo := "2"	//PLANO DE METAS
			
			//PARAMETRO QUE VERIFICA SE APROVACAO DE VERSAO PODE FUNCIONAR OU NAO
			//SE RETORNO DO PARAMETRO = 1 NAO EXISTIRAO APROVACOES DE VERSAO
			//CASO CONTRARIO, CONTROLE DE VERSAO EXISTIRA NORMALMENTE
			If oParam:GETPARAM( cCodUser, "MV_APRVPM" )
				HttpSession->cAprvPm := AllTrim(oParam:cGETPARAMRESULT)
			Else
				HttpSession->cAprvPm := ""
			EndIf
			
		EndIf
		
		oObj:cFilterField	:= HttpSession->cFilterField
		oObj:cFilterValue	:= HttpSession->cFilterValue
		//retorna todos os Planos de Desenvolvimento Pessoal da equipe
		If oObj:MYPAIRSOBJECTIVE( cCodUser, HttpSession->cUser, cTipo, "2" ) //Cod Usuario, Cod Avaliador, Tipo de Objetivo(1=Plano,2=Meta), Tipo de Status(1=Avaliado,2=Avaliador)
			HttpSession->MyAllPairsPlans := oObj:oWSMYPAIRSOBJECTIVERESULT:oWSOBJECTIVE
		Else
			conout( PWSGetWSError() )
		EndIf
	EndIf
	
	if Len(HttpSession->MyAllPairsPlans) > 0 
		HttpSession->MyPairsPlans:= PWSA0PAG(HttpSession->MyAllPairsPlans,HttpSession->nCurrentPage,nTPerPag)
	EndIf
	
	cHtml := ExecInPage( "PWSA045B" )
	WEB EXTENDED END
	
Return cHtml


/*************************************************************/
/* Autor...: Thiago dos Reis     			  Data: 18/01/05 */
/* Objetivo: Aprovar Objetivo e apagar versoes intermediárias*/
/*************************************************************/
Web Function PWSA046()
Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")

//UserCode,ObjID,PeriodID,ParticipantId,EvaluatorId,PlanVersion
If oObj:AproveObjetive( cCodUser, HttpGet->cCodPlano, HttpGet->cCodPeriod, HttpSession->cUser, HttpSession->EvaluatorId, HttpSession->PlanVersion, HttpGet->cAct )
	cHtml := "<script>alert('" + STR0014 + " "	//Plano
	If HttpGet->cAct == "3"
		cHtml += STR0015	//"Finalizado"
	Else
		cHtml += STR0016	//"Aprovado"
	EndIf
	cHtml += " " + STR0017 + "!');</script>" //com sucesso
Else
	conout( PWSGetWSError() )
	cHtml := "<script>alert('" + STR0018 + " "
	If HttpGet->cAct == "3"
		cHtml += STR0015	//"Finalizado"
	Else
		cHtml += STR0016	//"Aprovado"
	EndIf
	cHtml += ".');</script>"
EndIf

If HttpSession->cTipoPlano == "PDP"
	cHtml += W_PWSA040()
Else
	cHtml += W_PWSA004()
EndIf


WEB EXTENDED END
Return cHtml

/*************************************************************/
/* Autor...: Thiago dos Reis       			  Data: 20/12/04 */
/* Objetivo: Exclui item do objetivo do participante         */
/*************************************************************/
Web Function PWSA047()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")
oObj:oWSLISTOFITEMPROP := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHPERSONALDESENVPLAN_ITEMPROPRETIES"), RHPERSONALDESENVPLAN_ITEMPROPRETIES():NEW())

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
HttpGet->cCodPlano	:= HttpGet->cCodPlano
HttpGet->cCodTopic 	:= HttpGet->cCodTopic
HttpGet->cCodPeriod	:= HttpGet->cCodPeriod
HttpGet->nTipo		:= HttpGet->nTipo
HttpGet->cAct		:= HttpGet->cAct
cHtml :=  W_PWSA041()

WEB EXTENDED END

Return cHtml

/*************************************************************/
/* Autor...: Eduardo Ferreira     			  Data: 22/06/16 */
/* Objetivo: Cancela item do objetivo do participante         */
/*************************************************************/
Web Function PWSA04D()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")
oObj:oWSLISTOFITEMPROP := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHPERSONALDESENVPLAN_ITEMPROPRETIES"), RHPERSONALDESENVPLAN_ITEMPROPRETIES():NEW())

oObj:oWSLISTOFITEMPROP:cObjectiveId			:= HttpGet->cCodPlano
oObj:oWSLISTOFITEMPROP:cPeriod      		:= HttpGet->cCodPeriod
oObj:oWSLISTOFITEMPROP:cEvaluatedId			:= HttpSession->cUser
oObj:oWSLISTOFITEMPROP:cEvaluatorId 		:= HttpSession->EvaluatorId
oObj:oWSLISTOFITEMPROP:cITEM 				:= HttpGet->cItem
oObj:oWSLISTOFITEMPROP:cSubPlanID 			:= HttpGet->cCodTopic
oObj:oWSLISTOFITEMPROP:cStatus      		:= HttpGet->cStatus
oObj:oWSLISTOFITEMPROP:cItemPlanVersion		:= HttpSession->PlanVersion

If !oObj:CANCELAITEM( cCodUser, oObj:oWSLISTOFITEMPROP )
	conout( PWSGetWSError() )
EndIf
HttpGet->cCodPlano	:= HttpGet->cCodPlano
HttpGet->cCodTopic 	:= HttpGet->cCodTopic
HttpGet->cCodPeriod	:= HttpGet->cCodPeriod
HttpGet->nTipo		:= HttpGet->nTipo
HttpGet->cAct		:= HttpGet->cAct
cHtml :=  W_PWSA041()

WEB EXTENDED END

Return cHtml
/*************************************************************/
/* Autor...: Thiago dos Reis         		  Data: 20/12/04 */
/* Objetivo: Pop Up para selecionar o avaliador              */
/*************************************************************/
Web Function PWSA048()
Local cHtml := ""
Local cNome := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():NEW())
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
	HttpSession->_HTMLERRO := { STR0004, PWSGetWSError(), "W_PWSA040.APW" }
 	Return ExecInPage("PWSAMSG" )
EndIf

WEB EXTENDED END

Return cHtml

/*************************************************************/
/* Autor...: Thiago dos Reis         		  Data: 20/12/04 */
/* Objetivo: Alterar o avaliador     				         */
/*************************************************************/
Web Function PWSA049()
Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():NEW())
WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")

If oObj:setEvaluator( cCodUser, HttpSession->cUser, HttpGet->cAvaliador, HttpSession->EvaluatorId, HttpGet->cCodPlano, HttpGet->cCodPeriod )
	HttpSession->EvaluatorName	:= HttpGet->cNomeAvaliador
	HttpSession->EvaluatorId	:= HttpGet->cAvaliador

	HttpGet->cCodAvaliador := HttpGet->cAvaliador
	cHtml := "<script>alert('" + STR0019 + "!');</script>" //Avaliador alterado com sucesso
	cHtml += W_PWSA043()
Else
	HttpSession->_HTMLERRO := { STR0004, PWSGetWSError(), "W_PWSA040.APW" }
	Return ExecInPage("PWSAMSG" )
EndIf

WEB EXTENDED END
Return cHtml

/*************************************************************/
/* Autor...: Thiago dos Reis     			  Data: 21/12/04 */
/* Objetivo: Alterar a descricao do papel do participante    */
/* em um determinado objetivo       				         */
/*************************************************************/
Web Function PWSA04A()
Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")

If oObj:SETUSEROBJPAPER( cCodUser, HttpGet->cCodPlano, HttpGet->cCodPeriod, HttpSession->EvaluatorId, HttpSession->cUser, HttpPost->cDescr )
	If HttpSession->cAuthor == "1" //AVALIADO
		HttpGet->cCodAvaliador	:= HttpSession->EvaluatorId
	ElseIf HttpSession->cAuthor == "2" //AVALIADOR
		HttpGet->cParticipant	:= HttpSession->cUser
	EndIf
	cHtml := "<script>alert('" + STR0020 + "!');</script>" //Descrição gravada com sucesso
	cHtml += W_PWSA043()
Else
	HttpSession->_HTMLERRO := { STR0004, PWSGetWSError(), "W_PWSA040.APW" }
	Return ExecInPage("PWSAMSG")
EndIf

WEB EXTENDED END
Return cHtml

/*************************************************************/
/* Autor...: Thiago dos Reis     			  Data: 11/01/05 */
/* Objetivo: Aprova ou Reprova um item 						 */
/* em um determinado objetivo       				         */
/*************************************************************/
Web Function PWSA04B()
Local cHtml := ""
Local nz := 0
Local lResult := .F.

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")

For nz := 1 to Len(HttpPost->aPost) //o comando HttpPost->aPost retorna um array de todos os inputs postados
	If Substr( HttpPost->aPost[nz], 1, 3 ) == "CHK"
		If !oObj:ApproveFailItem( cCodUser, HttpPost->cCodPlano, HttpPost->cCodPeriod, HttpSession->cUser, HttpSession->EvaluatorId, HttpSession->PlanVersion, HttpPost->cCodTopic, &("HttpPost->"+HttpPost->aPost[nz]), HttpSession->cAuthor, HttpPost->cStatus )
			HttpSession->_HTMLERRO := { STR0004, PWSGetWSError(), "W_PWSA04B.APW" }
			Return ExecInPage("PWSAMSG")
		EndIf
	EndIf
next

HttpGet->cCodPlano	:= HttpPost->cCodPlano
HttpGet->cCodTopic 	:= HttpPost->cCodTopic
HttpGet->cCodPeriod	:= HttpPost->cCodPeriod
HttpGet->nTipo		:= HttpPost->nTipo
HttpGet->cAct		:= HttpPost->cAct
cHtml :=  W_PWSA041()


WEB EXTENDED END
Return cHtml

/*************************************************************/
/* Autor...: Thiago dos Reis     			  Data: 11/01/05 */
/* Objetivo: Lista todas as versoes do historico 			 */
/*************************************************************/
Web Function PWSA04C()
Local cHtml 	:= ""
Local cVersao 	:= ""
Local cAval 	:= ""
Local cPart		:= ""
Local cPlan 	:= ""
Local cPeri 	:= ""
Local cType		:= ""
Local cUrl		:= ""
Local oObj		:= ""
Local oObj1		:= ""
Local lmyplans	:= .T.
Local lequiplans:= .T.

WEB EXTENDED INIT cHtml START "InSite"
Default HttpGet->cPlanoFin		:= ""
Default HttpGet->cCodPlano		:= ""	
Default HttpGet->cCodPeriod		:= ""
Default HttpGet->cParticipant	:= ""
Default HttpGet->cNomePlano		:= ""
Default HttpGet->cNomePeriodo	:= ""
Default HttpGet->cNomeAvaliador	:= ""
Default HttpGet->cNomeAvaliado	:= ""
Default HttpGet->cUltAprov		:= ""
Default HttpSession->cUrl				:= ""

Default HttpGet->nOpcCMB		:= "0"

oObj	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
oObj1	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")
WsChgURL(@oObj1,"RHPERSONALDESENVPLAN.APW")

HttpSession->nOpcCMB			:= IIF(HttpSession->nOpcCMB!= 0 .And. Val(HttpGet->nOpcCMB)==0,HttpSession->nOpcCMB,Val(HttpGet->nOpcCMB))
HttpSession->cNomePlano			:= IIF(!Empty(HttpSession->cNomePlano) .And. Empty(HttpGet->cNomePlano),HttpSession->cNomePlano,"")
HttpSession->cNomePeriodo		:= IIF(!Empty(HttpSession->cNomePeriodo) .And. Empty(HttpGet->cNomePeriodo),HttpSession->cNomePeriodo,"")
HttpSession->cNomeAvaliador		:= IIF(!Empty(HttpSession->cNomeAvaliador) .And. Empty(HttpGet->cNomeAvaliador),HttpSession->cNomeAvaliador,"")
HttpSession->cNomeAvaliado		:= IIF(!Empty(HttpSession->cNomeAvaliado) .And. Empty(HttpGet->cNomeAvaliado),HttpSession->cNomeAvaliado,"")
HttpSession->cUltAprov			:= IIF(!Empty(HttpSession->cUltAprov) .And. Empty(HttpGet->cUltAprov),HttpSession->cUltAprov,"")

 
HttpSession->HistVersion		:= {}
HttpSession->HistTopicItens		:= {}
HttpSession->HistMyPlans		:= {}
HttpSession->HistMyEquipPlans	:= {}

If Valtype(HttpSession->aPeriodos)=="A" .And. Len(HttpSession->aPeriodos)>0 .And. HttpSession->nOpcCMB > 0 
	HttpGet->cCodPeriod:= HttpSession->aPeriodos[HttpSession->nOpcCMB]:cPeriodID
EndIf
If !Empty(HttpGet->cCodPlano)
	cPlan := HttpGet->cCodPlano
	cUrl:= 'W_PWSA04C.apw?cPlanoFin=1&cCodPlano=' + cPlan 
EndIf
If !Empty(HttpGet->cCodPeriod)
	 cPeri := HttpGet->cCodPeriod
	 cUrl	+= '&cCodPeriod=' + cPeri  
EndIf

If !Empty(HttpGet->cCodVersao)
	cVersao := HttpGet->cCodVersao
	HttpSession->cCodVersao:= cVersao
EndIf
If !Empty(HttpGet->cTipo)
	cType := HttpGet->cTipo
	HttpSession->cTipo:= cType
EndIf

If Empty(HttpGet->cParticipant) .and. !Empty(HttpGet->cCodAvaliador) //Meus Planos Correntes
	cAval := HttpGet->cCodAvaliador
	cPart := HttpSession->cParticipantID
	cUrl	+= '&cCodAvaliador=' + cAval 
ElseIf Empty(HttpGet->cCodAvaliador) .and. !Empty(HttpGet->cParticipant) //Planos Correntes da Minha equipe
	cAval := HttpSession->cParticipantID
	cPart := HttpGet->cParticipant
	cUrl	+= '&cParticipant=' +  cPart
EndIf
 
cUrl	+= '&cNomePlano=' + AlltoChar(HttpSession->cNomePlano) + '&cNomePeriodo=' + AlltoChar(HttpSession->cNomePeriodo)
cUrl	+= '&cNomeAvaliado=' + AlltoChar(HttpSession->cNomeAvaliado) + '&cNomeAvaliador=' + AlltoChar(HttpSession->cNomeAvaliador) + '&cUltAprov=' + AlltoChar(HttpSession->cUltAprov)

if !Empty(HttpGet->cLink)
	HttpSession->cUrl	:= ""+StrTran(cUrl,"'","")+""
EndIf
If !Empty(cType)
	Begin Sequence
	//CONSULTA MEU PLANO
	lmyplans 	:= oObj:ShowHistory( cCodUser, cType, cPlan, cPeri, HttpSession->cParticipantID, cAval, cVersao )   //UserCode,TypeId,ObjID,PeriodID,ParticipantId,EvaluatorId,PlanVersion
	//CONSULTA PLANO DE MINHA EQUIPE
    lequiplans	:= oObj1:ShowHistory( cCodUser, cType, cPlan, cPeri, cPart, HttpSession->cParticipantID, cVersao ) //UserCode,TypeId,ObjID,PeriodID,ParticipantId,EvaluatorId,PlanVersion

	//MEU PLANO    
    If lmyplans
		HttpSession->HistMyPlans	:= oObj:oWSSHOWHISTORYRESULT:oWSLISTOFOBJECTIVE:oWSOBJECTIVE
	EndIF
	
	//PLANO DE MINHA EQUIPE
	If lequiplans
		HttpSession->HistMyEquipPlans	:= oObj1:oWSSHOWHISTORYRESULT:oWSLISTOFOBJECTIVE:oWSOBJECTIVE
	EndIF
	
	
	IF !lmyplans .and. !lequiplans 
		If cType == "1"
			HttpSession->_HTMLERRO := { STR0021, STR0022, "W_PWSA000.APW","top" } //"Plano de Desenvolvimento - Consulta" || "Não há plano finalizado para o usuário"		
		Else
			HttpSession->_HTMLERRO := { STR0021, STR0022, "javascript:window.close();" } //"Plano de Desenvolvimento - Consulta" || "Não há plano finalizado para o usuário"
		EndIf
		cHtml := ExecInPage("PWSAMSG")
		Break
	EndIf


	If cType == "1"
		HttpSession->cTipoPlano := "PDP"
	EndIf

	cHtml := H_PWSA040PopHist()
	End Sequence
Else
	If oObj:ShowHistory( cCodUser, cType, cPlan, cPeri, cPart, cAval, cVersao ) //UserCode,TypeId,ObjID,PeriodID,ParticipantId,EvaluatorId,PlanVersion
		HttpSession->HistVersion	:= oObj:oWSSHOWHISTORYRESULT:oWSHISTVERSION:nFLOAT
		HttpSession->HistTopicItens	:= oObj:oWSSHOWHISTORYRESULT:oWSHISTSUBPLANS:oWSSUBPLANS

		cHtml := H_PWSA04PopHist()
	Else
		Return PWSHTMLAlert("", STR0004, PWSGetWSError(), "W_PWSX022.APW" )
	EndIf
EndIf

WEB EXTENDED END
Return cHtml



/*************************************************************
* Autor...: Juliana Barros                    Data: 29/04/05 *
* Objetivo: Chama pagina com desenho do processo do plano    *
**************************************************************/
Web Function PWSA040PROC()

Local cHtml		:= ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml := ExecInPage("PWSA046")

WEB EXTENDED END

Return cHtml


/*************************************************************
* Autor...: Juliana Barros                    Data: 20/03/06 *
* Objetivo: Checa se ja existe plano com este avaliador      *
**************************************************************/
Web Function PWSA048A()

Local cHtml		:= ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
WsChgURL(@oObj,"RHPERSONALDESENVPLAN.APW")

	If !Empty(HttpSession->cUser) .and. !Empty(HttpGet->cCodPlano) .and. !Empty(HttpGet->cAvaliador) .and. !Empty(HttpGet->cCodPeriod)
		If !oObj:ChkObjetive(cCodUser,HttpSession->cUser,HttpGet->cAvaliador,HttpGet->cCodPlano,HttpGet->cCodPeriod)
			cHtml := "<script>alert('"+PWSGetWSError()+"');</script>"
			cHtml += W_PWSA040A()
		Else
			cHtml += W_PWSA049()
		EndIf
    Else
		cHtml += W_PWSA049()
	EndIf

WEB EXTENDED END

Return cHtml          

/*************************************************************
* Autor...: Eduardo Ferreira                  Data: 10/06/16 *
* Objetivo: Controle de Paginação      *
**************************************************************/
Static Function PWSA0PAG(aRegOrig,nPos,nTPerPag)

Local nX			:= 1 
Local aRetorno		:= {}
Local lContinua		:= .T.

Default aRegOrig	:= {}

Default nPos		:=	1
Default nTPerPag	:= 10

If Mod(Len(aRegOrig),nTPerPag) > 0
	HttpSession->nPageTotal	:= NoRound((Len(aRegOrig)/nTPerPag),0)+1
Else
	HttpSession->nPageTotal	:= Len(aRegOrig)/nTPerPag
EndIF

nPos:= (nPos*nTPerPag)-(nTPerPag-1)

While (nPos <= Len(aRegOrig) .And. nPos!=0 .And. nTPerPag!=0 )
	aAdd(aRetorno,aRegOrig[nPos])
	nTPerPag -= 1
	nPos	 += 1
EndDo

Return aClone(aRetorno)
