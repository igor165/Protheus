#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA507.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA507
@type			function
@description	Cadastro de Derex - Movimentação ( V030/V100 - ECF ).
@author			Felipe C. Seolin
@since			17/04/2018
@version		1.0
/*/
//---------------------------------------------------------------------
Function TAFA507()

Local oBrowse	as object

oBrowse	:=	FWmBrowse():New()

If TAFAlsInDic( "V1S" )
	oBrowse:SetDescription( STR0001 ) //"Derex - Movimentação"
	oBrowse:SetAlias( "V1S" )
	oBrowse:SetMenuDef( "TAFA507" )

	V1S->( DBSetOrder( 2 ) )

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

aAdd( aFuncao, { "", "TAF507Vld", "2" } )
aRotina := xFunMnuTAF( "TAFA507",, aFuncao )

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

Local oStruV1S	as object
Local oModel	as object

oStruV1S	:=	FWFormStruct( 1, "V1S" )
oModel		:=	MPFormModel():New( "TAFA507",,, { |oModel| SaveModel( oModel ) } )

oModel:AddFields( "MODEL_V1S", /*cOwner*/, oStruV1S )
oModel:GetModel( "MODEL_V1S" ):SetPrimaryKey( { "V1S_CODINS", "V1S_RESPDO", "V1S_RESPNU", "V1S_DATA", "V1S_CODLAN", "V1S_CODCTA" } )

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
Local oStruV1S	as object

oModel		:=	FWLoadModel( "TAFA507" )
oView		:=	FWFormView():New()
oStruV1S	:=	FWFormStruct( 2, "V1S" )

oView:SetModel( oModel )

oView:AddField( "VIEW_V1S", oStruV1S, "MODEL_V1S" )
oView:EnableTitleView( "VIEW_V1S", STR0001 ) //"Derex - Movimentação"

oView:CreateHorizontalBox( "FIELDV1S", 100 )

oView:SetOwnerView( "VIEW_V1S", "FIELDV1S" )

xFunRmFStr( @oStruV1S, "V1S" )
oStruV1S:RemoveField( "V1S_ID" )
oStruV1S:RemoveField( "V1S_IDCODI" )
oStruV1S:RemoveField( "V1S_IDRESP" )
oStruV1S:RemoveField( "V1S_IDCODL" )

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
		TAFAltStat( "V1S", " " )
	EndIf

	FWFormCommit( oModel )
End Transaction

Return( .T. )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF507Vld
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
Function TAF507Vld( cAlias, nRecno, nOpc, lJob )

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
nRecno := V1S->( Recno() )

lValida := ( V1S->V1S_STATUS $ ( " |1" ) )

If lValida

	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty( V1S->V1S_IDCODI )
		aAdd( aLogErro, { "V1S_IDCODI", "000001", "V1S", nRecno } ) //"Campo inconsistente ou vazio."
	Else
		//------------------
		// Consultas Padrão
		//------------------

		//Chave de busca na Tabela Filha ou Consulta Padrão
		cChave := V1S->V1S_IDCODI
		xVldECFTab( "V1Q", cChave, 1,, @aLogErro, { "V1S", "V1S_IDCODI", nRecno } )
	EndIf

	If Empty( V1S->V1S_IDRESP )
		aAdd( aLogErro, { "V1S_IDRESP", "000001", "V1S", nRecno } ) //"Campo inconsistente ou vazio."
	Else
		//------------------
		// Consultas Padrão
		//------------------

		//Chave de busca na Tabela Filha ou Consulta Padrão
		cChave := V1S->V1S_IDRESP
		xVldECFTab( "V1R", cChave, 1,, @aLogErro, { "V1S", "V1S_IDRESP", nRecno } )
	EndIf

	If Empty( V1S->V1S_DATA )
		aAdd( aLogErro, { "V1S_DATA", "000003", "V1S", nRecno } ) //"Data inconsistente ou vazia."
	EndIf

	If Empty( V1S->V1S_IDCODL )
		aAdd( aLogErro, { "V1S_IDCODL", "000001", "V1S", nRecno } ) //"Campo inconsistente ou vazio."
	Else
		//------------------
		// Consultas Padrão
		//------------------

		//Chave de busca na Tabela Filha ou Consulta Padrão
		cChave := V1S->V1S_IDCODL
		If xVldECFTab( "CH6", cChave, 1,, @aLogErro, { "V1S", "V1S_IDCODL", nRecno } )
			If AllTrim( CH6->CH6_CODREG ) <> "V100"
				aAdd( aLogErro, { "V1S_IDCODL", "000332", "V1S", nRecno } ) //"O código de lançamento deve ser informado conforme tabela 'SPEDECF_V100'."
			EndIf
		EndIf
	EndIf

	If Empty( V1S->V1S_VALOR )
		aAdd( aLogErro, { "V1S_VALOR", "000001", "V1S", nRecno } ) //"Campo inconsistente ou vazio."
	EndIf

	If Empty( V1S->V1S_CODCTA )
		aAdd( aLogErro, { "V1S_CODCTA", "000001", "V1S", nRecno } ) //"Campo inconsistente ou vazio."
	EndIf

	//Atualiza o Status do Registro
	//1 = Registro Inválido
	//0 = Registro Válido
	cStatus := Iif( Len( aLogErro ) > 0, "1", "0" )
	TAFAltStat( "V1S", cStatus )
Else

	aAdd( aLogErro, { "V1S_ID", "000017", "V1S", nRecno } ) //"Registro já validado."

EndIf

//Não apresenta o alerta quando utiliza o Job para validar
If !lJob
	VldECFLog( aLogErro )
EndIf

Return( aLogErro )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF507SXB
@type			function
@description	Função para atribuição de conteúdo em campos relacionados a consulta padrão.
@author			Felipe C. Seolin
@since			19/04/2018
@version		1.0
@param			cRetorno	-	Conteúdo do retorno padrão da consulta padrão
@return			cRetorno	-	Conteúdo do retorno padrão da consulta padrão
/*/
//---------------------------------------------------------------------
Function TAF507SXB( cRetorno )

Local oModel	as object
Local cCampo	as char

oModel	:=	Nil
cCampo	:=	SubStr( ReadVar(), 4 )

If cCampo == "V1S_RESPNU"
	oModel := FWModelActive()
	oModel:LoadValue( "MODEL_V1S", "V1S_RESPDO", Posicione( "V1P", 1, xFilial( "V1P" ) + V1R->V1R_IDTPDO, "V1P_CODIGO" ) )
	oModel:LoadValue( "MODEL_V1S", "V1S_RESPNO", V1R->V1R_NOME )
	oModel:LoadValue( "MODEL_V1S", "V1S_IDRESP", V1R->V1R_ID )
EndIf

Return( cRetorno )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF507Init
@type			function
@description	Função para atribuição da propriedade de inicialização padrão do campo.
@author			Felipe C. Seolin
@since			20/04/2018
@version		1.0
@return			cInit	-	Conteúdo da inicialização padrão do campo
/*/
//---------------------------------------------------------------------
Function TAF507Init()

Local cCampo	as character
Local cInit		as character

cCampo	:=	SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
cInit	:=	""

If !INCLUI
	If cCampo == "V1S_RESPDO"
		cInit := Posicione( "V1P", 1, xFilial( "V1P" ) + Posicione( "V1R", 1, xFilial( "V1R" ) + V1S->V1S_IDRESP, "V1R_IDTPDO" ), "V1P_CODIGO" )
	EndIf
EndIf

If !Empty( cInit ) .and. AllTrim( cInit ) == "-"
	cInit := ""
EndIf

Return( cInit )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF507Unq
@type			function
@description	Função para validação da chave única.
@author			Felipe C. Seolin
@since			20/04/2018
@version		1.0
@return			lRet	-	Indica se a operação está consistente
/*/
//---------------------------------------------------------------------
Function TAF507Unq()

Local cCampo	as char
Local cCampo2	as char
Local cChave	as char
Local cRet		as char
Local nI		as numeric
Local aCampos	as array
Local lRet		as logical

cCampo	:=	ReadVar()
cCampo2	:=	SubStr( cCampo, 4 )
cChave	:=	""
cRet	:=	""
nI		:=	0
aCampos	:=	{}
lRet	:=	.T.

aAdd( aCampos, { "V1S_CODINS", 'Posicione( "V1Q", 2, xFilial( "V1Q" ) + FWFldGet( "V1S_CODINS" ), "V1Q_ID" )' } )
aAdd( aCampos, { "V1S_RESPNU", 'Posicione( "V1R", 2, xFilial( "V1R" ) + Posicione( "V1P", 2, xFilial( "V1P" ) + FWFldGet( "V1S_RESPDO" ), "V1P_ID" ) + FWFldGet( "V1S_RESPNU" ), "V1R_ID" )' } )
aAdd( aCampos, { "V1S_DATA", 'DToS( FWFldGet( "V1S_DATA" ) )' } )
aAdd( aCampos, { "V1S_CODLAN", 'Posicione( "CH6", 2, xFilial( "CH6" ) + PadR( "V100", TamSX3( "CH6_CODREG" )[1] ) + FWFldGet( "V1S_CODLAN" ), "CH6_ID" )' } )
aAdd( aCampos, { "V1S_CODCTA", 'FWFldGet( "V1S_CODCTA" )' } )

//Converto a chamada do FWFldGet para o campo de memória "M->"
For nI := 1 to Len( aCampos )
	cChave := StrTran( aCampos[nI,2], 'FWFldGet( "' + cCampo2 + '" )', cCampo )
	cRet += &( cChave )
Next nI

lRet := xFunVldUni( SubStr( cCampo2, 1, 3 ), 2, cRet, .F. )

Return( lRet )