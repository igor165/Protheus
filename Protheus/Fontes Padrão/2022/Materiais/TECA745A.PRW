#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TECA745A.CH'

//Status do orcamento de servicos
#DEFINE DEF_TFJ_ATIVO     "1"			//TFJ_STATUS Contrato Gerado
#DEFINE DEF_TFJ_EMREVISAO "2"			//TFJ_STATUS Em Revisão
#DEFINE DEF_TFJ_REVISADO  "3"			//TFJ_STATUS Revisado
#DEFINE DEF_TFJ_AGDAPROVA "4"			//TFJ_STATUS Aguardando Aprovação
#DEFINE DEF_TFJ_ENCERRADO "5"			//TFJ_STATUS Encerrado
#DEFINE DEF_TFJ_CANCELADO "6"			//TFJ_STATUS Cancelado
#DEFINE DEF_TFJ_INATIVO   "7"			//TFJ_STATUS Inativo

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA745A
@description Browse Orcamento de Reserva Tecnica

@since	21/06/2022
@author	flavio.vicco
/*/
//------------------------------------------------------------------------------
Function TECA745A()

Local oBrowse
Local cFiltro := "TFJ_RESTEC == '2' .AND. EMPTY(TFJ_CODVIS)"

If TFJ->(ColumnPos("TFJ_RESTEC"))>0
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('TFJ')
	oBrowse:SetDescription(STR0001) //'Orçamento de Reserva Tecnica'
	oBrowse:DisableDetails()
	oBrowse:SetFilterDefault(cFiltro)
	oBrowse:Activate()
Else
	Alert(STR0002) //"Atualizar dicionario e rodar UPDDISTR para criar o campo TFJ_RESTEC."
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef
@description Construção do Menu

@since	21/06/2022
@author	flavio.vicco
/*/
//------------------------------------------------------------------------------
Static Function Menudef()
Local aRotina := {}

aRotina := FwMVCMenu('TECA745A')

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@description Definição do modelo de Dados

@since	21/06/2022
@author	flavio.vicco
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel  	:= Nil
Local oStrTFJ 	:= FWFormStruct(1,'TFJ')
Local oStrTFL 	:= FWFormStruct(1,'TFL')
Local oStrTFF 	:= FWFormStruct(1,'TFF')
Local lGSxRH  	:= SuperGetMV("MV_TECXRH",,.F.)

oModel := MPFormModel():New('TECA745A',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)

oModel:AddFields('TFJ_REFER',/*cOwner*/,oStrTFJ,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/,/*bFieldAbp*/)
oModel:SetDescription(STR0001) //'Orçamento de Reserva Tecnica'

oModel:SetPrimaryKey({"TFJ_FILIAL","TFJ_CODIGO"})

oModel:addGrid('TFL_LOC','TFJ_REFER', oStrTFL)

oModel:SetRelation('TFL_LOC', { { 'TFL_FILIAL', 'xFilial("TFJ")' }, { 'TFL_CODPAI', 'TFJ_CODIGO' } }, TFL->(IndexKey(1)) )

oModel:addGrid('TFF_RH','TFL_LOC',oStrTFF)

oModel:SetRelation('TFF_RH', { { 'TFF_FILIAL', 'xFilial("TFF")' }, { 'TFF_CODPAI', 'TFL_CODIGO' }, { 'TFF_LOCAL', 'TFL_LOCAL' } }, TFF->(IndexKey(1)) )

// Campo Tipo 2=Orcamento de Reserva Técnica
oStrTFJ:SetProperty( "TFJ_RESTEC", MODEL_FIELD_INIT, {||"2"})

// Campos Codigo/Loja do Cliente
oStrTFJ:SetProperty( "TFJ_CODENT", MODEL_FIELD_OBRIGAT, .T.)
oStrTFJ:SetProperty( "TFJ_LOJA",   MODEL_FIELD_OBRIGAT, .T.)
oStrTFJ:SetProperty( "TFJ_CODENT", MODEL_FIELD_TITULO , STR0003) //'Cliente'
oStrTFJ:SetProperty( "TFJ_LOJA",   MODEL_FIELD_TITULO , STR0004) //'Loja'
oStrTFJ:SetProperty( "TFJ_CODENT", MODEL_FIELD_NOUPD  , .F.)
oStrTFJ:SetProperty( "TFJ_LOJA",   MODEL_FIELD_NOUPD  , .F.)
oStrTFJ:SetProperty( "TFJ_LOJA",   MODEL_FIELD_VALID  , {|a,b,c,d,e| FWInitCpo(a,b,c,d),lRet := At745VlCli(a),FWCloseCpo(a,b,c,lRet,.T.),lRet})

