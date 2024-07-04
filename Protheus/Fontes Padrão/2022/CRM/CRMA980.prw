#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "CRMDEF.CH" 
#INCLUDE "CRMA980.CH" 

Static aAOVMark 	:= {} 

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA980
Cadastro de clientes para localização padrão.

@param		aSA1Auto	, Array		, Dados do Cliente
			nOpcAuto	, Numerico	, Operação do cadastro.
			aAI0Auto	, Array		, Dados do Complemento do Cliente
			aFOJAuto	, Array		, Tipo de retenção x Clientes 
			
@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Function CRMA980(aSA1Auto,nOpcAuto,aAI0Auto,aFOJAuto)

	Local oMBrowse	:= Nil
	Local oModel	:= Nil  

	Private aRotina := MenuDef()
	
	//------------------------------------------------------------
	// Variaveis serão mantidas até descontinuar o fonte MATA030
	// devido o uso nas validações de campos.
	//------------------------------------------------------------
	Private lCGCValido 	:= .F. // Variavel usada na validacao do CNPJ/CPF (utilizando o Mashup) 
	Private l030Auto   	:= .F. // Variavel usada para saber se é rotina automática
	
	Default aSA1Auto 	:= {} 
	Default nOpcAuto	:= MODEL_OPERATION_INSERT
	Default aAI0Auto	:= {}
	Default aFOJAuto	:= {}
	
	If nModulo == 73
		aRotina := FwLoadMenuDef("CRMA070")
	Else	
		aRotina := MenuDef()
	EndIf
	 
	If Len( aSA1Auto  ) == 0
		oMBrowse := BrowseDef()
		oMBrowse:Activate()
	Else
		//----------------------------------
		// Rotina automatica Clientes.
		//----------------------------------
		l030Auto	:= .T.
		oModel 		:= FWLoadModel("CRMA980")
					
		If (FindFunction("FTemMotor") .and. FTemMotor())
			FwMvcRotAuto(oModel,"SA1",nOpcAuto,{{"SA1MASTER",aSA1Auto},{"AI0CHILD",aAI0Auto}, {"FOJDETAIL",aFOJAuto}},/*lSeek*/,.T.)
		Else
			FwMvcRotAuto(oModel,"SA1",nOpcAuto,{{"SA1MASTER",aSA1Auto},{"AI0CHILD",aAI0Auto}},/*lSeek*/,.T.)
		Endif

		oModel:DeActivate() 
		oModel:Destroy()
		oModel := Nil
		
	EndIf

Return Nil
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Configurações do browse de clientes para localização padrão.

@param		Nenhum

@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()

	Local oMBrowse 	:= Nil
	Local cFilUser	:= ""
	Local aLabelPE	:= {}
	Local nLenLabel	:= 0
	Local nX			:= 0
	Local nPos			:= 0
	Local oTableAtt 	:= TableAttDef()
	Local aBrwConfig	:= {} 	
	Local cMainProc    := IIF(nModulo==73,"CRMA070","CRMA980")
		
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("SA1")
	oMBrowse:SetDescription(STR0001)//"Clientes"
	oMBrowse:SetMenuDef("CRMA980")
	oMBrowse:SetMainProc(cMainProc)
	
	//----------------------------------
	// Visões e gráficos padrão.
	//----------------------------------
	oMBrowse:SetAttach(.T.)
	oMBrowse:SetViewsDefault(oTableAtt:aViews)
	oMBrowse:SetChartsDefault(oTableAtt:aCharts)
	
	If nModulo <> 73
		oMBrowse:SetOpenChart(.F.)
	EndIf
	
	//--------------------------------------------------------------------
	// Ponto de entrada para adicionar cores de legenda para os clientes.                                               
	//--------------------------------------------------------------------
	If ExistBlock("CRM980BLABEL")
		aLabelPE := ExecBlock("CRM980BLABEL", .F., .F.)
		If ValType( aLabelPE ) == "A"
			nLenLabel := Len( aLabelPE )
			For nX := 1 To nLenLabel
				oMBrowse:AddLegend(aLabelPE[nX][1],aLabelPE[nX][2],aLabelPE[nX][3])
			Next nX
		EndIf
	EndIf 
	
	If IsInCallStack("MATA030")	
		
		aBrwConfig := MA030BrwCfg()	//Função para manter o legado dos parametros do MATA030 referente aos filtros.
		
		If !Empty( aBrwConfig )
			//---------------------------
			// Filtro Default do Browse  
			//---------------------------
			If !Empty( aBrwConfig[1] )
				oMBrowse:SetFilterDefault( aBrwConfig[1] )
			EndIf
			
			//-------------------------------
			// Selecionando a Visão Inicial
			//------------------------------- 
			If !Empty( aBrwConfig[2] ) 
				nPos := aScan( oTableAtt:aViews, { |x| x:cID == aBrwConfig[2] } )
				If nPos > 0 
					oMBrowse:SetIDViewDefault( oTableAtt:aViews[nPos]:cID )
				EndIf
			EndIf
			
			//---------------------------------
			//Filtros adicionais do Browse
			//---------------------------------
			For nX := 1 To Len( aBrwConfig[3] )
				oMBrowse:DeleteFilter( aBrwConfig[3][nX][ADDFIL_ID] )
				oMBrowse:AddFilter(	aBrwConfig[3][nX][ADDFIL_TITULO]	,;
										aBrwConfig[3][nX][ADDFIL_EXPR]		,;
										aBrwConfig[3][nX][ADDFIL_NOCHECK]	,;
										aBrwConfig[3][nX][ADDFIL_SELECTED]	,;
										aBrwConfig[3][nX][ADDFIL_ALIAS]		,;
										aBrwConfig[3][nX][ADDFIL_FILASK]	,;
										aBrwConfig[3][nX][ADDFIL_FILPARSER],;
										aBrwConfig[3][nX][ADDFIL_ID] )	
				oMBrowse:ExecuteFilter()	
			Next nX
		EndIf
		
	EndIf		
	
	//----------------------------
	// Filtro padrão do usuario. 
	//----------------------------
	If ExistBlock("CRM980BFIL")
		cFilUser := ExecBlock("CRM980BFIL",.F.,.F.)
		If ValType( cFilUser ) == "C" .And. !Empty( cFilUser )
			oMBrowse:AddFilter(STR0048,cFilUser,.T.,.T.) //"Filtro de Usuário"
			oMBrowse:ExecuteFilter()
		EndIf
	EndIf	
				
	oMBrowse:SetTotalDefault("A1_FILIAL","COUNT",STR0002)//"Total de Registros"

Return oMBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de clientes para localização padrão.

@param		Nenhum

@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel    	:= Nil
	Local oStructSA1	:= FWFormStruct(1,"SA1",/*bAvalCampo*/,/*lViewUsado*/)
	Local oStructAI0	:= FWFormStruct(1,"AI0",/*bAvalCampo*/,/*lViewUsado*/)
	Local aMemoSA1	:= {}
	Local aMemoUser	:= {}
	Local oEvtDEF 		:= CRM980EventDEF():New()
	Local oEvtDEFCRM 	:= CRM980EventDEFCRM():New()
	Local oEvtDEFTMK 	:= Nil
	Local oEvtDEFFAT 	:= CRM980EventDEFFAT():New()
	Local oEvtDEFFIN 	:= CRM980EventDEFFIN():New()
	Local oEvtDEFFIS 	:= CRM980EventDEFFIS():New()
	Local oEvtDEFJUR 	:= CRM980EventDEFJUR():New()
	Local oEvtDEFLOJ 	:= CRM980EventDEFLOJ():New()
	Local oEvtDEFOMS 	:= Nil
	Local oEvtDEFGFE 	:= CRM980EventDEFGFE():New()
	Local oEvtDEFTMS 	:= CRM980EventDEFTMS():New()
	Local oEvtDEFRSK	:= Nil

	
	If Len(GetApoInfo("CRM980EventDEFTMK.PRW")) > 0
		oEvtDEFTMK 	:= CRM980EventDEFTMK():New()
	Endif

	If Len(GetApoInfo("CRM980EventDEFOMS.PRW")) > 0
		oEvtDEFOMS 	:= CRM980EventDEFOMS():New()
	EndIf

	If Len(GetApoInfo("CRM980EventDEFRSK.PRW")) > 0
		oEvtDEFRSK	:= CRM980EventDEFRSK():New()
	EndIf
	
	//-----------------------------------------------------------------------
	// Tratamento para campos do tipo Memo com o conteudo na SYP.
	// Obs: Não adiciona campos Memos para o PDV pois o cadastro é reduzido. 
	//-----------------------------------------------------------------------
	If nModulo <> 23
		aAdd(aMemoSA1,{"A1_CODMARC","A1_VM_MARC"})
		aAdd(aMemoSA1,{"A1_OBS","A1_VM_OBS"})
	EndIf
	
	//--------------------------------------------------------------------
	// Ponto de entrada para adição de campos memos do usuário.
	//--------------------------------------------------------------------
	If ExistBlock("CRM980MMEM") 
		aMemoUser := ExecBlock( "CRM980MMEM", .F., .F. ) 
		If ValType( aMemoUser ) == "A"
			AEval( aMemoUser, { |x| aAdd( aMemoSA1, x ) } ) 	
		EndIf 	
	EndIf

	//---------------------------------------------------------------------------------------
	// Bloqueia os campos chaves da AI0 para edição - Informações Complementares do Cliente
	// Os campos foram colocados como vísuais, para que não ocorra erro na montagem da aba.
	// quando os clientes configuram a aba para não apresentar nenhum campo da AI0.
	//---------------------------------------------------------------------------------------
	oStructAI0:SetProperty('AI0_CODCLI',MODEL_FIELD_WHEN,{||.F.})
	oStructAI0:SetProperty('AI0_LOJA'  ,MODEL_FIELD_WHEN,{||.F.})

	//-------------------------------------------
	// Considera os campos Memos SYP no MVC.
	//-------------------------------------------
	FWMemoVirtual(oStructSA1,aMemoSA1)
	
	oModel := MPFormModel():New("CRMA980",/*bPreValid*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)
	oModel:AddFields("SA1MASTER",/*cOwner*/,oStructSA1,/*bPreValid*/,/*bPosValid*/,/*bCarga*/)
	oModel:AddFields("AI0CHILD","SA1MASTER",oStructAI0,/*bPreValid*/,/*bPosValid*/,/*bCarga*/)
	oModel:SetRelation("AI0CHILD",{{"AI0_FILIAL", "xFilial('AI0')"},{"AI0_CODCLI","A1_COD"},{"AI0_LOJA","A1_LOJA"}},AI0->( IndexKey( 1 ) )) 
	
	//---------------------------------------------------------------------------------------------------------
	// Adicao do modelo da AO4 pois ele eh gravado juntamente com os registros da entidade principal do modelo
	//---------------------------------------------------------------------------------------------------------
	AO4GdModel("SA1MASTER", oModel, "SA1" )

	oModel:SetDescription(STR0001)//"Clientes"
	
	//-------------------------------------------
	// Instalação do evento padrão por modulos.
	//-------------------------------------------
	oModel:InstallEvent("LOCDEF"	,/*cOwner*/,oEvtDEF)
	oModel:InstallEvent("LOCDEFCRM"	,/*cOwner*/,oEvtDEFCRM)
	If oEvtDEFTMK <> Nil
		oModel:InstallEvent("LOCDEFTMK"	,/*cOwner*/,oEvtDEFTMK)
	EndIf
	oModel:InstallEvent("LOCDEFFAT"	,/*cOwner*/,oEvtDEFFAT)
	oModel:InstallEvent("LOCDEFFIN"	,/*cOwner*/,oEvtDEFFIN)
	oModel:InstallEvent("LOCDEFFIS"	,/*cOwner*/,oEvtDEFFIS)
	oModel:InstallEvent("LOCDEFLOJ"	,/*cOwner*/,oEvtDEFLOJ)
	oModel:InstallEvent("LOCDEFJUR"	,/*cOwner*/,oEvtDEFJUR)
	If oEvtDEFOMS != Nil
		oModel:InstallEvent("LOCDEFOMS"	,/*cOwner*/,oEvtDEFOMS)
	EndIf
	oModel:InstallEvent("LOCDEFGFE"	,/*cOwner*/,oEvtDEFGFE)
	oModel:InstallEvent("LOCDEFTMS"	,/*cOwner*/,oEvtDEFTMS) 

	If oEvtDEFRSK != Nil
		oModel:InstallEvent("LOCDEFRSK"	,/*cOwner*/,oEvtDEFRSK)
	EndIf

Return oModel      



//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface do modelo de dados de clientes para localização padrão.

@param		Nenhum

@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView		:= Nil
	Local oModel		:= FWLoadModel("CRMA980") 	 
	Local oStructSA1	:= FWFormStruct(2,"SA1",/*bAvalCampo*/,/*lViewUsado*/)
	Local oStructAI0	:= FWFormStruct(2,"AI0",/*bAvalCampo*/,/*lViewUsado*/)
	Local lCRMTerr 	:= SuperGetMV("MV_CRMTERR",.F.,.F.)
	
	oView:= FWFormView():New()
	oView:SetContinuousForm()
	oView:SetModel(oModel)
	
	oView:CreateHorizontalBox("BOXFORMALL",100)
	oView:CreateFolder("FOLDER","BOXFORMALL")
	oView:AddSheet("FOLDER","SHEETSA1","Principal")
	oView:AddSheet("FOLDER","SHEETAI0","Informações Complementares")
	
	oView:CreateHorizontalBox("BOXFORMSA1",100,/*cIdOwner*/,/*lFixPixel*/,"FOLDER","SHEETSA1")
	oView:CreateHorizontalBox("BOXFORMAI0",100,/*cIdOwner*/,/*lFixPixel*/,"FOLDER","SHEETAI0")
	
	oView:AddField("VIEW_SA1",oStructSA1,"SA1MASTER")
	oView:SetOwnerView("VIEW_SA1","BOXFORMSA1")
	
	oView:AddField("VIEW_AI0",oStructAI0,"AI0CHILD")
	oView:SetOwnerView("VIEW_AI0","BOXFORMAI0")
	
	oView:AddUserButton(STR0003,"",{|| a450F4Con()},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE} ) 									//"Posição do Cliente"
	oView:AddUserButton(STR0011,"",{|| CRMA120()},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE} ) 									//"SubClientes"
	oView:AddUserButton(STR0013,"",{|| MATA030Ref('SA1',SA1->(RecNo()),4)},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE} ) 			//"Referencias"
	oView:AddUserButton(STR0016,"",{|| A030Per()},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE} ) 									//"Perfil"
	oView:AddUserButton(STR0017,"",{|| CRMXNewOpo('SA1',SA1->A1_COD,SA1->A1_LOJA)},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE} ) 	//"Nova Oportunidade"
	oView:AddUserButton(STR0018,"",{|| CRMA110()},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE} ) 									//"Todas as Oportunidades"
	oView:AddUserButton(STR0021,"",{|| CRMXNewApo('SA1',SA1->A1_COD,SA1->A1_LOJA)},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE} ) 	//"Novo Apontamento"
	oView:AddUserButton(STR0022,"",{|| CRMA330()},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE} )  									//"Todos os Apontamentos"	
	oView:AddUserButton(STR0024,"",{|| CRMA310()},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE} ) 									//"Cons. Pedido de Venda"

	If ( nModulo == 13 .Or. nModulo == 73 )
		
		oView:AddUserButton(STR0006,"",{|| TkLstScr( oModel:GetOperation(),"SA1", FwFldGet("A1_COD"), FwFldGet("A1_LOJA") ) },,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE} ) //"Scripts de Campanha"
		
		If nModulo == 73	
			oView:AddUserButton(STR0007,"",{ |oView| SaveInter(), CRMA620(@aAOVMark,"SA1",FwFldGet("A1_COD"),FwFldGet("A1_LOJA"),FwFldGet("A1_CODSEG"),oModel:GetOperation()),RestInter() },,,{ MODEL_OPERATION_VIEW, MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE } ) //"Subsegmentos"
			If lCRMTerr
				oView:AddUserButton(STR0008,"",{|| CRMA690EvalTerritory("MATA030","SA1",.T.,.T.)},,,{MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE} ) //"Simular Território"
			EndIf	
		EndIf
		
	EndIf
	
	oView := CRMXAddAct("SA1",oView) 

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} TableAttDef
Criação de visões e gráficos para localização padrão.

@param		Nenhum

@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017
/*/
//-------------------------------------------------------------------
Static Function TableAttDef()

	Local oTableAtt 	:= Nil
	Local lCRMBrwView	:= ExistBlock("CRMBRWVIEW")	//Ponto entrada para manipulação das views padrão
	Local cRotina		:= "MATA030"
	Local cAliasView	:= "SA1"
	
	// Visões
	Local oDSMyCliAt := Nil // Meus Clientes Ativos
	Local oDSMyCliCo := Nil // Meus Clientes Ativos
	Local oDSCliAtiv := Nil // Clientes Ativos
	Local oDSCliInat := Nil // Clientes Inativos
	
	// Gráficos
	Local oDSNvPorDt := Nil // Colunas: Novos Clientes Por Data
	Local oDSPorVend := Nil // Colunas: Clientes Por Vendedor
	Local oDSPorSegm := Nil // Pizza: Clientes Por Segmento
	Local oPorRegiao := Nil // Colunas: Clientes Por Região
	
	If lCRMBrwView
		oTableAtt := ExecBlock("CRMBRWVIEW", .F.,.F.,{cRotina,cAliasView})
	EndIf 
	
	If Empty( oTableAtt )
	
		oTableAtt 	:= FWTableAtt():New()
		oTableAtt:SetAlias("SA1")
		
		//----------
		// Visões
		//---------- 
		If IsInCallStack("CRMA070") .Or. IsInCallStack("CRMA290") .Or. IsInCallStack("CRMA290A") .Or. IsInCallStack("CA290CWDGT")
		
			// Meus Clientes Ativos
			oDSMyCliAt := FWDSView():New()
			oDSMyCliAt:SetName(STR0033) //"Meus Clientes Ativos"
			oDSMyCliAt:SetID("DSMyCliAt") 
			oDSMyCliAt:SetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
			oDSMyCliAt:SetCollumns({	"A1_COD"	,"A1_LOJA"	,"A1_NOME"	,"A1_NREDUZ"	,"A1_END"	,;
										"A1_TIPO"	,"A1_EST"	,"A1_MUN"	,"A1_BAIRRO"	,"A1_DDD"	,;
										"A1_TEL"	,"A1_CGC"	,"A1_REGIAO" })
			oDSMyCliAt:SetPublic(.T.)
			oDSMyCliAt:AddFilterRelation("AO4","AO4_CHVREG","A1_FILIAL+A1_COD+A1_LOJA")
			oDSMyCliAt:AddFilter(STR0033,"AO4_ENTIDA = 'SA1' .And. AO4_CODUSR == '"+RetCodUsr()+"' .And. AO4_CTRLTT == .T.","AO4") //"Filtro CRM"
			oDSMyCliAt:AddFilter(STR0033,"A1_MSBLQL == '2'") //"Meus Clientes Ativos"
			
			oTableAtt:AddView(oDSMyCliAt)
			
			// Clientes Compartilhados
			oDSMyCliCo := FWDSView():New()
			oDSMyCliCo:SetName(STR0034)	//"Clientes Compartilhados"
			oDSMyCliCo:SetID("DSMyCliCo") 
			oDSMyCliCo:SetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
			oDSMyCliCo:SetCollumns({	"A1_COD"	,"A1_LOJA"	,"A1_NOME"	,"A1_NREDUZ"	,"A1_END"	,;
										"A1_TIPO"	,"A1_EST"	,"A1_MUN"	,"A1_BAIRRO"	,"A1_DDD"	,;
										"A1_TEL"	,"A1_CGC"	,"A1_REGIAO" })
			oDSMyCliCo:SetPublic(.T.)
			oDSMyCliCo:AddFilterRelation("AO4","AO4_CHVREG","A1_FILIAL+A1_COD+A1_LOJA")
			oDSMyCliCo:AddFilter(STR0034,"AO4_ENTIDA = 'SA1' .And. AO4_CODUSR == '"+RetCodUsr()+"' .And. AO4_CTRLTT == .F. .And. (AO4_PERVIS == .T. .Or. AO4_PEREDT == .T. .Or. AO4_PEREXC == .T. .Or. AO4_PERCOM == .T.)","AO4")	//"Clientes Compartilhados"
			
			oTableAtt:AddView(oDSMyCliCo)
		
		EndIf
		
		// Clientes Ativos
		oDSCliAtiv := FWDSView():New()
		oDSCliAtiv:SetName(STR0035) //"Clientes Ativos"
		oDSCliAtiv:SetID("DSCliAtiv") 
		oDSCliAtiv:SetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
		oDSCliAtiv:SetCollumns({	"A1_COD"	,"A1_LOJA"	,"A1_NOME"	,"A1_NREDUZ"	,"A1_END"	,;
									"A1_TIPO"	,"A1_EST"	,"A1_MUN"	,"A1_BAIRRO"	,"A1_DDD"	,;
									"A1_TEL"	,"A1_CGC"	,"A1_REGIAO" })
		oDSCliAtiv:SetPublic(.T.)
		oDSCliAtiv:AddFilter(STR0035,"A1_MSBLQL == '2'") //"Clientes Ativos"
		
		oTableAtt:AddView(oDSCliAtiv)
		
		// Clientes Inativos
		oDSCliInat := FWDSView():New()
		oDSCliInat:SetName(STR0036) //"Clientes Inativos"
		oDSCliInat:SetID("DSCliInat") 
		oDSCliInat:SetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
		oDSCliInat:SetCollumns({	"A1_COD"	,"A1_LOJA"	,"A1_NOME"	,"A1_NREDUZ"	,"A1_END"	,;
									"A1_TIPO"	,"A1_EST"	,"A1_MUN"	,"A1_BAIRRO"	,"A1_DDD"	,;
									"A1_TEL"	,"A1_CGC"	,"A1_REGIAO" })
		oDSCliInat:SetPublic(.T.)
		oDSCliInat:AddFilter(STR0036,"A1_MSBLQL == '1'") //"Clientes Inativos"
		
		oTableAtt:AddView(oDSCliInat)
		
		//------------
		// Gráficos
		//------------	
		
		// Colunas: Novos Clientes Por Data
		oDSNvPorDt := FWDSChart():New()	
		oDSNvPorDt:SetName(STR0037) 	//"Novos Clientes Por Data"
		oDSNvPorDt:SetTitle(STR0037) 	//"Novos Clientes Por Data"
		oDSNvPorDt:SetID("DSNvPorDt") 
		oDSNvPorDt:SetType("BARCOMPCHART")
		oDSNvPorDt:SetSeries({{"SA1", "A1_COD+A1_LOJA", "COUNT"}})
		oDSNvPorDt:SetCategory({{"SA1", "A1_DTCAD"}})
		oDSNvPorDt:SetPublic(.T.)
		oDSNvPorDt:SetLegend(CONTROL_ALIGN_BOTTOM) //Inferior
		oDSNvPorDt:SetTitleAlign(CONTROL_ALIGN_CENTER) 
		
		oTableAtt:AddChart(oDSNvPorDt)	
		
		// Colunas: Clientes Por Vendedor
		oDSPorVend := FWDSChart():New()	
		oDSPorVend:SetName(STR0038) 	//"Clientes Por Vendedor"
		oDSPorVend:SetTitle(STR0038) 	//"Clientes Por Vendedor"
		oDSPorVend:SetID("DSPorVend") 
		oDSPorVend:SetType("BARCOMPCHART")
		oDSPorVend:SetSeries({{"SA1", "A1_COD+A1_LOJA", "COUNT"}})
		oDSPorVend:SetCategory({{"SA3","A3_NOME"}})
		oDSPorVend:SetPublic(.T.)
		oDSPorVend:SetLegend(CONTROL_ALIGN_BOTTOM) //Inferior
		oDSPorVend:SetTitleAlign(CONTROL_ALIGN_CENTER) 
		
		oTableAtt:AddChart(oDSPorVend)
		
		// Pizza: Clientes Por Segmento
		oDSPorSegm := FWDSChart():New()	
		oDSPorSegm:SetName(STR0039) 	//"Clientes Por Segmento"
		oDSPorSegm:SetTitle(STR0039) 	//"Clientes Por Segmento"
		oDSPorSegm:SetID("DSPorSegm") 
		oDSPorSegm:SetType("PIECHART")
		oDSPorSegm:SetSeries({{"SA1","A1_COD+A1_LOJA","COUNT"}})
		oDSPorSegm:SetCategory({{"SA1", "A1_CODSEG"}})
		oDSPorSegm:SetPublic(.T.)
		oDSPorSegm:SetLegend(CONTROL_ALIGN_BOTTOM) //Inferior
		oDSPorSegm:SetTitleAlign(CONTROL_ALIGN_CENTER) 
		
		oTableAtt:AddChart(oDSPorSegm)
		
		// Colunas: Clientes Por Estado
		oPorRegiao := FWDSChart():New()	
		oPorRegiao:SetName(STR0040) 	//"Clientes Por Estado"
		oPorRegiao:SetTitle(STR0040) 	//"Clientes Por Estado"
		oPorRegiao:SetID("PorRegiao") 	
		oPorRegiao:SetType("BARCOMPCHART")
		oPorRegiao:SetSeries({{"SA1","A1_COD+A1_LOJA","COUNT"}})
		oPorRegiao:SetCategory({{"SA1","A1_EST"}})
		oPorRegiao:SetPublic(.T.)
		oPorRegiao:SetLegend(CONTROL_ALIGN_BOTTOM) //Inferior
		oPorRegiao:SetTitleAlign(CONTROL_ALIGN_CENTER) 
		
		oTableAtt:AddChart(oPorRegiao)
	
	EndIf

Return oTableAtt

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu do cadastro de clientes para localização padrão.

@param		Nenhum

@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina		:= {}
	Local aEntRelac		:= {}
	Local aApont		:= {}
	Local aOpor			:= {}
	Local aRotAdd 		:= {}
	Local aPerm			:= {}
	Local aPerfil360	:= {}
	Local lVldOffBalance := FindFunction( "RskIsActive" ) .And. FindFunction( "RskCliPosition" ) .And. AliasInDic( "AR3" ) .And. AliasInDic( "AR5" ) 
	
	If ( !IsBlind() .And. cPaisLoc <> "RUS" )
		aPerfil360	:= CRM710P360()  
	EndIf
	
	If ( IsInCallStack("FATA320") .Or. IsInCallStack("FATA321") )
		aPerm := FT060Permi(RetCodUsr(), "ACA_ACCLIE")
	Else
		aPerm := {.T.,.T.,.T.,.T.}
	EndIf
	
	ADD OPTION aRotina TITLE STR0041 ACTION "PesqBrw" OPERATION 1 ACCESS 0 // "Pesquisar"
	
	If aPerm[4]
		ADD OPTION aRotina TITLE STR0042 ACTION "VIEWDEF.CRMA980" OPERATION 2	ACCESS 0 //"Visualizar"
	EndIf
	
	If aPerm[1]
		ADD OPTION aRotina TITLE STR0043 ACTION "VIEWDEF.CRMA980" OPERATION 3	ACCESS 0 //"Incluir"	
	EndIf
	
	If aPerm[2]
		ADD OPTION aRotina TITLE STR0044 ACTION "VIEWDEF.CRMA980" OPERATION 4 ACCESS 143 //"Alterar"
	EndIf
	
	If aPerm[3]
		ADD OPTION aRotina TITLE STR0045 ACTION "VIEWDEF.CRMA980" OPERATION 5 ACCESS 144 //"Excluir"
	EndIf
	
	ADD OPTION aRotina TITLE STR0046	ACTION "VIEWDEF.CRMA980" OPERATION 8 ACCESS 0	 //"Imprimir"
	ADD OPTION aRotina TITLE STR0047	ACTION "VIEWDEF.CRMA980" OPERATION 9 ACCESS 0	 //"Copiar" 
	 
	ADD OPTION aRotina TITLE STR0010	ACTION "A030WizFac()" 							OPERATION 4 ACCESS 143 //"Facilitador"
	ADD OPTION aRotina TITLE STR0011	ACTION "CRMA120()" 								OPERATION 4 ACCESS 0 //"SubClientes"
	ADD OPTION aRotina TITLE STR0012	ACTION "MsDocument('SA1',SA1->(RecNo()), 4)" 	OPERATION 4 ACCESS 0 //"Conhecimento"
	ADD OPTION aRotina TITLE STR0013	ACTION "MATA030Ref('SA1',SA1->(RecNo()), 4)" 	OPERATION 3 ACCESS 0 //"Referencias"
	ADD OPTION aRotina TITLE STR0014 	ACTION "FtContato('SA1',SA1->(RecNo()) , 4)"	OPERATION 4 ACCESS 0 //"Contatos"
	ADD OPTION aRotina TITLE STR0015 	ACTION "CRMA200('SA1')"							OPERATION 4 ACCESS 0 //"Privilégios"
	ADD OPTION aRotina TITLE STR0016 	ACTION "A030Per()" 								OPERATION 4 ACCESS 0 //"Perfil"

	/* Integração RISK - TOTVS Mais Negócios
	Adiciona a opção de consulta da posição do cliente no TOTVS Mais Negócios */
	If lVldOffBalance .And. RskIsActive()
		ADD OPTION aRotina TITLE STR0056  ACTION "RskCliPosition( SA1->A1_COD, SA1->A1_LOJA )" OPERATION 4 ACCESS 0 //"Posição Mais Negócios"
		ADD OPTION aRotina TITLE STR0057  ACTION "RSKA060()" OPERATION 2 ACCESS 0 //"Histórico de Concessão - Mais Negócios"
	EndIf                  
	   
	//SubMenu - Relacionadas
	If Empty( aPerfil360 )
	
		ADD OPTION aOpor 		TITLE STR0017	ACTION "CRMXNewOpo('SA1',SA1->A1_COD,SA1->A1_LOJA)"	OPERATION 8 ACCESS 0  //"Nova Oportunidade"
		ADD OPTION aOpor 		TITLE STR0018	ACTION "CRMA110()"										OPERATION 8 ACCESS 0  //"Todas as Oportunidades"
		ADD OPTION aEntRelac TITLE STR0019	ACTION aOpor	 											OPERATION 8 ACCESS 0  //"Oportunidades"		
		ADD OPTION aApont    TITLE STR0021	ACTION "CRMXNewApo('SA1',SA1->A1_COD,SA1->A1_LOJA)" 	OPERATION 8 ACCESS 0  //"Novo Apontamento"
		ADD OPTION aApont    TITLE STR0022	ACTION "CRMA330()"	 									OPERATION 8 ACCESS 0  //"Todos os Apontamentos"
		ADD OPTION aEntRelac TITLE STR0023	ACTION aApont	 											OPERATION 8 ACCESS 0  //"Apontamentos"
		ADD OPTION aEntRelac TITLE STR0024	ACTION "CRMA310()" 										OPERATION 8 ACCESS 0  //"Cons. Pedido de Venda"
			
		aSort(aEntRelac,,,{ | x,y | y[1] > x[1] } )
		ADD OPTION aRotina  TITLE STR0031 	ACTION aEntRelac 	OPERATION 8 ACCESS 0 //"Relacionadas"
			
	Else	
		ADD OPTION aRotina TITLE STR0032 ACTION aPerfil360 OPERATION 8 ACCESS 0 //"Perfil 360"
	EndIf		 	
	
	//--------------------------------------------------
	// Ponto de entrada - Adiciona rotinas ao aRotina 
	//--------------------------------------------------
	If ExistBlock("CRM980MDEF")
		aRotAdd := ExecBlock("CRM980MDEF",.F., .F.)
		If ValType(aRotAdd) == "A"
			aEval(aRotAdd,{|x| aAdd(aRotina,x) })
		EndIf
	EndIf   

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA980GMSeg
Retorna os segmentos de negocios marcados pelo usuário para gravação
no modelo de dados.

@param		Nenhum

@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017
/*/
//-------------------------------------------------------------------
Function CRMA980GMSeg()
Return aAOVMark

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef

Função para chamar o adapter de mensagem única do cadastro de clientes.

@param 		cXML			,caracter, XML da mensagem única para envio/recebimento
@param 		nTypeTrans		,numerico, Tipo de transacao. (0-Recebimento, 1-Envio)
@param 		cTypeMessage	,numerico, Tipo de transação da Mensagem. (20-Business, 21-Response, 22-Receipt)

@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017
/*/
//-------------------------------------------------------------------
Static Function IntegDef( xEnt, nTypeTrans, cTypeMessage, cVersion, cTransaction, lJSon )

Local aRet := {}
Default lJSon := .F.
//a funcao integdef original foi transferida para o fonte mati030, conforme novas regras de mensagem unica.

If lJSon 
	aRet:= MATI030O( xEnt, nTypeTrans, cTypeMessage )
Else	
	aRet:= MATI030( xEnt, nTypeTrans, cTypeMessage, cVersion, cTransaction )
Endif

Return aRet

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

//-------------------------------------------------------------------
/*/{Protheus.doc} MyCRMA980

Função de exemplo para utilização da rotina automática de Clientes.

@param		Nenhum

@return	Nenhum

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
/*
User Function MyCRMA980()

Local aSA1Auto	:= {} 
Local aAI0Auto	:= {} 
Local nOpcAuto	:= MODEL_OPERATION_INSERT
Local lRet		:= .T.

Private lMsErroAuto := .F.

lRet := RpcSetEnv("T1","D MG 01","Admin") 

If lRet 
	
	//----------------------------------
	// Dados do Cliente
	//----------------------------------
	aAdd(aSA1Auto,{"A1_COD"		,"XBX139"				,Nil})
	aAdd(aSA1Auto,{"A1_LOJA"	,"01"					,Nil})
	aAdd(aSA1Auto,{"A1_NOME"	,"ROTINA AUTOMATICA"	,Nil})
	aAdd(aSA1Auto,{"A1_NREDUZ"	,"ROTAUTO"				,Nil})	
	aAdd(aSA1Auto,{"A1_TIPO"	,"F"					,Nil})
	aAdd(aSA1Auto,{"A1_END"		,"BRAZ LEME"			,Nil})	
	aAdd(aSA1Auto,{"A1_BAIRRO"	,"CASA VERDE"			,Nil})	
	aAdd(aSA1Auto,{"A1_EST"		,"SP"					,Nil})
	aAdd(aSA1Auto,{"A1_MUN"		,"SAO PAULO"			,Nil})
	
	//---------------------------------------------------------
	// Dados do Complemento do Cliente
	//---------------------------------------------------------
	aAdd(aAI0Auto,{"AI0_SALDO"	,30						,Nil})
	
	//------------------------------------
	// Chamada para cadastrar o cliente.
	//------------------------------------
	MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aSA1Auto, nOpcAuto, aAI0Auto) 
	 
	If lMsErroAuto	 
		lRet := lMsErroAuto	
	Else
		Conout("Cliente incluído com sucesso!")
	EndIf
	
EndIf

RpcClearEnv()
             
Return lRet
*/
