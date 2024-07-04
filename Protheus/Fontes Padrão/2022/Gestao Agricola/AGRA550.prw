#INCLUDE 'TOTVS.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGRA550.CH"
 
Static __cTipo //Tipo de Operacao N92
Static __aAutorPesos := {} //Guarda os pesos das autorizacoes au abrir a tela
//Static __mvRastro 	 := SuperGetMv('MV_RASTRO', , .F.) == 'S'
//Todo o controle por lote foi colocado em comentário, pois não será validado o lote a partir do local da IE

/*/{Protheus.doc} AGRA550
//Agendamento AGRO
@author carlos.augusto
@since 27/02/2018
@version 12.1.21
@type function
/*/
Function AGRA550()
	Local oMBrowse := Nil
	Local bKeyF12 := { || Pergunte('AGRA550001', .T.) }

	Private _lVincFard  := .F.
	Private _cTpOpRe	:= ""
	Private _lAltIE		:= .F. //indica se houve alteração/inclusão na IE
	
	//-- Proteção de Código
	If .Not. TableInDic('N9E') 
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	Pergunte( "AGRA550001", .F. )
	
	//---------------
	//Seta tecla F12
	//---------------
	SetKey( VK_F12, bKeyF12 )

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NJJ" )
	oMBrowse:SetDescription( STR0001 )	//Agendamento AGRO
	oMBrowse:SetFilterDefault( "NJJ_STATUS = '6'" )
	oMBrowse:DisableDetails()
	oMBrowse:SetMenuDef('AGRA550')
	oMBrowse:Activate()

	//-------------------------------
	//Retira ação da tecla F12
	//-------------------------------
	SetKey(VK_F12,Nil)
Return()



/*/{Protheus.doc} MenuDef
//MenuDef
@author carlos.augusto
@since 07/03/2018
@version 12.1.21

@type function
/*/
Static Function MenuDef()
	Local aRotina 	:= {}

	aAdd( aRotina, { STR0003 	, "PesqBrw"        	, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0004	, "ViewDef.AGRA550"	, 0, 2, 0, .T. } ) //"Visualizar"
	aAdd( aRotina, { STR0005	, "ViewDef.AGRA550"	, 0, 3, 0, .T. } ) //"Incluir"
	aAdd( aRotina, { STR0006	, "ViewDef.AGRA550"	, 0, 4, 0, .T. } ) //"Alterar"
	aAdd( aRotina, { STR0007	, "ViewDef.AGRA550"	, 0, 5, 0, .T. } ) //"Excluir"
	aAdd( aRotina, { STR0065	, "A550AtuSt(NJJ->NJJ_CODROM, .T.)"	, 0, 6, 0, .T. } ) //"Atualizar Status"

Return( aRotina )


/*/{Protheus.doc} ModelDef
//ModelDef
@author carlos.augusto
@since 07/03/2018
@version 12.1.21
@type function
/*/
Static Function ModelDef()
	Local oStruNJJ 		:= FWFormStruct( 1, "NJJ" )
	Local oStruN9E 		:= FWFormStruct( 1, "N9E" )
	Local oStruN8Q 		:= FWFormStruct( 1, "N8Q" )
	Local oStruN9D 		:= FWFormStruct( 1, "N9D" )
	Local oStruNJM 		:= FWFormStruct( 1, "NJM" )
	Local oStruDX0  	:= FWFormStruct( 1, "DX0" )
	Local oStruNJK  	:= FWFormStruct( 1, "NJK" )
	
	Local oModel 		:= MPFormModel():New( "AGRA550", {|oModel| PreModelo(oModel)}, {|oModel| PosModelo(oModel)}, {|oModel| GrvModelo(oModel)}, /*<bCancel >*/ )
	
	Local bIEVld		:= 'AGRA550VIE()'
	Local bProdVld		:= 'AGRA550VPD()'
	Local bGatVld		:= 'AGRA550GAT()'
	Local bAutVld		:= 'AGRA550VAU()'
	Local bLotVld		:= 'AGRA550VLT()'
	Local bSubVld		:= 'AGRA550VSB()'
	Local bCodPro   	:= 'MV_PAR01'
	Local bDesPro		:= 'AGRA550INP("NJJ_DESPRO")'
	Local bUMPro		:= 'AGRA550INP("NJJ_UM1PRO")'
	Local bLinePre 		:= { |oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| AGRX550APRE( oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue ) }
	Local bGatTbl		:= 'AGRA550GTB()'
	Local bTpOpVld      := 'AGRA550VTO()'
	
	oStruNJJ:AddField(/*cTitulo*/STR0044,/*"Conf. Op GFE"*/;
	/*cTooltip*/ STR0045,/*"Config Operação GFE"*/;
	/*cIdField*/'NJJ_CDOPER',;
	/*cTipo*/'C',;
	/*nTamanho*/16,;
	/*nDecimal*/0,;
	/*bValid*/ ,;
	/*bWhen*/{||.F.},;
	/*aValues*/,;
	/*lObrigat*/ .T.,;
	/*bInit*/ {||Posicione("N92",1,fwxFilial("N92")+MV_PAR03,"N92_CDOPER")},;
	/*lKey*/,;
	/*lNoUpd */,;
	/*lVirtual */ .T.)
	
	oStruNJJ:AddField(/*cTitulo*/STR0046,/*"Desc. Op GFE"*/;
	/*cTooltip*/ STR0047,/*"Desc Config Operação GFE"*/;
	/*cIdField*/'NJJ_DSOPER',;
	/*cTipo*/'C',;
	/*nTamanho*/50,;
	/*nDecimal*/0,;
	/*bValid*/ ,;
	/*bWhen*/{||.F.},;
	/*aValues*/,;
	/*lObrigat*/ .F.,;
	/*bInit*/ {||Posicione("GVC",1,fwxFilial("GVC")+FwFldGet("NJJ_CDOPER"),"GVC_DSOPER")},;
	/*lKey*/,;
	/*lNoUpd */,;
	/*lVirtual */ .T.)
	
	oStruNJJ:AddField(/*cTitulo*/STR0048,/*"Seq. Config Operação GFE"*/;
	/*cTooltip*/ STR0049,/*"Seq Conf OP "*/;
	/*cIdField*/'NJJ_SEQOP',;
	/*cTipo*/'C',;
	/*nTamanho*/3,;
	/*nDecimal*/0,;
	/*bValid*/ ,;
	/*bWhen*/{||.F.},;
	/*aValues*/,;
	/*lObrigat*/ .F.,;
	/*bInit*/ {||Posicione("N92",1,fwxFilial("N92")+MV_PAR03,"N92_SEQOP")},;
	/*lKey*/,;
	/*lNoUpd */,;
	/*lVirtual */ .T.)	
	
	//-------------------------
	// Remove obrigatoriedades-
	//-------------------------
	oStruNJJ:SetProperty( "*", MODEL_FIELD_OBRIGAT , .F.  )

	//---------------------------------------
	// Adiciona obrigatoriedades especificas-
	//---------------------------------------	
	oStruNJJ:SetProperty( "NJJ_CODROM", MODEL_FIELD_OBRIGAT, .T.)
	oStruNJJ:SetProperty( "NJJ_TIPO"  , MODEL_FIELD_OBRIGAT, .T.)
	oStruNJJ:SetProperty( "NJJ_CODTRA", MODEL_FIELD_OBRIGAT, .T.)
	oStruNJJ:SetProperty( "NJJ_DTAGEN", MODEL_FIELD_OBRIGAT, .T.)
	oStruNJJ:SetProperty( "NJJ_HRAGEN", MODEL_FIELD_OBRIGAT, .T.)
	
	oStruNJJ:SetProperty( 'NJJ_NRAGEN' , MODEL_FIELD_WHEN  	, {||.F.})
	oStruNJJ:SetProperty( 'NJJ_UM1PRO' , MODEL_FIELD_WHEN   , {||.F.})
	oStruNJJ:SetProperty( "NJJ_TIPENT" , MODEL_FIELD_INIT   , { | | "0" } ) // 0=Físico
	oStruNJJ:SetProperty( 'NJJ_CODPRO' , MODEL_FIELD_INIT	, FwBuildFeature( STRUCT_FEATURE_INIPAD, bCodPro))
	oStruNJJ:SetProperty( 'NJJ_DESPRO' , MODEL_FIELD_INIT	, FwBuildFeature( STRUCT_FEATURE_INIPAD, bDesPro))
	oStruNJJ:SetProperty( 'NJJ_UM1PRO' , MODEL_FIELD_INIT	, FwBuildFeature( STRUCT_FEATURE_INIPAD, bUMPro))
	oStruNJJ:SetProperty( 'NJJ_TABELA' , MODEL_FIELD_INIT	, FwBuildFeature( STRUCT_FEATURE_INIPAD, IIF( EMPTY(MV_PAR01),,bGatTbl) ))
	
	oStruNJJ:AddTrigger( "NJJ_CODPRO","NJJ_TABELA"  ,{|| .T. }, {|| AGRA550GTB() })
	oStruNJJ:AddTrigger( "NJJ_CODPRO","NJJ_DESPRO"  ,{|| .T. }, {|| AGRA550PRD("NJJ_DESPRO") })
	oStruNJJ:AddTrigger( "NJJ_CODPRO","NJJ_UM1PRO"  ,{|| .T. }, {|| AGRA550PRD("NJJ_UM1PRO") })
	
	//-------------------------------
	// Formulario do Agendamento AGRO
	//-------------------------------
	oModel:AddFields( 'AGRA550_NJJ', Nil, oStruNJJ,/*<bPre >*/,/*< bPost >*/,/*< bLoad >*/)	

	//--------------------------------------
	// Grid de Autorizacoes de Carregamento-
	//--------------------------------------
	oModel:AddGrid(  "AGRA550_N9E", "AGRA550_NJJ", oStruN9E, bLinePre/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bLinePost*/,/*bLoad*/)
	oModel:GetModel( "AGRA550_N9E" ):SetOptional( .t. )
	
	//------------------
	// Alteracao da NJJ-
	//------------------	
	oStruNJJ:SetProperty( 'NJJ_CODPRO' , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bProdVld))
	oStruNJJ:SetProperty( 'NJJ_UM1PRO' , MODEL_FIELD_VALID ,  {|| .T.})
	oStruNJJ:SetProperty( 'NJJ_TOETAP' , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bTpOpVld))
	oStruNJJ:SetProperty( 'NJJ_TIPO' ,   MODEL_FIELD_WHEN  	, {|| .F.})
	oStruNJJ:SetProperty( 'NJJ_PLACA' ,  MODEL_FIELD_WHEN 	, {|| AGRA550PLC()})
	
	//-------------------------------------
	// Inicializacao do Tipo na N9E
	//-------------------------------------
	oStruN9E:SetProperty( 'N9E_ORIGEM', MODEL_FIELD_INIT  	, FwBuildFeature( STRUCT_FEATURE_INIPAD, "'3'"))
	
	//-------------------------------------
	// Inicializacao do Tipo na N9E
	//-------------------------------------	
	oStruNJJ:SetProperty( 'NJJ_STATUS', MODEL_FIELD_INIT  	, FwBuildFeature( STRUCT_FEATURE_INIPAD, "'6'"))
	oStruN9E:SetProperty( 'N9E_DESORG', MODEL_FIELD_INIT  	, FwBuildFeature( STRUCT_FEATURE_INIPAD, "''"))
	
	
	//-------------------------------------------------------
	// Valids no fonte para nao influenciar outros programas-
	//-------------------------------------------------------
	oStruN9E:SetProperty( 'N9E_CODINE' , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bIEVld))
	oStruN9E:SetProperty( 'N9E_CODAUT' , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bAutVld))
	oStruN9E:SetProperty( 'N9E_FILIE'  , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bGatVld))
	oStruN9E:SetProperty( 'N9E_ITEMAC' , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bGatVld))
	oStruN9E:SetProperty( 'N9E_CODCTR' , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bGatVld))
	oStruN9E:SetProperty( 'N9E_ITEM'   , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bGatVld))
	oStruN9E:SetProperty( 'N9E_SEQPRI' , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bGatVld))
	oStruN9E:SetProperty( 'N9E_LOTE'   , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bLotVld))
	oStruN9E:SetProperty( 'N9E_NMLOT'  , MODEL_FIELD_VALID 	, FwBuildFeature( STRUCT_FEATURE_VALID, bSubVld))
	
	//-------------------------------------------------------
	// Trigger para Autorizacao que limpa campos dependentes-
	//-------------------------------------------------------	
	oStruN9E:AddTrigger( "N9E_CODAUT","N9E_CODINE" ,{|| .T. }, {|| Space(TamSX3("N9E_CODINE")[1])})
	oStruN9E:AddTrigger( "N9E_CODAUT","N9E_ITEMAC" ,{|| .T. }, {|| Space(TamSX3("N9E_ITEMAC")[1])})
	oStruN9E:AddTrigger( "N9E_CODAUT","N9E_DESINE" ,{|| .T. }, {|| Space(TamSX3("N9E_DESINE")[1])})
	oStruN9E:AddTrigger( "N9E_CODAUT","N9E_FILIE"  ,{|| .T. }, {|| Space(TamSX3("N9E_FILIE")[1])})
	oStruN9E:AddTrigger( "N9E_CODAUT","N9E_CODCTR" ,{|| .T. }, {|| Space(TamSX3("N9E_CODCTR")[1])})
	oStruN9E:AddTrigger( "N9E_CODAUT","N9E_ITEM"   ,{|| .T. }, {|| Space(TamSX3("N9E_ITEM")[1])})
	oStruN9E:AddTrigger( "N9E_CODAUT","N9E_SEQPRI" ,{|| .T. }, {|| Space(TamSX3("N9E_SEQPRI")[1])})
	
	//---------------------------------------------------------------
	// Trigger que preenche os campos da N8O para a IE selecionada---
	//---------------------------------------------------------------
	oStruN9E:AddTrigger( "N9E_CODINE","N9E_FILIE" , {|| .T. }, {|| IIF(.Not. Empty(FwFldGet("N9E_CODINE")),FwXFilial("N7Q"),Space(TamSX3("N9E_FILIE")[1]))})
	oStruN9E:AddTrigger( "N9E_CODINE","N9E_ITEMAC", {|| .T. }, {|| IIF(.Not. Empty(FwFldGet("N9E_CODINE")),N8O->N8O_ITEM,Space(TamSX3("N9E_ITEMAC")[1]) )  } )
	oStruN9E:AddTrigger( "N9E_CODINE","N9E_CODCTR", {|| .T. }, {|| IIF(.Not. Empty(FwFldGet("N9E_CODINE")),POSICIONE("N8O",1,FwXfilial("N8O") + FwFldGet("N9E_CODAUT") + N8O->N8O_ITEM, "N8O_CODCTR"),Space(TamSX3("N9E_CODCTR")[1]))})
	oStruN9E:AddTrigger( "N9E_CODINE","N9E_ITEM"  , {|| .T. }, {|| IIF(.Not. Empty(FwFldGet("N9E_CODINE")),POSICIONE("N8O",1,FwXfilial("N8O") + FwFldGet("N9E_CODAUT") + N8O->N8O_ITEM, "N8O_IDENTR"),Space(TamSX3("N9E_ITEM")  [1]))})
	oStruN9E:AddTrigger( "N9E_CODINE","N9E_SEQPRI", {|| .T. }, {|| IIF(.Not. Empty(FwFldGet("N9E_CODINE")),POSICIONE("N8O",1,FwXfilial("N8O") + FwFldGet("N9E_CODAUT") + N8O->N8O_ITEM, "N8O_IDREGR"),Space(TamSX3("N9E_SEQPRI")[1]))})
	
	//Gatilho para os campos da NJJ a partir da autorização de carregamento
	oStruN9E:AddTrigger( "N9E_CODAUT","N9E_CODAUT" ,{|| .T. }, {|| AGRA550CMP()})
	
	oModel:SetRelation( "AGRA550_N9E", { { "N9E_FILIAL", "fwxFilial( 'N9E' )" }, { "N9E_CODROM", "NJJ_CODROM" } }, N9E->( IndexKey( 1 ) ) )
	
	//--------------------------------------
	// Grid de Blocos 
	//--------------------------------------
	oModel:AddGrid(  "AGRA550_N8Q", "AGRA550_NJJ", oStruN8Q, /*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bLinePost*/,/*bLoad*/)
	oModel:GetModel( "AGRA550_N8Q" ):SetOptional( .t. )

	oStruNJM:SetProperty( "NJM_CODENT", MODEL_FIELD_OBRIGAT, .F.)
	oStruNJM:SetProperty( "NJM_CODROM", MODEL_FIELD_OBRIGAT, .F.)
	oStruNJM:SetProperty( "NJM_LOJENT", MODEL_FIELD_OBRIGAT, .F.)
	oStruNJM:SetProperty( "NJM_ITEROM", MODEL_FIELD_OBRIGAT, .F.)
	
	//--------------------------------------
	// Adiciona a estrutura comercializacao
	//--------------------------------------	
	oModel:AddGrid( "AGRA550_NJM", "AGRA550_NJJ", oStruNJM, /*lPre*/, /*lPos*/, /*bPre*/, /*bPos*/, /*bLoad*/)
	
	oModel:AddGrid( "AGRA550_DX0", "AGRA550_NJJ", oStruDX0,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bLinePost*/,/*bLoad*/)
	
	oModel:AddGrid( "AGRA550_NJK", "AGRA550_NJJ", oStruNJK, /*lPre*/,  /*lPos*/, /*bPre*/,/*bPos*/, /*bLoad*/)
	
	// Remove campos NJK
	oStruNJK:RemoveField( "NJK_CODROM" )
	oStruNJK:RemoveField( "NJK_CLASSP" )

	oModel:AddGrid( "AGRA550_N9D", "AGRA550_NJJ", oStruN9D,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bLinePost*/,/*bLoad*/)
	oModel:GetModel( "AGRA550_N9D" ):SetDescription( STR0040)	//Fardos do Agendamento AGRO
	oModel:GetModel( "AGRA550_N9D" ):SetOptional( .T. )
	oModel:GetModel( "AGRA550_NJM" ):SetOptional( .T. )
	oModel:GetModel( "AGRA550_DX0" ):SetOptional( .T. )
	oModel:GetModel( "AGRA550_NJK" ):SetOptional( .T. )

	oModel:SetRelation( "AGRA550_N9D", { { "N9D_FILIAL", "fwxFilial( 'N9D' )" }, { "N9D_CODROM", "NJJ_CODROM" } }, N9D->( IndexKey( 1 ) ) )//Preciso que nao filtre por item
	oModel:SetRelation( "AGRA550_N8Q", { { "N8Q_FILIAL", "fwxFilial( 'N8Q' )" }, { "N8Q_CODROM", "NJJ_CODROM" } }, N8Q->( IndexKey( 1 ) ) )//Preciso que nao filtre por item
	oModel:SetRelation( "AGRA550_NJM", { { "NJM_FILIAL", "fwxFilial( 'NJM' )" }, { "NJM_CODROM", "NJJ_CODROM" } }, NJM->( IndexKey( 1 ) ) )
	oModel:SetRelation( "AGRA550_DX0", { { "DX0_FILIAL", "fwxFilial( 'DX0' )" }, { "DX0_NRROM" , "NJJ_CODROM" } }, DX0->( IndexKey( 1 ) ) )	
	oModel:SetRelation( "AGRA550_NJK", { { "NJK_FILIAL", "fwxFilial( 'NJK' )" }, { "NJK_CODROM", "NJJ_CODROM" } }, NJK->( IndexKey( 1 ) ) )
		
	//-------------------
	// Titulos da tela---
	//-------------------
	oModel:SetDescription( STR0001 )	//"Autorização de Carregamento
	oModel:GetModel( 'AGRA550_NJJ' ):SetDescription( STR0001 )	//"Autorização de Carregamento
	oModel:GetModel( "AGRA550_N9E" ):SetDescription( STR0002 )	//"Itens da Autorização de Carregamento
	
	//-------------------------------------
	// Executa na Ativação do model
	//-------------------------------------
	oModel:SetVldActivate({|oModel|AGRA550VAC(oModel)})
	
	oModel:SetActivate({|oModel| AGRA550ACT(oModel)})
	oModel:SetDeActivate({|oModel| AGRA550DCT(oModel)})
	
Return oModel


/*/{Protheus.doc} ViewDef
//ViewDef
@author carlos.augusto
@since 07/03/2018
@version 12.1.21
@type function
/*/
Static Function ViewDef()
	Local oStruNJJ 	:= FWFormStruct( 2, "NJJ", {|cCampo| AllTRim(cCampo) $ "NJJ_CODROM|NJJ_TOETAP|NJJ_DESTPO|NJJ_TIPO|NJJ_DSTIPO|NJJ_PLACA|NJJ_CODTRA|NJJ_NOMTRA|NJJ_CODPRO|NJJ_DESPRO|NJJ_UM1PRO|NJJ_QTDAUT|NJJ_DTAGEN|NJJ_HRAGEN|NJJ_NRAGEN" } )
	Local oStruN9E	:= FWFormStruct( 2, 'N9E', {|cCampo| AllTRim(cCampo) $ "N9E_CODAUT|N9E_CODINE|N9E_ITEMAC|N9E_DESINE|N9E_FILIE|N9E_CODCTR|N9E_ITEM|N9E_SEQPRI|N9E_LOTE|N9E_NMLOT|N9E_QTDAGD|N9E_CTREXT" } )
	Local oModel  	:= FWLoadModel( 'AGRA550' )
	Local oView   	:= FWFormView():New()

	// Define qual Modelo de dados será utilizado
	oView:SetModel( oModel )

	//-----------------------------------------------
	// Campos da N9E que nao precisam ser exibidos---
	//-----------------------------------------------
	oStruN9E:RemoveField("N9E_FILIAL")
	oStruN9E:RemoveField("N9E_CODROM")
	oStruN9E:RemoveField("N9E_ORIGEM")
	oStruN9E:RemoveField("N9E_PEDIDO")
	oStruN9E:RemoveField("N9E_SEQUEN")
	oStruN9E:RemoveField("N9E_DESORG")
	

	//------------------------
	// Campos do formulario---
	//------------------------
	oView:AddField( 'AGRA550_NJJ', oStruNJJ, 'AGRA550_NJJ' )
	
		oStruNJJ:AddField(/*cIdField*/"NJJ_CDOPER",;
		/*cOrdem*/'14',;
		/*cTitulo*/STR0044,;
		/*cDescric*/STR0045,;
		/*aHelp*/,;
		/*cType*/"Get",;
		/*cPicture*/X3PICTURE("N92_CDOPER"),;
		/*bPictVar*/,;
		/*cLookUp*/,;
		/*lCanChange*/.T.,;
		/*cFolder*/,;
		/*cGroup*/,;
		/*aComboValues*/ ,;
		/*nMaxLenCombo*/,;
		/*cIniBrow*/,;
		/*lVirtual*/.T.,;
		/*cPictVar*/,;
		/*lInsertLine*/.F.,;
		/*nWidth*/)
		
		oStruNJJ:AddField(/*cIdField*/"NJJ_DSOPER",;
		/*cOrdem*/'15',;
		/*cTitulo*/STR0046,;
		/*cDescric*/STR0047,;
		/*aHelp*/,;
		/*cType*/"Get",;
		/*cPicture*/X3PICTURE("N92_DSOPER"),;
		/*bPictVar*/,;
		/*cLookUp*/,;
		/*lCanChange*/.T.,;
		/*cFolder*/,;
		/*cGroup*/,;
		/*aComboValues*/ ,;
		/*nMaxLenCombo*/,;
		/*cIniBrow*/,;
		/*lVirtual*/.T.,;
		/*cPictVar*/,;
		/*lInsertLine*/.F.,;
		/*nWidth*/)	
		
		oStruNJJ:AddField(/*cIdField*/"NJJ_SEQOP",;
		/*cOrdem*/'16',;
		/*cTitulo*/STR0048,;
		/*cDescric*/STR0049,;
		/*aHelp*/,;
		/*cType*/"Get",;
		/*cPicture*/X3PICTURE("N92_SEQOP"),;
		/*bPictVar*/,;
		/*cLookUp*/,;
		/*lCanChange*/.T.,;
		/*cFolder*/,;
		/*cGroup*/,;
		/*aComboValues*/ ,;
		/*nMaxLenCombo*/,;
		/*cIniBrow*/,;
		/*lVirtual*/.T.,;
		/*cPictVar*/,;
		/*lInsertLine*/.F.,;
		/*nWidth*/)	
		
		
	//------------------
	// Campos do Grid---
	//------------------
	oView:AddGrid(  'AGRA550_N9E', oStruN9E, 'AGRA550_N9E' , /*uParam4 */, /*< bGotFocus >*/)

	//-----------------------------------
	// Divisao da Tela horizontalmente---
	//-----------------------------------
	oView:CreateHorizontalBox( 'SUPERIOR', 50 )
	oView:CreateHorizontalBox( 'INFERIOR', 50 )

	//---------------------------------
	// 100 verticalmente na inferior---
	//---------------------------------
	oView:CreateVerticalBox( 'BOX_VERT', 100, 'INFERIOR'  )

	//---------------------------------
	// 100 verticalmente na inferior---
	//---------------------------------
	oView:CreateHorizontalBox( 'BOX_INF', 100, 'BOX_VERT' )	//Direito Inferior

	//--------------------
	// Seleciona Campos---
	//--------------------
	oView:SetOwnerView( "AGRA550_NJJ" , "SUPERIOR" )
	oView:SetOwnerView( "AGRA550_N9E" , "BOX_INF" )

	oView:EnableTitleView( "AGRA550_NJJ" )
	oView:EnableTitleView( "AGRA550_N9E" )

	//------------------------------------------
	// Desenhando a tela para o mesmo folder---
	//------------------------------------------	
	oStruNJJ:AddFolder('FOLDER1' ,STR0012 ,'',2) //"Identificação do Agendamento AGRO"
	oStruNJJ:SetProperty( 'NJJ_CODROM' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_TOETAP' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_DESTPO' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_TIPO'   , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_DSTIPO' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_PLACA'  , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_CODTRA' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_NOMTRA' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_CODPRO' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_DESPRO' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_UM1PRO' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_QTDAUT' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_DTAGEN' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_HRAGEN' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_CDOPER' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_DSOPER' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_SEQOP' ,  MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	oStruNJJ:SetProperty( 'NJJ_NRAGEN' , MVC_VIEW_FOLDER_NUMBER, 'FOLDER1')
	
	oStruNJJ:SetProperty( 'NJJ_CODROM' , MVC_VIEW_ORDEM, '01')
	oStruNJJ:SetProperty( 'NJJ_TOETAP' , MVC_VIEW_ORDEM, '02')
	oStruNJJ:SetProperty( 'NJJ_DESTPO' , MVC_VIEW_ORDEM, '03')
	oStruNJJ:SetProperty( 'NJJ_TIPO'   , MVC_VIEW_ORDEM, '04')
	oStruNJJ:SetProperty( 'NJJ_DSTIPO' , MVC_VIEW_ORDEM, '05')
	oStruNJJ:SetProperty( 'NJJ_CODTRA' , MVC_VIEW_ORDEM, '06')
	oStruNJJ:SetProperty( 'NJJ_NOMTRA' , MVC_VIEW_ORDEM, '07')
	oStruNJJ:SetProperty( 'NJJ_PLACA'  , MVC_VIEW_ORDEM, '08')
	oStruNJJ:SetProperty( 'NJJ_CODPRO' , MVC_VIEW_ORDEM, '09')
	oStruNJJ:SetProperty( 'NJJ_DESPRO' , MVC_VIEW_ORDEM, '10')
	oStruNJJ:SetProperty( 'NJJ_UM1PRO' , MVC_VIEW_ORDEM, '11')
	oStruNJJ:SetProperty( 'NJJ_QTDAUT' , MVC_VIEW_ORDEM, '12')
	oStruNJJ:SetProperty( 'NJJ_DTAGEN' , MVC_VIEW_ORDEM, '13')
	oStruNJJ:SetProperty( 'NJJ_HRAGEN' , MVC_VIEW_ORDEM, '14')
	oStruNJJ:SetProperty( 'NJJ_NRAGEN' , MVC_VIEW_ORDEM, '15')	
	oStruNJJ:SetProperty( 'NJJ_CDOPER' , MVC_VIEW_ORDEM, '16')
	oStruNJJ:SetProperty( 'NJJ_DSOPER' , MVC_VIEW_ORDEM, '17')
	oStruNJJ:SetProperty( 'NJJ_SEQOP' ,  MVC_VIEW_ORDEM, '18')
	
	oStruNJJ:SetProperty( 'NJJ_TOETAP' , MVC_VIEW_CANCHANGE, .T.)
	
	
	//--------------------------------------------------------
	// Consulta padrao para filtrar Inst emb da Autorizacao---
	//--------------------------------------------------------	
	oStruN9E:SetProperty( 'N9E_ITEMAC'   , MVC_VIEW_LOOKUP , 'N8ON9E')
	oStruN9E:SetProperty( 'N9E_CODAUT'   , MVC_VIEW_LOOKUP , 'N8NN9E')
	
	//consulta customizada filtra produto por tipo de operação
	oStruNJJ:SetProperty( 'NJJ_CODPRO'   , MVC_VIEW_LOOKUP , 'N92SB1')
	
	oView:AddUserButton( STR0034, '', {|| AGRX500AVF(, M->NJJ_CODROM)} ) //"Vincular Fardos"
	oView:AddUserButton( STR0035, '', {|| AGRX550BVB()} ) //"Vincular Blocos"

	oView:SetCloseOnOk( {||.T.} )
	
Return oView


/*/{Protheus.doc} AGRA550ACT
//Realiza operacoes antes de ativar o modelo
@author carlos.augusto
@since 12/03/2018
@version 12.1.21
@param oModel, object, descricao
@type function
/*/
Static Function AGRA550ACT(oModel)
	Local lRet		:= .T.
	Local oMldNJJ 	:= oModel:GetModel('AGRA550_NJJ')
	Local lMantem	:= .T.
	Local oMldN9E   := oModel:GetModel('AGRA550_N9E')
	Local nX, nY	
	Local lAtualiza := .F.
	
	
	Pergunte( "AGRA550001", .F. )
	SetKey(VK_F4,  {|| AGRA550F4()})  //Setanto F4 para mostrar (consulta saldos)
	
//	2 - REMESSA PARA DEPÓSITO
//	4 - SAÍDA POR VENDA
//	A - ENTRADA POR TRANSFERÊNCIA
//	B - SAÍDA POR TRANSFERÊNCIA
	
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE 
		__cTipo := NJJ->NJJ_TIPO
		
		oMldNJJ:LoadValue('NJJ_CDOPER', Posicione("GWV",1,fwxFilial("GWV")+ NJJ->NJJ_NRAGEN,"GWV_CDOPER"))
		oMldNJJ:LoadValue('NJJ_SEQOP',  Posicione("GWV",1,fwxFilial("GWV")+ NJJ->NJJ_NRAGEN,"GWV_SEQ"))
		oMldNJJ:LoadValue('NJJ_DSOPER', Posicione("GVC",1,fwxFilial("GVC")+ FwFldGet("NJJ_CDOPER"),"GVC_DSOPER"))		
	
	//EndIf
	ElseIf oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. .Not. lMantem
		If FwIsInCallStack("GFEA523")
			__cTipo := Posicione("N92",1,fwxFilial("N92")+_cTpOpRe,"N92_TIPO")
				
			oMldNJJ:LoadValue('NJJ_TIPO',   PADR(__cTipo,TamSx3("NJJ_TIPO")[1] ," "))
			oMldNJJ:LoadValue('NJJ_DSTIPO', AGRA550TP(oMldNJJ:GetValue('NJJ_TIPO')))
			oMldNJJ:LoadValue('NJJ_TOETAP', _cTpOpRe)	//Tipo de Operacao. Etapa eh NJJ_ETAPA	
			oMldNJJ:LoadValue('NJJ_DESTPO', POSICIONE("N92",1,fwxFilial("N92")+_cTpOpRe,"N92_DESCTO"))
			oMldNJJ:LoadValue('NJJ_CDOPER', Posicione("N92",1,fwxFilial("N92")+_cTpOpRe,"N92_CDOPER"))
			oMldNJJ:LoadValue('NJJ_SEQOP',  Posicione("N92",1,fwxFilial("N92")+_cTpOpRe,"N92_SEQOP"))
			oMldNJJ:LoadValue('NJJ_DSOPER', Posicione("GVC",1,fwxFilial("GVC")+FwFldGet("NJJ_CDOPER"),"GVC_DSOPER"))		
		
		Else
			If .Not. Empty(MV_PAR03)
				__cTipo := Posicione("N92",1,fwxFilial("N92")+MV_PAR03,"N92_TIPO")
				
				oMldNJJ:LoadValue('NJJ_TIPO',   PADR(__cTipo,TamSx3("NJJ_TIPO")[1] ," "))
				oMldNJJ:LoadValue('NJJ_DSTIPO', AGRA550TP(oMldNJJ:GetValue('NJJ_TIPO')))
				oMldNJJ:LoadValue('NJJ_TOETAP', MV_PAR03)	//Tipo de Operacao. Etapa eh NJJ_ETAPA
				oMldNJJ:LoadValue('NJJ_DESTPO', POSICIONE("N92",1,fwxFilial("N92")+MV_PAR03,"N92_DESCTO"))	
				oMldNJJ:LoadValue('NJJ_CDOPER', Posicione("N92",1,fwxFilial("N92")+MV_PAR03,"N92_CDOPER"))
				oMldNJJ:LoadValue('NJJ_SEQOP',  Posicione("N92",1,fwxFilial("N92")+MV_PAR03,"N92_SEQOP"))
				oMldNJJ:LoadValue('NJJ_DSOPER', Posicione("GVC",1,fwxFilial("GVC")+FwFldGet("NJJ_CDOPER"),"GVC_DSOPER"))
				
			ElseIf .Not. Empty(_cTpOpRe)
				__cTipo := Posicione("N92",1,fwxFilial("N92")+_cTpOpRe,"N92_TIPO")
				
				oMldNJJ:LoadValue('NJJ_TIPO',   PADR(__cTipo,TamSx3("NJJ_TIPO")[1] ," "))
				oMldNJJ:LoadValue('NJJ_DSTIPO', AGRA550TP(oMldNJJ:GetValue('NJJ_TIPO')))
				oMldNJJ:LoadValue('NJJ_TOETAP', _cTpOpRe)	//Tipo de Operacao. Etapa eh NJJ_ETAPA
				oMldNJJ:LoadValue('NJJ_DESTPO', POSICIONE("N92",1,fwxFilial("N92")+_cTpOpRe,"N92_DESCTO"))	
				oMldNJJ:LoadValue('NJJ_CDOPER', Posicione("N92",1,fwxFilial("N92")+_cTpOpRe,"N92_CDOPER"))
				oMldNJJ:LoadValue('NJJ_SEQOP',  Posicione("N92",1,fwxFilial("N92")+_cTpOpRe,"N92_SEQOP"))
				oMldNJJ:LoadValue('NJJ_DSOPER', Posicione("GVC",1,fwxFilial("GVC")+FwFldGet("NJJ_CDOPER"),"GVC_DSOPER"))
			EndIf
		EndIf
		
	ElseIf oModel:GetOperation() == MODEL_OPERATION_VIEW
		oMldNJJ:LoadValue('NJJ_CDOPER', Posicione("GWV",1,fwxFilial("GWV")+ NJJ->NJJ_NRAGEN,"GWV_CDOPER"))
		oMldNJJ:LoadValue('NJJ_SEQOP',  Posicione("GWV",1,fwxFilial("GWV")+ NJJ->NJJ_NRAGEN,"GWV_SEQ"))
		oMldNJJ:LoadValue('NJJ_DSOPER', Posicione("GVC",1,fwxFilial("GVC")+ FwFldGet("NJJ_CDOPER"),"GVC_DSOPER"))	
	EndIf
	
	//Dados dos pesos das Autorizacoes ao Abrir a tela
	//Preciso ter um somatorio para saber o saldo que precisarei atualizar em cada Autorizacao de Carregamento
	//Por exemplo, se tiver um total de 200 e acrescentar 100, devo atualizar a Autorizacao com +100 e nao 300
	__aAutorPesos := {}
	For nX := 1 to oMldN9E:Length()
		oMldN9E:GoLine( nX )
		If .Not. oMldN9E:IsDeleted()
			lAtualiza := .F.
			For nY := 1 To Len(__aAutorPesos)
				If __aAutorPesos[nY][1] == FwFldGet("N9E_CODAUT")
					__aAutorPesos[nY][2] := __aAutorPesos[nY][2] + FwFldGet("N9E_QTDAGD")
					lAtualiza := .T.
					exit
				EndIf
			Next nY
			If .Not. lAtualiza
				aAdd(__aAutorPesos,{FwFldGet("N9E_CODAUT"),FwFldGet("N9E_QTDAGD"),0, .F.})
			EndIf
		EndIf
	Next nX	
		
	if lRet 
		oModel:GetModel("AGRA550_N9E"):SetNoUpdateLine(.F.)
//		if __cTipo == '1'
//			oModel:GetModel("AGRA550_N9E"):SetNoUpdateLine(.T.)
//		else
//			oModel:GetModel("AGRA550_N9E"):SetNoUpdateLine(.F.)
//		endIF
	endIf
	
Return lRet


/*/{Protheus.doc} AGRA550DCT
//Desativa o modelo
@author marina.muller
@since 17/05/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function AGRA550DCT(oModel)
	Local lRet		:= .T.
	
	SetKey (VK_F4, nil) //Setanto F4 para NÃO mostrar (consulta saldos)
	
Return lRet


/*/{Protheus.doc} AGRA550VAC
//Realiza a validacao de ativacao do modelo
@author carlos.augusto
@since 12/03/2018
@version 12.1.21
@param oModel, object, descricao
@type function
/*/
Static Function AGRA550VAC(oModel)
	Local lRet		:= .T.
	Local lAltera
	
	FwClearHLP()
	
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If .Not. Empty(MV_PAR03) .And. .NOT. IsInCallStack( "A550AtuSt" ) /*não chama validação no atualizar status*/
			If lRet .And. MV_PAR03 != NJJ->NJJ_TOETAP
				//#"O Código de Operação do Agendamento AGRO é  "
				//#" e o código do parâmetro é: "
				//#". As informações de Operação para Agendamento serão atualizadas conforme parâmetro. Deseja alterar o parâmetro para: '" - "Pergunta"
				lAltera := ApMsgYesNo(STR0024 + NJJ->NJJ_TOETAP + STR0025 + MV_PAR03 + STR0026 + NJJ->NJJ_TOETAP + "'?", STR0027)
				If lAltera
					MV_PAR03 := NJJ->NJJ_TOETAP
				EndIf
			EndIf
		EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} PreModelo
//validação do pré modelo
@author marcos.wagner
@since 23/11/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function PreModelo(oModel)
	Local lRet		:= .T.
	Local nOperac	:= oModel:GetOperation()
	Local oMldNJJ 	:= oModel:GetModel('AGRA550_NJJ')
	Local oView     := FwViewActive() 

	//Assim que possível, jogar esta função para o diconário no InitValue
	If nOperac == MODEL_OPERATION_INSERT .AND. EMPTY(oMldNJJ:GetValue("NJJ_DTAGEN"))
		If SubStr(TIME(),1,5) < "12:00"
			oMldNJJ:SetValue("NJJ_DTAGEN", dDATABASE )
			oMldNJJ:SetValue("NJJ_HRAGEN", "14:00" )
		Else
			oMldNJJ:SetValue("NJJ_DTAGEN", dDATABASE+1 )
			oMldNJJ:SetValue("NJJ_HRAGEN", "08:00" )
		EndIf
		//Verifica se não foi chamado via REST, pois via REST a view não está ativa e causa erro
		If !FWIsInCallStack("OGWSPUTATU")
			oView:Refresh('AGRA550_NJJ')
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} PosModelo
//validação do pós modelo
@author marina.muller
@since 18/07/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function PosModelo(oModel)
	Local lRet		:= .T.
	Local nOperac	:= oModel:GetOperation()
	Local lGraos	:= Posicione("SB5",1,fwxFilial("SB5")+M->NJJ_CODPRO,"B5_TPCOMMO") != '2'

	If nOperac == MODEL_OPERATION_INSERT .OR. nOperac == MODEL_OPERATION_UPDATE
	  	If M->NJJ_TIPO $ '2|4|6|8' .AND. _lAltIE
  			//função para avaliação de crédito (AGRX500O.prw)
  			lRet := AGRX500VlC(oModel, M->NJJ_CODROM) 

  			If lRet
  				_lAltIE := .F.
  			EndIf
		EndIF
		
		If lRet .And. M->NJJ_TIPO $ '2|4|6|8'
			//função para verificar saldo do contrato logistico (AGRX550D.prw)
			lRet := AGRX550LOG(oModel)
		EndIF
		
		If oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. !(FWIsInCallStack("GrvModelo"))
			/*Função para preenchimento da GRID de classificação caso */
			If M->NJJ_TIPO $ '1|A|B' .AND. (!Empty(M->NJJ_CODPRO) .AND. lGraos)
				OGA250VTAB()
			EndIF
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} GrvModelo
//GrvModelo
@author carlos.augusto
@since 07/03/2018
@version 12.1.21
@param oModel, object, descricao
@type function
/*/
Static Function GrvModelo(oModel)
	Local lRet    	 	:= .T.
	Local aLines     	:= FwSaveRows()
	Local oMldN9E 	 	:= oModel:GetModel('AGRA550_N9E')
	Local oMldNJJ 	 	:= oModel:GetModel('AGRA550_NJJ')
	Local oMldNJM 	 	:= oModel:GetModel('AGRA550_NJM')	
	Local nOperation 	:= oModel:GetOperation()
	Local aArea 	 	:= GetArea()
	Local nX
	Local nSomaQtdAut 	:= 0 
	Local lCalc			:= .F.
	Local lIntGFE		:= SuperGetMV("MV_INTGFE",.F.,.F.)
	
	//-- Seta a função origem como o agendamento AGRO
	If nOperation == MODEL_OPERATION_INSERT
		oMldNJJ:SetValue('NJJ_ORIGEM','AGRA550')
		oMldNJJ:SetValue("NJJ_STATUS", '6')
	EndIf

	If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)
	
		For nX := 1 to oMldN9E:Length()
			oMldN9E:GoLine( nX )
			If .Not. oMldN9E:IsDeleted() 
			
				dbSelectArea("N8N")
				N8N->(dbSetOrder(1))
				If N8N->(msSeek(FWxFilial("N8N") + oMldN9E:GetValue("N9E_CODAUT")))
					
					//Soma os valores das autorizações para completar o campo QTDAUT
					nSomaQtdAut += N8N->N8N_QTDAUT
					lCalc := .T.
					
					If oMldNJJ:GetValue("NJJ_CODTRA") != N8N->N8N_CODTRA
						lRet := .F.
						//#"O transportador informado no Agendamento AGRO não é o mesmo da Autorização: "#"Por favor, informe a transportadora adequada."
						oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0008 + oMldN9E:GetValue("N9E_CODAUT"), STR0009, "", "")
						exit
					EndIf
					If lRet .And. .Not. Empty(oMldNJJ:GetValue("NJJ_CODPRO")) .And. (oMldNJJ:GetValue("NJJ_CODPRO") != N8N->N8N_CODPRO)
						lRet := .F.
						//#"O produto informado no Agendamento AGRO não é o mesmo da Autorização: "#"Por favor, informe o produto correspondente."
						oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0010 + oMldN9E:GetValue("N9E_CODAUT"), STR0011, "", "")
						exit
					EndIf  
				EndIf
				
				N9A->(DbSetorder(1))
				If N9A->(dbSeek(FWxFilial("N9A")+FwFldGet("N9E_CODCTR")+FwFldGet("N9E_ITEM")+FwFldGet("N9E_SEQPRI")))
					oMldNJJ:SetValue("NJJ_TES", N9A->N9A_TES)
					
					if nOperation == MODEL_OPERATION_INSERT
						oMldNJM:LoadValue("NJM_ITEROM",  StrZero( nX, TamSX3( "NJM_ITEROM" )[1], 0 ) )
					Else
						oMldNJM:GoLine(nX)
						
						If Empty(oMldNJM:GetValue("NJM_ITEROM",nX)) 
							oMldNJM:LoadValue("NJM_ITEROM",  StrZero(nX, TamSX3( "NJM_ITEROM" )[1], 0))
						EndIf
					EndIf
							
					oMldNJM:SetValue( "NJM_TES"   , N9A->N9A_TES)
					oMldNJM:LoadValue("NJM_PERDIV", (100/oMldN9E:Length()))
					oMldNJM:SetValue( "NJM_CODENT", N9A->N9A_CODENT)
					oMldNJM:SetValue( "NJM_LOJENT", N9A->N9A_LOJENT)
					oMldNJM:SetValue( "NJM_CODSAF", oMldNJJ:GetValue("NJJ_CODSAF"))
					oMldNJM:SetValue( "NJM_CODPRO", oMldNJJ:GetValue("NJJ_CODPRO"))
					oMldNJM:SetValue( "NJM_LOTCTL", oMldN9E:GetValue("N9E_LOTE"))
					
					oMldNJM:addLine()
				EndIf	
				
				//Verifica se há saldo e caso haja, atualiza o campo N7S_QTDAGD
				DbSelectArea("N7S")
				DbSetOrder(1)
				If DbSeek(xFilial("N7S") + oMldN9E:GetValue("N9E_CODINE") + oMldN9E:GetValue("N9E_CODCTR")  + oMldN9E:GetValue("N9E_ITEM")  + oMldN9E:GetValue("N9E_SEQPRI"))				
				/*	If oMldN9E:GetValue("N9E_QTDAGD") + N7S->N7S_QTDAGD > N7S->N7S_QTDVIN
						oModel:SetErrorMessage( , , oModel:GetId() , "", "", "Não é possivel instruir o valor : " + ALLTRIM(Transform(oMldN9E:GetValue("N9E_QTDAGD"),PesqPict("N9E","N9E_QTDAGD") ) ), "Saldo disponivel para IE é : " + ALLTRIM(Transform((N7S->N7S_QTDVIN - N7S->N7S_QTDAGD),PesqPict("N9E","N9E_QTDAGD") ) ), "", "")
						lRet := .F.
						exit
					EndIf */
				EndIf
				
			Else
				If nOperation == MODEL_OPERATION_UPDATE
					oMldNJM:GoLine(nX)
					oMldNJM:DeleteLine()
				EndIf			
			EndIf
		Next nX

		//seta valores default na NJJ a partir da IE
		AGRA550NJJ()
	EndIf
	
	if nOperation != MODEL_OPERATION_DELETE
		//Valida de acordo com a quantidade na Autorizacao
		If lRet
			lRet := AGRA550AUT(oModel)
		EndIf
	
		//Gera/Atualiza/Deleta agendamento no GFE	
		If lRet .AND. lIntGFE
			lRet := AGRA550GFE(oModel)		
		EndIf
		
		//Atualiza DXI - nova tela de fardinhos
		If lRet .AND. .NOT. IsInCallStack("A500IncRom") //não for transferência
			AGRX500FCM(oModel)	
		EndIf
		
		If lRet
			if lCalc
				oMldNJJ:SetValue('NJJ_QTDAUT', nSomaQtdAut  )
			endIF
			If lRet := oModel:VldData()
				lRet := FWFormCommit( oModel )
			EndIf
		EndIF
		
		RestArea(aArea)
		FwRestRows(aLines)
	else
		If lRet .AND. lIntGFE
			//Gera/Atualiza/Deleta agendamento no GFE
			lRet := AGRA550GFE(oModel)		
		EndIf
		
		//Deletar o registro na NJJ
		If lRet
			//Deletar o registro na NJJ
			oModel:Deactivate()
			oModel:SetOperation(MODEL_OPERATION_DELETE )
			oModel:Activate()
			
			if ( lRet := oModel:VldData() )
				lRet := FWFormCommit( oModel )
			endIf		
		endIf
	endIf
	
	RestArea(aArea)

Return lRet


/*/{Protheus.doc} AGRA550PLC
//When para controlar conforme a regra Enquanto permanecer no status previsto, deve ser possível alterar a Placa do veículo
@author carlos.augusto
@since 07/03/2018
@version 12.1.21
@type function
/*/
Function AGRA550PLC()
	Local lRet := .T.
	
	//Enquanto permanecer no status previsto, deve ser possível alterar a Placa do veículo
	If M->NJJ_STATUS != '6'
		lRet := .F.
	EndIf
	
Return lRet

/*/{Protheus.doc} AGRA550VPD
//Validacao do codigo do produto
@author carlos.augusto
@since 07/03/2018
@version 12.1.21
@type function
/*/
Function AGRA550VPD()
	Local lRet	:= .T.
	
	lRet := Vazio() .Or. ExistCpo('SB1', M->NJJ_CODPRO)
	
Return lRet

/*/{Protheus.doc} AGRA550VTO
//Função atribui valor tipo/ descrição com base tipo operação informado
@author marina.muller
@since 20/02/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AGRA550VTO()
	Local aArea    := GetArea()
	Local lRet	   := .T.
	Local oModel   := FwModelActive()
	Local oMldNJJ  := oModel:GetModel('AGRA550_NJJ')
	Local cTipo    := ""
	Local cTpOper  := FwFldGet("NJJ_TOETAP")
	
	If !Empty(cTpOper)
		cTipo := Posicione("N92",1,fwxFilial("N92")+FwFldGet("NJJ_TOETAP"),"N92_TIPO")
		oMldNJJ:LoadValue('NJJ_TIPO',   cTipo)
		oMldNJJ:LoadValue('NJJ_DSTIPO', AGRA550TP(cTipo))	
		
		oMldNJJ:LoadValue('NJJ_CDOPER', Posicione("N92",1,fwxFilial("N92")+cTpOper,"N92_CDOPER"))
		oMldNJJ:LoadValue('NJJ_SEQOP',  Posicione("N92",1,fwxFilial("N92")+cTpOper,"N92_SEQOP"))
		oMldNJJ:LoadValue('NJJ_DSOPER', Posicione("GVC",1,fwxFilial("GVC")+FwFldGet("NJJ_CDOPER"),"GVC_DSOPER"))
	EndIf
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} AGRA550F3A
//Filtro da Consulta padrao N8ON9E
@author carlos.augusto
@since 07/03/2018
@version 12.1.21
@type function
/*/
Function AGRA550F3A()
	Local aArea 	:= GetArea()
	Local lRet		:= .T.
	
	lRet := (N8O->N8O_FILIAL = FwXFilial("N9E")) .And. ;
			(N8O->N8O_CODAUT = FwFldGet("N9E_CODAUT"))

	RestArea(aArea)

Return lRet


/*/{Protheus.doc} AGRA550F3B
//Filtro da Consulta Padrao N8NN9E
@author carlos.augusto
@since 07/03/2018
@version 12.1.21
@type function
/*/
Function AGRA550F3B()
	Local aArea 	:= GetArea()
	Local lRet		:= .T.
	Local oModel	:= FwModelActive()
	Local oMldNJJ 	:= oModel:GetModel('AGRA550_NJJ')
	
	if !EMPTY(oMldNJJ:GetValue('NJJ_TIPO'))
		lRet := ((N8N->N8N_TIPO == "1" .And. oMldNJJ:GetValue('NJJ_TIPO') $ "1|3|5|7|9|A") .Or.;
		 		 (N8N->N8N_TIPO == "2" .And. oMldNJJ:GetValue('NJJ_TIPO') $ "2|4|6|8|B")) .And. ;
				(N8N->N8N_CODTRA = oMldNJJ:GetValue("NJJ_CODTRA")) .And. ;
				IIF(.Not. Empty(oMldNJJ:GetValue("NJJ_CODPRO")), N8N->N8N_CODPRO = oMldNJJ:GetValue("NJJ_CODPRO"), 1 = 1)
	else
		lRet := .T.
	endIf
	RestArea(aArea)

Return lRet


/*/{Protheus.doc} AGRA550N92
//Filtro da consulta N92N9E
@author carlos.augusto
@since 04/04/2018
@version undefined

@type function
/*/
Function AGRA550N92()
	
	Local cWhere := ""
	 
	cWhere := "@D_E_L_E_T_ <> '*' AND N92_CDOPER <> ' ' AND N92_MSBLOQ <> 'T' "
	 
	If .NOT. Empty(MV_PAR01)
	 	cWhere += " AND N92_CODIGO IN (SELECT NCB_CODTO FROM " + RetSqlName("NCB") + " NCB WHERE NCB_FILIAL = N92_FILIAL AND NCB_CODPRO = '" + MV_PAR01 + "' )  "
	Else
	 	cWhere += " AND N92_CODIGO NOT IN (SELECT NCB_CODTO FROM " +RetSqlName("NCB") + " NCB WHERE NCB_FILIAL = N92_FILIAL)  "
	EndIf
 
Return cWhere

/*/{Protheus.doc} AGRA550GAT
//Campos gatilhados nao podem ser alterados
@author carlos.augusto
@since 07/03/2018
@version 12.1.21
@type function
/*/
Function AGRA550GAT()
	Local lRet		:= .T.
	Local aArea 	:= GetArea()
	
	Do Case

		Case "N9E_FILIE" $ ReadVar()
			If .Not. Empty(FwFldGet("N9E_CODINE")) 
				lRet := FwFldGet("N9E_FILIE") == POSICIONE("N8O",1,FwXfilial("N8O") + FwFldGet("N9E_CODAUT") + N8O->N8O_ITEM, "N8O_FILORI")
			EndIf

		Case "N9E_ITEMAC" $ ReadVar()
			If .Not. Empty(FwFldGet("N9E_CODINE"))
				lRet := FwFldGet("N9E_ITEMAC") == POSICIONE("N8O",1,FwXfilial("N8O") + FwFldGet("N9E_CODAUT") + N8O->N8O_ITEM, "N8O_ITEM")
			EndIf

		Case "N9E_CODCTR" $ ReadVar()
			If .Not. Empty(FwFldGet("N9E_CODINE"))
				lRet := FwFldGet("N9E_CODCTR") == POSICIONE("N8O",1,FwXfilial("N8O") + FwFldGet("N9E_CODAUT") + N8O->N8O_ITEM, "N8O_CODCTR")
			EndIf

		Case "N9E_ITEM" $ ReadVar()
			If .Not. Empty(FwFldGet("N9E_CODINE"))
				lRet := FwFldGet("N9E_ITEM") == POSICIONE("N8O",1,FwXfilial("N8O") + FwFldGet("N9E_CODAUT") + N8O->N8O_ITEM, "N8O_IDENTR")
			EndIf

		Case "N9E_SEQPRI" $ ReadVar()
			If .Not. Empty(FwFldGet("N9E_CODINE"))
				lRet := FwFldGet("N9E_SEQPRI") == POSICIONE("N8O",1,FwXfilial("N8O") + FwFldGet("N9E_CODAUT") + N8O->N8O_ITEM, "N8O_IDREGR")
			EndIf

	EndCase
	RestArea(aArea)	
Return lRet


/*/{Protheus.doc} AGRA550TP
//Gatilha a Descricao do Tipo. O Tamanho da Descricao na NJJ e diferente da K5
@author carlos.augusto
@since 07/03/2018
@version 12.1.21
@type function
/*/
Function AGRA550TP(cCodTipo)
	Local cDescTipo
	
	cDescTipo := Posicione('SX5',1,FWxFilial('SX5')+'K5'+PADR(cCodTipo,TamSx3("X5_CHAVE")[1] ," "),"X5_DESCRI")
	If .Not. Empty(cDescTipo)
		cDescTipo := PADR(AllTrim(cDescTipo),TamSx3("NJJ_DSTIPO")[1] ," ")
	EndIf
Return ALLTRIM(cDescTipo)


/*/{Protheus.doc} AGRA550VIE
//Valida a Instrução de Embarque
@author carlos.augusto
@since 27/02/2018
@version 12.1.21
@type function
/*/
Function AGRA550VIE()
	Local lRet 		:= .T.
	Local aLines    := FwSaveRows()
	Local aArea 	:= GetArea()
	
	lRet := Vazio() .Or. ExistCpo("N7Q", FwFldGet("N9E_CODINE"))
	
	If lRet
		lRet := DefineNJJTipo()
	EndIf
	
	RestArea(aArea)	
	FwRestRows(aLines)
Return lRet


/*/{Protheus.doc} AGRA550VAU
//Valida a Autorizacao
@author carlos.augusto
@since 07/03/2018
@version 12.1.21
@type function
/*/
Function AGRA550VAU()
	Local lRet 		:= .T.
	Local aLines    := FwSaveRows()
	Local aArea 	:= GetArea()
	Local oModel   := FWModelActive()
	Local oModeNJJ := oModel:GetModel('AGRA550_NJJ')
		
	lRet := Vazio() .Or. ExistCpo("N8N", FwFldGet("N9E_CODAUT"))

	If lRet
		lRet := DefineNJJTipo()
		If Vazio()
			oModeNJJ:SetValue('NJJ_QTDAUT', 0 )	
		Else
			oModeNJJ:SetValue('NJJ_QTDAUT', Posicione("N8N",1,FwXfilial("N8N")+FwFldGet("N9E_CODAUT"),"N8N_QTDAUT") )
		EndIf
	EndIf

	RestArea(aArea)	
	FwRestRows(aLines)
Return lRet


/*/{Protheus.doc} DefineNJJTipo
//Valida se o item digitado esta de acordo com o Tipo de Controle NJJ_TIPO
@author carlos.augusto
@since 07/03/2018
@version 12.1.21
@type function
/*/
Static Function DefineNJJTipo()
	Local lRet 		:= .T.
	Local aArea 	:= GetArea()
	Local cTipoNJJ	:= ""
	Local cTpMerc
	Local cTipoCtr
	
	//Obtém as informacoes de Tipo de Mercado e Tipo de Contrato. 
	dbSelectArea("N8O")
	N8O->(dbSetOrder(1))
	If N8O->(msSeek(FWxFilial("N8O") + FwFldGet("N9E_CODAUT")))
		//Com IE
		cTpMerc := Posicione("NJR",1,xFilial("NJR") + N8O->N8O_CODCTR,"NJR_TIPMER") //1=Interno;2=Externo
		If  cTpMerc == "2" 
			cTipoNJJ := '2'
		ElseIf cTpMerc == "1"
			cTipoCtr := POSICIONE("N7Q",1,FwXfilial("N7Q") + N8O->N8O_CODINE, "N7Q_TPCTR") //1=Venda;2=Armazenagem
			If cTipoCtr == "1" 
				cTipoNJJ := '4'
			Elseif cTipoCtr == "2"
				cTipoNJJ := '2'
			EndIf
		EndIf
	Else
		//Sem IE
		If POSICIONE("N8N",1,FwXfilial("N8N") + FwFldGet("N9E_CODAUT"), "N8N_TIPO") == "1" //Entrada
			cTipoNJJ := '1'
		ElseIf POSICIONE("N8N",1,FwXfilial("N8N") + FwFldGet("N9E_CODAUT"), "N8N_TIPO") == "2" //Saida
			cTipoNJJ := '2'
		EndIf
	EndIf

	/*If AllTrim(__cTipo) != cTipoNJJ
		Help( , , STR0013, , STR0021 + cTipoNJJ + " - " + AllTrim(AGRA550TP(cTipoNJJ)), 1, 0 ) //#"O Tipo de Controle para o item selecionado é: "
		lRet := .F.
	EndIf*/

	RestArea(aArea)	
Return lRet



/*/{Protheus.doc} AGRA550GFE
//Gera Agendamento no GFE
@author carlos.augusto
@since 12/03/2018
@version 12.1.21
@param cTransp, characters, Transportadora do Agendamento no GFE
@param cOperGFE, characters, Operacao de Controle do GFE
@param cSeqOper, characters, Sequencia Operacao de Controle do GFE
@param cDtAgen, characters, Data do Agendamento no GFE
@param cHrAgen, characters, Horario do Agendamento no GFE
@param cPlaca, characters, Placa do Veiculo do Agendamento no GFE
@type function
/*/
Static Function AGRA550GFE(oModel, cTransp, cOperGFE, cSeqOper, cDtAgen, cHrAgen, cPlaca)
	Local oMldNJJ 	:= oModel:GetModel('AGRA550_NJJ')
	Local aArea  	:= GetArea()
	Local oModelGFE := FWLoadModel("GFEA517")
	Local lRet  	:= .T.
	Local nNrAgen 	:= oMldNJJ:GetValue("NJJ_NRAGEN")
	Local cField	:= ""
	Local nOperation := oModel:GetOperation()
	Local cTranspSN
	Local cAuton	 := ""
	Local cCGCIDFED 
	Local cEmit	
	Local cMsgDel 	:= ""
	Local cMsg 	  	:= ""
	
	Default cTransp  := oMldNJJ:GetValue("NJJ_CODTRA")
	Default cOperGFE := oMldNJJ:GetValue("NJJ_CDOPER")
	Default cSeqOper := oMldNJJ:GetValue("NJJ_SEQOP")
	Default cDtAgen  := oMldNJJ:GetValue("NJJ_DTAGEN")
	Default cHrAgen	 := StrTran( AllTrim(oMldNJJ:GetValue("NJJ_HRAGEN")), ":", "" ) //retira o : do horario se tiver
	Default cPlaca   := oMldNJJ:GetValue("NJJ_PLACA")

	If nOperation == MODEL_OPERATION_DELETE
		dbSelectArea("GWV")
		GWV->(dbSetOrder(1))
		if GWV->(MsSeek(FWxFilial("GWV")+nNrAgen))	
			if GWV->GWV_SIT = '1' //Aberto
				if RecLock("GWV", .F.)					
					GWV->(dbDelete())
					GWV->(MsUnLock())
				else
					//Registro não encontrado.
					lRet := .F.
					cMsgDel := STR0070  //"Agendamento GFE não encontrado ao tentar exlcuir."
				endIf
			else
				//Agendamento não está como aberto, não pode ser deletado
				lRet := .F.
				cMsgDel := STR0071 //"Status Agendamento GFE não está como aberto, portanto, não pode ser deletado."
			endIf
		endIf
		//oModelGFE:SetOperation(MODEL_OPERATION_DELETE )
	ElseIf Empty(nNrAgen)	
		nNrAgen := GETSXENUM("GWV","GWV_NRAGEN")
		oModelGFE:SetOperation( MODEL_OPERATION_INSERT )
	Else
		oModelGFE:SetOperation( MODEL_OPERATION_UPDATE )
		dbSelectArea("GWV")
		GWV->(dbSetOrder(1))
		GWV->(MsSeek(FWxFilial("GWV")+nNrAgen))

	EndIf

	If oModelGFE:Activate() .And. nOperation != MODEL_OPERATION_DELETE 
		If lRet
			lRet := oModelGFE:SetValue('GFEA517_GWV', 'GWV_NRAGEN', nNrAgen )
		EndIf
		If lRet
			lRet := oModelGFE:SetValue('GFEA517_GWV', 'GWV_FILIAL', FwXfilial("GWV") )
		EndIf
		
		If lRet				
			//Pegar CNPJ
			dbSelectArea("SA4")
			SA4->(dbSetOrder(1))
			If SA4->(DbSeek(FWxFilial("SA4")+cTransp))
				cCGCIDFED := SA4->A4_CGC
			EndIf
			
			If Empty(cCGCIDFED)
				cMsg := STR0039 + cTransp + "." //#"Verifique o Cadastro de Transportadores com o código: "
				lRet := .F.
			EndIf
			
			If lRet		
				dbSelectArea("GU3")
				GU3->(dbSetOrder(11))
				If GU3->(DbSeek(FWxFilial("GU3")+cCGCIDFED))
					//WHILE !(EOF()) .AND. GU3->GU3_IDFED = cCGCIDFED .AND. (GU3->GU3_TRANSP = '1' .OR. GU3->GU3_AUTON = '1') 
					While GU3->(!Eof()) .AND. GU3->GU3_IDFED = cCGCIDFED
						
						cTranspSN := GU3->GU3_TRANSP
						cEmit 	  := GU3->GU3_CDEMIT
						cAuton	  := GU3->GU3_AUTON
						If cTranspSN == "1" .OR. cAuton = '1'
							exit
						EndIf
						GU3->(dbSkip())
					EndDo
				EndIf
				
				If .Not. Empty(cTranspSN) .And. (cTranspSN == "2" .AND. cAuton == "2")  
					cMsg := STR0033 + cCGCIDFED + "." //#"Configure Emitente como transportador no GFE: CNPJ "
					lRet := .F.
				EndIf
				
				If Empty(cEmit)
					cMsg := STR0031 + cCGCIDFED + "." //#"Verifique o cadastro de Emitentes no GFE com o CNPJ: "
					lRet := .F.
				EndIf
			EndIf
		EndIf
		
		If lRet
			GU3->(DbSetorder(1))
			lRet := oModelGFE:SetValue('GFEA517_GWV', 'GWV_CDEMIT', cEmit )		
		EndIf
		
		If lRet
			lRet := oModelGFE:SetValue('GFEA517_GWV', 'GWV_CDOPER', cOperGFE )
		EndIf
		If lRet
			lRet := oModelGFE:SetValue('GFEA517_GWV', 'GWV_SEQ', 	cSeqOper )
		EndIf
		If lRet
			lRet := oModelGFE:SetValue('GFEA517_GWV', 'GWV_DTAGEN', cDtAgen )
		EndIf
		If lRet
			lRet := oModelGFE:SetValue('GFEA517_GWV', 'GWV_HRAGEN', cHrAgen )
		EndIf
	
		//SIMULA QUE O EMAIL JÁ FOI ENVIADO
		//DAGROUBA-6853 - foi desenvolvida mas a SLC não quer que o email seja enviado, portanto, os campos
		// abaixo serão preenchidos para que diga que o email já foi "* ENVIADO *".
		If lRet
			lRet := oModelGFE:SetValue('GFEA517_GWV', 'GWV_IDENVI', '1' )
		EndIf
		If lRet
			lRet := oModelGFE:SetValue('GFEA517_GWV', 'GWV_DTENVI', DDATABASE )
		EndIf
		If lRet
			lRet := oModelGFE:SetValue('GFEA517_GWV', 'GWV_HRENVI', PADR(TIME(),TamSX3("GWV_HRENVI")[1]) )
		EndIf

		//Obrigatorio na Movimentacao do Patio
		//oModelGFE:SetValue('GFEA517_GWV', 'GWV_NRROM' , nCodRom )

		//Inserção das tabela de Veiculo e Motorista!
		If lRet .AND. !Empty(cPlaca)
			cTipVeic := Posicione("GU8",2,fwxFilial("GU8")+cPlaca,"GU8_CDTPVC")
			lRet := oModelGFE:SetValue('GFEA517_GWY', 'GWY_CDTPVC', cTipVeic )
		EndIf
		/*
		If !(Empty(M->GWN_CDMTR))
		oModelGFE:SetValue('GFEA517_GX1', 'GX1_NRAGEN', nNrAgen)
		oModelGFE:SetValue('GFEA517_GX1', 'GX1_CDMTR', M->GWN_CDMTR)
		EndIf
		*/
	endIF
	
	If lRet .AND. nOperation != MODEL_OPERATION_DELETE
		If ( lRet := oModelGFE:VldData() )
			If lRet
				If nOperation == MODEL_OPERATION_INSERT
					oMldNJJ:LoadValue("NJJ_NRAGEN", nNrAgen )
				EndIf
				lRet := oModelGFE:CommitData()
				//FWFORMCOMMIT(oModelGFE)
				ConfirmSX8()
			EndIf
		endIf
	EndIf
	
	If .Not. lRet
		
		//Veio do incluir
		If !Empty(cMsg) .AND. Empty(cMsgDel)
			oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0020, cMsg, "", "") //"Erro ao excluir Agendamento no GFE"
		//Veio do deletar
		elseIf Empty(cMsg) .AND. !Empty(cMsgDel)
			oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0069, cMsgDel, "", "") //"Erro ao excluir Agendamento no GFE"
		Else
			cField := IIF(.Not. Empty(oModelGFE:GetErrorMessage()[4]),"["+ oModelGFE:GetErrorMessage()[4] +"]", "")
			oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0020, oModelGFE:GetErrorMessage()[6] + "["+ cField +"]" + oModelGFE:GetErrorMessage()[7], "", "")//#"Erro ao gerar Agendamento no GFE."
		EndIf
		
		RollBackSX8()
	EndIf

	oModelGFE:Deactivate()
	GU3->(dbCloseArea())
	SA4->(dbCloseArea())
	SA2->(dbCloseArea())
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} AGRA550P1
//Valid para o campo de produto do pergunte. Este campo filtra os tipo de operações a serem exibidos
@author brunosilva
@since 06/02/2018
@type function
/*/
Function AGRA550P1()
	Local aArea := GetArea()
	Local lRet  := .T.
	
	If !(EMPTY(MV_PAR01))
		If ExistCpo('SB1', MV_PAR01)
			NCB->(dbSelectArea("NCB"))	
			
			If !(EMPTY(MV_PAR03)) //Tp. Op.
				NCB->(dbSetOrder(1))
				
				If !NCB->(msSeek(FWxFilial("NCB")+MV_PAR03+MV_PAR01))
					lRet := .T.
					MV_PAR03 := Space(TamSX3("N92_CODIGO")[1])
					MV_PAR04 := Space(TamSX3("N92_DESCTO")[1])
				EndIf
			EndIf
			
			NCB->(dbGoTop())
			NCB->(dbSetOrder(2))
			If !(NCB->(MsSeek( FWxFilial( "NCB" )+MV_PAR01)))
				HELP(, , STR0013, , STR0061, 1, 0 ) //"Não existe nenhum Tipo de operação cadastrado para este produto."
				lRet := .F.
			Else
				MV_PAR02 := Posicione("SB1",1,FWxFilial("SB1")+MV_PAR01,"B1_DESC")
			EndIF
			NCB->(dbCloseArea())
		Else
			lRet := .F.
		EndIf
	Else
		MV_PAR02 := Space(TamSX3("B1_DESC")[1])
	EndIf
	
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} AGRA550P2
//Valid para o campo de tipo de operação do pergunte. 
@author ana.olegini
@since  24/04/2018
@type function
/*/
Function AGRA550P2()
	Local aArea 	:= GetArea()
	Local lRetorno  := .T.
	
	//--Se o Tipo de Operação NAO estiver vazio E o Produto NAO estiver vazio
	If .NOT. (EMPTY(MV_PAR03)) .And. .NOT. (EMPTY(MV_PAR01))
		//--Verifica na NCB se o tipo de operação possui produto vinculado
		NCB->(dbSelectArea("NCB"))
		NCB->(dbSetOrder(1))
		
		If !NCB->(msSeek(FWxFilial("NCB")+MV_PAR03+MV_PAR01))
			Help(, , STR0013, , STR0062, 1, 0 ) 	//"Tipo de Operação não está cadastrado para o Produto selecionado."
			lRetorno := .F.
		Else
			N92->(dbSelectArea("N92"))	
			N92->(dbSetOrder(1))
			If .NOT. (N92->(MsSeek(FWxFilial("N92")+MV_PAR03)))
				If Empty(N92->N92_CDOPER) .Or. Empty(N92->N92_SEQOP)
					//#"O campo de Configuração de Operação do GFE não foi preenchido no cadastro de Tipo de Operação de Romaneio."
					HELP(, , STR0013, , STR0050, 1, 0 )
					lRetorno := .F.
				Else
					MV_PAR04 := N92->N92_DESCTO
				EndIf
			EndIf	
			N92->(dbCloseArea())
		EndIf
		NCB->(dbCloseArea())
	Else
		If EMPTY(MV_PAR03)
			MV_PAR04 := Space(TamSX3("N92_DESCTO")[1])
		Else
			N92->(dbSelectArea("N92"))	
			N92->(dbSetOrder(1))
			If .NOT. (N92->(MsSeek(FWxFilial("N92")+MV_PAR03)))
				If Empty(N92->N92_CDOPER) .Or. Empty(N92->N92_SEQOP)
					//#"O campo de Configuração de Operação do GFE não foi preenchido no cadastro de Tipo de Operação de Romaneio."
					HELP(, , STR0013, , STR0050, 1, 0 )
					lRetorno := .F.
				Else
					MV_PAR04 := N92->N92_DESCTO
				EndIf
			EndIf	
			N92->(dbCloseArea())
		EndIf
	EndIf
	
	RestArea(aArea)
Return lRetorno


/*/{Protheus.doc} AGRA550AUT
//Validacao de quantidade autorizada
//Atualizacao de saldo na Autorizacao de Carregamento
@author carlos.augusto
@since 26/03/2018
@version undefined
@param oModel, object, descricao
@type function
/*/
Function AGRA550AUT(oModel)
	Local aArea 	 := GetArea()
	Local lRet  	 := .T.
	Local aLines     := FwSaveRows()
	Local oMldN9E 	 := oModel:GetModel('AGRA550_N9E')
	Local nOperation := oModel:GetOperation()
	Local oMldN8N
	Local nX, nY
	Local nDiferenca
	Local lAdiciona := .F.

	If lRet

		Begin Transaction

			//Preciso agrupar os pesos de agendamentos para Atualizar na Autorizacao de Carregamento
			If nOperation == MODEL_OPERATION_UPDATE
				For nX := 1 to oMldN9E:Length()
					oMldN9E:GoLine( nX )
					lAdiciona := .T.
					If .Not. oMldN9E:IsDeleted()
						For nY := 1 To Len(__aAutorPesos)
							If __aAutorPesos[nY][1] == oMldN9E:GetValue("N9E_CODAUT")
								__aAutorPesos[nY][3] :=  oMldN9E:GetValue("N9E_QTDAGD") + __aAutorPesos[nY][3]
								lAdiciona := .F.
							EndIf
						Next nY
						If lAdiciona
							aAdd(__aAutorPesos,{FwFldGet("N9E_CODAUT"),FwFldGet("N9E_QTDAGD"),FwFldGet("N9E_QTDAGD"),.F.})
						EndIf
					EndIf
				Next nX
			EndIf
			For nX := 1 to oMldN9E:Length()
				oMldN9E:GoLine( nX )
				If .Not. oMldN9E:IsDeleted() .And. lRet

					dbSelectArea("N8N")
					N8N->(dbSetOrder(1))
					If N8N->(MsSeek(FWxFilial("N8N") + oMldN9E:GetValue("N9E_CODAUT")))

						oMldN8N := FWLoadModel("AGRA540")
						// Remoção de when de campos para permitir setValue
						For nY := 1 To Len(oMldN8N:aAllSubModels)
							oMldN8N:aAllSubModels[nY]:GetStruct():SetProperty( "*", MODEL_FIELD_WHEN, {| oField | .T. } ) 
						Next nY
						oMldN8N:SetOperation( MODEL_OPERATION_UPDATE )
						If oMldN8N:Activate()
							If nOperation == MODEL_OPERATION_UPDATE
								nDiferenca := 0
								For nY := 1 To Len(__aAutorPesos)
									If __aAutorPesos[nY][1] == oMldN9E:GetValue("N9E_CODAUT") .And. .Not. __aAutorPesos[nY][4]
										nDiferenca :=   __aAutorPesos[nY][3] - __aAutorPesos[nY][2]
										__aAutorPesos[nY][4] := .T.
									EndIf
								Next nY
								If nDiferenca != 0
									oMldN8N:SetValue("AGRA540_N8N","N8N_QTDAGD", oMldN8N:GetValue("AGRA540_N8N","N8N_QTDAGD") + nDiferenca)
								EndIf	
							ElseIf nOperation == MODEL_OPERATION_INSERT
								oMldN8N:SetValue("AGRA540_N8N","N8N_QTDAGD", oMldN8N:GetValue("AGRA540_N8N","N8N_QTDAGD") + oMldN9E:GetValue("N9E_QTDAGD"))
							ElseIf nOperation == MODEL_OPERATION_DELETE
								oMldN8N:SetValue("AGRA540_N8N","N8N_QTDAGD", oMldN8N:GetValue("AGRA540_N8N","N8N_QTDAGD") - oMldN9E:GetValue("N9E_QTDAGD"))
							EndIf
							
							oMldN8N:SetValue("AGRA540_N8N","N8N_QTDSLD", oMldN8N:GetValue("AGRA540_N8N","N8N_QTDAUT") -  oMldN8N:GetValue("AGRA540_N8N","N8N_QTDAGD"))
								
							//Valida se quantidade agendada eh menor ou igual a autorizada
							If (nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT) .And. ;
							(oMldN8N:GetValue("AGRA540_N8N","N8N_QTDAGD") > oMldN8N:GetValue("AGRA540_N8N","N8N_QTDAUT"))
								//#"A quantidade agendada é maior do que a quantidade autorizada para a Autorização de Carregamento: "#"Por favor, verifique a diferença: "  
								lRet := .F.
								oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0042 + oMldN8N:GetValue("AGRA540_N8N","N8N_CODIGO"), STR0043 + cValToChar(AllTrim(TransForm((oMldN8N:GetValue("AGRA540_N8N","N8N_QTDAUT") - oMldN8N:GetValue("AGRA540_N8N","N8N_QTDAGD")), "@E 9,999,999.99"))                                       ), "", "")
							EndIf
	
							If lRet .And. ((nOperation == MODEL_OPERATION_UPDATE .And. nDiferenca != 0) .Or.;
							nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_DELETE)
								If ( lRet := oMldN8N:VldData() )
									If lRet
										lRet := oMldN8N:CommitData()
									EndIf
									If !lRet
										//#"Inconsistência ao atualizar a quantidade agendada na Autorização de Carregamento: "
										oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0041 + oMldN9E:GetValue("N9E_CODAUT"), oMldN8N:GetErrorMessage()[6], "", "")
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Next nX
			If !lRet
				DisarmTransaction()
			EndIf

		End Transaction
	EndIf

	RestArea(aArea)
	FwRestRows(aLines)
Return lRet


/*/{Protheus.doc} AGRA550F4
//Exibe os saldos do Produto
@author carlos.augusto
@since 18/04/2018
@version undefined
@type function
/*/
Static Function AGRA550F4()
	Local aOldArea  := GetArea()
	Local oModel	:= FwModelActive()
	Local oMldNJJ 	:= oModel:GetModel('AGRA550_NJJ')
	Local cCodPro   := ""
	Local cCodFilial := ""
	Local lRet		:= .T.
	
	//atribui os valores da tela
	cCodFilial := oMldNJJ:GetValue("NJJ_FILIAL")
	cCodPro    := oMldNJJ:GetValue("NJJ_CODPRO")
	
	//se produto não tiver sido informado busca no parâmetro F12
	If Empty(cCodPro)
	   Pergunte( "AGRA550001", .F.)
	   
	   If !Empty(MV_PAR01)
	   	  cCodPro := MV_PAR01
	   EndIf
	EndIf
			
	OGAC120(cCodPro, cCodFilial)
	
	RestArea(aOldArea)

Return lRet

/*/{Protheus.doc} AGRA550GTB()
// Gatilha a tabela de desconto caso o produto tenha uma.
@author brunosilva
@since 23/10/2018
@version 1.0
@return lRet 

@type function
/*/
Function AGRA550GTB()
	Local cCodPro 	:= M->NJJ_CODPRO
	Local lGraos	:= (Posicione("SB5",1,FWxFilial("SB5")+cCodPro,"B5_TPCOMMO") != '2')  //Diferente de algodao
	Local cTabela	:= ''
	Local cQry		:= ""
	Local cDB 		:= TcGetDB()
	Local cStrDt	:= ''
	Local cTipo 	:= M->NJJ_TIPO
	
	if cTipo $ '1|A|B' .AND. lGraos 
		If cDb = 'MSSQL'
			cStrDt := " GETDATE() "
		ElseIf cDb = "ORACLE"
			cStrDt := " SYSDATE "
		EndIf
		
		cQry := "SELECT NNI.NNI_CODIGO FROM "+RetSqlName("NNI")+" NNI "
		cQry += "WHERE NNI_TABPDR = '1' "
		cQry += "AND NNI_CODPRO = '"+ cCodPro +"' "
		cQry += "AND " + cStrDt + " BETWEEN " + cCpoDataDB("NNI_DATINI") + " AND " + cCpoDataDB("NNI_DATFIM") + " "
		
		cTabela := getDataSql(cQry)		
		
	endIf
	
Return cTabela

/*/{Protheus.doc} cCpoDataDB
// Reponsável por tratar os campos de data.
@author brunosilva
@since 23/10/2018
@version 1.0
@return cData
@param cCpoData, characters, descricao
@type function
/*/
Static Function cCpoDataDB(cCpoData)
	Local cDB := TcGetDB()
	
	If cDb = 'MSSQL'
		cData := cCpoData
	ElseIf cDb =  "ORACLE"
		cData := "TO_DATE(" + cCpoData + ", 'YYYYMMDD')"
	EndIf
Return cData


/*/{Protheus.doc} AGRA550VLT
//Valida o somente lote digitado
@author carlos.augusto
@since 18/04/2018
@version undefined
@type function
/*/
Function AGRA550VLT()
	Local lRet		:= .T.
	
	/*Local cCodPro   := ""
	Local cCodLoc	:= ""
	Local cCodFilial := ""
	Local aArea		:= GetArea()
	Local aLines	:= FwSaveRows()
	Local oModel	:= FwModelActive()
	Local oMldN9E 	:= oModel:GetModel('AGRA550_N9E')
	Local oMldNJJ 	:= oModel:GetModel('AGRA550_NJJ')
	
	If .Not. Empty(oMldN9E:GetValue( "N9E_CODAUT" )) .And. .Not. Empty(oMldN9E:GetValue( "N9E_CODINE" ))
		lRet := .Not. Empty(oMldN9E:GetValue( "N9E_LOTE" ))
		
		If lRet
			If lRet
				DbSelectArea("N7Q")
				DbSetOrder(1)
				If N7Q->(DbSeek(FwxFilial("N7Q") + oMldN9E:GetValue( "N9E_CODINE" )))
					cCodPro	:= N7Q->N7Q_CODPRO
					cCodLoc	:= N7Q->N7Q_LOCAL
				EndIf
				
				If Empty(cCodLoc)
					//#"Campo Local não preenchido na Instrução de Embarque."
					HELP(, , STR0013, , STR0056, 1, 0 )
					lRet := .F.		
				EndIf
				
				If lRet
					DbSelectArea("SB8")
					DbSetOrder(3)
					If SB8->(DbSeek(FwxFilial("SB8") + cCodPro + cCodLoc + oMldN9E:GetValue( "N9E_LOTE" )))
						If SB8->B8_DTVALID < dDataBase
							HELP(, , STR0013, , STR0057, 1, 0 ) //"Lote vencido."
							lRet := .F.
						EndIf
					Else
						HELP(, , STR0013, , STR0058, 1, 0 ) //"Lote não encontrado."
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
	FwRestRows(aLines)
	RestArea(aArea)*/
Return lRet


/*/{Protheus.doc} AGRA550VSB
//Valida Somente o Sub-Lote digitado
@author carlos.augusto
@since 18/04/2018
@version undefined
@type function
/*/
Function AGRA550VSB()
	Local lRet		:= .T.
	/*
	Local cCodPro   := ""
	Local cCodLoc	:= ""
	Local aArea 	:= GetArea()
	Local aLines	:= FwSaveRows()
	Local oModel	:= FwModelActive()
	Local oMldN9E 	:= oModel:GetModel('AGRA550_N9E')
	Local oMldNJJ 	:= oModel:GetModel('AGRA550_NJJ')
	
	If .Not. Empty(oMldN9E:GetValue( "N9E_CODAUT" )) .And. .Not. Empty(oMldN9E:GetValue( "N9E_CODINE" ))
		lRet := .Not. Empty(oMldN9E:GetValue( "N9E_LOTE" ) + oMldN9E:GetValue( "N9E_NMLOT" ))
		
		If lRet
	//		cCodFilial := oMldN9E:GetValue( "N9E_CODINE" )
		
	//		If Empty(cCodFilial)
	//			//#"Instrução de embarque não informada."
	//			HELP(, , STR0013, , STR0055, 1, 0 )
	//			lRet := .F.
	//		EndIf
			
			If lRet
				DbSelectArea("N7Q")
				DbSetOrder(1)
				If N7Q->(DbSeek(FwxFilial("N7Q") + oMldN9E:GetValue( "N9E_CODINE" )))
					cCodPro	:= N7Q->N7Q_CODPRO
					cCodLoc	:= N7Q->N7Q_LOCAL
				EndIf
				
				If Empty(cCodLoc)
					//#"Campo Local não preenchido na Instrução de Embarque."
					HELP(, , STR0013, , STR0056, 1, 0 )
					lRet := .F.		
				EndIf
				
				If lRet
					DbSelectArea("SB8")
					DbSetOrder(3)
					If SB8->(DbSeek(FwxFilial("SB8") + cCodPro + cCodLoc + oMldN9E:GetValue( "N9E_LOTE" ) + oMldN9E:GetValue( "N9E_NMLOT" )))
						If SB8->B8_DTVALID < dDataBase
							HELP(, , STR0013, , STR0059, 1, 0 ) //"Sub-Lote vencido."
							lRet := .F.
						EndIf
					Else
						HELP(, , STR0013, , STR0060, 1, 0 ) //"Sub-Lote não encontrado."
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	FwRestRows(aLines)
	RestArea(aArea)*/
Return lRet


/*/{Protheus.doc} A550AtuSt
//Função para atualizar status do agendamento AGRO
@author marina.muller
@since 18/05/2018
@version 1.0
@return ${return}, ${return_description}
/*/
Function A550AtuSt(cCodRomaneio, lVisual, cNmMov)
	Local lRet		:= .T.
	Local aArea   	:= GetArea()
	Local aLines  	:= FwSaveRows()
	Local oModel  	:= FwLoadModel('AGRA550')
	
	Default cNmMov	:= ""
	
	dbSelectArea('NJJ')
	NJJ->(dbSetOrder(1))
	If NJJ->(MsSeek(FWxFilial('NJJ')+cCodRomaneio)) //filial + romaneio

		//Se status do romaneio for 6 (previsto)
		If NJJ->NJJ_STATUS = '6'
			if !(IsInCallStack("GFEA523"))
				oModel:SetOperation(4) //Alteração
				If oModel:Activate()
				
					oModel:GetModel('AGRA550_NJJ'):SetValue('NJJ_DTULAL', dDatabase)
					oModel:GetModel('AGRA550_NJJ'):SetValue('NJJ_HRULAL', Time())
		
					if A550OriSai()
						oModel:GetModel('AGRA550_NJJ'):SetValue('NJJ_STATUS','5') //atualiza status para 5 (pendente de aprovação)
					Else
						oModel:GetModel('AGRA550_NJJ'):SetValue('NJJ_STATUS','0') //atualiza status como 0 (pendente)
					EndIf
						
					If lRet := oModel:VldData()
						lRet := FWFormCommit( oModel )
					EndIf 
				Else 
					AutoGrLog(oModel:GetErrorMessage()[6])
					AutoGrLog(oModel:GetErrorMessage()[7])
					If !Empty(oModel:GetErrorMessage()[2]) .And. !Empty(oModel:GetErrorMessage()[9])
						AutoGrLog(oModel:GetErrorMessage()[2] + " = " + oModel:GetErrorMessage()[9])
					EndIf
					
					If lVisual
						MostraErro()
					Endif					
				EndIf
	
				If lRet .And. lVisual
					If !IsBlind()
						MsgInfo( STR0063 + cCodRomaneio + STR0064 ) //"Status romaneio " ## " atualizado com sucesso."
					Endif
				Endif
				
				oModel:DeActivate()
			else
				if RecLock("NJJ", .F.)					
					NJJ->NJJ_STATUS := "1"
					NJJ->NJJ_NRMOV  := cNmMov
					MsUnlock("NJJ")
				endIf
			endIf
		Else
			If lVisual
				If !IsBlind()
				   MsgInfo(STR0066) //"Somente pode ser atualizado romaneio com status previsto."
				Endif
			Endif   
		Endif
	EndIf
		
	FwRestRows(aLines)
	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} A550OriSai
Função que verifica se o romaneio de entrada foi originado de um romaneio de saída automaticamente
@author silvana.torres
@since 06/06/2018
@version undefined

@type function
/*/
Function A550OriSai()

	Local lRet 		:= .F.
	Local aArea   	:= GetArea()
	Local cFilOri	:= ""
	Local cRomOri	:= ""
	Local cGeraAgen := ""
	
	//Verifica se é entrada e se foi originada por um romaneio de saída
	If NJJ->NJJ_TIPO = "A" .AND. SUBSTRING(NJJ->NJJ_OBS,1,17) = "Filial de origem:"
		cFilOri := SUBSTRING(NJJ->NJJ_OBS,18,7)
		cRomOri := SUBSTRING(NJJ->NJJ_OBS,35,len(trim(NJJ->NJJ_OBS))) 
		
		If .NOT. Empty(cRomOri)
		
			//busca o romaneio de origem
			dbSelectArea('NJJ')
			NJJ->(dbSetOrder(1))
			If NJJ->(MsSeek(cFilOri+cRomOri)) //filial + romaneio
				
				//verifica se o tipo de operação do romaneio origem gera agendamento
				cGeraAgen := Posicione("N92",1,FWxFilial("N92")+NJJ->NJJ_TOETAP,"N92_GERROM")
								
				If cGeraAgen = "2" //Gera agendamento Agro Destino
					lRet := .T.
				EndIf
			EndIf
		EndIf
	EndIF
	
	RestArea(aArea)  

Return lRet

/*/{Protheus.doc} AGRA550INP
Inicializador padrao de campos
@author silvana.torres
@since 30/06/2018
@version undefined
@param cCampo, characters, descricao
@type function
/*/
Function AGRA550INP(cCampo)
	Local aArea     := GetArea()
	Local cValor    := ""
    
	//-- Se não é uma inclusão
	If .NOT. Inclui
		If cCampo $ "NJJ_DESPRO"
	    	cValor := Posicione("SB1",1,FWxFilial("SB1")+NJJ->NJJ_CODPRO,"B1_DESC")
	    endIf
	Else //-- Utiliza etapa do parametro 
		Pergunte( "AGRA550001", .F. ) 
    	if .NOT. EMPTY(MV_PAR01)
		    If cCampo $ "NJJ_DESPRO"
	   			cValor := Posicione("SB1",1,FWxFilial("SB1")+MV_PAR01,"B1_DESC")
		    endIf 
		    If cCampo $ "NJJ_UM1PRO"
		    	cValor := Posicione("SB1",1,FWxFilial("SB1")+MV_PAR01,"B1_UM")
		    endIf
	    ENDiF
    EndIf	

	RestArea(aArea)

Return cValor

/*/{Protheus.doc} AGRA550NJJ
//Função seta valores default na NJJ apartir da IE e contrato informados na GRID
@author marina.muller
@since 18/09/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function AGRA550NJJ()
	Local aArea     := GetArea()
	Local oModel	:= FwModelActive()
	Local oMldN9E 	:= oModel:GetModel('AGRA550_N9E')
	Local oMldNJJ 	:= oModel:GetModel('AGRA550_NJJ')
	Local lRet 		:= .F.
	Local cCodSaf   := ""
	Local cCodEnt   := ""
	Local cLojEnt   := ""
	Local cEntEnt   := ""
	Local cLjEntE   := ""
	Local cLocal    := ""
	Local cTabela   := ""
	Local cTpFrete  := ""
	Local cTipo		:= oMldNJJ:GetValue("NJJ_TIPO")
	Local nX

	//se for saída
	If cTipo $ "2|4|6|8|B"
		For nX := 1 to oMldN9E:Length()
			oMldN9E:GoLine(nX)
			
			If .Not. oMldN9E:IsDeleted()
		
				//busca da IE informações para setar valor default na NJJ
			    dbSelectArea('N7Q')
				N7Q->(dbSetOrder(1))    	
				If N7Q->(MsSeek(FwxFilial("N7Q")+oMldN9E:GetValue("N9E_CODINE"))) //N7Q_FILIAL+N7Q_CODINE
					cCodSaf  := N7Q->N7Q_CODSAF
					cCodEnt  := N7Q->N7Q_IMPORT
					cLojEnt  := N7Q->N7Q_IMLOJA
					
					//se entidade de entrega estiver preenchida
					If !Empty(N7Q->N7Q_ENTENT)
						cEntEnt  := N7Q->N7Q_ENTENT
					Else
						cEntEnt  := N7Q->N7Q_IMPORT
					EndIf
					
					//se loja da entidade de entrega estiver preenchida
					If !Empty(N7Q->N7Q_LOJENT)	
						cLjEntE  := N7Q->N7Q_LOJENT
					Else
						cLjEntE  := N7Q->N7Q_IMLOJA
					EndIf	
					
					cLocal   := N7Q->N7Q_LOCAL 
			
					oMldNJJ:SetValue('NJJ_CODSAF',cCodSaf)
					oMldNJJ:SetValue('NJJ_CODENT',cCodEnt)
					oMldNJJ:SetValue('NJJ_LOJENT',cLojEnt)
					oMldNJJ:SetValue('NJJ_ENTENT',cEntEnt)
					oMldNJJ:SetValue('NJJ_ENTLOJ',cLjEntE)
					oMldNJJ:SetValue('NJJ_LOCAL' ,cLocal)
				EndIf  
				N7Q->(dbCloseArea())
			
				//busca do contrato informações para setar valor default na NJJ
			    dbSelectArea('NJR')
				NJR->(dbSetOrder(1))    	
				If NJR->(MsSeek(FwxFilial("NJR")+oMldN9E:GetValue("N9E_CODCTR"))) //NJR_FILIAL+NJR_CODCTR
					cTabela  := NJR->NJR_TABELA
					cTpFrete := NJR->NJR_TPFRET  
					
					oMldNJJ:SetValue('NJJ_TABELA',cTabela)
					oMldNJJ:SetValue('NJJ_TPFRET',cTpFrete)
				EndIf  
				NJR->(dbCloseArea())
				Exit
			EndIf
		Next nX
    
    //se for entrada
    ElseIf cTipo $ "1|3|5|7|9|A"
		//busca da autorização carregamento para setar valor default na NJJ
	    dbSelectArea('N8N')
		N8N->(dbSetOrder(1))    	
		If N8N->(MsSeek(FwxFilial("N8N")+oMldN9E:GetValue("N9E_CODAUT")+"1")) //N8N_FILIAL+N8N_CODIGO+N8N_TIPO
			cCodSaf  := N8N->N8N_SAFRA
	
			oMldNJJ:SetValue('NJJ_CODSAF',cCodSaf)
		EndIf  
		N8N->(dbCloseArea())

		//entrada por produção
		If cTipo == "1"
			//busca da entidade/loja para setar valor default na NJJ
		    dbSelectArea('NJ0')
			NJ0->(dbSetOrder(5))    	
			If NJ0->(MsSeek(FwxFilial("NJ0")+FWCodFil())) //NJ0_FILIAL+NJ0_CODCRP
				cCodEnt  := NJ0->NJ0_CODENT
				cLojEnt  := NJ0->NJ0_LOJENT
		
				oMldNJJ:SetValue('NJJ_CODENT',cCodEnt)
				oMldNJJ:SetValue('NJJ_LOJENT',cLojEnt)
			EndIf  
			NJ0->(dbCloseArea())
		EndIf	
    EndIf
    
    RestArea(aArea)

Return lRet

/*/{Protheus.doc} AGRA550PRD
//Retornar os valores de unidade de medida e de descrição do produto quando preencher o campo de produto.
@author brunosilva
@since 23/02/2019
@version 1.0
@param cCampo, characters, descricao
@type function
/*/
Static Function AGRA550PRD(cCampo)
	Local cRet := ""
	
    If cCampo $ "NJJ_DESPRO"
		cRet := Posicione("SB1",1,FWxFilial("SB1")+M->NJJ_CODPRO,"B1_DESC")
    endIf
    If cCampo $ "NJJ_UM1PRO"
    	cRet := Posicione("SB1",1,FWxFilial("SB1")+M->NJJ_CODPRO,"B1_UM")
    endIf
	
return cRet


/*/{Protheus.doc} AGRA550CMP
//Gatilho para os campos da NJJ a partir da autorização de carregamento.
@author brunosilva
@since 24/02/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function AGRA550CMP()
	Local lRet 		:= .T.
	Local aArea		:= GetArea()
	Local oModel	:= FwModelActive()
	Local oMldN9E 	:= oModel:GetModel('AGRA550_N9E')
	Local oMldNJJ 	:= oModel:GetModel('AGRA550_NJJ')
	
	//busca da autorização carregamento para setar valor default na NJJ
    dbSelectArea('N8N')
	N8N->(dbSetOrder(1))    	
	If N8N->(MsSeek(FwxFilial("N8N")+oMldN9E:GetValue("N9E_CODAUT"))) //N8N_FILIAL+N8N_CODIGO
		//Só preenche os campos se eles estiverem vazios.
		oMldNJJ:SetValue('NJJ_TOETAP',N8N->N8N_TOETAP)
		oMldNJJ:SetValue('NJJ_CODTRA',N8N->N8N_CODTRA)
		oMldNJJ:SetValue('NJJ_CODPRO',N8N->N8N_CODPRO)
		oMldNJJ:SetValue('NJJ_QTDAUT',N8N->N8N_QTDAUT)
	EndIf  
	N8N->(dbCloseArea())	
	
	RestArea(aArea)
return lRet