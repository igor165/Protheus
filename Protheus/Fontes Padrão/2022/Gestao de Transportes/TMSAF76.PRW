#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TMSAF76.CH'
#Include "FWMVCDEF.CH"
#xcommand aKill [<aArray>] => TM76LibArr(<aArray>)
#xcommand oKill [<oObj>]   => FreeObj(<oObj>);<oObj> := Nil

Static aAliasFil := {{"DF0","DF0"}		,{"DF1","DF1"}	,{"DT5","DT5"}	,{"DTQ","DTQ"}	,{"DTR","DTR"},;
					{"DUP","DUP"}		,{"DA3","DA3"}	,{"DA4","DA4"}	,{"DTW","DTW"}	,{"DT6","DT6"},;
					{"DTC","DTC"}		,{"DTY","DTY"}	,{"DDG","DDG"}	,{"SA1","SA1REM"}	,;
					{"SA1","SA1DES"}	,{"SA1","SA1CON"}	,{"SA1","SA1DEV"}}

Static aAliasSup := {"","","DF1","DUD","DTQ","DTQ","DTR","DUP","DTQ","DTC","DT5","DTQ","DTC","","","DTC",""}

Static aAliasNom := {{14,STR0050},{15,STR0051},{16,STR0052}	,{17,STR0053}} //"Clientes - Remetente"###"Clientes - Destinatario"###"Clientes - Consignatario"###"Clientes - Pagador"

Static cThreadNum:= StrZero(ThreadId(),20)
Static cUsuThread:= Iif(LockByName(cThreadNum,.F.,.F.),Substr(cUsuario,7,6),STR0054)//"Ja Locado"
Static lTM76BUT  := ExistBlock("TM76BUT") // Ponto de entrada para inclusao de opcoes no menu acoes relacionadas da rotina
Static lTMF76Din := ExistBlock("TMF76Din")// Ponto de entrada para inclusao de botoes na area superior da tela
Static lTMF76TOk := ExistBlock("TMF76TOk")// TudoOK da Tela do Painel
Static lTMF76INI := ExistBlock("TMF76INI")// Pré execução de Qualquer função do painel. TMF76EXE
Static lTMF76END := ExistBlock("TMF76END")// Pós execução de Qualquer função do painel. TMF76EXE
Static lTMF76RAD := ExistBlock("TMF76RAD")// Manipulação do Objeto Radio
Static lTMF76Cps := ExistBlock("TMF76Cps")// Manipulação dos campos a serem apresentaos
Static lTMF76ADD := ExistBlock("TMF76ADD")// Adiciona Nova Aba
Static lTMF76Fim := ExistBlock("TMF76Fim")// Fechamento da Tela do Painel
Static cNomeCampo := ""
Static cFilOriDTC := ""
Static cLotNfcDTC := ""
Static cFilDocDT6 := ""
Static cDocDT6    := ""
Static cSerieDT6  := "" 
Static nValorSE1  := 0 
Static nSaldoSE1 	:= 0
Static cSitSE1	:= ""
Static lTMF76QRY 	:= ExistBlock('TMF76QRY')// Complementa query
Static aTrechos 		:= {} //--Roteiro da viagem definido através da função TMSAF76Via
Static aRetPag	:= {}		
Static ctabAgd := GetNextAlias()
Static oTempTable := NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAF76  ³ Autor ³ Valdemar Roberto     ³ Data ³ 05/11/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Painel de Agendamento                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF76                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSAF76()
Local aSizeDlg   := FwGetDialogSize(oMainWnd)
Local nHeight    := aSizeDlg[3]
Local nWidth     := aSizeDlg[4] -5
Local aFolderAge := {}
Local aButtons   := {}
Local aColunas   := {}
Local nCntFor1   := 0
Local nCntFor2   := 0
Local nOpca      := 0
Local bAction    := {||.T.}

//-- Variaveis da tela
Local oFWLayer
Local oColumn

//-- Variaveis dos filtros dinamicos
Local oPanelUp
Local oButtonFil
Local oButtonDin
Local oButtonAtu
Local oPanelMidd
Local cPanel 		:= ""    
//-- Variaveis dos pontos de entrada
Local aButCust 	:= {}							// Array com as opcoes customizadas do menu acoes relacionadas da rotina

//-- Controle do tamanho das telas
Local nLarFolOpe := 0
Local nAltFolOpe := 0
Local nAltPanOpe := 0
Local nLarPanOpe := 0
Local nAltPanBut := 0
Local nLarPanBut := 0
Local nIniPanBut := 0
Local nTotTamBut := 0

Local aFields  := {}
Local aCampos  := {}
Local nCont    := 0

Private oDlgAge
//Deve ser private para nao dar erro em outras rotinas
Private cNumThread := cThreadNum

//-- Variaveis dos filtros dinamicos
Private aVetExp := {}
Private aFilBkp := {}

//-- Variaveis das operacoes
Private oPanelDown
Private oFolderOpe

//-- Variaveis dos agendamentos
Private oMarkAge
Private cCadastro  := STR0001 //Painel de Agendamento
Private aPaineis   := {}
Private aRotinas   := MenuDef76()
Private aPanAgeTms  := {}
Private aBrowseDF1 := Array(4)
Private aBrowseOpe := Array(len(aRotinas),5)
Private nFldr      := 1
Private lAltServ   := .F.
Private aVetPrg    := {}
Private cFilOri76  := Space(Len(DTQ->DTQ_FILORI))
Private cViagem76  := Space(Len(DTQ->DTQ_VIAGEM))
Private aSetKeyF12 := {}
Private aSetKeyF76	:= {}

If !AliasInDic("DDA")
	Aviso( STR0001,STR0055 ,{STR0056}) //--"Painel de Agendamento"###"Opção não disponível neste release. Aguarde liberações futuras."###"OK"
	Return( .F. )
EndIf

//--Montagem do Filtro dinamico de acordo com as respostas do Pergunte TMSAF76
aVetExp := TmsaF76Per()

If Empty(aVetExp)
	Return (.F.)
EndIf

If !TmsCFec()
	Aviso(STR0057,STR0058,{STR0056})//"Atencao !"###"O parametro MV_TMSCFEC nao esta habilitado para utilizacao da Carga Fechada."
	Return( .F. )
EndIf

// Cria a tabela temporaria de agendamento
oTempTable := FWTemporaryTable():New( ctabAgd )
//--------------------------
//Monta os campos da tabela
//--------------------------

aCampos := ApBuildHeader("DF1")
For nCont := 1 To Len(aCampos)
	If AllTrim(aCampos[nCont][2]) $ "DF1_NUMAGE.DF1_ITEAGE"
		aAdd(aFields, {aCampos[nCont][2], aCampos[nCont][8], aCampos[nCont][4], aCampos[nCont][5]})
	EndIf
Next nCont

oTemptable:SetFields( aFields )
oTempTable:AddIndex("indice1", {"DF1_NUMAGE","DF1_ITEAGE"} )
//------------------
//Criação da tabela
//------------------
oTempTable:Create()

For nCntFor1 := 1 To Len(aRotinas)
	Aadd(aFolderAge,aRotinas[nCntFor1,2])
Next nCntFor1

//-- Adiciona as opções de SetKey F12
Aadd( aSetKeyF12 , {STR0104, { || Pergunte("TMSAF60",.T.) } } ) //"Viag Mod 3"
Aadd( aSetKeyF12 , {STR0059, { || Pergunte("TMAF05",.T.) } } ) //"Agendamento"
Aadd( aSetKeyF12 , {STR0060, { || Pergunte("TMA460",.T.) } } ) //"Coletas"
Aadd( aSetKeyF12 , {STR0061, { || Pergunte("TMB200",.T.) } } ) //"Cálculo" 
Aadd( aSetKeyF12 , {STR0062, { || Pergunte("TM250D",.T.), lF12 := .T. ,lExibeLanc := Iif(mv_par01 == 2,.F.,.T.),lOnline    := Iif(mv_par03 == 2,.F.,.T.) } } ) //"Carta Frete"
Aadd( aSetKeyF12 , {STR0063, { || Pergunte("TMA500",.T.) } } ) //"Doc Transp" 
Aadd( aSetKeyF12 , {STR0064, { || Pergunte("TMA360",.T.) } } ) //"Ocorrências"
Aadd( aSetKeyF12 , {STR0065, { || Pergunte("AFI281",.T.) } } ) //"Faturas"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para inclusao de opcoes customizadas no³
//³menu acoes relacionadas da rotina.                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTM76BUT
	aButCust := ExecBlock("TM76BUT", .F., .F.)
	If Len(aButCust) > 0
		For nCntFor1 := 1 To LEN(aButCust)
			aAdd(aButtons, aButCust[nCntFor1])
		Next nCntFor1
	Endif
Endif

//-- Limpa campo de controle de marcacao na entrada do programa, para garantir que caso o número da thread se repita depois de um certo tempo,
//-- o sistema não irá considerar registros antigos marcados indevidamente, ou que foram deixados marcados no banco por conta de o sistema
//-- ter caido.
TMSF76Lim(cNumThread)

DEFINE MSDIALOG oDlgAge FROM 0,0 TO nHeight, nWidth TITLE cCadastro PIXEL of oMainWnd
	
	//-- Monta objeto FWLayer
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlgAge,.F.)

	oFWLayer:AddLine("LinFil",05) //-- 06
	oFWLayer:AddLine("LinAge",40) //-- 48
	oFWLayer:AddLine("LinOpe",55) //-- 46

	//-- Monta Janela de Filtros
	oPanelUp := oFWLayer:GetLinePanel("LinFil")

	//-- Cria Botoes do Agendamento
	@ 002,002 BUTTON oButtonAtu PROMPT STR0066 	SIZE 045, 010 OF oPanelUp PIXEL ACTION TMSF76Age(.T.,.F.,,,,,,.T.) //"Atualiza (F5)" 
	aAdd(aSetKeyF76,{VK_F5 ,{|| TMSF76Age(.T.,.F.)}})

	//-- Botao do Filtro
	@ 002,054 BUTTON oButtonFil PROMPT STR0067	SIZE 045, 010 OF oPanelUp PIXEL ACTION TMSF76AFIL(aAliasFil,.T.,,,,aAliasNom) //"Filtrar (F6)"
	aAdd(aSetKeyF76,{VK_F6 ,{||TMSF76AFIL(aAliasFil,.T.,,,aAliasNom)}})

	//-- Botao do Re-Filtro
	@ 002,106 BUTTON oButtonFil PROMPT STR0090	SIZE 045, 010 OF oPanelUp PIXEL ACTION Tmsaf76Ref() //Parâmetros (F7)
	aAdd(aSetKeyF76,{VK_F7 ,{||Tmsaf76Ref()}})

	//-- Botao de Marca/Desmarca Todos
	@ 002,158 BUTTON oButtonFil PROMPT STR0091	SIZE 045, 010 OF oPanelUp PIXEL ACTION Tmsaf76All() //Marca/Todos (F8)
	aAdd(aSetKeyF76,{VK_F8 ,{||Tmsaf76All()}})

	//-- Filtros Específicos
	If lTMF76Din
		@ 002,210 BUTTON oButtonDin PROMPT STR0068  SIZE 045, 010 OF oPanelUp PIXEL ACTION TMSF76Din() //"Filtro Espec (F9)"
		aAdd(aSetKeyF76,{VK_F9 ,{||TMSF76Din()}})
	EndIf

	//-- Função para carregar os F12 das rotinas padrões
	aAdd(aSetKeyF76,{VK_F12 ,{|| TMSF76F12() }})

	//-- Carrega as teclas de atalho.
	aEval(aSetKeyF76,{|x| SetKey( x[1] , x[2] ) } )

	//-- Monta Janela de Agendamentos
	oPanelMidd := oFWLayer:GetLinePanel("LinAge")

	//--Monta as queries
	TMSF76AFIL(aAliasFil,,.F.,.f.,,aAliasNom)

    //-- Cria Browse dos Agendamentos
	oMarkAge := FWBrowse():New(oPanelMidd)
	oMarkAge:SetProfileId('TMSAF76Sup')

	//--Desativa botão de impressão
	oMarkAge:DisableReport()

	oMarkAge:AddMarkColumns ({ || Iif(DF1_MRKPAN == cNumThread,'LBOK','LBNO')},{ || TMSF76Mrk()},{ || .F. })
	oMarkAge:SetDataQuery(.T.)
	oMarkAge:SetAlias(aBrowseDF1[1])
	nIni:=seconds()
	oMarkAge:SetQuery(aBrowseDF1[3])
	oMarkAge:SetDescription(STR0069)	//"Agendamentos"
	oMarkAge:SetDoubleClick({ || TMSF76Mrk()})
	oMarkAge:SetUpdateBrowse({||.T.})

	For nCntFor1 := 1 To Len(aBrowseDF1[2])
		oColumn := FWBrwColumn():New()

		oColumn:SetType(aBrowseDF1[2,nCntFor1,3])
		oColumn:SetTitle(aBrowseDF1[2,nCntFor1,2])
		oColumn:SetSize(aBrowseDF1[2,nCntFor1,4])
		oColumn:SetDecimal(aBrowseDF1[2,nCntFor1,5])
		oColumn:SetPicture(aBrowseDF1[2,nCntFor1,6])
		oColumn:SetOptions(aBrowseDF1[2,nCntFor1,7])
		If aBrowseDF1[2,nCntFor1,9] == "V" // Tratamento para campos virtuais
			oColumn:SetData(&('{ ||DF1->(dbGoto((oMarkAge:Alias())->REGIST)),' + aBrowseDF1[2,nCntFor1,10] + ' }' ) )
		Else
			If aBrowseDF1[2,nCntFor1,3] == "D"
				oColumn:SetData(&('{ || DToC(SToD(' + aBrowseDF1[2,nCntFor1,1] + ')) }'))
				
			ElseIf !Empty(aBrowseDF1[2,nCntFor1,6]) .And. !(aBrowseDF1[2,nCntFor1,3] $ "N|L")  //--Se a Picture nao estiver vazia utiliza o Transform; Para campos numéricos não é preciso utilizar o transform()
				oColumn:SetData(&('{ || Transform(' + aBrowseDF1[2,nCntFor1,1] + ',X3Picture("' + aBrowseDF1[2,nCntFor1,1] + '")' + ')}'))
			Else				
				oColumn:SetData(&('{ || ' + aBrowseDF1[2,nCntFor1,1] + ' }'))
			EndIf
		EndIf
		aAdd(aColunas,oColumn)
	Next nCntFor1
	
	oMarkAge:SetColumns(aColunas)

	oMarkAge:Activate()
	oPanelDown := oFWLayer:GetLinePanel("LinOpe")

	nLarFolOpe := oPanelDown:nRight * 50 / 100		//-- Última coluna do folder
	nAltFolOpe := oPanelDown:nBottom * 50 / 100		//-- Última linha do folder

	oFolderOpe := TFolder():New(0,0,aClone(aFolderAge),aClone(aFolderAge),oPanelDown,,,,.T.,.F.,nLarFolOpe,nAltFolOpe)
	oFolderOpe:bSetOption:={|n|nFldr:=n,TMSF76Fldr()}

	aKill aFolderAge
	//-- Não alterar os parametros, pois causa error log por falta de informações que são inicializadas após essa linha
	TMSF76Age(.F.,.T.,.F.,,)

	nAltPanOpe := nAltFolOpe * 52 / 100	//-- Altura do painel de operações
	nLarPanOpe := nLarFolOpe			//-- Largura do painel de operações

	nAltPanBut := nAltFolOpe * 30 / 100	//-- Altura do painel de botões
	nLarPanBut := nLarFolOpe			//-- Largura do painel de botões
	nIniPanBut := nAltPanOpe + 1		//-- Inicio do painel de botões

	//-- Ativa Browse das Operacoes
	For nCntFor1 := 1 To Len(aRotinas)

		@ 0,0 MSPANEL aPaineis[nCntFor1,1] SIZE nLarPanOpe,nAltPanOpe OF oFolderOpe:aDialogs[nCntFor1]
		
		oScrOpe := TScrollBox():New(oFolderOpe:aDialogs[nCntFor1],nIniPanBut,0,nAltPanBut,nLarPanBut,.T.,.T.,.T.)
		
		cPanel := "oPanel" + AllTrim(Str(nCntFor1))
		
		@ nIniPanBut,000 MSPANEL &(cPanel) SIZE nLarPanBut,nAltPanBut Of oScrOpe
		aPaineis[nCntFor1,2] := FWBrowse():New(aPaineis[nCntFor1,1])
		aPaineis[nCntFor1,2]:SetProfileId('TM76Inf' + StrZero(nCntFor1,2))	

		//--Desativa botão de impressão
		aPaineis[nCntFor1,2]:DisableReport()
		//---------------------------------------------

		aPaineis[nCntFor1,2]:SetDataQuery(.T.)
		aPaineis[nCntFor1,2]:SetDescription(STR0070) //"Operações"

		aColunas := {}
		
		For nCntFor2 := 1 To Len(aBrowseOpe[nCntFor1,2])
			oColumn := FWBrwColumn():New()
			If ( aBrowseOpe[nCntFor1,2,nCntFor2,2] == 'LEGENDA' )
				If Empty(cNomeCampo)
					cNomeCampo := aBrowseOpe[nCntFor1,2,nCntFor2,1]
				EndIf	                      				
				oColumn:SetPicture("@BMP")
				oColumn:SetImage(.T.)      
				oColumn:SetTitle(" ")
			Else
				oColumn:SetTitle(aBrowseOpe[nCntFor1,2,nCntFor2,2])
				oColumn:SetType(aBrowseOpe[nCntFor1,2,nCntFor2,3])
			EndIf	                                               
			If aBrowseOpe[nCntFor1,2,nCntFor2,1] == 'DTC_FILORI' 
				cFilOriDTC := &('{ || ' + aBrowseOpe[nCntFor1,2,nCntFor2,1] + ' }' )
			ElseIf aBrowseOpe[nCntFor1,2,nCntFor2,1] == 'DTC_LOTNFC' 
				cLotNfcDTC := &('{ || ' + aBrowseOpe[nCntFor1,2,nCntFor2,1] + ' }' )				
			ElseIf aBrowseOpe[nCntFor1,2,nCntFor2,1] == 'DT6_FILDOC'
				cFilDocDT6 := &('{ || ' + aBrowseOpe[nCntFor1,2,nCntFor2,1] + ' }' )				
			ElseIf AllTrim(aBrowseOpe[nCntFor1,2,nCntFor2,1]) == 'DT6_DOC'
				cDocDT6 	  := &('{ || ' + aBrowseOpe[nCntFor1,2,nCntFor2,1] + ' }' )
			ElseIf AllTrim(aBrowseOpe[nCntFor1,2,nCntFor2,1]) == 'DT6_SERIE'
				cSerieDT6  := &('{ || ' + aBrowseOpe[nCntFor1,2,nCntFor2,1] + ' }' )
			ElseIf AllTrim(aBrowseOpe[nCntFor1,2,nCntFor2,1]) == 'E1_VALOR'
				nValorSE1  := 	&('{ || ' + aBrowseOpe[nCntFor1,2,nCntFor2,1] + ' }')
			ElseIf	AllTrim(aBrowseOpe[nCntFor1,2,nCntFor2,1]) == 'E1_SALDO'               
				nSaldoSE1  := 	&('{ || ' + aBrowseOpe[nCntFor1,2,nCntFor2,1] + ' }')
			ElseIf aBrowseOpe[nCntFor1,2,nCntFor2,1] == 'E1_SITUACA'               
				cSitSE1	  := &('{ || ' + aBrowseOpe[nCntFor1,2,nCntFor2,1] + ' }')
			EndIf	                        
			oColumn:SetSize(aBrowseOpe[nCntFor1,2,nCntFor2,4])
			oColumn:SetDecimal(aBrowseOpe[nCntFor1,2,nCntFor2,5])
			oColumn:SetPicture(aBrowseOpe[nCntFor1,2,nCntFor2,6])
			oColumn:SetOptions(aBrowseOpe[nCntFor1,2,nCntFor2,7])
			oColumn:SetDelete(aBrowseOpe[nCntFor1,2,nCntFor2,8])
			If aBrowseOpe[nCntFor1,2,nCntFor2,9] == "V" // Tratamento para campos virtuais
				oColumn:SetData(&('{ ||'+aRotinas[nCntFor1][1]+'->(dbGoto((aPaineis[nFldr,2]:Alias())->REGIST)),' + aBrowseOpe[nCntFor1,2,nCntFor2,10] + ' }' ) )
			Else
				If aBrowseOpe[nCntFor1,2,nCntFor2,3] == "D"
					oColumn:SetData(&('{ || DToC(SToD(' + aBrowseOpe[nCntFor1,2,nCntFor2,1] + ')) }' ) )
				ElseIf ( aBrowseOpe[nCntFor1,2,nCntFor2,2] == 'LEGENDA' )
					If aBrowseOpe[nCntFor1,2,nCntFor2,1] == 'DTC_STATUS' 
						oColumn:SetData(&('{ ||TMSAF76Leg() }' ) )
					Else
						oColumn:SetData(&('{ ||TMSAF76Leg( ' + aBrowseOpe[nCntFor1,2,nCntFor2,1] +') }' ) )						
					EndIf					
				ElseIf !Empty(aBrowseOpe[nCntFor1,2,nCntFor2,6]) .And. !(aBrowseOpe[nCntFor1,2,nCntFor2,3] $ "N|L") // Se Picture estiver preenchida e não for lógico ou númerico aplica mascara pelo Transform()					
					oColumn:SetData(&('{ || Transform(' + aBrowseOpe[nCntFor1,2,nCntFor2,1] + ',X3Picture("' + aBrowseOpe[nCntFor1,2,nCntFor2,1] + '")' + ')}'))
				Else
					oColumn:SetData(&('{ || ' + aBrowseOpe[nCntFor1,2,nCntFor2,1] + ' }'))
				EndIf
			EndIf
			aAdd(aColunas,oColumn)
		Next nCntFor2

		aPaineis[nCntFor1,2]:SetColumns(aColunas)

		//-- Cria Botoes de cada Rotina
		nLinAtuBut := 1
		nColAtuBut := 0
		nTotTamBut := 0
		For nCntFor2 := 1 To Len(aRotinas[nCntFor1,3])
			nColAtuBut ++
			nTotTamBut += 42
			If nTotTamBut > nLarPanBut
				nColAtuBut := 1
				nLinAtuBut ++
				nTotTamBut := 42
			EndIf
			If IsAutUsr(2,,nCntFor1,nCntFor2)
				TBrowseButton():New(((nLinAtuBut - 1) * 14),((nColAtuBut - 1) * 42),aRotinas[nCntFor1,3,nCntFor2,1],oScrOpe,&("{|o| TMSF76Act(o," + Strzero(nCntFor1,2) + "," + Strzero(nCntFor2,2)  + "," + ","+ "," + ")}"),040,13,,/*oPanel:oFont*/,.F.,.T.,.F.,,.F.,,,)
			Else
				bAction:= {|| Help('',1,'SEMPERM',,,03,00)}
			EndIf

		Next nCntFor2
		
	Next nCntFor1
	
	TMSF76Fldr()

ACTIVATE MSDIALOG oDlgAge ON INIT EnchoiceBar(oDlgAge,{|| (nOpca := 1, TMSF76Fim(),Iif(TMSF76TOk(),oDlgAge:End(),nOpca := 0)) }, {|| TMSF76Fim(),oDlgAge:End() },, aButtons )

//-- Limpa campo de controle de marcacao
TMSF76Lim(cNumThread)

aKill aColunas
aKill aSizeDlg
aKill aButtons
aKill aButCust
aKill aVetExp
aKill aFilBkp
aKill aPaineis
aKill aRotinas
aKill aPanAgeTms
aKill aBrowseDF1
aKill aBrowseOpe
aKill aVetPrg
aKill aSetKeyF76
aKill aSetKeyF12

oKill oFWLayer
oKill oMarkAge

// Deleta a tabela de agendamentos temporaria
oTempTable:Delete() 
oKill oTempTable

DelClassIntF() //--Exclui todas as classes da interface da thread.
cNomeCampo := ""
cFilOriDTC := ""
cLotNfcDTC := ""
cFilDocDT6 := ""
cDocDT6    := ""
cSerieDT6  := ""             
nValorSE1  := 0 
nSaldoSE1  := 0
cSitSE1	  := ""
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Din ³ Autor ³ Valdemar Roberto    ³ Data ³ 27/01/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama PE para criacao de filtro especifico                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Din                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76Din()
Local lRet    := .T.

CursorWait()
lRet := ExecBlock("TMF76Din",.F.,.F.,{1,Aclone(aAliasFil),Aclone(aAliasSup)})
If ValType(lRet) == "L" .And. lRet
	TMSF76Lim(cNumThread)
	aBrowseDF1 := TMSF76Qry(1,"''","''",.F.,.T.)
	Tmsaf76Rfs(oMarkAge,aBrowseDF1[1],aBrowseDF1[3])
EndIf
CursorArrow()
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76TOk ³ Autor ³ Valdemar Roberto    ³ Data ³ 20/01/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76TOk                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76TOk()
Local lRet      := .T.

If lTMF76TOk
	lRet := ExecBlock("TMF76TOk", .F., .F.)
	If ValType(lRet) != "L"
		lRet := .T.
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Act ³ Autor ³ Valdemar Roberto    ³ Data ³ 05/11/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa acoes dos botoes                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Act                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76Act(oObj,nFolder,nBotao,xFuncao,nOpcx)
Local cFonte := aRotinas[nFolder,4]

DEFAULT xFuncao := aRotinas[nFolder,3,nBotao,2]
DEFAULT nOpcx   := nBotao

//-- Troca o Alias
If (Upper(AllTrim(xFuncao)) = "AXPESQUI")
	DbSelectArea(aRotinas[nFolder,1])
EndIf

//-- Desliga teclas de atalho do painel
aEval(aSetKeyF76,{|x| SetKey( x[1] , {|| } ) } )

If IsInCallStack('TMSF76Age') .or. IsInCallStack('TMSF76AFIL')
	Return
EndIf
/*If "TMSA144" $ Upper(cFonte) .And. nOpcx == 4 // Alteração de viagem
	//-- 23/06/2016: conf. alinhamento, a alteração de viagem não está compatível no painel, sendo necessário desabilitá-la temporariamente 
	 Help('', 1,"HELP",, "Alteração de viagem temporariamente desabilitada no Painel",1) 
Else*/
	If ValType(xFuncao) == "A"
		TMSF76Sub(cFonte,xFuncao,nOpcx,nFolder,nBotao,oObj)
	Else
		TMSF76Exe(cFonte,xFuncao,nOpcx,nFolder,nBotao)
	EndIf
//EndIf

//-- Recupera teclas de atalho do painel
aEval(aSetKeyF76,{|x| SetKey( x[1] , x[2] ) } )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Sub ³ Autor ³ Valdemar Roberto    ³ Data ³ 05/11/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe Sub-Menu                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Sub                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76Sub(cFonte,xFuncao,nOpcx,nFolder,nBotao,oObj)
Local nCntFor1 := 0
Local cLinha   := ""
Local oMenu

MENU oMenu POPUP of oObj
	For nCntFor1 := 1 To Len(xFuncao)
		cLinha := "{|oMenuItem| TMSF76Act(oObj," + Strzero(nFolder,2) + "," + StrZero(nCntFor1,2) + ",xFuncao[" + StrZero(nCntFor1,2) + ",2]," + StrZero(nOpcx,2)+")}"
		MENUITEM xFuncao[nCntFor1,1]
		oMenu:aItems[nCntFor1]:BAction := &(cLinha)
	Next nCntFor1
ENDMENU

oMenu:Activate(NIL,-21*(nCntFor1-1),oObj)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Exe ³ Autor ³ Valdemar Roberto    ³ Data ³ 05/11/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa fonte                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Ext                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76Exe(cFonte,xFuncao,nOpcx,nFolder,nBotao,nRadioMod,nRadioSer,nRadioTip,lTela)
Local aAreas    := {DUL->(GetArea()),DT5->(GetArea()),DDA->(GetArea()),DDC->(GetArea()),DF0->(GetArea()),DF1->(GetArea()),DTP->(GetArea()),;
					DTC->(GetArea()),DUD->(GetArea()),SA1->(GetArea()),DUY->(GetArea()),DDB->(GetArea()),SX5->(GetArea()),GetArea()}
Local aRet      := {}
Local aVetRad   := {}
Local aMsgErr   := {}
Local nPos      := 0
Local nCntFor1  := 0
Local nCntFor2  := 0
Local lRet      := .F.
Local lCont     := .T.
Local lIncVia   := .F.
Local cViagens  := ""
Local oDlgVia
Local oPanelSer
Local oPanelTip
Local oRadioMod
Local oRadioSer
Local oRadioTip
Local lRot144 := .F.

//Programação 
Local aAgends    := {}
Local aItensAg   := {}
Local aAgdCmplt  := {}
Local aAgendPend := {}
Local nCntAge    := 0

Local aCombStEnt := {}
Local aCombStCol := {}
Local cStaCol    := ""
Local cStaEnt    := ""
Local nSeek      := 0

Private aVetReg 	:= {}
//Private __aRotAut	:= ""
Private __aRecPag
Private nKmVia  	:= 0

Private aFreVgeItC  := {} //Variavel usada nos fontes TMSA200/TMSA140/TMSA141 - Frete calculado na tabela Normal.
Private aContrItC   := {} //Variavel usada nos fontes TMSA200/TMSA140/TMSA141
Private aRetItC     := {} //Variavel usada no fonte TMSA200.
Private __cSerAdi   := ""
Private l200Calc := .T.

DEFAULT nRadioMod := 2
DEFAULT nRadioSer := 1
DEFAULT nRadioTip := 1
DEFAULT lTela     := .T.
DEFAULT xFuncao   := aRotinas[nFolder,3,nBotao,2]
DEFAULT nOpcx     := nBotao

INCLUI := (nOpcx == 3)
ALTERA := (nOpcx == 4)

If lTMF76INI
	ExecBlock("TMF76INI",.F.,.F.,{cFonte})
EndIf
If AllTrim(Upper(cFonte)) $ "TMSA144B:TMSAF60" .And. xFuncao != "TMSAF64NFC()" 
	If nOpcx == 3 .And. lTela
		/*If AllTrim(Upper(cFonte)) == "TMSA146"
			nRadioSer := 2
		EndIf */

		aRet := TMSF76Age(.F.,.F.,.T.,StrZero(nRadioSer,1),StrZero(nRadioTip,1))
		If aRet[2] = "''" .AND. nRadioSer == 2
			AAdd(aMsgErr,{STR0041,"00",""}) //--Selecione um agendamento
			TmsMsgErr(aMsgErr)
			lCont := .F.
		End If

		If lCont
			If AllTrim(Upper(cFonte)) == "TMSAF60"
				nRadioMod := 2
				nRadioSer := 3
				nRadioTip := 1
				lRet      := .T.
				__cSerAdi := StrZero(1,Len(DTQ->DTQ_SERTMS))
			Else
				DEFINE MSDIALOG oDlgVia TITLE STR0011 FROM 0,0 TO 330,300 PIXEL //--"Selecione o Tipo da Viagem"
	
					@ 005,001 MSPANEL oPanelSer OF oDlgVia SIZE 140,055
			 		@ 005,001 TO 050,140 LABEL STR0015 PIXEL OF oPanelSer //--"Tipo de Viagem"
					@ 010,004 Radio oRadioSer VAR nRadioSer Items STR0016,STR0017,STR0018,STR0042 Size 080,012 PIXEL OF oPanelSer //--"Coleta","Transporte","Entrega","Entrega com Coleta" 
	
					@ 070,001 MSPANEL oPanelTip OF oDlgVia SIZE 140,055
			 		@ 001,001 TO 050,140 LABEL STR0019 PIXEL OF oPanelTip //--"Tipo de Transporte"
					@ 010,004 Radio oRadioTip VAR nRadioTip Items STR0020,STR0021,STR0022,STR0023 Size 080,012 PIXEL OF oPanelTip //--"Rodoviario"//--"Aereo"//--"Fluvial"//--"Internacional"
	
					If lTMF76RAD
						aVetRad := ExecBlock("TMF76RAD ",.F.,.F.)
						If ValType(aVetRad) == "A"
							nRadioMod := 0
							nRadioSer := 0
							nRadioTip := 0
							For nCntFor1 := 1 To 3
								For nCntFor2 := 1 To Len(aVetRad[nCntFor1])
									If !aVetRad[nCntFor1,nCntFor2]
										If nCntFor1 == 1
											oRadioMod:Disable(nCntFor2)
										ElseIf nCntFor1 == 2
											oRadioSer:Disable(nCntFor2)
										Else
											oRadioTip:Disable(nCntFor2)
										EndIf
									Else
										If nCntFor1 == 1
											If nRadioMod == 0
												nRadioMod := nCntFor2
											EndIf
										ElseIf nCntFor1 == 2
											If nRadioSer == 0
												nRadioSer := nCntFor2
											EndIf
										Else
											If nRadioTip == 0
												nRadioTip := nCntFor2
											EndIf
										EndIf
									EndIf
								Next nCntFor2
							Next nCntFor1
						Endif
					EndIf
	
					DEFINE SBUTTON FROM 145,080 TYPE 1 ENABLE OF oDlgVia PIXEL ACTION ;
									(Iif(TMSF76Vld(1,StrZero(nRadioSer,1),StrZero(nRadioTip,1)),(lRet := .T.,oDlgVia:End()),lRet := .F.))
					DEFINE SBUTTON FROM 145,110 TYPE 2 ENABLE OF oDlgVia PIXEL ACTION (lRet := .F.,oDlgVia:End())
	
				ACTIVATE MSDIALOG oDlgVia CENTERED
			EndIf
		EndIf
	ElseIf nOpcx!= 3
		lRet      := .T.
		nRadioMod := 2
		If (aBrowseOpe[nFolder,1])->REGIST > 0
			&(aRotinas[nFolder,1])->(DbGoTo((aBrowseOpe[nFolder,1])->REGIST))
		EndIf
		If lTela
			nRadioSer := Iif(AllTrim(Upper(cFonte)) $ "TMSA144B:TMSAF60",Val(DTQ->DTQ_SERTMS),Val(DF8->DF8_SERTMS))
			nRadioTip := Iif(AllTrim(Upper(cFonte)) $ "TMSA144B:TMSAF60",Val(DTQ->DTQ_TIPTRA),Val(DF8->DF8_TIPTRA))
		Else
			nRadioSer := Iif(AllTrim(Upper(cFonte)) $ "TMSA144B:TMSAF60",Val(M->DTC_SERTMS),Val(M->DF8_SERTMS))
			nRadioTip := Iif(AllTrim(Upper(cFonte)) $ "TMSA144B:TMSAF60",Val(M->DTC_TIPTRA),Val(M->DF8_SERTMS))
		EndIf
		__cSerAdi := DTQ->DTQ_SERADI
	ElseIf !empty(nRadioMod).and. !empty(nRadioSer) .and. !empty(nRadioTip)
		lRet      := .T.
	EndIf

	If lRet
		If nRadioSer == 4
			nRadioSer := 3
			__cSerAdi := StrZero(1,Len(DTQ->DTQ_SERTMS))
		EndIf
		If AllTrim(Upper(cFonte)) == "TMSA144B"
			cViagens := "/111TMSA141A/121TMSA140A/131TMSA141C/112TMSA141B/122TMSA140B/132TMSA141D/123TMSA140C/133TMSA141E/124TMSA140D"
			cViagens += "/211TMSA144A/221TMSA144B/231TMSA144D/212TMSA144E/222TMSA144C/232TMSA144F/223TMSA144G/233TMSA144H/224TMSA144I"
		Else
			cViagens += "/231TMSAF60/211TMSAF60"
		EndIf
		If (nPos := At("/" + StrZero(nRadioMod,1) + StrZero(nRadioSer,1) + StrZero(nRadioTip,1), cViagens )) > 0
			cFonte := SubStr(cViagens,nPos + 4,7) + "('" + StrZero(nRadioSer,1) + "','" + StrZero(nRadioTip,1) + "',," + StrZero(nOpcx,2) + ")"
			If nOpcx == 3
	
				//-- Busca os agendamentos marcados
				If lTela //-- Traz da tela do painel
					aRet := TMSF76Age(.F.,.F.,.T.,StrZero(nRadioSer,1),StrZero(nRadioTip,1),,,.T.)
				Else //-- Traz o agendamento utilizado digitacao da nota, com opcao de calculo automatico do lote, e da abertura automatica de viagem
					DUD->(DbSetOrder(1))
					DUD->(DbSeek(xFilial("DUD") + DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE)))
					aRet:= {DF1->DF1_NUMAGE,DF1->DF1_ITEAGE,{DUD->(Recno())}}
				EndIf

				//-- Busca os agendamentos marcados
				lCont:= AF76VldAgd(lTela,aRet,nRadioSer,nRadioTip,lCont,aVetReg,aVetPrg,oMarkAge,nOpcx)   

				//-- Valida registros que serao inseridos na viagem
				If lCont
					lCont := TMSF76Via(Aclone(aRet),StrZero(nRadioSer,1),StrZero(nRadioTip,1),nFolder,@nKmVia,cFonte,xFuncao,,,nOpcx)
					lIncVia := .T.
				EndIf
			Else
				If (aPaineis[nFolder,2]:cAlias)->(Eof())
					Aviso(STR0057,STR0071,{STR0056}) //"Atencao !"###"Não existem registros no Grid."###"Ok"
					lCont := .F.
				Else
					If (aBrowseOpe[nFolder,1])->REGIST > 0
						&(aRotinas[nFolder,1])->(DbGoTo((aBrowseOpe[nFolder,1])->REGIST))
						
						//--- Alteracao da Viagem 
						If  "TMSA144" $ Upper(cFonte) .Or. "TMSAF60" $ Upper(cFonte)   

							If nOpcx == 4 .Or. (nOpcx == 2 .And. "TMSA144" $ Upper(cFonte))
								aRet := TMSF76Age(.F.,.F.,.T.,StrZero(nRadioSer,1),StrZero(nRadioTip,1))
								lCont:= AF76VldAgd(lTela,aRet,nRadioSer,nRadioTip,lCont,aVetReg,aVetPrg,oMarkAge,nOpcx )
								If lCont
									lCont := TMSF76Via(Aclone(aRet),StrZero(nRadioSer,1),StrZero(nRadioTip,1),nFolder,@nKmVia,cFonte,xFuncao,,Iif(StrZero(nRadioSer,1) == "1",.F.,.T.),nOpcx)
									lRot144 := .T.
								EndIf
							Else
								aRet := TMSF76Age(.F.,.F.,.T.,StrZero(nRadioSer,1),StrZero(nRadioTip,1),,.T.)
								aVetReg := Aclone(aRet[3])
							EndIf
						EndIf						
					EndIf

					If lCont .And. !lRot144
						aPanAgeTms    := Array(3)
						aPanAgeTms[1] := SubStr(cViagens,nPos + 4,7)
						aPanAgeTms[2] := xFuncao
						If At("(",aPanAgeTms[2]) == 0
							aPanAgeTms[2] := aPanAgeTms[2] + "()"
						EndIf

						If At("FWExecView",aPanAgeTMS[2]) > 0 .Or. "TMSAF60" $ Upper(AllTrim(aPanAgeTms[1]))
							cFonte := aPanAgeTMS[2]
						EndIf

						&(cFonte)

					EndIf	
				EndIf
			EndIf
		EndIf
	EndIf
Else
	If At("(",cFonte) == 0
		aPanAgeTms    := Array(8)
		lCont        := .T.
		aPanAgeTms[1] := aRotinas[nFolder,1]
		aPanAgeTms[2] := Iif(nOpcx == 3,0,(aBrowseOpe[nFolder,1])->REGIST)
		aPanAgeTms[3] := nOpcx
		aPanAgeTms[6] := xFuncao
		aPanAgeTms[7] := {{},{},{}}
		//-- Busca os agendamentos marcados
		If lTela //-- Traz da tela do painel
			aRet := TMSF76Age(.F.,.F.,.F.,,)
			If !Empty(aRet).and.!Empty(aRet[1]) .And. !Empty(aRet[2]) .and. !("," $ aRet[1])
				aRet[1] := StrTran(aRet[1],"'","")
				aRet[2] := StrTran(aRet[2],"'","")
				DF1->(DbSetOrder(1))
				DF1->(DbSeek(xFilial("DF1") + aRet[1] + aRet[2]))
			Endif
		EndIf

		If nOpcx == 3 .Or. ("TMSAF64NFC" $ Upper(aPanAgeTMS[6]) .And. aPanAgeTMS[3] == 10);
			.Or. ("TMSAE73" $ Upper(aPanAgeTMS[6]) .And. nOpcx == 7);
			.Or. ("TMSA050MNT" $ Upper(aPanAgeTMS[6]) .And. nOpcx == 8);
			.Or. ("TMSA050MNT" $ Upper(aPanAgeTMS[6]) .And. nOpcx == 9)
			If "TMSA146" $ Upper(cFonte) .AND. lTela
				aPanAgeTms[4] := ""
				aPanAgeTms[5] := ""
				aAgends  := StrTokArr( StrTran(aRet[1],"'",""), "," )
				aItensAg := StrTokArr( StrTran(aRet[2],"'",""), "," )
				
				DF1->(dbSetOrder(1))
				aCombStCol := RetSx3Box(GetSX3Cache("DF1_STACOL","X3_CBOX"),,, 1 )				
				aCombStEnt := RetSx3Box(GetSX3Cache("DF1_STAENT","X3_CBOX"),,, 1 )		

				For nCntAge := 1 To Len(aAgends)
					// Verifica se esta pendente confirmação
					If DF1->( dbSeek( FwxFilial("DF1")+ aAgends[nCntAge] + aItensAg[nCntAge] ) )
						If DF1->DF1_STACOL == '1'

							If	( nSeek := Ascan( aCombStCol, { |x| x[ 2 ] == DF1->DF1_STACOL } ) ) > 0
								cStaCol :=  aCombStCol[ nSeek, 3 ]
							EndIf

							If	( nSeek := Ascan( aCombStEnt, { |x| x[ 2 ] == DF1->DF1_STAENT } ) ) > 0
								cStaEnt :=  aCombStEnt[ nSeek, 3 ]
							EndIf

							AADD(aAgendPend,{.F.,.F.,aAgends[nCntAge],aItensAg[nCntAge],cStaCol,cStaEnt,DF1->DF1_DATPRC,DF1->DF1_HORPRC,;
								DF1->DF1_CLIREM,DF1->DF1_LOJREM,Posicione("SA1",1,xFilial("SA1") + DF1->DF1_CLIREM + DF1->DF1_LOJREM,"A1_NOME"),;
								DF1->DF1_CDRORI,Posicione("DUY",1,xFilial("DUY") + DF1->DF1_CDRORI,"DUY_DESCRI"),DF1->DF1_CDRDES,;
								Posicione("DUY",1,xFilial("DUY") + DF1->DF1_CDRDES,"DUY_DESCRI"),DF1->DF1_CODNEG,;
								Posicione("DDB",1,xFilial("DDB") + DF1->DF1_CODNEG,"DDB_DESCRI"),DF1->DF1_SRVCOL,;
								TABELA("L4",DF1->DF1_SRVCOL,.F.),DF1->DF1_SERVIC,TABELA("L4",DF1->DF1_SERVIC,.F.),{StrZero(nCntAge,3),STR0087}})	//-- Confirme o agendamento
							AADD(aAgdCmplt,{aAgends[nCntAge],aItensAg[nCntAge]})
						EndIf
					EndIf	
				Next nCntAge
				
				// Exibe a tela para confirmar os Agendamentos
				If Len(aAgendPend) > 0 
					AF76ExbAgd(aAgendPend)
				EndIf
				
					
				If Len(aAgdCmplt) > 0
					aPanAgeTms[8] := AClone(aAgdCmplt)
				EndIf
						
			Else
				If !Empty(aRet)
					aRet[1] := StrTran(aRet[1],"'","")
					aRet[2] := StrTran(aRet[2],"'","")
					If "," $ aRet[1] ;
					   .AND. (aRotinas[nFolder,1] != "DTY") ; //-- seleção de agendamentos não interfere na geração da carta frete
					   .AND. (aRotinas[nFolder,1] != "DTP") ; //-- seleção de agendamentos não interfere no estorno do calculo do frete
					   .AND. (aRotinas[nFolder,1] != "SC9") ; //-- seleção de agendamentos não interfere na liberacao de credito
					   .AND. (aRotinas[nFolder,1] != "DF0") ; //-- seleção de agendamentos não interfere na inclusão de um novo agendamento
					   .AND. (aRotinas[nFolder,1] != "SE1") ; //-- seleção de agendamentos não interfere na inclusão Fatura
					   .AND. (aRotinas[nFolder,1] != "DRT") ; //-- seleção de agendamentos não interfere na inclusão Fatura (Integr. Datasul)
					   .AND. (aRotinas[nFolder,1] != "DU1") ; //-- seleção de agendamentos não interfere no comprovante de entrega
					   .AND. (aRotinas[nFolder,1] != "DUA") ; //-- seleção de agendamentos não interfere nas ocorrências
					   .AND. (aRotinas[nFolder,1] != "DTW") ; //-- seleção de agendamentos não interfere no apontamento de operações
					   .AND. (aRotinas[nFolder,1] != "DTX") ; //-- seleção de agendamentos não interfere no manifesto.
					   .AND. !("TMSAE73" $ Upper(aPanAgeTMS[6]));
					   .AND. !("TMSAF64NFC" $ Upper(aPanAgeTMS[6])) //-- Não válido para chamada da opção de + NF Cliente da viagem modelo 3
		
						Aviso(STR0057,STR0072,{STR0056})//"Atenção !"###"Somente um agendamento poderá ser selecionado."###"Ok"
						lCont := .F.
					ElseIf !Empty(aRet[1]) .And. !Empty(aRet[2])
						DF1->(DbSetOrder(1))
						DF1->(DbSeek(xFilial("DF1") + aRet[1] + aRet[2]))
						aPanAgeTms[4] := aRet[1]
						aPanAgeTms[5] := aRet[2]
					EndIf
				EndIf
			EndIf
		Else
			If (aPaineis[nFolder,2]:cAlias)->(Eof()).AND.  ;
			(aRotinas[nFolder,1] != "DTY")  //-- seleção de agendamentos não interfere na geração da carta frete
				If (aRotinas[nFolder,1] != "DTC") ;
					.AND. (aRotinas[nFolder,1] != "DTX") .AND. (aRotinas[nFolder,1] != "DUA")  //-- seleção de agendamentos não interfere no manifesto.
					Help('',1,'TMSAF7604',,,03,00) //"Não existem registros no Grid."
					lCont := .F.
				EndIf
			EndIf
		EndIf
		cFonte := cFonte + "()"
	EndIf
 
	If lCont
		If (aBrowseOpe[nFolder,1])->REGIST > 0
			&(aRotinas[nFolder,1])->(DbGoTo((aBrowseOpe[nFolder,1])->REGIST))
		EndIf
		
		If ExistFunc("TMSAE71AGE")
			TMSAE71Age(aRet)
		EndIf
		
		SetFunName(Substr(cFonte,1,At("(",cFonte)-1))

		If (At("FWExecView",aPanAgeTMS[6]) > 0 .Or. "TMSAF60" $ Upper(cFonte));
			.Or. ("TMSAE73" $ Upper(aPanAgeTMS[6]));
			.Or. ("TMSA190A" $ Upper(aPanAgeTMS[6]))
			cFonte := aPanAgeTMS[6]
			If At("(",cFonte) == 0
				cFonte := cFonte + "()"
			EndIf 
		EndIf
		&(cFonte)

		SetFunName("TMSAF76")
	EndIf

EndIf

If lTMF76END
	ExecBlock("TMF76END",.F.,.F.,{cFonte,StrZero(nRadioSer,1),lIncVia})
EndIf

DelClassIntF() //--Exclui todas as classes da interface da thread.

AEval(aAreas,{|x,y| RestArea(x) })

If nOpcx > 2 // Para pesquisa e visualização não tem a necessidade de refazer os Browses
	//-- Refaz Browses
	Tmsaf76Rfs(oMarkAge,aBrowseDF1[1],aBrowseDF1[3])	
	TMSF76Age(.T.,.F.,.F.,,)
EndIf

aEval(aSetKeyF76,{|x| SetKey( x[1] , x[2] ) } )

aKill aAreas
aKill aRet
aKill aVetRad
aKill aMsgErr
aKill aVetReg
aKill aFreVgeItC
aKill aContrItC
aKill aRetItC

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ	ÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±	±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ	¿±±
±±³Fun‡„o    ³ TMSF76Via ³ Autor ³ Valdemar Roberto    ³ Data ³ 13/03/13 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ	´±±
±±³Descri‡„o ³ Valida agendamentos da viagem                             	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ	´±±
±±³Sintaxe   ³ TMSF76Via                                                 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ	´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ	³±±
±±³ Uso      ³ TMSAF76                                                   	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ	±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±	±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76Via(aAgendas,cSerTms,cTipTra,nFolder,nKmViag,cFonte,xFuncao,lEfetiv,lValDTCCol,nOpcx)
Local aAreas     := {SC9->(GetArea()),DT5->(GetArea()),DTQ->(GetArea()),DUL->(GetArea()),DT5->(GetArea()),DDA->(GetArea()),DDC->(GetArea()),DF0->(GetArea()),DF1->(GetArea()),;
					DTP->(GetArea()),DTC->(GetArea()),DUD->(GetArea()),SA1->(GetArea()), GetArea()}
Local aVetAge    := {}
Local aVetIte    := {}
Local aVetDTP    := {} 
Local aPenNFc    := {}
Local aPenCal    := {}
Local aVetRota   := {}
Local aRet       := {}
Local aVetCal    := {}
Local nCntFor1   := 0
Local lRet       := .T.
Local lCont      := .T.
Local cStrWrk    := ""
Local lColeta    := .F.
Local lEntrega   := .F.
Local lPrgCar    := 'TMSA146'$cFonte
Local lColEnt    := .F.
Local nRegDUD    := 0
Local aTabRec	 := {}
Local aRetVia    := {}

Local aCamposDTQ := {}
Local aCamposDM3 := {}
Local aDadosDTQ  := {}
Local aDadosDM3  := {}
Local aLinhaDM3  := {}
Local oModelVia  := Nil
Local oMdlFldDTQ := Nil
Local oStruDTQ   := Nil
Local oMdlGrdDM3 := Nil
Local oStruDM3   := Nil
Local nCntFor2   := 0
Local nSequen    := 0
Local lDM3		 := AliasIndic('DM3')

Default lEfetiv    := .F.
Default cSerTms    := '' 
Default lValDTCCol := .T.
Default nOpcx      := 0

Private aVetTroca  := {{},{},{}}
Private aColsPag   := {}
Private aPenSol    := {}
Private aPanAgeTms   := Array(7)
Private lMsErroAuto := .F.
Private aValInfVia	:={}
Private aValVia		:={}
Private cTipoKM		:=''
Private aMsgErr    := {}
Private lConfirma  := .F.
Private lCompViag  := .F.
Private lHlpPnl    := .T. //Variável para exibir somente uma vez os bloqueios da viagem
Private aColsRota  := {}
Private lAutCharge := .F. //Define se usuário optou pelo carregamento automático ao inserir uma viagem de entrega/transf |2016-07-05 tiago.dsantos|)

l200Calc := .F.// não vefifica alteração no Complemento a não ser que calcule

If lDM3
	AAdd(aAreas, DM3->(GetArea()) )
EndIf

If	Type("aBloqueio") == "U"
	Private aBloqueio 	:= {}
EndIf

If	Type("lTmsCFec") == "U"
	Private lTmsCFec	:= TmsCFec()
EndIf
cStrWrk := StrTran(aAgendas[1],"'","")
aVetAge := StrTokArr(cStrWrk,",")
cStrWrk := StrTran(aAgendas[2],"'","")
aVetIte := StrTokArr(cStrWrk,",")

SA1->(DbSetOrder(1))
DUL->(DbSetOrder(2))
DT5->(DbSetOrder(1))
DDA->(DbSetOrder(2))
DDC->(DbSetOrder(1))
DF0->(DbSetOrder(1))
DF1->(DbSetOrder(1))
DTC->(DbSetOrder(8))
DUD->(DbSetOrder(1))
DT5->(DbSetOrder(1))
DTP->(DbSetOrder(1))

If cSerTms == "1" 
	lColeta  := .T.	
ElseIf cSerTms == "3" .And. Type("M->DTQ_SERADI") == "C" .And. Empty(M->DTQ_SERADI)
	lEntrega := .T.
EndIf

If lRet 
	For nCntFor1 := 1 To Len(aVetAge)
		If cSerTms == "1" //-- Coleta
			If DF1->(DbSeek(xFilial("DF1") + aVetAge[nCntFor1] + aVetIte[nCntFor1]))
				
				If lValDTCCol .And. DTC->(DbSeek(xFilial("DTC") + DF1->(DF1_FILDOC + DF1_DOC)))
 					AAdd(aMsgErr,{STR0026 + DF1->DF1_FILDOC + "/" + DF1->DF1_DOC + STR0027 + DTC->DTC_CLIREM + "/" + DTC->DTC_LOJREM + " - " + DTC->DTC_NUMNFC + "/" + DTC->DTC_SERNFC + ".","00",""}) //--"Solicitação de coleta "//--" já está vinculada à nota " 
					lCont := .F.
  				Else
					If !TMSF76DUD(DF1->DF1_FILDOC,DF1->DF1_DOC,DF1->DF1_SERIE,cTipTra,cSerTMS,@nRegDUD,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
						AAdd(aMsgErr,{STR0028 + DF1->DF1_FILDOC + "/" + DF1->DF1_DOC + STR0029,"00",""}) //--"Movimento da solicitação de coleta " 
						lCont := .F.
					Else
						If aScan(aVetReg,{|x| x == nRegDUD}) == 0
							Aadd(aVetReg,nRegDUD)
						EndIf
					EndIf					
				EndIf
				
				//- verifica se Solicitação de Coleta está bloqueada.
				DT5->(DbSeek(xFilial("DT5") + DF1->(DF1_FILDOC + DF1_DOC)))
				If DT5->DT5_STATUS == StrZero(6,TamSx3('DT5_STATUS')[1])
                   AAdd(aMsgErr,{STR0092 + DF1->DF1_FILDOC + "/" + DF1->DF1_DOC + "." + STR0093,"00",""}) //--"STR0092=[A Solicitação de Coleta encontra-se bloqueada. Ref. a ] #####  STR0093=[Faça o debloqueio pela tela de Solicitação de Coleta.]"
				EndIf
				
				If lCont
					//-- Carrega aCols dos pagadores de frete
					DT5->(DbSeek(xFilial("DT5") + DF1->(DF1_FILDOC + DF1_DOC)))
					AADD(aTabRec,{"DT5",DT5->(Recno())})
				EndIf
				
			EndIf
			
		Else //-- Transferencia ou entrega
			If DF1->(DbSeek(xFilial("DF1") + aVetAge[nCntFor1] + aVetIte[nCntFor1]))
				If Type("INCLUI") == "U" .Or. INCLUI
					If !DTC->(DbSeek(xFilial("DTC") + DF1->(DF1_FILDOC + DF1_DOC)))
						If lPrgCar
							lCont := .F.
						Else
							DT5->(DbSeek(xFilial("DT5") + DF1->(DF1_FILDOC + DF1_DOC)))
							lColEnt := (__cSerAdi == "1" .And. DT5->DT5_STATUS $ "16")
							If !lColEnt
								AAdd(aMsgErr,{STR0026 + DF1->DF1_FILDOC + "/" + DF1->DF1_DOC + STR0030,"00",""}) //--"Solicitação de coleta "//--"/COL não se encontra vinculada a nenhuma nota."
								Aadd(aPenNFc,{DF1->DF1_NUMAGE,DF1->DF1_ITEAGE,DF1->(Recno())}) //-- Agendamento e NFc ainda nao vinculados
							Else
								If TMSF76DUD(DF1->DF1_FILDOC,DF1->DF1_DOC,DF1->DF1_SERIE,cTipTra,"1",@nRegDUD,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
									If aScan(aVetReg,{|x| x == nRegDUD}) == 0
										Aadd(aVetReg,nRegDUD)
									EndIf
								EndIf
							EndIf

							//-- Carrega aCols dos pagadores de frete
							AADD(aTabRec,{"DT5",DT5->(Recno())})

						EndIf
					Else
						While DTC->(!Eof()) .And. DTC->(DTC_FILIAL+DTC_FILORI+DTC_NUMSOL) == DF1->(DF1_FILIAL+DF1_FILDOC+DF1_DOC)
							If Empty(DTC->DTC_DOC)
								If !lPrgCar .or. lEfetiv
									If aScan(aPenCal,{|x|x[1]+x[2]==DTC->DTC_FILORI+DTC->DTC_LOTNFC}) == 0
										Aadd(aPenCal,{DTC->DTC_FILORI,DTC->DTC_LOTNFC,.T.})
									EndIf

									//-- Carrega aCols dos pagadores de frete
									AADD(aTabRec,{"DTC",DTC->(Recno())})
								EndIf

							//-- Se o documento vinculado a nota fiscal for do tipo PED, signifca que existe uma pendencia de limite de crédito do cliente.
							ElseIf DTC->DTC_SERIE == "PED"
								aBloqueio := {}
								SC9->(DbSetOrder(2))
								If SC9->(DbSeek(xFilial("SC9") + DTC->DTC_CLIREM + DTC->DTC_LOJREM + PadR(DTC->DTC_DOCPER,Len(SC9->C9_PEDIDO))))
									If !Empty(SC9->C9_BLCRED) .Or. !Empty(SC9->C9_BLTMS)
										AAdd(aBloqueio,{SC9->C9_LOTNFC,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_BLCRED,SC9->C9_BLTMS,SC9->C9_CLIENTE,SC9->C9_LOJA,;
														Posicione("SA1",1,xFilial("SA1") + SC9->(C9_CLIENTE + C9_LOJA),"A1_NREDUZ"),SC9->C9_PRODUTO,;
														SC9->C9_QTDLIB,SC9->C9_PRCVEN,SC9->C9_SERVIC,SC9->C9_BLINF})
									EndIf
								EndIf
								If SC9->(DbSeek(xFilial("SC9") + DTC->DTC_CLIDEV + DTC->DTC_LOJDEV + PadR(DTC->DTC_DOC,Len(SC9->C9_PEDIDO))))
									If !Empty(SC9->C9_BLCRED) .Or. !Empty(SC9->C9_BLTMS)
										AAdd(aBloqueio,{SC9->C9_LOTNFC,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_BLCRED,SC9->C9_BLTMS,SC9->C9_CLIENTE,SC9->C9_LOJA,;
														Posicione("SA1",1,xFilial("SA1") + SC9->(C9_CLIENTE + C9_LOJA),"A1_NREDUZ"),SC9->C9_PRODUTO,;
														SC9->C9_QTDLIB,SC9->C9_PRCVEN,SC9->C9_SERVIC,SC9->C9_BLINF})
									EndIf
								EndIf
								If !Empty(aBloqueio)
									AAdd(aMsgErr,{"Documento bloqueado por análise de crédito, Solicite liberação ao departamento Financeiro. "+; 
													DTC->DTC_FILDOC + "/" + DTC->DTC_DOC + " / " + DTC->DTC_SERIE ,"00",""}) //--"Existem documentos bloqueados por análise de crédito. Faça a liberação antes de incluir a viagem."
									lCont := .F.
								Else
									If !lPrgCar .or. lEfetiv
										If aScan(aPenCal,{|x|x[1]+x[2]==DTC->DTC_FILORI+DTC->DTC_LOTNFC}) == 0
											Aadd(aPenCal,{DTC->DTC_FILORI,DTC->DTC_LOTNFC,.T.})
										EndIf
		
										//-- Carrega aCols dos pagadores de frete
										AADD(aTabRec,{"DTC",DTC->(Recno())})
									EndIf
								EndIf
							Else
								If TMSF76DUD(DTC->DTC_FILDOC,DTC->DTC_DOC,DTC->DTC_SERIE,cTipTra,cSerTMS,@nRegDUD,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
									If aScan(aVetReg,{|x| x == nRegDUD}) == 0
										Aadd(aVetReg,nRegDUD)
									EndIf
								EndIf
							EndIf
							
							DTC->(DbSkip())
						EndDo
					EndIf
				Else
					If DT5->(DbSeek(xFilial("DT5") + DF1->(DF1_FILDOC + DF1_DOC)))
						If DTC->(DbSeek(xFilial("DTC") + DT5->(DT5_FILDOC + DT5_DOC + DT5_SERIE)))
							If TMSF76DUD(DTC->DTC_FILDOC,DTC->DTC_DOC,DTC->DTC_SERIE,cTipTra,cSerTMS,@nRegDUD,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
								If aScan(aVetReg,{|x| x == nRegDUD}) == 0
									Aadd(aVetReg,nRegDUD)
								EndIf
							EndIf 
						EndIf
					EndIf	
					If TMSF76DUD(DF1->DF1_FILDOC,DF1->DF1_DOC,DF1->DF1_SERIE,cTipTra,"1",@nRegDUD,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
						If aScan(aVetReg,{|x| x == nRegDUD}) == 0
							Aadd(aVetReg,nRegDUD)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Next nCntFor1
	
	__aRecPag := aClone(aTabRec)
	
	If lRet .AND. lCont
		aPanAgeTms    := Array(7)
		aPanAgeTms[1] := "DTQ"
		aPanAgeTms[2] := xFuncao
		If At("(",aPanAgeTms[2]) == 0
			aPanAgeTms[2] := aPanAgeTms[2] + "()"
		EndIf

		If lDM3 .And. At("FWExecView",aPanAgeTMS[2]) > 0
			//-- Carrega vetor da viagem
			If nOpcx == 3
				Aadd(aDadosDTQ,{"DTQ_SERTMS",cSerTMS})
				Aadd(aDadosDTQ,{"DTQ_TIPTRA",cTipTra})
			EndIf

			//-- Carrega vetor dos documentos
			DM3->(DbSetOrder(1))
			For nCntFor1 := 1 To Len(aVetReg)
				DUD->(DbGoTo(aVetReg[nCntFor1]))
				If !DM3->(DbSeek(xFilial("DM3") + DUD->(DUD_FILDOC + DUD_DOC + DUD_SERIE + DUD_FILORI + DUD_VIAGEM)))
					aLinhaDM3 := {}
					Aadd(aLinhaDM3,{"DM3_SEQUEN",Space(Len(DM3->DM3_SEQUEN))})
					Aadd(aLinhaDM3,{"DM3_FILDOC",DUD->DUD_FILDOC})
					Aadd(aLinhaDM3,{"DM3_DOC"   ,DUD->DUD_DOC})
					Aadd(aLinhaDM3,{"DM3_SERIE" ,DUD->DUD_SERIE})
					Aadd(aDadosDM3,Aclone(aLinhaDM3))
				EndIf
			Next nCntFor1

			If Len(aDadosDM3) > 0
				//-- Carrega o Model de Carregamento
				oModelVia := FWLoadModel("TMSAF60")
				oModelVia:SetOperation(nOpcx)
		
				//-- Ativa o Model da Viagem
				oModelVia:Activate()
		
				//-- Carrega o Modelo da Viagem
				oMdlFldDTQ := oModelVia:GetModel("MdFieldDTQ")
				oStruDTQ   := oMdlFldDTQ:GetStruct()
				aCamposDTQ := oStruDTQ:GetFields()
	
				//-- Carrega o Modelo dos Documentos
				oMdlGrdDM3 := oModelVia:GetModel("MdGridDM3")
				oStruDM3   := oMdlGrdDM3:GetStruct()
				aCamposDM3 := oStruDM3:GetFields()

				//-- Ajusta a sequencia dos documentos na DM3
				nSequen := Iif(nOpcx == 3,0,oMdlGrdDM3:Length())
				For nCntFor1 := 1 To Len(aDadosDM3)
					nSequen ++
					aDadosDM3[nCntFor1,1,2] := StrZero(nSequen,Len(DM3->DM3_SEQUEN))
				Next nCntFor1

				//-- Preenche os Valores no Cabeçalho da Viagem
				For nCntFor1 := 1 To Len(aDadosDTQ)
					If AScan(aCamposDTQ,{|x| AllTrim(x[3]) == AllTrim(aDadosDTQ[nCntFor1,1])}) > 0
						If !oMdlFldDTQ:SetValue(aDadosDTQ[nCntFor1,1],aDadosDTQ[nCntFor1,2])
							lCont := .F.
							Exit
						EndIf
					EndIf
				Next nCntFor1
				
				//-- Adiciona Nova Linha de Documento
				nSequen := Iif(nOpcx == 3,0,oMdlGrdDM3:Length())
				For nCntFor1 := 1 To Len(aDadosDM3)
					oMdlGrdDM3:GoLine(oMdlGrdDM3:Length())
					If !oMdlGrdDM3:IsEmpty()
						nSequen ++
						If oMdlGrdDM3:AddLine(.T.) != nSequen
							lCont := .F.
							Exit
						EndIf
					Else
						nSequen ++
					EndIf
			
					//-- Preenche os Valores nos Documentos da Viagem
					If lCont
						For nCntFor2 := 1 To Len(aDadosDM3[nCntFor1])
							If AScan(aCamposDM3,{|x| AllTrim(x[3]) == AllTrim(aDadosDM3[nCntFor1,nCntFor2,1])}) > 0
								If !oMdlGrdDM3:SetValue(aDadosDM3[nCntFor1,nCntFor2,1],aDadosDM3[nCntFor1,nCntFor2,2])
									lCont := .F.
									Exit
								EndIf
							EndIf
						Next nCntFor2
					EndIf
				Next nCntFor1
			EndIf

			cFonte := Left(aPanAgeTMS[2],Len(aPanAgeTMS[2]) - 1) + ",,{|| .T.},,,,,,,oModelVia)" 
		EndIf
	
		aRetVia := &(cFonte)

	Else
		lRet :=  lCont := .F.
	EndIf

EndIf

//- Exibe mensagens para o usuário se encontrado alguma divergência
If Len(aMsgErr) > 0
    TmsMsgErr(aMsgErr)
EndIf

AEval(aAreas,{|x,y| RestArea(x) })

aKill aAreas
aKill aVetAge
aKill aVetIte
aKill aVetDTP
aKill aPenNFc
aKill aPenCal
aKill aVetRota
aKill aColsRota
aKill aRet
aKill aVetCal
aKill aVetTroca
aKill aColsPag
aKill aPenSol
aKill aPanAgeTms
aKill aValInfVia
aKill aValVia
aKill aMsgErr
aKill aBloqueio

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Age ³ Autor ³ Valdemar Roberto    ³ Data ³ 05/11/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Localiza Agendamentos Marcados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Age                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76Age(lRefazObj,lMntQuery,lQryVia,cSerTMS,cTipTra,lGetViag,lSoViagem,lSemDoc)
Local aAreas    := {DF1->(GetArea()),GetArea()}
Local aRecnos   := {}
Local cAgenda   := ""
Local cItens    := ""
Local cQuery    := ""
Local cQueryIni := ""
Local cQueryUni := ""
Local cQueryFim := ""
Local cAliasDF1 := ""
Local nCntFor1  := 0
Local cQryDel   := ""

DEFAULT lRefazObj	:= .F.
DEFAULT lMntQuery	:= .F.
DEFAULT lQryVia	    := .F.
Default lGetViag	:= .F.
DEFAULT lSoViagem   := .F.
DEFAULT lSemDoc     := .F.

If Type("__cSerAdi") != "C"
	__cSerAdi := "2"
Endif

CursorWait()

//-- Define o inicio da query normal
cQueryIni := "SELECT DISTINCT DF1AGD.DF1_NUMAGE,DF1AGD.DF1_ITEAGE,DF1AGD.DF1_FILDOC,DF1AGD.DF1_DOC,DF1AGD.DF1_SERIE"
If lQryVia
	cQueryIni += ",DUDAGD.R_E_C_N_O_ REGDUD,DF1AGD.R_E_C_N_O_ REGDF1"
	If cSerTms != "1"
		cQueryIni += ",DTCAGD.DTC_DOC DTC_DOC"
	Else
		cQueryIni += ",' ' DTC_DOC"
	EndIf
EndIf
cQueryIni += "  FROM " + cDF1 + " DF1AGD "

//-- Define o inicio da query do union
cQueryUni := "SELECT DISTINCT DF1AGD.DF1_NUMAGE,DF1AGD.DF1_ITEAGE,DF1AGD.DF1_FILDOC,DF1AGD.DF1_DOC,DF1AGD.DF1_SERIE"
If lQryVia
	cQueryUni += ",DUDAGD.R_E_C_N_O_ REGDUD,DF1AGD.R_E_C_N_O_ REGDF1"
	cQueryUni += ",' ' DTC_DOC"
EndIf
cQueryUni += "  FROM " + cDF1 + " DF1AGD "

//-- Define o fim da query
cQueryFim := " WHERE  DF1AGD.DF1_FILIAL = '" + xFilial("DF1") + "' "
If !lSoViagem
	cQueryFim += "   AND  DF1AGD.DF1_MRKPAN = '" + cNumThread + "' "
EndIf
If !lSemDoc
	cQueryFim += "   AND  DF1AGD.DF1_FILDOC <> '" + Space(TamSX3("DF1_FILDOC")[1]) + "' "
	cQueryFim += "   AND  DF1AGD.DF1_DOC    <> '" + Space(TamSX3("DF1_DOC")[1]) + "' "
	cQueryFim += "   AND  DF1AGD.DF1_SERIE  <> '" + Space(TamSX3("DF1_SERIE")[1]) + "' "
EndIf
cQueryFim += "   AND DF1AGD.D_E_L_E_T_ = ' ' "

//--Define query geral
cAliasDF1 := GetNextAlias()
cQuery := cQueryIni

If lQryVia
	aVetPrg := {}
	If cSerTms == "1"
		If lSoViagem
			cQuery += "  INNER JOIN " + cDUD + " DUDAGD "
		Else
			cQuery += "  LEFT  JOIN " + cDUD + " DUDAGD "
		EndIf
		cQuery += "    ON DUDAGD.DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += "   AND DUDAGD.DUD_FILDOC = DF1AGD.DF1_FILDOC "
		cQuery += "   AND DUDAGD.DUD_DOC    = DF1AGD.DF1_DOC "
		cQuery += "   AND DUDAGD.DUD_SERIE  = DF1AGD.DF1_SERIE "
		If lSoViagem
			cQuery += "   AND DUDAGD.DUD_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
		Else
			cQuery += "   AND DUDAGD.DUD_VIAGEM = '" + Space(Len(DUD->DUD_VIAGEM)) + "' "
		EndIf
		cQuery += "   AND DUDAGD.DUD_SERTMS = '1' "
		cQuery += "   AND DUDAGD.DUD_TIPTRA = '" + cTipTra + "' "
		cQuery += "   AND DUDAGD.D_E_L_E_T_ = ' ' "
		cQuery += cQueryFim
	Else
		cQuery += " LEFT JOIN " + cDTC + " DTCAGD "
		cQuery += "    ON DTCAGD.DTC_FILIAL = '" + xFilial("DTC") + "' "
		cQuery += "   AND DTCAGD.DTC_NUMSOL = DF1AGD.DF1_DOC "
		cQuery += "   AND DTCAGD.DTC_FILCFS = DF1AGD.DF1_FILDOC "
		cQuery += "   AND DTCAGD.DTC_NUMSOL <> ' ' "
		cQuery += "   AND DTCAGD.D_E_L_E_T_ = ' ' "
		If lSoViagem
			cQuery += "  INNER JOIN " + cDUD + " DUDAGD "
		Else
			cQuery += "  LEFT OUTER JOIN " + cDUD + " DUDAGD "
		EndIf
		cQuery += "    ON DUDAGD.DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += "   AND DUDAGD.DUD_FILDOC = DTCAGD.DTC_FILDOC "
		cQuery += "   AND DUDAGD.DUD_DOC    = DTCAGD.DTC_DOC "
		cQuery += "   AND DUDAGD.DUD_SERIE  = DTCAGD.DTC_SERIE "
		If lSoViagem
			cQuery += "   AND DUDAGD.DUD_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
		Else
			cQuery += "   AND DUDAGD.DUD_VIAGEM = '" + Space(Len(DUD->DUD_VIAGEM)) + "' "
		EndIf
		cQuery += "   AND DUDAGD.DUD_SERTMS <> '1' "
		cQuery += "   AND DUDAGD.DUD_TIPTRA = '" + cTipTra + "' "
		cQuery += "   AND DUDAGD.D_E_L_E_T_ = ' ' "
		cQuery += cQueryFim
		If __cSerAdi == "1"
			cQuery += " UNION ALL "
			cQuery += cQueryUni
			If lSoViagem
				cQuery += "  INNER JOIN " + cDUD + " DUDAGD "
			Else
				cQuery += "  LEFT OUTER JOIN " + cDUD + " DUDAGD "
			EndIf
			cQuery += "    ON DUDAGD.DUD_FILIAL = '" + xFilial("DUD") + "' "
			cQuery += "   AND DUDAGD.DUD_FILDOC = DF1AGD.DF1_FILDOC "
			cQuery += "   AND DUDAGD.DUD_DOC    = DF1AGD.DF1_DOC "
			cQuery += "   AND DUDAGD.DUD_SERIE  = DF1AGD.DF1_SERIE "
			If lSoViagem
				cQuery += "   AND DUDAGD.DUD_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
			Else
				cQuery += "   AND DUDAGD.DUD_VIAGEM = '" + Space(Len(DUD->DUD_VIAGEM)) + "' "
			EndIf
			cQuery += "   AND DUDAGD.DUD_TIPTRA = '" + cTipTra + "' "
			cQuery += "   AND DUDAGD.D_E_L_E_T_ = ' ' 
			cQuery += " WHERE NOT EXISTS (SELECT 1 "
			cQuery += "                     FROM " + cDTC + " DTCAGD "
			cQuery += "                    WHERE DTCAGD.DTC_FILIAL = '" + xFilial("DTC") + "' "
			cQuery += "                      AND DTCAGD.DTC_NUMSOL = DF1AGD.DF1_DOC "
			cQuery += "                      AND DTCAGD.DTC_FILCFS = DF1AGD.DF1_FILDOC "
			cQuery += "                      AND DTCAGD.D_E_L_E_T_ = ' ')
			cQuery += "   AND  DF1AGD.DF1_FILIAL = '" + xFilial("DF1") + "' "
			If !lSoViagem
				cQuery += "   AND  DF1AGD.DF1_MRKPAN = '" + cNumThread + "' "
			EndIf
			If !lSemDoc
				cQuery += "   AND  DF1AGD.DF1_FILDOC <> '" + Space(TamSX3("DF1_FILDOC")[1]) + "' "
				cQuery += "   AND  DF1AGD.DF1_DOC    <> '" + Space(TamSX3("DF1_DOC")[1]) + "' "
				cQuery += "   AND  DF1AGD.DF1_SERIE  <> '" + Space(TamSX3("DF1_SERIE")[1]) + "' "
			EndIf
			cQuery += "   AND DF1AGD.D_E_L_E_T_ = ' ' "
		EndIf
	EndIf
Else
	cQuery += cQueryFim
EndIf

cQuery += " ORDER BY  DF1_NUMAGE,DF1_ITEAGE "

cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDF1,.T.,.T.)

DUD->(DbSetOrder(1))

cQryDel := "DELETE FROM " + oTempTable:GetRealName()
TCSqlExec(cQryDel)

While (cAliasDF1)->(!Eof())
	
	RecLock( ctabAgd , .T. )
	(ctabAgd)->DF1_NUMAGE := (cAliasDF1)->DF1_NUMAGE
	(ctabAgd)->DF1_ITEAGE := (cAliasDF1)->DF1_ITEAGE
	(ctabAgd)->(MsUnlock())

	cAgenda += "'" + (cAliasDF1)->DF1_NUMAGE + "',"
	cItens  += "'" + (cAliasDF1)->DF1_ITEAGE + "',"		
	If lQryVia
		If (cAliasDF1)->REGDUD > 0
			Aadd(aRecnos,(cAliasDF1)->REGDUD)
		EndIf
		If (cAliasDF1)->REGDF1 > 0
			Aadd(aVetPrg,(cAliasDF1)->REGDF1)
		EndIf
	EndIf
	(cAliasDF1)->(DbSkip())
EndDo
(cAliasDF1)->(DbCloseArea())
DbSelectArea("DF1")

If Right(cAgenda,1) == ","
	cAgenda := Left(cAgenda,Len(cAgenda) - 1)
EndIf

If Right(cItens,1) == ","
	cItens  := Left(cItens,Len(cItens) - 1)
EndIf

If Empty(cAgenda) .And. Empty(cItens)
	cAgenda := "''"
	cItens  := "''"
EndIf
 
If lMntQuery 
	If Empty(aBrowseOpe[1][1])
		aBrowseOpe := TMSF76Qry( 2, cAgenda, cItens, .F., .F., oTempTable:GetRealName() )
	EndIf
EndIf

If lRefazObj
	For nCntFor1 := 1 To Len(aBrowseOpe)
		aBrowseOpe[nCntFor1][4] := .T.
	Next nCntFor1
	TMSF76Fldr()
EndIf

CursorArrow()

AEval(aAreas,{|x,y| RestArea(x) })
aKill aAreas

Return {cAgenda,cItens,aRecnos}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Lim ³ Autor ³ Valdemar Roberto    ³ Data ³ 16/05/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Limpa marcas anteriores                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Lim                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76Lim(cNumThr)
Local cQuery := ""
Local cAlias := GetNextAlias()
Local aAreas := {DF1->(GetArea()),GetArea()}

cQuery := " SELECT DF1.R_E_C_N_O_ DF1REC FROM  "
cQuery += cDF1+" DF1"
cQuery += " WHERE DF1_FILIAL = '" + xFilial("DF1") + "' "
cQuery += "   AND DF1_MRKPAN = '" + cNumThr + "' "
cQuery += "   AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

While (cAlias)->(!Eof())
	DF1->(dbGoto((cAlias)->DF1REC))
	RecLock("DF1",.F.)
	DF1_MRKPAN :=  Space(Len(DF1->DF1_MRKPAN))
	DF1->(MsUnlock())
	(cAlias)->(dbSkip())
endDo
(cAlias)->(dbCloseArea())

aEval(aAreas,{|x| RestArea(x) })
aKill aAreas

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Qry ³ Autor ³ Valdemar Roberto    ³ Data ³ 20/05/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta query e colunas dos browses                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Qry                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76Qry(nAcao,cAgenda,cItens,lPriVez,lFilEsp,cTableAgdT)
Local nCntFor1 := 0
Local nCntFor2 := 0
Local cAlias   := ""
Local cQuery   := ""
Local cWhere   := ""
Local aCampos  := {}
Local aRet     := {}
Local aRetDin  := {}
Local aVetWrk  := {}
Local aQuery   := {}
Local lFilAgen := SuperGetMV("MV_FILAGEN",.F.,.F.)
Local lCont    := .T.
Local cCompQry := ""
Local aJoin :={	{"DF0",""},;//--Não tem Join só where
					{"DF1",""},;//--Não tem Join só where
					{"DT5",""},;
					{"DTC",""},;
					{"DT6",""},;
					{"DTQ",""},;
					{"DTR",""},;
					{"DUP",""},;
					{"DA3",""},;
					{"DA4",""},;
					{"DTW",""},;
					{"DTY",""},;
					{"DDG",""}}

DEFAULT nAcao    := 0
DEFAULT cAgenda  := "''"
DEFAULT cItens   := "''"
DEFAULT lPriVez  := .F.
DEFAULT lFilEsp  := .F.
DEFAULT cTableAgdT := ""
//-- Mapa do vetor aVetWrk
//-- 01 - Alias do join
//-- 02 - Filtro para o usuario
//-- 03 - Filtro para o sistema
//-- 04 - Alias superior para join
//-- 05 - Indica se ja foi feito join para o alias superior

Static cDA3 := RetSqlName("DA3")
Static cDA4 := RetSqlName("DA4")
Static cDD9 := RetSqlName("DD9")
Static cDDG := RetSqlName("DDG")
Static cDE5 := RetSqlName("DE5")
Static cDF0 := RetSqlName("DF0")
Static cDF1 := RetSqlName("DF1")
Static cDF8 := RetSqlName("DF8")
Static cDT5 := RetSqlName("DT5")
Static cDT6 := RetSqlName("DT6")
Static cDTC := RetSqlName("DTC")
Static cDTP := RetSqlName("DTP")
Static cDTQ := RetSqlName("DTQ")
Static cDTR := RetSqlName("DTR")
Static cDTW := RetSqlName("DTW")
Static cDTX := RetSqlName("DTX")
Static cDTY := RetSqlName("DTY")
Static cDU1 := RetSqlName("DU1")
Static cDUA := RetSqlName("DUA")
Static cDUD := RetSqlName("DUD")
Static cDUP := RetSqlName("DUP")
Static cSA1 := RetSqlName("SA1")
Static cSA6 := RetSqlName("SA6") //--COMENTAR QUANDO FOR TUDO DICIONÁRIO
Static cDDD := RetSqlName("DDD")
Static cSE1 := RetSqlName("SE1")
Static cDRT := RetSqlName("DRT")

If nAcao == 1 //-- Agendamento

	//-- Monta array de trabalho
	For nCntFor1 := 1 To Len(aVetExp)
		Aadd(aVetWrk,{aVetExp[nCntFor1,1],;
					  aVetExp[nCntFor1,2],;
					  aVetExp[nCntFor1,3],;
					  aAliasSup[nCntFor1],;
					  .F.})
	Next nCntFor1

	If lTMF76Din .And. lFilEsp
		aRetDin := ExecBlock("TMF76Din",.F.,.F.,{2,Aclone(aAliasFil),Aclone(aAliasSup)})
		If ValType(aRetDin) == "A" .And. !Empty(aRetDin)
			aVetWrk := Aclone(aRetDin)
			aVetExp := {}
			For nCntFor1 := 1 To Len(aVetWrk)
				Aadd(aVetExp,{aVetWrk[nCntFor1,1],;
							  aVetWrk[nCntFor1,2],;
							  aVetWrk[nCntFor1,3],;
							  aAliasFil[nCntFor1,2]})
			Next nCntFor1
		EndIf
	EndIf

	//-- Monta estrutura de Joins
	For nCntFor1 := 1 To Len(aVetWrk)
		If !Empty(aVetWrk[nCntFor1,3])
			TMSF76Joi(aVetWrk,@aJoin,nCntFor1,@cWhere)
		EndIf
	Next nCntFor1
	aCampos := TMSF76Cp1(nAcao,"DF1")
	cAlias := GetNextAlias()
	For nCntFor1 := 1 To 2
		lCont := (nCntFor1 == 1)
		If !lCont
			lCont := ! empty(aJoin[06][02]) //--DTQ
		EndIf
		If lCont
			If nCntFor1 == 2
				cQuery := "SELECT * FROM (" + cQuery
				cQuery += " UNION "
			EndIf
			cQuery += "SELECT " + aCampos[1]
			cQuery += "  FROM " + cDF1 + " DF1 "

			cQuery += "  JOIN " + cDF0 + " DF0 "
			cQuery += "    ON DF0.DF0_FILIAL = '" + xFilial("DF0") + "' "
			cQuery += "   AND DF0.DF0_NUMAGE = DF1.DF1_NUMAGE "
			cQuery += "   AND DF0.D_E_L_E_T_ = ' ' "
			
			If "SA1REM."$cWhere
				cQuery += "  JOIN " + cSA1 + " SA1REM "
				cQuery += "    ON SA1REM.A1_FILIAL  = '" + xFilial("SA1") + "' "
				cQuery += "   AND SA1REM.A1_COD     =  DF1.DF1_CLIREM "
				cQuery += "   AND SA1REM.A1_LOJA    =  DF1.DF1_LOJREM "
				cQuery += "   AND SA1REM.D_E_L_E_T_ = ' ' "
			EndIf
			
			If "SA1DES."$cWhere
				cQuery += "  JOIN " + cSA1 + " SA1DES "
				cQuery += "    ON SA1DES.A1_FILIAL  = '" + xFilial("SA1") + "' "
				cQuery += "   AND SA1DES.A1_COD     =  DF1.DF1_CLIDES "
				cQuery += "   AND SA1DES.A1_LOJA    =  DF1.DF1_LOJDES "
				cQuery += "   AND SA1DES.D_E_L_E_T_ = ' ' "
			EndIf
			
			If "SA1DEV."$cWhere
				cQuery += "  JOIN " + cSA1 + " SA1DEV "
				cQuery += "    ON SA1DEV.A1_FILIAL  = '" + xFilial("SA1") + "' "
				cQuery += "   AND SA1DEV.A1_COD     =  DF1.DF1_CLIDEV "
				cQuery += "   AND SA1DEV.D_E_L_E_T_ = ' ' "
			EndIf
			
			cQuery += aJoin[01][02] //--DF0 sempre vazio
		    cQuery += aJoin[02][02] //--DF1 sempre vazio
			cQuery += aJoin[03][02] //--DT5
			cQuery += aJoin[04][02] //--DTC
			cQuery += aJoin[05][02] //--DT6
			cQuery += aJoin[13][02] //--DDG
			
			If "SA1CON."$cWhere
				cQuery += "  JOIN " + cSA1 + " SA1CON "
				cQuery += "    ON SA1CON.A1_FILIAL  = '" + xFilial("SA1") + "' "
				cQuery += "   AND SA1CON.A1_COD     = DTC_CLICON "
				cQuery += "   AND SA1CON.A1_LOJA    = DTC_LOJCON "
				cQuery += "   AND SA1CON.D_E_L_E_T_ = ' ' "
			EndIf
			
			If ! empty(aJoin[06][02]) //--DTQ
				If nCntFor1 == 1
					cQuery += "  JOIN " + cDUD + " DUD "
					cQuery += "    ON DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
					cQuery += "   AND DUD.DUD_FILDOC =  DF1.DF1_FILDOC "
					cQuery += "   AND DUD.DUD_DOC    =  DF1.DF1_DOC "
					cQuery += "   AND DUD.DUD_SERIE  =  DF1.DF1_SERIE "
					cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
				Else
					If empty(aJoin[04][02])//--DTC
						cQuery += "  JOIN " + cDTC + " DTC "
						cQuery += "    ON DTC.DTC_FILIAL = '" + xFilial("DTC") + "' "
						cQuery += "   AND DTC.DTC_NUMSOL =  DF1.DF1_DOC "
						cQuery += "   AND DTC.DTC_FILCFS =  DF1.DF1_FILDOC "
						cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
					EndIf
					cQuery += "  JOIN " + cDUD + " DUD "
					cQuery += "    ON DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
					cQuery += "   AND DUD.DUD_FILDOC = DTC_FILDOC "
					cQuery += "   AND DUD.DUD_DOC    = DTC_DOC "
					cQuery += "   AND DUD.DUD_SERIE  = DTC_SERIE "
					cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
				EndIf
			EndIf
			
			cQuery += aJoin[06][02] //--DTQ
			cQuery += aJoin[07][02] //--DTR
			cQuery += aJoin[08][02] //--DUP
			cQuery += aJoin[09][02] //--DA3
			cQuery += aJoin[10][02] //--DA4
			cQuery += aJoin[11][02] //--DTW
			cQuery += aJoin[12][02] //--DTY	

			If lFilAgen .And. lPriVez
				cQuery += " WHERE  DF1.DF1_FILIAL = 'zz' "
			Else
				cQuery += " WHERE  DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
			EndIf
			cQuery += "  AND DF1.DF1_FILORI ='"+ cFilAnt +"'"
			cQuery += cWhere
			cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
			If nCntFor1 == 2
				cQuery := cQuery + ") " + cAlias
			EndIf
		Else
			cQuery := StrTran(cQuery,"SELECT ","SELECT DISTINCT ")
		EndIf
	Next nCntFor1
	cQuery += " ORDER BY  DF1_FILIAL, DF1_NUMAGE, DF1_ITEAGE"
	aRet := {cAlias,aClone(aCampos[2]),cQuery,.T.}
ElseIf nAcao == 2 //-- Folders
	If !Empty(cAgenda + cItens)
		For nCntFor2 := 1 To Len(aRotinas)
			If aRotinas[nCntFor2,5]
				If lTMF76ADD
					aQuery := ExecBlock("TMF76ADD",.F.,.F.,{2})
					If ValType(aQuery) == "A"
						cAlias := GetNextAlias()
						cQuery:= aQuery[1]
						Aadd(aRet,{cAlias,aClone(aQuery[2]),cQuery,.T.})
					EndIf
				EndIf
			Else
				aCampos := TMSF76Cp1(nAcao,aRotinas[nCntFor2,1])
				cAlias := GetNextAlias()
				If aRotinas[nCntFor2,1] == "DTQ"
					cQuery := "SELECT DISTINCT * FROM (SELECT  " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDUD + " DUD "
					cQuery += "    ON DUD_FILIAL = '" + xFilial("DUD") + "' "
					cQuery += "   AND DUD_FILDOC =  DF1.DF1_FILDOC "
					cQuery += "   AND DUD_DOC    =  DF1.DF1_DOC "
					cQuery += "   AND DUD_SERIE  =  DF1.DF1_SERIE "
					cQuery += "   AND DUD_VIAGEM <> '" + Space(Len(DUD->DUD_VIAGEM)) + "' "
					cQuery += "   AND DUD_SERTMS = '1' "
					cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDTQ + " DTQ "
					cQuery += "    ON DTQ_FILIAL = '" + xFilial("DTQ") + "' "
					cQuery += "   AND DTQ_FILORI = DUD_FILORI "
					cQuery += "   AND DTQ_VIAGEM = DUD_VIAGEM "
					cQuery += "   AND DTQ.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON   DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "

					cQuery += " WHERE  DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " UNION ALL "
					cQuery += "SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDT5 + " DT5 "
					cQuery += "    ON DT5_FILIAL = '" + xFilial("DT5") + "' "
					cQuery += "   AND DT5_FILORI =  DF1.DF1_FILDOC "
					cQuery += "   AND DT5_NUMSOL =  DF1.DF1_DOC "
					cQuery += "   AND DT5.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDTC + " DTC "
					cQuery += "    ON DTC_FILIAL = '" + xFilial("DTC") + "' "
					cQuery += "   AND DTC_NUMSOL = DT5_NUMSOL "
					cQuery += "   AND DTC_FILCFS = DT5_FILORI "
					cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDUD + " DUD "
					cQuery += "    ON DUD_FILIAL = '" + xFilial("DUD") + "' "
					cQuery += "   AND DUD_FILDOC = DTC_FILDOC "
					cQuery += "   AND DUD_DOC    = DTC_DOC "
					cQuery += "   AND DUD_SERIE  = DTC_SERIE "
					cQuery += "   AND DUD_VIAGEM <> '" + Space(Len(DUD->DUD_VIAGEM)) + "' "
					cQuery += "   AND DUD_SERTMS <> '1' "
					cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDTQ + " DTQ "
					cQuery += "    ON DTQ_FILIAL = '" + xFilial("DTQ") + "' "
					cQuery += "   AND DTQ_FILORI = DUD_FILORI "
					cQuery += "   AND DTQ_VIAGEM = DUD_VIAGEM "
					cQuery += "   AND DTQ.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON   DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "

					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ') " + cAlias
					cQuery += " ORDER BY DTQ_FILIAL"
				ElseIf aRotinas[nCntFor2,1] == "DF8"
					cQuery := "SELECT DISTINCT * FROM ( "
					cQuery += " SELECT " + aCampos[1]
					cQuery += " FROM " + cDD9 + " DD9	"
					cQuery += " INNER JOIN " + cDTC + " DTC  "
					cQuery += " 	 	ON  DTC.DTC_FILIAL  = '"+ FwxFilial("DTC") +"' "
					cQuery += " 	 	AND DTC.DTC_CLIREM = DD9.DD9_CLIREM "    
					cQuery += " 	 	AND DTC.DTC_LOJREM = DD9.DD9_LOJREM "     
					cQuery += " 	 	AND DTC.DTC_NUMNFC = DD9.DD9_NUMNFC "     
					cQuery += " 	 	AND DTC.DTC_SERNFC = DD9.DD9_SERNFC "     
					cQuery += " 	 	AND DTC.D_E_L_E_T_ = ' '            "
					cQuery += " INNER JOIN " + cDF8 + " DF8                 "
					cQuery += "     ON DF8_FILIAL = '"+ FwxFilial("DF8") +"' "
					cQuery += "     AND DF8_FILORI = DD9_FILORI             "
					cQuery += "     AND DF8_NUMPRG = DD9_NUMPRG             "
					cQuery += "     AND DF8.D_E_L_E_T_ = ' '                "
					cQuery += " INNER JOIN " + cDF1 + " DF1                       "
					cQuery += "          ON DF1.DF1_FILIAL = '"+ FwxFilial("DF1") +"'  "
					cQuery += "             AND DF1.DF1_FILDOC = DTC_FILCFS     "
					cQuery += "             AND DF1.DF1_DOC    =  DTC_NUMSOL    "
					cQuery += "             AND DF1.D_E_L_E_T_ = ' '	       "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds "
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += "  AND DF1.DF1_DOC    > '" + SPACE(LEN(DF1->DF1_DOC)) + "' "

					cQuery += " WHERE DD9_FILIAL = '"+ FwxFilial("DD9") +"' "
					cQuery += " 	  AND DD9.DD9_DOC = ' '                  "
					cQuery += " 	  AND DD9.D_E_L_E_T_ = ' ' 	             "
					cQuery += " 	 UNION ALL "
					cQuery += " SELECT " + aCampos[1]
					cQuery += " FROM " + cDD9 + " DD9	"
					cQuery += " INNER JOIN " + cDTC + " DTC  "
					cQuery += " 	 	ON  DTC.DTC_FILIAL  = '"+ FwxFilial("DTC") +"' "
					cQuery += " 	 	AND DTC.DTC_CLIREM = DD9.DD9_CLIREM "    
					cQuery += " 	 	AND DTC.DTC_LOJREM = DD9.DD9_LOJREM "     
					cQuery += " 	 	AND DTC.DTC_NUMNFC = DD9.DD9_NUMNFC "     
					cQuery += " 	 	AND DTC.DTC_SERNFC = DD9.DD9_SERNFC "     
					cQuery += " 	 	AND DTC.D_E_L_E_T_ = ' '            "
					cQuery += " INNER JOIN " + cDF8 + " DF8                 "
					cQuery += "     ON DF8_FILIAL = '"+ FwxFilial("DF8") +"' "
					cQuery += "     AND DF8_FILORI = DD9_FILORI             "
					cQuery += "     AND DF8_NUMPRG = DD9_NUMPRG             "
					cQuery += "     AND DF8.D_E_L_E_T_ = ' '                "
					cQuery += " INNER JOIN " + cDF1 + " DF1                       "
					cQuery += "          ON DF1.DF1_FILIAL = '"+ FwxFilial("DF1") +"'  "
					cQuery += "             AND DF1.DF1_FILDOC = DTC_FILCFS     "
					cQuery += "             AND DF1.DF1_DOC    =  DTC_NUMSOL    "
					cQuery += "             AND DF1.DF1_DOC > ' ' "
					cQuery += "             AND DF1.D_E_L_E_T_ = ' '	       "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE
					cQuery += " WHERE DD9_FILIAL = '"+ FwxFilial("DD9") +"' "
					cQuery += " 	  AND DD9.DD9_DOC <> ' '                  "
					cQuery += " 	  AND DD9.D_E_L_E_T_ = ' ' 	             "
					cQuery += " 	 UNION ALL "
					cQuery += " SELECT  " + aCampos[1]
					cQuery += " FROM " + cDD9 + " DD9	"
					cQuery += " INNER JOIN " + cDF8 + " DF8 "
					cQuery += "     ON DF8_FILIAL = '"+ FwxFilial("DF8") +"' "
					cQuery += "     AND DF8_FILORI = DD9_FILORI "
					cQuery += "     AND DF8_NUMPRG = DD9_NUMPRG "
					cQuery += "     AND DF8.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN "+ cDF1 +" DF1 "
					cQuery += "     ON DF1.DF1_FILIAL = '"+ FwxFilial("DF1") +"' "
					cQuery += "     AND DF1.DF1_FILDOC = DD9.DD9_FILDOC	"
					cQuery += "     AND DF1.DF1_DOC   =  DD9.DD9_DOC "
					cQuery += "     AND DF1.DF1_SERIE =  DD9.DD9_SERIE "
					cQuery += "     AND DF1.DF1_DOC > ' ' "
					cQuery += "     AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += " WHERE DD9_FILIAL = '"+ FwxFilial("DD9") +"' "
					cQuery += " 	  AND DD9.DD9_DOC <> ' ' "
					cQuery += " 	  AND DD9.D_E_L_E_T_ = ' ' "
					cQuery += " 	 UNION ALL "
					cQuery += " SELECT " + aCampos[1]
					cQuery += " FROM " + cDD9 + " DD9	"
					cQuery += " INNER JOIN "+ cDT5 +" DT5 "
					cQuery += "	 ON  DT5.DT5_FILIAL  = '"+ FwxFilial("DT5") +"' "
					cQuery += "	 AND DT5.DT5_FILDOC = DD9.DD9_FILDOC		"
					cQuery += "	 AND DT5.DT5_DOC = DD9.DD9_DOC				"
					cQuery += "	 AND DT5.DT5_SERIE = DD9.DD9_SERIE			"
					cQuery += "	 AND DT5.D_E_L_E_T_ = ' ' 					"
					cQuery += " INNER JOIN " + cDF8 + " DF8                 "
					cQuery += "     ON DF8_FILIAL = '"+ FwxFilial("DF8") +"' "
					cQuery += "     AND DF8_FILORI = DD9_FILORI             "
					cQuery += "     AND DF8_NUMPRG = DD9_NUMPRG             "
					cQuery += "     AND DF8.D_E_L_E_T_ = ' '                "
					cQuery += " INNER JOIN "+ cDF1 +" DF1  					"
					cQuery += "     ON DF1.DF1_FILIAL = '"+ FwxFilial("DF1") +"'" 
					cQuery += "     AND DF1.DF1_FILDOC = DT5_FILORI             "
					cQuery += "     AND DF1.DF1_DOC  =  DT5_NUMSOL "
					cQuery += "     AND DF1.DF1_DOC  > ' ' "
					cQuery += "     AND DF1.D_E_L_E_T_ = ' ' " 
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += " WHERE DD9_FILIAL = '"+ FwxFilial("DD9") +"' "
					cQuery += " 	  AND DD9.DD9_DOC <> ' '                  "
					cQuery += " 	  AND DD9.D_E_L_E_T_ = ' '              "
					cQuery += "  ) TAB"
					cQuery += " ORDER BY DF8_FILIAL,DF8_FILORI,DF8_VIAGEM"
				ElseIf aRotinas[nCntFor2,1] == "DF0"
					cQuery := "SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDF0 + " DF0 "
					cQuery += "    ON DF0_FILIAL = '" + xFilial("DF0") + "' "
					cQuery += "   AND DF0_NUMAGE = DF1.DF1_NUMAGE "
					cQuery += "   AND DF0.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " ORDER BY DF0_FILIAL,DF0_NUMAGE"
				ElseIf aRotinas[nCntFor2,1] == "DT5"
					cQuery := "SELECT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDF0 + " DF0 "
					cQuery += "    ON DF0_FILIAL = '" + xFilial("DF0") + "' "
					cQuery += "   AND DF0_NUMAGE = DF1.DF1_NUMAGE "
					cQuery += "   AND DF0.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDT5 + " DT5 "
					cQuery += "    ON DT5_FILIAL = '" + xFilial("DT5") + "' "
					cQuery += "   AND DT5_FILORI = DF1.DF1_FILDOC "
					cQuery += "   AND DT5_NUMSOL = DF1.DF1_DOC "
					cQuery += "   AND DT5.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " ORDER BY DT5_FILIAL,DT5_FILORI,DT5_NUMSOL"
				ElseIf aRotinas[nCntFor2,1] == "DTC"
					cQuery := "SELECT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDT5 + " DT5 "
					cQuery += "    ON DT5_FILIAL = '" + xFilial("DT5") + "' "
					cQuery += "   AND DT5_FILORI = DF1.DF1_FILDOC "
					cQuery += "   AND DT5_NUMSOL = DF1.DF1_DOC "
					cQuery += "   AND DT5.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDTC + " DTC "
					cQuery += "    ON DTC_FILIAL = '" + xFilial("DTC") + "' "
					cQuery += "   AND DTC_NUMSOL = DT5_NUMSOL "
					cQuery += "   AND DTC_FILCFS = DT5_FILORI "
					cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += "  AND DF1.DF1_DOC    > '" + SPACE(LEN(DF1->DF1_DOC)) + "' "
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " ORDER BY DTC_FILIAL,DTC_CLIREM,DTC_LOJREM,DTC_NUMNFC,DTC_SERNFC,DTC_CODPRO"
				ElseIf aRotinas[nCntFor2,1] == "DTP"
					cQuery := "SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += "  INNER JOIN " + cDT5 + " DT5 "
					cQuery += "    ON DT5_FILIAL = '" + xFilial("DT5") + "' "
					cQuery += "   AND DT5_FILORI = DF1.DF1_FILDOC "
					cQuery += "   AND DT5_NUMSOL = DF1.DF1_DOC "
					cQuery += "   AND DT5.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDTC + " DTC "
					cQuery += "    ON DTC_FILIAL = '" + xFilial("DTC") + "' "
					cQuery += "   AND DTC_NUMSOL = DT5_NUMSOL "
					cQuery += "   AND DTC_FILCFS = DT5_FILORI "
					cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDTP + " DTP "
					cQuery += "    ON DTP_FILIAL = '" + xFilial("DTP") + "' "
					cQuery += "   AND DTP_FILORI = DTC_FILORI "
					cQuery += "   AND DTP_LOTNFC = DTC_LOTNFC "
					cQuery += "   AND DTP.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " ORDER BY DTP_FILIAL,DTP_FILORI,DTP_LOTNFC"
				ElseIf aRotinas[nCntFor2,1] == "DTX"
					cQuery := "SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDTC + " DTC "
					cQuery += "    ON DTC_FILIAL = '" + xFilial("DTC") + "' "
					cQuery += "   AND DTC_NUMSOL = DF1.DF1_DOC "
					cQuery += "   AND DTC_FILCFS = DF1.DF1_FILDOC "
					cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDT6 + " DT6 "
					cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
					cQuery += "   AND DT6_FILDOC = DTC_FILDOC "
					cQuery += "   AND DT6_DOC    = DTC_DOC "
					cQuery += "   AND DT6_SERIE  = DTC_SERIE "
					cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDUD + " DUD "
					cQuery += "    ON DUD_FILIAL = '" + xFilial("DUD") + "' "
					cQuery += "   AND DUD_FILDOC = DT6_FILDOC "
					cQuery += "   AND DUD_DOC    = DT6_DOC "
					cQuery += "   AND DUD_SERIE  = DT6_SERIE "
					cQuery += "   AND DUD_VIAGEM <> '" + Space(Len(DUD->DUD_VIAGEM)) + "' "
					cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDTX + " DTX "
					cQuery += "    ON DTX_FILIAL = '" + xFilial("DTX") + "' "
					cQuery += "   AND DTX_FILMAN = DUD_FILMAN "
					cQuery += "   AND DTX_MANIFE = DUD_MANIFE "
					cQuery += "   AND DTX.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += "  AND DF1.DF1_DOC    > '" + SPACE(LEN(DF1->DF1_DOC)) + "' "
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " UNION "
					cQuery += "SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDUD + " DUD "
					cQuery += "    ON DUD_FILIAL = '" + xFilial("DUD") + "' "
					cQuery += "   AND DUD_FILDOC = DF1.DF1_FILDOC "
					cQuery += "   AND DUD_DOC    = DF1.DF1_DOC "
					cQuery += "   AND DUD_SERIE  = 'COL' "
					cQuery += "   AND DUD_VIAGEM <> '" + Space(Len(DUD->DUD_VIAGEM)) + "' "
					cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDTX + " DTX "
					cQuery += "    ON DTX_FILIAL = '" + xFilial("DTX") + "' "
					cQuery += "   AND DTX_FILMAN = DUD_FILMAN "
					cQuery += "   AND DTX_MANIFE = DUD_MANIFE "
					cQuery += "   AND DTX.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += "  AND DF1.DF1_DOC    > '" + SPACE(LEN(DF1->DF1_DOC)) + "' "
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " ORDER BY DTX_FILIAL,DTX_FILMAN,DTX_MANIFE"
				ElseIf aRotinas[nCntFor2,1] == "DTY"
					cQuery := "SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDTC + " DTC "
					cQuery += "    ON DTC_FILIAL = '" + xFilial("DTC") + "' "
					cQuery += "   AND DTC_NUMSOL = DF1.DF1_DOC "
					cQuery += "   AND DTC_FILCFS = DF1.DF1_FILDOC "
					cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDT6 + " DT6 "
					cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
					cQuery += "   AND DT6_FILDOC = DTC_FILDOC "
					cQuery += "   AND DT6_DOC    = DTC_DOC "
					cQuery += "   AND DT6_SERIE  = DTC_SERIE "
					cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDUD + " DUD "
					cQuery += "    ON DUD_FILIAL = '" + xFilial("DUD") + "' "
					cQuery += "   AND DUD_FILDOC = DT6_FILDOC "
					cQuery += "   AND DUD_DOC    = DT6_DOC "
					cQuery += "   AND DUD_SERIE  = DT6_SERIE "
					cQuery += "   AND DUD_VIAGEM <> '" + Space(Len(DUD->DUD_VIAGEM)) + "' "
					cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDTY + " DTY "
					cQuery += "    ON DTY_FILIAL = '" + xFilial("DTY") + "' "
					cQuery += "   AND DTY_FILORI = DUD_FILORI "
					cQuery += "   AND DTY_VIAGEM = DUD_VIAGEM "
					cQuery += "   AND DTY.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += "  AND DF1.DF1_DOC    > '" + SPACE(LEN(DF1->DF1_DOC)) + "' "
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " UNION "
					cQuery += "SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDUD + " DUD "
					cQuery += "    ON DUD_FILIAL = '" + xFilial("DUD") + "' "
					cQuery += "   AND DUD_FILDOC = DF1.DF1_FILDOC "
					cQuery += "   AND DUD_DOC    = DF1.DF1_DOC "
					cQuery += "   AND DUD_SERIE  = 'COL' "
					cQuery += "   AND DUD_VIAGEM <> '" + Space(Len(DUD->DUD_VIAGEM)) + "' "
					cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDTY + " DTY "
					cQuery += "    ON DTY_FILIAL = '" + xFilial("DTY") + "' "
					cQuery += "   AND DTY_FILORI = DUD_FILORI "
					cQuery += "   AND DTY_VIAGEM = DUD_VIAGEM "
					cQuery += "   AND DTY.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += "  AND DF1.DF1_DOC    > '" + SPACE(LEN(DF1->DF1_DOC)) + "' "
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " ORDER BY DTY_FILIAL,DTY_FILORI,DTY_VIAGEM,DTY_NUMCTC"
				ElseIf aRotinas[nCntFor2,1] == "DT6"
					cQuery := "SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDTC + " DTC "
					cQuery += "    ON DTC_FILIAL = '" + xFilial("DTC") + "' "
					cQuery += "   AND DTC_NUMSOL = DF1.DF1_DOC "
					cQuery += "   AND DTC_FILCFS = DF1.DF1_FILORI "
					cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDT6 + " DT6 "
					cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
					cQuery += "   AND DT6_FILDOC = DTC_FILDOC "
					cQuery += "   AND DT6_DOC    = DTC_DOC "
					cQuery += "   AND DT6_SERIE  = DTC_SERIE "
					cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += "  AND DF1.DF1_DOC    > '" + SPACE(LEN(DF1->DF1_DOC)) + "' "
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " UNION "
					cQuery += "SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDT6 + " DT6 "
					cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
					cQuery += "   AND DT6_FILDOC = DF1.DF1_FILDOC "
					cQuery += "   AND DT6_DOC    = DF1.DF1_DOC "
					cQuery += "   AND DT6_SERIE  = 'COL' "
					cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " UNION "
					cQuery += "SELECT DISTINCT " + aCampos[1]
	                cQuery += "  FROM " + cDF1 + " DF1 "
	                cQuery += " INNER JOIN " + cDTC + " DTC "
	                cQuery += "    ON DTC_FILIAL = '" + xFilial("DTC") + "' "
	                cQuery += "   AND DTC_NUMSOL = DF1.DF1_DOC "
	                cQuery += "   AND DTC_FILCFS = DF1.DF1_FILORI "
	                cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
	                cQuery += " INNER JOIN " + cDT6 + " DT6 "
	                cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
	                cQuery += "   AND DT6_FILDCO = DTC_FILDOC "
	                cQuery += "   AND DT6_DOCDCO = DTC_DOC    "
	                cQuery += "   AND DT6_SERDCO = DTC_SERIE  "
	                cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += "  AND DF1.DF1_DOC    > '" + SPACE(LEN(DF1->DF1_DOC)) + "' "
	                cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += " AND DT6_FILDCO <> '"+ Space(TamSX3("DT6_FILDCO")[1]) +" ' "
					cQuery += " AND DT6_DOCDCO <> '"+ Space(TamSX3("DT6_DOCDCO")[1]) +" ' "
					cQuery += " AND DT6_SERDCO <> '"+ Space(TamSX3("DT6_SERDCO")[1]) +" ' "
	                cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
				ElseIf aRotinas[nCntFor2,1] == "DUA"
					cQuery := "SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDT6 + " DT6 "
					cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
					cQuery += "   AND DT6_FILDOC = DF1.DF1_FILDOC "
					cQuery += "   AND DT6_DOC    = DF1.DF1_DOC "
					cQuery += "   AND DT6_SERIE  = 'COL' "
					cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDUA + " DUA "
					cQuery += "    ON DUA_FILIAL = '" + xFilial("DUA") + "' "
					cQuery += "   AND DUA_FILDOC = DT6_FILDOC "
					cQuery += "   AND DUA_DOC    = DT6_DOC "
					cQuery += "   AND DUA_SERIE  = DT6_SERIE "
					cQuery += "   AND DUA.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += "  AND DF1.DF1_DOC    > '" + SPACE(LEN(DF1->DF1_DOC)) + "' "
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " UNION "
					cQuery += "SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDTC + " DTC "
					cQuery += "    ON DTC_FILIAL = '" + xFilial("DTC") + "' "
					cQuery += "   AND DTC_NUMSOL = DF1.DF1_DOC "
					cQuery += "   AND DTC_FILCFS = DF1.DF1_FILDOC "
					cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDT6 + " DT6 "
					cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
					cQuery += "   AND DT6_FILDOC = DTC_FILDOC "
					cQuery += "   AND DT6_DOC    = DTC_DOC "
					cQuery += "   AND DT6_SERIE  = DTC_SERIE "
					cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDUA + " DUA "
					cQuery += "    ON DUA_FILIAL = '" + xFilial("DUA") + "' "
					cQuery += "   AND DUA_FILDOC = DT6_FILDOC "
					cQuery += "   AND DUA_DOC    = DT6_DOC "
					cQuery += "   AND DUA_SERIE  = DT6_SERIE "
					cQuery += "   AND DUA.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += "  AND DF1.DF1_DOC    > '" + SPACE(LEN(DF1->DF1_DOC)) + "' "
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " ORDER BY DUA_FILIAL,DUA_FILDOC,DUA_DOC,DUA_SERIE,DUA_FILORI,DUA_VIAGEM"
				ElseIf aRotinas[nCntFor2,1] == "DTW"
					cQuery := "SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDUD + " DUD "
					cQuery += "    ON DUD_FILIAL = '" + xFilial("DUD") + "' "
					cQuery += "   AND DUD_FILDOC = DF1.DF1_FILDOC "
					cQuery += "   AND DUD_DOC    = DF1.DF1_DOC "
					cQuery += "   AND DUD_SERIE  = 'COL' "
					cQuery += "   AND DUD_VIAGEM <> '" + Space(Len(DUD->DUD_VIAGEM)) + "' "
					cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDTW + " DTW "
					cQuery += "    ON DTW_FILIAL = '" + xFilial("DTW") + "' "
					cQuery += "   AND DTW_FILORI = DUD_FILORI "
					cQuery += "   AND DTW_VIAGEM = DUD_VIAGEM "
					cQuery += "   AND DTW.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += "  AND DF1.DF1_DOC    > '" + SPACE(LEN(DF1->DF1_DOC)) + "' "
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " UNION "
					cQuery += "SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDTC + " DTC "
					cQuery += "    ON DTC.DTC_FILIAL = '" + xFilial("DTC") + "' "
					cQuery += "   AND DTC.DTC_NUMSOL = DF1.DF1_DOC "
					cQuery += "   AND DTC.DTC_FILCFS = DF1.DF1_FILDOC "
					cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDT6 + " DT6 "
					cQuery += "    ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
					cQuery += "   AND DT6.DT6_FILDOC = DTC.DTC_FILDOC "
					cQuery += "   AND DT6.DT6_DOC    = DTC.DTC_DOC "
					cQuery += "   AND DT6.DT6_SERIE  = DTC.DTC_SERIE "
					cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDUD + " DUD "
					cQuery += "    ON DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
					cQuery += "   AND DUD.DUD_FILDOC = DT6.DT6_FILDOC "
					cQuery += "   AND DUD.DUD_DOC    = DT6.DT6_DOC "
					cQuery += "   AND DUD.DUD_SERIE  = DT6.DT6_SERIE "
					cQuery += "   AND DUD.DUD_VIAGEM <> '" + Space(Len(DUD->DUD_VIAGEM)) + "' "
					cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDTW + " DTW "
					cQuery += "    ON DTW.DTW_FILIAL = '" + xFilial("DTW") + "' "
					cQuery += "   AND DTW.DTW_FILORI = DUD.DUD_FILORI "
					cQuery += "   AND DTW.DTW_VIAGEM = DUD.DUD_VIAGEM "
					cQuery += "   AND DTW.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += "  AND DF1.DF1_DOC    > '" + SPACE(LEN(DF1->DF1_DOC)) + "' "
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " ORDER BY 17, 2, 3, 4 " //DTW.DTW_FILIAL / DTW.DTW_FILORI / DTW.DTW_VIAGEM / DTW.DTW_SEQUEN
				ElseIf aRotinas[nCntFor2,1] == "DE5"
					cQuery := "SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDTC + " DTC "
					cQuery += "    ON DTC.DTC_FILIAL = '" + xFilial("DTC") + "' "
					cQuery += "   AND DTC.DTC_NUMSOL = DF1.DF1_DOC "
					cQuery += "   AND DTC.DTC_FILCFS = DF1.DF1_FILDOC "
					cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cSA1 + " SA1REM "
					cQuery += "    ON SA1REM.A1_FILIAL = '" + xFilial("SA1") + "' "
					cQuery += "   AND SA1REM.A1_COD    = DTC.DTC_CLIREM "
					cQuery += "   AND SA1REM.A1_LOJA   = DTC.DTC_LOJREM "
					cQuery += "   AND SA1REM.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDE5 + " DE5 "
					cQuery += "    ON DE5.DE5_FILIAL = '" + xFilial("DE5") + "' "
					cQuery += "   AND DE5.DE5_CGCREM = SA1REM.A1_CGC "
					cQuery += "   AND DE5.DE5_DOC    = DTC.DTC_NUMNFC "
					cQuery += "   AND DE5.DE5_SERIE  = DTC.DTC_SERNFC "
					cQuery += "   AND DE5.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += "  AND DF1.DF1_DOC    > '" + SPACE(LEN(DF1->DF1_DOC)) + "' "
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " ORDER BY DE5.DE5_FILIAL,DE5.DE5_CGCREM,DE5.DE5_DOC,DE5.DE5_SERIE"
				ElseIf aRotinas[nCntFor2,1] == "DU1" //-- Lote de Comprovantes de Entrega
					cQuery := "SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDTC + " DTC "
					cQuery += "    ON DTC_FILIAL = '" + xFilial("DTC") + "' "
					cQuery += "   AND DTC_NUMSOL = DF1.DF1_DOC "
					cQuery += "   AND DTC_FILCFS = DF1.DF1_FILDOC "
					cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDT6 + " DT6 "
					cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
					cQuery += "   AND DT6_FILDOC = DTC_FILDOC "
					cQuery += "   AND DT6_DOC    = DTC_DOC "
					cQuery += "   AND DT6_SERIE  = DTC_SERIE "
					cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDU1 + " DU1 "
					cQuery += "   ON DU1_FILDOC = DT6_FILDOC "
					cQuery += "   AND DU1_DOC    = DT6_DOC "
					cQuery += "   AND DU1_SERIE  = DT6_SERIE "
					cQuery += "   AND DU1.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += "  AND DF1.DF1_DOC    > '" + SPACE(LEN(DF1->DF1_DOC)) + "' "
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " ORDER BY DU1_FILIAL,DU1_FILDOC,DU1_DOC,DU1_SERIE"
				ElseIf aRotinas[nCntFor2,1] == "DDD" //--MRP - Agendamento
					cQuery := "SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += "	INNER JOIN " + cDF0 + " DF0 "
					cQuery += "	   ON DF0_FILIAL = '" + FwxFilial("DF0") + "' "
					cQuery += "   AND DF0_NUMAGE = DF1.DF1_NUMAGE"
					cQuery += "   AND DF0.D_E_L_E_T_ = ' ' "				
					cQuery += "	INNER JOIN " + cDDD + " DDD "
					cQuery += "	   ON DDD_FILIAL = '" + FwxFilial("DDD") + "' "
					cQuery += "   AND DDD_NUMMRP = DF0.DF0_NUMMRP"
					cQuery += "   AND DDD.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "   ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "   AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "								
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
				 	cQuery += "	ORDER BY DDD_DATAGE, DDD_HORAGE"					
				ElseIf aRotinas[nCntFor2,1] == "SE1"
					cQuery := "SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDTC + " DTC "
					cQuery += "    ON DTC_FILIAL = '" + xFilial("DTC") + "' "
					cQuery += "   AND DTC_NUMSOL = DF1.DF1_DOC "
					cQuery += "   AND DTC_FILCFS = DF1.DF1_FILDOC "
					cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDT6 + " DT6 "
					cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
					cQuery += "   AND DT6_FILDOC = DTC_FILDOC "
					cQuery += "   AND DT6_DOC    = DTC_DOC "
					cQuery += "   AND DT6_SERIE  = DTC_SERIE "
					cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cSE1 + " SE1 "
					cQuery += "    ON E1_FILIAL  = '" + xFilial("SE1") + "' "
					cQuery += "   AND E1_PREFIXO = DT6_PREFIX "
					cQuery += "   AND E1_NUM     = DT6_NUM "
					cQuery += "   AND E1_TIPO    = DT6_TIPO "
					cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "
					cQuery += "  LEFT OUTER JOIN " + cSA6 + " SA6 "
					cQuery += "    ON SA6.A6_FILIAL = '" + xFilial("SA6") + "' "
					cQuery += "   AND SA6.A6_COD    = E1_PORTADO "
					cQuery += "   AND SA6.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += "  AND DF1.DF1_DOC    > '" + SPACE(LEN(DF1->DF1_DOC)) + "' "
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					
					cQuery += " UNION "
					
					cQuery += " SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDTC + " DTC "
					cQuery += "    ON DTC_FILIAL = '" + xFilial("DTC") + "' "
					cQuery += "   AND DTC_NUMSOL = DF1.DF1_DOC "
					cQuery += "   AND DTC_FILCFS = DF1.DF1_FILDOC "
					cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDT6 + " DT6 "
					cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
					cQuery += "   AND DT6_FILDCO = DTC_FILDOC AND DT6_FILDCO <> '' "
					cQuery += "   AND DT6_DOCDCO = DTC_DOC    AND DT6_DOCDCO <> '' "
					cQuery += "   AND DT6_SERDCO = DTC_SERIE  AND DT6_SERDCO <> '' "
					cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cSE1 + " SE1 "
					cQuery += "    ON E1_FILIAL  = '" + xFilial("SE1") + "' "
					cQuery += "   AND E1_PREFIXO = DT6_PREFIX "
					cQuery += "   AND E1_NUM     = DT6_NUM "
					cQuery += "   AND E1_TIPO    = DT6_TIPO "
					cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "
	
					//--Comentar quando for totalmente dicionário.
					cQuery += "  LEFT OUTER JOIN " + cSA6 + " SA6 "
					cQuery += "    ON SA6.A6_FILIAL = '" + xFilial("SA6") + "' "
					cQuery += "   AND SA6.A6_COD    = E1_PORTADO "
					cQuery += "   AND SA6.D_E_L_E_T_ = ' ' "
					//-------------------------------------------
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += "  AND DF1.DF1_DOC    > '" + SPACE(LEN(DF1->DF1_DOC)) + "' "
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " ORDER BY E1_FILIAL,E1_PREFIXO,E1_NUM,E1_TIPO"
				ElseIf aRotinas[nCntFor2,1] == "DRT"
					cQuery := "SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDTC + " DTC "
					cQuery += "    ON DTC_FILIAL = '" + xFilial("DTC") + "' "
					cQuery += "   AND DTC_NUMSOL = DF1.DF1_DOC "
					cQuery += "   AND DTC_FILCFS = DF1.DF1_FILDOC "
					cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDT6 + " DT6 "
					cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
					cQuery += "   AND DT6_FILDOC = DTC_FILDOC "
					cQuery += "   AND DT6_DOC    = DTC_DOC "
					cQuery += "   AND DT6_SERIE  = DTC_SERIE "
					cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
					cQuery += "  JOIN " + cDRT + " DRT "
					cQuery += "    ON DRT_NUM = DT6_NUM "
					cQuery += "   AND DRT.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += "  AND DF1.DF1_DOC    > '" + SPACE(LEN(DF1->DF1_DOC)) + "' "
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					
					cQuery += " UNION "
					
					cQuery += " SELECT DISTINCT " + aCampos[1]
					cQuery += "  FROM " + cDF1 + " DF1 "
					cQuery += " INNER JOIN " + cDTC + " DTC "
					cQuery += "    ON DTC_FILIAL = '" + xFilial("DTC") + "' "
					cQuery += "   AND DTC_NUMSOL = DF1.DF1_DOC "
					cQuery += "   AND DTC_FILCFS = DF1.DF1_FILDOC "
					cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDT6 + " DT6 "
					cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
					cQuery += "   AND DT6_FILDCO = DTC_FILDOC AND DT6_FILDCO <> '' "
					cQuery += "   AND DT6_DOCDCO = DTC_DOC    AND DT6_DOCDCO <> '' "
					cQuery += "   AND DT6_SERDCO = DTC_SERIE  AND DT6_SERDCO <> '' "
					cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " + cDRT + " DRT "
					cQuery += "    ON DRT_NUM = DT6_NUM "
					cQuery += "   AND DRT.D_E_L_E_T_ = ' ' "
					cQuery += " INNER JOIN " +cTableAgdT +" Agds"
					cQuery += "  ON  DF1.DF1_NUMAGE = Agds.DF1_NUMAGE "
					cQuery += "  AND DF1.DF1_ITEAGE = Agds.DF1_ITEAGE "
					cQuery += "  AND DF1.DF1_DOC    > '" + SPACE(LEN(DF1->DF1_DOC)) + "' "
					cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
					cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
					cQuery += " ORDER BY DRT_FILIAL, DRT_NUM"
				EndIf
				

				//-- Ponto de entrada para complementar a query de contratos
				If lTMF76QRY
					cCompQry := ExecBlock('TMF76QRY',.F.,.F.,{ aRotinas[nCntFor2,1],aCampos[1],cAgenda,cItens,cQuery })
					If ValType(cCompQry) == 'C'
						cQuery := cCompQry
					EndIf
				EndIf

				Aadd(aRet,{cAlias,aClone(aCampos[2]),cQuery,.T.})
			EndIf
			 
		Next nCntFor2	
	EndIf

EndIf

aKill aCampos
aKill aRetDin
aKill aVetWrk
aKill aQuery
aKill aJoin

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Mrk ³ Autor ³ Valdemar Roberto    ³ Data ³ 20/05/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca registros                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Mrk                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76Mrk(cNumAge,cIteAge,lHelp)
Local aAreas     := {DF1->(GetArea()),GetArea()}
Local aListaThr  := {}
Local cAlias     := oMarkAge:Alias()
Local lMudou     := .F.
Local nPosThr    := 0
Default cNumAge:= (cAlias)->DF1_NUMAGE
Default cIteAge:= (cAlias)->DF1_ITEAGE
Default lHelp  := .T.
DF1->(DbSetOrder(1))
If DF1->(DbSeek(xFilial("DF1") + cNumAge +cIteAge ))
	If Empty(DF1->DF1_MRKPAN)
		RecLock("DF1",.F.)
		DF1->DF1_MRKPAN := cNumThread
		DF1->(MsUnlock())
		lMudou := .T.
	Else
		If DF1->DF1_MRKPAN != cNumThread
			aListaThr := GetUserInfoArray()
			If (nPosThr := Ascan(aListaThr,{|x| StrZero(x[3],20) == DF1->DF1_MRKPAN})) == 0
				TMSF76Lim(DF1->DF1_MRKPAN)
				RecLock("DF1",.F.)
				DF1->DF1_MRKPAN := cNumThread
				DF1->(MsUnlock())
				lMudou := .T.
			Else
				If lHelp
					Aviso(STR0057,STR0073 +cNumAge+"/"+cIteAge +STR0074 + chr(13)+chr(10) + Iif(nPosThr > 0,aListaThr[nPosThr,1],""), {STR0056}) //"Atenção !"###"Agendamento "###" já está sendo utilizado por outro usuário."###"Ok"
				EndIf
			EndIf
		Else
			RecLock("DF1",.F.)
			DF1->DF1_MRKPAN := Space(Len(DF1->DF1_MRKPAN))
			DF1->(MsUnlock())
			lMudou := .T.
		EndIf
	EndIf
EndIf

If lMudou
	If RecLock(oMarkAge:cAlias,.F.)
		(cAlias)->DF1_MRKPAN := DF1->DF1_MRKPAN
		(cAlias)->(MsUnlock())
	Endif
EndIf

AEval(aAreas,{|x,y| RestArea(x) })
aKill aAreas

Return lMudou

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Cp1 ³ Autor ³ Valdemar Roberto    ³ Data ³ 20/05/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Define campos                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Cp1                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76Cp1(nAcao,cAlias)
Local aRet      := {}
Local aRetUsr   := {}
Local aCposWrk  := {}
Local cCpoStatus:= ''
Local aCampos   := {}
Local nCont     := 0
Local aCposAux  := {}
Local cCampo    := ""

DEFAULT nAcao  := 0
DEFAULT cAlias := ""

cCpoStatus := IIF(cAlias!="SE1",cAlias+"_STATUS","E1_SITFAT")

aCposAux := ApBuildHeader(cAlias)
aEval(aCposAux,{|aLinHead,nY| Iif(nAcao == 1 .Or. GetSx3Cache(aLinHead[2],"X3_BROWSE") == "S" .Or. ;
									(cAlias == "DDD" .And. AllTrim(aLinHead[2]) $ "DDD_DATAGE,DDD_HORAGE") .Or.;
									AllTrim(aLinHead[2]) $ cCpoStatus,;
								aAdd(aCampos,aClone(aCposAux[nY])),;
								NIL)})

aSize(aCposAux,0)


cCampo := IIf(Substr(cAlias, 1, 1) == "S", Substr(cAlias, 2, 2) + "_FILIAL", cAlias +  "_FILIAL")
If Ascan( aCampos, { |x| AllTrim(x[ 2 ]) == cCampo } ) == 0 
	aAdd(aCampos, { "Filial", cCampo, "C", TamSX3(cCampo)[1], TamSX3(cCampo)[2], "@!", "", "", "", ""  } )
EndIf

If nAcao == 1
	If cAlias == "DF1"
		For nCont := 1 to Len(aCampos)	
			If "_FILIAL" $ aCampos[nCont][2] .OR. (aCampos[nCont][10] != 'V' .And. AllTrim(aCampos[nCont][2]) != 'DF1_VLRINF' .And. aCampos[nCont][8] != 'M')
				Aadd(aCposWrk,{aCampos[nCont][2],aCampos[nCont][2],aCampos[nCont][2],.F.})
			EndIf
		Next nCont
	EndIf	
	
	AADD(aCposWrk,{"R_E_C_N_O_","DF1.R_E_C_N_O_","REGIST",.F.})
					 
	If lTMF76Cps
		aRetUsr := ExecBlock("TMF76Cps",.F.,.F.,{nAcao,cAlias,Aclone(aCposWrk)})
		If ValType(aRetUsr) == "A"
			aCposWrk := Aclone(aRetUsr)
		Endif
	Endif

	aRet := TMSF76Cp2(aCposWrk, cAlias, aCampos)
ElseIf nAcao == 2
	
	////////////////////////////////////////////////
	// Montagem das colunas de LEGENDA e STATUS	 //
	////////////////////////////////////////////////
	If cALias $ ("DTQ:DF0:DT5:DTC:DTP:DTX:DTY:DT6:DTW:SE1:DRT:DDD:DF8")
		AADD(aCposWrk,{"LEGENDA",cCpoStatus,cCpoStatus,.F.})
		AADD(aCposWrk,{cCpoStatus,cCpoStatus,cCpoStatus,.F.})
	EndIf	
	
	/////////////////////////////////////////////////////////////////////
	// Montagem dos campos do SX3, retirando o Staus e campos Memos	 //
	/////////////////////////////////////////////////////////////////////
	For nCont := 1 to Len(aCampos)
		If "_FILIAL" $ aCampos[nCont][2] .OR. (aCampos[nCont][10] != 'V' .And. AllTrim(aCampos[nCont][2]) != 'E1_SALDO' .And. AllTrim(aCampos[nCont][2]) != cCpoStatus )
			Aadd(aCposWrk,{aCampos[nCont][2],aCampos[nCont][2],aCampos[nCont][2],.F.})
		EndIf
	Next nCont
			
	/////////////////////////////////////////////////////////////////////
	//Inclusão dos RECNO's para cada folder.				               //
	/////////////////////////////////////////////////////////////////////
	cRecno := cAlias+".R_E_C_N_O_"
	AADD(aCposWrk,{"R_E_C_N_O_",cRecno,"REGIST",.F.})
	
	/////////////////////////////////////////////////////////////////////
	//Ponto de Entrada para retirar colunas dos Folders                //
	/////////////////////////////////////////////////////////////////////
	If lTMF76Cps
		aRetUsr := ExecBlock("TMF76Cps",.F.,.F.,{nAcao,cAlias,Aclone(aCposWrk)})
		If ValType(aRetUsr) == "A"
			aCposWrk := Aclone(aRetUsr)
		Endif
	Endif

	/////////////////////////////////////////////////////////////////////
	//Montagem da estrutura do campos de acordo com SX3.	               //
	/////////////////////////////////////////////////////////////////////
	If !Empty(aCposWrk)
		aRet := TMSF76Cp2(aCposWrk, cAlias, aCampos)
	EndIf

EndIf

aKill aCposWrk
aKill aRetUsr
aKill aCampos

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Cp2 ³ Autor ³ Valdemar Roberto    ³ Data ³ 20/05/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Define campos                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Cp2                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76Cp2(aCposWrk, cAlias, aCampos)
Local nCntFor1 := 0
Local nCntFor2 := 0
Local aRet     := {"",{}}
Local aLista1  := {}
Local aLista2  := {}
Local nPos     := 0
Local cCampo   := ""

Default cAlias  := ""
Default aCampos := {}

If !Empty(cAlias) .And. Empty(aCampos)
	aCampos := apBuildHeader(cAlias)
EndIf

cCampo := IIf(Substr(cAlias, 1, 1) == "S", Substr(cAlias, 2, 2) + "_FILIAL", cAlias +  "_FILIAL")
If Ascan( aCampos, { |x| AllTrim(x[ 2 ]) == AllTrim(cCampo) } ) == 0 
	aAdd(aCampos, { "FILIAL", cCampo, "C", TamSX3(cCampo)[1], TamSX3(cCampo)[2], "@!", "", "", "", ""  } )
EndIf

For nCntFor1 := 1 To Len(aCposWrk)
	If (nPos := aScan(aCampos, {|x| AllTrim(x[2]) == AllTrim(aCposWrk[nCntFor1,1])})) > 0 .Or. AllTrim(aCposWrk[nCntFor1,1]) == "LEGENDA"
		If nPos > 0 .And. aCampos[nPos, 8] == "M"
			Loop
		EndIf
		If AllTrim(aCposWrk[nCntFor1,1]) $ "DTQ_SERTMS:DE5_TIPTRA:DF8_SERTMS:DF8_TIPTRA:DTQ_SERADI"
			aLista1 := TmsValField(aCposWrk[nCntFor1,1],.F.,,.F.,.T.)
			aLista2 := {}
			For nCntFor2 := 1 To Len(aLista1)
				Aadd(aLista2,aLista1[nCntfor2,1] + "=" + aLista1[nCntfor2,2])
			Next nCntFor2
			Aadd(aRet[2],{aCposWrk[nCntFor1,3], RetTitle(aCampos[nPos, 2]), aCampos[nPos, 8], 30, aCampos[nPos, 5], aCampos[nPos, 3], aLista2, aCposWrk[nCntFor1,4], GetSX3Cache(aCampos[nPos, 2], "X3_CONTEXT"), GetSX3Cache(aCampos[nPos, 2], "X3_INIBRW") })
		ElseIf AllTrim(aCposWrk[nCntFor1,1]) == "R_E_C_N_O_"
			Aadd(aRet[2],{aCposWrk[nCntFor1,3],"Registro","N",10,0,"@E 9999999999",{}})  
		ElseIf AllTrim(aCposWrk[nCntFor1,1]) == "LEGENDA"
			Aadd(aRet[2],{aCposWrk[nCntFor1,3],"LEGENDA"				  ,'O'			 ,aCampos[nCntFor1, 4], aCampos[nCntFor1, 5], aCampos[nCntFor1, 3], Sx3Box2Arr(aCampos[nCntFor1, 2]),aCposWrk[nCntFor1,4], GetSX3Cache(aCampos[nCntFor1, 2], "X3_CONTEXT"), GetSX3Cache(aCampos[nCntFor1, 2], "X3_INIBRW") })
		Else
			Aadd(aRet[2],{aCposWrk[nCntFor1,3],RetTitle(aCampos[nPos, 2]), aCampos[nPos, 8],  aCampos[nPos, 4], aCampos[nPos, 5], aCampos[nPos, 3], Sx3Box2Arr(aCampos[nPos, 2]), aCposWrk[nCntFor1,4], GetSX3Cache(aCampos[nPos, 2], "X3_CONTEXT"), GetSX3Cache(aCampos[nPos, 2], "X3_INIBRW") })
		EndIf
		If nPos > 0 .And. aCampos[nPos, 10] != 'V' .And. AllTrim(aCposWrk[nCntFor1,1]) != "LEGENDA"
			aRet[1] += aCposWrk[nCntFor1,2] + " " + aCposWrk[nCntFor1,3] + ","
		EndIf
	EndIf
Next nCntFor1

Aadd(aRet[2],{aCposWrk[len(aCposWrk),3],STR0075,"N",10,0,"@E 9999999999",{},aCposWrk[len(aCposWrk),4],'R',""}) //"Registro"

aRet[1] += aCposWrk[len(aCposWrk),2] + " " + aCposWrk[len(aCposWrk),3] + ","
aRet[1] := Left(aRet[1],Len(aRet[1]) - 1)

aKill aLista1
aKill aLista2

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ	ÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76DUD³ Autor ³ Valdemar Roberto      ³ Data ³ 18/09/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pesquisa DUD                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76DUD                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76DUD(cFilDoc,cDoc,cSerie,cTipTra,cSerTMS,nRegDUD,cFilOri,cViagem)
Local lRet      := .T.
Local aAreas    := {GetArea()}
Local cQuery    := ""
Local cAliasDUD := ""

DEFAULT cFilDoc := ""
DEFAULT cDoc    := ""
DEFAULT cSerie  := ""
DEFAULT cTipTra := ""
DEFAULT cSerTMS := ""
DEFAULT cFilOri := ""
DEFAULT cViagem := ""

cAliasDUD := GetNextAlias()
cQuery := "SELECT DUD.R_E_C_N_O_ REGDUD "
cQuery += "  FROM " + cDUD + " DUD "
cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery += "   AND DUD_FILDOC = '" + cFilDoc + "' "
cQuery += "   AND DUD_DOC    = '" + cDoc + "' "
cQuery += "   AND DUD_SERIE  = '" + cSerie + "' "
cQuery += "   AND DUD_TIPTRA = '" + cTipTra + "' "
cQuery += "   AND DUD_SERTMS = '" + cSerTMS + "' "
cQuery += "   AND ( (DUD_VIAGEM = '" + Space(Len(DUD->DUD_VIAGEM)) + "' "
cQuery += "   AND DUD_STATUS = '" + StrZero(1,Len(DUD->DUD_STATUS)) + "' ) "
If !Empty(cFilOri) .And. !Empty(cViagem)
	cQuery += "   OR (DUD_FILORI = '" + cFilOri + "' "
	cQuery += "   AND DUD_VIAGEM = '" + cViagem + "') "
EndIf
cQuery += " ) " 	
cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUD,.T.,.T.)
If (cAliasDUD)->(Eof()) .Or. Empty((cAliasDUD)->REGDUD)
	lRet := .F.
Else
	nRegDUD := (cAliasDUD)->REGDUD
EndIf
(cAliasDUD)->(DbCloseArea())

AEval(aAreas,{|x,y| RestArea(x) })
aKill aAreas

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Cri ³ Autor ³ Valdemar Roberto    ³ Data ³ 05/09/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica criterios de rateio                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Cri                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76Cri(cNContr,cCodNeg,cServic,aVetEnt,lHelp,nAcao,cDocTMS)
Local aAreas  := {DDA->(GetArea()),DDC->(GetArea()),GetArea()}
Local aVetSai := {}

DEFAULT cNContr := ""
DEFAULT cCodNeg := ""
DEFAULT cServic := ""
DEFAULT aVetEnt := {}
DEFAULT lHelp   := .T.
DEFAULT nAcao   := 0
DEFAULT cDocTMS := ""

//-- nAcao = 1 chamado pela rotina que monta aCols. nAcao = 2 chamado pela rotina de validacao TudoOk
DDA->(DbSetOrder(2))
DDC->(DbSetOrder(1))

If !Empty(cServic) .And. !DDA->(DbSeek(xFilial("DDA") + cNContr + cCodNeg + cServic))
	If lHelp
		Aviso(STR0057,STR0076,{STR0056}) //"Atenção" ### "Problemas com a localização do serviço de negociação do cliente." ###"Ok"
	EndIf
Else
	If !Empty(cServic) .And. !Empty(DDA->DDA_RATEIO)
		If (nAcao == 1 .And. Ascan(aVetEnt,{|x| x[1] + x[2] + x[3] + x[4] + x[5] + x[6] + x[7] + x[8] == cNContr + DDA->(DDA_TABFRE + DDA_TIPTAB + DDA_RATEIO + DDA_CRIRAT + DDA_SUBCRI + DDA_KMESP + cDocTMS)}) == 0) .Or. ;
		   (nAcao == 2 .And. Ascan(aVetEnt,{|x| x[2] + x[3] + x[4] + x[5] + x[6] + x[7] + x[8] == DDA->(DDA_TABFRE + DDA_TIPTAB + DDA_RATEIO + DDA_CRIRAT + DDA_SUBCRI + DDA_KMESP + cDocTMS)}) == 0)
			Aadd(aVetSai,cNContr)
			Aadd(aVetSai,DDA->DDA_TABFRE)
			Aadd(aVetSai,DDA->DDA_TIPTAB)
			Aadd(aVetSai,DDA->DDA_RATEIO)
			Aadd(aVetSai,DDA->DDA_CRIRAT)
			Aadd(aVetSai,DDA->DDA_SUBCRI)
			Aadd(aVetSai,DDA->DDA_KMESP)
			Aadd(aVetSai,cDocTMS)
		EndIf
	Else
		If !DDC->(DbSeek(xFilial("DDC") + cNContr + cCodNeg))
			If lHelp
				Aviso(STR0057,STR0077,{STR0056}) //"Atenção"### "Problemas com a localização da negociação do cliente." ###"Ok"
			EndIf
		Else
			If (nAcao == 1 .And. Ascan(aVetEnt,{|x| x[1] + x[2] + x[3] + x[7] + x[4] + x[5] + x[6] + x[8] == cNContr + Iif(!Empty(cServic),DDA->(DDA_TABFRE + DDA_TIPTAB   + DDA_KMESP),Space(Len(DDA->DDA_TABFRE) + Len(DDA->DDA_TIPTAB)+ Len(DDA->DDA_KMESP))) + DDC->(DDC_RATEIO + DDC_CRIRAT + DDC_SUBCRI + cDocTMS)}) == 0) .Or. ;
			   (nAcao == 2 .And. Ascan(aVetEnt,{|x| x[2] + x[3] + x[7] + x[4] + x[5] + x[6] + x[8] == Iif(!Empty(cServic),DDA->(DDA_TABFRE + DDA_TIPTAB + DDA_KMESP), 	Space(Len(DDA->DDA_TABFRE) + Len(DDA->DDA_TIPTAB) + Len(DDA->DDA_KMESP))) + DDC->(DDC_RATEIO + DDC_CRIRAT + DDC_SUBCRI + cDocTMS)}) == 0)
				Aadd(aVetSai,cNContr)
				Aadd(aVetSai,Iif(!Empty(cServic),DDA->DDA_TABFRE,Space(Len(DDA->DDA_TABFRE))))
				Aadd(aVetSai,Iif(!Empty(cServic),DDA->DDA_TIPTAB,Space(Len(DDA->DDA_TIPTAB))))
				Aadd(aVetSai,DDC->DDC_RATEIO)
				Aadd(aVetSai,DDC->DDC_CRIRAT)
				Aadd(aVetSai,DDC->DDC_SUBCRI)
				Aadd(aVetSai,Iif(!Empty(cServic),DDA->DDA_KMESP,Space(Len(DDA->DDA_KMESP))))
				Aadd(aVetSai,cDocTMS)
			EndIf
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x) })
aKill aAreas

Return aVetSai

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Gat ³ Autor ³ Valdemar Roberto    ³ Data ³ 09/09/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna campos em gatilho                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Gat(nExp01)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 - Campo a ser retornado                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76Gat(nCpoRet)
Local aAreas := {DDA->(GetArea()),DDC->(GetArea()),GetArea()}
Local cRet   := ""

DEFAULT nCpoRet := 0

If !Empty(GdFieldGet("DF1_CODNEG",n)) .And. !Empty(GdFieldGet("DF1_SERVIC",n))
	DDC->(DbSetOrder(1))
	DDA->(DbSetOrder(2))
	DDC->(MsSeek(xFilial("DDC") + GdFieldGet("DF1_NCONTR",n) + GdFieldGet("DF1_CODNEG",n)))
	DDA->(MsSeek(xFilial("DDA") + GdFieldGet("DF1_NCONTR",n) + GdFieldGet("DF1_CODNEG",n) + GdFieldGet("DF1_SERVIC",n)))
	If nCpoRet == 1  //-- TabFre
		cRet := DDA->DDA_TABFRE
	ElseIf nCpoRet == 2 //-- TipTab
		cRet := DDA->DDA_TIPTAB
	ElseIf nCpoRet == 3 //-- Rateio
		cRet := Iif (!Empty(DDA->DDA_RATEIO),DDA->DDA_RATEIO,DDC->DDC_RATEIO)
	ElseIf nCpoRet == 4 //-- CriRat
		cRet := Iif (!Empty(DDA->DDA_RATEIO),DDA->DDA_CRIRAT,DDC->DDC_CRIRAT)
	ElseIf nCpoRet == 5 //-- SubCri
		cRet := Iif (!Empty(DDA->DDA_RATEIO),DDA->DDA_SUBCRI,DDC->DDC_SUBCRI)
	ElseIf nCpoRet == 6 //-- TipoKM
		cRet := DDA->DDA_KMESP
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x) })
aKill aAreas

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef76()
Local nCntFor1 := 0
Local aRotinas := {}
Local aRot     := {}
Local aRet     := {}
Local cTmsERP  := SuperGetMV("MV_TMSERP",,'0') //-- Integracao com ERP
Local cRotFat  := Iif(cTmsERP == '1', "TMSA851", "TMSA850")
Local cTabFat  := Iif(cTmsERP == '1', "DRT", "SE1")

Local aFontes  := {	{STR0104,"TMSAF60" ,"MENUDEF" ,.T.,"DTQ"  ,.F.},; //"Viag Mod 3"
					{STR0078,"TMSA144B","MENUDEF" ,.T.,"DTQ"  ,.F.},; //"Viagem"
					{STR0079,"TMSA146" ,"MENUDEF" ,.T.,"DF8"  ,.F.},; //"Prog Carreg"
					{STR0059,"TMSAF05" ,"MENUDEF" ,.T.,"DF0"  ,.F.},; //"Agendamento"
					{STR0060,"TMSA460" ,"MENUDEF" ,.T.,"DT5"  ,.F.},; //"Coletas"
					{STR0080,"TMSA050" ,"MENUDEF" ,.T.,"DTC"  ,.F.},; //"Nfs Cliente"
					{STR0061,"TMSA200" ,"MENUDEF" ,.T.,"DTP"  ,.F.},; //"Cálculo"
					{STR0081,"TMSA190" ,"MENUDEF" ,.T.,"DTX"  ,.F.},; //"Romaneio"
					{STR0062,"TMSA250" ,"MENUDEF" ,.T.,"DTY"  ,.F.},; //"Carta Frete"
					{STR0063,"TMSA500" ,"MENUDEF" ,.T.,"DT6"  ,.F.},; //"Doc Transp"
					{STR0064,"TMSA360" ,"MENUDEF" ,.T.,"DUA"  ,.F.},; //"Ocorrências"
					{STR0070,"TMSA350" ,"MenuD350",.F.,"DTW"  ,.F.},; //"Operações"
					{STR0082,"TMSA570" ,"MENUDEF" ,.T.,"DU1"  ,.F.},; //"Cmp Entrega"
					{STR0083,"TMSAE55" ,"MENUDEF" ,.T.,"DE5"  ,.F.},; //"EDI"
					{STR0084,"TMSA019A","MENUDEF" ,.T.,"DDD"  ,.F.},; //"MRP"
					{STR0065, cRotFat  ,"MENUDEF" ,.T.,cTabFat,.F.}}  //"Faturas"

Local lComprEnt := DT2->(ColumnPos("DT2_CMPENT")) > 0 .And. TableInDic("DLY") .And. ExistFunc('TMSIncDLY')
Local lDM3      := AliasIndic('DM3') .And. FindFunction(aFontes[1,2]) 
				   
If lTMF76ADD
	aRet := ExecBlock("TMF76ADD",.F.,.F.,{1})
	If ValType(aRet) == "A"
		For nCntFor1 := 1 To Len(aRet)
			Aadd(aFontes,{})
			Ains(aFontes,aRet[nCntFor1,1])
			aFontes[aRet[nCntFor1,1]]   := aRet[nCntFor1,2]
			aFontes[aRet[nCntFor1,1],6] := .T.
		Next nCntFor1
	EndIf
EndIf

For nCntFor1 := 1 To Len(aFontes)		
	If aFontes[nCntFor1,2] $ "TMSAF60" .And. !lDM3
		Loop
	EndIf
	
	If IsAutUsr(1,aFontes[nCntFor1,2])
		If aFontes[nCntFor1,4]
			aRot := &("STATICCALL(" + aFontes[nCntFor1,2] + "," + aFontes[nCntFor1,3] + ")")
		Else
			aRot := &(aFontes[nCntFor1,3] + "()")
		EndIf

		If lComprEnt .And. aFontes[nCntFor1,2] == "TMSA360"
			Aadd(aRot,{STR0102,"TMSF76Moni(1,4)",0,4,0,Nil})	//-- "Monitor"
			Aadd(aRot,{STR0103,"TMSF76Moni(2,4)",0,4,0,Nil})	//-- "Altera"
		EndIf

		If !Empty(aRot) .and. Len(aRot) > 0
				
			// Ajusta o menu para rotinas MVC
			AF76RotMvc(aRot,aFontes[nCntFor1,2])

			If TmsExp() .And. AllTrim(aFontes[nCntFor1,2]) == "TMSAF60"
				Aadd(aRot,{STR0106,"TMSAF64NFC()",0,3,0,Nil,Nil,Nil})
			EndIf
		
			Aadd(aRotinas,{aFontes[nCntFor1,5],aFontes[nCntFor1,1],Aclone(aRot),aFontes[nCntFor1,2],aFontes[nCntFor1,6]})
			Aadd(aPaineis,{,,Array(Len(aRot)),.F.})
		EndIF
	Endif
Next nCntFor1

aKill aRot
aKill aRet
aKill aFontes

Return aRotinas

//-- Mapa do Vetor aFontes
//-- 01 - Titulo do Folder
//-- 02 - Nome do Fonte
//-- 03 - Nome da Rotina Dentro do Fonte
//-- 04 - Indica se a Rotina é Estatica ou não
//-- 05 - Alias do Browse Original
//-- 06 - Indica se a Rotina foi Inserida por Usuário

//-- Mapa do Vetor aRotinas
//-- 01 - Alias do Filtro do Browse
//-- 02 - Titulo do Folder
//-- 03 - Vetor aRotina do Fonte
//-- 04 - Nome do Fonte do Folder
//-- 05 - Indica se a Rotina foi Inserida por Usuário

//-- Mapa do Vetor aPaineis
//-- 01 - Objeto do Painel de cada Folder
//-- 02 - Objeto Browse do Painel de cada Folder
//-- 03 - Vetor com os Objetos dos Botoes de cada Folder de cada Painel
//-- 04 - Indica se browse está ativo ou não
//--------------------------------------------------------------------------

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³IsAutUsr  ³ Autor ³ Izac S. Ciszevski     ³ Data ³01/09/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o usuário tem permissão para acesssar rotina   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³1. nMode   - 1- Aba - 2- botão                              ³±±
±±³          ³2. cRotina - Nome da Rotina a ser localizada. nMode:=1      ³±±
±±³          ³3. nFolder - Número do folder. nMode:=2                     ³±±
±±³          ³4. nBotao  - Número do botão.  nMode:=2                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IsAutUsr(nMode,cRotina, nFolder, nBotao)
Local lRet:=.F.
Local cAccess :=''
Local cMessage:=''
/*
    Parametro 1= cFunction - caracter
    Parametro 2= nOpc - numerico
    Parametro 3= lDisplayMsg - logico
    Parametro 4= cAccess  - caracter
    Parametro 5= cMessage - caracter
    Parametro 6= cUserId  - caracter
    Parametro 7= lRotina  - logico
    Parametro 8= aRotina  - array
    Parametro 9= nFuncPos - numerico
*/

If nMode == 1
	If FwChkFuncAccess(cRotina,,.F.)
		lRet:=.T.
	EndIf
Else
	If FwChkFuncAccess(aRotinas[nFolder][4],,.F.,@cAccess,cMessage,__cUserId,.T.,aRotinas[nFolder,3],nBotao)
		lRet:=.T.
	EndIf
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FindInMenu³ Autor ³ Izac S. Ciszevski     ³ Data ³01/09/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Localiza determinada função num array de menu              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³1. aMenu - Array de menu recebido da função fwfgetmnuacces  ³±±
±±³          ³2. cFunc - nome da rotina                                   ³±±
±±³          ³3. aRet  - array onde estará contido a rotina               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FindInMenu( aMenu, cFunc, aRet)
Local lRet	:=.F.
Local nX	:=0

If Len(aMenu)==4 .and. ValType(aMenu[2])== "C" .and. cFunc$aMenu[2]
	aRet:= aClone(aMenu)
	lRet:=.T.
Else
	For nX:=1 to Len(aMenu)
		If ValType(aMenu[nX])== "A"
			If FindInMenu(aMenu[nX],cFunc,@aRet)
				lRet:=.T.
				Exit
			EndIf
		EndIf
	next
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Fldr³ Autor ³ Izac S. Ciszevski   ³ Data ³ 24/09/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o Folder ativo                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Fldr()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76Fldr()
	
	CursorWait()
	If !aPaineis[nFldr,4]// se não está ativo, ative		
			
		TMSF76Age(.F.,.F.,,,,,,.T.)
		aPaineis[nFldr,4]:=.T.    //indica se já foi ativado		
		aBrowseOpe[nFldr,4]:= .F. //indica se já foi atualizado.
		cNomeCampo := aBrowseOpe[nFldr][2][1][1]
		
		aPaineis[nFldr,2]:SetAlias(aBrowseOpe[nFldr,1])		

		nIni := seconds()
		aPaineis[nFldr,2]:SetQuery(aBrowseOpe[nFldr,3])
		aPaineis[nFldr,2]:Activate()

	ElseIf aBrowseOpe[nFldr,4]		
		TMSF76Age(.F.,.F.,,,,,,.T.)
		cNomeCampo := aBrowseOpe[nFldr][2][1][1]
		aBrowseOpe[nFldr,4]:= .F.	
		Tmsaf76Rfs(aPaineis[nFldr,2],aBrowseOpe[nFldr,1],aBrowseOpe[nFldr,3])	
	Else
		cNomeCampo := aBrowseOpe[nFldr][2][1][1]
		TMSF76Age(.T.,.F.)
		//aBrowseOpe[nFldr][4] := .T.
	EndIf
	CursorArrow()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76F12 ³ Autor ³Alfredo A. Magalhães ³ Data ³ 08/11/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa o F12 de acordo com a aba selecionada              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76F12()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76F12()

	Local nPos		:= 0

	//-- Declara as variaveis utilizadas pela rotina de carta frete
	If Type("lF12") == "U"
		Private lF12
	EndIf
	If Type("lExibeLanc") == "U"
		Private lExibeLanc
	EndIf
	If Type("lOnline") == "U"
		Private lOnline
	EndIf

	If Type("oFolderOpe") == "O"
		//-- Busca a aba posicionada no vetor de opçoes
		If ( nPos := aScan(aSetKeyF12 , {|x| x[1] == oFolderOpe:aPrompts[ oFolderOpe:nOption ]} ) ) > 0
			Eval(aSetKeyF12[nPos,2])
		EndIf
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Joi ³ Autor ³ Valdemar Roberto    ³ Data ³ 09/01/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna join da query dos agendamentos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Joi(aExp01,cExp01,nExp01)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 - Vetor com os filtros                              ³±±
±±³          ³ cExp01 - Conteudo da clausula Join                         ³±±
±±³          ³ nExp01 - Linha atual                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76Joi(aVetWrk,aJoin,nLinha,cWhere)
Local nPos    := 0
Local nLinSup := 0
Local cRetDel := ""
Local cAlias  := ""
Local cRet    := ""
Local cJoin   := ""

DEFAULT aVetWrk  := ""

If (nLinSup := Ascan(aVetWrk,{|x| x[1] == aVetWrk[nLinha,4]})) > 0 .And. !aVetWrk[nLinSup,5]
	TMSF76Joi(aVetWrk,aJoin,nLinSup,@cWhere)
EndIf

cAlias  := aVetWrk[nLinha,1]

If !cAlias $ "DF0:DF1:SA1"
//	cRet    += " JOIN " + RetSqlName(cAlias) + " " + aAliasFil[nLinha,2] + " "
	cRet    += " JOIN " + &('c'+cAlias) + " " + aAliasFil[nLinha,2] + " "
	cRet    += " ON " + aAliasFil[nLinha,2] + "." + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
	cRetDel := " AND " + aAliasFil[nLinha,2] + "." + "D_E_L_E_T_ = ' ' "
Else
//-- Monta where da tabela DF0 e DF1, e SA1 para remetente, destinatario e devedor
	If cAlias == "SA1"
		aVetWrk[nLinha,3] := StrTran(aVetWrk[nLinha,3],"A1_",aAliasFil[nLinha,2] +".A1_")
	Else
		aVetWrk[nLinha,3] := StrTran(aVetWrk[nLinha,3],aVetWrk[nLinha,1] + "_",aAliasFil[nLinha,2]+"."+aVetWrk[nLinha,1] + "_")
	EndIf								   
EndIf

cWhere += If (!empty(aVetWrk[nLinha,3])," AND ("+aVetWrk[nLinha,3]+" )","")

If cAlias == "DT5"
	cRet += " AND DT5.DT5_FILORI = DF1.DF1_FILDOC "
	cRet += " AND DT5.DT5_NUMSOL = DF1.DF1_DOC "
	
ElseIf cAlias == "DTC"
	cRet += " AND DTC.DTC_NUMSOL = DT5.DT5_NUMSOL "
	cRet += " AND DTC.DTC_FILCFS = DT5.DT5_FILORI "
	
ElseIf cAlias == "DT6"
	cRet += " AND DT6.DT6_FILDOC = DTC.DTC_FILDOC "
	cRet += " AND DT6.DT6_DOC    = DTC.DTC_DOC "
	cRet += " AND DT6.DT6_SERIE  = DTC.DTC_SERIE "
	
ElseIf cAlias == "DTQ"
	cRet += " AND DTQ.DTQ_FILORI = DUD.DUD_FILORI "
	cRet += " AND DTQ.DTQ_VIAGEM = DUD.DUD_VIAGEM "
	
ElseIf cAlias == "DTR"
	cRet += " AND DTR.DTR_FILORI = DTQ.DTQ_FILORI "
	cRet += " AND DTR.DTR_VIAGEM = DTQ.DTQ_VIAGEM "
	
ElseIf cAlias == "DUP"
	cRet += " AND DUP.DUP_FILORI = DTQ.DTQ_FILORI "
	cRet += " AND DUP.DUP_VIAGEM = DTQ.DTQ_VIAGEM "
	
ElseIf cAlias == "DA3"
	cRet += "   AND DA3.DA3_COD = DTR.DTR_CODVEI "
	
ElseIf cAlias == "DA4"
	cRet += "   AND DA4.DA4_COD = DUP.DUP_CODMOT "
	
ElseIf cAlias == "DTW"
	cRet += " AND DTW.DTW_FILORI = DTQ.DTQ_FILORI "
	cRet += " AND DTW.DTW_VIAGEM = DTQ.DTQ_VIAGEM "
	
ElseIf cAlias == "DTY"
	cRet += " AND DTY.DTY_FILORI = DTQ.DTQ_FILORI "
	cRet += " AND DTY.DTY_VIAGEM = DTQ.DTQ_VIAGEM "
	
ElseIf cAlias == "DDG"
	cRet += " AND DDG.DDG_CLIREM =  DTC.DTC_CLIREM "
	cRet += " AND DDG.DDG_LOJREM =  DTC.DTC_LOJREM "
	cRet += " AND DDG.DDG_NUMNFC =  DTC.DTC_NUMNFC "
	cRet += " AND DDG.DDG_SERNFC =  DTC.DTC_SERNFC "
	cRet += " AND DDG.DDG_CODPRO =  DTC.DTC_CODPRO "
	
EndIf

cJoin := cRet + cRetDel
aVetWrk[nLinha,5] := .T.

If (nPos := aScan(aJoin,{|x|x[1]==cAlias})) > 0
	aJoin [nPos][2]:= cJoin
EndIf
Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Fim ³ Autor ³ Kaiam Guilherme       ³ Data ³ 23/04/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao de Personalizacao do Painel - Por usuario           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Fim                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76Fim()

If lTMF76Fim
	lRet := ExecBlock("TMF76Fim", .F., .F.)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Vld ³ Autor ³ Valdemar Roberto      ³ Data ³ 03/06/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Vld(nExp01,cExp01,cExp02)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 := Indica a rotina a ser validada                     ³±±
±±³          ³ cExp01 := Servico do TMS                                     ³±±
±±³          ³ cExp02 := Tipo de transporte                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76Vld(nAcao,cSerTMS,cTipTra)
Local lRet     := .T.
Local aVetWrk  := {}
Local aAreas   := {DUD->(GetArea()),GetArea()}
Local aMsgErr  := {}
Local nCntFor1 := 0

DEFAULT nAcao   := 0
DEFAULT cSerTMS := ""
DEFAULT cTipTra := ""

If nAcao == 1
	//-- Verifica se existe viagem de coleta ligada ao agendamento marcado.
	//-- Se sim, verifica se a viagem está encerrada, se não estiver não permite inclusão viagem de entrega/transferencia.
	If cSerTMS != "1"
		aVetWrk := aClone(TMSF76Age(.F.,.F.,.T.,"1",cTipTra,.T.)[3])
		For nCntFor1 := 1 To Len(aVetWrk)
			DUD->(DbGoTo(aVetWrk[nCntFor1]))
			If !(DUD->DUD_STATUS $ "4|9") .And. !Empty(DUD->DUD_VIAGEM)
				Aadd(aMsgErr,{STR0085 + DUD->DUD_FILDOC + "/" + DUD->DUD_DOC + "/" + DUD->DUD_SERIE + STR0086 + ;
					 Iif(cSerTMS == "2",STR0017,STR0018),"00",""})  // "A coleta: "### " ainda não foi encerrada. Por favor encerre-a para continuar com a inclusão da viagem de "###"Transporte"###"Entrega"
			EndIf
		Next nCntFor1
	EndIf
EndIf

If !Empty(aMsgErr)
	TmsMsgErr(aMsgErr)
	lRet := .F.
EndIf

AEval(aAreas,{|x,y| RestArea(x) })

aKill aVetWrk
aKill aAreas
aKill aMsgErr

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tmsaf76Rfs ³ Autor ³ Izac Silverio        ³ Data ³ 03/06/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsaf76Rfs()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSAF76Rfs(oBrowse,cAlias,cQuery)	
	CursorWait()
	(oBrowse:Alias())->(DbCloseArea())	
	oBrowse:SetAlias(cAlias)	
	nIni := Seconds()
	oBrowse:SetQuery(cQuery)
	oBrowse:Refresh() //NÃO RETIRAR ESSA LINHA DEVIDO A ERRO DE FRAMEWORK
	oBrowse:GoTop()   //NÃO RETIRAR ESSA LINHA DEVIDO A ERRO DE FRAMEWORK
	CursorArrow()
Return


/*/{Protheus.doc} TM76LibArr
Funcão para Desalocar memória de arrays.
@author izac.ciszevski
@since 27/10/2014
@version 1.0
@param aArray, array, array a ser destruído.
/*/
Function TM76LibArr(aArray)
	Local nX := 0

	DEFAULT aArray := {}
	
	for nX:= 1 to Len(aArray)
		If ValType(aArray[nX])== 'A'
			TM76LibArr(aArray[nX])
		ElseIf ValType(aArray[nX])== 'O'
			FreeObj(aArray[nX])
		EndIf
	next
	
	aSize(aArray,0)
	aArray := Nil
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Leg³ Autor ³ Leandro Paulino     ³ Data ³ 24/09/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta Legenda da rotina ativa                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Leg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAF76Leg(cConteudo)
Local aCores 	:= {}
Local cCor 	:= 'BR_PRETO'
Local cResult	:= ""
Local nPos 	:= 0  
Local cFilDoc	:= ''
Local cDoc		:= ''
Local cSerie	:= ''
Local nValor	:= 0
Local nSaldo	:= 0
Local cSit		:= ''               

Default cConteudo := ""
If cNomeCampo == 'DF0_STATUS'
	aCores := TMSAF05Cor()
	nPos := Ascan(aCores, {|x| (x[1]) == cNomeCampo+'=='+"'"+AllTrim(cConteudo)+"'"} ) 
ElseIf cNomeCampo == 'DT5_STATUS'
	aCores := TMSA460Cor()                                                             
	nPos := Ascan(aCores, {|x| (x[1]) == cNomeCampo+'=='+"'"+AllTrim(cConteudo)+"'"} ) 
ElseIf cNomeCampo == 'DTC_STATUS'
	aCores := TMSA050Cor()	                                                                  	
	CResult:= TMS050Stlt(Eval(cFilOriDTC),Eval(cLotNFcDTC))                                         	
	nPos 	:= Ascan(aCores, {|x| (x[1]) == "TMS050STLT(DTC->DTC_FILORI, DTC->DTC_LOTNFC)==" + "'" + AllTrim(cResult)+"'"} )
ElseIf cNomeCampo == 'DTP_STATUS'
	aCores := TMSA200Cor()                                                             
	nPos := Ascan(aCores, {|x| (x[1]) == cNomeCampo+'=='+"'"+AllTrim(cConteudo)+"'"} ) 
ElseIf cNomeCampo == 'DTQ_STATUS'
	aCores := TMSA140Cor()                                                             
	nPos := Ascan(aCores,{|x| (x[1]) == cNomeCampo+'=='+"'"+AllTrim(cConteudo)+"'"} ) 
ElseIf cNomeCampo == 'DTX_STATUS'	
	If !Empty(cConteudo)
		cCor := 'BR_VERMELHO'
	Else
		cCor := 'BR_VERDE'			
	EndIf	                                                                            	
ElseIf cNomeCampo == 'DTY_STATUS'
	aCores := TMSA250Cor()                                                             
	nPos := Ascan(aCores,{|x| (x[1]) == cNomeCampo+'=='+"'"+AllTrim(cConteudo)+"'"} ) 
ElseIf cNomeCampo == 'DTW_STATUS'	
	aCores := TMSA350Cor()
	nPos := Ascan(aCores,{|x| (x[1]) == cNomeCampo+'=='+"'"+AllTrim(cConteudo)+"'"} ) 
ElseIf cNomeCampo == 'DT6_STATUS'
	If ValType(cFilDocDT6) == 'B'
		cFilDoc := Eval(cFilDocDT6)
	EndIf
	If ValType(cDocDT6) == 'B'
		cDoc    := Eval(cDocDT6)
	EndIf	
	If ValType(cSerieDT6) == 'B'
		cSerie  := Eval(cSerieDT6)
	EndIf	
	If cConteudo == '1' .Or. TMSStatCol(cFilDoc,cDoc,cSerie,'1')
		cCor := "BR_VERDE"  	//--Em Aberto
	ElseIf cConteudo == '2' .Or. 	TMSStatCol(cFilDoc,cDoc,cSerie,'2')
		cCor := "BR_VERMELHO"//--Em Aberto 
	ElseIf cConteudo == '3' .Or. 	TMSStatCol(cFilDoc,cDoc,cSerie,'3')
		cCor := "BR_AMARELO"	//--Em Transito
	ElseIf (cConteudo == '4' .And. cSerie <> 'COL') .Or. TMSStatCol(cFilDoc,cDoc,cSerie,'4') 
	   cCor := "BR_LARANJA" //--Chega Parcial ###Documento Informado
	ElseIf cConteudo == '5' .Or. TMSStatCol(cFilDoc,cDoc,cSerie,,'5') 
		cCor := "BR_AZUL"	//-- Chegada final   ### Encerrada
	ElseIf cConteudo == '6'
		cCor := "BR_CINZA" //--Indicado para Coleta			
	ElseIf cConteudo == '7'
		cCor := "BR_MARRON" //--Entregue
	ElseIf TMSStatCol(cFilDoc,cDoc,cSerie,'9') 	
		cCor := "BR_PRETO"	//-- Ordem de Coleta Cancelada
	ElseIf cConteudo == '8'
		cCor := "BR_PINK" //Entrega Parcial
	ElseIf cConteudo == '9'
		cCor := "BR_CANCEL" //Anulado
	ElseIf cConteudo == 'A'
		cCor := "BR_BRANCO" //Retorno Total
	EndIf	       
ElseIf cNomeCampo == 'E1_SITFAT'               
	If ValType(nSaldoSE1) == "B"
		nSaldo := Eval(nSaldoSE1)
	EndIf	                         
	If ValType(nValorSE1) == "B"   
		nValor := Eval(nValorSE1)
	EndIf
	If ValType(cSitSE1) == "B"
		cSit := Eval(cSitSE1)
	EndIf
	If cConteudo == '3'
		cCor := "BR_PRETO"	//"Fatura Cancelada"
	ElseIf ROUND(nSaldo,2) == ROUND(nValor,2) .And. cSit $ "F6"
		cCor := "BR_AMARELO" //"Fatura Protestada"               
	ElseIf ROUND(nSaldo,2) = 0
		cCor := "BR_VERMELHO" //"Fatura Baixada"
	ElseIf cConteudo == '2'
		cCor := "BR_AZUL" // "Fatura Impressa"
	Else
		cCor := "BR_VERDE" // "Fatura em Aberto"
	EndIf
ElseIf cNomeCampo == 'DF8_STATUS'
	cCor := TM146Cor('P',,,,,AllTrim(cConteudo))
EndIf

If nPos > 0
	cCor := aCores[nPos,2]
EndIf

Return cCor		 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Per³ Autor ³ Leandro Paulino     ³ Data ³ 10/03/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta array com os perguntes informados na abertura do     ³±±
±±³          ³ Painel de Agendamento                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Per()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tmsaf76Per()

Local aRet	:= {}
Local cQueryDF0 	:= {}
Local cQueryDF1 	:= {}
Local aStatus  	:= {}
Local nPos			:= 0
Local cStatusDe	:= '' //--Status Inicial Informado no range de acordo com o "-";
Local cStatusAte	:= '' //--Status Final Informado no range de acordo com o "-";
Local cStatusAll	:= '' //--Todos Status informados no range separados pelo";"
Local nX			:= 0

If Pergunte("TMSAF7601" ,.T.)

	//--Bloco que controla as informações do Range do pergunte Status (MV_Par17)
	
	aStatus := Iif(!Empty(mv_par17),Str2Arr(Upper(mv_par17), ";"),{})
	
	If Len(aStatus) > 0                        
		nPos:= At("-",aStatus[1])
		If nPos > 0
			cStatusDe := SubStr(aStatus[1],1,(nPos-1))
			cStatusAte:= SubStr(aStatus[1],nPos+1)			   			
		Else
			For nX := 1 To Len(aStatus)
				cStatusAll +=  "'" + aStatus[nx] + Iif(nX == Len(aStatus),"'", "',")
			Next nX
		EndIf	
	Else
		cFilDe	:= Space(Len(DTC->DTC_FILIAL))
		cFilAte := Replicate('Z',Len(DTC->DTC_FILIAL))
	EndIf	
	
	cQueryDF0 :=     " DF0_NUMAGE >= '" + (MV_PAR01)     + "' AND DF0_NUMAGE <= '" + (MV_PAR02) + "'"
	cQueryDF0 += " AND DF0_DATCAD >= '" + Dtos(MV_PAR03) + "' AND DF0_DATCAD <= '" + Dtos(MV_PAR04) + "'"  
	If !Empty(cStatusAll)																								//--Posicao 3 do aQueryDF0
		cQueryDF0 += " AND DF0_STATUS IN (" + cStatusAll + ")"
	Else
		cQueryDF0 += " AND DF0_STATUS >= '" + cStatusDe + "' AND DF0_STATUS <= '" + cStatusAte + "'"
	EndIf
	
	cQueryDF1 :=     " DF1_CLIREM >= '" + (MV_PAR05) + "' AND DF1_LOJREM >= '" + (MV_PAR06) + "'"
	cQueryDF1 += " AND DF1_CLIREM <= '" + (MV_PAR07) + "' AND DF1_LOJREM <= '" + (MV_PAR08) + "'"
	cQueryDF1 += " AND DF1_CLIDES >= '" + (MV_PAR09) + "' AND DF1_LOJDES >= '" + (MV_PAR10) + "'"		
	cQueryDF1 += " AND DF1_CLIDES <= '" + (MV_PAR11) + "' AND DF1_LOJDES <= '" + (MV_PAR12) + "'"			
	cQueryDF1 += " AND DF1_CLIDEV >= '" + (MV_PAR13) + "' AND DF1_LOJDEV >= '" + (MV_PAR14) + "'"			
	cQueryDF1 += " AND DF1_CLIDEV <= '" + (MV_PAR15) + "' AND DF1_LOJDEV <= '" + (MV_PAR16) + "'"			
	cQueryDf1 += " AND DF1_TIPTRA  = '" + (MV_PAR18) + "'"													
	cQueryDF1 += " AND DF1_CODNEG >= '" + (MV_PAR19) + "' AND DF1_CODNEG <= '" + (MV_PAR20) + "'"			
	cQueryDF1 += " AND DF1_CDRORI >= '" + (MV_PAR21) + "' AND DF1_CDRORI <= '" + (MV_PAR22) + "'"			
	cQueryDF1 += " AND DF1_CDRDES >= '" + (MV_PAR23) + "' AND DF1_CDRDES <= '" + (MV_PAR24) + "'"
	cQueryDf1 += " AND DF1_FILORI='" + cFilAnt + "'"													
	
	Aadd(aRet,{"DF0","",cQueryDF0,"DF0"})
	Aadd(aRet,{"DF1","",cQueryDF1,"DF1"})
EndIf	
Return aRet

/*/-----------------------------------------------------------
{Protheus.doc} AF76ExbAgd
Monta tela de exibição de Agendamentos à Confirmar

Uso: TMSAF76

@sample
//AF76ExbAgd

@author Paulo Henrique Corrêa Cardoso.
@since 13/04/2016
@version 1.0
-----------------------------------------------------------/*/
Function AF76ExbAgd(aAgds)
Local aAreas     := {DF0->(GetArea()),GetArea()}
Local oDlg		 := Nil  		// Recebe o objeto da Dialog				
Local oListBox	 := Nil			// Recebe o objeto do ListBox
Local oCheck  	 := LoadBitmap( GetResources(), "CHECKED" )      // Legends : CHECKED  / LBOK  /LBTIK
Local oNoCheck	 := LoadBitmap( GetResources(), "UNCHECKED" )    // Legends : UNCHECKED /LBNO
Local lBkpInclui := INCLUI				// Recebe o Backup da Variavel INCLUI
Local lBkpAltera := ALTERA				// Recebe o Backup da Variavel ALTERA  
Local nCntFor1   := 0
Local aCabec     := {}
Local aCampos    := {"DF1_NUMAGE","DF1_ITEAGE","DF1_STACOL","DF1_STAENT","DF1_DATPRC","DF1_HORPRC","DF1_CLIREM","DF1_LOJREM","DF1_NOMREM",;
					 "DF1_CDRORI","DF1_REGORI","DF1_CDRDES","DF1_REGDES","DF1_CODNEG","DF1_DESNEG","DF1_SRVCOL","DF1_DESCOL","DF1_SERVIC","DF1_DESSER"}
Local oVermelho  := LoadBitmap(GetResources(),"BR_VERMELHO")	//-- Existem validações
Local oAmarelo   := LoadBitmap(GetResources(),"BR_AMARELO")		//-- Somente confirmar

Local lAllMark := .F.
Local oAllMark

Default aAgds := {}				// Recebe os Agendamentos

If Len(aAgds) > 0

	For nCntFor1 := 1 To Len(aCampos)
		Aadd(aCabec,RetTitle(aCampos[nCntFor1]))
	Next nCntFor1
	 
	 INCLUI  := .F.
	 ALTERA  := .F.
	 
	 dbSelectArea("DF0")
	 DF0->(dbSetOrder(1))
	
	Define MSDialog oDlg title STR0097 From c( 180 ), c( 180 ) To c( 530 ), c( 910 ) Pixel	//-- "Validação dos Agendamentos"
	 // Chamadas das Listbox do Sistema
	 
	@ c(005),c(005) ListBox oListBox Fields Header "","",aCabec[01],aCabec[02],aCabec[03],aCabec[04],aCabec[05],aCabec[06],aCabec[07],aCabec[08],aCabec[09],;
														 aCabec[10],aCabec[11],aCabec[12],aCabec[13],aCabec[14],aCabec[15],aCabec[16],aCabec[17],aCabec[18],;
														 aCabec[19] Size c( 360 ), c( 150 ) Of oDlg Pixel 
	 
	oListBox:SetArray( aAgds )

	oListBox:bLine := {|| { 	Iif(aAgds[oListBox:nAt][01],oCheck,oNoCheck),;
								Iif(aAgds[oListBox:nAt][02],oVermelho,oAmarelo),;
	 								aAgds[oListBox:nAt][03],aAgds[oListBox:nAt][04],aAgds[oListBox:nAt][05],;
									aAgds[oListBox:nAt][06],aAgds[oListBox:nAt][07],aAgds[oListBox:nAt][08],aAgds[oListBox:nAt][09],;
									aAgds[oListBox:nAt][10],aAgds[oListBox:nAt][11],aAgds[oListBox:nAt][12],aAgds[oListBox:nAt][13],;
									aAgds[oListBox:nAt][14],aAgds[oListBox:nAt][15],aAgds[oListBox:nAt][16],aAgds[oListBox:nAt][17],;
									aAgds[oListBox:nAt][18],aAgds[oListBox:nAt][19],aAgds[oListBox:nAt][20],aAgds[oListBox:nAt][21]}}

	oListBox:BLDBLCLICK := { ||	aAgds[oListBox:nAt][1] := !aAgds[oListBox:nAt][1], oListBox:Refresh()}

	oListBox:bHeaderClick:= {|oObj,nCol| Iif(nCol == 2,AF76LegVld(),)}

	//-- Marca/Desmarca Todos
	@ 205,005 CHECKBOX oAllMark VAR lAllMark PROMPT STR0101 SIZE 168,08 ON CLICK(AF76AllMrk(aAgds,lAllMark,oListBox)) OF oDlg PIXEL //-- "Marca/Desmarca Todos"
									 
	// Cria componentes padroes do sistema
	Define SButton From c( 160 ), c( 230 ) Type 2  Enable Of oDlg Action (AF76CofAgd(aAgds,.F.,.T.),oDlg:End() ) // Cancela
	Define SButton From c( 160 ), c( 265 ) Type 1  Enable Of oDlg Action (AF76CofAgd(aAgds,.T.,.F.),oDlg:End() ) // OK
	Define SButton From c( 160 ), c( 300 ) Type 15 Enable Of oDlg Action ( IIf( DF0->( dbSeek( FwxFilial("DF0")+aAgds[oListBox:nAt][3])),TMSF05Mnt("DF0",DF0->(Recno()),2,.T.),) )
	Define SButton From c( 160 ), c( 335 ) Type 5  Enable Of oDlg Action (AF76LstVld(aAgds[oListBox:nAt,22]))	//-- Lista validações
	  
	Activate MSDialog oDlg Centered
EndIf

// Restaura as Variaveis 
INCLUI := lBkpInclui	
ALTERA := lBkpAltera

AEval(aAreas,{|x,y| RestArea(x) })

Return 

/*/-----------------------------------------------------------
{Protheus.doc} AF76CofAgd
Realiza a Confirmação de Agendamento

Uso: TMSAF76

@sample
//AF76CofAgd

@author Paulo Henrique Corrêa Cardoso.
@since 13/04/2016
@version 1.0
-----------------------------------------------------------/*/
Function AF76CofAgd(aAgds,lConfAgd,lCancel)
Local nCount 		:= 0 					// Recebe o contador
Local aAreaBKP	:= GetArea()			// Recebe a Area Ativa
Local aAreaDF0	:= DF0->(GetArea())	// Recebe a Area Ativa da tabela DF0
Local aAreaDF1	:= DF1->(GetArea())	// Recebe a Area Ativa da tabela DF0

Default aAgds 	:= {} 					// Recebe os Ageendamentos	
Default lCancel	:= .F.					// Recebe se o usuario clicou no botão cancelar
Default lConfAgd  := .T.					// Recebe se deverá executar a confirmação do Agendamento no TMSF05

If Len(aAgds) > 0

	 dbSelectArea("DF0")
	 DF0->(dbSetOrder(1))
	 
	 dbSelectArea("DF1")
	 DF1->(dbSetOrder(1))
	 
	For nCount := 1 To  Len(aAgds)
		
		If !aAgds[nCount][1] .Or. lCancel
			// Retira a Marcação do Agendamento
			If DF1->( dbSeek( FwxFilial("DF1")+aAgds[nCount][3]+aAgds[nCount][4] ))
				RecLock("DF1",.F.)
				DF1_MRKPAN :=  Space(Len(DF1->DF1_MRKPAN))
				DF1->(MsUnlock())
			EndIf
		ElseIf lConfAgd
						
			// Confirma o Agendamento
			If DF0->( dbSeek( FwxFilial("DF0")+aAgds[nCount][3]))			
				If DF1->(DbSeek(FwxFilial("DF1") + aAgds[nCount][3] + aAgds[nCount][4] ))
					TMSF05Mnt("DF0",DF0->(Recno()),6,.F.)
				EndIf
			EndIf
			
		EndIf
		
	Next nCount

EndIf

RestArea(aAreaDF0)
RestArea(aAreaDF1)
RestArea(aAreaBKP)
Return

/*/-----------------------------------------------------------
{Protheus.doc} AF76RotMvc
Realiza o tratamento das rotinas do menu caso sejam MVC

Uso: TMSAF76

@sample
//AF76RotMvc(aRot)

@author Paulo Henrique Corrêa Cardoso.
@since 27/05/2016
@version 1.0
-----------------------------------------------------------/*/
Function AF76RotMvc(aRot,cFonte)
Local nCntRot	 := 0

Default aRot   := {}
Default cFonte := ""

If Len(aRot) > 0 
	
	nCntRot:= 0
	For nCntRot := 1 To Len(aRot)
		
		If ValType(aRot[nCntRot][2]) ==  "C"
			If "VIEWDEF." $ aRot[nCntRot][2]
				aRot[nCntRot][2] := "FWExecView( '"+ aRot[nCntRot][1] +"' ,'"+ cFonte +"',"+ Iif(aRot[nCntRot][4]== 2,"1",cValToChar(aRot[nCntRot][4])) +")"
			EndIf
		ElseIf ValType(aRot[nCntRot][2]) ==  "A"
			AF76RotMvc(aRot[nCntRot][2],cFonte)
		EndIf
		
	Next nCntRot
EndIf

Return
/* 
  TMSAF76Crg
  Realiza o carregamento automatico para quando viagem de entrega ou entrega com coleta
  
  USO: TMSAF76
  
  @author: Tiago dos Santos
  @since : 05/07/2016
  @version: 1.0
   
*/
Function TMSF76Crg(nOpcx,lAltRota)
Local   lRet     := .F.
Private lLocaliz := GetMv('MV_LOCALIZ') == 'S'
Private lColeta	 := .F.
Private aDocto   := {}
Private aRotas   := {}
Private cGrpProd := ''
Private cSerTms  := M->DTQ_SERTMS
Private cTipTra  := M->DTQ_TIPTRA
Private ARota    := {}
Private lDoctoEnd:= .F. 
Private lTM141COL:= .F.


    TmsA140Qry( 2 )                                                  //- Carrega os documentos da viagem.
    Processa({|| lRet := Tmsa140Crg(nOpcx,lAltRota) }, "Aguarde...") //- "Aguarde..."

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Ref³ Autor ³ Valdemar Roberto     ³ Data ³ 01/07/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama o re-filtro                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Ref()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tmsaf76Ref()

//-- Evita Loop Da tela De Parãmetros
If !IsInCallStack("TmsaF76Per")

	aVetExp := TmsaF76Per()

	If !Empty(aVetExp)
		TMSF76AFIL(aAliasFil,.T.,.T.,.f.,,aAliasNom)
	EndIf

EndIf	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tmsaf76All³ Autor ³ Valdemar Roberto    ³ Data ³ 01/07/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca Todos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsaf76All()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Tmsaf76All()
Local nLinAtu := 0

CursorWait()
oMarkAge:GoTop(.T.)
nLinAtu ++

While nLinAtu <= oMarkAge:nLen
	TMSF76Mrk(,,.F.)
	oMarkAge:GoDown(1)
	nLinAtu ++
EndDo

oMarkAge:Refresh()
oMarkAge:GoTop(.T.)
//oMarkAge:Refresh()
CursorArrow()
Return

/*/-----------------------------------------------------------
{Protheus.doc} AF76VldAgd
Valida agendamentos marcados

Uso: TMSAF76

@sample
//AF76VldAgd()

@author Katia
@since 23/09/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function AF76VldAgd(lTela,aRet,nRadioSer,nRadioTip,lCont,aVetReg,aVetPrg,oMarkAge,nOpcx )
Local lRet      := .T.
Local aAgends   := {}
Local aItensAg  := {}
Local nCntAge   := 0
Local aAgendPend:= {}
Local aAgdCmplt := {}
Local nCntFor1  := 0
Local aMsgErr   := {}
Local aAreas    := {DF1->(GetArea()),DTC->(GetArea()),GetArea()}
Local lGrvMsg   := .F.

Local aCombStEnt := {}
Local aCombStCol := {}
Local cStaCol    := ""
Local cStaEnt    := ""
Local nSeek      := 0

Local lTemDoc := .T.

private __VPRINTSC := {}
Default lTela    := .T.
Default aRet     := {}
Default nRadioSer:= 0
Default nRadioTip:= 0
Default lCont    := .T.
Default oMarkAge := Nil
Default aVetReg  := {}
Default aVetPrg  := {}
Default nOpcx    := 0

//-- Busca os agendamentos marcados
//If lTela .And. (nOpcx == 3 .Or. nOpcx == 4)	//-- Traz da tela do painel
If lTela .And. nOpcx == 3	//-- Traz da tela do painel
	aAgends  := StrTokArr( StrTran(aRet[1],"'",""), "," )
	aItensAg := StrTokArr( StrTran(aRet[2],"'",""), "," )
	
	DF1->(dbSetOrder(1))
	DTC->(DbSetOrder(8))

	aCombStCol := RetSx3Box( GetSX3Cache("DF1_STACOL","X3_CBOX"),,, 1 )	
	aCombStEnt := RetSx3Box( GetSX3Cache("DF1_STAENT","X3_CBOX"),,, 1 ) 

	For nCntAge := 1 To Len(aAgends)
		// Verifica se esta pendente confirmação
		lGrvMsg := .F.
		If DF1->( dbSeek( FwxFilial("DF1")+ aAgends[nCntAge] + aItensAg[nCntAge] ) )
			
			If	( nSeek := Ascan( aCombStCol, { |x| x[ 2 ] == DF1->DF1_STACOL } ) ) > 0
				cStaCol :=  aCombStCol[ nSeek, 3 ]
			EndIf

			If	( nSeek := Ascan( aCombStEnt, { |x| x[ 2 ] == DF1->DF1_STAENT } ) ) > 0
				cStaEnt :=  aCombStEnt[ nSeek, 3 ]
			EndIf

			If DF1->DF1_STACOL == '1'
				lGrvMsg := .T.
				AADD(aAgendPend,{.F.,.F.,aAgends[nCntAge],aItensAg[nCntAge],cStaCol,cStaEnt,DF1->DF1_DATPRC,DF1->DF1_HORPRC,DF1->DF1_CLIREM,;
					DF1->DF1_LOJREM,Posicione("SA1",1,xFilial("SA1") + DF1->DF1_CLIREM + DF1->DF1_LOJREM,"A1_NOME"),;
					DF1->DF1_CDRORI,Posicione("DUY",1,xFilial("DUY") + DF1->DF1_CDRORI,"DUY_DESCRI"),DF1->DF1_CDRDES,;
					Posicione("DUY",1,xFilial("DUY") + DF1->DF1_CDRDES,"DUY_DESCRI"),DF1->DF1_CODNEG,;
					Posicione("DDB",1,xFilial("DDB") + DF1->DF1_CODNEG,"DDB_DESCRI"),DF1->DF1_SRVCOL,;
					TABELA("L4",DF1->DF1_SRVCOL,.F.),DF1->DF1_SERVIC,TABELA("L4",DF1->DF1_SERVIC,.F.),{{"001",STR0087}}})	//-- Confirme o agendamento
				AADD(aAgdCmplt,{aAgends[nCntAge],aItensAg[nCntAge]})
			EndIf
			//-- Valida documento para viagem
			cSerTms := StrZero(nRadioSer,Len(DTQ->DTQ_SERTMS))
			cTipTra := StrZero(nRadioTip,Len(DTQ->DTQ_TIPTRA))
			lTemDoc := .F.
			If nRadioSer == 1 //-- Coleta
				M->DTA_FILDOC := DF1->DF1_FILDOC
				M->DTA_DOC    := DF1->DF1_DOC
				M->DTA_SERIE  := DF1->DF1_SERIE
			Else //-- Transferência ou Entrega
				If DTC->(DbSeek(xFilial("DTC") + DF1->(DF1_FILDOC + DF1_DOC))) .And. !Empty(DTC->DTC_DOC)
					M->DTA_FILDOC := DTC->DTC_FILDOC
					M->DTA_DOC    := DTC->DTC_DOC
					M->DTA_SERIE  := DTC->DTC_SERIE
					lTemDoc := .T.
				Else
					M->DTA_FILDOC := DF1->DF1_FILDOC
					M->DTA_DOC    := DF1->DF1_DOC
					M->DTA_SERIE  := DF1->DF1_SERIE
				EndIf
			EndIf
			If !lGrvMsg .And. lTemDoc
				AADD(aAgendPend,{.F.,.F.,aAgends[nCntAge],aItensAg[nCntAge],cStaCol,cStaEnt,DF1->DF1_DATPRC,DF1->DF1_HORPRC,DF1->DF1_CLIREM,;
					DF1->DF1_LOJREM,Posicione("SA1",1,xFilial("SA1") + DF1->DF1_CLIREM + DF1->DF1_LOJREM,"A1_NOME"),;
					DF1->DF1_CDRORI,Posicione("DUY",1,xFilial("DUY") + DF1->DF1_CDRORI,"DUY_DESCRI"),DF1->DF1_CDRDES,;
					Posicione("DUY",1,xFilial("DUY") + DF1->DF1_CDRDES,"DUY_DESCRI"),DF1->DF1_CODNEG,;
					Posicione("DDB",1,xFilial("DDB") + DF1->DF1_CODNEG,"DDB_DESCRI"),DF1->DF1_SRVCOL,;
					TABELA("L4",DF1->DF1_SRVCOL,.F.),DF1->DF1_SERVIC,TABELA("L4",DF1->DF1_SERVIC,.F.),{}})
				TmsA210Val("M->DTA_FILDOC",nOpcx,@aAgendPend)
				If Empty(aAgendPend[Len(aAgendPend),22])
					Adel(aAgendPend,Len(aAgendPend))
					Asize(aAgendPend,Len(aAgendPend) - 1)
				Else
					aAgendPend[Len(aAgendPend),2] := .T.
				EndIf
			EndIf
		EndIf	
	Next nCntAge
					
	// Exibe a tela para confirmar os Agendamentos
	If Len(aAgendPend) > 0 
		AF76ExbAgd(aAgendPend)
	EndIf
	//-- Chama a impressão das Solicitacoes de Coletas
	If Len(__VPRINTSC) > 0
	     Pergunte("TMA460",.F.)
	     TmsA460Imp(,,,,(mv_par01 == 1))
	EndIf
	aRet := TMSF76Age(.F.,.F.,.T.,StrZero(nRadioSer,1),StrZero(nRadioTip,1))
EndIf

If nRadioSer == 2 .Or. nRadioSer == 3
	If lCont
		aVetReg := Aclone(aRet[3])
		For nCntFor1 := 1 To Len(aVetReg)
			DUD->(DbGoTo(aVetReg[nCntFor1]))
			If (DUD->DUD_FILORI != cFilAnt .Or. DUD->DUD_STATUS != StrZero(1,Len(DUD->DUD_STATUS))) .And. nOpcx != 4
				If Empty(aMsgErr)
					AAdd(aMsgErr,{STR0043,"00",""}) //--"Os agendamentos abaixo não estão disponiveis para a sua filial."
				EndIf
				DF1->(DbGoTo(aVetPrg[nCntFor1]))
				AAdd(aMsgErr,{DF1->DF1_FILORI + "/" + DF1->DF1_NUMAGE + "/" + DF1->DF1_ITEAGE + " - ","00",""})
				RecLock("DF1",.F.)
				DF1_MRKPAN = Space(Len(DF1->DF1_MRKPAN))
				DF1->(MsUnlock())
			EndIf
		Next nCntFor1
		If !Empty(aMsgErr)
			oMarkAge:Refresh()
			oMarkAge:GoTop() //NÃO RETIRAR ESSA LINHA DEVIDO A ERRO DE FRAMEWORK
			oMarkAge:Refresh() //NÃO RETIRAR ESSA LINHA DEVIDO A ERRO DE FRAMEWORK
			AAdd(aMsgErr,{STR0044,"00",""}) //--"Deseja carregar somente os agendamentos disponíveis?"
			If !TmsMsgErr(aMsgErr)
				lCont := .F.
			EndIf
		EndIf
	EndIf
EndIf
lRet:= lCont

AEval(aAreas,{|x,y| RestArea(x) })

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AF76LegVld ³ Autor ³ Valdemar Roberto   ³ Data ³ 24/11/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe legenda das validações dos agendamentos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AF76LegVld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AF76LegVld()
Local aArea    := GetArea()
Local aLegenda := {}		

Aadd(aLegenda,{"BR_VERMELHO",STR0095})	//-- "Existem validações"
Aadd(aLegenda,{"BR_AMARELO" ,STR0096})	//-- "Somente confirmar"

If Len(aLegenda) > 0  
	BrwLegenda(STR0094,STR0094,aLegenda)	//-- "Legenda"
EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AF76LstVld ³ Autor ³ Valdemar Roberto   ³ Data ³ 24/11/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Lista as validações dos agendamentos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AF76LstVld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function AF76LstVld(aAgeVld)
Local aAreas := {GetArea()}
Local oDlg
Local oListBox

DEFAULT aAgeVld := {}

If Len(aAgeVld) > 0
	Define MSDialog oDlg title STR0098 From c(180),c(180) To c(530),c(910) Pixel	//-- "Mensagens"

	@ c(005),c(005) ListBox oListBox Fields Header STR0099,STR0100 Size c(360),c(150) Of oDlg Pixel	//-- "Sequencia" # "Mensagem"
	 
	oListBox:SetArray( aAgeVld )

	oListBox:bLine := {|| {aAgeVld[oListBox:nAt][01],aAgeVld[oListBox:nAt][02]}}

	Define SButton From c(160),c(335) Type 1 Enable Of oDlg	Action (oDlg:End())	//-- OK

	Activate MSDialog oDlg Centered
EndIf

AEval(aAreas,{|x,y| RestArea(x) })

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ AF76AllMrk ³ Autor ³ Valdemar Roberto   ³ Data ³ 01/04/17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca/Desmarca todos os agendamentos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AF76AllMrk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function AF76AllMrk(aAgds,lAllMrk,oListBox)
Local nCntFor1 := 0

For nCntFor1 := 1 To Len(aAgds)
	aAgds[nCntFor1,1] := lAllMrk
Next nCntFor1

oListBox:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSF76Moni ³ Autor ³ Valdemar Roberto   ³ Data ³ 30/03/20  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa Monitor e Alteração do Comprovante Eletrônico      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF76Moni(cExp01,nExp01,nExp02)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 := 1-Monitoramento                                  ³±±
±±³          ³           2-Alteração                                      ³±±
±±³          ³ nExp01 := Opção do Protheus                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF76                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSF76Moni(nAcao,nOpcx)
Local cFonte := ""

Private lMonitora := Iif(nAcao == 1,.T.,.F.)

Default nAcao  := 0
Default nOpcx  := 0

If nAcao == 1
	cFonte := "TMSAE71A()"
Else
	cFonte := "TMSAE71B()"
EndIf

If !Empty(cFonte)
	&(cFonte)
EndIf

Return
 
