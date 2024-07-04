#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA313.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA313()
Cadastro de Escala extraordinária
 
@sample	GTPA313()
 
@return	oBrowse	Retorna o Cadastro de Plantões
 
@author	jacomo.fernandes
@since		08/02/18
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA313(cFiltDefault)

Local oBrowse 			:= FWMBrowse():New()	
Default cFiltDefault	:= ""

oBrowse:SetAlias('GQK')
oBrowse:SetMenuDef('GTPA313')

If !Empty(cFiltDefault)
	oBrowse:SetFilterDefault(cFiltDefault)
Endif

oBrowse:SetDescription(STR0009)//"Cadastro de Escalas Extraordinárias"
oBrowse:Activate()

Return ( oBrowse )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Retorna as opções do Menu
 
@author	jacomo.fernandes
@since		08/02/18
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.GTPA313' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.GTPA313' OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.GTPA313' OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.GTPA313' OPERATION 5 ACCESS 0 // Excluir

Return ( aRotina )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample	ModelDef()
 
@return	oModel  Retorna o Modelo de Dados
 
@author	jacomo.fernandes
@since		08/02/18
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local bPosValid	:= {|oModel|TP313TdOK(oModel)}
Local bVldActive:= {|oModel| VldActivate(oModel)}
Local oModel 	:= MPFormModel():New('GTPA313', /*bPreValidacao*/, bPosValid, /*bCommit*/, /*bCancel*/ )
Local oStruGQK	:= FWFormStruct(1,'GQK')

SetModelStruct(oStruGQK)

oModel:AddFields('GQKMASTER',/*cOwner*/,oStruGQK)
oModel:SetDescription(STR0010)	//"Escalas Extraordinárias"
oModel:GetModel('GQKMASTER'):SetDescription(STR0011)	//"Dados da Escala Extraordinária"

oModel:SetVldActivate(bVldActive)
Return ( oModel )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetModelStruct
(long_description)
@type function
@author jacomo.fernandes
@since 08/02/2018
@version 1.0
@param oStruGQK, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function SetModelStruct(oStruGQK)

oStruGQK:AddTrigger("GQK_RECURS", "GQK_DRECUR", { || .T.}, { |oModel| Posicione('GYG',1,xFilial('GYG')+oModel:GetValue('GQK_RECURS'),'GYG_NOME')	})
oStruGQK:AddTrigger("GQK_RECURS", "GQK_FUNCIO", { || .T.}, { |oModel| Posicione('GYG',1,xFilial('GYG')+oModel:GetValue('GQK_RECURS'),'GYG_FUNCIO')	})
oStruGQK:AddTrigger("GQK_TCOLAB", "GQK_DCOLAB", { || .T.}, { |oModel| Posicione('GYK',1,xFilial('GYK')+oModel:GetValue('GQK_TCOLAB'),'GYK_DESCRI')	})
oStruGQK:AddTrigger("GQK_LOCORI", "GQK_DESORI", { || .T.}, { |oModel| Posicione('GI1',1,xFilial('GI1')+oModel:GetValue('GQK_LOCORI'),'GI1_DESCRI')	})
oStruGQK:AddTrigger("GQK_LOCDES", "GQK_DESDES", { || .T.}, { |oModel| Posicione('GI1',1,xFilial('GI1')+oModel:GetValue('GQK_LOCDES'),'GI1_DESCRI')	})
oStruGQK:AddTrigger("GQK_CODGZS", "GQK_DSCGZS", { || .T.}, { |oModel| Posicione('GZS',1,xFilial('GZS')+oModel:GetValue('GQK_CODGZS'),'GZS_DESCRI')	})

oStruGQK:SetProperty("GQK_STATUS"	,MODEL_FIELD_VALUES,{"1=Sim","2=Não"})

oStruGQK:SetProperty("GQK_STATUS"	,MODEL_FIELD_INIT,{||If(FwIsInCallStack('GTPA313'),'1','2')})

If ( FwIsInCallStack("GTPA425") )
	oStruGQK:SetProperty("*", MODEL_FIELD_OBRIGAT, .F. )
Endif

Return 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldActivate
(long_description)
@type function
@author jacomo.fernandes
@since 08/02/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function VldActivate(oModel)
Local lRet	:= .T.
Local nOpc	:= oModel:GetOperation()

If nOpc == MODEL_OPERATION_UPDATE .or. nOpc == MODEL_OPERATION_DELETE 
	If GQK->GQK_MARCAD == "1"
		oModel:SetErrorMessage(oModel:GetId(), , oModel:GetId(), , "VldActivate", 'Não é permitido alterar ou excluir um registro que se encontra enviado para o ponto')
		lRet := .F.
	Endif
Endif

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface
 
@sample	ViewDef()
 
@return	oView  Retorna a View
 
@author	jacomo.fernandes
@since		08/02/18
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= FwLoadModel('GTPA313') 
Local oView		:= FWFormView():New()
Local oStruGQK	:= FWFormStruct(2, 'GQK')

SetViewStruct(oStruGQK)

oView:SetModel(oModel)
 
oView:AddField('VIEW_GQK' ,oStruGQK,'GQKMASTER')

oView:CreateHorizontalBox('TELA', 100)

oView:SetOwnerView('VIEW_GQK','TELA')

oView:SetDescription(STR0010)//"Escalas Extraordinárias"

Return ( oView )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetViewStruct
(long_description)
@type function
@author jacomo.fernandes
@since 08/02/2018
@version 1.0
@param oStruGQK, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function SetViewStruct(oStruGQK)
//Remoção de Campos
oStruGQK:RemoveField("GQK_OCOVIA")
oStruGQK:RemoveField("GQK_ESPHIN")
oStruGQK:RemoveField("GQK_ESPHFM")
oStruGQK:RemoveField("GQK_CODGYQ")

//Sepração dos campos
oStruGQK:AddGroup( "RECURSO", "Recurso", "" , 2 )
oStruGQK:SetProperty("GQK_CODIGO" , MVC_VIEW_GROUP_NUMBER, "RECURSO" )
oStruGQK:SetProperty("GQK_RECURS" , MVC_VIEW_GROUP_NUMBER, "RECURSO" )
oStruGQK:SetProperty("GQK_DRECUR" , MVC_VIEW_GROUP_NUMBER, "RECURSO" )

oStruGQK:AddGroup( "TIPORECURSO"  , "", "" , 1)
oStruGQK:SetProperty("GQK_TCOLAB" , MVC_VIEW_GROUP_NUMBER, "TIPORECURSO" )
oStruGQK:SetProperty("GQK_DCOLAB" , MVC_VIEW_GROUP_NUMBER, "TIPORECURSO" )
oStruGQK:SetProperty("GQK_FUNCIO" , MVC_VIEW_GROUP_NUMBER, "TIPORECURSO" )

oStruGQK:AddGroup( "ALOCACAO", "Alocações", "" , 2 )
oStruGQK:SetProperty("GQK_DTREF"  , MVC_VIEW_GROUP_NUMBER, "ALOCACAO" )
oStruGQK:SetProperty("GQK_TPDIA"  , MVC_VIEW_GROUP_NUMBER, "ALOCACAO" )

oStruGQK:AddGroup( "ALOCAINICIAL"  , "", "" , 1)
oStruGQK:SetProperty("GQK_DTINI"  , MVC_VIEW_GROUP_NUMBER, "ALOCAINICIAL" )
oStruGQK:SetProperty("GQK_HRINI"  , MVC_VIEW_GROUP_NUMBER, "ALOCAINICIAL" )
oStruGQK:SetProperty("GQK_LOCORI" , MVC_VIEW_GROUP_NUMBER, "ALOCAINICIAL" )
oStruGQK:SetProperty("GQK_DESORI" , MVC_VIEW_GROUP_NUMBER, "ALOCAINICIAL" )

oStruGQK:AddGroup( "ALOCAFINAL"  , "", "" , 1)
oStruGQK:SetProperty("GQK_DTFIM"  , MVC_VIEW_GROUP_NUMBER, "ALOCAFINAL" )
oStruGQK:SetProperty("GQK_HRFIM"  , MVC_VIEW_GROUP_NUMBER, "ALOCAFINAL" )
oStruGQK:SetProperty("GQK_LOCDES" , MVC_VIEW_GROUP_NUMBER, "ALOCAFINAL" )
oStruGQK:SetProperty("GQK_DESDES" , MVC_VIEW_GROUP_NUMBER, "ALOCAFINAL" )

oStruGQK:AddGroup( "ALOCDEMAIS"  , "", "" , 1)
oStruGQK:SetProperty("GQK_CODGZS" , MVC_VIEW_GROUP_NUMBER, "ALOCDEMAIS" )
oStruGQK:SetProperty("GQK_DSCGZS" , MVC_VIEW_GROUP_NUMBER, "ALOCDEMAIS" )
If GQK->(FieldPos("GQK_INTERV")) > 0
	oStruGQK:SetProperty("GQK_INTERV" , MVC_VIEW_GROUP_NUMBER, "ALOCDEMAIS" )
EndIf

oStruGQK:AddGroup( "STATUS", "Status", "" , 2 )
oStruGQK:SetProperty("GQK_STATUS" , MVC_VIEW_GROUP_NUMBER, "STATUS" )
oStruGQK:SetProperty("GQK_TPCONF" , MVC_VIEW_GROUP_NUMBER, "STATUS" )
oStruGQK:SetProperty("GQK_CONF"   , MVC_VIEW_GROUP_NUMBER, "STATUS" )
oStruGQK:SetProperty("GQK_MARCAD" , MVC_VIEW_GROUP_NUMBER, "STATUS" )

//Ordenação dos campos
oStruGQK:SetProperty("GQK_CODIGO" 	, MVC_VIEW_ORDEM,'01')
oStruGQK:SetProperty("GQK_RECURS" 	, MVC_VIEW_ORDEM,'02')
oStruGQK:SetProperty("GQK_DRECUR" 	, MVC_VIEW_ORDEM,'03')
oStruGQK:SetProperty("GQK_TCOLAB" 	, MVC_VIEW_ORDEM,'04')
oStruGQK:SetProperty("GQK_DCOLAB" 	, MVC_VIEW_ORDEM,'05')
oStruGQK:SetProperty("GQK_FUNCIO" 	, MVC_VIEW_ORDEM,'06')
oStruGQK:SetProperty("GQK_DTREF"  	, MVC_VIEW_ORDEM,'07')
oStruGQK:SetProperty("GQK_TPDIA"  	, MVC_VIEW_ORDEM,'08')
oStruGQK:SetProperty("GQK_DTINI"  	, MVC_VIEW_ORDEM,'09')
oStruGQK:SetProperty("GQK_HRINI"  	, MVC_VIEW_ORDEM,'10')
oStruGQK:SetProperty("GQK_LOCORI" 	, MVC_VIEW_ORDEM,'11')
oStruGQK:SetProperty("GQK_DESORI" 	, MVC_VIEW_ORDEM,'12')
oStruGQK:SetProperty("GQK_DTFIM"  	, MVC_VIEW_ORDEM,'13')
oStruGQK:SetProperty("GQK_HRFIM"  	, MVC_VIEW_ORDEM,'14')
oStruGQK:SetProperty("GQK_LOCDES" 	, MVC_VIEW_ORDEM,'15')
oStruGQK:SetProperty("GQK_DESDES" 	, MVC_VIEW_ORDEM,'16')
oStruGQK:SetProperty("GQK_CODGZS" 	, MVC_VIEW_ORDEM,'17')
oStruGQK:SetProperty("GQK_DSCGZS" 	, MVC_VIEW_ORDEM,'18')
If GQK->(FieldPos("GQK_INTERV")) > 0
	oStruGQK:SetProperty("GQK_INTERV" 	, MVC_VIEW_ORDEM,'19')
EndIf
oStruGQK:SetProperty("GQK_STATUS" 	, MVC_VIEW_ORDEM,'20')
oStruGQK:SetProperty("GQK_TPCONF" 	, MVC_VIEW_ORDEM,'21')
oStruGQK:SetProperty("GQK_CONF"   	, MVC_VIEW_ORDEM,'22')
oStruGQK:SetProperty("GQK_MARCAD" 	, MVC_VIEW_ORDEM,'23')
oStruGQK:SetProperty("GQK_JUSTIF" 	, MVC_VIEW_ORDEM,'24')
oStruGQK:SetProperty("GQK_USRCON" 	, MVC_VIEW_ORDEM,'25')
oStruGQK:SetProperty("GQK_CODVIA" 	, MVC_VIEW_ORDEM,'26')

oStruGQK:SetProperty("GQK_FUNCIO" 	, MVC_VIEW_CANCHANGE,.F.)
oStruGQK:SetProperty("GQK_STATUS" 	, MVC_VIEW_CANCHANGE,.F.)
oStruGQK:SetProperty("GQK_CONF" 	, MVC_VIEW_CANCHANGE,.F.)
oStruGQK:SetProperty("GQK_MARCAD" 	, MVC_VIEW_CANCHANGE,.F.)
oStruGQK:SetProperty("GQK_USRCON" 	, MVC_VIEW_CANCHANGE,.F.)

oStruGQK:SetProperty("GQK_STATUS"	,MVC_VIEW_COMBOBOX,{"1=Sim","2=Não"})


oStruGQK:SetProperty("GQK_STATUS" 	, MVC_VIEW_TITULO,'Confirmado?')
oStruGQK:SetProperty("GQK_CONF" 	, MVC_VIEW_TITULO,'Apurado?')
oStruGQK:SetProperty("GQK_MARCAD" 	, MVC_VIEW_TITULO,'Enviado?')

Return 

/*/{Protheus.doc} TP313TdOK
(long_description)
@type function
@author henrique.toyada
@since 01/02/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${lRet}, ${Permite a inclusão}
@example
(examples)
@see (links_or_references)
/*/
Static Function TP313TdOK(oModel)

Local lRet 	    := .T.
Local oMdlGQK	:= oModel:GetModel('GQKMASTER')
Local cMsgErro  := ""
Local cRecurso  := oMdlGQK:GetValue('GQK_RECURS')
Local dDtRef	:= oMdlGQK:GetValue('GQK_DTREF' )
Local dDtIni    := oMdlGQK:GetValue('GQK_DTINI' ) 
Local cHrIni    := oMdlGQK:GetValue('GQK_HRINI' ) 
Local dDtFim    := oMdlGQK:GetValue('GQK_DTFIM' ) 
Local cHrFim    := oMdlGQK:GetValue('GQK_HRFIM' )
Local cTpDia    := oMdlGQK:GetValue('GQK_TPDIA' ) 
Local nRecGQK   := oMdlGQK:GetDataId()
Local lVldRh	:= cTpDia <> '5' 

//Ajustar filial para pegar do funcionário na validação
// Validar o tipo de recurso para pegar apenas o colaborador e validar o TIPO DE DIA QUANDO FOR diferente de 4
If oMdlGQK:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlGQK:GetOperation() == MODEL_OPERATION_UPDATE
	If dDtFim < dDtIni
		Help( ,, 'Help',"TP313TdOK", STR0007, 1, 0,,,,,,{STR0008} )
		lRet := .F.		
	Endif	 
	If lRet .and. cTpDia != "4"
		If !Gc300VldAloc(cRecurso,"1",dDtRef,dDtIni,cHrIni,dDtFim,cHrFim,@cMsgErro,lVldRh,nRecGQK,cTpDia)
			Help( ,, 'Help',"TP313TdOK", cMsgErro, 1, 0 )
			lRet := .F.
		Endif
	EndIf
EndIf

Return lRet
