#include "protheus.ch"
#include "totvs.ch"
#include "FWMVCDEF.CH"
#include "PLSA420.CH"



//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA420   
@author Daniel Silva
@since 27/12/2021
/*/
//-------------------------------------------------------------------
Function PLSA420(lautoma)
Local oBrowse
DEFAULT lautoma := .f.
lautoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('BLM')
oBrowse:SetDescription(FunDesc())
iif( !lAutoma, oBrowse:Activate(), "")

return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA420   
@author Daniel Silva
@since 27/12/2021
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title STR0002  /*'Visualizar'*/  Action 'VIEWDEF.PLSA420' Operation 2 Access 0
Add Option aRotina Title STR0003  /*'Incluir'   */  Action 'VIEWDEF.PLSA420' Operation 3 Access 0
Add Option aRotina Title STR0004  /*'Alterar'   */  Action 'VIEWDEF.PLSA420' Operation 4 Access 0
Add Option aRotina Title STR0005  /*'Excluir'   */  Action 'VIEWDEF.PLSA420' Operation 5 Access 0

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA420   
@author Daniel Silva
@since 27/12/2021
/*/
//-------------------------------------------------------------------
Static FUNCTION ModelDef()

local oModel
Local oStrBLM:= FWFormStruct(1,'BLM')

oModel := MPFormModel():New('PLSA420')
oModel:SetDescription(STR0001) //Setor de Trabalho 

oModel:addFields('MasterBLM',,oStrBLM)
oModel:getModel('MasterBLM')	
oModel:SetPrimaryKey( {"BLM_FILIAL", "BLM_CODSET", "BLM_DESSET"} )

return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA420   
@author Daniel Silva
@since 27/12/2021
/*/
//-------------------------------------------------------------------
static function ViewDef()

Local oModel := ModelDef()
Local oView
Local oStrBLM:= FWFormStruct(2, 'BLM')

oView := FWFormView():New()		
oView:SetModel(oModel)	
oView:AddField('FrmBLM' , oStrBLM,'MasterBLM' ) 				
oView:CreateHorizontalBox( 'BxBLM', 100)						
oView:SetOwnerView('FrmBLM','BxBLM')						

return oView

