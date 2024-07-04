#include "GTPC300D.CH"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPC300D()
Histórico Monitor
 
@sample	GTPC300D()
 
@return	oBrowse  Retorna o Histórico do Monitor
 
@author	Inovação
@since		29/08/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPC300D()

Local oBrowse

oBrowse := FwMBrowse():New()
oBrowse:SetAlias('GYN')	
oBrowse:SetDescription(STR0001)//"Monitor de Viagens"
oBrowse:Activate()

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do modelo de Dados
 
@sample	MenuDef()
 
@return	oModel - Objeto do Model
 
@author	  	Inovação
@since		29/08/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0001 Action 'VIEWDEF.GTPC300D' OPERATION 4 ACCESS 0 //"Monitor de Viagens"
	
Return(aRotina)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ModelDef

Definição do Modelo do MVC

@return: 
	oModel:	Object. Objeto da classe MPFormModel

@sample: oModel := ModelDef()

@author Fernando Radu Muscalu

@since 18/08/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------

Static Function ModelDef()

Local oModel
Local oMonitor	:= GC300GetMVC("M")
Local oStrGYN	:= oMonitor:GetModel("GYNDETAIL"):GetStruct()
Local oStrG55	:= oMonitor:GetModel("G55DETAIL"):GetStruct()
Local oStrGQE	:= oMonitor:GetModel("GQEDETAIL"):GetStruct()

Local aRelation	:= {}

oModel := MPFormModel():New("GTPC300D")

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("GYNMASTER", , oStrGYN)
oModel:AddGrid("G55DETAIL", "GYNMASTER", oStrG55)
oModel:AddGrid("GQEDETAIL", "G55DETAIL", oStrGQE)

//Relação do Modelo
aAdd(aRelation,{"G55_FILIAL",'XFilial("G55")'})
aAdd(aRelation,{"G55_CODVIA","GYN_CODIGO"})
oModel:SetRelation('G55DETAIL', aRelation, G55->(IndexKey(1)) )

aRelation := {}
aAdd(aRelation,{"GQE_FILIAL",'XFilial("GQE")'})
aAdd(aRelation,{"GQE_VIACOD","G55_CODVIA"})
aAdd(aRelation,{"GQE_SEQ","G55_SEQ"})

oModel:SetRelation('GQEDETAIL', aRelation, GQE->(IndexKey(1)) )

//Define as descrições dos submodelos
oModel:SetDescription("Monitor de Viagens")
oModel:GetModel("GYNMASTER"):SetDescription(STR0002)//"Viagens"
oModel:GetModel("G55DETAIL"):SetDescription(STR0003)//"Seções da Viagem"
oModel:GetModel("GQEDETAIL"):SetDescription(STR0004)//"Recursos da Seção"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 

//Opcional
oModel:GetModel("GQEDETAIL"):SetOptional(.t.)

//Bloqueia inserção e exclusão de linhas
oModel:GetModel('G55DETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('G55DETAIL'):SetNoDeleteLine(.T.)

oModel:SetPrimaryKey({})

Return(oModel)

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definição do interface

@return oView. Objeto. objeto da classe FWFormView
@sample oView := ViewDef()

@authorFernando Radu Muscalu

@since 05/12/2015
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= ModelDef()
Local oMonitor	:= GC300GetMVC("V")
Local oStruGYN	:= oMonitor:GetViewObj("VIEW_GYN")[3]:GetStruct()
Local oStruG55	:= oMonitor:GetViewObj("VIEW_G55")[3]:GetStruct()
Local oStruGQE	:= oMonitor:GetViewObj("VIEW_GQE")[3]:GetStruct()
Local oView		:= FWFormView():New()

oView:SetModel(oModel)
oView:SetDescription(STR0001)  //"Monitor de Viagens"

oView:AddGrid("VIEW_GYN",oStruGYN,"GYNMASTER")
oView:AddGrid("VIEW_G55",oStruG55,"G55DETAIL")
oView:AddGrid("VIEW_GQE",oStruGQE,"GQEDETAIL")

oView:CreateHorizontalBox( 'TOP'  	, 35)
oView:CreateHorizontalBox( 'MIDDLE'	, 35)
oView:CreateHorizontalBox( 'DOWN', 30)

oView:SetOwnerView('VIEW_GYN','TOP')
oView:SetOwnerView('VIEW_G55','MIDDLE')
oView:SetOwnerView('VIEW_GQE','DOWN')

oView:EnableTitleView('VIEW_GYN',STR0002)//"Viagens"
oView:EnableTitleView('VIEW_G55',STR0003)//"Seções por viagem"
oView:EnableTitleView('VIEW_GQE',STR0004)//"Recursos por seção"

Return ( oView )
