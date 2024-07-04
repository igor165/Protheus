#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PCOA304.CH'


//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA304
@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PCOA304()
Local oBrowse

Private oBrowse := BrowseDef()

// Ativa browse.
oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA304
Cadastro de PIB Estadual pata metas anuais
@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------

Static Function BrowseDef()

	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias('A26')
	oBrowse:SetDescripton(STR0001)  // "Cadastro de PIB Estadual pata metas anuais"

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da Rotina

@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.PCOA304' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.PCOA304' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.PCOA304' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.PCOA304' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.PCOA304' OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE STR0007 Action 'VIEWDEF.PCOA304' OPERATION 9 ACCESS 0 //"Copiar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados da Rotina

@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruA26 := FWFormStruct(1,'A26')
Local oModel
// Local aAux		:= {}

oModel := MPFormModel():New('PCOA304', /*bPreValid*/,{|oModel|PosVld304(oModel)}, /*bCommitPos*/, /*bCancel*/)
//oModel:SetVldActivate({|oModel| ValidPre(oModel)})

oStruA26:SetProperty('A26_CONTA',MODEL_FIELD_VALID ,{|oModel|P304VLDCONTA(oModel)})

//aAux := FwStruTrigger("A26_CONTA","A26_CTDESC", "CT1->CT1_DESC01",.T.,"CT1",/*nOrdem*/,/*cChave*/,/*cCondic*/,/*cSequen*/)
oStruA26:AddTrigger("A26_CONTA", "A26_CTDESC", {|| .T.}, {|| P304GATILHO() })

oStruA26:SetProperty('A26_ANO',MODEL_FIELD_WHEN,{|oModel|INCLUI})
oStruA26:SetProperty('A26_CONTA',MODEL_FIELD_WHEN,{|oModel|INCLUI})

// Adiciona a descrição do modelo de dados.
oModel:SetDescription(STR0001)  //"Cadastro de PIB Estadual pata metas anuais"

// Adiciona ao modelo um componente de formulario.
oModel:AddFields('A26MASTER', /*cOwner*/, oStruA26, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
oModel:GetModel('A26MASTER'):SetDescription(STR0001)  //"Cadastro de PIB Estadual pata metas anuais"

// Configura chave primaria.
oModel:SetPrimaryKey({"A26_FILIAL", "A26_CONTA" , "A26_ANO"})

// Retorna o Modelo de dados.

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Tela da Rotina
Cadastro de PIB Estadual pata metas anuais
@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel    := FWLoadModel('PCOA304')

Local oStructA26   := FWFormStruct(2, 'A26')

Local oView := FWFormView():New()

oView:SetModel(oModel)

oView:bCloseOnOk := {|| .T.}

// Adiciona no nosso view um controle do tipo formulario (antiga enchoice).
oView:AddField('VIEW_A26', oStructA26, 'A26MASTER')

// Cria um "box" horizontal para receber cada elemento da view.
oView:CreateHorizontalBox('SUPERIOR', 100)

// Relaciona o identificador (ID) da view com o "box" para exibicao.
oView:SetOwnerView('VIEW_A26', 'SUPERIOR')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} P304GATILHO
Gatilho para descrição de conta 
@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------

Static Function P304GATILHO()
Local cRet := "" 
Local oModel := FWModelActive()
Local oModelA26 := oModel:GetModel( 'A26MASTER' )

cRet := POSICIONE("CT1",1,xFilial("CT1")+oModelA26:GetValue("A26_CONTA"),"CT1_DESC01")

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} P304VLDCONTA
Validação de conta, permitir apenas contas sintéticas
@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------

Static Function P304VLDCONTA(oModel)
Local lRet := .T.
Local cConta := oModel:GetValue("A26_CONTA")
Local aArea	:= GetArea()
Local aAreaCT1 := CT1->(Getarea())

DBSelectArea("CT1")
CT1->(DBSetOrder(1))

If CT1->(DBSeek(xFilial("CT1")+cConta))
	If CT1->CT1_CLASSE == '2'
		lRet := .F.
		HELP(' ',1,"NAOCONTA" ,,STR0008,1,0)
	EndIF
Else
	lRet := .F.
	HELP(' ',1,"NAOCONTA" ,,,1,0)//"Já existe uma cadastro para esse ano e essa conta."
EndIf

RestArea(aArea)
RestArea(aAreaCT1)
Return lRet  


Static Function PosVld304(oModel)

Local lRet 		:= .T.
Local nOper 	:= oModel:GetOperation()

If nOper == MODEL_OPERATION_INSERT

	If ExistCPO("A26", oModel:GetValue("A26MASTER", "A26_CONTA")+oModel:GetValue("A26MASTER", "A26_ANO"))
		HELP(' ',1,"JAEXST" ,,STR0010,1,0)//"Já existe uma dedução de receita neste ano com esta conta "
		lRet := .F.
	EndIf

EndIf


Return lRet