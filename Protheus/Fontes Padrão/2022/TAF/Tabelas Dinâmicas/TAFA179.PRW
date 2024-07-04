#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                            
#INCLUDE "TAFA179.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA179
Cadastro MVC de ECF

@author Fabio V. Santana
@since 12/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA179()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //"Motivo do Inventario"
oBrw:SetAlias( 'C5D')
oBrw:SetMenuDef( 'TAFA179' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA179" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC5D 	:= 	FWFormStruct( 1, 'C5D' )
Local oModel 	:= 	MPFormModel():New( 'TAFA179' )

oModel:AddFields('MODEL_C5D', /*cOwner*/, oStruC5D)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA179' )
Local 	oStruC5D 	:= 	FWFormStruct( 2, 'C5D' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C5D', oStruC5D, 'MODEL_C5D' )

oView:EnableTitleView( 'VIEW_C5D', STR0001 ) //"Motivo do Inventario"
oView:CreateHorizontalBox( 'FIELDSC5D', 100 )
oView:SetOwnerView( 'VIEW_C5D', 'FIELDSC5D' )

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
	aAdd( aHeader, "C5D_FILIAL" )
	aAdd( aHeader, "C5D_ID" )
	aAdd( aHeader, "C5D_CODIGO" )
	aAdd( aHeader, "C5D_DESCRI" )
	aAdd( aHeader, "C5D_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "NO FINAL NO PERIODO", "" } )
	aAdd( aBody, { "", "000002", "02", "NA MUDANCA DE FORMA DE TRIBUTACAO DA MERCADORIA (ICMS)", "" } )
	aAdd( aBody, { "", "000003", "03", "NA SOLICITACAO DA BAIXA CADASTRAL, PARALISACAO TEMPORARIA E OUTRAS SITUACOES", "" } )
	aAdd( aBody, { "", "000004", "04", "NA ALTERACAO DE REGIME DE PAGAMENTO – CONDICAO DO CONTRIBUINTE", "" } )
	aAdd( aBody, { "", "000005", "05", "POR DETERMINACAO DOS FISCOS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )