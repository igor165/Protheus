#Include "Protheus.CH"
#Include "FwMVCDef.CH"
#Include "TAFA371.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} TAFA371

Cadastro de Historico Padronizado(ECD I075).

@Author Felipe C. Seolin
@Since 04/11/2014
@Version 1.0

*/
//-------------------------------------------------------------------
Function TAFA371()

Local oBrw := FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Histórico Padronizado"
oBrw:SetAlias( "CHC" )
oBrw:SetMenuDef( "TAFA371" )
CHC->( DBSetOrder( 2 ) )
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu.

@Return aRotina - Array com as opcoes de Menu.

@Author Felipe C. Seolin
@Since 04/11/2014
@Version 1.0

*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}
Local aFuncao := { { "", "TAF371Vld", "2" } }

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action "VIEWDEF.TAFA371" OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA371",, aFuncao )
EndIf

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef

Funcao generica MVC do model.

@Return oModel - Objeto da Model MVC

@Author Felipe C. Seolin
@Since 04/11/2014
@Version 1.0

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCHC := FwFormStruct( 1, "CHC" )
Local oModel   := Nil

oModel := MpFormModel():New( "TAFA371",,, { |oModel| SaveModel( oModel ) } )

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStruCHC:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
EndIf

oModel:AddFields( "MODEL_CHC", /*cOwner*/, oStruCHC )
oModel:GetModel( "MODEL_CHC" ):SetPrimaryKey( { "CHC_CODIGO" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View.

@Return oView - Objeto da View MVC

@Author Felipe C. Seolin
@Since 04/11/2014
@Version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   :=  FwLoadModel( "TAFA371" )
Local oStruCHC :=  FwFormStruct( 2, "CHC" )
Local oView    :=  FwFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_CHC", oStruCHC, "MODEL_CHC" )

oView:EnableTitleView( "VIEW_CHC", STR0001 ) //"Histórico Padronizado"
oView:CreateHorizontalBox( "FIELDSCHC", 100 )
oView:SetOwnerView( "VIEW_CHC", "FIELDSCHC" )

oStruCHC:RemoveField( "CHC_ID" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel

Gravacao dos dados, executado no momento da confirmacao do modelo.

@Param oModel - Modelo de dados

@Return .T.

@Author Felipe C. Seolin
@Since 04/11/2014
@Version 1.0

/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
		TAFAltStat( "CHC", " " )
	EndIf

	FwFormCommit( oModel )

End Transaction

Return( .T. )

//-------------------------------------------------------------------
/*{Protheus.doc} TAF371Vld

Validacao dos registros de acordo com as regras de integridade e
regras do manual do ECD.

@Param cAlias - Alias da tabela
       nRecno - Recno do registro corrente
       nOpc   - Operacao a ser realizada
       lJob   - Informa se foi chamado por Job

@Return aLogErro - Array com o log de erros da validacao

@Author Felipe C. Seolin
@Since 04/11/2014
@Version 1.0

*/
//-------------------------------------------------------------------
Function TAF371Vld( cAlias, nRecno, nOpc, lJob )

Local aLogErro   := {}
Local aDadosUtil := {}
Local cStatus    := ""

Default lJob := .F.

If CHC->CHC_STATUS $ ( " 1" )

	If Empty( CHC->CHC_CODIGO )
		aAdd( aLogErro, { "CHC_CODIGO", "000001", "CHC", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	EndIf

	If Empty( CHC->CHC_DESCRI )
		aAdd( aLogErro, { "CHC_DESCRI", "000001", "CHC", nRecno } ) //STR0001 - "Campo inconsistente ou vazio."
	EndIf

	aDadosUtil := { "CHC_CODIGO" }
	xVldECFReg( "CHC", "REGRA_REGISTRO_DUPLICADO", @aLogErro, aDadosUtil,, 1 )

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif( Len( aLogErro ) > 0, "1", "0" )
	TAFAltStat( "CHC", cStatus )

Else

	aAdd( aLogErro, { "CHC_ID", "000017", "CHC", nRecno } ) //STR0017 - Registro já validado.

EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	VldECFLog( aLogErro )
EndIf

Return( aLogErro ) 