#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'LOCACAO.CH'
#INCLUDE 'TECA825C.CH'

Static cDefTextAtu := ''
Static cDefTipoAtu := ''

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Definição do modelo de dados para a atualização dos motivos de todos os movimentos
associados a reserva 
@sample 	ModelDef()
@since		11/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel    := Nil
Local oStr1     := FWFormStruct(1,'TFI')
Local oStr2     := FWFormStruct(1,'TEW')
Local oStr3     := FWFormStruct(1,'TFI')

oStr1:SetProperty('TFI_DESCRI', MODEL_FIELD_INIT, {|| Posicione('SB1',1,xFilial('SB1')+TFI->TFI_PRODUT,'B1_DESC')})

// Adiciona o Campo tipo de Frete
oStr1:AddField( 'Tipo Frete', ; // cTitle // 'Mark'
				'Tipo de Frete', ; // cToolTip // 'Mark'
				'TFI_XTPFRETE', ; // cIdField
				'C', ; // cTipo
				3, ; // nTamanho
				0, ; // nDecimal
				{|| .T.}, ; // bValid
				{|| .F.}, ; // bWhen
				Nil, ; // aValues
				Nil, ; // lObrigat
				{|oMdlTFIP,cField|At825CTpFr(oMdlTFIP,cField)}, ; // bInit
				Nil, ; // lKey
				.T., ; // lNoUpd
				.T. ) // lVirtual

oStr2:SetProperty('TEW_ORCSER',MODEL_FIELD_OBRIGAT,.F.)
oStr2:SetProperty('TEW_CODEQU',MODEL_FIELD_OBRIGAT,.F.)

oModel := MPFormModel():New('TECA825C',,,{|oMdlFull|At825CGrv(oMdlFull)})

oModel:addFields('CAB_TFI',,oStr1)
oModel:addGrid('GRD_TEW','CAB_TFI',oStr2,,,,,{|oMdl|SelecTEW(oMdl)})
oModel:addGrid('GRD_TFI','CAB_TFI',oStr3)
oModel:SetRelation('GRD_TFI', { { 'TFI_FILIAL', 'xFilial("TFI")' }, { 'TFI_RESERV', 'TFI_RESERV' } }, TFI->(IndexKey(1)) )

oModel:SetDescription(STR0001) // 'Reserva'
oModel:getModel('CAB_TFI'):SetDescription(STR0002)  // 'Item Locação'
oModel:getModel('GRD_TEW'):SetDescription(STR0003)  // 'Equip. Reservados'

oModel:getModel('GRD_TEW'):SetNoInsertLine(.T.)
oModel:getModel('GRD_TEW'):SetNoDeleteLine(.T.)

oModel:SetActivate({|oMdlFull|At825Cset( oMdlFull )})
oModel:getModel('GRD_TFI'):SetDescription(STR0004)  // 'Outros Itens da Reserva'
oModel:getModel('GRD_TFI'):SetOptional(.T.)

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface para a atualização dos motivos de todos os movimentos
associados a reserva 
@sample 	ViewDef()
@since		11/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel	:= ModelDef()
Local oStr1		:= FWFormStruct(2, 'TFI', {|cCpo| At825CpTFI(AllTrim(cCpo))})
Local oStr2:= FWFormStruct(2, 'TEW', {|cCpo|Alltrim(cCpo)$'TEW_FILIAL+TEW_RESCOD+TEW_PRODUT+TEW_BAATD+TEW_QTDRES+TEW_DTSEPA+TEW_DTRINI+TEW_DTRFIM+TEW_TIPO+TEW_MOTIVO'})

oView := FWFormView():New()
oView:SetModel(oModel)

oStr1:SetProperty( '*', MVC_VIEW_CANCHANGE, .F. )
oStr1:SetProperty( 'TFI_RESERV', MVC_VIEW_ORDEM, '01' )

oStr1:AddField('TFI_XTPFRETE',;				// cIdField
               '08',;					// cOrdem
               'Tipo Frete',;					// cTitulo // 'Mark'
               'Tipo de Frete',;					// cDescric // 'Mark'
               {'Tipo de Frete', 'Tipo de frete (Branco), CIF ou FOB'},;	// aHelp : 'Marque os itens que deseja realizar  ' ### 'a reserva dos equipamentos '    
               '',;					// cType
               '@!',;					// cPicture
               Nil,;						// nPictVar
               Nil,;						// Consulta F3
               .F.,;						// lCanChange
               '01',;					// cFolder
               Nil,;						// cGroup
               Nil,;						// aComboValues
               Nil,;						// nMaxLenCombo
               Nil,;						// cIniBrow
               .T.,;						// lVirtual
               Nil )						// cPictVar

oStr2:SetProperty( '*', MVC_VIEW_CANCHANGE, .F. )
oStr2:SetProperty( 'TEW_RESCOD', MVC_VIEW_ORDEM, '01' )
oStr2:SetProperty( 'TEW_DTRINI', MVC_VIEW_ORDEM, '02' )
oStr2:SetProperty( 'TEW_DTRFIM', MVC_VIEW_ORDEM, '03' )

oView:AddField('CAB', oStr1,'CAB_TFI')
oView:AddGrid('GRD' , oStr2,'GRD_TEW')  

oView:CreateHorizontalBox( 'BOXFORM1', 35)
oView:CreateHorizontalBox( 'BOXFORM2', 65)

oView:SetOwnerView('GRD','BOXFORM2')
oView:SetOwnerView('CAB','BOXFORM1')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} Atr825cGrv
Gravação dos dados no cancelamento da reserva

@since 17/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function At825cGrv( oMdlFull )

Local lRet      := .T.
Local aSave     := GetArea()
Local aSaveTEW  := TEW->( GetArea() )
Local aSaveTFI  := TFI->( GetArea() )
Local oTecProvider	:= Nil
Local nI			:= 0
Local oGrdTEW	:= oMdlFull:GetModel('GRD_TEW')

lRet := FwFormCommit( oMdlFull )
If lRet .And. SuperGetMv('MV_TECATF', .F.,'N') == 'S'
	For nI := 1 to oGrdTEW:Length()
		oGrdTEW:GoLine(nI)
		If oGrdTEW:GetValue('TEW_MOTIVO') == DEF_RES_CANCELADA
			If ValType(oTecProvider) <> 'O'
				oTecProvider := TecProvider():New()
			EndIf			
			oTecProvider:DeleteTWU(oGrdTEW:GetValue('TEW_CODMV'))
		ElseIf oGrdTEW:GetValue('TEW_MOTIVO') == DEF_RES_ENVIADA
			If ValType(oTecProvider) <> 'O'
				oTecProvider := TecProvider():New()
			EndIf			
			oTecProvider:UpdateTWU(oGrdTEW:GetValue('TEW_CODMV'),1)									
		EndIf
	Next nI
EndIf	

If ValType(oTecProvider) == 'O'
	FreeObj(oTecProvider)
EndIf

RestArea(aSaveTFI)
RestArea(aSaveTEW)
RestArea(aSave)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At825Cset
Gravação dos dados no cancelamento da reserva

@since 17/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function At825Cset( oMdlFull )

Local oMdlCab    := Nil
Local oMdlGrd    := Nil
Local nX         := 1
Local aRows      := {}
Local cCodItLoc  := ''
Local lAtuCodigo := .F.

If oMdlFull:GetId() == 'TECA825C' .And. ;  // é o model de cancelamento
	oMdlFull:GetOperation() == MODEL_OPERATION_UPDATE  // operação de atualização
	
	oMdlCab := oMdlFull:GetModel('CAB_TFI')
	oMdlGrd := oMdlFull:GetModel('GRD_TEW')
	
	aRows := FwSaveRows()
	
	//   ainda não remove o código da reserva pois o
	//  relation sobreporia nos equipamentos do grid
	If cDefTipoAtu == DEF_RES_CANCELADA
		oMdlCab:SetValue('TFI_RESERV', ' ' )
		cCodItLoc := oMdlCab:GetValue('TFI_COD')
		lAtuCodigo := .T.
	EndIf
	
	For nX := 1 To oMdlGrd:Length()
	
		oMdlGrd:GoLine(nX)
		
		If lAtuCodigo
			oMdlGrd:SetValue('TEW_CODEQU', cCodItLoc )
		EndIf
		
		oMdlGrd:SetValue('TEW_MOTIVO', cDefTipoAtu )
		oMdlGrd:SetValue('TEW_OBSMNT', cDefTextAtu )
	
	Next nX
	
	FwRestRows( aRows )
	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At825CText
Define o texto padrão para registro no campo observação

@since 17/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function At825CText( cText )

If ValType(cText) <> 'C' .Or. Empty(cText)
	cText := STR0004  // 'Cancelado pelo usuário'
EndIf

cDefTextAtu := SubStr( cText, 1, TamSX3('TEW_OBSMNT')[1] )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At825CText
Define o texto padrão para registro no campo observação

@since 17/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Function At825CTipo( cTipo )

If ValType(cTipo) <> 'C' .Or. Empty(cTipo)
	cTipo := DEF_RES_CANCELADA
EndIf

cDefTipoAtu := cTipo

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SelecTEW
	Carrega os dados do grid

@since 17/02/2014
@version P12.0
/*/
//-------------------------------------------------------------------
Static Function SelecTEW(oMdl)

Local cTmpQry      := GetNextAlias()
Local aRet         := {}

If !Empty(TFI->TFI_RESERV)
	// Carrega os dados de uma reserva ativa
	BeginSql Alias cTmpQry
		
		COLUMN TEW_DTSEPA AS DATE
		COLUMN TEW_DTRINI AS DATE
		COLUMN TEW_DTRFIM AS DATE
		COLUMN TEW_DTAMNT AS DATE
		COLUMN TEW_FECHOS AS DATE
		
		SELECT TEW.*
		FROM %Table:TEW% TEW
		WHERE TEW.TEW_FILIAL = %xFilial:TEW% AND TEW.TEW_RESCOD = %Exp:TFI->TFI_RESERV% 
				AND TEW.TEW_TIPO = '2' // tipo igual a reserva
	
	EndSql
Else
	// Carrega os dados de uma reserva cancelada
	BeginSql Alias cTmpQry

		COLUMN TEW_DTSEPA AS DATE
		COLUMN TEW_DTRINI AS DATE
		COLUMN TEW_DTRFIM AS DATE
		COLUMN TEW_DTAMNT AS DATE
		COLUMN TEW_FECHOS AS DATE
	
		SELECT TEW.*
		FROM %Table:TEW% TEW
		WHERE TEW.TEW_FILIAL = %xFilial:TEW% AND TEW.TEW_CODEQU = %Exp:TFI->TFI_COD% 
				AND TEW.TEW_TIPO = '2'  // tipo igual a reserva
	
	EndSql

EndIf

aRet := FwLoadByAlias( oMdl, cTmpQry )

(cTmpQry)->(DbCloseArea())

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At825CTpFr
Incializador padrão, para campo tipo de frete temporario

@param oMdlTFIP - oBjeto 	- FwFormModel
@param cField   - Caractere - Nome do Campo

@return cRet	- Caractere - Conteudo do campo

@since 08/09/2016
@version P12
/*/
//-------------------------------------------------------------------
Function At825CTpFr(oMdlTFIP,cField)

	Local aArea := GetArea()
	Local aAreaTFL := TFL->(GetArea())
	Local aAreaTFJ := TFJ->(GetArea())
	
	Local cRet:= ''
	
	If oMdlTFIP:GetId() == 'CAB_TFI'
		dbSelectArea('TFL')
		dbSetOrder(1)//TFL_FILIAL + TFL_CODIGO
		
		If TFL->(dbSeek(xFilial('TFL') + oMdlTFIP:GetValue('TFI_CODPAI')))
			
			dbSelectArea('TFJ')
			dbSetOrder(1)//TFJ_FILIAL + TFJ_CODIGO
			
			If TFJ->(dbSeek(xFilial('TFJ') + TFL->TFL_CODPAI))
				If Alltrim(TFJ->TFJ_TPFRET) == '1'
					cRet := 'CIF'
				ElseIf Alltrim(TFJ->TFJ_TPFRET) == '2'
					cRet := 'FOB'
				EndIf
			EndIf	
		EndIf
	EndIf
	
	RestArea(aAreaTFJ)
	RestArea(aAreaTFL)
	RestArea(aArea)

Return cRet
