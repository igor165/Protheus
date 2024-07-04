#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA171.CH"                                
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA170
Cadastro MVC de Unidades de Medida

@author Fabio V. Santana
@since 12/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA171()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Tipo de Unidade Imobiliaria
oBrw:SetAlias( 'C42')
oBrw:SetMenuDef( 'TAFA171' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC do Tipo de Unidade Imobiliaria

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA171" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC42 	:= 	FWFormStruct( 1, 'C42' )
Local oModel 	:= 	MPFormModel():New( 'TAFA171' )

oModel:AddFields('MODEL_C42', /*cOwner*/, oStruC42)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA171' )
Local 	oStruC42 	:= 	FWFormStruct( 2, 'C42' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C42', oStruC42, 'MODEL_C42' )

oView:EnableTitleView( 'VIEW_C42', STR0001 ) //Tipo de Unidade Imobiliaria
oView:CreateHorizontalBox( 'FIELDSC42', 100 )
oView:SetOwnerView( 'VIEW_C42', 'FIELDSC42' )

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
	aAdd( aHeader, "C42_FILIAL" )
	aAdd( aHeader, "C42_ID" )
	aAdd( aHeader, "C42_CODIGO" )
	aAdd( aHeader, "C42_DESCRI" )
	aAdd( aHeader, "C42_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "TERRENO ADQUIRIDO PARA VENDA", "" } )
	aAdd( aBody, { "", "000002", "02", "TERRENO DECORRENTE DE LOTEAMENTO", "" } )
	aAdd( aBody, { "", "000003", "03", "LOTE ORIUNDO DE DESMEMBRAMENTO DE TERRENO", "" } )
	aAdd( aBody, { "", "000004", "04", "UNIDADE RESULTANTE DE INCORPORACAO IMOBILIARIA", "" } )
	aAdd( aBody, { "", "000005", "05", "PREDIO CONSTRUIDO/EM CONSTRUCAO PARA VENDA", "" } )
	aAdd( aBody, { "", "000006", "06", "OUTRAS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )