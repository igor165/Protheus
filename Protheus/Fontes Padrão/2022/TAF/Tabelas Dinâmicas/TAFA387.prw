#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA387
Cadastro de Versão ECF(ECF)

@author Evandro dos Santos Oliveira
@since 06/05/2015
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA387()
Local   oBrw  :=  FWmBrowse():New()

oBrw:SetDescription("Cadastro de Versão ECF")    //"Cadastro de Versão ECF"
oBrw:SetAlias( 'CZV')
oBrw:SetMenuDef( 'TAFA387' )
CZV->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Evandro dos Santos Oliveira	
@since 06/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA387" ,,,,.T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Evandro dos Santos Oliveira
@since 06/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCZV  :=  FWFormStruct( 1, 'CZV' )
Local oModel    :=  MPFormModel():New( 'TAFA387' )

oModel:AddFields('MODEL_CZV', /*cOwner*/, oStruCZV)
oModel:GetModel('MODEL_CZV'):SetPrimaryKey({'CZV_FILIAL','CZV_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Evandro dos Santos Oliveira 
@since 06/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA387' )
Local   oStruCZV    :=  FWFormStruct( 2, 'CZV' )
Local   oView       :=  FWFormView():New()


oView:SetModel( oModel )
oView:AddField( 'VIEW_CZV', oStruCZV, 'MODEL_CZV' )

oView:EnableTitleView( 'VIEW_CZV',"Cadastro de Versão ECF")    //"Cadastro de Versão ECF"
oView:CreateHorizontalBox( 'FIELDSCZV', 100 )
oView:SetOwnerView( 'VIEW_CZV', 'FIELDSCZV' )

oStruCZV:RemoveField( "CZV_ID" )

Return oView 



//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author		Felipe C. Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody		:=	{}
Local aRet		:=	{}

nVerAtu := 1031.53

If nVerEmp < nVerAtu
	aAdd( aHeader, "CZV_FILIAL" )
	aAdd( aHeader, "CZV_ID"     )
	aAdd( aHeader, "CZV_CODIGO" )
	aAdd( aHeader, "CZV_DESCRI" )
	aAdd( aHeader, "CZV_DTINI"  )
	aAdd( aHeader, "CZV_DTFIN"  )

	aAdd( aBody, { "", "e00ba388-392b-c622-5c86-20cb42b2c677", "0001", "101", "20140101", "20141231" } )
	aAdd( aBody, { "", "7a5d3f58-55e5-679a-ca69-f85a7d7fb43b", "0002", "102", "20150101", "20151231" } )
	aAdd( aBody, { "", "91528b35-c2aa-1827-71f7-f2b4126899c1", "0003", "103", "20160101", "20161231" } )
	aAdd( aBody, { "", "af0b3abb-c746-a71f-cc08-2e3daf9bf97d", "0004", "104", "20170101", "20181231" } )
	aAdd( aBody, { "", "3f85fb10-401b-666a-c5db-b8e8191bf0c8", "0005", "105", "20190101", "20191231" } )
	aAdd( aBody, { "", "d191fe44-c3cb-25f3-9a85-98a9a8c6f88a", "0006", "106", "20200101", "20201231" } ) 
	aAdd( aBody, { "", "36d11a0c-7a80-0046-a69b-88742b8cb7b4", "0007", "107", "20210101", "20211231" } )
	aAdd( aBody, { "", "602e27cc-a6bd-82fb-de8a-2a7c8c0a7067", "0008", "108", "20220101", "20221231" } ) 

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
