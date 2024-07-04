#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA331.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA331

Cadastro de Lançamentos Contábeis ( ECD I200 ).

@Author	Evandro dos Santos Oliveira
@Since		10/06/2014
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFA331()

Local oBrowse	as object

oBrowse	:=	FWmBrowse():New()

oBrowse:SetDescription( STR0001 ) //"Lançamentos Contábeis"
oBrowse:SetAlias( "CFS" )
oBrowse:SetMenuDef( "TAFA331" )
CFS->( DBSetOrder( 2 ) )
oBrowse:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Função genérica MVC com as opções de menu.

@Return	aRotina	- Array com as opções de menu

@Author	Evandro dos Santos Oliveira
@Since		10/06/2014
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao	as array
Local aRotina	as array

aFuncao	:=	{ { "", "TAF331Vld", "2" } }
aRotina	:=	{}

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title STR0003 Action "VIEWDEF.TAFA331" OPERATION 2 ACCESS 0 //"Visualizar"
Else
	aRotina := xFunMnuTAF( "TAFA331",, aFuncao )
EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Função genérica MVC do modelo.

@Return	oModel	- Objeto da Model MVC

@Author	Evandro dos Santos Oliveira
@Since		10/06/2014
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCFS	as object
Local oStruCHB	as object
Local oModel		as object

oStruCFS	:=	FWFormStruct( 1, "CFS" )
oStruCHB	:=	FWFormStruct( 1, "CHB" )
oModel		:=	MPFormModel():New( "TAFA331",,, { |oModel| SaveModel( oModel ) } )

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStruCFS:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
	oStruCHB:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
EndIf

oModel:AddFields( "MODEL_CFS", /*cOwner*/, oStruCFS )
oModel:GetModel( "MODEL_CFS" ):SetPrimaryKey( { "CFS_NUMLCT" } )

oModel:AddGrid( "MODEL_CHB", "MODEL_CFS", oStruCHB )
oModel:GetModel( "MODEL_CHB" ):SetUniqueLine( { "CHB_CODCTA", "CHB_CODCUS", "CHB_NUMARQ" } )

oModel:SetRelation( "MODEL_CHB", { { "CHB_FILIAL", "xFilial( 'CHB' )" }, { "CHB_ID", "CFS_ID" } }, CHB->( IndexKey( 1 ) ) )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Função genérica MVC da View.

@Return	oView	- Objeto da View MVC

@Author	Evandro dos Santos Oliveira
@Since		10/06/2014
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		as object
Local oStruCFS	as object
Local oStruCHB	as object
Local oView		as object

oModel		:=	FWLoadModel( "TAFA331" )
oStruCFS	:=	FWFormStruct( 2, "CFS" )
oStruCHB	:=	FWFormStruct( 2, "CHB" )
oView		:=	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( "VIEW_CFS", oStruCFS, "MODEL_CFS" )
oView:EnableTitleView( "VIEW_CFS", STR0001 ) //"Lançamentos Contábeis"

oView:AddGrid( "VIEW_CHB", oStruCHB, "MODEL_CHB" )
oView:EnableTitleView( "VIEW_CHB", STR0002 ) //"Partidas do Lançamento"

oView:CreateHorizontalBox( "FIELDSCFS", 40 )
oView:CreateHorizontalBox( "CHB", 60 )

If TamSX3("CHB_CODCTA")[1] == 36
	oStruCHB:RemoveField( "CHB_CODCTA")
	oStruCHB:SetProperty( "CHB_CTACTB", MVC_VIEW_ORDEM, "03" )
EndIf

If TamSX3("CHB_CODPAR")[1] == 36
	oStruCHB:RemoveField( "CHB_CODPAR")
	oStruCHB:SetProperty( "CHB_PARTIC", MVC_VIEW_ORDEM, "14" )
	oStruCHB:SetProperty( "CHB_DCODPA", MVC_VIEW_ORDEM, "15" )
	oStruCHB:SetProperty( "CHB_HISTOR", MVC_VIEW_ORDEM, "16" )
EndIf
oView:SetOwnerView( "VIEW_CFS", "FIELDSCFS" )
oView:SetOwnerView( "VIEW_CHB", "CHB" )

oStruCFS:RemoveField( "CFS_ID" )
oStruCHB:RemoveField( "CHB_IDCODH" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel

Gravação dos dados, executado no momento da confirmação do modelo.

@Param		oModel	- Modelo de dados

@Return	.T.

@Author	Evandro dos Santos Oliveira
@Since		10/06/2014
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation	as numeric

nOperation	:=	oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
		TAFAltStat( "CFS", " " )
	EndIf

	FWFormCommit( oModel )

End Transaction

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF331Vld

Validação dos registros de acordo com as regras
de integridade e regras do manual da ECD.

@Param		cAlias		- Alias da tabela
			nRecno		- Recno do registro corrente
			nOpc		- Operação a ser realizada
			lJob		- Informa se foi chamado por Job

@Return	aLogErro	- Array com o log de erros de validação

@Author	Evandro dos Santos Oliveira
@Since		10/06/2014
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAF331Vld( cAlias, nRecno, nOpc, lJob )

Local cCHBKey		as character
Local cStatus		as character
Local aLogErro	as array
Local aDadosUtil	as array

cCHBKey	:=	""
cStatus	:=	""
aLogErro	:=	{}
aDadosUtil	:=	{}

Default lJob	:=	.F.

If CFS->CFS_STATUS $ ( " 1" )

	If Empty( CFS->CFS_NUMLCT )
		aAdd( aLogErro, { "CFS_NUMLCT", "000001", "CFS", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	EndIf

	If Empty( CFS->CFS_VLLCTO )
		aAdd( aLogErro, { "CFS_VLCLTO", "000001", "CFS", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	EndIf

	If Empty( CFS->CFS_INDLCT )
		aAdd( aLogErro, { "CFS_INDLCT", "000001", "CFS", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	ElseIf !( CFS->CFS_INDLCT $ "1|2|3" )
		aAdd( aLogErro, { "CFS_INDLCT", "000002", "CFS", nRecno } ) //STR0002 - "Conteúdo do campo não condiz com as opções possíveis."
	EndIf

	aDadosUtil := { "CFS_NUMLCT" }
	xVldECFReg( "CFS", "REGRA_REGISTRO_DUPLICADO", @aLogErro, aDadosUtil,, 1 )

	cCHBKey := CFS->CFS_ID
	If CHB->( MsSeek( xFilial( "CHB" ) + cCHBKey ) )

		While CHB->( !Eof() ) .and. cCHBKey == CHB->CHB_ID

			//-----------------
			// Consulta Padrão
			//-----------------
			If !Empty( CHB->CHB_CODCTA )
				//Chave de busca na tabela Filho ou Consulta Padrão
				cChave := CHB->CHB_CODCTA

				//O retorno da função xVldECFTab indica que a chave enviada foi encontrada
				If xVldECFTab( "C1O", cChave, 3,, @aLogErro, { "CFS", "CHB_CODCTA", nRecno } )
					//Verifica se a Conta Contábil informada é analítica ( Regra da ECD )

					If !( C1O->C1O_INDCTA $ "1" )
						aAdd( aLogErro,{ "CHB_CODCTA", "000124", "CFS", nRecno } ) //STR0124 - "O campo 'Cta Contabil' deve representar uma conta analítica."
					EndIf
				EndIf
			EndIf

			//-----------------
			// Consulta Padrão
			//-----------------
			If !Empty( CHB->CHB_CODCUS )
				//Chave de busca na tabela Filho ou Consulta Padrão
				cChave := CHB->CHB_CODCUS
				xVldECFTab( "C1P", cChave, 3,, @aLogErro, { "CFS", "CHB_CODCUS", nRecno } )
			EndIf

			//-----------------
			// Consulta Padrão
			//-----------------
			If !Empty( CHB->CHB_IDCODH )
				//Chave de busca na tabela Filho ou Consulta Padrão
				cChave := CHB->CHB_IDCODH
				xVldECFTab( "CHC", cChave, 1,, @aLogErro, { "CFS", "CHB_IDCODH", nRecno } )
			EndIf

			//-----------------
			// Consulta Padrão
			//-----------------
			If !Empty( CHB->CHB_CODPAR )
				//Chave de busca na tabela Filho ou Consulta Padrão
				cChave := CHB->CHB_CODPAR
				xVldECFTab( "C1H", cChave, 5,, @aLogErro, { "CFS", "CHB_CODPAR", nRecno } )
			EndIf

			CHB->( DBSkip() )

		EndDo
	EndIf

	//Atualiza o Status do Registro
	cStatus := Iif( Len( aLogErro ) > 0, "1", "0" )

	TAFAltStat( "CFS", cStatus )

Else
	aAdd( aLogErro, { "CFS_ID", "000017", "CFS", nRecno } ) //STR0017 - Registro já validado.
EndIf

//Não apresento o alert quando utilizo o Job para validar
If !lJob
	VldECFLog( aLogErro )
EndIf

Return( aLogErro )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAF331Valid

Funcionalidade para validação do campo.

@Return	lRet	- Indica se todas as condições foram respeitadas

@Author	Felipe C. Seolin
@Since		31/10/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAF331Valid()

Local cCampo	as character
Local aArea	as array
Local lRet		as logical

cCampo	:=	SubStr( ReadVar(), At( ">", ReadVar() ) + 1 )
aArea	:=	CFS->( GetArea() )
lRet	:=	.T.

If cCampo == "CFS_INDLCT"

	If FWFldGet( "CFS_INDLCT" ) == "3" //Carga Inicial
		CFS->( DBSetOrder( 3 ) )

		If CFS->( MsSeek( xFilial( "CFS" ) + "3" ) ) .and. CFS->CFS_ID <> FWFldGet( "CFS_ID" )
			Help( ,, "HELP",, STR0004, 1, 0 ) //"Já existe um lançamento do tipo 'Carga Inicial'. Não é permitido a existência de dois lançamentos deste tipo."
			lRet := .F.
		EndIf
	EndIf

EndIf

RestArea( aArea )

Return( lRet )