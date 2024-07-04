#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA432.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA432

Cadastro de Aplica��o do Limite de Dedu��o/Compensa��o.

@Author	David Costa
@Since		17/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFA432()

Local oBrw	as object

oBrw	:=	FWmBrowse():New()

If TAFAlsInDic( "T0L" )
	oBrw:SetDescription( STR0001 ) //"Cadastro de Aplica��o do Limite de Dedu��o/Compensa��o"
	oBrw:SetAlias( "T0L" )
	oBrw:SetMenuDef( "TAFA432" )

	T0L->( DBSetOrder( 1 ) )

	oBrw:Activate()
Else
	Aviso( STR0002, TafAmbInvMsg(), { STR0003 }, 2 ) //##"Dicion�rio Incompat�vel" ##"Encerrar"
EndIf


Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Fun��o gen�rica MVC com as op��es de menu.

@Author	David Costa
@Since		17/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return xFunMnuTAF( "TAFA432",,,, .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Fun��o gen�rica MVC do Model.

@Return	oModel - Objeto do Modelo MVC

@Author	David Costa
@Since		17/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruT0L	as object
Local oModel		as object

oStruT0L	:=	FWFormStruct( 1, "T0L" )
oModel		:=	MPFormModel():New( "TAFA432" )

oModel:AddFields( "MODEL_T0L", /*cOwner*/, oStruT0L )
oModel:GetModel( "MODEL_T0L" ):SetPrimaryKey( { "T0L_CODIGO" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Fun��o gen�rica MVC da View.

@Return	oView - Objeto da View MVC

@Author	David Costa
@Since		17/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		as object
Local oStruT0L	as object
Local oView		as object

oModel		:=	FWLoadModel( "TAFA432" )
oStruT0L	:=	FWFormStruct( 2, "T0L" )
oView		:=	FWFormView():New()

oStruT0L:RemoveField( "T0L_ID" )

oView:SetModel( oModel )
oView:AddField( "VIEW_T0L", oStruT0L, "MODEL_T0L" )

oView:EnableTitleView( "VIEW_T0L", STR0001 ) //"Cadastro de Aplica��o do Limite de Dedu��o/Compensa��o"
oView:CreateHorizontalBox( "FIELDST0L", 100 )
oView:SetOwnerView( "VIEW_T0L", "FIELDST0L" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@Author	David Costa
@Since		17/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	as array
Local aBody	as array
Local aRet		as array

aHeader	:=	{}
aBody		:=	{}
aRet		:=	{}

nVerAtu := 1013

If nVerEmp < nVerAtu
	aAdd( aHeader, "T0L_FILIAL" )
	aAdd( aHeader, "T0L_ID" )
	aAdd( aHeader, "T0L_CODIGO" )
	aAdd( aHeader, "T0L_DESCRI" )

	aAdd( aBody, { "", "f79bf405-7bee-aaee-40f3-4d25bbb94108", "000001", "Resultado Operacional" } )
	aAdd( aBody, { "", "390b6b04-3eb3-d6bc-4864-806b791ede52", "000002", "Resultado N�o Operacional" } )
	aAdd( aBody, { "", "5c64fa63-fc44-f772-30dd-30afb717c22a", "000003", "Resultado do Exerc�cio" } )
	aAdd( aBody, { "", "9c11f48d-a22f-0693-c2ee-24614cbdf64d", "000004", "Lucro Real antes da Compensa��o do Preju�zo" } )
	aAdd( aBody, { "", "b1b8eabc-c92f-c5f8-7cf2-6348b885cfac", "000005", "Lucro Real" } )
	aAdd( aBody, { "", "c1a96829-a6b9-8d97-e8c5-18534737595f", "000006", "Imposto apurado antes do adicional (BC * al�quota do tributo)" } )
	
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )