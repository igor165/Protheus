#INCLUDE "PLSABA8M.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//����������������������������������������������������������������������������
//� Define
//����������������������������������������������������������������������������
#DEFINE PLS_MENUDEF	"VIEWDEF.PLSABA8M"

/*/{Protheus.doc} MenuDef
MenuDef

@author Alexander Santos
@since 11/02/2014
@version P11
/*/
static function MenuDef()
local aRotina		:= {}
local oPMile 		:= PLSMILE():new('PLMIBA8M',aRotina) 

aadd( aRotina, { STR0001, 	PLS_MENUDEF, 0, MODEL_OPERATION_DELETE} ) //"Excluir"
aadd( aRotina, { STR0002, 	PLS_MENUDEF, 0, MODEL_OPERATION_VIEW } ) //"Visualizar"
aadd( aRotina, { STR0003, 	PLS_MENUDEF, 0, MODEL_OPERATION_INSERT} ) //"Incluir"
aadd( aRotina, { STR0004, 	PLS_MENUDEF, 0, MODEL_OPERATION_UPDATE} ) //"Alterar"
//����������������������������������������������������������������������������
//� Fim da funcao															 
//����������������������������������������������������������������������������
return aRotina
              
/*/{Protheus.doc} ViewDef
ViewDef

@author Alexander Santos
@since 11/02/2014
@version P11
/*/
static function ViewDef()
local oBA8C	:= PLSABA8C():new() 
local oModel 	:= FWLoadModel(oBA8C:getModel(0))
local oStruV 	:= FWFormStruct(oBA8C:getViewOperation(), oBA8C:getAlias(0))
local oView  := FWFormView():New()
//���������������������������������������������������������������������������
//� Seta o modelo na visao													 
//���������������������������������������������������������������������������
oView:setModel(oModel)
//���������������������������������������������������������������������������
//� Adiciona a strutura de campos da tabela na view - mestre							 
//���������������������������������������������������������������������������
oView:addField(oBA8C:getViewId(0), oStruV, oBA8C:getModelId(0))                             
//����������������������������������������������������������������������������
//� Fecha a tela
//����������������������������������������������������������������������������
oView:setCloseOnOk({|oView| oBA8C:VWOkCloseScreenVLD(oView)})
//���������������������������������������������������������������������������
//� Fim da rotina															 
//���������������������������������������������������������������������������
return oView

/*/{Protheus.doc} ModelDef
ModelDef

@author Alexander Santos
@since 11/02/2014
@version P11
/*/
static function ModelDef()
local oBA8C	:= PLSABA8C():new()
local oStruM	:= FWFormStruct(oBA8C:getModelOperation(), oBA8C:getAlias(0))
local oModel	:= MPFormModel():New( oBA8C:getModel(0),/*bPreValidacao*/,{|oModel| oBA8C:MDPosVLD(oModel,oBA8C:getAlias(0))},{|oModel| oBA8C:MDCommit(oModel,oBA8C:getAlias(0)) }, /*bCancel*/ )  /*bPosValidacao*/ /*bCommit*/
//���������������������������������������������������������������������������
//� Adiciona a strutura de campos ao modelo - mestre									 
//���������������������������������������������������������������������������
oModel:addFields(oBA8C:getModelId(0),/*cOwner*/,oStruM)
//���������������������������������������������������������������������������
//� Defini a descricao da tela												 
//���������������������������������������������������������������������������
oModel:setDescription(oBA8C:getTitulo(0))
//���������������������������������������������������������������������������
//� Fim da rotina															 
//���������������������������������������������������������������������������
return oModel


/*/{Protheus.doc} PLSABA8M
Somente para compilar a class

@author Alexander Santos
@since 11/02/2014
@version P11
/*/
function PLSABA8M
return