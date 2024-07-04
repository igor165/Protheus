#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                                      
#INCLUDE "TAFA172.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA176
Cadastro MVC dos Identificadores de Bens/Grupo Incorporados ao Ativo Imobilizado

@author Rodrigo Aguilar
@since 07/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA176()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001)	//"Cadastro dos Identif. Bem/Grupo Inc. Ativo Imobilizado"
oBrw:SetAlias( 'C4K')
oBrw:SetMenuDef( 'TAFA176' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Rodrigo Aguilar
@since 07/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA176" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 07/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC4K 	:= 	FWFormStruct( 1, 'C4K' )
Local oModel 	:= 	MPFormModel():New( 'TAFA176' )

oModel:AddFields('MODEL_C4K', /*cOwner*/, oStruC4K)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 07/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA176' )
Local 	oStruC4K 	:= 	FWFormStruct( 2, 'C4K' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C4K', oStruC4K, 'MODEL_C4K' )

oView:EnableTitleView( 'VIEW_C4K', STR0001 )	//"Cadastro dos Identif. Bem/Grupo Inc. Ativo Imobilizado"
oView:CreateHorizontalBox( 'FIELDSC4K', 100 )
oView:SetOwnerView( 'VIEW_C4K', 'FIELDSC4K' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1016.06

If nVerEmp < nVerAtu
	aAdd( aHeader, "C4K_FILIAL" )
	aAdd( aHeader, "C4K_ID" )
	aAdd( aHeader, "C4K_CODIGO" )
	aAdd( aHeader, "C4K_DESCRI" )
	aAdd( aHeader, "C4K_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "EDIFICACOES E BENFEITORIAS EM IMOVEIS PROPRIOS", "" } )
	aAdd( aBody, { "", "000002", "03", "INSTALACOES", "" } )
	aAdd( aBody, { "", "000003", "04", "MAQUINAS", "" } )
	aAdd( aBody, { "", "000004", "05", "EQUIPAMENTOS", "" } )
	aAdd( aBody, { "", "000005", "06", "VEICULOS", "" } )
	aAdd( aBody, { "", "000006", "99", "OUTROS BENS INCORPORADOS AO ATIVO IMOBILIZADO", "" } )
	aAdd( aBody, { "", "000007", "02", "EDIFICACOES E BENFEITORIAS EM IMOVEIS DE TERCEIROS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )