#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA316.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA316
Cadastro MVC de Tipo de Entidade 

@author Denis R de Oliveira
@since 15/05/2014
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA316()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001)    //"Cadastro de Tipo de Entidade"
oBrw:SetAlias( 'CH0')
oBrw:SetMenuDef( 'TAFA316' )
CH0->(DbSetOrder(2))
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
Return XFUNMnuTAF( "TAFA316" ,,,,.T. )
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
Local oStruCH0  :=  FWFormStruct( 1, 'CH0' )
Local oModel    :=  MPFormModel():New( 'TAFA316' )

oModel:AddFields('MODEL_CH0', /*cOwner*/, oStruCH0)
oModel:GetModel('MODEL_CH0'):SetPrimaryKey({'CH0_FILIAL','CH0_ID'})

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
Local   oModel      :=  FWLoadModel( 'TAFA316' )
Local   oStruCH0    :=  FWFormStruct( 2, 'CH0' )
Local   oView       :=  FWFormView():New() 

oStruCH0:RemoveField('CH0_ID')

oView:SetModel( oModel )
oView:AddField( 'VIEW_CH0', oStruCH0, 'MODEL_CH0' )

oView:EnableTitleView( 'VIEW_CH0', STR0001 )    //"Cadastro de Tipo de Entidade"
oView:CreateHorizontalBox( 'FIELDSCH0', 100 )
oView:SetOwnerView( 'VIEW_CH0', 'FIELDSCH0' )

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
	aAdd( aHeader, "CH0_FILIAL" )
	aAdd( aHeader, "CH0_ID" )
	aAdd( aHeader, "CH0_CODIGO" )
	aAdd( aHeader, "CH0_DESCRI" )
	aAdd( aHeader, "CH0_DTINI" )
	aAdd( aHeader, "CH0_DTFIN" )

	aAdd( aBody, { "", "1d853e68-c5c5-4faa-e147-4db311a06eec", "01", "ASSISTENCIA SOCIAL", "", "" } )
	aAdd( aBody, { "", "1e74bcca-45bf-c223-88cc-a3ceae436a2d", "02", "EDUCACIONAL", "20130101", "" } )
	aAdd( aBody, { "", "c34d3090-93aa-2c90-915a-d42125c49e04", "03", "SINDICATO DE TRABALHADORES", "20130101", "" } )
	aAdd( aBody, { "", "063c38e4-85f8-15e8-98cb-fd5d30401f85", "04", "ASSOCIACAO CIVIL", "20130101", "" } )
	aAdd( aBody, { "", "1d77de13-36fa-a695-8d35-cd0caf227aab", "05", "CULTURAL", "20130101", "" } )
	aAdd( aBody, { "", "b45eb718-2f0c-b323-fbac-35113cbd29ce", "06", "ENTIDADE FECHADA DE PREVIDENCIA COMPLEMENTAR", "20130101", "" } )
	aAdd( aBody, { "", "c44aa822-e977-8d8a-5ca6-3bda3a690164", "07", "FILANTROPICA", "20130101", "" } )
	aAdd( aBody, { "", "95fbb1c2-7cc5-8078-9a0a-f7be08eb0615", "08", "SINDICATO", "20130101", "" } )
	aAdd( aBody, { "", "694615c6-ff4a-e058-2886-d4adcb1e1a8f", "09", "RECREATIVA", "20130101", "" } )
	aAdd( aBody, { "", "95557a3c-fa7c-d689-026f-f3e128147583", "10", "CIENTIFICA", "20130101", "" } )
	aAdd( aBody, { "", "520cc32b-f0a4-f4d0-553c-377a89017df6", "11", "ASSOCIACAO DE POUPANCA E EMPRESTIMO", "20130101", "" } )
	aAdd( aBody, { "", "47676dde-6c6e-c2e6-7389-a86654648edf", "12", "ENTIDADE ABERTA DE PREVIDENCIA COMPLEMENTAR (SEM FINS LUCRATIVOS)", "20130101", "" } )
	aAdd( aBody, { "", "b6c4a260-2281-5681-ef2e-299f658df733", "13", "FIFA E ENTIDADES RELACIONADAS", "20130101", "" } )
	aAdd( aBody, { "", "ca770087-0b61-5f02-f406-3bcbde6fe621", "14", "CIO E ENTIDADES RELACIONADAS", "20130101", "" } )
	aAdd( aBody, { "", "814b21fb-d790-22d0-845f-5fb5914b56dd", "15", "PARTIDOS POLITICOS", "20130101", "" } )
	aAdd( aBody, { "", "fa6bd0aa-17cc-de85-2b6c-fc790bfe08e6", "99", "OUTRAS.", "20130101", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )