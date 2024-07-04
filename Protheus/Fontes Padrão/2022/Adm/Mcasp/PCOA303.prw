#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PCOA303.CH'


//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA303
@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PCOA303()
Local oBrowse

Private oBrowse := BrowseDef()

// Ativa browse.
oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA303
Cadastro de PIB Estadual pata metas anuais
@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------

Static Function BrowseDef()

	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias('A24')
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

ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.PCOA303' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.PCOA303' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.PCOA303' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.PCOA303' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.PCOA303' OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE STR0007 Action 'VIEWDEF.PCOA303' OPERATION 9 ACCESS 0 //"Copiar"

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
Local oStruA24 := FWFormStruct(1,'A24')
Local oModel

oModel := MPFormModel():New('PCOA303', /*bPreValid*/, {|oModel|PosVld303(oModel)}, /*bCommitPos*/, /*bCancel*/)
//oModel:SetVldActivate({|oModel| ValidPre(oModel)})

oStruA24:SetProperty('A24_ANO',MODEL_FIELD_WHEN,{|oModel|INCLUI})

// Adiciona a descrição do modelo de dados.
oModel:SetDescription(STR0001)  //"Cadastro de PIB Estadual pata metas anuais"

// Adiciona ao modelo um componente de formulario.
oModel:AddFields('A24MASTER', /*cOwner*/, oStruA24, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
oModel:GetModel('A24MASTER'):SetDescription(STR0001)  //"Cadastro de PIB Estadual pata metas anuais"

// Configura chave primaria.
oModel:SetPrimaryKey({"A24_FILIAL", "A24_ANO"})

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

Local oModel    := FWLoadModel('PCOA303')

Local oStructA24   := FWFormStruct(2, 'A24')

Local oView := FWFormView():New()

oView:SetModel(oModel)

oView:bCloseOnOk := {|| .T.}

// Adiciona no nosso view um controle do tipo formulario (antiga enchoice).
oView:AddField('VIEW_A24', oStructA24, 'A24MASTER')

// Cria um "box" horizontal para receber cada elemento da view.
oView:CreateHorizontalBox('SUPERIOR', 100)

// Relaciona o identificador (ID) da view com o "box" para exibicao.
oView:SetOwnerView('VIEW_A24', 'SUPERIOR')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PosVld303
Pós validação do PCOA303
Cadastro de PIB Estadual pata metas anuais
@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------

Static function PosVld303(oModel)

Local lRet 		:= .T.
Local nOper 	:= oModel:GetOperation()

If nOper == MODEL_OPERATION_INSERT

	If ExistCPO("A24", oModel:GetValue("A24MASTER", "A24_ANO"))
		HELP(' ',1,"JAEXST" ,,STR0008,1,0)//"Já existe um PIB Estadual cadastrado neste ano "
		lRet := .F.
	EndIf

EndIf

Return lRet