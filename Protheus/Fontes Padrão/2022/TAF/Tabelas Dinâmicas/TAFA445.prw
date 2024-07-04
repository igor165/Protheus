#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA445.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA445

Cadastro de Grupos da Forma de Tributação.

@Author	Felipe C. Seolin
@Since		29/06/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TAFA445()

Local oBrowse	as object

oBrowse	:=	FwMBrowse():New()

If TAFAlsInDic( "LEE" )
	oBrowse:SetDescription( STR0001 ) //"Cadastro de Grupos da Forma de Tributação"
	oBrowse:SetAlias( "LEE" )
	oBrowse:SetMenuDef( "TAFA445" )
	oBrowse:Activate()
Else
	Aviso( STR0002, TafAmbInvMsg(), { STR0003 }, 2 ) //##"Dicionário Incompatível" ##"Encerrar"
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Função genérica MVC com as opções de menu.

@Return	aRotina - Array com as opções de menu.

@Author	Felipe C. Seolin
@Since		29/06/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()
Return( xFunMnuTAF( "TAFA445" ) )

//---------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef

Função genérica MVC do modelo.

@Return	oModel - Objeto do modelo MVC

@Author	Felipe C. Seolin
@Since		29/06/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

Local oStruLEE	as object
Local oModel		as object

oStruLEE	:=	FWFormStruct( 1, "LEE" )
oModel		:=	MPFormModel():New( "TAFA445" )

oModel:AddFields( "MODEL_LEE", /*cOwner*/, oStruLEE )
oModel:GetModel( "MODEL_LEE" ):SetPrimaryKey( { "LEE_CODIGO", "LEE_VALIDA" } )

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Função genérica MVC da view.

@Return	oView - Objeto da view MVC

@Author	Felipe C. Seolin
@Since		29/06/2016
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oModel		as object
Local oStruLEE	as object
Local oView		as object

oModel		:=	FWLoadModel( "TAFA445" )
oStruLEE	:=	FWFormStruct( 2, "LEE" )
oView		:=	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( "VIEW_LEE", oStruLEE, "MODEL_LEE" )
oView:EnableTitleView( "VIEW_LEE", STR0001 ) //"Cadastro de Grupos da Forma de Tributação"

oView:CreateHorizontalBox( "FIELDSLEE", 100 )

oView:SetOwnerView( "VIEW_LEE", "FIELDSLEE" )

oStruLEE:RemoveField( "LEE_ID" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	- Versão corrente na empresa
			nVerAtu	- Versão atual ( passado como referência )

@Return	aRet		- Array com estrutura de campos e conteúdo da tabela

@Author	Felipe de Carvalho Seolin
@Since		29/06/2015
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
	aAdd( aHeader, "LEE_FILIAL" )
	aAdd( aHeader, "LEE_ID" )
	aAdd( aHeader, "LEE_CODIGO" )
	aAdd( aHeader, "LEE_DESCRI" )
	aAdd( aHeader, "LEE_VALIDA" )

	aAdd( aBody, { "", "32349dc6-68e7-b433-c889-d7e6a6635c87", "01", "Resultado Contábil - Operacional", "" } )
	aAdd( aBody, { "", "85eabbca-03b7-1bd9-4f74-e2cf83b8c18a", "02", "Resultado Contábil - Não operacional", "" } )
	aAdd( aBody, { "", "a35d199b-d87b-ff85-704e-88269348b317", "03", "Receita Bruta - Alíquota 1", "" } )
	aAdd( aBody, { "", "c0ee6c2d-4ead-6913-4285-95e7524d49de", "04", "Receita Bruta - Alíquota 2", "" } )
	aAdd( aBody, { "", "e59666c9-7a3b-f6d0-6341-b5c9a15cc085", "05", "Receita Bruta - Alíquota 3", "" } )
	aAdd( aBody, { "", "814ca1ac-f03a-3034-b694-58373ba01770", "06", "Receita Bruta - Alíquota 4", "" } )
	aAdd( aBody, { "", "8f573cdc-6d09-da38-1436-971892f8b85a", "07", "Demais Receitas", "" } )
	aAdd( aBody, { "", "4965aeb0-4c7d-9915-b546-df02e35b4d61", "08", "Base de Cálculo", "" } )
	aAdd( aBody, { "", "dc804df5-b0aa-4f41-050e-d069593b65d6", "09", "Adições do Lucro", "" } )
	aAdd( aBody, { "", "4c35b281-b4d7-8c23-29e6-c58da6e8bffc", "10", "Adições por Doação", "" } )
	aAdd( aBody, { "", "8430d84c-a63d-e2d8-d5df-30f15452c12d", "11", "Exclusões do Lucro", "" } )
	aAdd( aBody, { "", "f98e1145-93a5-f960-af65-dfccfb42cef5", "12", "Exclusões da Receita", "" } )
	aAdd( aBody, { "", "3ab05bce-92c8-be84-3c5b-a8a85e249e6c", "13", "Compensação de Prejuízo", "" } )
	aAdd( aBody, { "", "82322a43-4de8-3f4b-8c22-d24adbfbaf69", "14", "Deduções do Tributo", "" } )
	aAdd( aBody, { "", "bf2f283a-bf76-0bd0-31fe-660941196b47", "15", "Compensação do Tributo", "" } )
	aAdd( aBody, { "", "e977eded-4eaa-066e-eea2-a51f7a801297", "16", "Adicionais do Tributo", "" } )
	aAdd( aBody, { "", "225a7d6d-c724-2215-ceaa-73073d6e9424", "17", "Receita Líquida p/Atividade", "" } )
	aAdd( aBody, { "", "990dd1e9-9eb4-0d08-d173-545386b144b5", "18", "Lucro da Exploração", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )