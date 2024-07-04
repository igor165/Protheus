#INCLUDE 'GTPA302.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'

Static nTotHrAdic     := 0
Static aTP302RET	  := {}
Static cG302GrdFocus  := ""
Static lG302DelButton
Static lExibtot		  := .T.
Static lConfirm		:= .T.	
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA302()
Cadastro de Agenda/Escala de Viagens
@sample	GTPA302()
@return	oBrowse  Retorna o Cadastro Cadastro de Agenda/Escala de Viagens
@author	Inovação
@since		01/04/2015
@version	P12
/*///------------------------------------------------------------------------------------------
Function GTPA302()
		
	Local oBrowse	:= FWMBrowse():New()
	
		oBrowse:SetAlias("GYO")
		oBrowse:SetDescription(STR0001)//"Planejamento da Escala" //"Escala de Colaboradores"
		
		oBrowse:SetMenuDef('GTPA302')
		
		oBrowse:Activate()

Return ( oBrowse )
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
@sample	ModelDef()
@return	oModel - Objeto do Model
@author	Inovação
@since		01/04/2015
@version	P12
/*///------------------------------------------------------------------------------------------
Static Function ModelDef()
	
	Local oModel		:= Nil
	Local oStruGYO	:= FWFormStruct(1,'GYO')
	Local oStruGIE	:= FWFormStruct(1,"GIE")
	Local oStruGYP	:= FWFormStruct(1,"GYP" )   //-- Recebe a estrututa da Tabela de Veículos por linha
	Local oStruGY4	:= FWFormStruct(1,"GY4" )   //-- Recebe a estrututa da Tabela de Veículos por linha
	Local oStruTot	:= FWFormStruct(1,'GYO',{ |cCampo| Alltrim(cCampo) $ "GYO_FILIAL#GYO_CODIGO#GYO_HRVOL#GYO_HRFVOL#GYO_HORAAD#GYO_HORPAG#GYO_HORJOR#GYO_HORDES,#GYO_HRDESP#GYO_RHPLAN" } ) // Totalizadores

	Local cOutCpos	:= ',GID.GID_SEG, GID.GID_TER, GID.GID_QUA, GID.GID_QUI, GID.GID_SEX, GID.GID_SAB, GID.GID_DOM'
	Local aStrGY4	:= {}

	Local bAction := {|oSubMdl,cFldFilter,cOrder,aFldConv,lFilter,aRet|;
						lFilter := .T.,;
						aFldConv := {},;
						cFldFilter := (GTPFld2Str(oModel:GetModel( 'GIEDETAIL' ):GetStruct(),.t.,aFldConv)),;
						cOrder := " GIE_CODGID, GIE_SEQ ",;
						CursorWait(),;
						lFilter := GA408ExecFilter(cFldFilter+cOutCpos,oModel:GetModel("GY4FILTER"),cOrder,aFldConv),;
						Iif(lFilter,aRet := G302BCarga(oModel:GetModel( 'GIEDETAIL' )),aRet := FormLoadGrid(oSubMdl)),;
						CursorArrow() ,;
                        aRet}


	Local bPreVld	:= {|oSubMdl,nlinha,cAction,cField,xValue| GTP302PreTot(oSubMdl,nlinha,cAction,cField,xValue) }

		GA302Struct(oStruGYO,oStruGIE,oStruGYP,oStruGY4,oStruTot,'M')
	
		aStrGY4 := oStruGY4:GetFields()
	
		oModel := MPFormModel():New("GTPA302",/*PreValidMdl*/,{|oModel| GA302AllOK(oModel)},{|oMdl| G302Commit(oMdl)}/*bCommit*/)
	
		oModel:AddFields('GYOMASTER',/*cOwner*/,oStruGYO, {|oSubMdl,cAct,cFld,xVl,b| GA302When(oSubMdl,cAct,cFld,xVl) })//,/*bPosFValid*/, /*bCarga*/ )
		oModel:AddFields('GY4FILTER','GYOMASTER',oStruGY4, {|oSubMdl,cAct,cFld,xVl,b| GA302When(oSubMdl,cAct,cFld,xVl) }/*bPreValid*/,/*bPosFValid*/, /*bCarga*/ )
		oModel:addGrid('GIEDETAIL','GYOMASTER',oStruGIE, /*bPreValid*/  , /*bPosLValid*/ , /*bPre*/,/*bPost*/,bAction /*bLoad*/ )
		oModel:addGrid('GYPDETAIL','GYOMASTER',oStruGYP, bPreVld /*bPreValid*/  , /*bPosLValid*/ , /*bPre*/,/*bPost*/,/*bLoad*/ )
		oModel:AddFields('GYOTOT','GYOMASTER',oStruTot, /*bPreValidacao*/,/*bPosFValid*/, /*bCarga*/ )
		
		oModel:SetRelation( 'GY4FILTER', {{"GY4_FILIAL","xFilial('GY4')"},{"GY4_ESCALA","GYO_CODIGO"},{"GY4_TIPO","'2'"}}, GY4->(IndexKey(1)))

		oModel:SetRelation("GYPDETAIL", {{"GYP_FILIAL","xFilial('GYO')"},{"GYP_ESCALA","GYO_CODIGO"}}, GYP->(IndexKey(1)))

		oModel:SetRelation("GYOTOT", {  {"GYO_FILIAL" ,"xFilial('GYO')"} ,{"GYO_CODIGO","GYO_CODIGO"}}, GYO->(IndexKey(1)))

		oModel:SetDescription(STR0002)//"Planejamento da Escala" //"Planejamento da Escala de Colaboradores"
	
		oModel:GetModel("GIEDETAIL"):SetOnlyQuery(.t.)
		oModel:GetModel("GIEDETAIL"):SetOptional(.t.)
		oModel:GetModel("GIEDETAIL"):SetNoDeleteLine(.t.)
	
		oModel:GetModel("GY4FILTER"):SetOptional(.t.)
		oModel:GetModel("GYPDETAIL"):SetOptional(.t.)
		oModel:GetModel("GYOTOT"):SetOptional(.t.)
		oModel:GetModel("GYOTOT"):SetOnlyQuery(.t.)
	
		oModel:GetModel('GIEDETAIL'):SetMaxLine(9990)
		oModel:GetModel('GYPDETAIL'):SetMaxLine(9990)
	
		oModel:AddRules("GYPDETAIL","GYP_HRINIT","GYOMASTER","GYO_RECCOD",1)
		oModel:AddRules("GYPDETAIL","GYP_HRFIMT","GYOMASTER","GYO_RECCOD",1)
	
		oModel:SetActivate({|oModel| GA308UpdParam(oModel) })
	
		oModel:SetDeActivate({|| G408RSetDestroy() })
	
Return(oModel)
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface
@sample	ViewDef()
@return	oView - Objeto View
@author	Inovação
@since		01/04/2015
@version	P12
/*///------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local oModel	:= FwLoadModel('GTPA302')
	Local oStruGYO	:= FWFormStruct(2,'GYO')
	Local oStruGIE	:= FWFormStruct(2,'GIE')
	Local oStruGYP	:= FWFormStruct(2,'GYP')
	Local oStruGY4	:= FWFormStruct(2,'GY4')
	Local oStruTot	:= FWFormStruct(2,'GYO',{ |cCampo| Alltrim(cCampo) $ "GYO_HRVOL#GYO_HRFVOL#GYO_HORAAD#GYO_HORPAG#GYO_HORJOR#GYO_HORDES#GYO_HRDESP#GYO_RHPLAN" } ) // Totalizadores
	Local oView		:= FWFormView():New()

	Local cOutCpos	:= ',GID.GID_SEG, GID.GID_TER, GID.GID_QUA, GID.GID_QUI, GID.GID_SEX, GID.GID_SAB, GID.GID_DOM'
	
	Local bAction	:= {|| }
	
		GA302Struct(oStruGYO,oStruGIE,oStruGYP,oStruGY4,oStruTot,"V")
	
		oView:SetModel(oModel)
		oView:SetDescription(STR0003)  //"Planejamento da Escala"
	
		oView:AddField("VIEW_GYO", oStruGYO,"GYOMASTER")
		oView:AddField("VIEW_GY4",oStruGY4,"GY4FILTER")
		oView:AddGrid("VIEW_GIE",oStruGIE,"GIEDETAIL")
		oView:AddGrid("VIEW_GYP",oStruGYP,"GYPDETAIL")
		oView:AddField('VIEW_TOT', oStruTot, 'GYOTOT')
	
		oView:AddOtherObject("VIEW_BTN", {|oPanel| GA302Buttons(oPanel)})
	
		oView:AddIncrementField("VIEW_GYP", "GYP_ITEM" )
	
		oView:CreateHorizontalBox( 'SUPERIOR'  	, 35)
		oView:CreateHorizontalBox( 'INFERIOR'	, 50)
		oView:CreateHorizontalBox( 'TOTALIZADOR', 15)
	
		oView:CreateVerticalBox( 'DIRSUP', 50,"SUPERIOR")
		oView:CreateVerticalBox( 'ESQSUP', 50,"SUPERIOR")
	
		oView:CreateVerticalBox( 'ESQINF', 47,"INFERIOR")
		oView:CreateVerticalBox( 'CENINF', 06,"INFERIOR")
		oView:CreateVerticalBox( 'DIRINF', 47,"INFERIOR")
	
		oView:SetOwnerView('VIEW_GY4','DIRSUP')
		oView:SetOwnerView('VIEW_GYO','ESQSUP')
	
		oView:SetOwnerView('VIEW_GIE','ESQINF')
		oView:SetOwnerView('VIEW_BTN','CENINF')
		oView:SetOwnerView('VIEW_GYP','DIRINF')
		oView:SetOwnerView('VIEW_TOT','TOTALIZADOR')
	
		oView:EnableTitleView('VIEW_GYO',STR0004) //'Dados Escala'
		oView:EnableTitleView('VIEW_GY4',STR0005) //'Filtro de Horários'
		oView:EnableTitleView('VIEW_GIE',STR0006) //'Selecione os Horários'
		oView:EnableTitleView('VIEW_GYP',STR0007) //'Montagem da Escala'
		oView:EnableTitleView('VIEW_TOT',STR0008) //'Totais de Horas'
	
		bAction := {|oView,cFldFilter,cOrder,aFldConv,lFilter|;
						lFilter := .f.,;
						aFldConv := {},;
						cFldFilter := GTPFld2Str(oView:GetModel("GIEDETAIL"):GetStruct(),.t.,aFldConv),;
						cOrder := " GIE_CODGID, GIE_SEQ ",;
						CursorWait(),;
						lFilter := GA302ChkFilter(oView),;
						lFilter := Iif(lFilter, GA408ExecFilter(cFldFilter+cOutCpos,oView:GetModel("GY4FILTER"),cOrder,aFldConv),.f.),;
						Iif(lFilter,GA302FillGIE(oView),nil),;
						CursorArrow() }
	
		oView:AddUserButton(STR0009,"",bAction ,,VK_F5) //"Executar Filtro"
		oView:AddUserButton(STR0014,"",{|| G302MoveHor(1) }) //"Copia o horário selecionado"
		oView:AddUserButton(STR0015,"",{|| G302MoveHor(2) }) //"Voltar o horário selecionado"
		oView:AddUserButton(STR0016,"",{|| G302MoveHor(3) }) //"Voltar todos os horários"
	
		oView:GetViewObj("VIEW_GIE")[3]:SetGotFocus({||cG302GrdFocus := "VIEW_GIE" })
		oView:GetViewObj("VIEW_GYP")[3]:SetGotFocus({||cG302GrdFocus := "VIEW_GYP" })
	
		oView:GetModel('GYPDETAIL'):SetNoDeleteLine(.T.)
		oView:GetModel("GIEDETAIL"):SetNoInsertLine(.T.)
	
		oView:SetViewProperty("GIEDETAIL", "GRIDSEEK", {.T.})
		oView:SetViewProperty("GYPDETAIL", "GRIDSEEK", {.T.})
		oView:SetViewProperty("GIEDETAIL", "GRIDFILTER", {.T.})
		oView:SetViewProperty("GYPDETAIL", "GRIDFILTER", {.T.})
			
		oView:SetViewProperty( "GYOTOT", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_LEFT , 24, 5  } )


		oView:SetViewProperty( "*", "GRIDNOORDER")

Return ( oView )
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA302Struct()
Definição da Estrutura do MVC, tanto para view quanto para o model
@sample	GA302Struct(oStruGYO,oStruGIE,oStruGYP,oStruGY4,oStruTot,cTipo)
@params	oStruGYO: Objeto.	Instância da Classe FwFormModelStruct ou FwFormViewStruct
		oStruGIE: Objeto.	Instância da Classe FwFormModelStruct ou FwFormViewStruct
		oStruGYP: Objeto.	Instância da Classe FwFormModelStruct ou FwFormViewStruct
		oStruGY4: Objeto.	Instância da Classe FwFormModelStruct ou FwFormViewStruct
		oStruTot: Objeto.	Instância da Classe FwFormModelStruct ou FwFormViewStruct
		cTipo:	Caractere. Tipo de Estrutura que será definida. "M" - Modelo, "V" View	
@author	Inovação
@since		17/08/2015
@version	P12
/*///------------------------------------------------------------------------------------------
Static Function GA302Struct(oStruGYO,oStruGIE,oStruGYP,oStruGY4,oStruTot,cTipo)

	Local cFieldsIn	:= ""
	Local nI		:= 0
	Local aFldStr	:= {}

	Default cTipo := "M"
	
		If ( cTipo == "M" )
		
			If ValType( oStruGYP ) == "O"
				
				oStruGYP:addField("bkp Hr Ini Trab","backup Hr. Início Trabalho","BKP_HRINIT","C",4)	//AddField(<cTitulo >, <cTooltip >, <cIdField >, <cTipo >, <nTamanho >
				oStruGYP:addField("bkp Hr Fim Trab","backup Hr. Fim Trabalho","BKP_HRFIMT","C",4) 		//AddField(<cTitulo >, <cTooltip >, <cIdField >, <cTipo >, <nTamanho >
			// -------------------------------------+
			// DEFINE OBRIGATORIEDADE DOS CAMPOS GYP|
			// -------------------------------------+
				oStruGYP:SetProperty( '*'	,MODEL_FIELD_OBRIGAT, .F.)
				oStruGYP:SetProperty( 'GYP_ESCALA'	,MODEL_FIELD_OBRIGAT, .F.)
				oStruGYP:SetProperty( 'GYP_LINSTD'	,MODEL_FIELD_OBRIGAT, .F.)
				oStruGYP:SetProperty( 'GYP_HRINIT' , MODEL_FIELD_OBRIGAT, .T.)
				oStruGYP:SetProperty( 'GYP_HRFIMT' , MODEL_FIELD_OBRIGAT, .T.)
				oStruGYP:SetProperty( 'GYP_SRVDES' , MODEL_FIELD_OBRIGAT, .T.)
			
				// -------------------------------------+
				// DEFINE VALID DOS CAMPOS GYP|
				// -------------------------------------+
				oStruGYP:AddTrigger("GYP_HRINIT", "GYP_HRINIT"  ,{ || .T. }, { |oMdl,cField,xVal,d,e,f|GTPA302TRG(oMdl,cField,xVal) } )
				oStruGYP:AddTrigger("GYP_HRFIMT", "GYP_HRFIMT"  ,{ || .T. }, { |oMdl,cField,xVal,d,e,f|GTPA302TRG(oMdl,cField,xVal) } )
				oStruGYP:AddTrigger("GYP_PASSAG", "GYP_PASSAG"  ,{ || .T. }, { |oMdl,cField,xVal,d,e,f|GTPA302TRG(oMdl,cField,xVal) } )
				oStruGYP:AddTrigger("GYP_TIPO"	, "GYP_TIPO"  	,{ || .T. }, { |oMdl,cField,xVal,d,e,f|GTPA302TRG(oMdl,cField,xVal) } )
				oStruGYP:AddTrigger("GYP_SRVEXT", "GYP_SRVEXT"  ,{ || .T. }, { |oMdl,cField,xVal,d,e,f|GTPA302TRG(oMdl,cField,xVal) } )
                
				
				oStruGYP:SetProperty("*", MODEL_FIELD_VALID , {||.T.})
				oStruGYP:SetProperty( 'GYP_TIPO'	, MODEL_FIELD_VALID, {|oGrid,cCpo,xValAtu,nLinha,xValOld| GA302VLDGYP(oGrid,cCpo,xValAtu,nLinha,xValOld) })
                oStruGYP:SetProperty( 'GYP_SRVORI'	, MODEL_FIELD_VALID, {|oGrid,cCpo,xValAtu,nLinha,xValOld| GA302VLDGYP(oGrid,cCpo,xValAtu,nLinha,xValOld) })
                oStruGYP:SetProperty( 'GYP_SRVDES'	, MODEL_FIELD_VALID, {|oGrid,cCpo,xValAtu,nLinha,xValOld| GA302VLDGYP(oGrid,cCpo,xValAtu,nLinha,xValOld) })
                oStruGYP:SetProperty( 'GYP_SRVEXT'	, MODEL_FIELD_VALID, {|oGrid,cCpo,xValAtu,nLinha,xValOld| GA302VLDGYP(oGrid,cCpo,xValAtu,nLinha,xValOld) })

				oStruGYP:SetProperty( 'GYP_TIPO'	, MODEL_FIELD_INIT, {|oGrid,cCpo| '2' })
				oStruGYP:SetProperty( 'GYP_TIPO'	, MODEL_FIELD_WHEN, {|oGrid,cCpo| GA302X3WhenGYP(oGrid, cCpo) })
				oStruGYP:SetProperty( 'GYP_LINSTD'	, MODEL_FIELD_WHEN, {|oGrid,cCpo| GA302X3WhenGYP(oGrid, cCpo) })
				oStruGYP:SetProperty( 'GYP_LINCOD'	, MODEL_FIELD_WHEN, {|oGrid,cCpo| GA302X3WhenGYP(oGrid, cCpo) })
				oStruGYP:SetProperty( 'GYP_SRVEXT'	, MODEL_FIELD_WHEN, {|oGrid,cCpo| GA302X3WhenGYP(oGrid, cCpo) })
				oStruGYP:SetProperty( 'GYP_PFUNC'	, MODEL_FIELD_WHEN, {|oGrid,cCpo| GA302X3WhenGYP(oGrid, cCpo) })
				oStruGYP:SetProperty( 'GYP_HRINIT' , MODEL_FIELD_WHEN, {|oGrid,cCpo| GA302X3WhenGYP(oGrid, cCpo) })
				oStruGYP:SetProperty( 'GYP_HORORI' , MODEL_FIELD_WHEN, {|oGrid,cCpo| GA302X3WhenGYP(oGrid, cCpo) })
				oStruGYP:SetProperty( 'GYP_SRVORI' , MODEL_FIELD_WHEN, {|oGrid,cCpo| GA302X3WhenGYP(oGrid, cCpo) })
				oStruGYP:SetProperty( 'GYP_SRVDES' , MODEL_FIELD_WHEN, {|oGrid,cCpo| GA302X3WhenGYP(oGrid, cCpo) })
				oStruGYP:SetProperty( 'GYP_HORDES' , MODEL_FIELD_WHEN, {|oGrid,cCpo| GA302X3WhenGYP(oGrid, cCpo) })
				oStruGYP:SetProperty( 'GYP_HRFIMT' , MODEL_FIELD_WHEN, {|oGrid,cCpo| GA302X3WhenGYP(oGrid, cCpo) })
				oStruGYP:SetProperty( 'GYP_SEQ'    , MODEL_FIELD_WHEN, {|oGrid,cCpo| GA302X3WhenGYP(oGrid, cCpo) })
				oStruGYP:SetProperty( 'GYP_PASSAG' , MODEL_FIELD_WHEN, {|oGrid,cCpo| GA302X3WhenGYP(oGrid, cCpo) })
				oStruGYP:SetProperty( 'GYP_PASSAG'	, MODEL_FIELD_INIT, {|| '2' })
			Endif
		
			If ValType( oStruGIE ) == "O"
		
				oStruGIE:AddField(	"Codigo+Sequencia",;	// 	[01]  C   Titulo do campo // "Arq. Flash"
									"Codigo+Sequencia",;	// 	[02]  C   ToolTip do campo // "Diretório dos arquivos Flash"
									"CODSEQ",;	// 	[03]  C   Id do Field
									"C",;		// 	[04]  C   Tipo do campo
									TamSx3("GIE_CODGID")[1]+TamSx3("GIE_SEQ")[1],;		// 	[05]  N   Tamanho do campo
									0,;			// 	[06]  N   Decimal do campo
									Nil,;		// 	[07]  B   Code-block de validação do campo
									Nil,;		// 	[08]  B   Code-block de validação When do campo
									Nil,;		//	[09]  A   Lista de valores permitido do campo
									.F.,;		//	[10]  L   Indica se o campo tem preenchimento obrigatório
									NIL,;		//	[11]  B   Code-block de inicializacao do campo
									.F.,;		//	[12]  L   Indica se trata-se de um campo chave
									.F.,;		//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.)		// 	[14]  L   Indica se o campo é virtual
	
				oStruGIE:AddField(	"Segunda",;	// 	[01]  C   Titulo do campo // "Arq. Flash"
									"Segunda",;	// 	[02]  C   ToolTip do campo // "Diretório dos arquivos Flash"
									"GID_SEG",;	// 	[03]  C   Id do Field
									"L",;		// 	[04]  C   Tipo do campo
									1,;		// 	[05]  N   Tamanho do campo
									0,;			// 	[06]  N   Decimal do campo
									Nil,;		// 	[07]  B   Code-block de validação do campo
									Nil,;		// 	[08]  B   Code-block de validação When do campo
									Nil,;		//	[09]  A   Lista de valores permitido do campo
									.F.,;		//	[10]  L   Indica se o campo tem preenchimento obrigatório
									NIL,;		//	[11]  B   Code-block de inicializacao do campo
									.F.,;		//	[12]  L   Indica se trata-se de um campo chave
									.F.,;		//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.)		// 	[14]  L   Indica se o campo é virtual
	
				oStruGIE:AddField(	"Terça",;	// 	[01]  C   Titulo do campo // "Arq. Flash"
									"Terça",;	// 	[02]  C   ToolTip do campo // "Diretório dos arquivos Flash"
									"GID_TER",;	// 	[03]  C   Id do Field
									"L",;		// 	[04]  C   Tipo do campo
									1,;			// 	[05]  N   Tamanho do campo
									0,;			// 	[06]  N   Decimal do campo
									Nil,;		// 	[07]  B   Code-block de validação do campo
									Nil,;		// 	[08]  B   Code-block de validação When do campo
									Nil,;		//	[09]  A   Lista de valores permitido do campo
									.F.,;		//	[10]  L   Indica se o campo tem preenchimento obrigatório
									NIL,;		//	[11]  B   Code-block de inicializacao do campo
									.F.,;		//	[12]  L   Indica se trata-se de um campo chave
									.F.,;		//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.)		// 	[14]  L   Indica se o campo é virtual
	
				oStruGIE:AddField(	"Quarta",;	// 	[01]  C   Titulo do campo // "Arq. Flash"
									"Quarta",;	// 	[02]  C   ToolTip do campo // "Diretório dos arquivos Flash"
									"GID_QUA",;	// 	[03]  C   Id do Field
									"L",;		// 	[04]  C   Tipo do campo
									1,;			// 	[05]  N   Tamanho do campo
									0,;			// 	[06]  N   Decimal do campo
									Nil,;		// 	[07]  B   Code-block de validação do campo
									Nil,;		// 	[08]  B   Code-block de validação When do campo
									Nil,;		//	[09]  A   Lista de valores permitido do campo
									.F.,;		//	[10]  L   Indica se o campo tem preenchimento obrigatório
									NIL,;		//	[11]  B   Code-block de inicializacao do campo
									.F.,;		//	[12]  L   Indica se trata-se de um campo chave
									.F.,;		//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.)		// 	[14]  L   Indica se o campo é virtual
	
				oStruGIE:AddField(	"Quinta",;	// 	[01]  C   Titulo do campo // "Arq. Flash"
									"Quinta",;	// 	[02]  C   ToolTip do campo // "Diretório dos arquivos Flash"
									"GID_QUI",;	// 	[03]  C   Id do Field
									"L",;		// 	[04]  C   Tipo do campo
									1,;			// 	[05]  N   Tamanho do campo
									0,;			// 	[06]  N   Decimal do campo
									Nil,;		// 	[07]  B   Code-block de validação do campo
									Nil,;		// 	[08]  B   Code-block de validação When do campo
									Nil,;		//	[09]  A   Lista de valores permitido do campo
									.F.,;		//	[10]  L   Indica se o campo tem preenchimento obrigatório
									NIL,;		//	[11]  B   Code-block de inicializacao do campo
									.F.,;		//	[12]  L   Indica se trata-se de um campo chave
									.F.,;		//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.)		// 	[14]  L   Indica se o campo é virtual		
	
				oStruGIE:AddField(	"Sexta",;	// 	[01]  C   Titulo do campo // "Arq. Flash"
									"Sexta",;	// 	[02]  C   ToolTip do campo // "Diretório dos arquivos Flash"
									"GID_SEX",;	// 	[03]  C   Id do Field
									"L",;		// 	[04]  C   Tipo do campo
									1,;			// 	[05]  N   Tamanho do campo
									0,;			// 	[06]  N   Decimal do campo
									Nil,;		// 	[07]  B   Code-block de validação do campo
									Nil,;		// 	[08]  B   Code-block de validação When do campo
									Nil,;		//	[09]  A   Lista de valores permitido do campo
									.F.,;		//	[10]  L   Indica se o campo tem preenchimento obrigatório
									NIL,;		//	[11]  B   Code-block de inicializacao do campo
									.F.,;		//	[12]  L   Indica se trata-se de um campo chave
									.F.,;		//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.)		// 	[14]  L   Indica se o campo é virtual	

				oStruGIE:AddField(	"Sábado",;	// 	[01]  C   Titulo do campo // "Arq. Flash"
									"Sábado",;	// 	[02]  C   ToolTip do campo // "Diretório dos arquivos Flash"
									"GID_SAB",;	// 	[03]  C   Id do Field
									"L",;		// 	[04]  C   Tipo do campo
									1,;			// 	[05]  N   Tamanho do campo
									0,;			// 	[06]  N   Decimal do campo
									Nil,;		// 	[07]  B   Code-block de validação do campo
									Nil,;		// 	[08]  B   Code-block de validação When do campo
									Nil,;		//	[09]  A   Lista de valores permitido do campo
									.F.,;		//	[10]  L   Indica se o campo tem preenchimento obrigatório
									NIL,;		//	[11]  B   Code-block de inicializacao do campo
									.F.,;		//	[12]  L   Indica se trata-se de um campo chave
									.F.,;		//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.)		// 	[14]  L   Indica se o campo é virtual	

				oStruGIE:AddField(	"Domingo",;	// 	[01]  C   Titulo do campo // "Arq. Flash"
									"Domingo",;	// 	[02]  C   ToolTip do campo // "Diretório dos arquivos Flash"
									"GID_DOM",;	// 	[03]  C   Id do Field
									"L",;		// 	[04]  C   Tipo do campo
									1,;			// 	[05]  N   Tamanho do campo
									0,;			// 	[06]  N   Decimal do campo
									Nil,;		// 	[07]  B   Code-block de validação do campo
									Nil,;		// 	[08]  B   Code-block de validação When do campo
									Nil,;		//	[09]  A   Lista de valores permitido do campo
									.F.,;		//	[10]  L   Indica se o campo tem preenchimento obrigatório
									NIL,;		//	[11]  B   Code-block de inicializacao do campo
									.F.,;		//	[12]  L   Indica se trata-se de um campo chave
									.F.,;		//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.)		// 	[14]  L   Indica se o campo é virtual		
		
				oStruGIE:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
				oStruGIE:SetProperty("*", MODEL_FIELD_VALID , {||.T.})

			Endif
		
			If ( ValType(oStruTot) == "O" )
				oStruTot:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
			EndIf
		
			If ValType( oStruGYO ) == "O"

				oStruGYO:AddTrigger("GYO_RECCOD", "GYO_RECCOD"  ,{ || .T. }, { |oModel, cCpo, xValue | RetTpRec( oModel, cCpo, xValue ) } )					
				oStruGYO:SetProperty('GYO_RECCOD', MODEL_FIELD_WHEN, {|| Empty(FWFldGet("GYO_RECCOD"))} )
				oStruGYO:SetProperty('GYO_SETOR' , MODEL_FIELD_WHEN, {|| Empty(FWFldGet("GYO_SETOR"))} )
		
			EndIf
			
		Else
	
			//Ajusta quais os campos que deverão aparecer na tela - Fields GYOMASTER
			cFieldsIn := "GYO_CODIGO|GYO_DESCRI|GYO_RECCOD|GYO_RECDES|GYO_SETOR"
			cFieldsIn += "GYO_SEG|GYO_TER|GYO_QUA|GYO_QUI|GYO_SEX|GYO_SAB|GYO_DOM"
	
			aFldStr := aClone(oStruGYO:GetFields())
	
			For nI := 1 to Len(aFldStr)
	
				If ( !(aFldStr[nI,1] $ cFieldsIn) )
					oStruGYO:RemoveField(aFldStr[nI,1])
				EndIf
	
			Next nI
	
			If ValType( oStruGIE ) == "O"
			
				//Adicionar os campos
				oStruGIE:AddField("GID_SEG"	,"10",'Segunda'	,''	,{''}	,"L",,Nil,Nil,.T.,Nil)			
				oStruGIE:AddField("GID_TER"	,"11",'Terça'	,''	,{''}	,"L",,Nil,Nil,.T.,Nil)	
				oStruGIE:AddField("GID_QUA"	,"12",'Quarta'	,''	,{''}	,"L",,Nil,Nil,.T.,Nil)	
				oStruGIE:AddField("GID_QUI"	,"13",'Quinta'	,''	,{''}	,"L",,Nil,Nil,.T.,Nil)	
				oStruGIE:AddField("GID_SEX"	,"14",'Sexta'	,''	,{''}	,"L",,Nil,Nil,.T.,Nil)	
				oStruGIE:AddField("GID_SAB"	,"15",'Sábado'	,''	,{''}	,"L",,Nil,Nil,.T.,Nil)	
				oStruGIE:AddField("GID_DOM"	,"16",'Domingo'	,''	,{''}	,"L",,Nil,Nil,.T.,Nil)	
				
				//Ajusta quais os campos que deverão aparecer na tela - Grid GIEDETAIL
				cFieldsIn := " GIE_CODGID|GIE_SENTID|GIE_HORLOC|GIE_DESCLP|GIE_HORDES|GIE_DESCLD|GIE_NUMSRV"
				cFieldsIn += "|GID_SEG|GID_TER|GID_QUA|GID_QUI|GID_SEX|GID_SAB|GID_DOM"
			
				aFldStr := aClone(oStruGIE:GetFields())
		
				For nI := 1 to Len(aFldStr)
		
					If ( !(aFldStr[nI,1] $ cFieldsIn) )
						oStruGIE:RemoveField(aFldStr[nI,1])
					EndIf
		
				Next nI
															
				oStruGIE:SetProperty("GIE_CODGID"	, MVC_VIEW_ORDEM , "01")
				oStruGIE:SetProperty("GIE_SENTID"	, MVC_VIEW_ORDEM , "02")
				oStruGIE:SetProperty("GIE_HORLOC"	, MVC_VIEW_ORDEM , "03")
				oStruGIE:SetProperty("GIE_DESCLP"	, MVC_VIEW_ORDEM , "04")
				oStruGIE:SetProperty("GIE_HORDES"	, MVC_VIEW_ORDEM , "05")
				oStruGIE:SetProperty("GIE_DESCLD"	, MVC_VIEW_ORDEM , "06")
				oStruGIE:SetProperty("GIE_NUMSRV"	, MVC_VIEW_ORDEM , "07")
				oStruGIE:SetProperty("GID_SEG"		, MVC_VIEW_ORDEM , "08")
				oStruGIE:SetProperty("GID_TER"		, MVC_VIEW_ORDEM , "09")
				oStruGIE:SetProperty("GID_QUA"		, MVC_VIEW_ORDEM , "10")
				oStruGIE:SetProperty("GID_QUI"		, MVC_VIEW_ORDEM , "11")
				oStruGIE:SetProperty("GID_SEX"		, MVC_VIEW_ORDEM , "12")
				oStruGIE:SetProperty("GID_SAB"		, MVC_VIEW_ORDEM , "13")
				oStruGIE:SetProperty("GID_DOM"		, MVC_VIEW_ORDEM , "14")
			
			EndIf		
				
			//Ajusta quais os campos que deverão aparecer na tela - Grid GYPDETAIL
			cFieldsIn := "GYP_ITEM|GYP_LINCOD|GYP_LINSTD|GYP_TIPO|"
			cFieldsIn += "GYP_HORORI|GYP_SRVORI|GYP_DESORI|GYP_HORDES|"
			cFieldsIn += "GYP_SRVDES|GYP_DESDES|GYP_SRVEXT|GYP_PFUNC|"
			cFieldsIn += "GYP_HRINIT|GYP_HRFIMT|GYP_PASSAG|GYP_DIA|" // |GYP_CODGID
		
			aFldStr := aClone(oStruGYP:GetFields())
	
			For nI := 1 to Len(aFldStr)
	
				If ( !(aFldStr[nI,1] $ cFieldsIn) )
					oStruGYP:RemoveField(aFldStr[nI,1])
				EndIf
	
			Next nI
	    
			If ValType( oStruGYP ) == "O"
				
				oStruGYP:SetProperty("GYP_ITEM"	, 	MVC_VIEW_ORDEM , "01")
				oStruGYP:SetProperty("GYP_LINCOD", 	MVC_VIEW_ORDEM , "02")
				oStruGYP:SetProperty("GYP_LINSTD", 	MVC_VIEW_ORDEM , "03")
				oStruGYP:SetProperty("GYP_HRINIT", 	MVC_VIEW_ORDEM , "04")
				oStruGYP:SetProperty("GYP_HORORI", 	MVC_VIEW_ORDEM , "05")
				oStruGYP:SetProperty("GYP_HORDES", 	MVC_VIEW_ORDEM , "06")
				oStruGYP:SetProperty("GYP_HRFIMT", 	MVC_VIEW_ORDEM , "07")
				oStruGYP:SetProperty("GYP_SRVORI", 	MVC_VIEW_ORDEM , "08")
				oStruGYP:SetProperty("GYP_DESORI", 	MVC_VIEW_ORDEM , "09")
				oStruGYP:SetProperty("GYP_SRVDES", 	MVC_VIEW_ORDEM , "10")
				oStruGYP:SetProperty("GYP_DESDES", 	MVC_VIEW_ORDEM , "11")
				oStruGYP:SetProperty("GYP_DIA",		MVC_VIEW_ORDEM , "12")
	    	
			Endif
		
			//Ajuste de campos do Grid - GY4FILTER
			oStruGY4:RemoveField("GY4_ESCALA")
			oStruGY4:RemoveField("GY4_TIPO")
		
			If ValType( oStruTot ) == "O"
				
				oStruTot:SetProperty("GYO_HRVOL", MVC_VIEW_ORDEM , "01")
				oStruTot:SetProperty("GYO_HRFVOL", MVC_VIEW_ORDEM , "02")
				oStruTot:SetProperty("GYO_HRDESP", MVC_VIEW_ORDEM , "03")
				oStruTot:SetProperty("GYO_HORDES", MVC_VIEW_ORDEM , "04")
				oStruTot:SetProperty("GYO_HORAAD", MVC_VIEW_ORDEM , "05")
				oStruTot:SetProperty("GYO_HORPAG", MVC_VIEW_ORDEM , "06")
			  
				if lExibtot
		    
					oStruTot:SetProperty("GYO_HORJOR", MVC_VIEW_ORDEM , "07")
		    
				Else
			    
					oStruTot:RemoveField("GYO_HORJOR")
			    		
				EndIf
			
			Endif
		
			If ( ValType( oStruGYO ) == "O" )
			
				oStruGYO:SetProperty("GYO_CODIGO", MVC_VIEW_CANCHANGE,.F.)
			
			EndIf
		
			If ( ValType( oStruGIE ) == "O" )
			
				oStruGIE:SetProperty("*", MVC_VIEW_CANCHANGE,.F.)
				
			EndIf
	
			//Atualiza variável de controle para aplicação de regras referente horas fora volante.
			if ALTERA
			
				RetTpRec( Nil, 'GYO_RECCOD', GYO->GYO_RECCOD )
				
			EndIf
			
		EndIf

Return()
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
@sample	MenuDef()
@return	aRotina - Array com opções do menu
@author	Inovação
@since		01/04/2015
@version	P12
/*///------------------------------------------------------------------------------------------
Static Function MenuDef()
	
	Local aRotina	:= {}

		ADD OPTION aRotina TITLE STR0010	ACTION 'VIEWDEF.GTPA302' OPERATION 2 ACCESS 0  //"Visualizar"
		ADD OPTION aRotina TITLE STR0011	ACTION 'VIEWDEF.GTPA302' OPERATION 3 ACCESS 0   //"Incluir"
		ADD OPTION aRotina TITLE STR0012	ACTION 'VIEWDEF.GTPA302' OPERATION 4 ACCESS 0  //"Alterar"
		ADD OPTION aRotina TITLE STR0013	ACTION 'VIEWDEF.GTPA302' OPERATION 5 ACCESS 0  //"Excluir"
	
Return ( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA408Button
Botoes que irão transferir horarios de um lado par ao outro
@author Fernando Amorim(Cafu)
@since 04/07/2017
@version
/*///-------------------------------------------------------------------
Static Function GA302Buttons(oPanel)

	Local oBtn1,oBtn2,oBtn3

	oBtn1 := TBitmap():New(40	, 15,25,25,,"NEXT",.T.,oPanel,;
		{|| G302MoveHor(1) },,.F.,.F.,,,.F.,,.T.,,.F.)
	oBtn1:CTOOLTIP := STR0014 //"Copia o horário selecionado"

	oBtn2 := TBitmap():New(090	, 15,25,25,,"PREV",.T.,oPanel,;
		{|| G302MoveHor(2)},,.F.,.F.,,,.F.,,.T.,,.F.)
	oBtn2:CTOOLTIP := STR0015 //"Voltar o horário selecionado"

	oBtn3 := TBitmap():New(115	, 15,25,25,,"PGPREV",.T.,oPanel,;
		{|| G302MoveHor(3)},,.F.,.F.,,,.F.,,.T.,,.F.)

	oBtn3:CTOOLTIP := STR0016     //"Voltar todos os horários"

Return()
//-------------------------------------------------------------------
/*/{Protheus.doc} MoveHorar
Função que irá transferir horarios de um lado par ao outro
@author Fernando Amorim(Cafu)
@since 05/07/2017
@version
/*///-------------------------------------------------------------------
Static Function G302MoveHor( nBt )

	Local oModel		:= FWModelActive()
	Local oMdlSel1	 	:= oModel:GetModel( 'GIEDETAIL' )
	Local oMdlSel2	 	:= oModel:GetModel( 'GYPDETAIL' )

	Local nY			:= 0
	Local nX			:= 0
	Local nI			:= 0
	Local nlinhaSel1	:= 0
	Local nlinhaSel2	:= 0
	Local nLinAtSel2	:= 0
	Local nNewLine		:= 0
	Local nP			:= 0

	Local aStruct		:= {}
	Local aValues		:= {}
	Local aDePara		:= {}

	Local cLocIni		:= ''
	Local cLocFim		:= ''

	Local lRet			:= .T.

	Local xValue
	If oModel:GetOperation() <> MODEL_OPERATION_INSERT .and.  oModel:GetOperation() <> MODEL_OPERATION_UPDATE
		Return()
	Endif
	If ( Empty(oModel:GetModel("GYOMASTER"):GetValue("GYO_RECCOD")) ) .OR. ( Empty(oModel:GetModel("GYOMASTER"):GetValue("GYO_SETOR")) )

		FwAlertHelp( "Tipo de Recurso e Setor " , "Informe um tipo de recurso e o código do Setor." )

		Return()
	
	EndIf

		// AAdd(aDePara,{"GIE_COD","GYP_CODGIE"})
		AAdd(aDePara,{"GIE_CODGID","GYP_CODGID"})
	
		AAdd(aDePara,{"", "GYP_ESCALA"})
		AAdd(aDePara,{"", "GYP_HRINIT",{|a,b,c,d| G302SetHr(a,b,c,d,"I") }})
		AAdd(aDePara,{"", "GYP_HRFIMT",{|a,b,c,d| G302SetHr(a,b,c,d,"F")}})
		AAdd(aDePara,{"", "GYP_ITEM"})
		AAdd(aDePara,{"", "GYP_PFUNC"})
		AAdd(aDePara,{"", "GYP_SRVEXT"})
		AAdd(aDePara,{"", "GYP_TIPO",{|a,b| G302SetType(a,b)}})
		AAdd(aDePara,{"GIE_DIA", ""})
		AAdd(aDePara,{"GIE_DTALT", ""})
		AAdd(aDePara,{"GIE_DTATU", ""})
		AAdd(aDePara,{"GIE_HIST", ""})
		AAdd(aDePara,{"GIE_HORCAB", ""})
		AAdd(aDePara,{"GIE_HORDES", "GYP_HORDES"})
		AAdd(aDePara,{"GIE_HORLOC", "GYP_HORORI"})
		AAdd(aDePara,{"GIE_HRATU", ""})
		AAdd(aDePara,{"GIE_IDLOCD", "GYP_SRVDES"})
		AAdd(aDePara,{"GIE_DESCLP","GYP_DESORI"})
		AAdd(aDePara,{"GIE_DESCLD","GYP_DESDES"})
		AAdd(aDePara,{"GIE_IDLOCP", "GYP_SRVORI"})
		AAdd(aDePara,{"GIE_ITEM", ""})
		AAdd(aDePara,{"GIE_LINHA", "GYP_LINCOD",{|a,b,c,d| GA302SetLine(a,b,c,d)}})
		AAdd(aDePara,{"GIE_LOCHOR", ""})
		AAdd(aDePara,{"GIE_REVISA", ""})
		AAdd(aDePara,{"GIE_SECHOR", ""})
		AAdd(aDePara,{"GIE_SENTID", "GYP_LINSTD",{|a,b,c,d| GA302SetLine(a,b,c,d)}})
		AAdd(aDePara,{"GIE_SEQ", "GYP_SEQ"})
		AAdd(aDePara,{"GIE_TEMPO", ""})
		AAdd(aDePara,{"GIE_TPTR", ""})
		AAdd(aDePara,{"GIE_VIA", ""})
	
		oView	:= FwViewActive()
	
		If nBt == 1  // Botão 1 copia o item posicionado para lado esquerdo
			If cG302GrdFocus == 'VIEW_GIE'
						
				If ( !Empty(oMdlSel1:GetValue("CODSEQ")) )
				
					nlinhaSel1 		:= oMdlSel1:GetLine()
					oMdlSel2:GoLine(oMdlSel2:Length())
	
					If (!Empty( oMdlSel2:GetValue("GYP_HRINIT")) .AND. !Empty( oMdlSel2:GetValue("GYP_HRFIMT"))) .Or. oMdlSel2:Length() == 1
			
						GI2->(DbSetOrder(1))
				
						If !Empty(oMdlSel1:GetValue( 'GIE_CODGID' ))
							cLocIni := oMdlSel1:GetValue( 'GIE_IDLOCP' )
						Else
							cLocIni := ""
						Endif
				
						oMdlSel2:GoLine(oMdlSel2:Length())
				
						If !Empty(oMdlSel2:GetValue("GYP_CODGID"))
							cLocFim := oMdlSel2:GetValue( 'GYP_SRVDES' )
						Else
							cLocFim := ""
						Endif
		
						If (ALLTRIM(cLocIni) == alltrim(cLocFim) .Or. Empty(cLocFim))
						
							aStruct 		:= oMdlSel2:GetStruct():GetFields()
							aValues 		:= {}
						
							For nY := 1 to len( aStruct )
							
								nP := aScan(aDePara,{|x| !Empty(x[2]) .And. Alltrim(aStruct[nY][3]) == Alltrim(x[2]) })
							
								If ( nP > 0 )
		
									If ( Empty(aDePara[nP,1]) )
										xValue := GTPCastType(,aStruct[nY,4])
									Else
										If ( oMdlSel1:HasField(aDePara[nP,1]) )
											xValue := oMdlSel1:GetValue( aDePara[nP,1] )
										Else
											xValue := GTPCastType(,aStruct[nY,4])
										EndIf
									EndIf
		
									aAdd( aValues, {	AllTrim( aDePara[nP,1] ),;
										xValue,;
										aStruct[nY][3],;
										Iif(Len(aDePara[nP]) > 2, aDePara[nP,3], "NOCODEBLOCK") } )
		
								EndIf
		
							Next
		
							LoadVSel(oModel,oMdlSel1,oMdlSel2,'GYPDETAIL',aValues,.T.)
						
							oMdlSel1:LoadValue("CODSEQ","")
						
							nlinhaSel2 		:= oMdlSel2:GetLine()
		
							oView:Refresh( 'VIEW_GIE'	)
							oView:Refresh( 'VIEW_GYP'	)
							oMdlSel2:GoLine(nlinhaSel2)
						Else
							FwAlertHelp(STR0018,STR0017) 		 //"Horário"#"Informe uma linha que seja uma sequência"
							Return
						Endif
		
					Else
						FwAlertHelp(STR0018,STR0019) // "Horário"#"Há campos obrigatórios de horário que não foram preenchidos na ultima linha selecionada"
						Return
					Endif
			
				Else
					FwAlertHelp(STR0036, STR0037, STR0018)	//"Horário já foi selecionado"#"Não pode ser repetido um horário"#"Horário"
					Return
				EndIf
			
			Else
				FwAlertHelp(STR0021,STR0020) //STR0021,STR0020	 //"Este botão só funciona quando está posicionado no grid da direita" //"Atenção"
				Return
			Endif
	
		ElseIf nBt == 2  // Botão 2 copia o item posicionado para lado direito novamente(devolve os marcados na frequencia)
			If  cG302GrdFocus == 'VIEW_GYP'
				If oMdlSel2:Length() == oMdlSel2:GetLine()
				// acha o horario no grid da direita e transfere os marcados na frequencia
					If oMdlSel1:SeekLine({ {'GIE_CODGID', oMdlSel2:GetValue( 'GYP_CODGID' )},{"GIE_SEQ",oMdlSel2:GetValue("GYP_SEQ")}})
						oMdlSel1:LoadValue("CODSEQ",oMdlSel1:GetValue("GIE_CODGID")+oMdlSel1:GetValue("GIE_SEQ"))
					
					//deleta a linha do grid lado esquerdo
						If oMdlSel2:Length() == 1
							If Empty( oMdlSel2:GetValue("GYP_HRINIT"))
								oMdlSel2:LoadValue("GYP_HRINIT",GTFormatHour(0, "9999") )
							EndIf
							If Empty( oMdlSel2:GetValue("GYP_HRFIMT"))
								oMdlSel2:LoadValue("GYP_HRFIMT",GTFormatHour(0, "9999") )
							Endif
	
							nNewLine := oMdlSel2:AddLine()
							oMdlSel2:LineShift(1,nNewLine)
						//deleta novamente
							For nI := oMdlSel2:Length() to  1 Step -1
								oMdlSel2:Goline(nI)
								lG302DelButton := .T.
								oMdlSel2:DeleteLine(.T.,.T.)
							Next
						//tira o delete da linha em branco
							oMdlSel2:UnDeleteLine()
							oMdlSel2:LoadValue("GYP_DESDES",'' )
						ElseIf oMdlSel2:GetLine() <> oMdlSel2:Length()
							nlinAtSel2 := oMdlSel2:GetLine()
						
							oMdlSel2:LineShift(oMdlSel2:GetLine(),oMdlSel2:Length())
						//deleta novamente
							lG302DelButton := .T.
							oMdlSel2:DeleteLine(.T.,.T.)
							If nLinAtSel2 <> 1
								oMdlSel2:LineShift( oMdlSel2:Length(),nlinAtSel2)
							Else
								For nI := 1 to oMdlSel2:Length()
									If nI <> oMdlSel2:Length()
										oMdlSel2:LineShift( nI,nI+1)
									Endif
								Next nI
							Endif
						Else
							lG302DelButton := .T.
							oMdlSel2:DeleteLine(.T.,.T.)
						Endif
						nlinhaSel2 		:= oMdlSel2:GetLine()
					
						oView:Refresh( 'VIEW_GIE'	)
						oView:Refresh( 'VIEW_GYP'	)
						oMdlSel2:GoLine(nlinhaSel2)
					Else
						If oMdlSel2:Length() == 1
							nNewLine := oMdlSel2:AddLine()
							oMdlSel2:LineShift(1,nNewLine)
							//deleta novamente
							For nI := oMdlSel2:Length() to  1 Step -1
								oMdlSel2:Goline(nI)
								lG302DelButton := .T.
								oMdlSel2:DeleteLine(.T.,.T.)
							Next
						
							oMdlSel2:UnDeleteLine()
							oMdlSel2:LoadValue("GYP_DESDES",'' )
						Else
							lG302DelButton := .T.
							oMdlSel2:DeleteLine(.T.,.T.)
						Endif
						oView:Refresh( 'VIEW_GYP'	)
						oMdlSel2:GoLine(nlinhaSel2)
					Endif
				Else
					FwAlertHelp(STR0021,STR0022) // STR0021,"Este botão só funciona quando está posicionado no grid da esquerda" //"Só é permitido a exclusão da última linha." //"Atenção"
					Return
					
				EndIf
			Else
				FwAlertHelp(STR0021,STR0023) // STR0021,STR0023	 //"Este botão só funciona quando está posicionado no grid da esquerda" //"Atenção"
				Return
			Endif
		ElseIf nBt == 3  // Botão 3 move todos para lado direito novamente (devolve os marcados na frequencia)
			If  cG302GrdFocus == 'VIEW_GYP'
			
				For nX:= 1 To oMdlSel2:Length()
					oMdlSel2:GoLine(nX)
					If !oMdlSel2:IsDeleted()
						If Empty( oMdlSel2:GetValue("GYP_HRINIT"))
							oMdlSel2:LoadValue("GYP_HRINIT",GTFormatHour(0, "9999") )
						EndIf
						If Empty( oMdlSel2:GetValue("GYP_HRFIMT"))
							oMdlSel2:LoadValue("GYP_HRFIMT",GTFormatHour(0, "9999") )
						Endif
					// acha o horario no grid da direita e transfere os marcados na frequencia
						If oMdlSel1:SeekLine({ {'GIE_CODGID', oMdlSel2:GetValue( 'GYP_CODGID' )},{"GIE_SEQ",oMdlSel2:GetValue("GYP_SEQ")}})
						
							oMdlSel1:LoadValue("CODSEQ",oMdlSel1:GetValue("GIE_CODGID")+oMdlSel1:GetValue("GIE_SEQ"))
						
						//deleta a linha do grid lado esquerdo
					//	lG302DelButton := .T.
					//	oMdlSel2:DeleteLine(.T.,.T.)
						
						Endif
					Endif
				Next
			
				nNewLine := oMdlSel2:AddLine()
				oMdlSel2:LineShift(1,nNewLine)
	
				//deleta novamente
				For nI := oMdlSel2:Length() to  1 Step -1
					oMdlSel2:Goline(nI)
					lG302DelButton := .T.
					oMdlSel2:DeleteLine(.T.,.T.)
				Next
				//tira o delete da linha em branco
				oMdlSel2:UnDeleteLine()
				oMdlSel2:LoadValue("GYP_DESDES",'' )
		
				nlinhaSel2 		:= oMdlSel2:GetLine()
			
				oView:Refresh( 'VIEW_GIE'	)
				oView:Refresh( 'VIEW_GYP'	)
				oMdlSel2:GoLine(nlinhaSel2)
		
			Else
				FwAlertHelp(STR0021,STR0023)	// STR0021,STR0023 //"Este botão só funciona quando está posicionado no grid da esquerda" //"Atenção"
				Return
			Endif
		Endif

		///manutenção de totalizadores
		lRet := MntTots()
			
Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} LoadVSel
Realiza o LoadValue no modelo de dados 
@type function
@author Fernando Amorim(Cafu)
@since 05/07/2017
@version 12.1.16
/*///-------------------------------------------------------------------
Static Function LoadVSel(oModel,oMdlSel1,oMdlSel2,cIdModel,aDados,lLinha)
	
	Local lRet		:= .T.
	Local nX		:= 0
	
	Local oStru		:= oMdlSel2:GetStruct()

	Default lLinha	:= .F.

		If lLinha
			oView	 := FwViewActive()
			
			If oMdlSel2:CanInsertLine()
				
				If  !oMdlSel2:IsEmpty() .and. !( oMdlSel2:Length() == 1 .and. Empty(oMdlSel2:GetValue( 'GYP_SRVORI' )))
				
					If oMdlSel2:Length() == oMdlSel2:AddLine()
						Return .F.
					EndIf
	
				Endif
	
			Else
				MsgInfo(STR0024 + oMdlSel2:GetId() )  //'Modelo não permite incluir Linhas: '
				Return .F.
			EndIf
	
		EndIf
		
		For nX := 1 To Len( aDados )
		
			// Verifica se os campos passados existem na estrutura do modelo
			If oStru:HasField( aDados[nX][3] )
		
				If !( lRet := oModel:LoadValue(cIdModel, aDados[nX][3], aDados[nX][2] ) )
					lRet := .F.
				Else
	
					If ( ValType(aDados[nX,4]) == "B" )
						lRet := Eval(aDados[nX,4],oMdlSel2,oMdlSel2:GetLine(),oMdlSel1,oMdlSel1:GetLine())
					EndIf
					
				EndIf
	
			EndIf
			
			If ( !lRet )
				Exit
			EndIf
	
		Next nX
		
Return lRet
//-------------------------------------------------------------------
 /*/{Protheus.doc} GA302FillGIE()
	Preenche os horários do grid GIEDETAIL
	@type Static Function
	@author Fernando Radu Muscalu
	@since 28/07/2017
	@version version
	@param oView, objeto, instância da classe FwFormView
	@return nil, nulo, sem retorno
	@example
	(examples)
	@see (links_or_references)
/*///-------------------------------------------------------------------
Static Function GA302FillGIE(oView)

	Local oMdlGIE	:= oView:GetModel("GIEDETAIL")
	Local oMdlGYP	:= oView:GetModel("GYPDETAIL")

	Local cAlias	:= ""

	Local nI		:= 0

	Local aFields	:= {}

	Local lRet		:= .T.

		cAlias := GA408ResultSet()
	
		aFields := aClone(oMdlGIE:GetStruct():GetFields())
	
		If ( (cAlias)->(!Eof()) )
	
			While ( (cAlias)->(!Eof()) )
			
				If ( !Empty(oMdlGIE:GetValue("GIE_HORLOC")) )
					lRet := oMdlGIE:Length() < oMdlGIE:AddLine(.t.,.t.)
				EndIf
	
				If ( lRet )
	
					For nI := 1 to Len(aFields)
					
						If ( (cAlias)->(FieldPos(aFields[nI,3])) > 0 )
						
							lRet := oMdlGIE:LoadValue(aFields[nI,3],(cAlias)->&(aFields[nI,3]))
					
						Else
	
							If ( aFields[nI,3] == "GIE_DESCLP" )
								oMdlGIE:LoadValue(aFields[nI,3],POSICIONE('GI1', 1, XFILIAL('GI1') + (cAlias)->GIE_IDLOCP, "GI1_DESCRI"))
							ElseIf ( aFields[nI,3] == "GIE_DESCLD" )
								oMdlGIE:LoadValue(aFields[nI,3],POSICIONE('GI1', 1, XFILIAL('GI1') + (cAlias)->GIE_IDLOCD, "GI1_DESCRI"))
							ElseIf ( aFields[nI,3] == "CODSEQ" )
							
								oMdlGYP:Goline(1)
							
								If ( !oMdlGYP:SeekLine({{"GYP_CODGID",(cAlias)->GIE_CODGID},{"GYP_SEQ",(cAlias)->GIE_SEQ}}) )
									oMdlGIE:LoadValue(aFields[nI,3],(cAlias)->(GIE_CODGID+GIE_SEQ))
								EndIf
									
							EndIf
	
						EndIf
	
						If ( !lRet )
							Exit
						EndIf
	
					NexT nI
				
				Else
					Exit
				EndIf
	
				If ( !lRet )
					Exit
				EndIf
	
				(cAlias)->(DbSkip())
	
			EndDo
	
			If ( lRet )
				oMdlGIE:GoLine(1)
				oView:Refresh("VIEW_GIE")
			EndIf
	
		EndIf

Return()
//-------------------------------------------------------------------
/*/{Protheus.doc} GA302ChkFilter()
	Verifica se o filtro
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 28/07/2017
	@version version
	@param oView, objeto, instância da Classe FwFormView
	@return lRet, lógico, .t. - Permite prosseguir com o filtro
	@example
	(examples)
	@see (links_or_references)
/*///-------------------------------------------------------------------
Static Function GA302ChkFilter(oView)

	Local lRet		:= .F.
	Local cAlias 	:= GA408ResultSet()
	Local nOpera 	:= oView:GetModel():GetOperation()

		If ( !Empty(cAlias) .AND. (nOpera == 3 .Or. nOpera == 4) .AND. !fwisincallstack("FWALERTYESNO")  .AND. !fwisincallstack("FWALERTSUCCESS") .AND. !fwisincallstack("FWALERTERROR") .AND. ;
				!fwisincallstack("FWALERTHELP") .AND. !fwisincallstack("FWALERTEXITPAGE") )
		
			lRet := MsgYesNo(STR0025) //"Os horários já foram filtrados anteriormente. Deseja filtrá-los novamemte?"
	
			If ( lRet )
	
				oView:GetModel("GIEDETAIL"):ClearData()
				oView:Refresh("VIEW_GIE")
				If Select(cAlias) > 0
					(cAlias)->(DbCloseArea())
				EndIf
			
			EndIf
		
		ElseIf Empty(cAlias) .And. oView:IsActive()
		
			lRet := .T.
		
		EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GA302ChkFilter()
	(long_description)
	@type  Static Function
	@author Fernando Radu Muscalu
	@since 28/07/2017
	@version version
	@param oView, objeto, instância da Classe FwFormView
	@return lRet, lógico, .t. - Permite prosseguir com o filtro
	@example
	(examples)
	@see (links_or_references)
/*///-------------------------------------------------------------------
Static Function G302SetType(oSubMdl,nLine)

	Local lRet	:= .t.

		lRet := oSubMdl:LoadValue("GYP_TIPO","1")

Return(lRet)
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA302SetLine()
Função responsável por atualizar a linha e o sentido do registro do lado direito da tela

@sample	GA302SetLine(oSubDir,nLnDir,oSubEsq,nLnEsq)

@params	oSubDir: Objeto.	Instância da Classe FwFormGrid
		nLnDir: Numérico.	Número da linha posicionada no grid
		oSubEsq: Objeto.	Instância da Classe FwFormGrid
		nLnEsq: Numérico.	Número da linha posicionada no grid

@return	lRet: Lógico. .t. - Conseguiu atualizar com sucesso			
@author	Fernando Radu Muscalu
@since		17/08/2015
@version	P12
/*///------------------------------------------------------------------------------------------
Static Function GA302SetLine(oSubDir,nLnDir,oSubEsq,nLnEsq)

	Local lRet	:= .t.
	Local aAreaGID := GID->(GetArea())
	
		GID->(DbSetOrder(1))
	
		If ( GID->(DbSeek(XFilial("GID") + oSubEsq:GetValue("GIE_CODGID",nLnEsq) )) )
		
			lRet := oSubDir:LoadValue("GYP_LINCOD",GID->GID_LINHA) .And.;
				oSubDir:LoadValue("GYP_LINSTD",GID->GID_SENTID )
	
		EndIf
	
		RestArea(aAreaGID)

Return(lRet)
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G302SetHr()
Função responsável por atualizar o horário início de trabalho e o horário fim de trabalho

@sample	G302SetHr(oSubDir,nLnDir,oSubEsq,nLnEsq,cTipo)

@params	oSubDir: Objeto.	Instância da Classe FwFormGrid
		nLnDir: Numérico.	Número da linha posicionada no grid
		oSubEsq: Objeto.	Instância da Classe FwFormGrid
		nLnEsq: Numérico.	Número da linha posicionada no grid
		cTipo: Caractere.	Tipo do horário "I" - Horário Inicial; "F" - Horário final	
@author	Fernando Radu Muscalu
@since		17/08/2015
@version	P12
/*///------------------------------------------------------------------------------------------
Static Function G302SetHr(oSubDir,nLnDir,oSubEsq,nLnEsq,cTipo)

	Local nOriginLine
	Local lRet			:= .t.
	
		nOriginLine := oSubDir:GetLine()
	
		oSubDir:GoLine(nLnDir)
	
		If ( cTipo == "I" ) //Horário Início de Trabalho
		
			lRet := oSubDir:SetValue("GYP_HRINIT",oSubEsq:GetValue("GIE_HORLOC",nLnEsq))
		
		Else				//Horário Fim de Trabalho
		
			lRet := oSubDir:SetValue("GYP_HRFIMT",oSubEsq:GetValue("GIE_HORDES",nLnEsq))
		
		EndIf

		oSubDir:GoLine(nOriginLine)

Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TPTotHrAdic()
Rotina responsavel em retornar o total de Horas de Adicional Noturno, tomando como base a 
faixa de horas definidas nos parâmetros.

@Param		cHrIni = Horário de Inicio do ADN
@Param		cHrFim = Horário de Final do ADN
@Return 	cHrsAdNot = Retorno da função com o total de horas ADN
@sample	TPTotHrAdic()
@author	Inovação
@since		20/11/2015
@version	P12
/*///-----------------------------------------------------------------------------------------
Function TPTotHrAdic(cHrIni,cHrFim)

	Local cINICIO		:= GTFormatHour(SuperGetMV("MV_INIHNOT",,22.00), "99.99")
	Local cFIM			:= GTFormatHour(SuperGetMV("MV_FIMHNOT",,05.00), "99.99")
	Local cHoraIni	:= ""
	Local cHoraFim	:= ""
	Local cHrsAdNot	:= ""
	Local nDia			:= 0
	
		If cHrIni == "00.00"
		
			cHrIni := "24.00"
		
		EndIf
	
		If cHrFim == "00.00"
		
			cHrFim := "24.00"
		
		EndIf
	
		If cHrIni < cHrFim
		
			If (cHrIni > cINICIO) .Or. (cHrIni >= "00.01" .And. cHrFim <= cFIM)
		
				cHoraIni := cHrIni
				cHoraFim := cHrFim
		
			ElseIf cHrIni >= cFIM .And. cHrFim > cINICIO
			
				cHoraIni := cINICIO
				cHoraFim := cHrFim
			
			Elseif cHrIni < cFIM .And. cHrFim > cINICIO
			
				cHoraIni	:= cHrIni
				cHrsAdNot	:= GTDeltaTime(dDataBase, cHoraIni, dDataBase + nDia, cFIM )
				cHoraIni	:= cINICIO
				cHoraFim	:= cHrFim
	
			Elseif cHrIni < cFIM .And. cHrFim <= cINICIO
		
				cHoraIni	:= cHrIni
				cHoraFim	:= cFIM
		
			EndIf
		
		Else
		
			If cHrIni <> cHrFim
		
				nDia := 1
		
				If cHrIni <= cINICIO .And. cHrIni > cFIM  .And. cHrFim <= cFIM
			
					cHoraIni := cINICIO
					cHoraFim := cHrFim
				
				ElseIf cHrIni > cINICIO .And. cHrFim <= cFIM
			
					cHoraIni := cHrIni
					cHoraFim := cHrFim
			
				ElseIf cHrIni < cINICIO .And. cHrIni > cFIM .And. cHrFim > cFIM
			
					cHoraIni := cINICIO
					cHoraFim := cFIM
				
				ElseIf cHrIni < cFIM
			
					cHoraIni	:= cHrIni
					cHrsAdNot	:= GTDeltaTime(dDataBase, cHoraIni, dDataBase, cFIM )
					cHoraIni	:= cINICIO
					cHoraFim	:= cHrFim
				ElseIf cHrIni > cINICIO .And. cHrFim >= cFIM
					cHoraIni := cHrIni
					cHoraFim := cFIM
				EndIf
			
			EndIf
		
		Endif
	
		If !Empty(cHrsAdNot)
		
			cHrsAdNot := SomaHoras(GTDeltaTime(dDataBase, cHoraIni, dDataBase + nDia, cHoraFim ), cHrsAdNot )
		
		Else
		
			cHrsAdNot := GTDeltaTime(dDataBase, cHoraIni, dDataBase + nDia, cHoraFim )
		
		EndIf


Return(cHrsAdNot)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP302PreTot()
Pre validação do modelo de totalizador
@sample	GTP302PreTot()
@author	Fernndo Amorim(Cafu)a
@since		03/08/2017
@version	P12
/*///------------------------------------------------------------------------------------------
Function GTP302PreTot(oSubMdl,nlinha,cAction,cField,xValue)
	Local lRet			:= .t.
	Local cMsgProb		:= ""
	Local cMsgSolu		:= ""

	If ( cAction == "SETVALUE" .And. cField $ "GYP_HRINIT|GYP_HRFIMT|GYP_HORORI|GYP_HORDES" )
		If !GTTimeValid(xValue,.t.,.f.,@cMsgProb,@cMsgSolu)
			oSubMdl:GetModel():SetErrorMessage(oSubMdl:GetId(),cField,oSubMdl:GetId(),cField,'Horário incorreto',cMsgProb,cMsgSolu )
			lRet := .f.
		EndIf
	EndIf

Return (lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} GA302AllOK(oModel)
description
@author  author
@since   date
@version version
/*///-------------------------------------------------------------------
Static Function GA302AllOK(oModel)

	Local lRet		:= .T.
	
	Local nOpc	 	:= oModel:GetOperation()
	
	Local oMdlGYO	:= oModel:GetModel('GYOMASTER')
	Local oMdlGYP	:= oModel:GetModel('GYPDETAIL')
	Local oMdlTot	:= oModel:GetModel('GYOTOT')
	
	Local cMsgProblem	:= ""
	Local cMsgSolution	:= ""

	If nOpc <> MODEL_OPERATION_DELETE

		If ( nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE )
			
			lRet := lConfirm

			If ( !lRet )

				cMsgProblem	:= "Os valores que totalizam a escala possuem inconsistências."
				cMsgSolution:= "Reveja a montagem da escala. A soma dos horários é "
				cMsgSolution+= "reflexo de uma escala com muitos dias corridos."
			
				oModel:SetErrorMessage(oMdlGYO:GetId(),,oMdlGYP:GetId(),,'GA302AllOK',cMsgProblem,cMsgSolution)
			
			EndIf

		EndIf

		IF	lRet .And. oMdlGYO:LoadValue("GYO_HORAAD",oMdlTot:GetValue("GYO_HORAAD"));     
			.And. oMdlGYO:LoadValue("GYO_HORPAG",oMdlTot:GetValue("GYO_HORPAG"));     
			.And. oMdlGYO:LoadValue("GYO_HRVOL"	,oMdlTot:GetValue("GYO_HRVOL")) ;      
			.And. oMdlGYO:LoadValue("GYO_HRFVOL",oMdlTot:GetValue("GYO_HRFVOL"));     
			.And. oMdlGYO:LoadValue("GYO_HORJOR",oMdlTot:GetValue("GYO_HORJOR"));     
			.And. oMdlGYO:LoadValue("GYO_HORDES",oMdlTot:GetValue("GYO_HORDES"));     
			.And. oMdlGYO:LoadValue("GYO_HRDESP",oMdlTot:GetValue("GYO_HRDESP"));      
			.And. oMdlGYO:LoadValue("GYO_RHPLAN",oMdlTot:GetValue("GYO_RHPLAN"))
			ConfirmSx8()
		Else
			lRet := .F.
			
		Endif
			
		If lRet .and. (!oMdlGYO:GetValue("GYO_SEG") .and. !oMdlGYO:GetValue("GYO_TER") .and. !oMdlGYO:GetValue("GYO_QUA"); 
			.and. !oMdlGYO:GetValue("GYO_QUI") .and. !oMdlGYO:GetValue("GYO_SEX") .and. !oMdlGYO:GetValue("GYO_SAB"); 
			.and. !oMdlGYO:GetValue("GYO_DOM"))
			
			lRet := .F.
			oModel:SetErrorMessage(oMdlGYO:GetId(),"",oMdlGYO:GetId(),"",'GA302AllOK',STR0030,STR0031)//"Nenhuma frequência foi informada." //"É necessário selecionar um dia da semana, pelo menos."
		Endif
		
		If lRet .and. (oMdlTot:GetValue("GYO_HORPAG") > GTPGetRules("QTDHRDIA") )
			If GTPGetRules("BLQHRDIA")   //Se bloquear, não permite avançar
				lRet := .F.
				oModel:SetErrorMessage(oMdlGYO:GetId(),"GYO_HORPAG",oMdlGYO:GetId(),"GYO_HORPAG",'GA302AllOK',STR0026 + Alltrim(GTPGetRules("QTDHRDIA")),STR0028)//"A quantidade de Horas Pagas excede o valor parametrizado em QTDHRDIA: " //"Reveja a seleção dos trechos e horários."
			Else //Se não, só informa que passou
				FwAlertHelp(STR0026 + Alltrim(GTPGetRules("QTDHRDIA")),STR0028,'GA302AllOK')//"A quantidade de Horas Pagas excede o valor parametrizado em QTDHRDIA: " //"Reveja a seleção dos trechos e horários."
			Endif
		Endif
		
		If lRet .and. oMdlGYP:SeekLine({{'GYP_TIPO','2'},{'GYP_SRVEXT',Space(TamSx3('GYP_TIPO')[1])}}) //Se encontrar alguma escala Extraordinária sem tipo, retornar falso
			lRet := .F.
			oModel:SetErrorMessage(oMdlGYP:GetId(),"GYP_SRVEXT",oMdlGYP:GetId(),"GYP_SRVEXT",'GA302AllOK','Existem Escalas extraordinárias sem definição de tipo de serviço',I18n("Verifique o Item: #1 da escala",{oMdlGYP:GetValue("GYP_ITEM")}))
		Endif
		
		
	Endif
	

Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA308UpdParam()
Função pelas cargas dos dados, tanto do grid do lado esquerdo, quanto para a inclusão de 
registros na tabela GYF - Parâmetros do Módulo GTP
@sample	GA308UpdParam(oModel)
@params	oModel: Objeto.	Instância da Classe FwFormModel
@return lRet: Lógico.	.t. Atualização e carga efetuadas com sucesso		
@author	Fernando Radu Muscalu
@since		17/08/2015
@version	P12
/*///------------------------------------------------------------------------------------------
Static Function GA308UpdParam(oModel)

	Local lRet		:= .t.

	Local nOpera 	:= oModel:GetOperation()
	Local nI		:= 0
	
	Local oSubGYP 	:= oModel:GetModel("GYPDETAIL")

	If nOpera <> 3 .and. nOpera <> 5
		GA302ForceGIE(oModel:GetModel('GIEDETAIL'))
	Endif

	If ( lRet )
	
		lExibtot	:= GTPGetRules("GTPEXIBTOT")
		
	EndIf
	
	If nOpera <> 5
		for nI := 1 to oSubGYP:Length()

			oSubGYP:GoLine(nI)
			oSubGYP:LoadValue("BKP_HRINIT",oSubGYP:GetValue("GYP_HRINIT"))
			oSubGYP:LoadValue("BKP_HRFIMT",oSubGYP:GetValue("GYP_HRFIMT"))
				
		Next nI
	EndIf
	
Return(.t.)
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA302X3WhenGYP()
Rotina responsavel por habilitar a edição dos campos com base no tipo de trecho (Campo GYP_TIPO)
@sample	GA302X3WhenGYP()
@Param		oGrid - Objeto Grid  
@Param		cCampo - Nome do campo a ser avaliado.
@author	Fernando Amorim(Cafu)
@since		09/08/2017
@version	P12
/*///------------------------------------------------------------------------------------------
Static Function GA302X3WhenGYP(oGrid, cCampo)

	Local cTipo	:= oGrid:GetValue("GYP_TIPO")
	Local cFields := ""
	Local lRet 	:= .F.

		If Empty(cTipo)
			oGrid:LoadValue("GYP_TIPO",'2')
		Endif
		
		If cTipo == "1" //Trecho-Normal
			cFields := "GYP_TIPO|GYP_HRINIT|GYP_HRFIMT|GYP_PASSAG"
		ElseIf cTipo == "2" //Trecho-Extraordinário
			cFields := "GYP_TIPO|GYP_SRVEXT|GYP_HRINIT|GYP_HORORI|GYP_SRVORI|GYP_SRVDES|GYP_HORDES|GYP_HRFIMT|GYP_PASSAG"
		ElseIf cTipo == "3" //-- Trecho Plantão
			cFields := "GYP_TIPO|GYP_PFUNC|GYP_HRINIT|GYP_SRVORI|GYP_SRVDES|GYP_HRFIMT|GYP_PASSAG"
		ELseIf cTipo == "4" //Trecho-Normal
			cFields := "GYP_TIPO|GYP_HRINIT|GYP_HRFIMT|GYP_PASSAG"
		EndIf
			
		lRet := AllTrim(cCampo) $ cFields
	
Return (lRet)
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA302VLDGYP()
Rotina responsavel por habilitar a validação do campo tipo 
@sample	GA302VLDGYP()
@Param		oGrid - Objeto Grid  
@Param		cCampo - Nome do campo a ser avaliado.
@author	Fernando Amorim(Cafu)
@since		09/08/2017
@version	P12
/*///------------------------------------------------------------------------------------------
Function GA302VLDGYP(oGrid, cCampo,xValAtu,nLinha,xValOld)

	Local lRet			:= .T.
	Local oMdlSel1	 	:= oGrid:GetModel():GetModel( 'GIEDETAIL' )
	Local oMdlSel2	 	:= oGrid:GetModel():GetModel( 'GYPDETAIL' )
	
		If AllTrim(cCampo) == 'GYP_TIPO'
			If xValOld == '1'
				If xValAtu == '2' .Or. xValAtu == '3'
					oGrid:GetModel():SetErrorMessage("GYPDETAIL",cCampo,"GYPDETAIL",cCampo,'Tipo',"Utilize tipo Normal ou Parada obrig.","Para trechos Normal não é permitido usar os tipos extraordinário ou plantão. " )
					lRet	:= .F.
				Endif
			Elseif  xValOld == '4'
				If oMdlSel1:SeekLine({ {'GIE_CODGID', oMdlSel2:GetValue( 'GYP_CODGID' )},{"GIE_SEQ",oMdlSel2:GetValue("GYP_SEQ")}})
					If xValAtu == '2' .Or. xValAtu == '3'
						oGrid:GetModel():SetErrorMessage("GYPDETAIL",cCampo,"GYPDETAIL",cCampo,'Tipo',"Utilize tipo Normal ou Parada obrig.","Para trechos Normal não é permitido usar os tipos extraordinário ou plantão. " )
						lRet	:= .F.
					Endif
				Else
					If xValAtu == '1'
						oGrid:GetModel():SetErrorMessage("GYPDETAIL",cCampo,"GYPDETAIL",cCampo,'Tipo',STR0035,STR0034 )
						lRet	:= .F.
					Endif
				EndIf
			Else
				If xValAtu == '1'
					oGrid:GetModel():SetErrorMessage("GYPDETAIL",cCampo,"GYPDETAIL",cCampo,'Tipo',STR0035,STR0034 )		      //"Utilize tipo extraordinário ou plantão." //"Para trechos avulsos não é permitido usar o tipo Normal. "
					lRet	:= .F.
				Endif
			EndIf
        ElseIf AllTrim(cCampo) == 'GYP_SRVORI' .OR.  AllTrim(cCampo) == 'GYP_SRVDES'
            If!Empty(xValAtu) .and. !GTPExistCpo('GI1',xValAtu)
                lRet := .F.
                oGrid:GetModel():SetErrorMessage("GYPDETAIL",cCampo,"GYPDETAIL",cCampo,'Localidade',"Localidade informada não existe","Verifique as informações declaradas" )
            Endif
        ElseIf AllTrim(cCampo) == "GYP_SRVEXT"
            If!Empty(xValAtu) .and. !GTPExistCpo('GZS',xValAtu)
                lRet := .F.
                oGrid:GetModel():SetErrorMessage("GYPDETAIL",cCampo,"GYPDETAIL",cCampo,'Tipo de Serviço',"Tipo de Serviço informado não existe","Verifique as informações declaradas" )
            Endif
		EndIf

Return lRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA302When()
Função de validação e atualização de totais que é executada através do Field do Filtro e do
cabeçalho da Escala 
@sample	GA302When(oSubMdl,cAction,cField,xValue)
@params	oSubMdl: Objeto.	Instância da Classe FwFormFields
		cAction: Caractere. Tipo de Ação
		cField: Caractere. Campo sendo validado
		xValue: Qualquer. Valor do campo (cField) que está sendo validado
		
@return lRet: Lógico.	.t. Validação e atualização efetuadas com sucesso		
@author	Fernando Radu Muscalu
@since		17/08/2015
@version	P12
/*///------------------------------------------------------------------------------------------
Static Function GA302When(oSubMdl,cAction,cField,xValue)

	Local cNewDriver	:= ""
	Local cOldDriver	:= ""
	Local cHrFim		:= ""
	Local nI			:= 0
	Local lRet			:= .t.
	Local oMdlGYO		:= oSubMdl:GetModel():GetModel("GYOMASTER")
	Local oMdlGYP		:= oSubMdl:GetModel():GetModel("GYPDETAIL")
	Local oMdlTotal		:= oSubMdl:GetModel():GetModel("GYOTOT")
	Local oView			:= FwViewActive()
	
		If ( cAction == "CANSETVALUE" .And. oSubMdl:GetId() == "GY4FILTER" )
	
			lRet := !Empty(oMdlGYO:GetValue("GYO_RECCOD"))
	
		ElseIf ( cAction == "SETVALUE" )
	
			If ( !oMdlGYP:IsEmpty() .and. !Empty(oMdlGYP:GetValue("GYP_HRFIMT")) )
	
				If ( cField == "GYO_RECCOD" )
	
					If ( xValue <> oSubMdl:GetValue("GYO_RECCOD") )
	
						cNewDriver := Posicione("GYK",1,xFilial("GYK")+xValue,"GYK_VALCNH")
						cOldDriver := Posicione("GYK",1,xFilial("GYK")+oSubMdl:GetValue("GYO_RECCOD"),"GYK_VALCNH")
					
						If ( cNewDriver <> cOldDriver )
						
							oSubMdl:LoadValue("GYO_RECCOD",xValue)
						
							oMdlTotal:ClearData(.t.)
	
							For nI := 1 to oMdlGYP:Length()
	
								oMdlGYP:GoLine(nI)
	
								If ( !oMdlGYP:IsDeleted() )
									cHrFim := oMdlGYP:getValue("GYP_HRFIMT")
									GTP302PreTot(oMdlGYP,nI,"SETVALUE","GYP_HRFIMT",cHrFim)
								EndIf
	
							Next nI
	
						EndIf
	
					EndIf
	
				///colocar a logica para refazer os totais, quando alterar o tipo de colaborador
					oView:Refresh("VIEW_TOT")
				EndIf
	
			Endif
	
		EndIf

Return(lRet)
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G302BCarga   
    Executa o bloco de carga de dados dos grids SELECAO1 e SELECAO2
    @type  Static Function
    @author Fernando Amorim(Cafu)/Fernando Radu
    @since 27/07/2017
    @version version
    @param oSubMdl, objeto, instância da Classe FwFormGridModel
    @return aReg, array, Array de retorno da carga para o grid
    @example
    (examples)
    @see (links_or_references)
/*///------------------------------------------------------------------------------------------
Static Function G302BCarga(oMdlGIE)

	Local aReg  	:= {}
	Local aFields 	:= {}
	Local aAux  	:= {}
	Local cAlias 	:= GA408ResultSet()
	Local nI   		:= 0

	aFields := aClone(oMdlGIE:GetStruct():GetFields())

	If ( (cAlias)->(!Eof()) )

		While ( (cAlias)->(!Eof()) )
		
			For nI := 1 to Len(aFields)
			
					
				If ( (cAlias)->(FieldPos(aFields[nI,3])) > 0 )
					aAdd(aAux,(cAlias)->&(aFields[nI,3]))
				Else
				
					If ( aFields[nI,3] == "CODSEQ")
						aAdd(aAux,(cAlias)->(GIE_CODGID+GIE_SEQ))
					Else
						aAdd(aAux,GTPCastType(,aFields[nI,4]))
					Endif
					
				EndIf

			Next nI
		
			aAdd(aReg,{0,aClone(aAux)})
			aAux := {}
			
			(cAlias)->(DbSkip())

		EndDo
	Endif

Return(aReg)
//------------------------------------------------------------------------------------------
 /*/{Protheus.doc} GA302FillGIE()
	Preenche os horários do grid GIEDETAIL
	@type Static Function
	@author Fernando Radu Muscalu
	@since 28/07/2017
	@version version
	@param oView, objeto, instância da classe FwFormView
	@return nil, nulo, sem retorno
	@example
	(examples)
	@see (links_or_references)
/*///------------------------------------------------------------------------------------------
Static Function GA302ForceGIE(oMdlGIE)

	Local oMdlGYP
	Local cAlias	:= ""
	Local nI		:= 0
	Local aFields	:= {}
	Local lRet		:= .T.
	
		cAlias := GA408ResultSet()
	
		aFields := aClone(oMdlGIE:GetStruct():GetFields())
		(cAlias)->(DbGotop())
		If ( (cAlias)->(!Eof()) )
	
			While ( (cAlias)->(!Eof()) )
			
				If !oMdlGIE:IsEmpty()
					lRet := oMdlGIE:Length() < oMdlGIE:AddLine(.t.,.t.)
				EndIf
	
				If ( lRet )
	
					For nI := 1 to Len(aFields)
					
						If ( (cAlias)->(FieldPos(aFields[nI,3])) > 0 )
						
							lRet := oMdlGIE:LoadValue(aFields[nI,3],(cAlias)->&(aFields[nI,3]))
					
						Else
	
							If ( aFields[nI,3] == "GIE_DESCLP" )
								oMdlGIE:LoadValue(aFields[nI,3],POSICIONE('GI1', 1, XFILIAL('GI1') + (cAlias)->GIE_IDLOCP, "GI1_DESCRI"))
							ElseIf ( aFields[nI,3] == "GIE_DESCLD" )
								oMdlGIE:LoadValue(aFields[nI,3],POSICIONE('GI1', 1, XFILIAL('GI1') + (cAlias)->GIE_IDLOCD, "GI1_DESCRI"))
							ElseIf ( aFields[nI,3] == "CODSEQ")
							
								oMdlGYP := oMdlGIE:GetModel():GetModel("GYPDETAIL")
								oMdlGYP:Goline(1)
							
								If ( !oMdlGYP:SeekLine({{"GYP_CODGID",(cAlias)->GIE_CODGID},{"GYP_SEQ",(cAlias)->GIE_SEQ}}) )
									oMdlGIE:LoadValue(aFields[nI,3],(cAlias)->(GIE_CODGID+GIE_SEQ))
								EndIf
										
							EndIf
	
						EndIf
	
						If ( !lRet )
							Exit
						EndIf
	
					NexT nI
				
				Else
					Exit
				EndIf
	
				If ( !lRet )
					Exit
				EndIf
	
				(cAlias)->(DbSkip())
	
			EndDo
			
		EndIf

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G302Commit   
    Executa o bloco Commit do MVC
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 11/07/2017
    @version version
    @param oModel, objeto, instância da Classe FwFormModel
    @return lRet, lógico, .t. - Efetuou o Commit com sucesso
    @example
    (examples)
    @see (links_or_references)
/*///------------------------------------------------------------------------------------------
Static Function G302Commit(oModel)

	Local lRet 		:= .F.
	Local nOpera 	:= oModel:GetOperation()
	Local cQuery	:= ''
	Local oMdlGYP	:= oModel:GetModel("GYPDETAIL")
	Local nX		:= 0
	Local cAliasMx	:= GetNextAlias()
	Local nCont		:= 0
	
		If oModel:VldData()
			Begin Transaction
				If nOpera == 4
		 
			
					cQuery := " DELETE FROM "+RetSqlName("GYP")+" "
					cQuery += " WHERE GYP_FILIAL='"+xFilial("GYP")+"' AND "
					cQuery += " GYP_ESCALA='"+oModel:GetModel("GYOMASTER"):GetValue("GYO_CODIGO")+"' AND "
					cQuery += " D_E_L_E_T_= ' ' "
				
					lRet :=	TcSqlExec(cQuery) >= 0
					If lRet
						TcSqlExec("COMMIT")
					Endif
					If ( lRet )
			
						BeginSQL Alias cAliasMx
	
							SELECT MAX(R_E_C_N_O_)MAXREC
							FROM %Table:GYP% GYP
				
						EndSQL
					
						If !(cAliasMx)->(EOF())
							nCont := (cAliasMx)->MAXREC
						Endif
						(cAliasMx)->(DbCloseArea())
				
						For nX := 1 To oMdlGYP:Length()
	
							oMdlGYP:GoLine( nX )
							nCont++
							cQuery := "INSERT INTO "+RetSqlName("GYP")+"  (GYP_FILIAL,GYP_ESCALA,GYP_ITEM,GYP_SEQ, GYP_LINCOD, GYP_LINSTD, GYP_HORORI, GYP_SRVORI, GYP_HORDES, GYP_SRVDES,GYP_TIPO, GYP_SRVEXT, GYP_PFUNC,GYP_HRINIT,GYP_HRFIMT,GYP_CODGID,GYP_PASSAG,GYP_DIA,R_E_C_N_O_)"+Chr(13)
							cQuery += "VALUES('"+xFilial('GYP')+"', '"+oModel:GetModel("GYOMASTER"):GetValue("GYO_CODIGO")+"', '"+oMdlGYP:GetValue( "GYP_ITEM")+"', '"+oMdlGYP:GetValue( "GYP_SEQ")+"','"+oMdlGYP:GetValue( "GYP_LINCOD")+"', '"+oMdlGYP:GetValue( "GYP_LINSTD")+"', '"+oMdlGYP:GetValue( "GYP_HORORI")+"','"+oMdlGYP:GetValue( "GYP_SRVORI")+"' ,'"+oMdlGYP:GetValue( "GYP_HORDES")+"', "+Chr(13)
							cQuery += " '"+oMdlGYP:GetValue( "GYP_SRVDES")+"','"+oMdlGYP:GetValue( "GYP_TIPO")+"', '"+oMdlGYP:GetValue( "GYP_SRVEXT")+"', '"+oMdlGYP:GetValue( "GYP_PFUNC")+"', '"+oMdlGYP:GetValue( "GYP_HRINIT")+"','"+oMdlGYP:GetValue( "GYP_HRFIMT")+"','"+oMdlGYP:GetValue( "GYP_CODGID")+"','"+oMdlGYP:GetValue( "GYP_PASSAG")+"',"+cValToChar(oMdlGYP:GetValue("GYP_DIA"))+","+str(nCont)+"  ) "
							lRet :=	TcSqlExec(cQuery) >= 0
							If lRet
								TcSqlExec("COMMIT")
								oModel:GetModel("GYPDETAIL"):SetOnlyQuery(.t.)
							Endif
						Next nX
								
					EndIf
				Else
					lRet:= .T.
				Endif
				If lRet
					lRet := FWFormCommit(oModel)
					If lRet
						oModel:GetModel("GYPDETAIL"):SetOnlyQuery(.F.)
							
					Endif
				Endif
			End Transaction
		Endif
		
Return(lRet)
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA302F3   
   
    @type  Function
    @author JACOMO.FERNANDES
    @since 13/10/2017
    @version version
    @return cRet
    @example
    (examples)
    @see (links_or_references)
/*///------------------------------------------------------------------------------------------
Function GTPA302F3()
	Local cRet := "@#"
	Local oModel	:= FwModelActive()

	If oModel:GetId() == "GTPA312"
		cRet += " GYO->GYO_SETOR = '"+oModel:GetModel('GY8MASTER'):GetValue('GY8_SETOR')+"'"
	Endif

	cRet+= "@#"

Return cRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetTpRec
Retorna se o recurso valida ou não a CNH, se sim indica que o(s) recurso(s) é(são) motorista(s)
@type function
@author 
@since 10/01/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param cCpo, character, (Descrição do parâmetro)
@param xValue, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///------------------------------------------------------------------------------------------
Static Function RetTpRec( oModel, cCpo, xValue )

	Local lNBlq		:= Empty( xValue )
	Local aAreaGTK	:= GYK->(GetArea())

		if !lNBlq
				
			dbSelectArea("GYK")
			GYK->(dbSetOrder(1))
			if GYK->(dbSeek( xFilial("GYK") + xValue ))
					
				if FieldPos('GYK_MSBLQL') > 0
			
					if GYK->GYK_MSBLQL == '1'
								
						FwAlertHelp( "Tipo de Recurso Inativo" , "Informe um código de Recurso que esteja ativo." )
						lNBlq	:= .T.
						
					EndIf
				
				EndIf
				
				if !lNBlq
				
					lMotorista	:= iif( GYK->GYK_VALCNH == '1' , .T. , .F. )
				
				EndIf
					
			Else
								
				FwAlertHelp( "Tipo de Recurso " , "Informe um código de Recurso existente" )
				lNBlq	:= .T.
						
			EndIf
		
		EndIf
				
		RestArea( aAreaGTK )
		
Return xValue
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MntTots
chama as funções para calcular e recalcular os totalizadores.
@type function
@author  
@since 10/01/2018
@version 1.0
@return ${return}, ${return_description}
/*///------------------------------------------------------------------------------------------
Static Function MntTots()
	
	Local oView         := FWViewActive()
	Local oModel        := FWModelActive()
	Local oModelGYP     := oModel:GetModel('GYPDETAIL')
	Local oModelGYO     := oModel:GetModel('GYOMASTER')
    Local oModelTot     := oModel:GetModel('GYOTOT')
    
	Local dDtIni        := dDataBase
    Local dDtFim        := dDataBase
    
	Local lHrVol        := .T.
    Local lHrPagas      := .T.
    Local lMotorista    := Posicione('GYK',1,xFilial('GYK')+oModelGYO:GetValue("GYO_RECCOD"),'GYK_VALCNH') == "1"
    Local lRet			:= .T.

    Local cHrIni        := ""
    Local cHrFim        := ""
    Local cHrIniSrv     := ""
    Local cHrFimSrv     := ""

	Local cSetor        := oModelGYO:GetValue("GYO_SETOR")
    Local cColabAux     := Posicione('GY2',1,xFilial('GY2')+cSetor,'GY2_CODCOL')
    Local cTotHrVol		:= 0
    Local cTotHrFrV		:= 0
	Local cTotIntPg		:= 0
	Local cTotInter		:= 0
	Local cTotAdNot		:= 0
	Local cTotPagto		:= 0
	Local cHrJornad		:= 0
	Local cTotHrPlan	:= 0
	Local cHrFimAnt		:= ""
	Local cHrIniAnt		:= ""
	Local cMsgProblem	:= ""
	Local cMsgSolution	:= ""

	Local nI			:= 0
	Local nTotDia		:= 0
	
    Local oCalcDia      := GTPxCalcHrDia():New(dDtIni,cSetor,cColabAux)

	For nI := 1 To oModelGYP:Length()
		
		oModelGYP:GoLine(nI)
		
		If oModelGYP:IsDeleted(nI) .Or. Empty( oModelGYP:GetValue("GYP_HRINIT",nI)) .or. Empty( oModelGYP:GetValue("GYP_HRFIMT",nI) )
			Loop
        EndIf
        
        cHrIni 		:= GTFormatHour( oModelGYP:GetValue("GYP_HRINIT",nI), "99:99")
        cHrFim 		:= GTFormatHour( oModelGYP:GetValue("GYP_HRFIMT",nI), "99:99")
        cHrIniSrv 	:= GTFormatHour( oModelGYP:GetValue("GYP_HORORI",nI), "99:99")
        cHrFimSrv 	:= GTFormatHour( oModelGYP:GetValue("GYP_HORDES",nI), "99:99")
        
        If nI != 1
        	cHrFimAnt := GTFormatHour( oModelGYP:GetValue("GYP_HRFIMT",nI-1), "99:99")
        	cHrIniAnt := GTFormatHour( oModelGYP:GetValue("GYP_HRINIT",nI-1), "99:99")
        EndIf
        
		If cHrIni > cHrIniSrv
			dDtIni--
		ElseIf cHrFimAnt > cHrIni
			dDtIni++
		Endif

		If cHrFimSrv > cHrFim .Or. (cHrIni > cHrFim) 
			dDtFim++
		Endif

		If (nI > 1 .And. cHrFimAnt > cHrIni)
			dDtFim++
			nTotDia++
		Endif

        If !Empty(oModelGYP:GetValue("GYP_SRVEXT",nI))
            lHrVol    := Posicione('GZS',1,xFilial('GZS')+oModelGYP:GetValue("GYP_SRVEXT",nI),'GZS_VOLANT') == "1"
            lHrPagas  := Posicione('GZS',1,xFilial('GZS')+oModelGYP:GetValue("GYP_SRVEXT",nI),'GZS_HRPGTO') == "1"
        Else
            lHrVol    := lMotorista
            lHrPagas  := .T.
        Endif  

        lHrVol := IIf(oModelGYP:GetValue("GYP_TIPO") == "4",.f.,lHrVol)
        oCalcDia:AddTrechos(oModelGYP:GetValue("GYP_TIPO"),dDtIni,cHrIni,,,dDtFim,cHrFim,,,lHrVol,lHrPagas,,cHrIniSrv,cHrFimSrv)
        
       	dDtIni	:= dDtFim

		nTotDia := IIf( nTotDia < 0, 0, nTotDia)
		
        oModelGYP:SetValue("GYP_DIA",nTotDia)

    Next
    
	oCalcDia:CalculaDia()
	
	cTotHrVol 	:= oCalcDia:cHrVolante
	cTotIntPg	:= oCalcDia:cHrIntPgt 
	cTotInter	:= oCalcDia:cHrIntTot 
	cTotAdNot	:= oCalcDia:cHrAdnNot 
	cTotPagto	:= oCalcDia:cHrPagas
	cHrJornad	:= oCalcDia:cHrJorn
	cTotHrPlan	:= oCalcDia:cHrPlantao
	//cTotHrFrV 	:= IntToHora(oCalcDia:nHrJorn - oCalcDia:nHrVolante - oCalcDia:nHrPlantao)
	cTotHrFrV 	:= IntToHora(oCalcDia:nHrIntTot + oCalcDia:nHrForaVol)

	//Montar a mensagem de erro de acordo com falha em cada um dos campos abaixo
	lRet := oModelTot:LoadValue("GYO_HRVOL ",GTFormatHour( cTotHrVol , "9999" ) ) .And.;//Total de Horas Volante
	oModelTot:LoadValue("GYO_HRFVOL",GTFormatHour( cTotHrFrV , "9999" ) ) .And.;		//Total de Horas Fora Volante
	oModelTot:LoadValue("GYO_HRDESP",GTFormatHour( cTotIntPg , "9999" ) ) .And.;		//Total de Horas Intervalos Pagos
	oModelTot:LoadValue("GYO_HORDES",GTFormatHour( cTotInter , "9999" ) ) .And.;		//Total de Horas Intervalos 
	oModelTot:LoadValue("GYO_HORAAD",GTFormatHour( cTotAdNot , "9999" ) ) .And.;		//Total de Horas Adicional Noturno
	oModelTot:LoadValue("GYO_HORPAG",GTFormatHour( cTotPagto , "9999" ) ) .And.;		//Total de Horas Pagas
	oModelTot:LoadValue("GYO_HORJOR",GTFormatHour( cHrJornad , "9999" ) ) .And.;		//Total de Horas Jornadas
	oModelTot:LoadValue("GYO_RHPLAN",GTFormatHour( cTotHrPlan ,"9999" ) ) 				//Total de Horas Plantão
	
	If ( !lRet )
		cMsgProblem		:= "Total de Horas inválido."
		cMsgSolution	:= "O resultado da soma de horas (de ao menos um totalizador) é superior a 99:59 ou negativo."
		oModelTot:GetModel():SetErrorMessage(oModelTot:GetId(),"TOTAIS",oModelTot:GetId(),,,cMsgProblem,cMsgSolution)
	EndIf

    oView:Refresh("VIEW_GYP")
    oView:Refresh("VIEW_TOT")
    
Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA302TRG(oMdl,cField,xVal)
Função de Gatilhos

@sample	

@author	Fernando Amorim
@since		31/01/2018
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function GTPA302TRG(oMdl,cField,xVal)
	
	// Local nLine		:= oMdl:GetLine()
	Local nI		:= 0
	// Local nCountDays:= 0	//Por enquanto, esta variável é figurativa. Ele demonstra quantos dias se passaram sempre que os cálculos de horas passam das 24. Serve tambem para dizer quantos dias retrocederam quando o cálculo de horas superior a 00:00, após o resultado, ficaria inferior a 00:00 (negativo, ex: -01:00)	
	Local nLnOri	:= 0

	Local cDeltaTime:= ""
	Local cFieldBkp	:= ""
	Local cMsg		:= ""

	Local nRetOpc		:= 0
	Local nCurrentDay	:= 0
	Local nInit			:= 0
	Local lAjHorFin		:= GTPGetRules('AJHRFINESC', .F. , , .F.) 
	
	lConfirm := .T.
	
	If ( Alltrim(cField) $ "GYP_HRINIT|GYP_HRFIMT|GYP_TIPO" )
		
		cFieldBkp := IIf(cField == "GYP_HRFIMT","BKP_HRFIMT","BKP_HRINIT")	
		
		If ( oMdl:GetValue("GYP_HRINIT") != oMdl:GetValue("BKP_HRINIT") .Or.;
			oMdl:GetValue("GYP_HRFIMT") != oMdl:GetValue("BKP_HRFIMT") )
			
			cDeltaTime := GTPSubTime(oMdl:GetValue(cField),oMdl:GetValue(cFieldBkp)) //GTDeltaTime(dDtIni, GTFormatHour(oMdl:GetValue("BKP_HRFIMT"),"99:99"), dDtFim, GTFormatHour(oMdl:GetValue("GYP_HRFIMT"),"99:99"))

			cMsg := "Como gostaria de atualizar os horários, a partir daqui: " + chr(13) + chr(10)
			cMsg += " - [Item] posicionado?" + chr(13) + chr(10)
			cMsg += " - [Dia] corrente?" + chr(13) + chr(10)
			cMsg += " - [Todos] dias?" + chr(13)
			
			If ( !FwIsInCallStack("G302MoveHor") )	.And. lAjHorFin
				nRetOpc := Aviso("Atualização dos horários",cMsg,{"Dia","Item","Todos"})
			Else	
				nRetOpc := 3
			EndIf

			nLnOri := oMdl:GetLine()
			nCurrentDay := oMdl:GetValue("GYP_DIA")
			
			nInit := IIf(cField == "GYP_HRINIT",nLnOri,nLnOri+1)	
			
			For nI := nInit to oMdl:Length()
								
				oMdl:GoLine(nI)				

				If ( nRetOpc == 2 )

					If ( cField == "GYP_HRINIT" )
					//	UpdTime(oMdl,cDeltaTime,"GYP_HRFIMT")
					EndIf

					Exit

				ElseIf ( nRetOpc == 1 .And. oMdl:GetValue("GYP_DIA") != nCurrentDay )
					Exit
				EndIf

				If ( nI > nLnOri )				
					UpdTime(oMdl,cDeltaTime,"GYP_HRINIT")
				EndIf
				
	//			UpdTime(oMdl,cDeltaTime,"GYP_HRFIMT")
				
				nCurrentDay := oMdl:GetValue("GYP_DIA")

			Next nI

			oMdl:GoLine(nLnOri)

		Endif
		If ( cField == "GYP_HRINIT" )
			oMdl:LoadValue("BKP_HRINIT",oMdl:GetValue("GYP_HRINIT"))
		EndIf
		
		If ( cField == "GYP_HRFIMT" )
			oMdl:LoadValue("BKP_HRFIMT",oMdl:GetValue("GYP_HRFIMT"))
		EndIf

		If cField == "GYP_TIPO"
			oMdl:LoadValue('GYP_SRVEXT','')	//oMdl:SetValue('GYP_SRVEXT','')
		EndIf

	Endif

	If !FwIsInCallStack('G302MOVEHOR')
		nLnOri := oMdl:GetLine()
		lConfirm := MntTots()
	Endif

	oMdl:GoLine(nLnOri)	

Return xVal

Static Function UpdTime(oSubMdl,cTimeToSum,cFieldTime)

	Local cFldTimeBkp	:= Iif(cFieldTime == "GYP_HRINIT","BKP_HRINIT","BKP_HRFIMT")
	Local cTime			:= ""
	Local lAjHorFin		:= GTPGetRules('AJHRFINESC', .F. , , .F.) 
	
	Default oSubMdl := FwModelActive()

	If lAjHorFin

		cTime := GTPSumTime(cTimeToSum,oSubMdl:GetValue(cFieldTime),,"9999")	
		
		oSubMdl:LoadValue(cFieldTime,cTime)
		oSubMdl:LoadValue(cFldTimeBkp,cTime)	

	Endif

Return()

/*
	- Não deixar que a coluna Dias corridos para primeira linha seja maior que zero
	- Fazer a pergunta se deseja deslocar o horário para o dia corrente ou para tudo
		:: Calcular o deslocamento também para hora início de trabalho
	- Após a atualização da alteração dos horários para todas a linhas, deve-se voltar o cursor
	para a posição da linha atual - aquela que disparou a atualização
*/
