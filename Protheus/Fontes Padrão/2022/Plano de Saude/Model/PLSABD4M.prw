#INCLUDE "PLSABD4M.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Define
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
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
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da funcao															 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
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
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Remove field da view													 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oStruV:removeField('BD4_CODTAB')
oStruV:removeField('BD4_CDPADP')
oStruV:removeField('BD4_CODPRO')
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Seta o modelo na visao													 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oView:setModel(oModel)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Adiciona a strutura de campos da tabela na view - mestre							 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oView:addField(oBA8C:getViewId(1), oStruV, oBA8C:getModelId(1))                             
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da rotina															 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
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

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Adiciona a strutura de campos ao modelo - mestre									 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oModel:addFields(oBA8C:getModelId(1),/*cOwner*/,oStruM)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Defini a descricao da tela												 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oModel:setDescription(oBA8C:getTitulo(1))

//NecessАrio definir a chave primАria do modelo a partir da versЦo 12.1.4
oModel:SetPrimaryKey({"BD4_CODTAB", "BD4_CDPADP", "BD4_CODPRO", "BD4_CODIGO"})

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Valida o modelo															 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oModel:setVldActivate({|oModel| oBA8C:MDActVLD(oModel)})
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da rotina															 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return oModel

/*/{Protheus.doc} PLSABD4M
Somente para compilar a class

@author Alexander Santos
@since 11/02/2014
@version P11
/*/
function PLSABD4M
return
