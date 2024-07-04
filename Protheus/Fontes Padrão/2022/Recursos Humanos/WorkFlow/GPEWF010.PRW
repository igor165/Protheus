#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEWF010.CH"

#DEFINE cCodUser "MSALPHA"

Function WFProgFerias(nOpcao,oProcess, cFilFun, cMatFun, cCodProg)
	DEFAULT nOpcao := 0
                                                                                
	Do case         
		//Inclusão da Programacao de Ferias ou
		//Aprovação ou Reprovação da Programação de Férias via Portal
		Case nOpcao == 0 .or. nOpcao == 1 .or. nOpcao == 3
			WFPFInicio(cFilFun, cMatFun, cCodProg) 
			      
		//Aprovação ou Reprovação da Programação de Férias via e-mail
		Case nOpcao == 4
			WFPFRetorno(oProcess, nOpcao)                       	
			
		//Timeout
		Case nOpcao == 5
			WFPFRetorno(oProcess, nOpcao)
	EndCase		
Return

Function WFPFInicio(cFilFun, cMatFun, cCodProg)
	Local cCodProcesso     := "PROGFER" 
	Local cAssunto         := OemToAnsi(STR0001)	// Assunto da mensagem
	Local cHtmlModelo      := ""					// Arquivo html template utilizado para montagem da aprovação
	Local cMailID          := ""
	Local cNomeFun         := ""
	Local cFilApr 		   := ""
	Local cMatApr 		   := ""
	Local cNomeAPr		   := ""
	local cURL			   := "http://"
	local cWFID 		   := NIL
	Local oProgFer		   := {}
	Local aFunc			   := {}
	Local nPos			   := 0
	Local nDias 		   := GetMV("MV_DIASAPR",,3)
	Local oFunc
	Local oWSProgFerias
           
	oProgFer:= fGetVacationProg(cFilFun, cMatFun, .F.)
	
	nPos := aScan(oProgFer:ListOfPeriod, {|x| x:CodVacationProg == cCodProg})
	                                                            
	If oProgFer:ListOfPeriod[nPos]:IDStatusProg == "3"
		Return
	EndIf
	
	If !Empty( oProgFer:ListOfPeriod[nPos]:WFID )
 		cWFID := oProgFer:ListOfPeriod[nPos]:WFID
	EndIf

	oProcess := TWFProcess():New(cCodProcesso, cAssunto, cWFID )
		
	//Html Modelo de Programação de férias
	cHtmlModelo := "\workflow\wfprogferias.html"

	// Crie uma tarefa.
	oProcess:NewTask(cAssunto, cHtmlModelo)  

	//conout("(INICIO|PROGFERIAS) " + OemToAnsi(STR0012) + oProcess:fProcessID + " - Task: " + oProcess:fTaskID )

	// Assinale novos valores às macros existentes no html:
	oProcess:oHtml:ValByName("cFilFun"    , cFilFun  )
	oProcess:oHtml:ValByName("cMatFun"    , cMatFun  )
	oProcess:oHtml:ValByName("cCodProg"   , cCodProg )
	oProcess:oHtml:ValByName("cTitulo"    , OemToAnsi(STR0001) )
	oProcess:oHtml:ValByName("cTitNome"   , OemToAnsi(STR0002) )
	oProcess:oHtml:ValByName("cTitDtAdm"  , OemToAnsi(STR0003) )
	oProcess:oHtml:ValByName("cTitDep"    , OemToAnsi(STR0004) )
	oProcess:oHtml:ValByName("cTitDtIni"  , OemToAnsi(STR0005) )
	oProcess:oHtml:ValByName("cTitDtFim"  , OemToAnsi(STR0006) )
	oProcess:oHtml:ValByName("cTitDias"   , OemToAnsi(STR0007) )
	oProcess:oHtml:ValByName("cTitAprov"  , OemToAnsi(STR0008) )
	oProcess:oHtml:ValByName("cTitSim"    , OemToAnsi(STR0009) )
	oProcess:oHtml:ValByName("cTitNao"    , OemToAnsi(STR0010) )
	oProcess:oHtml:ValByName("cTitEnviar" , OemToAnsi(STR0011) )
	oProcess:oHtml:ValByName("cAprovValid", OemToAnsi(STR0020) ) 
	oProcess:oHtml:ValByName("cDtIniValid", OemToAnsi(STR0021) ) 
	                                            
	//Buscar dados do Funcionário                                                   
	oFunc := WSORGSTRUCTURE():New()
	WsChgURL(@oFunc, "ORGSTRUCTURE.APW", NIL, .F.)
	
	oFunc:cEmployeeFil:= cFilFun
	oFunc:cRegistration:= cMatFun
	
	If oFunc:GetEmployee()
		If !Empty(oFunc:oWSGetEmployeeRESULT)
			aFunc := oFunc:oWSGetEmployeeRESULT
			oProcess:oHtml:ValByName("cNome"        , aFunc:oWSDataEmployee[1]:cName)
			cNomeFun := aFunc:oWSDataEmployee[1]:cName
			oProcess:oHtml:ValByName("cDataAdm"     , aFunc:oWSDataEmployee[1]:cAdmissionDate)
			oProcess:oHtml:ValByName("cDepartamento", aFunc:oWSDataEmployee[1]:cDepartment )
		EndIf
	EndIf    

	If Valtype(aFunc) == "U"
		oProcess:oHtml:ValByName("cNome"        , "")
		oProcess:oHtml:ValByName("cDataAdm"     , "")
		oProcess:oHtml:ValByName("cDepartamento", "")
	EndIf

	oProcess:oHtml:ValByName("cDtIni"  , oProgFer:ListOfPeriod[nPos]:InitialDate  )
	oProcess:oHtml:ValByName("cDias"   , oProgFer:ListOfPeriod[nPos]:Days  )
	oProcess:oHtml:ValByName("cDtFim"  , oProgFer:ListOfPeriod[nPos]:FinalDate  )
	cFilApr := oProgFer:ListOfPeriod[nPos]:AprovFil
	cMatApr := oProgFer:ListOfPeriod[nPos]:AprovMat
	oProcess:oHtml:ValByName("cFilAprov", cFilApr)
	oProcess:oHtml:ValByName("cMatAprov", cMatApr)
 
	// Repasse o texto do assunto criado para a propriedade especifica do processo.
	oProcess:cSubject := cAssunto

	// Função de retorno a ser executada quando a mensagem de respostas retornarem ao Workflow
	oProcess:bReturn := "WFProgFerias(4)"

	// Função do tipo timeout que será executada se houver um timeout ocorrido para esse processo. 
	oProcess:bTimeOut := {{"WFProgFerias(5)", nDias, 0, 0}}

	oProcess:cTo := "progfer"
	
	//Verifica se utiliza Arquitetura Organizacional
	cURL += alltrim( GetMV( "MV_WFBRWSR" ) )
	if WFGetMV( "MV_WFWEBEX", .F. )
		cURL += "/w_wfhttpret.apw?ProcID="
		cURL += oProcess:cTo + "/"
	else
		cURL += "/messenger/emp" + cEmpAnt + "/"
		cURL += oProcess:cTo + "/"
	end
	
	cMailID := oProcess:Start()
	
	oWFData:= WsClassNew("DataWorkFlow")
	oWFData:ListOfWorkFlow := {WsClassNew("FieldsWorkFlow"), WsClassNew("FieldsWorkFlow")}
	oWFData:ListOfWorkFlow[1]:FieldWF:= "RGJ_WFID"
	oWFData:ListOfWorkFlow[1]:ValueField:= oProcess:fProcessID + oProcess:fTaskID
	oWFData:ListOfWorkFlow[2]:FieldWF:= "RGJ_IDENT"
	oWFData:ListOfWorkFlow[2]:ValueField:= cMailID
	
	fPutIDWFVacProg(cFilFun, cMatFun, cCodProg, oWFData)
	
 	cURL += cMailID + ".htm"

	cHtmlModelo := "\workflow\wflink.htm"

	oProcess:NewTask(cAssunto, cHtmlModelo)  

	// Repasse o texto do assunto criado para a propriedade especifica do processo.
	oProcess:cSubject := cAssunto

	// Informe o endereço eletrônico do destinatário - Aprovador
	aFunc := NIL
	oFunc := WSORGSTRUCTURE():New()
	WsChgURL(@oFunc,"ORGSTRUCTURE.APW",,.F.)

	oFunc:cEmployeeFil:= cFilApr
	oFunc:cRegistration:= cMatApr
	
	If oFunc:GetEmployee()
		If !Empty(oFunc:oWSGetEmployeeRESULT)
			aFunc := oFunc:oWSGetEmployeeRESULT
			cNomeAPr := aFunc:oWSDataEmployee[1]:cName
			cEmail   := aFunc:oWSDataEmployee[1]:cEmail
		EndIf
	EndIf
	
	If Valtype(aFunc) == "U"
		cNomeAPr := ""
		cEmail   := ""
	EndIf
	
	oProcess:cTo := cEmail
	oProcess:ohtml:ValByName("usuario"  , OemToAnsi(STR0017) + cNomeAPr)  
	
	If (cFilFun + cMatFun) == (cFilApr + cMatApr)
		oProcess:ohtml:ValByName("cTexto"   , OemToAnsi(STR0019) + OemToAnsi(STR0014))
	Else
		oProcess:ohtml:ValByName("cTexto"   , OemToAnsi(STR0013) + cNomeFun + ". " + OemToAnsi(STR0014))
	EndIf
	
	oProcess:ohtml:ValByName("proc_link", cURL )
	oProcess:ohtml:ValByName("cTitProc" , OemToAnsi(STR0015))
	oProcess:ohtml:ValByName("cTexto2"  , OemToAnsi(STR0016))
    
	// Apos ter repassado todas as informacoes necessarias para o workflow, solicite a
	// a ser executado o método Start() para se gerado todo processo e enviar a mensagem
	// ao destinatário.
	oProcess:Start()

	cCodProcesso   := NIL
	cAssunto       := NIL
	cHtmlModelo    := NIL
	cMailID        := NIL
	cNomeFun       := NIL
	cFilApr 	   := NIL
	cMatApr 	   := NIL
	cNomeAPr	   := NIL
	cURL		   := NIL
	cWFID 		   := NIL
	oProgFer	   := NIL
	aFunc		   := NIL
	nPos		   := NIL
	nDias 		   := NIL
	oFunc          := NIL
	oWSProgFerias  := NIL
Return


Function WFPFRetorno(oProcess, nOpcao)
	Local aDados      := {}
	Local cFilFun     := ""
	Local cMatFun     := ""
	Local cCodProg    := ""
	Local cOpcApr     := ""
	Local cDtIni      := ""
	Local cDias       := ""
	Local cVisao      := "" 
	Local cFilApr	  := ""
	Local cMatApr     := ""
	Local nNivelAprov := 99
	Local aInfRotina  := {}
	Local oMenuGPE
	Local lReprSemSug := .T.

	// Obter as informações do html
	If nOpcao == 4 //Aprovação ou Reprovação da Programação de Férias via e-mail
		//conout("(" + OemToAnsi(STR0018) + ") " + OemToAnsi(STR0012) + oProcess:fProcessID + " - Task: " + oProcess:fTaskID )
		cFilFun  := oProcess:oHtml:RetByName("cFilFun")
		cMatFun  := oProcess:oHtml:RetByName("cMatFun")
		cCodProg := oProcess:oHtml:RetByName("cCodProg")
		cOpcApr  := oProcess:oHtml:RetByName("aprov")
		cDtIni   := oProcess:oHtml:RetByName("cSugDtIni")
		cDias    := oProcess:oHtml:RetByName("cSugDias")
		cFilApr	 := oProcess:oHtml:RetByName("cFilAprov")
		cMatApr  := oProcess:oHtml:RetByName("cMatAprov")
		
		lReprSemSug := (Empty(cDtIni) .and. Empty(cDias))
	Else //Timeout
		//conout("(" + OemToAnsi(STR0023) + ") " + OemToAnsi(STR0012) + oProcess:fProcessID + " - Task: " + oProcess:fTaskID )
		cFilFun  := oProcess:oHtml:ValByName("cFilFun")
		cMatFun  := oProcess:oHtml:ValByName("cMatFun")
		cCodProg := oProcess:oHtml:ValByName("cCodProg")
		cFilApr	 := oProcess:oHtml:ValByName("cFilAprov")
		cMatApr  := oProcess:oHtml:ValByName("cMatAprov")
		cOpcApr  := "S"
	EndIf

	oMenuGPE := WSMENU():New()
	WsChgURL(@oMenuGPE,"MENU.APW",,.F.)

	//Buscar os periodos abertos do funcionario
	If oMenuGPE:GetDadosMenu('000006','000120')
		If !Empty(oMenuGPE:oWSGETDadosMenuRESULT)
			aInfRotina := oMenuGPE:oWSGETDadosMenuRESULT
			cVisao      := aInfRotina:cVisao
			nNivelAprov := aInfRotina:nNivelAprov
		EndIf                                                        
	EndIF
	
	oFeriasProg := WSRHVACATION():New()
	WsChgURL(@oFeriasProg,"RHVACATION.APW",,.F.)
	
	//Buscar as programacoes de ferias do funcionario
	If oFeriasProg:GetVacationProg(cFilFun, cMatFun, .F.)
		If !Empty(oFeriasProg:oWSGETVACATIONPROGRESULT)
			aProgFer := oFeriasProg:oWSGETVACATIONPROGRESULT
		EndIf
	EndIf	
            
	nPos := aScan(aProgFer:oWSListOfPeriod:oWsPeriodVacationProg, {|x| x:cCodVacationProg == cCodProg})
	
	aAdd(aDados, If(cOpcApr == "S", "1", if(lReprSemSug,"5","3"))) 	//Acao
	aAdd(aDados, NIL)						   	//Programacoes de Ferias do funcionario
	aAdd(aDados, nNivelAprov)	   				//Quantidade de niveis de aprovacao, cadastrado no menu do portal
	aAdd(aDados, cFilFun)	   					//Filial do Funcionario
	aAdd(aDados, cMatFun)	   					//Matricula do Funcionario
	aAdd(aDados, cCodProg)	   					//Codigo da Programacao
	aAdd(aDados, aProgFer:oWSListOfPeriod:oWsPeriodVacationProg[nPos]:nInitialLevel)			//Nivel Solicitante
	aAdd(aDados, aProgFer:oWSListOfPeriod:oWsPeriodVacationProg[nPos]:cFilInitial)				//Filial Solicitante
	aAdd(aDados, aProgFer:oWSListOfPeriod:oWsPeriodVacationProg[nPos]:cMatInitial)				//Matricula Solicitante
	aAdd(aDados, aProgFer:oWSListOfPeriod:oWsPeriodVacationProg[nPos]:nAprovLevel)				//Nivel Aprovador
	aAdd(aDados, aProgFer:oWSListOfPeriod:oWsPeriodVacationProg[nPos]:cAprovFil)				//Filial Aprovador
	aAdd(aDados, aProgFer:oWSListOfPeriod:oWsPeriodVacationProg[nPos]:cAprovMat)				//Matricula Aprovador

	// Informe o endereço eletrônico do destinatário - Aprovador
	aFunc := NIL
	oFunc := WSORGSTRUCTURE():New()
	WsChgURL(@oFunc,"ORGSTRUCTURE.APW",,.F.)
	                     
	oFunc:cEmployeeFil:= aProgFer:oWSListOfPeriod:oWsPeriodVacationProg[nPos]:cAprovFil
	oFunc:cRegistration:= aProgFer:oWSListOfPeriod:oWsPeriodVacationProg[nPos]:cAprovMat
	oFunc:cVision:= cVisao
	
	If oFunc:GetEmployee()
		If !Empty(oFunc:oWSGetEmployeeRESULT)
			aFunc := oFunc:oWSGetEmployeeRESULT
			aAdd(aDados, aFunc:oWSDataEmployee[1]:cSupFilial)			//Filial Superior
			aAdd(aDados, aFunc:oWSDataEmployee[1]:cSupRegistration)		//Matricula Superior
			aAdd(aDados, aFunc:oWSDataEmployee[1]:nLevelSup)			//Nivel Superior
		EndIf
	EndIf    
	If Valtype(aFunc) == "U"
		aAdd(aDados, "")						//Filial Superior
		aAdd(aDados, "")						//Matricula Superior
		aAdd(aDados, 99)						//Nivel Superior
	EndIf

	If cOpcApr == "S" .or. (cOpcApr == "N" .and. lReprSemSug)
		aAdd(aDados, aProgFer:oWSListOfPeriod:oWsPeriodVacationProg[nPos]:cInitialDate)		//Data Inicial
		aAdd(aDados, aProgFer:oWSListOfPeriod:oWsPeriodVacationProg[nPos]:nDays)				//Dias
		aAdd(aDados, aProgFer:oWSListOfPeriod:oWsPeriodVacationProg[nPos]:cFinalDate) 		//Data Final
	ElseIf cOpcApr == "N"
		aAdd(aDados, cDtIni)					//Data Inicial
		aAdd(aDados, Val(cDias))				//Dias
		aAdd(aDados, "")						//Data Final   
	EndIf                
	aAdd(aDados, cFilApr) //Filial do aprovador atual
	aAdd(aDados, cMatApr) //Matricula do aprovador atual

	//fPutVacation(aDados,.F.)

	aDados      := NIL
	cFilFun     := NIL
	cMatFun     := NIL
	cCodProg    := NIL
	cOpcApr     := NIL
	cDtIni      := NIL
	cDias       := NIL
	cVisao      := NIL
	nNivelAprov := NIL
	aInfRotina  := NIL
	oMenuGPE    := NIL
	
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WFSolicPortal  ºAutor  ³Alexandre Takaki    º Data ³  01/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                		                           º±±
±±º          ³                                      		                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ANHANGUERA EDUCACIONAL                            		       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function WFSolicPortal(nOpcao, cCodSolic, oProcess, cFilFun, cStatus)
	Local cFilOld := ""

	DEFAULT nOpcao := 0
               
	//Conout("******* Workflow Solicitacao (Aprovacao / Reprovacao)") 
	//Conout("Opcao: " + str(nOpcao))
	Do case         
		//Aprovação ou Reprovação da Solicitação via Portal
		Case nOpcao == 1 .or. nOpcao == 3 .or. nOpcao == 4
		
			//atualizado cFilAnt, pois nos casos da tabela WF7 exclusiva necessita 
			//buscar o email da filial de origem e não da primeira filial do sigamat
			cFilOld := cFilAnt
			cFilAnt := cFilFun

			WFSPInicio(cCodSolic, nOpcao, cFilFun, cStatus) 

			cFilAnt := cFilOld

		//Timeout
		/*Case nOpcao == 5
			//Conout("Timeout")
			WFSPTimeOut(oProcess, nOpcao)*/
	EndCase
		
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WFSPInicio     ºAutor  ³Alexandre Takaki    º Data ³  01/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	                      										   º±±
±±º          ³     		              										   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ANHANGUERA EDUCACIONAL                            		       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function WFSPInicio(cCodSolic, nOpcao, cFilFun, cStatus)

Local oProcess	          
Local aSolicPortal	   := {}
Local aFunc			   := {}
Local cCodProcesso     := "SOLICP"
Local cAssunto         := OemToAnsi(STR0024)// Assunto da mensagem
Local cFilApr 		   := ""
Local cMatApr 		   := ""
Local cHtmlModelo      := ""				// Arquivo html template utilizado para montagem da solicitação
Local cNomeAPr		   := ""
Local cEmail           := ""
Local cTexto           := ""
Local cWFID 		   := NIL
Local cMailID          := ""
Local aRetorno         := {}
Local lPontoRH         := ExistBlock("PontoRH")
Local lTcfa040		   := IsIncallStack("TCFA040Atende") .Or. IsIncallStack("TCFA040Rejeita")
Local lApprove		   := IsIncallStack('ApproveRequest')
//cStatus 1=Em processo de aprovação;2=Atendida;3=Reprovada;4=Aguardando Efetivação do RH

//Buscar o funcionário que a solicitação está pendente.
aSolicPortal := fGetRequest(xFilial("RH3", cFilFun), cCodSolic)
If !Empty(aSolicPortal) 
	
	If aSolicPortal:Status:Code == "4" .And. !lPontoRH
		If lApprove //Aguardando efetivação RH somente quando for acessado pelo ERP
			Return 
		ElseIf !lTcfa040
			Return
		EndIf
	EndIf

	//Buscar o ID do workflow caso seja uma aprovação ou rejeição.
	If !Empty( aSolicPortal:WFID )
		cWFID := aSolicPortal:WFID
	EndIf                       

	If lPontoRH
		aRetorno := ExecBlock("PontoRH",.F.,.F.,{"1", cCodSolic, aSolicPortal:ApproverLevel, aSolicPortal:Source, aSolicPortal:Branch, aSolicPortal:RequestType:Code,aSolicPortal:Status:Code})
		If aRetorno[1]
			If Len(aRetorno) > 1
				cEmail   := aRetorno[2]
				cNomeAPr := aRetorno[3]
				cTexto   := aRetorno[4]
			Else
				lPontoRH := .F.
			EndIf
		Else
			Return
		EndIf
	endif

	//Html
	cHtmlModelo 	   := "\workflow\wfsolicportal.html" 
	If !File(cHtmlModelo)
		conout(OemToAnsi(STR0030))
		Return
	EndIf
																		
	//Se o cWFID não tiver informação, será criado um novo processo de WF. 
	//Se tiver informação, o método buscará o processo existente conforme o ID.                                                          
	oProcess := TWFProcess():New(cCodProcesso, cAssunto , cWFID )

	

	// Crie uma nova tarefa conforme html modelo.
	oProcess:NewTask(cAssunto, cHtmlModelo)  

	//conout("(INICIO) " + "Task: " + oProcess:fTaskID )
	
	// Repasse o texto do assunto criado para a propriedade especifica do processo.
	oProcess:cSubject := cAssunto

	// Função do tipo timeout que será executada se houver um timeout ocorrido para esse processo. 
	//oProcess:bTimeOut := {{"WFSolicPortal(5)", nDias, 0, 0}}
		
	if !lPontoRH
		//Verifica Filial e Matricula para envio WF na Aprovacao do RH.
		If (aSolicPortal:APPROVERLEVEL != 99)
			cFilApr      := aSolicPortal:APPROVERBRANCH
			cMatApr      := aSolicPortal:APPROVERREGISTRATION
		Else
			cFilApr		:= 	aSolicPortal:STARTERBRANCH
			cMatApr		:=  aSolicPortal:STARTERREGISTRATION
		EndIf	 

		// Informe o endereço eletrônico do destinatário - Aprovador
		aFunc := {}
		If fGetFunc(cFilApr, cMatApr, @aFunc)
			If Len(aFunc) > 0
				cNomeAPr := aFunc[1][3]
				cEmail   := aFunc[1][4]
			EndIf
		EndIf    
		If Valtype(aFunc) == "U"
			cNomeAPr := ""
			cEmail   := ""
		EndIf
	EndIf
	
	oProcess:cTo := cEmail

	// Assinale novos valores às macros existentes no html:
	oProcess:oHtml:ValByName("usuario", OemToAnsi(STR0017) + cNomeAPr )
																
	//Buscar o serviço
	If !lPontoRH
		If nOpcao == 4 .Or. cStatus == 	"3"
			cTexto := OemToAnsi(STR0025)//"Sua solicitação foi rejeitada. Para maiores informações, por favor, acesse o portal."
		Else          
			If (aSolicPortal:APPROVERLEVEL != 99)
				cTexto := OemToAnsi(STR0026)//"Existem solicitações para serem aprovadas. Por favor, acesse o portal."
			Else
				cTexto := OemToAnsi(STR0029)//"Sua solicitação foi Aprovada. Para maiores informações, por favor, acesse o portal."		
			EndIf
		EndIf
	EndIf
	oProcess:ohtml:ValByName("cTexto", cTexto )
	
	oProcess:ohtml:ValByName("cTpSolic", OemToAnsi(STR0027) + aSolicPortal:REQUESTTYPE:DESCRIPTION )
	oProcess:ohtml:ValByName("cTexto1", OemToAnsi(STR0028))
	oProcess:ohtml:ValByName("cCodSolic", cCodSolic )

	// Apos ter repassado todas as informacoes necessarias para o workflow, solicite a
	// a ser executado o método Start() para se gerado todo processo e enviar a mensagem
	// ao destinatário.
	cMailID := oProcess:Start()
	
	//Grava ID do workflow
	PutIDWFRequest(cCodSolic, oProcess:fProcessID + oProcess:fTaskID, cMailID, cFilFun)
EndIf
										
cEmail         := NIL
cTexto         := NIL
cCodProcesso   := NIL
cAssunto       := NIL
cHtmlModelo    := NIL
cFilApr 	   := NIL
cMatApr 	   := NIL
cNomeAPr	   := NIL
cWFID 		   := NIL
cMailID        := NIL
aSolicPortal   := NIL
aFunc		   := NIL

Return

Function PutIDWFRequest(cSolic, cWFID, cIdent, cFilFun)

	dbSelectArea("RH3")
	RH3->( dbSetOrder(1) )

	If RH3->( dbSeek(xFilial("RH3", cFilFun) + cSolic ) )
		If RecLock("RH3",.F.)   
			RH3_WFID  := cWFID                                                             
			RH3_IDENT := cIdent
		EndIf
	EndIf
	
	RH3->( DbCloseArea() )
Return NIL

