#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA041.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA041
Cadastro de Indicador do Tipo de Sociedade Cooperativa

@author Marcio Nunes
@since 16/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA041()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Indicador do Tipo de Sociedade Cooperativa
oBrw:SetAlias( 'C1T')
oBrw:SetMenuDef( 'TAFA041' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcio Nunes
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA041" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC1T 	:= 	FWFormStruct( 1, 'C1T' )
Local oModel 	:= 	MPFormModel():New( 'TAFA041' )

oModel:AddFields('MODEL_C1T', /*cOwner*/, oStruC1T)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcio Nunes
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA041' )
Local 	oStruC1T 	:= 	FWFormStruct( 2, 'C1T' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C1T', oStruC1T, 'MODEL_C1T' )

oView:EnableTitleView( 'VIEW_C1T', STR0001 ) //Cadastro de Indicador do Tipo de Sociedade Cooperativa
oView:CreateHorizontalBox( 'FIELDSC1T', 100 )
oView:SetOwnerView( 'VIEW_C1T', 'FIELDSC1T' )

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
	aAdd( aHeader, "C1T_FILIAL" )
	aAdd( aHeader, "C1T_ID" )
	aAdd( aHeader, "C1T_CODIGO" )
	aAdd( aHeader, "C1T_DESCRI" )
	aAdd( aHeader, "C1T_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "COOPERATIVA DE PRODUCAO AGROPECUARIA;", "" } )
	aAdd( aBody, { "", "000002", "02", "COOPERATIVA DE CONSUMO;", "" } )
	aAdd( aBody, { "", "000003", "03", "COOPERATIVA DE CREDITO;", "" } )
	aAdd( aBody, { "", "000004", "04", "COOPERATIVA DE ELETRIFICACAO RURAL;", "" } )
	aAdd( aBody, { "", "000005", "05", "COOPERATIVA DE TRANSPORTE RODOVIARIO DE CARGAS;", "" } )
	aAdd( aBody, { "", "000006", "06", "COOPERATIVA DE MEDICOS;", "" } )
	aAdd( aBody, { "", "000007", "99", "OUTRAS.", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )