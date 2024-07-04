#INCLUDE "Protheus.CH"
#INCLUDE "FwMVCDef.CH"
#INCLUDE "TAFA395.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA395

Cadastro MVC de Tributos envolvidos no planejamento tributário

@Author Vitor Siqueira
@Since 09/09/2015
@Version 1.0

/*/
//------------------------------------------------------------------
Function TAFA395()

Local oBrw := FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Tributos envolvidos no planejamento tributário"
oBrw:SetAlias( "T26" )
oBrw:SetMenuDef( "TAFA395" )
T26->( DBSetOrder( 2 ) )
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@Author Vitor Siqueira
@Since 09/09/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return xFunMnuTAF( "TAFA395",,,, .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@Return oModel - Objeto do Modelo MVC

@Author Vitor Siqueira
@Since 09/09/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruT26 := FwFormStruct( 1, "T26" )
Local oModel   := MpFormModel():New( "TAFA395" )

oModel:AddFields( "MODEL_T26", /*cOwner*/, oStruT26 )
oModel:GetModel ( "MODEL_T26" ):SetPrimaryKey( { "T26_FILIAL", "T26_ID" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@Return oView - Objeto da View MVC

@Author Vitor Siqueira
@Since 09/09/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel( "TAFA395" )
Local oStruT26 := FwFormStruct( 2, "T26" )
Local oView    := FwFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_T26", oStruT26, "MODEL_T26" )
oView:EnableTitleView( "VIEW_T26", STR0001 ) //"Cadastro de Código de Conta Referencial"
oView:CreateHorizontalBox( "FIELDST26", 100 )
oView:SetOwnerView( "VIEW_T26", "FIELDST26" )

oStruT26:RemoveField( "T26_ID" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1005.05

If nVerEmp < nVerAtu
	aAdd( aHeader, "T26_FILIAL" )
	aAdd( aHeader, "T26_ID" )
	aAdd( aHeader, "T26_CODIGO" )
	aAdd( aHeader, "T26_DESCRI" )

	aAdd( aBody, { "", "a641c69b-e9d8-d09d-0a27-31b56e0cce2f", "01", "IRPF – Imposto sobre a Renda da Pessoa Física" } )
	aAdd( aBody, { "", "75766a80-82fc-c320-d5b9-553667ed1533", "02", "IRPJ – Imposto sobre a Renda da Pessoa Jurídica" } )
	aAdd( aBody, { "", "e4204eae-7d43-6474-29a3-e287e513ef94", "03", "CSLL – Contribuição Social sobre o Lucro Líquido" } )
	aAdd( aBody, { "", "58f89ac9-228c-fa72-08f9-2225b37abb2f", "04", "IRRF – Imposto de Renda Retido na Fonte" } )
	aAdd( aBody, { "", "0d2d9556-97d2-ad13-fb32-88807b0339f8", "05", "PIS/Cofins" } )
	aAdd( aBody, { "", "bb7608ec-807c-b99f-c11c-53195425d1a9", "06", "IOF – Imposto sobre Operações Financeiras" } )
	aAdd( aBody, { "", "26636e93-3ec5-1bbd-d330-df37784e9cc5", "07", "Imposto de Importação e Exportação" } )
	aAdd( aBody, { "", "fe1f5dde-7f2a-6ac5-ff64-13367f990eb6", "08", "Simples Nacional" } )
	aAdd( aBody, { "", "5cd2db22-688f-d0ea-7a84-5c1abf25c73c", "09", "Contribuição Previdenciária" } )
	aAdd( aBody, { "", "caaa3ff2-9bbb-2b81-809b-c76c02bf6226", "10", "Cide Combustíveis" } )
	aAdd( aBody, { "", "e5e53a0f-bdbc-ec93-4c5d-d0a4710d0090", "11", "IPI – Imposto sobre Produtos Industrializados" } )
	aAdd( aBody, { "", "1a499c0f-009e-b7b3-5318-6509dae36c49", "12", "Outras" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )