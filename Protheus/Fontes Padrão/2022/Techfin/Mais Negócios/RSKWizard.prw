#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FwSchedule.ch"
#INCLUDE "RSKWizard.ch"
#INCLUDE "RSKDefs.ch"

// Posições do Array aWizParam 
#Define CLIENT          1
#Define PROVIDER        2
#Define BANK            3
#Define BILLING         4
#Define OFFBALANCE      5

#Define SIZE_ENTITY     10
#Define SIZE_OFFBALANCE 11

// posições do array OFFBALANCE
#Define CAROL_URL               1
#Define PLATFORM_URL_RISK       2
#Define CAROL_CONNID            3
#Define CAROL_TOKEN             4
#Define RAC_URL                 5
#Define TENANT                  6
#Define RISK_TYPE_DESC          7
#Define RISK_TYPE               8
#Define RISK_CLIENT_ID          9
#Define RISK_CLIENT_SECRET      10
#Define PLATFORM_URL_FMSCASH    11

// posições do array de entidades 
#Define ENT_BRANCH      1 // filial (Ex: A1_FILIAL)
#Define ENT_CODE        2 // código de busca (Ex: A1_COD)
#Define ENT_STORE       3 // código adicional de busca (Ex: A1_LOJA)
#Define ENT_DESC        4 // descrição do registro (Ex: A1_NOME)
#Define ENT_AUX_DESC    5 // descrição auxiliar
#Define ENT_PARAMETER   6 // nome do parâmetro
#Define ENT_ALIAS       7 // tabela da entidade
#Define ENT_IDENT       8 // identificador
#Define ENT_CONTENT     9 // conteúdo do parâmetro
#Define ENT_MODEL       10 // vetor com o registro modelo

//-------------------------------------------------------------------
/*/{Protheus.doc} RSKWizard
Wizard de configuração do produto OffBalance

@author  Marcia Junko
@since   16/06/2020 
/*/
//-------------------------------------------------------------------
Main Function RSKWizard()
	Local lVldFunc  := FindFunction("FWTFConfig") .And. FindFunction("FTFWGrvFRV")

	If lVldFunc
		MsApp():New( "SIGAFIN" )
		oApp:cInternet  := Nil
		__cInterNet := NIL
		oApp:bMainInit  := { || ( oApp:lFlat := .F. , MakeWizard(), Final( STR0001 , "" )  ) }  //"Encerramento Normal"
		oApp:CreateEnv()
		OpenSM0()

		PtSetTheme( "TEMAP10" )
		SetFunName( "UPDDISTR" )
		oApp:lMessageBar := .T.

		oApp:Activate()
	Else
		ApMsgAlert( STR0002, "Wizard Risk" )     //"Uma ou mais funções não foram encontradas para execução do Wizard. Verifique se o ambiente possui a expedição contínua do módulo Financeiro com o pacote de programas (LIB) mais recente."
	EndIf

RETURN

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeWizard
Função responsável pela montagem das abas no Wizard.

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------
Static Function MakeWizard()
	Local oStepWiz
	Local oStatus
	Local oNewPag
	Local oAntecipa
	Local cUser := Space( 35 )
	Local cPsw := Space( 35 )
	Local cPosClientID := Space( 50 )
	Local cPosSecretID := Space( 50 )
	Local aCompany := {}
	Local aSM0     := {}
	Local aWizParam := {}
	Local aRiskTypes := {}
	Local lRet       := .T.

	aRiskTypes := { STR0003, STR0004, STR0005 } //"Mais Negócios"###"Interno e Mais Negócios"###"Interno"

	aWizParam := Array( 5 )   //posições dos agrupadores

	aWizParam[ CLIENT ]       := Array( SIZE_ENTITY )
	aWizParam[ PROVIDER ]     := Array( SIZE_ENTITY )
	aWizParam[ BANK ]         := Array( SIZE_ENTITY )
	aWizParam[ BILLING ]      := Array( SIZE_ENTITY )
	aWizParam[ OFFBALANCE ]   := Array( SIZE_OFFBALANCE )

	oStepWiz:= FWWizardControl():New( , { 530, 720 } )
	oStepWiz:ActiveUISteps()

	//-----------------------
	// Pagina 1 - Boas Vindas
	//-----------------------
	oNewPag := oStepWiz:AddStep()
	oNewPag:SetStepDescription( STR0006 )   //"Boas vindas"
	oNewPag:SetConstruction( { |Panel| MakeStep1( Panel ) } )
	oNewPag:SetNextAction( {|| .T.} )

	//------------------------
	// Pagina 2 - Autenticação
	//------------------------
	oNewPag := oStepWiz:AddStep()
	oNewPag:SetConstruction( {|Panel| MakeStep2( Panel, @cUser, @cPsw, @aCompany, @aSM0) } )
	oNewPag:SetStepDescription( STR0007 )   //"Autenticação"
	oNewPag:SetNextAction( {|| FWMsgRun( /*oComponent*/,{ || lRet := VldStep2( cUser, cPsw, @aCompany, @aWizParam, @cPosClientID, @cPosSecretID, aRiskTypes) }, Nil, STR0008 ), lRet })     //"Validando os acessos do usuário."

	//-------------------------------
	// Pagina 3 - Dados de Integração - Cliente
	//-------------------------------
	oNewPag := oStepWiz:AddStep()
	oNewPag:SetConstruction( {|Panel| MakeStep3( Panel, @aWizParam ) })
	oNewPag:SetStepDescription( STR0009 )    //"Dados da integração Risk"
	oNewPag:SetNextAction( {|| VldStep3( aWizParam ) })

	//-------------------------------
	// Pagina 5 - Dados de Plataforma - Supplier
	//-------------------------------
	oNewPag := oStepWiz:AddStep()
	oNewPag:SetConstruction( {|Panel| MakeStep4( Panel, @aWizParam[ OFFBALANCE ], aRiskTypes ) })
	oNewPag:SetStepDescription( STR0010 )   //"Dados de plataforma"
	oNewPag:SetNextAction( {|| VldStep4( @aWizParam[ OFFBALANCE ], @oAntecipa, aRiskTypes ) })

	//-------------------------------
	// Pagina 6 - Dados de Plataforma do Pós-Faturamento
	//-------------------------------
	oNewPag := oStepWiz:AddStep()
	oNewPag:SetConstruction( {|Panel| MakeStep5( Panel, @aWizParam[ BILLING ] ) })
	oNewPag:SetStepDescription( STR0011 )   //"Dados do Pós Faturamento"
	oNewPag:SetNextAction( {|| VldStep5( aWizParam[ BILLING ] )})

	//----------------------------------
	// Pagina 6 - Ativação da Integração
	//----------------------------------
	oNewPag := oStepWiz:AddStep()
	oNewPag:SetConstruction( {|Panel| MakeStep6( Panel, @oStatus), ;
		SaveConfig( oStatus, cUser, cPsw, aCompany, aSM0, aWizParam, cPosClientID, cPosSecretID, oAntecipa ) })
	oNewPag:SetStepDescription( STR0012 )   //"Ativando a integração"
	oNewPag:SetNextAction( {|| .T.} )
	oNewPag:SetPrevWhen( {|| .F. } )
	oNewPag:SetCancelWhen( {|| .F. } )
	oStepWiz:Activate()


	FWFreeArray( aCompany )
	FWFreeArray( aSM0 )
	FWFreeArray( aWizParam )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeStep1
Função de montagem dos componentes da aba.

@param oPanel, object, Painel onde os componentes serão criados

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------
Static Function MakeStep1( oPanel )
	local oWizard
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oSay7
	Local oGroup1
	local oGroup2
	Local oBitmap1
	Local oBitmap2
	Local oBitmap3
	Local oBitmap4
	Local cWelcome1 := STR0013  //"Boas vindas ao assistente de integração TechFin!"
	Local cWelcome2 := STR0014  //"Para continuar pressione o botão 'Avançar' ou 'Cancelar' para abortar o processo."
	Local cApp := ""
	Local cDb := ""
	Local cRpo := ""
	Local cDbi := ""
	local cValApp := ""
	local cValDb := ""
	local cValRpo := ""
	local cValDbi := ""

	oWizard := FWCarolWizard():New()
	cApp    := oWizard:AREQUIREMENTS[1][1]+": "+oWizard:AREQUIREMENTS[1][2]
	cDb     := oWizard:AREQUIREMENTS[2][1]+": "+oWizard:AREQUIREMENTS[2][2]
	cDbi    := oWizard:AREQUIREMENTS[3][1]+": "+oWizard:AREQUIREMENTS[3][2]
	cRpo    := GetRpoRelease()

	@ 005, 005 GROUP oGroup1 TO 100, 220 PROMPT  OF oPanel COLOR 0, 16777215 PIXEL
	oSay1   := TSay():New( 20, 10, {|| cWelcome1 }, oPanel, , , , , , .T., , , 200, 20)
	oSay2   := TSay():New( 30, 10, {|| cWelcome2 }, oPanel, , , , , , .T., , , 200, 20)
	@ 005, 225 GROUP oGroup2 TO 100, 360 PROMPT  OF oPanel COLOR 0, 16777215 PIXEL
	cValApp := IIF(Eval(oWizard:AREQUIREMENTS[1][3]) == .T., cValApp := 'CHECKOK', cValApp := 'BR_CANCEL')
	@ 20, 230 BITMAP oBitmap1 SIZE 10, 10 OF oPanel FILENAME cValApp NOBORDER PIXEL
	oSay3   := TSay():New( 20, 240, {|| cApp }, oPanel, , , , , , .T., , , 200, 20)
	cValDb  := IIF(Eval(oWizard:AREQUIREMENTS[2][3]) == .T., cValDb := 'CHECKOK', cValDb := 'BR_CANCEL')
	@ 30, 230 BITMAP oBitmap2 SIZE 10, 10 OF oPanel FILENAME cValDb NOBORDER PIXEL
	oSay4   := TSay():New( 30, 240, {|| cDb }, oPanel, , , , , , .T., , , 200, 20)
	cValDbi := IIF(Eval(oWizard:AREQUIREMENTS[3][3]) == .T., cValDbi := 'CHECKOK', cValDbi := 'BR_CANCEL')
	@ 40, 230 BITMAP oBitmap3 SIZE 10, 10 OF oPanel FILENAME cValDbi NOBORDER PIXEL
	oSay5   := TSay():New( 40, 240, {|| cDbi }, oPanel, , , , , , .T., , , 200, 20)
	cValRpo := IIF(cRpo >= "12.1.025", cValRpo := 'CHECKOK', cValRpo := 'BR_CANCEL')
	@ 50, 230 BITMAP oBitmap4 SIZE 10, 10 OF oPanel FILENAME cValRpo NOBORDER PIXEL
	oSay6   := TSay():New( 50, 240, {|| STR0095+cRpo }, oPanel, , , , , , .T., , , 200, 20)
	oSay7   := TSay():New( 160, 10, {|| STR0094+FwtechfinVersion() }, oPanel, , , , , , .T., , , 200, 20)

	FreeObj(oWizard)
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeStep2
Função de montagem dos componentes da aba.

@param oPanel, object, Painel onde os componentes serão criado
@param @cUser, caracter, nome do usuário
@param @cPsw, caracter, senha
@param @aCompany, array, vetor com a lista de empresas para executar a instalação
@param @aSM0, array, vetor com todas as filiais do SIGAMAT

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------
Static Function MakeStep2( oPanel, cUser, cPsw, aCompany, aSM0 )
	Local oTGet1
	Local oTGet2
	Local oList

	aCompany := LoadCompany( @aSM0 )

	DEFINE FONT oCHFont	NAME 'Arial' WEIGHT 10 BOLD
	DEFINE FONT oCMFont	NAME 'Arial' WEIGHT 10

	@ 10, 10 SAY STR0015 OF oPanel PIXEL FONT oCHFont //"Usuário:"
	@ 20, 10 MSGET oTGet1 VAR cUser SIZE 100, 10 OF oPanel Font oCMFont PIXEL

	@ 10, 140 SAY STR0016 OF oPanel PIXEL FONT oCHFont //"Senha:"
	@ 20, 140 MSGET oTGet2 VAR cPsw SIZE 100, 10 OF oPanel Font oCMFont PIXEL PASSWORD


	//-------------------------------------------------------------------
	// Monta a lista de empresas.
	//-------------------------------------------------------------------
	@ 050, 010 LISTBOX oList;
		FIELDS HEADER "", STR0017, STR0018 ; // "Código"###"Descrição da Empresa"
	SIZE 160, 115 OF oPanel PIXEL;
		ON DBLCLICK ( aCompany[ oList:nAt, 1] := !aCompany[ oList:nAt, 1], oList:Refresh( .F. ) )

	oList:SetArray( aCompany )
	oList:bLine := {|| { If( aCompany[ oList:nAt, 1], LoadBitmap( GetResources(), "LBTIK" ), LoadBitmap( GetResources(), "LBNO" )), ;
		aCompany[ oList:nAt, 2], aCompany[ oList:nAt, 3] }}
	oList:bHeaderClick := {|a, b| iif( b == 1 , MarkAll( aCompany, b), ), oList:Refresh() }
	oList:Refresh()

	oTGet1:SetFocus()

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MarkAll
Função para marcar/desmarcar todos os itens de um lista.

@param aArray, array, vetor com os itens a serem marcados/desmarcados
@param nPos, number, posição do array para validar a situação do item

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function MarkAll( aArray, nPos)
	Local lMark := .F.

	aEval(aArray, {|x| iif( !x[ nPos ], lMark := .T., )  })
	aEval(aArray, {|x, i| aArray[ i, nPos] := lMark })
Return .T.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidArr
Função que valida se algum item da lista está marcado.

@param aArray, array, vetor com os itens para validar a seleção.
@return boolean, valida se existe algum item selecionado. 

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function ValidArr( aArray )

Local nLoopComp := 0
Local nX		:= 0
Local nTCompany := Len(aArray)
Local lRetOkComp:= .F.

For nX := 01 To nTCompany
	If aArray[nX,01]
		nLoopComp++
	EndIf
Next

If nLoopComp == 1
	lRetOkComp := .T.
EndIf

Return ( lRetOkComp )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} VldStep2
Função de validação dos objetos da aba
Esta função centraliza a carga das informações contidas no banco de dados necessárias
para as próximas abas, para que não haja conexões desnecessárias no meio do processo
(RPCSETENV/RPCCLEARENV). A maior parte dos parâmetros da função são passados por referência 
(para retornar a função principal de montagem) à fim de retornar os dados.

@param cUser, caracter, usuário
@param cPsw, caracter, senha do usuário
@param @aCompany, array, lista com as empresas
@param @aWizParam, array, vetor com as informarções mostradas no Wizard. 
@param @cPosClientID, caracter, Client ID do Antecipa
@param @cPosSecretID, caracter, Secret ID do Antecipa
@param aRiskTypes, array, vetor com os tipos de uso da plataforma RISK

@return boolean, informa se há erros de preenchimento na aba
@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function VldStep2( cUser, cPsw, aCompany, aWizParam, cPosClientID, cPosSecretID, aRiskTypes )
	Local nVldLogin
	Local cDicCompany   := ""
	Local cNoCompany    := ""
	Local cMsg          := ""
	Local nX            := 0
	Local nCompany      := 0
	Local lValid        := .F.

	If Empty( cUser )
		cMsg := STR0019     //"Informe o usuário"
	ElseIf !ValidArr( aCompany )
		cMsg := STR0020     //"Selecionar uma empresa para processamento"
	Else
		nVldLogin := PswAdmin( Alltrim( cUser ), Alltrim( cPsw ) )
		if nVldLogin == 0
			For nX := 1 To Len(aCompany)
				If aCompany[ nX ][ 1 ]
					OpenSM0( aCompany[ nX ][ 2 ] )
					If ConnectComp( SM0->M0_CODIGO, SM0->M0_CODFIL, cUser, cPsw )
						If nCompany == 0
							nCompany := nX
							LoadPlatInfo( @aWizParam[ OFFBALANCE ], aRiskTypes )
							aWizParam[ CLIENT ] := LoadParamInfo( CLIENT )
							aWizParam[ PROVIDER ] := LoadParamInfo( PROVIDER )
							aWizParam[ BANK ] := LoadParamInfo( BANK )
							aWizParam[ BILLING ] := LoadParamInfo( BILLING )
						EndIf
						If RskVldDic()
							lValid := .T.
						Else
							cDicCompany += SM0->M0_CODIGO + ","
							lValid   := .F.
						EndIf
					Else
						cNoCompany += SM0->M0_CODIGO + ","
					EndIf
					RpcClearEnv()
				EndIf
			Next nX
			If Empty( cNoCompany )
				If lValid
					OpenSM0( aCompany[ nCompany ][ 2 ] )
					ConnectComp( SM0->M0_CODIGO, SM0->M0_CODFIL, cUser, cPsw )
				Else
					cMsg := I18N( STR0021, { SubStr( cDicCompany, 1, Len( cDicCompany ) - 1 ) } )     //"Atualização de dicionário de dados UPDEXRSK ou UPDDISTR (Pacote TECHFIN Risk) não aplicado ou desatualizado para a(s) empresa(s): #1."
				EndIf
			Else
				cMsg     := I18N( STR0022, { SubStr( cNoCompany, 1, Len( cNoCompany ) - 1 ) } )  //"Usuário não possui acesso na(s) empresa(s): #1."
				lValid   := .F.
			EndIf
		Else
			If nVldLogin == 1
				cMsg := STR0023     //"O usuário informado não é administrador do sistema."
			ElseIf nVldLogin == 2
				cMsg := STR0024     //"Dados para login incorretos."
			EndIf
		EndIf
	ENDIF

	If !lValid
		ApMsgAlert( cMsg, "Wizard Risk" )
	EndIf

Return lValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeStep3
Função de montagem dos componentes da aba.

@param oPanel, object, Painel onde os componentes serão criado
@param @aWizParam, array, vetor com as informarções mostradas no Wizard. 

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function MakeStep3( oPanel, aWizParam )
	Local oClient
	Local oStore
	Local oName
	Local lExistSA1 := .F.
	Local lExistSA2 := .F.
	Local lExistSA6 := .F.

	lExistSA1 := CheckParam( CLIENT, aWizParam[ CLIENT ] )
	lExistSA2 := CheckParam( PROVIDER, aWizParam[ PROVIDER ] )
	lExistSA6 := CheckParam( BANK, aWizParam[ BANK ] )

	DEFINE FONT oCHFont	NAME 'Arial' WEIGHT 10 BOLD
	DEFINE FONT oCMFont	NAME 'Arial' WEIGHT 10


	@ 10, 10 SAY STR0025 OF oPanel PIXEL FONT oCHFont   //"Defina os dados que serão utilizados para a integração com a Supplier"

	@ 20, 10 GROUP TO 57, 353 PROMPT STR0026 OF oPanel PIXEL    //'Dados do cliente'

	@ 30, 15 SAY STR0027 OF oPanel PIXEL FONT oCHFont   //"Código:"
	@ 40, 15 MSGET oClient VAR aWizParam[ CLIENT ][ ENT_CODE ]  SIZE 70, 10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA1

	@ 30, 90 SAY STR0028 OF oPanel PIXEL FONT oCHFont   //"Loja:"
	@ 40, 90 MSGET oStore VAR aWizParam[ CLIENT ][ ENT_STORE ]  SIZE 30, 10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA1

	@ 30, 125 SAY STR0029 OF oPanel PIXEL FONT oCHFont  //"Nome:"
	@ 40, 125 MSGET oName VAR aWizParam[ CLIENT ][ ENT_DESC ]  SIZE 150, 10 OF oPanel Font oCMFont PIXEL WHEN .F.

	@ 040, 277 BUTTON oBtnClient PROMPT STR0096 SIZE 30, 11 OF oPanel PIXEL ;
		WHEN !lExistSA1 ACTION ( SetAction( CLIENT, @aWizParam[ CLIENT ], @lExistSA1, .T. ) )    //"Pesquisar"

	@ 040, 310 BUTTON oBtnClient PROMPT STR0030 SIZE 30, 11 OF oPanel PIXEL ;
		WHEN !lExistSA1 ACTION ( SetAction( CLIENT, @aWizParam[ CLIENT ], @lExistSA1, .F. ) )    //"Incluir"

	@ 62, 10 GROUP TO 99, 353 PROMPT STR0031 OF oPanel PIXEL    //'Dados do fornecedor'

	@ 72, 15 SAY STR0027 OF oPanel PIXEL FONT oCHFont   //"Código:"
	@ 82, 15 MSGET oClient VAR aWizParam[ PROVIDER ][ ENT_CODE ]  SIZE 70, 10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA2

	@ 72, 90 SAY STR0028 OF oPanel PIXEL FONT oCHFont   //"Loja:"
	@ 82, 90 MSGET oStore VAR aWizParam[ PROVIDER ][ ENT_STORE ]  SIZE 30,10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA2

	@ 72, 125 SAY STR0029 OF oPanel PIXEL FONT oCHFont  //"Nome:"
	@ 82, 125 MSGET oName VAR aWizParam[ PROVIDER ][ ENT_DESC ]  SIZE 150,10 OF oPanel Font oCMFont PIXEL WHEN .F.

	@ 82, 277 BUTTON oBtnProvider PROMPT STR0096 SIZE 30, 11 OF oPanel PIXEL ;
		WHEN !lExistSA2 ACTION ( SetAction( PROVIDER, @aWizParam[ PROVIDER ], @lExistSA2, .T. ) )    //"Pesquisar"

	@ 82, 310 BUTTON oBtnProvider PROMPT STR0030 SIZE 30, 11 OF oPanel PIXEL ;
		WHEN !lExistSA2 ACTION ( SetAction( PROVIDER, @aWizParam[ PROVIDER ], @lExistSA2, .F. ) )    //"Incluir"

	@ 104, 10 GROUP TO 165, 353 PROMPT STR0032 OF oPanel PIXEL  //'Dados do Banco'

	@ 114, 15 SAY STR0027 OF oPanel PIXEL FONT oCHFont  //"Código:"
	@ 124, 15 MSGET oClient VAR aWizParam[ BANK ][ ENT_CODE ]  SIZE 40, 10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA6

	@ 114, 60 SAY STR0033 OF oPanel PIXEL FONT oCHFont  //"Agência:"
	@ 124, 60 MSGET oStore VAR aWizParam[ BANK ][ ENT_STORE ]  SIZE 60, 10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA6

	@ 114, 125 SAY STR0034 OF oPanel PIXEL FONT oCHFont //"Conta:"
	@ 124, 125 MSGET oName VAR aWizParam[ BANK ][ ENT_DESC ]  SIZE 150, 10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA6

	@ 124, 277 BUTTON oBtnProvider PROMPT STR0096 SIZE 30, 11 OF oPanel PIXEL ;
		WHEN !lExistSA6 ACTION ( SetAction( BANK, @aWizParam[ BANK ], @lExistSA6, .T. ) )     //"Pesquisar"

	@ 124, 310 BUTTON oBtnProvider PROMPT STR0030 SIZE 30, 11 OF oPanel PIXEL ;
		WHEN !lExistSA6 ACTION ( SetAction( BANK, @aWizParam[ BANK ], @lExistSA6, .F. ) )     //"Incluir"

	@ 139, 15 SAY STR0035 OF oPanel PIXEL FONT oCHFont  //"Nome do banco:"
	@ 149, 15 MSGET oName VAR aWizParam[ BANK ][ ENT_AUX_DESC ]  SIZE 150, 10 OF oPanel Font oCMFont PIXEL WHEN .F.

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckParam
Função de verifica se o registro existe no banco de dados

@param nType, number, identifica qual a entidade está sendo validada, onde:
    [1] - cliente
    [2] - fornecedor
    [3] - banco
    [4] - situação de cobrança

@param aInfo, array, armezena os dados da entidade a ser pesquisada

@return boolean, indica se o registro em questão existe no banco de dados.

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function CheckParam( nType, aInfo )
	Local lExist := .F.
	Local cQuery := ''
	Local cTempAlias := ''
	Local aSvAlias := GetArea()

	IF nType == CLIENT
		cQuery := "SELECT A1_COD FROM " + RetSqlName( aInfo[ ENT_ALIAS ] ) + ;
			" WHERE A1_FILIAL = '" + aInfo[ ENT_BRANCH ] + "' " + ;
			" AND A1_COD = '" + aInfo[ ENT_CODE ] + "' " + ;
			" AND A1_LOJA = '" + aInfo[ ENT_STORE ] + "' " + ;
			" AND D_E_L_E_T_ = ' '"
	ElseiF nType == PROVIDER
		cQuery := "SELECT A2_COD FROM " + RetSqlName( aInfo[ ENT_ALIAS ] ) + ;
			" WHERE A2_FILIAL = '" + aInfo[ ENT_BRANCH ] + "' " + ;
			" AND A2_COD = '" + aInfo[ ENT_CODE ] + "' " + ;
			" AND A2_LOJA = '" + aInfo[ ENT_STORE ] + "' " + ;
			" AND D_E_L_E_T_ = ' '"
	ElseiF nType == BANK
		cQuery := "SELECT A6_COD FROM " + RetSqlName( aInfo[ ENT_ALIAS ] ) + ;
			" WHERE A6_FILIAL = '" + aInfo[ ENT_BRANCH ] + "' " + ;
			" AND A6_COD = '" + aInfo[ ENT_CODE ] + "' " + ;
			" AND A6_AGENCIA = '" + aInfo[ ENT_STORE ] + "' " + ;
			" AND A6_NUMCON = '" + aInfo[ ENT_DESC ] + "' " + ;
			" AND D_E_L_E_T_ = ' '"
	ElseiF nType == BILLING
		cQuery := "SELECT FRV_CODIGO FROM " + RetSqlName( aInfo[ ENT_ALIAS ] ) + ;
			" WHERE FRV_FILIAL = '" + aInfo[ ENT_BRANCH ] + "' " + ;
			" AND FRV_CODIGO = '" + aInfo[ ENT_CODE ] + "' " + ;
			" AND D_E_L_E_T_ = ' '"
	EndIf

	IF !Empty( cQuery )
		cQuery := ChangeQuery( cQuery )

		cTempAlias := MPSysOpenQuery( cQuery )
		If ( cTempAlias )->( !Eof() )
			lExist := .T.
		EndIf
		( cTempAlias )->( DbCloseArea() )
	EndIf

	RestArea( aSvAlias )
	FWFreeArray( aSvAlias )
Return lExist

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetAction
Função executada ao clicar no botão Informar dados.
Esta função é responsável por montar a AXINCLUI para informar os dados adicionais ao 
incluir o registro na base de dados.

@param nType, number, identifica qual a entidade está sendo validada, onde:
    [1] - cliente
    [2] - fornecedor
    [3] - banco
    [4] - situação de cobrança

@param aArray, array, armezena os dados da entidade
@param @lExist, boolean, variável de controle do botão. Se ocorrer a inclusão pela
função, o botão no wizard deve ser desabilitado. 
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Function SetAction( nType, aArray, lExist, lPesqCad, lAutomato )
	Local aSvAlias := GetArea()
	Local aParam   := Array(4)
	Local aFields  := {}
	Local cAlias   := ''
	Local nPos     := 0

	Private cCadastro
	Private aRotina   := MenuDef()
	Private lAtuCad   := .F.

	Default lAutomato := .F.
	Default lPesqCad  := .F.

	If nType == CLIENT
		cCadastro := STR0036    //"Configuração do cliente - OffBalance"
		aFields   := {'A1_FILIAL', 'A1_COD', 'A1_LOJA', 'A1_NOME', 'A1_NREDUZ'}
	ElseIf nType == PROVIDER
		cCadastro := STR0037    //"Configuração do fornecedor - OffBalance"
		aFields   := {'A2_FILIAL', 'A2_COD', 'A2_LOJA', 'A2_NOME', 'A2_NREDUZ'}
	ElseIf nType == BANK
		cCadastro := STR0038    //"Configuração do banco - OffBalance"
		aFields   := {'A6_FILIAL', 'A6_COD', 'A6_AGENCIA', 'A6_NUMCON', 'A6_NOME', 'A6_NREDUZ'}
	EndIf

	cAlias := aArray[ ENT_ALIAS ]

	If lPesqCad
		If .Not. lAutomato
			mBrowse(6,1,22,75,cAlias)
		EndIf
	Else
		aArray := LoadParamInfo(nType)
		aParam[1] := {|| SetFldEnch( nType, aFields, aArray )}
		aParam[2] := {|| .T. }
		aParam[3] := {|| .T. }
		aParam[4] := {|| .T. }

		If !lAutomato .And. AxInclui( cAlias, , , , , , , , , , aParam ) == 1
			lAtuCad := .T.
			lExist  := .T.
		EndIf
	EndIf

	If lAtuCad
		For nPos := 1 To Len( aFields ) - 1
			aArray[ nPos ] := ( cAlias )->&( aFields[ nPos ])
		Next
	EndIf

	RestArea( aSvAlias )

	FWFreeArray( aParam )
	FWFreeArray( aSvAlias )
	FWFreeArray( aFields )
	FWFreeArray( aRotina )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetFldEnch
Função responsável em atribuir um conteúdo padrão aos campos da enchoice.

@param nType, number, identifica qual a entidade está sendo validada, onde:
    [1] - cliente
    [2] - fornecedor
    [3] - banco
    [4] - situação de cobrança
@param aEnchFields, array, lista de campos que terá um conteúdo pré-estabelecido na enchoice
@param aValue, array, armezena os dados da entidade

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function SetFldEnch( nType, aEnchFields, aValue )
	Local nPos := 0
	Local cAuxDesc := 'SUPPLIER OFFBALANCE'
	Local cField := ''
	Local lOther := .F.

	For nPos := 1 To Len( aEnchFields )
		cField := aEnchFields[ nPos ]
		lOther := .F.

		If cField == 'A6_NOME'
			cAuxDesc := STR0039     //'SUPPLIER - CONTA TRANSITÓRIA'
			lOther := .T.
		elseIf cField == 'A6_NREDUZ'
			cAuxDesc := 'SUPPLIER'
			lOther := .T.
		EndIF

		If nPos != len( aEnchFields ) .And. !lOther
			M->&( aEnchFields[ nPos ] ) := aValue[ nPos ]
		Else
			M->&( aEnchFields[ nPos ] ) := cAuxDesc
		EndIF
	Next

	If nType == CLIENT .OR. nType == PROVIDER
		SetOtherFlds( nType )
	EndIf
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetOtherFlds
Função responsável em atribuir um conteúdo padrão aos campos da enchoice que não estão 
no array de controle.

@param nType, number, identifica qual a entidade está sendo validada, onde:
    [1] - cliente
    [2] - fornecedor

@author  Marcia Junko
@since   05/10/2020
/*/
//-------------------------------------------------------------------------------------
Static Function SetOtherFlds( nType )
	Local aContent := {}
	Local cPrefix := ''
	Local cField := ''
	Local nItem := 0

	// Nunca traduzir estes dados, pois são os dados de cadastro da Supplier
	aContent := { { 'CGC', '06951711000128' }, ;
		{ 'END', 'Av. Paulista, 1728' }, ;
		{ 'COMPLEM', '13º andar' }, ;
		{ 'COD_MUN', '50308' }, ;
		{ 'MUN', 'SAO PAULO' }, ;
		{ 'BAIRRO', 'Cerqueira Cesar' }, ;
		{ 'EST', 'SP' }, ;
		{ 'CEP', '01310200' }, ;
		{ 'TEL', '11 4081-4000' }, ;
		{ 'EMAIL', 'controladoria@supplier.com.br' }, ;
		{ 'PAIS', '105' } }

	If nType == CLIENT
		cPrefix := PrefixoCpo( 'SA1' )

		Aadd( aContent, { 'A1_PESSOA', 'J' } )
		Aadd( aContent, { 'A1_TIPO', 'F' } )
	Else
		cPrefix := PrefixoCpo( 'SA2' )

		Aadd( aContent, { 'A2_TIPO', 'J' } )
	EndIf

	For nItem := 1 to len( aContent )
		cField := aContent[ nItem ][1]

		IF !( cPrefix + '_' $ cField )
			cField := cPrefix + '_' + cField
		EndIf
		M->&( cField ) := aContent[ nItem ][2]
	Next

	FWFreeArray( aContent )
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} VldStep3
Função de validação dos objetos da aba - Dados de integração com a Supplier

@param aWizParam, array, vetor com as informarções mostradas no Wizard. 

@return boolean, informa se há erros de preenchimento na aba
@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function VldStep3( aWizParam )
	Local lValid := .T.
	Local cMsg  := ''

	If Empty( aWizParam[ CLIENT ][ ENT_CODE ] ) .Or. Empty( aWizParam[ CLIENT ][ ENT_STORE ] ) .Or. Empty( aWizParam[ CLIENT ][ ENT_DESC ] )
		lValid := .F.
		cMsg := STR0040     //"Informe os dados do cliente para a integração com a Supplier."
	else
		lValid := CheckParam( CLIENT, aWizParam[ CLIENT ] )

		IF !lValid
			cMsg := STR0041     //"Preencha os dados complementares para a inclusão do cliente pelo botão 'Informar dados'."
		EndIf
	Endif

	If lValid
		If Empty( aWizParam[ PROVIDER ][ ENT_CODE ] ) .Or. Empty( aWizParam[ PROVIDER ][ ENT_STORE ] ) .Or. Empty( aWizParam[ PROVIDER ][ ENT_DESC ] )
			lValid := .F.
			cMsg := STR0042     //"Informe os dados do fornecedor para a integração com a Supplier."
		else
			lValid := CheckParam( PROVIDER, aWizParam[ PROVIDER ] )

			IF !lValid
				cMsg := STR0043     //"Preencha os dados complementares para a inclusão do fornecedor pelo botão 'Informar dados'."
			EndIf
		Endif
	EndIf

	If lValid
		If Empty( aWizParam[ BANK ][ ENT_CODE ] ) .Or. Empty( aWizParam[ BANK ][ ENT_STORE ] ) .Or. Empty( aWizParam[ BANK ][ ENT_DESC] )
			lValid := .F.
			cMsg := STR0044     //"Informe os dados do banco para a integração com a Supplier."
		else
			lValid := CheckParam( BANK, aWizParam[ BANK ])

			IF !lValid
				cMsg := STR0045     //"Preencha os dados complementares para a inclusão do banco pelo botão 'Informar dados'."
			EndIf
		Endif
	ENDIF

	If !lValid
		ApMsgAlert( cMsg )
	EndIf
Return lValid


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeStep4
Função de montagem dos componentes da aba - Dados da plataforma Offbalance

@param oPanel, object, Painel onde os componentes serão criado
@param @aPlatInfo, array, vetor com as informarções de conexão da plataforma
@param aRiskTypes, array, vetor com os tipos de uso do Risk

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function MakeStep4( oPanel, aPlatInfo, aRiskTypes )
	Local oCHFont
	Local oCMFont
	Local oCarolURL
	Local oPlatformURL
	Local oRSKClientID
	Local oRSKSecret
	Local oRiskType

	DEFINE FONT oCHFont	NAME 'Arial' WEIGHT 10 BOLD
	DEFINE FONT oCMFont	NAME 'Arial' WEIGHT 10

	@ 10, 10 GROUP TO 145, 353 PROMPT STR0046 OF oPanel PIXEL   //'Acesso a plataforma'

	@ 20, 15 SAY STR0047 OF oPanel PIXEL FONT oCHFont   //"Client ID:"
	@ 30, 15 MSGET oRSKClientID VAR aPlatInfo[ RISK_CLIENT_ID ] SIZE 120, 10 OF oPanel Font oCMFont PIXEL

	@ 45, 15 SAY STR0048 OF oPanel PIXEL FONT oCHFont   //"Secret ID:"
	@ 55, 15 MSGET oRSKSecret VAR aPlatInfo[ RISK_CLIENT_SECRET ] SIZE 120, 10 OF oPanel Font oCMFont PIXEL

	@ 70, 15 SAY STR0049 OF oPanel PIXEL FONT oCHFont   //"Carol URL:"
	@ 80, 15 MSGET oCarolURL VAR aPlatInfo[ CAROL_URL ] SIZE 120, 10 OF oPanel Font oCMFont PIXEL

	@ 95, 15 SAY STR0050 OF oPanel PIXEL FONT oCHFont   //"URL Plataforma Risk:"
	@ 105, 15 MSGET oPlatformURL VAR aPlatInfo[ PLATFORM_URL_RISK ] SIZE 120, 10 OF oPanel Font oCMFont PIXEL

	@ 120, 15 SAY STR0051 OF oPanel PIXEL FONT oCHFont  //"URL Plataforma Antecipa:"
	@ 130, 15 MSGET oPlatformURL VAR aPlatInfo[ PLATFORM_URL_FMSCASH ] SIZE 120, 10 OF oPanel Font oCMFont PIXEL


	@ 148, 10 GROUP TO 170, 353 PROMPT STR0052 OF oPanel PIXEL  //'Tipo de uso'

	@ 158, 15 SAY STR0053 OF oPanel PIXEL FONT oCHFont      //"Forma de utilização da plataforma RISK:"
	@ 157, 130 MSCOMBOBOX oRiskType VAR aPlatInfo[ RISK_TYPE_DESC ] ITEMS aRiskTypes SIZE 120, 9 OF oPanel PIXEL

Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeStep5
Função de montagem dos componentes da aba - dados da plataforma Pós Faturamento

@param oPanel, object, Painel onde os componentes serão criado
@param @aBilling, array, vetor com as informações da situação de cobrança

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function MakeStep5( oPanel, aBilling )
	Local oCodSitCob
	Local oDescSitCob

	DEFINE FONT oCHFont	NAME 'Arial' WEIGHT 10 BOLD
	DEFINE FONT oCMFont	NAME 'Arial' WEIGHT 10

	@ 10, 10 GROUP TO 50, 353 PROMPT STR0054 OF oPanel PIXEL    //'Carteira Devolução - Pós Faturamento'

	@ 20, 15 SAY STR0017  SIZE 200, 20 OF oPanel PIXEL      //"Código"
	@ 30, 15 MSGET oCodSitCob VAR aBilling[ ENT_CODE ] SIZE 30, 9 OF oPanel PIXEL PICTURE "@!" WHEN .F.;
		VALID RSKVlAlfaNum( aBilling[ ENT_CODE ] )

	@ 20, 54 SAY STR0055  SIZE 250, 20 OF oPanel PIXEL      //"Descrição"
	@ 30, 54 MSGET oDescSitCob VAR aBilling[ ENT_STORE ] SIZE 200, 9 OF oPanel PIXEL PICTURE "@!" WHEN .F.

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} VldStep5
Função de validação dos objetos da aba - Dados de integração com o Antecipa

@param aBilling, array, vetor com as informações da situação de cobrança

@return boolean, informa se há erros de preenchimento na aba
@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function VldStep5( aBilling )
	Local lValid := .F.

	lValid := !Empty( aBilling[ ENT_CODE ] )
	RPCClearEnv()
Return lValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ChkPlatAntecipa
Função de validação das informações de conexão com o Antencipa

@param @aOffBalance, array, vetor com as informarções de conexão da plataforma
@param @oAntecipa, object, objeto de validação da plataforma do Antecipa

@return boolean, informa se há erros de preenchimento na aba
@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function ChkPlatAntecipa( aOffBalance, oAntecipa )
	Local lValid       := .F.
	Local aHeader      := {}
	Local aToken       := {}
	Local cBody        := ''
	Local cEndPoint    := ''
	Local cResult      := ''
	Local cClientID    := ''
	Local cSecret      := ''
	Local cPlatafCash   := ''
	Local cTenant      := ''
	Local cMessage      := ''
	Local oConfig
	Local oJson
	Local oRest

	cClientID := aOffBalance[ RISK_CLIENT_ID ]
	cSecret := aOffBalance[ RISK_CLIENT_SECRET ]
	cPlatafCash := aOffBalance[ PLATFORM_URL_FMSCASH ]
	cEndPoint := RSKSetRacURL( oConfig, cPlatafCash )

	AAdd( aHeader, "Content-Type: application/x-www-form-urlencoded" )
	AAdd( aHeader, "charset: UTF-8" )
	AAdd( aHeader, "User-Agent: Protheus " + GetBuild() )

	cBody := "client_id=" + cClientId + "&"
	cBody += "client_secret=" + cSecret + "&"
	cBody += "grant_type=client_credentials&"
	cBody += "scope=authorization_api"

	oRest := FWRest():New( cEndPoint )
	oRest:setPath( '/totvs.rac/connect/token' )
	oRest:SetPostParams( cBody )

	If oRest:Post( aHeader )
		cResult := oRest:GetResult()
		oJson := JsonObject():New()
		oJson:fromJson( cResult )

		aHeader := {}
		cResult := ''

		AAdd( aHeader, "Content-Type: application/json" )
		AAdd( aHeader, "Authorization: Bearer " + oJson[ "access_token" ] )
		AAdd( aHeader, "User-Agent: Protheus " + GetBuild() )

		oRest := FWRest():New( cPlatafCash )
		oRest:setPath( '/integration/api/v1/carol-accesses' )

		If oRest:Get( aHeader )
			cResult := oRest:GetResult()
			oAntecipa := JsonObject():New()
			oAntecipa:fromJson( cResult )

			aOffBalance[ RAC_URL ] := cEndPoint

			cTenant := GetTokenInfo( oJson[ "access_token" ], "http://www.tnf.com/identity/claims/tenantId" )
			If !Empty( cTenant )
				aOffBalance[ TENANT ] := cTenant
			EndIf
			lValid := .T.
		EndIf
	EndIf

	If !lValid
		IF !Empty( oRest:GetHTTPCode() ) .And. oRest:GetHTTPCode() != "200"
			cMessage := CRLF + CRLF + STR0091 + oRest:GetLastError() + ' - ' + oRest:GetResult()  //'Status da requisição: '
		EndIf

		MsgStop( STR0056 + cMessage )  //"Informações de conexão inválidas na plataforma Antecipa."
	EndIf

	FwFreeArray( aHeader )
	FwFreeArray( aToken )
	FreeObj( oJson )
	FreeObj( oRest )
Return lValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ChkPlatRisk
Função de validação das informações de conexão com o Risk

@param @aOffBalance, array, vetor com as informarções de conexão da plataforma

@return boolean, informa se há erros de preenchimento na aba
@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function ChkPlatRisk( aOffBalance )
	Local lValid       := .F.
	Local aHeader      := {}
	Local aToken       := {}
	Local cBody        := ''
	Local cEndPoint    := ''
	Local cResult      := ''
	Local cClientID    := ''
	Local cSecret      := ''
	Local cPlatafRisk  := ''
	Local cMessage     := ''
	Local oConfig
	Local oJson
	Local oRest

	cClientID := aOffBalance[ RISK_CLIENT_ID ]
	cSecret := aOffBalance[ RISK_CLIENT_SECRET ]
	cPlatafRisk := aOffBalance[ PLATFORM_URL_RISK ]

	cEndPoint   := RSKSetRacURL( oConfig, cPlatafRisk, 2 )

	AAdd( aHeader, "Content-Type: application/x-www-form-urlencoded" )
	AAdd( aHeader, "charset: UTF-8" )
	AAdd( aHeader, "User-Agent: Protheus " + GetBuild() )

	cBody := "client_id=" + cClientId + "&"
	cBody += "client_secret=" + cSecret + "&"
	cBody += "grant_type=client_credentials&"
	cBody += "scope=authorization_api"

	oRest := FWRest():New( cEndPoint )
	oRest:setPath( '/totvs.rac/connect/token' )
	oRest:SetPostParams( cBody )

	If oRest:Post( aHeader )
		cResult := oRest:GetResult()
		oJson := JsonObject():New()
		oJson:fromJson( cResult )

		aHeader := {}
		cResult := ''

		AAdd( aHeader, "Content-Type: application/json" )
		AAdd( aHeader, "Authorization: Bearer " + oJson[ "access_token" ] )
		AAdd( aHeader, "User-Agent: Protheus " + GetBuild() )

		oRest := FWRest():New( cPlatafRisk )
		oRest:setPath( '/protheus-api/v1/credit_ticket' )

		If oRest:Get( aHeader )
			lValid := .T.
		EndIf
	EndIf

	If !lValid
		IF !Empty( oRest:GetHTTPCode() ) .And. oRest:GetHTTPCode() != "200"
			cMessage := CRLF + CRLF + STR0091 + oRest:GetLastError() + ' - ' + oRest:GetResult()  //'Status da requisição: '
		EndIf

		MsgStop( STR0057 + cMessage )      //"Informações de conexão inválidas na plataforma Risk."
	EndIf

	FwFreeArray( aHeader )
	FwFreeArray( aToken )
	FreeObj( oJson )
	FreeObj( oRest )

Return lValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTokenInfo
Função que retorna dados específicos relacionados ao token

@param cToken, caracter, token
@param cInfo, caracter, propriedade a pesquisar

@return caracter, conteúdo pesquisado
@author  Marcia Junko
@since   04/08/2020
/*/
//-------------------------------------------------------------------------------------
Static Function GetTokenInfo( cToken, cInfo )
	Local aToken := {}
	Local cJson := ''
	Local cResult := ''
	Local oPayLoad

	oPayLoad := JsonObject():New()

	aToken := StrTokArr( cToken, "." )
	cJson := Decode64( aToken[ 2 ] )

	oPayLoad:fromJson( cJson )
	cResult := oPayLoad[ cInfo ]

	FWFreeArray( aToken )
	FreeObj( oPayLoad )
Return cResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckCarol
Função de validação das informações de conexão com o Antencipa

@param @aOffBalance, array, vetor com as informarções de conexão da plataforma
@param oAntecipa, object, objeto de validação da plataforma do Antecipa

@return boolean, informa se há erros de preenchimento na aba
@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function CheckCarol( aOffBalance, oAntecipa )
	Local aHeader := {}
	Local cResult := ''
	Local cURL := ''
	Local cEndpoint := ''
	Local cConnector := ''
	Local cAPIToken := ''
	Local cMessage := ''
	Local lValid := .F.
	Local oResponse

	Default oAntecipa[ "apiToken" ]    := ""
	Default oAntecipa[ "connectorId" ] := ""

	cURL := aOffBalance[ CAROL_URL ]
	cConnector :=  oAntecipa[ "connectorId" ]
	cAPIToken := oAntecipa[ "apiToken" ]

	cEndpoint := "/v2/apiKey/details?connectorId=" + cConnector + "&apiKey=" + cAPIToken

	AAdd( aHeader, "X-Auth-Key: " + cAPIToken  )
	AAdd( aHeader, "X-Auth-ConnectorId: " + cConnector )
	AAdd( aHeader, "User-Agent: Protheus " + GetBuild() )

	oRest := FWRest():New( cURL )
	oRest:setPath( cEndPoint )

	If oRest:Get( aHeader )
		cResult := oRest:GetResult()
		oResponse := JsonObject():New()
		oResponse:fromJson( cResult )
		lValid := oResponse[ "connectorId" ] != Nil

		If lValid
			aOffBalance[ CAROL_CONNID ] := cConnector
			aOffBalance[ CAROL_TOKEN ] := cAPIToken
		EndIf
	Else
		IF !Empty( oRest:GetHTTPCode() ) .And. oRest:GetHTTPCode() != "200"
			cMessage := CRLF + CRLF + STR0091 + oRest:GetLastError() + ' - ' + oRest:GetResult()  //'Status da requisição: '
		EndIf

		MsgStop( STR0092 + cMessage )   //"Informações de conexão inválidas na Carol."
	EndIf
Return lValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadPlatInfo
Função que busca os parâmetros de conexão com a plataforma RISK e a Carol

@param @aPlatInfo, array, vetor com informações de conexão com a plataforma
    [1] - URL da plataforma Carol
    [2] - URL da plataforma RISK
    [3] - ID do conector da Carol
    [4] - Token da API da Carol
    [5] - URL do RAC
    [6] - ID do tenant
    [7] - Descrição do tipo de uso
    [8] - Tipo de uso (salvo no parâmetro MV_RISKTIP)
    [9] - Client ID
    [10] - Secret
@param aRiskTypes, array, vetor com os tipos de uso da plataforma RISK
@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function  LoadPlatInfo( aPlatInfo, aRiskTypes )
	Local aSvAlias := GetArea()
	Local nRiskType := 0
	Local nTamInfo := 120
	Local cRacURL := ''
	Local cPlatform := ''
	Local cPlatfCash := ''
	Local cClientID := ''
	Local cCarolURL := ''
	Local cCarolConnID := ''
	Local cCarolToken := ''
	Local cTenant := ''
	Local cTypeDesc := ''
	Local oConfig

	oConfig := FWTFConfig()
	cClientID := oConfig[ "platform-clientId" ]
	nRiskType := SuperGetMV( 'MV_RISKTIP', .F., 2  )
	cTypeDesc := GetRiskType( nRiskType, aRiskTypes )

	If !Empty( cClientID )
		cPlatform       := SuperGetMV( 'MV_RSKPLAT', .F., '' )
		cCarolURL       := oConfig[ "carol-endpoint" ]
		cPlatfCash      := oConfig[ "platform-endpoint" ]
		cCarolConnID    := oConfig[ "carol-connectorId" ]
		cCarolToken     := oConfig[ "carol-apiToken" ]
		cRacURL         := oConfig[ "rac-endpoint" ]
		cTenant         := oConfig[ "platform-tenantId" ]
		cSecret         := oConfig[ "platform-secret" ]
	Else
		cCarolURL       := SuperGetMV( 'MV_RSKCURL', .F., '' )
		cPlatform       := SuperGetMV( 'MV_RSKPLAT', .F., '' )
		cCarolConnID    := SuperGetMV( 'MV_RSKCCID', .F., '' )
		cCarolToken     := SuperGetMV( 'MV_RSKCTOK', .F., '' )

		cRacURL := SuperGetMV( 'MV_RSKRAC', .F., '' )
		If Empty( cRacURL)
			cRacURL := RSKSetRacURL( NIL, cPlatform )
		EndIf
		cTenant := SuperGetMV( 'MV_RSKTENA', .F., '' )

		cClientID := SuperGetMV( 'MV_RSKCID', .F., '' )
		cSecret := SuperGetMV( 'MV_RSKSID', .F., '' )
	EndIf

	aPlatInfo[ CAROL_URL ]              := Padr( cCarolURL, nTamInfo )
	aPlatInfo[ PLATFORM_URL_RISK ]      := Padr( cPlatform, nTamInfo )
	aPlatInfo[ CAROL_CONNID ]           := Padr( cCarolConnID, nTamInfo )
	aPlatInfo[ CAROL_TOKEN ]            := Padr( cCarolToken, nTamInfo )
	aPlatInfo[ RAC_URL ]                := Padr( cRacURL, nTamInfo )
	aPlatInfo[ TENANT ]                 := Padr( cTenant, nTamInfo )
	aPlatInfo[ RISK_TYPE ]              := nRiskType
	aPlatInfo[ RISK_TYPE_DESC ]         := Padr( cTypeDesc, nTamInfo )
	aPlatInfo[ RISK_CLIENT_ID ]         := Padr( cClientID, nTamInfo )
	aPlatInfo[ RISK_CLIENT_SECRET ]     := Padr( cSecret, nTamInfo )
	aPlatInfo[ PLATFORM_URL_FMSCASH ]   := Padr( cPlatfCash, nTamInfo )

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FreeObj( oConfig )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadParamInfo
Esta função é responsável por retornar os dados padrões do parâmetro (caso não esteja 
preenchido) ou os dados existentes no banco de dados.

@param nType, number, identifica qual a entidade está sendo validada, onde:
    [1] - cliente
    [2] - fornecedor
    [3] - banco
    [4] - situação de cobrança
@param lPesqComp, Logical, define como será o retorno da função

@return, array, armezena os dados da entidade
    aReturn[1] := filial (Ex: A1_FILIAL)
    aReturn[2] := código de busca (Ex: A1_COD)
    aReturn[3] := código auxiliar de busca (Ex: A1_LOJA)
    aReturn[4] := descrição do registro (Ex: A1_NOME)
    aReturn[5] := descrição auxiliar  
    aReturn[6] := nome do parâmetro
    aReturn[7] := tabela da entidade
    aReturn[8] := identificação
    aReturn[9] := conteúdo do parâmetro
    aReturn[10] := vetor com o registro modelo

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function LoadParamInfo( nType, lPesqComp )
	Local aSvAlias := GetArea()
	Local cContent := ''
	Local cAux := ''
	Local cDefaultText := 'SUPPLIER'
	Local cSupplierName := 'SUPPLIER ADM. DE CARTOES DE CREDITO S/A' //Nunca traduzir
	Local aReturn := Array( SIZE_ENTITY )
	Local aContent := {}
	Local cSeek := ''
	Local cAlias := ''

	Default lPesqComp := .T.

	If nType == CLIENT
		aReturn[ ENT_CODE ] := Padr( cDefaultText, TamSX3( 'A1_COD' )[1] )
		aReturn[ ENT_STORE ] := StrZero( 1, TamSX3( "A1_LOJA" )[1] )
		aReturn[ ENT_DESC ] := Padr( cSupplierName, TamSX3( "A1_NOME" )[1] )
		aReturn[ ENT_AUX_DESC ] := ''
		aReturn[ ENT_PARAMETER ] := 'MV_RSKCPAY'
		aReturn[ ENT_ALIAS ] := 'SA1'
		aReturn[ ENT_IDENT] := 'Client'
	ElseIf nType == PROVIDER
		aReturn[ ENT_CODE ] := Padr( cDefaultText, TamSX3( 'A2_COD' )[1] )
		aReturn[ ENT_STORE ] := StrZero( 1, TamSX3( "A2_LOJA" )[1] )
		aReturn[ ENT_DESC ] := Padr( cSupplierName, TamSX3( "A2_NOME" )[1] )
		aReturn[ ENT_AUX_DESC ] := ''
		aReturn[ ENT_PARAMETER ] := 'MV_RSKFPAY'
		aReturn[ ENT_ALIAS ] := 'SA2'
		aReturn[ ENT_IDENT ] := 'Provider'
	ElseIf nType == BANK
		aReturn[ ENT_CODE ] := Padr( cDefaultText, TamSX3( 'A6_COD' )[1] )
		aReturn[ ENT_STORE ] := Padr( cDefaultText, TAMSX3( "A6_AGENCIA" )[1] )
		aReturn[ ENT_DESC ] := Padr( cDefaultText, TAMSX3( "A6_NUMCON" )[1] )
		aReturn[ ENT_AUX_DESC ] := Padr( STR0039, TAMSX3( "A6_NOME" )[1] )  //'SUPPLIER - CONTA TRANSITORIA'
		aReturn[ ENT_PARAMETER ] := 'MV_RSKBPAY'
		aReturn[ ENT_ALIAS ] := 'SA6'
		aReturn[ ENT_IDENT ] := 'Bank'
	ElseIf nType == BILLING
		aReturn[ ENT_CODE ] := ValidCart()
		aReturn[ ENT_STORE ] := Padr( STR0054, TamSx3( "FRV_DESCRI" )[1] )  //'CARTEIRA DEVOLUCAO POS FATURAMENTO'
		aReturn[ ENT_DESC ] := ''
		aReturn[ ENT_AUX_DESC ] := ''
		aReturn[ ENT_PARAMETER ] := 'MV_RSKSNCC'
		aReturn[ ENT_ALIAS ] := 'FRV'
		aReturn[ ENT_IDENT ] := 'Billing'
	EndIf

	aReturn[ ENT_BRANCH ] := xFilial( aReturn[ ENT_ALIAS ] )
	aReturn[ ENT_CONTENT ] := ''
	aReturn[ ENT_MODEL ] := {}

	cContent := SuperGetMV( aReturn[ ENT_PARAMETER ], .T., '' )

	If !Empty( cContent ) .And. lPesqComp
		cAlias := aReturn[ ENT_ALIAS ]
		cSeek := StrTran( cContent, '|', '' )
		aContent := StrtokArr( cContent , '|' )

		aReturn[ ENT_CODE ] := aContent[1]

		If nType == BANK
			cAux := Posicione( 'SA6', 1, xFilial( 'SA6' ) + cSeek, 'A6_AGENCIA' )
			If !Empty( cAux )
				aReturn[ ENT_STORE ] := cAux
			Else
				aReturn[ ENT_STORE ] := aContent[2]
			EndIf

			cAux := Posicione( 'SA6', 1, xFilial( 'SA6' ) + cSeek, 'A6_NUMCON' )
			If !Empty( cAux )
				aReturn[ ENT_DESC ] := cAux
			Else
				aReturn[ ENT_DESC ] := aContent[3]				
			EndIf

			cAux := Posicione( 'SA6', 1, xFilial( 'SA6' ) + cSeek, 'A6_NOME' )
			If !Empty( cAux )
				aReturn[ ENT_AUX_DESC ] := cAux
			EndIf
		ElseIf nType == BILLING
			cAux := Posicione( 'FRV', 1, xFilial('FRV') + cSeek , 'FRV_DESCRI' )
			If !Empty( cAux )
				aReturn[ ENT_STORE ] := cAux
			EndIf
		Else
			aReturn[ ENT_STORE ] := aContent[2]
			aReturn[ ENT_DESC ] := Posicione( cAlias, 1, xFilial( cAlias ) + cSeek, PrefixoCPO( cAlias ) + '_NOME' )
		EndIf

		aReturn[ ENT_CONTENT ] := cContent
	EndIf

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FWFreeArray( aContent )
Return aReturn

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} VldStep4
Função de validação dos objetos da aba - Dados da plataforma Supplier

@param @aPlatInfo, array, vetor com as informações da conexão com a plataforma RISK
@param @oAntecipa, object, objeto de validação da plataforma do Antecipa
@param aRiskTypes, array, vetor com os tipos de uso do Risk

@return boolean, informa se há erros de preenchimento na aba
@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function VldStep4( aPlatInfo, oAntecipa, aRiskTypes )
	Local lValid := .T.
	Local cMsg  := ''
	Local nLen := 0

	aPlatInfo[ RISK_TYPE ] := SetRiskType( aPlatInfo[ RISK_TYPE_DESC ], aRiskTypes )

	If Empty( aPlatInfo[ RISK_CLIENT_ID ] )
		lValid := .F.
		cMsg := STR0058     //"Informe o ID do cliente de conexão."
	ElseIf Empty( aPlatInfo[ RISK_CLIENT_SECRET ] )
		lValid := .F.
		cMsg := STR0059     //"Informe a senha do cliente para conexão."
	ElseIf Empty( aPlatInfo[ CAROL_URL ] )
		lValid := .F.
		cMsg := STR0060     //"Informe a URL da Carol."
	ElseIf Empty( aPlatInfo[ PLATFORM_URL_RISK] )
		lValid := .F.
		cMsg := STR0061     //"Informe a URL da plataforma Risk."
	ElseIf Empty( aPlatInfo[ PLATFORM_URL_FMSCASH] )
		lValid := .F.
		cMsg := STR0062     //"Informe a URL da plataforma Antecipa."
	Endif

	If !lValid
		ApMsgAlert( cMsg )
	Else
		// somente para tirar os espaços do array
		For nLen := 1 to len( aPlatInfo )
			If nLen <> RISK_TYPE
				aPlatInfo[ nLen ] := Alltrim( aPlatInfo[ nLen ] )
			EndIf
		Next

		lValid := ChkPlatRisk( aPlatInfo )
		lValid := lValid .And. ChkPlatAntecipa( @aPlatInfo, @oAntecipa )
		lValid := lValid .And. CheckCarol( @aPlatInfo, oAntecipa )
	EndIf
Return lValid


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetRiskType
Função de seta o tipo de uso da plataforma

@param cSearch, caracter, descrição do uso da plataforma
@param aRiskTypes, array, vetor com os tipos de uso do Risk

@return number, Identificação do tipo de uso, sendo
    1 - Interno e Mais Negócios
    2 - Mais Negócios ( default )
    3 - Interno
@author  Marcia Junko
@since   29/07/2020
/*/
//-------------------------------------------------------------------------------------
Static Function SetRiskType( cSearch, aRiskTypes )
	Local nRiskType := 2
	Local nPosType := 0

	nPosType := Ascan( aRiskTypes, {|x| x == cSearch } )
	Do Case
	Case nPosType == 1
		nRiskType := 2
	Case nPosType == 2
		nRiskType := 1
	Case nPosType == 3
		nRiskType := 3
	EndCase
Return nRiskType

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetRiskType
Função que pesquisa o tipo de uso da plataforma

@param nRiskType, number, conteúdo salvo no parâmetro MV_RISKTIP
@param aRiskTypes, array, vetor com os tipos de uso da plataforma RISK

@return caracter, Texto selecionado no combobox.
@author  Marcia Junko
@since   29/07/2020
/*/
//-------------------------------------------------------------------------------------
Static Function GetRiskType( nRiskType, aRiskTypes )
	Local cRiskType := STR0003  //'Mais Negócios'

	Do Case
	Case nRiskType == 1
		cRiskType := STR0004    //'Interno e Mais Negócios'
	Case nRiskType == 2
		cRiskType := STR0003    //'Mais Negócios'
	Case nRiskType == 3
		cRiskType := STR0005    //'Interno'
	EndCase
Return cRiskType

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeStep6
Função de montagem dos componentes da aba - dados da plataforma Pós Faturamento

@param oPanel, object, Painel onde os componentes serão criado
@param oStatus, object, Painel onde serão mostrados as etapas de gravação.

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function MakeStep6( oPanel, oStatus )
	Local cStatus
	Local aStatus := {}
	Local oBtnPanel := TPanel():New( 0, 0, "", oPanel, , , , , , 40, 40, .T., .T. )
	Local oFont

	oBtnPanel:Align := CONTROL_ALIGN_ALLCLIENT

	DEFINE FONT oFont NAME "Courier New" SIZE 10, 0

	@ 15, 35 LISTBOX oStatus VAR cStatus ITEMS aStatus SIZE 250, 140 OF oBtnPanel PIXEL  FONT oFont

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SaveConfig
Função de montagem dos componentes da aba - dados da plataforma Pós Faturamento

@param oStatus, object, Painel onde serão mostrados as etapas de gravação.
@param cUser, caracter, nome do usuário
@param cPsw, caracter, senha
@param aCompany, array, vetor com a lista de empresas para executar a instalação
@param aSM0, array, vetor com todas as filiais do SIGAMAT
@param aWizParam, array, vetor com as informarções mostradas no Wizard. 
@param cPosClientID, caracter, Client ID de conexão com a plataforma Antecipa
@param cPosSecretID, caracter, Secret ID de conexão com a plataforma Antecipa
@param oAntecipa, object, objeto de validação da plataforma do Antecipa

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function SaveConfig( oStatus, cUser, cPsw, aCompany, aSM0, aWizParam, cPosClientID, cPosSecretID, oAntecipa )
	Local nCompany  := 0
	Local lSave  	:= .T.
	Local nQtdAtual := 0

	For nCompany := 1 to Len( aCompany )
		If aCompany[ nCompany ][1]
			nQtdAtual++
			IF nCompany > 1
				oStatus:Add( Replicate( '-', 50 ) )
			EndIF

			oStatus:Add( Padr( Dtoc( MsDate() ), 14 ) + Padr( Time(), 10 ) + ' - ' + STR0063 + ' - ' + aCompany[ nCompany ][2] )    //"Conectando ambiente"
			// Abre o ambiente
			OpenEnvironment( cUser, cPsw, aCompany[ nCompany ][2], aCompany[ nCompany ][1] )    // Usuario # Senha # Codigo Empresa # Selecionada
			If lSave
				// Salva as informações da plataforma - Antecipa
				oStatus:Add( Padr( Dtoc( MsDate() ), 14 ) + Padr( Time(), 10 ) + ' - ' + STR0064 )  //'Salvando dados da plataforma - Pós Faturamento'
				SaveAntecipa( aWizParam[ OFFBALANCE ], oAntecipa )
				lSave := .F.

				// Grava o Job de integração do RISK na tabela do Schedule
				oStatus:Add( Padr( Dtoc( MsDate() ), 14 ) + Padr( Time(), 10 ) + ' - ' + STR0065 )  //'Criando JOB no Schedule'
				SaveSchedule( aCompany )
			EndIf

			// Cria o registro do cliente de integração com a Supplier
			oStatus:Add( Padr( Dtoc( MsDate() ), 14 ) + Padr( Time(), 10 ) + ' - ' + STR0066 )  //'Criando dados para integração'
			SaveEntity( oStatus, aSM0,  aWizParam )

			// Cria os parâmetros de integração com o RISK
			oStatus:Add( Padr( Dtoc( MsDate() ), 14 ) + Padr( Time(), 10 ) + ' - ' + STR0067 )  //'Criando parâmetros de integração'
			SaveParameters( , aWizParam[ OFFBALANCE ] )

			// Integra os parâmetros do Protheus na plataforma
			oStatus:Add( Padr( Dtoc( MsDate() ), 14 ) + Padr( Time(), 10 ) + ' - ' + STR0068 )  //'Integra os parâmetros do Protheus na plataforma'
			SyncCarolSX6( oStatus, aWizParam[ OFFBALANCE ] )

			// Cria cadastros necessários para baixa Protheus.
			oStatus:Add( Padr( Dtoc( MsDate() ), 14 ) + Padr( Time(), 10 ) + ' - ' + STR0069 + aWizParam[ BILLING ][2])  //'Criando cadastros de baixa - Carteira: '
			RskIncMOtBX()

			oStatus:Add( Padr( Dtoc( MsDate() ), 14 ) + Padr( Time(), 10 ) + ' - ' + STR0070 + ' - ' + aCompany[ nCompany ][2] )    //'Ambiente encerrado'
			oStatus:Add( '' )

			RpcClearEnv()
		EndIf
	NEXT

	oStatus:Add( Padr( Dtoc( MsDate() ), 14 ) + Padr( Time(), 10 ) + ' - ' + STR0071 )  //'Configurações finalizadas'
	oStatus:Refresh()
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} OpenEnvironment
Função de abertura do ambiente e habilitação da empresa para o sincronismo com a plataforma.

@param cUser, caracter, nome do usuário
@param cPsw, caracter, senha
@param cCompany, caracter, empresa onde o ambiente será aberto
@param lSelected, boolean, indica se o registro está selecionado ou não.

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function OpenEnvironment( cUser, cPsw, cCompany, lSelected)
	OpenSM0( cCompany )

	ConnectComp( cCompany, SM0->M0_CODFIL, cUser, cPsw )

	// Habilitando a empresa para o sincronismo
	AdjCarolComp( cCompany, lSelected )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} AdjCarolComp
Função que atribui se a empresa deve ser sincronizada na Carol, dependendo se ela está
ou não selecionada no Wizard. 
Somente empresas selecionadas devem ser sincronizadas.

@param cCompany, caracter, nome do usuário
@param lSelected, boolean, indica se o registro está selecionado ou não.

@author  Marcia Junko
@since   16/07/2021
/*/
//-------------------------------------------------------------------------------------
Static Function AdjCarolComp( cCompany, lSelected )
	Local oParam
	Local cSelected := ''

	Default lSelected := .T.

	If lSelected
		cSelected := "true"
	else
		cSelected := "false"
	EndIf

	oParam := FwAppParam():New()
	oParam:Put( "FWCarolCompany" + cCompany, cSelected )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ConnectComp
Função auxliar para abertura do ambiente.

@param cCompany, caracter, empresa onde o ambiente será aberto
@param cBranch, caracter, filial onde o ambiente será aberto
@param cUser, caracter, nome do usuário
@param cPsw, caracter, senha

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function ConnectComp( cCompany, cBranch, cUser, cPsw )
	Local lRet      := .T.

	Default cUser   := ''
	Default cPsw    := ''

	SuperGetMV()
	RPCSetType( 3 )
	IF !Empty( cUser )
		lRet := RpcSetEnv( cCompany, cBranch, cUser, cPsw )
	else
		lRet := RpcSetEnv( cCompany, cBranch )
	EndIf
	oApp:cInternet := Nil
	__cInternet := NIL
	lMsHelpAuto := .F.
Return lRet


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SaveAntecipa
Função que grava os dados de conexão com o Antecipa

@param aOffBalance, array, vetor com as informarções de conexão da plataforma
@param oAntecipa, object, objeto de validação da plataforma do Antecipa

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function SaveAntecipa( aOffBalance, oAntecipa )
	Local oConfig
	Local aSvAlias := GetArea()

	oConfig := FWTFConfig()

	oConfig := JsonObject():New()
	oConfig[ "platform-clientId" ] := aOffBalance[ RISK_CLIENT_ID ]
	oConfig[ "platform-secret"   ] := aOffBalance[ RISK_CLIENT_SECRET ]
	oConfig[ "platform-endpoint" ] := aOffBalance[ PLATFORM_URL_FMSCASH ]
	oConfig[ "platform-tenantid" ] := aOffBalance[ TENANT ]
	oConfig[ "carol-connectorId" ] := aOffBalance[ CAROL_CONNID ]
	oConfig[ "carol-apiToken" ]    := aOffBalance[ CAROL_TOKEN ]
	oConfig[ "carol-endpoint" ]    := aOffBalance[ CAROL_URL ]
	oConfig[ "rac-endpoint" ]      := aOffBalance[ RAC_URL ]
	FwTFSetConfig( oConfig )

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FreeObj( oConfig )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SaveSchedule
Função que grava os JOBs no Schedule
@param aCompany, array, vetor com a lista de empresas ( selecionadas ou não )

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function SaveSchedule( aCompany )
	Local aJobs       := {'FWTECHFINJOB', 'RSKJOBCOMMAND', 'RSKJobBank'}
	Local aSchdComp   := {}
	Local aSM0        := {}
	Local aSvAlias    := GetArea()
	Local cAgend      := ""
	Local cExecComp   := ""
	Local cRecurrence := ""
	Local cStatus     := ""
	Local cTaskID     := ""
	Local cTime       := ""
	Local nAux        := 0
	Local nItem       := 1
	Local oDASchedule := Nil
	Local oSched      := Nil

	// Monta lista de empresas\filiais para execução do agendamento
	aSM0 := FWLoadSM0()
	For nItem := 1 To Len( aCompany )
		IF aCompany[ nItem ][1]
			nAux := Ascan( aSM0, {|x| x[1] == aCompany[ nItem ][2] } )
			cExecComp += aSM0[ nAux ][1] + "/" + aSM0[ nAux ][2] + ";"
		EndIf
	Next

	For nItem := 1 To Len( aJobs )
		cRecurrence := 'A'
		cTime       := '00:00'
		cStatus     := SCHD_ACTIVE

		If aJobs[ nItem ] == "RSKJOBCOMMAND"
			cRecurrence := "D(Each(.T.);Day(1);EveryDay(.F.););Execs(288 );Interval(00:05);Discard;"
		ElseIf aJobs[ nItem ] == "RSKJobBank"
			cRecurrence := "D(Each(.T.);Day(1);EveryDay(.F.););Execs(1   );Interval(00:00);Discard;"
			cTime := '22:00'
		EndIf

		cTaskID := FwSchdByFunction( aJobs[ nItem ] )
		If !Empty( cTaskID )
			oDASchedule := FWDASchedule():New()
			oSched      := oDASchedule:getSchedule( cTaskID )
			cRecurrence := oSched:getPeriod()
			cTime       := oSched:getTime()
			cStatus     := oSched:getStatus()

			FWDelSchedule( cTaskID )
		EndIf

		cAgend := FwInsSchedule( aJobs[ nItem ], __cUserID, , cRecurrence, cTime, Upper( GetEnvServer() ), cExecComp, cStatus, Date(), 5, NIL )
		If Empty( cAgend ) .Or. Empty( FWSchdEmpFil( cAgend ) )
			FwLogMsg("INFO",, "RSKWIZARD", FunName(), "", "01", I18N( STR0093, { aJobs[ nItem ] } ), 0, 0, {}) //"Houve um problema na criação do schedule #1 de integração do TOTVS Mais Negócios."
		EndIf
	Next

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FWFreeArray( aJobs )
	FWFreeArray( aSM0 )
	FWFreeArray( aSchdComp )

	FwFreeObj( oDASchedule )
	FwFreeObj( oSched )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SaveEntity
Função que grava as entidades relacionados aos parâmetros e dispara a gravação dos 
parâmetros por filial.

@param oStatus, object, Painel onde serão mostrados as etapas de gravação.
@param aSM0, array, vetor com todas as filiais do SIGAMAT
@param aWizParam, array, vetor com as informarções mostradas no Wizard. 

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function SaveEntity( oStatus, aSM0, aWizParam, lAutomato )
	Local aSvAlias := GetArea()
	Local aSX6 := {}
	Local aParam := {}
	Local aModel := {}
	Local aItemsSX6 := {}
	Local aWhere := {}
	Local nEmp := 0
	Local nFields := 0
	Local nSizeFilial := 0
	Local cCompExec := ''
	Local cBranchExec := ''
	Local cClientExec := ''
	Local cNewClient := ''
	Local cLastClient := ''
	Local cNewProvider := ''
	Local cLastProvider := ''
	Local cNewBank := ''
	Local cLastBank := ''
	Local cNewBilling := ''
	Local cLastBilling := ''
	Local cContent := ''
	Local cFindBranch := ''
	Local cProviderExec := ''
	Local cBankExec := ''
	Local cBillingExec := ''
	Local cAuxBranch := ''
	Local lUnique := .T.
	Local lContinue := .T.
	Local lFind := .T.
	Local lDiference := .F.
	Local nElem
	Local cSeek := ''
	Local cParamContent := ''
	Local cSeekAlias  := ''
	Local cNewBranch  := ''
	Local cParameter  := ''
	Local lExecute    := .F.
	
	Default lAutomato := .F.

	cCompExec     := cEmpAnt
	cBranchExec   := cFilAnt
	cClientExec   := aWizParam[ CLIENT ][ ENT_CODE ]
	cProviderExec := aWizParam[ PROVIDER ][ ENT_CODE ]
	cBankExec     := aWizParam[ BANK ][ ENT_CODE]
	cBillingExec  := aWizParam[ BILLING ][ ENT_CODE ]

	If Empty( aWizParam[ CLIENT ][ ENT_MODEL ] )
		aWizParam[ CLIENT ][ ENT_MODEL ] := GetModel( CLIENT, aWizParam[ CLIENT ] )
	EndIf

	If Empty( aWizParam[ PROVIDER ][ ENT_MODEL ] )
		aWizParam[ PROVIDER ][ ENT_MODEL ] := GetModel( PROVIDER, aWizParam[ PROVIDER ] )
	EndIf

	If Empty( aWizParam[ BANK ][ ENT_MODEL ] )
		aWizParam[ BANK ][ ENT_MODEL ] := GetModel( BANK, aWizParam[ BANK ] )
	EndIf

	If Empty( aWizParam[ BILLING ][ ENT_MODEL ] )
		aWizParam[ BILLING ][ ENT_MODEL ] := GetModel( BILLING, aWizParam[ BILLING ] )
	EndIf

	cLastClient   := ''
	cLastProvider := ''
	cLastBank     := ''
	cLastBilling  := ''

	For nEmp := 1 to len( aSM0 )
		cNewClient   := FwxFilial( "SA1", aSM0[ nEmp ][2], FWModeAccess('SA1',1), FWModeAccess('SA1',2), FWModeAccess('SA1',3))
		cNewProvider := FwxFilial( "SA2", aSM0[ nEmp ][2], FWModeAccess('SA2',1), FWModeAccess('SA2',2), FWModeAccess('SA2',3))
		cNewBank     := FwxFilial( "SA6", aSM0[ nEmp ][2], FWModeAccess('SA6',1), FWModeAccess('SA6',2), FWModeAccess('SA6',3))
		cNewBilling  := FwxFilial( "FRV", aSM0[ nEmp ][2], FWModeAccess('FRV',1), FWModeAccess('FRV',2), FWModeAccess('FRV',3))

		If aSM0[ nEmp ][1] == cCompExec
			nSizeFilial := FWSizeFilial( aSM0[ nEmp ][1] )

			IF cNewClient != cLastClient .or. cNewProvider != cLastProvider .or. cNewBank != cLastBank  .or. cNewBilling != cLastBilling
				lContinue := .T.

				RPCClearEnv()

				ConnectComp( aSM0[ nEmp ][1], aSM0[ nEmp ][2] )

				For nElem := 1 To 4
					lDiference  := .F.
					cNewBranch  := ''
					cLastBranch := ''
					aModel 		:= {}
					aWhere 		:= {}
					aElem 		:= aWizParam[ nElem ]
					aModel 		:= aElem[ ENT_MODEL ]

					If nElem == CLIENT
						lDiference := ( cNewClient != cLastClient )
						cNewBranch := cNewClient
						aWhere := { { 'A1_FILIAL', xFilial( 'SA1' ) }, { 'A1_COD', aElem[ ENT_CODE ] }, { 'A1_LOJA', aElem[ ENT_STORE ] } }
					Elseif nElem == PROVIDER
						lDiference := ( cNewProvider != cLastProvider )
						cNewBranch := cNewProvider
						aWhere := { { 'A2_FILIAL', xFilial( 'SA2' ) }, { 'A2_COD', aElem[ ENT_CODE ] }, { 'A2_LOJA', aElem[ ENT_STORE ] } }
					ElseIf nElem == BANK
						lDiference := ( cNewBank != cLastBank )
						cNewBranch := cNewBank
						aWhere := { { 'A6_FILIAL', xFilial( cSeekAlias ) }, { 'A6_COD', aElem[ ENT_CODE ] }, { 'A6_AGENCIA', aElem[ ENT_STORE ] }, {'A6_NUMCON', aElem[ ENT_DESC ] } }
					Else
						lDiference := ( cNewBilling != cLastBilling )
						cNewBranch := cNewBilling
						aWhere := { { 'FRV_FILIAL', xFilial( cSeekAlias ) }, { 'FRV_CODIGO', aElem[ ENT_CODE ] } }
					EndIf

					If lDiference
						lContinue  := .T.
						lUnique    := .T.
						cSeekAlias := aElem[ ENT_ALIAS ]
						cSeek 	   := aElem[ ENT_CODE ]

						If cSeekAlias != "FRV"
							cSeek += aElem[ ENT_STORE ]

							If cSeekAlias == "SA6"
								cSeek += aElem[ ENT_DESC ]
							EndIf
						ENDIF

						cParamContent := aElem[ ENT_CONTENT ]
						// Verifico se ja foi executado antes
						If Empty(cParamContent)
							cLastBranch := xFilial( cSeekAlias )
							if cSeekAlias == 'FRV'
								cContent := aElem[ ENT_CODE ]
							Elseif cSeekAlias == 'SA6'
								cContent := aElem[ ENT_CODE ] + '|' + aElem[ ENT_STORE ] + '|' + aElem[ ENT_DESC ]
							ELSE
								cContent := aElem[ ENT_CODE ] + '|' + aElem[ ENT_STORE ]
							ENDIF

							IF lUnique
								cFindBranch := Space( nSizeFilial )
							Else
								cFindBranch := cLastBranch
							EndIf
							If Ascan( aSX6, {|x| x[ ENT_BRANCH ] == cFindBranch .and. x[2] == aElem[ ENT_PARAMETER ] } ) > 0
								cParamContent := cContent
							EndIf
						EndIf

						DBSelectArea( cSeekAlias )
						DbSetOrder(1)

						IF Empty( cParamContent ) .or. !dbSeek( xFilial( cSeekAlias ) + cSeek )
							If !dbSeek( xFilial( cSeekAlias ) + cSeek ) .and. !dbSeek( cNewBranch + cSeek )
								If cSeekAlias <> 'FRV'
									If ValidaCadastro( nElem, cSeekAlias, cNewBranch, cSeek, oStatus )
										RecLock( cSeekAlias, .T.)
										For nFields := 1 To Len( aModel[2] )
											aFields := aModel[2][ nFields ]
											If '_FILIAL' $ aFields[1]
												FieldPut( FieldPos( aFields[1] ), cNewBranch )
											else
												FieldPut( FieldPos( aFields[1] ), aFields[2] )
											EndIf
										Next
										MsUnLock()
									EndIf
								Else
									FTFWGrvFRV( { aElem[ ENT_CODE ], aElem[ ENT_STORE ], "2", "2", "2", "1", "2", "2" } )
								EndIf
							ElseIf lExecute
								lUnique := .F.

								IF cSeekAlias != 'SA6'
									lFind := .T.
									aElem[ ENT_CODE ] := Subs( aElem[ ENT_CODE ], 1, len( aElem[ ENT_CODE ] ) - 1) + '0'

									While lFind
										aElem[2] := Padr( Soma1( aElem[ ENT_CODE ] ), len( aElem[ ENT_CODE ] ) )

										IF GetID( cSeekAlias, aWhere ) == 0
											lFind := .F.
										EndIf
									End

									IF cSeekAlias != "FRV"
										RecLock( cSeekAlias, .T. )
										For nFields := 1 To Len( aElem[ ENT_MODEL ][2] )
											aFields := aElem[ ENT_MODEL ][2][ nFields ]

											If '_FILIAL' $ aFields[1]
												FieldPut( FieldPos( aFields[1]), &( 'cNew' + aElem[ ENT_IDENT ] ) )
											ElseIf aFields[1] == ( SUBSTR( cSeekAlias, 2, 3 ) + '_COD' )
												FieldPut( FieldPos( aFields[1] ), aElem[ ENT_CODE ] )
											else
												FieldPut( FieldPos( aFields[1] ), aFields[2] )
											EndIf
										Next
										MSUnlock()
									else
										// Chama a função padrão do Wizard do Antecipa
										FTFWGrvFRV( { aElem[ ENT_CODE ], aElem[ ENT_STORE ], "2", "2", "2", "1", "2", "2" } )
										BlockFRVProcess( aElem[ ENT_CODE ] )
									EndIf
								ENDIF
							EndIf
						else
							If  cParamContent != aElem[ ENT_CODE ] + '|' + aElem[ ENT_STORE ] .And. Ascan( aSX6, {|x| x[1] == SX6->X6_FIL }) == 0
								If !lAutomato .And. !ApMsgYesNo( I18N( STR0072, { aElem[ ENT_PARAMETER ], aSM0[ nEmp ][2] } ) )  //"O parâmetro #1 já foi definido anteriormente para a filial #2. Deseja atualizá-lo?"
									lContinue := .F.
								else
									DBSelectArea( cSeekAlias )
									DbSetOrder(1)
									If !dbSeek( xFilial( cSeekAlias ) + aElem[ ENT_CODE ] + IIF( cSeekAlias $ "SA6|FRV", '', aElem[ ENT_STORE ]) )
										lUnique := .T.
									Else
										lUnique := .F.
									EndIf
								EndIf
							EndIf
						endif

						cLastBranch := xFilial( cSeekAlias )
						if cSeekAlias == 'FRV'
							cContent := aElem[ ENT_CODE ]
						Elseif cSeekAlias == 'SA6'
							cContent := aElem[ ENT_CODE ] + '|' + aElem[ ENT_STORE ] + '|' + aElem[ ENT_DESC ]
						ELSE
							cContent := aElem[ ENT_CODE ] + '|' + aElem[ ENT_STORE ]
						ENDIF

						If lContinue
							IF lUnique
								cFindBranch := Space( nSizeFilial )
							Else
								cFindBranch := cLastBranch
							EndIf
							If Ascan( aSX6, {|x| x[ ENT_BRANCH ] == cFindBranch .and. x[2] == aElem[ ENT_PARAMETER ] } ) == 0
								Aadd( aSX6, {  cFindBranch , aElem[ ENT_PARAMETER ], 'C', ;
									I18N( STR0077, { IIF( cSeekAlias == 'SA1', STR0073, IIF( cSeekAlias == 'SA2', STR0074, IIF( cSeekAlias == 'SA6', STR0075, STR0076 ) ) ) } ), ;
									'', cContent, cContent, cContent, 'S', 'S'} )   //"#1 utilizado para gerar contas a pagar para o parceiro Supplier."###'Cliente'###'Fornecedor'###'Banco'###'Situação'
							EndIf
						ENDIF
					EndIf
				NEXT
			Else
				for nElem := 1 to 4
					aElem := aWizParam[ nElem ]

					cParameter := aElem[ ENT_PARAMETER ]
					cSeekAlias := aElem[ ENT_ALIAS ]
					cAuxBranch := xFilial( cSeekAlias )

					If Ascan( aSX6, {|x| x[ ENT_BRANCH ] == cAuxBranch  .and. x[ ENT_CODE ] == cParameter } ) == 0
						if cSeekAlias == 'FRV'
							cContent := aElem[ ENT_CODE ]
						Elseif cSeekAlias == 'SA6'
							cContent := aElem[ ENT_CODE ] + '|' + aElem[ ENT_STORE ] + '|' + aElem[ ENT_DESC ]
						Else
							cContent := aElem[ ENT_CODE ] + '|' + aElem[ ENT_STORE ]
						ENDIF

						Aadd( aSX6, { cAuxBranch , cParameter, 'C', ;
							i18N( STR0077, { IIF( nElem == 1, STR0073, IIF( nElem == 2, STR0074, IIF( nElem == 3, STR0075, STR0076 ) ) ) } ), ;
							'',  cContent, cContent, cContent, 'S', 'S' } )     //"#1 utilizado para gerar contas a pagar para o parceiro Supplier."###'Cliente'###'Fornecedor'###'Banco'###'Situação'
					ENDIF
				Next
			ENDIF

			// Associa o cliente ao fornecedor
			RSKRlCusXSup( aSX6 )

			// Grava os dados da natureza TOTVS Mais Negócios
			CreateNature( oStatus, @aSX6, lAutomato )

			cLastClient   := FwxFilial( "SA1", aSM0[ nEmp ][2], FWModeAccess('SA1',1), FWModeAccess('SA1',2), FWModeAccess('SA1',3))
			cLastProvider := FwxFilial( "SA2", aSM0[ nEmp ][2], FWModeAccess('SA2',1), FWModeAccess('SA2',2), FWModeAccess('SA2',3))
			cLastBank     := FwxFilial( "SA6", aSM0[ nEmp ][2], FWModeAccess('SA6',1), FWModeAccess('SA6',2), FWModeAccess('SA6',3))
			cLastBilling  := FwxFilial( "FRV", aSM0[ nEmp ][2], FWModeAccess('FRV',1), FWModeAccess('FRV',2), FWModeAccess('FRV',3))
			lExecute      := .T.

		ElseIf lExecute

			cLastClient   := ''
			cLastProvider := ''
			cLastBank     := ''
			cLastBilling  := ''

		EndIF

		aWizParam[ CLIENT ][ ENT_CODE ] := cClientExec
		aWizParam[ PROVIDER ][ ENT_CODE ] := cProviderExec
		aWizParam[ BANK ][ ENT_CODE ] := cBankExec
		aWizParam[ BILLING ][ ENT_CODE ] := cBillingExec

		lUnique := .T.
	Next

	aItemsSX6 := ConsParameters( aSX6 )
	SaveParameters( aItemsSX6 )

	If ( cCompExec != cEmpAnt ) .OR. ( cBranchExec != cFilAnt )
		RPCClearEnv()
		ConnectComp( cCompExec, cBranchExec )
	EndIf

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FWFreeArray( aSX6 )
	FWFreeArray( aParam )
	FWFreeArray( aModel )
	FWFreeArray( aItemsSX6 )
	FWFreeArray( aWhere )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BlockFRVProcess
Função reponsável por ajustar as regras de bloqueio da situação de cobrança.

@param cSituation, caracter, Código da situação de cobrança
@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function BlockFRVProcess( cSituation )
	Local cProcess := '0001|0002|0003|0004|0007|0008|0009|0010'
	Local aSvAlias := GetArea()

	DBSelectArea( "FW2" )
	DbSetOrder(1)   //FW2_FILIAL+FW2_SITUAC+FW2_CODIGO

	IF FW2->( DbSeek( xFilial("FW2") + cSituation ) )
		While FW2->( !Eof() ) .And. FW2->FW2_SITUAC == cSituation
			IF !( FW2->FW2_CODIGO $ cProcess )
				Reclock( "FW2", .F. )
				DBDelete()
				MSUnlock()
			EndIf

			FW2->( DBSkip() )
		End
	EndIf

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ConsParameters
Função reponsável por avaliar o conteúdo dos parâmetros para não gravar os parâmetros
em duplicidade, caso o conteúdo seja o mesmo para todas as filiais.

@param aListParameters, array, lista com os parâmetros para validar o conteúdo
@return array, lista de parâmetros para gravar na SX6

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function ConsParameters( aListParameters )
	Local nItem := 0
	Local aItems := {}
	Local cParam := ''
	Local cContent := ''
	Local nPos := 0

	aSort( aListParameters, , , { |x,y| x[1] + x[2] < y[1] + y[2] } )
	For nItem := 1 to len( aListParameters )
		If ( nPos := Ascan( aItems, {|x| x[2] == aListParameters[ nItem ][2] }) ) == 0
			Aadd( aItems, aListParameters[ nItem ] )
		Else
			If aItems[ nPos ][7] != aListParameters[ nItem ][7]
				Aadd( aItems , aListParameters[ nItem ] )
			EndIf
		EndIf

		cParam := aListParameters[ nItem ][2]
		cContent := aListParameters[ nItem ][7]
	Next
Return aItems

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetModel
Esta função é responsável por retornar os dados padrões do parâmetro (caso não esteja 
preenchido) ou os dados existentes no banco de dados.

@param nType, number, identifica qual a entidade está sendo validada, onde:
    [1] - cliente
    [2] - fornecedor
    [3] - banco
    [4] - situação de cobrança
@param aArray, array, vetor com as informações da entidade

@return, array, contém os dados modelo para replicar nas outras empresas/filiais
    [1] - recno do registro
    [2] - vetor com as informações do registro.
@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function GetModel( nType, aArray )
	Local aStru := {}
	Local nFields := 0
	Local nRecno := 0
	Local aInfo := {}
	Local aSvAlias := {}
	Local xContent
	Local cField := ''
	Local cAlias := ''
	Local aWhere := ''

	aSvAlias := GetArea()

	cAlias := aArray[ ENT_ALIAS ]
	aStru :=  ( cAlias )->( DBStruct() )

	If nType == CLIENT
		aWhere := { { 'A1_FILIAL', aArray[ ENT_BRANCH ] }, { 'A1_COD', aArray[ ENT_CODE ] }, { 'A1_LOJA', aArray[ ENT_STORE ]} }
	ElseIf nType == PROVIDER
		aWhere := { { 'A2_FILIAL', aArray[ ENT_BRANCH ] }, { 'A2_COD', aArray[ ENT_CODE ] }, { 'A2_LOJA', aArray[ ENT_STORE ]} }
	ElseIf nType == BANK
		aWhere := { { 'A6_FILIAL', aArray[ ENT_BRANCH ] }, { 'A6_COD', aArray[ ENT_CODE ] }, { 'A6_AGENCIA', aArray[ ENT_STORE ]}, {'A6_NUMCON', aArray[ ENT_DESC ]} }
	ElseIf nType == BILLING
		aWhere := { { 'FRV_FILIAL', aArray[ ENT_BRANCH ] }, { 'FRV_CODIGO', aArray[ ENT_CODE ]} }
	EndIf

	nRecno := GetID( cAlias, aWhere )

	DBSelectArea( cAlias )
	DBGoto( nRecno )

	For nFields := 1 to len( aStru )
		cField := aStru[ nFields ][1]
		xContent := ( cAlias )->( FieldGet( FieldPos( aStru[ nFields ][1] ) ) )
		IF !Empty( xContent ) .And. !( cField $ "USERLGI|USERLGA" )
			aAdd( aInfo, { cField, xContent }  )
		EndIf
	Next

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FWFreeArray( aStru )
Return { nRecno, aInfo }

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetID
Esta função resgata o R_E_C_N_O_ do registro de acordo com a condição pesquisada.

@param cAlias, caracter, Alias da tabela a ser pesquisada
@param aWhere, array, vetor com os campos e condições do WHERE

@return, number, R_E_C_N_O_ do registro

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function GetID( cAlias, aWhere )
	Local aSvAlias := {}
	Local cQuery := ''
	Local cTempAlias := ''
	Local nItems := 0
	Local nRecno := 0

	aSvAlias := GetArea()

	cQuery := "SELECT R_E_C_N_O_ AS ID FROM " + RetSqlName( cAlias ) + " WHERE "

	For nItems := 1 to len( aWhere )
		If nItems != 1
			cQuery += " AND "
		EndIf
		cQuery += aWhere[ nItems ][1] + " = '" + aWhere[ nItems ][2] + "' "
	Next
	cQuery += " AND D_E_L_E_T_ = ' '"

	cTempAlias := MPSysOpenQuery( cQuery )

	if ( cTempAlias )->( !EOF() )
		nRecno := ( cTempAlias )->ID
	EndIf

	( cTempAlias )->( DbCloseArea() )

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
Return nRecno


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SaveParameters
Salva os parâmetros na base de dados.

@param aSX6, array, Lista de parâmetros a gravar
@param aOffBalance, array, vetor com as informarções de conexão da plataforma

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function SaveParameters( aSX6, aOffBalance )
	Local aStruct := { "X6_FIL", "X6_VAR", "X6_TIPO", "X6_DESCRIC", "X6_DESC1", "X6_DESC2", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG", "X6_PROPRI", "X6_PYME" }
	Local aSvAlias := GetArea()
	Local nTamSX6 := 0
	Local lFind    := .F.
	Local cEndpoint  := ''
	Local nParams := 0
	Local nFields := 0
	Local cCarolURL := ''
	Local cPlatform := ''
	Local cCarolConnID := ''
	Local cCarolAPIToken := ''
	Local cRiskType := ''
	Local cRacURL := ''
	Local cTenant := ''
	Local cClientID :=''
	Local cSecret := ''

	Default aSX6 := {}

	IF Empty( aSX6 )
		nTamSX6 := TamSX3( "A1_FILIAL" )[1]

		cEndpoint  := alltrim( aOffBalance[ PLATFORM_URL_RISK ] ) + '/entities'

		cCarolURL := aOffBalance[ CAROL_URL ]
		cPlatform := aOffBalance[ PLATFORM_URL_RISK ]
		cCarolConnID := aOffBalance[ CAROL_CONNID ]
		cCarolAPIToken := aOffBalance[ CAROL_TOKEN ]
		cRiskType := Alltrim( Str( aOffBalance[ RISK_TYPE ] ) )
		cRacURL := aOffBalance[ RAC_URL ]
		cTenant := aOffBalance[ TENANT ]
		cClientID := aOffBalance[ RISK_CLIENT_ID ]
		cSecret := aOffBalance[ RISK_CLIENT_SECRET ]

		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RISKAPI', 'C', STR0078, '', '', cEndpoint, cEndpoint, cEndpoint, 'S', 'S'} )    //'Informe a URL de integração com o Risk.'
		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RSKCURL', 'C', STR0079, '', '', cCarolURL, cCarolURL, cCarolURL, 'S', 'S'} )    //'Informe a URL da plataforma Carol com o Risk.'
		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RSKPLAT', 'C', STR0061, '', '', cPlatform, cPlatform, cPlatform, 'S', 'S'} )    //'Informe a URL da plataforma Risk.'
		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RSKCCID', 'C', STR0080, '', '', cCarolConnID, cCarolConnID, cCarolConnID, 'S', 'S'} )   //'Informe o Connector ID da Carol com o Risk.'
		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RSKCTOK', 'C', STR0081, '', '', cCarolAPIToken, cCarolAPIToken, cCarolAPIToken, 'S', 'S'} )     //'Informe o API Token da Carol com o Risk.'
		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RISKTIP', 'N', STR0082, '', '', cRiskType, cRiskType, cRiskType, 'S', 'S'} )    //'Define o tipo de integracao Risk.'
		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RSKRAC', 'C', STR0083, '', '', cRacURL, cRacURL, cRacURL, 'S', 'S'} )       //'Informe a URL do RAC utilizada no Risk.'
		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RSKTENA', 'C', STR0084, '', '', cTenant, cTenant, cTenant, 'S', 'S'} )      //'Informe o tenant utilizado no Risk.'
		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RSKCID', 'C', STR0085, '', '', cClientID, cClientID, cClientID, 'S', 'S'} ) //'Informe o Client ID para acessar o Mais Negócios'
		Aadd( aSX6, { Space( nTamSX6 ), 'MV_RSKSID', 'C', STR0086, '', '', cSecret, cSecret, cSecret, 'S', 'S'} )       //'Informe o Secret para acessar o Mais Negócios'
	EndIf

	dbSelectArea( "SX6" )
	dbSetOrder(1)
	For nParams := 1 To Len( aSX6 )
		If !Empty( aSX6[ nParams ][2] )
			If !dbSeek( aSX6[ nParams, 1] + aSX6[ nParams, 2] )
				lFind := .F.
			Else
				lFind := .T.
			EndIf

			RecLock( "SX6", !lFind )
			For nFields := 1 To Len( aSX6[ nParams ] )
				If !Empty( FieldName( FieldPos( aStruct[ nFields ] ) ) )
					IF !lFind .Or. "X6_CONT" $ aStruct[ nFields ]
						FieldPut( FieldPos( aStruct[ nFields ] ), AllTrim(aSX6[ nParams, nFields]) )
					EndIf
				EndIf
			Next
			MsUnLock()
		EndIf
	Next

	RestArea( aSvAlias )

	FwFreeArray( aSvAlias )
	FWFreeArray( aSX6 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCompany
Monta um vetor com as empresas disponíveis no sistema e já traz a empresa
selecionada, caso o Wizard já tenha sido executado anteriormente.

@param aSm0 - vetor com toda a estrutura do SIGAMAT (referência)
@return array, vetor com as empresas para execução do Wizard.

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------
Static Function LoadCompany( aSM0 )
	Local aCompany := {}
	Local oParam
	Local nItem := 0
	Local cContent := ''

	SET DELET ON

	OpenSM0()
	aSM0 := FWLoadSM0()

	aEval( FWAllGrpCompany(), {|oComp| AAdd( aCompany, { .F., oComp, FWEmpName( oComp ) }) } )

	oParam := FwAppParam():New()
	For nItem := 1 to len( aCompany )
		cContent := oParam:Get( "FWCarolCompany" + aCompany[ nItem ][2] )

		If cContent == 'true'
			aCompany[ nItem ][1] := .T.
		EndIf
	Next
Return aCompany

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SyncCarolSX6
Esta função é responsável por sincronizar alguns parâmetros do Protheus com a Carol.

@param oStatus, object, Painel onde serão mostrados as etapas de gravação.
@param aOffBalance, array, vetor com as informarções de conexão da plataforma

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function SyncCarolSX6( oStatus, aOffBalance )
	Local aSvAlias      := GetArea()
	Local aHeader       := {}
	Local oRestClient   := Nil
	Local nSM0          := 0
	Local nParam        := 0
	Local nLenItem      := 0
	Local aJsonItem     := {}
	Local aSM0Data      := {}
	Local aParameters   := { "MV_RISCOB", "MV_RISCOC", "MV_RISCOD", "MV_PEDIDOA", "MV_PEDIDOB", "MV_PEDIDOC", "MV_RISKTIP", "MV_1DUP" }
	Local cPath         := ''
	Local cParameters   := ''
	Local cBranch       := ''
	Local cContent      := ''
	Local cCarolConnID  := ''
	Local cCarolAPIToken := ''
	Local cCarolURL     := ''

	cCarolURL := aOFFBalance[ CAROL_URL ]
	cCarolConnID := aOFFBalance[ CAROL_CONNID ]
	cCarolAPIToken := aOFFBalance[ CAROL_TOKEN ]
	cPath := "/v2/staging/intake/parameters?connectorId=" + cCarolConnID + "&returnData=false"

	AAdd( aHeader, "Content-Type: application/json" )
	AAdd( aHeader, "Accept: application/json" )
	AAdd( aHeader, "X-Auth-Key: "          + cCarolAPIToken )
	AAdd( aHeader, "X-Auth-ConnectorId: "  + cCarolConnID )
	AAdd( aHeader, "User-Agent: Protheus " + GetBuild() )

	aSM0Data    := FWLoadSM0()
	oJson       := JsonObject():New()

	DBSelectArea( "SX6" )
	DBSetOrder(1)
	For nSM0 := 1 To Len( aSM0Data )
		If aSM0Data[ nSM0 ][1] == cEmpAnt
			For nParam := 1 To Len( aParameters )
				cParameters := aParameters[ nParam ]

				AAdd( aJsonItem, JsonObject():New())
				nLenItem := Len( aJsonItem )

				If DBSeek( aSM0Data[ nSM0 ][2] + cParameters )
					cBranch := aSM0Data[ nSM0 ][2]
					cContent := SuperGetMv( cParameters, .F., , cBranch )
				Else
					cBranch := Space( FWSizeFilial() )
					cContent := SuperGetMv( cParameters , .F. )
				EndIf

				aJsonItem[ nLenItem ][ "protheus_pk" ] := cEmpAnt + "|" + cParameters
				aJsonItem[ nLenItem ][ "branch" ]      := cBranch
				aJsonItem[ nLenItem ][ "content" ]     := cContent
				aJsonItem[ nLenItem ][ "parameter" ]   := cParameters
			Next
		EndIf
	Next

	oJson:Set( aJsonItem )
	cJson := EncodeUTF8( oJson:ToJson() )

	oRestClient := FWRest():New( cCarolURL )
	oRestClient:SetPath( cPath )
	oRestClient:SetPostParams( cJson )

	If oRestClient:Post( aHeader )
		oStatus:Add( Padr( Dtoc( MsDate() ), 14) + Padr( Time(), 10 ) + ' - ' + STR0087 )   //"Parâmetros enviados com sucesso para a plataforma."
	Else
		oStatus:Add( Padr( Dtoc( MsDate() ), 14) + Padr( Time(), 10 ) + ' - ' + STR0088 )    //'A T E N Ç Ã O - Ocorreu erro no envio dos parâmetros para a plataforma.'
	EndIf

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FWFreeArray( aHeader )
	FWFreeArray( aJsonItem )
	FWFreeArray( aSM0Data )
	FWFreeArray( aParameters )
	FreeObj( oRestClient )
	FreeObj( oJson )
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKRlCusXSup
Esta função associa o fornecedor Suplier ao cliente Supplier de acordo com o conteúdo
que será gravado no parâmetro.

@param aSX6, array, vetor com os parâmetros que serão gravados pelo Wizard.

@author  Marcia Junko
@since   24/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function RSKRlCusXSup( aSX6 )
	Local aSvAlias := GetArea()
	Local aProvider := {}
	Local aClient := {}
	Local aWhere := {}
	Local cBranchProvider := ''
	Local cBranchClient := ''
	Local nProvider := 0
	Local nClient := 0
	Local nRecClient := 0
	Local nRecProvider := 0

	cBranchProvider := xFilial( "SA2" )
	cBranchClient := xFilial( "SA1" )

	nProvider := Ascan( aSX6, {|x| x[1] == cBranchProvider .And. x[2] == "MV_RSKFPAY" } )
	If nProvider == 0
		nProvider := Ascan( aSX6, {|x| Empty( x[1] ) .And. x[2] == "MV_RSKFPAY" } )
	EndIf

	If nProvider > 0
		nClient := Ascan( aSX6, {|x| x[1] == cBranchClient .And. x[2] == "MV_RSKCPAY" } )
		If nClient == 0
			nClient := Ascan( aSX6, {|x| Empty( x[1] ) .And. x[2] == "MV_RSKCPAY" } )
		EndIf

		aProvider := StrTokArr( aSX6[ nProvider ][7], '|' )
		If !Empty( aProvider )
			aWhere := { { 'A2_FILIAL', cBranchProvider }, { 'A2_COD', aProvider[1] }, { 'A2_LOJA', aProvider[2] } }
			nRecProvider := GetID( 'SA2', aWhere )

			If nRecProvider > 0
				SA2->( DbGoTo( nRecProvider) )
				aClient := StrTokArr( aSX6[ nClient ][7], '|' )
				If !Empty( aClient )
					aWhere := { { 'A1_FILIAL', cBranchClient }, { 'A1_COD', aClient[1] }, { 'A1_LOJA', aClient[2] } }
					nRecClient := GetID( 'SA1', aWhere )

					If nRecClient > 0
						RecLock("SA2", .F.)
						SA2->A2_CLIENTE := aClient[1]
						SA2->A2_LOJCLI := aClient[2]
						MSUnlock()
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FWFreeArray( aProvider )
	FWFreeArray( aClient )
	FWFreeArray( aWhere )
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskVldDic
Valida se o dicionario de dados está atualizado.

@return Logico, Verdadeiro se o dicionario está atualizado.
@author Squad NT TechFin
@since  08/09/2020
/*/
//-------------------------------------------------------------------------------------
Static Function RskVldDic()
	Local lRet := .T.

	DBSelectArea( "SX2" )
	DBSetOrder(1)

	If SX2->( DBSeek( "AGA" ) ) .And. Empty( SX2->X2_UNICO )
		lRet := .F.
	EndIf

	If lRet
		If SX2->( DBSeek( "AGB" ) ) .And. Empty( SX2->X2_UNICO )
			lRet := .F.
		EndIf
	EndIf

	If lRet
		DBSelectArea( "SX3" )
		DBSetOrder(2)
		If !SX3->( DBSeek( "AR0_FILNFS" ) )
			lRet := .F.
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskIncMOtBX
Inclui o motivo de baixa que será utilizado no +Negocios.

@return Logico, Verdadeiro se for incluído.
@author Squad NT TechFin
@since  08/09/2020
/*/
//-------------------------------------------------------------------------------------
Static Function RskIncMOtBX()
	Local aSvAlias := GetArea()
	Local aCampos := {}
	Local aMotBaixas := {}
	Local lRet  := .T.
	Local cFile	:= "SIGAADV.MOT"

	// Executa a função de leitura das baixas para forçar a criação do arquivo, caso não exista.
	aMotBaixas := ReadMotBx()

	aCampos:={	{"SIGLA"	, "C", 03, 0 },;
		{"DESCR"	, "C", 10, 0 },;
		{"CARTEIRA"	, "C", 01, 0 },;
		{"MOVBANC"	, "C", 01, 0 },;
		{"COMIS"	, "C", 01, 0 },;
		{"CHEQUE"	, "C", 01, 0 },;
		{"ESPECIE"	, "C", 01, 0 }	}

	_oFINA4901 := FWTemporaryTable():New( "cArqTmp" )
	_oFINA4901:SetFields( aCampos )
	_oFINA4901:Create()

	cAlias := "cArqTmp"
	dbSelectArea( cAlias )

	APPEND FROM &cFile SDF
	dbGoTop()

	while CARQTMP->( !EOF() )
		if CARQTMP->SIGLA == 'OFF'
			lRet := .F.
			exit
		ENDIF

		CARQTMP->( dbSkip() )
	END

	IF ( lRet )

		lRet := .F.

		BEGIN TRANSACTION
			RecLock( cAlias , .T. )
			CARQTMP->Sigla    := "OFF"
			CARQTMP->Descr    := "+NEGOCIOS "
			CARQTMP->Carteira := "A"
			CARQTMP->MovBanC  := "N"
			CARQTMP->Comis    := "N"
			CARQTMP->Cheque   := "N"
			CARQTMP->Especie  := "N"
			MsUnLock()

			dbSelectArea( "cArqTmp" )
			FERASE( cFile )
			Copy to &cFile SDF

			lRet := .T.
		END TRANSACTION
	Endif

	RestArea( aSvAlias )

	FWFreeArray( aCampos )
	FWFreeArray( aSvAlias )
	FWFreeArray( aMotBaixas )
RETURN lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CreateNature
Esta função é reponsável por chamar a criação da natureza do TOTVS Mais Negócios 
na tabela SED via Wizard.

@param oStatus, object, Painel onde serão mostrados as etapas de gravação.

@author  Marcia Junko
@since   04/12/2020
/*/
//-------------------------------------------------------------------------------------
Static Function CreateNature( oStatus, aSX6, lAutomato )
	Local cMessage := ''
	Local cContent := ''
	Local cBranch  := ''
	Local nSizeBranch := 0

	Default lAutomato := .F.

	cBranch := xFilial( "SED" )
	nSizeBranch := FWSizeFilial()

	cContent := RskSeekNature( INCOME_NATURE, @cMessage )
	If !lAutomato .And. !Empty( cMessage )
		oStatus:Add( Padr( Dtoc( MsDate() ), 14) + Padr( Time(), 10 ) + ' - ' + STR0089 )    //'A T E N Ç Ã O - Ocorreu um erro na gravação da natureza de receita do TOTVS Mais Negócios.'
	EndIf

	cMessage := ''
	cContent := RskSeekNature( EXPENSE_NATURE, @cMessage )
	If !lAutomato .And. !Empty( cMessage )
		oStatus:Add( Padr( Dtoc( MsDate() ), 14) + Padr( Time(), 10 ) + ' - ' + STR0090 )    //'A T E N Ç Ã O - Ocorreu um erro na gravação da natureza de despesa do TOTVS Mais Negócios.'
	EndIf
