#Include "TOTVS.ch"
#Include "FwSchedule.ch"
#Include "FINA893.ch"

/*/{Protheus.doc} FINA893()
Cria Wizard de Configuração para acesso ao Pagamentos Digitais.

@author Edson Melo
@since  09/02/2021
@version 12.1.027
/*/
Function FINA893()
	Local aSM0Data		As Array
	Local nPosCGC		As Numeric
	Local nTamAgenci	As Numeric
	Local nTamBanco		As Numeric
	Local nTamConta		As Numeric
	Local oConfig		As Object

	Private cAgenPIX	As Character
	Private cBancoPIX	As Character
	Private cBusId		As Character
	private cChaveConf	As Character
	private cChaveBCO	As Character
	Private cCNPJFil	As Character
	Private cContaPIX	As Character
	Private cExtBusId	As Character
	Private cFilJob		As Character
	Private cPDPss		As Character
	Private cPDUrl		As Character
	Private cPDUser		As Character
	Private cPDTenant	As Character
	Private cPosId		As Character

	Private lVldConn	As Logical

	Private oConfigS	As Object
	Private oFont1		As Object
	Private oFont2		As Object
	Private oPayHub		As Object
	Private oStepWiz	As Object

	If !(AliasInDic("F70")) .Or. !(AliasInDic("F71"))
		Help(" ", 1, "F893NaoTab",, STR0001, 1, 0,,,,,, {STR0002})
		Return
	EndIf

	cMsgErro	:= ""

	cFilJob := cFilAnt

	cCNPJFil	:= ""
	cPDUrl		:= ""
	cPDUser		:= ""
	cPDPss		:= ""
	cPDTenant	:= ""
	cPosId		:= ""
	cExtBusId	:= ""
	cChaveConf	:= cEmpAnt										//StrTran(cEmpAnt, " ", "_")
	cChaveBCO	:= cEmpAnt + "|" + AllTrim(FwXFilial("SA6")) 	//StrTran(cEmpAnt, " ", "_") + "|" + StrTran(FwXFilial("SA6"), " ", "_")
	nPosCGC		:= 0
	lVldConn	:= .F.
	oFont1		:= TFont():New("Arial",, -18,, .F.)
	oFont2		:= TFont():New("Arial",, -15,, .F.)
	nTamBanco	:= TamSX3("A6_COD")[1]
	nTamAgenci	:= TamSX3("A6_AGENCIA")[1]
	nTamConta	:= TamSX3("A6_NUMCON")[1]

	// VALIDAÇÃO DA FILIAL
	aSM0Data := FwSM0Util():GetSM0Data(cEmpAnt, cFilAnt, {"M0_CGC", "M0_NOME"})
	nPosCGC  := AScan(aSM0Data, {|x| x[1] == "M0_CGC"})

	If nPosCGC > 0
		cCNPJFil := aSM0Data[nPosCGC][2]
	EndIf

	If Empty(cCNPJFil)
		Help(" ", 1, "HELP",, STR0048, 1, 1,,,,,, {STR0049})
		Return
	EndIf

	// Carrega inicalizador padrão das variáveis do TOTVS PAGAMENTOS DIGITAIS
	oConfig := FwTFConfig()

	// Definição da URL
	If ValType(cPDUrl := oConfig["fin_url_PagamentosDigitais"]) == "U"
		cPDUrl := PadR("https://staging.raas.varejo.totvs.com.br/", 100)
	EndIf

	// Definição do Usuário
	If ValType(cPDUser := oConfig["fin_user_PagamentosDigitais_" + cChaveConf]) == "U"
		cPDUser := PadR("", 50)
	EndIf

	// Definição do Senha
	If ValType(cPDPss := oConfig["fin_password_PagamentosDigitais_" + cChaveConf]) == "U"
		cPDPss := PadR("", 50)
	EndIf

	// Definição do Tenant
	If ValType(cPDTenant := oConfig["fin_tenant_PagamentosDigitais_" + cChaveConf]) == "U"
		cPDTenant := PadR("", 50)
	EndIf

	// Definição do Caixa Virtual 
	If ValType(cPosId := oConfig["fin_idpos_PagamentosDigitais_" + cChaveConf]) == "U"
		cPosId := PadR("", 50)
	EndIf
	
	// Definição do Código Externo da Unidade de Negócio no PD
	If ValType(cExtBusId := oConfig["fin_extBusId_PagamentosDigitais_" + cChaveConf]) == "U"
		cExtBusId := PadR("", 50)
	EndIf

	// Definação do Código da Unidade de Negócio dentro do PD
	If ValType(cBusId := oConfig["fin_busId_PagamentosDigitais_" + cChaveConf]) == "U"
		cBusId := PadR("", 50)
	EndIf

	// Definição Banco TOTVS PIX
	If ValType(cBancoPIX := oConfig["fin_banco_PagamentosDigitais_" + cChaveBCO]) == "U"
		cBancoPIX := PadR("", nTamBanco)
	EndIf

	// Definição Agência TOTVS PIX
	If ValType(cAgenPIX := oConfig["fin_agencia_PagamentosDigitais_" + cChaveBCO]) == "U"
		cAgenPIX := PadR("", nTamAgenci)
	EndIf

	// Definição Conta TOTVS PIX
	If ValType(cContaPIX := oConfig["fin_conta_PagamentosDigitais_" + cChaveBCO]) == "U"
		cContaPIX := PadR("", nTamConta)
	EndIf

	oConfigS := JSONObject():New()

	cPDUrl		:= AllTrim(cPDUrl)
	cPDUser		:= PadR(cPDUser,	50)
	cPDPss		:= PadR(cPDPss,		50)
	cPDTenant	:= PadR(cPDTenant,	50)
	cPosId		:= PadR(cPosId,		50)
	cExtBusId	:= PadR(cExtBusId,	50)
	cBusId		:= PadR(cBusId,		50)

	If !(Empty(cBancoPIX))
		SA6->(DbSeek(FwXFilial("SA6") + cBancoPIX + cAgenPIX + cContaPIX))
	Else
		cBancoPIX	:= PadR(cBancoPIX,	nTamBanco)
		cAgenPIX	:= PadR(cAgenPIX,	nTamAgenci)
		cContaPIX	:= PadR(cContaPIX,	nTamConta)
	EndIf

	// Montagem do Wizard
	oStepWiz := FwWizardControl():New(,{600,850}) //Instancia a classe FwWizardControl
	oStepWiz:ActiveUISteps()

	// Pagina 1
	o1stPage := oStepWiz:AddStep("1STSTEP",{|Panel| Step1(Panel)}) // Adiciona um Step
	o1stPage:SetStepDescription(OemToAnsi(STR0003))
	o1stPage:SetNextTitle(OemToAnsi(STR0005)) // Define o título do botão de avanço -- STR0005
	o1stPage:SetNextAction({||.T.}) // Define o bloco ao clicar no botão Próximo
	o1stPage:SetCancelAction({|| .T.}) // Define o bloco ao clicar no botão Cancelar

	// Pagina 2
	o2ndPage := oStepWiz:AddStep("2NDSTEP", {|Panel| Step2(Panel)})
	o2ndPage:SetStepDescription(OemToAnsi(STR0004))
	o2ndPage:SetNextTitle(OemToAnsi(STR0005)) // --
	o2ndPage:SetPrevTitle(OemToAnsi(STR0006)) // Define o título do botão para retorno --
	o2ndPage:SetNextAction({|| VldStep2()})
	o2ndPage:SetPrevAction({|| .T.}) // Define o bloco ao clicar no botão Voltar
	o2ndPage:SetCancelAction({|| .T.}) // Define o bloco ao clicar no botão Cancelar

	// Pagina 3
	o3rdPage := oStepWiz:AddStep("3RDSTEP", {|Panel| Step3(Panel)})
	o3rdPage:SetStepDescription(OemToAnsi(STR0007))
	o3rdPage:SetNextTitle(OemToAnsi(STR0005))
	o3rdPage:SetPrevTitle(OemToAnsi(STR0006))
	o3rdPage:SetNextAction({|| .T.})
	o3rdPage:SetPrevWhen({|| !lVldConn})
	o3rdPage:SetCancelAction({|| .T.})

	// Pagina 4
	o4thPage := oStepWiz:AddStep("4THSTEP", {|Panel| Step4(Panel)})
	o4thPage:SetStepDescription(OemToAnsi(STR0008))
	o4thPage:SetNextTitle(OemToAnsi(STR0005))
	o4thPage:SetPrevTitle(OemToAnsi(STR0006))
	o4thPage:SetNextAction({|| VldStep4()})
	o4thPage:SetPrevWhen({|| !lVldConn})
	o4thPage:SetCancelAction({|| .T.})

	// Pagina 5
	o5thPage := oStepWiz:AddStep("5THSTEP", {|Panel| Step5(Panel)})
	o5thPage:SetStepDescription(OemToAnsi(STR0009))
	o5thPage:SetNextTitle(OemToAnsi(STR0005))
	o5thPage:SetPrevTitle(OemToAnsi(STR0006))
	o5thPage:SetNextAction({|| .T.})
	o5thPage:SetPrevWhen({|| .F.})
	o5thPage:SetCancelWhen({|| .F.})

	// Pagina 6
	o6thPage := oStepWiz:AddStep("6THSTEP", {|Panel| Step6(Panel)})
	o6thPage:SetStepDescription(OemToAnsi(STR0010))
	o6thPage:SetNextTitle(OemToAnsi(STR0011))
	o6thPage:SetPrevTitle(OemToAnsi(STR0006))
	o6thPage:SetNextAction({|| .T.})
	o6thPage:SetPrevWhen({|| .F.})
	o6thPage:SetCancelWhen({|| .F.})

	oStepWiz:Activate()

	FreeObj(oPayHub)
	FreeObj(oConfig)
	FreeObj(oConfigS)
	FreeObj(oStepWiz)
	FwFreeArray(aSM0Data)

Return Nil

/*/{Protheus.doc} Step1
Função para construção da primeira página do wizard

@author		Edson Melo
@since		09/02/2021
@version	12.1.027
@param		oPanel
/*/
Static Function Step1(oPanel As Object)

	TSay():New(010, 025,{|| OemToAnsi(STR0012)}, oPanel,, oFont1,,,, .T., CLR_BLUE)
	TSay():New(025, 030,{|| OemToAnsi(STR0013)}, oPanel,, oFont2,,,, .T., CLR_BLUE)
	TSay():New(065, 030,{|| OemToAnsi(STR0014)}, oPanel,, oFont2,,,, .T., CLR_BLUE)
	TSay():New(085, 030,{|| OemToAnsi(STR0015)}, oPanel,, oFont2,,,, .T., CLR_BLUE)
	TSay():New(105, 030,{|| OemToAnsi(STR0016)}, oPanel,, oFont2,,,, .T., CLR_BLUE)
	TSay():New(125, 030,{|| OemToAnsi(STR0017)}, oPanel,, oFont2,,,, .T., CLR_BLUE)

Return Nil

/*/{Protheus.doc} Step2
Função para construção da segunda página do wizard. Validação de usuário e senha.

@author		Edson Melo
@since		09/02/2021
@version	12.1.027
@param		oPanel
/*/
Static Function Step2(oPanel As Object)

	TSay():New(010, 025, {|| OemToAnsi(STR0018)}, oPanel,, oFont1,,,, .T., CLR_BLUE)
	TSay():New(025, 030, {|| OemToAnsi(STR0019)}, oPanel,, oFont2,,,, .T., CLR_BLUE)

	//Dados de acesso 
	TSay():New(041, 030, {|| OemToAnsi(STR0020)}, oPanel,, oFont2,,,, .T., CLR_BLUE)
	TGet():New(056, 030, {|u| If(PCount() > 0, cPDTenant := u, cPDTenant)},oPanel,296,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.f.,, cPDTenant)

	TSay():New(072, 030, {|| OemToAnsi(STR0021)}, oPanel,, oFont2,,,, .T., CLR_BLUE)
	TGet():New(087, 030, {|u| If(PCount() > 0, cPDUser := u, cPDUser)},oPanel,296,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.f.,, cPDUser)

	TSay():New(103, 030, {|| OemToAnsi(STR0022)}, oPanel,, oFont2,,,, .T., CLR_BLUE)
	TGet():New(118, 030, {|u| If(PCount() > 0, cPDPss := u, cPDPss)},oPanel,296,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.T.,, cPDPss)

	TSay():New(134, 030, {|| OemToAnsi(STR0056)}, oPanel,, oFont2,,,, .T., CLR_BLUE)
	TGet():New(149, 030, {|u| If(PCount() > 0, cExtBusId := u, cExtBusId)},oPanel,296,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.f.,, cExtBusId)

	TSay():New(165, 030, {|| OemToAnsi(STR0057)}, oPanel,, oFont2,,,, .T., CLR_BLUE)
	TGet():New(180, 030, {|u| If(PCount() > 0, cPosId := u, cPosId)},oPanel,296,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.f.,, cPosId)

