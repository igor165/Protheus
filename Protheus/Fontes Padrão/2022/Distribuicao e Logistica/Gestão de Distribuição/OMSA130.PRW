#INCLUDE "PROTHEUS.CH"
#INCLUDE "OMSA130.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------
/*/{Protheus.doc} OMSA120
Cadastro de Time Service
@author  Henry Fila
@since   26/04/2002
@version 1.0
/*/
//-------------------------------------
Function OMSA130()
Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("DAF")         // Alias da tabela utilizada
	oBrowse:SetMenuDef("OMSA130")   // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0006) // Descrição do browse "Cadastro de Time Service"
	oBrowse:SetAmbiente(.F.)        // Desabilita opção Ambiente do menu Ações Relacionadas
	oBrowse:SetWalkThru(.F.)        // Desabilita opção WalkThru do menu Ações Relacionadas
	oBrowse:Activate()

Return Nil

//-------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef
@author  Guilherme A. Metzger
@since   31/05/2018
@version 1.0
/*/
//-------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0001 ACTION "AxPesqui"        OPERATION 1 ACCESS 0  // Pesquisar
	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.OMSA130" OPERATION 2 ACCESS 0  // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.OMSA130" OPERATION 3 ACCESS 0  // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.OMSA130" OPERATION 4 ACCESS 0  // Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.OMSA130" OPERATION 5 ACCESS 0  // Excluir

	// Ponto de entrada utilizado para inserir novas opcoes no array aRotina
	If ExistBlock("OM130MNU")
		ExecBlock("OM130MNU",.F.,.F.)
	EndIf

Return aRotina

//-------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef
@author  Guilherme A. Metzger
@since   31/05/2018
@version 1.0
/*/
//-------------------------------------
Static Function ModelDef()
Local oModel    := Nil
Local oStruCDAF := FWFormStruct(1,"DAF")
Local oStruIDAG := FWFormStruct(1,"DAG")
Local oOmsEvent := OMSA130EVOMS():New() // Evento de validação customizado

	// Todos os SetProperty abaixo podem ser removidos a partir da Release 12.1.22
	oStruCDAF:SetProperty("DAF_GRPCLI",MODEL_FIELD_VALID  ,FwBuildFeature(STRUCT_FEATURE_VALID,'Vazio() .Or. StaticCall(OMSA130,ValidField,A,B,C)'))
	oStruCDAF:SetProperty("DAF_CODCLI",MODEL_FIELD_VALID  ,FwBuildFeature(STRUCT_FEATURE_VALID,'Vazio() .Or. StaticCall(OMSA130,ValidField,A,B,C)'))
	oStruCDAF:SetProperty("DAF_LOJA"  ,MODEL_FIELD_VALID  ,FwBuildFeature(STRUCT_FEATURE_VALID,'Vazio() .Or. StaticCall(OMSA130,ValidField,A,B,C)'))

	oModel:= MPFormModel():New("OMSA130")
	oModel:SetDescription(STR0006) // "Cadastro de Time Service"

	oModel:AddFields("MdFieldCDAF",,oStruCDAF)
	oModel:SetPrimaryKey({"DAF_CODIGO"})

	oModel:AddGrid("MdGridIDAG","MdFieldCDAF",oStruIDAG)
	oModel:SetRelation("MdGridIDAG", { {"DAG_FILIAL","xFilial('DAG')"}, {"DAG_CODIGO","DAF_CODIGO"} }, DAG->(IndexKey(1)))

	oModel:GetModel("MdGridIDAG"):SetUniqueLine({"DAG_PESO","DAG_VOLUME"})

	oModel:InstallEvent("OMSE130", /*cOwner*/, oOmsEvent)

Return oModel

//-------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef
@author  Guilherme A. Metzger
@since   31/05/2018
@version 1.0
/*/
//-------------------------------------
Static Function ViewDef()
Local oModel    := FWLoadModel("OMSA130")
Local oView     := FWFormView():New()
Local oStruCDAF := FWFormStruct(2,"DAF")
Local oStruIDAG := FWFormStruct(2,"DAG")

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VwFieldCDAF",oStruCDAF,"MdFieldCDAF")
	oView:AddGrid("VwGridIDAG",oStruIDAG,"MdGridIDAG")

	oView:CreateHorizontalBox("SUPERIOR",20)
	oView:CreateHorizontalBox("INFERIOR",80)

	oView:EnableTitleView("VwFieldCDAF","Time Service")
	oView:EnableTitleView("VwGridIDAG" ,"Itens do Time Service")

	oView:AddIncrementField("VwGridIDAG","DAG_ITEM")

	oView:SetOwnerView("VwFieldCDAF","SUPERIOR")
	oView:SetOwnerView("VwGridIDAG" ,"INFERIOR")

Return oView

//-------------------------------------
/*/{Protheus.doc} ValidField
Validação de campos
@author  Guilherme A. Metzger
@since   30/05/2018
@version 1.0
/*/
//-------------------------------------
Static Function ValidField(oModel,cField,xValue)

	Do Case
		Case cField == "DAF_GRPCLI"
			Return VldGrupo(oModel,cField,xValue)
		Case cField == "DAF_CODCLI"
			Return VldCliLoj(oModel,cField,xValue)
		Case cField == "DAF_LOJA"
			Return VldCliLoj(oModel,cField,xValue)
	End Case

Return .T.

//-------------------------------------
/*/{Protheus.doc} VldGrupo
Validação do Grupo de Venda x Cliente
@author  Henry Fila
@since   02/03/2001
@version 1.0
/*/
//-------------------------------------
Static Function VldGrupo(oModel,cField,xValue)
Local aArea    := GetArea()
Local aAreaACY := ACY->(GetArea())
Local aAreaDAF := DAF->(GetArea())
Local cGrpCli  := xValue
Local cCodCli  := oModel:GetValue("DAF_CODCLI")
Local cCodLoj  := oModel:GetValue("DAF_LOJA")
Local lRet     := .T.

	If !Empty(cGrpCli) .And. (!Empty(cCodCli) .Or. !Empty(cCodLoj))
		OmsHelp("É possível escolher apenas um Grupo de Clientes ou um conjunto de Cliente e Loja para cada Time Service.")
		Return .F.
	EndIf

	DAF->(dbSetOrder(2))
	If !DAF->(DbSeek(xFilial("DAF")+cGrpCli))

		ACY->(dbSetOrder(1))
		If !ACY->(DbSeek(xFilial("ACY")+cGrpCli))
			Help(" ",1,"REGNOIS") // Não existe registro relacionado a este código
			lRet := .F.
		EndIf

	Else
		Help(" ",1,"JAGRAVADO") // Já existe registro com esta informação
		lRet := .F.
	EndIf

RestArea(aAreaACY)
RestArea(aAreaDAF)
RestArea(aArea)
Return lRet

//-------------------------------------
/*/{Protheus.doc} VldCliLoj
Validação do Cliente x Grupo de Venda
@author  Henry Fila
@since   02/03/2001
@version 1.0
/*/
//-------------------------------------
Static Function VldCliLoj(oModel,cField,xValue)
Local aAreaAnt := GetArea()
Local aAreaSD1 := SD1->(GetArea())
Local cGrpCli  := oModel:GetValue("DAF_GRPCLI")
Local cCodCli  := oModel:GetValue("DAF_CODCLI")
Local cCodLoj  := oModel:GetValue("DAF_LOJA")

	If !Empty(cGrpCli) .And. (!Empty(cCodCli) .Or. !Empty(cCodLoj))
		OmsHelp("É possível escolher apenas um Grupo de Clientes ou um conjunto de Cliente e Loja para cada Time Service.")
		Return .F.
	EndIf

	SA1->(dbSetOrder(1))
	If !SA1->(DbSeek(xFilial("SA1")+cCodCli+Iif(!Empty(cCodLoj),cCodLoj,"")))
		Help(" ",1,"REGNOIS") // Não existe registro relacionado a este código
		RestArea(aAreaSD1)
		Return .F.
	EndIf

RestArea(aAreaSD1)
RestArea(aAreaAnt)
Return .T.
