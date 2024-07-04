#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA042.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA042
Cadastro MVC - Cadastro de Natureza do Crédito Diferido
@author Mauro A. Goncalves
@since 16/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA042()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Natureza do Crédito Diferido
oBrw:SetAlias( 'C0V')
oBrw:SetMenuDef( 'TAFA042' )
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
Return XFUNMnuTAF( "TAFA042" )
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
Local oStruC0V 	:= 	FWFormStruct( 1, 'C0V' )
Local oModel 	:= 	MPFormModel():New( 'TAFA042' )

oModel:AddFields('MODEL_C0V', /*cOwner*/, oStruC0V)

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA042' )
Local 	oStruC0V 	:= 	FWFormStruct( 2, 'C0V' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0V', oStruC0V, 'MODEL_C0V' )

oView:EnableTitleView( 'VIEW_C0V', STR0001 ) //Cadastro de Natureza do Crédito Diferido
oView:CreateHorizontalBox( 'FIELDSC0V', 100 )
oView:SetOwnerView( 'VIEW_C0V', 'FIELDSC0V' )

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
	aAdd( aHeader, "C0V_FILIAL" )
	aAdd( aHeader, "C0V_ID" )
	aAdd( aHeader, "C0V_CODIGO" )
	aAdd( aHeader, "C0V_DESCRI" )
	aAdd( aHeader, "C0V_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "CREDITO A ALIQUOTA BASICA", "" } )
	aAdd( aBody, { "", "000002", "02", "CREDITO A ALIQUOTA DIFERENCIADA", "" } )
	aAdd( aBody, { "", "000003", "03", "CREDITO A ALIQUOTA POR UNIDADE DE PRODUTO", "" } )
	aAdd( aBody, { "", "000004", "04", "CREDITO PRESUMIDO DA AGROINDUSTRIA", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )