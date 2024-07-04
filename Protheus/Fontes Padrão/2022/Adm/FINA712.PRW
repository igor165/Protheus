#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FwSchedule.ch"
#INCLUDE "FINA712.CH"

Static  __oFontTit    := TFont():New(,,-25,.T.,.T.,,,,,)
Static  __oFont2      := TFont():New(,,-14,.T.,,,,,,)
Static  __oFont2N     := TFont():New(,,-14,.T.,.T.,,,,,)


//-------------------------------------------------------------------
/*/{Protheus.doc} F712Wiz
Wizard de configuração do Novo Gestor Financeiro

@author renato.ito
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Function F712Wiz()

	Local oStepWiz As Object
	Local o1stPage As Object
	Local o2stPage As Object
	Local o3stPage As Object
	Local o4stPage As Object
	Local o5stPage As Object
	Local o6stPage As Object
	Local oDlg     As Object
	Local lTravou  As Logical

	If !IsBlind()

    	// verifica se o processo já está em execução
		lTravou := .T.
		If FWIsAdmin( __cUserID )
    		lTravou := LockByName('FINA712', .T./*lEmpresa*/, .F./*lFilial*/)    
    	EndIf

    	If lTravou

			DEFINE DIALOG oDlg TITLE ' ' PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP )

				oDlg:nWidth  := 750
				oDlg:nHeight := 550

				oStepWiz := FWWizardControl():New(oDlg)  //Instancia a classe FWWizardControl
				oStepWiz:ActiveUISteps()

				//----------------------
				// Pagina 1 - Início
				//----------------------
				o1stPage := oStepWiz:AddStep("1STSTEP",{|Panel| cria_pn1(Panel)}) // Adiciona um Step
				o1stPage:SetStepDescription(OemToAnsi(STR0039))   // 'Início'
				If FWIsAdmin( __cUserID )
					o1stPage:SetNextTitle(OemToAnsi(STR0002))       // Define o título do botão next -- "Avançar"
					o1stPage:SetNextAction({||.T.})                 // Define o bloco ao clicar no botão next
				Else
					o1stPage:SetNextTitle(OemToAnsi(STR0040))       // 'Terminar'
					o1stPage:SetNextAction({||Help(' ', 1, 'F712WIZADM' , , STR0025 , 1 , 0),oDlg:End()})                 // Define o bloco ao clicar no botão next
				EndIf
				o1stPage:SetCancelAction({|| .T.})              // Define o bloco ao clicar no botão Cancelar

				//----------------------
				// Pagina 2 - Recomendações Adm
				//----------------------
				o2stPage := oStepWiz:AddStep("2STSTEP",{|Panel| cria_pn2(Panel)}) // Adiciona um Step
				o2stPage:SetStepDescription(OemToAnsi(STR0041)) // 'Avisos'
				o2stPage:SetNextTitle(OemToAnsi(STR0002))       // Define o título do botão next -- "Avançar"
				o2stPage:SetNextAction({||.T.})                  // Define o bloco ao clicar no botão next
				o2stPage:SetCancelAction({|| .T.})              // Define o bloco ao clicar no botão Cancelar

				//----------------------
				// Pagina 3 - Porta Multiprotocolo
				//----------------------
				o3stPage := oStepWiz:AddStep("3STSTEP",{|Panel| cria_pn3(Panel)}) // Adiciona um Step
				o3stPage:SetStepDescription(OemToAnsi(STR0042)) // 'Multiprotocolo'
				o3stPage:SetNextTitle(OemToAnsi(STR0002))       // Define o título do botão next -- "Avançar"
				If F710VMProt()
					o3stPage:SetNextTitle(OemToAnsi(STR0002))       // Define o título do botão next -- "Avançar"
					o3stPage:SetNextAction({||.T.})                 // Define o bloco ao clicar no botão next
				Else
					o3stPage:SetNextTitle(OemToAnsi(STR0040))       // 'Terminar'
					o3stPage:SetNextAction({||oDlg:End()})                 // Define o bloco ao clicar no botão next
				EndIf
				o3stPage:SetCancelAction({|| .T.})              // Define o bloco ao clicar no botão Cancelar

				//----------------------
				// Pagina 4 - Dicionário - STAMP
				//----------------------
				o4stPage := oStepWiz:AddStep("4STSTEP",{|Panel| cria_pn4(Panel)}) // Adiciona um Step
				o4stPage:SetStepDescription(OemToAnsi(STR0006))  // "Dicionário"
				o4stPage:SetNextTitle(OemToAnsi(STR0002))        // Define o título do botão next -- "Avançar"
				o4stPage:SetNextAction({||F712Dic()})            // Define o bloco ao clicar no botão next
				o4stPage:SetCancelAction({|| .T.})               // Define o bloco ao clicar no botão Cancelar

				//----------------------
				// Pagina 5 - Job
				//----------------------
				o5stPage := oStepWiz:AddStep("5STSTEP",{|Panel| cria_pn5(Panel)}) // Adiciona um Step
				o5stPage:SetStepDescription(OemToAnsi(STR0043))  // 'Agendamento'
				o5stPage:SetNextTitle(OemToAnsi(STR0013))        // Define o título do botão next -- "Configurar"
				o5stPage:SetNextAction({||F712Job()})            // Define o bloco ao clicar no botão Próximo
				o5stPage:SetCancelAction({|| .T.})               // Define o bloco ao clicar no botão Cancelar

				//----------------------
				// Pagina 6 - Conclusão
				//----------------------
				o6stPage := oStepWiz:AddStep("6STSTEP",{|Panel| cria_pn6(Panel)}) // Adiciona um Step
				o6stPage:SetStepDescription(OemToAnsi(STR0019)) // "Finalizar"
				o6stPage:SetNextTitle(OemToAnsi(STR0019))       // Define o título do botão next -- "Finalizar"
				o6stPage:SetNextAction({||.T.})                 // Define o bloco ao clicar no botão next
				o6stPage:SetCancelAction({|| .T.})              // Define o bloco ao clicar no botão Cancelar

				oStepWiz:activate()

			ACTIVATE DIALOG oDlg CENTER      

			If FWIsAdmin( __cUserID )
				UnLockByName('FINA712', .T./*lEmpresa*/, .F./*lFilial*/ )
			EndIf
      
		Else
			Help(' ', 1, 'F712WIZRUN' , , STR0026 , 1 , 0) // 'Wizard de configuração do Novo Gestor Financeiro já está em execução em outra instância!'
		EndIf
	Else
		//Somente será executado se for chamado por JOB.
		F712Dic()
		F712Job()
	Endif


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pn1
Função para construção página do wizard
step 1 informações gerais do wizard
@param oPanel

@author rafael.rondon
@since 25/07/2022
/*/
//-------------------------------------------------------------------
Static Function cria_pn1(oPanel As Object)

	Local cLinkTdn  As Character
	Local cMsg001   As Character
	Local oSay1     As Character

	cLinkTdn := 'https://tdn.totvs.com/pages/releaseview.action?pageId=611007335'

	cMsg001 := "<b><a target='_blank' href='"+cLinkTDN+"'> "
	cMsg001 += STR0044 // "Clique aqui para saber mais."
	cMsg001 += " </a></b>"
	cMsg001 += "<span color: #565759;'>" + "</span>"

	TSay():New(10,15,{|| STR0003},oPanel,,__oFontTit,,,,.T.,CLR_BLUE,)   // 'Boas vindas ao Novo Gestor Financeiro'
	TSay():New(35,15,{|| STR0046},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        // 'O Novo Gestor Financeiro fornece um conjunto de funcionalidades para gerir as atividades financeiras de'
	TSay():New(45,15,{|| STR0047},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        // 'forma ágil com uma interface moderna.'

	If !(FWIsAdmin( __cUserID ))
		TSay():New(65,15,{|| STR0048 },oPanel,,__oFont2,,,,.T.,CLR_BLUE,)  //   'Algumas configurações são necessárias para acessar essa rotina.'
		TSay():New(85,15,{|| STR0049 },oPanel,,__oFont2N,,,,.T.,CLR_RED,)  //   'Por favor, solicite ao administrador do sistema que acesse essa mesma rotina para realizar'
		TSay():New(95,15,{|| STR0050 },oPanel,,__oFont2N,,,,.T.,CLR_RED,)    //   'as configurações necessárias.'
		oSay1 := TSay():New(115,15,{||cMsg001},oPanel,,__oFont2,,,,.T.,,,220,20,,,,,,.T.)    
	else
		TSay():New(65,15,{|| STR0051 },oPanel,,__oFont2,,,,.T.,CLR_BLUE,)  //   'Algumas configurações são necessárias para acessar essa rotina. Você será guiado nos próximos passos.'
		oSay1 := TSay():New(85,15,{||cMsg001},oPanel,,__oFont2,,,,.T.,,,220,20,,,,,,.T.)
	EndIf

	oSay1:bLClicked := {|| MsgRun( STR0052, "URL",{|| ShellExecute("open",cLinkTDN,"","",1) } ) } // "Abrindo o link... Aguarde..."

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pn2
Função para construção página do wizard
step 1 informações gerais do wizard
@param oPanel

@author renato.ito
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Static Function cria_pn2(oPanel As Object)

	Local cLinkTdn  As Character
	Local cMsg001   As Character
	Local oSay1     As Character

	cLinkTdn := 'https://tdn.totvs.com/pages/releaseview.action?pageId=602610545'

	TSay():New(10,15,{|| STR0041},oPanel,,__oFontTit,,,,.T.,CLR_BLUE,)    //    'Avisos'
	TSay():New(35,15,{|| STR0004},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        // 'Nesse wizard vamos verificar todas as necessidades para execução do Novo Gestor Financeiro.'
	TSay():New(55,15,{|| STR0054},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)   //    'Será necessário o acesso exclusivo de algumas tabelas do módulo financeiro para atualização do dicionário'
	TSay():New(75,15,{|| STR0037},oPanel,,__oFont2,,,,.T.,CLR_RED,)  // 'Este wizard deve ser executado no ambiente onde está configurado o serviço de'

	cMsg001 := "<b><a target='_blank' href='"+cLinkTDN+"'> "
	cMsg001 += STR0045 // "Clique aqui para mais detalhes das configurações."
	cMsg001 += " </a></b>"
	cMsg001 += "<span color: #565759;'>" + "</span>"
	oSay1 := TSay():New(95,15,{||cMsg001},oPanel,,__oFont2,,,,.T.,,,220,20,,,,,,.T.)
	oSay1:bLClicked := {|| MsgRun( STR0052, "URL",{|| ShellExecute("open",cLinkTDN,"","",1) } ) } // "Abrindo o link... Aguarde..." 

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pn3
Função para construção página do wizard
step 3 porta multiprotocolo
@param oPanel

@author rafael.rondon
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Static Function cria_pn3(oPanel As Object)

	Local cLinkTdn  As Character
	Local cMsg001   As Character
	Local oSay1     As Character

	cLinkTdn := 'https://tdn.totvs.com/display/tec/Application+Server+-+Porta+Multiprotocolo'

	TSay():New(10,15,{|| STR0056 },oPanel,,__oFontTit,,,,.T.,CLR_BLUE,)   //    'Porta Multiprotocolo'

	If F710VMProt() // Multiprotocolo configurada?

		TSay():New(35,15,{|| STR0057},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)    //    'A porta Multiprotocolo está configurada.'
		TSay():New(55,15,{|| STR0058},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        //  'Nenhuma ação é necessária neste passo.'

	Else

		TSay():New(35,15,{|| STR0059},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)   //    'É preciso que o sistema esteja configurado com o uso da porta multiprotocolo para utilizar o Novo'
		TSay():New(45,15,{|| STR0060},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)   //    'Gestor Financeiro.'

		TSay():New(65,15,{|| STR0061},oPanel,,__oFont2N,,,,.T.,CLR_RED,)    //    'Somente após configurar a porta multiprotocolo, será possível continuar a configuração.'

		cMsg001 := "<b><a target='_blank' href='"+cLinkTDN+"'> "
		cMsg001 += STR0044 // "Clique aqui para saber mais."
		cMsg001 += " </a></b>"
		cMsg001 += "<span color: #565759;'>" + "</span>"
		oSay1 := TSay():New(85,15,{||cMsg001},oPanel,,__oFont2,,,,.T.,,,220,20,,,,,,.T.)
		oSay1:bLClicked := {|| MsgRun( STR0052, "URL",{|| ShellExecute("open",cLinkTDN,"","",1) } ) } // "Abrindo o link... Aguarde..."

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pn4
Função para construção página do wizard
step 2 valição das tabelas e parâmetros
@param oPanel

@author renato.ito
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Static Function cria_pn4(oPanel As Object)

	Local cLinkTdn  As Character
	Local cMsg001   As Character
	Local oSay1     As Character

	cLinkTdn := 'https://tdn.totvs.com/pages/releaseview.action?pageId=602610545'

	TSay():New(10,15,{|| STR0008},oPanel,,__oFontTit,,,,.T.,CLR_BLUE,)   // 'Dicionário de dados'

	If F710VDic()

		TSay():New(35,15,{|| STR0062},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)    //    'Dicionário Ok.'
		TSay():New(55,15,{|| STR0063},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        //   'Nenhuma ação é necessária neste passo.'

	Else  

		TSay():New(35,15,{|| STR0064},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        //    "Neste passo faz-se necessário que o dicionário do módulo financeiro esteja com acesso exclusivo,"
		TSay():New(45,15,{|| STR0065},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)            //    "onde ao avançar, serão criados campos de controle e novas tabelas no sistema."

		cMsg001 := "<b><a target='_blank' href='"+cLinkTDN+"'> "
		cMsg001 += STR0044 // "Clique aqui para saber mais."
		cMsg001 += " </a></b>"
		cMsg001 += "<span color: #565759;'>" + "</span>"
		oSay1 := TSay():New(65,15,{||cMsg001},oPanel,,__oFont2,,,,.T.,,,220,20,,,,,,.T.)
		oSay1:bLClicked := {|| MsgRun( STR0052, "URL",{|| ShellExecute("open",cLinkTDN,"","",1) } ) } // "Abrindo o link... Aguarde..."

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pn5
Função para construção página do wizard
step 4 configuração do job
@param oPanel

@author renato.ito
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Static Function cria_pn5( oPanel As Object )

	Local cLinkTdn  As Character
	Local cMsg001   As Character
	Local oSay1     As Character

	cLinkTdn := 'https://tdn.totvs.com/pages/releaseview.action?pageId=602610545'

	TSay():New(10,15,{|| STR0014},oPanel,,__oFontTit,,,,.T.,CLR_BLUE,)   // 'Configuração do Job' 
	TSay():New(35,15,{|| STR0015},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        // 'Nesta etapa, cadastraremos um novo job no schedule automaticamente. Ele tem o nome  FINA711.'                                                                                                                                                                                                                                                                                                                                                                                                                      
	TSay():New(55,15,{|| STR0066},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)          //  'Este job será configurado com intervalo de 15 minutos.'
	TSay():New(75,15,{|| STR0016},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        //'Para alteração no intervalo de execução, realize a manutenção pelo agendamento do Job no Schedule'                                                                                                                                                                                                                                                                                                                                                                                                                 
	TSay():New(85,15,{|| STR0017},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        // 'do módulo configurador.'

	cMsg001 := "<b><a target='_blank' href='"+cLinkTDN+"'> "
	cMsg001 += STR0044 // "Clique aqui para saber mais."
	cMsg001 += " </a></b>"
	cMsg001 += "<span color: #565759;'>" + "</span>"
	oSay1 := TSay():New(105,15,{||cMsg001},oPanel,,__oFont2,,,,.T.,,,220,20,,,,,,.T.)
	oSay1:bLClicked := {|| MsgRun( STR0052, "URL",{|| ShellExecute("open",cLinkTDN,"","",1) } ) } // "Abrindo o link... Aguarde..."

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} cria_pn6
Função para construção página do wizard
step 5 mensagens finais
@param oPanel

@author renato.ito
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Static Function cria_pn6( oPanel As Object )

	TSay():New(10,15,{|| STR0020},oPanel,,__oFontTit,,,,.T.,CLR_BLUE,)      // 'Configuração finalizada'
	TSay():New(35,15,{|| STR0021},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        // 'Configuração realizada com sucesso!'
	TSay():New(55,15,{|| STR0022},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        // 'Para acesso ao Novo Gestor Financeiro é necessário aguardar a execução da primeira carga de dados.'
	TSay():New(75,15,{|| STR0067},oPanel,,__oFont2,,,,.T.,CLR_BLUE,)        //  'Dependendo do volume da base de dados do financeiro, esta carga pode demorar um tempo considerável.'

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F712Dic
Função para validação da página 2 do wizard
Verifica o campo S_T_A_M_P_ das tabelas e parâmetros

@author renato.ito
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Static Function F712Dic()

	Local lRet    As Logical
	Local aTables As Array
	Local aFiles  As Array
	Local i       As Numeric
	Local cFn     As Character

	lRet    := .T.
	aTables := {}
	aFiles  := {}
	cFn     := "TCCONFIG"

	// Tabelas que devem ter o campo S_T_A_M_P_
	aTables := STRTOKARR('SE1|SE2|FKD|SC5|SC6|SC7|SC9', '|' )
	// Carrego o array com os dados para abertura das tabelas.
	aEval( aTables, { |x| aadd(aFiles,{RetSqlName(x),x}) } )

	If (&cFn.('SETAUTOSTAMP = ON') == 'OK') .And. (&cFn.('SETUSEROWSTAMP = ON') == 'OK')
		//Verifico se todas as tabelas puderam ser abertas em modo excluivo.
		For i := 1 To Len(aFiles)
			// fechando área caso aberta
			If (Select(aFiles[i][2]) > 0)
				&(aFiles[i][2])->(DbCloseArea())
			EndIf
			TCRefresh(aFiles[i][1])
			DbUseArea(.T., 'TOPCONN', aFiles[i][1], aFiles[i][2], .F. , .F.)
			&(aFiles[i][2])->(DbCloseArea())
			// Verifica se o campo S_T_A_M_P_ foi criado
			If aScan(TCStruct(aFiles[i][1] ), {|x| x[1] == 'S_T_A_M_P_'}) = 0
				lRet := .f.
				Help(' ', 1,'F712Stamp' ,,STR0010 ,1,0) // 'Não foi possível obter acesso exclusivo para adequação do dicionário.'
				Exit
			Endif
		Next
		&cFn.('SETAUTOSTAMP = OFF')
		&cFn.('SETUSEROWSTAMP = OFF')
	Else
		// Caso apresente esse erro, verifique se o banco de dados é homologado para o campo S_T_A_M_P_ e se o DbAcess está atualizado
		lRet := .F.
		Help(' ', 1,'F712DBStamp' ,,STR0011 ,1,0) // 'Não foi possível ativar o recurso S_T_A_M_P_ para o banco de dados.'
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F712Job
Função para validação da página 4 do wizard
configuração do job

@author renato.ito
@since 02/03/2021
/*/
//-------------------------------------------------------------------
Static Function F712Job()

	Local cAgend  as Character
	Local cPeriod as Character
	Local lRet    as Logical

	lRet    := .T.
	cAgend  := '' 
	cPeriod := ''

	// Verifica se já existe o job configurado
	cAgend := FwSchdByFunction("FINA711('" + cEmpAnt + "')")
	//Somente cria o agendamento do schedule caso o mesmo ainda não exista
	If (Empty(cAgend))
		//Executa a cada 15 minutos
		cPeriod := "D(Each(.T.);Day(1);EveryDay(.T.););Execs(0096);Interval(00:15);"
		//(cFunction, cUserID, cParam, cPeriod, cTime, cEnv, cEmpFil, cStatus, dDate, nModule, aParamDef)
		cAgend := FwInsSchedule("FINA711('" + cEmpAnt + "')", "000000",, cPeriod, "00:00", Upper(GetEnvServer()), cEmpAnt + "/" + cFilAnt + ";",;
			SCHD_ACTIVE, Date(), 6, )
		If Empty(cAgend)
			lRet := .F.
			Help(' ', 1,'F712Job' ,,STR0018 ,1,0) // 'Não foi possível criar o agendamento Job FINA711 de forma automática.'
		EndIf
	EndIf

Return lRet


