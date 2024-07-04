#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA902.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA902
Etilômetro
@sample		GTPA902()
@author 		GTP
@since 			19/10/2020
@version 		P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA902()
	
Local oBrowse := Nil
Local aNewFlds   := {'GQO_CODIGO', 'GQO_DATA','GQO_VALOR'}

If !(GTPxVldDic('GQO', aNewFlds, .T., .T.))
    FwAlertHelp(STR0006, STR0007,)	// "Dicionário desatualizado", "Atualize o dicionário para utilizar esta rotina"
Else	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('GQO')
	oBrowse:SetDescription(STR0001)	//'Etilômetro'
	oBrowse:SetMenuDef('GTPA902')
	If !(IsBlind())
		oBrowse:Activate()
	EndIf
EndIf	
Return Nil

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu

@sample		MenuDef()

@return		aRotina - Array de opções do menu

@author		GTP
@since			19/10/2020
@version		P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()
	
Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.GTPA902' OPERATION 2 ACCESS 0	//'Visualizar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.GTPA902' OPERATION 3 ACCESS 0	//'Incluir'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.GTPA902' OPERATION 4 ACCESS 0	//'Alterar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.GTPA902' OPERATION 5 ACCESS 0	//'Excluir'
	
Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo de dados.

@sample		ModelDef()

@return		oModel - Modelo de dados.

@author		GTP
@since			19/10/2020
@version		P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
	
Local oModel	:= Nil
Local oStruGQO	:= FWFormStruct(1,'GQO')
Local bPosValid	:= {|oModel|TP902TdOK(oModel)}	
Local lEditBloq := SuperGetMv('MV_GTPETIL') == .T.

oModel := MPFormModel():New('GTPA902',/*bPreValid*/,bPosValid,/*bCommit*/,/*bCancel*/)

oStruGQO:SetProperty('GQO_CODIGO' , MODEL_FIELD_WHEN, {|oSubMdl| oSubMdl:GetOperation() == MODEL_OPERATION_INSERT })
oStruGQO:SetProperty('GQO_BLOQUE' , MODEL_FIELD_WHEN, {|oSubMdl| lEditBloq })
oStruGQO:AddTrigger("GQO_VALOR", "GQO_VALOR", {||.T.}, {|| GA902TrigOrig('GQO_VALOR') })
oStruGQO:AddTrigger("GQO_BLOQUE", "GQO_BLOQUE", {||.T.}, {|| GA902TrigOrig('GQO_BLOQUE') })

oModel:AddFields('GQOMASTER',/*cOwner*/,oStruGQO)
oModel:SetDescription(STR0001)	//' Tipos de Documento'
oModel:GetModel('GQOMASTER'):SetDescription(STR0001)	//' Tipos de Documento'
oModel:SetPrimaryKey({"GQO_FILIAL","GQO_CODIGO","GQO_DATA"})
	
Return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface.
@sample		ViewDef()
@return		oView - Retorna a View
@author		GTP
@since			19/10/2020
@version		P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()
	
Local oModel	:= ModelDef()
Local oView		:= FWFormView():New()
Local oStruGQO	:= FWFormStruct(2, 'GQO')
	
oView:SetModel(oModel)
oView:SetDescription(STR0001)	//'Tipos de Documentos'

oView:AddField('VIEW_GQO' ,oStruGQO,'GQOMASTER')
oView:CreateHorizontalBox('TELA', 100)
oView:SetOwnerView('VIEW_GQO','TELA')
	
Return ( oView )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP902TdOK()
@sample		TP902TdOK()
@author		GTP
@since			19/10/2020
@version		P12
/*/
//------------------------------------------------------------------------------------------
Static Function TP902TdOK(oModel)
Local lRet 	:= .T.
Local oMdlGQO	:= oModel:GetModel('GQOMASTER')

// Se já existir a chave no banco de dados no momento do commit, a rotina 
If oModel:GetOperation() == MODEL_OPERATION_INSERT
	GQO->(DbSetOrder(1))
	If GQO->(DbSeek(xFilial("GQO") + oMdlGQO:GetValue('GQO_CODIGO')+DTOS(oMdlGQO:GetValue('GQO_DATA'))))
		Help( ,, 'Help',"TP902TdOK", STR0008, 1, 0 )//'Não pode ser incluido colaborador com a mesma data.'
		lRet := .F.    
	EndIf

	GQO->(DbSetOrder(2))
	If GQO->(DbSeek(xFilial("GQO") + oMdlGQO:GetValue('GQO_CODIGO')+'1')) .AND. GQO->GQO_MSBLQL == '2'
		Help( ,, 'Help',"TP902TdOK", STR0009, 1, 0 )		//'Colaborador bloqueado, deve ser desbloquado antes de uma nova inclusão.'
		lRet := .F.    
	EndIf
ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE
	If oMdlGQO:GetValue('GQO_MSBLQL')=='1'
		Help( ,, 'Help',"TP902TdOK", STR0010, 1, 0 )		//'Não permitida a exclusão para registro com bloqeio cadastral.'
		lRet := .F.  
	EndIf
EndIf

Return (lRet)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA902TrigOrig()
@sample		GA902TrigOrig()
@author		GTP
@since			19/10/2020
@version		P12
/*/
//------------------------------------------------------------------------------------------
Function GA902TrigOrig(cCampo)
Local oModel    := FwModelActive()
Local oFieldGQO := oModel:GetModel('GQOMASTER')

If cCampo == 'GQO_VALOR'
	If oFieldGQO:GetValue("GQO_VALOR") > 0
		oFieldGQO:LoadValue("GQO_BLOQUE", '1') 		
	Else
		oFieldGQO:LoadValue("GQO_BLOQUE", '2') 		
	EndIf
ElseIf cCampo == 'GQO_BLOQUE'
	If oFieldGQO:GetValue("GQO_BLOQUE") =='2' .AND. oFieldGQO:GetValue("GQO_VALOR") > 0
		oFieldGQO:LoadValue("GQO_USUDES", RetCodUsr()) 
	Else
		oFieldGQO:LoadValue("GQO_USUDES", '') 	
	EndIf
EndIf

Return
