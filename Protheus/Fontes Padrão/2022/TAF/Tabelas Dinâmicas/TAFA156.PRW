#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA156.CH"                         
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA156
Cadastro de Ajustes (PIS/COFINS) de Contribuição ou Créditos

@author Marcio Nunes
@since 05/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA156()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Ajustes (PIS/COFINS) de Contribuição ou Créditos
oBrw:SetAlias( 'C1D')
oBrw:SetMenuDef( 'TAFA156' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcio Nunes
@since 05/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA156" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 05/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC1D 	:= 	FWFormStruct( 1, 'C1D' )
Local oModel 	:= 	MPFormModel():New( 'TAFA156' )

oModel:AddFields('MODEL_C1D', /*cOwner*/, oStruC1D)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcio Nunes
@since 05/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA156' )
Local 	oStruC1D 	:= 	FWFormStruct( 2, 'C1D' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C1D', oStruC1D, 'MODEL_C1D' )

oView:EnableTitleView( 'VIEW_C1D', STR0001 ) //Cadastro de Ajustes (PIS/COFINS) de Contribuição ou Créditos
oView:CreateHorizontalBox( 'FIELDSC1D', 100 )
oView:SetOwnerView( 'VIEW_C1D', 'FIELDSC1D' )

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
	aAdd( aHeader, "C1D_FILIAL" )
	aAdd( aHeader, "C1D_ID" )
	aAdd( aHeader, "C1D_CODIGO" )
	aAdd( aHeader, "C1D_DESCRI" )
	aAdd( aHeader, "C1D_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "AJUSTE ORIUNDO DE ACAO JUDICIAL", "" } )
	aAdd( aBody, { "", "000002", "02", "AJUSTE ORIUNDO DE PROCESSO ADMINISTRATIVO", "" } )
	aAdd( aBody, { "", "000003", "03", "AJUSTE ORIUNDO DA LEGISLACAO TRIBUTARIA", "" } )
	aAdd( aBody, { "", "000004", "04", "AJUSTE ORIUNDO ESPECIFICAMENTE DO RTT", "" } )
	aAdd( aBody, { "", "000005", "05", "AJUSTE ORIUNDO DE OUTRAS SITUACOES", "" } )
	aAdd( aBody, { "", "000006", "06", "ESTORNO", "" } )
	aAdd( aBody, { "", "000007", "07", "AJUSTE DA CPRB: ADOCAO DO REGIME DE CAIXA", "" } )
	aAdd( aBody, { "", "000008", "08", "AJUSTE DA CPRB: DIFERIMENTO DE VALORES A RECOLHER NO PERIODO", "" } )
	aAdd( aBody, { "", "000009", "09", "AJUSTE DA CPRB: ADICAO DE VALORES DIFERIDOS EM PERIODO(S) ANTERIOR(ES)", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )