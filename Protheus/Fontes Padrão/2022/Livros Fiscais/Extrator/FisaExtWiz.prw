#Include 'Totvs.ch' 
#Include 'Totvs.ch'
#Include 'Protheus.ch'
#Include 'RwMake.ch'
#Include 'FWBrowse.ch'
#Include 'FWMvcDef.ch'
#Include 'ApWizard.ch'
#Include 'FWCommand.ch'
#Include 'FisaExtWiz.ch'
#Include 'colors.ch'

Static lJob := IsBlind() .or. IsInCallStack('TAFXGSP') 
Static lExecutou := .F.

Static cBarra := Iif(IsSrvUnix(),'/','\')
Static cRelease := GetRPORelease()

Static nQtdCmp := 0

Static oFisaExtSx := FisaExtX02()

/*/{Protheus.doc} FisaExtWiz
	(Função para montar a wizard do extrator fiscal.)

	@type Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@return Nil, nulo, não tem retorno.
	/*/
Function FisaExtWiz()

	Local nCount := 0
	Local nQuant := 0

	Local bFwMsgRun := {|| }

	Private nPagina := 1

	Private aLayRela := {}
	Private aLayRRei := {}
	Private aFiliais := {}
	Private aLaysBrw := {}

	Private lMarkALay := .F.
	Private lMarkAFil := .F.
	Private lMarkDia := .F.
	Private lMarkMes := .F.
	Private lMarkVal := .T.
	
	Private oWizard := Nil
	
	Private oP01Layer1 := Nil
	Private oP01Layer2 := Nil
	Private oP01Pane1 := Nil
	Private oP01Pane2 := Nil
	Private oP01Fldr := Nil
	Private oP01MGet1 := Nil
	Private oP01MGet2 := Nil
	
	Private oP02CBAll := Nil
	Private oP02CBDia := Nil
	Private oP02CBMes := Nil
	Private oP02BLay := Nil
	Private oP02BRel := Nil

	Private oP03CBAll := Nil
	Private oP03BFil := Nil

	Private oP04BFil := Nil
	Private oP04BLay := Nil

	// Inicializa a variavel.
	nQtdCmp := 0
	lExecutou := .F.

	// Quantidades de campos da aba parametrização
	nQuant := 55

	// Quantidades de campos da aba Tabelas de dados
	nQuant += Len(oFisaExtSx:_SX2)

	// Quantidades de campos da aba Campos das tabelas
	Aeval(oFisaExtSx:_SX3,{|x| nQuant += Len(x[2]) })

	// Quantidades de campos da aba Parâmetros do Sistema
	nQuant += Len(oFisaExtSx:_SX6)

	// Quantidade de campos utilizados pelo MsmGet.
	For nCount := 1 To nQuant
		_SetOwnerPrvt("W_PAR" + StrZero(nCount,3),"")
	Next

	// Instancia o objeto da wizard
	bFwMsgRun := {|| oWizard := FisaExtWiz_Class():New() }

	FWMsgRun(,bFwMsgRun,"Extrator Fiscal","Inicializando a wizard...")

	// Seta a quantidade de thread's
	oWizard:SetQtdeThread(oFisaExtSx:_MV_EXTQTHR)
	
	// valida se a classe FwWizardControl existe no RPO
	If FindFunction('__FWWIZCTLR')
		// Monta a Wizard com a função FwWizardControl
		bFwMsgRun := {|| fMkWizaCon() }
	Else
		// Monta a Wizard antiga
		bFwMsgRun := {|| fMkWizaOld() }
	EndIf
	
	// Executa a wizard
	FWMsgRun(,bFwMsgRun,"Extrator Fiscal","Inicializando a wizard...")

Return Nil

/*/{Protheus.doc} fMkWizaCon
	(Função para montar a wizard com a função FwWizardControl.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fMkWizaCon()
	
	Local aCoors := {}
	
	Local oDialog := Nil
	Local oStep01 := Nil
	Local oStep02 := Nil
	Local oStep03 := Nil
	Local oStep04 := Nil
	
	aCoors := FWGetDialogSize()									// Função para retornar o tamanho de uma window maximizada debaixo da window principal do Protheus.
	
	oDialog := FWWizardControl():New(,{aCoors[3],aCoors[4]})	// Classe para construção do Wizard
	oDialog:ActiveUISteps()										// Define se deverá ser exibida a classe de FWUISteps 
	/*
	// Pagina 0
	oStep00 := oDialog:AddStep('STEP0')							// Adiciona um novo Step ao wizard
	oStep00:SetStepDescription('Bem Vindo')						// Altera a descrição do Step (ou página) correspondente.
	oStep00:SetConstruction({|oPanel| fMakePag00(oPanel) }) 	// Seta o bloco de construção da tela.
	oStep00:SetNextAction({|| .T. }) 							// Define o bloco de código que deverá executar ao pressionar o botão Seguinte.
	oStep00:SetCancelAction({|| .T.})							// Define o bloco de código que deverá executar ao pressionar o botão Cancelar
	*/
	// Pagina 1
	oStep01 := oDialog:AddStep('STEP1')							// Adiciona um novo Step ao wizard
	oStep01:SetStepDescription('Parâmetros')					// Altera a descrição do Step (ou página) correspondente.
	oStep01:SetConstruction({|oPanel| fMakePag01(oPanel) }) 	// Seta o bloco de construção da tela.
	oStep01:SetNextAction({|| fValPag01() }) 			// Define o bloco de código que deverá executar ao pressionar o botão Seguinte.
	oStep01:SetCancelAction({|| .T.})							// Define o bloco de código que deverá executar ao pressionar o botão Cancelar
	
	// Pagina 2
	oStep02 := oDialog:AddStep('STEP2')							// Adiciona um novo Step ao wizard
	oStep02:SetStepDescription("Seleciona os Layout's")			// Altera a descrição do Step (ou página) correspondente.
	oStep02:SetConstruction({|oPanel| fMakePag02(oPanel) }) 	// Seta o bloco de construção da tela.
	oStep02:SetNextAction({|| fValPag02() }) 					// Define o bloco de código que deverá executar ao pressionar o botão Seguinte.
	oStep02:SetPrevAction({|| fRetPag02() })					// Define o bloco de código que deverá executar ao pressionar o botão Voltar
	oStep02:SetCancelAction({|| .T.})							// Define o bloco de código que deverá executar ao pressionar o botão Cancelar
	
	// Pagina 3
	oStep03 := oDialog:AddStep('STEP3')							// Adiciona um novo Step ao wizard
	oStep03:SetStepDescription('Seleciona as Filiais')			// Altera a descrição do Step (ou página) correspondente.
	oStep03:SetConstruction({|oPanel| fMakePag03(oPanel) }) 	// Seta o bloco de construção da tela.
	oStep03:SetNextAction({|| fValPag03() }) 					// Define o bloco de código que deverá executar ao pressionar o botão Seguinte.
	oStep03:SetPrevAction({|| fRetPag03() })					// Define o bloco de código que deverá executar ao pressionar o botão Voltar
	oStep03:SetCancelAction({|| .T.})							// Define o bloco de código que deverá executar ao pressionar o botão Cancelar
	
	// Pagina 4
	oStep04 := oDialog:AddStep('STEP4')							// Adiciona um novo Step ao wizard
	oStep04:SetStepDescription('Processamento')					// Altera a descrição do Step (ou página) correspondente.
	oStep04:SetConstruction({|oPanel| fMakePag04(oPanel) }) 	// Seta o bloco de construção da tela.
	oStep04:SetNextAction({|| fValPag04() }) 					// Define o bloco de código que deverá executar ao pressionar o botão Seguinte.
	oStep04:SetPrevAction({|| fRetPag04() })					// Define o bloco de código que deverá executar ao pressionar o botão Voltar
	oStep04:SetCancelAction({|| .T.})							// Define o bloco de código que deverá executar ao pressionar o botão Cancelar
	oStep04:bPrevWhen := { || !lExecutou }						// Desabilita o botão "Voltar" após a geração do arquivo.
	
	//Ativa Wizard
	oDialog:Activate()	
Return

/*/{Protheus.doc} fMkWizaOld
	(Função para montar a wizard com a função antiga.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fMkWizaOld()
	
	Local oDialog := Nil

	Local aSize := MsAdvSize(.T.)
	Local aCoors := {aSize[7]+5,0,aSize[3]-100,aSize[5]}

	oDialog := APWizard():New('Extrator Fiscal','Apresentação','Bem-Vindo','Esta ferramenta...',{||.T.},{||.T.},.F.,,,,aCoors)

	oDialog:NewPanel('Parâmetros'			,,{|| .T. },{|| fValPag01() },{|| .T. },.T.,{|| fMakePag01(oDialog:oMPanel[oDialog:nPanel]) })
	oDialog:NewPanel("Seleciona os Layout's",,{|| .F. },{|| fValPag02() },{|| .T. },.T.,{|| fMakePag02(oDialog:oMPanel[oDialog:nPanel]) })
	oDialog:NewPanel('Parâmetros'			,,{|| .F. },{|| fValPag03() },{|| .T. },.T.,{|| fMakePag03(oDialog:oMPanel[oDialog:nPanel]) })
	oDialog:NewPanel("Processamento"		,,{|| .F. },{|| fValPag04() },{|| .T. },.T.,{|| fMakePag04(oDialog:oMPanel[oDialog:nPanel]) })

	Activate Wizard oDialog CENTERED
	
Return

/*/{Protheus.doc} fMakePag00
	(Função para montar a pagina inicial.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param o_Dialog, objeto, pagina da wizard.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fMakePag00(o_Dialog)

	Local oTIBrowser := Nil

	oTIBrowser := TIBrowser():New(0,0,(o_Dialog:nClientWidth/2)-2,(o_Dialog:nClientHeight/2)-5,"http://tdn.totvs.com/plugins/servlet/remotepageview?pageId=286737675",o_Dialog)

Return Nil

/*/{Protheus.doc} fMakePag01
	(Função para montar a primeira pagina da wizard.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param o_Dialog, objeto, pagina da wizard.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fMakePag01(o_Dialog)
	
	Local aFolder := {}
	Local aTamPane := {}
	Local aEstrut1 := {}
	Local aEstrut2 := {}
	Local aCampos1 := {}
	Local aCampos2 := {}
	Local aFolder1 := {}
	Local aFolder2 := {}
	Local oFont16  := TFont():New('Arial',,16,,.t.,,,,,.f.,.f.)
	Local cTxtBtn  := "Novo! Ao utilizar o TAF como módulo e extração banco a banco, a etapa de gravação da tabela TAFST1 não será mais realizada otimizando seu processo de integração. Clique para maiores informações. "
	Local oBtnNews := nil

	Default o_Dialog := Nil

	// Define o nome dos folders
	Aadd(aFolder,'Parametrização')
	Aadd(aFolder,'Configuração do sistema')
	
	// Monta um folder
	oP01Fldr := TFolder():New(o_Dialog:nTop,o_Dialog:nLeft,aFolder,,o_Dialog,,,,.T.,,(o_Dialog:nClientWidth/2)-2,(o_Dialog:nClientHeight/2)-10)

	//Inicializa o FWLayer
	oP01Layer1 := FWLayer():new()
	oP01Layer1:Init(oP01Fldr:aDialogs[1],.F.)
	
	// Adicionando linhas
	oP01Layer1:AddLine('LIN1',100,.F.)
	
	// Adicionando colunas nas linhas
	oP01Layer1:AddCollumn('COL1',100,.F.,'LIN1')

	// Pega o objeto do painel de cada parte
	oP01Pane1 := oP01Layer1:getLinePanel('LIN1')
	
	Aadd(aTamPane,{0,0,(oP01Pane1:nClientHeight-4)/2,(oP01Pane1:nClientWidth/2)-5})

	// Pega a estrutura do MsmGet
	aEstrut1 := MkStrctFld(1)
	
	// Pega os campos e cria as variaveis private do MsmGet
	aCampos1 := MakeVar(@aEstrut1)
	
	// Define o nome dos folders
	Aadd(aFolder1,'Geração')
	Aadd(aFolder1,'Movimento')
	Aadd(aFolder1,'Apuração / SPED')
	Aadd(aFolder1,'Inventário')
	Aadd(aFolder1,'Financeiro')
	Aadd(aFolder1,'Contribuinte')
	Aadd(aFolder1,'Empresa Software')
	
	// Monta o campos
	oP01MGet1 := MsmGet():New(,,3,,,,aCampos1,aTamPane[1],,,,,,oP01Pane1,,.F.,.T.,,.F.,.T.,aEstrut1,aFolder1,.T.,,,.T.)
	oP01MGet1:oBox:bSetOption:={||oP01MGet1:SetFocus()}

	//Inicializa o FWLayer
	oP01Layer2 := FWLayer():new()
	oP01Layer2:Init(oP01Fldr:aDialogs[2],.F.)
	
	// Adicionando linhas
	oP01Layer2:AddLine('LIN1',100,.F.)
	
	// Adicionando colunas nas linhas
	oP01Layer2:AddCollumn('COL1',100,.F.,'LIN1')

	// Pega o objeto do painel de cada parte
	oP01Pane2 := oP01Layer2:getLinePanel('LIN1')  

	oBtnNews := THButton():New( (o_Dialog:nClientHeight/2)-10, 25,cTxtBtn,o_Dialog,{||ShellExecute("open","https://tdn.totvs.com/x/NiArI","","",1)},600,10,oFont16,'Detalhes da integração')
	oBtnNews:nClrText := CLR_BLUE

	Aadd(aTamPane,{0,0,(oP01Pane2:nClientHeight-4)/2,(oP01Pane2:nClientWidth/2)-5}) 

	// Pega a estrutura do MsmGet
	aEstrut2 := MkStrctFld(2)
	
	// Pega os campos e cria as variaveis private do MsmGet
	aCampos2 := MakeVar(@aEstrut2)
	
	// Define o nome dos folders
	Aadd(aFolder2,'Tabelas de dados')
	Aadd(aFolder2,'Campos das tabelas')
	Aadd(aFolder2,'Parâmetros do Sistema')
	
	// Monta o campos
	oP01MGet2 := MsmGet():New(,,3,,,,aCampos2,aTamPane[2],,,,,,oP01Pane2,,.F.,.T.,,.F.,.T.,aEstrut2,aFolder2,.T.,,,.T.)

Return Nil

/*/{Protheus.doc} MkStrctFld
	(Função para montar array com a estrutura dos campos para msmget.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param n_Pane, numerico, numero do painel.

	@return aEstrut, array, estrutura do msmget.
	/*/
Static Function MkStrctFld(n_Pane)

	Local aEstrut := {}
	
	Default n_Pane := 0
	
	If n_Pane == 1
		// Monta o Folder 1 - Geração
		fPnDdFld01(@aEstrut)
		
		// Monta o Folder 2 - Movimento
		fPnDdFld02(@aEstrut)
		
		// Monta o Folder 3 - Apuração / SPED
		fPnDdFld03(@aEstrut)
		
		// Monta o Folder 4 - Inventário
		fPnDdFld04(@aEstrut)
		
		// Monta o Folder 5 - Financeiro
		fPnDdFld05(@aEstrut)

		// Monta o Folder 6 - Contribuinte
		fPnDdFld06(@aEstrut)

		// Monta o Folder 7 - Empresa de software
		fPnDdFld07(@aEstrut)
	ElseIf n_Pane == 2
		// Monta o Folder do SX2
		fPnCfFld01(@aEstrut)

		// Monta o Folder do SX3
		fPnCfFld02(@aEstrut)

		// Monta o Folder do SX6
		fPnCfFld03(@aEstrut)
	EndIf
	
Return aEstrut

/*/{Protheus.doc} fPnDdFld01
	(Função para montar o folder 1 (Geração).)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Estrut, array, contem a estrutura do msmget.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fPnDdFld01(a_Estrut)

	Local nPosicao := 0
	Local nFolder := 0
	
	Default a_Estrut := {}
	
	nFolder := 1
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _DATADE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'D'
	a_Estrut[nPosicao][04] := 8
	a_Estrut[nPosicao][06] := '@D'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetDataDe(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][08] := .T.
	a_Estrut[nPosicao][10] := 'oWizard:GetDataDe()'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _DATAATE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'D'
	a_Estrut[nPosicao][04] := 8
	a_Estrut[nPosicao][06] := '@D'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetDataAte(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][08] := .T.
	a_Estrut[nPosicao][10] := 'oWizard:GetDataAte()'
	a_Estrut[nPosicao][16] := nFolder

	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _TIPOSAIDA
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetTipoSaida(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][08] := .T.
	a_Estrut[nPosicao][10] := 'oWizard:GetTipoSaida()'
	a_Estrut[nPosicao][15] := '1=Arquivo TXT;2=Banco de dados'
	a_Estrut[nPosicao][16] := nFolder

	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)

	a_Estrut[nPosicao][01] := Iif(GetMV('MV_ENCHOLD') == "1" , _DIRETORIOENCHOLD, _DIRETORIODESTINO)
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 50
	a_Estrut[nPosicao][06] := '@!'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetDiretorioDestino(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetDiretorioDestino()'
	a_Estrut[nPosicao][11] := 'GTFILE'
	a_Estrut[nPosicao][12] := {|| oWizard:GetTipoSaida() == '1' .and. GETREMOTETYPE() <> 5 }
	a_Estrut[nPosicao][16] := nFolder

	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _ARQUIVODESTINO
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 50
	a_Estrut[nPosicao][06] := '@!'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetArquivoDestino(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetArquivoDestino()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetTipoSaida() == '1' }
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)

	a_Estrut[nPosicao][01] := _FILTRAINTEG
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetFiltraInteg(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][08] := .F.
	a_Estrut[nPosicao][10] := 'oWizard:GetFiltraInteg()'
	a_Estrut[nPosicao][15] := '1=Somente Cadastros ;2=Somente Movimentos; 3=Ambos'
	a_Estrut[nPosicao][16] := nFolder

	nPosicao := AddStruct(@a_Estrut)

	a_Estrut[nPosicao][01] := Iif(GetMV('MV_ENCHOLD') == "1", _FILTRAENCHOLD, _FILTRAREINF)
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetFiltraReinf(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][08] := .F.
	a_Estrut[nPosicao][10] := 'oWizard:GetFiltraReinf()'
	a_Estrut[nPosicao][15] := '1=Sim ;2=Não'
	a_Estrut[nPosicao][16] := nFolder	

	// Verifica se deve mostrar a opção multi thread na wizard
	If oWizard:GetShowMultiThread()
		// Monta a estrutura
		nPosicao := AddStruct(@a_Estrut)

		a_Estrut[nPosicao][01] := _ATVMULTITHREAD
		a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
		a_Estrut[nPosicao][03] := 'C'
		a_Estrut[nPosicao][04] := 1
		a_Estrut[nPosicao][06] := '@!'
		a_Estrut[nPosicao][07] := &('{|| oWizard:SetAtvMultiThread(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
		a_Estrut[nPosicao][10] := 'oWizard:GetAtvMultiThread()'
		a_Estrut[nPosicao][15] := '1=Sim;2=Não'
		a_Estrut[nPosicao][16] := nFolder
		
		// Monta a estrutura
		nPosicao := AddStruct(@a_Estrut)

		a_Estrut[nPosicao][01] := _QTDETHREAD
		a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
		a_Estrut[nPosicao][03] := 'N'
		a_Estrut[nPosicao][04] := 2
		a_Estrut[nPosicao][06] := '@E 99'
		a_Estrut[nPosicao][07] := &('{|| oWizard:SetQtdeThread(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
		a_Estrut[nPosicao][10] := 'oWizard:GetQtdeThread()'
		a_Estrut[nPosicao][12] := {|| oWizard:GetAtvMultiThread() == '1' }
		a_Estrut[nPosicao][16] := nFolder
	EndIf

Return Nil

/*/{Protheus.doc} fPnDdFld02
	(Função para montar o folder 2 (Movimento).)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Estrut, array, contem a estrutura do msmget.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fPnDdFld02(a_Estrut)
	
	Local nPosicao := 0
	Local nFolder := 0
	
	Default a_Estrut := {}
	
	nFolder := 2
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _TIPOMOVIMENTO
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetTipoMovimento(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][08] := .T.
	a_Estrut[nPosicao][10] := 'oWizard:GetTipoMovimento()'
	a_Estrut[nPosicao][15] := '1=Ambos;2=Entradas;3=Saidas'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _NOTADE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := TamSX3('FT_NFISCAL')[1]
	a_Estrut[nPosicao][06] := '@!'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetNotaDe(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetNotaDe()'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _NOTAATE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := TamSX3('FT_NFISCAL')[1]
	a_Estrut[nPosicao][06] := '@!'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetNotaAte(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][08] := .T.
	a_Estrut[nPosicao][10] := 'oWizard:GetNotaAte()'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _SERIEDE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := TamSX3('FT_SERIE')[1]
	a_Estrut[nPosicao][06] := '@!'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetSerieDe(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetSerieDe()'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _SERIEATE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := TamSX3('FT_SERIE')[1]
	a_Estrut[nPosicao][06] := '@!'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetSerieAte(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][08] := .T.
	a_Estrut[nPosicao][10] := 'oWizard:GetSerieAte()'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _ESPECIE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 150
	a_Estrut[nPosicao][06] := '@!'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetEspecie(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetEspecie()'
	a_Estrut[nPosicao][11] := 'SX542M'
	a_Estrut[nPosicao][16] := nFolder
	
Return Nil

/*/{Protheus.doc} fPnDdFld03
	(Função para montar o folder 3 (Apuração).)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Estrut, array, contem a estrutura do msmget.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fPnDdFld03(a_Estrut)
	
	Local nPosicao := 0
	Local nFolder := 0
	
	Default a_Estrut := {}
	
	nFolder := 3
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _APURACAOIPI
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetApuracaoIPI(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetApuracaoIPI()'
	a_Estrut[nPosicao][15] := '0=Mensal;N=Decendial'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _INCIDTRIBPERIODO
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetIncidTribPeriodo(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetIncidTribPeriodo()'
	a_Estrut[nPosicao][15] := '1=Regime não-cumulativo;2=Regime cumulativo;3=Regimes não-cumulativo e cumulativo'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _INIOBRESCRITFISCALCIAP
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetIniObrEscritFiscalCIAP(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetIniObrEscritFiscalCIAP()'
	a_Estrut[nPosicao][15] := '1=Sim;2=Não'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _TIPOCONTRIBUICAO
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetTipoContribuicao(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetTipoContribuicao()'
	a_Estrut[nPosicao][15] := '1=Alq.Basica;2=Alq.Espec.'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _INDREGIMECUMULATIVO
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetIndRegimeCumulativo(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetIndRegimeCumulativo()'
	a_Estrut[nPosicao][15] := '1=Caixa;2=Consolidado;9=Detalhado'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _TIPOATIVIDADE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetTipoAtividade(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetTipoAtividade()'
	a_Estrut[nPosicao][15] := '0=Industrial ou Equiparado;1=Outros'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _INDNATUREZAPJ
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetIndNaturezaPJ(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetIndNaturezaPJ()'
	a_Estrut[nPosicao][15] := '00=PJ Em Geral;01=Soc. Cooperativa(Não SCP);02=Ent. Suj. PIS Folha de Sal.;03=PJ Em Geral(Part. SCP);04=Soc. Cooperativa(Part. SCP);05=SCP'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _CENTRALIZARUNICAFILIAL
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetCentralizarUnicaFilial(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][08] := .T.
	a_Estrut[nPosicao][10] := 'oWizard:GetCentralizarUnicaFilial()'
	a_Estrut[nPosicao][15] := '1=Não;2=Sim'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _SERVICOCODRECEITA
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 6
	a_Estrut[nPosicao][06] := '@!'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetServicoCodReceita(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetServicoCodReceita()'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _OUTROSCODRECEITA
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 6
	a_Estrut[nPosicao][06] := '@!'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetOutrosCodReceita(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetOutrosCodReceita()'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _INDINCIDTRIBUT
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][06] := '@!'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetIndIncidTribut(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetIndIncidTribut()'
	a_Estrut[nPosicao][15] := '1=Receita Bruta;2=Rec. Remun.'
	a_Estrut[nPosicao][16] := nFolder

Return Nil


/*/{Protheus.doc} fPnDdFld04
	(Função para montar o folder 4 (Inventário).)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Estrut, array, contem a estrutura do msmget.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fPnDdFld04(a_Estrut)
	
	Local nPosicao := 0
	Local nFolder := 0
	
	Default a_Estrut := {}
	
	nFolder := 4
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _MOTIVOINVENTARIO
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetMotivoInventario(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetMotivoInventario()'
	a_Estrut[nPosicao][15] := '01=Final do período;02=Mudança de trib. da mercadoria (ICMS);03=Solic. da baixa cad., paral. temp. e outras;04=Na alteração de regime de pagamento;05=Por determinação dos fiscos'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _DATAFECHAMENTOESTOQUE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'D'
	a_Estrut[nPosicao][04] := 8
	a_Estrut[nPosicao][06] := '@D'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetDataFechamentoEstoque(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetDataFechamentoEstoque()'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _REG0210MOV
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetReg0210Mov(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetReg0210Mov()'
	a_Estrut[nPosicao][15] := '1=Sim;2=Não'
	a_Estrut[nPosicao][16] := nFolder
	
Return Nil

/*/{Protheus.doc} fPnDdFld05
	(Função para montar o folder 5 (Financeiro).)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Estrut, array, contem a estrutura do msmget.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fPnDdFld05(a_Estrut)
	
	Local nPosicao := 0
	Local nFolder := 0
	
	Default a_Estrut := {}
	
	nFolder := 5
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _TITURECEBER
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetTituReceber(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetTituReceber()'
	a_Estrut[nPosicao][15] := '1=Data de Contabilização;2=Data de Emissão'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _TITUPAGAR
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetTituPagar(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetTituPagar()'
	a_Estrut[nPosicao][15] := '1=Data de Contabilização;2=Data de Emissão'
	a_Estrut[nPosicao][16] := nFolder

	// Monta a estrutura 
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _BXRECEBER
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetBxReceber(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetBxReceber()'
	a_Estrut[nPosicao][15] := '1=Não;2=Data da Baixa;3=Data de crédito'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _BXPAGAR
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetBxPagar(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetBxPagar()'
	a_Estrut[nPosicao][15] := '1=Não;2=Data da Baixa;3=Data de pagto.'
	a_Estrut[nPosicao][16] := nFolder

Return Nil

/*/{Protheus.doc} fPnDdFld06
	(Função para montar o folder 6 (Contribuinte).)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Estrut, array, contem a estrutura do msmget.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fPnDdFld06(a_Estrut)
	
	Local nPosicao := 0
	Local nFolder := 0
	
	Default a_Estrut := {}
	
	nFolder := 6
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _ENVIACONTRIBUINTE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetEnviaContribuinte(W_PAR' + StrZero(nQtdCmp,3) + '),fMsgAlert("ENVIACONTRIBUINTE"), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetEnviaContribuinte()'
	a_Estrut[nPosicao][15] := '1=Sim;2=Não'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _OBRIGATORIEDADEECD
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetObrigatoriedadeECD(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetObrigatoriedadeECD()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetEnviaContribuinte() == '1' }
	a_Estrut[nPosicao][15] := '0=Não é obrigada;1=Empresa obrigada a entrega ECD'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _CLASSIFTRIBTABELA8
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetClassifTribTabela8(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetClassifTribTabela8()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetEnviaContribuinte() == '1' }
	a_Estrut[nPosicao][15] := '01=Regime trib SN c/ trib prev substituída;'
	a_Estrut[nPosicao][15] += '02=Regime trib SN c/ trib prev não substituída;'
	a_Estrut[nPosicao][15] += '03=Regime trib SN c/ trib prev ambas;'
	a_Estrut[nPosicao][15] += '04=MEI - Micro Empreendedor Individual;'
	a_Estrut[nPosicao][15] += '06=Agroindústria;'
	a_Estrut[nPosicao][15] += '07=Produtor Rural Pessoa Jurídica;'
	a_Estrut[nPosicao][15] += '08=Consórcio Simplif. Produtores Rurais;'
	a_Estrut[nPosicao][15] += '09=Órgão Gestor de Mão de Obra;'
	a_Estrut[nPosicao][15] += '10=Entidade Sindical se refere a Lei 12.023/2009;'
	a_Estrut[nPosicao][15] += '11=Assoc Desportiva que mantém Clube de Futebol Profissional;'
	a_Estrut[nPosicao][15] += '13=Banco, caixa econômica, sociedade de crédito, financiamento e investimento e demais empresas relacionadas no parágrafo 1º do art. 22 da Lei 8.212./91;'
	a_Estrut[nPosicao][15] += '14=Sindicatos em geral, exceto aquele classificado no código [10];'
	a_Estrut[nPosicao][15] += '21=Pessoa Física, exceto Segurado Especial;'
	a_Estrut[nPosicao][15] += '22=Segurado Especial;'
	a_Estrut[nPosicao][15] += '60=Missão Diplomática ou Repart Consular de carreira estrangeira;'
	a_Estrut[nPosicao][15] += '70=Empresa de que trata o Decreto 5.436/2005;'
	a_Estrut[nPosicao][15] += '80=Entidade Imune ou Isenta;'
	a_Estrut[nPosicao][15] += '85=Ente Federativo, Órgãos da União, Autarquias e Fundações Públicas;'
	a_Estrut[nPosicao][15] += '99=Pessoas Jurídicas em Geral;'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _ACORDOINTERISENMULTAS
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetAcordoInterIsenMultas(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetAcordoInterIsenMultas()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetEnviaContribuinte() == '1' }
	a_Estrut[nPosicao][15] := '0=Sem acordo;1=Com acordo'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _NOMECONTRIBUINTE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 70
	a_Estrut[nPosicao][06] := '@!'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetNomeContribuinte(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetNomeContribuinte()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetEnviaContribuinte() == '1' }
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _CPFCONTRIBUINTE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 11
	a_Estrut[nPosicao][06] := '@R 999.999.999-99'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetCpfContribuinte(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetCpfContribuinte()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetEnviaContribuinte() == '1' }
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _TELEFONECONTRIBUINTE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 10
	a_Estrut[nPosicao][06] := '@R (99) 9999-9999'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetTelContribuinte(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetTelContribuinte()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetEnviaContribuinte() == '1' }
	a_Estrut[nPosicao][16] := nFolder
		
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _CELULARCONTRIBUINTE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 11
	a_Estrut[nPosicao][06] := '@R (99) 99999-9999'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetCelularContribuinte(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetCelularContribuinte()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetEnviaContribuinte() == '1' }
	a_Estrut[nPosicao][16] := nFolder
		
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _EMAILCONTRIBUINTE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 60
	a_Estrut[nPosicao][06] := '@!'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetEmailContribuinte(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetEmailContribuinte()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetEnviaContribuinte() == '1' }
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _ENTEFEDERATIVO
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetEnteFederativo(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetEnteFederativo()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetEnviaContribuinte() == '1' }
	a_Estrut[nPosicao][15] := '1=Sim;2=Não'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _CNPJENTEFEDERATIVO
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 14
	a_Estrut[nPosicao][06] := '@R 99.999.999/9999-99'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetCnpjEnteFederativo(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetCnpjEnteFederativo()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetEnviaContribuinte() == '1' }
	a_Estrut[nPosicao][16] := nFolder
		
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _INDDESONERACAOCPRB
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetIndDesoneracaoCPRB(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetIndDesoneracaoCPRB()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetEnviaContribuinte() == '1' }
	a_Estrut[nPosicao][15] := '0=Não aplicável;1=Emp. enquadrada termos Lei 12.546/20'
	a_Estrut[nPosicao][16] := nFolder
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _INDSITUACAOPJ
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 1
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetIndSituacaoPj(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetIndSituacaoPJ()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetEnviaContribuinte() == '1' }
	a_Estrut[nPosicao][15] := '0=Sem acordo;1=Com acordo'
	a_Estrut[nPosicao][16] := nFolder
	
	
//	Monta a estrutura E-mail de contato para Reinf
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _EMAILCONTATOREINF
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 60
	a_Estrut[nPosicao][06] := '@!'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetEmail_ContatoReinf(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetEmail_ContatoReinf()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetEnviaContribuinte() == '1' }
	a_Estrut[nPosicao][16] := nFolder

//	Monta a estrutura Nome de contato para Reinf
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _NOMECONTATOREINF
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 70
	a_Estrut[nPosicao][06] := '@!'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetNome_ContatoReinf(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetNome_ContatoReinf()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetEnviaContribuinte() == '1' }
	a_Estrut[nPosicao][16] := nFolder

//	Monta a estrutura CPF do contato para Reinf
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _CPFCONTATOREINF
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 14
	a_Estrut[nPosicao][06] := '@R 999.999.999-99'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetCPF_ContatoReinf(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetCPF_ContatoReinf()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetEnviaContribuinte() == '1' }
	a_Estrut[nPosicao][16] := nFolder

//	Monta a estrutura DDD do Telefone contato para Reinf
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _DDDCONTATOREINF
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 2
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetDDD_ContatoReinf(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetDDD_ContatoReinf()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetEnviaContribuinte() == '1' }
	a_Estrut[nPosicao][16] := nFolder

//	Monta a estrutura Telefone do contato para Reinf
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _TELCONTATOREINF
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 10
	a_Estrut[nPosicao][06] := '@R 9999-9999'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetTEL_ContatoReinf(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetTEL_ContatoReinf()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetEnviaContribuinte() == '1' }
	a_Estrut[nPosicao][16] := nFolder

//	Monta a estrutura DDD do Celular do contato para Reinf
	nPosicao := AddStruct(@a_Estrut) 
	
	a_Estrut[nPosicao][01] := _DDDCELULARCONTATOREINF
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 2
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetDDDCEL_ContatoReinf(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetDDDCEL_ContatoReinf()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetEnviaContribuinte() == '1' }
	a_Estrut[nPosicao][16] := nFolder

//	Monta a estrutura Celular do contato para Reinf
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _CELULARCONTATOREINF
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 11
	a_Estrut[nPosicao][06] := '@R 99999-9999'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetCEL_ContatoReinf(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetCEL_ContatoReinf()'
	a_Estrut[nPosicao][12] := {|| oWizard:GetEnviaContribuinte() == '1' }
	a_Estrut[nPosicao][16] := nFolder
	
Return Nil

/*/{Protheus.doc} fPnDdFld07
	(Função para montar o folder 7 (Empresa Software).)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Estrut, array, contem a estrutura do msmget.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fPnDdFld07(a_Estrut)

	Local nPosicao := 0
	Local nFolder := 0
	
	Default a_Estrut := {}
	
	nFolder := 7
	
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _CNPJEMPSOFTWARE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 14
	a_Estrut[nPosicao][06] := '@R 99.999.999/9999-99'
	a_Estrut[nPosicao][07] := &('{|| ValidPag07(oWizard,'+lTrim(str(nPosicao,3))+'), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetCnpjEmpSoftware()'
	a_Estrut[nPosicao][11] := 'SA2EXT'
	a_Estrut[nPosicao][16] := nFolder

   	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _RAZAOSOCIALEMPSOFTWARE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 115
	a_Estrut[nPosicao][06] := '@!'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetRazaoSocialEmpSoftware(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetRazaoSocialEmpSoftware()'
	a_Estrut[nPosicao][16] := nFolder
		
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _CONTATOEMPSOFTWARE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 70
	a_Estrut[nPosicao][06] := '@!'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetContatoEmpSoftware(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetContatoEmpSoftware()'
	a_Estrut[nPosicao][16] := nFolder
		
	// Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _TELEMPSOFTWARE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 13
	a_Estrut[nPosicao][06] := '@!'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetTelEmpSoftware(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetTelEmpSoftware()'
	a_Estrut[nPosicao][16] := nFolder

	 // Monta a estrutura
	nPosicao := AddStruct(@a_Estrut)
	
	a_Estrut[nPosicao][01] := _EMAILEMPSOFTWARE
	a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
	a_Estrut[nPosicao][03] := 'C'
	a_Estrut[nPosicao][04] := 60
	a_Estrut[nPosicao][06] := '@!'
	a_Estrut[nPosicao][07] := &('{|| oWizard:SetEmailEmpSoftware(W_PAR' + StrZero(nQtdCmp,3) + '), .T. }')
	a_Estrut[nPosicao][10] := 'oWizard:GetEmailEmpSoftware()'
	a_Estrut[nPosicao][16] := nFolder
	
Return Nil
	
/*/{Protheus.doc} fPnCfFld01
	(Monta o Folder das tabelas do sistema.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Estrut, array, contem a estrutura do msmget.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fPnCfFld01(a_Estrut)

	Local nCount := 0
	Local nPosicao := 0
	Local nFolder := 0
	
	Local cIniPad := ''
	
	Default a_Estrut := {}

	nFolder := 1

	For nCount := 1 To Len(oFisaExtSx:_SX2)
		// Monta a estrutura
		nPosicao := AddStruct(@a_Estrut)

		// Pega a informação do parâmetro
		cIniPad := fGetString(&('oFisaExtSx:_' + oFisaExtSx:_SX2[nCount]))
				
		a_Estrut[nPosicao][01] := 'Existe a tabela: ' + oFisaExtSx:_SX2[nCount]
		a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
		a_Estrut[nPosicao][03] := 'C'
		a_Estrut[nPosicao][04] := Len(Alltrim(cIniPad))
		a_Estrut[nPosicao][10] := cIniPad
		a_Estrut[nPosicao][12] := {|| .F. }
		a_Estrut[nPosicao][15] := '.T.=Sim;.F.=Não'
		a_Estrut[nPosicao][16] := nFolder
	Next
	
Return

/*/{Protheus.doc} fPnCfFld02
	(Monta o Folder dos campos das tabelas.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Estrut, array, contem a estrutura do msmget.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fPnCfFld02(a_Estrut)

	Local nCount1 := 0
	Local nCount2 := 0
	Local nPosicao := 0
	Local nFolder := 0
	
	Local cIniPad := ''
	
	Default a_Estrut := {}

	nFolder := 2

	For nCount1 := 1 To Len(oFisaExtSx:_SX3)

		For nCount2 := 1 To Len(oFisaExtSx:_SX3[nCount1][2])
			// Monta a estrutura
			nPosicao := AddStruct(@a_Estrut)

			// Pega a informação do parâmetro
			cIniPad := fGetString(&('oFisaExtSx:_' + oFisaExtSx:_SX3[nCount1][2][nCount2]))
					
			a_Estrut[nPosicao][01] := 'Existe o campo: ' + oFisaExtSx:_SX3[nCount1][2][nCount2]
			a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
			a_Estrut[nPosicao][03] := 'C'
			a_Estrut[nPosicao][04] := Len(Alltrim(cIniPad))
			a_Estrut[nPosicao][10] := cIniPad
			a_Estrut[nPosicao][12] := {|| .F. }
			a_Estrut[nPosicao][15] := '.T.=Sim;.F.=Não'
			a_Estrut[nPosicao][16] := nFolder
		Next
		
	Next
	
Return

/*/{Protheus.doc} fPnCfFld03
	(Monta o Folder de parametrização do sistema.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Estrut, array, contem a estrutura do msmget.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fPnCfFld03(a_Estrut)

	Local nCount := 0
	Local nPosicao := 0
	Local nFolder := 0
	
	Local cIniPad := ''
	
	Default a_Estrut := {}

	nFolder := 3

	For nCount := 1 To Len(oFisaExtSx:_SX6)
		// Monta a estrutura
		nPosicao := AddStruct(@a_Estrut)

		// Pega a informação do parâmetro
		cIniPad := fGetString(&('oFisaExtSx:_' + oFisaExtSx:_SX6[nCount][1]))
				
		a_Estrut[nPosicao][01] := oFisaExtSx:_SX6[nCount][1]
		a_Estrut[nPosicao][02] := 'W_PAR' + StrZero(nQtdCmp,3)
		a_Estrut[nPosicao][03] := 'C'
		a_Estrut[nPosicao][04] := Len(Alltrim(cIniPad))
		a_Estrut[nPosicao][10] := cIniPad
		a_Estrut[nPosicao][12] := {|| .F. }
		a_Estrut[nPosicao][16] := nFolder
	Next
	
Return

/*/{Protheus.doc} fGetString
	(Função para retornar o inicializador padrão em uma strig.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param c_IniPad, caracter, inicializador padrão.

	@return cConteudo, caracter, inicializador padrão em um string.
	/*/
Static Function fGetString(c_IniPad)

	Local cConteudo := ''

	Default c_IniPad := Nil

	If ValType(c_IniPad) == 'N'
		cConteudo := AllTrim(Str((c_IniPad)))
	ElseIf ValType(c_IniPad) == 'L'
		cConteudo := IIf(c_IniPad,'.T.','.F.')
	ElseIf ValType(c_IniPad) == 'D'
		cConteudo := DToC(c_IniPad)
	Else
		cConteudo := c_IniPad
	EndIf
	
Return cConteudo

/*/{Protheus.doc} AddStruct
	(Função para adicionar um linha da estrutura do MsmGet.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Estrut, array, contem a estrutura do msmget.

	@return nPosicao, numerico, retorna a posição do array.
	/*/
Static Function AddStruct(a_Estrut)
	
	Local nPosicao := 0 
	
	Default a_Estrut := {}
	
	Aadd(a_Estrut,{})
	nPosicao := Len(a_Estrut)
	
	Aadd(a_Estrut[nPosicao],'')			// 01 - Titulo
	Aadd(a_Estrut[nPosicao],'')			// 02 - Campo
	Aadd(a_Estrut[nPosicao],'')			// 03 - Tipo
	Aadd(a_Estrut[nPosicao],0)			// 04 - Tamanho
	Aadd(a_Estrut[nPosicao],0)			// 05 - Decimal
	Aadd(a_Estrut[nPosicao],'')			// 06 - Picture
	Aadd(a_Estrut[nPosicao],{|| .T. })	// 07 - Valid
	Aadd(a_Estrut[nPosicao],.F.)		// 08 - Obrigat
	Aadd(a_Estrut[nPosicao],1)			// 09 - Nivel
	Aadd(a_Estrut[nPosicao],'')			// 10 - Inicializador Padrão
	Aadd(a_Estrut[nPosicao],'')			// 11 - F3
	Aadd(a_Estrut[nPosicao],{|| })		// 12 - When
	Aadd(a_Estrut[nPosicao],.F.)		// 13 - Visual
	Aadd(a_Estrut[nPosicao],.F.)		// 14 - Chave
	Aadd(a_Estrut[nPosicao],'')			// 15 - Box - Opção do combo
	Aadd(a_Estrut[nPosicao],0)			// 16 - Folder
	Aadd(a_Estrut[nPosicao],.F.)		// 17 - Não Alterável
	Aadd(a_Estrut[nPosicao],'')			// 18 - PictVar
	Aadd(a_Estrut[nPosicao],'N')		// 19 - Gatilho

	// Guarda a quantidade de campos criadas pelo MsmGet
	nQtdCmp++
	
Return nPosicao

/*/{Protheus.doc} MakeVar
	(Função para devolver um array com os campos do MsmGet conforme a estrutura passada, e transformar os campos em variaveis privates.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Estrut, array, contem a estrutura do msmget.

	@return aCampos, array, retorna os campos da estrutura.
	/*/
Static Function MakeVar(a_Estrut)
	
	Local nCount := 0
	
	Local aCampos := {}
	
	Local xValor := Nil

	Local cIniPad := ''
	
	Default a_Estrut := {}
	
	For nCount := 1 To Len(a_Estrut)
		// Adiciona o campo no array aCampos
		Aadd(aCampos,a_Estrut[nCount][2])

		cIniPad := a_Estrut[nCount][10]

		// Pega o valor para inicializar a variavel.
		If a_Estrut[nCount][3] == 'N'
			If Empty(cIniPad)
				cIniPad := '0'
			EndIf

			xValor := Val(cIniPad)
		ElseIf a_Estrut[nCount][3] == 'L'
			If Empty(cIniPad)
				cIniPad := '.F.'
			EndIf

			xValor := &cIniPad
		ElseIf a_Estrut[nCount][3] == 'D'
			If Empty(cIniPad)
				cIniPad := 'StoD("")'
			EndIf

			xValor := &cIniPad
		Else
			If Empty(cIniPad)
				cIniPad := Replicate(' ',a_Estrut[nCount][4])
			EndIf

			// Se o conteudo for uma função, variavel, etc...
			If Type(cIniPad) <> "U" .Or. 'oWizard:' $ cIniPad
				xValor := PadR(&cIniPad,a_Estrut[nCount][4])
			Else
				xValor := PadR(cIniPad,a_Estrut[nCount][4])
			EndIf

			If Empty(xValor)
				xValor := Replicate(' ',a_Estrut[nCount][4])
			EndIf
		EndIf

		If Empty(a_Estrut[nCount][10])
			// Adiciona o inicializador padrão.
			a_Estrut[nCount][10] := cIniPad
		EndIf

		// Cria a variavel do campo
		&(aCampos[nCount]) := xValor
	Next
	
Return aCampos

/*/{Protheus.doc} fMsgAlert
	(Função para dar mensagem de aviso conforme campo.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Estrut, array, contem a estrutura do msmget.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fMsgAlert(c_Campo)

	Local cMsgAlert := ""

	Default c_Campo := ""

	If c_Campo == "ENVIACONTRIBUINTE"
		If oWizard:GetEnviaContribuinte() == "1"			// Se envia o contribuinte
			cMsgAlert := "Utilizando esta opção o layout T001, que possui as informações do contribuinte, será enviado com o objetivo de atualizar o cadastro no TAF." + CRLF + CRLF
			cMsgAlert += "Dessa forma, pode causar perda de informações já cadastradas no TAF." + CRLF + CRLF
			cMsgAlert += "Verifique!"
		ElseIf oWizard:GetEnviaContribuinte() == "2"			// Se não envia o contribuinte
			cMsgAlert := "Utilizando esta opção o layout T001, que possui as informações do contribuinte, não será atualizado no TAF." + CRLF + CRLF
			cMsgAlert += "Dessa forma, o layout T001 será gerado somente para possibilitar a integração dos dados no TAF." + CRLF + CRLF
		EndIf

	EndIf

	
	// Se existir mensagem
	If !Empty(cMsgAlert)
		// Mostra em tela
		MsgAlert(cMsgAlert,"Atenção")
	EndIf

Return Nil

/*/{Protheus.doc} fValPag01
	(Função para validar a primeira pagina da wizard.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@return lContinua, logico, Se foi validado ou não.
	/*/
Static Function fValPag01()

	Local lContinua := .F.
	Local nCount1	:=0
	Local nCount2	:=0
	Local cTxtProb 	:= 'Esse usuário não tem permissão para acessar dados pessoais e/ou sensíveis, não será possível extrair os dados em arquivo texto.'
	Local cTxtSolu 	:= 'Mude o [Tipo de Saída:] para "2 - Banco de dados" ou solicite liberação de acesso ao administrador do sistema.'	
	Local lProtData	:= FindFunction('ProtData')

	For nCount1:=1 To Len(oP01MGet1:oBox:aDialogs)
		For nCount2:=1 To Len(oP01MGet1:oBox:aDialogs[nCount1]:cArgo:cArgo)
			Eval(oP01MGet1:oBox:aDialogs[nCount1]:cArgo:cArgo[nCount2]:bValid)
		Next nCount2
	Next nCount1

	lContinua := fObrPag01()

	if lContinua
		//Valida se vai extrair em arquivo .txt e se usuario tem acesso a dados pessoais/sensiveis.
		if oWizard:GetTipoSaida() == '1' .and. lProtData
			lContinua := ProtData(.t.,cTxtProb,cTxtSolu)
		endif	
	endif	

	If lContinua
		// Se for arquivo txt
		If oWizard:GetTipoSaida() == "1" 	
			// Se não foi possivel criar o diretorio
			If Empty(oWizard:GetSystemDiretorio()) 
				lContinua := .F.
				Help( ,,"CRIADIR",, "Não foi possível criar o diretório!" + CRLF + CRLF + "Não será possivel a extrair via txt. Erro: " + cValToChar( FError() ) , 1, 0 )
			EndIf
		EndIf
	EndIf

	If lContinua
		If FirstDay(oWizard:GetDataDe()) <> oWizard:GetDataDe() .Or. LastDay(oWizard:GetDataAte()) <> oWizard:GetDataAte() .Or. Month(oWizard:GetDataDe()) <> Month(oWizard:GetDataAte())
			MsgAlert("Não foi selecionado um período fiscal de um mês!" + CRLF + CRLF + "Os layout's mensais não poderam ser gerados.","Atenção")
			lMarkVal := .F.

			SetMarkMes(.F.)
			fMarkMes(oWizard:GetLayouts())
		Else
			lMarkVal := .T.
		EndIf
		
		// Caso seja selecionada a opção Filtra Reinf = Não, o layout T001AN não deverá ser exibido.
		If oWizard:GetFiltraReinf() <> "2"
			// Se o CNPJ do contribuinte não for informado 
			If Empty(oWizard:GetCnpjEmpSoftware())
				If MsgNoYes("Não foi informado o CNPJ da empresa de software! Caso decida continuar o registro T001AN não poderá ser selecionado." + CRLF + CRLF + "Deseja continuar?","Atenção")
					oWizard:LayoutDel("T001AN")
				Else
					lContinua := .F.
				EndIf
			Else
				oWizard:LayoutInc("T001AN")
			EndIf
		Else
			oWizard:LayoutDel("T001AN")
		EndIf
	EndIf

	If lContinua
		// Grava a wizard
		oWizard:WriteWizard()

		If ValType(oP02BLay) == 'O'
			oP02BLay:SetArray(aLaysBrw)
			oP02BLay:Refresh()

			oP02BRel:SetArray(aLayRela)
			oP02BRel:Refresh()
		EndIf
		nPagina++
	EndIf


Return lContinua

/*/{Protheus.doc} fObrPag01
	(Função para verificar os campos obrigatorios.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@return lContinua, logico, Se foi volta ou não.
	/*/
Static Function fObrPag01()

	Local cMsgErro := ""
	Local nWeb :=  GETREMOTETYPE()
	Local lContinua := .F.

	If Empty(oWizard:GetTipoSaida())
		cMsgErro += _TIPOSAIDA + CRLF
	Else
		// Se for arquivo txt
		If oWizard:GetTipoSaida() == "1"
			If Empty(oWizard:GetDiretorioDestino()) .and. nWeb <> 5
				cMsgErro += _DIRETORIODESTINO +	 CRLF
			EndIf

			If Empty(oWizard:GetArquivoDestino())
				cMsgErro += _ARQUIVODESTINO + CRLF
			EndIf
		EndIf
	EndIf
	
	If Empty(oWizard:GetDataDe())
		cMsgErro += _DATADE + CRLF
	EndIf
	
	If Empty(oWizard:GetDataAte())
		cMsgErro += _DATAATE + CRLF
	EndIf

	If Empty(oWizard:GetTipoMovimento())
		cMsgErro += _TIPOMOVIMENTO + CRLF
	EndIf

	If Empty(oWizard:GetNotaAte())
		cMsgErro += _NOTAATE + CRLF
	EndIf

	If Empty(oWizard:GetSerieAte())
		cMsgErro += _SERIEATE + CRLF
	EndIf

	If Empty(oWizard:GetCentralizarUnicaFilial())
		cMsgErro += _CENTRALIZARUNICAFILIAL + CRLF
	EndIf

	If Empty(oWizard:GetFiltraReinf())
		cMsgErro += _FILTRAREINF + CRLF
	EndIf

	If Empty(oWizard:GetFiltraInteg())
		cMsgErro += _FILTRAINTEG + CRLF
	EndIf

	If Empty(cMsgErro)
		lContinua := .T.
	Else
		MsgAlert("Os campos abaixo são obrigatórios:" + CRLF + CRLF + cMsgErro + CRLF + "Verifique.","Atenção")
	EndIf

	if  nWeb == 5 .and. oWizard:GetTipoSaida() == "1" .and. lContinua
		MSGALERT("Você está utilizando a versão WEB do sistema,será realizado um download do arquivo. " ,"Aviso." )
	EndIF

Return lContinua

/*/{Protheus.doc} fMakePag02
	(Função para montar a segunda pagina da wizard.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param o_Dialog, objeto, pagina da wizard.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fMakePag02(o_Dialog)

	Local oP02Layer := Nil
	Local oP02Pane1 := Nil
	Local oP02Pane2 := Nil
	Local oP02Pane3 := Nil
	
	Local bMark := {|| aLaysBrw[oP02BLay:At()][1] }
	Local bMarkOne := {|| IIf(fVldMrkOne(aLaysBrw,oP02BLay:At()),fMarkOne(aLaysBrw,oP02BLay:At()),) }

	Local cDesBLay 	 := ""
	Local cLayCad	 := ""
	Local cLayMov	 := ""
	Local cLayImp	 := ""
	Local cTitle 	 := ""
	Local cBody		 := ""
	Local cFilInteg := If(!empty(oWizard:GetFiltraInteg()),oWizard:GetFiltraInteg(),"3")
	Local lFilReinf	:= (oWizard:GetFiltraReinf() == "1")
	Local nI				:= 0

	Default o_Dialog := Nil

	if cFilInteg $ " 12"
		cDesBLay := "Layouts a serem considerados no processamento"
	elseif cFilInteg == "3"
		cDesBLay := "Marque os layouts a serem considerados no processamento"
	endif

	oP02Layer := FWLayer():new()
	oP02Layer:Init(o_Dialog,.F.)
	
	If !lFilReinf
		//Preencho o array de acordo com o selecionado no novo campo.
		For nI := 1 to Len(oWizard:aLayouts)
			If cFilInteg == "1" .And. oWizard:aLayouts[nI,6] == "C"
				Aadd(aLaysBrw, oWizard:aLayouts[nI])
			ElseIf cFilInteg == "2" .And. oWizard:aLayouts[nI,6] == "M"
				Aadd(aLaysBrw, oWizard:aLayouts[nI])
			ElseIf cFilInteg == "3" 
				Aadd(aLaysBrw, oWizard:aLayouts[nI])
			EndIf
		Next nI
		
		// Adicionando linhas
		oP02Layer:AddLine('LIN1',10,.F.)
		oP02Layer:AddLine('LIN2',90,.F.)

		//Adicionando colunas nas linhas
		oP02Layer:AddCollumn('COL1',100,.F.,'LIN1')
		oP02Layer:AddCollumn('COL1',100,.F.,'LIN2')

		// Adicionando Windows nas colunas
		If cRelease <> 'R8'
			oP02Layer:AddWindow('COL1','WIN1',cDesBLay,100,.F.,.F.,,'LIN2')
		EndIf

		// Pega o painel 
		oP02Pane1 := oP02Layer:getLinePanel('LIN1')

		If cRelease == 'R8'
			oP02Pane2 := oP02Layer:getLinePanel('LIN2')
		Else
			// Pega o window
			oP02Pane2 := oP02Layer:getWinPanel('COL1','WIN1','LIN2')
		EndIf

		If (cFilInteg $ "1|3" .Or. Empty(cFilInteg))
			@ 007,003 CheckBox oP02CBAll Var lMarkALay Prompt OemToAnsi('Marca todos') Size 50,10 Of oP02Pane1 PIXEL ON Click fMarkAll(aLaysBrw) When lMarkVal

			@ 007,052 CheckBox oP02CBDia Var lMarkDia Prompt OemToAnsi('Diario') Size 50,10 Of oP02Pane1 PIXEL ON Click fMarkDia(aLaysBrw)

			@ 007,085 CheckBox oP02CBMes Var lMarkMes Prompt OemToAnsi('Mensal') Size 50,10 Of oP02Pane1 PIXEL ON Click fMarkMes(aLaysBrw) When lMarkVal
		EndIf

		oP02BLay := FwFormBrowse():New()
		If (cFilInteg $ "1|3" .Or. Empty(cFilInteg))
			oP02BLay:AddMarkColumns(bMark,bMarkOne)
		EndIf
		oP02BLay:FwBrowse():DisableReport()
		oP02BLay:FwBrowse():DisableConfig()
		oP02BLay:FwBrowse():DisableFilter()
		oP02BLay:FwBrowse():DisableLocate()
		oP02BLay:FwBrowse():DisableSeek()
		oP02BLay:FwBrowse():lHeaderClick:=.F.
		oP02BLay:SetColumns(fMkData01())
		oP02BLay:SetDataArray()
		oP02BLay:SetArray(aLaysBrw)
		oP02BLay:SetDoubleClick(bMarkOne)
		oP02BLay:SetChange({|| fChgBrwLay() })
		oP02BLay:SetOwner(oP02Pane2)
		oP02BLay:SetDescription(cDesBLay)
		oP02BLay:ForceQuitButton(.F.)
		oP02BLay:SetFixedBrowse(.T.)
		oP02BLay:Activate(oP02Pane2)
	Else
		//Preencho o array de acordo com o selecionado no novo campo.
		For nI := 1 to Len(oWizard:aLayReinf)
			If cFilInteg == "1" .And. oWizard:aLayReinf[nI,6] == "C"
				Aadd(aLaysBrw, oWizard:aLayReinf[nI])
			ElseIf cFilInteg == "2" .And. oWizard:aLayReinf[nI,6] == "M"
				Aadd(aLaysBrw, oWizard:aLayReinf[nI])
			ElseIf cFilInteg == "3" 
				Aadd(aLaysBrw, oWizard:aLayReinf[nI])
			EndIf
		Next nI

		oP02Layer:AddLine('LIN1',10,.F.)
		oP02Layer:AddLine('LIN2',90,.F.)

		// Adicionando colunas nas linhas
		oP02Layer:AddCollumn('COL1',100,.F.,'LIN1') 
		oP02Layer:AddCollumn('COL1',100,.F.,'LIN2')

		// Adicionando Windows nas colunas
		If cRelease <> 'R8'
			oP02Layer:AddWindow('COL1','WIN1',"Leiautes Considerados na Reinf",100,.F.,.F.,,'LIN2')
		EndIf

		// Pega o painel 		
		If cRelease == 'R8'
			oP02Pane2 := oP02Layer:getLinePanel('LIN2')
		Else
			// Pega o window
			oP02Pane2 := oP02Layer:getWinPanel('COL1','WIN1','LIN2')
		EndIf

		oP02BLay := FwFormBrowse():New()
		oP02BLay:FwBrowse():DisableReport()
		oP02BLay:FwBrowse():DisableConfig()
		oP02BLay:FwBrowse():DisableFilter()
		oP02BLay:FwBrowse():DisableLocate()
		oP02BLay:FwBrowse():DisableSeek()
		oP02BLay:FwBrowse():lHeaderClick:=.F.
		oP02BLay:SetColumns(fMkDataRei())
		oP02BLay:SetDataArray()
		oP02BLay:SetArray(aLaysBrw)
		oP02BLay:SetDoubleClick(bMarkOne)
		oP02BLay:SetChange({|| fChgBrwLRei() })
		oP02BLay:SetOwner(oP02Pane2)
		oP02BLay:ForceQuitButton(.F.)
		oP02BLay:SetFixedBrowse(.T.)
		oP02BLay:Activate(oP02Pane2)
	Endif

Return Nil

/*/{Protheus.doc} fVldMrkOne
	(Função para validar se pode marcar um registro ou não.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Cols, array, contém o array que será marcado.
	@param n_Posicao, numerico, contém a linha do a_Cols.

	@return lContinua, logico, Se foi validado ou não.
	/*/
Static Function fVldMrkOne(a_Cols,n_Posicao)

	Local lContinua := .T.

	Default a_Cols := {}

	Default n_Posicao := 0
	
	If !Empty(n_Posicao)
		If !lMarkVal .And. a_Cols[n_Posicao][4] == "MENSAL"
			MsgAlert("Não foi selecionado um período fiscal de um mês!" + CRLF + CRLF + "Esse layout não pode ser selecionado.","Atenção")
			lContinua := .F.
		EndIf
	EndIf

Return lContinua

/*/{Protheus.doc} fMarkOne
	(Função para marcar uma linha.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Cols, array, contém o array que será marcado.
	@param n_Posicao, numerico, contém a linha do a_Cols.
	@param c_Mark, caracter, contém a marca.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fMarkOne(a_Cols,n_Posicao,c_Mark)
	
	Default a_Cols := {}

	Default n_Posicao := 0
	
	Default c_Mark := ''
	
	If !Empty(n_Posicao)
		If Empty(c_Mark)
			If a_Cols[n_Posicao][1] == _MARK_NO_
				a_Cols[n_Posicao][1] := _MARK_OK_
			Else
				a_Cols[n_Posicao][1] := _MARK_NO_
			EndIf
			
			SetMarkAll()
		Else
			a_Cols[n_Posicao][1] := c_Mark
		EndIf
	EndIf
	
Return Nil

/*/{Protheus.doc} fMarkAll
	(Função para marcar todas as linhas.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Cols, array, contém o array que será marcado.
	@param l_MarkLay, logico, Se marca o layouts ou filiais

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fMarkAll(a_Cols)
	
	Local nCount := 0

	Local lMarkAll := .T.

	Default a_Cols := {}
	
	If nPagina == 2
		lMarkALL := lMarkALay
	ElseIf nPagina == 3
		lMarkALL := lMarkAFil
	EndIf

	For nCount := 1 To Len(a_Cols)
		fMarkOne(a_Cols,nCount,IIf(lMarkAll,_MARK_OK_,_MARK_NO_))
	Next
	
	If nPagina == 2
		SetMarkDia(IIf(lMarkAll,.T.,.F.))

		SetMarkMes(IIf(lMarkAll,.T.,.F.))
	EndIf
	
	If nPagina == 2
		oP02CBAll:Refresh()
		oP02BLay:Refresh()
	ElseIf nPagina == 3
		oP03CBAll:Refresh()
		oP03BFil:Refresh()
	EndIf

Return

/*/{Protheus.doc} fMarkDia
	(Função para marcar os registros diários.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Cols, array, contém o array que será marcado.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fMarkDia(a_Cols)

	Local nCount := 0

	Default a_Cols := {}
	
	For nCount := 1 To Len(a_Cols)
		If a_Cols[nCount][4] == 'DIARIO'
			fMarkOne(a_Cols,nCount,IIf(lMarkDia,_MARK_OK_,_MARK_NO_))
		Else
			fMarkOne(a_Cols,nCount,IIf(lMarkMes,_MARK_OK_,_MARK_NO_))
		EndIf
	Next
	
	SetMarkAll()

	oP02BLay:Refresh()
	
Return Nil

/*/{Protheus.doc} fMarkMes
	(Função para marcar os registros mensal.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Cols, array, contém o array que será marcado.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fMarkMes(a_Cols)

	Local nCount := 0

	Default a_Cols := {}
	
	For nCount := 1 To Len(a_Cols)
		If a_Cols[nCount][4] == 'MENSAL'
			fMarkOne(a_Cols,nCount,IIf(lMarkMes,_MARK_OK_,_MARK_NO_))
		Else
			fMarkOne(a_Cols,nCount,IIf(lMarkDia,_MARK_OK_,_MARK_NO_))
		EndIf
	Next
	
	SetMarkAll()

	If ValType(oP02BLay) == 'O'
		oP02BLay:Refresh()
	EndIf
	
Return Nil

/*/{Protheus.doc} SetMarkAll
	(Função para atribuir o valor na variavel lMarkALay e lMarkAFil.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param l_MarkAll, logico, contem se está marcado todos ou não.

	@return nulo, não tem retorno.
	/*/
Static Function SetMarkReg(c_Registro,l_Mark)

	Local nPosicao := 0

	Default c_Registro := ""
	
	Default l_Mark := .F.

	// Se o registro foi informado
	If !Empty(c_Registro)
		// Procura o registro no array
		nPosicao := Ascan(aLaysBrw,{|x| Upper(x[2]) == c_Registro })

		// Se o reistro foi encontrado
		If !Empty(nPosicao)	
			If l_Mark .And. Upper(aLaysBrw[nPosicao][1]) == _MARK_NO_		// Se é para marcar e o registro esta desmarcado
				// Marca o registro
				fMarkOne(aLaysBrw,nPosicao,_MARK_OK_)
			ElseIf !l_Mark .And. Upper(aLaysBrw[nPosicao][1]) == _MARK_OK_	// Se é para desmarcar e o registro está marcado
				// Desmarca o registro
				fMarkOne(aLaysBrw,nPosicao,_MARK_ON_)
			EndIf
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} SetMarkAll
	(Função para atribuir o valor na variavel lMarkALay e lMarkAFil.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param l_MarkAll, logico, contem se está marcado todos ou não.

	@return nulo, não tem retorno.
	/*/
Static Function SetMarkAll(l_MarkAll)
	
	Default l_MarkAll := Nil
	
	If l_MarkAll == Nil
		If nPagina == 2		// Se a pagina da wizard for a segunda

			If lMarkALay .And. Ascan(aLaysBrw,{|x| Upper(x[1]) == _MARK_NO_ }) > 0
				l_MarkAll := .F.
			ElseIf !lMarkALay .And. Ascan(aLaysBrw,{|x| Upper(x[1]) == _MARK_NO_ }) < 1
				l_MarkAll := .T.
			EndIf

		ElseIf nPagina == 3	// Se a pagina da wizard for a terceira

			If lMarkAFil .And. Ascan(oWizard:aFiliais,{|x| Upper(x[1]) == _MARK_NO_ }) > 0
				l_MarkAll := .F.
			ElseIf !lMarkAFil .And. Ascan(oWizard:aFiliais,{|x| Upper(x[1]) == _MARK_NO_ }) < 1
				l_MarkAll := .T.
			EndIf

		EndIf
	EndIf
	
	If l_MarkAll <> Nil
		If nPagina == 2		// Se a pagina da wizard for a segunda

			lMarkALay := l_MarkAll

			If ValType(oP02BLay) == 'O'
				oP02BLay:Refresh()
				oP02CBAll:Refresh()
			EndIf

		ElseIf nPagina == 3	// Se a pagina da wizard for a terceira

			lMarkAFil := l_MarkAll

			If ValType(oP03BFil) == 'O'
				oP03BFil:Refresh()
				oP03CBAll:Refresh()
			EndIf
			
		EndIf
	EndIf
	
Return Nil

/*/{Protheus.doc} SetMarkDia
	(Função para atribuir o valor na variavel lMarkDia.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param l_MarkAll, logico, contem se está marcado todos ou não.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function SetMarkDia(l_MarkDia)
	
	Default l_MarkDia := Nil
	
	If l_MarkDia == Nil
		If lMarkDia .And. Ascan(aLaysBrw,{|x| Upper(x[4]) == 'DIARIO' .And. Upper(x[1]) == _MARK_NO_ }) > 0
			l_MarkDia := .F.
		ElseIf !lMarkDia .And. Ascan(aLaysBrw,{|x| Upper(x[4]) == 'DIARIO' .And. Upper(x[1]) == _MARK_NO_ }) < 1
			l_MarkDia := .T.
		EndIf
	EndIf
	
	If l_MarkDia <> Nil
		lMarkDia := l_MarkDia

		If ValType(oP02BLay) == 'O'
			oP02BLay:Refresh()
			oP02CBDia:Refresh()
		EndIf
	EndIf
	
Return Nil

/*/{Protheus.doc} SetMarkMes
	(Função para atribuir o valor na variavel lMarkMes.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param l_MarkAll, logico, contem se está marcado todos ou não.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function SetMarkMes(l_MarkMes)
	
	Default l_MarkMes := Nil
	
	If l_MarkMes == Nil
		If lMarkMes .And. Ascan(aLaysBrw,{|x| Upper(x[4]) == 'MENSAL' .And. Upper(x[1]) == _MARK_NO_ }) > 0
			l_MarkMes := .F.
		ElseIf !lMarkMes .And. Ascan(aLaysBrw,{|x| Upper(x[4]) == 'MENSAL' .And. Upper(x[1]) == _MARK_NO_ }) < 1
			l_MarkMes := .T.
		EndIf
	EndIf
	
	If l_MarkMes <> Nil
		lMarkMes := l_MarkMes
		
		If ValType(oP02BLay) == 'O'
			oP02BLay:Refresh()
			oP02CBMes:Refresh()
		EndIf
	EndIf
	
Return Nil

/*/{Protheus.doc} fMarkLay
	(Função para marcar apenas os layouts selecionados no filtra Reinf.)

	@type Static Function
	@author Bruno Cremaschi
	@since 21/02/2019

	@param 

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fMarkLay()

Local nI := 0

for nI := 1 to Len(aLaysBrw)
	fMarkOne(aLaysBrw,nI,_MARK_OK_)
Next nI

Return Nil

/*/{Protheus.doc} fChgBrwLay
	(Função para executar a cada alteração do browser dos layout's.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@return Nil, nulo, não tem retorno
	/*/
Static Function fChgBrwLay()

	fGetLayRel(aLaysBrw[oP02BLay:At()][5])
	
	If ValType(oP02BRel) == 'O'
		oP02BRel:SetArray(aLayRela)
		oP02BRel:Refresh()
	EndIf

Return Nil

/*/{Protheus.doc} fChgBrwLRei
	(Função para executar a cada alteração do browser dos layout's.)

	@type Static Function
	@author Henrique Pereira
	@since 10/02/2018 

	@return Nil, nulo, não tem retorno
	/*/
Static Function fChgBrwLRei()

	fGetLayRei(aLaysBrw[oP02BLay:At()][5])
	
	If ValType(oP02BRel) == 'O'
		oP02BRel:SetArray(aLayRRei)
		oP02BRel:Refresh()
	EndIf

Return Nil

/*/{Protheus.doc} fGetLayRel
	(Função para atribuir o array aLayRela com as informações dos layout's relacionados.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_LaRela, array, contém os layout's relacionados.

	@return Nil, nulo, não tem retorno
	/*/
Static Function fGetLayRel(a_LayRela)

	Local nCount := 0
	Local nPosicao := 0

	Default a_LayRela := {}

	aLayRela := {}

	For nCount := 1 To Len(a_LayRela)
		nPosicao := Ascan(aLaysBrw,{|x| Upper(x[2]) == a_LayRela[nCount] })

		If !Empty(nPosicao)
			Aadd(aLayRela,{aLaysBrw[nPosicao][2],aLaysBrw[nPosicao][3],aLaysBrw[nPosicao][4]})
		EndIf
	Next

	If Empty(aLayRela)
		Aadd(aLayRela,{'','','',.F.})
	EndIf

Return Nil

/*/{Protheus.doc} fGetLayRei
	(Função para atribuir o array aLayRela com as informações dos layout's relacionados.)

	@type Static Function
	@author Henrique Pereira
	@since 10/02/2018

	@param a_LaRela, array, contém os layout's relacionados.

	@return Nil, nulo, não tem retorno
	/*/
Static Function fGetLayRei(a_LayRela)

	Local nCount := 0
	Local nPosicao := 0

	Default a_LayRela := {}

	aLayRRei := {}

	For nCount := 1 To Len(a_LayRela) 
		nPosicao := Ascan(aLaysBrw,{|x| Upper(x[2]) == a_LayRela[nCount] })

		If !Empty(nPosicao)
			Aadd(aLayRRei,{aLaysBrw[nPosicao][2],aLaysBrw[nPosicao][3],aLaysBrw[nPosicao][4]})
		EndIf
	Next

	If Empty(aLayRRei)
		Aadd(aLayRRei,{'','','',.F.})
	EndIf

Return Nil

/*/{Protheus.doc} fMkData01
	(Função para adicionar uma coluna no Browse em tempo de execução.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@Return aColumns, array, multidimensional contendo objetos da FWBrwColumn.
	/*/
Static Function fMkData01()

	Local oColuna := Nil

	Local aColumns := {}
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)    	   	// Indica se <E9> editavel
	oColuna:SetTitle('Código')		// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(10)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| aLaysBrw[oP02BLay:At()][2] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)    	   	// Indica se <E9> editavel
	oColuna:SetTitle('Descrição')	// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(60)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| aLaysBrw[oP02BLay:At()][3] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)       		// Indica se <E9> editavel
	oColuna:SetTitle('Período')		// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(6)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| aLaysBrw[oP02BLay:At()][4] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)       		// Indica se <E9> editavel
	oColuna:SetTitle('')			// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(6)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| "" }'))
	
	Aadd(aColumns,oColuna)
	
Return aColumns

/*/{Protheus.doc} fMkDataRei
	(Função para adicionar uma coluna no Browse em tempo de execução.)

	@type Static Function
	@author Henrique Pereira
	@since 10/02/2018

	@Return aColumns, array, multidimensional contendo objetos da FWBrwColumn.
	/*/
Static Function fMkDataRei()

	Local oColuna := Nil

	Local aColumns := {}
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)    	   	// Indica se <E9> editavel
	oColuna:SetTitle('Código')		// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(10)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| aLaysBrw[oP02BLay:At()][2] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)    	   	// Indica se <E9> editavel
	oColuna:SetTitle('Descrição')	// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(60)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| aLaysBrw[oP02BLay:At()][3] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)       		// Indica se <E9> editavel
	oColuna:SetTitle('Período')		// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(6)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| aLaysBrw[oP02BLay:At()][4] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)       		// Indica se <E9> editavel
	oColuna:SetTitle('')			// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(6)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| "" }'))
	
	Aadd(aColumns,oColuna)
	
Return aColumns

/*/{Protheus.doc} fMkData02
	(Função para adicionar uma coluna no Browse em tempo de execução.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@Return aColumns, array, multidimensional contendo objetos da FWBrwColumn.
	/*/
Static Function fMkData02()

	Local oColuna := Nil

	Local aColumns := {}
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)    	   	// Indica se <E9> editavel
	oColuna:SetTitle('Código')		// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(10)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| aLayRela[oP02BRel:At()][1] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)    	   	// Indica se <E9> editavel
	oColuna:SetTitle('Descrição')	// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(60)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| aLayRela[oP02BRel:At()][2] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)       		// Indica se <E9> editavel
	oColuna:SetTitle('Período')		// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(6)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| aLayRela[oP02BRel:At()][3] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)       		// Indica se <E9> editavel
	oColuna:SetTitle('')			// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(6)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| "" }'))
	
	Aadd(aColumns,oColuna)
	
Return aColumns

/*/{Protheus.doc} fMkDat2Rei
	(Função para adicionar uma coluna no Browse em tempo de execução.)

	@type Static Function
	@author Henrique Pereira
	@since 10/02/2018

	@Return aColumns, array, multidimensional contendo objetos da FWBrwColumn.
	/*/
Static Function fMkDat2Rei()

	Local oColuna := Nil

	Local aColumns := {}
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)    	   	// Indica se <E9> editavel
	oColuna:SetTitle('Código')		// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(10)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| aLayRRei[oP02BRel:At()][1] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)    	   	// Indica se <E9> editavel
	oColuna:SetTitle('Descrição')	// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(60)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| aLayRRei[oP02BRel:At()][2] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)       		// Indica se <E9> editavel
	oColuna:SetTitle('Período')		// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(6)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| aLayRRei[oP02BRel:At()][3] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)       		// Indica se <E9> editavel
	oColuna:SetTitle('')			// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(6)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| "" }'))
	
	Aadd(aColumns,oColuna)
	
Return aColumns

/*/{Protheus.doc} fValPag02
	(Função para validar a segunda pagina da wizard.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@return lContinua, logico, Se foi validado ou não.
	/*/
Static Function fValPag02()

	Local nPosicao  := 0
	Local lContinua := .F.

	if oWizard:GetFiltraReinf() == "1" .Or. ( oWizard:GetFiltraReinf() == "2" .And. oWizard:GetFiltraInteg() == "2" )
		fMarkLay()
	endif

	nPosicao := Ascan(aLaysBrw,{|x| Upper(x[1]) == _MARK_OK_ })

	If Empty(nPosicao)
		MsgAlert("Nenhum layout foi selecionado! Verifique.","Atenção")
	Else
		lContinua := .T.
	EndIf

	If lContinua
		nPagina++

		If Type("oP03BFil") == "O"
			oP03BFil:SetArray(oWizard:aFiliais)
			oP03BFil:Refresh()
		EndIf
	EndIf

Return lContinua

/*/{Protheus.doc} fRetPag02
	(Função executada no botão voltar da segunda pagina.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@return lContinua, logico, Se foi volta ou não.
	/*/
Static Function fRetPag02()

	Local lContinua := .F.

	//lContinua := .T.

	//If lContinua
	//	nPagina--
	//EndIf
	MsgInfo("Por conta da nova pergunta Filtra Apenas Reinf do passo 1 Parâmetros, não será possível retornar a partir do passo 2. "+ CRLF + CRLF+;
			'Caso queira alterar as configurações de geração, reinicie o processo!')

Return lContinua

/*/{Protheus.doc} fMakePag03
	(Função para montar a terceira pagina da wizard.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param o_Dialog, objeto, pagina da wizard.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fMakePag03(o_Dialog)
	
	Local oFont18 := Nil
	Local oP03Layer1 := Nil
	Local oP03Layer2 := Nil
	Local oP03Pane1 := Nil
	Local oP03Pane2 := Nil
	Local oP03Pane3 := Nil
	Local oP03Pane4 := Nil
	Local oP03Scroll := Nil
	Local oP03TSay := Nil
	
	Local bMark := {|| oWizard:aFiliais[oP03BFil:At()][1] }
	Local bMarkOne := {|| fMarkOne(oWizard:aFiliais,oP03BFil:At()) }
	Local bMarkAll := {|| SetMarkAll(IIf(lMarkAFil,.F.,.T.)), fMarkAll(oWizard:aFiliais) }
	
	Default o_Dialog := Nil

	// Fonte do texto
	oFont18 := TFont():New('Arial',,18,,.F.,,,,,.F.,.F.)
	
	//Inicializa o FWLayer
	oP03Layer1 := FWLayer():new()
	oP03Layer1:Init(o_Dialog,.F.)
	
	// Adicionando linhas
	oP03Layer1:AddLine('LIN1',100,.F.)
	
	// Adicionando colunas nas linhas
	oP03Layer1:AddCollumn('COL1',100,.F.,'LIN1')

	// Adicionando Windows nas colunas
	oP03Layer1:AddWindow('COL1','WIN1','Selecione as filiais a serem processadas - Empresa ' + cEmpAnt,100,.F.,.F.,,'LIN1')
		
	oP03Pane1 := oP03Layer1:getWinPanel('COL1','WIN1','LIN1')

	oP03Layer2 := FWLayer():new()
	oP03Layer2:Init(oP03Pane1,.F.)

	oP03Layer2:AddLine('LIN2',20,.F.)
	oP03Layer2:AddLine('LIN3',10,.F.)
	oP03Layer2:AddLine('LIN4',70,.F.)
	
	oP03Layer2:AddCollumn('COL2',100,.F.,'LIN2')
	oP03Layer2:AddCollumn('COL3',100,.F.,'LIN3')
	oP03Layer2:AddCollumn('COL4',100,.F.,'LIN4')

	// Pega o painel 
	oP03Pane2 := oP03Layer2:getLinePanel('LIN2')
	oP03Pane3 := oP03Layer2:getLinePanel('LIN3')
	oP03Pane4 := oP03Layer2:getLinePanel('LIN4')

	// Monta o box do 
	oP03Scroll := TScrollBox():New(oP03Pane2,0,0,(oP03Pane2:nHeight/2)-5,(oP03Pane2:nWidth/2)-2,.T.,.F.,.F.)
	oP03Scroll:Align := CONTROL_ALIGN_ALLCLIENT

	oP03TSay := TSay():New(0,0,,oP03Scroll,,oFont18,,,,.T.,CLR_BLACK,CLR_WHITE,(oP03Pane2:nWidth/2)-10,oP03Pane2:nHeight*2,,,,,,.T.)
	oP03TSay:SetCss('b{ color: #FF0000; }')
	oP03TSay:SetText( fGTextFil() )

	@ 007,003 CheckBox oP03CBAll Var lMarkAFil Prompt OemToAnsi('Marca todos') Size 50,10 Of oP03Pane3 PIXEL ON Click fMarkAll(oWizard:aFiliais)

	oP03BFil := FwFormBrowse():New()
	oP03BFil:AddMarkColumns(bMark,bMarkOne,bMarkAll)
	oP03BFil:FwBrowse():DisableReport()
	oP03BFil:FwBrowse():DisableConfig()
	oP03BFil:FwBrowse():DisableFilter()
	oP03BFil:FwBrowse():DisableLocate()
	oP03BFil:FwBrowse():DisableSeek()
	oP03BFil:SetColumns(fMkData03())
	oP03BFil:SetDataArray()
	oP03BFil:SetArray(oWizard:aFiliais)
	oP03BFil:SetDoubleClick(bMarkOne)
	oP03BFil:SetOwner(oP03Pane4)
	oP03BFil:ForceQuitButton(.F.)
	oP03BFil:SetFixedBrowse(.T.)
	oP03BFil:Activate(oP03Pane4)

Return Nil

/*/{Protheus.doc} fGTextFil
	(Função para retornar a mensagem referente a seleção de filiais.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@return cMensagem, caracter, mensagem.
	/*/
Static Function fGTextFil()

	Local cMensagem := ''

	cMensagem := '<p>'
	cMensagem += 'Para a correta geração das obrigações acessórias é fundamental que exista somente uma filial cadastrada para cada combinação de '
	cMensagem += '<b>Empresa + CNPJ + Inscrição Estadual + Código do Município + Inscrição Municipal</b> no TAF.'
	cMensagem += '</p>'

	If oWizard:GetCentralizarUnicaFilial() == '2'
		cMensagem += '<p>'
		cMensagem += 'Nesta extração, a opção de <b>CENTRALIZAÇÃO</b> foi selecionada, e uma análise de todas as filiais vinculadas a empresa logada foi realizada, sugerindo se elas podem ou não ser centralizadas conforme quadro abaixo: '
		cMensagem += '</p>'
		cMensagem += '<p>'
		cMensagem += 'Neste modelo a filial logada (' + cFilAnt + ') será a centralizadora e de onde as apurações e totalizadores serão extraídos!'
		cMensagem += '</p>'
	Else
		cMensagem += '<p>'
		cMensagem += 'Nesta extração, a opção de <b>NÃO CENTRALIZAÇÃO</b>  foi selecionada, e uma análise de todas as filiais vinculadas a empresa logada foi realizada, sugerindo se elas podem ou não ser centralizadas conforme quadro abaixo:'
		cMensagem += '</p>'
		cMensagem += '<p>'
		cMensagem += 'Neste modelo as informações processadas serão extraídas separadamente, sem filial centralizadora!'
		cMensagem += '</p>'
	EndIf

Return cMensagem

/*/{Protheus.doc} fMkData03
	(Função para adicionar uma coluna no Browse em tempo de execução.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@Return aColumns, array, multidimensional contendo objetos da FWBrwColumn.
	/*/
Static Function fMkData03()

	Local oColuna := Nil

	Local aColumns := {}
	
	oColuna := FWBrwColumn():New()					// Cria objeto
	oColuna:SetEdit(.F.)    	  				 	// Indica se <E9> editavel
	oColuna:SetTitle('Filial Protheus')				// Define titulo
	oColuna:SetType('C')							// Define tipo
	oColuna:SetSize(10)								// Define tamanho
	oColuna:SetPicture('@!')						// Define picture
	oColuna:SetAlign('LEFT')						// Define alinhamento				
	oColuna:SetData(&('{|| oWizard:aFiliais[oP03BFil:At()][2] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()					// Cria objeto
	oColuna:SetEdit(.F.)    	 				  	// Indica se <E9> editavel
	oColuna:SetTitle('Descrição')					// Define titulo
	oColuna:SetType('C')							// Define tipo
	oColuna:SetSize(30)								// Define tamanho
	oColuna:SetPicture('@!')						// Define picture
	oColuna:SetAlign('LEFT')						// Define alinhamento				
	oColuna:SetData(&('{|| oWizard:aFiliais[oP03BFil:At()][3] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()					// Cria objeto
	oColuna:SetEdit(.F.)       						// Indica se <E9> editavel
	oColuna:SetTitle('Sugestão de extração')		// Define titulo
	oColuna:SetType('C')							// Define tipo
	oColuna:SetSize(60)								// Define tamanho
	oColuna:SetPicture('@!')						// Define picture
	oColuna:SetAlign('LEFT')						// Define alinhamento				
	oColuna:SetData(&('{|| oWizard:aFiliais[oP03BFil:At()][4] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()					// Cria objeto
	oColuna:SetEdit(.F.)       						// Indica se <E9> editavel
	oColuna:SetTitle('Dados da Filial Protheus')	// Define titulo
	oColuna:SetType('C')							// Define tipo
	oColuna:SetSize(60)								// Define tamanho
	oColuna:SetPicture('@!')						// Define picture
	oColuna:SetAlign('LEFT')						// Define alinhamento				
	oColuna:SetData(&('{|| oWizard:aFiliais[oP03BFil:At()][5] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()					// Cria objeto
	oColuna:SetEdit(.F.)       						// Indica se <E9> editavel
	oColuna:SetTitle('')							// Define titulo
	oColuna:SetType('C')							// Define tipo
	oColuna:SetSize(6)								// Define tamanho
	oColuna:SetPicture('@!')						// Define picture
	oColuna:SetAlign('LEFT')						// Define alinhamento				
	oColuna:SetData(&('{|| "" }'))
	
	Aadd(aColumns,oColuna)
	
Return aColumns

/*/{Protheus.doc} fValPag03
	(Função para validar a terceira pagina da wizard.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@return lContinua, logico, Se foi validado ou não.
	/*/
Static Function fValPag03()

	Local nPosicao := 0

	Local lContinua := .F.

	Local cMensagem := ""

	nPosicao := Ascan(oWizard:aFiliais,{|x| Upper(x[1]) == _MARK_OK_ })

	If Empty(nPosicao)
		MsgAlert("Nenhuma filial foi selecionada! Verifique.","Atenção")
	Else
		lContinua := .T.
	EndIf

	If lContinua
		//Quando o usuário selecionou a opção de centralização de filiais eu preciso setar a filial logada como
		//a ultima a ser processada, para considerar as apurações e totalizadores
		If oWizard:GetCentralizarUnicaFilial() == '2'   
			cFilCent := cFilAnt
			
			nPosicao := Ascan(oWizard:aFiliais,{|x| Upper(x[1]) == _MARK_NO_ .And. AllTrim(x[2]) == AllTrim(cFilCent) })

			If !Empty(nPosicao)
				lContinua := .F.
				MsgAlert(OemToAnsi("Na extração CENTRALIZADA a filial logada deve obrigatoriamente estar entre as filiais selecionadas para processamento! Verifique."),"Atenção")
			EndIf
		EndIf
	EndIf

	If lContinua
		// Percorre o array de filiais
		For nPosicao := 1 to Len (oWizard:aFiliais)
			// Se a filial foi selecionada
			If oWizard:aFiliais[nPosicao][1] == _MARK_OK_

				If SubString(oWizard:aFiliais[nPosicao][3],1,11) == 'CENTRALIZAR'
					// Se foi selecionado para não centralizar
					If oWizard:GetCentralizarUnicaFilial() == "1"
						cMensagem := "Existem filiais selecionadas que <b>SUGERIMOS</b> serem extraída(s) <b>COM " + CRLF 
						cMensagem += "CENTRALIZAÇÃO</b> e estão sendo processadas como <b>NÃO " + CRLF
						cMensagem += "CENTRALIZADAS</b>, prosseguir pode ocasionar erros na geração das " + CRLF
						cMensagem += "obrigações acessórias no TAF." + CRLF + CRLF

						Exit
					EndIf
				Else
					// Se foi selecionado para centralizar
					If oWizard:GetCentralizarUnicaFilial() == "2"
						cMensagem := "Existem filiais selecionadas que <b>SUGERIMOS</b> serem extraída(s) <b>SEM " + CRLF
						cMensagem += "CENTRALIZAÇÃO</b> e estão sendo processadas como " + CRLF
						cMensagem += "<b>CENTRALIZADAS</b>, prosseguir pode ocasionar erros na geração das " + CRLF
						cMensagem += "obrigações acessórias no TAF." + CRLF + CRLF

						Exit
					EndIf
				Endif
			EndIf	
		Next
		
		If !Empty(cMensagem)
			cMensagem += "<b>Deseja Continuar?</b>"

			// Se for a versão 11
			If cRelease == "R8"
				/*
					Na versão 11 a função 'MsgNoYes' não reconhece a quebra de linha gerando uma mensagem extensa na mesma linha
					Como o função 'Aviso' não reconhece HTML, retiro a geração de negrito.
				*/
				lContinua := Aviso("Amarração de filiais Incorreta",StrTran(StrTran(cMensagem,"<b>",""),"</b>",""),{"Sim","Não"},3) == 1
			Else
				lContinua := MsgNoYes(cMensagem,"Amarração de filiais Incorreta")
			EndIf
		EndIf
	EndIf

	If lContinua
		// Monta o array aFiliais
		aFiliais := fMkFiliais(oWizard:aFiliais)

		If Type("oP04BFil") == "O"
			oP04BFil:SetArray(aFiliais)
			oP04BFil:Refresh()

			oP04BLay:SetArray(aFiliais[1][6])
			oP04BLay:Refresh()
		EndIf

		nPagina++
	EndIf

Return lContinua

/*/{Protheus.doc} fRetPag03
	(Função executada no botão voltar da terceira pagina.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@return lContinua, logico, Se foi volta ou não.
	/*/
Static Function fRetPag03()

	Local lContinua := .F.

	lContinua := .T.

	If lContinua
		nPagina--
	EndIf

Return lContinua

/*/{Protheus.doc} fMakePag04
	(Função para montar a quarta pagina da wizard.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param o_Dialog, objeto, pagina da wizard.

	@return Nil, nulo, não tem retorno.
	/*/
Static Function fMakePag04(o_Dialog)

	Local oFont18 := Nil
	Local oP04Layer := Nil
	Local oP04Pane1 := Nil
	Local oP04Pane2 := Nil

	Local cDesBFil := "Filiais selecionadas"
	Local cDesBLay := "Layout's selecionados"

	Default o_Dialog := Nil

	// Fonte do texto
	oFont18 := TFont():New('Arial',,18,,.F.,,,,,.F.,.F.)
	
	//Inicializa o FWLayer
	oP04Layer := FWLayer():new()
	oP04Layer:Init(o_Dialog,.F.)
	
	// Adicionando linhas
	oP04Layer:AddLine('LIN1',50,.F.)
	oP04Layer:AddLine('LIN2',50,.F.)
	
	// Adicionando colunas nas linhas
	oP04Layer:AddCollumn('COL1',100,.F.,'LIN1')
	oP04Layer:AddCollumn('COL2',100,.F.,'LIN2')

	If cRelease <> 'R8'
		// Adicionando Windows nas colunas
		oP04Layer:AddWindow('COL1','WIN1',cDesBFil,100,.F.,.F.,,'LIN1')
		oP04Layer:AddWindow('COL2','WIN2',cDesBLay,100,.F.,.F.,,'LIN2')
		
		// Pega o painel 
		oP04Pane1 := oP04Layer:getWinPanel('COL1','WIN1','LIN1')
		oP04Pane2 := oP04Layer:getWinPanel('COL2','WIN2','LIN2')
	Else
		oP04Pane1 := oP04Layer:getLinePanel('LIN1')
		oP04Pane2 := oP04Layer:getLinePanel('LIN2')
	EndIf

	// Monta o browse das filiais
	oP04BFil := FwFormBrowse():New()
	oP04BFil:AddLegend("aFiliais[oP04BFil:At()][1] == 1","BR_BRANCO"	,"Não gerado / Não há dados")
	oP04BFil:AddLegend("aFiliais[oP04BFil:At()][1] == 2","BR_AMARELO"	,"Gerando")
	oP04BFil:AddLegend("aFiliais[oP04BFil:At()][1] == 3","BR_LARANJA"	,"Gerado parcial")
	oP04BFil:AddLegend("aFiliais[oP04BFil:At()][1] == 4","BR_VERDE"		,"Gerado com sucesso")
	//oP04BFil:AddLegend("aFiliais[oP04BFil:At()][1] == 5","BR_VERMELHO"	,"Ocorreu um erro")
	oP04BFil:FwBrowse():DisableReport()
	oP04BFil:FwBrowse():DisableConfig()
	oP04BFil:FwBrowse():DisableFilter()
	oP04BFil:FwBrowse():DisableLocate()
	oP04BFil:FwBrowse():DisableSeek()
	oP04BFil:FwBrowse():lHeaderClick:=.F.
	oP04BFil:SetColumns(fMkData04F())
	oP04BFil:SetDataArray()
	oP04BFil:SetArray(aFiliais)
	oP04BFil:SetChange({|| fChgBrwPrc() })
	oP04BFil:SetOwner(oP04Pane1)
	oP04BFil:SetDescription(cDesBFil)
	oP04BFil:ForceQuitButton(.F.)
	oP04BFil:SetFixedBrowse(.T.)
	oP04BFil:Activate(oP04Pane1)

	// Monta o browse dos layouts
	oP04BLay := FwFormBrowse():New()
	oP04BLay:AddLegend("aFiliais[oP04BFil:At()][6][oP04BLay:At()][1] == 1","BR_BRANCO"		,"Não gerado / Não há dados")
	oP04BLay:AddLegend("aFiliais[oP04BFil:At()][6][oP04BLay:At()][1] == 2","BR_AMARELO"		,"Gerando")
	oP04BLay:AddLegend("aFiliais[oP04BFil:At()][6][oP04BLay:At()][1] == 3","BR_VERDE"		,"Gerado com sucesso")
	//oP04BLay:AddLegend("aFiliais[oP04BFil:At()][6][oP04BLay:At()][1] == 4","BR_VERMELHO"	,"Ocorreu um erro")
	oP04BLay:FwBrowse():DisableReport()
	oP04BLay:FwBrowse():DisableConfig()
	oP04BLay:FwBrowse():DisableFilter()
	oP04BLay:FwBrowse():DisableLocate()
	oP04BLay:FwBrowse():DisableSeek()
	oP04BLay:FwBrowse():lHeaderClick:=.F.
	oP04BLay:SetColumns(fMkData04L())
	oP04BLay:SetDataArray()
	oP04BLay:SetArray(aFiliais[1][6])
	oP04BLay:SetOwner(oP04Pane2)
	oP04BLay:SetDescription(cDesBLay)
	oP04BLay:ForceQuitButton(.F.)
	oP04BLay:SetFixedBrowse(.T.)
	oP04BLay:Activate(oP04Pane2)

Return Nil

/*/{Protheus.doc} fMkFiliais
	(Função para montar os array aFiliais com os dados selecionados.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Filiais, array, contém as filiais.

	@Return aRetorno, array, retorna as filiais selecionadas.
	/*/
Static Function fMkFiliais(a_Filiais)

	Local nCount1 := 0
	Local nCount2 := 0
	Local nPosicao := 0

	Local aRetorno := {}

	Default a_Filiais := {}

	For nCount1 := 1 To Len(a_Filiais)
		If a_Filiais[nCount1][1] == _MARK_OK_
			Aadd(aRetorno,{})
			nPosicao := Len(aRetorno)

			Aadd(aRetorno[nPosicao],1)

			For nCount2 := 2 To Len(a_Filiais[nCount1])
				Aadd(aRetorno[nPosicao],a_Filiais[nCount1][nCount2])
			Next

			Aadd(aRetorno[nPosicao],fMkLayouts(aLaysBrw))
		EndIf
	Next

Return aRetorno

/*/{Protheus.doc} fMkLayouts
	(Função para montar os array aLayouts com os dados selecionados.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param a_Layouts, array, contém os layouts.

	@Return aRetorno, array, retorna os layouts selecionados.
	/*/
Static Function fMkLayouts(a_Layouts)

	Local nCount1 := 0
	Local nCount2 := 0
	Local nPosicao := 0

	Local aRetorno := {}

	Default a_Layouts := {}

	For nCount1 := 1 To Len(a_Layouts)
		If a_Layouts[nCount1][1] == _MARK_OK_
			Aadd(aRetorno,{})
			nPosicao := Len(aRetorno)

			Aadd(aRetorno[nPosicao],1)

			For nCount2 := 2 To 4
				Aadd(aRetorno[nPosicao],a_Layouts[nCount1][nCount2])
			Next

			nCount2 := 0

			Aadd(aRetorno[nPosicao],"SELECIONADO")

			// Se possui layouts relacionados
			If !Empty(a_Layouts[nCount1][5])
				// Percorre todos os layouts relacionados
				For nCount2 := 1 To Len(a_Layouts[nCount1][5])
					// Encontra o layout relacionado na lista
					nPosicao := Ascan(a_Layouts,{|x| Upper(x[2]) == a_Layouts[nCount1][5][nCount2] })

					// Se encontrar e o mesmo não foi marcado como selecionado
					If !Empty(nPosicao) .And. a_Layouts[nPosicao][1] == _MARK_NO_
						// Se o layout não estiver no array
						If Ascan(aRetorno,{|x| Upper(x[2]) == a_Layouts[nPosicao][2] }) < 1
							Aadd(aRetorno,{1,a_Layouts[nPosicao][2],a_Layouts[nPosicao][3],a_Layouts[nPosicao][4],"RELACIONADO"})
						EndIf
					EndIf
				Next
			EndIf
		EndIf
	Next

	// Ordena por layout
	ASort(aRetorno,,,{|x,y| x[2] < y[2] })

Return aRetorno

/*/{Protheus.doc} fMkData04F
	(Função para adicionar uma coluna no Browse em tempo de execução.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@Return aColumns, array, multidimensional contendo objetos da FWBrwColumn.
	/*/
Static Function fMkData04F()

	Local oColuna := Nil

	Local aColumns := {}
	
	oColuna := FWBrwColumn():New()					// Cria objeto
	oColuna:SetEdit(.F.)    	  				 	// Indica se <E9> editavel
	oColuna:SetTitle('Filial Protheus')				// Define titulo
	oColuna:SetType('C')							// Define tipo
	oColuna:SetSize(10)								// Define tamanho
	oColuna:SetPicture('@!')						// Define picture
	oColuna:SetAlign('LEFT')						// Define alinhamento				
	oColuna:SetData(&('{|| aFiliais[oP04BFil:At()][2] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()					// Cria objeto
	oColuna:SetEdit(.F.)    	 				  	// Indica se <E9> editavel
	oColuna:SetTitle('Descrição')					// Define titulo
	oColuna:SetType('C')							// Define tipo
	oColuna:SetSize(30)								// Define tamanho
	oColuna:SetPicture('@!')						// Define picture
	oColuna:SetAlign('LEFT')						// Define alinhamento				
	oColuna:SetData(&('{|| aFiliais[oP04BFil:At()][3] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()					// Cria objeto
	oColuna:SetEdit(.F.)       						// Indica se <E9> editavel
	oColuna:SetTitle('Sugestão de extração')		// Define titulo
	oColuna:SetType('C')							// Define tipo
	oColuna:SetSize(60)								// Define tamanho
	oColuna:SetPicture('@!')						// Define picture
	oColuna:SetAlign('LEFT')						// Define alinhamento				
	oColuna:SetData(&('{|| aFiliais[oP04BFil:At()][4] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()					// Cria objeto
	oColuna:SetEdit(.F.)       						// Indica se <E9> editavel
	oColuna:SetTitle('Dados da Filial Protheus')	// Define titulo
	oColuna:SetType('C')							// Define tipo
	oColuna:SetSize(60)								// Define tamanho
	oColuna:SetPicture('@!')						// Define picture
	oColuna:SetAlign('LEFT')						// Define alinhamento				
	oColuna:SetData(&('{|| aFiliais[oP04BFil:At()][5] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()					// Cria objeto
	oColuna:SetEdit(.F.)       						// Indica se <E9> editavel
	oColuna:SetTitle('')							// Define titulo
	oColuna:SetType('C')							// Define tipo
	oColuna:SetSize(6)								// Define tamanho
	oColuna:SetPicture('@!')						// Define picture
	oColuna:SetAlign('LEFT')						// Define alinhamento				
	oColuna:SetData(&('{|| "" }'))
	
	Aadd(aColumns,oColuna)
	
Return aColumns

/*/{Protheus.doc} fMkData04L
	(Função para adicionar uma coluna no Browse em tempo de execução.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@Return aColumns, array, multidimensional contendo objetos da FWBrwColumn.
	/*/
Static Function fMkData04L()

	Local oColuna := Nil

	Local aColumns := {}
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)    	   	// Indica se <E9> editavel
	oColuna:SetTitle('Código')		// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(10)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| aFiliais[oP04BFil:At()][6][oP04BLay:At()][2] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)    	   	// Indica se <E9> editavel
	oColuna:SetTitle('Descrição')	// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(60)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| aFiliais[oP04BFil:At()][6][oP04BLay:At()][3] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)       		// Indica se <E9> editavel
	oColuna:SetTitle('Período')		// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(6)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| aFiliais[oP04BFil:At()][6][oP04BLay:At()][4] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)       		// Indica se <E9> editavel
	oColuna:SetTitle('Tipo')		// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(15)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| aFiliais[oP04BFil:At()][6][oP04BLay:At()][5] }'))
	
	Aadd(aColumns,oColuna)
	
	oColuna := FWBrwColumn():New()	// Cria objeto
	oColuna:SetEdit(.F.)       		// Indica se <E9> editavel
	oColuna:SetTitle('')			// Define titulo
	oColuna:SetType('C')			// Define tipo
	oColuna:SetSize(6)				// Define tamanho
	oColuna:SetPicture('@!')		// Define picture
	oColuna:SetAlign('LEFT')		// Define alinhamento				
	oColuna:SetData(&('{|| "" }'))

	Aadd(aColumns,oColuna)

Return aColumns

/*/{Protheus.doc} fChgBrwPrc
	(Função para executar a cada alteração do browser de processamento.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@return Nil, nulo, não tem retorno
	/*/
Static Function fChgBrwPrc()

	If ValType(oP04BLay) == 'O'
		oP04BLay:SetArray(aFiliais[oP04BFil:At()][6])
		oP04BLay:Refresh()
	EndIf

Return Nil

/*/{Protheus.doc} fValPag04
	(Função para validar a quarta pagina da wizard.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@return lContinua, logico, Se foi validado ou não.
	/*/
Static Function fValPag04()

	Local lContinua := .F.

	If lExecutou
		lContinua := .T.

		If lContinua
			nPagina++
		EndIf
	Else
		// Executa a extração fiscal
		Processa({|| FisaExtExc() },"Extrator Fiscal","Aguarde...",.F.)

		lExecutou := .T.
	EndIf

Return lContinua

/*/{Protheus.doc} FisaExtW01
	(Função para atualizar a tela de processamento.)

	@type Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@param c_Filial, caracter, contém a filial
	@param n_StatFil, caracter, contém o status de geração da filial
	@param c_Layout, caracter, contém o layout
	@param n_StatLay, caracter, contém o status de geração do layout

	@return Nil, nulo, não tem retorno.
	/*/
Function FisaExtW01(c_Filial,n_StatFil,c_Layout,n_StatLay)

	Local nPosFilial := 0
	Local nPosLayout := 0
	Local nCount := 0

	Local aLayouts := {}

	Default c_Filial := ""
	Default c_Layout := ""

	Default n_StatFil := ""
	Default n_StatLay := ""

	// Se não for job
	If !lJob
		// Se foi passado a filial e o status da filial
		If !Empty(c_Filial)
			// Procura a filial no array
			nPosFilial := Ascan(aFiliais,{|x| x[2] == c_Filial })

			// Se encontrou a filial
			If !Empty(nPosFilial)
				// Se foi passado um status de filial
				If !Empty(n_StatFil)
					// Atualiza o status
					aFiliais[nPosFilial][1] := n_StatFil

					// Atualiza a tela
					oP04BFil:SetArray(aFiliais)
					oP04BFil:Refresh()
					oP04BFil:GoTo(nPosFilial)
				EndIf

				// Se foi passado o layout e o status do layout
				If !Empty(c_Layout) .And. !Empty(n_StatLay)
					// Procura o layout no array
					nPosLayout := Ascan(aFiliais[nPosFilial][6],{|x| x[2] == c_Layout })

					// Se encontrou o layout
					If !Empty(nPosLayout)
						// Atualiza o status
						aFiliais[nPosFilial][6][nPosLayout][1] := n_StatLay

						// Atualiza a tela
						oP04BLay:SetArray(aFiliais[nPosFilial][6])
						oP04BLay:Refresh()
						oP04BLay:GoTo(nPosLayout)
					Else
						// Se foi passado mais de um layout separado por pipe
						aLayouts := Separa(c_Layout,"|")
						
						// Se existir layouts
						If !Empty(aLayouts)
							// Ordena por layout decrescente
							ASort(aLayouts,,,{|x,y| x > y })

							// Percorre todos os layouts
							For nCount := 1 To Len(aLayouts)
								// Se tiver um layout
								If !Empty(aLayouts[nCount])
									// Procura o layout no array
									nPosLayout := Ascan(aFiliais[nPosFilial][6],{|x| x[2] == AllTrim(aLayouts[nCount]) })

									// Se encontrou o layout
									If !Empty(nPosLayout)
										// Atualiza o status
										aFiliais[nPosFilial][6][nPosLayout][1] := n_StatLay
									EndIf
								EndIf
							Next

							// Atualiza a tela
							oP04BLay:SetArray(aFiliais[nPosFilial][6])
							oP04BLay:Refresh()
							oP04BLay:GoTo(nPosLayout)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	// Minimiza o efeito de 'congelamento' da aplicação durante a execução de um processo longo forçando o refresh do Smart Client
	ProcessMessages()

Return Nil

/*/{Protheus.doc} FisaExtW02
	(Função para atualizar a tela de processamento.)

	@type Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@return Nil, nulo, não tem retorno.
	/*/
Function FisaExtW02()

	// Se não for job
	If !lJob

		// Atualiza a tela
		oP04BLay:SetArray(aFiliais[1][6])
		oP04BLay:Refresh()
		oP04BLay:GoTop()

		// Minimiza o efeito de 'congelamento' da aplicação durante a execução de um processo longo forçando o refresh do Smart Client
		ProcessMessages()
	EndIf

Return Nil

/*/{Protheus.doc} fRetPag04
	(Função executada no botão voltar da quarta pagina.)

	@type Static Function
	@author Vitor Ribeiro
	@since 05/02/2018

	@return lContinua, logico, Se foi volta ou não.
	/*/
Static Function fRetPag04()

	Local lContinua := .F.

	If lExecutou
		Alert("A extração fiscal já foi realizada!" + CRLF + CRLF + "Não pode mais voltar.")
	Else
		lContinua := .T.
	EndIf

	If lContinua
		nPagina--
	EndIf

Return lContinua

/*/{Protheus.doc} ValidPag07
	(Função de validação executada no campo de CNPJ da aba Empresa Software.)

	@type Function
	@author Katielly Rezende
	@since 09/12/2019
	/*/

Static Function ValidPag07(oWizard,nPosCNPJ)

Local cParCNPJ 	:= 'W_PAR'+strzero(nPosCNPJ++,3)
Local cParNome 	:= 'W_PAR'+strzero(nPosCNPJ++,3)
Local cParCont 	:= 'W_PAR'+strzero(nPosCNPJ++,3)
Local cParTel 	:= 'W_PAR'+strzero(nPosCNPJ++,3)
Local cParMail 	:= 'W_PAR'+strzero(nPosCNPJ  ,3)
Local cCmpCNPJ	:= &(cParCNPJ) 

oWizard:SetCnpjEmpSoftware(cCmpCNPJ)

If !Empty(cCmpCNPJ)
	dbSelectArea("SA2")
	SA2->(dbSetOrder(3))

	If SA2->(!dbSeek(xFilial("SA2")+cCmpCNPJ))
		Help( ,, 'CNPJ',, "Fornecedor não encontrado" , 1, 0 )
		&(cParNome)	:= Space(115)
		&(cParCont)	:= Space(70)
		&(cParTel )	:= Space(13)	
		&(cParMail)	:= Space(60)
	EndIf
Else
	Help( ,, 'CNPJ',, "Fornecedor não possui CNPJ" , 1, 0 )
	&(cParNome)	:= Space(115)
	&(cParCont)	:= Space(70)
	&(cParTel )	:= Space(13)	
	&(cParMail)	:= Space(60)
EndIf

Return Nil