Return

/*/{Protheus.doc} ValidCart
	Verifia se carteira R esta disponivel, caso esta esteja em uso sugere um nova carteira.
	@type  Static Function
	@author Lucas Silva Vieira
	@since 07/07/2022
	@return cCarteira, Character, numero da carteira 
/*/
Static Function ValidCart() As Character
	Local cCodCart      As Character
	Local cCartParam    As Character
	Local cCarteira 	As Character
	Local aAreaFRV		As Array
	Local nTamFRV	    As Numeric

	cCarteira 	:= 'R'
	cCartParam  := SuperGetMV("MV_RSKSNCC",.F.,"")
	nTamFRV		:= TamSX3( "FRV_CODIGO" )[1]
	cCodCart    := Replicate( "0", nTamFRV )
	aAreaFRV	:= FRV->( GetArea() )

	If (Empty(cCartParam))
		FRV->(dbSetOrder(1))
		If FRV->(MsSeek( xFilial( "FRV" ) + cCarteira))
			cCodCart := SubStr(cCodCart, 1, nTamFRV)
			While cCodCart != SubStr(Replicate("Z", nTamFRV), 1, nTamFRV)
				If FRV->(MsSeek( xFilial( "FRV" ) + cCodCart))
					cCodCart := Soma1(cCodCart)
				Else
					cCarteira := cCodCart
					Exit
				EndIf
			EndDo
		Endif
	Else
		cCarteira := cCartParam
	Endif
	RestArea( aAreaFRV )
	FWFreeArray( aAreaFRV )

Return cCarteira

/*/
	{Protheus.doc} MenuDef
	Menu funcional da rotina de cadastros (Cliente, Fornecedor e Banco)
	@type  Static Function
	@author Daniel Moda
	@since 19/07/2022
	@return aRotina, Array, Opções do Menu
/*/
Static Function MenuDef() As Array

Local aRotina As Array

aRotina := {{"Selecionar" ,"RskWizSel",0, 6, 0, Nil},; //"Selecionar"
			{"Visualizar" ,"AxVisual" ,0, 2, 0, Nil}}  //"Visualizar"

Return aRotina

/*/
	{Protheus.doc} RskWizSel
	Botão chamado quando é selecionado um cadastro no Mbrowse
	@type  Function
	@author Daniel Moda
	@since 19/07/2022
	@return Nil
/*/
Function RskWizSel()

Local oBrowseCad As Object

oBrowseCad := GetObjBrow()

lAtuCad := .T.
oBrowseCad:oBrowse:oWnd:End()

Return Nil

/*/
	{Protheus.doc} ValidaCadastro
	(long_description)
	@type  Static Function
	@author user
	@since 21/07/2022
	@version version
	@param nElem, Numeric, tipo de cadastro que será validado
	@param cSeekAlias, Character, alias do cadastro
	@param cNewBranch, Character, filial do cadastro
	@param cSeek, Character, índice do cadastro
	@param oStatus, Object, status do processamento
	@return lRetConsulta, Logical, retorna se a pesquisa encontrou o registro
/*/
Static Function ValidaCadastro( nElem As Numeric, cSeekAlias As Character, cNewBranch As Character, cSeek As Character, oStatus As Object ) As Logical

Local aCadOriginal As Array
Local aAreaBkp     As Array
Local cCamposPesq  As Character
Local cCnpjSup	   As Character
Local lRetConsulta As Logical
Local lValidOk	   As Logical

aCadOriginal := LoadParamInfo(nElem, .F.)
lRetConsulta := .F.
lValidOk	 := .F.
aAreaBkp     := ( cSeekAlias )->( GetArea() )

If nElem == 3
	If cSeek <> aCadOriginal[ ENT_CODE ] + aCadOriginal[ ENT_STORE ] + aCadOriginal[ ENT_DESC ]
		lValidOk := .T.
	EndIf
Else
	If cSeek <> aCadOriginal[ENT_CODE] + aCadOriginal[ENT_STORE]
		lValidOk := .T.
	EndIf
EndIf

If lValidOk
	If nElem == 1 .Or. nElem == 2
		cCamposPesq  := IIf( nElem == 1 ,'A1_COD+A1_LOJA', 'A2_COD+A2_LOJA')
		cCnpjSup	 := '06951711000128'
		DBSelectArea( cSeekAlias )	
		DbSetOrder(3)
		If ( cSeekAlias )->( MsSeek( xFilial( cSeekAlias ) + cCnpjSup ))
			oStatus:Add( Padr( Dtoc( MsDate() ), 14) + Padr( Time(), 10 ) + I18N( STR0097, { cSeekAlias, ( cSeekAlias )->&(cCamposPesq) } ) ) // " - A T E N Ç Ã O - TABELA #1 - CNPJ encontrado no Codigo/Loja - #2"
		Else
			oStatus:Add( Padr( Dtoc( MsDate() ), 14) + Padr( Time(), 10 ) + I18N( STR0098, { cSeekAlias, cNewBranch } ) ) // " - A T E N Ç Ã O - TABELA #1 - Codigo não encontrado - FILIAL #2"
		EndIf
	Else
		oStatus:Add( Padr( Dtoc( MsDate() ), 14) + Padr( Time(), 10 ) + I18N( STR0098, { cSeekAlias, cNewBranch } ) ) // " - A T E N Ç Ã O - TABELA #1 - Codigo não encontrado - FILIAL #2"
	EndIf
Else
	lRetConsulta := .T.
EndIf

RestArea(aAreaBkp)

FwFreeArray(aCadOriginal)
FwFreeArray(aAreaBkp)

Return lRetConsulta