Return Nil

/*/{Protheus.doc} VldStep2
Valida se cliente poderá continuar com o processo.

@author 	Edson Melo
@since  	09/02/2021
@version 	12.1.027
/*/
Static Function VldStep2() As Logical

	Local lRet	As Logical

	lRet	:= .T.

	If Empty(cPDTenant)
		Aviso(OemToAnsi(STR0023), OemToAnsi(STR0024), {STR0027}, 3)
		lRet := .F.
	ElseIf Empty(cPDUser)
		Aviso(OemToAnsi(STR0023), OemToAnsi(STR0025), {STR0027}, 3)
		lRet := .F.
	ElseIf lRet .And. Empty(cPDPss)
		Aviso(OemToAnsi(STR0023), OemToAnsi(STR0026), {STR0027}, 3)
		lRet := .F.
	ElseIf Empty(cPosId)
		Aviso(OemToAnsi(STR0023), OemToAnsi(STR0050), {STR0027}, 3)
		lRet := .F.
	ElseIf Empty(cExtBusId)
		Aviso(OemToAnsi(STR0023), OemToAnsi(STR0051), {STR0027}, 3)
		lRet := .F.
	EndIf

	If lRet
		oPayHub := PayHubPix():New(cExtBusId, cPosId, cPDTenant, cPDUser, cPDPss, "totvs_pagamento_digital_protheus_ro",, "BRL")
		
		If !(lRet := oPayHub:CheckIntegrity())
			Aviso(OemToAnsi(STR0023), OemToAnsi(oPayHub:cLastError), {STR0027}, 3)
		ElseIf !(lRet := oPayHub:ValidConn())
			Aviso(OemToAnsi(STR0023), OemToAnsi(STR0028 + oPayHub:cLastError), {STR0027}, 3)
		ElseIf !(lRet := oPayHub:ValidExternalBusinessUnitId(@cBusId))
			Aviso(OemToAnsi(STR0023), OemToAnsi(oPayHub:cLastError), {STR0027}, 3)
		ElseIf !(lRet := oPayHub:ValidPosId(cBusId))
			Aviso(OemToAnsi(STR0023), OemToAnsi(oPayHub:cLastError), {STR0027}, 3)
		EndIf
		lVldConn := lRet
	EndIf

