#INCLUDE "PROTHEUS.CH"
#INCLUDE "TAFA443.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA443

Cadastro de Eventos Especiais.

@Author	David Costa
@Since		04/07/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFA443()

Local oBrw	as object

oBrw	:=	FWmBrowse():New()

If TAFAlsInDic( "CWU" )
	If VldFilEven()
		oBrw:SetDescription( STR0001 ) //"Cadastro de Eventos Especiais"
		oBrw:SetAlias( "CWU" )
		oBrw:SetMenuDef( "TAFA443" )
		oBrw:SetCacheView( .F. )

		CWU->( DBSetOrder( 1 ) )

		oBrw:Activate()
	EndIf
Else
	Aviso( STR0003, TafAmbInvMsg(), { STR0004 }, 2 ) //##"Dicionário Incompatível" ##"Encerrar"
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} VldFilEven

Verifica se o cadastro pode ser alterado/incluído para a filial selecionada.

@Return	lRet

@Author	David Costa
@Since		12/07/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function VldFilEven()

Local cIdFilial	as character
Local lRet			as logical

cIdFilial	:=	xFunCh2ID( cFilAnt, "C1E", 3,,,, .T. )
lRet		:=	.F.

DBSelectArea( "C1E" )
C1E->( DBSetOrder( 3 ) )
C1E->( MsSeek( xFilial( "C1E" ) + cFilAnt ) )
If FilialSCP( cIdFilial ) .or. C1E->C1E_MATRIZ
	lRet := .T.
Else
	Help( ,, "HELP",, STR0002, 1, 0 ) //"Este cadastro só poderá ser acessado por uma Filial Matriz ou Filial SCP."
	lRet := .F.
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Função genérica MVC com as opções de menu.

@Author	David Costa
@Since		04/07/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return( xFunMnuTAF( "TAFA443",,,, .T. ) )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Função genérica MVC do Model.

@Return	oModel	- Objeto do modelo MVC

@Author	David Costa
@Since		04/07/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCWU	as object
Local oModel		as object

oStruCWU	:=	FWFormStruct( 1, "CWU" )
oModel		:=	MPFormModel():New( "TAFA433" )

oModel:AddFields( "MODEL_CWU", /*cOwner*/, oStruCWU )
oModel:GetModel( "MODEL_CWU" ):SetPrimaryKey( { "CWU_DATA" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Função genérica MVC da View.

@Return	oView	- Objeto da view MVC

@Author	David Costa
@Since		04/07/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		as object
Local oStruCWU	as object
Local oView		as object

oModel		:=	FWLoadModel( "TAFA443" )
oStruCWU	:=	FWFormStruct( 2, "CWU" )
oView		:=	FWFormView():New()

If VldFilEven()
	oView:SetModel( oModel )

	oView:AddField( "VIEW_CWU", oStruCWU, "MODEL_CWU" )
	oView:EnableTitleView( "VIEW_CWU", STR0001 ) //"Cadastro de Eventos Especiais"

	oView:CreateHorizontalBox( "FIELDSCWU", 100 )

	oView:SetOwnerView( "VIEW_CWU", "FIELDSCWU" )

	oStruCWU:RemoveField( "CWU_ID" )
Else
	oView := Nil
EndIf

Return( oView )