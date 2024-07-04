#INCLUDE "PROTHEUS.CH"
#INCLUDE "OMSA120.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------
/*/{Protheus.doc} OMSA120
Cadastro de Regras de Entregas
@author  Henry Fila
@since   26/04/2002
@version 1.0
/*/
//-------------------------------------
Function OMSA120()
Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("DAD")         // Alias da tabela utilizada
	oBrowse:SetMenuDef("OMSA120")   // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0006) // Descrição do browse "Cadastro de Regras de Entrega"
	oBrowse:SetAmbiente(.F.)        // Desabilita opção Ambiente do menu Ações Relacionadas
	oBrowse:SetWalkThru(.F.)        // Desabilita opção WalkThru do menu Ações Relacionadas
	oBrowse:Activate()

Return Nil

//-------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef
@author  Guilherme A. Metzger
@since   30/05/2018
@version 1.0
/*/
//-------------------------------------
Static Function MenuDef()
Private  aRotina := {}

	ADD OPTION aRotina TITLE STR0001 ACTION "AxPesqui"        OPERATION 1 ACCESS 0  // Pesquisar
	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.OMSA120" OPERATION 2 ACCESS 0  // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.OMSA120" OPERATION 3 ACCESS 0  // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.OMSA120" OPERATION 4 ACCESS 0  // Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.OMSA120" OPERATION 5 ACCESS 0  // Excluir

	// Ponto de entrada utilizado para inserir novas opcoes no array aRotina
	If ExistBlock("OM120MNU")
		ExecBlock("OM120MNU",.F.,.F.)
	EndIf

Return aRotina

//-------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef
@author  Guilherme A. Metzger
@since   30/05/2018
@version 1.0
/*/
//-------------------------------------
Static Function ModelDef()
Local oModel    := Nil
Local oStruCDAD := FWFormStruct(1,"DAD")
Local oStruIDAE := FWFormStruct(1,"DAE")
Local oOmsEvent := OMSA120EVOMS():New() // Evento de validação customizado

	oStruCDAD:SetProperty("DAD_GRPVEN",MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,'Vazio() .Or. StaticCall(OMSA120,ValidField,A,B,C)'        ))
	oStruCDAD:SetProperty("DAD_CODCLI",MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,'Vazio() .Or. StaticCall(OMSA120,ValidField,A,B,C)'        ))
	oStruCDAD:SetProperty("DAD_LOJA"  ,MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,'Vazio() .Or. StaticCall(OMSA120,ValidField,A,B,C)'        ))
	oStruIDAE:SetProperty("DAE_GRUVEI",MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,'StaticCall(OMSA120,ValidField,A,B,C)'                      ))
	oStruIDAE:SetProperty("DAE_CODVEI",MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,'StaticCall(OMSA120,ValidField,A,B,C)'                      ))
	oStruIDAE:SetProperty("DAE_CODCAL",MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,'ExistCpo("DAA") .And. StaticCall(OMSA120,ValidField,A,B,C)'))
	oStruIDAE:SetProperty("DAE_HRINI" ,MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,'StaticCall(OMSA120,ValidField,A,B,C)'                      ))
	oStruIDAE:SetProperty("DAE_HRFIM" ,MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,'StaticCall(OMSA120,ValidField,A,B,C)'                      ))

	oStruIDAE:SetProperty("DAE_DESGRU", MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'StaticCall(OMSA120,GetDesField,A,B)'))
	oStruIDAE:SetProperty("DAE_DESVEI", MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'StaticCall(OMSA120,GetDesField,A,B)'))

	oModel:= MPFormModel():New("OMSA120")
	oModel:SetDescription(STR0006) // "Cadastro de Regras de Entrega"

	oModel:AddFields("MdFieldCDAD",,oStruCDAD)
	oModel:SetPrimaryKey({"DAD_CODIGO"})

	oModel:AddGrid("MdGridIDAE", "MdFieldCDAD", oStruIDAE)
	oModel:SetRelation("MdGridIDAE", { {"DAE_FILIAL","xFilial('DAE')"}, {"DAE_CODIGO","DAD_CODIGO"} }, DAE->(IndexKey(1)))

	oModel:GetModel("MdGridIDAE"):SetUniqueLine({"DAE_GRUVEI","DAE_CODVEI","DAE_CODCAL","DAE_HRINI","DAE_HRFIM"})

	oModel:InstallEvent("OMSE120", /*cOwner*/, oOmsEvent)

Return oModel

//-------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef
@author  Guilherme A. Metzger
@since   30/05/2018
@version 1.0
/*/
//-------------------------------------
Static Function ViewDef()
Local oModel    := FWLoadModel("OMSA120")
Local oView     := FWFormView():New()
Local oStruCDAD := FWFormStruct(2,"DAD")
Local oStruIDAE := FWFormStruct(2,"DAE")

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VwFieldCDAD", oStruCDAD , "MdFieldCDAD")
	oView:AddGrid("VwGridIDAE", oStruIDAE , "MdGridIDAE")

	oView:CreateHorizontalBox("SUPERIOR",20)
	oView:CreateHorizontalBox("INFERIOR",80)

	oView:EnableTitleView("VwFieldCDAD",STR0007) // "Regra de Entrega"
	oView:EnableTitleView("VwGridIDAE" ,STR0008) // "Itens da Regra de Entrega"

	oView:SetOwnerView("VwFieldCDAD","SUPERIOR")
	oView:SetOwnerView("VwGridIDAE" ,"INFERIOR")

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
		Case cField == "DAD_GRPVEN"
			Return VldGrupo(oModel,cField,xValue)
		Case cField == "DAD_CODCLI"
			Return VldCliLoj(oModel,cField,xValue)
		Case cField == "DAD_LOJA"
			Return VldCliLoj(oModel,cField,xValue)
		Case cField == "DAE_GRUVEI"
			Return VldVeiculo(oModel,cField,xValue)
		Case cField == "DAE_CODVEI"
			Return VldVeiculo(oModel,cField,xValue)
		Case cField == "DAE_CODCAL"
			Return VldCodCal(oModel,cField,xValue)
		Case cField == "DAE_HRINI"
			Return VldHora(oModel,cField,xValue)
		Case cField == "DAE_HRFIM"
			Return VldHora(oModel,cField,xValue)
	End Case

Return .T.

//-------------------------------------
/*/{Protheus.doc} ValidField
Validação de campos
@author  Guilherme A. Metzger
@since   31/05/2018
@version 1.0
/*/
//-------------------------------------
Static Function GetDesField(oModel,cField)
Local nLinha := oModel:GetQtdLine()
Local cRet   := ""
	// Impede que a descrição apareça na inclusão de itens durante a alteração
	If nLinha > 0
		cRet := ""
	Else
		If cField == "DAE_DESGRU"
			cRet := Iif(Inclui,"",Posicione("DAC",1,xFilial("DAC")+DAE->DAE_GRUVEI,"DAC_DESGRU"))
		EndIf
		If cField == "DAE_DESVEI"
			cRet := Iif(Inclui,"",Posicione("DA3",1,xFilial("DA3")+DAE->DAE_CODVEI,"DA3_DESC"))
		EndIf
	EndIf
Return cRet

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
Local aAreaDAD := DAD->(GetArea())
Local cGrpCli  := xValue
Local cCodCli  := oModel:GetValue("DAD_CODCLI")
Local cCodLoj  := oModel:GetValue("DAD_LOJA")
Local lRet     := .T.

	If !Empty(cGrpCli) .And. (!Empty(cCodCli) .Or. !Empty(cCodLoj))
		Help(" ",1,"OMS120CLI") // É possível escolher apenas o Grupo de Clientes ou o cliente para cada Regra de Entregas
		Return .F.
	EndIf

	DAD->(dbSetOrder(2))
	If !DAD->(DbSeek(xFilial("DAD")+cGrpCli))

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
RestArea(aAreaDAD)
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
Local aAreaAnt   := GetArea()
Local aAreaSD1   := SD1->(GetArea())
Local aAreaDAD   := DAD->(GetArea())
Local cGrpCli    := oModel:GetValue("DAD_GRPVEN")
Local cCodCli    := oModel:GetValue("DAD_CODCLI")
Local cCodLoj    := oModel:GetValue("DAD_LOJA")
Local oModelGrid := Nil
Local cQuery     := ""
Local cAliasQry  := ""
Local cCodCal    := ""
Local nX         := 0
Local lRet       := .T.

	If !Empty(cGrpCli) .And. (!Empty(cCodCli) .Or. !Empty(cCodLoj))
		Help(" ",1,"OMS120CLI") // É possível escolher apenas o Grupo de Clientes ou o cliente para cada Regra de Entregas
		Return .F.
	EndIf

	SA1->(dbSetOrder(1))
	If !SA1->(DbSeek(xFilial("SA1")+cCodCli+Iif(!Empty(cCodLoj),cCodLoj,"")))
		Help(" ",1,"REGNOIS") // Não existe registro relacionado a este código
		RestArea(aAreaSD1)
		Return .F.
	EndIf

	DAD->(dbSetOrder(2))
	If !DAD->(DbSeek(xFilial("DAD")+cGrpCli+cCodCli+cCodLoj))
		If !Empty(cGrpCli)
			RestArea(aAreaDAD)
			RestArea(aAreaSD1)
			Return .T.
		EndIf
		cQuery := "SELECT DA6_CODCAL"
		cQuery +=  " FROM "+RetSqlName("DA6")+" DA6,"
		cQuery +=           RetSqlName("DA7")+" DA7"
		cQuery += " WHERE DA6.DA6_FILIAL = '"+xFilial("DA6")+"'"
		cQuery +=   " AND DA6.DA6_PERCUR = DA7.DA7_PERCUR"
		cQuery +=   " AND DA6.DA6_ROTA   = DA7.DA7_ROTA"
		cQuery +=   " AND DA6.D_E_L_E_T_ = ' '"
		cQuery +=   " AND DA7.DA7_FILIAL = '"+xFilial("DA7")+"'"
		cQuery +=   " AND DA7.DA7_CLIENT = '"+cCodCli+"'"
		cQuery +=   " AND DA7.DA7_LOJA   = '"+cCodLoj+"'"
		cQuery +=   " AND DA7.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If !(cAliasQry)->(Eof())
			oModel     := oModel:GetModel()
			oModelGrid := oModel:GetModel("MdGridIDAE")
			For nX := 1 To oModelGrid:Length()
				oModelGrid:GoLine(nX)
				cCodCal := oModelGrid:GetValue("DAE_CODCAL")
				If !Empty(cCodCal) .And. !(OmsVldCal((cAliasQry)->DA6_CODCAL,cCodCal))
					Help(" ",1,"OMS080CAL") // Existem dias incompatíveis com o calendário associado a zona
					lRet := .F.
					Exit
				EndIf
			Next
		EndIf
		(cAliasQry)->(DbCloseArea())
	Else
		oModel:SetValue("DAD_CODCLI",Space(Len(SA1->A1_COD )))
		oModel:SetValue("DAD_LOJA"  ,Space(Len(SA1->A1_LOJA)))
		Help(" ",1,"JAGRAVADO") // Já existe registro com esta informação
		lRet := .F.
	EndIf

RestArea(aAreaDAD)
RestArea(aAreaSD1)
RestArea(aAreaAnt)
Return lRet

//-------------------------------------
/*/{Protheus.doc} VldVeiculo
Validação do Grupo e Código do Veículo
@author  Henry Fila
@since   02/03/2001
@version 1.0
/*/
//-------------------------------------
Static Function VldVeiculo(oModel,cField,xValue)
Local aArea      := GetArea()
Local aAreaACY   := DAC->(GetArea())
Local oModelGrid := oModel:GetModel():GetModel("MdGridIDAE")
Local cGrpVeic   := ""
Local cCodVeic   := ""
Local lRet       := .T.

	If cField == "DAE_GRUVEI"

		cGrpVeic := oModelGrid:GetValue("DAE_GRUVEI")

		If !Empty(cGrpVeic)

			DAC->(dbSetOrder(1))
			If !DAC->(MsSeek(xFilial("DAC")+cGrpVeic))
				Help(" ",1,"REGNOIS") // Não existe registro relacionado a este código
				lRet := .F.
			Else
				oModelGrid:SetValue("DAE_DESGRU",DAC->DAC_DESGRU)
			EndIf

		Else
			oModelGrid:SetValue("DAE_DESGRU","")
		EndIf

	ElseIf cField == "DAE_CODVEI"

		cCodVeic := oModelGrid:GetValue("DAE_CODVEI")

		If !Empty(cCodVeic)

			DA3->(dbSetOrder(1))
			If !DA3->(MsSeek(xFilial("DA3")+cCodVeic))
				Help(" ",1,"REGNOIS") // Não existe registro relacionado a este código
				lRet    := .F.
			Else
				oModelGrid:SetValue("DAE_DESVEI",DA3->DA3_DESC)
			EndIf

		Else
			oModelGrid:SetValue("DAE_DESVEI","")
		EndIf
	EndIf

RestArea(aAreaACY)
RestArea(aArea)
Return lRet

//-------------------------------------
/*/{Protheus.doc} VldCodCal
Validação do Calendário da Regra
@author  Henry Fila
@since   02/03/2001
@version 1.0
/*/
//-------------------------------------
Static Function VldCodCal(oModel,cField,xValue)
Local aArea     := GetArea()
Local cCodCal   := xValue
Local oModelFld := oModel:GetModel():GetModel("MdFieldCDAD")
Local cCodCli   := oModelFld:GetValue("DAD_CODCLI")
Local cCodLoj   := oModelFld:GetValue("DAD_LOJA")
Local cQuery    := ""
Local cAliasQry := ""
Local lRet      := .T.

	If !Empty(cCodCal)
		cQuery := "SELECT DA6_CODCAL"
		cQuery +=  " FROM "+RetSqlName("DA6")+" DA6,"
		cQuery +=           RetSqlName("DA7")+" DA7"
		cQuery += " WHERE DA6.DA6_FILIAL = '"+xFilial("DA6")+"'"
		cQuery +=   " AND DA6.DA6_PERCUR = DA7.DA7_PERCUR"
		cQuery +=   " AND DA6.DA6_ROTA   = DA7.DA7_ROTA"
		cQuery +=   " AND DA6.D_E_L_E_T_ = ' '"
		cQuery +=   " AND DA7.DA7_FILIAL = '"+xFilial("DA7")+"'"
		cQuery +=   " AND DA7.DA7_CLIENT = '"+cCodCli+"'"
		cQuery +=   " AND DA7.DA7_LOJA   = '"+cCodLoj+"'"
		cQuery +=   " AND DA7.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If !(cAliasQry)->(Eof())
			If !OmsVldCal((cAliasQry)->DA6_CODCAL,cCodCal)
				Help(" ",1,"OMS080CAL") // Existem dias incompatíveis com o calendário associado a zona
			EndIf
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf

RestArea(aArea)
Return lRet

//-------------------------------------
/*/{Protheus.doc} VldHora
Validação de Hora Inicial e Final
@author  Guilherme A. Metzger
@since   31/05/2018
@version 1.0
/*/
//-------------------------------------
Static Function VldHora(oModel,cField,xValue)
Local oModelGrid := oModel:GetModel():GetModel("MdGridIDAE")
Local cHoraIni   := oModelGrid:GetValue("DAE_HRINI")
Local cHoraFim   := oModelGrid:GetValue("DAE_HRFIM")

	If !AtVldHora(xValue)
		Return .F.
	EndIf

	If cHoraIni > cHoraFim
		Help(" ",1,"OMS120HR") // Hora inicial deve ser menor que hora final
		Return .F.
	EndIf

Return .T.
