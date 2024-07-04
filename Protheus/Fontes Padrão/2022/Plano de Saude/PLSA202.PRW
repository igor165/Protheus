#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} PLS365BC0V
Browse Classe de Procedimentos

@author  Lucas Nonato
@since   11/03/2020
@version P12
/*/
Function PLSA202()

oBrw := FWmBrowse():New()
oBrw:SetAlias( 'BJE' )
oBrw:SetDescription( 'Classe de Procedimentos' )
oBrw:SetMenuDef("PLSA202")
oBrw:Activate()

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Monta o menu

@author  Lucas Nonato
@since   11/03/2020
@version P12
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar' 	   Action 'ViewDef.PLSA202'		OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir'    	   Action 'ViewDef.PLSA202'		OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar'  	   Action 'ViewDef.PLSA202'		OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir'  	   Action 'ViewDef.PLSA202'		OPERATION 5 ACCESS 0

Return aRotina 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Lucas Nonato
@since 11/03/2020
@version P12
/*/
Static Function ModelDef()
Local oModel 
Local oStrBJE:= FWFormStruct(1,'BJE')

oModel := MPFormModel():New( 'PLSA202' )		
oModel:addFields('MasterBJE',,oStrBJE)
oModel:getModel('MasterBJE')

oModel:SetPrimaryKey( {"BJE_FILIAL", "BJE_CODINT", "BJE_CODIGO"} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Lucas Nonato
@since 11/03/2020
@version P12
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrBJE:= FWFormStruct(2, 'BJE')

oView := FWFormView():New()										
oView:SetModel(oModel)
oView:AddField('FrmBJE' , oStrBJE,'MasterBJE' )
oView:CreateHorizontalBox( 'BxBJE', 100)
oView:SetOwnerView('FrmBJE','BxBJE')

Return oView