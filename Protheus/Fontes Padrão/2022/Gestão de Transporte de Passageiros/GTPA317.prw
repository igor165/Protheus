#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA317.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA317
'Cadastro de Tipos de Ocorrencia'
@type Function
@author Sidney.Jesus
@since 19/07/2019
@version 1.0
@return nil, retorna nulo
/*/
//------------------------------------------------------------------------------
Function GTPA317()

Local oBrowse       := FWMBrowse():New()

oBrowse:SetAlias('G6Q')
oBrowse:SetMenuDef('GTPA317')


oBrowse:SetDescription(STR0001)//'Cadastro de Tipos de Ocorrencia'

oBrowse:Activate()
oBrowse:Destroy()

GTPDestroy(oBrowse)

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author Sidney.Jesus
@since 19/07/2019
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

    ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.GTPA317' OPERATION OP_VISUALIZAR	ACCESS 0 // "Visualizar"
    ADD OPTION aRotina TITLE "Incluir"    ACTION 'VIEWDEF.GTPA317' OPERATION OP_INCLUIR		ACCESS 0 // "Incluir"
    ADD OPTION aRotina TITLE "Alterar"    ACTION 'VIEWDEF.GTPA317' OPERATION OP_ALTERAR		ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE "Excluir"    ACTION 'VIEWDEF.GTPA317' OPERATION OP_EXCLUIR		ACCESS 0 // "Excluir"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author Sidney.Jesus
@since 19/07/2019
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local oStrG6Q	:= FWFormStruct(1,'G6Q')

oModel := MPFormModel():New('GTPA317', /*bPreValidacao*/,{|oModel|GPT317AllOK(oModel)}, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('G6QMASTER',/*cOwner*/,oStrG6Q)

oModel:SetDescription(STR0001) //'Cadastro de Tipos de Ocorrencia'

oModel:GetModel('G6QMASTER'):SetDescription(STR0001) //'Cadastro de Tipos de Ocorrencia'

oModel:SetPrimaryKey({'G6Q_FILIAL','G6Q_CODIGO'})

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author Sidney.Jesus
@since 19/07/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA317')
Local oStrG6Q	:= FWFormStruct(2, 'G6Q')

oView:SetModel(oModel)

oView:AddField('VIEW_G6Q' ,oStrG6Q,'G6QMASTER')

oView:CreateHorizontalBox('TELA', 100)

oView:SetOwnerView('VIEW_G6Q','TELA')

oView:SetDescription(STR0001) //'Cadastro de Tipos de Ocorrencia'

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} GPT317AllOK(oModel)
description
@author  Sidney.Jesus
@since   19/07/2019
@version 1.0
/*///-------------------------------------------------------------------
Static Function GPT317AllOK(oModel)

	Local lRet		:= .T.
	Local oMdlG6Q	:= oModel:GetModel('G6QMASTER')
	
	
		If (!oMdlG6Q:GetValue("G6Q_PASSAG") .and. !oMdlG6Q:GetValue("G6Q_VEICUL") .and. !oMdlG6Q:GetValue("G6Q_OPERAC"))
			lRet := .F.
			oModel:SetErrorMessage(oMdlG6Q:GetId(),"",oMdlG6Q:GetId(),"",'GPT317AllOK',STR0002,STR0003) //"Nenhum tipo foi selecionado.","Não é permitido prosseguir, pois nenhuma configuração foi selecionada."
			
		ElseIf (oMdlG6Q:GetValue("G6Q_PASSAG") .and. oMdlG6Q:GetValue("G6Q_VEICUL") .and. oMdlG6Q:GetValue("G6Q_OPERAC"))
			lRet := .F.
			oModel:SetErrorMessage(oMdlG6Q:GetId(),"",oMdlG6Q:GetId(),"",'GPT317AllOK',STR0004,STR0005) //"Todos os tipos foram selecionadas.","A configuração selecionada não é permitida, pois só pode ser criado um tipo de ocorrência para cada recurso."
		
		
		ElseIf (oMdlG6Q:GetValue("G6Q_PASSAG") .and. oMdlG6Q:GetValue("G6Q_VEICUL"))
			lRet := .F.
			oModel:SetErrorMessage(oMdlG6Q:GetId(),"",oMdlG6Q:GetId(),"",'GPT317AllOK',STR0006,STR0007) //"Seleção informada invalida.","A configuração selecionada não é permitida, pois só pode ser criado um tipo de ocorrência para cada recurso."
		Endif
		
		If !ExistChav('G6Q',oMdlG6Q:GetValue("G6Q_CODIGO"))
			lRet := .F.
			oModel:SetErrorMessage(oMdlG6Q:GetId(),"",oMdlG6Q:GetId(),"",'GPT317AllOK',STR0008,STR0009) //"Código já existente na base","Código já existente na base"
		Endif
	
Return(lRet)



