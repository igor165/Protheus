#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA070PRW.CH"


#DEFINE cCodUser "MSALPHA"

/*******************************************************************
* Funcao: PWSA070TEXTO - Tela de abertura com explicacao sobre curriculo
* Autor:	Juliana Barros Mariano
* Data:		29/09/2005
********************************************************************/
Web Function PWSA070TEXTO()
	Local cHtml		:= ""
	Local oParam 	:= ""
	Local oMsg		:= ""	
	Private cLink
	Private cMessage := If(Type("cMessage") <> "U", cMessage, STR0004	)	//"Apresentação estruturada do currículo dos funcionários, possibilitando sua manutenção pelo mesmo, bem como consulta pelos seus superiores"
	
	WEB EXTENDED INIT cHtml START "InSite"	
		oParam  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		WsChgURL(@oParam,"CFGDICTIONARY.APW")
		
		oMsg  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():New())
		WsChgURL(@oMsg,"RHPERSONALDESENVPLAN.APW")
				
		//RESGATA PARAMETRO CONTENDO CODIGO DA MENSAGEM
		//SE EM QUALQUER SITUACAO MSG NAUM ESTIVER CADASTRADA OU ESTIVER EM BRANCO, VALE MSG DEFAULT
		If oParam:GETPARAM( cCodUser, "MV_MSGCE")
			If !Empty(oParam:cGETPARAMRESULT)
				If oMsg:GETMESSAGE( cCodUser, oParam:cGETPARAMRESULT )
					If !Empty(oMsg:cGETMESSAGERESULT)
						cMessage := StrTran(oMsg:cGETMESSAGERESULT, Chr(10), "<br>" )
					EndIf
				EndIf
			EndIf
		EndIf
		cHtml := W_PWSA070MENTOR()
		// No Req126_02 (2012) foi solicitado para remover a tela intermediaria
	   //	cHtml := ExecInPage("PWSA070A")	
	WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA070MENTOR - Tela de selecao do mentor
* Autor:	Juliana Barros Mariano
* Data:		15/08/2005
********************************************************************/
Web Function PWSA070MENTOR()
	Local cHtml	:= ""
	Local oMentor    
	Local oParam
	Local cCVMod := ""
	
	Private cMessage := If(Type("cMessage") <> "U", cMessage, STR0004	)//"Apresentação estruturada do currículo dos funcionários, possibilitando sua manutenção pelo mesmo, bem como consulta pelos seus superiores"
		
	WEB EXTENDED INIT cHtml START "InSite"		
		oParam  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		WsChgURL(@oParam,"CFGDICTIONARY.APW")
		
		If oParam:GetParam(cCodUser, "MV_CVMOD")
			cCVMod:= oParam:cGetParamResult
		EndIf
	
		oMentor  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEMPLOYEDCURRICULUM"), WSRHEMPLOYEDCURRICULUM():New())
		WsChgURL(@oMentor,"RHEMPLOYEDCURRICULUM.APW")	
	
		//PEGA DADOS DO PARTICIPANTE LOGADO
		If oMentor:GETPARTICIPANT(cCodUser, HttpSession->cParticipantID)
			If cCVMod == "ORG"
				cHtml := W_PWSA070()
			Else
				If Empty(oMentor:oWSGETPARTICIPANTRESULT:cCODMENTOR)
					cHtml := ExecInPage("PWSA070MENTOR" )
				Else
					cHtml := W_PWSA070()
				EndIf
			EndIf
		Else       
			cHtml := W_PWSA070()
		EndIf	
	WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA070M2 - Funcao de gravacao do mentor
* Autor:	Juliana Barros Mariano
* Data:		16/08/2005
********************************************************************/
Web Function PWSA070A()
	Local cHtml		:= ""
	Local oMentor	:= ""
		
	WEB EXTENDED INIT cHtml START "InSite"
		oMentor	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oMentor,"RHEMPLOYEDCURRICULUM.APW")
	
		//PEGA DADOS DO PARTICIPANTE LOGADO
		If oMentor:PutMentor(cCodUser, HttpSession->cParticipantID, HttpPost->cAvaliador)
			cHtml := W_PWSA070()
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA070.APW" } //STR0001
	 		cHtml := ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END	
Return cHtml

/*******************************************************************
* Funcao: PWSA070 - Verifica qual tipo de 
* Autor:	Rogerio Augusto
* Data:		14/12/2004
* Alterado: Juliana Barros - 15/08/2005
********************************************************************/
Web Function PWSA070()
	Local cCVMod	:= "APD"
	Local oParam
	Local cHtml

	WEB EXTENDED INIT cHtml START "InSite"	
		oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		WsChgURL(@oParam,"CFGDICTIONARY.APW")
		
		If oParam:GetParam(cCodUser, "MV_CVMOD")
			cCVMod:= oParam:cGetParamResult
		EndIf
	
		If cCVMod == "ORG"
			cHtml:= W_PWSA200()
		Else
			cHtml:= W_PWSA070B()
		EndIf
	WEB EXTENDED END		
Return cHtml


/*******************************************************************
* Funcao: PWSA070 - Monta a tela inicial do Curriculo
* Autor:	Rogerio Augusto
* Data:		14/12/2004
* Alterado: Juliana Barros - 15/08/2005
********************************************************************/
Web Function PWSA070B()
	Local cHtml		:= ""
	Local cCodVis	:= ""
	Local oParam	:= ""
	Local oObj		:= ""
	Local oPart		:= ""
	//cMessage - Utilizado no voltar da apresentacao do curriculo
	Private cMessage := If(Type("cMessage") <> "U", cMessage, STR0004	)	//"Apresentação estruturada do currículo dos funcionários, possibilitando sua manutenção pelo mesmo, bem como consulta pelos seus superiores"
	
	WEB EXTENDED INIT cHtml START "InSite"
		oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		oObj	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHIDENTIFY"), WSRHIDENTIFY():New())
		oPart	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oParam,"CFGDICTIONARY.APW")
		WsChgURL(@oObj,"RHIDENTIFY.APW")
		WsChgURL(@oPart,"RHEMPLOYEDCURRICULUM.APW")
		
		HttpPost->BRWSUBORTINATES := {}
	
		If oParam:GETPARAM( cCodUser, "MV_APDVIS" )
			cCodVis := oParam:cGETPARAMRESULT
		EndIf
	
		//PEGA DADOS DO PARTICIPANTE LOGADO
		If oPart:GETPARTICIPANT( cCodUser,HttpSession->cParticipantID, cCodVis )
		    HttpSession->aUsuario := 	{	oPart:oWSGETPARTICIPANTRESULT:CREGISTRATION,;
											oPart:oWSGETPARTICIPANTRESULT:CNAME,;
											oPart:oWSGETPARTICIPANTRESULT:CFILIAL,;
											oPart:oWSGETPARTICIPANTRESULT:CEVALUATORNAME,;
											oPart:oWSGETPARTICIPANTRESULT:DLASTUPDATE,;
											oPart:oWSGETPARTICIPANTRESULT:CCODMENTOR,;
											oPart:oWSGETPARTICIPANTRESULT:CMENTORNAME,;
											oPart:oWSGETPARTICIPANTRESULT:CHIERARQLEVEL,;
											oPart:oWSGETPARTICIPANTRESULT:CAREA}
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA00C.APW" } //STR0001
	 		Return ExecInPage("PWSAMSG")
		EndIf
	
	
	
		//CONSULTA SUBORDINADOS DO PARTICIPANTE LOGADO CASO HAJA
	    If oObj:BRWSUBORTINATES( cCodUser, HttpSession->cParticipantID, cCodVis )
	    	//HttpPost->BRWSUBORTINATES := oObj:oWSBRWSUBORTINATESRESULT:oWSUSERINFO
			HttpPost->BRWSUBORTINATES := aSort(oObj:oWSBRWSUBORTINATESRESULT:oWSUSERINFO,,, { |x, y| UPPER(x:cUserName) < UPPER(y:cUserName) })
	    Else // Caso o usuario nao faca parte de alguma visao, direciona apenas para seus dados pessoais
	    	//cHtml += W_PWSA051()
		EndIf
	
		cHtml += ExecInPage( "PWSA070" )
	WEB EXTENDED END
Return cHtml



/*******************************************************************
* Funcao: PWSA071 - Carrega um item relacionado ao menu principal
*				  - Tela para item especifico (Cursos em geral)
* Autor:	Rogerio Augusto
* Data:		17/12/2004
********************************************************************/
Web Function PWSA071()
	Local cHtml := ""
	Local cCodigo := ""
	Local cTitulo := ""
	
	WEB EXTENDED INIT cHtml START "InSite"	
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
		
		If !empty( HttpPost->cCodigo )
			cCodigo := HttpPost->cCodigo
			cTitulo := HttpPost->cTitulo
		Else
			cCodigo := HttpGet->cCodigo
			cTitulo := HttpGet->cTitulo
		EndIf
		
		If oObj:BrwItemData( cCodUser, cCodigo, HttpSession->cPartAcesso[1] )
			HttpSession->aItens := oObj:oWSBRWITEMDATARESULT
			HttpPost->cTitulo := cTitulo
			HttpPost->cCodigo := cCodigo
	
			cHtml += ExecInPage( "PWSA071" )
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA076.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf	
	WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA071b - Carrega um item relacionado ao menu principal
*				   - Tela para item especifico (Filiacao de entidade de classe)
* Autor:	Rogerio Augusto
* Data:		27/01/2005
********************************************************************/
Web Function PWSA071b()
	Local cHtml := ""
	Local cTitulo := ""
	
	WEB EXTENDED INIT cHtml START "InSite"	
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
		
		If !empty( HttpPost->cTitulo )
			cTitulo := HttpPost->cTitulo
		Else
			cTitulo := HttpGet->cTitulo
		EndIf		
			If oObj:BrwEntData( cCodUser, HttpSession->cPartAcesso[1] )
				HttpSession->aItens := oObj:oWSBRWENTDATARESULT
				HttpPost->cTitulo := cTitulo
				cHtml += ExecInPage( "PWSA076" )
			Else
				HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA076.APW" }
		 		Return ExecInPage("PWSAMSG")
			EndIf		
	WEB EXTENDED END	
Return cHtml

/*******************************************************************
* Funcao: PWSA072 - Insere um novo curso na SQ9 - Cadastro de Cursos
*
* Autor:	Rogerio Augusto
* Data:		11/01/2005
********************************************************************/
Web Function PWSA072()
	Local cHtml := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
		
		oObj:oWSCourseList := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHEmployedCurriculum_CourseList"), RHEmployedCurriculum_CourseList():New())	
		oObj:oWSCourseList:cCourseCod	:= HttpPost->curso
		oObj:oWSCourseList:cCourseName	:= HttpPost->cCursoDesc
		oObj:oWSCourseList:cCourseEnt	:= HttpPost->instituicao
		
		If !Empty(HttpPost->datafim)
			oObj:oWSCourseList:dCourseCDate	:= ctod(HttpPost->datafim)
		EndIf
		
		If !Empty(HttpPost->datainicio)
			oObj:oWSCourseList:dCourseIDate	:= ctod(HttpPost->datainicio)
		EndIf
		
		oObj:oWSCourseList:cCourseType	:= HttpPost->tipo
		oObj:oWSCourseList:cCourseStatus := HttpPost->cstatus
		
		If !Empty(HttpPost->cDuracao)
			oObj:oWSCourseList:nCourseTime	:= val(AllTrim(strTran(HttpPost->cDuracao,":",".")))
		EndIf
		
		oObj:oWSCourseList:cCourseDesc	:= HttpPost->cDescricao
	
		If oObj:PutCourse( cCodUser, HttpSession->cParticipantID, oObj:oWSCourseList )
			If HttpPost->cTela == "CM" //CAPACITACAO DE MERCADO / MICROSIGA
				cHtml := W_PWSA082()
			ElseIf HttpPost->cTela == "ID" //IDIOMAS
				cHtml := W_PWSA084()
			Else
				cHtml := W_PWSA071()
			EndIf
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA071.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END
Return cHtml

/*******************************************************************
* Funcao: PWSA073 - Deleta um registro da tabela de cursos
*
* Autor:	Rogerio Augusto
* Data:		12/01/2005
********************************************************************/
Web Function PWSA073()	
	Local cHtml := ""
	
	WEB EXTENDED INIT cHtml START "InSite"	
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
		
		If oObj:DelItemData( cCodUser, val(HttpPost->cRecno) )
			If HttpPost->cTela == "CM" //CAPACITACAO MERCADO
				cHtml := W_PWSA082()
			ElseIf HttpPost->cTela == "ID" //IDIOMAS
				cHtml := W_PWSA084()
			ElseIf HttpPost->cTela == "CI" //CERTIFICACAO DE MERCADO
				cHtml := W_PWSA087()
			Else
				cHtml := W_PWSA071()
			EndIf
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA076.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA073a - Deleta um registro da tabela de cursos
*
* Autor:	Rogerio Augusto
* Data:		12/01/2005
********************************************************************/
Web Function PWSA073A()
	Local cHtml := ""
	
	WEB EXTENDED INIT cHtml START "InSite"		
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
	
		If oObj:DelExpItem( cCodUser, val(HttpPost->cItem) )
			HttpPost->cUserName := HttpPost->cUserName
			cHtml += W_PWSA077()
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA071.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf	
	WEB EXTENDED END	
Return cHtml



/*******************************************************************
* Funcao: PWSA073b - Deleta um registro da tabela de filiacao de entidade
*
* Autor:	Rogerio Augusto
* Data:		31/01/2005
********************************************************************/
Web Function PWSA073b()
	Local cHtml := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
	
		If oObj:DelEntItem( cCodUser, val(HttpPost->cRecno) )
			cHtml += W_PWSA071b()
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA071.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA074 - Consulta Experiencia profissionais de mercado
*
* Autor:	Juliana Barros Mariano
* Data:		12/01/2005
********************************************************************/
Web Function PWSA074()
	Local cHtml := ""
	Local oHist := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oHist := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oHist,"RHEmployedCurriculum.APW")
		
		If oHist:BRWEXTERNALHISTORY( cCodUser, HttpSession->cPartAcesso[1] )
			HttpPost->aHistorico := oHist:oWSBRWEXTERNALHISTORYRESULT:oWSHISTORYLIST
			cHtml := ExecInPage("PWSA072")
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA076.APW" }
	 		cHtml := ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END	
Return cHtml

/*******************************************************************
* Funcao: PWSA075 - Altera um curso na SQ9 - Cadastro de Cursos
*
* Autor:	Rogerio Augusto
* Data:		13/01/2005
********************************************************************/
Web Function PWSA075()
	Local cHtml := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
		
		oObj:oWSCourseList := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHEmployedCurriculum_CourseList"), RHEmployedCurriculum_CourseList():New())	
		oObj:oWSCourseList:cCourseCod 		:= HttpPost->curso
		oObj:oWSCourseList:cCourseEnt 		:= HttpPost->instituicao
		
		If !Empty(HttpPost->datafim)
			oObj:oWSCourseList:dCourseCDate 	:= ctod(HttpPost->datafim)
		EndIf
		
		If !Empty(HttpPost->datainicio)
			oObj:oWSCourseList:dCourseIDate 	:= ctod(HttpPost->datainicio)
		EndIf
		
		oObj:oWSCourseList:cCourseType 		:= HttpPost->tipo
		oObj:oWSCourseList:cCourseStatus	:= HttpPost->cstatus
		oObj:oWSCourseList:nRegRecno		:= val(HttpPost->cRecno)
		
		If !Empty(HttpPost->cDuracao)
			oObj:oWSCourseList:nCourseTime	:= val(AllTrim(strTran(HttpPost->cDuracao,":",".")))
		EndIf
		
		oObj:oWSCourseList:cCourseDesc	:= HttpPost->cDescricao
		oObj:oWSCourseList:cCourseName	:= HttpPost->cCursoDesc
	
		If oObj:SetItemData( cCodUser, HttpSession->cParticipantID, oObj:oWSCourseList )
			If HttpPost->cTela == "CM"	//CAPACITACAO MERCADO/MICROSIGA
				cHtml := W_PWSA082()
			ElseIf HttpPost->cTela == "ID" //IDIOMAS
				cHtml := W_PWSA084()
			Else
				cHtml := W_PWSA071()
			EndIf
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA071.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END
Return cHtml

/*******************************************************************
* Funcao: PWSA076 - Carrega as opcoes de conteudo do participante
*
* Autor:	Rogerio Augusto
* Data:		17/01/2005
********************************************************************/
Web Function PWSA076()
	Local cHtml 	:= ""
	Local oParam	:= ""
	Local oObj		:= ""
	Local cCodVis	:= ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		oObj	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oParam,"CFGDICTIONARY.APW")
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
	
		//tpAvaliador
		//1 - Participante
		//2 - Avaliador
		//3 - Mentor
	
		//PEGA DADOS DO PARTICIPANTE QUE ESTA ENTRANDO AGORA
		If !Empty(HttpPost->ParticipantID)
			HttpSession->cPartAcesso := {"",""}
			HttpSession->cPartAcesso[1] := HttpPost->ParticipantID
			HttpSession->cPartAcesso[2] := HttpPost->tpAvaliador
		EndIf
	
		If oParam:GETPARAM( cCodUser, "MV_APDVIS" )
			cCodVis := oParam:cGETPARAMRESULT
		EndIf
	
		//PEGA DADOS DO PARTICIPANTE LOGADO
		If oObj:GETPARTICIPANT( cCodUser, HttpSession->cPartAcesso[1], cCodVis )
		    HttpSession->aUsuario := {	oObj:oWSGETPARTICIPANTRESULT:CREGISTRATION,;
										oObj:oWSGETPARTICIPANTRESULT:CNAME,;
										oObj:oWSGETPARTICIPANTRESULT:CFILIAL,;
										oObj:oWSGETPARTICIPANTRESULT:CEVALUATORNAME,;
										oObj:oWSGETPARTICIPANTRESULT:DLASTUPDATE,;
										oObj:oWSGETPARTICIPANTRESULT:CCODMENTOR,;
										oObj:oWSGETPARTICIPANTRESULT:CMENTORNAME,;
										oObj:oWSGETPARTICIPANTRESULT:CHIERARQLEVEL,;
										oObj:oWSGETPARTICIPANTRESULT:CAREA}
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA00C.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf
	
		If oObj:BrwItemTypes( cCodUser, HttpSession->cPartAcesso[1] )
			HttpSession->aMenu := oObj:oWSBRWITEMTYPESRESULT:oWSITENSMENU
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA076.APW" }
	 		Return ExecInPage("PWSAMSG" )
		EndIf
	
		cHtml += ExecInPage( "PWSA073" )	
	WEB EXTENDED END	
Return cHtml

/*******************************************************************
* Funcao: PWSA077 - Carrega os itens da experiencia
*							 profissional Microsiga
*
* Autor:	Rogerio Augusto
* Data:		18/01/2005
********************************************************************/
Web Function PWSA077()
	Local cHtml := ""

	WEB EXTENDED INIT cHtml START "InSite"	
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
	
		If oObj:BrwInternalExp( cCodUser, HttpSession->cPartAcesso[1] )
			HttpSession->aItens := oObj:oWSBRWINTERNALEXPRESULT
			cHtml := ExecInPage( "PWSA074" )
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA076.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA078 - Inclui / Altera Experiencia Profissional de Mercado
*
* Autor:	Juliana Barros Mariano
* Data:		17/01/2005
********************************************************************/
Web Function PWSA078()
	Local cHtml := ""
	Local oHist := ""
	Local lInc	:= IIf( HttpGet->cInclusao == "S", lInc := .T., lInc:= .F. )
	
	WEB EXTENDED INIT cHtml START "InSite"	
		oHist := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oHist,"RHEmployedCurriculum.APW")
		
		oHist:oWSEXTERNALHISTORY:cRegistration	:= HttpPost->cMatr
		oHist:oWSEXTERNALHISTORY:dAdmissionDate	:= CToD(HttpPost->dAdmissao)
		oHist:oWSEXTERNALHISTORY:dDemissionDate	:= CToD(HttpPost->dDemissao)
		oHist:oWSEXTERNALHISTORY:cCompanyName 	:= HttpPost->cEmpresa
		oHist:oWSEXTERNALHISTORY:cPosition 		:= HttpPost->cCargo
		oHist:oWSEXTERNALHISTORY:cInitialPosition := HttpPost->cCargoIni
		oHist:oWSEXTERNALHISTORY:nHistoryId		:= IIf(!Empty(HttpPost->cCodHist),val(HttpPost->cCodHist),)
		oHist:oWSEXTERNALHISTORY:cDescription	:= HttpPost->txtDescr
	
		If oHist:PutExternalHistory(cCodUser, HttpSession->cParticipantID, lInc, oHist:oWSEXTERNALHISTORY)
			cHtml := W_PWSA074()
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA070.APW" }
	 		cHtml := ExecInPage("PWSAMSG")
		EndIf	
	WEB EXTENDED END
Return cHtml

/*******************************************************************
* Funcao: PWSA078a - Altera / Insere um registro no curriculo externo
*
* Autor:	Rogerio Augusto
* Data:		20/01/2005
********************************************************************/
Web Function PWSA078a()
	Local cHtml := ""
	Local Include := IIf( HttpPost->cAction == "true", lInc := .T., lInc:= .F. )
	Local lRet  := .F.
	
	WEB EXTENDED INIT cHtml START "InSite"	
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
		
		oObj:oWSExperienceItem := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHEMPLOYEDCURRICULUM_EXPERIENCES"), RHEMPLOYEDCURRICULUM_EXPERIENCES():New())
		oObj:oWSExperienceItem:nExpCod := val(HttpPost->cItem)
		oObj:oWSExperienceItem:cExpMat := HttpPost->cCodigo
		oObj:oWSExperienceItem:cExpDpt := HttpPost->area
		oObj:oWSExperienceItem:cExpFunction := HttpPost->cargo
		oObj:oWSExperienceItem:dExpIDate := cTod(HttpPost->datainicio)
		oObj:oWSExperienceItem:dExpFDate := cTod(HttpPost->datafim)
		oObj:oWSExperienceItem:cExpDetails := HttpPost->atividades
	
		lRet := oObj:PutInternalExp( cCodUser, Include, oObj:oWSExperienceItem,HttpSession->cParticipantID )
	
		If lRet
			HttpPost->cUserName := HttpPost->cUserName
			cHtml += W_PWSA077()
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA071.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf	
	WEB EXTENDED END	
Return cHtml

/*******************************************************************
* Funcao: PWSA078b - Altera / Insere um registro de filiacao a entidades
*
* Autor:	Rogerio Augusto
* Data:		01/02/2005
********************************************************************/
Web Function PWSA078b()
	Local cHtml := ""
	Local Include := IIf( HttpPost->cAction == "true", lInc := .T., lInc:= .F. )
	
	WEB EXTENDED INIT cHtml START "InSite"	
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
		
		oObj:oWSUserClassList := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHEMPLOYEDCURRICULUM_USERCLASSLIST"), RHEMPLOYEDCURRICULUM_USERCLASSLIST():New())
		oObj:oWSUserClassList:cESPECCODE := HttpPost->classe
		oObj:oWSUserClassList:cREGNUMBER := HttpPost->numReg
		oObj:oWSUserClassList:cREGDESCRIPTION	:= HttpPost->descEspec
		oObj:oWSUserClassList:cOTHERDESCRIPTION	:= HttpPost->cCursoDesc
	
		If oObj:PutEntData( cCodUser, Include, HttpSession->cPartAcesso[1], val(HttpPost->cRecno), oObj:oWSUserClassList )
			cHtml += W_PWSA071b()
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA071.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END
Return cHtml

/*******************************************************************
* Funcao: PWSA079 - Excluir Historico de Profissional
*
* Autor:	Juliana Barros Mariano
* Data:		18/01/2005
********************************************************************/
Web Function PWSA079()
	Local cHtml := ""
	Local oHist := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oHist := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oHist,"RHEmployedCurriculum.APW")
	
		If oHist:DELEXTERNALHISTORY( cCodUser, val(HttpGet->cCodHist) )
			cHtml := W_PWSA074()
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA070.APW" }
	 		cHtml := ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END	
Return cHtml


/*******************************************************************
* Funcao: PWSA080 - Visualiza descricao de qualificacoes
* Autor:	Juliana Barros
* Data:		25/02/2005
********************************************************************/
Web Function PWSA080()
	Local cHtml := ""
	Local oCurriculo := ""
	
	WEB EXTENDED INIT cHtml START "InSite"	
		oCurriculo := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oCurriculo,"RHEmployedCurriculum.APW")
	
		If oCurriculo:GetQualify( cCodUser, HttpSession->cPartAcesso[1] )
			HttpPost->aQualify := {oCurriculo:oWSGETQUALIFYRESULT}
			cHtml += ExecInPage("PWSA077")
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA076.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA081 - Inclui descricao de qualificacoes
* Autor:	Juliana Barros
* Data:		25/02/2005
********************************************************************/
Web Function PWSA081()
	Local cHtml := ""
	Local oCurriculo := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oCurriculo := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oCurriculo,"RHEmployedCurriculum.APW")
		
		If oCurriculo:PutQualify( cCodUser, HttpSession->cParticipantID, HttpPost->cQualif )
			HttpSession->_HTMLERRO := { STR0002, STR0003, "W_PWSA076.APW" } //"Inclusão / Alteração" ### "Atualização efetuada com sucesso."
	 		Return ExecInPage("PWSAMSG")
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA080.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao:	PWSA082 - Capacitacao de Mercado
* Autor:	Juliana
* Data:		07/2005
********************************************************************/
Web Function PWSA082()
	Local cHtml := ""
	Local cCodigo := ""
	Local cTitulo := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oObj  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
		
		If !empty( HttpPost->cCodigo )
			cCodigo := HttpPost->cCodigo
			cTitulo := HttpPost->cTitulo
		Else
			cCodigo := HttpGet->cCodigo
			cTitulo := HttpGet->cTitulo
		EndIf
	
		If oObj:BrwItemData( cCodUser, cCodigo, HttpSession->cPartAcesso[1] )
			HttpSession->aItens := oObj:oWSBRWITEMDATARESULT
			HttpPost->cTitulo := cTitulo
			HttpPost->cCodigo := cCodigo
			cHtml += ExecInPage( "PWSA080" )
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA076.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END
Return cHtml

/*******************************************************************
* Funcao: PWSA082 - Capacitacao de Microsiga
* Autor:	Juliana
* Data:
********************************************************************/
Web Function PWSA083()
	Local cHtml := ""
	Local cCodigo := ""
	Local cTitulo := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oObj  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
		
		If !empty( HttpPost->cCodigo )
			cCodigo := HttpPost->cCodigo
			cTitulo := HttpPost->cTitulo
		Else
			cCodigo := HttpGet->cCodigo
			cTitulo := HttpGet->cTitulo
		EndIf
	
		If oObj:BrwItemData( cCodUser, cCodigo, HttpSession->cPartAcesso[1] )
			HttpSession->aItens := oObj:oWSBRWITEMDATARESULT
			HttpPost->cTitulo := cTitulo
			HttpPost->cCodigo := cCodigo
			cHtml += ExecInPage( "PWSA079" )
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA076.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf
	
	WEB EXTENDED END
	
Return cHtml




/*******************************************************************
* Funcao: PWSA084 - Idiomas
* Autor:	Juliana Barros
* Data:		06.07.2005
********************************************************************/
Web Function PWSA084()
	Local cHtml := ""
	Local cCodigo := ""
	Local cTitulo := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oObj  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())		
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
		
		If !empty( HttpPost->cCodigo )
			cCodigo := HttpPost->cCodigo
			cTitulo := HttpPost->cTitulo
		Else
			cCodigo := HttpGet->cCodigo
			cTitulo := HttpGet->cTitulo
		EndIf
		
	
		If oObj:BrwItemData( cCodUser, cCodigo, HttpSession->cPartAcesso[1] )
			HttpSession->aItens := oObj:oWSBRWITEMDATARESULT
			HttpPost->cTitulo := cTitulo
			HttpPost->cCodigo := cCodigo
			cHtml += ExecInPage( "PWSA078" )
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA076.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END
Return cHtml




/*******************************************************************
* Funcao: PWSA085 - Comentarios adicionais
* Autor:	Juliana Barros
* Data:		12.07.2005
********************************************************************/
Web Function PWSA085()
	Local cHtml := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oCurriculo  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oCurriculo,"RHEmployedCurriculum.APW")
		
		If oCurriculo:GetComent( cCodUser, HttpSession->cPartAcesso[1] )
			HttpPost->aComent := {oCurriculo:oWSGETCOMENTRESULT}
			cHtml += ExecInPage("PWSA081")
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA076.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA085A - Comentarios adicionais - gravacao
* Autor:	Juliana Barros
* Data:		12.07.2005
********************************************************************/
Web Function PWSA085A()
	Local cHtml := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oCurriculo  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oCurriculo,"RHEmployedCurriculum.APW")
	
		If oCurriculo:PutComent( cCodUser, HttpSession->cParticipantID, HttpPost->cComent )
			HttpSession->_HTMLERRO := { STR0002, STR0003, "W_PWSA076.APW" } //"Inclusão / Alteração" ### "Atualização efetuada com sucesso."
	 		Return ExecInPage("PWSAMSG")
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA085.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA086 - Capacitacao Microsiga
* Autor:	Juliana Barros
* Data:		12.07.2005
********************************************************************/
Web Function PWSA086()
	Local cHtml := ""
	Local cCodigo := ""
	Local cTitulo := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oObj  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())		
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
		
		If !empty( HttpPost->cCodigo )
			cCodigo := HttpPost->cCodigo
			cTitulo := HttpPost->cTitulo
		Else
			cCodigo := HttpGet->cCodigo
			cTitulo := HttpGet->cTitulo
		EndIf
	
		If oObj:BrwLearning( cCodUser, cCodigo, HttpSession->cPartAcesso[1] )
			HttpSession->aItens := oObj:oWSBRWLEARNINGRESULT
			HttpPost->cTitulo := cTitulo
			HttpPost->cCodigo := cCodigo
			cHtml += ExecInPage( "PWSA082" )
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA076.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA086a - INCLUI CAPACITACAO INTERNA - RA4
*
* Autor:	Juliana Barros
* Data:		12/07/2005
********************************************************************/
Web Function PWSA086A()
	Local cHtml := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oObj  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())		
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
		
		oObj:oWSCourseList := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHEmployedCurriculum_CourseList"), RHEmployedCurriculum_CourseList():New())
		oObj:oWSCourseList:cCourseCod		:= HttpPost->curso
		oObj:oWSCourseList:cCourseName		:= HttpPost->cCursoDesc
		oObj:oWSCourseList:cCourseEnt		:= HttpPost->instituicao

		If !Empty(HttpPost->datafim)
			oObj:oWSCourseList:dCourseCDate	:= ctod(HttpPost->datafim)
		EndIf

		If !Empty(HttpPost->datainicio)
			oObj:oWSCourseList:dCourseIDate	:= ctod(HttpPost->datainicio)
		EndIf

		oObj:oWSCourseList:cCourseType		:= HttpPost->tipo
		oObj:oWSCourseList:cCourseStatus	:= HttpPost->cstatus

		If !Empty(HttpPost->cDuracao)
			oObj:oWSCourseList:nCourseTime	:= val(AllTrim(strTran(HttpPost->cDuracao,":",".")))
		EndIf

		oObj:oWSCourseList:cCourseDesc		:= HttpPost->cDescricao
		oObj:oWSCourseList:lCourseInclude	:= IIf(HttpPost->cInclusao == "1",.T., .F.)
		oObj:oWSCourseList:nRegRecno		:= val(HttpPost->cRecno)
	
		If oObj:PutLearning( cCodUser, HttpSession->cParticipantID, oObj:oWSCourseList )
			cHtml := W_PWSA086()
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA086.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA086B - Deleta um registro da tabela de cursos internos
*
* Autor:	Juliana Barros
* Data:		12/07/2005
********************************************************************/
Web Function PWSA086B()
	Local cHtml := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oObj  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())		
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
	
		If oObj:DelLearning( cCodUser, val(HttpPost->cRecno) )
			cHtml := W_PWSA086()
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA086.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA087 - Consulta Certificacoes de mercado
*
* Autor:	Juliana Barros
* Data:		13/07/2005
********************************************************************/
Web Function PWSA087()
	Local cHtml := ""
	Local cCodigo := ""
	Local cTitulo := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oObj  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())		
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
		
		If !empty( HttpPost->cCodigo )
			cCodigo := HttpPost->cCodigo
			cTitulo := HttpPost->cTitulo
		Else
			cCodigo := HttpGet->cCodigo
			cTitulo := HttpGet->cTitulo
		EndIf
	
		If oObj:BrwCertification( cCodUser, cCodigo, HttpSession->cPartAcesso[1] )
			HttpSession->aItens := oObj:oWSBRWCERTIFICATIONRESULT
			HttpPost->cTitulo := cTitulo
			HttpPost->cCodigo := cCodigo
			cHtml += ExecInPage( "PWSA083" )
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA076.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA087a - INCLUI CERTIFICACAO DE MERCADO SQ9
*
* Autor:	Juliana Barros
* Data:		13/07/2005
********************************************************************/
Web Function PWSA087A()
	Local cHtml := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oObj  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())		
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
		
		oObj:oWSCourseList := Iif(FindFunction("GetAuthWs"), GetAuthWs("RHEmployedCurriculum_CourseList"), RHEmployedCurriculum_CourseList():New())
		oObj:oWSCourseList:cCourseCod		:= HttpPost->curso
		oObj:oWSCourseList:cCourseName		:= HttpPost->cCursoDesc
		oObj:oWSCourseList:cCourseEnt		:= HttpPost->instituicao
		
		If !Empty(HttpPost->datafim)
			oObj:oWSCourseList:dCourseCDate	:= ctod(HttpPost->datafim)
		EndIf
		
		If !Empty(HttpPost->datainicio)
			oObj:oWSCourseList:dCourseIDate	:= ctod(HttpPost->datainicio)
		EndIf
		
		oObj:oWSCourseList:cCourseType		:= HttpPost->tipo
		oObj:oWSCourseList:lCourseInclude	:= IIf(HttpPost->cInclusao == "1",.T., .F.)
		oObj:oWSCourseList:nRegRecno		:= val(HttpPost->cRecno)	
		oObj:oWSCourseList:cOtherEnt		:= HttpPost->cInstDesc
		oObj:oWSCourseList:cOtherCert		:= HttpPost->cCertDesc
	
		If oObj:PutCertification( cCodUser, HttpSession->cParticipantID, oObj:oWSCourseList )
			cHtml := W_PWSA087()
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA087.APW" }
	 		Return ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA088 - Consulta Certificacoes profissionais - HCM
* Autor:	Juliana Barros
* Data:		23/08/2005
********************************************************************/
/*
Web Function PWSA088()

Local cHtml := ""
Local oObj	:= ""
Local cCodigo := ""
Local cTitulo := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
WsChgURL(@oObj,"RHEmployedCurriculum.APW")

If !empty( HttpPost->cCodigo )
	cCodigo := HttpPost->cCodigo
	cTitulo := HttpPost->cTitulo
Else
	cCodigo := HttpGet->cCodigo
	cTitulo := HttpGet->cTitulo
EndIf


	If oObj:BrwHCM( cCodUser, HttpSession->cPartAcesso[1] )
		HttpPost->aHCM := oObj:oWSBRWHCMRESULT:oWSHCMLIST

		HttpPost->cTitulo := cTitulo
		HttpPost->cCodigo := cCodigo
		cHtml += ExecInPage( "PWSA075" )
	Else
		HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA076.APW" }
 		Return ExecInPage("PWSAMSG")
	EndIf

WEB EXTENDED END

Return cHtml
*/


/*******************************************************************
* Funcao: PWSAOutros - Telas Criados pelo usuario
* Autor:	Juliana Barros
* Data:		19/09/2005
********************************************************************/
Web Function PWSAOutros()
	Local cHtml := ""
	Local oObj	:= ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oObj  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())		
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
	
		If oObj:UserMenu( cCodUser, HttpGet->cTitulo )
			If !Empty(oObj:cUSERMENURESULT)
				cHtml := &(oObj:cUSERMENURESULT)
			Else
				HttpSession->_HTMLERRO := { STR0007, STR0005, "W_PWSA076.APW" }	//"Aviso""Pagina nao encontrada"
	 			cHtml := ExecInPage("PWSAMSG")
			EndIf
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA076.APW" }
	 		cHtml := ExecInPage("PWSAMSG")
		EndIf
	WEB EXTENDED END
Return cHtml


/*************************************************************/
/* Autor...: Emerson Grassi Rocha     		  Data: 17/01/06 */
/* Objetivo: Pop Up para selecionar o Mentor              	 */
/*************************************************************/
Web Function PWSA089()
	Local cHtml := ""
	Local cNome := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oObj  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())		
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
		
		if empty(HttpPost->cNome)
			cNome := ""
		else
			cNome := HttpPost->cNome
		endif
		
		If oObj:brwMentors( cCodUser, cNome )
			httpPost->aMentores 	:= 	oObj:oWSBRWMENTORSRESULT:OWSMENTORS
			cHtml := H_PWSAvCurPop()
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA070.APW" }
		 	Return ExecInPage("PWSAMSG" )
		EndIf
	WEB EXTENDED END
Return cHtml


/*************************************************************/
/* Autor...: Emerson Grassi Rocha     		  Data: 17/01/06 */
/* Objetivo: Alterar o avaliador     				         */
/*************************************************************/
Web Function PWSA089A()
	Local cHtml := ""
	
	WEB EXTENDED INIT cHtml START "InSite"
		oObj  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oObj,"RHEmployedCurriculum.APW")
		
		If oObj:PutMentor( cCodUser, HttpSession->cParticipantId, HttpGet->cMentor )
			HttpSession->MentorName	:= HttpGet->cNomeMentor
			HttpSession->MentorId	:= HttpGet->cMentor
		
			HttpGet->cCodMentor := HttpGet->cMentor
			
			cHtml := "<script>alert('" + STR0006 + "!');</script>" //"Mentor alterado com sucesso"
			cHtml += W_PWSA076()
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA070.APW" }
			Return ExecInPage("PWSAMSG" )
		EndIf	
	WEB EXTENDED END
Return cHtml
