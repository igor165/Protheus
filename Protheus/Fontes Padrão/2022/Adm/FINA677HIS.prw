#Include 'Protheus.ch'
#Include 'FINA677.CH'
#Include 'FWEDITPANEL.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} ViewDef
Definição do interface

@author Jose Domingos Caldana Jr
@since 01/11/2013
@version 1.0
/*/
Static Function ViewDef()
Local oModel   := FWLoadModel('FINA677HIS')
Local oStruFLF := FWFormStruct(2,'FLF')
Local oStruFLN := FWFormStruct(2,'FLN')

oStruFLF:RemoveField('FLF_MOTVFL')

F677HRNM(oStruFLF)

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_FLF',oStruFLF,'FLFMASTER')
oView:AddGrid('VIEW_FLN',oStruFLN,'FLNDETAIL')
oView:SetViewProperty("VIEW_FLF","SETLAYOUT",{FF_LAYOUT_VERT_DESCR_TOP ,-1})
oView:SetViewProperty('VIEW_FLN','ENABLEDGRIDDETAIL', {50} )

oView:CreateHorizontalBox( 'SUP_FLF', 50)
oView:CreateHorizontalBox( 'INF_FLN', 50)

oView:SetOwnerView('VIEW_FLF','SUP_FLF')
oView:SetOwnerView('VIEW_FLN','INF_FLN')

oView:EnableTitleView('VIEW_FLF')
oView:EnableTitleView('VIEW_FLN')

oStruFLN:RemoveField('FLN_TIPO')
oStruFLN:RemoveField('FLN_PRESTA')
oStruFLN:RemoveField('FLN_PARTIC')

Return oView

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Jose Domingos Caldana Jr
@since 01/11/2013
@version 1.0
/*/
Static Function ModelDef()
Local aRelacao := {}
Local oStruFLF := FWFormStruct(1,'FLF')
Local oStruFLN := FWFormStruct(1,'FLN')
Local oModel   := MPFormModel():New('FINA677HIS')
oModel:SetDescription(STR0001 +" "+ STR0018 )

oModel:AddFields('FLFMASTER',/*cOwner(Pai)*/,oStruFLF)
oModel:AddGrid('FLNDETAIL','FLFMASTER',oStruFLN)

aAdd(aRelacao,{'FLN_FILIAL','xFilial("FLN")'})
aAdd(aRelacao,{'FLN_TIPO','FLF_TIPO'})
aAdd(aRelacao,{'FLN_PRESTA','FLF_PRESTA'})
aAdd(aRelacao,{'FLN_PARTIC','FLF_PARTIC'})

oModel:SetRelation('FLNDETAIL',aRelacao,FLN->(IndexKey(1)))

oModel:GetModel('FLFMASTER'):SetDescription(STR0001 +" "+ STR0018)
oModel:GetModel('FLNDETAIL'):SetDescription(STR0017)

Return oModel

/*/{Protheus.doc} F677HRNM
Renomeia os campos de valores de acordo com a moeda 1,2,3...

@author lucas.oliveira
@since 11/11/2015
@version 12.1.8
/*/
Function F677HRNM(oStruFLF)
Local cSimbMda := ""
Local nX := 0
Local cX := ""

For nX := 1 To 3 //quantidade de campos cadastrados no dicionário com moedas diferentes.

	cX := AllTRIM(STR(nX))
	
	cSimbMda := Iif( SUPERGETMV("MV_SIMB"+cX, .F., cX) == "", cX , SUPERGETMV("MV_SIMB"+cX, .F., cX))
	
	oStruFLF:SetProperty( "FLF_TDESP"+cX , MVC_VIEW_TITULO, STR0023 +" "+ cSimbMda) //"Despesas"
	oStruFLF:SetProperty( "FLF_TVLRE"+cX , MVC_VIEW_TITULO, STR0024 +" "+ cSimbMda) //"Reembols"
	oStruFLF:SetProperty( "FLF_TDESC"+cX , MVC_VIEW_TITULO, STR0025 +" "+ cSimbMda) //"Desconto"
	oStruFLF:SetProperty( "FLF_TADIA"+cX , MVC_VIEW_TITULO, STR0022 +" "+ cSimbMda) //"Adiantam."

Next nX

Return
