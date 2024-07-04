#INCLUDE "PLSABD4M.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//����������������������������������������������������������������������������
//� Define
//����������������������������������������������������������������������������
#DEFINE PLS_MENUDEF	"VIEWDEF.PLSABD4M"

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
local oModel 	:= FWLoadModel(oBA8C:getModel(1))
local oStruV 	:= FWFormStruct(oBA8C:getViewOperation(), oBA8C:getAlias(1))
local oView  := FWFormView():New()
//���������������������������������������������������������������������������
//� Remove field da view													 
//���������������������������������������������������������������������������
oStruV:removeField('BD4_CODTAB')
oStruV:removeField('BD4_CDPADP')
oStruV:removeField('BD4_CODPRO')
//���������������������������������������������������������������������������
//� Seta o modelo na visao													 
//���������������������������������������������������������������������������
oView:setModel(oModel)
//���������������������������������������������������������������������������
//� Adiciona a strutura de campos da tabela na view - mestre							 
//���������������������������������������������������������������������������
oView:addField(oBA8C:getViewId(1), oStruV, oBA8C:getModelId(1))                             
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
local oStruM	:= FWFormStruct(oBA8C:getModelOperation(), oBA8C:getAlias(1))
local oModel	:= MPFormModel():New( oBA8C:getModel(1),/*bPreValidacao*/,{|oModel| oBA8C:MDPosVLD(oModel,oBA8C:getAlias(1))},{|oModel| oBA8C:MDCommit(oModel,oBA8C:getAlias(1)) }, /*bCancel*/ )  /*bPosValidacao*/ /*bCommit*/

//���������������������������������������������������������������������������
//� Adiciona a strutura de campos ao modelo - mestre									 
//���������������������������������������������������������������������������
oModel:addFields(oBA8C:getModelId(1),/*cOwner*/,oStruM)
//���������������������������������������������������������������������������
//� Defini a descricao da tela												 
//���������������������������������������������������������������������������
oModel:setDescription(oBA8C:getTitulo(1))

//Necess�rio definir a chave prim�ria do modelo a partir da vers�o 12.1.4
oModel:SetPrimaryKey({"BD4_CODTAB", "BD4_CDPADP", "BD4_CODPRO", "BD4_CODIGO"})

//���������������������������������������������������������������������������
//� Valida o modelo															 
//���������������������������������������������������������������������������
oModel:setVldActivate({|oModel| oBA8C:MDActVLD(oModel)})
//���������������������������������������������������������������������������
//� Fim da rotina															 
//���������������������������������������������������������������������������
return oModel

/*/{Protheus.doc} PLSABD4M
Somente para compilar a class

@author Alexander Santos
@since 11/02/2014
@version P11
/*/
function PLSABD4M
return
