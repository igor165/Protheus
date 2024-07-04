#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA038.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA038
Cadastro de Indicador de Origem de Deduções Diversas

@author Marcio Nunes
@since 16/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA038()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Indicador de Origem de Deduções Diversas
oBrw:SetAlias( 'C1S')
oBrw:SetMenuDef( 'TAFA038' )
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
Return XFUNMnuTAF( "TAFA038" )
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
Local oStruC1S 	:= 	FWFormStruct( 1, 'C1S' )
Local oModel 	:= 	MPFormModel():New( 'TAFA038' )

oModel:AddFields('MODEL_C1S', /*cOwner*/, oStruC1S)

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA038' )
Local 	oStruC1S 	:= 	FWFormStruct( 2, 'C1S' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C1S', oStruC1S, 'MODEL_C1S' )

oView:EnableTitleView( 'VIEW_C1S', STR0001 ) //Cadastro de Indicador de Origem de Deduções Diversas
oView:CreateHorizontalBox( 'FIELDSC1S', 100 )
oView:SetOwnerView( 'VIEW_C1S', 'FIELDSC1S' )

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
	aAdd( aHeader, "C1S_FILIAL" )
	aAdd( aHeader, "C1S_ID" )
	aAdd( aHeader, "C1S_CODIGO" )
	aAdd( aHeader, "C1S_DESCRI" )
	aAdd( aHeader, "C1S_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "CREDITOS PRESUMIDOS - MEDICAMENTOS", "" } )
	aAdd( aBody, { "", "000002", "02", "CREDITOS ADMITIDOS NO REGIME CUMULATIVO – BEBIDAS FRIAS", "" } )
	aAdd( aBody, { "", "000003", "03", "CONTRIBUICAO PAGA PELO SUBSTITUTO TRIBUTARIO - ZFM", "" } )
	aAdd( aBody, { "", "000004", "04", "SUBSTITUICAO TRIBUTARIA – NAO OCORRENCIA DO FATO GERADOR PRESUMIDO", "" } )
	aAdd( aBody, { "", "000005", "99", "OUTRAS DEDUCOES", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )