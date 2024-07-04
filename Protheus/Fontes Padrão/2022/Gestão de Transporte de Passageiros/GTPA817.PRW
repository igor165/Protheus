#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA817.CH"

Function GTPA817()

Local oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GIL")
oBrowse:SetDescription(STR0001) // ParÃ¢metros de Clientes - Encomendas
oBrowse:DisableDetails()
oBrowse:Activate()

Return oBrowse

/*/{Protheus.doc} MenuDef
//TODO Descrição auto-gerada.
@author osmar.junior
@since 04/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002	ACTION "VIEWDEF.GTPA817" OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0003	ACTION "VIEWDEF.GTPA817" OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0004	ACTION "VIEWDEF.GTPA817" OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0005	ACTION "VIEWDEF.GTPA817" OPERATION 5 ACCESS 0 // Excluir

Return aRotina

/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author osmar.junior
@since 04/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()
Local oModel
Local oStruGIL  := FWFormStruct(1,"GIL")
Local bPosValid := {|oModel| GA817TdOk(oModel)}

oModel 	:= MPFormModel():New("GTPA817",/*bPreValidMdl*/, bPosValid, /*bCommit*/, /*bCancel*/ )

GA817Struc('M',oStruGIL)

oModel:SetDescription(STR0001) // ParÃ¢metros de Clientes
oModel:AddFields("FIELDGIL",,oStruGIL)
oModel:GetModel('FIELDGIL'):SetDescription(STR0001)	// 'ParÃ¢metros de Clientes - Encomendas'
oModel:SetPrimaryKey({"GIL_FILIAL","GIL_CODIGO","GIL_LOJA"})

Return oModel

/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author osmar.junior
@since 04/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()

Local oModel	:= FwLoadModel('GTPA817')
Local oView		:= FWFormView():New()
Local oStruGIL	:= FWFormStruct(2, "GIL")

oStruGIL:AddGroup( "CLIENTE"   , "", "" , 2 )
oStruGIL:SetProperty("GIL_CODIGO", MVC_VIEW_LOOKUP , "SA1")
oStruGIL:SetProperty("GIL_CODIGO" , MVC_VIEW_GROUP_NUMBER, "CLIENTE" )
oStruGIL:SetProperty("GIL_LOJA" , MVC_VIEW_GROUP_NUMBER, "CLIENTE" )
oStruGIL:SetProperty("GIL_NOMECL" , MVC_VIEW_GROUP_NUMBER, "CLIENTE" )

oStruGIL:AddGroup( "ENCOMENDA"   , "Encomenda", "" , 2 )

oStruGIL:SetProperty("GIL_CONDPG", MVC_VIEW_LOOKUP , "SE4")   
oStruGIL:SetProperty("GIL_CONDPG" , MVC_VIEW_GROUP_NUMBER, "ENCOMENDA" )

oStruGIL:SetProperty("GIL_PRODUT", MVC_VIEW_LOOKUP , "SB1")
oStruGIL:SetProperty("GIL_PRODUT" , MVC_VIEW_GROUP_NUMBER, "ENCOMENDA" )
oStruGIL:SetProperty("GIL_DESCPR" , MVC_VIEW_GROUP_NUMBER, "ENCOMENDA" )

oStruGIL:SetProperty("GIL_PERDES" , MVC_VIEW_GROUP_NUMBER, "ENCOMENDA" )
oStruGIL:SetProperty("GIL_TPFRET" , MVC_VIEW_GROUP_NUMBER, "ENCOMENDA" )
	
oStruGIL:RemoveField("GIL_TES")

If GIL->(FieldPos("GIL_RETIRA")) > 0 .AND. GIL->(FieldPos("GIL_FATURA")) > 0 .AND. GIL->(FieldPos("GIL_CARTAO")) > 0 .AND. GIL->(FieldPos("GIL_DINHEI")) > 0
	oStruGIL:AddGroup( "TPPAGAMENTO"   , "Tipo de Pagamento", "" , 2 )

	oStruGIL:SetProperty("GIL_RETIRA" , MVC_VIEW_GROUP_NUMBER, "TPPAGAMENTO" )
	oStruGIL:SetProperty("GIL_FATURA" , MVC_VIEW_GROUP_NUMBER, "TPPAGAMENTO" )
	oStruGIL:SetProperty("GIL_CARTAO" , MVC_VIEW_GROUP_NUMBER, "TPPAGAMENTO" )
	oStruGIL:SetProperty("GIL_DINHEI" , MVC_VIEW_GROUP_NUMBER, "TPPAGAMENTO" )
EndIf

oView:SetModel(oModel)
oView:SetDescription(STR0001)///'ParÃ¢metros do Cliente'
oView:AddField("VIEW_GIL", oStruGIL, "FIELDGIL")
oView:EnableTitleView('VIEW_GIL'	,STR0001)	//'ParÃ¢metros do Cliente'

Return oView

/*/{Protheus.doc} GA817VldCli
//TODO Descrição auto-gerada.
@author osmar.junior
@since 04/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function GA817VldCli()

Local lRet := .T.

IF !Empty(FWFldGet("GIL_LOJA")) .and. !ExistChav("GIL", FWFldGet("GIL_CODIGO") + FWFldGet("GIL_LOJA")) 
	lRet := .F.
Endif

If lRet .and. !ExistCpo("SA1", FWFldGet("GIL_CODIGO")+AllTrim(FWFldGet("GIL_LOJA")))
	lRet := .F.
ENDIF

Return lRet

/*/{Protheus.doc} GA817Struc
//TODO Descrição auto-gerada.
@author osmar.junior
@since 04/12/2019
@version 1.0
@return ${return}, ${return_description}
@param cTipo, characters, descricao
@param oStruGIL, object, descricao
@type function
/*/
Function GA817Struc(cTipo,oStruGIL)
Local aTrigger	:= {}
Local bFieldVld	:= {|oMdl,cField,uVal| FieldValid(oMdl,cField,uVal)}

	IF cTipo = 'M'
		// GIL
		aTrigger := FwStruTrigger("GIL_LOJA","GIL_NOMECL","Posicione('SA1',1,xFilial('SA1')+FwFldGet('GIL_CODIGO')+FwFldGet('GIL_LOJA'),'A1_NOME')" )	
		oStruGIL:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])
		
		aTrigger := FwStruTrigger("GIL_PRODUT","GIL_DESCPR","Posicione('SB1',1,xFilial('SB1')+FwFldGet('GIL_PRODUT'),'B1_DESC')" )	
		oStruGIL:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])
		
		oStruGIL:SetProperty("GIL_CODIGO", MODEL_FIELD_WHEN, {|| INCLUI } )
		oStruGIL:SetProperty("GIL_LOJA", MODEL_FIELD_WHEN, {|| INCLUI } )

		oStruGIL:SetProperty("GIL_CONDPG", MODEL_FIELD_OBRIGAT,.T.)
		oStruGIL:SetProperty("GIL_PRODUT", MODEL_FIELD_OBRIGAT,.T.)

		oStruGIL:SetProperty('GIL_PRODUT', MODEL_FIELD_VALID, bFieldVld)
	
	Endif
Return

/*/{Protheus.doc} FieldValid()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 07/04/2022
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function FieldValid(oMdl, cField, uVal)
Local lRet := .T.

If cField == 'GIL_PRODUT'

	SB1->(dbSetOrder(1))

	If SB1->(dbSeek(xFilial('SB1')+uVal)) .And. Empty(SB1->B1_TS)
		oMdl:GetModel():SetErrorMessage(oMdl:GetId(), cField, oMdl:GetId(), cField, "FieldValid", "TES de saída não informado no produto selecionado", "Informe a TES no produto selecionado ou informe outro produto") 
		lRet := .F.	
	Endif

Endif

Return lRet

/*/{Protheus.doc} GA817TdOk
//TODO Descrição auto-gerada.
@author osmar.junior
@since 04/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function GA817TdOk(oModel)
Local lRet     := .T.
Local cMsgErro := ""
Local cMsgTitu := ""
Local oMdlGIL  := oModel:GetModel('FIELDGIL')

IF (oModel:GetOperation() == MODEL_OPERATION_INSERT)
	// Verificação dupla da chave primária devido ao problema de concorrência de acessos apresentados na primeira entrega
	IF !GA817VldCli()
		lRet := .F.
	ENDIF
ENDIF

If GIL->(FieldPos("GIL_RETIRA")) > 0 .AND. GIL->(FieldPos("GIL_FATURA")) > 0 .AND. GIL->(FieldPos("GIL_CARTAO")) > 0 .AND. GIL->(FieldPos("GIL_DINHEI")) > 0
	IF (oModel:GetOperation() == MODEL_OPERATION_INSERT) .OR. (oModel:GetOperation() == MODEL_OPERATION_UPDATE)
		If (oMdlGIL:GetValue("GIL_RETIRA") .and. oMdlGIL:GetValue("GIL_FATURA") .and. oMdlGIL:GetValue("GIL_CARTAO") .and. oMdlGIL:GetValue("GIL_DINHEI"))
			lRet := .F.
			cMsgErro := "Só é permitido utilizar um tipo de pagamento padrão."
			cMsgTitu := "Todos os tipos foram selecionados."
		EndIf		

		If lRet .AND. (oMdlGIL:GetValue("GIL_RETIRA") .and. (oMdlGIL:GetValue("GIL_FATURA") .or. oMdlGIL:GetValue("GIL_CARTAO") .or. oMdlGIL:GetValue("GIL_DINHEI")))
			lRet := .F.
			cMsgErro := "Só é permitido utilizar um tipo de pagamento padrão."
			cMsgTitu := "Mais de um tipo foi selecionado."
		EndIf

		If lRet .AND. (oMdlGIL:GetValue("GIL_FATURA") .and. (oMdlGIL:GetValue("GIL_RETIRA") .or. oMdlGIL:GetValue("GIL_CARTAO") .or. oMdlGIL:GetValue("GIL_DINHEI")))
			lRet := .F.
			cMsgErro := "Só é permitido utilizar um tipo de pagamento padrão."
			cMsgTitu := "Mais de um tipo foi selecionado."
		EndIf

		If lRet .AND. (oMdlGIL:GetValue("GIL_CARTAO") .and. (oMdlGIL:GetValue("GIL_FATURA") .or. oMdlGIL:GetValue("GIL_RETIRA") .or. oMdlGIL:GetValue("GIL_DINHEI")))
			lRet := .F.
			cMsgErro := "Só é permitido utilizar um tipo de pagamento padrão."
			cMsgTitu := "Mais de um tipo foi selecionado."
		EndIf

		If !(EMPTY(cMsgErro))
			oModel:SetErrorMessage(oMdlGIL:GetId(),"",oMdlGIL:GetId(),"",'GA817TdOk',cMsgTitu,cMsgErro) 
		EndIf
	EndIf
EndIf
Return lRet
