#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA327.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA327
Cadastro MVC de Beneficio Fiscal

@author Denis R de Oliveira
@since 15/05/2014
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA327()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001)    //"Cadastro de Beneficio Fiscal"
oBrw:SetAlias( 'CFL')
oBrw:SetMenuDef( 'TAFA327' )
CFL->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Denis R de Oliveira
@since 15/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA327" ,,,,.T. )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis R de Oliveira
@since 15/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCFL  :=  FWFormStruct( 1, 'CFL' )
Local oModel    :=  MPFormModel():New( 'TAFA327' )

oModel:AddFields('MODEL_CFL', /*cOwner*/, oStruCFL)
oModel:GetModel('MODEL_CFL'):SetPrimaryKey({'CFL_FILIAL','CFL_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis R de Oliveira
@since 15/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA327' )
Local   oStruCFL    :=  FWFormStruct( 2, 'CFL' )
Local   oView       :=  FWFormView():New()
  
oStruCFL:RemoveField('CFL_ID')

oView:SetModel( oModel )
oView:AddField( 'VIEW_CFL', oStruCFL, 'MODEL_CFL' ) 

oView:EnableTitleView( 'VIEW_CFL', STR0001 )    //"Cadastro de Beneficio Fiscal"
oView:CreateHorizontalBox( 'FIELDSCFL', 100 )
oView:SetOwnerView( 'VIEW_CFL', 'FIELDSCFL' )

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
	aAdd( aHeader, "CFL_FILIAL" )
	aAdd( aHeader, "CFL_ID" )
	aAdd( aHeader, "CFL_CODIGO" )
	aAdd( aHeader, "CFL_DESCRI" )
	aAdd( aHeader, "CFL_DTINI" )
	aAdd( aHeader, "CFL_DTFIN" )

	aAdd( aBody, { "", "e7c99f28-0988-7ed7-5c35-b1aec8e38a50", "00", "NAO PREENCHIDO", "20130101", "" } )
	aAdd( aBody, { "", "b52299f1-ab08-796f-332e-d8cf7ab69443", "01", "ISENCAO", "20130101", "" } )
	aAdd( aBody, { "", "a0038516-50c3-7f9f-e346-978c177ccf3e", "02", "REDUCAO DE 100%", "20130101", "" } )
	aAdd( aBody, { "", "6848e627-6f1e-0468-0a2b-944c8cda4b72", "03", "REDUCAO DE 75%", "20130101", "" } )
	aAdd( aBody, { "", "3e0129f0-3ee0-2867-e9b6-3404f7c72d4f", "04", "REDUCAO DE 70%", "20130101", "" } )
	aAdd( aBody, { "", "ee98b8df-9362-9cbe-be39-a04ade83653d", "05", "REDUCAO DE 50%", "20130101", "" } )
	aAdd( aBody, { "", "0102b7c0-6879-795a-ec54-71cb4af9b68e", "06", "REDUCAO DE 33,33%", "20130101", "" } )
	aAdd( aBody, { "", "5debf855-7353-3ca2-0617-f566408716c0", "07", "REDUCAO DE 25%", "20130101", "" } )
	aAdd( aBody, { "", "73cbd38e-ee7d-a985-d04a-d5d2d72929a2", "08", "REDUCAO DE 12,5%", "20130101", "" } )
	aAdd( aBody, { "", "c4e4e06d-f699-264a-dc18-b0f00a5031be", "09", "REDUCAO POR REINVESTIMENTO", "20130101", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )