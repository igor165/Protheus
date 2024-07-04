#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'ubsa030.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} UBSA030A(cFil, cMoega)
Locais da Moega
@type function
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function UBSA030A(cFil, cMoega)

    Local oBrowse as object

    If cFil != FWxFilial('NL6')
        //'Selecione a filial correta na abertura do Browse: ', 'Filial Incorreta'
        MsgAlert(STR0010 + cFil, STR0011)
        Return
    EndIf

    If !TableInDic('NL6')
        // necessário a atualização do sistema para a expedição mais recente
        MsgNextRel()
    Else
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias('NL6')
        oBrowse:SetDescription(STR0006)
        oBrowse:SetMenuDef('UBSA030A')

        If !Empty(cMoega)
            oBrowse:SetFilterDefault("NL6_FILIAL == '"+cFil+"' .AND. NL6_MOEGA == '"+cMoega+"' ")
        EndIf

        oBrowse:AddLegend({||statusLeg() } , "Green",STR0013)//"Ativo"
		oBrowse:AddLegend({||!statusLeg()} , "Red"  ,STR0014)//"Inativo"

        oBrowse:Activate()
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

    ADD OPTION aMenu Title STR0002 Action 'VIEWDEF.UBSA030A' OPERATION 2 ACCESS 0
    ADD OPTION aMenu Title STR0003 Action 'VIEWDEF.UBSA030A' OPERATION 3 ACCESS 0
    ADD OPTION aMenu Title STR0004 Action 'VIEWDEF.UBSA030A' OPERATION 4 ACCESS 0
    ADD OPTION aMenu Title STR0005 Action 'VIEWDEF.UBSA030A' OPERATION 5 ACCESS 0

Return aMenu
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Construção de modelo de dados
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

    Local oModel as object
    Local oStructNL6 as object
    Local aProdTrigger as array

    aRelation := {}

    oModel := MPFormModel():New('UBSA030A')

    oStructNL6 := FWFormStruct(1,'NL6')

    oStructNL6:SetProperty('NL6_DTINI', MODEL_FIELD_VALID, {|oModel, cField, dValue | VldData(oModel, cField, dValue)})
    oStructNL6:SetProperty('NL6_DTFIM', MODEL_FIELD_VALID, {|oModel, cField, dValue | VldData(oModel, cField, dValue)})

    oStructNL6:SetProperty('NL6_HRINI', MODEL_FIELD_VALID, {|oModel, cField, cValue | VldHora(oModel, cField, cValue)})
    oStructNL6:SetProperty('NL6_HRFIM', MODEL_FIELD_VALID, {|oModel, cField, cValue | VldHora(oModel, cField, cValue)})

    oStructNL6:SetProperty('NL6_PRODUT', MODEL_FIELD_VALID, {|oModel, cField, cValue | ExistCpo('SB1', cValue, 1)})

    aProdTrigger := FwStruTrigger(;
        "NL6_PRODUT" ,; // Campo Dominio
        "NL6_PRDDES"  ,; // Campo de Contradominio
        "Posicione('SB1',1,xFilial('SB1')+FwFldGet('NL6_PRODUT'), 'B1_DESC')",; // Regra de Preenchimento
        .F. ,; // Se posicionara ou nao antes da execucao do gatilhos
        ""  ,; // Alias da tabela a ser posicionada
        0   ,; // Ordem da tabela a ser posicionada
        ""  ,; // Chave de busca da tabela a ser posicionada
        NIL ,; // Condicao para execucao do gatilho
        "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)

    oStructNL6:AddTrigger(aProdTrigger[1], aProdTrigger[2], aProdTrigger[3], aProdTrigger[4])

    oModel:AddFields('NL6_MASTER_MODEL',, oStructNL6)

    oModel:InstallEvent('UBSA030AE',, UBSA030AE():New())

    oModel:SetPrimaryKey({})

    oModel:SetDescription(STR0006)

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
    Local oStructNL6 as object

    oModel := FWLoadModel('UBSA030A')

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oStructNL6 := FWFormStruct(2,'NL6')

    oView:AddField('NL6_MASTER_VIEW', oStructNL6, 'NL6_MASTER_MODEL')

    oView:CreateHorizontalBox('BOX_MASTER_NL6', 100)

    oView:EnableTitleView('NL6_MASTER_VIEW', STR0006)

    oView:SetOwnerView('NL6_MASTER_VIEW', 'BOX_MASTER_NL6')

    oView:SetCloseOnOk({||.T.})

Return oView

/*/{Protheus.doc} statusLeg
Função para a Legenda na grid locais da moega
@type function
@version P12
@author claudineia.reinert
@since 03/06/2022
@return Logical, Valor Logico
/*/
Static function statusLeg()
    Local cTime := Time()
    Local dData := DATE()
    
    cTime := SubStr(cTime,1,2)+SubStr(cTime,4,2) //formato o cTime igual campo de hora(NL6_HRINI e NL6_HRFIM)

    If (!Empty(NL6->NL6_DTINI) .AND. (dData < NL6->NL6_DTINI .OR. (dData = NL6->NL6_DTINI .AND. cTime < NL6->NL6_HRINI)))
        Return .F.
    EndIf
        
    If (!Empty(NL6->NL6_DTFIM) .AND. (dData > NL6->NL6_DTFIM .OR. (dData = NL6->NL6_DTFIM .AND. cTime > NL6->NL6_HRFIM)))
        Return .F.
    EndIf    

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldData(oModel, cField, dValue)
Valida se a data atende as regras de cadastro
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function VldData(oModel, cField, dValue)

    Local lRet as logical
    Local dData as date

    lRet := .T.

    If cField == 'NL6_DTINI'

        dData := oModel:GetValue('NL6_DTFIM')
        // data inicio não pode ser menor que data atual e não pode ser mario que data fim (caso preenchida)
        If dValue < Date() .or. !Empty(dData) .and. dData <= dValue
            lRet := .F.
        EndIf

    ElseIf cField == 'NL6_DTFIM'

        dData := oModel:GetValue('NL6_DTINI')
        //data fim não pode ser menor que data atual ou menor que a data inicial
        If !Empty(dValue) .and. (dValue < Date() .or. dValue < dData)
            lRet := .F.
        ElseIf Empty(dValue)
            // se o valor da data fim for vazio, apagar a hora fim
            oModel:LoadValue('NL6_HRFIM', '')
        EndIf

    EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} VldHora(oModel, cField, cValue)
Valida se as horas atendem as regras de cadastro
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function VldHora(oModel, cField, cValue)

    Local cHora as char
    Local dDataIni as date
    Local dDataFim as date
    Local cHoraAtu as char
    Local lRet as logical

    lRet := .T.

    cHoraAtu := StrTran(SubStr(Time(), 1, 6), ':', '')
    dDataFim := oModel:GetValue('NL6_DTFIM')
    dDataIni := oModel:GetValue('NL6_DTINI')

    If cField == 'NL6_HRINI'

        cHora := oModel:GetValue('NL6_HRFIM')
        // hora inicial tem que estar no formato 24h59m, caso a data inicial seja o mesmo dia, não pode ser menor que a hora atual
        // caso exista hora fim preenchida e a data fim é igual a inicio, hora inicial não pode ser maior que a final
        If !AtVldHora(cValue) .or. ;
                (dDataIni == Date() .and. cHoraAtu > cValue) .or. ;
                (!Empty(dDataFim) .and. dDataIni == dDataFim .and. cValue > cHora)
            lRet := .F.
        EndIf

    ElseIf cField == 'NL6_HRFIM'

        cHora := oModel:GetValue('NL6_HRINI')
        // hora fim tem que estar no formato 24h59m, caso a data fim seja o mesmo dia, não pode ser menor que a hora atual
        // caso exista hora inicio preenchida e a data fim é igual a inicio a hora fim não pode ser manor que a inicial
        If !AtVldHora(cValue) .or. ;
                (dDataFim == Date() .and. cHoraAtu > cValue) .or. ;
                (!Empty(dDataIni) .and. dDataIni == dDataFim .and. cValue < cHora) .and. !Empty(cValue)
            lRet := .F.
        EndIf
    EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} Class UBSA030AE
Classe para validar a ativação do modelo
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Class UBSA030AE From FWModelEvent

    Method New()
    Method VldActivate()
    Method ModelPosVld()

EndClass
//-------------------------------------------------------------------
/*/{Protheus.doc} Method New() Class UBSA030AE
Instância a classe de evento
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Method New() Class UBSA030AE
Return Self
//-------------------------------------------------------------------
/*/{Protheus.doc} Method VldActivate(oModel, cModelId) Class UBSA030AE
Realiza a validação de filial na ativação do modelo,
como a tabela é exclusiva, é solicitada a filial em cada operação.
Com isso é necessário garantir que as filiais sejam as mesmas
@author  Lucas Briesemeister
@since   11/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Method VldActivate(oModel, cModelId) Class UBSA030AE

    Local lRet as logical

    lRet := .T.

    If oModel:GetOperation() == MODEL_OPERATION_INSERT .and. FWxFilial('NL6') != NL5->NL5_FILIAL
        lRet := .F.
        // "Erro",'Filial Incorreta', 'Selecione a filial correta para cadastro: '
        oModel:SetErrorMessage('NL6_MASTER_MODEL', 'NL6_FILIAL', 'NL6_MASTER_MODEL' , 'NL6_FILIAL' , STR0007,;
            STR0011 , STR0012 + NL5->NL5_FILIAL)
    EndIf

REturn lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} Method ModelPosVld(oModel, cModelId) Class UBSA030AE
Realiza as validações de locais já cadastrados no mesmo período
@author  Lucas Briesemeister
@since   01/2021
@version 12.1.27
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class UBSA030AE

    Local cAlias as char
    Local cDataIni as char
    Local cDataFim as char
    Local cHoraIni as char
    Local cHoraFim as char
    Local cWhere as char
    Local lRet as logical
	Local cExpDt as char
	Local lOverLap as logical

    cWhere := '% 1 = 1 %'
	cExpDt := '% %'
	lOverLap:= .F.

    If oModel:GetOperation() == MODEL_OPERATION_DELETE
        Return .T.
    ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE
        cWhere := '% NL6.R_E_C_N_O_ <> '+cValToChar(NL6->(Recno()))+'%'
    EndIf

    lRet := .T.

    cDataFim := DToS(oModel:GetValue('NL6_MASTER_MODEL', 'NL6_DTFIM'))
    cDataIni := DToS(oModel:GetValue('NL6_MASTER_MODEL', 'NL6_DTINI'))

    cHoraIni := oModel:GetValue('NL6_MASTER_MODEL', 'NL6_HRINI')
    cHoraFim := oModel:GetValue('NL6_MASTER_MODEL', 'NL6_HRFIM')

	cAlias := GetNextAlias()

    BeginSql Alias cAlias
        SELECT NL6_DTINI, NL6_HRINI, NL6_DTFIM, NL6_HRFIM
        FROM %table:NL6% NL6
        WHERE %exp:cWhere%
			AND NL6.%notDel%
            AND NL6.NL6_FILIAL = %exp:FWxFilial('NL6')%
            AND NL6.NL6_LOCAL = %exp:oModel:GetValue('NL6_MASTER_MODEL', 'NL6_LOCAL')%
			AND NL6.NL6_MOEGA = %exp:oModel:GetValue('NL6_MASTER_MODEL', 'NL6_MOEGA')%
            
    EndSql
	
	while (cAlias)->(!EOF()) .AND. !lOverLap

		
		if cDataIni == (cAlias)->NL6_DTINI //se a data de início for igual a data de início de outro registro, verificar se a hora de início está dentro do período
			if cHoraIni >= (cAlias)->NL6_HRINI //Se a hora de início for maior que a hora de início que já existe, então deve verificar se o horário de fim está dentro do período
				if (cAlias)->(NL6_DTFIM+NL6_HRFIM) >= cDataIni+cHoraIni
					lOverLap := .T.
				Elseif Empty((cAlias)->(NL6_DTFIM+NL6_HRFIM))
					lOverLap := .T.
				endif
			Else //se for menor, deve verificar se a data final acaba antes da data inicial do registro já existente
				if cDataFim == (cAlias)->NL6_DTINI
					if cHoraFim >= (cAlias)->NL6_HRINI
						lOverLap := .T.
					endif
				ElseIf cDataFim > (cAlias)->NL6_DTINI
					lOverLap := .T.
				ElseIf empty(cDataFim)
					lOverLap := .T.
				endif
			endif
		ElseIf cDataIni+cHoraIni > (cAlias)->(NL6_DTINI+NL6_HRINI) //se a data/hora inicial for maior que a data hora inicial já existente, então deve verificar se a hora inicial é menor que a hora final já existente
			if cDataIni+cHoraIni <= (cAlias)->(NL6_DTFIM+NL6_HRFIM)
				lOverLap := .T.
			ElseIf Empty((cAlias)->(NL6_DTFIM+NL6_HRFIM))
				lOverLap := .T.
			endif
		ElseIf cDataIni+cHoraIni < (cAlias)->(NL6_DTINI+NL6_HRINI)
			if cDataFim+cHoraFim == (cAlias)->(NL6_DTINI+NL6_HRINI)
				lOverLap := .T.
			ElseIf cDataFim+cHoraFim >= (cAlias)->(NL6_DTINI+NL6_HRINI)
				lOverLap := .T.
			endif
		endif

 		(cAlias)->(dbSkip())
	endDo

    If lOverLap
        Help(NIL, NIL, STR0007, NIL, STR0015, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0016})// Erro; 'Já existe agendamento para este local que compreende este período'; 'Informe outro período'
    EndIf

Return !lOverLap
