#include 'Protheus.ch'
#include 'FWMVCDef.ch'
#include "CONFTSSA.ch"

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Valter Silva                                                 |
 | Data:  17/08/2015                                                   |
 | Desc:  Criação do menu MVC                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
static function MenuDef()
    local aRot := {}

    ADD OPTION aRot TITLE STR0002 ACTION 'VIEWDEF.CONFTSSA' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // 'Visualizar' 
    ADD OPTION aRot TITLE STR0003 ACTION 'VIEWDEF.CONFTSSA' OPERATION MODEL_OPERATION_INSERT ACCESS 0 // 'Incluir'    
    ADD OPTION aRot TITLE STR0004 ACTION 'VIEWDEF.CONFTSSA' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // 'Alterar'
    ADD OPTION aRot TITLE STR0005 ACTION 'VIEWDEF.CONFTSSA' OPERATION MODEL_OPERATION_DELETE ACCESS 0 // 'Excluir'
 
return aRot
 
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Valter Silva                                                 |
 | Data:  17/12/2020                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:   /                                                           |
 *---------------------------------------------------------------------*/
static function ModelDef()
    local oModel := Nil
    local oStFX7 := FWFormStruct(1, "FX7")

    oModel := MPFormModel():New("FX7MASTER",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
    oModel:AddFields("FORMFX7",/*cOwner*/,oStFX7) 
    oModel:SetPrimaryKey({'FX7_FILIAL','FX7_CREDEN'})

    oModel:SetDescription(STR0001) // "Configuração do TSS"

return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Valter Silva                                                 |
 | Data:  14/12/2020                                                   |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
static function ViewDef()
    local oModel := FWLoadModel("CONFTSSA")
    local oStFX7 := FWFormStruct(2, "FX7")
    local oView  := Nil
 
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_FX7", oStFX7, "FORMFX7")
    oView:CreateHorizontalBox("TELA",100)
    oView:SetOwnerView("VIEW_FX7","TELA")

return oView
