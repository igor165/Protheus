#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA116.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA116
Cadastro de Passe Livre
@author  Renan Ribeiro Brando
@since   06/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GTPA116()

Local oBrowse := FWMBrowse():New()
oBrowse:SetAlias("G9Z")
oBrowse:SetDescription(STR0001) // "Cadastro de Passe Livre"
oBrowse:DisableDetails()
oBrowse:Activate()  

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu do cadasto
@author  Renan Ribeiro Brando
@since   06/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.GTPA116" OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GTPA116" OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GTPA116" OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GTPA116" OPERATION 5 ACCESS 0 // Excluir

Return aRotina  


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo de dados do cadastro
@author  Renan Ribeiro Brando
@since   03/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruG9Z := FWFormStruct(1, "G9Z")
Local bPosvalid	:= {|oModel| PosValid(oModel)}
Local oModel := MPFormModel():New("GTPA116",/*bPreValidMdl*/, bPosValid, /*bCommit*/, /*bCancel*/ )
Local aTrigger  := {}


// Gatilho para descrição da agência
aTrigger := FwStruTrigger("G9Z_TPDOC","G9Z_DOCDES","Posicione('GYA', 1, xFilial('GYA') + FwFldGet('G9Z_TPDOC'),'GYA_DESCRI')" )	
oStruG9Z:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])

// Gatilho para descrição da agência
aTrigger := FwStruTrigger("G9Z_AGENCI","G9Z_DESCAG","Posicione('GI6', 1, xFilial('GI6') + FwFldGet('G9Z_AGENCI'),'GI6_DESCRI')" )	
oStruG9Z:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])

// Gatilho para descrição do colaborador
aTrigger := FwStruTrigger("G9Z_CODCOL","G9Z_DSCCOL","Posicione('GYG', 1, xFilial('GYG') + FwFldGet('G9Z_CODCOL'),'GYG_NOME')" )	
oStruG9Z:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])

// Gatilho para descrição da linha
aTrigger := FwStruTrigger("G9Z_CODLIN","G9Z_NOMLIN","TPNOMELINH(FwFldGet('G9Z_CODLIN'))" )	
oStruG9Z:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])

// Gatilho para Codigo Origem
aTrigger := FwStruTrigger("G9Z_CODSER","G9Z_CODORI","Posicione('GYN', 1, xFilial('GYN') + FwFldGet('G9Z_CODSER'),'GYN_LOCORI')" )	
oStruG9Z:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])

// Gatilho para Código Destino 
aTrigger := FwStruTrigger("G9Z_CODSER","G9Z_CODDES","Posicione('GYN', 1, xFilial('GYN') + FwFldGet('G9Z_CODSER'),'GYN_LOCDES')" )	
oStruG9Z:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])

// Gatilho para descrição da origem
aTrigger := FwStruTrigger("G9Z_CODORI","G9Z_DSCORI","Posicione('GI1', 1, xFilial('GI1') + FwFldGet('G9Z_CODORI'),'GI1_DESCRI')" )	
oStruG9Z:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])

// Gatilho para descrição do destino
aTrigger := FwStruTrigger("G9Z_CODDES","G9Z_DSCDES","Posicione('GI1', 1, xFilial('GI1') + FwFldGet('G9Z_CODDES'),'GI1_DESCRI')" )	
oStruG9Z:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])

// Gatilho para descrição do departamento solicitante
aTrigger := FwStruTrigger("G9Z_CODDPS","G9Z_DPTSOL","Posicione('SQB', 1, xFilial('SQB') + FwFldGet('G9Z_CODDPS'),'QB_DESCRIC')" )	
oStruG9Z:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])

// Gatilho para descrição do departamento autorizador
aTrigger := FwStruTrigger("G9Z_CODDPA","G9Z_DPTAUT","Posicione('SQB', 1, xFilial('SQB') + FwFldGet('G9Z_CODDPA'),'QB_DESCRIC')" )	
oStruG9Z:AddTrigger(aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4])

// Validação das horas do dia do modelo
oStruG9Z:SetProperty('G9Z_HORA', MODEL_FIELD_VALID, {|oModel| VldHora(oModel) } )

// Validação da data de vencimento do passe
oStruG9Z:SetProperty('G9Z_DATVAL', MODEL_FIELD_VALID, {|oModel| VldDate(oModel, "VALIDADE") } )

// Validação da data de embarque do passageiro
oStruG9Z:SetProperty('G9Z_DATEMB', MODEL_FIELD_VALID, {|oModel| VldDate(oModel, "EMBARQUE") } )

// Validação Agência/Usuário
oStruG9Z:SetProperty('G9Z_AGENCI',MODEL_FIELD_VALID, {|oMdl,cField,cNewValue,cOldValue| ValidUserAg(oMdl,cField,cNewValue,cOldValue) } )


oModel:SetDescription(STR0001) // "Cadastro de Passe Livre"
oModel:AddFields("G9ZMASTER", , oStruG9Z)

Return oModel   


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View do mdoelo de dados
@author  Renan Ribeiro Brando
@since   06/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel := ModelDef()
Local oStruG9Z := FWFormStruct(2, "G9Z")

oStruG9Z:SetProperty("G9Z_CODORI", MVC_VIEW_CANCHANGE, .F.)

oStruG9Z:SetProperty("G9Z_CODDES", MVC_VIEW_CANCHANGE, .F.)

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW", oStruG9Z, "G9ZMASTER")

oView:CreateHorizontalBox("BOX", 100)
oView:SetOwnerView("VIEW","BOX")

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} VldDate(oModel, cType)
Validação do dia com a data atual
@author  Renan Ribeiro Brando
@since   10/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function VldDate(oModel, cType)

Local dDate

    If cType == "VALIDADE"
        dDate := oModel:GetValue("G9Z_DATVAL")
        
        If dDate < oModel:GetValue("G9Z_DATEMB")
            Return .F.
        EndIf

    ElseIf cType == "EMBARQUE"
        dDate := oModel:GetValue("G9Z_DATEMB")

        If dDate > oModel:GetValue("G9Z_DATVAL") .AND. !EMPTY(oModel:GetValue("G9Z_DATVAL"))
            Return .F.
        EndIf
        
    EndIf

    If dDate < DDATABASE
        Return .F.
    EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldHora(oModel)
Validação das horas do dia
@author  Renan Ribeiro Brando
@since   10/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function VldHora(oModel)

Local cTime := oModel:GetValue("G9Z_HORA")
Local cHour := SubStr(cTime, 1, 2)
Local cMinutes := SubStr(cTime, 4, 2)

    
    // Valida horas, minutos e segundos
    If Val(cHour) < 0
        Return .F.
    ElseIf Val(cHour) > 23
        Return .F.
    ElseIf Val(cMinutes) > 59
        Return .F.
    EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PosValid(oModel)
Pos validação do modelo
@author  Renan Ribeiro Brando
@since   10/10/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function PosValid(oModel)

// Validação de chave duplicada
Return ExistChav("G9Z", oModel:GetValue("G9ZMASTER", "G9Z_CODIGO"))

