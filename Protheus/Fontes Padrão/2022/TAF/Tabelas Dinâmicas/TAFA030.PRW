#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA030.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA003
Cadastro MVC - Cadastro de Finalidades do Documento Fiscal 

@author Mauro A. Goncalves
@since 11/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA030()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Finalidades do Documento Fiscal
oBrw:SetAlias( 'C0U')
oBrw:SetMenuDef( 'TAFA030' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 11/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA030" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 11/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC0U 	:= 	FWFormStruct( 1, 'C0U' )
Local oModel 	:= 	MPFormModel():New( 'TAFA030' )

oModel:AddFields('MODEL_C0U', /*cOwner*/, oStruC0U)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 11/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA030' )
Local 	oStruC0U 	:= 	FWFormStruct( 2, 'C0U' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0U', oStruC0U, 'MODEL_C0U' )

oView:EnableTitleView( 'VIEW_C0U', STR0001 ) //Cadastro de Finalidades do Documento Fiscal
oView:CreateHorizontalBox( 'FIELDSC0U', 100 )
oView:SetOwnerView( 'VIEW_C0U', 'FIELDSC0U' )

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
	aAdd( aHeader, "C0U_FILIAL" )
	aAdd( aHeader, "C0U_ID" )
	aAdd( aHeader, "C0U_CODIGO" )
	aAdd( aHeader, "C0U_DESCRI" )

	aAdd( aBody, { "", "000001", "00", "EMISSAO NORMAL" } )
	aAdd( aBody, { "", "000002", "01", "DOCUMENTO DE DEVOLUCAO" } )
	aAdd( aBody, { "", "000003", "02", "COMPLEMENTO DE ICMS" } )
	aAdd( aBody, { "", "000004", "03", "COMPLEMENTO DE IPI" } )
	aAdd( aBody, { "", "000005", "04", "COMPLEMENTO DE FRETE" } )
	aAdd( aBody, { "", "000006", "05", "BENEFICIAMENTO" } )
	aAdd( aBody, { "", "000007", "06", "Nota Fiscal de Serviço" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )