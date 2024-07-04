#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA505.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA505
@type			function
@description	Cadastro de Instituição Financeira ( V010 - ECF ).
@author			Felipe C. Seolin
@since			17/04/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA505()

Local oBrowse	as object

oBrowse	:=	FWmBrowse():New()

If TAFAlsInDic( "V1Q" )
	oBrowse:SetDescription( STR0001 ) //"Instituição Financeira"
	oBrowse:SetAlias( "V1Q" )
	oBrowse:SetMenuDef( "TAFA505" )

	V1Q->( DBSetOrder( 2 ) )

	oBrowse:Activate()
Else
	Aviso( STR0002, TafAmbInvMsg(), { STR0003 }, 3 ) //##"Dicionário Incompatível" ##"Encerrar"
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@type			function
@description	Função genérica MVC com as opções de menu.
@author			Felipe C. Seolin
@since			17/04/2018
@version		1.0
@return			aRotina - Array com as opções de menu.
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao	as array
Local aRotina	as array

aFuncao	:=	{}
aRotina	:=	{}

aAdd( aFuncao, { "", "TAF505Vld", "2" } )
aRotina := xFunMnuTAF( "TAFA505",, aFuncao )

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
@type			function
@description	Função genérica MVC do Model.
@author			Felipe C. Seolin
@since			17/04/2018
@version		1.0
@return			oModel - Objeto do modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

Local oStruV1Q	as object
Local oStruV3T 	as object 	
Local oModel	as object
Local lExistV3T := AliasInDic('V3T')

oStruV1Q	:=	FWFormStruct( 1, "V1Q" )
if lExistV3T
	oStruV3T	:= FWFormStruct( 1, 'V3T' )
endif
oModel		:=	MPFormModel():New( "TAFA505",,, { |oModel| SaveModel( oModel ) } )

oModel:AddFields( "MODEL_V1Q", /*cOwner*/, oStruV1Q )
if lExistV3T
	oModel:AddGrid ('MODEL_V3T', 'MODEL_V1Q',oStruV3T,,{|MODEL_V3T| ValidResp(oModel)})  
	oModel:GetModel('MODEL_V3T'):SetOptional( .T. )
	oModel:GetModel('MODEL_V3T'):SetUniqueLine( { 'V3T_ID','V3T_IDRESP','V3T_CODCTA' } ) 
endif

oModel:GetModel( "MODEL_V1Q" ):SetPrimaryKey( { "V1Q_CODIGO" } )
if lExistV3T
	oModel:SetRelation(  "MODEL_V3T", {{ "V3T_FILIAL","xFilial('V3T')" },{"V3T_ID","V1Q_ID"}}, V3T->( IndexKey(1)))
endif

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Função genérica MVC da View.
@author			Felipe C. Seolin
@since			17/04/2018
@version		1.0
@return			oModel - Objeto do modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oModel	as object
Local oView		as object
Local oStruV1Q	as object
Local oStruV3T  as object
Local nHBox as numeric  
Local lExistV3T := AliasInDic('V3T')

oModel		:=	FWLoadModel( "TAFA505" )
oView		:=	FWFormView():New()
oStruV1Q	:=	FWFormStruct( 2, "V1Q" )
if lExistV3T
	oStruV3T	:=	FWFormStruct( 2, "V3T" )
	nHBox		:=  30
else
	nHBox		:= 100
endif

oView:SetModel( oModel )

oView:AddField( "VIEW_V1Q", oStruV1Q, "MODEL_V1Q" )
oView:EnableTitleView( "VIEW_V1Q", STR0001 ) //"Instituição Financeira"

oView:CreateHorizontalBox( "FIELDV1Q", nHBox )
if lExistV3T
	oView:AddGrid( 'VIEW_V3T' , oStruV3T,  'MODEL_V3T' )
	oView:EnableTitleView( 'VIEW_V3T', 'Amarração Inst. Financeira vs Responsavel' ) //"Info.opt. refis Lucro R/P/A"
	oView:CreateFolder("FOLDER_PRINCIPAL","FIELDV1Q") 
	oView:CreateHorizontalBox( "FIELDV3T", 70 )
	oView:CreateFolder("FOLDER_INFERIOR","FIELDV3T") 
endif

oView:SetOwnerView( "VIEW_V1Q", "FIELDV1Q" )
if lExistV3T
	oView:SetOwnerView( 'VIEW_V3T', 'FIELDV3T' )   
endif

xFunRmFStr( @oStruV1Q, "V1Q" )
oStruV1Q:RemoveField( "V1Q_ID" )
oStruV1Q:RemoveField( "V1Q_IDMOED" )

if lExistV3T
	oStruV3T:RemoveField('V3T_ID')
	oStruV3T:RemoveField('V3T_IDRESP')
endif


Return( oView )

//---------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
@type			function
@description	Função de gravação dos dados, executado na confirmação do modelo.
@author			Felipe C. Seolin
@since			17/04/2018
@version		1.0
@param			oModel - Objeto do modelo MVC
@return			.T.
/*/
//---------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation	as numeric

nOperation	:=	oModel:GetOperation()

Begin Transaction
	If nOperation == MODEL_OPERATION_UPDATE
		TAFAltStat( "V1Q", " " )
	EndIf

	FWFormCommit( oModel )
End Transaction

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF505Vld
@type			function
@description	Função que valida os dados do registro posicionado.
@author			Felipe C. Seolin
@since			17/04/2018
@version		1.0
@param			cAlias		-	Alias corrente
@param			nRecno		-	Recno corrente
@param			nOpc		-	Opção selecionada
@param			lJob		-	Indicao execução por Job
@return			aLogErro	-	Array com as ocorrências de erro
/*/
//---------------------------------------------------------------------
Function TAF505Vld( cAlias, nRecno, nOpc, lJob )

Local cStatus	as char
Local cChave	as char
Local aLogErro	as array
Local lValida	as logical

Default lJob	:=	.F.

cStatus	:=	""
cChave	:=	""
aLogErro	:=	{}
lValida	:=	.F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := V1Q->( Recno() )

lValida := ( V1Q->V1Q_STATUS $ ( " |1" ) )

If lValida

	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty( V1Q->V1Q_CODIGO )
		aAdd( aLogErro, { "V1Q_CODIGO", "000001", "V1Q", nRecno } ) //"Campo inconsistente ou vazio."
	EndIf

	If Empty( V1Q->V1Q_NOME )
		aAdd( aLogErro, { "V1Q_NOME", "000001", "V1Q", nRecno } ) //"Campo inconsistente ou vazio."
	EndIf

	If Empty( V1Q->V1Q_PAIS )
		aAdd( aLogErro, { "V1Q_PAIS", "000001", "V1Q", nRecno } ) //"Campo inconsistente ou vazio."
	Else
		//------------------
		// Consulta Padrão
		//------------------

		//Chave de busca na Tabela Filha ou Consulta Padrão
		cChave := V1Q->V1Q_PAIS
		If xVldECFTab( "C08", cChave, 3,, @aLogErro, { "V1Q", "V1Q_PAIS", nRecno } )
			If Empty( C08->C08_JURIDI )
				aAdd( aLogErro, { "V1Q_PAIS", "000329", "V1Q", nRecno } ) //"O país deve ser informado conforme tabela 'EFDFINANCEIRA_PAISES'."
			//REGRA_DIFERENTE_BRASIL: Verifica, quando V010.PAIS é igual "BR" (Brasil)
			ElseIf C08->C08_JURIDI == "BR"
				aAdd( aLogErro, { "V1Q_PAIS", "000330", "V1Q", nRecno } ) //"O país informado deve ser diferente de 'BR' ( Brasil )."
			EndIf
		EndIf
	EndIf

	If Empty( V1Q->V1Q_IDMOED )
		aAdd( aLogErro, { "V1Q_MOEDA", "000001", "V1Q", nRecno } ) //"Campo inconsistente ou vazio."
	Else
		//------------------
		// Consulta Padrão
		//------------------

		//Chave de busca na Tabela Filha ou Consulta Padrão
		cChave := V1Q->V1Q_IDMOED
		If xVldECFTab( "CZU", cChave, 1,, @aLogErro, { "V1Q", "V1Q_IDMOED", nRecno } )
			If Empty( CZU->CZU_SIGLAM )
				aAdd( aLogErro, { "V1Q_IDMOED", "000331", "V1Q", nRecno } ) //"A moeda deve ser informada conforme tabela 'SPEDECF_CBC_MOEDA'."
			EndIf
		EndIf
	EndIf

	//Atualiza o Status do Registro
	//1 = Registro Inválido
	//0 = Registro Válido
	cStatus := Iif( Len( aLogErro ) > 0, "1", "0" )
	TAFAltStat( "V1Q", cStatus )
Else

	aAdd( aLogErro, { "V1Q_ID", "000017", "V1Q", nRecno } ) //"Registro já validado."

EndIf

//Não apresenta o alerta quando utiliza o Job para validar
If !lJob
	VldECFLog( aLogErro )
EndIf

Return( aLogErro )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF505Init
@type			function
@description	Função para atribuição da propriedade de inicialização padrão do campo.
@author			Felipe C. Seolin
@since			18/04/2018
@version		1.0
@return			cInit	-	Conteúdo da inicialização padrão do campo
/*/
//---------------------------------------------------------------------
Function TAF505Init()

Local cCampo	as char
Local cInit		as char

cCampo	:=	SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
cInit	:=	""

If !INCLUI
	If cCampo == "V1Q_DPAIS"
		If !Empty( V1Q->V1Q_PAIS )
			cInit := Posicione( "C08", 3, xFilial( "C08" ) + V1Q->V1Q_PAIS, "AllTrim( C08_JURIDI ) + ' - ' + C08_DESCRI" )
		EndIf
	EndIf
EndIf

Return( cInit )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF505IniB
@type			function
@description	Função para atribuição da propriedade de inicialização browse do campo.
@author			Felipe C. Seolin
@since			18/04/2018
@version		1.0
@return			cInit	-	Conteúdo da inicialização browse do campo
/*/
//---------------------------------------------------------------------
Function TAF505IniB( cCampo )

Local cInit	as char

cInit	:=	""

If cCampo == "V1Q_DPAIS"
	If !Empty( V1Q->V1Q_PAIS )
		cInit := Posicione( "C08", 3, xFilial( "C08" ) + V1Q->V1Q_PAIS, "AllTrim( C08_JURIDI ) + ' - ' + C08_DESCRI" )
	EndIf
EndIf

Return( cInit )

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidResp
@type			function
@description	Função para validar o responsavel selecionado na grid
@author			Carlos Eduardo N. Silva
@since			06/07/2019
@version		1.0
@return			cInit	-	Conteúdo da inicialização browse do campo
/*/
//---------------------------------------------------------------------
Static Function ValidResp(oModel)
Local lRet as logical
Local cDocRes as character

cDocRes := oModel:GetModel('MODEL_V3T'):GetValue('V3T_DOCRES')
if empty(GetAdvFVal('V1R','V1R_ID',xFilial('V1R')+cDocRes,3))
	oModel:SetErrorMessage( ,,,,,STR0004,, ) //'Esse número de documento não existe no cadastro de responsável.'
	lRet := .f.
endif	

return lRet