#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TMSA027.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA027.PRW
Interface Para Cadastramento Das Classes De Risco De Produtos (Tabela DDS)

@author Eduardo Alberti
@since 30/09/2014
@version P11
/*/
//-------------------------------------------------------------------
Function TMSA027()

	Local oBrowse   := Nil

	Private aRotina := MenuDef()

	//-- Proteção De Erro Da Rotina Caso o Dicionário Da Rotina Não Exista
	If !(AliasInDic("DDS"))
		//-- Mensagem genérica solicitando a atualização do sistema.
		MsgNextRel()
		Return()
	EndIf

	//-- Dá carga Inicial Dos Códigos ONU Quando Tabela Vazia
	If ChkFile('DDS')
		If Empty(DDS->(RecCount()))
			TMSA027Ini()
		EndIf
	EndIf

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DDS')
	oBrowse:SetDescription( STR0001 ) // "Classificacao Risco Produto"

	oBrowse:DisableDetails()

oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0	// Pesquisar
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TMSA027' OPERATION 2 ACCESS 0	// Visualizar
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.TMSA027' OPERATION 3 ACCESS 0	// Incluir
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.TMSA027' OPERATION 4 ACCESS 0	// Alterar
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.TMSA027' OPERATION 5 ACCESS 0	// Excluir
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.TMSA027' OPERATION 8 ACCESS 0	// Imprimir
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.TMSA027' OPERATION 9 ACCESS 0	// Copiar

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruDDS := FWFormStruct( 1, 'DDS', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('TMSA027MODEL', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'DDSMASTER', /*cOwner*/, oStruDDS, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 ) // "Classificacao Risco Produto"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'DDSMASTER' ):SetDescription( STR0001 ) // "Classificacao Risco Produto"

oModel:SetPrimaryKey( {} ) //obrigatorio setar a chave primaria (mesmo que vazia) // Ealberti

// Liga a validação da ativacao do Modelo de Dados
oModel:SetVldActivate( { |oModel| TMSA027ACT( oModel ) } )

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'TMSA027' ) // Tem Quer Ser o Nome Do Fonte (.PRW)
// Cria a estrutura a ser usada na View
Local oStruDDS := FWFormStruct( 2, 'DDS' )
Local oView
//--Local cCampos := {}, nX := 0

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_DDS', oStruDDS, 'DDSMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_DDS', 'TELA' )

Return oView

//-------------------------------------------------------------------
Static Function TMSA027ACT( oModel )

Local aArea      := GetArea()
Local cQuery     := ''
Local cTmp       := ''
Local lRet       := .T.
Local nOperation := oModel:GetOperation()


If nOperation == 5 .AND. lRet

	cTmp    := GetNextAlias()

	cQuery  := ""
	cQuery  += " SELECT      DDS_CLRISC "
	cQuery  += " FROM        " + RetSqlName( 'DDS' ) + " DDS "
	cQuery  += " WHERE       DDS.DDS_FILIAL = '" + xFilial("DDS") + "' "
	cQuery  += " AND         DDS.DDS_CLRISC = '" + DDS->DDS_CLRISC + "' "
	cQuery  += " AND         DDS.D_E_L_E_T_ = ' ' "
	cQuery  += " AND         EXISTS (    SELECT  1 "
	cQuery  += "                         FROM    " + RetSqlName( 'DY3' ) + " DY3 "
	cQuery  += "                         WHERE   DY3.DY3_FILIAL = '" + xFilial("DY3") + "' "
	cQuery  += "                         AND     DY3.DY3_NRISCO = DDS.DDS_CLRISC "
	cQuery  += "                         AND     DY3.D_E_L_E_T_ = ' ' )	"

	cQuery  := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .F., .T. )

	lRet := (cTmp)->( EOF() )

	(cTmp)->( dbCloseArea() )

	If !lRet
		Help('',1,'TMSA02701')	// 'Esta Classe De Risco Está Em Uso Na Classificação ONU (DY3).'
	EndIf

EndIf

RestArea( aArea )

Return lRet
//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA027Ini
@autor		: Eduardo Alberti
@descricao	: Carga Inicial Da tabela DDS
@since		: Mar./2015
@using		: Divergencias Das Classes De Risco/Grupo Embalagens
@review	:
/*/
//------------------------------------------------------------------------------------------------
Static Function TMSA027Ini()

Local aArea 	:= GetArea()
Local aDados	:= {}
Local nI		:= 0
Local nClRisc := TamSX3('DDS_CLRISC')[1]
Local nDescri := TamSX3('DDS_DESCRI')[1]

aAdd(aDados,{'1.1', STR0010 })	//-- 'Substância e artigos com risco de explosão em massa. '
aAdd(aDados,{'1.2', STR0011 })	//-- 'Substância e artigos com risco de projeção, mas sem risco de explosão em massa. '
aAdd(aDados,{'1.3', STR0012 })	//-- 'Substâncias e artigos com risco de fogo e com pequeno risco de explosão ou de projeção, ou ambos, mas sem risco de explosão em massa. '
aAdd(aDados,{'1.4', STR0013 })	//-- 'Substância e artigos que não apresentam risco significativo. '
aAdd(aDados,{'1.5', STR0014 })	//-- 'Substâncias muito sensíveis, com risco de explosão em massa. '
aAdd(aDados,{'1.6', STR0015 })	//-- 'Artigos extremamente insensíveis, sem risco de explosão em massa. '
aAdd(aDados,{'2.1', STR0016 })	//-- 'Gases inflamáveis: são gases que a 20°C e à pressão normal são inflamáveis. '
aAdd(aDados,{'2.2', STR0017 })	//-- 'Gases não-inflamáveis, não tóxicos: são gases asfixiantes e oxidantes, que não se enquadrem em outra subclasse. '
aAdd(aDados,{'2.3', STR0018 })	//-- 'Gases tóxicos: são gases tóxicos e corrosivos que constituam risco à saúde das pessoas. '
aAdd(aDados,{'4.1', STR0019 })	//-- 'Sólidos inflamáveis, Substâncias auto-reagentes e explosivos sólidos insensibilizados '
aAdd(aDados,{'4.2', STR0020 })	//-- 'Substâncias sujeitas à combustão espontânea'
aAdd(aDados,{'4.3', STR0021 })	//-- 'Substâncias que, em contato com água, emitem gases inflamáveis.'
aAdd(aDados,{'5.1', STR0022 })	//-- 'Substâncias oxidantes: são substâncias que podem causar a combustão de outros materiais ou contribuir para isso. '
aAdd(aDados,{'5.2', STR0023 })	//-- 'Peróxidos orgânicos: são poderosos agentes oxidantes, periodicamente instáveis, podendo sofrer decomposição. '
aAdd(aDados,{'6.1', STR0024 })	//-- 'Substâncias tóxicas: são substâncias capazes de provocar morte,lesões graves ou danos à saúde humana, se ingeridas ou inaladas, ou se entrarem em contato com a pele. '
aAdd(aDados,{'6.2', STR0025 })	//-- 'Substâncias infectantes: são substâncias que podem provocar doenças infecciosas em seres humanos ou em animais. '
aAdd(aDados,{'7  ', STR0026 })	//-- 'Material radioativo '
aAdd(aDados,{'8  ', STR0027 })	//-- 'Substâncias corrosivas '
aAdd(aDados,{'9  ', STR0028 })	//-- 'Substâncias e artigos perigosos diversos '

DbSelectArea('DDS')
DbSetOrder(1)

//-- Inicializa Controle Transacional
Begin Transaction

For nI := 1 To Len(aDados)

	If !DDS->(MsSeek(xFilial('DDS') + PadR(aDados[nI],nClRisc)))

		RecLock('DDS',.t.)
		Replace DDS->DDS_FILIAL With xFilial('DDS')
		Replace DDS->DDS_CLRISC With PadR(aDados[nI,01],nClRisc)
		Replace DDS->DDS_DESCRI With PadR(aDados[nI,02],nDescri)
		DDS->(MsUnlock())

	EndIf
Next nI

//-- Finaliza Controle Transacional
End Transaction

RestArea(aArea)

Return(Nil)
//-------------------------------------------------------------------
/*
REGRAS DE IMPLEMENTACAO

01 - Criar Tabela De Classes de Risco (DDS).
02 - Criar Tabela Do Cadastro de Divergencias (DDT).
02 - Inclusao Consulta padronizada SXB Para tabela DDS denominada 'DDS'
03 - Criar No SX5 Tabela Generica 'TX' Para Codigos De Grupo De Embalagens
04 - Inclusao Consulta padronizada SXB Para tabela 'TX' denominada 'TXSX5'
05 - Na tabela DY3 Class ONU Campo DY3_NRISCO colocar consulta 'DDS'   e colocar validacao (Vazio() .Or. ExistCPO("DDS"))
06 - Na tabela DY3 Class ONU Campo DY3_GRPEMB colocar consulta 'TXSX5' e colocar validacao (Vazio() .Or. ExistCpo("SX5","TX"+M->DY3_GRPEMB))
*/
