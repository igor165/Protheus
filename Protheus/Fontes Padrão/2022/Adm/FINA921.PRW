#Include 'Protheus.ch'
#Include "FwSchedule.ch"
#Include "FINA921.ch"

Static __lAPixTpd	:= .F.
Static __lSchedul	:= .F.

/*/{Protheus.doc} FINA921()
Cria Wizard de Configuração para acesso ao Pagamentos Digitais.

@author 	TOTVS SA
@since  	16/07/2021
@version 	12.1.33
/*/
Function FINA921()
	Local aArea   			As Array
	Local cMay    			As Character
	Local cEmpFVR 			As Character
	Local cUniFVR 			As Character
	Local cFilFVR 			As Character
	Local cEmpFV3 			As Character
	Local cUniFV3 			As Character
	Local cFilFV3 			As Character

	Local aSM0Data      	As Array
	Local aEmp 				As Array
	Local nPosCGC       	As Numeric
	Local nEmp 				As Numeric

	Private cCnpjFil    	As Character
	Private cFilJob     	As Char
	Private oFont1			As Object
	Private oFont2			As Object

	oFont1 := TFont():New("Arial",,-18,,.F.)
	oFont2 := TFont():New("Arial",,-15,,.F.)

	cEmpFVR := FWMODEACCESS("FVR",1)
	cUniFVR := FWMODEACCESS("FVR",2)
	cFilFVR := FWMODEACCESS("FVR",3)
	cEmpFV3 := FWMODEACCESS("FV3",1)
	cUniFV3 := FWMODEACCESS("FV3",2)
	cFilFV3 := FWMODEACCESS("FV3",3)

	cMay := "FINA921"

	Default lAutomato := .F.
	Default lOpt	  := .T.

	If cPaisLoc != "BRA"
		Help(" ",1,"F921BRA",, "Rotina indisponível." , 1 , 1,,,,,,{ "Rotina disponível apenas para ambiente BRASIL." })
		Return
	EndIf

	//Verifica o compartilhamento das tabelas FVR e FV3 são iguais e compartilhado..
	If ((cEmpFVR == "E") .Or. (cUniFVR == "E") .Or. (cFilFVR == "E")) .Or. ((cEmpFV3 == "E") .Or. (cUniFV3 == "E") .Or. (cFilFV3 == "E"))
		MsgStop( STR0048, STR0049 )
		Return(.F.)
	EndIf

	If !MayIUseCode(cMay)
		MsgStop(STR0050, STR0051)
		Return(.F.)
	EndIf

	If !AliasIndic('FIF') .or. !AliasIndic('FVR') .or. !AliasIndic('FV3')
		Help(" ", 1, "F921NaoTab",, STR0052, 1, 0,,,,,,{ STR0053 })
		Return
	EndIf

	cMsgErro := ""
	aEmp := FwLoadSm0()
	For nEmp:= 1 to Len(aEmp)
		If  aEmp[nEmp][1] == cEmpAnt
			cFilJob := aEmp[nEmp][2]
			exit
		EndIf
	Next

	// VALIDAÇÃO DA FILIAL
	aSM0Data := FwSM0Util():GetSM0Data(cEmpAnt, cFilAnt, {"M0_CGC", "M0_NOME"})
	nPosCGC  := aScan(aSM0Data, { |x| x[1] == "M0_CGC" })

	If nPosCGC > 0
		cCnpjFil := aSM0Data[nPosCGC,2]
	EndIf

	If Empty(cCnpjFil)
		Help(" ",1,"HELP",, STR0061 , 1 , 1,,,,,,{ STR0054 })
		Return
	EndIf

	aArea := GetArea()

	FINA921Wiz()

	RestArea( aArea )

	FwFreeArray(aEmp)
	FwFreeArray(aSM0Data)

Return

//--------------------------------------------------------------------------
/*{Protheus.doc} FINA921Wiz()
Montagem do wizard para comunicação com API

@author 	TOTVS SA
@since  	16/07/2021
@version 	12.1.33
*/
//--------------------------------------------------------------------------
Function FINA921Wiz()
	Local oStepWiz 			As Object
	Local o1stPage 			As Object
	Local o2ndPage 			As Object
	Local o3rdPage 			As Object
	Local o4thPage 			As Object

	Private oRecHub			As Object
	Private cPDUrlRAC		As Character
	Private cPDUser			As Character
	Private cPDPss			As Character
	Private cPDTenant		As Character
	Private cExtBusId		As Character
	Private lVldConn		As Logical

	If FindFunction("F918AtuTPD") 
		__lAPixTpd := F918AtuTPD() //Valida se o ambiente está atualizado
	Endif

	If __lAPixTpd
		// Carrega inicalizador padrão das variáveis do TOTVS PAGAMENTOS DIGITAIS
		oRecHub := FINReceiveHubTPD():New()

		cPDUrlRAC   := oRecHub:cUrlRAC
		cPDUser     := PADR(oRecHub:cUserName,50)
		cPDPss      := PADR(oRecHub:cPassword,50)
		cPDTenant   := PADR(oRecHub:cTenant,50)
		cExtBusId   := PADR(oRecHub:cCodeComp,50)	

		// Montagem do Wizard
		oStepWiz := FWWizardControl():New(, { 600, 850 }) //Instancia a classe FWWizardControl
		oStepWiz:ActiveUISteps()

		// Pagina 1 (Informações gerais sobre a rotina)
		o1stPage := oStepWiz:AddStep("1STSTEP", { |Panel| Step1(Panel) }) 	// Adiciona um Step (pagina)
		o1stPage:SetStepDescription(OemToAnsi(STR0003)) 			   		// "Informações"
		o1stPage:SetNextTitle(OemToAnsi(STR0005)) 					   		// "Avançar"
		o1stPage:SetNextAction({||.T. }) 							   		// Define o bloco ao clicar no botão "Avançar"
		o1stPage:SetCancelAction({|| .T. }) 							    // Define o bloco ao clicar no botão "Cancelar"

		// Pagina 2 (Credenciais Tenant)
		o2ndPage := oStepWiz:AddStep("2NDSTEP", { |Panel| Step2(Panel) }) 	// Adiciona um Step (pagina)
		o2ndPage:SetStepDescription(STR0004) 								// "Credenciais Tenant"
		o2ndPage:SetNextTitle(STR0005) 						            	// "Avançar"
		o2ndPage:SetPrevTitle(STR0006) 						            	// "Retornar"
		o2ndPage:SetNextAction({|| VldStep2() }) 							// Valida os dados do usuário
		o2ndPage:SetPrevAction({|| .T. }) 									// Define o bloco ao clicar no botão "Retornar"
		o2ndPage:SetCancelAction({|| .T. }) 								// Define o bloco ao clicar no botão "Cancelar"

		// Pagina 3 (Agendamento)
		o3rdPage := oStepWiz:AddStep("3RDSTEP", { | Panel | Step3(Panel) }) // Adiciona um Step (pagina)
		o3rdPage:SetStepDescription(OemToAnsi(STR0009))                 	// "Agendamento (Schedule)"
		o3rdPage:SetNextTitle(OemToAnsi(STR0005))                       	// "Avançar"
		o3rdPage:SetPrevTitle(OemToAnsi(STR0006))                       	// "Retornar"
		o3rdPage:SetNextAction({ || VldStep3() })                			// Define o bloco para "Avançar"
		o3rdPage:SetPrevWhen({|| !lVldConn })                            	// Define o bloco para "Retornar"
		o3rdPage:SetCancelAction({|| .T.})                              	// Define o bloco ao clicar no botão "Cancelar"

		// Pagina 4 (Encerramento Processo)
		o4thPage := oStepWiz:AddStep("4THSTEP", { |Panel| Step4(Panel) })  	// Adiciona um Step (pagina)
		o4thPage:SetStepDescription(OemToAnsi(STR0010))                		// Titulo do step: "Encerramento Processo"
		o4thPage:SetNextTitle(OemToAnsi(STR0011))                       	// "Concluir"
		o4thPage:SetPrevTitle(OemToAnsi(STR0006))                       	// "Retornar"
		o4thPage:SetNextAction({||.T. })                                	// Define o bloco ao clicar no botão "Concluir"
		o4thPage:SetPrevAction({|| .F. })                               	// Define o bloco ao clicar no botão "Retornar"
		o4thPage:SetCancelAction({|| .F. })                              	// Define o bloco ao clicar no botão "Cancelar"

		oStepWiz:Activate()

		FreeObj(oStepWiz)
	Else
		Help(" ", 1, "Dicionário",, STR0055, 1, 0,,,,,,{ STR0056 })
	EndIf

Return Nil

/*/{Protheus.doc} Step1
Função para construção da primeira página do wizard

@author 	TOTVS SA
@since  	16/07/2021
@version 	12.1.33
@param 		oPanel
/*/
Static Function Step1(oPanel as Object) 

	TSay():New(015,085,{|| OemToAnsi(STR0012) },oPanel,,oFont1,,,,.T.,CLR_BLUE,)
	TSay():New(030,110,{|| OemToAnsi(STR0013) },oPanel,,oFont1,,,,.T.,CLR_BLUE,)
	TSay():New(055,030,{|| OemToAnsi(STR0014) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)
	TSay():New(080,050,{|| OemToAnsi(STR0015) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)
	TSay():New(095,050,{|| OemToAnsi(STR0016) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)
	TSay():New(110,050,{|| OemToAnsi(STR0017) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)
	TSay():New(135,030,{|| OemToAnsi(STR0018) },oPanel,,oFont2,,,,.T.,CLR_BLUE,) 

	TSay():New(170,080,{|| OemToAnsi(STR0057) },oPanel,,oFont1,,,,.T.,CLR_RED,) 
	TSay():New(185,120,{|| OemToAnsi(STR0058) },oPanel,,oFont1,,,,.T.,CLR_RED,) 

Return

/*/{Protheus.doc} Step2
Função para construção da segunda página do wizard:
Informa os dados de tenant, usuário e senha.

@author 	TOTVS SA
@since  	16/07/2021
@version 	12.1.33
@param 		oPanel
/*/
Static Function Step2(oPanel As Object) As Logical
	Local lRet 		As Logical

	lRet := .T.	

	TSay():New(025,25,{|| STR0019 },oPanel,,oFont1,,,,.T.,CLR_BLUE,)
	TSay():New(045,30,{|| STR0020 },oPanel,,oFont2,,,,.T.,CLR_BLUE,)

	// Dados de acesso:

	// Tenant
	TSay():New(060,30,{|| STR0021 },oPanel,,oFont2,,,,.T.,CLR_BLUE,)
	TGet():New(070,30,{ |u| If(PCount() > 0, cPDTenant := u, cPDTenant) } ,oPanel,296,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cPDTenant)

	// Usuario
	TSay():New(090,30,{|| STR0022 },oPanel,,oFont2,,,,.T.,CLR_BLUE,)
	TGet():New(100,30,{ |u| If(PCount() > 0, cPDUser := u, cPDUser) } ,oPanel,296,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cPDUser)

	// Senha
	TSay():New(120,30,{|| STR0023 },oPanel,,oFont2,,,,.T.,CLR_BLUE,)
	TGet():New(130,30,{ |u| If(PCount() > 0, cPDPss := u, cPDPss) } ,oPanel,296,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.T.,,cPDPss)

	// Código Externo da Unidade de Negócio
	TSay():New(150,30, {|| STR0059 },oPanel,,oFont2,,,,.T.,CLR_BLUE)
	TGet():New(160,30, { |u| If(PCount() > 0, cExtBusId := u, cExtBusId) },oPanel,296,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cExtBusId)

Return lRet

/*/{Protheus.doc} VldStep2
Valida se é possivel fazer a comunucação/autenticação com a TPD com base nos dados informados

@author 	TOTVS SA
@since  	16/07/2021
@version 	12.1.33
/*/
Static Function VldStep2() As Logical
	Local lRet As Logical

	lRet := .T.

	If Empty(cPDTenant)
		Aviso(STR0024, STR0025, {STR0028}, 3)
		lRet := .F.
	EndIf

	If lRet .And. Empty(cPDUser)
		Aviso(STR0024, STR0026, {STR0028}, 3)
		lRet := .F.
	EndIf

	If lRet .And. Empty(cPDPss)
		Aviso(STR0024, STR0027, {STR0028}, 3)
		lRet := .F.
	EndIf

	If lRet .And. Empty(cExtBusId)
		Aviso(STR0024, STR0060, {STR0028}, 3)
		lRet := .F.
	EndIf

	If lRet
		// Faz a gravação dos dados de acesso
		oRecHub:cCodeComp 	:= ALLTRIM(cExtBusId)
		oRecHub:cTenant 	:= ALLTRIM(cPDTenant)
		oRecHub:cUserName 	:= ALLTRIM(cPDUser)
		oRecHub:cPassword 	:= ALLTRIM(cPDPss)
		oRecHub:SaveParam()

		If !(lRet := oRecHub:ValidConn()) 
			MsgStop(STR0040 + Chr(13) + Chr(13) + STR0043 + Alltrim(oRecHub:cURLRAC) + '<b>' + Chr(13) + STR0044 + '<b>' + AllTrim(cPDTenant) + '<b>', STR0029) 
		EndIf

		lVldConn := lRet	

	EndIf

Return lRet

/*/{Protheus.doc} Step3
Criação dos agendamentos

@author 	TOTVS SA
@since  	16/07/2021
@version 	12.1.33
@param 		oPanel
/*/
Static Function Step3(oPanel As Object)
	Local cRotina  as Character

	cRotina := "FINA914a('" + cEmpAnt + cFilAnt + "')"

	__lSchedul := !Empty(FwSchdByFunction(cRotina))

	TSay():New(025,25,{|| STR0009},oPanel,,oFont1,,,,.T.,CLR_BLUE,)

	If !__lSchedul
		TSay():New(050,030,{|| STR0033 },oPanel,,oFont2,,,,.T.,CLR_RED,)  //"Foi identificado que o agendamento ainda não foi criado."	
		TSay():New(070,030,{|| STR0034 },oPanel,,oFont2,,,,.T.,CLR_BLUE,) //"Clique no botão 'Avançar' para criar o agendamento (schedule) automaticamente."
		TSay():New(090,030,{|| STR0035 },oPanel,,oFont2,,,,.T.,CLR_BLUE,) //"Obs: O agendamento é criado por padrão com a periodicidade de 1 vez ao dia, no horario 05:00h."	
		TSay():New(110,030,{|| STR0036 },oPanel,,oFont2,,,,.T.,CLR_BLUE,) //"Para consultar ou editar, acesse a rotina 'Schedule' selecionando o agendamento 'FINA914a'."	
		TSay():New(130,030,{|| STR0046 },oPanel,,oFont2,,,,.T.,CLR_BLUE,) //"Para maiores informações sobre o agendamento, consulte a documentação do link abaixo:"	

		oSay := TSay():New(150,030,{|| "<u>" + STR0047 + "</u>" },oPanel,,oFont2,,,,.T.,CLR_BLUE,,,,,,,,,.T.) //Link do TDN a respeito da configuraçaõ do schedule
		oSay:bLClicked := {|| ShellExecute("open",STR0047,"","",1) } //Habilita o clique sobre o link para abrir no navegador		
	Else
		TSay():New(048,30,{|| STR0037 },oPanel,,oFont2,,,,.T.,CLR_BLUE,) //"Foi identificado que o agendamento já está cadastrado na rotina 'Schedule'."	
		TSay():New(071,30,{|| STR0046 },oPanel,,oFont2,,,,.T.,CLR_BLUE,) //"Para maiores informações sobre o agendamento, consulte a documentação do link abaixo:"		
		oSay := TSay():New(094,30,{|| "<u>" + STR0047 + "</u>" },oPanel,,oFont2,,,,.T.,CLR_BLUE,,,,,,,,,.T.) //Link do TDN a respeito da configuraçaõ do schedule
		oSay:bLClicked := {|| ShellExecute("open",STR0047,"","",1) }
	EndIf

Return Nil

/*/{Protheus.doc} VldStep3
Cria o agendamento (schedule) caso ainda não exista

@author 	TOTVS SA
@since  	16/07/2021
@version 	12.1.027
/*/
Static Function VldStep3() As Logical
	Local lRet    		As Logical
	Local cAgend  		As Char
	Local cPeriod 		As Char

	lRet := .T.

	//Somente cria o agendamento do schedule caso o mesmo ainda não exista
	If !__lSchedul

		cPeriod := "D(Each(.T.);Day(1);EveryDay(.T.););Execs(0001);Interval(00:00);"

		//Cria o agendamento (schedule)
		//(cFunction, cUserID, cParam, cPeriod, cTime, cEnv, cEmpFil, cStatus, dDate, nModule, aParamDef)
		cAgend := FwInsSchedule("FINA914a('" + cEmpAnt + cFilAnt + "')", STR0062,, cPeriod, STR0063, Upper(GetEnvServer()), cEmpAnt + "/" + cFilAnt + ";", SCHD_ACTIVE, Date(), 6, { cEmpAnt, cFilAnt })

		//"Não foi possível criar automaticamente o agendamento de integração com o PIX. Realize o agendamento da rotina FINA914a manualmente através do Schedule."
		IIf(Empty(cAgend), Aviso(STR0024, STR0039, {STR0028}, 3), .T.)

	EndIf

Return lRet

/*/{Protheus.doc} Step4
Encerramento do processo

@author 	TOTVS SA
@since  	16/07/2021
@version 	12.1.33
@param 		oPanel
/*/
Static Function Step4(oPanel As Object)

	Local lRet     As Logical

	lRet := .T.

	TSay():New(025,25,{|| STR0032 },oPanel,,oFont1,,,,.T.,CLR_BLUE,)

Return lRet