// Campos obrigatorios
oStrTFJ:SetProperty( "TFJ_CONDPG", MODEL_FIELD_OBRIGAT, .F.)
oStrTFJ:SetProperty( "TFJ_DTPLRV", MODEL_FIELD_OBRIGAT, .F.)
oStrTFJ:SetProperty( "TFJ_GRPRH" , MODEL_FIELD_OBRIGAT, .F.)
oStrTFJ:SetProperty( "TFJ_GRPMI" , MODEL_FIELD_OBRIGAT, .F.)
oStrTFJ:SetProperty( "TFJ_GRPMC" , MODEL_FIELD_OBRIGAT, .F.)
oStrTFJ:SetProperty( "TFJ_GRPLE" , MODEL_FIELD_OBRIGAT, .F.)
oStrTFJ:SetProperty( "TFJ_DSCLE" , MODEL_FIELD_OBRIGAT, .F.)
oStrTFJ:SetProperty( "TFJ_TES"   , MODEL_FIELD_OBRIGAT, .F.)
oStrTFJ:SetProperty( "TFJ_TESMI" , MODEL_FIELD_OBRIGAT, .F.)
oStrTFJ:SetProperty( "TFJ_TESMC" , MODEL_FIELD_OBRIGAT, .F.)
oStrTFJ:SetProperty( "TFJ_TESLE" , MODEL_FIELD_OBRIGAT, .F.)
oStrTFL:SetProperty( "TFL_CODPAI", MODEL_FIELD_OBRIGAT, .F.)
oStrTFF:SetProperty( "TFF_CODPAI", MODEL_FIELD_OBRIGAT, .F.)
oStrTFF:SetProperty( "TFF_LOCAL" , MODEL_FIELD_OBRIGAT, .F.)
oStrTFF:SetProperty( "TFF_QTDVEN", MODEL_FIELD_OBRIGAT, .F.)
oStrTFF:SetProperty( "TFF_PRCVEN", MODEL_FIELD_OBRIGAT, .F.)
oStrTFF:SetProperty( "TFF_COD"   , MODEL_FIELD_OBRIGAT, .T.)
oStrTFF:SetProperty( "TFF_FUNCAO", MODEL_FIELD_OBRIGAT, lGSxRH)
oStrTFF:SetProperty( "TFF_ESCALA", MODEL_FIELD_OBRIGAT, .T.)
oStrTFF:SetProperty( "TFF_TURNO", MODEL_FIELD_OBRIGAT, .F.)

// Campos Descricao
oStrTFL:SetProperty("TFL_DESLOC",MODEL_FIELD_INIT,{||If(!INCLUI,(Posicione("ABS",1,xFilial("ABS")+TFL->TFL_LOCAL, "ABS_DESCRI")),"")})
oStrTFL:SetProperty("TFL_ESTADO",MODEL_FIELD_INIT,{||If(!INCLUI,(Posicione("ABS",1,xFilial("ABS")+TFL->TFL_LOCAL, "ABS_ESTADO")),"")})
oStrTFL:SetProperty("TFL_MUNIC" ,MODEL_FIELD_INIT,{||If(!INCLUI,(Posicione("ABS",1,xFilial("ABS")+TFL->TFL_LOCAL, "ABS_MUNIC" )),"")})
oStrTFF:SetProperty("TFF_DESCRI",MODEL_FIELD_INIT,{||If(!INCLUI,(Posicione("SB1",1,xFilial("SB1")+TFF->TFF_PRODUT,"B1_DESC"   )),"")})
oStrTFF:SetProperty("TFF_NOMESC",MODEL_FIELD_INIT,{||If(!INCLUI,(Posicione("TDW",1,xFilial("TDW")+TFF->TFF_ESCALA,"TDW_DESC"  )),"")})
oStrTFF:SetProperty("TFF_DTURNO",MODEL_FIELD_INIT,{||If(!INCLUI,(Posicione("SR6",1,xFilial("SRJ")+TFF->TFF_TURNO, "R6_DESC"   )),"")})

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@description Definição da interface

@since	21/06/2022
@author	flavio.vicco
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel        := ModelDef()
Local oView         := NIL
Local oStrTFJ       := NIL
Local oStrTFL       := NIL
Local oStrTFF       := NIL

oStrTFJ  := FWFormStruct(2, 'TFJ', {|cCpo| At745ASelFields( 'TFJ', Alltrim(cCpo) ) } )
oStrTFL  := FWFormStruct(2, 'TFL', {|cCpo| At745ASelFields( 'TFL', Alltrim(cCpo) ) } )
oStrTFF  := FWFormStruct(2, 'TFF', {|cCpo| At745ASelFields( 'TFF', Alltrim(cCpo) ) } )

oView:= FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_REFER', oStrTFJ, 'TFJ_REFER')
oView:AddGrid('VIEW_LOC'   , oStrTFL, 'TFL_LOC')
oView:AddGrid('VIEW_RH'    , oStrTFF, 'TFF_RH')

// Adiciona as visões na tela
oView:CreateHorizontalBox( 'TOP'   , 30 )
oView:CreateHorizontalBox( 'MIDDLE', 70 )

// Define as abas
oView:CreateFolder( 'ABAS', 'MIDDLE')
oView:AddSheet('ABAS','ABA01',STR0005) //"Locais de Atendimento"
oView:AddSheet('ABAS','ABA02',STR0006) //"Recursos Humanos"

// Cria as abas e sheet para incluir
oView:CreateHorizontalBox( 'ID_ABA01' , 100,,, 'ABAS', 'ABA01' ) // Define a área de Locais
oView:CreateHorizontalBox( 'ID_ABA02' , 100,,, 'ABAS', 'ABA02' ) // Define a área de RH

// Faz a amarração das VIEWs dos modelos com as divisões na interface
oView:SetOwnerView('VIEW_REFER'	,'TOP')			// Cabeçalho
oView:SetOwnerView('VIEW_LOC'	,'ID_ABA01')	// Grid Locais
oView:SetOwnerView('VIEW_RH'	,'ID_ABA02')	// Grid RH

// Campo item/contador
oView:AddIncrementField('VIEW_RH' , 'TFF_ITEM' )

// Campos Codigo/Loja Cliente
oStrTFJ:SetProperty( "TFJ_CODENT", MVC_VIEW_LOOKUP    , 'SA1' )
oStrTFJ:SetProperty( "TFJ_CODENT", MVC_VIEW_CANCHANGE , .T. )
oStrTFJ:SetProperty( "TFJ_LOJA"  , MVC_VIEW_CANCHANGE , .T. )
oStrTFJ:SetProperty( "TFJ_CODENT", MVC_VIEW_TITULO    , STR0003 ) //'Cliente'
oStrTFJ:SetProperty( "TFJ_LOJA"  , MVC_VIEW_TITULO    , STR0004 ) //'Loja'

oStrTFJ:RemoveField("TFJ_RESTEC")

oView:SetCloseOnOk({|| .T.} )

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados
@description Bloco de código executado no activate

@since	21/06/2022
@author	flavio.vicco
/*/
//------------------------------------------------------------------------------
Static Function InitDados( oModel )

If oModel:GetOperation() == MODEL_OPERATION_INSERT
	oModel:GetModel("TFJ_REFER"):SetValue( "TFJ_ENTIDA", "1" )
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At745ASelFields
@description Filtra os campos de controle da rotina para não serem exibidos na view

@param   	cTab, Caracter, Código da tabela a ter o campo avaliado
@param   	cCpoAval, Caracter, Código do campo a ser avaliado
@return 	lRet, Logico, define se o campo deve ser apresentado na view
@since	21/06/2022
@author	flavio.vicco
/*/
//------------------------------------------------------------------------------
Function At745ASelFields( cTab, cCpoAval )

Local lRet := .T.

If !Empty( cTab ) .And. !Empty( cCpoAval )
	If cTab == 'TFJ'
		lRet := !( cCpoAval $ 'TFJ_PROPOS#TFJ_PREVIS#TFJ_ENTIDA#TFJ_ITEMRH#TFJ_ITEMMI#TFJ_ITEMMI#TFJ_DESCON#TFJ_DSGCN#TFJ_ORCSIM#TFJ_CODTAB#TFJ_TABREV#'+;
		'TFJ_GRPRH#TFJ_GRPMI#TFJ_GRPMC#TFJ_GRPLE#TFJ_DSCRH#TFJ_DSCMI#TFJ_DSCMC#TFJ_DSCLE#TFJ_TES#TFJ_TESMI#TFJ_TESMC#TFJ_TESLE#'+;
		'TFJ_TOTRH#TFJ_TOTMI#TFJ_TOTMC#TFJ_TOTLE#TFJ_LUCRO#TFJ_ADM#TFJ_GESMAT#TFJ_TPFRET#TFJ_CLIPED#TFJ_GRPCOM#TFJ_ANTECI#TFJ_CNTREC#'+;
		'TFJ_CONDPG#TFJ_DATA#TFJ_AGRUP#TFJ_TIPREV#TFJ_RGMCX#TFJ_VEND#TFJ_DTPLRV#TFJ_CODREL#TFJ_PRDRET#TFJ_APRVOP#TFJ_USAPRO#TFJ_DTAPRO')
		lRet := lRet .And. !( cCpoAval $ 'TFJ_ITEMMC#TFJ_ITEMLE#TFJ_CONTRT#TFJ_CONREV#TFJ_STATUS#TFJ_TOTRH#TFJ_TOTMI#TFJ_TOTMC#TFJ_TOTLE#TFJ_CODVIS#TFJ_TABXML' )
	ElseIf cTab == 'TFL'
		lRet := !( cCpoAval $ 'TFL_CODIGO#TFL_CODPAI#TFL_CONTRT#TFL_CONREV#TFL_CODSUB#TFL_MESRH#TFL_MESMI#TFL_MESMC#'+;
		'TFL_TOTRH#TFL_TOTMI#TFL_TOTMC#TFL_TOTLE#TFL_TOTAL#TFL_ITPLRH#TFL_ITPLMI#TFL_ITPLMC#TFL_ITPLLE#TFL_ENCE'+;
		'TFL_PLAN#TFJ_ITPLRH#TFL_PEDTIT#TFL_OBS#TFL_TOTIMP#TFL_ATCC#TFL_VLPRPA#TFL_MODPLA#TFL_CODREL#TFL_DTENCE#')
		lRet := lRet .And. !( cCpoAval $ '' )
	ElseIf cTab == 'TFF'
		lRet := !( cCpoAval $ 'TFF_LOCAL#TFF_CODPAI#TFF_CONTRT#TFF_CONREV#TFF_CODSUB#TFF_CHVTWO#TFF_ENCE#TFF_PROCES#TFF_ITCNB#TFF_TABXML#TFF_ITEXOP#'+;
		'TFF_TOTMI#TFF_TOTMC#TFF_TOTMES#TFF_TOTAL#TFF_TESPED#TFF_UM#TFF_QTDVEN#TFF_PRCVEN#TFF_SUBTOT#TFF_DFUNC#TFF_CARGO#TFF_DCARGO#'+;
		'TFF_DESCON#TFF_CALEND#TFF_DSCALE#TFF_VALDES#TFF_CALCMD#TFF_LUCRO#TFF_TXLUCR#TFF_ADM#TFF_TXADM#TFF_COBCTR#TFF_NARMA#TFF_NCOLE#TFF_PERMAT#TFF_VLRMAT#'+;
		'TFF_INSALU#TFF_GRAUIN#TFF_PERICU#TFF_PLACOD#TFF_PLAREV#TFF_TESPED#TFF_DPLAN#TFF_QTDHRS#TFF_HRSSAL#TFF_VLPRPA#TFF_CODREL#TFF_DTENCE#TFF_GERVAG#TFF_MODPLA#TFF_PRDRET#')
	Else
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At745VlCli
@description Valida Cod/Loja do cliente

@since	21/06/2022
@author	flavio.vicco
/*/
//------------------------------------------------------------------------------
Function At745VlCli(oModel)
Local lRet := .F.
Local aArea := GetArea()

SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD
lRet := SA1->(DbSeek(xFilial("SA1")+oModel:GetValue('TFJ_CODENT')+oModel:GetValue('TFJ_LOJA')))

RestArea(aArea)
Return lRet
