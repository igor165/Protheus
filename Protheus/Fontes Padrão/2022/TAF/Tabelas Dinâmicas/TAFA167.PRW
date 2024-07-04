#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                                         
#INCLUDE "TAFA167.CH"                                               
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA167
Cadastro MVC - Cadastro do Código da natureza da conta/grupo de contas

@author Mauro A. Goncalves
@since 26/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA167()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro do Código da natureza da conta/grupo de contas
oBrw:SetAlias( 'C2R')
oBrw:SetMenuDef( 'TAFA167' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 26/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA167" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 26/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC2R 	:= 	FWFormStruct( 1, 'C2R' )
Local oModel 	:= 	MPFormModel():New( 'TAFA167' )

oModel:AddFields('MODEL_C2R', /*cOwner*/, oStruC2R)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 26/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA167' )
Local 	oStruC2R 	:= 	FWFormStruct( 2, 'C2R' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C2R', oStruC2R, 'MODEL_C2R' )

oView:EnableTitleView( 'VIEW_C2R', STR0001 ) //Cadastro do Código da natureza da conta/grupo de contas
oView:CreateHorizontalBox( 'FIELDSC2R', 100 )
oView:SetOwnerView( 'VIEW_C2R', 'FIELDSC2R' )

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
	aAdd( aHeader, "C2R_FILIAL" )
	aAdd( aHeader, "C2R_ID" )
	aAdd( aHeader, "C2R_CODIGO" )
	aAdd( aHeader, "C2R_DESCRI" )
	aAdd( aHeader, "C2R_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "CONTAS DE ATIVO", "" } )
	aAdd( aBody, { "", "000002", "02", "CONTAS DE PASSIVO", "" } )
	aAdd( aBody, { "", "000003", "03", "PATRIMONIO LIQUIDO", "" } )
	aAdd( aBody, { "", "000004", "04", "CONTAS DE RESULTADO", "" } )
	aAdd( aBody, { "", "000005", "05", "CONTAS DE COMPENSACAO", "" } )
	aAdd( aBody, { "", "000006", "09", "OUTRAS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )