#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
//#INCLUDE 'GTPA427.CH'



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA427()
Receitas e Despesas Adicionais
 
@sample	GTPA427()
 
@return	oBrowse
 
@author	Flavio Martins
@since		23/04/2018
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA427()

Local oBrowse		:= Nil	

Private aRotina 	:= MenuDef()

oBrowse := FWMBrowse():New()

oBrowse:SetAlias('GZT')
oBrowse:SetDescription("Despesas e Receitas Adicionais")	// Despesas e Receitas Adicionais
oBrowse:Activate()

Return ( oBrowse )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	Flavio Martins
@since		23/04/2018
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel := nil
Local oStruGZT := FWFormStruct(1,'GZT')
Local oStrGZP  := FWFormStruct(1, "GZP")
Local bCommit  := {|oModel| G427Commit(oModel)}

If !FwIsInCallStack('GTPIRJ427') .AND. GZT->(FieldPos("GZT_SERIE")) > 0 
	oStruGZT:SetProperty('*' , MODEL_FIELD_WHEN, {||.F.})

	if GZT->(FieldPos("GZT_TIPDOC")) > 0
		oStruGZT:SetProperty('GZT_TIPDOC'	, MODEL_FIELD_WHEN, {|oSubMdl|oSubMdl:GetOperation() == MODEL_OPERATION_UPDATE})
	Endif

	oStruGZT:SetProperty('GZT_SERIE'	, MODEL_FIELD_WHEN, {|oSubMdl|oSubMdl:GetOperation() == MODEL_OPERATION_UPDATE})
	
	if GZT->(FieldPos("GZT_SUBSER")) > 0
		oStruGZT:SetProperty('GZT_SUBSER'	, MODEL_FIELD_WHEN, {|oSubMdl|oSubMdl:GetOperation() == MODEL_OPERATION_UPDATE})
	Endif

	if GZT->(FieldPos("GZT_NUMCOM")) > 0
		oStruGZT:SetProperty('GZT_NUMCOM'	, MODEL_FIELD_WHEN, {|oSubMdl|oSubMdl:GetOperation() == MODEL_OPERATION_UPDATE})
	Endif

	if GZT->(FieldPos("GZT_DOC")) > 0
		oStruGZT:SetProperty('GZT_DOC' 		, MODEL_FIELD_WHEN, {|oSubMdl|oSubMdl:GetOperation() == MODEL_OPERATION_UPDATE})
	Endif

	if GZT->(FieldPos("GZT_CODGQ1")) > 0
		oStruGZT:SetProperty('GZT_CODGQ1' 	, MODEL_FIELD_WHEN, {|oSubMdl|oSubMdl:GetOperation() == MODEL_OPERATION_UPDATE})
	Endif
Endif

If FwIsInCallStack('GTPIRJ427') .OR. FwIsInCallStack('GTPI427')
	oStruGZT:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)
	oStruGZT:SetProperty('*' , MODEL_FIELD_WHEN, {||.T.})
Endif

oModel := MPFormModel():New('GTPA427', /*bPreValidacao*/, /*bPosValid*/, bCommit, /*bCancel*/ )

oModel:AddFields('GZTMASTER',/*cOwner*/,oStruGZT)
oModel:addGrid('GZPPAGT','GZTMASTER',oStrGZP, /*bPreValid*/, /*bPosLValid*/, /*bPre*/, /*bPost*/, /*bLoad*/ )

oModel:GetModel('GZPPAGT'):SetMaxLine(6)
aRelation := {{"GZP_FILIAL","xFilial('GZP')"},;
			  {"GZP_CODIGO","GZT_CODGIC"}}

oModel:SetRelation("GZPPAGT", aRelation, GZP->(IndexKey(1)))
oModel:GetModel("GZPPAGT"):SetOptional(.t.)

oModel:SetDescription("Receitas e Despesas Adicionais")
oModel:GetModel('GZTMASTER'):SetDescription("Dados")	// Dados
oModel:SetPrimaryKey({"GZT_FILIAL","GZT_CODIGO"})

Return ( oModel )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface
 
@sample	ViewDef()
 
@return	oView  Retorna a View
 
@author	Flavio Martins
@since		21/04/2018
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= ModelDef() 
Local oView		:= FWFormView():New()
Local oStruGZT	:= FWFormStruct(2, 'GZT')
Local oStrGZP	:= FWFormStruct(2, "GZP")

oStruGZT:SetProperty("GZT_CODGZC", MVC_VIEW_LOOKUP , "GZCFIL")

if GZT->(FieldPos("GZT_TIPDOC")) > 0
	oStruGZT:SetProperty('GZT_TIPDOC', MVC_VIEW_CANCHANGE, .T.)
Endif

if GZT->(FieldPos("GZT_SUBSER")) > 0
	oStruGZT:SetProperty('GZT_SUBSER', MVC_VIEW_CANCHANGE, .T.)
Endif

if GZT->(FieldPos("GZT_NUMCOM")) > 0
	oStruGZT:SetProperty('GZT_NUMCOM', MVC_VIEW_CANCHANGE, .T.)
Endif

if GZT->(FieldPos("GZT_CODGQ1")) > 0
	oStruGZT:SetProperty('GZT_CODGQ1', MVC_VIEW_CANCHANGE, .F.)
Endif

oView:SetModel(oModel)
oView:SetDescription("Receitas e Despesas Adicionais") // Receitas e Despesas Adicionais
oView:GetModel('GZPPAGT'):SetNoInsertLine(.T.)
oView:GetModel('GZPPAGT'):SetNoUpdateLine(.T.)
oView:GetModel('GZPPAGT'):SetNoDeleteLine(.T.)

oView:AddField('VIEW_GZT' ,oStruGZT,'GZTMASTER')
oView:AddGrid("VIEW_GZP",oStrGZP,"GZPPAGT")

oView:AddIncrementField('VIEW_GZP','GZP_ITEM')

// Divisão Horizontal
oView:CreateHorizontalBox('SUPERIOR', 40)
oView:CreateHorizontalBox('INFERIOR', 60)
oView:SetOwnerView("VIEW_GZT", "SUPERIOR")
oView:SetOwnerView("VIEW_GZP", "INFERIOR")

oView:EnableTitleView('VIEW_GZP','Pagto Cartão')

oStrGZP:RemoveField("GZP_FILIAL")
oStrGZP:RemoveField("GZP_CODIGO")
oStrGZP:RemoveField("GZP_CODBIL")
oStrGZP:RemoveField("GZP_DTVEND")

oStruGZT:SetProperty("GZT_CODIGO", MVC_VIEW_ORDEM, '01')
oStruGZT:SetProperty("GZT_NDOCTO", MVC_VIEW_ORDEM, '02')
oStruGZT:SetProperty("GZT_DTVEND", MVC_VIEW_ORDEM, '03')
oStruGZT:SetProperty("GZT_AGENCI", MVC_VIEW_ORDEM, '04')
oStruGZT:SetProperty("GZT_DESAGE", MVC_VIEW_ORDEM, '05')
oStruGZT:SetProperty("GZT_CODGZC", MVC_VIEW_ORDEM, '06')
oStruGZT:SetProperty("GZT_DESCTP", MVC_VIEW_ORDEM, '07')
oStruGZT:SetProperty("GZT_VALOR" , MVC_VIEW_ORDEM, '08')
oStruGZT:SetProperty("GZT_COLAB" , MVC_VIEW_ORDEM, '09')
oStruGZT:SetProperty("GZT_NCOLAB", MVC_VIEW_ORDEM, '10')

if GZT->(FieldPos("GZT_TIPDOC")) > 0
	oStruGZT:SetProperty("GZT_TIPDOC", MVC_VIEW_ORDEM, '11')
Endif

if GZT->(FieldPos("GZT_SERIE")) > 0
	oStruGZT:SetProperty("GZT_SERIE" , MVC_VIEW_ORDEM, '12')
Endif

if GZT->(FieldPos("GZT_SUBSER")) > 0
	oStruGZT:SetProperty("GZT_SUBSER", MVC_VIEW_ORDEM, '13')
Endif

if GZT->(FieldPos("GZT_NUMCOM")) > 0
	oStruGZT:SetProperty("GZT_NUMCOM", MVC_VIEW_ORDEM, '14')
Endif

if GZT->(FieldPos("GZT_DOC")) > 0
	oStruGZT:SetProperty("GZT_DOC"   , MVC_VIEW_ORDEM, '15')
Endif

oStruGZT:SetProperty("GZT_ECFSER", MVC_VIEW_ORDEM, '16')
oStruGZT:SetProperty("GZT_ECFSEQ", MVC_VIEW_ORDEM, '17')
oStruGZT:SetProperty("GZT_CODGIC", MVC_VIEW_ORDEM, '18')
oStruGZT:SetProperty("GZT_NUMFCH", MVC_VIEW_ORDEM, '19')

if GZT->(FieldPos("GZT_CODGQ1")) > 0
	oStruGZT:SetProperty("GZT_CODGQ1", MVC_VIEW_ORDEM, '20')
Endif

Return ( oView )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Retorna as opções do Menu
 
@author	Flavio Martins 
@since		23/04/2018
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE "Visualizar"	ACTION 'VIEWDEF.GTPA427' OPERATION 2 ACCESS 0 // Visualizar

Return ( aRotina )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Função responsável por acionar a integração via mensagem única do cadastro de Localidades.

Nome da mensagem: Receitas e Despesas Adicionais
Fonte da Mensagem: GTPI427

@sample	IntegDef( cXML, nTypeTrans, cTypeMessage, cVersionRec )
 
@param		cXml			Texto da mensagem no formato XML.
@param		nTypeTrans		Código do tipo de transação que está sendo executada.
@param		cTypeMessage	Código com o tipo de Mensagem. (DELETE ou UPSERT)
@param		cVersionRec	Versão da mensagem.

@return	aRet  			Array contendo as informações dos parâmetros para o Adapter.
 
@author	Danilo Dias
@since		16/02/2016
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage, cVersionRec )

	Local aRet := {}

	aRet :=  GTPI427( cXML, nTypeTrans, cTypeMessage, cVersionRec )

Return aRet

/*
 *Protheus.doc G427Commit()
 *type  Static Function
 *author user Eduardo Ferreira
 *since date 05/08/2019
 *version version 12.1.25
 */
Static Function G427Commit(oModel)
Local oMdlGIC := FWLoadModel("GTPA115")
Local oMdlGzp := oMdlGIC:GetModel('GZPPAGTO')
Local aArray  := {}
Local nCont   := 0
Local lRet    := .T.

FwFormCommit(oModel)

If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. !Empty(oModel:GetModel("GZTMASTER"):GetValue("GZT_CODGIC"))

	DbSelectArea("GIC")
	GIC->(DbSetOrder(1))

	If GIC->(dbSeek(xFilial("GIC")+oModel:GetModel('GZTMASTER'):GetValue('GZT_CODGIC')))

		oMdlGIC:SetOperation(MODEL_OPERATION_UPDATE)
		oMdlGIC:Activate()

		If oMdlGzp:Length() > 0

			oMdlGzp:GoLine(1)

			For nCont := 1 to oMdlGzp:Length() 
				aAdd(aArray,{	oMdlGZP:GetValue("GZP_FILIAL", nCont),;
								oMdlGZP:GetValue("GZP_CODIGO", nCont),;
								oMdlGZP:GetValue("GZP_CODBIL", nCont),;
								oMdlGZP:GetValue("GZP_ITEM"  , nCont),;
								oMdlGZP:GetValue("GZP_FPAGTO", nCont),;
								oMdlGZP:GetValue("GZP_TPAGTO", nCont),;
								oMdlGZP:GetValue("GZP_DCART" , nCont),;
								oMdlGZP:GetValue("GZP_VALOR ", nCont),;
								oMdlGZP:GetValue("GZP_QNTPAR", nCont),;
								oMdlGZP:GetValue("GZP_NSU"   , nCont),;
								oMdlGZP:GetValue("GZP_AUT"   , nCont),;
								oMdlGZP:GetValue("GZP_DTVEND", nCont),;
								oMdlGZP:GetValue("GZP_STAPRO", nCont),;
								oMdlGZP:GetValue("GZP_TITTEF", nCont),;
								oMdlGZP:GetValue("GZP_BILREF", nCont),;
								oMdlGZP:GetValue("GZP_STATUS", nCont),;
								oMdlGZP:GetValue("GZP_FILORI", nCont),;
								oMdlGZP:GetValue("GZP_ESTAB ", nCont),;
								oMdlGZP:GetValue("GZP_CODGZT", nCont)})
			Next 

			For nCont := 1 to Len(aArray)
				oMdlGZP:AddLine()
				
				oMdlGZP:SetValue("GZP_FILIAL", aArray[nCont, 1])
				oMdlGZP:SetValue("GZP_CODIGO", aArray[nCont, 2])
				oMdlGZP:SetValue("GZP_CODBIL", aArray[nCont, 3])
				oMdlGZP:SetValue("GZP_ITEM"  , "T"+Right(aArray[nCont, 4], 2))
				oMdlGZP:SetValue("GZP_FPAGTO", aArray[nCont, 5])
				oMdlGZP:SetValue("GZP_TPAGTO", aArray[nCont, 6])
				oMdlGZP:SetValue("GZP_DCART" , aArray[nCont, 7])
				oMdlGZP:SetValue("GZP_VALOR" , Round(oModel:GetModel('GZTMASTER'):GetValue('GZT_VALOR')/Len(aArray), 2))
				oMdlGZP:SetValue("GZP_QNTPAR", aArray[nCont, 9])
				oMdlGZP:SetValue("GZP_NSU"   , aArray[nCont, 10])
				oMdlGZP:SetValue("GZP_AUT"   , aArray[nCont, 11])
				oMdlGZP:SetValue("GZP_DTVEND", aArray[nCont, 12])
				oMdlGZP:SetValue("GZP_STAPRO", aArray[nCont, 13])
				oMdlGZP:SetValue("GZP_TITTEF", aArray[nCont, 14])
				oMdlGZP:SetValue("GZP_BILREF", aArray[nCont, 15])
				oMdlGZP:SetValue("GZP_STATUS", aArray[nCont, 16])
				oMdlGZP:SetValue("GZP_FILORI", aArray[nCont, 17])
				oMdlGZP:SetValue("GZP_ESTAB" , aArray[nCont, 18])
				oMdlGZP:SetValue("GZP_CODGZT", oModel:GetModel('GZTMASTER'):GetValue('GZT_CODIGO'))

			Next

			If (lRet := oMdlGIC:VldData())
				oMdlGIC:CommitData()
			EndIf

			oMdlGIC:DeActivate()
			oMdlGIC:Destroy()

		EndIf

	EndIf

EndIf

Return lRet
