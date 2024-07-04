#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PCOA307.CH'


//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA306
CADASTRO DE JUROS PARA METAS ANUAIS      
@author TOTVS
@since 25/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PCOA307()
Local oBrowse

Private oBrowse := BrowseDef()

// Ativa browse.
oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA306
Cadastro de Divida Publica para Metal Anual
@author TOTVS
@since 25/11/2020
@version P12
/*/
//-------------------------------------------------------------------

Static Function BrowseDef()

	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias('A28')
	oBrowse:SetDescripton(STR0001)  //"Cadastro de Juros para Metal Anual"

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da Rotina

@author TOTVS
@since 25/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.PCOA307' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.PCOA307' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.PCOA307' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.PCOA307' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.PCOA307' OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE STR0007 Action 'VIEWDEF.PCOA307' OPERATION 9 ACCESS 0 //"Copiar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados da Rotina

@author TOTVS
@since 125/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruA28 := FWFormStruct(1,'A28')
Local oModel

oModel := MPFormModel():New('PCOA307', /*bPreValid*/, {|oModel|PosVld307(oModel)}, /*bCommitPos*/, /*bCancel*/)

// Adiciona a descrição do modelo de dados.
oModel:SetDescription(STR0001)  //"Cadastro de Juros para Metal Anual"

//When
oStruA28:SetProperty('A28_ANO',MODEL_FIELD_WHEN,{|oModel|INCLUI})
oStruA28:SetProperty('A28_CATEGO',MODEL_FIELD_WHEN,{|oModel|INCLUI})

// Adiciona ao modelo um componente de formulario.
oModel:AddFields('A28MASTER', /*cOwner*/, oStruA28, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
oModel:GetModel('A28MASTER'):SetDescription(STR0001)  //"Cadastro de Juros para Metal Anual"

// Configura chave primaria.
oModel:SetPrimaryKey({"A28_FILIAL", "A28_CATEGO","A28_ANO"})

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

Local oModel    := FWLoadModel('PCOA307')

Local oStructA28   := FWFormStruct(2, 'A28')

Local oView := FWFormView():New()

oView:SetModel(oModel)

oView:bCloseOnOk := {|| .T.}

// Adiciona no nosso view um controle do tipo formulario (antiga enchoice).
oView:AddField('VIEW_A28', oStructA28, 'A28MASTER')

// Cria um "box" horizontal para receber cada elemento da view.
oView:CreateHorizontalBox('SUPERIOR', 100)

// Relaciona o identificador (ID) da view com o "box" para exibicao.
oView:SetOwnerView('VIEW_A28', 'SUPERIOR')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PosVld307
Pós validação do PCOA307
Cadastro de Juros para metas anuais
@author TOTVS
@since 14/12/2020
@version P12
/*/
//-------------------------------------------------------------------

Static function PosVld307(oModel)

Local lRet 		:= .T.
Local nOper 	:= oModel:GetOperation()

If nOper == MODEL_OPERATION_INSERT

	If ExistCPO("A28", oModel:GetValue("A28MASTER", "A28_CATEGO")+oModel:GetValue("A28MASTER", "A28_ANO"))
		HELP(' ',1,"JAEXST" ,,STR0008,1,0)//"Já existe um cadastro para esse ano e essa categoria."
		lRet := .F.
	EndIf

EndIf

Return lRet