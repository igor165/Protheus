#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PCOA306.CH'


//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA306
Cadastro de Divida Publica para Metal Anual
@author TOTVS
@since 25/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PCOA306()
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

	oBrowse:SetAlias('A27')
	oBrowse:SetDescripton(STR0001)  //"Cadastro de Divida Publica para Metal Anual"

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

ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.PCOA306' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.PCOA306' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.PCOA306' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.PCOA306' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.PCOA306' OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE STR0007 Action 'VIEWDEF.PCOA306' OPERATION 9 ACCESS 0 //"Copiar"

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
Local oStruA27 := FWFormStruct(1,'A27')
Local oModel

oModel := MPFormModel():New('PCOA306', /*bPreValid*/, {|oModel|PosVld306(oModel)}, /*bCommitPos*/, /*bCancel*/)

//Adiciona valide
oStruA27:SetProperty('A27_CONTA',MODEL_FIELD_VALID ,{|oModel|P306VLDCONTA(oModel)})

//Criação de gatilho
oStruA27:AddTrigger("A27_CONTA","A27_DESC",{|| .T. },{||P306GATILHO()})

// Adiciona a descrição do modelo de dados.
oModel:SetDescription(STR0001)  //"Cadastro de Divida Publica para Metal Anual"

// Adiciona ao modelo um componente de formulario.
oModel:AddFields('A27MASTER', /*cOwner*/, oStruA27, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
oModel:GetModel('A27MASTER'):SetDescription(STR0001)  //"Cadastro de Divida Publica para Metal Anual"

// Configura chave primaria.
oModel:SetPrimaryKey({"A27_FILIAL", "A27_ANO"})

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

Local oModel    := FWLoadModel('PCOA306')

Local oStructA27   := FWFormStruct(2, 'A27')

Local oView := FWFormView():New()

oView:SetModel(oModel)

oView:bCloseOnOk := {|| .T.}

// Adiciona no nosso view um controle do tipo formulario (antiga enchoice).
oView:AddField('VIEW_A27', oStructA27, 'A27MASTER')

// Cria um "box" horizontal para receber cada elemento da view.
oView:CreateHorizontalBox('SUPERIOR', 100)

// Relaciona o identificador (ID) da view com o "box" para exibicao.
oView:SetOwnerView('VIEW_A27', 'SUPERIOR')

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

Static function PosVld306(oModel)

Local lRet 		:= .T.
Local nOper 	:= oModel:GetOperation()

If nOper == MODEL_OPERATION_INSERT

	If ExistCPO("A27", oModel:GetValue("A27MASTER", "A27_ANO")+oModel:GetValue("A27MASTER", "A27_CONTA"))
		HELP(' ',1,"JAEXST" ,,STR0008,1,0)//"Já existe um cadastro para esse ano e essa conta."
		lRet := .F.
	EndIf

EndIf

Return lRet


Static Function P306GATILHO()
Local cRet := "" 
Local oModel := FWModelActive()
Local oMdlA27 := oModel:GetModel( 'A27MASTER' )

cRet := POSICIONE("CT1",1,xFilial("CT1")+oMdlA27:GetValue("A27_CONTA"),"CT1_DESC01")

Return cRet

Static Function P306VLDCONTA(oModel)
Local lRet := .T.
Local cConta := oModel:GetValue("A27_CONTA")
Local aArea	:= GetArea()
Local aAreaCT1 := CT1->(Getarea())

DBSelectArea("CT1")
CT1->(DBSetOrder(1))

If CT1->(DBSeek(xFilial("CT1")+cConta))
	If CT1->CT1_CLASSE == '2'
		lRet := .F.
		HELP(' ',1,"NAOCONTAANA" ,,STR0009,1,0) //"Conta Contabil não pode ser analitica."
	EndIF
Else
	lRet := .F.
	HELP(' ',1,"CONTANAOEXISTE" ,,STR0010,1,0)//"Conta Contabil não existe."
EndIf

RestArea(aArea)
RestArea(aAreaCT1)
Return lRet