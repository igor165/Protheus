#Include "Protheus.CH"
#Include "FWMVCDef.CH"
#Include "TAFA394.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA394

Cadastro de Informa��es de Per�odos Anteriores.

@Param 

@Return

@Author	Felipe C. Seolin
@Since		21/09/2015
@Version	1.0
/*/                                                                                                                                          
//------------------------------------------------------------------
Function TAFA394()

Local oBrw	:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Informa��es de Per�odos Anteriores."
oBrw:SetAlias( "T29" )
oBrw:SetMenuDef( "TAFA394" )
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Fun��o gen�rica MVC com as op��es de menu.

@Param 

@Return	aRotina - Array com as op��es de Menu

@Author	Felipe C. Seolin
@Since		21/09/2015
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	:=	{}
Local aFuncao	:=	{ { "", "TAF394Vld", "2" } }

aRotina := xFunMnuTAF( "TAFA394",, aFuncao )

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Fun��o gen�rica MVC do Model.

@Param 

@Return	oModel - Objeto da Model MVC

@Author	Felipe C. Seolin
@Since		21/09/2015
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStructT29	:=	FWFormStruct( 1, "T29" )
Local oModel		:=	MPFormModel():New( "TAFA394",,, { |oModel| SaveModel( oModel ) } )

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStructT29:SetProperty( "*", MODEL_FIELD_VALID, { || lVldModel } )
EndIf

oModel:AddFields( "MODEL_T29", /*cOwner*/, oStructT29 )
oModel:GetModel( "MODEL_T29" ):SetPrimaryKey( { "T29_PERIOD", "T29_DTLUCL" } )

oModel:GetModel( "MODEL_T29" ):SetPrimaryKey( { "T29_ID" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Fun��o gen�rica MVC da View.

@Param 

@Return	oView - Objeto da View MVC

@Author	Felipe C. Seolin
@Since		21/09/2015
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:=	FWLoadModel( "TAFA394" )
Local oStructT29	:=	FWFormStruct( 2, "T29" )
Local oView		:=	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( "VIEW_T29", oStructT29, "MODEL_T29" )
oView:EnableTitleView( "VIEW_T29", STR0001 ) //"Informa��es de Per�odos Anteriores."

oView:CreateHorizontalBox( "FIELDST29", 100 )

oView:SetOwnerView( "VIEW_T29", "FIELDST29" )

oStructT29:RemoveField( "T29_ID" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel

Grava��o dos dados, executado no momento da confirma��o do modelo.

@Param		oModel - Objeto da Model MVC

@Return	.T.

@Author	Felipe C. Seolin
@Since		21/09/2015
@Version	1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation	:=	oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
		TAFAltStat( "T29", " " )
	EndIf

	FWFormCommit( oModel )

End Transaction

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF394Vld

Valida��o dos registros de acordo com as regras de integridade e
regras do manual da ECF.

@Param		cAlias	-	Alias da tabela
			nRecno	-	Recno do registro corrente
			nOpc	-	Opera��o a ser realizada
			lJob	-	Indica se foi chamado por Job

@Return	aLogErro - Array com o log de erros da valida��o

@Author	Felipe C. Seolin
@Since		21/09/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAF394Vld( cAlias, nRecno, nOpc, lJob )

Local cStatus		:=	""
Local cPerIni		:=	""
Local aLogErro	:=	{}

Default lJob	:=	.F.

If T29->T29_STATUS $ ( " 1" )

	If TAFSeekPer( DToS( T29->T29_PERIOD ), DToS( T29->T29_PERIOD ) )
		cPerIni := DToS( CHD->CHD_PERINI )
	EndIf

	If Empty( T29->T29_PERIOD )
		aAdd( aLogErro, { "T27_PERIOD", "000003", "T29", nRecno } ) //STR0003 - "Data inconsistente ou vazia."
	EndIf

	If Empty( T29->T29_DTLUCL )
		aAdd( aLogErro, { "T27_DTINAT", "000003", "T29", nRecno } ) //STR0003 - "Data inconsistente ou vazia."
	EndIf

	//REGRA_MENOR_DT_INI_ESC
	//Regra do PVA 1.0.7 diverge do Manual de Orienta��o de 31/08/2015.
	//De acordo com Consultoria Tribut�ria, devemos seguir o PVA.
	If DToS( T29->T29_DTLUCL ) >= cPerIni
		aAdd( aLogErro, { "T29_DTLUCL", "000247", "T29", nRecno } ) //STR0247 - "O campo 'Data Final Apura��o Lucro' deve ser menor que o campo 'Per�odo Inicial' da Escritura��o( TAFA372 - Par�metros de Abertura ECF )."
	EndIf

	//Atualizo o Status do Registro
	cStatus := Iif( Len( aLogErro ) > 0, "1", "0" )
	TAFAltStat( "T29", cStatus )

Else

	If !lJob
		aAdd( aLogErro, { "T29_ID", "000017", "T29", nRecno } ) //STR0017 - Registro j� validado.
	EndIf

EndIf

//N�o apresento o alert quando utilizo o JOB para validar
If !lJob
	VldECFLog( aLogErro )
EndIf

Return( aLogErro )