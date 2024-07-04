#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                                          
#INCLUDE "TAFA150.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA150
Cadastro MVC - Cadastro de Família ANP

@author Mauro A. Goncalves
@since 06/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA150()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Família ANP
oBrw:SetAlias( 'C0C')
oBrw:SetMenuDef( 'TAFA150' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 06/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA150" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 06/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC0C 	:= 	FWFormStruct( 1, 'C0C' )
Local oModel 	:= 	MPFormModel():New( 'TAFA150' )

oModel:AddFields('MODEL_C0C', /*cOwner*/, oStruC0C)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 06/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA150' )
Local 	oStruC0C 	:= 	FWFormStruct( 2, 'C0C' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0C', oStruC0C, 'MODEL_C0C' )

oView:EnableTitleView( 'VIEW_C0C', STR0001 ) //Cadastro de Família ANP
oView:CreateHorizontalBox( 'FIELDSC0C', 100 )
oView:SetOwnerView( 'VIEW_C0C', 'FIELDSC0C' )

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
	aAdd( aHeader, "C0C_FILIAL" )
	aAdd( aHeader, "C0C_ID" )
	aAdd( aHeader, "C0C_CODIGO" )
	aAdd( aHeader, "C0C_DESCRI" )

	aAdd( aBody, { "", "000001", "01", "COMBUSTIVEIS ALTERNATIVOS" } )
	aAdd( aBody, { "", "000002", "02", "DERIVADOS LEVES" } )
	aAdd( aBody, { "", "000003", "03", "DERIVADOS MEDIOS" } )
	aAdd( aBody, { "", "000004", "04", "DERIVADOS PESADOS" } )
	aAdd( aBody, { "", "000005", "05", "GASES" } )
	aAdd( aBody, { "", "000006", "06", "INSUMO BRUTO" } )
	aAdd( aBody, { "", "000007", "07", "OLEOS LUBRIFICANTES, PARAFINAS E GRAXAS" } )
	aAdd( aBody, { "", "000008", "08", "PRODUTOS INORGANICOS" } )
	aAdd( aBody, { "", "000009", "09", "SUBPRODUTOS OU ADITIVOS" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )