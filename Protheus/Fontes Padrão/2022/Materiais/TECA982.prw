#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWBROWSE.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} TECA982()
Rotina de bloqueio de saldos
@author Matheus Lando Raimundo
@since 05/09/16 
@return oModel
/*/
//-------------------------------------------------------------------
Function TECA982()
Local oBrowse	:= Nil
Local nX	:= 0
Local aLegenda := {}
Local aLegBlq := 		{"",{|| At982LegBlq() },"C","@BMP",0,1,0,.F.,{||.T.},.T.,{|| At982DesLeg() },,,,.F.}
	 
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('TWU')
oBrowse:SetDescription('Saldos Bloqueados')

oBrowse:AddColumn(aLegBlq)

Aadd(aLegenda, {"TWU_TIPO == '1'", "GREEN", "Reserva de equipamento"}) 
Aadd(aLegenda, {"TWU_TIPO == '2'", "BLUE"  , "Ordem de serviço"}) 
Aadd(aLegenda, {"TWU_TIPO == '3'", "RED" , "Inclusão manual de bloqueio "})

For nX := 1 to len(aLegenda)
	oBrowse:AddLegend(aLegenda[nX][1], aLegenda[nX][2], aLegenda[nX][3])	
Next nX

oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef da Rotina de bloqueio de saldos
@author Matheus Lando Raimundo
@since 05/09/16 
@return oModel
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar'  ACTION 'VIEWDEF.TECA982' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Bloquear'    ACTION 'At892Bloq()' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Desbloquear' ACTION 'At892DesBl()' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'     ACTION 'At892Exc()' OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'     ACTION 'At892Alt()' OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'    ACTION 'VIEWDEF.TECA982' OPERATION 8 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
ModelDef da Rotina de bloqueio de saldos
@author Matheus Lando Raimundo
@since 05/09/16 
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruTWU := FWFormStruct( 1, 'TWU', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel	:= Nil

oModel := MPFormModel():New('TECA982')
oModel:AddFields( 'TWUMASTER', /*cOwner*/, oStruTWU, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetPrimaryKey( {} )
oModel:SetDescription( 'Saldos Bloqueados' )
oModel:GetModel( 'TWUMASTER' ):SetDescription( 'Saldos Bloqueados' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
ViewDef da Rotina de bloqueio de saldos
@author Matheus Lando Raimundo
@since 05/09/16 
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := ModelDef()
Local oStruTWU := FWFormStruct( 2, 'TWU' )
Local oView 	:= Nil

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_TWU', oStruTWU, 'TWUMASTER' )
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_TWU', 'TELA' )

oStruTWU:RemoveField('TWU_CODTEW')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} A892VldQtd()
Validação das quantidades
@author Matheus Lando Raimundo
@since 05/09/16 
@return oModel
/*/
//-------------------------------------------------------------------
Function A892VldQtd()
Local lRet := .T.
Local oModel := FwModelActive()
Local oTWUMaster	:= oModel:GetModel('TWUMASTER') 

If oTWUMaster:GetValue('TWU_QTDLIB') > oTWUMaster:GetValue('TWU_QTDBLQ')
	Help( , , "At982VldQtd", , "A Quantidade liberada não pode ser maior do que a quantidade bloqueada", 1, 0) 
	lRet := .F.
ElseIf IsInCallStack('At892Bloq') .And. oTWUMaster:GetValue('TWU_QTDBLQ') > oTWUMaster:GetValue('TWU_SLDDIS')
	Help( , , "At982SldDis", , "A quantidade bloqueada não pode ser maior do que a quantidade disponível", 1, 0)
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At892Saldo()
Alimenta o campo de saldo disponivel
@author Matheus Lando Raimundo
@since 05/09/16 
@return oModel
/*/
//-------------------------------------------------------------------
Function At892Saldo()
Local oModel	:= FwModelActive()
Local oTWUMaster	:= oModel:GetModel('TWUMASTER') 
Local oTecProvider	:= Nil
Local nRet			:= 0

If !Empty(oTWUMaster:GetValue('TWU_BASE'))
	oTecProvider := TecProvider():New(oTWUMaster:GetValue('TWU_BASE'))
	nRet := oTecProvider:SaldoDisponivel()
	TecDestroy(oTecProvider)
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At892Saldo()
Rotina de bloqueio de saldo
@author Matheus Lando Raimundo
@since 05/09/16 
@return oModel
/*/
//-------------------------------------------------------------------
Function At892Bloq(lAuto)
Local oModel := FwModelActive()

Default lAuto := .F.

If !lAuto
	FWExecView ("Bloquear", "TECA982", MODEL_OPERATION_INSERT)
Else
	oModel:GetModel("TWUMASTER"):GetStruct():SetProperty('TWU_BASE',MODEL_FIELD_WHEN,{||.T.})
	oModel:GetModel("TWUMASTER"):GetStruct():SetProperty('TWU_QTDBLQ',MODEL_FIELD_WHEN,{||.T.})
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At892DesBl()
Rotina de desbloqueio de saldo
@author Matheus Lando Raimundo
@since 05/09/16 
@return oModel
/*/
//-------------------------------------------------------------------
Function At892DesBl(lAuto)
Local oModel := FwModelActive()

Default lAuto := .F.

If TWU->TWU_TIPO == '3'
	If !lAuto
		FWExecView ("Desbloquear", "TECA982", MODEL_OPERATION_UPDATE)
	Else
		oModel:GetModel("TWUMASTER"):GetStruct():SetProperty('TWU_QTDLIB',MODEL_FIELD_WHEN,{||.T.})
	EndIf
Else
	Help( , , "At982NAlt", , "Não é possível movimentar registros gerados internamente",4,10)	
EndIf	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} At982LegBlq()
Legenda dos saldos
@author Matheus Lando Raimundo
@since 05/09/16 
@return oModel
/*/
//-------------------------------------------------------------------

Function At982LegBlq()
Local cLeg := ""

If TWU->TWU_QTDLIB == 0
	cLeg := "BR_VERMELHO"
ElseIf TWU_QTDLIB == TWU_QTDBLQ 
	cLeg := "BR_VERDE"
ElseIf	TWU->TWU_QTDLIB > 0
	cLeg := "BR_AZUL"
EndIf

Return cLeg

//-------------------------------------------------------------------
/*/{Protheus.doc} At982DesLeg()
Descrição da legenda de saldos
@author Matheus Lando Raimundo
@since 05/09/16 
@return oModel
/*/
//-------------------------------------------------------------------

Function At982DesLeg()
Local oLegenda  :=  FWLegend():New()

oLegenda:Add("","BR_VERDE","Saldo totalmente liberado") 	   	// "Evolução da venda em dia."
oLegenda:Add("","BR_AZUL","Saldo parcialmente liberado")  	// "Evolução da venda em alerta."
oLegenda:Add("","BR_VERMELHO","Saldo totalmente bloqueado") 		// "Evolução da venda em atraso." 

oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return( .T. )


//-------------------------------------------------------------------
/*/{Protheus.doc} At982DesLeg()
Exclusão de registro
@author Matheus Lando Raimundo
@since 05/09/16 
@return oModel
/*/
//-------------------------------------------------------------------
Function At892Exc(lAuto)

Default lAuto := .F.

If TWU->TWU_TIPO == '3'
	If TWU->TWU_QTDLIB == 0
		If !lAuto
			FWExecView ("Excluir", "TECA982", MODEL_OPERATION_DELETE)
		EndIf
	Else
		Help( , , "At982NAlt", , "Não é possível excluir este registro, pois já houve liberação da quantidade",4,10)
	EndIf
Else
	Help( , , "At982NAlt", , "Não é possível movimentar registros gerados internamente",4,10)
EndIf		

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} At892Alt()
Alteração de registro
@author Matheus Lando Raimundo
@since 05/09/16 
@return oModel
/*/
//-------------------------------------------------------------------
Function At892Alt(lAuto)
Local oModel := FwModelActive()

Default lAuto := .F.

If TWU->TWU_TIPO == '3'
	If TWU->TWU_QTDLIB == 0
		If !lAuto
			FWExecView ("Alterar", "TECA982", MODEL_OPERATION_UPDATE)
		Else
			oModel:GetModel("TWUMASTER"):GetStruct():SetProperty('TWU_BASE',MODEL_FIELD_WHEN,{||.T.})
			oModel:GetModel("TWUMASTER"):GetStruct():SetProperty('TWU_QTDBLQ',MODEL_FIELD_WHEN,{||.T.})
		EndIf
	Else
		Help( , , "At982NAlt", , "Não é possível alterar este registro, pois já houve liberação da quantidade",4,10)
	EndIf
Else
	Help( , , "At982NAlt", , "Não é possível movimentar registros gerados internamente",4,10)
EndIf

Return