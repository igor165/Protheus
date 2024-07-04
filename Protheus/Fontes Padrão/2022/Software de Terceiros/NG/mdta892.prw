#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "MDTA892.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA892
Wizard de Configura��o de Par�metros do SIGAMDT

@sample	MDTA892()

@author	Luis Fellipy Bett
@since	04/03/2021

@return	Nil, Sempre Nulo
/*/
//---------------------------------------------------------------------
Function MDTA892()

	//Vari�veis de controle
	Local aRetRad
	Local lConfirm
	Local nOpcPar

    //Caso esteja logado pelo SIGAMDT
    If AmIIn( 35 )

		// "Selecione quais par�metros ser�o configurados:" // "eSocial" // "EPI's"
		aRetRad := MDTPopUp(;
			STR0001 + ":",;
			{ STR0003, STR0002 },;
			1.2; // Multiplicador do tamanho
		)

		//Salva o retorno nas vari�veis
		lConfirm := aRetRad[ 1 ]
		nOpcPar := aRetRad[ 2 ]

		//Caso a tela foi confirmada
		If lConfirm

			//Chama a fun��o de cria��o do wizard de acordo com
			fCrtWizPar( nOpcPar )

		EndIf

    EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCrtWizPar
Cria o wizard de configura��o dos par�metros do sistema de acordo
com as respostas do usu�rio �s perguntas apresentadas

@sample fCrtWizPar( 1 )

@param	nOpcPar, Num�rico, Indica quais os par�metros que ser�o apresentados ao usu�rio

@author Luis Fellipy Bett
@since  15/03/2021

@return Nil, Sempre Nulo
/*/
//---------------------------------------------------------------------
Static Function fCrtWizPar( nOpcPar )

	//Vari�veis de cria��o do Wizard
	Local oDlg
	Local oNewPag
	Local oPanelBkg
	Local oStepWiz := Nil

	//Vari�veis contadoras
	Local nQtdStp := 0
	Local nCont	:= 0

	Private oFontG := TFont():New( , , -20, .T. )
	Private oFontM := TFont():New( , , -15, .T. )
	Private oFontP := TFont():New( , , -14, .T. )
	Private aParams := {}
	Private aParAux := {}

	//---------------------------------------------------------------
	// Vari�veis utilizadas para salvar o conte�do de cada par�metro
	//---------------------------------------------------------------
	//Par�metros do eSocial
	Private cNG2ESOC := SuperGetMv( "MV_NG2ESOC", .F., "2" )
	Private cMID	 := cValToChar( SuperGetMv( "MV_MID", .F., .F. ) )
	Private dNG2DTES := SuperGetMv( "MV_NG2DTES", .F., SToD( "20211013" ) )
	Private cNG2AVIS := SuperGetMv( "MV_NG2AVIS", .F., "1" )
	Private cNG2NENV := Padr( SuperGetMv( "MV_NG2NENV", .F., "" ), 150 )
	Private cNG2IATE := SuperGetMv( "MV_NG2IATE", .F., "2" )
	Private cNG2RASO := SuperGetMv( "MV_NG2RASO", .F., "2" )
	Private cNG2INDR := SuperGetMv( "MV_NG2INDR", .F., "1" )
	Private cNG2TDES := SuperGetMv( "MV_NG2TDES", .F., "1" )
	Private cNG2RIST := SuperGetMv( "MV_NG2RIST", .F., "3" )
	Private cNG2VLAU := SuperGetMv( "MV_NG2VLAU", .F., "2" )
	Private cNG2EPIR := SuperGetMv( "MV_NG2EPIR", .F., "1" )
	Private cNG2REST := SuperGetMv( "MV_NG2REST", .F., "1" )
	Private cNG2EAMB := SuperGetMv( "MV_NG2EAMB", .F., "1" )
	Private cNG2TPAG := SuperGetMv( "MV_NG2TPAG", .F., "1" )
	Private cNG2RAMB := SuperGetMv( "MV_NG2RAMB", .F., "1" )
	Private cNG2VEVP := SuperGetMv( "MV_NG2VEVP", .F., "2" )
	Private dNG2DENO := SuperGetMv( "MV_NG2DENO", .F., SToD( "20211013" ) )
	Private cMDTENRE := cValToChar( SuperGetMv( 'MV_MDTENRE', .F., .T. ) )

	//Par�metros dos EPI's
	Private cNGMDTES := SuperGetMv( "MV_NGMDTES", .F., "N" )
	Private cLOCALIZ := SuperGetMv( "MV_LOCALIZ", .F., "N" )
	Private cRASTRO	 := SuperGetMv( "MV_RASTRO", .F., "N" )
	Private cESTNEG	 := SuperGetMv( "MV_ESTNEG", .F., "N" )
	Private cNG2SA	 := SuperGetMv( "MV_NG2SA", .F., "N" )
	Private cNG2EPDU := SuperGetMv( "MV_NG2EPDU", .F., "0" )
	Private cNG2INTE := SuperGetMv( "MV_NG2INTE", .F., "1" )
	Private cMDTPEPI := Padr( SuperGetMv( "MV_MDTPEPI", .F., "" ), 150 )
	Private cARQPROD := Padr( SuperGetMv( "MV_ARQPROD", .F., "SB1" ), 150 )
	Private cMDTEPID := SuperGetMv( "MV_MDTEPID", .F., "N" )
	Private cNG2EPIB := SuperGetMv( "MV_NG2EPIB", .F., "1" )
	Private cNG2BIOM := SuperGetMv( "MV_NG2BIOM", .F., "2" )
	Private cDEVBIOM := StrTran( SuperGetMv( "MV_DEVBIOM", .F., "2" ), '"', '' ) // Remove as aspas do conte�do
	Private cNGFORPD := SuperGetMv( "MV_NGFORPD", .F., "" )
	Private cNG2RECI := StrTran( SuperGetMv( "MV_NG2RECI", .F., "1" ), '"', '' ) // Remove as aspas do conte�do
	Private cNGEPIEN := SuperGetMv( "MV_NGEPIEN", .F., "N"  )
	Private dDBLQMOV := SuperGetMv( "MV_DBLQMOV", .F., SToD( "" ) )
	Private dULMES	 := SuperGetMv( "MV_ULMES", .F., SToD( "" ) )
	Private cMDTEPIV := cValToChar( SuperGetMV( "MV_MDTEPIV", .F., 3 ) )

	//--------------------------------------------------------------------------------------
	//Adiciona os par�metros a serem configurados no array de acordo com a chamada da rotina
	//--------------------------------------------------------------------------------------
	If nOpcPar == 1 //Par�metros do eSocial
		fParamEPI()
	EndIf

	//Par�metros dos EPI's
	If nOpcPar == 2
		fParamEsoc()
	EndIf

	//Copia array dos par�metros para um auxiliar
	aParAux := aClone( aParams )

	//Calcula a quantidade de steps necess�rios, considerando 5 perguntas em cada tela do Wizard
	nQtdStp := Ceiling( Len( aParams ) / 5 )

	//Define a dialog do wizard
	Define Dialog oDlg Style nOr( WS_POPUP, WS_VISIBLE ) Pixel

		//Define o tamanho do wizard
		oDlg:nWidth := 800
		oDlg:nHeight := 640

		//Define o painel
		oPanelBkg := TPanel():New( 10, 50, "", oDlg, , , , , , 300, 300 )

		//Cria o wizard
		oStepWiz:= FWWizardControl():New( oPanelBkg, { 600, 600 } )

		//Ativa os passos na parte superior da tela
		oStepWiz:ActiveUISteps()

		//-----------------------------
		// Pagina Inicial - Introdu��o
		//-----------------------------
		oNewPag := oStepWiz:AddStep( "1", { | oPanel | fCriaPgIni( oPanel, nOpcPar ) } )

		//Altera a descri��o do step
		oNewPag:SetStepDescription( STR0004 ) //"Configura��o de Par�metros"

		//Define o bloco ao clicar no bot�o Cancelar
		oNewPag:SetCancelAction( { || oDlg:End() } )

		//------------------------------------------
		// P�gina(s) de Configura��o dos Par�metros
		//------------------------------------------
		For nCont := 1 To nQtdStp

			//Adiciona uma nova p�gina
			oNewPag := oStepWiz:AddStep( cValToChar( nCont + 1 ), { | oPanel | fCriaPgPar( oPanel, nOpcPar ) } )

			//Altera a descri��o do step
			oNewPag:SetStepDescription( STR0005 ) //"Par�metros"

			//Define o bloco ao clicar no bot�o Voltar
			oNewPag:SetPrevTitle( STR0006 ) //"Voltar"

			//Define o bloco ao clicar no bot�o Cancelar
			oNewPag:SetCancelAction( { || oDlg:End() } )

		Next nCont

		//----------------------------
		// Pagina Final - Confirma��o
		//----------------------------
		oNewPag := oStepWiz:AddStep( cValToChar( nCont + 1 ), { | oPanel | fCriaPgFim( oPanel ) } )

		//Altera a descri��o do step
		oNewPag:SetStepDescription( STR0007 ) //"Confirma��o"

		//Define o bloco ao clicar no bot�o Concluir
		oNewPag:SetNextAction( { || fSaveParam( nOpcPar ), oDlg:End() } )

		//Define o bloco ao clicar no bot�o Cancelar
		oNewPag:SetCancelAction( {|| oDlg:End() } )

		//Ativa o Wizard
		oStepWiz:Activate()

	Activate Dialog oDlg Center

	//Destr�i o Wizard
	oStepWiz:Destroy()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fCriaPgIni
