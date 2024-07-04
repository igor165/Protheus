#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA444.CH"
#INCLUDE "TAFA444DEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA444

Cadastro de Período de Apuração.

@Author	David Costa
@Since		05/07/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFA444()
 
Local oBrw	as object

oBrw	:=	FWmBrowse():New()

If TAFAlsInDic( "CWV" )
	oBrw:SetDescription( STR0001 ) //"Cadastro do Período de Apuração"
	oBrw:SetAlias( "CWV" )
	oBrw:SetMenuDef( "TAFA444" )
	oBrw:SetCacheView( .F. )

	CWV->( DBSetOrder( 1 ) )

	oBrw:Activate()
Else
	Aviso( STR0022, TafAmbInvMsg(), { STR0023 }, 2 ) //##"Dicionário Incompatível" ##"Encerrar"
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Função genérica MVC com as opções de menu.

@Author		David Costa
@Since		05/07/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao	as array
Local aRotina	as array

aFuncao	:=	{}
aRotina	:=	{}

aAdd( aFuncao, { STR0020, "TAF444Pre( 'Encerrar Período', 'TAFA444Enc' )" } ) //"Encerrar Período"
aAdd( aFuncao, { STR0071, "TAF444Pre( 'Gerar Lançamentos da Parte B do LALUR', 'TAFA444PaB' )" } ) //"Gerar Lançamentos da Parte B do LALUR"
aAdd( aFuncao, { STR0076, "TAF444Pre( 'Reabertura do Período', 'TAF444Open' )" } ) //"Reabertura do Período"
aAdd( aFuncao, { STR0054, "TAF444Pre( 'Gerar Documento de Arrecadação', 'TAFA444DA' )" } ) //"Gerar Documento de Arrecadação"
aAdd( aFuncao, { STR0096, "TAF444Pre( 'Estornar Documento de Arrecadação', 'TAFA444EDA' )" } ) //"Estornar Documento de Arrecadação"
aAdd( aFuncao, { STR0138, "TAF444Pre( 'Enviar para ECF', 'TAFA444ECF' )" } ) //"Enviar para ECF"
aAdd( aFuncao, { STR0156, "TAF444Pre( 'Relatório LALUR Parte A Estimativa por Balanço', 'TAFA444REL' )" } ) //"Relatório LALUR Parte A Estimativa por Balanço"
aAdd( aFuncao, { STR0160, "TAF444Pre( 'Relatório LALUR Parte B Estimativa por Balanço', 'TAFA444REB' )" } ) //"Relatório LALUR Parte B Estimativa por Balanço"
aAdd( aFuncao, { STR0170, "TAF444Pre( 'Incluir Período em Lote', 'TAFA444Add' )" } ) //"Incluir Período em Lote"
aAdd( aFuncao, { STR0171, "TAF444Pre( 'Encerrar Período em Lote', 'TAF444ELTE' )" } ) //"Encerrar Período em Lote"
aAdd( aFuncao, { STR0172, "TAF444Pre( 'Reabrir Período em Lote', 'TAFA444ALTE' )" } ) //"Reabrir Período em Lote"

aRotina := xFunMnuTAF( "TAFA444",, aFuncao )

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF444Pre

Executa pré-condições para a operação desejada.

@Param		cOper	-	Indica a operação a ser executada
			cRotina	-	Indica a rotina a ser executada

@Author		Felipe C. Seolin
@Since		28/03/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF444Pre( cOper, cRotina )

Local nOperation as numeric
Local lAutomato  as logical

Default cRotina		:=	"TAFA444"

nOperation	:=	MODEL_OPERATION_VIEW

//De-Para de opções do Menu para a operações em MVC
If Upper( cOper ) $ Upper( "|Encerrar Período|Gerar Lançamentos da Parte B do LALUR|Reabertura do Período|Gerar Documento de Arrecadação|Estornar Documento de Arrecadação|Enviar para ECF|" )
	nOperation := 0
EndIf
lAutomato := IsBlind()
/*
C1O_NATURE	--> Dicionário do Plano de Contas
T0T_IDDETA	--> Dicionário do Encerramento
CWX_RURAL	--> Dicionario do Detalhamento
C0R_VLPAGO	--> Cadastro de Guias
*/
If TAFColumnPos( "C1O_NATURE" ) .and. TAFColumnPos( "CWX_RURAL" ) .and.;
	TAFColumnPos( "T0T_IDDETA" ) .and. TAFColumnPos( "C0R_VLPAGO" )
	If Upper( cOper ) $ ( Upper( "|Encerrar Período|Gerar Lançamentos da Parte B do LALUR|Reabertura do Período|" ) )
		&cRotina.(lAutomato)
	ElseIf Upper( cOper ) $ ( Upper( "|Gerar Documento de Arrecadação|Estornar Documento de Arrecadação|" ) )
		If TAFAlsInDic( "T50" )
			&cRotina.(lAutomato)
		Else
			MsgInfo( TafAmbInvMsg() )
		EndIf
	ElseIf Upper( cOper ) $ ( Upper( "|Enviar para ECF|" ) )
		If TAFColumnPos( "CHR_ORIGEM" )
			&cRotina.()
		Else
			MsgInfo( TafAmbInvMsg() )
		EndIf
	Else
		&cRotina.(lAutomato)
	EndIf
Else
	MsgInfo( TafAmbInvMsg() )
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Função genérica MVC do Model.

@Return	oModel	- Objeto do modelo MVC

@Author	David Costa
@Since		05/07/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCWV	as object
Local oStruCWX	as object
Local oStruT50	as object
Local oModel	as object

oStruCWV	:=	FWFormStruct( 1, "CWV" )
oStruCWX	:=	FWFormStruct( 1, "CWX" )
oStruT50	:=	FWFormStruct( 1, "T50" )
oModel		:=	MPFormModel():New( "TAFA444",, { |oModel| TAF444VldMdl( oModel ) }, { |oModel| SaveModel( oModel ) } )

//O Status deverá iniciar sempre como "1 - Aberto"
oStruCWV:SetProperty( "CWV_STATUS", MODEL_FIELD_INIT, { |oModel| PERIODO_ABERTO } )

//O Tributo não poderá ser alterado
oStruCWV:SetProperty( "CWV_CODTRI", MODEL_FIELD_WHEN, { || .F. } )

oStruCWX:SetProperty( "*", MODEL_FIELD_WHEN, { || .T. } )

//Inicia com o Tributo selecionado pelo usuário
oStruCWV:SetProperty( "CWV_IDTRIB", MODEL_FIELD_INIT, { |oModel| xFunCh2ID( MV_PAR01, "T0J", 2 ) } )

//Se o Período estiver encerrado, nenhum campo poderá ser editado
If CWV->CWV_STATUS == PERIODO_ENCERRADO .and. ALTERA
	oStruCWV:SetProperty( "*", MODEL_FIELD_WHEN, { || .F. } )
	oStruCWX:SetProperty( "*", MODEL_FIELD_WHEN, { || .F. } )
EndIf

oModel:AddFields( "MODEL_CWV", /*cOwner*/, oStruCWV )
oModel:GetModel( "MODEL_CWV" ):SetPrimaryKey( { "CWV_INIPER", "CWV_FIMPER", "CWV_IDTRIB", "CWV_DESCRI" } )

If TAFAlsInDic( "CWX" )
	oModel:AddGrid( "MODEL_CWX", "MODEL_CWV", oStruCWX )
	oModel:GetModel( "MODEL_CWX" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_CWX" ):SetUniqueLine( { "CWX_SEQDET" } )
	oModel:SetRelation( "MODEL_CWX", { { "CWX_FILIAL", "xFilial( 'CWX' )" }, { "CWX_ID", "CWV_ID" } }, CWX->( IndexKey( 1 ) ) )
EndIf

If TAFAlsInDic( "T50" )
	oModel:AddGrid( "MODEL_T50", "MODEL_CWV", oStruT50 )
	oModel:GetModel( "MODEL_T50" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_T50" ):SetUniqueLine( { "T50_IDGUIA" } )
	oModel:SetRelation( "MODEL_T50",{ { "T50_FILIAL", "xFilial( 'T50' )" }, { "T50_ID", "CWV_ID" } }, T50->( IndexKey( 1 ) ) )
EndIf

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Função genérica MVC da View.

@Return	oView	- Objeto da view MVC

@Author	David Costa
@Since		05/07/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		as object
Local oView		as object
Local cTpTributo	as character

oModel		:=	FWLoadModel( "TAFA444" )
oView		:=	FWFormView():New()
cTpTributo	:=	SelecTrib()

oView:SetModel( oModel )

oView:CreateHorizontalBox( "PAINEL_ABAS", 100 )
oView:CreateFolder( "FOLDER_GERAL", "PAINEL_ABAS" )

AbaIdentif( @oView, cTpTributo )

If CWV->CWV_STATUS == PERIODO_ENCERRADO .and. !INCLUI
	AbaApuraca( @oView, cTpTributo )

	If TAFAlsInDic( "CWX" )
		AbaDetalha( @oView, cTpTributo )
	EndIf
EndIf

If TAFAlsInDic( "T50" )
	AbaGuias( @oView )
EndIf

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} AbaIdentif

Adiciona a aba Identificação do Cadastro do Período de Apuração.

@Param	oView		- Objeto da view MVC
		cTpTributo	- Código do Tipo do Tributo selecionado

@Author	David Costa
@Since		05/07/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function AbaIdentif( oView, cTpTributo )

Local oStruIdent	as object
Local cCmpIdenti	as character

oStruIdent	:=	Nil
cCmpIdenti	:=	"CWV_INIPER|CWV_FIMPER|CWV_STATUS|CWV_DESCRI|CWV_CODTRI|CWV_DTRIBU|CWV_ALIQAP|"

If cTpTributo == TIPO_TRIBUTO_IRPJ
	cCmpIdenti += "CWV_ANUAL|CWV_ALIQAD|CWV_VLISEN|CWV_PERADI|CWV_ALIQU1|CWV_ALIQU2|CWV_ALIQU3|CWV_ALIQU4|"
ElseIf cTpTributo == TIPO_TRIBUTO_CSLL
	cCmpIdenti += "CWV_ANUAL|CWV_PERADI|CWV_ALIQU1|CWV_ALIQU2|CWV_ALIQU3|CWV_ALIQU4|"
EndIf

If TAFColumnPos( "CWV_POEB" )
	cCmpIdenti += "CWV_POEB|"
EndIf

oStruIdent := FWFormStruct( 2, "CWV", { |x| AllTrim( x ) + "|" $ cCmpIdenti } )

If "CWV_ANUAL" $ cCmpIdenti
	oStruIdent:SetProperty( "CWV_ANUAL", MVC_VIEW_ORDEM, "01" )
EndIf

//Grupo Identificação
oStruIdent:AddGroup( "GRP_IDENTIFICACAO", STR0003, "", 2 ) //"Identificação"

oStruIdent:SetProperty( "CWV_INIPER", MVC_VIEW_GROUP_NUMBER, "GRP_IDENTIFICACAO" )
oStruIdent:SetProperty( "CWV_FIMPER", MVC_VIEW_GROUP_NUMBER, "GRP_IDENTIFICACAO" )
oStruIdent:SetProperty( "CWV_STATUS", MVC_VIEW_GROUP_NUMBER, "GRP_IDENTIFICACAO" )
oStruIdent:SetProperty( "CWV_DESCRI", MVC_VIEW_GROUP_NUMBER, "GRP_IDENTIFICACAO" )
oStruIdent:SetProperty( "CWV_CODTRI", MVC_VIEW_GROUP_NUMBER, "GRP_IDENTIFICACAO" )
oStruIdent:SetProperty( "CWV_DTRIBU", MVC_VIEW_GROUP_NUMBER, "GRP_IDENTIFICACAO" )

If TAFColumnPos( "CWV_POEB" )
	oStruIdent:SetProperty( "CWV_POEB", MVC_VIEW_GROUP_NUMBER, "GRP_IDENTIFICACAO" )
EndIf

If cTpTributo == TIPO_TRIBUTO_IRPJ .or. cTpTributo == TIPO_TRIBUTO_CSLL
	oStruIdent:SetProperty( "CWV_ANUAL", MVC_VIEW_GROUP_NUMBER, "GRP_IDENTIFICACAO" )
EndIf

//Grupo Defaults do Tributo
oStruIdent:AddGroup( "GRP_DEFAULT_TRIBUTOS", STR0005, "", 2 ) //"Defaults do Tributo"

oStruIdent:SetProperty( "CWV_ALIQAP", MVC_VIEW_GROUP_NUMBER, "GRP_DEFAULT_TRIBUTOS" )

If cTpTributo == TIPO_TRIBUTO_IRPJ .or. cTpTributo == TIPO_TRIBUTO_CSLL
	oStruIdent:SetProperty( "CWV_PERADI", MVC_VIEW_GROUP_NUMBER, "GRP_DEFAULT_TRIBUTOS" )

	If cTpTributo == TIPO_TRIBUTO_IRPJ
		oStruIdent:SetProperty( "CWV_ALIQAD", MVC_VIEW_GROUP_NUMBER, "GRP_DEFAULT_TRIBUTOS" )
		oStruIdent:SetProperty( "CWV_VLISEN", MVC_VIEW_GROUP_NUMBER, "GRP_DEFAULT_TRIBUTOS" )
	EndIf

	//Grupo Alíquotas por Atividade
	oStruIdent:AddGroup( "GRP_ALIQUOTAS_ATIVIDADES", STR0006, "", 2 ) //"Alíquotas por Atividade"

	oStruIdent:SetProperty( "CWV_ALIQU1", MVC_VIEW_GROUP_NUMBER, "GRP_ALIQUOTAS_ATIVIDADES" )
	oStruIdent:SetProperty( "CWV_ALIQU2", MVC_VIEW_GROUP_NUMBER, "GRP_ALIQUOTAS_ATIVIDADES" )
	oStruIdent:SetProperty( "CWV_ALIQU3", MVC_VIEW_GROUP_NUMBER, "GRP_ALIQUOTAS_ATIVIDADES" )
	oStruIdent:SetProperty( "CWV_ALIQU4", MVC_VIEW_GROUP_NUMBER, "GRP_ALIQUOTAS_ATIVIDADES" )
EndIf

oView:AddField( "VIEW_CWV_IDENTIFICACAO", oStruIdent, "MODEL_CWV" )
oView:AddSheet( "FOLDER_GERAL", "ABA_IDENTIFICACAO", STR0003 ) //"Identificação"

oView:CreateHorizontalBox( "PAINEL_ABA_IDENTIFICACAO", 100,,, "FOLDER_GERAL", "ABA_IDENTIFICACAO" )

oView:SetOwnerView( "VIEW_CWV_IDENTIFICACAO", "PAINEL_ABA_IDENTIFICACAO" )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AbaApuraca

Adiciona a aba Apuração do Cadastro do Período de Apuração.

@Param	oView		- Objeto da view MVC
		cTpTributo	- Código do Tipo do Tributo selecionado

@Author	David Costa
@Since		05/07/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function AbaApuraca( oView, cTpTributo )

Local oStruTribu	as object
Local cCmpTribut	as character
Local cFormaTrib	as character

oStruTribu	:= Nil
cCmpTribut	:=	""
cFormaTrib	:=	""

If cTpTributo == TIPO_TRIBUTO_IRPJ .or. cTpTributo == TIPO_TRIBUTO_CSLL
	DBSelectArea( "T0N" )
	T0N->( DBSetOrder( 1 ) )
	If T0N->( MsSeek( xFilial( "T0N" ) + CWV->CWV_IDEVEN ) )
		cFormaTrib := xFunID2Cd( T0N->T0N_IDFTRI, "T0K", 1 )
	EndIf

	cCmpTribut := "CWV_APAGAR|CWV_CODEVE|CWV_DEVENT|"
EndIf

If !Empty( cCmpTribut )
	oStruTribu := FWFormStruct( 2, "CWV", { |x| AllTrim( x ) + "|" $ cCmpTribut } )

	oView:AddField( "VIEW_CWV_APURACAO", oStruTribu, "MODEL_CWV" )
	oView:EnableTitleView( "VIEW_CWV_APURACAO", STR0004 ) //"Apuração"

	oView:AddSheet( "FOLDER_GERAL", "ABA_APURACAO", STR0004 ) //"Apuração"
	oView:CreateHorizontalBox( "PAINEL_ABA_APURACAO", 100,,, "FOLDER_GERAL", "ABA_APURACAO" )

	oView:SetOwnerView( "VIEW_CWV_APURACAO", "PAINEL_ABA_APURACAO" )
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AbaDetalha

Adiciona a aba Detalhamento do Cadastro do Período de Apuração.

@Param	oView		- Objeto da view MVC
		cTpTributo	- Código do Tipo do Tributo selecionado

@Author	David Costa
@Since		27/07/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function AbaDetalha( oView, cTpTributo )

Local oStruDetal	as object
Local cCmpDetalh	as character

oStruDetal	:=	Nil
cCmpDetalh	:=	""

If cTpTributo == TIPO_TRIBUTO_IRPJ .or. cTpTributo == TIPO_TRIBUTO_CSLL
	cCmpDetalh := "CWX_SEQDET|CWX_ORIGEM|CWX_CODGRU|CWX_DCODGR|CWX_VALOR|CWX_TABECF|CWX_RURAL|"
	oStruDetal := FWFormStruct( 2, "CWX", { |x| AllTrim( x ) + "|" $ cCmpDetalh } )

	oView:AddGrid( "VIEW_CWX_DETALHAMENTO", oStruDetal, "MODEL_CWX" )
	oView:EnableTitleView( "VIEW_CWX_DETALHAMENTO", STR0018 ) //"Detalhamento"

	oView:AddSheet( "FOLDER_GERAL", "ABA_DETALHAMENTO", STR0018 ) //"Detalhamento"
	oView:CreateHorizontalBox( "PAINEL_ABA_DETALHAMENTO", 100,,, "FOLDER_GERAL", "ABA_DETALHAMENTO" )

	oView:SetOwnerView( "VIEW_CWX_DETALHAMENTO", "PAINEL_ABA_DETALHAMENTO" )
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AbaGuias

Monta a Aba Guias do Cadastro de Período de Apuração

@Param		oView	- Objeto da view MVC

@Author		Felipe C. Seolin
@Since		19/09/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function AbaGuias( oView )

Local oStruT50	as object

oStruT50	:=	FWFormStruct( 2, "T50" )

oView:AddGrid( "VIEW_T50", oStruT50, "MODEL_T50" )
oView:EnableTitleView( "VIEW_T50", STR0025 ) //"Guias"

oView:AddSheet( "FOLDER_GERAL", "ABA_GUIAS", STR0025 ) //"Guias"
oView:CreateHorizontalBox( "PAINEL_ABA_GUIAS", 100,,, "FOLDER_GERAL", "ABA_GUIAS" )

oView:SetOwnerView( "VIEW_T50", "PAINEL_ABA_GUIAS" )

oView:AddUserButton( STR0026, "", { |oModel| TAF444Bxa( oModel ) } ) //"Baixa/Estorno"

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF444Init

Função para atribuição da propriedade de inicialização padrão do campo.

@Return		cInit	- Conteúdo da inicialização padrão do campo

@Author		Felipe C. Seolin
@Since		19/09/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF444Init()

Local cCampo	as character
Local cInit		as character

cCampo	:=	SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
cInit	:=	""

If cCampo == "T50_DIDGUI"
	cInit := Posicione( "C0R", 6, xFilial( "C0R" ) + T50->T50_IDGUIA, "C0R->( AllTrim( C0R_NUMDA ) + ' - ' + AllTrim( C0R_DESDOC ) )" )

ElseIf cCampo == "CWX_TABECF"

	If Empty( CWX->CWX_IDECF )
		cInit := SubStr( Posicione( "CH8", 1, xFilial( "CH8" ) + CWX->CWX_IDLAL, "ALLTRIM( CH8_CODIGO ) + ' - ' + CH8_DESCRI", "" ), 1, 150 )
	Else
		cInit := SubStr( Posicione( "CH6", 1, xFilial( "CH6" ) + CWX->CWX_IDECF, "ALLTRIM( CH6_CODIGO ) + ' - ' + CH6_DESCRI", "" ), 1, 150 )
	EndIf

EndIf

If !Empty( cInit ) .and. AllTrim( cInit ) == "-"
	cInit := ""
EndIf

Return( cInit )

//-------------------------------------------------------------------
/*/{Protheus.doc} SelecTrib

Seleciona o Tipo do Tributo do cadastro.

@Return	cTpTributo	- Código do Tipo do Tributo selecionado

@Author	David Costa
@Since		05/07/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function SelecTrib()

Local cTpTributo	as character
Local aButtons	as array

cTpTributo	:=	""
aButtons	:=	{}

If Type( "INCLUI" ) <> "U" .and. INCLUI .and. AllTrim( FunName() ) == "TAFA444"
	aAdd( aButtons, { 1, .T., { |o| nOpca := 1, o:oWnd:End() } } )

	PergTAF( "TAFA444", STR0024, { STR0002 }, aButtons, { || .T. } ) //##"Parâmetros..." ##"Tributo"

	DBSelectArea( "T0J" )
	T0J->( DBSetOrder( 2 ) )
	If T0J->( MsSeek( xFilial( "T0J" ) + MV_PAR01 ) )
		cTpTributo := T0J->T0J_TPTRIB
	EndIf
Else
	DBSelectArea( "T0J" )
	T0J->( DBSetOrder( 1 ) )
	If T0J->( MsSeek( xFilial( "T0J" ) + CWV->CWV_IDTRIB ) )
		cTpTributo := T0J->T0J_TPTRIB
	EndIf
EndIf

Return( cTpTributo )

//-------------------------------------------------------------------
/*/{Protheus.doc} DefaultPer

Carrega os defaults do cadastro do Período de Apuração.

@Return	xRet	- Valor default do campo

@Author	David Costa
@Since		05/07/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function DefaultPer()

Local cCmp	as character
Local xRet

cCmp	:=	ReadVar()
xRet	:=	CWV->( &( AllTrim( SubStr( cCmp, 4 ) ) ) )

If Type( "INCLUI" ) <> "U" .and. INCLUI
	DBSelectArea( "T0J" )
	T0J->( DBSetOrder( 1 ) )
	If T0J->( MsSeek( xFilial( "T0J" ) + FWFldGet( "CWV_IDTRIB" ) ) )
		If AllTrim( SubStr( cCmp, 4 ) ) $ "CWV_ALIQAP"
			xRet := T0J->T0J_VLALIQ
		EndIf

		If T0J->T0J_TPTRIB == TIPO_TRIBUTO_IRPJ .or. T0J->T0J_TPTRIB == TIPO_TRIBUTO_CSLL
			If AllTrim( SubStr( cCmp, 4 ) ) $ "CWV_ALIQAD" .and. T0J->T0J_TPTRIB == TIPO_TRIBUTO_IRPJ
				xRet := T0J->T0J_ALADIR
			ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "CWV_VLISEN" .and. T0J->T0J_TPTRIB == TIPO_TRIBUTO_IRPJ
				xRet := T0J->T0J_PARCIS
			ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "CWV_PERADI"
				xRet := T0J->T0J_PERCAD
			ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "CWV_ALIQU1"
				xRet := T0J->T0J_ALIQL1
			ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "CWV_ALIQU2"
				xRet := T0J->T0J_ALIQL2
			ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "CWV_ALIQU3"
				xRet := T0J->T0J_ALIQL3
			ElseIf AllTrim( SubStr( cCmp, 4 ) ) $ "CWV_ALIQU4"
				xRet := T0J->T0J_ALIQL4
			EndIf
		EndIf
	EndIf
EndIf

Return( xRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCmpApur

Função utilizada para consistir os campos do Período de Apuração.

@Return	lRet	- Retorna se o campo está válido

@Author	David Costa
@Since		14/07/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function VldCmpApur()

Local cCmp			as character
Local cLogValid	as character
Local lRet			as logical
Local lPerAnual	as logical
Local xValueCmp

cCmp		:=	ReadVar()
cLogValid	:=	""
lRet		:=	.T.
lPerAnual	:=	.F.
xValueCmp	:=	Nil

//Verifica o Tributo selecionado
DBSelectArea( "T0J" )
T0J->( DBSetOrder( 1 ) )
If T0J->( MsSeek( xFilial( "T0J" ) + FWFldGet( "CWV_IDTRIB" ) ) )
	lPerAnual := T0J->T0J_PERAPU == TRIBUTO_ANUAL .or. FWFldGet( "CWV_ANUAL" )
EndIf

If AllTrim( SubStr( cCmp, 4 ) ) $ "CWV_INIPER|CWV_ANUAL|"
	xValueCmp := FWFldGet( "CWV_INIPER" )

	If !Empty( xValueCmp )
		/*
		As regras da validação deverão ser aplicadas somente se a data - 1 não pertencer
		a um Evento Especial ou se o Período não for referente ao IRPJ ou a CSLL
		*/
		If !FindEveEsp( DaySub( xValueCmp, 1 ) ) .or. ( T0J->T0J_TPTRIB <> TIPO_TRIBUTO_IRPJ .and. T0J->T0J_TPTRIB <> TIPO_TRIBUTO_CSLL )
			If lPerAnual .and. FirstYDate( xValueCmp ) <> xValueCmp
				AddLogErro( STR0012, @cLogValid ) //"O Período deverá iniciar no primeiro dia do ano ou no dia seguinte à um Evento Especial."
			ElseIf !lPerAnual .and. FirstDate( xValueCmp ) <> xValueCmp
				AddLogErro( STR0007, @cLogValid ) //"O Período deverá iniciar no primeiro dia do mês ou no dia seguinte à um Evento Especial."
			EndIf
		EndIf
	EndIf
EndIf

If AllTrim( SubStr( cCmp, 4 ) ) $ "CWV_FIMPER|CWV_ANUAL|"
	xValueCmp := FWFldGet( "CWV_FIMPER" )

	If !Empty( xValueCmp )
		/*
		As regras da validação deverão ser aplicadas somente se a data não pertencer
		a um evento especial ou se o Período não for referente ao IRPJ ou a CSLL
		*/
		If !FindEveEsp( xValueCmp ) .or. ( T0J->T0J_TPTRIB <> TIPO_TRIBUTO_IRPJ .and. T0J->T0J_TPTRIB <> TIPO_TRIBUTO_CSLL )
			If Empty( FWFldGet( "CWV_INIPER" ) )
				AddLogErro( STR0009, @cLogValid ) //"A data inicial do Período deverá ser preenchida antes da data final."
			ElseIf LastYDate( xValueCmp ) <> xValueCmp .and. lPerAnual
				AddLogErro( STR0011, @cLogValid ) //"O Período deverá finalizar no último dia do ano quando a periodicidade do tributo for anual ou o período for parametrizado como anual, exceto quando existir um Evento Especial dentro do período."
			ElseIf Lastday( FWFldGet( "CWV_INIPER" ) ) <> xValueCmp .and. T0J->T0J_PERAPU == TRIBUTO_MENSAL .and. !lPerAnual
				AddLogErro( STR0008, @cLogValid ) //"O Período deverá finalizar no último dia do mês quando a periodicidade do tributo for mensal, exceto quando existir um Evento Especial dentro do período ou tratar-se de período anual."
			ElseIf T0J->T0J_PERAPU == TRIBUTO_TRIMESTRAL .and.  !lPerAnual .and. ;
				!( Mod( Month( xValueCmp ), 3 ) == 0 .and. Lastday( xValueCmp ) == xValueCmp )
				AddLogErro( STR0010, @cLogValid ) //"O Período deverá finalizar no último dia do trimestre quando a periodicidade do tributo for trimestral, exceto quando existir um Evento Especial dentro do período."
			EndIf
		EndIf
	EndIf
EndIf

If !Empty( cLogValid )
	ShowLog( STR0015, cLogValid ) //"Atenção"
	lRet := .F.
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} FindEveEsp

Função utilizada para validar se existe um Evento Especial na data informada.

@Return	lRet	- Retorna se a data informada pertence a um Evento Especial

@Author	David Costa
@Since		15/07/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FindEveEsp( dData )

Local lRet	as logical

lRet	:=	.F.

DBSelectArea( "CWU" )
CWU->( DBSetOrder( 2 ) )
If CWU->( MsSeek( xFilial( "CWU" ) + DToS( dData ) ) )
	lRet := .T.
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF444VldMdl

Função de validação dos dados do modelo.

@Param		oModel	- Modelo de dados

@Return	lRet	- Indica se o modelo é válido para gravação

@Author	David Costa
@Since		15/07/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAF444VldMdl( oModel, lGravaLog, cLogErros )

Local oModelCWV	as object
Local cAliasQry	as character
Local cLogValid	as character
Local cSelect		as character
Local cFrom		as character
Local cWhere		as character
Local nOperation	as numeric
Local aAreaBkp	as array
Local lRet			as logical

Default lGravaLog := .F.

oModelCWV	:=	oModel:GetModel( "MODEL_CWV" )
cAliasQry	:=	GetNextAlias()
cLogValid	:=	""
cSelect	:=	""
cFrom		:=	""
cWhere		:=	""
nOperation	:=	oModel:GetOperation()
aAreaBkp	:=	{}
lRet		:=	.T.

If nOperation == MODEL_OPERATION_DELETE
	If oModelCWV:GetValue( "CWV_STATUS" ) == PERIODO_ENCERRADO
		AddLogErro( STR0014, @cLogValid )//"Apenas períodos com o Status Aberto podem ser excluídos"
	EndIf
EndIf

If oModelCWV:GetValue( "CWV_STATUS" ) <> PERIODO_ENCERRADO
	If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE
	
		aAreaBkp := CWV->( GetArea() )
		
		CWV->( DbSetOrder( 2 ) )
		
		If CWV->( MsSeek( xFilial( "CWV" ) + DTOS( oModelCWV:GetValue( "CWV_INIPER" ) ) + DTOS( oModelCWV:GetValue( "CWV_FIMPER" ) ) + oModelCWV:GetValue( "CWV_IDTRIB" ) ) )
			If CWV->CWV_ANUAL == oModelCWV:GetValue( "CWV_ANUAL" ) .and. CWV->CWV_ID <> oModelCWV:GetValue( "CWV_ID" )
				AddLogErro( STR0016, @cLogValid )//"Já existe um cadastro para este tributo neste período"
			EndIf
		EndIf
		
		RestArea( aAreaBkp )
		
	EndIf
	
	If nOperation == MODEL_OPERATION_INSERT
	
		cSelect	:= " R_E_C_N_O_ "
		cFrom		:= RetSqlName( "CWV" ) + " CWV "
		cWhere		:= " CWV.D_E_L_E_T_ = '' "
		cWhere		+= " AND CWV_FILIAL = '" + xFilial( "CWV" ) + "' "
		cWhere		+= " AND CWV_INIPER > '" + DTOS( oModelCWV:GetValue( "CWV_INIPER" ) ) + "' "
		cWhere		+= " AND CWV_STATUS = '" + PERIODO_ENCERRADO + "' "
		cWhere		+= " AND CWV_ANUAL = '" + StrTran( cValToChar( oModelCWV:GetValue( "CWV_ANUAL" ) ), ".", "" ) + "' "
		cWhere		+= " AND CWV_IDTRIB = '" + oModelCWV:GetValue( "CWV_IDTRIB" ) + "' "
		
		cSelect	:= "%" + cSelect 	+ "%"
		cFrom  	:= "%" + cFrom   	+ "%"
		cWhere 	:= "%" + cWhere  	+ "%"
		
		BeginSql Alias cAliasQry
		
			SELECT
				%Exp:cSelect%
			FROM
				%Exp:cFrom%
			WHERE
				%Exp:cWhere%
		EndSql
		
		DBSelectArea( cAliasQry )
		( cAliasQry )->( DbGoTop() )
		
		If ( cAliasQry )->( !Eof() )
			AddLogErro( STR0013, @cLogValid )//"O período não pode ser incluido porque existem períodos posteriores encerrados"
		EndIf
		
		( cAliasQry )->( DbCloseArea() )
	EndIf

EndIf

If !Empty( cLogValid )
	If lGravaLog
		AddLogErro( cLogValid, @cLogErros )
	Else
		ShowLog( STR0015, cLogValid ) //"Atenção"
	EndIf
	lRet := .F.
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCmpPer

Função utilizada para consistir os campos do Período de Apuração.

@Return	lRet	- Indica se o campo está válido

@Author	David Costa
@Since		02/08/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function VldCmpPer()

Local cCmp			as character
Local cFormaTrib	as character
Local cTributo	as character
Local cCodGrupo	as character
Local cLogValid	as character
Local nIdGrupo	as numeric
Local lRet			as logical
Local xValueCmp

cCmp		:=	ReadVar()
cFormaTrib	:=	""
cTributo	:=	""
cCodGrupo	:=	""
cLogValid	:=	""
nIdGrupo	:=	0
lRet		:=	.T.
xValueCmp	:=	Nil

If AllTrim( SubStr( cCmp, 4 ) ) $ "CWX_CODLAL|CWX_CODECF|"
	xValueCmp := &( cCmp )

	If !Empty( GetValueCmp( "CWX_CODLAL", "MODEL_CWX" ) ) .and. !Empty( GetValueCmp( "CWX_CODECF", "MODEL_CWX" ) )
		AddLogErro( STR0019, @cLogValid ) //"Um item não pode ter preenchido os códigos da ECF e do LALUR simultaneamente."

	ElseIf !Empty( xValueCmp )

		T0N->( DBSetOrder( 1 ) )
		If T0N->( DBSeek( xFilial( "T0N" ) + FWFldGet( "CWV_IDEVEN" ) ) )
			T0K->( DBSetOrder( 1 ) )
			
			If T0K->( DBSeek( xFilial( "T0K" ) + T0N->T0N_IDFTRI ) )
				cFormaTrib := T0K->T0K_CODIGO
			EndIf
			
			T0J->( DBSetOrder( 1 ) )
			If T0J->( DBSeek( xFilial( "T0J" ) + T0N->T0N_IDTRIB ) )
				cTributo := T0J->T0J_TPTRIB
			EndIf
			
			//Seleciona o código do grupo da linha em edição na Grid
			cCodGrupo := GetValueCmp( "CWX_CODGRU", "MODEL_CWX" )
			nIdGrupo := Iif( Empty( cCodGrupo ), 0, Val( cCodGrupo ) )
			
		 	//Verifica o código permitido para este grupo conforme regras do Evento Tributário
		 	cCodTDECF := GetCodECF( cFormaTrib, nIdGrupo, cTributo )

		 	If !( cCodTDECF $ xValueCmp ) .or. Empty( cCodTDECF )
		 		AddLogErro( STR0017, @cLogValid ) //"Código inválido para este item."
		 	EndIf

		EndIf
	EndIf
EndIf


If !Empty( cLogValid )
	ShowLog( STR0015, cLogValid ) //"Atenção"
	lRet := .F.
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF444Bxa

Funcionalidade para Baixa/Estorno do Documento de Arrecadação.

@Param		oModel	-	Objeto do modelo MVC

@Author	Felipe C. Seolin
@Since		19/09/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF444Bxa( oModel )

Local oView	as object
Local cID		as character
Local aArea	as array

oView	:=	FWViewActive()
cID		:=	oModel:GetModel( "MODEL_T50" ):GetValue( "T50_IDGUIA" )
aArea	:=	C0R->( GetArea() )

If oView:GetFolderActive( "FOLDER_GERAL", 2 )[2] == STR0025 //"Guias"
	DBSelectArea( "C0R" )
	C0R->( DBSetOrder( 6 ) )
	If C0R->( MsSeek( xFilial( "C0R" ) + cID ) )
		TAF027Bxa()
	EndIf
Else
	MsgInfo( STR0027 ) //"Processo permitido apenas na aba 'Guias'"
EndIf

RestArea( aArea )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA444Enc
Função para Encerramento do Período de Apuração

@Return Nil 

@Author David Costa
@Since 30/08/2016
@Version 1.0
/*/
//------------------------------------------------------------------------------------------------
Function TAFA444Enc(lAutomato)

Local cNomWiz	as character
Local lEnd		as logical

Private oProcess	as object

Default lAutomato := .F.

cNomWiz	:=	STR0021 + " " + DToC( CWV->CWV_INIPER ) + " à " + DToC( CWV->CWV_FIMPER ) + " " + xFunID2Cd( CWV->CWV_IDTRIB, "T0J", 1 ) //Encerrando Período
lEnd		:=	.F.

If !lAutomato
	oProcess :=	Nil
	//Cria objeto de controle do processamento
	oProcess := TAFProgress():New( { |lEnd| EncerraPer( ) }, cNomWiz )
	oProcess:Activate()
else
	EncerraPer( lAutomato )
endif

//Limpando a memória
DelClassIntf()

Return( )

//-------------------------------------------------------------------
/*/{Protheus.doc} EncerraPer
Função para Encerramento do Período de Apuração

@Return Nil 

@Author David Costa
@Since 30/08/2016
@Version 1.0
/*/
//------------------------------------------------------------------------------------------------
Static Function EncerraPer( lAutomato )

Local oModelPeri as object
Local cLogErros	 as character
Local cLogAvisos as character
Local nProgress1 as numeric

Default lAutomato := .F.

oModelPeri	:=	FWLoadModel( "TAFA444" )
cLogErros	:=	""
cLogAvisos	:=	""
nProgress1	:=	4

oModelPeri:SetOperation( MODEL_OPERATION_UPDATE )
oModelPeri:Activate()
if !lAutomato
	oProcess:Set1Progress( nProgress1 )
endif
Taf444Encerrar( @oModelPeri, @cLogErros, @cLogAvisos, lAutomato )
If !Empty( cLogAvisos ) .And. !lAutomato
	ShowLog( STR0015, cLogAvisos )//"Atenção"
EndIf
If !Empty( cLogErros ) .And. !lAutomato
	//Apresentando Log do processo
	oProcess:Set1Progress( 1 )
	oProcess:Set2Progress( 1 )
	oProcess:Inc1Progress( STR0033 )//"Erro ao encerrar período"
	oProcess:Inc2Progress( STR0034 ) //"Clique em finalizar"
	oProcess:nCancel := 1
	ShowLog( STR0015, cLogErros )//"Atenção"
EndIf

oModelPeri:DeActivate()

Return()

/*/{Protheus.doc} Taf444Encerrar
Processa o encerramento do período
@author david.costa
@since 18/12/2017
@version 1.0
/*/
Function Taf444Encerrar( oModelPeri, cLogErros, cLogAvisos, lAutomato )

Local cTpTributo	as character
Local lEncerrar	as logical
Local aParametro as array

Default lAutomato := .F.

cTpTributo	:= ''
lEncerrar	:= .T.

If oModelPeri:GetValue( "MODEL_CWV", "CWV_STATUS" ) <> PERIODO_ENCERRADO
	if !lAutomato
		//Verifica o Tipo do Tributo do Período
		oProcess:Inc1Progress( STR0028 )//"Verificando o tributo"
	endif
	cTpTributo := GetTpTribu( oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ) )
	if !lAutomato
		//Aplica regras especificas do tributo
		oProcess:Inc1Progress( STR0029 )//"Aplicando regras do tributo"
	endif
	If cTpTributo == TIPO_TRIBUTO_IRPJ .or. cTpTributo == TIPO_TRIBUTO_CSLL
		lEncerrar := ApuraIRPJ( @oModelPeri, @cLogErros, @cLogAvisos, @aParametro, lAutomato )
	EndIf

	If lEncerrar
		if !lAutomato
			oProcess:Inc1Progress( STR0030 )//"Salvando período"
		endif
		SalvarPer( @oModelPeri, @cLogAvisos, @cLogErros, cTpTributo, aParametro, lAutomato )
	Else
		cLogAvisos := ""
	EndIf
Else
	AddLogErro( STR0032, @cLogErros )//"Período já encerrado"
EndIf

Return()

/*/{Protheus.doc} GetTpTribu
Verifica o Tipo do tributo do Cadastro do Período
@author david.costa
@since 14/10/2016
@version 1.0
@param cIdTrib, character, Id do tributo
@return ${cTpTributo}, ${Tipo do tributo}
@example
GetTpTribu( oModelPeri )
/*/Static Function GetTpTribu( cIdTrib )

Local cTpTributo	as character

cTpTributo	:=	""

DBSelectArea( "T0J" )
T0J->( DbSetOrder( 1 ) )
If T0J->( MsSeek( xFilial( "T0J" ) + cIdTrib ))
	cTpTributo := T0J->T0J_TPTRIB
EndIf

Return( cTpTributo )

/*/{Protheus.doc} ApuraIRPJ
Aplica Regras de apuração para o IRPJ e a CSLL
@author david.costa
@since 14/10/2016
@version 1.0
@param oModelPeri, objeto, Passar por referência o objeto FWFormModel() do cadastro do período
@param cLogErros, character, Passar por referência o Log de Validação do processo
@param cLogAvisos, character, Passar por referência o Log com Avisos sobre a execução do processo
@return ${lEncerrar}, ${Retorna true se as regras foram aplicada com sucesso e o período pode ser encerrado}
@example
ApuraIRPJ( @oModelPeri, @cLogErros, cLogAvisos )
/*/Static Function ApuraIRPJ( oModelPeri, cLogErros, cLogAvisos, aParametro, lAutomato )

Local oModelEven	as object
Local cIdEvento	as character
Local nProgress2	as numeric
Local lEncerrar	as logical

Private lPerAnter := PerAntEnce( oModelPeri )

Default aParametro := {}
Default lAutomato := .F.

oModelEven	:=	FWLoadModel( "TAFA444" )
cIdEvento	:=	""
nProgress2	:=	0
aParametro	:=	{} 
lEncerrar	:=	.T.

if !lAutomato
	oProcess:Set2Progress( nProgress2 )
	//Verifica se os períodos anteriores estão encerrados
	oProcess:Inc2Progress( STR0036 )//"Verificando períodos anteriores"
endif
If !lPerAnter
	//Períodos anteriores abertos
	AddLogErro( STR0037, @cLogErros )//"Para encerrar este período todos os períodos anteriores deste tributo precisam ser encerrados."
EndIf
if !lAutomato
	//Verifica se a Filial é uma matriz ou SCP
	oProcess:Inc2Progress( STR0038 )//"Validando filial"
endif
If !FilMatSCP()
	AddLogErro( STR0039, @cLogErros )//"Este processo pode ser executando somente para uma Filial Matriz ou Filial SCP"
EndIf
if !lAutomato
	//Verifica a Vigência
	oProcess:Inc2Progress( STR0040 )//"Verificando o Cadastro de Vigência"
Endif
If !SelVigencia( oModelPeri, @cIdEvento )
	AddLogErro( STR0041, @cLogErros )//"Não existe uma vigência cadastrada abrangindo este período"
EndIf
if !lAutomato
	//Carrega Evento tributário Vigente
	oProcess:Inc2Progress( STR0042 )//"Selecionando evento tributário vigente"
endif
If !LoadEvento( @oModelEven, cIdEvento )
	AddLogErro( STR0043, @cLogErros )//"Não foi possível encontrar o Evento Tributário para apuração deste período"
//Apura o Evento Tributário
Else
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_IDEVEN", oModelEven:GetValue( "MODEL_T0N", "T0N_ID"  ) )
	if !lAutomato
		oProcess:Inc2Progress( STR0044 )//"Apurando evento tributário"
	endif
	//Carrega os dados necessários para a apuração
	LoadParam( @aParametro, oModelPeri, oModelEven )
	ApuraEvent( @oModelPeri, @oModelEven, @cLogErros, @cLogAvisos, @aParametro, /*6*/, /*7*/,lAutomato )
EndIf

If !Empty( cLogErros )
	lEncerrar := .F.
EndIf

FreeObj( oModelEven )

Return( lEncerrar )

/*/{Protheus.doc} SalvarPer
Salva o cadastro do período de Apuração
@author david.costa
@since 14/10/2016
@version 1.0
@param oModelPeri, objeto, Passar por referência o objeto FWFormModel() do cadastro do período
@param cLogAvisos, character, Log com Avisos sobre a execução do processo
@param cLogErros, character, Log com Erros da execução do processo
@return ${Nil}, ${Nulo}
@example
SalvarPer( @oModelPeri, @cLogAvisos, @cLogErros )
/*/Static Function SalvarPer( oModelPeri, cLogAvisos, cLogErros, cTpTributo, aParametro, lAutomato )

Local cMsg	as character

Default aParametro := {}
Default lAutomato  := .F.
cMsg	:=	""

Begin Transaction
	
	oModelPeri:SetValue( "MODEL_CWV", "CWV_STATUS", PERIODO_ENCERRADO )
	FWFormCommit( oModelPeri )
	
	If cTpTributo == TIPO_TRIBUTO_IRPJ .or. cTpTributo == TIPO_TRIBUTO_CSLL
		if !lAutomato
			oProcess:Inc1Progress( STR0068 ) //"Processando Lançamentos do LALUR Parte B"
		endif
		ProcParteB( @cLogAvisos, @cLogErros, aParametro, lAutomato )
	EndIf
	if !lAutomato
		oProcess:Inc1Progress( cMsg )
		oProcess:Set2Progress( 1 )
	endif
End Transaction

Return()

/*/{Protheus.doc} PerAntEnce
Verifica se os períodos anteriores estão encerrados
@author david.costa
@since 14/10/2016
@version 1.0
oModelPeri, objeto, Objeto FWFormModel() do cadastro do período
@return ${lPerAntEnc}, ${True se os períodos anterioes estiverem encerrados}
@example
PerAntEnce( oModelPeri )
/*/Static Function PerAntEnce( oModelPeri )

Local cAliasQry	as character
Local cSelect		as character
Local cFrom		as character
Local cWhere		as character
Local lPerAntEnc	as logical

cAliasQry	:=	GetNextAlias()
cSelect	:=	""
cFrom		:=	""
cWhere		:=	""
lPerAntEnc	:=	.T.

cSelect	:= " CWV_ID "
cFrom		:= RetSqlName( "CWV" ) + " CWV "
cWhere		:= " CWV.D_E_L_E_T_ = '' "
cWhere		+= " AND CWV_FILIAL = '" + xFilial( "CWV" ) + "' "
/*Períodos Abertos*/
cWhere		+= " AND CWV_STATUS = '" + PERIODO_ABERTO + "' "
cWhere		+= " AND CWV_FIMPER < '" + DTOS( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) + "' "
cWhere		+= " AND CWV_IDTRIB = '" + oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ) + "' "

cSelect	:= "%" + cSelect 	+ "%"
cFrom  	:= "%" + cFrom   	+ "%"
cWhere 	:= "%" + cWhere  	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
EndSql

DBSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )

//Se existir algum período anterior aberto a váriavel deve ser setada para False
lPerAntEnc := ( ( cAliasQry )->( ( Eof() ) ) )

( cAliasQry )->( DbCloseArea() )

Return( lPerAntEnc )

/*/{Protheus.doc} FilMatSCP
Verifica se a Filial do contexto é uma Matriz ou SCP
@author david.costa
@since 14/10/2016
@version 1.0
@return ${lMatrizSCP}, ${True se a Filial for SCP ou Matriz}
@example
FilMatSCP()
/*/Static Function FilMatSCP()

Local cIdFilial	as character
Local lMatrizSCP	as logical

cIdFilial	:=	xFunCh2ID( cFilAnt, "C1E", 3,,,, .T. )
lMatrizSCP	:=	.F.

DBSelectArea( "C1E" )
C1E->( DbSetOrder( 3 ) )
C1E->( MsSeek( xFilial( "C1E" ) + cFilAnt ) )
	
If FilialSCP( cIdFilial ) .or. C1E->C1E_MATRIZ
	lMatrizSCP := .T.
EndIf

Return( lMatrizSCP )

/*/{Protheus.doc} SelVigencia
Seleciona a Vigência para o período informado
@author david.costa
@since 14/10/2016
@version 1.0
@param oModelPeri, objeto, Objeto FWFormModel() do cadastro do período
@param cIdEvento, charecter, Identificador do cadastro do Evento Tributário
@return ${lRet}, ${Retorna true se conseguir selecionar uma vigência}
@example
SelVigencia( oModelPeri, @cIdEvento )
/*/Static Function SelVigencia( oModelPeri, cIdEvento )

Local cAliasQry	as character
Local cSelect		as character
Local cFrom		as character
Local cWhere		as character
Local lRet			as logical

cAliasQry	:=	GetNextAlias()
cSelect	:=	""
cFrom		:=	""
cWhere		:=	""
lRet		:=	.F.

cSelect	:= " LEL_IDCODE "
cFrom		:= RetSqlName( "LEL" ) + " LEL "

//Para o período de ajuste anual é necessário ter um evento tributário vigente do tipo Lucro Real
If oModelPeri:GetValue( "MODEL_CWV", "CWV_ANUAL" )
	cFrom += " JOIN " + RetSqlName( "T0N" ) + " T0N "
	cFrom += " 	JOIN " + RetSqlName( "T0K" ) + " T0K "
	cFrom += " 		ON T0K_CODIGO = '" + TRIBUTACAO_LUCRO_REAL + "' AND T0K_ID = T0N_IDFTRI "
	cFrom += " 	ON T0N_FILIAL = LEL_FILIAL AND T0N_ID = LEL_IDCODE AND T0N.D_E_L_E_T_ = '' "

//Se o período for mensal não poderá utilizar um evento tributário do tipo Lucro Real
ElseIf DateDiffMonth( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ), oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) == 0
	cFrom += " JOIN " + RetSqlName( "T0N" ) + " T0N "
	cFrom += " 	JOIN " + RetSqlName( "T0K" ) + " T0K "
	cFrom += " 		ON T0K_CODIGO <> '" + TRIBUTACAO_LUCRO_REAL + "' AND T0K_ID = T0N_IDFTRI "
	cFrom += " 	ON T0N_FILIAL = LEL_FILIAL AND T0N_ID = LEL_IDCODE AND T0N.D_E_L_E_T_ = '' "
EndIf

cWhere		:= " LEL.D_E_L_E_T_ = '' "
cWhere		+= " AND LEL_FILIAL = '" + xFilial( "LEL" ) + "' "
cWhere		+= " AND LEL_DTINI <= '" + DTOS( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ) + "' "
cWhere		+= " AND LEL_DTFIN >= '" + DTOS( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) + "' "
cWhere		+= " AND LEL_IDCODT = '" + oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" )+ "' "

cSelect	:= "%" + cSelect 	+ "%"
cFrom  	:= "%" + cFrom   	+ "%"
cWhere 	:= "%" + cWhere  	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
EndSql

DBSelectArea( cAliasQry )
( cAliasQry )->( DbGoTop() )

If ( cAliasQry )->( !Eof() )
	lRet := .T.
	cIdEvento := ( cAliasQry )->LEL_IDCODE
EndIf

( cAliasQry )->( DbCloseArea() )

Return( lRet )

/*/{Protheus.doc} LoadEvento
Carrega o Evento Trbutário vigente para o periodo
@author david.costa
@since 14/10/2016
@version 1.0
@param oModelEven, objeto, Passar por referência o Objeto FWFormModel() do cadastro do Evento Tributário
@param cIdEvento, charecter, Identificador do cadastro do Evento Tributário
@return ${lRet}, ${True se conseguir carregar o Evento Vigente para o Período}
@example
LoadEvento( @oModelEven, cIdEvento )
/*/Function LoadEvento( oModelEven, cIdEvento )

Local lRet	as logical

lRet	:=	.F.

DBSelectArea( "T0N" )
T0N->( DbSetOrder( 1 ) )

If T0N->( MsSeek( xFilial( "T0N" ) + cIdEvento ) )
	oModelEven := FWLoadModel( 'TAFA433' )
	oModelEven:SetOperation( MODEL_OPERATION_VIEW )
	oModelEven:Activate()
	lRet := .T.
EndIf

Return( lRet )

/*/{Protheus.doc} ApuraEvent
Apura os valores do Evento Tributário
@author david.costa
@since 14/10/2016
@version 1.0
@param oModelPeri, objeto, Passar por referência o objeto FWFormModel() do cadastro do período
@param oModelEven, objeto, Passar por referência o Objeto FWFormModel() do cadastro do Evento Tributário
@param cLogErros, character, Passar por referência o Log de Validação do processo
@param cLogAvisos, character, Passar por referência o Log com Avisos sobre a execução do processo
@param aParametro, ${param_type}, Passar por referência o array com os pametros para a apuração
@param lSimula, lógico, Indica se o processamento é uma simulação ou apuração
@param aParRural, ${param_type}, Passar por referência o array com os pametros para a apuração do Evento da Atividade Rural
@return ${Nil}, ${Nulo}
@example
ApuraEvent( @oModelPeri, @oModelEven, @cLogErros, @cLogAvisos, @aParametro, lSimula, aParRural )
/*/Function ApuraEvent( oModelPeri, oModelEven, cLogErros, cLogAvisos, aParametro, lSimula, aParRural, lAutomato, aItemsEvt)

Local oModeEveRu as object
Local nBase		 as numeric
Local aGrupos    as array

Default lSimula	  := .F.
Default aParRural := {}
Default lAutomato := .F.
Default aItemsEvt := {}

Private lPerAnter := PerAntEnce( oModelPeri )

oModeEveRu	:= Nil
nBase	 	:= 0
aGrupos	  	:= {}

//Se for simulação o detalhamento precisa ser removido e cálculado novamente
If lSimula .and. oModelPeri:GetValue( "MODEL_CWV", "CWV_STATUS" ) == PERIODO_ENCERRADO
	oModelPeri:GetModel( "MODEL_CWX"):DelAllLine()
EndIf

//Seleciona os grupos pertinentes para a forma de tributação em questão
aGrupos := GrupoEvnto( XFUNID2Cd( oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 ) )

//Calcula a Base de Cálculo do tributo
CalcBCEven( @oModelPeri, aGrupos, @aParametro, oModelEven, @cLogErros, @cLogAvisos, lSimula, .F., lAutomato, @aItemsEvt )

If XFUNID2Cd( oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 ) == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
	//Imposto Devido em Períodos anteriores por Estimativa
	DeviPerAnt( aParametro, oModelPeri )
ElseIf XFUNID2Cd( oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 ) == TRIBUTACAO_LUCRO_REAL
	//Imposto Pago em Períodos anteriores por Estimativa
	PagoPerAnt( aParametro, oModelPeri )
EndIf

If !lSimula .And. !lAutomato
	oProcess:Inc2Progress( STR0047 )//"Calculando o Tributo"
EndIf

//Cálculo da Atividade Rural
CalcRural( oModelEven, @oModelPeri, @aParametro, @cLogErros, @cLogAvisos, @aParRural, lSimula, lAutomato )

//Compensação de Prejuízo do período Atual
ComPjAtual( @aParRural, @aParametro, @oModelPeri, @cLogErros, @cLogAvisos )

//Carrega o evento da Atividade Rural
LoadEvento( @oModeEveRu, oModelEven:GetValue( "MODEL_T0N", "T0N_IDEVEN"  ) )

//Se houver lucro na atividade Rural
If VlrLRAntes( aParRural ) > 0
	//Calcula o Grupo Compensação do Prejuízo para a Atividade Rural
	nIndicGrup := aScan( aGrupos, { |x| x[ PARAM_GRUPO_ID ] == GRUPO_COMPENSACAO_PREJUIZO } )
	aParRural[ GRUPO_COMPENSACAO_PREJUIZO ] += ApuraGrupo( @oModelPeri, oModeEveRu, @cLogErros, ;
	aGrupos[ nIndicGrup ], @cLogAvisos, aParRural,,, oModeEveRu:GetModel( "MODEL_T0O_" + aGrupos[ nIndicGrup, PARAM_GRUPO_NOME ] ), lSimula, .T. )
EndIf

//Se houver lucro na Atividade Geral
If VlrLRApoPj( aParametro, aParRural ) > 0
	//Calcula compensações de prejuízo
	nIndicGrup := aScan( aGrupos, { |x| x[ PARAM_GRUPO_ID ] == GRUPO_COMPENSACAO_PREJUIZO } )
	aParametro[ GRUPO_COMPENSACAO_PREJUIZO ] += Iif( nIndicGrup > 0, ApuraGrupo( @oModelPeri, oModelEven, @cLogErros, aGrupos[ nIndicGrup ], @cLogAvisos, aParametro,,, oModelEven:GetModel( "MODEL_T0O_" + aGrupos[ nIndicGrup, PARAM_GRUPO_NOME ] ), lSimula, .F. ), 0)
EndIf

//Cria os lançamentos de compensação de prejuízo automaticos
LanAutPrej( aGrupos, @aParametro, @oModelPeri, oModelEven, @cLogAvisos, @aParRural, lSimula )

If VlrLucReal( aParametro, aParRural ) > 0
	//Calcula o grupo adicionais do tributo
	nIndicGrup := aScan( aGrupos, { |x| x[ PARAM_GRUPO_ID ] == GRUPO_ADICIONAIS_TRIBUTO } )
	aParametro[ GRUPO_ADICIONAIS_TRIBUTO ] += Iif( nIndicGrup > 0, ApuraGrupo( @oModelPeri, oModelEven, @cLogErros, aGrupos[ nIndicGrup ], @cLogAvisos, aParametro,,, oModelEven:GetModel( "MODEL_T0O_" + aGrupos[ nIndicGrup, PARAM_GRUPO_NOME ] ), lSimula, .F. ), 0)
	
	//Calcula deduções do tributo
	nIndicGrup := aScan( aGrupos, { |x| x[ PARAM_GRUPO_ID ] == GRUPO_DEDUCOES_TRIBUTO } )
	aParametro[ GRUPO_DEDUCOES_TRIBUTO ] += Iif( nIndicGrup > 0, ApuraGrupo( @oModelPeri, oModelEven, @cLogErros, aGrupos[ nIndicGrup ], @cLogAvisos, @aParametro,,, oModelEven:GetModel( "MODEL_T0O_" + aGrupos[ nIndicGrup, PARAM_GRUPO_NOME ] ), lSimula, .F. ), 0)

	//Calcula compensações do tributo
	nIndicGrup := aScan( aGrupos, { |x| x[ PARAM_GRUPO_ID ] == GRUPO_COMPENSACAO_TRIBUTO } )
	aParametro[ GRUPO_COMPENSACAO_TRIBUTO ] := Iif( nIndicGrup > 0, ApuraGrupo( @oModelPeri, oModelEven, @cLogErros, aGrupos[ nIndicGrup ], @cLogAvisos, aParametro,,, oModelEven:GetModel( "MODEL_T0O_" + aGrupos[ nIndicGrup, PARAM_GRUPO_NOME ] ), lSimula, .F. ), 0)
Else
	//No caso de prejuízo o cálculo deverá ser realizado para o lucro da exploração
	//Calcula deduções do tributo
	nIndicGrup := aScan( aGrupos, { |x| x[ PARAM_GRUPO_ID ] == GRUPO_DEDUCOES_TRIBUTO } )
	aParametro[ GRUPO_DEDUCOES_TRIBUTO ] += Iif( nIndicGrup > 0, ApuraGrupo( @oModelPeri, oModelEven, @cLogErros, aGrupos[ nIndicGrup ], @cLogAvisos, @aParametro,,, oModelEven:GetModel( "MODEL_T0O_" + aGrupos[ nIndicGrup, PARAM_GRUPO_NOME ] ), lSimula, .F. ), 0)
EndIf

//Calcula o Prejuízo da atividade Rural
aParRural[ VLR_PREJUIZO_OPERACIONAL ] += CalcPrejOp( aParRural, aParametro )
aParRural[ VLR_PREJUIZO_NAO_OPERACIONAL ] += CalPrejNOp( aParRural, aParametro )

//Calcula o Prejuízo da atividade geral
aParametro[ VLR_PREJUIZO_OPERACIONAL ] += CalcPrejOp( aParametro, aParRural )
aParametro[ VLR_PREJUIZO_NAO_OPERACIONAL ] += CalPrejNOp( aParametro, aParRural )

//Atualiza os Valores no período
UpdVlrPeri( @oModelPeri, aParametro, @cLogAvisos, lSimula, aParRural, XFUNID2Cd( oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 ) )

If oModeEveRu != Nil
	FreeObj( oModeEveRu )
EndIf

Return()

/*/{Protheus.doc} ApuraGrupo
Apura um Grupo tributário baseado nos itens do Evento e nos lançamentos manuais
@author david.costa
@since 14/10/2016
@version 1.0
@param oModelPeri, objeto, Passar por referência o objeto FWFormModel() do cadastro do período
@param oModelEven, objeto, Passar por referência o Objeto FWFormModel() do cadastro do Evento Tributário
@param cLogErros, character, Passar por referência o Log de Validação do processo
@param aGrupo, array, Array com os dados do Grupo que será apurado
@param cLogAvisos, character, Passar por referência o Log com Avisos sobre a execução do processo
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param nIteGrupo, numérico, Parâmemtro interno
@param nTotGrupo, numérico, Parâmemtro interno
@param oModelGrup, objeto, Parâmemtro interno
@param lSimula, lógico, Indica se o processamento é uma simulação ou apuração
@param lRural, Logical, Indica se o item é da atividade Rural
@return ${nTotGrupo}, ${Valor Total do Grupo Apurado}
@example
ApuraGrupo( @oModelPeri, oModelEven, @cLogErros, aGrupo, @cLogAvisos )
/*/
Static Function ApuraGrupo( oModelPeri, oModelEven, cLogErros, aGrupo, cLogAvisos, aParametro, nIteGrupo, nTotGrupo, oModelGrup, lSimula, lRural, aItemsEvt )

Local cOrigem	as character
Local nValItem	as numeric
Local nX        as numeric
Local aValItem  as array

Default nIteGrupo  := 1
Default nTotGrupo  := 0
Default oModelGrup := oModelEven:GetModel( "MODEL_T0O_" + aGrupo[PARAM_GRUPO_NOME] )
Default aItemsEvt  := {}

cOrigem	 :=	""
nValItem :=	0
aValItem := {}  

nLen := oModelGrup:Length()
If nLen > 0
	for nX := nIteGrupo to nLen
		//conout( "Controle Descida " + cValtoChar(nX) + "/" + cValtoChar(nLen) )

		oModelGrup:GoLine( nX )
		//Apura Lançamentos Manuais somente no ultimo item
		If nX == oModelGrup:Length()
			nTotGrupo += ApuLanManu( @oModelPeri, oModelEven, aGrupo[ PARAM_GRUPO_ID ], aParametro, @cLogAvisos, lRural )
		EndIf

		If !oModelGrup:IsDeleted() .and. !oModelGrup:IsEmpty()
			nValItem := CalcIteGru( oModelGrup, @oModelPeri, @cLogErros, @cLogAvisos, @aParametro, @cOrigem, aGrupo, oModelEven, lSimula, lRural, @aItemsEvt )
			nTotGrupo += nValItem
			AADD( aValItem , nValItem )

			//No ultimo item do grupo são apurados os lançamentos manuais e é realizado a validação do valor maior que zero
			If nX == oModelGrup:Length()
				
				If aGrupo[ PARAM_GRUPO_ID ] == GRUPO_LUCRO_EXPLORACAO

					nTotGrupo += VlrResCont( aParametro )

				//Se o Grupo totalizar negativo o mesmo será zerado.
				//No caso do grupo de dedução podem existir valores adicionados diretamente no grupo faltantes na variavel nTotGrupo
				//Os Grupo de resultado podem ficar negativos

				ElseIf ( nTotGrupo < 0 .and.;
				 		aGrupo[ PARAM_GRUPO_ID ] <> GRUPO_DEDUCOES_TRIBUTO .and.;
						aGrupo[ PARAM_GRUPO_ID ] <> GRUPO_RESULTADO_NAO_OPERACIONAL .and.;
						aGrupo[ PARAM_GRUPO_ID ] <> GRUPO_RESULTADO_OPERACIONAL ) .or.;
						( aGrupo[ PARAM_GRUPO_ID ] == GRUPO_DEDUCOES_TRIBUTO .and.;
						( aParametro[ GRUPO_DEDUCOES_TRIBUTO ] + nTotGrupo ) < 0 )

					AddLogErro( STR0050, @cLogAvisos, { aGrupo[ PARAM_GRUPO_DESCRICAO ], nTotGrupo } )//"O grupo @1 gerou valor negativo (@2) e por isso foi zerado."
					nTotGrupo := 0
					nValItem  := 0
				EndIf
			EndIf
		endif
	next nX

	nLen := Len(aValItem)

	For nX := nLen To 1 Step -1
		oModelGrup:GoLine( nX )
		AddDetalhe( @oModelPeri, oModelGrup:GetValue( "T0O_ORIGEM" ), aGrupo[ PARAM_GRUPO_ID ], aValItem[nX], oModelGrup:GetValue( "T0O_IDLAL" ), oModelGrup:GetValue( "T0O_IDECF" ) ,;
		oModelGrup:GetValue( "T0O_SEQITE" ), @cLogAvisos, lRural )
	Next
Else
	nTotGrupo += ApuLanManu( @oModelPeri, oModelEven, aGrupo[ PARAM_GRUPO_ID ], aParametro, @cLogAvisos, lRural )
EndIf

Return( nTotGrupo )

/*/{Protheus.doc} CalcIteGru
Calcula o valor do item do Grupo
@author david.costa
@since 08/11/2016
@version 1.0
@param oModelGrup, objeto, Objeto FWFormModel() do cadastro do Evento posicionado no Grupo a ser apurado
@param oModelPeri, objeto, Passar por referência o objeto FWFormModel() do cadastro do período
@param cLogErros, character, Passar por referência o Log de Validação do processo
@param cLogAvisos, character, Passar por referência o Log com Avisos sobre a execução do processo
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param cOrigem, character, Origem do Item
@param aGrupo, array, Array com os parâmetros do Grupo do Item do Evento
@param oModelEven, objeto, Objeto FWFormModel() do cadastro do Evento Tributário
@param lSimula, lógico, Indica se o processamento é uma simulação ou apuração
@return ${nValItem}, ${Valor do Item}
/*/Static Function CalcIteGru( oModelGrup, oModelPeri, cLogErros, cLogAvisos, aParametro, cOrigem, aGrupo, oModelEven, lSimula, lRural, aItemsEvt )

Local oModelTemp	as object
Local nValItem	as numeric

Default aItemsEvt := {}
oModelTemp	:=	Nil
nValItem	:=	0

If oModelGrup:GetValue( "T0O_ORIGEM" ) == ORIGEM_EVENTO_TRIBUTARIO
	
	LoadEvento( @oModelTemp, oModelGrup:GetValue( "T0O_IDEVEN" ) )
	aParametro[ GRUPO_LUCRO_EXPLORACAO ] := ApuraGrupo( @oModelPeri, oModelTemp, @cLogErros, { GRUPO_LUCRO_EXPLORACAO, 'LUCRO_EXPLORACAO', STR0052 }, @cLogAvisos, aParametro,,,, lSimula, .F. )//"Lucro da Exploração"
	
	LoadEvento( @oModelTemp, oModelGrup:GetValue( "T0O_IDEVEN" ) )
	aParametro[ GRUPO_RECEITA_LIQUIDA_ATIVIDA ] := ApuraGrupo( @oModelPeri, oModelTemp, @cLogErros, { GRUPO_RECEITA_LIQUIDA_ATIVIDA, 'RECEITA_LIQ_ATIVIDADE', STR0053 }, @cLogAvisos, aParametro,,,, lSimula, .F. )//"Receita Líquida por Atividade"
	
	//Adiciona o valor da dedução do item de origem evento (lucro da exploração)
	AddDedExpl( aParametro, @oModelPeri, oModelGrup, @cLogAvisos )

//Só poderá ser cálculado quando houver lucro
ElseIf VlrLRAntes( aParametro ) > 0 .or. ( aGrupo[PARAM_GRUPO_ID] == GRUPO_LUCRO_EXPLORACAO .or. aGrupo[PARAM_GRUPO_ID] == GRUPO_RECEITA_LIQUIDA_ATIVIDA ) .or. aGrupo[PARAM_GRUPO_TIPO] == TIPO_GRUPO_BASE_CALCULO
	If oModelGrup:GetValue( "T0O_ORIGEM" ) == ORIGEM_LALUR_PARTE_B

		nValItem := ApuContLAL( oModelPeri, oModelGrup, @cLogErros, aGrupo[ PARAM_GRUPO_ID ], aParametro, oModelEven:GetValue( "MODEL_T0N", "T0N_ID" ), lRural )
		cOrigem := ORIGEM_LALUR_PARTE_B

	ElseIf oModelGrup:GetValue( "T0O_ORIGEM" ) == ORIGEM_CONTA_CONTABIL

		nValItem := ApuraContC( oModelPeri, oModelGrup, @cLogErros, aGrupo, oModelEven, aParametro, @aItemsEvt )
		cOrigem := ORIGEM_CONTA_CONTABIL
		
	EndIf

	//Ajusta o Valor dos itens parametrizados para subtrair
	if oModelGrup:GetValue( "T0O_OPERAC" ) == OPERACAO_SUBTRACAO
		nValItem := nValItem * -1
	endif
	
	//Aplica o % de Dedução / Compensação
	If aGrupo[ PARAM_GRUPO_ID ] == GRUPO_DEDUCOES_TRIBUTO .or. aGrupo[ PARAM_GRUPO_ID ] == GRUPO_COMPENSACAO_TRIBUTO .or.;
	 	aGrupo[ PARAM_GRUPO_ID ] == GRUPO_COMPENSACAO_PREJUIZO
		AplDedComp( @nValItem, oModelGrup, aParametro, @cLogErros, aGrupo, lSimula )
	EndIf
	
	//Para o Grupo Receita Liquida por Atividades, os valores dos itens serão agrupados pela proporção do lucro
	If aGrupo[ PARAM_GRUPO_ID ] == GRUPO_RECEITA_LIQUIDA_ATIVIDA
		PropoLucro( @aParametro, oModelGrup, nValItem )
	EndIf

EndIf

Return( nValItem )

/*/{Protheus.doc} AddDedExpl
Adiciona o Valor da dedução do evento relacionado (Dedução do Lucro da Exploração)
@author david.costa
@since 08/11/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param oModelPeri, objeto, Passar por referência o objeto FWFormModel() do cadastro do período
@param oModelGrup, objeto, Objeto FWFormModel() do cadastro do Evento posicionado no Grupo a ser apurado
@param cLogAvisos, character, Log de Avisos do processo
@return ${Nil}, ${Nulo}
@example
AddDedExpl( aParametro, @oModelPeri, oModelGrup, @cLogAvisos )
/*/Static Function AddDedExpl( aParametro, oModelPeri, oModelGrup, cLogAvisos )

Local cIdECFDedu	as character
Local nDeducao	as numeric
Local nIndice		as numeric
Local nIndiceDed	as numeric
Local nProporcao	as numeric
Local nPerPropor	as numeric
Local nImposto	as numeric
Local nAdicional	as numeric
Local nIsentoRed	as numeric
Local nPerRed		as numeric
Local nValorIte	as numeric
Local nLucroReal	as numeric
Local nAdicionIR	as numeric
Local aDeducao	as array

cIdECFDedu	:=	""
nDeducao	:=	0
nIndice	:=	0
nIndiceDed	:=	0
nProporcao	:=	0
nPerPropor	:=	0
nImposto	:=	0
nAdicional	:=	0
nIsentoRed	:=	0
nPerRed	:=	0
nValorIte	:=	0
nLucroReal	:=	VlrLucReal( aParametro )
nAdicionIR	:=	VlrAdiciIR( aParametro )
aDeducao	:=	{ { 0, "" } }

If nLucroReal <> 0 .and. aParametro[ GRUPO_RECEITA_LIQUIDA_ATIVIDA ] <> 0

	For nIndice := 1 To Len( aParametro[ ITENS_PROPORCAO_DO_LUCRO ] )
		nValorIte	:= aParametro[ ITENS_PROPORCAO_DO_LUCRO ][ nIndice ][ VALOR ]
		
		//Reinicia os valores
		nIsentoRed := 0
		nPerRed := 0
		cIdECFDedu	:= aParametro[ ITENS_PROPORCAO_DO_LUCRO ][ nIndice ][ ID_TABELA_ECF_DED ]

		nPerPropor := nValorIte / aParametro[ GRUPO_RECEITA_LIQUIDA_ATIVIDA ]
		
		nProporcao := aParametro[ GRUPO_LUCRO_EXPLORACAO ] * nPerPropor
		
		If aParametro[ ITENS_PROPORCAO_DO_LUCRO ][ nIndice ][ PROUNI ] == PROUNI_SIM
			nProporcao := nProporcao * aParametro[ POEB ]
		EndIf
		
		//Adiciona a porporção no detalhamento do periodo
		AddDetalhe( @oModelPeri, aParametro[ ITENS_PROPORCAO_DO_LUCRO ][ nIndice ][ ORIGEM ],;
		GRUPO_RECEITA_LIQUIDA_ATIVIDA, nProporcao, , aParametro[ ITENS_PROPORCAO_DO_LUCRO ][ nIndice ][ ID_TABELA_ECF ], aParametro[ ITENS_PROPORCAO_DO_LUCRO, nIndice, PROPORCAO_SEQITE ], @cLogAvisos )
		
		//Não calcular para demais atividades
		nImposto := nProporcao * aParametro[ ALIQUOTA_IMPOSTO ]
		
		//Não calcular para demais atividades
		If nLucroReal < aParametro[ GRUPO_LUCRO_EXPLORACAO ]
			nAdicional := ( nValorIte * nAdicionIR ) / aParametro[ GRUPO_RECEITA_LIQUIDA_ATIVIDA ]
		Else
			nAdicional := ( nProporcao * nAdicionIR ) / nLucroReal
		EndIf
		
		Do Case
			Case aParametro[ ITENS_PROPORCAO_DO_LUCRO ][ nIndice ][ TIPO_ATIVIDADE ] == ATIVIDADE_ISENCAO
				nIsentoRed := nImposto + nAdicional
			Case aParametro[ ITENS_PROPORCAO_DO_LUCRO ][ nIndice ][ TIPO_ATIVIDADE ] == ATIVIDADE_REDUCAO
				nPerRed := aParametro[ ITENS_PROPORCAO_DO_LUCRO ][ nIndice ][ PERCENTUAL_REDUCAO ] / 100
				nIsentoRed := ( nImposto + nAdicional ) * nPerRed
		EndCase
		
		//Totaliza a dedução por código ECF Necessário para a CSLL
		nIndiceDed := aScan( aDeducao, { |x| x[ 2 ] == cIdECFDedu } )
		If nIndiceDed > 0
			aDeducao[ nIndiceDed ][ 1 ] += nIsentoRed
		Else
			Aadd( aDeducao, { nIsentoRed, cIdECFDedu } )
		EndIf
	Next nIndice
EndIf

//Adiciona os itens de dedução do lucro da exploração
For nIndiceDed := 1 To Len( aDeducao )
	If Empty( aDeducao[ nIndiceDed ][ 2 ] )
		AddDetalhe( @oModelPeri, ORIGEM_EVENTO_TRIBUTARIO, GRUPO_DEDUCOES_TRIBUTO, aDeducao[ nIndiceDed ][ 1 ],, oModelGrup:GetValue( "T0O_IDECF" ),;
		 oModelGrup:GetValue( "T0O_SEQITE" ), @cLogAvisos )
	Else
		AddDetalhe( @oModelPeri, ORIGEM_EVENTO_TRIBUTARIO, GRUPO_DEDUCOES_TRIBUTO, aDeducao[ nIndiceDed ][ 1 ],, aDeducao[ nIndiceDed ][ 2 ],;
		 oModelGrup:GetValue( "T0O_SEQITE" ), @cLogAvisos )
	EndIf
	
	aParametro[ GRUPO_DEDUCOES_TRIBUTO ] += aDeducao[ nIndiceDed ][ 1 ]
	
Next nIndiceDed

Return()

/*/{Protheus.doc} PropoLucro
Alimenta os itens da proporção do lucro do evento relacionado
@author david.costa
@since 08/11/2016
@version 1.0
@param aParametro, ${param_type}, Passar por referência o array com os pametros para a apuração
@param oModelGrup, objeto, Objeto FWFormModel() do cadastro do Evento posicionado no Grupo a ser apurado
@param nValItem, numérico, Valor do item da proporção
@return ${return}, ${return_description}
@example
PropoLucro( @aParametro, oModelGrup, nValItem )
/*/Static function PropoLucro( aParametro, oModelGrup, nValItem )

Local cProUni		as character
Local cAtivid		as character
Local cOrigem		as character
Local cIdEcf		as character
Local cIdEcfCSLL	as character
Local nPerRed		as numeric
Local cSeqIte		as character

cProUni	:=	oModelGrup:GetValue( "T0O_PROUNI" )
cAtivid	:=	oModelGrup:GetValue( "T0O_ATIVID" )
cOrigem	:=	oModelGrup:GetValue( "T0O_ORIGEM" )
cIdEcf		:=	oModelGrup:GetValue( "T0O_IDTDEX" )
cIdEcfCSLL	:=	GetTDCSLL( aParametro, oModelGrup:GetValue( "T0O_CODECF" ) )
nPerRed	:=	oModelGrup:GetValue( "T0O_PERRED" )
cSeqIte	:=	oModelGrup:GetValue( "T0O_SEQITE" )

aAdd( aParametro[ ITENS_PROPORCAO_DO_LUCRO ], { cProUni, nPerRed, cAtivid, nValItem, cIdEcf, cOrigem, cIdEcfCSLL, cSeqIte } )

Return()

/*/{Protheus.doc} ApuLanManu
Apura os lançamentos manuais de um determinado grupo do período de apuração
@author david.costa
@since 14/10/2016
@version 1.0
@param oModelPeri, objeto, Passar por referência o objeto FWFormModel() do cadastro do período
@param oModelEven, objeto, Objeto FWFormModel() do cadastro do Evento Tributário
@param nIdGrupo, numérico, Id do grupo que será apurado
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param cLogAvisos, character, Log de avisos do processo
@param lRural, Logical, Indica se o item é da atividade Rural
@return ${nTotLanMan}, ${Total apurado}
@example
ApuLanManu( @oModelPeri, oModelEven, aGrupo[ PARAM_GRUPO_ID ], aParametro, @cLogAvisos, lRural )
/*/Static Function ApuLanManu( oModelPeri, oModelEven, nIdGrupo, aParametro, cLogAvisos, lRural )

Local oModelLanM	as object
Local dInicioPer	as date
Local nTotLanMan	as numeric
Local nIndiceLaM	as numeric
Local nValDetalh	as numeric

oModelLanM	:=	Nil
dInicioPer	:=	Nil
nTotLanMan	:=	0
nIndiceLaM	:=	0
nValDetalh	:=	0

//Para o Grupo Compensação do Tributo a data inicial sempre será a do período em processamento
If nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
	dInicioPer := oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" )
Else
	dInicioPer := aParametro[ INICIO_PERIODO ]
EndIf

oModelLanM := oModelEven:GetModel( "MODEL_LEC" )

For nIndiceLaM := 1 to oModelLanM:Length()
	oModelLanM:GoLine( nIndiceLaM )
	
	If !oModelLanM:IsDeleted() .and. nIdGrupo == Val( oModelLanM:GetValue( "LEC_CODGRU" ) ) .and. ;
		oModelLanM:GetValue( "LEC_DATA" ) >=  dInicioPer .and. ;
		oModelLanM:GetValue( "LEC_DATA" ) <=  oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" )
		
		nValDetalh := oModelLanM:GetValue( "LEC_VALOR" )
		nTotLanMan += nValDetalh := Iif( oModelLanM:GetValue( "LEC_TPOPER" ) == OPERACAO_SUBTRACAO, nValDetalh * -1, nValDetalh )
		AddDetalhe( @oModelPeri, ORIGEM_LANCAMENTO_MANUAL, nIdGrupo, nValDetalh, oModelLanM:GetValue( "LEC_IDCODL" ), oModelLanM:GetValue( "LEC_IDCODE" ),;
		 oModelLanM:GetValue( "LEC_CODLAN" ), @cLogAvisos, lRural )
		
	EndIf
Next nIndiceLaM

Return( nTotLanMan )

/*/{Protheus.doc} ApuContLAL
Apura uma conta da parte B do Lalur conforme os parâmetros do Item do Evento
@author david.costa
@since 14/10/2016
@version 1.0
@param oModelPeri, objeto, Objeto FWFormModel() do cadastro do período
@param cSeqIte, character, Sequencial do item do Evento ("T0O_SEQITE")
@param cLogErros, character, Passar por referência o Log de Validação do processo
@param nIdGrupo, numérico, Id do grupo que será apurado
@param nTipoApurC, numérico, Tipo de Apuração que será utilizado para calcular os valores
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param cIdEvento, character, Identificador do Evento
@return ${nValorApur}, ${Valor Apurado}
/*/Static Function ApuContLAL( oModelPeri, oModelGrup, cLogErros, nIdGrupo, aParametro, cIdEvento, lRural )

Local cAliasQry		as character
Local cSelect		as character
Local cFrom			as character
Local cWhere		as character
Local cGroupBy		as character
Local cSeqIte		as character
Local cCodLalur		as character
Local cTipoApurC	as character
Local dInicioPer	as date
Local nValorApur	as numeric
Local nDebitos		as numeric
Local nCreditos		as numeric

cAliasQry	:=	GetNextAlias()
cSelect		:=	""
cFrom		:=	""
cWhere		:=	""
cGroupBy	:=	""
dInicioPer	:=	Nil
nValorApur	:=	0
nDebitos	:=	0
nCreditos	:=	0
cSeqIte		:= oModelGrup:GetValue( "T0O_SEQITE" )
cTipoApurC	:= oModelGrup:GetValue( "T0O_TIPOCC" )
cCodLalur	:= alltrim(oModelGrup:GetValue('T0O_CODLAL'))

//Para o Grupo Compensação do Tributo a data inicial sempre será a do período em processamento
If nIdGrupo == GRUPO_COMPENSACAO_TRIBUTO
	dInicioPer := oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" )
Else
	dInicioPer := aParametro[ INICIO_PERIODO ]
EndIf

cSelect := "SUM(T0T.T0T_VLLANC) T0T_VLLANC "
cSelect += "	,T0T.T0T_TPLANC "
cSelect += "	,T0S.T0S_NATURE "

cFrom := RetSqlName('T0N') + " T0N "
cFrom += "JOIN " + RetSqlName('T0O') + " T0O ON T0O.T0O_FILIAL = T0N.T0N_FILIAL "
cFrom += "	AND T0O.T0O_ID = T0N.T0N_ID "
cFrom += "	AND T0O.D_E_L_E_T_ = ' ' "
cFrom += "	AND T0O.T0O_SEQITE = '" + cSeqIte + "'
cFrom += "	AND T0O.T0O_IDGRUP = " + Str( nIdGrupo )
cFrom += "JOIN " + RetSqlName('C1E') + " C1E ON C1E.C1E_CODFIL = T0O.T0O_FILITE "
cFrom += "	AND C1E.C1E_ATIVO != '2' "
cFrom += "	AND C1E.D_E_L_E_T_ = ' ' "
cFrom += "JOIN " + RetSqlName('T0T') + " T0T ON T0T.T0T_FILIAL = C1E_FILTAF "
cFrom += "	AND T0T.T0T_IDCODT = T0N.T0N_IDTRIB "
cFrom += "	AND T0T.T0T_ID = T0O.T0O_IDPARB "
cFrom += "	AND T0T.D_E_L_E_T_ = ' ' "
cFrom += "	AND T0T.T0T_DTLANC BETWEEN '" + DTOS( dInicioPer ) + "' AND '" + DTOS( aParametro[ FIM_PERIODO ] ) + "' "
//Para esses códigos lalur o calculo é feito utilizando somente os lancamentos manuais
if cCodLalur $ 'M300A15|M350A15|M300A102|M350A102'
	cFrom		+= " AND T0T.T0T_ORIGEM = '" + ORIGEM_MANUAL + "' "
endif	
//se tem atividade rural. 
cFrom += iif(lRural, " AND T0T.T0T_RURAL = '1' ", "	AND ( T0T.T0T_RURAL = '0' OR T0T.T0T_RURAL = ' ' )"  )
cFrom += "JOIN " + RetSqlName('T0S') + " T0S ON T0T.T0T_FILIAL = T0S.T0S_FILIAL "
cFrom += "	AND T0T.T0T_ID = T0S.T0S_ID "
cFrom += "	AND T0S.D_E_L_E_T_ = ' ' "

cWhere += "T0N.D_E_L_E_T_ = ' ' "
cWhere += "	AND T0N.T0N_ID = '" + cIdEvento + "' "
cWhere += "	AND T0N.T0N_FILIAL = '" + xFilial('T0N') + "' "

cGroupBy :=  " T0T.T0T_TPLANC "
cGroupBy +=  " ,T0S.T0S_NATURE "	

cSelect	:= "%" + cSelect 		+ "%"
cFrom  	:= "%" + cFrom   		+ "%"
cWhere  := "%" + cWhere  		+ "%"
cGroupBy:= "%" + cGroupBy		+ "%"

BeginSql Alias cAliasQry
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	GROUP BY
		%Exp:cGroupBy%
EndSql

//Filtro para Debitos
Set Filter To ( cAliasQry )->T0T_TPLANC = TIPO_LANC_DEBITO
( cAliasQry )->( DbGoTop() )

If ( cAliasQry )->( !Eof() )
	nDebitos := ( cAliasQry )->T0T_VLLANC
EndIf

//Filtro para Créditos
Set Filter To ( cAliasQry )->T0T_TPLANC = TIPO_LANC_CREDITO
( cAliasQry )->( DbGoTop() )

If ( cAliasQry )->( !Eof() )
	nCreditos := ( cAliasQry )->T0T_VLLANC
EndIf

//Limpa o Filtro
Set Filter To
( cAliasQry )->( DbGoTop() )

If cTipoApurC == TIPO_DEBITO
	nValorApur := nDebitos
ElseIf cTipoApurC == TIPO_CREDITO
	nValorApur := nCreditos
ElseIf cTipoApurC == TIPO_MOVIMENTACAO_CONTA
	nValorApur := nCreditos - nDebitos
EndIf

Return( nValorApur )

/*/{Protheus.doc} AddDetalhe
Adiciona um detalhe da apuração no cadastro do período
@author david.costa
@since 14/10/2016
@version 1.0
@param oModelPeri, objeto, Passar por referência o objeto FWFormModel() do cadastro do período
@param cOrigem, character, Origem do Detalhe
@param nIdGrupo, numérico, Id do grupo que será apurado
@param nValor, numérico, Valor do detalhe
@param cIdLALUR, character, Id. de referência a tabela dinamica da ECF especifico para o M300
@param cIDECF, character, Id. de referência a tabela dinamica da ECF demais códigos
@param cSeqIte, character, Sequencial do item do Evento Tributário
@param cLogAvisos, character, Log de Avisos do processo
@param lRural, Logical, Indica se o item é da atividade Rural
@return ${nSeqDetalh}, ${Sequencial do detalhe inserido}
/*/Function AddDetalhe( oModelPeri, cOrigem, nIdGrupo, nValor, cIdLALUR, cIDECF, cSeqIte, cLogAvisos, lRural )

Local oModelDeta	as object
Local nSeqDetalh	as numeric

Default cSeqIte		:=	""
Default cLogAvisos	:=	""
Default lRural		:= .F.

oModelDeta	:=	Nil
nSeqDetalh	:=	1

//Itens zerados não interferem na apuração e não precisam ser gravados
If nValor <> 0
	oModelDeta := oModelPeri:GetModel( "MODEL_CWX" )
	
	//Tratamento para o primeiro registro
	nSeqDetalh := Iif( oModelDeta:Length() == 1 .and. Empty( oModelDeta:GetValue( "CWX_ORIGEM" ) ), nSeqDetalh, oModelDeta:AddLine() )
	
	oModelDeta:LoadValue( "CWX_ORIGEM", cOrigem )
	oModelDeta:LoadValue( "CWX_IDCODG", XFUNCh2ID( StrZero( nIdGrupo, 2) , 'LEE' , 2 ) )
	oModelDeta:LoadValue( "CWX_VALOR", nValor )
	oModelDeta:LoadValue( "CWX_IDLAL", cIdLALUR )
	oModelDeta:LoadValue( "CWX_IDECF", cIDECF )
	oModelDeta:LoadValue( "CWX_SEQDET", StrZero( nSeqDetalh, 6 ) )
	oModelDeta:LoadValue( "CWX_SEQITE", cSeqIte )
	oModelDeta:LoadValue( "CWX_RURAL", Iif( lRural, "1", "0" ) )
	oModelDeta:lValid := .T.
	
	If Empty( cIdLALUR ) .and. Empty( cIDECF )
		AddLogErro( STR0169, @cLogAvisos, { StrZero( nSeqDetalh, 6 ) } ) // "O Item @1 do detalhamento da apuração está com o código da Tabela Dinâmica da ECF em branco"
	EndIf
EndIf

Return( nSeqDetalh )

/*/{Protheus.doc} ApuraContC
Apura uma conta contábil conforme os parâmetros do Item do Evento
@author david.costa
@since 14/10/2016
@version 1.0
@param oModelPeri, objeto, Objeto FWFormModel() do cadastro do período
@param oModelGrup, objeto, Objeto FWFormModel() do cadastro do Evento posicionado no Grupo a ser apurado
@param cLogErros, character, Passar por referência o Log de Validação do processo
@param aGrupo, array, Array com os parâmetros do Grupo do Item do Evento
@param oModelEven, objeto, Objeto FWFormModel() do cadastro do Evento Tributário
@param aParametro, ${param_type}, Array com os pametros para a apuração
@return ${nValorApur}, ${Valor Apurado}
@example
ApuraContC( oModelPeri, oModelGrup, @cLogErros, aGrupo, oModelEven, aParametro )
/*/Static Function ApuraContC( oModelPeri, oModelGrup, cLogErros, aGrupo, oModelEven, aParametro, aItemsEvt )

Local cAliasQry	as character
Local nValorApur	as numeric
Local nDebitos	as numeric
Local nCreditos	as numeric
Local dInicioPer	as date

Default aItemsEvt := {}
cAliasQry	:=	""
nValorApur	:=	0
nDebitos	:=	0
nCreditos	:=	0
dInicioPer	:= Nil

If aGrupo[ PARAM_GRUPO_ID ] == GRUPO_COMPENSACAO_TRIBUTO
	dInicioPer := oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" )
Else
	dInicioPer := aParametro[ INICIO_PERIODO ]
EndIf

//Seleciona os dados da conta conforme definido no item tributário
cAliasQry := GetDadosCta( dInicioPer, oModelGrup, oModelEven, aGrupo, aParametro,/*6*/, @aItemsEvt )

//Filtro para Debitos
Set Filter To ( cAliasQry )->CHB_INDNAT = TIPO_DEBITO
( cAliasQry )->( DbGoTop() )

While ( cAliasQry )->( !Eof() )
	nDebitos += ( cAliasQry )->CHB_VLPART
	( cAliasQry )->( DbSkip() )
EndDo

//Limpa o Filtro
Set Filter To

//Filtro para Créditos
Set Filter To ( cAliasQry )->CHB_INDNAT = TIPO_CREDITO
( cAliasQry )->( DbGoTop() )

While ( cAliasQry )->( !Eof() )
	nCreditos += ( cAliasQry )->CHB_VLPART
	( cAliasQry )->( DbSkip() )
EndDo

//Limpa o Filtro
Set Filter To
( cAliasQry )->( DbGoTop() )

If oModelGrup:GetValue( "T0O_TIPOCC" ) == TIPO_DEBITO
	nValorApur := nDebitos
ElseIf oModelGrup:GetValue( "T0O_TIPOCC" ) == TIPO_CREDITO
	nValorApur := nCreditos
Else //Movimentação do Período ou Saldo Anterior ou Saldo Atual
	If ( cAliasQry )->C1O_NATURE == NATUREZA_TIPO_DEVEDORA
		nValorApur := nDebitos - nCreditos
	Else
		nValorApur := nCreditos - nDebitos
	EndIf
EndIf

(cAliasQry)->(DbCloseArea())

Return( nValorApur )

/*/{Protheus.doc} GetDadosCta
Seleciona os dados da Conta conforme definido no item do evento
@author david.costa
@since 14/10/2016
@version 1.0
@param dInicioPer, date, Data iniicial do período
@param oModelGrup, objeto, Objeto FWFormModel() do cadastro do Evento posicionado no Grupo a ser apurado
@param oModelEven, objeto, Objeto FWFormModel() do cadastro do Evento Tributário
@param aGrupo, array, Array com os parâmetros do Grupo do Item do Evento
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param lNumLan, lógico, Indica que a busca precisa agrupar pelo numero do lancamento
@return ${cAliasQry}, ${Alias com os dados selecionados}
@example
GetDadosCta( dInicioPer, oModelGrup, oModelEven, aGrupo, aParametro, lNumLan )
/*/Static Function GetDadosCta( dInicioPer, oModelGrup, oModelEven, aGrupo, aParametro, lNumLan, aItemsEvt )

Local oModelHist	as object
Local cFiltro		as character
Local cIdHistIN		as character
Local cIdHistNOT	as character
Local cQuery		as character
Local cAux			as character
Local cCompC1O		as character
Local cAliasQry		as character
Local cAliasTemp	as character
Local cInformix		as character
Local nIteHistor	as numeric
Local aInfoEUF		as array
Local aFields		as array
Local oTemp			as object
Local cEmpAtu		as character
Local cChav         as character
Local nPos 		    as numeric

Default lNumLan   := .F.
Default aItemsEvt := {}

cCompC1O	:= Upper(AllTrim(FWModeAccess("C1O",1)+FWModeAccess("C1O",2)+FWModeAccess("C1O",3)))
cCompCHB	:= Upper(AllTrim(FWModeAccess("CHB",1)+FWModeAccess("CHB",2)+FWModeAccess("CHB",3)))
aInfoEUF 	:= TamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))

cEmpAtu := Iif (aInfoEUF[1]>0,SUBSTR(oModelGrup:GetValue( "T0O_FILIAL" ),1,aInfoEUF[1]),oModelGrup:GetValue( "T0O_FILIAL" ))

oModelHist	:=	Nil
cFiltro		:=	""
cIdHistIN	:=	""
cIdHistNOT	:=	""
cQuery		:=	""
cAux		:=  ""
cAliasQry	:=	GetNextAlias()
nIteHistor	:=	0
aFields		:= {}
oTemp		:= Nil
cAliasTemp	:= ""
cNewAlias	:= GetNextAlias()
cInformix	:= TcGetDb() 

/*Monta o Filtro da Sentença*/

//só serão consideradas contas criadas antes do fim do período
cFiltro := " C1O_DTCRIA <= '" + DTOS( aParametro[ FIM_PERIODO ] ) + "' "

//Apenas contas Analiticas serão consideradas
cFiltro += " AND C1O_INDCTA = '1'"

If oModelGrup:GetValue( "T0O_TIPOCC" ) == TIPO_SALDO_ANTERIOR
	cFiltro += " AND CFS_DTLCTO < '" + DTOS( dInicioPer ) + "' "
ElseIf oModelGrup:GetValue( "T0O_TIPOCC" ) == TIPO_SALDO_ATUAL
	cFiltro += " AND CFS_DTLCTO <= '" + DTOS( aParametro[ FIM_PERIODO ] ) + "' "
Else //Movimentação do Período ou Débito ou Crédito
	cFiltro += " AND CFS_DTLCTO BETWEEN '" + DTOS( dInicioPer ) + "' AND '" + DTOS( aParametro[ FIM_PERIODO ] ) + "' "
EndIf

//Filtra pelo Centro de Custo
If !Empty( oModelGrup:GetValue( "T0O_IDCUST" ) )
	cFiltro += " AND CHB_CODCUS = '" + oModelGrup:GetValue( "T0O_IDCUST" ) + "' "
EndIf

oModelHist := oModelEven:GetModel( "MODEL_T0R_" + aGrupo[ PARAM_GRUPO_NOME ] )

//Filtra pelo Histórico Padrão
For nIteHistor := 1 to oModelHist:Length()
	oModelHist:GoLine( nIteHistor )

	If !oModelHist:IsDeleted() .and. !Empty( oModelHist:GetValue( 'T0R_IDHIST' ) )
		If oModelHist:GetValue( 'T0R_ACAO' ) == HISTORICO_CONSIDERA
			cIdHistIN += "'" + oModelHist:GetValue( 'T0R_IDHIST' ) + "'"
		Else
			cIdHistNOT += "'" + oModelHist:GetValue( 'T0R_IDHIST' ) + "'"
		EndIf
	EndIf
Next nIteHistor

If !Empty( cIdHistIN )
	cFiltro += " AND CHB_IDCODH IN (" + StrTran( cIdHistIN, "''", "','" ) + ") "
EndIf

If !Empty( cIdHistNOT )
	cFiltro += " AND CHB_IDCODH NOT IN (" + StrTran( cIdHistNOT, "''", "','" ) + ") "
EndIf

/*Monta a Sentença
 Esta senteça fará uma busca em árvore para encontrar as contas analiticas envolvidas 
 e totalizará pelo tipo dos lançamentos contabeis
*/
If cCompCHB <>"CCC" //Se for exclusivo pelo menos por empresa, o campo CHB_FILIAL ficará preenchido.
	If aInfoEUF[1] > 0 .And. !(cInformix $ "INFORMIX|ORACLE") 
		cFiltro += " AND SUBSTRING(CHB_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = '" + cEmpAtu + "'" 
	ElseIf aInfoEUF[1] > 0  .And. cInformix $ "INFORMIX|ORACLE" 
		cFiltro += " AND SUBSTR(CHB_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = '" + cEmpAtu + "'" 
	Endif
EndIf


If !(cInformix $ "INFORMIX")

	//Monta a árvore das Conta Contábeis envolvidas
	cQuery += " WITH " + iif(cInformix == 'POSTGRES', 'RECURSIVE','') + " TEMP_C1O (C1O_ID, C1O_FILIAL, C1O_INDCTA, C1O_DTCRIA, C1O_NATURE) " 
	cQuery += " AS ( "

Else
	//Tratativa realizada para que a função funcione no banco informix
	//pois o mesmo nao possui a clausula WITH TEMP usada no SQL
	//monta a estrutura dos campos utilizados na temptable 

	aAdd(aFields, {'C1O_ID',		'C', 	036,	0})
	aAdd(aFields, {'C1O_FILIAL',	'C', 	008,	0})
	aAdd(aFields, {'C1O_INDCTA',	'C', 	001,	0})
	aAdd(aFields, {'C1O_DTCRIA',	'C', 	008,	0})
	aAdd(aFields, {'C1O_NATURE',	'C', 	001,	0})
	aAdd(aFields, {'CHB_INDNAT',	'C', 	001,	0})
	aAdd(aFields, {'CHB_VLPART',	'N', 	008,	0})

	oTemp := FwTemporaryTable():New(cNewAlias,aFields)
	oTemp:AddIndex("1",{"C1O_ID","C1O_FILIAL","C1O_INDCTA","C1O_DTCRIA","C1O_NATURE", "CHB_INDNAT", "CHB_VLPART"})
	oTemp:Create()

	cAliasTemp:= oTemp:GetRealName()

	cQuery += " INSERT INTO " + cAliasTemp + " ( C1O_ID, C1O_FILIAL, C1O_INDCTA, C1O_DTCRIA, C1O_NATURE) "
EndIf


/*Seleciona a Conta Raiz da Árvore*/
cQuery += " SELECT C1O_ID, C1O_FILIAL, C1O_INDCTA, C1O_DTCRIA, C1O_NATURE "

If cInformix $ "INFORMIX"
	cQuery += " FROM( "
	cQuery += " SELECT C1O_ID, C1O_FILIAL, C1O_INDCTA, C1O_DTCRIA, C1O_NATURE "
EndIf

cQuery += " FROM " + RetSqlName( "C1O" ) + " C1O "

/*Tratamento devido alteracao de compartilhamento da tabela C1O - Plano Conta*/
cQuery += " JOIN " + RetSqlName( "C1E" ) + " C1E "
cQuery += " ON C1E_CODFIL = '" + oModelGrup:GetValue( "T0O_FILITE" ) + "' AND C1E.C1E_ATIVO != '2' AND C1E.D_E_L_E_T_= ' ' "
If cCompC1O == "EEE" //exclusivo
	cQuery += " AND C1O_FILIAL = C1E_FILTAF "
ElseIf cCompC1O == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 .And. !(cInformix $ "INFORMIX|ORACLE") //filial compartilhada EEC
	cQuery += " AND SUBSTRING(C1O_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(C1E_FILTAF, 1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
ElseIf cCompC1O == "ECC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 .And. !(cInformix $ "INFORMIX|ORACLE") //unidade + filial compartilhada ECC 
	cQuery += " AND SUBSTRING(C1O_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(C1E_FILTAF, 1," + cValToChar(aInfoEUF[1]) + ") "
ElseIf cCompC1O == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 .And. cInformix $ "INFORMIX|ORACLE" //filial compartilhada EEC
	cQuery += " AND SUBSTR(C1O_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTR(C1E_FILTAF, 1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
ElseIf cCompC1O == "ECC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 .And. cInformix $ "INFORMIX|ORACLE" //unidade + filial compartilhada ECC 
	cQuery += " AND SUBSTR(C1O_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTR(C1E_FILTAF, 1," + cValToChar(aInfoEUF[1]) + ") "
EndIf

cQuery += " WHERE C1O_ID = '" + oModelGrup:GetValue( "T0O_IDCC" ) + "' "
cQuery += " AND C1O.D_E_L_E_T_= ' ' "

cQuery += " UNION ALL "

//Monta a hierarquia da árvore (os galhos e folhas)
cQuery += " SELECT F.C1O_ID, F.C1O_FILIAL, F.C1O_INDCTA, F.C1O_DTCRIA, P.C1O_NATURE "

If !(cInformix $ "INFORMIX")
	cQuery += " FROM TEMP_C1O P "
Else
	cQuery += " FROM " +cAliasTemp+ " P "
EndIf

cQuery += " JOIN " + RetSqlName( "C1O" ) + " F " 
cQuery += " ON P.C1O_ID = F.C1O_CTASUP AND P.C1O_FILIAL = F.C1O_FILIAL AND F.D_E_L_E_T_= ' ' "
cQuery += " ) "

If cInformix $ "INFORMIX"

	TcSqlExec(cQuery) //execução do INSERT INTO

	cQuery := " UPDATE " +cAliasTemp 
	cQuery += " SET ( CHB_INDNAT, C1O_NATURE, CHB_VLPART ) = "
	cQuery += " ( ( SELECT CHB_INDNAT, C1O_NATURE , VLPART "
	if cInformix == 'INFORMIX'
		cQuery += " FROM ( SELECT CHB.CHB_INDNAT, NVL(T.C1O_NATURE, '0') C1O_NATURE, SUM(CHB.CHB_VLPART) VLPART "
	else
		cQuery += " FROM ( SELECT CHB.CHB_INDNAT, coalesce(T.C1O_NATURE, '0') C1O_NATURE, SUM(CHB.CHB_VLPART) VLPART "
	endif	
	cQuery += " FROM " +cAliasTemp+ " T "

Else

	cQuery += " SELECT SUM(CHB_VLPART) CHB_VLPART, CHB_INDNAT, C1O_NATURE @1 "
	cQuery += " FROM TEMP_C1O "

EndIf

/*Tratamento devido alteracao de compartilhamento da tabela C1O - Plano Conta*/
cAux += " JOIN " + RetSqlName( "CHB" ) + " CHB "
If cCompC1O == "EEE" //exclusivo
	cAux += " ON CHB_FILIAL = C1O_FILIAL "
ElseIf cCompC1O == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 .And. !(cInformix $ "INFORMIX|ORACLE") //filial compartilhada EEC
	cAux += " ON SUBSTRING(CHB_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(C1O_FILIAL, 1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") "
ElseIf cCompC1O == "ECC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 .And. !(cInformix $ "INFORMIX|ORACLE") //unidade + filial compartilhada ECC
	cAux += " ON SUBSTRING(CHB_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(C1O_FILIAL, 1," + cValToChar(aInfoEUF[1]) + ") "
ElseIf cCompC1O == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] = 0 // situação onde o SM0_LEIAUTE não possui Empresa nem Unidade e o compartilhamento por filial é compartilhado ( EEC )
	cAux += " ON CHB_CODCTA = C1O_ID AND CHB.D_E_L_E_T_= ' ' "
ElseIf cCompC1O == "ECC" .And. aInfoEUF[1] + aInfoEUF[2] = 0 // situação onde o SM0_LEIAUTE não possui Empresa nem Unidade e o compartilhamento por filial é compartilhado ( ECC )
	cAux += " ON CHB_CODCTA = C1O_ID AND CHB.D_E_L_E_T_= ' ' "
ElseIf cCompC1O == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 .And. cInformix $ "INFORMIX|ORACLE" //filial compartilhada EEC e banco informix
	cAux += " ON SUBSTR(CHB_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTR(C1O_FILIAL, 1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") "
ElseIf cCompC1O == "ECC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 .And. cInformix $ "INFORMIX|ORACLE" //unidade + filial compartilhada ECC e banco informix
	cAux += " ON SUBSTR(CHB_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTR(C1O_FILIAL, 1," + cValToChar(aInfoEUF[1]) + ") "
EndIf
if cCompC1O == "CCC" //Se compartilhado totalmente, mantem os filtros, exceto de filial.
	cAux += " ON CHB_CODCTA = C1O_ID AND CHB.D_E_L_E_T_= ' ' "
else //Se diferente de totalmente compartilhado, adiciona mais filtros alem da filial.
	cAux += " AND CHB_CODCTA = C1O_ID AND CHB.D_E_L_E_T_= ' ' "
endif

cAux += " JOIN " + RetSqlName( "CFS" ) + " CFS "
cAux += " ON CFS_FILIAL = CHB_FILIAL AND CFS_ID = CHB_ID AND CFS.D_E_L_E_T_= ' ' "

cAux += " WHERE " + cFiltro

cQuery += cAux

If !(cInformix $ "INFORMIX")
	
	cQuery += " GROUP BY CHB_INDNAT, C1O_NATURE @1 "

Else

	cQuery += " GROUP BY CHB.CHB_INDNAT, T.C1O_NATURE, CHB.CHB_VLPART ) ) ) "
	cQuery += " WHERE C1O_ID = '" + oModelGrup:GetValue( "T0O_IDCC" ) + "' "
	
	/* O FwTemporaryTable() cria os campos automaticamente como NOT NULL, devido a isso, o UPDATE	||
	|| pode gerar error no TcSqlError() se algum dos campos do UPDATE estiver null					*/

	TcSqlExec(cQuery) //Executa o UPDATE

	if cInformix == 'INFORMIX'
		cQuery := " SELECT NVL(CHB.CHB_INDNAT, '0') AS CHB_INDNAT, NVL(C1O_NATURE, '0') AS C1O_NATURE, NVL(CHB.CHB_VLPART, 0) AS CHB_VLPART "
	else
		cQuery := " SELECT coalesce(CHB.CHB_INDNAT, '0') AS CHB_INDNAT, coalesce(C1O_NATURE, '0') AS C1O_NATURE, coalesce(CHB.CHB_VLPART, 0) AS CHB_VLPART "
	endif	
	cQuery += " FROM " +cAliasTemp+ " T "
	cQuery += cAux

EndIf

If lNumLan
	cQuery := FormatStr( cQuery, { ", CFS_ID" } )
Else
	cQuery := FormatStr( cQuery, { "" } )
EndIf
cChav := oModelGrup:GetValue( "T0O_FILIAL" ) + oModelGrup:GetValue( "T0O_ID") //DTOS( dInicioPer ) + DTOS( aParametro[ FIM_PERIODO ] ) + oModelGrup:GetValue( "T0O_FILITE" ) + oModelGrup:GetValue( "T0O_ID")
nPos := aScan( aItemsEvt, cChav )
if nPos == 0
	aadd( aItemsEvt , cChav )
endif
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQry, .F., .T. )
( cAliasQry )->( DbGoTop() )

//Caso exista, exclui a tabela temporaria e fecha o alias.
if ValType(oTemp) == 'O'
	oTemp:delete()
endif

Return( cAliasQry )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author David Costa
@Since 23/09/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

//Periodos encerrados não serão salvos
If oModel:GetValue( "MODEL_CWV", "CWV_STATUS" ) == PERIODO_ENCERRADO
	ShowLog( STR0015, STR0048 )//"Atenção"; "O período encerrado não permite alterações."
Else
	FWFormCommit( oModel )
EndIf

Return( .T. )

/*/{Protheus.doc} AplDedComp
Aplica a Dedução/Compensação ao valor passado conforme as regras definidas no item do evento
@author david.costa
@since 14/10/2016
@version 1.0
@param nVlrDedCom, numérico, Passar por referência o valor no qual será aplicado o a dedução/compensação
@param oModelGrup, objeto, Objeto FWFormModel() do cadastro do Evento posicionado no Grupo a ser apurado
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param cLogErros, character, Passar por referência o Log de Validação do processo
@param aGrupo, array, Array com os dados do Grupo que será apurado
@param lSimula, lógico, Indica se o processamento é uma simulação ou apuração
@return ${Nil}, ${Nulo}
/*/Static Function AplDedComp( nVlrDedCom, oModelGrup, aParametro, cLogErros, aGrupo, lSimula )

Local cTpDedComp	as character
Local nVlrLimite	as numeric
Local nPerDedCom	as numeric
Local nBaseLimit	as numeric
Local cEfeito		as character

cTpDedComp	:=	xFunID2Cd( oModelGrup:GetValue( "T0O_IDLIDC" ), "T0L", 1 )
nVlrLimite	:=	0
nPerDedCom	:=	Iif( oModelGrup:GetValue( "T0O_PERDED" ) == 0, 1, oModelGrup:GetValue( "T0O_PERDED" ) / 100 )
nBaseLimit	:=	0
cEfeito 	:= oModelGrup:GetValue( "T0O_EFEITO" )

Do Case
	Case cTpDedComp == APL_RESULTADO_OPERACIONAL
		nBaseLimit := aParametro[ GRUPO_RESULTADO_OPERACIONAL ]
	Case cTpDedComp == APL_RESULTADO_NAO_OPERACIONAL
		nBaseLimit := aParametro[ GRUPO_RESULTADO_NAO_OPERACIONAL ]
	Case cTpDedComp == APL_RESULTADO_EXERCICIO
		nBaseLimit := VlrResCont( aParametro )
	Case cTpDedComp == APL_LUCRO_REAL_ANTES_COMP_PREJ
		nBaseLimit := VlrLRAntes( aParametro )
	Case cTpDedComp == APL_LUCRO_REAL
		nBaseLimit := VlrLucReal( aParametro )
	Case cTpDedComp == APL_BASE_X_ALIQUOTA
		nBaseLimit := VlrBCxAliq( aParametro )
	//Quando o campo estiver em branco não será aplicado limite
	OTHERWISE
		nBaseLimit := nVlrDedCom
EndCase

nVlrLimite := nBaseLimit * nPerDedCom

//Em caso de prejuízo o valor não será calculado
If nVlrLimite > 0
	//Se o item estiver configurado para gerar lançamento automatico a apuração irá ajustá-lo não sendo necessários apresentar log 
	If Round( nVlrDedCom, 2 ) > Round( nVlrLimite, 2 ) .and. cEfeito != EFEITO_INCLUIR_LANC_AUTOMATICO
		//"O item tributário @1 do grupo @2 gerou um valor acima do permitido. Valor calculado: @3 Valor permitido @4 ( @5% do @6 )"
		AddLogErro( STR0035, @cLogErros, { oModelGrup:GetValue( "T0O_SEQITE" ), aGrupo[ PARAM_GRUPO_DESCRICAO ], Round( nVlrDedCom, 2 ), ;
	 	Round( nVlrLimite, 2 ), ( nPerDedCom * 100 ), Round( nBaseLimit,2 ) } )
	ElseIf aGrupo[ PARAM_GRUPO_ID ] == GRUPO_COMPENSACAO_PREJUIZO 
		aParametro[ PERCENTUAL_COMP_PREJU ] := ( nPerDedCom * 100 )
	EndIf
Else
	nVlrDedCom := 0
EndIf

Return()

/*/{Protheus.doc} VlrLucReal
Calcula o valor do lucro real
VlrLRAntes( aParametro ) - aParametro[ GRUPO_COMPENSACAO_PREJUIZO ]
@author david.costa
@since 14/10/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param aParametr2, ${param_type}, Array com os pametros para a apuração
@return ${nRet}, ${Valor Calculado}
@example
VlrLucReal( aParametro )
/*/Function VlrLucReal( aParametro, aParametr2 )

Local nLucroReal	as numeric

Default aParametr2	:=	{}

nLucroReal	:=	0

//Evento Com atividade Rural
If Len( aParametr2 ) > 1
	nLucroReal := VlrBCParci( aParametro, aParametr2 )
	nLucroReal += VlrBCParci( aParametr2, aParametro )
Else
	nLucroReal := VlrLRAntes( aParametro )
	nLucroReal -= aParametro[ GRUPO_COMPENSACAO_PREJUIZO ]
EndIf

Return( nLucroReal )

/*/{Protheus.doc} VlrLRApoPj
Valor do Lucro Real após a compensação de prejuízo (com Atividade Rural)
@author david.costa
@since 02/02/2017
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param aParametr2, ${param_type}, Array com os pametros para a apuração
@return ${nLRApoPrej}, ${Valor do Lucro Real após a compensação de prejuízo}
@example
VlrLRApoPj( aParametro, aParRural )
/*/Function VlrLRApoPj( aParametro, aParametr2 )

Local nLRApoPrej	as numeric

nLRApoPrej	:=	0

nLRApoPrej := VlrLRAntes( aParametro )
nLRApoPrej -= aParametro[ VLR_PREJUIZO_COMP_NO_PERIODO ]
nLRApoPrej += aParametr2[ VLR_PREJUIZO_COMP_NO_PERIODO ]

Return( nLRApoPrej )

/*/{Protheus.doc} VlrBCParci
Valor da Base de cálculo parcial (com Atividade Rural)
@author david.costa
@since 02/02/2017
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param aParametr2, ${param_type}, Array com os pametros para a apuração
@return ${nBCParcial}, ${Valor da Base de cálculo parcial}
@example
VlrBCParci( aParametro )
/*/Function VlrBCParci( aParametro, aParametr2 )

Local nBCParcial	as numeric

nBCParcial	:=	0

nBCParcial := VlrLRApoPj( aParametro, aParametr2 )
nBCParcial -= aParametro[ GRUPO_COMPENSACAO_PREJUIZO ]

Return( nBCParcial )

/*/{Protheus.doc} VlrBCxAliq
Calcula o valor de Base x Aliquota
@author david.costa
@since 14/10/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param aParametr2, ${param_type}, Array com os pametros para a apuração
@return ${nRet}, ${Valor Calculado}
@example
VlrBCxAliq( aParametro )
/*/Function VlrBCxAliq( aParametro, aParametr2 )

Local nRet	as numeric

Default aParametr2	:=	{}

 nRet	:=	VlrLucReal( aParametro, aParametr2 ) * aParametro[ALIQUOTA_IMPOSTO]

Return( nRet )

/*/{Protheus.doc} VlrLRAntes
Calcula o Valor do Lucro Real antes da Compensação de Prejuízos
@author david.costa
@since 14/10/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@return ${nRet}, ${Valor Calculado}
@example
VlrLRAntes( aParametro )
/*/Function VlrLRAntes( aParametro )

Local nRet	as numeric

nRet	:=	0

nRet := VlrResCont( aParametro )
nRet += VlrAdicoes( aParametro )
nRet -= VlrExcluso( aParametro )
nRet += VlrDoacoes( aParametro )
nRet += aParametro [ GRUPO_BASE_CALCULO ]
nRet += VlrLucroEs( aParametro )
Return( nRet )

/*/{Protheus.doc} VlrLucroEs
Retorna o Valor do Lucro Estimado
@author david.costa
@since 25/01/2017
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@return ${nLucroEsti}, ${Valor do Lucro Estimado}
@example
VlrLucroEs( aParametro )
/*/Function VlrLucroEs( aParametro )

Local nLucroEsti	as numeric

nLucroEsti	:=	0

nLucroEsti := VlrReAliq1( aParametro )
nLucroEsti += VlrReAliq2( aParametro )
nLucroEsti += VlrReAliq3( aParametro )
nLucroEsti += VlrReAliq4( aParametro )
nLucroEsti += aParametro [ GRUPO_DEMAIS_RECEITAS ]

Return( nLucroEsti )

/*/{Protheus.doc} VlrReAliq1
Retorna o Valor para compor a BC conforme cálculo da da Atividade 1 
@author david.costa
@since 12/12/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@return ${nRet}, ${Valor Calculado}
@example
VlrReAliq1( aParametro )
/*/Function VlrReAliq1( aParametro )

Local nRet	as numeric

nRet	:=	( aParametro[GRUPO_RECEITA_BRUTA_ALIQ1] * aParametro[ALIQUOTA_RECEITA_1] )

Return( nRet )

/*/{Protheus.doc} VlrReAliq2
Retorna o Valor para compor a BC conforme cálculo da da Atividade 2
@author david.costa
@since 12/12/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@return ${nRet}, ${Valor Calculado}
@example
VlrReAliq2( aParametro )
/*/Function VlrReAliq2( aParametro )

Local nRet	as numeric

nRet	:=	( aParametro[GRUPO_RECEITA_BRUTA_ALIQ2] * aParametro[ALIQUOTA_RECEITA_2] )

Return( nRet )

/*/{Protheus.doc} VlrReAliq3
Retorna o Valor para compor a BC conforme cálculo da da Atividade 3
@author david.costa
@since 12/12/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@return ${nRet}, ${Valor Calculado}
@example
VlrReAliq3( aParametro )
/*/Function VlrReAliq3( aParametro )

Local nRet	as numeric

nRet	:=	( aParametro[GRUPO_RECEITA_BRUTA_ALIQ3] * aParametro[ALIQUOTA_RECEITA_3] )

Return( nRet )

/*/{Protheus.doc} VlrReAliq4
Retorna o Valor para compor a BC conforme cálculo da da Atividade 4
@author david.costa
@since 12/12/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@return ${nRet}, ${Valor Calculado}
@example
VlrReAliq4( aParametro )
/*/Function VlrReAliq4( aParametro )

Local nRet	as numeric

nRet	:=	( aParametro[GRUPO_RECEITA_BRUTA_ALIQ4] * aParametro[ALIQUOTA_RECEITA_4] )

Return( nRet )

/*/{Protheus.doc} VlrResCont
Retorna o resultado contábil ( ou Resultado do Exercicio ) do período
aParametro[ GRUPO_RESULTADO_NAO_OPERACIONAL ] + aParametro[ GRUPO_RESULTADO_OPERACIONAL ]
@author david.costa
@since 14/10/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@return ${nRet}, ${Valor Calculado}
@example
VlrResCont( aParametro )
/*/Function VlrResCont( aParametro )

Local nRet	as numeric

nRet	:=	aParametro[GRUPO_RESULTADO_NAO_OPERACIONAL] + aParametro[GRUPO_RESULTADO_OPERACIONAL]

Return( nRet )

/*/{Protheus.doc} AddLogErro
Função para tratar as mensagens de erros/validações do cadastro e seu processos
@author david.costa
@since 14/10/2016
@version 1.0
@param cTexto, character, Mensagem para o Log
@param cLog, character, Passar Log de Erro por referência
@param aParam, Array, Array com valores para sibstituir variavéis na mensagem, 
	as variaveis na mensagem deverão iniciar com @ seguido de um sequencial
	Exemplo: AddLogErro( "O valor @1 do campo @2 está incorreto", @cLog, { 38, "AAA_TESTES" } )
	A mensagem será gravada assim: "O valor 38 do campo AAA_TESTES está incorreto"
@return ${Nil}, ${Nulo}
@example
AddLogErro( "O valor @1 do campo @2 está incorreto", @cLog, { 38, "AAA_TESTES" } )
/*/Function AddLogErro( cTexto, cLog, aParam )

Default cLog	:=	""

cTexto := FormatStr( cTexto, aParam )

cLog += cTexto + CRLF
cLog += "-----------------------------------------------" + CRLF

Return()

/*/{Protheus.doc} FormatStr
Formata uma string conforme os parametros passados
@author david.costa
@since 22/12/2016
@version 1.0
@param cTexto, character, Mensagem para que será formatada
@param aParam, Array, Array com valores para sibstituir variavéis na mensagem, 
	as variaveis na mensagem deverão iniciar com @ seguido de um sequencial
@return ${cTexto}, ${Mensagem tratada}
@example
AddLogErro( "O valor @1 do campo @2 está incorreto", @cLog, { 38, "AAA_TESTES" } )
A mensagem será gravada assim: "O valor 38 do campo AAA_TESTES está incorreto"
/*/Static Function FormatStr( cTexto, aParam )

Local nIndice	as numeric

Default cTexto	:=	""
Default aParam	:=	{}

nIndice	:=	0

For nIndice := 1 To Len( aParam )
	If ValType( aParam[ nIndice ] ) == "N"
		aParam[ nIndice ] := Str( aParam[ nIndice ] )
	EndIf

	cTexto := StrTran( cTexto, "@" + AllTrim( Str( nIndice ) ), AllTrim( aParam[ nIndice ] ) )
Next nIndice

Return( cTexto )

/*/{Protheus.doc} VlrAdiciIR
Calcula o Adicional do IRPJ
@author david.costa
@since 19/10/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param aParametr2, ${param_type}, Array com os pametros para a apuração
@return ${nVlrAdicio}, ${Valor do Adicional de IR}
@example
VlrAdiciIR( aParametro )
/*/Function VlrAdiciIR( aParametro, aParametr2 )

Local nBaseAdici	as numeric
Local nVlrAdicio	as numeric

Default aParametr2	:=	{}

nBaseAdici	:=	0
nVlrAdicio	:=	0

If aParametro[ TIPO_TRIBUTO ] == TIPO_TRIBUTO_IRPJ
	
	nBaseAdici := VlrBCAdici( aParametro, aParametr2 )
	
	If nBaseAdici > 0
		nVlrAdicio := nBaseAdici * aParametro[ ALIQUOTA_IR_ADICIONAL_IMPOSTO ]
	EndIf
EndIf

Return( nVlrAdicio )

/*/{Protheus.doc} VlrProIRPJ
Retorna o Valor da Provisão de IRPJ
@author david.costa
@since 25/01/2017
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param aParametr2, ${param_type}, Array com os pametros para a apuração
@return ${nVlrProvis}, ${Valor da Provisão de IRPJ}
@example
VlrProIRPJ( aParametro )
/*/Function VlrProIRPJ( aParametro, aParametr2 )

Local nVlrProvis	as numeric

Default aParametr2	:=	{}

nVlrProvis	:=	VlrBCxAliq( aParametro, aParametr2 ) + VlrAdiciIR( aParametro, aParametr2 )

Return( nVlrProvis )

/*/{Protheus.doc} CalcBCEven
Calcula o Valor da Base de Cálculo do Evento
@author david.costa
@since 19/10/2016
@version 1.0
@param oModelPeri, objeto, Passar por referência o objeto FWFormModel() do cadastro do período
@param aGrupos, array, Array com os dados dos Grupos que serão considerados no cálculo
@param aParametro, ${param_type}, Passar por referência o array com os pametros para a apuração
@param oModelEven, objeto, Objeto FWFormModel() do cadastro do Evento Tributário
@param cLogErros, character, Passar por referência o Log de Validação do processo
@param cLogAvisos, character, Passar por referência o Log com Avisos sobre a execução do processo
@param lSimula, lógico, Indica se o processamento é uma simulação ou apuração
@param lRural, Logical, Indica se o item é da atividade Rural
@return ${Nil}, ${Nulo}
@example
CalcBCEven( @oModelPeri, aGrupos, @aParametro, oModelEven, @cLogErros, @cLogAvisos, lSimula, lRural )
/*/Static Function CalcBCEven( oModelPeri, aGrupos, aParametro, oModelEven, cLogErros, cLogAvisos, lSimula, lRural, lAutomato, aItemsEvt )

Local oModelDeta as object
Local nIdGrupo	 as numeric
Local nIndicGrup as numeric
Local nTotGrupo	 as numeric

Default lAutomato := .F.

oModelDeta := oModelPeri:GetModel( "MODEL_CWX" )
nIdGrupo   := 0
nIndicGrup := 0
nTotGrupo  := 0

//Calcula os Grupos da Base de Cálculo. Exceto o grupo de compensação de Prejuízo
For nIndicGrup := 1 to Len( aGrupos )
	If aGrupos[ nIndicGrup ][ PARAM_GRUPO_TIPO ] == TIPO_GRUPO_BASE_CALCULO .and. aGrupos[ nIndicGrup ][ PARAM_GRUPO_ID ] <> GRUPO_COMPENSACAO_PREJUIZO
		If !lSimula
			if !lAutomato
				oProcess:Inc2Progress( STR0045 + aGrupos[ nIndicGrup ][ PARAM_GRUPO_DESCRICAO ] )//"Apurando Grupo "
			endif
		EndIf
		aParametro[ aGrupos[ nIndicGrup ][ PARAM_GRUPO_ID ] ] := ApuraGrupo( @oModelPeri, oModelEven, @cLogErros, aGrupos[ nIndicGrup ], @cLogAvisos, aParametro,/*7*/,/*8*/, oModelEven:GetModel( "MODEL_T0O_" + aGrupos[ nIndicGrup, PARAM_GRUPO_NOME ] ), lSimula, lRural, @aItemsEvt )
	EndIf
Next nIndicGrup

Return()

/*/{Protheus.doc} VlrExcluso
Retorna o Valor das Exclusões
@author david.costa
@since 24/10/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@return ${nExlusoes}, ${Valor das Exclusões}
@example
VlrExcluso( aParametro )
/*/Function VlrExcluso( aParametro )

Local nExlusoes	as numeric

nExlusoes	:=	aParametro[GRUPO_EXCLUSOES_LUCRO] + aParametro[GRUPO_EXCLUSOES_RECEITA]

Return( nExlusoes )

/*/{Protheus.doc} VlrAdicoes
Retorna o valor das Adições
@author david.costa
@since 24/10/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@return ${nAdicoes}, ${valor das Adições}
@example
VlrAdicoes( aParametro )
/*/Function VlrAdicoes( aParametro )

Local nAdicoes	as numeric

nAdicoes	:=	aParametro[GRUPO_ADICOES_LUCRO]

Return( nAdicoes )

/*/{Protheus.doc} VlrDoacoes
Retorna o Valor das Adições por Doação
@author david.costa
@since 08/11/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@return ${nDoacoes}, ${Valor das Adições por Doação}
@example
VlrDoacoes( aParametro )
/*/Function VlrDoacoes( aParametro )

Local nDoacoes	as numeric

nDoacoes	:=	aParametro[GRUPO_ADICOES_DOACAO]

Return( nDoacoes )

/*/{Protheus.doc} VlrBCAdici
Retorna Valor da Base de Cálculo Adicional do IR
@author david.costa
@since 24/10/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param aParametr2, ${param_type}, Array com os pametros para a apuração
@return ${nBaseAdici}, ${Valor da Base de Cálculo Adicional do IR}
@example
VlrBCAdici( aParametro )
/*/Function VlrBCAdici( aParametro, aParametr2 )

Local nBaseAdici	as numeric

Default aParametr2	:=	{}

nBaseAdici	:=	0

nBaseAdici := VlrLucReal( aParametro, aParametr2 )
nBaseAdici -= VlrIsento( aParametro )

Return( nBaseAdici )

/*/{Protheus.doc} VlrIsento
Retorna o Valor Isento
@author david.costa
@since 25/01/2017
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@return ${nVlrIsento}, ${Valor da Parcela Isenta}
@example
VlrIsento( aParametro )
/*/Function VlrIsento( aParametro )

Local nVlrIsento	as numeric

nVlrIsento	:=	( aParametro[PARCELA_ISENTA] * ( DateDiffMonth( aParametro[INICIO_PERIODO], aParametro[FIM_PERIODO] ) + 1 ) )

Return( nVlrIsento )

/*/{Protheus.doc} CalcVlrAPg
Calcula o Valor à pagar para o período
@author david.costa
@since 24/10/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param cLogAvisos, character, Passar por referência o Log com Avisos sobre a execução do processo
@param oModelPeri, objeto, Objeto FWFormModel() do cadastro do período
@param lSimula, lógico, Indica se o processamento é uma simulação ou apuração
@param aParametr2, ${param_type}, Array com os pametros para a apuração
@param cFormaTrib, character, Forma de tributação do Evento Tributário
@return ${nVlrAPagar}, ${Valor à pagar}
@example
CalcVlrAPg( aParametro, @cLogAvisos, oModelPeri, lSimulacao )
/*/Function CalcVlrAPg( aParametro, cLogAvisos, oModelPeri, lSimulacao, aParametr2, cFormaTrib )

Local nVlrAPagar	as numeric

Default lSimulacao	:=	.F.
Default aParametr2	:=	{}

nVlrAPagar	:=	0
		
If VlrLucReal( aParametro, aParametr2 ) > 0
	//Base x Aliquota
	nVlrAPagar := VlrBCxAliq( aParametro, aParametr2 )
	//Aplica adicional de IR
	nVlrAPagar += VlrAdiciIR( aParametro, aParametr2 )
	//Aplica os adicionais do tributo
	nVlrAPagar += aParametro[ GRUPO_ADICIONAIS_TRIBUTO ]
	//Aplica Deduções
	nVlrAPagar -= aParametro[ GRUPO_DEDUCOES_TRIBUTO ]
	//Aplica Compensações
	nVlrAPagar -= aParametro[ GRUPO_COMPENSACAO_TRIBUTO ]
	//Subtrai o Valor devido em períodos anteriores
	nVlrAPagar -= aParametro[ VLR_DEVIDO_PERIODOS_ANTERIORES ]
	//Subtrai o Valor Pago em períodos anteriores
	nVlrAPagar -= aParametro[ VLR_PAGO_PERIODOS_ANTERIORES ]
Else
	//Apenas o Lucro Real pode gerar lançamento de prejuízo
	If cFormaTrib == TRIBUTACAO_LUCRO_REAL .and. VlrLucReal( aParametro, aParametr2 ) < 0 .and.;
	!lSimulacao .and. MsgYesNo( STR0075, STR0074 ) //"O Período gerou prejuízo. Deseja gerar um lançamento de prejuízo em uma conta do Lalur Parte B?";"Lançamento Automático"
		AddLanPrej( @cLogAvisos, oModelPeri, aParametro, aParametr2 )
	EndIf
	
	AddLogErro( STR0051, @cLogAvisos, { VlrLucReal( aParametro, aParametr2 ) } )//"A base de cálculo apurada no período foi @1 e por isso o imposto não pode ser calculado!"
	
EndIf

Return( Iif(nVlrAPagar>0,nVlrAPagar,0 ))

/*/{Protheus.doc} UpdVlrPeri
Atualiza os campos do Período com os valores calculados
@author david.costa
@since 24/10/2016
@version 1.0
@param oModelPeri, objeto, Passar por referência o objeto FWFormModel() do cadastro do período
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param cLogAvisos, character, Passar por referência o Log com Avisos sobre a execução do processo
@param lSimula, lógico, Indica se o processamento é uma simulação ou apuração
@param aParRural, ${param_type}, Array com os pametros para a apuração do Evento da Atividade Rural
@param cFormaTrib, character, Forma de tributação do Evento Tributário
@return ${Nil}, ${Nulo}
@example
UpdVlrPeri( @oModelPeri, aParametro, @cLogAvisos, lSimula )
/*/Static Function UpdVlrPeri( oModelPeri, aParametro, cLogAvisos, lSimula, aParRural, cFormaTrib )

If oModelPeri:HasField( "MODEL_CWV", "CWV_TOALQ1" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_TOALQ1", VlrReAliq1( aParametro ) )
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_TOALQ2" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_TOALQ2", VlrReAliq2( aParametro ) )
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_TOALQ3" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_TOALQ3", VlrReAliq3( aParametro ) )
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_TOALQ4" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_TOALQ4", VlrReAliq4( aParametro ) )
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_TOTISE" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_TOTISE", VlrLucReal( aParametro, aParRural ) )
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_TRIADI" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_TRIADI", aParametro[ GRUPO_ADICIONAIS_TRIBUTO ] )
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_DEDUCA" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_DEDUCA", aParametro[ GRUPO_DEDUCOES_TRIBUTO ] )
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_COMPEN" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_COMPEN", aParametro[ GRUPO_COMPENSACAO_TRIBUTO ] )
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_APAGAR" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_APAGAR", CalcVlrAPg( aParametro, @cLogAvisos, oModelPeri, lSimula, aParRural, cFormaTrib ) )
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_TOTDEM" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_TOTDEM", aParametro[ GRUPO_DEMAIS_RECEITAS ])
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_EXCLUS" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_EXCLUS", VlrExcluso( aParametro ) )
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_PERPRE" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_PERPRE", aParametro[ PERCENTUAL_COMP_PREJU ] )
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_VLPREJ" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_VLPREJ", aParametro[ GRUPO_COMPENSACAO_PREJUIZO ] )
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_OPERAC" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_OPERAC", aParametro[ GRUPO_RESULTADO_OPERACIONAL ] )
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_NAOOPE" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_NAOOPE", aParametro[ GRUPO_RESULTADO_NAO_OPERACIONAL ] ) 
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_ADICIO" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_ADICIO", VlrAdicoes( aParametro ) + VlrDoacoes( aParametro ) )
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_RCATIV" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_RCATIV", aParametro[ GRUPO_RECEITA_LIQUIDA_ATIVIDA ] )
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_LUCEXP" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_LUCEXP", aParametro[ GRUPO_LUCRO_EXPLORACAO ] )
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_TRIADI" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_TRIADI", aParametro[ GRUPO_ADICIONAIS_TRIBUTO ] )
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_POPERA" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_POPERA", aParametro[ VLR_PREJUIZO_OPERACIONAL ] )
EndIf

If oModelPeri:HasField( "MODEL_CWV", "CWV_PNAOOP" )
	oModelPeri:LoadValue( "MODEL_CWV", "CWV_PNAOOP", aParametro[ VLR_PREJUIZO_NAO_OPERACIONAL ] )
EndIf

Return()

/*/{Protheus.doc} LoadParam
Carrega os valores necessários para a apuração calcular o imposto
@author david.costa
@since 25/10/2016
@version 1.0
@param aParametro, ${param_type}, Passar por referência o array com os pametros para a apuração
@param oModelPeri, objeto, Objeto FWFormModel() do cadastro do período
@param oModelEven, objeto, Objeto FWFormModel() do cadastro do EventoTributário
@return ${Nil}, ${Nulo}
@example
LoadParam( @aParametro, oModelPeri )
/*/Function LoadParam( aParametro, oModelPeri, oModelEven )

aParametro := Nil
aParametro	:= Array( 36 )
Afill( aParametro, 0 )
aParametro[ ITENS_PROPORCAO_DO_LUCRO ] := {}
aParametro[ ALIQUOTA_IMPOSTO ] := oModelPeri:GetValue( "MODEL_CWV", "CWV_ALIQAP" ) / 100
aParametro[ INICIO_PERIODO ] := GetIniPer( oModelEven, oModelPeri )
aParametro[ FIM_PERIODO ] := oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" )
aParametro[ ALIQUOTA_RECEITA_1 ] := Iif( oModelPeri:HasField( "MODEL_CWV", "CWV_TOALQ1" ), oModelPeri:GetValue( "MODEL_CWV", "CWV_ALIQU1" ) / 100, 0 )
aParametro[ ALIQUOTA_RECEITA_2 ] := Iif( oModelPeri:HasField( "MODEL_CWV", "CWV_TOALQ2" ), oModelPeri:GetValue( "MODEL_CWV", "CWV_ALIQU2" ) / 100, 0 )
aParametro[ ALIQUOTA_RECEITA_3 ] := Iif( oModelPeri:HasField( "MODEL_CWV", "CWV_TOALQ3" ), oModelPeri:GetValue( "MODEL_CWV", "CWV_ALIQU3" ) / 100, 0 )
aParametro[ ALIQUOTA_RECEITA_4 ] := Iif( oModelPeri:HasField( "MODEL_CWV", "CWV_TOALQ4" ), oModelPeri:GetValue( "MODEL_CWV", "CWV_ALIQU4" ) / 100, 0 )
aParametro[ ALIQUOTA_IR_ADICIONAL_IMPOSTO ] := Iif( oModelPeri:HasField( "MODEL_CWV", "CWV_ALIQAD" ), oModelPeri:GetValue( "MODEL_CWV", "CWV_ALIQAD" ) / 100, 0 )
aParametro[ PARCELA_ISENTA ] := Iif( oModelPeri:HasField( "MODEL_CWV", "CWV_VLISEN" ), oModelPeri:GetValue( "MODEL_CWV", "CWV_VLISEN" ), 0 )
aParametro[ TIPO_TRIBUTO ] := GetTpTribu( oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ) )
aParametro[ POEB ] := oModelPeri:GetValue( "MODEL_CWV", "CWV_POEB" )

Return()

/*/{Protheus.doc} CalcPrejOp
Calcula o valor do prejuízo operacional
@author david.costa
@since 09/11/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param aParametr2, ${param_type}, Array com os pametros para a apuração
@return ${nPrejOpe}, ${valor do prejuízo operacional}
@example
CalcPrejOp( aParametro )
/*/Function CalcPrejOp( aParametro, aParametr2 )

Local nPrejOpe	as numeric
Local nPrjFiscal	as numeric
Local nPrejNaoOp	as numeric

nPrejOpe	:=	0
nPrjFiscal	:=	0
nPrejNaoOp	:=	CalPrejNOp( aParametro, aParametr2 )

If VlrLRApoPj( aParametro, aParametr2 ) < 0
	nPrjFiscal := VlrLRApoPj( aParametro, aParametr2 ) * ( -1 )
	nPrejOpe := nPrjFiscal - nPrejNaoOp
EndIf

Return( nPrejOpe )

/*/{Protheus.doc} CalPrejNOp
Calcula o valor do prejuízo não operacional
@author david.costa
@since 09/11/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param aParametr2, ${param_type}, Array com os pametros para a apuração
@return ${nPrejNaoOp}, ${valor do prejuízo não operacional}
@example
CalPrejNOp( aParametro )
/*/Static Function CalPrejNOp( aParametro, aParametr2 )

Local nPrejNaoOp	as numeric
Local nPrjFiscal	as numeric
Local nResultNOp	as numeric

nPrejNaoOp	:=	0
nPrjFiscal	:=	0
nResultNOp	:=	0

/*
§ 5º A separação em prejuízos não operacionais e em prejuízos das demais atividades somente será exigida se, no período,
forem verificados, cumulativamente, resultados não operacionais negativos e lucro real negativo (prejuízo fiscal).
*/

If aParametro[ GRUPO_RESULTADO_NAO_OPERACIONAL ] < 0 .and. VlrLRApoPj( aParametro, aParametr2 ) < 0 .and.;
	aParametro[ TIPO_TRIBUTO ] == TIPO_TRIBUTO_IRPJ

	nResultNOp := aParametro[ GRUPO_RESULTADO_NAO_OPERACIONAL ] * ( -1 )
	nPrjFiscal := VlrLRApoPj( aParametro, aParametr2 ) * ( -1 )
	/*
	§ 6º Verificada a hipótese de que trata o parágrafo anterior, a pessoa jurídica deverá comparar o prejuízo não 
	operacional com o prejuízo fiscal apurado na demonstração do lucro real, observado o seguinte:
	a) se o prejuízo fiscal for maior, todo o resultado não operacional negativo será considerado prejuízo fiscal 
	não operacional e a parcela excedente será considerada, prejuízo fiscal das demais atividades;
	b) se todo o resultado não operacional negativo for maior ou igual ao prejuízo fiscal, todo o prejuízo fiscal 
	será considerado não operacional.
	*/
	If nResultNOp < nPrjFiscal
		nPrejNaoOp := nResultNOp
	Else
		nPrejNaoOp := nPrjFiscal
	EndIf
EndIf

Return( nPrejNaoOp )

/*/{Protheus.doc} GetIDTDECF
Retorna o ID do Item da Tabela Dinâmica da ECF
@author david.costa
@since 09/11/2016
@version 1.0
@param cTDECF, character, Código da Tabela Dinâmica da ECF
@param cCodItemTD, character, Código do item da Tabela Dinâmica da ECF
@return ${cIdTDECF}, ${ID do Item da Tabela Dinâmica da ECF}
@example
GetIDTDECF( "N600", "2" )
/*/Static Function GetIDTDECF( cTDECF, cCodItemTD )

Local cIdTDECF	as character

cIdTDECF	:=	""

DBSelectArea( "CH6" )
CH6->( DbSetOrder(2) )

If CH6->( MsSeek( xFilial( "CH6" ) + PadR( cTDECF, TamSX3( "CH6_CODREG" )[1] ) + cCodItemTD ) )
	cIdTDECF := CH6->CH6_ID
EndIf

Return( cIdTDECF )

/*/{Protheus.doc} GetTDCSLL
Retorna o Id da Tabela dinâmica na qual a dedução da receita do lucro da exploração deverá ser lançada.
Obs: Aplica-se somente à CSLL
@author david.costa
@since 09/11/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param cCodECF, character, Código da Tabela dinâmica da Receita da Atividade do lucro da exploração
@return ${cIdTDECF}, ${Id da Tabela dinâmica da dedução da CSLL}
@example
GetTDCSLL( aParametro, "73e67115-c4ac-2b8b-3bf9-77dcb6960e8f" )
/*/Static Function GetTDCSLL( aParametro, cCodECF )

Local cIdTDECF	as character

cIdTDECF	:=	""

/*
No caso da CSLL, como não são todas as atividades que possuem isenção da CSLL, o sistema irá realizar
os lançamentos nos registros N660 e N670 de forma fixa:
Se o Item do Evento Tributário estiver classificado com o Código N600.2, 
	a isenção será registrada com o código N660.5 para Estimativa e N670.8 para Lucro Real
Se o Item do Evento Tributário estiver classificado com o Código N600.6,
	a isenção será registrada com o código N660.6 para Estimativa e N670.9 para Lucro Real
Se o Item do Evento Tributário estiver classificado com o Código N600.7,
	a isenção será registrada com o código N660.7 para Estimativa e N670.10 para Lucro Real
Se o Item do Evento Tributário estiver classificado com o Código N600.8,
	a isenção será registrada com o código N660.8 para Estimativa e N670.11 para Lucro Real
Se o Item do Evento Tributário estiver classificado com o Código N600.9,
	a isenção será registrada com o código N660.9 para Estimativa e N670.12 para Lucro Real
*/

If aParametro[ TIPO_TRIBUTO ] == TIPO_TRIBUTO_CSLL
	Do Case
		Case "N600 2" $ cCodECF
			cIdTDECF := GetIDTDECF( "N670", "8" )
		Case "N600 6" $ cCodECF
			cIdTDECF := GetIDTDECF( "N670", "9" )
		Case "N600 7" $ cCodECF
			cIdTDECF := GetIDTDECF( "N670", "10" )
		Case "N600 8" $ cCodECF
			cIdTDECF := GetIDTDECF( "N670", "11" )
		Case "N600 9" $ cCodECF
			cIdTDECF := GetIDTDECF( "N670", "12" )
	End Case
EndIf

Return( cIdTDECF )

/*/{Protheus.doc} GetIniPer
Retorna a data inicial que deverá quer considerada para apuração da estimativa de balanço
@author david.costa
@since 02/12/2016
@version 1.0
@param oModelEven, objeto, Objeto FWFormModel() do cadastro do Evento Tributário
@param oModelPeri, objeto, Objeto FWFormModel() do cadastro do Período de Apuração
@return ${dIniPer}, ${Data Inicial para a Estimativa}
@example
GetIniPer( oModelEven, oModelPeri )
/*/Static Function GetIniPer( oModelEven, oModelPeri )

Local cAliasQry	as character
Local cSelect		as character
Local cFrom		as character
Local cWhere		as character
Local dIniPer		as date

cAliasQry	:=	GetNextAlias()
cSelect		:=	""
cFrom		:=	""
cWhere		:=	""
dIniPer	:=	Nil

//Se a forma de tributação for Estimativa por levantamento de balanço e o período for mensal, 
//o calculo deve ser realizado a partir do inicio do período anual ou do dia seguinte a um evento especial
If 	XFUNID2Cd( oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 ) == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .and. ;
	!oModelPeri:GetValue( "MODEL_CWV", "CWV_ANUAL" )
	
	cSelect	:= " CWU.CWU_DATA "
	cFrom		:= RetSqlName( "CWU" ) + " CWU "
	cWhere		:= " CWU.CWU_DATA BETWEEN '" + Dtos( FirstYDate( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ) ) + "' "
	cWhere		+= " 	AND '" + Dtos( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) + "' "
	cWhere		+= " AND CWU.D_E_L_E_T_ = '' "
	
	cSelect	:= "%" + cSelect 	+ "%"
	cFrom  	:= "%" + cFrom   	+ "%"
	cWhere 	:= "%" + cWhere  	+ "%"
			
	BeginSql Alias cAliasQry

		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
	EndSql
	
	DBSelectArea( cAliasQry )
	( cAliasQry )->( DbGoTop() )

	If ( cAliasQry )->( !( Eof() ) )
		dIniPer := DaySum( STod( ( cAliasQry )->CWU_DATA ), 1 )
	Else
			dIniPer := FirstYDate( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) )
	EndIf
Else
	dIniPer := oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" )
EndIf

Return( dIniPer )

/*/{Protheus.doc} VlrDeviMes
Retorna o valor do imposto devido no mês
@author david.costa
@since 25/01/2017
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param oModelPeri, objeto, Objeto FWFormModel() do cadastro do Período de Apuração
@param aParametr2, ${param_type}, Array com os pametros para a apuração
@param cFormaTrib, $caracter, Forma de tributação do Evento
@return ${nImpDevMes}, ${valor do imposto devido no mês}
@example
VlrDeviMes(  aParametro, oModelPeri  )
/*/Function VlrDeviMes( aParametro, oModelPeri, aParametr2, cFormaTrib )

Local nImpDevMes	as numeric

Default cFormaTrib	:=	""

nImpDevMes	:=	0

If aParametro[ TIPO_TRIBUTO ] == TIPO_TRIBUTO_IRPJ
	nImpDevMes := VlrProIRPJ( aParametro, aParametr2 )
Else
	nImpDevMes := VlrBCxAliq( aParametro, aParametr2 )
EndIf

nImpDevMes -= aParametro[ GRUPO_DEDUCOES_TRIBUTO ]

If cFormaTrib == TRIBUTACAO_LUCRO_REAL
	nImpDevMes -= aParametro[ VLR_PAGO_PERIODOS_ANTERIORES ]
Else
	nImpDevMes -= aParametro[ VLR_DEVIDO_PERIODOS_ANTERIORES ]
EndIf

nImpDevMes += aParametro[ GRUPO_ADICIONAIS_TRIBUTO ]

Return( nImpDevMes )

/*/{Protheus.doc} DeviPerAnt
Calcula o valor do imposto devido em períodos anteriores
@author david.costa
@since 02/12/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param oModelPeri, objeto, Objeto FWFormModel() do cadastro do Período de Apuração
@return ${Nil}, ${Nulo}
@example
DeviPerAnt( aParametro, oModelPeri )
/*/Function DeviPerAnt( aParametro, oModelPeri )

Local cAliasQry	as character
Local cSelect		as character
Local cFrom		as character
Local cWhere		as character
Local cIdTdECF	as character

cAliasQry	:=	GetNextAlias()
cSelect		:=	""
cFrom		:=	""
cWhere		:=	""
cIdTdECF	:=	""

//Não se aplica para o período de ajuste anual
If !oModelPeri:GetValue( "MODEL_CWV", "CWV_ANUAL" )
	cSelect	:= " ( SUM( CWV2.CWV_APAGAR) + SUM( CWV.CWV_COMPEN ) ) AS VLR_DEVIDO "
	cFrom		:= RetSqlName( "CWV" ) + " CWV "
	cFrom		+= " LEFT JOIN " + RetSqlName( "CWV" ) + " CWV2 "
	cFrom		+= " ON CWV.CWV_ID = CWV2.CWV_ID AND CWV.CWV_FILIAL = CWV2.CWV_FILIAL AND CWV2.CWV_APAGAR > 0 "
	cWhere		:= " CWV.CWV_IDTRIB = '" + oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ) + "' "
	cWhere		+= " AND CWV.CWV_INIPER >= '" + Dtos( aParametro[ INICIO_PERIODO ] ) + "' "
	cWhere		+= " AND CWV.CWV_FIMPER < '" + Dtos( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ) + "' "
	cWhere		+= " AND CWV.CWV_FILIAL = '" + xFilial( "CWV" ) + "' "
	
	cSelect	:= "%" + cSelect 	+ "%"
	cFrom  	:= "%" + cFrom   	+ "%"
	cWhere 	:= "%" + cWhere  	+ "%"
			
	BeginSql Alias cAliasQry
	
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
	EndSql
		
	DBSelectArea( cAliasQry )
	( cAliasQry )->( DbGoTop() )
	
	If ( cAliasQry )->( !Eof() ) .and. ( cAliasQry )->VLR_DEVIDO > 0
		aParametro[ VLR_DEVIDO_PERIODOS_ANTERIORES ] := ( cAliasQry )->VLR_DEVIDO
		
		If aParametro[ TIPO_TRIBUTO ] == TIPO_TRIBUTO_IRPJ
			cIdTdECF := "09101bd1-6f1f-8132-d6b9-602a10b83e85" //"N620 	20" - (-) Imposto de Renda Devido em Meses Anteriores
		Else
			cIdTdECF := "a9b875e1-ea15-462c-a57c-6985c7a71c6e" //"N660  12" - (-) CSLL Devida em Meses Anteriores
		EndIf
		
		AddDetalhe( @oModelPeri, ORIGEM_APURACAO, GRUPO_COMPENSACAO_TRIBUTO, ( cAliasQry )->VLR_DEVIDO,, cIdTdECF )
	EndIf
EndIf

Return()

/*/{Protheus.doc} PagoPerAnt
Calcula o valor do imposto pago em períodos anteriores (Verifica o valor diretamente das guias de recolhimento)
@author david.costa
@since 05/12/2016
@version 1.0
@param aParametro, ${param_type}, Array com os pametros para a apuração
@param oModelPeri, objeto, Objeto FWFormModel() do cadastro do Período de Apuração
@return ${Nil}, ${Nulo}
@example
PagoPerAnt( aParametro, oModelPeri )
/*/Static Function PagoPerAnt( aParametro, oModelPeri )

Local cAliasQry	as character
Local cSelect		as character
Local cFrom		as character
Local cWhere		as character
Local cIdTdECF	as character

cAliasQry	:=	GetNextAlias()
cSelect	:=	""
cFrom		:=	""
cWhere		:=	""
cIdTdECF	:=	""

//Se aplica somente ao período de ajuste anual
If oModelPeri:GetValue( "MODEL_CWV", "CWV_ANUAL" )

	cSelect	:= " SUM( C0R_VLRPRC ) VLR_PAGO "
	cFrom		:= RetSqlName( "CWV" ) + " CWV "
	cFrom		+= " JOIN " + RetSqlName( "T50" ) + " T50 "
	cFrom		+= " 	ON T50.T50_FILIAL = CWV.CWV_FILIAL AND T50.D_E_L_E_T_ = '' AND T50.T50_ID = CWV.CWV_ID "
	cFrom		+= " JOIN " + RetSqlName( "C0R" ) + " C0R "
	cFrom		+= " 	ON C0R.C0R_FILIAL = T50.T50_FILIAL AND C0R.D_E_L_E_T_ = '' AND T50.T50_IDGUIA = C0R.C0R_ID "
	cWhere		:= " CWV.CWV_IDTRIB = '" + oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ) + "' "
	cWhere		+= " AND CWV.CWV_INIPER >= '" + Dtos( aParametro[ INICIO_PERIODO ] ) + "' "
	cWhere		+= " AND CWV.CWV_FIMPER <= '" + Dtos( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) + "' "
	cWhere		+= " AND CWV.CWV_FILIAL = '" + xFilial( "CWV" ) + "' "
	cWhere		+= " AND C0R.C0R_STPGTO = '2' " //2=Pago
	
	cSelect	:= "%" + cSelect 	+ "%"
	cFrom  	:= "%" + cFrom   	+ "%"
	cWhere 	:= "%" + cWhere  	+ "%"
			
	BeginSql Alias cAliasQry
	
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
	EndSql
		
	DBSelectArea( cAliasQry )
	( cAliasQry )->( DbGoTop() )
	
	If ( cAliasQry )->( !Eof() ) .and. ( cAliasQry )->VLR_PAGO > 0
		aParametro[ VLR_PAGO_PERIODOS_ANTERIORES ] := ( cAliasQry )->VLR_PAGO
		
		If aParametro[ TIPO_TRIBUTO ] == TIPO_TRIBUTO_IRPJ
			cIdTdECF := "7603f80a-da4a-c55b-944a-aeed8bd7c42d" //"N630 	24" (-) Imposto de Renda Mensal Pago por Estimativa
		Else
			cIdTdECF := "9702b4b0-b267-e307-c2db-9afebb714b50" //"N670  19" (-) CSLL Mensal Paga por Estimativa
		EndIf
		
		AddDetalhe( @oModelPeri, ORIGEM_APURACAO, GRUPO_COMPENSACAO_TRIBUTO, ( cAliasQry )->VLR_PAGO,, cIdTdECF )
	EndIf
EndIf

Return()

/*/{Protheus.doc} CalcRural
Calcula o Evento e as compensações da Atividade Rural
@author david.costa
@since 05/12/2016
@version 1.0
@param oModelEven, objeto, Passar por referência o Objeto FWFormModel() do cadastro do Evento Tributário
@param oModelPeri, objeto, Passar por referência o objeto FWFormModel() do cadastro do período
@param aParametro, ${param_type}, Passar por referência o array com os pametros para a apuração
@param cLogErros, character, Passar por referência o Log de Validação do processo
@param cLogAvisos, character, Passar por referência o Log com Avisos sobre a execução do processo
@param aParRural, ${param_type}, Passar por referência o array com os pametros para a apuração do Evento da Atividade Rural
@param lSimula, lógico, Indica se o processamento é uma simulação ou apuração
@return ${Nil}, ${Nulo}
@example
CalcRural( oModelEven, @oModelPeri, @aParametro, @cLogErros, @cLogAvisos, @aParRural )
/*/Static Function CalcRural( oModelEven, oModelPeri, aParametro, cLogErros, cLogAvisos, aParRural, lSimula, lAutomato )

Local oModeEveRu	as object
Local aGruposRur	as array

Default lAutomato := .F.

oModeEveRu	:=	Nil
aGruposRur	:=	{}

If !Empty( oModelEven:GetValue( "MODEL_T0N", "T0N_IDEVEN"  ) )
	//Carrega o Evento da Atividade Rural
	LoadEvento( @oModeEveRu, oModelEven:GetValue( "MODEL_T0N", "T0N_IDEVEN"  ) )
	
	//Carrega os parametros do Evento
	LoadParam( @aParRural, oModelPeri, oModeEveRu )
	
	//As datas Devem ser iguais ao do Evento Principal
	aParRural[ INICIO_PERIODO ] := aParametro[ INICIO_PERIODO ]
	aParRural[ FIM_PERIODO ] := aParametro[ FIM_PERIODO ]
	
	//Seleciona os grupos pertinentes a Atividade Rural
	aGruposRur := GrupoEvnto( TRIBUTACAO_LUCRO_REAL_ATIV_RURAL )
	
	//Calcula a Base de Cálculo do tributo para o Evento da Atividade Rural
	CalcBCEven( @oModelPeri, aGruposRur, @aParRural, oModeEveRu, @cLogErros, @cLogAvisos, lSimula, .T., lAutomato )
Else
	//Carrega os parametros para cálculos futuros
	LoadParam( @aParRural, oModelPeri, oModelEven )
EndIf

Return()

/*/{Protheus.doc} ComPjAtual
Compensação de prejuízo do Período Atual
@author david.costa
@since 05/12/2016
@version 1.0
@param aParRural, ${param_type}, Passar por referência o array com os pametros para a apuração do Evento da Atividade Rural
@param aParametro, ${param_type}, Passar por referência o array com os pametros para a apuração
@param oModelPeri, objeto, Passar por referência o objeto FWFormModel() do cadastro do período
@param cLogErros, character, Passar por referência o Log de Validação do processo
@param cLogAvisos, character, Passar por referência o Log com Avisos sobre a execução do processo
@return ${Nil}, ${Nulo}
@example
ComPjAtual( aParRural, aParametro, oModelPeri, oModeEveRu, cLogErros, cLogAvisos)
/*/Static Function ComPjAtual( aParRural, aParametro, oModelPeri, cLogErros, cLogAvisos )

Local cIdLALUR	as character
Local nIndicGrup	as numeric

cIdLALUR	:=	""
nIndicGrup	:=	0

//A compensação de prejuízo no lucro da Atividade Rural
If VlrLRAntes( aParRural ) > 0
	
	//Prejuízo na Atividade Geral
	If VlrLRAntes( aParametro ) < 0
		
		If aParRural[ TIPO_TRIBUTO ] == TIPO_TRIBUTO_IRPJ
			cIdLALUR := "c1ecb629-a21f-bec6-08e2-5ddf64c99c4f" //344 - (-) Compensação do Prejuízo do Próprio Período - Atividades em Geral
		Else
			cIdLALUR := "399ec154-84d1-5431-4eaf-7b55ac74b5bb" //344 - (-) Compensação da Base de Cálculo Negativa do Próprio Período - Atividades em Geral
		EndIf
			
		//Lucro da atividade Rural maior ou igual ao prejuízo da Atividade Geral
		If VlrLRAntes( aParRural ) >= ( VlrLRAntes( aParRural ) * (-1) )
			//Compensar 100% do prejuízo
			aParRural[ VLR_PREJUIZO_COMP_NO_PERIODO ] += ( VlrLRAntes( aParametro ) * (-1) )
			
			AddDetalhe( @oModelPeri, ORIGEM_APURACAO, GRUPO_COMPENSACAO_PREJUIZO, VlrLRAntes( aParametro ), cIdLALUR,,, @cLogAvisos, .T. )
		
		//Prejuízo da Atividade Geral maior que o Lucro da Atividade Rural
		Else
			//Compensar 100% do lucro
			aParRural[ VLR_PREJUIZO_COMP_NO_PERIODO ] += VlrLRAntes( aParRural )
			AddDetalhe( @oModelPeri, ORIGEM_APURACAO, GRUPO_COMPENSACAO_PREJUIZO, ( VlrLRAntes( aParRural ) * (-1) ), cIdLALUR,,, @cLogAvisos, .T. )
		EndIf
	EndIf

//Compensação de Prejuízo no Lucro da Atividade Geral
ElseIf VlrLRAntes( aParametro ) > 0
	//Prejuízo na Atividade Rural
	If VlrLRAntes( aParRural ) < 0
			
		If aParRural[ TIPO_TRIBUTO ] == TIPO_TRIBUTO_IRPJ
			cIdLALUR := "9881a4c6-793e-1963-d7c3-5774648da8ef" //170 - (-)Compensação de Prejuízo do Próprio Período - Atividade Rural
		Else
			cIdLALUR := "2f252066-1ec4-6788-0c8c-eca9933aad03" //170 - (-)Compensação da Base de Cálculo Negativa do Próprio Período - Atividade Rural
		EndIf
	
		//Lucro da atividade Geral maior ou igual que o prejuízo da Atividade Rural
		If VlrLRAntes( aParametro ) >= ( VlrLRAntes( aParRural ) * (-1) )
			//Compensar 100% do prejuízo
			aParametro[ VLR_PREJUIZO_COMP_NO_PERIODO ]+= ( VlrLRAntes( aParRural ) * (-1) )
			AddDetalhe( @oModelPeri, ORIGEM_APURACAO, GRUPO_COMPENSACAO_PREJUIZO, VlrLRAntes( aParRural ), cIdLALUR, @cLogAvisos )
			
		//Prejuízo da Atividade Rural maior que o Lucro da Atividade Geral
		Else
			//Compensar 100% do lucro
			aParametro[ VLR_PREJUIZO_COMP_NO_PERIODO ] += VlrLRAntes( aParametro )
			AddDetalhe( @oModelPeri, ORIGEM_APURACAO, GRUPO_COMPENSACAO_PREJUIZO, ( VlrLRAntes( aParametro ) * ( -1 ) ) , cIdLALUR, @cLogAvisos )
		EndIf
	EndIf
EndIf

Return()

/*/{Protheus.doc} Incorporar
Incorpora ao Evento principal a apuração do Evento Rural
@author david.costa
@since 19/12/2016
@version 1.0
@param aParametro, ${param_type}, Passar por referência o array com os pametros para a apuração
@param aParRural, ${param_type}, Array com os pametros para a apuração do Evento da Atividade Rural
@return ${Nil}, ${Nulo}
@example
Incorporar( @aParametro, aParRural )
/*/Static Function Incorporar( aParametro, aParRural )

aParametro[ GRUPO_ADICOES_LUCRO ] += aParRural[ GRUPO_ADICOES_LUCRO ]
aParametro[ GRUPO_ADICOES_DOACAO ] += aParRural[ GRUPO_ADICOES_DOACAO ] 
aParametro[ GRUPO_EXCLUSOES_LUCRO ] += aParRural[ GRUPO_EXCLUSOES_LUCRO ]
aParametro[ GRUPO_COMPENSACAO_PREJUIZO ] += aParRural[ GRUPO_COMPENSACAO_PREJUIZO ]
aParametro[ VLR_PREJUIZO_OPERACIONAL ] += aParRural[ VLR_PREJUIZO_OPERACIONAL ]
aParametro[ VLR_PREJUIZO_NAO_OPERACIONAL ] += aParRural[ VLR_PREJUIZO_NAO_OPERACIONAL ]
aParametro[ GRUPO_RESULTADO_NAO_OPERACIONAL ] += aParRural[ GRUPO_RESULTADO_NAO_OPERACIONAL ]
aParametro[ GRUPO_RESULTADO_OPERACIONAL ] += aParRural[ GRUPO_RESULTADO_OPERACIONAL ]

Return()

/*/{Protheus.doc} TAFA444DA
Geração de Documento de Arrecadação a partir do Período encerrado
@author david.costa
@since 20/12/2016
@version 1.0
@return ${Nil}, ${Nulo}
@example
(examples)
@see (links_or_references)
/*/Function TAFA444DA(lAutomato)

Local cNomWiz		as character
Local lEnd			as logical

Private oProcess	as object

Default lAutomato := .F.

cNomWiz	:=	""
lEnd		:=	.F.

If !lAutomato
	oProcess	:=	Nil
Endif

If GetTpTribu( CWV->CWV_IDTRIB ) == TIPO_TRIBUTO_IRPJ .or. GetTpTribu( CWV->CWV_IDTRIB ) == TIPO_TRIBUTO_CSLL
	cNomWiz := STR0055 + " " + XFUNID2Cd( CWV->CWV_IDTRIB, "T0J", 1 ) //"Gerando DARF"
	If !lAutomato
		//Cria objeto de controle do processamento
		oProcess := TAFProgress():New( { |lEnd| GerarDARF() }, cNomWiz )
		oProcess:Activate()
	Else
		GerarDARF(lAutomato)
	Endif
Else
	ShowLog( STR0015, STR0067 )//"Atenção"; "Este processo só pode ser executado para os tributos IRPJ ou CSLL"
EndIf

//Limpando a memória
DelClassIntf()

Return()

/*/{Protheus.doc} GerarDARF
Gerar A Guia DARF a partir do período encerrado
@author david.costa
@since 20/12/2016
@version 1.0
@return ${Nil}, ${Nulo}
@example
GerarDARF()
/*/Static Function GerarDARF(lAutomato)

Local oModelPeri	:=	Nil
Local oModelDA	:=	Nil
Local nProgress1	:=	1
Local nProgress2	:=	1
Local cLogErros	:=	""
Local nNumGuia	:=	1

Default lAutomato := .F.

oModelPeri	:=	Nil
oModelDA	:=	Nil
nProgress1	:=	1
nProgress2	:=	1
cLogErros	:=	""
nNumGuia	:=	1

If !lAutomato
	oProcess:Set1Progress( nProgress1 )
	oProcess:Set2Progress( nProgress2 )
Endif

If CWV->CWV_STATUS == PERIODO_ENCERRADO
	
	//Carrega os cadastros
	oModelDA := FWLoadModel( 'TAFA027' )
	oModelDA:SetOperation( MODEL_OPERATION_INSERT )
	oModelDA:Activate()
	
	oModelPeri := FWLoadModel( 'TAFA444' )
	oModelPeri:SetOperation( MODEL_OPERATION_UPDATE )
	oModelPeri:Activate()
	oModelPeri:GetModel( "MODEL_T50" ):AddLine()

	If !lAutomato
		//Carrega os parametros para geração da guia
		ParamGuia()
	Else
		MV_PAR01 := '001521'
		MV_PAR02 := 'ICMS COMUNICAÇÃO'
		MV_PAR03 := CTOD('31/03/2020')
	Endif
	
	//Verifica se os parametros foram informados
	If !Empty( MV_PAR01 ) .and. !Empty( MV_PAR03 )
		//Preenchendo a guia
		oModelDA:LoadValue( "MODEL_C0R", "C0R_DTVCT", MV_PAR03 )
		oModelDA:SetValue( "MODEL_C0R", "C0R_CODDA", "2" )//2- DARF
		oModelDA:SetValue( "MODEL_C0R", "C0R_PERIOD", AllTrim( StrZero( Month( CWV->CWV_INIPER ),2 ) ) + AllTrim( Str( Year( CWV->CWV_INIPER ) ) ) )
		oModelDA:SetValue( "MODEL_C0R", "C0R_DESDOC", STR0059 )//"Guia DARF (Gerada Automaticamente)"
		oModelDA:SetValue( "MODEL_C0R", "C0R_VLRPRC", CalVlrGuia( oModelPeri ) )
		oModelDA:SetValue( "MODEL_C0R", "C0R_VLCOMP", CWV->CWV_COMPEN )
		oModelDA:SetValue( "MODEL_C0R", "C0R_CODREC", MV_PAR01 )
		
		While !oModelDA:SetValue( "MODEL_C0R", "C0R_NUMDA", StrZero( nNumGuia, 3 ) ) .and. nNumGuia < 100
			nNumGuia++
			If nNumGuia >= 100
				AddLogErro( STR0121, @cLogErros )//Não foi possível definir um número para a Guia DARF, a Range de 1 à 100 já foi utilizada para o período
			EndIf
		EndDo
		
		oModelDA:lValid := .T.
		
		//Vincula a guia ao período
		oModelPeri:LoadValue( "MODEL_T50", "T50_IDGUIA", oModelDA:GetValue( "MODEL_C0R", "C0R_ID" ) )
		oModelPeri:lValid := .T.
		
		If oModelDA:GetValue( "MODEL_C0R", "C0R_VLRPRC") <= 0
			AddLogErro( STR0062, @cLogErros )//"O período não gerou valor de imposto à pagar ou a guia com o valor já foi gerada"
		EndIf
		
	Else
		AddLogErro( STR0060, @cLogErros )//"A guia DARF não pode ser gerada com os parametros informados"
	EndIf
Else
	AddLogErro( STR0056, @cLogErros )//"A guia DARF só pode ser gerada se o período estiver encerrado"
EndIf

If !lAutomato
//Em caso de Erros
	If !Empty( cLogErros )
		//Apresentando Log do processo
		oProcess:Set1Progress( 1 )
		oProcess:Inc1Progress( STR0058 )//"Erro ao incluir guia DARF"
		oProcess:nCancel := 1
		
		If !Empty( cLogErros )
			ShowLog( STR0015, cLogErros )//"Atenção"
		EndIf
	Else
		//Salvando
		oProcess:Inc1Progress( STR0057 )//"Salvando Guia"
		FWFormCommit( oModelDA )
		FWFormCommit( oModelPeri )
		oModelDA:DeActivate()
	EndIf

	oProcess:Inc2Progress( STR0034 ) //"Clique em finalizar"
Else
	FWFormCommit( oModelDA )
	FWFormCommit( oModelPeri )
	oModelDA:DeActivate()
Endif

Return()

/*/{Protheus.doc} ParamGuia
Parametros para geração da guia DARF
@author david.costa
@since 20/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function ParamGuia()

Local oDlg			as object
Local oFont		as object
Local cTitulo1	as character
Local cTitulo2	as character
Local cTitulo3	as character
Local nLarguraBox	as numeric
Local nAlturaBox	as numeric
Local nTop			as numeric
Local nAltura		as numeric
Local nLargura	as numeric
Local nPosIni		as numeric

oDlg			:=	Nil
oFont			:=	TFont():New( "Arial",, -11 )
cTitulo1		:=	Eval( { || SX3->( DBSetOrder( 2 ) ), SX3->( MsSeek( "C0R_CODREC" ) ), X3Titulo() } )
cTitulo2		:=	Eval( { || SX3->( DBSetOrder( 2 ) ), SX3->( MsSeek( "C6R_DESCRI" ) ), X3Titulo() } )
cTitulo3		:=	Eval( { || SX3->( DBSetOrder( 2 ) ), SX3->( MsSeek( "C0R_DTVCT" ) ), X3Titulo() } )
nLarguraBox	:=	0
nAlturaBox		:=	0
nTop			:=	0
nAltura		:=	230
nLargura		:=	500
nPosIni		:=	0

//Solicita ao usuário os parametros para o processo
oDlg := MsDialog():New( 0, 0, nAltura, nLargura, STR0024,,,,,,,,, .T. ) //"Parâmetros"

nAlturaBox := ( nAltura - 60 ) / 2
nLarguraBox := ( nLargura - 20 ) / 2

@10,10 to nAlturaBox,nLarguraBox of oDlg Pixel

//Limpa as variáveis
MV_PAR03 := MV_PAR02 := MV_PAR01 := ""

MV_PAR01 := PadR( MV_PAR01, TamSx3( "C0R_CODREC" )[1])
MV_PAR02 := PadR( MV_PAR02, Tamsx3( "C6R_DESCRI" )[1])
MV_PAR03 := SToD( "  /  /    " )

nTop := 20

//Código de Receita
TGet():New( nTop, 20, { |x| If( PCount() == 0, MV_PAR01, MV_PAR01 := x ) }, oDlg, 65, 10, "@!", { || ValidPerg() },,,,,, .T.,,,,,,,,, "C6R",,,,,,,, cTitulo1 , 1, oFont )
TGet():New( nTop, 90, { |x| If( PCount() == 0, MV_PAR02, MV_PAR02 := x ) }, oDlg, 140, 10, "@!",,,,,,, .T.,,, { || .F. },,,,,,,,,,,,,, cTitulo2, 1, oFont )

nTop += 30

//Data de vencimento
TGet():New( nTop, 20, { |x| If( PCount() == 0, MV_PAR03, MV_PAR03 := x ) }, oDlg, 65, 10, "@!", { || .T. },,,,,, .T.,,,,,,,,,,,,,,,,, cTitulo3 , 1, oFont )
nTop += 10

nPosIni := ( ( nLargura - 20 ) / 2 ) - 32

SButton():New( nAlturaBox + 10, nPosIni, 1, { |x| Iif( ValidPerg(), x:oWnd:End(), ) }, oDlg )

oDlg:Activate( ,,,.T. )

Return()

/*/{Protheus.doc} ValidPerg
Valida se os parâmetros informados estão corretos
@author david.costa
@since 20/12/2016
@version 1.0
@return ${lRet}, ${lRet}
@example
ValidPerg()
/*/Static Function ValidPerg()

Local lRet	as logical

lRet	:=	.T.

C6R->( DBSetOrder( 3 ) )
If !C6R->( MsSeek( xFilial("C6R") + MV_PAR01 ) ) .and. !Empty( MV_PAR01 )
	MsgInfo( STR0061 ) //"Código inexistente"
	lRet := .F.
Else
	MV_PAR02 := AllTrim( C6R->C6R_DESCRI )
EndIf

Return( lRet )

/*/{Protheus.doc} CalVlrGuia
Calcula o Valor que a guia deverá ser gerada
@author david.costa
@since 20/12/2016
@version 1.0
@param oModelPeri, objeto, Objeto FWFormModel() do cadastro do período
@return ${nVlrGuia}, ${Valor da guia}
@example
CalVlrGuia( oModelPeri )
/*/Static Function CalVlrGuia( oModelPeri )

Local oModelT50	as object
Local nVlrGuia	as numeric
Local nGuiasAnte	as numeric
Local nIndiceT50	as numeric

oModelT50	:=	oModelPeri:GetModel( "MODEL_T50" )
nVlrGuia	:=	0
nGuiasAnte	:=	0
nIndiceT50	:=	0

For nIndiceT50 := 1 To oModelT50:Length()
	oModelT50:GoLine( nIndiceT50 )
	
	If !oModelT50:IsDeleted()
		DBSelectArea( "C0R" )
		C0R->( DBSetOrder( 6 ) )
		If C0R->( MsSeek( xFilial( "C0R" ) + oModelT50:GetValue( "T50_IDGUIA" ) ) )
			nGuiasAnte += C0R->C0R_VLRPRC
		EndIf  
	EndIf
Next nIndiceT50

nVlrGuia := oModelPeri:GetValue( "MODEL_CWV", "CWV_APAGAR" ) + oModelPeri:GetValue( "MODEL_CWV", "CWV_COMPEN" ) - nGuiasAnte

nVlrGuia := IIf( nVlrGuia > 0, nVlrGuia , 0 )

Return( nVlrGuia )

/*/{Protheus.doc} TAFA444PaB
Geração de Lançamentos Automaticos na parte B do Lalur
@author david.costa
@since 22/12/2016
@version 1.0
@return ${Nil}, ${Nulo}
@example
TAFA444PaB()
/*/Function TAFA444PaB()

Local cNomWiz		as character
Local cLogAvisos	as character
Local cLogErros	as character
Local lEnd			as logical

Private oProcess	as object

cNomWiz	:=	""
cLogAvisos	:=	""
cLogErros	:=	""
lEnd		:=	.F.

oProcess	:=	Nil

If CWV->CWV_STATUS == PERIODO_ENCERRADO
	If GetTpTribu( CWV->CWV_IDTRIB ) == TIPO_TRIBUTO_IRPJ .or. GetTpTribu( CWV->CWV_IDTRIB ) == TIPO_TRIBUTO_CSLL
		cNomWiz := STR0068 //"Processando Lançamentos do LALUR Parte B"
	
		//Cria objeto de controle do processamento
		oProcess := TAFProgress():New( { |lEnd| ProcParteB( @cLogAvisos, @cLogErros ) }, cNomWiz )
		oProcess:Activate()
	Else
		AddLogErro( STR0067, @cLogErros ) //"Atenção"; "Este processo só pode ser executado para os tributos IRPJ ou CSLL"
	EndIf
Else
	AddLogErro( STR0069, @cLogErros ) //"Atenção"; "Este processo só pode ser executado com o período encerrado."
EndIf

If !Empty( cLogErros )
	ShowLog( STR0015, cLogErros )//"Atenção"
ElseIf	!Empty( cLogAvisos )
	ShowLog( STR0015, cLogAvisos )//"Atenção"
EndIf

//Limpando a memória
DelClassIntf()

Return()

/*/{Protheus.doc} ProcParteB
Processa a geração dos lançamentos da Parte B
@author david.costa
@since 22/12/2016
@version 1.0
@param cLogAvisos, character, Passar por Referência o Log de Avisos do Processo
@param cLogErros, character, Passar por referência o Log de Validação do processo
@return ${Nil}, ${Nulo}
@example
ProcParteB( @cLogAvisos, @cLogErros )
/*/Static Function ProcParteB( cLogAvisos, cLogErros, aParametro, lAutomato )

Local oModelParB	as object
Local oModelPeri	as object
Local oModelEven	as object
Local oModelGrup	as object
Local oGetDB		as object
Local cAliasQry		as character

Local nVlrParteB	as numeric
Local nIndicGrup	as numeric
Local nI			as numeric
Local aGrupos		as array
Local aItensRema	as array
Local oEvenRural	as object
Local aParRural		as array
Default aParametro := {}
Default lAutomato  := .F.

oModelParB	:=	Nil
oModelPeri	:=	Nil
oModelEven	:=	Nil
oModelGrup	:=	Nil
oGetDB		:=	Nil
cAliasQry	:=	""

nVlrParteB	:=	0
nIndicGrup	:=	0
nI			:=	0
aGrupos		:=	{}
aItensRema	:=	{}
oEvenRural	:= Nil
aParRural	:= {}
if !lAutomato
	oProcess:Set1Progress( 0 )
	oProcess:Set2Progress( 0 )
endif
//Carrega o Período
oModelPeri := FWLoadModel( 'TAFA444' )
oModelPeri:SetOperation( MODEL_OPERATION_VIEW )
oModelPeri:Activate()

//Carrega o Evento
LoadEvento( @oModelEven, oModelPeri:GetValue( "MODEL_CWV", "CWV_IDEVEN" ) )

//Carrega os parametros da apuração
If Len(aParametro)==0
	LoadParam( @aParametro, oModelPeri, oModelEven )
Endif

//Para os lançamentos automaticos a data inicial será sempre a do período
aParametro[ INICIO_PERIODO ] := oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" )

//Carrego o evento rural e seus parametros caso ele exista.
if !empty(oModelEven:GetValue('MODEL_T0N','T0N_CODEVE'))
	LoadEvento( @oEvenRural, oModelEven:GetValue( "MODEL_T0N", "T0N_IDEVEN"  ) )
	LoadParam( @aParRural, oModelPeri, oEvenRural )
	aParRural[ INICIO_PERIODO ] := oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" )
endif

//Carrega os grupos do evento tributário
//Segue a mesma regra para estimativa de balanco e atividade rural.
aGrupos := GrupoEvnto( XFUNID2Cd( oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI" ), "T0K", 1 ) )

//Seleciona os itens que irão gerar lançamentos automaticos na parte B
cAliasQry := SelDadosLA( oModelPeri ) 

If ( cAliasQry )->( !( Eof() ) )

	While ( cAliasQry )->( !( Eof() ) )
		
		If LoadContaB( ( cAliasQry )->T0O_IDPARB, @oModelParB, ( cAliasQry )->C1E_FILTAF )
		
			While oModelParB:GetValue( "MODEL_T0S", "T0S_ID" ) == ( cAliasQry )->T0O_IDPARB .and. ( cAliasQry )->( !( Eof() ) )
			
				//Seleciona os dados do grupo que esta sendo processado
				nIndicGrup := aScan( aGrupos, { |x| x[ PARAM_GRUPO_ID ] == ( cAliasQry )->T0O_IDGRUP } )
				
				//Apura o Valor para o lançamento
				if ( cAliasQry )->CWX_RURAL == '0'

					//Carrega e posiciona o item do evento tributário que será considerado para calcular o valor do lançamento
					oModelGrup	:= oModelEven:GetModel( "MODEL_T0O_" + aGrupos[ nIndicGrup ][ PARAM_GRUPO_NOME ] )
					oModelGrup:SeekLine( { { "T0O_IDGRUP", ( cAliasQry )->T0O_IDGRUP }, { "T0O_SEQITE", ( cAliasQry )->T0O_SEQITE } } )
					nVlrParteB := ApuraContC( oModelPeri, oModelGrup, @cLogErros, aGrupos[ nIndicGrup ], oModelEven, aParametro )
				else	
					
					//Carrega e posiciona o item do evento tributário que será considerado para calcular o valor do lançamento
					oModelGrup	:= oEvenRural:GetModel( "MODEL_T0O_" + aGrupos[ nIndicGrup ][ PARAM_GRUPO_NOME ] )
					oModelGrup:SeekLine( { { "T0O_IDGRUP", ( cAliasQry )->T0O_IDGRUP }, { "T0O_SEQITE", ( cAliasQry )->T0O_SEQITE } } )					
					nVlrParteB := ApuraContC( oModelPeri, oModelGrup, @cLogErros, aGrupos[ nIndicGrup ], oEvenRural, aParRural )
				endif
				
				//Ajusta o Valor dos itens parametrizados para subtrair
				if oModelGrup:GetValue( "T0O_OPERAC" ) == OPERACAO_SUBTRACAO;  nVlrParteB *= -1; endif

				//Para o grupo de deduções e Compensações do Tributo não haverá lançamento na parte B, pois ele só pode ser deduzido/compensado no período. Os valores não devem ser acumulados para os próximos períodos
				If aGrupos[nIndicGrup][ PARAM_GRUPO_ID ] <> GRUPO_DEDUCOES_TRIBUTO .And. aGrupos[nIndicGrup][ PARAM_GRUPO_ID ] <> GRUPO_COMPENSACAO_TRIBUTO

					//Verifica o Saldo da conta e retorna o valor que poderá ser lançado
					nVlrParteB := GetVlrLanc( nVlrParteB, oModelParB, cAliasQry, @cLogAvisos, @aItensRema )
					
					//Inclui o lançamento na conta da parte B
					AddLanParB( @oModelParB, nVlrParteB, aGrupos[ nIndicGrup ], @cLogAvisos, ( cAliasQry )->( CWX_ID + CWX_SEQDET ),;
					 sToD( ( cAliasQry )->CWV_FIMPER ), ( cAliasQry )->T0O_EFEITO, ( cAliasQry )->DESCRICAO, ( cAliasQry )->CWV_IDTRIB,,(cAliasQry)->CWX_RURAL == '1')
					
				Endif
				( cAliasQry )->( DbSkip() )
			EndDo
			
			//Salva a Conta
			FWFormCommit( oModelParB )
			oModelParB:DeActivate()
		Else
			( cAliasQry )->( DbSkip() )
		EndIf
	EndDo

	If Len( aItensRema ) > 0
		If !lAutomato
			If MsgYesNo( STR0088, STR0015 ) //"Alguns lançamentos automáticos não foram gerados com os valores apurados devido a falta de saldo nas contas da parte B. Deseja informar novas contas para receber o saldo remanescente?";Atenção
		
				oGetDB := DadosLanRe( aItensRema )

				For nI := 1 To Len( oGetDB:aCols )
					If !Empty( oGetDB:aCols[nI][5] )
						LoadContaB( XFUNCh2ID( oGetDB:aCols[nI][5], "T0S", 2 ), @oModelParB, xFilial( "T0S" ) )
						
						//Seleciona os dados do grupo que esta sendo processado
						nIndicGrup := aScan( aGrupos, { |x| x[ PARAM_GRUPO_ID ] == oGetDB:aCols[nI][10] } )
						
						//DESCGRUPO, ITEM, VLRAPURADO, REMASCENTE, CODPAB, DESCRICAO, TDECF, CHAVE, EFEITO
						AddLanParB( @oModelParB, oGetDB:aCols[nI][4], aGrupos[ nIndicGrup ], @cLogAvisos, oGetDB:aCols[nI][8], oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ), oGetDB:aCols[nI][9],, oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ) )
						
						//Salva a Conta
						FWFormCommit( oModelParB )
						oModelParB:DeActivate()
					EndIf
				Next nI
			EndIf
		Else
			If IsInCallStack('TAF444_005') .OR. IsInCallStack('TAF444_009')

				// Escolhe a conta CAD03008
				LoadContaB( XFUNCh2ID( "CAD03008", "T0S", 2 ), @oModelParB, xFilial( "T0S" ) )
					
				//Seleciona os dados do grupo que esta sendo processado
				nIndicGrup := aScan( aGrupos, { |x| x[ PARAM_GRUPO_ID ] == 9 } )
					
				//DESCGRUPO, ITEM, VLRAPURADO, REMASCENTE, CODPAB, DESCRICAO, TDECF, CHAVE, EFEITO
				AddLanParB( @oModelParB, aItensRema[1][4], aGrupos[ nIndicGrup ], @cLogAvisos, aItensRema[1][8], oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ), aItensRema[1][9],, oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ) )
					
				//Salva a Conta
				FWFormCommit( oModelParB )
				oModelParB:DeActivate()
			EndIf
		Endif
	EndIf
Else
	AddLogErro( STR0066, @cLogAvisos )//"Não existem lançamentos da Parte B Automáticos pendentes para este período"
EndIf

oModelPeri:DeActivate()
if !lAutomato
	oProcess:Set1Progress( 1 )
	oProcess:Set2Progress( 1 )
	oProcess:Inc1Progress( STR0034 ) //"Clique em finalizar"
	oProcess:Inc1Progress( STR0034 ) //"Clique em finalizar"
endif
Return()

/*/{Protheus.doc} AddLanParB
Adiciona um lançamento na conta da parte B
@author david.costa
@since 22/12/2016
@version 1.0
@param oModelParB, objeto, Objeto do cadastro da conta
@param nVlrParteB, numérico, Valor que deverá ser lançado na conta
@param aGrupo, array, Array com os dados do Grupo
@param cLogAvisos, character, Passar por Referência o Log de Avisos do Processo
@param cChave, character, Chave para o campo IdDetalhe do lançamento
@param dDtLan, date, Data para criação do lançamento
@param cEfeito, character, Efeito na parte B
@param cDescricao, character, Descrição da tabela dinamica da ECF
@param cIdTributo, character, Id do Tributo do Lançamento
@param cTipoLan, character, Tipo do Lançamento que será gerado
@param lRural, logical, Informa se o lançamento é da atividade Rural
@return ${Nil}, ${Nulo}
/*/Function AddLanParB( oModelParB, nVlrParteB, aGrupo, cLogAvisos, cChave, dDtLan, cEfeito, cDescricao, cIdTributo, cTipoLan, lRural )

Local oModelLanc	as object
Local oModelTrib	as object
Local nCodLancam	as numeric
Local lError		as logical
Local cNatConta		as character

Default aGrupo		:=	{ 0, "", "", 0 }
Default cDescricao	:=	""
Default cIdTributo	:=	""
Default lRural		:= .F.
Default cTipoLan	:= '' //GetTipoLan( aGrupo[PARAM_GRUPO_ID] , cEfeito, cNatConta )

oModelLanc	:=	Nil
oModelTrib	:=	Nil
nCodLancam	:=	0
lError		:=	.F.
cNatConta	:= oModelParb:GetValue('MODEL_T0S','T0S_NATURE')

//O Lançamento só será gravado se o valor for maior que zero
If nVlrParteB > 0
	
	//Posiciona no tributo correto
	oModelTrib := oModelParB:GetModel( "MODEL_LE9" )
	oModelTrib:SeekLine( { { "LE9_IDCODT", cIdTributo } } )

	if empty(cTipoLan)
		cTipoLan := GetTipoLan( aGrupo[PARAM_GRUPO_ID] , cEfeito, cNatConta, oModelTrib )
	endif	

	oModelLanc := oModelTrib:GetModel( "MODEL_T0T" ):GetModel( "MODEL_T0T" )

	//Verifica se existem lançamentos na conta
	if IsInCallStack( "AddLanPrej" ) .and. oModelLanc:SeekLine( { { "T0T_DTLANC", dDtLan }, { "T0T_TPLANC", cTipoLan }, { "T0T_ORIGEM", '2' }, {  "T0T_IDDETA", cChave } } )
		nVlrParteB += oModelLanc:GetValue('T0T_VLLANC')
		lError := lError .or. !oModelLanc:SetValue( "T0T_VLLANC", nVlrParteB )
	else
		If oModelLanc:Length() == 1 .and. Empty( oModelLanc:GetValue( "T0T_DTLANC" ) )
			nCodLancam := 1
		Else
			oModelLanc:GoLine( oModelLanc:Length() )
			nCodLancam	:= Val( oModelLanc:GetValue( "T0T_CODLAN" ) ) + 1
			oModelLanc:AddLine()
		EndIf
		lError := lError .or. !oModelLanc:SetValue( "T0T_CODLAN", StrZero( nCodLancam, 6 ) )
		lError := lError .or. !oModelLanc:LoadValue( "T0T_DTLANC", dDtLan )
		lError := lError .or. !oModelLanc:SetValue( "T0T_TPLANC", cTipoLan )
		lError := lError .or. !oModelLanc:SetValue( "T0T_ORIGEM", ORIGEM_AUTOMATICO )
		lError := lError .or. !oModelLanc:SetValue( "T0T_IDDETA", cChave )
		lError := lError .or. !oModelLanc:SetValue( "T0T_VLLANC", nVlrParteB )
		lError := lError .or. !oModelLanc:LoadValue( "T0T_INDDIF", "2" ) //2-NÃO
		lError := lError .or. !oModelLanc:LoadValue( "T0T_HISTOR", GetHistLanc( cEfeito, cDescricao, aGrupo ) )
		lError := lError .or. !oModelLanc:LoadValue( "T0T_RURAL", Iif( lRural, "1", "0" ) )
	endif	
	
	oModelLanc:lValid := !lError

	If lError
		AddLogErro( STR0116, @cLogAvisos , { oModelLanc:GetValue( "T0T_CODLAN" ), oModelParB:GetValue( "MODEL_T0S", "T0S_CODIGO" ), CRLF ,;
			 XFUNID2Cd( oModelTrib:Getvalue("LE9_IDCODT"), "T0J", 1 ), nVlrParteB, DesTpLan( cTipoLan ) } )
			 //"Não foi possível incluir o lançamento @1 na conta do LALUR parte B @2. Verifique o cadastro da conta.@3Dados do lançamento:@3Código: @1@3Conta: @2@3Tributo: @4@3Valor: @5@3Tipo: @6"
	Else
		AddLogErro( STR0072, @cLogAvisos , { oModelLanc:GetValue( "T0T_CODLAN" ), oModelParB:GetValue( "MODEL_T0S", "T0S_CODIGO" ),;
			 XFUNID2Cd( oModelTrib:Getvalue("LE9_IDCODT"), "T0J", 1 ), nVlrParteB } ) //"Lançamento @1 gerado na conta @2, tributo @3 com o valor @4"
	EndIf

EndIf

Return()

/*/{Protheus.doc} GetTipoLan
Retorna o tipo do lançamento automático
@author david.costa
@since 22/12/2016
@version 1.0
@param nIdGrupo, character, Dados dos lançamentos
@param cEfeito, character, Efeito na parte B
@return ${cTipoLan}, ${Tipo do lançamento que será gerado}
/*/Static Function GetTipoLan( nIdGrupo, cEfeito, cNatureza, oModelTrib )

Local cTipoLan	as character
Local cIndTrib 	as character
Default cNatureza := ''

cTipoLan :=	''
cIndTrib := oModelTrib:GetValue('LE9_ISLDAT')

If cEfeito == EFEITO_CONSTITUIR_SALDO .or. cEfeito == EFEITO_CONSTITUIR_SALDO_PREJ
	cTipoLan := TIPO_LANC_CONSTITUIR_SALDO

ElseIf cEfeito == EFEITO_INCLUIR_LANC_AUTOMATICO .or. ( cEfeito == EFEITO_BAIXAR_SALDO .and. ( nIdGrupo == GRUPO_EXCLUSOES_LUCRO .or. nIdGrupo == GRUPO_EXCLUSOES_RECEITA )  )

	cTipoLan := TIPO_LANC_CREDITO
    
ElseIf cEfeito == EFEITO_BAIXAR_SALDO .and. ( nIdGrupo == GRUPO_ADICOES_LUCRO .or. nIdGrupo == GRUPO_ADICOES_DOACAO )

	cTipoLan := TIPO_LANC_DEBITO

EndIf

Return( cTipoLan )

/*/{Protheus.doc} DesTpLan
Retorna a descrição do do tipo do lançamento conforme o tipo passado
@author david.costa
@since 16/01/2017
@version 1.0
@param cTipoLan, character, código do tipo do lançamento
@return ${cRet}, ${Descrição do Lançamento}
@example
DesTpLan( cTipoLan )
/*/Static Function DesTpLan( cTipoLan )

Local cRet	as character

cRet	:=	""

If cTipoLan == TIPO_LANC_CONSTITUIR_SALDO
	cRet := STR0117//"Constituição de Saldo"
ElseIf cTipoLan == TIPO_LANC_CREDITO
	cRet := STR0118 //"Crédito"
ElseIf cTipoLan == TIPO_LANC_DEBITO
	cRet := STR0119 //"Débito"
EndIf

Return( cRet )

/*/{Protheus.doc} GetHistLanc
Retorna o Histórico do lançamento automático
@author david.costa
@since 22/12/2016
@version 1.0
@param cEfeito, character, Efeito na parte B
@param cDescricao, character, Descrição da tabela dinamica da ECF
@param aGrupo, array, Array com os parametros do Grupo que esta sendo processado
@return ${cHistorico}, ${Mensagem do histórico}
@example
GetHistLanc( cEfeito, cDescricao, aGrupo )
/*/Static Function GetHistLanc( cEfeito, cDescricao, aGrupo )

Local cHistorico	as character

cHistorico	:=	""

If cEfeito == EFEITO_INCLUIR_LANC_AUTOMATICO
	cHistorico := STR0063 //"Valor referente compensação de prejuízo de períodos anteriores"
ElseIf cEfeito == EFEITO_BAIXAR_SALDO
	cHistorico := FormatStr( STR0064, { aGrupo[ PARAM_GRUPO_DESCRICAO ], cDescricao } )//"Baixa de saldo da conta referente lançamento de @1 referente à @2 "
ElseIf cEfeito == EFEITO_CONSTITUIR_SALDO
	cHistorico := FormatStr( STR0065, { aGrupo[ PARAM_GRUPO_DESCRICAO ], cDescricao } )//"Constituição de saldo da conta referente lançamento de @1 referente à @2 "
ElseIf cEfeito == EFEITO_CONSTITUIR_SALDO_PREJ
	cHistorico := STR0073 //"Prejuízo Fiscal/Base de cálculo negativa apurado no período"
EndIf

Return( cHistorico )

/*/{Protheus.doc} GetVlrLanc
Verifica o Saldo da conta e retorna o valor que poderá ser lançado na conta
@author david.costa
@since 22/12/2016
@version 1.0
@param nVlrParteB, numérico, Valor que precisa ser lançado
@param oModelParB, objeto, Objeto do cadastro da conta
@param cAliasQry, character, Dados para o lançamento
@param cLogAvisos, character, Passar por Referência o Log de Avisos do Processo
@param aItensRema, Array, Lista de item que têm valores remanescentes
@return ${nValorLanc}, ${Valor que poderá ser lançado na conta}
@example
GetVlrLanc( nVlrParteB, oModelParB, cAliasQry, @cLogAvisos, @aItensRema )
/*/Static Function GetVlrLanc( nVlrParteB, oModelParB, cAliasQry, cLogAvisos, aItensRema )

Local oModelTrib	as object
Local nValorLanc	as numeric
Local nSaldoCont	as numeric
Local cNatureza		as character

oModelTrib	:=	oModelParB:GetModel( "MODEL_LE9" )
nValorLanc	:=	0
nSaldoCont	:=	0

oModelTrib:SeekLine( { { "LE9_IDCODT", ( cAliasQry )->CWV_IDTRIB } } )
nSaldoCont := oModelTrib:GetValue( "LE9_VLSDAT" )

cNatureza := " "
//Pego a natureza para verificar se é adição/exclusão (Natureza 5). Caso seja, não deve ser adicionado no array.
cNatureza := oModelParB:GetValue( "MODEL_T0S", "T0S_NATURE" )

//É subtraido o valor dos lançamentos já gerados para este item
nVlrParteB -= ( cAliasQry )->TOT_LAN

If cNatureza <> "5" .and. nVlrParteB > nSaldoCont .and. ( cAliasQry )->T0O_EFEITO <> EFEITO_CONSTITUIR_SALDO
	AddLogErro( STR0070, @cLogAvisos , { oModelParB:GetValue( "MODEL_T0S", "T0S_CODIGO" ), nSaldoCont, nVlrParteB } )//"A Conta @1 estava com saldo @2 e por isso não pode receber um lançamento com valor @3 ( Valor Apurado conforme item do Evento Tributário )."
	AddItemRem( @aItensRema, nVlrParteB, nVlrParteB - nSaldoCont, cAliasQry )
	nValorLanc := nSaldoCont
Else
	nValorLanc := nVlrParteB
EndIf

Return( nValorLanc )

/*/{Protheus.doc} SelDadosLA
Seleciona os dados para geração do lançamento automatico
@author david.costa
@since 22/12/2016
@version 1.0
@param oModelPeri, objeto, Objeto do cadastro do Período
@return ${cAliasQry}, ${Objeto com os dados selecionados}
@example
SelDadosLA( oModelPeri )
/*/Static Function SelDadosLA( oModelPeri )

Local cAliasQry	as character
Local cSelect		as character
Local cFrom		as character
Local cWhere		as character
Local cWhere2		as character
Local cOrderBy	as character
Local cFrom2    as character
Local cFromAux	as character

cAliasQry	:=	GetNextAlias()
cSelect		:=	""
cFrom		:=	""
cWhere		:=	""
cWhere2		:=	""
cOrderBy	:=	"" 
cFrom2		:=  ""
cFromAux	:= ''

cSelect	:= " CWX.CWX_ID, '"+ oModelPeri:GetValue( "MODEL_CWV", "CWV_ID" )+"' AS CHAVE, CWX.CWX_SEQDET, T0O.T0O_EFEITO, T0O.T0O_IDPARB, CWV.CWV_IDTRIB, C1E.C1E_FILTAF, T0O.T0O_IDGRUP, T0O.T0O_SEQITE, "
cSelect	+= " CWV.CWV_FIMPER, CASE WHEN T0O_IDECF <> '' THEN CH6_DESCRI ELSE CH8_DESCRI END AS DESCRICAO, CWX.CWX_IDCODG, LEE.LEE_DESCRI, "
cSelect	+= " ( "
cSelect	+= " 		SELECT SUM( T0T_VLLANC) AS TOT_LAN FROM " + RetSqlName( "T0T" ) + " T0T "

If Upper( AllTrim( TCGetDB() ) ) $ "ORACLE|POSTGRES"
	cSelect	+= " WHERE T0T.D_E_L_E_T_ = '' AND T0T_IDDETA = CWX.CWX_ID || CWX.CWX_SEQDET "
Else
	cSelect	+= " WHERE T0T.D_E_L_E_T_ = '' AND T0T_IDDETA = CWX.CWX_ID + CWX.CWX_SEQDET "
EndIf

cSelect	+= " ) AS TOT_LAN "
cSelect += ", CWX.CWX_RURAL
cFromAux	:= RetSqlName( "CWX" ) + " CWX "
cFromAux	+= " JOIN " + RetSqlName( "CWV" ) + " CWV "
cFromAux	+= " 	ON CWV.D_E_L_E_T_ = '' AND CWV.CWV_FILIAL = CWX.CWX_FILIAL AND CWV.CWV_ID = CWX.CWX_ID "
cFromAux	+= " JOIN " + RetSqlName( "LEE" ) + " LEE "
cFromAux	+= " 	ON LEE.D_E_L_E_T_ = '' AND LEE.LEE_ID = CWX.CWX_IDCODG "

cFrom := cFromAux
cFrom += " JOIN " + RetSqlName( "T0O" ) + " T0O "
cFrom += " 	ON T0O.D_E_L_E_T_ = '' AND T0O.T0O_FILIAL = CWX.CWX_FILIAL AND T0O.T0O_ID = CWV.CWV_IDEVEN "
cFrom += " 	AND T0O.T0O_SEQITE = CWX.CWX_SEQITE AND T0O.T0O_IDGRUP = CAST(LEE.LEE_CODIGO AS INTEGER) AND T0O.T0O_IDPARB <> '' AND T0O.T0O_IDGRUP != '13' "

cFrom2	:= cFromAux
cFrom2	+=  " JOIN " + RetSqlName('T0N') + " T0N ON T0N.T0N_FILIAL = '"+ xFilial('T0N') + "' AND T0N.T0N_ID = CWV.CWV_IDEVEN AND T0N.D_E_L_E_T_ = ' '
cFrom2	+=  " JOIN " + RetSqlName("T0O") + " T0O "
cFrom2	+=  "	ON T0O.D_E_L_E_T_ = '' AND T0O.T0O_FILIAL = '"+ xFilial('T0O') + "' AND T0O.T0O_ID = T0N.T0N_IDEVEN "
cFrom2	+= " 	AND T0O.T0O_SEQITE = CWX.CWX_SEQITE AND T0O.T0O_IDGRUP = CAST(LEE.LEE_CODIGO AS INTEGER) AND T0O.T0O_IDPARB <> '' AND T0O.T0O_IDGRUP != '13' "

cFromaUX := " JOIN " + RetSqlName( "C1E" ) + " C1E "
cFromaUX += " 	ON C1E.D_E_L_E_T_ = '' AND C1E.C1E_CODFIL = T0O.T0O_FILITE AND C1E.C1E_ATIVO != '2' "
cFromaUX += " LEFT JOIN " + RetSqlName( "CH6" ) + " CH6 "
cFromaUX += " 	ON CH6.D_E_L_E_T_ = '' AND CH6_ID = T0O.T0O_IDECF "
cFromaUX += " LEFT JOIN " + RetSqlName( "CH8" ) + " CH8 "
cFromaUX += " 	ON CH8.D_E_L_E_T_ = '' AND CH8_ID = T0O.T0O_IDLAL "

cFrom  += cFromAux
cFrom2 += cFromAux

cWhere += " CWX.D_E_L_E_T_ = '' "
cWhere += " AND CWX.CWX_FILIAL = '" + xFilial( "CWX" ) + "' "
cWhere += " AND CWX.CWX_ID = '" + oModelPeri:GetValue( "MODEL_CWV", "CWV_ID" ) + "' "
cWhere2 := cWhere

cWhere += " AND CWX.CWX_RURAL = '0' "
cWhere2 += " AND CWX.CWX_RURAL = '1' "

cOrderBy := " T0O_IDPARB "

cSelect	 := "%" + cSelect  + "%"
cFrom  	 := "%" + cFrom    + "%"
cFrom2 	 := "%" + cFrom2   + "%"
cWhere 	 := "%" + cWhere   + "%"
cWhere2	 := "%" + cWhere2  + "%"
cOrderBy := "%" + cOrderBy + "%"

BeginSql Alias cAliasQry
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	UNION ALL 	
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom2%
	WHERE
		%Exp:cWhere2%	
	ORDER BY
		%Exp:cOrderBy%
EndSql

Return( cAliasQry )

/*/{Protheus.doc} LoadContaB
Carrega a conta da Parte B
@author david.costa
@since 22/12/2016
@version 1.0
@param cIdParteB, character, Id da Conta da Parte B
@param oModelParB, objeto, Objeto que receberá a conta da parte B
@param cFilParteB, character, Filial da Conta da Parte B
@return ${lRet}, ${Retorna verdadeiro se a conta for carregada corretamente}
@example
LoadContaB( cIdParteB, oModelParB, cFilParteB )
/*/Function LoadContaB( cIdParteB, oModelParB, cFilParteB )

Local lRet	as logical

lRet	:=	.F.

DBSelectArea( "T0S" )
T0S->( DbSetOrder( 1 ) )

If T0S->( MsSeek( cFilParteB + cIdParteB ) )
	oModelParB := FWLoadModel( 'TAFA436' )
	oModelParB:SetOperation( MODEL_OPERATION_UPDATE )
	oModelParB:Activate()
	lRet := .T.
EndIf

Return( lRet )

/*/{Protheus.doc} AddLanPrej
Adiciona um lançamento de prejuízo para o período apurado
@author david.costa
@since 26/12/2016
@version 1.0
@param cLogAvisos, character, Log de avisos do processo
@param oModelPeri, objeto, Passar por referência o objeto FWFormModel() do cadastro do período
@param aParametro, ${param_type}, Passar por referência o array com os pametros para a apuração
@param aParametr2, ${param_type}, Passar por referência o array com os pametros para a apuração
@return ${return}, ${return_description}
@example
AddLanPrej( @cLogAvisos, oModelPeri, aParametro )
/*/Static Function AddLanPrej( cLogAvisos, oModelPeri, aParametro, aParametr2 )

Local oModelParB	as object
Local cChave		as character

oModelParB	:=	Nil
cChave		:=	oModelPeri:GetValue( "MODEL_CWV", "CWV_ID" ) + StrZero( 0, 6 )

//Valor do prejuízo apurado
nVlrParteB := VlrLucReal( aParametro, aParametr2 ) * ( -1 )

//Seleciona a conta da Parte B do LALUR
ContParteB( aParametro, aParametr2, oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ) )

//Lançamento do Prejuízo Operacional
If aParametro[ VLR_PREJUIZO_OPERACIONAL ] > 0
	//Carrega a Conta
	If LoadContaB( XFUNCh2ID( MV_PAR01, "T0S", 2 ), @oModelParB, xFilial( "T0S" ) )
		AddLanParB( @oModelParB, aParametro[ VLR_PREJUIZO_OPERACIONAL ],, @cLogAvisos, cChave, oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ), EFEITO_CONSTITUIR_SALDO_PREJ,, oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ),, .F. )
		//Salva a Conta
		FWFormCommit( oModelParB )
		oModelParB:DeActivate()
	EndIf
EndIf

//Lançamento do Prejuízo Não Operacional
If aParametro[ VLR_PREJUIZO_NAO_OPERACIONAL ] > 0
	//Carrega a Conta
	If LoadContaB( XFUNCh2ID( MV_PAR03, "T0S", 2 ), @oModelParB, xFilial( "T0S" ) )
		AddLanParB( @oModelParB, aParametro[ VLR_PREJUIZO_NAO_OPERACIONAL ],, @cLogAvisos, cChave, oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ), EFEITO_CONSTITUIR_SALDO_PREJ,, oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ),, .F. )
		//Salva a Conta
		FWFormCommit( oModelParB )
		oModelParB:DeActivate()
	EndIf
EndIf

//Lançamento do Prejuízo Operacional
If aParametr2[ VLR_PREJUIZO_OPERACIONAL ] > 0
	//Carrega a Conta
	If LoadContaB( XFUNCh2ID( MV_PAR05, "T0S", 2 ), @oModelParB, xFilial( "T0S" ) )
		AddLanParB( @oModelParB, aParametr2[ VLR_PREJUIZO_OPERACIONAL ],, @cLogAvisos, cChave, oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ), EFEITO_CONSTITUIR_SALDO_PREJ,, oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ),, .T. )
		//Salva a Conta
		FWFormCommit( oModelParB )
		oModelParB:DeActivate()
	EndIf
EndIf

//Lançamento do Prejuízo Não Operacional
If aParametr2[ VLR_PREJUIZO_NAO_OPERACIONAL ] > 0
	//Carrega a Conta
	If LoadContaB( XFUNCh2ID( MV_PAR07, "T0S", 2 ), @oModelParB, xFilial( "T0S" ) )
		AddLanParB( @oModelParB, aParametr2[ VLR_PREJUIZO_NAO_OPERACIONAL ],, @cLogAvisos, cChave, oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ), EFEITO_CONSTITUIR_SALDO_PREJ,, oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ),, .T. )
		//Salva a Conta
		FWFormCommit( oModelParB )
		oModelParB:DeActivate()
	EndIf
EndIf

Return()

/*/{Protheus.doc} ContParteB
Seleciona uma conta da Parte B do LALUR
@author david.costa
@since 20/12/2016
@version 1.0
@param aParametro, ${param_type}, Passar por referência o array com os pametros para a apuração
@param aParametr2, ${param_type}, Passar por referência o array com os pametros para a apuração (Atividade Rural)
@param cIDTributo, caracter, Identificador do Tributo do período
@return ${Nil}, ${Nulo}
@example
ContParteB( aParametro, aParametr2, cIDTributo )
/*/Static Function ContParteB( aParametro, aParametr2, cIDTributo )

Local oDlg			as object
Local oFont		as object
Local oGroup1		as object
Local oGroup2		as object
Local cTitulo1	as character
Local cTitulo2	as character
Local cTitulo3	as character
Local cGrupo1		as character
Local cGrupo2		as character
Local nLarguraBox	as numeric
Local nAlturaBox	as numeric
Local nTop			as numeric
Local nAltura		as numeric
Local nLargura	as numeric
Local nPosIni		as numeric
Local lDivPrejui	as logical
Local lRural		as logical

oDlg			:=	Nil
oFont			:=	Nil
oGroup1		:=	Nil
oGroup2		:=	Nil
cTitulo1		:=	Eval( { || SX3->( DBSetOrder( 2 ) ), SX3->( MsSeek( "T0S_CODIGO" ) ), X3Titulo() } )
cTitulo2		:=	Eval( { || SX3->( DBSetOrder( 2 ) ), SX3->( MsSeek( "T0S_DESCRI" ) ), X3Titulo() } )
cTitulo3		:=	""
cGrupo1		:=	STR0089 //"Conta da Parte B do LALUR para o Prejuízo Operacional"
cGrupo2		:=	STR0090 //"Conta da Parte B do LALUR para o Prejuízo Não Operacional"
nLarguraBox	:=	0
nAlturaBox		:=	0
nTop			:=	0
nAltura		:=	255
nLargura		:=	500
nPosIni		:=	0
lDivPrejui		:=	.F.
lRural			:=	.F.

//Se tiver algum valor de prejuízo na Atividade Rural será solicitado as contas para geração dos lançamentos
If aParametro[ VLR_PREJUIZO_OPERACIONAL ] > 0 .or. aParametr2[ VLR_PREJUIZO_NAO_OPERACIONAL ] > 0
	nLargura := 1000
	cTitulo3 := cTitulo2 + " (Atividade Rural)"
	lRural := .T.
EndIf

If aParametro[ VLR_PREJUIZO_NAO_OPERACIONAL ] > 0 .or. aParametr2[ VLR_PREJUIZO_NAO_OPERACIONAL ] > 0
	nAltura := 235
	lDivPrejui := .T.
EndIf

If aParametro[ TIPO_TRIBUTO ] == TIPO_TRIBUTO_CSLL
	cGrupo1 := STR0091 //"Conta da Parte B do LALUR para a Base Negativa"
EndIf

//Solicita ao usuário os parametros para o processo
oFont := TFont():New( "Arial",, -11 )

oDlg := MsDialog():New( 0, 0, nAltura, nLargura, STR0092,,,,,,,,, .T. ) //"Lançamento de Prejuízo"

nAlturaBox := ( nAltura - 60 ) / 2
nLarguraBox := ( nLargura - 20 ) / 2

//Limpa as variáveis
MV_PAR08 := MV_PAR07 := MV_PAR06 := MV_PAR05 := MV_PAR04 := MV_PAR03 := MV_PAR02 := MV_PAR01 := ""

MV_PAR07 := MV_PAR05 := MV_PAR03 := MV_PAR01 := PadR( MV_PAR01, TamSx3( "T0S_CODIGO" )[1])
MV_PAR08 := MV_PAR06 := MV_PAR04 := MV_PAR02 := PadR( MV_PAR02, Tamsx3( "T0S_DESCRI" )[1])

//Conta da Parte B para o Prejuízo Operacional
nTop := 10
@ nTop, 010 GROUP oGroup1 TO 50, nLarguraBox PROMPT cGrupo1 OF oDlg PIXEL
nTop += 10
TGet():New( nTop, 20, { |x| If( PCount() == 0, MV_PAR01, MV_PAR01 := x ) }, oGroup1, 65, 10, "@!", { || ValidPartB( cIDTributo ) },,,,,, .T.,,,,,,,,, "T0S",,,,,,,, cTitulo1 , 1, oFont )
TGet():New( nTop, 90, { |x| If( PCount() == 0, MV_PAR02, MV_PAR02 := x ) }, oGroup1, 140, 10, "@!",,,,,,, .T.,,, { || .F. },,,,,,,,,,,,,, cTitulo2, 1, oFont )

If lRural
	TGet():New( nTop, 235, { |x| If( PCount() == 0, MV_PAR05, MV_PAR05 := x ) }, oGroup1, 65, 10, "@!", { || ValidPartB( cIDTributo ) },,,,,, .T.,,,,,,,,, "T0S",,,,,,,, cTitulo1 , 1, oFont )
	TGet():New( nTop, 305, { |x| If( PCount() == 0, MV_PAR06, MV_PAR06 := x ) }, oGroup1, 140, 10, "@!",,,,,,, .T.,,, { || .F. },,,,,,,,,,,,,, cTitulo3, 1, oFont )
EndIf

//Conta da Parte B para o Prejuízo Não Operacional
If lDivPrejui
	nTop += 33
	@ nTop, 010 GROUP oGroup2 TO 97, nLarguraBox PROMPT cGrupo2 OF oDlg PIXEL
	nTop += 10
	TGet():New( nTop, 20, { |x| If( PCount() == 0, MV_PAR03, MV_PAR03 := x ) }, oGroup2, 65, 10, "@!", { || ValidPartB( cIDTributo ) },,,,,, .T.,,,,,,,,, "T0S",,,,,,,, cTitulo1 , 1, oFont )
	TGet():New( nTop, 90, { |x| If( PCount() == 0, MV_PAR04, MV_PAR04 := x ) }, oGroup2, 140, 10, "@!",,,,,,, .T.,,, { || .F. },,,,,,,,,,,,,, cTitulo2, 1, oFont )
	
	If lRural
		TGet():New( nTop, 235, { |x| If( PCount() == 0, MV_PAR07, MV_PAR07 := x ) }, oGroup2, 65, 10, "@!", { || ValidPartB( cIDTributo ) },,,,,, .T.,,,,,,,,, "T0S",,,,,,,, cTitulo1 , 1, oFont )
		TGet():New( nTop, 305, { |x| If( PCount() == 0, MV_PAR08, MV_PAR08 := x ) }, oGroup2, 140, 10, "@!",,,,,,, .T.,,, { || .F. },,,,,,,,,,,,,, cTitulo3, 1, oFont )
	EndIf
EndIf

nPosIni := ( ( nLargura - 20 ) / 2 ) - 32

SButton():New( nAlturaBox + 10, nPosIni, 1, { |x| Iif( ValidPartB( cIDTributo ), x:oWnd:End(), ) }, oDlg )

oDlg:Activate( ,,,.T. )

Return()

/*/{Protheus.doc} ValidPartB
Valida se os parâmetros informados estão corretos
@author david.costa
@since 26/12/2016
@version 1.0
@param cIDTributo, character, Identificador do Tributo do período
@return ${lRet}, ${lRet}
@example
ValidPartB( cIDTributo )
/*/Static Function ValidPartB( cIDTributo )

Local lRet	as logical
Local cErro	as character

lRet	:=	.T.
cErro	:= ""

DbSelectArea( "LE9" )
LE9->( DBSetOrder( 1 ) )
T0S->( DBSetOrder( 2 ) )

If !Empty( MV_PAR01 )
	If !T0S->( MsSeek( xFilial("T0S") + MV_PAR01 ) )
		cErro += STR0061 + ENTER //"Código inexistente"
	ElseIf !LE9->( MsSeek( xFilial( "LE9" ) + T0S->T0S_ID + cIDTributo ) )
		cErro += STR0168 + ENTER //"A conta selecionada deverá possuir o mesmo tributo informado no Período de Apuração"
		MV_PAR01 := PadR( MV_PAR01, TamSx3( "T0S_CODIGO" )[1])
	Else
		MV_PAR02 := AllTrim( T0S->T0S_DESCRI )
	EndIf
EndIf

If !Empty( MV_PAR03 )
	If !T0S->( MsSeek( xFilial("T0S") + MV_PAR03 ) )
		cErro += STR0061 + ENTER //"Código inexistente"
	ElseIf !LE9->( MsSeek( xFilial( "LE9" ) + T0S->T0S_ID + cIDTributo ) )
		cErro += STR0168 + ENTER //"A conta selecionada deverá possuir o mesmo tributo informado no Período de Apuração"
		MV_PAR03 := PadR( MV_PAR03, TamSx3( "T0S_CODIGO" )[1])
	Else
		MV_PAR04 := AllTrim( T0S->T0S_DESCRI )
	EndIf
EndIf

If !Empty( MV_PAR05 )
	If !T0S->( MsSeek( xFilial("T0S") + MV_PAR05 ) )
		cErro += STR0061 + ENTER //"Código inexistente"
	ElseIf !LE9->( MsSeek( xFilial( "LE9" ) + T0S->T0S_ID + cIDTributo ) )
		cErro += STR0168 + ENTER //"A conta selecionada deverá possuir o mesmo tributo informado no Período de Apuração"
		MV_PAR05 := PadR( MV_PAR05, TamSx3( "T0S_CODIGO" )[1])
	Else
		MV_PAR06 := AllTrim( T0S->T0S_DESCRI )
	EndIf
EndIf

If !Empty( MV_PAR07 )
	If !T0S->( MsSeek( xFilial("T0S") + MV_PAR07 ) )
		cErro += STR0061 + ENTER //"Código inexistente"
	ElseIf !LE9->( MsSeek( xFilial( "LE9" ) + T0S->T0S_ID + cIDTributo ) )
		cErro += STR0168 + ENTER //"A conta selecionada deverá possuir o mesmo tributo informado no Período de Apuração"
		MV_PAR07 := PadR( MV_PAR07, TamSx3( "T0S_CODIGO" )[1])
	Else
		MV_PAR08 := AllTrim( T0S->T0S_DESCRI )
	EndIf
EndIf

If !Empty( cErro )
	MsgInfo( cErro ) //"Código inexistente"
	lRet := .F.
EndIf

Return( lRet )

/*/{Protheus.doc} DadosLanRe
Seleciona ao usuário as contas para os itens com valores remanescentes
@author david.costa
@since 28/12/2016
@version 1.0
@param aItensRema, array, Lista de Itens com valores remanescentes
@return ${oGetDB}, ${Objeto MsNewGetDados}
@example
DadosLanRe( aItensRema )
/*/Static Function DadosLanRe( aItensRema )

Local nOpc			as numeric
Local aSizeAuto	as array

Private oDlg		as object
Private oGetDB	as object
Private aHeader	as array
Private aCols		as array

nOpc		:=	GD_UPDATE
aSizeAuto	:=	MsAdvSize()

oDlg		:=	Nil
oGetDB		:=	Nil
aHeader	:=	{}
aCols		:=	aItensRema

GetHeadCols()

oDlg := MSDialog():New( 091,232,502,1200,STR0087,,,.F.,,,,,,.T.,,,.T. ) //"Lançamentos Automáticos"

oGetDB := MsNewGetDados():New(024, 016, aSizeAuto[6] -50, aSizeAuto[5] -50, nOpc, "AllwaysTrue", "AllwaysTrue", "", { "CODPAB" } ,;
0 , 99, "SetDesCont", "", "AllwaysTrue", oDlg, aHeader, aCols)

//Carrega a lista de itens ( As linhas da grid )
oGetDB:SetArray( aCols,.T.)
oGetDB:Refresh()

oGetDB:obrowse:align:= CONTROL_ALIGN_ALLCLIENT

oDlg:bInit := EnchoiceBar( oDlg, { || VldLine() }, { || oDlg:End() } )
oDlg:lCentered := .T.
oDlg:Activate()

Return( oGetDB )

/*/{Protheus.doc} VldLine
Valida a linha da grid
@author david.costa
@since 28/12/2016
@version 1.0
@return ${lOk}, ${lOk}
@example
VldLine()
/*/Static Function VldLine()

Local nI	as numeric
Local lOk	as logical

nI	:=	0
lOk	:=	.T.

For nI := 1 To Len( oGetDB:aCols )
	If Empty( oGetDB:aCols[nI][5] )
		If !MsgYesNo( STR0085, STR0015 ) //"Alguns Itens não foram preenchidos, deseja continuar mesmo assim?";Atenção
			lOk := .F.
		EndIf
	EndIf
Next nI

If lOk
	oDlg:End()
EndIf

Return( lOk )

/*/{Protheus.doc} GetHeadCols
Cria o cabeçalho da grid dos itens com valor remanescente
@author david.costa
@since 28/12/2016
@version 1.0
@return ${Nil}, ${Nulo}
@example
GetHeadCols() 
/*/Static Function GetHeadCols()

Aadd(aHeader, {;
              "Grupo",;		//X3Titulo()
              "DESCGRUPO",;	//X3_CAMPO
              "@!",;			//X3_PICTURE
              25,;			//X3_TAMANHO
              0,;			//X3_DECIMAL
              "",;			//X3_VALID
              "",;			//X3_USADO
              "C",;			//X3_TIPO
              "",; 			//X3_F3
              "V",;			//X3_CONTEXT
              "",;			//X3_CBOX
              "",;			//X3_RELACAO
              .F.})			//X3_WHEN
Aadd(aHeader, {;
              "Item do Grupo",;//X3Titulo()
              "ITEM",;  	//X3_CAMPO
              "@!",;			//X3_PICTURE
              6,;			//X3_TAMANHO
              0,;			//X3_DECIMAL
              "",;			//X3_VALID
              "",;			//X3_USADO
              "C",;			//X3_TIPO
              "",; 			//X3_F3
              "V",;			//X3_CONTEXT
              "",;			//X3_CBOX
              "",;			//X3_RELACAO
              .F.})			//X3_WHEN
Aadd(aHeader, {;
              "Valor Apurado",;	//X3Titulo()
              "VLRAPURADO",;  	//X3_CAMPO
              "@E 9,999,999,999,999.99",;			//X3_PICTURE
              16,;			//X3_TAMANHO
              2,;			//X3_DECIMAL
              "",;			//X3_VALID
              "",;			//X3_USADO
              "N",;			//X3_TIPO
              "",;		//X3_F3
              "V",;			//X3_CONTEXT
              "",;			//X3_CBOX
              "",;			//X3_RELACAO
              .F.})			//X3_WHEN
Aadd(aHeader, {;
              "Valor Remascente",;	//X3Titulo()
              "REMASCENTE",;  	//X3_CAMPO
              "@E 9,999,999,999,999.99",;		//X3_PICTURE
              16,;			//X3_TAMANHO
              2,;			//X3_DECIMAL
              "",;			//X3_VALID
              "",;			//X3_USADO
              "N",;			//X3_TIPO
              "",;			//X3_F3
              "V",;			//X3_CONTEXT
              "",;			//X3_CBOX
              "",;			//X3_RELACAO
              .F.})			//X3_WHEN

Aadd(aHeader, {;
              "Conta LALUR Parte B",;	//X3Titulo()
              "CODPAB",;  	//X3_CAMPO
              "@!",;		//X3_PICTURE
              60,;			//X3_TAMANHO
              0,;			//X3_DECIMAL
              "",;			//X3_VALID
              "",;			//X3_USADO
              "C",;			//X3_TIPO
              "T0SA",;		//X3_F3
              "R",;			//X3_CONTEXT
              "",;			//X3_CBOX
              "",;			//X3_RELACAO
              .F.})			//X3_WHEN

Aadd(aHeader, {;
              "Descrição",;	//X3Titulo()
              "DESCRICAO",;  	//X3_CAMPO
              "@!",;		//X3_PICTURE
              50,;			//X3_TAMANHO
              0,;			//X3_DECIMAL
              "",;			//X3_VALID
              "",;			//X3_USADO
              "C",;			//X3_TIPO
              "",;			//X3_F3
              "V",;			//X3_CONTEXT
              "",;			//X3_CBOX
              "",;			//X3_RELACAO
              .F.})			//X3_WHEN

Aadd(aHeader, {;
              "Tabela Dinamica ECF",;	//X3Titulo()
              "TDECF",;  	//X3_CAMPO
              "@!",;		//X3_PICTURE
              60,;			//X3_TAMANHO
              0,;			//X3_DECIMAL
              "",;			//X3_VALID
              "",;			//X3_USADO
              "C",;			//X3_TIPO
              "",;			//X3_F3
              "V",;			//X3_CONTEXT
              "",;			//X3_CBOX
              "",;			//X3_RELACAO
              .F.})			//X3_WHEN
 
Return()

/*/{Protheus.doc} AddItemRem
Preenche a lista de itens com valores remanescentes
@author david.costa
@since 28/12/2016
@version 1.0
@param aItensRema, array, lista de itens com valores remanescentes
@param nValItem, numérico, Valor do Item
@param nValRemane, numérico, Valor remanescente para o item
@param cAliasQry, character, Dados para o lançamento da parte B
@return ${Nil}, ${Nulo}
@example
AddItemRem( @aItensRema, nValItem, nValRemane, cAliasQry )
/*/Static Function AddItemRem( aItensRema, nValItem, nValRemane, cAliasQry )

//DESCGRUPO, ITEM, VLRAPURADO, REMASCENTE, CODPAB, DESCRICAO, TDECF, CHAVE, EFEITO
aAdd( aItensRema, { ( cAliasQry )->LEE_DESCRI, ( cAliasQry )->T0O_SEQITE, nValItem, nValRemane, Space(60), ,;
( cAliasQry )->DESCRICAO, ( cAliasQry )->CHAVE, ( cAliasQry )->T0O_EFEITO, ( cAliasQry )->T0O_IDGRUP, .F.  })

Return()

/*/{Protheus.doc} SetDesCont
Preenche a Descrição da conta da parte B na tela de manipulação das contas
@author david.costa
@since 28/12/2016
@version 1.0
@return ${.T.}, ${Verdadeiro}
@example
SetDesCont()
/*/Function SetDesCont()

Local cDescricao	as character

cDescricao	:=	""

If !Empty( &(READVAR()) )
	cDescricao := Posicione( "T0S", 2, xFilial("T0S") + &(READVAR()), "T0S_DESCRI" )
EndIf

oGetDB:aCols[n][6] := cDescricao
oGetDB:Refresh()

Return( .T. )

/*/{Protheus.doc} TAFA444EDA
Processo para apagar os documentos de arrecadação vinculados ao período
@author david.costa
@since 04/01/2017
@version 1.0
@return ${Nil}, ${Nulo}
@example
TAFA444EDA()
/*/Function TAFA444EDA( )

Local cNomWiz		as character
Local lEnd			as logical

Private oProcess	as object

cNomWiz	:=	""
lEnd		:=	.F.

oProcess	:=	Nil

If GetTpTribu( CWV->CWV_IDTRIB ) == TIPO_TRIBUTO_IRPJ .or. GetTpTribu( CWV->CWV_IDTRIB ) == TIPO_TRIBUTO_CSLL
	cNomWiz := STR0097 //"Excluindo guias DARF"

	//Cria objeto de controle do processamento
	oProcess := TAFProgress():New( { |lEnd| ExcluiDARF() }, cNomWiz )
	oProcess:Activate()

Else
	ShowLog( STR0015, STR0067 )//"Atenção"; "Este processo só pode ser executado para os tributos IRPJ ou CSLL"
EndIf

//Limpando a memória
DelClassIntf()

Return()

/*/{Protheus.doc} ExcluiDARF
Apaga os documentos de arrecadação vinculados ao período
@author david.costa
@since 04/01/2017
@version 1.0
@return ${Nil}, ${Nulo}
@example
ExcluiDARF()
/*/Static Function ExcluiDARF( )

Local oModelPeri	as object
Local oModelT50		as object
Local oModelDA		as object
Local cLogErros		as character
Local cLogAvisos	as character
Local nProgress1	as numeric
Local nProgress2	as numeric
Local nIndiceT50	as numeric
Local nQtd			as numeric

Private cListKey	as character

oModelPeri	:=	Nil
oModelT50	:=	Nil
oModelDA	:=	Nil
cLogErros	:=	""
cLogAvisos	:=	""
nProgress1	:=	1
nProgress2	:=	1
nIndiceT50	:=	0
nQtd		:=	0

cListKey	:=	""

oProcess:Set1Progress( nProgress1 )
oProcess:Set2Progress( nProgress2 )

oModelPeri := FWLoadModel( 'TAFA444' )
oModelPeri:SetOperation( MODEL_OPERATION_UPDATE )
oModelPeri:Activate()
oModelT50 := oModelPeri:GetModel( "MODEL_T50" )

GetGuias( oModelPeri:GetValue( "MODEL_CWV", "CWV_ID" ) )

For nIndiceT50 := 1 to oModelT50:Length()
	oModelT50:GoLine( nIndiceT50 )

	If !oModelT50:IsDeleted() .and. !Empty( oModelT50:GetValue( "T50_IDGUIA" ) ) .and. oModelT50:GetValue( "T50_IDGUIA" ) $ cListKey
		DBSelectArea( "C0R" )
		C0R->( DbSetOrder( 6 ) )
		If C0R->( MsSeek( xFilial( "C0R" ) + oModelT50:GetValue( "T50_IDGUIA" ) ) )
			//Carrega o Documento de Arrecadação
			oModelDA := FWLoadModel( 'TAFA027' )
			oModelDA:SetOperation( MODEL_OPERATION_DELETE )
			oModelDA:Activate()

			//Apaga a referência no período
			oModelT50:DeleteLine()

			//Salva o Documento de Arrecadação
			FWFormCommit( oModelDA )

			//Salva o Período
			FWFormCommit( oModelPeri )

			//Fecha o Documento de Arrecadação
			oModelDA:DeActivate()

			//Incrementa o contador de guias apagadas
			nQtd++
		EndIf
	EndIf
Next nIndiceT50

oProcess:Set1Progress( 1 )


//Em caso de Erros
If !Empty( cLogErros )
	//Apresentando Log do processo
	oProcess:Inc1Progress( STR0094 )//"Erro ao estornar guia DARF"
	oProcess:nCancel := 1
	
	If !Empty( cLogErros )
		ShowLog( STR0015, cLogErros )//"Atenção"
	EndIf
Else
	oProcess:Inc1Progress( FormatStr( STR0095, { nQtd } ) )//"Foi (ram) deletado(s) @1 documento(s) de arrecadação"
EndIf

oProcess:Inc2Progress( STR0034 ) //"Clique em finalizar"

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF444Open

Funcionalidade de Reabertura do Período de Apuração.

@Author		Felipe C. Seolin
@Since		21/12/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAF444Open(lAutomato)

Local oModel		as object
Local cMessage	as character

Default lAutomato := .F.

oModel		:=	FWLoadModel( "TAFA444" )
cMessage	:=	""

oModel:SetOperation( MODEL_OPERATION_UPDATE )
oModel:Activate()

Taf444Reabrir( @oModel, @cMessage )

If !Empty( cMessage ) .And. !lAutomato
	ShowLog( STR0076, cMessage ) //"Reabertura do Período"
EndIf

Return()

/*/{Protheus.doc} Taf444Reabrir
Processa a reabertra do período
@author david.costa
@since 18/12/2017
@version 1.0
@param oModel, objeto, Objeto do período
/*/
Function Taf444Reabrir( oModel, cMessage )

Local lOk	as logical

lOk		:=	.T.

If oModel:GetModel( "MODEL_CWV" ):GetValue( "CWV_STATUS" ) == PERIODO_ENCERRADO	
	If GetTpTribu( oModel:GetModel( "MODEL_CWV" ):GetValue( "CWV_IDTRIB" ) ) == TIPO_TRIBUTO_IRPJ .or. GetTpTribu( oModel:GetModel( "MODEL_CWV" ):GetValue( "CWV_IDTRIB" ) ) == TIPO_TRIBUTO_CSLL
		If ValidOpen( oModel, @cMessage )
			Processa( { || lOk := ProcReOpen( @oModel, @cMessage ), STR0078, STR0079 } ) //##"Processando" ##"Estornando Encerramento do Período"

			If lOk
				cMessage += STR0084 + ENTER + cMessage //"O processamento da reabertura do período foi realizado com sucesso!"
			Else
				cMessage += STR0122 + ENTER + cMessage //"Falha no processamento da reabertura do período!"
			EndIf
		EndIf
	Else
		cMessage += STR0067 //"Este processo só pode ser executado para os tributos IRPJ ou CSLL."
	EndIf
Else
	cMessage += STR0069 //"Este processo só pode ser executado com o período encerrado."
EndIf

oModel:DeActivate()
oModel:Destroy()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidOpen

Função que concentra as validações da Reabertura do Período de Apuração.

@Param		oModel		- Objeto do modelo MVC
			cMessage	- Mensagem de log de ocorrências

@Return		lRet		- Indica se todas as condições foram respeitadas

@Author		Felipe C. Seolin
@Since		21/12/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ValidOpen( oModel, cMessage )

Local lRet	as logical

lRet	:=	ValidPeriod( oModel, @cMessage )

If !ValidRPF( oModel, @cMessage ) .and. lRet
	lRet := .F.
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidPeriod

Validação de Períodos de Apuração posteriores já encerrados.

@Param		oModel		- Objeto do modelo MVC
			cMessage	- Mensagem de log de ocorrências

@Return		lRet		- Indica se todas as condições foram respeitadas

@Author		Felipe C. Seolin
@Since		21/12/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ValidPeriod( oModel, cMessage )

Local oModelCWV	as object
Local cAliasQry	as character
Local cSelect	as character
Local cFrom		as character
Local cWhere	as character
Local lRet		as logical

oModelCWV	:=	oModel:GetModel( "MODEL_CWV" )
cAliasQry	:=	GetNextAlias()
cSelect		:=	""
cFrom		:=	""
cWhere		:=	""
lRet		:=	.T.

//***************************************
// Busca Períodos posteriores encerrados
//***************************************
cSelect := "CWV.CWV_INIPER, CWV.CWV_FIMPER, CWV.CWV_DESCRI, CWV.CWV_STATUS "

cFrom := RetSqlName( "CWV" ) + " CWV "

cWhere := "    CWV.CWV_FILIAL = '" + xFilial( "CWV" ) + "' "
cWhere += "AND ( CWV.CWV_INIPER >= '" + DToS( oModelCWV:GetValue( "CWV_FIMPER" ) ) + "' OR CWV.CWV_FIMPER >= '" + DToS( oModelCWV:GetValue( "CWV_FIMPER" ) ) + "' ) "
cWhere += "AND CWV.CWV_IDTRIB = '" + oModelCWV:GetValue( "CWV_IDTRIB" ) + "' "
cWhere += "AND CWV.CWV_STATUS = '" + PERIODO_ENCERRADO + "' "
cWhere += "AND CWV.CWV_ID <> '" + oModelCWV:GetValue( "CWV_ID" ) + "' "
cWhere += "AND CWV.D_E_L_E_T_ = '' "

If oModelCWV:GetValue( "CWV_ANUAL" )
	cWhere += "AND SUBSTRING( CWV_INIPER, 1, 4 ) > '" + SubStr( DToS( oModelCWV:GetValue( "CWV_INIPER" ) ), 1, 4 ) + "' "
	cWhere += "AND SUBSTRING( CWV_FIMPER, 1, 4 ) > '" + SubStr( DToS( oModelCWV:GetValue( "CWV_FIMPER" ) ), 1, 4 ) + "' "
EndIf

cSelect  := "%" + cSelect  + "%"
cFrom    := "%" + cFrom    + "%"
cWhere   := "%" + cWhere   + "%"

BeginSql Alias cAliasQry

	column CWV_INIPER as Date
	column CWV_FIMPER as Date

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%

EndSql

If ( cAliasQry )->( !Eof() )
	lRet	:= .F.

	cMessage += " • " + STR0080 //"Existe(m) Período(s) encerrado(s) que não permite(m) a reabertura deste Período:"
	cMessage += ENTER

	While ( cAliasQry )->( !Eof() )
		cMessage += ENTER
		cMessage += STR0081 + ": " + DToC( ( cAliasQry )->CWV_INIPER ) + " à " + DToC( ( cAliasQry )->CWV_FIMPER ) //"Período"
		cMessage += ENTER
		cMessage += STR0082 + ": " + AllTrim( ( cAliasQry )->CWV_DESCRI ) //"Descrição"
		cMessage += ENTER
		cMessage += STR0083 + ": " + X3Combo( "CWV_STATUS", ( cAliasQry )->CWV_STATUS ) //"Status"
		cMessage += ENTER

		( cAliasQry )->( DBSkip() )
	EndDo
EndIf

( cAliasQry )->( DBCloseArea() )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidRPF

Validação de existência de Reclassificação do Prejuízo Fiscal.

@Param		oModel		- Objeto do modelo MVC
			cMessage	- Mensagem de log de ocorrências

@Return		lRet		- Indica se todas as condições foram respeitadas

@Author		Felipe C. Seolin
@Since		21/12/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ValidRPF( oModel, cMessage )

Local oModelCWV	as object
Local cAliasQry	as character
Local cSelect	as character
Local cFrom		as character
Local cWhere	as character
Local lRet		as logical

oModelCWV	:=	oModel:GetModel( "MODEL_CWV" )
cAliasQry	:=	GetNextAlias()
cSelect		:=	""
cFrom		:=	""
cWhere		:=	""
lRet		:=	.T.

//********************************************************************
// Busca Lançamentos na Parte B de origem Reclassificação do Prejuízo
//********************************************************************
cSelect := "T0S.T0S_CODIGO, T0S.T0S_DESCRI, T0J.T0J_CODIGO, T0J.T0J_DESCRI, T0T.T0T_CODLAN, T0T.T0T_DTLANC, T0T.T0T_TPLANC "

cFrom := RetSqlName( "T0S" ) + " T0S "

cFrom += "INNER JOIN " + RetSqlName( "LE9" ) + " LE9 "
cFrom += "   ON LE9.LE9_FILIAL = T0S.T0S_FILIAL "
cFrom += "  AND LE9.LE9_ID = T0S.T0S_ID "
cFrom += "  AND LE9.LE9_IDCODT = '" + oModelCWV:GetValue( "CWV_IDTRIB" ) + "' "
cFrom += "  AND LE9.D_E_L_E_T_ = '' "

cFrom += "INNER JOIN " + RetSqlName( "T0T" ) + " T0T "
cFrom += "   ON T0T.T0T_FILIAL = LE9.LE9_FILIAL "
cFrom += "  AND T0T.T0T_ID = LE9.LE9_ID "
cFrom += "  AND T0T.T0T_IDCODT = LE9.LE9_IDCODT "
cFrom += "  AND T0T.T0T_ORIGEM = '" + ORIGEM_RELASSICIFICACAO_PREJ + "' "
cFrom += "  AND T0T.T0T_DTLANC BETWEEN '" + DToS( oModelCWV:GetValue( "CWV_INIPER" ) ) + "' AND '" + DToS( oModelCWV:GetValue( "CWV_FIMPER" ) ) + "' "
cFrom += "  AND T0T.D_E_L_E_T_ = '' "

cFrom += "LEFT JOIN " + RetSqlName( "T0J" ) + " T0J "
cFrom += "  ON T0J.T0J_FILIAL = '" + xFilial( "T0J" ) + "' "
cFrom += " AND T0J.T0J_ID = LE9.LE9_IDCODT "
cFrom += " AND T0J.D_E_L_E_T_ = '' "

cWhere := "    T0S.T0S_FILIAL = '" + xFilial( "T0S" ) + "' "
cWhere += "AND T0S.D_E_L_E_T_ = '' "

cSelect  := "%" + cSelect  + "%"
cFrom    := "%" + cFrom    + "%"
cWhere   := "%" + cWhere   + "%"

BeginSql Alias cAliasQry

	column T0T_DTLANC as Date

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%

EndSql

If ( cAliasQry )->( !Eof() )
	lRet	:= .F.

	If !Empty( cMessage )
		cMessage += ENTER
		cMessage += ENTER
	EndIf

	cMessage += " • " + STR0098 //"Existe(m) Lançamento(s) na Parte B de origem Reclassificação do Prejuízo que não permite(m) a reabertura deste Período:"
	cMessage += ENTER

	While ( cAliasQry )->( !Eof() )
		cMessage += ENTER
		cMessage += STR0099 + ": " + AllTrim( ( cAliasQry )->T0S_CODIGO ) + " - " + AllTrim( ( cAliasQry )->T0S_DESCRI ) //"Conta"
		cMessage += ENTER
		cMessage += STR0002 + ": " + AllTrim( ( cAliasQry )->T0J_CODIGO ) + " - " + AllTrim( ( cAliasQry )->T0J_DESCRI ) //"Tributo"
		cMessage += ENTER
		cMessage += STR0100 + ": " + AllTrim( ( cAliasQry )->T0T_CODLAN ) + " - " //"Lançamento"
		cMessage += STR0101 + ": " + DToC( ( cAliasQry )->T0T_DTLANC ) + " - " //"Data"
		cMessage += STR0102 + ": " + X3Combo( "T0T_TPLANC", ( cAliasQry )->T0T_TPLANC ) //"Tipo"
		cMessage += ENTER

		( cAliasQry )->( DBSkip() )
	EndDo
EndIf

( cAliasQry )->( DBCloseArea() )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcReOpen

Processa a Reabertura do Período de Apuração.

@Param		oModel		- Objeto do modelo MVC
			cMessage	- Mensagem de log de ocorrências

@Return		lCommit	- Indica se as operações foram realizadas

@Author		Felipe C. Seolin
@Since		22/12/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ProcReOpen( oModel, cMessage )

Local oModelCWV	as object
Local oModelCWX	as object
Local oModelT50	as object
Local oModelC0R	as object
Local oModelT0S	as object
Local oModelLE9	as object
Local oModelT0T	as object
Local cSuccess	as character
Local cWarning	as character
Local cDisarm	as character
Local cAliasQry	as character
Local cSelect	as character
Local cFrom		as character
Local cWhere	as character
Local cLoop		as character
Local nI		as numeric
Local lCommit	as logical

oModelCWV	:=	oModel:GetModel( "MODEL_CWV" )
oModelCWX	:=	oModel:GetModel( "MODEL_CWX" )
oModelT50	:=	oModel:GetModel( "MODEL_T50" )
oModelC0R	:=	Nil
oModelT0S	:=	Nil
oModelLE9	:=	Nil
oModelT0T	:=	Nil
cSuccess	:=	""
cWarning	:=	""
cDisarm		:=	""
cAliasQry	:=	GetNextAlias()
cSelect		:=	""
cFrom		:=	""
cWhere		:=	""
cLoop		:=	""
nI			:=	0
lCommit		:=	.T.

Begin Transaction

	//*****************************
	// Estorna valores da Apuração
	//*****************************
	oModelCWV:LoadValue( "CWV_STATUS", PERIODO_ABERTO )
	oModelCWV:LoadValue( "CWV_IDEVEN", "" )
	oModelCWV:LoadValue( "CWV_TOALQ1", 0 )
	oModelCWV:LoadValue( "CWV_TOALQ2", 0 )
	oModelCWV:LoadValue( "CWV_TOALQ3", 0 )
	oModelCWV:LoadValue( "CWV_TOALQ4", 0 )
	oModelCWV:LoadValue( "CWV_TOTISE", 0 )
	oModelCWV:LoadValue( "CWV_DEDUCA", 0 )
	oModelCWV:LoadValue( "CWV_COMPEN", 0 )
	oModelCWV:LoadValue( "CWV_APAGAR", 0 )
	oModelCWV:LoadValue( "CWV_TOTDEM", 0 )
	oModelCWV:LoadValue( "CWV_EXCLUS", 0 )
	oModelCWV:LoadValue( "CWV_PERPRE", 0 )
	oModelCWV:LoadValue( "CWV_VLPREJ", 0 )
	oModelCWV:LoadValue( "CWV_OPERAC", 0 )
	oModelCWV:LoadValue( "CWV_NAOOPE", 0 )
	oModelCWV:LoadValue( "CWV_ADICIO", 0 )
	oModelCWV:LoadValue( "CWV_RCATIV", 0 )
	oModelCWV:LoadValue( "CWV_LUCEXP", 0 )
	oModelCWV:LoadValue( "CWV_TRIADI", 0 )
	oModelCWV:LoadValue( "CWV_POPERA", 0 )
	oModelCWV:LoadValue( "CWV_PNAOOP", 0 )
	
	cSuccess += "- " + STR0108 + " '" + X3Combo( "CWV_STATUS", oModelCWV:GetValue( "CWV_STATUS" ) ) + "'." //"Status do Período de Apuração alterado para"
	cSuccess += ENTER
	cSuccess += "- " + STR0109 //"Valores calculados pelo encerramento do Período anulados."
	cSuccess += ENTER

	//*******************************************
	// Apaga valores do Detalhamento da Apuração
	//*******************************************
	For nI := 1 to oModelCWX:Length()
		oModelCWX:GoLine( nI )

		If !oModelCWX:IsEmpty()
			If !oModelCWX:DeleteLine()
				lCommit := .F.

				If At( STR0123, cDisarm ) <= 0 //"Falha na remoção dos Itens do Detalhamento da Apuração devido a consistência de dados"
					cDisarm += " • " + STR0123 + ":" //"Falha na remoção dos Itens do Detalhamento da Apuração devido a consistência de dados"
					cDisarm += ENTER
					cDisarm += ENTER
				EndIf

				cDisarm += STR0124 + ": " + oModelCWX:GetValue( "CWX_SEQDET" ) //"Sequência Detalhe"
				cDisarm += ENTER
				cDisarm += STR0125 + ": " + X3Combo( "CWX_ORIGEM", oModelCWX:GetValue( "CWX_ORIGEM" ) ) //"Origem"
				cDisarm += ENTER
				cDisarm += STR0126 + ": " + AllTrim( Posicione( "LEE", 1, xFilial( "LEE" ) + oModelCWX:GetValue( "CWX_IDCODG" ), "LEE_DESCRI" ) ) + " - " //"Grupo"
				cDisarm += STR0127 + ": " + Val2Str( oModelCWX:GetValue( "CWX_VALOR" ), 16, 2 ) //"Valor"
				cDisarm += ENTER
				cDisarm += ENTER

			EndIf
		EndIf
	Next nI

	cSuccess += "- " + STR0110 //"Itens do Detalhamento da Apuração inseridos no encerramento do Período removidos."
	cSuccess += ENTER

	//****************************************
	// Apaga Guias vinculadas a Apuração:
	// - Apuração
	// - Cadastro de Documento de Arrecadação
	// Obs: Apenas se não estiverem pagas
	//****************************************
	DBSelectArea( "C0R" )
	C0R->( DBSetOrder( 6 ) )

	For nI := 1 to oModelT50:Length()

		oModelT50:GoLine( nI )

		If !oModelT50:IsEmpty() .and. C0R->( MsSeek( xFilial( "C0R" ) + oModelT50:GetValue( "T50_IDGUIA" ) ) )
			If C0R->C0R_STPGTO == STATUS_EM_ABERTO
				oModelC0R := FWLoadModel( "TAFA027" )
				oModelC0R:SetOperation( MODEL_OPERATION_DELETE )
				oModelC0R:Activate()
				FWFormCommit( oModelC0R )
				oModelC0R:DeActivate()

				If !oModelT50:DeleteLine()
					lCommit := .F.

					If At( STR0128, cDisarm ) <= 0 //"Falha na remoção dos Documentos de Arrecadação devido a consistência de dados"
						If !Empty( cDisarm )
							cDisarm += ENTER
						EndIf

						cDisarm += " • " + STR0128 + ":" //"Falha na remoção dos Documentos de Arrecadação devido a consistência de dados"
						cDisarm += ENTER
						cDisarm += ENTER
					EndIf

					cDisarm += STR0104 + ": " + AllTrim( C0R->C0R_NUMDA ) + " - " + AllTrim( C0R->C0R_DESDOC ) //"Documento de Arrecadação"
					cDisarm += ENTER
					cDisarm += STR0083 + ": " + X3Combo( "C0R_STPGTO", C0R->C0R_STPGTO ) //"Status"
					cDisarm += ENTER
					cDisarm += STR0105 + ": " + DToC( C0R->C0R_DTPGT ) + " - " //"Data Pagamento"
					cDisarm += STR0106 + ": " + Val2Str( C0R->C0R_VLDA, 16, 2 ) + " - " //"Valor DA"
					cDisarm += STR0107 + ": " + Val2Str( C0R->C0R_VLPAGO, 16, 2 ) //"Valor Pago"
					cDisarm += ENTER
					cDisarm += ENTER
				EndIf

				cSuccess += "- " + STR0104 + ": " + AllTrim( C0R->C0R_NUMDA ) + " - " + AllTrim( C0R->C0R_DESDOC ) //"Documento de Arrecadação"
				cSuccess += " " + STR0111 //"apagado do sistema, assim como seu vínculo com o Período de Apuração."
				cSuccess += ENTER
			Else
				If At( STR0103, cWarning ) <= 0
					cWarning += " • " + STR0103 + ":" //"A(s) Guia(s) abaixo não foi(ram) removida(s) do sistema pois já foi(ram) efetuado(s) pagamento(s)"
					cWarning += ENTER
					cWarning += ENTER
				EndIf

				cWarning += STR0104 + ": " + AllTrim( C0R->C0R_NUMDA ) + " - " + AllTrim( C0R->C0R_DESDOC ) //"Documento de Arrecadação"
				cWarning += ENTER
				cWarning += STR0083 + ": " + X3Combo( "C0R_STPGTO", C0R->C0R_STPGTO ) //"Status"
				cWarning += ENTER
				cWarning += STR0105 + ": " + DToC( C0R->C0R_DTPGT ) + " - " //"Data Pagamento"
				cWarning += STR0106 + ": " + Val2Str( C0R->C0R_VLDA, 16, 2 ) + " - " //"Valor DA"
				cWarning += STR0107 + ": " + Val2Str( C0R->C0R_VLPAGO, 16, 2 ) //"Valor Pago"
				cWarning += ENTER
				cWarning += ENTER
			EndIf
		EndIf

	Next nI

	//********************************************************************
	// Apaga Lançamentos na Parte B gerados pelo Encerramento da Apuração
	//********************************************************************
	cSelect := "T0S.R_E_C_N_O_ T0S_RECNO, LE9.LE9_IDCODT, T0T.T0T_CODLAN "

	cFrom := RetSqlName( "T0S" ) + " T0S "

	cFrom += "INNER JOIN " + RetSqlName( "LE9" ) + " LE9 "
	cFrom += "   ON LE9.LE9_FILIAL = T0S.T0S_FILIAL "
	cFrom += "  AND LE9.LE9_ID = T0S.T0S_ID "
	cFrom += "  AND LE9.D_E_L_E_T_ = '' "

	cFrom += "INNER JOIN " + RetSqlName( "T0T" ) + " T0T "
	cFrom += "   ON T0T.T0T_FILIAL = LE9.LE9_FILIAL "
	cFrom += "  AND T0T.T0T_ID = LE9.LE9_ID "
	cFrom += "  AND T0T.T0T_IDCODT = LE9.LE9_IDCODT "
	cFrom += "  AND T0T.T0T_ORIGEM = '" + ORIGEM_AUTOMATICO + "' "
	cFrom += "  AND T0T.T0T_IDDETA LIKE ( '" + oModelCWV:GetValue( "CWV_ID" ) + "%' ) "
	cFrom += "  AND T0T.D_E_L_E_T_ = '' "

	cWhere := "    T0S.T0S_FILIAL = '" + xFilial( "T0S" ) + "' "
	cWhere += "AND T0S.D_E_L_E_T_ = '' "

	cSelect  := "%" + cSelect  + "%"
	cFrom    := "%" + cFrom    + "%"
	cWhere   := "%" + cWhere   + "%"

	BeginSql Alias cAliasQry

		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%

	EndSql

	If ( cAliasQry )->( !Eof() )

		While ( cAliasQry )->( !Eof() )
			T0S->( DBGoTo( ( cAliasQry )->T0S_RECNO ) )

			oModelT0S := FWLoadModel( "TAFA436" )

			oModelLE9 := oModelT0S:GetModel( "MODEL_LE9" )
			oModelT0T := oModelT0S:GetModel( "MODEL_T0T" )

			oModelT0S:SetOperation( MODEL_OPERATION_UPDATE )
			oModelT0S:Activate()

			cLoop := ( cAliasQry )->T0S_RECNO
			While ( cAliasQry )->T0S_RECNO == cLoop

				If oModelLE9:SeekLine( { { "LE9_IDCODT", ( cAliasQry )->LE9_IDCODT } } )
					If oModelT0T:SeekLine( { { "T0T_IDCODT", ( cAliasQry )->LE9_IDCODT }, { "T0T_CODLAN", ( cAliasQry )->T0T_CODLAN } } )
						If !oModelT0T:DeleteLine()
							lCommit := .F.

							If At( STR0129, cDisarm ) <= 0 //"Falha na remoção dos Lançamentos devido a consistência de dados"
								If !Empty( cDisarm )
									cDisarm += ENTER
								EndIf

								cDisarm += " • " + STR0129 + ":" //"Falha na remoção dos Lançamentos devido a consistência de dados"
								cDisarm += ENTER
								cDisarm += ENTER
							EndIf

							cDisarm += STR0099 + ": " + AllTrim( T0S->T0S_CODIGO ) + " - " + AllTrim( T0S->T0S_DESCRI ) //"Conta"
							cDisarm += ENTER
							cDisarm += STR0002 + ": " + AllTrim( Posicione( "T0J", 1, xFilial( "T0J" ) + ( cAliasQry )->LE9_IDCODT, "T0J_CODIGO" ) ) + " - " + AllTrim( Posicione( "T0J", 1, xFilial( "T0J" ) + ( cAliasQry )->LE9_IDCODT, "T0J_DESCRI" ) ) //"Tributo"
							cDisarm += ENTER
							cDisarm += STR0100 + ": " + AllTrim( ( cAliasQry )->T0T_CODLAN ) //"Lançamento"
							cDisarm += ENTER
							cDisarm += ENTER
						EndIf

						cSuccess += "- " + STR0100 + ": " + AllTrim( ( cAliasQry )->T0T_CODLAN ) + " - " //"Lançamento"
						cSuccess += STR0002 + ": " + AllTrim( Posicione( "T0J", 1, xFilial( "T0J" ) + ( cAliasQry )->LE9_IDCODT, "T0J_CODIGO" ) ) + " - " + AllTrim( Posicione( "T0J", 1, xFilial( "T0J" ) + ( cAliasQry )->LE9_IDCODT, "T0J_DESCRI" ) ) + " - " //"Tributo"
						cSuccess += STR0099 + ": " + AllTrim( T0S->T0S_CODIGO ) + " - " + AllTrim( T0S->T0S_DESCRI ) //"Conta"
						cSuccess += " " + STR0112 //"gerado automaticamente no encerramento do Período foi removido do sistema."
						cSuccess += ENTER
					Else
						If At( STR0113, cWarning ) <= 0 //"O(s) Lançamento(s) abaixo não foi(ram) encontrado(s) no sistema"
							If !Empty( cWarning )
								cWarning += ENTER
							EndIf

							cWarning += " • " + STR0113 + ":" //"O(s) Lançamento(s) abaixo não foi(ram) encontrado(s) no sistema"
							cWarning += ENTER
							cWarning += ENTER
						EndIf

						cWarning += STR0099 + ": " + AllTrim( T0S->T0S_CODIGO ) + " - " + AllTrim( T0S->T0S_DESCRI ) //"Conta"
						cWarning += ENTER
						cWarning += STR0002 + ": " + AllTrim( Posicione( "T0J", 1, xFilial( "T0J" ) + ( cAliasQry )->LE9_IDCODT, "T0J_CODIGO" ) ) + " - " + AllTrim( Posicione( "T0J", 1, xFilial( "T0J" ) + ( cAliasQry )->LE9_IDCODT, "T0J_DESCRI" ) ) //"Tributo"
						cWarning += ENTER
						cWarning += STR0100 + ": " + AllTrim( ( cAliasQry )->T0T_CODLAN ) //"Lançamento"
						cWarning += ENTER
						cWarning += ENTER
					EndIf
				EndIf

				( cAliasQry )->( DBSkip() )
			EndDo

			FWFormCommit( oModelT0S )
			oModelT0S:DeActivate()
		EndDo

	EndIf

	( cAliasQry )->( DBCloseArea() )

	//*********************************************
	//Estorna a integração com os cadastros da ECF
	//*********************************************
	RemoveBlcP( oModel, @cSuccess )
	RemoveBlcU( oModel, @cSuccess )
	RemoveBlcT( oModel, @cSuccess )
	RemoveBlcM( oModel, @cSuccess, @cWarning )
	RemoveBlcN( oModel, @cSuccess )

	//**********************************
	// Confirma as alterações efetuadas
	//**********************************
	FWFormCommit( oModel )

	If !lCommit
		DisarmTransaction()
	EndIf

End Transaction

If lCommit
	If !Empty( cSuccess )
		cMessage += Replicate( "*", 97 )
		cMessage += ENTER
		cMessage += Upper( STR0114 ) //"Procedimentos executados com sucesso"
		cMessage += ENTER
		cMessage += Replicate( "*", 97 ) 
		cMessage += ENTER
		cMessage += ENTER
		cMessage += cSuccess
	EndIf

	If !Empty( cWarning )
		If !Empty( cMessage )
			cMessage += ENTER
			cMessage += ENTER
		EndIf

		cMessage += Replicate( "*", 97 )
		cMessage += ENTER
		cMessage += Upper( STR0115 ) //"Alertas"
		cMessage += ENTER
		cMessage += Replicate( "*", 97 )
		cMessage += ENTER
		cMessage += ENTER
		cMessage += cWarning
	EndIf
Else
	If !Empty( cDisarm )
		cMessage += Replicate( "*", 97 )
		cMessage += ENTER
		cMessage += Upper( STR0130 ) //"Falhas encontradas durante a execução"
		cMessage += ENTER
		cMessage += Replicate( "*", 97 ) 
		cMessage += ENTER
		cMessage += ENTER
		cMessage += cDisarm
	EndIf
EndIf

Return( lCommit )

//-------------------------------------------------------------------
/*/{Protheus.doc} ShowLog

Exibe a mensagem de log de ocorrências.

@Param		cTitle	- Título da interface
			cBody	- Corpo da mensagem

@Author		Felipe C. Seolin
@Since		26/12/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ShowLog( cTitle, cBody )

Local oModal	as object

oModal	:=	FWDialogModal():New()

oModal:SetTitle( cTitle )
oModal:SetFreeArea( 250, 150 )
oModal:SetEscClose( .T. )
oModal:SetBackground( .T. )
oModal:CreateDialog()
oModal:AddCloseButton()

TMultiGet():New( 030, 020, { || cBody }, oModal:GetPanelMain(), 210, 100,, .T. ,,,, .T.,,,,,, .T.,,,,, .T. )

oModal:Activate()

Return()

/*/{Protheus.doc} VldPerOpen
Verifica se a Data passada perntence a um período aberto
@author david.costa
@since 31/01/2017
@version 1.0
@param dData, data, Data que será validada
@param cIdTributo, character, Id do tributo a ser verificado
@return ${lRet}, ${validação se a Data passada perntence a um período aberto}
@example
VldPerOpen( dData, cIdTributo )
/*/Function VldPerOpen( dData, cIdTributo )

Local cAliasQry	as character
Local cSelect		as character
Local cFrom		as character
Local cWhere		as character

cAliasQry	:=	GetNextAlias()
cSelect	:=	""
cFrom		:=	""
cWhere		:=	""

cSelect	:= " R_E_C_N_O_ "
cFrom		:= RetSqlName( "CWV" ) + " CWV "
cWhere		:= " CWV.D_E_L_E_T_ = '' "
cWhere		+= " AND CWV_FILIAL = '" + xFilial( "CWV" ) + "' "
cWhere		+= " AND CWV_IDTRIB = '" + cIdTributo + "' "
cWhere		+= " AND CWV_STATUS = '" + PERIODO_ENCERRADO + "' "
cWhere		+= " AND '" + DTOS( dData ) + "' BETWEEN CWV_INIPER AND CWV_FIMPER "

cSelect	:= "%" + cSelect 	+ "%"
cFrom  	:= "%" + cFrom   	+ "%"
cWhere 	:= "%" + cWhere  	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
EndSql

lRet := ( cAliasQry )->( ( Eof() ) )

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetGuias

Seleciona as Guias que serão estornadas.

@Param		cIdPeriodo	- Identificador do Período

@Return		lRet		- Indica se as guias foram selecionadas

@Author		David Costa
@Since		31/01/2017
@Version	1.0

@Altered by Felipe C. Seolin in 15/02/2017 - Alterado de MsSelect para FWMarkBrowse
/*/
//---------------------------------------------------------------------
Static Function GetGuias( cIdPeriodo )

Local cAliasQry	as character
Local cTempTab	as character
Local cCampos		as character
Local cChave		as character
Local cTitle		as character
Local cReadVar	as character
Local cCombo		as character
Local cSelect		as character
Local cFrom		as character
Local cWhere		as character
Local cOrderBy	as character
Local nPos			as numeric
Local nI			as numeric
Local aStruct		as array
Local aColumns	as array
Local aAux			as array
Local aIndex		as array
Local aSeek		as array
Local aCombo		as array
Local aID			as array
Local aStatus		as array
Local aCodRec		as array
Local aVlrPrc		as array
Local aVlrPago	as array
Local aDataVct	as array

cAliasQry	:=	GetNextAlias()
cTempTab	:=	GetNextAlias()
cCampos	:=	"C0R_STPGTO|C6R_CODIGO|C0R_VLRPRC|C0R_VLPAGO|C0R_DTVCT"
cChave		:=	"C0R_ID"
cTitle		:=	STR0104 //"Documento de Arrecadação"
cReadVar	:=	ReadVar()
cCombo		:=	""
cSelect	:=	""
cFrom		:=	""
cWhere		:=	""
cOrderBy	:=	""
nPos		:=	0
nI			:=	0
aStruct	:=	{}
aColumns	:=	{}
aAux		:=	{}
aIndex		:=	{}
aSeek		:=	{}
aCombo		:=	{}
aID			:=	TamSX3( "C0R_ID" )
aStatus	:=	TamSX3( "C0R_STPGTO" )
aCodRec	:=	TamSX3( "C6R_CODIGO" )
aVlrPrc	:=	TamSX3( "C0R_VLRPRC" )
aVlrPago	:=	TamSX3( "C0R_VLPAGO" )
aDataVct	:=	TamSX3( "C0R_DTVCT" )


//------------------------------------
// Executa consulta ao banco de dados
//------------------------------------
cSelect	:= "C0R_ID, C0R_STPGTO, C6R_CODIGO, C0R_VLRPRC, C0R_VLPAGO, C0R_DTVCT "
cFrom		:= RetSqlName( "C0R" ) + " C0R "
cFrom		+= "LEFT JOIN " + RetSqlName( "C6R" ) + " C6R "
cFrom		+= "  ON C6R.C6R_FILIAL = '" + xFilial( "C6R" ) + "' "
cFrom		+= " AND C6R.C6R_ID = C0R.C0R_CODREC "
cFrom		+= " AND C6R.D_E_L_E_T_ = '' "
cWhere		:= "    C0R.C0R_FILIAL = '" + xFilial( "C0R" ) + "' "
cWhere		+= "AND C0R.C0R_ID IN ( SELECT T50_IDGUIA "
cWhere		+= "                FROM " + RetSqlName( "T50" ) + " T50 "
cWhere		+= "                WHERE T50.T50_FILIAL = C0R.C0R_FILIAL " 
cWhere		+= "                  AND T50.T50_ID = '" + cIdPeriodo + "' "
cWhere		+= "                  AND T50.D_E_L_E_T_ = '' ) "
cWhere		+= "AND C0R.D_E_L_E_T_ = '' "
cOrderBy	:= "C0R.R_E_C_N_O_ "

cSelect	:= "%" + cSelect 	+ "%"
cFrom  	:= "%" + cFrom   	+ "%"
cWhere		:= "%" + cWhere  	+ "%"
cOrderBy	:= "%" + cOrderBy	+ "%"

BeginSql Alias cAliasQry

	column C0R_DTVCT as Date

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	ORDER BY
		%Exp:cOrderBy%

EndSql

oTempTable := FWTemporaryTable():New( cTempTab )

//----------------------------------
// Cria arquivo de dados temporário
//----------------------------------
aAdd( aStruct, { "MARK"			, "C"			, 2				, 0 			} )
aAdd( aStruct, { "C0R_ID"		, aID[3]		, aID[1]		, aID[2]		} )
aAdd( aStruct, { "C0R_STPGTO"	, aStatus[3]	, aStatus[1]	, aStatus[2]	} )
aAdd( aStruct, { "C6R_CODIGO"	, aCodRec[3]	, aCodRec[1]	, aCodRec[2]	} )
aAdd( aStruct, { "C0R_VLRPRC"	, aVlrPrc[3]	, aVlrPrc[1]	, aVlrPrc[2]	} )
aAdd( aStruct, { "C0R_VLPAGO"	, aVlrPago[3]	, aVlrPago[1]	, aVlrPago[2]	} )
aAdd( aStruct, { "C0R_DTVCT"	, aDataVct[3]	, aDataVct[1]	, aDataVct[2]	} )


oTemptable:SetFields( aStruct )


//---------------------------
// Cria estrutura de colunas
//---------------------------
For nI := 1 to Len( aStruct )
	If aStruct[nI,1] $ cCampos

		nPos ++

		aAdd( aColumns, FWBrwColumn():New() )

		aColumns[nPos]:SetData( &( "{ || " + aStruct[nI,1] + " }" ) )
		aColumns[nPos]:SetTitle( RetTitle( aStruct[nI,1] ) )
		//aColumns[nPos]:SetSize( aStruct[nI,3] )
		aColumns[nPos]:SetDecimal( aStruct[nI,4] )
		aColumns[nPos]:SetPicture( PesqPict( SubStr( aStruct[nI,1], 1, At( "_", aStruct[nI,1] ) - 1 ), aStruct[nI,1] ) )
		aColumns[nPos]:SetType( aStruct[nI,2] )
		aColumns[nPos]:SetAlign( Iif( aStruct[nI,2] == "N", 2, 1 ) )

		If aStruct[nI,2] == "C"

			DBSelectArea( "SX3" )
			SX3->( DBSetOrder( 2 ) )
			If SX3->( MsSeek( aStruct[nI,1] ) )
				cCombo := X3Cbox()
			EndIf

			If !Empty( cCombo )
				aCombo := StrToKarr( cCombo, ";" )
				aColumns[nPos]:SetOptions( aCombo )
			EndIf

		EndIf

		//----------------------------
		// Cria estrutura de pesquisa
		//----------------------------
		If !( aStruct[nI,1] $ "C0R_VLRPRC|C0R_VLPAGO" )
			aAdd( aIndex, aStruct[nI,1] )
			aAdd( aSeek, { RetTitle( aStruct[nI,1] ), { { "", aStruct[nI,2], aStruct[nI,3], aStruct[nI,4], RetTitle( aStruct[nI,1] ), PesqPict( SubStr( aStruct[nI,1], 1, At( "_", aStruct[nI,1] ) - 1 ), aStruct[nI,1] ), } } } )
		EndIf

	EndIf
Next nI

//----------------------------
// Cria estrutura de índices
//----------------------------
aAux := aClone( aIndex )
aIndex := Array( Len( aAux ) )
nPos := 0

For nI := 1 to Len( aAux )
	nPos := Len( aAux ) - ( nI - 1 )
	aIndex[nPos] := aAux[nI]
Next nI

For nI := 1 to Len( aIndex )
	oTempTable:AddIndex( "cIndex" + AllTrim( Str( nI ) ) ,{aIndex[nI]})
Next nI


//------------------
//Criação da tabela
//------------------
oTempTable:Create()

//------------------------------------
// Popula arquivo de dados temporário
//------------------------------------
( cTempTab )->( DBGoTop() )

While ( cAliasQry )->( !Eof() )

	If RecLock( ( cTempTab ), .T. )
		( cTempTab )->MARK		:=	"  "
		( cTempTab )->C0R_ID		:=	( cAliasQry )->C0R_ID
		( cTempTab )->C0R_STPGTO	:=	( cAliasQry )->C0R_STPGTO
		( cTempTab )->C6R_CODIGO	:=	( cAliasQry )->C6R_CODIGO
		( cTempTab )->C0R_VLRPRC	:=	( cAliasQry )->C0R_VLRPRC
		( cTempTab )->C0R_VLPAGO	:=	( cAliasQry )->C0R_VLPAGO
		( cTempTab )->C0R_DTVCT	:=	( cAliasQry )->C0R_DTVCT
		( cTempTab )->( MsUnLock() )
	EndIf

	( cAliasQry )->( DBSkip() )
EndDo

( cAliasQry )->( DBCloseArea() )

//---------------------------------
// Executa a montagem da interface
//---------------------------------
TAF433SXB( cTitle, cTempTab, cReadVar, cChave, aColumns, aSeek, .T. )

//--------------------------------
// Apaga arquivo(s) temporário(s)
//--------------------------------
If !Empty( cTempTab )
	oTempTable:Delete()
EndIf

Return( .T. )

/*/{Protheus.doc} TAFA444ECF
Copia os valores apurados para os cadastros da ECF
@author david.costa
@since 22/02/2017
@version 1.0
@return ${Nil}, ${Nulo}
@example
TAFA444ECF()
/*/Function TAFA444ECF()

Local cNomWiz		as character
Local lEnd			as logical

Private oProcess	as object

cNomWiz		:=	""
lEnd		:=	.F.

oProcess	:=	Nil

If CWV->CWV_STATUS == PERIODO_ENCERRADO
	If GetTpTribu( CWV->CWV_IDTRIB ) == TIPO_TRIBUTO_IRPJ .Or. GetTpTribu( CWV->CWV_IDTRIB ) == TIPO_TRIBUTO_CSLL
		cNomWiz := STR0135	//"Preenchendo os cadastros da ECF"

		if type('lAutomato') == 'L' .and. lAutomato
			ProcessECF()
		else
			//Cria objeto de controle do processamento
			oProcess := TAFProgress():New( { |lEnd| ProcessECF() }, cNomWiz )
			oProcess:Activate()
		endif	

	Else
		ShowLog( STR0015, STR0067 )//"Atenção"; "Este processo só pode ser executado para os tributos IRPJ ou CSLL"
	EndIf
Else
	ShowLog( STR0015, STR0069 ) //"Atenção"; "Este processo só pode ser executado com o período encerrado."
EndIf

//Limpando a memória
DelClassIntf()

Return()

/*/{Protheus.doc} ProcessECF
Processa o preenchimento os cadatros da ECF com os dados apurados
@author david.costa
@since 22/02/2017
@version 1.0
@return ${Nil}, ${Nulo}
@example
ProcessECF()
/*/Static Function ProcessECF()

Local oModelPeri	as object
Local cLogErros		as character
Local cLogAvisos	as character
Local aBlocoP		as array
Local aBlocoM		as array
Local aBlocoN		as array
Local aBlocoT		as array
Local aBlocoU		as array

oModelPeri	:=	Nil
cLogErros	:=	""
cLogAvisos	:=	""
aBlocoP		:=	{}
aBlocoM		:=	{}
aBlocoN		:=	{}
aBlocoT		:=	{}
aBlocoU		:=	{}

if type('lAutomato') != 'L' .or. !lAutomato
	oProcess:Set2Progress( 0 )
	oProcess:Set1Progress( 0 )
endif	

//Carrega o Model do Período
oModelPeri := FWLoadModel( 'TAFA444' )
oModelPeri:SetOperation( MODEL_OPERATION_VIEW )
oModelPeri:Activate()

//Carrega os itens dos blocos que serão preenchidos
SetBlocos( @aBlocoP, @aBlocoM, @aBlocoN, @aBlocoT, @aBlocoU, @cLogErros, @cLogAvisos, oModelPeri )

//Preenche os cadastros da ECF
SetCadECF( @aBlocoP, @aBlocoM, @aBlocoN, @aBlocoT, @aBlocoU, @cLogErros, @cLogAvisos, oModelPeri )

if type('lAutomato') != 'L' .or. !lAutomato
	//Em caso de Erros
	If !Empty( cLogErros )
		//Apresentando Log do processo
		oProcess:Set1Progress( 1 )
		oProcess:Set2Progress( 1 )
		oProcess:Inc1Progress( STR0136 )//"Erro no preenchimento dos cadastros da ECF"
		oProcess:Inc2Progress( STR0034 ) //"Clique em finalizar"
		oProcess:nCancel := 1
		
		ShowLog( STR0015, cLogErros )//"Atenção"

	Else
		//Apresentando Log do processo
		oProcess:Set1Progress( 1 )
		oProcess:Set2Progress( 1 )
		oProcess:Inc1Progress( STR0137 )//"Processo executado com sucesso"
		oProcess:Inc2Progress( STR0034 ) //"Clique em finalizar"
		If !Empty( cLogAvisos )
			ShowLog( STR0015, cLogAvisos )//"Atenção"
		EndIf
	EndIf
endif

Return()

/*/{Protheus.doc} SetBlocos
Preenche os blocos que serão gravados na ECF
@author david.costa
@since 22/02/2017
@version 1.0
@param aBlocoP, array, Array do Bloco P
@param aBlocoM, array, Array do Bloco M
@param aBlocoN, array, Array do Bloco N
@param aBlocoT, array, Array do Bloco T
@param aBlocoU, array, Array do Bloco U
@param cLogErros, character, Log de Erros do processo
@param cLogAvisos, character, Log de Avisos do processo
@param oModelPeri, objeto, Model do Período
@return ${Nil}, ${Nulo}
@example
SetBlocos( @aBlocoP, @aBlocoM, @aBlocoN, @aBlocoT, @aBlocoU, @cLogErros, @cLogAvisos, oModelPeri )
/*/Static Function SetBlocos( aBlocoP, aBlocoM, aBlocoN, aBlocoT, aBlocoU, cLogErros, cLogAvisos, oModelPeri )

Local oModelCWX	as object
Local oModelEven	as object
Local cCodBloco	as character
Local cFormaTrib	as character
Local nIndiceCWX	as numeric

oModelCWX	:=	oModelPeri:GetModel( "MODEL_CWX" )
cCodBloco	:=	""
cFormaTrib	:=	xFunID2Cd( Posicione( "T0N", 1, xFilial( "T0N" ) + oModelPeri:GetValue( "MODEL_CWV", "CWV_IDEVEN" ), "T0N->T0N_IDFTRI" ), "T0K", 1 )
nIndiceCWX	:=	0

LoadEvento( @oModelEven, oModelPeri:GetValue( "MODEL_CWV", "CWV_IDEVEN" ) )

For nIndiceCWX := 1 to oModelCWX:Length()
	oModelCWX:GoLine( nIndiceCWX )

	If !oModelCWX:IsDeleted() .and. !oModelCWX:IsEmpty()
		cCodBloco := Iif( Empty( oModelCWX:GetValue( "CWX_CODLAL" ) ), oModelCWX:GetValue( "CWX_CODECF" ), oModelCWX:GetValue( "CWX_CODLAL" ) )

		Do Case
			Case "P" $ cCodBloco
				AddItemBlo( @aBlocoP, oModelCWX, cCodBloco, cFormaTrib,, @cLogErros )
			Case "M" $ cCodBloco
				AddItemBlo( @aBlocoM, oModelCWX, cCodBloco, cFormaTrib, oModelPeri, @cLogErros, oModelEven )
			Case "N" $ cCodBloco
				AddItemBlo( @aBlocoN, oModelCWX, cCodBloco, cFormaTrib,, @cLogErros )
			Case "T" $ cCodBloco
				AddItemBlo( @aBlocoT, oModelCWX, cCodBloco, cFormaTrib,, @cLogErros )
			Case "U" $ cCodBloco
				AddItemBlo( @aBlocoU, oModelCWX, cCodBloco, cFormaTrib,, @cLogErros )
		EndCase

	EndIf
Next nIndiceCWX

AgrupaBlcM( @aBlocoM, @cLogErros, @cLogAvisos, oModelPeri )

Return()

/*/{Protheus.doc} AddItemBlo
Preenche os itens dos blocos que serão enviados para a ECF
@author david.costa
@since 22/02/2017
@version 1.0
@param aBloco, array, Array que receberá os itens do bloco
@param oModelCWX, objeto, Model do detalhamento do Período
@param cCodBloco, character, Código do Registro
@param cFomaTrib, character, Forma de Tributação do Evento
@param oModelCWV, objeto, Model do Período
@param cLogErros, character, Log de Erros do processo
@param oModelEven, objeto, Model do Evento
@return ${Nil}, ${Nulo}
@example
AddItemBlo( aBloco, oModelCWX, cCodBloco, cFomaTrib, oModelPeri, cLogErros, oModelEven )
/*/Static Function AddItemBlo( aBloco, oModelCWX, cCodBloco, cFomaTrib, oModelPeri, cLogErros, oModelEven )

Local cIdBloco	 as character
Local cCodFolder as character
Local cSeqIteEve as character
Local cHistorico as character
Local nPosBloco	 as numeric
Local nIdGrupo	 as numeric
Local aContaCtb	 as array
Local aContaPaB	 as array
Local aProcessos as array
Local aSpecAdic  as array
Local aSpecExcl  as array
Local lLanManual as logical

cIdBloco 	:=	Iif( Empty( oModelCWX:GetValue( "CWX_IDECF" ) ), oModelCWX:GetValue( "CWX_IDLAL" ), oModelCWX:GetValue( "CWX_IDECF" ) )
cCodFolder	:=	GetCodFolder( oModelCWX, cCodBloco, cFomaTrib )
cSeqIteEve	:=	""
cHistorico	:=	""
nPosBloco	:=	aScan( aBloco, { |x| x[M300_ID_TABELA_DINAMICA] == cIdBloco } )
nIdGrupo	:=	0
aContaCtb	:=	{}
aContaPaB	:=	{}
aProcessos	:=	{}
lLanManual	:=	.F.

//Defino quais codigos do lalur que tenham lançamentos apenas conta contábil configurado no evento tributário
//devem ser enviados para a ECF com relacionamento = 3 - Com Conta Contábil e Conta da Parte B.
aSpecAdic   :=  {'M300A16','M300A6','M350A6'}
aSpecExcl   :=  {'M300A101','M300A95','M350A95'}

//O bloco M será agrupado em outro momento
If nPosBloco > 0 .and. !( "M" $ cCodBloco )
	aBloco[ nPosBloco ][ 2 ] += oModelCWX:GetValue( "CWX_VALOR" )
Else
	If "M" $ cCodBloco
		aContaCtb := GetM310( oModelCWX, oModelPeri, @cLogErros )
		aContaPaB := GetContPB( oModelCWX )
		aProcessos := GetaProces( oModelPeri:GetValue( "MODEL_CWV", "CWV_IDEVEN" ), Str( Val( oModelCWX:GetValue( "CWX_CODGRU" ) ), 2 ), oModelCWX:GetValue( "CWX_SEQITE" ) )
		cHistorico := GetHistorico( oModelCWX, oModelEven )
		lLanManual := oModelCWX:GetValue( "CWX_ORIGEM" ) == ORIGEM_LANCAMENTO_MANUAL
	EndIf
	
	nIdGrupo := Val( oModelCWX:GetValue( "CWX_CODGRU" ) )
	cSeqIteEve := oModelCWX:GetValue( "CWX_SEQITE" )
	
	aAdd( aBloco, { cIdBloco, oModelCWX:GetValue( "CWX_VALOR" ), cCodFolder, aContaCtb, aContaPaB, aProcessos, cSeqIteEve, nIdGrupo, cHistorico, lLanManual } )
	
	//Após gerar o M010 da conta, montar um novo M305 para os códigos especificos do lalur (16 ou 101)
	If nIdGrupo == GRUPO_ADICOES_LUCRO .AND. aScan(aSpecAdic, {|x| x== Alltrim(cCodBloco)}) .AND. oModelCWX:GetValue( "CWX_ORIGEM" ) == ORIGEM_CONTA_CONTABIL .and. len(aContaPaB) == 0
		aContaCtb := {}
		aContaPaB := GetContPB( oModelCWX,,,.t. )
		
		aAdd( aBloco, { cIdBloco, oModelCWX:GetValue( "CWX_VALOR" ), cCodFolder, aContaCtb, aContaPaB, aProcessos, cSeqIteEve, nIdGrupo, cHistorico, lLanManual } )
	
	Elseif nIdGrupo == GRUPO_EXCLUSOES_LUCRO .AND. aScan(aSpecExcl, {|x| x== Alltrim(cCodBloco)}) .AND. oModelCWX:GetValue( "CWX_ORIGEM" ) == ORIGEM_CONTA_CONTABIL .and. len(aContaPaB) == 0
		aContaCtb := {}
		aContaPaB := GetContPB( oModelCWX,,,.t. )
		
		aAdd( aBloco, { cIdBloco, oModelCWX:GetValue( "CWX_VALOR" ), cCodFolder, aContaCtb, aContaPaB, aProcessos, cSeqIteEve, nIdGrupo, cHistorico, lLanManual } )

	Endif

EndIf

Return()

/*/{Protheus.doc} GetM310
Retorna o M310
@author david.costa
@since 22/02/2017
@version 1.0
@param oModelCWX, objeto, O Model do detalhamento do periodo
@param oModelPeri, objeto, Model do Período
@param cLogErros, character, Log de Erros do processo
@return ${Nil}, ${Nulo}
@example
GetM310( oModelCWX, oModelPeri, cLogErros )
/*/Static Function GetM310( oModelCWX, oModelPeri, cLogErros )

Local cIdContCtb		as character
Local cIndNatCtb		as character
Local cIdCCusto		as character
Local cHistorico		as character
Local cFilItem		as character
Local cTipoApura		as character
Local nValor			as numeric
Local aM310			as array
Local aM312			as array
Local cIdEvento		as character

cIdContCtb	:=	""
cIndNatCtb	:=	""
cIdCCusto	:=	""
cHistorico	:= ""
cFilItem	:= ""
cTipoApura	:= ""
nValor		:=	0
aM310		:= {}
aM312		:= {}

//Se foi calculo de evento rural.
if oModelCWX:GetValue('CWX_RURAL') == '1'
	cIdEvento := GetAdvFVal('T0N','T0N_IDEVEN', xFilial( 'T0N' ) + oModelPeri:GetValue( "MODEL_CWV", "CWV_IDEVEN" ) , 1 )
else
	cIdEvento := oModelPeri:GetValue( "MODEL_CWV", "CWV_IDEVEN" )
endif	

If oModelCWX:GetValue( "CWX_ORIGEM" ) == ORIGEM_CONTA_CONTABIL
	DbSelectArea( "T0O" )
	T0O->( DbSetOrder(1) )
	If T0O->( MsSeek( xFilial( "T0O" ) + cIdEvento + Str( Val( oModelCWX:GetValue( "CWX_CODGRU" ) ), 2 ) + oModelCWX:GetValue( "CWX_SEQITE" ) ) )
		cIdContCtb := T0O->T0O_IDCC
		cIdCCusto := T0O->T0O_IDCUST
		cFilItem := xFunCh2ID( T0O->T0O_FILITE, "C1E", 1 )
		cIndNatCtb := Posicione( "C1O", 3, cFilItem + T0O->T0O_IDCC, "C1O->C1O_NATURE" )
		cHistorico := T0O->T0O_DESCRI
		nValor := oModelCWX:GetValue( "CWX_VALOR" )
		cTipoApura := T0O->T0O_TIPOCC
		aAdd( aM310, { cIdContCtb, cIdCCusto, nValor, cIndNatCtb, cTipoApura, aM312 } )
	EndIf
EndIf

Return( aM310 )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetContPB

Indica as Contas da Parte B utilizadas na Apuração.

@Param		oModelCWX	-	Modelo do Detalhamento do Período de Apuração
			aContaPB	-	Array com as Contas da Parte B do Bloco M ( referência )

@Return		aContaPB	-	Array com as Contas da Parte B do Bloco M

@Author		Felipe C. Seolin
@Since		31/03/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function GetContPB( oModelCWX, aContaPB, lPrejExe,lGeraM305 )

Local oModelCWV		as object
Local cAliasQry		as character
Local cSelect		as character
Local cFrom			as character
Local cWhere		as character
Local cOrderBy		as character
Local nIDGrupo		as numeric
Local lParteB		as logical
Local cIdEven		as character
Local lLE9_ISLDAT   as logical
Local cIniPer		as character

Default aContaPB	:=	{}
Default lPrejExe	:= .f.
Default lGeraM305	:= .f.

oModelCWV	:=	oModelCWX:GetOwner()
cAliasQry	:=	GetNextAlias()
cSelect		:=	""
cFrom		:=	""
cWhere		:=	""
cOrderBy	:=	" T0S.T0S_CODIGO "
nIDGrupo	:=	Val( Posicione( "LEE", 1, xFilial( "LEE" ) + oModelCWX:GetValue( "CWX_IDCODG" ), "LEE_CODIGO" ) )
cIdEven		:= iif( oModelCWX:GetValue('CWX_RURAL') != '1', 'T0N.T0N_ID', 'T0N.T0N_IDEVEN')
lParteB		:= .t.
lLE9_ISLDAT	:= TafColumnPos('LE9_ISLDAT')
cIniPer 	:= ''

cSelect := "DISTINCT T0S.T0S_ID, LE9.LE9_IDCODT, T0S.T0S_CODIGO, T0S.T0S_DESCRI, CH8.CH8_CODREG, LE9.LE9_IDCODL, T0S.T0S_DTFINA, C3S.C3S_CODIGO, T0S.T0S_DTLIMI, LE9.LE9_VLSDIN, T0S.T0S_NATURE, T0S.T0S_CNPJRE, T0S_IDCODP  "
if lLE9_ISLDAT
	cSelect += " , LE9_ISLDAT "
Endif


if !lPrejExe
	If oModelCWX:GetValue( "CWX_ORIGEM" ) == ORIGEM_LALUR_PARTE_B .or. lGeraM305
		
		if lGeraM305 .and. TafSeekPer( dtos( oModelCWV:GetValue( "CWV_INIPER" ) ) , dtos( oModelCWV:GetValue( "CWV_FIMPER" ) ) )
			//A função TafSeekPer posiciona no registro da tabela CHD caso encontre um periodo válido.
			cIniPer := dtos(CHD->CHD_PERINI)
		else
			cIniPer := dtos( oModelCWV:GetValue( "CWV_INIPER" ) ) 
		endif	

		cFrom := RetSqlName( "T0N" ) + " T0N "
		
		cFrom += "INNER JOIN " + RetSqlName( "T0O" ) + " T0O "
		cFrom += "   ON T0O.T0O_FILIAL = T0N.T0N_FILIAL "
		cFrom += "  AND T0O.T0O_ID = " + cIdEven
		cFrom += "  AND T0O.T0O_SEQITE = '" + oModelCWX:GetValue( "CWX_SEQITE" ) + "' "
		cFrom += "  AND T0O.T0O_IDGRUP = " + Str( nIDGrupo ) + " "
		cFrom += "  AND T0O.D_E_L_E_T_ = '' "
	
		cFrom += "INNER JOIN " + RetSqlName( "C1E" ) + " C1E "
		cFrom += "   ON C1E.C1E_CODFIL = T0O.T0O_FILITE "
		cFrom += "  AND C1E.C1E_ATIVO != '2' AND C1E.D_E_L_E_T_ = '' "

		cFrom += "INNER JOIN " + RetSqlName( "T0S" ) + " T0S "
		cFrom += "   ON T0S.T0S_FILIAL = C1E.C1E_FILTAF "
		cFrom += "  AND T0S.T0S_ID = T0O.T0O_IDPARB "
		cFrom += "  AND T0S.D_E_L_E_T_ = '' "

		cFrom += "INNER JOIN " + RetSqlName( "LE9" ) + " LE9 "
		cFrom += "   ON LE9.LE9_FILIAL = T0S.T0S_FILIAL "
		cFrom += "  AND LE9.LE9_ID = T0S.T0S_ID "
		cFrom += "  AND LE9.LE9_IDCODT = T0N.T0N_IDTRIB "
		cFrom += "  AND LE9.D_E_L_E_T_ = '' "

		cFrom += "INNER JOIN " + RetSqlName( "T0T" ) + " T0T "
		cFrom += "   ON T0T.T0T_FILIAL = LE9.LE9_FILIAL "
		cFrom += "  AND T0T.T0T_ID = LE9.LE9_ID "
		cFrom += "  AND T0T.T0T_IDCODT = LE9.LE9_IDCODT "
		cFrom += "  AND T0T.T0T_DTLANC BETWEEN '" + cIniPer + "' AND '" + DToS( oModelCWV:GetValue( "CWV_FIMPER" ) ) + "' "
		cFrom += "  AND T0T.D_E_L_E_T_ = '' "

		cFrom += "LEFT JOIN " + RetSqlName( "CH8" ) + " CH8 "
		cFrom += "  ON CH8.CH8_FILIAL = '" + xFilial( "CH8" ) + "' "
		cFrom += " AND CH8.CH8_ID = LE9.LE9_IDCODL "
		cFrom += " AND CH8.D_E_L_E_T_ = '' "

		cFrom += "LEFT JOIN " + RetSqlName( "T0J" ) + " T0J "
		cFrom += "  ON T0J.T0J_FILIAL = '" + xFilial( "T0J" ) + "' "
		cFrom += " AND T0J.T0J_ID = LE9.LE9_IDCODT "
		cFrom += " AND T0J.D_E_L_E_T_ = '' "

		cFrom += "LEFT JOIN " + RetSqlName( "C3S" ) + " C3S "
		cFrom += "  ON C3S.C3S_FILIAL = '" + xFilial( "C3S" ) + "' "
		cFrom += " AND C3S.C3S_ID = T0J.T0J_TPTRIB "
		cFrom += " AND C3S.D_E_L_E_T_ = '' "

		cWhere := "    T0N.T0N_FILIAL = '" + xFilial( "T0N" ) + "' "
		cWhere += "AND T0N.T0N_ID = '" + oModelCWV:GetValue( "CWV_IDEVEN" ) + "' "
		cWhere += "AND T0N.D_E_L_E_T_ = '' "

	else
		lParteb := .f.		
	EndIf

else
	cFrom := RetSqlName('T0T') + " T0T "
	cFrom += " INNER JOIN " + RetSqlName('LE9') + " LE9 ON LE9.LE9_FILIAL = '" + xFilial('LE9') + "' AND LE9.LE9_ID = T0T.T0T_ID AND LE9.LE9_IDCODT = T0T.T0T_IDCODT AND LE9.D_E_L_E_T_ = ' ' "
	cFrom += " INNER JOIN " + RetSqlName('T0S') + " T0S ON T0S.T0S_FILIAL = '" + xFilial('T0S') + "' AND T0S.T0S_ID = LE9.LE9_ID AND T0S.D_E_L_E_T_ = ' ' "
	cFrom += " LEFT JOIN  " + RetSqlName('T0J') + " T0J ON T0J.T0J_FILIAL = '" + xFilial('T0J') + "' AND T0J.T0J_ID = LE9.LE9_IDCODT AND T0J.D_E_L_E_T_ = ' ' "
	cFrom += " LEFT JOIN  " + RetSqlName('C3S') + " C3S ON C3S.C3S_FILIAL = '" + xFilial('C3S') + "' AND C3S.C3S_ID = T0J.T0J_TPTRIB AND C3S.D_E_L_E_T_ = ' ' "
	cFrom += " LEFT JOIN  " + RetSqlName('CH8') + " CH8 ON CH8.CH8_FILIAL = '" + xFilial('CH8') + "' AND CH8.CH8_ID = LE9.LE9_IDCODL AND CH8.D_E_L_E_T_ = ' ' "
	
	cWhere := "	    T0T.D_E_L_E_T_ = ' ' "
	cWhere += " AND T0T.T0T_FILIAL = '" + xFilial('T0T') + "' "
	cWhere += "	AND T0T.T0T_TPLANC = '3' "
	cWhere += " AND T0T.T0T_DTLANC BETWEEN '" + DToS( oModelCWV:GetValue( "CWV_INIPER" ) ) + "' AND '" + DToS( oModelCWV:GetValue( "CWV_FIMPER" ) ) + "' "
	cWhere += "	AND T0T.T0T_IDCODT = '" + oModelCWV:GetValue('CWV_IDTRIB') + "' "
endif		

if lParteB
	cSelect		:= "%" + cSelect + "%"
	cFrom		:= "%" + cFrom + "%"
	cWhere		:= "%" + cWhere + "%"
	cOrderBy	:= "%" + cOrderBy + "%"

	BeginSql Alias cAliasQry
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
		ORDER BY
			%Exp:cOrderBy%
	EndSql

	if (cAliasQry)->(!eof())
		aAdd( aContaPB, Array( 16 ) )
		aContaPB[Len( aContaPB )][M010_ID]					:=	AllTrim( ( cAliasQry )->T0S_ID )
		aContaPB[Len( aContaPB )][M010_ID_TRIBUTO]			:=	AllTrim( ( cAliasQry )->LE9_IDCODT )
		aContaPB[Len( aContaPB )][M010_CODIGO]				:=	AllTrim( ( cAliasQry )->T0S_CODIGO )
		aContaPB[Len( aContaPB )][M010_DESCRICAO]			:=	AllTrim( ( cAliasQry )->T0S_DESCRI )
		aContaPB[Len( aContaPB )][M010_TABELA_DINAMICA]		:=	AllTrim( ( cAliasQry )->CH8_CODREG )
		aContaPB[Len( aContaPB )][M010_ID_TABELA_DINAMICA]	:=	AllTrim( ( cAliasQry )->LE9_IDCODL )
		aContaPB[Len( aContaPB )][M010_DATA_CRIACAO]		:=	( cAliasQry )->T0S_DTFINA
		aContaPB[Len( aContaPB )][M010_CODIGO_TRIBUTO]		:=	AllTrim( ( cAliasQry )->C3S_CODIGO )
		aContaPB[Len( aContaPB )][M010_DATA_LIMITE]			:=	( cAliasQry )->T0S_DTLIMI
		aContaPB[Len( aContaPB )][M010_SALDO_INICIAL]		:=	( cAliasQry )->LE9_VLSDIN
		aContaPB[Len( aContaPB )][M010_INDICADOR_SALDO]		:=	AllTrim( ( cAliasQry )->T0S_NATURE )
		aContaPB[Len( aContaPB )][M010_CNPJ]				:=	AllTrim( ( cAliasQry )->T0S_CNPJRE )
		aContaPB[Len( aContaPB )][M010_ID_CONTA_REF_PB]		:=	AllTrim( ( cAliasQry )->T0S_IDCODP )
		//A posição M010_VLR_CONTA_PB_POR_COD_LALUR(14) do array é usada para armazenar o valor da conta da parte B por codigo lalur no agrupamento do bloco M.
		aContaPB[Len( aContaPB )][M010_GERA_M305]			:=	lGeraM305
		aContaPB[Len( aContaPB )][M010_IND_SALDO_ATU]		:=	IIF(!lLE9_ISLDAT,"",AllTrim( ( cAliasQry )->LE9_ISLDAT ))
		
		
	endif	

	( cAliasQry )->( DBCloseArea() )
endif


Return( aContaPB )

/*/{Protheus.doc} lGerarM312
Verifica a necessidade de gerar o bloco M312/M362
@author david.costa
@since 30/05/2017
@version 1.0
@param nVlrApurado, numeric, Valor apurado
@param cTipoCC, caracter, Tipo de apuração utilizado para item
@return ${lRet}, ${lRet}
@example
lGerarM312( nVlrApurado, cTipoCC )
/*/Static Function lGerarM312( nVlrApurado, cTipoCC )

Local lRet	as logical

lRet	:= .F.

//é considerado o valor absoluto na movimentação para não haver preocupação com a natureza da conta
lRet := lRet .or. ( cTipoCC == TIPO_MOVIMENTACAO_CONTA .and. Abs( CAD->CAD_VLRSLF - CAD->CAD_VLRSLI ) != Abs( nVlrApurado ) )
lRet := lRet .or. ( cTipoCC == TIPO_DEBITO .and. CAD->CAD_VLRDEB != nVlrApurado )
lRet := lRet .or. ( cTipoCC == TIPO_CREDITO .and. CAD->CAD_VLRCRD != nVlrApurado )
lRet := lRet .or. ( cTipoCC == TIPO_SALDO_ANTERIOR .and. CAD->CAD_VLRSLI != nVlrApurado )
lRet := lRet .or. ( cTipoCC == TIPO_SALDO_ATUAL .and. CAD->CAD_VLRSLF != nVlrApurado )

Return( lRet )

/*/{Protheus.doc} GerarM312
Busca os dados para gerar o bloco M312/M362
@author david.costa
@since 30/05/2017
@version 1.0
@param aM312, array, Array que receberá os dados apurados
@param oModelPeri, objeto, Model do Período de Apuração
@param cSeqIte, caracter, Sequencial do item no Evento Tributário
@param nIdGrupo, numeric, Identificador do Grupo do item no Evento Tributário
@return ${lRet}, ${lRet}
@example
lGerarM312( nVlrApurado, cTipoCC )
/*/Static Function GerarM312( aM312, oModelPeri, cSeqIte, nIdGrupo )

Local cAliasQry		as character
Local oModelEven	as object
Local oModelGrup	as object
Local aParametro	as array
Local aGrupos		as array
Local aGrupo		as array

cAliasQry	:=	""
oModelEven	:=	Nil
oModelGrup	:=	Nil
aParametro	:=	{}
aGrupos		:=	{}
aGrupo		:=	{}

If LoadEvento( @oModelEven, oModelPeri:GetValue( "MODEL_CWV", "CWV_IDEVEN" ) )

	LoadParam( @aParametro, oModelPeri, oModelEven )
	aGrupos := GrupoEvnto( , .T. )
	aGrupo := aGrupos[ aScan( aGrupos, { |x| x[ PARAM_GRUPO_ID ] == nIdGrupo } ) ]
	oModelGrup := oModelEven:GetModel( "MODEL_T0O_" + aGrupo[ PARAM_GRUPO_NOME ] )
	
	oModelGrup:SeekLine( { { "T0O_IDGRUP", nIdGrupo }, { "T0O_SEQITE", cSeqIte } } )
	
	cAliasQry := GetDadosCta( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ), oModelGrup, oModelEven, aGrupo, aParametro, .T. )
	
	While ( cAliasQry )->( .not. Eof() )
		If Len( aM312 ) == 0
			aAdd( aM312, { ( cAliasQry )->CFS_ID } )
		Else
			If aScan( aM312, { |x| x[ M312_ID_LANCAMENTO ] != ( cAliasQry )->CFS_ID } ) > 0
				aAdd( aM312, { ( cAliasQry )->CFS_ID } )
			EndIf
		EndIf
		( cAliasQry )->( DbSkip() )
	EndDo

EndIf

Return( Nil )

/*/{Protheus.doc} SetCadECF
Preenche os cadastros dos blocos
@author david.costa
@since 22/02/2017
@version 1.0
@param aBlocoP, array, Array com os itens do Bloco P
@param aBlocoM, array, Array com os itens do Bloco M
@param aBlocoN, array, Array com os itens do Bloco N
@param aBlocoT, array, Array com os itens do Bloco T
@param aBlocoU, array, Array com os itens do Bloco U
@param cLogErros, character, Log de Erros do processo
@param cLogAvisos, character, Log de Avisos do processo
@param oModelPeri, objeto, Model do Período de Apuração
@return ${Nil}, ${Nulo}
@example
SetCadECF( @aBlocoP, @aBlocoM, @aBlocoN, @aBlocoT, @aBlocoU, @cLogErros, @cLogAvisos, oModelPeri )
/*/Static Function SetCadECF( aBlocoP, aBlocoM, aBlocoN, aBlocoT, aBlocoU, cLogErros, cLogAvisos, oModelPeri )

Begin Transaction

	If Len( aBlocoP ) > 0
		AddBlocoP( aBlocoP, @cLogErros, @cLogAvisos, oModelPeri )
	EndIf
	
	If Len( aBlocoU ) > 0
		AddBlocoU( aBlocoU, @cLogErros, @cLogAvisos, oModelPeri )
	EndIf
	
	If Len( aBlocoT ) > 0
		AddBlocoT( aBlocoT, @cLogErros, @cLogAvisos, oModelPeri )
	EndIf
	
	If Len( aBlocoN ) > 0
		AddBlocoN( aBlocoN, @cLogErros, @cLogAvisos, oModelPeri )
	EndIf
	
	If Len( aBlocoM ) > 0
		AddBlocoM( aBlocoM, @cLogErros, @cLogAvisos, oModelPeri )
	EndIf

	If !Empty( cLogErros )
		DisarmTransaction()
	EndIf

End Transaction

Return()

/*/{Protheus.doc} AddBlocoP
Adiciona o Registro no Cadastro do Bloco P
@author david.costa
@since 22/02/2017
@version 1.0
@param aBlocoP, array, Array com os itens que serão adicionados
@param cLogErros, character, Log de Erros do processo
@param cLogAvisos, character, Log de Avisos do processo
@param oModelPeri, objeto, Model do Período de Apuração
@return ${Nil}, ${Nulo}
@example
AddBlocoP( aBlocoP, cLogErros, cLogAvisos, oModelPeri )
/*/Static Function AddBlocoP( aBlocoP, cLogErros, cLogAvisos, oModelPeri )

Local oModelBlcP	as object
Local oModelCEI		as object
Local cDescItem		as character
Local nIndiceCEI	as numeric
Local nIndicBlcP	as numeric

oModelBlcP	:=	Nil
oModelCEI	:=	Nil
cDescItem	:=	""
nIndiceCEI	:=	0
nIndicBlcP	:=	0

//Carrega o cadastro do Bloco P  
LoadBlocoP( @oModelBlcP, oModelPeri )

If GetTpTribu( CWV->CWV_IDTRIB ) == TIPO_TRIBUTO_IRPJ
	//Valida o Model "Apuração da Base de Cálculo do Lucro Presumido"
	oModelCEI := oModelBlcP:GetModel( "MODEL_CEIb" )
	VlModelCEI( oModelCEI, @cLogErros, oModelPeri )

	//Valida o Model "Cálculo do IRPJ com Base no Lucro Presumido"
	oModelCEI := oModelBlcP:GetModel( "MODEL_CEId" )
	VlModelCEI( oModelCEI, @cLogErros, oModelPeri )
Else
	//Valida o Model "Apuração da Base de Cálculo da CSLL com Base no Lucro Presumido"
	oModelCEI := oModelBlcP:GetModel( "MODEL_CEIe" )
	VlModelCEI( oModelCEI, @cLogErros, oModelPeri )
	
	//Valida o Model "Cálculo da CSLL com Base no Lucro Presumido."
	oModelCEI := oModelBlcP:GetModel( "MODEL_CEIf" )
	VlModelCEI( oModelCEI, @cLogErros, oModelPeri )
EndIf

//Adiciona os itens ao Cadastro
If Empty( cLogErros )
	For nIndicBlcP := 1 to Len( aBlocoP )
		
		oModelCEI:AddLine()
		oModelCEI:LoadValue( "CEI_IDCODC", aBlocoP[ nIndicBlcP, 1 ] )
		oModelCEI:LoadValue( "CEI_VALOR", aBlocoP[ nIndicBlcP, 2 ] )
		oModelCEI:LoadValue( "CEI_REGECF", aBlocoP[ nIndicBlcP, 3 ] )
		oModelCEI:LoadValue( "CEI_ORIGEM", "A" ) // A- AUTOMÁTICO
		oModelCEI:lValid := .T.
		
		//Grava no log o resgistro inserido
		cDescItem := Posicione( "CH6", 1, xFilial("CH6") + aBlocoP[ nIndicBlcP, 1 ], "AllTrim( CH6_CODIGO ) + ' ' + AllTrim( CH6_DESCRI )" )
		AddLogErro( STR0147, @cLogAvisos, { Round( aBlocoP[ nIndicBlcP, 2 ], 2 ), cDescItem } ) //'Foi adicionado um item com o valor @1 codigo @2 no cadastro do bloco P'
	Next nIndicBlcP
	
	//Salva o cadastro
	FWFormCommit( oModelBlcP )
EndIf

Return()

/*/{Protheus.doc} IdPerTri
Retorna o Identificador do período para o cadastro do bloco
@author david.costa
@since 22/02/2017
@version 1.0
@param dFinal, data, Data Final do Período
@param dInicial, data, Data Inicial do Período
@param lAnual, lógico, Informa se o Período é Anual
@return ${cIdPera}, ${Identificador do período}
@example
IdPerTri( dFinal )
/*/Static Function IdPerTri( dFinal, dInicial, lAnual )

Local cIdPera	as character

Default lAnual	:=	.F.

cIdPera	:=	""

If lAnual
	//Anual
	cIdPera := "4aae06a9-6893-fe70-8da2-8b96f2d982cd"
ElseIf Month( dFinal ) == Month( dInicial )
	//Mensais
	If Month( dFinal ) == 1
		//Janeiro
		cIdPera := "03ba5f6e-952d-cc58-1ebd-223c696151d8"
	ElseIf Month( dFinal ) == 2
		//Fevereiro
		cIdPera := "79e6b003-8119-e57b-7c1d-4d2682bc8fe3"
	ElseIf Month( dFinal ) == 3
		//Março
		cIdPera := "bdf113e5-d934-d2af-cfc7-582189d55ac3"
	ElseIf Month( dFinal ) == 4
		//Abril
		cIdPera := "b2abfe87-0e6b-fe37-928d-df3b3457391a"
	ElseIf Month( dFinal ) == 5
		//Maio
		cIdPera := "015f3a79-de41-a067-e37e-f2f17a04e5bd"
	ElseIf Month( dFinal ) == 6
		//Junho
		cIdPera := "75a46c8f-b97d-b863-984d-24655150f372"
	ElseIf Month( dFinal ) == 7
		//Julho
		cIdPera := "1ce4dfba-3b47-b081-2e27-130aacf75b56"
	ElseIf Month( dFinal ) == 8
		//Agosto
		cIdPera := "2e5030c8-f35f-2c2d-c9ff-16b93f33de77"
	ElseIf Month( dFinal ) == 9
		//Setembro
		cIdPera := "513fe77b-2dcd-520f-2a86-b977e6e37509"
	ElseIf Month( dFinal ) == 10
		//Outubro
		cIdPera := "9972811b-554c-603e-7f36-7b798effb2b1"
	ElseIf Month( dFinal ) == 11
		//Novembro
		cIdPera := "2055f779-8d61-6e71-1b02-df8542226254"
	ElseIf Month( dFinal ) == 12
		//Dezembro
		cIdPera := "a712cb44-03d3-0648-4a50-a07f0870feb3"
	EndIf
ElseIf Month( dFinal ) >= 1 .and. Month( dFinal ) <= 3
	//1º Trimestre
	cIdPera := "d0473a54-5476-1ab8-da1a-ccbc92cced12"
ElseIf Month( dFinal ) >= 4 .and. Month( dFinal ) <= 6
	//2º Trimestre
	cIdPera := "593d5941-e463-e348-9f9b-adaf8f3d2ab9"
ElseIf Month( dFinal ) >= 7 .and. Month( dFinal ) <= 9
	//3º Trimestre
	cIdPera := "acaec8a5-1992-b146-24e7-4b74087c5627"
ElseIf Month( dFinal ) >= 10 .and. Month( dFinal ) <= 12
	//4º Trimestre
	cIdPera := "f9b12922-6ac8-1769-b4f0-3b610a37918a"
EndIf

Return( cIdPera )

/*/{Protheus.doc} VlModelCEI
Valida se o Cadastro do BlocoP está em branco e pode receber os dados da apuração
@author david.costa
@since 22/02/2017
@version 1.0
@param oModelCEI, objeto, Model CEI que será validado
@param cLogErros, character, Log de Erros do processo
@param oModelPeri, objeto, Model do período
@return ${Nil}, ${Nulo}
@example
VlModelCEI( oModelCEI, cLogErros, aBlocoP, oModelPeri )
/*/Static Function VlModelCEI( oModelCEI, cLogErros, oModelPeri )

Local nIndiceCEI	as numeric

nIndiceCEI	:=	0

//Valida se o Cadastro está em branco
For nIndiceCEI := 1 to oModelCEI:Length()
	oModelCEI:GoLine( nIndiceCEI )
	If !oModelCEI:IsEmpty() .and. !oModelCEI:IsDeleted() .and. oModelCEI:GetValue( "CEI_REGECF" ) $ "02|04|05|06|"
		//'Existem Lançamentos criados no cadastro do Bloco P para o período de @1 até @2. Para executar este processo é necessário que não existam registros nas pastas 
		//"Apuração da Base de Cálculo do Lucro Presumido", "Cálculo do IRPJ com Base no Lucro Presumido", "Apuração da Base de Cálculo da CSLL com Base no Lucro Presumido" e "Cálculo da CSLL com Base no Lucro Presumido" do cadastro do Bloco P'
		AddLogErro( STR0131, @cLogErros, { DToC( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ), DToC( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) } )
		Exit
	EndIf
Next nIndiceCEI

Return()

/*/{Protheus.doc} LoadBlocoP
Carrega o Model do Bloco P
@author david.costa
@since 22/02/2017
@version 1.0
@param oModelBlcP, objeto,Objeto que receberá o Model
@param oModelPeri, objeto, Model do Período de Apuração
@param lReabertur, lógico, Indica se o model esta sendo carregado para a reabertura
@return ${Nil}, ${Nulo}
@example
LoadBlocoP( @oModelBlcP, oModelPeri, lReabertur )
/*/Static Function LoadBlocoP( oModelBlcP, oModelPeri, lReabertur )

Default oModelBlcP	:=	FWLoadModel( "TAFA321" )
Default lReabertur	:=	.F.

DBSelectArea( "CEG" )
CEG->( DBSetOrder( 2 ) )
If CEG->( MsSeek( xFilial( "CEG" ) + DToS( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ) + DToS( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) ) )
	oModelBlcP:SetOperation( MODEL_OPERATION_UPDATE )
	oModelBlcP:Activate()
ElseIf !lReabertur
	oModelBlcP:SetOperation( MODEL_OPERATION_INSERT )
	oModelBlcP:Activate()
	oModelBlcP:LoadValue( "MODEL_CEG", "CEG_DTINI", oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) )
	oModelBlcP:LoadValue( "MODEL_CEG", "CEG_DTFIN", oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) )
	oModelBlcP:LoadValue( "MODEL_CEG", "CEG_IDPERA", IdPerTri( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ), oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ), oModelPeri:GetValue( "MODEL_CWV", "CWV_ANUAL" ) ) )
EndIf

Return()

/*/{Protheus.doc} GetCodFolder
Retorna o código de controle do Folder para o cadastro da ECF
@author david.costa
@since 22/02/2017
@version 1.0
@param oModelCWX, objeto, O Model do detalhamento do periodo
@param cCodBloco, character, Codigo do bloco que esta sendo processado
@param cFormaTrib, character, Forma de Tributação do Evento
@return ${cCodFolder}, ${código de controle do Folder para o cadastro da ECF}
@example
GetCodFolder( oModelCWX, cCodBloco )
/*/Static Function GetCodFolder( oModelCWX, cCodBloco, cFormaTrib )

Local cCodFolder	as character
Local aGruposApu	as array

cCodFolder	:=	""
aGruposApu	:=	GrupoEvnto( , .T. )

If GetTpTribu( CWV->CWV_IDTRIB ) == TIPO_TRIBUTO_IRPJ
	//Grupo da Base de Cálculo
	If aScan( aGruposApu, { |x| x[ PARAM_GRUPO_ID ] == Val( oModelCWX:GetValue( "CWX_CODGRU" ) ) .and. x[ PARAM_GRUPO_TIPO ] == TIPO_GRUPO_BASE_CALCULO  } ) > 0
		If "P" $ cCodBloco
			cCodFolder := "02"
		ElseIf "U" $ cCodBloco
			cCodFolder := "01"
		ElseIf "T" $ cCodBloco
			cCodFolder := "01"
		ElseIf "N" $ cCodBloco
			If Val( oModelCWX:GetValue( "CWX_CODGRU" ) ) == GRUPO_LUCRO_EXPLORACAO .or. Val( oModelCWX:GetValue( "CWX_CODGRU" ) ) == GRUPO_RECEITA_LIQUIDA_ATIVIDA
				cCodFolder := "02"
			Else
				cCodFolder := "01"
			EndIf
		EndIf
	
	Else //Grupo do Cálculo
		If "P" $ cCodBloco
			cCodFolder := "04"
		ElseIf "U" $ cCodBloco
			cCodFolder := "01"
		ElseIf "T" $ cCodBloco
			cCodFolder := "02"
		ElseIf "N" $ cCodBloco
			If cFormaTrib == TRIBUTACAO_LUCRO_REAL
				cCodFolder := "05"
			Else
				cCodFolder := "04"
			EndIf
		EndIf
	EndIf
Else //CSLL
	//Grupo da Base de Cálculo
	If aScan( aGruposApu, { |x| x[ PARAM_GRUPO_ID ] == Val( oModelCWX:GetValue( "CWX_CODGRU" ) ) .and. x[ PARAM_GRUPO_TIPO ] == TIPO_GRUPO_BASE_CALCULO } ) > 0
		If "P" $ cCodBloco
			cCodFolder := "05"
		ElseIf "U" $ cCodBloco
			cCodFolder := "02"
		ElseIf "T" $ cCodBloco
			cCodFolder := "03"
		ElseIf "N" $ cCodBloco
			cCodFolder := "07"
		EndIf
	Else //Grupo do Cálculo
		If "P" $ cCodBloco
			cCodFolder := "06"
		ElseIf "U" $ cCodBloco
			cCodFolder := "02"
		ElseIf "T" $ cCodBloco
			cCodFolder := "04"
		ElseIf "N" $ cCodBloco
			If cFormaTrib == TRIBUTACAO_LUCRO_REAL
				cCodFolder := "09"
			Else
				cCodFolder := "08"
			EndIf
		EndIf
	EndIf
EndIf

Return( cCodFolder )

/*/{Protheus.doc} AddBlocoU
Adiciona o Registro no Cadastro do Bloco U
@author david.costa
@since 22/02/2017
@version 1.0
@param aBlocoU, array, Array com os itens que serão adicionados
@param cLogErros, character, Log de Erros do processo
@param cLogAvisos, character, Log de Avisos do processo
@param oModelPeri, objeto, Model do Período de Apuração
@return ${Nil}, ${Nulo}
@example
AddBlocoU( aBlocoU, cLogErros, cLogAvisos, oModelPeri )
/*/Static Function AddBlocoU( aBlocoU, cLogErros, cLogAvisos, oModelPeri )

Local oModelBlcU		as object
Local oModelCFI		as object
Local cDescItem		as character
Local nIndiceCFI		as numeric
Local nIndicBlcU		as numeric
Local lSucesso		as logical

oModelBlcU	:=	Nil
oModelCFI	:=	Nil
cDescItem	:=	""
nIndiceCFI	:=	0
nIndicBlcU	:=	0
lSucesso	:=	.T.

//Carrega o cadastro do Bloco U
LoadBlocoU( @oModelBlcU, oModelPeri )

If GetTpTribu( CWV->CWV_IDTRIB ) == TIPO_TRIBUTO_IRPJ
	//Valida o Model "Cálculo do IRPJ das Empresas Imunes e Isentas"
	oModelCFI := oModelBlcU:GetModel( "MODEL_CFIa" )
	VlModelCFI( oModelCFI, @cLogErros, oModelPeri )
Else
	//Valida o Model "Cálculo da CSLL das Empresas Imunes e Isentas"
	oModelCFI := oModelBlcU:GetModel( "MODEL_CFIb" )
	VlModelCFI( oModelCFI, @cLogErros, oModelPeri )
EndIf

//Adiciona os itens ao Cadastro
If Empty( cLogErros )
	For nIndicBlcU := 1 to Len( aBlocoU )
		
		If !oModelCFI:IsEmpty()
			oModelCFI:AddLine()
		EndIf 
		lSucesso := lSucesso .and. oModelCFI:SetValue( "CFI_IDCODC", aBlocoU[ nIndicBlcU, 1 ] )
		lSucesso := lSucesso .and. oModelCFI:SetValue( "CFI_VALOR", aBlocoU[ nIndicBlcU, 2 ] )
		lSucesso := lSucesso .and. oModelCFI:SetValue( "CFI_REGECF", aBlocoU[ nIndicBlcU, 3 ] )
		lSucesso := lSucesso .and. oModelCFI:SetValue( "CFI_ORIGEM", "A" ) // A- AUTOMÁTICO
		oModelCFI:lValid := .T.
		
		If lSucesso
			//Grava no log o resgistro inserido
			cDescItem := Posicione( "CH6", 1, xFilial("CH6") + aBlocoU[ nIndicBlcU, 1 ], "AllTrim( CH6_CODIGO ) + ' ' + AllTrim( CH6_DESCRI )" )
			AddLogErro( STR0145, @cLogAvisos, { Round( aBlocoU[ nIndicBlcU, 2 ], 2 ), cDescItem } ) //'Foi adicionado um item com o valor @1 codigo @2 no cadastro do bloco U'
		Else
			AddLogErro( STR0146, @cLogErros, { Round( aBlocoU[ nIndicBlcU, 2 ], 2 ), cDescItem } ) //'Não foi Possível adicionar o valor @1 codigo @2 no cadastro do bloco U. Verifique o cadastro do bloco.'
		EndIf
	Next nIndicBlcU
	
	If oModelBlcU:VldData() .and. Empty( cLogErros )
		//Salva o cadastro
		FWFormCommit( oModelBlcU )
	ElseIf !Empty( oModelBlcU:GetErrorMessagem()[6] )
		AddLogErro( STR0163, @cLogErros ) //"Não foi possível salvar o cadastro"
		AddLogErro( STR0165, @cLogErros, { oModelBlcU:GetErrorMessagem()[4], ENTER,; //"Campo: @1 @2Detalhes: @3, @2 @4"
				 oModelBlcU:GetErrorMessagem()[6], oModelBlcU:GetErrorMessagem()[7] } )
	EndIf

EndIf

Return()

/*/{Protheus.doc} LoadBlocoU
Carrega o Model do Bloco U
@author david.costa
@since 22/02/2017
@version 1.0
@param oModelBlcU, objeto,Objeto que receberá o Model
@param oModelPeri, objeto, Model do Período de Apuração
@param lReabertur, lógico, Indica se o model esta sendo carregado para a reabertura
@return ${lRet}, ${lRet}
@example
LoadBlocoU( @oModelBlcU, oModelPeri, lReabertur )
/*/Static Function LoadBlocoU( oModelBlcU, oModelPeri, lReabertur )

Local lRet		as logical

Default oModelBlcU	:=	FWLoadModel( "TAFA324" )
Default lReabertur	:=	.F.

lRet		:= .F.

DBSelectArea( "CEY" )
CEY->( DBSetOrder( 2 ) )
If CEY->( MsSeek( xFilial( "CEY" ) + DToS( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ) + DToS( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) ) )
	oModelBlcU:SetOperation( MODEL_OPERATION_UPDATE )
	oModelBlcU:Activate()
	lRet := .T.
ElseIf !lReabertur
	oModelBlcU:SetOperation( MODEL_OPERATION_INSERT )
	oModelBlcU:Activate()
	oModelBlcU:LoadValue( "MODEL_CEY", "CEY_DTINI", oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) )
	oModelBlcU:LoadValue( "MODEL_CEY", "CEY_DTFIN", oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) )
	oModelBlcU:LoadValue( "MODEL_CEY", "CEY_IDPERA", IdPerTri( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ), oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ), oModelPeri:GetValue( "MODEL_CWV", "CWV_ANUAL" ) ) )
	lRet := .T.
EndIf

Return( lRet )

/*/{Protheus.doc} VlModelCFI
Valida se o Cadastro do Bloco U está em branco e pode receber os dados da apuração
@author david.costa
@since 22/02/2017
@version 1.0
@param oModelCFI, objeto, Model CFI que será validado
@param cLogErros, character, Log de Erros do processo
@param oModelPeri, objeto, Model do período
@return ${Nil}, ${Nulo}
@example
VlModelCFI( oModelCFI, cLogErros, aBlocoU, oModelPeri )
/*/Static Function VlModelCFI( oModelCFI, cLogErros, oModelPeri )

Local nIndiceCFI	as numeric

nIndiceCFI	:=	0

//Valida se o Cadastro está em branco
For nIndiceCFI := 1 to oModelCFI:Length()
	oModelCFI:GoLine( nIndiceCFI )
	If !oModelCFI:IsEmpty() .and. !oModelCFI:IsDeleted() .and. oModelCFI:GetValue( "CFI_REGECF" ) $ "01|02|"
		//'Existem Lançamentos criados no cadastro do Bloco U para o período de @1 até @2. Para executar este processo é necessário que não 
		//existam registros nas pastas "Cálculo do IRPJ das Empresas Imunes e Isentas" e "Cálculo da CSLL das Empresas Imunes e Isentas" do cadastro do Bloco U'
		AddLogErro( STR0132, @cLogErros, { DToC( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ), DToC( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) } )
		Exit
	EndIf
Next nIndiceCFI

Return()

/*/{Protheus.doc} AddBlocoT
Adiciona o Registro no Cadastro do Bloco T
@author david.costa
@since 22/02/2017
@version 1.0
@param aBlocoT, array, Array com os itens que serão adicionados
@param cLogErros, character, Log de Erros do processo
@param cLogAvisos, character, Log de Avisos do processo
@param oModelPeri, objeto, Model do Período de Apuração
@return ${Nil}, ${Nulo}
@example
AddBlocoT( aBlocoT, cLogErros, cLogAvisos, oModelPeri )
/*/Static Function AddBlocoT( aBlocoT, cLogErros, cLogAvisos, oModelPeri )

Local oModelBlcT	as object
Local oModelCEK		as object
Local cDescItem		as character
Local nIndiceCEK	as numeric
Local nIndicBlcT	as numeric
Local lSucesso		as logical

oModelBlcT	:=	Nil
oModelCEK	:=	Nil
cDescItem	:=	""
nIndiceCEK	:=	0
nIndicBlcT	:=	0
lSucesso	:=	.T.

//Carrega o cadastro do Bloco T
LoadBlocoT( @oModelBlcT, oModelPeri )

If GetTpTribu( CWV->CWV_IDTRIB ) == TIPO_TRIBUTO_IRPJ
	//Valida o Model "Apuração da Base de Cálculo do IRPJ com Base no Lucro Arbitrado"
	oModelCEK := oModelBlcT:GetModel( "MODEL_CEKa" )
	VlModelCEK( oModelCEK, @cLogErros, oModelPeri )
	
	//Valida o Model "Cálculo do IRPJ com Base no Lucro Arbitrado"
	oModelCEK := oModelBlcT:GetModel( "MODEL_CEKb" )
	VlModelCEK( oModelCEK, @cLogErros, oModelPeri )
Else
	//Valida o Model "Apuração da Base de Cálculo da CSLL com Base no Lucro Arbitrado"
	oModelCEK := oModelBlcT:GetModel( "MODEL_CEKc" )
	VlModelCEK( oModelCEK, @cLogErros, oModelPeri )
	
	//Valida o Model "Cálculo da CSLL com Base no Lucro Arbitrado"
	oModelCEK := oModelBlcT:GetModel( "MODEL_CEKd" )
	VlModelCEK( oModelCEK, @cLogErros, oModelPeri )
EndIf

//Adiciona os itens ao Cadastro
If Empty( cLogErros )
	For nIndicBlcT := 1 to Len( aBlocoT )
		
		If !oModelCEK:IsEmpty()
			oModelCEK:AddLine()
		EndIf
		lSucesso := lSucesso .and. oModelCEK:SetValue( "CEK_IDCODC", aBlocoT[ nIndicBlcT, 1 ] )
		lSucesso := lSucesso .and. oModelCEK:SetValue( "CEK_VALOR", aBlocoT[ nIndicBlcT, 2 ] )
		lSucesso := lSucesso .and. oModelCEK:SetValue( "CEK_REGECF", aBlocoT[ nIndicBlcT, 3 ] )
		lSucesso := lSucesso .and. oModelCEK:SetValue( "CEK_ORIGEM", "A" ) // A- AUTOMÁTICO
		oModelCEK:lValid := .T.
		
		If lSucesso
			//Grava no log o resgistro inserido
			cDescItem := Posicione( "CH6", 1, xFilial("CH6") + aBlocoT[ nIndicBlcT, 1 ], "AllTrim( CH6_CODIGO ) + ' ' + AllTrim( CH6_DESCRI )" )
			AddLogErro( STR0143, @cLogAvisos, { Round( aBlocoT[ nIndicBlcT, 2 ], 2 ), cDescItem } ) //'Foi adicionado um item com o valor @1 codigo @2 no cadastro do bloco T'
		Else
			AddLogErro( STR0144, @cLogAvisos, { Round( aBlocoT[ nIndicBlcT, 2 ], 2 ), cDescItem } ) //'Não foi Possível adicionar o valor @1 codigo @2 no cadastro do bloco T. Verifique o cadastro do bloco.'
		EndIf
	Next nIndicBlcT
	
	//Salva o cadastro
	FWFormCommit( oModelBlcT )
EndIf

Return()

/*/{Protheus.doc} LoadBlocoT
Carrega o Model do Bloco T
@author david.costa
@since 22/02/2017
@version 1.0
@param oModelBlcT, objeto,Objeto que receberá o Model
@param oModelPeri, objeto, Model do Período de Apuração
@param lReabertur, lógico, Indica se o model esta sendo carregado para a reabertura
@return ${lRet}, ${lRet}
@example
LoadBlocoT( @oModelBlcT, oModelPeri, lReabertur )
/*/Static Function LoadBlocoT( oModelBlcT, oModelPeri, lReabertur )

Local lRet	as logical

Default oModelBlcT	:=	FWLoadModel( "TAFA323" )
Default lReabertur	:=	.F.

lRet		:= .F.

DBSelectArea( "CEJ" )
CEJ->( DBSetOrder( 2 ) )
If CEJ->( MsSeek( xFilial( "CEJ" ) + DToS( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ) + DToS( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) ) )
	oModelBlcT:SetOperation( MODEL_OPERATION_UPDATE )
	oModelBlcT:Activate()
	lRet := .T.
ElseIf !lReabertur
	oModelBlcT:SetOperation( MODEL_OPERATION_INSERT )
	oModelBlcT:Activate()
	oModelBlcT:LoadValue( "MODEL_CEJ", "CEJ_DTINI", oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) )
	oModelBlcT:LoadValue( "MODEL_CEJ", "CEJ_DTFIN", oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) )
	oModelBlcT:LoadValue( "MODEL_CEJ", "CEJ_IDPERA", IdPerTri( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ), oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ), oModelPeri:GetValue( "MODEL_CWV", "CWV_ANUAL" ) ) )
	lRet := .T.
EndIf

Return( lRet )

/*/{Protheus.doc} VlModelCEK
Valida se o Cadastro do BlocoT está em branco e pode receber os dados da apuração
@author david.costa
@since 22/02/2017
@version 1.0
@param oModelCEK, objeto, Model CEK que será validado
@param cLogErros, character, Log de Erros do processo
@param oModelPeri, objeto, Model do período
@return ${Nil}, ${Nulo}
@example
VlModelCEK( oModelCEK, cLogErros, aBlocoT, oModelPeri )
/*/Static Function VlModelCEK( oModelCEK, cLogErros, oModelPeri )

Local nIndiceCEK	as numeric

nIndiceCEK	:=	0

//Valida se o Cadastro está em branco
For nIndiceCEK := 1 to oModelCEK:Length()
	oModelCEK:GoLine( nIndiceCEK )
	If !oModelCEK:IsEmpty() .and. !oModelCEK:IsDeleted() .and. oModelCEK:GetValue( "CEK_REGECF" ) $ "01|02|03|04|"
	//'Existem Lançamentos criados no cadastro do Bloco T para o período de @1 até @2. Para executar este processo é necessário que não existam registros nas pastas 
	//"Apuração da Base de Cálculo do IRPJ com Base no Lucro Arbitrado", "Cálculo do IRPJ com Base no Lucro Arbitrado", "Apuração da Base de Cálculo da CSLL com 
	//Base no Lucro Arbitrado" e "Cálculo da CSLL com Base no Lucro Arbitrado" do cadastro do Bloco T'
		AddLogErro( STR0133, @cLogErros, { DToC( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ), DToC( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) } )
		Exit
	EndIf
Next nIndiceCEK

Return()

/*/{Protheus.doc} AddBlocoN
Adiciona o Registro no Cadastro do Bloco N
@author david.costa
@since 22/02/2017
@version 1.0
@param aBlocoN, array, Array com os itens que serão adicionados
@param cLogErros, character, Log de Erros do processo
@param cLogAvisos, character, Log de Avisos do processo
@param oModelPeri, objeto, Model do Período de Apuração
@return ${Nil}, ${Nulo}
@example
AddBlocoN( aBlocoN, cLogErros, cLogAvisos, oModelPeri )
/*/Static Function AddBlocoN( aBlocoN, cLogErros, cLogAvisos, oModelPeri )

Local oModelBlcN	as object
Local oModelCEB	as object
Local cDescItem	as character
Local nIndiceCEB	as numeric
Local nIndicBlcN	as numeric
Local lSucesso	as logical

oModelBlcN	:=	Nil
oModelCEB	:=	Nil
cDescItem	:=	""
nIndiceCEB	:=	0
nIndicBlcN	:=	0
lSucesso	:=	.T.

//Carrega o cadastro do Bloco N
If LoadBlocoN( @oModelBlcN, oModelPeri )

	If GetTpTribu( CWV->CWV_IDTRIB ) == TIPO_TRIBUTO_IRPJ
		//Valida o Model "Base Cáalc. IPRJ sobre lucro real após compensações prejuízo"
		oModelCEB := oModelBlcN:GetModel( "MODEL_CEB_01" )
		VlModelCEB( oModelCEB, @cLogErros, oModelPeri )
		
		//Valida o Model "Demonstração do Lucro da Exploração"
		oModelCEB := oModelBlcN:GetModel( "MODEL_CEB_02" )
		VlModelCEB( oModelCEB, @cLogErros, oModelPeri )
		
		//Valida o Model "Cálculo do IRPJ mensal por estimativa"
		oModelCEB := oModelBlcN:GetModel( "MODEL_CEB_04" )
		VlModelCEB( oModelCEB, @cLogErros, oModelPeri )
		
		//Valida o Model "Cálculo do IRPJ com Base no Lucro Real"
		oModelCEB := oModelBlcN:GetModel( "MODEL_CEB_05" )
		VlModelCEB( oModelCEB, @cLogErros, oModelPeri )
	Else
		//Valida o Model "Base CSLL após Compens. Base Negativa"
		oModelCEB := oModelBlcN:GetModel( "MODEL_CEB_06" )
		VlModelCEB( oModelCEB, @cLogErros, oModelPeri )
		
		//Valida o Model "Cálculo da CSLL mensal por estimativa"
		oModelCEB := oModelBlcN:GetModel( "MODEL_CEB_07" )
		VlModelCEB( oModelCEB, @cLogErros, oModelPeri )
		
		//Valida o Model "Cálculo da CSLL com base Lucro Real"
		oModelCEB := oModelBlcN:GetModel( "MODEL_CEB_08" )
		VlModelCEB( oModelCEB, @cLogErros, oModelPeri )
	EndIf

	//Adiciona os itens ao Cadastro
	If Empty( cLogErros )
	
		For nIndicBlcN := 1 to Len( aBlocoN )
			
			If !oModelCEB:IsEmpty()
				oModelCEB:AddLine()
			EndIf
			
			lSucesso := lSucesso .and. oModelCEB:LoadValue( "CEB_REGECF", aBlocoN[ nIndicBlcN, 3 ] )
			lSucesso := lSucesso .and. oModelCEB:LoadValue( "CEB_IDCODL", aBlocoN[ nIndicBlcN, 1 ] )
			lSucesso := lSucesso .and. oModelCEB:LoadValue( "CEB_VALOR", aBlocoN[ nIndicBlcN, 2 ] )
			lSucesso := lSucesso .and. oModelCEB:LoadValue( "CEB_ORIGEM", "A" ) // A- AUTOMÁTICO
			oModelCEB:lValid := .T.
			
			If lSucesso
				//Grava no log o resgistro inserido
				cDescItem := Posicione( "CH6", 1, xFilial("CH6") + aBlocoN[ nIndicBlcN, 1 ], "AllTrim( CH6_CODIGO ) + ' ' + AllTrim( CH6_DESCRI )" )
				AddLogErro( STR0141, @cLogAvisos, { Round( aBlocoN[ nIndicBlcN, 2 ], 2 ), cDescItem } ) // 'Foi adicionado um item com o valor @1 codigo @2 no cadastro do bloco N'
			Else
				AddLogErro( STR0142, @cLogAvisos, { Round( aBlocoN[ nIndicBlcN, 2 ], 2 ), cDescItem } ) //'Não foi Possível adicionar o valor @1 codigo @2 no cadastro do bloco N. Verifique o cadastro do bloco.'
			EndIf
		Next nIndicBlcN
		
		//Salva o cadastro
		FWFormCommit( oModelBlcN )
	EndIf
	
	oModelBlcN:Destroy()
EndIf

Return()

/*/{Protheus.doc} LoadBlocoN
Carrega o Model do Bloco N
@author david.costa
@since 22/02/2017
@version 1.0
@param oModelBlcN, objeto,Objeto que receberá o Model
@param oModelPeri, objeto, Model do Período de Apuração
@param lReabertur, lógico, Indica se o model esta sendo carregado para a reabertura
@return ${Nil}, ${Nulo}
@example
LoadBlocoN( @oModelBlcN, oModelPeri, lReabertur )
/*/Static Function LoadBlocoN( oModelBlcN, oModelPeri, lReabertur )

Local dIniPer	as date
Local lRet 	as logical

Default oModelBlcN	:=	FWLoadModel( "TAFA319" )
Default lReabertur	:=	.F.

dIniPer	:=	Nil
lRet 		:= .F.

If Month( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ) == Month( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) )
	dIniPer := SToD( AllTrim( Str( Year( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ) ) ) + "0101" )
Else
	dIniPer := oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" )
EndIf

DBSelectArea( "CEA" )
CEA->( DBSetOrder( 2 ) )
If CEA->( MsSeek( xFilial( "CEA" ) + DToS( dIniPer ) + DToS( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) + IdPerTri( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ), dIniPer, oModelPeri:GetValue( "MODEL_CWV", "CWV_ANUAL" ) ) ) )
	oModelBlcN:SetOperation( MODEL_OPERATION_UPDATE )
	oModelBlcN:Activate()
	lRet := .T.
ElseIf !lReabertur
	oModelBlcN:SetOperation( MODEL_OPERATION_INSERT )
	oModelBlcN:Activate()
	oModelBlcN:LoadValue( "MODEL_CEA", "CEA_DTINI", dIniPer )
	oModelBlcN:LoadValue( "MODEL_CEA", "CEA_DTFIN", oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) )
	oModelBlcN:LoadValue( "MODEL_CEA", "CEA_IDPERA", IdPerTri( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ), oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ), oModelPeri:GetValue( "MODEL_CWV", "CWV_ANUAL" ) ) )
	lRet := .T.
EndIf

Return( lRet )

/*/{Protheus.doc} VlModelCEB
Valida se o Cadastro do BlocoN está em branco e pode receber os dados da apuração
@author david.costa
@since 22/02/2017
@version 1.0
@param oModelCEB, objeto, Model CEB que será validado
@param cLogErros, character, Log de Erros do processo
@param oModelPeri, objeto, Model do período
@return ${Nil}, ${Nulo}
@example
VlModelCEB( oModelCEB, cLogErros, aBlocoN, oModelPeri )
/*/Static Function VlModelCEB( oModelCEB, cLogErros, oModelPeri )

Local nIndiceCEB	as numeric

nIndiceCEB	:=	0

//Valida se o Cadastro está em branco
For nIndiceCEB := 1 to oModelCEB:Length()
	oModelCEB:GoLine( nIndiceCEB )
	If !oModelCEB:IsEmpty() .and. !oModelCEB:IsDeleted() .and. oModelCEB:GetValue( "CEB_REGECF" ) $ "01|02|04|05|07|08|09|"
		//'Existem Lançamentos criados no cadastro do Bloco N para o período de @1 até @2. Para executar este processo é necessário que não existam registros nas pastas do cadastro do Bloco N'
		AddLogErro( STR0134, @cLogErros, { DToC( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ), DToC( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) } )
		Exit
	EndIf
Next nIndiceCEB

Return()

/*/{Protheus.doc} AddBlocoM
Adiciona o Registro no Cadastro do Bloco M
@author david.costa
@since 22/02/2017
@version 1.0
@param aBlocoM, array, Array com os itens que serão adicionados
@param cLogErros, character, Log de Erros do processo
@param cLogAvisos, character, Log de Avisos do processo
@param oModelPeri, objeto, Model do Período de Apuração
@return ${Nil}, ${Nulo}
@example
AddBlocoM( aBlocoM, cLogErros, cLogAvisos, oModelPeri )
/*/Static Function AddBlocoM( aBlocoM, cLogErros, cLogAvisos, oModelPeri )

Local oModelBlcM as object
Local oModelCFR  as object
Local oModelCP   as object
Local oModelCEO  as object
Local oModelCEP  as object
Local oModelCEQ  as object
Local oModelCER  as object
Local oModelCES  as object
Local oModelCHR  as object
Local oModelCHS  as object
Local oModelCHT  as object
Local oModelCHU  as object
Local oModelCHV  as object
Local oModelCET  as object
Local oModelCEU  as object
Local cAliasQry  as character
Local cDescItem  as character
Local cIDConta   as character
Local cNatureza  as character
Local cTipoRel   as character
Local cIdCodL    as character
Local cCHTCta    as character
Local cCodCus    as character
Local cCHTctb    as character
Local cIndLc     as character
Local cIndSldAtu as character
Local nIndiceCEB as numeric
Local nIndicM300 as numeric
Local nIndicM305 as numeric
Local nIndicM310 as numeric
Local nIndicM312 as numeric
Local nI         as numeric
Local nVlrLc     as numeric
Local nVlrCEO    as numeric
Local nVlrCHR    as numeric
Local nlA        as numeric
Local nSaldoCFR  as numeric
Local aProcessos as array
Local lCommitCET as logical
Local lSucesso   as logical

oModelBlcM	:=	Nil
oModelCFR	:=	Nil
oModelCP	:=	Nil
oModelCEO	:=	Nil
oModelCEP	:=	Nil
oModelCEQ	:=	Nil
oModelCER	:=	Nil
oModelCES	:=	Nil
oModelCHR	:=	Nil
oModelCHS	:=	Nil
oModelCHT	:=	Nil
oModelCHU	:=	Nil
oModelCHV	:=	Nil
oModelCET	:=	Nil
oModelCEU	:=	Nil
cAliasQry	:=	""
cDescItem	:=	""
cIDConta	:=	""
cNatureza	:=	""
cTipoRel	:=	""
cIdCodL     :=  ""
cCHTCta		:=  ""
cCodCus		:=  ""
cCHTctb		:=  ""
cIndSldAtu	:=  ""
nIndiceCEB	:=	0
nIndicM300	:=	0
nIndicM305	:=	0
nIndicM310	:=	0
nIndicM312	:=	0
nI			:=	0
nSaldoCFR	:=	0
aProcessos	:=	{}
lCommitCET	:=	.T.
lSucesso	:=	.T.
cIndLc		:= ''
nVlrLc		:= 0
nVlrCEO		:= 0
nVlrCHR		:= 0
nlA			:= 0

//Carrega o cadastro do Bloco M
LoadBlocoM( @oModelBlcM, oModelPeri )

/****************************/
//			IRPJ			//
/****************************/
If GetTpTribu( CWV->CWV_IDTRIB ) == TIPO_TRIBUTO_IRPJ

	//Valida o modelo "Lançamentos da Parte A do e-Lalur"
	oModelCEO := oModelBlcM:GetModel( "MODEL_CEO" )

	If oModelCEO:IsEmpty()
		oModelCEO:SetNoInsertLine( .F. )
		VlModelCEO( oModelCEO, @cLogErros, oModelPeri )

		//Model do M310
		oModelCEQ := oModelBlcM:GetModel( "MODEL_CEQ" )

		//Preenche o M300
		For nIndicM300 := 1 to Len( aBlocoM )
			If aBlocoM[ nIndicM300, M300_VALOR ] != 0
				
				cTipoRel := iIf( aBlocoM[ nIndicM300, M300_POSSUI_LANC_MANUAL ] , SEM_RELACIONAMENTO, "" )
				aProcessos := aBlocoM[nIndicM300,M300_M315]

				If !oModelCEO:IsEmpty()
					oModelCEO:AddLine()
				endif	
				cIdCodL := aBlocoM[ nIndicM300, M300_ID_TABELA_DINAMICA ]
				nVlrCEO 	:= aBlocoM[ nIndicM300, M300_VALOR ]

				lSucesso := lSucesso .and. oModelCEO:SetValue( "CEO_IDCODL", cIdCodL )
				lSucesso := lSucesso .and. oModelCEO:SetValue( "CEO_VLRLC" , nVlrCEO )
				lSucesso := lSucesso .and. oModelCEO:SetValue( "CEO_REGECF", ConvCodECF( Posicione( "CH8", 1, xFilial( "CH8" ) + aBlocoM[nIndicM300, M300_ID_TABELA_DINAMICA], "CH8_CODREG" ) ) )
				lSucesso := lSucesso .and. oModelCEO:SetValue( "CEO_ORIGEM", "A" ) //A - AUTOMATICO
				lSucesso := lSucesso .and. oModelCEO:SetValue( "CEO_HISTLC", left(aBlocoM[ nIndicM300, M300_HISTORICO ],220) )

				//Preenche M310
				For nIndicM310 := 1 to Len( aBlocoM[ nIndicM300, M300_M310 ] )

					If !oModelCEQ:IsEmpty()
						oModelCEQ:AddLine()
					EndIf

					lSucesso := lSucesso .and. oModelCEQ:LoadValue( "CEQ_CTA", aBlocoM[ nIndicM300, M300_M310, nIndicM310, M310_ID_CONTA_CONTABIL ] )
					lSucesso := lSucesso .and. oModelCEQ:LoadValue( "CEQ_CODCUS", aBlocoM[ nIndicM300, M300_M310, nIndicM310, M310_ID_CENTRO_CUSTO ] )
					lSucesso := lSucesso .and. oModelCEQ:LoadValue( "CEQ_VLRLC", Abs( aBlocoM[ nIndicM300, M300_M310, nIndicM310, M310_VALOR ] ) )
					
					//se tem parte B também, vejo natureza da conta da parte B
					if !Empty( aBlocoM[nIndicM300,M300_M305] )
						cNatureza 	:= aBlocoM[nIndicM300,M300_M305,1,M010_INDICADOR_SALDO]
						
						if len(aBlocoM[nIndicM300,M300_M305,1]) > 14
							//Se bloco m305 foi gerado pelo m310, então busco indicado do saldo da conta parte b para inverter o sinal na função GetIndM310
							if aBlocoM[nIndicM300,M300_M305,1,M010_GERA_M305]
								cIndSldAtu  := aBlocoM[nIndicM300,M300_M305,1,M010_IND_SALDO_ATU]
							else
								cIndSldAtu	:= ""
							endif
							
						else
							cIndSldAtu	:= ""
						Endif
					else
						cNatureza 	:= ""
					Endif

					
					If cIndSldAtu == "1"
						lSucesso := lSucesso .and. oModelCEQ:LoadValue( "CEQ_INDVLR", GetIndM310( aBlocoM[ nIndicM300, M300_M310, nIndicM310 ], aBlocoM[ nIndicM300, M300_ID_GRUPO_EVENTO ], .t. ) )
					ElseIf cIndSldAtu == "2"
						lSucesso := lSucesso .and. oModelCEQ:LoadValue( "CEQ_INDVLR", GetIndM310( aBlocoM[ nIndicM300, M300_M310, nIndicM310 ], aBlocoM[ nIndicM300, M300_ID_GRUPO_EVENTO ], .f. ) )
					else
						lSucesso := lSucesso .and. oModelCEQ:LoadValue( "CEQ_INDVLR", GetIndM310( aBlocoM[ nIndicM300, M300_M310, nIndicM310 ], aBlocoM[ nIndicM300, M300_ID_GRUPO_EVENTO ], .f. ) )
					Endif
					

					cTipoRel := GetRelM300( cTipoRel, COM_CONTA_CONTABIL )
					oModelCEO:lValid := .T.

					//Preenche M312
					For nIndicM312 := 1 to Len( aBlocoM[ nIndicM300, M300_M310, nIndicM310, M310_M312 ] )

						//Model do M312
						oModelCER := oModelBlcM:GetModel( "MODEL_CER" )

						If !oModelCER:IsEmpty()
							oModelCER:AddLine()
						EndIf

						//Campo virtual preenchido somente para evitar erros ao salvar o model
						lSucesso := lSucesso .and. oModelCER:LoadValue( "CER_NUMLCT", "x" )
						lSucesso := lSucesso .and. oModelCER:LoadValue( "CER_IDNUML", aBlocoM[ nIndicM300, M300_M310, nIndicM310, M310_M312, nIndicM312, M312_ID_LANCAMENTO ] )
						oModelCER:lValid := .T.

					Next nIndicM312
				Next nIndicM310

				// Conta da Parte B
				If !Empty( aBlocoM[nIndicM300,M300_M305] ) .and. lSucesso
					oModelCEP := oModelBlcM:GetModel( "MODEL_CEP" )
					oModelCET := oModelBlcM:GetModel( "MODEL_CET" )
		
					For nI := 1 to Len( aBlocoM[nIndicM300,M300_M305] )

						lSucesso := lSucesso .and. GeraM010( aBlocoM[nIndicM300,M300_M305,nI], oModelPeri, @oModelCFR, @cLogErros )

						If !lSucesso
							Exit
						Else
							cIDConta 	:= oModelCFR:GetValue( "MODEL_CFR", "CFR_ID" )
							nSaldoCFR 	:= oModelCFR:GetValue( "MODEL_CFR", "CFR_VLSALD" )
							cNatureza 	:= aBlocoM[nIndicM300,M300_M305,nI,M010_INDICADOR_SALDO]
							
							if len(aBlocoM[nIndicM300,M300_M305,nI]) > 14
								cIndSldAtu  := aBlocoM[nIndicM300,M300_M305,nI,M010_IND_SALDO_ATU]
							else
								cIndSldAtu	:= ""
							Endif

							//Adição ou exclusão
							if strzero(aBlocoM[nIndicM300][M300_ID_GRUPO_EVENTO],2) $ '09|10|11|12'
								If !oModelCEP:IsEmpty()
									oModelCEP:AddLine()
								EndIf

								cTipoRel := GetRelM300( cTipoRel, COM_CONTA_DA_PARTE_B )

								lSucesso := lSucesso .and. oModelCEP:SetValue( "CEP_CTA", oModelCFR:GetValue( "MODEL_CFR", "CFR_CODCTA" ) )
								lSucesso := lSucesso .and. oModelCEP:SetValue( "CEP_IDCTA", cIDConta )
								lSucesso := lSucesso .and. oModelCEP:SetValue( "CEP_VLRLC", aBlocoM[nIndicM300][M300_M305][nI][M010_VLR_CONTA_PB_POR_COD_LALUR] )
								
								if cNatureza == "5"
									
									//INDICADOR DO SALDO DA CONTA (CONTA NATUREZA 5, ADIÇÃO OU EXCLUSÃO), OLHAR O SALDO DA CONTA
									//SE INDSALATU == DEBITO, TRATAR COMO EXCLUSÃO (CEP_INDLC == 1), SE FOR CREDITO TRATA COMO ADIÇÃO (CEP_INDLC == 2)

									If cIndSldAtu == "1"
										lSucesso := lSucesso .and. oModelCEP:SetValue( "CEP_INDLC", iif( strzero(aBlocoM[nIndicM300][M300_ID_GRUPO_EVENTO],2) $ '09|10','1','2') )
									ElseIf cIndSldAtu == "2"
										lSucesso := lSucesso .and. oModelCEP:SetValue( "CEP_INDLC", iif( strzero(aBlocoM[nIndicM300][M300_ID_GRUPO_EVENTO],2) $ '09|10','2','1') )
									else
										lSucesso := lSucesso .and. oModelCEP:SetValue( "CEP_INDLC", iif( strzero(aBlocoM[nIndicM300][M300_ID_GRUPO_EVENTO],2) $ '09|10','2','1') )
									Endif
									
								else
									lSucesso := lSucesso .and. oModelCEP:SetValue( "CEP_INDLC", iif( strzero(aBlocoM[nIndicM300][M300_ID_GRUPO_EVENTO],2) $ '09|10','2','1') )
								Endif

								
							elseIf ! (strzero(aBlocoM[nIndicM300][M300_ID_GRUPO_EVENTO],2) $ "01|02|") 
							
								cAliasQry := GetLancPB( aBlocoM[nIndicM300,M300_M305,nI], oModelPeri )

								While ( cAliasQry )->( !Eof() ) .and. lSucesso

									T0T->( DBGoTo( ( cAliasQry )->T0T_RECNO ) )

									nSaldoCFR := RetSaldo( nSaldoCFR, cNatureza, T0T->T0T_TPLANC, T0T->T0T_VLLANC )

									If ( T0T->T0T_TPLANC == TIPO_LANC_DEBITO .or. T0T->T0T_TPLANC == TIPO_LANC_CREDITO ) .and. cNatureza <> NATUREZA_DEDUCA_COMP_TRIBUTO

										cTipoRel := GetRelM300( cTipoRel, COM_CONTA_DA_PARTE_B )

										If lSucesso
											If oModelCEP:SeekLine( { { "CEP_IDCTA", cIDConta } } )
												cIndLc := iif( T0T->T0T_TPLANC == TIPO_LANC_DEBITO, AUMENTA_LUCRO_REAL, REDUZ_LUCRO_REAL)
												if cIndLc == oModelCEP:GetValue( 'CEP_INDLC' ) 
													lSucesso := lSucesso .and. oModelCEP:SetValue( "CEP_VLRLC", oModelCEP:GetValue( "CEP_VLRLC" ) + T0T->T0T_VLLANC )
												else
													nVlrLc := oModelCEP:GetValue( "CEP_VLRLC" ) - T0T->T0T_VLLANC
													lSucesso := lSucesso .and. oModelCEP:SetValue( "CEP_VLRLC", abs(nVlrLc) )
													if nVlrLc < 0
														lSucesso := lSucesso .and. oModelCEP:SetValue( "CEP_INDLC", cIndLc )
													endif	
												endif	
											Else
												If !oModelCEP:IsEmpty()
													oModelCEP:AddLine()
												EndIf

												lSucesso := lSucesso .and. oModelCEP:SetValue( "CEP_CTA", oModelCFR:GetValue( "MODEL_CFR", "CFR_CODCTA" ) )
												lSucesso := lSucesso .and. oModelCEP:SetValue( "CEP_IDCTA", cIDConta )
												lSucesso := lSucesso .and. oModelCEP:SetValue( "CEP_VLRLC", T0T->T0T_VLLANC )
												lSucesso := lSucesso .and. oModelCEP:SetValue( "CEP_INDLC", Iif( T0T->T0T_TPLANC == TIPO_LANC_DEBITO, AUMENTA_LUCRO_REAL, Iif( T0T->T0T_TPLANC == TIPO_LANC_CREDITO, REDUZ_LUCRO_REAL, "" ) ) )

												If lSucesso .and. T0U->( MsSeek( xFilial( "T0U" ) + T0T->( T0T_ID + T0T_IDCODT + T0T_CODLAN ) ) )
													If aScan( aProcessos, { |x| AllTrim( x[M315_ID_PROCESSO] ) == AllTrim( T0U->T0U_IDPROC ) } ) <= 0
														If Len( aProcessos ) == 0
															aAdd( aProcessos, { T0U->T0U_IDPROC } )
														Else
															aAdd( aProcessos, T0U->T0U_IDPROC )
														EndIf
													EndIf
												EndIf
											EndIf

										EndIf

									ElseIf T0T->T0T_TPLANC == TIPO_LANC_CONSTITUIR_SALDO .or. cNatureza == NATUREZA_DEDUCA_COMP_TRIBUTO

										cTipoRel := GetRelM300( cTipoRel, COM_CONTA_DA_PARTE_B )

										if !oModelCET:IsEmpty(); oModelCET:AddLine(); endif
										lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_CTA", oModelCFR:GetValue( "MODEL_CFR", "CFR_CODCTA" ) )
										lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_DCTA", oModelCFR:GetValue( "MODEL_CFR", "CFR_DCODCT" ) )
										lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_IDCTA", cIDConta )
										lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_CODTRI", IRPJ )
										lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_VLRLC", T0T->T0T_VLLANC )

										If T0T->T0T_TPLANC == TIPO_LANC_CONSTITUIR_SALDO
											If cNatureza == NATUREZA_COMP_PREJ_BASE_NEGATIVA
												lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_IDLCTO", PREJUIZO_DO_EXERCICIO )
											Else
												If cNatureza == NATUREZA_ADICAO
													lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_IDLCTO", CREDITO )
												Else
													lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_IDLCTO", DEBITO )
												EndIf
											EndIf
										Else
											If T0T->T0T_TPLANC == TIPO_LANC_DEBITO
												lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_IDLCTO", DEBITO )
											Else
												lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_IDLCTO", CREDITO )
											EndIf
										EndIf

										If !Empty( T0T->T0T_CTDEST ) .and. lCommitCET
											lCommitCET := lCommitCET.and. GeraM010CP( T0T->T0T_CTDEST, oModelPeri, @oModelCP, @cLogErros )

											lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_CTACP", oModelCP:GetValue( "MODEL_CFR", "CFR_CODCTA" ) )
											lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_DCTACP", oModelCP:GetValue( "MODEL_CFR", "CFR_DCODCT" ) )
											lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_IDCTAC", oModelCP:GetValue( "MODEL_CFR", "CFR_ID" ) )

											oModelCP:DeActivate()
										EndIf

										lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_HISTLC", T0T->T0T_HISTOR )
										lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_TRIDIF", T0T->T0T_INDDIF )
										lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_ORIGEM", "A" ) //A - AUTOMÁTICO

										If lCommitCET .and. T0U->( MsSeek( xFilial( "T0U" ) + T0T->( T0T_ID + T0T_IDCODT + T0T_CODLAN ) ) )
											oModelCEU := oModelBlcM:GetModel( "MODEL_CEU" )

											While T0U->( !Eof() ) .and. T0U->( T0U_FILIAL + T0U_ID + T0U_IDCODT + T0U_CODLAN ) == xFilial( "T0U" ) + T0T->( T0T_ID + T0T_IDCODT + T0T_CODLAN ) .and. lCommitCET
												If !oModelCEU:IsEmpty()
													oModelCEU:AddLine()
												EndIf

												If !oModelCEU:SeekLine( { { "CEU_IDPROC", T0U->T0U_IDPROC } } )
													lCommitCET := lCommitCET .and. oModelCEU:SetValue( "CEU_IDPROC", T0U->T0U_IDPROC )
												EndIf
												T0U->( DBSkip() )
											EndDo
										EndIf

										If !lCommitCET
											lSucesso := .F.
											AddLogErro( STR0162, @cLogErros, { oModelCFR:GetValue( "MODEL_CFR", "CFR_CODCTA" ), oModelCFR:GetValue( "MODEL_CFR", "CFR_DCODCT" ) } ) //"Não foi possível adicionar a Conta @1 - @2 no Registro M410. Verifique o cadastro do Bloco."
										EndIf

									EndIf

									( cAliasQry )->( DBSkip() )
								EndDo
								( cAliasQry )->( DbCloseArea() )
							endif
						EndIf

						oModelCFR:DeActivate()

					Next nI

				EndIf

				// Processos
				If !Empty( aProcessos ) .and. lSucesso
					oModelCES := oModelBlcM:GetModel( "MODEL_CES" )
		
					For nI := 1 to Len( aProcessos )
						If !Empty( aProcessos[nI,M315_ID_PROCESSO] ) .and. lSucesso
							If !oModelCES:IsEmpty()
								oModelCES:AddLine()
							EndIf

							lSucesso := lSucesso .and. oModelCES:SetValue( "CES_IDPROC", aProcessos[nI,M315_ID_PROCESSO] )
						EndIf
					Next nI
				EndIf

				If lSucesso
					//Grava no log o registro inserido
					cDescItem := Posicione( "CH8", 1, xFilial( "CH8" ) + aBlocoM[nIndicM300,M300_ID_TABELA_DINAMICA], "AllTrim( CH8_CODIGO ) + ' ' + AllTrim( CH8_DESCRI )" )
					AddLogErro( STR0148, @cLogAvisos, { Round( aBlocoM[nIndicM300,M300_VALOR], 2 ), cDescItem } ) //"Foi adicionado um item com o valor @1 código @2 no cadastro do Bloco M"
				Else
					AddLogErro( STR0149, @cLogErros, { Round( aBlocoM[nIndicM300,M300_VALOR], 2 ), cDescItem } ) //"Não foi possível adicionar o valor @1 código @2 no cadastro do Bloco M. Verifique o cadastro do Bloco."
				EndIf

				lSucesso := lSucesso .and. oModelCEO:SetValue( "CEO_TIPORL",  GetRelM300( cTipoRel, cTipoRel ) )

				oModelCEO:lValid := .T.
			Else
				AddLogErro( STR0180, @cLogAvisos, { cValTochar(Round( aBlocoM[nIndicM300,M300_VALOR], 2 )), Posicione( "CH8", 1, xFilial("CH8") + aBlocoM[ nIndicM300, M300_ID_TABELA_DINAMICA ], "AllTrim( CH8_CODIGO ) + ' ' + AllTrim( CH8_DESCRI )" ) } ) 
			Endif
		Next nIndicM300 
	Else
		AddLogErro( STR0164, @cLogErros ) //"Os valores do Bloco M já estão preenchidos. Para gerar novamente apague os dados do bloco M ou reabra o Período."
	EndIf

/****************************/
//			CSLL			//
/****************************/
Else
	oModelCHR := oModelBlcM:GetModel( "MODEL_CHR" )
	
	If oModelCHR:IsEmpty()

		oModelCHR:SetNoInsertLine( .F. )
		VlModelCHR( oModelCHR, @cLogErros, oModelPeri )

		//Model do M360
		oModelCHT := oModelBlcM:GetModel( "MODEL_CHT" )

		//Preenche o M350
		For nIndicM300 := 1 to Len( aBlocoM )

			If aBlocoM[ nIndicM300, M300_VALOR ] != 0

				cTipoRel := iIf( aBlocoM[ nIndicM300, M300_POSSUI_LANC_MANUAL ] , SEM_RELACIONAMENTO, "" )
				aProcessos := aBlocoM[nIndicM300,M300_M315]

				If !oModelCHR:IsEmpty()
					oModelCHR:AddLine()
				EndIf

				cIdCodL := aBlocoM[ nIndicM300, M300_ID_TABELA_DINAMICA ]
				nVlrCHR  := aBlocoM[ nIndicM300, M300_VALOR ]
				cRegECF := ConvCodECF( Posicione( "CH8", 1, xFilial( "CH8" ) + aBlocoM[nIndicM300, M300_ID_TABELA_DINAMICA], "CH8_CODREG" ) )

				//Campo virtual preenchido com conteudo generico para evitar erros de validacao
				lSucesso := lSucesso .and. oModelCHR:LoadValue( "CHR_CODLAN", "x" )
				lSucesso := lSucesso .and. oModelCHR:SetValue( "CHR_IDCODL", cIdCodL )
				lSucesso := lSucesso .and. oModelCHR:LoadValue( "CHR_VLRLC", nVlrCHR )
				lSucesso := lSucesso .and. oModelCHR:SetValue( "CHR_REGECF", cRegECF ) 
				lSucesso := lSucesso .and. oModelCHR:SetValue( "CHR_ORIGEM", 'A' ) //A- AUTOMATICO
				lSucesso := lSucesso .and. oModelCHR:SetValue( "CHR_HISTLC", left(aBlocoM[ nIndicM300, M300_HISTORICO ],220) )

				//Preenche M360
				For nIndicM310 := 1 to Len( aBlocoM[ nIndicM300, M300_M310 ] )

					If !oModelCHT:IsEmpty()
						oModelCHT:AddLine()
					EndIf

					cCHTCta := aBlocoM[ nIndicM300, M300_M310, nIndicM310, M310_ID_CONTA_CONTABIL ]
					cCodCus := aBlocoM[ nIndicM300, M300_M310, nIndicM310, M310_ID_CENTRO_CUSTO ]
					cCHTctb := Posicione( "C1O", 3, xFilial("C1O") + cCodCus  , "C1O_CODIGO")

					lSucesso := lSucesso .and. oModelCHT:LoadValue( "CHT_CTA", cCHTCta )
					lSucesso := lSucesso .and. oModelCHT:LoadValue( "CHT_CTACTB", cCHTctb ) //X3_CONTEXT V
					lSucesso := lSucesso .and. oModelCHT:LoadValue( "CHT_CODCUS", cCodCus )
					lSucesso := lSucesso .and. oModelCHT:LoadValue( "CHT_VLRLC", Abs( aBlocoM[ nIndicM300, M300_M310, nIndicM310, M310_VALOR ] ) )
					lSucesso := lSucesso .and. oModelCHT:LoadValue( "CHT_INDVLR", GetIndM310( aBlocoM[ nIndicM300, M300_M310, nIndicM310 ], aBlocoM[ nIndicM300, M300_ID_GRUPO_EVENTO ] ) )
					oModelCHT:lValid := .T.

					cTipoRel := GetRelM300( cTipoRel, COM_CONTA_CONTABIL )

					//Preenche M362
					For nIndicM312 := 1 to Len( aBlocoM[ nIndicM300, M300_M310, nIndicM310, M310_M312 ] )

						//Model do M362
						oModelCHU := oModelBlcM:GetModel( "MODEL_CHU" )

						If !oModelCHU:IsEmpty()
							oModelCHU:AddLine()
						EndIf

						cIdNumL := aBlocoM[ nIndicM300, M300_M310, nIndicM310, M310_M312, nIndicM312, M312_ID_LANCAMENTO ]

						//Campo virtual preenchido somente para evitar erros ao salvar o model
						lSucesso := lSucesso .and. oModelCHU:LoadValue( "CHU_NUMLCT", "x" )
						lSucesso := lSucesso .and. oModelCHU:LoadValue( "CHU_IDNUML", cIdNumL )
						oModelCHU:lValid := .T.
					Next nIndicM312
				Next nIndicM310

				// Conta da Parte B
				If !Empty( aBlocoM[nIndicM300,M300_M305] ) .and. lSucesso
					oModelCHS := oModelBlcM:GetModel( "MODEL_CHS" )
					oModelCET := oModelBlcM:GetModel( "MODEL_CET" )

					For nI := 1 to Len( aBlocoM[nIndicM300,M300_M305] )

						lSucesso := lSucesso .and. GeraM010( aBlocoM[nIndicM300,M300_M305,nI], oModelPeri, @oModelCFR, @cLogErros )

						If !lSucesso
							Exit
						Else
							cIDConta := oModelCFR:GetValue( "MODEL_CFR", "CFR_ID" )
							nSaldoCFR := oModelCFR:GetValue( "MODEL_CFR", "CFR_VLSALD" )
							cNatureza := aBlocoM[nIndicM300,M300_M305,nI,M010_INDICADOR_SALDO]

							//Adição ou exclusão
							if strzero(aBlocoM[nIndicM300][M300_ID_GRUPO_EVENTO],2) $ '09|10|11|12'
								If !oModelCHS:IsEmpty()
									oModelCHS:AddLine()
								EndIf

								lSucesso := lSucesso .and. oModelCHS:SetValue( "CHS_CTA", oModelCFR:GetValue( "MODEL_CFR", "CFR_CODCTA" ) )
								lSucesso := lSucesso .and. oModelCHS:SetValue( "CHS_IDCTA", cIDConta )
								lSucesso := lSucesso .and. oModelCHS:SetValue( "CHS_VLRLC", aBlocoM[nIndicM300][M300_M305][nI][M010_VLR_CONTA_PB_POR_COD_LALUR] )

								//INDICADOR DO SALDO DA CONTA (CONTA NATUREZA 5, ADIÇÃO OU EXCLUSÃO), OLHAR O SALDO DA CONTA
								If cNatureza == "5"
									
									//SE INDSALATU == DEBITO, TRATAR COMO EXCLUSÃO (CHS_INDLC == 1), SE FOR CREDITO TRATA COMO ADIÇÃO (CHS_INDLC == 2)
									cIndSldAtu	:= ""
									If len(aBlocoM[nIndicM300,M300_M305,1]) > 14
										If aBlocoM[nIndicM300,M300_M305,1,M010_GERA_M305]
											cIndSldAtu  := aBlocoM[nIndicM300,M300_M305,1,M010_IND_SALDO_ATU]
										EndIf
									EndIf

									If cIndSldAtu == "1"
										lSucesso := lSucesso .and. oModelCHS:SetValue( "CHS_INDLC", iif( strzero(aBlocoM[nIndicM300][M300_ID_GRUPO_EVENTO],2) $ '09|10','1','2') )
									Else
										lSucesso := lSucesso .and. oModelCHS:SetValue( "CHS_INDLC", iif( strzero(aBlocoM[nIndicM300][M300_ID_GRUPO_EVENTO],2) $ '09|10','2','1') )
									Endif
								Else
									lSucesso := lSucesso .and. oModelCHS:SetValue( "CHS_INDLC", iif( strzero(aBlocoM[nIndicM300][M300_ID_GRUPO_EVENTO],2) $ '09|10','2','1') )
								Endif

								cTipoRel := GetRelM300( cTipoRel, COM_CONTA_DA_PARTE_B )
							elseIf ! (strzero(aBlocoM[nIndicM300][M300_ID_GRUPO_EVENTO],2) $ "01|02|") 	

								cAliasQry := GetLancPB( aBlocoM[nIndicM300,M300_M305,nI], oModelPeri )

								While ( cAliasQry )->( !Eof() ) .and. lSucesso

									T0T->( DBGoTo( ( cAliasQry )->T0T_RECNO ) )

									nSaldoCFR := RetSaldo( nSaldoCFR, cNatureza, T0T->T0T_TPLANC, T0T->T0T_VLLANC )

									If ( T0T->T0T_TPLANC == TIPO_LANC_DEBITO .or. T0T->T0T_TPLANC == TIPO_LANC_CREDITO ) .and. cNatureza <> NATUREZA_DEDUCA_COMP_TRIBUTO

										cTipoRel := GetRelM300( cTipoRel, COM_CONTA_DA_PARTE_B )

										If lSucesso
											If oModelCHS:SeekLine( { { "CHS_IDCTA", cIDConta } } )
												cIndLc := iif( T0T->T0T_TPLANC == TIPO_LANC_DEBITO, AUMENTA_LUCRO_REAL, REDUZ_LUCRO_REAL)
												if cIndLc == oModelCHS:GetValue( 'CHS_INDLC' ) 
													lSucesso := lSucesso .and. oModelCHS:SetValue( "CHS_VLRLC", oModelCHS:GetValue( "CHS_VLRLC" ) + T0T->T0T_VLLANC )
												else
													nVlrLc := oModelCHS:GetValue( "CHS_VLRLC" ) - T0T->T0T_VLLANC
													lSucesso := lSucesso .and. oModelCHS:SetValue( "CHS_VLRLC", abs(nVlrLc) )
													if nVlrLc < 0
														lSucesso := lSucesso .and. oModelCHS:SetValue( "CHS_INDLC", cIndLc )
													endif	
												endif	
											Else
												If !oModelCHS:IsEmpty()
													oModelCHS:AddLine()
												EndIf

												lSucesso := lSucesso .and. oModelCHS:SetValue( "CHS_CTA", oModelCFR:GetValue( "MODEL_CFR", "CFR_CODCTA" ) )
												lSucesso := lSucesso .and. oModelCHS:SetValue( "CHS_IDCTA", cIDConta )
												lSucesso := lSucesso .and. oModelCHS:SetValue( "CHS_VLRLC", T0T->T0T_VLLANC )
												lSucesso := lSucesso .and. oModelCHS:SetValue( "CHS_INDLC", Iif( T0T->T0T_TPLANC == TIPO_LANC_DEBITO, AUMENTA_LUCRO_REAL, Iif( T0T->T0T_TPLANC == TIPO_LANC_CREDITO, REDUZ_LUCRO_REAL, "" ) ) )

												If lSucesso .and. T0U->( MsSeek( xFilial( "T0U" ) + T0T->( T0T_ID + T0T_IDCODT + T0T_CODLAN ) ) )
													If aScan( aProcessos, { |x| AllTrim( x[M315_ID_PROCESSO] ) == AllTrim( T0U->T0U_IDPROC ) } ) <= 0
														If Len( aProcessos ) == 0
															aAdd( aProcessos, { T0U->T0U_IDPROC } )
														Else
															aAdd( aProcessos, T0U->T0U_IDPROC )
														EndIf
													EndIf
												EndIf
											EndIf
										EndIf

									ElseIf T0T->T0T_TPLANC == TIPO_LANC_CONSTITUIR_SALDO .or. cNatureza == NATUREZA_DEDUCA_COMP_TRIBUTO

										cTipoRel := GetRelM300( cTipoRel, COM_CONTA_DA_PARTE_B )

										if !oModelCET:IsEmpty(); oModelCET:AddLine(); endif
										lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_CTA", oModelCFR:GetValue( "MODEL_CFR", "CFR_CODCTA" ) )
										lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_DCTA", oModelCFR:GetValue( "MODEL_CFR", "CFR_DCODCT" ) )
										lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_IDCTA", cIDConta )
										lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_CODTRI", CSLL )
										lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_VLRLC", T0T->T0T_VLLANC )

										If T0T->T0T_TPLANC == TIPO_LANC_CONSTITUIR_SALDO
											If cNatureza == NATUREZA_COMP_PREJ_BASE_NEGATIVA
												lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_IDLCTO", BASE_DE_CALCULO_NEGATIVA_DA_CSLL )
											Else
												If cNatureza == NATUREZA_ADICAO
													lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_IDLCTO", CREDITO )
												Else
													lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_IDLCTO", DEBITO )
												EndIf
											EndIf
										Else
											If T0T->T0T_TPLANC == TIPO_LANC_DEBITO
												lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_IDLCTO", DEBITO )
											Else
												lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_IDLCTO", CREDITO )
											EndIf
										EndIf

										If !Empty( T0T->T0T_CTDEST ) .and. lCommitCET
											lCommitCET := GeraM010CP( T0T->T0T_CTDEST, oModelPeri, @oModelCP, @cLogErros )

											lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_CTACP", oModelCP:GetValue( "MODEL_CFR", "CFR_CODCTA" ) )
											lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_DCTACP", oModelCP:GetValue( "MODEL_CFR", "CFR_DCODCT" ) )
											lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_IDCTAC", oModelCP:GetValue( "MODEL_CFR", "CFR_ID" ) )

											oModelCP:DeActivate()
										EndIf

										lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_HISTLC", T0T->T0T_HISTOR )
										lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_TRIDIF", T0T->T0T_INDDIF )
										lCommitCET := lCommitCET .and. oModelCET:SetValue( "CET_ORIGEM", "A" ) //A - AUTOMÁTICO

										If lCommitCET .and. T0U->( MsSeek( xFilial( "T0U" ) + T0T->( T0T_ID + T0T_IDCODT + T0T_CODLAN ) ) )
											oModelCEU := oModelBlcM:GetModel( "MODEL_CEU" )

											While T0U->( !Eof() ) .and. T0U->( T0U_FILIAL + T0U_ID + T0U_IDCODT + T0U_CODLAN ) == xFilial( "T0U" ) + T0T->( T0T_ID + T0T_IDCODT + T0T_CODLAN ) .and. lCommitCET
												If !oModelCEU:IsEmpty()
													oModelCEU:AddLine()
												EndIf

												If !oModelCEU:SeekLine( { { "CEU_IDPROC", T0U->T0U_IDPROC } } )
													lCommitCET := lCommitCET .and. oModelCEU:SetValue( "CEU_IDPROC", T0U->T0U_IDPROC )
												EndIf
												T0U->( DBSkip() )
											EndDo
										EndIf

										If !lCommitCET
											lSucesso := .F.
											AddLogErro( STR0162, @cLogErros, { oModelCFR:GetValue( "MODEL_CFR", "CFR_CODCTA" ), oModelCFR:GetValue( "MODEL_CFR", "CFR_DCODCT" ) } ) //"Não foi possível adicionar a Conta @1 - @2 no Registro M410. Verifique o cadastro do Bloco."
										EndIf

									EndIf

									( cAliasQry )->( DBSkip() )
								EndDo
								( cAliasQry )->( DbCloseArea() )
							endif
						EndIf
						oModelCFR:DeActivate()
					Next nI
				EndIf

				// Processos
				If !Empty( aProcessos ) .and. lSucesso
					oModelCHV := oModelBlcM:GetModel( "MODEL_CHV" )

					For nI := 1 to Len( aProcessos )
						If !Empty( aProcessos[nI,M315_ID_PROCESSO] ) .and. lSucesso
							If !oModelCHV:IsEmpty()
								oModelCHV:AddLine()
							EndIf

							lSucesso := lSucesso .and. oModelCHV:SetValue( "CHV_IDPROC", aProcessos[nI,M315_ID_PROCESSO] )
						EndIf
					Next nI
				EndIf

				If lSucesso
					//Grava no log o registro inserido
					cDescItem := Posicione( "CH8", 1, xFilial( "CH8" ) + aBlocoM[nIndicM300,M300_ID_TABELA_DINAMICA], "AllTrim( CH8_CODIGO ) + ' ' + AllTrim( CH8_DESCRI )" )
					AddLogErro( STR0148, @cLogAvisos, { Round( aBlocoM[nIndicM300,M300_VALOR], 2 ), cDescItem } ) //"Foi adicionado um item com o valor @1 código @2 no cadastro do Bloco M"
				Else
					AddLogErro( STR0149, @cLogErros, { Round( aBlocoM[nIndicM300,M300_VALOR], 2 ), cDescItem } ) //"Não foi possível adicionar o valor @1 código @2 no cadastro do Bloco M. Verifique o cadastro do Bloco."
				EndIf

				lSucesso := lSucesso .and. oModelCHR:SetValue( "CHR_TIPORL", GetRelM300( cTipoRel, cTipoRel ) )

				oModelCHR:lValid := .T.
			Else
				AddLogErro( STR0180, @cLogAvisos, { cValTochar(Round( aBlocoM[nIndicM300,M300_VALOR], 2 )), Posicione( "CH8", 1, xFilial("CH8") + aBlocoM[ nIndicM300, M300_ID_TABELA_DINAMICA ], "AllTrim( CH8_CODIGO ) + ' ' + AllTrim( CH8_DESCRI )" ) } ) 
			Endif
		Next nIndicM300
	Else
		AddLogErro( STR0164, @cLogErros ) //"Os valores do Bloco M já estão preenchidos. Para gerar novamente apague os dados do bloco M ou reabra o Período."
	EndIf
EndIf

If Empty( cLogErros )
	FWFormCommit( oModelBlcM )
ElseIf !Empty( oModelBlcM:GetErrorMessagem()[6] )
	AddLogErro( STR0165, @cLogErros, { oModelBlcM:GetErrorMessagem()[4], ENTER, oModelBlcM:GetErrorMessagem()[6], oModelBlcM:GetErrorMessagem()[7] } ) //"Campo: @1 @2Detalhes: @3, @2 @4"
EndIf

oModelBlcM:DeActivate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraM010CP

Gera informações da Identificação da Conta da Parte B
de Contrapartida a ser utilizado no Registro M410.

@Param		cConta		-	ID Conta da Parte B do Cadastro ( Apuração )
			oModelPeri	-	Modelo do Período de Apuração
			oModelCP	-	Modelo da Identificação da Conta da Parte B de Contrapartida( referência )
			cLogErros	-	Log de erros do processo ( referência )

@Return		lCommit		-	Indica se a operações foi efetuada

@Author		Felipe C. Seolin
@Since		13/05/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function GeraM010CP( cConta, oModelPeri, oModelCP, cLogErros )

Local aContaPB	as array
Local aAreaT0S	as array
Local aAreaLE9	as array
Local aAreaT0T	as array
Local lCommit	as logical
Local nContaPB  as numeric

aContaPB	:=	{}
aAreaT0S	:=	T0S->( GetArea() )
aAreaLE9	:=	LE9->( GetArea() )
aAreaT0T	:=	T0T->( GetArea() )
lCommit		:=	.F.
nContaPB	:= iif(TafColumnPos('T0S_IDCODP'),13,12)

T0T->( DBSetOrder( 1 ) )
If T0T->( MsSeek( xFilial( "T0T" ) + cConta ) )
	LE9->( DBSetOrder( 1 ) )
	If LE9->( MsSeek( xFilial( "LE9" ) + T0T->( T0T_ID + T0T_IDCODT ) ) )
		T0S->( DBSetOrder( 1 ) )
		If T0S->( MsSeek( xFilial( "T0S" ) + LE9->LE9_ID ) )

			aAdd( aContaPB, Array( nContaPB ) )
			aContaPB[Len( aContaPB )][M010_ID]					:=	AllTrim( T0S->T0S_ID )
			aContaPB[Len( aContaPB )][M010_ID_TRIBUTO]			:=	AllTrim( LE9->LE9_IDCODT )
			aContaPB[Len( aContaPB )][M010_CODIGO]				:=	AllTrim( T0S->T0S_CODIGO )
			aContaPB[Len( aContaPB )][M010_DESCRICAO]			:=	AllTrim( T0S->T0S_DESCRI )
			aContaPB[Len( aContaPB )][M010_TABELA_DINAMICA]		:=	AllTrim( Posicione( "CH8", 1, xFilial( "CH8" ) + LE9->LE9_IDCODL, "CH8_CODREG" ) )
			aContaPB[Len( aContaPB )][M010_ID_TABELA_DINAMICA]	:=	AllTrim( LE9->LE9_IDCODL )
			aContaPB[Len( aContaPB )][M010_DATA_CRIACAO]		:=	dtos(T0S->T0S_DTFINA)
			aContaPB[Len( aContaPB )][M010_CODIGO_TRIBUTO]		:=	AllTrim( Posicione( "C3S", 3, xFilial( "C3S" ) + Posicione( "T0J", 1, xFilial( "T0J" ) + LE9->LE9_IDCODT, "T0J_TPTRIB" ), "C3S_CODIGO" ) )
			aContaPB[Len( aContaPB )][M010_DATA_LIMITE]			:=	dtos(T0S->T0S_DTLIMI)
			aContaPB[Len( aContaPB )][M010_SALDO_INICIAL]		:=	LE9->LE9_VLSDIN
			aContaPB[Len( aContaPB )][M010_INDICADOR_SALDO]		:=	AllTrim( T0S->T0S_NATURE )
			aContaPB[Len( aContaPB )][M010_CNPJ]				:=	AllTrim( T0S->T0S_CNPJRE )
			if nContaPB > 12
				aContaPB[Len( aContaPB )][M010_ID_CONTA_REF_PB]		:=	AllTrim( T0S->T0S_IDCODP )
			endif	
		
			lCommit := GeraM010( aContaPB[Len( aContaPB )], oModelPeri, @oModelCP, @cLogErros )

		EndIf
	EndIf
EndIf
	
RestArea( aAreaT0S )
RestArea( aAreaLE9 )
RestArea( aAreaT0T )

Return( lCommit )

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraM010

Gera informações da Identificação da Conta da Parte B.

@Param		aContaPB	-	Informações da Conta da Parte B
			oModelPeri	-	Modelo do Período de Apuração
			oModelCFR	-	Modelo da Identificação da Conta da Parte B ( referência )
			cLogErros	-	Log de erros do processo ( referência )

@Return		lCommit		-	Indica se a operações foi efetuada

@Author		Felipe C. Seolin
@Since		31/03/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function GeraM010( aContaPB, oModelPeri, oModelCFR, cLogErros )

Local cTributo	as character
Local cTabDin	as character
Local cIndSaldo	as character
Local cAliasQry	as character
Local cSelect	as character
Local cFrom		as character
Local cWhere	as character
Local lCommit	as logical
Local cQryAux	as character
Local cTamPer 	as numeric

cTributo	:=	""
cTabDin		:=	ConvCodECF( aContaPB[M010_TABELA_DINAMICA] )
cIndSaldo	:=	""
cAliasQry	:=	""
cSelect		:=	""
cFrom		:=	""
cWhere		:=	""
lCommit		:=	.T.
cQryAux 	:= iif(Upper(AllTrim(TCGetDB())) == 'ORACLE','SUBSTR','SUBSTRING')
cTamPer		:= iif(T0J->T0J_PERAPU != '3', '4', '6')

If StrZero( Val( aContaPB[M010_CODIGO_TRIBUTO] ), 6 ) == TIPO_TRIBUTO_CSLL
	cTributo := CSLL
ElseIf StrZero( Val( aContaPB[M010_CODIGO_TRIBUTO] ), 6 ) == TIPO_TRIBUTO_IRPJ
	cTributo := IRPJ
Else
	cTributo := ""
EndIf

If aContaPB[M010_INDICADOR_SALDO] == NATUREZA_ADICAO
	cIndSaldo := AUMENTA_LUCRO_REAL
ElseIf aContaPB[M010_INDICADOR_SALDO] $ NATUREZA_EXCLUSAO + "|" + NATUREZA_COMP_PREJ_BASE_NEGATIVA + "|" + NATUREZA_DEDUCA_COMP_TRIBUTO
	cIndSaldo := REDUZ_LUCRO_REAL
Else
	cIndSaldo := IndParteB( aContaPB[M010_CODIGO] ) 
EndIf

cAliasQry := GetNextAlias()

cSelect	:= "CFR.R_E_C_N_O_ CFR_RECNO "
cFrom	+= RetSqlName( "CFR" ) + " CFR "
cWhere	:= "    CFR.CFR_FILIAL = '" + xFilial( "CFR" ) + "' "
cWhere	+= "AND CFR.CFR_CODCTA = '" + aContaPB[M010_CODIGO] + "' "
cWhere	+= "AND CFR.CFR_TRIBUT = '" + cTributo + "' "
cWhere 	+= "AND " + cQryAux + "( CFR.CFR_PERIOD, 1, " + cTamPer + " ) = '" + left(dtos(oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" )),val(cTamPer)) + "' "
cWhere	+= "AND CFR.D_E_L_E_T_ = '' "

cSelect	:= "%" + cSelect	+ "%"
cFrom		:= "%" + cFrom	+ "%"
cWhere		:= "%" + cWhere	+ "%"

BeginSql Alias cAliasQry
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
EndSql

If Empty( oModelCFR )
	oModelCFR := FWLoadModel( "TAFA330" )
EndIf

If ( cAliasQry )->( Eof() )
	oModelCFR:SetOperation( MODEL_OPERATION_INSERT )
	oModelCFR:Activate()

	lCommit := lCommit .and. oModelCFR:SetValue( "MODEL_CFR", "CFR_PERIOD", oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) )
	lCommit := lCommit .and. oModelCFR:SetValue( "MODEL_CFR", "CFR_CODCTA", aContaPB[M010_CODIGO] )
	lCommit := lCommit .and. oModelCFR:SetValue( "MODEL_CFR", "CFR_REGECF", cTabDin )
	lCommit := lCommit .and. oModelCFR:SetValue( "MODEL_CFR", "CFR_DCODCT", aContaPB[M010_DESCRICAO] )
	lCommit := lCommit .and. oModelCFR:SetValue( "MODEL_CFR", "CFR_DTLAL", SToD( aContaPB[M010_DATA_CRIACAO] ) )
	lCommit := lCommit .and. oModelCFR:SetValue( "MODEL_CFR", "CFR_IDCODL", aContaPB[M010_ID_TABELA_DINAMICA] )
	lCommit := lCommit .and. oModelCFR:SetValue( "MODEL_CFR", "CFR_TRIBUT", cTributo )
	lCommit := lCommit .and. oModelCFR:SetValue( "MODEL_CFR", "CFR_DTLIM", SToD( aContaPB[M010_DATA_LIMITE] ) )
	lCommit := lCommit .and. oModelCFR:SetValue( "MODEL_CFR", "CFR_VLSALD", TAF436Saldo( aContaPB[M010_ID], aContaPB[M010_ID_TRIBUTO], oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ), aContaPB[M010_INDICADOR_SALDO], aContaPB[M010_SALDO_INICIAL], cQryAux, cTamPer ) )
	lCommit := lCommit .and. oModelCFR:SetValue( "MODEL_CFR", "CFR_INDSAL", cIndSaldo )
	lCommit := lCommit .and. oModelCFR:SetValue( "MODEL_CFR", "CFR_CNPJ", aContaPB[M010_CNPJ] )
	lCommit := lCommit .and. oModelCFR:SetValue( "MODEL_CFR", "CFR_ORIGEM", "A" )
	if TafColumnPos( 'T0S_IDCODP' ) // Esse é o campo que alimenta o array aContaPB na posição M010_ID_CONTA_REF_PB
		lCommit := lCommit .and. oModelCFR:SetValue( "MODEL_CFR", "CFR_IDCODP", aContaPB[M010_ID_CONTA_REF_PB] )
	endif	

	If lCommit .and. oModelCFR:VldData()
		FWFormCommit( oModelCFR )
	Else
		AddLogErro( STR0165, @cLogErros, { oModelCFR:GetErrorMessagem()[4], ENTER, oModelCFR:GetErrorMessagem()[6], oModelCFR:GetErrorMessagem()[7] } ) //"Campo: @1 @2Detalhes: @3, @2 @4"
	EndIf
Else
	CFR->( DBGoTo( ( cAliasQry )->( CFR_RECNO ) ) )

	oModelCFR:SetOperation( MODEL_OPERATION_VIEW )
	oModelCFR:Activate()
EndIf

( cAliasQry )->( DBCloseArea() )

Return( lCommit )

//---------------------------------------------------------------------
/*/{Protheus.doc} ConvCodECF

Converte o código do Plano de Contas Referencial do Layout para
o código do Plano de Contas Referencial no sistema.

@Param		cPlano	-	Código do Plano de Contas Referencial do Layout

@Return		cRet	-	Código do Plano de Contas Referencial no sistema

@Author		Felipe C. Seolin
@Since		10/05/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ConvCodECF( cPlano )

Local cRet	as character

cRet	:=	""

If cPlano == "M300A"
	cRet := M300A
ElseIf cPlano == "M300B"
	cRet := M300B
ElseIf cPlano == "M300C"
	cRet := M300C
ElseIf cPlano == "M350A"
	cRet := M350A
ElseIf cPlano == "M350B"
	cRet := M350B
ElseIf cPlano == "M350C"
	cRet := M350C
EndIf

Return( cRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetLancPB

Consulta lançamentos da conta dentro do período apurado.

@Param		aContaPB	-	Informações da Conta da Parte B
			oModelPeri	-	Modelo do Período de Apuração

@Return		cAliasQry	-	Consulta aplicada

@Author		Felipe C. Seolin
@Since		10/05/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function GetLancPB( aContaPB, oModelPeri )

Local cAliasQry	as character
Local cSelect	as character
Local cFrom		as character
Local cWhere	as character
Local cPerIni   as character
Local cIdEvento as character
Local cIdForTri as character
Local lEstbalan as logical

cAliasQry	:=	GetNextAlias()
cSelect		:=	""
cFrom		:=	""
cWhere		:=	""
cIdEvento	:= oModelPeri:GetValue( "MODEL_CWV", "CWV_IDEVEN" )
cIdForTri	:= GetAdvFVal('T0N','T0N_IDFTRI', xFilial( 'T0N' ) + cIdEvento , 1 )
lEstbalan	:= GetAdvFVal('T0K','T0K_CODIGO', xFilial( 'T0K' ) + cIdForTri , 1 ) == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO
cPerIni		:= iif( lEstbalan, FirstYDate(oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" )) , oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) )

cSelect := " DISTINCT T0T.R_E_C_N_O_ T0T_RECNO "

cFrom := RetSqlName( "T0T" ) + " T0T "

//Natureza da conta for 5-adicao/exclusao
if aContaPB[M010_INDICADOR_SALDO] == '5'
	cFrom += " INNER JOIN " + RetSqlName('T0O') + " T0O ON T0O.T0O_FILIAL = '" + xFilial('T0O') + "' AND T0O.T0O_IDPARB = T0T.T0T_ID AND T0O.T0O_TIPOCC = T0T.T0T_TPLANC AND T0O.D_E_L_E_T_ = ' ' "
endif	

cWhere := "    T0T.T0T_FILIAL = '" + xFilial( "T0T" ) + "' "
cWhere += "AND T0T.T0T_ID = '" + aContaPB[M010_ID] + "' "
cWhere += "AND T0T.T0T_IDCODT = '" + aContaPB[M010_ID_TRIBUTO] + "' "
cWhere += "AND T0T.T0T_DTLANC BETWEEN '" + dtos( cPerIni ) + "' AND '" + DToS( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) + "' "
cWhere += "AND T0T.T0T_ORIGEM = '2' "
cWhere += "AND T0T.D_E_L_E_T_ = ' ' "

cSelect  := "%" + cSelect  + "%"
cFrom    := "%" + cFrom    + "%"
cWhere   := "%" + cWhere   + "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%

EndSql

Return( cAliasQry )

/*/{Protheus.doc} LoadBlocoM
Carrega o Model do Bloco M
@author david.costa
@since 22/02/2017
@version 1.0
@param oModelBlcM, objeto,Objeto que receberá o Model
@param oModelPeri, objeto, Model do Período de Apuração
@param lReabertur, lógico, Indica se o model esta sendo carregado para a reabertura
@return ${lRet}, ${lRet}
@example
LoadBlocoM( @oModelBlcM, oModelPeri, lReabertur )
/*/Static Function LoadBlocoM( oModelBlcM, oModelPeri, lReabertur )

Local dIniPer	as date
Local lRet		as logical
Local cIdPer	as character

Default lReabertur	:=	.F.

dIniPer	:=	Nil
lRet	:=	.F.

If Month( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ) == Month( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) )
	dIniPer := SToD( AllTrim( Str( Year( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ) ) ) + "0101" )
Else
	dIniPer := oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" )
EndIf

cIdPer := IdPerTri( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ), oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ), oModelPeri:GetValue( "MODEL_CWV", "CWV_ANUAL" ) )
DBSelectArea( "CEN" )
CEN->( DBSetOrder( 2 ) )
If CEN->( MsSeek( xFilial( "CEN" ) + DToS( dIniPer ) + DToS( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) + cIdPer ) )
	oModelBlcM := FWLoadModel( "TAFA322" )
	oModelBlcM:SetOperation( MODEL_OPERATION_UPDATE )
	oModelBlcM:Activate()
	lRet := .T.
ElseIf !lReabertur
	oModelBlcM := FWLoadModel( "TAFA322" )
	oModelBlcM:SetOperation( MODEL_OPERATION_INSERT )
	oModelBlcM:Activate()
	oModelBlcM:LoadValue( "MODEL_CEN", "CEN_DTINI", dIniPer )
	oModelBlcM:LoadValue( "MODEL_CEN", "CEN_DTFIN", oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) )
	oModelBlcM:LoadValue( "MODEL_CEN", "CEN_IDPERA",  cIdPer)
	lRet := .T.
EndIf

Return( lRet )

/*/{Protheus.doc} VlModelCEO
Valida se o Cadastro do BlocoM está em branco e pode receber os dados da apuração
@author david.costa
@since 22/02/2017
@version 1.0
@param oModelCEO, objeto, Model CEO que será validado
@param cLogErros, character, Log de Erros do processo
@param oModelPeri, objeto, Model do período
@return ${Nil}, ${Nulo}
@example
VlModelCEM( oModelCEO, cLogErros, aBlocoM, oModelPeri )
/*/Static Function VlModelCEO( oModelCEO, cLogErros, oModelPeri )

Local nIndiceCEO	as numeric

nIndiceCEO	:=	0

//Valida se o Cadastro está em branco
For nIndiceCEO := 1 to oModelCEO:Length()
	oModelCEO:GoLine( nIndiceCEO )
	If oModelCEO:Length() > 0 .and. !oModelCEO:IsEmpty() .and. !oModelCEO:IsDeleted()
		//'Existem itens com valor no cadastro do Bloco M para o período de @1 até @2. Para executar este processo é necessário que o cadastro esteja com os valores zerados na "pasta Lançamentos da Parte A do e-LALUR"'
		AddLogErro( STR0139, @cLogErros, { DToC( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ), DToC( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) } )
		Exit
	EndIf
Next

Return()

/*/{Protheus.doc} VlModelCHR
Valida se o Cadastro do BlocoM está em branco e pode receber os dados da apuração
@author david.costa
@since 22/02/2017
@version 1.0
@param oModelCHR, objeto, Model CHR que será validado
@param cLogErros, character, Log de Erros do processo
@param oModelPeri, objeto, Model do período
@return ${Nil}, ${Nulo}
@example
VlModelCHR( oModelCHR, cLogErros, aBlocoM, oModelPeri )
/*/Static Function VlModelCHR( oModelCHR, cLogErros, oModelPeri )

Local nIndiceCHR	as numeric

nIndiceCHR	:=	0

//Valida se o Cadastro está em branco
For nIndiceCHR := 1 to oModelCHR:Length()
	oModelCHR:GoLine( nIndiceCHR )
	If oModelCHR:Length() > 0 .and. !oModelCHR:IsEmpty() .and. !oModelCHR:IsDeleted()
		//'Existem itens com valor no cadastro do Bloco M para o período de @1 até @2. Para executar este processo é necessário que o cadastro esteja com os valores zerados na pasta "Lançamentos da Parte A do e-LACS"'
		AddLogErro( STR0140, @cLogErros, { DToC( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ), DToC( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) } )
		Exit
	EndIf
Next nIndiceCHR

Return()

/*/{Protheus.doc} RemoveBlcP
Remove a integração feita com os cadastros da ECF
@author david.costa
@since 27/02/2017
@version 1.0
@param oModelPeri, objeto, Model do cadastro do período
@param cSuccess, caracter, Log de avisos do processo
@return ${Nil}, ${Nulo}
@example
RemoveBlcP( oModelPeri, cSuccess )
/*/Static Function RemoveBlcP( oModelPeri, cSuccess )

Local oModelBlcP	as object
Local oModelCEI		as object
Local oBlcEcf		as codeblock

oModelBlcP	:=	Nil
oModelCEI	:=	Nil
oBlcEcf		:=	{ || Posicione( "CH6", 1, xFilial( "CH6" ) + oModel:GetValue( "CEI_IDCODC" ), "AllTrim( CH6_CODIGO ) + ' ' + AllTrim( CH6_DESCRI )" ) }

LoadBlocoP( @oModelBlcP, oModelPeri, .T. )

cSuccess += STR0155 //"*****Cadastro do Bloco P*****"
cSuccess += ENTER

If GetTpTribu( oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ) ) == TIPO_TRIBUTO_IRPJ
	//Valida o Model "Apuração da Base de Cálculo do Lucro Presumido"
	oModelCEI := oModelBlcP:GetModel( "MODEL_CEIb" )
	DelIteBloc( "CEI", oModelCEI, @cSuccess, oBlcEcf )
	//Valida o Model "Cálculo do IRPJ com Base no Lucro Presumido"
	oModelCEI := oModelBlcP:GetModel( "MODEL_CEId" )
	DelIteBloc( "CEI", oModelCEI, @cSuccess, oBlcEcf )
Else	//CSLL
	//Valida o Model "Apuração da Base de Cálculo da CSLL com Base no Lucro Presumido"
	oModelCEI := oModelBlcP:GetModel( "MODEL_CEIe" )
	DelIteBloc( "CEI", oModelCEI, @cSuccess, oBlcEcf )
	//Valida o Model "Cálculo da CSLL com Base no Lucro Presumido."
	oModelCEI := oModelBlcP:GetModel( "MODEL_CEIf" )
	DelIteBloc( "CEI", oModelCEI, @cSuccess, oBlcEcf )
EndIf

FWFormCommit( oModelBlcP )

Return()

/*/{Protheus.doc} RemoveBlcM
Remove a integração feita com os cadastros da ECF
@author david.costa
@since 27/02/2017
@version 1.0
@param oModelPeri, objeto, Model do cadastro do período
@param cSuccess, caracter, Log de sucessos do processo
@param cWarning, caracter, Log de avisos do processo
@return ${Nil}, ${Nulo}
@example
RemoveBlcM( oModelPeri, cSuccess, cWarning )
/*/Static Function RemoveBlcM( oModelPeri, cSuccess, cWarning )

Local oModelBlcM	as object
Local oModelCEO		as object
Local oModelCHR		as object
Local oModelCET		as object
Local oBlcEcf		as codeblock
Local aContaPB		as array

oModelBlcM	:=	Nil
oModelCEO	:=	Nil
oModelCHR	:=	Nil
oModelCET	:=	Nil
oBlcEcf		:=	Nil
aContaPB	:=	{}

If LoadBlocoM( @oModelBlcM, oModelPeri, .T. )
	oModelCEO := oModelBlcM:GetModel( "MODEL_CEO" )
	oModelCHR := oModelBlcM:GetModel( "MODEL_CHR" )

	//IRPJ - M300
	If GetTpTribu( oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ) ) == TIPO_TRIBUTO_IRPJ .and. oModelCEO:Length() > 0 .and. !oModelCEO:IsEmpty()
		cSuccess += STR0154 //"*****Cadastro do Bloco M*****"
		cSuccess += ENTER

		oBlcEcf		:= { || Posicione( "CH8", 1, xFilial("CH8") + oModel:GetValue( "CEO_IDCODL" ), "AllTrim( CH8_CODIGO ) + ' ' + AllTrim( CH8_DESCRI )" ) }
		DelIteBloc( "CEO", @oModelCEO, @cSuccess, oBlcEcf, @aContaPB )

	//CSLL - M350
	ElseIf oModelCHR:Length() > 0 .and. !oModelCHR:IsEmpty()
		cSuccess += STR0154 //"*****Cadastro do Bloco M*****"
		cSuccess += ENTER
	
		oBlcEcf		:= { || Posicione( "CH8", 1, xFilial("CH8") + oModel:GetValue( "CHR_IDCODL" ), "AllTrim( CH8_CODIGO ) + ' ' + AllTrim( CH8_DESCRI )" ) }
		DelIteBloc( "CHR", @oModelCHR, @cSuccess, oBlcEcf, @aContaPB )
	EndIf

	//IRPJ - CSLL - M410
	oModelCET := oModelBlcM:GetModel( "MODEL_CET" )
	oBlcEcf := { || AllTrim( oModel:GetValue( "CET_CTA" ) ) + " - " + AllTrim( oModel:GetValue( "CET_DCTA" ) ) }
	DelIteBloc( "CET", oModelCET, @cSuccess, oBlcEcf, @aContaPB )

	FWFormCommit( oModelBlcM )

	DelContaPB( aContaPB, @cSuccess, @cWarning )
EndIf

Return()

/*/{Protheus.doc} RemoveBlcN
Remove a integração feita com os cadastros da ECF
@author david.costa
@since 27/02/2017
@version 1.0
@param oModelPeri, objeto, Model do cadastro do período
@param cSuccess, caracter, Log de avisos do processo
@return ${Nil}, ${Nulo}
@example
RemoveBlcN( oModelPeri, cSuccess )
/*/Static Function RemoveBlcN( oModelPeri, cSuccess )

Local oModelBlcN	as object
Local oModelCEB		as object
Local oBlcEcf		as codeblock

oModelBlcN	:=	Nil
oModelCEB	:=	Nil
oBlcEcf		:=	{ || Posicione( "CH6", 1, xFilial( "CH6" ) + oModel:GetValue( "CEB_IDCODL" ), "AllTrim( CH6_CODIGO ) + ' ' + AllTrim( CH6_DESCRI )" ) }

If LoadBlocoN( @oModelBlcN, oModelPeri, .T. )

	cSuccess += STR0153 //"*****Cadastro do Bloco N*****"
	cSuccess += ENTER
	
	If GetTpTribu( oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ) ) == TIPO_TRIBUTO_IRPJ
		//Valida o Model "Base Cáalc. IPRJ sobre lucro real após compensações prejuízo"
		oModelCEB := oModelBlcN:GetModel( "MODEL_CEB_01" )
		DelIteBloc( "CEB", oModelCEB, @cSuccess, oBlcEcf )
		//Valida o Model "Demonstração do Lucro da Exploração"
		oModelCEB := oModelBlcN:GetModel( "MODEL_CEB_02" )
		DelIteBloc( "CEB", oModelCEB, @cSuccess, oBlcEcf )
		//Valida o Model "Cálculo do IRPJ mensal por estimativa"
		oModelCEB := oModelBlcN:GetModel( "MODEL_CEB_04" )
		DelIteBloc( "CEB", oModelCEB, @cSuccess, oBlcEcf )
		//Valida o Model "Cálculo do IRPJ com Base no Lucro Real"
		oModelCEB := oModelBlcN:GetModel( "MODEL_CEB_05" )
		DelIteBloc( "CEB", oModelCEB, @cSuccess, oBlcEcf )
	Else	//CSLL
		//Valida o Model "Base CSLL após Compens. Base Negativa"
		oModelCEB := oModelBlcN:GetModel( "MODEL_CEB_06" )
		DelIteBloc( "CEB", oModelCEB, @cSuccess, oBlcEcf )
		//Valida o Model "Cálculo da CSLL mensal por estimativa"
		oModelCEB := oModelBlcN:GetModel( "MODEL_CEB_07" )
		DelIteBloc( "CEB", oModelCEB, @cSuccess, oBlcEcf )
		//Valida o Model "Cálculo da CSLL com base Lucro Real"
		oModelCEB := oModelBlcN:GetModel( "MODEL_CEB_08" )
		DelIteBloc( "CEB", oModelCEB, @cSuccess, oBlcEcf )
	EndIf
	
	FWFormCommit( oModelBlcN )
	oModelBlcN:Destroy()
EndIf

Return()

/*/{Protheus.doc} RemoveBlcU
Remove a integração feita com os cadastros da ECF
@author david.costa
@since 27/02/2017
@version 1.0
@param oModelPeri, objeto, Model do cadastro do período
@param cSuccess, caracter, Log de avisos do processo
@return ${Nil}, ${Nulo}
@example
RemoveBlcU( oModelPeri, cSuccess )
/*/Static Function RemoveBlcU( oModelPeri, cSuccess )

Local oModelBlcU	as object
Local oModelCFI		as object
Local oBlcEcf		as codeblock

oModelBlcU	:=	Nil
oModelCFI	:=	Nil
oBlcEcf		:=	{ || Posicione( "CH6", 1, xFilial( "CH6" ) + oModel:GetValue( "CFI_IDCODC" ), "AllTrim( CH6_CODIGO ) + ' ' + AllTrim( CH6_DESCRI )" ) }

If LoadBlocoU( @oModelBlcU, oModelPeri, .T. )

	If GetTpTribu( oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ) ) == TIPO_TRIBUTO_IRPJ .and.;
		oModelBlcU:GetModel( "MODEL_CFIa" ):Length() > 0
		cSuccess += STR0152 //"*****Cadastro do Bloco U*****"
		cSuccess += ENTER

		//Valida o Model "Cálculo do IRPJ das Empresas Imunes e Isentas"
		oModelCFI := oModelBlcU:GetModel( "MODEL_CFIa" )
		DelIteBloc( "CFI", oModelCFI, @cSuccess, oBlcEcf )
	//CSLL
	ElseIf oModelBlcU:GetModel( "MODEL_CFIb" ):Length() > 0
		cSuccess += STR0152 //"*****Cadastro do Bloco U*****"
		cSuccess += ENTER
	
		//Valida o Model "Cálculo da CSLL das Empresas Imunes e Isentas"
		oModelCFI := oModelBlcU:GetModel( "MODEL_CFIb" )
		DelIteBloc( "CFI", oModelCFI, @cSuccess, oBlcEcf )
	EndIf

	FWFormCommit( oModelBlcU )
EndIf

Return()

/*/{Protheus.doc} RemoveBlcT
Remove a integração feita com os cadastros da ECF
@author david.costa
@since 27/02/2017
@version 1.0
@param oModelPeri, objeto, Model do cadastro do período
@param cSuccess, caracter, Log de avisos do processo
@return ${Nil}, ${Nulo}
@example
RemoveBlcT( oModelPeri, cSuccess )
/*/Static Function RemoveBlcT( oModelPeri, cSuccess )

Local oModelBlcT	as object
Local oModelCEK		as object
Local oBlcEcf		as codeblock

oModelBlcT	:=	Nil
oModelCEK	:=	Nil
oBlcEcf		:=	{ || Posicione( "CH6", 1, xFilial( "CH6" ) + oModel:GetValue( "CEK_IDCODC" ), "AllTrim( CH6_CODIGO ) + ' ' + AllTrim( CH6_DESCRI )" ) }

If LoadBlocoT( @oModelBlcT, oModelPeri, .T. )

	If GetTpTribu( oModelPeri:GetValue( "MODEL_CWV", "CWV_IDTRIB" ) ) == TIPO_TRIBUTO_IRPJ .and.;
		( oModelBlcT:GetModel( "MODEL_CEKa" ):Length() > 0 .or. oModelBlcT:GetModel( "MODEL_CEKb" ):Length() > 0 )
		cSuccess += STR0151 //"*****Cadastro do Bloco T*****"
		cSuccess += ENTER

		//Valida o Model "Apuração da Base de Cálculo do IRPJ com Base no Lucro Arbitrado"
		oModelCEK := oModelBlcT:GetModel( "MODEL_CEKa" )
		DelIteBloc( "CEK", oModelCEK, @cSuccess, oBlcEcf )
		//Valida o Model "Cálculo do IRPJ com Base no Lucro Arbitrado"
		oModelCEK := oModelBlcT:GetModel( "MODEL_CEKb" )
		DelIteBloc( "CEK", oModelCEK, @cSuccess, oBlcEcf )
	//CSLL
	ElseIf oModelBlcT:GetModel( "MODEL_CEKc" ):Length() > 0 .or. oModelBlcT:GetModel( "MODEL_CEKd" ):Length() > 0 
		cSuccess += STR0151 //"*****Cadastro do Bloco T*****"
		cSuccess += ENTER
		//Valida o Model "Apuração da Base de Cálculo da CSLL com Base no Lucro Arbitrado"
		oModelCEK := oModelBlcT:GetModel( "MODEL_CEKc" )
		DelIteBloc( "CEK", oModelCEK, @cSuccess, oBlcEcf )
		//Valida o Model "Cálculo da CSLL com Base no Lucro Arbitrado"
		oModelCEK := oModelBlcT:GetModel( "MODEL_CEKd" )
		DelIteBloc( "CEK", oModelCEK, @cSuccess, oBlcEcf )
	EndIf

	FWFormCommit( oModelBlcT )
EndIf

Return()

/*/{Protheus.doc} DelIteBloc
Apaga os itens automaticos do bloco
@author david.costa
@since 27/02/2017
@version 1.0
@param cAlias, caracter, Alias do model
@param oModel, objeto, Model do cadastro do Bloco
@param cSuccess, caracter, Log de sucessos do processo
@param oBlcEcf, objeto, Bloco de código para o log da ECF
@param aContaPB, array, Array com as Contas da Parte B do Bloco M ( referência )
@return ${Nil}, ${Nulo}
@example
DelIteBloc( "CHR", oModelCHR, cSuccess, oBlcEcf, aContaPB )
/*/Static Function DelIteBloc( cAlias, oModel, cSuccess, oBlcEcf, aContaPB )

Local cField	as character
Local nIndice	as numeric

cField	:=	Iif( cAlias $ "CEO|CHR|CET", "_VLRLC", "_VALOR" )
nIndice	:=	0

For nIndice := 1 to oModel:Length()
	oModel:GoLine( nIndice )
	If oModel:GetValue( cAlias + "_ORIGEM" ) == "A" // AUTOMÁTICO
		If cAlias <> "CET" .or. ( cAlias == "CET" .and. GetTpTribu( CWV->CWV_IDTRIB ) == Iif( oModel:GetValue( "CET_CODTRI" ) == IRPJ, TIPO_TRIBUTO_IRPJ, TIPO_TRIBUTO_CSLL ) )
			If cAlias $ "CEO|CHR|CET"
				AddBlcM010( cAlias, oModel, @aContaPB )
			EndIf

			oModel:DeleteLine()
			cSuccess += FormatStr( "- " + STR0150, { Eval( oBlcEcf ), Val2Str( oModel:GetValue( cAlias + cField ), 16, 2 ) } ) //"Foi removido o item @1 com o valor @2."
			cSuccess += ENTER
		EndIf
	EndIf
Next nIndice

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} AddBlcM010

Executa pré-condições para a operação desejada.

@Param		cAlias		-	Alias do Modelo
			oModel		-	Modelo do cadastro do Bloco
			aContaPB	-	Array com as Contas da Parte B do Bloco M

@Author		Felipe C. Seolin
@Since		08/06/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function AddBlcM010( cAlias, oModel, aContaPB )

Local oGrid		as object
Local cTabela	as character
Local nI		as numeric
Local cTributo	as character

oGrid	:=	Nil
cTabela	:=	""
nI		:=	0
cTributo:= ''

If cAlias $ "CEO"
	cTabela := "CEP"
ElseIf cAlias $ "CHR"
	cTabela := "CHS"
ElseIf cAlias $ "CET"
	cTabela := "CET"
EndIf

if cAlias != 'CET'
	oGrid := oModel:GetModel( "MODEL_" + cTabela ):GetModel( "MODEL_" + cTabela )
	For nI := 1 to oGrid:Length()
		oGrid:GoLine( nI )
		If !oGrid:IsDeleted() .and. !Empty( oGrid:GetValue( cTabela + "_IDCTA" ) ) .and. aScan( aContaPB, { |x| AllTrim( x ) == AllTrim( oGrid:GetValue( cTabela + "_IDCTA" ) ) } ) <= 0
			aAdd( aContaPB, oGrid:GetValue( cTabela + "_IDCTA" ) )
		EndIf
	Next nI
else
	If !oModel:IsDeleted() .and. !Empty( oModel:GetValue( cTabela + "_IDCTA" ) ) 
		//Conta Parte B
		if aScan( aContaPB, { |x| AllTrim( x ) == AllTrim( oModel:GetValue( cTabela + "_IDCTA" ) ) } ) = 0
			aAdd( aContaPB, oModel:GetValue( cTabela + "_IDCTA" ) )
		endif
		//Conta Contra
		if !empty( oModel:GetValue( cTabela + "_IDCTAC" ) ) .and. aScan( aContaPB, { |x| AllTrim( x ) == AllTrim( oModel:GetValue( cTabela + "_IDCTAC" ) ) } ) = 0
			aAdd( aContaPB, oModel:GetValue( cTabela + "_IDCTAC" ) )
		endif	
	EndIf	
endif		

Return()

/*/{Protheus.doc} AgrupaBlcM
Agrupa os itens da apuração quem tenhama o mesmo codigo da ECF
@author david.costa
@since 30/05/2017
@version 1.0
@param aBlocoM, array, Array com os dados do bloco M
@param cLogErros, caracter, Log para guardar os erros do processo
@param cLogAvisos, caracter, Log para guardar os avisos do processo
@param oModelPeri, object, Modelo do período de apuração
@return ${Nil}, ${Nulo}
@example
AgrupaBlcM( aBlocoM, cLogErros, cLogAvisos, oModelPeri )
/*/Static Function AgrupaBlcM( aBlocoM, cLogErros, cLogAvisos, oModelPeri )

Local cIdContCtb   as character
Local cIdCCusto    as character
Local nIndice      as numeric
Local nIndiceBlc   as numeric
Local nValor       as numeric
Local aBlcMAux     as array
Local cPerIni      as character
Local nLenBlc      as numeric
Local cSepara      as character
Local lSomaM305    as logical
Private lGeraCCust as logical

cIdContCtb := ""
cIdCCusto  := ""
nIndice    := 0
nIndiceBlc := 0
nValor     := 0
aBlcMAux   := {}
nLenBlc    := 0
cSepara    := ''
lSomaM305  := .t.
lGeraCCust := .F.

//Agrupa o M300/M350
For nIndice := 1 to Len( aBlocoM )
	nIndiceBlc := aScan( aBlcMAux, { |x| x[ M300_ID_TABELA_DINAMICA ] == aBlocoM[ nIndice, M300_ID_TABELA_DINAMICA ] } )
	If nIndiceBlc > 0
		lSomaM305 := .t.
		//Não somar quando o registro foi gerado no M305, nos códigos M16 E M101
		If !Empty( aBlocoM[ nIndice, M300_M305 ] )
			if len(aBlocoM[ nIndice][M300_M305][1]) > 14
				if aBlocoM[ nIndice][M300_M305][1][M010_GERA_M305]
					lSomaM305 := .f.	
				Endif	
			else
				lSomaM305 := .t.
			endif
		
		Endif

		if lSomaM305
			aBlcMAux[ nIndiceBlc, M300_VALOR ] += aBlocoM[ nIndice, M300_VALOR ]
		Endif
		
		aBlcMAux[ nIndiceBlc, M300_FOLDER ] := aBlocoM[ nIndice, M300_FOLDER ]
		If !Empty( aBlocoM[ nIndice, M300_M305 ] )
			//No array aBlocoM tem sempre um unico id de conta parte B, só havera mais de um após o agrupamento.
			if aScan( aBlcMAux[ nIndiceBlc, M300_M305 ] , { |x| x[1] == aBlocoM[ nIndice, M300_M305, 1, M010_ID ] } ) == 0
				aAdd( aBlcMAux[ nIndiceBlc, M300_M305 ], aBlocoM[ nIndice, M300_M305, 1 ] )
			endif

			nLenBlc := len(aBlcMAux[ nIndiceBlc ][ M300_M305 ])
			if nLenBlc > 0
				//Se ja existir valor, soma o novo valor no m305
				if ValType(aBlcMAux[ nIndiceBlc, M300_M305, nLenBlc, M010_VLR_CONTA_PB_POR_COD_LALUR]) == "N"
					aBlcMAux[ nIndiceBlc, M300_M305, nLenBlc, M010_VLR_CONTA_PB_POR_COD_LALUR] += aBlocoM[ nIndice, M300_VALOR ]
				else
					aBlcMAux[ nIndiceBlc, M300_M305, nLenBlc, M010_VLR_CONTA_PB_POR_COD_LALUR] := aBlocoM[ nIndice, M300_VALOR ]
				Endif
				
			endif	

		EndIf
		AgrpCCont( @aBlcMAux[ nIndiceBlc, M300_M310 ], aBlocoM[ nIndice, M300_M310 ] )
		AgrpProces( @aBlcMAux[ nIndiceBlc, M300_M315 ], aBlocoM[ nIndice, M300_M315 ] )
		
		if !empty(aBlocoM[ nIndice, M300_HISTORICO]) .and. !( alltrim(aBlocoM[ nIndice, M300_HISTORICO ]) $ alltrim(aBlcMAux[ nIndiceBlc, M300_HISTORICO ]) )
			cSepara := iif( !empty(aBlcMAux[ nIndiceBlc, M300_HISTORICO ]), ' - ', '' )
			aBlcMAux[ nIndiceBlc, M300_HISTORICO ] += cSepara + aBlocoM[ nIndice, M300_HISTORICO ]
		endif	
		
		aBlcMAux[ nIndiceBlc, M300_POSSUI_LANC_MANUAL ] := aBlcMAux[ nIndiceBlc, M300_POSSUI_LANC_MANUAL ] .OR. aBlocoM[ nIndice, M300_POSSUI_LANC_MANUAL ]
	Else
		aAdd( aBlcMAux, { aBlocoM[ nIndice, M300_ID_TABELA_DINAMICA ],;
						  aBlocoM[ nIndice, M300_VALOR 				],;
						  aBlocoM[ nIndice, M300_FOLDER 			],;
						  aBlocoM[ nIndice, M300_M310 				],; 
						  aBlocoM[ nIndice, M300_M305 				],; 
						  aBlocoM[ nIndice, M300_M315 				],;
						  aBlocoM[ nIndice, M300_SEQUENCIAL_EVENTO 	],;
						  aBlocoM[ nIndice, M300_ID_GRUPO_EVENTO 	],; 
						  aBlocoM[ nIndice, M300_HISTORICO 			],;
						  aBlocoM[ nIndice, M300_POSSUI_LANC_MANUAL ]})

		nLenBlc := len(aBlcMAux)
		if len(aBlcMAux[ nLenBlc ][ M300_M305 ]) > 0
			aBlcMAux[ nLenBlc ][ M300_M305 ][ 1 ][ M010_VLR_CONTA_PB_POR_COD_LALUR ] := aBlocoM[ nIndice, M300_VALOR ]
		endif	
	EndIf
	
Next nIndice

aBlocoM := aBlcMAux
aBlcMAux := {}

//Verifico se houve prejuizo no periodo após o bloco ser agrupado
for nIndice := 1 to len(aBlocoM)
	if aBlocoM[nIndice][M300_VALOR] < 0
		aBlocoM[nIndice][M300_M305] := GetContPB(oModelPeri:GetModel( "MODEL_CWX" ),,.t.)
	endif
next

DbSelectArea( "CAC" )
CAC->( DbSetOrder(2) )

DbSelectArea( "CAD" )
CAD->( DbSetOrder(1) )

DbSelectArea( "CAF" )
CAF->( DbSetOrder(1) )
//Agrupa M310/M360

//Se periodo de apuracao for apuração trimestral
cPerIni := iif( T0J->T0J_PERAPU == '3', DToS( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ) , DToS( FirstYDate (oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ) ) )

For nIndice := 1 to Len( aBlocoM )
	aBlcMAux := {}
	For nIndiceBlc := 1 to Len( aBlocoM[ nIndice, M300_M310 ] )
		//Carregar Bloco K
		If CAC->( MsSeek( xFilial( "CAC" ) + cPerIni + DToS( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) ) )
			cIdContCtb := aBlocoM[ nIndice, M300_M310, nIndiceBlc, M310_ID_CONTA_CONTABIL ]
			cIdCCusto := aBlocoM[ nIndice, M300_M310, nIndiceBlc, M310_ID_CENTRO_CUSTO ]
			If CAD->( MsSeek( xFilial( "CAD" ) + CAC->CAC_ID + cIdContCtb ) )
				lGeraCCust := .F.
				//Contas de patrimonio
				While !CAD->( Eof() ) .and. CAD->CAD_CTA == cIdContCtb .and. CAD->CAD_ID == CAC->CAC_ID
					If ComparaKxM( CAD->CAD_CODCUS, @aBlocoM[ nIndice, M300_M310, nIndiceBlc ], cIdCCusto, @aBlcMAux, CAD->CAD_VLRDEB,;
								 CAD->CAD_VLRCRD, CAD->CAD_VLRSLI, CAD->CAD_VLRSLF, cIdContCtb )
						CAD->( DbSkip() )
					Else
						exit
					EndIf
				EndDo
			ElseIf CAF->( MsSeek( xFilial( "CAF" ) + CAC->CAC_ID + cIdContCtb ) )
				lGeraCCust := .F.
				//Contas de resultado
				While !CAF->( Eof() ) .and. CAF->CAF_CTA == cIdContCtb .and. CAF->CAF_ID == CAC->CAC_ID
					If ComparaKxM( CAF->CAF_CODCUS, @aBlocoM[ nIndice, M300_M310, nIndiceBlc ], cIdCCusto, @aBlcMAux, 0, 0, 0, CAF->CAF_VLRSLF, cIdContCtb )
						CAF->( DbSkip() )
					Else
						exit
					EndIf
				EndDo
			Else
				AddLogErro( STR0161, @cLogErros, { Posicione( "C1O", 3, xFunCh2ID( T0O->T0O_FILITE, "C1E", 1 ) + cIdContCtb, "C1O->C1O_CODIGO" ), ENTER } ) //"Não foi possível encontrar os saldos contábeis no cadastro do Bloco K da conta @1 @2Por isso os registro filhos do M300 não foram gerados."
			EndIf
		Else
			AddLogErro( STR0161, @cLogErros, { Posicione( "C1O", 3, xFunCh2ID( T0O->T0O_FILITE, "C1E", 1 ) + T0O->T0O_IDCC, "C1O->C1O_CODIGO" ), ENTER } ) //"Não foi possível encontrar os saldos contábeis no cadastro do Bloco K da conta @1 @2Por isso os registro filhos do M300 não foram gerados."
		EndIf
	Next nIndiceBlc
	aBlocoM[ nIndice, M300_M310 ] := aBlcMAux
Next nIndice

//Gerar M312/M362
For nIndice := 1 to Len( aBlocoM )
	For nIndiceBlc := 1 to Len( aBlocoM[ nIndice, M300_M310 ] )
		If CAC->( MsSeek( xFilial( "CAC" ) + DToS( oModelPeri:GetValue( "MODEL_CWV", "CWV_INIPER" ) ) + DToS( oModelPeri:GetValue( "MODEL_CWV", "CWV_FIMPER" ) ) ) )
			cIdContCtb := aBlocoM[ nIndice, M300_M310, nIndiceBlc, M310_ID_CONTA_CONTABIL ]
			cIdCCusto := aBlocoM[ nIndice, M300_M310, nIndiceBlc, M310_ID_CENTRO_CUSTO ]
			If CAD->( MsSeek( xFilial( "CAD" ) + CAC->CAC_ID + cIdContCtb + cIdCCusto ) )
				If lGerarM312( aBlocoM[ nIndice, M300_M310, nIndiceBlc, M310_VALOR ],;
							 aBlocoM[ nIndice, M300_M310, nIndiceBlc, M310_TIPO_APURACAO ] )
					GerarM312( @aBlocoM[ nIndice, M300_M310, nIndiceBlc, M310_M312], oModelPeri,;
								aBlocoM[ nIndice, M300_SEQUENCIAL_EVENTO ], aBlocoM[ nIndice, M300_ID_GRUPO_EVENTO ] )
				EndIf
			EndIf
		EndIf
	Next nIndiceBlc
Next nIndice

Return( Nil )

/*/{Protheus.doc} AgrpCCont
Agrupa os itens apurados através das contas contabeis
@author david.costa
@since 30/05/2017
@version 1.0
@param aCContDest, array, Array que receberá as contas
@param aCContOrig, array, Array com as contas de origem
@return ${Nil}, ${Nulo}
@example
AgrpCCont( aCContDest, aCContOrig )
/*/Static Function AgrpCCont( aCContDest, aCContOrig )

Local nIndicM310	as numeric
Local nIndice		as numeric

nIndicM310	:= 0
nIndice		:= 0

If Len( aCContOrig ) > 0
	nIndicM310 := aScan( aCContDest, { |x| x[ M310_ID_CONTA_CONTABIL ] == aCContOrig[ 1, M310_ID_CONTA_CONTABIL ] .and.;
											x[ M310_ID_CENTRO_CUSTO ] == aCContOrig[ 1, M310_ID_CENTRO_CUSTO ] } )
	If nIndicM310 > 0
		aCContDest[ nIndicM310, M310_VALOR ] += aCContOrig[ 1, M310_VALOR ]
	Else
		For nIndice := 1 to Len( aCContOrig )
			aAdd( aCContDest, AClone( aCContOrig[ nIndice ] ) )
		Next nIndice 
	EndIf
EndIf

Return( Nil )

/*/{Protheus.doc} GetaProces
Busca os parametros relacionados aos itens do evento que foram considerados na apuração
@author david.costa
@since 30/05/2017
@version 1.0
@param cIdEvento, caracter, Identificador do Evento Tributário utilizado na apuração
@param nIdGrupo, numeric, Identificador do Grupo do item no Evento Tributário
@param cSeqIte, caracter, Sequencial do item no Evento Tributário
@return ${aProcess}, ${Array com os processos encontrados}
@example
GetaProces( cIdEvento, nIdGrupo, cSeqIte )
/*/Static Function GetaProces( cIdEvento, nIdGrupo, cSeqIte )

Local cAliasQry	as character
Local aProcess	as array
Local cSelect	as character
Local cFrom		as character
Local cWhere	as character

cAliasQry	:= GetNextAlias()
aProcess	:= {}
cSelect		:= ""
cFrom		:= ""
cWhere		:= ""

cSelect	:= " T0P_IDPROC "
cFrom		:= RetSqlName( "T0P" ) + " T0P "
cWhere		:= " T0P.D_E_L_E_T_ = '' "
cWhere		+= " AND T0P_FILIAL = '" + xFilial( "T0P" ) + "' "
cWhere		+= " AND T0P_ID = '" + cIdEvento + "' "
cWhere		+= " AND T0P_IDGRUP = " + nIdGrupo
cWhere		+= " AND T0P_SEQITE = '" + cSeqIte + "' "

cSelect	:= "%" + cSelect 	+ "%"
cFrom  	:= "%" + cFrom   	+ "%"
cWhere 	:= "%" + cWhere  	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
EndSql

While ( cAliasQry )->( !Eof() )
	If Len( aProcess ) == 0
		aAdd( aProcess, { ( cAliasQry )->T0P_IDPROC } )
	Else
		aAdd( aProcess, ( cAliasQry )->T0P_IDPROC )
	EndIf
	( cAliasQry )->( DbSkip() )
EndDo

( cAliasQry )->( DbCloseArea() )

Return( aProcess )

/*/{Protheus.doc} AgrpProces
Agrupa os arryas dos processos para a apuração
@author david.costa
@since 30/05/2017
@version 1.0
@param aProcDest, Array, Array que receberá os processos
@param aProcOrige, Array, Array com os processos de origem
@return ${Nil}, ${Nulo}
@example
AgrpProces( aProcDest, aProcOrige )
/*/Static Function AgrpProces( aProcDest, aProcOrige )

Local nIndicM315	as numeric
Local nIndice		as numeric

nIndicM315	:= 0
nIndice		:= 0

For nIndice := 1 to Len( aProcOrige )
	If aScan( aProcDest, { |x| x[ M315_ID_PROCESSO ] == aProcOrige[ nIndice, M315_ID_PROCESSO ] } ) == 0
		aAdd( aProcDest, AClone( aProcOrige[ nIndice ] ) )
	EndIf
Next nIndice

Return( Nil )

/*/{Protheus.doc} lGeraCCust
Informa se deverá ser gerado o centro de custo para a ECF
@author david.costa
@since 30/05/2017
@version 1.0
@param nVlrApurado, numeric, Valor Apurado
@param cTipoApura, caracter, Tipo de apuração utilizada
@param cIndicador, caracter, Indicador da natureza da conta contábil
@return ${lGeraCCust}, ${lGeraCCust}
@example
lGeraCCust( nVlrApurado, cTipoApura, cIndicador )
/*/Static Function lGeraCCust( nVlrApurado, cTipoApura, cIndicador )

Local nValor		as numeric
Local cAliasQry		as character
Local cSelect		as character
Local cFrom			as character
Local cWhere		as character

nValor		:= 0
cAliasQry	:= GetNextAlias()
cSelect		:= ""
cFrom		:= ""
cWhere		:= ""

cSelect	:= " SUM( CAD_VLRCRD ) AS CAD_VLRCRD, SUM( CAD_VLRDEB ) AS CAD_VLRDEB, SUM( CAD_VLRSLF ) AS CAD_VLRSLF, SUM( CAD_VLRSLI ) AS CAD_VLRSLI "
cFrom		:= RetSqlName( "CAD" ) + " CAD "
cWhere		:= " CAD.D_E_L_E_T_ = '' "
cWhere		+= " AND CAD.CAD_FILIAL = '" + xFilial( "CAD" ) + "' "
cWhere		+= " AND CAD.CAD_CTA = '" + CAD->CAD_CTA + "' "
cWhere		+= " AND CAD.CAD_ID = '" + CAD->CAD_ID + "' "

cSelect	:= "%" + cSelect 	+ "%"
cFrom  	:= "%" + cFrom   	+ "%"
cWhere 	:= "%" + cWhere  	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
EndSql

If ( cAliasQry )->( !Eof() )
	Do Case
		Case cTipoApura == TIPO_DEBITO
			nValor := CAD->CAD_VLRDEB
		Case cTipoApura == TIPO_CREDITO
			nValor := CAD->CAD_VLRCRD
		Case cTipoApura == TIPO_MOVIMENTACAO_CONTA
			If cIndicador $ "|C|"
				nValor := CAD->CAD_VLRCRD - CAD->CAD_VLRDEB
			Else
				nValor := CAD->CAD_VLRDEB - CAD->CAD_VLRCRD
			EndIf
		Case cTipoApura == TIPO_SALDO_ANTERIOR
			nValor := CAD->CAD_VLRSLI
		Case cTipoApura == TIPO_SALDO_ATUAL
			nValor := CAD->CAD_VLRSLF
	EndCase
EndIf

lGeraCCust := lGeraCCust .or. nValor == nVlrApurado

Return( lGeraCCust )

//---------------------------------------------------------------------
/*/{Protheus.doc} DelContaPB

Executa pré-condições para a operação desejada.

@Param		aContaPB	-	Array com as Contas da Parte B do Bloco M
			cSuccess	-	Log de sucessos do processo
			cWarning	-	Log de avisos do processo

@Author		Felipe C. Seolin
@Since		27/05/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function DelContaPB( aContaPB, cSuccess, cWarning )

Local oModelCFR	as object
Local nI		as numeric

oModelCFR	:=	Nil
nI			:=	0

For nI := 1 to Len( aContaPB )
	DbSelectArea( "CFR" )
	If CFR->( MsSeek( xFilial( "CFR" ) + aContaPB[nI] ) ) .and. CFR->CFR_ORIGEM == "A"
		oModelCFR := FWLoadModel( "TAFA330" )
		oModelCFR:SetOperation( MODEL_OPERATION_DELETE )
		oModelCFR:Activate()
		If oModelCFR:VldData()
			FWFormCommit( oModelCFR )
			cSuccess += FormatStr( "- " + STR0150, { AllTrim( oModelCFR:GetValue( "MODEL_CFR", "CFR_CODCTA" ) ) + " - " + AllTrim( oModelCFR:GetValue( "MODEL_CFR", "CFR_DCODCT" ) ), Val2Str( oModelCFR:GetValue( "MODEL_CFR", "CFR_VLSALD" ), 16, 2 ) } ) //"Foi removido o item @1 com o valor @2."
			cSuccess += ENTER
		Else
			cWarning += FormatStr( "- " + STR0167, { AllTrim( oModelCFR:GetValue( "MODEL_CFR", "CFR_CODCTA" ) ) + " - " + AllTrim( oModelCFR:GetValue( "MODEL_CFR", "CFR_DCODCT" ) ), Val2Str( oModelCFR:GetValue( "MODEL_CFR", "CFR_VLSALD" ), 16, 2 ) } ) //"Item @1 com o valor @2 não removido."
			cWarning += ENTER
			cWarning += STR0166 + ": " + oModelCFR:GetErrorMessagem()[6] //"Falha"
			cWarning += ENTER
		EndIf
		oModelCFR:DeActivate()
		oModelCFR:Destroy()
		CFR->( DbCloseArea() )
	EndIf
Next nI

Return()

/*/{Protheus.doc} TAFA444REL
Relatório de apuração do LALUR Parte A
@author david.costa
@since 03/05/2017
@version 1.0
@return ${Nil}, ${Nulo}
@example
TAFA444REL()
/*/Function TAFA444REL()

Local cLogErros		as character
Local oModelPeri	as object
Local oModelEven	as object

//Carrega o Período
oModelPeri := FWLoadModel( 'TAFA444' )
oModelPeri:SetOperation( MODEL_OPERATION_VIEW )
oModelPeri:Activate()

If oModelPeri:GetValue( "MODEL_CWV", "CWV_STATUS" ) == PERIODO_ENCERRADO

	//Carrega o Evento
	LoadEvento( @oModelEven, oModelPeri:GetValue( "MODEL_CWV", "CWV_IDEVEN" ) )
	
	If xFunID2Cd( oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI"), "T0K", 1 ) == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. ;
		xFunID2Cd( oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI"), "T0K", 1 ) == TRIBUTACAO_LUCRO_REAL
		RelApuraca( oModelEven, oModelPeri, @cLogErros )
	Else
		AddLogErro( STR0157, @cLogErros ) //"Este Relatório só pode ser gerado para a forma de tributação estimativa por levantamento de balanço."
	EndIf
Else
	AddLogErro( STR0158, @cLogErros ) //"O Relatório só pode ser gerado para períodos encerrados."
EndIf

If !Empty( cLogErros )
	ShowLog( STR0015, cLogErros )//"Atenção"
EndIf

Return( Nil )

/*/{Protheus.doc} TAFA444REB
Relatório de apuração do LALUR Parte B
@author david.costa
@since 04/05/2017
@version 1.0
@return ${Nil}, ${Nulo}
@example
TAFA444REB()
/*/Function TAFA444REB()

Local oModelPeri	as object
Local oModelEven	as object
Local cLogErros		as character

cLogErros	:=	""

//Carrega o Período
oModelPeri := FWLoadModel( 'TAFA444' )
oModelPeri:SetOperation( MODEL_OPERATION_VIEW )
oModelPeri:Activate()

If oModelPeri:GetValue( "MODEL_CWV", "CWV_STATUS" ) == PERIODO_ENCERRADO

	//Carrega o Evento
	LoadEvento( @oModelEven, oModelPeri:GetValue( "MODEL_CWV", "CWV_IDEVEN" ) )
	
	If xFunID2Cd( oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI"), "T0K", 1 ) == TRIBUTACAO_LUCRO_REAL_ESTI_BALANCO .or. ;
		xFunID2Cd( oModelEven:GetValue( "MODEL_T0N", "T0N_IDFTRI"), "T0K", 1 ) == TRIBUTACAO_LUCRO_REAL
		TAFR118( oModelPeri, @cLogErros )
	Else
		AddLogErro( STR0157, @cLogErros ) //"Este Relatório só pode ser gerado para a forma de tributação estimativa por levantamento de balanço."
	EndIf
Else
	AddLogErro( STR0158, @cLogErros ) //"O Relatório só pode ser gerado para períodos encerrados."
EndIf

If !Empty( cLogErros )
	ShowLog( STR0015, cLogErros )//"Atenção"
EndIf

Return( Nil )

/*/{Protheus.doc} GetRelM300
Retorna o tipo de relacionamento do item do M300
@author david.costa
@since 08/06/2017
@version 1.0
@param cRelAtual, caracter, Relacionamento Atual
@param cRelNovo, caracter, Relacionamento Novo
@return ${cRelac}, ${Tipo de relacionamento Atualizado}
@example
GetRelM300( cRelAtual, cRelNovo )
/*/Static Function GetRelM300( cRelAtual, cRelNovo )

Local cRelac	:= ""

If Empty( cRelNovo ) .or. cRelAtual == SEM_RELACIONAMENTO .or. cRelNovo == SEM_RELACIONAMENTO
	cRelac := SEM_RELACIONAMENTO
ElseIf Empty( cRelAtual ) .or. cRelAtual == cRelNovo
	cRelac := cRelNovo
Else
	cRelac := COM_CONTA_DA_PARTE_B_E_CONTA_CONTABIL
EndIf

Return( cRelac )

/*/{Protheus.doc} GetHistorico
Retorna o histórico do item do M300
@author david.costa
@since 12/06/2017
@version 1.0
@param oModelCWX, objeto, Model do detalhamento do Período
@param oModelEven, objeto, Model do Evento Tributário
@return ${cHistorico}, ${Historico do item apurado}
@example
GetHistorico( oModelCWX, oModelEven )
/*/Static Function GetHistorico( oModelCWX, oModelEven )

Local cHistorico		:= ""
Local oModelLanM		:= Nil
Local cIdEven			:= iif( oModelCWX:GetValue('CWX_RURAL') != '1', 'T0N_ID', 'T0N_IDEVEN')

If oModelCWX:GetValue( "CWX_ORIGEM" ) == ORIGEM_LANCAMENTO_MANUAL
	oModelLanM := oModelEven:GetModel( "MODEL_LEC" )
	If oModelLanM:SeekLine( { { "LEC_CODLAN", oModelCWX:GetValue( "CWX_SEQITE" ) } } )
		If !Empty( oModelLanM:GetValue( "LEC_HISTOR" ) )
			cHistorico := AllTrim( oModelLanM:GetValue( "LEC_HISTOR" ) )
		EndIf
	EndIf
Else
	DbSelectArea( "T0O" )
	T0O->( DbSetOrder(1) )
	If T0O->( MsSeek( xFilial( "T0O" ) + oModelEven:GetValue( "MODEL_T0N", cIdEven ) + Str( Val( oModelCWX:GetValue( "CWX_CODGRU" ) ), 2 ) + oModelCWX:GetValue( "CWX_SEQITE" ) ) )
		If !Empty( T0O->T0O_DESCRI )
			cHistorico := AllTrim( T0O->T0O_DESCRI )
		EndIf
	EndIf
EndIf

Return( cHistorico )

/*/{Protheus.doc} ComparaKxM
Compara o saldos do bloco K com os saldos da Apuração e agrupa os itens do M310/360
@author david.costa
@since 12/06/2017
@version 1.0
@return ${lRet}, ${Retorna False se o bloco K não deverá ser considerado}
@example
ComparaKxM( cCustoK, aBlocMCont, cCustoM, aBlcMAux, nDebitoK, nCreditoK, nSaldoIniK, nSaldoFimK, cIdContCtb )
/*/Static Function ComparaKxM( cCustoK, aBlocMCont, cCustoM, aBlcMAux, nDebitoK, nCreditoK, nSaldoIniK, nSaldoFimK, cIdContCtb )

Local nValor	as numeric
Local lRet		as logical

nValor := 0
lRet	:= .T.

If Empty( cCustoK )
	aBlocMCont[ M310_ID_CENTRO_CUSTO ] := ""
	AgrpCCont( @aBlcMAux, { aBlocMCont } )
ElseIf !Empty( cCustoK ) .and. Empty( cCustoM )
	//Verificar se a soma dos Centros de Custos é igual ao apurado
	//Se sim, gerar o valor do bloco K e os centro de custos do bloco K
	If lGeraCCust( aBlocMCont[ M310_VALOR ], aBlocMCont[ M310_TIPO_APURACAO ], aBlocMCont[ M310_NATUREZA_CONTA ] )
		Do Case
			Case aBlocMCont[ M310_TIPO_APURACAO ] == TIPO_DEBITO
				nValor := nDebitoK
			Case aBlocMCont[ M310_TIPO_APURACAO ] == TIPO_CREDITO
				nValor := nCreditoK
			Case aBlocMCont[ M310_TIPO_APURACAO ] == TIPO_MOVIMENTACAO_CONTA
				If aBlocMCont[ M310_NATUREZA_CONTA ] == NATUREZA_TIPO_CREDORA
					nValor := nCreditoK - nDebitoK
				Else
					nValor := nDebitoK - nCreditoK
				EndIf
			Case aBlocMCont[ M310_TIPO_APURACAO ] == TIPO_SALDO_ANTERIOR
				nValor := nSaldoIniK
			Case aBlocMCont[ M310_TIPO_APURACAO ] == TIPO_SALDO_ATUAL
				nValor := nSaldoFimK
		EndCase
		aAdd( aBlcMAux, { cIdContCtb, cCustoK, nValor, aBlocMCont[ M310_NATUREZA_CONTA ], aBlocMCont[ M310_TIPO_APURACAO ], {} } )
	//Senão considerar extamente a apuração e interromper o while
	Else
		AgrpCCont( @aBlcMAux, { aBlocMCont } )
		lRet := .F.
	EndIf
ElseIf !Empty( cCustoK ) .and. !Empty( cCustoM ) .and. cCustoM == cCustoK
	AgrpCCont( @aBlcMAux, { aBlocMCont } )
EndIf

Return( lRet )

/*/{Protheus.doc} GetIndM310
Calcula o indicador do M310
@author david.costa
@since 14/06/2017
@version 1.0
@return ${cIndM310}, ${Indicador do M310}
@example
GetIndM310( aM310, nIdGrupo )
/*/Static Function GetIndM310( aM310, nIdGrupo,lTemParteB )

Local cIndM310   as character
Local cIdContCtb as character
Local cIndNature as character
Local cTpContCtb as character
Local nVlrItem   as numeric

Default lTemParteB := .f.

cIndM310	:=	""
cIdContCtb	:=	aM310[ M310_ID_CONTA_CONTABIL ]
cIndNature	:=	aM310[ M310_NATUREZA_CONTA ]
cTpContCtb	:=	Posicione( "C1O", 3, xFilial( "C1O" ) + cIdContCtb, "C1O->C1O_CODNAT" )
nVlrItem	:=	aM310[ M310_VALOR ]

If cTpContCtb == TIPO_CONTA_DE_RESULTADO
	If nIdGrupo == GRUPO_ADICOES_LUCRO .or. nIdGrupo == GRUPO_ADICOES_DOACAO
		If nVlrItem > 0
			cIndM310 := "D"
		Else
			cIndM310 := "C"
		EndIf
	Else
		If nVlrItem > 0
			cIndM310 := "C"
		Else
			cIndM310 := "D"
		EndIf
	EndIf
Else
	If nIdGrupo == GRUPO_ADICOES_LUCRO .or. nIdGrupo == GRUPO_ADICOES_DOACAO
		//Relacionamento tipo 3, com conta contábil e conta parte B
		if lTemParteB
			If nVlrItem > 0
				cIndM310 := "D"
			Else
				cIndM310 := "C"
			EndIf
		else
			If nVlrItem > 0
				cIndM310 := "C"
			Else
				cIndM310 := "D"
			EndIf
		Endif
	Else
		//Relacionamento tipo 3, com conta contábil e conta parte B
		if lTemParteB
			If nVlrItem > 0
				cIndM310 := "C"
			Else
				cIndM310 := "D"
			EndIf
		else
			If nVlrItem > 0
				cIndM310 := "D"
			Else
				cIndM310 := "C"
			EndIf
		Endif
	EndIf
EndIf

Return( cIndM310 )

/*/{Protheus.doc} LanAutPrej
Faz a chamada para as compensações automaticas da atividade geral e rural
@author david.costa
@since 04/12/2017
@version 1.0
@return ${Nil}, ${Nulo}
/*/Static Function LanAutPrej( aGrupos, aParametro, oModelPeri, oModelEven, cLogAvisos, aParRural, lSimula )

Local nIndicGrup	as numeric
nIndicGrup	:= 0

nIndicGrup := aScan( aGrupos, { |x| x[ PARAM_GRUPO_ID ] == GRUPO_COMPENSACAO_PREJUIZO } )

If nIndicGrup > 0
	//Atividade Rural
	TAF444Comp( @aParRural, @oModelPeri, oModelEven, @cLogAvisos, aGrupos[ nIndicGrup ], .T., aParametro, lSimula )

	//Atividade Geral
	TAF444Comp( @aParametro, @oModelPeri, oModelEven, @cLogAvisos, aGrupos[ nIndicGrup ], .F., aParRural, lSimula )
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TamEUF()

Tamanho da Estrutura SM0 para a empresa, unidade negócio e filial

@author Denis Souza
@since 03/12/18
@version 1.0
@return array

/*/ 
//-------------------------------------------------------------------
Static Function TamEUF(cLayout)

	Local aTam 	As Array
	Local nAte 	As Numeric
	Local nlA 	As Numeric
	Default cLayout := Upper(AllTrim(SM0->M0_LEIAUTE))

	aTam := {0,0,0}
	nAte := Len(cLayout)
	nlA	 := 0

	For nlA := 1 to nAte
		if Upper(substring(cLayout,nlA,1)) == "E"
			++aTam[1]
		elseif Upper(substring(cLayout,nlA,1)) == "U"
			++aTam[2]
		elseif Upper(substring(cLayout,nlA ,1)) == "F"
			++aTam[3]
		endif
	Next nlA

Return aTam

/*----------------------------------------------------------------------
{Protheus.doc} TamEUF()
Retorna o indice da Conta Parte B caso a natureza seja 5-Adicao/Exclusao
@author Carlos Eduardo N. da Silva.
@since 26/08/2020
@version 1.0
@return array
----------------------------------------------------------------------*/
Static Function IndParteB(cCodCtaPB)
Local cRet 	 	:= ''
Local cQuery 	:= ''
Local cAlias	:= GetNextAlias()
Local nVlrPB 	:= 0

cQuery := " SELECT "
cQuery += " 	T0S.T0S_CODIGO, "
cQuery += " 	LEE.LEE_CODIGO, "
cQuery += " 	SUM(CWX.CWX_VALOR) CWX_VALOR "
cQuery += " FROM " + RetSqlName('CWX') + " CWX "
cQuery += " 	INNER JOIN " + RetSqlName('LEE') + " LEE ON LEE.LEE_FILIAL = '" + xFilial('LEE') + "' AND LEE.LEE_ID = CWX.CWX_IDCODG AND LEE.LEE_CODIGO IN ('09','11') AND LEE.D_E_L_E_T_ = ' ' "
cQuery += " 	INNER JOIN " + RetSqlName('CWV') + " CWV ON CWV.CWV_FILIAL = '" + xFilial('CWV') + "' AND CWV.CWV_ID = CWX.CWX_ID AND CWV.D_E_L_E_T_ = ' ' "
cQuery += " 	INNER JOIN " + RetSqlName('T0O') + " T0O ON T0O.T0O_FILIAL = '" + xFilial('T0O') + "' AND T0O.T0O_ID = CWV.CWV_IDEVEN AND T0O.T0O_SEQITE = CWX.CWX_SEQITE AND T0O_IDGRUP = cast(LEE.LEE_CODIGO AS INTEGER) AND T0O.D_E_L_E_T_ = ' ' "
cQuery += " 	INNER JOIN " + RetSqlName('T0S') + " T0S ON T0S.T0S_FILIAL = '" + xFilial('T0S') + "' AND T0S.T0S_ID = T0O.T0O_IDPARB AND T0S.T0S_CODIGO = '" + cCodCtaPB + "' AND T0S.D_E_L_E_T_ = ' ' "
cQuery += " WHERE CWX.D_E_L_E_T_ = ' ' "
cQuery += " 	AND CWX.CWX_FILIAL = '" + xFilial('CWX') + "' "
cQuery += " 	AND CWX.CWX_ORIGEM = '2' "
cQuery += " GROUP BY T0S.T0S_CODIGO, LEE.LEE_CODIGO "
dbUseArea( .t., "TOPCONN", TcGenQry( ,, cQuery ) , cAlias, .f., .t. )

while (cAlias)->(!eof())
	nVlrPB := iif( (cAlias)->LEE_CODIGO == '09', nVlrPB + (cAlias)->CWX_VALOR , nVlrPB - (cAlias)->CWX_VALOR )   
	(cAlias)->(DbSkip())
enddo
(cAlias)->(DbCloseArea())

cRet := iif(nVlrPB > 0, AUMENTA_LUCRO_REAL, REDUZ_LUCRO_REAL)

return cRet
