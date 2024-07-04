#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA506.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA506
@type			function
@description	Cadastro de Responsável pela Movimentação da Instituição Financeira ( V020 - ECF ).
@author			Felipe C. Seolin
@since			17/04/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA506()

Local oBrowse	as object

oBrowse	:=	FWmBrowse():New()

If TAFAlsInDic( "V1R" )
	oBrowse:SetDescription( STR0001 ) //"Responsável pela Movimentação da Instituição Financeira"
	oBrowse:SetAlias( "V1R" )
	oBrowse:SetMenuDef( "TAFA506" )

	V1R->( DBSetOrder( 2 ) )

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

aAdd( aFuncao, { "", "TAF506Vld", "2" } )
aRotina := xFunMnuTAF( "TAFA506",, aFuncao )

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

Local oStruV1R	as object
Local oModel	as object

oStruV1R	:=	FWFormStruct( 1, "V1R" )
oModel		:=	MPFormModel():New( "TAFA506",,, { |oModel| SaveModel( oModel ) } )

oModel:AddFields( "MODEL_V1R", /*cOwner*/, oStruV1R )
oModel:GetModel( "MODEL_V1R" ):SetPrimaryKey( { "V1R_TPDOCR", "V1R_NUMDOC" } )

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
Local oStruV1R	as object

oModel		:=	FWLoadModel( "TAFA506" )
oView		:=	FWFormView():New()
oStruV1R	:=	FWFormStruct( 2, "V1R" )

oView:SetModel( oModel )

oView:AddField( "VIEW_V1R", oStruV1R, "MODEL_V1R" )
oView:EnableTitleView( "VIEW_V1R", STR0001 ) //"Responsável pela Movimentação da Instituição Financeira"

oView:CreateHorizontalBox( "FIELDV1R", 100 )

oView:SetOwnerView( "VIEW_V1R", "FIELDV1R" )

xFunRmFStr( @oStruV1R, "V1R" )
oStruV1R:RemoveField( "V1R_ID" )
oStruV1R:RemoveField( "V1R_IDTPDO" )

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
		TAFAltStat( "V1R", " " )
	EndIf

	FWFormCommit( oModel )
End Transaction

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF506Vld
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
Function TAF506Vld( cAlias, nRecno, nOpc, lJob )

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
nRecno := V1R->( Recno() )

lValida := ( V1R->V1R_STATUS $ ( " |1" ) )

If lValida

	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty( V1R->V1R_IDTPDO )
		aAdd( aLogErro, { "V1R_IDTPDO", "000001", "V1R", nRecno } ) //"Campo inconsistente ou vazio."
	Else
		//------------------
		// Consultas Padrão
		//------------------

		//Chave de busca na Tabela Filha ou Consulta Padrão
		cChave := V1R->V1R_IDTPDO
		xVldECFTab( "V1P", cChave, 1,, @aLogErro, { "V1R", "V1R_IDTPDO", nRecno } )
	EndIf

	If Empty( V1R->V1R_NUMDOC )
		aAdd( aLogErro, { "V1R_NUMDOC", "000001", "V1R", nRecno } ) //"Campo inconsistente ou vazio."
	EndIf

	If Empty( V1R->V1R_NOME )
		aAdd( aLogErro, { "V1R_NOME", "000001", "V1R", nRecno } ) //"Campo inconsistente ou vazio."
	EndIf

	If Empty( V1R->V1R_ENDERE )
		aAdd( aLogErro, { "V1R_ENDERE", "000001", "V1R", nRecno } ) //"Campo inconsistente ou vazio."
	EndIf

	//Atualiza o Status do Registro
	//1 = Registro Inválido
	//0 = Registro Válido
	cStatus := Iif( Len( aLogErro ) > 0, "1", "0" )
	TAFAltStat( "V1R", cStatus )
Else

	aAdd( aLogErro, { "V1R_ID", "000017", "V1R", nRecno } ) //"Registro já validado."

EndIf

//Não apresenta o alerta quando utiliza o Job para validar
If !lJob
	VldECFLog( aLogErro )
EndIf

Return( aLogErro )