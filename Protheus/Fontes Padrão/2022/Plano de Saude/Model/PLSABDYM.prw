#INCLUDE "PLSABDYM.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//����������������������������������������������������������������������������
//� Define
//����������������������������������������������������������������������������
#DEFINE PLS_MENUDEF	"VIEWDEF.PLSABDYM"

/*/{Protheus.doc} MenuDef
MenuDef

@author Alexander Santos
@since 11/02/2014
@version P11
/*/
static function MenuDef()
local aRotina := {}

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
local oModel 	:= FWLoadModel(oBA8C:getModel(2))
local oStruV 	:= FWFormStruct(oBA8C:getViewOperation(), oBA8C:getAlias(2))
local oView  := FWFormView():New()
//���������������������������������������������������������������������������
//� Remove field da view													 
//���������������������������������������������������������������������������
oStruV:removeField('BDY_CODTAB')
oStruV:removeField('BDY_CDPADP')
oStruV:removeField('BDY_CODPRO')
//���������������������������������������������������������������������������
//� Seta o modelo na visao													 
//���������������������������������������������������������������������������
oView:setModel(oModel)
//���������������������������������������������������������������������������
//� Adiciona a strutura de campos da tabela na view - mestre							 
//���������������������������������������������������������������������������
oView:addField(oBA8C:getViewId(2), oStruV, oBA8C:getModelId(2))                             
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
local oStruM	:= FWFormStruct(oBA8C:getModelOperation(), oBA8C:getAlias(2))
local oModel	:= MPFormModel():New( oBA8C:getModel(2),/*bPreValidacao*/,{|oModel| oBA8C:MDPosVLD(oModel,oBA8C:getAlias(2))},{|oModel| oBA8C:MDCommit(oModel,oBA8C:getAlias(2)) }, /*bCancel*/ )  /*bPosValidacao*/ /*bCommit*/
local aKey	:= strToKarr(PLGETUNIC(oBA8C:getAlias(2))[2],'+')
//���������������������������������������������������������������������������
//� Adiciona a strutura de campos ao modelo - mestre									 
//���������������������������������������������������������������������������
oModel:addFields(oBA8C:getModelId(2),/*cOwner*/,oStruM)
//���������������������������������������������������������������������������
//� PrimaryKey									 
//���������������������������������������������������������������������������
oModel:setPrimaryKey(aKey)
//���������������������������������������������������������������������������
//� Defini a descricao da tela												 
//���������������������������������������������������������������������������
oModel:setDescription(oBA8C:getTitulo(2))
//���������������������������������������������������������������������������
//� Fim da rotina															 
//���������������������������������������������������������������������������
return oModel

/*/{Protheus.doc} PLSABDYM
Somente para compilar a class

@author Alexander Santos
@since 11/02/2014
@version P11
/*/
function PLSABDYM
return