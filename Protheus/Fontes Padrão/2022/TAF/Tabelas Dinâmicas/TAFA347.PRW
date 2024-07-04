#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA347.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA347
Cadastro MVC de Qualificação

@author Denis R de Oliveira
@since 15/05/2014
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA347()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001)    //"Cadastro de Qualificação"
oBrw:SetAlias( 'CGN')
oBrw:SetMenuDef( 'TAFA347' )
CGN->(DbSetOrder(2))
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
Return XFUNMnuTAF( "TAFA347" ,,,,.T. )
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
Local oStruCGN  :=  FWFormStruct( 1, 'CGN' )
Local oModel    :=  MPFormModel():New( 'TAFA347' )

oModel:AddFields('MODEL_CGN', /*cOwner*/, oStruCGN)
oModel:GetModel('MODEL_CGN'):SetPrimaryKey({'CGN_FILIAL','CGN_ID'})

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
Local   oModel      :=  FWLoadModel( 'TAFA347' )
Local   oStruCGN    :=  FWFormStruct( 2, 'CGN' )
Local   oView       :=  FWFormView():New()  

oStruCGN:RemoveField('CGN_ID')

oView:SetModel( oModel )
oView:AddField( 'VIEW_CGN', oStruCGN, 'MODEL_CGN' )

oView:EnableTitleView( 'VIEW_CGN', STR0001 )    //"Cadastro de Qualificação"
oView:CreateHorizontalBox( 'FIELDSCGN', 100 )
oView:SetOwnerView( 'VIEW_CGN', 'FIELDSCGN' )

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

nVerAtu := 1029.22

If nVerEmp < nVerAtu
	aAdd( aHeader, "CGN_FILIAL" )
	aAdd( aHeader, "CGN_ID" )
	aAdd( aHeader, "CGN_CODIGO" )
	aAdd( aHeader, "CGN_DESCRI" )
	aAdd( aHeader, "CGN_DTINI" )
	aAdd( aHeader, "CGN_DTFIN" )

	aAdd( aBody, { "", "0ced53eb-070d-8c9e-6c6c-70e4377c92e6", "01", "ACIONISTA PESSOA FISICA DOMICILIADO NO BRASIL", "20130101", "" } )
	aAdd( aBody, { "", "627f1638-f59a-36b3-be7a-0c77cdef253b", "02", "SOCIO PESSOA FISICA DOMICILIADO NO BRASIL", "20130101", "" } )
	aAdd( aBody, { "", "f178f6a1-e91d-1191-113d-15ac428ff679", "03", "ACIONISTA PESSOA JURIDICA DOMICILIADO NO BRASIL", "20130101", "" } )
	aAdd( aBody, { "", "af1c18e8-0c18-604e-b13e-bda09f985877", "04", "SOCIO PESSOA JURIDICA DOMICILIADO NO BRASIL", "20130101", "" } )
	aAdd( aBody, { "", "9ee5744d-5d10-a66f-56be-fd8f05bca6aa", "05", "ACIONISTA PESSOA FISICA RESIDENTE OU DOMICILIADO NO EXTERIOR", "20130101", "" } )
	aAdd( aBody, { "", "794a20cf-5ec2-19b3-f37f-f03e2f47732c", "06", "SOCIO PESSOA FISICA RESIDENTE OU DOMICILIADO NO EXTERIOR", "20130101", "" } )
	aAdd( aBody, { "", "06ca9fac-5ef5-7c41-8f2f-7ae4c103e842", "07", "ACIONISTA PESSOA JURIDICA RESIDENTE OU DOMICILIADO NO EXTERIOR", "20130101", "" } )
	aAdd( aBody, { "", "eb2c26fb-3530-3bc8-d9a7-3681c2a60c0f", "08", "SOCIO PESSOA JURIDICA RESIDENTE OU DOMICILIADO NO EXTERIOR", "20130101", "" } )
	aAdd( aBody, { "", "5dd68745-32ac-7fea-5f0f-c6f56fb2c305", "09", "TITULAR", "20130101", "" } )
	aAdd( aBody, { "", "972328b2-da20-ac05-bd94-09cd64cf9abe", "10", "ADMINISTRADOR SEM VINCULO EMPREGATICIO", "20130101", "" } )
	aAdd( aBody, { "", "e1148871-3554-90b6-7504-7a73ce73a78e", "11", "DIRETOR SEM VINCULO EMPREGATICIO", "20130101", "" } )
	aAdd( aBody, { "", "4b520596-f57c-24c7-5d2d-80600077ec27", "12", "PRESIDENTE SEM VINCULO EMPREGATICIO", "20130101", "" } )
	aAdd( aBody, { "", "83f862f3-dfac-2358-0854-0caa3fab5c1a", "13", "ADMINISTRADOR COM VINCULO EMPREGATICIO", "20130101", "" } )
	aAdd( aBody, { "", "871ad487-fa28-b473-bcc1-5a317c3b839c", "14", "CONSELHEIRO DE ADMINISTRACAO OU FISCAL", "20130101", "" } )
	aAdd( aBody, { "", "a00be63a-941e-e16b-2103-6a82b4ba758a", "15", "DIRETOR COM VINCULO EMPREGATICIO", "20130101", "" } )
	aAdd( aBody, { "", "45a6b638-4055-4436-d781-619ea04c11a1", "16", "FUNDADOR", "20130101", "" } )
	aAdd( aBody, { "", "6a3cf182-50b8-8344-318d-94abed372ef4", "17", "PRESIDENTE COM VINCULO EMPREGATICIO", "20130101", "" } )
	aAdd( aBody, { "", "07eaa3ea-e180-a25a-19e1-170dea8941c4", "18", "USUFRUTUÁRIO DE QUOTAS OU AÇÕES", "20190101", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )