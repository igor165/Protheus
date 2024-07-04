#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA316.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA316VEI
Função responsavel pela browse da amarração de Veículo x documentos
@type Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Function GTPA316VEI()
Local oBrowse   := FWLoadBrw('GTPA316')

oBrowse:SetMenuDef('GTPA316VEI')
oBrowse:SetDescription(STR0027)//'Amarração do Veículo x Documento'

oBrowse:SetFilterDefault ( " G6V_TRECURS == '2' ")//Filtra apenas registros de Veículo

oBrowse:Activate()
oBrowse:Destroy()

GTPDestroy(oBrowse)
 
Return oBrowse

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

    ADD OPTION aRotina TITLE STR0023    ACTION 'VIEWDEF.GTPA316VEI' OPERATION OP_VISUALIZAR	    ACCESS 0 // "Visualizar"
    ADD OPTION aRotina TITLE STR0024    ACTION 'VIEWDEF.GTPA316VEI' OPERATION OP_INCLUIR		ACCESS 0 // "Incluir"
    ADD OPTION aRotina TITLE STR0025    ACTION 'VIEWDEF.GTPA316VEI' OPERATION OP_ALTERAR		ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE STR0026    ACTION 'VIEWDEF.GTPA316VEI' OPERATION OP_EXCLUIR		ACCESS 0 // "Excluir"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView         := FwLoadView('GTPA316')
Local oModel        := oView:GetModel()
Local oStrMdlG6V    := oModel:GetModel('G6VMASTER'):GetStruct() 
Local oStrViwG6V    := oView:GetViewStruct('VIEW_G6V')

SetModelStruct(oStrMdlG6V)
SetViewStruct(oStrViwG6V)

oModel:SetDescription(STR0027)  //'Amarração do Veículo x Documento'
oView:SetDescription(STR0027)   //'Amarração do Veículo x Documento'

Return oView


//------------------------------------------------------------------------------
/*/{Protheus.doc} SetModelStruct
Função responsavel pela estrutura de dados do modelo
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@param oStrG6V, object, (Descrição do parâmetro)
@param oStrG6W, object, (Descrição do parâmetro)
@return nil, retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStrG6V,oStrG6W)

oStrG6V:SetProperty('G6V_RECURS'	, MODEL_FIELD_TAMANHO	,TamSx3('T9_CODBEM')[1] )
oStrG6V:SetProperty('G6V_DRECUR'	, MODEL_FIELD_TAMANHO	,TamSx3('T9_NOME')[1] )

oStrG6V:SetProperty('G6V_TRECUR'	,MODEL_FIELD_INIT	    ,{||'2'})//Veículo

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetViewStruct
Função responsavel pela estrutura de dados da view
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@param oStrG6V, object, (Descrição do parâmetro)
@param oStrG6W, object, (Descrição do parâmetro)
@return nil, retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStrG6V,oStrG6W)

oStrG6V:SetProperty("G6V_RECURS"	,MVC_VIEW_LOOKUP		, 'ST9' )

Return