Return lRet

/*/{Protheus.doc} Step3
Função para construção da terceira página do wizard. usuário informa o endereço de conexão com o pix.

@author 	Edson Melo
@since 	 	09/02/2021
@version 	12.1.027
@param 		oPanel
/*/
Static Function Step3(oPanel As Object)

	TSay():New(010, 025, {|| OemToAnsi(STR0029)},					oPanel,, oFont1,,,, .T., CLR_BLUE)
	TSay():New(025, 030, {|| OemToAnsi(STR0030)},					oPanel,, oFont2,,,, .T., CLR_BLUE)
	TSay():New(040, 030, {|| OemToAnsi(STR0031 + oPayHub:cURL)},	oPanel,, oFont2,,,, .T., CLR_BLUE)

Return Nil

/*/{Protheus.doc} Step4
Função para construção da quarta página do wizard. usuário informa o banco padrão para o PIX.

@author		Edson Melo
@since		09/02/2021
@version	12.1.027
@param		oPanel
/*/
Static Function Step4(oPanel As Object)
	Local oGetBco	As Object
	Local oGetAgen	As Object
	Local oGetConta	As Object

	TSay():New(025, 025, {|| OemToAnsi(STR0008)}, oPanel,, oFont1,,,, .T., CLR_BLUE)
	TSay():New(038, 030, {|| OemToAnsi(STR0032)}, oPanel,, oFont2,,,, .T., CLR_BLUE)
	TSay():New(051, 030, {|| OemToAnsi(STR0033)}, oPanel,, oFont2,,,, .T., CLR_BLUE)

	//Dados de acesso
	TSay():New(064,30,{|| OemToAnsi(STR0034)},oPanel,,oFont2,,,,.T.,CLR_BLUE)
	oGetBco := TGet():New(077,30,{|u| If(PCount() > 0, cBancoPIX := u, cBancoPIX)},oPanel,296,009,"@!", {|u| ValidBanco(1)},0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,, cBancoPIX)

	TSay():New(097,30,{|| OemToAnsi(STR0035)},oPanel,,oFont2,,,,.T.,CLR_BLUE)
	oGetAgen := TGet():New(110,30,{|u| If(PCount() > 0, cAgenPIX := u, cAgenPIX)},oPanel,296,009,"@!", {|u| ValidBanco(2)},0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,, cAgenPIX)

	TSay():New(130,30,{|| OemToAnsi(STR0037)},oPanel,,oFont2,,,,.T.,CLR_BLUE)
	oGetConta := TGet():New(143,30,{|u| If(PCount() > 0, cContaPIX := u, cContaPIX)},oPanel,296,009,"@!", {|u| ValidBanco(3)} ,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,, cContaPIX)

	oGetBco:bF3 := {|| ConPadSA6(@oGetBco, @oGetAgen, @oGetConta)}
Return Nil

/*/{Protheus.doc} ConPadSA6
Validação dos campos banco, agência e conta.

@author		Rafael Riego
@since		16/08/2021
@param		oGetBco, object, get referente ao código do banco
@param		oGetAgen, object, get referente a agência
@param		oGetConta, object, get referente ao número da conta
/*/
Static Function ConPadSA6(oGetBco As Object, oGetAgen As Object, oGetConta As Object)
	If ConPad1(,,, "SA6",,, .F.)
		cBancoPIX	:= SA6->A6_COD
		cAgenPIX	:= SA6->A6_AGENCIA
		cContaPIX	:= SA6->A6_NUMCON
		oGetBco:Refresh()
		oGetAgen:Refresh()
		oGetConta:Refresh()
	EndIf
Return Nil

/*/{Protheus.doc} ValidBanco
Validação dos campos banco, agência e conta.

@author 	Rafael Riego
@since  	16/08/2021
@param		nTipo, numeric, qual dado deve ser validado, sendo 1=Banco;2=Agência;3=Conta
@return 	logical, verdadeiro caso os dados informados sejam válidos
/*/
Static Function ValidBanco(nTipo As Numeric) As Logical
	Local lValido	As Logical

	Default nTipo	:= 0

	lValido := .T.

	If nTipo == 1 //Banco
		If Empty(cBancoPIX) 
			cAgenPIX	:= Space(TamSX3("A6_AGENCIA")[1])
			cContaPIX	:= Space(TamSX3("A6_NUMCON")[1])
		ElseIf !(ExistCpo("SA6", cBancoPIX))
			lValido := .F.
		EndIf
	ElseIf nTipo == 2 //Agencia
		If Empty(cAgenPIX)
			cContaPIX := Space(TamSX3("A6_NUMCON")[1])
		ElseIf !(ExistCpo("SA6", cBancoPIX + cAgenPIX))
			lValido := .F.
		EndIf
	ElseIf nTipo == 3 //Conta
		If !(Empty(cContaPIX)) .And. !(ExistCpo("SA6", cBancoPIX + cAgenPIX + cContaPIX))
			lValido := .F.
		EndIf
	EndIf

	//Validação completa da chave SA6
	If lValido .And. !(Empty(cBancoPIX)) .And. !(Empty(cAgenPIX)) .And. !(Empty(cContaPIX))
		If !(ExistCpo("SA6", cBancoPIX + cAgenPIX + cContaPIX))
			lValido := .F.
		EndIf
	EndIf

Return lValido

/*/{Protheus.doc} VldStep4
Valida o banco / Agencia e Conta.

@author 	Edson Melo
@since  	09/02/2021
@version 	12.1.027
@return		logical
/*/
Static Function VldStep4() As Logical
	Local lRet		As Logical
	Local cChavePix As Character
	Local cTpChvPix As Character

	lRet		:= .T.
	cChavePix	:= ""
	cTpChvPix	:= ""

	If Empty(cBancoPIX) .Or. Empty(cAgenPIX) .Or. Empty(cContaPIX)
		Aviso(OemToAnsi(STR0023), OemToAnsi(STR0038), {STR0027}, 3)
		lRet := .F.
	Else
		cBancoPIX := AvKey(cBancoPIX, 	"A6_COD")
		cAgenPIX  := AvKey(cAgenPIX,	"A6_AGENCIA")
		cContaPIX := AvKey(cContaPIX, 	"A6_NUMCON")

		SA6->(DbSetOrder(1)) //A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON
		If !SA6->(DbSeek(FwXFilial("SA6") + cBancoPIX + cAgenPIX + cContaPIX))
			Aviso(OemToAnsi(STR0023), OemToAnsi(STR0039), {STR0027}, 3)
			lRet := .F.
		Else
			cTempF70	:= GetNextAlias()
			cQuery		:= " SELECT  F70_TPCHV, F70_CHVPIX "
			cQuery		+= " FROM " + RetSQLName("F70")+ " "
			cQuery		+= " WHERE F70_FILIAL = '"	+ FwXFilial("SA6")	+ "' "
			cQuery		+= " AND F70_COD = '"		+ cBancoPIX			+ "' "
			cQuery		+= " AND F70_AGENCI = '"	+ cAgenPIX			+ "' "
			cQuery		+= " AND F70_NUMCON = '"	+ cContaPIX			+ "' "
			cQuery		+= " AND F70_ACTIVE = '1' "
			cQuery		+= " AND D_E_L_E_T_ = ' ' "
			cQuery		:= ChangeQuery(cQuery)
			MPSysOpenQuery(cQuery,cTempF70)

			If (cTempF70)->(!EoF())
				cTpChvPix := (cTempF70)->F70_TPCHV
				cChavePix := (cTempF70)->F70_CHVPIX
			EndIf

			(cTempF70)->(DbCloseArea())

			If Empty(cChavePix) .And. Empty(cTpChvPix)
				Aviso(OemToAnsi(STR0023), OemToAnsi(STR0040), {STR0027}, 3)
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} Step5
Criação dos agendamentos e gravação dos dados de conexão.

@author 	Edson Melo
@since  	09/02/2021
@version	12.1.027
@param 		oPanel
/*/
Static Function Step5(oPanel As Object)
	Local cAgend  As Character
	Local cPeriod As Character
	
	TSay():New(025, 025,{|| OemToAnsi(STR0009)}, oPanel,, oFont1,,,, .T., CLR_BLUE)
	
	//Schedule para baixar os retornos do PIX
	cAgend := FwSchdByFunction("FINI892({'" + cEmpAnt + "','" + cFilJob + "'})")
	
	//Somente cria o agendamento do schedule caso o mesmo ainda não exista
	If Empty(cAgend)
		//Executa a cada 10 minutos
		cPeriod := "D(Each(.T.);Day(1);EveryDay(.F.););Execs(0144);Interval(00:10);"
		
		cAgend := FwInsSchedule("FINI892('" + cEmpAnt + "','" + cFilJob + "')", "000000",, cPeriod, "00:00", Upper(GetEnvServer()), cEmpAnt + "/" + cFilJob + ";",;
			SCHD_ACTIVE, Date(), 6, {cEmpAnt, cFilJob})
	EndIf
	
	TSay():New(048, 030,{|| OemToAnsi(STR0042)}, oPanel,, oFont2,,,, .T., CLR_BLUE)
	TSay():New(071, 030,{|| OemToAnsi(STR0043)}, oPanel,, oFont2,,,, .T., CLR_BLUE)
	TSay():New(094, 030,{|| OemToAnsi(STR0044)}, oPanel,, oFont2,,,, .T., CLR_BLUE)
	TSay():New(109, 030,{|| OemToAnsi(STR0045)}, oPanel,, oFont2,,,, .T., CLR_BLUE)
	TSay():New(124, 030,{|| OemToAnsi(STR0046)}, oPanel,, oFont2,,,, .T., CLR_BLUE)
	
	//Efetua gravação dos dados de conexão PIX API independenten do criamento do agendamento
	oConfigS["fin_url_PagamentosDigitais"]						:= AllTrim(cPDUrl)
	oConfigS["fin_user_PagamentosDigitais_" 	+ cChaveConf]	:= AllTrim(cPDUser)
	oConfigS["fin_password_PagamentosDigitais_" + cChaveConf]	:= AllTrim(cPDPss)
	oConfigS["fin_tenant_PagamentosDigitais_" 	+ cChaveConf]	:= AllTrim(cPDTenant)
	oConfigS["fin_idpos_PagamentosDigitais_" 	+ cChaveConf]	:= AllTrim(cPosId)
	oConfigS["fin_busId_PagamentosDigitais_" 	+ cChaveConf]	:= AllTrim(cBusId)
	oConfigS["fin_extBusId_PagamentosDigitais_" + cChaveConf]	:= AllTrim(cExtBusId)
	oConfigS["fin_banco_PagamentosDigitais_" 	+ cChaveBCO]	:= cBancoPIX
	oConfigS["fin_agencia_PagamentosDigitais_" 	+ cChaveBCO]	:= cAgenPIX
	oConfigS["fin_conta_PagamentosDigitais_" 	+ cChaveBCO]	:= cContaPIX
	FwTFSetConfig(oConfigS)
Return Nil

/*/{Protheus.doc} Step5
Encerramento do processo.

@author 	Edson Melo
@since  	09/02/2021
@version 	12.1.027
@param 		oPanel
/*/
Static Function Step6(oPanel As Object)
	TSay():New(025, 025, {|| OemToAnsi(STR0047)}, oPanel,, oFont1,,,, .T., CLR_BLUE)
Return Nil
