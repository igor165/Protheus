#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA033.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA033
Cadastro MVC - Cadastro de Posse de Mercadoria

@author Mauro A. Goncalves
@since 12/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA033()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Posse de Mercadoria
oBrw:SetAlias( 'C0Z')
oBrw:SetMenuDef( 'TAFA033' )
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
Return XFUNMnuTAF( "TAFA033" )
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
Local oStruC0Z 	:= 	FWFormStruct( 1, 'C0Z' )
Local oModel 	:= 	MPFormModel():New( 'TAFA033' )

oModel:AddFields('MODEL_C0Z', /*cOwner*/, oStruC0Z)

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA033' )
Local 	oStruC0Z 	:= 	FWFormStruct( 2, 'C0Z' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0Z', oStruC0Z, 'MODEL_C0Z' )

oView:EnableTitleView( 'VIEW_C0Z', STR0001 ) //Cadastro de Posse de Mercadoria
oView:CreateHorizontalBox( 'FIELDSC0Z', 100 )
oView:SetOwnerView( 'VIEW_C0Z', 'FIELDSC0Z' )

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
	aAdd( aHeader, "C0Z_FILIAL" )
	aAdd( aHeader, "C0Z_ID" )
	aAdd( aHeader, "C0Z_CODIGO" )
	aAdd( aHeader, "C0Z_DESCRI" )
	aAdd( aHeader, "C0Z_VALIDA" )

	aAdd( aBody, { "", "000001", "0", "ITEM DE PROPRIEDADE DO INFORMANTE E EM SEU PODER", "" } )
	aAdd( aBody, { "", "000002", "1", "ITEM DE PROPRIEDADE DO INFORMANTE EM POSSE DE TERCEIROS", "" } )
	aAdd( aBody, { "", "000003", "2", "ITEM DE PROPRIEDADE DE TERCEIROS EM POSSE DO INFORMANTE", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )