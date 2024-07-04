#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDef.ch'
#INCLUDE 'GPEM924.ch'

Static cMsgSucesso := STR0001//"Segundo Passo"


/*/{Protheus.doc} GPEM924
    Monitor de Processamento da Integra��o GPE x NG

    @type  Function
    @author rafaelalmeida
    @since 05/06/2020
    @version 12.1.27

/*/
Function GPEM924()

Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias("RJP")
oBrowse:SetDescription(OemToAnsi(STR0002)) //"Monitor Integra��o NG"

//Define as legendas
oBrowse:AddLegend('!Empty(RJP->RJP_DTIN) .And. AllTrim(RJP->RJP_RTN) == "'+STR0001+'" '  ,"BR_VERDE" 		,STR0003)//"Segundo Passo"##"Processado"
oBrowse:AddLegend('Empty(RJP->RJP_DTIN) '                                                ,"BR_AZUL" 	    ,STR0004)//"Pendente"
oBrowse:AddLegend('!Empty(RJP->RJP_DTIN) .And. AllTrim(RJP->RJP_RTN) <> "'+STR0001+'" '  ,"BR_VERMELHO" 	,STR0005)//"Segundo Passo"##"Falha"

oBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
    Carrega as op��es de menu.

    @type  Function
    @author rafaelalmeida
    @since 05/06/2020
    @version 12.1.27
    
    @return aRotina, Array, Array com as op��es de Menu
    
/*/
Static Function MenuDef()

Local aRotina := {}

Add Option aRotina Title STR0006    Action "VIEWDEF.GPEM924"   Operation 2 Access 0//"Visualizar"
Add Option aRotina Title STR0007    Action "GPEM924MNU(1)"      Operation 4 Access 0//"Reenvio"
Add Option aRotina Title STR0008    Action "GPEM924MNU(2)"      Operation 5 Access 0//"Excluir"


    
Return aRotina

/*/{Protheus.doc} ModelDef
    Repons�vel pela montagem do modelo

    @type  Static Function
    @author rafaelalmeida
    @since 05/06/2020
    @version 12.1.27
    
    @return oModel, Object, Objeto do Modelo
    
    /*/
Static Function ModelDef()

Local oModel     
Local oStruRJP	:= FwFormStruct(1,"RJP") 

oModel := MPFormModel():New("GPEM924",/*bPreValidacao*/,/*bTudoOk*/,/*bCommit*/,/*bCancel*/)

oModel:AddFields("RJPMASTER",/*Owner*/,oStruRJP)
oModel:SetPrimaryKey({'RJP_FILIAL','RJP_FIL','RJP_MAT'})

                                                                                
oModel:SetDescription(OemToAnsi(STR0002))//"Monitor Integra��o NG"

oModel:GetModel("RJPMASTER"):SetDescription(OemToAnsi(STR0002))//"Monitor Integra��o NG"

Return oModel

/*/{Protheus.doc} ViewDef
    Respons�vel pela montagem da View

    @type  Static Function
    author rafaelalmeida
    @since 05/06/2020
    @version 12.1.27
    
    @return oView, Object, Objeto View
/*/
Static Function ViewDef(param_name)
    
Local oModel:= FwLoadModel("GPEM924") 
Local oStruRJP := FwFormStruct(2,"RJP")
Local oView := FwFormView():New()

oView:SetModel(oModel)

oView:AddField("VIEW_RJP",oStruRJP,"RJPMASTER")

oView:CreateHorizontalBox("SUPERIOR",100,,,,)

oView:SetOwnerView("VIEW_RJP","SUPERIOR")

Return oView

/*/{Protheus.doc} GPEM924MNU
    
    Fun��o para chamar as static functions.

    @type  Function
    @author rafaelalmeida
    @since 05/06/2020
    @version version
    @param nTipo, Numeric, Determina qual static ser� acionada pelo menu.
    
    /*/
Function GPEM924MNU(nTipo)

Default nTipo := 0

Do Case
    Case nTipo == 1 //Limpeza do campo RJ_DTIN
        ClearDTIn()
    Case nTipo == 2// Exclus�o do registro.
        DelRjp()
EndCase

Return Nil

/*/{Protheus.doc} ClearDtIn
    
    Limpa o campo RJ_DTIN

    @type  Static Function
    @author rafaelalmeida

    @since 05/06/2020
    @version 12.1.27
    
/*/
Static Function ClearDTIn()


Local aAreOld := {RJP->(GetArea()),GetArea()}

If Upper(AllTrim(RJP->RJP_RTN)) <>  Upper(Alltrim(cMsgSucesso))
    If MsgNoYes(STR0010)//"Tem certeza que deseja disponibilizar este registro para reenvio?"
        RecLock('RJP',.F.)
        RJP->RJP_DTIN   := StoD('')
        RJP->RJP_HORAIN := ''
        RJP->RJP_RTN    := ''
        RJP->(MsUnlock())
        MsgInfo(STR0011,STR0012)//"Registro disponbilizado para reenvio!"##"GPEM924 - Reenvio"
    else
        MsgInfo(STR0013,STR0012)//"Reenvio cancelado!"##"GPEM924 - Reenvio"
    EndIf
else
    MsgAlert(STR0014)//"N�o � poss�vel reenviar registros processados com sucesso!"
EndIf

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return Nil

/*/{Protheus.doc} DelRJP
    Exclui o registro da RJP.

    @type  Static Function
    @author rafaelalmeida

    @since 05/06/2020
    @version 12.1.27
    
    
    /*/
Static Function DelRJP()

Local aAreOld := {RJP->(GetArea()),GetArea()}

If Empty(RJP->RJP_DTIN) 
    If MsgNoYes(STR0015)//"Tem certeza que deseja excluir o registro posicionado?"
        RecLock('RJP',.F.)
        RJP->(dbDelete())
        RJP->(MsUnlock())
        MsgInfo(STR0016,STR0017)//"Registro excluido com sucesso!"##"GPEM924 - Exclus�o"
    Else
        MsgInfo(STR0018,STR0017)//"Exclus�o cancelada!"##"GPEM924 - Exclus�o"
    EndIf
else
    MsgStop(STR0019)//"N�o � poss�vel excluir registros j� enviados!"
EndIf

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return 


