#INCLUDE 'PROTHEUS.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'TMSA153B.ch'

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA153B
Cadastro de Planejamento de demanda
@type function
@author Ruan Ricardo Salvador.
@version 12.1.17
@since 08/11/2017
/*/
//-------------------------------------------------------------------------------------------------

Static IncAuto := .F.
Static cChaveDl8 := " " //Utilizado para gravar chave da demandas no CANSEVALUE para liberar o registro do lock.

Function TMSA153B()
	//Funcionalidades de Planejamento de demandas	
Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu 
@type function
@author Ruan Ricardo Salvador.
@version 12.1.17
@since 08/11/2017
/*/
//-------------------------------------------------------------------------------------------------
Static Function Menudef()
	Local aRotina := {}
	
	aAdd(aRotina, {STR0001, 'VIEWDEF.TMSA153B', 0, 3, 0, NIL}) //Incluir
	aAdd(aRotina, {STR0002, 'VIEWDEF.TMSA153B', 0, 4, 0, NIL}) //Alterar
	aAdd(aRotina, {STR0003, 'VIEWDEF.TMSA153B', 0, 2, 0, NIL}) //Visualizar
	aAdd(aRotina, {STR0004, 'VIEWDEF.TMSA153B', 0, 5, 0, NIL}) //Excluir
	aAdd(aRotina, {STR0033,'TMA154Par(3, , , , DL9->DL9_COD, , , 4)', 0, 2, 0, NIL}) //Tracking
	
Return aRotina

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados 
@type function
@author Ruan Ricardo Salvador
@version 12.1.17
@since 06/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel    := Nil
	Local oStruDL9  := FWFormStruct(1, 'DL9')
	Local oStruDLA := FWFormStruct(1, 'DLA')
	Local oStruDLL := FWFormStruct(1, 'DLL')
	Local oStruDL8  := MdoStruDL8()
	//Local oEvent  := TMSA153BEV():New()
	
	Local bLnPosOri    := { | oModel | T153BRgPos( oModel, '1' ) }
	Local bLnPosDes    := { | oModel | T153BRgPos( oModel, '2' ) } 
	Local bLinePreDM := { | oModel, nLine, cAction | T153BPreDM(oModel, nLine, cAction) }
	Local bPreVRegOr := { | oModel, nLine, cAction | T153BOrPre(oModel, nLine, cAction) }
	Local bPreVRegDs := { | oModel, nLine, cAction | T153BDsPre(oModel, nLine, cAction) }
	Local bPreValDMD := { | oDlDmd, nLine, cOpera, cCampo, cValAtu, cValAnt | T153BPREVL( oDlDmd, nLine, cOpera, cCampo, cValAtu, cValAnt) }
	Local bPosValDMD := { | oModel | T153PosDem( oModel ) }
	
	//Cria model principal - Cabecalho
	oModel := MPFormModel():New( 'TMSA153B',/*bPre*/,{|oModel|TMA153VALD(oModel)},{|oModel| TMSA153GRV(oModel)}, {|oModel| T153BCanc(oModel)} )	
	//oModel:InstallEvent("TMSA153BEV", /*cOwner*/, oEvent)
	oModel:SetVldActivate ( { |oModel| TMSA153BVL(oModel) } )
	oModel:SetDeActivate ( {|oModel| T153BDeAct(oModel)})
	
	//Seta inicializador padrão para cada grid
	oStruDLA:SetProperty('DLA_PREVIS',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'2'))
	
	oStruDLL:SetProperty('DLL_PREVIS',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'2'))
	oStruDLL:SetProperty('*', MODEL_FIELD_OBRIGAT,.F.)
	
	oModel:SetDescription(STR0005) //Planejamento de Demanda
	
	//Field principal
	oModel:AddFields('MASTER_DL9',nil,oStruDL9)
	
	//Adiciona os grids
	oModel:AddGrid('GRID_DEMAN','MASTER_DL9' ,oStruDL8 , bLinePreDM, /*bLinePost*/, bPreValDMD, bPosValDMD      , /*bload*/)
	oModel:AddGrid('GRID_ORI'  ,'GRID_DEMAN' ,oStruDLA, /*bPre*/  , bLnPosOri    , bPreVRegOr, /*bPosVal*/     , /*bload*/)
	oModel:AddGrid('GRID_DES'  ,'GRID_DEMAN' ,oStruDLL, /*bPre*/  , bLnPosDes    , bPreVRegDs, /*bPosVal*/     , /*bload*/)
	
	//Grid nao obrigatorio 
	oModel:GetModel('GRID_DEMAN'):SetOptional(.T.)
	oModel:GetModel('GRID_ORI'):SetOptional(.T.)
	oModel:GetModel('GRID_DES'):SetOptional(.T.)
	
	//Relacao pai-filho-neto
	oModel:SetRelation( 'GRID_DEMAN', { { 'DL8_FILIAL', 'xFilial( "DL8" ) ' } , { 'DL8_PLNDMD', 'DL9_COD' }} , DL8->( IndexKey( 1 )))
	oModel:SetRelation( 'GRID_ORI'  , { { 'DLA_FILIAL', 'xFilial( "DLA" )' }  , { 'DLA_CODDMD', 'DL8_COD' },{'DLA_SEQDMD', 'DL8_SEQ'}}, DLA->( IndexKey( 1 )))
	oModel:SetRelation( 'GRID_DES'  , { { 'DLL_FILIAL', 'xFilial( "DLL" )' }  , { 'DLL_CODDMD', 'DL8_COD' },{'DLL_SEQDMD', 'DL8_SEQ'}}, DLL->( IndexKey( 1 )))
	
	oModel:SetOnlyQuery('GRID_DEMAN',.T.)
	oModel:SetOnlyQuery('GRID_ORI',.T.)
	oModel:SetOnlyQuery('GRID_DES',.T.)
	
	//Controle de nao repeticao de linha
	oModel:GetModel( 'GRID_DEMAN' ):SetUniqueLine( { 'DL8_COD', 'DL8_SEQ' } )
	oModel:GetModel( 'GRID_ORI' ):SetUniqueLine( { 'DLA_CODREG' } )
	oModel:GetModel( 'GRID_DES' ):SetUniqueLine( { 'DLL_CODREG' } )
	
	
	oModel:SetPrimaryKey({}) 

Return oModel

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Estrutura de dados 
@type function
@author Ruan Ricardo Salvador
@version 12.1.17
@since 06/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel('TMSA153B')
	Local oStruDL9 := FWFormStruct(2,'DL9')
	Local oStruDLA := FWFormStruct(2,'DLA')
	Local oStruDLL := FWFormStruct(2,'DLL')
	Local oStruDL8  := VwStruDL8()

	Local cFunction	:= "TMSA153B"

	//--Força LOG DE ACESSO Ref. a Proteção de Dados
	IIf(ExistFunc('FwPDLogUser'),FwPDLogUser(cFunction),)

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados sera utilizado
	oView:SetModel( oModel )
	
	oView:SetViewAction( 'BUTTONCANCEL', {|| lCanPLN := .T. } )
	
	//Remove os campos para nao serem apresentado ao inclui/editar/visualizar
	oStruDL9:RemoveField('DL9_MARK')
	oStruDL9:RemoveField('DL9_STATUS')
	oStruDL9:RemoveField('DL9_FILGER')
	oStruDL9:RemoveField('DL9_CODUSR')

	oStruDL8:RemoveField('DL8_SEQMET')
	oStruDL8:RemoveField('DL8_TIPVEI')
	oStruDL8:RemoveField('DL8_DESTVE')

	oStruDL8:SetProperty('DL8_COD'   , MVC_VIEW_ORDEM, '01')
	oStruDL8:SetProperty('DL8_SEQ'   , MVC_VIEW_ORDEM, '02')	
	oStruDL8:SetProperty('DL8_CLIDEV', MVC_VIEW_ORDEM, '03')
	oStruDL8:SetProperty('DL8_LOJDEV', MVC_VIEW_ORDEM, '04')
	oStruDL8:SetProperty('DL8_NOMDEV', MVC_VIEW_ORDEM, '05')
	oStruDL8:SetProperty('DL8_CRTDMD', MVC_VIEW_ORDEM, '06')
	oStruDL8:SetProperty('DL8_CODGRD', MVC_VIEW_ORDEM, '07')
	oStruDL8:SetProperty('DL8_DESGRD', MVC_VIEW_ORDEM, '08')
	oStruDL8:SetProperty('DL8_DATPRV', MVC_VIEW_ORDEM, '09')
	oStruDL8:SetProperty('DL8_HORPRV', MVC_VIEW_ORDEM, '10')
	oStruDL8:SetProperty('DL8_QTD'   , MVC_VIEW_ORDEM, '11')
	oStruDL8:SetProperty('DL8_UM'    , MVC_VIEW_ORDEM, '12')
	oStruDL8:SetProperty('DL8_QTDPO' , MVC_VIEW_ORDEM, '13')
	oStruDL8:SetProperty('DL8_QTDPD' , MVC_VIEW_ORDEM, '14')
	oStruDL8:SetProperty('DL8_PRVORI', MVC_VIEW_ORDEM, '15')
	oStruDL8:SetProperty('DL8_HRPROR', MVC_VIEW_ORDEM, '15')
	oStruDL8:SetProperty('DL8_PRVDES', MVC_VIEW_ORDEM, '16')
	oStruDL8:SetProperty('DL8_HRPRDS', MVC_VIEW_ORDEM, '16')
	
	oStruDLA:RemoveField('DLA_CODDMD')
	oStruDLA:RemoveField('DLA_SEQDMD')
	
	oStruDLA:SetProperty('DLA_SEQREG', MVC_VIEW_CANCHANGE, .F.)
	oStruDLA:SetProperty('DLA_PREVIS', MVC_VIEW_CANCHANGE, .F.)
	oStruDLA:SetProperty('DLA_QTD'	 , MVC_VIEW_CANCHANGE, .F.)
	oStruDLA:SetProperty('DLA_CODREG', MVC_VIEW_CANCHANGE, .F. )
	oStruDLA:SetProperty('DLA_CODCLI', MVC_VIEW_CANCHANGE, .F. )
	oStruDLA:SetProperty('DLA_LOJA'  , MVC_VIEW_CANCHANGE, .F. )
	
	oStruDLL:RemoveField('DLL_CODDMD')
	oStruDLL:RemoveField('DLL_SEQDMD')
	
	oStruDLL:SetProperty('DLL_SEQREG', MVC_VIEW_CANCHANGE, .F.)
	oStruDLL:SetProperty('DLL_PREVIS', MVC_VIEW_CANCHANGE, .F.)
	oStruDLL:SetProperty('DLL_CODREG', MVC_VIEW_CANCHANGE, .F.)
			
	oView:AddField( 'VIEW_DL9', oStruDL9, 'MASTER_DL9' )
	
	oView:CreateHorizontalBox('BOX_UP',40)
	oView:CreateHorizontalBox('BOX_MD',32)
	oView:CreateHorizontalBox('BOX_DW',28)
	
	oView:CreateVerticalBox('BOX_DW_ESQ',50,'BOX_DW')
	oView:CreateVerticalBox('BOX_DW_DIR',50,'BOX_DW')
	
	oView:CreateHorizontalBox('BOX_ORI'  , 100,'BOX_DW_ESQ')
	oView:CreateHorizontalBox('BOX_DES'  , 100,'BOX_DW_DIR')
	
	//Cria grid de demandas
	oView:AddGrid('GRID_DEMAN', oStruDL8, 'GRID_DEMAN')
	oView:EnableTitleView('GRID_DEMAN', STR0006) //Demandas
	oView:AddUserButton(STR0055,'',{|| TMSLegDmd('DL8_STATUS') }) //Status da demanda
	
	oView:SetViewProperty("GRID_DEMAN", "GRIDDOUBLECLICK", {{|oModel,cField| TMSLegDmd(cField)}}) 

	//Cria grid de Origens
	oView:AddGrid('GRID_ORI', oStruDLA, 'GRID_ORI')
	oView:EnableTitleView('GRID_ORI', STR0007) //Origem
	
	//Cria grid de Destinos
	oView:AddGrid('GRID_DES', oStruDLL, 'GRID_DES')
	oView:EnableTitleView('GRID_DES', STR0008) //Destino
	
	oView:AddIncrementField( 'GRID_ORI', 'DLA_SEQREG' )
	oView:AddIncrementField( 'GRID_DES', 'DLL_SEQREG' )

	oView:SetViewCanActivate( { |oView,cIdView,nNumLine| T153BlqReg( oView,'MASTER_DL9',nNumLine ) } )

	oView:SetOwnerView( 'VIEW_DL9', 'BOX_UP')
	oView:SetOwnerView( 'GRID_DEMAN', 'BOX_MD')
	oView:SetOwnerView( 'GRID_ORI', 'BOX_ORI')
	oView:SetOwnerView( 'GRID_DES', 'BOX_DES')
	
Return oView

//------------------------------------------------------------------- 
/*/{Protheus.doc} T153BlqReg
description
@author  Gustavo Krug
@since   12/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153BlqReg(oView,cIdView,nNumLine)
	
	oView:SetNoDeleteLine('GRID_ORI')
	oView:SetNoDeleteLine('GRID_DES')
	oView:SetNoInsertLine('GRID_ORI')
	oView:SetNoInsertLine('GRID_DES')
	
	//Refresh browse planejamento
	nRfDMD := 2
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} T153StBlRg
description
@author  Gustavo Krug
@since   12/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153StBlRg(oModel, lBloq)
Local oModelOri := oModel:GetModel('GRID_ORI')
Local oModelDes := oModel:GetModel('GRID_DES')

	oModelOri:SetNoDeleteLine(lBloq)
	oModelDes:SetNoDeleteLine(lBloq)
	oModelOri:SetNoInsertLine(lBloq)
	oModelDes:SetNoInsertLine(lBloq)
	
Return .T.


//----------------------------------------------------------------
/*/{Protheus.doc} T153BDeAct
Desativação do modelo 
@type function
@author Ruan Ricardo Salvador
@version 12.1.17
@since 04/07/2018
/*/
//-----------------------------------------------------------------
Function T153BDeAct(oModel)
	Local cCodDMD
	Local cSeqDMD 
	Local nIndex	:= DL8->(IndexOrd())
	
	If type('nRfDMD') == 'N' .And. (nRfDMD == 2 ) 
		Pergunte('TMSA153', .F.)
		
		If !lCanPLN
			If oModel:GetOperation() == MODEL_OPERATION_DELETE
				oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
				oBrwDeman:GoTo(nPosDL8)
				If Empty(DL8->DL8_COD)
					oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
					oBrwDeman:Refresh()
				EndIf
				oBrwPlan:SetFilterDefault(TMA153Filt("DL9"))	
			Else
				oBrwDeman:GoTo(nPosDL8)
				cCodDMD := DL8->DL8_COD
				cSeqDMD := DL8->DL8_SEQ
				oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
				DL8->(DbSetOrder(1))
				If !DL8->(DbSeek(xFilial('DL8')+cCodDMD+cSeqDMD))
					DL8->(DbSetOrder(nIndex))
					oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
					oBrwDeman:GoTop()
				Else
					DL8->(DbSetOrder(nIndex))
					oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
					oBrwDeman:GoTo(nPosDL8)
				EndIf
				oBrwPlan:SetFilterDefault(TMA153Filt("DL9"))
				if oModel:GetOperation() == MODEL_OPERATION_INSERT
					oBrwPlan:GoBottom()
					if Empty(DL9->DL9_COD)
						DL9->(dbSetOrder(1))
						oBrwPlan:GoUp(1)
						oBrwPlan:Refresh()
					endif
				endif
				Iif(oModel:GetOperation() == MODEL_OPERATION_UPDATE, oBrwPlan:GoTo(nPosDL9),)
			EndIf
		Else
			DL8->(DbSetOrder(nIndex))
			oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
			oBrwDeman:GoTo(nPosDL8)
			oBrwPlan:SetFilterDefault(TMA153Filt("DL9"))
			oBrwPlan:GoTo(nPosDL9)	
			lCanPLN := .F.
		EndIf
	EndIf

	SetKey(VK_F5,{ ||TMA153Par(.F.)} )
	SetKey(VK_F12,{ ||Pergunte('TMSA1531', .T.), Pergunte('TMSA153', .F.)} )
	
Return 

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MdoStruDL8
Cria a estrutura da tabela DL8 para o model
@type function
@author Ruan Ricardo Salvador.
@version 12.1.17
@since 09/04/2017
/*/
//-------------------------------------------------------------------------------------------------
Static Function MdoStruDL8() 
	Local oStruDL8 := FWFormStruct(1, 'DL8')

	
	oStruDL8:AddField(STR0060															,;	// 	[01]  C   Titulo do campo  
					 STR0060															,;	// 	[02]  C   ToolTip do campo
					 "DL8_LEGDMD"		     											,;	// 	[03]  C   Id do Field
					 'BT'																,;	// 	[04]  C   Tipo do campo
					 1                       											,;	// 	[05]  N   Tamanho do campo
					 0																	,;	// 	[06]  N   Decimal do campo
					 Nil																,;	// 	[07]  B   Code-block de validação do campo
					 NIL																,;	// 	[08]  B   Code-block de validação When do campo
					 NIL																,;	//	[09]  A   Lista de valores permitido do campo
					 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL			 													,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
					 .F.																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.																)	// 	[14]  L   Indica se o campo é virtual
	
	oStruDL8:AddField(STR0009															,;	// 	[01]  C   Titulo do campo  
					 STR0009															,;	// 	[02]  C   ToolTip do campo
					 "DL8_COD"		     												,;	// 	[03]  C   Id do Field
					 "C"																,;	// 	[04]  C   Tipo do campo
					 TAMSX3("DL8_COD")[1]												,;	// 	[05]  N   Tamanho do campo
					 0																	,;	// 	[06]  N   Decimal do campo
					 NIL																,;	// 	[07]  B   Code-block de validação do campo
					 NIL																,;	// 	[08]  B   Code-block de validação When do campo
					 NIL																,;	//	[09]  A   Lista de valores permitido do campo
					 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .F.																)	// 	[14]  L   Indica se o campo é virtual

	oStruDL8:RemoveField('DL8_SEQ')
	
	oStruDL8:AddField('Sequencia'														,;	// 	[01]  C   Titulo do campo  
					 'Sequencia'														,;	// 	[02]  C   ToolTip do campo
					 "DL8_SEQ"		     												,;	// 	[03]  C   Id do Field
					 "C"																,;	// 	[04]  C   Tipo do campo
					 TAMSX3("DL8_SEQ")[1]												,;	// 	[05]  N   Tamanho do campo
					 0																	,;	// 	[06]  N   Decimal do campo
					 NIL																,;	// 	[07]  B   Code-block de validação do campo
					 NIL																,;	// 	[08]  B   Code-block de validação When do campo
					 NIL																,;	//	[09]  A   Lista de valores permitido do campo
					 .F.																,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 NIL																,;	//	[11]  B   Code-block de inicializacao do campo
					 NIL																,;	//	[12]  L   Indica se trata-se de um campo chave
					 NIL																,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .F.																)	// 	[14]  L   Indica se o campo é virtual
		

	oStruDL8:AddTrigger("DL8_COD", "DL8_COD", {||.T.}, {|oModel|LoadGrid(oModel)})
	oStruDL8:AddTrigger("DL8_SEQ", "DL8_SEQ", {||.T.}, {|oModel|LoadGrid(oModel)})
	
	oStruDL8:SetProperty('DL8_COD', MODEL_FIELD_WHEN,{|oModel|T153WHENDM(oModel,1)})
	oStruDL8:SetProperty('DL8_SEQ', MODEL_FIELD_WHEN,{|oModel|T153WHENDM(oModel,2)})	
	oStruDL8:SetProperty('DL8_CRTDMD', MODEL_FIELD_WHEN,{||.F.})
	oStruDL8:SetProperty('DL8_CLIDEV', MODEL_FIELD_WHEN,{||.F.})
	oStruDL8:SetProperty('DL8_LOJDEV', MODEL_FIELD_WHEN,{||.F.})
	oStruDL8:SetProperty('DL8_CODGRD', MODEL_FIELD_WHEN,{||.F.})
	oStruDL8:SetProperty('DL8_TIPVEI', MODEL_FIELD_WHEN,{||.F.})
	
	
	oStruDL8:SetProperty('*', MODEL_FIELD_OBRIGAT,.F.)
	oStruDL8:SetProperty('DL8_COD', MODEL_FIELD_OBRIGAT,.T.)
	oStruDL8:SetProperty('DL8_SEQ', MODEL_FIELD_OBRIGAT,.T.)
	
	oStruDL8:SetProperty('DL8_FILEXE',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,''))
	oStruDL8:SetProperty('DL8_COD',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,''))
	oStruDL8:SetProperty('DL8_SEQ',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,''))
	oStruDL8:SetProperty('DL8_LEGDMD',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'T153BCOR()'))
		
	oStruDL8:SetProperty('DL8_NOMDEV',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'TMIniDL8("DL8_NOMDEV")'))
	oStruDL8:SetProperty('DL8_DESGRD',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'TMIniDL8("DL8_DESGRD")'))
	oStruDL8:SetProperty('DL8_DESTVE',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'TMIniDL8("DL8_DESTVE")'))
	
	oStruDL8:SetProperty('DL8_COD',MODEL_FIELD_VALID ,{|oModel|VldDmdPln(oModel)})
	oStruDL8:SetProperty('DL8_SEQ',MODEL_FIELD_VALID ,{|oModel|VldDmdPln(oModel)})

Return oStruDL8

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VwStruDL8
Cria a estrutura da tabela DL8 para a view
@type function
@author Ruan Ricardo Salvador.
@version 12.1.17
@since 09/04/2017
/*/
//-------------------------------------------------------------------------------------------------
Static Function VwStruDL8()
	Local oStruDL8 := FWFormStruct(2, 'DL8')
	
	oStruDL8:AddField("DL8_LEGDMD"		     											,;	// [01]  C   Nome do Campo
					"01"																,;	// [02]  C   Ordem
					STR0060																,;	// [03]  C   Titulo do campo//"Descrição"
					STR0010																,;	// [04]  C   Descricao do campo//"Descrição"
					NIL																	,;	// [05]  A   Array com Help
					"BT"																,;	// [06]  C   Tipo do campo
					"@BMP"																,;	// [07]  C   Picture
					NIL																	,;	// [08]  B   Bloco de Picture Var
					NIL																	,;	// [09]  C   Consulta F3
					.T.																	,;	// [10]  L   Indica se o campo é alteravel
					NIL																	,;	// [11]  C   Pasta do campo
					NIL																	,;	// [12]  C   Agrupamento do campo
					NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL																	,;	// [15]  C   Inicializador de Browse
					.T.																	,;	// [16]  L   Indica se o campo é virtual
					NIL																	,;	// [17]  C   Picture Variavel
					NIL																	)	// [18]  L   Indica pulo de linha após o campo
	
	oStruDL8:RemoveField('DL8_COD')
	
	oStruDL8:RemoveField("DL8_CODOBS")
	oStruDL8:RemoveField("DL8_OBS")
	
	oStruDL8:AddField("DL8_COD"		     												,;	// [01]  C   Nome do Campo
					"02"																,;	// [02]  C   Ordem
					STR0009																,;	// [03]  C   Titulo do campo//"Descrição"
					STR0010																,;	// [04]  C   Descricao do campo//"Descrição"
					NIL																	,;	// [05]  A   Array com Help
					"C"																	,;	// [06]  C   Tipo do campo
					"@!"																,;	// [07]  C   Picture
					NIL																	,;	// [08]  B   Bloco de Picture Var
					"DL81"																,;	// [09]  C   Consulta F3
					.T.																	,;	// [10]  L   Indica se o campo é alteravel
					NIL																	,;	// [11]  C   Pasta do campo
					NIL																	,;	// [12]  C   Agrupamento do campo
					NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL																	,;	// [15]  C   Inicializador de Browse
					.F.																	,;	// [16]  L   Indica se o campo é virtual
					NIL																	,;	// [17]  C   Picture Variavel
					NIL																	)	// [18]  L   Indica pulo de linha após o campo
					
	oStruDL8:RemoveField('DL8_SEQ')
	
	oStruDL8:AddField("DL8_SEQ"		     											,;	// [01]  C   Nome do Campo
					"03"																,;	// [02]  C   Ordem
					'Sequencia'															,;	// [03]  C   Titulo do campo//"Descrição"
					'Sequencia'															,;	// [04]  C   Descricao do campo//"Descrição"
					NIL																	,;	// [05]  A   Array com Help
					"C"																	,;	// [06]  C   Tipo do campo
					"@!"																,;	// [07]  C   Picture
					NIL																	,;	// [08]  B   Bloco de Picture Var
					Nil 																,;	// [09]  C   Consulta F3
					.T.																	,;	// [10]  L   Indica se o campo é alteravel
					NIL																	,;	// [11]  C   Pasta do campo
					NIL																	,;	// [12]  C   Agrupamento do campo
					NIL																	,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL																	,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL																	,;	// [15]  C   Inicializador de Browse
					.F.																	,;	// [16]  L   Indica se o campo é virtual
					NIL																	,;	// [17]  C   Picture Variavel
					NIL																	)	// [18]  L   Indica pulo de linha após o campo
	
	oStruDL8:RemoveField('DL8_FILGER')
	oStruDL8:RemoveField('DL8_QTCTDM')
	oStruDL8:RemoveField('DL8_SDCTDM')
	oStruDL8:RemoveField('DL8_PLNDMD')
	oStruDL8:RemoveField('DL8_STATUS')
	oStruDL8:RemoveField('DL8_ORIDMD')	
	oStruDL8:RemoveField('DL8_MARK')
	
	oStruDL8:SetProperty( 'DL8_DATPRV', MVC_VIEW_CANCHANGE, .F. )
	oStruDL8:SetProperty( 'DL8_HORPRV', MVC_VIEW_CANCHANGE, .F. )
	oStruDL8:SetProperty( 'DL8_UM', MVC_VIEW_CANCHANGE, .F. )
	oStruDL8:SetProperty( 'DL8_QTD', MVC_VIEW_CANCHANGE, .F. )
	
Return oStruDL8

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA153BVL
Impedir a Alteração de Planejamentos de Demandas com o STATUS diferentes de "Em Aberto" 
@type function
@author André Luiz Custódio
@version 12.1.17
@since 04/05/2018
/*/
//-------------------------------------------------------------------------------------------------

Function TMSA153BVL(oModel)
	Local lRet := .T.	
	
	TClearFKey()

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or. oModel:GetOperation() == MODEL_OPERATION_DELETE 	
		If lRet 
			aRet := TMLockDmd("TMSA153B_" + DL9->DL9_FILIAL + DL9->DL9_COD)  //Verifica se registro encontra-se bloqueado por outro processo.	
			If !aRet[1]
				Help( ,, 'HELP',, aRet[2], 1, 0 )
				lRet := .F.
			EndIf
		Endif
		If lRet .AND. ( DL9->DL9_STATUS <> "1") .And. (DL9->DL9_STATUS  <> "2")
			Help( ,, 'TMSA153B',, STR0031, 1, 0 ) //Não é permitido alterar, excluir ou recusar Planejamentos de Demandas já executados.
			lRet := .F.      
		Endif  
    Endif 
    
	//--Não executar para teste automatizado 
    If !IsBlind()
    	//Grava as posicoes
    	nPosDL9 := oBrwPlan:At()
    	nPosDL8 := oBrwDeman:At() 
    	nPosDL7 := oBrwCrtDmd:At()
	EndIf 
	
	If !lRet
		SetKey(VK_F5,{ ||TMA153Par(.F.)} )
		SetKey(VK_F12,{ ||Pergunte('TMSA1531', .T.), Pergunte('TMSA153', .F.)} )
	EndIf
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA153GRV
Bloco Commit do model 
@type function
@author Ruan Ricardo Salvador.
@version 12.1.17
@since 09/04/2017
/*/
//-------------------------------------------------------------------------------------------------
Static Function TMSA153GRV(oModel)

	Local oModelDL9 := oModel:GetModel('MASTER_DL9')
	Local oModelDMD := oModel:GetModel('GRID_DEMAN')
	Local oModelORI := oModel:GetModel('GRID_ORI')
	Local oModelDES := oModel:GetModel('GRID_DES')
	Local lBlqTipVei:= SuperGetMv("MV_PLVDCD",.F.,.F.)  //Impedir planejamento de veículos diferentes do tipo de veículo do Contrato de Demanda?
	Local cIntTMSMNT:= SuperGetMv("MV_NGMNTMS",.F.,"N") //Integração Manutenção de Ativos (MNT) com Gestão de Transporte (TMS). Informar S=Sim ou N=Não.
	Local lRet 		:= .T.
	Local lMensagem := .F.
	Local lTmsBlqMnt:= .F.
	Local dDataIni	:= oModelDL9:GetValue('DL9_DATINI')
	Local dDataFin	:= oModelDL9:GetValue('DL9_DATFIM')
	Local cMensagem := ""
	Local cCtrVei	:= ""
	Local cCodUser  := RetCodUsr() //Retorna o Codigo do Usuario
	Local nX		:= 0
	Local nTamCODGRD:= TAMSX3("DLF_CODGRD")[1]
	Local aValTipVei:= {} //Valida tipos de veículos do planejamento? Usado quando existem demandas com contrato no planejamento
	Local aAreaDA3  := DA3->(GetArea())
	Local aAreaDUT  := DUT->(GetArea())
	Local aAreaDLF  := DLF->(GetArea())
	Local nOperation := oModel:GetOperation()

	//Validação de Demanda COM Contrato e SEM Data de previsão   
	For nX := 1 to oModelDMD:GetQTDLine()
		oModelDMD:SetLine(nX)
		If !Empty(oModelDMD:GetValue('DL8_CRTDMD',nX)) .And. Empty(oModelDMD:GetValue('DL8_DATPRV',nX))	.AND. !oModelDMD:IsDeleted() 
			If IsInCallStak("TMS153ADD") //Para o caso de estar efetuando o relacionamento entre Demanda e Planejamento via botão "Adicionar" do painel de demandas.
				Help( ,, 'HELP',, STR0046 + " " + oModelDMD:GetValue('DL8_COD',nX) + "/" + oModelDMD:GetValue('DL8_SEQ',nX) + STR0047, 1, 0 )//"A demanda 999999/99 possui contrato, porém, não possui data de previsão informada."
			Else
				oModel:SetErrorMessage('TMSA153B',,,,,STR0046 + " " + oModelDMD:GetValue('DL8_COD',nX) + "/" + oModelDMD:GetValue('DL8_SEQ',nX) + STR0047,'', nil, nil) //"A demanda 999999/99 possui contrato, porém, não possui data de previsão informada."
			EndIf
			lRet := .F.
		EndIf
	Next nX
	
	If lRet
		BEGIN TRANSACTION	
			If nOperation == MODEL_OPERATION_INSERT 
				If __lSX8
					ConfirmSX8()
				EndIf
				
				oModelDL9:SetValue('DL9_FILGER',cFilAnt)
				oModelDL9:SetValue('DL9_CODUSR',cCodUser)
				oModelDL9:SetValue('DL9_STATUS','1')
			EndIf 
		
			If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE .And. lRet
			
				//Atualiza o status do planejamento
				
				//////////////////////////////////////////////////////////////////////////////////////
				//Caso o Model de demandas não possua nenhuma demanda, o status é atualizado		//
				//para 1 - Aberto, caso possua uma ou mais demandas, o status é atualizado			//
				//para 2 - Aberto com demanda 														//
				//O trecho oModelDMD:Length(.T.) >= 1 .And. !Empty(oModelDMD:GetValue('DL8_COD')) 	//
				//é necessário pois se o modelo possuir apenas uma linha em branco,					//
				//a função Length(.T.) considera que o model possui uma linha		                //
				//Só será feito se o model de demanda for modificado devido à rotina de recusa, que //
				//faz o loadmodel e apenas muda a situação para 5.				                    //
				//////////////////////////////////////////////////////////////////////////////////////
				//DLOGTMS01-4696 - O IIF existente antes foi alterado para um FOR, a fim de validar //
				//quais das linhas preenchidas e não deletadas realmente possuem demandas. Por      //
				//default o Status é iniciado como "1". Ao encontrar uma Demanda preenchida e não   //
				//deletada, o status é alterado para "2" e o FOR é finalizado.                      // 
				//////////////////////////////////////////////////////////////////////////////////////
				If oModelDMD:IsModified()
					oModelDL9:SetValue('DL9_STATUS','1')
					For nX := 1 to oModelDMD:GetQTDLine()
						oModelDMD:SetLine(nX)
						If !(oModelDMD:IsDeleted()) .And. !Empty(oModelDMD:GetValue('DL8_COD'))
						   oModelDL9:SetValue('DL9_STATUS','2')
						   Exit
						EndIf
					Next nX
				EndIf 
		
				//Atualiza as registros de origem e destino da demanda   
				For nX := 1 to oModelDMD:GetQTDLine()
					oModelDMD:SetLine(nX) 
					If (!Empty(oModelORI:GetLinesChanged()) .Or. !Empty(oModelDES:GetLinesChanged())) .And. (!oModelDMD:IsDeleted())
						lRet := T153ATUORI(oModel,oModelDMD)
						If !lRet
							Exit
						EndIf
						lRet := T153ATUDES(oModel,oModelDMD)
						If !lRet
							Exit
						EndIf						
					EndIf
					If !Empty(oModelDMD:GetValue('DL8_CRTDMD')) .And. (!oModelDMD:IsDeleted())
						If AScan(aValTipVei,oModelDMD:GetValue('DL8_CRTDMD')) = 0 
							aAdd(aValTipVei,oModelDMD:GetValue('DL8_CRTDMD'))
						EndIf
					EndIf
				Next nX
				
				DA3->(dbSetOrder(1))
				DUT->(dbSetOrder(1))
				DLF->(dbSetOrder(1))
				If DLF->(DBSeek(xFilial('DLF') + oModelDMD:GetValue('DL8_CRTDMD') + Space(nTamCODGRD)))
					If lRet .AND. !IsInCallStack('TMS153ADD')
						If DA3->(DbSeek(xFilial('DA3') + oModelDL9:GetValue('DL9_CODVEI')))
							If DUT->(DbSeek(xFilial('DUT') + DA3->DA3_TIPVEI))	//Validação para desconsiderar a categoria "cavalo"
								For nX := 1 to Len(aValTipVei)
									If DUT->DUT_CATVEI <> '2' .AND. !(DLF->(DbSeek(xFilial('DLF') + aValTipVei[nX] + Space(nTamCODGRD) + DA3->DA3_TIPVEI ))) 
										If lBlqTipVei
											lRet := .F.
											oModel:SetErrorMessage('TMSA153B',,,,,STR0043 + DA3->DA3_COD + STR0044 + aValTipVei[nX] + STR0045,'', nil, nil) //O tipo do veículo " + DA3->DA3_COD + " não está cadastrado no contrato de demanda " + aValTipVei[nX] + ". Não foi possível salvar o planejamento. (MV_PLVDCD)
											Exit
								 		Else 
								 			cMensagem := STR0043 + DA3->DA3_COD + STR0044 + aValTipVei[nX] + "." //O tipo do veículo " + DA3->DA3_COD + " não está cadastrado no contrato de demanda " + aValTipVei[nX]
								 			cCtrVei := aValTipVei[nX]  
								 		EndIf
								 	EndIf
							 	Next nX						 	
							EndIf
						EndIf
						If lRet .AND. !Empty(oModelDL9:GetValue('DL9_CODRB1')) .AND. DA3->(DbSeek(xFilial('DA3') + oModelDL9:GetValue('DL9_CODRB1'))) 
							For nX := 1 to Len(aValTipVei)
								If !(DLF->(DbSeek(xFilial('DLF') + aValTipVei[nX] + Space(nTamCODGRD) + DA3->DA3_TIPVEI )))
								 	If lBlqTipVei
										lRet := .F.
										oModel:SetErrorMessage('TMSA153B',,,,,STR0043 + DA3->DA3_COD + STR0044 + aValTipVei[nX] + STR0045,'', nil, nil) //O tipo do veículo " + DA3->DA3_COD + " não está cadastrado no contrato de demanda " + aValTipVei[nX] + ". Não foi possível salvar o planejamento. (MV_PLVDCD)
										Exit
								 	Else
								 		If Empty(cMensagem)
								 			cMensagem := STR0043 + DA3->DA3_COD + STR0044 + aValTipVei[nX] + "." //O tipo do veículo " + DA3->DA3_COD + " não está cadastrado no contrato de demanda " + aValTipVei[nX]
								 		Else
								 		 	lMensagem := .T.
								 		 	iIF(!(aValTipVei[nX] $ cCtrVei),iIf(Empty(cCtrVei),cCtrVei := aValTipVei[nX],cCtrVei += " / " + aValTipVei[nX]),) 
								 		EndIf
								 	EndIf
								EndIf				
							Next nX
							If lRet .AND. !Empty(oModelDL9:GetValue('DL9_CODRB2')) .AND. DA3->(DbSeek(xFilial('DA3') + oModelDL9:GetValue('DL9_CODRB2'))) 
								For nX := 1 to Len(aValTipVei)
									If !(DLF->(DbSeek(xFilial('DLF') + aValTipVei[nX] + Space(nTamCODGRD) + DA3->DA3_TIPVEI )))
									 	If lBlqTipVei
											lRet := .F.
											oModel:SetErrorMessage('TMSA153B',,,,,STR0043 + DA3->DA3_COD + STR0044 + aValTipVei[nX] + STR0045,'', nil, nil) //O tipo do veículo " + DA3->DA3_COD + " não está cadastrado no contrato de demanda " + aValTipVei[nX] + ". Não foi possível salvar o planejamento. (MV_PLVDCD)
											Exit
									 	Else
										 	If Empty(cMensagem)
									 			cMensagem := STR0043 + DA3->DA3_COD + STR0044 + aValTipVei[nX] + "." //O tipo do veículo " + DA3->DA3_COD + " não está cadastrado no contrato de demanda " + aValTipVei[nX]
									 		Else
									 		 	lMensagem := .T.
									 		 	iIF(!(aValTipVei[nX] $ cCtrVei),iIf(Empty(cCtrVei),cCtrVei := aValTipVei[nX],cCtrVei += " / " + aValTipVei[nX]),) 
									 		EndIf
									 	EndIf
									EndIf				
								Next nX	
								If lRet .AND. !Empty(oModelDL9:GetValue('DL9_CODRB3')) .AND. DA3->(DbSeek(xFilial('DA3') + oModelDL9:GetValue('DL9_CODRB3'))) 
									For nX := 1 to Len(aValTipVei)
										If !(DLF->(DbSeek(xFilial('DLF') + aValTipVei[nX] + Space(nTamCODGRD) + DA3->DA3_TIPVEI )))
										 	If lBlqTipVei
												lRet := .F.
												oModel:SetErrorMessage('TMSA153B',,,,,STR0043 + DA3->DA3_COD + STR0044 + aValTipVei[nX] + STR0045,'', nil, nil) //O tipo do veículo " + DA3->DA3_COD + " não está cadastrado no contrato de demanda " + aValTipVei[nX] + ". Não foi possível salvar o planejamento. (MV_PLVDCD)
												Exit
										 	Else
											 	If Empty(cMensagem)
										 			cMensagem := STR0043 + DA3->DA3_COD + STR0044 + aValTipVei[nX] + "." //O tipo do veículo " + DA3->DA3_COD + " não está cadastrado no contrato de demanda " + aValTipVei[nX]
										 		Else
										 		 	lMensagem := .T.
										 		 	iIF(!(aValTipVei[nX] $ cCtrVei),iIf(Empty(cCtrVei),cCtrVei := aValTipVei[nX],cCtrVei += " / " + aValTipVei[nX]),) 
										 		EndIf
										 	EndIf
										EndIf				
									Next nX	
								EndIf
							EndIf
						EndIf
						iIf(lMensagem, MsgInfo(STR0052 + cCtrVei),iIf(!Empty(cMensagem),Msginfo(cMensagem),))  //Tipo de veículo utilizado no Planejamento de Demanda não está previsto no(s) Contrato(s) de Demanda(s): 
					EndIf
				Endif

				//Validação de integração Manutencao de Ativos
				If lRet .AND. cIntTMSMNT == "S" .AND. !Empty(oModelDL9:GetValue('DL9_CODVEI'))
					If TmsBlqMnt(oModelDL9:GetValue('DL9_CODVEI'),dDataIni,dDataFin,1) .OR. !TMSA240Blq(oModelDL9:GetValue('DL9_CODVEI'))
						lTmsBlqMnt := .T.
				    Else
					    If !Empty(oModelDL9:GetValue('DL9_CODRB1'))
							If TmsBlqMnt(oModelDL9:GetValue('DL9_CODRB1'),dDataIni,dDataFin,1) .OR. !TMSA240Blq(oModelDL9:GetValue('DL9_CODRB1'))
								lTmsBlqMnt := .T.
							Else
								If !Empty(oModelDL9:GetValue('DL9_CODRB2'))
									If TmsBlqMnt(oModelDL9:GetValue('DL9_CODRB2'),dDataIni,dDataFin,1) .OR. !TMSA240Blq(oModelDL9:GetValue('DL9_CODRB2'))
										lTmsBlqMnt := .T.
									Else 
										If !Empty(oModelDL9:GetValue('DL9_CODRB3'))
											lTmsBlqMnt := TmsBlqMnt(oModelDL9:GetValue('DL9_CODRB3'),dDataIni,dDataFin,1) .OR. !TMSA240Blq(oModelDL9:GetValue('DL9_CODRB3'))
										Endif
									EndIf
								EndIf
							 EndIf
						EndIf
					EndIf
					If lTmsBlqMnt
						lRet := ApMSGYESNO(STR0071,STR0072)//""Aviso de futuro bloqueio Manuteção de Ativos na Viagem. Deseja continuar?" "Veículos - SIGATMS X SIGAMNT"
					EndIf
					If !lRet
						FwClearHLP() 
						oModel:SetErrorMessage (,,,,,STR0073) //"Operação abortada pelo operador. Registro não foi salvo."
					EndIf
				EndIf
			EndIf
		
			If nOperation == MODEL_OPERATION_DELETE
				//Remove o codigo do planejamento das demandas
				For nX:= 1 to oModelDMD:GetQTDLine()
					TMUnLockDmd("TMSA153A_" + oModelDMD:GetValue('DL8_FILIAL',nX) + oModelDMD:GetValue('DL8_COD',nX) + oModelDMD:GetValue('DL8_SEQ',nX),.T.)
					lRet := T153ATUDMD(oModel,oModelDL9,oModelDMD,nX,3)
					If !lRet
						Exit
					EndIf
				Next nX
				If lRet
					TmIncTrk('3', oModelDL9:GetValue('DL9_FILIAL'), oModelDL9:GetValue('DL9_COD'),/*cSeqDoc*/,/*cDocPai*/,'X',/*cCodMotOpe*/,/*cObs*/)
				EndIf
			EndIf
			
			If lRet		
				
				If FwFormCommit(oModel)

					//gravação do tracking
					If nOperation == MODEL_OPERATION_INSERT
						TmIncTrk('3', DL9->DL9_FILIAL, DL9->DL9_COD,/*cSeqDoc*/,/*cDocPai*/,'I',/*cCodMotOpe*/,/*cObs*/)

						//Atualiza a demanda com o codigo do planejamento
						If oModelDMD:IsModified() .And. oModelDMD:VldData()
							If oModelDMD:Length(.T.) >= 1
								For nX:= 1 to Len(oModelDMD:GetLinesChanged())
									If !oModelDMD:IsDeleted(nX)
										lRet := T153ATUDMD(oModel,oModelDL9,oModelDMD,oModelDMD:GetLinesChanged()[nX],1)
										If !lRet
											Exit
										EndIf
									EndIf
								Next nX
							EndIf
						EndIf
					EndIf

					If nOperation == MODEL_OPERATION_UPDATE
						//Atualiza a demanda com o codigo do planejamento
						If oModelDMD:IsModified()
							For nX:= 1 to Len(oModelDMD:GetLinesChanged())
								lRet := T153ATUDMD(oModel,oModelDL9,oModelDMD,oModelDMD:GetLinesChanged()[nX],2)
								If !lRet
									Exit
								EndIf
							Next nX
						EndIf
					EndIf
		
					If Vazio(DL9->DL9_MARK)
						TMUnLockDmd("TMSA153B_" + DL9->DL9_FILIAL + DL9->DL9_COD,.T.)
					Endif
				Else
					DisarmTransaction()
					Break
				EndIf
			Else
				DisarmTransaction()
				Break
			EndIf
			
			RestArea(aAreaDA3)
			RestArea(aAreaDUT)
			RestArea(aAreaDLF)
			
		END TRANSACTION
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T153BCanc()
Trata evento Cancelar do Model
@author  Gustavo Krug
@since   25/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153BCanc(oModel)
Local oModelDMD := oModel:GetModel('GRID_DEMAN')
Local lRet := .T.
Local nX

	For nX := 1 to oModelDMD:GetQTDLine()
		If !Empty(oModelDMD:GetValue('DL8_COD', nX)) .And. !(oBrwDeman:Mark() == oModelDMD:GetValue('DL8_MARK', nX))
			TMUnLockDmd("TMSA153A_" + oModelDMD:getValue('DL8_FILIAL',nX) + oModelDMD:getValue('DL8_COD',nX) + oModelDMD:getValue('DL8_SEQ',nX),.T.)	
		EndIf
	Next nX
	
	If Vazio(DL9->DL9_MARK)
		TMUnLockDmd("TMSA153B_" + DL9->DL9_FILIAL + DL9->DL9_COD,.T.)
	Endif 

	FWFormCancel(oModel)

	If __lSX8
		RollBackSX8()
	EndIf	
	
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T153ATUDMD
Atualiza a demanda
@type function
@author Ruan Ricardo Salvador.
@version 12.1.17
@since 09/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function T153ATUDMD(oModel,oModelDL9,oModelDMD,nX,nOpc)
	Local oModelDL8
	Local lRet := .T.
	Local nIndex	:= DL8->(IndexOrd())

	aAreaDL8:= DL8->(GetArea())
  	DL8->(DbClearFilter())
	DL8->(DbCloseArea())   
	DL8->(DbSetOrder(1))
	
	oModelDMD:SetLine(nX)    

	If DL8->( dbSeek(xFilial('DL8')+oModelDMD:GetValue('DL8_COD',nX)+oModelDMD:GetValue('DL8_SEQ',nX)))
		aRet := TMLockDmd("TMSA153A_" + xFilial('DL8')+oModelDMD:GetValue('DL8_COD',nX)+oModelDMD:GetValue('DL8_SEQ',nX),.T.)
		If aRet[1]				
			oModelDL8 := FWLoadModel('TMSA153A')
			oModelDL8:GetModel('MASTER_DL8'):GetStruct():SetProperty("DL8_PLNDMD", MODEL_FIELD_WHEN,{||.T.})
			oModelDL8:SetOperation(MODEL_OPERATION_UPDATE)
			oModelDL8:Activate()
	
			If nOpc == 1 .Or. nOpc == 2 //Inclusao ou alteracao
				If oModelDMD:IsDeleted() .And. nOpc == 2
					oModelDL8:SetValue('MASTER_DL8','DL8_PLNDMD','')
					oModelDL8:SetValue('MASTER_DL8','DL8_MARK','')
					oModelDL8:SetValue('MASTER_DL8','DL8_STATUS','1')
				ElseIf !oModelDMD:IsDeleted()
					oModelDL8:SetValue('MASTER_DL8','DL8_PLNDMD',oModelDL9:GetValue('DL9_COD'))
					oModelDL8:SetValue('MASTER_DL8','DL8_MARK','')
					oModelDL8:SetValue('MASTER_DL8','DL8_STATUS','2')					
				EndIf				
			ElseIf nOpc == 3 //Exclusao
				oModelDL8:SetValue('MASTER_DL8','DL8_PLNDMD','')
				oModelDL8:SetValue('MASTER_DL8','DL8_MARK','')
				oModelDL8:SetValue('MASTER_DL8','DL8_STATUS','1')
			EndIf
			
			If oModelDL8:VldData()
				If oModelDL8:CommitData()
					//Atualiza o saldo do contrato e tracking da demanda
					If nOpc == 1 .Or. (nOpc == 2 .And. oModelDMD:IsInserted())
						If !Empty(oModelDMD:GetValue('DL8_CRTDMD'))
							TMUpQtMDmd(xFilial('DL8'), oModelDMD:GetValue('DL8_CRTDMD'), oModelDMD:GetValue('DL8_CODGRD'), oModelDMD:GetValue('DL8_TIPVEI'), oModelDMD:GetValue('DL8_SEQMET'), oModelDMD:GetValue('DL8_QTD'), 3)
						EndIf
						TmIncTrk('2', oModelDMD:GetValue('DL8_FILIAL'), oModelDMD:GetValue('DL8_COD'),oModelDMD:GetValue('DL8_SEQ'),oModelDL9:GetValue('DL9_COD'),'P',/*cCodMotOpe*/,/*cObs*/)
					ElseIf nOpc == 3 .Or. (nOpc == 2 .And. oModelDMD:IsDeleted())
						If !Empty(oModelDMD:GetValue('DL8_CRTDMD'))
							TMUpQtMDmd(xFilial('DL8'), oModelDMD:GetValue('DL8_CRTDMD'), oModelDMD:GetValue('DL8_CODGRD'), oModelDMD:GetValue('DL8_TIPVEI'), oModelDMD:GetValue('DL8_SEQMET'), oModelDMD:GetValue('DL8_QTD'), 4)
						EndIf
						TmIncTrk('2', oModelDMD:GetValue('DL8_FILIAL'), oModelDMD:GetValue('DL8_COD'),oModelDMD:GetValue('DL8_SEQ'),oModelDL9:GetValue('DL9_COD'),'D',/*cCodMotOpe*/,/*cObs*/)
					EndIf
				Else
					oModel:SetErrorMessage(,,,,,oModelDL8:GetErrorMessage()[6])
					lRet := .F.
				EndIf
			Else				
				VarInfo('',oModelDL8:GetErrorMessage())
				oModel:SetErrorMessage(,,,,,oModelDL8:GetErrorMessage()[6])
				lRet := .F.
			EndIf
			
			oModelDL8:DeActivate()			
		EndIf
	EndIf
	RestArea( aAreaDL8 )
	DL8->(DbSetOrder(nIndex))
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T153ATUORI
Atualiza as regios das demandas
@type function
@author Ruan Ricardo Salvador.
@version 12.1.17
@since 04/05/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function T153ATUORI(oModel, oModelDMD)
	Local oModelDL8  := Nil
	Local oModelGrid := Nil
	
	Local aAreaDLA   := DLA->(GetArea())
	Local aAreaDL8   := DL8->(GetArea())
	
	Local lRet       := .T.
	
	Local nIndex	 := DL8->(IndexOrd())
	Local nX         := 0
		
	Local cOldFilter := DL8->(dbFilter())

	DL8->(DbClearFilter())
	DL8->(DbCloseArea())   
	DL8->(DbSetOrder(1))    

	If DL8->( dbSeek(xFilial('DL8')+oModelDMD:GetValue('DL8_COD')+oModelDMD:GetValue('DL8_SEQ')))
		oModelDL8 := FWLoadModel('TMSA153A')
		oModelDL8:GetModel('MASTER_DL8'):GetStruct():SetProperty("DL8_PLNDMD", MODEL_FIELD_WHEN,{||.T.})
		oModelDL8:SetOperation(MODEL_OPERATION_UPDATE)
		oModelDL8:Activate()	
		
		oModelGrid := oModel:GetModel('GRID_ORI')
			
		For nX := 1 to Len(oModelGrid:GetLinesChanged())
			oModelGrid:SetLine(oModelGrid:GetLinesChanged()[nX])
					
			DLA->(DbSetOrder(1))
			If DLA->( dbSeek(xFilial('DLA')+oModelDMD:GetValue('DL8_COD')+oModelDMD:GetValue('DL8_SEQ')+oModelGrid:GetValue('DLA_SEQREG')))
						
				oModelDL8:GetModel('GRID_ORI'):SeekLine({{'DLA_SEQREG', oModelGrid:GetValue('DLA_SEQREG')}})
								
				oModelDL8:SetValue('GRID_ORI','DLA_CODREG',oModelGrid:GetValue('DLA_CODREG'))
				oModelDL8:SetValue('GRID_ORI','DLA_DTPREV',oModelGrid:GetValue('DLA_DTPREV'))
				oModelDL8:SetValue('GRID_ORI','DLA_HRPREV',oModelGrid:GetValue('DLA_HRPREV'))
			EndIf
		Next Nx		
		
		If Len(oModelGrid:GetLinesChanged()) > 0 
			If oModelDL8:VldData()  
				If !oModelDL8:CommitData()
					oModel:SetErrorMessage(,,,,,oModelDL8:GetErrorMessage()[6])
					lRet := .F.
				EndIf			
			Else				
				VarInfo('',oModelDL8:GetErrorMessage())
				oModel:SetErrorMessage(,,,,,oModelDL8:GetErrorMessage()[6])
				lRet := .F.
			EndIf	
		EndIf
		oModelDL8:DeActivate()	
	EndIf
		
	RestArea( aAreaDL8 )
	RestArea( aAreaDLA )

	If !Empty( cOldFilter )
		Set Filter to &cOldFilter
	EndIf	

	DL8->(DbSetOrder(nIndex))
Return lRet


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T153ATUDES
Atualiza as regiões destino das demandas
@type function
@author Ruan Ricardo Salvador.
@version 12.1.17
@since 04/05/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function T153ATUDES(oModel, oModelDMD)
	Local oModelDL8  := Nil
	Local oModelGrid := Nil

	Local aAreaDLL   := DLL->(GetArea())
	Local aAreaDL8   := DL8->(GetArea())
	
	Local lRet 		 := .T.
	
	Local nIndex	 := DL8->(IndexOrd())
	Local nX         := 0
	
	Local cOldFilter := DL8->(dbFilter())
	
	DL8->(DbClearFilter())
	DL8->(DbCloseArea())   
	DL8->(DbSetOrder(1))    

	If DL8->( dbSeek(xFilial('DL8')+oModelDMD:GetValue('DL8_COD')+oModelDMD:GetValue('DL8_SEQ')))
		oModelDL8 := FWLoadModel('TMSA153A')
		oModelDL8:GetModel('MASTER_DL8'):GetStruct():SetProperty("DL8_PLNDMD", MODEL_FIELD_WHEN,{||.T.})
		oModelDL8:SetOperation(MODEL_OPERATION_UPDATE)
		oModelDL8:Activate()
	
		oModelGrid := oModel:GetModel('GRID_DES')
				
		For nX := 1 to Len(oModelGrid:GetLinesChanged())
			oModelGrid:SetLine(oModelGrid:GetLinesChanged()[nX])
				
			DLL->(DbSetOrder(1))
			If DLL->( dbSeek(xFilial('DLL')+oModelDMD:GetValue('DL8_COD')+oModelDMD:GetValue('DL8_SEQ')+oModelGrid:GetValue('DLL_SEQREG')))
						
				oModelDL8:GetModel('GRID_DES'):SeekLine({{'DLL_SEQREG', oModelGrid:GetValue('DLL_SEQREG')}})
											
				oModelDL8:SetValue('GRID_DES','DLL_CODREG',oModelGrid:GetValue('DLL_CODREG'))
				oModelDL8:SetValue('GRID_DES','DLL_DTPREV',oModelGrid:GetValue('DLL_DTPREV'))
				oModelDL8:SetValue('GRID_DES','DLL_HRPREV',oModelGrid:GetValue('DLL_HRPREV'))
			EndIf
		Next Nx
			
		If Len(oModelGrid:GetLinesChanged()) > 0
			If oModelDL8:VldData()  
				If !oModelDL8:CommitData()
					oModel:SetErrorMessage(,,,,,oModelDL8:GetErrorMessage()[6])
					lRet := .F.
				EndIf			
			Else				
				VarInfo('',oModelDL8:GetErrorMessage())
				oModel:SetErrorMessage(,,,,,oModelDL8:GetErrorMessage()[6])
				lRet := .F.
			EndIf
		EndIf
		oModelDL8:DeActivate()	
	EndIf
		
	RestArea( aAreaDL8 )
	RestArea( aAreaDLL )
	
	If !Empty( cOldFilter )
		Set Filter to &cOldFilter
	EndIf	

	DL8->(DbSetOrder(nIndex))
Return lRet


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMS153REB
Gatilha os reboques do veiculo de sua ultima viagem
@type function
@author Gustavo Baptista.
@version 12.1.17
@since 13/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Function TMS153REB(cCodVei,cTipo,cCampo) 

	Local cTemp:= GetNextAlias()
	Local cQuery  := ""
	Local lRet:= .T.
	Local aArea := DA4->(GetArea())

	If !Empty(cCodVei) .AND. cTipo == '1' //cavalo
	       
	   	DA3->(DbSetOrder(1))
		If DA3->(DbSeek(xFilial("DA3")+cCodVei))       
			If DA3->DA3_ATIVO <> '1'
				Help("",1,"TMSA153B8")//Não é possível informar veículos inativos no Planejamento de Demanda.
				lRet := .F.
			Else			
				DUT->(DbSetOrder(1))
				If DUT->(DbSeek(xFilial("DUT")+DA3->DA3_TIPVEI))
					If DUT->DUT_CATVEI == '3'           	
						Help("",1,"TMSA153B2") //Informe um veiculo tracionador				  
						lRet:= .F.
					Else
						If DUT->DUT_CATVEI <> '2'
							M->DL9_CODRB1 := ''
							M->DL9_MODRB1 := ''
							M->DL9_CODRB2 := ''
							M->DL9_MODRB2 := ''
					 		M->DL9_CODRB3 := ''
							M->DL9_MODRB3 := ''
						EndIf
					EndIf
				EndIf
			EndIf
		Else                
			lRet:= .F.
		EndIf
		
		Pergunte('TMSA1531', .F.) //Configuracoes
		If MV_PAR01 == 1 .And. lRet   
			//Carrega os reboques e motorista de ultima viagem do veículo
			If (Empty(M->DL9_CODRB1)) .And. (Empty(M->DL9_CODMOT))
				
				cQuery  += " SELECT DTR.DTR_CODRB1, "
				cQuery  += "        DTR.DTR_CODRB2, "  
				cQuery  += "        DTR.DTR_CODRB3, "
				cQuery  += "        DA4.DA4_COD,    "
				cQuery  += "        DA4.DA4_NOME    "
				cQuery  += "   FROM "+RetSqlName('DTR')+ " DTR, "
				cQuery  += "        "+RetSqlName('DUP')+ " DUP, "
				cQuery  += "        "+RetSqlName('DA4')+ " DA4 "			           
				cQuery  += "   WHERE DTR.DTR_FILIAL = '" + xFilial('DTR') + "'"
				cQuery  += "     AND DA4.DA4_FILIAL = '" + xFilial('DA4') + "'"	
				cQuery  += "     AND DUP.DUP_FILIAL = '" + xFilial('DUP') + "'"	
				cQuery  += "     AND DTR.DTR_VIAGEM = (SELECT MAX(DTR_VIAGEM) VIAGEM "
				cQuery  += "                             FROM "+RetSqlName('DTR')+ " DTR1" 
				cQuery  += "                            WHERE DTR1.DTR_FILIAL = '" + xFilial('DTR') + "'"
				cQuery  += "                              AND DTR1.DTR_CODVEI = '"+ cCodVei +"'"
				cQuery  += "                              AND DTR1.D_E_L_E_T_ = ' ')"
				cQuery  += "     AND DUP.DUP_VIAGEM = DTR.DTR_VIAGEM "
				cQuery  += "     AND DA4.DA4_COD    = DUP.DUP_CODMOT "
				cQuery  += "     AND DTR.D_E_L_E_T_ = ' '"
				cQuery  += "     AND DUP.D_E_L_E_T_ = ' '"
				cQuery  += "     AND DA4.D_E_L_E_T_ = ' '"
				
				cQuery := ChangeQuery(cQuery)
				
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
	
				If !(cTemp)->( EOF() )
					M->DL9_CODRB1:= (cTemp)->DTR_CODRB1
					M->DL9_MODRB1:= Posicione("DA3",1,xFilial("DA3")+M->DL9_CODRB1,"DA3_DESC")                    
					M->DL9_CODRB2:= (cTemp)->DTR_CODRB2
					M->DL9_MODRB2:= Posicione("DA3",1,xFilial("DA3")+M->DL9_CODRB2,"DA3_DESC")
					M->DL9_CODRB3:= (cTemp)->DTR_CODRB3
					M->DL9_MODRB3:= Posicione("DA3",1,xFilial("DA3")+M->DL9_CODRB3,"DA3_DESC")
					If Posicione("DA4",1,xFilial("DA4")+(cTemp)->DA4_COD,"DA4_BLQMOT") == StrZero(1,Len(DA4->DA4_BLQMOT))
						M->DL9_CODMOT:= ' '
						M->DL9_NOMMOT:= ' '
					Else
						M->DL9_CODMOT:= (cTemp)->DA4_COD
						M->DL9_NOMMOT:= (cTemp)->DA4_NOME
					EndIf
				Else 
					M->DL9_CODMOT:= ''
					M->DL9_NOMMOT:= '' 
					// caso não encontre a viagem, buscar o motorista direto do veículo
					DA3->(DbSetOrder(1))
					If DA3->(DbSeek(xFilial("DA3")+cCodVei))
						DA4->(DbSetOrder(1))
						If DA4->(DbSeek(xFilial("DA4")+DA3->DA3_MOTORI))
							If Posicione("DA4",1,xFilial("DA4")+DA4->DA4_COD,"DA4_BLQMOT") == StrZero(1,Len(DA4->DA4_BLQMOT))
								M->DL9_CODMOT:= ' '
								M->DL9_NOMMOT:= ' '
							Else
								M->DL9_CODMOT:= DA4->DA4_COD
								M->DL9_NOMMOT:= DA4->DA4_NOME
							EndIf  
						endif
           
					EndIf					
									
				EndIf
				
				(cTemp)->(dbCloseArea())
				
			EndIf             
		EndIf
		Pergunte('TMSA153', .F.) //Carrega os mv_par do filtro gestao de demandas
	ElseIf !Empty(cCodVei) .AND. cTipo == '2' //carreta	 
		DA3->(DbSetOrder(1))
		If DA3->(DbSeek(xFilial("DA3")+cCodVei))	
			If DA3->DA3_ATIVO <> '1'
				Help("",1,"TMSA153B8")//Não é possível informar veículos inativos no Planejamento de Demanda.
				lRet := .F.
			Else			
				DUT->(DbSetOrder(1))
				If DUT->(DbSeek(xFilial("DUT")+DA3->DA3_TIPVEI))
					If DUT->DUT_CATVEI <> '3'
						Help("",1,"TMSA153B6")//Veículo informado deve ser da categoria "Carreta"
						lRet:= .F.
					EndIf
				EndIf
			EndIf
		Else
			lRet := .F.
		EndIf  
		
		//Um reboque deve constar em apenas um dos campos destinados aos reboques
		If lRet
			If cCampo == 'DL9_CODRB1'
				If M->DL9_CODRB1 == M->DL9_CODRB2 .Or. M->DL9_CODRB1 == M->DL9_CODRB3
					lRet := .F.
				EndIf
			EndIf
			If cCampo == 'DL9_CODRB2'
				If M->DL9_CODRB2 == M->DL9_CODRB1 .Or. M->DL9_CODRB2 == M->DL9_CODRB3
					lRet := .F.
				EndIf
			EndIf
			If cCampo == 'DL9_CODRB3'
				If M->DL9_CODRB3 == M->DL9_CODRB1 .Or. M->DL9_CODRB3 == M->DL9_CODRB2
					lRet := .F.
				EndIf
			EndIf
			Iif(!lRet, Help("",1,"TMSA153B9"),) //Reboque ja informado para este planejamento.
		EndIf
	ElseIf Empty(cCodVei) //.AND. cTipo == '2' //carreta	 
		If cCampo == 'DL9_CODVEI'
			M->DL9_CODRB1 := ''
			M->DL9_MODRB1 := ''
		EndIf
		If cCampo == 'DL9_CODRB1' .Or. cCampo == 'DL9_CODVEI' 
			M->DL9_CODRB2 := ''
			M->DL9_MODRB2 := ''
		EndIf
		If cCampo == 'DL9_CODRB1' .Or. cCampo == 'DL9_CODRB2' .Or. cCampo == 'DL9_CODVEI'
			M->DL9_CODRB3 := ''
			M->DL9_MODRB3 := ''
		EndIf
	EndIf

	DA4->(RestArea(aArea))
	
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TM153BWHEN
When dos campos da tabela DL9
@type function
@author Ruan Ricardo Salvador
@version 12.1.17
@since 21/05/2018
/*/
//-------------------------------------------------------------------------------------------------
Function TM153BWHEN(cCampo)
	Local lRet := .F.
	
	If cCampo == 'DL9_CODRB1' .And. !Empty(M->DL9_CODVEI)
		DA3->(DbSetOrder(1))
		If DA3->(DbSeek(xFilial("DA3")+M->DL9_CODVEI))       
			DUT->(DbSetOrder(1))
			If DUT->(DbSeek(xFilial("DUT")+DA3->DA3_TIPVEI))
				If DUT->DUT_CATVEI == '2'           	
					lRet:= .T.
				EndIf
			EndIf
		EndIf
	EndIf 
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} LoadGrid()
Carrega as informações da demanda
@author Ruan Ricardo Salvador
@since 13/04/2018
@version 12.1.17
@return .T.
/*/
//----------------------------------------------------------------------
Static Function LoadGrid(oModel)
	Local oModelDL9 := oModel:GetModel('MASTER_DL9')
	Local oModelDMD := oModelDL9:GetModel('GRID_DEMAN')
	Local oModelOri := oModelDL9:GetModel('GRID_ORI')
	Local oModelDes := oModelDL9:GetModel('GRID_DES')
	
	Local aAreaDL8 := DL8->(GetArea())
	Local aAreaDL := Nil
	
	Local lMVTMSDCOL := SuperGetMv("MV_TMSDCOL",.F.,.T.)
	local lRet := .T.
	
	Local nIndex	:= DL8->(IndexOrd())
	Local nGRid := 0
	Local nI := 1
	Local nX 
		
	If !Empty(oModelDMD:GetValue('DL8_COD')) .And. !Empty(oModelDMD:GetValue('DL8_SEQ')) 		
		DL8->(DbClearFilter())
		DL8->(DbCloseArea())   
		DL8->(DbSetOrder(1))    
		If DL8->( dbSeek(xFilial('DL8')+oModelDMD:GetValue('DL8_COD')+oModelDMD:GetValue('DL8_SEQ')))
			
			For nx := 1 to oModelDMD:GetQtdLine()
			
				If !oModelDMD:IsDeleted(nx) .And. nx <> oModelDMD:GetLine()
					if DL8->DL8_UM <> oModelDMD:GetValue("DL8_UM",nx)
						Help( ,, 'HELP',,STR0041 + STR0077, 1, 0 )//"Não é possível existir Demandas com unidades de medida diferentes dentro de um mesmo Planejamento de Demanda. Demanda informada com unidade de medida diferente das já cadastradas no Planejamento de Demanda."
						lRet := .F.
					endif
					
					if !lRet
						exit
					endif
				endif
			next
			
			If !lMVTMSDCOL .And. lRet
				If DL8->DL8_FILEXE != oModelDL9:GetValue("MASTER_DL9","DL9_FILEXE")
					Help( ,, 'Help',, STR0082, 1, 0 ) //Filial de execução da demanda não pode ser diferente da filial de execução do planejamento.
					lRet := .F.
				EndIf
			EndIf
			
			if lRet
				If M->DL9_COD == DL8->DL8_PLNDMD .OR. DL8->DL8_STATUS == '1'
					For nI := 1 To DL8->(FCount()) 
						oModelDMD:LoadValue(DL8->(FieldName(nI)),DL8->(FieldGet(nI)))
					Next
					
					oModelDMD:LoadValue("DL8_NOMDEV",Posicione("SA1",1,xFilial("SA1")+DL8->DL8_CLIDEV+DL8->DL8_LOJDEV,"A1_NOME"))
					oModelDMD:LoadValue("DL8_DESGRD",Posicione("DLC",1,xFilial("DLC")+DL8->DL8_CODGRD,"DLC_DESCRI"))
					oModelDMD:LoadValue("DL8_DESTVE",Posicione("DUT",1,XFILIAL("DUT")+DL8->DL8_TIPVEI,"DUT_DESCRI"))
					oModelDMD:LoadValue("DL8_LEGDMD",TMSCLegDmd('DL8_STATUS', DL8->DL8_STATUS))
				Else
					Help("",1,"TMSA153B3") //Demanda ja esta em planejamento
					lRet := .F.
				EndIf
			endif
			If lRet
				T153StBlRg(oModelDL9, .F.) //Habilita inserção e deleção de linha nos Grids de Região
				//Carrega os grids de regioes
				For nGrid := 1 to 2
				
					If nGrid == 1
						aAreaDL := DLA->(GetArea())
						DLA->(DbSetOrder(1))
						DLA->( dbSeek(xFilial('DLA')+oModelDMD:GetValue('DL8_COD')+oModelDMD:GetValue('DL8_SEQ')))
					
						oModelGrid := oModelDL9:GetModel('GRID_ORI')
						
						ClearGrid(oModelDL9, 'GRID_ORI')
											
						nX := 1
				
						While DLA->(!EOF()) .And. DLA->DLA_CODDMD == oModelDMD:GetValue('DL8_COD') .And. DLA->DLA_SEQDMD == oModelDMD:GetValue('DL8_SEQ')
							IiF(nX != 1, oModelGrid:AddLine(),)
							For nX := 1 To DLA->(FCount()) 
								oModelGrid:LoadValue(DLA->(FieldName(nX)),DLA->(FieldGet(nX)))
							Next
							oModelGrid:LoadValue("DLA_NOMREG",Posicione("DUY",1,xFilial("DUY")+DLA->DLA_CODREG,"DUY_DESCRI"))
							oModelGrid:LoadValue("DLA_NOMCLI",POSICIONE("SA1",1,XFILIAL("SA1")+DLA->DLA_CODCLI+DLA->DLA_LOJA,"A1_NOME"))
							DLA->(DbSkip())
						EndDo
					ElseIf nGrid == 2
						aAreaDL := DLL->(GetArea())
						DLL->(DbSetOrder(1))
						DLL->( dbSeek(xFilial('DLL')+oModelDMD:GetValue('DL8_COD')+oModelDMD:GetValue('DL8_SEQ')))
					
						oModelGrid := oModelDL9:GetModel('GRID_DES')
						
						ClearGrid(oModelDL9, 'GRID_DES')
						
						nX := 1
				
						While DLL->(!EOF()) .And. DLL->DLL_CODDMD == oModelDMD:GetValue('DL8_COD') .And. DLL->DLL_SEQDMD == oModelDMD:GetValue('DL8_SEQ')  
							IiF(nX != 1, oModelGrid:AddLine(),)
							For nX := 1 To DLL->(FCount()) 
								oModelGrid:LoadValue(DLL->(FieldName(nX)),DLL->(FieldGet(nX)))
							Next
							oModelGrid:LoadValue("DLL_NOMREG",Posicione("DUY",1,xFilial("DUY")+DLL->DLL_CODREG,"DUY_DESCRI"))
							DLL->(DbSkip())
						EndDo
					EndIf
					
					oModelGrid:SetLine(1)
					oModelGrid:ALINESCHANGED := {}
					RestArea( aAreaDL )
				Next nGrid
				T153StBlRg(oModelDL9, .T.) //Desabilita inserção e deleção de linha nos Grids de Região
			EndIf
		Else
			If !Empty(oModelDMD:GetValue('DL8_COD')) .And. !Empty(oModelDMD:GetValue('DL8_SEQ')) 
				Help("",1,"TMSA153B4") //Demanda nao encontrada/cadastrada
				lRet := .F.
			EndIf
		EndIf
	Else
		For nI := 1 To DL8->(FCount())
			If !(DL8->(FieldName(nI)) == 'DL8_COD')
				oModelDMD:ClearField(DL8->(FieldName(nI)),,.T.)
			EndIf
		Next
		If !oModelOri:CanDeleteLine() .OR. !oModelDes:CanDeleteLine()
			T153StBlRg(oModelDL9, .F.) //Habilita inserção e deleção de linha nos Grids de Região
		EndIf
		ClearGrid(oModelDL9, 'GRID_ORI')
		ClearGrid(oModelDL9, 'GRID_DES')
		T153StBlRg(oModelDL9, .T.) //Desabilita inserção e deleção de linha nos Grids de Região
	EndIf
		
	If !Empty(oModelDMD:GetValue('DL8_COD')) .And. !Empty(oModelDMD:GetValue('DL8_SEQ')) .And. !lRet
		For nI := 1 To DL8->(FCount()) 
			oModelDMD:ClearField(DL8->(FieldName(nI)),,.T.)
		Next
		If !oModelOri:CanDeleteLine() .OR. !oModelDes:CanDeleteLine()
			T153StBlRg(oModelDL9, .F.) //Habilita inserção e deleção de linha nos Grids de Região
		EndIf
		ClearGrid(oModelDL9, 'GRID_ORI')
		ClearGrid(oModelDL9, 'GRID_DES')
		T153StBlRg(oModelDL9, .T.) //Desabilita inserção e deleção de linha nos Grids de Região
		
	EndIf 
	
	RestArea( aAreaDL8 )
	DL8->(DbSetOrder(nIndex))
	
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} T153PosDem()
Valida se veiculo ou primeiro reboque foi informado
@author Ruan Ricardo Salvador
@since 13/04/2018
@version 12.1.17
@return .T.
/*/
//----------------------------------------------------------------------
Static Function T153PosDem(oModel)    
	Local lRet := .T.
	Local nX
	Local aDmd:= {}  
	Local aVeic:= {M->DL9_CODVEI,M->DL9_CODRB1,M->DL9_CODRB2,M->DL9_CODRB3}
	Local cUm
	Local aRet := {}
	Local aHelp := ""

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
			
		If Empty(M->DL9_CODVEI) 
			Help("",1,"TMSA153B1") ////Deve ser informado obrigatoriamente veículo
			lRet := .F.
		EndIf
		If lRet
			// valida a unidade de medida e também o peso das demandas X o peso da composição de veículos
			For nX := 1 to oModel:GetQTDLine() 
			  	IF !oModel:IsDeleted(nX )
			  		if Empty(cUm)
			  			cUm:= oModel:GetValue( 'DL8_UM',nX )
			  		endif
			  		if oModel:GetValue( 'DL8_UM',nX ) <> cUm
			  			lRet := .F.
			  			exit
			  		endIf
			  		aAdd(aDmd,oModel:GetValue("DL8_QTD",nX))
			  	EndIf 
			Next nX

			If !lRet 
				Help("",1,"TMSA153B7")//Não é permitido vincular ao mesmo planejamento demandas com unidades diferentes entre si.
			EndIf

			If lRet .AND. cUm != '2'			
				aRet:= TmValPesCp(aDmd, aVeic)
				lRet := aRet[1]
				aHelp := aRet[2]
				
				If (lRet .AND. !Empty(aHelp)) 
					MsgInfo(aHelp)
				ElseIf !lRet 
					Help(NIL, NIL,"HELP", NIL, aHelp, 1, 0, NIL, NIL, NIL, NIL, NIL,NIL)
				EndIf
				
			EndIf
		EndIf						
	EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T153UMPLN
Verifica se existe Demandas com Unidade de Medida diferente das selecionadas para adição.
@type function
@author André Luiz Custódio
@version 12.1.17
@since 07/05/2018
/*/
//-------------------------------------------------------------------------------------------------

Static Function T153UMPLN(cUM, cPLNDMD)
	Local lRet := .T.
	Local cTemp:= GetNextAlias()
	Local cQuery  := ""
	
	cQuery  += " SELECT DISTINCT 1"
	cQuery  += "   FROM "+RetSqlName('DL8')+ " DL8 "			           
	cQuery  += " WHERE DL8.DL8_FILIAL = '" + xFilial('DL8') + "'" 
	cQuery  += "  	AND DL8.DL8_PLNDMD   = '"+cPLNDMD+"'" 
    cQuery  += "    AND DL8.DL8_UM <> '"+cUM+"'"
    cQuery  += "    AND DL8.D_E_L_E_T_ = ' '"
    
    cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )	
	
	If !(cTemp)->( EOF() )
		lRet := .F.
	EndIf
	
	(cTemp)->(dbCloseArea())	

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMS153ADD
Adiciona Demandas a um planejamento
@type function
@author Gustavo Henrique Baptista
@version 12.1.17
@since 24/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Function TMS153ADD()
	Local lBlind     := IsBlind()
	Local lRet       := .T.
	Local cTempDL8   := ""
	Local cTMPDL8    := GetNextAlias()
	Local cTMPDL9    := ""
	Local cMarkDem   := IIf (lBlind, 'MK', oBrwDeman:mark())
	Local cMarkPln   := IIf (lBlind, 'MK', oBrwPlan:mark())
	Local cCodPln    := ""
	Local cStatPln   := ""
	Local cQuery   	 := ""
	Local lBlqTipVei := SuperGetMv("MV_PLVDCD",.F.,.F.)  //Impedir planejamento de veículos diferentes do tipo de veículo do Contrato de Demanda?
	Local lMensagem  := .T.
	Local oModelDL8
	Local oModelDL9
	Local nCountPln	 := 0
	Local nCountDmd	 := 0	
	Local nTamCODGRD := TAMSX3("DLF_CODGRD")[1]
	Local nIndex	 := DL8->(IndexOrd())
	Local aAreaDL9 	 := DL9->(GetArea())
	Local aAreaDL8 	 := DL8->(GetArea())
	Local aAreaDA3   := DA3->(GetArea())
	Local aAreaDUT   := DUT->(GetArea())
	Local aAreaDLF   := DLF->(GetArea())
	Local aDados	 := {}   
	Local nX		 := 0
	Local aDmd       := {}
	Local aVeic      := {}
	Local aRet := { .T., ""}
	Local aHelp := ""
	Local lMVTMSDCOL := SuperGetMv("MV_TMSDCOL",.F.,.T.)
	
	//Refresh browse planejamento
	If !lBlind
		nPosDL9 := oBrwPlan:At()
	    nPosDL8 := oBrwDeman:At() 
		nRfDMD := 2
	EndIf

	//verifica se tem ao menos um item marcado na grid de demandas	
	cQuery:= " SELECT COUNT (DL8_MARK) DL8_MARK"
	cQuery+=   " FROM "+RetSqlName('DL8')+ " DL8 "
	cQuery+=  " WHERE DL8.DL8_FILIAL = '" + FWxFilial('DL8') + "'"
	cQuery+=    " AND DL8.DL8_MARK 	 = '" + cMarkDem + "'"  
	cQuery+=    " AND DL8.D_E_L_E_T_ = '' "  
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTMPDL8, .F., .T. )
	If (cTMPDL8)->DL8_MARK == 0
		Help( ,, 'HELP',,STR0061, 1, 0 )//"Selecionar ao menos uma demanda."
		lRet:= .F.
	EndIf
	(cTMPDL8)->(dbCloseArea())

	If lRet
		//verifica se tem ao menos um item marcado na grid de planejamento
		cTMPDL9	:= GetNextAlias()
		cQuery:= " SELECT DL9_MARK, DL9_COD, DL9_STATUS"
		cQuery+=   " FROM "+RetSqlName('DL9')+ " DL9 "
		cQuery+=  " WHERE DL9.DL9_FILIAL = '" + FWxFilial('DL9') + "'"
		cQuery+=    " AND DL9.DL9_MARK 	 = '" + cMarkPln + "'"  
		cQuery+=    " AND DL9.D_E_L_E_T_ = '' "  
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTMPDL9, .F., .T. )

		While (cTMPDL9)->(!EOF()) .AND. cMarkPln == (cTMPDL9)->DL9_MARK .AND. nCountPln < 2
			nCountPln++
			cCodPln	 := (cTMPDL9)->DL9_COD
			cStatPln := (cTMPDL9)->DL9_STATUS
			(cTMPDL9)->(DBSKIP())
		EndDo

		If nCountPln > 1 
			Help( ,, 'HELP',, STR0014, 1, 0 )//"Selecionar apenas um planejamento."
			lRet:= .F.
		ElseIf nCountPln < 1 
			Help( ,, 'HELP',, STR0062, 1, 0 )//"Selecionar ao menos um Planejamento."
			lRet:= .F.
		Else
			If cStatPln <> "1" .And. cStatPln <> "2" // só permite incluir demandas em planejamentos abertos
				Help( ,, 'HELP',, STR0016, 1, 0 )//"Somente é possível adicionar Demanda a um Planejamento com status em aberto ou aberto com demanda."
				lRet:= .F.
			Endif
		EndIf

		(cTMPDL9)->(dbCloseArea())
	EndIf
	
	If lRet
		DL9->(DbSetOrder(2))
		DL9->(dbSeek(xFilial("DL9")+cMarkPln))
		
		aVeic := {DL9->DL9_CODVEI, DL9->DL9_CODRB1, DL9->DL9_CODRB2, DL9->DL9_CODRB3}

		DL8->(DbSetOrder(2))
		DL8->(dbGoTop())
		DL8->(dbSeek(xFilial("DL8")+cMarkDem))
		While DL8->(!EOF()) .AND. cMarkDem == DL8->DL8_MARK .AND. lRet
			If !Empty(DL8->DL8_PLNDMD)
				Help( ,, 'HELP',, STR0017, 1, 0 )//"Não é permitido vincular uma demanda já planejada."
				lRet:= .F.
			Endif

			If lRet
				aAdd(aDados,{DL8->(RECNO()),DL8->DL8_COD ,DL8->DL8_UM})
				If DL8->DL8_UM <> aDados[1][3]	
					Help( ,, 'Help',, STR0041 + STR0078, 1, 0 ) //"Não é possível existir Demandas com unidades de medida diferentes dentro de um mesmo Planejamento de Demanda. Foram selecionadas Demandas com unidades de medida deferentes entre si."                                                                                                                                                                                                                                                                                                                                
					lRet := .F.
					Exit
				EndIf
				If !(T153UMPLN(aDados[1][3],cCodPln))
					Help( ,, 'Help',, STR0041 + STR0042, 1, 0 ) //"Não é possível existir Demandas com unidades de medidas diferente dentro de um mesmo Planejamento de Demanda. Foram selecionadas Demandas com unidades de medida diferente das já cadastradas no Planejamento de Demanda selecionado."                                                                                                                                                                                                                                                                        
					lRet := .F.
				EndIf
			Endif
			
			If !lMVTMSDCOL .And. lRet
				If DL8->DL8_FILEXE != DL9->DL9_FILEXE		                                                                                                                                                                                                                                                                        
					Help( ,, 'Help',, STR0083 + DL8->DL8_COD + STR0084 +  DL8->DL8_SEQ + STR0085, 1, 0 ) //Filial de execução da demanda: XXXXXXXX Seq: XX é diferente da filial de execução do planejamento. 
					lRet := .F.
				EndIf
			EndIf
			
			If DL8->DL8_UM != '2' .And. lRet
				aadd(aDmd, DL8->DL8_QTD)
			EndIf
			
			If !Empty(DL8->DL8_CRTDMD) .AND. lRet
				DA3->(dbSetOrder(1))
				DUT->(dbSetOrder(1))
				DLF->(dbSetOrder(1))
				If DLF->(DBSeek(xFilial('DLF')+DL8->DL8_CRTDMD + Space(nTamCODGRD)))
					If DA3->(DbSeek(xFilial('DA3') + DL9->DL9_CODVEI))
						If DUT->(DbSeek(xFilial('DUT') + DA3->DA3_TIPVEI))
							If DUT->DUT_CATVEI <> '2' .AND. !(DLF->(DbSeek(xFilial('DLF') + DL8->DL8_CRTDMD + Space(nTamCODGRD) + DA3->DA3_TIPVEI ))) 
								If lBlqTipVei
									lRet := .F.
									Help( ,, 'HELP',,STR0048 + DL9->DL9_COD + STR0049 + DL8->DL8_CRTDMD + STR0050 + DL8->DL8_COD + "/" + DL8->DL8_SEQ + STR0051 , 1, 0 ) //O tipo do veículo " + DA3->DA3_COD + " não está cadastrado no contrato de demanda " + aValTipVei[nX] + ". Não foi possível salvar o planejamento. (MV_PLVDCD)
							 	Else
							 		MsgInfo(STR0048 + DL9->DL9_COD + STR0049 + DL8->DL8_CRTDMD +".") //Tipo de veículo utilizado no Planejamento de Demanda xxxxxxxx não está previsto no Contrato de Demanda xxxxxxx
							 		lMensagem := .F.
							 	EndIf
							EndIf
						EndIf	
					EndIf
					If lRet .AND. !Empty(DL9->DL9_CODRB1) .AND. DA3->(DbSeek(xFilial('DA3') + DL9->DL9_CODRB1)) 
						If !(DLF->(DbSeek(xFilial('DLF') + DL8->DL8_CRTDMD + Space(nTamCODGRD) + DA3->DA3_TIPVEI )))
							If lBlqTipVei
								lRet := .F.
								Help( ,, 'HELP',,STR0048 + DL9->DL9_COD + STR0049 + DL8->DL8_CRTDMD + STR0050 + DL8->DL8_COD + "/" + DL8->DL8_SEQ + STR0051 , 1, 0 ) //O tipo do veículo " + DA3->DA3_COD + " não está cadastrado no contrato de demanda " + aValTipVei[nX] + ". Não foi possível salvar o planejamento. (MV_PLVDCD)
						 	Else
						 		iIf(lMensagem,MsgInfo(STR0048 + DL9->DL9_COD + STR0049 + DL8->DL8_CRTDMD +"."),) //Tipo de veículo utilizado no Planejamento de Demanda xxxxxxxx não está previsto no Contrato de Demanda xxxxxxx
						 		lMensagem := .F.
						 	EndIf
						EndIf				
						If lRet .AND. !Empty(DL9->DL9_CODRB2) .AND. DA3->(DbSeek(xFilial('DA3') + DL9->DL9_CODRB2)) 
							If !(DLF->(DbSeek(xFilial('DLF') + DL8->DL8_CRTDMD + Space(nTamCODGRD) + DA3->DA3_TIPVEI)))
								If lBlqTipVei
									lRet := .F.
									Help( ,, 'HELP',,STR0048 + DL9->DL9_COD + STR0049 + DL8->DL8_CRTDMD + STR0050 + DL8->DL8_COD + "/" + DL8->DL8_SEQ + STR0051 , 1, 0 ) //O tipo do veículo " + DA3->DA3_COD + " não está cadastrado no contrato de demanda " + aValTipVei[nX] + ". Não foi possível salvar o planejamento. (MV_PLVDCD)
							 	Else
							 		iIf(lMensagem,MsgInfo(STR0048 + DL9->DL9_COD + STR0049 + DL8->DL8_CRTDMD +"."),) //Tipo de veículo utilizado no Planejamento de Demanda xxxxxxxx não está previsto no Contrato de Demanda xxxxxxx
							 		lMensagem := .F.
							 	EndIf
							EndIf				
							If lRet .AND. !Empty(DL9->DL9_CODRB3) .AND. DA3->(DbSeek(xFilial('DA3') + DL9->DL9_CODRB3)) 
								If !(DLF->(DbSeek(xFilial('DLF') + DL8->DL8_CRTDMD + Space(nTamCODGRD) + DA3->DA3_TIPVEI )))
									If lBlqTipVei
										lRet := .F.
										Help( ,, 'HELP',,STR0048 + DL9->DL9_COD + STR0049 + DL8->DL8_CRTDMD + STR0050 + DL8->DL8_COD + "/" + DL8->DL8_SEQ + STR0051 , 1, 0 ) //O tipo do veículo " + DA3->DA3_COD + " não está cadastrado no contrato de demanda " + aValTipVei[nX] + ". Não foi possível salvar o planejamento. (MV_PLVDCD)
									Else
										iIf(lMensagem,MsgInfo(STR0048 + DL9->DL9_COD + STR0049 + DL8->DL8_CRTDMD +"."),) //Tipo de veículo utilizado no Planejamento de Demanda xxxxxxxx não está previsto no Contrato de Demanda xxxxxxx
									EndIf
								EndIf				
							EndIf
						EndIf
					EndIf
				EndIf
				If Empty(dtos(DL8->DL8_DATPRV)) .And. lRet
					Help( ,, 'HELP',, STR0046 + " " + DL8->DL8_COD + "/" + DL8->DL8_SEQ +" "+ STR0047, 1, 0 )//"A demanda 999999/99 possui contrato, porém, não possui data de previsão informada."
					lRet := .F.
				EndIf
			EndIf
			nCountDmd++			
			DL8->(DBSKIP())
		Enddo

		If lRet
			cTempDL8 := GetNextAlias()
			cQuery:= " SELECT DL8.DL8_QTD, DL8.DL8_UM    "
			cQuery+=   " FROM "+RetSqlName('DL8')+ " DL8 "
			cQuery+=  " WHERE DL8.DL8_FILIAL = '" + FWxFilial('DL8') + "'"
			cQuery+=    " AND DL8.DL8_PLNDMD = '" + DL9->DL9_COD + "'"  
			cQuery+=    " AND DL8.DL8_UM 	 = '1' "  
			cQuery+=    " AND DL8.D_E_L_E_T_ = ' ' "  
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTempDL8, .F., .T. )
		
			While (cTempDL8)->(!EOF()) 
				aadd(aDmd,(cTempDL8)->DL8_QTD)
				(cTempDL8)->(DbSkip())
			EndDo
			(cTempDL8)->(DbCloseArea())
		EndIf

		If lRet .AND. !Empty(aDmd)
			aRet := TmValPesCp(aDmd, aVeic)
			lRet := aRet[1]
			aHelp := aRet[2] 
			
			If (!Empty( aHelp ))
				Help(NIL, NIL,"HELP", NIL, aHelp, 1, 0, NIL, NIL, NIL, NIL, NIL,NIL)
			EndIf
		EndIf

	EndIf
	
	If lRet .And. (IIf (lBlind, .T., MSGYESNO(STR0012,STR0013)))//"Deseja adicionar demandas ao planejamento selecionado?" "Confirmacao"	
		BEGIN TRANSACTION				
			If lRet
				For nX:= 1 to Len(aDados)
				
					DL8->(dbGoTo(aDados[nX][1]))
							
					oModelDL8 := FWLoadModel('TMSA153A')
					oModelDL8:GetModel('MASTER_DL8'):GetStruct():SetProperty("DL8_PLNDMD", MODEL_FIELD_WHEN,{||.T.})
					oModelDL8:SetOperation(MODEL_OPERATION_UPDATE)
					oModelDL8:Activate()
		
					oModelDL8:SetValue("MASTER_DL8","DL8_PLNDMD",DL9->DL9_COD)
					oModelDL8:SetValue("MASTER_DL8","DL8_MARK",'')
					oModelDL8:SetValue("MASTER_DL8",'DL8_STATUS','2')
		
					If oModelDL8:VldData()     
						IF oModelDL8:CommitData()
							TmIncTrk('2', DL8->DL8_FILIAL, DL8->DL8_COD, DL8->DL8_SEQ, DL9->DL9_COD,'P',/*cCodMotOpe*/,/*cObs*/)
							TMUnLockDmd("TMSA153A_" + DL8->DL8_FILIAL + DL8->DL8_COD + DL8->DL8_SEQ,.T.)
							If !Empty(DL8->DL8_CRTDMD)
								TMUpQtMDmd(DL8->DL8_FILIAL, DL8->DL8_CRTDMD, DL8->DL8_CODGRD, DL8->DL8_TIPVEI, DL8->DL8_SEQMET, DL8->DL8_QTD, 3)
							Endif
						Else
							Help(NIL, NIL,"HELP", NIL, oModelDL8:GetErrorMessage()[6] , 1, 0, NIL, NIL, NIL, NIL, NIL,NIL)
							lRet := .F.
						EndIf							
					Else
						Help(NIL, NIL,"HELP", NIL, oModelDL8:GetErrorMessage()[6] , 1, 0, NIL, NIL, NIL, NIL, NIL,NIL)
						lRet:= .F.
					Endif
				Next
			EndIf
	
			If lRet
				DL9->(DbSetOrder(2)) //reposiciona na DL9 para alterar o status
				If DL9->(dbSeek(xFilial("DL9")+cMarkPln))
					oModelDL9 := FWLoadModel('TMSA153B')
					oModelDL9:SetOperation(MODEL_OPERATION_UPDATE)
					oModelDL9:Activate()
	
					oModelDL9:SetValue("MASTER_DL9","DL9_STATUS",'2')
					oModelDL9:SetValue("MASTER_DL9","DL9_MARK",'')
	
					If oModelDL9:VldData()        
						If !oModelDL9:CommitData()
							Help(NIL, NIL,"HELP", NIL, oModelDL9:GetErrorMessage()[6] , 1, 0, NIL, NIL, NIL, NIL, NIL,NIL)
							lRet := .F.
						EndIf 
					Else
						Help(NIL, NIL,"HELP", NIL, oModelDL9:GetErrorMessage()[6] , 1, 0, NIL, NIL, NIL, NIL, NIL,NIL)
						lRet:= .F.
					Endif
				Endif
			Endif
			
			If !lRet	
				DisarmTransaction()
				Break
			Else
				MsgInfo(STR0019)//"Demandas vinculadas com sucesso."
				If !lBlind
					oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
					oBrwDeman:GoTop()
					DL9->(DbSetOrder(1))
					oBrwPlan:SetFilterDefault(TMA153Filt("DL9"))
					oBrwPlan:GoTo(nPosDL9)
				EndIf
			Endif
		END TRANSACTION
	Else
		lRet := .F.
	Endif

	RestArea(aAreaDA3)
	RestArea(aAreaDUT)
	RestArea(aAreaDLF)
	
	If !lBlind
		If !lRet
			DL8->(DbSetOrder(nIndex))
			DL9->(DbSetOrder(1))
			oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
			If !Empty(DL8->DL8_COD)
				oBrwDeman:GoTo(nPosDL8)
				If Empty(DL8->DL8_COD)
					oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
				EndIf
			EndIF
			oBrwDeman:Refresh()
			
			oBrwPlan:SetFilterDefault(TMA153Filt("DL9"))
			If !Empty(DL9->DL9_COD)
				oBrwPlan:GoTo(nPosDL9)
				If Empty(DL9->DL9_COD)
				 	DL9->(DbSetOrder(1))
					oBrwPlan:SetFilterDefault(TMA153Filt("DL9"))
				EndIf
			EndIf
			oBrwPlan:Refresh()
		Else
			DL8->(DbSetOrder(nIndex))
			oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
			
			DL9->(DbSetOrder(1))
			oBrwPlan:SetFilterDefault(TMA153Filt("DL9"))		
		EndIf
	EndIf
	
	FwFreeObj(aAreaDL8)
	FwFreeObj(aAreaDL9)
	FwFreeObj(aDados)
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} T153BNovo()
Cria um planejamento novo a partir das demandas selecionadas
@author Ruan Ricardo Salvador
@since 13/04/2018
@version 12.1.17
@return .T.
/*/
//----------------------------------------------------------------------
Function T153BNovo()
	Local oMarkDMD := oBrwDeman:mark()
	Local aDemandas := {}
	Local aAreaDL8 	 := DL8->(GetArea())
	Local oModelDL8 
	Local oModelDMD
	Local nX
	Local nI
	Local lRet := .T.
	Local lMVTMSDCOL := SuperGetMv("MV_TMSDCOL",.F.,.T.)
	
	IncAuto := .T.
	//Refresh browse planejamento
	nRfDMD := 2

	DL8->(DbSetOrder(2))
	If DL8->(dbSeek(xFilial('DL8')+oMarkDMD))
		While DL8->(!Eof()) .And. Empty(DL8->DL8_PLNDMD) .And. DL8->DL8_MARK == oMarkDMD
			aadd(aDemandas, {DL8->DL8_COD, DL8->DL8_SEQ, DL8->DL8_UM})
			If DL8->DL8_UM <> aDemandas[1][3]	
				Help( ,, 'Help',, STR0041 + STR0078, 1, 0 ) //"Não é possível existir Demandas com unidades de medidas diferentes dentro de um único Planejamento de Demanda. Foram selecionadas Demandas com unidades de medidas deferentes entre si."                                                                                                                                                                                                                                                                                                                           
				lRet := .F.
				Exit
			EndIf
			If Empty(dtos(DL8->DL8_DATPRV)) .AND. !Empty(DL8->DL8_CRTDMD)
				Help( ,, 'HELP',, STR0046 + " " + DL8->DL8_COD + "/" + DL8->DL8_SEQ +" "+ STR0047, 1, 0 )//"A demanda 999999/99 possui contrato, porém, não possui data de previsão informada."
				lRet := .F.
				Exit
			EndIf
			
			If !lMVTMSDCOL .And. DL8->DL8_FILEXE != cFilAnt
				Help( ,, 'Help',, STR0086 + DL8->DL8_COD + STR0084 +  DL8->DL8_SEQ + STR0087, 1, 0 ) //Filial de execução da demanda: XXXXXXXX Seq: XX é diferente da filial de execução do planejamento.
				lRet := .F.
				exit
			EndIf
			DL8->(dbSkip())
		EndDo
		If lRet .AND. !Empty(aDemandas)
			oModelDL9 := FWLoadModel('TMSA153B')
			oModelDL9:SetOperation(MODEL_OPERATION_INSERT)
			oModelDL9:Activate()
			oModelDMD := oModelDL9:GetModel('GRID_DEMAN')
				
			For nX := 1 to Len(aDemandas)
				DL8->(DbSetOrder(1))
				If DL8->(dbSeek(xFilial('DL8')+aDemandas[nX][1]+aDemandas[nX][2]))
					If Empty(DL8->DL8_PLNDMD) 
						For nI := 1 To DL8->(FCount())						
							oModelDMD:SetValue(DL8->(FieldName(nI)),DL8->(FieldGet(nI)))
						Next nI
						//Campos virtuais
						oModelDMD:LoadValue("DL8_NOMDEV",Posicione("SA1",1,xFilial("SA1")+DL8->DL8_CLIDEV+DL8->DL8_LOJDEV,"A1_NOME"))
					EndIf
				EndIf
				If nX < Len(aDemandas)
					oModelDMD:AddLine()
				EndIf
			Next nX
			oModelDMD:SetLine(1)
			RestArea(aAreaDL8)	
			FWExecView(STR0001,'TMSA153B',MODEL_OPERATION_INSERT,, { || .T. },{ || .T.  },,,{ || .T. },,,oModelDL9) //Incluir
		EndIf
	Else
		Help( ,, 'HELP',,STR0061, 1, 0 )//"Selecionar ao menos uma Demanda."
		lRet := .F.	
	EndIf
	
	If !lRet
		RestArea(aAreaDL8)	 
	EndIf
	FwFreeObj(aDemandas)
	IncAuto := .F.
	
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} T153RECPL()
Recusa planejamentos
@author Gustavo Henrique Baptista
@since 27/04/2018
@version 12.1.17
@return
/*/
//----------------------------------------------------------------------
Function T153RECPL()

	Local lRet:= .T.
	Local cMarkPln   := ""
	Local aAreaDL9 	 := DL9->(GetArea())
	Local aAreaDL7 	 := DL7->(GetArea())
	Local oModelDL9
	Local oModelDL8
	Local cQuery
	Local cTemp := getNextAlias()
	Local aDados:= {}
	Local nX:= 0
	Local nIndex	:= DL8->(IndexOrd())
	Local lBlind := IsBlind()
	Local lYesNo := .T.

	Default aJustif := {}

	If !lBlind
		cMarkPln := oBrwPlan:mark()
	
	//Refresh browse planejamento

		nPosDL9 := oBrwPlan:At()
			nPosDL8 := oBrwDeman:At() 
		nRfDMD := 2
	Else
		cMarkPln := "kj"
	EndIf
		
	DL9->(DbSetOrder(2))
	If DL9->(dbSeek(xFilial("DL9")+cMarkPln))
		While DL9->(!EOF()) .AND. cMarkPln == DL9->DL9_MARK .AND. lRet	
			If ( DL9->DL9_STATUS <> "1") .And. (DL9->DL9_STATUS  <> "2")
				// MsgInfo(STR0031) //Não permitido alterar, excluir ou recusar Planejamentos de Demandas que já foram executados.						
				Help( ,, 'TMSA153B',, STR0031, 1, 0 ) //Não é permitido alterar, excluir ou recusar Planejamentos de Demandas já executados.
				lRet := .F. 
				exit     
			EndIf
			DL9->(DBSKIP())
		EndDo 	
    Else
    	Help( ,, 'HELP',,STR0062, 1, 0 )//"Selecionar ao menos um Planejamento."
		lRet:= .F.
    EndIf

	If lRet 

		If !lBlind
			lYesNo := MSGYESNO(STR0020,STR0013) //"Deseja recusar os planejamento(s) selecionado(s)?" "Confirmação"
		EndIf

		If lYesNo
			BEGIN TRANSACTION

				DL9->(DbSetOrder(2))
				if DL9->(dbSeek(xFilial("DL9")+cMarkPln))

					If !lBlind
						aJustif:= TMSMotDmd('2') //chamar tela de justificativa
					EndIf
					if Len(aJustif) == 0
						lRet := .F.
					endif
					if lRet
						While DL9->(!EOF()) .AND. cMarkPln == DL9->DL9_MARK .AND. lRet	
		
							cQuery:= " SELECT DL8_COD, DL8_SEQ, DL8_CRTDMD "
							cQuery+= " FROM "+RetSqlName('DL8')+ " DL8 "
							cQuery+= " WHERE DL8.DL8_FILIAL = '" + xFilial('DL8') + "'"
							cQuery+= " AND DL8.DL8_PLNDMD = '"+DL9->DL9_COD+"' "
							cQuery+= " AND DL8.D_E_L_E_T_ = ' ' "
						
							cQuery := ChangeQuery(cQuery)
							
							dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )				
			
							while (ctemp)->(!EOF())
								DL8->(DbClearFilter())
								DL8->(DbCloseArea())   
								DL8->(DbSetOrder(1))  
								if DL8->(dbSeek(xFilial("DL8")+(cTemp)->(DL8_COD+DL8_SEQ)))
				
									oModelDL8 := FWLoadModel('TMSA153A')
									oModelDL8:GetModel('MASTER_DL8'):GetStruct():SetProperty("DL8_PLNDMD", MODEL_FIELD_WHEN,{||.T.})
									oModelDL8:SetOperation(MODEL_OPERATION_UPDATE)
									oModelDL8:Activate()
				
									oModelDL8:SetValue("MASTER_DL8","DL8_PLNDMD",'')
									
									If aJustif[3] == '1'//Recusa Motorista
										oModelDL8:SetValue("MASTER_DL8","DL8_STATUS",'1') 
									Else//Recusa Cliente
										DL7->(DbSetOrder(1))
										If DL7->(dbSeek(xFilial("DL7")+(cTemp)->DL8_CRTDMD)) 
											If DL7->DL7_RECUSA == "2"
												oModelDL8:SetValue("MASTER_DL8","DL8_STATUS",'1')
											Else
												oModelDL8:SetValue("MASTER_DL8","DL8_STATUS",'3')
											EndIf  
										EndIf
									EndIF
									
									TMUnLockDmd("TMSA153A_" + oModelDL8:GetValue('MASTER_DL8','DL8_FILIAL') + oModelDL8:GetValue('MASTER_DL8','DL8_COD') + oModelDL8:GetValue('MASTER_DL8','DL8_SEQ'),.T.)
									
									if oModelDL8:VldData()        
										oModelDL8:CommitData()
										
										TMUpQtMDmd(DL8->DL8_FILIAL, DL8->DL8_CRTDMD, DL8->DL8_CODGRD, DL8->DL8_TIPVEI, DL8->DL8_SEQMET, DL8->DL8_QTD, 4)
										If aJustif[3] == '2'//Recusa Cliente
											TMUpQtMDmd(DL8->DL8_FILIAL, DL8->DL8_CRTDMD, DL8->DL8_CODGRD, DL8->DL8_TIPVEI, DL8->DL8_SEQMET, DL8->DL8_QTD, 10)//Recusa Cliente
											If DL7->DL7_RECUSA == "2"
												TmIncTrk('2', DL8->DL8_FILIAL, DL8->DL8_COD, DL8->DL8_SEQ, DL9->DL9_COD, 'D', aJustif[1], aJustif[2], '1')
											Else	
												TmIncTrk('2', DL8->DL8_FILIAL, DL8->DL8_COD, DL8->DL8_SEQ, DL9->DL9_COD, 'D', aJustif[1], aJustif[2], '1')
												TmIncTrk('2', DL8->DL8_FILIAL, DL8->DL8_COD, DL8->DL8_SEQ,, 'U', aJustif[1], aJustif[2],'1')
											EndIf
										Else
											TmIncTrk('2', DL8->DL8_FILIAL, DL8->DL8_COD, DL8->DL8_SEQ, DL9->DL9_COD, 'D', aJustif[1], aJustif[2], '2')
										EndIF
									else
										lRet:= .F.
									endif						
					
										
								endif
								(ctemp)->(dbSkip())
							enddo
							
							(cTemp)->(DBCLOSEAREA())									
			
							if lRet
								aAdd(aDados,DL9->(RECNO()))
							endif
			
							DL9->(DBSKIP())
						enddo
					endif
					for nX:= 1 to Len(aDados)
						DL9->(DbClearFilter())
						DL9->(DbCloseArea())   
						DL9->(DbSetOrder(1))
					
						DL9->(dbGoTo(aDados[nX]))

						if Len(aJustif) > 0
							If aJustif[3] == '1'//Recusa Motorista
								TmIncTrk('3', DL9->DL9_FILIAL, DL9->DL9_COD,'', , 'U', aJustif[1], aJustif[2],'3')						
							Else//Recusa Cliente
								TmIncTrk('3', DL9->DL9_FILIAL, DL9->DL9_COD,'', , 'U', aJustif[1], aJustif[2],'1')
							EndIF
						endif
						
						oModelDL9 := FWLoadModel('TMSA153B')
						oModelDL9:SetOperation(MODEL_OPERATION_UPDATE)
						oModelDL9:Activate()
		
						oModelDL9:SetValue("MASTER_DL9","DL9_STATUS",'5')
						oModelDL9:SetValue("MASTER_DL9","DL9_MARK",'')
		
						if oModelDL9:VldData()        
							oModelDL9:CommitData()
						else
							lRet:= .F.
						endif				
		
					next
				endif	
			
				if !lRet	
					DisarmTransaction()
					Break
				else
					If !lBlind
						MsgInfo(STR0023) //"Planejamento(s) recusado(s) com sucesso."
						DL8->(DbSetOrder(nIndex))
						oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
						oBrwDeman:GoTo(nPosDL8)
						If Empty(DL8->DL8_COD)
							oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
							oBrwDeman:Refresh()
						EndIF
						DL9->(DbSetOrder(1))
						oBrwPlan:SetFilterDefault(TMA153Filt("DL9"))
						oBrwPlan:GoTop()
						oBrwPlan:Refresh()
					EndIf
				endif
			END TRANSACTION
		EndIf
	Else
		RestArea(aAreaDL9)
		RestArea(aAreaDL7)
	Endif
	
	If !lBlind
		If !lRet
			oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
			oBrwDeman:GoTo(nPosDL8)
			oBrwDeman:Refresh()

			DL9->(DbSetOrder(1))
			oBrwPlan:SetFilterDefault(TMA153Filt("DL9"))	
			oBrwPlan:GoTo(nPosDL9)
		EndIf

		FwFreeObj(aJustif)
		FwFreeObj(aDados)
		DL8->(DbSetOrder(nIndex))
	EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} T153BPreDM()
Função para tratar as operacoes de pré-validacao do grid demandas
@author Ruan Ricardo Salvador
@since 04/05/2018
@version 12.1.17
@return
/*/
//----------------------------------------------------------------------
Function T153BPreDM(oModel, nLine, cAction)
	Local oModelDL9 := oModel:GetModel('MASTER_DL9')
	Local oModelORI := oModelDL9:GetModel('GRID_ORI')
	Local oModelDES := oModelDL9:GetModel('GRID_DES')
	Local oModelDMD := oModelDL9:GetModel('GRID_DEMAN')
	Local aChgLinORI := oModelOri:GetLinesChanged()
	Local aChgLinDES := oModelDES:GetLinesChanged()
	Local nI
	Local nX
	Local lRet := .T.	
	Local lMVTMSDCOL := SuperGetMv("MV_TMSDCOL",.F.,.T.)	
	
	If cAction == 'DELETE'
		T153StBlRg(oModelDL9, .F.) //Habilita inserção e deleção de linha nos Grids de Região
		oModelOri:DelAllLine()
		oModelDes:DelAllLine()
		T153StBlRg(oModelDL9, .T.) //Desabilita inserção e deleção de linha nos Grids de Região
	ElseIf cAction == 'UNDELETE'
		For nx := 1 to oModelDMD:GetQtdLine()	
			If nx <> nLine 
				if !oModelDmd:IsDeleted(nx)
					if oModelDMD:GetValue("DL8_UM",nLine) <> oModelDMD:GetValue("DL8_UM",nx) .AND. !Empty(oModelDMD:GetValue("DL8_UM",nLine))
						Help( ,, 'HELP',,STR0041 + STR0076, 1, 0 )//"Não é possível existir Demandas com unidades de medidas diferente dentro de um mesmo Planejamento de Demanda. Demanda a ser desfeita a exclusão tem unidade de medida diferente das já cadastradas no Planejamento de Demanda." 
						lRet := .F.
					endif
				endif
				if !lRet
					exit
				endif
			endif
		next
		
		If !lMVTMSDCOL .And. lRet
			If oModelDMD:GetValue("DL8_FILEXE",nLine) != oModelDL9:GetValue("MASTER_DL9","DL9_FILEXE") .AND. !Empty(oModelDMD:GetValue("DL8_FILEXE",nLine))
				Help( ,, 'Help',, STR0083 + oModelDMD:GetValue("DL8_COD",nLine) + STR0084 +  oModelDMD:GetValue("DL8_SEQ",nLine) + STR0085, 1, 0 ) //Filial de execução da demanda: XXXXXXXX Seq: XX é diferente da filial de execução do planejamento.		
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			For nI := 1 to oModelORI:GetQTDLine()
				oModelORI:SetLine(nI)
				oModelORI:UnDeleteLine()	
			Next nI
			
			For nI := 1 to oModelDES:GetQTDLine()
				oModelDES:SetLine(nI)
				oModelDES:UnDeleteLine()	
			Next nI
		EndIf
	EndIf
		
	oModelORI:ALINESCHANGED := aChgLinORI
	oModelDES:ALINESCHANGED := aChgLinDES
	oModelORI:SetLine(1)
	oModelDES:SetLine(1)

Return lRet 



/*/{Protheus.doc} T153BOrPre
//Pré validação do model
@author wander.horongoso
@since 22/05/2018
@version 1.0
@return ${return}, ${return_description}
@param oModelGrid, object, model a ser validado
@param nLine, numeric, linha ser validada
@param cAction, characters, ação
@type function
/*/
Function T153BOrPre(oModelGrid, nLine, cAction)
Local lRet   := .T.
Local nOperation := oModelGrid:GetOperation()

	If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE ) 
		If cAction == 'SETVALUE'	
		
			If lRet .And. !Empty(M->DLA_DTPREV) 
				If M->DLA_DTPREV < Date() 
					Help( ,, 'HELP',, STR0036, 1, 0 )  //Data de previsão não pode ser menor que a data atual.			
					lRet := .F.
				ElseIf M->DLA_DTPREV == Date() 
					If !Empty(oModelGrid:GetValue('DLA_HRPREV')) .And. oModelGrid:GetValue('DLA_HRPREV') < (Substr( TIME(),1,2  )+ Substr( TIME(),4,2  ))
						Help( ,, 'HELP',, STR0037, 1, 0 )  //Hora de previsão não pode ser menor que hora atual.
						lRet:= .F.
					EndIf
				EndIf
			EndIf		
			
			If lRet .And. !Empty(M->DLA_HRPREV) 
				lRet := AtVldHora(M->DLA_HRPREV) //valida se o formato da hora está ok
				
				If !lRet
					If Len(Alltrim(M->DLA_HRPREV)) < 4					
						Help( ,, 'HELP',, STR0034, 1, 0 )   //Hora de previsão inválida.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
						lRet := .F.
					EndIf
				Else
					If !Empty(oModelGrid:GetValue('DLA_DTPREV')) .And. oModelGrid:GetValue('DLA_DTPREV') == Date() .And. M->DLA_HRPREV < Substr(Time(),1,2) + Substr(Time(),4,2)
						Help( ,, 'HELP',, STR0037, 1, 0 )  //Hora de previsão não pode ser menor que hora atual.
						lRet:= .F.
					EndIf		
				EndIf			
			EndIf		
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} T153BDsPre
//Pré validação do model
@author wander.horongoso
@since 22/05/2018
@version 1.0
@return ${return}, ${return_description}
@param oModelGrid, object, model a ser validado
@param nLine, numeric, linha ser validada
@param cAction, characters, ação
@type function
/*/
Function T153BDsPre(oModelGrid, nLine, cAction)
Local lRet   := .T.
Local nOperation := oModelGrid:GetOperation()

	If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE ) 
		If cAction == 'SETVALUE'	
		
			If lRet .And. !Empty(M->DLL_DTPREV) 
				If M->DLL_DTPREV < Date() 
					Help( ,, 'HELP',, STR0036, 1, 0 )  //Data de previsão não pode ser menor que a data atual.			
					lRet := .F.
				ElseIf M->DLL_DTPREV == Date() 
					If !Empty(oModelGrid:GetValue('DLL_HRPREV')) .And. oModelGrid:GetValue('DLL_HRPREV') < (Substr( TIME(),1,2  )+ Substr( TIME(),4,2  ))
						Help( ,, 'HELP',, STR0037, 1, 0 )  //Hora de previsão não pode ser menor que hora atual.
						lRet:= .F.
					EndIf
				EndIf
			EndIf		
			
			If lRet .And. !Empty(M->DLL_HRPREV) 
				lRet := AtVldHora(M->DLL_HRPREV) //valida se o formato da hora está ok
				
				If !lRet
					If Len(Alltrim(M->DLL_HRPREV)) < 4					
						Help( ,, 'HELP',, STR0034, 1, 0 )   //Hora de previsão inválida.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
						lRet := .F.
					EndIf
				Else
					If !Empty(oModelGrid:GetValue('DLL_DTPREV')) .And. oModelGrid:GetValue('DLL_DTPREV') == Date() .And. M->DLL_HRPREV < Substr(Time(),1,2) + Substr(Time(),4,2)
						Help( ,, 'HELP',, STR0037, 1, 0 )  //Hora de previsão não pode ser menor que hora atual.
						lRet:= .F.
					EndIf		
				EndIf			
			EndIf		
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------	
/*/{Protheus.doc} T153BRgPos()
Realiza pós validação da linha (Grids origem e Destino)
@author  Gustavo Baptista
@since   13/04/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153BRgPos (oModelGrid, cTipo)
Local lRet       := .T.
Local nOperation := oModelGrid:GetOperation()
		
	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
		If cTipo == '1'
			If !Empty(oModelGrid:GetValue('DLA_HRPREV')) .And. Empty(oModelGrid:GetValue('DLA_DTPREV')) .And. lRet
				lRet := .F.
			EndIf
		Else
			If !Empty(oModelGrid:GetValue('DLL_HRPREV')) .And. Empty(oModelGrid:GetValue('DLL_DTPREV')) .And. lRet
				lRet := .F.
			EndIf
		EndIf
	
		If !lRet
			Help( ,, 'HELP',, STR0035, 1, 0 )  //Informe a data de previsão.
		EndIf
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T153BPREVL
Pré-validação do submodelo. 
O bloco é invocado na deleção de linha, no undelete da linha, na inserção de uma linha e nas tentativas de atribuição de valor.  
@author  Gustavo Krug
@since   25/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153BPREVL( oModel, nLine, cOpera, cCampo, cValAtu, cValAnt)
Local lRet 		:= .T.
Local oModelDL9 := oModel:GetModel('MASTER_DL9')
Local oModelDMD := oModelDL9:GetModel('GRID_DEMAN')
Local nOperation:=  oModel:GetOperation()
Local nIndex	:= DL8->(IndexOrd())
Local cChave    := ""

	If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE )  

		If cOpera == 'SETVALUE' 
			
			//Primeira coisa a ser feita quando um valor vai ser setado é desbloquear o registro anterior 
			if cCampo = 'DL8_COD' //Quando o campo alterado for o código
				if ValType("M->DL8_SEQ") <> "U" .AND. !Empty(oModel:GetValue('DL8_SEQ',nLine)) //verificar se a sequência já foi preenchida
					TMUnLockDmd("TMSA153A_" + oModelDMD:GetValue('DL8_FILIAL') +cValAnt+oModel:GetValue('DL8_SEQ',nLine),.T.)
					cChave := cValAtu+oModel:GetValue('DL8_SEQ',nLine)
					
				endif
			endif

			if cCampo = 'DL8_SEQ' //Quando o campo alterado for o sequência
				if ValType("M->DL8_COD") <> "U" .AND. !Empty(oModel:GetValue('DL8_COD',nLine))//verificar se o código já foi preenchido
					TMUnLockDmd("TMSA153A_" + oModelDMD:GetValue('DL8_FILIAL') +oModel:GetValue('DL8_COD',nLine)+cValAnt,.T.)
					cChave := oModel:GetValue('DL8_COD',nLine)+cValAtu
				endif
			endif

			if cValAtu <> cValAnt .AND. !Empty(cChave) //se alterou algum valor e a chave está completa, faz o lock
				aAreaDL8:= DL8->(GetArea())
				DbSelectArea("DL8")
				DL8->(DbSetOrder(1))    
				If DL8->(DbSeek(xFilial('DL8') + cChave)) .AND. Empty(DL8->DL8_PLNDMD)
					aRet := TMLockDmd("TMSA153A_" + oModelDMD:GetValue('DL8_FILIAL',nLine) + cChave,.T.)
					If !aRet[1]
						Help( ,, 'HELP',, aRet[2], 1, 0 )
						lRet := .F.
					EndIf
				EndIf
				RestArea( aAreaDL8 )
				DL8->(DbSetOrder(nIndex))
			endif

		EndIf		
		
		If lRet .AND. (cOpera == "DELETE") .AND. !IsBlind()		    
			If !Empty(oModelDMD:GetValue('DL8_COD', nline)) .AND. !Empty(oModelDMD:GetValue('DL8_SEQ', nline)) .AND. !(oBrwDeman:Mark() == oModelDMD:GetValue('DL8_MARK', nline))
				TMUnLockDmd("TMSA153A_" + oModelDMD:GetValue('DL8_FILIAL',nline) + oModelDMD:getValue('DL8_COD',nline) + oModelDMD:getValue('DL8_SEQ',nline),.T.)	
			EndIf
		EndIf
			
		If lRet .AND. (cOpera == "UNDELETE") 
			If !Empty(oModelDMD:GetValue('DL8_COD', nline)) .AND. !Empty(oModelDMD:GetValue('DL8_SEQ', nline))
				aRet := TMLockDmd("TMSA153A_" + oModelDMD:GetValue('DL8_FILIAL',nline) + oModelDMD:getValue('DL8_COD',nline) + oModelDMD:getValue('DL8_SEQ',nline),.T.)
				If !aRet[1]
					Help( ,, 'HELP',, aRet[2], 1, 0 )
					lRet := .F.
				EndIf
				If lRet .AND. oModelDMD:GetValue('DL8_STATUS', nline) == "1"
					aAreaDL8:= DL8->(GetArea())
					DbSelectArea("DL8")
					DL8->(DbSetOrder(1))    
					If DL8->(DbSeek(xFilial('DL8') + oModelDMD:GetValue('DL8_COD', nline) + oModelDMD:GetValue('DL8_SEQ', nline))) 
						If !Empty(DL8->DL8_PLNDMD) .OR. !(DL8->DL8_STATUS == '1')
							Help( ,, 'HELP',, STR0053, 1, 0 )  //Esta demanda não está mais disponível para planejamento. 
							lRet := .F.
						EndIf
						If lRet .AND. (!(oModelDMD:GetValue('DL8_DATPRV', nline) == DL8->DL8_DATPRV ) .OR. !(oModelDMD:GetValue('DL8_HORPRV', nline) == DL8->DL8_HORPRV) .OR. !(oModelDMD:GetValue('DL8_QTD', nline) == DL8->DL8_QTD))
							Help( ,, 'HELP',, STR0054, 1, 0 )  //"Esta demanda sofreu alteração, não é possivel desfazer o delete, informe a demanda novamente em outra linha para planejá-la."         
							lRet := .F.						
						EndIf
					Else
						Help( ,, 'HELP',, STR0053, 1, 0 )  //Esta demanda não está mais disponível para planejamento. 
						lRet := .F.
					EndIf
					RestArea( aAreaDL8 )
					DL8->(DbSetOrder(nIndex))
				EndIf
			EndIf
		EndIf		
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldDmdPln()
Valida se demanda informada já foi planejada
@author  Gustavo Krug
@since   28/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function VldDmdPln(oModel)
Local lRet := .T.
Local cQuery  := ""
Local cTemp:= GetNextAlias()
Local oModelAux := FWModelActive()
 
	If !Empty(oModel:GetValue("DL8_COD")) .And. !Empty(oModel:GetValue("DL8_SEQ"))
		cQuery  += " SELECT DL8_PLNDMD "
		cQuery  += "   FROM "+RetSqlName('DL8')+ " DL8 "			           
		cQuery  += " WHERE DL8.DL8_FILIAL = '" + xFilial('DL8') + "'" 
		cQuery  += "  	AND DL8.DL8_COD = '"+oModel:GetValue('DL8_COD')+"'" 
  	cQuery  += "    AND DL8.DL8_SEQ = '"+oModel:GetValue("DL8_SEQ")+"'"
  	cQuery  += "    AND DL8.D_E_L_E_T_ = ' '"
    
  	cQuery := ChangeQuery(cQuery)

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
		
		If !Empty((cTemp)->DL8_PLNDMD)
				oModelAux:SetErrorMessage('TMSA153B',,,,,STR0040,'', nil, nil) //Demanda já está em planejamento.
				lRet:= .F.
		EndIf
		(cTemp)->(dbCloseArea())		
	endif
Return lRet

/*/{Protheus.doc} TMIniDL8
//Ajusta os inicializadores padrões para que não carregue descrições indevidamente
@author gustavo.baptista
@since 28/06/2018
@version 1.0
@return ${return}, ${return_description}
@param cCampo, characters, descricao
@type function
/*/
function TMIniDL8(cCampo)

	Local cRet:= ''
	Local oModel:= FWModelActive()
	Local oModelDl8:=  oModel:GetModel('GRID_DEMAN')

	if cCampo ==  'DL8_NOMDEV'
		cRet:= iIf(!Inclui .AND. !Empty(DL8->DL8_CLIDEV)  ,Posicione("SA1",1,xFilial("SA1")+DL8->DL8_CLIDEV+DL8->DL8_LOJDEV,"A1_NOME"),"")
	elseif cCampo == 'DL8_DESTVE'
		cRet:= iIf(INCLUI,"",POSICIONE("DUT",1,XFILIAL("DUT")+DL8->DL8_TIPVEI,"DUT_DESCRI"))
	elseif cCampo == 'DL8_DESGRD'
		cRet:= iIf(!Inclui .AND. !Empty(DL8->DL8_CLIDEV)  ,Posicione("DLC",1,xFilial("DLC")+DL8->DL8_CODGRD,"DLC_DESCRI"),"")
	endif

	if oModelDl8:GetLine() > 0
		cRet:= ''
	endif

return cRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T153WHENDM
Bloco When dos campos : DL8_COD(Codigo demanda) e DL8_SEQ(Sequencia Demanda). 
@type function
@author Marcelo Radulski Nunes
@version 12.1.17
@since 02/07/2018
/*/
//-------------------------------------------------------------------------------------------------
function T153WHENDM(oModel, nCampo)
Local oModelDL9 := oModel:GetModel('MASTER_DL9')
Local oModelDMD := oModelDL9:GetModel('GRID_DEMAN')
Local lWhen := .T.

	If !(oModel:GetOperation() = MODEL_OPERATION_INSERT)  
		If oModelDMD:IsInserted(oModelDMD:GetLine())
			lWhen := .T.
		Else
			lWhen := .F.
		EndIF
	EndIF	
	//nCampo 1 é o campo DL8_COD
	//nCampo 2 é o campo DL8_SEQ
	If nCampo == 2 .AND. lWhen .AND. Empty(oModelDMD:GetValue('DL8_COD'))
		lWhen := .F.
	EndIf

Return lWhen

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA153COR
Validação para cor do status no grid do planejamento.
@type function
@author Natalia Maria Neves
@version 12.1.17
@since 24/07/2018
/*/
//-------------------------------------------------------------------------------------------------
Function T153BCOR()
Local oModelAux := FWModelActive()
Local cRet := ''

	If ValType(M->DL8_STATUS) ==  'U' .And. oModelAux:GetOperation() != MODEL_OPERATION_INSERT
		cRet := TMSCLegDmd('DL8_STATUS', DL8->DL8_STATUS)
	Else
		cRet := TMSCLegDmd('DL8_STATUS', M->DL8_STATUS)
	EndIf
	
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TMA153VLDT
Faz as validações para os campos data e hora de inicio e fim do planejamento.
@author  natalia.neves
@since   21/09/2018
@version 1.0
@param cCampo - Campo que esta sendo realizado o valid.
@return Retorna verdadeiro ou falso (caso ocorra algum problema).
/*/
//-------------------------------------------------------------------
Function TMA153VLDT(cCampo)

	Local lRet := .T.
	
	If cCampo == "DL9_DATINI" .And. !Empty(M->DL9_DATINI)	
		If M->DL9_DATINI < Date()
			Help(,, "HELP",, STR0066, 1, 0) //Data de início não pode ser anterior à data atual.
			lRet := .F.
		EndIf	
		If lRet .And. !Empty(M->DL9_DATFIM) 
			If M->DL9_DATINI > M->DL9_DATFIM 
				Help(,, "HELP",,STR0064, 1, 0) //Data de início não pode ser posterior à data de fim.
				lRet := .F.
			ElseIf M->DL9_DATINI == M->DL9_DATFIM .And. (!Empty(M->DL9_HORINI) .And. !Empty(M->DL9_HORFIM))
				If M->DL9_HORINI > M->DL9_HORFIM 
					Help(,, "HELP",,STR0065, 1, 0) //Data e hora de início não pode ser posterior à data e hora de fim.
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	
	If cCampo == "DL9_DATFIM" .And. !Empty(M->DL9_DATFIM)
		If M->DL9_DATFIM < Date()
			Help(,, "HELP",, STR0074, 1, 0) //Data de fim não pode ser anterior à data atual.
			lRet := .F.
		EndIf
		If lRet .And. !Empty(M->DL9_DATINI) 
			If  M->DL9_DATINI > M->DL9_DATFIM
				Help(,, "HELP",, STR0075, 1, 0) //Data de fim não pode ser anterior à data de início.
				lRet := .F.
			ElseIf M->DL9_DATINI == M->DL9_DATFIM .And. (!Empty(M->DL9_HORFIM) .And. !Empty(M->DL9_HORINI))
				If M->DL9_HORFIM < M->DL9_HORINI
					Help(,, "HELP",, STR0079, 1, 0) //Data e hora de fim não pode ser anterior à data e hora de início.
					lRet := .F.
				EndIf
			EndIf
		EndIf	
	EndIf
	
	If cCampo == "DL9_HORINI" .And. !Empty(M->DL9_HORINI)
		//Valida hora digitada
		lRet := AtVldHora(M->DL9_HORINI)
		
		If lRet 
			If M->DL9_DATINI == Date()
				If(M->DL9_HORINI < (Substr( TIME(),1,2  )+ Substr( TIME(),4,2  )))
					Help(,, "HELP",, STR0080, 1, 0) //Hora de início não pode ser anterior à hora atual.
					lRet := .F.
				EndIf
			EndIf
			
			If lRet .And. (!Empty(M->DL9_DATINI) .And. !Empty(M->DL9_DATFIM) .And. !Empty(M->DL9_HORFIM))
				If M->DL9_DATINI == M->DL9_DATFIM .And. M->DL9_HORINI > M->DL9_HORFIM 
					Help(,, "HELP",,STR0065, 1, 0) //Data e hora de início não pode ser posterior à data e hora de fim.
					lRet := .F. 
				EndIf
			EndIf
		EndIf
	EndIf
	
	If cCampo == "DL9_HORFIM" .And. !Empty(M->DL9_HORFIM)
		//Valida hora digitada
		lRet := AtVldHora(M->DL9_HORFIM)
		
		If lRet 
			If M->DL9_DATFIM == Date()
				If (M->DL9_HORFIM < (Substr( TIME(),1,2  )+ Substr( TIME(),4,2  )))
					Help(,, "HELP",, STR0081, 1, 0) //Hora de Fim não pode ser anterior à hora atual.
					lRet := .F.
				EndIf
			EndIf
	 
			If lRet .And. (!Empty(M->DL9_DATINI) .And. !Empty(M->DL9_DATFIM) .And. !Empty(M->DL9_HORINI))
				If M->DL9_DATINI == M->DL9_DATFIM .And. M->DL9_HORFIM < M->DL9_HORINI
					Help(,, "HELP",, STR0079, 1, 0) //Data e hora de fim não pode ser anterior à data e hora de início.
					lRet := .F.
				EndIf 
			EndIf 
		EndIf                                                                    
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TMA153VALD
Faz as validações, ao confirmar, do planejamento. 
OBS.: Estas validações serão feitas antes do bloco de commit.
@author  natalia.neves
@since   24/09/2018
@version 1.0
@return Retorna verdadeiro ou falso (caso ocorra algum problema).
/*/
//-------------------------------------------------------------------
Function TMA153VALD(oModel)

	Local lMVTMSDCOL := SuperGetMv("MV_TMSDCOL",.F.,.T.)
	Local lRet := .T.
	Local nX := 0
	Local aVeic := {}
	Local aAreaDA3 := NIL
	Local aAreaDUT := NIL

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		//Validações dos campos de data do planejamento.
		If !Empty(oModel:GetValue('MASTER_DL9','DL9_DATINI')) .And. Empty(oModel:GetValue('MASTER_DL9','DL9_DATFIM'))
			Help(,, "HELP",, STR0067, 1, 0) //Ao informar a Data Inicio é obrigatório informar a Data Fim.
			lRet := .F.
		ElseIf Empty(oModel:GetValue('MASTER_DL9','DL9_DATINI')) .And. !Empty(oModel:GetValue('MASTER_DL9','DL9_DATFIM'))
			Help(,, "HELP",, STR0068, 1, 0) //Ao informar a Data Fim é obrigatório informar a Data Inicio.
			lRet := .F.
		EndIf
		
		//Caso alguma data esteja preenchida, é obrigatório informar um horário.
		If lRet .And. (!Empty(oModel:GetValue('MASTER_DL9','DL9_DATINI')) .OR. !Empty(oModel:GetValue('MASTER_DL9','DL9_DATFIM'))) .And. (Empty(oModel:GetValue('MASTER_DL9','DL9_HORINI')) .OR. Empty(oModel:GetValue('MASTER_DL9','DL9_HORFIM')))
			Help(,, "HELP",, STR0069, 1, 0) //Ao informar a Data Inicio e a Data Fim do planejamento é obrigatório informar o horário.
			lRet := .F.
		EndIf
		
		//Caso o horário esteja preenchido, é obrigatório informar as datas.
		If lRet .And. (Empty(oModel:GetValue('MASTER_DL9','DL9_DATINI')) .Or. Empty(oModel:GetValue('MASTER_DL9','DL9_DATFIM'))) .And. (!Empty(oModel:GetValue('MASTER_DL9','DL9_HORINI')) .OR. !Empty(oModel:GetValue('MASTER_DL9','DL9_HORFIM')))
			Help(,, "HELP",, STR0070, 1, 0) //Ao informar o horário é obrigatório informar a Data Inicio e a Data Fim do planejamento.
			lRet := .F.
		EndIf

		If lRet .And. FWIsInCallStack('BUTTONOKACTION') .AND. oModel:GetValue('MASTER_DL9','DL9_STATUS') $ ' 12' // Status igual a 'Aberto' ou 'Aberto com demanda'
			lRet := TMSVldMotP(oModel:GetValue('MASTER_DL9','DL9_COD'), '',oModel:GetValue('MASTER_DL9','DL9_CODMOT'), { oModel:GetValue('MASTER_DL9','DL9_DATINI'), oModel:GetValue('MASTER_DL9','DL9_HORINI'),oModel:GetValue('MASTER_DL9','DL9_DATFIM'),oModel:GetValue('MASTER_DL9','DL9_HORFIM')})
		EndIf

		If lRet 
			If Empty(oModel:GetValue('MASTER_DL9','DL9_CODVEI'))
				Help( ,, 'Help',,STR0011, 1, 0 ) //Deve ser informado obrigatoriamente veiculo.
				lRet := .F.				
			ElseIf Empty(oModel:GetValue('MASTER_DL9','DL9_CODRB1')) //Valida se a categoria é cavalo, caso sim, é obrigatório informar o Reboque.
				
				aAreaDA3 := DA3->(GetArea())
				aAreaDUT := DUT->(GetArea())

				DA3->(dbSetOrder(1))
				DUT->(dbSetOrder(1))

				If DA3->(DbSeek(xFilial('DA3') + oModel:GetValue('MASTER_DL9','DL9_CODVEI')))
					If DUT->(DbSeek(xFilial('DUT') + DA3->DA3_TIPVEI))
						If DUT->DUT_CATVEI == '2'
							Help( ,, 'Help',,STR0091, 1, 0 )//Para veículos do tipo cavalo é obrigatório informar o 1º reboque.
							lRet := .F.
						EndIf
					EndIf
				Endif
				RestArea(aAreaDUT)
				RestArea(aAreaDA3)
			Endif
		EndIf

		If lRet 
			If FWIsInCallStack('BUTTONOKACTION') .AND. oModel:GetValue('MASTER_DL9','DL9_STATUS') $ ' 12' // Status igual a 'Aberto' ou 'Aberto com demanda'
				aAdd(aVeic, oModel:GetValue('MASTER_DL9','DL9_CODVEI'))
				aAdd(aVeic, oModel:GetValue('MASTER_DL9','DL9_CODRB1'))
				aAdd(aVeic, oModel:GetValue('MASTER_DL9','DL9_CODRB2'))
				aAdd(aVeic, oModel:GetValue('MASTER_DL9','DL9_CODRB3'))
			
				lRet := TMSVldVei( oModel:GetValue('MASTER_DL9','DL9_COD'),,, oModel:GetValue('MASTER_DL9','DL9_DATINI'),oModel:GetValue('MASTER_DL9','DL9_HORINI'), oModel:GetValue('MASTER_DL9','DL9_DATFIM'), oModel:GetValue('MASTER_DL9','DL9_HORFIM'),aVeic )
			EndIf
		EndIf
	EndIf
	
	If !lMVTMSDCOL .And. lRet
		oModel:GetModel("GRID_DEMAN"):GoLine(1)
		For nX := 1 to oModel:GetModel("GRID_DEMAN"):GetQtdLine()
			If !oModel:GetModel("GRID_DEMAN"):IsDeleted(nX) .And. oModel:GetValue("GRID_DEMAN", "DL8_FILEXE", nX) != oModel:GetValue('MASTER_DL9','DL9_FILEXE') .And. !Empty(oModel:GetValue("GRID_DEMAN", "DL8_FILEXE", nX)) 
				Help( ,, 'Help',, STR0083 + oModel:GetValue("GRID_DEMAN", "DL8_COD", nX) + STR0084 +  oModel:GetValue("GRID_DEMAN", "DL8_SEQ", nX) + STR0085, 1, 0 ) //Filial de execução da demanda: XXXXXXXX Seq: XX é diferente da filial de execução do planejamento.
				lRet := .F.
			EndIf
		Next nX
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TM153BVMOT
Faz as validações do campo Cod. Motorista. 
@author  natalia.neves
@since   20/11/2018
@version 1.0
@return lRet (.T. ou .F.).
/*/
//-------------------------------------------------------------------
Function TM153BVMOT()

	Local lRet := Vazio() .OR. ExistCpo("DA4")
	Local aArea :=  DA4->(GetArea())
	Local cMot := FwFldGet('DL9_CODMOT')

	If lRet .And. Posicione("DA4",1,xFilial("DA4")+cMot,"DA4_BLQMOT") ==  StrZero(1,Len(DA4->DA4_BLQMOT))
		Help( ,, 'Help',, STR0088, 1, 0 ) //Não é possível informar motoristas bloqueados no Planejamento de Demandas.
		lRet := .F.
	Endif

	DA4->(RestArea(aArea))
	
Return lRet

Function TMS153BBrw(cCampo)
Local cQuery := ''
Local cTemp:= GetNextAlias()
Local cDescr := ''

	If cCampo == 'DL9_MODVEI'
	    if !Empty(DL9->DL9_CODVEI)
				cQuery  := " SELECT DA3_DESC "
				cQuery  += "   FROM "+RetSqlName('DA3')+ " DA3 "
				cQuery  += " WHERE DA3.DA3_FILIAL = '" + xFilial('DA3') + "'" 
				cQuery  += "  	AND DA3.DA3_COD = '"+DL9->DL9_CODVEI+"'" 
	  		cQuery  += "    AND DA3.D_E_L_E_T_ = ' '"

				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
		
				cDescr := (cTemp)->DA3_DESC
				(cTemp)->(DbCloseArea())
		EndIf
	ElseIf cCampo == 'DL9_NOMMOT'
		 if !Empty(DL9->DL9_CODMOT)
				cQuery  := " SELECT DA4_NOME "
				cQuery  += "   FROM "+RetSqlName('DA4')+ " DA4 "
				cQuery  += " WHERE DA4.DA4_FILIAL = '" + xFilial('DA4') + "'" 
				cQuery  += "  	AND DA4.DA4_COD = '"+DL9->DL9_CODMOT+"'" 				
	 			cQuery  += "    AND DA4.D_E_L_E_T_ = ' '"

				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
		
				cDescr := (cTemp)->DA4_NOME
				(cTemp)->(DbCloseArea())
		EndIf		
	EndIf

Return cDescr 