Constru��o da p�gina inicial do Wizard

@return	Nil, Sempre Nulo

@param	oPanel, Objeto, Painel em que a p�gina ser� criada
@param	nOpcPar, Num�rico, Indica para quais par�metros a configura��o foi chamada

@sample	fCriaPgIni( oPanel, 1 )

@author	Luis Fellipy Bett
@since	04/03/2021
/*/
//---------------------------------------------------------------------
Static Function fCriaPgIni( oPanel, nOpcPar )

	Local oSay
	Local cStrCompl := ""

	If nOpcPar == 1 //Caso for configura��o de par�metros do eSocial
		cStrCompl := STR0010 //"do eSocial"
	ElseIf nOpcPar == 2 //Caso for configura��o de par�metros dos EPI's
		cStrCompl := STR0009 //"dos EPI's"
	EndIf

	oSay := TSay():New( 80, 30, { || STR0008 + " " + cStrCompl }, oPanel, , oFontG, , , , .T., , , 250, 30 ) //"Bem Vindo ao Wizard de Configura��o de Par�metros"
	oSay:SetTextAlign( 2, 2 )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fCriaPgPar
Constru��o da(s) p�gina(s) de configura��o dos par�metros do Wizard

@return	Nil, Sempre Nulo

@param	oPanel, Objeto, Painel em que a p�gina ser� criada
@param	nOpcPar, Num�rico, Indica para quais par�metros a configura��o foi chamada

@sample	fCriaPgPar( oPanel )

@author	Luis Fellipy Bett
@since	04/03/2021
/*/
//---------------------------------------------------------------------
Static Function fCriaPgPar( oPanel, nOpcPar )

	Local nPosReg	:= 0
	Local nPosOpc	:= 0
	Local nCtrlReg	:= 1
	Local aItems	:= {}

	//Vari�veis dos objetos das mensagens
	Local oSayNG2ESOC
	Local oSayMID
	Local oSayNG2DTES
	Local oSayNG2AVIS
	Local oSayNG2NENV
	Local oSayNG2IATE
	Local oSayNG2RASO
	Local oSayNG2INDR
	Local oSayNG2TDES
	Local oSayNG2RIST
	Local oSayNG2VLAU
	Local oSayNG2EPIR
	Local oSayNG2REST
	Local oSayNG2EAMB
	Local oSayNG2TPAG
	Local oSayNG2RAMB
	Local oSayNG2VEVP
	Local oSayNG2DENO
	Local oSayNGMDTES
	Local oSayLOCALIZ
	Local oSayRASTRO
	Local oSayESTNEG
	Local oSayNG2SA
	Local oSayNG2EPDU
	Local oSayNG2INTE
	Local oSayMDTPEPI
	Local oSayARQPROD
	Local oSayMDTEPID
	Local oSayNG2EPIB
	Local oSayNG2BIOM
	Local oSayDEVBIOM
	Local oSayNGFORPD
	Local oSayNG2RECI
	Local oSayNGEPIEN
	Local oSayDBLQMOV
	Local oSayULMES
	Local oSayMDTEPIV
	Local oSayMDTENRE

	//Vari�veis dos objetos de capta��o dos valores
	Local oCboNG2ESOC
	Local oCboMID
	Local oGetNG2DTES
	Local oCboNG2AVIS
	Local oGetNG2NENV
	Local oCboNG2IATE
	Local oCboNG2RASO
	Local oCboNG2INDR
	Local oCboNG2TDES
	Local oCboNG2RIST
	Local oCboNG2VLAU
	Local oCboNG2EPIR
	Local oCboNG2REST
	Local oCboNG2EAMB
	Local oCboNG2TPAG
	Local oCboNG2RAMB
	Local oCboNG2VEVP
	Local oGetNG2DENO
	Local oCboNGMDTES
	Local oCboLOCALIZ
	Local oCboRASTRO
	Local oCboESTNEG
	Local oCboNG2SA
	Local oCboNG2EPDU
	Local oCboNG2INTE
	Local oGetMDTPEPI
	Local oGetARQPROD
	Local oCboMDTEPID
	Local oCboNG2EPIB
	Local oCboNG2BIOM
	Local oCboDEVBIOM
	Local oGetNGFORPD
	Local oCboNG2RECI
	Local oCboNGEPIEN
	Local oGetDBLQMOV
	Local oGetULMES
	Local oCboMDTEPIV
	Local oCboMDTENRE

	//-------------------------------------------------------
	//Cria mensagens e op��es de escolha para cada par�metro
	//-------------------------------------------------------
	
	//Par�metros do eSocial
	If nOpcPar == 2

		//Par�metro MV_NG2ESOC
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2ESOC" } ) ) > 0

			oSayNG2ESOC := TSay():New( 30 * nCtrlReg, 20, { || STR0014 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Deseja habilitar a integra��o com o eSocial?"

			aItems	 := { "1- " + STR0015, "2- " + STR0016 } //Op��es: 1- Sim/2- N�o
			nPosOpc	 := aScan( aItems, { |x| cNG2ESOC $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2ESOC := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2ESOC := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2ESOC := u, cNG2ESOC ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2ESOC' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_MID
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_MID" } ) ) > 0

			oSayMID := TSay():New( 30 * nCtrlReg, 20, { || STR0017 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "O envio ao Governo ser� atrav�s do Middleware? Caso definido como '.F.' o envio ser� pelo SIGATAF"

			aItems	 := { ".T.- " + STR0015, ".F.- " + STR0016 } //Op��es: .T.- Sim/.F.- N�o
			nPosOpc	 := aScan( aItems, { |x| cMID $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cMID := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboMID := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cMID := u, cMID ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cMID' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2DTES
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2DTES" } ) ) > 0

			oSayNG2DTES := TSay():New( 30 * nCtrlReg, 20, { || STR0018 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Qual a data inicial de obrigatoriedade de envio dos eventos de SST ao eSocial?"

			oGetNG2DTES := TGet():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, dNG2DTES := u, dNG2DTES ) }, oPanel, 060, 010, "@D", , 0, 16777215, , .F., , .T., , .F., , .F., .F., , .F., .F., , "dNG2DTES", , , , .T. )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2AVIS
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2AVIS" } ) ) > 0

			oSayNG2AVIS := TSay():New( 30 * nCtrlReg, 20, { || STR0019 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Caso ocorra inconsist�ncias na integra��o com o Governo, o que o sistema deve fazer?"

			aItems	 := { "0- " + STR0020, "1- " + STR0021, "2- " + STR0022 } //Op��es: 0- Avisar/1- Avisar e impedir o processo/2- N�o avisar
			nPosOpc	 := aScan( aItems, { |x| cNG2AVIS $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2AVIS := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2AVIS := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2AVIS := u, cNG2AVIS ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2AVIS' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf
		
		//Par�metro MV_NG2NENV
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2NENV" } ) ) > 0

			oSayNG2NENV := TSay():New( 30 * nCtrlReg, 20, { || STR0023 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Quais categorias de funcion�rios n�o dever�o ter os eventos de SST enviados ao SIGATAF/Middleware?"

			oGetNG2NENV := TGet():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2NENV := u, cNG2NENV ) }, oPanel, 060, 010, "@!", , 0, 16777215, , .F., , .T., , .F., , .F., .F., , .F., .F., , "cNG2NENV", , , , .T. )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2IATE
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2IATE" } ) ) > 0

			oSayNG2IATE := TSay():New( 30 * nCtrlReg, 20, { || STR0024 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Qual documento deve ser considerado para envio das informa��es do atendimento m�dico no evento S-2210?"

			aItems	 := { "1- " + STR0025, "2- " + STR0026, "3- " + STR0027 } //Op��es: 1- Diagn�stico/2- Atestado/3- Mais recente
			nPosOpc	 := aScan( aItems, { |x| cNG2IATE $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2IATE := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2IATE := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2IATE := u, cNG2IATE ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2IATE' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2RASO
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2RASO" } ) ) > 0

			oSayNG2RASO := TSay():New( 30 * nCtrlReg, 20, { || STR0028 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Na gera��o do ASO, como deve-se enviar a op��o 'Apto com restri��o' ao Governo?"

			aItems	 := { "1- " + STR0029, "2- " + STR0030 } //Op��es: 1- Apto/2- Inapto
			nPosOpc	 := aScan( aItems, { |x| cNG2RASO $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2RASO := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2RASO := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2RASO := u, cNG2RASO ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2RASO' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2INDR
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2INDR" } ) ) > 0

			oSayNG2INDR := TSay():New( 30 * nCtrlReg, 20, { || STR0031 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Na comunica��o do evento S-2220 ao Governo a tag <indResult> ser� enviada?"

			aItems	 := { "1- " + STR0015, "2- " + STR0016 } //Op��es: 1- Sim/2- N�o
			nPosOpc	 := aScan( aItems, { |x| cNG2INDR $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2INDR := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2INDR := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2INDR := u, cNG2INDR ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2INDR' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2TDES
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2TDES" } ) ) > 0

			oSayNG2TDES := TSay():New( 30 * nCtrlReg, 20, { || STR0032 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Qual descri��o de atividades dever� ser considerada no envio do evento S-2240 ao Governo?"

			aItems	 := { "1- " + STR0033, "2- " + STR0034, "3- " + STR0035, "4- " + STR0034 + " + " + STR0033 } //Op��es: 1- Tarefa/2- Cargo/3- Fun��o/4- Cargo + Tarefa
			nPosOpc	 := aScan( aItems, { |x| cNG2TDES $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2TDES := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2TDES := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2TDES := u, cNG2TDES ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2TDES' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2RIST
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2RIST" } ) ) > 0

			oSayNG2RIST := TSay():New( 30 * nCtrlReg, 20, { || STR0036 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Quais riscos, al�m dos obrigat�rios, ser�o tamb�m enviados ao Governo?"

			aItems	 := { "0- " + STR0037, "1- " + STR0038, "2- " + STR0039, "3- " + STR0040, "4- " + STR0041, "5- " + STR0042 } //Op��es: 0- Nenhum/1- Ergon�micos/2- Mec�nicos/Acidente/3- Ergo/Mec/Acid/4- Perigosos/5- Todos
			nPosOpc	 := aScan( aItems, { |x| cNG2RIST $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2RIST := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2RIST := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2RIST := u, cNG2RIST ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2RIST' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2VLAU
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2VLAU" } ) ) > 0

			oSayNG2VLAU := TSay():New( 30 * nCtrlReg, 20, { || STR0043 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Dever�o ser enviados ao Governo apenas os riscos vinculados a um Laudo PPRA?"

			aItems	 := { "1- " + STR0015, "2- " + STR0016 } //Op��es: 1- Sim/2- N�o
			nPosOpc	 := aScan( aItems, { |x| cNG2VLAU $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2VLAU := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2VLAU := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2VLAU := u, cNG2VLAU ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2VLAU' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2EPIR
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2EPIR" } ) ) > 0

			oSayNG2EPIR := TSay():New( 30 * nCtrlReg, 20, { || STR0044 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "As caracter�sticas dos EPI's ser�o buscadas da entrega do EPI ou do cadastro do Risco?"

			aItems	 := { "1- " + STR0045, "2- " + STR0046 } //Op��es: 1- Entrega/2- Risco
			nPosOpc	 := aScan( aItems, { |x| cNG2EPIR $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2EPIR := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2EPIR := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2EPIR := u, cNG2EPIR ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2EPIR' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2REST
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2REST" } ) ) > 0

			oSayNG2REST := TSay():New( 30 * nCtrlReg, 20, { || STR0047 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Qual tipo de respons�vel ambiental ser� enviado ao Governo?"

			aItems	 := { "1- " + STR0048, "2- " + STR0049, "3- " + STR0050, "4- " + STR0042 } //Op��es: 1- M�dico Trab./2- Engenheiro Trab./3- Ambos/4- Todos
			nPosOpc	 := aScan( aItems, { |x| cNG2REST $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2REST := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2REST := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2REST := u, cNG2REST ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2REST' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2EAMB
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2EAMB" } ) ) > 0

			oSayNG2EAMB := TSay():New( 30 * nCtrlReg, 20, { || STR0051 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Qual entidade ser� vinculada ao ambiente para envio das informa��es da tag <infoAmb>?"

			aItems	 := { "1- " + STR0052, "2- " + STR0053, "3- " + STR0035, "4- " + STR0033, "5- " + STR0054 } //Op��es: 1- Centro de Custo/2- Departamento/ 3- Fun��o/4- Tarefa/5- Funcion�rio
			nPosOpc	 := aScan( aItems, { |x| cNG2EAMB $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2EAMB := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2EAMB := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2EAMB := u, cNG2EAMB ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2EAMB' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2TPAG
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2TPAG" } ) ) > 0

			oSayNG2TPAG := TSay():New( 30 * nCtrlReg, 20, { || STR0055 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "A qualifica��o do agente (quantitativo/qualitativo) ser� buscada do cadastro de agentes ou de riscos?"

			aItems	 := { "1- " + STR0056, "2- " + STR0057 } //Op��es: 1- Agentes/2- Riscos
			nPosOpc	 := aScan( aItems, { |x| cNG2TPAG $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2TPAG := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2TPAG := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2TPAG := u, cNG2TPAG ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2TPAG' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2RAMB
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2RAMB" } ) ) > 0

			oSayNG2RAMB := TSay():New( 30 * nCtrlReg, 20, { || STR0058 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Ser�o enviados todos os respons�veis ambientais ou apenas os vinculados aos laudos relacionados aos riscos?"

			aItems	 := { "1- " + STR0042, "2- " + STR0059 } //Op��es: 1- Todos/2- Vinculados
			nPosOpc	 := aScan( aItems, { |x| cNG2RAMB $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2RAMB := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2RAMB := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2RAMB := u, cNG2RAMB ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2RAMB' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2VEVP
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2VEVP" } ) ) > 0

			oSayNG2VEVP := TSay():New( 30 * nCtrlReg, 20, { || STR0060 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Os eventos predecessores (S-1005/S-2190/S-2200/S-2300) dever�o ser validados no envio dos eventos de SST?"

			aItems	 := { "1- " + STR0015, "2- " + STR0016 } //Op��es: 1- Sim/2- N�o
			nPosOpc	 := aScan( aItems, { |x| cNG2VEVP $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2VEVP := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2VEVP := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2VEVP := u, cNG2VEVP ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2VEVP' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2DENO
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2DENO" } ) ) > 0

			oSayNG2DENO := TSay():New( 30 * nCtrlReg, 20, { || STR0061 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Qual a data inicial de envio dos eventos n�o obrigat�rios (S-2220/S-2240) para funcion�rios n�o expostos a risco?"

			oGetNG2DENO := TGet():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, dNG2DENO := u, dNG2DENO ) }, oPanel, 060, 010, "@D", , 0, 16777215, , .F., , .T., , .F., , .F., .F., , .F., .F., , "dNG2DENO", , , , .T. )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_MDTENRE
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { | x | x[ 1 ] == 'MV_MDTENRE' } ) ) > 0

			// "Indica se deve gerar o evento S-2240 na rescis�o."
			oSayMDTENRE := TSay():New( 30 * nCtrlReg, 20, { || STR0087 }, oPanel, Nil, oFontP, Nil, Nil, Nil, .T., Nil, Nil, 200, 20 )

			aItems := { '.T. - ' + STR0015, '.F. - ' + STR0016 } //Op��es: .T.- Sim/.F.- N�o
			nPosOpc := aScan( aItems, { | x | cMDTENRE $ x } )
			cMDTENRE := aItems[ nPosOpc ]

			oCboMDTENRE := TComboBox():New( 30 * nCtrlReg, 230, { | u | IIf( PCount() > 0, cMDTENRE := u, cMDTENRE ) }, aItems, 50, 20, oPanel, Nil, { || }, Nil, Nil, Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, 'cMDTENRE' )

			nCtrlReg++
			aDel( aParAux, nPosReg )
			aSize( aParAux, Len( aParAux ) - 1 )

		EndIf

	EndIf

	//Par�metros dos EPI's
	If nOpcPar == 1

		//Par�metro MV_NGMDTES
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NGMDTES" } ) ) > 0

			oSayNGMDTES := TSay():New( 30 * nCtrlReg, 20, { || STR0062 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Deseja habilitar a integra��o com o m�dulo de estoque (SIGAEST)?"

			aItems	 := { "S- " + STR0015, "N- " + STR0016 } //Op��es: S- Sim/N- N�o
			nPosOpc	 := aScan( aItems, { |x| cNGMDTES $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNGMDTES := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNGMDTES := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNGMDTES := u, cNGMDTES ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNGMDTES' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_LOCALIZ
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_LOCALIZ" } ) ) > 0

			oSayLOCALIZ := TSay():New( 30 * nCtrlReg, 20, { || STR0063 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Deseja habilitar o controle por localiza��o f�sica?"

			aItems	 := { "S- " + STR0015, "N- " + STR0016 } //Op��es: S- Sim/N- N�o
			nPosOpc	 := aScan( aItems, { |x| cLOCALIZ $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cLOCALIZ := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboLOCALIZ := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cLOCALIZ := u, cLOCALIZ ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cLOCALIZ' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_RASTRO
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_RASTRO" } ) ) > 0

			oSayRASTRO := TSay():New( 30 * nCtrlReg, 20, { || STR0064 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Deseja habilitar o controle por rastreabilidade dos lotes de produ��o?"

			aItems	 := { "S- " + STR0015, "N- " + STR0016 } //Op��es: S- Sim/N- N�o
			nPosOpc	 := aScan( aItems, { |x| cRASTRO $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cRASTRO := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboRASTRO := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cRASTRO := u, cRASTRO ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cRASTRO' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_ESTNEG
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_ESTNEG" } ) ) > 0

			oSayESTNEG := TSay():New( 30 * nCtrlReg, 20, { || STR0065 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Os saldos em estoque dos EPI's poder�o ficar negativos atrav�s de movimenta��es?"

			aItems	 := { "S- " + STR0015, "N- " + STR0016 } //Op��es: S- Sim/N- N�o
			nPosOpc	 := aScan( aItems, { |x| cESTNEG $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cESTNEG := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboESTNEG := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cESTNEG := u, cESTNEG ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cESTNEG' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2SA
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2SA" } ) ) > 0

			oSayNG2SA := TSay():New( 30 * nCtrlReg, 20, { || STR0066 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "A entrega de EPI ir� gerar solicita��o ao armaz�m?"

			aItems	 := { "S- " + STR0015, "N- " + STR0016 } //Op��es: S- Sim/N- N�o
			nPosOpc	 := aScan( aItems, { |x| cNG2SA $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2SA := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2SA := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2SA := u, cNG2SA ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2SA' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf
		
		//Par�metro MV_NG2EPDU
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2EPDU" } ) ) > 0

			oSayNG2EPDU := TSay():New( 30 * nCtrlReg, 20, { || STR0067 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Ao entregar um EPI vencido o sistema dever� emitir um alerta?"

			aItems	 := { "0- " + STR0016, "1- " + STR0068, "2- " + STR0069, "3- " + STR0042 } //Op��es: 0- Sim/1- EPI c/ devolu��o/2- EPI s/ devolu��o/ 3- Todos
			nPosOpc	 := aScan( aItems, { |x| cNG2EPDU $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2EPDU := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2EPDU := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2EPDU := u, cNG2EPDU ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2EPDU' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2INTE
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2INTE" } ) ) > 0

			oSayNG2INTE := TSay():New( 30 * nCtrlReg, 20, { || STR0070 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "O SIGAMDT ter� integra��o com outros produtos?"

			aItems	 := { "1- " + STR0016, "2- " + STR0071 } //Op��es: 1- N�o, 2- Logix
			nPosOpc	 := aScan( aItems, { |x| cNG2INTE $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2INTE := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2INTE := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2INTE := u, cNG2INTE ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2INTE' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_MDTPEPI
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_MDTPEPI" } ) ) > 0

			oSayMDTPEPI := TSay():New( 30 * nCtrlReg, 20, { || STR0072 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Que tipos de produtos ser�o considerados EPI's de acordo com a tabela 02 da tabela gen�rica SX5?"

			oGetMDTPEPI := TGet():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cMDTPEPI := u, cMDTPEPI ) }, oPanel, 060, 010, "@!", , 0, 16777215, , .F., , .T., , .F., , .F., .F., , .F., .F., , "cMDTPEPI", , , , .T. )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_ARQPROD
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_ARQPROD" } ) ) > 0

			oSayARQPROD := TSay():New( 30 * nCtrlReg, 20, { || STR0073 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Qual tabela ser� respons�vel por definir os produtos EPI's (SB1 ou SBZ)?"

			oGetARQPROD := TGet():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cARQPROD := u, cARQPROD ) }, oPanel, 060, 010, "@!", , 0, 16777215, , .F., , .T., , .F., , .F., .F., , .F., .F., , "cARQPROD", , , , .T. )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf
		
		//Par�metro MV_MDTEPID
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_MDTEPID" } ) ) > 0

			oSayMDTEPID := TSay():New( 30 * nCtrlReg, 20, { || STR0074 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Ao excluir uma entrega de EPI o sistema ir� solicitar a confirma��o da exclus�o?"

			aItems	 := { "S- " + STR0015, "N- " + STR0016 } //Op��es: S- Sim/N- N�o
			nPosOpc	 := aScan( aItems, { |x| cMDTEPID $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cMDTEPID := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboMDTEPID := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cMDTEPID := u, cMDTEPID ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cMDTEPID' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2EPIB
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2EPIB" } ) ) > 0

			oSayNG2EPIB := TSay():New( 30 * nCtrlReg, 20, { || STR0075 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Ap�s a impress�o do recibo de entrega do EPI o EPI dever� ficar bloqueado para edi��es?"

			aItems	 := { "1- " + STR0076, "2- " + STR0077 } //Op��es: 1- Bloqueia/2- N�o bloqueia
			nPosOpc	 := aScan( aItems, { |x| cNG2EPIB $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2EPIB := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2EPIB := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2EPIB := u, cNG2EPIB ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2EPIB' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2BIOM
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2BIOM" } ) ) > 0

			oSayNG2BIOM := TSay():New( 30 * nCtrlReg, 20, { || STR0078 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Ser� utilizada biometria na entrega de EPI?"

			aItems	 := { "1- " + STR0015, "2- " + STR0016 } //Op��es: 1- Sim/2- N�o
			nPosOpc	 := aScan( aItems, { |x| cNG2BIOM $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2BIOM := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2BIOM := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2BIOM := u, cNG2BIOM ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2BIOM' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_DEVBIOM
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_DEVBIOM" } ) ) > 0

			oSayDEVBIOM := TSay():New( 30 * nCtrlReg, 20, { || STR0079 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Ser� utilizada biometria na devolu��o de EPI?"

			aItems	 := { "1- " + STR0015, "2- " + STR0016 } //Op��es: 1- Sim/2- N�o
			nPosOpc	 := aScan( aItems, { |x| cDEVBIOM $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cDEVBIOM := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboDEVBIOM := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cDEVBIOM := u, cDEVBIOM ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cDEVBIOM' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NGFORPD
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NGFORPD" } ) ) > 0

			oSayNGFORPD := TSay():New( 30 * nCtrlReg, 20, { || STR0080 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Qual ser� o c�digo do fornecedor padr�o a ser utilizado na entrega de EPI's (informar c�digo + loja, Exemplo: 00000201)?"

			oGetNGFORPD := TGet():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNGFORPD := u, cNGFORPD ) }, oPanel, 060, 010, "@!", , 0, 16777215, , .F., , .T., , .F., , .F., .F., , .F., .F., , "cNGFORPD", , , , .T. )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NG2RECI
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NG2RECI" } ) ) > 0

			oSayNG2RECI := TSay():New( 30 * nCtrlReg, 20, { || STR0081 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Ao entregar um EPI o sistema dever� apresentar a sugest�o de impress�o do recibo de entrega do EPI?"

			aItems	 := { "1- " + STR0015, "2- " + STR0016 } //Op��es: 1- Sim/2- N�o
			nPosOpc	 := aScan( aItems, { |x| cNG2RECI $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNG2RECI := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNG2RECI := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNG2RECI := u, cNG2RECI ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNG2RECI' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_NGEPIEN
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_NGEPIEN" } ) ) > 0

			oSayNGEPIEN := TSay():New( 30 * nCtrlReg, 20, { || STR0082 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Ser� permitida a entrega de EPI's para funcion�rios que n�o estejam com situa��o ativa?"

			aItems	 := { "S- " + STR0015, "N- " + STR0016 } //Op��es: S- Sim/N- N�o
			nPosOpc	 := aScan( aItems, { |x| cNGEPIEN $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cNGEPIEN := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboNGEPIEN := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cNGEPIEN := u, cNGEPIEN ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cNGEPIEN' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_DBLQMOV
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_DBLQMOV" } ) ) > 0

			oSayDBLQMOV := TSay():New( 30 * nCtrlReg, 20, { || STR0083 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Data em que ser�o bloqueados os movimentos do estoque. Somente ser�o permitidos movimentos com data superior."

			oGetDBLQMOV := TGet():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, dDBLQMOV := u, dDBLQMOV ) }, oPanel, 060, 010, "@D", , 0, 16777215, , .F., , .T., , .F., , .F., .F., , .F., .F., , "dDBLQMOV", , , , .T. )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_ULMES
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_ULMES" } ) ) > 0

			oSayULMES := TSay():New( 30 * nCtrlReg, 20, { || STR0084 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "Data em que ser� definido o �ltimo fechamento do estoque."

			oGetULMES := TGet():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, dULMES := u, dULMES ) }, oPanel, 060, 010, "@D", , 0, 16777215, , .F., , .T., , .F., , .F., .F., , .F., .F., , "dULMES", , , , .T. )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

		//Par�metro MV_MDTEPIV
		If nCtrlReg <= 5 .And. ( nPosReg := aScan( aParAux, { |x| x[1] == "MV_MDTEPIV" } ) ) > 0

			oSayMDTEPIV := TSay():New( 30 * nCtrlReg, 20, { || STR0085 }, oPanel, , oFontP, , , , .T., , , 200, 20 ) //Define a mensagem do par�metro ## "EPI's vencidos poder�o ser entregues?"

			aItems	 := { "1- " + STR0015, "2- " + STR0016, "3- " + STR0086 } //Op��es: 1- Sim/2- N�o/3- Questionar
			nPosOpc	 := aScan( aItems, { |x| cMDTEPIV $ x } ) //Busca entre as op��es, a que est� no conte�do do par�metro atualmente
			cMDTEPIV := aItems[ nPosOpc ] //Define a op��o atual ou a padr�o

			oCboMDTEPIV := TComboBox():New( 30 * nCtrlReg, 230, { |u| IIf( PCount() > 0, cMDTEPIV := u, cMDTEPIV ) }, aItems, 50, 20, oPanel, , { || }, , , , .T., , , , , , , , , 'cMDTEPIV' )

			nCtrlReg++ //Incrementa contagem de registros
			aDel( aParAux, nPosReg ) //Deleta registro do array
			aSize( aParAux, Len( aParAux ) - 1 ) //Diminui a posi��o exclu�da do array

		EndIf

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fCriaPgFim
Constru��o da p�gina final do Wizard

@return Nil, Sempre Nulo

@param oPanel, Objeto, Painel em que a p�gina ser� criada

@sample fCriaPgFim( oPanel )

@author	Luis Fellipy Bett
@since	04/03/2021
/*/
//---------------------------------------------------------------------
Static Function fCriaPgFim( oPanel )

	//Vari�veis dos Says
	Local oSay1
	Local oSay2
	Local oSay3

	//Define os Says
	oSay1 := TSay():New( 30, 26, { || STR0011 }, oPanel, , oFontG, , , , .T., , , 250, 20 ) //"Aten��o"
	oSay2 := TSay():New( 60, 25, { || STR0012 }, oPanel, , oFontM, , , , .T., , , 250, 20 ) //"Deseja concluir a configura��o e salvar os par�metros?"
	oSay3 := TSay():New( 80, 20, { || STR0013 }, oPanel, , oFontM, , , , .T., , , 260, 20 ) //"Clique em 'Concluir' para salvar e finalizar ou 'Cancelar' para anular a opera��o"

	//Define o alinhamento centralizado dos Says
	oSay1:SetTextAlign( 2, 2 )
	oSay2:SetTextAlign( 2, 2 )
	oSay3:SetTextAlign( 2, 2 )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fSaveParam
Salva os par�metros de acordo com as escolhas do usu�rio

@return	Nil, Sempre nulo

@sample	fSaveParam( 1 )

@param	nOpcPar, Num�rico, Indica para quais par�metros a configura��o foi chamada

@author	Luis Fellipy Bett
@since	04/03/2021
/*/
//---------------------------------------------------------------------
Static Function fSaveParam( nOpcPar )

	//------------------------------------------------------
	//Salva os par�metros de acordo com a escolha do usu�rio
	//------------------------------------------------------
	
	//Par�metros do eSocial
	If nOpcPar == 2

		//Par�metro MV_NG2ESOC
		If aScan( aParams, { |x| x[1] == "MV_NG2ESOC" } ) > 0
			PUTMV( "MV_NG2ESOC", SubStr( cNG2ESOC, 1, 1 ) )
		EndIf

		//Par�metro MV_MID
		If aScan( aParams, { |x| x[1] == "MV_MID" } ) > 0
			PUTMV( "MV_MID", IIf( ".T." $ cMID, .T., .F. ) )
		EndIf

		//Par�metro MV_NG2DTES
		If aScan( aParams, { |x| x[1] == "MV_NG2DTES" } ) > 0
			PUTMV( "MV_NG2DTES", dNG2DTES )
		EndIf

		//Par�metro MV_NG2AVIS
		If aScan( aParams, { |x| x[1] == "MV_NG2AVIS" } ) > 0
			PUTMV( "MV_NG2AVIS", SubStr( cNG2AVIS, 1, 1 ) )
		EndIf

		//Par�metro MV_NG2NENV
		If aScan( aParams, { |x| x[1] == "MV_NG2NENV" } ) > 0
			PUTMV( "MV_NG2NENV", AllTrim( cNG2NENV ) )
		EndIf

		//Par�metro MV_NG2IATE
		If aScan( aParams, { |x| x[1] == "MV_NG2IATE" } ) > 0
			PUTMV( "MV_NG2IATE", SubStr( cNG2IATE, 1, 1 ) )
		EndIf

		//Par�metro MV_NG2RASO
		If aScan( aParams, { |x| x[1] == "MV_NG2RASO" } ) > 0
			PUTMV( "MV_NG2RASO", SubStr( cNG2RASO, 1, 1 ) )
		EndIf

		//Par�metro MV_NG2INDR
		If aScan( aParams, { |x| x[1] == "MV_NG2INDR" } ) > 0
			PUTMV( "MV_NG2INDR", SubStr( cNG2INDR, 1, 1 ) )
		EndIf

		//Par�metro MV_NG2TDES
		If aScan( aParams, { |x| x[1] == "MV_NG2TDES" } ) > 0
			PUTMV( "MV_NG2TDES", SubStr( cNG2TDES, 1, 1 ) )
		EndIf

		//Par�metro MV_NG2RIST
		If aScan( aParams, { |x| x[1] == "MV_NG2RIST" } ) > 0
			PUTMV( "MV_NG2RIST", SubStr( cNG2RIST, 1, 1 ) )
		EndIf

		//Par�metro MV_NG2VLAU
		If aScan( aParams, { |x| x[1] == "MV_NG2VLAU" } ) > 0
			PUTMV( "MV_NG2VLAU", SubStr( cNG2VLAU, 1, 1 ) )
		EndIf

		//Par�metro MV_NG2EPIR
		If aScan( aParams, { |x| x[1] == "MV_NG2EPIR" } ) > 0
			PUTMV( "MV_NG2EPIR", SubStr( cNG2EPIR, 1, 1 ) )
		EndIf

		//Par�metro MV_NG2REST
		If aScan( aParams, { |x| x[1] == "MV_NG2REST" } ) > 0
			PUTMV( "MV_NG2REST", SubStr( cNG2REST, 1, 1 ) )
		EndIf

		//Par�metro MV_NG2EAMB
		If aScan( aParams, { |x| x[1] == "MV_NG2EAMB" } ) > 0
			PUTMV( "MV_NG2EAMB", SubStr( cNG2EAMB, 1, 1 ) )
		EndIf

		//Par�metro MV_NG2TPAG
		If aScan( aParams, { |x| x[1] == "MV_NG2TPAG" } ) > 0
			PUTMV( "MV_NG2TPAG", SubStr( cNG2TPAG, 1, 1 ) )
		EndIf

		//Par�metro MV_NG2RAMB
		If aScan( aParams, { |x| x[1] == "MV_NG2RAMB" } ) > 0
			PUTMV( "MV_NG2RAMB", SubStr( cNG2RAMB, 1, 1 ) )
		EndIf

		//Par�metro MV_NG2VEVP
		If aScan( aParams, { |x| x[1] == "MV_NG2VEVP" } ) > 0
			PUTMV( "MV_NG2VEVP", SubStr( cNG2VEVP, 1, 1 ) )
		EndIf

		//Par�metro MV_NG2DENO
		If aScan( aParams, { |x| x[1] == "MV_NG2DENO" } ) > 0
			PUTMV( "MV_NG2DENO", dNG2DENO )
		EndIf

		//Par�metro MV_MDTENRE
		If aScan( aParams, { | x | x[ 1 ] == 'MV_MDTENRE' } ) > 0
			PutMv( 'MV_MDTENRE', IIf( '.T.' $ cMDTENRE, .T., .F. ) )
		EndIf

	EndIf

	//Par�metros dos EPI's
	If nOpcPar == 1

		//Par�metro MV_NGMDTES
		If aScan( aParams, { |x| x[1] == "MV_NGMDTES" } ) > 0
			PUTMV( "MV_NGMDTES", SubStr( cNGMDTES, 1, 1 ) )
		EndIf

		//Par�metro MV_LOCALIZ
		If aScan( aParams, { |x| x[1] == "MV_LOCALIZ" } ) > 0
			PUTMV( "MV_LOCALIZ", SubStr( cLOCALIZ, 1, 1 ) )
		EndIf

		//Par�metro MV_RASTRO
		If aScan( aParams, { |x| x[1] == "MV_RASTRO" } ) > 0
			PUTMV( "MV_RASTRO", SubStr( cRASTRO, 1, 1 ) )
		EndIf

		//Par�metro MV_ESTNEG
		If aScan( aParams, { |x| x[1] == "MV_ESTNEG" } ) > 0
			PUTMV( "MV_ESTNEG", SubStr( cESTNEG, 1, 1 ) )
		EndIf

		//Par�metro MV_NG2SA
		If aScan( aParams, { |x| x[1] == "MV_NG2SA" } ) > 0
			PUTMV( "MV_NG2SA", SubStr( cNG2SA, 1, 1 ) )
		EndIf

		//Par�metro MV_NG2EPDU
		If aScan( aParams, { |x| x[1] == "MV_NG2EPDU" } ) > 0
			PUTMV( "MV_NG2EPDU", SubStr( cNG2EPDU, 1, 1 ) )
		EndIf

		//Par�metro MV_NG2INTE
		If aScan( aParams, { |x| x[1] == "MV_NG2INTE" } ) > 0
			PUTMV( "MV_NG2INTE", SubStr( cNG2INTE, 1, 1 ) )
		EndIf

		//Par�metro MV_MDTPEPI
		If aScan( aParams, { |x| x[1] == "MV_MDTPEPI" } ) > 0
			PUTMV( "MV_MDTPEPI", AllTrim( cMDTPEPI ) )
		EndIf

		//Par�metro MV_ARQPROD
		If aScan( aParams, { |x| x[1] == "MV_ARQPROD" } ) > 0
			PUTMV( "MV_ARQPROD", AllTrim( cARQPROD ) )
		EndIf

		//Par�metro MV_MDTEPID
		If aScan( aParams, { |x| x[1] == "MV_MDTEPID" } ) > 0
			PUTMV( "MV_MDTEPID", SubStr( cMDTEPID, 1, 1 ) )
		EndIf

		//Par�metro MV_NG2EPIB
		If aScan( aParams, { |x| x[1] == "MV_NG2EPIB" } ) > 0
			PUTMV( "MV_NG2EPIB", SubStr( cNG2EPIB, 1, 1 ) )
		EndIf

		//Par�metro MV_NG2BIOM
		If aScan( aParams, { |x| x[1] == "MV_NG2BIOM" } ) > 0
			PUTMV( "MV_NG2BIOM", SubStr( cNG2BIOM, 1, 1 ) )
		EndIf

		// Par�metro MV_DEVBIOM
		If aScan( aParams, { | x | x[ 1 ] == 'MV_DEVBIOM' } ) > 0
			PutMv( 'MV_DEVBIOM', '"' + SubStr( cDEVBIOM, 1, 1 ) + '"' )
		EndIf

		//Par�metro MV_NGFORPD
		If aScan( aParams, { |x| x[1] == "MV_NGFORPD" } ) > 0
			PUTMV( "MV_NGFORPD", SubStr( cNGFORPD, 1, 1 ) )
		EndIf

		// Par�metro MV_NG2RECI
		If aScan( aParams, { | x | x[ 1 ] == 'MV_NG2RECI' } ) > 0
			PutMv( 'MV_NG2RECI', '"' + SubStr( cNG2RECI, 1, 1 ) + '"' )
		EndIf

		//Par�metro MV_NGEPIEN
		If aScan( aParams, { |x| x[1] == "MV_NGEPIEN" } ) > 0
			PUTMV( "MV_NGEPIEN", SubStr( cNGEPIEN, 1, 1 ) )
		EndIf

		//Par�metro MV_DBLQMOV
		If aScan( aParams, { |x| x[1] == "MV_DBLQMOV" } ) > 0
			PUTMV( "MV_DBLQMOV", dDBLQMOV )
		EndIf

		//Par�metro MV_ULMES
		If aScan( aParams, { |x| x[1] == "MV_ULMES" } ) > 0
			PUTMV( "MV_ULMES", dULMES )
		EndIf

		//Par�metro MV_MDTEPIV
		If aScan( aParams, { |x| x[1] == "MV_MDTEPIV" } ) > 0
			PUTMV( "MV_MDTEPIV", Val( SubStr( cMDTEPIV, 1, 1 ) ) )
		EndIf

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fParamEsoc
Adiciona no array os par�metros relacionados ao eSocial

@return Nil, Sempre nulo

@sample fParamEsoc()

@author Luis Fellipy Bett
@since  23/06/2022
/*/
//---------------------------------------------------------------------
Static Function fParamEsoc()

	//---------------------------------------------------------------------
	// Verifica se os par�metros existem no dicion�rio e adiciona no array
	//---------------------------------------------------------------------
	If GetMv( "MV_NG2ESOC", .T. )
		aAdd( aParams, { "MV_NG2ESOC" } )
	EndIf

	If GetMv( "MV_MID", .T. )
		aAdd( aParams, { "MV_MID" } )
	EndIf
	
	If GetMv( "MV_NG2DTES", .T. )
		aAdd( aParams, { "MV_NG2DTES" } )
	EndIf

	If GetMv( "MV_NG2AVIS", .T. )
		aAdd( aParams, { "MV_NG2AVIS" } )
	EndIf

	If GetMv( "MV_NG2NENV", .T. )
		aAdd( aParams, { "MV_NG2NENV" } )
	EndIf

	If GetMv( "MV_NG2IATE", .T. )
		aAdd( aParams, { "MV_NG2IATE" } )
	EndIf

	If GetMv( "MV_NG2RASO", .T. )
		aAdd( aParams, { "MV_NG2RASO" } )
	EndIf

	If GetMv( "MV_NG2TDES", .T. )
		aAdd( aParams, { "MV_NG2TDES" } )
	EndIf

	If GetMv( "MV_NG2RIST", .T. )
		aAdd( aParams, { "MV_NG2RIST" } )
	EndIf

	If GetMv( "MV_NG2VLAU", .T. )
		aAdd( aParams, { "MV_NG2VLAU" } )
	EndIf

	If GetMv( "MV_NG2EPIR", .T. )
		aAdd( aParams, { "MV_NG2EPIR" } )
	EndIf

	If GetMv( "MV_NG2REST", .T. )
		aAdd( aParams, { "MV_NG2REST" } )
	EndIf

	If GetMv( "MV_NG2INDR", .T. )
		aAdd( aParams, { "MV_NG2INDR" } )
	EndIf

	If GetMv( "MV_NG2EAMB", .T. )
		aAdd( aParams, { "MV_NG2EAMB" } )
	EndIf

	If GetMv( "MV_NG2TPAG", .T. )
		aAdd( aParams, { "MV_NG2TPAG" } )
	EndIf

	If GetMv( "MV_NG2RAMB", .T. )
		aAdd( aParams, { "MV_NG2RAMB" } )
	EndIf

	If GetMv( "MV_NG2VEVP", .T. )
		aAdd( aParams, { "MV_NG2VEVP" } )
	EndIf

	If GetMv( "MV_NG2DENO", .T. )
		aAdd( aParams, { "MV_NG2DENO" } )
	EndIf

	If GetMv( 'MV_MDTENRE', .T. )
		aAdd( aParams, { 'MV_MDTENRE' } )
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fParamEPI
Adiciona no array os par�metros relacionados � entrega de EPI's

@return Nil, Sempre nulo

@sample fParamEPI()

@author Luis Fellipy Bett
@since  23/06/2022
/*/
//---------------------------------------------------------------------
Static Function fParamEPI()

	//---------------------------------------------------------------------
	// Verifica se os par�metros existem no dicion�rio e adiciona no array
	//---------------------------------------------------------------------
	If GetMv( "MV_NGMDTES", .T. )
		aAdd( aParams, { "MV_NGMDTES" } )
	EndIf

	If GetMv( "MV_LOCALIZ", .T. )
		aAdd( aParams, { "MV_LOCALIZ" } )
	EndIf

	If GetMv( "MV_RASTRO", .T. )
		aAdd( aParams, { "MV_RASTRO" } )
	EndIf

	If GetMv( "MV_ESTNEG", .T. )
		aAdd( aParams, { "MV_ESTNEG" } )
	EndIf

	If GetMv( "MV_NG2SA", .T. )
		aAdd( aParams, { "MV_NG2SA" } )
	EndIf

	If GetMv( "MV_NG2EPDU", .T. )
		aAdd( aParams, { "MV_NG2EPDU" } )
	EndIf

	If GetMv( "MV_NG2INTE", .T. )
		aAdd( aParams, { "MV_NG2INTE" } )
	EndIf

	If GetMv( "MV_MDTPEPI", .T. )
		aAdd( aParams, { "MV_MDTPEPI" } )
	EndIf

	If GetMv( "MV_ARQPROD", .T. )
		aAdd( aParams, { "MV_ARQPROD" } )
	EndIf

	If GetMv( "MV_MDTEPID", .T. )
		aAdd( aParams, { "MV_MDTEPID" } )
	EndIf

	If GetMv( "MV_NG2EPIB", .T. )
		aAdd( aParams, { "MV_NG2EPIB" } )
	EndIf

	If GetMv( "MV_NG2BIOM", .T. )
		aAdd( aParams, { "MV_NG2BIOM" } )
	EndIf

	If GetMv( "MV_DEVBIOM", .T. )
		aAdd( aParams, { "MV_DEVBIOM" } )
	EndIf

	If GetMv( "MV_NGFORPD", .T. )
		aAdd( aParams, { "MV_NGFORPD" } )
	EndIf

	If GetMv( "MV_NG2RECI", .T. )
		aAdd( aParams, { "MV_NG2RECI" } )
	EndIf

	If GetMv( "MV_NGEPIEN", .T. )
		aAdd( aParams, { "MV_NGEPIEN" } )
	EndIf

	If GetMv( "MV_DBLQMOV", .T. )
		aAdd( aParams, { "MV_DBLQMOV" } )
	EndIf

	If GetMv( "MV_ULMES", .T. )
		aAdd( aParams, { "MV_ULMES" } )
	EndIf

	If GetMv( "MV_MDTEPIV", .T. )
		aAdd( aParams, { "MV_MDTEPIV" } )
	EndIf

Return
