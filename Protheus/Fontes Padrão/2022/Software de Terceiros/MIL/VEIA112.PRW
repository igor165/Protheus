#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWEditPanel.CH'

#INCLUDE "VEIA112.CH"

/*/{Protheus.doc} VEIA112

Integração Protheus vs PO

@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VEIA112()
	Local oBrowse

	// VJM - JD - PO
	// VJK - JD - Itens da Cotacao
	// VJL - JD - Opcionais Equip.
	// VJP - JD - Cliente CKC
	oBrowse := BrowseDef()
	oBrowse:Activate()
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
	//Local oStruVJM := FWFormStruct( 1, 'VJM' )
	Local oStruVJM := FWFormStruct( 1, 'VJM' )
	Local oStruVJK := FWFormStruct( 1, 'VJK' )
	Local oStruVJL := FWFormStruct( 1, 'VJL' )

	oStruVJK:SetProperty('VJK_CODVJM',MODEL_FIELD_OBRIGAT,.f.)

	oStruVJL:SetProperty('VJL_CODVJK',MODEL_FIELD_OBRIGAT,.f.)

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


	oModel := MPFormModel():New('VEIA112' )
	oModel:AddFields('MODEL_VJM', /*cOwner*/, oStruVJM , /* <bPre > */ , /* <bPost > */ , /* <bLoad> */ )
	oModel:AddGrid(  'MODEL_VJK', 'MODEL_VJM',oStruVJK, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* bLoad */ )
	oModel:AddGrid(  'MODEL_VJL', 'MODEL_VJK',oStruVJL, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* bLoad */ )

	oModel:SetDescription( "JDQuote - PO" ) //
	oModel:GetModel( 'MODEL_VJM' ):SetDescription( STR0002 ) // 'Dados do PO'
	oModel:GetModel( 'MODEL_VJK' ):SetDescription( STR0003 ) // "Dados dos equipamentos do PO"
	oModel:GetModel( 'MODEL_VJL' ):SetDescription( STR0004 ) // "Dados dos opcionais dos equipamentos do PO"

	oModel:SetRelation('MODEL_VJK', { { 'VJK_FILIAL' , 'xFilial("VJK")' } , { 'VJK_CODVJM' , 'VJM_CODIGO' } } , 'VJK_FILIAL+VJK_CODVJM' )
	oModel:SetRelation('MODEL_VJL', { { 'VJL_FILIAL' , 'xFilial("VJL")' } , { 'VJL_CODVJK' , 'VJK_CODIGO' } } , 'VJL_FILIAL+VJL_CODVJK' )

	oModel:GetModel('MODEL_VJK'):SetOptional( .T. )
	oModel:GetModel('MODEL_VJL'):SetOptional( .T. )

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
	Local oModel := FWLoadModel( 'VEIA112' )
	Local oStruVJM := FWFormStruct( 2, 'VJM' )
	Local oStruVJK := FWFormStruct( 2, 'VJK', { |x| ! AllTrim(x) $ "VJK_CODVJJ/VJK_ID/VJK_MAKEID/VJK_LIST/VJK_COST/VJK_FILOPO/VJK_CODOPO/VJK_CODINT/VJK_FILTRA/VJK_NUMTRA/VJK_ITETRA/" } )
	Local oStruVJL := FWFormStruct( 2, 'VJL' )

	oStruVJK:RemoveField('VJK_CODIGO')
	oStruVJK:RemoveField('VJK_CODVJM')
	oStruVJK:AddField( 'LEGENDA','01',' ','Legenda',, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, )

	oStruVJL:RemoveField('VJL_CODIGO')
	oStruVJL:RemoveField('VJL_CODVJK')

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField('VIEW_VJM', oStruVJM, 'MODEL_VJM' )
	oView:AddGrid( 'VIEW_VJK', oStruVJK, 'MODEL_VJK' )
	oView:AddGrid( 'VIEW_VJL', oStruVJL, 'MODEL_VJL' )

	oView:CreateFolder( 'TELA_FOLDER' )
	oView:AddSheet('TELA_FOLDER','ABA_COTACAO', STR0005 ) // 'Cotação'
	oView:AddSheet('TELA_FOLDER','ABA_EQUIP'  , STR0006 ) // 'Equipamentos'

	oView:CreateHorizontalBox( 'TELA_VJM', 100, , , 'TELA_FOLDER', 'ABA_COTACAO')

	oView:CreateHorizontalBox( 'TELA_VJK', 30 , , , 'TELA_FOLDER', 'ABA_EQUIP')
	oView:CreateHorizontalBox( 'TELA_VJL', 70 , , , 'TELA_FOLDER', 'ABA_EQUIP')

	oView:SetOwnerView( 'VIEW_VJM', 'TELA_VJM' )
	oView:SetOwnerView( 'VIEW_VJK', 'TELA_VJK' )
	oView:SetOwnerView( 'VIEW_VJL', 'TELA_VJL' )

	oView:EnableTitleView('VIEW_VJK', STR0006 ) // 'Equipamentos'
	oView:EnableTitleView('VIEW_VJL', STR0007 ) // 'Opcionais do Equipamento'

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
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.VEIA112' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0009 ACTION 'VA1120033_Atualizar' OPERATION 4 ACCESS 0 // 'Atualizar'
	ADD OPTION aRotina TITLE STR0010 ACTION 'VA1120043_GetPDF' OPERATION 4 ACCESS 0 // 'Visualizar PDF'
	ADD OPTION aRotina TITLE STR0011 ACTION 'VIEWDEF.VEIA112' OPERATION 8 ACCESS 0 // 'Imprimir'
	ADD OPTION aRotina TITLE STR0024 ACTION 'VA1120153_LimparToken' OPERATION 8 ACCESS 0 // 'Limpar Token'
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
	oBrowse:SetAlias('VJM')
	oBrowse:SetDescription( STR0001 ) // 'Cadastro de PO do JDQuote'

	oBrowse:SetBlkBackColor( { || IIf( VJM_DELETE == "1" , CLR_HGRAY , NIL ) } )

Return oBrowse

/*/{Protheus.doc} VA1120033_Atualizar
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
Function VA1120033_Atualizar(cAlias, nReg, nOpc)

	//Local oJDQuotePO := VEJDQuotePODataService():New()
	Local lProcessado := .f.
	Local aListQuote := {}

	Private lAbortPrint := .f. // Variavel utilizada pelo Processa

	VJJ->(dbSetOrder(1))
	If ! VJJ->(dbSeek(FWxFilial("VJJ") + VJM->VJM_CODVJJ))
		MsgInfo("Cotação não encontrada")
		Return .f.
	EndIf

	dbSelectArea("VJJ")
	//VA1100363_ProcessaImportacao({{VJJ->VJJ_CODIGO}})
	aListQuote := { { VJJ->VJJ_ID , VJJ->VJJ_TIPO } }
	Processa( { || VA1100043_ImportarQuote(aListQuote, .f. ,, .t.) }, STR0012, STR0013,.t.) // Aguarde // Importando/Atualizando PO

Return

/*/{Protheus.doc} VA1120063_ConsultaWebService
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param nQuoteId, numeric, description
@param oJDQuotePO, object, description
@type function
/*/
Function VA1120063_ConsultaWebService(nQuoteId, oJDQuotePO)

	Local lRetorno

	oJDQuotePO:Clear()
	lRetorno := oJDQuotePO:getPODetailByQuoteID(nQuoteId)

Return lRetorno

/*/{Protheus.doc} VA1120043_GetPDF
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
Function VA1120043_GetPDF(cAlias, nReg, nOpc)

	Local oJDQuotePO := VEJDQuotePODataService():New()
	Local lProcessado := .f.

	If ! VA1120123_PedidoVendaValido()
		FMX_HELP("VA112ERR01", STR0014) // "PO deletado."
		Return .f.
	EndIf

	VJJ->(dbSetOrder(1))
	If ! VJJ->(dbSeek(FWxFilial("VJJ") + VJM->VJM_CODVJJ))
		MsgInfo(STR0015) // "Cotação não encontrada."
		Return .f.
	EndIf

	MsgRun(STR0016 + " - " + cValToChar( VJM->VJM_POID ),"JDQuote - getPOPdf",{|| lProcessado := oJDQuotePO:getPOPdf(VJJ->VJJ_ID, VJM->VJM_POID) }) // "Consultando detalhes do PO"
	If ! lProcessado
		MsgInfo(STR0023) // "Não foi possivel obter o PDF deste PO."
		Return .t.
	EndIf

	cNomArq := AllTrim(GetTempPath()) + "jdpo_" + AllTrim(cValToChar(VJM->VJM_POID)) + ".pdf"
	oFWriter := FWFileWriter():New( cNomArq ,.t.)
	If ! oFWriter:Create()
		//Conout("VA1120043_GetPDF - ERRO: "+oFWriter:Error():Message)
		MsgInfo(STR0017 + CRLF + oFWriter:Error():Message) // "Não foi possível criar arquivo."
	Else
		oFWriter:Write( oJDQuotePO:aResponse[1]:pdf )
		oFWriter:Close()
		ShellExecute( "Open", cNomArq , "", AllTrim(GetTempPath()), 3 )
	EndIf

Return

/*/{Protheus.doc} VA1120083_PedidoVenda
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oJDQuotePO, object, description
@param cCodVJJ, characters, description
@param lMsg, logical, description
@param lAtuCotacao, logical, description
@type function
/*/
Function VA1120083_PedidoVenda(oJDQuotePO, cCodVJJ, lMsg, lAtuCotacao)

	Local lDeletar := .f.
	Local lExistVJJ := .f.

	If ! VA1120093_ValidaRetornoWS(oJDQuotePO, .t.)
		Return .f.
	EndIf
	Begin Transaction
		lExistVJJ := (cCodVJJ == VJM->VJM_CODVJJ .and. VA1120123_PedidoVendaValido())
		If ! lExistVJJ
			lExistVJJ := VA1120133_PosicionaVJM(cCodVJJ)
		EndIf

		If lExistVJJ
			// Possivelmente o usuário excluiu a PO da Cotacao e gerou uma nova ...
			If VJM->VJM_POID <> oJDQuotePO:aResponse[1]:poNumber
				VJJ->(dbSetOrder(1))
				If VJJ->(dbSeek(xFilial("VJJ") + VJM->VJM_CODVJJ))
					lDeletar := (VJJ->VJJ_POID <> VJM->VJM_POID)
				EndIf
			EndIf
			//
			If lDeletar
				VA1120073_DeletarPO(lAtuCotacao)
			EndIf
		EndIf

		VA1120013_ImportarPO(oJDQuotePO, cCodVJJ, lAtuCotacao)

	End Transaction

Return

/*/{Protheus.doc} VA1120093_ValidaRetornoWS
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oJDQuotePO, object, description
@param lMsg, logical, description
@type function
/*/
Function VA1120093_ValidaRetornoWS(oJDQuotePO, lMsg)
	If Len(oJDQuotePO:aResponse) == 0 .or. oJDQuotePO:aResponse[1]:poNumber== 0
		If lMsg
			MsgInfo(STR0018 + CRLF + CRLF + ; // "Não houve resposta com detalhes do PO selecionado."
				STR0019 + ": " + cValToChar(VJM->VJM_POID) ) // Pedido
		EndIf
		Return .f.
	EndIf

	If ! Empty(oJDQuotePO:aResponse[1]:aRevisions[1]:oErrorMessage:errorMessage)
		If lMsg
			MsgInfo(STR0020 + CRLF + CRLF + ; // "Não é possível importar/atualizar o PO selecinoado."
				STR0019 + ": " + cValToChar(VJM->VJM_POID) + CRLF + ;
				STR0021 + ": " + cValToChar(oJDQuotePO:aResponse[1]:oErrorMessage:errorId)  + CRLF + ; // "Código do Erro
				STR0022 + ": " + oJDQuotePO:aResponse[1]:oErrorMessage:errorMessage ) // "Mensagem do Erro
		EndIf
		Return .f.
	EndIf

Return .t.

/*/{Protheus.doc} VA1120073_DeletarPO
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param lAtuCotacao, logical, description
@type function
/*/
Function VA1120073_DeletarPO(lAtuCotacao)

	Local oModel112
	Local oModel110
	Local lRet

	Default lAtuCotacao := .f.

	oModel112 := FWLoadModel( 'VEIA112' )
	oModel112:SetOperation( MODEL_OPERATION_UPDATE )
	lRet := oModel112:Activate()
	If ! lRet
		Alert("Erro")
	EndIf

	SetModelVal( oModel112:GetModel("MODEL_VJM") , 'VJM_DELETE' , "1" )

	If lRet
		If ( lRet := oModel112:VldData() )
			lRet := oModel112:CommitData()
		EndIf
	EndIf

	If !lRet
		VA1120103_MostraErro(oModel112)
	EndIf

	// Desativamos o Model
	oModel112:DeActivate()

	If lAtuCotacao
		VA1120113_AtualizarCotacao(VJJ->VJJ_CODIGO, 0)
	EndIf

Return lRet

/*/{Protheus.doc} VA1120013_ImportarPO
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oJDQuotePO, object, description
@param cCodVJJ, characters, description
@param lAtuCotacao, logical, description
@type function
/*/
Function VA1120013_ImportarPO(oJDQuotePO, cCodVJJ, lAtuCotacao)
	Local oModel112 := FWLoadModel( 'VEIA112' )

	Local cModelVJM := "MODEL_VJM"
	Local cModelVJK := "MODEL_VJK"
	Local cModelVJL := "MODEL_VJL"
	Local oModelVJM
	Local oModelVJK
	Local oModelVJL

	Local nTamVJLDesc := TamSX3("VJL_DESC")[1]

	Local oAuxResponse
	Local oPOEquipOpt

	Local nPosEquip
	Local nPosOptions

	Local nRecVJM
	Local cItemPed := ""

	Local nEquipAtu := 0
	Local nEquipOptAtu := 0
	Local lAlterar := .f.
	Local aEquipOptAtu := {}

	lAlterar := VA1120023_JaImportada(oJDQuotePO:aResponse[1]:poNumber, @nRecVJM)
	If lAlterar
		dbSelectArea("VJM")
		dbGoTo(nRecVJM)
		oModel112:SetOperation( MODEL_OPERATION_UPDATE )
	Else
		oModel112:SetOperation( MODEL_OPERATION_INSERT )
	EndIf
	lRet := oModel112:Activate()
	If ! lRet
		Alert("Erro")
	EndIf

	oAuxResponse := oJDQuotePO:aResponse[1]

	oModelVJM := oModel112:GetModel( cModelVJM )
	If lAlterar == .f.
		SetModelVal( oModelVJM, 'VJM_CODVJJ', cCodVJJ )
	EndIf
	SetModelVal( oModelVJM , 'VJM_POID'   , oAuxResponse:poNumber )
	SetModelVal( oModelVJM , 'VJM_REVISI' , 1 ) // Por enquanto é 1 pois o WS nao retorna as revisoes do Pedido...

	oAuxResponse := oJDQuotePO:aResponse[1]:aRevisions[1]
	SetModelVal( oModelVJM , 'VJM_STATUS' , oAuxResponse:status )
	SetModelVal( oModelVJM , 'VJM_ORDDAT' , oAuxResponse:orderDate )
	SetModelVal( oModelVJM , 'VJM_SIGDAT' , oAuxResponse:signedOnDate )
	SetModelVal( oModelVJM , 'VJM_NOTES'  , oAuxResponse:internalNotes )
	SetModelVal( oModelVJM , 'VJM_DELETE' , "0" )


	//SetModelVal( oModelVJM , 'VJM_PDF'    , oAuxResponse:pdf )

	oModelVJK := oModel112:GetModel( cModelVJK)
	For nPosEquip := 1 to Len(oAuxResponse:aEquipment)

		oEquipment := oAuxResponse:aEquipment[nPosEquip]
		cItemPed := StrZero(nPosEquip,2)

		nEquipAtu++

		If oModelVJK:SeekLine({{ "VJK_ITEM" , cItemPed }},.f.,.t.)
		Else
			If oModelVJK:Length() == 1 .and. Empty(oModelVJK:GetValue("VJK_MAKENA"))
			Else
				oModelVJK:AddLine()
			EndIf
		EndIf
		SetModelVal( oModelVJK , 'VJK_ITEM'   , cItemPed )
		SetModelVal( oModelVJK , 'VJK_MAKENA' , oEquipment:makeName )				//
		SetModelVal( oModelVJK , 'VJK_MODNAM' , oEquipment:modelName ) 	 		//
 		SetModelVal( oModelVJK , 'VJK_STATUS' , oEquipment:status ) 				//
		SetModelVal( oModelVJK , 'VJK_HOURMR' , oEquipment:hourMeterReading ) 	// Horímetro - C
		SetModelVal( oModelVJK , 'VJK_SERIAL' , oEquipment:serialNumber ) 		// Núm. Serial - C
		SetModelVal( oModelVJK , 'VJK_PRICE'  , oEquipment:finalSellingPrice ) 	// Preço - N

		aEquipOptAtu := {}

		oModelVJL := oModel112:GetModel( cModelVJL )
		cAuxBaseCD := ""
		For nPosOptions := 1 to Len(oEquipment:aStandardOptions)

			nEquipOptAtu++

			oPOEquipOpt := oEquipment:aStandardOptions[nPosOptions]
			If oModelVJL:Length() == 1 .and. Empty(oModelVJL:GetValue("VJL_CODE"))
			ElseIf nPosOptions <= oModelVJL:Length()
				oModelVJL:GoLine(nPosOptions)
			Else
				oModelVJL:AddLine()
			EndIf

			SetModelVal( oModelVJL , 'VJL_CODE'  , oPOEquipOpt:code                            )
			SetModelVal( oModelVJL , 'VJL_DESC'  , Right(oPOEquipOpt:description, nTamVJLDesc) )
			SetModelVal( oModelVJL , 'VJL_PRICE' , oPOEquipOpt:extendedDiscountPrice           )

			If nPosOptions == 1 .and. oEquipment:makeName == "JOHN DEERE" .and. Len(oEquipment:aStandardOptions) > 1 .and. Len(AllTrim(oPOEquipOpt:code)) > 4
				cAuxBaseCD := oPOEquipOpt:code
				SetModelVal( oModelVJK , 'VJK_BASECD' , oPOEquipOpt:code ) //
				VA1120143_VV2_BaseCode(cAuxBaseCD, oModelVJK)
			EndIf

		Next nPosOptions

		If lAlterar
			For nPosOptions := (Len(oEquipment:aStandardOptions) + 1) to oModelVJL:Length()
				oModelVJL:GoLine(nPosOptions)
				oModelVJL:DeleteLine()
			Next nPosOptions
		EndIf

	Next nPosEquip

	If lAlterar
		// Ajuste de base
		// Se encontrar algum registro sem codigo de item do pedido é a primeira execucao da rotina apos a criação
		// do campo de item do pedido
		If oModelVJK:SeekLine({{ "VJK_ITEM" , "  " }},.f.,.t.)
			For nPosEquip := 1 to oModelVJK:Length()
				If Empty(oModelVJK:GetValue("VJK_ITEM", nPosEquip))
					oModelVJK:GoLine(nPosEquip)
					oModelVJK:DeleteLine()
				EndIf
			Next nPosEquip
		Else
			If oModelVJK:Length() > nEquipAtu
				nEquipAtu++
				For nPosEquip := nEquipAtu to oModelVJK:Length()
					oModelVJK:GoLine(nPosEquip)
					oModelVJK:DeleteLine()
				Next nPosEquip
			EndIf
		EndIf
	EndIf

	If lRet
		If ( lRet := oModel112:VldData() )
			lRet := oModel112:CommitData()
		EndIf
	EndIf

	If !lRet
		VA1120103_MostraErro(oModel112)
	EndIf

	If lAtuCotacao
		VA1120113_AtualizarCotacao(cCodVJJ, oJDQuotePO:aResponse[1]:poNumber)
	EndIf

	// Desativamos o Model
	oModel112:DeActivate()

Return lRet

/*/{Protheus.doc} VA1120023_JaImportada
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param nPOId, numeric, description
@param nRecVJM, numeric, description
@type function
/*/
Function VA1120023_JaImportada(nPOId, nRecVJM)

	Local lRet := .t.

	BeginSql Alias "TPESQPO"

		COLUMN VJMREC AS NUMERIC(10,2)

		SELECT VJM.R_E_C_N_O_ VJMREC
		  FROM %Table:VJM% VJM
		 WHERE VJM.VJM_POID = %exp:nPOId%
		   AND %NotDel%

	EndSql

	If TPESQPO->(Eof()) .or. TPESQPO->VJMREC == 0
		lRet := .f.
		nRecVJM := 0
	Else
		nRecVJM := TPESQPO->VJMREC
	EndIf

	TPESQPO->(dbCloseArea())

Return lRet


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
		//Conout("VEIA112 - Erro ao gravar valor no campo " + cCampo + " - [" + cValToChar(uValor) + "]" )
		Return .f.
	EndIf
Return .t.

/*/{Protheus.doc} VA1120103_MostraErro
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel112, object, description
@type function
/*/
Static Function VA1120103_MostraErro(oModel112)
	// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
	aErro   := oModel112:GetErrorMessage()

	// A estrutura do vetor com erro é:
	//  [1] Id do formulário de origem
	//  [2] Id do campo de origem
	//  [3] Id do formulário de erro
	//  [4] Id do campo de erro
	//  [5] Id do erro
	//  [6] mensagem do erro
	//  [7] mensagem da solução
	//  [8] Valor atribuido
	//  [9] Valor anterior

	AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
	AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
	AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
	AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
	AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
	AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
	AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
	AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
	AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )

	//If nItErro > 0
	//	AutoGrLog( "Erro no Item:              " + ' [' + AllTrim( AllToChar( nItErro  ) ) + ']' )
	//EndIf

	MostraErro()
Return

/*/{Protheus.doc} VA1120113_AtualizarCotacao
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param cCodVJJ, characters, description
@param nPOID, numeric, description
@type function
/*/
Static Function VA1120113_AtualizarCotacao(cCodVJJ, nPOID)

	VA1100043_ImportarQuote( {{ cCodVJJ }}, .t. )

Return lRet

/*/{Protheus.doc} VA1120123_PedidoVendaValido
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function VA1120123_PedidoVendaValido()
Return (VJM->VJM_DELETE <> "1")


/*/{Protheus.doc} VA1120133_PosicionaVJM
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param cCodVJJ, characters, description
@type function
/*/
Static Function VA1120133_PosicionaVJM(cCodVJJ)
	Local lRet := .t.

	BeginSql Alias "TPOSPO"

		COLUMN VJMREC AS NUMERIC(10,2)

		SELECT VJM.R_E_C_N_O_ VJMREC
		  FROM %Table:VJM% VJM
		 WHERE VJM.VJM_FILIAL = %xfilial:VJM%
		   AND VJM.VJM_CODVJJ = %exp:cCodVJJ%
			AND VJM.VJM_DELETE = '0'
		   AND %NotDel%
		 ORDER BY R_E_C_N_O_ DESC

	EndSql

	If TPOSPO->(Eof()) .or. TPOSPO->VJMREC == 0
		lRet := .f.
	Else
		VJM->(dbGoTo(TPOSPO->VJMREC))
	EndIf

	TPOSPO->(dbCloseArea())

Return lRet

/*/{Protheus.doc} VA1120143_VV2_BaseCode
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param cAuxBaseCD, characters, description
@param oModelVJK, object, description
@type function
/*/
Static Function VA1120143_VV2_BaseCode(cAuxBaseCD, oModelVJK)
	If Empty(cAuxBaseCD)
		Return
	EndIf

	BeginSql Alias "TVJU"

		SELECT VJU.VJU_CODMAR, VJU.VJU_MODVEI, VJU.VJU_SEGMOD, VJU.VJU_CONIMP
		  FROM %Table:VJU% VJU
		 WHERE VJU.VJU_FILIAL = %xfilial:VJU%
		   AND VJU.VJU_BASECD = %exp:cAuxBaseCD%
			AND VJU.VJU_MODVEI <> ' '
		   AND %NotDel%

	EndSql

	If ! TVJU->(Eof())
		SetModelVal( oModelVJK , 'VJK_CODMAR' , TVJU->VJU_CODMAR )
		SetModelVal( oModelVJK , 'VJK_MODVEI' , TVJU->VJU_MODVEI )
		SetModelVal( oModelVJK , 'VJK_SEGMOD' , TVJU->VJU_SEGMOD )
		SetModelVal( oModelVJK , 'VJK_INTEGR' , TVJU->VJU_CONIMP )
	EndIf

	TVJU->(dbCloseArea())

Return

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
Function VA1120153_LimparToken(cAlias, nReg, nOpc)

	Local oOkta := OFJDOkta():New()

	oOkta := OFJDOkta():New()
	if oOkta:oConfig:poDataJDQuote()
		oOkta:SetPODataJDQuote()
		oOkta:cleanProfile()
		MsgInfo(STR0025) // "Token removido."
	Else
		MsgInfo(STR0026) // "Sistema não está configurado para utilizar a autenticação via Okta."
	endif
Return
