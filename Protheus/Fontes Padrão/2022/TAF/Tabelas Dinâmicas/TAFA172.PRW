#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                                                
#INCLUDE "TAFA172.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA172
Cadastro MVC dos Tipos de Creditos

@author Rodrigo Aguilar
@since 02/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA172()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001)	//"Cadastro dos Tipos de Creditos "
oBrw:SetAlias( 'C4D')
oBrw:SetMenuDef( 'TAFA172' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Rodrigo Aguilar
@since 02/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA172" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 02/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC4D 	:= 	FWFormStruct( 1, 'C4D' )
Local oModel 	:= 	MPFormModel():New( 'TAFA172' )

oModel:AddFields('MODEL_C4D', /*cOwner*/, oStruC4D)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 02/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA172' )
Local 	oStruC4D 	:= 	FWFormStruct( 2, 'C4D' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C4D', oStruC4D, 'MODEL_C4D' )

oView:EnableTitleView( 'VIEW_C4D', STR0001 )	//"Cadastro dos Tipos de Creditos "
oView:CreateHorizontalBox( 'FIELDSC4D', 100 )
oView:SetOwnerView( 'VIEW_C4D', 'FIELDSC4D' )

Return oView

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

nVerAtu := 1003

If nVerEmp < nVerAtu
	aAdd( aHeader, "C4D_FILIAL" )
	aAdd( aHeader, "C4D_ID" )
	aAdd( aHeader, "C4D_CODIGO" )
	aAdd( aHeader, "C4D_DESCRI" )
	aAdd( aHeader, "C4D_VALIDA" )

	aAdd( aBody, { "", "000001", "101", "CREDITO VINCULADO A RECEITA TRIBUTADA NO MERCADO INTERNO – ALIQUOTA BASICA", "" } )
	aAdd( aBody, { "", "000002", "102", "CREDITO VINCULADO A RECEITA TRIBUTADA NO MERCADO INTERNO – ALIQUOTAS DIFERENCIADAS", "" } )
	aAdd( aBody, { "", "000003", "103", "CREDITO VINCULADO A RECEITA TRIBUTADA NO MERCADO INTERNO – ALIQUOTA POR UNIDADE DE PRODUTO", "" } )
	aAdd( aBody, { "", "000004", "104", "CREDITO VINCULADO A RECEITA TRIBUTADA NO MERCADO INTERNO – ESTOQUE DE ABERTURA", "" } )
	aAdd( aBody, { "", "000005", "105", "CREDITO VINCULADO A RECEITA TRIBUTADA NO MERCADO INTERNO – AQUISICAO EMBALAGENS PARA REVENDA", "" } )
	aAdd( aBody, { "", "000006", "106", "CREDITO VINCULADO A RECEITA TRIBUTADA NO MERCADO INTERNO – PRESUMIDO DA AGROINDUSTRIA", "" } )
	aAdd( aBody, { "", "000007", "107", "CREDITO VINCULADO A RECEITA TRIBUTADA NO MERCADO INTERNO – OUTROS CREDITOS PRESUMIDOS", "" } )
	aAdd( aBody, { "", "000008", "108", "CREDITO VINCULADO A RECEITA TRIBUTADA NO MERCADO INTERNO – IMPORTACAO", "" } )
	aAdd( aBody, { "", "000009", "109", "CREDITO VINCULADO A RECEITA TRIBUTADA NO MERCADO INTERNO – ATIVIDADE IMOBILIARIA", "" } )
	aAdd( aBody, { "", "000010", "199", "CREDITO VINCULADO A RECEITA TRIBUTADA NO MERCADO INTERNO – OUTROS", "" } )
	aAdd( aBody, { "", "000011", "201", "CREDITO VINCULADO A RECEITA NAO TRIBUTADA NO MERCADO INTERNO – ALIQUOTA BASICA", "" } )
	aAdd( aBody, { "", "000012", "202", "CREDITO VINCULADO A RECEITA NAO TRIBUTADA NO MERCADO INTERNO – ALIQUOTAS DIFERENCIADAS", "" } )
	aAdd( aBody, { "", "000013", "203", "CREDITO VINCULADO A RECEITA NAO TRIBUTADA NO MERCADO INTERNO – ALIQUOTA POR UNIDADE DE PRODUTO", "" } )
	aAdd( aBody, { "", "000014", "204", "CREDITO VINCULADO A RECEITA NAO TRIBUTADA NO MERCADO INTERNO – ESTOQUE DE ABERTURA", "" } )
	aAdd( aBody, { "", "000015", "205", "CREDITO VINCULADO A RECEITA NAO TRIBUTADA NO MERCADO INTERNO – AQUISICAO EMBALAGENS PARA REVENDA", "" } )
	aAdd( aBody, { "", "000016", "206", "CREDITO VINCULADO A RECEITA NAO TRIBUTADA NO MERCADO INTERNO – PRESUMIDO DA AGROINDUSTRIA", "" } )
	aAdd( aBody, { "", "000017", "207", "CREDITO VINCULADO A RECEITA NAO TRIBUTADA NO MERCADO INTERNO – OUTROS CREDITOS PRESUMIDOS", "" } )
	aAdd( aBody, { "", "000018", "208", "CREDITO VINCULADO A RECEITA NAO TRIBUTADA NO MERCADO INTERNO – IMPORTACAO", "" } )
	aAdd( aBody, { "", "000019", "299", "CREDITO VINCULADO A RECEITA NAO TRIBUTADA NO MERCADO INTERNO – OUTROS", "" } )
	aAdd( aBody, { "", "000020", "301", "CREDITO VINCULADO A RECEITA DE EXPORTACAO – ALIQUOTA BASICA", "" } )
	aAdd( aBody, { "", "000021", "302", "CREDITO VINCULADO A RECEITA DE EXPORTACAO – ALIQUOTAS DIFERENCIADAS", "" } )
	aAdd( aBody, { "", "000022", "303", "CREDITO VINCULADO A RECEITA DE EXPORTACAO – ALIQUOTA POR UNIDADE DE PRODUTO", "" } )
	aAdd( aBody, { "", "000023", "304", "CREDITO VINCULADO A RECEITA DE EXPORTACAO – ESTOQUE DE ABERTURA", "" } )
	aAdd( aBody, { "", "000024", "305", "CREDITO VINCULADO A RECEITA DE EXPORTACAO – AQUISICAO EMBALAGENS PARA REVENDA", "" } )
	aAdd( aBody, { "", "000025", "306", "CREDITO VINCULADO A RECEITA DE EXPORTACAO – PRESUMIDO DA AGROINDUSTRIA", "" } )
	aAdd( aBody, { "", "000026", "307", "CREDITO VINCULADO A RECEITA DE EXPORTACAO – OUTROS CREDITOS PRESUMIDOS", "" } )
	aAdd( aBody, { "", "000027", "308", "CREDITO VINCULADO A RECEITA DE EXPORTACAO – IMPORTACAO", "" } )
	aAdd( aBody, { "", "000028", "399", "CREDITO VINCULADO A RECEITA DE EXPORTACAO – OUTROS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )