#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'ubsa030.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} UBSA030()
Cadastro de Moega
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function UBSA030()

    Private oBrowseMoe as object

    If !TableInDic('NL5')
        // necessário a atualização do sistema para a expedição mais recente
        MsgNextRel()
    Else
        oBrowseMoe := FWMBrowse():New()
        oBrowseMoe:SetAlias('NL5')
        oBrowseMoe:SetDescription(STR0001)
        oBrowseMoe:SetMenuDef('UBSA030')

        oBrowseMoe:AddLegend('UBSA030ST()' , "Green",STR0013)//"Ativo"
		oBrowseMoe:AddLegend('!UBSA030ST()', "Red"  ,STR0014)//"Inativo"
       
        oBrowseMoe:Activate()
    EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Construção de menu padrão
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

    Local aMenu as array

    aMenu := {}

    ADD OPTION aMenu Title STR0002 Action 'VIEWDEF.UBSA030' OPERATION 2 ACCESS 0
    ADD OPTION aMenu Title STR0003 Action 'VIEWDEF.UBSA030' OPERATION 3 ACCESS 0
    ADD OPTION aMenu Title STR0004 Action 'VIEWDEF.UBSA030' OPERATION 4 ACCESS 0
    ADD OPTION aMenu Title STR0005 Action 'VIEWDEF.UBSA030' OPERATION 5 ACCESS 0
    ADD OPTION aMenu Title STR0006 Action 'UBS030LOC()'   OPERATION 4 ACCESS 0

Return aMenu
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Construção de modelo de dados
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/'
//-------------------------------------------------------------------
Static Function ModelDef()

    Local oModel as object
    Local oStructNL5 as object

    aRelation := {}

    oModel := MPFormModel():New('UBSA030')

    oStructNL5 := FWFormStruct(1,'NL5')

    oStructNL5:SetProperty('NL5_MOEGA', MODEL_FIELD_VALID, {|oModel| ExistChav('NL5', oModel:GetValue('NL5_MOEGA'), 1)})
    oStructNL5:SetProperty('NL5_MOEGA', MODEL_FIELD_WHEN, {|oModel| oModel:GetOperation() == MODEL_OPERATION_INSERT })

    oModel:AddFields('NL5_MASTER_MODEL',, oStructNL5)

    oModel:SetPrimaryKey({'NL5_FILIAL','NL5_MOEGA'})

    oModel:InstallEvent('UBSA030E', , UBSA030E():New())

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Construção do objeto de view
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

    Local oView as object
    Local oModel as object
    Local oStructNL5 as object
    Local oStructNL6 as object

    oModel := FWLoadModel('UBSA030')

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oStructNL5 := FWFormStruct(2,'NL5')
    oStructNL6 := FWFormStruct(2,'NL6')

    oView:AddField('NL5_MASTER_VIEW', oStructNL5, 'NL5_MASTER_MODEL')

    oView:CreateHorizontalBox('BOX_MASTER_NL5', 100)

    oView:EnableTitleView('NL5_MASTER_VIEW', STR0001)

    oView:SetOwnerView('NL5_MASTER_VIEW', 'BOX_MASTER_NL5')

    oView:SetCloseOnOk({||.T.})

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} UBS030LOC()
Abre browse de locais
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function UBS030LOC()
    UBSA030A(NL5->NL5_FILIAL, NL5->NL5_MOEGA)
    oBrowseMoe:Refresh()
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Class UBSA030E From FWModelEvent
Classe para validar a exclusão da moega antes do commit
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Class UBSA030E From FWModelEvent

    Method New()
    Method ModelPosVld()

EndClass
//-------------------------------------------------------------------
/*/{Protheus.doc} Method New() Class UBSA030E
Instância a classe de evento
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Method New() Class UBSA030E
Return Self
//-------------------------------------------------------------------
/*/{Protheus.doc} Method ModelPosVld(oModel, cModelId) Class UBSA030E
Realiza a validação se não existem locais relacionados com a moega
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class UBSA030E

    Local lRet as logical

    lRet := .T.

    DBSelectArea('NL6')
    NL6->(DBSetOrder(1))
    If oModel:GetOperation() == MODEL_OPERATION_DELETE .and. ;
            NL6->(DBSeek(FWxFilial('NL6') + oModel:GetModel('NL5_MASTER_MODEL'):GetValue('NL5_MOEGA')))
        lRet := .F.
        //'Erro','Existem locais relacionados a moega', 'Remova os locais relacionados antes de remover a moega'
        oModel:SetErrorMessage('NL5_MASTER_MODEL', 'NL5_MOEGA', 'NL5_MASTER_MODEL' , 'NL6_MOEGA' , STR0007, STR0008, STR0009)
    EndIf

REturn lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} UBSA030ST(nStatus)
Verifica se possui locais disponíveis na moega
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function UBSA030ST()

    Local cAlias as char
    Local cTime as char
    Local lFound as logical

    lFound := .F.

    cAlias := GetNextAlias()

    BeginSql Alias cAlias
        SELECT NL6_DTINI,
            NL6_HRINI,
            NL6_DTFIM,
            NL6_HRFIM
		FROM %table:NL6%
		WHERE NL6_FILIAL   = %Exp:NL5->NL5_FILIAL%
		    AND NL6_MOEGA  = %Exp:NL5->NL5_MOEGA%
            AND %notDel%
    EndSql

    If (cAlias)->(!Eof())
        cTime := Time()
        cTime := StrTran(cTime,':','')
        While ((cAlias)->(!EOF()) .AND. !lFound)
            If (DToS(dDataBase) == (cAlias)->NL6_DTINI) //se a data atual for igual a data de inicio , entao deve verificar a hora
                If (cTime >= (cAlias)->NL6_HRINI)
                    If VldDtFim((cAlias)->NL6_DTFIM, (cAlias)->NL6_HRFIM)
                        lFound := .T.
                    EndIf
                EndIf
            ElseIf (DToS(dDataBase) > (cAlias)->NL6_DTINI )// se a data de atual for maior que a data de inicio, entao deve verificar o
                If VldDtFim((cAlias)->NL6_DTFIM, (cAlias)->NL6_HRFIM)
                    lFound := .T.
                EndIf
            EndIf
            (cAlias)->(dbSkip())
        EndDo
    EndIf
    (cAlias)->(dbCloseArea())

Return lFound
//-------------------------------------------------------------------
/*/{Protheus.doc} VldDtFim(dDtFim,horaFim)
Verifica se a data está dentro da data final
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
static Function VldDtFim(dDtFim,horaFim)
	Local lRet as logical
	Local cTime as char  

    lRet := .F.
    cTime := Time()
	cTime := StrTran(cTime,':','')

	If !Empty(dDtFim)//Se a data e hora iniciais estiverem ok, verifica data final ( se existir )
		If (DToS(dDataBase) < dDtFim)
			lRet := .T.
		ElseIf (DToS(dDataBase) == dDtFim)
			If !Empty(horaFim)
				If (cTime <= horaFim)
					lRet := .T.
				EndIf
			EndIf
		EndIf
	Else
		lRet:= .T.
	EndIf

Return lRet

