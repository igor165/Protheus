#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA431.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA431

Cadastro de Forma de Tributação CSLL e IRPJ.

@Author	David Costa
@Since		16/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFA431()

Local oBrw	as object

oBrw	:=	FWmBrowse():New()

If TAFAlsInDic( "T0K" )
	oBrw:SetDescription( STR0001 ) //"Cadastro de Forma de Tributação CSLL e IRPJ"
	oBrw:SetAlias( "T0K" )
	oBrw:SetMenuDef( "TAFA431" )

	T0K->( DBSetOrder( 1 ) )

	oBrw:Activate()
Else
	Aviso( STR0002, TafAmbInvMsg(), { STR0003 }, 2 ) //##"Dicionário Incompatível" ##"Encerrar"
EndIf


Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Função genérica MVC com as opções de menu.

@Author	David Costa
@Since		16/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return xFunMnuTAF( "TAFA431",,,, .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Função genérica MVC do Model.

@Return	oModel - Objeto do modelo MVC

@Author	David Costa
@Since		16/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruT0K	as object
Local oModel		as object

oStruT0K	:=	FWFormStruct( 1, "T0K" )
oModel		:=	MPFormModel():New( "TAFA431" )

oModel:AddFields( "MODEL_T0K", /*cOwner*/, oStruT0K )
oModel:GetModel( "MODEL_T0K" ):SetPrimaryKey( { "T0K_CODIGO" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Função genérica MVC da View.

@Return	oView - Objeto da View MVC

@Author	David Costa
@Since		16/03/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:=	FWLoadModel( "TAFA431" )
Local oStruT0K	:=	FWFormStruct( 2, "T0K" )
Local oView		:=	FWFormView():New()

oStruT0K:RemoveField( "T0K_ID" )

oView:SetModel( oModel )
oView:AddField( "VIEW_T0K", oStruT0K, "MODEL_T0K" )

oView:EnableTitleView( "VIEW_T0K", STR0001 ) //"Cadastro de Forma de Tributação CSLL e IRPJ"
oView:CreateHorizontalBox( "FIELDST0K", 100 )
oView:SetOwnerView( "VIEW_T0K", "FIELDST0K" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	David Costa
@Since		16/03/2016
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
	aAdd( aHeader, "T0K_FILIAL" )
	aAdd( aHeader, "T0K_ID" )
	aAdd( aHeader, "T0K_CODIGO" )
	aAdd( aHeader, "T0K_DESCRI" )

	aAdd( aBody, { "", "712544ba-01ad-233f-0eeb-a085bd6cc674", "000001", "Lucro Real" } )
	aAdd( aBody, { "", "fa7ad19c-3c80-bc87-2a3c-1c857504b541", "000002", "Lucro Real - Estimativa por levantamento de balanço" } )
	aAdd( aBody, { "", "141e4ffa-0197-97d0-af7d-80c1535009ed", "000003", "Lucro Real - Estimativa por Receita Bruta" } )
	aAdd( aBody, { "", "ebf125bc-3140-9c7b-1e01-de4a61fd16e3", "000004", "Lucro Real - Atividade Rural" } )
	aAdd( aBody, { "", "1a46ceda-ffae-fa0f-0d9b-693dcb256849", "000005", "Lucro Real - Lucro da exploração" } )
	aAdd( aBody, { "", "39ea34b9-f799-a15a-e781-fb6da7951b5b", "000006", "Lucro Presumido" } )
	aAdd( aBody, { "", "fea9cf8d-e2e8-d5ea-5fa1-fe59337344ea", "000007", "Lucro Arbitrado" } )
	aAdd( aBody, { "", "254712df-e187-afc0-717b-7cb8b5e16f61", "000008", "Imune" } )
	aAdd( aBody, { "", "3141310b-391c-0d02-8391-6892d2d22a27", "000009", "Isenta" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )