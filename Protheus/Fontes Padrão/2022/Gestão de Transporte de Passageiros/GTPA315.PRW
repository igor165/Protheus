#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA315.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA315
'Cadastro de Tipos de Documentos Operacionais'
@type Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@return nil, retorna nulo
/*/
//------------------------------------------------------------------------------
Function GTPA315()

Local oBrowse       := FWMBrowse():New()

oBrowse:SetAlias('G6U')
oBrowse:SetMenuDef('GTPA315')

oBrowse:AddLegend("G6U_MSBLQL == '1'"	, "RED"		, STR0002   )//"Inativo" 
oBrowse:AddLegend("G6U_MSBLQL <> '1'"	, "GREEN"	, STR0003   )//"Ativo"

oBrowse:SetDescription(STR0001)//'Cadastro de Tipos de Documentos Operacionais'

oBrowse:Activate()
oBrowse:Destroy()

GTPDestroy(oBrowse)

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

    ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.GTPA315' OPERATION OP_VISUALIZAR	ACCESS 0 // "Visualizar"
    ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.GTPA315' OPERATION OP_INCLUIR		ACCESS 0 // "Incluir"
    ADD OPTION aRotina TITLE STR0006    ACTION 'VIEWDEF.GTPA315' OPERATION OP_ALTERAR		ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE STR0007    ACTION 'VIEWDEF.GTPA315' OPERATION OP_EXCLUIR		ACCESS 0 // "Excluir"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author jacomo.fernades
@since 04/07/2019
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local oStrG6U	:= FWFormStruct(1,'G6U')

SetModelStruct(oStrG6U)

oModel := MPFormModel():New('GTPA315', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('G6UMASTER',/*cOwner*/,oStrG6U)

oModel:SetDescription(STR0001)//'Cadastro de Tipos de Documentos Operacionais'

oModel:GetModel('G6UMASTER'):SetDescription(STR0001)	//'Cadastro de Tipos de Documentos Operacionais'

//oModel:SetPrimaryKey({''})	

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetModelStruct
Função responsavel pela estrutura de dados do modelo
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@param oStrG6U, object, (Descrição do parâmetro)
@return nil, retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStrG6U)
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}

If ValType(oStrG6U) == "O"
    oStrG6U:SetProperty('G6U_TPVIGE'    ,MODEL_FIELD_VALUES ,GetComboBox('G6U_TPVIGE'))
    oStrG6U:SetProperty('G6U_TPTOLE'    ,MODEL_FIELD_VALUES ,GetComboBox('G6U_TPTOLE'))
    oStrG6U:SetProperty('G6U_MSBLQL'    ,MODEL_FIELD_VALUES ,GetComboBox('G6U_MSBLQL'))

    oStrG6U:AddTrigger('G6U_TPVIGE'		,'G6U_TPVIGE'	    ,{||.T.}, bTrig)
    oStrG6U:AddTrigger('G6U_TPTOLE'		,'G6U_TPTOLE'	    ,{||.T.}, bTrig)

    oStrG6U:SetProperty('G6U_TEMPVI'	, MODEL_FIELD_VALID , bFldVld)
    oStrG6U:SetProperty('G6U_TEMPTO'	, MODEL_FIELD_VALID , bFldVld)

    oStrG6U:SetProperty('G6U_TRECUR'	, MODEL_FIELD_INIT	, {||"1"})
    oStrG6U:SetProperty('G6U_TPVIGE'	, MODEL_FIELD_INIT	, {||"1"})
    oStrG6U:SetProperty('G6U_TPTOLE'	, MODEL_FIELD_INIT	, {||"1"})
    oStrG6U:SetProperty('G6U_MSBLQL'	, MODEL_FIELD_INIT	, {||"2"})

    oStrG6U:SetProperty('G6U_TEMPVI'	, MODEL_FIELD_WHEN	, {|oMdl|FwIsInCallStack('FIELDTRIGGER') .or. oMdl:GetValue('G6U_TPVIGE') <= "3" })
    oStrG6U:SetProperty('G6U_TEMPTO'	, MODEL_FIELD_WHEN	, {|oMdl|FwIsInCallStack('FIELDTRIGGER') .or. oMdl:GetValue('G6U_TPTOLE') <= "3" })

Endif

Return nil
//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldValid
Função responsavel pela validação dos campos
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@param oMdl, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uNewValue, character, (Descrição do parâmetro)
@param uOldValue, character, (Descrição do parâmetro)
@return lRet, retorno lógico
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue)
Local lRet      := .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Do Case
    Case Empty(uNewValue)
        lRet := .T.
    Case cField == "G6U_TEMPVI" .or. cField == "G6U_TEMPTO"
        If uNewValue < 0
            lRet		:= .F.
            cMsgErro	:= STR0008//"Não pode informar um valor menor que zero"
            cMsgSol		:= STR0009//"Necessário informar um valor positivo"
        Endif
EndCase


If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger
Função responsavel pelos gatilhos dos campos
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@param oMdl, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uVal, character, (Descrição do parâmetro)
@return uVal, Retorna o mesmo valor que recebeu
/*/
//------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)

Do Case
    Case cField == "G6U_TPVIGE"
        oMdl:SetValue('G6U_TEMPVI',0)
    Case cField == "G6U_TPTOLE"
        oMdl:SetValue('G6U_TEMPTO',0)
EndCase

Return uVal
//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA315')
Local oStrG6U	:= FWFormStruct(2, 'G6U')

SetViewStruct(oStrG6U)

oView:SetModel(oModel)

oView:AddField('VIEW_G6U' ,oStrG6U,'G6UMASTER')

oView:CreateHorizontalBox('TELA', 100)

oView:SetOwnerView('VIEW_G6U','TELA')

oView:SetDescription(STR0001) //'Cadastro de Tipos de Documentos Operacionais'

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetViewStruct
Função responsavel pela estrutura de dados da View
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@param oStrG6U, object, (Descrição do parâmetro)
@return nil, retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStrG6U)

If ValType(oStrG6U) == "O"
    oStrG6U:SetProperty('G6U_TPVIGE',MVC_VIEW_COMBOBOX,GetComboBox('G6U_TPVIGE'))
    oStrG6U:SetProperty('G6U_TPTOLE',MVC_VIEW_COMBOBOX,GetComboBox('G6U_TPTOLE'))
    oStrG6U:SetProperty('G6U_MSBLQL',MVC_VIEW_COMBOBOX,GetComboBox('G6U_MSBLQL'))
    
    oStrG6U:AddGroup('GRP001', '','', 2)
    oStrG6U:SetProperty( 'G6U_CODIGO', MVC_VIEW_GROUP_NUMBER, 'GRP001')
    oStrG6U:SetProperty( 'G6U_DESCRI', MVC_VIEW_GROUP_NUMBER, 'GRP001')
    oStrG6U:SetProperty( 'G6U_TRECUR', MVC_VIEW_GROUP_NUMBER, 'GRP001')
    oStrG6U:SetProperty( 'G6U_MSBLQL', MVC_VIEW_GROUP_NUMBER, 'GRP001')

    oStrG6U:AddGroup('GRP002', STR0010,'', 2) // "Vigência/Tolerância"
    oStrG6U:SetProperty( 'G6U_TPVIGE', MVC_VIEW_GROUP_NUMBER, 'GRP002')
    oStrG6U:SetProperty( 'G6U_TEMPVI', MVC_VIEW_GROUP_NUMBER, 'GRP002')
    oStrG6U:SetProperty( 'G6U_TPTOLE', MVC_VIEW_GROUP_NUMBER, 'GRP002')
    oStrG6U:SetProperty( 'G6U_TEMPTO', MVC_VIEW_GROUP_NUMBER, 'GRP002')
    
Endif

Return nil
//------------------------------------------------------------------------------
/*/{Protheus.doc} GetComboBox
Função Responsavel para retornar o array contendo os valores do ComboBox
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@param cField, character, (Descrição do parâmetro)
@return aRetCBox, array contendo os valores do ComboBox
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function GetComboBox(cField)
Local aRetCBox   := {}
Do Case
    Case cField == "G6U_TPVIGE" .or. cField == "G6U_TPTOLE"
        aAdd(aRetCBox,STR0011)//"1=Dia"
        aAdd(aRetCBox,STR0012)//"2=Mes"
        aAdd(aRetCBox,STR0013)//"3=Ano"
        aAdd(aRetCBox,STR0014)//"4=Indeterminado"
                
        If cField == 'G6U_TPTOLE'
            aAdd(aRetCBox,STR0015)//"5=Não Possui"
        Endif

    Case cField == 'G6U_MSBLQL'
        aAdd(aRetCBox,"1="+STR0002)//Inativo
        aAdd(aRetCBox,"2="+STR0003)//Ativo
EndCase

Return aRetCBox