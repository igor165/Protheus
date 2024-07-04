#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA036.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA036
Cadastro MVC - Cadastro de Tipo de Receita

@author Mauro A. Goncalves
@since 12/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA036()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Tipo de Receita
oBrw:SetAlias( 'C10')
oBrw:SetMenuDef( 'TAFA036' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA036" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC10 	:= 	FWFormStruct( 1, 'C10' )
Local oModel 	:= 	MPFormModel():New( 'TAFA036' )

oModel:AddFields('MODEL_C10', /*cOwner*/, oStruC10)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA036' )
Local 	oStruC10 	:= 	FWFormStruct( 2, 'C10' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C10', oStruC10, 'MODEL_C10' )

oView:EnableTitleView( 'VIEW_C10', STR0001 ) //Cadastro de Tipo de Receita
oView:CreateHorizontalBox( 'FIELDSC10', 100 )
oView:SetOwnerView( 'VIEW_C10', 'FIELDSC10' )

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
	aAdd( aHeader, "C10_FILIAL" )
	aAdd( aHeader, "C10_ID" )
	aAdd( aHeader, "C10_CODIGO" )
	aAdd( aHeader, "C10_DESCRI" )
	aAdd( aHeader, "C10_VALIDA" )

	aAdd( aBody, { "", "000001", "0", "RECEITA PROPRIA - SERVICOS PRESTADOS", "" } )
	aAdd( aBody, { "", "000002", "1", "RECEITA PROPRIA - COBRANCA DE DEBITOS", "" } )
	aAdd( aBody, { "", "000003", "2", "RECEITA PROPRIA - VENDA DE SERVICO PRE-PAGO – FATURAMENTO DE PERIODOS ANTERIORES", "" } )
	aAdd( aBody, { "", "000004", "3", "RECEITA PROPRIA - VENDA DE SERVICO PRE-PAGO – FATURAMENTO NO PERIODO", "" } )
	aAdd( aBody, { "", "000005", "4", "OUTRAS RECEITAS PROPRIAS DE SERVICOS DE COMUNICACAO E TELECOMUNICACAO", "" } )
	aAdd( aBody, { "", "000006", "5", "RECEITA PROPRIA - CO-FATURAMENTO", "" } )
	aAdd( aBody, { "", "000007", "6", "RECEITA PROPRIA – SERVICOS A FATURAR EM PERIODO FUTURO", "" } )
	aAdd( aBody, { "", "000008", "7", "OUTRAS RECEITAS PROPRIAS DE NATUREZA NAO-CUMULATIVA", "" } )
	aAdd( aBody, { "", "000009", "8", "OUTRAS RECEITAS DE TERCEIROS", "" } )
	aAdd( aBody, { "", "000010", "9", "OUTRAS RECEITAS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )