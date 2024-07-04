#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                             
#INCLUDE "TAFA170.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA169
Cadastro MVC de Unidades de Medida

@author Fabio V. Santana
@since 01/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA170()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Tipo da Operação Unidade Imobiliaria
oBrw:SetAlias( 'C41')
oBrw:SetMenuDef( 'TAFA170' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC do Tipo da Operação Unidade Imobiliaria

@author Fabio V. Santana
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA170" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC41 	:= 	FWFormStruct( 1, 'C41' )
Local oModel 	:= 	MPFormModel():New( 'TAFA170' )

oModel:AddFields('MODEL_C41', /*cOwner*/, oStruC41)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA170' )
Local 	oStruC41 	:= 	FWFormStruct( 2, 'C41' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C41', oStruC41, 'MODEL_C41' )

oView:EnableTitleView( 'VIEW_C41', STR0001 ) //Tipo da Operação Unidade Imobiliaria
oView:CreateHorizontalBox( 'FIELDSC41', 100 )
oView:SetOwnerView( 'VIEW_C41', 'FIELDSC41' )

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
	aAdd( aHeader, "C41_FILIAL" )
	aAdd( aHeader, "C41_ID" )
	aAdd( aHeader, "C41_CODIGO" )
	aAdd( aHeader, "C41_DESCRI" )
	aAdd( aHeader, "C41_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "VENDA A VISTA DE UNIDADE CONCLUIDA", "" } )
	aAdd( aBody, { "", "000002", "02", "VENDA A PRAZO DE UNIDADE CONCLUIDA", "" } )
	aAdd( aBody, { "", "000003", "03", "VENDA A VISTA DE UNIDADE EM CONSTRUCAO", "" } )
	aAdd( aBody, { "", "000004", "04", "VENDA A PRAZO DE UNIDADE EM CONSTRUCAO", "" } )
	aAdd( aBody, { "", "000005", "05", "OUTRAS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )