#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#INCLUDE "VEIA111.CH"

Static cFilCpoSA1 := "A1_COD|A1_LOJA|A1_NOME|A1_NREDUZ|A1_PESSOA|A1_CGC|A1_END|A1_BAIRRO|A1_TIPO|A1_EST|A1_COD_MUN|A1_MUN|A1_CEP|A1_IBGE|A1_NATUREZ|A1_DDD|A1_TEL|A1_PAIS|A1_INSCR"
Static oAuxEvDef := NIL

/*/{Protheus.doc} VEIA111
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VEIA111()
	Local oBrowse

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
	Local oStruVJP := FWFormStruct( 1, 'VJP' )

	Local oSModelSA1
	Local oSViewSA1
	Local cFieldsSA1 := ""


	oStruVJP:AddField(;
		"Funcao",; // cTitulo
		"Funcao",; // cTooltip
		"FUNCAO",; // cIdField
		"C",; // cTipo
		30,; // nTamanho
		0,; // nDecimal
		{ || .T. },; // bValid
		FWBuildFeature( STRUCT_FEATURE_WHEN, ".t." ),; // bWhen
		NIL,; // aValues
		.F.,; // lObrigat
		NIL,; // bInit
		.f.,; // lKey
		.f. ,; // lNoUpd
		.t. ,; // lVirtual
		NIL ) // cValid



	oModel := MPFormModel():New('VEIA111' )
	oModel:AddFields('MODEL_VJP', /*cOwner*/, oStruVJP , /* <bPre > */ , /* <bPost > */ , /* <bLoad> */ )

	oModel:SetDescription( STR0002 + ' - CKC') // 'Clientes - CKC'
	oModel:GetModel( 'MODEL_VJP' ):SetDescription( STR0003 + ' - Base CKC') // 'Dados do Cliente - Base CKC'

	oAuxEvDef := VEIA111EVDEF():New()
	oAuxEvDef:cFilCpoSA1 := cFilCpoSA1
	oModel:InstallEvent("PADRAO",, oAuxEvDef )

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
	Local oModel := FWLoadModel( 'VEIA111' )
	Local oStruVJP := FWFormStruct( 2, 'VJP' )

	oStruVJP:AddGroup('VJP1',STR0003 + ' - John Deere','1',2)
	oStruVJP:AddGroup('VJP2',STR0003 + ' - Protheus','2',2)

	oStruVJP:SetProperty("*", MVC_VIEW_GROUP_NUMBER, "VJP1")
	oStruVJP:SetProperty("VJP_A1FIL"  , MVC_VIEW_GROUP_NUMBER, "VJP2")
	oStruVJP:SetProperty("VJP_A1COD"  , MVC_VIEW_GROUP_NUMBER, "VJP2")
	oStruVJP:SetProperty("VJP_A1LOJA" , MVC_VIEW_GROUP_NUMBER, "VJP2")

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField('VIEW_VJP', oStruVJP, 'MODEL_VJP' )

	oView:CreateHorizontalBox( 'TELA_VJP' , 100 )

	oView:SetOwnerView('VIEW_VJP','TELA_VJP')

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
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.VEIA111' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VA1110013_RelMBrowse' OPERATION 4 ACCESS 0 // 'Relacionar Cliente'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VA1110053_CriarSA1' OPERATION 4 ACCESS 0 // 'Criar Cliente Protheus'
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.VEIA111' OPERATION 8 ACCESS 0 // 'Imprimir'
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
	oBrowse:SetAlias('VJP')
	oBrowse:SetDescription( STR0001 + ' - Base John Deere - CKC') // 'Cadastro de Clientes - Base John Deere - CKC'

	oBrowse:AddLegend( 'VJP->VJP_ID == 0' , 'BR_PINK'     , STR0008 ) // "Não possui cadastro na base da John Deere."
	oBrowse:AddLegend( 'VJP->VJP_ID <> 0' , 'BR_AMARELO'  , STR0009 ) // "Cliente possui cadastro válido na base da John Deere."

	oBrowse:AddStatusColumns( { || IIF( Empty(VJP->VJP_A1COD) , 'BR_VERMELHO','BR_VERDE' ) }, { || VA1110073_LegendaSA1() } )

Return oBrowse

/*/{Protheus.doc} VA1110073_LegendaSA1
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function VA1110073_LegendaSA1()
	Local oLegenda  :=  FWLegend():New()

	oLegenda:Add( '', "BR_VERMELHO" , STR0010 ) // 'Não possui cadastro na base do Protheus.' 
	oLegenda:Add( '', "BR_VERDE"    , STR0011 ) // 'Cliente possui cadastro válido na base do Protheus.' 
	
	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()

Return Nil

/*/{Protheus.doc} VA1110013_RelMBrowse
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
Function VA1110013_RelMBrowse(cAlias, nReg, nOpc)

	Local oView
	Local oModel := FWLoadModel( 'VEIA111' )
	Local oStruVJP := FWFormStruct( 2, 'VJP' , { |x| ! AllTrim(x) $ "VJP_A1FIL/VJP_A1COD/VJP_A1LOJA" })

	Private oBrwPainel

	If ! Empty(VJP->VJP_A1COD)
		Help(	NIL, NIL, "VA110ERR01",,STR0012,1,0,NIL, NIL, NIL, NIL, NIL, { "" } ) // "Registro já possui um cliente relacionado."
		Return .f.
	EndIf

	If Empty(VJP->VJP_ID)
		Help(	NIL, NIL, "VA110ERR02",,STR0013,1,0,NIL, NIL, NIL, NIL, NIL, { "" } ) // "Cliente não possui ID na base da John Deere."
		Return .f.
	EndIf

	oStruVJP:SetProperty("*", MVC_VIEW_CANCHANGE , .F. )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField('VIEW_VJP', oStruVJP, 'MODEL_VJP' )
	oView:AddOtherObject('VIEW_SA1', { |oPanel| VA1110033_BrowseSA1 (oPanel) })

	oView:CreateHorizontalBox( 'TELA_VJP' , 40 )
	oView:CreateHorizontalBox( 'TELA_SA1' , 60 )

	oView:SetOwnerView('VIEW_VJP', 'TELA_VJP')
	oView:SetOwnerView('VIEW_SA1', 'TELA_SA1')
	
	oView:EnableTitleView('VIEW_SA1', STR0014 + ' - Protheus') // Relação de Clientes

	oView:SetCloseOnOk({||.T.})

	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)

	oModel:SetActivate( { |oModel| oModel:SetValue("MODEL_VJP","FUNCAO","RELSA1") } )

	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0015 + " - Protheus") // Lista de Clientes
	oExecView:setModel(oModel)
	oExecView:setView(oView)
	oExecView:setOK( { |oModel| VA1110023_ConfirmaRelacionamento(oModel) })
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)

Return .t.

/*/{Protheus.doc} VA1110023_ConfirmaRelacionamento
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Function VA1110023_ConfirmaRelacionamento(oModel)

	Local cAuxMsg
	Local oModelVJP := oModel:GetModel("MODEL_VJP")
	Local lRetorno := .f.
	Local cNomeCliente := ""

	SA1->(dbSetOrder(1))
	If SA1->(MsSeek(xFilial("SA1") + oModelVJP:GetValue("VJP_A1COD") + oModelVJP:GetValue("VJP_A1LOJA") ))
		cNomeCliente := AllTrim(SA1->A1_NOME)
	EndIf

	cAuxMsg := STR0016 + CRLF + CRLF + ; // "Confirma relacionamento do cliente CKC com o cliente do Protheus?"
		STR0017 + " - CKC: " + cValToChar(oModelVJP:GetValue("VJP_ID")) + CRLF + CRLF + ; // Cliente
		STR0017 + " - Protheus: " + oModelVJP:GetValue("VJP_A1COD") + "-" + oModelVJP:GetValue("VJP_A1LOJA") + " - " + cNomeCliente // Cliente
	lRetorno := MsgYesNo(cAuxMsg)

Return lRetorno

/*/{Protheus.doc} VA1110033_BrowseSA1
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oPanel, object, description
@type function
/*/
Function VA1110033_BrowseSA1(oPanel)

	Local cFilterDefault

	oBrwPainel := FWMBrowse():New() 
	oBrwPainel:SetOwner(oPanel)  
	oBrwPainel:SetAlias("SA1")
	oBrwPainel:DisableLocate()
	oBrwPainel:DisableDetails()
	oBrwPainel:SetAmbiente(.F.)
	oBrwPainel:SetWalkthru(.F.)
	oBrwPainel:SetMenuDef("")
	oBrwPainel:SetInsert(.f.)
	oBrwPainel:SetUseFilter()

	cFilterDefault := "@ NOT EXISTS (SELECT VJP.R_E_C_N_O_ FROM " + RetSQLName("VJP") + " VJP WHERE VJP.VJP_A1FIL = A1_FILIAL AND VJP.VJP_A1COD = A1_COD AND VJP.VJP_A1LOJA = A1_LOJA AND VJP.D_E_L_E_T_ = ' ') "
	If ! Empty(VJP->VJP_TAXID)
		cFilterDefault += " AND A1_CGC LIKE '" + AllTrim(VJP->VJP_TAXID) + "%' "
	EndIf
	If ! Empty(VJP->VJP_DBSCN)
		cAuxCodigo := PadR( AllTrim(VJP->VJP_DBSCN) , TamSX3("A1_COD")[1] + TamSX3("A1_LOJA")[1], " ")
		cCodigo := Left(cAuxCodigo, TamSX3("A1_COD")[1] )
		cLoja   := Right(cAuxCodigo, TamSX3("A1_LOJA")[1] )
		If ! Empty(cCodigo)
			cFilterDefault += " AND A1_COD = '" + cCodigo + "'"
			If ! Empty(cLoja)
				cFilterDefault += " AND A1_LOJA = '" + cLoja + "'"
			EndIf
		EndIf
	EndIf

	oBrwPainel:AddFilter(STR0019, cFilterDefault,,.T.) // 'Filtro Padrão'
	//oBrwPainel:SetFilterDefault(cFilterDefault) -- Alex - Torna o Filtro Obrigatório, enquanto o AddFilter permite remover e selecionar a preferência do cliente.
	oBrwPainel:DisableReport()

	oBrwPainel:SetChange({ || VA1110043_AtualizaCampoVJP() })

	oBrwPainel:Activate()

Return

/*/{Protheus.doc} VA1110043_AtualizaCampoVJP
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VA1110043_AtualizaCampoVJP()

	Local oModel := FWModelActive()
	Local oModelVJP := oModel:GetModel("MODEL_VJP")

	oModelVJP:SetValue("VJP_A1FIL"  , SA1->A1_FILIAL )
	oModelVJP:SetValue("VJP_A1COD"  , SA1->A1_COD )
	oModelVJP:SetValue("VJP_A1LOJA" , SA1->A1_LOJA )

Return

/*/{Protheus.doc} VA1110053_CriarSA1
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
Function VA1110053_CriarSA1(cAlias, nReg, nOpc)

	Local oModel
	Local oView := ViewDef()

	Local oSModelSA1
	Local oSViewSA1
	Local cFieldsSA1 := ""

	Local oStruVJP
	Local nPosField

	If ! Empty(VJP->VJP_A1COD)
		Help(	NIL, NIL, "VA110ERR03",,STR0012 + CRLF + CRLF + RetTitle("A1_COD") + ": " + VJP->VJP_A1COD + "-" + VJP->VJP_A1LOJA,1,0,NIL, NIL, NIL, NIL, NIL, { "" } ) // "Registro já possui um cliente relacionado." 
		Return .f.
	EndIf

	oModel := oView:GetModel()

	VA1110093_FieldsSA1(@cFieldsSA1, @oSModelSA1, @oSViewSA1)
	oAuxEvDef:cFilCpoSA1 := cFieldsSA1

	oSModelSA1:SetProperty('*', MODEL_FIELD_VIRTUAL, .T. )
	oSModelSA1:SetProperty('A1_COD', MODEL_FIELD_KEY, .F. )
	oSModelSA1:SetProperty('A1_LOJA', MODEL_FIELD_KEY, .F. )

	oSModelSA1:SetProperty('A1_COD' , MODEL_FIELD_WHEN, FWBuildFeature( STRUCT_FEATURE_WHEN, ".t." ) )
	oSModelSA1:SetProperty('A1_LOJA', MODEL_FIELD_WHEN, FWBuildFeature( STRUCT_FEATURE_WHEN, ".t." ) )

	oSViewSA1:SetNoFolder()

	oModel:AddFields('MODEL_SA1', 'MODEL_VJP', oSModelSA1 , /* <bPre > */ , /* <bPost > */ , /* <bLoad> */ { |oFieldModel, lCopy| VA1110063_loadCabSA1(oFieldModel, lCopy) } )
	oModel:GetModel( 'MODEL_SA1' ):SetDescription( STR0003 + ' - SA1' ) // Dados do Cliente
	oModel:GetModel('MODEL_SA1'):SetOnlyQuery( .T. )

	oStruVJP := oView:GetSubView("VIEW_VJP"):GetStruct()
	
	oStruVJP:SetProperty("*",MVC_VIEW_CANCHANGE ,.F.)
	oStruVJP:RemoveField("VJP_A1FIL"  )
	oStruVJP:RemoveField("VJP_A1COD"  )
	oStruVJP:RemoveField("VJP_A1LOJA" )

	oView:SetModel(oModel)
	oView:AddField('VIEW_SA1' , oSViewSA1,'MODEL_SA1')
	oView:CreateVerticallBox( 'TELANOVA' , 100, 'TELA_VJP' )
	oView:CreateHorizontalBox( 'TELA_VJP_NOVA', 40, 'TELANOVA')
	oView:CreateHorizontalBox( 'TELA_SA1', 60 , 'TELANOVA')
	oView:SetOwnerView('VIEW_VJP','TELA_VJP_NOVA')
	oView:SetOwnerView('VIEW_SA1','TELA_SA1')
	oView:EnableTitleView('VIEW_SA1' , STR0003 + '(SA1)' )

	oModel:SetActivate( { |oModel| oModel:SetValue("MODEL_VJP","FUNCAO","CRIARSA1") } )

	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0018) // "Incluir cliente a partir do registro do Cliente CKC"
	oExecView:setModel(oModel)
	oExecView:setView(oView)
	oExecView:setCancel( { || .T. } )
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.t.)


Return .t.

/*/{Protheus.doc} VA1110063_loadCabSA1
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oFieldModel, object, description
@param lCopy, logical, description
@type function
/*/
Static Function VA1110063_loadCabSA1(oFieldModel, lCopy)
	Local aLoad := {}
	Local aAuxFields := oFieldModel:GetStruct():GetFields()
	Local nPosField

	RegToMemory("SA1",.t.)

	M->A1_NOME := Left( AllTrim( IIf( ! Empty(VJP->VJP_CBNAME) , VJP->VJP_CBNAME , AllTrim(VJP->VJP_CFNAME) + " " + AllTrim(VJP->VJP_CLNAME) ) ) , Len(M->A1_NOME) )
	M->A1_NREDUZ := Left(M->A1_NOME,Len(M->A1_NREDUZ))
	If ! Empty(VJP->VJP_TAXID)
		M->A1_PESSOA >= IIf( Len(AllTrim(VJP->VJP_TAXID)) <= 11 , "F" , "J" )
		M->A1_CGC := VJP->VJP_TAXID
	EndIf

	M->A1_END := Left( AllTrim( AllTrim(VJP->VJP_CADDR1) + " " + AllTrim(VJP->VJP_CADDR2) ) , Len(M->A1_END) )
	//M->A1_BAIRRO
	M->A1_EST := VJP->VJP_CSTATE
	M->A1_CEP := AllTrim(VJP->VJP_CZIPC)
	M->A1_COD_MUN := Posicione("CC2", 4, xFilial("CC2") + VJP->VJP_CSTATE + AllTrim(VJP->VJP_CCITY) , "CC2_CODMUN")
	M->A1_MUN := AllTrim(VJP->VJP_CCITY)
	M->A1_IBGE := Posicione("VAM", 3, xFilial("VAM") + VJP->VJP_CSTATE + AllTrim(VJP->VJP_CCITY) , "VAM_IBGE")
	//M->A1_DDD
	M->A1_TEL := AllTrim(VJP->VJP_PHONE)
	//M->A1_INSCR
	M->A1_PAIS := Posicione("SYA", 2, xFilial("SYA") + AllTrim(Upper(VJP->VJP_CCOUNT)) , "YA_CODGI")

	CC2->(dbSetOrder(1))
	VAM->(dbSetOrder(1))
	SYA->(dbSetOrder(1))

	For nPosField := 1 to Len(aAuxFields)
		AADD( aLoad, &("M->" + aAuxFields[nPosField, 3] ) )
	Next nPosField
	
Return aLoad


/*/{Protheus.doc} VA1110083_CriaSA1Automaticamente
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VA1110083_CriaSA1Automaticamente()

	Local oModel := FWLoadModel("VEIA111")

	Local oSModelSA1
	Local oSViewSA1
	Local cFieldsSA1 := ""

	Local oStruVJP
	Local nPosField

	Local lRetorno
	Local aErro

	If ! Empty(VJP->VJP_A1COD) .or. VJP->VJP_ID == 0 .or. Empty(VJP->VJP_TAXID)
		Return .T.
	EndIf	

	INCLUI := .T.

	VA1110093_FieldsSA1(@cFieldsSA1, @oSModelSA1, @oSViewSA1)
	oAuxEvDef:cFilCpoSA1 := cFieldsSA1

	//oSModelSA1:SetProperty('*', MODEL_FIELD_VIRTUAL, .T. )

	oModel:AddFields('MODEL_SA1', 'MODEL_VJP', oSModelSA1 , /* <bPre > */ , /* <bPost > */ , /* <bLoad> */ { |oFieldModel, lCopy| VA1110063_loadCabSA1(oFieldModel, lCopy) } )
	oModel:GetModel( 'MODEL_SA1' ):SetDescription( 'Dados do Cliente - SA1' )
	oModel:GetModel('MODEL_SA1'):SetOnlyQuery( .T. )

	oModel:setOperation(MODEL_OPERATION_UPDATE)
	If ! oModel:Activate()
		Return .f.
	EndIf

	If Empty(M->A1_COD)
		// 
		VA1110103_CodigoCliente(@oModel)
	EndIf
	If Len(AllTrim(oModel:GetValue("MODEL_SA1","A1_CGC"))) <= 11
		oModel:SetValue("MODEL_SA1","A1_TIPO","F")
	Else
		oModel:SetValue("MODEL_SA1","A1_TIPO","J")
	EndIf

	oModel:SetValue("MODEL_VJP","FUNCAO","CRIARSA1")
	lRetorno := oModel:VldData()
	If lRetorno
		oModel:CommitData()
	Else
		aErro := oModel:GetErrorMessage(.t.)

		Conout( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
		Conout( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
		Conout( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
		Conout( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
		Conout( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
		Conout( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
		Conout( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
		Conout( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
		Conout( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )

	EndIf
	oModel:DeActivate()

//	oModel:SetActivate( { |oModel| oModel:SetValue("MODEL_VJP","FUNCAO","CRIARSA1") } )

Return lRetorno

/*/{Protheus.doc} VA1110093_FieldsSA1
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param cFieldsSA1, characters, description
@param oSModelSA1, object, description
@param oSViewSA1, object, description
@type function
/*/
Static Function VA1110093_FieldsSA1(cFieldsSA1, oSModelSA1, oSViewSA1)
	Local aAuxStruSA1
	Local cFieldsSA1 := ""
	Local nPosField

	aAuxStruSA1 := FWFormStruct( 3 , "SA1" )
	For nPosField := 1 to Len(aAuxStruSA1[FORM_STRUCT_TABLE_MODEL])
		If aAuxStruSA1[ FORM_STRUCT_TABLE_MODEL ][ nPosField ][ MVC_MODEL_OBRIGAT ] .or. AllTrim(aAuxStruSA1[ FORM_STRUCT_TABLE_MODEL ][ nPosField ][ MVC_MODEL_IDFIELD ]) $ cFilCpoSA1
			cFieldsSA1 += aAuxStruSA1[ FORM_STRUCT_TABLE_MODEL ][ nPosField ][ MVC_MODEL_IDFIELD ] + "|"
		EndIf
	Next nPosField

	oSModelSA1 := FWFormStruct(1, "SA1", { |x| ALLTRIM(x) $ cFieldsSA1 } )
	oSViewSA1  := FWFormStruct(2, "SA1", { |x| ALLTRIM(x) $ cFieldsSA1 } )

Return

/*/{Protheus.doc} VA1110103_CodigoCliente
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, description
@type function
/*/
Static Function VA1110103_CodigoCliente(oModel)
	Local cAlCliente := "TPRXSA1"

	BeginSQL Alias cAlCliente
		SELECT A1_COD, A1_LOJA 
		FROM 
			%table:SA1% SA1
		WHERE	SA1.A1_FILIAL = %xFilial:SA1% 
		AND SA1.A1_CGC = %exp:oModel:GetValue('MODEL_SA1','A1_CGC')%
		AND SA1.%notDel% 
	EndSql
	If ! (cAlCliente)->(Eof())
		oModel:LoadValue("MODEL_SA1","A1_COD",(cAlCliente)->A1_COD)
		oModel:LoadValue("MODEL_SA1","A1_LOJA",Soma1((cAlCliente)->A1_LOJA))
	Else

		cQuery := ;
			"SELECT MAX(A1_COD) A1_COD" +;
			 " FROM " + RetSQLName("SA1") + " SA1" +;
			" WHERE SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
		oModel:LoadValue("MODEL_SA1","A1_COD",Soma1(FM_SQL(cQuery)))
		oModel:LoadValue("MODEL_SA1","A1_LOJA",StrZero( 1, TamSX3("A1_LOJA")[1]))
	End
	(cAlCliente)->(dbCloseArea())

Return