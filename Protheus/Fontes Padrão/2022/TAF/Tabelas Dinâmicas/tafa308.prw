#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA308.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA308
Cadastro MVC dos Indicadores de Atividade

@author Fabio V Santana
@since 07/03/2013
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA308()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001)	//"Cadastro dos Indicadores de Atividade"
oBrw:SetAlias( 'CA0')
oBrw:SetMenuDef( 'TAFA308' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V Santana
@since 07/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA308" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V Santana
@since 07/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCA0 	:= 	FWFormStruct( 1, 'CA0' )
Local oModel 	:= 	MPFormModel():New( 'TAFA308' )

oModel:AddFields('MODEL_CA0', /*cOwner*/, oStruCA0)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V Santana
@since 07/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA308' )
Local 	oStruCA0 	:= 	FWFormStruct( 2, 'CA0' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_CA0', oStruCA0, 'MODEL_CA0' )

oView:EnableTitleView( 'VIEW_CA0', STR0001 )	//"Cadastro dos Indicadores de Atividade
oView:CreateHorizontalBox( 'FIELDSCA0', 100 )
oView:SetOwnerView( 'VIEW_CA0', 'FIELDSCA0' )

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
	aAdd( aHeader, "CA0_FILIAL" )
	aAdd( aHeader, "CA0_ID" )
	aAdd( aHeader, "CA0_CODIGO" )
	aAdd( aHeader, "CA0_DESCRI" )
	aAdd( aHeader, "CA0_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "Exclusivamente operacoes de Instituicoes Financeiras e Assemelhadas", "" } )
	aAdd( aBody, { "", "000002", "02", "Exclusivamente operacoes de Seguros Privados", "" } )
	aAdd( aBody, { "", "000003", "03", "Exclusivamente operacoes de Previdencia Complementar", "" } )
	aAdd( aBody, { "", "000004", "04", "Exclusivamente operacoes de Capitalizacao", "" } )
	aAdd( aBody, { "", "000005", "05", "Exclusivamente operacoes de Planos de Assistencia a saude", "" } )
	aAdd( aBody, { "", "000006", "06", "Realizou operacoes referentes a mais de um dos indicadores acima", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )