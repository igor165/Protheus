#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA039.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA039
Cadastro MVC - Cadastro de Indicador da Natureza do Evento de Sucessão

@author Mauro A. Goncalves
@since 16/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA039()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Indicador da Natureza do Evento de Sucessão
oBrw:SetAlias( 'C12')
oBrw:SetMenuDef( 'TAFA039' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA039" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC12 	:= 	FWFormStruct( 1, 'C12' )
Local oModel 	:= 	MPFormModel():New( 'TAFA039' )

oModel:AddFields('MODEL_C12', /*cOwner*/, oStruC12)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA039' )
Local 	oStruC12 	:= 	FWFormStruct( 2, 'C12' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C12', oStruC12, 'MODEL_C12' )

oView:EnableTitleView( 'VIEW_C12', STR0001 ) //Cadastro do Grupo de classificação do item de energia elétrica
oView:CreateHorizontalBox( 'FIELDSC12', 100 )
oView:SetOwnerView( 'VIEW_C12', 'FIELDSC12' )

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
	aAdd( aHeader, "C12_FILIAL" )
	aAdd( aHeader, "C12_ID" )
	aAdd( aHeader, "C12_CODIGO" )
	aAdd( aHeader, "C12_DESCRI" )
	aAdd( aHeader, "C12_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "INCORPORACAO", "" } )
	aAdd( aBody, { "", "000002", "02", "FUSAO", "" } )
	aAdd( aBody, { "", "000003", "03", "CISAO TOTAL", "" } )
	aAdd( aBody, { "", "000004", "04", "CISAO PARCIAL", "" } )
	aAdd( aBody, { "", "000005", "99", "OUTROS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )