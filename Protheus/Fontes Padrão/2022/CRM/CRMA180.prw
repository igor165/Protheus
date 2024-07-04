#INCLUDE "CRMA180.CH"
#INCLUDE "CRMDEF.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

//----------------------------------------------------------
/*/{Protheus.doc} CRMA180()

Chamada para rotina de Atividades

@param	  ExpU1 = Variavel que recebera um array contendo os dados, somente por ExecAuto
		  ExpN1 = Variavel que recebera a operação que ira realizar o model, somente por ExecAuto
		  ExpL1 = Variavel que indica se é uma chamada automatica
		  ExpN2 = Tipo de Operação que será realizada.
		  ExpC1 = Alias da entidade a ser vinculada
		  ExpA1 = Array Contendo os Anexos, quando for rotina automatica para Email.
		  ExpO1 = Modelop de dados a ser ultilizado
		  ExpN3 = Tipo da atividade a ser criada (Tipo do modelo que deverá ser aberto...(tarefa,compromisso ...))
		  ExpC2 = Grafico de Atividades Concluidas
		  ExpC3 = 
       	  ExpC4 = Código do Usuário Proprietário da atividade a ser criada

@return  lRet

@author   Victor Bitencourt
@since    17/02/2014
@version  12.0
/*/
//----------------------------------------------------------
Function CRMA180( uRotAuto, nOpcAuto, lExecAuto, nOper, cAlias, aAnexos, oMdlAux, nTpAtiv, cVDefault, cCodRastr, cCodUsrPr)

Local cEntidade          := Alias()
Local nTimerSinc         := 10
Local nX                 := 0
Local aIcon              := {}
Local aInfoUser          := {}
Local aDadosSX2          := {}
Local cCodUsr			 := If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
Local lRet               := .F.
Local lThread            := .F. // indica se uma thread foi criado
Local cFilENT            := ""
Local cUnico             := ""
Local cFilCam            := "" // Filtro das Campanhas Rapidas
Local cFiltroAO4         := ""

Local oCalend            := Nil
Local oMBrowse           := Nil // Browse da lista de scripts executados
Local oLayerMain         := Nil // Layer Principal
Local oLayerInte         := Nil // Layer Interno
Local oDlgOwner          := Nil // Janela Principal
Local oCOLRIGHT          := Nil // Coluna da Direita Dentro do Layer Principal
Local oCOLLEFT           := Nil // Coluna da Esquerda Dentro do Layer Principal
Local oLINEONE           := Nil
Local oLINETWO           := Nil
Local oLINETHRE          := Nil
Local oTableAtt          := Nil

Local oTimer             := Nil

Local aSize              := FWGetDialogSize( oMainWnd )

Local aLegEnt            := {}
Local cCnpjCnt			 := ""
Local oModel			 := Nil

Private aRotina  		    := MenuDef()

Private cCRM180CRA       := ""  // Codigo rastreavel para html com imagen, este parametro só é valido quando é distribuição de e-mails
Private lCRM180Aut       := Nil // verifica se foi chamado de uma rotina automatica
Private oCRM180EHT       := Nil // variavel que receberá o objeto do Editor de HTML
Private nCRM180TAt       := 0   // Tipo de Atividade
Private nCRM180MOp       := 0   // Operação que o Model está executando
Private aCRM180ANX       := {}  // Variavel queguarda os anexos do email
Private lCRM180CIn 	     := .T. // Variavel para controlar a inserção de atividades
Private cCRM180AVc       := IIF(ValType(cAlias) == "C" .AND. !Empty(cAlias),cAlias,cEntidade) // variavel private que guarda o alias da entidade a ser vinculada
Private oCRM180GET       := Nil // Variavel do objeto get
Private lMsErroAuto      := .F.

Default cVDefault        := "TarConcl" // Grafico de Atividades Concluidas
Default lExecAuto        := .F.
Default nOper            := NIL
Default nTpAtiv          := NIL
Default cAlias           := Nil
Default aAnexos          := Nil
Default oMdlAux          := Nil
Default cCodRastr        := ""
Default cCodUsrPr        := ""

cCRM180CRA := cCodRastr 
lCRM180Aut := lExecAuto

If uRotAuto == Nil .AND. nOpcAuto == Nil .AND. nOper == Nil

    aIcon := {{" AOF_TIPO == '1'" ,"BR_AMARELO", STR0001 },;//"Tarefa"
              {" AOF_TIPO == '2'" ,"BR_AZUL"   , STR0002},;	//"Compromisso"
              {" AOF_TIPO == '3'" ,"BR_VERDE"  , STR0058 },;//"Email"
              {" Empty(AOF_TIPO)","",""}}

	DbSelectArea("AO2")//Modelo de Email
	AO2->(DbSetOrder(1)) //AO1_FILIAL+AO1_ENTIDADE
	
    If FunName() == "CRMA180" // só realiza a sincronização automatica quando ele entra direto da rotina no Menu
		If !Empty(cCodUsr) .AND. AO3->(DbSeek(xFilial("AO3")+cCodUsr))	// Verifica se é um usuario do CRM
			FwMsgRun(,{|| aInfoUser := CRM170GetS(.T.) },Nil,STR0095) //"Carregando dados do usuário !"
			If aInfoUser[_PREFIXO][_Habilita]
				CRMA170EXG(.T.,aInfoUser)
			 	nTimerSinc := IIF(!Empty(aInfoUser[_PREFIXO][_TimeMin]),Val(aInfoUser[_PREFIXO][_TimeMin]),nTimerSinc)// valor padrao 10, caso o _TimeMin venha vazio
				CRM170AThr()
				CreateSyncSession(cValToChar(ThreadId()))
				lThread := .T.
			EndIf
		EndIf
	EndIf

	//--------------------------------------
	//		Criando Janela Principal
	//--------------------------------------
	DEFINE DIALOG oDlgOwner TITLE STR0003 FROM aSize[1],aSize[2] TO aSize[3],aSize[4] PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)//"Atividades"

		//--------------------------------------
		//		Criando Browser e Layer
		//--------------------------------------
		oMBrowse       := FWMBrowse():New()
		oLayerMain     := FWLayer():New()
		oLayerInte     := FWLayer():New()

		oLayerMain:Init(oDlgOwner,.F.)

		oLayerMain:AddCollumn("LEFT_BOX",73,.F.)
		oLayerMain:AddCollumn("RIGTH_BOX",27,.F.)
		oLayerMain:setColSplit("RIGTH_BOX",CONTROL_ALIGN_LEFT,Nil,Nil)

		oCOLRIGHT := oLayerMain:getColPanel("RIGTH_BOX",Nil)
		oCOLLEFT  := oLayerMain:getColPanel("LEFT_BOX",Nil)

		oLayerInte:Init(oCOLRIGHT,.F.)

		oLayerInte:AddLine("LINEONE" ,32,.F.,Nil)
		oLayerInte:AddLine("LINETWO" ,45,.F.,Nil)
		oLayerInte:AddLine("LINETHRE",23,.F.,Nil)

		oLINEONE  := oLayerInte:getLinePanel("LINEONE")
		oLINETWO  := oLayerInte:getLinePanel("LINETWO")
		oLINETHRE := oLayerInte:getLinePanel("LINETHRE")

		CRM180Calend(oLINEONE,oMBrowse,@oCalend)
		CRM180MntOutros(oLINETWO,oMBrowse)
		CRMA180MTS(oLINETHRE)

		oMBrowse:SetCanSaveArea(.T.) 
		oMBrowse:SetOwner(oCOLLEFT)
		oMBrowse:SetAlias("AOF")
		oMBrowse:SetDescription(STR0003)//Atividades
		
		//--------------------------
		//	Criando o Filtro da AO4
		//--------------------------
		cFiltroAO4 := CRMXFilEnt( "AOF", .T. )
		oMBrowse:DeleteFilter( "AO4_FILENT" )
		oMBrowse:AddFilter( STR0056, cFiltroAO4, .T., .T., "AO4", , , "AO4_FILENT" )//"Filtro do CRM"
		oMBrowse:ExecuteFilter()

		//-------------------------------------------------------------------------------------
		//	Criando o Filtro de Campanhas e Campanhas rapidas, quando chamada dessas rotinas
		//-------------------------------------------------------------------------------------
		If IsInCallStack("CRMA250") .OR. IsInCallStack("TMKA310") //Verificando se a chamada vem de Campanhas
			aDadosSX2  := CRMXGetSX2(cCRM180AVc)
			If !Empty(aDadosSX2)
		      	cUnico  := (cCRM180AVc)->&(aDadosSX2[1])
			EndIf
			Do Case
				Case IsInCallStack("CRMA250")
					cFilCam := "AOF_TIPCAM == 'AOC' .AND. AOF_CHVCAM == '"+xFilial("AOC")+AOC->AOC_CODIGO+"'"
			  	Case IsInCallStack("TMKA310")
					cFilCam := "AOF_TIPCAM == 'SUO' .AND. AOF_CHVCAM == '"+xFilial("SUO")+SUO->UO_CODCAMP+"'"
					cFilCam += " .OR. (AOF_FILIAL == '"+xFilial("AOF")+"'.AND. AOF_ENTIDA == '"+cCRM180AVc+"' .AND. AOF_CHAVE == '"+cUnico+"')"
			EndCase
	    	oMBrowse:DeleteFilter("AOF_FILCAM")
	    	oMBrowse:AddFilter(STR0087,cFilCam ,.T.,.T.,,,,"AOF_FILCAM")//Filtro de Campanhas
	    	oMBrowse:ExecuteFilter()
		ElseIf ( FunName() <> "CRMA180" .AND. !IsInCallStack("CRMA180WAATI") ) .Or. IsInCallStack( 'CRMA710' ) //Verificando a chamada se é de Ações relacionadas de outros fontes e que não seja diretamente da WorkArea 
			aDadosSX2  := CRMXGetSX2(cCRM180AVc)
			If !Empty(aDadosSX2)
		      	cUnico  := (cCRM180AVc)->&(aDadosSX2[1])
	        EndIf
	        //Caso a rotina de atividades esteja sendo executada à partir da rotina de 
			//Suspect/Prospects/Clientes 
			If cCRM180AVc == "ACH" .OR. cCRM180AVc == "SUS" .OR. cCRM180AVc == "SA1"
				
				cFilEnt := "AOF_FILIAL == '"+xFilial("AOF")+"'.AND.( (AOF_ENTIDA == "+"'"+ cCRM180AVc+"'"+ ".AND. AOF_CHAVE == " + "'" + cUnico + "') " 
				Do case 
					Case cCRM180AVc == "ACH"
						cCnpjCnt := ACH->ACH_CGC

					Case cCRM180AVc == "SUS"
						cCnpjCnt := SUS->US_CGC

					Case cCRM180AVc == "SA1"
						cCnpjCnt := SA1->A1_CGC
				Endcase

				If !Empty(cCnpjCnt)
					cFilEnt += CRM180Fil( cCRM180AVc, cCnpjCnt )
				EndIf

				cFilEnt +=" ) "

			Else
				cFilEnt := "AOF_FILIAL == '"+xFilial("AOF")+"'.AND. AOF_ENTIDA == '"+cCRM180AVc+"' .AND. AOF_CHAVE == '"+cUnico+"'" "
			Endif 
	       oMBrowse:DeleteFilter("AOF_FILENT")
	       oMBrowse:AddFilter(STR0053,cFilEnt,.T.,.T.,,,,"AOF_FILENT")//Filtro Entidade
	       oMBrowse:ExecuteFilter()
		EndIf

		oMBrowse:SetAttach( .T. )//Habilita as visões do Browse
		oTableAtt := TableAttDef()

	    //--------------------------------------------------------------------------------------
		//	Carrega Todas as visões e graficos disponiveis para atividades na função TableAttDef
		//---------------------------------------------------------------------------------------
		If oTableAtt <> Nil
			oMBrowse:SetViewsDefault( oTableAtt:aViews )
			oMBrowse:SetChartsDefault( oTableAtt:aCharts )
			oMBrowse:SetIDChartDefault( "MesConl" )
		EndIf

		//--------------------------------------
		//	  Adiciona as legendas no browse
		//--------------------------------------
		For nX := 1 To Len(aIcon)
			oMBrowse:AddLegend(aIcon[nX][1],aIcon[nX][2],aIcon[nX][3])
		Next nX

		//----------------------------------------------------------------
		//Legenda adicional no browse - Cada entidade com uma cor
		//----------------------------------------------------------------
		aLegEnt := {"",{||CRMA180RegL()  },"C","@BMP",0,1,0,.F.,{||.T.},.T.,{|| CRMA180Leg() },,,,.F.}
		oMBrowse:AddColumn(aLegEnt)	
		//-----------------------------------------------------------
		//	 Criando objeto de Timer para a sincronização automatica
		//-----------------------------------------------------------
		If !Empty(aInfoUser) .AND. aInfoUser[_PREFIXO][_Habilita]
			oTimer := TTimer():New(nTimerSinc *60000,{|| IIF(aInfoUser[_PREFIXO][_Habilita],CRMA170EXG(.T.)[2],Nil),oMBrowse:Refresh(.T.) } , oDlgOwner )
	 		oTimer:Activate()
		EndIf

		//---------------------------
		// Configurações no Browse
		//---------------------------
		oMBrowse:DisableDetails()
		oMBrowse:AddButton(STR0059,{ || oDlgOwner:End() },0,0,0,,,,,{STR0059})//"Sair"
		oMBrowse:SetTotalDefault("AOF_CODIGO","COUNT",STR0097) // "Total de Registros"

		oLayerMain:ClickColSplit( "RIGTH_BOX" , Nil )//Começar com o split do layer fechado
		oMBrowse:SetMainProc("CRMA180") 		
		oMBrowse:Activate()

 	ACTIVATE DIALOG oDlgOwner CENTERED

 	If lThread
		EndSyncSession(cValToChar(ThreadId())) // encerrando thread criada
	EndIf

ElseIf !Empty(uRotAuto) .AND. nOpcAuto > 0 .AND. nOper == Nil

	//--------------------------------------------------------------------------------
	//	 Verificando se existe anexos quando quando executados de rotinas automaticas
	//--------------------------------------------------------------------------------
	If ValType(aAnexos) == "A" .AND. !Empty(aAnexos)
		aCRM180ANX := aClone(aAnexos)
	EndIf
	
	oModel := ModelDef()
	
	FWMVCRotAuto(oModel,"AOF",nOpcAuto,{{"AOFMASTER",uRotAuto}},/*lSeek*/,.T.)

  	If lMsErroAuto
  		MostraErro()
  		lMsErroAuto := .F. //Setando valor padrão para variavel
  	Endif
  	
  	oModel:DeActivate()
  	oModel:Destroy()

ElseIf FunName() <> "CRMA180" .And. ValType( nOper ) == "N" .And. nOper > 0
 	Do Case
 		Case nOper == 2
          CRMA180VIS()
		Case nOper == 3
         lRet := CRMA180INC(cAlias, oMdlAux, nTpAtiv, cCodUsrPr)
		Case nOper == 4
          CRMA180ALT()
		Case nOper == 5
          CRMA180DEL()
	EndCase
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/	{Protheus.doc} TableAttDef

Cria as visões e gráficos.

@sample	TableAttDef()

@param		Nenhum

@return	ExpO - Objetos com as Visoes e Gráficos.

@author	Cristiane Nishizaka
@since		28/04/2014
@version	12
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()

Local oTableAtt 		:= Nil
//Visões
Local oTarAberta		:= Nil // Minhas Tarefas Abertas
Local oTarConcl			:= Nil // Minhas Tarefas Concluídas
Local oTarTodas			:= Nil // Todas as Tarefas
Local oCmpAberto		:= Nil // Meus Compromissos Abertos
Local oCmpConcl			:= Nil // Meus Compromissos Concluídos
Local oCmpTodos			:= Nil // Todos os compromissos
Local oEmailPend		:= Nil // Meus E-mails Pendentes
Local oEmailAll			:= Nil // Todos os E-mails
Local oAtvAberta		:= Nil // Minhas Atividades Abertas
Local oAtvConcl			:= Nil // Minhas Atividades Concluídas

//Gráficos
Local oMesConl			:= Nil // Colunas: Atividades por mês de conclusão
Local oPriorid			:= Nil // Pizza: Atividades por prioridade
Local oStatus 			:= Nil // Linhas: Atividades Por Status
Local oPropriet 		:= Nil // Linhas: Atividades Por proprietário
Local oTipo				:= Nil // Pizza: Atividades por tipo

Local lCRM180View		:= ExistBlock("CRMBRWVIEW")	//Ponto entrada para manipulação das views padrão
Local cRotina			:= "CRMA180"
Local cAliasView		:= "AOF"
Local cCodUsr			:= If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())

If lCRM180View   //CRMBRWVIEW(cRotina,cAliasview )
	oTableAtt := ExecBlock("CRMBRWVIEW", .F.,.F.,{cRotina,cAliasView})
EndIf

If Empty( oTableAtt )	

	oTableAtt := FWTableAtt():New()
	oTableAtt:SetAlias("AOF")

	//----------
	// Visões
	//----------
	
	// Minhas Tarefas Abertas
	oTarAberta := FWDSView():New()
	oTarAberta:SetName(STR0098)// "Minhas Tarefas Abertas"
	oTarAberta:SetID("TarAberta")
	oTarAberta:SetOrder(1) // AOF_FILIAL+AOF_CODIGO
	oTarAberta:SetCollumns({"AOF_ASSUNT","AOF_DTINIC","AOF_DTFIM","AOF_STATUS","AOF_MSBLQL"})
	oTarAberta:SetPublic( .T. )
	oTarAberta:AddFilterRelation( 'AO4', 'AO4_CHVREG', 'AOF_FILIAL+AOF_CODIGO' )
	oTarAberta:AddFilter(STR0098, "AOF_TIPO == '1' .AND. AOF_STATUS <> '3'") // "Minhas Tarefas Abertas"
	oTarAberta:AddFilter(STR0098, "AO4_CODUSR == '"+cCodUsr+"' .AND. AO4_CTRLTT == .T.","AO4") // "Minhas Tarefas Abertas"
	
	oTableAtt:AddView(oTarAberta)
	
	// Minhas Tarefas Concluídas
	oTarConcl := FWDSView():New()
	oTarConcl:SetName(STR0099) // "Minhas Tarefas Concluídas"
	oTarConcl:SetID("TarConcl")
	oTarConcl:SetOrder(1) // AOF_FILIAL+AOF_CODIGO
	oTarConcl:SetCollumns({"AOF_ASSUNT","AOF_DTINIC","AOF_DTFIM","AOF_DTCONC","AOF_MSBLQL"})
	oTarConcl:SetPublic( .T. )
	oTarConcl:AddFilterRelation( 'AO4', 'AO4_CHVREG', 'AOF_FILIAL+AOF_CODIGO' )
	oTarConcl:AddFilter(STR0099, "AOF_TIPO == '1' .AND. AOF_STATUS == '3'") // "Minhas Tarefas Concluídas"
	oTarConcl:AddFilter(STR0099, "AO4_CODUSR == '"+cCodUsr+"' .AND. AO4_CTRLTT == .T.","AO4") // "Minhas Tarefas Concluídas"
	
	oTableAtt:AddView(oTarConcl)
	
	// Todas as Tarefas
	oTarTodas	:= FWDSView():New()
	oTarTodas:SetName(STR0100) // "Todas as Tarefas"
	oTarTodas:SetID("TarTodas")
	oTarTodas:SetOrder(1) // AOF_FILIAL+AOF_CODIGO
	oTarTodas:SetCollumns({"AOF_ASSUNT","AOF_DTINIC","AOF_DTFIM","AOF_STATUS","AOF_MSBLQL"})
	oTarTodas:SetPublic( .T. )
	oTarTodas:AddFilter(STR0100, 'AOF_TIPO == "1"') // "Todas as Tarefas"
	
	oTableAtt:AddView(oTarTodas)
	
	// Meus Compromissos Abertos
	oCmpAberto := FWDSView():New()
	oCmpAberto:SetName(STR0101) // "Meus Compromissos Abertos"
	oCmpAberto:SetID("CmpAberto")
	oCmpAberto:SetOrder(1) // AOF_FILIAL+AOF_CODIGO
	oCmpAberto:SetCollumns({"AOF_ASSUNT","AOF_PARTIC","AOF_LOCAL","AOF_DTINIC","AOF_HRINIC",;
							"AOF_DTFIM","AOF_HRFIM","AOF_STATUS","AOF_MSBLQL"})
	oCmpAberto:SetPublic( .T. )
	oCmpAberto:AddFilterRelation( 'AO4', 'AO4_CHVREG', 'AOF_FILIAL+AOF_CODIGO' )
	oCmpAberto:AddFilter(STR0101, "AOF_TIPO == '2' .AND. AOF_STATUS <> '3'") // "Meus Compromissos Abertos"
	oCmpAberto:AddFilter(STR0101, "AO4_CODUSR == '"+cCodUsr+"' .AND. AO4_CTRLTT == .T.","AO4") // "Meus Compromissos Abertos"
	
	oTableAtt:AddView(oCmpAberto)
	
	// Meus Compromissos Concluídos
	oCmpConcl := FWDSView():New()
	oCmpConcl:SetName(STR0102) // "Meus Compromissos Concluídos"
	oCmpConcl:SetID("CmpConcl")
	oCmpConcl:SetOrder(1) // AOF_FILIAL+AOF_CODIGO
	oCmpConcl:SetCollumns({"AOF_ASSUNT","AOF_PARTIC","AOF_LOCAL","AOF_DTINIC","AOF_HRINIC",;
							"AOF_DTFIM","AOF_HRFIM","AOF_DTCONC","AOF_MSBLQL"})
	oCmpConcl:SetPublic( .T. )
	oCmpConcl:AddFilterRelation( 'AO4', 'AO4_CHVREG', 'AOF_FILIAL+AOF_CODIGO' )
	oCmpConcl:AddFilter(STR0102, "AOF_TIPO == '2' .AND. AOF_STATUS == '3'") // "Meus Compromissos Concluídos"
	oCmpConcl:AddFilter(STR0102, "AO4_CODUSR == '"+cCodUsr+"' .AND. AO4_CTRLTT == .T.","AO4") // "Meus Compromissos Concluídos"
	
	oTableAtt:AddView(oCmpConcl)
	
	// Todos os compromissos
	oCmpTodos := FWDSView():New()
	oCmpTodos:SetName(STR0103) // "Todos os compromissos"
	oCmpTodos:SetID("CmpTodos")
	oCmpTodos:SetOrder(1) // AOF_FILIAL+AOF_CODIGO
	oCmpTodos:SetCollumns({"AOF_ASSUNT","AOF_PARTIC","AOF_LOCAL","AOF_DTINIC","AOF_HRINIC",;
							"AOF_DTFIM","AOF_HRFIM","AOF_STATUS","AOF_MSBLQL"})
	oCmpTodos:SetPublic( .T. )
	oCmpTodos:AddFilter(STR0103, 'AOF_TIPO == "2"') // "Todos os compromissos"
	
	oTableAtt:AddView(oCmpTodos)
	
	// Meus E-mails Pendentes
	oEmailPend := FWDSView():New()
	oEmailPend:SetName(STR0104) // "Meus E-mails Pendentes"
	oEmailPend:SetID("EmailPend")
	oEmailPend:SetOrder(1) // AOF_FILIAL+AOF_CODIGO
	oEmailPend:SetCollumns({"AOF_ASSUNT","AOF_DESTIN","AOF_PARTIC","AOF_DTINIC","AOF_MSBLQL"})
	oEmailPend:SetPublic( .T. )
	oEmailPend:AddFilterRelation( 'AO4', 'AO4_CHVREG', 'AOF_FILIAL+AOF_CODIGO' )
	oEmailPend:AddFilter(STR0104, "AOF_TIPO == '3' .AND. AOF_STATUS == '6'") // "Meus E-mails Pendentes"
	oEmailPend:AddFilter(STR0104, "AO4_CODUSR == '"+cCodUsr+"' .AND. AO4_CTRLTT == .T.","AO4") // "Meus E-mails Pendentes"
	
	oTableAtt:AddView(oEmailPend)
	
	// Todos os E-mails
	oEmailAll := FWDSView():New()
	oEmailAll:SetName(STR0105) // "Todos os E-mails"
	oEmailAll:SetID("EmailAll")
	oEmailAll:SetOrder(1) // AOF_FILIAL+AOF_CODIGO
	oEmailAll:SetCollumns({"AOF_ASSUNT","AOF_DESTIN","AOF_PARTIC","AOF_DTINIC","AOF_STATUS","AOF_MSBLQL"})
	oEmailAll:SetPublic( .T. )
	oEmailAll:AddFilter(STR0105, 'AOF_TIPO == "3"') // "Todos os E-mails"
	
	oTableAtt:AddView(oEmailAll)
	
	// Minhas Atividades Abertas
	oAtvAberta := FWDSView():New()
	oAtvAberta:SetName(STR0106) // "Minhas Atividades Abertas"
	oAtvAberta:SetID("AtvAberta")
	oAtvAberta:SetOrder(1) // AOF_FILIAL+AOF_CODIGO
	oAtvAberta:SetCollumns({"AOF_TIPO","AOF_ASSUNT","AOF_DTINIC","AOF_DTFIM","AOF_STATUS","AOF_MSBLQL"})
	oAtvAberta:SetPublic( .T. )
	oAtvAberta:AddFilterRelation( 'AO4', 'AO4_CHVREG', 'AOF_FILIAL+AOF_CODIGO' )
	oAtvAberta:AddFilter(STR0106, "AOF_STATUS <> '3'") // "Minhas Atividades Abertas"
	oAtvAberta:AddFilter(STR0106, "AO4_CODUSR == '"+cCodUsr+"' .AND. AO4_CTRLTT == .T.","AO4") // "Minhas Atividades Abertas"
	
	oTableAtt:AddView(oAtvAberta)
	
	// Minhas Atividades Concluídas
	oAtvConcl := FWDSView():New()
	oAtvConcl:SetName(STR0107) // "Minhas Atividades Concluídas"
	oAtvConcl:SetID("AtvConcl")
	oAtvConcl:SetOrder(1) // AOF_FILIAL+AOF_CODIGO
	oAtvConcl:SetCollumns({"AOF_TIPO","AOF_ASSUNT","AOF_DTINIC","AOF_DTFIM","AOF_DTCONC","AOF_MSBLQL"})
	oAtvConcl:SetPublic( .T. )
	oAtvConcl:AddFilterRelation( 'AO4', 'AO4_CHVREG', 'AOF_FILIAL+AOF_CODIGO' )
	oAtvConcl:AddFilter(STR0107, "AOF_STATUS == '3'") // "Minhas Atividades Concluídas"
	oAtvConcl:AddFilter(STR0107, "AO4_CODUSR == '"+cCodUsr+"' .AND. AO4_CTRLTT == .T.","AO4") // "Minhas Atividades Concluídas"
	
	oTableAtt:AddView(oAtvConcl)
EndIf
//------------
// Gráficos
//------------

// Colunas: Atividades por data de conclusão
oMesConl := FWDSChart():New()
oMesConl:SetName(STR0108) // "Atividades Por Data de Conclusão"
oMesConl:setTitle(STR0108) // "Atividades Por Data de Conclusão"
oMesConl:SetID("MesConl")
oMesConl:SetType("BARCOMPCHART")
oMesConl:SetSeries({ {"AOF", "AOF_CODIGO", "COUNT"} })
oMesConl:SetCategory( { {"AOF", "AOF_DTCONC"} } )
oMesConl:SetPublic( .T. )
oMesConl:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oMesConl:SetTitleAlign( CONTROL_ALIGN_CENTER )

oTableAtt:AddChart(oMesConl)

// Pizza: Atividades por prioridade
oPriorid := FWDSChart():New()
oPriorid:SetName(STR0109) // "Atividades Por Prioridade"
oPriorid:setTitle(STR0109) // "Atividades Por Prioridade"
oPriorid:SetID("Priorid")
oPriorid:SetType("PIECHART")
oPriorid:SetSeries({ {"AOF", "AOF_CODIGO", "COUNT"} })
oPriorid:SetCategory( { {"AOF", "AOF_PRIORI"} } )
oPriorid:SetPublic( .T. )
oPriorid:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oPriorid:SetTitleAlign( CONTROL_ALIGN_CENTER )

oTableAtt:AddChart(oPriorid)

// Linhas: Atividades Por Status
oStatus := FWDSChart():New()
oStatus:SetName(STR0110) // "Atividades Por Status"
oStatus:setTitle(STR0110) // "Atividades Por Status"
oStatus:SetID("Status")
oStatus:SetType("LINECHART")
oStatus:SetSeries({ {"AOF", "AOF_CODIGO", "COUNT"} })
oStatus:SetCategory( { {"AOF", "AOF_STATUS"} } )
oStatus:SetPublic( .T. )
oStatus:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oStatus:SetTitleAlign( CONTROL_ALIGN_CENTER )

oTableAtt:AddChart(oStatus)

// Linhas: Atividades Por proprietário
oPropriet := FWDSChart():New()
oPropriet:SetName(STR0111) // "Atividades Por Proprietário"
oPropriet:SetTitle(STR0111) // "Atividades Por Proprietário"
oPropriet:SetID("Propriet")
oPropriet:SetType("LINECHART")
oPropriet:SetSeries({ {"AOF", "AOF_CODIGO", "COUNT"} })
oPropriet:SetCategory( { {"AOF", "AOF_CODUSR"} } )
oPropriet:SetPublic( .T. )
oPropriet:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oPropriet:SetTitleAlign( CONTROL_ALIGN_CENTER )

oTableAtt:AddChart(oPropriet)

// Pizza: Atividades por tipo
oTipo := FWDSChart():New()
oTipo:SetName(STR0112) // "Atividades Por Tipo"
oTipo:SetTitle(STR0112) // "Atividades Por Tipo"
oTipo:SetID("Tipo")
oTipo:SetType("PIECHART")
oTipo:SetSeries({ {"AOF", "AOF_CODIGO", "COUNT"} })
oTipo:SetCategory( { {"AOF", "AOF_TIPO"} } )
oTipo:SetPublic( .T. )
oTipo:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oTipo:SetTitleAlign( CONTROL_ALIGN_CENTER )

oTableAtt:AddChart(oTipo)

Return (oTableAtt)


//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Modelo de dados da atividade
@param	  Nenhum
@return  oModel - objeto contendo o modelo de dados
@author   Victor Bitencourt
@since    17/02/2014
@version  12.0
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel      := Nil
Local oStructAOF  := FWFormStruct(1,"AOF")

oModel := MPFormModel():New("CRMA180",/*bPreValidacao*/,/*bPosValidacao*/,{ |oModel| ModelCommit(oModel) },/*bCancel*/)
oModel:SetDescription(STR0006)//"Atividades"
oModel:AddFields("AOFMASTER",/*cOwner*/,oStructAOF,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:SetPrimaryKey({"AOF_FILIAL" ,"AOF_CODIGO"})
oModel:GetModel("AOFMASTER"):SetDescription(STR0007)//"Atividade"

// Adicao do modelo da AO4 para evitar a validacao indevida do relacionamento SX9 antes da funcao CRMA200PAut
AO4GdModel("AOFMASTER", oModel, "AOF" )

If Type("nCRM180TAt") == "N" .AND. nCRM180TAt > 0
	Do Case // Definindo quais campos deverá serem obrigatórios, conforme o tipo de atividade.
		Case nCRM180TAt == Val(TPTAREFA) .OR. nCRM180TAt == Val(TPCOMPROMISSO) //Tarefa //Compromisso
			oStructAOF:SetProperty("AOF_DTINIC",MODEL_FIELD_OBRIGAT,.T.)
			oStructAOF:SetProperty("AOF_DTFIM",MODEL_FIELD_OBRIGAT,.T.)
		Case nCRM180TAt == Val(TPEMAIL)//EMAIL
			If FunName() == "CRMA180"
				oStructAOF:SetProperty("AOF_DESTIN",MODEL_FIELD_OBRIGAT,.T.)
			Else
				oStructAOF:SetProperty("AOF_DESTIN",MODEL_FIELD_OBRIGAT,.F.)
			EndIf
			oStructAOF:SetProperty("AOF_ASSUNT",MODEL_FIELD_OBRIGAT,.F.)
	EndCase
EndIf
return (oModel)


//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
ViewDef - Visão do model de atividades
@param	  Nenhum
@return  oView - objeto contendo a visão criada
@author   Victor Bitencourt
@since    17/02/2014
@version  12.0
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oView			:= FWFormView():New()
Local oModel		:= FwLoadModel("CRMA180")
Local cFieldsUser	:= CRM180UCpo()

Local aComboAtiv   := {STR0060,STR0061,STR0062,STR0063,STR0064,STR0120}//1=Não Iniciada//"2= Em Andamento"//"3= Concluída"//"4= Aguardando outros"//"5= Adiada"//"9=Cancelada"//combo com os status disponiveis para atividades
Local aComboEmail  := {STR0065,STR0066 ,STR0067}//"6=Pendente"//"7=Enviado"//"8=Lido"//combo com os status disponiveis para Email

local cDescricao   := ""

Local cCpoAOFTar   := "AOF_CODIGO|AOF_ASSUNT|AOF_DTCONC|AOF_DESCRI|AOF_DTINIC|AOF_DTFIM|AOF_PERCEN|AOF_PRIORI|AOF_STATUS|AOF_ENTIDA|AOF_DESCEN|AOF_CHAVE|AOF_DESCRE|AOF_DTLEMB|AOF_HRLEMB|AOF_DURACA|AOF_CODUSR|AOF_USRDES|AOF_MSBLQL|" + cFieldsUser  // estrutura para Tarefas
Local cCpoAOFCOM   := "AOF_CODIGO|AOF_CODUMO|AOF_ASSUNT|AOF_DESCRI|AOF_LOCAL|AOF_PARTIC|AOF_DTINIC|AOF_HRINIC|AOF_DTFIM|AOF_HRFIM|AOF_DURACA|AOF_ENTIDA|AOF_DESCEN|AOF_DESCRE|AOF_CHAVE|AOF_DTCONC|AOF_STATUS|AOF_PERCEN|AOF_PRIORI|AOF_CODUSR|AOF_USRDES|AOF_MSBLQL|" + cFieldsUser // estrutura para Compromissos
Local cCpoAOFEMA   := "AOF_CODIGO|AOF_DTCAD|AOF_STATUS|AOF_ENTIDA|AOF_DESCEN|AOF_CHAVE|AOF_DESCRE|AOF_DESTIN|AOF_ANEXO|AOF_DTAEMA|AOF_PARTIC|AOF_CODUSR|AOF_USRDES|AOF_MSBLQL|" + cFieldsUser // estrutura para Email

Local bAvCpoTAR    := {|cCampo| AllTrim(cCampo)+"|" $ cCpoAOFTar}
Local bAvCpoCOM    := {|cCampo| AllTrim(cCampo)+"|" $ cCpoAOFCOM}
Local bAvCpoEMA    := {|cCampo| AllTrim(cCampo)+"|" $ cCpoAOFEMA}

Local oStructATI   :=  Nil
Local lCRM180TAt   := Type("nCRM180TAt") == "N" .And. nCRM180TAt > 0

Local lTk272GrvTmk := IsInCallStack("Tk272GrvTmk")

Do Case

	Case ( lCRM180TAt .And. nCRM180TAt == Val(TPTAREFA) ) //Tarefa
	
		oStructATI :=	FWFormStruct(2,"AOF",bAvCpoTAR)
		cDescricao := STR0008		//"Tarefa"

		oStructATI:AddGroup( "GRUPO01", STR0009, "", 2 )// criando grupo de campos informações	//"Informações"
		oStructATI:AddGroup( "GRUPO02", STR0010, "", 2 )// criando grupo de campos de Agendamento//"Agendamento"
		oStructATI:AddGroup( "GRUPO03", STR0011, "", 2 )// criando grupo de campos de status//"Status"
		oStructATI:AddGroup( "GRUPO04", STR0017, "", 2 )// criando grupo de campos da entidade relacionada//"Entidade Relacionada"

		oStructATI:SetProperty("AOF_CODIGO" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
		oStructATI:SetProperty("AOF_ASSUNT" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
		oStructATI:SetProperty("AOF_DESCRI" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )

		oStructATI:SetProperty("AOF_DTINIC" , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
		oStructATI:SetProperty("AOF_DTFIM"  , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
		oStructATI:SetProperty("AOF_DTLEMB" , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
		oStructATI:SetProperty("AOF_HRLEMB" , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
		oStructATI:SetProperty("AOF_DURACA" , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )

		oStructATI:SetProperty("AOF_PERCEN" , MVC_VIEW_GROUP_NUMBER, "GRUPO03" )
		oStructATI:SetProperty("AOF_STATUS" , MVC_VIEW_GROUP_NUMBER, "GRUPO03" )
		oStructATI:SetProperty("AOF_PRIORI" , MVC_VIEW_GROUP_NUMBER, "GRUPO03" )
		oStructATI:SetProperty("AOF_DTCONC" , MVC_VIEW_GROUP_NUMBER, "GRUPO03" )

		oStructATI:SetProperty("AOF_ENTIDA" , MVC_VIEW_GROUP_NUMBER, "GRUPO04" )
		oStructATI:SetProperty("AOF_DESCEN" , MVC_VIEW_GROUP_NUMBER, "GRUPO04" )
		oStructATI:SetProperty("AOF_CHAVE"  , MVC_VIEW_GROUP_NUMBER, "GRUPO04" )
		oStructATI:SetProperty("AOF_DESCRE" , MVC_VIEW_GROUP_NUMBER, "GRUPO04" )

		//colocando os campos na ordem
		oStructATI:SetProperty("AOF_CODIGO" , MVC_VIEW_ORDEM, "01" )
		oStructATI:SetProperty("AOF_ASSUNT" , MVC_VIEW_ORDEM, "02" )
		oStructATI:SetProperty("AOF_DESCRI" , MVC_VIEW_ORDEM, "03" )

		oStructATI:SetProperty("AOF_ENTIDA" , MVC_VIEW_ORDEM, "12" )
		oStructATI:SetProperty("AOF_DESCEN" , MVC_VIEW_ORDEM, "13" )
		oStructATI:SetProperty("AOF_CHAVE"  , MVC_VIEW_ORDEM, "14" )
		oStructATI:SetProperty("AOF_DESCRE" , MVC_VIEW_ORDEM, "15" )

		oStructATI:SetProperty("AOF_STATUS" , MVC_VIEW_COMBOBOX, aComboAtiv )

		If IsInCallStack("Tk310Ativ") .OR. IsInCallStack("CRMA250") .OR. lTk272GrvTmk
			oStructATI:SetProperty("AOF_ENTIDA" , MVC_VIEW_CANCHANGE, .F. )
			oStructATI:SetProperty("AOF_CHAVE"  , MVC_VIEW_CANCHANGE, .F. )
			If lTk272GrvTmk
				oStructATI:SetProperty("AOF_CODUSR", MVC_VIEW_CANCHANGE, .F.)
			EndIf
		EndIf

	Case ( lCRM180TAt .And. nCRM180TAt == VAl(TPCOMPROMISSO) ) //Compromisso
	
		oStructATI := FWFormStruct(2,"AOF",bAvCpoCOM)
		cDescricao := STR0013//"Compromisso"

		oStructATI:AddGroup( "GRUPO01", STR0014, "", 2 )// criando grupo de campos informações	//"Informações"
		oStructATI:AddGroup( "GRUPO02", STR0015, "", 2 ) // criando grupo de campos de Agendamento//"Agendamento"
		oStructATI:AddGroup( "GRUPO03", STR0016, "", 2 )// criando grupo de campos de status//"Status"
		oStructATI:AddGroup( "GRUPO04", STR0017, "", 2 )// criando grupo de campos da entidade relacionada//"Entidade Relacionada"

		oStructATI:SetProperty("AOF_CODIGO" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
		oStructATI:SetProperty("AOF_CODUMO" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
		oStructATI:SetProperty("AOF_ASSUNT" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
		oStructATI:SetProperty("AOF_DESCRI" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
		oStructATI:SetProperty("AOF_LOCAL"  , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
		oStructATI:SetProperty("AOF_PARTIC" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )

		oStructATI:SetProperty("AOF_DTINIC" , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
		oStructATI:SetProperty("AOF_HRINIC" , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
		oStructATI:SetProperty("AOF_DTFIM"  , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
		oStructATI:SetProperty("AOF_HRFIM"  , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
		oStructATI:SetProperty("AOF_DURACA" , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )

		oStructATI:SetProperty("AOF_PERCEN" , MVC_VIEW_GROUP_NUMBER, "GRUPO03" )
		oStructATI:SetProperty("AOF_STATUS" , MVC_VIEW_GROUP_NUMBER, "GRUPO03" )
		oStructATI:SetProperty("AOF_PRIORI" , MVC_VIEW_GROUP_NUMBER, "GRUPO03" )
		oStructATI:SetProperty("AOF_DTCONC" , MVC_VIEW_GROUP_NUMBER, "GRUPO03" )

		oStructATI:SetProperty("AOF_ENTIDA" , MVC_VIEW_GROUP_NUMBER, "GRUPO04" )
		oStructATI:SetProperty("AOF_DESCEN" , MVC_VIEW_GROUP_NUMBER, "GRUPO04" )
		oStructATI:SetProperty("AOF_CHAVE"  , MVC_VIEW_GROUP_NUMBER, "GRUPO04" )
		oStructATI:SetProperty("AOF_DESCRE" , MVC_VIEW_GROUP_NUMBER, "GRUPO04" )

		oStructATI:SetProperty("AOF_CODIGO" , MVC_VIEW_ORDEM, "01" )
		oStructATI:SetProperty("AOF_CODUMO" , MVC_VIEW_ORDEM, "02" )
		oStructATI:SetProperty("AOF_PARTIC" , MVC_VIEW_ORDEM, "03" )
		oStructATI:SetProperty("AOF_ASSUNT" , MVC_VIEW_ORDEM, "04" )
		oStructATI:SetProperty("AOF_LOCAL"  , MVC_VIEW_ORDEM, "05" )
		oStructATI:SetProperty("AOF_DESCRI" , MVC_VIEW_ORDEM, "06" )

		oStructATI:SetProperty("AOF_ENTIDA" , MVC_VIEW_ORDEM, "12" )
		oStructATI:SetProperty("AOF_DESCEN" , MVC_VIEW_ORDEM, "13" )
		oStructATI:SetProperty("AOF_CHAVE"  , MVC_VIEW_ORDEM, "14" )
		oStructATI:SetProperty("AOF_DESCRE" , MVC_VIEW_ORDEM, "15" )

		If IsInCallStack("Tk310Ativ") .OR. IsInCallStack("CRMA250") .OR. lTk272GrvTmk
			oStructATI:SetProperty("AOF_ENTIDA" , MVC_VIEW_CANCHANGE, .F. )
			oStructATI:SetProperty("AOF_CHAVE"  , MVC_VIEW_CANCHANGE, .F. )
			If lTk272GrvTmk
				oStructATI:SetProperty("AOF_CODUSR", MVC_VIEW_CANCHANGE, .F.)
			EndIf
		EndIf 

		oView:AddUserButton(STR0018,"",{|| CRMA140(,,AOF->AOF_CODUMO)},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE})	//"Check In\Out"
		oView:AddUserButton(STR0121,"",{|| CRMA180NEG(AOF->AOF_CODUMO)},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE})	//"Possíveis Negociações"
		oStructATI:SetProperty("AOF_STATUS", MVC_VIEW_COMBOBOX, aComboAtiv)

	Case ( lCRM180TAt .And. nCRM180TAt == Val(TPEMAIL) )//EMAIL
	
		oStructATI := FWFormStruct(2,"AOF",bAvCpoEMA) 
		cDescricao := STR0058//"Email"

		oStructATI:AddGroup( "GRUPO01", STR0014, "", 2 )// criando grupo de campos informações	//"Informações"
		oStructATI:AddGroup( "GRUPO02", STR0016, "", 2 )// criando grupo de campos de status//"Status"
		oStructATI:AddGroup( "GRUPO03", STR0017, "", 2 )// criando grupo de campos da entidade relacionada//"Entidade Relacionada"

		oStructATI:SetProperty("AOF_CODIGO" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
		oStructATI:SetProperty("AOF_DESTIN" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
		oStructATI:SetProperty("AOF_PARTIC" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )

		oStructATI:SetProperty("AOF_DTCAD"  , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
		oStructATI:SetProperty("AOF_STATUS" , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
		oStructATI:SetProperty("AOF_DTAEMA" , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
		oStructATI:SetProperty("AOF_ANEXO"  , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )

		oStructATI:SetProperty("AOF_ENTIDA" , MVC_VIEW_GROUP_NUMBER, "GRUPO03" )
		oStructATI:SetProperty("AOF_DESCEN" , MVC_VIEW_GROUP_NUMBER, "GRUPO03" )
		oStructATI:SetProperty("AOF_CHAVE"  , MVC_VIEW_GROUP_NUMBER, "GRUPO03" )
		oStructATI:SetProperty("AOF_DESCRE" , MVC_VIEW_GROUP_NUMBER, "GRUPO03" )

		oStructATI:SetProperty("AOF_CODIGO" , MVC_VIEW_ORDEM, "01" )
		oStructATI:SetProperty("AOF_DESTIN" , MVC_VIEW_ORDEM, "02" )
		oStructATI:SetProperty("AOF_PARTIC" , MVC_VIEW_ORDEM, "03" )

		oStructATI:SetProperty("AOF_DTCAD"  , MVC_VIEW_ORDEM, "04" )
		oStructATI:SetProperty("AOF_STATUS" , MVC_VIEW_ORDEM, "05" )
		oStructATI:SetProperty("AOF_DTAEMA" , MVC_VIEW_ORDEM, "06" )
		oStructATI:SetProperty("AOF_ANEXO"  , MVC_VIEW_ORDEM, "07" )

		oStructATI:SetProperty("AOF_STATUS" , MVC_VIEW_CANCHANGE, .F. )
		oStructATI:SetProperty("AOF_STATUS" , MVC_VIEW_COMBOBOX, aComboEmail )

		oStructATI:SetProperty("AOF_ENTIDA" , MVC_VIEW_ORDEM, "08" )
		oStructATI:SetProperty("AOF_DESCEN" , MVC_VIEW_ORDEM, "09" )
		oStructATI:SetProperty("AOF_CHAVE"  , MVC_VIEW_ORDEM, "10" )
		oStructATI:SetProperty("AOF_DESCRE" , MVC_VIEW_ORDEM, "11" )

		oView:AddOtherObject("VIEW_HTML" , {|oPanel| MntEdHTML(oPanel)})//Adiciona um objeto externo ao View do MVC

		If IsInCallStack("Tk310Ativ") .OR. IsInCallStack("CRMA250") .OR. lTk272GrvTmk
			oStructATI:SetProperty("AOF_ENTIDA" , MVC_VIEW_CANCHANGE, .F. )
			oStructATI:SetProperty("AOF_CHAVE"  , MVC_VIEW_CANCHANGE, .F. )
			If lTk272GrvTmk
				oStructATI:SetProperty("AOF_CODUSR", MVC_VIEW_CANCHANGE, .F.)
			Else
				oStructATI:SetProperty("AOF_DESTIN", MVC_VIEW_CANCHANGE, .F.)
			EndIf
		EndIf

 		oView:AddUserButton(STR0113,"",{|| CRMA170StR()},,,{MODEL_OPERATION_UPDATE,MODEL_OPERATION_INSERT})//"Diretório de Imagem"
		oView:AddUserButton(STR0069,"",{|| GetModEmail(FwModelActive())},,,{MODEL_OPERATION_UPDATE,MODEL_OPERATION_INSERT})//"Modelo de Email"
		oView:AddUserButton(STR0114,"",{|| Processa({|| AlteraMapHTML()},STR0117,STR0118)},,,{MODEL_OPERATION_UPDATE})//"Alterar Map. HTML"//Aguarde//"Alterando Mapemaneto de e-mail ..."

		If AOF->AOF_STATUS == STENVIADO
			oView:AddUserButton(STR0070,"",{|| ReenviaEmail() } ,,,{MODEL_OPERATION_VIEW}  )//"Reenviar Email"
		EndIf

		If Type("nCRM180MOp") == "N" .AND. nCRM180MOp <> MODEL_OPERATION_INSERT
	 		oStructATI:SetProperty("AOF_ANEXO" , MVC_VIEW_CANCHANGE, .F. )
       EndIf

	OtherWise
	 	oStructATI := FWFormStruct(2,"AOF")
	 	cDescricao := STR0019//"Atividade"
EndCase

// colocando na ordem correta os campos
oStructATI:SetProperty("AOF_CODUSR" , MVC_VIEW_ORDEM, "30" )
oStructATI:SetProperty("AOF_USRDES" , MVC_VIEW_ORDEM, "31" )
oStructATI:SetProperty("AOF_MSBLQL" , MVC_VIEW_ORDEM, "32" )

oView:AddUserButton(STR0055,"",{|| CRMA200("AOF")} ,,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE})//"Privilégios"
oView:AddUserButton(STR0068,"",{|| MsDocument("AOF",AOF->(RecNo()),3),CRMA180VRA("AOF",AOF->AOF_CODIGO,(xFilial("AOF")+AOF->AOF_CODIGO))} ,,,{MODEL_OPERATION_UPDATE})//"Anexar"

ASORT(oView:AUSERBUTTONS,,,{ | x,y | y[1] > x[1] } )
//--------------------------------------
//		Associa o View ao Model
//--------------------------------------
oView:SetModel( oModel )	//define que a view vai usar o model
oView:SetDescription(cDescricao) //Tipo de atividadepode ser (compromisso,e-mail,tarefa)

oView:AddField("VIEW_ATIV_FIELD", oStructATI, "AOFMASTER" )///,,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

//-----------------------------------------------------//
// Montagem da tela Cria os Box's conforme a Atividade //
//-----------------------------------------------------//
If lCRM180TAt
	If nCRM180TAt == Val(TPEMAIL)
		oView:CreateHorizontalBox( "LINEONE", 55 )  // Box da View
		oView:CreateHorizontalBox( "LINETWO", 45 )  // Box da View
	
		oView:SetOwnerView( "VIEW_ATIV_FIELD","LINEONE" )
		oView:SetOwnerView( "VIEW_HTML","LINETWO" )
	Else
		oView:CreateHorizontalBox( "LINEONE", 100 )  // Box da View
		oView:SetOwnerView( "VIEW_ATIV_FIELD","LINEONE" )
	EndIf
EndIf
Return (oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM180Calend()

Cria Area do Calendario

@param oPanel, painel, objeto onde sera criado o calendario
@param oModel, model, modelo
@param oCalend, objeto do calendario que sera construido

@author  Victor Bitencourt
@since   27/02/2014
@version 12.0
/*/
//--------------------------------------------------------------------
Static Function CRM180Calend(oPanel, oMBrowse, oCalend)

Local oFwLayer := Nil

DEFINE FONT oTFont
oTFont := TFont():New("Arial",,15,.T.,.T.)

oFwLayer := FwLayer():New()
oFwLayer:init(oPanel,.F.)

oFWLayer:addCollumn( "COL1",100, .T. , "LINHA2")
oFWLayer:addWindow( "COL1", "WIN1", STR0021, 100, .F., .F., , "LINHA2")//Calendário//"Calendário"

oPanel := oFWLayer:GetWinPanel("COL1","WIN1","LINHA2")

oCalend := MsCalend():New(01,01,oPanel) //Cria o calendario
oCalend:dDiaAtu := dDataBase

oCalend:bChange    := {|| CRM180EventCalend("CHANGE_DIA",oMBrowse,oCalend) }
oCalend:bChangeMes := {|| CRM180EventCalend("CHANGE_MES",oMBrowse,oCalend) }

Return

//----------------------------------------------------------
/*/{Protheus.doc} CRM180EventCalend()

rotina que executa os filtros conforme a interação do usuario com o calendario

@param cEvento, Evento que está sendo executado no calendario
@param oBrowse, objeto de borwse para ser manipulado
@param oCalend, objeto, Calendario

@Return Nenhum

@author Victor Bitencourt
@since  27/02/2014
@version 12.0
/*/
//----------------------------------------------------------
Static Function CRM180EventCalend(cEvento,oMBrowse, oCalend)

Local cAnoMesSel  := ""
Local dAnoMesAtiv := Nil
Local aArea	:= GetArea()

oMBrowse:DeleteFilter("FIL_CALEND")
Do Case
	Case cEvento == "CHANGE_DIA"
		oMBrowse:AddFilter(STR0022,"AOF_DTINIC == '" + dTos(oCalend:dDiaAtu) + "' ",.T.,.T.,,,,"FIL_CALEND")//"Filtro Calendario"
		oMBrowse:ExecuteFilter()
	Case cEvento == "CHANGE_MES"
		oMBrowse:DeleteFilter("FIL_MES_ATUAL")
		oMBrowse:AddFilter(STR0023,"Month(AOF_DTINIC) == "+cValToChar(Month(oCalend:dDiaAtu))+" .AND. Year(AOF_DTINIC) == "+cValToChar(Year(oCalend:dDiaAtu)),.T.,.T.,,,,"FIL_CALEND")	//"Filtro Calendario"
EndCase

If cEvento == "CHANGE_MES"
	If oCalend <> Nil
		oCalend:DelAllRestri()
		cAnoMesSel := SubStr(DtoS(oCalend:dDiaAtu), 1, 6)

		While AOF->(!EOF())
			dAnoMesAtiv := AOF->AOF_DTINIC
			If SubStr(DtoS(dAnoMesAtiv), 1, 6) == cAnoMesSel  // se o mes e ano do registro da grid for igual ao selecionado no calendario
					oCalend:AddRestri(Day(dAnoMesAtiv), CLR_HRED,0) // destaca os dias no calendario
			EndIf
			AOF->(dbSkip())
		EndDo
		oCalend:CtrlRefresh()
	EndIf
EndIf
RestArea(aArea)
oMBrowse:ExecuteFilter()
oMBrowse:Refresh(.T.)
Return

//----------------------------------------------------------
/*/{Protheus.doc} CRM180MntF()

filtra o Tipo de Atividade selecionado pelo usuario

@param oBrowse, objeto de browse para ser manipulado conforme o filtro
@param cComboExi, opção escolhida no combo box para ser filtrada

@Return Nenhum

@author Victor Bitencourt
@since  27/02/2014
@version 12.0
/*/
//----------------------------------------------------------
Static Function CRM180MntF(oMBrowse, cComboExi, aStatus, oComboSTA, oPanel)

aStatus := {}
oMBrowse:DeleteFilter("FIL_TPATIV")
Do Case
	Case cComboExi == TPTAREFA .OR. cComboExi == TPCOMPROMISSO
		oMBrowse:AddFilter(STR0024,"AOF_TIPO == '"+cComboExi + "'",.T.,.T.,,,,"FIL_TPATIV")//"Filtro Exibe Tarefa"
		aStatus := {STR0071,STR0060,STR0061,STR0062,STR0063,STR0064}//"0=Todos"//"1=Não Iniciada"//"2= Em Andamento"//"3= Concluída"//"4= Aguardando outros"//"5= Adiada"// combo com os status disponiveis para atividades
	Case cComboExi == TPEMAIL
		oMBrowse:AddFilter(STR0025,"AOF_TIPO == '"+cComboExi + "'",.T.,.T.,,,,"FIL_TPATIV")	//"Filtro Exibe EMail"
		aStatus := {STR0071,STR0065,STR0066 ,STR0067}//"0=Todos"//"6=Pendente"//"7=Enviado"//"8=Lido"//combo com os status disponiveis para Email
	Case cComboExi == "0"
		oMBrowse:DeleteFilter("FIL_STATIV")
		oMBrowse:DeleteFilter("FIL_CALEND")
		aStatus := {STR0071}
EndCase
oComboSTA:SetItems(aStatus)
oComboSTA:Refresh()
oPanel:Refresh()
oMBrowse:ExecuteFilter()
oMBrowse:Refresh(.T.)

Return

//----------------------------------------------------------
/*/{Protheus.doc} CRM180MntOutros()

cria tela com filtros e botão para limpar filtro

@param oPanel, objeto de panel indica um janela determinada dentro da tela de atividades
@param oMbrowse, objeto de browse para ser manipulado

@author Victor Bitencourt
@since  27/02/2014
@version 12.0
/*/
//----------------------------------------------------------
Static Function CRM180MntOutros(oPanel,oMbrowse)

Local oFwLayer  := Nil
Local oBtnCalen := Nil
Local oBtnEntid := Nil
Local oComboExi := Nil
Local cComboExi := "0"
Local oComboSTA := Nil
Local cComboSTA := ""
Local oGetCGC := Nil
Local cGetCGC := space(20)
Local aStatus := {STR0071}//"0=Todos"

DEFINE FONT oTFont
oTFont:= TFont():New("Arial",,15,.T.,.T.)

oFwLayer := FwLayer():New()
oFwLayer:init(oPanel,.F.)

oFWLayer:addCollumn( "COL1",100, .T. , "LINHA2")
oFWLayer:addWindow( "COL1", "WIN1", STR0026, 100, .F., .F., , "LINHA2")	//"Filtros"

oPanel := oFWLayer:GetWinPanel("COL1","WIN1","LINHA2")


@ 005, 010 BUTTON oBtnCalen PROMPT STR0031 SIZE 085, 010 ACTION oMBrowse:DeleteFilter("FIL_CALEND") OF oPanel PIXEL//"Limpar Filtro de Data"

@ 020, 010 BUTTON oBtnEntid PROMPT STR0073 SIZE 085, 010 ACTION (oMBrowse:DeleteFilter("AOF_FILENT"),cCRM180AVc := "") OF oPanel PIXEL//"Limpar Filtro de Entidade"


@ 034, 010 SAY oTitulo2 PROMPT STR0027 SIZE 120,009  OF oPanel PIXEL//"Filtro Tipo de Atividade:"
@ 044, 010 MSCOMBOBOX oComboExi VAR cComboExi ITEMS {STR0028,STR0029,STR0030,STR0054} SIZE 085, 010 OF oPanel;//"0=Todos"//"1=Exibe somente Tarefa"//"2=Exibe somente Compromisso"//"3= Exibe Somente Email"
           ON CHANGE CRM180MntF(oMbrowse,cComboExi,@aStatus,oComboSTA,oPanel) PIXEL

@ 060, 010 SAY oTitulo2 PROMPT STR0072 SIZE 120,009  OF oPanel PIXEL//"Filtro Status da Atividade:"
@ 070, 010 MSCOMBOBOX oComboSTA VAR cComboSTA ITEMS aStatus  SIZE 085, 010 OF oPanel;//"1=Todos"//"2=Exibe somente Tarefa"//"3=Exibe somente Compromisso"
           ON CHANGE FilStatusAtiv(oMbrowse,cComboSTA) WHEN (cComboExi <> "0") PIXEL

@ 086, 010 SAY oTitulo2 PROMPT STR0124 SIZE 120,009  OF oPanel PIXEL//"Filtro CGC:"
@ 096, 010 MSGET oGetCGC VAR cGetCGC SIZE 120, 010 Picture "99999999999999" Pixel OF oPanel Valid FilCGC(oMbrowse,cGetCGC)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Rotina para criar as opções de menu disponiveis para a tela de atividades
@param		Nenhum
@return	aRotina - array contendo as opções disponiveis
@author	Victor Bitencourt
@since		27/02/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Local aEntRelac := {}
Local aRotina   := {}

If FunName() == "CRMA530" .OR. FunName() == "TMKA310" .OR. FunName() == "TMKA061" .OR. FunName() == "CRMA360"
	ADD OPTION aRotina TITLE STR0032 	ACTION "CRMA180VIS()"        OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0035   ACTION "CRMA180DEL()"        OPERATION 5 ACCESS 0 //"Excluir"
Else
	ADD OPTION aRotina   TITLE STR0096 ACTION aEntRelac             OPERATION 1 ACCESS 0 // "Relacionadas"
	ADD OPTION aRotina TITLE STR0032 	ACTION "CRMA180VIS()"        OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0033   ACTION "CRMA180INC()"        OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0034   ACTION "CRMA180ALT()"        OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0035   ACTION "CRMA180DEL()"        OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0036	ACTION "CRM170GetS(.F.)"     OPERATION 3 ACCESS 0 //"Sincronizar"
	ADD OPTION aEntRelac TITLE STR0115 ACTION "MsDocument('AOF', AOF->(RecNo()),4)" OPERATION 8 ACCESS 0 // "Conhecimento"
	ADD OPTION aEntRelac TITLE STR0055 ACTION "CRMA200"         	 OPERATION 8 ACCESS 0 // "Privilégios"
EndIf
Return(aRotina)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA180INC()
Rotina para chamar a tela de inclusão das atividades
lCRM180CIn - Variavel para controlar a inserção de atividades, foi necessária porque
               após inserir um anexo na inserção de um novo email,o msdocument executa a rotina
               de inclusão novamente.
@param		ExpC1 - Alias da Entidade que será vinculada a atividade
		    ExpO1 - Modelo de Dados a ser utilizado
			ExpN1 - Tipo de Atividade que deverá ser aberta
@return	lRetorno
@author    Victor Bitencourt
@since		27/02/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMA180INC(cAlias, oMdlAux, nTpAtiv, cCodUsrPr)

Local aItems 	    := {STR0039,STR0038,STR0058} //"Compromisso"//"Tarefa"//"E-mail"
Local aDadosSX2   	:= {}
Local cUnico      	:= ""
Local oRadio 	    := Nil
Local oModel      	:= Nil
Local oView       	:= Nil
Local aSize	      	:= FWGetDialogSize( oMainWnd )
Local oPanel      	:= ""
Local cAliasVinc 	:= ""
Local nSaveSx8		:= GetSx8Len()

Local lAliasVinc  := .F. // Verifica se para este alias, atividade está disponivel
Local lRetorno    := .T.
Local lCancel     := .F.

Default cAlias    := ""
Default oMdlAux   := Nil
Default nTpAtiv   := 0
Default cCodUsrPr := ""

nCRM180MOp        := 0
nCRM180TAt        := 0

If Type("lCRM180CIn") == "U"
	lCRM180CIn := .T.
EndIf

If lCRM180CIn

	If nTpAtiv > 0
		nCRM180TAt := nTpAtiv
	Else
		//--------------------------------------------------------
		//	 Criando tela para escolha de Tipo de Atividades
		//--------------------------------------------------------
		oDlg := FWDialogModal():New()
			oDlg:SetBackground(.F.) // .T. -> escurece o fundo da janela
			oDlg:SetTitle(STR0040)//Tipo de Atividade
			oDlg:SetEscClose(.T.)//permite fechar a tela com o ESC
			oDlg:SetSize(080,110) //cria a tela maximizada (chamar sempre antes do CreateDialog)
			oDlg:EnableFormBar(.T.)

			oDlg:CreateDialog() //cria a janela (cria os paineis)
			oPanel := oDlg:getPanelMain()
			oDlg:createFormBar()//cria barra de botoes

			oRadio := TRadMenu():New (05,03,aItems,, oPanel ,,,,,,,,110,12,,,,.T.)
			oRadio:bSetGet := {|u|Iif (PCount()==0,nCRM180TAt,nCRM180TAt:=u)}

			oDlg:addYesNoButton()
		oDlg:activate()
		lRetorno := IIF(oDlg:getButtonSelected() > 0, .T., .F.)//pegando a resposta di usuario na tela
	EndIf

	//------------------------------------------------------------------------------------
	//	 Verificando se não foi enviado um model para ser usado, senão criar um proprio
	//------------------------------------------------------------------------------------
	If oMdlAux <> Nil .AND. ValType(oMdlAux) == "O"
		oModel := oMdlAux
	Else
		oModel := FWLoadModel("CRMA180")
		oModel:SetOperation(MODEL_OPERATION_INSERT)
	  	oModel:Activate()
	EndIf

	//----------------------------------------------
	//		Pegando o retorno da Tela/Tipo Atividade
	//----------------------------------------------
	If lRetorno .AND. nCRM180TAt > 0

		//Tratando a origem do Alias a ser utilizado para vincular a uma atividade.
		If !Empty(cAlias)
			 cAliasVinc := cAlias
		ElseIf Type("cCRM180AVc") == "C" .AND. !Empty(cCRM180AVc)
			 cAliasVinc := cCRM180AVc
		EndIF

		lAliasVinc := CRMXVLDENT( cAliasVinc, RATIVIDADE )// verificando se esse alias esta disponivel para ser vinculado com atividades
		oModel:GetModel("AOFMASTER"):SetValue("AOF_TIPO",cValToChar(nCRM180TAt))//Setando tipo de atividade no registro.
		nCRM180MOp  := MODEL_OPERATION_INSERT //setando a operação do model.

		//---------------------------------------------------
		//		Tratando a inclusão dos tipos de atividades
		//---------------------------------------------------
		Do Case
	     	Case nCRM180TAt == Val(TPEMAIL)

	     	 	oModel:lModify := .T. // Setando alteração manualmente

	  			oModel:GetModel("AOFMASTER"):SetValue("AOF_STATUS",STPENDENTE)// Inicia o email, com Status "Pendente"

	     	Case nCRM180TAt == Val(TPTAREFA) .OR. nCRM180TAt == Val(TPCOMPROMISSO)
	     	 	oModel:GetModel("AOFMASTER"):SetValue("AOF_STATUS",STNAOINICIADO)// Inicia a Atividade, com Status "Não Iniciado"

	    EndCase

	    //---------------------------------------------------
		//		Tratando o Vinculo de Entidades com Atividades
		//----------------------------------------------------
		/* Verificando se o Alias a se existe um alias a ser vinculado, e se está disponivel para ser vinculado com atividades.*/
		If lAliasVinc                                                                                                                                 .AND.;
		   !Empty(cAliasVinc)                                                                                                                         .AND.;
		   ( ( FunName() <> "CRMA180" .AND. ProcName(2) <> "CRM290ADTSK" .AND. ProcName(3) <> "CRMA290RFUN" .AND. ProcName(7) <> "CRMA290RFUN" ) .OR.;
		     ( FunName() == "CRMA180" .AND. IsInCallStack("MATA030") .AND. IsInCallStack("CRMA710") ) )

		 	oModel:GetModel("AOFMASTER"):SetValue("AOF_ENTIDA",cAliasVinc)// Vinculando Atividades a uma entidade.

		 	/*Protegendo a operação de vincular um registro especifico da entidade "cAliasVinc" somente quando
		 	chamado dessas chamadas "CRM250DTRA","CRMA250","Tk310Ativ" */
			If	!(IsInCallStack("CRM250DTRA") .OR. IsInCallStack("CRMA250")) .AND. !IsInCallStack("Tk310Ativ")
				/* operação para vincular um registro especifico da entidade passada "cAliasVinc"*/
				aDadosSX2  := CRMXGetSX2(cAliasVinc) 
				If !Empty(aDadosSX2)
					cUnico  := (cAliasVinc)->&(aDadosSX2[1])
					oModel:GetModel("AOFMASTER"):SetValue("AOF_CHAVE",cUnico)
					If	! Empty(cCodUsrPr)
						oModel:GetModel("AOFMASTER"):SetValue("AOF_CODUSR", cCodUsrPr)
					EndIf

					/*Tratando Casos especificos dos tipos de atividades */
					If nCRM180TAt == Val(TPEMAIL)
						Do Case
							Case cCRM180AVc == "SA1"
								oModel:GetModel("AOFMASTER"):SetValue("AOF_DESTIN",SA1->A1_EMAIL)
							Case cCRM180AVc == "ACH"
								oModel:GetModel("AOFMASTER"):SetValue("AOF_DESTIN",ACH->ACH_EMAIL)
							Case cCRM180AVc == "SUS"
								oModel:GetModel("AOFMASTER"):SetValue("AOF_DESTIN",SUS->US_EMAIL)
							Case cCRM180AVc == "SU5"
								oModel:GetModel("AOFMASTER"):SetValue("AOF_DESTIN",SU5->U5_EMAIL)
						EndCase
					EndIF
				EndIf
			EndIf
		EndIf

	    //-----------------------------------------------------------------
		//		Tratando a view que será aberta conforme o tipo de Atividade
		//------------------------------------------------------------------
		oView := FWLoadView("CRMA180")
		oView:SetModel(oModel)
		oView:SetOperation(MODEL_OPERATION_INSERT)

		oFWMVCWin := FWMVCWindow():New()
		oFWMVCWin:SetUseControlBar(.T.)

		oFWMVCWin:SetView(oView)
		oFWMVCWin:SetCentered(.T.)
		oFWMVCWin:SetPos(aSize[1],aSize[2])
		oFWMVCWin:SetSize(aSize[3],aSize[4])
		oFWMVCWin:SetTitle(STR0041)//"Incluir"
		oFWMVCWin:oView:BCloseOnOk := {||  lRetorno :=  .T. }
		oFWMVCWin:oView:oModel:BCancel := {|| lCancel := .T. }
		oFWMVCWin:Activate()

	EndIf
Else
	lCRM180CIn := .T.
EndIf

If lCancel
	DBSelectArea("AOF")
	lRetorno :=  .F.
	While ( GetSx8Len() > nSaveSx8 )
		RollBackSx8()
	End
EndIf

Return lRetorno

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA180ALT()

Rotina para chamar a tela de alteração das atividades

@param		Nenhum

@return	Nenhum

@author	Victor Bitencourt
@since		27/02/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMA180ALT()

Local cRemetente := SuperGetMV("MV_RELACNT",.F.,"")
Local oModel     := Nil
Local oView      := Nil
Local aSize	   := FWGetDialogSize( oMainWnd )	// Coordenadas da Dialog Principal.

If AOF->AOF_TIPO == TPEMAIL .AND. (AOF->AOF_STATUS == STENVIADO .OR. AOF->AOF_STATUS == STLIDO)

	Aviso(STR0074,STR0075,{STR0076})//"Atenção"//"Este email já foi enviado, Só está diponível para visualização/exclusão !"//"OK"

Else
	nCRM180MOp := 0
	nCRM180TAt := 0
	nCRM180TAt := Val(AOF->AOF_TIPO)

	oModel := FWLoadModel("CRMA180")
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()

	If nCRM180TAt == Val(TPEMAIL)
		oModel:lModify := .T.
	EndIf
	nCRM180MOp := MODEL_OPERATION_UPDATE // Setando a operação do model
	oView := FWLoadView("CRMA180")
	oView:SetModel(oModel)
	oView:SetOperation(MODEL_OPERATION_UPDATE)

	oFWMVCWin := FWMVCWindow():New()
	oFWMVCWin:SetUseControlBar(.T.)

	oFWMVCWin:SetView(oView)
	oFWMVCWin:SetCentered(.T.)
	oFWMVCWin:SetPos(aSize[1],aSize[2])
	oFWMVCWin:SetSize(aSize[3],aSize[4])
	oFWMVCWin:SetTitle(STR0042)//"Alterar"
	oFWMVCWin:oView:BCloseOnOk := {|| .T.  }

	If AOF->AOF_TIPO == TPEMAIL .AND. AOF->AOF_STATUS == STPENDENTE
		If Empty(AOF->AOF_DESTIN)
			Aviso(STR0074,STR0088,{STR0076})//"Atenção"//"O Email está com status de Pendente, por não possuir destinatário !"//"OK"
		ElseIf Empty(AOF->AOF_REMETE)
		    //--------------------------------------------------------------------------
			//  Caso Não Tenha Remetente cadastrado na Atividade, verificar se existe um
			//---------------------------------------------------------------------------
			aDadUsr := CRM170GetS(.T.)//Retornando dados do usuario crm
			If aDadUsr[3]// verifica se é usuario do exchange
				cRemetente := aDadUsr[_PREFIXO][_EndEmail]// pegando e-mail 
				If !Empty( cRemetente )
					oModel:GetModel("AOFMASTER"):SetValue("AOF_REMETE",cRemetente)// retorna o  email do usuario corrente 
				EndIf
			EndIf	
		Else
			Aviso(STR0074,STR0090,{STR0076})//"Atenção"//"O Email está com status de Pedente, Talvez por não possuir os parametros de envio de email configurados corretamente !"//"OK"
		EndIf
	EndIf
	oFWMVCWin:Activate()
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA180DEL()

Rotina para chamar a tela de exclusão das atividades

@param		Nenhum

@return	 	Nenhum

@author	Victor Bitencourt
@since		27/02/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMA180DEL()

Local oModel      := Nil
Local oView       := Nil
Local aSize       := FWGetDialogSize( oMainWnd )	// Coordenadas da Dialog Principal.

nCRM180MOp := 0
nCRM180TAt := 0
nCRM180TAt := Val(AOF->AOF_TIPO)

oModel := FWLoadModel("CRMA180")
oModel:SetOperation(MODEL_OPERATION_DELETE)
oModel:Activate()

nCRM180MOp := MODEL_OPERATION_DELETE

oView := FWLoadView("CRMA180")
oView:SetModel(oModel)
oView:SetOperation(MODEL_OPERATION_DELETE)

oFWMVCWin := FWMVCWindow():New()
oFWMVCWin:SetUseControlBar(.T.)

oFWMVCWin:SetView(oView)
oFWMVCWin:SetCentered(.T.)
oFWMVCWin:SetPos(aSize[1],aSize[2])
oFWMVCWin:SetSize(aSize[3],aSize[4])
oFWMVCWin:SetTitle(STR0043)//"Excluir"
oFWMVCWin:oView:BCloseOnOk := {|| .T.  }
oFWMVCWin:Activate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA180VIS()

Rotina para chamar a tela de visualização das atividades

@param		Nenhum

@return	 	Nenhum

@author	    Victor Bitencourt
@since		27/02/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMA180VIS()

Local oModel      := Nil
Local oView       := Nil
Local aSize       := FWGetDialogSize( oMainWnd )	// Coordenadas da Dialog Principal.

nCRM180MOp := 0
nCRM180TAt := 0
nCRM180TAt := Val(AOF->AOF_TIPO)

oModel := FWLoadModel("CRMA180")
oModel:SetOperation(MODEL_OPERATION_VIEW)
oModel:Activate()
nCRM180MOp := MODEL_OPERATION_VIEW

oView := FWLoadView("CRMA180")
oView:SetModel(oModel)
oView:SetOperation(MODEL_OPERATION_VIEW)

oFWMVCWin := FWMVCWindow():New()
oFWMVCWin:SetUseControlBar(.T.)

oFWMVCWin:SetView(oView)
oFWMVCWin:SetCentered(.T.)
oFWMVCWin:SetPos(aSize[1],aSize[2])
oFWMVCWin:SetSize(aSize[3],aSize[4])
oFWMVCWin:SetTitle(STR0044)//"Visualizar"
oFWMVCWin:oView:BCloseOnOk := {|| .T.  }
oFWMVCWin:Activate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA180MTS

Cria a tela de Status de sincronização dentro da janela indicada

@sample	CRMA180MTS()

@param		ExpO1 = Representa o Painel que a tela de sincronização deverá ser criada

@return	Nenhum

@author	Victor Bitencourt
@since		19/02/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMA180MTS(oPanel)

Local cData 	    := ""
Local cHora 	    := ""
Local cMensagem   := ""
Local cStatus	    := ""
Local oTimer 	    := Nil
Local oGetStatus  := Nil
Local oData 	    := Nil
Local oGetData    := Nil
Local oGetHora    := Nil
Local oStatus     := Nil
Local oButton     := Nil
Local oWndSinc    := Nil

// Sincronização
DEFINE FONT oTFont
oTFont:= TFont():New("Arial",,15,.T.,.T.)

oFwLayer := FwLayer():New()
oFwLayer:init(oPanel,.F.)

oFwLayer:addCollumn( "COL1",100, .T. , "LINHA1")
oFwLayer:addWindow( "COL1", "WIN1", STR0045, 100, .F., .F., , "LINHA1")	//"Dados da ultima Sincronização"

oWndSinc := oFwLayer:GetWinPanel("COL1","WIN1","LINHA1")

@ 015, 008 SAY oData PROMPT STR0046  COLOR CLR_BLUE SIZE 025, 007 PIXEL OF oWndSinc //"Data/Hora"
@ 015, 043 MSGET oGetData VAR cData COLOR CLR_BLUE SIZE 040, 010 PIXEL OF oWndSinc
oGetData:Disable()
@ 015, 088 MSGET oGetHora VAR cHora SIZE 034, 010 OF oWndSinc  PIXEL
oGetHora:Disable()
@ 032, 008 SAY oStatus PROMPT STR0047  COLOR CLR_BLUE SIZE 035, 007 OF oWndSinc  PIXEL //"Status"
@ 030, 043 MSGET oGetStatus VAR cStatus SIZE 040, 010 OF oWndSinc  PIXEL
oGetStatus:Disable()
@ 030, 088 BUTTON oButton PROMPT  STR0048	 SIZE 034, 013 ACTION (FT320MsgRetorno(cStatus,cMensagem))OF oWndSinc PIXEL //"Detalhes"

oTimer := TTimer():New(20000,{|| CRM180BRefresh(@cStatus, @cMensagem, @cData, @cHora , oGetStatus , oGetData, oGetHora )  } , oPanel:oWnd )
oTimer:Activate()

// para carregar a primeira vez somente....as demais será chamado pelo componente TTimer.
CRM180BRefresh(@cStatus, @cMensagem, @cData, @cHora , oGetStatus , oGetData, oGetHora )

Return

//----------------------------------------------------------
/*/{Protheus.doc} ModelCommit()

Validação dos Dados , após dar o Commit no model.. verifica qual a operação
que estava sendo realizada , para poder enviar os dados para o exchange

@param	  ExpO1 = oModel .. objeto do modelo de dados corrente.

@return  .T.

@author   Victor Bitencourt
@since    26/02/2014
@version  12.0
/*/
//----------------------------------------------------------
Static Function ModelCommit(oModel)

Local aArea			:= GetArea()
Local aAnexo		:= {}
Local aInfoSinc 	:= {}
Local cURL      	:= ""
Local cUser         := ""
Local cPass         := ""
Local cBody         := ""
Local cTag          := ""
Local cRemetente    := SuperGetMV("MV_RELACNT",.F.,"")
Local cToken        := ""
Local cFil          := cFilAnt
Local cEmp          := cEmpAnt
Local nOperation    := oModel:GetModel("AOFMASTER"):GetOperation()
Local cTipoAtiv     := oModel:GetModel("AOFMASTER"):GetValue("AOF_TIPO")
Local nDuracao      := 0
Local aDadUsr       := {}
Local cServRec      := SuperGetMv("MV_CRMEMAL",,"")
Local bInTTS		:= {|oModel| CRMA180InTTS(oModel, "") }
Local cUserAnt		:= AOF->AOF_CODUSR
Local cUserAtu		:= oModel:GetModel("AOFMASTER"):GetValue("AOF_CODUSR")

If Type("lCRM180Aut") == "U"
	lCRM180Aut := .F.
EndIf

//------------------------------------------------
//		Ações Antes de efetuar o Commit no Model
//------------------------------------------------
Do Case
	Case cTipoAtiv == TPEMAIL

		If nOperation <> MODEL_OPERATION_DELETE

			aDadUsr := CRM170GetS(.T.)//Retornando dados do usuario crm
			If aDadUsr[3] .And. !Empty( aDadUsr[_PREFIXO][_Usuario] )// verifica se é usuario do exchange
				cRemetente := aDadUsr[_PREFIXO][_EndEmail]
			EndIf

			cToken := FwUuId(FwFldGet("AOF_CODIGO"))//Gerando o Token para o e-mail, somente na inserção
			oModel:GetModel("AOFMASTER"):SetValue("AOF_TOKEN" ,cToken )
			oModel:GetModel("AOFMASTER"):SetValue("AOF_DTINIC",FwFldGet("AOF_DTCAD"))
			oModel:GetModel("AOFMASTER"):SetValue("AOF_DTFIM" ,FwFldGet("AOF_DTCAD"))
			oModel:GetModel("AOFMASTER"):SetValue("AOF_REMETE",cRemetente)// retorna o  email do usuario corrente			   		


			If Type("oCRM180GET") == "O" .AND. Type("oCRM180EHT") == "O"// Verificando objetos da tela de e-mail
				oModel:GetModel("AOFMASTER"):SetValue("AOF_ASSUNT",oCRM180GET:cText)
				cBody := oCRM180EHT:GetText() 
			Else
				oModel:GetModel("AOFMASTER"):SetValue("AOF_ASSUNT",FwFldGet("AOF_ASSUNT"))
				cBody := FwFldGet("AOF_DESCRI")
			EndIf

			If nOperation == MODEL_OPERATION_UPDATE // verificando operação do model, para evitar de criar outro Id para o e-mail
				cToken := AOF->AOF_TOKEN
			EndIf

			If At( "CRM170READ.apl", cBody ) <= 0 .AND. !Empty(FwFldget("AOF_DESTIN")) .AND. !Empty(cServRec)
				cFil := StrTran (cFil ," ", "@")
				cTag :='<img src="'+cServRec+'/CRM170READ.apl?'+cFil+'!'+cEmp+'!'+AllTrim(cToken)+'" height="1" width="1"  >'
				cBody := CRMA170ddT(cBody, cTag) //Adicionando a Tag criado no corpo do e-mail
			EndIf

			//---------------------------------------
			//		Tratando as imagens do e-mail
			//---------------------------------------
			If Empty(FwFldget("AOF_LNKIMG")) .AND. !lCRM180Aut // Verificando se já existe mapeamento de links para este e-mail, senão for rotina automatica.
				// Rotina para Ler e retornar o xml de mapeamento
				oModel:GetModel("AOFMASTER"):SetValue("AOF_LNKIMG",CRMA170LMG(cBody,.T.) )
			EndIf

			//--------------------------------------------------------------
			//		Verificando se a chamda é de uma distribuição de e-mail
			//--------------------------------------------------------------
			If IsInCallStack("CRM250DTRA").OR.IsInCallStack("Tk310Ativ")// caso seja distribuição de e-mails de campanhas rapidas ou campanhas
				If Type("cCRM180CRA") == "C" .AND. Empty(cCRM180CRA)
				cBody := CRMA170Lnk( cBody, .T., /*lEnvia*/, lCRM180Aut, .F.) //fazendo a troca dos endereços locais por codigos rastreaveis
				ElseIf Type("cCRM180CRA") == "C"
					cBody := CRMA170Lnk( cBody, /*lGrava*/, /*lEnvia*/, lCRM180Aut, .T., cCRM180CRA) //fazendo a troca dos endereços locais por codigos rastreaveis
				EndIf
				cCRM180CRA := "" //Limpando a variavel, após usa-la
			Else
				cBody := CRMA170Lnk( cBody, .T., /*lEnvia*/, lCRM180Aut, .F.) //fazendo a troca dos endereços locais por codigos rastreaveis
			EndIf

			//---------------------------------------
			//		Atribuindo o cBody no Model
			//---------------------------------------
			oModel:GetModel("AOFMASTER"):SetValue("AOF_DESCRI",cBody)//oModel:GetModel("AOFMASTER"):SetValue("AOF_DESCRI",CRMA170Lnk(oCRM180EHT:GetText(),.T.))
		EndIf
	Case cTipoAtiv == TPTAREFA	.OR. cTipoAtiv == TPCOMPROMISSO
		If nOperation <> MODEL_OPERATION_DELETE
			If !Empty(FwFldget("AOF_DTINIC")) .AND. !Empty(FwFldget("AOF_DTFIM"))
					nDuracao := CRM170CAHR( FwFldget("AOF_DTINIC"),FwFldget("AOF_HRINIC"),FwFldget("AOF_DTFIM"),FwFldget("AOF_HRFIM"))
				oModel:GetModel("AOFMASTER"):SetValue("AOF_DURACA",nDuracao)
			EndIf
		Endif
EndCase

//---------------------------
//		Commit no Model
//---------------------------
If cUserAnt <> cUserAtu
	bInTTS := {|oModel| CRMA180InTTS(oModel, cUserAnt) }
EndIf
FWFormcommit(oModel,/*bBefore*/,/*bAfter*/,/*bAfterSTTS*/,bInTTS) //Salvando os Dados do Formulario.
//------------------------------------------------
//		Ações Depois de efetuar o Commit no Model
//------------------------------------------------
Do Case
	Case cTipoAtiv == TPEMAIL

		// Gravando os anexos do e-mail quando esse modelo de email que possui anexos (Rotina automática)
		If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .AND. Type("aCRM180ANX") == "A" .AND. !Empty(aCRM180ANX)
			GravaAnexo(AOF->AOF_CODIGO)
		EndIf

		//Gravando os anexos do email quando não é rotina automatica e foi adicionado no formulario de e-mail
		If	nOperation == MODEL_OPERATION_INSERT .AND. AOF->AOF_ANEXO == "1" .AND. !lCRM180Aut
			If MsDocument('AOF', AOF->(RecNo()),4)
				lCRM180CIn := .F.
			EndIf
		EndIF

		If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .AND.  AOF->AOF_STATUS == STPENDENTE .AND. !Empty(AOF->AOF_DESTIN)// verificando o status do e-mail

			aDadUsr  := CRM170GetS(.T.)// Retorna alguns dados do usuario do crm
			If aDadUsr[3]
		 		cUser  := aDadUsr[_PREFIXO][_Usuario]
		 		cPass  := aDadUsr[_PREFIXO][_SenhaUser]
			EndIf
			// Enviando e-mail
			cBody := CRMA170Lnk(AOF->AOF_DESCRI,.F.,.T.,,,, @aAnexo)			
			If CRMXEnvMail(AOF->AOF_REMETE,AOF->AOF_DESTIN,AOF->AOF_PARTIC,"",AOF->AOF_ASSUNT, cBody,"AOF",AOF->AOF_CODIGO,lCRM180Aut,cUser,cPass, aAnexo)
				CRM170ATLS(AOF->AOF_CODIGO,STENVIADO)// atualiza status do e-mail
			EndIf

		EndIf

	Case cTipoAtiv == TPTAREFA .OR. cTipoAtiv == TPCOMPROMISSO

		//------------------------------------
		//		INTEGRACAO COM EXCHANGE
		//------------------------------------
		If Type("lCRM180Aut") == "L" .AND. !lCRM180Aut // Validação para ver se não for automatica (ExecAuto), e verificar se as atividade a ser sincronizada é um tarefa ou compromisso
			aInfoSinc := CRM170GetS(.T.)
			If aInfoSinc[_LCRMUSR] .AND. aInfoSinc[_PREFIXO][_Habilita]// Verifica se é um usuario do CRM e se está a habilitado para sic. automatica
				cURL := CRM170UrlE() //retorna a url de integração com exchange
				Do Case
			 		Case nOperation == MODEL_OPERATION_DELETE
							CRM170ATLZ( aInfoSinc, cURL, "D", .T.)
					Case nOperation == MODEL_OPERATION_INSERT
							CRM170ATLZ( aInfoSinc, cURL, "A", .T.)
					Case nOperation == MODEL_OPERATION_UPDATE
							CRM170ATLZ( aInfoSinc, cURL, "A", .T.)
				EndCase
			EndIf
		EndIf
EndCase

RestArea(aArea)

Return (.T.)

//----------------------------------------------------------
/*/{Protheus.doc} CRM180BRefresh()

Função para atualizar os dados da janela de sincronização .....

@param	  ExpC1 = Variavel que ira receber o status da sincronização
		  ExpC2 = Variavel que recebera a mensagems que sicronização irá retornar , somente se houver erro
		  ExpC3 = Variavel que recebera a ultima data de sincronização
		  ExpC4 = Variavel que recebera a ultima hora de sincronização
		  ExpO1 = Objeto Status da janela de sincronização
		  ExpO2 = Objeto de data da janela de sincronização
		  ExpO3 = Objeto de Hora da janela de sincronização

@return  Nenhum

@author   Victor Bitencourt
@since    26/02/2014
@version  12.0
/*/
//----------------------------------------------------------
 Static Function CRM180BRefresh(cStatus,cMensagem ,cData, cHora, oGetStatus, oGetData, oGetHora)

Local aSyncState := {}

If FindFunction("GetSyncState")
	aSyncState := GetSyncState(cValToChar(ThreadId()))
EndIf

If ValType(aSyncState) == "A" .AND. Len(aSyncState) > 0

	If 	aSyncState[1] == 1
		cStatus     := STR0049  //"Parado"
		cMensagem   := aSyncState[2]
	ElseIf aSyncState[1] == 2
		cStatus     := STR0050  //"Sincronizando"
		cMensagem   := aSyncState[2]
	ElseIf aSyncState[1] == 3
		cStatus     := STR0051  //"Erro"
		cMensagem   := aSyncState[2]
	ElseIf aSyncState[1] == 4
		cStatus     := STR0052  //"Sincronizado"
		cMensagem   := aSyncState[2]
	EndIf

	If Len(aSyncState) > 3
		If ValType(aSyncState[3]) == "D"
			cData := DToC(aSyncState[3])
		EndIf
		cHora := aSyncState[4]
	EndIf

	If oGetHora <> Nil 	// validação caso o Objeto venha com Nil
		oGetHora:Refresh()
		oGetData:Refresh()
		oGetStatus:Refresh()
	EndIf

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA180VRA

 Função para Verificar Anexo, Atualizar o campo anexo para "sim", caso exista anexo para o registro.

@param	  ExpC1 - Alias da Entidade que possuie Anexo
		  ExpC2 - Codigo da entidade(Chave unica de relacionamento na AC9, para buscar o Registro que possue anexo).

@return  Nenhum

@author  Victor Bitencourt
@since	  18/03/2014
@version 12.0
/*/
//-------------------------------------------------------------------
Function CRMA180VRA(cAlias,cCodigo,cCodPesq)

Local nNum 	   := 0
Local nOperation := 0
Local oModel     := FWModelActive()
Local aAreaAOF   := {}
Local cModel     := cAlias+"MASTER"
Local cCampo     := cAlias+"_ANEXO"

If !Empty(cAlias)

	If Select(cAlias) > 0
		aAreaAOF := (cAlias)->(GetArea())
	Else
		DbSelectArea(cAlias)// Tabela dinâmica pode variar entre AOF/AO6 -- ATividades/Modelo de email
	EndIf
	(cAlias)->(DbSetOrder(1))// indice dinâmico pode variar entre AOF/AO6

	BeginSql Alias "TMPALIAS"
	SELECT
		ACB.ACB_OBJETO
	FROM
		%Table:AC9% AC9 INNER JOIN %Table:ACB% ACB ON (ACB.ACB_CODOBJ = AC9_CODOBJ)
	WHERE
		AC9.AC9_FILIAL = %xFilial:AC9%              AND
		AC9.AC9_ENTIDA = %exp:cAlias%      		  AND
		AC9.AC9_FILENT = %exp:xFilial(cAlias)%      AND
       AC9.AC9_CODENT = %exp:cCodPesq%             AND
       AC9.%NotDel%
	EndSql

    While TMPALIAS->(!Eof())
   		nNum += 1
     	TMPALIAS->(DbSkip())
    EndDo
	TMPALIAS->(DbCloseArea())
	If ValType(oModel) == "O"
		nOperation := oModel:GetModel(cModel):GetOperation()
		If nOperation == MODEL_OPERATION_UPDATE
			If (cAlias)->(DbSeek(xFilial(cAlias)+cCodigo))
				If nNum > 0
					RecLock(cAlias,.F.)// foi necessário atualizar dessa forma porque o mvc não enterpretava a alteração
					(cAlias)->&(cCampo) := "1"
					(cAlias)->(MsUnlock())
					oModel:GetModel(cModel):SetValue(cCampo,"1")// para atualizar o status na View
				Else
					RecLock(cAlias,.F.)// foi necessário atualizar dessa forma porque o mvc não enterpretava a alteração
					(cAlias)->&(cCampo) := "2"
					(cAlias)->(MsUnlock())
					oModel:GetModel(cModel):SetValue(cCampo,"2")// para atualizar o status na View
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If !Empty(aAreaAOF)
	RestArea(aAreaAOF)
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ReenviaEmail

 Função para Reenviar emails manualmente...
 o registro deverá estar posicionado para que a rotina funcione corretamente.

@param	  Nenhum

@return  Nenhum

@author  Victor Bitencourt
@since	  20/03/2014
@version 12.0
/*/
//-------------------------------------------------------------------
Static Function ReenviaEmail()

Local oPanel   := Nil
Local oDlg     := Nil

Local aDadUsr  := CRM170GetS(.T.) // Retorna alguns dados do usuario do crm

Local cUser    := ""
Local cPass    := ""

//------------------------------------------------
//		Criando DialogModal
//------------------------------------------------
oDlg := FWDialogModal():New()
oDlg:SetBackground(.F.) // .T. -> escurece o fundo da janela
oDlg:SetTitle(STR0070)//"Reenviar E-mail"
oDlg:SetEscClose(.T.)//permite fechar a tela com o ESC
oDlg:SetSize(080,120) //cria a tela maximizada (chamar sempre antes do CreateDialog)
oDlg:EnableFormBar(.T.)

oDlg:CreateDialog() //cria a janela (cria os paineis)
oPanel := oDlg:getPanelMain()
oDlg:createFormBar()//cria barra de botoes

@ 010, 010 SAY oTitulo2 PROMPT STR0077 SIZE 120,009  OF oPanel PIXEL//"Deseja realmente reenviar o e-mail ?"

oDlg:addYesNoButton()

oDlg:activate()

If  oDlg:getButtonSelected() > 0
	If aDadUsr[3]
		 cUser  := aDadUsr[_PREFIXO][_Usuario]
		 cPass  := aDadUsr[_PREFIXO][_SenhaUser]
	EndIf
	If CRMXEnvMail(AOF->AOF_REMETE,AOF->AOF_DESTIN,AOF->AOF_PARTIC,"",AOF->AOF_ASSUNT,CRMA170Lnk(AOF->AOF_DESCRI,.F.,.T.),"AOF",AOF->AOF_CODIGO,.F.,cUser,cPass)
		CRM170ATLS(AOF->AOF_CODIGO,STENVIADO)//atualiza status da atividade
		Aviso(STR0074,STR0116,{STR0076})//"Atenção"//"E-mail enviado com sucesso !"//"OK"
	Else
		CRM170ATLS(AOF->AOF_CODIGO,STPENDENTE)//atualiza status da atividade
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FilStatusAtiv

Rotina que filtra o browse pelo status da atividade

@param oBrowse, objeto de browse para ser manipulado conforme o filtro
@param cComboSTA, opção escolhida no combo box para ser filtrada

@return  Nenhum

@author  Victor Bitencourt
@since	  21/03/2014
@version 12.0
/*/
//-------------------------------------------------------------------
Static Function FilStatusAtiv(oMBrowse, cComboSTA)

oMBrowse:DeleteFilter("FIL_STATIV")
If cComboSTA <> "0"
	oMBrowse:AddFilter(STR0078,"AOF_STATUS == '" + cComboSTA + "'" ,.T.,.T.,,,,"FIL_STATIV")//"Filtro status Atividade"
EndIf
oMBrowse:ExecuteFilter()
oMBrowse:Refresh(.T.)

Return

//------------------------------------------------------------------------------

/*/{Protheus.doc} FilCGC()

Rotina que filtra o browse pelo CNPJ ou CPF da atividade

@param oBrowse, objeto de browse para ser manipulado conforme o filtro
@param cComboSTA, opção escolhida no combo box para ser filtrada

@return  Nenhum

@author  Philip Pellegrini
@since	  19/06/2015
@version 12.0
/*/
//-------------------------------------------------------------------
Static Function FilCGC(oMBrowse, cGetCGC)

Local lFiltro    := .F. // Caso não seja encontrado nenhuma entidade com o CGC, não mostra nada no filtro
Local cFiltro    := "" //Variável que vai receber as instruções para filtro
Local aArea      := {}
Local aAreaACH   := {}
Local aAreaSUS   := {}
Local aAreaSA1   := {}
Local aAreaSA2   := {}
Local aAreaSA3   := {}

oMBrowse:DeleteFilter("FIL_CGC")
If ! Empty(cGetCGC)

	aArea      := GetArea()
	aAreaACH   := ACH->(GetArea())
	aAreaSUS   := SUS->(GetArea())
	aAreaSA1   := SA1->(GetArea())
	aAreaSA2   := SA2->(GetArea())
	aAreaSA3   := SA3->(GetArea())

	//DbSeek em todas as entidades possíveis utilizando o CGC
	//Suspects
	DbSelectArea("ACH")
	ACH->(DbSetOrder(2)) //ACH_FILIAL+ACH_CGC

	If ACH->(DbSeek(xFilial("ACH")+cGetCGC))
		While ! ACH->(Eof()).And. Alltrim(ACH->ACH_CGC) == Alltrim(cGetCGC)
			If !Empty(cFiltro)
				cFiltro += " .Or. AOF_CHAVE == "+"'"+ACH->ACH_CODIGO + ACH->ACH_LOJA+"'"
			Else
				cFiltro += " AOF_CHAVE == "+"'"+ACH->ACH_CODIGO + ACH->ACH_LOJA+"'"
			Endif
			ACH->(DbSkip())
		Enddo
		lFiltro := .T.
	ENDIF


	//Prospects
	DbSelectArea("SUS")
	SUS->(DbSetOrder(4)) //SUS_FILIAL+SUS_CGC

	If SUS->(DbSeek(xFilial("SUS")+cGetCGC))
		While ! SUS->(Eof()) .And. Alltrim(SUS->US_CGC) == Alltrim(cGetCGC)
			If !Empty(cFiltro)
				cFiltro += " .Or. AOF_CHAVE == "+"'"+SUS->US_COD + SUS->US_LOJA+"'"
			Else
				cFiltro += " AOF_CHAVE == "+"'"+SUS->US_COD + SUS->US_LOJA+"'"
			Endif
			SUS->(DbSkip())
		Enddo
		lFiltro := .T.
	ENDIF

	
	//Clientes
	DbSelectArea("SA1")
	SA1->(DbSetOrder(3)) //SA1_FILIAL+SA1_CGC

	If SA1->(DbSeek(xFilial("SA1")+cGetCGC))
		While ! SA1->(Eof()) .And. Alltrim(SA1->A1_CGC) == Alltrim(cGetCGC)
			If !Empty(cFiltro)
				cFiltro += " .Or. AOF_CHAVE == "+"'"+SA1->A1_COD + SA1->A1_LOJA+"'"
			Else
				cFiltro += " AOF_CHAVE == "+"'"+SA1->A1_COD + SA1->A1_LOJA+"'"
			Endif
			SA1->(DbSkip())
		Enddo
		lFiltro := .T.
	ENDIF

	//Fornecedores
	DbSelectArea("SA2")
	SA2->(DbSetOrder(3)) //SUS_FILIAL+SUS_CGC

	If SA2->(DbSeek(xFilial("SA2")+cGetCGC))
		While ! SA2->(Eof()) .And. Alltrim(SA2->A2_CGC) == Alltrim(cGetCGC)
			If !Empty(cFiltro)
				cFiltro += " .Or. AOF_CHAVE == "+"'"+SA2->A2_COD + SA2->A2_LOJA+"'"
			Else
				cFiltro += " AOF_CHAVE == "+"'"+SA2->A2_COD + SA2->A2_LOJA+"'"
			Endif
			SA2->(DbSkip())
		Enddo
		lFiltro := .T.
	ENDIF

	SA2->(DbCloseArea())

	//Vendedores
	DbSelectArea("SA3")
	SA3->(DbSetOrder(3)) //SUS_FILIAL+SUS_CGC

	If SA3->(DbSeek(xFilial("SA3")+cGetCGC))
		While ! SA3->(Eof()) .And. Alltrim(SA3->A3_CGC) == Alltrim(cGetCGC)
			If !Empty(cFiltro)
				cFiltro += " .Or. AOF_CHAVE == "+"'"+SA3->A3_COD +"'"
			Else
				cFiltro += " AOF_CHAVE == "+"'"+SA3->A3_COD + "'"
			Endif
			SA3->(DbSkip())
		Enddo
		lFiltro := .T.
	ENDIF

	RestArea(aAreaSA3)
	RestArea(aAreaACH)
	RestArea(aAreaSUS)
	RestArea(aAreaSA1)
	RestArea(aAreaSA2)
	RestArea(aArea)	
		
	//Caso o CNJP não seja encontrado, o filtro fica vazio 
	If !(lFiltro)
		cFiltro = "AOF_CHAVE == '***'"
	Endif

	oMBrowse:AddFilter(STR0124, cFiltro,.T.,.T.,,,,"FIL_CGC")
	oMBrowse:ExecuteFilter()
	oMBrowse:Refresh(.T.)
Endif

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MntEdHTML()

Rotina para montar em uma janela determinada o Editor de Html

@param	  	ExpO1 = Objeto da janela onde será criado o Editor de Html

@return   	Nil

@author	Victor Bitencourt
@since		27/03/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Static Function MntEdHTML( oPanel )

Local cAssunto    := Space(60)
Local oFwLayer    := Nil
Local oLayerInte  := Nil
Local oLayerMark  := Nil
Local oLINEONE    := Nil
Local oLINETWO    := Nil
Local oTitulo     := Nil
Local lVisual     := .T. //variavel que indica se é visual ou editavel o Editor de HTML

If Type("lCRM180Aut") == "U"
	lCRM180Aut := .F.
EndIf

oFwLayer   := FwLayer():New()// Layer do ComboBox
oLayerInte := FwLayer():New()// Layer onde acontece a divisão em 3 partes, para adicionar os tres componentes.
oLayerMark := FwLayer():New()// Layer do FwBrose

oFwLayer:init(oPanel,.F.)

oFWLayer:addCollumn( "COL1",100, .F. ,"LINHA" )

oCOLLONE := oFwLayer:getColPanel("COL1","LINHA")
oLayerInte:init(oCOLLONE,.F.)

oLayerInte:AddLine("LINEONE" ,17,.F.)
oLayerInte:AddLine("LINETWO" ,83,.F.)

oLINEONE := oLayerInte:GetLinePanel("LINEONE")
oLINETWO := oLayerInte:GetLinePanel("LINETWO")

If  nCRM180MOp == MODEL_OPERATION_INSERT .OR. nCRM180MOp == MODEL_OPERATION_UPDATE
	lVisual := .F.
EndIf

oCRM180EHT := FWSimpEdit():New( 0, 0, 500,1000, STR0078,,,.F.,.F. , oLINETWO,lVisual)//"Editor HTML"

@ 00,06 SAY oTitulo PROMPT STR0085 SIZE 120,009  OF oLINEONE PIXEL//"Assunto"
@ 08, 06 MSGET oCRM180GET VAR cAssunto SIZE 172, 010 PIXEL OF oLINEONE

If nCRM180MOp <> MODEL_OPERATION_INSERT // Verificando a operação do model para carregar o conteudo do Html
	If nCRM180MOp <> MODEL_OPERATION_UPDATE
		oCRM180GET:Disable()
	EndIf
	oCRM180EHT:SetText(CRMA170CRG(AOF->AOF_DESCRI,lCRM180Aut))//Carregando o email no objeto
	oCRM180GET:cText := AOF->AOF_ASSUNT
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetModEmail()

Rotina para pegar o modelo de email que será utilizado

@param	  	ExpO1 = Modelo de dados Atividades

@return   	Nenhum

@author	Victor Bitencourt
@since		03/04/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Static Function GetModEmail(oModel)

Local   cAlias      := FwFldGet("AOF_ENTIDA")
Local   cUnico      := FwFldGet("AOF_CHAVE")
Local   aCampos     := {}

Local   oDlg        := Nil
Local 	 oColEnt     := Nil
Local   oPanel      := Nil
Local 	 oFWLayer    := Nil
Local   oBrwMark    := Nil
Local 	 oLINEONE    := Nil
Local   oLINETWO    := Nil

Do Case
	Case Empty(cAlias) .AND. FunName() == "CRMA180"
		Aviso(STR0074,STR0080,{STR0076},2)//"Atenção"//"Para poder utilizar um modelo de email, É necessário relacionar este email há uma entidade !"//"OK"
	Case Empty(cUnico) .AND. FunName() == "CRMA180"
		Aviso(STR0074,STR0081,{STR0076},2)//"Atenção"//"Para poder utilizar um modelo de email, É necessário relacionar este email há um registro !"//"OK"
	OtherWise
		//------------------------------------------------
		//		Criando DialogModal
		//------------------------------------------------
		oDlg := FWDialogModal():New()

			oDlg:SetBackground(.F.) // .T. -> escurece o fundo da janela
			oDlg:SetTitle(STR0082)//"Modelos de Email"
			oDlg:SetEscClose(.T.)//permite fechar a tela com o ESC
			oDlg:SetSize(270,400) //cria a tela maximizada (chamar sempre antes do CreateDialog)
			oDlg:EnableFormBar(.T.)

			oDlg:CreateDialog() //cria a janela (cria os paineis)
			oPanel := oDlg:getPanelMain()

			oDlg:createFormBar()//cria barra de botoes

		 	CrgModEmail(@aCampos,oBrwMark,cAlias)
			oFwLayer := FwLayer():New()
			oFwLayer:init(oPanel,.F.)
			oFWLayer:AddLine( "LINEONE",90, .F.)
			oFWLayer:AddLine( "LINETWO",10, .F.)
			oLINEONE := oFwLayer:GetLinePanel("LINEONE")
			oLINETWO := oFwLayer:GetLinePanel("LINETWO")

		    DEFINE FWBROWSE oBrwMark  DATA ARRAY ARRAY aCampos LINE BEGIN 1 OF oLINEONE
				ADD COLUMN oColEnt DATA &("{ || aCampos[oBrwMark:At()][1] }") TITLE STR0084 TYPE "C" SIZE 20 OF oBrwMark//"Titulo"
				ADD COLUMN oColEnt DATA &("{ || aCampos[oBrwMark:At()][2] }") TITLE STR0085 TYPE "C" SIZE 30 OF oBrwMark//"Assunto"
			ACTIVATE FWBROWSE oBrwMark

			//adiciona botoes
			If (FunName() <> "TMKA061" .AND. FunName() <> "CRMA350" .AND. FunName() <> "CRMA250")
				oDlg:AddButton( STR0092, {|| VisModEmail(oBrwMark,aCampos,cAlias)}, STR0092, , .T., .F., .T., )//"Pré-Visualizar"
			EndIf
			oDlg:AddButton( STR0041,{|| CRMA230(cAlias,3),CrgModEmail(aCampos,oBrwMark,cAlias) }, STR0041, , .T., .F., .T., )//"Incluir"
			oDlg:AddButton( STR0076,{|| UtlzEmail(oBrwMark,aCampos,oModel),oDlg:Deactivate() }, STR0076, , .T., .F., .T., )//Ok
			oDlg:addCloseButton()

		oDlg:activate()
EndCase

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CrgModEmail()

Rotina para Carregar todos os modelos de email para o alias especificado

@param	  	ExpA1 = Array contendo os registro do browse
			ExpO1 = Objeto do browse que será manipulado
			ExpC1 = Alias da Entidade

@return   	Nenhum

@author	Victor Bitencourt
@since		03/04/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Static Function CrgModEmail(aCampos,oBrwMark,cAlias)

Local 	 aAreaAO6  := {}

Default oBrwMark  := Nil
Default cAlias    := ""

aCampos   := {}

If Select("AO6") > 0
	aAreaAO6 := AO6->(GetArea())
Else
	DbSelectArea("AO6")//Modelo de Email
EndIf
AO6->(DbSetOrder(2)) //AO6_FILIAL+AO6_CODENT+AO6_CODMOD

If AO6->(DbSeek(xFilial("AO6")+cAlias))
	Do While AO6->(!EOF()) .AND. AO6->AO6_ENTMOD == cAlias
		AAdd( aCampos,{AO6->AO6_TITULO,AO6->AO6_ASSUNT,AO6->AO6_CODMOD})
		AO6->( DbSkip())
	EndDo
EndIf

If ValType(oBrwMark) == "O"
	oBrwMark:SetArray(aCampos)
	oBrwMark:Refresh(.T.)
EndIf

If !Empty(aAreaAO6)
	RestArea(aAreaAO6)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} UtlzEmail()

Rotina para pegar o modelo de email que será utilizado, atribuir o modelo de email
já mesclado no EditorHTML

@param	  	ExpO1 = Objeto do browse que será manipulado
			ExpA1 = Array contendo os registro do browse
			ExpO1 = Modelo de dados a ser alterado

@return   	Nenhum

@author	Victor Bitencourt
@since		03/04/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Static Function UtlzEmail(oBrwMark,aCampos,oModel)

Local cBodyMesc  := ""
Local cCodMod    := ""
Local cAlias     := "AO6" //Alias Da tabela onde Existem os modelos de Email

Local aAreaAO6   := {}
Local aAreaAC9   := {}

Default aCampos  := {}
Default oBrwMark := Nil

If Type("aCRM180ANX") == "U"
	aCRM180ANX := {}
EndIf

If ValType(oBrwMark) == "O" .AND. !Empty(aCampos) .AND. Type("oCRM180EHT") == "O"

	Asize( aCRM180ANX, 0)

	If Select("AO6") > 0
		aAreaAO6 := AO6->(GetArea())
	Else
		DbSelectArea("AO6")//Modelo de Email
	EndIf
	AO6->(DbSetOrder(1)) //AO6_FILIAL+AO6_CODMOD

	If Select("AC9") > 0
		aAreaAC9 := AC9->(GetArea())
	Else
		DbSelectArea("AC9")//RELACAO DE OBJETOS X ENTIDADES
	EndIf
	AC9->(DbSetOrder(1)) //AC9_FILIAL+AC9_CODOBJ+AC9_ENTIDA+AC9_FILENT+AC9_CODENT

	cCodMod := aCampos[oBrwMark:At()][3]

	If AO6->(DbSeek(xFilial(cAlias)+cCodMod))

		If IsInCallStack("Tk310Ativ") .OR. IsInCallStack("CRMA250") //verificando se a chamada é de Campanhas ou de Campanhas rapidas
			cBodyMesc := AO6->AO6_MENSAG
		Else
          cBodyMesc := CRM170MEEM(AO6->AO6_MENSAG,AO6->AO6_ENTMOD)
		EndIf
		oCRM180EHT:SetText(CRMA170CRG(cBodyMesc,.F.,.T.))
		oModel:GetModel("AOFMASTER"):SetValue("AOF_LNKIMG",AO6->AO6_LNKIMG)// Tratar imagens do Modelo de E-mail
		oCRM180GET:cText := AO6->AO6_ASSUNT
		If !Empty(AO6->AO6_ENTMOD) .AND. !Empty(AO6->AO6_CODMOD) //verificando se existe Anexos, se existir anexar ao email que está sendo criado
          aCRM180ANX := CRMA180ANX(cAlias,xFilial(cAlias)+AO6->AO6_CODMOD)// VERIFICANDO ANEXOS
       EndIf
	EndIf
EndIf

If !Empty(aAreaAO6)
	RestArea(aAreaAO6)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} VisModEmail()

Rotina para pré-visualizar o modelo de escolhido

@param	  	ExpO1 = Objeto do browse que será manipulado
			ExpA1 = Array contendo os registro do browse
			ExpC1 = Alias da entidade

@return   	Nenhum

@author	Victor Bitencourt
@since		14/04/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Static Function VisModEmail(oBrwMark,aCampos,cAlias)

Local cBodyMesc  := ""
Local cCodMod    := ""

Local aAreaAO6   := {}

Local oEditHtml  := Nil
Local oDlg       := Nil
Local oPanel     := Nil

Default aCampos  := {}
Default oBrwMark := Nil

If ValType(oBrwMark) == "O" .AND. !Empty(aCampos) .AND. Type("oCRM180EHT") == "O"

	If Select("AO6") > 0
		aAreaAO6 := AO6->(GetArea())
	Else
		DbSelectArea("AO6")//Modelo de Email
	EndIf
	AO6->(DbSetOrder(1)) //AO6_FILIAL+AO6_CODMO

	cCodMod   := aCampos[oBrwMark:At()][3]

	If AO6->(DbSeek(xFilial("AO6")+cCodMod))
		cBodyMesc := CRM170MEEM(AO6->AO6_MENSAG,AO6->AO6_ENTMOD)
		cBodyMesc := CRMA170CRG(cBodyMesc, .F., .T.)//Tratando as imagens do modelo, caso haja
		oDlg := FWDialogModal():New()
			oDlg:SetBackground(.T.)// .T. -> escurece o fundo da janela
			oDlg:SetTitle(STR0091)//"Pré-Visualização Modelo de Email"
			oDlg:SetEscClose(.T.)//permite fechar a tela com o ESC
			oDlg:SetSize(270,400)//cria a tela maximizada (chamar sempre antes do CreateDialog)
			oDlg:EnableFormBar(.T.)

			oDlg:CreateDialog() //cria a janela (cria os paineis)
			oPanel := oDlg:getPanelMain()
			oDlg:createFormBar()//cria barra de botoes
			oEditHtml := FWSimpEdit():New( 0, 0, 0,0, STR0078,,,.F.,.F. , oPanel, .T.)//"Editor HTML"
			oEditHtml:SetText(cBodyMesc)
			oDlg:addCloseButton()
		oDlg:activate()
	EndIf
EndIf

If !Empty(aAreaAO6)
	RestArea(aAreaAO6)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA180ANX()

Rotina para pesquisar anexos para determinado registro

@param	  	ExpC1 = Alias que p anexo está vinculado
			ExpC2 = Codigo que Deverá ser pesquisado


@return   	aRet - Array contendo os objetos (anexos)

@author	Victor Bitencourt
@since		22/04/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Function CRMA180ANX(cAlias,cCodigo)

Local aRet := {}

Default cAlias  := ""
Default cCodigo := ""

If !Empty(cAlias) .AND. !Empty(cCodigo)

    BeginSql Alias "TMPALIAS"
		SELECT
			ACB.ACB_OBJETO, ACB.ACB_CODOBJ
		FROM
			%Table:AC9% AC9 INNER JOIN %Table:ACB% ACB ON (ACB.ACB_CODOBJ = AC9_CODOBJ)
		WHERE
			AC9.AC9_FILIAL = %xFilial:AC9%          AND
			AC9.AC9_ENTIDA = %exp:cAlias%           AND
			AC9.AC9_FILENT = %exp:xFilial(cAlias)%  AND
			AC9.AC9_CODENT = %exp:cCodigo% AND
			AC9.%NotDel%
    EndSql
    While TMPALIAS->(!Eof())
    	AAdd(aRet,{TMPALIAS->ACB_CODOBJ,TMPALIAS->ACB_OBJETO} )
       TMPALIAS->(DbSkip())
    EndDo
    TMPALIAS->(DbCloseArea())
EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA180ANX()

Rotina para gravar Anexos.

-- Atenção --
Ao chamar essa rotina os regidtro na qual deverá ser vinculado o anexo deverá
estar posicionado.

@param	  	ExpC2 = Codigo do Registro que Deverá ser vinculado ao anexo


@return   	aRet - Array contendo os objetos (anexos)

@author	Victor Bitencourt
@since		23/04/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Static Function GravaAnexo(cCodigo)

Local aAreaAC9 := {}
Local nX       := 0

If Select("AC9") > 0
	aAreaAC9 := AC9->(GetArea())
Else
	DbSelectArea("AC9")//RELACAO DE OBJETOS X ENTIDADES
EndIf
AC9->(DbSetOrder(1)) //AC9_FILIAL+AC9_CODOBJ+AC9_ENTIDA+AC9_FILENT+AC9_CODENT

Default cCodigo := ""

If !Empty(cCodigo)
	Begin Transaction
		For nX := 1 To Len( aCRM180ANX )
			If !AC9->(DbSeek(xFilial("AC9")+aCRM180ANX[nX][1]+"AOF"+xFilial("AOF")+(xFilial("AOF")+cCodigo)) )
				RecLock( "AC9", .T. )
					AC9->AC9_FILIAL := xFilial( "AC9" )
					AC9->AC9_FILENT := xFilial("AOF" )
					AC9->AC9_ENTIDA := "AOF"
					AC9->AC9_CODENT := xFilial("AOF")+cCodigo
					AC9->AC9_CODOBJ := aCRM180ANX[nX][1]
				AC9->( MsUnlock() )
			EndIf
		Next nX
		RecLock("AOF",.F.)//Foi necessário atualizar dessa forma, porque está no bloco de commit chamar o ExecAuto do mvc para atualização seria muito mais lento em performance.
			AOF->AOF_ANEXO := "1" // Atualizando Campo de Anexo
		AOF->(MsUnlock())
	End Transaction
EndIf

Asize( aCRM180ANX, 0)

If !Empty(aAreaAC9)
	RestArea(aAreaAC9)
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AlteraMapHTML()

Rotina para alterar o mapeamento do HTML

@param	  	Nenhum

@return   	Nenhum

@author	Victor Bitencourt
@since		23/04/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Static Function AlteraMapHTML()

Local cXml := ""
Private lMsErroAuto := .F.

cXml := CRMA170LMG(Nil, Nil, .T.)

If !Empty(cXml)

	aExecAuto := {{"AOF_FILIAL",xFilial("AOF")	,Nil},;
	   			 	{"AOF_CODIGO" ,AOF->AOF_CODIGO ,Nil},;
				 	{"AOF_LNKIMG" ,cXml			,Nil}}
	CRMA180( aExecAuto, 4, .T. ) // Importar agenda por rotina automatica

EndIf

Return

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA180InTTS

Bloco de transacao durante o commit do model.

@sample	CRMA180InTTS(oModel,cId,cAlias)

@param		ExpO1 - Modelo de dados
			ExpC2 - Id do Modelo
			ExpC3 - Alias

@return	ExpL  - Verdadeiro / Falso

@author	Anderson Silva
@since		07/08/2014
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRMA180InTTS(oModel, cUserAnt)

Local nOperation	:= oModel:GetOperation()
Local oMdlAOF		:= oModel:GetModel("AOFMASTER")
Local cChave    	:= ""
Local aAutoAO4  	:= {}
Local lRetorno 	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona ou Remove o privilegios deste registro.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cChave := PadR( xFilial("AOF")+oMdlAOF:GetValue("AOF_CODIGO"),TAMSX3("AO4_CHVREG")[1])
If ( nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_DELETE )
  	aAutoAO4	:= CRMA200PAut(nOperation,"AOF",cChave,FwFldGet("AOF_CODUSR"),/*aPmrmissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)
	CRMA200Auto(aAutoAO4[1],aAutoAO4[2],nOperation)
ElseIf nOperation == MODEL_OPERATION_UPDATE .And. !Empty(cUserAnt)
	DbSelectArea("AO4")
	AO4->(DbSetOrder(1)) // AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR
	If AO4->(DbSeek(xFilial("AO4")+"AOF"+cChave+AOF->AOF_CODUSR)) //Verifica se o usuário atual possui privilegios para este registro
		If AO4->(DbSeek(xFilial("AO4")+"AOF"+cChave+cUserAnt)) //Se possui, é só deletar o acesso do usuário anterior
			RecLock("AO4",.F.)
			AO4->(DbDelete())
			AO4->(MsUnlock())
		EndIf
	Else
		If AO4->(DbSeek(xFilial("AO4")+"AOF"+cChave+cUserAnt)) //Se não possui, atualiza o privilégio atual do registro
			RecLock("AO4",.F.)
			AO4->AO4_CODUSR := AOF->AOF_CODUSR
			AO4->AO4_IDESTN := AOF->AOF_IDESTN
			AO4->AO4_NVESTN := AOF->AOF_NVESTN
			AO4->(MsUnlock())
		EndIf
	EndIf
EndIf

Return(lRetorno)

//------------------------------------------------------------------------------
/*/	{Protheus.doc} 

Rotina feita especialmente para a chamada de atividade da WorArea do CRM

@sample	CRMA180WAATI()

@param		Nenhum

@return	Nenhum

@author	Victor Bitencourt
@since		09/10/2014
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA180WAATI()

/*	*****************Atenção**************           

 	existe Alguns cenários difierentes para aplicar o filtro de entidade na rotina de atividades São eles:
 	
 	1° o filtro de entidade deverá ser aplicado somente quando a chamada vier de outras funções como:
 	  clientes, prospects, suspects e etc... esse filtro faz com que mostre todos os registros de atividades,
 	  relacionadas ao registro posicionado na entidade que está chamando.
 	  
 	2° quando a chamada vem direto da WorkArea não deverá ser aplicado os filtros de entidade, porque ele deverá
 	ver os registros referentes ao seu usuário e não somente os registros referentes aquela entidade que está chamando.
 	
 	3° Existe uma situação que o usuário pode abrir a rotina de clientes direto da WorkArea, e da rotina de clientes chamar
 	a rotina de atividades. Nesse caso como é a rotina de clientes que está chamado atividades, deverá ser aplicado o filtro 
 	de entidade. somente não aplica quando a chamada para atividades é diretamente pela WorkArea.
 	
 	Por esse motivo foi criado essa função, somente chamadas diretas da WorkArea chama essa função, e ela fica
 	responsavel por chamar a rotina de atividades.
 	
 	como funciona: quando a atividades recebe uma chamada, ele verificar se existe essa função (CRMA180WAATI) na pilha
 	se existir, ele sabe que é uma chamada direta da WorkArea e não aplica o filtro de entidade, caso não existe a função na pilha 
 	mantem o funcionamento padrão , aplica o filtro de entidade. 
 	
 	para verificar o codigo dê uma olhada na função CRMA180() na parte de criação de filtros, lá terá um 
 	IsInCallStack("CRMA180WAATI") verificando se não existe essa função na pilha, para assim incluir o filtro de entidade.
*/
CRMA180()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA180NEG()

Rotina para alterar o mapeamento do HTML

@param	  	cCodUmov - Codigo do umov no compromisso

@return   	Nenhum

@author	Victor Bitencourt
@since		23/04/2014
@version	12.0
/*/
//------------------------------------------------------------------------------
Static Function CRMA180NEG(cCodUmov)

Local aAddFil    := {}

Default cCodUmov := ""

If !Empty(cCodUmov)
	aAdd( aAddFil, {STR0119, "AOJ_IDAGEN == '"+cCodUmov+"'", .T., .T., "AOJ", /*lFilterAsk*/, /*aFilParser*/, "AOJ_FILENT" } ) //"Filtro de Entidade"
	CRMA570(,,, aAddFil)	
Else
	Help( ,,STR0122,,STR0123, 1, 0 )	//'Ajuda'//'Este compromisso não possui registros de check-in\out.'
EndIf

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA180Leg()
Função para criar uma legenda adicional no browse 
@return   	Nenhum
@author	Philip Pellegrini
@since		22/06/2015
@version	12.0
/*/
Static Function CRMA180Leg()

Local oLegenda  :=  FWLegend():New()

oLegenda:Add("" ,"BR_AMARELO" 		, STR0125) //"Clientes"
oLegenda:Add("" ,"BR_AZUL"    		, STR0126)//"Suspects"
oLegenda:Add("" ,"BR_VERDE"   		, STR0127)//"Prospects"
oLegenda:Add("" ,"BR_PRETO"   		, STR0128)//"Vendedores"
oLegenda:Add("" ,"BR_VERMELHO"		, STR0129)//"Oportunidades"
oLegenda:Add("" ,"BR_PINK"    		, STR0130)//"Concorrentes"
oLegenda:Add("" ,"BR_LARANJA"		, STR0131)//"Parceiros"
oLegenda:Add("" ,"BR_VIOLETA" 		, STR0132)//"Fornecedores"
oLegenda:Add("" ,"BR_CINZA"   	  	, STR0133)//"Usuários do CRM"
oLegenda:Add("" ,"BR_AZUL_CLARO"   , STR0134)//"Campanhas"
oLegenda:Add("" ,"BR_MARROM"   		, STR0135)//"Eventos"
oLegenda:Add("" ,"BR_VERDE_ESCURO" , STR0136)//"Unidades de Negócio"
oLegenda:Add("" ,"BR_MARROM_OCEAN" , STR0137)//"Equipes de Venda"
oLegenda:Add("" ,"BR_AZUL_OCEAN"  	, STR0138)//"Contatos"
oLegenda:Add("" ,"BR_BRANCO"  		, STR0139)//"Outros"

oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA180RegL()
Regra da legenda adicional 
@return   	cLegenda - Cor da legenda de cada registro do browse
@author	Philip Pellegrini
@since		22/06/2015
@version	12.0
/*/
Static Function CRMA180RegL()

Local cLegenda		:= ""

Do Case
	Case AOF->AOF_ENTIDA == "SA1"
		cLegenda := "BR_AMARELO"
	Case AOF->AOF_ENTIDA == "ACH"
		cLegenda := "BR_AZUL"
	Case AOF->AOF_ENTIDA == "SUS"
		cLegenda := "BR_VERDE"
	Case AOF->AOF_ENTIDA == "SA3"
		cLegenda :="BR_PRETO"
	Case AOF->AOF_ENTIDA == "AD1"
		cLegenda := "BR_VERMELHO"
	Case AOF->AOF_ENTIDA == "AC3"
		cLegenda := "BR_PINK"
	Case AOF->AOF_ENTIDA == "AC4"
		cLegenda := "BR_LARANJA"
	Case AOF->AOF_ENTIDA == "SA2"
		cLegenda := "BR_VIOLETA"
	Case AOF->AOF_ENTIDA == "AO3"
		cLegenda := "BR_CINZA"
	Case AOF->AOF_ENTIDA == "SU0"
		cLegenda := "BR_AZUL_CLARO"
	Case AOF->AOF_ENTIDA == "ACD"
		cLegenda := "BR_MARROM"
	Case AOF->AOF_ENTIDA == "ADK"
		cLegenda := "BR_VERDE_ESCURO"
	Case AOF->AOF_ENTIDA == "ACA"
		cLegenda := "BR_MARROM_OCEAN"
	Case AOF->AOF_ENTIDA == "SU5"
		cLegenda := "BR_AZUL_OCEAN"
	Otherwise 
		cLegenda := "BR_BRANCO"
EndCase
Return(cLegenda)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CRM180UCpo
Retorna os campos de usuarios.
@return   	cFields, caracter, Campos do usuario.
@since		20/02/2017
@version	12.0
/*/
Static Function CRM180UCpo()

Local aAreaSX3 := SX3->( GetArea() )
Local cFields  := ""

SX3->( DbSetOrder( 1 ) )
If SX3->( DBSeek( "AOF" ) )
	While SX3->( !Eof() .And. SX3->X3_ARQUIVO == "AOF" )
		If SX3->X3_PROPRI == "U"
			cFields += AllTrim( SX3->X3_CAMPO ) + "|" 
		EndIf
		SX3->( DbSkip() )
	EndDo
EndIf
RestArea( aAreaSX3 )
Return( cFields )

Static Function CRM180Fil(cMyAlias, cCGC)

Local aAreaEnt		:= {}
Local cMyFilter		:= ''
Default cMyAlias	:= ''
Default cCGC		:= ''

If !Empty(cCGC)
	If cMyAlias <> "SA1"	
		DbSelectArea("SA1")
		aAreaEnt := SA1->(GetArea())
		SA1->(DbSetOrder(3)) //SA1_FILIAL+SA1_CGC
		If SA1->( DbSeek( xFilial("SA1")+ALLTRIM(cCGC) ) )
			cMyFilter += ".OR. ( AOF_ENTIDA == 'SA1'.AND. AOF_CHAVE == "+"'"+SA1->A1_COD + SA1->A1_LOJA+"' )"
		EndIf
		RestArea(aAreaEnt)
	EndIf	

	If cMyAlias <> "SUS"
		DbSelectArea("SUS")
		aAreaEnt := SUS->(GetArea())
		SUS->(DbSetOrder(4)) //SUS_FILIAL+SUS_CGC
		If SUS->( DbSeek( xFilial("SUS")+ ALLTRIM(cCGC) ) )
			cMyFilter += ".OR. ( AOF_ENTIDA == 'SUS'.AND. AOF_CHAVE == "+"'"+SUS->US_COD + SUS->US_LOJA+"' )"
		EndIf
		RestArea(aAreaEnt)
	EndIf	

	If cMyAlias <> "ACH"
		DbSelectArea("ACH")
		aAreaEnt := ACH->(GetArea())
		ACH->(DbSetOrder(2)) //ACH_FILIAL+ACH_CGC
		If ACH->( DbSeek( xFilial("ACH")+ ALLTRIM(cCGC) ) )
			cMyFilter += ".OR. ( AOF_ENTIDA == 'ACH'.AND. AOF_CHAVE == "+"'"+ACH->ACH_CODIGO + ACH->ACH_LOJA+"' )"
		EndIf
		RestArea(aAreaEnt)
	EndIf
EndIf
If	Len(aAreaEnt) > 0 
	Asize(aAreaEnt,0)
EndIf
Return cMyFilter

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} AO4GdModel

Cria um GridModel associado ao modelo informado no parãmetro, para evitar
a validação do SX9 da entidade principal do modelo informado com a AO4

@param, cIDModel, ID do modelo principal                              , String
@param, oModel  , Objeto do modelo a que o novo modelo serah associado, MPFormModel

@sample		AO4GdModel(cIDModel, oModel)

@return, Nil

@author		Squad CRM/Faturamento
@since		30/06/2021
@version	12.1.27
/*/
//----------------------------------------------------------------------------------
Static Function AO4GdModel(cIDMasterM, oModel, cAliasMast )
Local oStructAO4 := FWFormStruct(1,"AO4",/*bAvalCampo*/,/*lViewUsado*/)
Default cIDMasterM := ""
Default cAliasMast := ""

oModel:AddGrid("AO4CHILD",cIDMasterM,oStructAO4,/*bPreValid*/,/*bPosValid*/, , ,{|oGridModel, lCopy|LoadGdAO4(oGridModel, lCopy)})
oModel:SetRelation( "AO4CHILD" ,{ { "AO4_FILIAL", "FWxFilial( 'AO4' )" }, { "AO4_ENTIDA", cAliasMast }, { "AO4_CHVREG", ( cAliasMast )->( IndexKey( 1 ) ) }  }, AO4->( IndexKey( 1 ) ) )
oModel:GetModel("AO4CHILD"):SetOnlyView()
oModel:GetModel("AO4CHILD"):SetOnlyQuery()
oModel:GetModel("AO4CHILD"):SetOptional(.T.)
oModel:GetModel("AO4CHILD"):SetNoInsertLine(.T.)
oModel:GetModel("AO4CHILD"):SetNoUpdateLine(.T.)
oModel:GetModel("AO4CHILD"):SetNoDeleteLine(.T.)

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} LoadGdAO4 

Bloco de carga dos dados do submodelo.
Este bloco sera invocado durante a execução do metodo activate desta classe.
O bloco recebe por parametro o objeto de model do FormGrid(FWFormGridModel) e um 
valor lógico indicando se eh uma operação de copia.

@param, oGridModel, objeto de model do FormGrid, FWFormGridModel
@param, lCopy     , indica se eh uma operação de copia, Boolean

@sample	LoadGdAO4(oGridModel, lCopy)

@return, aLoad, array com os dados que serão carregados no objeto, 
                o array deve ter a estrutura abaixo:
					[n]
					[n][1] ExpN: Id do registro (RecNo)
					[n][2] Array com os dados, os dados devem seguir exatamente 
					       a mesma ordem da estrutura de dados submodelo

@author		Squad CRM/Faturamento
@since		30/06/2021
@version	12.1.27
/*/
//----------------------------------------------------------------------------------
Static Function LoadGdAO4(oGridModel, lCopy)
	
	Local aLoad      := {}
	Local oStructAO4 := FWFormStruct(1,"AO4",/*bAvalCampo*/,/*lViewUsado*/)
	Local aFields    := {}
	Local nField     := 0
	Local nQtFields  := 0
	Local xValue     := Nil
	Local cField     := ""
	Local cType      := ""
	Local nLen       := 0

	aFields   := oStructAO4:GetFields()
	nQtFields := Len(aFields)

	AAdd(aLoad, {0,{}})

	For nField := 1 To nQtFields
		
		cField := aFields[nField][3]
		
		If Alltrim(cField) == "AO4_FILIAL"
			xValue := XFilial("AO4")
			cType  := ""
		Else
			cType  := aFields[nField][4]
			nLen   := aFields[nField][5]	
		EndIf

		Do Case
			Case cType == "C"
				xValue := Space(nLen)
			Case cType == "N"
				xValue := 0
			Case cType == "L"
				xValue := .T.
			Case cType == "D"
				xValue := CToD("  /  /    ")
		End Case

		AAdd(aLoad[1][2], xValue)
	Next nField

	FwFreeObj(oStructAO4)
	FwFreeObj(aFields)

Return aLoad
