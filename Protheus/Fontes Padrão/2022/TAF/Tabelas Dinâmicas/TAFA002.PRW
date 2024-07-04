#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA002.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA002
Cadastro MVC das Situações dos Documentos Fiscais 

@author Marcio Nunes
@since 02/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA002()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro das Situações dos Documentos Fiscais
oBrw:SetAlias( 'C02')
oBrw:SetMenuDef( 'TAFA002' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcio Nunes
@since 02/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA002" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 02/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC02 	:= 	FWFormStruct( 1, 'C02' )
Local oModel 	:= 	MPFormModel():New( 'TAFA002' )

oModel:AddFields('MODEL_C02', /*cOwner*/, oStruC02)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcio Nunes
@since 02/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA002' )
Local 	oStruC02 	:= 	FWFormStruct( 2, 'C02' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C02', oStruC02, 'MODEL_C02' )

oView:EnableTitleView( 'VIEW_C02', STR0001 ) //Cadastro das Situações dos Documentos Fiscais
oView:CreateHorizontalBox( 'FIELDSC02', 100 )
oView:SetOwnerView( 'VIEW_C02', 'FIELDSC02' )

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
	aAdd( aHeader, "C02_FILIAL" )
	aAdd( aHeader, "C02_ID" )
	aAdd( aHeader, "C02_CODIGO" )
	aAdd( aHeader, "C02_DESCRI" )
	aAdd( aHeader, "C02_VALIDA" )

	aAdd( aBody, { "", "000001", "00", "DOCUMENTO REGULAR", "" } )
	aAdd( aBody, { "", "000002", "01", "ESCRITURACAO EXTEMPORANEA DE DOCUMENTO REGULAR", "" } )
	aAdd( aBody, { "", "000003", "02", "DOCUMENTO CANCELADO", "" } )
	aAdd( aBody, { "", "000004", "03", "ESCRITURACAO EXTEMPORANEA DE DOCUMENTO CANCELADO", "" } )
	aAdd( aBody, { "", "000005", "04", "NF-E OU CT-E - DENEGADO", "" } )
	aAdd( aBody, { "", "000006", "05", "NF-E OU CT-E - NUMERACAO INUTILIZADA", "" } )
	aAdd( aBody, { "", "000007", "06", "DOCUMENTO FISCAL COMPLEMENTAR", "" } )
	aAdd( aBody, { "", "000008", "07", "ESCRITURACAO EXTEMPORANEA DE DOCUMENTO COMPLEMENTAR", "" } )
	aAdd( aBody, { "", "000009", "08", "DOCUMENTO FISCAL EMITIDO COM BASE EM REGIME ESPECIAL OU NORMA ESPECIFICA", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )