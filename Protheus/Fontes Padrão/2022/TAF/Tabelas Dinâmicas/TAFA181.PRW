#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                                       
#INCLUDE "TAFA181.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA181
Cadastro MVC de Detalhamento da Apuração da Contribuição

@author Fabio V. Santana
@since 21/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA181()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Cadastro de Detalhamento da Apuração da Contribuição
oBrw:SetAlias( 'C5P')
oBrw:SetMenuDef( 'TAFA181' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V. Santana
@since 21/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA181" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 21/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC5P 	:= 	FWFormStruct( 1, 'C5P' )
Local oModel 	:= 	MPFormModel():New( 'TAFA181' )

oModel:AddFields('MODEL_C5P', /*cOwner*/, oStruC5P)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 21/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA181' )
Local 	oStruC5P 	:= 	FWFormStruct( 2, 'C5P' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C5P', oStruC5P, 'MODEL_C5P' )

oView:EnableTitleView( 'VIEW_C5P', STR0001 ) //Cadastro de Detalhamento da Apuração da Contribuição
oView:CreateHorizontalBox( 'FIELDSC5P', 100 )
oView:SetOwnerView( 'VIEW_C5P', 'FIELDSC5P' )

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
	aAdd( aHeader, "C5P_FILIAL" )
	aAdd( aHeader, "C5P_ID" )
	aAdd( aHeader, "C5P_CODIGO" )
	aAdd( aHeader, "C5P_DESCRI" )
	aAdd( aHeader, "C5P_VALIDA" )

	aAdd( aBody, { "", "0000000001", "00000001", "DETALHAMENTO POR DOCUMENTO FISCAL", "" } )
	aAdd( aBody, { "", "0000000002", "00000002", "DETALHAMENTO POR ITEM/PRODUTO/SERVICO", "" } )
	aAdd( aBody, { "", "0000000003", "00000003", "DETALHAMENTO POR NCM", "" } )
	aAdd( aBody, { "", "0000000004", "00000004", "DETALHAMENTO POR CLIENTE", "" } )
	aAdd( aBody, { "", "0000000005", "00000999", "DETALHAMENTO POR OUTROS CRITERIOS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )