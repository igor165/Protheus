#Include 'TOTVS.ch'
#Include "FwSchedule.ch"
#Include "FINA231.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA231()
Rotina para constru��o do wizard para configura��o do TOTVS CONNECT 
BANk

@author Edson Borges de Melo
@since  24/09/2020
@version 12.1.027
/*/
//-------------------------------------------------------------------
Function FINA231()

	Local oConfig       As Object
	Local oConfigS      As Object
	Local aSM0Data      As Array
	Local nPosCGC       As Numeric
	Local nPosNam       As Numeric
	Local cNomeCli	    As Char
	Local cChave        As Char
	
	Private cTCBUrl		As Character
	Private cTCBCPF		As Character
	Private cTCBPass	As Character

    Private oStepWiz	As Object
    Private oFont1		As Object
	Private oFont2		As Object
	Private cCnpjFil    As Character
	Private lVldConn    As Logical
	
	cCnpjFil    := ""
	cNomeCli    := ""
	cTCBUrl		:= ""
	cTCBCPF		:= ""
	cTCBPass	:= ""
	cChave      := Strtran(cEmpAnt," ","_") + "|" + Strtran(cFilAnt," ","_")
	nPosCGC     := 0
	nPosNam     := 0
	lVldConn    := .F.
    oFont1		:= TFont():New("Arial",,-18,,.F.,,,,,)
	oFont2		:= TFont():New("Arial",,-15,,.F.,,,,,)
	
	// VALIDA��O DA FILIAL
	aSM0Data := FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {"M0_CGC", "M0_NOME"} ) 
	nPosCGC  := aScan(aSM0Data, {|x| x[1] == "M0_CGC"})
	nPosNam  := aScan(aSM0Data, {|x| x[1] == "M0_NOME"})
	
	If nPosCGC > 0
		cCnpjFil := aSM0Data[nPosCGC,2]
	EndIf
	
	If nPosNam > 0
		cNomeCli := RTrim(aSM0Data[nPosNam,2])
	EndIf
	
	If cEmpAnt == "T1" .and. cNomeCli == "Grupo TOTVS 1"
		cCnpjFil := "53113791000122"
	EndIf
	
	If Empty(cCnpjFil)
		Help(" ",1,"HELP",,STR0001, 1 , 1 )
		Return
	EndIf
	
	//Carrega inicalizador padr�o das vari�veis do TCB
	oConfig := FWTFConfig()
	
	//Defini��o da URL
	cTCBUrl := oConfig["fin_url_TCB"]
	
	If Valtype(oConfig["fin_url_TCB"]) == "U"
		cTCBUrl := Padr("https://prd-tcb.tfs.totvs.com/", 100)
	EndIf
	
	//Defini��o do usu�rio
	cTCBCPF := oConfig[ "fin_cpfTCB_" + cChave ]
	If Valtype(oConfig[ "fin_cpfTCB_" + cChave ] ) == "U"
		cTCBCPF := PadR('', 11)
	EndIf
	
	//Defini��o da senha
	cTCBPass := oConfig[ "fin_pwdTCB_" + cChave ]
	If Valtype(oConfig[ "fin_pwdTCB_" + cChave ] ) == "U"
		cTCBPass := PadR('', 50)
	EndIf
	
	oConfigS := JsonObject():New()
	oConfigS[ "fin_url_TCB" ]  := Alltrim(cTCBUrl)
	oConfigS[ "fin_cpfTCB_" + cChave ]  := Alltrim(cTCBCPF)
	oConfigS[ "fin_pwdTCB_" + cChave ] := Alltrim(cTCBPass)
	FwTFSetConfig( oConfigS )

	cTCBUrl := Padr(cTCBUrl,100)
	cTCBCPF := PadR(cTCBCPF, 11)
	cTCBPass := PadR(cTCBPass, 50)
	
	// Montagem do Wizard 
    oStepWiz := FWWizardControl():New(,{600,850})//Instancia a classe FWWizardControl
    oStepWiz:ActiveUISteps()
	
	//----------------------
	// Pagina 1
	//----------------------
	o1stPage := oStepWiz:AddStep("1STSTEP",{|Panel| step1(Panel)}) // Adiciona um Step
	o1stPage:SetStepDescription(OemToAnsi(STR0002))  // "Informa��es" 
	o1stPage:SetNextTitle(OemToAnsi(STR0003)) // Define o t�tulo do bot�o de avan�o -- "Avan�ar"
	o1stPage:SetNextAction({||.T.}) // Define o bloco ao clicar no bot�o Pr�ximo
	o1stPage:SetCancelAction({|| .T.}) // Define o bloco ao clicar no bot�o Cancelar

	//----------------------
	// Pagina 2
	//----------------------
	o2ndPage := oStepWiz:AddStep("2NDSTEP", {|Panel| step2(Panel)})
	o2ndPage:SetStepDescription(OemToAnsi(STR0004))   // "Credenciais"
	o2ndPage:SetNextTitle(OemToAnsi(STR0003)) // "Avan�ar"  
	o2ndPage:SetPrevTitle(OemToAnsi(STR0005)) // Define o t�tulo do bot�o para retorno -- "Retornar" 
	o2ndPage:SetNextAction({|| VldStep2()})
	o2ndPage:SetPrevAction({|| .T.}) // Define o bloco ao clicar no bot�o Voltar
	o2ndPage:SetCancelAction({|| .T.}) // Define o bloco ao clicar no bot�o Cancelar

	//----------------------
	// Pagina 3
	//----------------------
	o3rdPage := oStepWiz:AddStep("3RDSTEP", {|Panel| step3(Panel)})
	o3rdPage:SetStepDescription(OemToAnsi(STR0006))   // "Valida��o de conex�o"
	o3rdPage:SetNextTitle(OemToAnsi(STR0003))   // "Avan�ar" 
	o3rdPage:SetPrevTitle(OemToAnsi(STR0005))  // "Retornar" 
	o3rdPage:SetNextAction({|| .T.})
	o3rdPage:SetPrevWhen({|| !lVldConn })
	o3rdPage:SetCancelAction({|| .T. })

	//----------------------
	// Pagina 4
	//----------------------
	o4rdPage := oStepWiz:AddStep("4RDSTEP", {|Panel| step4(Panel)})
	o4rdPage:SetStepDescription(OemToAnsi(STR0007))   // "Cria��o dos JOBs" 
	o4rdPage:SetNextTitle(OemToAnsi(STR0003))   // "Avan�ar" 
	o4rdPage:SetPrevTitle(OemToAnsi(STR0005))   // "Retornar"
	o4rdPage:SetNextAction({|| .T. }) 
	o4rdPage:SetPrevWhen({|| !lVldConn })
	o4rdPage:SetCancelAction({|| .T. })

	//----------------------
	// Pagina 5
	//----------------------
	o5rdPage := oStepWiz:AddStep("5RDSTEP", {|Panel|step5(Panel)})
	o5rdPage:SetStepDescription(OemToAnsi(STR0008))    // "Encerramento Processo"
	o5rdPage:SetNextTitle(OemToAnsi(STR0009))   // "Concluir" 
	o5rdPage:SetPrevTitle(OemToAnsi(STR0005))	// "Retornar" 
	o5rdPage:SetNextAction({|| .T. })
	o5rdPage:SetPrevAction({|| .F. })
	o5rdPage:SetCancelAction({|| .T. })

    oStepWiz:Activate()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} step1
Fun��o para constru��o da primeira p�gina do wizard

@param oPanel

@author Francisco Oliveira
@since  10/07/2017
@version 12.1.019
/*/
//-------------------------------------------------------------------
Static Function step1(oPanel as Object)

	TSay():New(010,25,{|| OemToAnsi(STR0010) },oPanel,,oFont1,,,,.T.,CLR_BLUE,)  // "Configura��o de conex�o com o TOTVS CONNECT BANK (TCB)." 
	TSay():New(025,30,{|| OemToAnsi(STR0011) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)  // "Clique em 'Avan�ar' para:"
	TSay():New(065,30,{|| OemToAnsi(STR0012) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)  // "- Defini��o do usu�rio e senha."
	TSay():New(085,30,{|| OemToAnsi(STR0013) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)  // "- Valida��o de conex�o com o TCB."
	TSay():New(105,30,{|| OemToAnsi(STR0014) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)  // "- Configura��o dos agendamentos de monitoramento e processamento de arquivos de retorno."
	TSay():New(125,30,{|| OemToAnsi(STR0015) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)  // "Ao final do processo, o ambiente estar� apto a realizar o envio autom�tico de border�s ao TCB."

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} step2
Fun��o para constru��o da segunda p�gina do wizard
Valida��o de usu�rio e senha

@param oPanel

@author Edson Melo
@since  25/09/2020
@version 12.1.027
/*/
//-------------------------------------------------------------------
Static Function step2(oPanel As Object) As Logical

	Local lRet     As Logical
	lRet := .T.
	
	TSay():New(025,25,{|| OemToAnsi(STR0016) },oPanel,,oFont1,,,,.T.,CLR_BLUE,)  // "Credenciais de conex�o" 
	TSay():New(038,30,{|| OemToAnsi(STR0017) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)  // "Informe as credenciais de conex�o do TOTVS CONNECT BANK" 

	TSay():New(051,30,{|| OemToAnsi(STR0018) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)  // "CNPJ" 
	TGet():New(064,30,{|u| if( PCount() > 0, cCnpjFil := u, cCnpjFil ) } ,oPanel,296,009,"@R 99.999.999/9999-99",,0,,,.F.,,.T.,,.F.,{|u|.F.},.F.,.F.,,.F.,.F.,,cCnpjFil,,,, )

	TSay():New(084,30,{|| OemToAnsi(STR0019) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)  // "CPF" 
	TGet():New(097,30,{|u| if( PCount() > 0, cTCBCpf := u, cTCBCpf ) } ,oPanel,296,009,"@R 999.999.999-99",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTCBCpf,,,, )

	TSay():New(117,30,{|| OemToAnsi(STR0020) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)  // "Senha" 
	TGet():New(130,30,{|u| if( PCount() > 0, cTCBPass := u, cTCBPass ) } ,oPanel,296,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.T.,,cTCBPass,,,, )


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldStep2

Valida se cliente poder� continuar com o processo
@author Edson Melo
@since  24/09/2020
@version 12.1.027
/*/
//-------------------------------------------------------------------
Static Function VldStep2() As Logical

	Local lRet	As Logical
	Local oConfigs As Object
	Local cChave As Char

	cChave := Strtran(cEmpAnt," ","_") + "|" + Strtran(cFilAnt," ","_")
	lRet	:= .T.

	If Empty(cTCBCpf)
		Aviso(OemToAnsi(STR0021), OemToAnsi(STR0022), {STR0025}, 3)  // "Aten��o"  "Informar o CPF para conex�o com o TCB." "Ok"
		lRet := .F.
	Endif
	
	If lRet .And. Empty(cTCBPass)
		Aviso(OemToAnsi(STR0021), OemToAnsi(STR0023), {STR0025}, 3)  // "Aten��o"  "Informar a senha para conex�o com o TCB." "Ok"
		lRet := .F.
	EndIf
	
	If lRet
		oConfigS := JsonObject():New()
		oConfigS[ "fin_cpfTCB_" + cChave ] := cTCBCpf
		oConfigS[ "fin_pwdTCB_" + cChave ] := cTCBPass
		FwTFSetConfig( oConfigS )

		oTCBConn := TCBConnect():New()
		oTCBConn:ValidConn()
		lRet := oTCBConn:lConnected
	EndIf

	If !lRet
		Aviso(OemToAnsi(STR0021), OemToAnsi(STR0024 + oTCBConn:cMessageError), {STR0025}, 3)  // "Aten��o" "Conex�o n�o estabelecida. Revise os dados digitados: " "Ok"
	Endif
	
	FreeObj(oTCBConn)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} step3

Fun��o para constru��o da terceira p�gina do wizard. usu�rio informa
o endere�o de conex�o com o TCB.

@param oPanel

@author Edson Melo
@since  24/09/2020
@version 12.1.027
/*/
//-------------------------------------------------------------------
Static Function step3(oPanel As Object)

	Local lRet     As Logical
	lRet := .T.
	
	TSay():New(015,16,{|| OemToAnsi(STR0026) },oPanel,,oFont1,,,,.T.,CLR_BLUE,)  // "Validando conex�o" 
		
	TSay():New(030,25,{|| OemToAnsi(STR0027) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)  // "Conex�o estabelecida com sucesso." 
	TSay():New(045,25,{|| OemToAnsi(STR0028+cTCBUrl) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)  // "URL: " 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} step4
Valida��o da conex�o

@param oPanel

@author Edson Melo
@since  24/09/2020
@version 12.1.027
/*/
//-------------------------------------------------------------------
Static Function step4(oPanel As Object)

	Local cAgend  As Char
	Local cPeriod As Char
	Local cMsgErro As Char

	cMsgErro := ""

	TSay():New(025,25,{|| OemToAnsi(STR0029) },oPanel,,oFont1,,,,.T.,CLR_BLUE,)   // "Cria��o dos agendamentos"
	
	// Schedule para baixar os retornos do TCB
	cAgend := FwSchdByFunction("FINI230O('"+cEmpAnt+"','"+cFilAnt+"')")
	//Somente cria o agendamento do schedule caso o mesmo ainda n�o exista
	If Empty(cAgend)
		//Executa a cada 10 minutos
		cPeriod := "D(Each(.T.);Day(1);EveryDay(.F.););Execs(0144);Interval(00:10);"
		//(cFunction, cUserID, cParam, cPeriod, cTime, cEnv, cEmpFil, cStatus, dDate, nModule, aParamDef)
		cAgend := FwInsSchedule("FINI230O('"+cEmpAnt+"','"+cFilAnt+"')", "000000",, cPeriod, "00:00", Upper(GetEnvServer()), cEmpAnt + "/" + cFilAnt + ";",;
			SCHD_ACTIVE, Date(), 6, {cEmpAnt, cFilAnt})
		If Empty(cAgend)
			cMsgErro := STR0030   // "N�o foi poss�vel criar automaticamente o JOB de integra��o com o TCB."
		EndIf
	EndIf

	// Schedule para baixar os retornos do TCB
	cAgend := FwSchdByFunction("FINA435('"+cEmpAnt+"','"+cFilAnt+"')")
	//Somente cria o agendamento do schedule caso o mesmo ainda n�o exista
	If Empty(cAgend)
		//Executa a cada 10 minutos
		cPeriod := "D(Each(.T.);Day(1);EveryDay(.F.););Execs(0144);Interval(00:10);"
		//(cFunction, cUserID, cParam, cPeriod, cTime, cEnv, cEmpFil, cStatus, dDate, nModule, aParamDef)
		cAgend := FwInsSchedule("FINA435('"+cEmpAnt+"','"+cFilAnt+"')", "000000",, cPeriod, "00:00", Upper(GetEnvServer()), cEmpAnt + "/" + cFilAnt + ";",;
			SCHD_ACTIVE, Date(), 6, {cEmpAnt, cFilAnt})
		If Empty(cAgend)
			cMsgErro := STR0031  // "N�o foi poss�vel criar automaticamente o JOB de processamento de retorno de CNAB."
		EndIf
	EndIf
	
	If !Empty(cMsgErro)
		TSay():New(048,30,{|| OemToAnsi(cMsgErro) },oPanel,,oFont2,,,,.T.,CLR_RED,) 
	Else
		TSay():New(048,30,{|| OemToAnsi(STR0032) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)  // "Agendamentos criados com sucesso." 
		TSay():New(071,30,{|| OemToAnsi(STR0033) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)  // "1) FINI230O: Respons�vel pela c�pia dos arquivos de retorno do TCB."
		TSay():New(094,30,{|| OemToAnsi(STR0034) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)  // "2) FINA435:  Respons�vel pelo processamento dos arquivos recepcionados da plataforma TCB "
		TSay():New(109,30,{|| OemToAnsi(STR0035) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)  // "             no ERP Protheus. Este job est� configurado para ser executado a cada 10 minutos,"
		TSay():New(124,30,{|| OemToAnsi(STR0036) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)  // "             podendo ser alterado. Favor conferir as configura��es do schedule. "
	EndIf

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} step4
Valida��o da conex�o

@param oPanel

@author Edson Melo
@since  24/09/2020
@version 12.1.027
/*/
//-------------------------------------------------------------------
Static Function step5(oPanel As Object)

	Local lRet     As Logical
	lRet := .T.
	
	TSay():New(025,25,{|| OemToAnsi(STR0037) },oPanel,,oFont1,,,,.T.,CLR_BLUE,)  // "Conex�o com o TOTVS CONNECT BANK configurada e validada com sucesso." 

Return lRet

