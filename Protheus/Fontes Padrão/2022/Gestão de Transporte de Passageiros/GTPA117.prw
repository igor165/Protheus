#include 'gtpa117.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'

/*/{Protheus.doc} GTPA117
Cadastro de Taxas

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 04/10/2017
@version 

@type function
/*/
Function GTPA117()

Local oBrowse	:= FWLoadBrw('GTPA117')
Private aRotina	:= MenuDef()

 oBrowse:Activate()
 oBrowse:Destroy()

GTPDestroy(oBrowse)
	
Return

Static Function BrowseDef()
Local oBrowse 	:= FWMBrowse():New()
Local cTpDocBag	:= GTPGetRules('TPDOCEXBAG')

oBrowse:SetAlias('G57')

oBrowse:SetMenuDef('GTPA117')

oBrowse:SetDescription(STR0001) // Cadastro de Taxas'

If G57->(FieldPos('G57_STAENV')) > 0
	oBrowse:AddLegend("G57_TIPO = '" +cTpDocBag+ "' .And. G57_STAENV == '0'", "WHITE" , STR0038) //"Não Transmitido"
	oBrowse:AddLegend("G57_TIPO = '" +cTpDocBag+ "' .And. G57_STAENV == '1'", "YELLOW", STR0039) //"Aguardando Envio TSS"
	oBrowse:AddLegend("G57_TIPO = '" +cTpDocBag+ "' .And. G57_STAENV == '2'", "GREEN" , STR0040) //"Transmitido"
	oBrowse:AddLegend("G57_TIPO = '" +cTpDocBag+ "' .And. G57_STAENV == '3'", "RED"   , STR0041) //"Evento Rejeitado"
Endif

Return oBrowse

/*/{Protheus.doc} MenuDef
Definição de Menu do Cadastro de Taxas (de embarque e excedente)

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 04/10/2017
@version 

@type function
/*/
Static Function MenuDef()

Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002   ACTION "PesqBrw"         OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003   ACTION 'VIEWDEF.GTPA117' OPERATION 2 ACCESS 0 // #Visualizar
	ADD OPTION aRotina TITLE STR0004   ACTION 'VIEWDEF.GTPA117' OPERATION 3 ACCESS 0 // #Incluir
	ADD OPTION aRotina TITLE STR0005   ACTION 'VIEWDEF.GTPA117' OPERATION 4 ACCESS 0 // #Alterar
	ADD OPTION aRotina TITLE STR0006   ACTION "VIEWDEF.GTPA117" OPERATION 5 ACCESS 0 // #Excluir
	ADD OPTION aRotina TITLE STR0007   ACTION 'GTPR117'         OPERATION 3 ACCESS 0 // #Impressão de Taxa
	If FindFunction("GTPA117C")
		ADD OPTION aRotina TITLE STR0034   ACTION 'GTPA117C(1)'     OPERATION 9 ACCESS 0 // "Evento de Excesso de Bagagem"
		ADD OPTION aRotina TITLE STR0044   ACTION 'GTPA117C(2)'     OPERATION 9 ACCESS 0 // "Atualiza status do envio"
	EndIf

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do Modelo de Dados do Cadastro de Taxas

@author SIGAGTP | Gabriela Naomi Kamimoto	
@since 15/07/2017
@version 

@type function
/*/

Static Function ModelDef()

Local oModel	:= nil
Local oStruG57	:= FWFormStruct( 1,"G57")	//Tabela de Taxas
Local bPosValid	:= {|oModel| GA117PosVld(oModel)}
Local bCommit	:= {|oModel| GA117Commit(oModel)}
	
	SetModelStruct(oStruG57)
	
	oModel := MPFormModel():New('GTPA117', /*bPreValidacao*/, bPosValid, /*bCommit*/, /*bCancel*/ )
	
	oModel:SetCommit(bCommit)
	oModel:AddFields('G57MASTER',/*cPai*/,oStruG57)
	oModel:SetPrimaryKey({"G57_FILIAL","G57_NUMMOV","G57_SERIE","G57_SUBSER","G57_NUMCOM","G57_CODIGO", "G57_TIPO" })

	oModel:AddRules("G57MASTER","G57_TIPO"	,"G57MASTER","G57_AGENCI",1)
	oModel:AddRules("G57MASTER","G57_SERIE"	,"G57MASTER","G57_AGENCI",1)
	oModel:AddRules("G57MASTER","G57_SUBSER","G57MASTER","G57_AGENCI",1)
	oModel:AddRules("G57MASTER","G57_CODIGO","G57MASTER","G57_AGENCI",1)

	oModel:SetDescription(STR0001) //"Cadastro de Taxas"
	oModel:SetVldActivate({|oModel| GA117VldAct(oModel)})
	
Return oModel

/*/{Protheus.doc} SetModelStruct
(long_description)
@type function
@author jacomo.fernandes
@since 12/02/2019
@version 1.0
@param oStruG57, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetModelStruct(oStruG57)

Local bFldVld	:= {|oMdl,cField,cNewValue,cOldValue| GTPA117Vld(oMdl,cField,cNewValue,cOldValue) }
Local bTrig		:= {|oMdl,cField,xVal|GTPA117TRG(oMdl,cField,xVal)}
	
	oStruG57:SetProperty('G57_NUMMOV', MODEL_FIELD_OBRIGAT, .F.)
	oStruG57:SetProperty('G57_AGENCI', MODEL_FIELD_OBRIGAT, .T.)
	
	oStruG57:SetProperty('G57_SERIE' , MODEL_FIELD_VALID, bFldVld )
	oStruG57:SetProperty('G57_SUBSER', MODEL_FIELD_VALID, bFldVld )
	oStruG57:SetProperty('G57_NUMCOM', MODEL_FIELD_VALID, bFldVld )
	oStruG57:SetProperty('G57_CODIGO', MODEL_FIELD_VALID, bFldVld )
	oStruG57:SetProperty('G57_AGENCI', MODEL_FIELD_VALID, bFldVld )
	
	oStruG57:SetProperty("G57_AGENCI"	, MODEL_FIELD_NOUPD, .T.)
	oStruG57:SetProperty("G57_TIPO"		, MODEL_FIELD_NOUPD, .T.)
	oStruG57:SetProperty("G57_SERIE"	, MODEL_FIELD_NOUPD, .T.)
	oStruG57:SetProperty("G57_SUBSER"	, MODEL_FIELD_NOUPD, .T.)
	oStruG57:SetProperty("G57_NUMCOM"	, MODEL_FIELD_NOUPD, .T.)
	oStruG57:SetProperty("G57_CODIGO"	, MODEL_FIELD_NOUPD, .T.)
	oStruG57:SetProperty("G57_VALOR"	, MODEL_FIELD_NOUPD, .T.)
	oStruG57:SetProperty("G57_EMISSA"	, MODEL_FIELD_NOUPD, .T.)
	oStruG57:SetProperty("G57_EMISSO"	, MODEL_FIELD_NOUPD, .T.)

	oStruG57:AddTrigger("G57_TIPO"		,"G57_TIPO"		,{||.T.},bTrig)
	oStruG57:AddTrigger("G57_CODIGO"	,"G57_CODIGO"	,{||.T.},bTrig)
	oStruG57:AddTrigger("G57_NUMCOM"	,"G57_NUMCOM"	,{||.T.},bTrig)
	oStruG57:AddTrigger("G57_SERIE"		,"G57_SERIE"	,{||.T.},bTrig)
	oStruG57:AddTrigger("G57_SUBSER"	,"G57_SUBSER"	,{||.T.},bTrig)
	oStruG57:AddTrigger("G57_AGENCI"	,"G57_AGENCI"	,{||.T.},bTrig)
	
	If G57->(FieldPos('G57_CODGIC')) > 0
		oStruG57:SetProperty('G57_CODGIC', MODEL_FIELD_VALID, bFldVld )
		oStruG57:SetProperty("G57_CODGIC", MODEL_FIELD_NOUPD, .T.)
	Endif
	
Return

/*/{Protheus.doc} GA117VldAct
Validação da ativação do modelo
@type function
@author jacomo.fernandes
@since 28/12/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GA117VldAct(oModel)
Local lRet	:= .T.
Local nOpc	:= oModel:GetOperation()

If FwIsInCallStack("GTPA117")
	If (nOpc ==  MODEL_OPERATION_UPDATE .or. nOpc ==  MODEL_OPERATION_DELETE ).and. !Empty(G57->G57_NUMFCH)  
	    oModel:SetErrorMessage(oModel:GetId(), , oModel:GetId(), , "GA117VldAct", STR0036, STR0037) // 'Não é possivel alterar ou deletar taxas que já foram vinculadas a ficha' 'Caso necessário, deletar a ficha primeiramente e realizar a alteração da Taxa'
	    lRet := .F.
	Endif
EndIf
Return lRet

/*/{Protheus.doc} ViewDef
Definição da Interface do Cadastro de Taxas

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 04/10/2017
@version 

@type function
/*/
Static Function ViewDef()

Local oModel	:= FWLoadModel('GTPA117')
Local oStruG57	:= FWFormStruct(2,'G57')
Local oView		:= Nil

	SetViewStruct(oStruG57)
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:SetDescription(STR0001) 

	oView:AddField('VIEW_G57',oStruG57,'G57MASTER')
	oView:CreateHorizontalBox('VIEWTOTAL',100)
	
	oView:SetOwnerView('VIEW_G57','VIEWTOTAL')

Return oView


/*/{Protheus.doc} SetViewStruct
(long_description)
@type function
@author jacomo.fernandes
@since 12/02/2019
@version 1.0
@param oStruG57, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStruct(oStruG57)

	oStruG57:RemoveField('G57_CODDT')
	oStruG57:RemoveField('G57_CONFER')
	oStruG57:RemoveField('G57_NUMMOV')
	
	oStruG57:SetProperty('G57_SERIE'  , MVC_VIEW_CANCHANGE , .T. )
	oStruG57:SetProperty('G57_SUBSER' , MVC_VIEW_CANCHANGE , .T. )
	oStruG57:SetProperty('G57_NUMCOM' , MVC_VIEW_CANCHANGE , .T. )
	
	oStruG57:SetProperty('G57_VALACE' , MVC_VIEW_CANCHANGE , .F. )
	oStruG57:SetProperty('G57_CODG5A' , MVC_VIEW_CANCHANGE , .F. )
	oStruG57:SetProperty('G57_MOTREJ' , MVC_VIEW_CANCHANGE , .F. )
	oStruG57:SetProperty('G57_DESCRI' , MVC_VIEW_CANCHANGE , .F. )
	oStruG57:SetProperty('G57_CODGQ1' , MVC_VIEW_CANCHANGE , .F. )
	
	If G57->(FieldPos('G57_PROENV')) > 0 .And. G57->(FieldPos('G57_STAENV')) 
		oStruG57:SetProperty('G57_PROENV' , MVC_VIEW_CANCHANGE , .F. )
		oStruG57:SetProperty('G57_STAENV' , MVC_VIEW_CANCHANGE , .F. )
	Endif

	oStruG57:SetProperty('G57_CODIGO', MVC_VIEW_LOOKUP, "GIIFIL")
	
	oStruG57:SetProperty('G57_AGENCI'	, MVC_VIEW_ORDEM , '02' )
	oStruG57:SetProperty('G57_DESCRI'	, MVC_VIEW_ORDEM , '03' )
	oStruG57:SetProperty('G57_TIPO'		, MVC_VIEW_ORDEM , '04' )
	oStruG57:SetProperty('G57_DOCDES'	, MVC_VIEW_ORDEM , '05' )
	oStruG57:SetProperty('G57_SERIE'	, MVC_VIEW_ORDEM , '06' )
	oStruG57:SetProperty('G57_SUBSER'	, MVC_VIEW_ORDEM , '07' )
	oStruG57:SetProperty('G57_NUMCOM'	, MVC_VIEW_ORDEM , '08'	)
	oStruG57:SetProperty('G57_CODIGO'	, MVC_VIEW_ORDEM , '09' )

	oStruG57:AddGroup('GRP001', 'Dados da Taxa','', 2)	
	oStruG57:AddGroup('GRP002', 'Controle de Documentos','', 2)	

	oStruG57:SetProperty('G57_AGENCI', MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStruG57:SetProperty('G57_DESCRI', MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStruG57:SetProperty('G57_EMISSA', MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStruG57:SetProperty('G57_VALOR' , MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStruG57:SetProperty('G57_EMISSO', MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStruG57:SetProperty('G57_NEMISS', MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStruG57:SetProperty('G57_CODGIC', MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStruG57:SetProperty('G57_LOCORI', MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStruG57:SetProperty('G57_NLOCOR', MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStruG57:SetProperty('G57_LOCDES', MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStruG57:SetProperty('G57_NLOCDE', MVC_VIEW_GROUP_NUMBER, 'GRP001')

	If  G57->(FieldPos('G57_QTDBAG')) > 0
		oStruG57:SetProperty('G57_QTDBAG', MVC_VIEW_GROUP_NUMBER, 'GRP001')
	Endif

	oStruG57:SetProperty('G57_TIPO'  , MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStruG57:SetProperty('G57_DOCDES', MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStruG57:SetProperty('G57_SERIE' , MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStruG57:SetProperty('G57_SUBSER', MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStruG57:SetProperty('G57_NUMCOM', MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStruG57:SetProperty('G57_CODIGO', MVC_VIEW_GROUP_NUMBER, 'GRP002')

Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} GA117PosVld(oModel)
Pos validação do modelo de dados
@author  Renan Ribeiro Brando	
@since   27/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function GA117PosVld(oModel)

	Local lRet := .T.
	Local nOpc		:= oModel:GetOperation()
	Local cNumMov   := oModel:GetValue("G57MASTER", "G57_NUMMOV")
	Local cSerie    := oModel:GetValue("G57MASTER", "G57_SERIE" )
	Local cSubSerie := oModel:GetValue("G57MASTER", "G57_SUBSER")
	Local cComple   := oModel:GetValue("G57MASTER", "G57_NUMCOM")
	Local cCodigo   := oModel:GetValue("G57MASTER", "G57_CODIGO")
	Local cTipo     := oModel:GetValue("G57MASTER", "G57_TIPO"  )
	Local cAgencia  := oModel:GetValue("G57MASTER", "G57_AGENCI")
	Local dDtEmiss  := oModel:GetValue("G57MASTER", "G57_EMISSA")
	Local cCodBil   := ''
	Local cTpDocBag := GTPGetRules('TPDOCEXBAG')
	Local nQtdBag	:= 0

	If nOpc == MODEL_OPERATION_INSERT
		//Função responsavel pela validação do controle de documento
		If lRet .and. !GA115VldCtr(cAgencia,cTipo, cSerie, cSubSerie, cComple, cCodigo,dDtEmiss)
			lRet := .F.
		Endif 
		
		If !ExistChav("G57", cNumMov + cSerie + cSubSerie + cComple + cCodigo + cTipo, 2)
			lRet := .F. 
			Help( ,, "Help", STR0009, STR0008, 1, 0) // "Código do Lote inválido", cNumMov + "/" + cCodigo , "Selecione outro documento."
		EndIf
		
	Endif

	If lRet .And. G57->(FieldPos('G57_CODGIC')) > 0 .And. GYA->(FieldPos('GYA_VINBIL')) > 0

		GYA->(dbSetOrder(1))

		If GYA->(dbSeek(xFilial('GYA')+cTipo)) .And. GYA->GYA_VINBIL == '1'

			cCodBil 	:= oModel:GetValue("G57MASTER", "G57_CODGIC")

			If Empty(cCodBil)
				lRet := .F.
				oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"GA117PosVld", STR0027) //"Obrigatório informar código de bilhete para este tipo de documento"
			EndIf

		Endif

	Endif

	If G57->(FieldPos('G57_QTDBAG')) > 0 

		nQtdBag := oModel:GetValue("G57MASTER", "G57_QTDBAG")

		If cTipo == cTpDocBag .And. nQtdBag == 0
			lRet := .F.
			oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"GA117PosVld", STR0035) //"Quantidade de Bagagem obrigatório para excesso de bagagem"
		Endif

	Endif
	
Return lRet

/*/{Protheus.doc} GA117Commit
(long_description)
@type function
@author jacomo.fernandes
@since 21/12/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GA117Commit(oModel)
Local lRet		:= .T.
Local oMdlG57	:= oModel:GetModel('G57MASTER')
Local nOpc		:= oModel:GetOperation()
Local cNumMov   := oMdlG57:GetValue("G57_NUMMOV")
Local cSerie    := oMdlG57:GetValue("G57_SERIE" )
Local cSubSerie := oMdlG57:GetValue("G57_SUBSER")
Local cComple   := oMdlG57:GetValue("G57_NUMCOM")
Local cCodigo   := oMdlG57:GetValue("G57_CODIGO")
Local cTipo     := oMdlG57:GetValue("G57_TIPO"  )
Local cAgencia  := oMdlG57:GetValue("G57_AGENCI")
Local lUtil		:= If(nOpc <> MODEL_OPERATION_DELETE,.T.,.F. )
Local cAliasTab	:= "G57"
Local cChave	:= xFilial('G57')+cNumMov+cSerie+cSubSerie+cComple+cCodigo+cTipo
Local cTpDocBag := GTPGetRules('TPDOCEXBAG')

Begin Transaction
	If lRet .and. nOpc <> MODEL_OPERATION_UPDATE
		lRet := GA115AtuCtr(cAgencia, cTipo, cSerie, cSubSerie, cComple, cCodigo, lUtil, cAliasTab, cChave)	
	Endif
	
	If lRet
		lRet := FwFormCommit(oModel)	
	Else
		DisarmTransaction()	
	Endif

	If lRet .And. cTipo == cTpDocBag
		If MsgYesNo(STR0042, STR0043) //"Deseja enviar o evento de excesso de bagagem agora? Esta ação não poderá ser desfeita", "Evento Excesso de Bagagem" 
			GTPA117C()
		Endif
	Endif

End Transaction	

Return lRet

/*/{Protheus.doc} GTPA117Vld
(long_description)
@type function
@author jacomo.fernandes
@since 12/02/2019
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param cNewValue, character, (Descrição do parâmetro)
@param cOldValue, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GTPA117Vld(oMdl,cField,cNewValue,cOldValue)
Local lRet		:= .T.
Local cMsgErro	:= ""
Local cMsgSolu	:= ""
Local cAgencia  := oMdl:GetValue("G57_AGENCI")
Local cTipo     := oMdl:GetValue("G57_TIPO"  )
Local cSerie    := oMdl:GetValue("G57_SERIE" )
Local cSubSerie := oMdl:GetValue("G57_SUBSER")
Local cComple   := oMdl:GetValue("G57_NUMCOM")
Local cCodigo   := oMdl:GetValue("G57_CODIGO")
Local dDtEmiss  := oMdl:GetValue("G57_EMISSA") 

Do Case
	Case Empty(cNewValue)
		lRet := .T.
	Case cField $ "G57_SERIE|G57_SUBSER|G57_NUMCOM|G57_CODIGO"
		If !Empty(cAgencia) .and. !Empty(cTipo) .and. !Empty(cSerie) .and. !Empty(cSubSerie) .and. !Empty(cComple) .and. !Empty(cCodigo) 
			//Função responsavel pela validação do controle de documento
			lRet := GA115VldCtr(cAgencia,cTipo, cSerie, cSubSerie, cComple, cCodigo,dDtEmiss)
		Endif
	Case cField == "G57_AGENCI"
		lRet := ValidUserAg(oMdl,cField,cNewValue,cOldValue)
	Case cField == 'G57_CODGIC'
		lRet := VldBilhete(cNewValue, cTipo, @cMsgErro, @cMsgSolu) 
		
EndCase

If !lRet .and. !Empty(cMsgErro)
	oMdl:GetModel():SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"GTPA303Vld",cMsgErro,cMsgSolu,cNewValue,cOldValue)
Endif

Return lRet


/*/{Protheus.doc} GTPA117TRG
(long_description)
@type function
@author jacomo.fernandes
@since 12/02/2019
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param xVal, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GTPA117TRG(oMdl,cField,xVal)

Do Case

	Case cField == "G57_AGENCI"
		oMdl:LoadValue("G57_TIPO"	,'')
		oMdl:LoadValue("G57_SERIE"	,'')
		oMdl:LoadValue("G57_SUBSER"	,'')
		oMdl:LoadValue("G57_CODIGO"	,'')
		oMdl:LoadValue("G57_NUMCOM"	,'')
		oMdl:LoadValue("G57_DOCDES"	,'')
		oMdl:LoadValue("G57_NUMMOV"	,'')
		
	Case cField == "G57_TIPO"	
		oMdl:SetValue("G57_DOCDES",Posicione('GYA',1,xFilial('GYA')+xVal,"GYA_DESCRI"))
	Case cField == "G57_CODIGO" .Or. cField == "G57_TIPO" .Or. cField == "G57_NUMCOM" .Or. cField == "G57_SERIE" .Or. cField == "G57_SUBSER"
		If GtpIsInPoui()
			oMdl:LoadValue("G57_NUMMOV",Posicione('GII',4,xFilial('GII')+oMdl:GetValue('G57_AGENCI')+;
												oMdl:GetValue('G57_TIPO')+oMdl:GetValue('G57_SERIE')+;
												oMdl:GetValue('G57_SUBSER')+oMdl:GetValue('G57_NUMCOM')+;
												oMdl:GetValue('G57_CODIGO'),'GII_NUMMOV'))
		Else
			oMdl:LoadValue("G57_NUMMOV",Posicione('GII',4,xFilial('GII')+oMdl:GetValue('G57_AGENCI')+;
												oMdl:GetValue('G57_TIPO')+oMdl:GetValue('G57_SERIE')+;
												oMdl:GetValue('G57_SUBSER'),'GII_NUMMOV'))
		EndIf
		
EndCase

Return xVal

/*/{Protheus.doc} VldBilhete
Valida se o bilhete selecionado pode ser vinculado a taxa
@type function
@author flavio.martins
@since 11/08/2020
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function VldBilhete(cCodBil, cTipo, cMsgErro, cMsgSolu)
Local lRet 		:= .T.
Local cAliasTmp	:= GetNextAlias()

GIC->(dbSetOrder(1))

If !(GIC->(dbSeek(xFilial('GIC')+cCodBil)))

	lRet := .F.
	cMsgErro := STR0030 // "Código de bilhete não encontrado"
	cMsgSolu := STR0031 // "Selecione um código de bilhete válido"

ElseIf !(GIC->GIC_STATUS $ 'E|V')

	lRet := .F.
	cMsgErro := STR0028 // "Status do bilhete não permite a utilização"
	cMsgSolu := STR0029 // "Selecione um bilhete com status Vendido ou Entregue"

Endif

If lRet

	BeginSql Alias cAliasTmp

		SELECT G57_CODIGO
		FROM %Table:G57%
		WHERE G57_FILIAL = %xFilial:G57%
			AND G57_TIPO = %Exp:cTipo%
			AND G57_CODGIC = %Exp:cCodBil%
			AND %NotDel%	

	EndSql

	If !(Empty((cAliasTmp)->G57_CODIGO))
		lRet := .F.
		cMsgErro := STR0032 // "Bilhete selecionado está vinculado a outra taxa cadastrada"
		cMsgSolu := STR0033 // "Selecione outro bilhete"
	Endif

	(cAliasTmp)->(dbCloseArea())

Endif

Return lRet
