#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWEditPanel.CH'

#INCLUDE "VEIA110.CH"

/*/{Protheus.doc} VEIA110

Integração Protheus vs JDQuote

@author rubens.takahashi
@since 02/08/2019
@version 1.0

@type function
/*/
Function VEIA110()
	Local oBrowse

	Private cFilCodMar := "" // Variavel utilizada na consulta padrao da VV2

	SetKey(VK_F12,{ || Pergunte( "VEIA110" , .T. ,,,,.f.)})

	// VJJ - JD - Quote
	// VJK - JD - Itens da Cotacao
	// VJL - JD - Opcionais Equip.
	// VJO - JD - Equip. Anexos
	// VJP - JD - Cliente CKC
	oBrowse := BrowseDef()
	oBrowse:Activate()

	SetKey(VK_F12,Nil)
Return

/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()
	Local oStruVJJ := FWFormStruct( 1, 'VJJ' )
	Local oStruVJK := FWFormStruct( 1, 'VJK' )
	Local oStruVJL := FWFormStruct( 1, 'VJL' )
	//Local oStruVJN := FWFormStruct( 1, 'VJN' )
	Local oStruVJO := FWFormStruct( 1, 'VJO' )

	oStruVJK:SetProperty('VJK_CODVJJ',MODEL_FIELD_OBRIGAT,.f.)
	oStruVJK:AddField(;
		'Legenda',; // cTitulo
		'',; // cTooltip
		'LEGENDA',; // cIdField
		'C',; // cTipo
		30,; // nTamanho
		0,; // nDecimal
		,; // bValid
		,; // bWhen
		{},; // aValues
		.F.,; // lObrigat
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "VA1100493_LegendaItem()"),; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid

	oStruVJL:SetProperty('VJL_CODVJK',MODEL_FIELD_OBRIGAT,.f.)
	//oStruVJN:SetProperty('VJN_CODVJK',MODEL_FIELD_OBRIGAT,.f.)

	oStruVJO:SetProperty('VJO_CODVJJ',MODEL_FIELD_OBRIGAT,.f.)
	oStruVJO:AddField(;
		'Legenda',; // cTitulo
		'',; // cTooltip
		'LEGENDA',; // cIdField
		'C',; // cTipo
		30,; // nTamanho
		0,; // nDecimal
		,; // bValid
		,; // bWhen
		{},; // aValues
		.F.,; // lObrigat
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "VA1100513_LegendaUsado()"),; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid

	oModel := MPFormModel():New('VEIA110' )
	oModel:AddFields('MODEL_VJJ', /*cOwner*/, oStruVJJ , /* <bPre > */ , /* <bPost > */ , /* <bLoad> */ )
	oModel:AddGrid(  'MODEL_VJK', 'MODEL_VJJ',oStruVJK, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* bLoad */ )
	oModel:AddGrid(  'MODEL_VJL', 'MODEL_VJK',oStruVJL, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* bLoad */ )
	//oModel:AddGrid(  'MODEL_VJN', 'MODEL_VJK',oStruVJN, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* bLoad */ )
	oModel:AddGrid(  'MODEL_VJO', 'MODEL_VJJ',oStruVJO, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* bLoad */ )

	oModel:SetDescription( STR0002 ) // JDQuote - Cotação
	oModel:GetModel( 'MODEL_VJJ' ):SetDescription( STR0003 ) // 'Dados da Cotação'
	oModel:GetModel( 'MODEL_VJK' ):SetDescription( STR0004 ) // "Dados dos itens da cotação"
	oModel:GetModel( 'MODEL_VJL' ):SetDescription( STR0005 ) // "Dados dos opcionais dos itens da cotação"
	//oModel:GetModel( 'MODEL_VJN' ):SetDescription( "Dados dos ajustes dos equipamentos da cotação" ) //
	oModel:GetModel( 'MODEL_VJJ' ):SetDescription( STR0006 ) // 'Dados de equipamentos usados'

	oModel:SetRelation('MODEL_VJK', { { 'VJK_FILIAL' , 'xFilial("VJK")' } , { 'VJK_CODVJJ' , 'VJJ_CODIGO' } } , 'VJK_FILIAL+VJK_CODVJJ' )
	oModel:SetRelation('MODEL_VJL', { { 'VJL_FILIAL' , 'xFilial("VJL")' } , { 'VJL_CODVJK' , 'VJK_CODIGO' } } , 'VJL_FILIAL+VJL_CODVJK' )
	//oModel:SetRelation('MODEL_VJN', { { 'VJN_FILIAL' , 'xFilial("VJN")' } , { 'VJN_CODVJK' , 'VJK_CODIGO' } } , 'VJN_FILIAL+VJN_CODVJK' )
	oModel:SetRelation('MODEL_VJO', { { 'VJO_FILIAL' , 'xFilial("VJO")' } , { 'VJO_CODVJJ' , 'VJJ_CODIGO' } } , 'VJO_FILIAL+VJO_CODVJJ' )

	oModel:GetModel('MODEL_VJK'):SetOptional( .T. )
	oModel:GetModel('MODEL_VJL'):SetOptional( .T. )
	//oModel:GetModel('MODEL_VJN'):SetOptional( .T. )
	oModel:GetModel('MODEL_VJO'):SetOptional( .T. )

	oModel:AddRules('MODEL_VJK', 'VJK_MODVEI', 'MODEL_VJK', 'VJK_CODMAR', 3)
	oModel:AddRules('MODEL_VJK', 'VJK_SEGMOD', 'MODEL_VJK', 'VJK_MODVEI', 3)

	oModel:InstallEvent("PADRAO",, VEIA110EVDEF():New())

Return oModel

/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()

	Local oView
	Local oModel := FWLoadModel( 'VEIA110' )
	Local oStruVJJ := FWFormStruct( 2, 'VJJ' )
	Local oStruVJK := FWFormStruct( 2, 'VJK' )
	Local oStruVJL := FWFormStruct( 2, 'VJL' )
//	Local oStruVJN := FWFormStruct( 2, 'VJN' )
	Local oStruVJO := FWFormStruct( 2, 'VJO' )

	oStruVJK:RemoveField('VJK_CODIGO')
	oStruVJK:RemoveField('VJK_CODVJJ')
	oStruVJK:SetProperty('VJK_INTEGR', MVC_VIEW_CANCHANGE , .F. )
	oStruVJK:SetProperty('VJK_CODMAR', MVC_VIEW_CANCHANGE , .F. )
	oStruVJK:SetProperty('VJK_MODVEI', MVC_VIEW_CANCHANGE , .F. )
	oStruVJK:SetProperty('VJK_SEGMOD', MVC_VIEW_CANCHANGE , .F. )
	oStruVJK:AddField( 'LEGENDA','01',' ','Legenda',, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, )

	oStruVJL:RemoveField('VJL_CODIGO')
	oStruVJL:RemoveField('VJL_CODVJK')

//	oStruVJN:RemoveField('VJN_CODIGO')
//	oStruVJN:RemoveField('VJN_CODVJK')

	oStruVJO:RemoveField('VJO_CODIGO')
	oStruVJO:RemoveField('VJO_CODVJJ')
	oStruVJO:AddField( 'LEGENDA','01',' ','Legenda',, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField('VIEW_VJJ', oStruVJJ, 'MODEL_VJJ' )
	oView:AddGrid( 'VIEW_VJK', oStruVJK, 'MODEL_VJK' )
	oView:AddGrid( 'VIEW_VJL', oStruVJL, 'MODEL_VJL' )
//	oView:AddGrid( 'VIEW_VJN', oStruVJN, 'MODEL_VJN' )
	oView:AddGrid( 'VIEW_VJO', oStruVJO, 'MODEL_VJO' )

	oView:CreateFolder( 'TELA_FOLDER' )
	oView:AddSheet('TELA_FOLDER','ABA_COTACAO',STR0007 ) // 'Cotação'
	oView:AddSheet('TELA_FOLDER','ABA_EQUIP'  ,STR0008 ) // 'Equipamentos'
	oView:AddSheet('TELA_FOLDER','ABA_USADO'  ,STR0009 ) // 'Usados'

	oView:CreateHorizontalBox( 'TELA_VJJ', 100, , , 'TELA_FOLDER', 'ABA_COTACAO')

	oView:CreateHorizontalBox( 'TELA_VJK', 30 , , , 'TELA_FOLDER', 'ABA_EQUIP')
	oView:CreateHorizontalBox( 'TELA_VJL', 70 , , , 'TELA_FOLDER', 'ABA_EQUIP')

	oView:CreateHorizontalBox( 'TELA_VJO', 100 , , , 'TELA_FOLDER', 'ABA_USADO')

	oView:SetOwnerView( 'VIEW_VJJ', 'TELA_VJJ' )
	oView:SetOwnerView( 'VIEW_VJK', 'TELA_VJK' )
	oView:SetOwnerView( 'VIEW_VJL', 'TELA_VJL' )

	oView:SetOwnerView( 'VIEW_VJO', 'TELA_VJO' )

	oView:EnableTitleView('VIEW_VJK', STR0008 ) // 'Equipamentos'
	oView:EnableTitleView('VIEW_VJL', STR0011 ) // 'Opcionais do Equipamento'
	oView:EnableTitleView('VIEW_VJO', STR0009 ) // 'Usados'

Return oView

/*/{Protheus.doc} MenuDef
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MenuDef()

	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0013 ACTION 'VIEWDEF.VEIA110' OPERATION 2 ACCESS 0 // 'Visualizar' 
	ADD OPTION aRotina TITLE STR0014 ACTION 'VA1100013_Importar' OPERATION 3 ACCESS 0 // 'Importar' 
	ADD OPTION aRotina TITLE STR0015 ACTION 'VA1100313_ImportarMasters ' OPERATION 3 ACCESS 0 // 'Importar Masters'
	ADD OPTION aRotina TITLE STR0016 ACTION 'VA1100073_CriarOportunidade' OPERATION 4 ACCESS 0 // 'Criar Oportunidade'
	ADD OPTION aRotina TITLE STR0017 ACTION 'VA1100283_TelaCriarAtendimento' OPERATION 4 ACCESS 0 // 'Criar Atendimento'
	ADD OPTION aRotina TITLE STR0018 ACTION 'VA1100023_Atualizar' OPERATION 4 ACCESS 0 // 'Atualizar' 
	ADD OPTION aRotina TITLE STR0019 ACTION 'VA1100223_RelacionaModelo' OPERATION 4 ACCESS 0 // 'Relaciona Modelo'
	ADD OPTION aRotina TITLE STR0020 ACTION 'VA1100393_RelacionaOportunidade' OPERATION 4 ACCESS 0 // 'Relaciona Oportunidade'
	ADD OPTION aRotina TITLE STR0021 ACTION 'VA1100533_RelacionaAtendimento' OPERATION 4 ACCESS 0 // 'Relaciona Atendimento'
	ADD OPTION aRotina TITLE STR0022 ACTION 'VA1100143_AlterarSenha' OPERATION 3 ACCESS 0 // 'Alterar Senha'
	ADD OPTION aRotina TITLE STR0023 ACTION 'VIEWDEF.VEIA110' OPERATION 5 ACCESS 0 // 'Excluir' 
	ADD OPTION aRotina TITLE STR0024 ACTION 'VIEWDEF.VEIA110' OPERATION 8 ACCESS 0 // 'Imprimir' 
	ADD OPTION aRotina TITLE STR0086 ACTION 'VA1100643_LimparToken' OPERATION 3 ACCESS 0 // "Limpar Token"
	//ADD OPTION aRotina TITLE 'getPO'                ACTION 'VA1100203_getPO' OPERATION 4 ACCESS 0
	//ADD OPTION aRotina TITLE 'Importar Manual'      ACTION 'VA1100193_ImportarManual' OPERATION 3 ACCESS 0
Return aRotina

/*/{Protheus.doc} BrowseDef
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function BrowseDef()

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VJJ')
	oBrowse:SetDescription( STR0001 ) // 'Cadastro de Cotação do JDQuote'

	oBrowse:SetBlkBackColor( { || IIf( VJJ_DELETE == "1" , CLR_HGRAY , NIL ) } )

	If __cUserId <> "000000" .and. VAI->(ColumnPos("VAI_JDQOUT")) <> 0
		VAI->(DBSetOrder(4))
		VAI->(DBSeek(xFilial("VAI")+__cUserId))
		If VAI->VAI_JDQOUT $ " /0"
			oBrowse:addFilter(STR0025,"VJJ_SALID = '" + AllTrim(VAI->VAI_FABUSR) + "'", .t., .t.,,,,'VEIA110_VEND'  ) // "Vendedor"
		EndIf
	EndIf

Return oBrowse

/*/{Protheus.doc} VA1100013_Importar
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cAlias, characters, description
@param nReg, numeric, description
@param nOpc, numeric, description
@type function
/*/
Function VA1100013_Importar(cAlias, nReg, nOpc)

	Local nPos
	Local aRetorno := {}

	aRetorno := VA1100053_ListaQuote("COTACAO")
	If Len(aRetorno) == 0
		Return
	End

	VA1100363_ProcessaImportacao(aRetorno)
Return

/*/{Protheus.doc} VA1100023_Atualizar
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cAlias, characters, description
@param nReg, numeric, description
@param nOpc, numeric, description
@type function
/*/
Function VA1100023_Atualizar(cAlias, nReg, nOpc)
	VA1100363_ProcessaImportacao({{ VJJ->VJJ_ID , VJJ->VJJ_TIPO }})
Return

/*/{Protheus.doc} VA1100033_StruGridQuote
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cTipoCotacao, characters, description
@type function
/*/
Function VA1100033_StruGridQuote(cTipoCotacao)

	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddSelect('','QUOTESEL')

	oRetorno:AddField( { ;
		{ "cIdField" , "ID" }  , { "cTitulo"  , STR0007 } ,; //"Cotação"
		{ "cTipo"    , "N" }   , { "nTamanho" , 12 } , { "cPicture" , "@E 999999999999"} ,;
		{ "lCanChange" , .f. } , { "lVirtual" , .t. } } )

	oRetorno:AddField( { ;
		{ "cIdField" , "NOME" } , { "cTitulo"  , STR0027 } ,; //"Nome da Cotação"
		{ "cTipo"    , "C" }    , { "nTamanho" , 50 } , { "cPicture" , "@!"} ,;
		{ "lCanChange" , .f. }  , { "lVirtual" , .t. } } )

	If cTipoCotacao == "COTACAO"
		oRetorno:AddField( { ;
			{ "cIdField" , "CLIENTE" } , { "cTitulo"  , STR0028 } ,; // "Cliente"
			{ "cTipo"    , "C" }    , { "nTamanho" , 100 } , { "cPicture" , "@!"} ,;
			{ "lCanChange" , .f. }  , { "lVirtual" , .t. } } )

		oRetorno:AddField( { ;
			{ "cIdField" , "TOTAL" } , { "cTitulo"  , STR0029 } ,; // "Total"
			{ "cTipo"    , "N" }     , { "nTamanho" , 12 } , { "nDecimal" , 02 } , { "cPicture" , "@E 999,999,999.99"} ,;
			{ "lCanChange" , .f. }   , { "lVirtual" , .t. } } )

		oRetorno:AddField( { ;
			{ "cIdField" , "MODELO" } , { "cTitulo"  , STR0030 } ,; // "Modelo"
			{ "cTipo"    , "C" }    , { "nTamanho" , 100 } , { "cPicture" , "@!"} ,;
			{ "lCanChange" , .f. }  , { "lVirtual" , .t. } } )

		oRetorno:AddField( { ;
			{ "cIdField" , "STATUS" } , { "cTitulo"  , STR0031 } ,; // "Status"
			{ "cTipo"    , "C" }    , { "nTamanho" , 30 } , { "cPicture" , "@!"} ,;
			{ "lCanChange" , .f. }  , { "lVirtual" , .t. } } )
	EndIf

	oRetorno:AddField( { ;
		{ "cIdField" , "CRIACAO" } , { "cTitulo"  , STR0032 } ,; // "Data Criação"
		{ "cTipo"    , "D" }       , { "nTamanho" , 8 } , { "cPicture" , ""} ,;
		{ "lCanChange" , .t. }     , { "lVirtual" , .t. } } )

	oRetorno:AddField( { ;
		{ "cIdField" , "VENCIMENTO" } , { "cTitulo"  , STR0033 } ,; // "Data Vencimento"
		{ "cTipo"    , "D" }       , { "nTamanho" , 8 } , { "cPicture" , ""} ,;
		{ "lCanChange" , .t. }     , { "lVirtual" , .t. } } )

Return oRetorno

/*/{Protheus.doc} VA1100363_ProcessaImportacao
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param aListQuote, array, description
@type function
/*/
Function VA1100363_ProcessaImportacao(aListQuote)
	
	Local lRetImp := .t.

	Private lAbortPrint := .f. // Variavel utilizada pelo Processa
		
	Processa( {|| lRetImp := VA1100043_ImportarQuote(aListQuote, .f. ,, .t.) }, STR0034 + "...", STR0035 + "...",.t.) // "Aguarde" // Importando/Atualizando cotações
	
	If lRetImp
		MsgInfo(STR0036) // "Importação/Atualização finalizada."
	EndIf

Return .t.

/*/{Protheus.doc} VA1100043_ImportarQuote
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param aListQuote, array, description
@param lSchedule, logical, description
@param oTProces, object, description
@param lSincPedidoVenda, logical, Indica se deve atualizar pedido de venda
@type function
/*/
Function VA1100043_ImportarQuote(aListQuote, lSchedule, oTProces, lSincPedidoVenda)

	Local oJDQuote   := VEJDQuoteMaintainQuote():New()
	Local oJDQuotePO := VEJDQuotePODataService():New()
	Local nPosQuote
	Local oModel110 := FWLoadModel( 'VEIA110' )

	Local cModelVJJ := "MODEL_VJJ"
	Local cModelVJK := "MODEL_VJK"
	Local cModelVJO := "MODEL_VJO"

	Local lProcessado := .f.

	Local nPosEquip
	Local nPosTradeIn
	Local nPosFil
	Local nPosCanc

	Local cIDQuote := ""

	Local cCodVJJ

	Local oAuxFil := DMS_FilialHelper():New()
	Local aFiliais := oAuxFil:GetAllFilEmpresa(.t.)
	Local aMapFilDealerCode := {}
	Local nTotListQuote
	Local nRecVJJ := 0
	Local aEquipProc
	Local aUsadoProc

	Local lDelete := .f.
	Local lDeletePO := .f.
	Local aCancOportAtend := {}
	Local aCancAtend := {}
	Local cOportMotCan
	Local cAtendMotCan

	Local lRetorno := .t.

	Local oSQLHelper

	Private lcriaSA1Automatico

	Pergunte("VEIA110",.f.,,,,.f.)    
	lcriaSA1Automatico := (MV_PAR01 == 1)
	lCriaOportunidade := (MV_PAR04 == 2)
	lCriaAtendimento  := (MV_PAR04 == 3)
	cFaseOportunidade := MV_PAR05
	lCancelaOpoAtend  := (MV_PAR06 == 1)
	cOportMotCan      := MV_PAR07
	cAtendMotCan      := MV_PAR08
	lCKCValidaCliente := MV_PAR09 == 1

	For nPosFil := 1 to Len(aFiliais)
		AADD( aMapFilDealerCode , { aFiliais[nPosFil] , GetNewPar("MV_MIL0005","", aFiliais[nPosFil]) })
	Next nPosFil

	nTotListQuote := Len(aListQuote)
	If lSchedule == .f.
		If oTProces == NIL
			ProcRegua(nTotListQuote)
		Else
			oTProces:SetRegua1(nTotListQuote)
		EndIf
	EndIf

	For nPosQuote := 1 to nTotListQuote

		If lSchedule == .f.
			If oTProces == NIL
				If lAbortPrint
					Exit
				EndIf

				IncProc( STR0007 + ": " + cValToChar(aListQuote[nPosQuote, 1 ]) ) // "Cotação"
			Else
				oTProces:IncRegua1(STR0007 + ": " + cValToChar(aListQuote[nPosQuote, 1 ])) // "Cotação"
			EndIf
		EndIf

		lProcessado := VA1100213_ConsultaWebService( aListQuote[nPosQuote, 1 ] ,@oJDQuote, @oJDQuotePO )
		If ! lProcessado
			If lSchedule == .f.
				MsgInfo(STR0038 + CRLF + CRLF + STR0007 + ": " + cValToChar(aListQuote[nPosQuote, 1 ]) ) // "Não foi possível consultar dados do WebService." // "Cotação"
			EndIf
			Loop
		EndIf

		If ! Empty(oJDQuote:aResponse[1]:oErrorMessage:errorMessage)
			MsgInfo(STR0039 + CRLF + CRLF + ; // "Não é possível importar/atualizar a cotação selecionada."
				STR0007 + ": " + cValToChar(aListQuote[nPosQuote, 1 ]) + CRLF + ; // "Cotação"
				STR0040 + ": " + cValToChar(oJDQuote:aResponse[1]:oErrorMessage:errorId)  + CRLF + ; // "Código do Erro"
				STR0041 + ": " + oJDQuote:aResponse[1]:oErrorMessage:errorMessage ) // "Mensagem do Erro
			Loop
		EndIf

		lJaimportada := VA1100123_JaImportada(aListQuote[nPosQuote, 1 ], @nRecVJJ)
		lDelete := .f.
		lDeletePO := .f.
		aCancOportAtend := {}
		aCancAtend := {}
		If lJaimportada
			VJJ->(dbGoTo(nRecVJJ))
		EndIf

		If oJDQuote:aResponse[1]:quoteId == 0
			If lJaimportada .and. VA1100483_CotacaoDeletada(oJDQuote, VJJ->VJJ_DTMOD, VJJ->VJJ_ID)
				lDelete := .t.
			Else
				MsgInfo(STR0042 + CRLF + CRLF + ; // "Não houve resposta com detalhes da cotação selecionada."
					STR0007 + ": " + cValToChar(aListQuote[nPosQuote, 1 ]) ) // "Cotação"
				Loop
			EndIf
		EndIf

		If lJaimportada
			oModel110:SetOperation( MODEL_OPERATION_UPDATE )
		Else
			oModel110:SetOperation( MODEL_OPERATION_INSERT )
		EndIf
		lRet := oModel110:Activate()
		If ! lRet
			Alert("Erro")
			Loop
		EndIf

		Begin Transaction
		Begin Sequence

			If lDelete
				oModelVJJ := oModel110:GetModel( cModelVJJ )
				SetModelVal( oModelVJJ , 'VJJ_DELETE' , "1" )

				If lCancelaOpoAtend
					For nPosEquip := 1 to oModelVJK:Length()
						If oModelVJK:GetValue("VJK_ID", nPosEquip) <> 0 .and. oModelVJK:GetValue("VJK_DELETE", nPosEquip) <> "1"
							AADD( aCancOportAtend , nPosEquip )
						EndIf
					Next nPosEquip
				EndIF

			Else

				oAuxResponse := oJDQuote:aResponse[1]

				If ! (cIDQuote $ oAuxResponse:oQuoteStatus:id) .and. ! OFIOA560VL("072", oAuxResponse:oQuoteStatus:id,,.f.)
					cIDQuote += oAuxResponse:oQuoteStatus:id + "/"
					OFIOA560ADD("072", oAuxResponse:oQuoteStatus:id, oAuxResponse:oQuoteStatus:description)
				EndIf

				oModelVJJ := oModel110:GetModel( cModelVJJ )

				SetModelVal( oModelVJJ , 'VJJ_TIPO'   , aListQuote[nPosQuote,2] )
				SetModelVal( oModelVJJ , 'VJJ_ID'     , oAuxResponse:quoteId )
				SetModelVal( oModelVJJ , 'VJJ_QNAME'  , oAuxResponse:quoteName )
				SetModelVal( oModelVJJ , 'VJJ_DTCREA' , oAuxResponse:creationDate )
				SetModelVal( oModelVJJ , 'VJJ_DTEXPE' , oAuxResponse:expirationDate )
				SetModelVal( oModelVJJ , 'VJJ_DEALER' , oAuxResponse:dealerAccountNumber )

				nPosFil := aScan(aMapFilDealerCode, { |x| x[2] == oAuxResponse:dealerAccountNumber })
				If nPosFil <> 0
					SetModelVal( oModelVJJ , 'VJJ_FILDEA' , aMapFilDealerCode[nPosFil,1] )
				EndIf

				SetModelVal( oModelVJJ , 'VJJ_DTMOD'  , oAuxResponse:lastDateModifiedDate )
				SetModelVal( oModelVJJ , 'VJJ_HRMOD'  , oAuxResponse:lastTimeModifiedDate )
				SetModelVal( oModelVJJ , 'VJJ_NOTES'  , HtmlToTXT(oAuxResponse:customerNote) )
				SetModelVal( oModelVJJ , 'VJJ_TOTAL'  , oAuxResponse:totalNetTradeValue )
				SetModelVal( oModelVJJ , 'VJJ_BALDUE' , oAuxResponse:balanceDue )
				SetModelVal( oModelVJJ , 'VJJ_NETPRO' , oAuxResponse:netProceeds )

				SetModelVal( oModelVJJ , 'VJJ_QSTATU' , oAuxResponse:oQuoteStatus:id )

				SetModelVal( oModelVJJ , 'VJJ_QTYPE' , oAuxResponse:oQuoteType:id )

				SetModelVal( oModelVJJ , 'VJJ_SALID'  , oAuxResponse:oSalesPerson:deereUserId )
				SetModelVal( oModelVJJ , 'VJJ_SALNAM' , oAuxResponse:oSalesPerson:fullName  )

				lDeletePO := ( oModelVJJ:GetValue("VJJ_POID") <> 0 .and. Len(oJDQuotePO:aResponse) == 0 )

				SetModelVal( oModelVJJ , 'VJJ_POID'   , oAuxResponse:oPODetails:poNumber )

				If aListQuote[nPosQuote,2] == "2" // Cotacao
					VA1100153_Customer(oModel110, oModelVJJ, oAuxResponse:oCustomer, lSchedule)
				EndIf

 				If oModelVJJ:GetValue("VJJ_DELETE") == "1"
					// TO-DO
					// Verificar o que fazer quando a Cotacao ja tinha vinculado Oportundiade / Atendimento e a mesma foi restaurada no portal
				EndIf
				SetModelVal( oModelVJJ , 'VJJ_DELETE' , "0" )


				aEquipProc := {} // Controla os equipamentos processados para verificar quais equipamentos foram excluidos da Cotação

				oModelVJK := oModel110:GetModel( cModelVJK)
				For nPosEquip := 1 to Len(oAuxResponse:aEquipment)

					oEquipment := oAuxResponse:aEquipment[nPosEquip]

					If oModelVJK:SeekLine({{ "VJK_ID" , oEquipment:id }},.f.,.t.)
					Else
						If oModelVJK:Length() == 1 .and. oModelVJK:GetValue("VJK_ID") == 0
						Else
							oModelVJK:AddLine()
						EndIf
					EndIf

					SetModelVal( oModelVJK , 'VJK_ITEM' , StrZero(nPosEquip,2) )

					SetModelVal( oModelVJK , 'VJK_ID'     , oEquipment:id ) 					// ID - N
					SetModelVal( oModelVJK , 'VJK_MAKENA' , oEquipment:makeName )			//
					SetModelVal( oModelVJK , 'VJK_MODNAM' , oEquipment:modelName ) 	 	//
					SetModelVal( oModelVJK , 'VJK_STATUS' , oEquipment:status ) 			//
					SetModelVal( oModelVJK , 'VJK_HOURMR' , oEquipment:machineHours ) 	// Horímetro - C
					SetModelVal( oModelVJK , 'VJK_SERIAL' , oEquipment:serialNumber ) 	// Núm. Serial - C
					SetModelVal( oModelVJK , 'VJK_LIST'   , oEquipment:listPrice ) 		// Preço - N
					SetModelVal( oModelVJK , 'VJK_COST'   , oEquipment:costPrice ) 		// Custo - N
					SetModelVal( oModelVJK , 'VJK_PRICE'  , oEquipment:totalEquipmentSellingPrice ) 		// Custo - N
					SetModelVal( oModelVJK , 'VJK_DELETE' , "0" ) // Marca Item como deletado

					AADD( aEquipProc , oEquipment:id )

					If ! Empty(oEquipment:serialNumber)

					EndIf

				Next nPosEquip

				For nPosEquip := 1 to oModelVJK:Length()
					If oModelVJK:GetValue("VJK_ID", nPosEquip) <> 0 .and. oModelVJK:GetValue("VJK_DELETE", nPosEquip) <> "1" .and. aScan(aEquipProc, oModelVJK:GetValue("VJK_ID", nPosEquip)) == 0

						oModelVJK:GoLine(nPosEquip)
						SetModelVal( oModelVJK , 'VJK_ITEM', " " ) // Limpa o numero do item
						SetModelVal( oModelVJK , 'VJK_DELETE', "1" ) // Marca Item como deletado

						If lCancelaOpoAtend
							AADD( aCancOportAtend , nPosEquip )
						EndIf

					EndIF
				Next nPosEquip

				////////////////////////////////////////
				aUsadoProc := {}
				oModelVJO := oModel110:GetModel( cModelVJO)
				For nPosTradeIn := 1 to Len(oAuxResponse:aTradeIns)

					oTradeIn := oAuxResponse:aTradeIns[nPosTradeIn]

					If oModelVJO:SeekLine({{ "VJO_ID" , oTradeIn:id }},.f.,.t.)
					Else
						If oModelVJO:Length() == 1 .and. oModelVJO:GetValue("VJO_ID") == 0
						Else
							oModelVJO:AddLine()
						EndIf
					EndIf

					SetModelVal( oModelVJO , 'VJO_ID'     , oTradeIn:id                     )
					SetModelVal( oModelVJO , 'VJO_MAKENA' , oTradeIn:makeName               )
					SetModelVal( oModelVJO , 'VJO_MODNAM' , oTradeIn:modelName              )
					SetModelVal( oModelVJO , 'VJO_SERIAL' , oTradeIn:serialNumber           )
					SetModelVal( oModelVJO , 'VJO_YEARMA' , oTradeIn:year                   )
					SetModelVal( oModelVJO , 'VJO_DESCR'  , HtmlToTXT(oTradeIn:description) )
					SetModelVal( oModelVJO , 'VJO_HOURMR' , oTradeIn:hourMeterReading       )
					SetModelVal( oModelVJO , 'VJO_TAG'    , oTradeIn:tagNumber              )
					SetModelVal( oModelVJO , 'VJO_NPRICE' , oTradeIn:netTradeValue          )
					SetModelVal( oModelVJO , 'VJO_DELETE' , "0" ) // Marca Item como deletado

					AADD( aUsadoProc , oTradeIn:id )

				Next nPosTradeIn

				For nPosTradeIn := 1 to oModelVJO:Length()
					If oModelVJO:GetValue("VJO_ID", nPosTradeIn) <> 0 .and. oModelVJO:GetValue("VJO_DELETE", nPosTradeIn) <> "1" .and. aScan(aUsadoProc, oModelVJO:GetValue("VJO_ID", nPosTradeIn)) == 0
						oModelVJO:GoLine(nPosTradeIn)
						SetModelVal( oModelVJO , 'VJO_DELETE', "1" ) // Marca Item como deletado
					EndIF
				Next nPosTradeIn

			EndIf

			cCodVJJ := oModelVJJ:GetValue("VJJ_CODIGO")

			If lSincPedidoVenda
				If lDelete .or. lDeletePO
					VA1100583_DeletarPedidoVenda(cCodVJJ)
				ElseIf Len(oJDQuotePO:aResponse) > 0
					VA1120083_PedidoVenda(oJDQuotePO, cCodVJJ, .f., .f.)
				EndIF
			EndIf

			If oModelVJJ:GetValue("VJJ_POID") <> 0
				lRet := VA1100593_SincVJKCotacaoPedido(oModelVJJ:GetValue("VJJ_POID"), cCodVJJ, oModel110)
				If ! lRet
					VA1100623_SetError("VA1100593_SincVJKCotacaoPedido", oModel110:GetErrorMessage() )
					Break
				EndIf
			EndIf

			If oModelVJJ:isModified() .or. oModelVJK:isModified() .or. oModelVJO:isModified()
			
				SetModelVal( oModelVJJ , 'VJJ_DTSINC' , Date() )
				SetModelVal( oModelVJJ , 'VJJ_HRSINC' , StrTran(Time(),":") )
				
				If ( lRet := oModel110:VldData() )
					lRet := oModel110:CommitData()
				EndIf

				If ! lRet

					// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
					aErro   := oModel110:GetErrorMessage()
					VA1100623_SetError("VA1100043_ImportarQuote", aErro)

					Break

				EndIf

				// Processa itens cancelados para verificar se será necessário cancelar oportunidade / atendimento
				For nPosEquip := 1 to Len(aCancOportAtend)
					oModelVJK:GoLine( aCancOportAtend[nPosEquip] )

					If ! Empty(oModelVJK:GetValue("VJK_NUMTRA"))
						// No caso dos atendimento, será necessário processar para verificar se será cancelado um item do atendimento ou o atendimento completo.
						// Quando o cancelamento for de um item do atendimento, a rotina será executada excluindo um item do atendimento.
						// Quando todos os itens do atendimento forem excluidos, o atendimento será cancelado com o motivo de cancelamento informado no F12 da rotina.
						nPosCanc := aScan( aCancAtend , { |x| x[1] == oModelVJK:GetValue("VJK_FILTRA") .and. x[2] == oModelVJK:GetValue("VJK_NUMTRA") })
						If nPosCanc == 0
							AADD( aCancAtend , { oModelVJK:GetValue("VJK_FILTRA"), oModelVJK:GetValue("VJK_NUMTRA") , {oModelVJK:GetValue("VJK_ITETRA")} })
						Else
							AADD( aCancAtend[nPosCanc,3] , oModelVJK:GetValue("VJK_ITETRA") )
						EndIf
					ElseIf ! Empty(oModelVJK:GetValue("VJK_CODOPO"))
						VA1100233_CancelaInteresse(oModelVJK, cOportMotCan)
					EndIF

				Next nPosEquip
				If Len(aCancAtend) > 0 
					For nPosCanc := 1 to Len(aCancAtend)
						VA1100243_CancelaAtendimento(oModelVJK, cAtendMotCan, aCancAtend[nPosCanc])
					Next nPosCanc
				EndIf

				If lCriaOportunidade .or. lCriaAtendimento

					oModel110:DeActivate()

					VJJ->(dbSetOrder(1))
					VJJ->(dbSeek(FWxFilial("VJJ") + cCodVJJ ))
					VJK->(dbGoTop())
					
					oModel110:SetOperation( MODEL_OPERATION_UPDATE )
					oModel110:Activate()

					If lCriaOportunidade
						VA1100293_GravarVDL(oModel110, .f., cFaseOportunidade)
					EndIf

					If lCriaAtendimento
						If VA1100573_CriarAtendimento(oModel110, .t.)
							If ( lRet := oModel110:VldData() )
								lRet := oModel110:CommitData()
							EndIf
						EndIf
						If ! lRet
							aErro   := oModel110:GetErrorMessage()
							VA1100623_SetError("VA1100043_ImportarQuote", aErro)

							Break
						EndIf
					EndIf

				EndIf

			EndIf


		Recover
			DisarmTransaction()
			RollbackSx8()
			MsUnlockAll()

			If nTotListQuote == 1
				MostraErro()
				lRetorno := .f.
			EndIf

		End Sequence

		End Transaction

		DbSelectArea("VJJ")

		// Desativamos o Model
		oModel110:DeActivate()

	Next nPosQuote

	// Quando sincroniza pedido de venda, atualiza a descricao dos opcionais gerados pela importacao do CGPoll
	If lSincPedidoVenda
		oSQLHelper := DMS_SQLHelper():New()
		
		cQuery := ;
			"UPDATE " + RetSQLName("VJV") +;
				" SET VJV_DESOPC = (" +;
					oSQLHelper:TOPFunc("SELECT VJL_DESC FROM " + RetSQLName("VJL") + " VJL WHERE " + oSQLHelper:CompatFunc("SUBSTR") + "(VJL_CODE,1,5) = VJV_CODOPC AND VJL.D_E_L_E_T_ = ' '", 1) +;
				") " +;
			"WHERE EXISTS (SELECT VJL.R_E_C_N_O_ FROM " + RetSQLName("VJL") + " VJL WHERE " + oSQLHelper:CompatFunc("SUBSTR") + "(VJL_CODE,1,5) = VJV_CODOPC AND VJL.D_E_L_E_T_ = ' ')"

		If TCSQLExec(cQuery) < 0
			MsgInfo(STR0043 + CRLF + CRLF + STR0045 + ": " + tcSQLError(),STR0044) // "Erro ao atualizar descricao dos opcionais." // Atenção
		EndIf

	EndIf
	//

Return lRetorno

/*/{Protheus.doc} VA1100053_ListaQuote
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cTipoCotacao, characters, description
@type function
/*/
Function VA1100053_ListaQuote(cTipoCotacao)

	Local oBkpModel := FWModelActive()
	Local oBkpView := FWViewActive()

	Local aRetorno := {}

	Local oStruParQuote
	Local oStruGridQuote

	Default cTipoCotacao := "COTACAO"

	Private oModelLQ
	Private oViewLQ

	Private lMarcarDesmarcar := .f.

	oStruParQuote := VA1100063_StruParQuote(cTipoCotacao)
	oStruGridQuote := VA1100033_StruGridQuote(cTipoCotacao)

	oModelLQ := VA1100103_ModelConsQuote(oStruParQuote, oStruGridQuote)
	oViewLQ := VA1100113_ViewConsQuote(oModelLQ, oStruParQuote, oStruGridQuote)

	FWModelActive(oModelLQ)
	FWViewActive(oViewLQ)

	If cTipoCotacao == "MASTER"
		oModelLQ:SetOperation(MODEL_OPERATION_UPDATE)
		oModelLQ:Activate()
		oModelLQ:SetValue("PARAMETROS", "CRIADAPOR", "2")
	EndIf

	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0046 + " - JDQuote") // 
	oExecView:setModel(oModelLQ)
	oExecView:setView(oViewLQ)
	oExecView:setOK( { |oModelLQ| VA1100133_OkListaQuote(oModelLQ, @aRetorno, cTipoCotacao) })
	oExecView:setCancel( { || .T. } )
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)

	FWModelActive(oBkpModel)
	FWViewActive(oBkpView)

Return aRetorno

/*/{Protheus.doc} VA1100063_StruParQuote
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cTipoCotacao, characters, description
@type function
/*/
Function VA1100063_StruParQuote(cTipoCotacao)

	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddField( { ;
		{ "cIdField" , "DATAINI" } , { "cTitulo"  , STR0047 } ,; // "Data Inicial"
		{ "cTipo"    , "D" }       , { "nTamanho" , 8 } , { "cPicture" , ""} ,;
		{ "lCanChange" , .t. }     , { "lVirtual" , .t. } } )

	oRetorno:AddField( { ;
		{ "cIdField" , "DATAFIM" } , { "cTitulo"  , STR0048 } ,; // "Data Final"
		{ "cTipo"    , "D" }           , { "nTamanho" , 8 } , { "cPicture" , ""} ,;
		{ "lCanChange" , .t. }         , { "lVirtual" , .t. } } )

	oRetorno:AddField( { ;
		{ "cIdField" , "VENCIDAS" } , { "cTitulo"  , STR0049 } ,; // "Exibir Vencidas"
		{ "cTipo"    , "L" }         , { "nTamanho" , 1 } , { "cPicture" , ""} ;
		} )

	Do Case
	Case cTipoCotacao == "COTACAO"
		oRetorno:AddField( { ;
			{ "cIdField" , "EXPIRADAS" } , { "cTitulo"  , STR0050 } ,; // "Exibir Expiradas"
			{ "cTipo"    , "L" }         , { "nTamanho" , 1 } , { "cPicture" , ""} ;
			} )

	Case cTipoCotacao == "MASTER"
		// Valor: 1
		// Objetivo: Masters criadas pela Companhia ( Acredito que não temos isso no Brasil hoje, talvez com algum usuário que tenha maior permissão aqui dentro )
		//
		// Valor: 2
		// Objetivo: Masters criadas pelos Concessionários – 100% das masters criadas hoje no JDQuote2 Brasil.
		//Conout(" ")
		//Conout(cValToChar(FWBuildFeature( STRUCT_FEATURE_INIPAD, "'2'") ))
		//Conout(" ")

		oRetorno:AddField( { ;
			{ "cIdField" , "CRIADAPOR" } , { "cTitulo"  , STR0051 } ,; // "Criada Por"
			{ "cTipo"    , "C" }         , { "nTamanho" , 1 } , { "cPicture" , ""} ,;
			{ "aComboValues" , { "1=" + STR0052 , "2=" + STR0053 } } ; // "John Deere" // "Concessionário"
			} )

	EndCase

	oRetorno:AddFieldDictionary( "VJJ", "VJJ_ID" , { {"cIdField" , "ID"} , { "lCanChange" , .t. } , { "lVirtual", .t. } } )

	oRetorno:AddButton(STR0018, 'BTNATUALIZAR', { || VA1100083_AtualizaQuoteList(cTipoCotacao) } ) // "Atualizar"

Return oRetorno

/*/{Protheus.doc} VA1100073_CriarOportunidade
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cAlias, characters, description
@param nReg, numeric, description
@param nOpc, numeric, description
@type function
/*/
Function VA1100073_CriarOportunidade(cAlias, nReg, nOpc)

	Local oModel := FWLoadModel( 'VEIA110' )
	Local lRet

	oModel:SetOperation( MODEL_OPERATION_UPDATE )
	lRet := oModel:Activate()
	If ! lRet
		Alert("Erro ao carregar model.")
		Return .f.
	EndIf

	If ! MsgYesNo(STR0054, STR0044) // "Confirma criação de Oportunidade para a cotação posicionada?"
		oModel:DeActivate()
		Return .f.
	EndIF

	Pergunte("VEIA110",.f.,,,,.f.)    
	cFaseOportunidade := MV_PAR05

	Begin Transaction

		lRet := VA1100293_GravarVDL(oModel, .t., cFaseOportunidade)

	End Transaction

	oModel:DeActivate()

	If lRet
		MsgInfo(STR0055 + CRLF + CRLF + STR0056 + ": " + VDL->VDL_CODOPO) // "Oportunidade gerada." // Número
	EndIf

Return .t.

/*/{Protheus.doc} VA1100233_CancelaInteresse
Cancela interesse

@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModelVJK, object, description
@param cOportMotCan, characters, description
@type function
/*/
Static Function VA1100233_CancelaInteresse(oModelVJK, cOportMotCan)

	Local aIntCanc := {}

	VDL->(dbSetOrder(1))
	If ! VDL->(dbSeek(xFilial("VDL") + oModelVJK:GetValue("VJK_CODOPO")))
		Return .f.
	EndIf

	VDM->(dbSetOrder(2))
	If ! VDM->(dbSeek(xFilial("VDM") + oModelVJK:GetValue("VJK_CODINT")))
		Return .f.
	EndIf

	aAdd(aIntCanc,{ "1" ,;
				,;
				,;
				,;
				,;
				,;
				,;
				VDM->(Recno()) ,;
				VDL->(Recno()) })

	aMotCanc := {cOportMotCan,,,{}}
	VCM680043_GravaCancelamento(aMotCanc, aIntCanc)

Return

/*/{Protheus.doc} VA1100293_GravarVDL
Grava registro de oportunidade/interesse
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@param lHelp, logical, description
@param cFaseOportunidade, characters, description
@type function
/*/
Static Function VA1100293_GravarVDL(oModel, lHelp, cFaseOportunidade)

	Local oModelVJK
	Local oModelVJJ
	Local nLinha
	Local cNivImp := ""
	Local lSA1Rel := .f.

	oModelVJJ := oModel:GetModel("MODEL_VJJ")
	oModelVJK := oModel:GetModel("MODEL_VJK")

	If VA1100333_BloqueiaCriacaoAtendOpo(oModelVJJ:GetValue("VJJ_TIPO"), oModelVJJ:GetValue("VJJ_FILDEA"), lHelp)
		Return .f.
	EndIf

	If VA1100373_FaltaDadosCliente(oModelVJJ:GetValue("VJJ_CODVJP"), lHelp)
		Return .f.
	EndIf

	If VA1100303_ItemSemModeloRelacionado(oModelVJJ:GetValue("VJJ_CODIGO"), lHelp)
		Return .f.
	EndIf

	If ! VA1100523_ItensSemOportunidade(oModelVJJ:GetValue("VJJ_CODIGO"), lHelp)
		Return .f.
	EndIf


	lSA1Rel := ! Empty(VJP->VJP_A1COD)
	If lSA1Rel
		SA1->(dbSetOrder(1))
		lSA1Rel := SA1->(MsSeek( VJP->VJP_A1FIL + VJP->VJP_A1COD + VJP->VJP_A1LOJA ))

		VCF->(DbSetOrder(1))
		If VCF->(DbSeek( xFilial("VCF") + SA1->A1_COD + SA1->A1_LOJA ))
			cNivImp := VCF->VCF_NIVIMP
		EndIf
	EndIf
	//

	DbSelectArea("VDL")
	RecLock("VDL",.t.)
	VDL->VDL_FILIAL := xFilial("VDL")
	VDL->VDL_CODOPO := GetSXENum("VDL","VDL_CODOPO")
	ConfirmSX8()
	If lSA1Rel
		VDL->VDL_CODCLI := SA1->A1_COD
		VDL->VDL_LOJCLI := SA1->A1_LOJA
		VDL->VDL_NOMCLI := SA1->A1_NOME
		VDL->VDL_DDDCLI := SA1->A1_DDD
		VDL->VDL_TELCLI := SA1->A1_TEL
		VDL->VDL_EMACLI := SA1->A1_EMAIL
		VDL->VDL_NIVIMP := cNivImp
	Else
		If Empty(VJP->VJP_CBNAME)
			VDL->VDL_NOMCLI := VJP->VJP_CFNAME + " " + VJP->VJP_CLNAME
		Else
			VDL->VDL_NOMCLI := VJP->VJP_CBNAME
		EndIf
		VDL->VDL_TELCLI := VJP->VJP_PHONE
	EndIf
	VDL->(MsUnLock())
	VDL->(dbGoTo(VDL->(Recno())))

	// Procura vendedor com base no vendedor da cotacao ...
	cCodVen := VA1100613_CodigoVendedor( oModelVJJ:GetValue("VJJ_SALID") )
	//

	DbSelectArea("VDM")
	For nLinha := 1 to oModelVJK:Length()

		oModelVJK:SetLine(nLinha)
		If oModelVJK:GetValue("VJK_DELETE") == "1" .or. oModelVJK:GetValue("VJK_INTEGR") <> "1" .or. !Empty(oModelVJK:GetValue("VJK_CODOPO"))
			Loop
		EndIf

		RegToMemory("VDM",.T.)

		RecLock("VDM",.t.)
		FG_GRAVAR("VDM")

		VDM->VDM_FILIAL := xFilial("VDM")
		VDM->VDM_CODOPO := VDL->VDL_CODOPO
		VDM->VDM_QTDINT := 1 // Qtde fixa 1

		VDM->VDM_CODINT := GetSXENum("VDM","VDM_CODINT")
		ConfirmSX8()

		VDM->VDM_CODMAR := oModelVJK:GetValue("VJK_CODMAR", nLinha)
		VDM->VDM_MODVEI := oModelVJK:GetValue("VJK_MODVEI", nLinha)

		IF !Empty(cCodVen)
			VDM->VDM_CODVEN := cCodVen
		EndIf

		VDM->VDM_CODFAS := cFaseOportunidade

		VDM->VDM_VLRVDA := oModelVJK:GetValue("VJK_PRICE", nLinha)
		VDM->VDM_VLRNEG := oModelVJK:GetValue("VJK_PRICE", nLinha)
		VDM->(MsUnlock())
		VDM->(dbGoTo(VDM->(Recno())))

		SetModelVal( oModelVJK , "VJK_FILOPO" , VDM->VDM_FILIAL )
		SetModelVal( oModelVJK , "VJK_CODOPO" , VDM->VDM_CODOPO )
		SetModelVal( oModelVJK , "VJK_CODINT" , VDM->VDM_CODINT )

	Next nLinha

	If ( lRet := oModel:VldData() )
		lRet := oModel:CommitData()
	EndIf
Return

/*/{Protheus.doc} VA1100083_AtualizaQuoteList
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cTipoCotacao, characters, description
@type function
/*/
Function VA1100083_AtualizaQuoteList(cTipoCotacao)

	Local cAuxMsg
	Local oModel
	Local oView
	Local oModelParam
	Local oModelGrid
	Local nLinha
	Local oJDQuote
	Local lCOTACAO := .F.
	Local lMASTER := .F.

	Local lEscondeVencidas := .f.
	Local lEscondeExpiradas := .f.

	oJDQuote := VEJDQuoteMaintainQuote():New()

	oModel := FWModelActive()
	oModelParam := oModel:GetModel("PARAMETROS")

	lEscondeVencidas := (oModelParam:GetValue("VENCIDAS") == .f.)

	Do Case
	Case cTipoCotacao == "COTACAO"
		If ! VA1100093_GetQuote(oJDQuote, oModelParam:GetValue("DATAINI"), oModelParam:GetValue("DATAFIM"), oModelParam:GetValue("ID"), .f. )
			Return .t.
		EndIf
		If Len(oJDQuote:aResponse) == 0
			MsgInfo(STR0057)
			Return .T.
		EndIf
		lCOTACAO := .T.
		lEscondeExpiradas := (oModelParam:GetValue("EXPIRADAS") == .f.)
	Case cTipoCotacao == "MASTER"
		If ! VA1100323_GetMaster(oJDQuote, oModelParam:GetValue("DATAINI"), oModelParam:GetValue("DATAFIM"), oModelParam:GetValue("ID"), oModelParam:GetValue("CRIADAPOR"))
			Return .t.
		EndIf
		lMASTER := .T.
	EndCase

	CursorWait()

	oView	:= FWViewActive()
	oModelGrid := oModel:GetModel("QUOTE")

	oModelGrid:SetNoInsertLine(.f.)

	If oModelGrid:CanClearData()
		oModelGrid:ClearData( .t. , .f. )
	EndIf

	For nLinha := 1 to Len(oJDQuote:aResponse)

		If oJDQuote:aResponse[nLinha]:deleteIndicator
			Loop
		EndIf

		If lCOTACAO .and. lEscondeExpiradas .and. Upper(oJDQuote:aResponse[nLinha]:quoteStatus) == "EXPIRADO"
			Loop
		EndIf

		If lEscondeVencidas .and. dDataBase > oJDQuote:aResponse[nLinha]:expirationDate
			Loop
		EndIf

		If VA1100123_JaImportada(oJDQuote:aResponse[nLinha]:quoteId )
			Loop
		EndIf

		oModelGrid:AddLine()
		oModelGrid:SetValue( "ID"       , oJDQuote:aResponse[nLinha]:quoteId )
		oModelGrid:SetValue( "NOME"     , oJDQuote:aResponse[nLinha]:quoteName )
		If cTipoCotacao == "COTACAO"
			oModelGrid:SetValue( "CLIENTE"  , oJDQuote:aResponse[nLinha]:customerName )
			oModelGrid:SetValue( "MODELO"   , oJDQuote:aResponse[nLinha]:modelName )
			oModelGrid:SetValue( "TOTAL"    , oJDQuote:aResponse[nLinha]:quoteTotal )
			oModelGrid:SetValue( "STATUS"    , oJDQuote:aResponse[nLinha]:quoteStatus )
		EndIf
		oModelGrid:SetValue( "CRIACAO"  , oJDQuote:aResponse[nLinha]:creationDate )
		oModelGrid:SetValue( "VENCIMENTO", oJDQuote:aResponse[nLinha]:expirationDate )

	Next nLinha

	If oModelGrid:Length() == 0
		oModelGrid:AddLine()
	EndIf
	oModelGrid:SetLine(1)
	oModelGrid:SetNoInsertLine(.T.)

	CursorArrow()
Return .t.

/*/{Protheus.doc} VA1100093_GetQuote
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oJDQuote, object, description
@param dDataIni, date, description
@param dDataFim, date, description
@param nID, numeric, description
@param lSchedule, logical, description
@type function
/*/
Function VA1100093_GetQuote(oJDQuote, dDataIni, dDataFim, nID, lSchedule)

	Local cAuxMsg
	Local lProcessado := .f.

	Default nID := 0

	If Empty(dDataIni) .or. Empty(dDataFim)
		Return .f.
	EndIf

	cAuxMsg := ;
		'<startModifiedDate>' + StrZero(Month(dDataIni),2) + "/" + StrZero(Day(dDataIni),2) + "/" + StrZero(Year(dDataIni),4) + '</startModifiedDate>' +;
		'<endModifiedDate>' + StrZero(Month(dDataFim),2) + "/" + StrZero(Day(dDataFim),2) + "/" + StrZero(Year(dDataFim),4) + '</endModifiedDate>'

	If nID <> 0
		cAuxMsg += '<quoteId>' + AllTrim(cValToChar(nID)) + '</quoteId>'
	EndIf

	If lSchedule
		lProcessado := oJDQuote:getQuote(cAuxMsg)
	Else
		MsgRun(STR0058 ,"JDQuote - getQuote",{|| lProcessado := oJDQuote:getQuote(cAuxMsg) }) // "Consultando lista de cotações"
	EndIf

	If ! lProcessado
		MsgInfo(STR0059, STR0044) // "Erro ao acessar WebService."
		Return .f.
	EndIf

Return .t.

/*/{Protheus.doc} VA1100103_ModelConsQuote
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oStruParQuote, object, description
@param oStruGridQuote, object, description
@type function
/*/
Static Function VA1100103_ModelConsQuote(oStruParQuote, oStruGridQuote)

	Local oModel

	Local oModelParQuote  := oStruParQuote:GetModel()
	Local oModelGridQuote := oStruGridQuote:GetModel()

	oModel := MPFormModel():New( 'VA110CQT', /* bPre */,  , { || .t. } /* bCommit */ , { || .T. }/* bCancel */ )
	oModel:AddFields('PARAMETROS', /* cOwner */ , oModelParQuote, /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ { || } )
	oModel:AddGrid('QUOTE', 'PARAMETROS', oModelGridQuote, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* { |oSubModel| (oSubModel, oJDQuote) } */ /* <bLoad> */ )

	oModel:SetDescription( STR0046 ) // "Lista de Cotações - JDQuote"
	oModel:GetModel( 'PARAMETROS' ):SetDescription( STR0060 ) // "Dados de parâmetros da consulta"
	oModel:GetModel( 'QUOTE' ):SetDescription( STR0061 ) // "Dados das cotações"

	oModel:GetModel('PARAMETROS'):SetOnlyQuery( .T. )
	oModel:GetModel('QUOTE'):SetOnlyQuery( .T. )

	oModel:GetModel('QUOTE'):SetOptional( .T. )

	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} VA1100113_ViewConsQuote
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@param oStruParQuote, object, description
@param oStruGridQuote, object, description
@type function
/*/
Static Function VA1100113_ViewConsQuote(oModel, oStruParQuote, oStruGridQuote)

	Local oViewParQuote  :=  oStruParQuote:GetView()
	Local oViewGridQuote :=  oStruGridQuote:GetView()

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField('VIEW_PARAMETROS', oViewParQuote , 'PARAMETROS' )
	oView:AddGrid( 'VIEW_GRIDQUOTE', oViewGridQuote , 'QUOTE' )

	oView:EnableTitleView('VIEW_PARAMETROS', STR0062 ) // 'Parâmetros'

	oView:SetNoInsertLine('VIEW_GRIDQUOTE')
	oView:SetNoDeleteLine('VIEW_GRIDQUOTE')
	oView:EnableTitleView('VIEW_GRIDQUOTE'	, STR0063 ) // 'Listagem de Cotações'

	oView:CreateHorizontalBox('TELA_PARAM',170, , .t.)
	oView:CreateHorizontalBox('TELA_LISTA',100)

	oView:SetOwnerView('VIEW_PARAMETROS','TELA_PARAM')
	oView:SetOwnerView('VIEW_GRIDQUOTE','TELA_LISTA')

	oView:SetCloseOnOk({||.T.})
	//Executa a ação antes de cancelar a Janela de edição se ação retornar .F. não apresenta o
	// qustionamento ao usuario de formulario modificado
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.})

	oView:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL

	oView:AddOtherObject("VIEW_BT", {|oPanel,oView| VA1100343_SelecionaTudo(oPanel,oView) })
	oView:CreateHorizontalBox( 'BOXBT', 20 ,, .t.)
	oView:SetOwnerView("VIEW_BT",'BOXBT')

	oView:SetViewProperty("VIEW_GRIDQUOTE", "GRIDFILTER", {.T.})
	oView:SetViewProperty("VIEW_GRIDQUOTE", "GRIDSEEK", {.T.})

	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)

Return oView

/*/{Protheus.doc} VA1100343_SelecionaTudo
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oPanel, object, description
@param oView, object, description
@type function
/*/
Function VA1100343_SelecionaTudo(oPanel,oView)
	//Local oTBtn1 := Nil
	//oTBtn1 := TButton():Create( oPanel,005,005,"Marcar Todos",{||F686AllBt()},70,15,,,,.T.,,,,,,)//"Marcar todos"
	@ 001, 010 CheckBox oChK VAR lMarcarDesmarcar OF oPanel SIZE 100, 15 PROMPT STR0064 PIXEL ON Click VA1100353_BotaoSelecionaTudo() // "Marca / Desmarca Todos"
Return

/*/{Protheus.doc} VA1100353_BotaoSelecionaTudo
Seleciona todos os registros da grid
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VA1100353_BotaoSelecionaTudo()

	Local oModel := FWModelActive()
	Local oView	 := FWViewActive()
	Local oModelGrid := oModel:GetModel('QUOTE')
	Local nLinhasGrid := oModelGrid:Length()
	Local nX		:= 0

	For nX := 1 To nLinhasGrid
		oModelGrid:GoLine(nX)
		If nLinhasGrid == 1 .and. Empty( oModelGrid:GetValue("ID") )
		Else
			oModelGrid:SetValue('QUOTESEL', lMarcarDesmarcar )
		EndIf
	Next nX

	oModelGrid:GoLine(1)
	oView:Refresh()

Return

/*/{Protheus.doc} VA1100123_JaImportada
Retorna se a cotacao ja foi importada

@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param nQuoteId, numeric, description
@param nRecVJJ, numeric, description
@type function
/*/
Function VA1100123_JaImportada(nQuoteId, nRecVJJ)

	Local lRet := .t.

	BeginSql Alias "TPESQQUOTE"

		COLUMN VJJREC AS NUMERIC(10,2)

		SELECT VJJ.R_E_C_N_O_ VJJREC
		  FROM %Table:VJJ% VJJ
		 WHERE VJJ.VJJ_ID = %exp:nQuoteId%
		   AND %NotDel%

	EndSql

	If TPESQQUOTE->(Eof()) .or. TPESQQUOTE->VJJREC == 0
		lRet := .f.
	EndIf
	nRecVJJ := TPESQQUOTE->VJJREC

	TPESQQUOTE->(dbCloseArea())

Return lRet

/*/{Protheus.doc} VA1100133_OkListaQuote
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@param aRetorno, array, description
@param cTipoCotacao, characters, description
@type function
/*/
Function VA1100133_OkListaQuote(oModel, aRetorno, cTipoCotacao)

	Local nLinha
	Local oModelGrid := oModel:GetModel("QUOTE")
	Local cVJJTIPO

	If ! MsgYesNo(STR0065,STR0044) // "Confirma importação das cotações selecionadas" // Atenção
		Return .t.
	EndIf

	Do Case
	Case cTipoCotacao == "MASTER"
		cVJJTIPO := "1"
	Case cTipoCotacao == "COTACAO"
		cVJJTIPO := "2"
	EndCase

	For nLinha := 1 to oModelGrid:Length()
		If ! oModelGrid:GetValue("QUOTESEL",nLinha)
			Loop
		EndIf

		AADD( aRetorno , { oModelGrid:GetValue("ID", nLinha) , cVJJTIPO } )

	Next nLinha

Return .t.

/*/{Protheus.doc} VA1100143_AlterarSenha
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param cAlias, characters, description
@param nReg, numeric, description
@param nOpc, numeric, description
@type function
/*/
Function VA1100143_AlterarSenha(cAlias,nReg,nOpc)
	OFNJD15PW(cAlias,nReg,nOpc)
Return

/*/{Protheus.doc} VA1100153_Customer
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel110, object, description
@param oModelVJJ, object, description
@param oCustomer, object, description
@type function
/*/
Function VA1100153_Customer(oModel110, oModelVJJ, oCustomer, lSchedule)

	If oCustomer:entityId <> 0
		cCodigoVJP := VA1100163_CustomerWithID(oModel110, oModelVJJ, oCustomer, lSchedule)
		If ! Empty(cCodigoVJP)
			SetModelVal( oModelVJJ , 'VJJ_CODVJP' , cCodigoVJP )
		EndIf
	Else
		cCodigoVJP := VA1100173_CustomerWithoutID(oModelVJJ, oCustomer, lSchedule)
		If !Empty(cCodigoVJP)
			SetModelVal( oModelVJJ , 'VJJ_CODVJP' , cCodigoVJP )
		EndIf
	EndIf

Return cCodigoVJP

/*/{Protheus.doc} VA1100163_CustomerWithID
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel110, object, description
@param oModelVJJ, object, description
@param oCustomer, object, description
@type function
/*/
Function VA1100163_CustomerWithID(oModel110, oModelVJJ, oCustomer, lSchedule)

	Local cVJJcodVJP := ""
	Local cCodVJP := ""
	Local cQuery

	If oModel110:GetOperation() == MODEL_OPERATION_UPDATE
		cVJJcodVJP := oModelVJJ:GetValue("VJJ_CODVJP")
	EndIf

	BeginSql Alias "TPESQCKC"

		SELECT VJP.VJP_CODIGO
		  FROM %Table:VJP% VJP
		 WHERE
		 	VJP.VJP_FILIAL= %xfilial:VJP%
			AND VJP.VJP_ID = %exp:oCustomer:entityId%
			AND %NotDel%

	EndSql

	// Cliente nao cadastrado 
	If TPESQCKC->(Eof())
		If Empty(cVJJcodVJP)
			cCodVJP := VA1100183_CreateCustomer(oCustomer, "")
		Else
			cCodVJP := cVJJcodVJP
			VA1100273_UpdateCustomer(cCodVJP, oCustomer, lSchedule)
		EndIf
	Else
		If Empty(cVJJcodVJP)
			cCodVJP := TPESQCKC->VJP_CODIGO
			VA1100273_UpdateCustomer(cCodVJP, oCustomer, lSchedule)
		Else
			// Se o codigo de cliente for diferente do codigo informado na Cotacao
			// provavelmente a cotacao foi alterada para um registro de cliente já sincronizado
			// nesses casos, sera necessário remover o relacionamento da VJJ com VJP e apagar o registro do cliente (VJP)
			If cVJJcodVJP <> TPESQCKC->VJP_CODIGO
				cCodVJP := TPESQCKC->VJP_CODIGO
				VA1100383_DeleteCustomer(cVJJcodVJP, oModelVJJ)
			Else
				cCodVJP := cVJJcodVJP 
			EndIf
			VA1100273_UpdateCustomer(cCodVJP, oCustomer, lSchedule)
		EndIf
	EndIf

	TPESQCKC->(dbCloseArea())

Return cCodVJP

/*/{Protheus.doc} VA1100383_DeleteCustomer
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cCodVJP, characters, description
@param oModelVJJ, object, description
@type function
/*/
Function VA1100383_DeleteCustomer(cCodVJP, oModelVJJ)
	Local oModelActive := FWModelActive()
	Local oModelCliente := FWLoadModel( 'VEIA111' )
	Local lRetorno := .f.


	VJP->(dbSetOrder(1))
	If ! VJP->(dbSeek(FWxFilial("VJP") + cCodVJP))
		Return .f.
	EndIf

	// Se o registro ja possui um relacionamento com a SA1, so removemos o relacionamento do cliente CKC com a cotacao 
	If ! Empty(VJP->VJP_A1COD)
		SetModelVal( oModelVJJ , 'VJJ_CODVJP' , " " )
		Return .t.
	EndIF

	oModelCliente:SetOperation( MODEL_OPERATION_DELETE )
	If oModelCliente:Activate()
		SetModelVal( oModelVJJ , 'VJJ_CODVJP' , " " )

		If oModelCliente:VldData()
			oModelCliente:CommitData()
			lRetorno := .t.
		Else
			aErro   := oModelCliente:GetErrorMessage()
			VA1100623_SetError("VA1100383_DeleteCustomer", aErro)

			MostraErro()

			lRetorno := .f.

		EndIf

	EndIf

	FWModelActive(oModelActive)

Return lRetorno


/*/{Protheus.doc} VA1100173_CustomerWithoutID
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oModelVJJ, object, description
@param oCustomer, object, description
@type function
/*/
Function VA1100173_CustomerWithoutID(oModelVJJ, oCustomer, lSchedule)

	Local cCodVJP := ""
	Local cQuery
	Local cCodVJJ := oModelVJJ:GetValue("VJJ_CODIGO")

	BeginSql Alias "TPESQCKC"

		SELECT VJP.VJP_CODIGO
		  FROM %Table:VJP% VJP
		 WHERE VJP.VJP_FILIAL= %xfilial:VJP%
			AND VJP.VJP_CODVJJ = %exp:cCodVJJ%
			AND %NotDel%

	EndSql

	If TPESQCKC->(Eof())
		cCodVJP := VA1100183_CreateCustomer(oCustomer, cCodVJJ, lSchedule)
	Else
		cCodVJP := TPESQCKC->VJP_CODIGO
		VA1100273_UpdateCustomer(cCodVJP, oCustomer, lSchedule, cCodVJJ)
	EndIf

	TPESQCKC->(dbCloseArea())

Return cCodVJP

/*/{Protheus.doc} VA1100183_CreateCustomer
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oCustomer, object, description
@param cCodVJJ, characters, description
@type function
/*/
Static Function VA1100183_CreateCustomer(oCustomer, cCodVJJ)
	Local cCodVJP
	Local oModelActive := FWModelActive()
	Local oModelCliente := FWLoadModel( 'VEIA111' )

	oModelCliente:SetOperation( MODEL_OPERATION_INSERT )
	If oModelCliente:Activate()
		If VA1100263_SetModelCustomer(oModelCliente, oCustomer, cCodVJJ)
			cCodVJP := oModelCliente:GetValue("MODEL_VJP","VJP_CODIGO")

			If lcriaSA1Automatico
				dbSelectArea("VJP")
				dbGoTo(oModelCliente:GetModel("MODEL_VJP"):GetDataID())
				VA1110083_CriaSA1Automaticamente()
			EndIf

		EndIf
	EndIf


	FWModelActive(oModelActive)

Return cCodVJP

/*/{Protheus.doc} VA1100193_ImportarManual
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VA1100193_ImportarManual()

	Local aParamBox := {}
	Local aRetParam := {}

	AADD(aParamBox,{1,RetTitle("VJJ_ID"),0,PesqPict("VJJ","VJJ_ID"),"","","" ,50,.T.})
	If !ParamBox(aParamBox, STR0066,@aRetParam,,,,,,,,.f.) //"Importação de Cotação"
		Return .f.
	EndIf

	VA1100363_ProcessaImportacao({aRetParam[1]})

Return .t.

/*/{Protheus.doc} VA1100203_getPO
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VA1100203_getPO()
	Local oJDQuotePO := VEJDQuotePODataService():New()
	Local aListQuote := {16098121}
	Local nPosQuote := 1

	MsgRun( STR0067 + " - " + cValToChar(aListQuote[nPosQuote]),"JDQuotePO - getQuoteDetail",{|| lProcessado := oJDQuotePO:getPODetailByQuoteID(aListQuote[nPosQuote]) }) // "Consultando PO"

	nPosQuote := 1

Return

/*/{Protheus.doc} VA1100213_ConsultaWebService
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param nQuoteId, numeric, description
@param oJDQuote, object, description
@param oJDQuotePO, object, description
@type function
/*/
Function VA1100213_ConsultaWebService(nQuoteId, oJDQuote, oJDQuotePO)

	Local lRetorno

	lRetorno := oJDQuote:getQuoteDetail(nQuoteId)

	oJDQuotePO:Clear()
	If lRetorno
		If ! Empty(oJDQuote:aResponse[1]:oPODetails:poNumber)
			lRetorno := oJDQuotePO:getPODetailByQuoteID(nQuoteId)
		EndIf
	EndIf

Return lRetorno

/*/{Protheus.doc} VA1100223_RelacionaModelo
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cAlias, characters, description
@param nReg, numeric, description
@param nOpc, numeric, description
@type function
/*/
Function VA1100223_RelacionaModelo(cAlias, nReg, nOpc)

	Local oView
	Local oModel := FWLoadModel( 'VEIA110' )
	Local oStruVJJ := FWFormStruct( 2, 'VJJ' )
	Local oStruVJK := FWFormStruct( 2, 'VJK' , { |x| AllTrim(x) $ "/VJK_INTEGR/VJK_CODIGO/VJK_ID/VJK_MODEID/VJK_BASECD/VJK_MODNAM/VJK_CODMAR/VJK_MODVEI/VJK_SEGMOD" } )
	Local nLinha
	Local lSemModelo := .f.
	Local cBkpFilAnt := cFilAnt

	Private oBrwPainel

	cQuery := ;
		"SELECT COUNT(*) " +;
		 " FROM " + RetSQLName("VJK") + " VJK " +;
		" WHERE VJK.VJK_FILIAL = '" + xFilial("VJK") + "'" +;
		  " AND VJK.VJK_CODVJJ = '" + VJJ->VJJ_CODIGO + "'" +;
		  " AND VJK.VJK_CODOPO = ' '" +;
		  " AND VJK.VJK_NUMTRA = ' '" +;
		  " AND VJK.D_E_L_E_T_ = ' '"
	lSemModelo := (FM_SQL(cQuery) <> 0)
	If ! lSemModelo
		FMX_HELP("VA110ERR16",STR0068) // "Todos os itens já possuem oportunidade e/ou atendimento relacionado."
		Return
	EndIf

	oStruVJJ:SetProperty("*", MVC_VIEW_CANCHANGE , .F. )

	oStruVJK:SetProperty("*", MVC_VIEW_CANCHANGE , .F. )
	oStruVJK:SetProperty('VJK_INTEGR', MVC_VIEW_CANCHANGE , .T. )
	oStruVJK:SetProperty('VJK_CODMAR', MVC_VIEW_CANCHANGE , .T. )
	oStruVJK:SetProperty('VJK_MODVEI', MVC_VIEW_CANCHANGE , .T. )
	oStruVJK:SetProperty('VJK_SEGMOD', MVC_VIEW_CANCHANGE , .T. )
	oStruVJK:AddField( 'LEGENDA','01',' ','Legenda',, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField('VIEW_VJJ', oStruVJJ, 'MODEL_VJJ' )
	oView:AddGrid( 'VIEW_VJK', oStruVJK, 'MODEL_VJK' )

	oView:SetNoInsertLine('VIEW_VJK')

	oView:CreateHorizontalBox( 'TELA_VJJ' , 70 )
	oView:CreateHorizontalBox( 'TELA_VJK' , 30 )

	oView:SetOwnerView('VIEW_VJK', 'TELA_VJK')
	oView:SetOwnerView('VIEW_VJJ', 'TELA_VJJ')

	oView:SetCloseOnOk( {||.T.} )

	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0069 + " - Protheus") // Lista de Modelos
	oExecView:setModel(oModel)
	oExecView:setView(oView)
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)

	cFilAnt := cBkpFilAnt

Return .t.

/*/{Protheus.doc} VA1100243_CancelaAtendimento
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function VA1100243_CancelaAtendimento( oModelVJK, cAtendMotCan, aCancItens )

	Local cNumTra := aCancItens[2]
	Local aAutoCab := {}
	Local aAutoVV9 := {}
	Local aAutoItens:= {} // Campos Itens

	Local cBkpFunName := FunName()
	Local cBkpFilAnt := cFilAnt

	Local nPosCancItem

	cFilAnt := aCancItens[1]

	VV9->(dbSetOrder(1))
	VV9->(dbSeek(FWxFilial("VV9") + cNumTra))
	If ! VV9->(Found()) .or. VV9->VV9_STATUS == "C"
		Return .t.
	EndIf

	If VV9->VV9_STATUS <> "A" 
		Return .f.
	EndIf

	BeginSql Alias "TPESQVVA"

		COLUMN VVACONT AS NUMERIC(10,2)

		SELECT COUNT(*) VVACONT
		  FROM %Table:VVA% VVA
		 WHERE VVA.VVA_FILIAL= %xfilial:VVA%
			AND VVA.VVA_NUMTRA = %exp:cNumTra%
			AND %NotDel%

	EndSql

	aAdd(aAutoVV9, { "VV9_NUMATE" , cNumTra, NIL } )
	
	// Cancelamento do total do atendimento
	If TPESQVVA->VVACONT == Len(aCancItens[3])

		nOpcCanc := 2 // Cancela atendimento

		VS0->(dbSetOrder(1))
		VS0->(dbSeek(FWxFilial("VS0") + "000001" + cAtendMotCan))

		aMotCanc := { cAtendMotCan , VS0->VS0_DESMOT , (VS0->VS0_CRICEV=="1") , {}}

		SetFunName("VEIXA018")
		lMSHelpAuto := .t.
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z,w,u,v| VEIXX002(x,y,,z,,w,u,v)}, aAutoCab, aAutoItens, 5, aAutoVV9,nOpcCanc,aMotCanc)
		If lMsErroAuto
			MostraErro()
		EndIf

	Else
		// exclusao de algumas linhas do atendimento

		aAutoItens:= {} // Campos Itens

		For nPosCancItem := 1 to Len(aCancItens[3])
			aAutoIt := {}
			AADD( aAutoIt , { "LINPOS"    , "VVA_ITETRA", aCancItens[3, nPosCancItem] })
			AADD( aAutoIt , { "AUTDELETA" , "S" , NIL } )
			AADD( aAutoItens , aAutoIt )
		Next nPosCancItem

		SetFunName("VEIXA018")
		lMSHelpAuto := .t.
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z,w| VEIXX002(x,y,,z,,w )}, aAutoCab, aAutoItens, 4, aAutoVV9)
		If lMsErroAuto
			MostraErro()		
		EndIf

	EndIf

	TPESQVVA->(dbCloseArea())

	SetFunName(cBkpFunName)
	cFilAnt := cBkpFilAnt

Return

/*/{Protheus.doc} VA1100253_AtualizaCampoVJL
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VA1100253_AtualizaCampoVJL()

	Local oModel := FWModelActive()
	Local oView := FWViewActive()
	Local oModelVJK := oModel:GetModel("MODEL_VJK")

	oModelVJK:SetValue("VJK_CODMAR"  , VV2->VV2_CODMAR )
	oModelVJK:SetValue("VJK_MODVEI"  , VV2->VV2_MODVEI )
	oModelVJK:SetValue("VJK_SEGMOD"  , VV2->VV2_SEGMOD )

	oView:Refresh()

Return

/*/{Protheus.doc} VA1100263_SetModelCustomer
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oModelCliente, object, description
@param oCustomer, object, description
@param cCodVJJ, characters, description
@type function
/*/
Function VA1100263_SetModelCustomer(oModelCliente, oCustomer, cCodVJJ)
	Local oModelVJP

	oModelVJP := oModelCliente:GetModel("MODEL_VJP")

	SetModelVal( oModelVJP , 'VJP_ID' , oCustomer:entityId )
	SetModelVal( oModelVJP , 'VJP_CBNAME' , oCustomer:businessName )
	SetModelVal( oModelVJP , 'VJP_CFNAME' , oCustomer:firstName )
	SetModelVal( oModelVJP , 'VJP_CLNAME' , oCustomer:lastName )
	SetModelVal( oModelVJP , 'VJP_PHONE'  , oCustomer:phoneNumber )
	SetModelVal( oModelVJP , 'VJP_TAXID'  , oCustomer:taxID )
	SetModelVal( oModelVJP , 'VJP_DBSCN'  , oCustomer:dbsCustomerNumber )
	SetModelVal( oModelVJP , 'VJP_CADDR1' , oCustomer:oAddress:addressLine1 )
	SetModelVal( oModelVJP , 'VJP_CADDR2' , oCustomer:oAddress:addressLine2 )
	SetModelVal( oModelVJP , 'VJP_CCITY'  , oCustomer:oAddress:city         )
	SetModelVal( oModelVJP , 'VJP_CSTATE' , oCustomer:oAddress:state        )
	SetModelVal( oModelVJP , 'VJP_CCOUNT' , oCustomer:oAddress:country      )
	SetModelVal( oModelVJP , 'VJP_CZIPC'  , StrTran(oCustomer:oAddress:zip,"-","") )

	SetModelVal( oModelVJP , 'VJP_CODVJJ'  , cCodVJJ )

	If oModelCliente:VldData()
		oModelCliente:CommitData()
	Else
		aErro   := oModelCliente:GetErrorMessage()
		VA1100623_SetError("VA1100263_SetModelCustomer", aErro)

		MostraErro()

		Return .f.

	EndIf
Return .t.

/*/{Protheus.doc} VA1100273_UpdateCustomer
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cCodVJP, characters, description
@param oCustomer, object, description
@type function
/*/
Static Function VA1100273_UpdateCustomer(cCodVJP, oCustomer, lSchedule, cCodVJJ)
	Local oModelActive := FWModelActive()
	Local oModelCliente := FWLoadModel( 'VEIA111' )
	Local lRetorno := .f.

	Default cCodVJJ := ""

	VJP->(dbSetOrder(1))
	If ! VJP->(dbSeek(FWxFilial("VJP") + cCodVJP))
		Return .f.
	EndIf

	If lSchedule == .F. .and. lCKCValidaCliente .and. VA1100633_DadosCKCDiferentes(oCustomer)
		If ! MsgYesNo(STR0070) // "Os dados do cliente na base de dados da John Deere alterado. Deseja atualizar os dados no cadastro do cliente CKC no Protheus?"
			Return .t.
		Endif
	EndIf

	oModelCliente:SetOperation( MODEL_OPERATION_UPDATE )
	If oModelCliente:Activate()
		lRetorno := VA1100263_SetModelCustomer(oModelCliente, oCustomer, cCodVJJ)
	EndIf

	FWModelActive(oModelActive)

Return lRetorno

/*/{Protheus.doc} VA1100283_TelaCriarAtendimento
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cAlias, characters, description
@param nReg, numeric, description
@param nOpc, numeric, description
@type function
/*/
Function VA1100283_TelaCriarAtendimento(cAlias, nReg, nOpc)

	Local oModel := FWLoadModel( 'VEIA110' )
	Local oModelVJJ
	Local nLinha
	Local cNivImp := ""
	Local lSA1Rel := .f.
	Local nLinhaAtual
	Local lRet := .t.

	Local lValidar := .t.

	Local oView
	Local oStruVJJView
	Local oStruVJKView

	Local oStruVJK := oModel:GetModel("MODEL_VJK"):GetStruct()

	Private lSair := .f.

	If VA1100333_BloqueiaCriacaoAtendOpo(VJJ->VJJ_TIPO, VJJ->VJJ_FILDEA, .t.)
		Return .f.
	EndIf

	If VA1100373_FaltaDadosCliente(VJJ->VJJ_CODVJP, .t.)
		Return .f.
	EndIf

	If VA1100303_ItemSemModeloRelacionado(VJJ->VJJ_CODIGO, .t.)
		Return .f.
	EndIf

	If ! VA1100543_ItensSemAtendimento(VJJ->VJJ_CODIGO, .t.)
		Return .f.
	EndIf

	If ! MsgYesNo(STR0071) // "Confirma criação de Atendimento para a cotação posicionada"
		Return .f.
	EndIF
	lValidar := .f.

	oStruVJK:DeActivate()
	oStruVJK:AddField('SELECT', ' ', 'SELECT', 'L', 1, 0, , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, ".f.")) 
	oStruVJK:Activate()

	oModel:SetOperation( MODEL_OPERATION_UPDATE )
	oModel:GetModel("MODEL_VJK"):SetLoadFilter( , "VJK_CODOPO = ' ' AND VJK_NUMTRA = ' ' AND VJK_DELETE = '0' AND VJK_INTEGR = '1'" )

	oStruVJJView := FWFormStruct( 2, 'VJJ' )
	oStruVJKView := FWFormStruct( 2, 'VJK' , { |x| AllTrim(x) $ "/VJK_CODIGO/VJK_ID/VJK_MODEID/VJK_MODNAM/VJK_BASECD/VJK_CODMAR/VJK_MODVEI/" } )
	oStruVJKView:AddField( 'SELECT','01','','SELECT',, 'Check')    

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddGrid( 'VIEW_VJK', oStruVJKView, 'MODEL_VJK' )

	oView:CreateHorizontalBox( 'TELA_VJK' , 100 )

	//Executa a ação antes de cancelar a Janela de edição se ação retornar .F. não apresenta o
	// qustionamento ao usuario de formulario modificado
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.})

	oView:SetOwnerView('VIEW_VJK', 'TELA_VJK')

	oView:EnableTitleView('VIEW_VJK', STR0008) // 'Equipamentos'

	While lSair == .f.

		If ! VA1100543_ItensSemAtendimento(VJJ->VJJ_CODIGO, .f.)
			Exit
		EndIf

		lRet := oModel:Activate()
		If ! lRet
			Alert("Erro ao carregar model.")
			Return .f.
		EndIf

		For nLinha := 1 to oModel:GetModel("MODEL_VJK"):Length()
			oModel:GetModel("MODEL_VJK"):GoLine(nLinha)
			oModel:GetModel("MODEL_VJK"):SetValue("SELECT",.t.)
		Next nLinha
		oModel:GetModel("MODEL_VJK"):GoLine(1)

		oExecView := FWViewExec():New()
		oExecView:setTitle(STR0010 + " - JDQuote") // "Itens da Cotação"
		oExecView:setModel(oModel)
		oExecView:setView(oView)
		oExecView:setOperation(MODEL_OPERATION_UPDATE)
		oExecView:setOK( { |oModel| VA1100573_CriarAtendimento(oModel, .f.) })
		oExecView:SetReduction(30)
		oExecView:SetCloseOnOk( { || .t. } )
		oExecView:SetCancel( { || lSair := .t. })
		oExecView:openView(.F.)

		oModel:DeActivate()

	End

Return lRet

/*/{Protheus.doc} VA1100573_CriarAtendimento
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@param lForce, logical, description
@type function
/*/
Function VA1100573_CriarAtendimento(oModel, lForce)

	Local aAutoVV0 := {}
	Local aAutoVV9 := {}
	Local aAutoVVA := {} // Campos Itens
	Local aAutoIt
	Local aAutoPagto := {} // Campos Pagamento
	Local aIteSel := {}
	Local lRet := .t.

	Local lVVASEGMOD := ( VVA->(ColumnPos("VVA_SEGMOD")) > 0 )

	Local nLinhaAtual
	Local cNumAteGerado
	Local cCodVen

	Pergunte("VEIA110",.f.,,,,.f.)    
	
	oModelVJJ := oModel:GetModel("MODEL_VJJ")
	oModelVJK := oModel:GetModel("MODEL_VJK")

	If lForce == .f.
		If oModelVJK:SeekLine({ {"SELECT", .T. } } , .F. , .F. ) == .f.
			FMX_HELP("VA110ERR13", STR0072) // "Selecione ao menos um item para criação de atendimento."
			Return .f.
		EndIf

		If ! MsgYesNo(STR0073)
			Return .f.
		EndIf

		CursorWait()

	EndIf

	aAutoVV9 := {}

	// Atendimento com cliente SA1
	If ! Empty(VJP->VJP_A1COD)
		SA1->(dbSetOrder(1))
		SA1->(MsSeek(VJP->VJP_A1FIL + VJP->VJP_A1COD + VJP->VJP_A1LOJA))

		aAdd(aAutoVV9, { "VV9_CODCLI" , SA1->A1_COD  , NIL } )
		aAdd(aAutoVV9, { "VV9_LOJA"   , SA1->A1_LOJA , NIL } )

		aAutoVV0 := {} // Campos Cabecalho
		aAdd(aAutoVV0,{"VV0_CODCLI"  ,SA1->A1_COD  , NIl })
		aAdd(aAutoVV0,{"VV0_LOJA"    ,SA1->A1_LOJA , NIl })
	Else

		If Empty(VJP->VJP_CBNAME)
			AADD( aAutoVV9 , { "VV9_NOMVIS" , AllTrim(VJP->VJP_CFNAME + " " + VJP->VJP_CLNAME) , NIL } )
		Else
			AADD( aAutoVV9 , { "VV9_NOMVIS" , AllTrim(VJP->VJP_CBNAME) , NIL } )
		EndIf
		AADD( aAutoVV9 , { "VV9_TELVIS" , IIf( Empty(VJP->VJP_PHONE) , "." , AllTrim(VJP->VJP_PHONE) ) , NIL } )
		AADD( aAutoVV9 , { "VV9_DATVIS" , dDataBase , NIL } )
		AADD( aAutoVV9 , { "VV9_HORVIS" , Val(StrTran(Left(Time(),5),":","")) , NIL } )
		AADD( aAutoVV9 , { "VV9_TIPMID" , "9" , NIL } )

		aAutoVV0 := {} // Campos Cabecalho
	EndIf

	cCodVen := VA1100613_CodigoVendedor(oModelVJJ:GetValue("VJJ_SALID"))
	If ! Empty(cCodVen)
		aAdd(aAutoVV0,{"VV0_CODVEN", cCodVen , NIl })
	EndIf


	aAutoVVA:= {} // Campos Itens
	aAutoPagto := {}
	For nLinhaAtual := 1 to oModelVJK:Length()

		If lForce == .f. .and. oModelVJK:GetValue("SELECT", nLinhaAtual) == .f.
			Loop
		EndIf

		oModelVJK:GoLine(nLinhaAtual)
		If oModelVJK:GetValue("VJK_DELETE") == "1" .or. oModelVJK:GetValue("VJK_INTEGR") <> "1" .or. ! Empty(oModelVJK:GetValue("VJK_CODOPO")) .or. !Empty(oModelVJK:GetValue("VJK_NUMTRA"))
			Loop
		EndIf

		VV2->(dbSetOrder(1))
		VV2->(MsSeek(xFilial("VV2") + oModelVJK:GetValue("VJK_CODMAR") + oModelVJK:GetValue("VJK_MODVEI") ))

		aAutoIt := {}

		aAdd( aAutoIt , { 'VVA_CODMAR' , VV2->VV2_CODMAR , NIL } )
		aAdd( aAutoIt , { 'VVA_GRUMOD' , VV2->VV2_GRUMOD , NIL } )
		aAdd( aAutoIt , { 'VVA_MODVEI' , VV2->VV2_MODVEI , NIL } )
		If lVVASEGMOD .and. ! Empty(VV2->VV2_SEGMOD)
			aAdd( aAutoIt , { 'VVA_SEGMOD' , VV2->VV2_SEGMOD , NIL } )
		EndIf

		If ! Empty(MV_PAR02)
			aAdd( aAutoIt , { 'VVA_OPER' , MV_PAR02 , NIL } )
		ElseIf ! Empty(MV_PAR03)
			aAdd( aAutoIt , { 'VVA_CODTES' , MV_PAR03 , NIL } )
		EndIf
		aAdd( aAutoIt , { 'VVA_VALTAB' , oModelVJK:GetValue( 'VJK_PRICE' ) , NIL } )

		aAdd(aAutoVVA,aAutoIt)

		// Controla os itens selecionados e o item da VVA para atualizar o registro na VJK
		AADD( aIteSel , { nLinhaAtual, Len(aAutoVVA)} )

	Next nLinhaAtual

	If Len(aAutoVVA) == 0
		Return .t.
	EndIf

	Begin Transaction
	Begin Sequence
		SetFunName("VEIXA018")

		lMSHelpAuto := .t.
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z,w| VEIXX002(x,y,,z,,w,,,,,,)}, aAutoVV0, aAutoVVA, 3, aAutoVV9 )

		//Conout("lMsErroAuto - " + cValToChar(lMsErroAuto))

		If lMsErroAuto
			MostraErro()
			lRet := .f.
			Break
		Endif

		nLinhaAtual := 1

		cNumAteGerado := VV0->VV0_NUMTRA

		VVA->(dbSetOrder(4))
		VVA->(dbGoTop())
		VVA->(dbSeek(FWxFilial("VVA") + VV0->VV0_NUMTRA))

		While !VVA->(Eof()) .and. VVA->VVA_FILIAL == FWxFilial("VVA") .and. VVA->VVA_NUMTRA == VV0->VV0_NUMTRA

			oModelVJK:GoLine( aIteSel[ nLinhaAtual , 1] )

			SetModelVal( oModelVJK , "VJK_FILTRA" , VVA->VVA_FILIAL )
			SetModelVal( oModelVJK , "VJK_NUMTRA" , VVA->VVA_NUMTRA )
			SetModelVal( oModelVJK , "VJK_ITETRA" , VVA->VVA_ITETRA )

			VVA->(dbSkip())

			++nLinhaAtual
		End

	Recover
		If lForce == .f.
			DisarmTransaction()
			MostraErro()
		EndIf

	End Sequence
	End Transaction

	If lForce == .f.
		CursorArrow()
		If lRet
			MsgInfo("Atendimento gerado." + CRLF + CRLF + "Número: " + cNumAteGerado)
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} VA1100303_ItemSemModeloRelacionado
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oModelVJK, object, description
@type function
/*/
Function VA1100303_ItemSemModeloRelacionado(cCodVJJ, lHelp)
	Local nLinha
	Local lRet := .f.
	Local cSQL

	cSQL := ;
		"SELECT COUNT(*) " +;
		" FROM " + RetSQLName("VJK") + " VJK" +;
		" WHERE VJK.VJK_FILIAL = '" + FWxFilial("VJK") + "' " +;
		" AND VJK.VJK_CODVJJ = '" + cCodVJJ + "' " + ;
		" AND VJK.VJK_MODVEI = ' ' " +;
		" AND VJK.VJK_DELETE <> '1' " +;
		" AND VJK.VJK_INTEGR = '1' " +;
		" AND VJK.D_E_L_E_T_ = ' '"
	If FM_SQL( cSQL ) <> 0
		If lHelp
			Help(NIL, NIL,"VA110ERR04",,STR0074,1,0,NIL, NIL, NIL, NIL, NIL,{ "" } ) // "Item da Cotação sem um modelo relacionado."
		EndIf
		lRet := .t.
	EndIf

Return lRet

/*/{Protheus.doc} VA1100313_ImportarMasters
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cAlias, characters, description
@param nReg, numeric, description
@param nOpc, numeric, description
@type function
/*/
Function VA1100313_ImportarMasters(cAlias, nReg, nOpc)

	Local nPos
	Local aRetorno := {}

	aRetorno := VA1100053_ListaQuote("MASTER")
	If Len(aRetorno) == 0
		Return
	End

	VA1100363_ProcessaImportacao(aRetorno)

Return

/*/{Protheus.doc} VA1100323_GetMaster
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oJDQuote, object, description
@param dDataIni, date, description
@param dDataFim, date, description
@param nID, numeric, description
@param cCriadaPor, characters, description
@type function
/*/
Function VA1100323_GetMaster(oJDQuote, dDataIni, dDataFim, nID, cCriadaPor)

	Local cAuxMsg
	Local lProcessado := .f.

	Default nID := 0

	If Empty(dDataIni) .or. Empty(dDataFim)
		Return .f.
	EndIf

	cAuxMsg := ;
		'<startModifiedDate>' + StrZero(Month(dDataIni),2) + "/" + StrZero(Day(dDataIni),2) + "/" + StrZero(Year(dDataIni),4) + '</startModifiedDate>' +;
		'<endModifiedDate>' + StrZero(Month(dDataFim),2) + "/" + StrZero(Day(dDataFim),2) + "/" + StrZero(Year(dDataFim),4) + '</endModifiedDate>'

	If nID <> 0
		cAuxMsg += '<quoteId>' + AllTrim(cValToChar(nID)) + '</quoteId>'
	EndIf

	If !Empty( cCriadaPor )
		cAuxMsg += '<dealerCompanyMasterIndicator>' + cCriadaPor + '</dealerCompanyMasterIndicator>'
	EndIf

	MsgRun(STR0075,"JDQuote - getMasterQuotes",{|| lProcessado := oJDQuote:getMasterQuotes(cAuxMsg) }) // "Consultando lista de cotações master"

	If ! lProcessado
		MsgInfo(STR0059) // "Erro ao acessar WebService."
		Return .f.
	EndIf

	If Len(oJDQuote:aResponse) == 0
		MsgInfo(STR0076) // "Não existe cotações no periodo informado."
		Return .f.
	EndIf

Return .t.

/*/{Protheus.doc} VA1100333_BloqueiaCriacaoAtendOpo
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VA1100333_BloqueiaCriacaoAtendOpo(cVJJTIPO, cVJJFILDEA, lHelp)

	If cVJJTIPO == "1"
		If lHelp
			Help(NIL, NIL,"VA110ERR10",,STR0078,1,0,NIL, NIL, NIL, NIL, NIL,{ STR0079 } ) // "Não é permitida criação de Oportunidade ou Atendimento a partir de cotações Masters." // "Selecione um registro do tipo Cotação."
		EndIf
		Return .t.
	EndIf

	If cVJJFILDEA <> cFilAnt
		If lHelp
			Help(NIL, NIL,"VA110ERR09",,STR0080,1,0,NIL, NIL, NIL, NIL, NIL,{ STR0081 } ) // "Concessionário relacionado no JDQuote não está relacionado à filial selecionada para criação da Oportunidade ou Atendimento." // "Altere o concessionário no portal do JDQuote ou seleciona a filial correta do Protheus."
		EndIf
		Return .t.
	EndIf

 Return .f.

/*/{Protheus.doc} SetModelVal
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oAuxModel, object, description
@param cCampo, characters, description
@param uValor, undefined, description
@type function
/*/
Static Function SetModelVal( oAuxModel , cCampo , uValor )
	If ! oAuxModel:SetValue(cCampo, uValor)
		//Conout("VEIA110 - Erro ao gravar valor no campo " + cCampo + " - [" + cValToChar(uValor) + "]" )
		Return .f.
	EndIf
Return .t.


/*/{Protheus.doc} VA1100373_FaltaDadosCliente
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oModelVJJ, object, description
@type function
/*/
Function VA1100373_FaltaDadosCliente(cCodVJP, lHelp)

	VJP->(dbSetOrder(1))
	If ! VJP->(MsSeek(FWxFilial("VJP") + cCodVJP ))
		If lHelp
			Help(1," ","REGNOIS",,CRLF + "VJP" + CRLF + RetTitle("VJJ_CODVJP") + ": " + cCodVJP,4,1)
		EndIf
		Return .t.
	EndIf

	If Empty(VJP->VJP_CFNAME + VJP->VJP_CLNAME + VJP->VJP_CBNAME)
		If lHelp
			Help(NIL, NIL,"VA110ERR08",,STR0082 + CRLF + CRLF + RetTitle("VJJ_CODVJP") + ": " + cCodVJP,1,0,NIL, NIL, NIL, NIL, NIL,{ "" } ) // "Cliente sem nome para criar atendimento."
		EndIf
		Return .t.
	EndIf

Return .f.



/*/{Protheus.doc} VA1100393_RelacionaOportunidade
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cAlias, characters, description
@param nReg, numeric, description
@param nOpc, numeric, description
@type function
/*/
Function VA1100393_RelacionaOportunidade(cAlias, nReg, nOpc)

	Local oView
	Local oModel
	Local oStruVJJ
	Local oStruVJK
	Local nLinha
	Local lSemModelo := .f.
	Local cBkpFilAnt := cFilAnt

	Private oBrwPainel

	If VA1100333_BloqueiaCriacaoAtendOpo(VJJ->VJJ_TIPO, VJJ->VJJ_FILDEA, .t.)
		Return .f.
	EndIf

	If ! VA1100523_ItensSemOportunidade(VJJ->VJJ_CODIGO, .t.)
		Return .f.
	EndIf

	oModel := FWLoadModel( 'VEIA110' )
	oStruVJJ := FWFormStruct( 2, 'VJJ' )
	oStruVJK := FWFormStruct( 2, 'VJK' , { |x| AllTrim(x) $ "/VJK_CODIGO/VJK_ID/VJK_MODEID/VJK_MODNAM/VJK_BASECD/VJK_CODMAR/VJK_MODVEI/VJK_FILOPO/VJK_CODOPO/VJK_CODINT/VJK_FILTRA/VJK_NUMTRA/VJK_ITETRA/" } )

	oStruVJJ:SetProperty("*", MVC_VIEW_CANCHANGE , .F. )

	oModel:GetModel("MODEL_VJK"):SetLoadFilter( , "VJK_CODOPO = ' ' AND VJK_DELETE = '0' AND VJK_INTEGR = '1'" )

	oModel:SetPost( { || VA1100473_ValidacaoRelacionamento(oModel, "VJK_CODOPO", "VJK_CODINT") } )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddGrid( 'VIEW_VJK', oStruVJK, 'MODEL_VJK' )
	oView:AddOtherObject('VIEW_VDL', { |oPanel| VA1100403_BrowseVDL(oPanel) })

	oView:CreateHorizontalBox( 'TELA_VJK' , 40 )
	oView:CreateHorizontalBox( 'TELA_VDL' , 60 )

	oView:SetOwnerView('VIEW_VJK', 'TELA_VJK')
	oView:SetOwnerView('VIEW_VDL', 'TELA_VDL')

	oView:SetNoInsertLine('VIEW_VJK')

	oView:EnableTitleView('VIEW_VDL', STR0083 + ' - Protheus') // Relação Oportunidade/Interesse

	oView:SetCloseOnOk({||.T.})

	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0069 + " - Protheus") // Lista de Modelos
	oExecView:setModel(oModel)
	oExecView:setView(oView)
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)

	cFilAnt := cBkpFilAnt

Return .t.

/*/{Protheus.doc} VA1100473_ValidacaoRelacionamento
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@param cCpoCodigo, characters, description
@param cCpoItem, characters, description
@type function
/*/
Function VA1100473_ValidacaoRelacionamento(oModel, cCpoCodigo, cCpoItem)

	Local oModelVJK := oModel:GetModel("MODEL_VJK")
	Local nTamVJK := oModelVJK:Length()
	Local nPos, nPosSeek
	Local cCodigo
	Local cItem

	For nPos := 1 to nTamVJK
		cCodigo := oModelVJK:GetValue(cCpoCodigo, nPos)
		cItem := oModelVJK:GetValue(cCpoItem, nPos)
		For nPosSeek := 1 to nTamVJK
			If nPosSeek == nPos
				Loop
			EndIf

			If oModelVJK:GetValue(cCpoCodigo, nPosSeek) == cCodigo .and. oModelVJK:GetValue(cCpoItem,nPosSeek) == cItem
				Help(NIL, NIL,"VA110ERR11",,;
					STR0084 + CRLF + cCodigo + " - " + cItem,1,0,NIL, NIL, NIL, NIL, NIL,; // "Registro já selecionado em outra cotação."
					{ STR0085 } ) // "Verifique o relacionamento para garantir que o mesmo registro não seja em mais de uma cotação do JDQuote."
				Return .f.
			EndIf
		Next nPosSeek
	Next nPos

Return .t.


/*/{Protheus.doc} VA1100403_BrowseVDL
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oPanel, object, description
@type function
/*/
Function VA1100403_BrowseVDL(oPanel)

	Local oDMSBrwStru := OFBrowseStruct():New()
	Local cQuery := ""
	Local lFiltraSA1 := .f.

	Private cAliasVDL

	oDMSBrwStru := OFBrowseStruct():New({"VDL", "VDM", "VJU"})

	oDMSBrwStru:AddField( "VDL_FILIAL" , "" , .f. )
	oDMSBrwStru:AddField( "VDL_CODOPO" )
	oDMSBrwStru:AddField( "VDM_CODINT" )
	oDMSBrwStru:AddField( "VDM_FILATE" )
	oDMSBrwStru:AddField( "VDM_NUMATE" )
	oDMSBrwStru:AddField( "VDM_ITETRA" )
	oDMSBrwStru:AddField( "VDL_CODCLI" )
	oDMSBrwStru:AddField( "VDL_LOJCLI" )
	oDMSBrwStru:AddField( "VDL_NOMCLI" )
	oDMSBrwStru:AddField( "VDM_CODMAR" )
	oDMSBrwStru:AddField( "VDM_MODVEI" )
	oDMSBrwStru:AddField( "VDM_VLRVDA" )
	oDMSBrwStru:AddField( "VDM_VLRNEG" )
	oDMSBrwStru:AddField( "VJU_MODEID" )
	oDMSBrwStru:AddField( "VJU_BASECD" )

	oDMSBrwStru:CriaTabTmp()
	cAliasVDL := oDMSBrwStru:GetAlias()

	VJP->(dbSetOrder(1))
	If VJP->(msSeek(FWxFilial("VJP") + VJJ->VJJ_CODVJP))
		If !Empty(VJP->VJP_A1COD) .AND. VJP->VJP_A1FIL == FWxFilial("SA1")
			lFiltraSA1 := .t.
		EndIf
	EndIf

	cQuery := ;
		"SELECT VDL_FILIAL, VDL_CODOPO, VDM_CODINT, VDM_FILATE, VDM_NUMATE, VDM_ITETRA, VDL_CODCLI, VDL_LOJCLI, VDL_NOMCLI, VDM_CODMAR, VDM_MODVEI, VDM_VLRVDA, VDM_VLRNEG, COALESCE(VJU_MODEID, ' ' ) VJU_MODEID, COALESCE(VJU_BASECD, ' ' ) VJU_BASECD" +;
		 " FROM " + RetSQLName("VDL") + " VDL " +;
			" JOIN " + RetSQLName("VDM") + " VDM " + ;
				" ON VDM.VDM_FILIAL = VDL.VDL_FILIAL " +;
				"AND VDM.VDM_CODOPO = VDL.VDL_CODOPO " +;
				"AND VDM.D_E_L_E_T_ = ' '" +;
			" LEFT JOIN " + RetSQLName("VJU") + " VJU " + ;
				" ON VJU.VJU_FILIAL = '" + FWxFilial("VJU") + "' " +;
				"AND VJU.VJU_CODMAR = VDM.VDM_CODMAR AND VJU.VJU_CODMAR <> ' ' " +;
				"AND VJU.VJU_MODVEI = VDM.VDM_MODVEI " +;
				"AND VJU.D_E_L_E_T_ = ' '" +;
		"WHERE VDL.VDL_FILIAL = '" + FWxFilial("VDL") + "'" +;
		 " AND NOT EXISTS ( SELECT VJK.R_E_C_N_O_ " +;
								  " FROM " + RetSQLName("VJK") + " VJK " +;
								 " WHERE VJK.VJK_FILOPO = VDM.VDM_FILIAL " +;
								 	" AND VJK.VJK_CODOPO = VDM.VDM_CODOPO " +;
								 	" AND VJK.VJK_CODINT = VDM.VDM_CODINT " +;
								 	" AND VJK.D_E_L_E_T_ = ' ' )" +;
				"AND VDL.D_E_L_E_T_ = ' '"

	If lFiltraSA1
		cQuery += " AND VDM.VDM_CODCLI = '" + VJP->VJP_A1COD + "' " + ;
			" AND VDM.VDM_LOJCLI = '" + VJP->VJP_A1LOJA + "'"
	EndIf

	oDMSBrwStru:LoadData( cQuery )

	oBrwPainel := FWMBrowse():New()
	oBrwPainel:SetOwner(oPanel)
	oBrwPainel:SetAlias(cAliasVDL)
	oBrwPainel:SetTemporary(.t.)
	oBrwPainel:DisableLocate()
	oBrwPainel:DisableDetails()
	oBrwPainel:DisableReport()
	oBrwPainel:SetAmbiente(.F.)
	oBrwPainel:SetWalkthru(.F.)
	oBrwPainel:SetMenuDef("")
	oBrwPainel:SetInsert(.f.)
	oBrwPainel:SetUseFilter()

	oBrwPainel:SetSeek(.T.,oDMSBrwStru:GetSeek())
	oBrwPainel:SetFieldFilter(oDMSBrwStru:GetColFilter())
	oBrwPainel:SetQueryIndex(oDMSBrwStru:GetIndexes())

	oDMSBrwStru:SetBrwOwner(oBrwPainel)
	oDMSBrwStru:AddBrwColumn()

	oBrwPainel:SetChange( { || VA1100413_AtualizaCampoOportunidade( oBrwPainel:GetAlias() ) })

	oBrwPainel:Activate()

Return

/*/{Protheus.doc} VA1100413_AtualizaCampoOportunidade
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cAliasBrw, characters, description
@type function
/*/
Function VA1100413_AtualizaCampoOportunidade( cAliasBrw )

	Local oModel := FWModelActive()
	Local oView := FWViewActive()
	Local oModelVJK := oModel:GetModel("MODEL_VJK")

	oModelVJK:SetValue("VJK_FILOPO"  , (cAliasBrw)->VDL_FILIAL )
	oModelVJK:SetValue("VJK_CODOPO"  , (cAliasBrw)->VDL_CODOPO )
	oModelVJK:SetValue("VJK_CODINT"  , (cAliasBrw)->VDM_CODINT )

	oModelVJK:SetValue("VJK_FILTRA"  , (cAliasBrw)->VDM_FILATE )
	oModelVJK:SetValue("VJK_NUMTRA"  , (cAliasBrw)->VDM_NUMATE )
	oModelVJK:SetValue("VJK_ITETRA"  , (cAliasBrw)->VDM_ITETRA )

	oModelVJK:SetValue("VJK_CODMAR"  , (cAliasBrw)->VDM_CODMAR )
	oModelVJK:SetValue("VJK_MODVEI"  , (cAliasBrw)->VDM_MODVEI )

	oModelVJK:SetValue("VJK_MODEID"  , (cAliasBrw)->VJU_MODEID )
	oModelVJK:SetValue("VJK_BASECD"  , (cAliasBrw)->VJU_BASECD )

	oView:Refresh()

Return



/*/{Protheus.doc} VA1100423_DesvinculaAtendimento
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cFilAte, characters, description
@param cNumAte, characters, description
@param cIteAte, characters, description
@type function
/*/
Function VA1100423_DesvinculaAtendimento(cFilAte, cNumAte, cIteAte)

	Local oModelJDquote
	Local oModelVJK

	If FWAliasInDic("VJJ") == .F.
		Return .t.
	EndIf

	If ! VA1100453_PosAPartirAtendimento(cFilAte, cNumAte, cIteAte)
		Return .t.
	EndIf

	oModelJDquote := FWLoadModel( 'VEIA110' )
	oModelJDquote:SetOperation( MODEL_OPERATION_UPDATE )
	If ! oModelJDquote:Activate()
		MostraErro()
	EndIf

	oModelVJK := oModelJDquote:GetModel("MODEL_VJK")
	If oModelVJK:SeekLine({ { "VJK_FILTRA" , cFilAte },{ "VJK_NUMTRA" , cNumAte },{ "VJK_ITETRA" , cIteAte } })
		oModelVJK:SetValue("VJK_FILTRA", " ")
		oModelVJK:SetValue("VJK_NUMTRA", " ")
		oModelVJK:SetValue("VJK_ITETRA", " ")
	EndIf

	If oModelJDquote:VldData()
		oModelJDquote:CommitData()
	EndIf
	oModelJDquote:DeActivate()

Return .t.

/*/{Protheus.doc} VA1100433_DesvinculaOportunidade
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cFilOpo, characters, description
@param cNumOpo, characters, description
@param cIntOpo, characters, description
@type function
/*/
Function VA1100433_DesvinculaOportunidade(cFilOpo, cNumOpo, cIntOpo)

	Local oModelJDquote
	Local oModelVJK

	If FWAliasInDic("VJJ") == .F.
		Return .t.
	EndIf

	If ! VA1100443_PosAPartirOportunidade(cFilOpo, cNumOpo, cIntOpo)
		Return .t.
	EndIf
	DbSelectArea("VJJ")

	oModelJDquote := FWLoadModel( 'VEIA110' )
	oModelJDquote:SetOperation( MODEL_OPERATION_UPDATE )
	If ! oModelJDquote:Activate()
		MostraErro()
	EndIf

	oModelVJK := oModelJDquote:GetModel("MODEL_VJK")
	If oModelVJK:SeekLine({ { "VJK_FILOPO" , cFilOpo },{ "VJK_CODOPO" , cNumOpo },{ "VJK_CODINT" , cIntOpo } })
		oModelVJK:SetValue("VJK_FILOPO", " ")
		oModelVJK:SetValue("VJK_CODOPO", " ")
		oModelVJK:SetValue("VJK_CODINT", " ")

		If oModelJDquote:VldData()
			oModelJDquote:CommitData()
		EndIf

	EndIf

	oModelJDquote:DeActivate()

Return .t.

/*/{Protheus.doc} VA1100443_PosAPartirOportunidade
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cFilOpo, characters, description
@param cNumOpo, characters, description
@param cIntOpo, characters, description
@type function
/*/
Function VA1100443_PosAPartirOportunidade(cFilOpo, cNumOpo, cIntOpo)

	Local nRecVJJ
	Local cSQL

	cSQL := ;
		"SELECT VJJ.R_E_C_N_O_ " +;
		 " FROM " + RetSQLName("VJK") + " VJK " +;
				" JOIN " + RetSQLName("VJJ") + " VJJ " +;
					 " ON VJJ.VJJ_FILIAL = VJK.VJK_FILIAL " +;
					" AND VJJ.VJJ_CODIGO = VJK.VJK_CODVJJ " +;
					" AND VJJ.D_E_L_E_T_ = ' '" +;
		" WHERE VJK.VJK_FILIAL = '" + FWxFilial("VJK") + "' " +;
		  " AND VJK.VJK_FILOPO = '" + cFilOpo + "' " +;
		  " AND VJK.VJK_CODOPO = '" + cNumOpo + "' " +;
		  " AND VJK.VJK_CODINT = '" + cIntOpo + "' " +;
		  " AND VJK.D_E_L_E_T_ = ' '"
	nRecVJJ := FM_SQL(cSQL)

	If nRecVJJ == 0
		Return .f.
	EndIf

	VJJ->(dbGoTo(nRecVJJ))

Return .t.

/*/{Protheus.doc} VA1100453_PosAPartirAtendimento
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cFilAte, characters, description
@param cNumAte, characters, description
@param cIteAte, characters, description
@type function
/*/
Function VA1100453_PosAPartirAtendimento(cFilAte, cNumAte, cIteAte)

	Local cSQL
	Local nRecVJJ

	cSQL := ;
		"SELECT VJJ.R_E_C_N_O_ " +;
		 " FROM " + RetSQLName("VJK") + " VJK " +;
				" JOIN " + RetSQLName("VJJ") + " VJJ " +;
					 " ON VJJ.VJJ_FILIAL = VJK.VJK_FILIAL " +;
					" AND VJJ.VJJ_CODIGO = VJK.VJK_CODVJJ " +;
					" AND VJJ.D_E_L_E_T_ = ' '" +;
		" WHERE VJK.VJK_FILIAL = '" + FWxFilial("VJK") + "' " +;
		  " AND VJK.VJK_FILTRA = '" + cFilAte + "' " +;
		  " AND VJK.VJK_NUMTRA = '" + cNumAte + "' " +;
		  " AND VJK.VJK_ITETRA = '" + cIteAte + "' " +;
		  " AND VJK.D_E_L_E_T_ = ' '"
	nRecVJJ := FM_SQL(cSQL)

	If nRecVJJ == 0
		Return .f.
	EndIf

	VJJ->(dbGoTo(nRecVJJ))

Return .t.

/*/{Protheus.doc} VA1100463_VinculaAtendimento
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cFilOpo, characters, description
@param cNumOpo, characters, description
@param cIntOpo, characters, description
@param cFilAte, characters, description
@param cNumAte, characters, description
@param cIteAte, characters, description
@type function
/*/
Function VA1100463_VinculaAtendimento(cFilOpo, cNumOpo, cIntOpo, cFilAte, cNumAte, cIteAte)

	Local oModelJDquote
	Local oModelVJK

	If FWAliasInDic("VJJ") == .F.
		Return .t.
	EndIf

	If ! VA1100443_PosAPartirOportunidade(cFilOpo, cNumOpo, cIntOpo)
		Return .t.
	EndIf

	DbSelectArea("VJJ")

	oModelJDquote := FWLoadModel( 'VEIA110' )
	oModelJDquote:SetOperation( MODEL_OPERATION_UPDATE )
	If ! oModelJDquote:Activate()
		MostraErro()
	EndIf

	oModelVJK := oModelJDquote:GetModel("MODEL_VJK")
	If oModelVJK:SeekLine({ { "VJK_FILOPO" , cFilOpo },{ "VJK_CODOPO" , cNumOpo },{ "VJK_CODINT" , cIntOpo } })
		oModelVJK:SetValue("VJK_FILTRA", cFilAnt)
		oModelVJK:SetValue("VJK_NUMTRA", cNumAte)
		oModelVJK:SetValue("VJK_ITETRA", cIteAte)

		If oModelJDquote:VldData()
			oModelJDquote:CommitData()
		EndIf
	EndIf

	oModelJDquote:DeActivate()

Return .t.

/*/{Protheus.doc} VA1100483_CotacaoDeletada
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oJDQuote, object, description
@param dDataMod, date, description
@param nID, numeric, description
@type function
/*/
Function VA1100483_CotacaoDeletada(oJDQuote, dDataMod, nID)
	Local dDataFinal := dDataMod + 300

	If dDataFinal > dDataBase
		dDataFinal := dDataBase
	EndIf

	VA1100093_GetQuote(oJDQuote, dDataMod - 10 , dDataFinal, nID)

	If Len(oJDQuote:aResponse) == 0
		FMX_HELP("VA110ERR12",STR0077) // "Não foi possível verificar se a cotação foi excluída no portal JDQuote."
		Return .f.
	EndIf

Return .t.

/*/{Protheus.doc} VA1100493_LegendaItem
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VA1100493_LegendaItem()

	If ! INCLUI
		Do Case
		Case VJK->VJK_DELETE == "1"
			Return "br_vermelho.png"
		Case VJK->VJK_INTEGR == "0"
			Return "br_preto.png"
		Case !Empty(VJK->VJK_CODOPO) .or. !Empty(VJK->VJK_NUMTRA)
			Return "br_amarelo.png"
		OtherWise
			Return "br_verde.png"
		EndCase
	Else
		Return ""
	EndIf

Return ""


/*/{Protheus.doc} VA1100503_NomeCliente
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VA1100503_NomeCliente()
Return Posicione("VJP", 1, xFilial("VJP")+VJJ_CODVJP, "AllTrim(VJP_CFNAME) + ' ' + AllTrim(VJP_CLNAME)")

/*/{Protheus.doc} VA1100513_LegendaUsado
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VA1100513_LegendaUsado()

	If ! INCLUI
		Do Case
		Case VJO->VJO_DELETE == "1"
			Return "br_vermelho.png"
		OtherWise
			Return "br_verde.png"
		EndCase
	Else
		Return ""
	EndIf

Return ""


/*/{Protheus.doc} VA1100523_ItensSemOportunidade
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cCodVJJ, characters, description
@type function
/*/
Function VA1100523_ItensSemOportunidade(cCodVJJ, lHelp)
	Local lRet := .t.

	BeginSql Alias "TPESQVJK"

		COLUMN VJKCONT AS NUMERIC(10,2)

		SELECT COUNT(*) VJKCONT
		  FROM %Table:VJK% VJK
		 WHERE VJK.VJK_FILIAL= %xfilial:VJK%
			AND VJK.VJK_CODVJJ = %exp:cCodVJJ%
			AND VJK.VJK_CODOPO = ' '
			AND VJK.VJK_NUMTRA = ' '
			AND VJK.VJK_DELETE = '0'
			AND VJK.VJK_INTEGR = '1'
			AND %NotDel%

	EndSql

	If TPESQVJK->(Eof()) .or. TPESQVJK->VJKCONT == 0
		If lHelp
			FMX_HELP("VA110ERR14",STR0052,STR0012) // "Todos os itens válidos da cotação já possuem oportunidade/atendimento relacionado." // "Selecione uma outra cotação para relacionar com oportunidade."
		EndIf
		lRet := .f.
	EndIf

	TPESQVJK->(dbCloseArea())

Return lRet


/*/{Protheus.doc} VA1100533_RelacionaAtendimento
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cAlias, characters, description
@param nReg, numeric, description
@param nOpc, numeric, description
@type function
/*/
Function VA1100533_RelacionaAtendimento(cAlias, nReg, nOpc)

	Local oView
	Local oModel
	Local oStruVJJ
	Local oStruVJK
	Local nLinha
	Local lSemModelo := .f.
	Local cBkpFilAnt := cFilAnt

	Private oBrwPainel

	If VA1100333_BloqueiaCriacaoAtendOpo(VJJ->VJJ_TIPO, VJJ->VJJ_FILDEA, .t.)
		Return .f.
	EndIf

	If ! VA1100543_ItensSemAtendimento(VJJ->VJJ_CODIGO, .t.)
		Return .f.
	EndIf

	oModel := FWLoadModel( 'VEIA110' )
	oStruVJJ := FWFormStruct( 2, 'VJJ' )
	oStruVJK := FWFormStruct( 2, 'VJK' , { |x| AllTrim(x) $ "/VJK_CODIGO/VJK_ID/VJK_MODEID/VJK_MODNAM/VJK_BASECD/VJK_CODMAR/VJK_MODVEI/VJK_FILOPO/VJK_CODOPO/VJK_CODINT/VJK_FILTRA/VJK_NUMTRA/VJK_ITETRA/" } )

	oStruVJJ:SetProperty("*", MVC_VIEW_CANCHANGE , .F. )


	oModel:GetModel("MODEL_VJK"):SetLoadFilter( , "VJK_NUMTRA = ' ' AND VJK_DELETE = '0' AND VJK_INTEGR = '1'" )

	oModel:SetPost( { || VA1100473_ValidacaoRelacionamento(oModel, "VJK_NUMTRA", "VJK_ITETRA") } )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddGrid( 'VIEW_VJK', oStruVJK, 'MODEL_VJK' )
	oView:AddOtherObject('VIEW_VDL', { |oPanel| VA1100553_BrowseVV9(oPanel) })

	oView:CreateHorizontalBox( 'TELA_VJK' , 40 )
	oView:CreateHorizontalBox( 'TELA_VDL' , 60 )

	oView:SetOwnerView('VIEW_VJK', 'TELA_VJK')
	oView:SetOwnerView('VIEW_VDL', 'TELA_VDL')

	//oView:GetModel("MODEL_VJK"):SetLoadFilter( { { 'VJK_CODOPO', "'" + Space(TamSX3("VJK_CODOPO")[1]) + "'", MVC_LOADFILTER_EQUAL } } )
	oView:SetNoInsertLine('VIEW_VJK')

	oView:EnableTitleView('VIEW_VDL', STR0037 + ' - Protheus') // Relação Atendimento

	oView:SetCloseOnOk({||.T.})

	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0069 + " - Protheus") // Lista de Modelos
	oExecView:setModel(oModel)
	oExecView:setView(oView)
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)

	cFilAnt := cBkpFilAnt

Return .t.

/*/{Protheus.doc} VA1100543_ItensSemAtendimento
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cCodVJJ, characters, description
@type function
/*/
Function VA1100543_ItensSemAtendimento(cCodVJJ, lHelp)
	Local lRet := .t.

	BeginSql Alias "TPESQVJK"

		COLUMN VJKCONT AS NUMERIC(10,2)

		SELECT COUNT(*) VJKCONT
		  FROM %Table:VJK% VJK
		 WHERE VJK.VJK_FILIAL= %xfilial:VJK%
			AND VJK.VJK_CODVJJ = %exp:cCodVJJ%
			AND VJK.VJK_CODOPO = ' '
			AND VJK.VJK_NUMTRA = ' '
			AND VJK.VJK_DELETE = '0'
			AND VJK.VJK_INTEGR = '1'
			AND %NotDel%

	EndSql

	If TPESQVJK->(Eof()) .or. TPESQVJK->VJKCONT == 0
		If lHelp
			FMX_HELP("VA110ERR15",STR0052,STR0026) // "Todos os itens válidos da cotação já possuem oportunidade/atendimento relacionado." // "Selecione uma outra cotação para relacionar atendimento."
		EndIf

		lRet := .f.
	EndIf

	TPESQVJK->(dbCloseArea())

Return lRet


/*/{Protheus.doc} VA1100553_BrowseVV9
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oPanel, object, description
@type function
/*/
Function VA1100553_BrowseVV9(oPanel)

	Local oDMSBrwStru := OFBrowseStruct():New()
	Local cQuery := ""
	Local lFiltraSA1 := .f.

	Private cAliasVV9

	oDMSBrwStru := OFBrowseStruct():New({"VV9", "VV0", "VVA"})

	oDMSBrwStru:AddField( "VV9_FILIAL" , "" , .f. )
	oDMSBrwStru:AddField( "VV9_NUMATE" )
	oDMSBrwStru:AddField( "VVA_ITETRA" )
	oDMSBrwStru:AddField( "VDM_FILIAL" , "" , .f. )
	oDMSBrwStru:AddField( "VDM_CODOPO" )
	oDMSBrwStru:AddField( "VDM_CODINT" )
	oDMSBrwStru:AddField( "VV0_CODCLI" )
	oDMSBrwStru:AddField( "VV0_LOJA" )
	oDMSBrwStru:AddField( "A1_NOME" )
	oDMSBrwStru:AddField( "VVA_CHAINT" )
	oDMSBrwStru:AddField( "VVA_CHASSI" )
	oDMSBrwStru:AddField( "VVA_CODMAR" )
	oDMSBrwStru:AddField( "VVA_MODVEI" )
	oDMSBrwStru:AddField( "VVA_VALTAB" )
	oDMSBrwStru:AddField( "VVA_VALMOV" )
	oDMSBrwStru:AddField( "VJU_MODEID" )
	oDMSBrwStru:AddField( "VJU_BASECD" )

	oDMSBrwStru:CriaTabTmp()
	cAliasVV9 := oDMSBrwStru:GetAlias()

	VJP->(dbSetOrder(1))
	If VJP->(msSeek(FWxFilial("VJP") + VJJ->VJJ_CODVJP))
		If !Empty(VJP->VJP_A1COD) .AND. VJP->VJP_A1FIL == FWxFilial("SA1")
			lFiltraSA1 := .t.
		EndIf
	EndIf

	cQuery := ;
		"SELECT VV9_FILIAL, VV9_NUMATE, VVA_ITETRA, COALESCE(VDM_FILIAL, ' ') VDM_FILIAL, COALESCE(VDM_CODOPO, ' ') VDM_CODOPO, COALESCE(VDM_CODINT, ' ') VDM_CODINT, VV0_CODCLI, VV0_LOJA, COALESCE(A1_NOME, ' ') A1_NOME, VVA_CHAINT, VVA_CHASSI, VVA_CODMAR, VVA_MODVEI, VVA_VALTAB, VVA_VALMOV, COALESCE(VJU_MODEID, ' ') VJU_MODEID, COALESCE(VJU_BASECD, ' ') VJU_BASECD" +;
		 " FROM " + RetSQLName("VV9") + " VV9 " +;
			" JOIN " + RetSQLName("VV0") + " VV0 " + ;
				" ON VV0.VV0_FILIAL = VV9.VV9_FILIAL " +;
				"AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE " +;
				"AND VV0.D_E_L_E_T_ = ' '" +;
			" JOIN " + RetSQLName("VVA") + " VVA " + ;
				" ON VVA.VVA_FILIAL = VV9.VV9_FILIAL " +;
				"AND VVA.VVA_NUMTRA = VV9.VV9_NUMATE " +;
				"AND VVA.D_E_L_E_T_ = ' '" +;
			" LEFT JOIN " + RetSQLName("SA1") + " SA1 " + ;
				" ON SA1.A1_FILIAL = VV9.VV9_FILIAL " +;
				"AND SA1.A1_COD = VV0.VV0_CODCLI " +;
				"AND SA1.A1_LOJA = VV0.VV0_LOJA " +;
				"AND SA1.D_E_L_E_T_ = ' '" +;
			" LEFT JOIN " + RetSQLName("VDM") + " VDM " + ;
				" ON VDM.VDM_FILATE = VVA.VVA_FILIAL " +;
				"AND VDM.VDM_NUMATE = VVA.VVA_NUMTRA " +;
				"AND VDM.VDM_ITETRA = VVA.VVA_ITETRA " +;
				"AND VDM.D_E_L_E_T_ = ' '" +;
			" LEFT JOIN " + RetSQLName("VJU") + " VJU " + ;
				" ON VJU.VJU_FILIAL = '" + FWxFilial("VJU") + "' " +;
				"AND VJU.VJU_CODMAR = VVA.VVA_CODMAR AND VJU.VJU_CODMAR <> ' ' " +;
				"AND VJU.VJU_MODVEI = VVA.VVA_MODVEI " +;
				"AND VJU.D_E_L_E_T_ = ' '" +;
		"WHERE VV9.VV9_FILIAL = '" + FWxFilial("VV9") + "'" +;
		 " AND VV9.VV9_STATUS NOT IN ('C','R') " +;
		 " AND NOT EXISTS ( SELECT VJK.R_E_C_N_O_ " +;
								  " FROM " + RetSQLName("VJK") + " VJK " +;
								 " WHERE VJK.VJK_FILTRA = VVA.VVA_FILIAL " +;
								 	" AND VJK.VJK_NUMTRA = VVA.VVA_NUMTRA " +;
								 	" AND VJK.VJK_ITETRA = VVA.VVA_ITETRA " +;
								 	" AND VJK.D_E_L_E_T_ = ' ' )" +;
				"AND VV9.D_E_L_E_T_ = ' '"

	If lFiltraSA1
		cQuery += " AND VV0.VV0_CODCLI = '" + VJP->VJP_A1COD + "' " + ;
			" AND VV0.VV0_LOJA = '" + VJP->VJP_A1LOJA + "'"
	EndIf

	oDMSBrwStru:LoadData( cQuery )

	oBrwPainel := FWMBrowse():New()
	oBrwPainel:SetOwner(oPanel)
	oBrwPainel:SetAlias(cAliasVV9)
	oBrwPainel:SetTemporary(.t.)
	oBrwPainel:DisableLocate()
	oBrwPainel:DisableDetails()
	oBrwPainel:DisableReport()
	oBrwPainel:SetAmbiente(.F.)
	oBrwPainel:SetWalkthru(.F.)
	oBrwPainel:SetMenuDef("")
	oBrwPainel:SetInsert(.f.)
	oBrwPainel:SetUseFilter()

	oBrwPainel:SetSeek(.T.,oDMSBrwStru:GetSeek())
	oBrwPainel:SetFieldFilter(oDMSBrwStru:GetColFilter())
	oBrwPainel:SetQueryIndex(oDMSBrwStru:GetIndexes())

	oDMSBrwStru:SetBrwOwner(oBrwPainel)
	oDMSBrwStru:AddBrwColumn()

	oBrwPainel:SetChange( { || VA1100563_AtualizaCampoAtendimento( oBrwPainel:GetAlias() ) })

	oBrwPainel:Activate()

Return

/*/{Protheus.doc} VA1100563_AtualizaCampoAtendimento
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cAliasBrw, characters, description
@type function
/*/
Function VA1100563_AtualizaCampoAtendimento( cAliasBrw )

	Local oModel := FWModelActive()
	Local oView := FWViewActive()
	Local oModelVJK := oModel:GetModel("MODEL_VJK")

	oModelVJK:SetValue("VJK_FILOPO"  , (cAliasBrw)->VDM_FILIAL )
	oModelVJK:SetValue("VJK_CODOPO"  , (cAliasBrw)->VDM_CODOPO )
	oModelVJK:SetValue("VJK_CODINT"  , (cAliasBrw)->VDM_CODINT )

	oModelVJK:SetValue("VJK_FILTRA"  , (cAliasBrw)->VV9_FILIAL )
	oModelVJK:SetValue("VJK_NUMTRA"  , (cAliasBrw)->VV9_NUMATE )
	oModelVJK:SetValue("VJK_ITETRA"  , (cAliasBrw)->VVA_ITETRA )

	oModelVJK:SetValue("VJK_CODMAR"  , (cAliasBrw)->VVA_CODMAR )
	oModelVJK:SetValue("VJK_MODVEI"  , (cAliasBrw)->VVA_MODVEI )

	oModelVJK:SetValue("VJK_MODEID"  , (cAliasBrw)->VJU_MODEID )
	oModelVJK:SetValue("VJK_BASECD"  , (cAliasBrw)->VJU_BASECD )

	oView:Refresh()

Return

/*/{Protheus.doc} VA1100583_DeletarPedidoVenda
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param cCodVJJ, characters, description
@type function
/*/
Function VA1100583_DeletarPedidoVenda(cCodVJJ)

	BeginSql Alias "TPESQPO"

		COLUMN VJMREC AS NUMERIC(10,2)

		SELECT VJM.R_E_C_N_O_ VJMREC
		  FROM %Table:VJM% VJM
		 WHERE VJM.VJM_FILIAL= %xfilial:VJM%
			AND VJM.VJM_CODVJJ = %exp:cCodVJJ%
			AND VJM.VJM_DELETE = '0'
			AND %NotDel%

	EndSql

	While ! TPESQPO->(Eof())
		dbSelectArea("VJM")
		VJM->(dbGoTo( TPESQPO->VJMREC ))

		VA1120073_DeletarPO(.f.)

		TPESQPO->(dbSkip())
	End

	TPESQPO->(dbCloseArea())

Return 

/*/{Protheus.doc} VA1100593_SincVJKCotacaoPedido
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param nPOID, numeric, description
@param cCodVJJ, characters, description
@param oModel110, object, description
@type function
/*/
Static Function VA1100593_SincVJKCotacaoPedido(nPOID, cCodVJJ, oModel110)

	Local cSQL
	Local nRecVJM
	Local nRecVJK
	Local lRet
	Local oModelVJK
	Local nPosVJK

	If ! VA1120023_JaImportada(nPOID, @nRecVJM)
		Return .t.
	EndIf

	VJM->(dbGoTo(nRecVJM))

	cSQL := "SELECT VJK.R_E_C_N_O_ VJKRECNO " +;
		" FROM " + RetSQLName("VJK") + " VJK " +;
		" WHERE VJK.VJK_FILIAL = '" + xFilial("VJK") + "' " +;
		  " AND VJK.VJK_CODVJM = '" + VJM->VJM_CODIGO + "' " +;
		  " AND VJK.D_E_L_E_T_ = ' '" +;
		  " AND VJK.VJK_ITEM "

	oModelVJK := oModel110:GetModel("MODEL_VJK")

	For nPosVJK := 1 to oModelVJK:Length()
		If oModelVJK:GetValue("VJK_DELETE", nPosVJK) == "1"
			Loop
		EndIf

		oModelVJK:GoLine(nPosVJK)

		nRecVJK := FM_SQL(cSQL + " = '" + oModelVJK:GetValue("VJK_ITEM") + "' " )
		If nRecVJK <> 0
			VJK->(dbGoTo(nRecVJK))
			SetModelVal( oModelVJK , 'VJK_MODEID' , VJK->VJK_MODEID )
			SetModelVal( oModelVJK , 'VJK_BASECD' , VJK->VJK_BASECD )
			If ! Empty(VJK->VJK_CODMAR)
				SetModelVal( oModelVJK , 'VJK_CODMAR' , VJK->VJK_CODMAR )
			EndIf
			If ! Empty(VJK->VJK_MODVEI)
				SetModelVal( oModelVJK , 'VJK_MODVEI' , VJK->VJK_MODVEI )
			EndIf
			If ! Empty(VJK->VJK_SEGMOD)
				SetModelVal( oModelVJK , 'VJK_SEGMOD' , VJK->VJK_SEGMOD )
			EndIf
			SetModelVal( oModelVJK , 'VJK_INTEGR' , VJK->VJK_INTEGR )
		EndIf

	Next nPosVJK

	lRet := oModel110:VldData()

Return lRet

/*/{Protheus.doc} VA1100613_CodigoVendedor
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param cSALID, characters, description
@type function
/*/
Function VA1100613_CodigoVendedor( cSALID )

	Local cCodVendedor := ""

	BeginSql Alias "TPESQVAI"

		SELECT VAI.VAI_CODVEN
		  FROM %Table:VAI% VAI
		 WHERE VAI.VAI_FILIAL = %xFilial:VAI%
		   AND VAI.VAI_FABUSR = %exp:cSALID%
		   AND %NotDel%
	EndSql

	If ! TPESQVAI->(Eof())
		cCodVendedor := TPESQVAI->VAI_CODVEN
	EndIf

	TPESQVAI->(dbCloseArea())

Return cCodVendedor


/*/{Protheus.doc} VA1100623_SetError
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param cOrigem, characters, description
@param aErro, array, description
@type function
/*/
Static Function VA1100623_SetError(cOrigem, aErro)
	AutoGrLog(cOrigem)
	AutoGrLog( " " )
	AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' ) //  [1] Id do formulário de origem
	AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' ) //  [2] Id do campo de origem
	AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' ) //  [3] Id do formulário de erro
	AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' ) //  [4] Id do campo de erro
	AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' ) //  [5] Id do erro
	AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' ) //  [6] mensagem do erro
	AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' ) //  [7] mensagem da solução
	AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' ) //  [8] Valor atribuido
	AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' ) //  [9] Valor anterior
Return

/*/{Protheus.doc} VA1100633_DadosCKCDiferentes
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oCustomer, object, description
@type function
/*/
Static function VA1100633_DadosCKCDiferentes(oCustomer)

	if empty(VJP->VJP_A1COD) .OR. VJP->VJP_ID <> oCustomer:entityId
		return .f.
	endif 

	Do Case
		//Case VJP->VJP_ID     <> oCustomer:entityId                              ; return .t.
		Case AllTrim(VJP->VJP_CBNAME) <> AllTrim(oCustomer:businessName)                 ; return .t.
		Case AllTrim(VJP->VJP_CFNAME) <> AllTrim(oCustomer:firstName)                    ; return .t.
		Case AllTrim(VJP->VJP_CLNAME) <> AllTrim(oCustomer:lastName)                     ; return .t.
		Case AllTrim(VJP->VJP_PHONE)  <> AllTrim(oCustomer:phoneNumber)                  ; return .t.
		Case AllTrim(VJP->VJP_TAXID)  <> AllTrim(oCustomer:taxID)                        ; return .t.
		Case AllTrim(VJP->VJP_DBSCN)  <> AllTrim(oCustomer:dbsCustomerNumber)            ; return .t.
		Case AllTrim(VJP->VJP_CADDR1) <> AllTrim(oCustomer:oAddress:addressLine1)        ; return .t.
		Case AllTrim(VJP->VJP_CADDR2) <> AllTrim(oCustomer:oAddress:addressLine2)        ; return .t.
		Case AllTrim(VJP->VJP_CCITY)  <> AllTrim(oCustomer:oAddress:city)                ; return .t.
		Case AllTrim(VJP->VJP_CSTATE) <> AllTrim(oCustomer:oAddress:state)               ; return .t.
		Case AllTrim(VJP->VJP_CCOUNT) <> AllTrim(oCustomer:oAddress:country)             ; return .t.
		Case AllTrim(VJP->VJP_CZIPC)  <> AllTrim(StrTran(oCustomer:oAddress:zip,"-","")) ; return .t.
	EndCase

Return .f.

/*/{Protheus.doc} VA1120153_LimparToken

Limpar token de comunicacao com o Okta

@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cAlias, characters, description
@param nReg, numeric, description
@param nOpc, numeric, description
@type function
/*/
Function VA1100643_LimparToken(cAlias, nReg, nOpc)

	Local oOkta := OFJDOkta():New()

	oOkta := OFJDOkta():New()
	if oOkta:oConfig:maintainQuoteJDQuote()
		oOkta:SetMaintainQuoteJDQuote()
		oOkta:cleanProfile()
		MsgInfo(STR0087) // "Token removido."
	Else
		MsgInfo(STR0088) // "Sistema não está configurado para utilizar a autenticação via Okta."
	endif
Return
