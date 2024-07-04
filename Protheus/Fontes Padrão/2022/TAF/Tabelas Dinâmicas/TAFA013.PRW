#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA013.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA013
Cadastro MVC do Indicador de Número de Parcelas da depreciação 

@author Fabio V. Santana
@since 07/05/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA013()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Cadastro de Indicador de Número de Parcelas da depreciação
oBrw:SetAlias( 'C13')
oBrw:SetMenuDef( 'TAFA013' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V. Santana
@since 07/05/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA013" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 07/05/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC13 	:= 	FWFormStruct( 1, 'C13' )
Local oModel 	:= 	MPFormModel():New( 'TAFA013' )

oModel:AddFields('MODEL_C13', /*cOwner*/, oStruC13)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 07/05/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA013' )
Local 	oStruC13 	:= 	FWFormStruct( 2, 'C13' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C13', oStruC13, 'MODEL_C13' )

oView:EnableTitleView( 'VIEW_C13', STR0001 ) //Cadastro de Indicador de Número de Parcelas da depreciação
oView:CreateHorizontalBox( 'FIELDSC13', 100 )
oView:SetOwnerView( 'VIEW_C13', 'FIELDSC13' )

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
	aAdd( aHeader, "C13_FILIAL" )
	aAdd( aHeader, "C13_ID" )
	aAdd( aHeader, "C13_CODIGO" )
	aAdd( aHeader, "C13_DESCRI" )
	aAdd( aHeader, "C13_VALIDA" )

	aAdd( aBody, { "", "000001", "1", "INTEGRAL (MES DE AQUISICAO)", "" } )
	aAdd( aBody, { "", "000002", "2", "12 MESES", "" } )
	aAdd( aBody, { "", "000003", "3", "24 MESES", "" } )
	aAdd( aBody, { "", "000004", "4", "48 MESES", "" } )
	aAdd( aBody, { "", "000005", "5", "6 MESES (EMBALAGENS DE BEBIDAS FRIAS)", "" } )
	aAdd( aBody, { "", "000006", "9", "OUTRA PERIODICIDADE DEFINIDA EM LEI", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )